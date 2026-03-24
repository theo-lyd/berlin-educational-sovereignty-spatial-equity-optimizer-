with versioned as (
    select
        bezirk_clean,
        date_trunc('month', dbt_valid_from) as snapshot_month,
        count(*) as records_in_snapshot,
        sum(case when has_planning_change then 1 else 0 end) as changed_records,
        sum(case when handover_moved_later then 1 else 0 end) as delayed_records,
        sum(case when cost_increased then 1 else 0 end) as cost_increase_records,
        sum(case when capacity_changed then 1 else 0 end) as capacity_change_records,
        sum(case when project_scope_changed then 1 else 0 end) as scope_change_records
    from {{ ref('int_planning_slippage') }}
    group by 1, 2
)

select
    bezirk_clean,
    snapshot_month,
    records_in_snapshot,
    changed_records,
    delayed_records,
    cost_increase_records,
    capacity_change_records,
    scope_change_records,
    round(cast(changed_records as double) / nullif(cast(records_in_snapshot as double), 0.0), 4) as change_rate,
    round(cast(delayed_records as double) / nullif(cast(records_in_snapshot as double), 0.0), 4) as delay_rate
from versioned
