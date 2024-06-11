-include .env

# BuildKit enables higher performance docker builds and caching possibility
# to decrease build times and increase productivity for free.
# https://docs.docker.com/compose/environment-variables/envvars/
export DOCKER_BUILDKIT ?= 1

# Docker binary to use, when executing docker tasks
DOCKER ?= docker

# Binary to use, when executing docker-compose tasks
DOCKER_COMPOSE ?= $(DOCKER) compose

# Support image with all needed binaries, like envsubst, mkcert, wait4x
SUPPORT_IMAGE ?= wayofdev/build-deps:alpine-latest

APP_RUNNER ?= $(DOCKER_COMPOSE) run --rm --no-deps app
APP_COMPOSER ?= $(APP_RUNNER) composer
APP_EXEC ?= $(DOCKER_COMPOSE) exec app

BUILDER_PARAMS ?= docker run --rm -i \
	--env-file ./.env \
	--env APP_NAME=$(APP_NAME) \
	--env SHARED_SERVICES_NAMESPACE=$(SHARED_SERVICES_NAMESPACE) \
	--env COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
	--env COMPOSER_AUTH="$(COMPOSER_AUTH)"

BUILDER ?= $(BUILDER_PARAMS) $(SUPPORT_IMAGE)
BUILDER_WIRED ?= $(BUILDER_PARAMS) --network project.$(COMPOSE_PROJECT_NAME) $(SUPPORT_IMAGE)

# Shorthand wait4x command, executed through build-deps
WAITER ?= $(BUILDER_WIRED) wait4x

# Shorthand envsubst command, executed through build-deps
ENVSUBST ?= $(BUILDER) envsubst

# Yamllint docker image
YAML_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(PWD):/data \
	cytopia/yamllint:latest \
	-c ./.github/.yamllint.yaml \
	-f colored .

ACTION_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/repo \
	 --workdir /repo \
	 rhysd/actionlint:latest \
	 -color

MARKDOWN_LINT_RUNNER ?= $(DOCKER) run --rm $$(tty -s && echo "-it" || echo) \
	-v $(shell pwd):/app \
	--workdir /app \
	davidanson/markdownlint-cli2-rules:latest \
	--config ".github/.markdownlint.json"

PHIVE_RUNNER ?= $(DOCKER_COMPOSE) run --rm --no-deps app

EXPORT_VARS = '\
	$${APP_NAME} \
	$${COMPOSE_PROJECT_NAME} \
	$${SHARED_SERVICES_NAMESPACE} \
	$${COMPOSER_AUTH}'

#
# Self documenting Makefile code
# ------------------------------------------------------------------------------------
ifneq ($(TERM),)
	BLACK := $(shell tput setaf 0)
	RED := $(shell tput setaf 1)
	GREEN := $(shell tput setaf 2)
	YELLOW := $(shell tput setaf 3)
	LIGHTPURPLE := $(shell tput setaf 4)
	PURPLE := $(shell tput setaf 5)
	BLUE := $(shell tput setaf 6)
	WHITE := $(shell tput setaf 7)
	RST := $(shell tput sgr0)
else
	BLACK := ""
	RED := ""
	GREEN := ""
	YELLOW := ""
	LIGHTPURPLE := ""
	PURPLE := ""
	BLUE := ""
	WHITE := ""
	RST := ""
endif
MAKE_LOGFILE = /tmp/wayofdev-laravel-starter-tpl.log
MAKE_CMD_COLOR := $(BLUE)

default: all

help: ## Show this menu
	@echo 'Management commands for project:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Prepares and spins up project with default settings'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Project                 laravel-starter-tpl (https://github.com/wayofdev/laravel-starter-tpl)'
	@echo '    🤠 Author                  Andrij Orlenko (https://github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (https://github.com/wayofdev)${RST}'
	@echo
.PHONY: help

.EXPORT_ALL_VARIABLES:

#
# Default action
# Defines default command when `make` is executed without additional parameters
# ------------------------------------------------------------------------------------
all: hooks install key prepare up
.PHONY: all

#
# System Actions
# ------------------------------------------------------------------------------------
override-create: ## Generate override file from dist
	cp -v docker-compose.override.yaml.dist docker-compose.override.yaml
.PHONY: override-create

env: ## Generate .env file from example, use `make env force=true`, to force re-create file
ifeq ($(FORCE),true)
	@echo "${YELLOW}Force re-creating .env file from example...${RST}"
	$(ENVSUBST) $(EXPORT_VARS) < ./.env.example > ./.env
else ifneq ("$(wildcard ./.env)","")
	@echo ""
	@echo "${YELLOW}The .env file already exists! Use FORCE=true to re-create.${RST}"
else
	@echo "Creating .env file from example"
	$(ENVSUBST) $(EXPORT_VARS) < ./.env.example > ./.env
endif
.PHONY: env

key: ## Runs artisan command to create app encryption key
	$(APP_RUNNER) php artisan key:generate
.PHONY: key

prepare:
	mkdir -p app/.build/php-cs-fixer
.PHONY: prepare

#
# Docker Actions
# ------------------------------------------------------------------------------------
up: # Creates and starts containers, defined in docker-compose and override file
	$(DOCKER_COMPOSE) up --remove-orphans -d
	@sleep 1
	$(DOCKER_COMPOSE) exec app wait4x postgresql 'postgres://${DB_USERNAME}:${DB_PASSWORD}@database:5432/${DB_DATABASE}?sslmode=disable' -t 1m
.PHONY: up

down: # Stops and removes containers of this project
	$(DOCKER_COMPOSE) down --remove-orphans
.PHONY: down

purge: ## Stops and removes containers, volumes, networks and images
	$(DOCKER_COMPOSE) down --remove-orphans --volumes
	$(DOCKER) network prune --force
	$(DOCKER) volume prune --force
	$(DOCKER) image prune --force
.PHONY: purge

restart: down up ## Runs down and up commands
.PHONY: restart

clean: ## Stops and removes containers of this project together with volumes
	$(DOCKER_COMPOSE) rm --force --stop --volumes
.PHONY: clean

ps: ## List running project containers
	$(DOCKER_COMPOSE) ps
.PHONY: ps

logs: ## Show project docker logs with follow up mode enabled
	$(DOCKER_COMPOSE) logs -f
.PHONY: logs

pull: ## Pull and update docker images in this project
	$(DOCKER_COMPOSE) pull
.PHONY: pull

ssh: ## Login inside running docker container
	$(APP_EXEC) sh
.PHONY: ssh

#
# Composer Commands
# ------------------------------------------------------------------------------------
install: ## Install composer dependencies
	$(APP_COMPOSER) install
.PHONY: install

update: ## Update composer dependencies
	$(APP_COMPOSER) update $(package)
.PHONY: update

du: ## Dump composer autoload
	$(APP_COMPOSER) dump-autoload
.PHONY: du

show: ## Shows information about installed composer packages
	$(APP_COMPOSER) show
.PHONY: show

phive: ## Installs dependencies with phive
	$(APP_RUNNER) /usr/local/bin/phive install --trust-gpg-keys 0xC00543248C87FB13,0x033E5F8D801A2F8D,0x47436587D82C4A39
.PHONY: phive

#
# Code Quality, Git, Linting
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit install --hook-type commit-msg
	pre-commit autoupdate
.PHONY: hooks

lint: lint-yaml lint-actions lint-md lint-php lint-stan lint-composer lint-audit ## Runs all linting commands
.PHONY: lint

lint-yaml: ## Lints yaml files inside project
	@$(YAML_LINT_RUNNER) | tee -a $(MAKE_LOGFILE)
.PHONY: lint-yaml

lint-actions: ## Lint all github actions
	@$(ACTION_LINT_RUNNER) | tee -a $(MAKE_LOGFILE)
.PHONY: lint-actions

lint-md: ## Lint all markdown files using markdownlint-cli2
	@$(MARKDOWN_LINT_RUNNER) --fix "**/*.md" "!CHANGELOG.md" "!app/vendor" "!app/node_modules" | tee -a $(MAKE_LOGFILE)
.PHONY: lint-md

lint-md-dry: ## Lint all markdown files using markdownlint-cli2 in dry-run mode
	@$(MARKDOWN_LINT_RUNNER) "**/*.md" "!CHANGELOG.md" "!app/vendor" "!app/node_modules" | tee -a $(MAKE_LOGFILE)
.PHONY: lint-md-dry

lint-php: ## Lints php files inside project using php-cs-fixer
	$(APP_COMPOSER) cs:fix
.PHONY: lint-php

lint-diff: ## Shows diff of php-cs-fixer
	$(APP_COMPOSER) cs:diff
.PHONY: lint-diff

lint-stan:
	$(APP_COMPOSER) stan
.PHONY: lint-stan

lint-stan-ci: ## Runs phpstan – static analysis tool with github output (CI mode)
	$(APP_COMPOSER) stan:ci
.PHONY: lint-stan-ci

lint-stan-baseline: ## Runs phpstan to update its baseline
	$(APP_COMPOSER) stan:baseline
.PHONY: lint-stan-baseline

lint-psalm: ## Runs vimeo/psalm – static analysis tool
	$(APP_COMPOSER) psalm
.PHONY: lint-psalm

lint-psalm-ci: ## Runs vimeo/psalm – static analysis tool with github output (CI mode)
	$(APP_COMPOSER) psalm:ci
.PHONY: lint-psalm-ci

lint-psalm-baseline: ## Runs vimeo/psalm to update its baseline
	$(APP_COMPOSER) psalm:baseline
.PHONY: lint-psalm-baseline

lint-deps: ## Runs composer-require-checker – checks for dependencies that are not used
	$(APP_RUNNER) .phive/composer-require-checker check \
		--config-file=/app/composer-require-checker.json \
		--verbose
.PHONY: lint-deps

lint-deptrac: ## Runs deptrac – static analysis tool
	$(APP_RUNNER) .phive/deptrac analyse --config-file=deptrac.yaml -v --cache-file=.build/.deptrac.cache
.PHONY: lint-deptrac

lint-deptrac-ci: ## Runs deptrac – static analysis tool with github output (CI mode)
	$(APP_RUNNER) .phive/deptrac analyse --config-file=deptrac.yaml -v --cache-file=.build/.deptrac.cache --formatter github-actions
.PHONY: lint-deptrac-ci

lint-deptrac-gv: ## Runs deptrac – static analysis tool and generates graphviz image
	$(APP_RUNNER) .phive/deptrac analyse --config-file=deptrac.yaml -v --cache-file=.build/.deptrac.cache --formatter graphviz-image --output ../assets/deptrac.svg
.PHONY: lint-deptrac-gv

lint-composer: ## Normalize composer.json and composer.lock files
	$(APP_RUNNER) .phive/composer-normalize normalize
.PHONY: lint-composer

lint-audit: ## Runs security checks for composer dependencies
	$(APP_COMPOSER) audit --ansi
.PHONY: lint-security

validate-composer: ## Validates composer.json and composer.lock files
	$(APP_COMPOSER) validate --ansi --strict
.PHONY: validate-composer

#
# Testing
# ------------------------------------------------------------------------------------
infect: ## Runs mutation tests with infection/infection
	$(APP_COMPOSER) infect
.PHONY: infect

infect-ci: ## Runs infection – mutation testing framework with github output (CI mode)
	$(APP_COMPOSER) infect:ci
.PHONY: lint-infect-ci

test: ## Run project php-unit and pest tests
	$(APP_COMPOSER) test
.PHONY: test

test-cc: ## Run project php-unit and pest tests in coverage mode and build report
	$(APP_COMPOSER) test:cc
.PHONY: test-cc

api-docs-public: ## Generate openapi docs specification file for public api
	$(APP_EXEC) php artisan open-docs:generate public
.PHONY: api-docs-public

api-docs-admin: ## Generate openapi docs specification file for admin api
	$(APP_EXEC) php artisan open-docs:generate admin
.PHONY: api-docs-admin

#
# Database Commands
# ------------------------------------------------------------------------------------
db-wipe: ## Wipe database
	$(APP_EXEC) php artisan db:wipe
.PHONY: db-wipe

db-refresh: ## Delete migration files, wipe database, create new migrations, run them and seed database
	$(APP_EXEC) php artisan migrate:fresh
.PHONY: db-refresh

db-migrate: ## Run all pending migrations
	$(APP_EXEC) php artisan migrate
.PHONY: db-migrate

#
# Deployer Commands
# ------------------------------------------------------------------------------------
dep-staging:
	$(APP_EXEC) vendor/bin/dep deploy staging
.PHONY: dep-staging

dep-prod:
	$(APP_EXEC) vendor/bin/dep deploy prod
.PHONY: dep-prod

ssh-staging:
	$(APP_EXEC) vendor/bin/dep ssh staging
.PHONY: ssh-staging

ssh-prod:
	$(APP_EXEC) vendor/bin/dep ssh prod
.PHONY: ssh-prod
