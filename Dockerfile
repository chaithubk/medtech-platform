FROM alpine:3.21

# docker compose CLI — used for config validation (no Docker daemon required)
RUN apk add --no-cache docker-cli-compose python3

WORKDIR /platform
COPY docker-compose.yml .

# Verify the bundled compose configuration parses correctly.
# docker compose config is pure YAML resolution — no daemon access needed.
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=2 \
    CMD docker compose config --quiet || exit 1

# Validate config on startup then stay alive for inspection / docker cp.
ENTRYPOINT ["sh", "-c", "docker compose config --quiet && exec tail -f /dev/null"]
