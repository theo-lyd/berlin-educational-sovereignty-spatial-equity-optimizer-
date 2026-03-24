{% macro null_if_unknown(expr) %}
    case
        when {{ expr }} is null then null
        when trim(cast({{ expr }} as varchar)) = '' then null
        when lower(trim(cast({{ expr }} as varchar))) in ('k. a.', 'k.a.', 'k a', 'k.a', 'k a.') then null
        else trim(cast({{ expr }} as varchar))
    end
{% endmacro %}


{% macro parse_numeric_text(expr) %}
    cast(
        nullif(
            regexp_extract(
                regexp_replace(
                    regexp_replace({{ null_if_unknown(expr) }}, '\\.', ''),
                    ',',
                    '.'
                ),
                '(-?[0-9]+(?:\\.[0-9]+)?)',
                1
            ),
            ''
        ) as double
    )
{% endmacro %}


{% macro parse_eur_amount(expr) %}
    case
        when {{ null_if_unknown(expr) }} is null then null
        when lower({{ null_if_unknown(expr) }}) = '0' then 0
        when lower({{ null_if_unknown(expr) }}) like '%mio%' then cast(round({{ parse_numeric_text(expr) }} * 1000000) as bigint)
        when lower({{ null_if_unknown(expr) }}) like '%tsd%' then cast(round({{ parse_numeric_text(expr) }} * 1000) as bigint)
        else cast(round({{ parse_numeric_text(expr) }}) as bigint)
    end
{% endmacro %}


{% macro parse_year_start(expr) %}
    cast(nullif(regexp_extract({{ null_if_unknown(expr) }}, '(19|20)[0-9]{2}', 0), '') as integer)
{% endmacro %}


{% macro parse_year_end(expr) %}
    cast(
        nullif(
            coalesce(
                regexp_extract({{ null_if_unknown(expr) }}, '(?:/|-)((?:19|20)[0-9]{2})', 1),
                regexp_extract({{ null_if_unknown(expr) }}, '(19|20)[0-9]{2}', 0)
            ),
            ''
        ) as integer
    )
{% endmacro %}


{% macro canonical_bezirk(expr) %}
    case
        when {{ null_if_unknown(expr) }} is null then null
        when lower({{ null_if_unknown(expr) }}) = 'charlottenburg-wilmersdorf' then 'Charlottenburg-Wilmersdorf'
        when lower({{ null_if_unknown(expr) }}) = 'friedrichshain-kreuzberg' then 'Friedrichshain-Kreuzberg'
        when lower({{ null_if_unknown(expr) }}) = 'lichtenberg' then 'Lichtenberg'
        when lower({{ null_if_unknown(expr) }}) = 'marzahn-hellersdorf' then 'Marzahn-Hellersdorf'
        when lower({{ null_if_unknown(expr) }}) = 'mitte' then 'Mitte'
        when lower({{ null_if_unknown(expr) }}) = 'neukölln' then 'Neukölln'
        when lower({{ null_if_unknown(expr) }}) = 'pankow' then 'Pankow'
        when lower({{ null_if_unknown(expr) }}) = 'reinickendorf' then 'Reinickendorf'
        when lower({{ null_if_unknown(expr) }}) = 'spandau' then 'Spandau'
        when lower({{ null_if_unknown(expr) }}) = 'steglitz-zehlendorf' then 'Steglitz-Zehlendorf'
        when lower({{ null_if_unknown(expr) }}) = 'tempelhof-schöneberg' then 'Tempelhof-Schöneberg'
        when lower({{ null_if_unknown(expr) }}) = 'treptow-köpenick' then 'Treptow-Köpenick'
        else null
    end
{% endmacro %}


{% macro canonical_schulart(expr) %}
    case
        when {{ null_if_unknown(expr) }} is null then null
        when lower({{ null_if_unknown(expr) }}) like '%grundschule%' then 'Grundschule'
        when lower({{ null_if_unknown(expr) }}) like '%gymnasium%' then 'Gymnasium'
        when lower({{ null_if_unknown(expr) }}) like '%integrierte sekundarschule%' then 'Integrierte Sekundarschule'
        when lower({{ null_if_unknown(expr) }}) like '%gemeinschaftsschule%' then 'Gemeinschaftsschule'
        when lower({{ null_if_unknown(expr) }}) like '%osz%' then 'OSZ'
        when lower({{ null_if_unknown(expr) }}) like '%sonderpädagog%' then 'Schule mit sonderpädagogischem Förderschwerpunkt'
        when lower({{ null_if_unknown(expr) }}) like '%drehscheibe%' then null
        when lower({{ null_if_unknown(expr) }}) like '%waldorf%' then 'Freie Waldorfschule'
        else null
    end
{% endmacro %}


{% macro is_special_needs(expr) %}
    case
        when {{ null_if_unknown(expr) }} is null then false
        when lower({{ null_if_unknown(expr) }}) like '%sonderpädagog%' then true
        else false
    end
{% endmacro %}


{% macro is_temporary_site(schulart_expr, measure_expr, description_expr) %}
    case
        when lower(coalesce({{ null_if_unknown(schulart_expr) }}, '')) like '%drehscheibe%' then true
        when lower(coalesce({{ null_if_unknown(measure_expr) }}, '')) like '%tempor%' then true
        when lower(coalesce({{ null_if_unknown(description_expr) }}, '')) like '%drehscheibe%' then true
        else false
    end
{% endmacro %}