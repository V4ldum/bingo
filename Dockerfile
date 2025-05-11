# Build
FROM dart:stable AS builder
WORKDIR /work
COPY . .

RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN dart --disable-analytics
RUN flutter --disable-analytics
RUN flutter channel stable > /dev/null 2>&1
RUN flutter upgrade > /dev/null 2>&1
RUN flutter config --enable-web 2>&1

RUN dart run build_runner build | grep -Ev "^\[INFO\]"
RUN flutter build web --release > /dev/null 2>&1

# Run
FROM nginx:alpine-slim AS runner
# Update nginx config
RUN sed -i '/location \/ {/,/}/s|^\(.*index  index.html index.htm;\)|\1\n        try_files \$uri \$uri/ \$uri.html /index.html;|' /etc/nginx/conf.d/default.conf

COPY --from=builder /work/build/web /usr/share/nginx/html