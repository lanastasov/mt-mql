//+------------------------------------------------------------------+
//|                                                Day_Hight_Low.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property script_show_inputs
//--- input parameters
input datetime Day;
input color    Day_level=clrDarkViolet;
input color    Night_Level=clrRoyalBlue;
input bool     Night_Session=true;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   datetime TStart,TDay,TNight;
   MqlDateTime STRTime;
   int IStart,IDay,INight;
   int IDayHight,IDayLow,INightHight,INightLow;
   double MHightD[1],MLowD[1],MHightN[1],MLowN[1];

//---
   TimeToStruct(Day,STRTime);
   STRTime.hour= 10;
   STRTime.min = 0;
   TStart=StructToTime(STRTime);
   STRTime.hour= 18;
   STRTime.min = 40;
   TDay=StructToTime(STRTime);
   STRTime.hour= 23;
   STRTime.min = 45;
   TNight=StructToTime(STRTime);
//Print (TStart, TDay, TNight);
   IStart=iBarShift(NULL,PERIOD_CURRENT,TStart,true);
   IDay=iBarShift(NULL,PERIOD_CURRENT,TDay,true);
   INight=iBarShift(NULL,PERIOD_CURRENT,TNight,true);
//Print ("IStart = ", IStart , " IDay = ", IDay, " INight = ",INight);
   IDayHight=iHighest(NULL,0,MODE_HIGH,IStart-IDay+1,IDay);
   IDayLow=iLowest(NULL,0,MODE_LOW,IStart-IDay+1,IDay);
   INightHight=iHighest(NULL,0,MODE_HIGH,IStart-INight+2,INight);
   INightLow=iLowest(NULL,0,MODE_LOW,IStart-INight+2,INight);
   CopyHigh(NULL,0,IDayHight,1,MHightD);
   CopyHigh(NULL,0,INightHight,1,MHightN);
   CopyLow(NULL,0,IDayLow,1,MLowD);
   CopyLow(NULL,0,INightLow,1,MLowN);
//Print ("Hight дня = ",MHightD[0]," - ",IDayHight," Low дня = ", MLowD[0], " - ",IDayLow," Hight с вечером = ", MHightN[0], " - ",INightHight, " Low с вечером = ",MLowN[0], " - ",INightLow);
   ObjectCreate(0,"NOFX_DH",OBJ_HLINE,0,IStart,MHightD[0]);
   ObjectSetInteger(0,"NOFX_DH",OBJPROP_COLOR,Day_level);
   ObjectSetInteger(0,"NOFX_DH",OBJPROP_HIDDEN,false);
   ObjectCreate(0,"NOFX_DL",OBJ_HLINE,0,IStart,MLowD[0]);
   ObjectSetInteger(0,"NOFX_DL",OBJPROP_COLOR,Day_level);
   ObjectSetInteger(0,"NOFX_DL",OBJPROP_HIDDEN,false);

   if(Night_Session)//если включен учёт ночной сессии, то дорисовываем ночные экстремумы если они выходят за рамки дня
     {
      if(MHightD[0]<MHightN[0])//если дневной максимум меньше ночного то дорисовываем уровень вечернего максимума
        {
         ObjectCreate(0,"NOFX_NH",OBJ_HLINE,0,IStart,MHightN[0]);
         ObjectSetInteger(0,"NOFX_NH",OBJPROP_COLOR,Night_Level);
         ObjectSetInteger(0,"NOFX_NH",OBJPROP_HIDDEN,false);
        }
      if(MLowD[0]>MLowN[0])//если дневной минимум больше ночного то дорисовываем ночной минимум
        {
         ObjectCreate(0,"NOFX_DL",OBJ_HLINE,0,IStart,MLowN[0]);
         ObjectSetInteger(0,"NOFX_DL",OBJPROP_COLOR,Night_Level);
         ObjectSetInteger(0,"NOFX_DL",OBJPROP_HIDDEN,false);
        }
     }

  }
//+------------------------------------------------------------------+
