#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "AGDJ030.CH"

#DEFINE AGD_JOB "AGDJ030"
#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDJ030
Rotina responsável por realizar carga de dados para rebate
Somente via Job/Schedule.
@type Function
@version 12
@author lindembergson.pacheco
@since 04/08/2026
/*/
Function AGDJ030()

	private JobName :=  AGD_JOB + "_" + AllTrim(MV_PAR01)+ "_" + AllTrim(MV_PAR03)

	If ! isBlind()
		FWAlertError(STR0001) //"Rotina de uso restrito para Job/Schedule."
		Return
	EndIf

	If ! LockByName(JobName, .T. , .T.)
		FWLogMsg("WARN", Nil, JobName, procName(), Nil, Nil, i18n(STR0002, {cEmpAnt, cFilant})) //"A rotina ja esta sendo executada em outra thread. Grupo: #1[CODIGO_GRUPO]#  Filial: #2[CODIGO_FILIAL]#"
		Return
	EndIf

	FWLogMsg("INFO", Nil, JobName, procName(), Nil, Nil, STR0003) //"Iniciando Job..."
	AGDJ030M()

	FWLogMsg("INFO", Nil, JobName, procName(), Nil, Nil, STR0004) //"Fim do Job."
	UnlockByName(JobName, .T., .T.)
Return

/*/{Protheus.doc} SchedDef
As definições de agendamento são determinadas por rotina, sendo configuradas pela função SCHEDDEF().
Ao agendar uma rotina no Schedule, o sistema verIfica a existência da função e aplica as configurações 
retornadas, permitindo controlar dinamicamente opções de execução.
@type Function
@version 12
@author lindembergson.pacheco
@since 04/08/2026
@Return array, lista de configurações esperadas pelo SchedDef.
/*/
Static Function SchedDef()
	Local aParam := {}

	aParam := {;
		"P"   ,; // R=relatorio; P=processo
	"AGDJ030",; // Pergunte do relatorio, caso nao use, informar "PARAMDEF"
	Nil       ,; // cAliasNF7 (Quando R=Relatório)
	Nil       ,; // aArray (Quando R=Relatório)
	Nil       ,; // Titulo (Quando R=Relatório)
	Nil       ,; // Nome  (Quando R=Relatório)s
	.F.       ,; // Permite agendamento sempre ativo?
	.T.        ; // Permite agendamento por filiais?
	}
Return aParam


/*/{Protheus.doc} AGDJ030M
* Processa e grava registros para rebate
* @type Function
* @version 12
* @author lindembergson.pacheco
* @since 04/08/2026
/*/
Static Function AGDJ030M()

	Local cQuery      := ""
	Local cIdent      := AllTrim(MV_PAR01)
	Local cRota       := AllTrim(MV_PAR02)
	Local cEntidade   := AllTrim(MV_PAR03)
	Local nDias       := MV_PAR04
	Local nQuebra     := MV_PAR05
	Local cParams     := AllTrim(MV_PAR06)
	Local cFilialNFA  := cFilant//FWxFilial("NFA", cFilant)
	Local cChave      := cFilialNFA + cIdent + cEntidade

	// Limpa registros anteriores
	cQuery := "DELETE FROM " + RetSqlName("NFA") + ;
		" WHERE NFA_FILIAL = '" + cFilialNFA + "'" + ;
		" AND NFA_CHAVE = '" + cChave + "'"

	TCSqlExec(cQuery)

	IF !Empty(cParams)
		cParams := AGDJ030PAR(cParams)
	endif

	// Processamento
	If nQuebra == 1 .And. nDias > 0
		// Processamento com quebra diária
		AGDJ030DIA(cIdent, cRota, cEntidade, nDias, cParams, cFilialNFA, cChave)
	Else
		// Processamento normal
		AGDJ030LT(cIdent, cRota, cEntidade, cParams, cFilialNFA, cChave, Nil)

	EndIf

Return


/*/{Protheus.doc} AGDJ030PAR
* Converte os parâmetros recebidos em formato query string para JsonObject.
* Exemplos:
* filter=insc_cli eq 'ISENTO'
* cnpj_cli=93578052000120
* filter=insc_cli eq 'ISENTO'&cnpj_cli=93578052000120
* @type Function
* @version 12
* @author lindembergson.pacheco
* @since 13/08/2026
/*/
Static Function AGDJ030PAR(cParams)

	Local oParams := JsonObject():New()
	Local aParams := {}
	Local aParam  := {}
	Local nParam  := 0
	Local cParam  := ""
	Local cKey    := ""
	Local cValue  := ""
	Local nX      := 0

	// Separa os parâmetros pelo &
	aParams := StrTokArr(cParams, "&")

	For nParam := 1 To Len(aParams)

		cParam := AllTrim(aParams[nParam])

		// If Empty(cParam)
		// 	Loop
		// EndIf

		// Separa chave e valor pelo primeiro =
		aParam := StrTokArr(cParam, "=")

		If Len(aParam) >= 2

			cKey := AllTrim(aParam[1])

			// Recompõe o valor caso exista "=" no conteúdo
			cValue := ""

			For nX := 2 To Len(aParam)

				If nX > 2
					cValue += "="
				EndIf

				cValue += aParam[nX]

			Next

			cValue := AllTrim(cValue)

			If !Empty(cKey)
				oParams[cKey] := cValue
			EndIf

		EndIf

	Next

Return oParams

/*/{Protheus.doc} AGDJ030FT
* Monta os parâmetros da consulta para determinado dia
* @type Function
* @version 12
* @author lindembergson.pacheco
* @since 12/08/2026
/*/
Static Function AGDJ030FT(cParams, dDataLote, cEntidade)

	Local oParams := JsonObject():New()
	Local cData   := DToS(dDataLote)

	if cEntidade $ "2" // Notas Fiscais

		If ValType(cParams) == "J" .and. cParams:hasProperty("filter") .and. cParams:GetJsonText("filter") != 'null'
			oParams["filter"] := "data_ven eq '" + cData + "' and " +  cParams:GetJsonText("filter")
		else
			oParams["filter"] := "data_ven eq '" + cData + "'"
		EndIf

	elseif cEntidade $ "7" // Notas Fiscais V2

		If ValType(cParams) == "J" .and. cParams:hasProperty("filter") .and. cParams:GetJsonText("filter") != 'null'
			oParams["filter"] := "FaturamentoData eq '" + cData + "' and " +  cParams:GetJsonText("filter")
		else
			oParams["filter"] := "FaturamentoData eq '" + cData + "'"
		EndIf

	elseif cEntidade $ "B" // Pedidos

		If ValType(cParams) == "J" .and. cParams:hasProperty("filter") .and. cParams:GetJsonText("filter") != 'null'
			oParams["filter"] := "data_ped eq '" + cData + "' and " +  cParams:GetJsonText("filter")
		else
			oParams["filter"] := "data_ped eq '" + cData + "'"
		EndIf

	endif

Return oParams

/*/{Protheus.doc} AGDJ030DIA
* Processa consultas com quebra diária
* @type Function
* @version 12
* @author lindembergson.pacheco
* @since 12/08/2026
/*/
Static Function AGDJ030DIA(cIdent, cRota, cEntidade, nDias, cParams, cFilialNFA, cChave)

	Local nDia        := 0
	Local dDataLote   := Nil
	Local cParamsDia  := ""

	// Processa cada dia
	For nDia := 0 To nDias - 1

		// Data que será consultada
		dDataLote := dDataBase - nDia

		// Monta os parâmetros da consulta
		cParamsDia := AGDJ030FT(cParams, dDataLote, cEntidade)

		// Processa a paginação daquele dia
		AGDJ030LT(cIdent, cRota,  cEntidade, cParamsDia, cFilialNFA, cChave, dDataLote)

	Next

Return

/*/{Protheus.doc} AGDJ030LT
* Processa uma consulta através de paginação
* @type Function
* @version 12
* @author lindembergson.pacheco
* @since 12/08/2026
/*/
Static Function AGDJ030LT(cIdent, cRota, cEntidade, cParams, cFilialNFA, cChave, dDataLote )

	Local oService    := Nil
	Local oResponse   := Nil
	Local aItens      := {}
	Local lHasNext    := .T.
	Local cDados      := ""
	Local nPage       := 1
	Local nPageSize   := 100

	// Paginação
	While lHasNext

		// Cria um novo Service para cada página
		oService := AGDJ030SV(cEntidade)

		If oService == Nil

			FWLogMsg( "ERROR",  Nil,  JobName, ProcName(), Nil, Nil,  i18n(STR0005, {cEntidade})) //"Service não encontrado para entidade: #1[CODIGO_ENTIDADE]#"

			Return

		EndIf

		if cEntidade $ "1|2|3|6|B|D|" //entidade bayer/corteva
			If ValType(cParams) == "J"
				cParams["codi_rev"] := cFilialNFA
			Else
				cParams := JsonObject():New()
				cParams["codi_rev"] := cFilialNFA
			ENDIF
		endif

		// Executa consulta
		oResponse := AGDJ030RES( cEntidade, oService, nPage, nPageSize, cParams )

		// If oResponse == Nil
		// 	FWFreeObj(oService)
		// 	oService := Nil
		// 	Return
		// EndIf

		// Obtém itens
		if oResponse:hasProperty("items")
			aItens := oResponse["items"]
		else
			aItens := oResponse
		endif



		// Grava o lote inteiro no campo MEMO
		If Len(aItens) > 0//If ValType(aItens) == "A" .And. Len(aItens) > 0

			if ValType(aItens) == "A"
				cDados := FWJsonSerialize(aItens)
			else
				cDados := aItens:toJson()
			endif
			If RecLock("NFA", .T.)

				NFA_FILIAL := cFilialNFA
				NFA_IDENT  := cIdent
				NFA_ENTIDA := cEntidade
				NFA_CHAVE  := cChave
				NFA_SEQUEN := IIF( !Empty(dDataLote) , FormataData(dDataLote, 1) + " - " + AllTrim(Str(nPage)) , AllTrim(Str(nPage)))
				NFA_ROTA   := cRota
				NFA_FILORI := cFilialNFA
				NFA_DTJOB  := dDataBase
				NFA_DTREG  := dDataLote
				NFA_DADOS  := cDados

				MsUnlock()

			EndIf

		EndIf

		if oResponse:hasProperty("hasNext")
			// Verifica se existe próxima página
			lHasNext := oResponse["hasNext"]

			// Próxima página
			nPage++
		else
			lHasNext := .F.
		endif


		// Libera objetos
		FWFreeObj(oService)

		oService  := Nil
		oResponse := Nil

	EndDo

Return

/*/{Protheus.doc} AGDJ030CB
Cria opcao de selecao para SX1(MV_PAR03) de acordo com NFA_ENTIDA 
@type function
@version 12
@author lindembergson.pacheco
@since 06/08/2026
/*/
Function AGDJ030CB()

	Local cTitulo    := STR0006 //"Entidades"
	Local cMvParDef  := ""
	Local cMvPar     := "" //Retorno da funcao f_Opcoes
	Local cMvRet     := AllTrim(ReadVar()) //Pergunta sendo tratada
	Local cValBkp    := &(ReadVar()) //Backup do valor inicial da pergunta
	Local lRet       := .T.
	Local aCBox      := {}
	Local nX         := 0
	Local aEntidade  := {}

	aCBox := x3CboxToArray("NFA_ENTIDA") //entidade

	For nX := 1 to Len(aCBox[2])

		cMvParDef +=  aCBox[2][nX]
		aAdd(aEntidade, alltrim(aCBox[1][nX]))
	Next

	//Chama funcao com opcoes da pergunta
	If f_Opcoes(@cMvPar, cTitulo, aEntidade, cMvParDef, 12, 49, .F.)
		&(cMvRet) := AllTrim(StrTran(cMvPar, "*", ""))
	ElseIf !Empty(cValBkp) .And. cValBkp $ cMvParDef
		&(cMvRet) := cValBkp
	Else
		lRet := .F.
	EndIf

Return lRet


/*/{Protheus.doc} AGDNFACBOX
Cria combobox para o campo NFA_ENTIDA 
@type function
@version 12
@author lindembergson.pacheco
@since 06/08/2026
/*/
Function AGDNFACBOX()

	Local cCombo    := "1=Clientes;2=Notas Fiscais;3=Estoque;4=Safra;5=Cultura;6=Totalizadores;7=Notas Fiscais V2;8=Produtos;9=Municipios;A=Estoque V2;B=Pedido;C=Vendedores;D=Filiais" //STR0007

Return cCombo


/*/{Protheus.doc} AGDJ030SV
Obtem o classe de serviço de acordo com a entidade
@type function
@version 12
@author lindembergson.pacheco
@since 06/08/2026
@param cEntidade, character, Código da entidade de acordo com NFA_ENTIDA
/*/
Static Function AGDJ030SV(cEntidade)

	Local oService := Nil

	Do Case

	Case cEntidade == "1" // Clientes

		oService := NAMESPACEAGD.CustomerIntegrationService():New()

	Case cEntidade == "2" .or.  cEntidade == "7" // 2 - Notas Fiscais; 7 - Notas Fiscais V2

		oService := NAMESPACEAGD.RebateInvoiceService():New()

	Case cEntidade == "3" .or. cEntidade == "8" .or. cEntidade == "A" // 3 - Estoque; 8 - Produtos; A - Estoque V2

		oService := NAMESPACEAGD.RebateProductService():New()

	Case cEntidade == "4" // Safra

		oService := NAMESPACEAGD.RebateHarvestService():New()

	Case cEntidade == "5" // Cultura

		oService := NAMESPACEAGD.RebateCultureService():New()

	Case cEntidade == "6" // Totalizadores

		oService := NAMESPACEAGD.FiscalMovementService():New()

	Case cEntidade == "9" // Municipios

		oService := NAMESPACEAGD.CityService():New()

	Case cEntidade == "B" // Pedido

		oService := NAMESPACEAGD.SalesPurchaseOrderRebateSevice():New()

	Case cEntidade == "C" // Vendedores

		oService := NAMESPACEAGD.SalesmanIntegrationService():New()

	Case cEntidade == "D" // Filiais

		oService := NAMESPACEAGD.RebateBranchesService():New()

	EndCase

Return oService

/*/{Protheus.doc} AGDJ030RES
executa o metodo de busca de registro da classe de serviço de acordo com a entidade
@type function
@version 12
@author lindembergson.pacheco
@since 06/08/2026
@param cEntidade, character, Código da entidade de acordo com NFA_ENTIDA
/*/
Static Function AGDJ030RES(cEntidade, oService, nPage, nPageSize, cParams)

	Local cFabricanteID          := ""
	Local cCodiRev               := ""

	IF ValType(cParams) != "J"
		IF Empty(cParams)
			cParams := JsonObject():New()
		ENDIF
	ENDIF

	Do Case

	Case cEntidade == "1" // Clientes

		oService:listCustomers(nPage, nPageSize, cParams)

	Case cEntidade == "2" // Notas Fiscais

		oService:findDataInvoice(nPage, nPageSize, cParams)

	Case cEntidade == "3" // Estoque

		oService:findProductStock(nPage, nPageSize, cParams)

	Case cEntidade == "4" // Safra

		oService:listar(nPage, nPageSize, cParams)

	Case cEntidade == "5" // Cultura

		oService:listar(nPage, nPageSize, cParams)

	Case cEntidade == "6" // Totalizadores

		oService:listarMovimentosFiscais(nPage, nPageSize, cParams)

	Case cEntidade == "7" // Notas Fiscais V2

		oService:findBillingInvoiceData(nPage, nPageSize, cParams)

	Case cEntidade == "8" // Produtos

		oService:findProducts(nPage, nPageSize, cParams)

	Case cEntidade == "9" // Municipios

		oService:listCities(nPage, nPageSize, cParams)

	Case cEntidade == "A" // Estoque V2

		oService:findStockPosition(nPage, nPageSize, cParams)

	Case cEntidade == "B" // Pedidos

		oService:listarPedidos(nPage, nPageSize, cParams)

	Case cEntidade == "C" // Vendedores

		oService:listSalesman(nPage, nPageSize, cParams)

	Case cEntidade == "D" // Filiais

		If ValType(cParams) == "J"
			cFabricanteID := IIf(cParams:HasProperty("fabricanteID"),cParams["fabricanteID"],"")
			cCodiRev      := IIf(cParams:HasProperty("filial"),cParams["filial"],"")
		EndIf

		oService:listBranchData(cCodiRev,cFabricanteID)

	EndCase

Return oService:getResponse()



