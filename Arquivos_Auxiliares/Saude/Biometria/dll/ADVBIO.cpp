// ADVBIO.cpp : Defines the entry point for the dll application.
#include "Advbio.h"
HINSTANCE		   m_hLib;	
NBioAPI_HANDLE	   m_hBSP;
NBioAPI_DEVICE_ID  deviceID = NBioAPI_DEVICE_ID_AUTO;

void _ToUpper(char * s);
#define Alert2(x) MessageBox( 0,x,"Alert",MB_OK | MB_ICONEXCLAMATION | MB_APPLMODAL);

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
			break;
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
			break;
		case DLL_PROCESS_DETACH:
			
			break;
	}
	return TRUE;
}


int FK_Init()
{
	NBioAPI_FIR_FORMAT m_nFIRFormat;
	DWORD			   m_dErrorNum;
/*
	m_hLib		= 0;
	m_hLib		= LoadLibrary("NBioBSP.DLL");
	m_dErrorNum = 0;

	if ( !m_hLib )
	{
		m_dErrorNum = -1;
		return 0;
	}
*/
	m_hBSP = 0;
	m_nFIRFormat = NBioAPI_FIR_FORMAT_STANDARD;
/*
	// Basic Functions
	NBioAPI_Init		= (FP_NBioAPI_Init) GetProcAddress(m_hLib, "NBioAPI_Init");
	NBioAPI_Terminate   = (FP_NBioAPI_Terminate) GetProcAddress(m_hLib, "NBioAPI_Terminate");
	NBioAPI_GetVersion  = (FP_NBioAPI_GetVersion) GetProcAddress(m_hLib, "NBioAPI_GetVersion");
	NBioAPI_GetInitInfo = (FP_NBioAPI_GetInitInfo) GetProcAddress(m_hLib, "NBioAPI_GetInitInfo");
	NBioAPI_SetInitInfo = (FP_NBioAPI_SetInitInfo) GetProcAddress(m_hLib, "NBioAPI_SetInitInfo");

	// Device Functions
	NBioAPI_EnumerateDevice = (FP_NBioAPI_EnumerateDevice) GetProcAddress(m_hLib, "NBioAPI_EnumerateDevice");
	NBioAPI_OpenDevice		= (FP_NBioAPI_OpenDevice) GetProcAddress(m_hLib, "NBioAPI_OpenDevice");
	NBioAPI_CloseDevice		= (FP_NBioAPI_CloseDevice) GetProcAddress(m_hLib, "NBioAPI_CloseDevice");
	NBioAPI_GetDeviceInfo	= (FP_NBioAPI_GetDeviceInfo) GetProcAddress(m_hLib, "NBioAPI_GetDeviceInfo");
	NBioAPI_SetDeviceInfo	= (FP_NBioAPI_SetDeviceInfo) GetProcAddress(m_hLib, "NBioAPI_SetDeviceInfo");
	NBioAPI_AdjustDevice	= (FP_NBioAPI_AdjustDevice) GetProcAddress(m_hLib, "NBioAPI_AdjustDevice");

	//Memory Functions
	NBioAPI_FreeFIRHandle		= (FP_NBioAPI_FreeFIRHandle) GetProcAddress(m_hLib, "NBioAPI_FreeFIRHandle");
	NBioAPI_GetFIRFromHandle	= (FP_NBioAPI_GetFIRFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetFIRFromHandle");
	NBioAPI_GetHeaderFromHandle = (FP_NBioAPI_GetHeaderFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetHeaderFromHandle");
	NBioAPI_FreeFIR				= (FP_NBioAPI_FreeFIR) GetProcAddress(m_hLib, "NBioAPI_FreeFIR");
	NBioAPI_FreePayload			= (FP_NBioAPI_FreePayload) GetProcAddress(m_hLib, "NBioAPI_FreePayload");

	// TextEncode Funtions
	NBioAPI_GetTextFIRFromHandle = (FP_NBioAPI_GetTextFIRFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetTextFIRFromHandle");
	NBioAPI_FreeTextFIR			 = (FP_NBioAPI_FreeTextFIR) GetProcAddress(m_hLib, "NBioAPI_FreeTextFIR");

	// Extened Functions
	NBioAPI_GetExtendedFIRFromHandle	 = (FP_NBioAPI_GetExtendedFIRFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetExtendedFIRFromHandle");
	NBioAPI_GetExtendedHeaderFromHandle  = (FP_NBioAPI_GetExtendedHeaderFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetExtendedHeaderFromHandle");
	NBioAPI_GetExtendedTextFIRFromHandle = (FP_NBioAPI_GetExtendedTextFIRFromHandle) GetProcAddress(m_hLib, "NBioAPI_GetExtendedTextFIRFromHandle");

	// BSP Functions
	NBioAPI_Capture		   = (FP_NBioAPI_Capture) GetProcAddress(m_hLib, "NBioAPI_Capture");
	NBioAPI_Process		   = (FP_NBioAPI_Process) GetProcAddress(m_hLib, "NBioAPI_Process");
	NBioAPI_CreateTemplate = (FP_NBioAPI_CreateTemplate) GetProcAddress(m_hLib, "NBioAPI_CreateTemplate");
	NBioAPI_VerifyMatch	   = (FP_NBioAPI_VerifyMatch) GetProcAddress(m_hLib, "NBioAPI_VerifyMatch");
	NBioAPI_Enroll		   = (FP_NBioAPI_Enroll) GetProcAddress(m_hLib, "NBioAPI_Enroll");
	NBioAPI_Verify		   = (FP_NBioAPI_Verify) GetProcAddress(m_hLib, "NBioAPI_Verify");

	// Skin Function
	NBioAPI_SetSkinResource = (FP_NBioAPI_SetSkinResource) GetProcAddress(m_hLib, "NBioAPI_SetSkinResource");
*/
	NBioAPI_Init(&m_hBSP);

	if(m_hBSP)
		m_dErrorNum = NBioAPI_OpenDevice(m_hBSP,deviceID);
	else
		MessageBox(NULL, "Dispositivo não encontrado.", "Erro", MB_TOPMOST|MB_SETFOREGROUND|MB_OK);

	return 1;
}

int FK_Close(int hDevice)
{
	if (m_hBSP == NULL)
		return -1;
	
	NBioAPI_CloseDevice(m_hBSP, deviceID);
	
	if (m_hBSP)
		NBioAPI_Terminate(m_hBSP);
	
	if (m_hLib)
		FreeLibrary(m_hLib);
	
	m_hLib = 0;
	
	return 0;
}
char* FK_Capture(void)
{
	char* ret = NULL;

	// Inicializa o Dispositivo
	FK_Init();
	
	if (m_hBSP == NULL)
		return ret;

	NBioAPI_RETURN		   err;
	NBioAPI_FIR_TEXTENCODE g_TextFIR;
	NBioAPI_WINDOW_OPTION  pwindow;
	NBioAPI_SINT32		   time_out		= -1;
	NBioAPI_FIR_HANDLE_PTR paudit_data  = NULL;
	NBioAPI_FIR_PURPOSE	   nPurpose		= NBioAPI_FIR_PURPOSE_VERIFY;
	NBioAPI_FIR_HANDLE	   hFIR			= 0;
	NBioAPI_BOOL		   bwchar		= false;
	NBioAPI_FIR_FORMAT	   m_nFIRFormat = NBioAPI_FIR_FORMAT_STANDARD;

	memset(&pwindow,0,sizeof(NBioAPI_WINDOW_OPTION));
	pwindow.WindowStyle=NBioAPI_WINDOW_STYLE_INVISIBLE;
	
	err = NBioAPI_Capture(m_hBSP, nPurpose, &hFIR, time_out, paudit_data, &pwindow);
	
	if ( err == NBioAPIERROR_NONE )
	{
		NBioAPI_FreeTextFIR(m_hBSP, &g_TextFIR);
		
		//NBioAPI_GetTextFIRFromHandle(m_hBSP, g_hFIR, &g_TextFIR, bwchar);
		NBioAPI_GetExtendedTextFIRFromHandle(m_hBSP, hFIR, &g_TextFIR, FALSE, m_nFIRFormat);
		
		if(strlen(g_TextFIR.TextFIR))
		{
			ret = (char*) malloc(strlen(g_TextFIR.TextFIR)+1);
			strcpy(ret,g_TextFIR.TextFIR);
		}
	}
	else
	{
		MessageBox(NULL, "Falhou captura da digital.", "Erro", MB_TOPMOST|MB_SETFOREGROUND|MB_OK);
		ret = (char*) malloc(64);
		strcpy(ret,"ERROR");
	}
	
	// Finaliza o Dispositivo
	FK_Close(deviceID);
	return ret;
}

int  FK_Verify(char* ToVerify)
{
	NBioAPI_INPUT_FIR	   input_fir;	
	NBioAPI_FIR_TEXTENCODE textFIR;
	NBioAPI_FIR_PAYLOAD	   payload;
	NBioAPI_RETURN		   err;
	NBioAPI_WINDOW_OPTION  pwindow;
	NBioAPI_FIR_HANDLE_PTR paudit_data = NULL;
	NBioAPI_BOOL		   resultX	   = 0;
	NBioAPI_SINT32		   time_out    = -1;
	int					   ret		   = 0;
	
	// Inicializa o Dispositivo
	FK_Init();

	if (m_hBSP == NULL)
		return ret;
	
	memset(&textFIR, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
	memset(&input_fir, 0, sizeof(NBioAPI_INPUT_FIR));
	memset(&pwindow,0,sizeof(NBioAPI_WINDOW_OPTION));

	pwindow.WindowStyle=NBioAPI_WINDOW_STYLE_INVISIBLE;
	
	textFIR.IsWideChar=0;
	textFIR.TextFIR=ToVerify;

	input_fir.Form = NBioAPI_FIR_FORM_TEXTENCODE;
	input_fir.InputFIR.FIR=&textFIR;
	
	err = NBioAPI_Verify(m_hBSP, &input_fir, &resultX, &payload, time_out, paudit_data, &pwindow);

	if (resultX == (BOOL)NBioAPI_TRUE) // Verify Success
		ret=1;	
	
	// Finaliza o Dispositivo
	FK_Close(deviceID);
	
	return ret;
}

int  FK_VerifyMatch(char* FkStored, char* ToVerify)
{
	NBioAPI_FIR_TEXTENCODE tStored;
	NBioAPI_FIR_TEXTENCODE tVerify;

	NBioAPI_INPUT_FIR	   input_fir;
	NBioAPI_INPUT_FIR	   textFIR;

	NBioAPI_FIR_PAYLOAD	   payload;
	NBioAPI_RETURN		   err;

	NBioAPI_BOOL		   resultX	   = 0;
	int					   ret		   = 0;
	
	// Inicializa o Dispositivo
	FK_Init();

	if (m_hBSP == NULL)
		return ret;

	memset(&textFIR, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
	memset(&input_fir, 0, sizeof(NBioAPI_INPUT_FIR));
	memset(&tStored, 0, sizeof(NBioAPI_FIR_TEXTENCODE));
	memset(&tVerify,0,sizeof(NBioAPI_FIR_TEXTENCODE));

	tStored.IsWideChar=0;
	tStored.TextFIR=FkStored;

	tVerify.IsWideChar=0;
	tVerify.TextFIR=ToVerify;
	
	textFIR.Form = NBioAPI_FIR_FORM_TEXTENCODE;
	textFIR.InputFIR.FIR=&tVerify;

	input_fir.Form = NBioAPI_FIR_FORM_TEXTENCODE;
	input_fir.InputFIR.FIR=&tStored;

	err = NBioAPI_VerifyMatch(m_hBSP, &input_fir,&textFIR,&resultX, &payload);

	if (resultX == (BOOL)NBioAPI_TRUE) // Verify Success
		ret=1;

	// Finaliza o Dispositivo
	FK_Close(deviceID);

	return ret;
}

#define MAX_FINGERS 16
long FAR PASCAL ExecInClientDLL(int nFuncID, char* Params, char* cBuf, int nTam)
{
	char* p = Params;
	char* cfunction=Params;
	char* pBuffer=NULL;
	char** pParam = NULL;
	int i=0;
	int ret;

	pParam = (char**) malloc ( sizeof(char**) + sizeof(char*)*MAX_FINGERS);
	for(i=0;i<MAX_FINGERS;i++)
		pParam[i]=NULL;

	i=0;
	while((p = strchr(p,0x01)))
	{
		*p = '\0';
		p++;

		pParam[i] = p;
		i++;
	}

	p=cBuf;
	_ToUpper(cfunction);
	if(strncmp(cfunction,"CAPTURAR",8)==0)
	{
		p=FK_Capture();
		memcpy(cBuf, p, strlen(p)+1);
	}
	else if(strncmp(cfunction,"VERIFICAR",9)==0)
	{
		ret=FK_Verify(pParam[0]);
		sprintf(p,"%d",ret);
		memcpy(cBuf, p, strlen(p)+1);
	}
	else if(strncmp(cfunction,"MATCH",5)==0)
	{
		if(i>=1)
		{
			int j=0;
			for(j=1;j<i;j++)
			{
				ret=FK_VerifyMatch(pParam[0], pParam[j]);
				if(ret)
					break;
			}
			sprintf(p,"%d%d",ret,j);
			memcpy(cBuf, p, strlen(p)+1);
		}
		
	}
	else
	{
		free(pParam);
		return -1;
	}
	
	free(pParam);
	return 1;
}

void _ToUpper(char * s)
{
	int i=0;
    char* p=s;
	while(*p)
	{
		*p=toupper(*p);
		p++;
	}
}
