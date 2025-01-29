# Base stage
FROM python:3.13-slim AS base

ARG DOCKER_IMAGE

ENV PYTHONPATH=/app \
    CONFIG_FILE=/app/config.yaml \
    PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        python3-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

COPY base_images/${DOCKER_IMAGE}/requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt watchdog

# Dev stage
FROM base AS development

WORKDIR /app

CMD ["python", "main.py"]

# Production stage
FROM base AS production

ARG STRATEGY_NAME
ENV STRATEGY_NAME=${STRATEGY_NAME}

WORKDIR /app

COPY common/ /app/common/
COPY superalgos/${STRATEGY_NAME}/ /app

CMD ["python", "main.py"]