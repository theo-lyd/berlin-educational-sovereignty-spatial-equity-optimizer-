with demand as (
    select
        bezirk_clean,
        schulart_clean,
        sum(students) as demand_students
    from {{ ref('stg_student_demand') }}
    where bezirk_clean is not null
      and schulart_clean is not null
    group by 1, 2
),

supply as (
    select
        bezirk_clean,
        schulart_clean,
        sum(coalesce(planned_capacity, 0)) as planned_capacity_total,
        sum(case when not is_temporary_site then coalesce(planned_capacity, 0) else 0 end) as planned_capacity_permanent,
        sum(case when is_temporary_site then coalesce(planned_capacity, 0) else 0 end) as planned_capacity_temporary
    from {{ ref('stg_school_construction_projects') }}
    where bezirk_clean is not null
      and schulart_clean is not null
    group by 1, 2
),

combined as (
    select
        coalesce(d.bezirk_clean, s.bezirk_clean) as bezirk_clean,
        coalesce(d.schulart_clean, s.schulart_clean) as schulart_clean,
        coalesce(d.demand_students, 0) as demand_students,
        coalesce(s.planned_capacity_total, 0) as planned_capacity_total,
        coalesce(s.planned_capacity_permanent, 0) as planned_capacity_permanent,
        coalesce(s.planned_capacity_temporary, 0) as planned_capacity_temporary,
        coalesce(d.demand_students, 0) - coalesce(s.planned_capacity_total, 0) as gap_total,
        case
            when coalesce(s.planned_capacity_total, 0) = 0 then null
            else round(cast(coalesce(d.demand_students, 0) as double) / cast(s.planned_capacity_total as double), 4)
        end as demand_pressure_ratio
    from demand d
    full outer join supply s
        on d.bezirk_clean = s.bezirk_clean
       and d.schulart_clean = s.schulart_clean
),

ranked as (
    select
        *,
        sum(gap_total) over (partition by bezirk_clean) as district_gap_total,
        sum(demand_students) over (partition by bezirk_clean) as district_demand_total,
        sum(planned_capacity_total) over (partition by bezirk_clean) as district_capacity_total
    from combined
),

with_city_totals as (
    select
        *,
        sum(district_demand_total) over () as city_total_demand,
        dense_rank() over (order by district_gap_total desc, district_demand_total desc) as district_rank_by_gap
    from ranked
),

with_kpis as (
    select
        *,
        -- KPI: District Demand Share (% of Berlin-wide demand in this district)
        case
            when city_total_demand > 0 then round(cast(district_demand_total as double) / cast(city_total_demand as double) * 100.0, 2)
            else null
        end as demand_share_pct,
        -- KPI: Spatial Relief Score (% of this district's gap that capacity covers, capped at 100%)
        case
            when district_gap_total <= 0 then 100.0
            when district_gap_total > 0 then round(
                case
                    when cast(district_capacity_total as double) / cast(district_gap_total as double) * 100.0 > 100.0 then 100.0
                    else cast(district_capacity_total as double) / cast(district_gap_total as double) * 100.0
                end,
                2
            )
            else null
        end as spatial_relief_score
    from with_city_totals
)

select
    bezirk_clean,
    schulart_clean,
    demand_students,
    planned_capacity_total,
    planned_capacity_permanent,
    planned_capacity_temporary,
    gap_total,
    demand_pressure_ratio,
    district_gap_total,
    district_demand_total,
    district_capacity_total,
    district_rank_by_gap,
    demand_share_pct,
    spatial_relief_score
from with_kpis
