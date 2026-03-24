with demand_quality as (
    select
        'stg_student_demand' as model_name,
        count(*) as row_count,
        sum(case when bezirk_clean is null then 1 else 0 end) as missing_bezirk_clean,
        sum(case when schulart_clean is null then 1 else 0 end) as missing_schulart_clean,
        sum(case when students is null then 1 else 0 end) as missing_students,
        sum(case when traeger is null then 1 else 0 end) as missing_traeger,
        sum(case when lower(coalesce(bezirk_raw, '')) like '%k. a.%' then 1 else 0 end) as unknown_bezirk_marker,
        sum(case when lower(coalesce(schulart_raw, '')) like '%k. a.%' then 1 else 0 end) as unknown_schulart_marker
    from {{ ref('stg_student_demand') }}
),

construction_quality as (
    select
        'stg_school_construction_projects' as model_name,
        count(*) as row_count,
        sum(case when bezirk_clean is null then 1 else 0 end) as missing_bezirk_clean,
        sum(case when schulart_clean is null then 1 else 0 end) as missing_schulart_clean,
        sum(case when planned_capacity is null then 1 else 0 end) as missing_planned_capacity,
        sum(case when total_cost_eur is null then 1 else 0 end) as missing_total_cost_eur,
        sum(case when handover_year_start is null then 1 else 0 end) as missing_handover_year_start,
        sum(case when lower(coalesce(bezirk_raw, '')) like '%k. a.%' then 1 else 0 end) as unknown_bezirk_marker,
        sum(case when lower(coalesce(schulart_raw, '')) like '%k. a.%' then 1 else 0 end) as unknown_schulart_marker
    from {{ ref('stg_school_construction_projects') }}
),

unioned as (
    select
        model_name,
        row_count,
        cast(missing_bezirk_clean + missing_schulart_clean + missing_students + missing_traeger as bigint) as missing_cell_count,
        cast(row_count * 4 as bigint) as assessed_cell_count,
        cast(unknown_bezirk_marker + unknown_schulart_marker as bigint) as unknown_marker_count
    from demand_quality

    union all

    select
        model_name,
        row_count,
        cast(missing_bezirk_clean + missing_schulart_clean + missing_planned_capacity + missing_total_cost_eur + missing_handover_year_start as bigint) as missing_cell_count,
        cast(row_count * 5 as bigint) as assessed_cell_count,
        cast(unknown_bezirk_marker + unknown_schulart_marker as bigint) as unknown_marker_count
    from construction_quality
),

scored as (
    select
        model_name,
        row_count,
        assessed_cell_count,
        missing_cell_count,
        unknown_marker_count,
        round((1.0 - cast(missing_cell_count as double) / nullif(cast(assessed_cell_count as double), 0.0)) * 100.0, 2) as completeness_pct,
        round(cast(missing_cell_count as double) / nullif(cast(assessed_cell_count as double), 0.0) * 100.0, 2) as missingness_pct,
        round((1.0 - cast(missing_cell_count + unknown_marker_count as double) / nullif(cast(assessed_cell_count as double), 0.0)) * 100.0, 2) as data_trust_score
    from unioned
),

overall as (
    select
        'overall' as model_name,
        sum(row_count) as row_count,
        sum(assessed_cell_count) as assessed_cell_count,
        sum(missing_cell_count) as missing_cell_count,
        sum(unknown_marker_count) as unknown_marker_count,
        round((1.0 - cast(sum(missing_cell_count) as double) / nullif(cast(sum(assessed_cell_count) as double), 0.0)) * 100.0, 2) as completeness_pct,
        round(cast(sum(missing_cell_count) as double) / nullif(cast(sum(assessed_cell_count) as double), 0.0) * 100.0, 2) as missingness_pct,
        round((1.0 - cast(sum(missing_cell_count + unknown_marker_count) as double) / nullif(cast(sum(assessed_cell_count) as double), 0.0)) * 100.0, 2) as data_trust_score
    from unioned
)

select * from scored
union all
select * from overall
