FROM dart:stable AS build
WORKDIR /work
COPY . .

# Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Config
RUN dart --disable-analytics
RUN flutter --disable-analytics
RUN flutter channel stable > /dev/null 2>&1
RUN flutter upgrade > /dev/null 2>&1
RUN flutter config --enable-web 2>&1

# Build
RUN dart run build_runner build | grep -Ev "^\[INFO\]"
RUN flutter build web --release > /dev/null 2>&1


FROM nginx:alpine-slim
# Update nginx config
RUN sed -i '/location \/ {/,/}/s|^\(.*index  index.html index.htm;\)|\1\n        try_files \$uri \$uri/ \$uri.html /index.html;|' /etc/nginx/conf.d/default.conf

COPY --from=build /work/build/web /usr/share/nginx/html
