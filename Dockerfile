FROM python:3.12-bookworm as builder

RUN apt-get update

ENV PYTHONDONTWRITEBYTECODE=1 \
PYTHONUNBUFFERED=1 \
PIP_NO_CACHE_DIR=off \
PIP_DISABLE_PIP_VERSION_CHECK=on \
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
ARG USER="app"

RUN apt-get update && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/app/.venv \
PATH="/app/.venv/bin:$PATH"

COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV

WORKDIR /app
COPY entrypoint.sh ./

RUN useradd -r -u 1000 ${USER}
RUN chown -R $USER:$USER /app

# Enable when repository checkout is needed in GitHub Actions
# https://github.com/actions/checkout/issues/1014#issuecomment-1670098922
RUN mkdir -m 777 /__w

USER $USER

ENTRYPOINT ["./entrypoint.sh"]
