
    
    

select
    borrower_id as unique_field,
    count(*) as n_records

from "ingestion"."main_raw"."raw_cbs_borrowers"
where borrower_id is not null
group by borrower_id
having count(*) > 1


