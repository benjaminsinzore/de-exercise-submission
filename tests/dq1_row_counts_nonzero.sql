select * from {{ ref('dq1_arrival_row_counts') }}
where row_count = 0