//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/* 2016-05-19 

2015-05-19
Version 1.1

Currency Pairs: 6 majors all wait for price to cross 00
It DOES NOT matter whether price cross upward or downward. Once price crosses an 00 level,
a buy is place 29 pips below and 29 pips above
except for USDCAD because it is too volatile, the entry will be +/- 49 pips from 00 level
So we cannot place limit order in advance because the Buy and Sell levels are dynamic
based on when the price crosses the 00 level

1. The EA first determine the Upper and Lower 00 levels
2. It monitor the prices for them to cross the 00 levels
3. When the 00 levels are crossed, EA will then place the limit orders

*/
#include <stderror.mqh>
#include <stdlib.mqh>
#define WAIT_FOR_NEW_DAY 0
#define NEW_DAY 1
#define SEND_LIMIT_ORDERS 2
#define WAIT_FOR_TRIGGER 3
#define MANAGE_TRADE 4
#define UPPER_LEVEL_TRIGGERED 5
#define LOWER_LEVEL_TRIGGERED 6
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
// Just 6 majors
//extern string  Pairs="AUDUSD,EURUSD,GBPUSD,NZDUSD,USDCAD,USDJPY";
extern double  PP_Offset=30;
//extern int StartTradingHour=4+3; //  => for backtesting TimeGMT()=BrokerTime=TimeCurrent()
//extern int OrderDurationHour=11.0;
extern int levels=2;
extern double DistanceToEntry=40;
extern double RiskPercent=10;
 double startingLot=0.01;
extern double lot2_multiplier = 1;
extern double lot3_multiplier = 1;
extern double lot4_multiplier = 0;
extern double lot5_multiplier = 0;
extern double lot6_multiplier = 0;
extern double SL=20.0;
extern int TP1 = 10.0;
extern int TP2 = 15.0;
extern int TP3 = 10.0;
extern int TP4 = 0.0;
extern int TP5 = 0.0;
extern int TP6 = 0.0;
extern double pipsFromLevel1to2 = 5;
extern double pipsFromLevel2to3 = 5;
extern double pipsFromLevel3to4 = 0;
extern double pipsFromLevel4to5 = 0;
extern double pipsFromLevel5to6 = 0;
extern bool clearAllOrdersOnResolution=true;
input int Magic=20160519;
extern int fontSize=11; // Font Size
extern color fontClr=clrAqua; // Text Color
extern int PipsToCaptureProfitAt = 3;
extern int PipsOfProfitToCapture = 0;
extern int TrailingStep=1;
extern bool sendEmailOnError=false;
input int SlippagePoint=50;
datetime TimeNextDay=0;
string   OrdType[7]=
  {
   "BUY",
   "SELL",
   "BUY_LIMIT",
   "SELL_LIMIT",
   "BUY_STOP",
   "SELL_STOP",
   "NIL"
  };
string StateType[7]=
  {
   "WAIT_FOR_NEW_DAY",
   "NEW_DAY",
   "SEND_LIMIT_ORDERS",
   "WAIT_FOR_TRIGGER",
   "MANAGE_TRADE",
   "UPPER_LEVEL_TRIGGERED",
   "LOWER_LEVEL_TRIGGERED"
  };
int State=0;
//datetime NextStartTime=0;
double SellPriceAboveMarket;
double BuyPriceBelowMarket;
datetime StopTime=0;
datetime CurrentDayStart;
double pip=0.0;
int buy_currentLevel; // -1 = no orders
int buy_marketOrders;
int buy_pendingOrders;
int sell_currentLevel;
int sell_marketOrders;
int sell_pendingOrders;
int buy_newMarketOrders;
int buy_newPendingOrders;
int sell_newMarketOrders;
int sell_newPendingOrders;
double UpperTriggerLevel;
double LowerTriggerLevel;
string         String;
int PairsQty;
string ManagePair;
int OrderType1[];
string suffix;
string TempPair;
int    Multiplier;
//double Point1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
//if(IsTesting()) StartTradingHour=StartTradingHour+TimeGMTOffset();
   CurrentDayStart=iTime(Symbol(),PERIOD_D1,0);
   TimeNextDay=CurrentDayStart+24*60*60;
//StopTime=TimeGMT()+OrderDurationHour*60*60;
   suffix=StringSubstr(Symbol(),6,4);
   if(Digits==3 || Digits==5)
      Multiplier=10;
   else
      Multiplier=1;

//String=Pairs;
//if(StringSubstr(String,StringLen(String)-1)!=",") String=StringConcatenate(String,",");
//PairsQty=PairsQty(String);
//int i = 0;int j = 0; int k = 0; int s=0;
//for(k = 0; k < PairsQty; k ++)
//{
//i=StringFind(String,",",j);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//if(i>-1)
//{
//int temp=ArraySize(TempPair);
//ArrayResize(TempPair,temp+1);
//TempPair[k] = StringSubstr(String, j,i-j);
//TempPair[k] = StringTrimLeft(TempPair[k]);
//TempPair[k] = StringTrimRight(TempPair[k]);
//TempPair[k] = StringConcatenate(TempPair[k], suffix);
//j=i+1;
// }
//}
//j=0;
//for(i=0;i<PairsQty;i++)
//{
//if(MarketInfo(TempPair[i],MODE_MAXLOT)>0.0)
//{
//Print(" SYMBOL Found: ",TempPair[i]);
//int temp=ArraySize(ManagePair);
//ArrayResize(ManagePair,temp+1);
//ManagePair[j]=TempPair[i];
//j++;
//}
//else
//{
//Print(" **** NO SYMBOL: ",TempPair[i]);
//}
//}

//PairsQty=j;

//ArrayResize(ManagePair,PairsQty);
//ArrayResize(TempPair,PairsQty);
//ArrayResize(Mult,PairsQty);
//ArrayResize(Point1,PairsQty);
//ArrayResize(BuyPriceBelowMarket,PairsQty);
//ArrayResize(SellPriceAboveMarket,PairsQty);
//ArrayResize(buy_currentLevel,PairsQty);
//ArrayResize(buy_marketOrders,PairsQty);
//ArrayResize(buy_pendingOrders,PairsQty);
//ArrayResize(sell_currentLevel,PairsQty);
//ArrayResize(sell_marketOrders,PairsQty);
//ArrayResize(sell_pendingOrders,PairsQty);
//ArrayResize(buy_newMarketOrders,PairsQty);
//ArrayResize(buy_newPendingOrders,PairsQty);
//ArrayResize(sell_newMarketOrders,PairsQty);
//ArrayResize(sell_newPendingOrders,PairsQty);
//ArrayResize(OrderType1,PairsQty);
//ArrayResize(UpperTriggerLevel,PairsQty);
//ArrayResize(LowerTriggerLevel,PairsQty);

   pip=getPipValue();
   EventSetTimer(60);
   State=WAIT_FOR_NEW_DAY;
//Print("NextTradeTime=",NextTradeTime," TimeGMT=",TimeGMT());
   ObjectSet("CycleStart",OBJPROP_TIME1,TimeCurrent());
   Print("Broker =",AccountCompany()," CurrentTimeGMT = ",TimeGMT()," Broker Time = ",TimeCurrent());
   ObjectCreate("Upper00",OBJ_HLINE,0,0,0);
   ObjectSet("Upper00",OBJPROP_STYLE,STYLE_DASH);
   ObjectSet("Upper00",OBJPROP_COLOR,Blue);
   ObjectCreate("Lower00",OBJ_HLINE,0,0,0);
   ObjectSet("Lower00",OBJPROP_STYLE,STYLE_DASH);
   ObjectSet("Lower00",OBJPROP_COLOR,Red);
   ObjectCreate("CycleStart",OBJ_VLINE,0,0,0);
   ObjectSet("CycleStart",OBJPROP_STYLE,STYLE_DASH);
   ObjectSet("CycleStart",OBJPROP_COLOR,Yellow);
   ObjectCreate("CycleStop",OBJ_VLINE,0,0,0);
   ObjectSet("CycleStop",OBJPROP_STYLE,STYLE_DASH);
   ObjectSet("CycleStop",OBJPROP_COLOR,Aqua);
   Output();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MainBody();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   MainBody();

  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
void    MainBody()
  {
//CurrentDayStart=iTime(Symbol(),PERIOD_D1,0);
   if(TimeGMT()>TimeNextDay)
     {
      State=NEW_DAY;
      CurrentDayStart=iTime(Symbol(),PERIOD_D1,0);
      TimeNextDay=CurrentDayStart+24*60*60;
      ObjectSet("CycleStart",OBJPROP_TIME1,CurrentDayStart);
      ObjectSet("CycleStop",OBJPROP_TIME1,TimeNextDay);
      //for(int i=0;i<PairsQty;i++)
      //{
      BuyPriceBelowMarket=0;
      SellPriceAboveMarket=0;
      LowerTriggerLevel=0;
      UpperTriggerLevel=0;
     }
//}
//}
   switch(State)
     {
      //case WAIT_FOR_NEW_DAY:
      //ManageTrades();
      //if(CheckNewDay()==true)
      //{
      //for(int i=0;i<PairsQty;i++)
      //{
      //BuyPriceBelowMarket[i]=0;
      //SellPriceAboveMarket[i]=0;
      //LowerTriggerLevel[i]=0;
      //UpperTriggerLevel[i]=0;
      //}
      //State=NEW_DAY;
      //}
      //State=ORDERS_SENT;
      //break;
      //case ORDERS_SENT:
      //AdjustTrailingStop();
      //ManageTrades();
      // break;
      case NEW_DAY:
         //for(int i=0;i<PairsQty;i++)
         //{
         LowerTriggerLevel=GetNewLowerTriggerLevel(Symbol());
         UpperTriggerLevel=GetNewUpperTriggerLevel(Symbol());
         //}
         State=WAIT_FOR_TRIGGER;
         break;
      case WAIT_FOR_TRIGGER:
         // incase, price does not trigger Upper or Lower trigger level
         // AND NewDay arrive, then reset
         //if(CheckNewDay()==true)
         //{
         ///CloseAllOrders();
         //for(int i=0;i<PairsQty;i++)
         //{
         //BuyPriceBelowMarket[i]=0;
         //SellPriceAboveMarket[i]=0;
         //LowerTriggerLevel[i]=0;
         //UpperTriggerLevel[i]=0;
         //}
         ///State=NEW_DAY;
         //}
         //else
         //
         //{
         //for(int i=0;i<PairsQty;i++)
         //{
         //               if(CheckForLowerLevelTrigger(ManagePair[i],LowerTriggerLevel[i])==true)
         //if(MathAbs((MarketInfo(Symbol(),MODE_ASK)-LowerTriggerLevel))<10*Multiplier*Point)
         //Print("Ask=",MarketInfo(Symbol(),MODE_ASK)," LowerTriggerLevel=",LowerTriggerLevel," UpperTriggerLevel=",UpperTriggerLevel);
         if(MarketInfo(Symbol(),MODE_ASK)<LowerTriggerLevel)
           {
            //StopTime=TimeCurrent()+OrderDurationHour*60*60;
            //digit=MarketInfo(Symbol(),MODE_DIGITS);
            //if(digit==3 || digit==5)
            //PtsPerPip=10;
            //else
            //PtsPerPip=1;
            //point1=MarketInfo(Symbol(),MODE_POINT);
            // Just Send the Order here. No need to give control to SendOrder()
            //BuyPriceBelowMarket=LowerTriggerLevel-29*PtsPerPip*point1;
            //SellPriceAboveMarket=LowerTriggerLevel+29*PtsPerPip*point1;
            //if(OrderSend(Symbol(),OP_BUYLIMIT,startingLot,BuyPriceBelowMarket,SlippagePoint,BuyPriceBelowMarket-SL*PtsPerPip*point1,
            //BuyPriceBelowMarket+TP1*PtsPerPip*point1,"!PK_00B_Buy_L1",Magic,StopTime,Blue)) Print("Buy Limit Order send for ",Symbol());
            //if(OrderSend(Symbol(),OP_SELLLIMIT,startingLot,SellPriceAboveMarket,SlippagePoint,SellPriceAboveMarket+SL*PtsPerPip*point1,
            //SellPriceAboveMarket-TP1*PtsPerPip*point1,"!PK_00B_Sell_L1",Magic,StopTime,Red)) Print("Sell Limit Order send for ",Symbol());
            Print("LowerTriggerLevel activated",LowerTriggerLevel);
            SellPriceAboveMarket=LowerTriggerLevel+DistanceToEntry*Multiplier*Point;
            BuyPriceBelowMarket=0;
            SendOrders();
            //StopTime=TimeNextDay;
            //BuyPriceBelowMarket=UpperTriggerLevel-29*PtsPerPip*point1;
            //SellPriceAboveMarket=LowerTriggerLevel+DistanceToEntry*Multiplier*Point;
            //if(OrderSend(Symbol(),OP_BUYLIMIT,startingLot,BuyPriceBelowMarket,SlippagePoint,BuyPriceBelowMarket-SL*PtsPerPip*point1,
            //BuyPriceBelowMarket+TP1*PtsPerPip*point1,"!PK_00B_Buy_L1",Magic,StopTime,Blue)) Print("Buy Limit Order send for ",Symbol());
            //if(OrderSend(Symbol(),OP_SELLLIMIT,startingLot,SellPriceAboveMarket,SlippagePoint,SellPriceAboveMarket+SL*Multiplier*Point,
            //SellPriceAboveMarket-TP1*Multiplier*Point,"!PK_00B_Sell_L1",Magic,StopTime,Red)) Print("Sell Limit Order send for ",Symbol());
            State=MANAGE_TRADE;
           }
         //if(CheckForUpperLevelTrigger(ManagePair[i],UpperTriggerLevel[i])==true)
         //if(MathAbs((MarketInfo(Symbol(),MODE_ASK)-UpperTriggerLevel))<10*Multiplier*Point)
         if(MarketInfo(Symbol(),MODE_ASK)>UpperTriggerLevel)
           {
            Print("UpperTriggerLevel activated",UpperTriggerLevel);
            SellPriceAboveMarket=UpperTriggerLevel+DistanceToEntry*Multiplier*Point;
            BuyPriceBelowMarket=0;
            SendOrders();
            //StopTime=TimeNextDay;
            //BuyPriceBelowMarket=UpperTriggerLevel-29*PtsPerPip*point1;
            //SellPriceAboveMarket=UpperTriggerLevel+DistanceToEntry*Multiplier*Point;
            //if(OrderSend(Symbol(),OP_BUYLIMIT,startingLot,BuyPriceBelowMarket,SlippagePoint,BuyPriceBelowMarket-SL*PtsPerPip*point1,
            //BuyPriceBelowMarket+TP1*PtsPerPip*point1,"!PK_00B_Buy_L1",Magic,StopTime,Blue)) Print("Buy Limit Order send for ",Symbol());
            //if(OrderSend(Symbol(),OP_SELLLIMIT,startingLot,SellPriceAboveMarket,SlippagePoint,SellPriceAboveMarket+SL*Multiplier*Point,
            //SellPriceAboveMarket-TP1*Multiplier*Point,"!PK_00B_Sell_L1",Magic,StopTime,Red)) Print("Sell Limit Order send for ",Symbol());
            State=MANAGE_TRADE;
           }
         //}
         //}
         break;
      case MANAGE_TRADE:
         ManageTrades();
         break;

     }
   Output();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade()
  {
//for(int i=0;i<PairsQty;i++)
//{
   SellPriceAboveMarket=GetNewUpperTriggerLevel(Symbol());
   BuyPriceBelowMarket=GetNewLowerTriggerLevel(Symbol());
//}
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  NumbersOfOpenTrade()

  {
   int count=0;
   int i;
   for(i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderMagicNumber()!=Magic) continue;
      if(OrderType()!=OP_BUY) continue;
      if(OrderType()!=OP_SELL) continue;
      count++;
     }
   return(count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Output()
  {
   string cmt="\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
   Comment(cmt);
   cmt=" CurrentDayStartSecs="+TimeToStr(CurrentDayStart,TIME_DATE | TIME_MINUTES | TIME_SECONDS)+" TimeNextDay="+TimeToStr(TimeNextDay,TIME_DATE | TIME_MINUTES | TIME_SECONDS)+" State="+StateType[State]+" PairsQty="+IntegerToString(PairsQty)+"\n";
   cmt=cmt+"Pair               UpperTrigLevel           LowerTrigLevel               SellPriceAboveMarket                  BuyPriceBelowMarket\n";
//for(int i=0;i<PairsQty;i++)
//{
   cmt=cmt+Symbol()+"          "+DoubleToStr(UpperTriggerLevel,5)+"                         "+DoubleToStr(LowerTriggerLevel,5)+"                      "+DoubleToStr(SellPriceAboveMarket,5)+"                 "+DoubleToStr(BuyPriceBelowMarket,5)+"\n";
//}
   Comment(cmt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetNewLowerTriggerLevel(string sym)
  {
   double ret=0.0;
   double points=MarketInfo(sym,MODE_POINT);
   double digit=MarketInfo(sym,MODE_DIGITS);
   double PtsPerPip=10;
   if(digit==3 || digit==5)
      PtsPerPip=10;
   else
      PtsPerPip=1;
   double CurPrice=MarketInfo(sym,MODE_ASK)*MathPow(10,digit);
// find remainder if divide by 1000
   double temp3=MathMod(CurPrice,1000);
   double Lower00=(CurPrice-temp3);
   ret=Lower00*points;
//Lower00=Lower00-PipsBuyOffset*PtsPerPip;
//double Higher00=(Lower00+1000);
//Print("Lower00= ",Lower00," CurPrice=",CurPrice," Higher00=",Higher00);
//if((CurPrice-Lower00)>10*PtsPerPip) ret=Lower00*points;
//else ret=(Lower00-100*PtsPerPip)*points;

   drawStatusLabel("LowerTriggerLevel="+DoubleToStr(ret,Digits-1),fontClr,1);
   ObjectSet("Upper00",OBJPROP_PRICE1,ret);
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetNewUpperTriggerLevel(string sym)
  {
   double ret=0.0;
   double points=MarketInfo(sym,MODE_POINT);
   double digit=MarketInfo(sym,MODE_DIGITS);
   double PtsPerPip=10;
   if(digit==3 || digit==5)
      PtsPerPip=10;
   else
      PtsPerPip=1;
   double CurPrice=MarketInfo(sym,MODE_ASK)*MathPow(10,digit);
// find remainder if divide by 1000
   double temp3=MathMod(CurPrice,1000);
   double Higher00=(CurPrice-temp3)+1000;
   ret=Higher00*points;
//Higher00=Higher00+(100-PipsBuyOffset)*PtsPerPip;
//double Higher00=(Lower00+1000);
//Print("Lower00= ",Lower00," CurPrice=",CurPrice," Higher00=",Higher00);
//if((Higher00-CurPrice)>10*PtsPerPip) ret=Higher00*points;
//else ret=(Higher00+100*PtsPerPip)*points;
   drawStatusLabel("HigherTriggerLevel ="+DoubleToStr(ret,Digits-1),fontClr,2);
   ObjectSet("Lower00",OBJPROP_PRICE1,ret);
   return(ret);
  }
//+------------------------------------------------------------------+
void drawStatusLabel(string text,color textColor,int n)
  {
   string label="VT_STATUS"+DoubleToStr(n,0); //V1.1 added line number to name
   ObjectCreate(label,OBJ_LABEL,0,0,0);
   ObjectSet(label,OBJPROP_CORNER,3);
   ObjectSet(label,OBJPROP_XDISTANCE,5);
   ObjectSet(label,OBJPROP_YDISTANCE,5+(fontSize+5)*n); //V1.1 allowance in case this is line 2 
   ObjectSetText(label,text,fontSize,"Tahoma",textColor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SendOrders()
  {
   int ret=0;
   GetStartingLots();
   if(startingLot<0.01) startingLot=0.01;
   Print("Send Orders");
//for(int count=0;count<PairsQty;count++)
//{
//Print("count =",count);
   
   Print(BuyPriceBelowMarket,getOrderCount(Symbol(),OP_BUYLIMIT));
   if(BuyPriceBelowMarket>0 && getOrderCount(Symbol(),OP_BUYLIMIT)==0 && getOrderCount(Symbol(),OP_BUY)==0)
     {
      // Open only 1st order
      StopTime=TimeNextDay;
      for(int i=0; i<levels; i++)
        {
         if(i==0)
           {
            Print(Symbol()," Type=",OrdType[OP_BUYLIMIT]," price=",getBuyPriceByLevel(Symbol(),i)," StopTime=",StopTime,"SL=",getBuyPriceByLevel(Symbol(),i)-SL*pip,getTPPipsByLevel(i),getLotByLevel(i),getCommentByLevel(i));
            openPendingOrder(Symbol(),OP_BUYLIMIT,getBuyPriceByLevel(Symbol(),i),StopTime,getBuyPriceByLevel(Symbol(),i)-SL*pip,getTPPipsByLevel(i),getLotByLevel(i),getCommentByLevel(i));
           }
         else
           {
            openPendingOrder(Symbol(),OP_BUYLIMIT,getBuyPriceByLevel(Symbol(),i),StopTime,BuyPriceBelowMarket-SL*pip,getTPPipsByLevel(i),getLotByLevel(i),getCommentByLevel(i));
           }
        }
     }
   if(SellPriceAboveMarket>0 && getOrderCount(Symbol(),OP_SELLLIMIT)==0 && getOrderCount(Symbol(),OP_SELL)==0)
     {
      // Open only 1st order
      StopTime=TimeNextDay;
      for(int i=0; i<levels; i++)
        {
         if(i==0)
           {
            Print(Symbol()," Type=",OrdType[OP_SELLLIMIT]," price=",getSellPriceByLevel(Symbol(),i)," StopTime=",StopTime,"SL=",getSellPriceByLevel(Symbol(),i)-SL*pip,getTPPipsByLevel(i),getLotByLevel(i),getCommentByLevel(i));
            openPendingOrder(Symbol(),OP_SELLLIMIT,getSellPriceByLevel(Symbol(),i),StopTime,getSellPriceByLevel(Symbol(),i)+SL*pip,getTPPipsByLevel(i),getLotByLevel(i),getCommentByLevel(i));
              } else {
            openPendingOrder(Symbol(),OP_SELLLIMIT,getSellPriceByLevel(Symbol(),i),StopTime,getSellPriceByLevel(Symbol(),i)+SL*pip,getTPPipsByLevel(i),getLotByLevel(i),getCommentByLevel(i));
           }
        }
     }
   RefreshRates();
   if(BuyPriceBelowMarket>0)
     {
      buy_marketOrders=getOrderCount(Symbol(),OP_BUY);
      buy_pendingOrders=getOrderCount(Symbol(),OP_BUYLIMIT);
     }
   if(SellPriceAboveMarket>0)
     {
      sell_marketOrders=getOrderCount(Symbol(),OP_SELL);
      sell_pendingOrders=getOrderCount(Symbol(),OP_SELLLIMIT);
     }
   return(ret);

  }

double getBuyPriceByLevel(string sym,int level)
  {

   double buyPrice=0;
//int Found=0;
//for(int i=0;i<PairsQty;i++)
//{
// if(StringFind(ManagePair[i],sym,0)>=0)
//{
//Found=i;
//}
   if(level==0)
     {
      buyPrice=BuyPriceBelowMarket;
        } else if(level==1) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      buyPrice=BuyPriceBelowMarket-pipsFromLevel1to2*pip;
        } else if(level==2) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      buyPrice=BuyPriceBelowMarket-(pipsFromLevel1to2+pipsFromLevel2to3)*pip;
        } else if(level==3) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      buyPrice=BuyPriceBelowMarket-(pipsFromLevel1to2+pipsFromLevel2to3+pipsFromLevel3to4)*pip;
        } else if(level==4) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      buyPrice=BuyPriceBelowMarket-(pipsFromLevel1to2+pipsFromLevel2to3+pipsFromLevel3to4+pipsFromLevel4to5)*pip;
        } else if(level==5) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      buyPrice=BuyPriceBelowMarket-(pipsFromLevel1to2+pipsFromLevel2to3+pipsFromLevel3to4+pipsFromLevel4to5+pipsFromLevel5to6)*pip;
     }
//}
   return(NormalizeDouble(buyPrice, Digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getSellPriceByLevel(string sym,int level)
  {
   double sellPrice=0;
//int Found=0;
//for(int i=0;i<PairsQty;i++)
//{
// if(StringFind(ManagePair[i],sym,0)>=0)
//{
//Found=i;
//}
   if(level==0)
     {
      sellPrice=SellPriceAboveMarket;
        } else if(level==1) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      sellPrice=SellPriceAboveMarket+pipsFromLevel1to2*pip;
        } else if(level==2) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      sellPrice=SellPriceAboveMarket+(pipsFromLevel1to2+pipsFromLevel2to3)*pip;
        } else if(level==3) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      sellPrice=SellPriceAboveMarket+(pipsFromLevel1to2+pipsFromLevel2to3+pipsFromLevel3to4)*pip;
        } else if(level==4) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      sellPrice=SellPriceAboveMarket+(pipsFromLevel1to2+pipsFromLevel2to3+pipsFromLevel3to4+pipsFromLevel4to5)*pip;
        } else if(level==5) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      sellPrice=SellPriceAboveMarket+(pipsFromLevel1to2+pipsFromLevel2to3+pipsFromLevel3to4+pipsFromLevel4to5+pipsFromLevel5to6)*pip;
     }
//}
   return(NormalizeDouble(sellPrice, Digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getTPPipsByLevel(int level)
  {
   int tp=-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(level==0)
     {
      tp=TP1;
        } else if(level==1) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      tp=TP2;
        } else if(level==2) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      tp=TP3;
        } else if(level==3) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      tp=TP4;
        } else if(level==4) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      tp=TP5;
        } else if(level==5) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      tp=TP6;
     }
   return(tp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLotByLevel(int level)
  {
   double lot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   lot=startingLot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(level==0)
     {
      lot=NormalizeDouble(startingLot,2);
        } else if(level==1) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      lot=NormalizeDouble(startingLot*lot2_multiplier,2);
        } else if(level==2) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      lot=NormalizeDouble(startingLot*lot3_multiplier,2);
        } else if(level==3) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      lot=NormalizeDouble(startingLot*lot4_multiplier,2);
        } else if(level==4) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      lot=NormalizeDouble(startingLot*lot5_multiplier,2);
        } else if(level==5) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      lot=NormalizeDouble(startingLot*lot6_multiplier,2);
     }
   return(lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getCommentByLevel(int level)
  {
   string comment="00B_L-"+IntegerToString(level+1);
   return(comment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool openPendingOrder(string sym,int type,double price,datetime orderExpirationTime,
                      double priceSL,int orderTP,double lot,string comment)
  {

   double priceTP;
   int clr;
   bool orderSent=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==OP_BUYLIMIT)
     {
      clr=Blue;
      //priceSL = price - orderSL*pip;
      priceTP=price+orderTP*pip;
        } else if(type==OP_SELLLIMIT) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      clr=Red;
      //priceSL = price + orderSL*pip;
      priceTP=price-orderTP*pip;
        } else {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      showMessage("Wrong order type! Coding error.",false);
      return(false);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Try to repeat send order operation in case of non-critical error
   Print(sym," ",DoubleToStr(MarketInfo(sym,MODE_ASK),4)," ",DoubleToStr(price,4)," ",DoubleToStr(priceSL,4)," ",DoubleToStr(priceTP,4));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(!IsStopped())
     {
      Print(sym," Type=",OrdType[type]," Bid=",DoubleToStr(MarketInfo(sym,MODE_ASK),4)," price=",DoubleToStr(price,4)," priceSL=",DoubleToStr(priceSL,4)," priceTP=",DoubleToStr(priceTP,4));

      int ticket=OrderSend(sym,type,lot,NormalizeDouble(price,Digits),SlippagePoint,
                           NormalizeDouble(priceSL,Digits),NormalizeDouble(priceTP,Digits),
                           comment,Magic,orderExpirationTime,clr);

      if(ticket<0)
        {
         int error=GetLastError();

         switch(error)
           {
            case ERR_PRICE_CHANGED: Comment("The price has changed. Retrying...");
            RefreshRates();                     // Update data
            continue;                           // Try again on next iteration
            case ERR_OFF_QUOTES: Comment("Off quotes. Waiting for a new tick...");
            while(RefreshRates()==false) // Up to a new tick
               Sleep(100);                       // Cycle delay
            continue;                           // Try again on next iteration
            case ERR_TRADE_CONTEXT_BUSY: Comment("Trade context is busy. Retrying...");
            Sleep(500);                         // Simple solution
            RefreshRates();                     // Update data
            continue;                           // Try again on next iteration
            default:
               // Send email = false as we will open market order
               showMessage("Cannot send pending order, error: "+DoubleToStr(error,0)+". "+ErrorDescription(error),false);
               orderSent=false;
           }
           } else {
         orderSent=true;
        }

      break;
     }

// Clear comment
   Comment("");
   return(orderSent);
  }
//+------------------------------------------------------------------+
//| Shows an Alert with some additional info. If sendMail=true,      | 
//| email will be sent using settings from MT4 options.              |
//+------------------------------------------------------------------+
void AdjustTrailingStop()
  {
   for(int cnt=OrdersTotal()-1; cnt>=0; cnt--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if((OrderSelect(cnt,SELECT_BY_POS)==True))
        {
         double newSL=0.0;
         bool capture=false;
         double CurrentAsk=MarketInfo(OrderSymbol(), MODE_ASK);
         double CurrentBid=MarketInfo(OrderSymbol(), MODE_BID);
         double StopLevel = MarketInfo(OrderSymbol(), MODE_STOPLEVEL);
         double Pt1=MarketInfo(OrderSymbol(),MODE_POINT);
         double   NumDigit=MarketInfo(OrderSymbol(),MODE_DIGITS);
         int NumDigits=(int)NumDigit;
         //double OpenPrice=OrderOpenPrice();
         int PtsPerPip=10;
         if(MarketInfo(OrderSymbol(),MODE_DIGITS)==5 || MarketInfo(OrderSymbol(),MODE_DIGITS)==3) PtsPerPip=10;
         if(OrderType()==OP_BUY)
           {

            if(OrderStopLoss()!=0)
              {
               if(CurrentBid>(OrderStopLoss()+(PipsToCaptureProfitAt+TrailingStep)*PtsPerPip*Pt1)
                  && CurrentBid>(OrderOpenPrice()+PipsToCaptureProfitAt*PtsPerPip*Pt1))
                 {
                  newSL=NormalizeDouble((OrderStopLoss()+(PipsOfProfitToCapture+TrailingStep)*PtsPerPip*Pt1),NumDigits);
                  if(newSL<=NormalizeDouble(OrderStopLoss(),NumDigits))
                    {
                     capture=false;
                    }
                  else
                  //if(newSL>NormalizeDouble(OrderStopLoss(),NumDigits))
                    {
                     capture=true;
                    }
                 }
              }
            else if(OrderStopLoss()==0)
              {
               if(CurrentBid>(OrderOpenPrice()+PipsToCaptureProfitAt*PtsPerPip*Pt1))
                 {
                  newSL=NormalizeDouble((OrderOpenPrice()+(PipsOfProfitToCapture+TrailingStep)*PtsPerPip*Pt1),NumDigits);
                  capture=true;
                 }
              }
           }
         else if(OrderType()==OP_SELL)
           {
            if(OrderStopLoss()!=0)
              {

               if(CurrentAsk<(OrderStopLoss()-(PipsToCaptureProfitAt+TrailingStep)*PtsPerPip*Pt1)
                  && CurrentAsk<(OrderOpenPrice()-PipsToCaptureProfitAt*PtsPerPip*Pt1))
                 {
                  newSL=NormalizeDouble((OrderStopLoss()-(PipsOfProfitToCapture+TrailingStep)*PtsPerPip*Pt1),NumDigits);
                  if(newSL>=NormalizeDouble(OrderStopLoss(),NumDigits))
                    {
                     capture=false;
                    }
                  else
                  //if(newSL<NormalizeDouble(OrderStopLoss(),NumDigits))
                    {
                     capture=true;
                    }

                 }
              }
            else if(OrderStopLoss()==0)
              {
               if(CurrentAsk<(OrderOpenPrice()-PipsToCaptureProfitAt*PtsPerPip*Pt1))
                 {
                  newSL=NormalizeDouble((OrderOpenPrice()-(PipsOfProfitToCapture+TrailingStep)*PtsPerPip*Pt1),NumDigits);
                  capture=true;
                 }
              }
           }
         // Move SL to BE
         if(capture)
           {
            if(OrderStopLoss()!=newSL)
              {
               if(OrderModify(OrderTicket(),OrderOpenPrice(),newSL,OrderTakeProfit(),0)==true)
                 {
                  //Alert(OrderSymbol()," ",OrderType()," SL modiflied to ",newSL);
                  Print(OrderSymbol()," ",OrderType()," SL modiflied to ",newSL);
                  //Sleep(5000);
                 }
               else
                 {
                  int error=GetLastError();
                  Print("Failed to move SL on order: #"+IntegerToString(OrderTicket())
                        +". Error: "+IntegerToString(error));
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void ManageTrades()
  {
//for(int i=0;i<PairsQty;i++)
//{

   buy_newMarketOrders=getOrderCount(Symbol(),OP_BUY);
   buy_newPendingOrders=getOrderCount(Symbol(),OP_BUYLIMIT);
   sell_newMarketOrders=getOrderCount(Symbol(),OP_SELL);
   sell_newPendingOrders=getOrderCount(Symbol(),OP_SELLLIMIT);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(TimeGMT()>=StopTime && (buy_newMarketOrders==0 || buy_newPendingOrders>0))
     {
      Print("[INFO] Cancelling all pending orders as expiration time is reached...");
      Print("buy_newMarketOrders =",buy_newMarketOrders," buy_marketOrders =",buy_marketOrders);
      cancelPendingOrders(Symbol(),OP_BUYLIMIT);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(TimeGMT()>=StopTime && (sell_newMarketOrders==0 || sell_newPendingOrders>0))
     {
      Print("[INFO] Cancelling all pending orders as expiration time is reached...");
      Print("buy_newMarketOrders=",buy_newMarketOrders," buy_marketOrders =",buy_marketOrders);
      cancelPendingOrders(Symbol(),OP_SELLLIMIT);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(isAnyOrderActive(Symbol()))
     {
      // === BUY side of the grid ============================================================================================
      if(BuyPriceBelowMarket>0)
        {
         buy_newMarketOrders=getOrderCount(Symbol(),OP_BUY);
         buy_newPendingOrders=getOrderCount(Symbol(),OP_BUYLIMIT);
         sell_newMarketOrders=getOrderCount(Symbol(),OP_SELL);
         sell_newPendingOrders=getOrderCount(Symbol(),OP_SELLLIMIT);
         Print("buy_newMarketOrders =",buy_newMarketOrders," buy_marketOrders =",buy_marketOrders);
         // When first time buy_newMarketOrders>0 => Buy Trigger
         // Should delete Sell orders, this is PP rule
         if(buy_newMarketOrders>0 && sell_newMarketOrders==0 && sell_newPendingOrders>0)
           {
            cancelPendingOrders(Symbol(),OP_SELLLIMIT);
           }
         buy_currentLevel=levels-buy_newPendingOrders;
         if(buy_newMarketOrders==0 && buy_marketOrders>0)
           {
            Print("[INFO] Profit target reached. Cancelling remaining BUY pending orders...");
            BuyPriceBelowMarket=0.0;
            cancelPendingOrders(Symbol(),OP_BUYLIMIT);
            if(clearAllOrdersOnResolution)
              {
               Print("[INFO] Cancelling remaining SELL pending orders... (clearAllOrdersOnResolution)");
               cancelPendingOrders(Symbol(),OP_SELLLIMIT);
               cancelPendingOrders(Symbol(),OP_BUYLIMIT);
              }

           }
         if(buy_newMarketOrders>0 && buy_marketOrders>0 && buy_newMarketOrders>buy_marketOrders)
           {
            // New market order triggered - ajust TP
            Print("[INFO] New BUY market order triggered. Adjusting TPs on remaining...");
            double newBuyTakeProfitPrice=getBuyPriceByLevel(Symbol(),buy_currentLevel-1)+getTPPipsByLevel(buy_currentLevel-1)*pip;
            adjustTakeProfitOnMarketOrders(newBuyTakeProfitPrice,OP_BUY);

           }
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      // === SELL side of the grid ===========================================================================================
      if(SellPriceAboveMarket>0)
        {
         sell_newMarketOrders=getOrderCount(Symbol(),OP_SELL);
         sell_newPendingOrders=getOrderCount(Symbol(),OP_SELLLIMIT);
         buy_newMarketOrders=getOrderCount(Symbol(),OP_BUY);
         buy_newPendingOrders=getOrderCount(Symbol(),OP_BUYLIMIT);
         sell_currentLevel=levels-sell_newPendingOrders;
         if(sell_newMarketOrders>0 && buy_newMarketOrders==0 && buy_newPendingOrders>0)
           {
            cancelPendingOrders(Symbol(),OP_BUYLIMIT);
            cancelPendingOrders(Symbol(),OP_SELLLIMIT);
           }
         //if (sell_newMarketOrders == 0 && sell_marketOrders > 0 && sell_newPendingOrders > 0) {
         if(sell_newMarketOrders==0 && sell_marketOrders>0)
           {
            // TP reached
            Print("[INFO] Profit target reached. Cancelling remaining SELL pending orders...");
            SellPriceAboveMarket=0.0;
            cancelPendingOrders(Symbol(),OP_SELLLIMIT);
            if(clearAllOrdersOnResolution)
              {
               Print("[INFO] Cancelling remaining BUY pending orders... (clearAllOrdersOnResolution)");
               cancelPendingOrders(Symbol(),OP_BUYLIMIT);
              }

              } else if(sell_newMarketOrders>0 && sell_marketOrders>0 && sell_newMarketOrders!=sell_marketOrders) {
            // New market order triggered - ajust TP
            Print("[INFO] New SELL market order triggered. Adjusting TPs on remaining...");
            double newSellTakeProfitPrice=getSellPriceByLevel(Symbol(),sell_currentLevel-1)-getTPPipsByLevel(sell_currentLevel-1)*pip;
            adjustTakeProfitOnMarketOrders(newSellTakeProfitPrice,OP_SELL);

           }
        }
      buy_marketOrders=buy_newMarketOrders;
      buy_pendingOrders=buy_newPendingOrders;
      sell_marketOrders=sell_newMarketOrders;
      sell_pendingOrders=sell_newPendingOrders;
      //}
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //else
      //{
      //State=WAIT_FOR_NEW_DAY;
      //}
     }

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Value of one pip based on broker digit count                     |
//+------------------------------------------------------------------+
double getPipValue()
  {
   double p=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Digits==2 || Digits==4)
     {
      p=Point;
        } else if(Digits==3 || Digits==5) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      p=10*Point;
        } else if(Digits==6) {
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      p=100*Point;
     }

   return(p);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getOrderCount(string sym,int orderType)
  {
   int count=0;
   int i;
   for(i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      if(OrderSymbol()!=sym) continue;
      if(OrderMagicNumber()!=Magic) continue;
      if(OrderType()!=orderType) continue;
      count++;
     }
   return(count);
  }
//+------------------------------------------------------------------+
void showMessage(string text,bool sendEmail)
  {
   Print(text);
   Alert(Symbol()+" "+WindowExpertName()+". "+text);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(sendEmail && !IsTesting() && !IsOptimization())
     {
      string subject="Error in Account: "+DoubleToStr(AccountNumber(),0)
                     +" ("+WindowExpertName()+")";
      string body=
                  "Account name: "+AccountName()+"\n"+
                  "Account number: "+DoubleToStr(AccountNumber(),0)+"\n"+
                  "Symbol: "+Symbol()+"\n"+
                  "Timeframe: "+TFToStr(Period())+"\n"+
                  "Bot: "+WindowExpertName()+"\n"+
                  "Magic: "+DoubleToStr(Magic,0)+"\n"+
                  "\n"+
                  "Error: "+"\n"+
                  text;
      // MT4 bug: have to call GetLastError() before 
      // using SendMail() to clear the error buffer.
      GetLastError();
      SendMail(subject,body);
      int error= GetLastError();
      if(error!=ERR_NO_ERROR)
        {
         string emailError="Error sending email. Code: "+DoubleToStr(error,0)
                           +", description: "+ErrorDescription(error);
         Alert(emailError);
         Print(emailError);
        }
     }
  }
//+------------------------------------------------------------------+
void cancelPendingOrders(string sym,int orderType)
  {
   int i;
   for(i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      if(OrderSymbol()!=sym) continue;
      if(OrderMagicNumber()!=Magic) continue;
      if(OrderType()!=orderType) continue;

      cancelPendingOrder(OrderTicket());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool isAnyOrderActive(string sym)
  {
   bool open=false;
   int i;
   for(i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      if(OrderSymbol()==sym && OrderMagicNumber()==Magic && (OrderType()==OP_BUY || OrderType()==OP_BUY))
        {
         open=true;
         break;
        }
     }

   return(open);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void adjustTakeProfitOnMarketOrders(double newTakeProfitPrice,int orderType)
  {
   newTakeProfitPrice=NormalizeDouble(newTakeProfitPrice,Digits);
   Print("adjustTakeProfitOnMarketOrders ",DoubleToStr(newTakeProfitPrice,Digits));
   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderMagicNumber()!=Magic) continue;
      if(OrderType()!=orderType) continue;
      if(newTakeProfitPrice==NormalizeDouble(OrderTakeProfit(),Digits)) continue;

      if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),newTakeProfitPrice,0))
        {
         int error=GetLastError();
         showMessage("[ERROR] Failed to move SL on order: #"+DoubleToStr(OrderTicket(),0)
                     +". Error: "+DoubleToStr(error,0)+". "+ErrorDescription(error),sendEmailOnError);
        }
     }
  }
//+------------------------------------------------------------------+
//| Returns last market order open time if there's one, otherwise -1 |
//+------------------------------------------------------------------+
datetime getLastMarketOrderOpenTime()
  {
   datetime openTime=-1;

   for(int i=OrdersTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(!OrderSelect(i,SELECT_BY_POS)) continue;
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderMagicNumber()!=Magic) continue;
      if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;

      openTime=OrderOpenTime();
      break;
     }

   return(openTime);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TFToStr(int tf=0)
  {
   if(tf==0) tf=Period();
   if(tf >= 43200)    return("MN");
   if(tf >= 10080)    return("W1");
   if(tf >=  1440)    return("D1");
   if(tf >=   240)    return("H4");
   if(tf >=    60)    return("H1");
   if(tf >=    30)    return("M30");
   if(tf >=    15)    return("M15");
   if(tf >=     5)    return("M5");
   if(tf >=     1)    return("M1");
   return("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void cancelPendingOrder(int ticket)
  {
   if(!OrderSelect(ticket,SELECT_BY_TICKET))
     {
      showMessage("Failed to select order by ticket #"+DoubleToStr(ticket,0),sendEmailOnError);
      return;
     }

// Print info about order being cancelled to the log
   OrderPrint();
// Try to delete order multiple times in case of non-critical error
   while(!IsStopped())
     {
      bool result=OrderDelete(OrderTicket());

      if(result!=true)
        {
         int error=GetLastError();

         switch(error)
           {
            case ERR_PRICE_CHANGED: Comment("The price has changed. Retrying...");
            RefreshRates();                     // Update data
            continue;                           // Try again on next iteration
            case ERR_OFF_QUOTES: Comment("Off quotes. Waiting for a new tick...");
            while(RefreshRates()==false)        // Up to a new tick
               Sleep(100);                      // Cycle delay
            continue;                           // Try again on next iteration
            case ERR_TRADE_CONTEXT_BUSY: Comment("Trade context is busy. Retrying...");
            Sleep(500);                         // Simple solution
            RefreshRates();                     // Update data
            continue;                           // Try again on next iteration
            default:
               showMessage("Cannot send order, error: "+DoubleToStr(error,0)+". "+ErrorDescription(error),sendEmailOnError);
           }
        }

      // Break "while" loop
      break;
     }

// Clear comment
   Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PairsQty(string s)
  {
   int i=0;
   int j=0;
   int qty=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(i>-1)
     {
      i=StringFind(s,",",j);
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(i>-1)
        {
         qty++;
         j=i+1;
        }
     }
   return(qty);
  }
//+------------------------------------------------------------------+
int CheckForUpperLevelTrigger(string sym,double UpperTriggerLevel1)
  {
//Print("CheckForUpperLevelTrigger");
   int ret=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(MarketInfo(sym,MODE_BID)>UpperTriggerLevel1)
     {
      ret=UPPER_LEVEL_TRIGGERED;
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckForLowerLevelTrigger(string sym,double LowerTriggerLevel1)
  {
//Print("CheckForLowerLevelTrigger");
   int ret=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(MarketInfo(sym,MODE_ASK)<LowerTriggerLevel1)
     {
      ret=LOWER_LEVEL_TRIGGERED;
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllOrders()
  {
   int total= OrdersTotal();
   for(int i=total-1;i>=0;i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(i,SELECT_BY_POS)==true && OrderMagicNumber()==Magic)
        {
         int type=OrderType();
         bool result=false;
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         switch(type)
           {
            //Close opened long positions
            case OP_BUY       : result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Red);
            break;

            //Close opened short positions
            case OP_SELL      : result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Red);
            break;

            //Close pending orders
            case OP_BUYLIMIT  :
            case OP_BUYSTOP   :
            case OP_SELLLIMIT :
            case OP_SELLSTOP  : result=OrderDelete(OrderTicket());
           }
         if(result==false)
           {
            Alert("Order ",OrderTicket()," failed to close. Error:",GetLastError());
            Sleep(3000);
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
bool CheckNewDay()
  {
// if CurrentTime>NextDayStartTime( initialised to next 2200 GMT ahead )
   bool ret=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(TimeGMT()>TimeNextDay)
     {
      TimeNextDay=TimeGMT()+24*60*60;
      //TimeNextDay=TimeNextDay+12*60*60;
      //StopTime=TimeGMT()+OrderDurationHour*60*60;
      ObjectSet("CycleStart",OBJPROP_TIME1,TimeGMT());
      ObjectSet("CycleStop",OBJPROP_TIME1,TimeNextDay);
      ret=true;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      ret=false;
     }
   return (ret);
  }
//+------------------------------------------------------------------+
double GetStartingLots()
{
double MaxLoss=AccountEquity()*RiskPercent/100;
startingLot=MaxLoss/(SL*10.0);
return(startingLot);
}
