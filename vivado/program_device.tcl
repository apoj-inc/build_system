source vars.tcl

open_project $TOPLEVEL.xpr

open_hw_manager
connect_hw_server
open_hw_target

set Device [lindex [get_hw_devices] $DEVICE_NUMBER]

current_hw_device $Device
set_property PROGRAM.FILE "$TOPLEVEL.runs/impl_1/$TOPLEVEL.bit" $Device
if {[file exists "$TOPLEVEL.runs/impl_1/$TOPLEVEL.ltx"]} {
    set_property PROBES.FILE "$TOPLEVEL.runs/impl_1/$TOPLEVEL.bit" $Device
}

program_hw_devices $Device
refresh_hw_device $Device

exit