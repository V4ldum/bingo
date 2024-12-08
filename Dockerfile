# Build
FROM plugfox/flutter:stable-web AS builder

RUN flutter --disable-analytics
RUN dart --disable-analytics

RUN flutter upgrade

WORKDIR /work
COPY . .
COPY ../bingo-env .

RUN dart run build_runner build
RUN flutter build web --release

# Run
FROM nginx:alpine AS runner
COPY --from=builder /work/build/web /usr/share/nginx/html