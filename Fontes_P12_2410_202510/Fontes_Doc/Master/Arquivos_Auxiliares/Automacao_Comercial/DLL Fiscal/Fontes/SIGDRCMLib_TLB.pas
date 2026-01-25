unit SIGDRCMLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.88  $
// File generated on 18/09/2000 5:26:27 PM from Type Library described below.

// ************************************************************************ //
// Type Lib: C:\WINDOWS\SYSTEM\SIGDRCM.OCX (1)
// IID\LCID: {E082E831-EA7F-11D0-86A4-000044022A8A}\0
// Helpfile: 
// DepndLst: 
//   (1) v1.0 stdole, (C:\WINDOWS\SYSTEM\stdole32.tlb)
//   (2) v2.0 StdType, (C:\WINDOWS\SYSTEM\OLEPRO32.DLL)
//   (3) v1.0 StdVCL, (C:\WINDOWS\SYSTEM\STDVCL32.DLL)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  SIGDRCMLibMajorVersion = 1;
  SIGDRCMLibMinorVersion = 0;

  LIBID_SIGDRCMLib: TGUID = '{E082E831-EA7F-11D0-86A4-000044022A8A}';

  DIID__DSigDrCm: TGUID = '{E082E832-EA7F-11D0-86A4-000044022A8A}';
  DIID__DSigDrCmEvents: TGUID = '{E082E833-EA7F-11D0-86A4-000044022A8A}';
  CLASS_SigDrCm: TGUID = '{E082E834-EA7F-11D0-86A4-000044022A8A}';
  DIID_ISigCom: TGUID = '{C6C3BE96-ED3D-11D0-86A8-000044022A8A}';
  CLASS_SIGCOM: TGUID = '{C6C3BE97-ED3D-11D0-86A8-000044022A8A}';
  DIID_ISigMod: TGUID = '{C6C3BE98-ED3D-11D0-86A8-000044022A8A}';
  CLASS_SIGMOD: TGUID = '{C6C3BE99-ED3D-11D0-86A8-000044022A8A}';
  DIID_ISigCmd: TGUID = '{C6C3BE9A-ED3D-11D0-86A8-000044022A8A}';
  CLASS_SIGCMD: TGUID = '{C6C3BE9B-ED3D-11D0-86A8-000044022A8A}';
  DIID_ISigPrn: TGUID = '{C6C3BE9C-ED3D-11D0-86A8-000044022A8A}';
  CLASS_SIGPRN: TGUID = '{C6C3BE9D-ED3D-11D0-86A8-000044022A8A}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum SigCmdDeviceType
type
  SigCmdDeviceType = TOleEnum;
const
  sigDeviceTypeSerial = $00000001;
  sigDeviceTypeParalell = $00000002;

// Constants for enum SigCmdDataType
type
  SigCmdDataType = TOleEnum;
const
  sigDataTypeConstString = $00000001;
  sigDataTypeCharString = $00000002;
  sigDataTypeByte = $00000003;
  sigDataTypeNoZeroString = $00000004;
  sigDataTypeInputUntil = $00000005;
  sigDataTypeDigit = $00000006;
  sigDataTypeHexaDigit = $00000007;
  sigDataTypeBCDDigit = $00000008;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _DSigDrCm = dispinterface;
  _DSigDrCmEvents = dispinterface;
  ISigCom = dispinterface;
  ISigMod = dispinterface;
  ISigCmd = dispinterface;
  ISigPrn = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  SigDrCm = _DSigDrCm;
  SIGCOM = ISigCom;
  SIGMOD = ISigMod;
  SIGCMD = ISigCmd;
  SIGPRN = ISigPrn;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PWideString1 = ^WideString; {*}


// *********************************************************************//
// DispIntf:  _DSigDrCm
// Flags:     (4112) Hidden Dispatchable
// GUID:      {E082E832-EA7F-11D0-86A4-000044022A8A}
// *********************************************************************//
  _DSigDrCm = dispinterface
    ['{E082E832-EA7F-11D0-86A4-000044022A8A}']
    property CmdFileName: WideString dispid 1;
    property CommConfig: WideString dispid 2;
    property CtsFlow: WordBool dispid 3;
    property DeviceType: Smallint dispid 4;
    property DsrFlow: WordBool dispid 5;
    property LibName: WideString dispid 6;
    property CmdName: WideString dispid 8;
    property AdditionalRet: WideString dispid 9;
    property TimeOut: Integer dispid 7;
    function  Open: WordBool; dispid 10;
    procedure Close; dispid 11;
    function  Write(const Buffer: WideString): Integer; dispid 12;
    function  Read(var Buffer: WideString; Count: Integer): Integer; dispid 13;
    property Param[const Name: WideString]: WideString dispid 16;
    property Ret[const Name: WideString]: WideString readonly dispid 17;
    property RetByIndex[Index: Integer]: WideString readonly dispid 18;
    function  Send: Integer; dispid 14;
    property ParamByIndex[Index: Integer]: WideString dispid 19;
    function  GetInputSize: Integer; dispid 15;
    procedure AboutBox; dispid -552;
  end;

// *********************************************************************//
// DispIntf:  _DSigDrCmEvents
// Flags:     (4096) Dispatchable
// GUID:      {E082E833-EA7F-11D0-86A4-000044022A8A}
// *********************************************************************//
  _DSigDrCmEvents = dispinterface
    ['{E082E833-EA7F-11D0-86A4-000044022A8A}']
  end;

// *********************************************************************//
// DispIntf:  ISigCom
// Flags:     (4096) Dispatchable
// GUID:      {C6C3BE96-ED3D-11D0-86A8-000044022A8A}
// *********************************************************************//
  ISigCom = dispinterface
    ['{C6C3BE96-ED3D-11D0-86A8-000044022A8A}']
    property InputSize: Integer dispid 1;
    function  Open(const Config: WideString; DeviceType: Smallint; CtsFlow: WordBool; 
                   DsrFlow: WordBool): WordBool; dispid 2;
    procedure Close; dispid 3;
    function  GetLastError: Integer; dispid 4;
    function  Write(const Buffer: WideString): Integer; dispid 5;
    function  Read(var Buffer: WideString; Count: Integer): Integer; dispid 6;
  end;

// *********************************************************************//
// DispIntf:  ISigMod
// Flags:     (4096) Dispatchable
// GUID:      {C6C3BE98-ED3D-11D0-86A8-000044022A8A}
// *********************************************************************//
  ISigMod = dispinterface
    ['{C6C3BE98-ED3D-11D0-86A8-000044022A8A}']
    property LibCount: Integer dispid 1;
    function  Open(const FileName: WideString): WordBool; dispid 2;
    procedure Close; dispid 3;
    function  GetLastError: Integer; dispid 4;
    function  GetCmd(const LibName: WideString; const CmdName: WideString): IDispatch; dispid 5;
    function  GetCmdByIndex(LibIndex: Integer; CmdIndex: Integer): IDispatch; dispid 6;
    property LibName[LibIndex: Integer]: WideString readonly dispid 7;
    property LibDesc[LibIndex: Integer]: WideString readonly dispid 8;
    property CmdName[LibIndex: Integer; CmdIndex: Integer]: WideString readonly dispid 9;
    property CmdDesc[LibIndex: Integer; CmdIndex: Integer]: WideString readonly dispid 10;
    property CmdCount[LibIndex: Integer]: Integer readonly dispid 11;
  end;

// *********************************************************************//
// DispIntf:  ISigCmd
// Flags:     (4096) Dispatchable
// GUID:      {C6C3BE9A-ED3D-11D0-86A8-000044022A8A}
// *********************************************************************//
  ISigCmd = dispinterface
    ['{C6C3BE9A-ED3D-11D0-86A8-000044022A8A}']
    property ParamCount: Integer dispid 1;
    property RetCount: Integer dispid 2;
    property ParamType[ParamIndex: Integer]: Integer readonly dispid 3;
    property ParamName[ParamIndex: Integer]: WideString readonly dispid 4;
    property ParamValue[ParamIndex: Integer]: WideString readonly dispid 5;
    property ParamSize[ParamIndex: Integer]: Integer readonly dispid 6;
    property RetType[RetIndex: Integer]: Integer readonly dispid 7;
    property RetName[RetIndex: Integer]: WideString readonly dispid 8;
    property RetValue[RetIndex: Integer]: WideString readonly dispid 9;
    property RetSize[RetIndex: Integer]: Integer readonly dispid 10;
  end;

// *********************************************************************//
// DispIntf:  ISigPrn
// Flags:     (4096) Dispatchable
// GUID:      {C6C3BE9C-ED3D-11D0-86A8-000044022A8A}
// *********************************************************************//
  ISigPrn = dispinterface
    ['{C6C3BE9C-ED3D-11D0-86A8-000044022A8A}']
    property Output: WideString dispid 1;
    property Input: WideString dispid 2;
    procedure Initialize(const Com: IDispatch; const Cmd: IDispatch); dispid 3;
    procedure Finalize; dispid 4;
    property Param[const Name: WideString]: WideString dispid 6;
    property Ret[const Name: WideString]: WideString readonly dispid 7;
    property ParamByIndex[Index: Integer]: WideString dispid 8;
    property RetByIndex[Index: Integer]: WideString readonly dispid 9;
    function  Send(var Buffer: WideString; TimeOut: Integer): Integer; dispid 5;
  end;


// *********************************************************************//
// OLE Control Proxy class declaration
// Control Name     : TSigDrCm
// Help String      : SigDrCm Control
// Default Interface: _DSigDrCm
// Def. Intf. DISP? : Yes
// Event   Interface: _DSigDrCmEvents
// TypeFlags        : (38) CanCreate Licensed Control
// *********************************************************************//
  TSigDrCm = class(TOleControl)
  private
    FIntf: _DSigDrCm;
    function  GetControlInterface: _DSigDrCm;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
    function  Get_Param(const Name: WideString): WideString;
    procedure Set_Param(const Name: WideString; const Param2: WideString);
    function  Get_Ret(const Name: WideString): WideString;
    function  Get_RetByIndex(Index: Integer): WideString;
    function  Get_ParamByIndex(Index: Integer): WideString;
    procedure Set_ParamByIndex(Index: Integer; const Param2: WideString);
  public
    function  Open: WordBool;
    procedure Close;
    function  Write(const Buffer: WideString): Integer;
    function  Read(var Buffer: WideString; Count: Integer): Integer;
    function  Send: Integer;
    function  GetInputSize: Integer;
    procedure AboutBox;
    property  ControlInterface: _DSigDrCm read GetControlInterface;
    property  DefaultInterface: _DSigDrCm read GetControlInterface;
    property Param[const Name: WideString]: WideString read Get_Param write Set_Param;
    property Ret[const Name: WideString]: WideString read Get_Ret;
    property RetByIndex[Index: Integer]: WideString read Get_RetByIndex;
    property ParamByIndex[Index: Integer]: WideString read Get_ParamByIndex write Set_ParamByIndex;
  published
    property CmdFileName: WideString index 1 read GetWideStringProp write SetWideStringProp stored False;
    property CommConfig: WideString index 2 read GetWideStringProp write SetWideStringProp stored False;
    property CtsFlow: WordBool index 3 read GetWordBoolProp write SetWordBoolProp stored False;
    property DeviceType: Smallint index 4 read GetSmallintProp write SetSmallintProp stored False;
    property DsrFlow: WordBool index 5 read GetWordBoolProp write SetWordBoolProp stored False;
    property LibName: WideString index 6 read GetWideStringProp write SetWideStringProp stored False;
    property CmdName: WideString index 8 read GetWideStringProp write SetWideStringProp stored False;
    property AdditionalRet: WideString index 9 read GetWideStringProp write SetWideStringProp stored False;
    property TimeOut: Integer index 7 read GetIntegerProp write SetIntegerProp stored False;
  end;

// *********************************************************************//
// The Class CoSIGCOM provides a Create and CreateRemote method to          
// create instances of the default interface ISigCom exposed by              
// the CoClass SIGCOM. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSIGCOM = class
    class function Create: ISigCom;
    class function CreateRemote(const MachineName: string): ISigCom;
  end;

// *********************************************************************//
// The Class CoSIGMOD provides a Create and CreateRemote method to          
// create instances of the default interface ISigMod exposed by              
// the CoClass SIGMOD. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSIGMOD = class
    class function Create: ISigMod;
    class function CreateRemote(const MachineName: string): ISigMod;
  end;

// *********************************************************************//
// The Class CoSIGCMD provides a Create and CreateRemote method to          
// create instances of the default interface ISigCmd exposed by              
// the CoClass SIGCMD. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSIGCMD = class
    class function Create: ISigCmd;
    class function CreateRemote(const MachineName: string): ISigCmd;
  end;

// *********************************************************************//
// The Class CoSIGPRN provides a Create and CreateRemote method to          
// create instances of the default interface ISigPrn exposed by              
// the CoClass SIGPRN. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSIGPRN = class
    class function Create: ISigPrn;
    class function CreateRemote(const MachineName: string): ISigPrn;
  end;

procedure Register;

implementation

uses ComObj;

procedure TSigDrCm.InitControlData;
const
  CLicenseKey: array[0..110] of Word = ( $0028, $0043, $0029, $006F, $0070, $0079, $0072, $0069, $0067, $0068, $0074
    , $0020, $0059, $0075, $006A, $0069, $0020, $0043, $006F, $006D, $00E9
    , $0072, $0063, $0069, $006F, $0020, $0065, $0020, $0053, $0065, $0072
    , $0076, $0069, $00E7, $006F, $0073, $0020, $0064, $0065, $0020, $0049
    , $006E, $0066, $006F, $0072, $006D, $00E1, $0074, $0069, $0063, $0061
    , $0020, $0053, $002F, $0043, $0020, $004C, $0074, $0064, $0061, $002E
    , $000D, $000A, $0028, $0043, $0029, $006F, $0070, $0079, $0072, $0069
    , $0067, $0068, $0074, $0020, $0053, $0069, $0067, $0074, $0072, $006F
    , $006E, $0020, $0041, $0075, $0074, $006F, $006D, $0061, $00E7, $00E3
    , $006F, $0020, $0043, $006F, $006D, $0065, $0072, $0063, $0069, $0061
    , $006C, $0020, $004C, $0074, $0064, $0061, $002E, $000D, $000A, $0000);
  CControlData: TControlData2 = (
    ClassID: '{E082E834-EA7F-11D0-86A4-000044022A8A}';
    EventIID: '';
    EventCount: 0;
    EventDispIDs: nil;
    LicenseKey: @CLicenseKey;
    Flags: $00000000;
    Version: 401);
begin
  ControlData := @CControlData;
end;

procedure TSigDrCm.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as _DSigDrCm;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TSigDrCm.GetControlInterface: _DSigDrCm;
begin
  CreateControl;
  Result := FIntf;
end;

function  TSigDrCm.Get_Param(const Name: WideString): WideString;
begin
  Result := DefaultInterface.Param[Name];
end;

procedure TSigDrCm.Set_Param(const Name: WideString; const Param2: WideString);
begin
  DefaultInterface.Param[Name] := Param2;
end;

function  TSigDrCm.Get_Ret(const Name: WideString): WideString;
begin
  Result := DefaultInterface.Ret[Name];
end;

function  TSigDrCm.Get_RetByIndex(Index: Integer): WideString;
begin
  Result := DefaultInterface.RetByIndex[Index];
end;

function  TSigDrCm.Get_ParamByIndex(Index: Integer): WideString;
begin
  Result := DefaultInterface.ParamByIndex[Index];
end;

procedure TSigDrCm.Set_ParamByIndex(Index: Integer; const Param2: WideString);
begin
  DefaultInterface.ParamByIndex[Index] := Param2;
end;

function  TSigDrCm.Open: WordBool;
begin
  Result := DefaultInterface.Open;
end;

procedure TSigDrCm.Close;
begin
  DefaultInterface.Close;
end;

function  TSigDrCm.Write(const Buffer: WideString): Integer;
begin
  Result := DefaultInterface.Write(Buffer);
end;

function  TSigDrCm.Read(var Buffer: WideString; Count: Integer): Integer;
begin
  Result := DefaultInterface.Read(Buffer, Count);
end;

function  TSigDrCm.Send: Integer;
begin
  Result := DefaultInterface.Send;
end;

function  TSigDrCm.GetInputSize: Integer;
begin
  Result := DefaultInterface.GetInputSize;
end;

procedure TSigDrCm.AboutBox;
begin
  DefaultInterface.AboutBox;
end;

class function CoSIGCOM.Create: ISigCom;
begin
  Result := CreateComObject(CLASS_SIGCOM) as ISigCom;
end;

class function CoSIGCOM.CreateRemote(const MachineName: string): ISigCom;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SIGCOM) as ISigCom;
end;

class function CoSIGMOD.Create: ISigMod;
begin
  Result := CreateComObject(CLASS_SIGMOD) as ISigMod;
end;

class function CoSIGMOD.CreateRemote(const MachineName: string): ISigMod;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SIGMOD) as ISigMod;
end;

class function CoSIGCMD.Create: ISigCmd;
begin
  Result := CreateComObject(CLASS_SIGCMD) as ISigCmd;
end;

class function CoSIGCMD.CreateRemote(const MachineName: string): ISigCmd;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SIGCMD) as ISigCmd;
end;

class function CoSIGPRN.Create: ISigPrn;
begin
  Result := CreateComObject(CLASS_SIGPRN) as ISigPrn;
end;

class function CoSIGPRN.CreateRemote(const MachineName: string): ISigPrn;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SIGPRN) as ISigPrn;
end;

procedure Register;
begin
  RegisterComponents('ActiveX',[TSigDrCm]);
end;

end.
