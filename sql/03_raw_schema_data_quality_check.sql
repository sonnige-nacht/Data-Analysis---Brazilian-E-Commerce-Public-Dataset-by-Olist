-- 0. Overview on all tables from raw Schema
SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'raw'
ORDER BY table_name, ordinal_position;


-- 1. DATA QUALITY CHECK: NULL & EMPTY VALUES

DROP TABLE IF EXISTS dq_null_empty_results;

CREATE TEMP TABLE dq_null_empty_results (
    table_name TEXT,
    column_name TEXT,
    null_count BIGINT,
    empty_count BIGINT
);

DO $$
DECLARE
    col RECORD;
    empty_expression TEXT;
    query_text TEXT;
BEGIN

    FOR col IN
        SELECT
            table_name,
            column_name,
            data_type
        FROM information_schema.columns
        WHERE table_schema = 'raw'
        ORDER BY table_name, ordinal_position

    LOOP

        -- Empty check only for text columns
        IF col.data_type IN ('character varying', 'character', 'text') THEN

            empty_expression := format(
                'COUNT(*) FILTER (WHERE BTRIM(%I) = '''')',
                col.column_name
            );

        ELSE

            empty_expression := '0::BIGINT';

        END IF;

        -- Build dynamic SQL
        query_text := format(
            'INSERT INTO dq_null_empty_results
             SELECT
                %L,
                %L,
                COUNT(*) FILTER (WHERE %I IS NULL),
                %s
             FROM %I.%I',

            col.table_name,
            col.column_name,
            col.column_name,
            empty_expression,
            'raw',
            col.table_name
        );

        EXECUTE query_text;

    END LOOP;

END $$;

-- Display results
SELECT
    table_name,
    column_name,
    null_count,
    empty_count
FROM dq_null_empty_results
ORDER BY table_name, column_name;


-- 2. DATA QUALITY CHECK: DUPLICATE ROWS
DROP TABLE IF EXISTS dq_duplicate_results;

CREATE TEMP TABLE dq_duplicate_results (
    table_name TEXT,
    row_data JSONB,
    duplicate_count BIGINT
);

DO $$
DECLARE
    tbl RECORD;
    query_text TEXT;

BEGIN

    FOR tbl IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'raw'
          AND table_type = 'BASE TABLE'
        ORDER BY table_name

    LOOP

        query_text := format(
            'INSERT INTO dq_duplicate_results
             SELECT
                %L,
                TO_JSONB(t),
                COUNT(*)
             FROM %I.%I t
             GROUP BY TO_JSONB(t)
             HAVING COUNT(*) > 1',

            tbl.table_name,
            'raw',
            tbl.table_name
        );

        EXECUTE query_text;

    END LOOP;

END $$;

-- Display duplicate records
SELECT
    table_name,
    row_data,
    duplicate_count
FROM dq_duplicate_results
ORDER BY table_name, duplicate_count DESC;