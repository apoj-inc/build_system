source vars.tcl

set fp [open $FILES_RTL_PATH r]
set file_data [read $fp]
close $fp

set FILES_RTL_LIST [split $file_data "\n"]

set fp [open $INCDIRS_PATH r]
set file_data [read $fp]
close $fp

set INCDIRS_LIST [split $file_data "\n"]

set fp [open $FILES_XDC_PATH r]
set file_data [read $fp]
close $fp

set FILES_XDC_LIST [split $file_data "\n"]

set fp [open $FILES_XCI_PATH r]
set file_data [read $fp]
close $fp

set FILES_XCI_LIST [split $file_data "\n"]


create_project -force $TOPLEVEL -part $DEVICE

set_property verilog_define {XILINX} [get_filesets sources_1]

set_property top $TOPLEVEL [get_filesets sources_1]

foreach rtl $FILES_RTL_LIST {
    add_files -fileset sources_1 $REPO_DIR/$rtl
}

set INCDIR_STRING $REPO_DIR/[lindex $INCDIRS_LIST 0]
foreach incdir [lrange $INCDIRS_LIST 1 end] {
    set INCDIR_STRING "$INCDIR_STRING $REPO_DIR/$incdir"
}
set_property include_dirs $INCDIR_STRING [get_filesets sources_1]
puts [get_property include_dirs [get_filesets sources_1]]

foreach xdc $FILES_XDC_LIST {
    add_files -fileset constrs_1 $REPO_DIR/$xdc
}

foreach xci $FILES_XCI_LIST {
    source $REPO_DIR/$xci
}

create_ip_run [get_ips pcie_7x_0]
launch_runs pcie_7x_0_synth_1
launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

exit