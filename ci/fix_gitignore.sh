#! /bin/bash
# shellcheck disable=SC2012

set -euo pipefail
# shellcheck disable=SC1091
source ci/ci_helpers.sh

ls -1 src/test/regress/input | sed -E "s/(.*)\.source/\/\1.sql/" > src/test/regress/sql/.gitignore
ls -1 src/test/regress/output | sed -E "s/(.*)\.source/\/\1.out/" > src/test/regress/expected/.gitignore
