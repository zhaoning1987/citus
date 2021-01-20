-- regression tests regarding foreign key
-- drops cascading into undistributing Citus
-- local tables to Postgres local tables
CREATE SCHEMA drop_fkey_cascade;
SET search_path TO drop_fkey_cascade;
SET client_min_messages TO WARNING;
SET citus.next_shard_id TO 1810000;

SELECT 1 FROM master_add_node('localhost', :master_port, groupId => 0);

-- show that DROP CONSTRAINT cascades to undistributing citus_local_table
CREATE TABLE citus_local_table(l1 int);
SELECT create_citus_local_table('citus_local_table');
CREATE TABLE reference_table(r1 int primary key);
SELECT create_reference_table('reference_table');
ALTER TABLE citus_local_table ADD CONSTRAINT fkey_local_to_ref FOREIGN KEY(l1) REFERENCES reference_table(r1) ON DELETE CASCADE;

SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;

ALTER TABLE citus_local_table DROP CONSTRAINT fkey_local_to_ref;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;

DROP TABLE citus_local_table, reference_table;

-- show that DROP COLUMN cascades to undistributing citus_local_table
CREATE TABLE reference_table(r1 int primary key, r2 int);
SELECT create_reference_table('reference_table');

CREATE TABLE citus_local_table(l1 int REFERENCES reference_table(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;

ALTER TABLE reference_table DROP COLUMN r1 CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;
DROP TABLE citus_local_table, reference_table;

-- show that DROP COLUMN that cascades into drop foreign key undistributes local table
CREATE TABLE reference_table(r1 int primary key, r2 int);
SELECT create_reference_table('reference_table');

CREATE TABLE citus_local_table(l1 int REFERENCES reference_table(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;
ALTER TABLE citus_local_table DROP COLUMN l1 CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;


DROP TABLE citus_local_table, reference_table;

-- show that PRIMARY KEY that cascades into drop foreign key undistributes local table
CREATE TABLE reference_table(r1 int primary key, r2 int);
SELECT create_reference_table('reference_table');

CREATE TABLE citus_local_table(l1 int REFERENCES reference_table(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;
ALTER TABLE reference_table DROP CONSTRAINT reference_table_pkey CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;

-- show that DROP UNIQUE INDEX that cascades into drop foreign key undistributes local table
DROP TABLE citus_local_table, reference_table;

CREATE TABLE reference_table(r1 int, r2 int);
SELECT create_reference_table('reference_table');
CREATE UNIQUE INDEX ref_unique ON reference_table(r1);

CREATE TABLE citus_local_table(l1 int REFERENCES reference_table(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;
DROP INDEX ref_unique CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;

-- show that UNIQUE CONSTRAINT that cascades into drop foreign key undistributes local table
DROP TABLE citus_local_table, reference_table;

CREATE TABLE reference_table(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table');

CREATE TABLE citus_local_table(l1 int REFERENCES reference_table(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;
ALTER TABLE reference_table DROP CONSTRAINT reference_table_r1_key  CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;

-- show that DROP TABLE that cascades into drop foreign key undistributes local table
DROP TABLE citus_local_table, reference_table;

CREATE TABLE reference_table(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table');
CREATE TABLE citus_local_table(l1 int REFERENCES reference_table(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;
DROP TABLE reference_table CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass) ORDER BY logicalrelid;


-- show that UNIQUE CONSTRAINT that cascades into drop foreign key undistributes local table
DROP TABLE citus_local_table;

CREATE TABLE reference_table(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table');

CREATE TABLE citus_local_table(l1 int REFERENCES reference_table(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;
ALTER TABLE reference_table DROP CONSTRAINT reference_table_r1_key  CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table'::regclass) ORDER BY logicalrelid;


-- show that DROP SCHEMA that cascades into drop foreign key undistributes local table
DROP TABLE citus_local_table, reference_table;

CREATE SCHEMA ref_table_drop_schema;
CREATE TABLE ref_table_drop_schema.reference_table(r1 int UNIQUE, r2 int);
SELECT create_reference_table('ref_table_drop_schema.reference_table');
CREATE TABLE citus_local_table(l1 int REFERENCES ref_table_drop_schema.reference_table(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'ref_table_drop_schema.reference_table'::regclass) ORDER BY logicalrelid;
DROP SCHEMA ref_table_drop_schema CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass) ORDER BY logicalrelid;


-- drop column cascade that doesn't cascade into citus local table
DROP TABLE IF EXISTS citus_local_table, reference_table_1, reference_table_2;

CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');
CREATE TABLE reference_table_2(r1 int UNIQUE REFERENCES reference_table_1(r1), r2 int);
SELECT create_reference_table('reference_table_2');
CREATE TABLE citus_local_table(l1 int REFERENCES reference_table_2(r1), l2 int);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table_1'::regclass, 'reference_table_2'::regclass) ORDER BY logicalrelid;
ALTER TABLE reference_table_1 DROP COLUMN r1 CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table_1'::regclass, 'reference_table_2'::regclass) ORDER BY logicalrelid;


-- local table has multiple foreign keys to two tables
-- drop one at a time
DROP TABLE IF EXISTS citus_local_table, reference_table_1, reference_table_2;
CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');
CREATE TABLE reference_table_2(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_2');
CREATE TABLE citus_local_table(l1 int REFERENCES reference_table_1(r1), l2 int REFERENCES reference_table_2(r1));
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table_1'::regclass, 'reference_table_2'::regclass) ORDER BY logicalrelid;

DROP TABLE reference_table_1 CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table_2'::regclass) ORDER BY logicalrelid;
DROP TABLE reference_table_2 CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass) ORDER BY logicalrelid;

-- local table has multiple foreign keys to two tables
-- drop both at the same time
DROP TABLE IF EXISTS citus_local_table, reference_table_1, reference_table_2;
CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');
CREATE TABLE reference_table_2(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_2');
CREATE TABLE citus_local_table(l1 int REFERENCES reference_table_1(r1), l2 int REFERENCES reference_table_2(r1));
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table_1'::regclass, 'reference_table_2'::regclass) ORDER BY logicalrelid;
DROP TABLE reference_table_1, reference_table_2 CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass) ORDER BY logicalrelid;

-- local table has multiple foreign keys to two tables
-- drop one at a time
DROP TABLE IF EXISTS citus_local_table, reference_table_1, reference_table_2;
CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');
CREATE TABLE reference_table_2(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_2');
CREATE TABLE citus_local_table(l1 int REFERENCES reference_table_1(r1), l2 int REFERENCES reference_table_2(r1));
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table_1'::regclass, 'reference_table_2'::regclass) ORDER BY logicalrelid;
ALTER TABLE citus_local_table DROP CONSTRAINT citus_local_table_l1_fkey;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table_1'::regclass, 'reference_table_2'::regclass) ORDER BY logicalrelid;

-- this should undistribute
ALTER TABLE citus_local_table DROP CONSTRAINT citus_local_table_l2_fkey;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('citus_local_table'::regclass, 'reference_table_1'::regclass, 'reference_table_2'::regclass) ORDER BY logicalrelid;


-- a single drop column cascades into multiple undistributes
DROP TABLE IF EXISTS citus_local_table_1, citus_local_table_2, reference_table_1;

CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');

CREATE TABLE citus_local_table_1(l1 int REFERENCES reference_table_1(r1), l2 int UNIQUE);
CREATE TABLE citus_local_table_2(l1 int REFERENCES reference_table_1(r1), l2 int UNIQUE REFERENCES citus_local_table_1(l2));
CREATE TABLE citus_local_table_3(l1 int REFERENCES reference_table_1(r1), l2 int REFERENCES citus_local_table_2(l2));
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass, 'citus_local_table_2'::regclass, 'citus_local_table_3'::regclass) ORDER BY logicalrelid;
ALTER TABLE reference_table_1 DROP COLUMN r1 CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass, 'citus_local_table_2'::regclass, 'citus_local_table_3'::regclass) ORDER BY logicalrelid;

-- a single drop table cascades into multiple undistributes
DROP TABLE IF EXISTS citus_local_table_1, citus_local_table_2, citus_local_table_3, citus_local_table_2, reference_table_1;
CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');
CREATE TABLE citus_local_table_1(l1 int REFERENCES reference_table_1(r1), l2 int UNIQUE);
CREATE TABLE citus_local_table_2(l1 int REFERENCES reference_table_1(r1), l2 int UNIQUE REFERENCES citus_local_table_1(l2));
CREATE TABLE citus_local_table_3(l1 int REFERENCES reference_table_1(r1), l2 int REFERENCES citus_local_table_2(l2));
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass, 'citus_local_table_2'::regclass, 'citus_local_table_3'::regclass) ORDER BY logicalrelid;
DROP TABLE reference_table_1 CASCADE;
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ( 'citus_local_table_1'::regclass, 'citus_local_table_2'::regclass, 'citus_local_table_3'::regclass) ORDER BY logicalrelid;


-- dropping constraints inside a plpgsql procedure should be fine
DROP TABLE IF EXISTS citus_local_table_1, reference_table_1 CASCADE;
CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');
CREATE TABLE citus_local_table_1(l1 int REFERENCES reference_table_1(r1), l2 int UNIQUE);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass) ORDER BY logicalrelid;
create or replace procedure drop_constraint_via_proc()
language plpgsql
as $$
DECLARE
    res INT := 0;
begin
        ALTER TABLE citus_local_table_1 DROP CONSTRAINT citus_local_table_1_l1_fkey;
    commit;
end;$$;
call drop_constraint_via_proc();

SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass) ORDER BY logicalrelid;

-- even if the procedure is called from another procedure
DROP TABLE IF EXISTS citus_local_table_1, reference_table_1 CASCADE;
CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');
CREATE TABLE citus_local_table_1(l1 int REFERENCES reference_table_1(r1), l2 int UNIQUE);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass) ORDER BY logicalrelid;

create or replace procedure drop_constraint_via_proc_top_level()
language plpgsql
as $$
DECLARE
    res INT := 0;
begin
        CALL drop_constraint_via_proc();
    commit;
end;$$;

CALL drop_constraint_via_proc_top_level();
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass) ORDER BY logicalrelid;


-- even if the procedure is called from an exception handler
DROP TABLE IF EXISTS citus_local_table_1, reference_table_1 CASCADE;
CREATE TABLE reference_table_1(r1 int UNIQUE, r2 int);
SELECT create_reference_table('reference_table_1');
CREATE TABLE citus_local_table_1(l1 int REFERENCES reference_table_1(r1), l2 int UNIQUE);
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass) ORDER BY logicalrelid;

create or replace procedure drop_constraint_via_proc_exception()
language plpgsql
as $$
DECLARE
    res INT := 0;
begin
		PERFORM 1/0;
    	EXCEPTION
             when others then
        CALL drop_constraint_via_proc();
    commit;
end;$$;

CALL drop_constraint_via_proc_exception();
SELECT logicalrelid, partmethod, repmodel FROM pg_dist_partition WHERE logicalrelid IN ('reference_table_1'::regclass, 'citus_local_table_1'::regclass) ORDER BY logicalrelid;

DROP SCHEMA drop_fkey_cascade CASCADE;
