CREATE FUNCTION pg_catalog.worker_fix_partition_constraints(table_name regclass,
															shardid integer,
															constraint_name text)
  RETURNS void
  LANGUAGE C STRICT
  AS 'MODULE_PATHNAME', $$worker_fix_partition_constraints$$;
COMMENT ON FUNCTION pg_catalog.worker_fix_partition_constraints(table_name regclass,
																shardid integer,
																constraint_name text)
  IS 'fix constraint names on partition shards on worker nodes';
