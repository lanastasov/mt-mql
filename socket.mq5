 //+------------------------------------------------------------------+
//|                                                       socket.mq5 |
//|                                                        avoitenko |
//|                        https://login.mql5.com/en/users/avoitenko |
//+------------------------------------------------------------------+
#property copyright "avoitenko"
#property link      "https://login.mql5.com/en/users/avoitenko"
#property version   "1.00"

//+------------------------------------------------------------------+
//|   Defines                                                        |
//+------------------------------------------------------------------+
#define ERROR_SUCCESS               0
#define SOCKET_STATUS_CONNECTED		1
#define SOCKET_STATUS_DISCONNECTED	2
//+------------------------------------------------------------------+
//|   SOCKET_CLIENT                                                  |
//+------------------------------------------------------------------+
struct SOCKET_CLIENT
  {
   uchar             status;
   ushort            sequence;
   uint              sock;
  };
//+------------------------------------------------------------------+
//|   ENUM_DATA_TYPE                                                 |
//+------------------------------------------------------------------+
enum ENUM_DATA_TYPE
  {
   DATA_STRING,//String
   DATA_STRUCT //Struct
  };
//+------------------------------------------------------------------+
//|   Inport DLL                                                     |
//+------------------------------------------------------------------+
#import "socket_mql5_x86.dll"
uint SocketOpen(SOCKET_CLIENT &socket,const string host,const ushort port);
void SocketClose(SOCKET_CLIENT &socket);
uint SocketWriteStruct(SOCKET_CLIENT &socket,const string symbol,const MqlTick &tick);
uint SocketWriteString(SOCKET_CLIENT &socket,const string str);
string SocketErrorString(int error_code);
#import "socket_mql5_x64.dll"
uint SocketOpen(SOCKET_CLIENT &socket,const string host,const ushort port);
void SocketClose(SOCKET_CLIENT &socket);
uint SocketWriteStruct(SOCKET_CLIENT &socket,const string symbol,const MqlTick &tick);
uint SocketWriteString(SOCKET_CLIENT &socket,const string str);
string SocketErrorString(int error_code);
#import
//+------------------------------------------------------------------+
//|   SocketOpen                                                     |
//+------------------------------------------------------------------+
uint SocketOpen(SOCKET_CLIENT &socket,const string host,const ushort port)
  {
   if(_IsX64)return(socket_mql5_x64::SocketOpen(socket, host, port));
   return(socket_mql5_x86::SocketOpen(socket, host, port));
  }
//+------------------------------------------------------------------+
//|   SocketClose                                                    |
//+------------------------------------------------------------------+
void SocketClose(SOCKET_CLIENT &socket)
  {
   if(_IsX64)socket_mql5_x64::SocketClose(socket);
   else socket_mql5_x86::SocketClose(socket);
  }
//+------------------------------------------------------------------+
//|   SocketWriteData                                                |
//+------------------------------------------------------------------+
uint SocketWriteStruct(SOCKET_CLIENT &socket,const string symbol,const MqlTick &tick)
  {
   if(_IsX64)return(socket_mql5_x64::SocketWriteStruct(socket,symbol,tick));
   return(socket_mql5_x86::SocketWriteStruct(socket,symbol,tick));
  }
//+------------------------------------------------------------------+
//|   SocketWriteString                                              |
//+------------------------------------------------------------------+
uint SocketWriteString(SOCKET_CLIENT &socket,const string str)
  {
   if(_IsX64)return(socket_mql5_x64::SocketWriteString(socket,str));
   return(socket_mql5_x86::SocketWriteString(socket,str));
  }
//+------------------------------------------------------------------+
//|   SysErrorMessage                                                |
//+------------------------------------------------------------------+
string SocketErrorString(const int error_code)
  {
   if(_IsX64)return(socket_mql5_x64::SocketErrorString(error_code));
   return(socket_mql5_x86::SocketErrorString(error_code));
  }

//+------------------------------------------------------------------+
//|   Input variables                                                |
//+------------------------------------------------------------------+
input string         InpHost="localhost"; // Host
input ushort         InpPort=777;         // Port
input ENUM_DATA_TYPE InpType=DATA_STRING; // Data Type

//--- global variables
SOCKET_CLIENT client;
MqlTick last_tick;
//+------------------------------------------------------------------+
//|   OnInit                                                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SocketOpen(client,InpHost,InpPort);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|   OnDeinit                                                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SocketClose(client);
  }
//+------------------------------------------------------------------+
//|   OnTick                                                         |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(!SymbolInfoTick(_Symbol,last_tick))return;

   string str_msg=StringFormat("symbol: %s dt: %s bid: %s ask: %s",_Symbol,TimeToString(last_tick.time,TIME_DATE|TIME_SECONDS),
                               DoubleToString(last_tick.bid,_Digits),DoubleToString(last_tick.ask,_Digits));

   switch(InpType)
     {
      case DATA_STRING: //write string
        {
         string str_out=StringFormat("%s %s %s %s",_Symbol,TimeToString(last_tick.time,TIME_DATE|TIME_SECONDS),
                                     DoubleToString(last_tick.bid,_Digits),DoubleToString(last_tick.ask,_Digits));

         uint err=SocketWriteString(client,str_out);
         if(err!=ERROR_SUCCESS)
           {
            Print(SocketErrorString(err));
            SocketOpen(client,InpHost,InpPort);
           }
         else
            Print(str_msg);
        }
      break;

      case DATA_STRUCT: //write struct
        {

         uint err=SocketWriteStruct(client,_Symbol,last_tick);
         if(err!=ERROR_SUCCESS)
           {
            Print(SocketErrorString(err));
            SocketOpen(client,InpHost,InpPort);
           }
         else
            Print(str_msg);
        }
      break;
     }// end switch
  }
//+------------------------------------------------------------------+
