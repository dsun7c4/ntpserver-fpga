# get the directory where this script resides
set thisDir [file dirname [info script]]
# source common utilities
source -notrace $thisDir/utils.tcl

# Create project
open_project ./clock/clock.xpr

# Implement and write_bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

# If successful, "touch" a file so the make utility will know it's done 
touch {.compile.done}

# Export the hardware definition file for the SDK to make the FSBL
write_hwdef -force  -file ./fsbl/clock.hdf

