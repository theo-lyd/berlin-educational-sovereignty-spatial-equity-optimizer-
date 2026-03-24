with slippage as (
    select
        project_key,
        handover_moved_later,
        handover_year_start_delta,
        cost_increased,
        total_cost_delta_eur,
        has_planning_change,
        version_rank_desc
    from {{ ref('kpi_planning_slippage') }}
),

risk as (
    select
        project_key,
        berlin_school_number,
        school_name,
        bezirk_clean,
        schulart_clean,
        baumassnahme,
        handover_year_start,
        handover_year_end,
        planned_capacity,
        total_cost_eur,
        is_temporary_site,
        project_risk_score,
        project_risk_bucket,
        project_risk_rank
    from {{ ref('kpi_project_risk_ranking') }}
)

select
    risk.project_key,
    risk.berlin_school_number,
    risk.school_name,
    risk.bezirk_clean,
    risk.schulart_clean,
    risk.baumassnahme,
    risk.handover_year_start,
    risk.handover_year_end,
    risk.planned_capacity,
    risk.total_cost_eur,
    risk.is_temporary_site,
    risk.project_risk_score,
    risk.project_risk_bucket,
    risk.project_risk_rank,
    coalesce(slippage.has_planning_change, false) as has_planning_change,
    coalesce(slippage.handover_moved_later, false) as handover_moved_later,
    slippage.handover_year_start_delta,
    coalesce(slippage.cost_increased, false) as cost_increased,
    slippage.total_cost_delta_eur,
    case
        when coalesce(slippage.handover_moved_later, false)
             or risk.handover_year_start >= extract(year from current_date) + 2
        then true
        else false
    end as delayed_handover_flag,
    case
        when (
            coalesce(slippage.handover_moved_later, false)
            or risk.handover_year_start >= extract(year from current_date) + 2
        )
         and coalesce(risk.total_cost_eur, 0) >= 15000000
        then true
        else false
    end as expensive_delayed_project_flag
from risk
left join slippage
    on risk.project_key = slippage.project_key
   and slippage.version_rank_desc = 1
