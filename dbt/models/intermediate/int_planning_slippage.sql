with snapshot_history as (
    select
        project_key,
        berlin_school_number,
        school_name,
        bezirk_clean,
        schulart_clean,
        baumassnahme,
        beschreibung,
        handover_period_raw,
        handover_year_start,
        handover_year_end,
        total_cost_eur,
        planned_capacity,
        track_structure,
        project_status,
        dbt_valid_from,
        dbt_valid_to,
        dbt_scd_id,
        row_number() over (partition by project_key order by dbt_valid_from desc) as version_rank_desc,
        lag(handover_year_start) over (partition by project_key order by dbt_valid_from) as prev_handover_year_start,
        lag(handover_year_end) over (partition by project_key order by dbt_valid_from) as prev_handover_year_end,
        lag(total_cost_eur) over (partition by project_key order by dbt_valid_from) as prev_total_cost_eur,
        lag(planned_capacity) over (partition by project_key order by dbt_valid_from) as prev_planned_capacity,
        lag(track_structure) over (partition by project_key order by dbt_valid_from) as prev_track_structure,
        lag(baumassnahme) over (partition by project_key order by dbt_valid_from) as prev_baumassnahme,
        lag(project_status) over (partition by project_key order by dbt_valid_from) as prev_project_status
    from {{ ref('snp_planning_history') }}
),

changes as (
    select
        project_key,
        berlin_school_number,
        school_name,
        bezirk_clean,
        schulart_clean,
        baumassnahme,
        beschreibung,
        dbt_scd_id,
        dbt_valid_from,
        dbt_valid_to,
        version_rank_desc,

        prev_handover_year_start,
        handover_year_start,
        handover_year_start - prev_handover_year_start as handover_year_start_delta,

        prev_handover_year_end,
        handover_year_end,
        handover_year_end - prev_handover_year_end as handover_year_end_delta,

        prev_total_cost_eur,
        total_cost_eur,
        total_cost_eur - prev_total_cost_eur as total_cost_delta_eur,

        prev_planned_capacity,
        planned_capacity,
        planned_capacity - prev_planned_capacity as planned_capacity_delta,

        prev_track_structure,
        track_structure,
        track_structure - prev_track_structure as track_structure_delta,

        prev_baumassnahme,

        prev_project_status,
        project_status,

        case when prev_handover_year_start is not null and handover_year_start > prev_handover_year_start then true else false end as handover_moved_later,
        case when prev_handover_year_start is not null and handover_year_start < prev_handover_year_start then true else false end as handover_moved_earlier,
        case when prev_total_cost_eur is not null and total_cost_eur > prev_total_cost_eur then true else false end as cost_increased,
        case when prev_total_cost_eur is not null and total_cost_eur < prev_total_cost_eur then true else false end as cost_decreased,
        case when prev_planned_capacity is not null and planned_capacity <> prev_planned_capacity then true else false end as capacity_changed,
        case when prev_track_structure is not null and track_structure <> prev_track_structure then true else false end as track_count_changed,
        case when prev_baumassnahme is not null and baumassnahme <> prev_baumassnahme then true else false end as project_scope_changed,
        case when prev_project_status is not null and project_status <> prev_project_status then true else false end as project_status_changed,

        case
            when prev_handover_year_start is null
                and prev_total_cost_eur is null
                and prev_planned_capacity is null
                and prev_track_structure is null
                and prev_project_status is null then false
            when (
                coalesce(handover_year_start, -9999) <> coalesce(prev_handover_year_start, -9999)
                or coalesce(handover_year_end, -9999) <> coalesce(prev_handover_year_end, -9999)
                or coalesce(total_cost_eur, -999999999) <> coalesce(prev_total_cost_eur, -999999999)
                or coalesce(planned_capacity, -999999999) <> coalesce(prev_planned_capacity, -999999999)
                or coalesce(track_structure, -999999999.0) <> coalesce(prev_track_structure, -999999999.0)
                or coalesce(baumassnahme, '___NULL___') <> coalesce(prev_baumassnahme, '___NULL___')
                or coalesce(project_status, '___NULL___') <> coalesce(prev_project_status, '___NULL___')
            ) then true
            else false
        end as has_planning_change
    from snapshot_history
)

select *
from changes
