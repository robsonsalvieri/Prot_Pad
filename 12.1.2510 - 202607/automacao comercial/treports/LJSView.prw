#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LJSVIEW.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} LjSView
Funções genéricas de integração Varejo e Smart View.

@author Jorge Martins
@since  28/03/2025
@obs    Dummy Function
/*/
//-------------------------------------------------------------------
Function LjSView()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSVOpc
Função para montar um menu para selecionar qual tipo de relatório
que será gerado

@param lTRepOld   , Indica se a opção de relatório em TReports (versão antiga) será exibida para seleção
@param lReport    , Indica se a opção de relatório em SV será exibida para seleção
@param lDataGrid  , Indica se a opção de visão de dados em SV será exibida para seleção
@param lPivotTable, Indica se a opção de tabela dinâmica em SV será exibida para seleção
@param cNome      , Nome do relatório na versão nova (SV)
@param cNomeOld   , Nome do relatório na versão antiga (TReports). Necessário pois em alguns casos o relatório trocou de nome

@author  Jorge Martins
@since   28/03/2025
/*/
//-------------------------------------------------------------------
Function LJSVOpc(lTRepOld, lReport, lDataGrid, lPivotTable, cNome, cNomeOld)
Local oModalDlg as object
Local aList as array
Local aFields as array
Local oColumn as object
Local oList as object
Local nType as numeric

Default cNome    := ""
Default cNomeOld := ""

	oModalDlg := FWDialogModal():New()
	oModalDlg:setSize(150, 300)
	oModalDlg:SetTitle(STR0001) // "Escolha o recurso para execução"
	oModalDlg:SetEscClose(.T.)
	oModalDlg:CreateDialog()

	//-------------------------------------------------------------------
	// Campos utilizados
	//-------------------------------------------------------------------
	aFields := {}
	Aadd( aFields, {STR0002, STR0002, "C", 200, 0, ""} ) // "Descrição" ### "Descrição"
	Aadd( aFields, {STR0003, STR0003, "C", 100, 0, ""} ) // "Código" ### "Código"

	aList := {}
	IIf( lTRepOld,    Aadd( aList, {I18N(STR0004, {cNomeOld}), STR0005 }), Nil) // "Relatório de #1" ## "Versão TReport"
	IIf( lReport,     Aadd( aList, {I18N(STR0004, {cNome})   , STR0006 }), Nil) // "Relatório de #1" ## "Versão Smart View"
	IIf( lDataGrid,   Aadd( aList, {I18N(STR0007, {cNome})   , STR0006 }), Nil) // "Visão de dados de #1" ## "Versão Smart View"
	IIf( lPivotTable, Aadd( aList, {I18N(STR0008, {cNome})   , STR0006 }), Nil) // "Tabela dinâmica de #1" ## "Versão Smart View"

	oList := FWBrowse():New(oModalDlg:GetPanelMain())
	oList:SetDataArray(.T.)
	oList:SetArray(aList)
	oList:DisableConfig()
	oList:DisableReport()
	oList:SetFieldFilter(aFields)
	oList:SetOwner(oModalDlg:GetPanelMain())

	oColumn := FWBrwColumn():New(); oColumn:SetData({||aList[oList:At()][1]}); oColumn:SetTitle(STR0002); oColumn:SetSize(035); oList:SetColumns({oColumn}) // "Descrição"
	oColumn := FWBrwColumn():New(); oColumn:SetData({||aList[oList:At()][2]}); oColumn:SetTitle(STR0009); oColumn:SetSize(015); oList:SetColumns({oColumn}) // "Formato"

	ACTIVATE FWBROWSE oList

	oList:SetDoubleClick( {|| nType := oList:At(), oModalDlg:Deactivate(), oList:DeActivate() } )

	oModalDlg:AddOkButton( {|| nType := oList:At(), oModalDlg:Deactivate(), oList:DeActivate() }, STR0010) // "Confirmar"
	oModalDlg:AddCloseButton( {|| nType := -1, oModalDlg:Deactivate(), oList:DeActivate() }, STR0011) // "Fechar"
	oModalDlg:Activate()

Return nType

//-------------------------------------------------------------------
/*/{Protheus.doc} LJSVBind
Função para substituição dos valores da query que usam BIND

@param cQuery, Query original sem bind para substituição de valores
@param aBind , Valores para utilização na query

@Return cQuery, Query com as substituição de valores

@author  Jorge Martins
@since   28/03/2025
/*/
//-------------------------------------------------------------------
Function LJSVBind(cQuery, aBind)
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
			ElseIf aBind[nI][2] == "U" // Tipo Unsafe
				oStatement:SetUnsafe(nI, aBind[nI][1])
			ElseIf aBind[nI][2] == "I" // Tipo In
				oStatement:SetIn(nI, aBind[nI][1])
			Else // Tipo Numérico
				oStatement:SetNumeric(nI, aBind[nI][1])
			EndIf
		Next nI
		cQuery := oStatement:GetFixQuery()
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*{Protheus.doc} LJSVMultiSel
Faz o tratamento das consultas com multiseleção

@param aMultiSel, Registros selecionados
@param cCampo   , Campo referência para ajuste de tamanho do conteúdo

@return aDados, Dados tratados

@author Jorge Martins
@since  28/03/2025
*/
//-------------------------------------------------------------------
Function LJSVMultiSel(aMultiSel, cCampo)
Local aDados := {} as array
Local nMulti := 0  as numeric

	If Len(aMultiSel) == 0 // Multiselect sem valor preenchido
		aAdd(aDados, "")
	Else // Multiselect com um ou mais valores preenchidos
		For nMulti := 1 To Len(aMultiSel)
			aAdd(aDados, AvKey(aMultiSel[nMulti], cCampo))
		Next
	EndIf

Return aDados
