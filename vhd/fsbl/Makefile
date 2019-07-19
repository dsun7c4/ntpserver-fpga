# Build the First Stage Boot Loader from the hardware description file

clock/Release/clock.elf: clock.hdf ../../scripts/fsbl.tcl
	xsdk -batch -source ../../scripts/fsbl.tcl

clean:
	rm -rf .metadata
	rm -rf clock
	rm -rf clock_bsp
	rm -rf clock_hw_platform_0
	rm -f  *.log
	rm -f  *.jou

