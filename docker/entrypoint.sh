#!/bin/sh
# MedTech Platform — container entrypoint
#
# Default command: up  (foreground, logs streamed to stdout)
#
# Usage inside the container:
#   medtech-platform [up [-d] | down | ps | logs [-f] | pull | config | <any docker compose subcommand>]
#
# Run from GHCR (Linux):
#   docker run --rm -it --name medtech-platform \
#     -v /var/run/docker.sock:/var/run/docker.sock \
#     ghcr.io/chaithubk/medtech-platform:<tag>

set -e

COMPOSE_FILE="${COMPOSE_FILE:-/platform/docker-compose.yml}"
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-medtech-platform}"
export COMPOSE_FILE COMPOSE_PROJECT_NAME

# ── helpers ─────────────────────────────────────────────────────────────────

info()  { printf 'ℹ️  %s\n' "$*"; }
ok()    { printf '✅ %s\n' "$*"; }
err()   { printf '❌ %s\n' "$*" >&2; }
die()   { err "$*"; exit 1; }

print_run_hint() {
    printf '\n'
    printf 'To start the full platform stack, mount the host Docker socket:\n'
    printf '\n'
    printf '  # Linux / macOS (Docker Desktop uses the same socket path):\n'
    printf '  docker run --rm -it --name medtech-platform \\\n'
    printf '    -v /var/run/docker.sock:/var/run/docker.sock \\\n'
    printf '    ghcr.io/chaithubk/medtech-platform:<tag>\n'
    printf '\n'
    printf '  # Detached (background) mode:\n'
    printf '  docker run -d --name medtech-platform \\\n'
    printf '    -v /var/run/docker.sock:/var/run/docker.sock \\\n'
    printf '    ghcr.io/chaithubk/medtech-platform:<tag> up -d\n'
    printf '\n'
}

check_docker_socket() {
    if [ ! -S /var/run/docker.sock ]; then
        err "Docker socket not found at /var/run/docker.sock."
        err "This container orchestrates sibling containers and therefore needs"
        err "read/write access to the host Docker daemon socket."
        print_run_hint
        exit 1
    fi

    if ! docker version > /dev/null 2>&1; then
        err "Docker socket is present but 'docker version' failed."
        err "Ensure Docker is running and the socket is readable by this container."
        err "  Check socket permissions: ls -la /var/run/docker.sock"
        print_run_hint
        exit 1
    fi
}

preflight() {
    info "Preflight: validating docker-compose.yml …"
    if ! docker compose -f "$COMPOSE_FILE" config --quiet 2>&1; then
        die "docker-compose.yml failed validation — fix the errors above and rebuild the image."
    fi
    ok "Compose config is valid."
}

# ── signal handler ───────────────────────────────────────────────────────────

COMPOSE_PID=""

cleanup() {
    # Prevent re-entry on multiple signals.
    trap '' INT TERM
    info "Stop signal received — running docker compose down …"
    docker compose -f "$COMPOSE_FILE" down 2>/dev/null || true
    if [ -n "$COMPOSE_PID" ]; then
        kill "$COMPOSE_PID" 2>/dev/null || true
        wait "$COMPOSE_PID" 2>/dev/null || true
    fi
    exit 0
}

# ── subcommand dispatch ──────────────────────────────────────────────────────

CMD="${1:-up}"
shift 2>/dev/null || true   # consume $1; suppress error when no arguments exist

case "$CMD" in

    # ------------------------------------------------------------------
    # config — validate compose file then stay alive for docker cp.
    # Used by CI smoke-test to extract the pinned compose file from the
    # image without starting the stack on the host daemon.
    # ------------------------------------------------------------------
    config)
        preflight
        ok  "Container staying alive for inspection / docker cp."
        info "Compose file is at: /platform/docker-compose.yml"
        info "To start the stack on your host:  docker compose -f /path/to/docker-compose.yml up"
        exec tail -f /dev/null
        ;;

    # ------------------------------------------------------------------
    # up — start the full stack (default command)
    # ------------------------------------------------------------------
    up)
        check_docker_socket
        preflight

        # Detect detached mode so we do not background an already-detached run.
        DETACH=false
        for arg in "$@"; do
            case "$arg" in -d|--detach) DETACH=true ;; esac
        done

        if [ "$DETACH" = "true" ]; then
            info "Starting MedTech platform stack (detached) …"
            exec docker compose -f "$COMPOSE_FILE" up "$@"
        else
            info "Starting MedTech platform stack (foreground — Ctrl-C or docker stop to quit) …"
            trap cleanup INT TERM
            docker compose -f "$COMPOSE_FILE" up "$@" &
            COMPOSE_PID=$!
            wait "$COMPOSE_PID"
        fi
        ;;

    # ------------------------------------------------------------------
    # down — stop and remove containers / networks
    # ------------------------------------------------------------------
    down)
        check_docker_socket
        exec docker compose -f "$COMPOSE_FILE" down "$@"
        ;;

    # ------------------------------------------------------------------
    # ps — list running services
    # ------------------------------------------------------------------
    ps)
        check_docker_socket
        exec docker compose -f "$COMPOSE_FILE" ps "$@"
        ;;

    # ------------------------------------------------------------------
    # logs — tail service logs
    # ------------------------------------------------------------------
    logs)
        check_docker_socket
        exec docker compose -f "$COMPOSE_FILE" logs "$@"
        ;;

    # ------------------------------------------------------------------
    # pull — pull all pinned service images
    # ------------------------------------------------------------------
    pull)
        check_docker_socket
        exec docker compose -f "$COMPOSE_FILE" pull "$@"
        ;;

    # ------------------------------------------------------------------
    # Passthrough — any other docker compose subcommand
    # ------------------------------------------------------------------
    *)
        check_docker_socket
        preflight
        exec docker compose -f "$COMPOSE_FILE" "$CMD" "$@"
        ;;

esac
