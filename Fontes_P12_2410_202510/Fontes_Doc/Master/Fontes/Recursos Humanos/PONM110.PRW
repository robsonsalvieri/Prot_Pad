#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "PONM110.CH"

/*/{Protheus.doc} PONM110
Interface para gestão de banco de horas
@type function
@author Cícero Alves
@since 28/03/2024
/*/
Function PONM110()
	
	Local oDlgPrinc
	Local oPanelDown
	Local oPanelUp
	
	Private cMark		:= GetMark()
	Private cAliasSRA 	:= GetNextAlias()
	Private oArqSRA
	Private lPerApont	:= .F.
	
	Static nMarcados	:= 0
	Static oBrowse		:= NIL
	Static lWenBtn 		:= .F.
	Static dBkpDtBase	:= dDataBase
	
	// Cria a tabela temporária 
	CriaTmpSRA(cAliasSRA)
	
	CriaTela(@oDlgPrinc, @oPanelUp, @oPanelDown)
	
	// Cria a buttonBar
	fBtn(@oPanelUp)
	
	// Cria o Browse com os funcionários
	FuncBrowse(@oPanelDown)
	
	oDlgPrinc:Activate()
	
	RestVars()
	
Return

/*/{Protheus.doc} CriaTela
Cria a dialog e os paines 
@type Static function
@author Cícero Alves
@since 28/03/204
@param oDlgPrinc, object, Instância da classe FWDialogModal - passado por referência
@param oPanelUp, object, painel para a barra de botões - passado por referência
@param oPanelDown, object, painel para o browse - passado por referência
/*/
Static Function CriaTela(oDlgPrinc, oPanelUp, oPanelDown)
	
	Local oPanel
	Local oTela
	Local cIdButtons
	Local cIdBrowse
	
	oDlgPrinc := FWDialogModal():New()       
	oDlgPrinc:SetEscClose(.T.)
	oDlgPrinc:setTitle(STR0001) // "Gestão de Banco de Horas"
	
	//Seta a largura e altura da janela em pixel
	oDlgPrinc:enableAllClient()
	oDlgPrinc:createDialog()
	
	oPanel := TPanel():New( ,,, oDlgPrinc:getPanelMain())
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	oTela := FWFormContainer():New( oPanel )
	
	cIdButtons := oTela:CreateHorizontalBox( 6 )
	cIdBrowse := oTela:CreateHorizontalBox( 94 )
	
	oTela:activate(oPanel, .F.)
	
	oPanelUp  	:= oTela:GeTPanel(cIdButtons)
	oPanelDown  := oTela:GeTPanel( cIdBrowse )
	
Return

/*/{Protheus.doc} fBtn
Cria os botões apresentados na tela
@type Static function
@author Cícero Alves
@since 28/03/2024
@param oPanel, object, painel onde os botões serão criados - passado por referência
/*/
Static Function fBtn(oPanel)
	
	Local oBtnAjuda		:= NIL
	Local oBtnFiltro	:= NIL
	Local oMenu			:= NIL
	
	Static oBtnLan		:= NIL
	Static oBtnCalc 	:= NIL
	Static oBtnFecha	:= NIL
	Static oBtnAbre		:= NIL
	Static oBtnRel		:= NIL
	Static oBtnMeses	:= NIL
	Static lMesesBH		:= NIL
	
	lMesesBH := If(lMesesBH == NIL, SPI->(ColumnPos("PI_MESESBH")) > 0, lMesesBH)
	
	oPanel:lShowHint := .T.
	
	// "Lançamentos"
	// "Abre a tela de lançamento de Banco de Horas para manutenção"
	oBtnLan := TButton():Create(oPanel,,, Space(6) + STR0076, {|| LancBH()}, 60, 20,,,, .T.,, STR0077)
	oBtnLan:SetCss(GetCSS(7))
	oBtnLan:Align := CONTROL_ALIGN_LEFT
	
	// "Cálculo"
	// "Atualiza os lançamentos do banco de horas com base nos apontamentos"
	oBtnCalc := TButton():Create(oPanel,,, Space(6) + STR0002, {|| CalcBH()}, 50, 20,,,, .T.,, STR0003,, {|| lWenBtn}) 
	oBtnCalc:SetCss(GetCSS(1))
	oBtnCalc:Align := CONTROL_ALIGN_LEFT
	
	// "Fechamento"
	// "Realiza o Fechamento do banco de horas gerando o saldo nos resultados"
	oBtnFecha := TButton():Create(oPanel,,, Space(6) + STR0004, {|| If(!lMesesBH, FechaBH(),)}, 60, 20,,,, .T.,, STR0005,, {|| lWenBtn})
	oBtnFecha:SetCSS(GetCSS(2))
	oBtnFecha:Align := CONTROL_ALIGN_LEFT
	
	If lMesesBH
		// Opções do botão fechamento
		oMenu := TMenu():New(0, 0, 0, 0, .T.)
		oMenu:Add(TMenuItem():New(oPanel, STR0080,,,, {|| FechaBHVen()},,,,,,,,,.T.)) // "Por Vencimento"
		oMenu:Add(TMenuItem():New(oPanel, STR0081,,,, {|| FechaBH()},,,,,,,,,.T.))	// "Por Período/Horas"
		oBtnFecha:SetPopupMenu(oMenu)
	EndIf
	
	// Reabertura
	// "Realiza a reabertura do banco de horas para o período aberto"
	oBtnAbre := TButton():Create(oPanel,,, Space(6) + STR0006, {|| AbreBH()}, 60, 20,,,, .T.,, STR0007,, {|| lWenBtn})
	oBtnAbre:SetCss(GetCSS(3))
	oBtnAbre:Align := CONTROL_ALIGN_LEFT
	
	If GetRpoRelease() >= "12.1.2210" .And. FWLibVersion() >= "20240226" 
		// "Extrato"
		// "Impressão do extrato do banco de horas - Smart View"
		oBtnRel := TButton():Create(oPanel,,, Space(6) + STR0008, {|| ImpBH()}, 50, 20,,,, .T.,, STR0009,, {|| lWenBtn})
		oBtnRel:SetCss(GetCSS(4))
		oBtnRel:Align := CONTROL_ALIGN_LEFT
	EndIf
	
	If lMesesBH
		// Vencimento
		// "Atualiza o meses para o vencimento dos eventos do Banco de Horas"
		oBtnMeses := TButton():Create(oPanel,,, Space(6) + STR0078, {|| MesesBH()}, 60, 20,,,, .T.,, STR0079,, {|| lWenBtn})
		oBtnMeses:SetCss(GetCSS(8))
		oBtnMeses:Align := CONTROL_ALIGN_LEFT
	EndIf
	
	// "Filtro"
	// "Selecionar filtros para os funcionários"
	oBtnFiltro := TButton():Create(oPanel,,, Space(6) + STR0010, {|| FiltraFunc()}, 50, 20,,,, .T.,, STR0011,, )
	oBtnFiltro:SetCss(GetCSS(5))
	oBtnFiltro:Align := CONTROL_ALIGN_LEFT
	
	// "Ajuda"
	// "Documentação da Rotina"
	oBtnAjuda := TButton():Create(oPanel,,, Space(6) + STR0012, {|| AbreTDN()}, 50, 20,,,, .T.,, STR0013,, )
	oBtnAjuda:SetCss(GetCSS(6))
	oBtnAjuda:Align := CONTROL_ALIGN_RIGHT
	
Return

/*/{Protheus.doc} GetCSS
Retorna o CCS utilizado nos botões com uma imagem de fundo
@type static function
@author Cícero Alves
@since 28/03/2024
@param nBtn, numeric, Tipo do botão 
@return character, CSS do botão
/*/
Static Function GetCSS(nBtn)
	
	Local cCSSBtn	:= ""
	Local cImage	:= ""
	
	If nBtn == 1 		// Cálculo
		cImage := "SDUSUM_OCEAN.PNG"
	ElseIf nBtn == 2 	// Fechamento
		cImage := "CADEADO_OCEAN.PNG"
	ElseIf nBtn == 3 	// Reabertura
		cImage := "MDILOGOFF_OCEAN.PNG"
	ElseIf nBtn == 4 	// Extrato
		cImage := "IMPRESSAO_OCEAN.PNG"
	ElseIf nBtn == 5 	// Filtro
		cImage := "FILTRO_OCEAN.PNG"
	ElseIf nBtn == 6 	// Ajuda
		cImage := "MDIHELP_OCEAN.PNG"
	ElseIf nBtn == 7 	// Lançamentos
		cImage := "EDITABLE_OCEAN.PNG"
	ElseIf nBtn == 8 	
		cImage := "BTCALEND_OCEAN.PNG"
	EndIf
	
	cCSSBtn := "QPushButton {"  
	cCSSBtn += " background-image: url(rpo:" + cImage + ");"
	cCSSBtn += " background-repeat:no-repeat;"
	cCSSBtn += " background-position: left center;"
	cCSSBtn += " background-size: auto;"
	cCSSBtn += " margin:2px;"
	cCSSBtn += " margin-left:5px;"
	cCSSBtn += " border-style: outset;"
	cCSSBtn += " border-width: 2px;"
	cCSSBtn += " border: 1px solid #C0C0C0;"
	cCSSBtn += " border-radius: 5px;"
	cCSSBtn += " border-color: #C0C0C0;"
	cCSSBtn += " font: bold 12px Arial;"
	cCSSBtn += " padding: 6px;"
	cCSSBtn += "}"
	
	cCSSBtn += "QPushButton:hover {"
	cCSSBtn += " border-color: white;"
	cCSSBtn += " background-color: #69C5FC;"
	cCSSBtn += "}"
	
	cCSSBtn += "QPushButton:pressed {"
	cCSSBtn += " background-color: #12A2F7;"
	cCSSBtn += " border-style: inset;"
	cCSSBtn += "}"
	
Return cCSSBtn

/*/{Protheus.doc} FuncBrowse
Cria um MarkBrowse para seleção dos funcionários
@type static function
@author Cícero Alves
@since 28/03/2024
@param oPanel, object, Painel para a criação do Browse - passado por referência
/*/
Static Function FuncBrowse(oPanel)
	
	Local aSRAColumns := GetColumns()
	
	// Browse para a seleção dos funcionários
	oBrowse := FWMarkBrowse():New()
	oBrowse:SetOwner( oPanel )
	oBrowse:SetDescription(STR0022) // "Seleção de Funcionários"
	oBrowse:SetMenuDef("")
	oBrowse:ForceQuitButton()
	oBrowse:SetAlias(cAliasSRA)
	GpLegend(@oBrowse, .T.)
	oBrowse:SetColumns(aSRAColumns)
	oBrowse:SetFieldMark("OK")
	oBrowse:SetProfileID( '1' )
	oBrowse:SetTemporary(.T.)
	oBrowse:DisableReport()
	oBrowse:DisableDetails()
	oBrowse:SetIgnoreARotina(.T.)
	oBrowse:SetMark(cMark, cAliasSRA, "OK")
	oBrowse:SetAfterMark({|| If(oBrowse:IsMark(), nMarcados++, nMarcados--), If(nMarcados <= 1, ButtonsWhen(), )})
	
	oBrowse:Activate()
	
Return

/*/{Protheus.doc} ButtonsWhen
Habilita ou Desabilita os botões de acordo com a quantidade de funcionários selecionados na tela
@type static function
@author Cícero Alves
@since 28/03/2024
@return logical, sempre verdadeiro
/*/
Static Function ButtonsWhen()
	
	lMesesBH := If(lMesesBH == NIL, SPI->(ColumnPos("PI_MESESBH")) > 0, lMesesBH)
	
	lWenBtn := nMarcados > 0
	
	oBtnCalc:SetEnable(lWenBtn)
	oBtnFecha:SetEnable(lWenBtn)
	oBtnAbre:SetEnable(lWenBtn)
	
	If lMesesBH
		oBtnMeses:SetEnable(lWenBtn)
	EndIf
	
	If GetRpoRelease() >= "12.1.2210" .And. FWLibVersion() >= "20240226"
		oBtnRel:SetEnable(lWenBtn)
	EndIf
	
Return .T.

/*/{Protheus.doc} CriaTmpSRA
Cria uma tabela temporária com as informações do cadastro de funcionários
@type static function
@author Cícero Alves
@since 28/03/2024
@param cAliasSRA, character, Alias utilizado na tabela temporária - passado por referência
@param cWhere, character, Cláusula where em SQL para filtro dos registros da SRA
@param lMarca, logical, Quando verdadeiro os registros da tabela temporária serão marcados
/*/
Static Function CriaTmpSRA(cAliasSRA, cWhere, lMarca)
	
	Local aStructSRA	:= {}
	Local aLstIndices	:= {}
	Local cSQLAlias		:= GetNextAlias()
	Local cAcessaSRA	:= fSFiltrSQL(ChkRH("PONM110", "SRA", "2"))
	Local cTCAlias		:= ""
	Local cValidFil		:= fValidFil()
	Local lSkipFil		:= .F.
	Local cLastFil		:= "******"
	Local oBulk
	
	DEFAULT cAliasSRA 	:= GetNextAlias()
	DEFAULT cWhere		:= ""
	DEFAULT lMarca		:= .F.
	
	// Monta a estrutura da tabela temporária 
	aAdd( aStructSRA, { "OK"		, "C", 2					  , 0 } )
	aAdd( aStructSRA, { "RA_FILIAL" , "C", FwGetTamFilial		  , 0 } )
	aAdd( aStructSRA, { "RA_MAT"	, "C", TamSX3("RA_MAT")[1]	  , 0 } )
	aAdd( aStructSRA, { "RA_ADMISSA", "D", 8					  , 0 } )
	aAdd( aStructSRA, { "RA_NOME"	, "C", 30					  , 0 } )
	aAdd( aStructSRA, { "RA_CC"  	, "C", TamSX3("RA_CC")[1]	  , 0 } )
	aAdd( aStructSRA, { "RA_SITFOLH", "C", 1					  , 0 } )
	aAdd( aStructSRA, { "RA_RESCRAI", "C", 2					  , 0 } )
	aAdd( aStructSRA, { "RECSRA"	, "N", 10					  , 0 } )
	
	aAdd( aLstIndices, { "RA_FILIAL", "RA_MAT" } )
	
	oArqSRA := FWTemporaryTable():New(cAliasSRA)
	oArqSRA:SetFields(aStructSRA)
	oArqSRA:AddIndex("1", {"RA_FILIAL", "RA_MAT"})
	oArqSRA:Create()
	
	cWhere += If(!Empty(cAcessaSRA) .And. cAcessaSRA != ".T.", " AND " + cAcessaSRA, "")
	cWhere := "%" + cWhere + "%"
	
	BeginSQL ALIAS cSQLAlias
		COLUMN RA_ADMISSA AS DATE
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CC, RA_ADMISSA, RA_SITFOLH, RA_RESCRAI, R_E_C_N_O_ RECNO
		FROM %Table:SRA% SRA
		WHERE SRA.%NotDel%
		%Exp:cWhere%
		ORDER BY RA_FILIAL, RA_MAT
	EndSQL
	
	cTCAlias := oArqSRA:GetTableNameForTCFunctions()
	
	oBulk := FwBulk():New(cTCAlias)
	oBulk:SetFields(aStructSRA)
	
	While (cSQLAlias)->(!EoF())
		
		If !(cSQLAlias)->RA_FILIAL == cLastFil 
			lSkipFil := (cSQLAlias)->(!(RA_FILIAL $ cValidFil))
			cLastFil := (cSQLAlias)->RA_FILIAL
		EndIf
		
		If lSkipFil
			(cSQLAlias)->(dbSkip())
			LOOP
		EndIf
		
		If(lMarca, nMarcados++, ) 
		oBulk:AddData({;
			If(lMarca, cMark, ""),;
			(cSQLAlias)->RA_FILIAL,;
			(cSQLAlias)->RA_MAT,;
			(cSQLAlias)->RA_ADMISSA,;
			(cSQLAlias)->RA_NOME,;
			(cSQLAlias)->RA_CC,;
			(cSQLAlias)->RA_SITFOLH,;
			(cSQLAlias)->RA_RESCRAI,;
			(cSQLAlias)->RECNO;
		})
		(cSQLAlias)->(dbSkip())
	EndDo
	
	oBulk:Close()
	oBulk:Destroy()
	oBulk := Nil
	
	(cSQLAlias)->(dbCloseArea())
	
Return

/*/{Protheus.doc} GetColumns
Retorna as colunas utilizadas no browse
@type static function
@author Cícero Alves
@since 28/03/2024
@return Array, lista de FWBrwColumn
/*/
Static Function GetColumns()
	
	Local aCampos := {"RA_FILIAL", "RA_MAT", "RA_NOME", "RA_CC", "RA_ADMISSA"}
	Local aColumns := {}
	Local nI
	
	For nI := 1 To Len(aCampos)
		AAdd( aColumns, FWBrwColumn():New() )
		aTail(aColumns):SetID(		aCampos[nI] )
		aTail(aColumns):SetData( 	&("{ || " + aCampos[nI] + " }") )
		aTail(aColumns):SetType( 	GetSx3Cache(aCampos[nI], "X3_TIPO") )
		aTail(aColumns):SetSize( 	GetSx3Cache(aCampos[nI], "X3_TAMANHO"))
		aTail(aColumns):SetTitle(	GetSx3Cache(aCampos[nI], "X3_TITULO") )
		aTail(aColumns):SetPicture(	GetSx3Cache(aCampos[nI], "X3_PICTURE"))
		aTail(aColumns):SetDecimal( GetSx3Cache(aCampos[nI], "X3_DECIMAL") )
	Next nI
	
Return aColumns

/*/{Protheus.doc} LancBH
Chama a rotina de manutenção de banco de horas
@type static function
@author Cícero Alves
@since 17/06/2024
@return NIL, NIL
/*/
Static Function LancBH()
	
	// Posiciona na SRA 
	dbSelectArea("SRA")
	SRA->(dbGoTo( (cAliasSRA)->RECSRA))
	
	// Chama a rotina de lançamentos
	FWExecView(STR0082, "PONA200", MODEL_OPERATION_UPDATE,, {||.T.}) // "Manutenção de Banco de Horas"
	
Return

/*/{Protheus.doc} CalcBH
Chama as funções para realizar o cálculo mensal
@type static function
@author Cícero Alves
@since 28/03/2024
/*/
Static Function CalcBH()
	
	Local lPerApont	:= .F.
	
	If GetPergCalc(@lPerApont)
		dDataBase := If(!lPerApont, MV_PAR17, dDataBase)
		MsAguarde( {|| PONM070(.F., .T., lPerApont)}, STR0014) // "Realizando o cálculo para os funcionários selecionados..."
	EndIf
	
	dDataBase := dBkpDtBase
	
Return

/*/{Protheus.doc} MesesBH
Chama as funções para atualizar os meses para vencimento do banco de horas
@type static function
@author Cícero Alves
@since 17/06/2024
@return NIl, NIL
/*/
Static Function MesesBH()
	
	If GetPergMeses()
		MsAguarde( {|| AtuMesesBH(.T.)}, STR0083) //"Atualizando Registros..."
	EndIf
	
Return

/*/{Protheus.doc} FechaBH
Chama as funções para realizar o fechamento do banco de horas
@type static function
@author Cícero Alves
@since 28/03/2024
/*/
Static Function FechaBH()
	
	If GetPergFech()
		
		dDataBase := MV_PAR24
		
		// "Realizando o fechamento para os funcionários selecionados..."
		MsAguarde( {|| PONM080(.T.)}, STR0015)
		
	EndIf
	
	dDataBase := dBkpDtBase
	
Return

/*/{Protheus.doc} FechaBHVen
Chama as funções para realizar o fechamento por vencimento do banco de horas
@type static function
@author Cícero Alves
@since 17/06/2024
@return NIL, NIL
/*/
Static Function FechaBHVen()
	
	If GetPergFV()
		
		dDataBase := MV_PAR24
		
		// "Realizando o fechamento para os funcionários selecionados..."
		MsAguarde( {|| PONM080(.T.)}, STR0015)
		
	EndIf
	
	dDataBase := dBkpDtBase
	
Return

/*/{Protheus.doc} AbreBH
Chama as funções para realizar a reabetura do banco de horas
@type static function
@author Cícero Alves
@since 28/03/2024
/*/
Static Function AbreBH()
	
	// "Realizando a Reabertura do banco para os funcionários selecionados..."
	MsAguarde( {|| PONM100(.T.)}, STR0016)
	
Return

/*/{Protheus.doc} ImpBH
Chama as funções para realizar a impressão do extrato de banco de horas
@type static function
@author Cícero Alves
@since 28/03/2024
/*/
Static Function ImpBH()
	
	Local cTCAlias 		:= oArqSRA:GetRealName()
	local oSmartView 	:= NIL
	local jPrint 		:= NIL
	Local lSucess		:= .F.
	Local cPath			:= "/Rel_SmartView/"
	Local cName			:= STR0017 + " - " + StrTran(StrTran(FWTimeStamp(2), "/", "_"), ":", "_") // "Extrato Banco de Horas"
	Local cExtencao		:= ""
	Local cPathTo		:= ""
	
	If !ExistDir(cPath)
		MakeDir( cPath)
	EndIf
	
	If GetPergRel()
		
		oSmartView := totvs.framework.smartview.callSmartView():new("rh.sv.pon.ponr190", "report")
		
		// Altera as perguntas do relatório
		oSmartView:setNoInterface(.T.)
		oSmartView:setParam("filial1"	, "PONM110")
		oSmartView:setParam("filial2"	, cTCAlias)
		oSmartView:setParam("cc1"		, cMark)
		oSmartView:setParam("per1"		, totvs.framework.treports.date.stringToTimeStamp(DToS(aPergsR[1][3])))
		oSmartView:setParam("per2"		, totvs.framework.treports.date.stringToTimeStamp(DToS(aPergsR[2][3])))
		oSmartView:setParam("hrsvalori"	, If (aPergsR[3][3] == "1", .T., .F.))
		oSmartView:setParam("evtaut"	, aPergsR[4][3])
		
		oSmartView:setPrintType(1)
		oSmartView:setShowWizard(.T.)
		oSmartView:setForceParams(.T.)
		oSmartView:setOpenFile(.F.)
		
		jPrint := jsonObject():new()
		
		jPrint["name"] := cName
		
		If aPergsR[5][3] == "1" // PDF
			cExtencao := ".pdf"
			jPrint["extension"] := "pdf"
		Else 					// Excel
			cExtencao := ".xlsx"
			jPrint["extension"] := "xlsx"
		EndIf
		
		jPrint["path"] := cPath
		
		oSmartView:setPrintInfo(jPrint)
		
		// "Gerando o Relatório..."
		MsAguarde( {|| lSucess := oSmartView:executeSmartView()}, STR0070)
		
		If lSucess
			If GetRemoteType() != 5
				// "Selecione onde Salvar o Arquivo"
				cPathTo := cGetFile("", STR0018, 0, , .F., nOr(GETF_RETDIRECTORY, GETF_LOCALFLOPPY, GETF_LOCALHARD), .F.)
				
				// Salva o Arquivo
				If !Empty(cPathTo)
					If CpyS2T(cPath + cName + cExtencao, cPathTo)
						MsgAlert(STR0019) // "Arquivo salvo com sucesso!"
					EndIf
				EndIf
			EndIf
			
			// Exclui o arquivo
			If File(cPath + cName + cExtencao)
				fErase(cPath + cName + cExtencao)
			EndIf
		Else
			// "Não foi possível realizar a geração do relatório em Smart View"
			Help(NIL, NIL, "Smart View", NIL, STR0020, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0021, oSmartView:getError()}) // "Detalhes do erro: "
		EndIf
		
		oSmartView:destroy()
		
	EndIf
	
Return

/*/{Protheus.doc} FiltraFunc
Chama as funções para realizar o filtro dos registros apresentados
@type static function
@author Cícero Alves
@since 28/03/2024
/*/
Static Function FiltraFunc()
	
	Local cWhere := ""
	
	// Apresenta a tela para a seleção dos filtros
	If GetPergFil()
		
		// Busca os filtros informados pelo usuário
		cWhere := GetWhere()
		
		// Destoi a tabela temporária 
		DelTab()
		
		nMarcados := 0
		CriaTmpSRA(cAliasSRA, cWhere, .T.)
		
		oBrowse:Refresh()
		oBrowse:GoTop(.T.)
		
		// Habilita os botões
		ButtonsWhen()
		
	EndIf
	
Return 

/*/{Protheus.doc} GetPergCalc
Apresenta a tela com as perguntas para o cálculo
@type static function
@author Cícero Alves
@since 28/03/2024
@param lPerApont, logical, Se utiliza o período de apontamento para realizar o cálculo - passado por referência
@return logical, Verdadeiro quando o usuário confirma a seleção dos parâmetros
/*/
Static Function GetPergCalc(lPerApont)
	
	Local oPanel
	Local oDlgPerg	:= FWDialogModal():New()
	Local lCalc		:= .F.
	Local aButtons	:= {{, STR0029, {|| oDlgPerg:oOwner:End()}, "",, .T., }} // "Cancelar"
	Local dDataDe	:= Date()
	Local dDataAte	:= Date()
	
	lPerApont := .F.
	
	//Criação da tela
	oDlgPerg:SetEscClose(.F.)
	oDlgPerg:setTitle(STR0023) // "Cálculo Banco de Horas"
	oDlgPerg:setSize(150, 200)
	oDlgPerg:createDialog()
	oDlgPerg:addCloseButton({|| If( lCalc := (lPerApont .Or. (!lPerApont .And. !Empty(dDataDe) .And. !Empty(dDataAte))), oDlgPerg:oOwner:End(),)}, STR0024) // Confirmar
	oDlgPerg:addButtons(aButtons)
	
	oPanel := TPanel():New(,,, oDlgPerg:getPanelMain())
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	Pergunte("PNM070", .F.)
	
	//"Utilizar período de Apontamento"
	TCheckBox():New( 8, 3, STR0025, {|| lPerApont}, oPanel, 100,,, {|| (dDataDe := dDataAte := If(!lPerApont, cToD(""), Date())), lPerApont := !lPerApont},,,,,, .T., STR0026,,) // "Utiliza o período de apontamento aberto de acordo coma filial do funcionário"
	
	// "Período Inicial?"
	TGet():New( 24, 3, {|u| If(PCount() == 0, dDataDe, dDataDe := u )}, oPanel, 60,,,{|| lPerApont .Or. !Empty(dDataDe)},,,,,, .T.,,,,,,,,,, "dDataDe",,,, .T.,,, STR0027 + Space(44), 2)
	
	// "Período Final?"
	TGet():New( 40, 3, {|u| If(PCount() == 0, dDataAte, dDataAte := u )}, oPanel, 60,,,{|| lPerApont .Or. !Empty(dDataAte)},,,,,, .T.,,,,,,,,,, "dDataAte",,,, .T.,,, STR0028 + Space(46), 2)
	
	oDlgPerg:Activate()
	
	If lCalc
		SetMVValue( "PNM070", "MV_PAR16", dDataDe, .T.)
		SetMVValue( "PNM070", "MV_PAR17", dDataAte, .T.)
	EndIf
	
Return lCalc

/*/{Protheus.doc} GetPergMeses
Apresenta a tela com as perguntas para alteração dos meses para vencimento do banco de horas 
@type static function
@author Cícero Alves
@since 17/06/2024
@return logical, Verdadeiro quando o usuário confirma a seleção dos parâmetros
/*/
Static Function GetPergMeses()
	
	Local oPanel
	Local oDlgPerg	:= FWDialogModal():New()
	Local lCalc		:= .F.
	Local aButtons	:= {{, STR0029, {|| oDlgPerg:oOwner:End()}, "",, .T., }} // "Cancelar"
	
	Private nMeses		:= 0
	Private lAtuSPI		:= .F.
	Private dLancDate	:= cToD("")
	
	//Criação da tela
	oDlgPerg:SetEscClose(.F.)
	oDlgPerg:setTitle(STR0084) // "Meses para Vencimento"
	oDlgPerg:setSize(150, 200)
	oDlgPerg:createDialog()
	oDlgPerg:addCloseButton({|| lCalc := .T., oDlgPerg:oOwner:End()}, STR0024) // Confirmar
	oDlgPerg:addButtons(aButtons)
	
	oPanel := TPanel():New(,,, oDlgPerg:getPanelMain())
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	Pergunte("PONA200", .F.)
	
	// "Meses para vencimento"
	TGet():New( 8, 3, {|u| If(PCount() == 0, nMeses, nMeses := u )}, oPanel, 60, , "@E 99", {|| Positivo()},,,,,, .T.,,,,,,,,,, "nMeses",,,, .T.,,, STR0084 + Space(39), 2)
	
	// "Atualizar lançamentos"
	TCheckBox():New(24, 3, STR0085, {|| lAtuSPI}, oPanel, 100,,, {|| lAtuSPI := !lAtuSPI},, {|| dLancDate := If(lAtuSPI, Date(), cToD(""))},,,, .T., STR0086) // "Aplica a alteração do vencimento para os registros presentes no banco de horas"
	
	// "Lançamentos a partir de"
	TGet():New(40, 3, {|u| If(PCount() == 0, dLancDate, dLancDate := u )}, oPanel, 60,,,,,,,,, .T.,,,,,,,,,, "dLancDate",,,, .T.,,, STR0087 + Space(37), 2)
	
	oDlgPerg:Activate()
	
	If lCalc
		//Atualizar os MV_PAR
		SetMVValue( "PONA200", "MV_PAR09", nMeses, .T.)
		SetMVValue( "PONA200", "MV_PAR10", If(lAtuSPI, 1, 2) , .T.)
		SetMVValue( "PONA200", "MV_PAR11", dLancDate, .T.)
	EndIf
	
Return lCalc

/*/{Protheus.doc} GetPergFech
Apresenta a tela com as perguntas para o Fechamento
@type static function
@author Cícero Alves
@since 28/03/2024
@return logical, Verdadeiro quando o usuário confirma a seleção dos parâmetros
/*/
Static Function GetPergFech()
	
	Local oPanel
	Local oDlgPerg	:= FWDialogModal():New()
	Local lCalc		:= .F.
	Local aButtons	:= {{, STR0029, {|| oDlgPerg:oOwner:End()}, "",, .T., }} // "Cancelar"
	Local nLinha	:= 8
	Local nI		:= 0
	Local cVarGet	:= ""
	Local aOpc19	:= {"1=" + STR0031, "2=" + STR0032} 								// Período - Horas
	Local aOpc20	:= {"1=" + STR0034, "2=" + STR0035, "3=" + STR0036} 				// "Até Limite" - "Acima Limite" - "Ambos"
	Local aOpc22	:= {"1=" + STR0039, "2=" + STR0040} 								// "Normais" - "Valorizadas"
	Local aOpc23	:= {"1=" + STR0042, "2=" + STR0043, "3=" + STR0044} 				// "Credor" - "Devedor" - "Saldo"
	Local aOpc31	:= {"1=" + STR0047, "2=" + STR0048, "3=" + STR0036, "4=" + STR0049} // "Proventos" - "Descontos" - "Ambos" - "Nenhum"
	Local aOpc32	:= {"1=" + STR0051, "2=" + STR0052} 								// "Sim" - "Não"
	
	Static aPergsF	:= {}
	
	If Empty(aPergsF)
		aAdd(aPergsF, {"MV_PAR19", STR0030, "1"		 , "C", aOpc19, 		   , "N"}) 	// "Fechamento por?"
		aAdd(aPergsF, {"MV_PAR20", STR0033, "1"		 , "C", aOpc20, 		   , "N"}) 	// "Fechamento Horas?" 
		aAdd(aPergsF, {"MV_PAR21", STR0037, 0.00	 , "G", 	  , "@E 999.99",	})	// "No. Horas Limite?"
		aAdd(aPergsF, {"MV_PAR22", STR0038, "1"		 , "C", aOpc22, 		   , "N"}) 	// "Utilizar Horas?"
		aAdd(aPergsF, {"MV_PAR23", STR0041, "3"		 , "C", aOpc23, 		   , "N"}) 	// "Resultado?"
		aAdd(aPergsF, {"MV_PAR24", STR0045, Date()	 , "G", 	  , 		   , 	})	// "Data de Fechamento?"
		aAdd(aPergsF, {"MV_PAR27", STR0027, Date()	 , "G", 	  , 		   , 	})	// "Período Inicial?"
		aAdd(aPergsF, {"MV_PAR28", STR0028, Date()	 , "G", 	  , 		   , 	})	// "Período Final?"
		aAdd(aPergsF, {"MV_PAR31", STR0046, "4"		 , "C", aOpc31, 		   , "N"}) 	// "Limita Lançamentos?"
		aAdd(aPergsF, {"MV_PAR32", STR0050, "2"		 , "C", aOpc32, 		   , "N"}) 	// "Fechamento para Rescisão?"
		aAdd(aPergsF, {"MV_PAR33", STR0053, "1"		 , "C", aOpc32, 		   , "N"}) 	// "Apenas Saldo nos Resultados?"
	EndIf
	
	//Criação da tela
	oDlgPerg:SetEscClose(.F.)
	oDlgPerg:setTitle(STR0054) // "Fechamento Banco de Horas"
	oDlgPerg:setSize(250, 200)
	oDlgPerg:createDialog()
	oDlgPerg:addCloseButton({|| If( lCalc := VldPergs(1), oDlgPerg:oOwner:End(), ) }, STR0024) // "Confirmar"
	oDlgPerg:addButtons(aButtons)
	
	oPanel := TPanel():New(,,, oDlgPerg:getPanelMain())
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	For nI := 1 To Len(aPergsF)
		
		cVarGet := "aPergsF[" + cValToChar(nI) + "][3]"
		
		cBlkGet := "{|u| If( PCount() == 0, " + cVarGet + "," + cVarGet + " := u )}"
		
		TSay():New( nLinha, 3, MontaBlock("{|| '" + Left(aPergsF[nI][2] + Space(60), 60) + "' }"), oPanel,,,,,, .T.,,, 100,,,,,,)
		
		If aPergsF[nI][4] == "G"
			TGet():New( nLinha, 100, &cBlkGet, oPanel, 70,, aPergsF[nI][6],,,,,,, .T.,,,,,,,,,, cVarGet,,,, .T.,,, "", 2)
		Else
			TComboBox():New(nLinha, 100, &cBlkGet, aPergsF[nI][5], 70, 12, oPanel, , , , , , .T., , , , , , , , , cVarGet, "", 2)
		EndIf
		
		nLinha += 16
		
	Next nI
	
	oDlgPerg:Activate()
	
	If lCalc
		
		Pergunte("PNM080", .F.)
		
		aEval(aPergsF, {|x| SetMVValue("PNM080", x[1], If(x[7] == "N", Val(x[3]), x[3]), .T.)})
		
		// Altera as perguntas que não foram exibidas em tela
		SetMVValue("PNM080", "MV_PAR25", 2, .T.) 				// Sempre baixar os eventos do banco
		SetMVValue("PNM080", "MV_PAR26", 3, .T.) 				// Ambos eventos autorizados e não autorizados
		SetMVValue("PNM080", "MV_PAR29", &("MV_PAR27"), .T.) 	// Data inicial dos descontos
		SetMVValue("PNM080", "MV_PAR30", &("MV_PAR28"), .T.) 	// Data Final dos descontos
		
	EndIf
	
Return lCalc

/*/{Protheus.doc} GetPergFV
Apresenta a tela com as perguntas para o Fechamento por vencimento
@type static function
@author Cícero Alves
@since 17/06/2024
@return logical, Verdadeiro quando o usuário confirma a seleção dos parâmetros
/*/
Static Function GetPergFV()
	
	Local oPanel
	Local oDlgPerg	:= FWDialogModal():New()
	Local lCalc		:= .F.
	Local aButtons	:= {{, STR0029, {|| oDlgPerg:oOwner:End()}, "",, .T., }} // "Cancelar"
	Local nLinha	:= 8
	Local nI		:= 0
	Local cVarGet	:= ""
	Local aOpc22	:= {"1=" + STR0039, "2=" + STR0040} 								// "Normais" - "Valorizadas"
	Local aOpc32	:= {"1=" + STR0051, "2=" + STR0052} 								// "Sim" - "Não"
	
	Static aPergsFV	:= {}
	
	If Empty(aPergsFV)
		aAdd(aPergsFV, {"MV_PAR24", STR0045, Date()	, "G", 	  	 , 		   , 	})	// "Data de Fechamento?"
		aAdd(aPergsFV, {"MV_PAR22", STR0038, "1"	, "C", aOpc22, 		   , "N"}) 	// "Utilizar Horas?"
		aAdd(aPergsFV, {"MV_PAR32", STR0050, "2"	, "C", aOpc32, 		   , "N"}) 	// "Fechamento para Rescisão?"
	EndIf
	
	//Criação da tela
	oDlgPerg:SetEscClose(.F.)
	oDlgPerg:setTitle(STR0054) // "Fechamento Banco de Horas"
	oDlgPerg:setSize(150, 200)
	oDlgPerg:createDialog()
	oDlgPerg:addCloseButton({|| If( lCalc := .T., oDlgPerg:oOwner:End(), )}, STR0024) // "Confirmar"
	oDlgPerg:addButtons(aButtons)
	
	oPanel := TPanel():New(,,, oDlgPerg:getPanelMain())
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	For nI := 1 To Len(aPergsFV)
		
		cVarGet := "aPergsFV[" + cValToChar(nI) + "][3]"
		
		cBlkGet := "{|u| If( PCount() == 0, " + cVarGet + "," + cVarGet + " := u )}"
		
		TSay():New( nLinha, 3, MontaBlock("{|| '" + Left(aPergsFV[nI][2] + Space(60), 60) + "' }"), oPanel,,,,,, .T.,,, 100,,,,,,)
		
		If aPergsFV[nI][4] == "G"
			TGet():New( nLinha, 100, &cBlkGet, oPanel, 70,, aPergsFV[nI][6],,,,,,, .T.,,,,,,,,,, cVarGet,,,, .T.,,, "", 2)
		Else
			TComboBox():New(nLinha, 100, &cBlkGet, aPergsFV[nI][5], 70, 12, oPanel, , , , , , .T., , , , , , , , , cVarGet, "", 2)
		EndIf
		
		nLinha += 16
		
	Next nI
	
	oDlgPerg:Activate()
	
	If lCalc
		
		Pergunte("PNM080", .F.)
		
		aEval(aPergsFV, {|x| SetMVValue("PNM080", x[1], If(x[7] == "N", Val(x[3]), x[3]), .T.)})
		
		// Altera as perguntas que não foram exibidas em tela
		SetMVValue("PNM080", "MV_PAR19", 3, .T.) // Fechamento por vencimento
		
	EndIf
	
Return lCalc

/*/{Protheus.doc} VldPergs
Valida as perguntas de data para o fechamento e geração do extrato
@type static function
@author Cícero Alves
@since 04/04/2024
@param nPerg, numeric, 1 = Valida o fechamento; 2 = Valida o extrato
@return Logical, Verdadeiro se as datas não estiverem vazias
/*/
Static Function VldPergs(nPerg)
	
	Local lRet := .T.
	
	If nPerg == 1 // Fechamento
		If Empty(aPergsF[6][3]) .Or. Empty(aPergsF[7][3]) .Or. Empty(aPergsF[8][3])
			// "Datas em branco."
			// "A data de fechamento ou o período Inicial/Final está em branco"
			// "É necessário informar as datas para realizar o fechamento do banco de horas"
			Help(NIL, NIL, "HELP", NIL, STR0071 + CRLF + STR0072, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0073})
			lRet := .F.
		EndIf
	ElseIf nPerg == 2 // Extrato
		If Empty(aPergsR[1][3]) .Or. Empty(aPergsR[2][3])
			// "Datas em branco."
			// "Período Inicial ou Final está em branco"
			// "É necessário informar as datas inicial e final para a geração do extrato do banco de horas"
			Help(NIL, NIL, "HELP", NIL, STR0071 + CRLF + STR0074, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0075})
			lRet := .F.
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} GetPergRel
Apresenta a tela com as perguntas para a impressão do extrato
@type static function
@author Cícero Alves
@since 28/03/2024
@return lógico, Verdadeiro quando o usuário confirma a execução
/*/
Static Function GetPergRel()
	
	Local oPanel
	Local oDlgPerg	:= FWDialogModal():New()
	Local lCalc		:= .F.
	Local aButtons	:= {{, STR0029, {|| oDlgPerg:oOwner:End()}, "",, .T., }} // "Cancelar"
	Local nLinha	:= 8
	Local nI		:= 0
	Local cVarGet	:= ""
	Local aOpcHrs	:= {"1=" + STR0051, "2=" + STR0052} // "Sim" "Não"
	Local aOpcEvt	:= {"0=" + STR0036, "1=" + STR0066, "2=" + STR0067} // "Ambos" "Autorizados" "Não Autorizados"
	Local aOpcFrm	:= {"1=PDF", "2=XLSX"}
	
	Static aPergsR	:= {}
	
	If Empty(aPergsR)
		aAdd(aPergsR, {"per1"	  , STR0027, Date(), "G", 			})	// "Período Inicial?"
		aAdd(aPergsR, {"per2"	  , STR0028, Date(), "G", 			})	// "Período Final?"
		aAdd(aPergsR, {"hrsvalori", STR0064, "1"   , "C", aOpcHrs	})	// "Utilizar Horas Valorizadas?"
		aAdd(aPergsR, {"evtaut"	  , STR0065, "0"   , "C", aOpcEvt	})	// "Eventos Autorizados?" 
		aAdd(aPergsR, {"Formato"  , STR0068, "1"   , "C", aOpcFrm	})	// "Relatório em?"
	EndIf
	
	//Criação da tela
	oDlgPerg:SetEscClose(.F.)
	oDlgPerg:setTitle(STR0069) // "Extrato de Banco de Horas"
	oDlgPerg:setSize(180, 200)
	oDlgPerg:createDialog()
	oDlgPerg:addCloseButton({|| If(lCalc := VldPergs(2), oDlgPerg:oOwner:End(), )}, STR0024) // "Confirmar"
	oDlgPerg:addButtons(aButtons)
	
	oPanel := TPanel():New(,,, oDlgPerg:getPanelMain())
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	For nI := 1 To Len(aPergsR)
		
		cVarGet := "aPergsR[" + cValToChar(nI) + "][3]"
		
		cBlkGet := "{|u| If( PCount() == 0, " + cVarGet + "," + cVarGet + " := u )}"
		
		TSay():New( nLinha, 3, MontaBlock("{|| '" + Left(aPergsR[nI][2] + Space(60), 60) + "' }"), oPanel,,,,,, .T.,,, 100,,,,,,)
		
		If aPergsR[nI][4] == "G"
			TGet():New( nLinha, 100, &cBlkGet, oPanel, 70,,,,,,,,, .T.,,,,,,,,,, cVarGet,,,, .T.,,, "", 2)
		Else
			TComboBox():New(nLinha, 100, &cBlkGet, aPergsR[nI][5], 70, 12, oPanel, , , , , , .T., , , , , , , , , cVarGet, "", 2)
		EndIf
		
		nLinha += 16
		
	Next nI
	
	oDlgPerg:Activate()
	
Return lCalc

/*/{Protheus.doc} GetPergCalc
Apresenta a tela com as perguntas para o Filtro
@type static function
@author Cícero Alves
@since 28/03/2024
@return logical, Verdadeiro quando o usuário confirma a seleção dos parâmetros
/*/
Static Function GetPergFil()
	
	Local oPanel
	Local oDlgPerg	:= FWDialogModal():New()
	Local lCalc		:= .F.
	Local aButtons	:= {{, STR0029, {|| oDlgPerg:oOwner:End()}, "",, .T., }} // "Cancelar"
	Local nLinha	:= 8
	Local cVar		:= ""
	Local nI		:= 0
	Local cSituacao := fSituacao(.F., .F.)
	Local cCateg	:= fCategoria(.F., .F.)
	
	Static lFirst := .T.
	
	Private aPergs	:= {}
	
	aAdd(aPergs, {"MV_PAR01", STR0055, Space(99), "R", , "SM0"}) 				// "Filiais?"
	aAdd(aPergs, {"MV_PAR02", STR0056, Space(99), "R", , "CTT"}) 				// "Centros de Custo?"
	aAdd(aPergs, {"MV_PAR03", STR0057, Space(99), "R", , "SR6"}) 				// STR0057
	aAdd(aPergs, {"MV_PAR04", STR0058, Space(99), "R", , "SRA"}) 				// "Matrículas?"
	aAdd(aPergs, {"MV_PAR05", STR0059, Space(99), "R", , "SPA"}) 				// "Regras de Apontamento?"
	aAdd(aPergs, {"MV_PAR06", STR0060, cSituacao, "G", {|| fSituacao() }, }) 	// "Situações?"
	aAdd(aPergs, {"MV_PAR07", STR0061, cCateg   , "G", {|| fCategoria()}, }) 	// "Categorias?"
	
	//Criação da tela
	oDlgPerg:SetEscClose(.F.)
	oDlgPerg:setTitle(STR0062) // "Filtrar Funcionários"
	oDlgPerg:setSize(180, 250)
	oDlgPerg:createDialog()
	oDlgPerg:addCloseButton({|| lCalc := .T., oDlgPerg:oOwner:End()}, STR0063) // "Filtrar e Selecionar"
	oDlgPerg:addButtons(aButtons)
	
	oPanel := TPanel():New(,,, oDlgPerg:getPanelMain())
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
	Pergunte("PONM100", .F.)
	
	For nI := 1 To Len(aPergs)
		
		cVar := "aPergs[" + cValToChar(nI) + "][3]"
		
		If !lFirst
			aPergs[nI][3] := &(aPergs[nI][1])
		EndIf
		
		If aPergs[nI][4] == "R"
			cBlkGet := "{|u| If(PCount() == 0, " + cVar + ", fsetVar(u))}"
		Else
			cBlkGet := "{|u| If( PCount() == 0, " + cVar + "," + cVar + " := u)}"
		EndIf
		
		TSay():New( nLinha, 3, MontaBlock("{|| '" + Left( aPergs[nI][2] + Space(60), 60) + "' }"), oPanel,,,,,, .T.,,, 100,,,,,,)
		
		If aPergs[nI][4] == "G"
			TGet():New( nLinha, 100, &cBlkGet, oPanel, 70,,, aPergs[nI][5],,,,,, .T.,,,,,,,,,, cVar,,,, .T.,,, "", 2)
		Else
			oGet := TGet():New( nLinha, 100, &cBlkGet, oPanel, 130,,, ,,,,,, .T.,,,,,,,,,, cVar,,,, .T.,,, "", 2)
			oGet:cF3 := aPergs[nI][6]
		EndIf
		
		nLinha += 16
	Next nI
	
	lFirst := .F.
	
	oDlgPerg:Activate()
	
	// Atualiza as perguntas para execução da rotina
	If lCalc
		aEval(aPergs, {|x| SetMVValue("PONM100", x[1], x[3], .T.)})
	EndIf
	
Return lCalc

/*/{Protheus.doc} fSetVar
Atualiza o conteúdo da variável de peguntas do tipo Range
@type function
@author Cícero Alves
@since 28/03/2024
@param u, character, Conteúdo digitado ou selecionado via F3
@return character, Novo conteúdo do campo
/*/
Function fSetVar(u)
	
	Local cVar		:= ReadVar()
	Local cConteudo	:= ""
	Local nTam		:= 0
	Local cContAux, cAux	:= ""
	Static nConts := 0
	
	nTam := Len(&cVar)
	If !IsInCallStack("GetLKRet") // Quando chamado pelo F3 a função é executada 2X, por isso o controle é necessário
		&cVar := Left(AllTrim(u) + Space(nTam), nTam)
	ElseIf ++nConts  == 1
		&cVar := Left(AllTrim(&cVar) + AllTrim(u) + ";" + Space(nTam), nTam)
	Else
		nConts := 0
	EndIf
	
Return &cVar

/*/{Protheus.doc} RestVars
Reinicializa as variáveis Static e Destroi os objetos criados
@type static function
@author Cícero Alves
@since 28/03/2024
/*/
Static Function RestVars()
	
	nMarcados	:= 0
	lWenBtn		:= .F.
	oBrowse		:= NIL
	oBtnCalc 	:= NIL
	oBtnFecha	:= NIL
	oBtnFiltro	:= NIL
	oBtnCalc 	:= NIL
	oBtnFecha	:= NIL
	oBtnAbre	:= NIL
	oBtnRel		:= NIL
	aPergsF		:= {}
	aPergsR		:= {}
	
	DelTab()
	
Return

/*/{Protheus.doc} DelTab
Destroi a tabela temporária para aplicação dos filtros
@type static function
@author Cícero Alves
@since 28/03/2024
@return NIL, 
/*/
Static function DelTab()
	
	oArqSRA:Delete()
	oArqSRA := NIL
	
Return

/*/{Protheus.doc} GetWhere
Retorna a claúsala where para filtro da SRA com base nas perguntas preenchidas pelo usuário
@type static function
@author Cícero Alves
@since 28/03/2024
@return character, filtro da SRA em SQL
/*/
Static Function GetWhere()
	
	Local cAcessaSRA	:= ""
	Local cWhereSRA		:= ""
	
	cAcessaSRA	:= fSFiltrSQL(ChkRH("PONM110", "SRA", "2"))
	
	MV_PAR06 := fSqlIn(StrTran(MV_PAR06, '*'), 1)
	MV_PAR07 := fSqlIn(StrTran(MV_PAR07, '*'), 1)
	
	MakeSqlExp("PONM100")
	
	cWhereSRA += If(!Empty(MV_PAR01), " AND " + MV_PAR01, "") 							// Filiais
	cWhereSRA += If(!Empty(MV_PAR02), " AND " + MV_PAR02, "") 							// Centros de Custo
	cWhereSRA += If(!Empty(MV_PAR03), " AND " + MV_PAR03, "")							// Turnos
	cWhereSRA += If(!Empty(MV_PAR04), " AND " + MV_PAR04, "") 							// Matrículas
	cWhereSRA += If(!Empty(MV_PAR05), " AND " + MV_PAR05, "") 							// Regras de Apontamento
	cWhereSRA += If(!Empty(MV_PAR06), " AND RA_SITFOLH IN (" + MV_PAR06 + ")", "") 		// Situações
	cWhereSRA += If(!Empty(MV_PAR07), " AND RA_CATFUNC IN (" + MV_PAR07 + ")", "") 		// Categorias
	
	// Controle de Acesso
	cWhereSRA += If(!Empty(cAcessaSRA) .And. cAcessaSRA != ".T.", " AND " + cAcessaSRA, "")
	
Return cWhereSRA

/*/{Protheus.doc} AbreTDN
Abre a página de documentação da rotina no TDN 
@type static function
@author Cícero Alves
@since 28/03/2024
@return character, Retorna 0 em caso de sucesso da execução do processo e diferente de zero para erros.
/*/
Static Function AbreTDN()
Return ShellExecute("open", "https://tdn.totvs.com/pages/viewpage.action?pageId=834798885", "", "", 1)
