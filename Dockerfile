# Build
FROM debian:bookworm-slim AS builder

RUN apt-get update -qq && \
    apt-get install -y -qq git curl unzip

RUN git clone https://github.com/flutter/flutter.git
RUN /flutter/bin/flutter

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter --disable-analytics
RUN dart --disable-analytics

RUN flutter channel stable > /dev/null 2>&1
RUN flutter upgrade > /dev/null 2>&1
RUN flutter config --enable-web 2>&1

WORKDIR /work
COPY . .

RUN dart run build_runner build | grep -Ev "^\[INFO\]"
RUN flutter build web --release > /dev/null 2>&1

# Run
FROM nginx:alpine AS runner
# Update nginx config
RUN sed -i '/location \/ {/,/}/s|^\(.*index  index.html index.htm;\)|\1\n        try_files \$uri \$uri/ \$uri.html /index.html;|' /etc/nginx/conf.d/default.conf
COPY --from=builder /work/build/web /usr/share/nginx/html