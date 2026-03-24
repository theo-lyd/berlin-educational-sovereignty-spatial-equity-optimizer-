with demand as (
    select
        'stg_student_demand' as model_name,
        count(*) as row_count,
        sum(case when bezirk_clean is null then 1 else 0 end) as missing_bezirk,
        sum(case when schulart_clean is null then 1 else 0 end) as missing_schulart,
        sum(case when students is null then 1 else 0 end) as missing_students,
        sum(case when students < 0 then 1 else 0 end) as invalid_students,
        sum(case when lower(coalesce(bezirk_raw, '')) like '%k. a.%' then 1 else 0 end) as ka_bezirk,
        sum(case when lower(coalesce(schulart_raw, '')) like '%k. a.%' then 1 else 0 end) as ka_schulart,
        sum(case when bezirk_clean is null or schulart_clean is null or students is null then 1 else 0 end) as incomplete_records
    from {{ ref('stg_student_demand') }}
),

construction as (
    select
        'stg_school_construction_projects' as model_name,
        count(*) as row_count,
        sum(case when bezirk_clean is null then 1 else 0 end) as missing_bezirk,
        sum(case when schulart_clean is null then 1 else 0 end) as missing_schulart,
        sum(case when planned_capacity is null then 1 else 0 end) as missing_students,
        sum(case when planned_capacity < 0 or track_structure < 0 then 1 else 0 end) as invalid_students,
        sum(case when lower(coalesce(bezirk_raw, '')) like '%k. a.%' then 1 else 0 end) as ka_bezirk,
        sum(case when lower(coalesce(schulart_raw, '')) like '%k. a.%' then 1 else 0 end) as ka_schulart,
        sum(
            case
                when bezirk_clean is null
                  or schulart_clean is null
                  or planned_capacity is null
                  or total_cost_eur is null
                  or handover_year_start is null
                then 1 else 0
            end
        ) as incomplete_records
    from {{ ref('stg_school_construction_projects') }}
),

unioned as (
    select * from demand
    union all
    select * from construction
)

select
    model_name,
    row_count,
    missing_bezirk,
    missing_schulart,
    missing_students,
    invalid_students,
    ka_bezirk,
    ka_schulart,
    incomplete_records,
    round(cast(missing_bezirk + missing_schulart + missing_students as double) / nullif(cast(row_count as double), 0.0) * 100.0, 2) as missing_value_rate_pct,
    round(cast(invalid_students as double) / nullif(cast(row_count as double), 0.0) * 100.0, 2) as invalid_value_rate_pct,
    round(cast(ka_bezirk + ka_schulart as double) / nullif(cast(row_count as double), 0.0) * 100.0, 2) as ka_rate_pct,
    round(cast(incomplete_records as double) / nullif(cast(row_count as double), 0.0) * 100.0, 2) as incomplete_project_rate_pct,
    -- KPI: Transformation Success Rate (% of records with all required fields populated)
    round(
        cast(row_count - incomplete_records as double) / nullif(cast(row_count as double), 0.0) * 100.0,
        2
    ) as transformation_success_rate
from unioned
