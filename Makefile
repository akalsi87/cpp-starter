# Makefile for repo

# variables
REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
BUILD_TYPE ?= Debug
COMPILER ?= gcc

LOCAL_ROOT ?= $(REPO_ROOT)/.local
CMAKE_BUILD_TYPE ?= $(BUILD_TYPE)
VCPKG_ROOT ?= $(LOCAL_ROOT)/vcpkg
VCPKG_BIN := $(VCPKG_ROOT)/vcpkg
PATH := $(VCPKG_ROOT):$(PATH)
CMAKE_BUILD_DIR ?= $(REPO_ROOT)/build/$(CMAKE_BUILD_TYPE)
REPO_NAME ?= $(notdir $(REPO_ROOT))

ifndef VERBOSE
MAKEFLAGS += -s
endif

ifeq ($(COMPILER),gcc)
CC := gcc
CXX := g++
else ifeq ($(COMPILER),clang)
CC := clang
CXX := clang++
else
$(error Unsupported or unknown compiler)
endif

# targets
.DEFAULT_GOAL := build

.PHONY: run
run:
	@>&2 echo "$$ $(ARGS)"
	@$(ARGS) || (echo " -- rc: $$?" && exit 1)

.PHONY: build
build: $(CMAKE_BUILD_DIR)
	@$(MAKE) run ARGS="cmake --build $(CMAKE_BUILD_DIR)"

.PHONY: clean
clean:
	@$(MAKE) run ARGS="rm -fr $(CMAKE_BUILD_DIR)"

.PHONY: test
test: $(CMAKE_BUILD_DIR)
	@$(MAKE) run ARGS="ctest --test-dir $(CMAKE_BUILD_DIR) -VV"

.PHONY: format
format:
	@$(MAKE) run ARGS="git ls-files | egrep '(.hpp|.cpp)$$\' | xargs -r clang-format -i"

.PHONY: help
help:
	@echo "Available targets:"
	@cat $(REPO_ROOT)/Makefile | grep -E '^[a-zA-Z0-9_-]+:' | cut -d: -f1

# prerequisites
$(VCPKG_BIN):
	@test -d "$(VCPKG_ROOT)" || ( \
		echo "$$ git clone https://github.com/microsoft/vcpkg.git $(VCPKG_ROOT)" && \
		git clone "https://github.com/microsoft/vcpkg.git" "$(VCPKG_ROOT)" && \
		cd "$(VCPKG_ROOT)" && \
		echo "$$ ./bootstrap-vcpkg.sh" && \
		./bootstrap-vcpkg.sh \
	)

CmakeConfigArgs ?= \
	-G Ninja \
	-DCMAKE_TOOLCHAIN_FILE=$(VCPKG_ROOT)/scripts/buildsystems/vcpkg.cmake \
	-DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	-DCMAKE_C_COMPILER=$(CC) \
	-DCMAKE_CXX_COMPILER=$(CXX) \
	-DREPO_NAME=$(REPO_NAME) \

$(CMAKE_BUILD_DIR): $(VCPKG_BIN)
	@make run ARGS="cmake -S $(REPO_ROOT) -B $@ $(CmakeConfigArgs)" || (rm -rf $@ && exit 1)
