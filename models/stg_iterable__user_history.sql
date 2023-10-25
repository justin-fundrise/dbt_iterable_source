
with base as (

    select * 
    from {{ ref('stg_iterable__user_history_tmp') }}

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_iterable_source/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_iterable_source/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_iterable__user_history_tmp')),
                staging_columns=get_user_history_columns()
            )
        }}
        
    from base
),

final as (
    
    select 
        _fivetran_id as _fivetran_user_id,
        updated_at,
        lower(email) as email,
        user_id,
        first_name,
        last_name,
        email_list_ids,
        phone_number,
        signup_date,
        signup_source,
        iterable_user_id,
        _fivetran_synced

        {{ fivetran_utils.fill_pass_through_columns('iterable_user_pass_through_columns') }}

    from fields
)

select * 
from final