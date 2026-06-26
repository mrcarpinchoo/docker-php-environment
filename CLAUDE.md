# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

A personal PHP development environment template. Clone this repo for each new PHP project — do not add multiple projects to one clone. Each clone gets its own isolated stack (PHP + Apache, MariaDB, phpMyAdmin).

## First-Time Setup Per Clone

1. Copy `.env.example` to `.env` and fill in all values — `DB_NAME` has no default and is required.
2. Create `db/password.txt` with a password string — this file is excluded from git and mounted as a Docker secret.

## Commands

```sh
# Build and start all services
docker compose up --build

# Start with live file sync (no rebuild on src/ changes)
docker compose up --watch

# Run PHPUnit tests
docker compose run --rm server vendor/bin/phpunit tests/

# Stop and remove containers
docker compose down
```

## Architecture

**Dockerfile** uses four stages:

| Stage | Base | Purpose |
|---|---|---|
| `prod-deps` | `composer:lts` | Installs production Composer dependencies |
| `dev-deps` | `composer:lts` | Installs all dependencies including PHPUnit |
| `base` | `php:${PHP_VERSION}-apache` | Runtime with `pdo` and `pdo_mysql` extensions; copies `src/` to `/var/www/html` |
| `development` | `base` | Adds `tests/` and full vendor; used by docker compose |
| `final` | `base` | Production image; runs as `www-data` |

`docker-compose.yml` always targets the `development` stage and defines three services: `server` (PHP + Apache), `db` (MariaDB), and `phpmyadmin`.

**Configuration** is driven by `.env` (gitignored). Variables and their defaults:

| Variable | Default | Notes |
|---|---|---|
| `PHP_VERSION` | `8.2` | Passed as a build arg to the Dockerfile |
| `APP_PORT` | `9000` | Host port for the PHP app |
| `PMA_PORT` | `8080` | Host port for phpMyAdmin |
| `DB_NAME` | *(none)* | Required — no fallback |

**Database password** uses Docker Secrets: `db/password.txt` is mounted inside the container at `/run/secrets/db-password`. The app reads the password from the file path set in `PASSWORD_FILE_PATH`, not from a plain environment variable.

## Project Structure

- `src/` — Apache web root. Add PHP files here; they are live-synced into the container with `--watch`.
- `tests/` — PHPUnit test files.
- `db/` — Contains `password.txt`. Gitignored entirely.
