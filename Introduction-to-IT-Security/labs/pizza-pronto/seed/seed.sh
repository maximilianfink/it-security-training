#!/bin/sh
# Fills the lab registries with the prepared packages (runs once at startup).

# create (or log in) the user "seed" and print its auth token
token() {
  node -e "
    fetch('http://$1:4873/-/user/org.couchdb.user:seed', {
      method: 'PUT',
      headers: { 'content-type': 'application/json', authorization: 'Basic ' + Buffer.from('seed:seed-password').toString('base64') },
      body: JSON.stringify({ name: 'seed', password: 'seed-password' }),
    }).then((r) => r.json()).then((j) => console.log(j.token || ''));"
}

publish() {
  registry="$1"; file="$2"; auth="$3"
  out=$(npm publish "$file" --registry "http://$registry:4873/" "--//$registry:4873/:_authToken=$auth" 2>&1)
  if [ $? -eq 0 ]; then
    echo "[seed] published $(basename "$file") to $registry"
  elif echo "$out" | grep -qiE "EPUBLISHCONFLICT|409|cannot publish over"; then
    echo "[seed] $(basename "$file") already in $registry"
  else
    echo "[seed] ERROR publishing $(basename "$file") to $registry:"; echo "$out" | grep -i error; exit 1
  fi
}

INTERNAL_TOKEN=$(token registry-internal)
PUBLIC_TOKEN=$(token registry-public)
for f in /seed/packages/internal/*.tgz; do publish registry-internal "$f" "$INTERNAL_TOKEN"; done
for f in /seed/packages/public/*.tgz; do publish registry-public "$f" "$PUBLIC_TOKEN"; done
