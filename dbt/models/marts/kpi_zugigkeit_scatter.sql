with demand as (
    select
        bezirk_clean,
        schulart_clean,
        sum(students) as student_volume
    from {{ ref('stg_student_demand') }}
    where bezirk_clean is not null
      and schulart_clean is not null
    group by 1, 2
),

construction as (
    select
        bezirk_clean,
        schulart_clean,
        sum(coalesce(track_structure, 0.0)) as planned_track_count,
        avg(track_structure) as avg_track_count,
        sum(coalesce(planned_capacity, 0)) as planned_capacity_total,
        count(*) as project_count
    from {{ ref('stg_school_construction_projects') }}
    where bezirk_clean is not null
      and schulart_clean is not null
    group by 1, 2
)

select
    coalesce(demand.bezirk_clean, construction.bezirk_clean) as bezirk_clean,
    coalesce(demand.schulart_clean, construction.schulart_clean) as schulart_clean,
    coalesce(demand.student_volume, 0) as student_volume,
    coalesce(construction.planned_track_count, 0.0) as planned_track_count,
    construction.avg_track_count,
    coalesce(construction.planned_capacity_total, 0) as planned_capacity_total,
    coalesce(construction.project_count, 0) as project_count,
    case
        when coalesce(demand.student_volume, 0) = 0 then null
        else round(cast(coalesce(construction.planned_track_count, 0.0) as double) / cast(demand.student_volume as double), 6)
    end as track_per_student_ratio
from demand
full outer join construction
    on demand.bezirk_clean = construction.bezirk_clean
   and demand.schulart_clean = construction.schulart_clean
