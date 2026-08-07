FROM dart:stable AS build
WORKDIR /work

# Flutter
ADD --keep-git-dir=true https://github.com/flutter/flutter.git#stable /flutter
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
