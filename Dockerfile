# Build
FROM debian:bookworm-slim AS builder

RUN apt-get update -qq && \
    apt-get install -y -qq wget bash git xz-utils

RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
RUN tar -xf flutter_linux_3.24.5-stable.tar.xz --no-same-owner

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter --disable-analytics
RUN dart --disable-analytics

RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

WORKDIR /work
COPY . .

RUN dart run build_runner build
RUN flutter build web --release

# Run
FROM nginx:alpine AS runner
COPY --from=builder /work/build/web /usr/share/nginx/html