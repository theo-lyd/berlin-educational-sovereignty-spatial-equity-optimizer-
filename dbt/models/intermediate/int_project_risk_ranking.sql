with district_pressure as (
    select
        bezirk_clean,
        demand_pressure_ratio_total
    from {{ ref('int_district_aggregation') }}
),

projects as (
    select
        berlin_school_number,
        school_name,
        bezirk_clean,
        schulart_clean,
        baumassnahme,
        is_temporary_site,
        planned_capacity,
        total_cost_eur,
        handover_year_start,
        handover_year_end,
        coalesce(trim(berlin_school_number), '') || '|' || coalesce(trim(school_name), '') || '|' || coalesce(trim(baumassnahme), '') as project_key
    from {{ ref('stg_school_construction_projects') }}
),

scored as (
    select
        p.*,
        d.demand_pressure_ratio_total,

        case
            when p.handover_year_start is null then 4
            when p.handover_year_start <= extract(year from current_date) then 0
            when p.handover_year_start = extract(year from current_date) + 1 then 1
            when p.handover_year_start = extract(year from current_date) + 2 then 2
            when p.handover_year_start = extract(year from current_date) + 3 then 3
            else 4
        end as score_handover_delay,

        case
            when p.total_cost_eur is null then 2
            when p.total_cost_eur < 5000000 then 1
            when p.total_cost_eur < 15000000 then 2
            when p.total_cost_eur < 30000000 then 3
            else 4
        end as score_project_cost,

        case
            when p.is_temporary_site then 3
            else 0
        end as score_interim_dependency,

        (
            case when p.bezirk_clean is null then 1 else 0 end +
            case when p.schulart_clean is null then 1 else 0 end +
            case when p.planned_capacity is null then 1 else 0 end +
            case when p.total_cost_eur is null then 1 else 0 end +
            case when p.handover_year_start is null then 1 else 0 end
        ) as score_missing_data,

        case
            when d.demand_pressure_ratio_total is null then 1
            when d.demand_pressure_ratio_total >= 2.0 then 4
            when d.demand_pressure_ratio_total >= 1.2 then 3
            when d.demand_pressure_ratio_total >= 0.8 then 2
            else 1
        end as score_demand_pressure
    from projects p
    left join district_pressure d
        on p.bezirk_clean = d.bezirk_clean
)

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
    demand_pressure_ratio_total,
    score_handover_delay,
    score_project_cost,
    score_interim_dependency,
    score_missing_data,
    score_demand_pressure,
    round(
        cast(
            score_handover_delay + score_project_cost + score_interim_dependency + score_missing_data + score_demand_pressure
            as double
        ) / 20.0 * 100.0,
        2
    ) as project_risk_score,
    case
        when (score_handover_delay + score_project_cost + score_interim_dependency + score_missing_data + score_demand_pressure) >= 14 then 'high'
        when (score_handover_delay + score_project_cost + score_interim_dependency + score_missing_data + score_demand_pressure) >= 8 then 'medium'
        else 'low'
    end as project_risk_bucket,
    dense_rank() over (
        order by
            (score_handover_delay + score_project_cost + score_interim_dependency + score_missing_data + score_demand_pressure) desc,
            coalesce(total_cost_eur, 0) desc,
            coalesce(planned_capacity, 0) desc
    ) as project_risk_rank
from scored
