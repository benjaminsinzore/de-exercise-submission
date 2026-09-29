
    
    

select
    ims_client_id as unique_field,
    count(*) as n_records

from (select * from "ingestion"."main_intermediate"."int_client_identity_prepped" where source_system = 'ims') dbt_subquery
where ims_client_id is not null
group by ims_client_id
having count(*) > 1


