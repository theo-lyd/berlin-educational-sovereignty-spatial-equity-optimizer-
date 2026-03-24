{{ config(materialized='view') }}

with source as (
    select *
    from {{ source('raw_demand', 'raw__od_eckdaten_allg_2024__tabelle1') }}
)

select
    {{ null_if_unknown('"Traeger "') }} as traeger_raw,
    {{ null_if_unknown('"Traeger "') }} as traeger,
    {{ null_if_unknown('"Bezirk"') }} as bezirk_raw,
    {{ canonical_bezirk('"Bezirk"') }} as bezirk_clean,
    {{ null_if_unknown('"Schulart"') }} as schulart_raw,
    {{ canonical_schulart('"Schulart"') }} as schulart_clean,
    {{ is_special_needs('"Schulart"') }} as is_special_needs,
    false as is_temporary_site,
    cast("Schüler (w/m/d)" as integer) as students
from source