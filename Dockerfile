## FLUTTER VERSION ##
FROM alpine AS version

RUN apk add --no-cache jq

# Query the most recent Flutter stable version
# New Beta releases will invalidate cache, so we do it in its own layer to avoid invalidating the build layers
ADD https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json releases.json
RUN jq -r '.current_release.stable as $sha | first(.releases[] | select(.hash == $sha and .channel == "stable")) | "\(.version) \($sha)"' releases.json > /flutter-stable && \
    test -s /flutter-stable


## BUILD ##
FROM dart:stable AS build
WORKDIR /work

# Flutter
# Invalidates cache on version change
COPY --from=version flutter-stable flutter-stable
RUN set -x; read -r version sha < flutter-stable && \
    git clone --depth 1 --branch "$version" https://github.com/flutter/flutter.git /flutter && \
    test "$(git -C /flutter rev-parse HEAD)" = "$sha"
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Config
RUN flutter config --no-analytics --enable-web && \
    flutter precache --web

# Dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Build
COPY . .
RUN dart run build_runner build
RUN flutter build web --release


## RUN ##
FROM nginxinc/nginx-unprivileged:alpine-slim
COPY --from=build /work/build/web /usr/share/nginx/html
