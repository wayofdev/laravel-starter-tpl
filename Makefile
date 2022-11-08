export DOCKER_BUILDKIT ?= 1
DOCKER_COMPOSE ?= docker-compose
BUILDER_IMAGE ?= wayofdev/build-deps:alpine-latest
ENV_PATH =

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

help:
	@echo 'Management commands for package:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Prepares and spins up project with default settings'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Package                 laravel-starter-tpl (github.com/wayofdev/laravel-starter-tpl)'
	@echo '    🤠 Author                  Andrij Orlenko (github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (github.com/wayofdev)${RST}'
.PHONY: help

all: help
PHONY: all


# System Actions
# ------------------------------------------------------------------------------------
override-create: ## Generate override file from dist
	cp -v docker-compose.override.yaml.dist docker-compose.override.yaml
.PHONY: override-create

env: ## Generate .env file from example, use `make env force=true`, to force re-create file
ifneq ($(force),"")
	@echo "${YELLOW}Force re-creating .env file from example...${RST}"
	@cp -f .env.example .env
else ifneq ("$(wildcard ./.env)","")
	@echo "${YELLOW}The .env file already exists!${RST}"
else
	@echo "Creating .env file from example"
	@cp -f .env.example .env
endif
.PHONY: env


# Docker Actions
# ------------------------------------------------------------------------------------
up:
	$(DOCKER_COMPOSE) up --remove-orphans -d
	$(DOCKER_COMPOSE) exec app wait4x tcp database:5432 -t 1m
.PHONY: up

down:
	$(DOCKER_COMPOSE) down --remove-orphans
.PHONY: down

restart: down up
.PHONY: restart

clean:
	$(DOCKER_COMPOSE) rm --force --stop
.PHONY: clean

ps:
	$(DOCKER_COMPOSE) ps
.PHONY: ps

logs:
	$(DOCKER_COMPOSE) logs -f
.PHONY: logs


# Code Quality, Git, Linting
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit autoupdate
.PHONY: hooks

lint: ## Lints yaml files inside project
	yamllint .
.PHONY: lint
