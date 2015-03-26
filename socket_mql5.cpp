// https://www.mql5.com/en/code/169
//+------------------------------------------------------------------+
//|		SOCKET client DLL Library				                    |
//+------------------------------------------------------------------+

#define	_CRT_SECURE_NO_DEPRECATE
#include <windows.h>

#pragma comment(lib, "ws2_32.lib")
#pragma intrinsic(__rdtsc)

#define	SOCKET_STATUS_CONNECTED		1
#define	SOCKET_STATUS_DISCONNECTED	2

typedef struct _SOCKET_CLIENT
{
	BYTE status;
	USHORT sequence;
	ULONG sock;
} SOCKET_CLIENT, *PSOCKET_CLIENT;

typedef struct _MqlTick
{
	__int64	time;
	double	bid;
	double	ask;
	double	last;
	__int64	volume;	
} MqlTick;

typedef struct _SOCKET_DATA
{
	char symbol[16];
	MqlTick tick;
} SOCKET_DATA;

//+------------------------------------------------------------------+
//|		my_rand				                                        |
//+------------------------------------------------------------------+
ULONG my_rand()
{
	return (ULONG)__rdtsc();
}

//+------------------------------------------------------------------+
//|		Host2Ip				                                        |
//+------------------------------------------------------------------+
ULONG Host2Ip(char * host)
{
	struct hostent * p;
	ULONG ret;
	p = gethostbyname(host);
	if(p) ret = *(ULONG*)(p->h_addr);
	else ret = INADDR_NONE;
	return ret;
}

//+------------------------------------------------------------------+
//|		ConnectToServer												|
//+------------------------------------------------------------------+
ULONG ConnectToServer(char * host, USHORT port)
{
	struct sockaddr_in addr;
	BOOL bOptVal = TRUE;
	int bOptLen = sizeof(BOOL);

	ULONG ip;
	SOCKET sock = INVALID_SOCKET;

	ip = Host2Ip(host);
	if (ip != INADDR_NONE)
	{
		addr.sin_addr.S_un.S_addr = ip;
		addr.sin_port = htons(port);

		if (addr.sin_addr.S_un.S_addr != INADDR_NONE)
		{
			addr.sin_family = AF_INET;
			sock = (ULONG)socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);//IPPROTO_TCP

			if (sock != INVALID_SOCKET)
			{
				if (connect(sock, (struct sockaddr *)&addr, sizeof(addr)))
				{
					closesocket(sock);
					sock = INVALID_SOCKET;
				}
			}
		}
	}

	return (ULONG)sock;
}

//+------------------------------------------------------------------+
//|		SocketOpen			                                        |
//+------------------------------------------------------------------+
ULONG __stdcall SocketOpen(PSOCKET_CLIENT client, wchar_t * wc_host, USHORT port)
{
	ULONG ret = ERROR_INVALID_HANDLE;

	char *host  = new char[wcslen(wc_host) + 1]; 
	wcstombs(host, wc_host, wcslen(wc_host) + 1);

	client->status = SOCKET_STATUS_DISCONNECTED;
	client->sequence = (USHORT)my_rand();
	client->sock = ConnectToServer(host, port);

	if (client->sock == INVALID_SOCKET)
	{	
		closesocket(client->sock);
	}
	else
	{
		client->status = SOCKET_STATUS_CONNECTED;
		ret = ERROR_SUCCESS;
	}
	delete(host);

	return(ret);
}
//+------------------------------------------------------------------+
//|		SocketClose			                                        |
//+------------------------------------------------------------------+
void __stdcall SocketClose(PSOCKET_CLIENT client)
{
	if (client->status == SOCKET_STATUS_CONNECTED)
	{
		closesocket(client->sock);
		client->status = SOCKET_STATUS_DISCONNECTED;
	}
}

//+------------------------------------------------------------------+
//|		SocketWriteStruct                                           |
//+------------------------------------------------------------------+
ULONG __stdcall SocketWriteStruct(PSOCKET_CLIENT client, wchar_t *symbol, MqlTick *tick)
{
	SOCKET_DATA mydata={0};
	char cdata[sizeof(_SOCKET_DATA)]={0};
	ULONG ret = ERROR_INVALID_HANDLE;

	wcstombs(mydata.symbol, symbol, sizeof(mydata.symbol));

	if(client->status == SOCKET_STATUS_CONNECTED)
	{
		//build data
		memcpy(&mydata.tick, tick, sizeof(MqlTick));
		memcpy(&cdata, &mydata, sizeof(SOCKET_DATA));

		//send data
		if (send(client->sock, cdata, sizeof(SOCKET_DATA), 0) != sizeof(SOCKET_DATA))
		{
			client->status = SOCKET_STATUS_DISCONNECTED;
			ret = GetLastError();
			closesocket(client->sock);
		}
		else
			ret = ERROR_SUCCESS;
	}

	return ret;
}


//+------------------------------------------------------------------+
//|		SocketWriteString                                           |
//+------------------------------------------------------------------+
ULONG __stdcall SocketWriteString(PSOCKET_CLIENT client, wchar_t *wstr)
{
	ULONG ret = ERROR_INVALID_HANDLE;

	char * str  = new char[wcslen(wstr) + 1]; 
	wcstombs(str, wstr, wcslen(wstr) + 1);

	if (client->status == SOCKET_STATUS_CONNECTED)
	{
		//--- send string
		if(send(client->sock, str, (int)strlen(str), 0) != strlen(str))
		{
			client->status = SOCKET_STATUS_DISCONNECTED;
			ret = GetLastError();
			closesocket(client->sock);
		}
		else
			ret = ERROR_SUCCESS;
	}
	delete (str);
	return ret;
}


//+------------------------------------------------------------------+
//|		SocketErrorString                                           |
//+------------------------------------------------------------------+
wchar_t * __stdcall SocketErrorString(int error_code)
{
	wchar_t buffer[255]={0};
	if(FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, error_code, LANG_NEUTRAL, buffer, 255, 0)>0)
	{
		for(size_t i=0; i<wcslen(buffer);i++)
			if(buffer[i]>0 && buffer[i]<32) buffer[i]=32;
	}
	else
	{
		wchar_t strerr[16];
		_itow(error_code,strerr,10);
		wcscpy(&buffer[0],L"Error ");
		wcscpy(&buffer[6],strerr);
	}
	return(&buffer[0]);
}

//+------------------------------------------------------------------+
//|		DllMain				                                        |
//+------------------------------------------------------------------+
BOOL __stdcall DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{	
	WSADATA ws;
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		WSAStartup(0x202, &ws);			
		break;
	case DLL_PROCESS_DETACH:
		WSACleanup();
		break;
	}
	return 1;
}
