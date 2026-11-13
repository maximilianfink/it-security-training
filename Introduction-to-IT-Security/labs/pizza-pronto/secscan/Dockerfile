# All-in-one security scanner image for the Pizza Pronto CI pipeline.
# Built once (with internet access), afterwards the pipeline runs completely offline.
FROM zricethezav/gitleaks:v8.30.1 AS gitleaks
FROM aquasec/trivy:0.76.2 AS trivy
FROM anchore/syft:v1.57.1 AS syft
FROM hadolint/hadolint:v2.15.1 AS hadolint

FROM node:22-bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates python3 python3-venv jq \
 && rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir semgrep guarddog
ENV PATH="/opt/venv/bin:${PATH}"

COPY --from=gitleaks /usr/bin/gitleaks /usr/local/bin/gitleaks
COPY --from=trivy /usr/local/bin/trivy /usr/local/bin/trivy
COPY --from=syft /syft /usr/local/bin/syft
COPY --from=hadolint /bin/hadolint /usr/local/bin/hadolint

# Pre-download vulnerability databases and rules so the pipeline works offline
ENV TRIVY_CACHE_DIR=/opt/trivy-cache \
    SEMGREP_SEND_METRICS=off
RUN trivy fs --download-db-only \
 && chmod -R a+rX /opt/trivy-cache
# from now on never try to update the database (offline)
ENV TRIVY_SKIP_DB_UPDATE=true \
    TRIVY_SKIP_JAVA_DB_UPDATE=true \
    TRIVY_SKIP_CHECK_UPDATE=true \
    TRIVY_DISABLE_TELEMETRY=true
COPY rules /rules
