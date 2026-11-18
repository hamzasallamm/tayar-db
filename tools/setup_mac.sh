#!/usr/bin/env bash
# One-time setup for this Mac. Safe to run again.
set -euo pipefail
cd "$(dirname "$0")/.."
PORT=14330
CONTAINER=tayar-sql

echo "==> Starting Docker"
open -a Docker
for _ in $(seq 1 60); do docker info >/dev/null 2>&1 && break; sleep 2; done
docker info >/dev/null 2>&1 || { echo "Docker did not start. Open Docker Desktop, then run this again."; exit 1; }

echo "==> Saving the local database login"
if [ ! -f .env ]; then
  PASSWORD="Tayar-$(openssl rand -hex 6)-Aa1"
  printf 'DB_SERVER="localhost,%s"\nDB_USER="sa"\nDB_PASSWORD="%s"\n' "$PORT" "$PASSWORD" > .env
  chmod 600 .env
fi
source .env

echo "==> Starting SQL Server 2022 (the first run downloads about 1.5 GB)"
if ! docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  docker run -d --name "$CONTAINER" --platform linux/amd64 --restart unless-stopped \
    -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD="$DB_PASSWORD" -p "$PORT:1433" \
    mcr.microsoft.com/mssql/server:2022-latest >/dev/null
else
  docker start "$CONTAINER" >/dev/null
fi

echo "==> Installing the SQL Server ODBC driver"
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_ACCEPT_EULA=Y
brew tap microsoft/mssql-release https://github.com/Microsoft/homebrew-mssql-release >/dev/null
brew trust --formula microsoft/mssql-release/msodbcsql18
brew list unixodbc >/dev/null 2>&1 || brew install unixodbc < <(yes y)
brew list msodbcsql18 >/dev/null 2>&1 || brew install microsoft/mssql-release/msodbcsql18 < <(yes y)

echo "==> Installing pyodbc"
export ODBCSYSINI=/opt/homebrew/etc
# The SQL Server driver needs OpenSSL 3; this Mac also has OpenSSL 4 as its default.
export DYLD_LIBRARY_PATH=/opt/homebrew/opt/openssl@3/lib
[ -d .venv ] || python3 -m venv .venv
.venv/bin/pip install --quiet --upgrade pip pyodbc
if ! .venv/bin/python -c "import pyodbc,sys; sys.exit(0 if any('18' in d for d in pyodbc.drivers()) else 1)"; then
  LDFLAGS="-L/opt/homebrew/lib" CPPFLAGS="-I/opt/homebrew/include" \
    .venv/bin/pip install --quiet --force-reinstall --no-binary pyodbc pyodbc
fi

echo "==> Waiting for SQL Server"
.venv/bin/python - <<'EOF'
import os, re, sys, time, pyodbc
env = dict(re.findall(r'(\w+)="([^"]*)"', open(".env").read()))
cs = (f"DRIVER={{ODBC Driver 18 for SQL Server}};SERVER={env['DB_SERVER']};UID={env['DB_USER']};"
      f"PWD={env['DB_PASSWORD']};Encrypt=no;TrustServerCertificate=yes;")
for _ in range(60):
    try:
        print(pyodbc.connect(cs, timeout=5).cursor().execute("SELECT @@VERSION").fetchone()[0].splitlines()[0])
        sys.exit(0)
    except pyodbc.Error as e:
        last = e
        if "SSL Provider" in str(e) or "Login failed" in str(e):
            sys.exit(f"Could not connect to SQL Server: {e}")
        time.sleep(3)
sys.exit(f"Could not connect to SQL Server: {last}")
EOF

echo "==> Publishing to GitHub"
[ -d .git ] || git init -q -b main
git remote get-url origin >/dev/null 2>&1 || git remote add origin https://github.com/hamzasallamm/tayar-db.git
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "Set up Tayar project, build and test tools" \
    -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" \
    -m "Claude-Session: https://claude.ai/code/session_01WW4WCuDgKZx8rRTeDF8Nkh"
fi
if ! git push -q -u origin main; then
  echo "GitHub push needs a sign-in. In GitHub Desktop choose File > Add Local Repository, pick this folder, then Push origin."
fi

echo "==> Running the first test"
bash tools/test.sh s1 || true

open -a "Visual Studio Code" .
echo
echo "Setup finished. To connect from VS Code: server localhost,$PORT, user sa."
echo "The password is DB_PASSWORD in the .env file in this folder."
