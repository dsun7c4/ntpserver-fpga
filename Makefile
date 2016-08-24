# these are the sources - everything depends upon them
VHDL_SRC =								   \
	bcdtime.vhd							   \
	dac.vhd								   \
	disp.vhd							   \
	disp_ctl.vhd							   \
	disp_dark.vhd							   \
	disp_lut.vhd							   \
	disp_sr.vhd							   \
	fan.vhd								   \
	io.vhd								   \
	regs.vhd							   \
	syspll.vhd							   \
	tsc.vhd								   \
	util_pkg.vhd							   \
	types_pkg.vhd							   \
	clock.vhd							   \
	clock_.vhd							   \

VHDL_SIM =								   \
	tb_pkg.vhd							   \
	cpu_test.vhd							   \
	clock_tb.vhd							   \


#RTL=../hdl/top/top.v ../hdl/threeFlop/threeFlop.v

XDC = $(addprefix xdc/,							   \
	pin.xdc								   \
	timing.xdc							   \
	)


# These are all the compilation targets, starting with "all"
all : setup compile


include scripts/version.rules


# This setups up the top level project
setup : .setup.done
.setup.done : $(addprefix hdl/, $(VHDL_SRC) $(VHDL_SIM)) $(XDC) $(VERSION_PKG)
	vivado -mode batch -source scripts/clock.tcl -log setup.log -jou setup.jou

compile : .compile.done
.compile.done : .setup.done
	vivado -mode batch -source scripts/compile.tcl -log compile.log -jou compile.jou

# delete everything except this Makefile
clean :	
	rm -f .setup.done
	rm -f .compile.done
	#find . -not -name "Makefile*" -not -name "." | xargs rm -rf


check:
	@echo VHDL_SRC = $(VHDL_SRC)
	@echo VHDL_SIM = $(VHDL_SIM)
	@echo XDC      = $(XDC)
