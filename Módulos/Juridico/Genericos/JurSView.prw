#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'JURSVIEW.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JurSView
Funções de integração Jurídico e Smart View.

@author Jonatas Martins
@since  01/03/2023
@obs    Dummy Function
/*/
//-------------------------------------------------------------------
Function JurSView()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTRepStruct
Função para montar o array com as propriedades dos campos utilizados
no relatório. Esse array será utilizado no método "addProperty" no
método "getSchema()" do objeto de negócio.

@author Jonatas Martins
@since  01/03/2023
/*/
//-------------------------------------------------------------------
Function JurTRepStruct(aCpos)
Local aDeParaCpo := {{"C", "string"}, {"D", "date"}, {"M", "memo"}, {"N", "number"}, {"L", "boolean"}}
Local aCpoTmp    := {}
Local cCampo     := ""
Local cCpoQry    := ""
Local cCpoAlias  := ""
Local cTipR      := ""
Local nPos       := 0
Local nLin       := 0

	Default aCpos := {}

	For nLin := 1 to Len(aCpos)
		cCpoQry   := aCpos[nLin][1]
		nPos      := AT(".", aCpos[nLin][1])
		cCampo    := IIF(nPos > 0, Substr(cCpoQry, nPos + 1), cCpoQry)
		cTipo     := GetSx3Cache(cCampo, "X3_TIPO")
		nPos      := aScan(aDeParaCpo, {|x| x[1] = cTipo})
		cTipR     := IIF(nPos > 0, aDeParaCpo[nPos, 2], "string")
		cCpoAlias := IIF(!Empty(aCpos[nLin][2]), aCpos[nLin][2], cCampo)

	AAdd(aCpoTmp, {lower(cCpoAlias), Iif(nPos == 0, "", FWSX3Util():GetDescription(cCampo)), cTipR, cCpoAlias, cCpoQry, "", .F., cCpoAlias})
	Next nLin

Return (aCpoTmp)

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTRepCall
Função para execução de relatório no Smart View.

@param cIdProt    , parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)
@param cType      , parâmetro = Tipo do relatório ("report" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)
@param nPrintType , parâmetro = Tipo de impressão (1 = Arquivo, 2 = E-mail) (Somente se for JOB)
@param aRepParam  , Parâmetros do relatório. Exemplo: {{'pCodFatura', '000000898'}, {'pCodEscr', 'SP001'}} (Somente quando não for nativo SX1)
@param lRunJob    , Indica se irá executar em job
@param lShowParams, Indica se irá mostrar a tela de parâmetros (se for geração em job esse parâmetro sempre é .F.)
@param lWizard    , Se verdadeiro indica se exibe o wizard de configuração do Smart View, caso o ambiente não esteja preparado
@param cError     , Indica o erro na execução [referência]
@param cPath      , Diretório para salvar o relatório (somente para JOB)
@param cExtension , Extenção do arquivo (somente para JOB)
@param cMails     , Endereço do destinátario quando o tipo de impressão for igual a 2 = E-mail (somente para JOB)
@param jParams    , Parâmetros do relatório enviado via API

@author Jonatas Martins
@since  01/03/2023
@obs    https://tdn.totvs.com/pages/releaseview.action?pageId=742218090
/*/
//-------------------------------------------------------------------
Function JurTRepCall(cIdProt, cType, nPrintType, aRepParam, lRunJob, lShowParams, lWizard, cError, cPath, cExtension, cMails, jParams)
Local lSuccess   As Logical
Local jPrintInfo As Json
Local nParam     As Numeric

	Default cIdProt     := ""  //1º parâmetro = Relatório cadastrado na tabela de De/Para (Campo TR__IDREL)
	Default cType       := ""  //2º parâmetro = Tipo do relatório ("report" = relatório, "data-grid" = visão de dados, "pivot-table" = tabela dinâmica)
	Default nPrintType  := 0   //3º parâmetro = Tipo de impressão (1 = Arquivo, 2 = E-mail) (Somente se for JOB)
	Default aRepParam   := {}  //4º Parâmetros do relatório - exemplo: {{'pCodFatura', '000000898'}, {'pCodEscr', 'SP001'}} (Somente quando não for nativo SX1)
	Default lRunJob     := .F. //5º Indica se irá executar em job
	Default lShowParams := .T. //6º Indica se irá mostrar a tela de parâmetros (se for geração em job esse parâmetro sempre é .F.)
	Default lWizard     := .F. //6º Se verdadeiro indica se exibe o wizard de configuração do Smart View, caso o ambiente não esteja preparado
	Default cError      := ""  //7º Indica o erro na execução [referência]
	Default cPath       := ""  //8º Diretório para salvar o relatório (somente para JOB)
	Default cExtension  := ""  //9º Extenção do arquivo (somente para JOB)
	Default cMails      := ""  //10º Endereço do destinátario quando o tipo de impressão for igual a 2 = E-mail (somente para JOB)
	Default jParams     := NIL //11 Parâmetro do relatório enviado via API

	If Alltrim(__FWLibVersion()) >= "20231009" .And. totvs.framework.smartview.util.isConfig() // Proteção
		// Configurações apenas para execução em JOB
		If lRunJob
			jPrintInfo := JsonObject():New()
			jPrintInfo['name'] := AllTrim(cIdProt) + FwTimeStamp() //Adicionado o timestamp para não ter conflito no nome do arquivo
			
			If !Empty(cExtension)
				jPrintInfo['extension'] := AllTrim(cExtension)
			EndIf
			
			If nPrintType == 1 .And. !Empty(cPath) // Diretório de saida
				jPrintInfo['path'] := AllTrim(cPath)
			EndIf

			If nPrintType == 2 .And. !Empty(cMails) // E-mail
				jPrintInfo['to'] := AllTrim(cMails) //Obrigatório setar o destinatário
			EndIf
			
			lShowParams := .F.
			lWizard     := .F.
		EndIf

		//Preencher os parâmetros do relatório somente quando não utilizar SX1 nativamente
		If !Empty(aRepParam)
			jParams := JsonObject():New()
			For nParam := 1 To Len(aRepParam)
				jParams[aRepParam[nParam][1]] := aRepParam[nParam][2]
			Next
		EndIf

		//1º Id do relatório que será impresso (relacionado ao nome do arquivo .trp)
		//2º Tipo de dado (report, pivot-table ou data-grid)
		//3º Tipo do impressão (Arquivo=1, Email=2)
		//4º Informações para a impressão do relatório
		//5º Parâmetros do relatório (Somente quando no for nativo do SX1)
		//6º Indica se irá executar em job
		//7º Indica se irá mostrar a tela de parâmetros (se for geração em job esse parâmetro sempre é .F.)
		//8º Indica se exibe o wizard de configuração do Smart View, caso o ambiente não esteja preparado
		//9º Indica o erro na execução [referência]
		lSuccess := totvs.framework.treports.callTReports(cIdProt, cType, nPrintType, jPrintInfo, jParams, lRunJob, lShowParams, lWizard, @cError)
		
		IIF(!lSuccess .And. !Empty(cError), JurMsgErro(STR0003,, STR0004 + "-" + cError), Nil) // "JurTRepCall - Erro na geração, verificar logs." # "Verifique as configurações."
	Else
		JurMsgErro(STR0005,, STR0006) // "Ambiente desatualizado!" # "Necessário versão da LIB igual ou superior a #1 e a configuração do Smart View no ambietne."
	EndIf

Return lSuccess

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTRepBox
Função para montar um menu para selecionar qual tipo de relatório
que será gerado

@author Joao Pedro
@since  30/10/2023
/*/
//-------------------------------------------------------------------

Function JurTRepBox(lReport, lDataGrid, lPivotTable, cNome)
Local oModalDlg as object
Local aList as array
Local aFields as array
Local oColumn as object
Local oList as object
Local nType as numeric

	oModalDlg := FWDialogModal():New()
	oModalDlg:setSize(150, 300)
	oModalDlg:SetTitle(STR0007) // "Smart View - Escolha o recurso para execução"
	oModalDlg:SetEscClose(.T.)
	oModalDlg:CreateDialog()

	//-------------------------------------------------------------------
	// Campos utilizados
	//-------------------------------------------------------------------
	aFields := {}
	Aadd( aFields, {STR0008, STR0008, "C", 200, 0, ""} ) // "Descrição" ### "Descrição"
	Aadd( aFields, {STR0009, STR0009, "C", 100, 0, ""} ) // "Código" ### "Código"

	aList := {}
	IIf( lReport,     Aadd( aList, {I18N(STR0010, {cNome}), "report"     }), Nil) // "Relatório de #1"
	IIf( lDataGrid,   Aadd( aList, {I18N(STR0011, {cNome}), "data-grid"  }), Nil) // "Visão de dados de #1"
	IIf( lPivotTable, Aadd( aList, {I18N(STR0012, {cNome}), "pivot-table"}), Nil) // "Tabela dinâmica de #1"

	oList := FWBrowse():New(oModalDlg:GetPanelMain())
	oList:SetDataArray(.T.)
	oList:SetArray(aList)
	oList:DisableConfig()
	oList:DisableReport()
	oList:SetFieldFilter(aFields)
	oList:SetOwner(oModalDlg:GetPanelMain())

	oColumn := FWBrwColumn():New(); oColumn:SetData({||aList[oList:At()][1]}); oColumn:SetTitle(STR0008); oColumn:SetSize(040); oList:SetColumns({oColumn}) // "Descrição"
	oColumn := FWBrwColumn():New(); oColumn:SetData({||aList[oList:At()][2]}); oColumn:SetTitle(STR0013); oColumn:SetSize(010); oList:SetColumns({oColumn}) // "Tipo"
	ACTIVATE FWBROWSE oList

	oList:SetDoubleClick( {|| nType := oList:At(), oModalDlg:Deactivate(), oList:DeActivate() } )

	oModalDlg:AddOkButton( {|| nType := oList:At(), oModalDlg:Deactivate(), oList:DeActivate() },STR0014 ) // "Confirmar"
	oModalDlg:AddCloseButton( {|| nType := -1, oModalDlg:Deactivate(), oList:DeActivate() }, STR0015) // "Fechar"
	oModalDlg:Activate()

Return nType


//-------------------------------------------------------------------
/*/{Protheus.doc} JurTRepVar
Função para trocar a váriavel de string para numérica

@param xValue, Valor do parâmetro rebido do Smart View
@param nVal  , Valor do parâmetro convertido para numérico

@author Joao Pedro
@since  30/10/2023
/*/
//-------------------------------------------------------------------
Function JurTRepVar(xValue)
Local nValue := 0

Default xValue := ""

	If !Empty(xValue)
		If ValType(xValue) == "C"
			nValue := Val(AllTrim(xValue))
		ElseIf ValType(xValue) == "N"
			nValue := xValue
		EndIf
	EndIf

Return nValue

//-------------------------------------------------------------------
/*/{Protheus.doc} JurTRepBin
Method de BIND para substituição dos valores da query

@param cQuery, Query original sem bind para substituição de valores
@param aBind , Valores para utilização na query

@Return cQuery, Query com as substituição de valores

@author  João Pedro
@since   13/11/2024
/*/
//-------------------------------------------------------------------
Function JurTRepBin(cQuery, aBind)
Local oStatement as Object
Local nQtd as Numeric
Local nI as Numeric

	nQtd := Len(aBind)
	If nQtd > 0
		oStatement := FWPreparedStatement():New()
		oStatement:SetQuery(cQuery)
		For nI := 1 To nQtd
			If aBind[nI][2] == "S" // Tipo String
				oStatement:SetString(nI, aBind[nI][1])
			ElseIf aBind[nI][2] == "U"
				oStatement:SetUnsafe(nI, aBind[nI][1])
			Else 
				oStatement:SetNumeric(nI, aBind[nI][1])
			EndIf
		Next nI
		cQuery := oStatement:GetFixQuery()
	EndIf

Return cQuery
