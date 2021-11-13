//+------------------------------------------------------------------+
//|                                                    _fix_open.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#define pdxversion "1.00"
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://www.mql5.com/en/users/needtome"
#property version   pdxversion
#property description "This advisor helps you to open a deal with a stop loss no more than the amount you specified."
#property description "That is, it determines the number of lots to which you want to make a deal, so that the stop loss does not exceed the indicated amount in dollars."
#property description "Keys:"
#property description "X - quit, S - send order and quit, U - min stop BUY, L - min stop SELL, Z - reset Open Price"
#property description "2 - 0.2% stop Long, 3 - 0.2% stop Short, 7 - CENT_STOP stop Long, 8 - CENT_STOP stop Short"
#property strict

double            OPEN_PRICE=0; //Opening price (0 - by market)
double            STOPLOSS_PRICE=0; //Stop loss Price

enum TYPESTOP
  {
   dollar,// $
   percent,// % of deposit
  }; 
enum TypeOfPos
  {
   MY_BUY,
   MY_SELL,
   MY_BUYSTOP,
   MY_BUYLIMIT,
   MY_SELLSTOP,
   MY_SELLLIMIT,
   MY_BUYSLTP,
   MY_SELLSLTP,
  }; 
   enum TypeOfLang{
      MY_ENG, // English
      MY_RUS, // Russian
   }; 

input TYPESTOP    Type_STOP=dollar; //Stop Loss type
input double      STOP_IN=10; //Stop loss as $ or %
input double      CENT_STOP=0.001; //Stop loss in cents (keys 7 and 8)
input bool        EXIT_IF_MORE=true; //No deal entry if with min. lot the risk is greater than specified
input uchar       DEL_END_DAY=0; //Cancel limit order after, hours
input uchar       TAKE_MULTIPLY=4; //Multiplier for take profit calculation
input string      MY_COMMENT=""; //Comment
#ifdef __MQL5__ 
   enum TypeOfFilling //Filling Mode
     {
      FOK,//ORDER_FILLING_FOK
      RETURN,// ORDER_FILLING_RETURN
      IOC,//ORDER_FILLING_IOC
     }; 
   input TypeOfFilling  useORDER_FILLING_RETURN=FOK; //Order filling mode
#endif 

input int         EA_Magic=777; // Magic number for the first position
input TypeOfLang  LANG=MY_RUS; // Language

int curMagic=0;
int lastOrder;
double open=OPEN_PRICE;
bool isLong=true;
double lot=0.01;
double profit=0;
double stopin_value;
double takein_value=0;
double takein_line1=0;
long chart_ID=0;
string symbols="";
int tmp_val=0;
double curPoint=0;
double curBid=0;
double curAsk=0;
double curSpread=0;
string exprefix="fixopen";
MqlRates rates[];
MqlTick lastme;
double maxLot=0;

MqlDateTime curDay;
datetime dfrom;
datetime dto;
MqlDateTime curEndTime;
MqlDateTime curStartTime;
string time_info="";

double draw_stop=0;
double draw_open=0;
string resval;
double curMinStop=0;
string currencyS;
bool isEndTime=false;
bool isClosed=false;

struct translate{
   string err1;
   string err2;
   string err3;
   string err4;
   string err5;
   string err6;
   string err7;
   string err8;
   string err9;
   string err64;
   string err65;
   string err128;
   string err129;
   string err130;
   string err131;
   string err132;
   string err133;
   string err134;
   string err135;
   string err136;
   string err137;
   string err138;
   string err139;
   string err140;
   string err141;
   string err145;
   string err146;
   string err147;
   string err148;
   string err0;
   string CheckBox1;
   string CheckBox2;
   string CheckBox4;
   string CheckBox5;
   string CheckBox6;
   string CheckBox7;
   string Label1;
   string Label1_min;
   string Label1_freeze;
   string Label1_spread;
   string Label2;
   string Label3;
   string Label6;
   string Label7;
   string Label11;
   string Label12;
   string Button1;
   string Button1_buy;
   string Button1_sell;
   string Button2;
   string Label4;
   string Label5;
   string ComboBox1_item0;
   string ComboBox1_item1;
   string wrnType_STOP;
   string wrnTAKE_MULTIPLY;
   string wrnDEMO;
   string wrnSTOPLOSS_PRICE;
   string wrnTAKE_LEVEL1;
   string wrnTAKE_LEVEL2;
   string wrnTAKE_LEVEL3;
   string wrnEXIT_IF_MORE1;
   string wrnEXIT_IF_MORE2;
   string wrnONLY_WRITE1;
   string wrnONLY_WRITE2;
   string wrnONLY_WRITE3;
   string wrnONLY_WRITE4;
   string wrnSTOPLOSS_PRICE2;
   string wrnSTOP_IN;
   string wndTITLE;
   string wrnTAKEIN_LESS;
   string retcode;
   string retcode10004;
   string retcode10006;
   string retcode10007;
   string retcode10010;
   string retcode10011;
   string retcode10012;
   string retcode10013;
   string retcode10014;
   string retcode10015;
   string retcode10016;
   string retcode10017;
   string retcode10018;
   string retcode10019;
   string retcode10020;
   string retcode10021;
   string retcode10022;
   string retcode10023;
   string retcode10024;
   string retcode10025;
   string retcode10026;
   string retcode10027;
   string retcode10028;
   string retcode10029;
   string retcode10030;
   string retcode10031;
   string retcode10032;
   string retcode10033;
   string retcode10034;
   string retcode10035;
   string retcode10036;
   string retcode10038;
   string retcode10039;
   string retcode10040;
   string retcode10041;
   string retcode10042;
   string retcode10043;
   string retcode10044;
   string wrnSYMBOL_TRADE_TICK_SIZE;
   string wrnSYMBOL_TRADE_TICK_SIZE2;
   string wrnSYMBOL_TRADE_TICK_SIZE_end;
   string DEL_END_DAY_val1;
   string DEL_END_DAY_val2;
   string DEL_END_DAY_val3;
   string DEL_END_DAY_val4;
   string DEL_END_DAY_val5;
   string lblMinSTOP;
   string lblNo;
   string lblDef;
   string noMinStop;
   string lblshow_SWAP;
   string lbl_point;
   string lblshow_TIME;
   string lblshow_TIME2;
   string lbl_min;
   string lbl_hour;
   string lbl_close;
   string wrnMinVolume;
   string wrnOnlyClose;
   string wrnMaxLot;
   string maxMarga;
   string noBalance;
   string maxCount;
   string btnShowOpenLine;
   string btnSpecSL;
};
translate langs;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   init_lang();
   
   if(!SymbolInfoTick(_Symbol,lastme)){
      Alert(GetLastError());
      ExpertRemove();
   }
   
   curMagic=EA_Magic;
   int cntMyPos=OrdersTotal();

   
   
   stopin_value=STOP_IN;
   maxLot=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
  
   if(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)==0){
      Alert(langs.wrnMinVolume);
      ExpertRemove();
   }
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE)==SYMBOL_TRADE_MODE_DISABLED || SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE)==SYMBOL_TRADE_MODE_CLOSEONLY ){
      Alert(langs.wrnOnlyClose);
      ExpertRemove();
   }
  
  isClosed=false;
  // Get the current date
  TimeToStruct(TimeCurrent(), curDay);
  // Get symbol trading time for today
  if(SymbolInfoSessionTrade(_Symbol, (ENUM_DAY_OF_WEEK) curDay.day_of_week, 0, dfrom, dto)){
      time_info="";
      TimeToStruct(dto, curEndTime);
      TimeToStruct(dfrom, curStartTime);
         
         isEndTime=true;
         string tmpmsg="";
         tmp_val=curEndTime.hour;
         if(tmp_val<10){
            StringAdd(tmpmsg, "0");
         }
         StringAdd(tmpmsg, (string) tmp_val+":");
         tmp_val=curEndTime.min;
         if(tmp_val<10){
            StringAdd(tmpmsg, "0");
         }
         StringAdd(tmpmsg, (string) tmp_val);
         if(curEndTime.hour==curDay.hour){
            if(tmp_val>curDay.min){
            }else{
               isClosed=true;
            }
         }else{
            if(curEndTime.hour==0){
            }else{
               if( curEndTime.hour>1 && (curDay.hour>curEndTime.hour || curDay.hour==0)){
                  StringAdd(time_info, " ("+langs.lbl_close+")");
                  isClosed=true;
               }else if(curDay.hour<curStartTime.hour ){
                  StringAdd(time_info, " ("+langs.lbl_close+")");
                  isEndTime=false;
                  isClosed=true;
               }else if(curDay.hour==curStartTime.hour && curDay.min<curStartTime.min ){
                  StringAdd(time_info, " ("+langs.lbl_close+")");
                  isEndTime=false;
                  isClosed=true;
               }
            }
         }

         if(isEndTime){
            StringAdd(time_info, langs.lblshow_TIME+": "+tmpmsg+time_info);
         }else{
            StringAdd(time_info, langs.lblshow_TIME2+": "+tmpmsg+time_info);
         }
  }
  
  ArraySetAsSeries(rates, true);
  // the currency used for profit calculation for the current financial instrument
  currencyS=SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);
  // Symbol's point size
  curPoint=SymbolInfoDouble(_Symbol, SYMBOL_POINT);

  
  curMinStop=SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL)*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  ObjectDelete(0, exprefix+"_line1");
  
  symbols=SymbolName(0, false);
  if(SymbolsTotal(false)>1){
   StringAdd(symbols, ", "+SymbolName(1, false));
  }

  // if there are Stop Loss and open price lines on the chart
  // add the appropriate prices to variables
  if(ObjectFind(0, exprefix+"_stop")>=0){
      draw_stop=ObjectGetDouble(0, exprefix+"_stop", OBJPROP_PRICE);
      if(ObjectFind(0, exprefix+"_open")>=0){
         draw_open=ObjectGetDouble(0, exprefix+"_open", OBJPROP_PRICE);
      }
  // otherwise create the entire Expert Advisor UI
  }else{
      draw_open=lastme.bid;
      draw_stop=draw_open-(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD)*curPoint);
      ObjectCreate(0, exprefix+"_stop", OBJ_HLINE, 0, 0, draw_stop);
      ObjectSetInteger(0,exprefix+"_stop",OBJPROP_SELECTABLE,1);
      ObjectSetInteger(0,exprefix+"_stop",OBJPROP_SELECTED,1); 
      ObjectSetInteger(0,exprefix+"_stop",OBJPROP_STYLE,STYLE_DASHDOTDOT); 
      ObjectSetInteger(0,exprefix+"_stop",OBJPROP_ANCHOR,ANCHOR_TOP); 
        
      if(curMinStop>0){
         ObjectCreate(0, exprefix+"_minstop_high", OBJ_HLINE, 0, 0, lastme.ask+curMinStop);
         ObjectSetInteger(0,exprefix+"_minstop_high",OBJPROP_SELECTABLE,0);
         ObjectSetInteger(0,exprefix+"_minstop_high",OBJPROP_SELECTED,0); 
         ObjectSetInteger(0,exprefix+"_minstop_high",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,exprefix+"_minstop_high",OBJPROP_ANCHOR,ANCHOR_TOP); 
         ObjectSetInteger(0,exprefix+"_minstop_high",OBJPROP_COLOR,clrKhaki);
         ObjectSetInteger(0,exprefix+"_minstop_high",OBJPROP_BACK,true); 
           
         ObjectCreate(0, exprefix+"_minstop_low", OBJ_HLINE, 0, 0, lastme.bid-curMinStop);
         ObjectSetInteger(0,exprefix+"_minstop_low",OBJPROP_SELECTABLE,0);
         ObjectSetInteger(0,exprefix+"_minstop_low",OBJPROP_SELECTED,0); 
         ObjectSetInteger(0,exprefix+"_minstop_low",OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,exprefix+"_minstop_low",OBJPROP_ANCHOR,ANCHOR_TOP); 
         ObjectSetInteger(0,exprefix+"_minstop_low",OBJPROP_COLOR,clrKhaki);
         ObjectSetInteger(0,exprefix+"_minstop_low",OBJPROP_BACK,true); 
      }

      // Creating button "Show (0) open price line"
      if(ObjectFind(0, exprefix+"_openbtn")<0){
         ObjectCreate(0, exprefix+"_openbtn", OBJ_BUTTON, 0, 0, 0);
         ObjectSetInteger(0,exprefix+"_openbtn",OBJPROP_XDISTANCE,0); 
         ObjectSetInteger(0,exprefix+"_openbtn",OBJPROP_YDISTANCE,33); 
         ObjectSetString(0,exprefix+"_openbtn",OBJPROP_TEXT, langs.btnShowOpenLine); 
         ObjectSetInteger(0,exprefix+"_openbtn",OBJPROP_XSIZE,333); 
         ObjectSetInteger(0,exprefix+"_openbtn",OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0,exprefix+"_openbtn",OBJPROP_YSIZE,25); 
      }
      // Creating the Buy button
      if(ObjectFind(0, exprefix+"_send")<0){
         ObjectCreate(0, exprefix+"_send", OBJ_BUTTON, 0, 0, 0);
         ObjectSetInteger(0,exprefix+"_send",OBJPROP_XDISTANCE,0); 
         ObjectSetInteger(0,exprefix+"_send",OBJPROP_YDISTANCE,58); 
         ObjectSetString(0,exprefix+"_send",OBJPROP_TEXT, langs.btnSpecSL); 
         ObjectSetInteger(0,exprefix+"_send",OBJPROP_XSIZE,333); 
         ObjectSetInteger(0,exprefix+"_send",OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0,exprefix+"_send",OBJPROP_YSIZE,25); 
     }
  }

  getmespread();

      
//---
   return(INIT_SUCCEEDED);
  }
/* Show the open price line */
void showOpenLine(){
   if(ObjectFind(0, exprefix+"_open")<0){
      draw_open=lastme.bid;
      ObjectCreate(0, exprefix+"_open", OBJ_HLINE, 0, 0, draw_open);
      ObjectSetInteger(0,exprefix+"_open",OBJPROP_SELECTABLE,1);
      ObjectSetInteger(0,exprefix+"_open",OBJPROP_SELECTED,1); 
      ObjectSetInteger(0,exprefix+"_open",OBJPROP_STYLE,STYLE_DASHDOTDOT); 
      ObjectSetInteger(0,exprefix+"_open",OBJPROP_ANCHOR,ANCHOR_TOP); 
      ObjectSetInteger(0,exprefix+"_open",OBJPROP_COLOR,clrGreen);
   }
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

     if(reason!=REASON_CHARTCHANGE){
        ObjectsDeleteAll(0, exprefix);
        Comment("");
     }
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
      SymbolInfoTick(_Symbol,lastme);
      getmespread();
//         movestopline(true);
//         movestopline(false);
         
      if(STOPLOSS_PRICE>0){
         updatelots();
      }
      if( curMinStop>0 && ObjectFind(0, exprefix+"_minstop_high")>=0 ){      
         ObjectMove(0,exprefix+"_minstop_high",0,0,SymbolInfoDouble(_Symbol, SYMBOL_ASK)+curMinStop);
         ObjectMove(0,exprefix+"_minstop_low",0,0,SymbolInfoDouble(_Symbol, SYMBOL_BID)-curMinStop);
      }
   
  }


void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  { 
   string text="";
   double curprice=0;
   switch(id){
      case CHARTEVENT_OBJECT_CLICK:
         if (sparam==exprefix+"_send"){
            startPosition();
         }else if (sparam==exprefix+"_openbtn"){
            updateOpenLine();
         }
         break;
      case CHARTEVENT_OBJECT_DRAG:
         if(sparam==exprefix+"_stop"){
            setstopbyline();
            showOpenLine();
            ObjectSetInteger(0,exprefix+"_openbtn",OBJPROP_STATE, true);
         }else if(sparam==exprefix+"_open"){
               curprice=ObjectGetDouble(0, exprefix+"_open", OBJPROP_PRICE);
               if( curprice>0 && curprice != draw_open ){
                  double tmp_double=SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
                  if( tmp_double>0 && tmp_double!=1 ){
                     if(tmp_double<1){
                        resval=DoubleToString(curprice/tmp_double, 8);
                        if( StringFind(resval, ".00000000")>0 ){}else{
                           curprice=MathFloor(curprice)+MathFloor((curprice-MathFloor(curprice))/tmp_double)*tmp_double;
                        }
                     }else{
                        if( MathMod(curprice,tmp_double) ){
                           curprice= MathFloor(curprice/tmp_double)*tmp_double;
                        }
                     }
                  }
                  draw_open=open=OPEN_PRICE=curprice;
                  
                  updatebuttontext();
                  ObjectSetString(0,exprefix+"Edit3",OBJPROP_TEXT,0, (string) NormalizeDouble(draw_open, _Digits));
                  ChartRedraw(0);
               }
         }
         break;
      case CHARTEVENT_KEYDOWN:
         switch((int) sparam){
            // Terminate EA operation without placing an order
            case 45: //x
               closeNotSave();
               break;
            // Place an order and complete EA operation
            case 31: //s
               startPosition();
               break;
            // Set minimum possible Stop Loss to open a Buy position
            case 22: //u
               setMinStopBuy();
               break;
            // Set minimum possible Stop Loss to open a Sell position
            case 38: //l
               setMinStopSell();
               break;
            // Cancel the set open price
            case 44: //z
               setZero();
               ChartRedraw();
               break;
            // Set Stop Loss at 0.2% from the current price to open a Long position
            case 3: //2
               set02StopBuy();
               break;
            // Set Stop Loss at 0.2% from the current price to open a Short position
            case 4: //3
               set02StopSell();
               break;
            // Set Stop Loss to 7 cents from the current price (the CENT_STOP parameter)
            // To open a Long position
            case 8: //7
               set7StopBuy();
               break;
            // Set Stop Loss to 7 cents from the current price (the CENT_STOP parameter)
            // To open a Short position
            case 9: //8
               set7StopSell();
               break;
         }
         break;
   }
}
void updateOpenLine(){
   setZero();
   if( ObjectGetInteger(0,exprefix+"_openbtn",OBJPROP_SELECTED) == true ){
      ObjectDelete(0, exprefix+"_open");
   }else{
      showOpenLine();
   }
   ChartRedraw();
}
/*
"Remembers" the Stop Loss levels for the future order
*/
void setstopbyline(){
   // Receive the price in which the Stop Loss line is located
   double curprice=ObjectGetDouble(0, exprefix+"_stop", OBJPROP_PRICE);
   // If the price is different from the one in which the Stop Loss line was positioned at the EA launch,
   if(  curprice>0 && curprice != draw_stop ){
      double tmp_double=SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      if( tmp_double>0 && tmp_double!=1 ){
         if(tmp_double<1){
            resval=DoubleToString(curprice/tmp_double, 8);
            if( StringFind(resval, ".00000000")>0 ){}else{
               curprice=MathFloor(curprice)+MathFloor((curprice-MathFloor(curprice))/tmp_double)*tmp_double;
            }
         }else{
            if( MathMod(curprice,tmp_double) ){
               curprice= MathFloor(curprice/tmp_double)*tmp_double;
            }
         }
      }
      draw_stop=STOPLOSS_PRICE=curprice;
                  
      updatebuttontext();
      ChartRedraw(0);
   }
}
void movestopline(bool direction, int type=0){
   double tmp_price=0;
      double new_price=0;
      if(direction){
         if(open>0){
            tmp_price=open;
         }else{
            tmp_price=SymbolInfoDouble(_Symbol, SYMBOL_BID);
         }
         switch(type){
            case 0: // min stop
               if(curMinStop>0){
                  new_price=tmp_price-(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL)+1)*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
               }else{
                  Alert(langs.noMinStop);
                  return;
               }
               break;
            case 1: // 0.2%
               new_price=tmp_price-tmp_price*0.002;
               break;
            case 2: // 7 cents
               new_price=tmp_price-CENT_STOP;
               break;
         }
         ObjectMove(0,exprefix+"_stop",0,0,new_price);
      }else{
         if(open>0){
            tmp_price=open;
         }else{
            tmp_price=SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         }
         switch(type){
            case 0: // min stop
               if(curMinStop>0){
                  new_price=tmp_price+(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL)+1)*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
               }else{
                  Alert(langs.noMinStop);
                  return;
               }
               break;
            case 1: // 0.2%
               new_price=tmp_price+tmp_price*0.002;
               break;
            case 2: // 7 cents
               new_price=tmp_price+CENT_STOP;
               break;
         }
         ObjectMove(0,exprefix+"_stop",0,0,new_price);
      }
      setstopbyline();
}
void updatebuttontext(){
   double tmp_price=OPEN_PRICE;
   if(tmp_price==0){
      tmp_price=lastme.bid;
   }
   if(tmp_price>0 && STOPLOSS_PRICE>0){
      if(tmp_price>STOPLOSS_PRICE){
         // change the name for the Buy button
      }else{
         // change the name for the Sell button
      }
   }
   updatelots();
}
/*
   Calculate loss in case of Stop Loss
*/
double getMyProfit(double fPrice, double fSL, double fLot, bool forLong=true){
   double fProfit=0;
   
   fPrice=NormalizeDouble(fPrice,_Digits);
   fSL=NormalizeDouble(fSL,_Digits);
   #ifdef __MQL5__ 
      if( forLong ){
         if(OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, fLot, fPrice, fSL, fProfit)){};
      }else{
         if(OrderCalcProfit(ORDER_TYPE_SELL, _Symbol, fLot, fPrice, fSL, fProfit)){};
      }
   #else
      if( forLong ){
         fProfit=(fPrice-fSL)*fLot* (1 / MarketInfo(_Symbol, MODE_POINT)) * MarketInfo(_Symbol, MODE_TICKVALUE);
      }else{
         fProfit=(fSL-fPrice)*fLot* (1 / MarketInfo(_Symbol, MODE_POINT)) * MarketInfo(_Symbol, MODE_TICKVALUE);
      }
   #endif 
   if( fProfit!=0 ){
      fProfit=MathAbs(fProfit);
   }
   
   return fProfit;
}
void updatelots(){
   
   double tmp_price=OPEN_PRICE;
   if(tmp_price==0){
      if(lastme.bid>STOPLOSS_PRICE){
         tmp_price=SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      }else{
         tmp_price=SymbolInfoDouble(_Symbol, SYMBOL_BID);
      }
   }
   lot=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(lot==0){
      Alert(langs.wrnMinVolume);
      ExpertRemove();
   }
   
   if( Type_STOP==percent ){
      stopin_value=(AccountInfoDouble(ACCOUNT_BALANCE)*STOP_IN)/100;
   }

   if(tmp_price>0 && STOPLOSS_PRICE>0){
      if(tmp_price>STOPLOSS_PRICE){
         //LONG
         if( curMinStop>0 && curMinStop>=(tmp_price-STOPLOSS_PRICE) ){
            if(ObjectFind(0, exprefix+"_take")>=0){
               ObjectDelete(0, exprefix+"_take");
            }
            ObjectSetString(0,exprefix+"_send",OBJPROP_TEXT, langs.wrnSTOPLOSS_PRICE+" ("+DoubleToString(tmp_price-STOPLOSS_PRICE, _Digits)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"). "+langs.Label1_min+": "+(string) curMinStop+" "+AccountInfoString(ACCOUNT_CURRENCY));
            return;
         }

         if(TAKE_MULTIPLY>0){
            takein_value=NormalizeDouble(tmp_price+(TAKE_MULTIPLY*(tmp_price-STOPLOSS_PRICE)),_Digits);
         }else{
            takein_value=0;
         }
         
         profit=getMyProfit(tmp_price, STOPLOSS_PRICE, lot);
         if( profit!=0 ){
            if( profit<stopin_value ){
               lot*=(stopin_value/profit);
               if( SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)==0.01 ){
                  lot=(floor(lot*100))/100;
               }else if( SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)==0.1 ){
                  lot=(floor(lot*10))/10;
               }else{
                  lot=floor(lot);
               }
            }
         }
         
      }else{
         //SHORT
         if( curMinStop>0 && curMinStop>=(STOPLOSS_PRICE-tmp_price) ){
            if(ObjectFind(0, exprefix+"_take")>=0){
               ObjectDelete(0, exprefix+"_take");
            }
            ObjectSetString(0,exprefix+"_send",OBJPROP_TEXT, langs.wrnSTOPLOSS_PRICE+" ("+DoubleToString(STOPLOSS_PRICE-tmp_price, _Digits)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"). "+langs.Label1_min+": "+(string) curMinStop+" "+AccountInfoString(ACCOUNT_CURRENCY));
            return;
         }
         
         if(TAKE_MULTIPLY>0){
            takein_value=NormalizeDouble(tmp_price-(TAKE_MULTIPLY*(STOPLOSS_PRICE-tmp_price)),_Digits);
         }else{
            takein_value=0;
         }
         
         profit=getMyProfit(tmp_price, STOPLOSS_PRICE, lot, false);
         if( profit!=0 ){
            if( profit<stopin_value ){
               lot*=(stopin_value/profit);
               if( SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)==0.01 ){
                  lot=(floor(lot*100))/100;
               }else if( SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)==0.1 ){
                  lot=(floor(lot*10))/10;
               }else{
                  lot=floor(lot);
               }
            }
         }
         
      }
      
      if(takein_value>0){
         if(ObjectFind(0, exprefix+"_take")<0){
            ObjectCreate(0, exprefix+"_take", OBJ_HLINE, 0, 0, takein_value);
            ObjectSetInteger(0,exprefix+"_take",OBJPROP_STYLE,STYLE_DASHDOT);
            ObjectSetInteger(0,exprefix+"_take",OBJPROP_COLOR,clrWhite);
            ObjectSetInteger(0,exprefix+"_take",OBJPROP_SELECTABLE,true); 
         }else{
            ObjectMove(0,exprefix+"_take",0,0,takein_value);
         }
      }
      
      string direction="SELL: ";
      if(tmp_price>STOPLOSS_PRICE){
         direction="BUY: ";
      }
      double tmp_lot=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      if(tmp_lot==0){
         tmp_lot=0.01;
      }
     
      string wrnLot="";
      if( maxLot>0 && lot > maxLot ){
         wrnLot=". "+langs.wrnMaxLot+": "+(string) maxLot+"!";
      }
      
      ObjectSetString(0,exprefix+"_send",OBJPROP_TEXT, direction+langs.wrnONLY_WRITE1+": "+DoubleToString(lot, 2)+"; "+langs.wrnONLY_WRITE2+": "+(string) takein_value+"; "+langs.wrnONLY_WRITE3+": "+DoubleToString(profit*(lot/tmp_lot),2)+wrnLot);
   }
}

void msgErr(int err, int retcode=0){
   string curErr="";
   switch(err){
      case 1:
         curErr=langs.err1;
         break;
      case 2:
         curErr=langs.err2;
         break;
      case 3:
         curErr=langs.err3;
         break;
      case 4:
         curErr=langs.err4;
         break;
      case 5:
         curErr=langs.err5;
         break;
      case 6:
         curErr=langs.err6;
         break;
      case 7:
         curErr=langs.err7;
         break;
      case 8:
         curErr=langs.err8;
         break;
      case 9:
         curErr=langs.err9;
         break;
      case 64:
         curErr=langs.err64;
         break;
      case 65:
         curErr=langs.err65;
         break;
      case 128:
         curErr=langs.err128;
         break;
      case 129:
         curErr=langs.err129;
         break;
      case 130:
         curErr=langs.err130;
         break;
      case 131:
         curErr=langs.err131;
         break;
      case 132:
         curErr=langs.err132;
         break;
      case 133:
         curErr=langs.err133;
         break;
      case 134:
         curErr=langs.err134;
         break;
      case 135:
         curErr=langs.err135;
         break;
      case 136:
         curErr=langs.err136;
         break;
      case 137:
         curErr=langs.err137;
         break;
      case 138:
         curErr=langs.err138;
         break;
      case 139:
         curErr=langs.err139;
         break;
      case 140:
         curErr=langs.err140;
         break;
      case 141:
         curErr=langs.err141;
         break;
      case 145:
         curErr=langs.err145;
         break;
      case 146:
         curErr=langs.err146;
         break;
      case 147:
         curErr=langs.err147;
         break;
      case 148:
         curErr=langs.err148;
         break;
      default:
         curErr=langs.err0+": "+(string) err;
   }
   if(retcode>0){
      curErr+=" ";
      switch(retcode){
         case 10004:
            curErr+=langs.retcode10004;
            break;
         case 10006:
            curErr+=langs.retcode10006;
            break;
         case 10007:
            curErr+=langs.retcode10007;
            break;
         case 10010:
            curErr+=langs.retcode10010;
            break;
         case 10011:
            curErr+=langs.retcode10011;
            break;
         case 10012:
            curErr+=langs.retcode10012;
            break;
         case 10013:
            curErr+=langs.retcode10013;
            break;
         case 10014:
            curErr+=langs.retcode10014;
            break;
         case 10015:
            curErr+=langs.retcode10015;
            break;
         case 10016:
            curErr+=langs.retcode10016;
            break;
         case 10017:
            curErr+=langs.retcode10017;
            break;
         case 10018:
            curErr+=langs.retcode10018;
            break;
         case 10019:
            curErr+=langs.retcode10019;
            break;
         case 10020:
            curErr+=langs.retcode10020;
            break;
         case 10021:
            curErr+=langs.retcode10021;
            break;
         case 10022:
            curErr+=langs.retcode10022;
            break;
         case 10023:
            curErr+=langs.retcode10023;
            break;
         case 10024:
            curErr+=langs.retcode10024;
            break;
         case 10025:
            curErr+=langs.retcode10025;
            break;
         case 10026:
            curErr+=langs.retcode10026;
            break;
         case 10027:
            curErr+=langs.retcode10027;
            break;
         case 10028:
            curErr+=langs.retcode10028;
            break;
         case 10029:
            curErr+=langs.retcode10029;
            break;
         case 10030:
            curErr+=langs.retcode10030;
            break;
         case 10031:
            curErr+=langs.retcode10031;
            break;
         case 10032:
            curErr+=langs.retcode10032;
            break;
         case 10033:
            curErr+=langs.retcode10033;
            break;
         case 10034:
            curErr+=langs.retcode10034;
            break;
         case 10035:
            curErr+=langs.retcode10035;
            break;
         case 10036:
            curErr+=langs.retcode10036;
            break;
         case 10038:
            curErr+=langs.retcode10038;
            break;
         case 10039:
            curErr+=langs.retcode10039;
            break;
         case 10040:
            curErr+=langs.retcode10040;
            break;
         case 10041:
            curErr+=langs.retcode10041;
            break;
         case 10042:
            curErr+=langs.retcode10042;
            break;
         case 10043:
            curErr+=langs.retcode10043;
            break;
         case 10044:
            curErr+=langs.retcode10044;
            break;
      }
   }
   
   Alert(curErr);
}

/*
   Showing data on spread and session closing time in a chart comment
*/
void getmespread(){
   string msg="";
   
   // Add the spread value in the symbol currency to the global variable
   curSpread=lastme.ask-lastme.bid;
   
   // If the market is not closed, show spread info
   if( !isClosed ){
      if(curSpread>0){
         StringAdd(msg, langs.Label1_spread+": "+(string) DoubleToString(curSpread, (int) SymbolInfoInteger(_Symbol, SYMBOL_DIGITS))+" "+currencyS+" ("+DoubleToString(curSpread/curPoint, 0)+langs.lbl_point+")");
         StringAdd(msg, "; "+DoubleToString(((curSpread)/lastme.bid)*100, 3)+"%");
      }else{
         StringAdd(msg, langs.Label1_spread+": "+langs.lblNo);
      }
      StringAdd(msg, "; ");
   }
   
   // Show market closing time if we could determine it
   if(StringLen(time_info)){
      StringAdd(msg, "   "+time_info);
   }
      
   Comment(msg);
}

void setMinStopBuy(){
   movestopline(true);
}
void setMinStopSell(){
   movestopline(false);
}
void set02StopBuy(){
   movestopline(true, 1);
}
void set02StopSell(){
   movestopline(false, 1);
}
void set7StopBuy(){
   movestopline(true, 2);
}
void set7StopSell(){
   movestopline(false, 2);
}
void setZero(){
   open=OPEN_PRICE=0;
   ObjectSetString(0,exprefix+"Edit3",OBJPROP_TEXT,"0");
   updatelots();
}
void startPosition(){

   if( !STOPLOSS_PRICE ){
      Alert(langs.wrnSTOPLOSS_PRICE2);
      return;
   }
   if( SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)>0 && SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)!=1 ){
      resval=DoubleToString(STOPLOSS_PRICE/SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), 8);
      if( StringFind(resval, ".00000000")>0 ){}else{
         Alert(langs.wrnSYMBOL_TRADE_TICK_SIZE+" "+(string) SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)+"! "+langs.wrnSYMBOL_TRADE_TICK_SIZE_end);
         return;
      }
   }
   
   if( !STOP_IN ){
      Alert(langs.wrnSTOP_IN);
      return;
   }
   
   if( Type_STOP==percent && STOP_IN>5 ){
      Alert(langs.wrnType_STOP);
      return;
   }
   
   
   if(!SymbolInfoTick(_Symbol,lastme)){
      Alert(GetLastError());
      return;
   }
   
   if( Type_STOP==percent ){
      stopin_value=(AccountInfoDouble(ACCOUNT_BALANCE)*STOP_IN)/100;
   }

   open=OPEN_PRICE;
   if(open>0){
      if(STOPLOSS_PRICE>open){
         isLong=false;
      }
   }else{
      if(STOPLOSS_PRICE>lastme.ask){
         isLong=false;
         open=lastme.bid;
      }else{
         open=lastme.ask;
      }
   }
   if( SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)>0 && SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)!=1 ){
      resval=DoubleToString(open/SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE), 8);
      if( StringFind(resval, ".00000000")>0 ){}else{
         Alert(langs.wrnSYMBOL_TRADE_TICK_SIZE2+" "+(string) SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE)+"! "+langs.wrnSYMBOL_TRADE_TICK_SIZE_end);
         return;
      }
   }

   chart_ID=ChartID();
   lot=SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(lot==0){
      Alert(langs.wrnMinVolume);
      ExpertRemove();
   }
   if(isLong){
      //LONG
      
      if( curMinStop>0 && open-STOPLOSS_PRICE <= curMinStop  ){
         Alert(langs.wrnSTOPLOSS_PRICE+" ("+(string) (open-STOPLOSS_PRICE)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"). "+langs.Label1_min+": "+(string) curMinStop+" "+AccountInfoString(ACCOUNT_CURRENCY));
         return;
      }
      
      if(TAKE_MULTIPLY>0){
         takein_value=NormalizeDouble(open+(TAKE_MULTIPLY*(open-STOPLOSS_PRICE)),_Digits);
      }else{
         takein_value=0;
      }
      
      profit=getMyProfit(open, STOPLOSS_PRICE, lot);
      if( profit!=0 ){
         // If loss with the minimum lot is less than your risks,
         // calculate appropriate deal volume
         if( profit<stopin_value ){
            // get the desired deal volume
            lot*=(stopin_value/profit);
            // adjust the volume if it does not correspond to the minimum allowed step
            // for this trading instrument
            if( SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)==0.01 ){
               lot=(floor(lot*100))/100;
            }else if( SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)==0.1 ){
               lot=(floor(lot*10))/10;
            }else{
               lot=floor(lot);
            }
         // If loss with the minimum lot is greater than your risks,
         // cancel position opening if this option is set in EA parameters
         }else if( profit>stopin_value && EXIT_IF_MORE ){
            Alert(langs.wrnEXIT_IF_MORE1+": "+(string) lot+" "+langs.wrnEXIT_IF_MORE2+": "+(string) profit+" "+AccountInfoString(ACCOUNT_CURRENCY)+" ("+(string) stopin_value+" "+AccountInfoString(ACCOUNT_CURRENCY)+")!");
            return;
         }
      }
      
      TypeOfPos myType=MY_BUY;
      if(OPEN_PRICE>0){
         if( OPEN_PRICE>lastme.ask && OPEN_PRICE>lastme.bid ){
            myType = MY_BUYSTOP;
         }else{
            myType = MY_BUYLIMIT;
         }
      }else{
         myType = MY_BUY;
      }
      
      if( maxLot>0 && lot>maxLot){
         lot=maxLot;
      }
      
      datetime cur_expiration=0;
      if(DEL_END_DAY>0){
         cur_expiration=TimeCurrent()+DEL_END_DAY*3600;
      }
      
      if(pdxSendOrder(myType, open, STOPLOSS_PRICE, takein_value, lot, 0, MY_COMMENT, _Symbol, cur_expiration)){
      }else{
         return;
      }
   
   }else{
      //SHORT

      if( curMinStop>0 && STOPLOSS_PRICE-open < curMinStop  ){
         Alert(langs.wrnSTOPLOSS_PRICE+" ("+(string) (STOPLOSS_PRICE-open)+" "+AccountInfoString(ACCOUNT_CURRENCY)+"). "+langs.Label1_min+": "+(string) curMinStop+" "+AccountInfoString(ACCOUNT_CURRENCY));
         return;
      }
      
      if(TAKE_MULTIPLY>0){
         takein_value=NormalizeDouble(open-(TAKE_MULTIPLY*(STOPLOSS_PRICE-open)),_Digits);
      }else{
         takein_value=0;
      }
            
      profit=getMyProfit(open, STOPLOSS_PRICE, lot);
      if( profit!=0 ){
         if( profit<stopin_value ){
            lot*=(stopin_value/profit);
            if( SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)==0.01 ){
               lot=(floor(lot*100))/100;
            }else if( SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)==0.1 ){
               lot=(floor(lot*10))/10;
            }else{
               lot=floor(lot);
            }
         }else if( profit>stopin_value && EXIT_IF_MORE ){
            Alert(langs.wrnEXIT_IF_MORE1+": "+(string) lot+" "+langs.wrnEXIT_IF_MORE2+": "+(string) profit+" "+AccountInfoString(ACCOUNT_CURRENCY)+" ("+(string) stopin_value+" "+AccountInfoString(ACCOUNT_CURRENCY)+")!");
            return;
         }
      }

      TypeOfPos myType=MY_SELL;
      if(OPEN_PRICE>0){
         if( OPEN_PRICE>lastme.ask && OPEN_PRICE>lastme.bid ){
            myType = MY_SELLLIMIT;
         }else{
            myType = MY_SELLSTOP;
         }
      }else{
         myType= MY_SELL;
      }

      if(maxLot>0 && lot>maxLot){
         lot=maxLot;
      }

      datetime cur_expiration=0;
      if(DEL_END_DAY>0){
         cur_expiration=TimeCurrent()+DEL_END_DAY*3600;
      }

      if(pdxSendOrder(myType, open, STOPLOSS_PRICE, takein_value, lot, 0, MY_COMMENT, _Symbol, cur_expiration)){
      }else{
         return;
      }
   }
   ExpertRemove();
}


string dayName(int i){
   switch(i){
      case 1:
            return "Monday";
      case 2:
            return "Tuesday";
      case 3:
            return "Wednesday";
      case 4:
            return "Thursday";
      case 5:
            return "Friday";
      case 6:
            return "Saturday";
      default:
            return "Sunday";
   }
}

void init_lang(){
   switch(LANG){
      case MY_ENG:
         langs.err1="No error, but unknown result. (1)";
         langs.err2="General error (2)";
         langs.err3="Incorrect parameters (3)";
         langs.err4="Trade server busy (4)";
         langs.err5="Old client terminal version (5)";
         langs.err6="No connection to trade server (6)";
         langs.err7="Not enough rights (7)";
         langs.err8="Too frequent requests (8)";
         langs.err9="Invalid operation disruptive server operation (9)";
         langs.err64="Account blocked (64)";
         langs.err65="Invalid account number (65)";
         langs.err128="Expired waiting period for transaction (128)";
         langs.err129="Invalid price (129)";
         langs.err130="Wrong stop loss (130)";
         langs.err131="Wrong volume (131)";
         langs.err132="Market closed (132)";
         langs.err133="Trade prohibited (133)";
         langs.err134="Not enough money to complete transaction. (134)";
         langs.err135="Price changed (135)";
         langs.err136="No prices (136)";
         langs.err137="Broker busy (137)";
         langs.err138="New prices (138)";
         langs.err139="Order blocked and already being processed (139)";
         langs.err140="Only purchase allowed (140)";
         langs.err141="Too many requests (141)";
         langs.err145="Modification prohibited because order too close to market. (145)";
         langs.err146="Trading subsystem busy (146)";
         langs.err147="Using order expiration date prohibited by broker (147)";
         langs.err148="Number of open and pending orders reached limit set by broker (148)";
         langs.err0="Error occurred while running request";
         langs.CheckBox1="Set min. stop for BUY (U)";
         langs.CheckBox5="For SELL (L)";
         langs.CheckBox6="Set to 0 (Z)";
         langs.CheckBox7="+ 3 p.";
         langs.CheckBox2="Do not open a trade if at min lot stop is greater";
         langs.Label7="Cancel a limit order";
         langs.CheckBox4="Use ORDER_FILLING_RETURN instead of ORDER_FILLING_FOK";
         langs.Label1="Stop loss Price";
         langs.Label1_min="min";
         langs.Label1_freeze="freeze";
         langs.Label1_spread="Spread";
         langs.lblMinSTOP="Min. stop";
         langs.Label2="Loss in dollars or percent for a stop line";
         langs.Label3="Opening price (0 - by market)";
         langs.Label6="The price of the top level (0 - do not check)";
         langs.Button1="Enter Stop Loss Price";
         langs.Button2="Save and exit (X)";
         langs.Label4="Multiplier for take (0 - do not put a take)";
         langs.ComboBox1_item0="Dollars";
         langs.ComboBox1_item1="Percent of deposit";
         langs.wrnType_STOP="The price of stop loss in percent of the deposit can not be more than 5!";
         langs.wrnTAKE_MULTIPLY="Take is not set";
         langs.wrnDEMO="The demo version can only work on symbols ";
         langs.wrnSTOPLOSS_PRICE="Stop loss is too small";
         langs.wrnTAKE_LEVEL1="The take price";
         langs.wrnTAKE_LEVEL2="is more than the given upper level";
         langs.wrnTAKE_LEVEL3="is less than the given upper level";
         langs.wrnEXIT_IF_MORE1="Minimal lot";
         langs.wrnEXIT_IF_MORE2="The price of stop is more than the max.";
         langs.wrnONLY_WRITE1="Lot";
         langs.wrnONLY_WRITE2="Take";
         langs.wrnONLY_WRITE3="Stop, $";
         langs.wrnONLY_WRITE4="Margin";
         langs.Label5="Draw a line at the level of a given number of stops";
         langs.wndTITLE="Settings, ver "+pdxversion;
         langs.wrnTAKEIN_LESS="Get your take is impossible. The take price is obtained below 0";
         langs.retcode="Reason";
         langs.retcode10004="Requote";
         langs.retcode10006="Request rejected";
         langs.retcode10007="Request canceled by trader";
         langs.retcode10010="Only part of request completed";
         langs.retcode10011="Request processing error";
         langs.retcode10012="Request canceled by timeout";
         langs.retcode10013="Invalid request";
         langs.retcode10014="Invalid volume in request";
         langs.retcode10015="Invalid price in request";
         langs.retcode10016="Invalid stops in request";
         langs.retcode10017="Trade disabled";
         langs.retcode10018="Market closed";
         langs.retcode10019="Not enough money to complete request";
         langs.retcode10020="Prices changed";
         langs.retcode10021="No quotes to process request";
         langs.retcode10022="Invalid order expiration date in request";
         langs.retcode10023="Order state changed";
         langs.retcode10024="Too frequent requests";
         langs.retcode10025="No changes in request";
         langs.retcode10026="Autotrading disabled by server";
         langs.retcode10027="Autotrading disabled by client terminal";
         langs.retcode10028="Request locked for processing";
         langs.retcode10029="Order or position frozen";
         langs.retcode10030="Invalid order filling type";
         langs.retcode10031="No connection with trade server";
         langs.retcode10032="Operation allowed only for live accounts";
         langs.retcode10033="Number of pending orders reached limit";
         langs.retcode10034="Volume of orders and positions for symbol reached limit";
         langs.retcode10035="Incorrect or prohibited order type";
         langs.retcode10036="Position with specified POSITION_IDENTIFIER already closed";
         langs.retcode10038="Close volume exceeds current position volume";
         langs.retcode10039="Close order already exists for specified position";
         langs.retcode10040="Number of open items exceeded";
         langs.retcode10041="Pending order activation request rejected, order canceled";
         langs.retcode10042="Only long positions allowed";
         langs.retcode10043="Only short positions allowed";
         langs.retcode10044="Only position closing allowed";
         langs.wrnSTOPLOSS_PRICE2="Parameter not set: Stop loss Price";
         langs.wrnSTOP_IN="Parameter not set: Loss in dollars or percent for a stop line";
         langs.wrnSYMBOL_TRADE_TICK_SIZE="The stop loss price must be a multiple of";
         langs.wrnSYMBOL_TRADE_TICK_SIZE2="The take price must be a multiple of";
         langs.wrnSYMBOL_TRADE_TICK_SIZE_end="Round it in the desired direction";
         langs.DEL_END_DAY_val1="Do not cancel";
         langs.DEL_END_DAY_val2="At the end of the day";
         langs.DEL_END_DAY_val3="In 2 days";
         langs.DEL_END_DAY_val4="In 3 days";
         langs.DEL_END_DAY_val5="A week later";
         langs.lblNo="no";
         langs.lblshow_SWAP="Swap";
         langs.lbl_point=" p";
         langs.Button1_buy="Send BUY order (S)";
         langs.Button1_sell="Send SELL order (S)";
         langs.lblDef="Specify the stop loss price to see the lot size";
         langs.noMinStop="The minimum stop on the instrument is not limited";
         langs.Label11="Magic Number (0 - def.)";
         langs.Label12="Comment (0 - no)";
         langs.lbl_min="m";
         langs.lbl_hour="h";
         langs.lblshow_TIME="End time";
         langs.lblshow_TIME2="Start time";
         langs.lbl_close="the market is closed";
         langs.wrnMinVolume="The minimum volume for this instrument is 0. Trading is impossible.";
         langs.wrnOnlyClose="Opening deals on this symbol is prohibited.";
         langs.wrnMaxLot="Max. lot";
         langs.maxMarga="Maximum margin already exceeds ";
         langs.noBalance="Your account balance is zero!";
         langs.maxCount="The maximum possible number of transactions is already open.";
         langs.btnShowOpenLine="Show line for open price (O)";
         langs.btnSpecSL="Specify stop loss (move red line)";
         break;
      case 1:
         langs.err0="Во время выполнения запроса произошла ошибка";
         langs.err1="Нет ошибки, но результат неизвестен (1)";
         langs.err2="Общая ошибка (2)";
         langs.err3="Неправильные параметры (3)";
         langs.err4="Торговый сервер занят (4)";
         langs.err5="Старая версия клиентского терминала (5)";
         langs.err6="Нет связи с торговым сервером (6)";
         langs.err7="Недостаточно прав (7)";
         langs.err8="Слишком частые запросы (8)";
         langs.err9="Недопустимая операция нарушающая функционирование сервера (9)";
         langs.err64="Счет заблокирован (64)";
         langs.err65="Неправильный номер счета (65)";
         langs.err128="Истек срок ожидания совершения сделки (128)";
         langs.err129="Неправильная цена (129)";
         langs.err130="Неправильные стопы (130)";
         langs.err131="Неправильный объем (131)";
         langs.err132="Рынок закрыт (132)";
         langs.err133="Торговля запрещена (133)";
         langs.err134="Недостаточно денег для совершения операции (134)";
         langs.err135="Цена изменилась (135)";
         langs.err136="Нет цен (136)";
         langs.err137="Брокер занят (137)";
         langs.err138="Новые цены (138)";
         langs.err139="Ордер заблокирован и уже обрабатывается (139)";
         langs.err140="Разрешена только покупка (140)";
         langs.err141="Слишком много запросов (141)";
         langs.err145="Модификация запрещена, так как ордер слишком близок к рынку (145)";
         langs.err146="Подсистема торговли занята (146)";
         langs.err147="Использование даты истечения ордера запрещено брокером (147)";
         langs.err148="Количество открытых и отложенных ордеров достигло предела, установленного брокером (148)";
         langs.CheckBox1="Уст. min. стоп для BUY (U)";
         langs.CheckBox5="Для SELL (L)";
         langs.CheckBox6="Уст. равным 0 (Z)";
         langs.CheckBox2="Не входить в сделку, если при мин. лоте стоп больше";
         langs.CheckBox7="+ 3 п.";
         langs.Label7="Отменить лимитный ордер";
         langs.CheckBox4="Использовать ORDER_FILLING_RETURN вместо ORDER_FILLING_FOK";
         langs.Label1="Цена стоп лосса";
         langs.Label1_min="мин";
         langs.Label1_freeze="заморозка";
         langs.Label1_spread="Спред";
         langs.lblMinSTOP="Мин. стоп";
         langs.Label2="Потери в долларах или процентах при стопе";
         langs.Label3="Цена открытия (0 - по рынку)";
         langs.Label6="Цена верхнего уровня (0 - не проверять превышение)";
         langs.Button1="Введите цену стоп лосса";
         langs.Button2="Сохранить и выйти (X)";
         langs.Label4="Множитель для тейка (0 - не ставить тейк)";
         langs.ComboBox1_item0="В долларах";
         langs.ComboBox1_item1="В процентах от депозита";
         langs.wrnType_STOP="Стоп лосс в процентах от депозита не может быть больше 5%!";
         langs.wrnTAKE_MULTIPLY="Тейк не задан";
         langs.wrnDEMO="Демо-версия работает только на символах ";
         langs.wrnSTOPLOSS_PRICE="Стоп слишком маленький";
         langs.wrnTAKE_LEVEL1="Цена тейка";
         langs.wrnTAKE_LEVEL2="больше чем граничный уровень";
         langs.wrnTAKE_LEVEL3="меньше чем граничный уровень";
         langs.wrnEXIT_IF_MORE1="Минимальный лот";
         langs.wrnEXIT_IF_MORE2="Цена стоп лосса больше максимальной";
         langs.wrnONLY_WRITE1="Лот";
         langs.wrnONLY_WRITE2="Тейк";
         langs.wrnONLY_WRITE3="Стоп, $";
         langs.wrnONLY_WRITE4="Маржа";
         langs.Label5="Провести линию на данном количестве стопов (0 - нет)";
         langs.wndTITLE="Настройки, ver "+pdxversion;
         langs.wrnTAKEIN_LESS="Получить ваш тейк невозможно. Цена тейка получается ниже 0";
         langs.retcode="Причина";
         langs.retcode10004="Реквота";
         langs.retcode10006="Запрос отклонен";
         langs.retcode10007="Запрос отменен трейдером";
         langs.retcode10010="Заявка выполнена частично";
         langs.retcode10011="Ошибка обработки запроса";
         langs.retcode10012="Запрос отменен по истечению времени";
         langs.retcode10013="Неправильный запрос";
         langs.retcode10014="Неправильный объем в запросе";
         langs.retcode10015="Неправильная цена в запросе";
         langs.retcode10016="Неправильные стопы в запросе";
         langs.retcode10017="Торговля запрещена";
         langs.retcode10018="Рынок закрыт";
         langs.retcode10019="Нет достаточных денежных средств для выполнения запроса";
         langs.retcode10020="Цены изменились";
         langs.retcode10021="Отсутствуют котировки для обработки запроса";
         langs.retcode10022="Неверная дата истечения ордера в запросе";
         langs.retcode10023="Состояние ордера изменилось";
         langs.retcode10024="Слишком частые запросы";
         langs.retcode10025="В запросе нет изменений";
         langs.retcode10026="Автотрейдинг запрещен сервером";
         langs.retcode10027="Автотрейдинг запрещен клиентским терминалом";
         langs.retcode10028="Запрос заблокирован для обработки";
         langs.retcode10029="Ордер или позиция заморожены";
         langs.retcode10030="Указан неподдерживаемый тип исполнения ордера по остатку ";
         langs.retcode10031="Нет соединения с торговым сервером";
         langs.retcode10032="Операция разрешена только для реальных счетов";
         langs.retcode10033="Достигнут лимит на количество отложенных ордеров";
         langs.retcode10034="Достигнут лимит на объем ордеров и позиций для данного символа";
         langs.retcode10035="Неверный или запрещённый тип ордера";
         langs.retcode10036="Позиция с указанным POSITION_IDENTIFIER уже закрыта";
         langs.retcode10038="Закрываемый объем превышает текущий объем позиции";
         langs.retcode10039="Для указанной позиции уже есть ордер на закрытие";
         langs.retcode10040="Количество открытых позиций превышено";
         langs.retcode10041="Запрос на активацию отложенного ордера отклонен, а сам ордер отменен";
         langs.retcode10042="Разрешены только длинные позиции";
         langs.retcode10043="Разрешены только короткие позиции";
         langs.retcode10044="Разрешено только закрывать существующие позиции";
         langs.wrnSTOPLOSS_PRICE2="Параметр не задан: Цена стоп лосса";
         langs.wrnSTOP_IN="Параметр не задан: Потери в долларах или процентах при стопе";
         langs.wrnSYMBOL_TRADE_TICK_SIZE="Цена стоп лосса должна быть кратна";
         langs.wrnSYMBOL_TRADE_TICK_SIZE2="Цена тейка должна быть кратна";
         langs.wrnSYMBOL_TRADE_TICK_SIZE_end="Округлите ее в нужную сторону";
         langs.DEL_END_DAY_val1="Не отменять";
         langs.DEL_END_DAY_val2="В конце дня";
         langs.DEL_END_DAY_val3="Через 2 дня";
         langs.DEL_END_DAY_val4="Через 3 дня";
         langs.DEL_END_DAY_val5="Через неделю";
         langs.lblNo="нет";
         langs.lblshow_SWAP="Своп";
         langs.lbl_point=" п";
         langs.Button1_buy="Отправить BUY ордер (S)";
         langs.Button1_sell="Отправить SELL ордер (S)";
         langs.lblDef="Укажите цену стоп лосса, чтобы увидеть размер лота";
         langs.noMinStop="Минимальный стоп по инструменту не ограничен";
         langs.Label11="Magic-номер (0 - по ум.)";
         langs.Label12="Комментарий (0 - нет)";
         langs.lblshow_TIME="Закрытие";
         langs.lblshow_TIME2="Открытие";
         langs.lbl_min="м";
         langs.lbl_hour="ч";
         langs.lbl_close="рынок закрыт";
         langs.wrnMinVolume="Минимальный объем по данному инструменту равен 0. Торговля невозможна.";
         langs.wrnOnlyClose="Открытие сделок по данному символу запрещено.";
         langs.wrnMaxLot="Максимальный лот";
         langs.maxMarga="Максимальная маржа уже превышает ";
         langs.noBalance="Баланс вашего счета нулевой!";
         langs.maxCount="Уже открыто максимально возможное количество сделок";
         langs.btnShowOpenLine="Показать линию цены открытия (0)";
         langs.btnSpecSL="Задайте SL (переместите красную линию)";
         break;
   }
   

}
void closeNotSave(){
   ExpertRemove();
   ChartRedraw();
}
bool pdxSendOrder(TypeOfPos mytype, double price, double sl, double tp, double volume, ulong position=0, string comment="", string sym="", datetime expiration=0){
      if( !StringLen(sym) ){
         sym=_Symbol;
      }
      int curDigits=(int) SymbolInfoInteger(sym, SYMBOL_DIGITS);
      if(sl>0){
         sl=NormalizeDouble(sl,curDigits);
      }
      if(tp>0){
         tp=NormalizeDouble(tp,curDigits);
      }
      if(price>0){
         price=NormalizeDouble(price,curDigits);
      }else{
         #ifdef __MQL5__ 
         #else
            if(!SymbolInfoTick(sym,lastme)){
               Alert(GetLastError());
               return false;
            }
            if( mytype == MY_SELL ){
               price=lastme.ask;
            }else if( mytype == MY_BUY ){
               price=lastme.bid;
            }
         #endif 
      }
   #ifdef __MQL5__ 
      ENUM_TRADE_REQUEST_ACTIONS action=TRADE_ACTION_DEAL;
      ENUM_ORDER_TYPE type=ORDER_TYPE_BUY;
      switch(mytype){
         case MY_BUY:
            action=TRADE_ACTION_DEAL;
            type=ORDER_TYPE_BUY;
            break;
         case MY_BUYSLTP:
            action=TRADE_ACTION_SLTP;
            type=ORDER_TYPE_BUY;
            break;
         case MY_BUYSTOP:
            action=TRADE_ACTION_PENDING;
            type=ORDER_TYPE_BUY_STOP;
            break;
         case MY_BUYLIMIT:
            action=TRADE_ACTION_PENDING;
            type=ORDER_TYPE_BUY_LIMIT;
            break;
         case MY_SELL:
            action=TRADE_ACTION_DEAL;
            type=ORDER_TYPE_SELL;
            break;
         case MY_SELLSLTP:
            action=TRADE_ACTION_SLTP;
            type=ORDER_TYPE_SELL;
            break;
         case MY_SELLSTOP:
            action=TRADE_ACTION_PENDING;
            type=ORDER_TYPE_SELL_STOP;
            break;
         case MY_SELLLIMIT:
            action=TRADE_ACTION_PENDING;
            type=ORDER_TYPE_SELL_LIMIT;
            break;
      }
      
      MqlTradeRequest mrequest;
      MqlTradeResult mresult;
      ZeroMemory(mrequest);
      
      mrequest.action = action;
      mrequest.sl = sl;
      mrequest.tp = tp;
      mrequest.symbol = sym;
      if(expiration>0){
         mrequest.type_time = ORDER_TIME_SPECIFIED_DAY;
         mrequest.expiration = expiration;
      }
      if(position>0){
         mrequest.position = position;
      }
      if(StringLen(comment)){
         mrequest.comment=comment;
      }
      if(action!=TRADE_ACTION_SLTP){
         if(price>0){
            mrequest.price = price;
         }
         if(volume>0){
            mrequest.volume = volume;
         }
         mrequest.type = type;
         mrequest.magic = EA_Magic;
         switch(useORDER_FILLING_RETURN){
            case FOK:
               mrequest.type_filling = ORDER_FILLING_FOK;
               break;
            case RETURN:
               mrequest.type_filling = ORDER_FILLING_RETURN;
               break;
            case IOC:
               mrequest.type_filling = ORDER_FILLING_IOC;
               break;
         }
         mrequest.deviation=100;
      }
      if(OrderSend(mrequest,mresult)){
         if(mresult.retcode==10009 || mresult.retcode==10008){
            if(action!=TRADE_ACTION_SLTP){
               switch(type){
                  case ORDER_TYPE_BUY:
//                     Alert("Order Buy #:",mresult.order," sl",sl," tp",tp," p",price," !!");
                     break;
                  case ORDER_TYPE_SELL:
//                     Alert("Order Sell #:",mresult.order," sl",sl," tp",tp," p",price," !!");
                     break;
               }
            }else{
//               Alert("Order Modify SL #:",mresult.order," sl",sl," tp",tp," !!");
            }
            return true;
         }else{
            msgErr(GetLastError(), mresult.retcode);
         }
      }
   #else 
      int type=OP_BUY;
      switch(mytype){
         case MY_BUY:
            type=OP_BUY;
            break;
         case MY_BUYSTOP:
            type=OP_BUYSTOP;
            break;
         case MY_BUYLIMIT:
            type=OP_BUYLIMIT;
            break;
         case MY_SELL:
            type=OP_SELL;
            break;
         case MY_SELLSTOP:
            type=OP_SELLSTOP;
            break;
         case MY_SELLLIMIT:
            type=OP_SELLLIMIT;
            break;
      }
      
      if(OrderSend(sym, type, volume, price, 100, sl, tp, comment, EA_Magic, expiration)<0){
            msgErr(GetLastError());
      }else{
         switch(type){
            case OP_BUY:
               Alert("Order Buy sl",sl," tp",tp," p",price," !!");
               break;
            case OP_SELL:
               Alert("Order Sell sl",sl," tp",tp," p",price," !!");
               break;
            }
            return true;
      }
   
   #endif 
   return false;
}
