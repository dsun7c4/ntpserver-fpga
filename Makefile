# these are the sources - everything depends upon them

VER_SRC  = hdl/version_pkg.vhd

VHDL_SRC = 								   \
	$(addprefix hdl/,						   \
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
	)

VHDL_SIM = 								   \
	$(VHDL_SRC)							   \
	$(XLX_IP_SIM)							   \
	$(addprefix hdl/,						   \
	tb_pkg.vhd							   \
	cpu_test.vhd							   \
	clock_tb.vhd							   \
	)

#RTL=../hdl/top/top.v ../hdl/threeFlop/threeFlop.v

XLX_BLK =								   \
	cpu/cpu.bd							   \


XLX_IP =								   \
	ip/ocxo_clk_pll/ocxo_clk_pll.xci				   \


XLX_IP_SIM =								   \
	ip/ocxo_clk_pll/ocxo_clk_pll_clk_wiz.vhd			   \
	ip/ocxo_clk_pll/ocxo_clk_pll.vhd				   \


XLX_XDC =								   \
	xdc/pin.xdc							   \
	xdc/timing.xdc							   \


# These are all the compilation targets, starting with "all"
all : setup compile


include scripts/version.rules
include scripts/filestcl.rules


# This setups up the top level project
setup : .setup.done
.setup.done : $(VHDL_SRC) $(VHDL_SIM) $(VER_SRC) $(XLX_BLK) $(XLX_IP) $(XLX_XDC) $(TCL_FILE)
	vivado -mode batch -source scripts/clock.tcl -log setup.log -jou setup.jou

compile : .compile.done
.compile.done : .setup.done
	vivado -mode batch -source scripts/compile.tcl -log compile.log -jou compile.jou

# delete everything except this Makefile
clean :	
	rm -f $(VER_SRC)
	rm -f $(TCL_FILE)
	rm -f .setup.done
	rm -f .compile.done
	rm -f setup*.jou
	rm -f setup*.log
	rm -f compile*.jou
	rm -f compile*.log
	rm -f vivado*.jou
	rm -f vivado*.log
	#find . -not -name "Makefile*" -not -name "." | xargs rm -rf


check:
	@echo "VHDL_SRC    = $(VHDL_SRC)"
	@echo "XLX_BLK     = $(XLX_BLK)"
	@echo "VHDL_SIM    = $(VHDL_SIM)"
	@echo "XLX_XDC     = $(XLX_XDC)"
	@echo "XLX_IP      = $(XLX_IP)"
	@echo "XLX_IP_SIM  = $(XLX_IP_SIM)"
