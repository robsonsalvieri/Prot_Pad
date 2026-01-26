unit IIntegrationDlg_TLB;

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

// PASTLWTR : $Revision: 8559 $
// File generated on 13/08/2004 15:55:18 from Type Library described below.

// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
// ************************************************************************ //
// Type Lib: P:\BCSiManage\Units\iIntegrationDlg.dll (1)
// IID\LCID: {60C28080-6218-11D2-9051-00A0C975AA49}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINNT\System32\Stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINNT\System32\STDVCL40.DLL)
// Errors:
//   Error creating palette bitmap of (TDocOpenDlg) : Invalid GUID format
//   Error creating palette bitmap of (TPortableDocOpenDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TBrowseFoldersDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TFavoritesDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TOrganizeFavoritesDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TAdvancedOptionsDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TSaveEmailDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TImportLinksDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TConfigCommonDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TDocListDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
//   Error creating palette bitmap of (TAddToFavoritesDlg) : Server C:\Program Files\iManage\iIntegrationDlg.dll contains no icons
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
  IIntegrationDlgMajorVersion = 1;
  IIntegrationDlgMinorVersion = 0;

  LIBID_IIntegrationDlg: TGUID = '{60C28080-6218-11D2-9051-00A0C975AA49}';

  DIID__IDocOpenDlgEvents: TGUID = '{C92637A0-F802-11D2-8150-00C04F81E113}';
  DIID__IConfigCommonDlgEvents: TGUID = '{6529C8CD-8A89-11D5-AB6D-00C04F6803D1}';
  IID_IPortableDualDocOpenDlg: TGUID = '{26CC9573-C84C-11D2-8314-00A0C932328D}';
  IID_IPortableDualDocOpenDlg2: TGUID = '{5C079309-A56A-11D6-ABF8-00C04F6803D1}';
  IID_IDualDocOpenDlg: TGUID = '{60C28082-6218-11D2-9051-00A0C975AA49}';
  IID_IDualDocOpenDlg2: TGUID = '{0C442D30-907E-11D3-80C2-00C04F610E35}';
  IID_IDualDocOpenDlg3: TGUID = '{11CB3ABB-A56A-11D6-ABF8-00C04F6803D1}';
  CLASS_DocOpenDlg: TGUID = '{60C28083-6218-11D2-9051-00A0C975AA49}';
  DIID__IPortableDocOpenDlgEvents: TGUID = '{59DCE383-01E6-11D4-8152-00C04F610D7A}';
  CLASS_PortableDocOpenDlg: TGUID = '{26CC9577-C84C-11D2-8314-00A0C932328D}';
  IID_IDualBrowseFoldersDlg: TGUID = '{F7DF9A29-4C12-11D3-80B7-00C04F610E35}';
  DIID__IBrowseFoldersDlgEvents: TGUID = '{F7DF9A28-4C12-11D3-80B7-00C04F610E35}';
  CLASS_BrowseFoldersDlg: TGUID = '{510387DA-4B8F-11D3-80B7-00C04F610E35}';
  IID_IDualFavoritesDlg: TGUID = '{3B4C3022-203A-41A0-9069-2FCB60737B82}';
  DIID__IFavoritesDlgEvents: TGUID = '{B3C94199-1A01-4A1E-B7AC-07C160665CE1}';
  CLASS_FavoritesDlg: TGUID = '{C95CA55E-3DFC-4311-B7DF-FCB4AD3741FA}';
  IID_IDualOrganizeFavoritesDlg: TGUID = '{2660FC53-4370-4E83-B45C-1516E677A0F0}';
  DIID__IOrganizeFavoritesDlgEvents: TGUID = '{D56F7FB7-FD12-43D3-896A-31999B727BB9}';
  CLASS_OrganizeFavoritesDlg: TGUID = '{A7326E15-BE23-4806-AD1A-8130158C3C62}';
  IID_IDualAdvancedOptionsDlg: TGUID = '{D813851B-0012-11D4-AAC0-00C04F6803D1}';
  CLASS_AdvancedOptionsDlg: TGUID = '{3A732CEA-0012-11D4-AAC0-00C04F6803D1}';
  DIID__ISaveEmailDlgEvents: TGUID = '{6A59C0DB-A14E-11D4-B969-00C04F093D23}';
  IID_ISaveEmailDlg: TGUID = '{6A59C0D9-A14E-11D4-B969-00C04F093D23}';
  CLASS_SaveEmailDlg: TGUID = '{6A59C0DA-A14E-11D4-B969-00C04F093D23}';
  DIID__IImportLinksDlgEvents: TGUID = '{38FFEEB9-FFD0-11D5-BB9A-00C04F610D7A}';
  IID_IImportLinksDlg: TGUID = '{917932D1-FFCF-11D5-BB9A-00C04F610D7A}';
  CLASS_ImportLinksDlg: TGUID = '{968F7685-FFD0-11D5-BB9A-00C04F610D7A}';
  IID_IConfigCommonDlg: TGUID = '{FD81CBE9-8A88-11D5-AB6D-00C04F6803D1}';
  CLASS_ConfigCommonDlg: TGUID = '{C04B0AD7-8A89-11D5-AB6D-00C04F6803D1}';
  DIID__IDocListDlgEvents: TGUID = '{F2D22C07-0AD0-11D6-BBA1-00C04F610D7A}';
  IID_ITreeViewOptionsDlgObj: TGUID = '{57457701-A41C-4A3B-B56B-1F6D94C60FCE}';
  IID_IDocListDlg: TGUID = '{9C7DA825-0ACD-11D6-BBA1-00C04F610D7A}';
  CLASS_DocListDlg: TGUID = '{68FAB9A7-0ACD-11D6-BBA1-00C04F610D7A}';
  IID_IAddToFavoritesDlg: TGUID = '{8722388E-D253-43AD-8AF1-47CB7BD12C5E}';
  DIID__IAddToFavoritesDlgEvents: TGUID = '{85D0B2E5-86CE-49EA-889F-C70B3C3A6128}';
  CLASS_AddToFavoritesDlg: TGUID = '{32F83878-9769-416A-A1A3-6B1F583110C0}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _IDocOpenDlgEvents = dispinterface;
  _IConfigCommonDlgEvents = dispinterface;
  IPortableDualDocOpenDlg = interface;
  IPortableDualDocOpenDlgDisp = dispinterface;
  IPortableDualDocOpenDlg2 = interface;
  IPortableDualDocOpenDlg2Disp = dispinterface;
  IDualDocOpenDlg = interface;
  IDualDocOpenDlgDisp = dispinterface;
  IDualDocOpenDlg2 = interface;
  IDualDocOpenDlg2Disp = dispinterface;
  IDualDocOpenDlg3 = interface;
  IDualDocOpenDlg3Disp = dispinterface;
  _IPortableDocOpenDlgEvents = dispinterface;
  IDualBrowseFoldersDlg = interface;
  IDualBrowseFoldersDlgDisp = dispinterface;
  _IBrowseFoldersDlgEvents = dispinterface;
  IDualFavoritesDlg = interface;
  IDualFavoritesDlgDisp = dispinterface;
  _IFavoritesDlgEvents = dispinterface;
  IDualOrganizeFavoritesDlg = interface;
  IDualOrganizeFavoritesDlgDisp = dispinterface;
  _IOrganizeFavoritesDlgEvents = dispinterface;
  IDualAdvancedOptionsDlg = interface;
  IDualAdvancedOptionsDlgDisp = dispinterface;
  _ISaveEmailDlgEvents = dispinterface;
  ISaveEmailDlg = interface;
  ISaveEmailDlgDisp = dispinterface;
  _IImportLinksDlgEvents = dispinterface;
  IImportLinksDlg = interface;
  IImportLinksDlgDisp = dispinterface;
  IConfigCommonDlg = interface;
  IConfigCommonDlgDisp = dispinterface;
  _IDocListDlgEvents = dispinterface;
  ITreeViewOptionsDlgObj = interface;
  ITreeViewOptionsDlgObjDisp = dispinterface;
  IDocListDlg = interface;
  IDocListDlgDisp = dispinterface;
  IAddToFavoritesDlg = interface;
  IAddToFavoritesDlgDisp = dispinterface;
  _IAddToFavoritesDlgEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  DocOpenDlg = IDualDocOpenDlg3;
  PortableDocOpenDlg = IPortableDualDocOpenDlg2;
  BrowseFoldersDlg = IDualBrowseFoldersDlg;
  FavoritesDlg = IDualFavoritesDlg;
  OrganizeFavoritesDlg = IDualOrganizeFavoritesDlg;
  AdvancedOptionsDlg = IDualAdvancedOptionsDlg;
  SaveEmailDlg = ISaveEmailDlg;
  ImportLinksDlg = IImportLinksDlg;
  ConfigCommonDlg = IConfigCommonDlg;
  DocListDlg = IDocListDlg;
  AddToFavoritesDlg = IAddToFavoritesDlg;


// *********************************************************************//
// DispIntf:  _IDocOpenDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {C92637A0-F802-11D2-8150-00C04F81E113}
// *********************************************************************//
  _IDocOpenDlgEvents = dispinterface
    ['{C92637A0-F802-11D2-8150-00C04F81E113}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// DispIntf:  _IConfigCommonDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {6529C8CD-8A89-11D5-AB6D-00C04F6803D1}
// *********************************************************************//
  _IConfigCommonDlgEvents = dispinterface
    ['{6529C8CD-8A89-11D5-AB6D-00C04F6803D1}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: IPortableDualDocOpenDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {26CC9573-C84C-11D2-8314-00A0C932328D}
// *********************************************************************//
  IPortableDualDocOpenDlg = interface(IDispatch)
    ['{26CC9573-C84C-11D2-8314-00A0C932328D}']
    procedure Show(ParentWnd: Integer); safecall;
    function  Window: Integer; safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    function  Get_PortableSession: IDispatch; safecall;
    procedure Set_PortableSession(const pVal: IDispatch); safecall;
    function  Get_DocumentList: OleVariant; safecall;
    procedure Set_DocumentList(pVal: OleVariant); safecall;
    function  Get_SingleSel: WordBool; safecall;
    procedure Set_SingleSel(pVal: WordBool); safecall;
    function  Get_CommandList: OleVariant; safecall;
    procedure Set_CommandList(pVal: OleVariant); safecall;
    function  Get_CommandSelected: OleVariant; safecall;
    procedure Set_CommandSelected(pVal: OleVariant); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property PortableSession: IDispatch read Get_PortableSession write Set_PortableSession;
    property DocumentList: OleVariant read Get_DocumentList write Set_DocumentList;
    property SingleSel: WordBool read Get_SingleSel write Set_SingleSel;
    property CommandList: OleVariant read Get_CommandList write Set_CommandList;
    property CommandSelected: OleVariant read Get_CommandSelected write Set_CommandSelected;
  end;

// *********************************************************************//
// DispIntf:  IPortableDualDocOpenDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {26CC9573-C84C-11D2-8314-00A0C932328D}
// *********************************************************************//
  IPortableDualDocOpenDlgDisp = dispinterface
    ['{26CC9573-C84C-11D2-8314-00A0C932328D}']
    procedure Show(ParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property PortableSession: IDispatch dispid 4;
    property DocumentList: OleVariant dispid 5;
    property SingleSel: WordBool dispid 6;
    property CommandList: OleVariant dispid 7;
    property CommandSelected: OleVariant dispid 8;
  end;

// *********************************************************************//
// Interface: IPortableDualDocOpenDlg2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5C079309-A56A-11D6-ABF8-00C04F6803D1}
// *********************************************************************//
  IPortableDualDocOpenDlg2 = interface(IPortableDualDocOpenDlg)
    ['{5C079309-A56A-11D6-ABF8-00C04F6803D1}']
    procedure Set_FilterAppType(const Param1: WideString); safecall;
    procedure Set_Caption(const Param1: WideString); safecall;
    property FilterAppType: WideString write Set_FilterAppType;
    property Caption: WideString write Set_Caption;
  end;

// *********************************************************************//
// DispIntf:  IPortableDualDocOpenDlg2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {5C079309-A56A-11D6-ABF8-00C04F6803D1}
// *********************************************************************//
  IPortableDualDocOpenDlg2Disp = dispinterface
    ['{5C079309-A56A-11D6-ABF8-00C04F6803D1}']
    property FilterAppType: WideString writeonly dispid 9;
    property Caption: WideString writeonly dispid 10;
    procedure Show(ParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property PortableSession: IDispatch dispid 4;
    property DocumentList: OleVariant dispid 5;
    property SingleSel: WordBool dispid 6;
    property CommandList: OleVariant dispid 7;
    property CommandSelected: OleVariant dispid 8;
  end;

// *********************************************************************//
// Interface: IDualDocOpenDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {60C28082-6218-11D2-9051-00A0C975AA49}
// *********************************************************************//
  IDualDocOpenDlg = interface(IDispatch)
    ['{60C28082-6218-11D2-9051-00A0C975AA49}']
    procedure Show(hParentWnd: Integer); safecall;
    function  Window: Integer; safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    function  Get_NRTDMS: IDispatch; safecall;
    procedure Set_NRTDMS(const pVal: IDispatch); safecall;
    function  Get_DocumentList: OleVariant; safecall;
    procedure Set_DocumentList(pVal: OleVariant); safecall;
    function  Get_SingleSel: WordBool; safecall;
    procedure Set_SingleSel(pVal: WordBool); safecall;
    function  Get_CommandList: OleVariant; safecall;
    procedure Set_CommandList(pVal: OleVariant); safecall;
    function  Get_CommandSelected: Integer; safecall;
    procedure Set_CommandSelected(pVal: Integer); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property DocumentList: OleVariant read Get_DocumentList write Set_DocumentList;
    property SingleSel: WordBool read Get_SingleSel write Set_SingleSel;
    property CommandList: OleVariant read Get_CommandList write Set_CommandList;
    property CommandSelected: Integer read Get_CommandSelected write Set_CommandSelected;
  end;

// *********************************************************************//
// DispIntf:  IDualDocOpenDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {60C28082-6218-11D2-9051-00A0C975AA49}
// *********************************************************************//
  IDualDocOpenDlgDisp = dispinterface
    ['{60C28082-6218-11D2-9051-00A0C975AA49}']
    procedure Show(hParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property NRTDMS: IDispatch dispid 4;
    property DocumentList: OleVariant dispid 5;
    property SingleSel: WordBool dispid 6;
    property CommandList: OleVariant dispid 7;
    property CommandSelected: Integer dispid 8;
  end;

// *********************************************************************//
// Interface: IDualDocOpenDlg2
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0C442D30-907E-11D3-80C2-00C04F610E35}
// *********************************************************************//
  IDualDocOpenDlg2 = interface(IDualDocOpenDlg)
    ['{0C442D30-907E-11D3-80C2-00C04F610E35}']
    function  Get_ShowContainedDocuments: IDispatch; safecall;
    procedure Set_ShowContainedDocuments(const pVal: IDispatch); safecall;
    function  Get_AdvancedOptions: OleVariant; safecall;
    procedure Set_AdvancedOptions(pVal: OleVariant); safecall;
    procedure Set_Caption(const Param1: WideString); safecall;
    property ShowContainedDocuments: IDispatch read Get_ShowContainedDocuments write Set_ShowContainedDocuments;
    property AdvancedOptions: OleVariant read Get_AdvancedOptions write Set_AdvancedOptions;
    property Caption: WideString write Set_Caption;
  end;

// *********************************************************************//
// DispIntf:  IDualDocOpenDlg2Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {0C442D30-907E-11D3-80C2-00C04F610E35}
// *********************************************************************//
  IDualDocOpenDlg2Disp = dispinterface
    ['{0C442D30-907E-11D3-80C2-00C04F610E35}']
    property ShowContainedDocuments: IDispatch dispid 9;
    property AdvancedOptions: OleVariant dispid 10;
    property Caption: WideString writeonly dispid 11;
    procedure Show(hParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property NRTDMS: IDispatch dispid 4;
    property DocumentList: OleVariant dispid 5;
    property SingleSel: WordBool dispid 6;
    property CommandList: OleVariant dispid 7;
    property CommandSelected: Integer dispid 8;
  end;

// *********************************************************************//
// Interface: IDualDocOpenDlg3
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {11CB3ABB-A56A-11D6-ABF8-00C04F6803D1}
// *********************************************************************//
  IDualDocOpenDlg3 = interface(IDualDocOpenDlg2)
    ['{11CB3ABB-A56A-11D6-ABF8-00C04F6803D1}']
    procedure Set_FilterAppType(const Param1: WideString); safecall;
    property FilterAppType: WideString write Set_FilterAppType;
  end;

// *********************************************************************//
// DispIntf:  IDualDocOpenDlg3Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {11CB3ABB-A56A-11D6-ABF8-00C04F6803D1}
// *********************************************************************//
  IDualDocOpenDlg3Disp = dispinterface
    ['{11CB3ABB-A56A-11D6-ABF8-00C04F6803D1}']
    property FilterAppType: WideString writeonly dispid 12;
    property ShowContainedDocuments: IDispatch dispid 9;
    property AdvancedOptions: OleVariant dispid 10;
    property Caption: WideString writeonly dispid 11;
    procedure Show(hParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property NRTDMS: IDispatch dispid 4;
    property DocumentList: OleVariant dispid 5;
    property SingleSel: WordBool dispid 6;
    property CommandList: OleVariant dispid 7;
    property CommandSelected: Integer dispid 8;
  end;

// *********************************************************************//
// DispIntf:  _IPortableDocOpenDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {59DCE383-01E6-11D4-8152-00C04F610D7A}
// *********************************************************************//
  _IPortableDocOpenDlgEvents = dispinterface
    ['{59DCE383-01E6-11D4-8152-00C04F610D7A}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: IDualBrowseFoldersDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F7DF9A29-4C12-11D3-80B7-00C04F610E35}
// *********************************************************************//
  IDualBrowseFoldersDlg = interface(IDispatch)
    ['{F7DF9A29-4C12-11D3-80B7-00C04F610E35}']
    procedure Show(ParentWnd: Integer); safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    function  Get_NRTDMS: IDispatch; safecall;
    procedure Set_NRTDMS(const pVal: IDispatch); safecall;
    function  Get_Sessions: OleVariant; safecall;
    procedure Set_Sessions(pVal: OleVariant); safecall;
    function  Get_DestinationObject: IDispatch; safecall;
    procedure Set_DestinationObject(const pVal: IDispatch); safecall;
    function  Get_SelectedSession: IDispatch; safecall;
    procedure Set_SelectedSession(const pVal: IDispatch); safecall;
    function  Get_SelectedDatabase: IDispatch; safecall;
    procedure Set_SelectedDatabase(const pVal: IDispatch); safecall;
    function  Get_SelectedFolder: IDispatch; safecall;
    procedure Set_SelectedFolder(const pVal: IDispatch); safecall;
    function  Get_SelectedPath: WideString; safecall;
    procedure Set_SelectedPath(const pVal: WideString); safecall;
    function  Get_ShowSingleDatabase: WordBool; safecall;
    procedure Set_ShowSingleDatabase(pVal: WordBool); safecall;
    function  Get_ShowReadWriteFoldersOnly: WordBool; safecall;
    procedure Set_ShowReadWriteFoldersOnly(pVal: WordBool); safecall;
    function  Get_SelectedPage: IDispatch; safecall;
    procedure Set_SelectedPage(const pVal: IDispatch); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property Sessions: OleVariant read Get_Sessions write Set_Sessions;
    property DestinationObject: IDispatch read Get_DestinationObject write Set_DestinationObject;
    property SelectedSession: IDispatch read Get_SelectedSession write Set_SelectedSession;
    property SelectedDatabase: IDispatch read Get_SelectedDatabase write Set_SelectedDatabase;
    property SelectedFolder: IDispatch read Get_SelectedFolder write Set_SelectedFolder;
    property SelectedPath: WideString read Get_SelectedPath write Set_SelectedPath;
    property ShowSingleDatabase: WordBool read Get_ShowSingleDatabase write Set_ShowSingleDatabase;
    property ShowReadWriteFoldersOnly: WordBool read Get_ShowReadWriteFoldersOnly write Set_ShowReadWriteFoldersOnly;
    property SelectedPage: IDispatch read Get_SelectedPage write Set_SelectedPage;
  end;

// *********************************************************************//
// DispIntf:  IDualBrowseFoldersDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F7DF9A29-4C12-11D3-80B7-00C04F610E35}
// *********************************************************************//
  IDualBrowseFoldersDlgDisp = dispinterface
    ['{F7DF9A29-4C12-11D3-80B7-00C04F610E35}']
    procedure Show(ParentWnd: Integer); dispid 1;
    property CloseOnOK: WordBool dispid 2;
    property NRTDMS: IDispatch dispid 3;
    property Sessions: OleVariant dispid 4;
    property DestinationObject: IDispatch dispid 5;
    property SelectedSession: IDispatch dispid 6;
    property SelectedDatabase: IDispatch dispid 7;
    property SelectedFolder: IDispatch dispid 8;
    property SelectedPath: WideString dispid 9;
    property ShowSingleDatabase: WordBool dispid 10;
    property ShowReadWriteFoldersOnly: WordBool dispid 11;
    property SelectedPage: IDispatch dispid 12;
  end;

// *********************************************************************//
// DispIntf:  _IBrowseFoldersDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {F7DF9A28-4C12-11D3-80B7-00C04F610E35}
// *********************************************************************//
  _IBrowseFoldersDlgEvents = dispinterface
    ['{F7DF9A28-4C12-11D3-80B7-00C04F610E35}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: IDualFavoritesDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3B4C3022-203A-41A0-9069-2FCB60737B82}
// *********************************************************************//
  IDualFavoritesDlg = interface(IDispatch)
    ['{3B4C3022-203A-41A0-9069-2FCB60737B82}']
    procedure Show(ParentWnd: Integer); safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    function  Get_IManDMS: IDispatch; safecall;
    procedure Set_IManDMS(const pVal: IDispatch); safecall;
    function  Get_SelectedFolder: IDispatch; safecall;
    procedure Set_SelectedFolder(const pVal: IDispatch); safecall;
    function  Get_SelectedPath: WideString; safecall;
    procedure Set_SelectedPath(const pVal: WideString); safecall;
    function  Get_ShowReadWriteFoldersOnly: WordBool; safecall;
    procedure Set_ShowReadWriteFoldersOnly(pVal: WordBool); safecall;
    function  Get_FavoritesName: WideString; safecall;
    procedure Set_FavoritesName(const pVal: WideString); safecall;
    procedure Set_Caption(const Param1: WideString); safecall;
    procedure Set_Message(const Param1: WideString); safecall;
    function  Get_TargetType: Integer; safecall;
    procedure Set_TargetType(pVal: Integer); safecall;
    function  Get_Bitmap: OleVariant; safecall;
    procedure Set_Bitmap(pVal: OleVariant); safecall;
    function  Get_ShowMinimumControls: WordBool; safecall;
    procedure Set_ShowMinimumControls(pVal: WordBool); safecall;
    function  Get_IManSession: IDispatch; safecall;
    procedure Set_IManSession(const pVal: IDispatch); safecall;
    procedure Set_HelpID(Param1: Integer); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property IManDMS: IDispatch read Get_IManDMS write Set_IManDMS;
    property SelectedFolder: IDispatch read Get_SelectedFolder write Set_SelectedFolder;
    property SelectedPath: WideString read Get_SelectedPath write Set_SelectedPath;
    property ShowReadWriteFoldersOnly: WordBool read Get_ShowReadWriteFoldersOnly write Set_ShowReadWriteFoldersOnly;
    property FavoritesName: WideString read Get_FavoritesName write Set_FavoritesName;
    property Caption: WideString write Set_Caption;
    property Message: WideString write Set_Message;
    property TargetType: Integer read Get_TargetType write Set_TargetType;
    property Bitmap: OleVariant read Get_Bitmap write Set_Bitmap;
    property ShowMinimumControls: WordBool read Get_ShowMinimumControls write Set_ShowMinimumControls;
    property IManSession: IDispatch read Get_IManSession write Set_IManSession;
    property HelpID: Integer write Set_HelpID;
  end;

// *********************************************************************//
// DispIntf:  IDualFavoritesDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3B4C3022-203A-41A0-9069-2FCB60737B82}
// *********************************************************************//
  IDualFavoritesDlgDisp = dispinterface
    ['{3B4C3022-203A-41A0-9069-2FCB60737B82}']
    procedure Show(ParentWnd: Integer); dispid 1;
    property CloseOnOK: WordBool dispid 2;
    property IManDMS: IDispatch dispid 3;
    property SelectedFolder: IDispatch dispid 4;
    property SelectedPath: WideString dispid 5;
    property ShowReadWriteFoldersOnly: WordBool dispid 6;
    property FavoritesName: WideString dispid 7;
    property Caption: WideString writeonly dispid 8;
    property Message: WideString writeonly dispid 9;
    property TargetType: Integer dispid 10;
    property Bitmap: OleVariant dispid 11;
    property ShowMinimumControls: WordBool dispid 12;
    property IManSession: IDispatch dispid 13;
    property HelpID: Integer writeonly dispid 14;
  end;

// *********************************************************************//
// DispIntf:  _IFavoritesDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {B3C94199-1A01-4A1E-B7AC-07C160665CE1}
// *********************************************************************//
  _IFavoritesDlgEvents = dispinterface
    ['{B3C94199-1A01-4A1E-B7AC-07C160665CE1}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: IDualOrganizeFavoritesDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2660FC53-4370-4E83-B45C-1516E677A0F0}
// *********************************************************************//
  IDualOrganizeFavoritesDlg = interface(IDispatch)
    ['{2660FC53-4370-4E83-B45C-1516E677A0F0}']
    procedure Show(ParentWnd: Integer); safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    function  Get_NRTDMS: IDispatch; safecall;
    procedure Set_NRTDMS(const pVal: IDispatch); safecall;
    procedure Set_Caption(const Param1: WideString); safecall;
    procedure Set_Message(const Param1: WideString); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property Caption: WideString write Set_Caption;
    property Message: WideString write Set_Message;
  end;

// *********************************************************************//
// DispIntf:  IDualOrganizeFavoritesDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2660FC53-4370-4E83-B45C-1516E677A0F0}
// *********************************************************************//
  IDualOrganizeFavoritesDlgDisp = dispinterface
    ['{2660FC53-4370-4E83-B45C-1516E677A0F0}']
    procedure Show(ParentWnd: Integer); dispid 1;
    property CloseOnOK: WordBool dispid 2;
    property NRTDMS: IDispatch dispid 3;
    property Caption: WideString writeonly dispid 4;
    property Message: WideString writeonly dispid 5;
  end;

// *********************************************************************//
// DispIntf:  _IOrganizeFavoritesDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {D56F7FB7-FD12-43D3-896A-31999B727BB9}
// *********************************************************************//
  _IOrganizeFavoritesDlgEvents = dispinterface
    ['{D56F7FB7-FD12-43D3-896A-31999B727BB9}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: IDualAdvancedOptionsDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D813851B-0012-11D4-AAC0-00C04F6803D1}
// *********************************************************************//
  IDualAdvancedOptionsDlg = interface(IDispatch)
    ['{D813851B-0012-11D4-AAC0-00C04F6803D1}']
    procedure Show(ParentWnd: Integer); safecall;
    function  Window: Integer; safecall;
  end;

// *********************************************************************//
// DispIntf:  IDualAdvancedOptionsDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D813851B-0012-11D4-AAC0-00C04F6803D1}
// *********************************************************************//
  IDualAdvancedOptionsDlgDisp = dispinterface
    ['{D813851B-0012-11D4-AAC0-00C04F6803D1}']
    procedure Show(ParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
  end;

// *********************************************************************//
// DispIntf:  _ISaveEmailDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {6A59C0DB-A14E-11D4-B969-00C04F093D23}
// *********************************************************************//
  _ISaveEmailDlgEvents = dispinterface
    ['{6A59C0DB-A14E-11D4-B969-00C04F093D23}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: ISaveEmailDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6A59C0D9-A14E-11D4-B969-00C04F093D23}
// *********************************************************************//
  ISaveEmailDlg = interface(IDispatch)
    ['{6A59C0D9-A14E-11D4-B969-00C04F093D23}']
    procedure Show(hParentWnd: Integer); safecall;
    function  Window: Integer; safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    procedure Set_EnableRelateAttachments(Param1: WordBool); safecall;
    procedure Set_EnableCommonProfile(Param1: WordBool); safecall;
    function  Get_SelectRelateAttachments: WordBool; safecall;
    procedure Set_SelectRelateAttachments(pVal: WordBool); safecall;
    function  Get_SelectCommonProfile: WordBool; safecall;
    procedure Set_SelectCommonProfile(pVal: WordBool); safecall;
    procedure Set_DocumentDescriptionArray(Param1: OleVariant); safecall;
    function  Get_DocumentIndexArray: OleVariant; safecall;
    procedure Set_InitialExpand(Param1: WordBool); safecall;
    procedure Set_NRTDMS(const Param1: IDispatch); safecall;
    function  Get_BaseVersionDocsArray: OleVariant; safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property EnableRelateAttachments: WordBool write Set_EnableRelateAttachments;
    property EnableCommonProfile: WordBool write Set_EnableCommonProfile;
    property SelectRelateAttachments: WordBool read Get_SelectRelateAttachments write Set_SelectRelateAttachments;
    property SelectCommonProfile: WordBool read Get_SelectCommonProfile write Set_SelectCommonProfile;
    property DocumentDescriptionArray: OleVariant write Set_DocumentDescriptionArray;
    property DocumentIndexArray: OleVariant read Get_DocumentIndexArray;
    property InitialExpand: WordBool write Set_InitialExpand;
    property NRTDMS: IDispatch write Set_NRTDMS;
    property BaseVersionDocsArray: OleVariant read Get_BaseVersionDocsArray;
  end;

// *********************************************************************//
// DispIntf:  ISaveEmailDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {6A59C0D9-A14E-11D4-B969-00C04F093D23}
// *********************************************************************//
  ISaveEmailDlgDisp = dispinterface
    ['{6A59C0D9-A14E-11D4-B969-00C04F093D23}']
    procedure Show(hParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property EnableRelateAttachments: WordBool writeonly dispid 4;
    property EnableCommonProfile: WordBool writeonly dispid 5;
    property SelectRelateAttachments: WordBool dispid 6;
    property SelectCommonProfile: WordBool dispid 7;
    property DocumentDescriptionArray: OleVariant writeonly dispid 8;
    property DocumentIndexArray: OleVariant readonly dispid 9;
    property InitialExpand: WordBool writeonly dispid 10;
    property NRTDMS: IDispatch writeonly dispid 11;
    property BaseVersionDocsArray: OleVariant readonly dispid 12;
  end;

// *********************************************************************//
// DispIntf:  _IImportLinksDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {38FFEEB9-FFD0-11D5-BB9A-00C04F610D7A}
// *********************************************************************//
  _IImportLinksDlgEvents = dispinterface
    ['{38FFEEB9-FFD0-11D5-BB9A-00C04F610D7A}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: IImportLinksDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {917932D1-FFCF-11D5-BB9A-00C04F610D7A}
// *********************************************************************//
  IImportLinksDlg = interface(IDispatch)
    ['{917932D1-FFCF-11D5-BB9A-00C04F610D7A}']
    procedure Show(hParentWnd: Integer); safecall;
    function  Window: Integer; safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    procedure Set_EnableRelateLinks(Param1: WordBool); safecall;
    procedure Set_EnableCommonProfile(Param1: WordBool); safecall;
    function  Get_RelateLinks: WordBool; safecall;
    procedure Set_RelateLinks(pVal: WordBool); safecall;
    function  Get_CommonProfile: WordBool; safecall;
    procedure Set_CommonProfile(pVal: WordBool); safecall;
    procedure Set_DocumentDescriptionArray(Param1: OleVariant); safecall;
    function  Get_DocumentIndexArray: OleVariant; safecall;
    procedure Set_InitialExpand(Param1: WordBool); safecall;
    procedure Set_NRTDMS(const Param1: IDispatch); safecall;
    function  Get_BaseVersionDocsArray: OleVariant; safecall;
    function  Get_LatestVersion: WordBool; safecall;
    procedure Set_LatestVersion(pVal: WordBool); safecall;
    procedure Set_Caption(const Param1: WideString); safecall;
    procedure Set_Message(const Param1: WideString); safecall;
    procedure Set_OkButtonCaption(const Param1: WideString); safecall;
    procedure Set_CancelButtonCaption(const Param1: WideString); safecall;
    procedure Set_CommonProfileCaption(const Param1: WideString); safecall;
    procedure Set_LatestVerCaption(const Param1: WideString); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property EnableRelateLinks: WordBool write Set_EnableRelateLinks;
    property EnableCommonProfile: WordBool write Set_EnableCommonProfile;
    property RelateLinks: WordBool read Get_RelateLinks write Set_RelateLinks;
    property CommonProfile: WordBool read Get_CommonProfile write Set_CommonProfile;
    property DocumentDescriptionArray: OleVariant write Set_DocumentDescriptionArray;
    property DocumentIndexArray: OleVariant read Get_DocumentIndexArray;
    property InitialExpand: WordBool write Set_InitialExpand;
    property NRTDMS: IDispatch write Set_NRTDMS;
    property BaseVersionDocsArray: OleVariant read Get_BaseVersionDocsArray;
    property LatestVersion: WordBool read Get_LatestVersion write Set_LatestVersion;
    property Caption: WideString write Set_Caption;
    property Message: WideString write Set_Message;
    property OkButtonCaption: WideString write Set_OkButtonCaption;
    property CancelButtonCaption: WideString write Set_CancelButtonCaption;
    property CommonProfileCaption: WideString write Set_CommonProfileCaption;
    property LatestVerCaption: WideString write Set_LatestVerCaption;
  end;

// *********************************************************************//
// DispIntf:  IImportLinksDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {917932D1-FFCF-11D5-BB9A-00C04F610D7A}
// *********************************************************************//
  IImportLinksDlgDisp = dispinterface
    ['{917932D1-FFCF-11D5-BB9A-00C04F610D7A}']
    procedure Show(hParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property EnableRelateLinks: WordBool writeonly dispid 4;
    property EnableCommonProfile: WordBool writeonly dispid 5;
    property RelateLinks: WordBool dispid 6;
    property CommonProfile: WordBool dispid 7;
    property DocumentDescriptionArray: OleVariant writeonly dispid 8;
    property DocumentIndexArray: OleVariant readonly dispid 9;
    property InitialExpand: WordBool writeonly dispid 10;
    property NRTDMS: IDispatch writeonly dispid 11;
    property BaseVersionDocsArray: OleVariant readonly dispid 12;
    property LatestVersion: WordBool dispid 13;
    property Caption: WideString writeonly dispid 14;
    property Message: WideString writeonly dispid 15;
    property OkButtonCaption: WideString writeonly dispid 16;
    property CancelButtonCaption: WideString writeonly dispid 17;
    property CommonProfileCaption: WideString writeonly dispid 18;
    property LatestVerCaption: WideString writeonly dispid 19;
  end;

// *********************************************************************//
// Interface: IConfigCommonDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FD81CBE9-8A88-11D5-AB6D-00C04F6803D1}
// *********************************************************************//
  IConfigCommonDlg = interface(IDispatch)
    ['{FD81CBE9-8A88-11D5-AB6D-00C04F6803D1}']
    procedure Show(hParentWnd: Integer); safecall;
    function  Window: Integer; safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    function  Get_NRTDMS: IDispatch; safecall;
    procedure Set_NRTDMS(const pVal: IDispatch); safecall;
    function  Get_ContextItems: IDispatch; safecall;
    procedure Set_ContextItems(const pVal: IDispatch); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property ContextItems: IDispatch read Get_ContextItems write Set_ContextItems;
  end;

// *********************************************************************//
// DispIntf:  IConfigCommonDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {FD81CBE9-8A88-11D5-AB6D-00C04F6803D1}
// *********************************************************************//
  IConfigCommonDlgDisp = dispinterface
    ['{FD81CBE9-8A88-11D5-AB6D-00C04F6803D1}']
    procedure Show(hParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property NRTDMS: IDispatch dispid 4;
    property ContextItems: IDispatch dispid 5;
  end;

// *********************************************************************//
// DispIntf:  _IDocListDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {F2D22C07-0AD0-11D6-BBA1-00C04F610D7A}
// *********************************************************************//
  _IDocListDlgEvents = dispinterface
    ['{F2D22C07-0AD0-11D6-BBA1-00C04F610D7A}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// Interface: ITreeViewOptionsDlgObj
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {57457701-A41C-4A3B-B56B-1F6D94C60FCE}
// *********************************************************************//
  ITreeViewOptionsDlgObj = interface(IDispatch)
    ['{57457701-A41C-4A3B-B56B-1F6D94C60FCE}']
    procedure Show(hParentWnd: Integer); safecall;
  end;

// *********************************************************************//
// DispIntf:  ITreeViewOptionsDlgObjDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {57457701-A41C-4A3B-B56B-1F6D94C60FCE}
// *********************************************************************//
  ITreeViewOptionsDlgObjDisp = dispinterface
    ['{57457701-A41C-4A3B-B56B-1F6D94C60FCE}']
    procedure Show(hParentWnd: Integer); dispid 1;
  end;

// *********************************************************************//
// Interface: IDocListDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9C7DA825-0ACD-11D6-BBA1-00C04F610D7A}
// *********************************************************************//
  IDocListDlg = interface(IDispatch)
    ['{9C7DA825-0ACD-11D6-BBA1-00C04F610D7A}']
    procedure Show(hParentWnd: Integer); safecall;
    function  Window: Integer; safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    procedure Set_DocumentList(Param1: OleVariant); safecall;
    function  Get_DocumentSelectedList: OleVariant; safecall;
    procedure Set_Caption(const Param1: WideString); safecall;
    procedure Set_Message(const Param1: WideString); safecall;
    procedure Set_OkButtonCaption(const Param1: WideString); safecall;
    procedure Set_CancelButtonCaption(const Param1: WideString); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property DocumentList: OleVariant write Set_DocumentList;
    property DocumentSelectedList: OleVariant read Get_DocumentSelectedList;
    property Caption: WideString write Set_Caption;
    property Message: WideString write Set_Message;
    property OkButtonCaption: WideString write Set_OkButtonCaption;
    property CancelButtonCaption: WideString write Set_CancelButtonCaption;
  end;

// *********************************************************************//
// DispIntf:  IDocListDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {9C7DA825-0ACD-11D6-BBA1-00C04F610D7A}
// *********************************************************************//
  IDocListDlgDisp = dispinterface
    ['{9C7DA825-0ACD-11D6-BBA1-00C04F610D7A}']
    procedure Show(hParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property DocumentList: OleVariant writeonly dispid 4;
    property DocumentSelectedList: OleVariant readonly dispid 5;
    property Caption: WideString writeonly dispid 6;
    property Message: WideString writeonly dispid 7;
    property OkButtonCaption: WideString writeonly dispid 8;
    property CancelButtonCaption: WideString writeonly dispid 9;
  end;

// *********************************************************************//
// Interface: IAddToFavoritesDlg
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8722388E-D253-43AD-8AF1-47CB7BD12C5E}
// *********************************************************************//
  IAddToFavoritesDlg = interface(IDispatch)
    ['{8722388E-D253-43AD-8AF1-47CB7BD12C5E}']
    procedure Show(hParentWnd: Integer); safecall;
    function  Window: Integer; safecall;
    function  Get_CloseOnOK: WordBool; safecall;
    procedure Set_CloseOnOK(pVal: WordBool); safecall;
    function  Get_NRTDMS: IDispatch; safecall;
    procedure Set_NRTDMS(const pVal: IDispatch); safecall;
    function  Get_ContextItems: IDispatch; safecall;
    procedure Set_ContextItems(const pVal: IDispatch); safecall;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property ContextItems: IDispatch read Get_ContextItems write Set_ContextItems;
  end;

// *********************************************************************//
// DispIntf:  IAddToFavoritesDlgDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {8722388E-D253-43AD-8AF1-47CB7BD12C5E}
// *********************************************************************//
  IAddToFavoritesDlgDisp = dispinterface
    ['{8722388E-D253-43AD-8AF1-47CB7BD12C5E}']
    procedure Show(hParentWnd: Integer); dispid 1;
    function  Window: Integer; dispid 2;
    property CloseOnOK: WordBool dispid 3;
    property NRTDMS: IDispatch dispid 4;
    property ContextItems: IDispatch dispid 5;
  end;

// *********************************************************************//
// DispIntf:  _IAddToFavoritesDlgEvents
// Flags:     (4096) Dispatchable
// GUID:      {85D0B2E5-86CE-49EA-889F-C70B3C3A6128}
// *********************************************************************//
  _IAddToFavoritesDlgEvents = dispinterface
    ['{85D0B2E5-86CE-49EA-889F-C70B3C3A6128}']
    procedure OnOK(const pMyInterface: IDispatch); dispid 1;
    procedure OnCancel(const pMyInterface: IDispatch); dispid 2;
    procedure OnInitDialog(const pMyInterface: IDispatch); dispid 3;
  end;

// *********************************************************************//
// The Class CoDocOpenDlg provides a Create and CreateRemote method to          
// create instances of the default interface IDualDocOpenDlg3 exposed by              
// the CoClass DocOpenDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDocOpenDlg = class
    class function Create: IDualDocOpenDlg3;
    class function CreateRemote(const MachineName: string): IDualDocOpenDlg3;
  end;

  TDocOpenDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TDocOpenDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TDocOpenDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDocOpenDlg
// Help String      : DocOpenDlg Class
// Default Interface: IDualDocOpenDlg3
// Def. Intf. DISP? : No
// Event   Interface: _IDocOpenDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDocOpenDlgProperties= class;
{$ENDIF}
  TDocOpenDlg = class(TOleServer)
  private
    FOnOK: TDocOpenDlgOnOK;
    FOnCancel: TDocOpenDlgOnCancel;
    FOnInitDialog: TDocOpenDlgOnInitDialog;
    FIntf:        IDualDocOpenDlg3;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TDocOpenDlgProperties;
    function      GetServerProperties: TDocOpenDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IDualDocOpenDlg3;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    function  Get_DocumentList: OleVariant;
    procedure Set_DocumentList(pVal: OleVariant);
    function  Get_SingleSel: WordBool;
    procedure Set_SingleSel(pVal: WordBool);
    function  Get_CommandList: OleVariant;
    procedure Set_CommandList(pVal: OleVariant);
    function  Get_CommandSelected: Integer;
    procedure Set_CommandSelected(pVal: Integer);
    function  Get_ShowContainedDocuments: IDispatch;
    procedure Set_ShowContainedDocuments(const pVal: IDispatch);
    function  Get_AdvancedOptions: OleVariant;
    procedure Set_AdvancedOptions(pVal: OleVariant);
    procedure Set_Caption(const Param1: WideString);
    procedure Set_FilterAppType(const Param1: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDualDocOpenDlg3);
    procedure Disconnect; override;
    procedure Show(hParentWnd: Integer);
    function  Window: Integer;
    property  DefaultInterface: IDualDocOpenDlg3 read GetDefaultInterface;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property DocumentList: OleVariant read Get_DocumentList write Set_DocumentList;
    property CommandList: OleVariant read Get_CommandList write Set_CommandList;
    property ShowContainedDocuments: IDispatch read Get_ShowContainedDocuments write Set_ShowContainedDocuments;
    property AdvancedOptions: OleVariant read Get_AdvancedOptions write Set_AdvancedOptions;
    property Caption: WideString write Set_Caption;
    property FilterAppType: WideString write Set_FilterAppType;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SingleSel: WordBool read Get_SingleSel write Set_SingleSel;
    property CommandSelected: Integer read Get_CommandSelected write Set_CommandSelected;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDocOpenDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TDocOpenDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TDocOpenDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TDocOpenDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDocOpenDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDocOpenDlgProperties = class(TPersistent)
  private
    FServer:    TDocOpenDlg;
    function    GetDefaultInterface: IDualDocOpenDlg3;
    constructor Create(AServer: TDocOpenDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    function  Get_DocumentList: OleVariant;
    procedure Set_DocumentList(pVal: OleVariant);
    function  Get_SingleSel: WordBool;
    procedure Set_SingleSel(pVal: WordBool);
    function  Get_CommandList: OleVariant;
    procedure Set_CommandList(pVal: OleVariant);
    function  Get_CommandSelected: Integer;
    procedure Set_CommandSelected(pVal: Integer);
    function  Get_ShowContainedDocuments: IDispatch;
    procedure Set_ShowContainedDocuments(const pVal: IDispatch);
    function  Get_AdvancedOptions: OleVariant;
    procedure Set_AdvancedOptions(pVal: OleVariant);
    procedure Set_Caption(const Param1: WideString);
    procedure Set_FilterAppType(const Param1: WideString);
  public
    property DefaultInterface: IDualDocOpenDlg3 read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SingleSel: WordBool read Get_SingleSel write Set_SingleSel;
    property CommandSelected: Integer read Get_CommandSelected write Set_CommandSelected;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoPortableDocOpenDlg provides a Create and CreateRemote method to          
// create instances of the default interface IPortableDualDocOpenDlg2 exposed by              
// the CoClass PortableDocOpenDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPortableDocOpenDlg = class
    class function Create: IPortableDualDocOpenDlg2;
    class function CreateRemote(const MachineName: string): IPortableDualDocOpenDlg2;
  end;

  TPortableDocOpenDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TPortableDocOpenDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TPortableDocOpenDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TPortableDocOpenDlg
// Help String      : PortableDocOpenDlg Class
// Default Interface: IPortableDualDocOpenDlg2
// Def. Intf. DISP? : No
// Event   Interface: _IPortableDocOpenDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TPortableDocOpenDlgProperties= class;
{$ENDIF}
  TPortableDocOpenDlg = class(TOleServer)
  private
    FOnOK: TPortableDocOpenDlgOnOK;
    FOnCancel: TPortableDocOpenDlgOnCancel;
    FOnInitDialog: TPortableDocOpenDlgOnInitDialog;
    FIntf:        IPortableDualDocOpenDlg2;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TPortableDocOpenDlgProperties;
    function      GetServerProperties: TPortableDocOpenDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IPortableDualDocOpenDlg2;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_PortableSession: IDispatch;
    procedure Set_PortableSession(const pVal: IDispatch);
    function  Get_DocumentList: OleVariant;
    procedure Set_DocumentList(pVal: OleVariant);
    function  Get_SingleSel: WordBool;
    procedure Set_SingleSel(pVal: WordBool);
    function  Get_CommandList: OleVariant;
    procedure Set_CommandList(pVal: OleVariant);
    function  Get_CommandSelected: OleVariant;
    procedure Set_CommandSelected(pVal: OleVariant);
    procedure Set_FilterAppType(const Param1: WideString);
    procedure Set_Caption(const Param1: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IPortableDualDocOpenDlg2);
    procedure Disconnect; override;
    procedure Show(ParentWnd: Integer);
    function  Window: Integer;
    property  DefaultInterface: IPortableDualDocOpenDlg2 read GetDefaultInterface;
    property PortableSession: IDispatch read Get_PortableSession write Set_PortableSession;
    property DocumentList: OleVariant read Get_DocumentList write Set_DocumentList;
    property CommandList: OleVariant read Get_CommandList write Set_CommandList;
    property CommandSelected: OleVariant read Get_CommandSelected write Set_CommandSelected;
    property FilterAppType: WideString write Set_FilterAppType;
    property Caption: WideString write Set_Caption;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SingleSel: WordBool read Get_SingleSel write Set_SingleSel;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TPortableDocOpenDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TPortableDocOpenDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TPortableDocOpenDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TPortableDocOpenDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TPortableDocOpenDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TPortableDocOpenDlgProperties = class(TPersistent)
  private
    FServer:    TPortableDocOpenDlg;
    function    GetDefaultInterface: IPortableDualDocOpenDlg2;
    constructor Create(AServer: TPortableDocOpenDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_PortableSession: IDispatch;
    procedure Set_PortableSession(const pVal: IDispatch);
    function  Get_DocumentList: OleVariant;
    procedure Set_DocumentList(pVal: OleVariant);
    function  Get_SingleSel: WordBool;
    procedure Set_SingleSel(pVal: WordBool);
    function  Get_CommandList: OleVariant;
    procedure Set_CommandList(pVal: OleVariant);
    function  Get_CommandSelected: OleVariant;
    procedure Set_CommandSelected(pVal: OleVariant);
    procedure Set_FilterAppType(const Param1: WideString);
    procedure Set_Caption(const Param1: WideString);
  public
    property DefaultInterface: IPortableDualDocOpenDlg2 read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SingleSel: WordBool read Get_SingleSel write Set_SingleSel;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoBrowseFoldersDlg provides a Create and CreateRemote method to          
// create instances of the default interface IDualBrowseFoldersDlg exposed by              
// the CoClass BrowseFoldersDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoBrowseFoldersDlg = class
    class function Create: IDualBrowseFoldersDlg;
    class function CreateRemote(const MachineName: string): IDualBrowseFoldersDlg;
  end;

  TBrowseFoldersDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TBrowseFoldersDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TBrowseFoldersDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TBrowseFoldersDlg
// Help String      : BrowseFoldersDlg Class
// Default Interface: IDualBrowseFoldersDlg
// Def. Intf. DISP? : No
// Event   Interface: _IBrowseFoldersDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TBrowseFoldersDlgProperties= class;
{$ENDIF}
  TBrowseFoldersDlg = class(TOleServer)
  private
    FOnOK: TBrowseFoldersDlgOnOK;
    FOnCancel: TBrowseFoldersDlgOnCancel;
    FOnInitDialog: TBrowseFoldersDlgOnInitDialog;
    FIntf:        IDualBrowseFoldersDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TBrowseFoldersDlgProperties;
    function      GetServerProperties: TBrowseFoldersDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IDualBrowseFoldersDlg;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    function  Get_Sessions: OleVariant;
    procedure Set_Sessions(pVal: OleVariant);
    function  Get_DestinationObject: IDispatch;
    procedure Set_DestinationObject(const pVal: IDispatch);
    function  Get_SelectedSession: IDispatch;
    procedure Set_SelectedSession(const pVal: IDispatch);
    function  Get_SelectedDatabase: IDispatch;
    procedure Set_SelectedDatabase(const pVal: IDispatch);
    function  Get_SelectedFolder: IDispatch;
    procedure Set_SelectedFolder(const pVal: IDispatch);
    function  Get_SelectedPath: WideString;
    procedure Set_SelectedPath(const pVal: WideString);
    function  Get_ShowSingleDatabase: WordBool;
    procedure Set_ShowSingleDatabase(pVal: WordBool);
    function  Get_ShowReadWriteFoldersOnly: WordBool;
    procedure Set_ShowReadWriteFoldersOnly(pVal: WordBool);
    function  Get_SelectedPage: IDispatch;
    procedure Set_SelectedPage(const pVal: IDispatch);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDualBrowseFoldersDlg);
    procedure Disconnect; override;
    procedure Show(ParentWnd: Integer);
    property  DefaultInterface: IDualBrowseFoldersDlg read GetDefaultInterface;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property Sessions: OleVariant read Get_Sessions write Set_Sessions;
    property DestinationObject: IDispatch read Get_DestinationObject write Set_DestinationObject;
    property SelectedSession: IDispatch read Get_SelectedSession write Set_SelectedSession;
    property SelectedDatabase: IDispatch read Get_SelectedDatabase write Set_SelectedDatabase;
    property SelectedFolder: IDispatch read Get_SelectedFolder write Set_SelectedFolder;
    property SelectedPage: IDispatch read Get_SelectedPage write Set_SelectedPage;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SelectedPath: WideString read Get_SelectedPath write Set_SelectedPath;
    property ShowSingleDatabase: WordBool read Get_ShowSingleDatabase write Set_ShowSingleDatabase;
    property ShowReadWriteFoldersOnly: WordBool read Get_ShowReadWriteFoldersOnly write Set_ShowReadWriteFoldersOnly;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TBrowseFoldersDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TBrowseFoldersDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TBrowseFoldersDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TBrowseFoldersDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TBrowseFoldersDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TBrowseFoldersDlgProperties = class(TPersistent)
  private
    FServer:    TBrowseFoldersDlg;
    function    GetDefaultInterface: IDualBrowseFoldersDlg;
    constructor Create(AServer: TBrowseFoldersDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    function  Get_Sessions: OleVariant;
    procedure Set_Sessions(pVal: OleVariant);
    function  Get_DestinationObject: IDispatch;
    procedure Set_DestinationObject(const pVal: IDispatch);
    function  Get_SelectedSession: IDispatch;
    procedure Set_SelectedSession(const pVal: IDispatch);
    function  Get_SelectedDatabase: IDispatch;
    procedure Set_SelectedDatabase(const pVal: IDispatch);
    function  Get_SelectedFolder: IDispatch;
    procedure Set_SelectedFolder(const pVal: IDispatch);
    function  Get_SelectedPath: WideString;
    procedure Set_SelectedPath(const pVal: WideString);
    function  Get_ShowSingleDatabase: WordBool;
    procedure Set_ShowSingleDatabase(pVal: WordBool);
    function  Get_ShowReadWriteFoldersOnly: WordBool;
    procedure Set_ShowReadWriteFoldersOnly(pVal: WordBool);
    function  Get_SelectedPage: IDispatch;
    procedure Set_SelectedPage(const pVal: IDispatch);
  public
    property DefaultInterface: IDualBrowseFoldersDlg read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SelectedPath: WideString read Get_SelectedPath write Set_SelectedPath;
    property ShowSingleDatabase: WordBool read Get_ShowSingleDatabase write Set_ShowSingleDatabase;
    property ShowReadWriteFoldersOnly: WordBool read Get_ShowReadWriteFoldersOnly write Set_ShowReadWriteFoldersOnly;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoFavoritesDlg provides a Create and CreateRemote method to          
// create instances of the default interface IDualFavoritesDlg exposed by              
// the CoClass FavoritesDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFavoritesDlg = class
    class function Create: IDualFavoritesDlg;
    class function CreateRemote(const MachineName: string): IDualFavoritesDlg;
  end;

  TFavoritesDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TFavoritesDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TFavoritesDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TFavoritesDlg
// Help String      : FavoritesDlg Class
// Default Interface: IDualFavoritesDlg
// Def. Intf. DISP? : No
// Event   Interface: _IFavoritesDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TFavoritesDlgProperties= class;
{$ENDIF}
  TFavoritesDlg = class(TOleServer)
  private
    FOnOK: TFavoritesDlgOnOK;
    FOnCancel: TFavoritesDlgOnCancel;
    FOnInitDialog: TFavoritesDlgOnInitDialog;
    FIntf:        IDualFavoritesDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TFavoritesDlgProperties;
    function      GetServerProperties: TFavoritesDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IDualFavoritesDlg;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_IManDMS: IDispatch;
    procedure Set_IManDMS(const pVal: IDispatch);
    function  Get_SelectedFolder: IDispatch;
    procedure Set_SelectedFolder(const pVal: IDispatch);
    function  Get_SelectedPath: WideString;
    procedure Set_SelectedPath(const pVal: WideString);
    function  Get_ShowReadWriteFoldersOnly: WordBool;
    procedure Set_ShowReadWriteFoldersOnly(pVal: WordBool);
    function  Get_FavoritesName: WideString;
    procedure Set_FavoritesName(const pVal: WideString);
    procedure Set_Caption(const Param1: WideString);
    procedure Set_Message(const Param1: WideString);
    function  Get_TargetType: Integer;
    procedure Set_TargetType(pVal: Integer);
    function  Get_Bitmap: OleVariant;
    procedure Set_Bitmap(pVal: OleVariant);
    function  Get_ShowMinimumControls: WordBool;
    procedure Set_ShowMinimumControls(pVal: WordBool);
    function  Get_IManSession: IDispatch;
    procedure Set_IManSession(const pVal: IDispatch);
    procedure Set_HelpID(Param1: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDualFavoritesDlg);
    procedure Disconnect; override;
    procedure Show(ParentWnd: Integer);
    property  DefaultInterface: IDualFavoritesDlg read GetDefaultInterface;
    property IManDMS: IDispatch read Get_IManDMS write Set_IManDMS;
    property SelectedFolder: IDispatch read Get_SelectedFolder write Set_SelectedFolder;
    property Caption: WideString write Set_Caption;
    property Message: WideString write Set_Message;
    property Bitmap: OleVariant read Get_Bitmap write Set_Bitmap;
    property IManSession: IDispatch read Get_IManSession write Set_IManSession;
    property HelpID: Integer write Set_HelpID;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SelectedPath: WideString read Get_SelectedPath write Set_SelectedPath;
    property ShowReadWriteFoldersOnly: WordBool read Get_ShowReadWriteFoldersOnly write Set_ShowReadWriteFoldersOnly;
    property FavoritesName: WideString read Get_FavoritesName write Set_FavoritesName;
    property TargetType: Integer read Get_TargetType write Set_TargetType;
    property ShowMinimumControls: WordBool read Get_ShowMinimumControls write Set_ShowMinimumControls;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TFavoritesDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TFavoritesDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TFavoritesDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TFavoritesDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TFavoritesDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TFavoritesDlgProperties = class(TPersistent)
  private
    FServer:    TFavoritesDlg;
    function    GetDefaultInterface: IDualFavoritesDlg;
    constructor Create(AServer: TFavoritesDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_IManDMS: IDispatch;
    procedure Set_IManDMS(const pVal: IDispatch);
    function  Get_SelectedFolder: IDispatch;
    procedure Set_SelectedFolder(const pVal: IDispatch);
    function  Get_SelectedPath: WideString;
    procedure Set_SelectedPath(const pVal: WideString);
    function  Get_ShowReadWriteFoldersOnly: WordBool;
    procedure Set_ShowReadWriteFoldersOnly(pVal: WordBool);
    function  Get_FavoritesName: WideString;
    procedure Set_FavoritesName(const pVal: WideString);
    procedure Set_Caption(const Param1: WideString);
    procedure Set_Message(const Param1: WideString);
    function  Get_TargetType: Integer;
    procedure Set_TargetType(pVal: Integer);
    function  Get_Bitmap: OleVariant;
    procedure Set_Bitmap(pVal: OleVariant);
    function  Get_ShowMinimumControls: WordBool;
    procedure Set_ShowMinimumControls(pVal: WordBool);
    function  Get_IManSession: IDispatch;
    procedure Set_IManSession(const pVal: IDispatch);
    procedure Set_HelpID(Param1: Integer);
  public
    property DefaultInterface: IDualFavoritesDlg read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SelectedPath: WideString read Get_SelectedPath write Set_SelectedPath;
    property ShowReadWriteFoldersOnly: WordBool read Get_ShowReadWriteFoldersOnly write Set_ShowReadWriteFoldersOnly;
    property FavoritesName: WideString read Get_FavoritesName write Set_FavoritesName;
    property TargetType: Integer read Get_TargetType write Set_TargetType;
    property ShowMinimumControls: WordBool read Get_ShowMinimumControls write Set_ShowMinimumControls;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoOrganizeFavoritesDlg provides a Create and CreateRemote method to          
// create instances of the default interface IDualOrganizeFavoritesDlg exposed by              
// the CoClass OrganizeFavoritesDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOrganizeFavoritesDlg = class
    class function Create: IDualOrganizeFavoritesDlg;
    class function CreateRemote(const MachineName: string): IDualOrganizeFavoritesDlg;
  end;

  TOrganizeFavoritesDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TOrganizeFavoritesDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TOrganizeFavoritesDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TOrganizeFavoritesDlg
// Help String      : OrganizeFavoritesDlg Class
// Default Interface: IDualOrganizeFavoritesDlg
// Def. Intf. DISP? : No
// Event   Interface: _IOrganizeFavoritesDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TOrganizeFavoritesDlgProperties= class;
{$ENDIF}
  TOrganizeFavoritesDlg = class(TOleServer)
  private
    FOnOK: TOrganizeFavoritesDlgOnOK;
    FOnCancel: TOrganizeFavoritesDlgOnCancel;
    FOnInitDialog: TOrganizeFavoritesDlgOnInitDialog;
    FIntf:        IDualOrganizeFavoritesDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TOrganizeFavoritesDlgProperties;
    function      GetServerProperties: TOrganizeFavoritesDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IDualOrganizeFavoritesDlg;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    procedure Set_Caption(const Param1: WideString);
    procedure Set_Message(const Param1: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDualOrganizeFavoritesDlg);
    procedure Disconnect; override;
    procedure Show(ParentWnd: Integer);
    property  DefaultInterface: IDualOrganizeFavoritesDlg read GetDefaultInterface;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property Caption: WideString write Set_Caption;
    property Message: WideString write Set_Message;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TOrganizeFavoritesDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TOrganizeFavoritesDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TOrganizeFavoritesDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TOrganizeFavoritesDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TOrganizeFavoritesDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TOrganizeFavoritesDlgProperties = class(TPersistent)
  private
    FServer:    TOrganizeFavoritesDlg;
    function    GetDefaultInterface: IDualOrganizeFavoritesDlg;
    constructor Create(AServer: TOrganizeFavoritesDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    procedure Set_Caption(const Param1: WideString);
    procedure Set_Message(const Param1: WideString);
  public
    property DefaultInterface: IDualOrganizeFavoritesDlg read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoAdvancedOptionsDlg provides a Create and CreateRemote method to          
// create instances of the default interface IDualAdvancedOptionsDlg exposed by              
// the CoClass AdvancedOptionsDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAdvancedOptionsDlg = class
    class function Create: IDualAdvancedOptionsDlg;
    class function CreateRemote(const MachineName: string): IDualAdvancedOptionsDlg;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TAdvancedOptionsDlg
// Help String      : AdvancedOptionsDlg Class
// Default Interface: IDualAdvancedOptionsDlg
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TAdvancedOptionsDlgProperties= class;
{$ENDIF}
  TAdvancedOptionsDlg = class(TOleServer)
  private
    FIntf:        IDualAdvancedOptionsDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TAdvancedOptionsDlgProperties;
    function      GetServerProperties: TAdvancedOptionsDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IDualAdvancedOptionsDlg;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDualAdvancedOptionsDlg);
    procedure Disconnect; override;
    procedure Show(ParentWnd: Integer);
    function  Window: Integer;
    property  DefaultInterface: IDualAdvancedOptionsDlg read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TAdvancedOptionsDlgProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TAdvancedOptionsDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TAdvancedOptionsDlgProperties = class(TPersistent)
  private
    FServer:    TAdvancedOptionsDlg;
    function    GetDefaultInterface: IDualAdvancedOptionsDlg;
    constructor Create(AServer: TAdvancedOptionsDlg);
  protected
  public
    property DefaultInterface: IDualAdvancedOptionsDlg read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoSaveEmailDlg provides a Create and CreateRemote method to          
// create instances of the default interface ISaveEmailDlg exposed by              
// the CoClass SaveEmailDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoSaveEmailDlg = class
    class function Create: ISaveEmailDlg;
    class function CreateRemote(const MachineName: string): ISaveEmailDlg;
  end;

  TSaveEmailDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TSaveEmailDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TSaveEmailDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TSaveEmailDlg
// Help String      : SaveEmailDlg Class
// Default Interface: ISaveEmailDlg
// Def. Intf. DISP? : No
// Event   Interface: _ISaveEmailDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TSaveEmailDlgProperties= class;
{$ENDIF}
  TSaveEmailDlg = class(TOleServer)
  private
    FOnOK: TSaveEmailDlgOnOK;
    FOnCancel: TSaveEmailDlgOnCancel;
    FOnInitDialog: TSaveEmailDlgOnInitDialog;
    FIntf:        ISaveEmailDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TSaveEmailDlgProperties;
    function      GetServerProperties: TSaveEmailDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: ISaveEmailDlg;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    procedure Set_EnableRelateAttachments(Param1: WordBool);
    procedure Set_EnableCommonProfile(Param1: WordBool);
    function  Get_SelectRelateAttachments: WordBool;
    procedure Set_SelectRelateAttachments(pVal: WordBool);
    function  Get_SelectCommonProfile: WordBool;
    procedure Set_SelectCommonProfile(pVal: WordBool);
    procedure Set_DocumentDescriptionArray(Param1: OleVariant);
    function  Get_DocumentIndexArray: OleVariant;
    procedure Set_InitialExpand(Param1: WordBool);
    procedure Set_NRTDMS(const Param1: IDispatch);
    function  Get_BaseVersionDocsArray: OleVariant;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: ISaveEmailDlg);
    procedure Disconnect; override;
    procedure Show(hParentWnd: Integer);
    function  Window: Integer;
    property  DefaultInterface: ISaveEmailDlg read GetDefaultInterface;
    property EnableRelateAttachments: WordBool write Set_EnableRelateAttachments;
    property EnableCommonProfile: WordBool write Set_EnableCommonProfile;
    property DocumentDescriptionArray: OleVariant write Set_DocumentDescriptionArray;
    property DocumentIndexArray: OleVariant read Get_DocumentIndexArray;
    property InitialExpand: WordBool write Set_InitialExpand;
    property NRTDMS: IDispatch write Set_NRTDMS;
    property BaseVersionDocsArray: OleVariant read Get_BaseVersionDocsArray;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SelectRelateAttachments: WordBool read Get_SelectRelateAttachments write Set_SelectRelateAttachments;
    property SelectCommonProfile: WordBool read Get_SelectCommonProfile write Set_SelectCommonProfile;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TSaveEmailDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TSaveEmailDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TSaveEmailDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TSaveEmailDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TSaveEmailDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TSaveEmailDlgProperties = class(TPersistent)
  private
    FServer:    TSaveEmailDlg;
    function    GetDefaultInterface: ISaveEmailDlg;
    constructor Create(AServer: TSaveEmailDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    procedure Set_EnableRelateAttachments(Param1: WordBool);
    procedure Set_EnableCommonProfile(Param1: WordBool);
    function  Get_SelectRelateAttachments: WordBool;
    procedure Set_SelectRelateAttachments(pVal: WordBool);
    function  Get_SelectCommonProfile: WordBool;
    procedure Set_SelectCommonProfile(pVal: WordBool);
    procedure Set_DocumentDescriptionArray(Param1: OleVariant);
    function  Get_DocumentIndexArray: OleVariant;
    procedure Set_InitialExpand(Param1: WordBool);
    procedure Set_NRTDMS(const Param1: IDispatch);
    function  Get_BaseVersionDocsArray: OleVariant;
  public
    property DefaultInterface: ISaveEmailDlg read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property SelectRelateAttachments: WordBool read Get_SelectRelateAttachments write Set_SelectRelateAttachments;
    property SelectCommonProfile: WordBool read Get_SelectCommonProfile write Set_SelectCommonProfile;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoImportLinksDlg provides a Create and CreateRemote method to          
// create instances of the default interface IImportLinksDlg exposed by              
// the CoClass ImportLinksDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoImportLinksDlg = class
    class function Create: IImportLinksDlg;
    class function CreateRemote(const MachineName: string): IImportLinksDlg;
  end;

  TImportLinksDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TImportLinksDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TImportLinksDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TImportLinksDlg
// Help String      : ImportLinksDlg Class
// Default Interface: IImportLinksDlg
// Def. Intf. DISP? : No
// Event   Interface: _IImportLinksDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TImportLinksDlgProperties= class;
{$ENDIF}
  TImportLinksDlg = class(TOleServer)
  private
    FOnOK: TImportLinksDlgOnOK;
    FOnCancel: TImportLinksDlgOnCancel;
    FOnInitDialog: TImportLinksDlgOnInitDialog;
    FIntf:        IImportLinksDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TImportLinksDlgProperties;
    function      GetServerProperties: TImportLinksDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IImportLinksDlg;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    procedure Set_EnableRelateLinks(Param1: WordBool);
    procedure Set_EnableCommonProfile(Param1: WordBool);
    function  Get_RelateLinks: WordBool;
    procedure Set_RelateLinks(pVal: WordBool);
    function  Get_CommonProfile: WordBool;
    procedure Set_CommonProfile(pVal: WordBool);
    procedure Set_DocumentDescriptionArray(Param1: OleVariant);
    function  Get_DocumentIndexArray: OleVariant;
    procedure Set_InitialExpand(Param1: WordBool);
    procedure Set_NRTDMS(const Param1: IDispatch);
    function  Get_BaseVersionDocsArray: OleVariant;
    function  Get_LatestVersion: WordBool;
    procedure Set_LatestVersion(pVal: WordBool);
    procedure Set_Caption(const Param1: WideString);
    procedure Set_Message(const Param1: WideString);
    procedure Set_OkButtonCaption(const Param1: WideString);
    procedure Set_CancelButtonCaption(const Param1: WideString);
    procedure Set_CommonProfileCaption(const Param1: WideString);
    procedure Set_LatestVerCaption(const Param1: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IImportLinksDlg);
    procedure Disconnect; override;
    procedure Show(hParentWnd: Integer);
    function  Window: Integer;
    property  DefaultInterface: IImportLinksDlg read GetDefaultInterface;
    property EnableRelateLinks: WordBool write Set_EnableRelateLinks;
    property EnableCommonProfile: WordBool write Set_EnableCommonProfile;
    property DocumentDescriptionArray: OleVariant write Set_DocumentDescriptionArray;
    property DocumentIndexArray: OleVariant read Get_DocumentIndexArray;
    property InitialExpand: WordBool write Set_InitialExpand;
    property NRTDMS: IDispatch write Set_NRTDMS;
    property BaseVersionDocsArray: OleVariant read Get_BaseVersionDocsArray;
    property Caption: WideString write Set_Caption;
    property Message: WideString write Set_Message;
    property OkButtonCaption: WideString write Set_OkButtonCaption;
    property CancelButtonCaption: WideString write Set_CancelButtonCaption;
    property CommonProfileCaption: WideString write Set_CommonProfileCaption;
    property LatestVerCaption: WideString write Set_LatestVerCaption;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property RelateLinks: WordBool read Get_RelateLinks write Set_RelateLinks;
    property CommonProfile: WordBool read Get_CommonProfile write Set_CommonProfile;
    property LatestVersion: WordBool read Get_LatestVersion write Set_LatestVersion;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TImportLinksDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TImportLinksDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TImportLinksDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TImportLinksDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TImportLinksDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TImportLinksDlgProperties = class(TPersistent)
  private
    FServer:    TImportLinksDlg;
    function    GetDefaultInterface: IImportLinksDlg;
    constructor Create(AServer: TImportLinksDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    procedure Set_EnableRelateLinks(Param1: WordBool);
    procedure Set_EnableCommonProfile(Param1: WordBool);
    function  Get_RelateLinks: WordBool;
    procedure Set_RelateLinks(pVal: WordBool);
    function  Get_CommonProfile: WordBool;
    procedure Set_CommonProfile(pVal: WordBool);
    procedure Set_DocumentDescriptionArray(Param1: OleVariant);
    function  Get_DocumentIndexArray: OleVariant;
    procedure Set_InitialExpand(Param1: WordBool);
    procedure Set_NRTDMS(const Param1: IDispatch);
    function  Get_BaseVersionDocsArray: OleVariant;
    function  Get_LatestVersion: WordBool;
    procedure Set_LatestVersion(pVal: WordBool);
    procedure Set_Caption(const Param1: WideString);
    procedure Set_Message(const Param1: WideString);
    procedure Set_OkButtonCaption(const Param1: WideString);
    procedure Set_CancelButtonCaption(const Param1: WideString);
    procedure Set_CommonProfileCaption(const Param1: WideString);
    procedure Set_LatestVerCaption(const Param1: WideString);
  public
    property DefaultInterface: IImportLinksDlg read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
    property RelateLinks: WordBool read Get_RelateLinks write Set_RelateLinks;
    property CommonProfile: WordBool read Get_CommonProfile write Set_CommonProfile;
    property LatestVersion: WordBool read Get_LatestVersion write Set_LatestVersion;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoConfigCommonDlg provides a Create and CreateRemote method to          
// create instances of the default interface IConfigCommonDlg exposed by              
// the CoClass ConfigCommonDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoConfigCommonDlg = class
    class function Create: IConfigCommonDlg;
    class function CreateRemote(const MachineName: string): IConfigCommonDlg;
  end;

  TConfigCommonDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TConfigCommonDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TConfigCommonDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TConfigCommonDlg
// Help String      : ConfigCommonDlg Class
// Default Interface: IConfigCommonDlg
// Def. Intf. DISP? : No
// Event   Interface: _IConfigCommonDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TConfigCommonDlgProperties= class;
{$ENDIF}
  TConfigCommonDlg = class(TOleServer)
  private
    FOnOK: TConfigCommonDlgOnOK;
    FOnCancel: TConfigCommonDlgOnCancel;
    FOnInitDialog: TConfigCommonDlgOnInitDialog;
    FIntf:        IConfigCommonDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TConfigCommonDlgProperties;
    function      GetServerProperties: TConfigCommonDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IConfigCommonDlg;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    function  Get_ContextItems: IDispatch;
    procedure Set_ContextItems(const pVal: IDispatch);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IConfigCommonDlg);
    procedure Disconnect; override;
    procedure Show(hParentWnd: Integer);
    function  Window: Integer;
    property  DefaultInterface: IConfigCommonDlg read GetDefaultInterface;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property ContextItems: IDispatch read Get_ContextItems write Set_ContextItems;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TConfigCommonDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TConfigCommonDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TConfigCommonDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TConfigCommonDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TConfigCommonDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TConfigCommonDlgProperties = class(TPersistent)
  private
    FServer:    TConfigCommonDlg;
    function    GetDefaultInterface: IConfigCommonDlg;
    constructor Create(AServer: TConfigCommonDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    function  Get_ContextItems: IDispatch;
    procedure Set_ContextItems(const pVal: IDispatch);
  public
    property DefaultInterface: IConfigCommonDlg read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoDocListDlg provides a Create and CreateRemote method to          
// create instances of the default interface IDocListDlg exposed by              
// the CoClass DocListDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoDocListDlg = class
    class function Create: IDocListDlg;
    class function CreateRemote(const MachineName: string): IDocListDlg;
  end;

  TDocListDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TDocListDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TDocListDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TDocListDlg
// Help String      : DocListDlg Class
// Default Interface: IDocListDlg
// Def. Intf. DISP? : No
// Event   Interface: _IDocListDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TDocListDlgProperties= class;
{$ENDIF}
  TDocListDlg = class(TOleServer)
  private
    FOnOK: TDocListDlgOnOK;
    FOnCancel: TDocListDlgOnCancel;
    FOnInitDialog: TDocListDlgOnInitDialog;
    FIntf:        IDocListDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TDocListDlgProperties;
    function      GetServerProperties: TDocListDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IDocListDlg;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    procedure Set_DocumentList(Param1: OleVariant);
    function  Get_DocumentSelectedList: OleVariant;
    procedure Set_Caption(const Param1: WideString);
    procedure Set_Message(const Param1: WideString);
    procedure Set_OkButtonCaption(const Param1: WideString);
    procedure Set_CancelButtonCaption(const Param1: WideString);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IDocListDlg);
    procedure Disconnect; override;
    procedure Show(hParentWnd: Integer);
    function  Window: Integer;
    property  DefaultInterface: IDocListDlg read GetDefaultInterface;
    property DocumentList: OleVariant write Set_DocumentList;
    property DocumentSelectedList: OleVariant read Get_DocumentSelectedList;
    property Caption: WideString write Set_Caption;
    property Message: WideString write Set_Message;
    property OkButtonCaption: WideString write Set_OkButtonCaption;
    property CancelButtonCaption: WideString write Set_CancelButtonCaption;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TDocListDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TDocListDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TDocListDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TDocListDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TDocListDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TDocListDlgProperties = class(TPersistent)
  private
    FServer:    TDocListDlg;
    function    GetDefaultInterface: IDocListDlg;
    constructor Create(AServer: TDocListDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    procedure Set_DocumentList(Param1: OleVariant);
    function  Get_DocumentSelectedList: OleVariant;
    procedure Set_Caption(const Param1: WideString);
    procedure Set_Message(const Param1: WideString);
    procedure Set_OkButtonCaption(const Param1: WideString);
    procedure Set_CancelButtonCaption(const Param1: WideString);
  public
    property DefaultInterface: IDocListDlg read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoAddToFavoritesDlg provides a Create and CreateRemote method to          
// create instances of the default interface IAddToFavoritesDlg exposed by              
// the CoClass AddToFavoritesDlg. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoAddToFavoritesDlg = class
    class function Create: IAddToFavoritesDlg;
    class function CreateRemote(const MachineName: string): IAddToFavoritesDlg;
  end;

  TAddToFavoritesDlgOnOK = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TAddToFavoritesDlgOnCancel = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;
  TAddToFavoritesDlgOnInitDialog = procedure(Sender: TObject; var pMyInterface: OleVariant) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TAddToFavoritesDlg
// Help String      : AddToFavoritesDlg Class
// Default Interface: IAddToFavoritesDlg
// Def. Intf. DISP? : No
// Event   Interface: _IAddToFavoritesDlgEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TAddToFavoritesDlgProperties= class;
{$ENDIF}
  TAddToFavoritesDlg = class(TOleServer)
  private
    FOnOK: TAddToFavoritesDlgOnOK;
    FOnCancel: TAddToFavoritesDlgOnCancel;
    FOnInitDialog: TAddToFavoritesDlgOnInitDialog;
    FIntf:        IAddToFavoritesDlg;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TAddToFavoritesDlgProperties;
    function      GetServerProperties: TAddToFavoritesDlgProperties;
{$ENDIF}
    function      GetDefaultInterface: IAddToFavoritesDlg;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    function  Get_ContextItems: IDispatch;
    procedure Set_ContextItems(const pVal: IDispatch);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IAddToFavoritesDlg);
    procedure Disconnect; override;
    procedure Show(hParentWnd: Integer);
    function  Window: Integer;
    property  DefaultInterface: IAddToFavoritesDlg read GetDefaultInterface;
    property NRTDMS: IDispatch read Get_NRTDMS write Set_NRTDMS;
    property ContextItems: IDispatch read Get_ContextItems write Set_ContextItems;
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TAddToFavoritesDlgProperties read GetServerProperties;
{$ENDIF}
    property OnOK: TAddToFavoritesDlgOnOK read FOnOK write FOnOK;
    property OnCancel: TAddToFavoritesDlgOnCancel read FOnCancel write FOnCancel;
    property OnInitDialog: TAddToFavoritesDlgOnInitDialog read FOnInitDialog write FOnInitDialog;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TAddToFavoritesDlg
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TAddToFavoritesDlgProperties = class(TPersistent)
  private
    FServer:    TAddToFavoritesDlg;
    function    GetDefaultInterface: IAddToFavoritesDlg;
    constructor Create(AServer: TAddToFavoritesDlg);
  protected
    function  Get_CloseOnOK: WordBool;
    procedure Set_CloseOnOK(pVal: WordBool);
    function  Get_NRTDMS: IDispatch;
    procedure Set_NRTDMS(const pVal: IDispatch);
    function  Get_ContextItems: IDispatch;
    procedure Set_ContextItems(const pVal: IDispatch);
  public
    property DefaultInterface: IAddToFavoritesDlg read GetDefaultInterface;
  published
    property CloseOnOK: WordBool read Get_CloseOnOK write Set_CloseOnOK;
  end;
{$ENDIF}


procedure Register;

implementation

uses ComObj;

class function CoDocOpenDlg.Create: IDualDocOpenDlg3;
begin
  Result := CreateComObject(CLASS_DocOpenDlg) as IDualDocOpenDlg3;
end;

class function CoDocOpenDlg.CreateRemote(const MachineName: string): IDualDocOpenDlg3;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DocOpenDlg) as IDualDocOpenDlg3;
end;

procedure TDocOpenDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{60C28083-6218-11D2-9051-00A0C975AA49}';
    IntfIID:   '{11CB3ABB-A56A-11D6-ABF8-00C04F6803D1}';
    EventIID:  '{C92637A0-F802-11D2-8150-00C04F81E113}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDocOpenDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IDualDocOpenDlg3;
  end;
end;

procedure TDocOpenDlg.ConnectTo(svrIntf: IDualDocOpenDlg3);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TDocOpenDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TDocOpenDlg.GetDefaultInterface: IDualDocOpenDlg3;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TDocOpenDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDocOpenDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TDocOpenDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDocOpenDlg.GetServerProperties: TDocOpenDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TDocOpenDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TDocOpenDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TDocOpenDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TDocOpenDlg.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TDocOpenDlg.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

function  TDocOpenDlg.Get_DocumentList: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentList;
end;

procedure TDocOpenDlg.Set_DocumentList(pVal: OleVariant);
begin
  DefaultInterface.Set_DocumentList(pVal);
end;

function  TDocOpenDlg.Get_SingleSel: WordBool;
begin
  Result := DefaultInterface.Get_SingleSel;
end;

procedure TDocOpenDlg.Set_SingleSel(pVal: WordBool);
begin
  DefaultInterface.Set_SingleSel(pVal);
end;

function  TDocOpenDlg.Get_CommandList: OleVariant;
begin
  Result := DefaultInterface.Get_CommandList;
end;

procedure TDocOpenDlg.Set_CommandList(pVal: OleVariant);
begin
  DefaultInterface.Set_CommandList(pVal);
end;

function  TDocOpenDlg.Get_CommandSelected: Integer;
begin
  Result := DefaultInterface.Get_CommandSelected;
end;

procedure TDocOpenDlg.Set_CommandSelected(pVal: Integer);
begin
  DefaultInterface.Set_CommandSelected(pVal);
end;

function  TDocOpenDlg.Get_ShowContainedDocuments: IDispatch;
begin
  Result := DefaultInterface.Get_ShowContainedDocuments;
end;

procedure TDocOpenDlg.Set_ShowContainedDocuments(const pVal: IDispatch);
begin
  DefaultInterface.Set_ShowContainedDocuments(pVal);
end;

function  TDocOpenDlg.Get_AdvancedOptions: OleVariant;
begin
  Result := DefaultInterface.Get_AdvancedOptions;
end;

procedure TDocOpenDlg.Set_AdvancedOptions(pVal: OleVariant);
begin
  DefaultInterface.Set_AdvancedOptions(pVal);
end;

procedure TDocOpenDlg.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TDocOpenDlg.Set_FilterAppType(const Param1: WideString);
begin
  DefaultInterface.Set_FilterAppType(Param1);
end;

procedure TDocOpenDlg.Show(hParentWnd: Integer);
begin
  DefaultInterface.Show(hParentWnd);
end;

function  TDocOpenDlg.Window: Integer;
begin
  Result := DefaultInterface.Window;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDocOpenDlgProperties.Create(AServer: TDocOpenDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TDocOpenDlgProperties.GetDefaultInterface: IDualDocOpenDlg3;
begin
  Result := FServer.DefaultInterface;
end;

function  TDocOpenDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TDocOpenDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TDocOpenDlgProperties.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TDocOpenDlgProperties.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

function  TDocOpenDlgProperties.Get_DocumentList: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentList;
end;

procedure TDocOpenDlgProperties.Set_DocumentList(pVal: OleVariant);
begin
  DefaultInterface.Set_DocumentList(pVal);
end;

function  TDocOpenDlgProperties.Get_SingleSel: WordBool;
begin
  Result := DefaultInterface.Get_SingleSel;
end;

procedure TDocOpenDlgProperties.Set_SingleSel(pVal: WordBool);
begin
  DefaultInterface.Set_SingleSel(pVal);
end;

function  TDocOpenDlgProperties.Get_CommandList: OleVariant;
begin
  Result := DefaultInterface.Get_CommandList;
end;

procedure TDocOpenDlgProperties.Set_CommandList(pVal: OleVariant);
begin
  DefaultInterface.Set_CommandList(pVal);
end;

function  TDocOpenDlgProperties.Get_CommandSelected: Integer;
begin
  Result := DefaultInterface.Get_CommandSelected;
end;

procedure TDocOpenDlgProperties.Set_CommandSelected(pVal: Integer);
begin
  DefaultInterface.Set_CommandSelected(pVal);
end;

function  TDocOpenDlgProperties.Get_ShowContainedDocuments: IDispatch;
begin
  Result := DefaultInterface.Get_ShowContainedDocuments;
end;

procedure TDocOpenDlgProperties.Set_ShowContainedDocuments(const pVal: IDispatch);
begin
  DefaultInterface.Set_ShowContainedDocuments(pVal);
end;

function  TDocOpenDlgProperties.Get_AdvancedOptions: OleVariant;
begin
  Result := DefaultInterface.Get_AdvancedOptions;
end;

procedure TDocOpenDlgProperties.Set_AdvancedOptions(pVal: OleVariant);
begin
  DefaultInterface.Set_AdvancedOptions(pVal);
end;

procedure TDocOpenDlgProperties.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TDocOpenDlgProperties.Set_FilterAppType(const Param1: WideString);
begin
  DefaultInterface.Set_FilterAppType(Param1);
end;

{$ENDIF}

class function CoPortableDocOpenDlg.Create: IPortableDualDocOpenDlg2;
begin
  Result := CreateComObject(CLASS_PortableDocOpenDlg) as IPortableDualDocOpenDlg2;
end;

class function CoPortableDocOpenDlg.CreateRemote(const MachineName: string): IPortableDualDocOpenDlg2;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PortableDocOpenDlg) as IPortableDualDocOpenDlg2;
end;

procedure TPortableDocOpenDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{26CC9577-C84C-11D2-8314-00A0C932328D}';
    IntfIID:   '{5C079309-A56A-11D6-ABF8-00C04F6803D1}';
    EventIID:  '{59DCE383-01E6-11D4-8152-00C04F610D7A}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TPortableDocOpenDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IPortableDualDocOpenDlg2;
  end;
end;

procedure TPortableDocOpenDlg.ConnectTo(svrIntf: IPortableDualDocOpenDlg2);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TPortableDocOpenDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TPortableDocOpenDlg.GetDefaultInterface: IPortableDualDocOpenDlg2;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TPortableDocOpenDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TPortableDocOpenDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TPortableDocOpenDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TPortableDocOpenDlg.GetServerProperties: TPortableDocOpenDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TPortableDocOpenDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TPortableDocOpenDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TPortableDocOpenDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TPortableDocOpenDlg.Get_PortableSession: IDispatch;
begin
  Result := DefaultInterface.Get_PortableSession;
end;

procedure TPortableDocOpenDlg.Set_PortableSession(const pVal: IDispatch);
begin
  DefaultInterface.Set_PortableSession(pVal);
end;

function  TPortableDocOpenDlg.Get_DocumentList: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentList;
end;

procedure TPortableDocOpenDlg.Set_DocumentList(pVal: OleVariant);
begin
  DefaultInterface.Set_DocumentList(pVal);
end;

function  TPortableDocOpenDlg.Get_SingleSel: WordBool;
begin
  Result := DefaultInterface.Get_SingleSel;
end;

procedure TPortableDocOpenDlg.Set_SingleSel(pVal: WordBool);
begin
  DefaultInterface.Set_SingleSel(pVal);
end;

function  TPortableDocOpenDlg.Get_CommandList: OleVariant;
begin
  Result := DefaultInterface.Get_CommandList;
end;

procedure TPortableDocOpenDlg.Set_CommandList(pVal: OleVariant);
begin
  DefaultInterface.Set_CommandList(pVal);
end;

function  TPortableDocOpenDlg.Get_CommandSelected: OleVariant;
begin
  Result := DefaultInterface.Get_CommandSelected;
end;

procedure TPortableDocOpenDlg.Set_CommandSelected(pVal: OleVariant);
begin
  DefaultInterface.Set_CommandSelected(pVal);
end;

procedure TPortableDocOpenDlg.Set_FilterAppType(const Param1: WideString);
begin
  DefaultInterface.Set_FilterAppType(Param1);
end;

procedure TPortableDocOpenDlg.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TPortableDocOpenDlg.Show(ParentWnd: Integer);
begin
  DefaultInterface.Show(ParentWnd);
end;

function  TPortableDocOpenDlg.Window: Integer;
begin
  Result := DefaultInterface.Window;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TPortableDocOpenDlgProperties.Create(AServer: TPortableDocOpenDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TPortableDocOpenDlgProperties.GetDefaultInterface: IPortableDualDocOpenDlg2;
begin
  Result := FServer.DefaultInterface;
end;

function  TPortableDocOpenDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TPortableDocOpenDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TPortableDocOpenDlgProperties.Get_PortableSession: IDispatch;
begin
  Result := DefaultInterface.Get_PortableSession;
end;

procedure TPortableDocOpenDlgProperties.Set_PortableSession(const pVal: IDispatch);
begin
  DefaultInterface.Set_PortableSession(pVal);
end;

function  TPortableDocOpenDlgProperties.Get_DocumentList: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentList;
end;

procedure TPortableDocOpenDlgProperties.Set_DocumentList(pVal: OleVariant);
begin
  DefaultInterface.Set_DocumentList(pVal);
end;

function  TPortableDocOpenDlgProperties.Get_SingleSel: WordBool;
begin
  Result := DefaultInterface.Get_SingleSel;
end;

procedure TPortableDocOpenDlgProperties.Set_SingleSel(pVal: WordBool);
begin
  DefaultInterface.Set_SingleSel(pVal);
end;

function  TPortableDocOpenDlgProperties.Get_CommandList: OleVariant;
begin
  Result := DefaultInterface.Get_CommandList;
end;

procedure TPortableDocOpenDlgProperties.Set_CommandList(pVal: OleVariant);
begin
  DefaultInterface.Set_CommandList(pVal);
end;

function  TPortableDocOpenDlgProperties.Get_CommandSelected: OleVariant;
begin
  Result := DefaultInterface.Get_CommandSelected;
end;

procedure TPortableDocOpenDlgProperties.Set_CommandSelected(pVal: OleVariant);
begin
  DefaultInterface.Set_CommandSelected(pVal);
end;

procedure TPortableDocOpenDlgProperties.Set_FilterAppType(const Param1: WideString);
begin
  DefaultInterface.Set_FilterAppType(Param1);
end;

procedure TPortableDocOpenDlgProperties.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

{$ENDIF}

class function CoBrowseFoldersDlg.Create: IDualBrowseFoldersDlg;
begin
  Result := CreateComObject(CLASS_BrowseFoldersDlg) as IDualBrowseFoldersDlg;
end;

class function CoBrowseFoldersDlg.CreateRemote(const MachineName: string): IDualBrowseFoldersDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_BrowseFoldersDlg) as IDualBrowseFoldersDlg;
end;

procedure TBrowseFoldersDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{510387DA-4B8F-11D3-80B7-00C04F610E35}';
    IntfIID:   '{F7DF9A29-4C12-11D3-80B7-00C04F610E35}';
    EventIID:  '{F7DF9A28-4C12-11D3-80B7-00C04F610E35}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TBrowseFoldersDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IDualBrowseFoldersDlg;
  end;
end;

procedure TBrowseFoldersDlg.ConnectTo(svrIntf: IDualBrowseFoldersDlg);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TBrowseFoldersDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TBrowseFoldersDlg.GetDefaultInterface: IDualBrowseFoldersDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TBrowseFoldersDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TBrowseFoldersDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TBrowseFoldersDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TBrowseFoldersDlg.GetServerProperties: TBrowseFoldersDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TBrowseFoldersDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TBrowseFoldersDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TBrowseFoldersDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TBrowseFoldersDlg.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TBrowseFoldersDlg.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

function  TBrowseFoldersDlg.Get_Sessions: OleVariant;
begin
  Result := DefaultInterface.Get_Sessions;
end;

procedure TBrowseFoldersDlg.Set_Sessions(pVal: OleVariant);
begin
  DefaultInterface.Set_Sessions(pVal);
end;

function  TBrowseFoldersDlg.Get_DestinationObject: IDispatch;
begin
  Result := DefaultInterface.Get_DestinationObject;
end;

procedure TBrowseFoldersDlg.Set_DestinationObject(const pVal: IDispatch);
begin
  DefaultInterface.Set_DestinationObject(pVal);
end;

function  TBrowseFoldersDlg.Get_SelectedSession: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedSession;
end;

procedure TBrowseFoldersDlg.Set_SelectedSession(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedSession(pVal);
end;

function  TBrowseFoldersDlg.Get_SelectedDatabase: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedDatabase;
end;

procedure TBrowseFoldersDlg.Set_SelectedDatabase(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedDatabase(pVal);
end;

function  TBrowseFoldersDlg.Get_SelectedFolder: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedFolder;
end;

procedure TBrowseFoldersDlg.Set_SelectedFolder(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedFolder(pVal);
end;

function  TBrowseFoldersDlg.Get_SelectedPath: WideString;
begin
  Result := DefaultInterface.Get_SelectedPath;
end;

procedure TBrowseFoldersDlg.Set_SelectedPath(const pVal: WideString);
begin
  DefaultInterface.Set_SelectedPath(pVal);
end;

function  TBrowseFoldersDlg.Get_ShowSingleDatabase: WordBool;
begin
  Result := DefaultInterface.Get_ShowSingleDatabase;
end;

procedure TBrowseFoldersDlg.Set_ShowSingleDatabase(pVal: WordBool);
begin
  DefaultInterface.Set_ShowSingleDatabase(pVal);
end;

function  TBrowseFoldersDlg.Get_ShowReadWriteFoldersOnly: WordBool;
begin
  Result := DefaultInterface.Get_ShowReadWriteFoldersOnly;
end;

procedure TBrowseFoldersDlg.Set_ShowReadWriteFoldersOnly(pVal: WordBool);
begin
  DefaultInterface.Set_ShowReadWriteFoldersOnly(pVal);
end;

function  TBrowseFoldersDlg.Get_SelectedPage: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedPage;
end;

procedure TBrowseFoldersDlg.Set_SelectedPage(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedPage(pVal);
end;

procedure TBrowseFoldersDlg.Show(ParentWnd: Integer);
begin
  DefaultInterface.Show(ParentWnd);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TBrowseFoldersDlgProperties.Create(AServer: TBrowseFoldersDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TBrowseFoldersDlgProperties.GetDefaultInterface: IDualBrowseFoldersDlg;
begin
  Result := FServer.DefaultInterface;
end;

function  TBrowseFoldersDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TBrowseFoldersDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TBrowseFoldersDlgProperties.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_Sessions: OleVariant;
begin
  Result := DefaultInterface.Get_Sessions;
end;

procedure TBrowseFoldersDlgProperties.Set_Sessions(pVal: OleVariant);
begin
  DefaultInterface.Set_Sessions(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_DestinationObject: IDispatch;
begin
  Result := DefaultInterface.Get_DestinationObject;
end;

procedure TBrowseFoldersDlgProperties.Set_DestinationObject(const pVal: IDispatch);
begin
  DefaultInterface.Set_DestinationObject(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_SelectedSession: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedSession;
end;

procedure TBrowseFoldersDlgProperties.Set_SelectedSession(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedSession(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_SelectedDatabase: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedDatabase;
end;

procedure TBrowseFoldersDlgProperties.Set_SelectedDatabase(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedDatabase(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_SelectedFolder: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedFolder;
end;

procedure TBrowseFoldersDlgProperties.Set_SelectedFolder(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedFolder(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_SelectedPath: WideString;
begin
  Result := DefaultInterface.Get_SelectedPath;
end;

procedure TBrowseFoldersDlgProperties.Set_SelectedPath(const pVal: WideString);
begin
  DefaultInterface.Set_SelectedPath(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_ShowSingleDatabase: WordBool;
begin
  Result := DefaultInterface.Get_ShowSingleDatabase;
end;

procedure TBrowseFoldersDlgProperties.Set_ShowSingleDatabase(pVal: WordBool);
begin
  DefaultInterface.Set_ShowSingleDatabase(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_ShowReadWriteFoldersOnly: WordBool;
begin
  Result := DefaultInterface.Get_ShowReadWriteFoldersOnly;
end;

procedure TBrowseFoldersDlgProperties.Set_ShowReadWriteFoldersOnly(pVal: WordBool);
begin
  DefaultInterface.Set_ShowReadWriteFoldersOnly(pVal);
end;

function  TBrowseFoldersDlgProperties.Get_SelectedPage: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedPage;
end;

procedure TBrowseFoldersDlgProperties.Set_SelectedPage(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedPage(pVal);
end;

{$ENDIF}

class function CoFavoritesDlg.Create: IDualFavoritesDlg;
begin
  Result := CreateComObject(CLASS_FavoritesDlg) as IDualFavoritesDlg;
end;

class function CoFavoritesDlg.CreateRemote(const MachineName: string): IDualFavoritesDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FavoritesDlg) as IDualFavoritesDlg;
end;

procedure TFavoritesDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{C95CA55E-3DFC-4311-B7DF-FCB4AD3741FA}';
    IntfIID:   '{3B4C3022-203A-41A0-9069-2FCB60737B82}';
    EventIID:  '{B3C94199-1A01-4A1E-B7AC-07C160665CE1}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TFavoritesDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IDualFavoritesDlg;
  end;
end;

procedure TFavoritesDlg.ConnectTo(svrIntf: IDualFavoritesDlg);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TFavoritesDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TFavoritesDlg.GetDefaultInterface: IDualFavoritesDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TFavoritesDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TFavoritesDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TFavoritesDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TFavoritesDlg.GetServerProperties: TFavoritesDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TFavoritesDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TFavoritesDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TFavoritesDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TFavoritesDlg.Get_IManDMS: IDispatch;
begin
  Result := DefaultInterface.Get_IManDMS;
end;

procedure TFavoritesDlg.Set_IManDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_IManDMS(pVal);
end;

function  TFavoritesDlg.Get_SelectedFolder: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedFolder;
end;

procedure TFavoritesDlg.Set_SelectedFolder(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedFolder(pVal);
end;

function  TFavoritesDlg.Get_SelectedPath: WideString;
begin
  Result := DefaultInterface.Get_SelectedPath;
end;

procedure TFavoritesDlg.Set_SelectedPath(const pVal: WideString);
begin
  DefaultInterface.Set_SelectedPath(pVal);
end;

function  TFavoritesDlg.Get_ShowReadWriteFoldersOnly: WordBool;
begin
  Result := DefaultInterface.Get_ShowReadWriteFoldersOnly;
end;

procedure TFavoritesDlg.Set_ShowReadWriteFoldersOnly(pVal: WordBool);
begin
  DefaultInterface.Set_ShowReadWriteFoldersOnly(pVal);
end;

function  TFavoritesDlg.Get_FavoritesName: WideString;
begin
  Result := DefaultInterface.Get_FavoritesName;
end;

procedure TFavoritesDlg.Set_FavoritesName(const pVal: WideString);
begin
  DefaultInterface.Set_FavoritesName(pVal);
end;

procedure TFavoritesDlg.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TFavoritesDlg.Set_Message(const Param1: WideString);
begin
  DefaultInterface.Set_Message(Param1);
end;

function  TFavoritesDlg.Get_TargetType: Integer;
begin
  Result := DefaultInterface.Get_TargetType;
end;

procedure TFavoritesDlg.Set_TargetType(pVal: Integer);
begin
  DefaultInterface.Set_TargetType(pVal);
end;

function  TFavoritesDlg.Get_Bitmap: OleVariant;
begin
  Result := DefaultInterface.Get_Bitmap;
end;

procedure TFavoritesDlg.Set_Bitmap(pVal: OleVariant);
begin
  DefaultInterface.Set_Bitmap(pVal);
end;

function  TFavoritesDlg.Get_ShowMinimumControls: WordBool;
begin
  Result := DefaultInterface.Get_ShowMinimumControls;
end;

procedure TFavoritesDlg.Set_ShowMinimumControls(pVal: WordBool);
begin
  DefaultInterface.Set_ShowMinimumControls(pVal);
end;

function  TFavoritesDlg.Get_IManSession: IDispatch;
begin
  Result := DefaultInterface.Get_IManSession;
end;

procedure TFavoritesDlg.Set_IManSession(const pVal: IDispatch);
begin
  DefaultInterface.Set_IManSession(pVal);
end;

procedure TFavoritesDlg.Set_HelpID(Param1: Integer);
begin
  DefaultInterface.Set_HelpID(Param1);
end;

procedure TFavoritesDlg.Show(ParentWnd: Integer);
begin
  DefaultInterface.Show(ParentWnd);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TFavoritesDlgProperties.Create(AServer: TFavoritesDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TFavoritesDlgProperties.GetDefaultInterface: IDualFavoritesDlg;
begin
  Result := FServer.DefaultInterface;
end;

function  TFavoritesDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TFavoritesDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TFavoritesDlgProperties.Get_IManDMS: IDispatch;
begin
  Result := DefaultInterface.Get_IManDMS;
end;

procedure TFavoritesDlgProperties.Set_IManDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_IManDMS(pVal);
end;

function  TFavoritesDlgProperties.Get_SelectedFolder: IDispatch;
begin
  Result := DefaultInterface.Get_SelectedFolder;
end;

procedure TFavoritesDlgProperties.Set_SelectedFolder(const pVal: IDispatch);
begin
  DefaultInterface.Set_SelectedFolder(pVal);
end;

function  TFavoritesDlgProperties.Get_SelectedPath: WideString;
begin
  Result := DefaultInterface.Get_SelectedPath;
end;

procedure TFavoritesDlgProperties.Set_SelectedPath(const pVal: WideString);
begin
  DefaultInterface.Set_SelectedPath(pVal);
end;

function  TFavoritesDlgProperties.Get_ShowReadWriteFoldersOnly: WordBool;
begin
  Result := DefaultInterface.Get_ShowReadWriteFoldersOnly;
end;

procedure TFavoritesDlgProperties.Set_ShowReadWriteFoldersOnly(pVal: WordBool);
begin
  DefaultInterface.Set_ShowReadWriteFoldersOnly(pVal);
end;

function  TFavoritesDlgProperties.Get_FavoritesName: WideString;
begin
  Result := DefaultInterface.Get_FavoritesName;
end;

procedure TFavoritesDlgProperties.Set_FavoritesName(const pVal: WideString);
begin
  DefaultInterface.Set_FavoritesName(pVal);
end;

procedure TFavoritesDlgProperties.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TFavoritesDlgProperties.Set_Message(const Param1: WideString);
begin
  DefaultInterface.Set_Message(Param1);
end;

function  TFavoritesDlgProperties.Get_TargetType: Integer;
begin
  Result := DefaultInterface.Get_TargetType;
end;

procedure TFavoritesDlgProperties.Set_TargetType(pVal: Integer);
begin
  DefaultInterface.Set_TargetType(pVal);
end;

function  TFavoritesDlgProperties.Get_Bitmap: OleVariant;
begin
  Result := DefaultInterface.Get_Bitmap;
end;

procedure TFavoritesDlgProperties.Set_Bitmap(pVal: OleVariant);
begin
  DefaultInterface.Set_Bitmap(pVal);
end;

function  TFavoritesDlgProperties.Get_ShowMinimumControls: WordBool;
begin
  Result := DefaultInterface.Get_ShowMinimumControls;
end;

procedure TFavoritesDlgProperties.Set_ShowMinimumControls(pVal: WordBool);
begin
  DefaultInterface.Set_ShowMinimumControls(pVal);
end;

function  TFavoritesDlgProperties.Get_IManSession: IDispatch;
begin
  Result := DefaultInterface.Get_IManSession;
end;

procedure TFavoritesDlgProperties.Set_IManSession(const pVal: IDispatch);
begin
  DefaultInterface.Set_IManSession(pVal);
end;

procedure TFavoritesDlgProperties.Set_HelpID(Param1: Integer);
begin
  DefaultInterface.Set_HelpID(Param1);
end;

{$ENDIF}

class function CoOrganizeFavoritesDlg.Create: IDualOrganizeFavoritesDlg;
begin
  Result := CreateComObject(CLASS_OrganizeFavoritesDlg) as IDualOrganizeFavoritesDlg;
end;

class function CoOrganizeFavoritesDlg.CreateRemote(const MachineName: string): IDualOrganizeFavoritesDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OrganizeFavoritesDlg) as IDualOrganizeFavoritesDlg;
end;

procedure TOrganizeFavoritesDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{A7326E15-BE23-4806-AD1A-8130158C3C62}';
    IntfIID:   '{2660FC53-4370-4E83-B45C-1516E677A0F0}';
    EventIID:  '{D56F7FB7-FD12-43D3-896A-31999B727BB9}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TOrganizeFavoritesDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IDualOrganizeFavoritesDlg;
  end;
end;

procedure TOrganizeFavoritesDlg.ConnectTo(svrIntf: IDualOrganizeFavoritesDlg);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TOrganizeFavoritesDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TOrganizeFavoritesDlg.GetDefaultInterface: IDualOrganizeFavoritesDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TOrganizeFavoritesDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TOrganizeFavoritesDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TOrganizeFavoritesDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TOrganizeFavoritesDlg.GetServerProperties: TOrganizeFavoritesDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TOrganizeFavoritesDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TOrganizeFavoritesDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TOrganizeFavoritesDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TOrganizeFavoritesDlg.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TOrganizeFavoritesDlg.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

procedure TOrganizeFavoritesDlg.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TOrganizeFavoritesDlg.Set_Message(const Param1: WideString);
begin
  DefaultInterface.Set_Message(Param1);
end;

procedure TOrganizeFavoritesDlg.Show(ParentWnd: Integer);
begin
  DefaultInterface.Show(ParentWnd);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TOrganizeFavoritesDlgProperties.Create(AServer: TOrganizeFavoritesDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TOrganizeFavoritesDlgProperties.GetDefaultInterface: IDualOrganizeFavoritesDlg;
begin
  Result := FServer.DefaultInterface;
end;

function  TOrganizeFavoritesDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TOrganizeFavoritesDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TOrganizeFavoritesDlgProperties.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TOrganizeFavoritesDlgProperties.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

procedure TOrganizeFavoritesDlgProperties.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TOrganizeFavoritesDlgProperties.Set_Message(const Param1: WideString);
begin
  DefaultInterface.Set_Message(Param1);
end;

{$ENDIF}

class function CoAdvancedOptionsDlg.Create: IDualAdvancedOptionsDlg;
begin
  Result := CreateComObject(CLASS_AdvancedOptionsDlg) as IDualAdvancedOptionsDlg;
end;

class function CoAdvancedOptionsDlg.CreateRemote(const MachineName: string): IDualAdvancedOptionsDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AdvancedOptionsDlg) as IDualAdvancedOptionsDlg;
end;

procedure TAdvancedOptionsDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{3A732CEA-0012-11D4-AAC0-00C04F6803D1}';
    IntfIID:   '{D813851B-0012-11D4-AAC0-00C04F6803D1}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TAdvancedOptionsDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as IDualAdvancedOptionsDlg;
  end;
end;

procedure TAdvancedOptionsDlg.ConnectTo(svrIntf: IDualAdvancedOptionsDlg);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TAdvancedOptionsDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TAdvancedOptionsDlg.GetDefaultInterface: IDualAdvancedOptionsDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TAdvancedOptionsDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TAdvancedOptionsDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TAdvancedOptionsDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TAdvancedOptionsDlg.GetServerProperties: TAdvancedOptionsDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TAdvancedOptionsDlg.Show(ParentWnd: Integer);
begin
  DefaultInterface.Show(ParentWnd);
end;

function  TAdvancedOptionsDlg.Window: Integer;
begin
  Result := DefaultInterface.Window;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TAdvancedOptionsDlgProperties.Create(AServer: TAdvancedOptionsDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TAdvancedOptionsDlgProperties.GetDefaultInterface: IDualAdvancedOptionsDlg;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoSaveEmailDlg.Create: ISaveEmailDlg;
begin
  Result := CreateComObject(CLASS_SaveEmailDlg) as ISaveEmailDlg;
end;

class function CoSaveEmailDlg.CreateRemote(const MachineName: string): ISaveEmailDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_SaveEmailDlg) as ISaveEmailDlg;
end;

procedure TSaveEmailDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{6A59C0DA-A14E-11D4-B969-00C04F093D23}';
    IntfIID:   '{6A59C0D9-A14E-11D4-B969-00C04F093D23}';
    EventIID:  '{6A59C0DB-A14E-11D4-B969-00C04F093D23}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TSaveEmailDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as ISaveEmailDlg;
  end;
end;

procedure TSaveEmailDlg.ConnectTo(svrIntf: ISaveEmailDlg);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TSaveEmailDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TSaveEmailDlg.GetDefaultInterface: ISaveEmailDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TSaveEmailDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TSaveEmailDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TSaveEmailDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TSaveEmailDlg.GetServerProperties: TSaveEmailDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TSaveEmailDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TSaveEmailDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TSaveEmailDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

procedure TSaveEmailDlg.Set_EnableRelateAttachments(Param1: WordBool);
begin
  DefaultInterface.Set_EnableRelateAttachments(Param1);
end;

procedure TSaveEmailDlg.Set_EnableCommonProfile(Param1: WordBool);
begin
  DefaultInterface.Set_EnableCommonProfile(Param1);
end;

function  TSaveEmailDlg.Get_SelectRelateAttachments: WordBool;
begin
  Result := DefaultInterface.Get_SelectRelateAttachments;
end;

procedure TSaveEmailDlg.Set_SelectRelateAttachments(pVal: WordBool);
begin
  DefaultInterface.Set_SelectRelateAttachments(pVal);
end;

function  TSaveEmailDlg.Get_SelectCommonProfile: WordBool;
begin
  Result := DefaultInterface.Get_SelectCommonProfile;
end;

procedure TSaveEmailDlg.Set_SelectCommonProfile(pVal: WordBool);
begin
  DefaultInterface.Set_SelectCommonProfile(pVal);
end;

procedure TSaveEmailDlg.Set_DocumentDescriptionArray(Param1: OleVariant);
begin
  DefaultInterface.Set_DocumentDescriptionArray(Param1);
end;

function  TSaveEmailDlg.Get_DocumentIndexArray: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentIndexArray;
end;

procedure TSaveEmailDlg.Set_InitialExpand(Param1: WordBool);
begin
  DefaultInterface.Set_InitialExpand(Param1);
end;

procedure TSaveEmailDlg.Set_NRTDMS(const Param1: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(Param1);
end;

function  TSaveEmailDlg.Get_BaseVersionDocsArray: OleVariant;
begin
  Result := DefaultInterface.Get_BaseVersionDocsArray;
end;

procedure TSaveEmailDlg.Show(hParentWnd: Integer);
begin
  DefaultInterface.Show(hParentWnd);
end;

function  TSaveEmailDlg.Window: Integer;
begin
  Result := DefaultInterface.Window;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TSaveEmailDlgProperties.Create(AServer: TSaveEmailDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TSaveEmailDlgProperties.GetDefaultInterface: ISaveEmailDlg;
begin
  Result := FServer.DefaultInterface;
end;

function  TSaveEmailDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TSaveEmailDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

procedure TSaveEmailDlgProperties.Set_EnableRelateAttachments(Param1: WordBool);
begin
  DefaultInterface.Set_EnableRelateAttachments(Param1);
end;

procedure TSaveEmailDlgProperties.Set_EnableCommonProfile(Param1: WordBool);
begin
  DefaultInterface.Set_EnableCommonProfile(Param1);
end;

function  TSaveEmailDlgProperties.Get_SelectRelateAttachments: WordBool;
begin
  Result := DefaultInterface.Get_SelectRelateAttachments;
end;

procedure TSaveEmailDlgProperties.Set_SelectRelateAttachments(pVal: WordBool);
begin
  DefaultInterface.Set_SelectRelateAttachments(pVal);
end;

function  TSaveEmailDlgProperties.Get_SelectCommonProfile: WordBool;
begin
  Result := DefaultInterface.Get_SelectCommonProfile;
end;

procedure TSaveEmailDlgProperties.Set_SelectCommonProfile(pVal: WordBool);
begin
  DefaultInterface.Set_SelectCommonProfile(pVal);
end;

procedure TSaveEmailDlgProperties.Set_DocumentDescriptionArray(Param1: OleVariant);
begin
  DefaultInterface.Set_DocumentDescriptionArray(Param1);
end;

function  TSaveEmailDlgProperties.Get_DocumentIndexArray: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentIndexArray;
end;

procedure TSaveEmailDlgProperties.Set_InitialExpand(Param1: WordBool);
begin
  DefaultInterface.Set_InitialExpand(Param1);
end;

procedure TSaveEmailDlgProperties.Set_NRTDMS(const Param1: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(Param1);
end;

function  TSaveEmailDlgProperties.Get_BaseVersionDocsArray: OleVariant;
begin
  Result := DefaultInterface.Get_BaseVersionDocsArray;
end;

{$ENDIF}

class function CoImportLinksDlg.Create: IImportLinksDlg;
begin
  Result := CreateComObject(CLASS_ImportLinksDlg) as IImportLinksDlg;
end;

class function CoImportLinksDlg.CreateRemote(const MachineName: string): IImportLinksDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ImportLinksDlg) as IImportLinksDlg;
end;

procedure TImportLinksDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{968F7685-FFD0-11D5-BB9A-00C04F610D7A}';
    IntfIID:   '{917932D1-FFCF-11D5-BB9A-00C04F610D7A}';
    EventIID:  '{38FFEEB9-FFD0-11D5-BB9A-00C04F610D7A}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TImportLinksDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IImportLinksDlg;
  end;
end;

procedure TImportLinksDlg.ConnectTo(svrIntf: IImportLinksDlg);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TImportLinksDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TImportLinksDlg.GetDefaultInterface: IImportLinksDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TImportLinksDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TImportLinksDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TImportLinksDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TImportLinksDlg.GetServerProperties: TImportLinksDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TImportLinksDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TImportLinksDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TImportLinksDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

procedure TImportLinksDlg.Set_EnableRelateLinks(Param1: WordBool);
begin
  DefaultInterface.Set_EnableRelateLinks(Param1);
end;

procedure TImportLinksDlg.Set_EnableCommonProfile(Param1: WordBool);
begin
  DefaultInterface.Set_EnableCommonProfile(Param1);
end;

function  TImportLinksDlg.Get_RelateLinks: WordBool;
begin
  Result := DefaultInterface.Get_RelateLinks;
end;

procedure TImportLinksDlg.Set_RelateLinks(pVal: WordBool);
begin
  DefaultInterface.Set_RelateLinks(pVal);
end;

function  TImportLinksDlg.Get_CommonProfile: WordBool;
begin
  Result := DefaultInterface.Get_CommonProfile;
end;

procedure TImportLinksDlg.Set_CommonProfile(pVal: WordBool);
begin
  DefaultInterface.Set_CommonProfile(pVal);
end;

procedure TImportLinksDlg.Set_DocumentDescriptionArray(Param1: OleVariant);
begin
  DefaultInterface.Set_DocumentDescriptionArray(Param1);
end;

function  TImportLinksDlg.Get_DocumentIndexArray: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentIndexArray;
end;

procedure TImportLinksDlg.Set_InitialExpand(Param1: WordBool);
begin
  DefaultInterface.Set_InitialExpand(Param1);
end;

procedure TImportLinksDlg.Set_NRTDMS(const Param1: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(Param1);
end;

function  TImportLinksDlg.Get_BaseVersionDocsArray: OleVariant;
begin
  Result := DefaultInterface.Get_BaseVersionDocsArray;
end;

function  TImportLinksDlg.Get_LatestVersion: WordBool;
begin
  Result := DefaultInterface.Get_LatestVersion;
end;

procedure TImportLinksDlg.Set_LatestVersion(pVal: WordBool);
begin
  DefaultInterface.Set_LatestVersion(pVal);
end;

procedure TImportLinksDlg.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TImportLinksDlg.Set_Message(const Param1: WideString);
begin
  DefaultInterface.Set_Message(Param1);
end;

procedure TImportLinksDlg.Set_OkButtonCaption(const Param1: WideString);
begin
  DefaultInterface.Set_OkButtonCaption(Param1);
end;

procedure TImportLinksDlg.Set_CancelButtonCaption(const Param1: WideString);
begin
  DefaultInterface.Set_CancelButtonCaption(Param1);
end;

procedure TImportLinksDlg.Set_CommonProfileCaption(const Param1: WideString);
begin
  DefaultInterface.Set_CommonProfileCaption(Param1);
end;

procedure TImportLinksDlg.Set_LatestVerCaption(const Param1: WideString);
begin
  DefaultInterface.Set_LatestVerCaption(Param1);
end;

procedure TImportLinksDlg.Show(hParentWnd: Integer);
begin
  DefaultInterface.Show(hParentWnd);
end;

function  TImportLinksDlg.Window: Integer;
begin
  Result := DefaultInterface.Window;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TImportLinksDlgProperties.Create(AServer: TImportLinksDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TImportLinksDlgProperties.GetDefaultInterface: IImportLinksDlg;
begin
  Result := FServer.DefaultInterface;
end;

function  TImportLinksDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TImportLinksDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

procedure TImportLinksDlgProperties.Set_EnableRelateLinks(Param1: WordBool);
begin
  DefaultInterface.Set_EnableRelateLinks(Param1);
end;

procedure TImportLinksDlgProperties.Set_EnableCommonProfile(Param1: WordBool);
begin
  DefaultInterface.Set_EnableCommonProfile(Param1);
end;

function  TImportLinksDlgProperties.Get_RelateLinks: WordBool;
begin
  Result := DefaultInterface.Get_RelateLinks;
end;

procedure TImportLinksDlgProperties.Set_RelateLinks(pVal: WordBool);
begin
  DefaultInterface.Set_RelateLinks(pVal);
end;

function  TImportLinksDlgProperties.Get_CommonProfile: WordBool;
begin
  Result := DefaultInterface.Get_CommonProfile;
end;

procedure TImportLinksDlgProperties.Set_CommonProfile(pVal: WordBool);
begin
  DefaultInterface.Set_CommonProfile(pVal);
end;

procedure TImportLinksDlgProperties.Set_DocumentDescriptionArray(Param1: OleVariant);
begin
  DefaultInterface.Set_DocumentDescriptionArray(Param1);
end;

function  TImportLinksDlgProperties.Get_DocumentIndexArray: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentIndexArray;
end;

procedure TImportLinksDlgProperties.Set_InitialExpand(Param1: WordBool);
begin
  DefaultInterface.Set_InitialExpand(Param1);
end;

procedure TImportLinksDlgProperties.Set_NRTDMS(const Param1: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(Param1);
end;

function  TImportLinksDlgProperties.Get_BaseVersionDocsArray: OleVariant;
begin
  Result := DefaultInterface.Get_BaseVersionDocsArray;
end;

function  TImportLinksDlgProperties.Get_LatestVersion: WordBool;
begin
  Result := DefaultInterface.Get_LatestVersion;
end;

procedure TImportLinksDlgProperties.Set_LatestVersion(pVal: WordBool);
begin
  DefaultInterface.Set_LatestVersion(pVal);
end;

procedure TImportLinksDlgProperties.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TImportLinksDlgProperties.Set_Message(const Param1: WideString);
begin
  DefaultInterface.Set_Message(Param1);
end;

procedure TImportLinksDlgProperties.Set_OkButtonCaption(const Param1: WideString);
begin
  DefaultInterface.Set_OkButtonCaption(Param1);
end;

procedure TImportLinksDlgProperties.Set_CancelButtonCaption(const Param1: WideString);
begin
  DefaultInterface.Set_CancelButtonCaption(Param1);
end;

procedure TImportLinksDlgProperties.Set_CommonProfileCaption(const Param1: WideString);
begin
  DefaultInterface.Set_CommonProfileCaption(Param1);
end;

procedure TImportLinksDlgProperties.Set_LatestVerCaption(const Param1: WideString);
begin
  DefaultInterface.Set_LatestVerCaption(Param1);
end;

{$ENDIF}

class function CoConfigCommonDlg.Create: IConfigCommonDlg;
begin
  Result := CreateComObject(CLASS_ConfigCommonDlg) as IConfigCommonDlg;
end;

class function CoConfigCommonDlg.CreateRemote(const MachineName: string): IConfigCommonDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_ConfigCommonDlg) as IConfigCommonDlg;
end;

procedure TConfigCommonDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{C04B0AD7-8A89-11D5-AB6D-00C04F6803D1}';
    IntfIID:   '{FD81CBE9-8A88-11D5-AB6D-00C04F6803D1}';
    EventIID:  '{6529C8CD-8A89-11D5-AB6D-00C04F6803D1}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TConfigCommonDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IConfigCommonDlg;
  end;
end;

procedure TConfigCommonDlg.ConnectTo(svrIntf: IConfigCommonDlg);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TConfigCommonDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TConfigCommonDlg.GetDefaultInterface: IConfigCommonDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TConfigCommonDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TConfigCommonDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TConfigCommonDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TConfigCommonDlg.GetServerProperties: TConfigCommonDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TConfigCommonDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TConfigCommonDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TConfigCommonDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TConfigCommonDlg.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TConfigCommonDlg.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

function  TConfigCommonDlg.Get_ContextItems: IDispatch;
begin
  Result := DefaultInterface.Get_ContextItems;
end;

procedure TConfigCommonDlg.Set_ContextItems(const pVal: IDispatch);
begin
  DefaultInterface.Set_ContextItems(pVal);
end;

procedure TConfigCommonDlg.Show(hParentWnd: Integer);
begin
  DefaultInterface.Show(hParentWnd);
end;

function  TConfigCommonDlg.Window: Integer;
begin
  Result := DefaultInterface.Window;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TConfigCommonDlgProperties.Create(AServer: TConfigCommonDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TConfigCommonDlgProperties.GetDefaultInterface: IConfigCommonDlg;
begin
  Result := FServer.DefaultInterface;
end;

function  TConfigCommonDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TConfigCommonDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TConfigCommonDlgProperties.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TConfigCommonDlgProperties.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

function  TConfigCommonDlgProperties.Get_ContextItems: IDispatch;
begin
  Result := DefaultInterface.Get_ContextItems;
end;

procedure TConfigCommonDlgProperties.Set_ContextItems(const pVal: IDispatch);
begin
  DefaultInterface.Set_ContextItems(pVal);
end;

{$ENDIF}

class function CoDocListDlg.Create: IDocListDlg;
begin
  Result := CreateComObject(CLASS_DocListDlg) as IDocListDlg;
end;

class function CoDocListDlg.CreateRemote(const MachineName: string): IDocListDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_DocListDlg) as IDocListDlg;
end;

procedure TDocListDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{68FAB9A7-0ACD-11D6-BBA1-00C04F610D7A}';
    IntfIID:   '{9C7DA825-0ACD-11D6-BBA1-00C04F610D7A}';
    EventIID:  '{F2D22C07-0AD0-11D6-BBA1-00C04F610D7A}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TDocListDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IDocListDlg;
  end;
end;

procedure TDocListDlg.ConnectTo(svrIntf: IDocListDlg);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TDocListDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TDocListDlg.GetDefaultInterface: IDocListDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TDocListDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TDocListDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TDocListDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TDocListDlg.GetServerProperties: TDocListDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TDocListDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TDocListDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TDocListDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

procedure TDocListDlg.Set_DocumentList(Param1: OleVariant);
begin
  DefaultInterface.Set_DocumentList(Param1);
end;

function  TDocListDlg.Get_DocumentSelectedList: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentSelectedList;
end;

procedure TDocListDlg.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TDocListDlg.Set_Message(const Param1: WideString);
begin
  DefaultInterface.Set_Message(Param1);
end;

procedure TDocListDlg.Set_OkButtonCaption(const Param1: WideString);
begin
  DefaultInterface.Set_OkButtonCaption(Param1);
end;

procedure TDocListDlg.Set_CancelButtonCaption(const Param1: WideString);
begin
  DefaultInterface.Set_CancelButtonCaption(Param1);
end;

procedure TDocListDlg.Show(hParentWnd: Integer);
begin
  DefaultInterface.Show(hParentWnd);
end;

function  TDocListDlg.Window: Integer;
begin
  Result := DefaultInterface.Window;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TDocListDlgProperties.Create(AServer: TDocListDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TDocListDlgProperties.GetDefaultInterface: IDocListDlg;
begin
  Result := FServer.DefaultInterface;
end;

function  TDocListDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TDocListDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

procedure TDocListDlgProperties.Set_DocumentList(Param1: OleVariant);
begin
  DefaultInterface.Set_DocumentList(Param1);
end;

function  TDocListDlgProperties.Get_DocumentSelectedList: OleVariant;
begin
  Result := DefaultInterface.Get_DocumentSelectedList;
end;

procedure TDocListDlgProperties.Set_Caption(const Param1: WideString);
begin
  DefaultInterface.Set_Caption(Param1);
end;

procedure TDocListDlgProperties.Set_Message(const Param1: WideString);
begin
  DefaultInterface.Set_Message(Param1);
end;

procedure TDocListDlgProperties.Set_OkButtonCaption(const Param1: WideString);
begin
  DefaultInterface.Set_OkButtonCaption(Param1);
end;

procedure TDocListDlgProperties.Set_CancelButtonCaption(const Param1: WideString);
begin
  DefaultInterface.Set_CancelButtonCaption(Param1);
end;

{$ENDIF}

class function CoAddToFavoritesDlg.Create: IAddToFavoritesDlg;
begin
  Result := CreateComObject(CLASS_AddToFavoritesDlg) as IAddToFavoritesDlg;
end;

class function CoAddToFavoritesDlg.CreateRemote(const MachineName: string): IAddToFavoritesDlg;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_AddToFavoritesDlg) as IAddToFavoritesDlg;
end;

procedure TAddToFavoritesDlg.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{32F83878-9769-416A-A1A3-6B1F583110C0}';
    IntfIID:   '{8722388E-D253-43AD-8AF1-47CB7BD12C5E}';
    EventIID:  '{85D0B2E5-86CE-49EA-889F-C70B3C3A6128}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TAddToFavoritesDlg.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IAddToFavoritesDlg;
  end;
end;

procedure TAddToFavoritesDlg.ConnectTo(svrIntf: IAddToFavoritesDlg);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TAddToFavoritesDlg.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TAddToFavoritesDlg.GetDefaultInterface: IAddToFavoritesDlg;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TAddToFavoritesDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TAddToFavoritesDlgProperties.Create(Self);
{$ENDIF}
end;

destructor TAddToFavoritesDlg.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TAddToFavoritesDlg.GetServerProperties: TAddToFavoritesDlgProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TAddToFavoritesDlg.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
   1: if Assigned(FOnOK) then
            FOnOK(Self, Params[0] {const IDispatch});
   2: if Assigned(FOnCancel) then
            FOnCancel(Self, Params[0] {const IDispatch});
   3: if Assigned(FOnInitDialog) then
            FOnInitDialog(Self, Params[0] {const IDispatch});
  end; {case DispID}
end;

function  TAddToFavoritesDlg.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TAddToFavoritesDlg.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TAddToFavoritesDlg.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TAddToFavoritesDlg.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

function  TAddToFavoritesDlg.Get_ContextItems: IDispatch;
begin
  Result := DefaultInterface.Get_ContextItems;
end;

procedure TAddToFavoritesDlg.Set_ContextItems(const pVal: IDispatch);
begin
  DefaultInterface.Set_ContextItems(pVal);
end;

procedure TAddToFavoritesDlg.Show(hParentWnd: Integer);
begin
  DefaultInterface.Show(hParentWnd);
end;

function  TAddToFavoritesDlg.Window: Integer;
begin
  Result := DefaultInterface.Window;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TAddToFavoritesDlgProperties.Create(AServer: TAddToFavoritesDlg);
begin
  inherited Create;
  FServer := AServer;
end;

function TAddToFavoritesDlgProperties.GetDefaultInterface: IAddToFavoritesDlg;
begin
  Result := FServer.DefaultInterface;
end;

function  TAddToFavoritesDlgProperties.Get_CloseOnOK: WordBool;
begin
  Result := DefaultInterface.Get_CloseOnOK;
end;

procedure TAddToFavoritesDlgProperties.Set_CloseOnOK(pVal: WordBool);
begin
  DefaultInterface.Set_CloseOnOK(pVal);
end;

function  TAddToFavoritesDlgProperties.Get_NRTDMS: IDispatch;
begin
  Result := DefaultInterface.Get_NRTDMS;
end;

procedure TAddToFavoritesDlgProperties.Set_NRTDMS(const pVal: IDispatch);
begin
  DefaultInterface.Set_NRTDMS(pVal);
end;

function  TAddToFavoritesDlgProperties.Get_ContextItems: IDispatch;
begin
  Result := DefaultInterface.Get_ContextItems;
end;

procedure TAddToFavoritesDlgProperties.Set_ContextItems(const pVal: IDispatch);
begin
  DefaultInterface.Set_ContextItems(pVal);
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents('iManage',[TDocOpenDlg, TPortableDocOpenDlg, TBrowseFoldersDlg, TFavoritesDlg, 
    TOrganizeFavoritesDlg, TAdvancedOptionsDlg, TSaveEmailDlg, TImportLinksDlg, TConfigCommonDlg, 
    TDocListDlg, TAddToFavoritesDlg]);
end;

end.
