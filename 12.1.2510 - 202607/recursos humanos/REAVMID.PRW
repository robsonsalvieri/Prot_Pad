#Include 'Protheus.ch'
#Include 'REAVMID.ch'

/*/{Protheus.doc} REAVMID
Programa responsável por reavaliar os totalizadores dos eventos selecionados:
[x] S-5002 - Imposto de Renda Retido na Fonte por Trabalhador
[ ] S-5001 - Informações das Contribuições Sociais por Trabalhador *não implementado nesta versão
@Return	Nil

@Author   martins.marcio
@Since    22/01/2026
@Version  1.0
@Type     Function
/*/
Function ReavMID()
	Local aArea			:= GetArea()
	Local cTitle  		:= OemToAnsi(STR0001) //"Reavaliação de Totalizadores"
	Local cAliasTRB		:= GetNextAlias()
	Local nOpcA			:= 1
	Local aObjSize		:= {}
	Local aArrayFil		:= {}
	Local aCheck		:= {.T., .F.} /*Caso seja criado novos itens, deve ser alimentado*/
	Local bFilt			:= { || FPergunte("REAVMID", .T., .T.) }
	Local aObjCheck		:= Array(Len(aCheck)) //Objetos dos eventos
	Local aObjCoords	:= {}
	Local oFont
	Local aItens 		:= {}
	Local bFecha		:= {||nOpcA := 2, oDlg:End()}
	Local nOpcB			:= 0
	Local oBtFechar
	Local bOK1			:= {||Iif(fReavMTdOk(aCheck,cAliasTRB,cPerIni, cPerFin, aArrayFil, aItens), (oDlg:End(), nOpcB := 1), Nil)}
	Local lMArcar		:= .F.
	Local aAdvSize		:= MsAdvSize(.F.)
	Local oBtFiltrar
	Local oBtProcessar

	Private lIntTaf     := ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 2 )
	Private lMiddleware := If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Private cPerIni     := SPACE(6)
	Private cPerFin     := SPACE(6)
	Private aSM0        := FWLoadSM0(.T.,,.T.)
	Private cRotina     := "REAVMID"
	Private oTempTable := Nil
	Private oMark
	Private oDlg
	Private oPanel3
	Private aColumns  := {}
	Private cCPFDe    := ""
	Private lIRRFComp := ChkFile("RUQ") .And. FindFunction("fGrvRUQ")
	Private cQuebra   := Chr(13) + Chr(10)

	If !lMiddleware
		MsgAlert(OemToAnsi(STR0002)) //"A integração com o Middleware não está ativa. Operação não permitida."
		Return
	EndIf

	FPergunte("REAVMID",.F., .T.)

    aAdvSize			:= MsAdvSize( .F.,.F.,570)
    aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
    aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
    aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

    //----------------------------------
    //| Criação da tela de apresentação
    //------------------------------------------------
    Define MsDialog oDlg FROM 0, 0 To 400, 930 Title cTitle Pixel

    //Cria o conteiner onde serão colocados os paineis
    oTela1	:= FWFormContainer():New( oDlg )
    cIdTel1	:= oTela1:CreateHorizontalBox( 15 )
    cIdTel2	:= oTela1:CreateHorizontalBox( 23 )
    cIdTel3	:= oTela1:CreateHorizontalBox( 57 )

    oTela1:Activate( oDlg, .F. )

    //Cria os paineis onde serao colocados os browses
    oPanel1	:= oTela1:GeTPanel(cIdTel1)
    oPanel2	:= oTela1:GeTPanel(cIdTel2)
    oPanel3	:= oTela1:GeTPanel(cIdTel3)

    //------------------
    //| Primeiro Painel
    //---------------------------------

    @ aObjSize[1,1]*0.5	, aObjSize[1,2]+2		SAY   OemToAnsi(STR0003) SIZE 038,007 OF oPanel1 PIXEL	//"Periodo De"
    @ (aObjSize[1,1]*0.5)+8, aObjSize[1,2]+2	MSGET cPerIni SIZE 028,007	OF oPanel1 PIXEL WHEN .T. PICTURE "@R 99/9999"

    @ aObjSize[1,1]*0.5, aObjSize[1,2]+70      SAY   OemToAnsi(STR0004) SIZE 038,007 OF oPanel1 PIXEL	//"Periodo Até"
    @ (aObjSize[1,1]*0.5)+8, aObjSize[1,2]+70  MSGET cPerFin SIZE 028,007	OF oPanel1 PIXEL WHEN .T. PICTURE "@R 99/9999"
    //-----------------
    //| Segundo Painel
    //| Armazena os checkbox com todos os eventos disponiveis para ajuste
    //-----------------------------------------------------
    @ 0, aObjSize[1,2] GROUP oGroup TO 25 ,aObjSize[1,4]*0.68 LABEL OemToAnsi(STR0005) OF oPanel2  PIXEL	//"Eventos "

    oGroup:oFont:=oFont

    Aadd(aItens, OemToAnsi(STR0006) ) //"S-5002 - Imposto de Renda Retido na Fonte por Trabalhador"
    // Aadd(aItens, OemToAnsi(STR0008) ) //"S-5001 - Informações das Contribuições Sociais por Trabalhador"

    @ aObjSize[1,1]*0.62, aObjSize[1,2]+6	CHECKBOX aObjCheck[1] VAR aCheck[1] PROMPT "" SIZE 010,007 OF oPanel2 PIXEL WHEN .T.
    @ aObjSize[1,1]*0.62, aObjSize[1,2]+16	SAY OemToAnsi(STR0006)  SIZE 200,060 OF oPanel2 PIXEL //"S-5002 - Imposto de Renda Retido na Fonte por Trabalhador"
    // @ aObjSize[1,1]*0.62, aObjSize[1,2]+206 CHECKBOX aObjCheck[2] VAR aCheck[2] PROMPT "" SIZE 010,007 OF oPanel2 PIXEL WHEN  .F.
    // @ aObjSize[1,1]*0.62, aObjSize[1,2]+221 SAY   OemToAnsi(STR0008)  SIZE 200,060 OF oPanel2 PIXEL //"S-5001 - Informações das Contribuições Sociais por Trabalhador"

    fReavMrkS1(aArrayFil,cAliasTRB,aItens, aObjSize,@aColumns)

    oMark:= FWMarkBrowse():New()
    oMark:SetAlias(cAliasTRB)
    oMark:DisableReport(.T.)
    oMark:DisableFilter(.T.)
    oMark:SetTemporary(.T.)
    oMark:SetColumns(aColumns)
    oMark:SetOwner(oPanel3)

    //--------------------------------------
    //| Aponta para qual browse sera criado
    //--------------------------------------
    oMark:SetFieldMark('OK')
    oMark:SetValid({||.T.})

    oBtFiltrar		:= TButton():New( aObjSize[1,1]*0.5, aObjSize[1,2]+15+230,OemToAnsi(STR0009),NIL,bFilt, 060 , 012 , NIL , NIL , NIL , .T. )	// "Filtro"
    oBtProcessar	:= TButton():New( aObjSize[1,1]*0.5, aObjSize[1,2]+15+300,OemToAnsi(STR0010),NIL,bOK1	, 060 , 012 , NIL , NIL , NIL , .T. )	// "Processar"
    oBtFechar		:= TButton():New( aObjSize[1,1]*0.5, aObjSize[1,2]+15+370,OemToAnsi(STR0011),NIL,bFecha, 060 , 012 , NIL , NIL , NIL , .T. )	// "Fechar"

    oMark:SetMenuDef("GPEM038")

    oMark:bAllMark := {|| SetMarkAll(oMark:Mark(), lMarcar := !lMarcar,cAliasTRB), oMark:Refresh(.T.)}

    oMark:Activate()

    ACTIVATE MSDIALOG oDlg CENTERED

	//Finaliza qualquer área ainda aberta
	If ValType(oTempTable) == "O"
		oTempTable:Delete()
		oTempTable	:= Nil
	EndIf
	RestArea(aArea)

Return

/*/{Protheus.doc}
@Author   martins.marcio
@Date      22/01/2026
@Type      Static Function
Função responsável por fazer a validação de TudOk da tela de seleção de filiais
/*/
Static Function fReavMTdOk(aCheck, cAliasTRB, cPerIni, cPerFin, aArrayFil, aItens)
	Local aArea	:= GetArea()
	Local nErro	:= 0
	Local lRet	:= .T.
	Local nx 	:= 0
    Local cTitulo := STR0012 //"Reavaliação dos totalizadores em andamento"
    Local cDesc   := STR0013 //"Aguarde, iniciando a leitura dos registros..."
    Local oProcess

	Default aCheck		:= {.F., .F.}
	Default cAliasTRB	:= ""
	Default cPerIni		:= ""
	Default cPerFin		:= ""
	Default aArrayFil	:= {}
	Default aItens		:= {}

	Private cAnoMesIni  := substr(cPerIni,3,4) + substr(cPerIni,1,2)
	Private cAnoMesFin  := substr(cPerFin,3,4) + substr(cPerFin,1,2)

	//---------------------------------
	//| Consiste o períodos (vazias)
	//---------------------------------
	If Empty(cAnoMesIni) .and. nErro = 0
		MsgStop(OemToAnsi(STR0014)) //"Necessário preencher o período inicial."
		lRet := .F.
		nErro += nErro
	Endif

	If Empty(cAnoMesFin) .and. nErro = 0
		MsgStop(OemToAnsi(STR0015)) //"Necessário preencher o período final."
		lRet := .F.
		nErro += nErro
	Endif

	If cAnoMesIni > cAnoMesFin .and.  nErro = 0
		MsgStop(OemToAnsi(STR0016)) //"O período final deve ser maior ou igual ao período inicial."
		lRet := .F.
		nErro += nErro
	Endif

	If !aCheck[1] .And.  !aCheck[2] .And. nErro = 0
		MsgStop(OemToAnsi(STR0017)) //"Necessário selecionar um evento"
		lRet := .F.
	Endif

	If lRet
		aArrayFil		:= {}
		//Adiciona filiais selecionadas
		(cAliasTRB)->(dbGoTop())

		While (cAliasTRB)->(!EOF())
			If !Empty((cAliasTRB)->OK)
				aAdd(aArrayFil, {Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL()),substr((CALIASTRB)->CNPJ,1,8),{Padr((cAliasTRB)->FILTAF, FWSIZEFILIAL())}})
				For nX := 1 To Len(aSM0)
					If aSM0[nX, 1] == cEmpAnt .And. aSM0[nX, 2] != Padr((cAliasTRB)->FILTAF, FwSizeFilial()) .And. SubStr((cAliasTRB)->CNPJ, 1, 8) == SubStr(aSM0[nX, 18], 1, 8)
						aAdd( aArrayFil[Len(aArrayFil), 3], aSM0[nX, 2] )
					EndIf
				Next nX
			EndIf
			(cAliasTRB)->(dbSkip())
		EndDo
		//Valida filiais
		If Len(aArrayFil) == 0
			MsgStop(OemToAnsi(STR0018)) //"Necessário selecionar uma filial"
			lRet := .F.
		EndIf
		If lRet
			//Verifica se o processamento está em execução
			If !LockByName( cRotina + cEmpAnt)
				MsgAlert(OemToAnsi(STR0019)) //"Processamento já está em execução para o grupo/empresa logado."
			Else
				// Inicia o Processo de Reavaliação
				oProcess := MsNewProcess():New({|lEnd| Processar(oProcess,aCheck, aArrayFil, @lEnd) }, cTitulo, cDesc, .T.)
				oProcess:Activate()
				UnLockByName(cRotina + cEmpAnt)
			EndIf
		Endif
	Endif

	RestArea(aArea)

Return If(lRet, Nil, lRet)

/*/{Protheus.doc}
@Author   martins.marcio
@Date      22/01/2026
@Type      Static Function
Função responsável por realizar a checagem das filiais
/*/
Static Function fReavMrkS1(aArrayFil, cAliasTRB, aItens,aObjSize,aColumns)

	Local aStru			:= {}
	Local nPosFilTaf	:= 0
	Local nPosNome		:= 0
	Local nPosCnpj		:= 0
	Local nPosDini		:= 0
	Local cPrefixo      := ""
	Local cAliasTaf		:= ""

	Default aArrayFil	:= {}
	Default cAliasTRB	:= ""
	Default aItens		:= {}
	Default aObjSize	:= {}
	Default aColumns	:= {}

	Private cRotina		:= "REAVMID"
	Private oMark
	Private oDlgGrid

    fCriaTmpMd(cAliasTRB)
    cPrefixo 	:= "RJ9_"
    cAliasTaf 	:= "RJ9"
    Dbselectarea(cAliasTaf)
    aStru		:= RJ9->(DBSTRUCT())

    nPosFilTaf	:= aScan( aStru , { |x| x[1] == "RJ9_FILIAL" } )
    nPosNome	:= aScan( aStru , { |x| x[1] == "RJ9_NOME" } )
    nPosCnpj	:= aScan( aStru , { |x| x[1] == "RJ9_NRINSC" } )
    nPosDini	:= aScan( aStru , { |x| x[1] == "RJ9_INI" } )

	//--------------------------------------------------------------
	//| Criando coluna Filial | Atribuindo nome | Dados estruturais
	//--------------------------------------------------------------
	If nPosFilTaf > 0
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosFilTaf][1],"RJ9_FILIAL", "FILTAF",1,1   )+"}") )
		aColumns[Len(aColumns)]:SetTitle(STR0021) //"Filial"
		aColumns[Len(aColumns)]:SetSize(aStru[nPosFilTaf][3])
		aColumns[Len(aColumns)]:SetDecimal(aStru[nPosFilTaf][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf ,  aStru[nPosFilTaf][1]))
	EndIf

	//--------------------------------------------------------------
	//| Criando coluna Nome   | Atribuindo nome | Dados estruturais
	//--------------------------------------------------------------
	If nPosNome > 0
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosNome][1],cPrefixo, "",1,1   )+"}") )
		aColumns[Len(aColumns)]:SetTitle(STR0022) //"Nome"
		aColumns[Len(aColumns)]:SetSize(aStru[nPosNome][3])
		aColumns[Len(aColumns)]:SetDecimal(aStru[nPosNome][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf,  aStru[nPosNome][1]))
	EndIf

	//--------------------------------------------------------------
	//| Criando coluna CNPJ   | Atribuindo nome | Dados estruturais
	//--------------------------------------------------------------
	If nPosCnpj > 0
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosCnpj][1],"RJ9_NRINSC", "CNPJ",1,1   )+"}") )
		aColumns[Len(aColumns)]:SetTitle(STR0023) //"Cnpj"
        aColumns[Len(aColumns)]:SetSize(aStru[nPosCnpj][3])
        aColumns[Len(aColumns)]:SetDecimal(aStru[nPosCnpj][4])
		aColumns[Len(aColumns)]:SetPicture(  "@!R NN.NNN.NNN/NNNN-99"   )
	EndIf

	//-------------------------------------------------------------------
	//| Criando coluna Data Inicio | Atribuindo nome | Dados estruturais
	//-------------------------------------------------------------------
	If nPosDini > 0
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->"+ strtran(aStru[nPosDini][1],"RJ9_INI", "DTINI",1,1   )+"}") )
		aColumns[Len(aColumns)]:SetTitle(STR0024) //"Dt. Ini. Validade"
		aColumns[Len(aColumns)]:SetSize(aStru[nPosDini][3])
		aColumns[Len(aColumns)]:SetDecimal(aStru[nPosDini][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict( cAliasTaf,  aStru[nPosDini][1]))
	EndIf

Return()

/*/{Protheus.doc}
@Author   martins.marcio
@Date      22/01/2026
@Type      Static Function
Função responsável por fazer a criação dos dados temporários das filiais cadastradas no Middleware
/*/
Static Function fCriaTmpMd(cAliasTRB)

	Local aArea			:= GetArea()
	Local aAreaRJ9		:= RJ9->(GetArea())
	Local nPos			:= 0
	Local aStru   		:= {}
	Local aSM0    		:= FWLoadSM0(.T.,,.T.)

	Default cAliasTRB	:= ""

	Private cCadastro	:= OemToAnsi(STR0020) //"Filiais"
	Private aRotina		:= {}

	IIf(Select(cAliasTRB) > 0 , (cAliasTRB)->(DbCloseArea()), .T.)

	//--------------------------------
	//| Estrutura da tabela | Colunas
	//--------------------------------
	DbSelectArea("RJ9")
	RJ9->(dbSetOrder(5))

	//Estrutura da tabela temporaria
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILTAF"	, "C", TamSx3("RJ9_FILIAL")[1]	, 0})
	Aadd(aStru, {"NOME"  	, "C", 100						, 0})
	Aadd(aStru, {"CNPJ"  	, "C", TamSx3("RJ9_NRINSC")[1]  	, 0})
	Aadd(aStru, {"DTINI" 	, "C", TamSx3("RJ9_INI")[1]	, 0})

	oTempTable := FWTemporaryTable():New(cAliasTRB)
	oTempTable:SetFields(aStru)
	oTempTable:AddIndex( "01", {"FILTAF"} )
	oTempTable:Create()

	RJ9->(dbGoTop())
	While !RJ9->(EOF())
		nPos := aScan(aSM0, {|x| Alltrim(x[1] + X[18]) ==  Alltrim(cEmpAnt+RJ9->RJ9_NRINSC) })
		If nPos > 0
			RecLock(cAliasTRB, .T.)
				(cAliasTRB)->FILTAF	:= aSM0[nPos, 2]
				(cAliasTRB)->NOME  	:= RJ9->RJ9_NOME
				(cAliasTRB)->CNPJ 	:= RJ9->RJ9_NRINSC
				(cAliasTRB)->DTINI  := RJ9->RJ9_INI
				(cAliasTRB)->(MsUnlock())
		Endif
		RJ9->(dbSkip())
	Enddo

	//--------------------------------------------
	//| Apontando para o primeiro registro válido
	//--------------------------------------------
	RJ9->(DbCloseArea())

	RestArea(aAreaRJ9)
	RestArea(aArea)

Return()

/*/{Protheus.doc}
@Author   martins.marcio
@Date      22/01/2026
@Type      Static Function
Função responsável pelo processamento da reavaliação dos eventos
/*/
Static Function Processar(oProcess, aCheck, aArrayFil, lEnd)
	Local nTotFil    := Len(aArrayFil) + 1
	Local nSubTot    := 0
	Local nTotGer    := 0
	Local nX         := 0
	Local nY         := 0
	Local cInscr     := ""
	Local oRJEQry    := Nil
	Local cEvento    := ""
	Local lAtualizou := .F.
	Local cAliasReg  := ""

	Default oProcess  := Nil
	Default aCheck    := {.F., .F.}
	Default aArrayFil := {}
	Default lEnd      := .F.

    For nY := 1 To Len(aArrayFil)

        // Define o tamanho total da régua (100%)
        oProcess:SetRegua1(nTotFil)
        oProcess:IncRegua1(STR0025 + aArrayFil[nY][1] + "...        [" + cValToChar(nY) + STR0032 + cValToChar(Len(aArrayFil)) + "]") //"Processando Filial " | " de "
        cEvento := IIf(aCheck[1], "S5002", IIf(aCheck[2], "S5001", ""))
		If !Empty(cEvento)
			cInscr  := SubStr(aArrayFil[nY][2], 1, 8)
			DbSelectArea("RJE")
			cAliasReg := fQryRegs(oRJEQry, cEvento, cInscr, cAnoMesIni, cAnoMesFin)
			DbSelectArea(cAliasReg)
			If !(cAliasReg)->(Eof())
				(cAliasReg)->(dbGoTop())

				Count To nSubTot
				oProcess:SetRegua2(nSubTot)

				(cAliasReg)->(dbGoTop())
				//Varre todos os registros encontrados para a filial
				While !(cAliasReg)->(Eof()) .And. !lEnd
					RJE->(dbGoTo((cAliasReg)->R_E_C_N_O_))

					//Atualizando a régua de progresso secundária
					nX ++
					oProcess:IncRegua2(STR0026 + " [" + cValToChar(nX) + STR0032 + cValToChar(nSubTot) + "]") //"Processando tabela RJE... [" | " de "

					//Regrava os totalizadores do evento
					fGrvTotIR( RJE->RJE_FIL, RJE->RJE_TPINSC, RJE->RJE_INSCR, RJE->RJE_XML )
					(cAliasReg)->(dbSkip())
					lAtualizou := .T.
					nTotGer ++
				EndDo
				If nSubTot > 0
					(cAliasReg)->(DbCloseArea())
				EndIf
			EndIf
		EndIf

    Next nY

    If !lEnd
		If lAtualizou
        	MsgInfo(STR0029 + cQuebra + cQuebra + STR0007 + cValToChar(nTotGer), STR0030) //"Processamento finalizado com sucesso! " | "Total de registros processados: "
		Else
			MsgInfo(STR0031, STR0028) //"Não foram encontrados registros com os critérios informados!" | "Atenção"
        EndIf
    EndIf

Return lAtualizou

/*/{Protheus.doc}
@Author   martins.marcio
@Date      22/01/2026
@Type      Static Function
Função filtrar os registros da tabela RJE de acordo com os parâmetros informados
/*/
Static Function fQryRegs(oRJEQry, cEvento, cInscr, cAnoMesIni, cAnoMesFin)

    Local cQuery       := ""
	Local cAliasReg   := GetNextAlias()

    Default oRJEQry  := Nil
	Default cEvento    := ""
    Default cInscr     := ""
    Default cAnoMesIni := ""
    Default cAnoMesFin := ""

    If oRJEQry == Nil
        cQuery := "SELECT RJE.RJE_FIL, RJE.RJE_TPINSC, RJE.RJE_INSCR, RJE.RJE_EVENTO, RJE.RJE_INI, RJE.RJE_XML, RJE.R_E_C_N_O_ "
        cQuery += "FROM " + RetSqlName('RJE') + " RJE "
        cQuery += "WHERE RJE.RJE_EVENTO = ? "
        cQuery +=	"AND RJE.RJE_INSCR = ? "
        cQuery +=	"AND RJE.RJE_INI BETWEEN ? AND ? "
        cQuery +=	"AND RJE.RJE_STATUS = ? "
        cQuery +=	"AND RJE.RJE_EXC = ? "
        cQuery += 	"AND RJE.D_E_L_E_T_ = ? "
        If !Empty(cCPFDe)
			cQuery += 	"AND SUBSTRING(RJE.RJE_KEY, 8, 11) = ? "
		EndIf
        cQuery += "ORDER BY RJE.RJE_INSCR, RJE.RJE_INI, RJE.RJE_KEY"

        cQuery := ChangeQuery(cQuery)
        oRJEQry := FwExecStatement():New(cQuery)
    EndIf
    oRJEQry:SetString(1, cEvento)     // 1
    oRJEQry:SetString(2, cInscr)      // 2
    oRJEQry:SetString(3, cAnoMesIni)  // 3
    oRJEQry:SetString(4, cAnoMesFin)  // 4
    oRJEQry:SetString(5, "4")         // 5
    oRJEQry:SetString(6, " ")         // 6
    oRJEQry:SetString(7, " ")         // 7
	If !Empty(cCPFDe)
		oRJEQry:SetString(8, cCPFDe)  // 8
	EndIf

    // Executa a query e retorna o alias criado
    cAliasReg := oRJEQry:OpenAlias()

Return cAliasReg

/*/{Protheus.doc}
@Author   martins.marcio
@Date      22/01/2026
@Type      Static Function
Função que trata os filtros de perguntas
/*/
Static Function FPergunte(cNomRot, lView, lEdit)

	Local aParambox	:= {}
	Local aRet 		:= {}
	Local lRet		:= .T.
	Local nX		:= 0

	Default cNomRot	:= "REAVMID"
	Default lView	:= .T.
	Default lEdit	:= .T.

	Private lWhen	:= lEdit

	aAdd( aParambox, {1, STR0033, CriaVar("RA_CIC", .F.), "@R 999.999.999-99", ".T.", "", ".T.", 100, .F.})  //"CPF Trabalhador: "

	//Carrega o array com os valores utilizados na última tela ou valores Default de cada campo.
	For nX := 1 To Len(aParamBox)
		aParamBox[nX][3] := ParamLoad(cNomRot, aParamBox, nX, aParamBox[nX][3])
	Next nX

	//Define se ira apresentar tela de perguntas
	If lView
		lRet := ParamBox(aParamBox, STR0034, aRet, {|| VldPerg()}, {}, .T., Nil, Nil, Nil, cNomRot, .F., .F.) //"Parâmetros"
	Else
		For nX := 1 To Len(aParamBox)
			Aadd(aRet, aParamBox[nX][3])
		Next nX
	EndIf

	If lRet
		//Carrega perguntas em variaveis usadas no programa
		If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
			For nX := 1 to Len(aParamBox)
				If ValType(aRet[nX]) == "C"
					&("Mv_Par" + StrZero(nX, 2)) := aRet[nX]
				Endif
			Next nX
		EndIf

		If lEdit
			//Salva parametros
			ParamSave(cNomRot, aParamBox, "1")
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc}
@Author   martins.marcio
@Date      23/01/2026
@Type      Static Function
Função responsável por validar os dados da tela de perguntas
/*/
Static Function VldPerg()

	Local lRet := .T.

	cCPFDe := MV_PAR01
	If !Empty(cCPFDe) // Valida CPF
		If Len(AllTrim(cCPFDe)) <> 11
			MsgAlert(OemToAnsi(STR0035)) //"CPF inválido."
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc}
Função responsável por Marcar/Desmarcar todos os itens
@Author   isabel.noguti
@Date      12/03/2026
@Type      Static Function
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB)
	Local cAliasMark := cAliasTRB
	Local aAreaMark  := (cAliasMark)->( GetArea() )

	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )

	While !(cAliasMark)->( Eof() )
		RecLock( (cAliasMark), .F. )
		(cAliasMark)->OK := IIf( lMarcar, cMarca, '  ' )
		MsUnLock()
		(cAliasMark)->( dbSkip() )
	EndDo

	RestArea(aAreaMark)
Return .T.
