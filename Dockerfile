FROM python:3.12-bookworm as builder

RUN apt-get update

RUN pip install poetry

ENV POETRY_NO_INTERACTION=1 \
POETRY_VIRTUALENVS_IN_PROJECT=1 \
POETRY_VIRTUALENVS_CREATE=1 \
POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root && rm -rf $POETRY_CACHE_DIR

###############

FROM python:3.12-slim-bookworm as runtime
ARG USER="app"

RUN apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/app/.venv \
PATH="/app/.venv/bin:$PATH"

COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV

WORKDIR /app
COPY entrypoint.sh ./

RUN useradd -r -u 1000 ${USER}
RUN chown -R $USER:$USER /app

USER $USER

ENTRYPOINT ["/entrypoint.sh"]
