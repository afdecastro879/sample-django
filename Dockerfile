FROM python:3.8.6 as builder

# This is to print directly to stdout instead of buffering output
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /usr/src/app

COPY requirements.txt .

# Install build deps, then run `pip install`, then remove unneeded build deps
# all in a single step.
SHELL ["/bin/bash", "-c"]
RUN set -ex \
  && BUILD_DEPS=" \
  build-essential \
  libpcre3-dev \
  git \
  " \
  && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
  && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS \
  && python -m venv venv \
  && source venv/bin/activate \
  && pip install -r requirements.txt

###
# Main image
###
FROM python:3.8.6-slim-buster

# This is to print directly to stdout instead of buffering output
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create a group and user to run our app
ARG APP_USER=kantan
RUN groupadd -r ${APP_USER} && useradd --no-log-init -r -g ${APP_USER} ${APP_USER}

# Install packages needed to run your application (not build deps)
# We also recreate the /usr/share/man/man{1..8} directories because they were
# clobbered by a parent image.
RUN set -ex \
  && RUN_DEPS=" \
  libpcre3 \
  libxml2 \
  libcurl4-openssl-dev \
  libssl-dev \
  " \
  && seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} \
  && apt-get update && apt-get install -y --no-install-recommends $RUN_DEPS \
  && rm -rf /var/lib/apt/lists/*

ARG VERSION
ARG DJANGO_SETTINGS_MODULE=mysite.settings
ARG PORT=8000
ARG DEVELOPMENT_MODE=True
ARG DJANGO_ALLOWED_HOSTS=localhost

ENV VERSION=${VERSION}
ENV PORT=${PORT}
ENV DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE}
ENV DEVELOPMENT_MODE=${DEVELOPMENT_MODE}
ENV DJANGO_ALLOWED_HOSTS=${DJANGO_ALLOWED_HOSTS}

EXPOSE ${PORT}

## Clean new directory
WORKDIR /usr/src/app

## We need all the files
COPY . .
COPY --from=builder /usr/src/app .

ENV PATH /usr/src/app/venv/bin:$PATH

RUN mkdir /usr/src/app/staticfiles/ && \
    chown -R ${APP_USER}:${APP_USER} /usr/src/app

# Change to a non-root user
USER ${APP_USER}:${APP_USER}

# Start uWSGI
CMD ["/bin/bash", "-c", "python manage.py migrate && python manage.py collectstatic --noinput && gunicorn mysite.wsgi"]
