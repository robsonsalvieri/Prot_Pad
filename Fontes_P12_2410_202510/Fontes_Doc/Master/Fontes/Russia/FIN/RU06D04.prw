#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RU06D04.CH"
#INCLUDE "RWMAKE.CH"

Static __cTabHdr  := "F47"
Static __cMdlHdr := "RU06D04_MHEAD"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D04
Payment Request Routine

@author natalia.khozyainova
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D04()
Local oBrowse as Object
// Included because of the MSDOCUMENT routine,
// the MVC does not need any private variables
// but MSDOCUMENT needs aRrotina and cCastro
Private cCadastro as Char
Private aRotina as Array

aRotina		:= {}
cCadastro := STR0001 //"Payment Requests"

oBrowse := BrowseDef()
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.
@author natalia.khozyainova
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse 	as Object
Local cFilter   as Char

//in all modules except SIGAFIN we filter only requests with F47_PAYTYP == 1
If nModulo != 6
    cFilter := "AllTrim(F47->F47_REQTYP) $ '1'"
Endif
DBSelectArea("F47")
DBSetOrder(4)
oBrowse	:= FWmBrowse():New()
oBrowse:SetAlias("F47")
oBrowse:SetDescription(STR0001) // Payment Requests
oBrowse:SetAttach(.T.)
oBrowse:SetFilterDefault(cFilter)
oBrowse:SetDoubleClick({||RU06D0410_Act(1)})
oBrowse:AddLegend("F47_STATUS =='1'", "WHITE", STR0075)
oBrowse:AddLegend("F47_STATUS =='2'", "YELLOW", STR0076)
oBrowse:AddLegend("F47_STATUS =='3'", "GREEN", STR0077)
If  SuperGetMv("MV_REQAPR",,"")  = 1
    oBrowse:AddLegend("F47_STATUS =='4'", "BLUE", STR0078)
    oBrowse:AddLegend("F47_STATUS =='5'", "RED", STR0079)
Endif

aRotina := Nil // needed for MSDOCUMENT
oBrowse:SetCacheView(.F.)// needed for MSDOCUMENT
Return (oBrowse)

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Menu definition.
@author natalia.khozyainova
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0002    ACTION "RU06D0410_Act(1)"               OPERATION 1 ACCESS 0   // View
ADD OPTION aRotina TITLE STR0003    ACTION "RU06D0418_SelectTypesForm()"    OPERATION 3 ACCESS 0   // Add
ADD OPTION aRotina TITLE STR0004    ACTION "RU06D0410_Act(4)"               OPERATION 4 ACCESS 0   // Edit
ADD OPTION aRotina TITLE STR0005    ACTION "RU06D0410_Act(5)"               OPERATION 5 ACCESS 0   // Delete
ADD OPTION aRotina TITLE STR0006    ACTION "MSDOCUMENT"                     OPERATION 4 ACCESS 0   // Knowledge (Upload Documents)
ADD OPTION aRotina TITLE STR0007    ACTION "RU06D0414_CopyOperation()"      OPERATION 9 ACCESS 0   // Copy
ADD OPTION aRotina TITLE STR0083    ACTION "RUD604LGND"                     OPERATION 7 ACCESS 0   // Legend
ADD OPTION aRotina TITLE STR0108    ACTION "RU06D0411_ShowPO()"             OPERATION 1 ACCESS 0   // Search for Payment Orders

If  SuperGetMv("MV_REQAPR",, 0)  = 1
    ADD OPTION aRotina Title STR0008    ACTION "R604ViwApr(1)"     OPERATION 4 ACCESS 0     //"Approve"
    ADD OPTION aRotina Title STR0028    ACTION "RUD604GRUP(1)"  OPERATION 4 ACCESS 0        //"Approve in Group"

    ADD OPTION aRotina Title STR0009    ACTION "R604ViwApr(2)"    OPERATION 4 ACCESS 0      //"Reject"
    ADD OPTION aRotina Title STR0029    ACTION "RUD604GRUP(2)"  OPERATION 4 ACCESS 0        //"Reject in Group"

Endif
Return (aRotina)



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition.
@author natalia.khozyainova
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ModelDef()
Local oStrF47 	as Object
Local oStrF48 	as Object
Local iCx       as Numeric

Local oUpdF47Event 	:= RU06D04EventRUS():New()
Public lUserValue  as Logical // will show if F47_VALUE WAS UPDATED BY USER

Default lUserValue:=.F.
If Type('cOperTp') == 'U'
    cOperTp := '1' //default payment to supplier
EndIf
oModel:= MPFormModel():New("RU06D04")
oModel:SetDescription(STR0001) // Payment Requests

// Header structure - F47 Payment Request - Header
oStrF47 := FWFormStruct(1, "F47")
oStrF47:SetProperty("F47_IDF47", MODEL_FIELD_INIT, {|| FWUUIDV4(.F.) }  )
oStrF47:SetProperty("F47_DTPLAN", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'RU06D0401_RecalcCurrency()'))

Do Case
    //
    Case cOperTp == '1' .Or. cOperTp == '3'

        oStrF47:AddTrigger("F47_SUPP","F47_UNIT"  ,,{ |oModel| RU06D0419_GatForn("F47_UNIT")  })
        oStrF47:AddTrigger("F47_SUPP","F47_SUPNAM",,{ |oModel| RU06D0419_GatForn("F47_SUPNAM")})
        oStrF47:AddTrigger("F47_SUPP","F47_KPPREC",,{ |oModel| RU06D0419_GatForn("F47_KPPREC")})
        oStrF47:AddTrigger("F47_UNIT","F47_SUPNAM",,{ |oModel| RU06D0419_GatForn("F47_SUPNAM")})
        oStrF47:AddTrigger("F47_UNIT","F47_KPPREC",,{ |oModel| RU06D0419_GatForn("F47_KPPREC")})
        oStrF47:AddTrigger("F47_SUPP","F47_BNKCOD",,{ |oModel| RU06D05495_GatBankRec("F47_BNKCOD",__cMdlHdr)})
        oStrF47:AddTrigger("F47_SUPP","F47_BIK"   ,,{ |oModel| RU06D05495_GatBankRec("F47_BIK"   ,__cMdlHdr)})
        oStrF47:AddTrigger("F47_SUPP","F47_ACCNT" ,,{ |oModel| RU06D05495_GatBankRec("F47_ACCNT" ,__cMdlHdr)})
        oStrF47:AddTrigger("F47_SUPP","F47_TYPCC" ,,{ |oModel| RU06D05495_GatBankRec("F47_TYPCC" ,__cMdlHdr)})
        oStrF47:AddTrigger("F47_SUPP","F47_BKNAME",,{ |oModel| RU06D05495_GatBankRec("F47_BKNAME",__cMdlHdr)})
        oStrF47:AddTrigger("F47_SUPP","F47_ACNAME",,{ |oModel| RU06D05495_GatBankRec("F47_ACNAME",__cMdlHdr)})
        oStrF47:AddTrigger("F47_SUPP","F47_RECNAM",,{ |oModel| RU06D05495_GatBankRec("F47_RECNAM",__cMdlHdr)})
        oStrF47:AddTrigger("F47_UNIT","F47_BNKCOD",,{ |oModel| RU06D05495_GatBankRec("F47_BNKCOD",__cMdlHdr)})
        oStrF47:AddTrigger("F47_UNIT","F47_BIK"   ,,{ |oModel| RU06D05495_GatBankRec("F47_BIK"   ,__cMdlHdr)})
        oStrF47:AddTrigger("F47_UNIT","F47_ACCNT" ,,{ |oModel| RU06D05495_GatBankRec("F47_ACCNT" ,__cMdlHdr)})
        oStrF47:AddTrigger("F47_UNIT","F47_TYPCC" ,,{ |oModel| RU06D05495_GatBankRec("F47_TYPCC" ,__cMdlHdr)})
        oStrF47:AddTrigger("F47_UNIT","F47_BKNAME",,{ |oModel| RU06D05495_GatBankRec("F47_BKNAME",__cMdlHdr)})
        oStrF47:AddTrigger("F47_UNIT","F47_ACNAME",,{ |oModel| RU06D05495_GatBankRec("F47_ACNAME",__cMdlHdr)})
        oStrF47:AddTrigger("F47_UNIT","F47_RECNAM",,{ |oModel| RU06D05495_GatBankRec("F47_RECNAM",__cMdlHdr)})
        
        oStrF47:SetProperty('F47_KPPREC', MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, ''))
        oStrF47:SetProperty("F47_BNKCOD", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'R604VldFil(1)'))
        oStrF47:SetProperty("F47_BIK", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'R604VldFil(3)'))
        oStrF47:SetProperty("F47_ACCNT", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'R604VldFil(4)'))
        
        // Reset x3 settings mandatory field (as these fields not used for 1, 3)
        oStrF47:SetProperty("F47_RCVBNK", MODEL_FIELD_OBRIGAT, .F.)
        oStrF47:SetProperty("F47_RCVBIK", MODEL_FIELD_OBRIGAT, .F.)
        oStrF47:SetProperty("F47_RCVACC", MODEL_FIELD_OBRIGAT, .F.)
       
    // Transfers between bank accounts
    Case cOperTp == '6'
        oStrF47:AddTrigger("F47_ACCNT","F47_RECNAM", , { |oModel| RU06D04204(1)})
        oStrF47:AddTrigger("F47_RCVACC","F47_RCVNAM", , { |oModel| RU06D04204(2)})
        oStrF47:AddTrigger("F47_BNKCOD","F47_RECNAM", , { |oModel| RU06D04205()})
        oStrF47:SetProperty('F47_KPPREC', MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(INCLUI,GetCoBrRUS()[2][5][2] ,"")'))
        oStrF47:SetProperty("F47_BNKCOD", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'RU06D04014_VldSa6(0)'))
        oStrF47:SetProperty("F47_BIK", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'RU06D04014_VldSa6(3)'))
        oStrF47:SetProperty("F47_ACCNT", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'RU06D04014_VldSa6(4)'))

        //oStrF47:SetProperty( aCurFldSt[nICnt][3], MODEL_FIELD_OBRIGAT, .F.)
        
         aRmvFldEx := {"F47_TAX", "F47_CFGCOD", "F47_SUPP", "F47_UNIT", "F47_SUPNAM", ;
                        "F47_PREPAY", "F47_TYPCC", "F47_BKNAME", "F47_ACNAME", "F47_CNT", ;
                        "F47_VATCOD", "F47_VATAMT", "F47_VATRAT", "F47_REGNUM", "F47_BCC", ;
                        "F47_OKTMO", "F47_PAYSTA", "F47_PSDESC", "F47_PAYBAS", "F47_PBDESC", ;
                        "F47_UIP", "F47_TAXPER", "F47_CUSOFF", "F47_NTAXDC", "F47_F5QDES", ;
                        "F47_CTPRE", "F47_CCPRE", "F47_ITPRE", "F47_CLPRE", "F47_DTTXDC"}
        
        for iCx = 1 To len(aRmvFldEx)
            if ostrF47:HasField(aRmvFldEx[iCx])
                oStrF47:SetProperty(aRmvFldEx[iCx], MODEL_FIELD_OBRIGAT, .F.)
            End if
        next iCx

    OtherWise
EndCase

// NO more oStrF47 adjustemts after next line!
oModel:AddFields("RU06D04_MHEAD", NIL, oStrF47 )
oModel:GetModel("RU06D04_MHEAD"):SetDescription(STR0001) // Payment Requests
oModel:GetModel("RU06D04_MHEAD"):SetFldNoCopy({'F47_FILIAL','F47_IDF47','F47_CODREQ','F47_DTREQ','F47_PAYORD','F47_DTPAYM','F47_STATUS'})

// Items structure - F48 Payment Request - Lines
oStrF48 := FWFormStruct(1, "F48")
oStrF48:AddField("CheckBox", "CheckBox", "F48_CHECK", "L", 1, /*[ nDecimal ]*/,{|| RU06D0404_CheckBoxValid()}, {|| RU06XFUN25_CheckBoxWhen("F48")}/*[ bWhen ]*/,;
/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/, .F./*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
oStrF48:SetProperty("F48_CHECK"	,MODEL_FIELD_INIT,{|| F48->F48_RATUSR== "1"})
//Please remove it o R10 and put this in ditionary
oStrF48:SetProperty("F48_BSVATC"  , MODEL_FIELD_WHEN   , {|| .T. })
oStrF48:SetProperty("F48_VLVATC"  , MODEL_FIELD_WHEN   , {|| .T. })

Do Case
    Case cOPerTp == '6'
        oStrF48:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
    OtherWise
EndCase 

oModel:AddGrid("RU06D04_MLNS", "RU06D04_MHEAD", oStrF48)
oModel:GetModel("RU06D04_MLNS"):SetDescription(STR0017) // Payment Request Items
oModel:GetModel('RU06D04_MLNS'):SetOptional(.T.)
oModel:SetRelation( "RU06D04_MLNS", { { "F48_FILIAL", "xFilial('F48')" }, { "F48_IDF48", "F47_IDF47" } }, F48->( IndexKey( 1 ) ) ) //fix bag filial 
oModel:GetModel("RU06D04_MLNS"):SetUniqueLine({"F48_FILIAL","F48_IDF48","F48_PREFIX","F48_NUM","F48_PARCEL","F48_TYPE"})
oModel:GetModel("RU06D04_MLNS"):SetFldNoCopy({'F48_FILIAL', 'F48_IDF48', 'F48_PREFIX', 'F48_NUM', 'F48_PARCEL', 'F48_TYPE', 'F48_CLASS', 'F48_EMISS', 'F48_REALMT',;
                                            'F48_VALREQ', 'F48_VALREQ', 'F48_VALUE', 'F48_CURREN', 'F48_CONUNI', 'F48_VLCRUZ', 'F48_OPBAL', 'F48_BSIMP1', 'F48_ALIMP1',;
                                            'F48_VLIMP1', 'F48_MDCNTR', 'F48_FLORIG', 'F48_EXGRAT', 'F48_VALCNV','F48_BSVATC','F48_VLVATC','F48_RATUSR'})

oModel:InstallEvent("Name"	,,oUpdF47Event)

Return (oModel)


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition.
@author natalia.khozyainova
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()
Local oView 	    as Object
Local oModel 	    as Object
Local oStrF47 	    as Object
Local oStrF48 	    as Object
Local cBoxName      as Char
Local cFilName      as Char
Local aRmvFields    as Array
Local aRmvFldEx     as Array
Local aCurFldSt     as Array
Local aFldBlg       as Array
Local nICnt         as numeric

//Check if varible type movement exists, avoid error.log execview
If Type('cOperTp') == 'U'
    cOperTp := '1' //default payment to supplier
ElseIf Type('cOperTp') == 'C' .and. Empty(cOperTp)//View/update/
    cOperTp := F47->F47_REQTYP
EndIf

// **************************************************
// Common area setup without current specific cOperTp
// **************************************************
aRmvFields := {}
aRmvFldEx := {}
aCurFldSt := {}
oModel := FWLoadModel("RU06D04")
cBoxName:=RetTitle("F48_RATUSR")
cFilName:=RetTitle("F48_FILIAL")

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetAfterViewActivate({|oView| RUD604SBrw(oView) })

// Header structure - F47 Payment Request - Header
oStrF47 := FWFormStruct(2, "F47")
oStrF47:RemoveField("F47_IDF47")
oStrF47:RemoveField("F47_VRSN")
oStrF47:RemoveField("F47_F5QUID")
oStrF47:AddField("F47_FILIAL", "01", cFilName, "VirtFilial", {}, "C", "@!", {|| xFilial("F47")}, "", .F., "1","003" , , , , .T., , , )

if cOperTp == '1' .Or. cOperTp == '3'
    oStrF47:SetProperty("F47_BNKCOD", MVC_VIEW_LOOKUP, "FIL")
    oStrF47:SetProperty('F47_RECNAM', MVC_VIEW_TITULO, STR0125)
Endif

oView:AddField("RU06D04_VHEAD", oStrF47, "RU06D04_MHEAD")

//Items should be removed when we add Payment type for budget = 3
//Diferent than Payment to Budget, Transfers between bank accounts = 6
If cOperTp <> '3' .And. cOperTp <> '6' 
    // Items structure - F48 Payment Request - Lines
    oStrF48 := FWFormStruct(2, "F48")
    oStrF48:RemoveField("F48_IDF48")
    oStrF48:RemoveField("F48_RATUSR")
    oStrF48:RemoveField("F48_UUID")
    oStrF48:AddField("F48_CHECK", "01", cBoxName, "CheckBox", {}, "L", "", , "", .T., "","" , , , , .T., , , )

    oView:AddGrid("RU06D04_VLNS", oStrF48, "RU06D04_MLNS" )
    oView:SetViewProperty("RU06D04_VLNS", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06XFUN24_2Click(oFormula, cFieldName, nLineGrid, nLineModel )}})

    oView:CreateHorizontalBox('SUPERIOR', 70)
    oView:CreateHorizontalBox('INFERIOR', 30)

    oView:SetOwnerView('RU06D04_VHEAD','SUPERIOR')
    oView:SetOwnerView('RU06D04_VLNS','INFERIOR')
    oView:SetNoInsertLine('RU06D04_VLNS')

    //Remove fields related payment to budgget
    aRmvFields := {"F47_TAX", "F47_CFGCOD"}
Endif
// next fields only for 'Transfers between bank accounts' document: 
if cOperTp <> '6'
    aRmvFldEx := {"F47_RCVBNK", "F47_RCVBIK", "F47_RCVACC", "F47_RCVNAM", "F47_RCVCLS"}
    aAddEx(aRmvFields, aRmvFldEx)
Endif

// ************************************
// Separates setup for specific cOperTp
// ************************************
Do Case
    Case cOperTp == '3'     //Payment to Budget
        aRmvFldEx := {"F47_PREPAY", "F47_CNT", "F47_F5QDES", "F47_CTPRE" , "F47_CCPRE" , "F47_ITPRE" , "F47_CLPRE"}
        aAddEx(aRmvFields, aRmvFldEx)
        oStrF47:SetProperty("F47_VALUE", MVC_VIEW_FOLDER_NUMBER , "1") //Move Value to general folder (folder values are hidden at function RUD604SBrw)        
    
    Case cOperTp == '6'     //Transfers between bank accounts
        aRmvFldEx := {"F47_TAX", "F47_CFGCOD", "F47_SUPP", "F47_UNIT", "F47_SUPNAM", ;
                        "F47_PREPAY", "F47_TYPCC", "F47_BKNAME", "F47_ACNAME", "F47_CNT", ;
                        "F47_VATCOD", "F47_VATAMT", "F47_VATRAT", "F47_REGNUM", "F47_BCC", ;
                        "F47_OKTMO", "F47_PAYSTA", "F47_PSDESC", "F47_PAYBAS", "F47_PBDESC", ;
                        "F47_UIP", "F47_TAXPER", "F47_CUSOFF", "F47_NTAXDC", "F47_F5QDES", ;
                        "F47_CTPRE", "F47_CCPRE", "F47_ITPRE", "F47_CLPRE", "F47_DTTXDC"} 
        aAddEx(aRmvFields, aRmvFldEx)
        //field's properties (from sx3) will be reassigned dynamically:
        RU06D04203(oStrF47)        
        // Folders are going to hide (by removing all fields from its):
        aCurFldSt := oStrF47:GetFields()   // :AFIELDS
        aFldBlg := {}
        For nICnt := 1 To Len(aCurFldSt)
            if aCurFldSt[nICnt][11] $ "2|3|4|6"
                AADD(aFldBlg, aCurFldSt[nICnt][1])
            EndIf
        next nICnt

        aAddEx(aRmvFields, aFldBlg)

EndCase


/*Hide fields-------------------------------------------------------------------*/
RU06D0405_RemoveStructFields(oStrF47, aRmvFields)
/*-------------------------------------------------------------------Hide fields*/

oView:SetCloseOnOk({|| .T. })

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0405_RemoveStructFields
Function to remove transfered list of fields from transfered form data model instance
@author rafael.goncalves
@since 25/02/2020
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0405_RemoveStructFields(oFormStruct,aFields)
Local nCnt As Numeric

If !Empty(aFields)
    For nCnt := 1 to Len(aFields)
        oFormStruct:RemoveField(aFields[nCnt])
    Next nCnt
EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RUD604LGND
this function will show list of colours used for legend (status). See Browse:AddLegend()
@author natalia.khozyainova
@since 05/06/2018
@version 1.0
@project MA3 - Russia
/*/

Function RUD604LGND()
Local aRet as Array
aRet:={}
aAdd(aRet,{ "BR_BRANCO"  , STR0075 }) // White == Created
aAdd(aRet,{ "BR_AMARELO" , STR0076 }) // Yellow == Included in PO
aAdd(aRet,{ "BR_VERDE"   , STR0077 }) // Green == Payed
If  SuperGetMv("MV_REQAPR",,"")  = 1
    aAdd(aRet,{ "BR_AZUL "   , STR0078 }) // Blue == Approved
    aAdd(aRet,{ "BR_VERMELHO", STR0079 }) // Red == Rejected
Endif

BrwLegenda(cCadastro,STR0083, aRet) // Legend

Return (aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} R0604TypR
This function will show small screen to choose payment type
@author natalia.khozyainova
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Function R0604TypR()
Local aArea     as Array
Local aPayTypes as Array
Local cPayType  as Char
Local oDlg      as Object
Local oCbx      as Object
Local nOpca     as Numeric

aArea := GetArea()
nOpca := 1
cPayType :=''

If nModulo == 6    
    If !isBlind() // this if is for automated test or other auto mode
        aPayTypes:= {}
        AADD(aPayTypes,STR0010) //1 - payments to supplier
        AADD(aPayTypes,STR0011) //2 -
        AADD(aPayTypes,STR0012) //3 - payments to Budget
        AADD(aPayTypes,STR0013) //4 -
        AADD(aPayTypes,STR0014) //5 -
        AADD(aPayTypes,STR0015) //6 - transfers between bank accounts 
        AADD(aPayTypes,STR0016) //7 - other

        DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE RetTitle("F47_REQTYP") PIXEL
        @ 10,17 Say RetTitle("F47_REQTYP") SIZE 150,7 OF oDlg PIXEL
        @ 27,07 TO 72, 140 OF oDlg  PIXEL
        @ 35, 10 COMBOBOX oCbx VAR cPayType ITEMS aPayTypes SIZE 120, 27 OF oDlg PIXEL
        DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, RUD604DOK(cPayType, @oDlg))
        DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, RUD604DCnc(@cPayType, @oDlg))
        ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)
    Endif
Else
    cPayType := '1'
Endif
cPayType := LEFT(cPayType,1)
RestArea(aArea)
Return (cPayType)

/*/{Protheus.doc} RUD604DOK
it's temporary to check type of request
@author natalia.khozyainova
@since 08/06/2018
@version 1.0
@project MA3 - Russia
/*/
Function RUD604DOK(cPayType, oDlg)

if LEFT(cPayType,1) $ '1|3|6'
    oDlg:End()
Else
    MsgInfo(STR0087)
EndIf
Return (nil)

/*/{Protheus.doc} RUD604DCnc
Close dialog when cancel
@author natalia.khozyainova
@since 08/06/2018
@version 1.0
@project MA3 - Russia
/*/
Function RUD604DCnc(cPayType, oDlg)
cPayType:='0'
oDlg:End()
Return (nil)

/*/{Protheus.doc} RUD604SBrw
this function will prevent Viewdef from opening after Cancel on PAYTYPE
@author eduardo.flima
@since 08/06/2018
@version 1.0
@project MA3 - Russia
/*/
Function RUD604SBrw(oView)
Local lRet:= .T.
Local oModel as Object

lRet := !(FwFldGet("F47_REQTYP") == '0' )
oModel:=oView:GetModel()

If !lRet
    oView:lModify := .F.
    oView:BUTTONCANCELACTION()
Else
    RU06D0408_FillVirtFilial(oModel)
    if oModel:IsCopy()
        FilRsn604(.T.)
        oView:Refresh("RU06D04_VHEAD")
    EndIf
Endif

// display view depending on the request type
cReqType := oView:GetModel():GetModel('RU06D04_MHEAD'):GetValue('F47_REQTYP')

Do Case
    Case cReqType == '1'
        oView:HideFolder('RU06D04_VHEAD',2,1)
        oView:SelectFolder('RU06D04_VHEAD',1,1)
    Case cReqType == '3'
        //oView:HideFolder('RU06D04_VHEAD',5,1) Folder accounting should be not hidden / Rafael / 25/02/2020
        oView:HideFolder('RU06D04_VHEAD',4,1) //Hidde totals
        oView:GetViewStruct('RU06D04_VHEAD'):SetProperty('F47_VALUE', 11, "1")
        oView:GetViewStruct('RU06D04_VHEAD'):SetProperty('F47_VALUE', 12, "003")
        oView:SelectFolder('RU06D04_VHEAD',1,1)
    Case cReqType == '6' 
        // all necessary movements were done in ViewDef       
EndCase

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D0410_Act
all actions, called from Main Menu
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------

Function RU06D0410_Act(nOperation as Numeric)
Local aArea     as Array
Local lRet      as Logical
Local lCheck     as Logical
Local cStatus   as Char
Local cPayord   as Char
Local cOper     as Char

lRet:=.T.
lCheck:=.T. //.F. means thst payment requests are included in the payment list
aArea:=GetArea()
cStatus:=F47->F47_STATUS
cPayord:=F47->F47_PAYORD
lCheck := RU06D0416_CheckPayLists() //The program checks if requests are not included in the list of payments.
cOperTp     := '' //reset global type
if nOperation == MODEL_OPERATION_DELETE
     cOper:= STR0005
    If ALLTRIM(cPayord)!=''
        Help("",1,STR0001,,STR0042+cPayord+STR0043,1,0,,,,,,/*{'str - solution'}*/) //this PR is included to PO# -- Therefore it can not be deleted
        lRet := .F.
    EndIf

    If SuperGetMv("MV_REQAPR") == 1 .and. cStatus=='4'
        Help("",1,STR0001,,STR0044,1,0,,,,,,{STR0084}) //This request is approved, it can not be deleted. First Reject it
        lRet := .F.
    EndIf
//If the request is included in the list of payments, the user is immediately informed about it.
    if lCheck
        Help("",1,STR0111,,STR0112,1,0,,,,,,{STR0113})
        lRet := .F.
    EndIf
EndIf

if nOperation==MODEL_OPERATION_UPDATE
    cOper:= STR0004
    If cStatus=='4'
        Help("",1,STR0001,,STR0045,1,0,,,,,,{STR0085}) // This request is approved, can not be updated. First Reject
    EndIf

    if cStatus == '2' .or. cStatus =='3'
        nOperation:=MODEL_OPERATION_VIEW
        cOper:= STR0002
        Help("",1,STR0001,,STR0109,1,0,,,,,,) // This PR is processed with PO, it can not be edited. Will be open for view.
    EndIf

    if lCheck //If the request for payment is in the list of payments
        nOperation:=MODEL_OPERATION_VIEW
        cOper:= STR0002
        Help("",1,STR0111,,STR0112,1,0,,,,,,{STR0114})
    EndIf

EndIf

if nOperation==MODEL_OPERATION_VIEW
    cOper:= STR0002
endIf

If lRet
	FWExecView(cOper,"RU06D04",nOperation,,{|| .T.})
Endif

Return lRet

/*/{Protheus.doc} RU06D04WR
Write lines from MarkBrowse to F48
@param	oTempTable, Object, Link to Temporary table
@param  oMoreDlg, Object, Link to Dialog object
@param cMark, Charcater, mark symbol of selected lines
@author natalia.khozyainova
@since 25/04/2018
@edit astepanov 17 November 2022
@version P12.1.20
@type function
@project	MA3
/*/
Function RU06D04WR(oTempTable, oMoreDlg, cMark)

    Local aInp          as Array
    Local aMLFlds       as Array
    Local aArea         as Array
    Local aF48Lns       as Array
    Local lPrc          as Logical
    Local lNoAddFtLn    as Logical
    Local nX            as Numeric
    Local nModelLLen    as Numeric
    Local nVATRAT       as Numeric
    Local cNaturez      as Character
    Local cForbCo       as Character
    Local cAlias        as Character
    Local cErrMsg       as Character
    Local oModel        as Object
    Local oModelL 		as Object
    Local oModelH 		as Object
    Local xVal

    aArea   := GetArea()
    oModel  := FwModelActive()
    oModelH := oModel:GetModel("RU06D04_MHEAD")
    oModelL := oModel:GetModel("RU06D04_MLNS")

    aMLFlds := ACLONE(oModelL:GetStruct():GetFields())
    lNoAddFtLn := oModelL:IsEmpty()
    aF48Lns := {}
    aInp := RU06XFUN45_RetF5MnVrtLnsFromAPs(oTempTable,cMark,oModelH:GetValue("F47_DTPLAN"),oModelH)
    cErrMsg := aInp[2]
    If !Empty(cErrMsg) //cErrMsg
        lPrc    := .F.
    Else
        cAlias := aInp[1]:GetAlias()
        DBSelectArea(cAlias)
        DbGoTop()
        lPrc := .T.
    EndIf
    oModelL:SetNoInsertLine(.F.)
    While lPrc .AND. (cAlias)->(!EoF())  //process sql query result and put data to F48 grid
        lPrc        := .F.
        nModelLLen  := oModelL:Length()
        If lNoAddFtLn .OR. nModelLLen < oModelL:AddLine() //add line to F48 grid
            For nX := 1 To Len(aMLFlds)
                    xVal := (cAlias)->&(aMLFlds[nX][3])
                    oModelL:LoadValue(aMLFlds[nX][3], xVal)
            Next nX
            AADD(aF48Lns,oModelL:GetLine())
            lPrc := .T.
        Else
            lPrc := .F.
        EndIf
        lNoAddFtLn := .F.
        IIF(Empty(nVATRAT)  .AND. !Empty((cAlias)->F48_ALIMP1), nVATRAT  := (cAlias)->F48_ALIMP1, Nil)
        IIF(Empty(cNaturez) .AND. !Empty((cAlias)->F48_CLASS),  cNaturez := (cAlias)->F48_CLASS , Nil)
        IIF(Empty(cForbCo)  .AND. !Empty((cAlias)->E2_FORBCO),  cForbCo  := (cAlias)->E2_FORBCO , Nil)
        RU06XFUN27_GridSortAPs(oModelL,"F48")
        (cAlias)->(DBSkip())
    EndDo
    If lPrc .AND. Empty(oModelH:GetValue("F47_VATRAT"))
        oModelH:LoadValue("F47_VATRAT" ,nVATRAT)
    EndIf
    If lPrc .AND. Empty(oModelH:GetValue("F47_CLASS"))
        oModelH:LoadValue("F47_CLASS"  ,cNaturez)
    EndIf
    If lPrc .AND. (Empty(oModelH:GetValue("F47_BNKCOD")) .OR. !(oModelH:GetValue("F47_BNKCOD") == cForbCo))
        R604PutFil(cForbCo)
    EndIf
    oModelL:SetNoInsertLine(.T.)
    If !lPrc
        If Empty(cErrMsg)
            // If there are some problems with line adding
            // delete all added lines and show help message
            For nX := 1 To Len(aF48Lns)
                oModelL:GoLine(aF48Lns[nX])
                oModelL:DeleteLine()
            Next nX
            cErrMsg := cValToChar(oModelL:Length() + 1)
        EndIf
        HELP("", 1, STR0001, ,; //Payment request; err on ln
                cErrMsg,;
                1,0,,,,,,                  )
    EndIf
    R0604VAL(.T.) // Recalculate Totals //(19/11/2019): force recalculation
    If !Empty(cAlias)
        (cAlias)->(DBCloseArea())
        aInp[1]:Delete()
    EndIf
    If !Empty(oMoreDlg)
        oMoreDlg:End()
    EndIf
    RestArea(aArea)

Return (lPrc)

/*/{Protheus.doc} R0604VAL
This function calculate F47_VALUE and F47_VATAMT from Lines
@author natalia.khozyainova
@since 10/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function R0604VAL(lForce as Logical,nLine as Numeric, cAction as Char)
Local nVal as Numeric
Local nVat as Numeric
Local oModel as Object
Local oModelF47 as Object
Local oModelF48 as Object
Local oView as Object
Local oViewHead as Object
Local nX as Numeric

Default lForce:=.F.
Default nLine:=0
Default cAction:=''

oModel:=FWModelActive()
oModelF47:=oModel:GetModel("RU06D04_MHEAD")
oModelF48:=oModel:GetModel("RU06D04_MLNS")

oView := FwViewActive()
    If lForce .or. !(lUserValue)
        nVal:=0
        nVat:=0

        for nX:=1 to oModelF48:Length()
            if !(nX==nLine .and. cAction='DELETE')
                oModelF48:GoLine(nX)
                if !(oModelF48:IsDeleted()) .or. (nX==nLine .and. cAction='UNDELETE')
                    If !Empty("F48_VALREQ")
                        nVal+=oModelF48:GetValue("F48_VALCNV")
                    EndIf
                    If !Empty("F48_VLIMP1")
                        nVat+=oModelF48:GetValue("F48_VLVATC")
                    EndIf
                Endif
            EndIf
        Next nX

        oModelF47:SetValue("F47_VALUE",nVal)
        oModelF47:SetValue("F47_VATAMT",nVat)
        FilRsn604(.F.,nLine,cAction)
    EndIf

    If !Empty(oView) .and. oView:GetModel():GetId()=="RU06D04"
        oViewHead := oView:GetViewObj("RU06D04_VHEAD")[3]
        If !Empty(oViewHead)
            oViewHead:Refresh(.T.,.F.)
        EndIf
    EndIf

    if nLine>0
        oModelF48:GoLine(nLine)
    EndIf

Return (NIL)

/*/{Protheus.doc} R0604RCalc
Called from Button - Recalculate Totals
@type function
@author natalia.khozyainova
@since 12/05/2017
@version 1.0
/*/
Static Function R0604RCalc()
If FwFldGet("F47_PREPAY")!="1"
    If MsgYesNo(STR0040,STR0041) // Totals will be recalculated. Continue? -- Recalculate
        R0604VAL(.T.)
        lUserValue:=.F.
    EndIf
Else
    Help("",1,STR0080,,STR0081,1,0,,,,,,{STR0087})//can not recalculate prepayment
EndIf
Return (NIL)

//-----------------------------------------------------------------------
/*/{Protheus.doc} R604ViwApr
Approve One, called from Main Menu
@author eduardo.flima
@since 11/05/2018
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------

Function R604ViwApr(nNum)
// 1 = approve
// 2 = reject
Local aEnableButtons as array
Local bOk as block
Local lRet as Logical
Local lInListReq as Logical
Local cButtonName as Character
Local cTitleName as Character
Local cStatus as Character
Local cPayOrd as Character

If nNum <> nil
    lInListReq := RU06D0416_CheckPayLists() //if the request is included in the list of payments.
    cStatus := F47->F47_STATUS
EndIf
If nNum==1
    cButtonName:=STR0070 // Approve
    cTitleName := STR0060 //Payment Request - Approval
    lRet := cStatus $ "1|5" .And. !lInListReq //Payment Request could be approve only if its status is created or rejected
Elseif nNum==2
    cButtonName := STR0071 // Reject
    cTitleName  := STR0115   // Payment Request - Rejection
    lRet   := cStatus $ "1|4" .And. !lInListReq //Payment Request could be reject only if its status is created or approved
Endif
If lRet
    aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,cButtonName},{.T.,STR0027},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //Hide the standart options of the Form
    bOk          	:= {|| lRet := IIf(nNum==1,R0604Apr(), R0604DApr()) }
    lRet         	:= FWExecView(cTitleName , "RU06D04", MODEL_OPERATION_UPDATE, /*oDlg*/,/*/ {|| .T. }/*/ ,bOk , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ ) // PR - Approe
ElseIf lInListReq .And. Empty(cPayOrd)
    Help("",1,STR0111,,STR0114,1,0,,,,,,/*solution*/) //This request is included in the list of payments. //Delete the request from the list or cancel the list of payments
Else
    Help("",1,STR0001,, STR0116,1,0,,,,,,/*{'str - solution'}*/) //This operation is not allowed. Check status of the payment request
EndIf
Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} R0604Apr
Approve One, called from R604ViwApr
@author eduardo.flima
@since 04/05/2018
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------
Function R0604Apr()
Local oModel as Object
Local oModelH as Object
Local cStatus as Char
Local lRet as Logical

oModel:=FWLoadModel("RU06D04")
oModel:SetOperation( 4 )
oModel:Activate()
oModelH:=oModel:GetModel("RU06D04_MHEAD")
cStatus:=oModelH:GetValue('F47_STATUS')

lRet :=.F.
If cStatus !='4'
    lRet:= MsgYesNo(STR0048+Alltrim(oModelH:GetValue("F47_CODREQ"))+'?',STR0046) // Approve?
    If lRet
        FwFldPut('F47_STATUS','4',,,,.T.)
        If oModel:VldData()
            oModel:CommitData()
        Else
            Help("",1,STR0046,,STR0049,1,0,,,,,,{STR0088}) // Not Validated
        EndIf
        oModel:DeActivate()
        //----------------------------------------------------------------------------------
        // Treatment to allow confirmation without the confirmation help
        //----------------------------------------------------------------------------------
        oView	:= FWViewActive()
        oView:lModify := .T.
        oView:oModel:lModify := .T.
        //----------------------------------------------------------------------------------
        // Treatment to Show the approval MSG confirmation
        //----------------------------------------------------------------------------------
        oView:ShowUpdateMsg(.T.)
        oView:SetUpdateMessage(STR0046, STR0061) // Approval -- Aproved
    Endif
Else
   Help("",1,STR0046,,STR0047,1,0,,,,,,/*{'str - solution'}*/) // Approve request - already approved
EndIf

oModel:DeActivate()

Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} R0604Dapr
Reject One, called from Main Menu
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------
Function R0604Dapr()
Local oModel as Object
Local oModelH as Object
Local cStatus as Char
Local lRet as Logical

oModel:=FWLoadModel("RU06D04")
oModel:SetOperation( 4 )
oModel:Activate()
oModelH:=oModel:GetModel("RU06D04_MHEAD")
cStatus:=oModelH:GetValue('F47_STATUS')

lRet :=.F.

If cStatus=='4'
    lRet:= MsgYesNo (STR0051+Alltrim(oModelH:GetValue("F47_CODREQ"))+"?",STR0050)// Do you confirm? -- Reject
    If lRet
        FwFldPut('F47_STATUS','5',,,,.T.)
        If oModel:VldData()
            oModel:CommitData()
        Else
           Help("",1,STR0050,,STR0049,1,0,,,,,,{STR0088}) // Validation failed
        EndIf
        oModel:DeActivate()
        //----------------------------------------------------------------------------------
        // Treatment to allow confirmation without the confirmation help
        //----------------------------------------------------------------------------------
        oView	:= FWViewActive()
        oView:lModify := .T.
        oView:oModel:lModify := .T.
        //----------------------------------------------------------------------------------
        // Treatment to Show the approval MSG confirmation
        //----------------------------------------------------------------------------------
        oView:ShowUpdateMsg(.T.)
        oView:SetUpdateMessage(STR0050, STR0062 ) // Rejection -- Request Rejected!
    Endif
Else
   Help("",1,STR0050,,STR0052,1,0,,,,,,/*{'str - solution'}*/) // not aaproved yet
EndIf

oModel:Deactivate()

Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} R604VldVRq
This Function checks if balance of the bill is ok in all open requests
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------
Function R604VldVRq()
Local lRet as Logical
Local nPos as Numeric
lRet:=RU06XFUN20_VldValPay(@nPos)
If lRet
    RU06D0403_RecalcRubls(.F.)
EndIf
Return (lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} RUD604GRUP
Approve/Reject reqests in group - set Group of questions parameters
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------
Function RUD604GRUP(nType as Numeric)
// nType = 1 Approuve in Group
// nType = 2 Reject in Group
Local cPerg as Char
Local lRet as Logical
Local oModel as Object

Default nType:=0

oModel:= FWModelActive()
cPerg := "RUD604G"

If nType == 1
    SetMVValue(cPerg,"MV_PAR13", 1)
EndIf

If nType == 2
    SetMVValue(cPerg,"MV_PAR13", 4)
EndIf

lRet:= Pergunte(cPerg,.T.,STR0053+If(nType == 1, STR0054, STR0055),.F.) // select PRs for -- Approve -- Reject
If lRet
    RUD604PQsBRW(nType) // MarkBrowse is here
Endif

Return (lRet)


//-----------------------------------------------------------------------
/*/{Protheus.doc} RUD604PQsBRW
Approve/Reject reqests in group - markbrowse
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
//-----------------------------------------------------------------------
Function RUD604PQsBRW(nType as Numeric)
Local aSize     as Array
Local aStr      as Array // Structure to show
Local aColumns  as Array
Local nX        as Numeric
Local cTitle    as Char

Private oPQDlg    as object
Private oBrowsePut  as object
Private oTmpPQs  as Object
Private cTmpPQs    as Char
Private cMark   as Char

aSize	:= MsAdvSize()
nX:=0
cTmpPQs	:= CriaTrab(,.F.)
aStr	:= {}
aColumns 	:= {}
cTitle:=""

// Create temporary table
MsgRun(STR0021,STR0022,{|| PQCreaTRB()}) //"Please wait"//"Creating temporary table"

iF ((cTmpPQs)->(Eof()))
    Help("",1,STR0056,,STR0057,1,0,,,,,,{STR0025})
Else
    aAdd( aStr, {"F47_FILIAL"	,RetTitle("F47_FILIAL"), PesqPict("F47","F47_FILIAL")})
    aAdd( aStr, {"F47_CODREQ"  	,RetTitle("F47_CODREQ"), PesqPict("F47","F47_CODREQ")})
    aAdd( aStr, {"F47_DTREQ"	,RetTitle("F47_DTREQ"), PesqPict("F47","F47_DTREQ")})
    aAdd( aStr, {"F47_DTPLAN"	,RetTitle("F47_DTPLAN"), PesqPict("F47","F47_DTPLAN")})
    aAdd( aStr, {"F47_SUPP"	    ,RetTitle("F47_SUPP"), PesqPict("F47","F47_SUPP")})
    aAdd( aStr, {"F47_VALUE"	,RetTitle("F47_VALUE"), PesqPict("F47","F47_VALUE")})
    aAdd( aStr, {"F47_CURREN"  	,RetTitle("F47_CURREN"), PesqPict("F47","F47_CURREN")})
    aAdd( aStr, {"F47_VRSN"  	,RetTitle("F47_REASON"), "@"})

    For nX := 1 TO  8
        cTitle:=aStr[nX][1]
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStr[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStr[nX][2])

        if cTitle!="F47_VRSN"
            aColumns[Len(aColumns)]:SetSize(TamSx3(cTitle)[1])
            aColumns[Len(aColumns)]:SetDecimal(TamSx3(cTitle)[2])
        Else
            aColumns[Len(aColumns)]:SetSize(TamSx3("F47_REASON")[1])
            aColumns[Len(aColumns)]:SetDecimal(TamSx3("F47_REASON")[2])
        EndIf

        aColumns[Len(aColumns)]:SetPicture(aStr[nX][3])

    Next nX

    oPQDlg := MsDialog():New( aSize[7], aSize[2], aSize[6], aSize[5], STR0082, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // APs

    //MarkBrowse
    oBrowsePut := FWMarkBrowse():New()
    oBrowsePut:SetFieldMark("PQ_OK")
    oBrowsePut:SetOwner(oPQDlg)
    oBrowsePut:SetAlias(cTmpPQs)
    aRotina	 := RUD604GrMen(nType) //Reset global aRotina
    oBrowsePut:SetMenuDef("RUD604GrMen")
    oBrowsePut:SetColumns(aColumns)
    oBrowsePut:SetClrAlterRow(2)
    oBrowsePut:DisableReport()
    oBrowsePut:bAllMark := {||RU06XFUN16_MarkAll(oBrowsePut, cTmpPQs,"PQ_OK")}
    oBrowsePut:Activate()
    cMark := oBrowsePut:Mark()

    oPQDlg:Activate(,,,.T.,,,)

    If !Empty (cTmpPQs)
        dbSelectArea(cTmpPQs)
        dbCloseArea()
        cTmpPQs := ""
        dbSelectArea("F47")
        dbSetOrder(1)
    EndIf

    If oTmpPQs <> Nil
        oTmpPQs:Delete()
        oTmpPQs := Nil
    Endif
EndIf

aRotina	 := MenuDef() //Return aRotina
Return (.T.)

/*/{Protheus.doc} PQCreaTRB
Tmp table for approve/reject in group markbrowse
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
Static Function PQCreaTRB()
Local aFields   as Array
Local cQuery    as Char
Local cInsFlds  as Char
Local cSlcFlds  as Char
Local nX        as Numeric

/* Object creation*/
oTmpPQs := FWTemporaryTable():New(cTmpPQs)

// Table fields - structure
aFields := {}
aadd(aFields,{"PQ_OK"		, "C", 1,   00})		//
aadd(aFields,{"F47_FILIAL"	, "C", TamSX3("F47_FILIAL")[1], 00})
aadd(aFields,{"F47_PAYTYP"	, "C", TamSX3("F47_PAYTYP")[1], 00})
aadd(aFields,{"F47_CODREQ"	, "C", TamSX3("F47_CODREQ")[1], 00})
aadd(aFields,{"F47_DTREQ"	, "D", TamSX3("F47_DTREQ")[1],  00})
aadd(aFields,{"F47_DTPLAN"	, "D", TamSX3("F47_DTPLAN")[1],  00})
aadd(aFields,{"F47_SUPP"	, "C", TamSX3("F47_SUPP")[1],   00})
aadd(aFields,{"F47_VALUE"	, "N", TamSX3("F47_VALUE")[1],  00})
aadd(aFields,{"F47_PRIORI"	, "C", TamSX3("F47_PRIORI")[1], 00})
aadd(aFields,{"F47_CURREN"  , "C", TamSX3("F47_CURREN")[1], 00})
aadd(aFields,{"F47_VRSN"	, "C", TamSX3("F47_REASON")[1], 00})


oTmpPQs:SetFields(aFields)
oTmpPQs:AddIndex("Indice2", {"F47_FILIAL", "F47_CODREQ"} )

// Table fields - data
cInsFlds := ""
cSlcFlds := ""
For nX := 1 To Len(aFields)
    cInsFlds += aFields[nX][1]+","
    If     aFields[nX][1] == "PQ_OK"
        cSlcFlds += " '0' AS PQ_OK,"
    ElseIf aFields[nX][1] == "F47_VRSN"
        cSlcFlds += " '' AS F47_VRSN,"
    Else
        cSlcFlds += aFields[nX][1]+","
    EndIf
Next nX
cInsFlds := SubStr(cInsFlds,1,Len(cInsFlds)-1)
cSlcFlds := SubStr(cSlcFlds,1,Len(cSlcFlds)-1)

oTmpPQs:Create()
cQuery := "INSERT INTO " + oTmpPQs:GetRealName() + " (" + cInsFlds + ") "
cQuery += " SELECT " + cSlcFlds + " "
cQuery += " FROM " + RetSQLName("F47") + " F47 "
cQuery += " INNER JOIN " + RetSQLName("CTO") + " CTO ON (F47_CURREN=CTO_MOEDA AND CTO_FILIAL = '" + xFILIAL("F47",CTO->CTO_FILIAL) + "') "
cQuery += " WHERE F47.D_E_L_E_T_ =' ' "
cQuery += " AND F47_FILIAL BETWEEN '" + MV_PAR01  + "' AND '" + MV_PAR02 +"'"
cQuery += " AND F47_PAYTYP BETWEEN '" + MV_PAR03  + "' AND '" + MV_PAR04 +"'"
cQuery += " AND F47_CODREQ BETWEEN '" + MV_PAR05  + "' AND '" + MV_PAR06 +"'"
cQuery += " AND F47_DTPLAN BETWEEN '" + DTOS(MV_PAR07)  + "' AND '" + DTOS(MV_PAR08) +"'"
cQuery += " AND F47_SUPP BETWEEN '" + MV_PAR09  + "' AND '" + MV_PAR11 +"'"
cQuery += " AND F47_UNIT BETWEEN '" + MV_PAR10  + "' AND '" + MV_PAR12 +"'"
cQuery += " AND F47_STATUS = '" + ALLTRIM(STR(MV_PAR13))  +  "'"
cQuery += " AND TRIM(F47_PAYORD) = '' "
If MV_PAR14==1
    cQuery += " AND F47_CURREN = '" + MV_PAR15  +  "'"
Endif

nStatus := TCSqlExec(cQuery)

DbSelectArea(cTmpPQs)
DbGotop()

While (cTmpPQs)->(!EOF())
    (cTmpPQs)->F47_VRSN := Posicione("F47",1,(cTmpPQs)->F47_FILIAL+(cTmpPQs)->F47_CODREQ,"F47_REASON")
    (cTmpPQs)->(DBSkip())
Enddo
DbGotop()

Return (NIL)


/*/{Protheus.doc} RUD604GrMen
Menu for approve/reject in group markbrowse
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
static Function RUD604GrMen(nType)
Local aRet as Array
Local cBtnOk as Char

if nType==1
    cBtnOk := STR0008
Elseif nType==2
    cBtnOk := STR0009
Else
    cBtnOk:=STR0064
End

aRet := {{cBtnOk,  "RU06D04GWR("+str(nType)+")", 0, 4, 0, Nil},;// OK
		{STR0027,   "RU06D04GCL()", 0, 1, 0, Nil},;             // Cancel
        {STR0065,"R0604ShwPR()",0,1,0,NIL}}                     // View request
Return (aRet)

/*/{Protheus.doc} RU06D04GCL
Close approve/reject in group markbrowse
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
Function RU06D04GCL()
oPQDlg:End()
Return .F.


/*/{Protheus.doc} RU06D04GWR
Approve/reject in group markbrowse - update selected PRs
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
Function RU06D04GWR(nType as Numeric)
// 1 == approve
// 2 == reject
Local aArea as array
Local aAreaF47 as Array

aArea := (cTmpPQs)->(GetArea())
DbGotop()
while !((cTmpPQs)->(Eof()))
	If ((cTmpPQs)->PQ_OK == cMark)
        lDbSeek:=.F.	// this variable shows if record already exists (then update) or not (then create)
        aAreaF47 := F47->(GetArea())
        F47->(dbSetOrder( 1 ))
        lDbSeek := F47->(DbSeek( (cTmpPQs)->F47_FILIAL+(cTmpPQs)->F47_CODREQ) )
        If lDbSeek
            RecLock("F47",!(lDbSeek)) // update or create
            F47->F47_STATUS	:= If(nType==1,'4','5')
        EndIf
    EndIf
	(cTmpPQs)->(DbSkip())
Enddo
oPQDlg:End()
RestArea(aArea)
Return (NIL)


/*/{Protheus.doc} R0604ShwPR
Called from Menu in markbrowse - option to see details of Payment Request
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
Function R0604ShwPR()
Local aEnableButtons as Array
Local aArea as Array
Local cKey as Char

aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0027},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //Hide the standart options of the Form
aArea := (cTmpPQs)->(GetArea())
cKey:=(cTmpPQs)->F47_FILIAL+(cTmpPQs)->F47_CODREQ
RestArea(aArea)

dbSelectArea("F47")
F47->(DbSetOrder(1))
If F47->(DbSeek(cKey))
   FWExecView( STR0001 , "RU06D04", MODEL_OPERATION_VIEW, /*oDlg*/,/*/ {|| .T. }/*/ ,/*bOk*/ , /*nPercReducao*/, aEnableButtons, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,/* oModel*/ )
EndIf
DbCloseArea()

Return (nil)

/*/{Protheus.doc} R0604ShwBl
Called from Menu in markbrowse - option to see details of Bill
@author natalia.khozyainova
@since 04/05/2018
@version P12.1.21
@type function
/*/
Function R0604ShwBl()
Local aArea as Array
Local cKey as Char

aArea := (cTempTbl)->(GetArea())
cKey:=(cTempTbl)->E2_FILIAL+(cTempTbl)->E2_PREFIXO + (cTempTbl)->E2_NUM +(cTempTbl)->E2_PARCELA+ (cTempTbl)->E2_TIPO + (cTempTbl)->E2_FORNECE + (cTempTbl)->E2_LOJA
RestArea(aArea)

dbSelectArea("SE2")
SE2->(DbSetOrder(1))
If SE2->(DbSeek(cKey))
    AxVisual('SE2',SE2->(RecNo()),2,,4,SA2->A2_NOME,"FA050MCPOS",FA050BAR('SE2->E2_PROJPMS == "1"')   )
EndIf
DbCloseArea()

Return (nil)


//______________________________________________________________________________
//
// HERE ALL THE VALIDATION FUNCTION CALLED FROM DB ARE
//______________________________________________________________________________


/*/{Protheus.doc} R604RetSe2
This function links values for virtual fields.
It is called from sx3_relacao of fields, nField parameter defines which field
@author eduardo.flima
@since 17/04/2018
@edit astepanov 09 October 2020
@version 1.0
@project MA3 - Russia
/*/
Function R604RetSe2(nField,cTable)

Local aSaveArea as Array
Local aKeys     as Array
Local cKey      as Char
Local cKeyF5M   as Char
Local cAlias    as Char
Local cUUID     as Char
Local xRet

Default cTable:='F48'
Default nField  := 1
aSaveArea   := GetArea()
If cTable=="F48"
    aKeys   := RetSE2Key(cTable)
    cKey    := aKeys[1]
    cKeyF5M := aKeys[2]
    cAlias  :="F48"
    cUUID   :=F48->F48_UUID
ElseIf cTable== "F4B"
    aKeys   := RetSE2Key(cTable)
    cKey    := aKeys[1]
    cKeyF5M := aKeys[2]
    cAlias  :="F4B"
    cUUID   :=F4B->F4B_UUID
EndIf

If nField == 1 .and. ValType(cKey)='C' //  F48_CLASS
        xRet := Posicione("SE2",1,cKey,"E2_NATUREZ")
    ElseIf nField == 2 .and. ValType(cKey)='C' // F48_EMISS
        xRet := Posicione("SE2",1,cKey,"E2_EMISSAO")
    ElseIf nField == 3 .and. ValType(cKey)='C' // F48_REALMT
        xRet := Posicione("SE2",1,cKey,"E2_VENCREA")
    ElseIf nField == 4 .and. ValType(cKey)='C' 
        xRet := Posicione("SE2",1,cKey,"E2_VALOR") //F4B_VALUE or F48_VALUE
    ElseIf nField == 5 .and. ValType(cKey)='C' // F48_CURREN
        xRet := Posicione("SE2",1,cKey,"E2_MOEDA")
    ElseIf nField == 6 .and. ValType(cKey)='C' // F48_VLCRUZ
        xRet := Posicione("SE2",1,cKey,"E2_VLCRUZ")
    ElseIf nField == 7 .and. ValType(cKey)='C' // F48_BSIMP1
        If      cTable == "F4B"
            xRet := F4B->F4B_VALPAY-F4B->F4B_VLIMP1
        ElseIf  cTable == "F48"
            xRet := F48->F48_VALREQ-F48->F48_VLIMP1
        EndIf
    ElseIf nField == 8 .and. ValType(cKey)='C' // F48_ALIMP1
        xRet := Posicione("SE2",1,cKey,"E2_ALQIMP1")
    ElseIf nField == 9 .and. ValType(cKey)='C' // F48_MDCNTR
        //for _MDCNTR field we get F5QCODE from legal contracts
        xRet := Posicione("SE2",1,cKey,"E2_F5QCODE")
    ElseIf nField == 10 .and. ValType(cKey)='C' // _OPBAL or F4B_VALPAY or F48_VALREQ
        xRet := RU06XFUN06_GetOpenBalance(cKeyF5M)+;
        Posicione("F5M",1,xFilial("F5M")+cAlias+cUUID+cKeyF5M,"F5M_VALPAY")
    Endif
RestArea(aSaveArea)

Return (xRet)

/*/{Protheus.doc} R604VldCur
This function is called from x3_valid of field F47_CURREN
It checks if all Lines and Header of the request have the same currency
It also filles in the currency name F47_CURNAM
@author natalia.khozyainova
@since 10/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function R604VldCur()
Local lRet      as Logical

lRet:= ExistCpo("CTO",FwFldGet("F47_CURREN")) .and. RU06XFUN26_CheckCurrHeadLines()
If lRet
    FwFldPut("F47_CURNAM",POSICIONE("CTO",1,xFilial("CTO")+FwFldGet("F47_CURREN"),"CTO_DESC"),,,,.T.)
    R604PutFil()
Else
    Help("",1,STR0089,,STR0033,1,0,,,,,,{STR0034})
Endif
Return (lRet)


/*/{Protheus.doc} R604ShwFil
This function fullfills F47_TYPECC (nNum=1) and F47_ACCNAME(nNum==2)
with data from table FIL
Called from x3_relacao
@author eduardo.flima
@since 12/11/2018
@version 2.0
@param    Numeric        nNum     //1, 2, 0
          Character      Table Alias (F47 or F6B)
@project MA3 - Russia
/*/
Function R604ShwFil(nNum as Numeric, cAliPos as Character)
Local cRet as Char
Local cSupp    as Character
Local cUnit    as Character
Local cBnkCod  as Character
Local cBik     as Character
Local cAccnt   as Character
Default cAliPos := 'F47'

If cAliPos $ "F6B"
    cSupp   :=&(cAliPos+"->"+cAliPos+"_SUPP")
    cUnit   :=&(cAliPos+"->"+cAliPos+"_UNIT") 
    cBnkCod :=&(cAliPos+"->"+cAliPos+"_BNKCOD") 
    cBik    :=&(cAliPos+"->"+cAliPos+"_BIK")
    cAccnt  :=&(cAliPos+"->"+cAliPos+"_ACCNT")
else
    cSupp   := FwFldGet(cAliPos+"_SUPP")
    cUnit   := FwFldGet(cAliPos+"_UNIT")
    cBnkCod := FwFldGet(cAliPos+"_BNKCOD")
    cBik    := FwFldGet(cAliPos+"_BIK")
    cAccnt  := FwFldGet(cAliPos+"_ACCNT")
Endif
cRet:=RU06XFUN02_ShwFIL(nNum,cSupp,cUnit,cBnkCod,cBik,cAccnt)
Return cRet

/*/{Protheus.doc} R604VldSpl
called from x3_valid of Fields F47_SUPP, F47_UNIT
@author natalia.khozyainova
@since 10/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function R604VldSpl(nField,cTable as Character)
Local lRet as Logical
Local aSaveArea as Array

Default nField := 1
default cTable := 'F47'

aSaveArea := GetArea()

If nField == 1
    lRet := ExistCpo("SA2",FwFldGet(cTable+"_SUPP"))
Else
    lRet := ExistCpo("SA2",FwFldGet(cTable+"_SUPP")+FwFldGet(cTable+"_UNIT"))
Endif

RestArea(aSaveArea)

Return (lRet)

/*/{Protheus.doc} R604PutFil
Function Used to Automaticly Put the FIL table data
@author Eduardo.Flima
@since 23/05/2018
@version 2.0
@project MA3 - Russia
@param cBankAcc   Character   Bank Account from E2 uses for filling bank fields
/*/

Static Function R604PutFil(cBankAcc, cAliPos as Character)
Local lRet as Logical
Local aSaveArea as Array
Local lOk as Logical
Local nCurr as Numeric
Local cKey as Char

Default cBankAcc := ""
Default cAliPos := 'F47'

If cAliPos $ "F6B"
    nCurr   := 1
else
    nCurr   := Val(FwFldGet(cAliPos+"_CURREN"))
Endif

lOk := .F.
aSaveArea := GetArea()

If R604ChkFil(xFilial("FIL"),FwFldGet(cAliPos+"_SUPP"),FwFldGet(cAliPos+"_UNIT"),FwFldGet(cAliPos+"_BNKCOD"),FwFldGet(cAliPos+"_BIK"),FwFldGet(cAliPos+"_ACCNT"),str(nCurr), cAliPos )
    cKey:=xFilial("FIL")+FwFldGet(cAliPos+"_SUPP")+FwFldGet(cAliPos+"_UNIT")
    dbSelectArea("FIL")
    FIL->(DbSetOrder(1))
    If (FIL->(DbSeek(cKey,.T.)))
        
        While (FIL->(!EOF())) .and. (FIL->FIL_FILIAL+FIL->FIL_FORNEC+FIL->FIL_LOJA == xFilial("FIL") +FwFldGet(cAliPos+"_SUPP")+FwFldGet(cAliPos+"_UNIT")) .and. !lOk
            If FIL->FIL_MOEDA == NCURR .And. IIf(Empty(cBankAcc),.T.,FIL->FIL_BANCO == cBankAcc)
                If Empty(cBankAcc)
                    FwFldPut(cAliPos+"_BNKCOD",FIL->FIL_BANCO,,,,.T.)
                EndIf
                FwFldPut(cAliPos+"_BIK",FIL->FIL_AGENCI,,,,.T.)
                FwFldPut(cAliPos+"_ACCNT",FIL->FIL_CONTA,,,,.T.)
                FwFldPut(cAliPos+"_RECNAM",ALLTRIM(FIL->FIL_NMECOR),,,,.T.)
                If !(cAliPos $ "F6B")
                    FilRsn604() //fill F47_REASON
                Endif
                lOk:=.T.   
            EndIf
            FIL->(DbSkip())
        Enddo
        If !lOk //Clear  the data
            If cAliPos $ "F6B"
                aFields:={cAliPos+"_BNKCOD",cAliPos+"_BIK",cAliPos+"_ACCNT",cAliPos+"_TYPCC",cAliPos+"_BKNAME",cAliPos+"_ACNAME",cAliPos+"_RECNAM"}
            Else
                aFields:={cAliPos+"_BNKCOD",cAliPos+"_BIK",cAliPos+"_ACCNT",cAliPos+"_TYPCC",cAliPos+"_BKNAME",cAliPos+"_ACNAME",cAliPos+"_RECNAM", cAliPos+"_REASON"}
            Endif
            RU06XFUN01_CleanFlds(aFields) // Load "" (empty) value to each field from the array
        EndIf
    EndIf
Endif
RestArea(aSaveArea)
Return (lRet)


/*/{Protheus.doc} R604ChkFil
Function Used to check If we need to replace FIL table data
@author Eduardo.Flima
@since 23/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function R604ChkFil(cFll, cSupp, cUnit, cBnkCod, cBik, cAccnt, cCurr, cAliPos as Character)
Local lRet as Logical
Local aSaveArea as Array
Local cQuery as Char

Default cFll:=XFILIAL("FIL")
Default cSupp:=FwFldGet("F47_SUPP")
Default cUnit:=FwFldGet("F47_UNIT")
Default cBnkCod:=FwFldGet("F47_BNKCOD")
Default cBik:=FwFldGet("F47_BIK")
Default cAccnt:=FwFldGet("F47_ACCNT")
Default cCurr:=str(val(FwFldGet("F47_CURREN")))
Default cAliPos := 'F47'

cQuery := ""
aSaveArea := GetArea()

cQuery := "SELECT * " + chr(13) + chr(10)
cQuery += "FROM " + RetSQlName("FIL") + " FIL " + chr(13) + chr(10)
cQuery += "WHERE FIL_FILIAL = '" + cFll + "' " + chr(13) + chr(10)
cQuery += " AND FIL_FORNEC = '" + cSupp + "' " + chr(13) + chr(10)
cQuery += " AND FIL_LOJA = '" + cUnit + "' " + chr(13) + chr(10)
cQuery += " AND FIL_BANCO = '" + cBnkCod + "' " + chr(13) + chr(10)
cQuery += " AND FIL_AGENCI = '" + cBik + "' " + chr(13) + chr(10)
cQuery += " AND FIL_CONTA = '" + cAccnt + "' " + chr(13) + chr(10)
cQuery += " AND FIL_MOEDA = " + cCurr + chr(13) + chr(10)
cQuery += " AND FIL.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

If select("CHKFIL") > 0
    CHKFIL->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "CHKFIL", .T., .F.)
dbSelectArea("CHKFIL")
lRet := CHKFIL->(Eof())
CHKFIL->(DbCloseArea())
RestArea(aSaveArea)

Return (lRet)


/*/{Protheus.doc} R604VldFil
is called from x3_valid of F47_BNKCOD(1), F47_BIK(3),F47_ACCNT(4)
used for any types but! not for Type 6 
(Transfer between bank accounts)
@author natalia.khozyainova
@since 10/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function R604VldFil(nOpc,cTable as character)
Local lRet as Logical
Local aFields as Array

Default cTable = 'F47'

If cTable == 'F6B'
    // cTable+"_REASON" deleted from aFields because of:
    // https://jiraproducao.totvs.com.br/browse/RULOC-1177
    aFields:={cTable+"_BKNAME",cTable+"_ACNAME",cTable+"_RECNAM"}
    If nOpc == 1
        FwFldPut(cTable+"_BIK",'',,,,.T.)
        FwFldPut(cTable+"_ACCNT",'',,,,.T.)
    ElseIf nOpc == 3
        FwFldPut(cTable+"_ACCNT",'',,,,.T.)
    Endif
    //used Nil for currency parameter, because now we have no currncy related field in F6B table
    //https://jiraproducao.totvs.com.br/browse/RULOC-1229
    lRet:=RU06XFUN04_VldFIL(FwFldGet(cTable+"_SUPP"), FwFldGet(cTable+"_UNIT"),Nil                        , FwFldGet(cTable+"_BNKCOD"), FwFldGet(cTable+"_BIK"), FwFldGet(cTable+"_ACCNT"), aFields)
else
    aFields:={cTable+"_TYPCC",cTable+"_BKNAME",cTable+"_ACNAME",cTable+"_REASON",cTable+"_RECNAM"}
    If nOpc == 1
        FwFldPut(cTable+"_BIK",'',,,,.T.)
        FwFldPut(cTable+"_ACCNT",'',,,,.T.)
    ElseIf nOpc == 3
        FwFldPut(cTable+"_ACCNT",'',,,,.T.)
    Endif
    lRet:=RU06XFUN04_VldFIL(FwFldGet(cTable+"_SUPP"), FwFldGet(cTable+"_UNIT"), FwFldGet(cTable+"_CURREN"), FwFldGet(cTable+"_BNKCOD"), FwFldGet(cTable+"_BIK"), FwFldGet(cTable+"_ACCNT"), aFields)
    
Endif

If lRet .and. !(cTable $ 'F6B')
    FilRsn604(.F.) //filled reason
EndIf
Return (lRet)


/*/{Protheus.doc} R604VldVat
Called from x3_valid of F47_VALUE, F47_VATCOD, F47_VATRAT, F47_VATAMT
@author natalia.khozyainova
@param  nNum: 1=VALUE, 2=COD , 3=RAT , 4=VAT Amount
@since 10/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function R604VldVat(nNum as Numeric)
Local lRet as Logical
lRet:=RU06XFUN17_VldVATFields(nNum, "F47", "RU06D04_MLNS")
FilRsn604()
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} FilRsn604
(Function for Payment Order to fill the Reason)
@type function
@author natalia.khozyainova
@since 28/12/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Function FilRsn604(lForce as Logical, nLine as Numeric, cAction as Char)
FwFldPut("F47_REASON",RU06XFUN19_ReasonText(lForce, nLine, cAction))
Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0401_RecalcCurrency
Function to Recalculate Currency Rate.
It is called from F47_DTPLAN x3_valid + from button + from RU06D05 source at the moment PRs are included to PO
@type function
@author natalia.khozyainova
@since 05/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function RU06D0401_RecalcCurrency(lForced, oModel, nRUD05, dDateToRecalc)
// nRUD05 == 1 means it comes from RU06D05 - Payment Orders
Local oModelH   as Object
Local oModelL   as Object
Local nX        as Numeric
Local aArea     as Array
Local aAreaF48  as Array
Local aError    as Array
Local nPos      as Numeric
Local oView     as Object
Local oViewLns  as Object
Local cHelpMsg  as Char
Local lConUni   as logical
Local lRet      as Logical

Default lForced:=.F.
Default nRUD05:=0

lRet := .T.
if nRUD05==0
    oModel:=FwModelActive()
Elseif nRUD05==1 .and. ValType(oModel)=='O'
    oModel:Activate()
EndIf

oModelH:=oModel:GetModel("RU06D04_MHEAD")
oModelL:=oModel:GetModel("RU06D04_MLNS")

Default dDateToRecalc:=oModelH:GetValue("F47_DTPLAN")

If ALLTRIM(oModelH:GetValue("F47_PAYORD"))=="" .or. nRUD05==1

    lConUni:=IIF(oModelH:GetValue("F47_CURREN")="01",RU06D0406_CheckifConUni(),.F.) // if head currency is RUB and if has some lines in conv units
    nPos:=oModelL:GetLine()
    aArea := GetArea()
    aAreaF48 := F48->(GetArea())

    If lConUni
        // Go line by line to update currency rate where currency <> 01 and conuni="1"  and Currency Rate is not defined by user
        For nX := 1 To oModelL:Length()
            oModelL:GoLine(nX)
            if  oModelL:GetValue("F48_CONUNI")=="1" .and. oModelL:GetValue("F48_RATUSR")!="1"
                RU06XFUN21_RecalcRubls(.T.,dDateToRecalc)
                RU06D0403_RecalcRubls(.F.,dDateToRecalc)
            EndIf
        Next nX

        R0604VAL()

        If ValType(nPos)=="N" .and. nPos>0
            oModelL:GoLine(nPos)
        EndIf

        if nRUD05==0
            oView := FwViewActive()
            If !Empty(oView)
                oViewLns := oView:GetViewObj("RU06D04_VLNS")[3]
                If !Empty(oViewLns)
                    oViewLns:Refresh(.T.,.F.)
                EndIf
            EndIf
        EndIf

    Else
        If lForced .and. nRUD05==0
            Help("",1,STR0098,,STR0101,1,0,,,,,,/*{'str - solution'}*/) // is possible only for conventional units
        EndIf
    EndIf

    RestArea(aAreaF48)
    RestArea(aArea)

Else
    cHelpMsg:=STR0102+alltrim(oModelH:GetValue("F47_CODREQ"))+STR0103+DTOC(oModelH:GetValue("F47_DTREQ"))+' '+;
    STR0104+alltrim(oModelH:GetValue("F47_PAYORD"))+STR0103+DTOC(oModelH:GetValue("F47_DTPAYM"))+STR0105
    Help("",1,STR0098,,cHelpMsg,1,0,,,,,,/*{'str - solution'}*/)//STR - This PR included to payment order, it can not be recalculated
EndIf

if nRUD05==1
    If oModel:VldData()
        lRet := oModel:CommitData()
    else
        lRet := .F.
        If oModel:HasErrorMessage()
            aError := oModel:GetErrorMessage()
            HELP("",1,  STR0001,,;  //Payment request
            aError[MODEL_MSGERR_IDFIELDERR] + " "+;
            aError[MODEL_MSGERR_MESSAGE],;    //Field and error
            1,0,,,,,,;
            {aError[MODEL_MSGERR_SOLUCTION]}) //Solution
        EndIf
    EndIf
    oModel:DeActivate()
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0402_RateValid
Validation Function for F48_EXGRAT. It will set F48_RATUSR as yes if user puts some currency rate manually
@type function
@author natalia.khozyainova
@since 05/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function RU06D0402_RateValid(nNum)
//nNum==2 - comes from RATUSR
lRet:=.T.

If !(ISINCALLSTACK("RU06D0401_RECALCCURRENCY")) .and. !(ISINCALLSTACK("RU06XFUN21_RecalcRubls"))
    lRet:=RU06XFUN22_CurrRatValid(nNum)
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0402_RecalcRubls
Recalculates values in rubles, called after VALREQ changed and after EXGRAT changes
@type function
@author natalia.khozyainova
@since 28/12/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Function RU06D0403_RecalcRubls(lOnlyRate, dDateToRecalc)
RU06XFUN21_RecalcRubls(lOnlyRate, dDateToRecalc)
Return (.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0402_RecalcRubls
Recalculates values in rubles, called after VALREQ changed and after EXGRAT changes
@type function
@author natalia.khozyainova
@since 05/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function RU06D0404_CheckBoxValid()
Local lRet as Logical
lRet:=RU06XFUN23_VirtCheckBoxValid()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0406_CheckifConUni()
Returns logical value: True if request includes some lines with conventional units, False - if not
@type function
@author natalia.khozyainova
@since 05/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RU06D0406_CheckifConUni(oModel)
Local lRet as Logical
Local oModelL as Object
lRet:=.F.

If ValType(oModel)!="O"
    oModel:=FwModelActive()
EndIf
If oModel != nil
    oModelL:=oModel:GetModel("RU06D04_MLNS")
    IIF(oModelL != nil,lRet:=oModelL:SeekLine({{"F48_CONUNI", "1"}}), .F. )
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0407_ValidRubles()
called from validation of F48_VALCNV, F48_VLVATC
@type function
@author natalia.khozyainova
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function  RU06D0407_ValidRubles()
Local oModel as Object
Local oModelL as ObjectRecalcRubls
Local nPos as Numeric

oModel:=FwModelActive()
oModelL:=oModel:GetModel("RU06D04_MLNS")
nPos:=oModelL:GetLine()

R0604VAL(.F.,nPos)

Return (.T.)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0408_FillVirtFilial()

@type function
@author natalia.khozyainova
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function RU06D0408_FillVirtFilial(oModel)
Local oView as Object
nOperation:=oModel:GetOperation()

if nOperation != 5
    oView	:= FWViewActive()
    oModel:GetModel("RU06D04_MHEAD"):LoadValue("F47_FILIAL",xFilial("F47"))
    oView:Refresh()
EndIf

Return

Function RU06D0414_CopyOperation()
Local cOper as Char

cOper:= STR0007
FWExecView(cOper,"RU06D04",9,,{|| .T.})
Return (NIL)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0411_ShowPO()
Link from RU06D04 to RU06D05  (from payment request to payment order)
@type function
@author natalia.khozyainova
@since 10/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function RU06D0411_ShowPO()
Local aArea as Array
//Local aAreaF49 as Array
Local cKey as Char

aArea := (GetArea())
if ALLTRIM(F47->F47_PAYORD)=''
    Help("",1,STR0106,,STR0107,1,0,,,,,,/*{"solution"}*/) // Payment Orders related - Nothing found -
Else
    cKey:=RU06D0412_GenKeyF47(F47->F47_PAYORD, F47->F47_CODREQ)

    if alltrim(cKey)!=''
        dbSelectArea("F49")
        F49->(DbSetOrder(1))
        If F49->(DbSeek(cKey))
            FWExecView(STR0108,"RU06D05",MODEL_OPERATION_VIEW,,{|| .T.})
        EndIf
        DbCloseArea()
    Else
        Help("",1,STR0106,,STR0107,1,0,,,,,,/*{"solution"*/) // Payment Orders related - Nothing found -
    EndIf
EndIf
RestArea(aArea)
return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0412_GenKeyF47()
Returns unique key for table F49 when we know Payment orser number and request code
@type function
@author natalia.khozyainova
@since 10/09/2018
@version 1.1
@edit astepanov 13 October 2020
changed according to changes in RU06D0413_ShwDtPaym()
/*/
//-------------------------------------------------------------------
Function RU06D0412_GenKeyF47(cPayOrd, cCodReq, dDtReq)
Local cRet as Char
Local cQuery as Char
Local cTab as Char
Local aArea as Array

Default cPayOrd:=''
Default cCodReq:=''
Default dDtReq :=STOD('')

aArea  := GetArea()

cQuery := " SELECT * FROM " + RetSQLName("F4A")  + " F4A "
cQuery += " LEFT JOIN "     + RetSQLName("F49")  + " F49 "
cQuery += " ON ( F4A_IDF49=F49_IDF49 AND F4A_FILIAL=F49_FILIAL ) "
cQuery += "     WHERE F49_PAYORD = '" + cPayOrd     +"'"
cQuery += "     AND   F4A_CODREQ = '" + cCodReq     +"'"
If !Empty(dDtReq)
    cQuery += " AND   F4A_DTREQ  = '" + DTOS(dDtReq)+"'"
EndIf
cQuery += "     AND   F49_FILREQ = '" + xFilial("F49",F47->F47_FILIAL) +"'"
cQuery += "     AND   F4A.D_E_L_E_T_ =' ' "
cQuery += "     AND   F49.D_E_L_E_T_ =' ' "

cQuery := ChangeQuery(cQuery)
cTab := CriaTrab( , .F.)
TcQuery cQuery New Alias ((cTab))

cRet:=''
DBSelectArea(cTab)
(cTab)->(DBGoTop())
While (cTab)->(!EOF())  .and. ((cTab)->(F49_FILREQ+F4A_CODREQ+F49_PAYORD) == (xFilial("F49",F47->F47_FILIAL)+cCodReq+cPayOrd))
    cRet:=(cTab)->F49_FILIAL+(cTab)->F49_PAYORD+(cTab)->F49_BNKORD+(cTab)->(F49_DTPAYM)
    (cTab)->(DbSkip())
Enddo
(cTab)->(DBCloseArea())
RestArea(aArea)

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0413_ShwDtPaym()
Returns value of virtual field F47_DTPAYM to x3relacao and to x3_inibrw
@type function
@author natalia.khozyainova
@since 19/09/2018
@version 1.1
@edit   astepanov  13 October 2020
added date parameter because code request is not unique key,
unique key is F47_FILIAL+F47_CODREQ+DTOS(F47_DTREQ)
inibrw should be changed to Posicione
/*/
//-------------------------------------------------------------------
Function RU06D0413_ShwDtPaym(cPayOrd, cCodReq, dDtReq)
Local dRet as Date
Local aArea as Array

Default cPayOrd:=''
Default cCodReq:=''
Default dDtReq := STOD('')

aArea:=GetArea()
dRet:=STOD('')
dRet:=Posicione("F49",1,RU06D0412_(cPayOrd,cCodReq,dDtReq),"F49_DTPAYM")
RestArea(aArea)
Return(dRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0415_ViewConfig()
Called from Event Activate()
this function configures the View before it opens:
Add button to recalculate conventional units and set most of the fields not editable for
PRs approved (except date, reason and totaks for conuni possible recalculation)
@type function
@author natalia.khozyainova
@since 11/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function RU06D0415_ViewConfig(oView, oModel)
Local oModelH   as Object
Local oModelL   as Object
Local nOper     as Numeric
Local lConUni   as Logical
Local nX        as Numeric
Local cDocTp   as Character
//Local cReqType  as Character

oModelH:=oModel:GetModel("RU06D04_MHEAD")
oModelL:=oModel:GetModel("RU06D04_MLNS")
nOper:=oModel:GetOperation()
lConUni:=RU06D0406_CheckifConUni(oModel)

cDocTp := oModelH:GetValue("F47_REQTYP")
If FwIsInCallStack("R604VIWAPR")     // Disable all fields when operation is 'approve'
    aFields := oModelH:GetStruct():GetFields()
    For nX := 1 to Len(aFields)
        oModelH:GetStruct():SetProperty(aFields[nX][3],MODEL_FIELD_WHEN,{||.F.})
    Next nX
Endif

If F47->F47_STATUS=="4" .and. nOper!=3 // If status is 'approved'
    aFields := oModelH:GetStruct():GetFields()
    If alltrim(F47->F47_PAYORD)=="" .and. lConUni // if not attached to Payment Order and includes conventional units
        For nX := 1 to Len(aFields)
        // disable fields except date, reason of payment, value and vat amount
            if !(aFields[nX][3]=="F47_DTPLAN" .or. aFields[nX][3]=="F47_REASON" .or. aFields[nX][3]=="F47_VALUE" .or. aFields[nX][3]=="F47_VATAMT")
                oModelH:GetStruct():SetProperty(aFields[nX][3],MODEL_FIELD_WHEN,{||.F.})
            EndIf
        Next nX
        oModelL:SetNoInsertLine()
        oModelL:SetNoDeletLine()
        oModelL:GetStruct():SetProperty("F48_VALREQ",MODEL_FIELD_WHEN,{||.F.})

    Else
        For nX := 1 to Len(aFields)
            oModelH:GetStruct():SetProperty(aFields[nX][3],MODEL_FIELD_WHEN,{||.F.})
        Next nX
        aFieldsL := oModelL:GetStruct():GetFields()
        For nX := 1 to Len(aFieldsL)
            oModelL:GetStruct():SetProperty(aFieldsL[nX][3],MODEL_FIELD_WHEN,{||.F.})
        Next nX

    EndIf
Endif

IF cDocTp != "6"
    If (nOper == 3 .OR. nOper == 4)  // Copy
        oView:AddUserButton(STR0096, '', {|| RU06D0401_RecalcCurrency(.T.)})     //Recalc Currency
    EndIf

    If !FwIsInCallStack('R604ViwApr')
        If (!(F47->F47_STATUS $ "2|3|4") .and. nOper == 4) .or. (nOper == 3) .or. FwIsInCallStack("RU06D0414_CopyOperation")
            oView:AddUserButton(STR0018, '', {|| RU06XFUN10_PickUpAPs("F47")})    //Pick Up APs
            oView:AddUserButton(STR0030, '', {|| R0604RCalc()})     //Recalc Total Value
        EndIf
    Endif
Endif

Return (.T.)



//-------------------------------------------------------------------
//The function checks if the selected payment request is in the list of payments.
//The function is activated when you try to edit or delete a payment request.
//-------------------------------------------------------------------
function RU06D0416_CheckPayLists
    local lRet      as logical
    Local cStatus   as Character
    //Local cPayord   as Character
    Local cRet      as Character
    local cIdF47    as Character
    local cBranch   as character

    lRet:=.F.
    aArea:=GetArea()
    cIdF47  :=F47->F47_IDF47
    cBranch :=F47->F47_FILIAL

    cQuery := " SELECT F5M_IDDOC, F5M_KEY, F60_STATUS, F5M_KEYALI, F60_IDF60, F5M_FILIAL, F60_FILIAL, F5M_ALIAS, F47_IDF47 FROM " + RetSQLName("F47")  + " F47 "
    cQuery += " LEFT JOIN  " + RetSQLName("F5M")  + " F5M "
    cQuery += " ON F5M_KEY = F47_IDF47 AND F5M_KEYALI = 'F47' AND F5M_ALIAS = 'F60' "
    cQuery += " LEFT JOIN  " + RetSQLName("F60")  + " F60 "
    cQuery += " ON F5M_IDDOC = F60_IDF60 AND F5M_FILIAL = F60_FILIAL "
    cQuery += " WHERE F47_IDF47 = '" + cIdF47 + "' "
    cQuery += " AND F47_FILIAL = '" + cBranch + "' "
    cQuery += " AND F47.D_E_L_E_T_ = ' '"
    cQuery += " AND F60.D_E_L_E_T_ = ' '"
    cQuery += " AND F5M.D_E_L_E_T_ = ' '"

    cQuery := ChangeQuery(cQuery)
    cTab := CriaTrab( , .F.)
    TcQuery cQuery New Alias ((cTab))
    cRet:=''
    cRet:=(cTab)->F60_IDF60
    cStatus := (cTab)->F60_STATUS
    //  .T. means that the request is included in the list of payments if the function finds a non-empty record that is not canceled (status not equal to '4')
    If !EMPTY(cRet) .And. cStatus != '4'
        lRet := .T.
    EndIf
Return lRet

/*/{Protheus.doc} RU06D04
Select view to PR
FI-CF-25-5
@author alexander.kharchenko
@since 26.12.2019
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0418_SelectTypesForm()
Local aArea     as Array
Local oModel    as Object
Local cOper     as Character
Local nRet      as Numeric

aArea:=GetArea() //F47 area
F48->(dbGoBottom())
F48->(dbSkip())
cOper:= STR0003
cOperTp := R0604TypR()
nRet    := 1
Do Case
    Case cOperTp == "1"
        nRet := FWExecView(cOper,"RU06D04",MODEL_OPERATION_INSERT,,{|| .T.})
    Case cOperTp == "3" .Or. cOperTp == "6"
        oModel := FWLoadModel('RU06D04')
        oModel:SetOperation(MODEL_OPERATION_INSERT)
        oModel:Activate()
        oModel:GetModel("RU06D04_MHEAD"):LoadValue("F47_REQTYP", cOperTp)
        if cOperTp == "6"
            oModel:GetModel("RU06D04_MHEAD"):LoadValue("F47_REASON", STR0117)
        endif
        nRet := FWExecView(cOper,"RU06D04",MODEL_OPERATION_INSERT,,{|| .T.},,,,,,,oModel)
        oModel:DeActivate()
EndCase

If nRet == 1
    //we restore F47 area if user pressed Cancel in window
    RestArea(aArea)
EndIf

Return

/*/{Protheus.doc} RU06D04
This function assigned to the triggers
for F47_SUPP and F47_UNIT fields 
and F6B_SUPP and F6B_UNIT fields in RU09D08.
When we input F47_SUPP(F6B_SUPP) or F47_UNIT(F6B_UNIT) 
fields we fill information about
supplier like supplier name, KPP.
@author astepanov
@since 18 August 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0419_GatForn(cField)
    Local  cRet As Character
    Local  aArea     As Array
    Local  aAreaSA2  As Array
    Local  cPref     As Character
    aArea    := GetArea()
    aAreaSA2 := SA2->(GetArea())
    cRet     := ""
    cPref    := SubStr(cField,1,4)
    If     cField $ "F47_UNIT|F6B_UNIT"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet(cPref+"SUPP"),"A2_LOJA")
    ElseIf cField $ "F47_SUPNAM|F6B_SUPNAM"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet(cPref+"SUPP")+FwFldGet(cPref+"UNIT"),"A2_NOME")
    ElseIf cField $ "F47_KPPREC|F6B_KPPREC"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet(cPref+"SUPP")+FwFldGet(cPref+"UNIT"),"A2_KPP")
    EndIf
    cRet := PADR(cRet,GetSX3Cache(cField,"X3_TAMANHO"," "))
    RestArea(aAreaSA2)
    RestArea(aArea)
Return cRet

/*/{Protheus.doc} RU06D04201
This function assigned to the triggers
for F47_CFGCOD field. 
According to selected F47_CFGCOD we recieve currency for
F47_CURREN
@author astepanov
@since 12 February 2021
@version 1.0
@project MA3 - Russia
/*/
Function RU06D04201_GatMoeda(cSupp,cUnit,cBnkCod,cBik,cAcc)
    Local cRet  As Character
    Local cAls  As Character
    Local aArea As Array
    cRet  := ""
    aArea := GetArea()
    cAls  := RU06XFUN40_RetBankAccountDataFromFIL(cSupp, cUnit, Nil, cBnkCod, cBik, cAcc, .T., Nil, Nil)
    DBSelectArea(cAls)
    DBGoTop()
    cRet := PADL(cValToChar(_MOEDA),GetSX3Cache("F47_CURREN","X3_TAMANHO"),"0")
    DBCloseArea()
    RestArea(aArea)
Return cRet

/*/{Protheus.doc} RetSE2Key
    Return search key value for searching in SE2 table, index 1
    and F5M_KEY value for searching in F5M table
    @type  Static Function
    @author astepanov
    @since 08/11/2022
    @version version
    @param cTab, Character, F48 or F4B
    @return {cSE2K,cF5MK}, Array, {Search key fro SE2 index 1, F5M_KEY}
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function RetSE2Key(cTab)
    Local cSE2K  As Character
    Local cF5MK  As Character
    Local cStr   As Character
    Local cSepar As Character
    cSepar := "|"
    If cTab    == "F48"
        cStr := PADR(F48->F48_FLORIG,GetSX3Cache("E2_FILIAL" ,"X3_TAMANHO"))
        cSE2K := cStr
        cF5MK := cStr + cSepar
        cStr := PADR(F48->F48_PREFIX,GetSX3Cache("E2_PREFIXO","X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F48->F48_NUM   ,GetSX3Cache("E2_NUM"    ,"X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F48->F48_PARCEL,GetSX3Cache("E2_PARCELA","X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F48->F48_TYPE  ,GetSX3Cache("E2_TIPO"   ,"X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F47->F47_SUPP  ,GetSX3Cache("E2_FORNECE","X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F47->F47_UNIT  ,GetSX3Cache("E2_LOJA"   ,"X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr
    ElseIf cTab == "F4B"
        cStr := PADR(F4B->F4B_FLORIG,GetSX3Cache("E2_FILIAL" ,"X3_TAMANHO"))
        cSE2K := cStr
        cF5MK := cStr + cSepar
        cStr := PADR(F4B->F4B_PREFIX,GetSX3Cache("E2_PREFIXO","X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F4B->F4B_NUM   ,GetSX3Cache("E2_NUM"    ,"X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F4B->F4B_PARCEL,GetSX3Cache("E2_PARCELA","X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F4B->F4B_TYPE  ,GetSX3Cache("E2_TIPO"   ,"X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F49->F49_SUPP  ,GetSX3Cache("E2_FORNECE","X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr + cSepar
        cStr := PADR(F49->F49_UNIT  ,GetSX3Cache("E2_LOJA"   ,"X3_TAMANHO"))
        cSE2K += cStr
        cF5MK += cStr
    EndIf
Return {cSE2K,cF5MK}

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D04202()
Returns value of x3_inibrw for F47_RCVNAM
@type function
@author konstantin.konovalov
@since 06/07/2023
@version 1.1
@edit   
/*/
//-------------------------------------------------------------------
Function RU06D04202()
    Local dRet as Character
    Local aArea as Array    

    aArea:=GetArea()
    dRet:=IIF((!INCLUI .AND. !EMPTY(M->F47_RCVACC)),Posicione('SA6', 1, xFilial('SA6')+M->(F47_RCVBNK+F47_RCVBIK+F47_RCVACC), 'A6_NAMECOR'),"")
    RestArea(aArea)
Return (dRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D04205()
Trigger function for F47_BNKCOD() -> if empty clean F47_RECNAM
@type function
@author konstantin.konovalov
@since 27/11/2023
@version 1.1
@edit   
/*/
//-------------------------------------------------------------------
Function RU06D04205()
    Local cRet as Character
    Local aArea as Array
    
    aArea:=GetArea()
    cRet := (M->F47_RECNAM)
    if EMPTY(M->F47_BNKCOD)
        cRet := ''
    EndIf 
    RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D04204()
Trigger function for F47_RCVNAM(2), F47_RECNAM(1)
@type function
@author konstantin.konovalov
@since 06/07/2023
@version 1.1
@edit   
/*/
//-------------------------------------------------------------------
Function RU06D04204(nType as Numeric)
    Local dRet as Character
    Local aArea as Array
    
    aArea:=GetArea()   // A6_NAMECOR
    if nType == 1
        dRet:=IIF(!EMPTY(M->F47_BNKCOD) .AND. ; 
                !EMPTY(M->F47_BIK) .AND. ;
                !EMPTY(M->F47_ACCNT) ,;
                Posicione('SA6', 1, xFilial('SA6')+M->(F47_BNKCOD+F47_BIK+F47_ACCNT),'A6_NAMECOR'),"")
    else
        dRet:=IIF(!EMPTY(M->F47_RCVBNK) .AND. ;
                !EMPTY(M->F47_RCVBIK) .AND. ;
                !EMPTY(M->F47_RCVACC) ,;
                Posicione('SA6', 1, xFilial('SA6')+M->(F47_RCVBNK+F47_RCVBIK+F47_RCVACC),'A6_NAMECOR'),"")
    Endif
    RestArea(aArea)

Return (dRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D04203()
Dynamically setup fields properties for 
'Transfers between bank accounts' document (6 type):
@type function
@author konstantin.konovalov
@since 06/07/2023
@version 1.1
@edit   
/*/
//-------------------------------------------------------------------
Function RU06D04203(oStrF47)
    oStrF47:SetProperty("F47_VALUE", MVC_VIEW_FOLDER_NUMBER, "1") 
    oStrF47:SetProperty( "F47_VALUE", MVC_VIEW_GROUP_NUMBER, "003")

    oStrF47:SetProperty("F47_BNKCOD", MVC_VIEW_FOLDER_NUMBER, "7")
    oStrF47:SetProperty("F47_BNKCOD", MVC_VIEW_GROUP_NUMBER, "008")
    oStrF47:SetProperty("F47_BNKCOD", MVC_VIEW_LOOKUP, "SA6PO")

    oStrF47:SetProperty("F47_BIK", MVC_VIEW_FOLDER_NUMBER, "7")
    oStrF47:SetProperty("F47_BIK", MVC_VIEW_GROUP_NUMBER, "008")
    
    oStrF47:SetProperty("F47_ACCNT", MVC_VIEW_FOLDER_NUMBER, "7")
    oStrF47:SetProperty("F47_ACCNT", MVC_VIEW_GROUP_NUMBER, "008")

    oStrF47:SetProperty("F47_CLASS", MVC_VIEW_FOLDER_NUMBER, "7")
    oStrF47:SetProperty("F47_CLASS", MVC_VIEW_GROUP_NUMBER, "008")    

    oStrF47:SetProperty("F47_KPPPAY", MVC_VIEW_FOLDER_NUMBER, "7")
    oStrF47:SetProperty("F47_KPPPAY", MVC_VIEW_GROUP_NUMBER, "008")

    oStrF47:SetProperty("F47_RECNAM", MVC_VIEW_FOLDER_NUMBER, "7")
    oStrF47:SetProperty("F47_RECNAM", MVC_VIEW_GROUP_NUMBER, "008")
    //!  next line is workaround explanation:
    // as no fields in group at the moment x3 loading - group will never be shown, 
    // despite trying add fields in the code, so create field in x3 with 'wrong' group
    // - to opportunities to work with a group from code. Now change to the correct belongs:
    oStrF47:SetProperty("F47_RCVNAM", MVC_VIEW_GROUP_NUMBER, "009")

    // New title:
    oStrF47:SetProperty('F47_KPPPAY', MVC_VIEW_TITULO, STR0118)
    oStrF47:SetProperty('F47_KPPREC', MVC_VIEW_TITULO, STR0119)
    oStrF47:SetProperty('F47_BNKCOD', MVC_VIEW_TITULO, STR0120)
    oStrF47:SetProperty('F47_RCVBNK', MVC_VIEW_TITULO, STR0121)
    oStrF47:SetProperty('F47_BIK', MVC_VIEW_TITULO, STR0122)
    oStrF47:SetProperty('F47_RCVBIK', MVC_VIEW_TITULO, STR0123)
    oStrF47:SetProperty('F47_RECNAM', MVC_VIEW_TITULO, STR0124)
    oStrF47:SetProperty('F47_RCVNAM', MVC_VIEW_TITULO, STR0125)
    oStrF47:SetProperty('F47_ACCNT', MVC_VIEW_TITULO, STR0126)
    oStrF47:SetProperty('F47_RCVACC', MVC_VIEW_TITULO, STR0127)
    oStrF47:SetProperty('F47_CLASS', MVC_VIEW_TITULO, STR0128)
    oStrF47:SetProperty('F47_RCVCLS', MVC_VIEW_TITULO, STR0129)

    //Sender's Data:  
    ostrF47:SetProperty("F47_RECNAM", MVC_VIEW_ORDEM, "24")
    ostrF47:SetProperty("F47_CLASS", MVC_VIEW_ORDEM, "25")   
    ostrF47:SetProperty("F47_KPPPAY", MVC_VIEW_ORDEM, "26")

    //Receiver's Data: 
       
    ostrF47:SetProperty("F47_RCVNAM", MVC_VIEW_ORDEM, "65")
    ostrF47:SetProperty("F47_RCVCLS", MVC_VIEW_ORDEM, "66")
    oStrF47:SetProperty("F47_KPPREC", MVC_VIEW_FOLDER_NUMBER, "7")
    oStrF47:SetProperty("F47_KPPREC", MVC_VIEW_GROUP_NUMBER, "009")
    ostrF47:SetProperty("F47_KPPREC", MVC_VIEW_ORDEM, "67")

Return

//------------------------------------------------------------------
/*/{Protheus.doc} RU06D04014()
Validate '(Receiver's/Sender's) Bank', 
         '(Receiver's/Sender's) BIK number', 
         '(Receiver's/Sender's) Bank account' 
for 'Transfers between bank accounts' document (type 6)
Created based on RU06D0508_VldSa6()
@type function
@author konstantin.konovalov
@param  Numeric   nParam    //Type of verification {0,10;3,13;4,14}
@since 11/07/2023
@version 1.1
@edit   
/*/
//----------------------------------------------------
Function RU06D04014_VldSa6(nParam as Numeric)
Local lRet      as Logical
Local aArea     as Array
Local cAls      as Character
Local nLParam   as Numeric

Default nParam  := 0

lRet :=  .T.
if nParam < 10 
    cBCId := __cTabHdr+"_BNKCOD"
    cBICID := __cTabHdr+"_BIK"
    cAccID := __cTabHdr+"_ACCNT"
    cCurrID := __cTabHdr+"_CURREN"
    nLParam := nParam
else
    cBCId := __cTabHdr+"_RCVBNK"
    cBICID := __cTabHdr+"_RCVBIK"
    cAccID := __cTabHdr+"_RCVACC"
    cCurrID := __cTabHdr+"_CURREN"
    nLParam := nParam - 10
ENDIF

If nLParam == 0 // validate bank code
    If !Empty(FwFldGet(cBCId))
        aArea := GetArea()
        // this function have more complex rules for bankcode data extraction
        cAls := RU06XFUN39_RetBankAccountDataFromSA6;
                (FwFldGet(cBCId),,,Val(FwFldGet(cCurrID)),.F.,.F.,.T.)
        DBSelectArea(cAls)
        (cAls)->(DbGoTop())
        If (cAls)->(Eof())
            lRet := .F.
        EndIf
        (cAls)->(DBCloseArea())
        RestArea(aArea)
    EndIf
ElseIf nLParam == 3   // validate bank BIC (Business Identifier Code)
    If !Empty(FwFldGet(cBICID))
        lRet := ExistCpo("SA6",FwFldGet(cBCId)+FwFldGet(cBICID))
    EndIf
Elseif nLParam == 4   // validate bank account
    If !Empty(FwFldGet(cAccID))
        lRet := ExistCpo("SA6",FwFldGet(cBCId)+FwFldGet(cBICID)+FwFldGet(cAccID))
    EndIf
EndIf

Return (lRet)
                   
//Merge Russia R14 
                   
