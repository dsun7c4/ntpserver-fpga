
;
Refreshing IP repositories
234*coregenZ19-234h px
D
"No user IP repositories specified
1154*coregenZ19-1704h px
�
"Loaded Vivado IP repository '%s'.
1332*coregen2:
&/home/cae/xilinx/Vivado/2014.4/data/ip2default:defaultZ19-2313h px
�
FIP '%s' generated file not found '%s'. Please regenerate to continue.
1688*coregen2 
ocxo_clk_pll2default:default2S
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.dcp2default:defaultZ19-3664h px
�
FIP '%s' generated file not found '%s'. Please regenerate to continue.
1688*coregen2 
ocxo_clk_pll2default:default2V
B/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_stub.v2default:defaultZ19-3664h px
�
FIP '%s' generated file not found '%s'. Please regenerate to continue.
1688*coregen2 
ocxo_clk_pll2default:default2Y
E/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_stub.vhdl2default:defaultZ19-3664h px
�
FIP '%s' generated file not found '%s'. Please regenerate to continue.
1688*coregen2 
ocxo_clk_pll2default:default2Y
E/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_funcsim.v2default:defaultZ19-3664h px
�
FIP '%s' generated file not found '%s'. Please regenerate to continue.
1688*coregen2 
ocxo_clk_pll2default:default2\
H/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_funcsim.vhdl2default:defaultZ19-3664h px
~
]hardware handoff file cannot be generated as there is no block diagram instance in the design132*	vivadotclZ4-279h px
�
Command: %s
53*	vivadotcl2]
Isynth_design -top ocxo_clk_pll -part xc7z010clg400-1 -mode out_of_context2default:defaultZ4-113h px
7
Starting synth_design
149*	vivadotclZ4-321h px
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
	Synthesis2default:default2
xc7z0102default:defaultZ17-347h px
�
0Got license for feature '%s' and/or device '%s'
310*common2
	Synthesis2default:default2
xc7z0102default:defaultZ17-349h px
�
�The version limit for your license is '%s' and will expire in %s days. A version limit expiration means that, although you may be able to continue to use the current version of tools or IP with this license, you will not be eligible for any updates or new releases.
519*common2
2016.032default:default2
162default:defaultZ17-1223h px
�
%s*synth2�
�Starting RTL Elaboration : Time (s): cpu = 00:00:07 ; elapsed = 00:00:07 . Memory (MB): peak = 872.672 ; gain = 151.773 ; free physical = 125 ; free virtual = 37397
2default:defaulth px
�
synthesizing module '%s'638*oasys2 
ocxo_clk_pll2default:default2U
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.vhd2default:default2
862default:default8@Z8-638h px
�
Hmodule '%s' declared at '%s:%s' bound to instance '%s' of component '%s'3392*oasys2(
ocxo_clk_pll_clk_wiz2default:default2[
G/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_clk_wiz.vhd2default:default2
742default:default2
U02default:default2(
ocxo_clk_pll_clk_wiz2default:default2U
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.vhd2default:default2
1042default:default8@Z8-3491h px
�
synthesizing module '%s'638*oasys2(
ocxo_clk_pll_clk_wiz2default:default2]
G/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_clk_wiz.vhd2default:default2
862default:default8@Z8-638h px
d
%s*synth2O
;	Parameter CAPACITANCE bound to: DONT_CARE - type: string 
2default:defaulth px
a
%s*synth2L
8	Parameter IBUF_DELAY_VALUE bound to: 0 - type: string 
2default:defaulth px
[
%s*synth2F
2	Parameter IBUF_LOW_PWR bound to: 1 - type: bool 
2default:defaulth px
c
%s*synth2N
:	Parameter IFD_DELAY_VALUE bound to: AUTO - type: string 
2default:defaulth px
a
%s*synth2L
8	Parameter IOSTANDARD bound to: DEFAULT - type: string 
2default:defaulth px
�
,binding component instance '%s' to cell '%s'113*oasys2 
clkin1_ibufg2default:default2
IBUF2default:default2]
G/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_clk_wiz.vhd2default:default2
1192default:default8@Z8-113h px
b
%s*synth2M
9	Parameter BANDWIDTH bound to: OPTIMIZED - type: string 
2default:defaulth px
g
%s*synth2R
>	Parameter CLKFBOUT_MULT_F bound to: 63.750000 - type: float 
2default:defaulth px
e
%s*synth2P
<	Parameter CLKFBOUT_PHASE bound to: 0.000000 - type: float 
2default:defaulth px
c
%s*synth2N
:	Parameter CLKFBOUT_USE_FINE_PS bound to: 0 - type: bool 
2default:defaulth px
f
%s*synth2Q
=	Parameter CLKIN1_PERIOD bound to: 100.000000 - type: float 
2default:defaulth px
d
%s*synth2O
;	Parameter CLKIN2_PERIOD bound to: 0.000000 - type: float 
2default:defaulth px
g
%s*synth2R
>	Parameter CLKOUT0_DIVIDE_F bound to: 6.375000 - type: float 
2default:defaulth px
i
%s*synth2T
@	Parameter CLKOUT0_DUTY_CYCLE bound to: 0.500000 - type: float 
2default:defaulth px
d
%s*synth2O
;	Parameter CLKOUT0_PHASE bound to: 0.000000 - type: float 
2default:defaulth px
b
%s*synth2M
9	Parameter CLKOUT0_USE_FINE_PS bound to: 0 - type: bool 
2default:defaulth px
`
%s*synth2K
7	Parameter CLKOUT1_DIVIDE bound to: 1 - type: integer 
2default:defaulth px
i
%s*synth2T
@	Parameter CLKOUT1_DUTY_CYCLE bound to: 0.500000 - type: float 
2default:defaulth px
d
%s*synth2O
;	Parameter CLKOUT1_PHASE bound to: 0.000000 - type: float 
2default:defaulth px
b
%s*synth2M
9	Parameter CLKOUT1_USE_FINE_PS bound to: 0 - type: bool 
2default:defaulth px
`
%s*synth2K
7	Parameter CLKOUT2_DIVIDE bound to: 1 - type: integer 
2default:defaulth px
i
%s*synth2T
@	Parameter CLKOUT2_DUTY_CYCLE bound to: 0.500000 - type: float 
2default:defaulth px
d
%s*synth2O
;	Parameter CLKOUT2_PHASE bound to: 0.000000 - type: float 
2default:defaulth px
b
%s*synth2M
9	Parameter CLKOUT2_USE_FINE_PS bound to: 0 - type: bool 
2default:defaulth px
`
%s*synth2K
7	Parameter CLKOUT3_DIVIDE bound to: 1 - type: integer 
2default:defaulth px
i
%s*synth2T
@	Parameter CLKOUT3_DUTY_CYCLE bound to: 0.500000 - type: float 
2default:defaulth px
d
%s*synth2O
;	Parameter CLKOUT3_PHASE bound to: 0.000000 - type: float 
2default:defaulth px
b
%s*synth2M
9	Parameter CLKOUT3_USE_FINE_PS bound to: 0 - type: bool 
2default:defaulth px
^
%s*synth2I
5	Parameter CLKOUT4_CASCADE bound to: 0 - type: bool 
2default:defaulth px
`
%s*synth2K
7	Parameter CLKOUT4_DIVIDE bound to: 1 - type: integer 
2default:defaulth px
i
%s*synth2T
@	Parameter CLKOUT4_DUTY_CYCLE bound to: 0.500000 - type: float 
2default:defaulth px
d
%s*synth2O
;	Parameter CLKOUT4_PHASE bound to: 0.000000 - type: float 
2default:defaulth px
b
%s*synth2M
9	Parameter CLKOUT4_USE_FINE_PS bound to: 0 - type: bool 
2default:defaulth px
`
%s*synth2K
7	Parameter CLKOUT5_DIVIDE bound to: 1 - type: integer 
2default:defaulth px
i
%s*synth2T
@	Parameter CLKOUT5_DUTY_CYCLE bound to: 0.500000 - type: float 
2default:defaulth px
d
%s*synth2O
;	Parameter CLKOUT5_PHASE bound to: 0.000000 - type: float 
2default:defaulth px
b
%s*synth2M
9	Parameter CLKOUT5_USE_FINE_PS bound to: 0 - type: bool 
2default:defaulth px
`
%s*synth2K
7	Parameter CLKOUT6_DIVIDE bound to: 1 - type: integer 
2default:defaulth px
i
%s*synth2T
@	Parameter CLKOUT6_DUTY_CYCLE bound to: 0.500000 - type: float 
2default:defaulth px
d
%s*synth2O
;	Parameter CLKOUT6_PHASE bound to: 0.000000 - type: float 
2default:defaulth px
b
%s*synth2M
9	Parameter CLKOUT6_USE_FINE_PS bound to: 0 - type: bool 
2default:defaulth px
a
%s*synth2L
8	Parameter COMPENSATION bound to: ZHOLD - type: string 
2default:defaulth px
_
%s*synth2J
6	Parameter DIVCLK_DIVIDE bound to: 1 - type: integer 
2default:defaulth px
Y
%s*synth2D
0	Parameter IS_CLKINSEL_INVERTED bound to: 1'b0 
2default:defaulth px
U
%s*synth2@
,	Parameter IS_PSEN_INVERTED bound to: 1'b0 
2default:defaulth px
Y
%s*synth2D
0	Parameter IS_PSINCDEC_INVERTED bound to: 1'b0 
2default:defaulth px
W
%s*synth2B
.	Parameter IS_PWRDWN_INVERTED bound to: 1'b0 
2default:defaulth px
T
%s*synth2?
+	Parameter IS_RST_INVERTED bound to: 1'b0 
2default:defaulth px
b
%s*synth2M
9	Parameter REF_JITTER1 bound to: 0.000000 - type: float 
2default:defaulth px
b
%s*synth2M
9	Parameter REF_JITTER2 bound to: 0.000000 - type: float 
2default:defaulth px
Z
%s*synth2E
1	Parameter SS_EN bound to: FALSE - type: string 
2default:defaulth px
b
%s*synth2M
9	Parameter SS_MODE bound to: CENTER_HIGH - type: string 
2default:defaulth px
c
%s*synth2N
:	Parameter SS_MOD_PERIOD bound to: 10000 - type: integer 
2default:defaulth px
[
%s*synth2F
2	Parameter STARTUP_WAIT bound to: 0 - type: bool 
2default:defaulth px
�
,binding component instance '%s' to cell '%s'113*oasys2!
mmcm_adv_inst2default:default2

MMCME2_ADV2default:default2]
G/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_clk_wiz.vhd2default:default2
1312default:default8@Z8-113h px
�
,binding component instance '%s' to cell '%s'113*oasys2
clkout1_buf2default:default2
BUFG2default:default2]
G/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_clk_wiz.vhd2default:default2
1962default:default8@Z8-113h px
�
%done synthesizing module '%s' (%s#%s)256*oasys2(
ocxo_clk_pll_clk_wiz2default:default2
12default:default2
12default:default2]
G/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_clk_wiz.vhd2default:default2
862default:default8@Z8-256h px
�
%done synthesizing module '%s' (%s#%s)256*oasys2 
ocxo_clk_pll2default:default2
22default:default2
12default:default2U
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.vhd2default:default2
862default:default8@Z8-256h px
�
%s*synth2�
�Finished RTL Elaboration : Time (s): cpu = 00:00:08 ; elapsed = 00:00:09 . Memory (MB): peak = 908.914 ; gain = 188.016 ; free physical = 132 ; free virtual = 37359
2default:defaulth px
A
%s*synth2,

Report Check Netlist: 
2default:defaulth px
r
%s*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth px
r
%s*synth2]
I|      |Item              |Errors |Warnings |Status |Description       |
2default:defaulth px
r
%s*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth px
r
%s*synth2]
I|1     |multi_driven_nets |      0|        0|Passed |Multi driven nets |
2default:defaulth px
r
%s*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished RTL Optimization Phase 1 : Time (s): cpu = 00:00:08 ; elapsed = 00:00:09 . Memory (MB): peak = 908.914 ; gain = 188.016 ; free physical = 132 ; free virtual = 37359
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
b
-Analyzing %s Unisim elements for replacement
17*netlist2
22default:defaultZ29-17h px
g
2Unisim Transformation completed in %s CPU seconds
28*netlist2
02default:defaultZ29-28h px
�
Loading clock regions from %s
13*device2f
R/home/cae/xilinx/Vivado/2014.4/data/parts/xilinx/zynq/zynq/xc7z010/ClockRegion.xml2default:defaultZ21-13h px
�
Loading clock buffers from %s
11*device2g
S/home/cae/xilinx/Vivado/2014.4/data/parts/xilinx/zynq/zynq/xc7z010/ClockBuffers.xml2default:defaultZ21-11h px
�
&Loading clock placement rules from %s
318*place2^
J/home/cae/xilinx/Vivado/2014.4/data/parts/xilinx/zynq/ClockPlacerRules.xml2default:defaultZ30-318h px
�
)Loading package pin functions from %s...
17*device2Z
F/home/cae/xilinx/Vivado/2014.4/data/parts/xilinx/zynq/PinFunctions.xml2default:defaultZ21-17h px
�
Loading package from %s
16*device2i
U/home/cae/xilinx/Vivado/2014.4/data/parts/xilinx/zynq/zynq/xc7z010/clg400/Package.xml2default:defaultZ21-16h px
�
Loading io standards from %s
15*device2[
G/home/cae/xilinx/Vivado/2014.4/data/./parts/xilinx/zynq/IOStandards.xml2default:defaultZ21-15h px
H
)Preparing netlist for logic optimization
349*projectZ1-570h px
;

Processing XDC Constraints
244*projectZ1-262h px
:
Initializing timing engine
348*projectZ1-569h px
�
$Parsing XDC File [%s] for cell '%s'
848*designutils2W
C/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_ooc.xdc2default:default2
U02default:defaultZ20-848h px
�
-Finished Parsing XDC File [%s] for cell '%s'
847*designutils2W
C/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_ooc.xdc2default:default2
U02default:defaultZ20-847h px
�
$Parsing XDC File [%s] for cell '%s'
848*designutils2Y
E/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_board.xdc2default:default2
U02default:defaultZ20-848h px
�
-Finished Parsing XDC File [%s] for cell '%s'
847*designutils2Y
E/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_board.xdc2default:default2
U02default:defaultZ20-847h px
�
$Parsing XDC File [%s] for cell '%s'
848*designutils2S
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.xdc2default:default2
U02default:defaultZ20-848h px
�
-Finished Parsing XDC File [%s] for cell '%s'
847*designutils2S
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.xdc2default:default2
U02default:defaultZ20-847h px
5
Deriving generated clocks
2*timingZ38-2h px
�
�Implementation specific constraints were found while reading constraint file [%s]. These constraints will be ignored for synthesis but will be used in implementation. Impacted constraints are listed in the file [%s].
233*project2S
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.xdc2default:default22
.Xil/ocxo_clk_pll_propImpl.xdc2default:defaultZ1-236h px
�
Parsing XDC File [%s]
179*designutils2�
p/home/guest/cae/fpga/ntpserver/ip/managed_ip_project/managed_ip_project.runs/ocxo_clk_pll_synth_1/dont_touch.xdc2default:defaultZ20-179h px
�
Finished Parsing XDC File [%s]
178*designutils2�
p/home/guest/cae/fpga/ntpserver/ip/managed_ip_project/managed_ip_project.runs/ocxo_clk_pll_synth_1/dont_touch.xdc2default:defaultZ20-178h px
E
&Completed Processing XDC Constraints

245*projectZ1-263h px
{
!Unisim Transformation Summary:
%s111*project29
%No Unisim elements were transformed.
2default:defaultZ1-111h px
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common24
 Constraint Validation Runtime : 2default:default2
00:00:00.012default:default2
00:00:00.032default:default2
1137.2462default:default2
0.0002default:default2
1172default:default2
371832default:defaultZ17-722h px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Constraint Validation : Time (s): cpu = 00:00:17 ; elapsed = 00:00:19 . Memory (MB): peak = 1137.246 ; gain = 416.348 ; free physical = 135 ; free virtual = 37183
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
S
%s*synth2>
*Start Loading Part and Timing Information
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
G
%s*synth22
Loading part: xc7z010clg400-1
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Loading Part and Timing Information : Time (s): cpu = 00:00:17 ; elapsed = 00:00:19 . Memory (MB): peak = 1137.246 ; gain = 416.348 ; free physical = 135 ; free virtual = 37183
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
W
%s*synth2B
.Start Applying 'set_property' XDC Constraints
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished applying 'set_property' XDC Constraints : Time (s): cpu = 00:00:17 ; elapsed = 00:00:19 . Memory (MB): peak = 1137.246 ; gain = 416.348 ; free physical = 135 ; free virtual = 37183
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished RTL Optimization Phase 2 : Time (s): cpu = 00:00:18 ; elapsed = 00:00:20 . Memory (MB): peak = 1137.246 ; gain = 416.348 ; free physical = 126 ; free virtual = 37174
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
B
%s*synth2-

Report RTL Partitions: 
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
+| |RTL Partition |Replication |Instances |
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
I
%s*synth24
 Start RTL Component Statistics 
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
H
%s*synth23
Detailed RTL Component Info : 
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
L
%s*synth27
#Finished RTL Component Statistics 
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
V
%s*synth2A
-Start RTL Hierarchical Component Statistics 
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
L
%s*synth27
#Hierarchical RTL Component report 
2default:defaulth px
>
%s*synth2)
Module ocxo_clk_pll 
2default:defaulth px
H
%s*synth23
Detailed RTL Component Info : 
2default:defaulth px
F
%s*synth21
Module ocxo_clk_pll_clk_wiz 
2default:defaulth px
H
%s*synth23
Detailed RTL Component Info : 
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
X
%s*synth2C
/Finished RTL Hierarchical Component Statistics
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
E
%s*synth20
Start Part Resource Summary
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px

%s*synth2j
VPart Resources:
DSPs: 80 (col length:40)
BRAMs: 120 (col length: RAMB18 40 RAMB36 20)
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
H
%s*synth23
Finished Part Resource Summary
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Start Parallel Synthesis Optimization  : Time (s): cpu = 00:00:18 ; elapsed = 00:00:20 . Memory (MB): peak = 1137.246 ; gain = 416.348 ; free physical = 127 ; free virtual = 37176
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
K
%s*synth26
"Start Cross Boundary Optimization
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Cross Boundary Optimization : Time (s): cpu = 00:00:18 ; elapsed = 00:00:20 . Memory (MB): peak = 1137.246 ; gain = 416.348 ; free physical = 127 ; free virtual = 37176
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Parallel Reinference  : Time (s): cpu = 00:00:18 ; elapsed = 00:00:20 . Memory (MB): peak = 1137.246 ; gain = 416.348 ; free physical = 127 ; free virtual = 37176
2default:defaulth px
B
%s*synth2-

Report RTL Partitions: 
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
+| |RTL Partition |Replication |Instances |
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
�
%s*synth2�
~---------------------------------------------------------------------------------
Start RAM, DSP and Shift Register Reporting
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�---------------------------------------------------------------------------------
Finished RAM, DSP and Shift Register Reporting
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
A
%s*synth2,
Start Area Optimization
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Area Optimization : Time (s): cpu = 00:00:18 ; elapsed = 00:00:20 . Memory (MB): peak = 1145.250 ; gain = 424.352 ; free physical = 135 ; free virtual = 37159
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Area Optimization : Time (s): cpu = 00:00:18 ; elapsed = 00:00:20 . Memory (MB): peak = 1145.250 ; gain = 424.352 ; free physical = 137 ; free virtual = 37159
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Parallel Area Optimization  : Time (s): cpu = 00:00:18 ; elapsed = 00:00:20 . Memory (MB): peak = 1145.250 ; gain = 424.352 ; free physical = 138 ; free virtual = 37159
2default:defaulth px
B
%s*synth2-

Report RTL Partitions: 
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
+| |RTL Partition |Replication |Instances |
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
�
%s*synth2�
�Finished Parallel Synthesis Optimization  : Time (s): cpu = 00:00:18 ; elapsed = 00:00:20 . Memory (MB): peak = 1145.250 ; gain = 424.352 ; free physical = 142 ; free virtual = 37159
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
C
%s*synth2.
Start Timing Optimization
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
O
%s*synth2:
&Start Applying XDC Timing Constraints
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Applying XDC Timing Constraints : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 1188.254 ; gain = 467.355 ; free physical = 130 ; free virtual = 37110
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Timing Optimization : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 1188.254 ; gain = 467.355 ; free physical = 130 ; free virtual = 37110
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
B
%s*synth2-

Report RTL Partitions: 
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
+| |RTL Partition |Replication |Instances |
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
B
%s*synth2-
Start Technology Mapping
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Technology Mapping : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 1198.266 ; gain = 477.367 ; free physical = 121 ; free virtual = 37102
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
B
%s*synth2-

Report RTL Partitions: 
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
+| |RTL Partition |Replication |Instances |
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
<
%s*synth2'
Start IO Insertion
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
N
%s*synth29
%Start Flattening Before IO Insertion
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
Q
%s*synth2<
(Finished Flattening Before IO Insertion
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
E
%s*synth20
Start Final Netlist Cleanup
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
H
%s*synth23
Finished Final Netlist Cleanup
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished IO Insertion : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 1198.266 ; gain = 477.367 ; free physical = 121 ; free virtual = 37102
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
A
%s*synth2,

Report Check Netlist: 
2default:defaulth px
r
%s*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth px
r
%s*synth2]
I|      |Item              |Errors |Warnings |Status |Description       |
2default:defaulth px
r
%s*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth px
r
%s*synth2]
I|1     |multi_driven_nets |      0|        0|Passed |Multi driven nets |
2default:defaulth px
r
%s*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
L
%s*synth27
#Start Renaming Generated Instances
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Renaming Generated Instances : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 1198.266 ; gain = 477.367 ; free physical = 121 ; free virtual = 37102
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
B
%s*synth2-

Report RTL Partitions: 
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
+| |RTL Partition |Replication |Instances |
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
T
%s*synth2?
++-+--------------+------------+----------+
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
I
%s*synth24
 Start Rebuilding User Hierarchy
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Rebuilding User Hierarchy : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 1198.266 ; gain = 477.367 ; free physical = 121 ; free virtual = 37102
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
~---------------------------------------------------------------------------------
Start RAM, DSP and Shift Register Reporting
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�---------------------------------------------------------------------------------
Finished RAM, DSP and Shift Register Reporting
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
H
%s*synth23
Start Writing Synthesis Report
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
>
%s*synth2)

Report BlackBoxes: 
2default:defaulth px
G
%s*synth22
+-+--------------+----------+
2default:defaulth px
G
%s*synth22
| |BlackBox name |Instances |
2default:defaulth px
G
%s*synth22
+-+--------------+----------+
2default:defaulth px
G
%s*synth22
+-+--------------+----------+
2default:defaulth px
>
%s*synth2)

Report Cell Usage: 
2default:defaulth px
E
%s*synth20
+------+-----------+------+
2default:defaulth px
E
%s*synth20
|      |Cell       |Count |
2default:defaulth px
E
%s*synth20
+------+-----------+------+
2default:defaulth px
E
%s*synth20
|1     |BUFG       |     1|
2default:defaulth px
E
%s*synth20
|2     |LUT1       |     1|
2default:defaulth px
E
%s*synth20
|3     |MMCME2_ADV |     1|
2default:defaulth px
E
%s*synth20
|4     |IBUF       |     1|
2default:defaulth px
E
%s*synth20
+------+-----------+------+
2default:defaulth px
B
%s*synth2-

Report Instance Areas: 
2default:defaulth px
Y
%s*synth2D
0+------+---------+---------------------+------+
2default:defaulth px
Y
%s*synth2D
0|      |Instance |Module               |Cells |
2default:defaulth px
Y
%s*synth2D
0+------+---------+---------------------+------+
2default:defaulth px
Y
%s*synth2D
0|1     |top      |                     |     4|
2default:defaulth px
Y
%s*synth2D
0|2     |  U0     |ocxo_clk_pll_clk_wiz |     4|
2default:defaulth px
Y
%s*synth2D
0+------+---------+---------------------+------+
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
�
%s*synth2�
�Finished Writing Synthesis Report : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 1198.266 ; gain = 477.367 ; free physical = 121 ; free virtual = 37102
2default:defaulth px
{
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px
o
%s*synth2Z
FSynthesis finished with 0 errors, 0 critical warnings and 0 warnings.
2default:defaulth px
�
%s*synth2�
�Synthesis Optimization Runtime : Time (s): cpu = 00:00:20 ; elapsed = 00:00:21 . Memory (MB): peak = 1198.266 ; gain = 144.242 ; free physical = 121 ; free virtual = 37102
2default:defaulth px
�
%s*synth2�
�Synthesis Optimization Complete : Time (s): cpu = 00:00:29 ; elapsed = 00:00:31 . Memory (MB): peak = 1198.266 ; gain = 477.367 ; free physical = 121 ; free virtual = 37102
2default:defaulth px
?
 Translating synthesized netlist
350*projectZ1-571h px
b
-Analyzing %s Unisim elements for replacement
17*netlist2
22default:defaultZ29-17h px
g
2Unisim Transformation completed in %s CPU seconds
28*netlist2
02default:defaultZ29-28h px
H
)Preparing netlist for logic optimization
349*projectZ1-570h px
�
$Parsing XDC File [%s] for cell '%s'
848*designutils2W
C/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_ooc.xdc2default:default2
U02default:defaultZ20-848h px
�
-Finished Parsing XDC File [%s] for cell '%s'
847*designutils2W
C/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_ooc.xdc2default:default2
U02default:defaultZ20-847h px
�
$Parsing XDC File [%s] for cell '%s'
848*designutils2Y
E/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_board.xdc2default:default2
U02default:defaultZ20-848h px
�
-Finished Parsing XDC File [%s] for cell '%s'
847*designutils2Y
E/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll_board.xdc2default:default2
U02default:defaultZ20-847h px
�
$Parsing XDC File [%s] for cell '%s'
848*designutils2S
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.xdc2default:default2
U02default:defaultZ20-848h px
�
%Done setting XDC timing constraints.
35*timing2U
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.xdc2default:default2
562default:default8@Z38-35h px
�
Deriving generated clocks
2*timing2U
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.xdc2default:default2
562default:default8@Z38-2h px
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2 
get_clocks: 2default:default2
00:00:122default:default2
00:00:132default:default2
1562.7542default:default2
349.4882default:default2
1272default:default2
367552default:defaultZ17-722h px
�
-Finished Parsing XDC File [%s] for cell '%s'
847*designutils2S
?/home/guest/cae/fpga/ntpserver/ip/ocxo_clk_pll/ocxo_clk_pll.xdc2default:default2
U02default:defaultZ20-847h px
r
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02default:default2
02default:defaultZ31-138h px
{
!Unisim Transformation Summary:
%s111*project29
%No Unisim elements were transformed.
2default:defaultZ1-111h px
R
Releasing license: %s
83*common2
	Synthesis2default:defaultZ17-83h px
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
252default:default2
02default:default2
02default:default2
02default:defaultZ4-41h px
[
%s completed successfully
29*	vivadotcl2 
synth_design2default:defaultZ4-42h px
�
r%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s ; free physical = %s ; free virtual = %s
480*common2"
synth_design: 2default:default2
00:00:402default:default2
00:00:432default:default2
1562.7542default:default2
737.0782default:default2
1262default:default2
367552default:defaultZ17-722h px
�
�report_utilization: Time (s): cpu = 00:00:00.08 ; elapsed = 00:00:00.40 . Memory (MB): peak = 1578.766 ; gain = 0.000 ; free physical = 129 ; free virtual = 36753
*commonh px
}
Exiting %s at %s...
206*common2
Vivado2default:default2,
Tue Mar 15 21:11:26 20162default:defaultZ17-206h px