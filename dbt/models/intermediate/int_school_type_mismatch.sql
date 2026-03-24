with demand_by_school_type as (
    select
        schulart_clean,
        sum(students) as demand_students_total,
        count(*) as demand_records
    from {{ ref('stg_student_demand') }}
    where schulart_clean is not null
    group by 1
),

supply_by_school_type as (
    select
        schulart_clean,
        count(*) as supply_projects_total,
        sum(coalesce(planned_capacity, 0)) as planned_capacity_total,
        sum(case when not is_temporary_site then coalesce(planned_capacity, 0) else 0 end) as planned_capacity_permanent,
        sum(case when is_temporary_site then coalesce(planned_capacity, 0) else 0 end) as planned_capacity_temporary
    from {{ ref('stg_school_construction_projects') }}
    where schulart_clean is not null
    group by 1
)

select
    coalesce(d.schulart_clean, s.schulart_clean) as schulart_clean,
    coalesce(d.demand_students_total, 0) as demand_students_total,
    coalesce(d.demand_records, 0) as demand_records,
    coalesce(s.supply_projects_total, 0) as supply_projects_total,
    coalesce(s.planned_capacity_total, 0) as planned_capacity_total,
    coalesce(s.planned_capacity_permanent, 0) as planned_capacity_permanent,
    coalesce(s.planned_capacity_temporary, 0) as planned_capacity_temporary,
    coalesce(d.demand_students_total, 0) - coalesce(s.planned_capacity_total, 0) as demand_supply_gap_total,
    coalesce(d.demand_students_total, 0) - coalesce(s.planned_capacity_permanent, 0) as demand_supply_gap_permanent,
    case
        when coalesce(s.planned_capacity_total, 0) = 0 then null
        else round(cast(coalesce(d.demand_students_total, 0) as double) / cast(s.planned_capacity_total as double), 4)
    end as demand_pressure_ratio_total
from demand_by_school_type d
full outer join supply_by_school_type s
    on d.schulart_clean = s.schulart_clean
