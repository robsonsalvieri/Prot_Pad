#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA413B.CH"

#DEFINE WMSA413B01 "WMSA413B01"

//--------------------------------------------------
/*/{Protheus.doc} WMSA413B
Programa que contém a regra de estorno / exclusão do item conferido pelo operador (D16).
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Function WMSA413B()
Return Nil

Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0001 ACTION "WMS413BEst()" OPERATION 4 ACCESS 0 // Estornar Item Conferência
Return aRotina

Static Function ModelDef()
Local oModel     := MPFormModel():New('WMSA413B',,,{|oModel| CommitMdl(oModel) })
Local oStructD16 := FWFormStruct(1,'D16')
	oStructD16:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	
	oModel:AddFields('A413D16',,oStructD16)
	oModel:SetPrimaryKey({"D16_FILIAL","D16_EMBARQ","D16_CODOPE","D16_CARGA","D16_PEDIDO","D16_ITEM","D16_SEQUEN","D16_PRDORI","D16_PRODUT","D16_CODVOL"})

	oModel:SetActivate({|oModel| SetActive(oModel) })
Return oModel

Static Function ViewDef()
Local oModel := ModelDef()
Local oView  := FWFormView():New()
Local oStructD16  := FWFormStruct(2,'D16')
	oStructD16:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_D16', oStructD16, 'A413D16')
	
	oView:CreateHorizontalBox( 'BOXD16', 100)
	
	oView:EnableTitleView('VIEW_D16', STR0002) // Itens Embarque
	
	oView:SetOwnerView('VIEW_D16','BOXD16')
Return oView
//--------------------------------------------------
/*/{Protheus.doc} SetActive
Realiza alguma alteração no modelo para possibilitar a confirmação da alteração
@author  amanda.vieira
@since   18/06/2020
@version 1.0
@param 	 oModel, objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function SetActive(oModel)
	oModel:GetModel("A413D16"):SetValue("D16_CODOPE", oModel:GetModel("A413D16"):GetValue("D16_CODOPE"))
Return .T.
//--------------------------------------------------
/*/{Protheus.doc} EstItem
Inicia processo de estorno do item
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Function WMS413BEst()
Return (FWExecView(STR0001,'WMSA413B',4,,{ || .T. },,,,{ || .T. }) == 0) // Estornar Item Conferência
//--------------------------------------------------
/*/{Protheus.doc} CommitMdl
Realiza commit do modelo de dados
@author  amanda.vieira
@since   18/06/2020
@version 1.0
@param 	 oModel, objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function CommitMdl(oModel)
Return FWFormCommit(oModel,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/,{|oModel| InTTS(oModel)},/*bABeforeTTS*/,/*bIntegEAI*/)
//--------------------------------------------------
/*/{Protheus.doc} InTTS
Bloco de código chamado dentro da transação do commit
@author  amanda.vieira
@since   18/06/2020
@version 1.0
@param 	 oModel, objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function InTTS(oModel)
Local oEstEmbOp := Nil
Local lRet      := .T.
	oEstEmbOp := WMSDTCEmbarqueExpedicaoEmbarqueOperador():New()
	oEstEmbOp:GoToD16(D16->(Recno()))
	If !(lRet := oEstEmbOp:EstEmbOpe())
		oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSA413B01,oEstEmbOp:GetErro())
	EndIf
	If lRet .And. oModel:GetOperation() == 4
		WmsUpdD00(3,oEstEmbOp:oEmbExpIt:oEmbExp:cEmbarque)
	EndIf
	FreeObj(oEstEmbOp)

Return lRet
