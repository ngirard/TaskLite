FROM haskell:8.8.4-buster as builder

WORKDIR /usr/src/tasklite

COPY docker-stack.yaml stack.yaml

COPY tasklite-core/README.md tasklite-core/README.md
COPY tasklite-core/example-config.yaml tasklite-core/example-config.yaml
COPY tasklite-core/package.yaml tasklite-core/package.yaml

COPY huzzy huzzy

RUN stack install --only-dependencies tasklite-core

COPY tasklite-core tasklite-core

# Needed for retrieving the version number
COPY .git .git

RUN stack install


FROM alpine:3.13.4
RUN apk --no-cache add libgmp10=6.2.1-r0
COPY --from=builder /usr/src/tasklite/tasklite-core/example-config.yaml /root/.config/tasklite/config.yaml
COPY --from=builder /root/.local/bin/tasklite /usr/local/bin/tasklite
ENTRYPOINT ["tasklite"]
