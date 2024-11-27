FROM oven/bun

WORKDIR /app

COPY . .
RUN bun install
RUN bun --bun run build

CMD ["bun", "run", "/app/.output/server/index.mjs" ]
