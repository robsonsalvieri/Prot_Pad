#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA318.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA318
Leitura de iniciais DTA

@since 20/02/2026
/*/
//-------------------------------------------------------------------
Function JURA318()
Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001) // "Leitura de iniciais DTA"
	oBrowse:SetAlias("O1L")
	oBrowse:Activate()
	oBrowse:Destroy()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo

@since 20/02/2026
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel  := nil
Local oStruct := FWFormStruct(1, "O1L")
Local oStrO1M := FWFormStruct(1, "O1M")

	oStrO1M:RemoveField("O1M_CFGDTA")

	oModel := MPFormModel():New("JURA318", /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields("O1LMASTER", /*cOwner*/, oStruct, /*bPre*/, /*bPos*/, /*bLoad*/)
	oModel:SetDescription(STR0001)  // "Leitura de iniciais DTA"
	oModel:GetModel("O1LMASTER"):SetDescription(STR0001)  // "Leitura de iniciais DTA"

	oModel:AddGrid("O1MDETAIL", "O1LMASTER" /*cOwner*/, oStrO1M, /*bLinePre*/, /*bLinePos*/, /*bPre*/, /*bPost*/)
	oModel:SetDescription(STR0004) //"Config leitura de iniciais DTA"

	oModel:GetModel("O1MDETAIL"):SetDescription(STR0004) //"Config leitura de iniciais DTA"
	oModel:GetModel("O1MDETAIL"):SetUniqueLine({"O1M_CODIGO"})
	oModel:SetOptional("O1MDETAIL", .T.)
	oModel:SetRelation("O1MDETAIL", {{"O1M_FILIAL", "O1L_FILIAL"}, {"O1M_CFGDTA", "O1L_CODIGO"}}, O1M->(IndexKey(1)))

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados da leitura de iniciais DTA

@since 20/02/2026
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView := nil
Local oModel := FWLoadModel("JURA318")
Local oStruct := FWFormStruct(1, "O1L")
Local oStrO1M := FWFormStruct(1, "O1M")

	oStrO1M:RemoveField("O1M_CFGDTA")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:SetDescription(STR0001) // "Leitura de iniciais DTA"
	oView:AddField("JURA318_MASTER", oStruct, "O1LMASTER")
	oView:AddGrid("JURA318_DETAIL", oStrO1M, "O1MDETAIL")

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} J318OptO1L
Retorna as opções para o campo O1L_PRCONT

@since 20/02/2026
/*/
//------------------------------------------------------------------------------
Function J318OptO1L()
Local nCont  :=0
Local aLstPesq:={}
Local cLstPesq:=""

	aAdd(aLstPesq,STR0002) //"1=Sim"
	aAdd(aLstPesq,STR0003) //"2=Não"

	For nCont:=1 To Len(aLstPesq)
		cLstPesq+=aLstPesq[nCont]+";"
	Next
	cLstPesq:=Substr(cLstPesq,1,Len(cLstPesq)-1)

Return cLstPesq
