
//+------------------------------------------------------------------+
//|                                                      MAX_LOT.mq5 |
//|                                Copyright © 2017, Андрей Мишустин | 
//|                                                                  | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2017, Андрей Мишустин"
#property link "" 
//---- номер версии индикатора
#property version   "1.00"
#property description "Скрипт делает расчёт максимальной величины лота, который можно использовать для открывания позиции на всю величину свободных средств депозита."
#property description "Расчитанное значение отображается по умолчанию в течение 10 секунд в правом верхнем углу графика."
//+----------------------------------------------+ 
//|  Объявление констант                         |
//+----------------------------------------------+
#define NAMES_SYMBOLS_FONT  "Georgia"                  // Шрифт для индикатора
//---- показывать входные параметры
#property script_show_inputs
//+----------------------------------------------+
//| ВХОДНЫЕ ПАРАМЕТРЫ СКРИПТА                    |
//+----------------------------------------------+
input ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;    // Тип позиции
//---- настройки визуального отображения индикатора
input string Symbols_Sirname="MAX_LOT_Label_";         // Название для меток индикатора
input color IndName_Color=clrMediumSlateBlue;          // Цвет индикатора
input uint Font_Size=15;                               // Размер шрифта индикатора
input uint X_=15;                                      // Смещение по горизонтали
input int Y_=30;                                       // Смещение по вертикали
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Угол расположения
input uint INFOTIME=10;                                // Время отображения информации в секундах
//+------------------------------------------------------------------+ 
//| start function                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//----
   double MaxLot=LotCount(Symbol(),PosType,1.0);
   string strMaxLot;
   if(MaxLot>0) strMaxLot="Максимальный лот для открывания позиции "+DoubleToString(MaxLot,4);
   else strMaxLot="Нет свободных средств для открывания позиции!!!";
   SetTLabel(0,Symbols_Sirname,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_,strMaxLot,strMaxLot,IndName_Color,NAMES_SYMBOLS_FONT,Font_Size);
   ChartRedraw(0);
   Sleep(INFOTIME*1000);
   ObjectDelete(0,Symbols_Sirname);
   ChartRedraw(0);
//----
  }
//+------------------------------------------------------------------+
//| Расчёт размера лота для открывания лонга                         |  
//+------------------------------------------------------------------+
double LotCount
(
string symbol,
ENUM_POSITION_TYPE postype,
double Money_Management
)
// (string symbol, double Money_Management)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   double margin,Lot;

//---- Расчёт лота от свободных средств на счёте
   margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE)*Money_Management;
   if(!margin) return(-1);

   Lot=GetLotForOpeningPos(symbol,postype,margin);

//---- нормирование величины лота до ближайшего стандартного значения 
   if(!LotCorrect(symbol,Lot,postype)) return(-1);
//----
   return(Lot);
  }
//+------------------------------------------------------------------+
//| коррекция размера отложенного ордера до допустимого значения     |
//+------------------------------------------------------------------+
bool StopCorrect(string symbol,int &Stop)
  {
//----
   long Extrem_Stop;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,Extrem_Stop)) return(false);
   if(Stop<Extrem_Stop) Stop=int(Extrem_Stop);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| LotCorrect() function                                            |
//+------------------------------------------------------------------+
bool LotCorrect
(
string symbol,
double &Lot,
ENUM_POSITION_TYPE trade_operation
)
//LotCorrect(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {

   double LOTSTEP=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(!LOTSTEP || !MaxLot || !MinLot) return(0);

//---- нормирование величины лота до ближайшего стандартного значения 
   Lot=LOTSTEP*MathFloor(Lot/LOTSTEP);

//---- проверка лота на минимальное допустимое значение
   if(Lot<MinLot) Lot=MinLot;
//---- проверка лота на максимальное допустимое значение       
   if(Lot>MaxLot) Lot=MaxLot;

//---- проверка средств на достаточность
   if(!LotFreeMarginCorrect(symbol,Lot,trade_operation))return(false);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| LotFreeMarginCorrect() function                                  |
//+------------------------------------------------------------------+
bool LotFreeMarginCorrect
(
string symbol,
double &Lot,
ENUM_POSITION_TYPE trade_operation
)
//(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----  
//---- проверка средств на достаточность
   double freemargin=AccountInfoDouble(ACCOUNT_FREEMARGIN);
   if(freemargin<=0) return(false);
   double LOTSTEP=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(!LOTSTEP || !MinLot) return(0);
   double maxLot=GetLotForOpeningPos(symbol,trade_operation,freemargin);
//---- нормирование величины лота до ближайшего стандартного значения 
   maxLot=LOTSTEP*MathFloor(maxLot/LOTSTEP);
   if(maxLot<MinLot) return(false);
   if(Lot>maxLot) Lot=maxLot;
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| расчёт размер лота для открывания позиции с маржой lot_margin    |
//+------------------------------------------------------------------+
double GetLotForOpeningPos(string symbol,ENUM_POSITION_TYPE direction,double lot_margin)
  {
//----
   double price=0.0,n_margin;
   if(direction==POSITION_TYPE_BUY)  price=SymbolInfoDouble(symbol,SYMBOL_ASK);
   if(direction==POSITION_TYPE_SELL) price=SymbolInfoDouble(symbol,SYMBOL_BID);
   if(!price) return(NULL);

   if(!OrderCalcMargin(ENUM_ORDER_TYPE(direction),symbol,1,price,n_margin) || !n_margin) return(0);
   double lot=lot_margin/n_margin;

//---- получение торговых констант
   double LOTSTEP=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   double MaxLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   double MinLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(!LOTSTEP || !MaxLot || !MinLot) return(0);

//---- нормирование величины лота до ближайшего стандартного значения 
   lot=LOTSTEP*MathFloor(lot/LOTSTEP);

//---- проверка лота на минимальное допустимое значение
   if(lot<MinLot) lot=0;
//---- проверка лота на максимальное допустимое значение       
   if(lot>MaxLot) lot=MaxLot;
//----
   return(lot);
  }
//+------------------------------------------------------------------+
//|  Создание текстовой метки                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // идентификатор графика
                  string name,             // имя объекта
                  int    nwin,             // индекс окна
                  ENUM_BASE_CORNER corner, // положение угла привязки
                  ENUM_ANCHOR_POINT point, // положение точки привязки
                  int    X,                // дистанция в пикселях по оси X от угла привязки
                  int    Y,                // дистанция в пикселях по оси Y от угла привязки
                  string text,             // текст
                  string textTT,           // текст всплывающей подсказки
                  color  Color,            // цвет текста
                  string Font,             // шрифт текста
                  int    Size)             // размер шрифта
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка текстовой метки                                   |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // идентификатор графика
               string name,             // имя объекта
               int    nwin,             // индекс окна
               ENUM_BASE_CORNER corner, // положение угла привязки
               ENUM_ANCHOR_POINT point, // положение точки привязки
               int    X,                // дистанция в пикселях по оси X от угла привязки
               int    Y,                // дистанция в пикселях по оси Y от угла привязки
               string text,             // текст
               string textTT,           // текст всплывающей подсказки
               color  Color,            // цвет текста
               string Font,             // шрифт текста
               int    Size)             // размер шрифта
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,textTT,Color,Font,Size);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//----
  }
//+------------------------------------------------------------------+
