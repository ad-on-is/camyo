FROM oven/bun:alpine AS bun
FROM lscr.io/linuxserver/openssh-server:latest

WORKDIR /app

COPY --from=bun /usr/local/bin/bun /usr/local/bin/
ARG BUN_RUNTIME_TRANSPILER_CACHE_PATH=0
ENV BUN_RUNTIME_TRANSPILER_CACHE_PATH=${BUN_RUNTIME_TRANSPILER_CACHE_PATH}

ARG BUN_INSTALL_BIN=/usr/local/bin
ENV BUN_INSTALL_BIN=${BUN_INSTALL_BIN}

RUN apk add libgcc libstdc++ && which bun && bun --version

COPY . .
RUN bun install
RUN bun --bun run build

CMD ["bun", "run", "/app/.output/server/index.mjs" ]