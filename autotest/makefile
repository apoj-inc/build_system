SHELL := /bin/bash
LAUNCH_PYTHON := $(shell ./build_system/utils/collect_lists.py)

AUTOTEST_DIR := $(CURDIR)/build_system/autotest

CACHE_DIR ?= $(CURDIR)/.cache
VENV_DIR ?= $(CACHE_DIR)/.venv
COCOTB_DIR ?= $(CACHE_DIR)/cctb

LIST_DIR ?= $(CACHE_DIR)/lists

INCDIRS_PATH ?= $(LIST_DIR)/incdirs.lst
INCLUDE_DIRS ?= $(foreach file,$(shell cat $(INCDIRS_PATH) | grep -v "#"),$(CURDIR)/$(file))

LIST_RTL ?= $(LIST_DIR)/files_rtl.lst
VERILOG_SOURCES ?= $(foreach file,$(shell cat $(LIST_RTL) | grep -v "#"),$(CURDIR)/$(file))

TB_DIR ?= $(CURDIR)/tb
TESTS_DIRS ?= $(sort $(dir $(wildcard $(TB_DIR)/tb_*/)))
TB_FILES ?=  $(foreach file,$(shell find $(TB_DIR)/tb_* -type f -name '*.sv'),$(file))

BUILD_DIR   ?= $(COCOTB_DIR)
TESTS_DIR   ?= $(BUILD_DIR)/tests
LOGS_DIR    ?= $(TESTS_DIR)/logs
RESULTS_DIR ?= ${LOGS_DIR}/results

SIM ?= questa-qisqrun
BUILD_ARGS ?= -suppress 13314 -suppress 14408
SIM_ARGS ?= -suppress 12110 -autofindloop -suppress 12130

ARGS ?=

.PHONY: all run_pytest clean
all: run_pytest

run_pytest: $(VENV_DIR)/bin/activate
	@export TESTS_DIRS="$(TESTS_DIRS)"; \
	export INCLUDE_DIRS="$(INCLUDE_DIRS)"; \
	export VERILOG_SOURCES="$(VERILOG_SOURCES) $(TB_FILES)"; \
	export LOGS_DIR=${LOGS_DIR}; \
	export RESULTS_DIR=${RESULTS_DIR}; \
	export TESTS_DIR=${TESTS_DIR}; \
	export BUILD_DIR="$(BUILD_DIR)"; \
	export BUILD_ARGS="$(BUILD_ARGS)"; \
	export SIM_ARGS="$(SIM_ARGS)"; \
	source $(VENV_DIR)/bin/activate; \
	python3 -m pytest --junit-xml=${RESULTS_DIR}/all.xml $(ARGS)

$(VENV_DIR)/bin/activate : $(AUTOTEST_DIR)/requirements.txt
	python3 -m venv $(VENV_DIR)
	source $(VENV_DIR)/bin/activate; \
	pip install -r $(AUTOTEST_DIR)/requirements.txt

clean:
	@rm -rf $(CURDIR)/.cache \
	$(CURDIR)/.pytest_cache \
	$(CURDIR)/tests/__pycache__ \
	$(CURDIR)/qrun.log \
	$(CURDIR)/modelsim.ini \
	$(CURDIR)/transcript
	@make -f $(QUARTUS_MAKEFILE) clean_releases

