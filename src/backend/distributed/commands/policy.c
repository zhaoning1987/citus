/*-------------------------------------------------------------------------
 * policy.c
 *
 * This file contains functions to create, alter and drop policies on
 * distributed tables.
 *
 * Copyright (c) Citus Data, Inc.
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "catalog/namespace.h"
#include "commands/policy.h"
#include "distributed/commands.h"
#include "distributed/metadata_cache.h"
#include "utils/builtins.h"
#include "utils/elog.h"


/* placeholder for CreatePolicyCommands */
List *
CreatePolicyCommands(Oid relationId)
{
elog(INFO, "TTT src/backend/distributed/commands/policy.c:CreatePolicyCommands");
	/* placeholder for future implementation */
	return NIL;
}


/* placeholder for PreprocessCreatePolicyStmt */
List *
PreprocessCreatePolicyStmt(Node *node, const char *queryString,
						   ProcessUtilityContext processUtilityContext)
{
elog(INFO, "TTT src/backend/distributed/commands/policy.c:PreprocessCreatePolicyStmt");
	CreatePolicyStmt *stmt = castNode(CreatePolicyStmt, node);
	Oid relationId = RangeVarGetRelid(stmt->table,
									  AccessExclusiveLock,
									  false);
	if (IsCitusTable(relationId))
	{
		ereport(ERROR, (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
						errmsg("policies on distributed tables are only supported in "
							   "Citus Enterprise")));
	}

	/* placeholder for future implementation */
	return NIL;
}


/* placeholder for PreprocessAlterPolicyStmt */
List *
PreprocessAlterPolicyStmt(Node *node, const char *queryString,
						  ProcessUtilityContext processUtilityContext)
{
elog(INFO, "TTT src/backend/distributed/commands/policy.c:PreprocessAlterPolicyStmt");
	/* placeholder for future implementation */
	return NIL;
}


/* placeholder for ErrorIfUnsupportedPolicy */
void
ErrorIfUnsupportedPolicy(Relation relation)
{
elog(INFO, "TTT src/backend/distributed/commands/policy.c:ErrorIfUnsupportedPolicy");
	if (relation_has_policies(relation))
	{
		ereport(ERROR, (errcode(ERRCODE_FEATURE_NOT_SUPPORTED),
						errmsg("policies on distributed tables are only supported in "
							   "Citus Enterprise"),
						errhint("Remove any policies on a table before distributing")));
	}
}


/* placeholder for PreprocessDropPolicyStmt */
List *
PreprocessDropPolicyStmt(Node *node, const char *queryString,
						 ProcessUtilityContext processUtilityContext)
{
elog(INFO, "TTT src/backend/distributed/commands/policy.c:PreprocessDropPolicyStmt");
	/* placeholder for future implementation */
	return NIL;
}


/* placeholder for IsPolicyRenameStmt */
bool
IsPolicyRenameStmt(RenameStmt *stmt)
{
elog(INFO, "TTT src/backend/distributed/commands/policy.c:IsPolicyRenameStmt");
	/* placeholder for future implementation */
	return false;
}


/* placeholder for CreatePolicyEventExtendNames */
void
CreatePolicyEventExtendNames(CreatePolicyStmt *stmt, const char *schemaName, uint64
							 shardId)
{
	/* placeholder for future implementation */
}


/* placeholder for AlterPolicyEventExtendNames */
void
AlterPolicyEventExtendNames(AlterPolicyStmt *stmt, const char *schemaName, uint64 shardId)
{
elog(INFO, "TTT src/backend/distributed/commands/policy.c:AlterPolicyEventExtendNames");
	/* placeholder for future implementation */
}


/* placeholder for RenamePolicyEventExtendNames */
void
RenamePolicyEventExtendNames(RenameStmt *stmt, const char *schemaName, uint64 shardId)
{
	/* placeholder for future implementation */
}


/* placeholder for DropPolicyEventExtendNames */
void
DropPolicyEventExtendNames(DropStmt *dropStmt, const char *schemaName, uint64 shardId)
{
	/* placeholder for future implementation */
}
