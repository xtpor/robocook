
# client

FROM tintinho/godot-builder:3.1.2-stable AS robocook-client-builder

WORKDIR /app
COPY client /app
RUN echo '\
[preset.0]\n\
\n\
name="HTML5"\n\
platform="HTML5"\n\
runnable=true\n\
custom_features=""\n\
export_filter="all_resources"\n\
include_filter=""\n\
exclude_filter=""\n\
export_path=""\n\
patch_list=PoolStringArray(  )\n\
script_export_mode=1\n\
script_encryption_key=""\n\
\n\
[preset.0.options]\n\
\n\
vram_texture_compression/for_desktop=true\n\
vram_texture_compression/for_mobile=false\n\
html/custom_html_shell=""\n\
html/head_include=""\n\
custom_template/release=""\n\
custom_template/debug=""\n\
' > /app/export_presets.cfg

RUN mkdir /output
RUN godot --path /app/project.godot --export "HTML5" /output/robocook.html
RUN mv /output/robocook.html /output/index.html
RUN sed -i '/<body>/a <script src="env.js"></script>' /output/index.html
RUN echo '\
SERVER_URL = "ws://localhost:5657"\n\
' > /output/env.js


FROM caddy:2.3.0-alpine AS robocook-client

WORKDIR /var/www/html
COPY --from=robocook-client-builder /output /var/www/html

CMD ["caddy", "file-server"]


# server

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
