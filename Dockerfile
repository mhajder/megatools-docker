# syntax=docker/dockerfile:1

FROM alpine:3.24 AS builder

ARG MEGATOOLS_VERSION=1.12.2
ARG MEGATOOLS_PGP_FINGERPRINT=EBFBDDE11FB918D44D1F56C1F9F0A873BE9777ED

SHELL ["/bin/sh", "-eo", "pipefail", "-c"]

RUN apk add --no-cache \
        build-base \
        curl \
        curl-dev \
        glib-dev \
        gnupg \
        meson \
        openssl-dev \
        pkgconf

WORKDIR /src

RUN set -eux; \
    VER_RE=$(printf '%s' "${MEGATOOLS_VERSION}" | sed 's/\./\\./g'); \
    TARBALL=$(curl -fsSL https://xff.cz/megatools/builds/ \
        | grep -oE "megatools-${VER_RE}(\.[0-9]+)?\.tar\.gz" \
        | sort -V \
        | tail -n 1); \
    test -n "$TARBALL"; \
    curl -fsSL "https://xff.cz/megatools/builds/${TARBALL}" -o megatools.tar.gz; \
    curl -fsSL "https://xff.cz/megatools/builds/${TARBALL}.asc" -o megatools.tar.gz.asc; \
    curl -fsSL "https://xff.cz/key.txt" -o release-key.txt; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --import release-key.txt; \
    gpg --batch --list-keys --with-colons | grep -q "^fpr:::::::::${MEGATOOLS_PGP_FINGERPRINT}:$"; \
    gpg --batch --status-fd 1 --verify megatools.tar.gz.asc megatools.tar.gz | grep -q "VALIDSIG .* ${MEGATOOLS_PGP_FINGERPRINT}$"; \
    rm -rf "${GNUPGHOME}"; \
    tar -xzf megatools.tar.gz --strip-components=1; \
    meson setup --prefix=/usr --buildtype=release --strip -Dman=false build; \
    meson compile -C build; \
    DESTDIR=/install meson install -C build

FROM alpine:3.24

ARG MEGATOOLS_VERSION=1.12.2
ARG UID=10001
ARG GID=10001

LABEL org.opencontainers.image.title="Megatools" \
    org.opencontainers.image.description="Command-line client for Mega.nz" \
    org.opencontainers.image.url="https://xff.cz/megatools/" \
    org.opencontainers.image.documentation="https://xff.cz/megatools/" \
    org.opencontainers.image.source="https://xff.cz/git/megatools/" \
    org.opencontainers.image.vendor="Mateusz Hajder" \
    org.opencontainers.image.licenses="GPL-2.0" \
    org.opencontainers.image.base.name="docker.io/library/alpine:3.24" \
    org.opencontainers.image.version="${MEGATOOLS_VERSION}"

RUN apk add --no-cache ca-certificates glib libcurl && \
    addgroup -g "${GID}" -S megatools && \
    adduser -D -S -u "${UID}" -G megatools -h /home/megatools megatools

COPY --from=builder /install/usr/bin/ /usr/bin/

ENV HOME=/home/megatools

USER megatools
WORKDIR /home/megatools

ENTRYPOINT ["megatools"]
