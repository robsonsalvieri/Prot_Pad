//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#include "OFIA512.CH"

Static oModel01

/*/{Protheus.doc} OFIA512
	Rotina de Criacao de Contas do RPM, para configuracao do COMBO

	@author Bruno Forcato
	@since 24/09/2025
/*/
Function OFIA512()
	Local aArea			:= FWGetArea()
	Local oBrowse
	Local aCampos		:= {}
	Local aColunas		:= {}
	Local aPesquisa		:= {}
	Private aRotina		:= {}
	Private cAliasTmp	:= GetNextAlias()

	//Definicação Inicial
	aRotina := MenuDef()
	aAdd(aCampos, {"TMP_COD", "C", 30, 0})

	//Criando a tabela temporária
	oTempTable := FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields(aCampos)
	oTempTable:AddIndex("1", {"TMP_COD"} )
	oTempTable:Create()

	aAdd(aColunas, {STR0001,    "TMP_COD", "C", 30, 0, "@!"}) //"Titulo da Conta"
	aAdd(aPesquisa, {STR0001, {{"", "C", 30, 0, STR0001, "@!", "TMP_COD"}} } ) //"Titulo da Conta"
	OA5120012_LevantaDados()

	//Criando o browse da temporária
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasTmp)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetFields(aColunas)
	oBrowse:DisableDetails()
	oBrowse:SetDescription(STR0002) //Cadastro de Contas do RPM
	oBrowse:SetSeek(.T., aPesquisa)
	oBrowse:Activate()

	oTempTable:Delete()
	FWRestArea(aArea)
Return Nil
  
/*/{Protheus.doc} MenuDef
	Menu de opcoes na funcao OFIA512

	@author Bruno Forcato
	@since 24/09/2025
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.OFIA512" OPERATION 1 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.OFIA512" OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.OFIA512" OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.OFIA512" OPERATION 5 ACCESS 0 //Excluir
Return aRotina
  
/*/{Protheus.doc} ModelDef
	Modelo de dados na funcao OFIA512

	@author Bruno Forcato
	@since 24/09/2025
/*/
Static Function ModelDef()
	Local oModel := Nil
	Local oStr1

	If oModel01 == NIL
		oModel01 := GetModel01()
	endif
	oStr1 := oModel01:GetModel()

	oStr1:AddTable(cAliasTmp, {'TMP_COD'}, STR0007) //Temporaria
	oModel := MPFormModel():New("OFIA512M",,,{|oModel| OA5120042_Commit(oModel) }) 
	oModel:AddFields("FORMTMP",,oStr1)
	oModel:SetPrimaryKey({'TMP_COD'})
	oModel:SetDescription(STR0008) //Modelo de Dados do Cadastro Contas do RPM
	oModel:GetModel("FORMTMP"):SetDescription(STR0009) //Formulário do Cadastro Contas do RPM
Return oModel
  
/*/{Protheus.doc} ViewDef
	Visualizacao de dados na funcao OFIA512

	@author Bruno Forcato
	@since 24/09/2025
/*/
Static Function ViewDef()
	Local oModel	:= FWLoadModel("OFIA512")
	Local oView		:= Nil
	Local oStr1		:= oModel01:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_TMP", oStr1, "FORMTMP")
	oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView('VIEW_TMP', STR0010 ) //Dados - Contas do RPM
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_TMP","TELA")
Return oView

/*/{Protheus.doc} OA5120012_LevantaDados
	Levanta os dados da tabela temporaria da VRN

	@author Bruno Forcato
	@since 24/09/2025
/*/
Static Function OA5120012_LevantaDados()
	local lExistCfg	:= .f.
	local oJson		:= JsonObject():New()
	local nIndex	:= 0

	dbSelectArea("VRN")
	VRN->(dbSetOrder(1))
	lExistCfg := VRN->(dbSeek(xFilial("VRN") + "OFIA512"))
	if lExistCfg
		oJson:FromJson(VRN->VRN_CONFIG)

		for nIndex := 1 to Len(oJson["CONTAS"])
			RecLock(cAliasTmp, .T.)
			(cAliasTmp)->TMP_COD := oJson["CONTAS"][nIndex]
			(cAliasTmp)->(MsUnlock())
		next
	endif
return

/*/{Protheus.doc} OA5120022_Cadastrar
	Incluir novas contas do RPM no array da VRN

	@author Bruno Forcato
	@since 24/09/2025
/*/
Function OA5120022_Cadastrar(cNovaConta, aContas, lExistCfg)
	local oJson := JsonObject():New()

	if lExistCfg
		oJson["CONTAS"] := aContas
		aadd(aContas, cNovaConta)

		RecLock("VRN", .f.)
		VRN->VRN_CONFIG := oJson:ToJson()
		msUnlock()
	else
		oJson["CONTAS"] := {}
		aadd(oJson["CONTAS"], cNovaConta)

		RecLock("VRN", .t.)
		VRN->VRN_FILIAL := xFilial("VRN")
		VRN->VRN_CODIGO := "OFIA512"
		VRN->VRN_CONFIG := oJson:ToJson()
		msUnlock()
	endif
Return 

/*/{Protheus.doc} OA5120032_Alterar
	Altera Conta do RPM no array da VRN

	@author Bruno Forcato
	@since 24/09/2025
/*/
Function OA5120032_Alterar(cNovaConta, cAntigaConta, aContas, lExistCfg)
	local oJson  := JsonObject():New()
	local nIndex := 0

	for nIndex := 1 to Len(aContas)
		if alltrim(aContas[nIndex]) == alltrim(cAntigaConta)
			aContas[nIndex] := cNovaConta
		endif
	next

	oJson["CONTAS"] := aContas
	RecLock("VRN", .F.)
	VRN->VRN_CONFIG := oJson:ToJson()
	VRN->(msUnlock())
Return 

/*/{Protheus.doc} OA5120052_Excluir
	Exclui uma conta em conjunto
	com as configura��es da conta no OFIA503

	@author Bruno Forcato
	@since 30/09/2025
/*/
Function OA5120052_Excluir(cConta, aContas)
	local oJson  := JsonObject():New()
	local nIndex := 0
	local lExistCfg := .f.
	local oOFIA512Config := JsonObject():New()
	local oConfig := JsonObject():New()

	for nIndex := 1 to Len(aContas)
		if alltrim(aContas[nIndex]) == alltrim(cConta)
			CONOUT(aContas[nIndex])
			aDel(aContas, nIndex)
		endif
	next

	aSize(aContas, LEN(aContas)-1)
	oJson["CONTAS"] := aContas
	RecLock("VRN", .F.)
	VRN->VRN_CONFIG := oJson:ToJson()
	VRN->(msUnlock())

	//deleta a configuracao da conta em quest�o
	VRN->(dbSetOrder(1))
	lExistCfg := VRN->(dbSeek(xFilial("VRN") + "OFIA503"))
	if !lExistCfg
		return .t.
	endif

	oOFIA512Config:FromJson(VRN->VRN_CONFIG)
	if !oOFIA512Config:hasProperty("CONFIGURACOES")
		return .t.
	endif

	for nIndex := 1 to Len(oOFIA512Config["CONFIGURACOES"])
		oConfig := oOFIA512Config["CONFIGURACOES"][nIndex]
		if alltrim(oConfig["ID"]) == alltrim(cConta)
			aDel(oOFIA512Config["CONFIGURACOES"], nIndex)
			exit
		endif
	next

	aSize(oOFIA512Config["CONFIGURACOES"], LEN(oOFIA512Config["CONFIGURACOES"])-1)
	RecLock("VRN", .F.)
	VRN->VRN_CONFIG := oOFIA512Config:ToJson()
	VRN->(msUnlock())
Return 

/*/{Protheus.doc} OA5120032_Alterar
	Funcao de commit da funcao OFIA512
	Feita pra direcionar corretamente o fluxo de cadastro/alteração

	@author Bruno Forcato
	@since 24/09/2025
/*/
Function OA5120042_Commit(oModel)
	local lExistCfg		:= .T.
	local nIndex		:= 0
	local oJson			:= JsonObject():New()
	Local oModelForm	:= oModel:GetModel('FORMTMP')
	local cNovaConta	:= oModelForm:GetValue("TMP_COD")
	local cAntigaConta	:= (cAliasTmp)->TMP_COD
	local nOpc			:= oModel:GetOperation()

	VRN->(dbSetOrder(1))
	lExistCfg := VRN->(dbSeek(xFilial("VRN") + "OFIA512"))

	if !lExistCfg
		OA5120022_Cadastrar(cNovaConta, {}, lExistCfg)   
		oTempTable:Zap()
		OA5120012_LevantaDados()
		return .T.
	endif

	oJson:FromJson(VRN->VRN_CONFIG)
	aContas := oJson["CONTAS"]
	for nIndex := 1 to Len(aContas)
		if aContas[nIndex] == oModelForm:GetValue("TMP_COD") .and. nOpc != 5
			FMX_HELP("OFIA512", STR0011) //Conta ja cadastrada!
			return .F.
		endif
	next

	if nOpc == 4 .and. cNovaConta != cAntigaConta
		OA5120032_Alterar(cNovaConta, cAntigaConta, aContas, lExistCfg)
	elseif nOpc == 3
		OA5120022_Cadastrar(cNovaConta, aContas, lExistCfg)
	elseif nOpc == 5
		OA5120052_Excluir(cNovaConta, aContas)
	endif

	oTempTable:Zap()
	OA5120012_LevantaDados()
return .T.

/*/{Protheus.doc} GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author Bruno Forcato
	@since 24/09/2025
/*/
Static Function GetModel01()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'  , STR0001 },; //"Titulo da Conta"
		{'cIdField' , "TMP_COD" },;
		{'nTamanho' , 30 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0001 } ; //"Titulo da Conta"
	})
return oMd1