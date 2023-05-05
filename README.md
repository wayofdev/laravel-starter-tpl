Features:
- Removed
  - removed laravel sanctum
  - removed laravel sail
  - removed laravel pint

## Installation

1. Create `.env` file:

    ```bash
    make env \
      APP_NAME=laravel \
      SHARED_SERVICES_NAMESPACE=ss \
      PROJECT_SERVICES_NAMESPACE=wod \
      COMPOSE_PROJECT_NAME=laravel-starter-tpl
    ```
   add `FORCE=true` to re-create .env from example file

    ```bash
    make env \
      APP_NAME=laravel \
      SHARED_SERVICES_NAMESPACE=ss \
      PROJECT_SERVICES_NAMESPACE=wod \
      COMPOSE_PROJECT_NAME=laravel-starter-tpl \
      FORCE=true
    ```


2. Build, run and install. This will also generate Laravel app key:

    ```bash
    $ make
    ```
