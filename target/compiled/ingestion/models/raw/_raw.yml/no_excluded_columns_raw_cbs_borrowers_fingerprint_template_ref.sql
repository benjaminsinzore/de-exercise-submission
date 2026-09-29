

WITH columns AS (
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'main_raw'
      AND table_name = 'raw_cbs_borrowers'
)
SELECT column_name
FROM columns
WHERE column_name IN (
    
    'fingerprint_template_ref'
    
)

