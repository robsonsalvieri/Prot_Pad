//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#include "OFIA512.CH"

Static oModel01

Static cAliasTmp
Static oTempTable


/*/{Protheus.doc} OFIA512
	Rotina de Criacao de Contas do RPM, para configuracao do COMBO

	@author Bruno Forcato
	@since 24/09/2025
/*/
Function OFIA512()
	Local aArea			:= FWGetArea()
	Local oBrowse
	Local aColunas		:= {}
	Local aPesquisa		:= {}
	Private aRotina		:= {}

	//Definicao Inicial
	aRotina := MenuDef()

	OA5120165_CriaTabelaTemporaria()

	aAdd(aColunas, {STR0001,    "TMP_COD", "C", 20, 0, "@!"}) //"Titulo da Conta"
	aAdd(aPesquisa, {STR0001, {{"", "C", 20, 0, STR0001, "@!", "TMP_COD"}} } ) //"Titulo da Conta"
	OA5120012_LevantaDados()

	//Criando o browse da temporÃ¡ria
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
	// ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.OFIA512" OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.OFIA512" OPERATION 5 ACCESS 0 //Excluir
	ADD OPTION aRotina TITLE STR0012 ACTION "OA5120062_AbrirConfiguracoes()" OPERATION 3 ACCESS 0 //Configurações
	ADD OPTION aRotina TITLE STR0014 ACTION "OA5120072_AbrirConfigOkta()" OPERATION 3 ACCESS 0 //AbrirConfigOkta
	ADD OPTION aRotina TITLE STR0015 ACTION "OA5120082_AbrirConfigDTF()" OPERATION 3 ACCESS 0 //Abrir Configurações DTF
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

	if cAliasTMP == NIL
		OA5120165_CriaTabelaTemporaria()
	endif

	oStr1 := oModel01:GetModel()

	oStr1:AddTable(cAliasTmp, {'TMP_COD'}, STR0007) //Temporaria
	oModel := MPFormModel():New("OFIA512M",,,{|oModel| OA5120042_Commit(oModel) }) 
	oModel:AddFields("FORMTMP",,oStr1)
	oModel:SetPrimaryKey({'TMP_COD'})
	oModel:SetDescription(STR0008) //Modelo de Dados do Cadastro Contas do RPM
	oModel:GetModel("FORMTMP"):SetDescription(STR0009) //FormulÃ¡rio do Cadastro Contas do RPM
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

/*/{Protheus.doc} OA5120052_Excluir
	Exclui uma conta em conjunto
	com as configurações da conta no OFIA503

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

	//deleta a configuracao da conta em questão
	VRN->(dbSetOrder(1))
	lExistCfg := VRN->(dbSeek(xFilial("VRN") + "OFIA503_C"))
	if !lExistCfg
		return .t.
	endif

	oOFIA512Config:FromJson(VRN->VRN_CONFIG)
	if !oOFIA512Config:hasProperty("CONFIGURACOES")
		return .t.
	endif

	lDel := .f.
	for nIndex := 1 to Len(oOFIA512Config["CONFIGURACOES"])
		oConfig := oOFIA512Config["CONFIGURACOES"][nIndex]
		if alltrim(oConfig["ID"]) == alltrim(cConta)
			aDel(oOFIA512Config["CONFIGURACOES"], nIndex)
			lDel := .t.
			exit
		endif
	next

	if lDel
		aSize(oOFIA512Config["CONFIGURACOES"], LEN(oOFIA512Config["CONFIGURACOES"])-1)
		RecLock("VRN", .F.)
		VRN->VRN_CONFIG := oOFIA512Config:ToJson()
		VRN->(msUnlock())
	endif
Return 

/*/{Protheus.doc} OA5120042_Commit
	Funcao de commit da funcao OFIA512
	Feita pra direcionar corretamente o fluxo de cadastro/alteraÃ§Ã£o

	@author Bruno Forcato
	@since 24/09/2025
/*/
Function OA5120042_Commit(oModel)
	local lExistCfg		:= .T.
	local nIndex		:= 0
	local oJson			:= JsonObject():New()
	Local oModelForm	:= oModel:GetModel('FORMTMP')
	local cNovaConta	:= oModelForm:GetValue("TMP_COD")
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

	if nOpc == 3
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
		{'nTamanho' , 20 },;
		{'lObrigat' , .T. },;
		{'cTooltip' , STR0001 } ; //"Titulo da Conta"
	})
return oMd1

/*/{Protheus.doc} OA5120062_AbrirConfiguracoes
	Função para abrir a rotina OFIA503
	Para cadastro de novas contas

	@author Bruno Forcato
	@since 25/09/2025
/*/
Function OA5120062_AbrirConfiguracoes()
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)

	if lNovoCombo
		OFIA503((cAliasTmp)->TMP_COD)
	else
		FMX_HELP("OFIA512", STR0013) //Para utilizar essa opção, ative o parâmetro do novo combo (MV_MIL0210)
	endif
return

/*/{Protheus.doc} OA5120072_AbrirConfigOkta
	Função para abrir a rotina OFIA280
	Para cadastro de novas contas

	@author Bruno Forcato
	@since 09/10/2025
/*/
Function OA5120072_AbrirConfigOkta()
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)

	if lNovoCombo
		OFIA280((cAliasTmp)->TMP_COD)
	else
		FMX_HELP("OFIA512", STR0013) //"Para utilizar essa opção, ative o parâmetro do novo RPM Latam (MV_MIL0210)"
	endif
return

/*/{Protheus.doc} OA5120082_AbrirConfigDTF
	Função para abrir a rotina OFIA410
	Para cadastro de novas contas

	@author Bruno Forcato
	@since 09/10/2025
/*/
Function OA5120082_AbrirConfigDTF()
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)

	if lNovoCombo
		OFIA410((cAliasTmp)->TMP_COD)
	else
		FMX_HELP("OFIA512", STR0013) //"Para utilizar essa opção, ative o parâmetro do novo RPM Latam (MV_MIL0210)"
	endif
return

/*/{Protheus.doc} OA5120074_BuscaContasRPM
    Busca as contas para preencher o combo
   
    @type function
    @author Vinicius Gati
    @since 15/10/2025
/*/
function OA5120074_BuscaContasRPM()
	local oJson := JsonObject():New()
	dbSelectArea("VRN")
	VRN->(dbSetOrder(1))
	lExistCfg := VRN->(dbSeek(xFilial("VRN") + "OFIA512"))
	if lExistCfg
		if empty(oJson:FromJson(VRN->VRN_CONFIG))
			return oJson["CONTAS"]
		endif
	endif
return {"OLD                 "}
 
/*/{Protheus.doc} OA5120104_BuscaContaFilSeg
    Busca a conta passando a filial e o segmento
   
    @type function
    @author Vinicius Gati
    @since 24/11/2025
/*/
function OA5120104_BuscaContaFilSeg(cFill, cSegmento)
    local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
    local aContas := OA5120074_BuscaContasRPM()
    local nIdx := 1
 
    if !lNovoCombo
        return ""
    endif
 
	// busca o dealer code com base no segmento e filial
	if Len(aContas) > 0
		for nIdx := 1 to Len(aContas)
			oJdConfig := OFJDConfig():New( , aContas[nIdx] )
			cDealerCode := oJdConfig:GetDealerCode(cFill, cSegmento)
			if ! Empty(cDealerCode)
				return aContas[nIdx]
			endif
		next
	endif
return ""

/*/{Protheus.doc} OA5120114_SegmtoFromDAccount
    Retorna o segmento de determinado dealer code, procurando em todas as contas claro
   
    @type function
    @author Vinicius Gati
    @since 09/12/2025
/*/
function OA5120114_SegmtoFromDAccount(cDealerAcc)
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	local nX := 1

	if lNovoCombo
		aContas := OA5120074_BuscaContasRPM()
		for nX := 1 to len(aContas)
			oJdConfig := OFJDConfig():New( , aContas[nX] )
			cSegm := oJdConfig:GetSegmentoByJdCode(cDealerAcc)
			if ! Empty(cSegm) .and. OFIOA560VL("097", alltrim(cSegm))
				return cSegm
			endif
		next
	else
		oJdConfig := OFJDConfig():New()
		return oJdConfig:GetSegmentoByJdCode(cDealerAcc)
	endif
return ""

/*/{Protheus.doc} OA5120124_ContaFromDAccount
    Retorna a conta de determinado dealer code, procurando em todas as contas claro
   
    @type function
    @author Vinicius Gati
    @since 09/12/2025
/*/
function OA5120124_ContaFromDAccount(cDealerAcc)
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	local aFilis, aContas
	local nX := 1
	local nY := 1

	if lNovoCombo
		aContas := OA5120074_BuscaContasRPM()
		for nX := 1 to len(aContas)
			oJdConfig := OFJDConfig():New( , aContas[nX] )
			aFilis := oJdConfig:GetFiliais()

			for nY := 1 to len(aFilis)
				if alltrim(aFilis[nY]["DEALER_CODE"]) == alltrim(cDealerAcc)
					return aContas[nX]
				endif
			next
		next
	endif
return ""

/*/{Protheus.doc} OA5120134_UnicoSeg
    SE a filial tem somente um segmento independente das contas posso forçar um segmento quando necessário
   
    @type function
    @author Vinicius Gati
    @since 24/04/2026
/*/
function OA5120134_UnicoSeg(cFil)
	local nX := 1
	local nY := 1
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	local aFound := {}

	if lNovoCombo
		aContas := OA5120074_BuscaContasRPM()
		for nX := 1 to len(aContas)
			oJdConfig := OFJDConfig():New( , aContas[nX] )
			aFilis := oJdConfig:GetFiliais()

			for nY := 1 to len(aFilis)
				if alltrim(aFilis[nY]["FILIAL"]) == alltrim(cFil)
					aadd(aFound, aFilis[nY])
				endif
			next
		next
	endif

	if len(aFound) == 1
		return .T.
	endif
return .F.


/*/{Protheus.doc} OA5120144_ValUnicoSeg
    Valor do segmento unico
   
    @type function
    @author Vinicius Gati
    @since 24/04/2026
/*/
function OA5120144_ValUnicoSeg(cFil)
	local nX := 1
	local nY := 1
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	local aFound := {}

	if lNovoCombo
		aContas := OA5120074_BuscaContasRPM()
		for nX := 1 to len(aContas)
			oJdConfig := OFJDConfig():New( , aContas[nX] )
			aFilis := oJdConfig:GetFiliais()

			for nY := 1 to len(aFilis)
				if alltrim(aFilis[nY]["FILIAL"]) == alltrim(cFil)
					aadd(aFound, aFilis[nY])
				endif
			next
		next
	endif

	if len(aFound) == 1
		return aFound[1]["SEGMENTO"]
	endif
return "-"

/*/{Protheus.doc} OA5120154_UnicoAccount
    Valor do account unico
   
    @type function
    @author Vinicius Gati
    @since 11/05/2026
/*/
function OA5120154_UnicoAccount(cFil)
	local nX := 1
	local nY := 1
	local lNovoCombo := GetNewPar("MV_MIL0210", .F.)
	local aFound := {}

	if lNovoCombo
		aContas := OA5120074_BuscaContasRPM()
		for nX := 1 to len(aContas)
			oJdConfig := OFJDConfig():New( , aContas[nX] )
			aFilis := oJdConfig:GetFiliais()

			for nY := 1 to len(aFilis)
				if alltrim(aFilis[nY]["FILIAL"]) == alltrim(cFil)
					aadd(aFound, aContas[nX])
				endif
			next
		next
	endif

	if len(aFound) == 1
		return aFound[1]
	endif
return "-"


static function OA5120165_CriaTabelaTemporaria()
	Local aCampos		:= {}

	oTempTable  := FWTemporaryTable():New()

	aAdd(aCampos, {"TMP_COD", "C", 20, 0})

	oTempTable:SetFields(aCampos)
	oTempTable:AddIndex("1", {"TMP_COD"} )
	oTempTable:Create()
	cAliasTmp := oTempTable:getAlias()
return