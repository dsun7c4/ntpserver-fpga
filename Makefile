# these are the sources - everything depends upon them
#RTL=../hdl/top/top.v ../hdl/threeFlop/threeFlop.v
#XDC=../xdc/top.xdc ../xdc/top_io_simple.xdc

# These are all the compilation targets, starting with "all"
all : setup compile

# This setups up the top level project
setup : .setup.done
.setup.done : $(RTL) $(XDC)
	vivado -mode batch -source scripts/clock.tcl -log setup.log -jou setup.jou

compile : .compile.done
.compile.done : .setup.done
	vivado -mode batch -source scripts/compile.tcl -log compile.log -jou compile.jou

# delete everything except this Makefile
clean :	
	#find . -not -name "Makefile*" -not -name "." | xargs rm -rf
