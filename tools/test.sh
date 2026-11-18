#!/usr/bin/env bash
# Builds the project and runs the public tests. Usage: bash tools/test.sh [s1|all]
set -uo pipefail
cd "$(dirname "$0")/.."
[ -f .env ] || { echo "Run bash tools/setup_mac.sh first."; exit 1; }
source .env
export ODBCSYSINI=/opt/homebrew/etc
export DYLD_LIBRARY_PATH=/opt/homebrew/opt/openssl@3/lib
docker start tayar-sql >/dev/null 2>&1
.venv/bin/python tools/build.py || exit 1
rm -f build/Team_105_results.txt
.venv/bin/python tests/grader.py build/Team_105.sql --server "$DB_SERVER" --user "$DB_USER" --password "$DB_PASSWORD" > build/grader_output.txt 2>&1
.venv/bin/python tools/summary.py "${1:-s1}"
