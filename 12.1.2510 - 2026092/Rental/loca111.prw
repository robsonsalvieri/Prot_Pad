#INCLUDE "loca111.ch" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} LOCA111
Rotina para registro pré PO
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 03/07/2026
/*/
Function LOCA111()
Local oBrowse

Private aRotina := {}
Private cCadastro := STR0001 //"Pré Cadastro de PO"
Private cString := "FH7"

	dbSelectArea(cString) 
	dbSetOrder(1) 

	aRotina := MenuDef()  
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FH7')
	oBrowse:SetDescription(STR0001) //"Pré Cadastro de PO"

	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
Declaração do menu
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 03/07/2026
/*/
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.LOCA111' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.LOCA111' OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.LOCA111' OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.LOCA111' OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Declaração do modelo do MVC
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 03/07/2026
/*/
Static Function ModelDef()
Local oModel	:= nil
Local oStruFPG 	:= FWFormStruct( 1, "FH7" )
Local bTudoOk  := {|| .T.}
Local bCommit  := {|oModel| LOC111GRV(oModel)}

	oModel := MPFormModel():New("LOCA111", , , bCommit, )
	oModel:AddFields( "FH7MASTER", /*cOwner*/, oStruFPG)
	oModel:SetDescription( STR0001 ) //"Pré Cadastro de PO"
	oModel:GetModel( "FH7MASTER"):SetDescription( STR0001) //"Pré Cadastro de PO"

Return oModel

/*/{Protheus.doc} ViewDef
Declaração da visualização do modelo MVC
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 03/07/2026
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel   	:= FWLoadModel("LOCA111")
Local oStruZZ7 	:= FWFormStruct( 2, "FH7" )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "VIEW_FH7", oStruZZ7, "FH7MASTER" )
	oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView("VIEW_FH7", STR0001) //"Pré Cadastro de PO"

	oView:SetOwnerView("VIEW_FH7","TELA")

	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} LOC111GRV
Gravação do formulário
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 03/07/2026
/*/
Static Function LOC111GRV(oModel)
Local nOperacao	:= oModel:GetOperation()
Local oMaster   := oModel:GetModel('FH7MASTER')
Local lOk		:= .T.
Local cID

	If nOperacao = MODEL_OPERATION_INSERT
 	   If empty(oMaster:GetValue("FH7_IDPO"))
		    cID := GetSx8Num("FH7","FH7_IDPO")
		    ConfirmSx8()
		    oMaster:LoadValue("FH7_IDPO", cID)
 	   EndIf
	endif

	//Gravação do Modelo de Dados.
	FWFormCommit( oModel )

Return lOk


/*/{Protheus.doc} LOC11102
Validação do campo FH7_IDPO  
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 03/07/2026
/*/

Function LOC11102
Local lRet := .T.
Local aArea := GetArea()
Local cId := &(ReadVar())

	FH7->(dbSetOrder(2))
	If FH7->(dbSeek(xFilial("FH7")+cId))
		Help( ,, "LOCA111-LOC11102",, STR0006, 1, 0,,,,,,{STR0007}) //"Inconsistência nos dados."###"Código já existente."
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet


/*/{Protheus.doc} LOC11103
Validação do campo FPA_IDPO  
@type function
@version 1.0
@author Frank Zwarg Fuga
@since 03/07/2026
/*/

Function LOC11103
Local lRet := .T.
Local aArea := GetArea()
Local cId := &(ReadVar())

	FH7->(dbSetOrder(1))
	If FH7->(dbSeek(xFilial("FH7")+cId))
		If FH7->FH7_CODCLI <> FP0->FP0_CLI .or. FH7->FH7_LOJA <> FP0->FP0_LOJA
			Help( ,, "LOCA111-LOC11103",, STR0006, 1, 0,,,,,,{STR0008}) //"Inconsistência nos dados."###"Cliente inválido x registro do PO."
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)
Return lRet
