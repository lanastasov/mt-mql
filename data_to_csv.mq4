//+------------------------------------------------------------------+
//|                                                  Data_to_CSV.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Inovance"
#property link      "https://www.inovancetech.com/"
#property description "Save OHLCV data to a csv file."
#property version   "1.00"
#property strict
#property indicator_chart_window

   //Filename
input string   FileName = "PriceData.csv";



//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
  
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
      //Define variables
      int limit,i;
      int counted_bars = IndicatorCounted();
      
      //Make sure on most recent bar
      if(counted_bars>0) counted_bars--;
   
      //Set limit
      limit = Bars - counted_bars - 1;
      
      
      //Main loop
      for(i = limit - 1; i>=0; i--) 
         { 
          
            //Create and Open file
            int handle=FileOpen(FileName,FILE_CSV|FILE_READ|FILE_WRITE,",");
            
            //Name column headers
            FileWrite(handle,"Open Timestamp","Open","High","Low","Close","Volume");
            
            //Go to end of file
            FileSeek(handle,0,SEEK_END);
            
            //Record data
            FileWrite(handle,Time[i],Open[i],High[i],Low[i],Close[i],Volume[i]);
            
            //Close file
            FileClose(handle);    
            
         }
         
      return(0);
  }