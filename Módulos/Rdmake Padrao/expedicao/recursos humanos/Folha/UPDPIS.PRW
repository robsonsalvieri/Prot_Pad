#INCLUDE "PROTHEUS.CH"

User Function UPDPIS()

Local aButtons  := {}
Local aSays     := {}
Local nOpcA     := 0

Private aLog        := {}
Private aTitle      := {}
Private cProcesso   := "     "
Private cFiltFil    := cFilAnt

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo ajustar as verbas de base e recolhimento " ))
aAdd(aSays,OemToAnsi( "do PIS EMPRESA na folha de pagamento de dezembro de 2024." ))
aAdd(aSays,OemToAnsi( "O sistema irá excluir ambas as verbas da SRD e recalcula-las de acordo com as" ))
aAdd(aSays,OemToAnsi( "incidências de verbas existentes na folha." ))
aAdd(aSays,OemToAnsi( "Caso a folha ainda esteja aberta ou as verbas não existam na folha do funcionário, " ))
aAdd(aSays,OemToAnsi( "nenhum tratamento será efetuado." ))
aAdd(aSays,OemToAnsi( "Antes de prosseguir certifique-se de ter executado BACKUP da base de dados. " ))

aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(fLoadParams() .and. gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Ajuste do PIS Empresa da folha do período 202412", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários com recolhimento de PIS recalculado" ) )
    Aadd( aLog, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    If Empty(aLog[1])
        MsgInfo("Nenhum registro processado")
    EndIf
    fMakeLog(aLog,aTitle,,,"UPDPIS",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
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
oSize:AddObject( "CABECALHO",  160, 50, .F., .F. ) // Não dimensionavel

oSize:lProp 	:= .F. // Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
oSize:Process() 	   // Dispara os calculos

Define MSDialog oDlg Title OemToAnsi("Parâmetros para recálculo") FROM 0,0 TO 200,380 OF oMainWnd PIXEL

	@ oSize:GetDimension("CABECALHO","LININI") +5 , oSize:GetDimension("CABECALHO","COLINI")+10;
		TO oSize:GetDimension("CABECALHO","LINEND") +10,oSize:GetDimension("CABECALHO","COLEND")+10 LABEL OemToAnsi("Filtro") OF oDlg PIXEL

    @ oSize:GetDimension("CABECALHO","LININI") +18, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Filial: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
    @ oSize:GetDimension("CABECALHO","LININI") +17, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oFilial VAR cFiltFil SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'SM0' VALID Vazio() .Or. ExistCpo("SM0",cEmpAnt + cFiltFil)

    @ oSize:GetDimension("CABECALHO","LININI") +33, oSize:GetDimension("CABECALHO","COLINI")+20 SAY OemToAnsi("Processo: ")	SIZE 146,10 OF oDlg PIXEL FONT oFont
    @ oSize:GetDimension("CABECALHO","LININI") +32, oSize:GetDimension("CABECALHO","COLINI")+50 MSGET oProcesso VAR cProcesso SIZE 050,10 OF oDlg PIXEL PICTURE "@!" F3 'RCJ' VALID Vazio() .Or. ExistCpo("RCJ")


	bSet15 := {|| lRet := .T., oDlg:End() }
	bSet24 := {|| lRet := .F., oDlg:End() }


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

If lRet
    If Empty(cFiltFil)
        lRet := MsgYesNo( "Filial não foi preenchida. Confirma o recalculo para todas as Filiais? " )
    EndIf 
    If lRet .and. Empty(cProcesso)
        lRet := MsgYesNo( "Processo não foi preenchido. Confirma o recalculo para todos os processos? " )
    EndIf           
EndIf

Return lRet

/*/{Protheus.doc} fProcessa
Função que efetua os ajustes na base
/*/
Static Function fProcessa()
Local aArea     := GetArea()
Local aRecPis   := {}
Local cAliasQry := GetNextAlias()
Local cPeriodo  := "202412"
Local cRoteiro  := fGetRotOrdinar()
Local cBasPIS   := ""
Local cRecPIS   := ""
Local cFilAux   := ""
Local cFilMat   := ""
Local cWhere	:= "%"
Local cJoinSRV	:= "%" + FWJoinFilial( "SRD", "SRV" ) + "%"
Local nBasPis   := 0
Local nPercPis  := 0
local nX        := 0
Local nQtd      := 0
Local nBasAnt   := 0
Local lTemRateio:= .F.
Local lRatPIS   := .F.
Local lRatOut   := .F.

If !Empty(cFiltFil)
	cWhere += " SRA.RA_FILIAL = '" + cFiltFil + "' AND "
EndIf
If !Empty(cProcesso)
	cWhere += " SRA.RA_PROCES = '" + cProcesso + "' AND "
EndIf

cWhere += "%"

BeginSql alias cAliasQry
    SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_PROCES, SRA.RA_NOME
    FROM %table:SRA% SRA
    INNER JOIN %Table:SRD% SRD ON SRD.RD_FILIAL = SRA.RA_FILIAL
        AND SRD.RD_MAT = SRA.RA_MAT
        AND SRD.RD_PERIODO = %Exp:cPeriodo%
        AND SRD.%NotDel%
    INNER JOIN %table:SRV% SRV ON %exp: cJoinSRV%
        AND SRV.RV_COD = SRD.RD_PD
        AND SRV.%NotDel%
    WHERE %Exp:cWhere%
    SRV.RV_CODFOL = %exp:"0229"% AND
	SRA.%NotDel%
    GROUP BY SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_PROCES, SRA.RA_NOME
    ORDER BY SRA.RA_FILIAL, SRA.RA_PROCES, SRA.RA_MAT
EndSql

count to nQtd

DbGoTop()

GpProcRegua(nQtd)

DbSelectArea("SRD")
DbSetOrder(5) //RD_FILIAL, RD_MAT, RD_PROCES, RD_ROTEIR, RD_PERIODO, RD_SEMANA, RD_PD

While (cAliasQry)->( !EoF() )
    cChave := (cAliasQry)->(RA_FILIAL + RA_MAT + RA_PROCES) + cRoteiro + cPeriodo 

    GpIncProc()

    If cFilAux <> SRD->RD_FILIAL .or. Empty(cBasPIS) .or. Empty(cRecPIS)
        cBasPIS := fGetCodFol("0223")
        cRecPIS := fGetCodFol("0229")
        nPercPis:= RetValSrv( cRecPIS,SRD->RD_FILIAL,"RV_PERC") / 100        
        cFilAux := SRD->RD_FILIAL
        lTemRateio := RetValSrv(cBasPIS, cFilAux, "RV_ENCARCC") == "S" .or. RetValSrv(cRecPIS, cFilAux, "RV_ENCARCC") == "S"
    EndIf

    If lTemRateio .and. cFilMat <> (cAliasQry)->(RA_FILIAL + RA_MAT)
        aRateio := {}
        cFilMat := (cAliasQry)->(RA_FILIAL + RA_MAT)   
        SRA->(DbSeek(cFilMat))
        fRateio( {} , 2, "202412" ) //Carrega a programação de Rateio
        lRatPIS := Len(aRateio) > 0
    Else 
        lRatPIS := .F.
    EndIf

    If SRD->(Dbseek(cChave)) .and. !Empty(cBasPIS) .and. !Empty(cRecPIS) .and. nPercPis > 0
        nBasPis   := 0
        nBasAnt   := 0
        aRecPis   := {}
        lRatOut   := .F.
        While SRD->(!Eof() .and. RD_FILIAL + RD_MAT + RD_PROCES + RD_ROTEIR + RD_PERIODO == cChave)
            If SRD->RD_PD $ cBasPis + "/" + cRecPis
                aAdd(aRecPis, SRD->(Recno()))
                If SRD->RD_PD == cBasPis .and. lTemRateio
                    nBasAnt += SRD->RD_VALOR
                EndIf
            ElseIf RetValSRV(SRD->RD_PD, SRD->RD_FILIAL, "RV_PIS") == "S"
                If( RetValSrv(SRD->RD_PD,SRD->RD_FILIAL,"RV_TIPOCOD") $ "1*3", nBasPis += SRD->RD_VALOR, nBasPis -= SRD->RD_VALOR)
            EndIf
            SRD->(DbSkip())
        EndDo
        If nBasPis > 0
            aAdd( aLog[1] , "Funcionário: " + (cAliasQry)->RA_FILIAL + " - " + (cAliasQry)->RA_MAT +  " - " + AllTrim((cAliasQry)->RA_NOME) )
            If lTemRateio .and. !lRatPIS .and. Len(aRecPis) > 2 //Se não tem programação de rateio mas o PIS foi rateado
                lRatOut := .T.
            EndIf

            For nX := 1 to Len(aRecPis)
                SRD->(DbGoTo(aRecPis[nX]))
                RecLock("SRD",.F.)
                If SRD->RD_PD == cBasPis
                    If RetValSrv(cBasPIS, cFilAux, "RV_ENCARCC") == "S" .and. ( lRatPIS .or. lRatOut )
                        If lRatPIS
                            If ( nPos := aScan(aRateio, {|x| x[1]+x[2]+x[3] == SRD->(RD_CC+RD_ITEM+RD_CLVL)}) ) > 0
                                SRD->RD_VALOR := nBasPis * aRateio[nPos][4]
                            EndIf
                        Else
                            SRD->RD_VALOR := ( SRD->RD_VALOR / nBasAnt ) * nBasPis
                        EndIf
                    Else 
                        SRD->RD_VALOR := nBasPis
                    EndIf
                Else
                    If RetValSrv(cRecPIS, cFilAux, "RV_ENCARCC") == "S" .and. ( lRatPIS .or. lRatOut )
                        If lRatPIS
                            If ( nPos := aScan(aRateio, {|x| x[1]+x[2]+x[3] == SRD->(RD_CC+RD_ITEM+RD_CLVL)}) ) > 0
                                SRD->RD_VALOR := Round(nBasPis * nPercPis,2) * aRateio[nPos][4]
                            EndIf
                        Else 
                            nPercAux := SRD->RD_VALOR / Round(nBasAnt * nPercPis,2)
                            SRD->RD_VALOR := Round( Round(nBasPis * nPercPis,2) * nPercAux, 2)
                        EndIf
                    Else 
                        SRD->RD_VALOR := Round(nBasPis * nPercPis,2)
                    EndIf
                EndIf
                SRD->(MsUnLock())
            Next nX 
        EndIf
    EndIf
    (cAliasQry)->( dbSkip() )
Enddo   
        
(cAliasQry)->( dbCloseArea() )

RestArea( aArea)

Return
