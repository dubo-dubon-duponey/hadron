# Ouch - necessary for extended globbing (eg: !) to work
SHELL=/bin/bash -O extglob -c

DC_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Output directory
DC_PREFIX ?= $(shell pwd)

# Set to true to disable fancy / colored output
DC_NO_FANCY ?=

# List of dckr platforms to test
# make on debian-10 has no order guarantee on files, which breaks the builder here
DCKR_PLATFORMS ?= debian-11 debian-12 debian-current debian-next ubuntu-1404 ubuntu-1604 ubuntu-1804 ubuntu-2004 ubuntu-2204 ubuntu-current ubuntu-next alpine-316 alpine-317 alpine-318 alpine-319 alpine-next

# Fancy output if interactive
ifndef DC_NO_FANCY
    NC := \033[0m
    GREEN := \033[1;32m
    ORANGE := \033[1;33m
    BLUE := \033[1;34m
    RED := \033[1;31m
endif

# Helper to put out nice title
define title
	@printf "$(GREEN)----------------------------------------------------------------------------------------------------\n"
	@printf "$(GREEN)%*s\n" $$(( ( $(shell echo "☆ $(1) ☆" | wc -c ) + 100 ) / 2 )) "☆ $(1) ☆"
	@printf "$(GREEN)----------------------------------------------------------------------------------------------------\n$(ORANGE)"
endef

define footer
	@printf "$(GREEN)> %s: done!\n" "$(1)"
	@printf "$(GREEN)____________________________________________________________________________________________________\n$(NC)"
endef

DC_AUTHOR := Dubo Dubon Duponey
DC_LICENSE := MIT License

#######################################################
# Targets
#######################################################
all: build lint test test-all

# Make happy
.PHONY: bootstrap build-binaries lint-signed lint-code test-unit test-integration test-all build lint test clean

DC_TOOLING := $(DC_PREFIX)/bin/tooling

#######################################################
# Base private tasks
#######################################################
# Build dc-tooling and library
bootstrap:
	$(call title, $@)
	DC_PREFIX=$(DC_TOOLING) make -s -f $(DC_MAKEFILE_DIR)/sh-art/Makefile build-tooling build-library
	$(call footer, $@)

#######################################################
# Base building tasks
#######################################################
# Builds the main library
$(DC_PREFIX)/lib/lib-hadron: $(DC_TOOLING)/lib/lib-dc-sh-art $(DC_MAKEFILE_DIR)/source/core/*.sh
	$(call title, $@)
	$(DC_TOOLING)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="the library version" --with-git-info $^
	$(call footer, $@)

$(DC_PREFIX)/lib/lib-hadron-strip: $(DC_MAKEFILE_DIR)/source/core/*.sh
	$(call title, $@)
	$(DC_TOOLING)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="the library version" --with-git-info $^
	$(call footer, $@)

# Builds all the CLIs that depend just on the main library
$(DC_PREFIX)/bin/%: $(DC_PREFIX)/lib/lib-hadron $(DC_MAKEFILE_DIR)/source/cli/%
	$(call title, $@)
	$(DC_TOOLING)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^
	$(call footer, $@)

# Builds all the CLIs that depend on the main library and extensions
$(DC_PREFIX)/bin/%: $(DC_TOOLING)/lib/lib-dc-sh-art $(DC_TOOLING)/lib/lib-dc-sh-art-extensions $(DC_MAKEFILE_DIR)/source/core/*.sh $(DC_MAKEFILE_DIR)/source/cli-ext/%
	$(call title, $@)
	$(DC_TOOLING)/bin/dc-tooling-build --destination="$(shell dirname $@)" --name="$(shell basename $@)" --license="MIT License" --author="dubo-dubon-duponey" --description="another fancy piece of shcript" $^
	$(call footer, $@)

#######################################################
# Tasks to be called on
#######################################################

# High-level task to build the library
build-library: bootstrap $(DC_PREFIX)/lib/lib-hadron # $(DC_PREFIX)/lib/lib-hadron-strip

# High-level task to build all CLIs
build-binaries: build-library $(patsubst $(DC_MAKEFILE_DIR)/source/cli-ext/%/cmd.sh,$(DC_PREFIX)/bin/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-ext/*/cmd.sh)) \
				$(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,$(DC_PREFIX)/bin/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh))

# Git sanity
lint-signed: bootstrap
	$(call title, $@)
	$(DC_TOOLING)/bin/dc-tooling-git $(DC_MAKEFILE_DIR)
	$(call footer, $@)

# Linter
lint-code: bootstrap build-library build-binaries
	$(call title, $@)
	$(DC_TOOLING)/bin/dc-tooling-lint $(DC_MAKEFILE_DIR)/source
	$(DC_TOOLING)/bin/dc-tooling-lint $(DC_MAKEFILE_DIR)/tests
	$(DC_TOOLING)/bin/dc-tooling-lint $(DC_PREFIX)/lib
	$(DC_TOOLING)/bin/dc-tooling-lint $(DC_PREFIX)/bin/!(tooling)
	$(call footer, $@)

# Unit tests
unit/%: bootstrap build-library
	$(call title, $@)
	$(DC_TOOLING)/bin/dc-tooling-test $(DC_MAKEFILE_DIR)/tests/$@
	$(call footer, $@)

test-unit: $(patsubst $(DC_MAKEFILE_DIR)/tests/unit/%,unit/%,$(wildcard $(DC_MAKEFILE_DIR)/tests/unit/*.sh))

# Integration tests
integration/%: bootstrap $(DC_PREFIX)/bin/%
	$(call title, $@)
	PATH="$(DC_PREFIX)/bin:${PATH}" $(DC_TOOLING)/bin/dc-tooling-test $(DC_MAKEFILE_DIR)/tests/$@/*.sh
	$(call footer, $@)

test-integration: build-binaries $(patsubst $(DC_MAKEFILE_DIR)/source/cli/%/cmd.sh,integration/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli/*/cmd.sh)) \
	$(patsubst $(DC_MAKEFILE_DIR)/source/cli-ext/%/cmd.sh,integration/%,$(wildcard $(DC_MAKEFILE_DIR)/source/cli-ext/*/cmd.sh))

dckr/%:
	$(call title, $@)
	DOCKERFILE=./dckr.Dockerfile TARGET="$(patsubst dckr/%,%,$@)" dckr make test
	$(call footer, $@)

test-all: $(patsubst %,dckr/%,$(DCKR_PLATFORMS))

build: build-library build-binaries
lint: lint-code lint-signed
test: test-unit test-integration

# Simple clean: rm bin & lib
clean:
	$(call title, $@)
	rm -Rf "${DC_PREFIX}/bin"
	rm -Rf "${DC_PREFIX}/lib"
	$(call footer, $@)
