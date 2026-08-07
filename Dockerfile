FROM alpine AS version

# Query the most recent Flutter stable version
# New Beta releases will invalidate cache, so we do it in its own layer to avoid invalidating the build layers
ADD https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json releases.json
RUN awk -F'"' '$2=="stable" && !s {s=$4} s && $2=="hash" && $4==s {f=1} f && $2=="channel" && $4!="stable" {f=0} f && $2=="version" {print $4, s; exit}' releases.json > /flutter-stable && \
    test -s /flutter-stable


FROM dart:stable AS build
WORKDIR /work

# Flutter
# Invalidates cache on version change
COPY --from=version flutter-stable flutter-stable
RUN set -x; read -r version sha < /tmp/flutter-stable && \
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


FROM nginxinc/nginx-unprivileged:alpine-slim
# Update nginx config
RUN sed -i '/location \/ {/,/}/s|^\(.*index  index.html index.htm;\)|\1\n        try_files \$uri \$uri/ \$uri.html /index.html;|' /etc/nginx/conf.d/default.conf

COPY --from=build /work/build/web /usr/share/nginx/html
