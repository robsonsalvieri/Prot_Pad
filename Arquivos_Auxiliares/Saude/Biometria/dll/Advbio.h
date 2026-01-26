// Insert your headers here
#include <windows.h>
#include <stdio.h>
#include "NBioAPI.h"
//#include "NBioBSPInter.h"

//#define ADVPL_BIO __declspec(dllexport)
/*
//Include ODS headers
FP_NBioAPI_Init                  NBioAPI_Init;
FP_NBioAPI_Terminate             NBioAPI_Terminate;

// Basic Functions
FP_NBioAPI_GetVersion            NBioAPI_GetVersion;
FP_NBioAPI_GetInitInfo           NBioAPI_GetInitInfo;
FP_NBioAPI_SetInitInfo           NBioAPI_SetInitInfo;

// Device Functions
FP_NBioAPI_EnumerateDevice       NBioAPI_EnumerateDevice;
FP_NBioAPI_OpenDevice            NBioAPI_OpenDevice;
FP_NBioAPI_CloseDevice           NBioAPI_CloseDevice;
FP_NBioAPI_GetDeviceInfo         NBioAPI_GetDeviceInfo;
FP_NBioAPI_SetDeviceInfo         NBioAPI_SetDeviceInfo;
FP_NBioAPI_AdjustDevice          NBioAPI_AdjustDevice;

//Memory Functions
FP_NBioAPI_FreeFIRHandle         NBioAPI_FreeFIRHandle;
FP_NBioAPI_GetFIRFromHandle      NBioAPI_GetFIRFromHandle;
FP_NBioAPI_GetHeaderFromHandle   NBioAPI_GetHeaderFromHandle;
FP_NBioAPI_FreeFIR               NBioAPI_FreeFIR;
FP_NBioAPI_FreePayload           NBioAPI_FreePayload;

// TextEncode Funtions
FP_NBioAPI_GetTextFIRFromHandle  NBioAPI_GetTextFIRFromHandle;
FP_NBioAPI_FreeTextFIR           NBioAPI_FreeTextFIR;

// Extened Functions
FP_NBioAPI_GetExtendedFIRFromHandle       NBioAPI_GetExtendedFIRFromHandle;
FP_NBioAPI_GetExtendedHeaderFromHandle    NBioAPI_GetExtendedHeaderFromHandle;
FP_NBioAPI_GetExtendedTextFIRFromHandle   NBioAPI_GetExtendedTextFIRFromHandle;

// BSP Functions
FP_NBioAPI_Capture               NBioAPI_Capture;
FP_NBioAPI_Process               NBioAPI_Process;
FP_NBioAPI_CreateTemplate        NBioAPI_CreateTemplate;
FP_NBioAPI_VerifyMatch           NBioAPI_VerifyMatch;
FP_NBioAPI_Enroll                NBioAPI_Enroll;
FP_NBioAPI_Verify                NBioAPI_Verify;

// Skin Function
FP_NBioAPI_SetSkinResource       NBioAPI_SetSkinResource;
*/
/*
bool IsValidModule();
long GetBSPVersion(TCHAR* tstr);
long GetBSPInfo(NBioAPI_INIT_INFO_0* pInitInfo);
long SetBSPInfo(NBioAPI_INIT_INFO_0* pInitInfo);
long EnumerateDevice(DWORD *num, NBioAPI_DEVICE_ID** pDeviceID);
long OpenDevice(NBioAPI_DEVICE_ID deviceID);
long CloseDevice(NBioAPI_DEVICE_ID deviceID);
long GetDeviceInfo(NBioAPI_DEVICE_ID deviceID, NBioAPI_DEVICE_INFO_0 *pDeviceInfo);

long Enroll(NBioAPI_FIR_HANDLE* hFIR, NBioAPI_FIR_PAYLOAD* payload);

long GetFirLength(NBioAPI_FIR_HANDLE hFIR);

long GetFullFIR(NBioAPI_FIR_HANDLE hFIR, NBioAPI_FIR* pFullFIR);
long GetTextFIR(NBioAPI_FIR_HANDLE hFIR, NBioAPI_FIR_TEXTENCODE* pTextFIR);

long MakeStreamFromFIR(NBioAPI_FIR* pFullFIR, BYTE* pBinaryStream);
long MakeStreamFromTextFIR(NBioAPI_FIR_TEXTENCODE* pTextFIR, char* pTextStream);
long MakeFIRFromStream(BYTE* pBinaryStream, NBioAPI_FIR* pFullFIR);
long MakeTextFIRFromStream(char* pTextStream, NBioAPI_FIR_TEXTENCODE* pTextFIR);

long Capture(NBioAPI_FIR_HANDLE* hFIR, NBioAPI_FIR_PAYLOAD* payload, NBioAPI_FIR_PURPOSE nPurpose);
long Verify(NBioAPI_INPUT_FIR* inputFIR,NBioAPI_BOOL* result, NBioAPI_FIR_PAYLOAD* ppayload);
long VerifyMatch(NBioAPI_INPUT_FIR* inputFIR1, NBioAPI_INPUT_FIR* inputFIR2, NBioAPI_BOOL* result, NBioAPI_FIR_PAYLOAD* ppayload);

long FreeFIRHandle(NBioAPI_FIR_HANDLE hFIR);
long FreeFIR(NBioAPI_FIR* pFIR);
long FreeTextFIR(NBioAPI_FIR_TEXTENCODE* pTextFIR);
long FreePayload(NBioAPI_FIR_PAYLOAD* payload);

long SetSkinResource(LPCTSTR szResPath);

NBioAPI_FIR_FORMAT m_nFIRFormat;

void SetFIRFormat(NBioAPI_FIR_FORMAT nFIRFormat) { m_nFIRFormat = nFIRFormat; }
NBioAPI_FIR_FORMAT GetFIRFormat() { return m_nFIRFormat; }

long GetError(void);
*/
#ifdef __cplusplus
extern "C" {
#endif 

int FK_Init(void);
int FK_Close(int hDevice);
char* FK_Capture(void);
int FK_Verify(char* ToVerify);
int FK_VerifyMatch(char* FkStored, char* ToVerify);
long FAR PASCAL _ExecInClientDLL(long,char *,char *,long);
#ifdef __cplusplus
}
#endif 