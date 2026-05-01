FROM alpine:3.21@sha256:48b0309ca019d89d40f670aa1bc06e426dc0931948452e8491e3d65087abc07d

# docker compose CLI — used for config validation (no Docker daemon required)
RUN apk add --no-cache docker-cli-compose=2.31.0-r5 python3=3.12.13-r0

WORKDIR /platform
COPY docker-compose.yml .

# Verify the bundled compose configuration parses correctly.
# docker compose config is pure YAML resolution — no daemon access needed.
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=2 \
    CMD docker compose config --quiet || exit 1

# Validate config on startup then stay alive for inspection / docker cp.
ENTRYPOINT ["sh", "-c", "docker compose config --quiet && exec tail -f /dev/null"]
