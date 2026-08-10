#INCLUDE "LOCA250A.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"

/*/{PROTHEUS.DOC} LOCA250A.PRW
ITUP BUSINESS - TOTVS RENTAL
LIBERACAO DE EQUIPAMENTOS EM LOTE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 21/06/2024
/*/

FUNCTION LOCA250A()
Local aArea	   	    := GETAREA()
Local lMvLocBac	    := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local oTempTable    := Nil
Local aColumns      := {}
Local aOldaRotina   := aRotina
Local cRet00        := ""
Local cRet10        := ""
Local cRet20        := ""
Local cRet50        := ""
Local cRet60        := ""
Local cRet70        := ""
Local cQryLeg

Private oMark
Private cDes00        := ""
Private cDes10        := ""
Private cDes20        := ""
Private cDes50        := ""
Private cDes60        := ""
Private cDes70        := ""
Private cTempTable    := ""
Private oMarkBrowse
Private lMonta        := .T.

    If !lMvLocBac
        Return .F.
    EndIf

    If !Pergunte("LOCA250A")
        Return .F.
    EndIf

    If SELECT("TMPLEG") > 0
        TMPLEG->( DBCLOSEAREA() )
    EndIf

    // Se alterar a legenda aqui, precisa alterar também no LOCA224
    cQryLeg := "SELECT FQD_STATQY , FQD_STAREN FROM "+ RETSQLNAME("FQD") +" WHERE FQD_STAREN IN ('00','10','20','30','40','50','60','70') AND D_E_L_E_T_ = '' "
	TCQUERY cQryLeg NEW ALIAS "TMPLEG"
	While TMPLEG->(!EOF())
        If TMPLEG->FQD_STAREN = "00" 		    // --> 00 - DISPONIVEL               - VERDE
            cRet00 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes00 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes00) .and. !empty(TMPLEG->FQD_STAREN)
                cDes00 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes00)
                cDes00 := STR0009 // Disponivel
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "10" 		// --> 10 - CONTRATO GERADO          - AMARELO
            cRet10 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes10 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes10) .and. !empty(TMPLEG->FQD_STAREN)
                cDes10 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes10)
                cDes10 := STR0010 // "Contrato gerado"
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "20" 		// --> 20 - NF DE REMESSA GERADA     - AZUL
            cRet20 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes20 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes20) .and. !empty(TMPLEG->FQD_STAREN)
                cDes20 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes20)
                cDes20 := STR0011 // "Remessa gerada"
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "50" 		// --> 50 - RETORNO DE LOCACAO       - PRETO
            cRet50 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes50 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes50) .and. !empty(TMPLEG->FQD_STAREN)
                cDes00 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes50)
                cDes50 := STR0012 // "Retorno locação"
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "60" 		// --> 60 - NF DE RETORNO GERADA     - VERMELHO
            cRet60 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes60 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes60) .and. !empty(TMPLEG->FQD_STAREN)
                cDes60 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes60)
                cDes60 := STR0013 // "Retorno gerado"
            EndIf
        ElseIf TMPLEG->FQD_STAREN = "70" 		// --> 70 - Em manutenção - Violeta
            cRet70 += TMPLEG->FQD_STATQY + "*"
            If !empty(TMPLEG->FQD_STATQY)
                cDes70 := Posicione("TQY",1,xfilial("TQY") + TMPLEG->FQD_STATQY,"TQY_DESTAT")
            EndIf
            If empty(cDes70) .and. !empty(TMPLEG->FQD_STAREN)
                cDes70 := Posicione("SX5",1,xFilial("SX5")+"QY"+ TMPLEG->FQD_STAREN,"X5_DESCRI")
            EndIf
            If empty(cDes70)
                cDes70 := STR0013 // "Retorno gerado"
            EndIf
        EndIf
        TMPLEG->(DBSKIP())
    EndDo
    TMPLEG->( DBCLOSEAREA() )

    /*
    MV_PAR01 - Cliente de
    MV_PAR02 - Loja de
    MV_PAR03 - Cliente até
    MV_PAR04 - Loja até
    MV_PAR05 - Projeto de
    MV_PAR06 - Projeto até
    MV_PAR07 - Obra de
    MV_PAR08 - Obra até
    MV_PAR09 - Produto de
    MV_PAR10 - Produto até
    MV_PAR11 - Equipamento de
    MV_PAR12 - Equipamento até
    */

    if LockByName("LOCA250A", .F., .F.)

        //Constrói estrutura da temporária
        cTempTable := fBuildTmp(@oTempTable)

        DbSelectArea(cTempTable)
        (cTempTable)->( DbSetOrder(1) )
        (cTempTable)->( DbGoTop() )

        Processa( {|| MontaLista() },STR0007) // "Localizando os registros"
        If !lMonta
            Return .F.
        EndIF

        //Constrói estrutura das colunas do FWMarkBrowse
        aColumns := fBuildColumns()

        aRotina:={}
        ADD OPTION aRotina TITLE STR0003 ACTION 'LOCA2501()' OPERATION 2 ACCESS 0 // "Liberação"
        ADD OPTION aRotina TITLE STR0004 ACTION 'LOCA2503()' OPERATION 2 ACCESS 0 // "OS Corretiva"
        ADD OPTION aRotina TITLE STR0005 ACTION 'LOCA224L()' OPERATION 2 ACCESS 0 // "Legenda"
        ADD OPTION aRotina TITLE STR0006 ACTION 'LOCA2502()' OPERATION 2 ACCESS 0 // "Seleciona os bens"

        // Se alterar a legenda aqui, precisa alterar também no LOCA224
        oMarkBrowse := FWMarkBrowse():New()
        oMarkBrowse:SetAlias(cTempTable)
        oMarkBrowse:SetDescription(STR0002) //"Liberação de equipamento em lote"
        oMarkBrowse:DisableReport()
        oMarkBrowse:SetFieldMark( 'OK' )    //Campo que será marcado/descmarcado
        oMarkBrowse:AddLegend("STATUS $ '"+cRet00+"'", 'BR_VERDE',    alltrim(cDes00))  //Disponível
        oMarkBrowse:AddLegend("STATUS $ '"+cRet10+"'", 'BR_AMARELO',  alltrim(cDes10))  //Contrato gerado
        oMarkBrowse:AddLegend("STATUS $ '"+cRet20+"'", 'BR_AZUL',     alltrim(cDes20))  //Remessa gerada
        oMarkBrowse:AddLegend("STATUS $ '"+cRet50+"'", 'BR_PRETO',    alltrim(cDes50))  //Retorno locação
        oMarkBrowse:AddLegend("STATUS $ '"+cRet60+"'", 'BR_VERMELHO', alltrim(cDes60))  //Retorno gerado
        oMarkBrowse:AddLegend("STATUS $ '"+cRet70+"'", 'BR_VIOLETA',  alltrim(cDes70))  //Em manutenção
        oMarkBrowse:SetTemporary(.T.)
        oMarkBrowse:SetColumns(aColumns)

        //Inicializa com todos registros marcados
        oMarkBrowse:AllMark()

        //Ativando a janela
        oMarkBrowse:Activate()

        oTempTable:Delete()
        oMarkBrowse:DeActivate()
        FreeObj(oTempTable)
        FreeObj(oMarkBrowse)

        aRotina := aOldaRotina
        UnLockByName("LOCA250A", .F., .F.)
    Else
        Help( ,, "LOCA250",, STR0001, 1, 0,,,,,,{STR0008}) //"Inconsistência nos dados."###"Rotina em uso por outro usuário."
    EndIF

    RestArea(aArea)
Return .T.

/*/{PROTHEUS.DOC} LOCA250A.PRW
ITUP BUSINESS - TOTVS RENTAL
MONTAGEM DA TABELA TEMPORARIA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/
Static Function fBuildTmp(oTempTable)

    Local cAliasTemp := "ZMARC_"+FWTimeStamp(1)
    Local aFields    := {}

    //Monta estrutura de campos da temporária
    aAdd(aFields, { "OK"    , "C", 2                        , 0 })
    aAdd(aFields, { "DOC"   , "C", GetSx3Cache("FQ4_DOCUME" ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "BEM"   , "C", GetSx3Cache("FQ4_CODBEM" ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "NOMBEM", "C", GetSx3Cache("T9_NOME"    ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "STATUS", "C", GetSx3Cache("FQ4_STATUS" ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "DESCRI", "C", GetSx3Cache("FQD_DESREN" ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "CODCLI", "C", GetSx3Cache("FQ4_CODCLI" ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "LOJCLI", "C", GetSx3Cache("FQ4_LOJCLI" ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "NOMCLI", "C", GetSx3Cache("FQ4_NOMCLI" ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "PROJET", "C", GetSx3Cache("FQ4_PROJET" ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "ASX"   , "C", GetSx3Cache("FQ4_AS"     ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "PRODUT", "C", GetSx3Cache("B1_COD"     ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "OBRA"  , "C", GetSx3Cache("FPA_OBRA"   ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "XORDEM" , "C", GetSx3Cache("TJ_ORDEM"   ,"X3_TAMANHO"), 0 })
    aAdd(aFields, { "SEQ"   , "C", GetSx3Cache("FQ4_SEQ"    ,"X3_TAMANHO"), 0 })

    oTempTable:= FWTemporaryTable():New(cAliasTemp)
    oTemptable:SetFields( aFields )
    oTempTable:AddIndex("01", {"BEM"} )
    oTempTable:Create()

Return oTempTable:GetAlias()

/*/{PROTHEUS.DOC} LOCA250A.PRW
ITUP BUSINESS - TOTVS RENTAL
MONTAGEM DAS COLUNAS DA LISTBOX
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/
Static Function fBuildColumns()

    Local nX       := 0
    Local aColumns := {}
    Local aStruct  := {}

    aAdd(aStruct, { "OK"    , "C", 2                        , 0 })
    aAdd(aStruct, { "DOC"   , "C", GetSx3Cache("FQ4_DOCUME" ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_DOCUME" , "X3_TITULO") })
    aAdd(aStruct, { "BEM"   , "C", GetSx3Cache("FQ4_CODBEM" ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_CODBEM" , "X3_TITULO") })
    aAdd(aStruct, { "NOMBEM", "C", GetSx3Cache("T9_NOME"    ,"X3_TAMANHO"), 0, GetSx3Cache("T9_NOME"    , "X3_TITULO") })
    aAdd(aStruct, { "STATUS", "C", GetSx3Cache("FQ4_STATUS" ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_STATUS" , "X3_TITULO") })
    aAdd(aStruct, { "DESCRI", "C", GetSx3Cache("FQD_DESREN" ,"X3_TAMANHO"), 0, GetSx3Cache("FQD_DESREN" , "X3_TITULO") })
    aAdd(aStruct, { "CODCLI", "C", GetSx3Cache("FQ4_CODCLI" ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_CODCLI" , "X3_TITULO") })
    aAdd(aStruct, { "LOJCLI", "C", GetSx3Cache("FQ4_LOJCLI" ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_LOJCLI" , "X3_TITULO") })
    aAdd(aStruct, { "NOMCLI", "C", GetSx3Cache("FQ4_NOMCLI" ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_NOMCLI" , "X3_TITULO") })
    aAdd(aStruct, { "PROJET", "C", GetSx3Cache("FQ4_PROJET" ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_PROJET" , "X3_TITULO") })
    aAdd(aStruct, { "ASX"   , "C", GetSx3Cache("FQ4_AS"     ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_AS"     , "X3_TITULO") })
    aAdd(aStruct, { "PRODUT", "C", GetSx3Cache("B1_COD"     ,"X3_TAMANHO"), 0, GetSx3Cache("B1_COD"     , "X3_TITULO") })
    aAdd(aStruct, { "OBRA"  , "C", GetSx3Cache("FPA_OBRA"   ,"X3_TAMANHO"), 0, GetSx3Cache("FPA_OBRA"   , "X3_TITULO") })
    aAdd(aStruct, { "XORDEM" , "C", GetSx3Cache("TJ_ORDEM"   ,"X3_TAMANHO"), 0, GetSx3Cache("TJ_ORDEM"   , "X3_TITULO") })
    aAdd(aStruct, { "SEQ"   , "C", GetSx3Cache("FQ4_SEQ"    ,"X3_TAMANHO"), 0, GetSx3Cache("FQ4_SEQ"    , "X3_TITULO") })

    For nX := 2 To Len(aStruct)
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(aStruct[nX][5])
        aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
        aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
    Next nX
Return aColumns


/*/{PROTHEUS.DOC} LOCA250A.PRW
ITUP BUSINESS - TOTVS RENTAL
LOCALIZA OS REGISTROS VALIDOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/
Static Function MontaLista
Local cQuery
//Local cUser		    := RETCODUSR(SUBSTR(CUSUARIO,7,15))
//Local lUser         := .T.
Local cTemps60      := ""
Local cTemps50      := ""
Local aBindParam    := {}
Local cTemps70      := ""
Local aArea         := GetArea()

    ProcRegua(0)

    IncProc()

    //If !FQ1->(DBSEEK(XFILIAL("FQ1") + cUser + "LOCA250" , .T.)) // Tabela de permissoes
    //    lUser := .F.
    //EndIf

    FQD->(dbSetOrder(1))
    FQD->(dbGotop())
    While !FQD->(Eof())
        If FQD->FQD_STAREN == "60"
            cTemps60 := FQD->FQD_STATQY
        EndIF
        If FQD->FQD_STAREN == "50"
            cTemps50 := FQD->FQD_STATQY
        EndIF
        If FQD->FQD_STAREN == "70"
            cTemps70 := FQD->FQD_STATQY
        EndIF
        FQD->(dbSkip())
        IncProc()
    EndDo

    If empty(cTemps50) .or. empty(cTemps60) .or. empty(cTemps70)
        Help( ,, "LOCA250A-MONTALISTA",, STR0001, 1, 0,,,,,,{STR0023}) //"Inconsistência nos dados."###"Falta o preenchimento do status 50,60 ou 70 na tabela status do bem (FQD)."
        RestArea(aArea)
        lMonta := .F.
        Return .F.
    EndIF

    //Alimenta a tabela temporária
    cQuery := " SELECT FQ4.R_E_C_N_O_ AS REG "
    cQuery += " FROM " + RetSqlName("FQ4") + " FQ4 "
    cQuery += " WHERE FQ4.D_E_L_E_T_ = '' "
    cQuery += " AND FQ4.FQ4_FILIAL = '"+xFilial("FQ4")+"' "
    cQuery += " AND FQ4.FQ4_STATUS <> '' "
    cQuery += " AND (FQ4.FQ4_STATUS = ? OR FQ4.FQ4_STATUS = ? OR FQ4.FQ4_STATUS = ? OR FQ4.FQ4_STATUS = ?)
    Aadd(aBindParam, LOCA224K() ) // 00 - Disponível
    Aadd(aBindParam, cTemps50 ) // 50
    Aadd(aBindParam, cTemps60 ) // 60
    Aadd(aBindParam, cTemps70 ) // 70
    //If !lUser
    //    cQuery += " AND (FQ4.FQ4_STATUS = '"+cTemps60+"' OR FQ4.FQ4_STATUS = '"+cTemps50+"') "
    //EndIF
    cQuery += " AND FQ4.FQ4_CODCLI >= ? AND FQ4.FQ4_CODCLI <= ? "
    Aadd(aBindParam, MV_PAR01)
    Aadd(aBindParam, MV_PAR03)
    cQuery += " AND FQ4.FQ4_LOJCLI >= ? AND FQ4.FQ4_LOJCLI <= ? "
    Aadd(aBindParam, MV_PAR02)
    Aadd(aBindParam, MV_PAR04)
    cQuery += " AND FQ4.FQ4_PROJET >= ? AND FQ4.FQ4_PROJET <= ? "
    Aadd(aBindParam, MV_PAR05)
    Aadd(aBindParam, MV_PAR06)
    cQuery += " AND FQ4.FQ4_CODBEM >= ? AND FQ4.FQ4_CODBEM <= ? "
    Aadd(aBindParam, MV_PAR11)
    Aadd(aBindParam, MV_PAR12)
    cQuery += " AND FQ4.FQ4_SEQ = (SELECT MAX(FQ4A.FQ4_SEQ) FROM "+ RetSqlName("FQ4") + " FQ4A "
    cQuery += " WHERE FQ4A.D_E_L_E_T_ = '' "
    cQuery += " AND FQ4A.FQ4_FILIAL = '"+xFilial("FQ4")+"' "
    cQuery += " AND FQ4A.FQ4_CODBEM = FQ4.FQ4_CODBEM "
    cQuery += ") "

    cQuery := changequery(cQuery)

    If SELECT("TRBFQ4") > 0
		TRBFQ4->( DBCLOSEAREA() )
	EndIf

    MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)

    ST9->(dbSetOrder(1))
    FPA->(dbSetOrder(3))
    FQD->(dbSetOrder(2))
    While !TRBFQ4->(Eof())
        IncProc()
        FQ4->(dbgoto(TRBFQ4->(REG)))
        FQD->(dbSeek(xFilial("FQD")+FQ4->FQ4_STATUS))
        ST9->(dbSeek(xFilial("ST9")+FQ4->FQ4_CODBEM))
        If ST9->T9_SITMAN <> 'A' .OR. ST9->T9_SITBEM <> 'A' "
            TRBFQ4->(dbSkip())
            Loop
        EndIF
        If FPA->(dbSeek(xFilial("FPA")+FQ4->FQ4_AS)) .and. !empty(FQ4->FQ4_AS)
            If FPA->FPA_OBRA < MV_PAR07 .OR. FPA->FPA_OBRA > MV_PAR08
                TRBFQ4->(dbSkip())
                Loop
            EndIF
            If FPA->FPA_PRODUT < MV_PAR09 .or. FPA->FPA_PRODUT > MV_PAR10
                TRBFQ4->(dbSkip())
                Loop
            EndIF
        EndIF
        If( RecLock(cTempTable, .T.) )
            (cTempTable)->DOC    := FQ4->FQ4_DOCUME
            (cTempTable)->BEM    := FQ4->FQ4_CODBEM
            (cTempTable)->NOMBEM := ST9->T9_NOME
            (cTempTable)->STATUS := FQ4->FQ4_STATUS
            (cTempTable)->DESCRI := FQD->FQD_DESTQY
            (cTempTable)->CODCLI := FQ4->FQ4_CODCLI
            (cTempTable)->LOJCLI := FQ4->FQ4_LOJCLI
            (cTempTable)->NOMCLI := FQ4->FQ4_NOMCLI
            (cTempTable)->PROJET := FQ4->FQ4_PROJET
            (cTempTable)->ASX    := FQ4->FQ4_AS
            (cTempTable)->PRODUT := FPA->FPA_PRODUT
            (cTempTable)->OBRA   := FPA->FPA_OBRA
            (cTempTable)->XORDEM  := FQ4->FQ4_OS
            (cTempTable)->SEQ    := FQ4->FQ4_SEQ

            If empty(FQ4->FQ4_PROJET) .and. !empty(FQ4->FQ4_AS)
                FPA->(dbSetOrder(3))
                If FPA->(dbSeek(xFilial("FPA")+FQ4->FQ4_AS))
                    (cTempTable)->PROJET := FPA->FPA_PROJETO
                    (cTempTable)->OBRA := FPA->FPA_OBRA
                EndIF
            EndIf


            (cTempTable)->(MsUnLock())
        EndIf
        TRBFQ4->(dbSkip())
    EndDo

    TRBFQ4->( DBCLOSEAREA() )
    RestArea(aArea)

Return .T.

/*/{PROTHEUS.DOC} LIBERA250.PRW
ITUP BUSINESS - TOTVS RENTAL
LIBERA OS REGISTROS SELECIONADOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/
Function LOCA2501
    If MsgYesNo(STR0015,STR0016) // "Confirma a liberação dos bens?"###"Atenção!"
        Processa( {|| LIBER250() },STR0014) //"Liberando os bens selecionados."
    EndIF
Return .T.

/*/{PROTHEUS.DOC} LIBER250.PRW
ITUP BUSINESS - TOTVS RENTAL
LIBERA OS REGISTROS SELECIONADOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/
Static Function LIBER250()
Local cSTSANTI
Local cQRYLEG  := "SELECT FQD_STATQY FROM "+ RETSQLNAME("FQD") +" FQD WHERE FQD.FQD_STAREN = '00' AND FQD.D_E_L_E_T_ = ' ' AND FQD.FQD_FILIAL = '"+xFilial("FQD")+"' "
Local cSTSNOVO := ""
Local cBem
Local cSeq

    ProcRegua(0)

    If SELECT("TMPLEG") > 0
        TMPLEG->( DBCLOSEAREA() )
    EndIf
    TCQUERY CQRYLEG NEW ALIAS "TMPLEG"
    If TMPLEG->(!EOF())
        CSTSNOVO := TMPLEG->FQD_STATQY
    EndIf
    TMPLEG->( DBCLOSEAREA() )

    FQ4->(dbSetOrder(1))
    ST9->(dbSetOrder(1))
    (cTempTable)->(dbGotop())
    While !(cTempTable)->(Eof())
        IncProc()
        If !empty((cTempTable)->(OK))
            cBem := (cTempTable)->(BEM)
            cSeq := (cTempTable)->(SEQ)
            If FQ4->(dbSeek(xFilial("FQ4")+cBem))
                While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4")+cBem
                    If FQ4->FQ4_SEQ == cSeq
                        If FQ4->FQ4_STATUS <> LOCA224K() // diferente de disponível
                            cSTSANTI := FQ4->FQ4_STATUS
                            ST9->(dbSeek(xFilial("ST9")+cBem))
                            ST9->(RECLOCK("ST9",.F.))
                            ST9->T9_STATUS := CSTSNOVO
                            ST9->(MSUNLOCK())
                            LOCXITU21(CSTSANTI, CSTSNOVO, FQ4->FQ4_PROJET , "", "")

                            (cTempTable)->(RecLock((cTempTable),.F.))
                            (cTempTable)->(XORDEM) := ""
                            (cTempTable)->(STATUS) := CSTSNOVO
                            (cTempTable)->(MsUnlock())

                        EndIF
                        Exit
                    EndIF
                    FQ4->(dbSkip())
                EndDo
            EndIf
        EndIF
        (cTempTable)->(dbSkip())
    EndDo
    (cTempTable)->(dbGotop())
    While !(cTempTable)->(Eof())
        (cTempTable)->(RecLock((cTempTable),.F.))
        (cTempTable)->(OK) := space(2)
        (cTempTable)->(MsUnlock())
        (cTempTable)->(dbSkip())
        IncProc()
    EndDo
    (cTempTable)->(dbGotop())
Return


/*/{PROTHEUS.DOC} LOCA2502
ITUP BUSINESS - TOTVS RENTAL
BIPAR AS AS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/

Function LOCA2502
Local ODLGBIP
Local lOk := .F.
Local nX
Local aResult := {}

Private cBem := space(TamSx3("T9_CODBEM")[1])
Private oBem
Private OOK := LOADBITMAP( GETRESOURCES(), "LBOK" )
Private ONO := LOADBITMAP( GETRESOURCES(), "LBNO" )
Private aLinha := {}
Private oLbx

	aadd(aLinha, { .F., cBem } )

    DEFINE MSDIALOG ODLGBIP TITLE STR0006  FROM 10,359 TO 500,882 PIXEL	// "Seleciona os bens"
    @ 45,11 SAY STR0017 SIZE 40,08 PIXEL OF ODLGBIP //"Código do bem:"
    @ 43,55 GET oBem VAR cBem valid LOCA250A1() SIZE 70,8 PIXEL OF ODLGBIP
                                                        // C,L
    @ 60,05 LISTBOX oLbx FIELDS HEADER "", STR0017  SIZE 255,175 OF ODLGBIP PIXEL ON DBLCLICK (MARCARREGI()) //"Código do bem:"

	OLBX:SETARRAY(ALINHA)
	OLBX:BLINE := {|| { IF( ALINHA[OLBX:NAT,1],OOK,ONO),ALINHA[OLBX:NAT,2] }}

    ACTIVATE MSDIALOG ODLGBIP CENTERED ON INIT ENCHOICEBAR(ODLGBIP, {||LOK:=.T., aResult:=aclone(OLBX:AARRAY) ,ODLGBIP:END()},{||ODLGBIP:END()},,{})

    If lOk
        (cTempTable)->(dbGotop())
        While !(cTempTable)->(Eof())
            For nX := 1 to len(aResult)
                If aResult[nX,1]
                    If aResult[nX,2] == (cTempTable)->(BEM)
                        (cTempTable)->(RecLock((cTempTable),.F.))
                        (cTempTable)->(OK) := oMarkBrowse:Mark()
                        (cTempTable)->(MsUnlock())
                        Exit
                    EndIF
                EndIf
            Next
            (cTempTable)->(dbSkip())
        EndDo
    EndIf

Return .T.

/*/{PROTHEUS.DOC} MARCARREGI
ITUP BUSINESS - TOTVS RENTAL
CONTROLE NA SELECAO DOS BENS NA LISTBOX
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/

STATIC FUNCTION MARCARREGI()
LOCAL LMARCADOS := ALINHA[OLBX:NAT,1]
	ALINHA[OLBX:NAT,1] := ! LMARCADOS
	OLBX:AARRAY[OLBX:NAT,1] := ALINHA[OLBX:NAT,1]

    If empty(ALINHA[OLBX:NAT,2])
        OLBX:AARRAY[OLBX:NAT,1] := .F.
    EndIf

	OLBX:REFRESH()
RETURN NIL


/*/{PROTHEUS.DOC} LOCA250A1
ITUP BUSINESS - TOTVS RENTAL
VALIDACAO DO CAMPO BEM
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/
Function LOCA250A1()
Local lRet := .T.
Local nX
Local cBemx := &(ReadVar())
Local lPreenche := .T.
Local lExiste := .F.

    For nX := 1 to len(OLBX:AARRAY)
        If OLBX:AARRAY[nX,2] == cBemx
            lPreenche := .F.
        EndIf
    Next

    If empty(cBemX)
        lPreenche := .F.
    EndIF

    (cTempTable)->(dbGotop())
    While !(cTempTable)->(Eof())
        If BEM == cBemx
            lExiste := .T.
            Exit
        EndIf
        (cTempTable)->(dbSkip())
    EndDo

    If !lExiste .and. !empty(cBemx)
        lPreenche := .F.
        Help( ,, "LOCA250A1",, STR0001, 1, 0,,,,,,{STR0018}) //"Inconsistência nos dados."###"Bem não localizado na lista."
    EndIf

    If lPreenche
        If !empty(OLBX:AARRAY[OLBX:NAT,2])
            aadd(OLBX:AARRAY,{.T.,cBemx})
        Else
            OLBX:AARRAY[1,2] := cBemx
            OLBX:AARRAY[1,1] := .T.
        EndIf
    EndIF

    OLBX:REFRESH()
    cBemx := space(TamSx3("T9_CODBEM")[1])
    obem:ctext := cBemX
    oBem:refresh()
    oBem:setfocus()

Return lRet

/*/{PROTHEUS.DOC} LOCA2503
ITUP BUSINESS - TOTVS RENTAL
GERACAO DA OS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/
Function LOCA2503()
Private CSTSNOVO := ""

    FQD->(dbGotop())
    While !FQD->(Eof())
        If FQD->FQD_STAREN == "70"
            CSTSNOVO := FQD->FQD_STATQY
            Exit
        EndIF
        FQD->(dbSkip())
    EndDo

    If empty(CSTSNOVO)
        Help( ,, "LOCA2503",, STR0001, 1, 0,,,,,,{STR0022}) //"Inconsistência nos dados."###"Status 70-Manutenção não localizado na tabela de status do bem (FQD)."
        Return .F.
    EndIF

    If empty(MV_PAR13)
        Help( ,, "LOCA2503",, STR0001, 1, 0,,,,,,{STR0020}) //"Inconsistência nos dados."###"Faltou informar o serviço nos parâmetros."
        Return .F.
    EndIf

    M->TJ_SERVICO := MV_PAR13
    If !CHKSER()
        Help( ,, "LOCA2503",, STR0001, 1, 0,,,,,,{STR0021}) //"Inconsistência nos dados."###"Serviço inválido."
        Return .F.
    EndIF

    If MsgYesNo("Confirma a geração das OS?","Atenção!")
        Processa( {|| LOCA2503A() },STR0019) // "Gerando as OS"
    EndIF

Return .T.

/*/{PROTHEUS.DOC} LOCA2503A
ITUP BUSINESS - TOTVS RENTAL
GERACAO DA OS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/06/2024
/*/
Function LOCA2503A()
Local cRet00 := ""
Local cRet50 := ""
Local cRet60 := ""
Local cRet70 := ""
Local cQryLeg
Local aRet
Local cOSGer := ""

    // Se alterar a legenda aqui, precisa alterar também no LOCA224
    cQryLeg := "SELECT FQD_STATQY , FQD_STAREN FROM "+ RETSQLNAME("FQD") +" WHERE FQD_STAREN IN ('00','50','60','70') AND D_E_L_E_T_ = '' "
	TCQUERY cQryLeg NEW ALIAS "TMPLEG"
	While TMPLEG->(!EOF())
        If TMPLEG->FQD_STAREN = "00" 		    // --> 00 - DISPONIVEL
            cRet00 += TMPLEG->FQD_STATQY + "*"
        //ElseIf TMPLEG->FQD_STAREN = "10" 		// --> 10 - CONTRATO GERADO
        //    cRet10 += TMPLEG->FQD_STATQY + "*"
        //ElseIf TMPLEG->FQD_STAREN = "20" 		// --> 20 - NF DE REMESSA GERADA
        //    cRet20 += TMPLEG->FQD_STATQY + "*"
        ElseIf TMPLEG->FQD_STAREN = "50" 		// --> 50 - RETORNO DE LOCACAO
            cRet50 += TMPLEG->FQD_STATQY + "*"
        ElseIf TMPLEG->FQD_STAREN = "60" 		// --> 60 - NF DE RETORNO GERADA
            cRet60 += TMPLEG->FQD_STATQY + "*"
        ElseIf TMPLEG->FQD_STAREN = "70" 		// --> 70 - EM MANUTENCAO
            cRet70 += TMPLEG->FQD_STATQY + "*"
        EndIf
        TMPLEG->(DBSKIP())
    EndDo
    TMPLEG->( DBCLOSEAREA() )

    (cTempTable)->(dbGotop())
    While !(cTempTable)->(Eof())
        If !empty((cTempTable)->(OK)) .and. ( (cTempTable)->(STATUS) $ cRet00 .or. (cTempTable)->(STATUS) $ cRet50 .or. (cTempTable)->(STATUS) $ cRet60  )

            // Gerar a OS
            aRet := NGGERAOS("C", dDatabase, (cTempTable)->(BEM), MV_PAR13, '0','N','N','N',cFilAnt,"L")

            If len(aRet) > 0

                // Campos exclusivos do Rental
                STJ->(RecLock("STJ",.F.))
                STJ->TJ_AS		:= (cTempTable)->(ASX)
                STJ->TJ_PROJETO	:= (cTempTable)->(PROJET)
                STJ->TJ_OBRA	:= (cTempTable)->(OBRA)
                STJ->(MsUnlock())

                // Atualizar o status no cadastro do bem e incrementar o gerenciamento de bens
                cSTSANTI := (cTempTable)->(STATUS)
                ST9->(dbSeek(xFilial("ST9")+(cTempTable)->(BEM)))
                ST9->(RECLOCK("ST9",.F.))
                ST9->T9_STATUS := CSTSNOVO // EM MANUTENCAO
                ST9->(MSUNLOCK())
                LOCXITU21(CSTSANTI, CSTSNOVO, (cTempTable)->(PROJET) , "", "")

                // Gravar a numeracao da OS no gerencamento de bens
                // Por ter gerado uma nova linha no gerenciamento via LOCXITU21 já está posicionado no registro
                FQ4->(RecLock("FQ4"),.F.)
                FQ4->FQ4_OS := aRet[1,3]
                FQ4->(MsUnlock())

                // Gravar na tabela temporária
                If( RecLock(cTempTable, .F.) )
                    (cTempTable)->XORDEM  := FQ4->FQ4_OS
                    (cTempTable)->STATUS := ST9->T9_STATUS
                    (cTempTable)->(MsUnLock())
                EndIf

                cOSGer += "[" + alltrim(aRet[1,3]) + "]"

            EndIF

        EndIf
        (cTempTable)->(dbSkip())
        IncProc()
    EndDo

    If !Empty(cOSGer)
        Aviso("Ordens de Serviço Geradas","OS Geradas : "+cOSGer, {"Ok"})
    endif

    (cTempTable)->(dbGotop())
    While !(cTempTable)->(Eof())
        (cTempTable)->(RecLock((cTempTable),.F.))
        (cTempTable)->(OK) := space(2)
        (cTempTable)->(MsUnlock())
        (cTempTable)->(dbSkip())
        IncProc()
    EndDo
Return
