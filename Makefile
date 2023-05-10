-include .env

# BuildKit enables higher performance docker builds and caching possibility
# to decrease build times and increase productivity for free.
# https://docs.docker.com/compose/environment-variables/envvars/
export DOCKER_BUILDKIT ?= 1

# Binary to use, when executing docker-compose tasks
DOCKER_COMPOSE ?= docker compose

# Support image with all needed binaries, like envsubst, mkcert, wait4x
SUPPORT_IMAGE ?= wayofdev/build-deps:alpine-latest

APP_RUNNER ?= $(DOCKER_COMPOSE) run --rm --no-deps app
APP_EXEC ?= $(DOCKER_COMPOSE) exec app
APP_COMPOSER ?= $(APP_RUNNER) composer

BUILDER_PARAMS ?= docker run --rm -i \
	--env-file ./.env \
	--env APP_NAME=$(APP_NAME) \
	--env SHARED_SERVICES_NAMESPACE=$(SHARED_SERVICES_NAMESPACE) \
	--env PROJECT_SERVICES_NAMESPACE=$(PROJECT_SERVICES_NAMESPACE) \
	--env COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
	--env COMPOSER_AUTH="$(COMPOSER_AUTH)"

BUILDER ?= $(BUILDER_PARAMS) $(SUPPORT_IMAGE)
BUILDER_WIRED ?= $(BUILDER_PARAMS) --network $(COMPOSE_PROJECT_NAME)_default $(SUPPORT_IMAGE)

# Shorthand wait4x command, executed through build-deps
WAITER ?= $(BUILDER_WIRED) wait4x

# Shorthand envsubst command, executed through build-deps
ENVSUBST ?= $(BUILDER) envsubst

EXPORT_VARS = '\
	$${APP_NAME} \
	$${COMPOSE_PROJECT_NAME} \
	$${PROJECT_SERVICES_NAMESPACE} \
	$${SHARED_SERVICES_NAMESPACE} \
	$${COMPOSER_AUTH}'


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
MAKE_LOGFILE = /tmp/laravel-starter-tpl.log
MAKE_CMD_COLOR := $(BLUE)

default: all

help: ## Show this menu
	echo ${MAKEFILE_LIST}

	@echo 'Management commands for package:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Prepares and spins up project with default settings'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Package                 laravel-starter-tpl (github.com/wayofdev/laravel-starter-tpl)'
	@echo '    🤠 Author                  Andrij Orlenko (github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (github.com/wayofdev)${RST}'
.PHONY: help

.EXPORT_ALL_VARIABLES:

# Default action
# Defines default command when `make` is executed without additional parameters
# ------------------------------------------------------------------------------------
all: hooks key prepare up
.PHONY: all


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


# Docker Actions
# ------------------------------------------------------------------------------------
up: # Creates and starts containers, defined in docker-compose and override file
	$(DOCKER_COMPOSE) up --remove-orphans -d
	$(DOCKER_COMPOSE) exec app wait4x tcp database:5432 -t 1m
.PHONY: up

down: # Stops and removes containers of this project
	$(DOCKER_COMPOSE) down --remove-orphans
.PHONY: down

restart: down up ## Runs down and up commands
.PHONY: restart

clean: ## Stops containers if required and removes from system
	$(DOCKER_COMPOSE) rm --force --stop
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


# Code Quality, Git, Linting, Testing
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit autoupdate
.PHONY: hooks

lint-yaml: ## Lints yaml files inside project
	yamllint .
.PHONY: lint-yaml

lint-php: ## Lints php files inside project using php-cs-fixer
	$(APP_COMPOSER) run-script cs:fix
.PHONY: lint-php

lint-diff: ## Shows diff of php-cs-fixer
	$(APP_COMPOSER) run-script cs:diff
.PHONY: lint-diff

lint-stan:
	$(APP_COMPOSER) run-script stan
.PHONY: lint-stan

test: ## Run project php-unit and pest tests
	$(APP_COMPOSER) test
.PHONY: test

test-cc: ## Run project php-unit and pest tests in coverage mode and build report
	$(APP_COMPOSER) test:cc
.PHONY: test-cc


# Composer Commands
# ------------------------------------------------------------------------------------
install: ## Install composer dependencies
	$(APP_COMPOSER) install
.PHONY: install

update: ## Update composer dependencies
	$(APP_COMPOSER) update $(package)
.PHONY: update

show: ## Shows information about installed composer packages
	$(APP_COMPOSER) show
.PHONY: show


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
