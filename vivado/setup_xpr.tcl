source vars.tcl

set fp [open $FILES_RTL_PATH r]
set file_data [read $fp]
close $fp

set FILES_RTL_LIST [split $file_data "\n"]

set fp [open $INCDIRS_PATH r]
set file_data [read $fp]
close $fp

set INCDIRS_LIST [split $file_data "\n"]

set fp [open $FILES_SDC_PATH r]
set file_data [read $fp]
close $fp

set FILES_SDC_LIST [split $file_data "\n"]

set fp [open $FILES_XCI_PATH r]
set file_data [read $fp]
close $fp

set FILES_XCI_LIST [split $file_data "\n"]


create_project -force $TOPLEVEL -part $DEVICE

set_property top $TOPLEVEL [get_filesets sources_1]

foreach rtl $FILES_RTL_LIST {
    add_files -fileset sources_1 $REPO_DIR/$rtl
}

foreach incdir $INCDIRS_LIST {
    set_property include_dirs $REPO_DIR/$incdir [get_filesets sources_1]
}

foreach sdc $FILES_SDC_LIST {
    add_files -fileset constrs_1 $REPO_DIR/$sdc
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