
    
    

select
    loan_id as unique_field,
    count(*) as n_records

from "ingestion"."main_marts"."fct_loan"
where loan_id is not null
group by loan_id
having count(*) > 1


