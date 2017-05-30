create_project -type hw -name clock_hw_platform_0 -hwspec clock.hdf
create_project -type app -name clock -hwproject clock_hw_platform_0 -proc ps7_cortexa9_0 -app {Zynq FSBL}
build
quit
