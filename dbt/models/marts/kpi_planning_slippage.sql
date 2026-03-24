with detailed as (
    select
        project_key,
        berlin_school_number,
        school_name,
        bezirk_clean,
        schulart_clean,
        baumassnahme,
        beschreibung,
        dbt_valid_from,
        dbt_valid_to,
        version_rank_desc,
        handover_year_start,
        prev_handover_year_start,
        handover_year_start_delta,
        handover_year_end,
        prev_handover_year_end,
        handover_year_end_delta,
        total_cost_eur,
        prev_total_cost_eur,
        total_cost_delta_eur,
        planned_capacity,
        prev_planned_capacity,
        planned_capacity_delta,
        track_structure,
        prev_track_structure,
        track_structure_delta,
        prev_baumassnahme,
        project_status,
        prev_project_status,
        handover_moved_later,
        handover_moved_earlier,
        cost_increased,
        cost_decreased,
        capacity_changed,
        track_count_changed,
        project_scope_changed,
        project_status_changed,
        has_planning_change
    from {{ ref('int_planning_slippage') }}
)

select *
from detailed
