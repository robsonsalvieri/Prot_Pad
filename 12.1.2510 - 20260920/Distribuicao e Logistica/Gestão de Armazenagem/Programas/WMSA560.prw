#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA560.CH"

//-------------------------------------
/*/{Protheus.doc} WMSA560
Bloqueio de Saldo WMS (Visualizar)
@author felipe.m
@since 25/07/2017
@version 1.0
/*/
//-------------------------------------
Function WMSA560()
Local oBrw := Nil

	// Permite efetuar validações, apresentar mensagem e abortar o programa quando desejado
	If !WMSChkPrg(FunName(),"1")
		Return Nil
	EndIf

	 //Validação para verificar tamanho do campo Entre as Tabelas D0U E SDD 
	IF !TamSx3("D0U_DOCTO")[1] == TamSx3("DD_DOC")[1]
		FwAlertError(STR0007) //"Os campos D0U_DOCTO e DD_DOC esta com tamanho diferente em seu dicionario de dados, por favor, equalizar o tamanho dos campos."
		Return Nil
	EndIf
	
	oBrw := FWMBrowse():New()
	oBrw:SetAlias("D0U")
	oBrw:SetDescription(STR0001) // "Bloqueio de Saldo WMS"
	oBrw:SetMenuDef("WMSA560")
	FiltroD0U(oBrw)
	oBrw:SetParam({|| FiltroD0U(oBrw) })
	
	oBrw:Activate()
Return
 
//----------------------------------------------------------
Static Function FiltroD0U(oBrw)
//----------------------------------------------------------
Local cFiltro := ""

	If ExistBlock('DL560FIL')
        cFiltro := ExecBlock('DL560FIL', .F., .F.)
		If ValType(cFiltro) == 'C'
            oBrw:SetFilterDefault("@ "+cFiltro)
		EndIf
	EndIf
	 
Return

//-------------------------------------
Static Function MenuDef()
//-------------------------------------
Private aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"       OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003 ACTION "WMSA560MEN(2)" OPERATION 1 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004 ACTION "WMSA560MEN(3)" OPERATION 3 ACCESS 0 // "Bloquear"
	ADD OPTION aRotina TITLE STR0005 ACTION "WMSA560MEN(4)" OPERATION 4 ACCESS 0 // "Liberar"
Return aRotina
//-------------------------------------------------------
Function WMSA560MEN(nPos)
//-------------------------------------------------------
Local aRotina := MenuDef()
Local lRet    := .T.
Local nOperation := aRotina[nPos][4]
Local cModel  := "WMSA560"

	If nOperation == MODEL_OPERATION_VIEW
		cModel := "WMSA560"
	ElseIf nOperation == MODEL_OPERATION_INSERT
		lRet := Pergunte("WMSA560",.T.)
		cModel := "WMSA560A"
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		cModel := "WMSA560B"
	EndIf

	If lRet
		FWExecView(aRotina[nPos][1],cModel,nOperation,,{ || .T. },{ || .T. },0,,{ || .T. },,, )
	EndIf
Return Nil
//-------------------------------------------------------
Static Function ModelDef()
//-------------------------------------------------------
Local oModel  := Nil
Local oStrD0U := FWFormStruct(1,"D0U")
Local oStrD0V := FWFormStruct(1,"D0V")

	oModel := MPFormModel():New("WMSA560")
	// Modelo D0U
	oModel:AddFields("D0U_MODEL",,oStrD0U)
	oModel:GetModel("D0U_MODEL"):SetDescription(STR0001) // "Bloqueio de Saldo WMS"
	// Modelo D0V
	oModel:AddGrid("D0V_MODEL","D0U_MODEL",oStrD0V)
	oModel:GetModel("D0V_MODEL"):SetDescription(STR0006) // "Itens Bloqueio de Saldo WMS"
	oModel:SetRelation("D0V_MODEL", {{"D0V_FILIAL","xFilial('D0V')"},{"D0V_IDBLOQ","D0U_IDBLOQ"}},)
Return oModel
//-------------------------------------------------------
Static Function ViewDef()
//-------------------------------------------------------
Local oModel  := ModelDef()
Local oView   := Nil
Local oStrD0U := FWFormStruct(2,"D0U")
Local oStrD0V := FWFormStruct(2,"D0V")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox("D0U_DADOS",16)
	oView:CreateHorizontalBox("D0V_DADOS",84)

	oView:AddField("D0U_VIEW",oStrD0U,"D0U_MODEL")
	oView:SetOwnerView("D0U_VIEW","D0U_DADOS")

	oView:AddGrid("D0V_VIEW",oStrD0V,"D0V_MODEL")
	oView:EnableTitleView("D0V_VIEW", STR0006) // "Itens Bloqueio de Saldo WMS"
	oView:SetOwnerView("D0V_VIEW","D0V_DADOS")
Return oView
