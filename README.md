# docker-php-environment

> **Note**: This guide is based on the [Docker Docs - PHP language-specific guide](https://docs.docker.com/guides/php/).

## Prerequisites

- Docker with Docker Compose.

## Setup

### Configuring the Environment

To start a new PHP project from this template:

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Set the environment variables in `.env`:
   ```env
   PHP_VERSION=
   APP_PORT=
   PMA_PORT=
   DB_NAME=
   ```

   > **Note**: Port `9000` is the convention for the PHP application (`APP_PORT`) and `8080` for phpMyAdmin (`PMA_PORT`).

3. Create the database password file:
   ```bash
   echo "<password>" > db/password.txt
   ```

   > **Note**: `db/password.txt` is mounted as a Docker secret and is excluded from version control.

4. Build and start the environment:
   ```bash
   docker compose up --build
   ```

5. Verify the containers are running:
   ```bash
   docker compose ps
   ```

> **Note**: The application is served at http://localhost:9000 and phpMyAdmin at http://localhost:8080.

## Usage

Place PHP files in `src/` to serve them via Apache. Place test files in `tests/` for PHPUnit.

### Live Reload

To sync source file changes into the container without rebuilding:

```bash
docker compose up --watch
```

### Running Tests

To run the PHPUnit test suite:

```bash
docker compose run --rm server vendor/bin/phpunit tests/
```

### Stopping the Environment

To stop and remove containers:

```bash
docker compose down
```
