with demand_special_needs as (
    select
        bezirk_clean,
        sum(students) as special_needs_demand_students,
        count(*) as special_needs_demand_records
    from {{ ref('stg_student_demand') }}
    where is_special_needs
      and bezirk_clean is not null
    group by 1
),

supply_special_needs as (
    select
        bezirk_clean,
        sum(coalesce(planned_capacity, 0)) as special_needs_planned_capacity,
        sum(case when not is_temporary_site then coalesce(planned_capacity, 0) else 0 end) as special_needs_planned_capacity_permanent,
        count(*) as special_needs_supply_projects
    from {{ ref('stg_school_construction_projects') }}
    where is_special_needs
      and bezirk_clean is not null
    group by 1
)

select
    coalesce(d.bezirk_clean, s.bezirk_clean) as bezirk_clean,
    coalesce(d.special_needs_demand_students, 0) as special_needs_demand_students,
    coalesce(d.special_needs_demand_records, 0) as special_needs_demand_records,
    coalesce(s.special_needs_supply_projects, 0) as special_needs_supply_projects,
    coalesce(s.special_needs_planned_capacity, 0) as special_needs_planned_capacity,
    coalesce(s.special_needs_planned_capacity_permanent, 0) as special_needs_planned_capacity_permanent,
    coalesce(d.special_needs_demand_students, 0) - coalesce(s.special_needs_planned_capacity, 0) as special_needs_gap_total,
    coalesce(d.special_needs_demand_students, 0) - coalesce(s.special_needs_planned_capacity_permanent, 0) as special_needs_gap_permanent,
    case
        when coalesce(d.special_needs_demand_students, 0) = 0 then null
        else round(cast(coalesce(s.special_needs_planned_capacity, 0) as double) / cast(d.special_needs_demand_students as double), 4)
    end as special_needs_coverage_ratio
from demand_special_needs d
full outer join supply_special_needs s
    on d.bezirk_clean = s.bezirk_clean
order by bezirk_clean
