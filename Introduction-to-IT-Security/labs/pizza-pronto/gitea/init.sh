#!/bin/bash
# Sets up the local Gitea for the DevSecOps lab (safe to run multiple times):
#   - users "luca" (admin, password below) and "renovate" (bot)
#   - repository luca/shop with the shop code and its (embarrassing) git history
#   - repository luca/skills for the Skill Battle
#   - writes RENOVATE_TOKEN to ../.env so "docker compose run --rm renovate" works
set -e
cd "$(dirname "$0")/.."

GITEA=http://localhost:3030
ADMIN=luca
ADMIN_PW=pizza-pronto-123
# COMPOSE is normally inherited from lab.sh; fall back to auto-detection if run standalone.
if [ -z "${COMPOSE:-}" ]; then
  for c in "docker compose" "podman compose" docker-compose podman-compose; do
    $c version >/dev/null 2>&1 && { COMPOSE="$c"; break; }
  done
fi

api() {  # api METHOD PATH [JSON]
  curl -s --noproxy '*' -u "$ADMIN:$ADMIN_PW" -X "$1" -H 'content-type: application/json' "$GITEA/api/v1$2" ${3:+-d "$3"}
}

echo "[init] waiting for Gitea ..."
until curl -s --noproxy '*' -o /dev/null "$GITEA/api/healthz"; do sleep 2; done

echo "[init] creating users"
$COMPOSE exec -T -u git gitea gitea admin user create --admin --username "$ADMIN" --password "$ADMIN_PW" \
  --email luca@pizza-pronto.example --must-change-password=false >/dev/null 2>&1 || true
$COMPOSE exec -T -u git gitea gitea admin user create --username renovate --password renovate-bot-123 \
  --email renovate@pizza-pronto.example --must-change-password=false >/dev/null 2>&1 || true
api PATCH /admin/users/renovate '{"full_name":"Renovate Bot","login_name":"renovate","source_id":0}' >/dev/null

# ---- repository luca/shop with a realistic history ----
if api GET /repos/$ADMIN/shop | grep -q '"id"'; then
  echo "[init] repository luca/shop already exists"
else
  echo "[init] creating repository luca/shop"
  api POST /user/repos '{"name":"shop","description":"Pizza Pronto online ordering website","private":false,"default_branch":"main"}' >/dev/null

  # Credentials Luca accidentally committed. The trainer may replace them with a real canary token (gitea/canary.env).
  AWS_ACCESS_KEY_ID=AKIAPRONTOSHOPXYZ234
  AWS_SECRET_ACCESS_KEY=pR0nt0+Sh0p/bAckUp+K3y+9f8e7d6c5b4a3f2e1d0c
  [ -f gitea/canary.env ] && . gitea/canary.env

  WORK=$(mktemp -d)
  cp -r app/. "$WORK/"
  rm -rf "$WORK/node_modules"
  cd "$WORK"
  git init -q -b main
  git config user.name "Luca Romano"
  git config user.email "luca@pizza-pronto.example"

  cat > .env <<ENV
# backup of the website to S3
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=eu-central-1
ENV
  git add -A
  GIT_AUTHOR_DATE="2025-03-01T21:14:00" GIT_COMMITTER_DATE="2025-03-01T21:14:00" git commit -q -m "Initial version of the online shop"

  git rm -q --cached .env && rm .env
  printf "node_modules/\n.env\n" > .gitignore
  git add .gitignore
  GIT_AUTHOR_DATE="2025-03-02T10:02:00" GIT_COMMITTER_DATE="2025-03-02T10:02:00" git commit -q -m "Remove .env, oops"

  mkdir -p .gitea/workflows
  cat > .gitea/workflows/ci.yml <<'YML'
name: CI
on: [push, pull_request]

jobs:
  build:
    runs-on: secscan
    env:
      DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
    steps:
      - name: Checkout
        run: |
          git clone http://gitea:3000/${{ github.repository }}.git src
          cd src && git checkout ${{ github.sha }}

      - name: Install dependencies
        working-directory: src
        run: npm install --no-package-lock

      - name: Syntax check
        working-directory: src
        run: node --check server.js

      # TODO (DevSecOps lab): add security checks here

      - name: Deploy
        run: echo "Deploying to shop.pizza-pronto.example with token ${DEPLOY_TOKEN:0:4}..."
YML
  git add -A
  GIT_AUTHOR_DATE="2025-04-10T18:30:00" GIT_COMMITTER_DATE="2025-04-10T18:30:00" git commit -q -m "Add CI pipeline"

  git -c http.proxy= push -q "http://$ADMIN:$ADMIN_PW@localhost:3030/$ADMIN/shop.git" main
  cd - >/dev/null
  rm -rf "$WORK"
  api PUT /repos/$ADMIN/shop/collaborators/renovate '{"permission":"write"}' >/dev/null
  api PUT /repos/$ADMIN/shop/actions/secrets/DEPLOY_TOKEN '{"data":"dpl_FLAG{ci-secrets-are-secrets-for-every-dependency}"}' >/dev/null
fi

# ---- repository luca/skills for the Skill Battle ----
if api GET /repos/$ADMIN/skills | grep -q '"id"'; then
  echo "[init] repository luca/skills already exists"
else
  echo "[init] creating repository luca/skills"
  api POST /user/repos '{"name":"skills","description":"Security review skills (Skill Battle)","private":false,"default_branch":"main"}' >/dev/null
  WORK=$(mktemp -d)
  cp -r skills/. "$WORK/"
  cd "$WORK"
  git init -q -b main
  git config user.name "Luca Romano"
  git config user.email "luca@pizza-pronto.example"
  git add -A && git commit -q -m "Add skill template"
  git -c http.proxy= push -q "http://$ADMIN:$ADMIN_PW@localhost:3030/$ADMIN/skills.git" main
  cd - >/dev/null
  rm -rf "$WORK"
fi

# ---- token for the Renovate bot ----
if ! grep -q '^RENOVATE_TOKEN=' .env 2>/dev/null; then
  echo "[init] creating Renovate token"
  TOKEN=$(curl -s --noproxy '*' -u renovate:renovate-bot-123 -X POST -H 'content-type: application/json' \
    "$GITEA/api/v1/users/renovate/tokens" \
    -d "{\"name\":\"renovate-$(date +%s)\",\"scopes\":[\"write:repository\",\"read:user\",\"write:issue\",\"read:organization\",\"read:misc\"]}" \
    | sed -n 's/.*"sha1":"\([^"]*\)".*/\1/p')
  echo "RENOVATE_TOKEN=$TOKEN" >> .env
fi

echo
echo "[init] done. Open $GITEA and log in as $ADMIN / $ADMIN_PW"
