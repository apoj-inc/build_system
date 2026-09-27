SHELL := /bin/bash
LAUNCH_PYTHON := $(shell ./build_system/utils/collect_lists.py)

TOPLEVEL ?= toplevel

BS_PATH := $(CURDIR)/build_system/vivado

CACHE_DIR ?= $(CURDIR)/.cache
LIST_DIR ?= $(CACHE_DIR)/lists
PROJECT_DIR ?= $(CACHE_DIR)/vivado/$(TOPLEVEL)
VARS_TCL ?= $(PROJECT_DIR)/vars.tcl

FILES_RTL_PATH ?= $(LIST_DIR)/files_rtl.lst
INCDIRS_PATH ?= $(LIST_DIR)/incdirs.lst

FILES_SDC_PATH ?= $(CURDIR)/sdc/lists/files_sdc.lst

FILES_XCI_PATH ?= $(LIST_DIR)/files_xci.lst

DEVICE ?= xc7k325tffg676-2L
DEVICE_NUMBER ?= 0

VERILOG_SOURCES := $(shell cat $(FILES_RTL_PATH) | tr '\n' ' ')
SDC_SOURCES := $(shell cat $(FILES_SDC_PATH) | tr '\n' ' ')
XCI_SOURCES := $(shell cat $(FILES_XCI_PATH) | tr '\n' ' ')

compile: $(PROJECT_DIR)/$(TOPLEVEL).runs/impl_1/$(TOPLEVEL).bit

$(PROJECT_DIR)/$(TOPLEVEL).runs/impl_1/$(TOPLEVEL).bit: $(VERILOG_SOURCES) $(SDC_SOURCES) $(XCI_SOURCES)
	mkdir -p $(PROJECT_DIR)
	cp $(BS_PATH)/setup_xpr.tcl $(PROJECT_DIR)/setup_xpr.tcl

	@echo set TOPLEVEL $(TOPLEVEL) > $(VARS_TCL)
	@echo set REPO_DIR $(CURDIR) >> $(VARS_TCL)
	@echo set FILES_RTL_PATH $(FILES_RTL_PATH) >> $(VARS_TCL)
	@echo set INCDIRS_PATH $(INCDIRS_PATH) >> $(VARS_TCL)
	@echo set FILES_SDC_PATH $(FILES_SDC_PATH) >> $(VARS_TCL)
	@echo set FILES_XCI_PATH $(FILES_XCI_PATH) >> $(VARS_TCL)
	@echo set DEVICE $(DEVICE) >> $(VARS_TCL)

	@cd $(PROJECT_DIR);\
	vivado -mode tcl -source setup_xpr.tcl

program: $(PROJECT_DIR)/$(TOPLEVEL).runs/impl_1/$(TOPLEVEL).bit
	cp $(BS_PATH)/program_device.tcl $(PROJECT_DIR)/program_device.tcl

	grep -qxF "set DEVICE_NUMBER $(DEVICE_NUMBER)" $(VARS_TCL) || echo set DEVICE_NUMBER $(DEVICE_NUMBER) >> $(VARS_TCL)

	@cd $(PROJECT_DIR);\
	vivado -mode tcl -source program_device.tcl

clean:
	rm -rf $(PROJECT_DIR)

clean_all:
	rm -rf $(CACHE_DIR)/vivado