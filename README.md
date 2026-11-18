# Build system

## Synopsis

`build_system` is a centralized collection of scripts and makefiles that allows for launching common operations of FPGA tools using a single line in CLI.

Platform - Linux, OS tested in - Ubuntu 22.04.

Currently supported tools and their operations:

- Quartus - compile and load bitstream into SRAM;
- Vivado - compile and load bitstream into SRAM;
- Cocotb - use Questa for running testbenches;
- Pytest - launch a chosen collection of testbenches using Cocotb.

Functions present in the directory but not supported:

- Questa - launch testbenches directly in Questa.

All of the user-written HDL should be in SystemVerilog.

## Usage

### Adding build system to your project

`build_system` should be located in the root directory of the repository. One of the possible ways to get it there is to add it as a submodule:

```bash
$ pwd
<repository rootdir>

$ git submodule add git@github.com:apoj-inc/build_system.git

$ ls
build_system
```

### Repository folder structure

For `build_system` to work the project should have a __buildable__ folder structure. Following diagram and description show, what a __buildable__ folder structure is:
```
|- build_system
|- fpga
|   |- quartus
|   |   |- constraints
|   |   |   |- <toplevel_name>.sdc
|   |   |   |- <toplevel_name>.tcl
|   |   |   \- ...
|   |   |
|   |   |- custom_ip
|   |   |   |- lists
|   |   |   |   \- ip_paths.lst
|   |   |   |
|   |   |   |- <ip_regenerator_tcl_scripts>
|   |   |   \- ...
|   |   |
|   |   |- qsys
|   |   |   \- names_qsys.lst
|   |   |
|   |   |- <qsys_regenerator_tcl_scripts>
|   |   \- ...
|   |
|   \- vivado
|       |- constraints
|       |   |- <toplevel_name>.xdc
|       |   \- ...
|       |
|       |- lists
|       |   \- files_ip.lst
|       |
|       |- <ip_regenerator_tcl_scripts>
|       \- ...
|
|- rtl
|   |- lists
|   |   \- files_rtl.lst
|   |
|   |- <rtl sources>
|   \- ...
|
|- submodules
|   |- lists
|   |   \- buildable_submodules.lst
|   |
|   |- <submodules in separate directories>
|   \- ...
|
\- tb
    |- tb_<name>
    |   |- tb_<name>.py
    |   \- tb_<name>.sv
    \- ...
```

To see examples of projects with this folder structure (with some variations), feel free to visit any of the [apoj-inc](https://github.com/apoj-inc) FPGA repositories [[rtl-lib](https://github.com/apoj-inc/rtl-lib), [Kintex-7-PCIe-DMA](https://github.com/apoj-inc/Kintex-7-PCIe-DMA), [Cyclone-V-PCIe-AVMM-DMA](https://github.com/apoj-inc/Cyclone-V-PCIe-AVMM-DMA), [AXI-NoC-with-built-in-PMUs](https://github.com/apoj-inc/AXI-NoC-with-built-in-PMUs), [FPGA-NoC-testbed](https://github.com/apoj-inc/FPGA-NoC-testbed)].

Not all of the components should be present:

- `fpga/quartus`, `fpga/vivado` - either or both can be dropped if only one FPGA platform is needed or if you don't need to implement this particular project in FPGAs. Examples - [rtl-lib](https://github.com/apoj-inc/rtl-lib), [Kintex-7-PCIe-DMA](https://github.com/apoj-inc/Kintex-7-PCIe-DMA), [Cyclone-V-PCIe-AVMM-DMA](https://github.com/apoj-inc/Cyclone-V-PCIe-AVMM-DMA), [AXI-NoC-with-built-in-PMUs](https://github.com/apoj-inc/AXI-NoC-with-built-in-PMUs);
- `submodules` - can be dropped if there are no __buildable__ submodules present in the project. Example - [rtl-lib](https://github.com/apoj-inc/rtl-lib);
- `tb` - can be dropped if you don't test your RTL (for some reason). I have no examples of that.

#### RTL folder

`./rtl` folder contains user-written HDL sources. `rtl/lists/files_rtl.lst` is a list of paths to synthesizable SystemVerilog sources that will be used to build and run testbenches or to compile FPGA bitstreams. All of the paths are relative to the repository root. Example:

```bash
$ pwd
<repository rootdir>

$ tree ./rtl
./rtl
|- lists
|   \- files_rtl.lst
\- src
    |- folder1
    |   |- module1.sv
    |   \- module2.sv
    |- folder2
    |   |- subfolder1
    |   |   \- module3.sv
    |   \- module4.sv
    \- toplevel.sv

$ cat ./rtl/lists/files_rtl.lst           # files_rtl.lst contents
rtl/src/folder1/module1.sv
rtl/src/folder1/module2.sv
rtl/src/folder2/subfolder1/module3.sv
rtl/src/folder2/module4.sv
rtl/src/toplevel.sv
```

Each `.sv` file should contain either one module, one package or one interface. Filename should be the same as module/package/interface name.

#### TB folder

`./tb` contains testbenches for the synthesizable SystemVerilog code. Currently all of the testbenches are ran through Cocotb in Questa, so the folder structure should be specific. Example:

```bash
$ pwd
<repository rootdir>

$ tree ./tb
./tb
|- tb_<name_1>
|   |- tb_<name_1>.py
|   \- tb_<name_1>.sv
|- tb_<name_2>
|   |- tb_<name_2>.py
|   \- tb_<name_2>.sv
\- ...
```

Note that each folder and file name should start with `tb_`, for example, `tb_dma_echodevice`. `.sv` file contains DUT instantiation and both `.py` and `.sv` files contain testbench code that tests the DUT.

#### Submodules folder

`./submodules` folder contains __buildable__ submodules. __Buildable__ submodule is a submodule that has a __buildable__ folder structure inside of it. `submodules/lists/buildable_submodules.lst` contains paths to these submodules relative to the repository root. For example, let's see how `rtl-lib` repository can be added to the project as a submodule:

```bash
$ pwd
<repository rootdir>

$ cd ./submodules
$ mkdir src
$ cd ./src
$ git submodule add git@github.com:apoj-inc/rtl-lib.git
$ cd ../../

### editing submodules/lists/buildable_submodules.lst ###

$ pwd
<repository rootdir>

$ cat ./submodules/lists/buildable_submodules.lst
submodules/src/rtl-lib
```

#### FPGA folder

`./fpga` folder contains constraints and IPs used to build FPGA bitstreams. `./fpga/quartus` contains sources for Altera FPGAs, `./fpga/vivado` contains sources for Xilinx FPGAs.

##### Vivado

- Constraints - for each toplevel module there should be a separate `.xdc` constraint file with the same name as the name of module (for example, `kdma_toplevel.sv` with `kdma_toplevel` module inside of it corresponds to `kdma_toplevel.xdc` constraint file). Usually `.xdc` files contain sdc constraints and pin+miscellaneous assignments. All of the `<toplevel>.xdc` files should be inside `fpga/vivado/constraints` directory;
- IP-cores - for each IP core there should be a `<ip_name>.tcl` script that regenerates the IP-core with name `ip_name` (refer to Vivado's `write_ip_tcl` on how to generate such file). `./fpga/vivado/lists/files_ip.lst` contains list of paths to these `.tcl` files relative to the repository root in the same way as `./rtl/lists/files_rtl.lst`.


##### Quartus

- Constraints - for each toplevel module there should be a separate `.sdc` constraint file and a `.tcl` assignment file with same names as the name of module (for example, `avmm_dma_toplevel.sv` with `avmm_dma_toplevel` module inside of it corresponds to `avmm_dma_toplevel.sdc` constraint file and `avmm_dma_toplevel.tcl` assignment file). `.sdc` files contain sdc constraints while `.tcl` files contain things like pin+miscellaneous assignments;
- Custom IP-cores - for each custom IP core there should be a `<custom_ip_name>_hw.tcl` script that describes it. You can write these scripts manually or from Quartus GUI using Component Editor inside of Platform Designer. HDL sources of the custom IP-core should be in the project at a fixed path relative to the `_hw.tcl` file. ENSURE that all of the `add_fileset` commands source HDL files using correct paths relative to the folder, containing `_hw.tcl`. If paths are wrong, you can fix them manually. `./fpga/quartus/custom_ip/lists/ip_paths.lst` contains list of __directories__ relative to the repository root, that contain such `_hw.tcl` files;
- Platform Designer files - for each system created in Platform Designer there should be a `<system_name>.tcl` file that can be used to regenerate the system. You can write these scripts manually (not recommended) or generate them from Platform Designer using Platform Designer menu: `File` > `Export System as Platform Designer script (.tcl)`. `./fpga/quartus/qsys/lists/names_qsys.lst` file contains list of paths to these scripts without `.tcl` extension. Example: script path - `./fpga/quartus/qsys/src/my_pcie.tcl`; line in `./fpga/quartus/qsys/lists/names_qsys.lst` file - `./fpga/quartus/qsys/src/my_pcie`.

### Usage

#### Cocotb

Run a testbench `./tb/tb_<name>` using cocotb:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/cctb/makefile COCOTB_TOPLEVEL=tb_<name> run
```

Launch Questa GUI to inspect waves generated by testbench `./tb/tb_<name>`:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/cctb/makefile COCOTB_TOPLEVEL=tb_<name> wave
```

Other useful variables:

- `PLATFORM`, value `ALTERA` or `XILINX` - you can write `` `ifdef ALTERA ... `elsif XILINX ... `` macros for platform-specific modules, for example, modules that infer BRAM slices;
- `COMPILE_ARGS` (default value - `suppress 13314 -suppress 14408 +define+$(PLATFORM)`) - arguments for the Questa command that builds HDL sources. !!! NOTE !!! Defining this variable overrides the effect of `PLATFORM` variable and default compile arguments;
- `SIM_ARGS` (default value - `-suppress 12110 -autofindloop -suppress 12130 -sv_seed random -do $(CURDIR)/build_system/cctb/questa_after_vsim.do`) - arguments for Questa command that runs the simulation. !!! NOTE !!! Defining this variable overrides default simulation arguments;
- `WAVES` (default value - 1) - if 1, then waveform files are generated, if 0 - not generated.

#### Pytest

Run all testbenches in a pytest environment:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/autotest/makefile run_pytest
```

Run a set collection of testbenches in a pytest environment:
```bash
make -f build_system/autotest/makefile TESTS_DIRS='tb/tb_<name_1> tb/tb_<name_2>' run_pytest
```
`tb/tb_<name_1>` and `tb/tb_<name_2>` are directories relative to the repository root. 

#### Quartus

Compile a Quartus project with toplevel module named `<toplevel>`:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/quartus/makefile TOPLEVEL=<toplevel> compile
```

Program bitstream from a toplevel module named `<toplevel>` into the SRAM of a device number `<N>` on a cable/JTAG-chain named `<cable_name>`:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/quartus/makefile TOPLEVEL=<toplevel> CABLE_NAME=<cable_name> JTAG_CHAIN_DEVNUM=<N> program
```

Other useful variables:

- `DEVICE_FAMILY` (default value - `Cyclone V`) - family of target FPGA;
- `DEVICE_PART` (default value - `5CGTFD9D5F27C7`) - model index of target FPGA.

#### Vivado

Compile a Vivado project with toplevel module named `<toplevel>`:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/vivado/makefile TOPLEVEL=<toplevel> compile
```

Program bitstream from a toplevel module named `<toplevel>` into the SRAM of a device number `<N>` on a JTAG-chain:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/vivado/makefile TOPLEVEL=<toplevel> DEVICE_NUMBER=<N> program
```

Other useful variables:

- `DEVICE` (default value - `xc7k325tffg676-2L`) - model index of target FPGA.

#### Usage results

All of the usage results are generated inside the `./.cache` directory. Examples of interaction with its contents:

Open project in Quartus GUI:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/quartus/makefile TOPLEVEL=<toplevel> compile
...

$ cd ./.cache/quartus/<toplevel>
$ quartus <toplevel>.qsf
```

Open project in Vivado GUI:
```bash
$ pwd
<repository rootdir>

$ make -f build_system/vivado/makefile TOPLEVEL=<toplevel> compile
...

$ cd ./.cache/vivado/<toplevel>
$ vivado <toplevel>.xpr              # Opens project in Vivado GUI
```

Location of simulation logs from pytest launch
```bash
$ pwd
<repository rootdir>

$ make -f build_system/autotest/makefile run_pytest
...

$ ls .cache/cctb/tests/logs
results tb_<name_1>.log tb_<name_2>.log tb_<name_3>.log ...
```