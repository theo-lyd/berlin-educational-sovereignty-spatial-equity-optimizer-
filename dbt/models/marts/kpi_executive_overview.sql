with district as (
    select *
    from {{ ref('kpi_district_summary') }}
),

risk as (
    select
        bezirk_clean,
        count(*) as project_count,
        sum(case when project_risk_bucket = 'high' then 1 else 0 end) as high_risk_project_count,
        avg(project_risk_score) as avg_project_risk_score
    from {{ ref('kpi_project_risk_ranking') }}
    group by 1
),

data_trust as (
    select data_trust_score
    from {{ ref('kpi_data_trust_score') }}
    where model_name = 'overall'
)

select
    sum(demand_students_total) as total_student_demand,
    sum(planned_capacity_total) as total_planned_capacity,
    sum(demand_supply_gap_total) as total_gap,
    count(*) filter (where demand_supply_gap_total > 0) as districts_with_positive_gap,
    count(*) filter (where coalesce(high_risk_project_count, 0) > 0) as high_risk_district_count,
    round(avg(coalesce(avg_project_risk_score, 0.0)), 2) as avg_project_risk_score,
    max(data_trust.data_trust_score) as overall_data_trust_score
from district
left join risk
    on district.bezirk_clean = risk.bezirk_clean
cross join data_trust
