# Build
FROM debian:bookworm-slim AS builder
#FROM alpine AS builder

RUN apt-get update -qq && \
    apt-get install -y -qq git curl unzip

RUN git clone https://github.com/flutter/flutter.git
RUN /flutter/bin/flutter

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