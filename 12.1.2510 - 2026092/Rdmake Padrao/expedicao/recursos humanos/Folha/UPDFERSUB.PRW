#INCLUDE "PROTHEUS.CH"

User Function UPDFERSUB()

    Local aButtons  := {}
    Local aSays     := {}
    Local nOpcA     := 0

    Private aLog        := {}
    Private aTitle      := {}
    Private cProcesso   := "     "
    Private cPeriodo    := "      "
    Private cMatricula  := "      "
    Private cFiltFil    := cFilAnt

    aAdd(aSays,OemToAnsi( 'Esta rotina tem como objetivo preencher o conteúdo do campo "Vb.Subs.Fer" das verbas' ))
    aAdd(aSays,OemToAnsi( 'de férias, que serão substituidas pelas verbas "Vb.Fer.Mes.A"(RV_FERAXML) e ' ))
    aAdd(aSays,OemToAnsi( '"Vb.Fer.Mes"(RV_FERXML) no cálculo de férias(SRR), lançamentos por funcionário(RGB)' ))
    aAdd(aSays,OemToAnsi( "folha aberta(SRC) e folha fechada(SRD), para atender a necessidade do item 3.3" ))
    aAdd(aSays,OemToAnsi( "da nota técnica 04/2025 do leiaute S-1.3 do eSocial."))
    aAdd(aSays, "")
    aAdd(aSays,OemToAnsi( "ATENÇÃO: Efetue o BACKUP da base de dados antes da execução da rotina." ))
    aAdd(aButtons, { 14,.T.,{|| ShellExecute( "open", "https://tdn.totvs.com/pages/releaseview.action?pageId=1016690512", "", "", 1 ) } } )
    aAdd(aButtons, { 5, .T.,{|| fLoadParams() }} )
    AAdd(aButtons, { 1, .T.,{|| nOpcA := 1, Iif(gpconfOK(), FechaBatch(), nOpcA := 0 ) } } )
    aAdd(aButtons, { 2, .T.,{|| FechaBatch() }} )

    //Abre a tela de processamento
    FormBatch( 'Atualização do campo "Vb.Subs.Fer"', aSays, aButtons )

    //Efetua o processamento de geração
    If Empty(cPeriodo) .And. nOpcA == 1
        MsgInfo("O preenchimento do período é obrigatório")
    ElseIf nOpcA == 1 .And. MsgNoYes("Foi efetuado o backup da base de dados?", "Atenção!") .And. MsgYesNo("Tem certeza que deseja continuar?", "Atenção!")
        Aadd( aTitle, OemToAnsi( "Funcionários processados: " ) )
        Aadd( aLog, {} )
        ProcGpe( {|lEnd| fProcessa()},"Aguarde","Processando...",.T. )
        If Empty(aLog[1])
            MsgInfo("Nenhum registro processado")
        EndIf
        fMakeLog(aLog,aTitle,,,"UPDFERSUB",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
    EndIf
Return

/*/{Protheus.doc} fLoadParams
Função para preenchimento dos parametros de processamento
/*/
Static Function fLoadParams()

    Local oDlg
    Local oFont
    Local oSize
    Local lRet  := .F.

    DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

    oSize := FwDefSize():New()
    oSize:AddObject( "CABECALHO",  160, 50, .F., .F. ) // NÃO dimensionavel

    oSize:lProp 	:= .F.            // Proporcional
    oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
    oSize:Process() 	              // Dispara os calculos

    Define MSDialog oDlg Title OemToAnsi("Parâmetros para processamento") FROM 0,0 TO 250,380 OF oMainWnd PIXEL
    	@ oSize:GetDimension("CABECALHO","LININI") +5 , oSize:GetDimension("CABECALHO","COLINI")+10;
    		TO oSize:GetDimension("CABECALHO","LINEND") +30, oSize:GetDimension("CABECALHO","COLEND")+10 LABEL OemToAnsi("Filtro") OF oDlg PIXEL

        @ oSize:GetDimension("CABECALHO","LININI") +18, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Filial: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
        @ oSize:GetDimension("CABECALHO","LININI") +17, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oFilial VAR cFiltFil SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'SM0' VALID Vazio() .Or. ExistCpo("SM0",cEmpAnt + cFiltFil)

        @ oSize:GetDimension("CABECALHO","LININI") +33, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Matricula: ")    SIZE 146,10 OF oDlg PIXEL FONT oFont
        @ oSize:GetDimension("CABECALHO","LININI") +32, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oProcesso VAR cMatricula SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'SRA' VALID Vazio() .Or. ExistCpo("SRA")

        @ oSize:GetDimension("CABECALHO","LININI") +48, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Processo: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
        @ oSize:GetDimension("CABECALHO","LININI") +47, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oProcesso VAR cProcesso SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'RCJ' VALID Vazio() .Or. ExistCpo("RCJ")

        @ oSize:GetDimension("CABECALHO","LININI") +63, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Perí­odo: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
        @ oSize:GetDimension("CABECALHO","LININI") +62, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oPeriodo VAR cPeriodo SIZE 050,10 OF oDlg PIXEL PICTURE "@E 999999" F3 "RCH" VALID NaoVazio()

    	bSet15 := {|| lRet := .T., oDlg:End() }
    	bSet24 := {|| lRet := .F., oDlg:End() }

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

    If lRet
    
        lRet := !Empty(cPeriodo)

        If !lRet
            MsgInfo("O preenchimento do período é obrigatório")
        EndIf

        If lRet .and. Empty(cFiltFil)
           lRet := MsgYesNo( "Filial não foi preenchida. Confirma o processamento para todas as Filiais? " )
        EndIf 

        If lRet .and. Empty(cProcesso)
            lRet := MsgYesNo( "Processo não foi preenchido. Confirma o processamento para todos os processos? " )
        EndIf   

        If lRet .and. Empty(cMatricula)
            lRet := MsgYesNo( "Matrícula não foi preenchida. Confirma o processamento para todas as matrículas? " )
        EndIf   

    EndIf

Return lRet

/*/{Protheus.doc} fProcessa
Função que efetua os ajustes na base
/*/
Static Function fProcessa()

    Local cAliasQry := GetNextAlias()
    Local cQuery    := ""
    Local cWhere    := ""
    Local cVbSubs   := ""
    Local cJoin     := ""
    Local nQtd      := 0
    Local nAtual    := 0

    If !Empty(cFiltFil)
        cWhere += "SRR.RR_FILIAL = '" + cFiltFil + "' AND "
    EndIf

    If !Empty(cProcesso)
       cWhere += "SRR.RR_PROCES = '" + cProcesso + "' AND "
    EndIf

    If !Empty(cMatricula)
        cWhere += "SRR.RR_MAT = '" + cMatricula + "' AND "
    EndIf

    If !Empty(cPeriodo)
        cWhere += "SRR.RR_PERIODO = '" + cPeriodo + "' AND "
    EndIf

    cWhere += "SRR.RR_FERSUB = ' ' "

    //Prepara a variável para uso no BeginSql
    cWhere := "%" + cWhere + "%"
    
    //Cria string para Join de Filiais de acordo com modo de compartilhamento
    cJoin := "%" + FWJoinFilial("SRV", "SRR") + "%"

    BeginSql Alias cAliasQry
       SELECT SRR.RR_FILIAL, 
              SRR.RR_MAT, 
              SRR.RR_PD, 
              SRR.RR_DATAPAG, 
              SRR.RR_FERSUB, 
              SRV.RV_FERXML, 
              SRV.RV_FERAXML
        FROM %table:SRR% SRR
        INNER JOIN %table:SRV% SRV 
            ON SRV.RV_COD = SRR.RR_PD 
            AND %exp:cJoin%
            AND SRV.%NotDel%
        WHERE %exp:cWhere% 
            AND SRR.%NotDel%
        ORDER BY SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_PD
    EndSql

    count to nQtd

    DbSelectArea(cAliasQry)
    DbGoTop()

    GpProcRegua(nQtd)

    While (cAliasQry)->( !EoF() )   
        nAtual++
        GpIncProc("Atualizando registro " + cValToChar(nAtual) + " de " + cValToChar(nQtd) + "...")

        cVbSubs := ""

        If SubStr((cAliasQry)->RR_DATAPAG,1,6) < cPeriodo .And. !Empty((cAliasQry)->RV_FERAXML)
            cVbSubs := (cAliasQry)->RV_FERAXML
        ElseIf !Empty((cAliasQry)->RV_FERXML)
            cVbSubs := (cAliasQry)->RV_FERXML
        EndIf

        If !Empty(cVbSubs)
            cQuery := "UPDATE " + RetSqlName("SRR") + " "
            cQuery += "SET RR_FERSUB = '" + cVbSubs + "' "
            cQuery += "WHERE RR_FILIAL = '" + (cAliasQry)->RR_FILIAL + "' "
            cQuery += "AND RR_MAT = '" + (cAliasQry)->RR_MAT + "' "
            cQuery += "AND RR_PD = '" + (cAliasQry)->RR_PD + "' "
            cQuery += "AND RR_PERIODO = '" + cPeriodo + "' "
            cQuery += "AND D_E_L_E_T_ = ' '"
            TcSqlExec(cQuery)

            cQuery := "UPDATE " + RetSqlName("RGB") + " "
            cQuery += "SET RGB_FERSUB = '" + cVbSubs + "' "
            cQuery += "WHERE RGB_FILIAL  = '" + (cAliasQry)->RR_FILIAL + "' "
            cQuery += "AND RGB_MAT     = '" + (cAliasQry)->RR_MAT + "' "
            cQuery += "AND RGB_PD      = '" + (cAliasQry)->RR_PD + "' "
            cQuery += "AND RGB_PERIOD = '" + cPeriodo + "' "
            cQuery += "AND RGB_FERSUB = ' ' "
            cQuery += "AND D_E_L_E_T_ = ' '"
            TcSqlExec(cQuery)

            cQuery := "UPDATE " + RetSqlName("SRC") + " "
            cQuery += "SET RC_FERSUB = '" + cVbSubs + "' "
            cQuery += "WHERE RC_FILIAL  = '" + (cAliasQry)->RR_FILIAL + "' "
            cQuery += "AND RC_MAT     = '" + (cAliasQry)->RR_MAT + "' "
            cQuery += "AND RC_PD      = '" + (cAliasQry)->RR_PD + "' "
            cQuery += "AND RC_PERIODO = '" + cPeriodo + "' "
            cQuery += "AND RC_FERSUB = ' ' "
            cQuery += "AND D_E_L_E_T_ = ' '"
            TcSqlExec(cQuery)

            cQuery := "UPDATE " + RetSqlName("SRD") + " "
            cQuery += "SET RD_FERSUB = '" + cVbSubs + "' "
            cQuery += "WHERE RD_FILIAL  = '" + (cAliasQry)->RR_FILIAL + "' "
            cQuery += "AND RD_MAT     = '" + (cAliasQry)->RR_MAT + "' "
            cQuery += "AND RD_PD      = '" + (cAliasQry)->RR_PD + "' "
            cQuery += "AND RD_PERIODO = '" + cPeriodo + "' "
            cQuery += "AND RD_FERSUB = ' ' "
            cQuery += "AND D_E_L_E_T_ = ' '"
            TcSqlExec(cQuery)
        EndIf

        aAdd(aLog[1], "Filial: " + (cAliasQry)->RR_FILIAL + " | Matrícula: " + (cAliasQry)->RR_MAT + " | Verba: " + (cAliasQry)->RR_PD + " | Verba substituta incluída: " + If(!Empty(cVbSubs),cVbSubs, "Verba substituta não esta configurada") )

        (cAliasQry)->( dbSkip() )

    EndDo

    If nQtd == 0
        aAdd(aLog[1], "Nenhum registro com campo Vb.Subs.Fer(RR_FERSUB) vazio foi encontrado para os parâmetros informados.")
    EndIf

    (cAliasQry)->( dbCloseArea() )

Return
