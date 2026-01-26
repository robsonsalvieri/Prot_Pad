#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM026.CH"

Function GPEM026K()

    Local aButtons  := {}
    Local aSays     := {}
    Local cMsg      := ""
    Local nOpcA     := 0
    Local aErros	:= {}
    Local cMsgHelp	:= ""
    Local cLink		:= 'https://tdn.totvs.com/x/FJHzLQ'

    Private aLog    := {}
    Private aTitle  := {}
    Private cPerg   := "GPEM026K"

    // VERIFICA SE ENCONTROU O GRUPO DE PERGUNTAS
    If !SX1->(DbSeek('GPEM026K'))
        cMsg :=  + CRLF + OemToAnsi(STR0273) + Alltrim(cPerg) //Não foi encontrado o grupo de perguntas

        cMsgHelp := ""
        //Antes de prosseguir será necessário criar o grupo de perguntas. Para isso, siga as instruções contidos no link abaixo:
        cMsgHelp += + CRLF + OemToAnsi(STR0274)
        cMsgHelp += + CRLF + cLink + CRLF

        aAdd(aErros, cMsgHelp)

        Help(,, 'NOPERGUNT',, cMsg, 1, 0,,,,,, {aErros})

        Return()
    EndIf

    aAdd(aSays,OemToAnsi( STR0379 )) //Este programa tem por objetivo gerar uma verba de no cálculo de férias com valor
    aAdd(aSays,OemToAnsi( STR0380 )) //correspondente ao Id 0569. A correta configuração desta verba assim como maiores 
    aAdd(aSays,OemToAnsi( STR0381 )) //informações deste ajuste podem ser consultadas em nossa documentação.
    aAdd(aSays,OemToAnsi( STR0382 )) //Clique em abrir para consultar.


    aAdd(aButtons, { 14,.T.,{|| ShellExecute("open",cLink,"","",1) } } )
    aAdd(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
    aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
    aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

    //Abre a tela de processamento
    FormBatch( OemToAnsi( STR0383 ), aSays, aButtons ) //"Ajuste para devolução de IR Férias"

    //Efetua o processamento de geração
    If nOpcA == 1
        Aadd( aTitle, OemToAnsi( STR0384 ) ) //"Funcionários ajustados:"
        Aadd( aLog, {} )
        ProcGpe( {|lEnd| fProcessa()},,,.T. )
        fMakeLog(aLog,aTitle,,,"GPEM026K",OemToAnsi( STR0296 ),"M","P",,.F.) //"Log de Ocorrências"
    EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua o processamento para a geração dos Id`s
/*/
Static Function fProcessa()

    Local cAliasQry := GetNextAlias()
    Local cAliasMov  := GetNextAlias()
    Local cJoinRRRV	:= "% " + FWJoinFilial( "SRR", "SRV" ) + " %"
    Local cFilOld   := cFilAnt
    Local cWhere    := ""
    Local cFilRROld := ""
    Local cMatRROld := ""
    Local cQrySt    := ""
    Local cPd0569   := ""
    Local cDtIni    := ""
    Local cDtFim    := ""
    Local CREGGRV   := ""
    Local nVlrIR    := 0
    Local nVlrEstIR := 0
    Local lProc     := .F.
    Local aCodFol   := {}
    Local __oSt01 := Nil

    //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
    Fp_CodFol(@aCodFol, xFilial("SRV", cFilAnt), .F., .F.)

    Pergunte( cPerg, .F. )
    MakeSqlExpr( cPerg )

    //Filial
    If !Empty(mv_par01)
        cWhere += mv_par01
    EndIf

    //Matricula
    If !Empty(mv_par02)
        cWhere += Iif(!Empty(cWhere)," AND ","")
        cWhere += mv_par02
    EndIf

    If Empty(mv_par03) .Or. Empty(mv_par04)
        aAdd( aLog[1],  OemToAnsi( STR0385 )) //"Verifique o preenchimento dos parâmetros. Período ou verba não foi informada."
        Return
    EndIf

    //Periodo
    cDtIni := mv_par03+"01"
    cDtFim := dtos(lastday(stod(mv_par03+"01")))
    cWhere += Iif(!Empty(cWhere)," AND ","")
    cWhere += "SRR.RR_DATAPAG BETWEEN '" + cDtIni +"' AND  '" + cDtFim +"' "   

    //Prepara a variável para uso no BeginSql
    cWhere := "%" + cWhere + "%"

    //Processa a query e cria a tabela temporária com os resultados
    BeginSql alias cAliasQry
        SELECT SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_PD, SRR.RR_DATA, SRR.RR_PERIODO, SRR.RR_SEMANA,
            SRR.RR_DATAPAG, SRR.RR_VALOR, SRR.RR_SEQ, SRR.RR_PROCES, SRR.RR_DTREF, SRR.RR_CC
        FROM %table:SRR% SRR
        INNER JOIN %table:SRV% SRV
        ON	%exp:cJoinRRRV% AND
            SRV.RV_COD = SRR.RR_PD AND
            SRV.%notDel%
        WHERE %exp:cWhere% AND
            SRV.RV_CODFOL = '0067' AND
            SRR.RR_TIPO3 = 'F' AND
            SRR.%notDel%
        GROUP BY SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_PD, SRR.RR_DATA, SRR.RR_PERIODO, SRR.RR_SEMANA, 
            SRR.RR_DATAPAG, SRR.RR_VALOR, SRR.RR_SEQ, SRR.RR_PROCES, SRR.RR_DTREF, SRR.RR_CC
        ORDER BY SRR.RR_FILIAL, SRR.RR_MAT, SRR.RR_PD, SRR.RR_DATA, SRR.RR_PERIODO, SRR.RR_SEMANA, 
            SRR.RR_DATAPAG, SRR.RR_VALOR, SRR.RR_SEQ, SRR.RR_PROCES, SRR.RR_DTREF, SRR.RR_CC
    EndSql

    While (cAliasQry)->( !EoF() )

        //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
        If xFilial("SRV",(cAliasQry)->RR_FILIAL) != xFilial("SRV",cFilOld)
            cFilOld := (cAliasQry)->RR_FILIAL
            cPd0569 := ""
            aCodFol := {}
            Fp_CodFol(@aCodFol, xFilial("SRV", (cAliasQry)->RR_FILIAL))
        EndIf

        //Obtém o código da verba de Id 0659
        If Len(aCodFol) >= 659 .And. !Empty(aCodFol[659,1])
            cPd0569 := aCodFol[659,1]
        EndIf

        //Obtém o valor do IR
        nVlrIR  := (cAliasQry)->RR_VALOR

        If !Empty(cPd0569) .And. (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT <> cFilRROld + cMatRROld
			If __oSt01 == Nil
				__oSt01 := FWPreparedStatement():New()
				cQrySt := "SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PD, SRD.RD_VALOR, SRD.RD_PERIODO, SRD.RD_ROTEIR, SRD.RD_SEMANA "
				cQrySt += "FROM " + RetSqlName('SRD') + " SRD "
				cQrySt += "WHERE SRD.RD_FILIAL = ? AND "
				cQrySt += 		"SRD.RD_MAT = ? AND "
				cQrySt += 		"SRD.RD_PERIODO = '" + mv_par03 + "' AND "
                cQrySt += 		"SRD.RD_PD = '" + cPd0569 + "' AND "
				cQrySt += 		"SRD.RD_EMPRESA = '  ' AND "
				cQrySt += 		"SRD.D_E_L_E_T_ = ' ' "
				cQrySt += "GROUP BY SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_PD, SRD.RD_VALOR, SRD.RD_PERIODO, SRD.RD_ROTEIR, SRD.RD_SEMANA "
				cQrySt += "UNION ALL "
				cQrySt += "SELECT SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PD, SRC.RC_VALOR, SRC.RC_PERIODO, SRC.RC_ROTEIR, SRC.RC_SEMANA "
				cQrySt += "FROM " + RetSqlName('SRC') + " SRC "
				cQrySt += "WHERE SRC.RC_FILIAL = ? AND "
				cQrySt += 		"SRC.RC_MAT = ? AND "
				cQrySt += 		"SRC.RC_PERIODO = '" + mv_par03 + "' AND "
                cQrySt += 		"SRC.RC_PD = '" + cPd0569 + "' AND "
				cQrySt += 		"SRC.D_E_L_E_T_ = ' ' "
				cQrySt += "GROUP BY SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PD, SRC.RC_VALOR, SRC.RC_PERIODO, SRC.RC_ROTEIR, SRC.RC_SEMANA "
				cQrySt += "ORDER BY 1, 2 "
				cQrySt := ChangeQuery(cQrySt)
				__oSt01:SetQuery(cQrySt)
			EndIf
			__oSt01:SetString(1, (cAliasQry)->RR_FILIAL)
			__oSt01:SetString(2, (cAliasQry)->RR_MAT)
			__oSt01:SetString(3, (cAliasQry)->RR_FILIAL)
			__oSt01:SetString(4, (cAliasQry)->RR_MAT)
			cQrySt := __oSt01:getFixQuery()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySt),cAliasMov,.T.,.T.)
        EndIf

        If !Empty(cPd0569) .And. (cAliasMov)->( !EoF() )
            nVlrEstIR := (cAliasMov)->RD_VALOR 

            If nVlrEstIR <= nVlrIR .And. (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT <> cRegGrv
                lProc   := .T.
                cRegGrv := (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT
                fGrava((cAliasQry)->RR_FILIAL, (cAliasQry)->RR_MAT, MV_PAR04, (cAliasQry)->RR_DATA, (cAliasQry)->RR_PERIODO, (cAliasQry)->RR_SEMANA, (cAliasQry)->RR_DATAPAG, (cAliasQry)->RR_SEQ, (cAliasQry)->RR_PROCES, (cAliasQry)->RR_DTREF, (cAliasQry)->RR_CC, nVlrEstIR)
            EndIf
        EndIf

        cFilRROld   := (cAliasQry)->RR_FILIAL
        cMatRROld   := (cAliasQry)->RR_MAT

        //Pula para o próximo registro
        (cAliasQry)->( dbSkip() )

        IF (cAliasQry)->RR_FILIAL + (cAliasQry)->RR_MAT <> cFilRROld + cMatRROld
            (cAliasMov)->(dbCloseArea())
        EndIf
    EndDo

    //Fecha a tabela temporária da query
    (cAliasQry)->( dbCloseArea() )

    If !lProc
        aAdd( aLog[1],  OemToAnsi( STR0299 )) //"Não foram encontrados registros para processamento."
    EndIf

Return

/*/{Protheus.doc} fGrava
Função responsável pela gravação das verbas
/*/
Static Function fGrava(cCodFil, cCodMat, cPD, cData, cPer, cSem, cDtPag, cSeq, cProc, cDtRef, cCenCus, nValor)

    Local aArea	    := GetArea()
    Local aAreaSRR  := SRR->(GetArea())
    Local lNovo := .T.

    SRR->( dbSetOrder(1) )
    lNovo := SRR->( !dbSeek( cCodFil + cCodMat + "F" + cData + cPD + cCenCus ))

    //Grava a verba 
    If nValor > 0
        //Trava o registro na SRR para edição
        If SRR->( RecLock("SRR", lNovo) )
            //Se for inclusão, grava todos campos da SRR
            //Se for alteração, apenas altera o valor do registro
            If lNovo
                SRR->RR_FILIAL  := cCodFil
                SRR->RR_MAT     := cCodMat
                SRR->RR_PD      := cPD
                SRR->RR_TIPO1   := "V"
                SRR->RR_TIPO2   := "C"
                SRR->RR_DATA    := STOD(cData)
                SRR->RR_TIPO3   := "F"
                SRR->RR_PERIODO := cPer
                SRR->RR_ROTEIR  := "FER"
                SRR->RR_SEMANA  := cSem
                SRR->RR_DATAPAG := STOD(cDtPag)
                SRR->RR_SEQ     := cSeq
                SRR->RR_PROCES  := cProc
                SRR->RR_DTREF   := STOD(cDtRef)
                SRR->RR_CC      := cCenCus
            EndIf

            SRR->RR_VALOR   := nValor

            //Adiciona no log de ocorrências
            //              Filial                         "  -  Matrícula: "                    "  -  Período: "                  "  -  Verba: "              "  -  Valor: R$ "
            aAdd( aLog[1], OemToAnsi( STR0300 ) + cCodFil + OemToAnsi( STR0301 ) + cCodMat + OemToAnsi( STR0302 ) + cPer + OemToAnsi( STR0303 ) + cPD + OemToAnsi( STR0304 ) + Transform( nValor, "@E 99,999,999,999.99" ) + OemToAnsi(STR0310) )

            //Libera o registro da SRR
            SRR->( MsUnlock() )
        EndIf
    EndIf

    RestArea(aAreaSRR)
    RestArea(aArea)

Return
