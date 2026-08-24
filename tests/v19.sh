#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
response=/tmp/tkl-nodejs-response.$$
pm2_state=/tmp/tkl-nodejs-pm2.$$
policy=/tmp/tkl-nodejs-policy.$$

cleanup() {
    rm -f -- "$response" "$pm2_state" "$policy"
}
trap cleanup EXIT

systemctl --quiet is-active nginx.service pm2-node.service multi-user.target
nginx -t

test "$(command -v node)" = /usr/bin/node
test "$(command -v npm)" = /usr/bin/npm
dpkg-query -S /usr/bin/node | grep -q '^nodejs:'
dpkg-query -S /usr/bin/npm | grep -q '^npm:'
node_version=$(dpkg-query -W -f='${Version}' nodejs)
npm_version=$(dpkg-query -W -f='${Version}' npm)
nginx_version=$(dpkg-query -W -f='${Version}' nginx)
[[ $(node --version) == v20.* ]]
test "$(su node -s /bin/bash -c 'npm config get prefix')" = \
    /home/node/.npm-packages
test "$(su node -s /bin/bash -c 'npm config get cafile')" = \
    /etc/ssl/certs/ca-certificates.crt
npm audit --help >/dev/null
test -x /etc/skel/.bashrc.d/npm

curl --fail --silent --show-error http://127.0.0.1:8000/ >"$response"
grep -q 'TurnKey Node.js' "$response"
curl --insecure --fail --silent --show-error https://127.0.0.1/ >"$response"
grep -q 'TurnKey Node.js' "$response"
grep -q ':12321' "$response"

su node -s /bin/bash -c \
    'PM2_HOME=/home/node/.pm2 /usr/local/lib/node_modules/pm2/bin/pm2 jlist' \
    >"$pm2_state"
python3 - "$pm2_state" <<'PYTHON'
import json
import sys

processes = json.load(open(sys.argv[1]))
assert any(
    process.get("name") == "TurnKey Linux CP"
    and process.get("pid", 0) > 0
    and process.get("pm2_env", {}).get("status") == "online"
    for process in processes
)
PYTHON

pm2_version=$(node -p \
    "require('/usr/local/lib/node_modules/pm2/package.json').version")
pm2_candidate=$(npm_config_cafile=/etc/ssl/certs/ca-certificates.crt \
    npm view pm2 version)
test -n "$pm2_candidate"
test -f /opt/tklweb-cp/package-lock.json
node - <<'NODE'
const lock = require('/opt/tklweb-cp/package-lock.json');
const packages = Object.entries(lock.packages || {})
  .filter(([path]) => path.startsWith('node_modules/'));
if (!packages.length || packages.some(([, pkg]) => !pkg.integrity)) process.exit(1);
NODE

for example in node-by-example express_example nodejsbook.io.examples practicalnode; do
    test "$(stat -c '%U:%G' "/opt/node-examples/$example")" = node:node
    [[ $(git -C "/opt/node-examples/$example" remote get-url origin) == \
        https://github.com/* ]]
done

before="$node_version|$npm_version|$nginx_version"
apt-get update >/dev/null
for package in nodejs npm nginx; do
    apt-cache policy "$package" >"$policy"
    candidate=$(awk '/Candidate:/ {print $2}' "$policy")
    test -n "$candidate"
    test "$candidate" != '(none)'
    grep -Eq 'https?://(deb|security)\.debian\.org/.*trixie' "$policy"
done
after="$(dpkg-query -W -f='${Version}' nodejs)|$(dpkg-query -W -f='${Version}' npm)|$(dpkg-query -W -f='${Version}' nginx)"
test "$after" = "$before"
grep -Rqs '^Suites: trixie' /etc/apt/sources.list.d
! grep -Rqi bookworm /etc/apt/sources.list.d

cat >"$result" <<EOF
package_source=Debian 13 Trixie APT repositories for Node.js, npm and Nginx; npm registry for PM2 and sample application dependencies; GitHub upstream repositories for source examples
installed_version=nodejs $node_version; npm $npm_version; nginx $nginx_version; pm2 $pm2_version
runtime_checks=normal init; Nginx and PM2 active; direct sample application; HTTPS reverse proxy; PM2 sample process online; Debian-owned Node.js and npm; updateable Git examples
updater_command=apt-get update; apt-cache policy nodejs npm nginx; npm view pm2 version; npm install --global pm2@latest; npm update
updater_result=signed Debian metadata refreshed; installed packages unchanged; PM2 registry candidate $pm2_candidate; package-lock integrity fields present
updater_channel=Debian Trixie APT repositories, npm registry and upstream Git repositories
integrity_evidence=APT accepted signed Debian metadata; npm dependency lock records registry integrity hashes; no Bookworm source remained
EOF
