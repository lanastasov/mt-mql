//+-------------------------------------------------------------------+
//|                                       TradeManagerEA1.0.mq4       |
//|                      Copyright © 2013, WildhorseEnterprises       |
//|                                        http://www.metaquotes.net  |
//|
#property copyright "Copyright © 2013, Wildhorse Enterprises"
#property link      ""

#define BUY 1
#define SELL -1
#define FLAT 0
#define GOOD 1
#define PRICE 2
#define TAKE 3
#define STOP 4

extern bool    ManageAllTrades = true,
               ManageManualTradesOnly = false,
               ManageChartPairOnly = false,
               TimedClose = false,
               CloseOnSpecificTime = true,
               CloseOnlyInProfit = false;
extern string  SpecificCloseTime = "23:00";               
extern int     MagicID = 0;
extern double  OrderCloseMinutes = 10;
extern bool    SetSL_TP = true;
extern int     SL = 0,
               TP = 0;
extern bool    UseBasketProfit = false;
extern double  BasketProfit = 5;
extern bool    UseEquityPctClose = false;
extern double  EquityPct = 2.0;
extern bool    UsePipProfit = false;
extern double  PipProfit = 5.0;
extern int     Slippage = 5;
extern string  b1 = "BE Options";
extern bool    UseStdBE = false;
extern double  BreakEvenPips = 20;
extern double  LockInPips = 2;
extern string  t0 = "Trail Stop settings";
extern bool    UseTrailingStop = false;
extern double  TrailStart = 40,
               TrailStop = 10;
extern bool    UseSRTrailStop = false;
extern int     SR_TimeFrame=0;
extern double  SLPipDiff = 1;
extern bool    AddSpread = true;
extern bool    UsePercentTS = false;
extern double  TSPercent = 30.0;
extern double  TSPercentStartPips = 20;
extern bool    UsePSARTrail = false;
extern int     PSAR_TimeFrame=0;
extern double  PSAR_Step = 0.005,
               PSAR_Max = 0.05;
extern bool    MoveSL_TP = false;
extern double  TP_DistancePips = 10,
               MovePips = 10;
extern bool    UseCandleTrail = false;
extern int     CT_TimeFrame=0;
extern int     TrailCandlesBack = 3,
               StartCTPips = 20;

double GetRes(string symbol) {
   double result=0.0,fractal=0.0;
   for (int ct=1;ct<iBars(symbol,SR_TimeFrame);ct++) {
      fractal=iFractals(symbol,SR_TimeFrame,MODE_UPPER,ct);
      if (fractal>0.0) {
         result=fractal;
         break;
         }
      }
   result=MathMax(result,iHigh(symbol,SR_TimeFrame,iHighest(symbol,SR_TimeFrame,MODE_HIGH,2,1)));
   return(result);
}
double GetSup(string symbol) {
   double result=0.0,fractal=0.0;
   for (int ct=1;ct<iBars(symbol,SR_TimeFrame);ct++) {
      fractal=iFractals(symbol,SR_TimeFrame,MODE_LOWER,ct);
      if (fractal>0.0) {
         result=fractal;
         break;
         }
      }
   result=MathMin(result,iLow(symbol,SR_TimeFrame,iLowest(symbol,SR_TimeFrame,MODE_LOW,2,1)));
   return(result);
}
void deinit() {
   Comment("");
}
void init(){
   double Profit,PProfit,HistoryProfit;
   while (true) {
      Profit=0;
      PProfit=0;
      HistoryProfit=0;
      RefreshRates();
      for (int l = OrdersTotal()-1; l>=0; l--) {
         if (!OrderSelect(l, SELECT_BY_POS,MODE_TRADES)) continue;
         if ((!ManageChartPairOnly || OrderSymbol()==Symbol()) && (ManageAllTrades || (ManageManualTradesOnly && OrderMagicNumber()==0) || OrderMagicNumber()==MagicID)) {
            if (UseTrailingStop) UpdateTrail(l);
            if (UsePSARTrail) UpdatePSARTrail(l);
            if (UsePercentTS) UpdatePctTS(l);
            if (UseStdBE) GoToBE(l);
            if (MoveSL_TP) MoveSLTP(l);
            if (SetSL_TP) SetSLTP(l);
            Profit+=OrderProfit()+OrderCommission()+OrderSwap();
            if (OrderType() == OP_BUY) {
               if (((TimedClose && TimeCurrent()-OrderOpenTime()>=OrderCloseMinutes*60) || (CloseOnSpecificTime && TimeCurrent()>=StrToTime(SpecificCloseTime))) &&  
                   (!CloseOnlyInProfit || OrderProfit()>=0)) {
                  CloseBuy(l);
                  continue;
                  }
               if (UseCandleTrail && (MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice()>=StartCTPips*Pt(OrderSymbol()))) UpdateCandleTrail(l);
               if (UseSRTrailStop) {
                  double Sup=GetSup(OrderSymbol());
                  UpdateSRTrailStop(l,Sup);
                  }
               PProfit+=(OrderClosePrice()-OrderOpenPrice())/Pt(OrderSymbol());
               }
            else if (OrderType() == OP_SELL) {
               if (((TimedClose && TimeCurrent()-OrderOpenTime()>=OrderCloseMinutes*60) || (CloseOnSpecificTime && TimeCurrent()>=StrToTime(SpecificCloseTime))) &&  
                   (!CloseOnlyInProfit || OrderProfit()>=0)) {
                  CloseSell(l);
                  continue;
                  }
               if (UseCandleTrail && (OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK)>=StartCTPips*Pt(OrderSymbol()))) UpdateCandleTrail(l);
               if (UseSRTrailStop) {
                  double Res=GetRes(OrderSymbol());
                  UpdateSRTrailStop(l,Res);
                  }
               PProfit+=(OrderOpenPrice()-OrderClosePrice())/Pt(OrderSymbol());
               }
            }
         }
      for (l=0;l<OrdersHistoryTotal();l++) {
         if (!OrderSelect(l, SELECT_BY_POS,MODE_HISTORY)) continue;
         if (OrderMagicNumber()==MagicID) {
            HistoryProfit+=OrderProfit()+OrderSwap()+OrderCommission();
            }
         }
      Comment("Total profit   = ",NormalizeDouble(Profit,2),"\n",
              "Pip profit     = ",NormalizeDouble(PProfit,1),"\n",
              "History profit = ",NormalizeDouble(HistoryProfit,2));
      if ((UseBasketProfit && Profit>=BasketProfit && BasketProfit>0) || (UseEquityPctClose && Profit/AccountEquity()>=EquityPct/100) || (UsePipProfit && PProfit>=PipProfit))
         CloseAll();
      Sleep(1000);
      }
   return;
}
void start() {
   init();
   return;
} 
bool CloseAll() {
   int ct;
   bool err;
   for (int cnt=OrdersTotal()-1; cnt>=0 ; cnt--) {
      if (!OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES)) continue;
      if ((!ManageChartPairOnly || OrderSymbol()==Symbol()) && (ManageAllTrades || (ManageManualTradesOnly && OrderMagicNumber()==0) || OrderMagicNumber()==MagicID)) {
         ct=0;
         err=false;
         while (!err && ct<50) {
            RefreshRates();
            if (OrderType()==OP_BUY) 
               err = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(), Slippage, Blue);
            else if (OrderType()==OP_SELL)
               err = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(), Slippage, Red);
            else if (OrderType()>1) err=OrderDelete(OrderTicket());
            ct++;
            }
         if (!err) Print("Close unsuccessful - ticket #",OrderTicket()," - error ",GetLastError());
         }
      }
   return(true);
}
 
bool CloseBuy(int ticket) {
   int ct;
   bool err;
   if (ticket<0) {
      for (int cnt=OrdersTotal()-1; cnt>=0; cnt--) {
         if (!OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES)) continue;
         if ((!ManageChartPairOnly || OrderSymbol()==Symbol()) && (ManageAllTrades || (ManageManualTradesOnly && OrderMagicNumber()==0) || OrderMagicNumber()==MagicID) && OrderType() == OP_BUY) {
            ct=0;
            err=false;
            while (!err && ct<50) {
               while (!IsTradeAllowed()) Sleep(500);
               RefreshRates();
               err = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(), Slippage, Blue);
               ct++;
               }
            if (!err) {
               Alert("Close buy unsuccessful - ",GetLastError());
               return(false);
               }
            }
         }
      }
   else {
      if (OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) {
         ct=0;
         err=false;
         while (!err && ct<50) {
            while (!IsTradeAllowed()) Sleep(500);
            RefreshRates();
            err = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(), Slippage, Blue);
            ct++;
            }     
         if (!err) {
            Alert("Close buy unsuccessful - ",GetLastError());
            return(false);
            }
         }
      }
   return(true);
}
bool CloseSell(int ticket) {
   int ct;
   bool err;
   if (ticket<0) {
      for (int cnt=OrdersTotal()-1; cnt>=0; cnt--) {
         if (!OrderSelect(cnt, SELECT_BY_POS,MODE_TRADES)) continue;
         if ((!ManageChartPairOnly || OrderSymbol()==Symbol()) && (ManageAllTrades || (ManageManualTradesOnly && OrderMagicNumber()==0) || OrderMagicNumber()==MagicID) && OrderType() == OP_SELL) {
            ct=0;
            err=false;
            while (!err && ct<50) {
               while (!IsTradeAllowed()) Sleep(500);
               RefreshRates();
               err = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage, Red);
               ct++;
               }
            if (!err) {
               Alert("Close sell unsuccessful - ",GetLastError());
               return(false);
               }
            }
         }
      }
   else {
      if (OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) {
         ct=0;
         err=false;
         while (!err && ct<50) {
            while (!IsTradeAllowed()) Sleep(500);
            RefreshRates();
            err = OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(), Slippage, Red);
            ct++;
            }     
         if (!err) {
            Alert("Close sell unsuccessful - ",GetLastError());
            return(false);
            }
         }
      }
   return(true);
}   
void UpdateTrail (int ticket) {
   RefreshRates();
   double NewStop;
   bool err;
   if (!OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) return;
   int digits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point=Pt(OrderSymbol());
   if (OrderType() == OP_BUY) {
      if (TrailStop>0&&NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)-TrailStart*point,digits)>NormalizeDouble(OrderOpenPrice(),digits)) {                 
         if(NormalizeDouble(OrderStopLoss(),digits)<NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-TrailStop*point,digits)||(OrderStopLoss()==0)) {
            NewStop = MarketInfo(OrderSymbol(),MODE_BID)-TrailStop*point;
            if (NormalizeDouble(OrderStopLoss(),digits)<NormalizeDouble(NewStop,digits)&& NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopRange(OrderSymbol())*point,digits)>NormalizeDouble(NewStop,digits)) {
               err=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Blue);
               if (!err) Print ("Error modifying order on TrailStop: ",GetLastError());
               }
            }
         }
      }
   else if (OrderType() == OP_SELL) {
      if (TrailStop>0&&NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)+TrailStart*point,digits)<NormalizeDouble(OrderOpenPrice(),digits)) {                 
         if (NormalizeDouble(OrderStopLoss(),digits)>NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+TrailStop*point,digits)||(OrderStopLoss()==0)) {
            NewStop = MarketInfo(OrderSymbol(),MODE_ASK)+TrailStop*point;
            if (NormalizeDouble(OrderStopLoss(),digits) > NormalizeDouble(NewStop,digits) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopRange(OrderSymbol())*point,digits)<NormalizeDouble(NewStop,digits)) {
               err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Red);
               if (!err) Print ("Error modifying order on TrailStop: ",GetLastError());
               }
            }
         }
      }
   return;
}
void UpdateSRTrailStop (int ticket, double newStop) {
   bool err;
   if (!OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) return;
   int digits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point=Pt(OrderSymbol());
   if (OrderType() == OP_BUY) {
      newStop -= SLPipDiff*point;
      if (AddSpread) newStop -= MarketInfo(OrderSymbol(),MODE_SPREAD)*MarketInfo(OrderSymbol(),MODE_POINT);
      //if (MarketInfo(OrderSymbol(),MODE_BID)<=newStop) CloseBuy(ticket);
      if (NormalizeDouble(OrderStopLoss(),digits)<NormalizeDouble(newStop,digits) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopRange(OrderSymbol())*point,digits)>NormalizeDouble(newStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(newStop,digits),OrderTakeProfit(),0,Blue);
         if (!err) Print ("Error modifying order on SRTrail: ",GetLastError());
         }
      }
   else if (OrderType() == OP_SELL) {
      newStop += SLPipDiff*Pt(OrderSymbol());
      if (AddSpread) newStop -= MarketInfo(OrderSymbol(),MODE_SPREAD)*MarketInfo(OrderSymbol(),MODE_POINT);
      //if (MarketInfo(OrderSymbol(),MODE_ASK)>=newStop) CloseSell(ticket);
      if ((NormalizeDouble(OrderStopLoss(),digits)>NormalizeDouble(newStop,digits) || OrderStopLoss()==0.0) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopRange(OrderSymbol())*point,digits)<NormalizeDouble(newStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(newStop,digits),OrderTakeProfit(),0,Red);
         if (!err) Print ("Error modifying order on SRTrail: ",GetLastError());
         }
      }
   return;
}
void UpdatePctTS (int ticket) {
   RefreshRates();
   double NewStop,MaxPrice;
   int TradeTime;
   bool err;
   if (!OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) return;
   int digits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point=Pt(OrderSymbol());
   TradeTime=iBarShift(OrderSymbol(),0,OrderOpenTime(),true);
   if (OrderType() == OP_BUY) {
      MaxPrice=iHigh(OrderSymbol(),0,iHighest(OrderSymbol(),0,MODE_HIGH,TradeTime,0));
      NewStop = MaxPrice-(MaxPrice-OrderOpenPrice())*TSPercent/100;
      if (TSPercentStartPips>0&&NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)-TSPercentStartPips*point,digits)>NormalizeDouble(OrderOpenPrice(),digits)) {                 
         if(NormalizeDouble(OrderStopLoss(),digits)<NormalizeDouble(NewStop,digits) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopRange(OrderSymbol())*point,digits)>NormalizeDouble(NewStop,digits)) {
            err=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Blue);
            if (!err) Print ("Error modifying order on PCT TrailStop: ",GetLastError());
            }
         }
      }
   else if (OrderType() == OP_SELL) {
      MaxPrice=iLow(OrderSymbol(),0,iLowest(OrderSymbol(),0,MODE_LOW,TradeTime,0));
      NewStop = MaxPrice+(OrderOpenPrice()-MaxPrice)*TSPercent/100;
      if (TSPercentStartPips>0&&NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)+TSPercentStartPips*Pt(OrderSymbol()),digits)<NormalizeDouble(OrderOpenPrice(),digits)) {                 
         if ((NormalizeDouble(OrderStopLoss(),digits)>NormalizeDouble(NewStop,digits) || OrderStopLoss()==0.0) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopRange(OrderSymbol())*point,digits)<NormalizeDouble(NewStop,digits)) {
            err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Red);
            if (!err) Print ("Error modifying order on PCT TrailStop: ",GetLastError());
            }
         }
      }
   return;
}

void UpdateCandleTrail (int ticket) {
   double NewStop;
   bool err;
   if (!OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) return;
   int digits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point=Pt(OrderSymbol());
   if (OrderType() == OP_BUY) {
      NewStop = iLow(OrderSymbol(),0,iLowest(OrderSymbol(),CT_TimeFrame,MODE_LOW,TrailCandlesBack,0))-SLPipDiff*point;
      if (NormalizeDouble(OrderStopLoss(),digits) < NormalizeDouble(NewStop,digits) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopRange(OrderSymbol())*point,digits)>NormalizeDouble(NewStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Blue);
         if (!err) Print ("Error modifying order on candletrail: ",GetLastError());
         }
      }
   else if (OrderType() == OP_SELL) {
      NewStop = iHigh(OrderSymbol(),0,iHighest(OrderSymbol(),CT_TimeFrame,MODE_HIGH,TrailCandlesBack,0))+SLPipDiff*point;
      if ((NormalizeDouble(OrderStopLoss(),digits) > NormalizeDouble(NewStop,digits) || OrderStopLoss()==0.0) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopRange(OrderSymbol())*point,digits)<NormalizeDouble(NewStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Red);
         if (!err) Print ("Error modifying order on candletrail: ",GetLastError());
         }
      }
   return;
}
void UpdatePSARTrail (int ticket) {
   double NewStop=iSAR(OrderSymbol(),PSAR_TimeFrame,PSAR_Step,PSAR_Max,0);
   bool err;
   if (!OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) return;
   int digits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point=Pt(OrderSymbol());
   if (OrderType() == OP_BUY) {
      NewStop -= SLPipDiff*point;
      if (AddSpread) NewStop -= MarketInfo(OrderSymbol(),MODE_SPREAD)*MarketInfo(OrderSymbol(),MODE_POINT);
      //if (MarketInfo(OrderSymbol(),MODE_BID)<=NewStop) CloseBuy(ticket);
      if (NormalizeDouble(OrderStopLoss(),digits) < NormalizeDouble(NewStop,digits) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopRange(OrderSymbol())*point,digits)>NormalizeDouble(NewStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Blue);
         if (!err) Print ("Error modifying order on PSAR trail: ",GetLastError());
         }
      }
   else if (OrderType() == OP_SELL) {
      NewStop += SLPipDiff*Pt(OrderSymbol());
      if (AddSpread) NewStop -= MarketInfo(OrderSymbol(),MODE_SPREAD)*MarketInfo(OrderSymbol(),MODE_POINT);
      //if (MarketInfo(OrderSymbol(),MODE_ASK)>=NewStop) CloseSell(ticket);
      if ((NormalizeDouble(OrderStopLoss(),digits) > NormalizeDouble(NewStop,digits) || OrderStopLoss()==0.0) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopRange(OrderSymbol())*point,digits)<NormalizeDouble(NewStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Red);
         if (!err) Print ("Error modifying order on PSAR trail: ",GetLastError());
         }
      }
   return;
}
void GoToBE(int ticket) {
   double NewStop;
   bool err;
   if (!OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) return;
   int digits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point=Pt(OrderSymbol());
   if (OrderType() == OP_BUY) {
      NewStop = OrderOpenPrice()+ LockInPips*point;
      if (MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice()>=BreakEvenPips*point && NormalizeDouble(OrderStopLoss(),digits)<NormalizeDouble(NewStop,digits)
         && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopRange(OrderSymbol())*point,digits)>NormalizeDouble(NewStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Blue);
         if (!err) Print ("Error modifying order on BE: ",GetLastError());
         }
      }
   else if (OrderType() == OP_SELL) {
      NewStop = OrderOpenPrice()- LockInPips*point;
      if (OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK)>=BreakEvenPips*point && (NormalizeDouble(OrderStopLoss(),digits)>NormalizeDouble(NewStop,digits) || OrderStopLoss()==0.0)
          && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopRange(OrderSymbol())*point,digits)<NormalizeDouble(NewStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),OrderTakeProfit(),0,Red);
         if (!err) Print ("Error modifying order on BE: ",GetLastError());
         }
      }
   return;
}
void MoveSLTP(int ticket) {
   double NewStop,NewTake;
   bool err;
   if (!OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) return;
   int digits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point=Pt(OrderSymbol());
   if (OrderType() == OP_BUY) {
      if (OrderTakeProfit()-MarketInfo(OrderSymbol(),MODE_BID)<=TP_DistancePips*point && OrderStopLoss()>0.0 && OrderTakeProfit()>0.0) {
         NewStop = OrderStopLoss()+MovePips*point;
         NewTake = OrderTakeProfit()+MovePips*point;
         if (NormalizeDouble(OrderStopLoss(),digits)<NormalizeDouble(NewStop,digits) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopRange(OrderSymbol())*point,digits)>NormalizeDouble(NewStop,digits)) {
            err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),NormalizeDouble(NewTake,digits),0,Blue);
            if (!err) Print ("Error modifying order on MoveSL_TP: ",GetLastError());
            }
         }
      }
   else if (OrderType() == OP_SELL) {
      if (MarketInfo(OrderSymbol(),MODE_ASK)-OrderTakeProfit()<=TP_DistancePips*point && OrderStopLoss()>0.0 && OrderTakeProfit()>0.0) {
         NewStop = OrderStopLoss()-MovePips*point;
         NewTake = OrderTakeProfit()-MovePips*point;
         if ((NormalizeDouble(OrderStopLoss(),digits)>NormalizeDouble(NewStop,digits) || OrderStopLoss()==0.0) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopRange(OrderSymbol())*point,digits)<NormalizeDouble(NewStop,digits)) {
            err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),NormalizeDouble(NewTake,digits),0,Red);
            if (!err) Print ("Error modifying order on MoveSL_TP: ",GetLastError());
            }
         }
      }
   return;
}
void SetSLTP(int ticket) {
   double NewStop,NewTake;
   bool err;
   if (!OrderSelect(ticket, SELECT_BY_POS,MODE_TRADES)) return;
   int digits=MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point=Pt(OrderSymbol());
   if (OrderType() == OP_BUY) {
      NewStop = OrderOpenPrice()-SL*point;
      NewTake = OrderOpenPrice()+TP*point;
      if (NormalizeDouble(OrderStopLoss(),digits)<NormalizeDouble(NewStop,digits) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopRange(OrderSymbol())*point,digits)>NormalizeDouble(NewStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),NormalizeDouble(NewTake,digits),0,Blue);
         if (!err) Print ("Error modifying order on MoveSL_TP: ",GetLastError());
         }
      }
   else if (OrderType() == OP_SELL) {
      NewStop = OrderOpenPrice()+SL*point;
      NewTake = OrderOpenPrice()-TP*point;
      if ((NormalizeDouble(OrderStopLoss(),digits)>NormalizeDouble(NewStop,digits) || OrderStopLoss()==0.0) && NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopRange(OrderSymbol())*point,digits)<NormalizeDouble(NewStop,digits)) {
         err = OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(NewStop,digits),NormalizeDouble(NewTake,digits),0,Red);
         if (!err) Print ("Error modifying order on MoveSL_TP: ",GetLastError());
         }
      }
   return;
}
   
int StopRange(string symbol) {
   int X=1;
   int digits=MarketInfo(symbol,MODE_DIGITS);
   if (digits==5 || digits==3) X=10;
   return(MarketInfo(symbol,MODE_STOPLEVEL)/X);
}
double Pt(string symbol) {
   int X=1;
   int digits=MarketInfo(symbol,MODE_DIGITS);
   if (digits==5 || digits==3) X=10;
   return(X*MarketInfo(symbol,MODE_POINT));
}