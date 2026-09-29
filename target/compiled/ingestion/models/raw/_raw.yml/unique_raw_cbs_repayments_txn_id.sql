
    
    

select
    txn_id as unique_field,
    count(*) as n_records

from "ingestion"."main_raw"."raw_cbs_repayments"
where txn_id is not null
group by txn_id
having count(*) > 1


