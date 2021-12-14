<chart>
id=132822938971760870
symbol=USDJPY
description=US Dollar vs Japanese Yen
period_type=1
period_size=1
digits=3
tick_size=0.000000
position_time=0
scale_fix=0
scale_fixed_min=113.340000
scale_fixed_max=115.560000
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=8
mode=1
fore=0
grid=0
volume=1
scroll=0
shift=1
shift_size=15.294118
fixed_pos=0.000000
ticker=1
ohlc=0
one_click=1
one_click_btn=1
bidline=1
askline=0
lastline=0
days=1
descriptions=0
tradelines=1
tradehistory=1
window_left=0
window_top=0
window_right=0
window_bottom=0
window_type=1
floating=0
floating_left=0
floating_top=0
floating_right=0
floating_bottom=0
floating_type=1
floating_toolbar=1
floating_tbstate=
background_color=16775408
foreground_color=0
barup_color=0
bardown_color=0
bullcandle_color=16777215
bearcandle_color=0
chartline_color=0
volumes_color=3329330
grid_color=10061943
bidline_color=8036607
askline_color=255
lastline_color=49152
stops_color=255
windows_total=1

<window>
height=100.000000
objects=112

<indicator>
name=Main
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
color=0
</graph>
period=200
method=1
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
color=32768
</graph>
period=50
method=1
</indicator>

<indicator>
name=Moving Average
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=129
style=0
width=2
color=255
</graph>
period=20
method=1
</indicator>

<indicator>
name=Custom Indicator
path=Scripts\AM_Session_Opens.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=0
style=0
width=1
arrow=251
color=
</graph>
<inputs>
Info= == LondonOpen , NewYorkOpen, ZeroGMTOpen Lines == 
NumberOfDays=15
LondonOpenBegin=07:00
NewYorkBegin=13:00
LondonCloseBegin=18:00
Lo_OpenLineShow=true
NY_OpenLineShow=false
ZeroGMT_OpenLineShow=false
Lo_OpenLineColor=16711680
NY_OpenLineColor=2763429
ZeroGMT_OpenLineColor=255
</inputs>
</indicator>

<indicator>
name=Custom Indicator
path=Scripts\TzPivots.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=0
style=0
width=1
arrow=251
color=
</graph>
<inputs>
LocalTimeZone=0
DestTimeZone=0
LineStyle=2
LineThickness=1
ShowComment=false
ShowHighLowOpen=false
ShowSweetSpots=false
ShowPivots=true
ShowMidPitvot=true
ShowFibos=false
ShowCamarilla=false
ShowLevelPrices=true
BarForLabels=10
VerticalTextColor=10526303
VerticalLineColor=9109504
DebugLogger=false
</inputs>
</indicator>

<indicator>
name=Bollinger Bands
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=131
style=0
width=2
arrow=251
color=8036607
</graph>

<graph>
name=
draw=131
style=0
width=2
arrow=251
color=8036607
</graph>

<graph>
name=
draw=131
style=0
width=2
arrow=251
color=8036607
</graph>
period=4000
deviation=2.000000
</indicator>

<indicator>
name=Bollinger Bands
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=131
style=0
width=2
color=10526303
</graph>

<graph>
name=
draw=131
style=0
width=2
color=10526303
</graph>

<graph>
name=
draw=131
style=0
width=2
color=10526303
</graph>
period=800
deviation=2.000000
</indicator>

<indicator>
name=Bollinger Bands
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1

<graph>
name=
draw=131
style=0
width=2
color=14772545
</graph>

<graph>
name=
draw=131
style=0
width=2
color=14772545
</graph>

<graph>
name=
draw=131
style=0
width=2
color=14772545
</graph>
period=200
deviation=2.000000
</indicator>
<object>
type=109
name=2013.10.21 06:00 DE : Producer Price Index (MoM)
hidden=1
descr=DE : Producer Price Index (MoM) 0.3% / 0.1%
color=15658671
selectable=0
date1=1382335200
</object>

<object>
type=109
name=2013.10.21 06:00 DE : Producer Price Index (YoY)
hidden=1
descr=DE : Producer Price Index (YoY) -0.5% / -0.7%
color=15658671
selectable=0
date1=1382335200
</object>

<object>
type=109
name=2013.10.21 08:00 IT : Industrial Orders n.s.a (YoY)
hidden=1
descr=IT : Industrial Orders n.s.a (YoY) -6.8% / 
color=13353215
selectable=0
date1=1382342400
</object>

<object>
type=109
name=2013.10.21 08:00 IT : Industrial Orders s.a (MoM)
hidden=1
descr=IT : Industrial Orders s.a (MoM) 2.0% / 
color=15658671
selectable=0
date1=1382342400
</object>

<object>
type=109
name=2013.10.21 08:00 IT : Industrial Sales n.s.a. (YoY)
hidden=1
descr=IT : Industrial Sales n.s.a. (YoY) -4.8% / 
color=13353215
selectable=0
date1=1382342400
</object>

<object>
type=109
name=2013.10.21 08:00 IT : Industrial Sales s.a. (MoM)
hidden=1
descr=IT : Industrial Sales s.a. (MoM) 1.0% / 
color=15658671
selectable=0
date1=1382342400
</object>

<object>
type=109
name=2013.10.21 10:00 SK : Unemployment Rate
hidden=1
descr=SK : Unemployment Rate 13.8% / 
color=15658671
selectable=0
date1=1382349600
</object>

<object>
type=109
name=2013.10.21 12:00 PT : Current Account Balance
hidden=1
descr=PT : Current Account Balance 1.163B / 
color=15658671
selectable=0
date1=1382356800
</object>

<object>
type=109
name=2013.10.21 12:00 Fed's Evans Speech
hidden=1
descr=Fed's Evans Speech
color=16119285
selectable=0
date1=1382356800
</object>

<object>
type=109
name=2013.10.21 14:00 CB Leading Indicator (MoM)
hidden=1
descr=CB Leading Indicator (MoM)
color=16119285
selectable=0
date1=1382364000
</object>

<object>
type=109
name=2013.10.21 14:00 Existing Home Sales (MoM)
hidden=1
descr=Existing Home Sales (MoM) 5.29M / 5.30M
color=13353215
selectable=0
date1=1382364000
</object>

<object>
type=109
name=2013.10.21 14:00 Existing Home Sales Change (MoM)
hidden=1
descr=Existing Home Sales Change (MoM) -1.9% / -2.9%
color=15658671
selectable=0
date1=1382364000
</object>

<object>
type=109
name=2013.10.21 14:00 Wholesale Inventories
hidden=1
descr=Wholesale Inventories
color=16119285
selectable=0
date1=1382364000
</object>

<object>
type=109
name=2013.10.21 14:30 EIA Crude Oil Stocks change
hidden=1
descr=EIA Crude Oil Stocks change 3.999M / 3.400M
color=15658671
selectable=0
date1=1382365800
</object>

<object>
type=109
name=2013.10.21 15:30 6-Month Bill Auction
hidden=1
descr=6-Month Bill Auction 0.07% / 
color=15658671
selectable=0
date1=1382369413
</object>

<object>
type=109
name=2013.10.21 15:30 3-Month Bill Auction
hidden=1
descr=3-Month Bill Auction 0.035% / 
color=15658671
selectable=0
date1=1382369448
</object>

<object>
type=109
name=2013.10.22 06:00 FI : Unemployment Rate
hidden=1
descr=FI : Unemployment Rate
color=16119285
selectable=0
date1=1382421600
</object>

<object>
type=109
name=2013.10.22 08:50 ES : 3-Month Letras Auction
hidden=1
descr=ES : 3-Month Letras Auction
color=16119285
selectable=0
date1=1382431800
</object>

<object>
type=109
name=2013.10.22 08:50 ES : 9-Month Letras auction
hidden=1
descr=ES : 9-Month Letras auction
color=16119285
selectable=0
date1=1382431800
</object>

<object>
type=109
name=2013.10.22 09:00 FR : 10-y Bond Auction
hidden=1
descr=FR : 10-y Bond Auction
color=16119285
selectable=0
date1=1382432400
</object>

<object>
type=109
name=2013.10.22 12:30 Average Hourly Earnings (MoM)
hidden=1
descr=Average Hourly Earnings (MoM)
color=16119285
selectable=0
date1=1382445000
</object>

<object>
type=109
name=2013.10.22 12:30 Average Hourly Earnings (YoY)
hidden=1
descr=Average Hourly Earnings (YoY)
color=16119285
selectable=0
date1=1382445000
</object>

<object>
type=109
name=2013.10.22 12:30 Average Weekly Hours
hidden=1
descr=Average Weekly Hours
color=16119285
selectable=0
date1=1382445000
</object>

<object>
type=109
name=2013.10.22 12:30 Nonfarm Payrolls
hidden=1
descr=Nonfarm Payrolls
color=16119285
selectable=0
date1=1382445000
</object>

<object>
type=109
name=2013.10.22 12:30 Unemployment Rate
hidden=1
descr=Unemployment Rate
color=16119285
selectable=0
date1=1382445000
</object>

<object>
type=109
name=2013.10.22 12:55 Redbook index (MoM)
hidden=1
descr=Redbook index (MoM)
color=16119285
selectable=0
date1=1382446500
</object>

<object>
type=109
name=2013.10.22 12:55 Redbook index (YoY)
hidden=1
descr=Redbook index (YoY)
color=16119285
selectable=0
date1=1382446500
</object>

<object>
type=109
name=2013.10.22 13:00 Net Long-Term TIC Flows
hidden=1
descr=Net Long-Term TIC Flows
color=16119285
selectable=0
date1=1382446800
</object>

<object>
type=109
name=2013.10.22 13:00 Total Net TIC Flows
hidden=1
descr=Total Net TIC Flows
color=16119285
selectable=0
date1=1382446800
</object>

<object>
type=109
name=2013.10.22 14:00 Construction Spending (MoM)
hidden=1
descr=Construction Spending (MoM)
color=16119285
selectable=0
date1=1382450400
</object>

<object>
type=109
name=2013.10.22 14:00 Richmond Fed Manufacturing Index
hidden=1
descr=Richmond Fed Manufacturing Index
color=16119285
selectable=0
date1=1382450400
</object>

<object>
type=109
name=2013.10.22 14:30 EIA Natural Gas Storage change
hidden=1
descr=EIA Natural Gas Storage change
color=16119285
selectable=0
date1=1382452200
</object>

<object>
type=109
name=2013.10.22 15:30 4-Week Bill Auction
hidden=1
descr=4-Week Bill Auction
color=16119285
selectable=0
date1=1382455800
</object>

<object>
type=109
name=2013.10.23 06:45 FR : Business Climate
hidden=1
descr=FR : Business Climate
color=16119285
selectable=0
date1=1382510700
</object>

<object>
type=109
name=2013.10.23 07:30 NL : Consumer Spending Volume
hidden=1
descr=NL : Consumer Spending Volume
color=16119285
selectable=0
date1=1382513400
</object>

<object>
type=109
name=2013.10.23 07:50 ES : Current Account Balance
hidden=1
descr=ES : Current Account Balance
color=16119285
selectable=0
date1=1382514600
</object>

<object>
type=109
name=2013.10.23 08:00 IT : Trade Balance non-EU
hidden=1
descr=IT : Trade Balance non-EU
color=16119285
selectable=0
date1=1382515200
</object>

<object>
type=109
name=2013.10.23 09:00 DE : 10-y Bond Auction
hidden=1
descr=DE : 10-y Bond Auction
color=16119285
selectable=0
date1=1382518800
</object>

<object>
type=109
name=2013.10.23 09:30 DE : 30-y Bond Auction
hidden=1
descr=DE : 30-y Bond Auction
color=16119285
selectable=0
date1=1382520600
</object>

<object>
type=109
name=2013.10.23 10:10 IT : 10-y Bond Auction
hidden=1
descr=IT : 10-y Bond Auction
color=16119285
selectable=0
date1=1382523000
</object>

<object>
type=109
name=2013.10.23 11:00 MBA Mortgage Applications
hidden=1
descr=MBA Mortgage Applications
color=16119285
selectable=0
date1=1382526000
</object>

<object>
type=109
name=2013.10.23 12:30 Export Price Index (MoM)
hidden=1
descr=Export Price Index (MoM)
color=16119285
selectable=0
date1=1382531400
</object>

<object>
type=109
name=2013.10.23 12:30 Export Price Index (YoY)
hidden=1
descr=Export Price Index (YoY)
color=16119285
selectable=0
date1=1382531400
</object>

<object>
type=109
name=2013.10.23 12:30 Import Price Index (MoM)
hidden=1
descr=Import Price Index (MoM)
color=16119285
selectable=0
date1=1382531400
</object>

<object>
type=109
name=2013.10.23 12:30 Import Price Index (YoY)
hidden=1
descr=Import Price Index (YoY)
color=16119285
selectable=0
date1=1382531400
</object>

<object>
type=109
name=2013.10.23 13:00 BE : Leading Indicator
hidden=1
descr=BE : Leading Indicator
color=16119285
selectable=0
date1=1382533200
</object>

<object>
type=109
name=2013.10.23 13:00 Housing Price Index (MoM)
hidden=1
descr=Housing Price Index (MoM)
color=16119285
selectable=0
date1=1382533200
</object>

<object>
type=109
name=2013.10.23 14:00 EMU: Consumer Confidence
hidden=1
descr=EMU: Consumer Confidence
color=16119285
selectable=0
date1=1382536800
</object>

<object>
type=109
name=2013.10.23 14:30 EIA Crude Oil Stocks change
hidden=1
descr=EIA Crude Oil Stocks change
color=16119285
selectable=0
date1=1382538600
</object>

<object>
type=109
name=2013.10.24 00:00 EMU: European Council meeting
hidden=1
descr=EMU: European Council meeting
color=16119285
selectable=0
date1=1382572800
</object>

<object>
type=109
name=2013.10.24 06:00 FI : Export Prices (YoY)
hidden=1
descr=FI : Export Prices (YoY)
color=16119285
selectable=0
date1=1382594400
</object>

<object>
type=109
name=2013.10.24 06:00 FI : Import Prices (YoY)
hidden=1
descr=FI : Import Prices (YoY)
color=16119285
selectable=0
date1=1382594400
</object>

<object>
type=109
name=2013.10.24 06:00 FI : Producer Price Index (YoY)
hidden=1
descr=FI : Producer Price Index (YoY)
color=16119285
selectable=0
date1=1382594400
</object>

<object>
type=109
name=2013.10.24 06:58 FR : Markit Manufacturing PMI
hidden=1
descr=FR : Markit Manufacturing PMI
color=16119285
selectable=0
date1=1382597880
</object>

<object>
type=109
name=2013.10.24 06:58 FR : Markit Services PMI
hidden=1
descr=FR : Markit Services PMI
color=16119285
selectable=0
date1=1382597880
</object>

<object>
type=109
name=2013.10.24 07:00 ES : Unemployment Survey
hidden=1
descr=ES : Unemployment Survey
color=16119285
selectable=0
date1=1382598000
</object>

<object>
type=109
name=2013.10.24 07:28 DE : Markit Manufacturing PMI
hidden=1
descr=DE : Markit Manufacturing PMI
color=16119285
selectable=0
date1=1382599680
</object>

<object>
type=109
name=2013.10.24 07:28 DE : Markit Services PMI
hidden=1
descr=DE : Markit Services PMI
color=16119285
selectable=0
date1=1382599680
</object>

<object>
type=109
name=2013.10.24 07:58 EMU: Markit Manufacturing PMI
hidden=1
descr=EMU: Markit Manufacturing PMI
color=16119285
selectable=0
date1=1382601480
</object>

<object>
type=109
name=2013.10.24 07:58 EMU: Markit PMI Composite
hidden=1
descr=EMU: Markit PMI Composite
color=16119285
selectable=0
date1=1382601480
</object>

<object>
type=109
name=2013.10.24 07:58 EMU: Markit Services PMI
hidden=1
descr=EMU: Markit Services PMI
color=16119285
selectable=0
date1=1382601480
</object>

<object>
type=109
name=2013.10.24 08:00 IT : Consumer Confidence
hidden=1
descr=IT : Consumer Confidence
color=16119285
selectable=0
date1=1382601600
</object>

<object>
type=109
name=2013.10.24 09:00 IT : Wage Inflation (MoM)
hidden=1
descr=IT : Wage Inflation (MoM)
color=16119285
selectable=0
date1=1382605200
</object>

<object>
type=109
name=2013.10.24 09:00 IT : Wage Inflation (YoY)
hidden=1
descr=IT : Wage Inflation (YoY)
color=16119285
selectable=0
date1=1382605200
</object>

<object>
type=109
name=2013.10.24 12:30 Continuing Jobless Claims
hidden=1
descr=Continuing Jobless Claims
color=16119285
selectable=0
date1=1382617800
</object>

<object>
type=109
name=2013.10.24 12:30 Initial Jobless Claims
hidden=1
descr=Initial Jobless Claims
color=16119285
selectable=0
date1=1382617800
</object>

<object>
type=109
name=2013.10.24 12:58 Markit Manufacturing PMI
hidden=1
descr=Markit Manufacturing PMI
color=16119285
selectable=0
date1=1382619480
</object>

<object>
type=2
name=[PIVOT] YesterdayStart
hidden=1
color=9109504
style=2
selectable=0
ray1=0
ray2=0
date1=1637712000
date2=1637712000
value1=0.000000
value2=100.000000
</object>

<object>
type=101
name=[PIVOT] YesterdayStart Label
hidden=1
descr=yesterday
color=10526303
selectable=0
angle=0
date1=1637712000
value1=115.239333
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] YesterdayEnd
hidden=1
color=9109504
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637798400
value1=0.000000
value2=100.000000
</object>

<object>
type=101
name=[PIVOT] YesterdayEnd Label
hidden=1
descr=today
color=10526303
selectable=0
angle=0
date1=1637798400
value1=115.239333
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] R1 Line
hidden=1
color=16711680
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=115.667000
value2=115.667000
</object>

<object>
type=101
name=[PIVOT] R1 Label
hidden=1
descr= R1: 115.667
color=16777215
selectable=0
angle=0
date1=1637791200
value1=115.667000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] R2 Line
hidden=1
color=16711680
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=115.939000
value2=115.939000
</object>

<object>
type=101
name=[PIVOT] R2 Label
hidden=1
descr= R2: 115.939
color=16777215
selectable=0
angle=0
date1=1637791200
value1=115.939000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] R3 Line
hidden=1
color=16711680
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=116.363000
value2=116.363000
</object>

<object>
type=101
name=[PIVOT] R3 Label
hidden=1
descr= R3: 116.363
color=16777215
selectable=0
angle=0
date1=1637791200
value1=116.363000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] Pivot Line
hidden=1
color=16711935
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=115.243000
value2=115.243000
</object>

<object>
type=101
name=[PIVOT] Pivot Label
hidden=1
descr= Pivot: 115.243
color=16777215
selectable=0
angle=0
date1=1637791200
value1=115.243000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] S1 Line
hidden=1
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=114.971000
value2=114.971000
</object>

<object>
type=101
name=[PIVOT] S1 Label
hidden=1
descr= S1: 114.971
color=16777215
selectable=0
angle=0
date1=1637791200
value1=114.971000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] S2 Line
hidden=1
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=114.547000
value2=114.547000
</object>

<object>
type=101
name=[PIVOT] S2 Label
hidden=1
descr= S2: 114.547
color=16777215
selectable=0
angle=0
date1=1637791200
value1=114.547000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] S3 Line
hidden=1
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=114.275000
value2=114.275000
</object>

<object>
type=101
name=[PIVOT] S3 Label
hidden=1
descr= S3: 114.275
color=16777215
selectable=0
angle=0
date1=1637791200
value1=114.275000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] MR3 Line
hidden=1
color=32768
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=116.151000
value2=116.151000
</object>

<object>
type=101
name=[PIVOT] MR3 Label
hidden=1
descr= MR3: 116.151
color=16777215
selectable=0
angle=0
date1=1637791200
value1=116.151000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] MR2 Line
hidden=1
color=32768
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=115.803000
value2=115.803000
</object>

<object>
type=101
name=[PIVOT] MR2 Label
hidden=1
descr= MR2: 115.803
color=16777215
selectable=0
angle=0
date1=1637791200
value1=115.803000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] MR1 Line
hidden=1
color=32768
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=115.455000
value2=115.455000
</object>

<object>
type=101
name=[PIVOT] MR1 Label
hidden=1
descr= MR1: 115.455
color=16777215
selectable=0
angle=0
date1=1637791200
value1=115.455000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] MS1 Line
hidden=1
color=32768
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=115.107000
value2=115.107000
</object>

<object>
type=101
name=[PIVOT] MS1 Label
hidden=1
descr= MS1: 115.107
color=16777215
selectable=0
angle=0
date1=1637791200
value1=115.107000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] MS2 Line
hidden=1
color=32768
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=114.759000
value2=114.759000
</object>

<object>
type=101
name=[PIVOT] MS2 Label
hidden=1
descr= MS2: 114.759
color=16777215
selectable=0
angle=0
date1=1637791200
value1=114.759000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=[PIVOT] MS3 Line
hidden=1
color=32768
style=2
selectable=0
ray1=0
ray2=0
date1=1637798400
date2=1637827200
value1=114.411000
value2=114.411000
</object>

<object>
type=101
name=[PIVOT] MS3 Label
hidden=1
descr= MS3: 114.411
color=16777215
selectable=0
angle=0
date1=1637791200
value1=114.411000
fontsz=8
fontnm=Arial
anchorpos=0
</object>

<object>
type=2
name=SessionOpen0LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637823600
date2=1637863200
value1=115.360000
value2=115.360000
</object>

<object>
type=2
name=SessionOpen1LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637737200
date2=1637776800
value1=114.948000
value2=114.948000
</object>

<object>
type=2
name=SessionOpen2LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637650800
date2=1637690400
value1=115.096000
value2=115.096000
</object>

<object>
type=2
name=SessionOpen3LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637564400
date2=1637604000
value1=114.136000
value2=114.136000
</object>

<object>
type=2
name=SessionOpen4LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637478000
date2=1637517600
value1=113.989000
value2=113.989000
</object>

<object>
type=2
name=SessionOpen5LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637305200
date2=1637344800
value1=114.363000
value2=114.363000
</object>

<object>
type=2
name=SessionOpen6LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637218800
date2=1637258400
value1=114.064000
value2=114.064000
</object>

<object>
type=2
name=SessionOpen7LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637132400
date2=1637172000
value1=114.856000
value2=114.856000
</object>

<object>
type=2
name=SessionOpen8LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1637046000
date2=1637085600
value1=114.146000
value2=114.146000
</object>

<object>
type=2
name=SessionOpen9LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1636959600
date2=1636999200
value1=113.856000
value2=113.856000
</object>

<object>
type=2
name=SessionOpen10LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1636873200
date2=1636912800
value1=113.874000
value2=113.874000
</object>

<object>
type=2
name=SessionOpen11LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1636700400
date2=1636740000
value1=114.256000
value2=114.256000
</object>

<object>
type=2
name=SessionOpen12LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1636614000
date2=1636653600
value1=113.960000
value2=113.960000
</object>

<object>
type=2
name=SessionOpen13LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1636527600
date2=1636567200
value1=112.846000
value2=112.846000
</object>

<object>
type=2
name=SessionOpen14LO
hidden=1
color=16711680
style=1
selectable=0
ray1=0
ray2=0
date1=1636441200
date2=1636480800
value1=112.818000
value2=112.818000
</object>

</window>
</chart>
