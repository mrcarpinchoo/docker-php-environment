# syntax=docker/dockerfile:1

ARG PHP_VERSION=8.5

# Stage: prod-deps - use the official Composer image (LTS) just to install PHP dependencies
FROM composer:lts as prod-deps
WORKDIR /app
# Install only production dependencies (no dev packages)
RUN --mount=type=bind,source=./composer.json,target=composer.json \
    --mount=type=bind,source=./composer.lock,target=composer.lock \
    --mount=type=cache,target=/tmp/cache \
    composer install --no-dev --no-interaction

# Stage: dev-deps - same idea, but install full dependencies (including dev/test packages)
FROM composer:lts as dev-deps
WORKDIR /app
RUN --mount=type=bind,source=./composer.json,target=composer.json \
    --mount=type=bind,source=./composer.lock,target=composer.lock \
    --mount=type=cache,target=/tmp/cache \
    composer install --no-interaction

# Stage: base - common runtime base: PHP + Apache built in
FROM php:${PHP_VERSION}-apache as base
# Install PHP extensions needed to talk to MySQL via PDO
RUN docker-php-ext-install pdo pdo_mysql
# Copy application source code into the web root
COPY ./src /var/www/html

# Stage: development - image intended for local/dev use, built on top of "base"
FROM base as development
# Include test suite (not wanted in production image)
COPY ./tests /var/www/html/tests
# Use PHP's development php.ini (more verbose errors, less optimized)
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
# Pull in vendor/ directory built by the dev-deps stage (full dependencies)
COPY --from=dev-deps app/vendor/ /var/www/html/vendor

# Stage: final - production image, also built on top of "base"
FROM base as final
# Use PHP's production php.ini (optimized, less verbose errors)
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# Pull in vendor/ directory built by the prod-deps stage (prod-only dependencies)
COPY --from=prod-deps app/vendor/ /var/www/html/vendor
# Drop root privileges - run the container as the unprivileged www-data user
USER www-data