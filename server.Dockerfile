FROM elixir:1.11.4-alpine AS robocook-server-builder

RUN mix do local.hex --force, local.rebar --force

WORKDIR /app
COPY server /app
COPY levels /app/priv/res

ENV MIX_ENV=prod
RUN mix do deps.get, deps.compile, release

FROM alpine:3.13 AS robocook-server

WORKDIR /app
RUN apk add --update ncurses-dev
COPY --from=robocook-server-builder /app/_build/prod/rel/robocook /app

CMD ["/app/bin/robocook", "start"]
