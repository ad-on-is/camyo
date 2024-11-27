FROM oven/bun:alpine

WORKDIR /app

ARG BUN_RUNTIME_TRANSPILER_CACHE_PATH=0
ENV BUN_RUNTIME_TRANSPILER_CACHE_PATH=${BUN_RUNTIME_TRANSPILER_CACHE_PATH}

ARG BUN_INSTALL_BIN=/usr/local/bin
ENV BUN_INSTALL_BIN=${BUN_INSTALL_BIN}
COPY package.json .
RUN bun install
COPY . .
RUN bun --bun run build

CMD ["bun", "run", "/app/.output/server/index.mjs" ]
