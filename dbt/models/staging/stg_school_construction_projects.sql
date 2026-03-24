{{ config(materialized='view') }}

with source as (
    select *
    from {{ source('raw_construction', 'raw__schulbaukarte_2025__tabelle1') }}
)

select
    trim("Berliner Schulnummer") as berlin_school_number,
    trim("Schulname") as school_name,
    {{ null_if_unknown('"Bezirk"') }} as bezirk_raw,
    {{ canonical_bezirk('"Bezirk"') }} as bezirk_clean,
    {{ null_if_unknown('"Schulart"') }} as schulart_raw,
    {{ canonical_schulart('"Schulart"') }} as schulart_clean,
    {{ is_special_needs('"Schulart"') }} as is_special_needs,
    trim("Baumaßnahme") as baumassnahme,
    trim("Beschreibung") as beschreibung,
    {{ is_temporary_site('"Schulart"', '"Baumaßnahme"', '"Beschreibung"') }} as is_temporary_site,
    {{ null_if_unknown('"Gebaute bzw. geplante Schulplätze"') }} as planned_capacity_raw,
    cast(round({{ parse_numeric_text('"Gebaute bzw. geplante Schulplätze"') }}) as integer) as planned_capacity,
    nullif(trim(cast("Gebaute bzw. geplante Schulplätze" as varchar)), '') as built_or_planned_places_raw,
    nullif(trim(cast("Kapazität nach Baumaßnahme" as varchar)), '') as capacity_after_measure_raw,
    cast(round({{ parse_numeric_text('"Kapazität nach Baumaßnahme"') }}) as integer) as capacity_after_measure,
    nullif(trim(cast("Zügigkeit nach Baumaßnahme" as varchar)), '') as track_structure_raw,
    {{ parse_numeric_text('"Zügigkeit nach Baumaßnahme"') }} as track_structure,
    nullif(trim(cast("Nutzungsübergabe" as varchar)), '') as handover_period_raw,
    {{ parse_year_start('"Nutzungsübergabe"') }} as handover_year_start,
    {{ parse_year_end('"Nutzungsübergabe"') }} as handover_year_end,
    nullif(trim(cast("Gesamtkosten in Euro" as varchar)), '') as total_cost_raw,
    {{ parse_eur_amount('"Gesamtkosten in Euro"') }} as total_cost_eur,
    trim("Adresse") as adresse,
    cast("PLZ" as varchar) as plz,
    trim("Ort") as ort
from source