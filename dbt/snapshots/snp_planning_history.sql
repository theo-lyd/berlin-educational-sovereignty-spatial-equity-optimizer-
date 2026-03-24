{% snapshot snp_planning_history %}

{{
    config(
        target_schema='analytics_snapshots',
        unique_key='project_key',
        strategy='check',
        check_cols=[
            'handover_period_raw',
            'handover_year_start',
            'handover_year_end',
            'total_cost_eur',
            'planned_capacity',
            'track_structure',
            'baumassnahme',
            'project_status'
        ]
    )
}}

with src as (
    select
        md5(
            coalesce(trim(berlin_school_number), '') || '|' ||
            coalesce(trim(school_name), '') || '|' ||
            coalesce(trim(baumassnahme), '') || '|' ||
            coalesce(trim(beschreibung), '') || '|' ||
            coalesce(trim(adresse), '') || '|' ||
            coalesce(trim(plz), '') || '|' ||
            coalesce(trim(ort), '')
        ) as project_key,
        berlin_school_number,
        school_name,
        bezirk_clean,
        schulart_clean,
        baumassnahme,
        beschreibung,
        adresse,
        plz,
        ort,
        handover_period_raw,
        handover_year_start,
        handover_year_end,
        total_cost_eur,
        planned_capacity,
        track_structure,
        is_temporary_site,
        case
            when handover_year_start is null then 'status_unknown'
            when handover_year_start <= extract(year from current_date) then 'delivered_or_due_now'
            else 'planned'
        end as project_status
    from {{ ref('stg_school_construction_projects') }}
)

select *
from src

{% endsnapshot %}
