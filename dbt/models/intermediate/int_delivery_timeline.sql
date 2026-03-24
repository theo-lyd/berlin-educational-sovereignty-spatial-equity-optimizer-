with projects as (
    select
        handover_period_raw,
        handover_year_start,
        handover_year_end,
        coalesce(planned_capacity, 0) as planned_capacity,
        is_temporary_site,
        total_cost_eur
    from {{ ref('stg_school_construction_projects') }}
),

timeline as (
    select
        handover_year_start as delivery_year,
        min(handover_year_start) as handover_year_start,
        max(handover_year_end) as handover_year_end,
        count(*) as project_count,
        sum(planned_capacity) as planned_capacity_total,
        sum(case when not is_temporary_site then planned_capacity else 0 end) as planned_capacity_permanent,
        sum(case when is_temporary_site then planned_capacity else 0 end) as planned_capacity_temporary,
        sum(case when total_cost_eur is null then 1 else 0 end) as projects_missing_cost,
        sum(case when handover_period_raw is null then 1 else 0 end) as projects_missing_handover_period
    from projects
    where handover_year_start is not null
    group by 1
)

select
    delivery_year,
    handover_year_start,
    handover_year_end,
    project_count,
    planned_capacity_total,
    planned_capacity_permanent,
    planned_capacity_temporary,
    projects_missing_cost,
    projects_missing_handover_period,
    sum(planned_capacity_total) over (order by delivery_year rows between unbounded preceding and current row) as cumulative_capacity_total,
    sum(planned_capacity_permanent) over (order by delivery_year rows between unbounded preceding and current row) as cumulative_capacity_permanent
from timeline
order by delivery_year
