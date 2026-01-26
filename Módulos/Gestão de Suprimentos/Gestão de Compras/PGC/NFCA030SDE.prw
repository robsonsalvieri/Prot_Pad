#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "NFCA030SDE.CH"

PUBLISH MODEL REST NAME NFCA030SDE SOURCE NFCA030SDE

Function NFCA030SDE()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Model da tela.
@author renan.martins
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruDHU	:= NF030SDEMD()
	Local oModel	:= nil

	oModel := MPFormModel():New('NFCA030SDE',/*bPreVld*/, /*{|oModel| PosValid(oModel)}*/, {|oModel| NF030SDGoSend(oModel)}) 

	oModel:AddFields( 'DHUMASTER', , oStruDHU )
    oModel:SetDescription( STR0001 ) //Teste de E-mail
    oModel:GetModel('DHUMASTER'):SetDescription( STR0001 ) 
	oModel:SetPrimaryKey({'DHU_NUM', 'DHU_EMAIL'})
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author renan.martins
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.NFCA030SDE' OPERATION 3 ACCESS 0 //-- Incluir
Return(aRotina) 


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface com usuário
@author renan.martins
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel := FWLoadModel("NFCA030SDE")
	Local oView := FWFormView():New()
	Local oStruDHU := NF030SDEVW()

	oView:SetModel(oModel)
	oView:AddField('VIEW_CAB', oStruDHU, 'DHUMASTER')
	oView:CreateHorizontalBox('CABEC', 100)
	oView:SetOwnerView('VIEW_CAB', 'CABEC' )
	oView:showInsertMsg(.F.)
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} NF030SDEMD
Campos do modelo
@author renan.martins
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
static function NF030SDEMD()
	Local oStructMn	:= FWFormModelStruct():New()
	Local aSzNum	:= TamSX3("C8_NUM")
	Local aSzEMail	:= TamSX3("C8_FORMAIL")
	Local aSzPayment := TamSX3("C8_COND")
	Local cTitleName := GetSX3Cache('C8_NUM', 'X3_TITULO')
	Local cTitleEmail := GetSX3Cache('C8_FORMAIL', 'X3_TITULO')
	Local cTitleCond := GetSX3Cache('C8_COND', 'X3_TITULO')

	oStructMn:AddField(cTitleName , cTitleName , 'DHU_NUM'  , 'C', aSzNum[1]    , aSzNum[2]    , {|a,b,c,d| VldFields(a,b,c,d)}, {|| .T.}, {}, .T., , .F., .T., .T.) //Cotação
	oStructMn:AddField(cTitleCond , cTitleCond , 'DHU_COND' , 'C', aSzPayment[1], aSzPayment[2], {|a,b,c,d| VldFields(a,b,c,d)}, {|| .T.}, {}, .T., , .F., .T., .T.) //Condição de pagamento
	oStructMn:AddField(cTitleEmail, cTitleEmail, 'DHU_EMAIL', 'C', aSzEMail[1]  , aSzEMail[2]  , {|a,b,c,d| VldFields(a,b,c,d)}, {|| .T.}, {}, .T., , .F., .T., .T.) //E-mail
	FwFreeArray(aSzNum)
	FwFreeArray(aSzEMail)
return oStructMn


//-------------------------------------------------------------------
/*/{Protheus.doc} NF030SDEVW
Campos da View
@author renan.martins
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
static function NF030SDEVW()
	Local oStructMn	:= FWFormViewStruct():New()
	Local cTitleName := GetSX3Cache('C8_NUM', 'X3_TITULO')
	Local cTitleEmail := GetSX3Cache('C8_FORMAIL', 'X3_TITULO')
	Local cTitleCond := GetSX3Cache('C8_COND', 'X3_TITULO')

	oStructMn:AddField('DHU_NUM'  , '01', cTitleName , cTitleName ,, 'C' , PesqPict("SC8","C8_NUM"    ) , , 'DHU' , .T., , , , , , .T., , ) //Cotação
	oStructMn:AddField('DHU_COND' , '02', cTitleCond , cTitleCond ,, 'C' , PesqPict("SC8","C8_COND"   ) , , 'SE4' , .T., , , , , , .T., , ) //Condição de pagamento
	oStructMn:AddField('DHU_EMAIL', '03', cTitleEmail, cTitleEmail,, 'C' , PesqPict("SC8","C8_FORMAIL") , ,       , .T., , , , , , .T., , ) //E-mail
return oStructMn


//-------------------------------------------------------------------
/*/{Protheus.doc} NF030SDGoSend
Função para disparar o e-mail de teste
@author renan.martins
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function NF030SDGoSend(oModel)
    Local cNum := ""
    Local cEmail := ""
    Local cPayment := ""
    Local oUtils := pgc.utils.pgcUtils():New()
    Local oModelDHU := Nil
	Local oJsonWF := JsonObject():New()
	Local oJsonBody := JsonObject():New()
	Local cMessage := ""
	Local oJsonData	:= JsonObject():New()
	Local aSuppliers := {}
	Local lOk := .T.
    Default oModel := FwModelActive()

    oModelDHU := oModel:GetModel("DHUMASTER")

    cNum := oModelDHU:GetValue("DHU_NUM")
    cEmail := AllTrim(oModelDHU:GetValue("DHU_EMAIL"))
    cPayment := AllTrim(oModelDHU:GetValue("DHU_COND"))

	oJsonData := NF030SDProposal(cNum)

	oJsonWF['quotation'] := cNum
	oJsonWF['message'] := ''
	oJsonWF['sendAttachment'] := .F.

	AAdd(aSuppliers, JsonObject():New())
	aSuppliers[1]['supplier'] 		:= oJsonData['c8_fornece']
	aSuppliers[1]['store'] 			:= oJsonData['c8_loja']
	aSuppliers[1]['corporatename'] 	:= Upper(PGCCarEsp(oJsonData['c8_fornome']))
	aSuppliers[1]['email'] 			:= cEmail
	
	oJsonWF['suppliers'] := aSuppliers
	oJsonWF['selectedconditions']  := {cPayment}

	oWorkflow := pgc.workflowRepository.pgcWorkflowRepository():New()

	oUtils:validateRequestBody(oJsonWF:toJson(), @oJsonBody,, !Existblock("NFCWFCUSTOM"))

	oWorkflow:oJsonRequest := oJsonBody
	
	oJsonRetAux := oWorkflow:postWorkflow('000000') //-- Envia processo de workflow

	lOk := oWorkflow:lOk
	cMessage := DecodeUTF8(oJsonRetAux['message'])

	If lOk
		FWAlertSuccess(cMessage, STR0008) //"E-mail de teste enviado."
	Else
		oModel:SetErrorMessage(,,,, 'NF030EMAIL2', cMessage)
	EndIf

	FwFreeArray(aSuppliers)
	FreeObj(oWorkflow)
return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} NF030SDProposal
Obter a ultima proposta válida, de acordo com a cotação inserida pelo usuário
@author renan.martins
@since 06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
function NF030SDProposal(cNumPro)
 	Local cAliasTemp 	:= ""
    Local cQuery 		:= ""
	Local cSC8Fil		:= FWxFilial('SC8')
	Local oJsonRet      := JsonObject():New()
	Local oQuery		:= Nil
    Default cNumPro 	:= ''

	cQuery += " SELECT C8_NUMPRO, C8_NUM, C8_FORNECE, C8_LOJA, C8_FORNOME, C8_COND "
	cQuery += " 	FROM " + RetSQLName("SC8") + " SC8 "
	cQuery += " WHERE "
	cQuery += " 	SC8.C8_FILIAL		= ? " 
	cQuery += " 	AND SC8.C8_NUM 		= ? "
	cQuery += " 	AND SC8.C8_NUMPRO = ( SELECT MAX(C8_NUMPRO) NUMPRO "
	cQuery += " 		FROM " + RetSQLName("SC8") + " SC82 "
	cQuery += " 		WHERE "
	cQuery += " 			SC82.C8_FILIAL	= ? "
	cQuery += " 			AND SC82.C8_NUM	= ? "
	cQuery += " 			AND SC82.D_E_L_E_T_ = ' ') "
	cQuery += " 	AND SC8.D_E_L_E_T_ = ' ' "

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, cSC8Fil)
    oQuery:SetString(2, cNumPro)
    oQuery:SetString(3, cSC8Fil)
    oQuery:SetString(4, cNumPro)

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

	oJsonRet['c8_num'] := ''
	oJsonRet['c8_numpro'] := ''
	oJsonRet['c8_fornece'] := ''
	oJsonRet['c8_loja'] := ''
	oJsonRet['c8_fornome'] := ''

    If !(cAliasTemp)->(Eof())
		oJsonRet['c8_num'] := (cAliasTemp)->C8_NUM
		oJsonRet['c8_numpro'] := (cAliasTemp)->C8_NUMPRO
		oJsonRet['c8_fornece'] := (cAliasTemp)->C8_FORNECE
		oJsonRet['c8_loja'] := (cAliasTemp)->C8_LOJA
		oJsonRet['c8_fornome'] := (cAliasTemp)->C8_FORNOME
    EndIf

    (cAliasTemp)->(dbCloseArea())
    
    oQuery:Destroy()
    FreeObj(oQuery)
Return oJsonRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NF030SDProposal
	Filtro da consulta padrão da DHU (Cotações)
@author juan.felipe
@since 17/06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Function NF030SDFilt()
Return DHU->DHU_STATUS == '1' .Or. DHU->DHU_STATUS == '2'

//-------------------------------------------------------------------
/*/{Protheus.doc} VldFields
	Validação dos campos do cabeçalho da tela
@author juan.felipe
@since 17/06/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldFields(oModelDHU,cField,cValue,cOldValue)
	Local lRet As Logical
	Local cMessage As Character
	Local cSolution As Character
	Local oModel As Object
	Default oModelDHU := FwModelActive():GetModel('DHUMASTER')
	Default cField := ''
	Default cValue := ''
	Default cOldValue := ''

	lRet := .T.
	cMessage := ''
	cSolution := ''
	oModel := oModelDHU:GetModel()

	If !Empty(cValue)
		If cField == 'DHU_NUM'
			DHU->(DbSetOrder(1))
			lRet := DHU->(MsSeek(FWxFilial('DHU') + cValue))
		ElseIf cField == 'DHU_COND'
			lRet := ExistCpo("SE4", cValue) .And. RegistroOk("SE4", .F.)
		ElseIf cField == 'DHU_EMAIL'
			lRet := NFCVldEmail(cValue, @cMessage, @cSolution) //-- Valida e-mails preenchidos
			oModel:SetErrorMessage(,,,, 'NF030EMAIL1', cMessage, cSolution)
		EndIf
	Endif
Return lRet
