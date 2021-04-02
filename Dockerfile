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


# Same OS version as the builder image
FROM debian:buster
RUN apt-get update \
    && apt-get install -y libgmp10 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/tasklite/tasklite-core/example-config.yaml /root/.config/tasklite/config.yaml
COPY --from=builder /root/.local/bin/tasklite /usr/local/bin/tasklite
CMD ["tasklite"]
