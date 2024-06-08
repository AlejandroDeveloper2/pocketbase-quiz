FROM alpine:3 as downloader

ARG TARGETOS
ARG TARGETARCH
ARG VERSION=0.22.13

ENV BUILDX_ARCH="${TARGETOS:-linux}_${TARGETARCH:-amd64}"

# Install the dependencies
RUN apk add --no-cache \
    ca-certificates \
    unzip \
    wget \
    zip \
    zlib-dev

RUN wget https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && unzip pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && chmod +x /pocketbase

COPY pb_data /pb_data
COPY pb_migrations /pb_migrations

FROM scratch

EXPOSE 8090

COPY --from=downloader /pocketbase /usr/local/bin/pocketbase
COPY --from=downloader /pb_migrations /pb_migrations
COPY --from=downloader /pb_data /pb_data 

CMD ["/usr/local/bin/pocketbase", "serve", "--http=0.0.0.0:8090", "--datair=/pb_data", "--migrationsDir=/pb_migrations", "--publicDir=/pb_public"]