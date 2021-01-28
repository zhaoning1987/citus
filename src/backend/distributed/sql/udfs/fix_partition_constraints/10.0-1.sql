CREATE FUNCTION pg_catalog.fix_partition_constraints(table_name regclass)
  RETURNS void
  LANGUAGE C STRICT
  AS 'MODULE_PATHNAME', $$fix_partition_constraints$$;
COMMENT ON FUNCTION pg_catalog.fix_partition_constraints(table_name regclass)
  IS 'fix constraint names on partition shards';

CREATE OR REPLACE FUNCTION pg_catalog.fix_partition_constraints()
  RETURNS SETOF regclass
  LANGUAGE plpgsql
  AS $$
DECLARE
	oid regclass;
BEGIN
    FOR oid IN SELECT c.oid
            FROM pg_dist_partition p
            JOIN pg_class c ON p.logicalrelid = c.oid
			JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE c.relkind = 'p'
		ORDER BY n.nspname, c.relname
    LOOP
        EXECUTE 'SELECT fix_partition_constraints( ' || quote_literal(oid) || ' )';
        RETURN NEXT oid;
    END LOOP;
    RETURN;
END;
$$;
COMMENT ON FUNCTION pg_catalog.fix_partition_constraints()
  IS 'fix constraint names on all partition shards';
