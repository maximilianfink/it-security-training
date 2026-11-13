#!/bin/bash
# Pizza Pronto lab – one script for everything.
#
#   ./lab.sh setup       once, needs internet: download/build everything (~5 GB), afterwards works offline
#   ./lab.sh start       Supply Chain lab: shop, registries, collector
#   ./lab.sh devsecops   DevSecOps lab: additionally Gitea + CI runner
#   ./lab.sh sbom        list the shop's dependencies (direct + transitive)
#   ./lab.sh diff P A B  show what changed between two versions of a package
#   ./lab.sh publish D   publish package folder D to the public registry (attack)
#   ./lab.sh code        open the lab in VS Code (+ recommended extensions)
#   ./lab.sh attacker    shell with node/npm on the lab network (for your own packages)
#   ./lab.sh renovate    run the Renovate bot once
#   ./lab.sh redeploy    redeploy the shop (runs "npm install" again)
#   ./lab.sh status      show containers and URLs
#   ./lab.sh stop        stop everything (data is kept)
#   ./lab.sh reset       back to the initial state (removes your packages, Gitea data, orders)
set -e
cd "$(dirname "$0")"

# The lab runs on Docker or Podman. Pick whatever is installed and working.
#   ENGINE   -> "docker" or "podman"
#   COMPOSE  -> "docker compose" / "podman compose" / "docker-compose" / "podman-compose"
detect_engine() {
  for e in docker podman; do
    command -v "$e" >/dev/null 2>&1 || continue
    if "$e" info >/dev/null 2>&1; then ENGINE="$e"; return 0; fi
  done
  # nothing talking yet – produce a precise diagnosis
  if command -v docker >/dev/null 2>&1; then
    if sudo docker info >/dev/null 2>&1; then
      echo "Docker only works with sudo -> your user is not in the 'docker' group yet." >&2
      echo "Fix it once:  sudo usermod -aG docker \$USER  &&  newgrp docker" >&2
    else
      echo "The Docker daemon is not running. Start it:  sudo systemctl enable docker --now" >&2
    fi
  elif command -v podman >/dev/null 2>&1; then
    echo "Podman is installed but not reachable. On a Mac/Windows host start the VM:" >&2
    echo "  podman machine start" >&2
  else
    echo "Neither Docker nor Podman found. Install Docker:  sudo apt install -y docker.io" >&2
  fi
  exit 1
}

detect_compose() {
  if $ENGINE compose version >/dev/null 2>&1; then COMPOSE="$ENGINE compose"; return; fi
  if command -v "$ENGINE-compose" >/dev/null 2>&1; then COMPOSE="$ENGINE-compose"; return; fi
  if [ "$ENGINE" = docker ] && command -v docker-compose >/dev/null 2>&1; then COMPOSE="docker-compose"; return; fi
  COMPOSE="$ENGINE compose"   # will be installed by './lab.sh setup' on Docker
}

check_docker() { detect_engine; }   # kept for callers below

# Install the Docker Compose v2 plugin for the current user (Docker only; needs internet, honours proxy).
install_compose_plugin() {
  [ "$ENGINE" = docker ] || return 0
  docker compose version >/dev/null 2>&1 && return 0
  echo "== Installing the Docker Compose v2 plugin"
  mkdir -p "$HOME/.docker/cli-plugins"
  curl -fSL "https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" \
    -o "$HOME/.docker/cli-plugins/docker-compose"
  chmod +x "$HOME/.docker/cli-plugins/docker-compose"
  docker compose version >/dev/null 2>&1 || { echo "Compose v2 install failed." >&2; exit 1; }
  COMPOSE="docker compose"
}

# The CI runner needs the engine's socket to launch job containers.
# Docker: /var/run/docker.sock. Rootless Podman: the user socket (started on demand).
detect_socket() {
  [ -n "${DOCKER_SOCKET:-}" ] && { export DOCKER_SOCKET; return; }
  if [ "$ENGINE" = podman ]; then
    systemctl --user enable --now podman.socket >/dev/null 2>&1 || true
    DOCKER_SOCKET="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
  else
    DOCKER_SOCKET="/var/run/docker.sock"
  fi
  export DOCKER_SOCKET
}

# Compute a CONTAINER-reachable proxy from the host proxy.
# A proxy on localhost/127.0.0.1 (common on Bosch laptops) is the host from the container's
# point of view -> rewrite it to the host alias. The host's own proxy stays untouched so that
# "$ENGINE pull" (which runs on the host) keeps working.
compute_container_proxy() {
  case "$ENGINE" in
    podman) HOST_ALIAS="host.containers.internal" ;;
    *)      HOST_ALIAS="host.docker.internal" ;;
  esac
  for v in HTTP_PROXY HTTPS_PROXY; do
    eval "cur=\${$v:-\${$(echo "$v" | tr '[:upper:]' '[:lower:]'):-}}"
    case "$cur" in
      *localhost*|*127.0.0.1*) cur=$(printf '%s' "$cur" | sed -E "s#(localhost|127\\.0\\.0\\.1)#$HOST_ALIAS#g") ;;
    esac
    export "CONTAINER_$v=$cur"
  done
  export CONTAINER_NO_PROXY="registry-internal,registry-public,collector,shop,gitea,localhost,127.0.0.1"
  if [ -n "${CONTAINER_HTTP_PROXY:-}${CONTAINER_HTTPS_PROXY:-}" ]; then
    echo "   (containers use proxy: ${CONTAINER_HTTPS_PROXY:-$CONTAINER_HTTP_PROXY})"
  fi
  return 0
}

# Build args so image builds work behind a corporate proxy (container-reachable proxy).
# Empty in the lab (no proxy) -> changes nothing.
build_proxy_args() {
  printf ' --add-host=host.docker.internal:host-gateway --add-host=host.containers.internal:host-gateway'
  [ -n "${CONTAINER_HTTP_PROXY:-}" ]  && printf ' --build-arg HTTP_PROXY=%s --build-arg http_proxy=%s' "$CONTAINER_HTTP_PROXY" "$CONTAINER_HTTP_PROXY"
  [ -n "${CONTAINER_HTTPS_PROXY:-}" ] && printf ' --build-arg HTTPS_PROXY=%s --build-arg https_proxy=%s' "$CONTAINER_HTTPS_PROXY" "$CONTAINER_HTTPS_PROXY"
  [ -n "${CONTAINER_HTTP_PROXY:-}${CONTAINER_HTTPS_PROXY:-}" ] && printf ' --build-arg NO_PROXY=%s --build-arg no_proxy=%s' "$CONTAINER_NO_PROXY" "$CONTAINER_NO_PROXY"
  return 0
}

ALL="--profile devsecops --profile tools"

# Detect the engine for every real command (not for plain help).
case "${1:-help}" in
  help|-h|--help|"") ;;
  *) detect_engine; detect_compose; compute_container_proxy; export ENGINE COMPOSE ;;
esac

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
    install_compose_plugin
    detect_socket
    echo "== Downloading images"
    for img in verdaccio/verdaccio:7.1 gitea/gitea:28.3 gitea/act_runner:0.6.1 \
               renovate/renovate:44.235 node:22-alpine; do
      $ENGINE pull "$img"
    done
    echo "== Building shop and scanner image (takes a few minutes)"
    # shellcheck disable=SC2046
    $ENGINE build $(build_proxy_args) -t pizza-pronto/shop ./app
    # shellcheck disable=SC2046
    $ENGINE build $(build_proxy_args) -t pizza-pronto/secscan ./secscan
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
    detect_socket
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
  code)
    # open the lab folder in VS Code and install the recommended extensions
    if ! command -v code >/dev/null 2>&1; then
      echo "VS Code ('code') is not installed in this VM." >&2
      echo "Install it, then run './lab.sh code' again:" >&2
      echo "  sudo snap install code --classic   # or download the .deb from https://code.visualstudio.com" >&2
      exit 1
    fi
    for ext in dbaeumer.vscode-eslint redhat.vscode-yaml ms-azuretools.vscode-docker editorconfig.editorconfig; do
      code --install-extension "$ext" >/dev/null 2>&1 || true
    done
    code "$PWD"
    echo "VS Code opened on the lab folder. Accept the recommended extensions if prompted."
    ;;
  sbom)
    # list the shop's dependencies (direct + transitive)
    $COMPOSE exec -T shop sh -c 'echo "Direct dependencies:"; npm ls 2>/dev/null | sed "1d"; \
      echo; echo -n "Total packages (direct + transitive): "; npm ls --all --parseable 2>/dev/null | grep -c node_modules'
    ;;
  diff)
    # compare two versions of a package: ./lab.sh diff tiny-receipt 1.2.0 1.2.1
    pkg="${2:?usage: ./lab.sh diff <package> <old-version> <new-version>}"
    v1="${3:?usage: ./lab.sh diff <package> <old-version> <new-version>}"
    v2="${4:?usage: ./lab.sh diff <package> <old-version> <new-version>}"
    $COMPOSE --profile tools run --rm -T attacker sh -c "cd /tmp && rm -rf a b *.tgz && \
      npm pack $pkg@$v1 --registry http://registry-public:4873/ >/dev/null 2>&1 && \
      npm pack $pkg@$v2 --registry http://registry-public:4873/ >/dev/null 2>&1 && \
      mkdir a b && tar xf $pkg-$v1.tgz -C a && tar xf $pkg-$v2.tgz -C b && \
      diff -ru a/package b/package || true"
    ;;
  publish)
    # publish a package folder to the (simulated) public registry: ./lab.sh publish examples/evil-pronto-utils
    dir="${2:?usage: ./lab.sh publish <folder>}"
    [ -d "$dir" ] || { echo "No such folder: $dir" >&2; exit 1; }
    $COMPOSE --profile tools run --rm -T -v "$PWD/$dir:/pkg:ro" attacker sh -c "
      cp -r /pkg /tmp/pkg && cd /tmp/pkg && \
      T=\$(node -e \"fetch('http://registry-public:4873/-/user/org.couchdb.user:team',{method:'PUT',headers:{'content-type':'application/json','authorization':'Basic '+Buffer.from('team:secret123').toString('base64')},body:JSON.stringify({name:'team',password:'secret123'})}).then(r=>r.json()).then(j=>console.log(j.token||''))\") && \
      npm publish --registry http://registry-public:4873/ --//registry-public:4873/:_authToken=\$T"
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
    $ENGINE volume rm -f pizza-pronto_registry-internal pizza-pronto_gitea pizza-pronto_runner >/dev/null
    rm -f .env
    find attacker -mindepth 1 ! -name README.md -exec rm -rf {} + 2>/dev/null || true
    echo "Done. Start again with ./lab.sh start (or ./lab.sh devsecops)"
    ;;
  *)
    sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
    ;;
esac
