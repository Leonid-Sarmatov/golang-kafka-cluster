# Сборка
FROM haskell:9.12.4-bookworm AS builder

WORKDIR /app_directory

RUN cabal update

COPY /microservices/example_haskell_consumer/example-haskell-consumer.cabal ./example-haskell-consumer.cabal

RUN cabal build --only-dependencies

COPY /microservices/example_haskell_consumer/LICENSE ./LICENSE
COPY /microservices/example_haskell_consumer/CHANGELOG.md ./CHANGELOG.md
COPY /microservices/example_haskell_consumer/main ./main
COPY /microservices/example_haskell_consumer/examplelib ./examplelib
COPY /microservices/example_haskell_consumer/librdkafka ./librdkafka

# RUN --mount=type=cache,target=/root/.cabal \
#     --mount=type=cache,target=/app_directory/dist-newstyle \
#     cabal build exe:example-haskell-consumer && \
#     mkdir -p /app_directory/bin && \
#     cp $(cabal list-bin exe:example-haskell-consumer) /app_directory/bin/

# Собираем приложение, монтируя кэш (для использования в дальнейших слоях сборки)
RUN --mount=type=cache,target=/app_directory/dist-newstyle \
    cabal build

# Внутри кэша автоматически находим исполняемый файл
RUN --mount=type=cache,target=/app_directory/dist-newstyle \
    cp $(cabal list-bin exe:example-haskell-consumer) /app_directory/

# Запуск
FROM debian:bookworm-slim

WORKDIR /app_directory

COPY --from=builder /app_directory/example-haskell-consumer .

ENTRYPOINT ["./example-haskell-consumer"]