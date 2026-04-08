# Сборка
FROM haskell:9.14.1-slim AS builder
WORKDIR /app_directory

RUN cabal update

COPY .cabal /app_directory/

RUN cabal build --only-dependencies

COPY . /app_directory/
RUN cabal build

RUN mv $(cabal list-bin abc) /app_directory/executable

# Запуск
FROM debian:bookworm-slim

WORKDIR /app_directory

COPY --from=builder /app_directory/executable /app_directory/bin

ENTRYPOINT ["/app/bin"]