with demand_by_district as (
    select
        bezirk_clean,
        sum(students) as demand_students_total,
        count(*) as demand_records
    from {{ ref('stg_student_demand') }}
    where bezirk_clean is not null
    group by 1
),

supply_by_district as (
    select
        bezirk_clean,
        count(*) as supply_projects_total,
        sum(coalesce(planned_capacity, 0)) as planned_capacity_total,
        sum(case when is_temporary_site then coalesce(planned_capacity, 0) else 0 end) as planned_capacity_temporary,
        sum(case when not is_temporary_site then coalesce(planned_capacity, 0) else 0 end) as planned_capacity_permanent,
        sum(case when planned_capacity is null then 1 else 0 end) as projects_missing_capacity,
        sum(case when handover_year_start is null then 1 else 0 end) as projects_missing_handover
    from {{ ref('stg_school_construction_projects') }}
    where bezirk_clean is not null
    group by 1
)

select
    coalesce(d.bezirk_clean, s.bezirk_clean) as bezirk_clean,
    coalesce(d.demand_students_total, 0) as demand_students_total,
    coalesce(d.demand_records, 0) as demand_records,
    coalesce(s.supply_projects_total, 0) as supply_projects_total,
    coalesce(s.planned_capacity_total, 0) as planned_capacity_total,
    coalesce(s.planned_capacity_permanent, 0) as planned_capacity_permanent,
    coalesce(s.planned_capacity_temporary, 0) as planned_capacity_temporary,
    coalesce(s.projects_missing_capacity, 0) as projects_missing_capacity,
    coalesce(s.projects_missing_handover, 0) as projects_missing_handover,
    coalesce(d.demand_students_total, 0) - coalesce(s.planned_capacity_total, 0) as demand_supply_gap_total,
    coalesce(d.demand_students_total, 0) - coalesce(s.planned_capacity_permanent, 0) as demand_supply_gap_permanent,
    case
        when coalesce(s.planned_capacity_total, 0) = 0 then null
        else round(cast(coalesce(d.demand_students_total, 0) as double) / cast(s.planned_capacity_total as double), 4)
    end as demand_pressure_ratio_total
from demand_by_district d
full outer join supply_by_district s
    on d.bezirk_clean = s.bezirk_clean
