#!/bin/bash
# Pizza Pronto lab – one script for everything.
#
#   ./lab.sh setup       once, needs internet: download/build everything (~5 GB), afterwards works offline
#   ./lab.sh start       Supply Chain lab: shop, registries, collector
#   ./lab.sh devsecops   DevSecOps lab: additionally Gitea + CI runner
#   ./lab.sh attacker    shell with node/npm on the lab network (for your own packages)
#   ./lab.sh renovate    run the Renovate bot once
#   ./lab.sh redeploy    redeploy the shop (runs "npm install" again)
#   ./lab.sh status      show containers and URLs
#   ./lab.sh stop        stop everything (data is kept)
#   ./lab.sh reset       back to the initial state (removes your packages, Gitea data, orders)
set -e
cd "$(dirname "$0")"

if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
  echo "Warning: using the old docker-compose (v1). The lab is tested with the Docker Compose v2" >&2
  echo "plugin. If you hit errors, install it: sudo apt install -y docker-compose-plugin" >&2
else
  echo "Docker Compose not found. Install it with:  sudo apt install -y docker-compose-plugin" >&2; exit 1
fi
export COMPOSE
ALL="--profile devsecops --profile tools"

check_docker() {
  if ! docker info >/dev/null 2>&1; then
    echo "Cannot talk to Docker. Try:" >&2
    echo "  sudo systemctl enable docker --now" >&2
    echo "  sudo usermod -aG docker \$USER   (then log out and in again)" >&2
    exit 1
  fi
}

urls() {
  echo
  echo "  Shop               http://localhost:3000"
  echo "  Collector          http://localhost:8000   (attacker server)"
  echo "  Internal registry  http://localhost:4873"
  echo "  Public registry    http://localhost:4874"
  if [ -n "$($COMPOSE $ALL ps -q gitea 2>/dev/null)" ]; then
    echo "  Gitea              http://localhost:3030   (luca / pizza-pronto-123)"
  fi
  echo
}

wait_for_shop() {
  echo -n "Waiting for the shop "
  for _ in $(seq 1 90); do
    if curl -s --noproxy '*' -o /dev/null http://localhost:3000; then echo " ok"; return 0; fi
    echo -n "."; sleep 2
  done
  echo; echo "Shop did not start – check: $COMPOSE logs shop" >&2; return 1
}

case "${1:-help}" in
  setup)
    check_docker
    echo "== Downloading images"
    for img in verdaccio/verdaccio:7.1 gitea/gitea:28.3 gitea/act_runner:0.6.1 \
               renovate/renovate:44.235 node:22-alpine; do
      docker pull "$img"
    done
    echo "== Building shop and scanner image (takes a few minutes)"
    docker build -t pizza-pronto/shop ./app
    docker build -t pizza-pronto/secscan ./secscan
    echo "== First start (fills the package cache for offline use)"
    $COMPOSE $ALL up -d
    wait_for_shop
    ./gitea/init.sh
    echo "== Stopping again"
    $COMPOSE $ALL down
    echo; echo "Setup complete. Start the lab with:  ./lab.sh start"
    ;;
  start)
    check_docker
    $COMPOSE up -d
    wait_for_shop
    urls
    ;;
  devsecops)
    check_docker
    $COMPOSE --profile devsecops up -d
    wait_for_shop
    ./gitea/init.sh
    urls
    ;;
  attacker)
    $COMPOSE --profile tools run --rm attacker
    ;;
  renovate)
    $COMPOSE --profile tools run --rm renovate
    ;;
  redeploy)
    $COMPOSE up -d --force-recreate shop
    wait_for_shop
    ;;
  status)
    $COMPOSE $ALL ps
    urls
    ;;
  stop)
    $COMPOSE $ALL down
    ;;
  reset)
    echo "Resetting the lab (the package cache is kept, so the lab still works offline) ..."
    $COMPOSE $ALL up -d registry-public >/dev/null 2>&1
    # remove the lab packages (incl. everything participants published); seed.sh restores the originals
    $COMPOSE exec -T registry-public sh -c 'cd /verdaccio/storage/data && rm -rf pronto-* tiny-receipt loadsh' || true
    $COMPOSE $ALL down
    docker volume rm -f pizza-pronto_registry-internal pizza-pronto_gitea pizza-pronto_runner >/dev/null
    rm -f .env
    find attacker -mindepth 1 ! -name README.md -exec rm -rf {} + 2>/dev/null || true
    echo "Done. Start again with ./lab.sh start (or ./lab.sh devsecops)"
    ;;
  *)
    sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
    ;;
esac
