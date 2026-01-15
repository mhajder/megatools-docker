FROM alpine:3.23

ARG MEGATOOLS_VERSION

LABEL org.opencontainers.image.title="Megatools" \
    org.opencontainers.image.description="Command-line client for Mega.nz" \
    org.opencontainers.image.url="https://xff.cz/megatools/" \
    org.opencontainers.image.source="https://xff.cz/git/megatools/" \
    org.opencontainers.image.vendor="Mateusz Hajder" \
    org.opencontainers.image.licenses="GPL-2.0" \
    org.opencontainers.image.version="${MEGATOOLS_VERSION}"

RUN apk add --no-cache ca-certificates && \
    echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache "megatools@testing~=${MEGATOOLS_VERSION}" && \
    addgroup -g 1000 megatools && \
    adduser -D -u 1000 -G megatools megatools

USER megatools
WORKDIR /home/megatools

ENTRYPOINT ["megatools"]
