# these are the sources - everything depends upon them

VLOG_VER_SRC  = hdl/version_pkg.sv

VLOG_SRC = 								   \
	$(addprefix hdl/,						   \
	types_pkg.sv							   \
	util_pkg.sv							   \
	bcdtime.sv							   \
	dac.sv								   \
	disp.sv								   \
	disp_ctl.sv							   \
	disp_dark.sv							   \
	disp_lut.sv							   \
	disp_sr.sv							   \
	fan.sv								   \
	io.sv								   \
	regs.sv								   \
	syspll.sv							   \
	tsc.sv								   \
	clock.sv							   \
	)

VLOG_SIM = 								   \
	$(addprefix hdl/,						   \
	tb_pkg.sv							   \
	cpu_test.sv							   \
	)								   \
	$(XLX_IP_SIM)							   \
	$(VLOG_SRC)							   \
	$(addprefix hdl/,						   \
	clock_tb.sv							   \
	)

#RTL=../hdl/top/top.v ../hdl/threeFlop/threeFlop.v

XLX_BLK =								   \
	../cpu/cpu.bd							   \


XLX_IP =								   \
	ip/ocxo_clk_pll/ocxo_clk_pll.xci				   \


XLX_IP_SIM =								   \
	ip/ocxo_clk_pll/ocxo_clk_pll_clk_wiz.v				   \
	ip/ocxo_clk_pll/ocxo_clk_pll.v				           \


XLX_XDC =								   \
	../xdc/pin.xdc							   \
	../xdc/timing.xdc						   \


# These are all the compilation targets, starting with "all"
all : setup compile


include ../scripts/version.rules
include ../scripts/filestcl.rules


# This setups up the top level project
setup : .setup.done
.setup.done : $(VLOG_SRC) $(VLOG_SIM) $(VLOG_VER_SRC) $(XLX_BLK) $(XLX_IP) $(XLX_XDC) $(TCL_FILE)
	vivado -mode batch -source scripts/clock.tcl -log setup.log -jou setup.jou

compile : .compile.done
.compile.done : .setup.done
	vivado -mode batch -source ../scripts/compile.tcl -log compile.log -jou compile.jou

fsbl:
	${MAKE} -C fsbl


# delete everything except this Makefile
clean :	
	rm -f $(VHDL_VER_SRC) $(VLOG_VER_SRC)
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
	@echo "VLOG_SRC    = $(VLOG_SRC)"
	@echo "XLX_BLK     = $(XLX_BLK)"
	@echo "VHDL_SIM    = $(VHDL_SIM)"
	@echo "VLOG_SIM    = $(VLOG_SIM)"
	@echo "XLX_XDC     = $(XLX_XDC)"
	@echo "XLX_IP      = $(XLX_IP)"
	@echo "XLX_IP_SIM  = $(XLX_IP_SIM)"


.PHONY: fsbl
