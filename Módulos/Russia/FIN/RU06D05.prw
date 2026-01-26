#INCLUDE "PROTHEUS.CH"    
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"
#include "RU06D05.CH"
#Include "RWMAKE.CH"

#DEFINE LDISARMEADTRANSACTION .F.

Static __cTabHdr  := "F49"
Static __cMdlHdr  := "RU06D05_MF49"
Static __lDsrmTra := RU06D05Sta("__lDsrmTra")


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D05
Payment Ordes (main) Routine 
@author natalia.khozyainova
@since 18/07/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D05()
Local oBrowse as Object
// Included because of the MSDOCUMENT routine, 
// the MVC does not need any private variables 
// but MSDOCUMENT needs aRrotina and cCadastro
Private cCadastro as Character 
Private aRotina as Array

aRotina		:= {}
cCadastro := STR0002 //Payment Order

oBrowse := BrowseDef()
oBrowse:Activate()
 
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition.
@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function BrowseDef()
Local oBrowse 	as Object

oBrowse	:= FWmBrowse():New()
oBrowse:SetAlias("F49")
oBrowse:SetDescription(STR0001) // Payment Orders  
oBrowse:SetAttach(.T.)
oBrowse:SetExecuteDef(1)
oBrowse:AddLegend("F49_STATUS =='1'", "WHITE",  STR0003) // Created
oBrowse:AddLegend("F49_STATUS =='2'", "YELLOW", STR0004) // Sent to bank
oBrowse:AddLegend("F49_STATUS =='3'", "RED",    STR0005) // Rejected
oBrowse:AddLegend("F49_STATUS =='4'", "GREEN",  STR0006) //Paid

aRotina := Nil // needed for MSDOCUMENT
oBrowse:SetCacheView(.F.)// needed for MSDOCUMENT

Return (oBrowse) 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition.
@author natalia.khozyainova
@since 17/07/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function MenuDef()
Local aRotina as Array

aRotina := {}

ADD OPTION aRotina TITLE STR0007   ACTION "RU06D0510_Act(1)"    OPERATION 1 ACCESS 0   // View
ADD OPTION aRotina TITLE STR0028   ACTION "RU06D05520_Inclusion(3)"  OPERATION 3 ACCESS 0   // Add
ADD OPTION aRotina TITLE STR0010   ACTION "RU06D0510_Act(4)"    OPERATION 4 ACCESS 0   // Edit
ADD OPTION aRotina TITLE STR0011   ACTION "RU06D0510_Act(5)"    OPERATION 5 ACCESS 0   // Delete
ADD OPTION aRotina TITLE STR0012   ACTION "MSDOCUMENT"          OPERATION 4 ACCESS 0   // Knowledge (Upload Documents)
ADD OPTION aRotina TITLE STR0013   ACTION "RU06D0510_Act(9)"    OPERATION 9 ACCESS 0   // Copy
ADD OPTION aRotina TITLE STR0014   ACTION "RU06D0511_Legend"    OPERATION 7 ACCESS 0   // Legend
ADD OPTION aRotina TITLE STR0015   ACTION "RU06D0516_Status"    OPERATION 4 ACCESS 0   // Change Status

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model Definition for the case when PO is created from list of PRs.
It contains 3 levels: F49 (PO), F4A (PRs), F4B (APs) 
@author natalia.khozyainova
@edit   astepanov
@since 24/07/2018
@edition 24 September 2020
@version 2.0
@project MA3 - Russia
/*/
Static Function ModelDef()

Local aStruct   as Array
Local oModel    as Object

aStruct := {}

oModel  := MPFormModel():New("RU06D05",,,{|oModel| CommitData(oModel)})
aStruct := RU06D05490_RetStructs()
oModel  := RU06D05491_ConfigModel("RU06D05", oModel, aStruct)

Return oModel

/*/{Protheus.doc} CommitData
    Function used by model for data commiting
    @type  Static Function
    @author astepanov
    @since 02/08/2022
    @version version
    @param oModel, Object, Link to Object
    @return lRet, Logical, Result of commit
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CommitData(oModel)
    Local lRet       As Logical
    lRet := .T.
    __lDsrmTra := RU06D05Sta("__lDsrmTra")
    If InTransact()
        If !FWInTTSBreak()
            lRet := lRet .AND. FwFormCommit(oModel)
        Else
            lRet := .F.
        EndIf
    Else
        lRet := lRet .AND. FwFormCommit(oModel)
    EndIf
    If __lDsrmTra
        lRet := .F.
        If InTransact()
            DisarmTransaction()
        EndIf
    EndIf
    __lDsrmTra := RU06D05Sta("__lDsrmTra")
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View Definition for the case when PO is created from list of PRs.
It contains 3 levels: F49 (PO), F4A (PRs), F4B (APs) 
@author natalia.khozyainova
@edit   astepanov
@since 24/07/2018
@edition 24 September 2020
@version 1.0
@project MA3 - Russia
/*/
Static Function ViewDef()

Local oModel    as Object
Local oView 	as Object

oModel := FWLoadModel("RU06D05")
oView  := RU06D05492_RetView(oModel)

Return oView


//-----------------------------------------------------------------------
/*/{Protheus.doc} RU06D0510_Act
all actions, called from Main Menu
@author natalia.khozyainova
@since 24/07/2018
@version P12.1.21
@type function
/*/
Function RU06D0510_Act(nOperation as Numeric, nOrdrTyp as Numeric, cPayTyp as Character)
Local aArea     as Array
Local lRet      as Logical
Local cOper     as Character 
Local cProgram   as Character
Local cStatus as Character

Default nOperation := MODEL_OPERATION_INSERT
Default nOrdrTyp :=  2 // 1 == from request; 2= manualy created
Default cPayTyp  := F49->F49_PAYTYP // "1" - payment to supplier, "3" - payment to budget

Private cRU06D05PT := cPayTyp // Payment to supplier, we use this parameter in ModelDef() and in ViewDef() in RU06D05

lRet:=.T.
aArea:=GetArea()
cStatus:=F49->F49_STATUS


If (nOperation == MODEL_OPERATION_INSERT)
    If     nOrdrTyp == 1
        cProgram := "RU06D05"
        If     cPayTyp == "1"
            cOper := STR0008 //create from requests
        ElseIf cPayTyp == "3"      
            cOper := STR0116 //Create payment to budget
        EndIf
    ElseIf nOrdrTyp == 2
        cProgram := "RU06D06"
        cOper  := STR0009 //create manually
    EndIf
    FWExecView(cOper,cProgram,nOperation,,{|| .T.})
EndIf

//F49_REQUES == "1" PO created from requests; "2" - no requests
cProgram := IIF(F49->F49_REQUES == "1", "RU06D05", "RU06D06")

If nOperation == MODEL_OPERATION_DELETE
    cOper:= STR0011 // Delete
    If cStatus=='4' // Paid
        Help("",1,STR0001,,STR0086,1,0,,,,,,) // This PO is paid, it can not be deleted
    Else 
        FWExecView(cOper,cProgram,nOperation,,{|| .T.})
    EndIf
EndIf

If nOperation == MODEL_OPERATION_UPDATE
    cOper:= STR0010 // Edit
    If cStatus=="2" .or. cStatus=="4"
        If MsgNoYes(STR0091, STR0092) // Edition is not available for this PO Open for View? -- Open for View
            FWExecView(STR0007,cProgram,MODEL_OPERATION_VIEW,,{|| .T.}) 
        EndIf
    Else
        FWExecView(cOper,cProgram,nOperation,,{|| .T.})
    EndIf
EndIf
    
If nOperation == MODEL_OPERATION_VIEW
    cOper:= STR0007 // View
    FWExecView(cOper,cProgram,nOperation,,{|| .T.})
EndIf

If nOperation == 9 // Copy
    cOper:= STR0013 // Copy 
    FWExecView(cOper,cProgram,nOperation,,{|| .T.})
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0511_Legend
this function will show list of colours used for legend (status). See Browse:AddLegend()
@author natalia.khozyainova
@since 24/07/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0511_Legend()
Local aRet as Array
aRet:={}
aAdd(aRet,{ "BR_BRANCO"  , STR0003 }) // White == Created
aAdd(aRet,{ "BR_AMARELO" , STR0004}) // Yellow == Included in PO
aAdd(aRet,{ "BR_VERMELHO", STR0005 }) // Red == Rejected
aAdd(aRet,{ "BR_VERDE"   , STR0006 }) // Green == Payed

BrwLegenda(cCadastro,STR0014, aRet) // Legend 
Return (aRet)


/*/{Protheus.doc} RU06D0501_InitPayOrd
This function is to set initial value to Payment Order Number
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0501_InitPayOrd()
Local cNum as Character

cNum:=RU09D03NMB("PAYORD")
while Right(Alltrim(cNum),3)='000'
    cNum:=RU09D03NMB("PAYORD")
EndDo

Return (cNum)

Function RU06D0502_VldBnkOrd(cFldName)
Local lRet as Logical
Local lIs3EndZer as Logical
Local lIsInteger as Logical

Default cFldName:="F49_BNKORD"
lRet := .T.
lIsInteger  := RU99XFUN08_IsInteger(FwFldGet(cFldName))
lIs3EndZer := Right(Alltrim(FwFldGet(cFldName)), 3) == '000'
If lRet .AND. !lIsInteger
    lRet := .F.
    Help("",1,STR0063,,STR0112,1,0,,,,,,{STR0065}) // Bank Number is not allowed -- Number must contain only digits and can't end with 000 -- Change the number
EndIf
If lRet .AND. lIs3EndZer
    lRet := .F.
    Help("",1,STR0063,,STR0064,1,0,,,,,,{STR0065}) // Bank Number is not allowed -- Can not end with 000 -- Change the number
EndIf

Return (lRet)

/*/
{Protheus.doc} RU06D0503_VldSupp()
Supplier code and unit validation
also used in RU06D07
@author natalia.khozyainova
@param  Numeric    nField   //1 = Supp, 2=Unit
        Character  cTab    // can be Nil, default is __cTabHdr      
@since 31/07/2018
@version 1.0
@edit  astepanov 03 November 2020
@project MA3 - Russia
/*/
Function RU06D0503_VldSupp(nField, cTab)

Local lRet as Logical
Local aSaveArea as Array
Default nField := 1
Default cTab   := __cTabHdr

lRet := .T.
aSaveArea := GetArea()

If     lRet .AND. nField == 1
    If !Empty(FwFldGet(cTab+"_SUPP"))
        lRet:= ExistCpo("SA2",FwFldGet(cTab+"_SUPP"))
    EndIf
    // Question about supplier change removed by
    // https://jiraproducao.totvs.com.br/browse/RULOC-1009
ElseIf lRet .AND. nField == 2
    lRet:= ExistCpo("SA2",FwFldGet(cTab+"_SUPP")+FwFldGet(cTab+"_UNIT"))
Endif

RestArea(aSaveArea)

Return (lRet)


/*/{Protheus.doc} RU06D0504_VldFil
is called from x3_valid of F49_BNKREC(1), F49_RECBIK(3),F49_RECACC(4)
also it used by RU06D07 for validation
@param  nParam    Numeric   //1,3,4
        cTab      Caharacter // can be Nil, Default is __cTabHdr
@author eduardo.flima
@edit   asteapnov
@since 13/08/2018
@edition 30 September 2020
@version 2.0
@project MA3 - Russia
/*/
Function RU06D0504_VldFil(nParam, cTab)

Local lRet as Logical
Default nParam := 1
Default cTab   := __cTabHdr
lRet := .T.
If     nParam == 1 // validate F49_BNKREC
    If !Empty(FwFldGet(cTab+"_BNKREC"))
        lRet := RU06XFUN04_VldFIL(FWFldGet(cTab+"_SUPP"), FWFldGet(cTab+"_UNIT"), Val(FwFldGet(cTab+"_CURREN")), FWFldGet(cTab+"_BNKREC"),;
                           Nil, Nil, Nil, .F., .F.)
    EndIf
ElseIf nParam == 3   // validate F49_RECBIK
    lRet := RU06XFUN04_VldFIL(FWFldGet(cTab+"_SUPP"), FWFldGet(cTab+"_UNIT"), Val(FwFldGet(cTab+"_CURREN")), FWFldGet(cTab+"_BNKREC"),;
                              FWFldGet(cTab+"_RECBIK"), Nil, Nil, .F., .F.)
Elseif nParam == 4   // validate F49_RECACC
    lRet := RU06XFUN04_VldFIL(FWFldGet(cTab+"_SUPP"), FWFldGet(cTab+"_UNIT"), Val(FwFldGet(cTab+"_CURREN")), FWFldGet(cTab+"_BNKREC"),;
                              FWFldGet(cTab+"_RECBIK"), FWFldGet(cTab+"_RECACC"), Nil, .T., .F.)
EndIf

Return (lRet)


/*/{Protheus.doc} RU06D0505_ShwFil
is called from x3_relacao: 
// nNum==1 -> F49_TYPCC ; nNum==2 -> F49_ACRNAM
@author natalia.khozyainova
@since 12/11/2018
@version 2.0
@project MA3 - Russia
/*/
Function RU06D0505_ShwFil(nNum)
Local cRet as Character 
cRet:=RU06XFUN02_ShwFIL(nNum, FwFldGet("F49_SUPP"), FwFldGet("F49_UNIT"), FwFldGet("F49_BNKREC"), FwFldGet("F49_RECBIK"), FwFldGet("F49_RECACC"))
Return cRet


/*/
{Protheus.doc} RU06D0506_VldCur()
Currency validation
@author natalia.khozyainova
@since 30/07/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0506_VldCur()
Local lRet      as Logical
Local lMismatch as Logical
Local oModel    as Object
Local oModelF4A as Object
Local nX        as Numeric
Local nSize     as Numeric
Local cCurrF47 as Character

lRet:=.F.
lMismatch := .F.
lRet:= ExistCpo("CTO",FwFldGet("F49_CURREN"))
oModel := FWModelActive()
If lRet .AND. oModel:cSource == "RU06D05"
    oModelF4A := oModel:GetModel("RU06D05_MF4A")
    nSize:=oModelF4A:Length()
    cCurrF47:=""
    For nX := 1 To nSize
        oModelF4A:GoLine(nX)
        if !(oModelF4A:IsDeleted()) .and. lRet
            cCurrF47:=POSICIONE("F47",1,oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ")),"F47_CURREN")
            If (Alltrim(cCurrF47)!="" ) .AND. (cCurrF47 != FwFldGet("F49_CURREN"))
                lRet:=.F.
                lMismatch := .T.
            Endif
        EndIf
    Next nX
EndIf

If lRet .AND. oModel:cSource == "RU06D06"
    lRet := RU06D06010_ValidExRatDate()
EndIf

If !lRet
    If lMismatch
        Help("",1,STR0051,,STR0050,1,0,,,,,,{STR0052}) // Currency mismatch between PO header and payment requests included-- Currency --Delete payment requests attached
    EndIf    
EndIf

Return(lRet)

/*/
{Protheus.doc} RU06D0508_VldSa6()
validate Payer bank account, we use this function fro validation in RU06D07
@author natalia.khozyainova
@edit   astepanov
@param  Numeric   nParam
        Character cBCId     // BANK CODE ID, can be Nil, Defult is F49_BNKPAY
        Character cBICID    // BANK BIC ID,  can be Nil, Defult is F49_PAYBIK
        Character cAccID    // BANK ACCOUNT ID, can be Nil, Defult is F49_PAYACC
        Character cCurrID   // CURRENCY ID, can be Nil, Defult is F49_CURREN
@since 30/07/2018
@edition 25 September 2020, 03 November 2020
@version 2.0
@project MA3 - Russia
/*/
Function RU06D0508_VldSa6(nParam,cBCId, cBICID, cAccID, cCurrID)
Local lRet as Logical
Local aArea as Array
Local cAls as Character

Default nParam  := 0
Default cBCId   := __cTabHdr+"_BNKPAY"
Default cBICID  := __cTabHdr+"_PAYBIK"
Default cAccID  := __cTabHdr+"_PAYACC"
Default cCurrID := __cTabHdr+"_CURREN"

lRet :=  .T.

If     nParam == 0 // validate bank code
    If !Empty(FwFldGet(cBCId))
        aArea := GetArea()
        // this function have more complex rules for bankcode data extraction
        cAls := RU06XFUN39_RetBankAccountDataFromSA6(FwFldGet(cBCId),,,Val(FwFldGet(cCurrID)),.F.,.F.,.T.)
        DBSelectArea(cAls)
        (cAls)->(DbGoTop())
        If (cAls)->(Eof())
            lRet := .F.
        EndIf
        (cAls)->(DBCloseArea())
        RestArea(aArea)
    EndIf
ElseIf nParam == 3   // validate bank BIC (Business Identifier Code)
    lRet := ExistCpo("SA6",FwFldGet(cBCId)+FwFldGet(cBICID))
Elseif nParam == 4   // validate bank account
    lRet := ExistCpo("SA6",FwFldGet(cBCId)+FwFldGet(cBICID)+FwFldGet(cAccID))
EndIf

Return (lRet)


/*/
{Protheus.doc} RU06D0509_ShwSa6()
Banc and account name of payer - virtual fields initializer 
nNum==1 -> F49_BKPNAM;  nNum==2 -> F49_ACPNAM
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0509_ShwSa6(nNum)
Local cRet as Character 
cRet := RU06XFUN03_ShwSA6(nNum, FwFldGet("F49_BNKPAY"), FwFldGet("F49_PAYBIK"),  FwFldGet("F49_PAYACC"))
Return (cRet)


/*/{Protheus.doc} RU06D0541_CheckSA6
Function Used to check If we need to replace FIL table data 
@author Eduardo.Flima
@since 23/05/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0541_CheckSA6(cFll, cBnkCod, cBik, cAccnt, cCurr)
Local lRet as Logical
Local aSaveArea as Array
Local cQuery as Character

Default cFll:=XFILIAL("SA6")
Default cBnkCod:=FwFldGet("F49_BNKPAY")
Default cBik:=FwFldGet("F49_PAYBIK")
Default cAccnt:=FwFldGet("F49_PAYACC")
Default cCurr:=str(val(FwFldGet("F49_CURREN")))

cQuery := ""
aSaveArea := GetArea()

cQuery := "SELECT * FROM " + RetSQlName("SA6") + " SA6 " + chr(13) + chr(10)
cQuery += "WHERE A6_FILIAL = '" + cFll + "' " + chr(13) + chr(10)
cQuery += " AND A6_COD = '" + cBnkCod + "' " + chr(13) + chr(10)
cQuery += " AND A6_AGENCIA = '" + cBik + "' " + chr(13) + chr(10)
cQuery += " AND A6_NUMCON = '" + cAccnt + "' " + chr(13) + chr(10)
cQuery += " AND A6_MOEDA = " + cCurr + chr(13) + chr(10)
cQuery += " AND SA6.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery) 

If select("CHKSA6") > 0
    CHKFIL->(DbCloseArea())
Endif
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), "CHKSA6", .T., .F.)
dbSelectArea("CHKSA6")
lRet := CHKSA6->(Eof())
CHKSA6->(DbCloseArea())
RestArea(aSaveArea)

Return (lRet)

/*/
{Protheus.doc} RU06D0507_VldPrePay()
validation for field F49_PREPAY
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0507_VldPrePay()
Local lRet as Logical
Local oModel as Object
Local oModelVirt as Object
Local nQtyAPs as Numeric

lRet:=Pertence("12")
oModel:=FwModelActive()
oModelVirt:=oModel:GetModel("RU06D05_MVIRT")
nQtyAPs:=0

if !(RU06D0544_EmptyModel(oModelVirt, "B_NUM")) .and. FwFldGet("F49_PREPAY")=='1' .and. lRet
    lRet:=.F.
    Help("",1,STR0066,,STR0067,1,0,,,,,,{STR0068}) //Prepayment parameter -- Order for repayment can not include APs -- Change to not prepayment to add any PRs with APs
EndIf

Return (lRet)

/*/
{Protheus.doc} RU06D0512_InitOrdType()
MsgDialog - small scrin to initialize type of order by user selection from combobox
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0512_InitOrdType()
Local cPayType   as Character
cPayType := "1"
If Type("cRU06D05PT") == "C" // if defined private variable
    cPayType := cRU06D05PT
EndIf
Return (cPayType)


/*/
{Protheus.doc} RU06D0515_Brw()
function to be executed after view activate - it is needed to close Msdialog and to set some fields value
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0515_Brw(oView)
Local lRet     as Logical 
Local oModel   as Object

lRet := !(FwFldGet("F49_PAYTYP") == '0' )
oModel:=oView:GetModel()

If !lRet
    oView:lModify := .F. 
    oView:BUTTONCANCELACTION()
Else
    If oModel:GetOperation() != MODEL_OPERATION_VIEW .AND. oModel:GetOperation() != MODEL_OPERATION_DELETE
        oModel:GetModel("RU06D05_MF49"):SetValue("F49_FILIAL",xFilial("F49"))
    EndIf
    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        If     oModel:cSource == "RU06D05"
            oModel:GetModel("RU06D05_MF49"):SetValue("F49_REQUES","1")
        ElseIf oModel:cSource == "RU06D06"
            oModel:GetModel("RU06D05_MF49"):SetValue("F49_REQUES","2")
        EndIf
    EndIf
    If oModel:GetOperation() != MODEL_OPERATION_INSERT .AND. oModel:GetOperation() != MODEL_OPERATION_VIEW
        If oModel:cSource == "RU06D06"
            oModel:GetModel("RU06D05_MVIRT"):SetNoDeleteLine(.F.)
            oModel:GetModel("RU06D05_MVIRT"):SetNoUpdateLine(.F.)
        EndIf
    EndIf
    if oModel:IsCopy()
        If oModel:cSource != "RU06D06"
            RU06D0536_POReason(0,'',.T.)
        EndIf
    EndIf
    // load default bank account for selected currency. See:
    // https://jiraproducao.totvs.com.br/browse/RULOC-825
    If oModel:GetOperation() == MODEL_OPERATION_INSERT
        //keep [lLoad] as .F. because we should run trigger for this field
        //oView:Refresh() is obligatory after trigger runs
        FwFldPut("F49_BNKPAY",RU06D05493_GatBankPay("F49_BNKPAY",__cMdlHdr),,,,.F.)
    EndIf
    If oView != Nil
        oView:Refresh()
    EndIf 
Endif 

Return (lRet)


/*/
{Protheus.doc} RU06D0516_Status()
This function is temporary - until we develop the real rules to update statuses after operations
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0516_Status()
Local nRet as Numeric
Local aBtns as Array
Local aArea as Array
Local oModelPO as Object

nRet:=0
aBtns:={STR0114,STR0115,STR0006,STR0029}
nRet:=AVISO(STR0015,STR0113,aBtns,3)

aArea := GetArea()	
 // update or create
If nRet>0 .and. nRet<4  
    if ALLTRIM(DTOS(F49->F49_DTACTP))!='' .or. nRet!=3 
        dbSelectArea("F49")
        F49->(DbSetOrder(1))
        If F49->(DbSeek(F49->F49_FILIAL+F49->F49_PAYORD+F49->F49_BNKORD+DTOS(F49->F49_DTPAYM)))
            oModelPO:= FwLoadModel("RU06D05")
            oModelPO:SetOperation(4)
            oModelPO:Activate()
            oModelPO:GetModel("RU06D05_MF49"):SetValue("F49_STATUS", alltrim(str(nRet+1)))
            If oModelPO:VldData() 
                oModelPO:CommitData()
            EndIf
            oModelPO:DeActivate()
        EndIf

    Else
        Help("",1,STR0069,,STR0070,1,0,,,,,,{STR0071}) //Status update is not allowed -- Date of actual payment is not specified --  Specify date of actual payment
    EndIf
EndIf

RestArea(aArea)

Return NIL 



/*/
{Protheus.doc} RU06D0517_AddReqs()
Called from user button - Pick up Payment Requests
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0517_AddReqs()
Local oModel as Object
Local lCurrCor as Logical

if !(Empty(FwFldGet("F49_SUPP"))) .and. (ExistCpo("SA2",FwFldGet("F49_SUPP") + FwFldGet("F49_UNIT")))
    oModel:= FWModelActive()
    cPerg := "RUD605"
    
    // Update initial Ranges in Group of Questions:
    If !Empty(FwFldGet("F49_CURREN"))
        SetMVValue(cPerg,"MV_PAR09",FwFldGet("F49_CURREN"))
    EndIf

    If !Empty(FwFldGet("F49_FILREQ"))
        SetMVValue(cPerg,"MV_PAR10",FwFldGet("F49_FILREQ"))
    Else
        SetMVValue(cPerg,"MV_PAR10",xFilial("F49"))
    EndIf

    If Empty(FwFldGet("F49_CNT"))
        SetMVValue(cPerg,"MV_PAR07",Replicate(" ",TamSX3("F49_CNT")[1]))
        SetMVValue(cPerg,"MV_PAR08",Replicate("Z",TamSX3("F49_CNT")[1]))
    Else
        SetMVValue(cPerg,"MV_PAR07",oModel:GetValue('RU06D05_MF49','F49_CNT'))
        SetMVValue(cPerg,"MV_PAR08",oModel:GetValue('RU06D05_MF49','F49_CNT'))
    Endif

    If Empty(FwFldGet("F49_CLASS"))
        SetMVValue(cPerg,"MV_PAR05",Replicate(" ",TamSX3("F49_CLASS")[1]))
        SetMVValue(cPerg,"MV_PAR06",Replicate("Z",TamSX3("F49_CLASS")[1]))
    Else
        SetMVValue(cPerg,"MV_PAR05",oModel:GetValue('RU06D05_MF49','F49_CLASS'))
        SetMVValue(cPerg,"MV_PAR06",oModel:GetValue('RU06D05_MF49','F49_CLASS'))
    Endif

    lRet:= Pergunte(cPerg,.T.,STR0040,.F.) // Group of questions

    lCurrCor := RU06D0547_CheckCurrency(MV_PAR09, oModel)
    If (!empty(oModel:GetValue("RU06D05_MF49","F49_FILREQ")) .and. oModel:GetValue("RU06D05_MF49","F49_FILREQ") != MV_PAR10) .or. oModel:GetValue("RU06D05_MF49","F49_CURREN") != MV_PAR09
        While lRet .and. ((!empty(oModel:GetValue("RU06D05_MF49","F49_FILREQ")) .and. oModel:GetValue("RU06D05_MF49","F49_FILREQ") != MV_PAR10 ) .or. !lCurrCor)
            If !empty(oModel:GetValue("RU06D05_MF49","F49_FILREQ")) .and. oModel:GetValue("RU06D05_MF49","F49_FILREQ") != MV_PAR10 
                Help("",1,STR0087,,STR0088,1,0,,,,,,{STR0089}) //It is not allowed to select two payment requests from different branches -- Branch --  Choose the same Branch    
            ElseIf !lCurrCor
                Help("",1,STR0094,,STR0095,1,0,,,,,,{STR0096}) //It is not allowed to select payment requests in different currency -- Uncorrect currency --  Either it should delete included payments requests or it should select in the payment order currency
            EndIf
            lRet:= Pergunte(cPerg,.T.,STR0040,.F.) // Group of questions
            lCurrCor := RU06D0547_CheckCurrency(MV_PAR09, oModel)
        Enddo        
    Endif
    If lRet
        RU06D0518_MBrowse() // MarkBrowse is here
    Endif

Else
    Help("",1,STR0041,,STR0042,1,0,,,,,,{STR0043}) //Supplier field is empty -- Supplier --  Specify code and unit of supp
EndIf

Return (Nil)

/*/
{Protheus.doc} RU06D0518_MBrowse()
Markbrowse to select PRs 
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0518_MBrowse()
Local aSize     as Array
Local aStr      as Array // Structure to show
Local aColumns  as Array
Local nX        as Numeric 
Local cTitle    as Character

Private oMoreDlg    as Object
Private oBrowsePut  as Object
Private oTempTable  as Object
Private cTempTbl    as Character
Private cMark       as Character

aSize	:= MsAdvSize()
nX:=0
cTempTbl	:= CriaTrab(,.F.)
aStr	:= {}
aColumns 	:= {}
cTitle:=""

// Create temporary table
MsgRun(STR0026,STR0027,{|| RU06D0519_CreateTable()}) //"Please wait"//"Creating temporary table"

iF ((cTempTbl)->(Eof()))
    Help("",1,STR0044,,STR0036,1,0,,,,,,{STR0045}) // No requests found -- Pick Up PRs --Please, check parameters of the request 
Else
    aAdd( aStr, {"F47_FILIAL"	,RetTitle("F47_FILIAL") , PesqPict("F47","F47_FILIAL")})
    aAdd( aStr, {"F47_CODREQ"	,RetTitle("F47_CODREQ") , PesqPict("F47","F47_CODREQ")})
    aAdd( aStr, {"F47_DTPLAN"	,RetTitle("F47_DTPLAN") , PesqPict("F47","F47_DTPLAN")})
    aAdd( aStr, {"F47_PREPAY"	,RetTitle("F47_PREPAY") , PesqPict("F47","F47_PREPAY")})
    aAdd( aStr, {"F47_BNKCOD"	,RetTitle("F47_BNKCOD") , PesqPict("F47","F47_BNKCOD")})
    aAdd( aStr, {"F47_CNT"	    ,RetTitle("F47_CNT")    , PesqPict("F47","F47_CNT")})
    aAdd( aStr, {"F47_CLASS"	,RetTitle("F47_CLASS")  , PesqPict("F47","F47_CLASS")})
    aAdd( aStr, {"F47_CURREN"	,RetTitle("F47_CURREN") , PesqPict("F47","F47_CURREN")})
    aAdd( aStr, {"F47_VALUE"	,RetTitle("F47_VALUE")  , PesqPict("F47","F47_VALUE")})
    aAdd( aStr, {"F47_VRSN" 	,RetTitle("F47_REASON") , "@"})
    aAdd( aStr, {"F47_PAYORD"	,RetTitle("F47_PAYORD") , PesqPict("F47","F47_PAYORD")})
    aAdd( aStr, {"F49_DTPAYM"	,RetTitle("F49_DTPAYM") , PesqPict("F49","F49_DTPAYM")})

    For nX := 1 TO  11
        cTitle:=aStr[nX][1]
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStr[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStr[nX][2]) 

        if cTitle!="F47_VRSN"
            aColumns[Len(aColumns)]:SetSize(TamSx3(cTitle)[1]) 
            aColumns[Len(aColumns)]:SetDecimal(TamSx3(cTitle)[2])
        Else
            aColumns[Len(aColumns)]:SetSize(40) 
            aColumns[Len(aColumns)]:SetDecimal(0)
        EndIf
        aColumns[Len(aColumns)]:SetPicture(aStr[nX][3]) 

    Next nX

    oMoreDlg := MsDialog():New( aSize[7], aSize[2], aSize[6], aSize[5], STR0046, , , , , CLR_BLACK, CLR_WHITE, , , .T., , , , .T.) // Payment Requests available

    //MarkBrowse
    oBrowsePut := FWMarkBrowse():New()
    oBrowsePut:SetFieldMark("F47_OK")
    oBrowsePut:SetOwner(oMoreDlg)
    oBrowsePut:SetAlias(cTempTbl)
    aRotina	 := RU06D0520_MBrowseMenu() //Reset global aRotina
    oBrowsePut:SetColumns(aColumns)
    oBrowsePut:bAllMark := {||RU06D0535_MarkAll(oBrowsePut, cTempTbl)}

    oBrowsePut:DisableReport()
    oBrowsePut:Activate()
    cMark := oBrowsePut:Mark()
 
    oMoreDlg:Activate(,,,.T.,,,)

    If !Empty (cTempTbl)
        dbSelectArea(cTempTbl)
        dbCloseArea()
        cTempTbl := ""
        dbSelectArea("F47")
        dbSetOrder(1)
    EndIf

    If oTempTable <> Nil
        oTempTable:Delete()
        oTempTable := Nil
    Endif
eNDIF 
aRotina	 := MenuDef() //Return aRotina
return (.T.)

/*/
{Protheus.doc} RU06D0519_CreateTable()
temporary table for markbrowse
@author natalia.khozyainova
@since 17/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0519_CreateTable()
Local aFields   as Array
Local aColNames as Array
local cQuery    as Character
Local cQueryIns as Character
local cQueryDel as Character
Local oModel    as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local cSupp     as Character
Local cUnit     as Character
Local cCurr     as Character
Local cPrePay   as Character
Local cContract as Character
Local cTabName  as Character
Local nX        as Numeric
Local nStatus   as Numeric
Local cErrMsg   as Character
Local cVrsn     as Character
Local cDtPaym   as Character

oModel:=FWModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
cSupp:=oModelF49:GetValue("F49_SUPP")
cUnit:=oModelF49:GetValue("F49_UNIT")
cCurr:=oModelF49:GetValue("F49_CURREN")
cPrePay:=oModelF49:GetValue("F49_PREPAY")
cContract:=oModelF49:GetValue("F49_CNT")
cVrsn := "'" + Space(TamSX3("F47_VRSN")[1]) + "'" 
cDtPaym := "'" + Space(TamSX3("F49_DTPAYM")[1]) + "'" 

aFields := {}
aadd(aFields, {"F47_OK", "C", 1, 0})
aColNames := {"F47_FILIAL", "F47_CODREQ", "F47_DTPLAN", "F47_PREPAY", "F47_BNKCOD", "F47_CNT", "F47_CLASS",;
"F47_VALUE",  "F47_VRSN", "F47_PAYORD", "F49_DTPAYM", "F47_IDF47", "F47_CURREN", "F47_DTREQ"}
RU99XFUN10_AppendFields(aFields, aColNames, 0)

oTempTable := FWTemporaryTable():New(cTempTbl)
oTemptable:SetFields(aFields)
oTempTable:AddIndex("Indice1", {"F47_DTPLAN","F47_FILIAL","F47_CODREQ"} )
oTempTable:Create()
cTabName := oTempTable:GetRealName()

// Selection part of insertion query
cQuery := " SELECT DISTINCT '0' AS F47_OK, F47_FILIAL, F47_CODREQ, F47_DTPLAN, F47_PREPAY, F47_BNKCOD, F47_CNT,"
cQuery += " F47_CLASS, F47_VALUE, " + cVrsn + " AS F47_VRSN, F47_PAYORD, " + cDtPaym + " AS F49_DTPAYM, F47_IDF47, F47_CURREN, "
cQuery += " F47_DTREQ                          "
cQuery += " FROM " + RetSQLName("F47") + " F47 "
cQuery += " LEFT JOIN " + RetSQLName("F4A") + " F4A ON F4A_FILIAL=F47_FILIAL AND F4A_CODREQ=F47_CODREQ AND F4A_DTREQ=F47_DTREQ AND F4A.D_E_L_E_T_=' ' "
cQuery += " LEFT JOIN " + RetSQLName("F49") + " F49 ON F49_FILIAL=F4A_FILIAL AND F49_IDF49=F4A_IDF49 AND F49.D_E_L_E_T_=' ' "
cQuery += " LEFT JOIN " + RetSQLName("F5M") + " F5M ON F5M_KEY = F47_IDF47 AND F5M_KEYALI = 'F47' AND F5M.D_E_L_E_T_ = ' ' " // this is a connection to the list of payments F60
cQuery += " LEFT JOIN " + RetSQLName("F60") + " F60 ON F5M_IDDOC = F60_IDF60 AND F5M_ALIAS = 'F60'  AND F60.D_E_L_E_T_ = ' ' "// One entry in F60 matches several entries in F5M
cQuery += " WHERE (F49_IDF49 IS NULL OR F49_DTPAYM <= '" + DTOS(Date()-10) +"' ) "
cQuery += " AND F47.D_E_L_E_T_ =' ' "
cQuery += " AND F47_FILIAL ='" +  MV_PAR10  + "'"
cQuery += " AND F47_SUPP  = '" +  cSupp  + "'"
cQuery += " AND F47_UNIT  = '" +  cUnit  + "'"
cQuery += " AND F47_CURREN = '"+  MV_PAR09  + "'"
cQuery += " AND F47_CLASS BETWEEN '"+ MV_PAR05 +"' AND '" + MV_PAR06 + "'"
cQuery += " AND F47_CNT BETWEEN '"+ ALLTRIM(MV_PAR07) +"' AND '" + ALLTRIM(MV_PAR08) + "'"
cQuery += " AND F47_PAYTYP='1' "
//calculate the total list of payment valids, should be zero to allow add
cQuery += " AND ((( SELECT COUNT(F601.F60_FILIAL) FROM " + RetSQLName("F5M") + " F5M1 INNER JOIN " + RetSQLName("F60") 
cQuery += " F601 ON F5M1.F5M_IDDOC = F601.F60_IDF60 AND F5M1.F5M_ALIAS = 'F60' AND F601.D_E_L_E_T_ = ' ' WHERE F5M1.D_E_L_E_T_ =''	AND F601.F60_STATUS <> '4' AND F5M1.F5M_KEY = COALESCE(F5M.F5M_KEY, ' ')) <= 0 )"
cQuery += " OR COALESCE(F60.R_E_C_N_O_, -1) = -1 ) "  //This condition does not allow you to select an application for payment, which is included in the list of payments.

If SuperGetMv("MV_REQAPR",, 0)  == 1
    cQuery += " AND F47_STATUS IN ('4') "  //TODO Status '2' was remove ( if we keep it here, is possible add a PR that are already selected in other PO and this PO was not used at BS), this is confirme with Marina 27/07/2020 - 16:23 (Rafael, Eduardo and Marina)
Else        
    cQuery += " AND F47_STATUS IN ('1') "  //TODO Status '2' was remove ( if we keep it here, is possible add a PR that are already selected in other PO and this PO was not used at BS), this is confirme with Marina 27/07/2020 - 16:23 (Rafael, Eduardo and Marina)
EndIf

If cPrePay  == "1"
    cQuery += " AND F47_PREPAY = '1' "
EndIf

cQueryIns := RU99XFUN12_MakeInsertionQueryPart(aFields, cTabName)
cQueryIns += ChangeQuery(cQuery)

cErrMsg := ""
nStatus := TCSqlExec(cQueryIns)
If nStatus < 0
    cErrMsg := TCSQLError()
EndIf

For nX := 1 To oModelF4A:Length()
    oModelF4A:GoLine(nX)
    cQueryDel  := " DELETE FROM " + oTempTable:GetRealName()
    cQueryDel  += " WHERE F47_FILIAL ='" +xFilial("SE2")  + "'"
    cQueryDel  += " AND F47_CODREQ ='" + oModelF4A:GetValue("F4A_CODREQ")  + "'"
    cQueryDel  += " AND F47_DTREQ  ='" + DTOS(oModelF4A:GetValue("F4A_DTREQ")) + "'"
    nStatus := TCSqlExec(cQueryDel)
    If nStatus < 0
        cErrMsg := TCSQLError()
        Exit
    EndIf
Next nX

DbSelectArea(cTempTbl) 
DbGotop()
While (cTempTbl)->(!EOF())  
    (cTempTbl)->F47_VRSN := Posicione("F47",1,xFilial("F47")+(cTempTbl)->F47_CODREQ+DTOS((cTempTbl)->F47_DTREQ),"F47_REASON")
    if alltrim((cTempTbl)->F47_PAYORD)!=''
        (cTempTbl)->F49_DTPAYM := RU06D0413_ShwDtPaym((cTempTbl)->F47_PAYORD, (cTempTbl)->F47_CODREQ,(cTempTbl)->F47_DTREQ)
	EndIf
    (cTempTbl)->(DBSkip())
Enddo
DbGotop()
Return (NIL)


/*/
{Protheus.doc} RU06D0520_MBrowseMenu()
Menu for MarkBrowse
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0520_MBrowseMenu()
Local aRet as Array
aRet := {{STR0028,  "RU06D0521_WriteToModel()",  0, 4, 0, Nil},; //Add
		{STR0029,   "RU06D0522_MBrwCancel()",  0, 1, 0, Nil},; //Cancel
        {STR0030,   "RU06D0523_ShowPR()", 0, 1, 0, Nil}}  //Request Details
Return (aRet)


/*/
{Protheus.doc} RU06D0521_WriteToModel()
called after button Add in Markbrowse - writes PRs and APs to the model
@author natalia.khozyainova
@since 24/08/2018
@edit  astepanov   23 October 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0521_WriteToModel()
Local aArea         as Array
Local aAreaTmpTbl   as Array
Local oModelH       as Object
Local oModelF4A     as Object
Local oModelF4B     as Object
Local oModelVirt as Object
Local cQuery    as Character
Local cQueryLns as Character
Local cTab      as Character
Local cTabLns   as Character
Local oView     as Object
Local oGridFake as Object
Local oGridF4A as Object
Local oGridF4B as Object
Local nItemF    as Numeric
Local nItemF2    as Numeric
Local cF47ID    as Character
Local oModelPR as Object
Local oModelPO as Object
Local dDateToRecalc as Date
Local nRecalcCurr as Numeric
Local lNPrepay as Logical
Local cKeyF5M As Character
Local lRet    As Logical
Local lF47LineLk As Logical
Local nF47Recno  As Numeric

lRet        := .T.
aArea       := GetArea()
oModel      := FwModelActive()		
oModelH     := oModel:GetModel("RU06D05_MF49")
oModelF4A   := oModel:GetModel("RU06D05_MF4A")
oModelF4B   := oModel:GetModel("RU06D05_MF4B")
oModelVirt  := oModel:GetModel("RU06D05_MVIRT")
cF47ID      :=''
lNPrepay    :=.F.
nItemF:=1

aAreaTmpTbl := (cTempTbl)->(GetArea())
DBSetOrder(1)
DBGoTop()

While (cTempTbl)->(!EOF()) .and. !lNPrepay
    lNPrepay:= ((cTempTbl)->F47_OK == cMark) .and. (cTempTbl)->F47_PREPAY =="2"
    (cTempTbl)->(DBSkip())
Enddo
(cTempTbl)->(DbGoTop())
If !isBlind() .and.  oModelH:GetValue("F49_CURREN")=='01' .and. oModelH:GetValue("F49_PREPAY")!='1'.and. lNPrepay .and. RU06D0546_CheckConUni(oTempTable)
    nRecalcCurr:=AVISO(STR0082,STR0083,; // Currency recalculation - Please, be awared: this recalculation will update rates in PR as well. Which date use to recalculate currency? 
    {STR0084,STR0085,STR0029},3)
Else
    nRecalcCurr:=3
EndIf

If isBlind() .And. oModelH:GetValue("F49_CURREN") <> '01'
    nRecalcCurr:=1
EndIf
dDateToRecalc := if( nRecalcCurr == 1 , oModelH:GetValue("F49_DTPAYM"), NIL)

While !((cTempTbl)->(Eof())) .AND. lRet
    lF47LineLk := .F.
    If ((cTempTbl)->F47_OK == cMark)
        oModelF4A:SetNoUpdateLine(.F.)
        If !EMPTY(oModelF4A:GetValue("F4A_DTREQ",oModelF4A:Length())) .or. oModelF4A:IsDeleted()// create new line if the last one is not empty
            oModelF4A:SetNoInsertLine(.F.)
            nItemF := oModelF4A:AddLine()
            oModelF4A:SetNoInsertLine(.T.)            
        Endif
        oModelF4A:GoLine(oModelF4A:Length()) // put cursor on new line

        if oModelH:GetValue("F49_CURREN")=='01'
            if nRecalcCurr==1 .or. nRecalcCurr==2
                oModelPO:=oModel
                dbSelectArea("F47")
                F47->(DbSetOrder(1))
                If F47->(DbSeek((cTempTbl)->F47_FILIAL+(cTempTbl)->F47_CODREQ+DTOS((cTempTbl)->F47_DTREQ)))
                    If RecLock("F47",.F.)
                        lF47LineLk := .T.
                        nF47Recno  := F47->(Recno())
                        oModelPR:= FwLoadModel("RU06D04")
                        oModelPR:SetOperation(4)
                        lRet := lRet .AND. RU06D0401_RecalcCurrency(.T., @oModelPR, 1, dDateToRecalc )
                        oModel:=oModelPO
                    Else
                        lRet := .F.
                    EndIf
                EndIf
            EndIf
        EndIf
        If lRet
            cQuery := "SELECT * FROM " + RetSQLName("F47")
            cQuery += " WHERE F47_FILIAL ='" + (cTempTbl)->F47_FILIAL +"'"
            cQuery += " AND F47_IDF47 ='" + (cTempTbl)->F47_IDF47 +"'"
            cQuery += " AND D_E_L_E_T_ =' '"
            
            cQuery := ChangeQuery(cQuery)
            cTab := CriaTrab( , .F.)
            TcQuery cQuery New Alias ((cTab))

            DbSelectArea((cTab))
            (cTab)->(DbGoTop())

            If Empty(oModelH:GetValue("F49_FILREQ"))
                F47->(DbSetOrder(1))
                If F47->(DbSeek((cTempTbl)->F47_FILIAL+(cTempTbl)->F47_CODREQ+DTOS((cTempTbl)->F47_DTREQ)))        
                    oModelH:LoadValue("F49_FILREQ",(cTempTbl)->F47_FILIAL)
                Endif               
            Endif 

            oModelF4A:LoadValue("F4A_FILIAL", xFilial ("F4A")) 
            oModelF4A:LoadValue("F4A_IDF4A", (cTab)->F47_IDF47 )
            oModelF4A:LoadValue("F4A_IDF49", oModelH:GetValue("F49_IDF49"))	
            oModelF4A:LoadValue("F4A_CODREQ", (cTab)->F47_CODREQ )	
            oModelF4A:LoadValue("F4A_DTREQ", STOD((cTab)->F47_DTREQ))
            oModelF4A:LoadValue("F4A_PREPAY",(cTab)->F47_PREPAY )
            oModelF4A:LoadValue("F4A_BNKCOD", (cTab)->F47_BNKCOD)	
            oModelF4A:LoadValue("F4A_CNT", (cTab)->F47_CNT)
            oModelF4A:LoadValue("F4A_CLASS", (cTab)->F47_CLASS)
            oModelF4A:LoadValue("F4A_VALUE", (cTab)->F47_VALUE)
            oModelF4A:LoadValue("F4A_VATCOD", (cTab)->F47_VATCOD)
            oModelF4A:LoadValue("F4A_VATRAT", (cTab)->F47_VATRAT)
            oModelF4A:LoadValue("F4A_VATAMT", (cTab)->F47_VATAMT)
            oModelF4A:LoadValue("F4A_REASON", LEFT(alltrim(Posicione("F47",1,(cTab)->F47_FILIAL+(cTab)->F47_CODREQ+(cTab)->F47_DTREQ,"F47_REASON")),210))
            oModelF4A:LoadValue("F4A_FILREQ", (cTab)->F47_FILIAL)
            
            cF47ID:=(cTab)->F47_IDF47

            cQueryLns := "SELECT * FROM " + RetSQLName("F48") + " F48 "
            cQueryLns += " LEFT JOIN "+ RetSQLName("SE2") + " SE2 "
            cQueryLns += " ON (SE2.E2_FILIAL=F48.F48_FLORIG AND SE2.E2_PREFIXO=F48.F48_PREFIX AND SE2.E2_NUM=F48.F48_NUM  "
            cQueryLns += " AND SE2.E2_PARCELA=F48.F48_PARCEL AND SE2.E2_TIPO=F48.F48_TYPE "
            cQueryLns += " AND SE2.E2_FORNECE='"+oModelH:GetValue("F49_SUPP")+"'          "
            cQueryLns += " AND SE2.E2_LOJA='"+oModelH:GetValue("F49_UNIT")+"'             "
            cQueryLns += " AND SE2.D_E_L_E_T_ =' '                                        "
            cQueryLns += "    )                                                           "
            cQueryLns += " WHERE F48_FILIAL ='" + MV_PAR10 +"'"
            cQueryLns += " AND F48_IDF48 ='" + cF47ID +"'"
            cQueryLns += " AND F48.D_E_L_E_T_ =' ' "
            
            cQueryLns := ChangeQuery(cQueryLns)
            cTabLns := CriaTrab( , .F.)
            TcQuery cQueryLns New Alias ((cTabLns))
            
            DbSelectArea((cTabLns))
            (cTabLns)->(DbGoTop())
            while !((cTabLns)->(Eof()))
                If !EMPTY(oModelF4B:GetValue("F4B_NUM",oModelF4B:Length())) .or. oModelF4B:IsDeleted() // create new line if the last one is not empty
                    oModelF4B:SetNoInsertLine(.F.)
                    nItemF2 := oModelF4B:AddLine()
                    oModelF4B:SetNoInsertLine(.T.)            
                Endif
                oModelF4B:GoLine(oModelF4B:Length()) // put cursor on new line

                oModelF4B:LoadValue("F4B_FILIAL", xFilial ("F4B")) 
                oModelF4B:LoadValue("F4B_UUID", FWUUIDV4()) 
                oModelF4B:LoadValue("F4B_IDF4A", (cTabLns)->F48_IDF48)
                oModelF4B:LoadValue("F4B_IDF49", oModelH:GetValue("F49_IDF49"))	
                oModelF4B:LoadValue("F4B_PREFIX", (cTabLns)->F48_PREFIX )	
                oModelF4B:LoadValue("F4B_NUM", (cTabLns)->F48_NUM )	
                oModelF4B:LoadValue("F4B_PARCEL",(cTabLns)->F48_PARCEL )
                oModelF4B:LoadValue("F4B_TYPE", (cTabLns)->F48_TYPE)	
                oModelF4B:LoadValue("F4B_CLASS", (cTabLns)->E2_NATUREZ)
                oModelF4B:LoadValue("F4B_EMISS", STOD((cTabLns)->E2_EMISSAO))
                oModelF4B:LoadValue("F4B_REALMT", STOD((cTabLns)->E2_VENCREA))
                oModelF4B:LoadValue("F4B_VALPAY", (cTabLns)->F48_VALREQ)
                oModelF4B:LoadValue("F4B_VALUE", (cTabLns)->E2_VALOR)
                oModelF4B:LoadValue("F4B_CURREN", (cTabLns)->E2_MOEDA)
                oModelF4B:LoadValue("F4B_CONUNI", (cTabLns)->F48_CONUNI)
                oModelF4B:LoadValue("F4B_VLCRUZ", (cTabLns)->E2_VLCRUZ)
                            
                cKeyF5M:=xFilial("SE2")+"|"+(cTabLns)->F48_PREFIX+"|"+;
                (cTabLns)->F48_NUM+"|"+(cTabLns)->F48_PARCEL+"|"+(cTabLns)->F48_TYPE+"|"+;
                (cTab)->F47_SUPP+"|"+(cTab)->F47_UNIT    
                oModelF4B:LoadValue("F4B_OPBAL", RU06XFUN06_GetOpenBalance(cKeyF5M) +;
                Posicione("F5M",1,xFilial("F5M")+"F48"+(cTabLns)->F48_UUID+cKeyF5M,"F5M_VALPAY"))
                
                oModelF4B:LoadValue("F4B_BSIMP1", (cTabLns)->E2_BASIMP1)
                oModelF4B:LoadValue("F4B_ALIMP1", (cTabLns)->E2_ALQIMP1)

                oModelF4B:LoadValue("F4B_VLIMP1", (cTabLns)->F48_VLIMP1)
                //line before strange because F4B_BSIMP1 value we get from E2_BASIMP1,
                //but F4B_VLIMP1 from F48_VLIMP1. F48_VLIMP1 we calculate in RU06D04 like:
                //(((cTab)->E2_VALIMP1) * (oModelL:GetValue("F48_VALREQ")/oModelL:GetValue("F48_VALUE") ))
                //so we use proportion, but for F48_BSIMP1 we use E2_BASIMP1:
                //oModelL:LoadValue("F48_BSIMP1",(cTab)->E2_BASIMP1)
                //So if we'll summirize F4B_VLIMP1 and F4B_BSIMP1 we will get strange amount
                //it will not be F4B_VALPAY and it will not be a F4B_VALUE.
                //astepanov 23 October 2020
                
                oModelF4B:LoadValue("F4B_MDCNTR", (cTabLns)->E2_F5QCODE)
                oModelF4B:LoadValue("F4B_FLORIG", (cTabLns)->F48_FLORIG)

                oModelF4B:LoadValue("F4B_RATUSR", (cTabLns)->F48_RATUSR)
                oModelF4B:LoadValue("F4B_EXGRAT", (cTabLns)->F48_EXGRAT)
                oModelF4B:LoadValue("F4B_CHECK", if((cTabLns)->F48_RATUSR == '1',.T.,.F.))
                oModelF4B:LoadValue("F4B_VALCNV", (cTabLns)->F48_VALCNV)
                oModelF4B:LoadValue("F4B_BSVATC", (cTabLns)->F48_BSVATC)
                oModelF4B:LoadValue("F4B_VLVATC", (cTabLns)->F48_VLVATC)

                (cTabLns)->(DbSkip())
                
            Enddo

            If Empty(oModelH:GetValue("F49_PREPAY")) .or. nItemF==1
                oModelH:SetValue("F49_PREPAY",(cTab)->F47_PREPAY)
            Elseif oModelH:GetValue("F49_PREPAY")=='1' .and. (cTab)->F47_PREPAY=='2'
                oModelH:SetValue("F49_PREPAY",(cTab)->F47_PREPAY)
            EndIf

            If Empty(oModelH:GetValue("F49_CLASS")) 
                oModelH:SetValue("F49_CLASS",(cTab)->F47_CLASS)
            EndIf

            If Empty(oModelH:GetValue("F49_VATRAT"))
                oModelH:SetValue("F49_VATRAT",(cTab)->F47_VATRAT)
            EndIf

            If Empty(oModelH:GetValue("F49_CNT")) .and. oModelH:GetValue("F49_REQUES") == "1" // Filled in only if a new payment request is generated from another payment request.
                oModelH:SetValue("F49_CNT",(cTab)->F47_CNT)
            EndIf

            If Empty(oModelH:GetValue("F49_F5QUID"))
                oModelH:SetValue("F49_F5QUID",(cTab)->F47_F5QUID)
            EndIf

            If Empty(oModelH:GetValue("F49_BNKREC"))
                oModelH:SetValue("F49_BNKREC",(cTab)->F47_BNKCOD)
            EndIf

            If Empty(oModelH:GetValue("F49_RECBIK"))
                oModelH:SetValue("F49_RECBIK",(cTab)->F47_BIK)
            EndIf

            If Empty(oModelH:GetValue("F49_RECACC"))
                oModelH:SetValue("F49_RECACC",(cTab)->F47_ACCNT)
            EndIf

            If Empty(oModelH:GetValue("F49_CTPRE")) .AND. !Empty((cTab)->F47_CTPRE)
                oModelH:SetValue("F49_CTPRE",(cTab)->F47_CTPRE)
            EndIf

            If Empty(oModelH:GetValue("F49_CTPOS")) .AND. !Empty((cTab)->F47_CTPOS)
                oModelH:SetValue("F49_CTPOS",(cTab)->F47_CTPOS)
            EndIf

            If Empty(oModelH:GetValue("F49_CCPRE")) .AND. !Empty((cTab)->F47_CCPRE)
                oModelH:SetValue("F49_CCPRE",(cTab)->F47_CCPRE)
            EndIf

            If Empty(oModelH:GetValue("F49_CCPOS")) .AND. !Empty((cTab)->F47_CCPOS)
                oModelH:SetValue("F49_CCPOS",(cTab)->F47_CCPOS)
            EndIf

            If Empty(oModelH:GetValue("F49_ITPRE")) .AND. !Empty((cTab)->F47_ITPRE)
                oModelH:SetValue("F49_ITPRE",(cTab)->F47_ITPRE)
            EndIf

            If Empty(oModelH:GetValue("F49_ITPOS")) .AND. !Empty((cTab)->F47_ITPOS)
                oModelH:SetValue("F49_ITPOS",(cTab)->F47_ITPOS)
            EndIf

            If Empty(oModelH:GetValue("F49_CLPRE")) .AND. !Empty((cTab)->F47_CLPRE)
                oModelH:SetValue("F49_CLPRE",(cTab)->F47_CLPRE)
            EndIf

            If Empty(oModelH:GetValue("F49_CLPOS")) .AND. !Empty((cTab)->F47_CLPOS)
                oModelH:SetValue("F49_CLPOS",(cTab)->F47_CLPOS)
            EndIf

            If nItemF==1 .or. Empty(oModelH:GetValue("F49_KPPREC"))
                oModelH:SetValue("F49_KPPREC",(cTab)->F47_KPPREC)
            EndIf

            If oModelH:GetValue("F49_CURREN") <> (cTab)->F47_CURREN
                oModelH:SetValue("F49_CURREN",(cTab)->F47_CURREN)
            EndIf

            RU06D0542_SortF4A(oModelF4A)
        EndIf
    EndIf
    If lF47LineLk
        F47->(DBGoto(nF47Recno))
        F47->(MSUnlock())
    Endif
    (cTempTbl)->(DbSkip())
Enddo
If lRet
    oModelF4A:SetNoUpdateLine(.T.)
    RU06D0543_VrtModel(oModel)
    RU06D0531_TOTLS(.T.)
    RU06D0536_POReason()
    RU06D0545_PutSuppAcc()
EndIf

If !isBlind()
    oView	:= FWViewActive()
    oGridFake:= oView:GetViewObj("RU06D05_VVIRT")[3]
    oGridF4A:= oView:GetViewObj("RU06D05_VLNS")[3]
    oGridF4B:= oView:GetViewObj("RU06D05_VGLNS")[3]

    oGridF4A:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
    oGridFake:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)
    oGridF4B:Refresh( .T. /* lEvalChanges */, .T. /* lGoTop */)

    oMoreDlg:End()
EndIf
If !Empty(cTab)
    (cTab)->(DBCloseArea())
EndIf
If !Empty(cTabLns)
    (cTabLns)->(DBCloseArea())
EndIf
RestArea(aArea)

Return (lRet)


/*/
{Protheus.doc} RU06D0522_MBrwCancel()
Close markbrowse dialog when cancel
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0522_MBrwCancel()
oMoreDlg:End()
return .F.

/*/
{Protheus.doc} RU06D0523_ShowPR()
Link from markbrowse to AP
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0523_ShowPR()
Local aArea as Array
Local cKey as Character

aArea := (cTempTbl)->(GetArea())	
cKey:=(cTempTbl)->F47_FILIAL+(cTempTbl)->F47_CODREQ+DTOS((cTempTbl)->F47_DTREQ)
RestArea(aArea)

dbSelectArea("F47")
F47->(DbSetOrder(1))
If F47->(DbSeek(cKey))
    FWExecView("View Request details","RU06D04",MODEL_OPERATION_VIEW,,{|| .T.})
EndIf
DbCloseArea()
return Nil



/*/
{Protheus.doc} RU06D0524_PR2Click()
Doubleclick on payment request - link to RU06D04
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0524_PR2Click(oFormula, cFieldName, nLineGrid, nLineModel)
Local aArea		:= GetArea()
Local aAreaF47	:= Eval({||DbSelectArea("F47"),F47->(GetArea())})
Local oModel as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local lRet as Logical

Default oFormula:=NIL
Default cFieldName:=""
Default nLineGrid:=0
Default nLineModel:=0

lRet:=.T.
oModel:=FwModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
IF !(oModelF4A:CanSetValue(cFieldName))
    F47->(DbSetOrder(1))
    If DbSeek(oModelF4A:GetValue("F4A_FILREQ")+oModelF4A:GetValue("F4A_CODREQ")+DTOS(oModelF4A:GetValue("F4A_DTREQ")))
        FWExecView("View Request details","RU06D04",MODEL_OPERATION_VIEW,,{|| .T.})
        lRet:=.F.
    EndIf
    RestArea(aAreaF47)
    RestArea(aArea)
EndIf

Return (lRet)



/*/
{Protheus.doc} RU06D0538_AP2Click()
Doubleclick on AP - link to FINA050
@author natalia.khozyainova, Nikitenko Artem
@since 24/08/2018, 02.09.2020
@version 1.1
@project MA3 - Russia
/*/
Static Function RU06D0538_AP2Click(oFormula, cFieldName, nLineGrid, nLineModel )
Local aArea		:= GetArea()
Local aAreaSE2	:= Eval({||DbSelectArea("SE2"),SE2->(GetArea())})
Local oModel as Object
Local oModelF49 as Object
Local oModelF4B as Object
Local cKey as Character
Local lRet as Logical

Default oFormula:=NIL
Default cFieldName:=""
Default nLineGrid:=0
Default nLineModel:=0

lRet:=.T.
oModel:=FwModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4B:=oModel:GetModel(oFormula:GetModel():GetID())
cId = iif(oFormula:GetModel():GetID() == 'RU06D05_MVIRT', 'B_', 'F4B_')
cKey:= xFilial("SE2")+oModelF4B:GetValue(cId +"PREFIX")+oModelF4B:GetValue(cId +"NUM")+oModelF4B:GetValue(cId +"PARCEL")+;
oModelF4B:GetValue(cId +"TYPE")+oModelF49:GetValue("F49_SUPP")+oModelF49:GetValue("F49_UNIT")

IF !(oModelF4B:CanSetValue(cFieldName))
    SE2->(DbSetOrder(1))
        If DbSeek(cKey)
            dbSelectArea("SA2")
            dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
            cCadastro := STR0100
            AxVisual('SE2',SE2->(RecNo()),2,,4,SA2->A2_NOME,"FA050MCPOS",fa050BAR('SE2->E2_PROJPMS == "1"')   )
            lRet:=.F.
        EndIf
    RestArea(aAreaSE2)
    RestArea(aArea)
EndIf

Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0525_DefVirtStr
Virtual structure for gridd of All Bills
@author eduardo.flima
@since 17/04/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0525_DefVirtStr(lBS as Logical)
Local oStruct   as Object
Local aArea     as Array
Local cWhen     as Character
Default lBS:=.F.
If lBS
    cWhen:= "lBS .and. FwFldGet('B_CONUNI') == '1' "
Else
    cWhen:=".F."
EndIf
aArea	:=GetArea()
oStruct :=FWFormModelStruct():New()

// Table 
oStruct:AddTable("", , "Bills")

// Indexes 
oStruct:AddIndex(   1, ;     // [01] Index Order
		"01", ;     // [02] ID
		"B_BRANCH + B_CODREQ + B_PREFIX + B_NUM + B_PARCEL + B_TYPE", ; 	// [03] Key of Index
		"Virt_Bills"	, ; 	// [04] Description of Index
		""			, ;    	// [05] Lookup Expression 
		""			, ;    	// [06] Index Nickname
		.T. )				// [07] Index used on interface


// Fields
//               Titulo,                       ToolTip,          Field ID,   Tipo,                                          Tam,                                          Dec,                           Valid   ,When,   Combo,Obrigat,Init, Chave, Altera,   Virtual

oStruct:AddField("B_BRANCH"             ,"B_BRANCH"             ,"B_BRANCH" ,GetSX3Cache("F4B_FILIAL", "X3_TIPO"), GetSX3Cache("F4B_FILIAL", "X3_TAMANHO")   ,GetSX3Cache("F4B_FILIAL", "X3_DECIMAL")  ,Nil ,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Branch
oStruct:AddField(RetTitle("F4B_RATUSR") ,RetTitle("F4B_RATUSR") ,"B_CHECK"  ,"L"                                 , 1                                         ,0                                        ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Currency Rate is Manual
oStruct:AddField(RetTitle("F4A_CODREQ") ,RetTitle("F4A_CODREQ") ,"B_CODREQ" ,GetSX3Cache("F4A_CODREQ", "X3_TIPO"), GetSX3Cache("F4A_CODREQ", "X3_TAMANHO")   ,GetSX3Cache("F4A_CODREQ", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Request Code
oStruct:AddField(RetTitle("F4B_PREFIX") ,RetTitle("F4B_PREFIX") ,"B_PREFIX" ,GetSX3Cache("F4B_PREFIX", "X3_TIPO"), GetSX3Cache("F4B_PREFIX", "X3_TAMANHO")   ,GetSX3Cache("F4B_PREFIX", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Prefix
oStruct:AddField(RetTitle("F4B_NUM")    ,RetTitle("F4B_NUM")    ,"B_NUM"    ,GetSX3Cache("F4B_NUM", "X3_TIPO"),    GetSX3Cache("F4B_NUM", "X3_TAMANHO")      ,GetSX3Cache("F4B_NUM", "X3_DECIMAL")     ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Number
oStruct:AddField(RetTitle("F4B_PARCEL") ,RetTitle("F4B_PARCEL") ,"B_PARCEL" ,GetSX3Cache("F4B_PARCEL", "X3_TIPO"), GetSX3Cache("F4B_PARCEL", "X3_TAMANHO")   ,GetSX3Cache("F4B_PARCEL", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Parcel
oStruct:AddField(RetTitle("F4B_TYPE")   ,RetTitle("F4B_TYPE")   ,"B_TYPE"   ,GetSX3Cache("F4B_TYPE", "X3_TIPO"),   GetSX3Cache("F4B_TYPE", "X3_TAMANHO")     ,GetSX3Cache("F4B_TYPE", "X3_DECIMAL")    ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Type
oStruct:AddField(RetTitle("F4B_CLASS")  ,RetTitle("F4B_CLASS")  ,"B_CLASS"  ,GetSX3Cache("F4B_CLASS", "X3_TIPO"),  GetSX3Cache("F4B_CLASS", "X3_TAMANHO")    ,GetSX3Cache("F4B_CLASS", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,NIL     ,NIL    ,NIL    ,.F.)   // Class
oStruct:AddField(RetTitle("F4B_EMISS")  ,RetTitle("F4B_EMISS")  ,"B_EMISS"  ,GetSX3Cache("F4B_EMISS", "X3_TIPO"),  GetSX3Cache("F4B_EMISS", "X3_TAMANHO")    ,GetSX3Cache("F4B_EMISS", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Emissao Date
oStruct:AddField(RetTitle("F4B_REALMT") ,RetTitle("F4B_REALMT") ,"B_REALMT" ,GetSX3Cache("F4B_REALMT", "X3_TIPO"), GetSX3Cache("F4B_REALMT", "X3_TAMANHO")   ,GetSX3Cache("F4B_REALMT", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Real maturity date
oStruct:AddField(RetTitle("F4B_VALPAY") ,RetTitle("F4B_VALPAY") ,"B_VALPAY" ,GetSX3Cache("F4B_VALPAY", "X3_TIPO"), GetSX3Cache("F4B_VALPAY", "X3_TAMANHO")   ,GetSX3Cache("F4B_VALPAY", "X3_DECIMAL")  ,Nil	,{|| lBS}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Value to pay
oStruct:AddField(RetTitle("F4B_EXGRAT") ,RetTitle("F4B_EXGRAT") ,"B_EXGRAT" ,GetSX3Cache("F4B_EXGRAT", "X3_TIPO"), GetSX3Cache("F4B_EXGRAT", "X3_TAMANHO")   ,GetSX3Cache("F4B_EXGRAT", "X3_DECIMAL")  ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Exchange Rate
oStruct:AddField(RetTitle("F4B_VALCNV") ,RetTitle("F4B_VALCNV") ,"B_VALCNV" ,GetSX3Cache("F4B_VALCNV", "X3_TIPO"), GetSX3Cache("F4B_VALCNV", "X3_TAMANHO")   ,GetSX3Cache("F4B_VALCNV", "X3_DECIMAL")  ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Exchange Rate
oStruct:AddField(RetTitle("F4B_BSVATC") ,RetTitle("F4B_BSVATC") ,"B_BSVATC" ,GetSX3Cache("F4B_BSVATC", "X3_TIPO"), GetSX3Cache("F4B_BSVATC", "X3_TAMANHO")   ,GetSX3Cache("F4B_BSVATC", "X3_DECIMAL")  ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Exchange Rate
oStruct:AddField(RetTitle("F4B_VLVATC") ,RetTitle("F4B_VLVATC") ,"B_VLVATC" ,GetSX3Cache("F4B_VLVATC", "X3_TIPO"), GetSX3Cache("F4B_VLVATC", "X3_TAMANHO")   ,GetSX3Cache("F4B_VLVATC", "X3_DECIMAL")  ,Nil	,{|| &(cWhen)}  ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Exchange Rate
oStruct:AddField(RetTitle("F4B_VALUE")  ,RetTitle("F4B_VALUE")  ,"B_VALUE"  ,GetSX3Cache("F4B_VALUE", "X3_TIPO"),  GetSX3Cache("F4B_VALUE", "X3_TAMANHO")    ,GetSX3Cache("F4B_VALUE", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Value from bill
oStruct:AddField(RetTitle("F4B_CURREN") ,RetTitle("F4B_CURREN") ,"B_CURREN" ,GetSX3Cache("F4B_CURREN", "X3_TIPO"), GetSX3Cache("F4B_CURREN", "X3_TAMANHO")   ,GetSX3Cache("F4B_CURREN", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Currency 
oStruct:AddField(RetTitle("F4B_CONUNI") ,RetTitle("F4B_CONUNI") ,"B_CONUNI" ,GetSX3Cache("F4B_CONUNI", "X3_TIPO"), GetSX3Cache("F4B_CONUNI", "X3_TAMANHO")   ,GetSX3Cache("F4B_CONUNI", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Conventional units 
oStruct:AddField(RetTitle("F4B_VLCRUZ") ,RetTitle("F4B_VLCRUZ") ,"B_VLCRUZ" ,GetSX3Cache("F4B_VLCRUZ", "X3_TIPO"), GetSX3Cache("F4B_VLCRUZ", "X3_TAMANHO")   ,GetSX3Cache("F4B_VLCRUZ", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Value in local currency
oStruct:AddField(RetTitle("F4B_OPBAL")  ,RetTitle("F4B_OPBAL")  ,"B_OPBAL"  ,GetSX3Cache("F4B_OPBAL", "X3_TIPO"),  GetSX3Cache("F4B_OPBAL", "X3_TAMANHO")    ,GetSX3Cache("F4B_OPBAL", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Open balance 
oStruct:AddField(RetTitle("F4B_BSIMP1") ,RetTitle("F4B_BSIMP1") ,"B_BSIMP1" ,GetSX3Cache("F4B_BSIMP1", "X3_TIPO"), GetSX3Cache("F4B_BSIMP1", "X3_TAMANHO")   ,GetSX3Cache("F4B_BSIMP1", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // VAT Base
oStruct:AddField(RetTitle("F4B_ALIMP1") ,RetTitle("F4B_ALIMP1") ,"B_ALIMP1" ,GetSX3Cache("F4B_ALIMP1", "X3_TIPO"), GetSX3Cache("F4B_ALIMP1", "X3_TAMANHO")   ,GetSX3Cache("F4B_ALIMP1", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // VAT Rate
oStruct:AddField(RetTitle("F4B_VLIMP1") ,RetTitle("F4B_VLIMP1") ,"B_VLIMP1" ,GetSX3Cache("F4B_VLIMP1", "X3_TIPO"), GetSX3Cache("F4B_VLIMP1", "X3_TAMANHO")   ,GetSX3Cache("F4B_VLIMP1", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // VAT Value
oStruct:AddField(RetTitle("F4B_MDCNTR") ,RetTitle("F4B_MDCNTR") ,"B_MDCNTR" ,GetSX3Cache("F4B_MDCNTR", "X3_TIPO"), GetSX3Cache("F4B_MDCNTR", "X3_TAMANHO")   ,GetSX3Cache("F4B_MDCNTR", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Contract number from bill
oStruct:AddField(RetTitle("F4B_FLORIG") ,RetTitle("F4B_FLORIG") ,"B_FLORIG" ,GetSX3Cache("F4B_FLORIG", "X3_TIPO"), GetSX3Cache("F4B_FLORIG", "X3_TAMANHO")   ,GetSX3Cache("F4B_FLORIG", "X3_DECIMAL")  ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Filial of Request
oStruct:AddField(RetTitle("F4B_IDF4A")  ,RetTitle("F4B_IDF4A")  ,"B_IDF4A"  ,GetSX3Cache("F4B_IDF4A", "X3_TIPO"),  GetSX3Cache("F4B_IDF4A", "X3_TAMANHO")    ,GetSX3Cache("F4B_IDF4A", "X3_DECIMAL")   ,Nil	,{|| .F.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // Filial of Request
oStruct:AddField(RetTitle("F4B_RATUSR") ,RetTitle("F4B_RATUSR") ,"B_RATUSR" ,GetSX3Cache("F4B_RATUSR", "X3_TIPO"), GetSX3Cache("F4B_RATUSR", "X3_TAMANHO")   ,GetSX3Cache("F4B_RATUSR", "X3_DECIMAL")  ,Nil	,{|| .T.}       ,{} ,.F.    ,Nil     ,NIL    ,NIL    ,.F.)   // If Currency Rate is Manual

RestArea(aArea)

Return (oStruct)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0526_LoadBills
Load function for virtual grid - All Bills
@author eduardo.flima
@since 17/04/2018
@edit  astepanov 22 November 2020
@version 1.1
@project MA3 - Russia
/*/
Static Function RU06D0526_LoadBills(oModel)
Local aLines     as Array
Local aVrtFields as Array
Local aArea      as Array
Local aTmp       as Array
Local cTab       as Character
Local nX         as Numeric
Local xVal

aLines     := {}
aArea      := GetArea()
aVrtFields := ACLONE(oModel:GetStruct():GetFields())
cTab       := RU06XFUN77_RetVrtLinesForPO(aVrtFields,FWFldGet("F49_SUPP"),FWFldGet("F49_UNIT"),FwFldGet("F49_IDF49"))
DBSelectArea(cTab)
(cTab)->(DBGoTop())
While (cTab)->(!EoF())
    aTmp := {}
    For nX := 1 To Len(aVrtFields)
        If aVrtFields[nX][4] == "C"
            xVal := PADR((cTab)->&(aVrtFields[nX][3]),aVrtFields[nX][5]," ")
        Else
            xVal := (cTab)->&(aVrtFields[nX][3])
        EndIf
        AADD(aTmp,xVal)
    Next nX
    AADD(aLines,{0,aTmp})
    (cTab)->(DBSkip())
Enddo
(cTab)->(DBCloseArea())
RestArea(aArea)

Return (aLines) //End of RU06D0526_LoadBills


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0527_DefVirtViewStr
View structure for virtual grid - All Bills
@author eduardo.flima
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0527_DefVirtViewStr(lBS as Logical)
Local aArea 	as Array
Local oStruct 	as Object
Default lBS:=.F.

aArea		:= 	GetArea()
oStruct 	:= 	FWFormViewStruct():New()
//                  ID      Order           Titulo          Descrip                 Help Type    Pict                           bPictVar LookUp CanCh  Ider cGroup Combo MaxLenCombo IniBrw, lVirt PicVar
oStruct:AddField("B_CHECK"	,"01"	,RetTitle("F4B_RATUSR")	,RetTitle("F4B_RATUSR")	,NIL ,"L"	,""                         	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Request Code
oStruct:AddField("B_CODREQ"	,"02"	,RetTitle("F4A_CODREQ")	,RetTitle("F4A_CODREQ")	,NIL ,"C"	,PesqPict("F4A","F4A_CODREQ")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Request Code
oStruct:AddField("B_PREFIX"	,"03"	,RetTitle("F4B_PREFIX")	,RetTitle("F4B_PREFIX")	,NIL ,"C"	,PesqPict("F4B","F4B_PREFIX")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // AP Prefic
oStruct:AddField("B_NUM"	,"04"	,RetTitle("F4B_NUM")	,RetTitle("F4B_NUM")	,NIL ,"C"	,PesqPict("F4B","F4B_NUM")	    ,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // AP Number
oStruct:AddField("B_PARCEL"	,"05"	,RetTitle("F4B_PARCEL")	,RetTitle("F4B_PARCEL")	,NIL ,"C"	,PesqPict("F4B","F4B_PARCEL")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // AP parcel
oStruct:AddField("B_TYPE"	,"06"	,RetTitle("F4B_TYPE")	,RetTitle("F4B_TYPE")	,NIL ,"C"	,PesqPict("F4B","F4B_TYPE")	    ,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // AP Type
oStruct:AddField("B_CLASS"	,"07"	,RetTitle("F4B_CLASS")	,RetTitle("F4B_CLASS")	,NIL ,"C"	,PesqPict("F4B","F4B_CLASS")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // AP Class
oStruct:AddField("B_EMISS"	,"08"	,RetTitle("F4B_EMISS")	,RetTitle("F4B_EMISS")	,NIL ,"D"	,PesqPict("F4B","F4B_EMISS" )	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Emission date
oStruct:AddField("B_REALMT"	,"09"	,RetTitle("F4B_REALMT")	,RetTitle("F4B_REALMT")	,NIL ,"D"	,PesqPict("F4B","F4B_REALMT" )	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Plan date
oStruct:AddField("B_VALPAY"	,"10"	,RetTitle("F4B_VALPAY")	,RetTitle("F4B_VALPAY")	,NIL ,"N"	,PesqPict("F4B","F4B_VALPAY") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_EXGRAT"	,"11"	,RetTitle("F4B_EXGRAT")	,RetTitle("F4B_EXGRAT")	,NIL ,"N"	,PesqPict("F4B","F4B_EXGRAT") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_VALCNV"	,"12"	,RetTitle("F4B_VALCNV")	,RetTitle("F4B_VALCNV")	,NIL ,"N"	,PesqPict("F4B","F4B_VALCNV") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_BSVATC"	,"13"	,RetTitle("F4B_BSVATC")	,RetTitle("F4B_BSVATC")	,NIL ,"N"	,PesqPict("F4B","F4B_BSVATC") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_VLVATC"	,"14"	,RetTitle("F4B_VLVATC")	,RetTitle("F4B_VLVATC")	,NIL ,"N"	,PesqPict("F4B","F4B_VLVATC") 	,NIL ,''	,   lBS	  ,''	,''		,{}	,0	,''		,.F.) // Value to pay
oStruct:AddField("B_VALUE"	,"15"	,RetTitle("F4B_VALUE")  ,RetTitle("F4B_VALUE")	,NIL ,"N"	,PesqPict("SE2","E2_SALDO") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Bill value
oStruct:AddField("B_CURREN"	,"16"	,RetTitle("F4B_CURREN")	,RetTitle("F4B_CURREN")	,NIL ,"C"	,PesqPict("SE2","E2_MOEDA") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // AP Currency
oStruct:AddField("B_CONUNI"	,"17"	,RetTitle("F4B_CONUNI")	,RetTitle("F4B_CONUNI")	,NIL ,"C"	,PesqPict("F4B","F4B_CONUNI")	,NIL ,''	,   .F.	  ,''	,''		,{'1=Yes','2=No'}		,0	,''		,.F.) // Conv Units
oStruct:AddField("B_VLCRUZ"	,"18"	,RetTitle("F4B_VLCRUZ")	,RetTitle("F4B_VLCRUZ")	,NIL ,"N"	,PesqPict("SE2","E2_VLCRUZ")	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Value in local currency
oStruct:AddField("B_OPBAL"	,"19"	,RetTitle("F4B_OPBAL")	,RetTitle("F4B_OPBAL")	,NIL ,"N"	,PesqPict("SE2","E2_SALDO") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Open balance
oStruct:AddField("B_BSIMP1"	,"20"	,RetTitle("F4B_BSIMP1")	,RetTitle("F4B_BSIMP1")	,NIL ,"N"	,PesqPict("SE2","E2_SALDO") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // VAT Base
oStruct:AddField("B_ALIMP1"	,"21"	,RetTitle("F4B_ALIMP1")	,RetTitle("F4B_ALIMP1")	,NIL ,"N"	,PesqPict("SE2","E2_ALQIMP1") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // VAT Rate
oStruct:AddField("B_VLIMP1"	,"22"	,RetTitle("F4B_VLIMP1")	,RetTitle("F4B_VLIMP1")	,NIL ,"N"	,PesqPict("F4B","F4B_VLIMP1") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // VAT Amount
oStruct:AddField("B_MDCNTR"	,"23"	,RetTitle("F4B_MDCNTR")	,RetTitle("F4B_MDCNTR")	,NIL ,"C"	,PesqPict("SE2","E2_MDCONTR") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.T.) // Contract number
oStruct:AddField("B_FLORIG"	,"24"	,RetTitle("F4B_FLORIG")	,RetTitle("F4B_FLORIG")	,NIL ,"C"	,PesqPict("F4B","F4B_FLORIG") 	,NIL ,''	,   .F.	  ,''	,''		,{}	,0	,''		,.F.) // Filial of origin


Return (oStruct)


//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0529_VldVat
Validations for F49_VALUE, _VATCOD, _VATRAT, _VATAMT
@author natalia.khozyainova
@param nNum: // 1 = F49_VALUE, 2=F49_VATCOD , 3=F49_VATRAT, 4=F49_VATAMNT
@since 18/12/2018
@version 2.0
@project MA3 - Russia
/*/
Function RU06D0529_VldVat(nNum as Numeric)
Local lRet as Logical
lRet:=RU06XFUN17_VldVATFields(nNum, "F49", "RU06D05_MF4B")
Return lRet


/*/{Protheus.doc} RU06D0530_RetF47
Virtual fields of F4A initializer
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0530_RetF47(nField,cTable)
Local cRet      as Character
Local aSaveArea as Array
Local cKey      as Char

Default cTable:='F47'
Default nField  := 1
aSaveArea   := GetArea()
If cTable=='F47'
    cKey := F49->F49_FILREQ+((F4A->F4A_CODREQ))+(DTOS(F4A->F4A_DTREQ))
EndIf

If nField == 1 .and. ValType(cKey)='C' // F4A_PREPAY
        cRet := Posicione("F47",1,cKey,"F47_PREPAY")
    ElseIf nField == 2 .and. ValType(cKey)='C' // F4A_BNKCOD
        cRet := Posicione("F47",1,cKey,"F47_BNKCOD")
    ElseIf nField == 3 .and. ValType(cKey)='C' // F4A_CNT
        cRet := Posicione("F47",1,cKey,"F47_CNT")
    ElseIf nField == 4 .and. ValType(cKey)='C' // F4A_CLASS
        cRet := Posicione("F47",1,cKey,"F47_CLASS")
    ElseIf nField == 5 .and. ValType(cKey)='C' // F4A_VALUE
        cRet := Posicione("F47",1,cKey,"F47_VALUE")
    ElseIf nField == 6 .and. ValType(cKey)='C' // F4A_VATCOD
        cRet := Posicione("F47",1,cKey,"F47_VATCOD")
    ElseIf nField == 7 .and. ValType(cKey)='C' // F4A_VATRAT
        cRet := Posicione("F47",1,cKey,"F47_VATRAT")
    ElseIf nField == 8 .and. ValType(cKey)='C' // F4A_VATAMT
        cRet := Posicione("F47",1,cKey,"F47_VATAMT")
    ElseIf nField == 9 .and. ValType(cKey)='C' // F4A_REASON
        cRet := Posicione("F47",1,cKey,"F47_REASON")
    Endif 
RestArea(aSaveArea)

Return (cRet)

/*/{Protheus.doc} RU06D0531_TOTLS
Calculates total value and total vat amount from lines
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0531_TOTLS(lForce as Logical,nLine as Numeric, cAction as Character)
Local nVal as Numeric
Local nVat as Numeric
Local oModel as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local oView as Object
Local oViewHead as Object
Local nX as Numeric

Default lForce:=.F.
Default nLine:=0
Default cAction:=''

oModel:=FWModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
    
oView := FwViewActive()
If lForce
    nVal:=0
    nVat:=0    
        
    for nX:=1 to oModelF4A:Length()
        if !(nX==nLine .and. cAction='DELETE')
            oModelF4A:GoLine(nX)
            if !(oModelF4A:IsDeleted()) .or. (nX==nLine .and. cAction='UNDELETE')
                If !Empty("F4A_VALUE") 
                    nVal+=oModelF4A:GetValue("F4A_VALUE")
                EndIf
                If !Empty("F4A_VATAMT")
                    nVat+=oModelF4A:GetValue("F4A_VATAMT")
                EndIf
            Endif
        EndIf 
    Next nX
        
    oModelF49:SetValue("F49_VALUE",nVal)
    oModelF49:SetValue("F49_VATAMT",nVat)
EndIf

If !Empty(oView) 
    oViewHead := oView:GetViewObj("RU06D05_VHEAD")[3]
    If !Empty(oViewHead)
        oViewHead:Refresh(.T.,.F.)
    EndIf
EndIf

if nLine>0
    oModelF4A:GoLine(nLine)
EndIf

Return (NIL)


/*/{Protheus.doc} RU06D0532_RecalcTotls
Recalc totals menu button
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Static Function RU06D0532_RecalcTotls()
If FwFldGet("F49_PREPAY")!="1"
    If MsgNoYes(STR0032,STR0031) // Totals will be recalculated. Continue? -- Recalculate
        RU06D0531_TOTLS(.T.)
        RU06D0536_POReason()

        lUserValue:=.F.
    EndIf
Else
    Help("",1,STR0033,,STR0034,1,0,,,,,,{STR0035})// Totals Recalculation -- can not recalculate prepayment -- change prepayment parameter
EndIf
Return (NIL)

/*/{Protheus.doc} RU06D0543_VrtModel
to add lines to the vitual grid of All Bills at the moment of Picking p PRs
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0543_VrtModel(oModel)
Local oModelF4B as Object
Local oModelVirt as Object
Local oModelF4A as Object

Local nQ as Numeric
Local nX as Numeric
Local nY as Numeric
Local lExitCycle as Logical

Local cKey1 as Character
Local cKey2 as Character

lExitCycle:=.F.

if ValType(oModel)=='O'
    oModelF4B:=oModel:GetModel("RU06D05_MF4B")
    oModelF4A:=oModel:GetModel("RU06D05_MF4A")
    oModelVirt:=oModel:GetModel("RU06D05_MVIRT")
EndIf

for nQ:=1 to  oModelF4A:Length()
    oModelF4A:GoLine(nQ)

    if !(oModelF4A:IsDeleted())
        for nX:=1 to oModelF4B:Length()
            oModelF4B:GoLine(nX)
            cKey1:= alltrim(oModelF4B:GetValue("F4B_FILIAL")) + alltrim(oModelF4B:GetValue("F4B_IDF4A")) + alltrim(oModelF4B:GetValue("F4B_PREFIX")) + ;
            alltrim(oModelF4B:GetValue("F4B_NUM")) +  alltrim(oModelF4B:GetValue("F4B_PARCEL")) +  alltrim(oModelF4B:GetValue("F4B_TYPE"))
            lExitCycle:=.F.

            for nY:=1 to oModelVirt:Length()
                If !lExitCycle
                    oModelVirt:GoLine(nY)
                    cKey2:= alltrim(xFilial("F4B")) + alltrim(oModelVirt:GetValue("B_IDF4A")) +  alltrim(oModelVirt:GetValue("B_PREFIX")) + ;
                    alltrim(oModelVirt:GetValue("B_NUM")) +  alltrim(oModelVirt:GetValue("B_PARCEL")) +  alltrim(oModelVirt:GetValue("B_TYPE"))

                    if (cKey1==cKey2)
                        lExitCycle:=.T.
                    EndIf    
                EndIf
            Next nY

            if !lExitCycle
                
                if !(Empty(oModelVirt:GetValue("B_NUM"))) .or. oModelVirt:IsDeleted()
                    oModelVirt:SetNoInsertLine(.F.)
                    oModelVirt:AddLine()
                    oModelVirt:SetNoInsertLine(.T.)
                Endif

                oModelVirt:GoLine(oModelVirt:Length())
                RU06D05498_LoadValuesToVirt(oModel, oModelVirt, oModelF4B, oModelF4A)
            Endif
        Next nX
    EndIf
Next nQ 

Return (nil)

/*/{Protheus.doc} RU06D0540_Array
make an aray of fields that should not be copied in Copy operation
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0540_Array(oModel)
Local oStr as Object
Local aRet as Array
Local nX as Numeric

oStr:=oModel:GetStruct()
aRet:={}

for nX:=1 to oStr:FieldsLength()
    aAdd(aRet, oStr:GetFields()[nX][03])
next nX

Return (aRet)




/*/{Protheus.doc} RU06D0535_MarkAll
Mark all records
@param		oBrowsePut - Object
			cTempTbl - Alias markbrowse
@author eduardo.flima
@since 20/08/2018
@version P12.1.20
@type function
@project	MA3
/*/
Static Function RU06D0535_MarkAll(oBrowsePut as Object, cTempTbl as Char)
Local nRecOri 	as Numeric
nRecOri	:= (cTempTbl)->( RecNo() )

dbSelectArea(cTempTbl)
(cTempTbl)->( DbGoTop() )
Do while !(cTempTbl)->( Eof() )
	RecLock(cTempTbl, .F.)
	If !Empty((cTempTbl)->F47_OK)
		(cTempTbl)->F47_OK := ''
	Else
		(cTempTbl)->F47_OK := cMark
	EndIf
	MsUnlock()

	(cTempTbl)->( DbSkip() )
Enddo

(cTempTbl)->( DbGoTo(nRecOri) )
oBrowsePut:oBrowse:Refresh(.T.)
Return .T.



/*/{Protheus.doc} RU06D0536_POReason
writes reason of payment
cAction Parameter is used because this function we call at the moment of deletion/undeletion line
@author natalia.khozyainova
@since 20/08/2018
@version P12.1.20
@type function
@project	MA3
/*/
Function RU06D0536_POReason(nLine,cAction,lCopy)
Local cRet as Character
Local oModel as Object
Local oModelF49 as Object
Local oModelF4A as Object
Local oModelF4B as Object
Local aFields   as Array
Local cTmpTab as Character
Local oTmpTab as Object
Local nX as Numeric
Local nY as Numeric
Local nQtyPRs as Numeric
Local cCont as Character
Local cText as Character
Local cTextLn as Character
Local nOn as Numeric
Local nVatRt as Numeric
Local nVatAmnt as Numeric
Local aAreaTmp as Array
Local lDbSeek as Logical
Local aSaveArea as Array
Local nTheLine as Numeric
Local oView as Object
Local oViewHead as Object

Default nLine:=0
Default cAction:=''
Default lCopy:=.F.

aSaveArea:=GetArea()
oModel:=FwModelActive()
oModelF49:=oModel:GetModel("RU06D05_MF49")
oModelF4A:=oModel:GetModel("RU06D05_MF4A")
oModelF4B:=oModel:GetModel("RU06D05_MF4B")

nVatRt:=oModelF49:GetValue("F49_VATRAT")
nVatAmnt:=oModelF49:GetValue("F49_VATAMT")

nTheLine:=0
nQtyPRs:=0
cRet:=''

// calc qty of lines and if there is only 1 line its number will be saved in nTheLine
For nX := 1 To oModelF4A:Length()
    oModelF4A:GoLine(nX)
    if ( !(oModelF4A:IsDeleted()) .or. cAction=='UNDELETE') .and. !Empty("F4A_CODREQ")
            if !(cAction='DELETE' .and. nX==nLine)
            nQtyPRs++
            nTheLine:=oModelF4A:GetLine()
        EndIf
    EndIf
Next nX

if lCopy
    nQtyPRs:=0
EndIf
oModelF4A:GoLine(1)

if nQtyPRs==1 // if there is only 1 line, copy Reason of Payment
    cRet:=ALLTRIM(FwFldGet("F4A_REASON",nTheLine)) 

Elseif nQtyPRs>0
    cRet:=''

    If oTmpTab <> Nil // temporary table to make listing of bills w/o duplication
        oTmpTab:Delete()
        oTmpTab := Nil
    Endif
    cTmpTab	:= CriaTrab(,.F.)
    oTmpTab := FWTemporaryTable():New(cTmpTab)

    aFields := {}
    aadd(aFields,{"TMP_CNT"		, "C", GetSX3Cache("F4A_CNT", "X3_TAMANHO"),  GetSX3Cache("F4A_CNT", "X3_DECIMAL")})		
    aadd(aFields,{"TMP_BILL"	, "C", 50,  00})
    aadd(aFields,{"TMP_QTY"	    , "N", 2 ,  00})

    oTmpTab:SetFields(aFields)
    oTmpTab:AddIndex("Indice1", {"TMP_CNT","TMP_BILL"} )
    oTmpTab:Create()

    For nX := 1 To oModelF4A:Length() // check every PR in model
        oModelF4A:GoLine(nX)
        if ( !(oModelF4A:IsDeleted()) .or. cAction=='UNDELETE') .and. !Empty("F4A_CODREQ")
            if !(cAction='DELETE' .and. nX==nLine)
                For nY:=1 to oModelF4B:Length() // check every AP of every PR in model
                    oModelF4B:GoLine(nY)
                    aAreaTmp := (cTmpTab)->(GetArea())
                    (cTmpTab)->(dbSetOrder(1))
                    lDbSeek := (cTmpTab)->(DbSeek(oModelF4A:GetValue("F4A_CNT")+ALLTRIM(oModelF4B:GetValue("F4B_PREFIX"))+'/'+ALLTRIM(oModelF4B:GetValue("F4B_NUM"))+;
                    STR0059+ALLTRIM(DTOC(oModelF4B:GetValue("F4B_EMISS")) ))) // add a bill to the tmp table, if it is not there yet 
                    RecLock(cTmpTab,!(lDbSeek)) 
                    (cTmpTab)->TMP_CNT:= oModelF4A:GetValue("F4A_CNT") 
                    if ALLTRIM(oModelF4B:GetValue("F4B_NUM"))==''   
                        (cTmpTab)->TMP_BILL:=''
                    Else    
                        (cTmpTab)->TMP_BILL	:= ALLTRIM(oModelF4B:GetValue("F4B_PREFIX"))+'/'+ ALLTRIM(oModelF4B:GetValue("F4B_NUM"))+STR0059+ALLTRIM(DTOC(oModelF4B:GetValue("F4B_EMISS"))) // ' from '
                    EndIf
                    (cTmpTab)->TMP_QTY	:= (cTmpTab)->TMP_QTY+1   
                    (cTmpTab)->(MsUnLock())
                next nY
            EndIf
        EndIf
    Next nX

    (cTmpTab)->(DBGoTop()) // now in cTmpTab we have a list of bills, each one described as a sentence like 'AA/BBB from 11.05/.2018'
    (cTmpTab)->(dbSetOrder(1))

    cCont:='nothing' // this means that no contract numbers were described in reason of payment so far
    cText:=''
    cTextLn:=''
    nOn:=0

    // this ccle takes avery line of Tmp Table and makes a text from it
    while !(cTmpTab)->(EOF()) 
        if alltrim((cTmpTab)->TMP_CNT)+alltrim((cTmpTab)->TMP_BILL)!='' // if there is bill number or contract number
            If alltrim(cCont)!=alltrim((cTmpTab)->TMP_CNT) 
                if cCont!='nothing'
                    cText:=alltrim(cText)+';'+CRLF + if(alltrim(cTextLn)!='',alltrim(cTextLn),'')// if there are some contracts in the Reason, we start from the new line
                    nOn:=0
                    cTextLn:=''
                Else    
                    cText:=STR0055 //'Payment ' - here we start if this contract is first to be described in Reason
                    nOn:=0
                    cTextLn:=''
                EndIf
                if alltrim((cTmpTab)->TMP_CNT)!=''  
                    cTextLn:=STR0056 + ((cTmpTab)->TMP_CNT) // 'from contract '
                EndIf
                if alltrim((cTmpTab)->TMP_BILL)!=''
                    cTextLn:=alltrim(cTextLn)+STR0058 + ((cTmpTab)->TMP_BILL) //' from bill ' 
                    nOn++
                EndIf
            Else 
                cTextLn:=alltrim(cTextLn)+', '+alltrim((cTmpTab)->TMP_BILL)
                nOn++
                if nOn==2
                    cTextLn:=StrTran(cTextLn, alltrim(STR0058), alltrim(STR0057)) // replace 'from bill' with 'from bills'
                EndIf
            EndIf
            if cCont!='nothing'
                cText:=alltrim(cText)+if(alltrim(cTextLn)!='',' '+alltrim(cTextLn),'') 
                nOn:=0
                cTextLn:=''
            Endif    
            cCont:=(cTmpTab)->TMP_CNT
        EndIf
        DBSkip()
    Enddo

    cRet:=cText
    if !(nVatRt=0 .and. nVatAmnt=0) // if there is some information about total VAT of PR, make a new line
        cRet:=alltrim(cRet)+'.'+CRLF 
    EndIf
EndIf

If nQtyPRs!=1 .and. !(nVatRt=0 .and. nVatAmnt=0) // add information about VAT

    If nVatRt!=0 // describe VAT rate
        cRet+=STR0060+alltrim(STR(ROUND(nVatRt,2)))+'%' // like 'Including VAT 13% '
    EndIf

    If nVatAmnt!=0 // describe VAT amount
        cRet+=' - '+alltrim(STR(ROUND(nVatAmnt,2),15,2)) // like ' - 300.00 '
    EndIf

EndIf

oModelF49:LoadValue("F49_REASON",cRet)
RestArea(aSaveArea)

If Empty(oView) 
    oView:=FwViewActive()
EndIf
If !Empty(oView) 
    oViewHead := oView:GetViewObj("RU06D05_VHEAD")[3]
    If !Empty(oViewHead)
        oViewHead:Refresh(.T.,.F.)
    EndIf
EndIf

if nLine>0
    oModelF4A:GoLine(nLine)
EndIf
Return (NIL)

/*/{Protheus.doc} RU06D0539_OkToUnDelete
checks if line can be undeleted
@author natalia.khozyainova
@since 24/08/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0539_OkToUnDelete(nLine)
Local lRet as Logical
Local lFilReq as Logical
Local lCurrErr as Logical
Local lSuppErr as Logical
Local lPrePayErr as Logical
Local cCurrF4A as Character
Local cSuppF4A as Character
Local nQtyAPs as Numeric
Local nQtyActAPs as Numeric
Local oModel as Object
Local aArea  as Array
lRet:=.T.
lCurrErr:=.F.
lFilReq:=.F.
aArea:=GetArea()


F47->(DbSetOrder(1))

If Empty(FwFldGet("F49_FILREQ"))
    lFilReq:=.T.
ElseIf  (!F47->(DbSeek(FwFldGet("F49_FILREQ")+FwFldGet("F4A_CODREQ",nLine)+DTOS(FwFldGet("F4A_DTREQ",nLine)))))
	Help("",1,STR0053,,STR0088,1,0,,,,,,{STR0090}) //'Not allowed to undelete line-- Branch - A payment Order can not have payment request from different branches
	lRet:=.F. 
Endif 


cCurrF4A:=POSICIONE("F47",1,FwFldGet("F4A_FILREQ",nLine)+FwFldGet("F4A_CODREQ",nLine)+DTOS(FwFldGet("F4A_DTREQ",nLine)),"F47_CURREN")
If cCurrF4A!= FwFldGet("F49_CURREN") .and. alltrim(cCurrF4A)!=''
	lCurrErr:=.T.
EndIf
If lCurrErr
	lRet:=.F.
	Help("",1,STR0053,,STR0050,1,0,,,,,,{STR0054}) //'Not allowed to undelete line-- Currency - Currency of payment order should be same as currency of each request included
EndIf

lSuppErr:=.F.
cSuppF4A:=POSICIONE("F47",1,FwFldGet("F4A_FILREQ",nLine)+FwFldGet("F4A_CODREQ",nLine)+DTOS(FwFldGet("F4A_DTREQ",nLine)),"F47_SUPP")+POSICIONE("F47",1,FwFldGet("F4A_FILREQ",nLine)+FwFldGet("F4A_CODREQ",nLine)+DTOS(FwFldGet("F4A_DTREQ",nLine)),"F47_UNIT")
If cSuppF4A!= FwFldGet("F49_SUPP")+FwFldGet("F49_UNIT") .and. alltrim(cSuppF4A)!=''
	lSuppErr:=.T.
EndIf
If lSuppErr
	lRet:=.F.
	Help("",1,STR0053,,STR0072,1,0,,,,,,{STR0073}) //'Not allowed to undelete line -- Error in supplier code -- Supplier code of PO must match supplier code of each PR attached
EndIf

lPrePayErr:=.F.
oModel:=FwModelActive()
nQtyAPs := oModel:GetModel("RU06D05_MF4B"):Length()
nQtyActAPs:= oModel:GetModel("RU06D05_MF4B"):Length(.T.)
if nQtyAPs>0 .and. FwFldGet("F49_PREPAY")=='1' .and. nQtyActAPs == 0
    lPrePayErr:=.T.
EndIf
If lPrePayErr
	lRet:=.F.
	Help("",1,STR0053,,STR0074,1,0,,,,,,{STR0075}) //'Not allowed to undelete line -- Currency - Currency of payment order should be same as currency of each request included
EndIf

If lRet .and. lFilReq
   FwFldPut("F49_FILREQ", FwFldGet("F4A_FILREQ",nLine),,,,.T.)
Endif
RestArea(aArea)
Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0542_SortF4A
Internal Function to order the F4A grid in the moment that we add the accounts payables
@type function
@author eduardo.FLima
@since 11/07/2018
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function RU06D0542_SortF4A(oGrid,nDest)
Local lRet as Logical
Local cFrom as Char
Local cTo as Char
Local nOrig as Numeric

Default nDest :=  1 

lRet := .F.    

cFrom := oGrid:GetValue('F4A_FILIAL') + oGrid:GetValue('F4A_CODREQ')  
nOrig := oGrid:GetLine()
oGrid:GoLine(nDest)
cTo  := oGrid:GetValue('F4A_FILIAL') + oGrid:GetValue('F4A_CODREQ')

While cFrom !=   cTo    
    If cFrom < cTo 
        oGrid:LineShift( nOrig, nDest)
        lRet := .T.
        oGrid:GoLine(nOrig)
        RU06D0542_SortF4A(oGrid,nDest)
        cFrom := oGrid:GetValue('F4A_FILIAL') + oGrid:GetValue('F4A_CODREQ')  
    Else 
        nDest := nDest + 1 
        oGrid:GoLine(nDest)
        cTo  := oGrid:GetValue('F4A_FILIAL') + oGrid:GetValue('F4A_CODREQ') 
    Endif
Enddo 

Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0544_EmptyModel
Checks if the model is empty
i.e. there are no active lines (active = not deleted and control field has some value) 
@type function
@author natalia.khozyainova
@since 17/09/2018
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function RU06D0544_EmptyModel(oSubModel as Object, cFieldName as Character, nLine as Numeric)
Local lRet      as Logical
Local nX        as Numeric
Local nQtyLns   as Numeric

Default cFieldName:=""
Default nLine:=0
lRet:=.F.
nQtyLns:=0


If ValType(oSubModel)=='O'
    For nX := 1 To oSubModel:Length()
        oSubModel:GoLine(nX)
        if !(oSubModel:IsDeleted() )
            if Valtype(cFieldName)=='C' .and. oSubModel:GetStruct():HasField(cFieldName) .and. !Empty(oSubModel:GetValue(cFieldName))
                nQtyLns++
            ElseIf Valtype(cFieldName)!='C' .or. !oSubModel:GetStruct():HasField(cFieldName)
                nQtyLns++
            EndIf
        EndIf
    Next nX
EndIf

If nQtyLns==0
    lRet:=.T.
EndIf

if nLine>0
    oSubModel:GoLine(nLine)
EndIf

Return (lRet)


Static Function RU06D0545_PutSuppAcc()
Local oModel as Object 
Local oModelF49 as Object 
Local oModelF4A as Object 
Local nPos as Numeric
Local nX as Numeric
Local nLine1 as Numeric

oModel:=FwModelActive()
If ValType(oModel)=='O'

    oModelF49:=oModel:GetModel("RU06D05_MF49")
    oModelF4A:=oModel:GetModel("RU06D05_MF4A")
    nPos:=oModelF4A:GetLine()
    nLine1:=0
    nX:=1
    while nX<=oModelF4A:Length() .and. nLine1==0
        oModelF4A:GoLine(nX)
        if !(oModelF4A:IsDeleted()) .and. !Empty(oModelF4A:GetValue("F4A_CODREQ")) 
            nLine1:=nX
        Endif
        nX++
    EndDo

    if nLine1>0
        oModelF49:LoadValue("F49_BNKREC",POSICIONE("F47",1,oModelF49:GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ",nLine1)+DTOS(oModelF4A:GetValue("F4A_DTREQ",nLine1)),"F47_BNKCOD"))
        oModelF49:LoadValue("F49_RECBIK",POSICIONE("F47",1,oModelF49:GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ",nLine1)+DTOS(oModelF4A:GetValue("F4A_DTREQ",nLine1)),"F47_BIK"))
        oModelF49:LoadValue("F49_RECACC",POSICIONE("F47",1,oModelF49:GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ",nLine1)+DTOS(oModelF4A:GetValue("F4A_DTREQ",nLine1)),"F47_ACCNT"))
        oModelF49:LoadValue("F49_RECNAM",POSICIONE("F47",1,oModelF49:GetValue("F49_FILREQ")+oModelF4A:GetValue("F4A_CODREQ",nLine1)+DTOS(oModelF4A:GetValue("F4A_DTREQ",nLine1)),"F47_RECNAM"))
    EndIf

    if nPos>0
        oModelF4A:GoLine(nPos)
    Endif
EndIf


Return (NIL)

Static Function RU06D0546_CheckConUni(oTempTable)
    Local lRet       As Logical
    Local cQuery     As Character
    Local cTab       As Character
    Local aArea      As Array

    lRet := .F.
    aArea := GetArea()
    
    cQuery := " SELECT COUNT (*) AS CNT FROM " + oTempTable:GetRealName()
    cQuery += " INNER JOIN " + RetSQLName("F48") + " AS F48 "
    cQuery += " ON F48.F48_FILIAL=F47_FILIAL AND F48.F48_IDF48 = F47_IDF47 "
    cQuery += " WHERE F48.D_E_L_E_T_ = ' ' "
    cQuery += " AND F48.F48_CONUNI = '1' "
    cQuery += " AND F47_CURREN = '01' "
    cQuery += " AND F47_OK = '" + cMark + "' "

    cQuery    := ChangeQuery(cQuery)
    cTab := MPSysOpenQuery(cQuery)
    
    DbSelectArea(cTab)
    If (cTab)->(CNT) > 0 // there is exist F48_CONUNI field equals '1'
        lRet := .T.
    EndIf
    (cTab)->(DBCloseArea())
    RestArea(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RU06D0547_CheckCurrency
Checks currency for add new lines
@type function
@param  cCurrPerg   Currency from pergunte
        oModel      Model of program
@author alexandra.velmozhmaya
@since 19/02/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function RU06D0547_CheckCurrency(cCurrPerg, oModel)
Local lRet       As Logical
Local nX         As Numeric
Local oModelHead As Object
Local oModelDet  As Object

oModelHead := oModel:GetModel("RU06D05_MF49")
oModelDet := oModel:GetModel("RU06D05_MF4B")
lRet := .T.

If !Empty(oModelHead:GetValue("F49_CNT")) .and. oModelHead:GetValue("F49_CURREN") <> cCurrPerg
    lRet := .F.
EndIf

If lRet .and. (oModelDet:Length() >= 1 .and. !Empty(oModelDet:GetValue("F4B_CURREN", 1)) )
    For nX := 1 to oModelDet:Length()
        oModelDet:GoLine(nX)
        If (oModelDet:GetValue("F4B_CURREN") <> Val(cCurrPerg)) .and. !(oModelDet:GetValue("F4B_CONUNI") == "1" .and. cCurrPerg == "01")
            lRet := .F.
            Exit
        EndIf
    Next nX
EndIf

Return (lRet)

/*/{Protheus.doc} RU06D0548_GatForn
This function assigned to the triggers
for F49_SUPP (F4C_SUPP) and F49_UNIT (F4C_UNIT) fields. When we input
F49_SUPP (F4C_SUPP) or F49_UNIT (F4C_UNIT) fields we fill information about
supplier like supplier name, KPP.
@author astepanov
@param cField     Character   Field id which we should fill
       cModelID   Character    character ID to model
@since 18 August 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D0548_GatForn(cField, cModelID)
    Local  cRet      As Character
    Local  aArea     As Array
    Local  aAreaSA2  As Array
    Local  cTab      As Character
    aArea    := GetArea()
    aAreaSA2 := SA2->(GetArea())
    cRet     := ""
    If cModelID == __cMdlHdr
        cTab := "F49"
    ElseIf cModelID == "RU06D07_MHEAD"
        cTab := "F4C"
    EndIf
    If     cField == cTab+"_UNIT"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet(cTab+"_SUPP"),"A2_LOJA")
    ElseIf cField == cTab+"_SUPNAM"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet(cTab+"_SUPP")+FwFldGet(cTab+"_UNIT"),"A2_NOME")
    ElseIf cField == cTab+"_KPPREC"
        cRet := Posicione("SA2",1,xFilial("SA2")+FwFldGet(cTab+"_SUPP")+FwFldGet(cTab+"_UNIT"),"A2_KPP")
        // Delete Lines in a grid after entering a new supplier
        RU06D05497_DelLinesInTheGrid()
    EndIf
    cRet := PADR(cRet,GetSX3Cache(cField,"X3_TAMANHO"," "))
    RestArea(aAreaSA2)
    RestArea(aArea)
Return cRet


/*/{Protheus.doc} RU06D05490_RetStructs
This function returns an array of FWFormStruct 'ers:
for Header oStrF49, for payment requests oStrF4A,
for payment request lines oStrF4B, and virtual structure oStrAllBills.
@param  Character cProgram
@return Array     aStruct   //{oStrF49, oStrF4A, oStrF4B, oStrAllBills}
@author astepanov
@since 24 September 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D05490_RetStructs()

Local aStruct      As Array
Local oStrF49      As Object
Local oStrF4A      As Object
Local oStrF4B      As Object
Local oStrAllBills As Object

aStruct := {}

// Header structure - F49 Payment Order - Header
oStrF49 := FWFormStruct(1, "F49")
oStrF49:SetProperty("F49_PAYTYP", MODEL_FIELD_INIT, {|| RU06D0512_InitOrdType() }  ) 
oStrF49:SetProperty("F49_IDF49", MODEL_FIELD_INIT, {|| FWUUIDV4(.F.) }  )
oStrF49:AddTrigger("F49_SUPP","F49_UNIT"  ,,{ |oModel| RU06D0548_GatForn("F49_UNIT",__cMdlHdr)  })
oStrF49:AddTrigger("F49_SUPP","F49_SUPNAM",,{ |oModel| RU06D0548_GatForn("F49_SUPNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_SUPP","F49_KPPREC",,{ |oModel| RU06D0548_GatForn("F49_KPPREC",__cMdlHdr)})
oStrF49:AddTrigger("F49_UNIT","F49_SUPNAM",,{ |oModel| RU06D0548_GatForn("F49_SUPNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_UNIT","F49_KPPREC",,{ |oModel| RU06D0548_GatForn("F49_KPPREC",__cMdlHdr)})

oStrF49:AddTrigger("F49_CURREN","F49_CURNAM",,{|| POSICIONE("CTO",1,xFilial("CTO")+FwFldGet("F49_CURREN"),"CTO_DESC")})

// Add triggers to bank code related fields; F49_PAYNAM or F49_RECNAM should be called last.
// https://jiraproducao.totvs.com.br/browse/RULOC-825
oStrF49:AddTrigger("F49_CURREN","F49_BNKPAY",,{ |oModel| RU06D05493_GatBankPay("F49_BNKPAY",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_PAYBIK",,{ |oModel| RU06D05493_GatBankPay("F49_PAYBIK",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_PAYACC",,{ |oModel| RU06D05493_GatBankPay("F49_PAYACC",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_BKPNAM",,{ |oModel| RU06D05493_GatBankPay("F49_BKPNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_ACPNAM",,{ |oModel| RU06D05493_GatBankPay("F49_ACPNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_PAYNAM",,{ |oModel| RU06D05493_GatBankPay("F49_PAYNAM",__cMdlHdr)})

oStrF49:AddTrigger("F49_CURREN","F49_BNKREC",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_BNKREC",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_RECBIK",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECBIK",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_RECACC",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECACC",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_TYPCC" ,{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_TYPCC", __cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_BKRNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_BKRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_ACRNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_ACRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_CURREN","F49_RECNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECNAM",__cMdlHdr)})

oStrF49:AddTrigger("F49_SUPP","F49_BNKREC",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_BNKREC",__cMdlHdr)})
oStrF49:AddTrigger("F49_SUPP","F49_RECBIK",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECBIK",__cMdlHdr)})
oStrF49:AddTrigger("F49_SUPP","F49_RECACC",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECACC",__cMdlHdr)})
oStrF49:AddTrigger("F49_SUPP","F49_TYPCC" ,{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_TYPCC", __cMdlHdr)})
oStrF49:AddTrigger("F49_SUPP","F49_BKRNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_BKRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_SUPP","F49_ACRNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_ACRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_SUPP","F49_RECNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECNAM",__cMdlHdr)})

oStrF49:AddTrigger("F49_UNIT","F49_BNKREC",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_BNKREC",__cMdlHdr)})
oStrF49:AddTrigger("F49_UNIT","F49_RECBIK",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECBIK",__cMdlHdr)})
oStrF49:AddTrigger("F49_UNIT","F49_RECACC",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECACC",__cMdlHdr)})
oStrF49:AddTrigger("F49_UNIT","F49_TYPCC" ,{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_TYPCC", __cMdlHdr)})
oStrF49:AddTrigger("F49_UNIT","F49_BKRNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_BKRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_UNIT","F49_ACRNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_ACRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_UNIT","F49_RECNAM",{|| (FwFldGet("F49_REQUES") == "2")},{ |oModel| RU06D05495_GatBankRec("F49_RECNAM",__cMdlHdr)})

oStrF49:AddTrigger("F49_BNKREC","F49_RECBIK",,{ |oModel| RU06D05495_GatBankRec("F49_RECBIK",__cMdlHdr)})
oStrF49:AddTrigger("F49_BNKREC","F49_RECACC",,{ |oModel| RU06D05495_GatBankRec("F49_RECACC",__cMdlHdr)})
oStrF49:AddTrigger("F49_BNKREC","F49_TYPCC" ,,{ |oModel| RU06D05495_GatBankRec("F49_TYPCC", __cMdlHdr)})
oStrF49:AddTrigger("F49_BNKREC","F49_BKRNAM",,{ |oModel| RU06D05495_GatBankRec("F49_BKRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_BNKREC","F49_ACRNAM",,{ |oModel| RU06D05495_GatBankRec("F49_ACRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_BNKREC","F49_RECNAM",,{ |oModel| RU06D05495_GatBankRec("F49_RECNAM",__cMdlHdr)})

oStrF49:AddTrigger("F49_RECACC","F49_TYPCC" ,,{ |oModel| RU06D05495_GatBankRec("F49_TYPCC", __cMdlHdr)})
oStrF49:AddTrigger("F49_RECACC","F49_BKRNAM",,{ |oModel| RU06D05495_GatBankRec("F49_BKRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_RECACC","F49_ACRNAM",,{ |oModel| RU06D05495_GatBankRec("F49_ACRNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_RECACC","F49_RECNAM",,{ |oModel| RU06D05495_GatBankRec("F49_RECNAM",__cMdlHdr)})

oStrF49:AddTrigger("F49_BNKPAY","F49_PAYBIK",,{ |oModel| RU06D05493_GatBankPay("F49_PAYBIK",__cMdlHdr)})
oStrF49:AddTrigger("F49_BNKPAY","F49_PAYACC",,{ |oModel| RU06D05493_GatBankPay("F49_PAYACC",__cMdlHdr)})
oStrF49:AddTrigger("F49_BNKPAY","F49_BKPNAM",,{ |oModel| RU06D05493_GatBankPay("F49_BKPNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_BNKPAY","F49_ACPNAM",,{ |oModel| RU06D05493_GatBankPay("F49_ACPNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_BNKPAY","F49_PAYNAM",,{ |oModel| RU06D05493_GatBankPay("F49_PAYNAM",__cMdlHdr)})

oStrF49:AddTrigger("F49_PAYACC","F49_BKPNAM",,{ |oModel| RU06D05493_GatBankPay("F49_BKPNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_PAYACC","F49_ACPNAM",,{ |oModel| RU06D05493_GatBankPay("F49_ACPNAM",__cMdlHdr)})
oStrF49:AddTrigger("F49_PAYACC","F49_PAYNAM",,{ |oModel| RU06D05493_GatBankPay("F49_PAYNAM",__cMdlHdr)})

// Items structure - F4A Payment Requests
oStrF4A:= FWFormStruct(1, "F4A")
oStrF4A:AddField("FILREQ", "FILREQ", "F4A_FILREQ", "C", LEN(XFILIAL()), /*[ nDecimal ]*/,/*{|| }*/, /*[ bWhen ]*/ ,/* [ aValues ]*/,/* [ lObrigat ]*/,{|| Iif(!INCLUI,F49->F49_FILREQ,"") } /*[ bInit ]*/, .F./*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)

// Items grandson structure - F4B Payment Requests - Lines
oStrF4B:= FWFormStruct(1, "F4B")
oStrF4B:AddField("CheckBox", "CheckBox", "F4B_CHECK", "L", 1, /*[ nDecimal ]*/,/*{|| }*/, /*[ bWhen ]*/,/* [ aValues ]*/,/* [ lObrigat ]*/, /*[ bInit ]*/, .F./*, [ lNoUpd ], [ lVirtual ], [ cValid ]*/)
oStrF4B:SetProperty("F4B_CHECK"	,MODEL_FIELD_INIT,{|| F4B->F4B_RATUSR== "1"})

// Virtual structure to show list of bills from all requests
oStrAllBills := RU06D0525_DefVirtStr()

aStruct := {oStrF49, oStrF4A, oStrF4B, oStrAllBills}

Return (aStruct) //End of RU06D05490_RetStructs()


/*/{Protheus.doc} RU06D05491_ConfigModel
This function returns configured oModel for ModelDef() function
@param  Character cProgram  // "RU06D05" or "RU06D06", etc..
        Object    oModel    // MPFormModel():New() result
        Array     aStruct   // result of RU06D05490_RetStructs()
@return Object    oModel    // configured Model
@author astepanov
@since 24 September 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D05491_ConfigModel(cProgram, oModel, aStruct)

Local oStrF49      As Object
Local oStrF4A      As Object
Local oStrF4B      As Object
Local oStrAllBills As Object
Local aF4ARel      As Array
Local aF4BRel      As Array

Local oUpdF49Event 	:= RU06D05EventRUS():New()

oStrF49      := aStruct[1]
oStrF4A      := aStruct[2]
oStrF4B      := aStruct[3]
oStrAllBills := aStruct[4]
aF4ARel      := {}
aF4BRel      := {}

oModel:SetDescription(STR0002) // Payment Order 

oModel:AddFields("RU06D05_MF49", NIL, oStrF49 )
oModel:GetModel("RU06D05_MF49"):SetDescription(STR0002) // Payment Order 
oModel:GetModel("RU06D05_MF49"):SetFldNoCopy({'F49_FILIAL','F49_IDF49','F49_STATUS','F49_PAYORD','F49_BNKORD','F49_DTPAYM', 'F49_FILREQ'})

If cProgram == "RU06D05"

    oModel:AddGrid('RU06D05_MF4A','RU06D05_MF49',oStrF4A)
    oModel:GetModel("RU06D05_MF4A"):SetDescription(STR0016) // Payment Requests included in PO
    oModel:GetModel('RU06D05_MF4A'):SetOptional(.T.)

    //Array to set the relation betwen the header and the request
    aAdd(aF4ARel, {'F4A_FILIAL',    'xFilial( "F4A" )'} )
    aAdd(aF4ARel, {'F4A_IDF49', 'F49_IDF49'})
    oModel:SetRelation('RU06D05_MF4A', aF4ARel, F4A->(IndexKey(1))) 
    oModel:GetModel("RU06D05_MF4A"):SetNoInsertLine(.T.)
    oModel:GetModel("RU06D05_MF4A"):SetNoUpdateLine(.T.)
    If Type("cRU06D05PT") == "C"
        If cRU06D05PT == "3" // payment to budget
            oModel:GetModel("RU06D05_MF4A"):SetNoInsertLine(.F.)
            oModel:GetModel("RU06D05_MF4A"):SetNoUpdateLine(.F.)
        EndIf
    EndIf
    oModel:GetModel("RU06D05_MF4A"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D05_MF4A")))

    oModel:AddGrid('RU06D05_MF4B','RU06D05_MF4A',oStrF4B)  
    oModel:GetModel("RU06D05_MF4B"):SetDescription(STR0017) // APs in included in PO
    oModel:GetModel('RU06D05_MF4B'):SetOptional(.T.)
    //Array to set the relation betwen the request and the bills
    aAdd(aF4BRel, {'F4B_FILIAL', 'xFilial( "F4B" )'} )
    aAdd(aF4BRel, {'F4B_IDF4A', 'F4A_IDF4A'}) 
    oModel:SetRelation('RU06D05_MF4B', aF4BRel, F4B->(IndexKey(1)))
    If Type("cRU06D05PT") == "C"
        If cRU06D05PT == "3" // payment to budget
            oModel:GetModel("RU06D05_MF4A"):SetNoInsertLine(.F.)
            oModel:GetModel("RU06D05_MF4A"):SetNoUpdateLine(.F.)
        EndIf
    EndIf
    oModel:GetModel("RU06D05_MF4B"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D05_MF4B")))

ElseIf cProgram == "RU06D06"

    oModel:AddGrid('RU06D05_MF4B','RU06D05_MF49',oStrF4B) 
    oModel:GetModel("RU06D05_MF4B"):SetDescription(STR0017) // APs in included in PO
    oModel:GetModel('RU06D05_MF4B'):SetOptional(.T.)
    //Array to set the relation betwen PO and the bills
    aAdd(aF4BRel, {'F4B_FILIAL', 'xFilial( "F4B" )'} )
    aAdd(aF4BRel, {'F4B_IDF49', 'F49_IDF49'}) 
    oModel:SetRelation('RU06D05_MF4B', aF4BRel) 
    oModel:GetModel("RU06D05_MF4B"):SetNoInsertLine(.T.)
    oModel:GetModel("RU06D05_MF4B"):SetNoDeleteLine(.T.)
    oModel:GetModel("RU06D05_MF4B"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D05_MF4B")))

EndIf

oModel:AddGrid("RU06D05_MVIRT", "RU06D05_MF49", oStrAllBills, /*bPreValid*/	, /*bPosValid*/	,,, {|oModel| RU06D0526_LoadBills(oModel)}/* bLoad*/ )
oModel:GetModel("RU06D05_MVIRT"):SetDescription(STR0018) // All bills to show only
If cProgram == "RU06D05"
    oModel:GetModel("RU06D05_MVIRT"):SetOnlyView(.T.)
EndIf
oModel:GetModel('RU06D05_MVIRT'):SetOptional(.T.)
oModel:GetModel("RU06D05_MVIRT"):SetFldNoCopy(RU06D0540_Array(oModel:GetModel("RU06D05_MVIRT")))

oModel:InstallEvent("Name",,oUpdF49Event)

Return oModel //End of RU06D05491_ConfigModel()


/*/{Protheus.doc} RU06D05492_RetView
This function returns configured oView for ViewDef()
@param  Object    oModel    // configured Model
@return Object    oView     // configured View
@author astepanov
@since 24 September 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D05492_RetView(oModel)

Local oView 	as Object
Local oStrF49 	as Object
Local oStrF4A 	as Object
Local oStrF4B 	as Object
Local oStrAllBills as Object

// Header structure - F49 Payment Request - Header
oStrF49 := FWFormStruct(2, "F49")
oStrF49:RemoveField("F49_IDF49")
oStrF49:RemoveField("F49_VRSN")
oStrF49:RemoveField("F49_F5QUID")
oStrF49:AddField("F49_FILIAL","01",RetTitle("F49_FILIAL"),X3Descric(),{},;
                 "C","",Nil,"",.F.,"1","005",{},0,Nil,.F.,Nil,.F.,;
                 GetSX3Cache("F49_FILIAL","X3_TAMANHO")                  )

oStrF49:SetProperty("F49_UNIT"  , MVC_VIEW_CANCHANGE, .F.)

oStrF49:SetProperty("F49_PAYBIK", MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_PAYACC", MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_BKPNAM", MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_ACPNAM", MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_RECBIK", MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_RECACC", MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_TYPCC" , MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_BKRNAM", MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_ACRNAM", MVC_VIEW_CANCHANGE, .F.)
oStrF49:SetProperty("F49_DTACTP", MVC_VIEW_CANCHANGE, .F.)

If Type("cRU06D05PT") == "C"
    If cRU06D05PT == "3" // Payment to budget
        oStrF49:RemoveField("F49_PREPAY")
        oStrF49:RemoveField("F49_CNT")
        oStrF49:RemoveField("F49_F5QDES")
        oStrF49:RemoveField("F49_VATCOD")
        oStrF49:RemoveField("F49_VATRAT")
        oStrF49:RemoveField("F49_VATAMT")
        oStrF49:RemoveField("F49_CTPRE")
        oStrF49:RemoveField("F49_CCPRE")
        oStrF49:RemoveField("F49_ITPRE")
        oStrF49:RemoveField("F49_CLPRE")
    Else
        oStrF49:RemoveField("F49_CODREQ")
        oStrF49:RemoveField("F49_TAX")
        oStrF49:RemoveField("F49_CFGCOD")
        oStrF49:RemoveField("F49_REGNUM")
        oStrF49:RemoveField("F49_BCC")
        oStrF49:RemoveField("F49_OKTMO")
        oStrF49:RemoveField("F49_PAYSTA")
        oStrF49:RemoveField("F49_PSDESC")
        oStrF49:RemoveField("F49_PAYBAS")
        oStrF49:RemoveField("F49_PBDESC")
        oStrF49:RemoveField("F49_UIP")
    EndIf
EndIf

// Items structure - F4A Payment Requests
oStrF4A := FWFormStruct(2, "F4A")
oStrF4A:RemoveField("F4A_IDF4A")
oStrF4A:RemoveField("F4A_IDF49")

// Items structure - F4B Payment Requests - Lines
oStrF4B := FWFormStruct(2, "F4B")
oStrF4B:RemoveField("F4B_IDF4A")
oStrF4B:RemoveField("F4B_IDF49")
oStrF4B:RemoveField("F4B_RATUSR")
oStrF4B:RemoveField("F4B_UUID")
oStrF4B:AddField("F4B_CHECK", "01", RetTitle("F4B_RATUSR"), "CheckBox", {}, "L", "", , "", .T., "","" , , , , .T., , , ) 

// Virtual grid for all bills to show only
oStrAllBills := RU06D0527_DefVirtViewStr()

oView := FWFormView():New()
oView:SetModel(oModel)

//Add fields and grids to View
oView:AddField("RU06D05_VHEAD", oStrF49, "RU06D05_MF49")

If (Type("cRU06D05PT") == "C" .AND. cRU06D05PT != "3") // Don't show grids for payment budget
    If oModel:cSource == "RU06D05"
            oView:AddGrid("RU06D05_VLNS", oStrF4A, "RU06D05_MF4A" )
            oView:SetViewProperty("RU06D05_VLNS", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06D0524_PR2Click(oFormula, cFieldName, nLineGrid, nLineModel )}})

            oView:AddGrid("RU06D05_VGLNS", oStrF4B, "RU06D05_MF4B" )
            oView:SetViewProperty("RU06D05_VGLNS","OnlyView")
            oView:SetViewProperty("RU06D05_VGLNS", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06D0538_AP2Click(oFormula, cFieldName, nLineGrid, nLineModel )}})
            oView:SetViewProperty("RU06D05_VGLNS", "GRIDSEEK", {.T.})
    EndIf

    oView:AddGrid("RU06D05_VVIRT", oStrAllBills, "RU06D05_MVIRT" )
    If oModel:cSource == "RU06D05"
        oView:SetViewProperty("RU06D05_VVIRT","OnlyView")
    EndIf
    oView:SetViewProperty("RU06D05_VVIRT", "GRIDDOUBLECLICK", {{|oFormula, cFieldName, nLineGrid, nLineModel | RU06D0538_AP2Click(oFormula, cFieldName, nLineGrid, nLineModel )}})

    //Add folders, sheets and boxes
    If oModel:cSource == "RU06D05"

        oView:CreateHorizontalBox('SUPERIOR', 100)
        oView:CreateFolder('FOLDER1', 'SUPERIOR')
        oView:AddSheet('FOLDER1', 'Sheet1', STR0061)	//General
        oView:AddSheet('FOLDER1', 'Sheet2', STR0062)	//Requests 

        oView:CreateHorizontalBox("F49POHEAD",60/*%*/,,,'FOLDER1','Sheet1')
        oView:CreateHorizontalBox("F49POBILLS",40/*%*/,,,'FOLDER1','Sheet1')
        oView:CreateHorizontalBox("F4AREQS",60/*%*/,,,'FOLDER1','Sheet2')
        oView:CreateHorizontalBox("F4BBILLS",40/*%*/,,,'FOLDER1','Sheet2')

        oView:SetOwnerView("RU06D05_VHEAD", "F49POHEAD")
        oView:SetOwnerView("RU06D05_VVIRT", "F49POBILLS")
        oView:SetOwnerView("RU06D05_VLNS", "F4AREQS")
        oView:SetOwnerView('RU06D05_VGLNS','F4BBILLS')

    ElseIf oModel:cSource == "RU06D06"

        oView:CreateHorizontalBox("F49POHEAD",60/*%*/)
        oView:CreateHorizontalBox("F49POBILLS",40/*%*/)

        oView:SetOwnerView("RU06D05_VHEAD", "F49POHEAD")
        oView:SetOwnerView("RU06D05_VVIRT", "F49POBILLS")

    EndIf
EndIf

oView:SetAfterViewActivate({|oView| RU06D0515_Brw(oView) })
oView:SetCloseOnOk({|| .T. })
If oModel:cSource == "RU06D06"
    oView:AddUserButton(STR0101, '', {|| RU06XFUN10_PickUpAPs("F49") },,,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})   //Pick Up bills
ElseIf !(Type("cRU06D05PT") == "C" .AND. cRU06D05PT == "3")
    oView:AddUserButton(STR0036, '', {|| RU06D0517_AddReqs()    },,,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})   //Pick Up PRs
    oView:AddUserButton(STR0037, '', {|| RU06D0532_RecalcTotls()},,,{MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE})   //Recalc Total Values
EndIf

if oModel:GetOperation() == MODEL_OPERATION_INSERT
    oView:ShowUpdateMsg(.T.)    
    oView:ShowInsertMessage(.F.)
EndIf 

Return (oView) //End of RU06D05492_RetView


/*/{Protheus.doc} RU06D05493_GatBankPay
This function called when we run triggers for : F49_CURREN, F49_BNKPAY or F49_PAYACC
The main reason for this function : return a content for bank account related fields like:
F49_BNKPAY,F49_PAYBIK,F49_PAYACC,F49_BKPNAM,F49_ACPNAM,F49_PAYNAM according to rules
described in https://jiraproducao.totvs.com.br/browse/RULOC-825
@param  Character cField      // Target field id, for which we return cRet
        Character cModelID   // Character id to header model
@return Character cRet
@author astepanov
@since 28 September 2020
@version 1.0
@project MA3 - Russia
/*/
Function RU06D05493_GatBankPay(cField,cModelID)

    Local cRet        As Character
    Local cAlias      As Character
    Local cTab        As Character
    Local cBnkField   As Character
    Local cBICField   As Character
    Local cAccField   As Character
    Local cCurField   As Character
    Local cPayRecNam  As Character
    Local cBKPRNam    As Character
    Local cACPRNam    As Character
    Local cTypNam     As Character
    Local aArea       As Array
    Local aResD05493  As Array
    Local nX          As Numeric
    Local lPutDeflt   As Logical

    cRet  := ""
    aArea :=  GetArea()
    If cModelID == __cMdlHdr
        cTab       := __cTabHdr
        cBnkField  := cTab+"_BNKPAY"
        cBICField  := cTab+"_PAYBIK"
        cAccField  := cTab+"_PAYACC"
        cCurField  := cTab+"_CURREN"
        cBKPRNam   := cTab+"_BKPNAM"
        cPayRecNam := cTab+"_PAYNAM"
        cACPRNam   := cTab+"_ACPNAM"
        cTypNam    := cTab+"_TYPCP"
    ElseIf cModelID == "RU06D07_MHEAD"
        cTab := "F4C"
        cCurField := cTab+"_CURREN"
        If FwFldGet("F4C_OPER") == "1"     // Inflow BS
            cBnkField  := cTab+"_BNKREC" 
            cBICField  := cTab+"_RECBIK"
            cAccField  := cTab+"_RECACC"
            cPayRecNam := cTab+"_RECNAM"
            cBKPRNam   := cTab+"_BKRNAM"
            cACPRNam   := cTab+"_ACRNAM"
            cTypNam    := cTab+"_TYPCC"
        ElseIf FwFldGet("F4C_OPER") == "2" // Outflow BS
            cBnkField  := cTab+"_BNKPAY"
            cBICField  := cTab+"_PAYBIK"
            cAccField  := cTab+"_PAYACC"
            cPayRecNam := cTab+"_PAYNAM"
            cBKPRNam   := cTab+"_BKPNAM"
            cACPRNam   := cTab+"_ACPNAM"
            cTypNam    := cTab+"_TYPCP"
        EndIf
    EndIf
    aResD05493 := {{"",""}}
    cAlias     := ""
    If cField == cBnkField
        // we put bank info for company if we have main account
        // or we have only one non-main account in other cases
        // we clear bank account data.
        // https://jiraproducao.totvs.com.br/browse/RULOC-825
        lPutDeflt  := .T.
        cAlias := RU06XFUN39_RetBankAccountDataFromSA6(,,,Val(FwFldGet(cCurField)),.F.,.T.,.T.)
        aArea  := GetArea()
        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())
        If (cAlias)->(!Eof())
            If !(AllTrim((cAlias)->_TYPCC) == "1") .OR. !(AllTrim((cAlias)->_TYPCP) == "1")
               (cAlias)->(DBSkip())
                If (cAlias)->(!Eof())
                    lPutDeflt := .F.
                EndIf
            EndIf
            (cAlias)->(DBGoTop())
            If lPutDeflt
                AADD(aResD05493, {cBnkField, (cAlias)->_BNKPAY})
                AADD(aResD05493, {cBICField, (cAlias)->_PAYBIK})
                AADD(aResD05493, {cAccField, (cAlias)->_PAYACC})
                AADD(aResD05493, {cBKPRNam,  (cAlias)->_BKPNAM})
                AADD(aResD05493, {cACPRNam,  (cAlias)->_ACPNAM})
                AADD(aResD05493, {cPayRecNam,(cAlias)->_PAYNAM})
                AADD(aResD05493, {cTypNam   ,(cAlias)->_TYPCP })
            EndIf
        EndIf
        (cAlias)->(DBCloseArea())
        RestArea(aArea) 
    Else  //!(cField == cBnkField)
        If !Empty(FWFldGet(cBnkField))
            // if we will add for standard query SA6PO a filter for blocked bank accounts
            // we should change 6th parameter (lExBlkd) to .T.
            If     cField == cBICField
                cAlias := RU06XFUN39_RetBankAccountDataFromSA6(FWFldGet(cBnkField),Nil,Nil,Val(FwFldGet(cCurField)),.F.,.F.,.T.)
            ElseIf cField == cAccField
                cAlias := RU06XFUN39_RetBankAccountDataFromSA6(FWFldGet(cBnkField),FWFldGet(cBICField),Nil,Val(FwFldGet(cCurField)),.F.,.F.,.T.)
            Else
                cAlias := RU06XFUN39_RetBankAccountDataFromSA6(FWFldGet(cBnkField),FWFldGet(cBICField),FWFldGet(cAccField),Val(FwFldGet(cCurField)),.F.,.F.,.T.)
            EndIf
        EndIf
        If !Empty(cAlias)
            DBSelectArea(cAlias)
            (cAlias)->(DBGoTop())
            If (cAlias)->(!Eof())
                AADD(aResD05493, {cBnkField, (cAlias)->_BNKPAY})
                AADD(aResD05493, {cBICField, (cAlias)->_PAYBIK})
                AADD(aResD05493, {cAccField, (cAlias)->_PAYACC})
                AADD(aResD05493, {cBKPRNam,  (cAlias)->_BKPNAM})
                AADD(aResD05493, {cACPRNam,  (cAlias)->_ACPNAM})
                AADD(aResD05493, {cPayRecNam,(cAlias)->_PAYNAM})
                AADD(aResD05493, {cTypNam   ,(cAlias)->_TYPCP })
            EndIf
            (cAlias)->(DBCloseArea())
        EndIf
    EndIf
    nX := ASCAN(aResD05493 ,{|x| x[1] == cField})
    If nX > 0
        cRet := PADR(aResD05493[nX][2],GetSX3Cache(cField,"X3_TAMANHO"), " ")
    EndIf

    RestArea(aArea)

Return (cRet) //End of RU06D05493_GatBankPay


/*/{Protheus.doc} RU06D05495_GatBankRec
This function called when we run triggers for : F49_CURREN, F49_BNKREC, F49_SUPP, F49_UNIT or F49_RECACC
The main reason for this function : return a content for bank account related fields like:
F49_BNKREC,F49_RECBIK,F49_RECACC,F49_TYPCC,F49_BKRNAM,F49_ACRNAM,F49_RECNAM according to rules
described in https://jiraproducao.totvs.com.br/browse/RULOC-825
@param  Character cField  // Target field id, for which we return cRet
        Character cModel  // header model id __cMdlHdr or "RU06D07_MHEAD"
@return Character cRet
@author astepanov
@since 30 September 2020
@version 1.1
@project MA3 - Russia
/*/
Function RU06D05495_GatBankRec(cField, cModelID)
    Local cRet        As Character
    Local cAlias      As Character
    Local cTab        As Character
    Local cBnkField   As Character
    Local cBICField   As Character
    Local cAccField   As Character
    Local cCurField   As Character
    Local cPayRecNam  As Character
    Local cBKPRNam    As Character
    Local cACPRNam    As Character
    Local cTypNam     As Character
    Local cSupField   As Character
    Local cUntField   As Character
    Local lPutDeflt   As Logical
    Local aArea       As Array
    Local aResD05495  As Array
    Local nX          As Numeric

    cRet  := ""
    aArea := GetArea()
    If cModelID == __cMdlHdr
        cTab := __cTabHdr
    ElseIf cModelID == "RU06D07_MHEAD"
        cTab := "F4C"
    ElseIf cModelID == "RU06D04_MHEAD"
        cTab := "F47"
    EndIf
    If cModelID == "RU06D04_MHEAD"
        cBnkField  := cTab+"_BNKCOD"
        cBICField  := cTab+"_BIK"
        cAccField  := cTab+"_ACCNT"
        cCurField  := cTab+"_CURREN"
        cBKPRNam   := cTab+"_BKNAME"
        cPayRecNam := cTab+"_RECNAM"
        cACPRNam   := cTab+"_ACNAME"
        cTypNam    := cTab+"_TYPCC"
        cSupField  := cTab+"_SUPP"
        cUntField  := cTab+"_UNIT"
    Else
        cBnkField  := cTab+"_BNKREC"
        cBICField  := cTab+"_RECBIK"
        cAccField  := cTab+"_RECACC"
        cCurField  := cTab+"_CURREN"
        cBKPRNam   := cTab+"_BKRNAM"
        cPayRecNam := cTab+"_RECNAM"
        cACPRNam   := cTab+"_ACRNAM"
        cTypNam    := cTab+"_TYPCC"
        cSupField  := cTab+"_SUPP"
        cUntField  := cTab+"_UNIT"
    EndIf
    aResD05495 := {{"",""}}
    cAlias     := ""
    If cField == cBnkField
        // we put reciever's bank company info if we have main account
        // or we have only one non-main account in other cases
        // we clear reciever's bank account data.
        // https://jiraproducao.totvs.com.br/browse/RULOC-825
        If !Empty(FWFldGet(cSupField)) .AND. !Empty(FWFldGet(cUntField))
            lPutDeflt  := .T.
            cAlias := RU06XFUN38_RetSuppDataByKey(FWFldGet(cSupField), FWFldGet(cUntField), Val(FwFldGet(cCurField)),, " INNER JOIN ", .F.)
            aArea  := GetArea()
            DBSelectArea(cAlias)
            (cAlias)->(DBGoTop())
            If (cAlias)->(!Eof())
                If !(AllTrim((cAlias)->_TYPCC) == "1")
                (cAlias)->(DBSkip())
                    If (cAlias)->(!Eof())
                        lPutDeflt := .F.
                    EndIf
                EndIf
                (cAlias)->(DBGoTop())
                If lPutDeflt
                    AADD(aResD05495, {cBnkField, (cAlias)->_BNKREC})
                    AADD(aResD05495, {cBICField, (cAlias)->_RECBIK})
                    AADD(aResD05495, {cAccField, (cAlias)->_RECACC})
                    AADD(aResD05495, {cTypNam,   (cAlias)->_TYPCC })
                    AADD(aResD05495, {cBKPRNam,  (cAlias)->_BKRNAM})
                    AADD(aResD05495, {cACPRNam,  (cAlias)->_ACRNAM})
                    AADD(aResD05495, {cPayRecNam,(cAlias)->_RECNAM})
                EndIf
            EndIf
            (cAlias)->(DBCloseArea())
            RestArea(aArea)
        EndIf
    Else //cField != cBnkField
        If !Empty(FWFldGet(cBnkField))
            // if we will add for standard query FIL a filter for blocked bank accounts
            // we should change 6th parameter (lExBlkd) to .T.
            If   cField == cBICField
                cAlias := RU06XFUN38_RetSuppDataByKey(FWFldGet(cSupField), FWFldGet(cUntField), Val(FwFldGet(cCurField)),FWFldGet(cBnkField), " INNER JOIN ", .F.,;
                                                      Nil, Nil)
            ElseIf cField == cAccField
                cAlias := RU06XFUN38_RetSuppDataByKey(FWFldGet(cSupField), FWFldGet(cUntField), Val(FwFldGet(cCurField)),FWFldGet(cBnkField), " INNER JOIN ", .F.,;
                                                      FWFldGet(cBICField), Nil)
            Else
                cAlias := RU06XFUN38_RetSuppDataByKey(FWFldGet(cSupField), FWFldGet(cUntField), Val(FwFldGet(cCurField)),FWFldGet(cBnkField), " INNER JOIN ", .F.,;
                                                      FWFldGet(cBICField), FWFldGet(cAccField))
            EndIf
        EndIf
        If !Empty(cAlias)
            DBSelectArea(cAlias)
            (cAlias)->(DBGoTop())
            If (cAlias)->(!Eof())
                AADD(aResD05495, {cBnkField, (cAlias)->_BNKREC})
                AADD(aResD05495, {cBICField, (cAlias)->_RECBIK})
                AADD(aResD05495, {cAccField, (cAlias)->_RECACC})
                AADD(aResD05495, {cTypNam,   (cAlias)->_TYPCC })
                AADD(aResD05495, {cBKPRNam,  (cAlias)->_BKRNAM})
                AADD(aResD05495, {cACPRNam,  (cAlias)->_ACRNAM})
                AADD(aResD05495, {cPayRecNam,(cAlias)->_RECNAM})
            EndIf
            (cAlias)->(DBCloseArea())
        EndIf
    EndIf
    nX := ASCAN(aResD05495 ,{|x| x[1] == cField})
    If nX > 0
        cRet := PADR(aResD05495[nX][2],GetSX3Cache(cField,"X3_TAMANHO"), " ")
    EndIf
    RestArea(aArea)
    
Return cRet


/* {Protheus.doc} RU06D05497_DelLinesInTheGrid
This function called when we changed supplier info (code or unit)
from RU06D0548_GatForn or we change supplier info (code or unit)
from RU06D07037_GatCust
We delete all lines in a related grid.
@return Nil
@author astepanov
@since 02 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D05497_DelLinesInTheGrid()
    Local oModel     As Object
    Local oModelGrd  As Object

    oModel := FWModelActive()
    If oModel != Nil
        If     oModel:cSource == "RU06D05"
            oModelGrd := oModel:GetModel("RU06D05_MF4A")
            oModelGrd:DelAllLine()
        ElseIf oModel:cSource == "RU06D06"
            oModelGrd := oModel:GetModel("RU06D05_MVIRT")
            oModelGrd:DelAllLine()
        ElseIf oModel:cSource == "RU06D07"
            oModelGrd := oModel:GetModel("RU06D07_MVIRT")
            oModelGrd:DelAllLine()
        EndIf
    EndIf

Return Nil

/* {Protheus.doc} RU06D05498_LoadValuesToVirt
This function used for loading values from line in RU06D05_MF4B and 
RU06D05_MF4A models to RU06D05_MVIRT model
In case if oModel has error message we show it using Help()
@return Nil
@author astepanov
@since 09 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D05498_LoadValuesToVirt(oModel, oModelVirt, oModelF4B, oModelF4A)

    Local aError     As Array

    oModelVirt:LoadValue("B_BRANCH",    xFilial ("F4B"))
    oModelVirt:LoadValue("B_CHECK",     IIF(oModelF4B:GetValue("F4B_RATUSR")=='1' ,.T.,.F.))

    If oModel:GetModel("RU06D05_MF49"):GetValue("F49_REQUES") == "1" // PO with PR
        If POSICIONE("F47",1,; //F47_FILIAL+F47_CODREQ+DTOS(F47_DTREQ)
                    oModel:GetModel("RU06D05_MF49"):GetValue("F49_FILREQ")+;
                    oModelF4A:GetValue("F4A_CODREQ")+;
                    DTOS(oModelF4A:GetValue("F4A_DTREQ")),;
                    "F47_PREPAY") != "1"
            oModelVirt:LoadValue("B_CODREQ",    oModelF4A:GetValue("F4A_CODREQ"))
            oModelVirt:LoadValue("B_IDF4A",     oModelF4A:GetValue("F4A_IDF4A"))
        EndIf
    EndIf

    oModelVirt:LoadValue("B_PREFIX",    oModelF4B:GetValue("F4B_PREFIX"))
    oModelVirt:LoadValue("B_NUM",       oModelF4B:GetValue("F4B_NUM"))
    oModelVirt:LoadValue("B_PARCEL",    oModelF4B:GetValue("F4B_PARCEL") )
    oModelVirt:LoadValue("B_TYPE",      oModelF4B:GetValue("F4B_TYPE") )
    oModelVirt:LoadValue("B_CLASS",     oModelF4B:GetValue("F4B_CLASS") )
    oModelVirt:LoadValue("B_EMISS",     oModelF4B:GetValue("F4B_EMISS") )
    oModelVirt:LoadValue("B_REALMT",    oModelF4B:GetValue("F4B_REALMT") )
    oModelVirt:LoadValue("B_VALPAY",    oModelF4B:GetValue("F4B_VALPAY") )

    oModelVirt:LoadValue("B_EXGRAT",    oModelF4B:GetValue("F4B_EXGRAT") )
    oModelVirt:LoadValue("B_VALCNV",    oModelF4B:GetValue("F4B_VALCNV") )
    oModelVirt:LoadValue("B_BSVATC",    oModelF4B:GetValue("F4B_BSVATC") )
    oModelVirt:LoadValue("B_VLVATC",    oModelF4B:GetValue("F4B_VLVATC") )

    oModelVirt:LoadValue("B_VALUE",     oModelF4B:GetValue("F4B_VALUE") )
    oModelVirt:LoadValue("B_CURREN",    oModelF4B:GetValue("F4B_CURREN") )
    oModelVirt:LoadValue("B_CONUNI",    oModelF4B:GetValue("F4B_CONUNI") )
    oModelVirt:LoadValue("B_VLCRUZ",    oModelF4B:GetValue("F4B_VLCRUZ") )
    oModelVirt:LoadValue("B_OPBAL",     oModelF4B:GetValue("F4B_OPBAL") )
    oModelVirt:LoadValue("B_BSIMP1",    oModelF4B:GetValue("F4B_BSIMP1") )
    oModelVirt:LoadValue("B_ALIMP1",    oModelF4B:GetValue("F4B_ALIMP1") )
    oModelVirt:LoadValue("B_VLIMP1",    oModelF4B:GetValue("F4B_VLIMP1") )
    oModelVirt:LoadValue("B_MDCNTR",    oModelF4B:GetValue("F4B_MDCNTR") )
    oModelVirt:LoadValue("B_FLORIG",    oModelF4B:GetValue("F4B_FLORIG") )

    If oModel:HasErrorMessage()
        aError := oModel:GetErrorMessage()
        HELP("",1, aError[MODEL_MSGERR_IDFORM],,;  //Form
        aError[MODEL_MSGERR_IDFIELDERR] + " "+;
        aError[MODEL_MSGERR_MESSAGE],;    //Field and error
        1,0,,,,,,;
        {aError[MODEL_MSGERR_SOLUCTION]}) //Solution
    EndIf

Return Nil //End of RU06D05498_LoadValuesToVirt


/* {Protheus.doc} RU06D05502_GetF5MKeyFromF4BLine
This function generates F5M_KEY from F4B line and from F49_SUPP and F49_UNIT
@param  Object       oModelGrd // link to grid model which relates to F4B table
        Object       oModelHdr // link to header model which relates to F49 table
@return Character    cKeyF5M
@author astepanov
@since 27 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D05502_GetF5MKeyFromF4BLine(oModelGrd, oModelHdr)

	Local   cKeyF5M     As Character
	Local   cPrefix     As Character
    Local   cHeadPr     As Character

	cPrefix     := "F4B_" 
    cHeadPr     := "F49_"
	cKeyF5M := oModelGrd:GetValue(cPrefix+"FLORIG")+"|"+;
	           oModelGrd:GetValue(cPrefix+"PREFIX")+"|"+;
	           oModelGrd:GetValue(cPrefix+"NUM")   +"|"+;
	           oModelGrd:GetValue(cPrefix+"PARCEL")+"|"+;
	           oModelGrd:GetValue(cPrefix+"TYPE")  +"|"+;
	           oModelHdr:GetValue(cHeadPr+"SUPP")  +"|"+ ;
	           oModelHdr:GetValue(cHeadPr+"UNIT")
	cKeyF5M := PADR(cKeyF5M,GetSX3Cache("F5M_KEY","X3_TAMANHO")," ")

Return cKeyF5M //End of RU06D05502_GetF5MKeyFromF4BLine


/* {Protheus.doc} RU06D05506_Ret_OPBAL
We use this function for  open balance generation for F4B_OPBAL (or B_OPBAL)
At core we use query from RU06XFUN55_QuerryF5MBalance, which can provide us E2_SALDO
for SE2 record (for positioning in SE2 we use cKeyF5M henerated from F4B line) and
TOTAL which equal SUM(F5M_VALPAY) for F5M records with F5M_CTRBAL == "1".

Also we increase our balance to F5M_VALPAY. How we get it?
When we insert PO or copy it , we use rule from RU06D0521_WriteToModel() :
Posicione("F5M",1,xFilial("F5M")+"F48"+(cTabLns)->F48_UUID+cKeyF5M,"F5M_VALPAY"))
and we use rule rule:
Posicione("F5M",1,xFilial("F5M")+"F4B"+FwFldGet("F4B_UUID")+cKeyF5M,"F5M_VALPAY")
look for R604RetSe2() when nField == 10

So when we have line in F5M with alias == "F48" and F5M_CTRBAL == "1",
we have no line in F5M with alias "F4B".
When line in F5M with alias "F4B" and F5M_CTRBAL == "1" will be created,
the line with alias "F48" should have F5M_CTRABL equal "2".
So if we have correct data cSubQrF48 and cSubQrF4B will not duplicate data.

We create and run one sql query for getting consistent data.
This function can be used fo PO with PR and without PR.
@param  Object       oModelGrd // link to grid model which relates to F4B table
        Object       oMdlHdr   // link to header model which relates to F49 table
@return Character    cKeyF5M
@author astepanov
@since 27 October 2020
@version 1.0
@project MA3 - Russia
*/
Function RU06D05506_Ret_OPBAL(oModelGrd,oMdlHdr)
	Local nRet       As Numeric
	Local cKeyF5M    As Character
	Local cSupp      As Character
	Local cUnit      As Character
	Local cQuery     As Character
	Local cAlias     As Character
	Local cF48Fil    As Character
    Local cSubQrF48  As Character
    Local cSubQrF4B  As Character
    Local cIDF4A     As Character
	Local aArea      As Array

	nRet      := 0
	cSubQrF48 := ""
    cSubQrF4B := ""
	cSupp     := oMdlHdr:GetValue("F49_SUPP")
	cUnit     := oMdlHdr:GetValue("F49_UNIT")
	cKeyF5M   := RU06D05502_GetF5MKeyFromF4BLine(oModelGrd, oMdlHdr)
    // unique indice for F48 is:
    // F48_FILIAL+F48_IDF48+F48_PREFIX+F48_NUM+F48_PARCEL+F48_TYPE
    // So:
    // define F48_FILIAL :
    // look for this rule in RU06D0517_AddReqs() when we set MV_PAR10
    // and when we use MV_PAR10 in filter in query:
    // cQueryLns += " WHERE F48_FILIAL ='" + MV_PAR10 +"'"
    // in RU06D0521_WriteToModel()
    cF48Fil   := IIF(!Empty(FwFldGet("F49_FILREQ")),FwFldGet("F49_FILREQ"),xFilial("F49"))
    // define F48_IDF48 :
    // F48_IDF48 == F4B_IDF4A, when we load from PR, look for this rule in
    // RU06D0521_WriteToModel()
    cIDF4A    := oModelGrd:GetValue("F4B_IDF4A")
    // F48_PREFIX+F48_NUM+F48_PARCEL+F48_TYPE == F4B_PREFIX+F4B_NUM+F4B_PARCEL+F4B_TYPE
    cSubQrF48 := " (   SELECT *                                                      "
    cSubQrF48 += "     FROM   "+RetSQLName("F48")+" F48                              "
    cSubQrF48 += "     WHERE F48.F48_FILIAL = '"+cF48Fil+"'                          "
    cSubQrF48 += "       AND F48.F48_IDF48  = '"+cIDF4A+"'                           "
    cSubQrF48 += "       AND F48.F48_PREFIX = '"+oModelGrd:GetValue("F4B_PREFIX")+"' "
    cSubQrF48 += "       AND F48.F48_NUM    = '"+oModelGrd:GetValue("F4B_NUM")   +"' "
    cSubQrF48 += "       AND F48.F48_PARCEL = '"+oModelGrd:GetValue("F4B_PARCEL")+"' "
    cSubQrF48 += "       AND F48.F48_TYPE   = '"+oModelGrd:GetValue("F4B_TYPE")  +"' "
    cSubQrF48 += "       AND F48.D_E_L_E_T_ = ' '                                    "
    cSubQrF48 += " )                                                    F48          "
    cSubQrF48 += "     LEFT JOIN "+RetSQLName("F5M")+"                  F5M          "
    cSubQrF48 += "            ON ("+RU06XFUN79_JoinOnF5MToF48(cSupp,cUnit)+"         "
    cSubQrF48 += "                 AND F5M.F5M_CTRBAL = '1'                          "
    cSubQrF48 += "               )                                                   "
    // unique key for F4B is F4B_FILIAL+F4B_IDF4A+F4B_PREFIX+F4B_NUM+F4B_PARCEL+F4B_TYPE
    cSubQrF4B := " ( SELECT *                                                       "
    cSubQrF4B += "   FROM   "+RetSQLName("F4B")+" F4B                               "
    cSubQrF4B += "   WHERE  F4B.F4B_FILIAL = '"+xFilial("F4B")+"'                   "
    cSubQrF4B += "     AND  F4B.F4B_IDF4A  = '"+cIDF4A+"'                           "
    cSubQrF4B += "     AND  F4B.F4B_PREFIX = '"+oModelGrd:GetValue("F4B_PREFIX")+"' "
    cSubQrF4B += "     AND  F4B.F4B_NUM    = '"+oModelGrd:GetValue("F4B_NUM")   +"' "
    cSubQrF4B += "     AND  F4B.F4B_PARCEL = '"+oModelGrd:GetValue("F4B_PARCEL")+"' "
    cSubQrF4B += "     AND  F4B.F4B_TYPE   = '"+oModelGrd:GetValue("F4B_TYPE")  +"' "
    cSubQrF4B += "     AND  F4B.D_E_L_E_T_ = ' '                                    "
    cSubQrF4B += " )                                                    F4B         "
    cSubQrF4B += "   LEFT JOIN "+RetSQLName("F5M")+"                    F5M         "
    cSubQrF4B += "          ON ("+RU06XFUN78_JoinOnF5MToF4B(cSupp,cUnit)+"          "
    cSubQrF4B += "                 AND F5M.F5M_CTRBAL = '1'                         "
    cSubQrF4B += "               )                                                  "
    //main query
	cQuery := " SELECT                SUM(BAL.SALDO)      SALDO,         "
	cQuery += "                       SUM(BAL.TOTAL)      TOTAL,         "
	cQuery += "                       SUM(BAL.F5M_VALPAY) F5M_VALPAY     "
	cQuery += " FROM                                                     "
	cQuery += "(                                                         "
	cQuery += "     SELECT COALESCE(SLD.SALDO,0)       SALDO,            "
	cQuery += "            COALESCE(SLD.TOTAL,0)       TOTAL,            "
	cQuery += "            0                           F5M_VALPAY        "
	cQuery += "     FROM ("+RU06XFUN55_QuerryF5MBalance(cKeyF5M)+") SLD  "
	cQuery += "     UNION                                                "
	cQuery += "     SELECT 0                           SALDO,            "
	cQuery += "            0                           TOTAL,            "
	cQuery += "           COALESCE(F5M.F5M_VALPAY,0)   F5M_VALPAY        "
	cQuery += "     FROM "+cSubQrF48+"                                   "
    cQuery += "     UNION                                                "
    cQuery += "     SELECT 0                           SALDO,            "
	cQuery += "            0                           TOTAL,            "
	cQuery += "           COALESCE(F5M.F5M_VALPAY,0)   F5M_VALPAY        "
	cQuery += "     FROM "+cSubQrF4B+"                                   "
	cQuery += ") BAL                                                     "
	cQuery := ChangeQuery(cQuery)
	cAlias := CriaTrab( , .F.)
	TcQuery cQuery New Alias ((cAlias))
	TCSetField(cAlias,"SALDO",GetSX3Cache("E2_SALDO","X3_TIPO"),;
	                          GetSX3Cache("E2_SALDO","X3_TAMANHO"),;
	                          GetSX3Cache("E2_SALDO","X3_DECIMAL") )
	TCSetField(cAlias,"TOTAL",GetSX3Cache("F5M_VALPAY","X3_TIPO"),;
	                          GetSX3Cache("F5M_VALPAY","X3_TAMANHO"),;
	                          GetSX3Cache("F5M_VALPAY","X3_DECIMAL") )
	TCSetField(cAlias,"F5M_VALPAY",GetSX3Cache("F5M_VALPAY","X3_TIPO"),;
	                               GetSX3Cache("F5M_VALPAY","X3_TAMANHO"),;
	                               GetSX3Cache("F5M_VALPAY","X3_DECIMAL") )
	aArea := GetArea()
	DBSELECTAREA(cAlias)
	(cAlias)->(DBGoTop())
	If (cAlias)->(!Eof())
		nRet := ((cAlias)->SALDO - (cAlias)->TOTAL) + (cAlias)->F5M_VALPAY
	EndIf
	(cAlias)->(DBCloseArea())
	RestArea(aArea)

Return nRet //End of RU06D05506_Ret_OPBAL

/*/{Protheus.doc} RU06D05Sta
    Function for setting or getting static variables
    Put only first parameter if you want to get a default value.
    Put also second parameter if you want to set
    @type Function
    @author astepanov
    @since 02/08/2022
    @version version
    @param cStaticVar, character, Static Var name
    @param xSet, variant, value which we must set
    @return xRet, variant, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function RU06D05Sta(cStaticVar,xSet)
    Local xRet As Variant
    If xSet != NIL
        &(cStaticVar) := xSet
    Else
        If cStaticVar == "__lDsrmTra"
            xRet := LDISARMEADTRANSACTION
        EndIf
    EndIf
Return xRet

/*/{Protheus.doc} RU06D05507_PayType()
    Small window for selecting payment type stored in SX5 table
    @type  Function
    @author astepanov
    @since 25/03/2024
    @version version
    @param 
    @return {cPayType,cPTFullTxt}, Array, {Payment type code, Payment type description}
    (examples)
    @see FI-CF-25-20 Payment order for budget payments
    /*/
Function RU06D05507_PayType()
    Local cSelOperDi As Character
    Local aPayTypes  As Array
    Local oDlg       As Object
    Local oGrpPaym   As Object
    Local oCmbPt     As Object
    Local oButtonOk  As Object
    Local oButtonCnc As Object
    Local cPayType   As Character
    Local cX         As Character
    Local cPTFullTxt As Character
    Local nX         As Numeric
    cX := ""
    If !IsBlind()
        cSelOperDi := "2" //Outflow - like in Outflow Bank statement
        aPayTypes := RU06D0719_ReturnPayTypes(cSelOperDi)
        oDlg := MSDialog():New( 01, 01, 120, 245, STR0001,,,,,,,,,.T.) //Payment orders
        oGrpPaym := TGroup():New( 05, 05, 40, 120,  STR0001,oDlg,,,.T.) //Payment orders
        oCmbPt := TComboBox():New(20, 10,;
                                    {|u| If(PCount() > 0,;
                                    cPayType := u,;
                                    cPayType)},;
                                    aPayTypes, 105, 20, oDlg,,;
                                    ,,,,;
                                    .T.,,,,,,,,,"cPayType",;
                                    Nil)
        oButtonOk   := SButton():Create(oDlg, 45, 65, 1, {||oDlg:End()}, .T.,, {||.T.})
        oButtonCnc  := SButton():Create(oDlg, 45, 95, 2, {||oDlg:End(), cPayType := "1" }, .T.,, {||.T.})
        oDlg:Activate()
        cPayType := AllTrim(cPayType)
        cPTFullTxt := cPayType
        For nX := 1 To Len(cPayType)
            If IsDigit(SubStr(cPayType,nX,1))
                cX += SubStr(cPayType,nX,1)
            Else
                Exit
            EndIf 
        Next nX
    EndIf
    If !Empty(cX)
        cPayType := cX
    Else 
        cPayType := "1"
        cPTFullTxt := cPayType 
    EndIf
Return {cPayType,cPTFullTxt}

/*/{Protheus.doc} RU06D05519_PayToSupp()
    Window where we select optionfor creationg PO: from request or manual
    @type  Function
    @author astepanov
    @since 25/03/2024
    @version version
    @param cPTFullTxt, Character, Text for window title
    @return nSelect, Numeric, 1 - Create from request, 2 - Create manually
    (examples)
    @see FI-CF-25-20 Payment order for budget payments
    /*/
Function RU06D05519_PayToSupp(cPTFullTxt)
    Local nSelect    As Numeric // 1 - Add From Request, 2 - Add Manually
    Local oDlg       As Object
    Local oGrpPaym   As Object
    Local oRadio     As Object
    Local oButtonOk  As Object
    Local oButtonCnc As Object
    Local aItems   As Array
    Default cPTFullTxt := ""
    nSelect := 1
    If !IsBlind()
        oDlg   := MSDialog():New( 01, 01, 160, 245, cPTFullTxt,,,,,,,,,.T.)
        oGrpPaym := TGroup():New( 05, 05, 60, 120, STR0028, oDlg,,,.T.) //Add
        aItems := {STR0008,STR0009}
        oRadio := TRadMenu():New (15,10,aItems,,oDlg,,,,,,,,105,40,,,,.T.)
        oRadio:bSetGet := {|u| Iif (PCount() == 0,nSelect,nSelect:=u)}
        oButtonOk   := SButton():Create(oDlg, 65, 65, 1, {||oDlg:End()}, .T.,, {||.T.})
        oButtonCnc  := SButton():Create(oDlg, 65, 95, 2, {||oDlg:End(), nSelect := 1 }, .T.,, {||.T.})
        oDlg:Activate()
    EndIf
Return nSelect

/*/{Protheus.doc} RU06D05520_Inclusion()
    Inclusion function which open several windows before creating PO
    @type  Function
    @author astepanov
    @since 25/03/2024
    @version version
    @param nOper, Numeric, 3 - standard code for inclusion
    @return lRet, Logical, .T. if all is ok
    (examples)
    @see FI-CF-25-20 Payment order for budget payments
    /*/
Function RU06D05520_Inclusion(nOper)
    Local lRet As Logical
    Local aPayTyp As Array
    Local nOption As Numeric // 1 - Create from PR, 2 - Create manually
    Local cPayTyp As Character
    Default nOper   := 3 // Add
    cPayTyp := "1" // Payment to supplier
    If !IsBlind()
        If nOper == 3
            aPayTyp := RU06D05507_PayType()
            cPayTyp := aPayTyp[1]
            If cPayTyp == "1" // Payment to supplier
                nOption := RU06D05519_PayToSupp(aPayTyp[2])
            ElseIf cPayTyp == "3" // Payment to budget
                nOption := 1
            EndIf
        EndIf
    EndIf
    lRet := RU06D0510_Act(nOper, nOption, cPayTyp)
Return lRet

/*/{Protheus.doc} RU06D05521_F47BUDSQLFilter()
    Sql filter for F47BUD standard query
    @type  Function
    @author astepanov
    @since 25/03/2024
    @version version
    @param
    @return cSqlFilter, Character, part of sql query used by standard query
    (examples)
    @see FI-CF-25-20 Payment order for budget payments
    /*/
Function RU06D05521_F47BUDSQLFilter()
    Local cSqlFilter As Character
    Local cStatus    As Character
    Local cReqTyp    As Character
    cSqlFilter := ""
    If F47->F47_REQTYP != Nil .AND. F47->F47_STATUS != Nil
        cReqTyp := "3"
        If SuperGetMv("MV_REQAPR",, 0) == 1
            cStatus := "4"
        Else
            cStatus := "1"
        EndIf
        cSqlFilter := "@ F47_REQTYP = '"+cReqTyp+"' AND F47_STATUS = '"+cStatus+"' "
    EndIf
Return cSqlFilter
                   
//Merge Russia R14 
                   
