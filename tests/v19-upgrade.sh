#!/bin/bash
set -Eeuo pipefail
umask 077

work=/tmp/tkl-nodejs-upgrade
pm2_home=/tmp/tkl-nodejs-pm2
response=/tmp/tkl-nodejs-upgrade-response.$$

cleanup() {
    PM2_HOME=$pm2_home pm2 kill >/dev/null 2>&1 || true
    rm -rf -- "$work" "$pm2_home" "$response"
}
trap cleanup EXIT

export DEBIAN_FRONTEND=noninteractive
apt-get update >/dev/null
apt-get install --assume-yes --no-install-recommends \
    ca-certificates curl nodejs npm >/dev/null
update-ca-certificates >/dev/null
test "$(npm config get registry)" = https://registry.npmjs.org/

mkdir -p "$work"
cd "$work"
npm init --yes >/dev/null
npm install express@4.20.0 >/dev/null
npm install --global pm2@5.4.3 >/dev/null
cat >app.js <<'NODE'
const express = require('express');
const app = express();
app.get('/', (_request, response) => response.send('nodejs-upgrade-ok'));
app.listen(18000, '127.0.0.1');
NODE

PM2_HOME=$pm2_home pm2 start app.js --name upgrade-fixture >/dev/null
PM2_HOME=$pm2_home pm2 save >/dev/null
for _ in $(seq 1 30); do
    if curl --fail --silent --show-error http://127.0.0.1:18000/ \
            >"$response" 2>/dev/null; then
        break
    fi
    sleep 1
done
grep -Fxq 'nodejs-upgrade-ok' "$response"
pm2_before=$(node -p \
    "require('/usr/local/lib/node_modules/pm2/package.json').version")
express_before=$(node -p "require('express/package.json').version")

PM2_HOME=$pm2_home pm2 kill >/dev/null
npm install --global pm2@latest >/dev/null
npm update express >/dev/null
pm2_after=$(node -p \
    "require('/usr/local/lib/node_modules/pm2/package.json').version")
express_after=$(node -p "require('express/package.json').version")
test "$pm2_after" != "$pm2_before"
test "$express_after" != "$express_before"

PM2_HOME=$pm2_home pm2 resurrect >/dev/null
for _ in $(seq 1 30); do
    if curl --fail --silent --show-error http://127.0.0.1:18000/ \
            >"$response" 2>/dev/null; then
        break
    fi
    sleep 1
done
grep -Fxq 'nodejs-upgrade-ok' "$response"
node - <<'NODE'
const lock = require('./package-lock.json');
const packages = Object.entries(lock.packages || {})
  .filter(([path]) => path.startsWith('node_modules/'));
if (!packages.length || packages.some(([, pkg]) => !pkg.integrity)) process.exit(1);
NODE

cat <<EOF
pm2_upgrade=$pm2_before -> $pm2_after
express_upgrade=$express_before -> $express_after
upgrade_result=PM2 resurrected the sample application and the HTTP response passed
integrity_result=npm used the HTTPS registry and package-lock integrity hashes passed
EOF
