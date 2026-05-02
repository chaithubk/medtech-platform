FROM alpine:3.21@sha256:48b0309ca019d89d40f670aa1bc06e426dc0931948452e8491e3d65087abc07d

# docker-cli-compose — docker compose plugin (pulls in docker-cli as a dependency)
# python3           — runtime for integration test suite
RUN apk add --no-cache docker-cli-compose=2.31.0-r5 python3=3.12.13-r0

WORKDIR /platform
COPY docker-compose.yml .
COPY docker/entrypoint.sh /usr/local/bin/medtech-platform
RUN chmod +x /usr/local/bin/medtech-platform

# Healthcheck: validate bundled compose YAML — no Docker daemon needed.
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=2 \
    CMD docker compose -f /platform/docker-compose.yml config --quiet || exit 1

# Default: start the full stack in the foreground.
# Pass "config" to run in CI carrier mode (validate + stay alive for docker cp).
ENTRYPOINT ["medtech-platform"]
CMD ["up"]
