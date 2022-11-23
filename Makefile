-include .env

# BuildKit enables higher performance docker builds and caching possibility
# to decrease build times and increase productivity for free.
export DOCKER_BUILDKIT ?= 1

export COMPOSE_PROJECT_NAME_SAFE=$(subst $e.,_,$(COMPOSE_PROJECT_NAME))
export APP_NAME_SAFE=$(subst $e-,_,$(APP_NAME))
export SHARED_SERVICES_NETWORK = $(addsuffix _network,$(subst $e.,_,$(SHARED_SERVICES_NAMESPACE)))

EXPORT_VARS = '\
	$${APP_NAME} \
	$${APP_NAME_SAFE} \
	$${COMPOSE_PROJECT_NAME} \
	$${COMPOSE_PROJECT_NAME_SAFE} \
	$${PROJECT_SERVICES_NAMESPACE} \
	$${SHARED_SERVICES_NETWORK} \
	$${COMPOSER_AUTH}'

# Binary to use, when executing docker-compose tasks
DOCKER_COMPOSE ?= docker-compose

# Support image with all needed binaries, like envsubst, mkcert, wait4x
SUPPORT_IMAGE ?= wayofdev/build-deps:alpine-latest

BUILDER_PARAMS ?= docker run --rm -i \
	--env-file ./.env \
	--env APP_NAME=$(APP_NAME) \
	--env APP_NAME_SAFE=$(APP_NAME_SAFE) \
	--env COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
	--env COMPOSE_PROJECT_NAME_SAFE=$(COMPOSE_PROJECT_NAME_SAFE) \
	--env PROJECT_SERVICES_NAMESPACE=$(PROJECT_SERVICES_NAMESPACE) \
	--env SHARED_SERVICES_NETWORK=$(SHARED_SERVICES_NETWORK) \
	--env COMPOSER_AUTH="$(COMPOSER_AUTH)"

BUILDER ?= $(BUILDER_PARAMS) $(SUPPORT_IMAGE)
BUILDER_WIRED ?= $(BUILDER_PARAMS) --network $(COMPOSE_PROJECT_NAME)_default $(SUPPORT_IMAGE)

# Shorthand wait4x command, executed through build-deps
WAITER ?= $(BUILDER_WIRED) wait4x

# Shorthand envsubst command, executed through build-deps
ENVSUBST ?= $(BUILDER) envsubst

APP_RUNNER ?= $(DOCKER_COMPOSE) run --rm --no-deps app
APP_EXEC ?= $(DOCKER_COMPOSE) run app
APP_CONSOLE ?= $(APP_RUNNER) php artisan
APP_COMPOSER = $(APP_RUNNER) composer


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
all: help
PHONY: all


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
	$(APP_EXEC) php artisan key:generate
.PHONY: key

mkcert: ## Generate DH param and SSL certs
	openssl dhparam -out certs/dhparam.pem 2048
.PHONY: mkcert

prepare:
	mkdir -p .build/php-cs-fixer
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


# Code Quality, Git, Linting
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit autoupdate
.PHONY: hooks

lint: ## Lints yaml files inside project
	yamllint .
.PHONY: lint

cs-diff:
	$(APP_COMPOSER) cs-diff
.PHONY: cs-diff

cs-fix:
	$(APP_COMPOSER) cs-fix
.PHONY: cs-fix

stan:
	$(APP_COMPOSER) run-script stan
.PHONY: stan


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



