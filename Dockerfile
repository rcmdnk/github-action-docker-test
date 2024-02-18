FROM python:3.12-slim-bookworm as builder

ENV PIP_NO_CACHE_DIR=1 \
PIP_DISABLE_PIP_VERSION_CHECK=1 \
VIRTUAL_ENV=/app/.venv

WORKDIR /app

RUN pip install poetry-plugin-export

COPY pyproject.toml poetry.lock src ./

RUN poetry export --with dev --without-hashes --format=requirements.txt > requirements.txt
RUN echo "./" >> requirements.txt

RUN python -m venv "$VIRTUAL_ENV"
RUN . "$VIRTUAL_ENV/bin/activate" && pip install -r requirements.txt

###############

FROM python:3.12-slim-bookworm as runtime
ARG USER_NAME="appuser"

ENV VIRTUAL_ENV=/app/.venv \
PATH="/app/.venv/bin:$PATH"

COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV

WORKDIR /app

RUN useradd -r -u 1000 $USER_NAME
RUN chown -R $USER_NAME:$USER_NAME /app

USER $USER_NAME
