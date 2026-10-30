#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static _lIsSmartUI := .F. // Variável para controlar se a requisição está sendo chamada pelo SmartUI

//-------------------------------------------------------------------
/*/{Protheus.doc} JPagPfsModel
Classe dos modelos para os App do PFS

@since 07/07/2020
/*/
//-------------------------------------------------------------------

Class JPagPfsModel From FwRestModel
	Data searchKey AS STRING

	Method Activate()
	Method SetFilter()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Tratamento para Ativar o modelo

@since 07/07/2020
/*/
//-------------------------------------------------------------------
Method Activate() Class JPagPfsModel
Local cPath      := self:GetHttpHeader("_PATH_")
Local cSmartUI   := self:GetHttpHeader("SMARTUI")
Local cId        := ""
Local cFiltro    := ""
Public lF050Auto := .F.

	self:searchKey := self:GetHttpHeader("searchKey")
	Do Case 
		Case IsInPath(cPath, "JURA246")
			cId := SubStr(cPath, RAt("/", cPath) - Len(cPath))
			If (cId != "JURA246")
				cId := Decode64(cId)
				
				DbSelectArea("SE2")
				SE2->( DbSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				SE2->( DbSeek(cId) )
			EndIf 
		Case IsInPath(cPath, "JURA247")
			cId := SubStr(cPath, RAt("/", cPath) - Len(cPath))
			If (cId != "JURA247")
				cId := Decode64(cId)
				
				DbSelectArea("SE2")
				SE2->( DbSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				SE2->( DbSeek(cId) )
			EndIf
		Case IsInPath(cPath, "JURA278")
			cId := SubStr(cPath, RAt("/", cPath) - Len(cPath))
			If (cId != "JURA278")
				cId := Decode64(cId)
				
				DbSelectArea("SE2")
				SE2->( DbSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				SE2->( DbSeek(cId) )
			EndIf
	End Case

	If !Empty(self:searchKey)
		If (!Empty(Self:cFilter))
			cFiltro := Self:cFilter + " AND "
		EndIf
		cFiltro := cFiltro + JMontSrcky(self:searchKey)

		Self:SetFilter(cFiltro)
	EndIf

	IIf(cSmartUI == Nil, cSmartUI := "", "")

	_lIsSmartUI := (Upper(cSmartUI) == "TRUE")
	I18nConOut("SMARTUI: #1", {cSmartUI})

Return _Super:Activate()

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter()
Filtro recebido da requisição.

@since 07/08/2020
/*/
//-------------------------------------------------------------------
Method SetFilter(cFilter)  Class JPagPfsModel
Local cVerbo     := self:GetHttpHeader("_METHOD_")
Local cPath      := self:GetHttpHeader("_PATH_")
Local cQuery     := self:GetHttpHeader("_QUERY_")
Local cFiltFil   := ""

	If (cQuery == Nil)
		cQuery := ""
	EndIf

	If (cVerbo == "GET")
		If ( "FILTFIL=" $ Upper(cQuery) )
			Do Case 
				Case IsInPath(cPath, "JPPJUR148")
					cFiltFil := "A1_FILIAL='" + FWxFilial("SA1") + "'"
				Case IsInPath(cPath, "JPPMAT020")
					cFiltFil := "A2_FILIAL='" + FWxFilial("SA2") + "'"
				Case IsInPath(cPath, "JPPJUR159")
					cFiltFil := "RD0_FILIAL='" + FWxFilial("RD0") + "'"
				Case IsInPath(cPath, "JPPCTB140")
					cFiltFil := "CTO_FILIAL='" + FWxFilial("CTO") + "'"
				Otherwise
					cFiltFil := ""
			End Case

			If !Empty(cFiltFil)
				If !Empty(cFilter)
					cFilter += " AND "
				EndIf

				cFilter += cFiltFil
			EndIf
		EndIf

	EndIf

Return _Super:SetFilter(cFilter)

//-------------------------------------------------------------------
/*/{Protheus.doc} IsInPath(cPath, cFonte)
Verifica se o Endpoint (cFonte) está na requisição (cPath)

@Param cPath - Path completo da requisição
@Param cFonte - Nome do fonte a ser verificado

@since 30/09/2019
/*/
//-------------------------------------------------------------------
Static Function IsInPath(cPath, cFonte)
Default cPath  := ""
Default cFonte := ""
Return  cFonte $ cPath

Static Function ReplaceAcc(cFiltro)
Return cFiltro


//-------------------------------------------------------------------
/*/{Protheus.doc} JMontSrcky(cBusca)
Função responsável por normalizar o searchKey. Remove caracteres especiais no campo e
a palavra pesquisada.

@param cBusca - Estrutura para realizar o tratamento dos caracteres 
				especiais. Estrutura:
				{
					"fields": [
						{ "NQ4_COD" },
						{ "NQ4_DESC" },
					]
					"searchKey": 'palavra ou frase a ser pesquisada'
				}

@since 17/06/2021
/*/
//-------------------------------------------------------------------
Function JMontSrcky(cBusca)
Local cFilter   := ""
Local cValBusca := ""
Local cResulFil := ""
Local nI        := 1
Local nFields   := 0
Local oBusca    := JsonObject():New()

	If !Empty(cBusca)
		oBusca:fromJson(cBusca)
		nFields := Len(oBusca['fields'])

		If nFields > 0 .And. !Empty(oBusca['searchKey'])
			cValBusca  := DecodeUTF8(oBusca['searchKey'] )

			cFilter := ' ( '

			If Empty(cValBusca)
				cValBusca := Lower( StrTran( JurLmpCpo( oBusca['searchKey'], .F. ), '#', '' ) )
			EndIf

			For nI := 1 To nFields
				cResulFil := JFilSx3Tip(oBusca['fields'][nI], cValBusca)

				If !Empty(cResulFil)
					cFilter += cResulFil
					If nI < nFields
						cFilter += ' OR '
					EndIf
				EndIf
			Next

			cFilter += ') '
		EndIf
	EndIf
Return cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} JFilSx3Tip(cCampo, cValor)
Função responsável por verificar o tipo do campo e montar a query 
de acordo

@param cCampo - Campo a ser filtrado
@param cValor - Valor inputado que poderá ser convertido

@return Comparação realizando a conversão apropriada do valor

@author Willian Kazahaya
@since 28/07/2021
/*/
//-------------------------------------------------------------------
Static Function JFilSx3Tip(cCampo, cValor)
Local cFiltro   := ""
Local cFieldTip := GetSx3Cache(cCampo, "X3_TIPO")
Local cValLimp  := cValor

	Do Case
		Case cFieldTip == "D"
			cFiltro := cCampo + "= '" + DToS(CTOD(cValor)) + "'"
		Case cFieldTip == "N"
			cFiltro := cCampo + " LIKE '%" + StrTran(StrTran(cValLimp, ".", ""), ",", ".") + "%'"
		Otherwise
			cFiltro := JurFormat(cCampo, .T./*lAcentua*/,.T./*lPontua*/) + " LIKE '%" + Lower(StrTran( JurLmpCpo( cValor, .F. ), '#', '' )) + "%'"
	End Case

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} JIsSmartUI
Indica se a execução está sendo feita por uma requisição do SmartUI

@return _lIsSmartUI, .T. - Requisição do SmartUI

@author Abner Fogaça
@since 19/03/2024
/*/
//-------------------------------------------------------------------
Function JIsSmartUI()
Return _lIsSmartUI

//-------------------------------------------------------------------
/* Publicação dos modelos que são disponibilizados no REST */
// Modelos utilizados nos Apps com fontes de outras equipes
PUBLISH MODEL REST NAME JVALACESSORIO    SOURCE FINA050VA RESOURCE OBJECT JPagPfsModel      //Valores acessórios - FINA050VA
PUBLISH MODEL REST NAME JTITPAGAR        SOURCE FINA050   RESOURCE OBJECT JPagPfsModel      //Titulo a pagar - FINA050
PUBLISH MODEL REST NAME JFNCONTASPAGAR   SOURCE FINA750   RESOURCE OBJECT JPagPfsModel      //Funções contas a pagar  - FINA750
PUBLISH MODEL REST NAME JCOMPTITULO      SOURCE FINA986   RESOURCE OBJECT JPagPfsModel      //Complemento de Título - FINA986
PUBLISH MODEL REST NAME JTRACKERCONTABIL SOURCE CTBC662   RESOURCE OBJECT JPagPfsModel      //Tracker Contábil - CTBC662

// Modelos utilizados nos Apps do SIGAPFS
PUBLISH MODEL REST NAME JURA246          SOURCE JURA246  RESOURCE OBJECT JPagPfsModel       //Desdobramento - JURA246
PUBLISH MODEL REST NAME JURA247          SOURCE JURA247  RESOURCE OBJECT JPagPfsModel       //Desdobramento Pós-pagamento - JURA247
PUBLISH MODEL REST NAME JURA277          SOURCE JURA277  RESOURCE OBJECT JPagPfsModel       //Titulo do Pagar - FWSE2
PUBLISH MODEL REST NAME JURA278          SOURCE JURA278  RESOURCE OBJECT JPagPfsModel       //Item do Projeto - FWOHM
PUBLISH MODEL REST NAME JURA240          SOURCE JURA240  RESOURCE OBJECT JPagPfsModel       //Histórico Padrão - JURA240
PUBLISH MODEL REST NAME JURA291          SOURCE JURA291  RESOURCE OBJECT JPagPfsModel       //Cadastro de Rotinas Customizadas - JURA291
PUBLISH MODEL REST NAME JURA292          SOURCE JURA292  RESOURCE OBJECT JPagPfsModel       //"Rotinas Disponiveis PagPFS" - JURA292
PUBLISH MODEL REST NAME JURA056          SOURCE JURA056  RESOURCE OBJECT JPagPfsModel       //Junção de contratos - JURA056

// Modelos presentes no JurRestModel mas que precisam do tratamento do JPagPfsModel
PUBLISH MODEL REST NAME JPPJUR148        SOURCE JURA148 RESOURCE OBJECT JPagPfsModel       //Clientes - JURA148
PUBLISH MODEL REST NAME JPPJUR159        SOURCE JURA159 RESOURCE OBJECT JPagPfsModel       //Participantes - JURA159
PUBLISH MODEL REST NAME JPPJUR238        SOURCE JURA238 RESOURCE OBJECT JPagPfsModel       //Tabela Rateio - JURA238
PUBLISH MODEL REST NAME JPPMAT020        SOURCE MATA020 RESOURCE OBJECT JPagPfsModel       //Fornecedor - MATA020
PUBLISH MODEL REST NAME JPPCTB140        SOURCE CTBA140 RESOURCE OBJECT JPagPfsModel       //Moedas Contábeis - CTBA140
PUBLISH MODEL REST NAME JPPMAT070        SOURCE MATA070 RESOURCE OBJECT JPagPfsModel       //Banco - MATA070
PUBLISH MODEL REST NAME JPPCONDPAG       SOURCE MATA360 RESOURCE OBJECT JPagPfsModel      //Condição de Pagamento - MATA360
