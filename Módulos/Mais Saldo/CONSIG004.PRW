#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "fileio.ch"
#INCLUDE "CONSIG004.CH"

#DEFINE nPageDef    	1
#DEFINE nPageSizeDef    100000
#DEFINE cCurrentMonth   ALLTRIM(STR(MONTH(DATE())))
#DEFINE cCurrentYear    ALLTRIM(STR(YEAR(DATE())))


/*/{Protheus.doc} function CONSIG004
Integra lote de saldos devedores de empréstimos consignados com o PRT
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Function CONSIG004()
	Private aItemsNOK    := {}
	Private aItemsOK     := {}
	Private cPD 		 := ""
	Private lPerIsValid  := .T.

	Private oParams  	 := JsonObject():New()
	Private oBatches  	 := JsonObject():New()

	// Controle de validação do retorno de sucesso/erro/warnings da rotina GPEA580.
	Private aLog		    := {}
	Private lExecAutoError	:= .F.
	Private lMsErrorAuto	:= .F.
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile  := .T.	// Se ativada retorna no log através do GetAutoGRLog. Se desativada, grava em disco.

	If !GetMv("MV_CONSIG", .F., .F.)
		Aviso(STR0029, STR0030, { "Ok" }, 3) // STR0029: "Aviso Integração" e STR0030: "Para utilizar essa rotina é necessário ativar a chave do TOTVS Consignado."
		Return
	EndIf

	oParams['month']  := cCurrentMonth
	oParams['month'] := setMonth(oParams['month'])
	oParams['year']   := cCurrentYear
	oBatches = fDebitBalanceBatch()
	fMakeScreen(oBatches)
Return


/*/{Protheus.doc} function setMonth
Ajusta tamanho do mês
@author  hugo.de.oliveira
@since   24/01/2023
@version 1.0
/*/
Static Function setMonth(cMonth)
	cMonth := AllTrim(cMonth)
	
	If(len(cMonth) < 2 )
		cMonth := "0" + cMonth
	EndIf
Return cMonth


/*/{Protheus.doc} function fSetBatchDesc
Seta as Descrições do ComboBox de Lotes
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fSetBatchDesc(oBatchInteg)
	Local nX 	 := 1
	Local aItems := {}

	DEFAULT oBatchInteg := JsonObject():New()

	If (len(oBatchInteg['items']) > 0)
		For nX := 1 To len(oBatchInteg['items'])
			aadd(aItems, DecodeUTF8(oBatchInteg['items'][nX]['description']))
		Next nX
	Else
		aItems := {""}
	EndIf
Return aItems


/*/{Protheus.doc} function fMakeScreen
Realiza a montagem da tela de Consulta Lotes de Saldos Devedores.
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fMakeScreen(oBatches)
	Local nGrpTop 		:= 010
	Local nGrpLeft 		:= 010
	Local nGrpLeftItem  := nGrpLeft + 10
	Local nGrpWidth		:= 350
	Local nGrpHeight	:= 90
	Local nWidthSay   	:= 30
	Local nHeightSay  	:= 30
	Local aItems 		:= {}
	
	aItems := fSetBatchDesc(oBatches)

	// Montagem da Tela
	Private oDialog	 	 := MSDialog():Create(GetWndDefault())
	oDialog:cName 	 	 := "oDialog"
	oDialog:cCaption 	 := STR0001 //"Importação saldo devedor TOTVS Consignado"
	oDialog:nTop 	 	 := 150
	oDialog:nLeft 	 	 := 180
	oDialog:nWidth 	 	 := 370
	oDialog:nHeight  	 := 280

	Private grpPeriod  	 := TGroup():Create(oDialog)
	grpPeriod:nTop 	   	 := nGrpTop
	grpPeriod:nLeft    	 := nGrpLeft
	grpPeriod:nWidth   	 := nGrpWidth
	grpPeriod:nHeight  	 := nGrpHeight
	grpPeriod:cCaption 	 := STR0002 // "Competência"

	Private oMonthSay 	 := TSay():Create(grpPeriod)
	oMonthSay:nTop 		 := nGrpTop + 20
	oMonthSay:nLeft 	 := nGrpLeftItem
	oMonthSay:nWidth 	 := nWidthSay
	oMonthSay:nHeight 	 := nHeightSay
	oMonthSay:cCaption 	 := STR0003 //"Mês"
	
	Private oGetMonth 	 := TGet():Create(grpPeriod)
	oGetMonth:nTop 		 := nGrpTop + 40
	oGetMonth:nLeft 	 := nGrpLeftItem
	oGetMonth:nWidth 	 := 30
	oGetMonth:nHeight 	 := nHeightSay
	oGetMonth:cPlaceHold := oParams['month']
	oGetMonth:lReadOnly  := .F.
	oGetMonth:Picture 	 := "@E 99"
	oGetMonth:bSetGet    := {|u| If(PCount()>0, fSetPeriod(u), oParams['month']) }
	
	Private oYearSay 	:= TSay():Create(grpPeriod)
	oYearSay:nTop 		:= nGrpTop + 20
	oYearSay:nLeft 		:= nGrpLeftItem + 35
	oYearSay:nWidth 	:= nWidthSay
	oYearSay:nHeight 	:= nHeightSay
	oYearSay:cCaption 	:= STR0004 //"Ano"

	Private oGetYear 	:= TGet():Create(grpPeriod)
	oGetYear:nTop 		:= nGrpTop + 40
	oGetYear:nLeft 		:= nGrpLeftItem + 35
	oGetYear:nWidth 	:= 40
	oGetYear:nHeight 	:= nHeightSay
	oGetYear:cPlaceHold := oParams['year']
	oGetYear:lReadOnly 	:= .F.
	oGetYear:Picture 	:= "@E 9999"
	oGetYear:bSetGet    := {|u| If(PCount()>0, fSetPeriod(u, "year"), oParams['year']) }

	Private btnSearch	:= TButton():Create(grpPeriod)
	btnSearch:nTop 		:= nGrpTop + 40
	btnSearch:nLeft 	:= nGrpLeftItem + 80
	btnSearch:nWidth 	:= 050
	btnSearch:nHeight 	:= nHeightSay
	btnSearch:cCaption 	:= STR0005 // Buscar
	btnSearch:bAction   := {|| fSearch() }

	Private grpBatch  := TGroup():Create(oDialog)
	grpBatch:nTop 	  := nGrpTop  + 100
	grpBatch:nLeft 	  := nGrpLeft
	grpBatch:nWidth   := nGrpWidth
	grpBatch:nHeight  := nGrpHeight - 10
	grpBatch:cCaption := STR0006 // "Lote"
	
	Private oCombo 	  := TComboBox():New(NIL, NIL, NIL, aItems, NIL, NIL, grpBatch)
	oCombo:nTop 	  := nGrpTop  + 130
	oCombo:nLeft 	  := nGrpLeftItem
	oCombo:nWidth 	  := 300
	oCombo:nHeight 	  := 30
	oCombo:lReadOnly  := .F.
	
	// Ações
	Private btnCancel	:= TButton():Create(oDialog)
	btnCancel:nTop 		:= nGrpTop + 200
	btnCancel:nLeft 	:= 250
	btnCancel:nWidth 	:= 050
	btnCancel:nHeight 	:= nHeightSay
	btnCancel:cCaption 	:= STR0007 // Cancelar
	btnCancel:bAction   := {|| oDialog:End() }

	Private btnImport	:= TButton():Create(oDialog)
	btnImport:nTop 		:= nGrpTop + 200
	btnImport:nLeft 	:= 310
	btnImport:nWidth 	:= 050
	btnImport:nHeight 	:= nHeightSay
	btnImport:cCaption 	:= STR0008 // Importar
	btnImport:bAction   := {|| fImport() }

	ACTIVATE DIALOG oDialog CENTERED
Return


/*/{Protheus.doc} function fSetPeriod
Valida e seta os valores do Período selecionado
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fSetPeriod(cValue, cField)
	DEFAULT cField := "month"
	DEFAULT cValue := ""

	cValue := setMonth(cValue)

	If (cField == "month" .AND. (VAL(cValue) < 1 .OR. VAL(cValue) > 12))
		lPerIsValid  := .F.
		MsgAlert(STR0009, STR0010) // STR0009: "O mês deve ser um número válido entre 1 e 12.". STR0010: "Atenção"
		fClear()
		Return cValue
		
	ElseIf (cField == "year" .AND. (VAL(cValue) < VAL(cCurrentYear)))
		lPerIsValid  := .F.
		MsgAlert(STR0011, STR0010) // STR0011: "O ano deve ser igual ou maior que o ano corrente.". STR0010: "Atenção"
		fClear()
		Return cValue
	EndIf
	
	lPerIsValid  := .T.
	oParams[cField] := ALLTRIM(cValue)
Return cValue


/*/{Protheus.doc} function fImport
Realiza a importação dos Registros do Lote
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fImport()
	Local nPos 		  := 1
	Local nX 		  := 1
	Local aRegCode    := {}
	Local oItemFull   := JsonObject():New()
	Local oBatchItems := JsonObject():New()

	If (VALTYPE(oBatches) == "U" .OR. LEN(oBatches['items']) == 0)
		MsgAlert(STR0012, STR0010) // STR0012: "É necessário selecionar 1 Lote para realizar a Importação.". STR0010: "Atenção"
		Return
	EndIf

	nPos := MAX(nPos, oCombo:nAt)
	oBatchItems := fGetItemBatch(oBatches['items'][nPos]['id'])

	For nX := 1 To len(oBatchItems['items'])
		oItemFull := fSetProps(oBatchItems['items'][nX]) // Complementa objeto com demais propriedades necessárias dos items
		fValidItem(oItemFull) // Valida os items válidos e não válidos de acordo com as propriedades coletadas
	Next nX

	aRegCode := fFormatToSave()
	fSaveInstallment(aRegCode)	// Chama gravação (GPEA580) para os registros válidos
	fCheckImported() // Verifica o que foi lançado na RGB
	fCreateLog(aRegCode)
	oDialog:End()
Return


/*/{Protheus.doc} function fValidItem
Valida e separa Items que serão processados dos que não serão.
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fValidItem(oItem)
	Local lOpenPeriod := oItem['periodoAtivo'] == "1"
	Local lActivePeriod := oItem['periodoStatus'] != "5"

	// Verificar se funcionário está na mesma filial logada
	If(Empty(oItem['codigoFilial']))
		oItem['cReasonNOK'] := STR0014 //"Funcionário pertence a outro Grupo de Empresas"
		aadd(aItemsNOK, oItem)
	
	ElseIf (Empty(oItem['verba']))
		oItem['cReasonNOK'] := STR0013 // STR0013: "É necessário realizar o cadastro da verba de Rescisão, na tabela S137 (Verbas - Empréstimo Consignado), para lançamentos a serem importados"
		aadd(aItemsNOK, oItem)

	ElseIf (!lOpenPeriod .OR. !lActivePeriod)
		oItem['cReasonNOK'] := STR0031 + oItem['periodo'] +  STR0032 + oItem['codigoFilial'] + "'" // STR0031: "O Período '", STR0032: "' não se encontra aberto para a filial '"
		aadd(aItemsNOK, oItem)
	
	ElseIf Empty(oItem['centroDeCusto'])
		oItem['cReasonNOK'] := STR0033 + oItem['matricula'] + "'" // STR0033: "O Centro de Custo não foi encontrado para a matrícula '"
		aadd(aItemsNOK, oItem)

	Else
		aadd(aItemsOK, oItem)
	EndIf
Return


/*/{Protheus.doc} function fGetRegCode
Verifica se CNPJ pertence ao mesmo Grupo de Empresas Logado.
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fGetRegCode(cCNPJ)
	Local nY   := 1
	Local cRet := ""
	Local aSM0 := {}

	DEFAULT cCNPJ := ""

	If(!Empty(cCNPJ))
		aSM0 := FWLoadSM0()

		For nY := 1 To Len(aSM0)
			If AllTrim(aSM0[nY][1]) == cEmpAnt .AND. AllTrim(aSM0[nY][18]) == cCNPJ
				cRet := aSM0[nY][2] // Código filial ("D MG 01 ").
				Exit
			EndIf
		Next nY
	EndIf
Return cRet


/*/{Protheus.doc} function fFormatToSave
Seta as Propriedades esperadas pela rotina GPEA580
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static function fFormatToSave()
	Local nX 		  := 1
	Local nRegCodePos := 0
	Local aHeader 	  := {}
	Local aItens      := {}
	Local aRegCode 	  := {}

	For nX := 1 TO len(aItemsOK)
		aHeader := {}
		aItens 	:= {}
		// Adiciona novo item
		aadd(aItens, fMakeItem(aItemsOK[nX]))

		// Cria novo header somente se funcionário ainda não foi adicionado no aRegCode
		If !Empty(aRegCode)
			nRegCodePos := fPosMatEnc(aItemsOK[nX]['matricula'], aRegCode)
		EndIf
		
		If nRegCodePos == 0
			aadd(aHeader, fMakeHeader(aItemsOK[nX]))
			aadd(aRegCode, { aHeader, aItens })
		Else
			aadd(aRegCode[nRegCodePos][2], aItens[1])
		EndIf
	Next nX
Return aRegCode


/*/{Protheus.doc} function fSetProps
Seta as Propriedades esperadas pela rotina GPEA580
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fSetProps(oItem)
	Local oItemFull   				:= JsonObject():New()

	oItemFull['codigoFilial'] 		:= fGetRegCode(oItem['cnpj']) 
	oItemFull['processo'] 			:= fConsFunc(oItemFull['codigoFilial'], oItem['registrationCode'], "RA_PROCES")
	oItemFull['cpf'] 				:= fConsFunc(oItemFull['codigoFilial'], oItem['registrationCode'], "RA_CIC")
	oItemFull['centroDeCusto']  	:= fConsFunc(oItemFull['codigoFilial'], oItem['registrationCode'], "RA_CC")
	oItemFull['codFuncionario'] 	:= fConsFunc(oItemFull['codigoFilial'], oItem['registrationCode'], "RA_CODFUNC")

	oItemFull['matricula'] 			:= fAjustTam("RA_MAT", oItem['registrationCode'])
	oItemFull['cnpj'] 				:= oItem['cnpj']
	oItemFull['valorParcela']		:= ALLTRIM(STR(oItem['totalAmountToPay']))

	oItemFull['periodo'] 		  	:= oParams['year'] + oParams['month']
	oItemFull['semana'] 		  	:= fConsCabPer(oItemFull['codigoFilial'], oItemFull['processo'], oParams['year'], oParams['month'], "RCF_SEMANA")
	oItemFull['periodoStatus']		:= fConsPer(oItemFull['codigoFilial'], oItemFull['processo'], oItemFull['periodo'], "RCH_STATUS")
	oItemFull['periodoAtivo'] 		:= fConsPer(oItemFull['codigoFilial'], oItemFull['processo'], oItemFull['periodo'], "RCH_PERSEL")
	oItemFull['dtPgtoPeriodo']		:= fConsPer(oItemFull['codigoFilial'], oItemFull['processo'], oItemFull['periodo'], "RCH_DTPAGO")

	oItemFull['verba']				:= fGetS137Pd(oItemFull['codigoFilial'], oItem['partnerCode'])
	oItemFull['tipoVerba']			:= fConsVerba(oItemFull['codigoFilial'], oItemFull['verba'], "RV_TIPO")

	oItemFull['roteiro'] 		  	:= "RES"
	oItemFull['tipoInsercao']		:= "G" // Usado por rotinas automáticas, como no GPEA580
	oItemFull['idParcela'] 	 		:= ""
Return oItemFull


/*/{Protheus.doc} function fSearch()
Realiza a importação dos Registros do Lote
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fSearch()
	Local aItems := {}

	If (!lPerIsValid)
		fClear()
		MsgAlert(STR0016, STR0010) // STR0016: "Ajuste o Mês e Ano para valores válidos.". STR0010: "Atenção"
		Return
	EndIf

	oBatches = fDebitBalanceBatch()
	aItems := fSetBatchDesc(oBatches)
	oCombo:SetItems(aItems)
Return


/*/{Protheus.doc} function fDebitBalanceBatch
Consulta Lotes de Saldos Devedores da Filial logada de acordo com o período informado.
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fDebitBalanceBatch()
	Local oInteg
	Local cRacToken := ""
	Local aHeader   := {}
	Local oBatches  := JsonObject():New()
	Local cEndPoint := fGetURLCsg()

	oInteg    := FwRest():New(cEndPoint + "/api/erp/v1/debit-balance-batches-by-period")
	cRacToken := fConsTKConsig()

	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	aAdd(aHeader, "Authorization: Bearer " + cRacToken)

	oInteg:setPath("?month=" + oParams['month'] + "&year=" + oParams['year'])

	If oInteg:Get(aHeader)
		If oInteg:ORESPONSEH:CSTATUSCODE == "200" .AND. !Empty(oInteg:GetResult())
			oBatches:FromJson(oInteg:GetResult())
		EndIf
	EndIf
Return oBatches


/*/{Protheus.doc} function fGetItemBatch
Consulta Items dos Lotes de Saldos Devedores de acordo com o Id do Lote informado.
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fGetItemBatch(cBatchId)
	Local oInteg
	Local cRacToken   := ""
	Local aHeader     := {}
	Local cEndPoint	  := fGetURLCsg()
	Local oBatchItems := JsonObject():New()

	DEFAULT cBatchId := ""

	oInteg    := FwRest():New(cEndPoint + "/api/erp/v1/debit-balance-registrations")
	cRacToken := fConsTKConsig()

	aAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
	aAdd(aHeader, "Authorization: Bearer " + cRacToken)

	oInteg:setPath("?debitBalanceBatchId=" + cBatchId)

	If oInteg:Get(aHeader)
		If oInteg:ORESPONSEH:CSTATUSCODE == "200" .AND. !Empty(oInteg:GetResult())
			oBatchItems:FromJson(oInteg:GetResult())
		EndIf
	EndIf
Return oBatchItems


/*/{Protheus.doc} function fCreateLog
Cria principal para criação do log
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fCreateLog(aRegCode)
	Local nAux	 	 := 1
	Local aTitle 	 := {}

	DEFAULT aRegCode := {}

	aTitle := fCreateHeader(nAux, aTitle)
	aTitle := fCreateLine(nAux, aTitle)
	
	fMakeLog(aLog,  ; // Array que contem os Detalhes de Ocorrencia de Log
			aTitle, ; // Array que contem os Titulos de Acordo com as Ocorrencias
			NIL,	; // Pergunte a Ser Listado
			NIL,	; // Se Havera "Display" de Tela
			"CONSIG004" + DTOS(dDataBase), ; // Nome Alternativo do Log
			STR0017, ; // "Log de Ocorrencias - Importação de Lote de Saldo Devedor - TOTVS Consignado"
			"M", 	; // Tamanho Vertical do Relatorio de Log ("P","M","G")
			"P",	; // Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
			NIL,	; //Array com a Mesma Estrutura do retorno
			.F.,	; // Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
			NIL     ; // Array com as perguntas selecionadas
			)
	aLog := {}
Return


/*/{Protheus.doc} function fCreateHeader
Cria o cabeçalho do log
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fCreateHeader(nAux, aTitle)
	DEFAULT nAux   := 1
	DEFAULT aTitle := {}

	aAdd(aTitle, STR0018) // "Importação de Lançamentos por Funcionário"
	aAdd(aLog, {})
	aAdd(aLog[nAux], STR0019 + ": " + STR0020) // "Destino" e "Lançamentos Mensais"
	aAdd(aLog[nAux], STR0021 + ": " + "RES") // "Roteiro"
	aAdd(aLog[nAux], STR0022 + ": " + oParams['year'] + oParams['month']) // "Período"
	aAdd(aLog[nAux], STR0023 + ": " + IIF(Len(aItemsOK) > 0, aItemsOK[1]['verba'], "")) // "Verba"
	aAdd(aLog[nAux], STR0024 + ": " + ALLTRIM(STR(Len(aItemsOK)))) // "Total de Funcionários Importados"
	aAdd(aLog[nAux], STR0025 + ": " + ALLTRIM(STR(Len(aItemsNOK)))) // "Total de Funcionários Não Importados"
Return aTitle


/*/{Protheus.doc} function fCreateLine
Cria as linhas do log
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fCreateLine(nAux, aTitle)
	Local nX 		 := 1
	Local nY 		 := 1
	Local aLogDetail := {}
	Local cDefColumn := STR0034 + fGetSpace("matricula", "") + ; // STR0034: "Mat."
								  STR0035 + fGetSpace("cpf", "") + ; // STR0035: "CPF"
								  STR0036 + fGetSpace("cnpj", "") + ; // STR0036: "CNPJ"
								  STR0037 + fGetSpace("valor", "") // STR0037: "Valor"
	DEFAULT nAux 	 := 1
	DEFAULT aTitle 	 := {}
	DEFAULT aRegCode := {}

	If len(aItemsOK) > 0
		nAux ++
		aAdd(aLog, {})
		aAdd(aTitle, STR0026 +"("+ALLTRIM(STR(Len(aItemsOK)))+"): ") // "Funcionários Importados:"
		aAdd(aLog[nAux], cDefColumn)
		aAdd(aLog[nAux], replicate("-",130))
		fCreateColumn(nAux, aItemsOK)
	EndIf

	If len(aItemsNOK) > 0
		nAux ++
		aAdd(aLog, {})
		aAdd(aTitle , STR0027+"("+ALLTRIM(STR(Len(aItemsNOK)))+"): ") // "Funcionários Não Importados"
		aAdd(aLog[nAux], cDefColumn + STR0038) // STR0038: "Motivo"
		aAdd(aLog[nAux], replicate("-",130))
		fCreateColumn(nAux, aItemsNOK, .T.)
	EndIf

	// Preenche informações complementares do processamento do Log
	aLogDetail := fGetLogDetail()
	If len(aLogDetail) > 0
		nAux ++
		aAdd(aLog, {})
		aAdd(aTitle , STR0028) // "Informações complementares"
		For nX := 1 to len(aLogDetail)
			For nY := 1 to len(aLogDetail[nX])
				aAdd(aLog[nAux], aLogDetail[nX][nY])
			Next nY
		Next nX
	EndIf
Return aTitle


/*/{Protheus.doc} function fCreateColumn
Cria as colunas do log
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fCreateColumn(nAux, aItems, lNotOk)
	Local cReasonNOK := ""
	Local nX 		 := 1

	DEFAULT nAux   := 1
	DEFAULT aItems := {}
	DEFAULT lNotOk := .F.

	For nX := 1 to Len(aItems)
		cReasonNOK  := IIF(lNotOk, aItems[nX]['cReasonNOK'], cReasonNOK)

		aAdd(aLog[nAux], aItems[nX]['matricula'] + fGetSpace("matricula", aItems[nX]['matricula']) + ;
						 aItems[nX]['cpf'] + fGetSpace("cpf", aItems[nX]['cpf']) + ;
						 aItems[nX]['cnpj'] + fGetSpace("cnpj", aItems[nX]['cnpj']) + ;
						 aItems[nX]['valorParcela'] + fGetSpace("valor", aItems[nX]['valorParcela']) + ;
						 cReasonNOK) // Motivo de não ter Importado
	Next nX
Return


/*/{Protheus.doc} function fGetSpace
Cria tamanho do espaçamento das colunas das linha de acordo com o tamanho de cada campo
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fGetSpace(cLabel, cValue)
	Local cReturn := ""
	Local nWhiteSpc := 4
	Local nMatDef := IIF(cValue == "", 6, nWhiteSpc + 6)
	Local nCPFDef := IIF(cValue == "", 13, nWhiteSpc + 12)
	Local nCNPJDef := IIF(cValue == "", 14, nWhiteSpc + 14)
	Local nTotalDef := IIF(cValue == "", 6, nWhiteSpc + 7)
	
	DEFAULT cLabel := ""
	DEFAULT cValue := ""

	If (cLabel == "matricula")
		cReturn := Space(nMatDef - Len(cValue))

	ElseIf (cLabel == "cpf")
		cReturn := Space(nCPFDef - Len(cValue))

	ElseIf (cLabel == "cnpj")
		cReturn := Space(nCNPJDef - Len(cValue))

	ElseIf (cLabel == "valor")
		cReturn := Space(nTotalDef - Len(cValue))
	EndIf
Return cReturn


/*/{Protheus.doc} function fClear
Limpa Objetos principais da tela.
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fClear()
	oCombo:SetItems({""})
	FreeObj(oBatches)
Return


/*/{Protheus.doc} function fCheckImported
Verifica quais items foram importados após execução do GPEA580.
@author  hugo.de.oliveira
@since   10/11/2022
@version 1.0
/*/
Static Function fCheckImported()
	Local nX 		:= 1
	Local cKeyRGB 	:= ""
	Local aItemsImp := {}
	Local lImported := .F.
	Local aArea 	:= GetArea()

	For nX := 1 To len(aItemsOK)
		cKeyRGB := xFilial(("RGB"), aItemsOK[nX]['codigoFilial']) + aItemsOK[nX]['matricula'] + aItemsOK[nX]['verba'] + aItemsOK[nX]['periodo']

		RGB->(DbSetOrder(1)) // RGB_FILIAL, RGB_MAT, RGB_PD, RGB_PERIOD

		lImported := .F.
		If RGB->(dbSeek(cKeyRGB))
			While RGB->(!Eof() .and. RGB_FILIAL + RGB_MAT + RGB_PD + RGB_PERIOD == cKeyRGB)
				If (RGB->RGB_FILIAL + RGB->RGB_MAT + RGB->RGB_PD + RGB->RGB_PERIOD + AllTrim((STR(RGB->RGB_VALOR)))) == (cKeyRGB + aItemsOK[nX]['valorParcela'])
					lImported := .T.
					Aadd(aItemsImp, aItemsOK[nX])
					Exit
				EndIf
				RGB->(dbSkip())
			EndDo
		EndIf

		If (!lImported .AND. lMsErroAuto)
			Aadd(aItemsNOK, aItemsOK[nX])
			aItemsNOK[Len(aItemsNOK)]['cReasonNOK'] := STR0039 + STR0028 // STR0039: "Regra de negócio da Folha, verificar ", STR0028: "Informações complementares"
		EndIf

		RestArea(aArea)
	Next nX

	aItemsOK := aItemsImp
Return
