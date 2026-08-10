#include "TBICONN.CH"
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "OFIA530.CH"

Static oModelPV
Static cMVMIL0006  := GetNewPar("MV_MIL0006","")

/*/{Protheus.doc} OFIA530
	Tela para configuração dos Pontos de Venda ARGENTINA

	@author Andre Luis Almeida
	@since  16/05/2025
/*/
Function OFIA530()
	Private oConfig := OFIA530Config():New()
	Private aConFil := {}
	Private nPosFil := 0
	If cPaisLoc == "ARG"
		FWExecView(STR0001, "OFIA530", MODEL_OPERATION_UPDATE) // Pontos de Venda - ARGENTINA
	Else
		FMX_HELP("OFIA530", STR0002 ) // Opção disponivel apenas para Argentina
	EndIf
Return .t.

/*/{Protheus.doc} ViewDef
	Definicao da view
	
	@author Andre Luis Almeida
	@since  16/05/2025
/*/
Static Function ViewDef()
	Local oModel  := Modeldef()
	Local oStrPV  := oModelPV:GetView()
	oStrPV:AddFolder("PEC",STR0003) // Peças
	oStrPV:AddFolder("OFI",STR0004) // Oficina
	oStrPV:AddFolder("VEI",STR0005) // Veículos/Máquinas
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( 'TELA' , oStrPV , 'TELA' )
	oView:CreateHorizontalBox( 'BOX_TELA', 100)
	oView:EnableTitleView('TELA', STR0006+": "+cFilAnt+" - "+FWFilialName() ) // Filial
	oView:SetCloseOnOk({||.T.})
Return oView

/*/{Protheus.doc} ModelDef
	Definicao do modelo
	
	@author Andre Luis Almeida
	@since  16/05/2025/*/
Static Function ModelDef()
	Local oModel
	Local oStrPV
	If oModelPV == NIL
		oArrHelper := DMS_ArrayHelper():New()
		oModelPV   := OA5300021_GetModel()
	EndIf
	oStrPV := oModelPV:GetModel()
	oModel := MPFormModel():New('OFIA530',,,{ |oModel| OA5300041_Confirmar(oModel) })
	oModel:SetDescription(STR0007) // Configurar
	oModel:AddFields("TELA",,oStrPV,,,{|| OA5300031_Load() })
	oModel:GetModel("TELA"):SetDescription(STR0001) // Pontos de Venda - ARGENTINA
	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} OA5300011_Validacao_PV
	Validação da digitação do Ponto de Venda

	@author Andre Luis Almeida
	@since 16/05/2025
/*/
Function OA5300011_Validacao_PV(oModel, cField, xValue, xValueAntigo)
Local lRet := .t.
If !Empty(xValue)
	lRet := ExistCpo("CFH",xValue)
EndIf
Return lRet

/*/{Protheus.doc} OA5300021_GetModel
	Definicao da struct PECAS, OFICINA e VEICULOS
	
	@author Andre Luis Almeida
	@since 16/05/2025
/*/
Static Function OA5300021_GetModel()
Local nCntFor := 0
Local nTamCFH := 4
Local oMd     := OFDMSStruct():New()
Local aPV     := OA5300061_Pontos_de_Venda()

if cPaisLoc == "ARG"
	nTamCFH := GetSX3Cache("CFH_CODIGO","X3_TAMANHO")
endif

For nCntFor :=  1 to len(aPV)
	oMd:AddField({;
		{'cTitulo'  , aPV[nCntFor,1] },;
		{'cIdField' , aPV[nCntFor,2] },;
		{'nTamanho' , nTamCFH },;
		{'lObrigat' , .f. },;
		{'cFolder'  , aPV[nCntFor,3] },;
		{'bValid', { |a,b,c,d| OA5300011_Validacao_PV(a,b,c,d) }},;
		{'cLookUp'  , "CFH" },;
		{'cTooltip' , aPV[nCntFor,4] } ;
	})
Next
Return oMd

/*/{Protheus.doc} OA5300031_Load()
	default values for the filter
	
	@author Andre Luis Almeida
	@since  16/05/2025
/*/
Static Function OA5300031_Load()
Local nCntFor := 0
Local nTamCFH := 4
Local aRet    := {}
Local aPV     := OA5300061_Pontos_de_Venda()

if cPaisLoc == "ARG"
	nTamCFH := GetSX3Cache("CFH_CODIGO","X3_TAMANHO")
endif

For nCntFor :=  1 to len(aPV)
	aAdd(aRet, oConfig:GetValue( aPV[nCntFor,2] , space(nTamCFH) ) )
Next
//
Return {aRet,0}

/*/{Protheus.doc} OA5300041_Confirmar
	Salva os dados preenchidos na TELA
	
	@author Andre Luis Almeida
	@since  16/05/2025
/*/
Static Function OA5300041_Confirmar(oModel)
Local nCntFor := 0
Local oTela   := oModel:GetModel("TELA")
Local jJson   := JsonObject():New()
Local aPV     := OA5300061_Pontos_de_Venda()
For nCntFor :=  1 to len(aPV)
	jJson[aPV[nCntFor,2]] := oTela:GetValue(aPV[nCntFor,2])
Next
oConfig:Save(jJson)
return .t.

/*/{Protheus.doc} OA5300051_Retorna_Ponto_de_Venda
	Retorna o Ponto de Venda padrão a ser utilizado nas rotinas de Remito e Fatura
	 - PV_REM_TRANSF        - Remito - Transferência de Peças
	 - PV_REM_ORCTO         - Remito - Orçamento de Peças
	 - PV_FAT_ORCTO         - Fatura - Orçamento de Peças
	 - PV_REM_REMREQ        - Remito - Remessa de Peça
	 - PV_FAT_GARFECTO      - Fatura - Fechamento de OS Garantia Interna
	 - PV_FAT_INTFECTO      - Fatura - Fechamento de OS Interna
	 - PV_FAT_FECTO         - Fatura - Fechamento de OS Geral
	 - PV_FAT_GARJD         - Fatura - Garantia JD - Dealer
	 - PV_NCC_DEVVENDA      - Fatura - NCC da Entrada por Devolução de Venda
	 - PV_REM_ENTRETREMESSA - Remito - Entrada por Retorno de Remessa quando Formulário Próprio
	 - PV_REM_ENTRETCONSIG  - Remito - Entrada por Retorno de Consignação quando Formulário Próprio
	 - PV_REM_TRANSFER      - Remito - Saida de Veiculos por Transferência
	 - PV_REM_REMESSA       - Remito - Saida de Veiculos por Remessa
	 - PV_REM_DEVCOMPRA     - Remito - Devolução de Compra
	 - PV_REM_CONSIG        - Remito - Saida de Veiculos por Consignação
	 - PV_REM_RETREMESSA    - Remito - Retorno de Remessa
	 - PV_REM_RETCONSIG     - Remito - Retorno Consignação
	 - PV_REM_ATENDVEI      - Remito - Atendimento de Veículos/Máquinas
	 - PV_FAT_ATENDVEI      - Fatura - Atendimento de Veículos/Máquinas
	 - PV_FAT_INCENT        - Fatura - Incentivos - Faturamento Direto
	 - PV_REM_SAIVENDA      - Remito - Saida por Venda de Veículos/Máquinas
	 - PV_FAT_SAIVENDA      - Fatura - Saida por Venda de Veículos/Máquinas
	@author Andre Luis Almeida
	@since  19/05/2025
/*/
Function OA5300051_Retorna_Ponto_de_Venda(cTAGJSON)
Local oConfig := OFIA530Config():New()
Local cRetPV  := oConfig:GetValue( cTAGJSON , "" )
Return cRetPV

/*/{Protheus.doc} OA5300061_Pontos_de_Venda
	Retorna os Pontos de Vendas do DMS
	
	@author Andre Luis Almeida
	@since  15/07/2025
/*/
Static Function OA5300061_Pontos_de_Venda()
Local aPV := {}
aAdd(aPV,{STR0008,"PV_REM_TRANSF"       ,"PEC",STR0009}) // Remito da Transferência de Peças / Informe o Ponto de Venda relacionado ao Remito da Transferência de Peças
aAdd(aPV,{STR0010,"PV_REM_ORCTO"        ,"PEC",STR0011}) // Remito do Orçamento de Peças / Informe o Ponto de Venda relacionado ao Remito do Orçamento de Peças
aAdd(aPV,{STR0012,"PV_FAT_ORCTO"        ,"PEC",STR0013}) // Fatura do Orçamento de Peças / Informe o Ponto de Venda relacionado a Fatura do Orçamento de Peças
aAdd(aPV,{STR0014,"PV_REM_REMREQ"       ,"OFI",STR0015}) // Remito da Remessa de Peças / Informe o Ponto de Venda relacionado ao Remito da Remessa de Peças
aAdd(aPV,{STR0042,"PV_FAT_GARFECTO"     ,"OFI",STR0043}) // Fechamento de OS Garantia Interna / Informe o Ponto de Venda relacionado ao Fechamento de OS Garantia Interna
aAdd(aPV,{STR0044,"PV_FAT_INTFECTO"     ,"OFI",STR0045}) // Fechamento de OS Interna / Informe o Ponto de Venda relacionado ao Fechamento de OS Interna
aAdd(aPV,{STR0016,"PV_FAT_FECTO"        ,"OFI",STR0017}) // Fatura do Fechamento de OS / Informe o Ponto de Venda relacionado a Fatura do Fechamento de OS
If cMVMIL0006 == "JD"
	aAdd(aPV,{STR0018,"PV_FAT_GARJD"    ,"OFI",STR0019}) // Fatura de Garantia JD - Dealer / Informe o Ponto de Venda relacionado a Fatura de Garantia JD - Dealer
EndIf
aAdd(aPV,{STR0036,"PV_NCC_DEVVENDA"     ,"VEI",STR0037}) // Fatura de NCC da Entrada por Devolução de Venda / Informe o Ponto de Venda relacionado a Fatura de NCC da Entrada de Veículos/Máquinas por Devolução de Venda
aAdd(aPV,{STR0038,"PV_REM_ENTRETREMESSA","VEI",STR0039}) // Remito de Entrada por Retorno de Remessa quando Formulário Próprio / Informe o Ponto de Venda relacionado ao Remito de Entrada de Veículos/Máquinas por Retorno de Remessa quando Formulário Próprio
aAdd(aPV,{STR0040,"PV_REM_ENTRETCONSIG" ,"VEI",STR0041}) // Remito de Entrada por Retorno de Consignação quando Formulário Próprio / Informe o Ponto de Venda relacionado ao Remito de Entrada de Veículos/Máquinas por Retorno de Consignação quando Formulário Próprio
aAdd(aPV,{STR0046,"PV_REM_TRANSFER"     ,"VEI",STR0047}) // Remito da Saida por Transferência / Informe o Ponto de Venda relacionado ao Remito da Saida de Veículos/Máquinas por Transferência
aAdd(aPV,{STR0048,"PV_REM_REMESSA"      ,"VEI",STR0049}) // Remito da Saida por Remessa / Informe o Ponto de Venda relacionado ao Remito da Saida de Veículos/Máquinas por Remessa
aAdd(aPV,{STR0020,"PV_REM_DEVCOMPRA"    ,"VEI",STR0021}) // Remito da Saída por Devolução de Compra / Informe o Ponto de Venda relacionado ao Remito da Saída de Veículos/Máquinas por Devolução de Compra
aAdd(aPV,{STR0050,"PV_REM_CONSIG"       ,"VEI",STR0051}) // Remito da Saida por Consignação / Informe o Ponto de Venda relacionado ao Remito da Saida de Veículos/Máquinas por Consignação
aAdd(aPV,{STR0022,"PV_REM_RETREMESSA"   ,"VEI",STR0023}) // Remito da Saída por Retorno de Remessa / Informe o Ponto de Venda relacionado ao Remito da Saída de Veículos/Máquinas por Retorno de Remessa
aAdd(aPV,{STR0024,"PV_REM_RETCONSIG"    ,"VEI",STR0025}) // Remito da Saída por Retorno de Consignação / Informe o Ponto de Venda relacionado ao Remito da Saída de Veículos/Máquinas por Retorno de Consignação
aAdd(aPV,{STR0026,"PV_REM_ATENDVEI"     ,"VEI",STR0027}) // Remito do Atendimento de Veículos/Máquinas / Informe o Ponto de Venda relacionado ao Remito do Atendimento de Veículos/Máquinas
aAdd(aPV,{STR0028,"PV_FAT_ATENDVEI"     ,"VEI",STR0029}) // Fatura do Atendimento de Veículos/Máquinas / Informe o Ponto de Venda relacionado a Fatura do Atendimento de Veículos/Máquinas
aAdd(aPV,{STR0030,"PV_FAT_INCENT"       ,"VEI",STR0031}) // Fatura do Incentivos Faturamento Direto / Informe o Ponto de Venda relacionado a Fatura do Incentivos Faturamento Direto
aAdd(aPV,{STR0032,"PV_REM_SAIVENDA"     ,"VEI",STR0033}) // Remito da Saida por Venda de Veículos/Máquinas / Informe o Ponto de Venda relacionado ao Remito da Saida por Venda de Veículos/Máquinas
aAdd(aPV,{STR0034,"PV_FAT_SAIVENDA"     ,"VEI",STR0035}) // Fatura da Saida por Venda de Veículos/Máquinas / Informe o Ponto de Venda relacionado a Fatura da Saida por Venda de Veículos/Máquinas
Return aPV

/*/{Protheus.doc} OFIA530Config
	Classe principal para tratar os dados de configuração dos Pontos de Venda ARGENTINA - OFIA530
	
	@type class
	@author Andre Luis Almeida
	@since 27/05/2025
/*/
Class OFIA530Config
	Public Data cCodigo
	Public Data cFilConf
	Data jConfig

	Public Method New() CONSTRUCTOR
	Public Method SetValue()
	Public Method GetValue()
	Public Method Save()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type method
	@author Andre Luis Almeida
	@since 27/05/2025
/*/
Method New() Class OFIA530Config
	Local lTipConf := ( VRN->(FieldPos("VRN_FILCON")) > 0 )
	Local nOrdVRN  := 1  // Ordem VRN: 1 = Filial + Codigo
	Local cFilVRN  := "" // Sem Filial da Configuração no VRN
	If lTipConf
		nOrdVRN := 2 // 2 = Filial + Filial Config + Codigo
		cFilVRN := Padr(cFilAnt,FWSizeFilial()) // Carrega a Filial Logada
	EndIf
	::cCodigo  := "OFIA530"
	::cFilConf := cFilVRN
	::jConfig  := JsonObject():New()
	dbselectArea("VRN")
	dbSetOrder( nOrdVRN ) // Ordem do VRN
	If dbSeek(xFilial("VRN") + ::cFilConf + ::cCodigo)
		::jConfig:FromJson(VRN->VRN_CONFIG)
	Else
		VRN->(reclock("VRN", .T.))
		VRN->VRN_FILIAL := xFilial("VRN")
		VRN->VRN_CODIGO := ::cCodigo
		VRN->VRN_CONFIG := "{}"
		If lTipConf
			VRN->VRN_FILCON := ::cFilConf
		EndIf
		VRN->(msUnlock())
	EndIf	
Return SELF

/*/{Protheus.doc} GetValue
	retorna o valor contido no json para o parametro passado

	@type method
	@author Andre Luis Almeida
	@since 27/05/2025
/*/
Method GetValue(cLabel, xDef) Class OFIA530Config
	if self:jConfig:hasProperty(cLabel)
		return self:jConfig[cLabel]
	endif
Return xDef

/*/{Protheus.doc} SetValue
	Seta o valor do parametro no json

	@type method
	@author Andre Luis Almeida
	@since 27/05/2025
/*/
Method SetValue(cAttr, xValue) Class OFIA530Config
	self:jConfig[cAttr] := xValue
Return .t.

/*/{Protheus.doc} Save
	salva json com a configuração

	@type method
	@author Andre Luis Almeida
	@since 27/05/2025
/*/
Method Save(jConfig) Class OFIA530Config
	Local lTipConf := ( VRN->(FieldPos("VRN_FILCON")) > 0 )
	Local nOrdVRN  := IIf(lTipConf,2,1)
	dbselectArea("VRN")
	dbSetOrder(nOrdVRN)
	If dbSeek(xFilial("VRN") + self:cFilConf + self:cCodigo)
		reclock("VRN", .F.)
		VRN->VRN_CONFIG := jConfig:toJSON()
		msUnlock()
	EndIf
	self:jConfig := jConfig
Return .t.