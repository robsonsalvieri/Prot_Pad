#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'GPEM941.CH'

/*/{Protheus.doc} GPEM941
Réplica do Cadastro de processos e Tipo de ausências
@type  Function
@author Bruno Costa
@since 17/06/2024
@version 12
/*/
Function GPEM941()

Local aFilAux   := {}
Local aRecProc  := {}

Private lGpea420 := FunName() == "GPEA420"

If GP941Comp()
    aFilAux := LoadProcFil(@aRecProc)

    If Len(aFilAux) > 0
        If lGpea420
            ProcGpe({|lEnd| GP941Proc(aFilAux, aRecProc) },,, .T.)
        Else  
            ProcGpe({|lEnd| GP941TpAus(aFilAux, aRecProc) },,, .T.)
        EndIf      
    EndIf
EndIf

Return Nil

/*/{Protheus.doc} LoadProcFil
Carrega Filiais
@type  Function
@author Bruno Costa
@since 17/06/2024
@version 12
/*/
Static Function LoadProcFil(aRecProc)

Local aArea			:= GetArea()
Local aColumns		:= {}
Local aSM0     		:= {}
Local aStru			:= {}
Local aLstIndices	:= {}
Local aRet          := {}
Local aFilAux       := {}
Local cFilRep       := ""
Local cFilSM0       := If(lGpea420, "RCJ", "RCM")
Local cAliasTab     := GetNextAlias()
Local lMarcar 		:= .T.
Local lProcSist     := .F.
Local lProcUser     := .F.
Local lTpAuse       := .F.
Local nOpcX 		:= 0
Local nProces       := 0
Local nCont
Local oSize 
Local oDlgGrid 
Local oTela
Local oPanel
Local oMark
Local oFont         := TFont():New('Courier new',,-16,,.T.)

Private cAliasTRB
Private cAliasProc

Static cAliasTmp
Static oArqTmp

If oArqTmp == Nil //Monta temporária com filiais disponíveis
	Aadd(aStru, {"OK"		, "C", 2			  , 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial , 0})
	Aadd(aStru, {"NOME"  	, "C", 100			  , 0})
    Aadd(aStru, {"FILCOMP" 	, "C", FwGetTamFilial , 0})
	AAdd(aLstIndices, {"FILIAL"})

	cAliasTmp := cAliasTRB := GetNextAlias()

	oArqTmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)
	aSM0    := FWLoadSM0(.T.,, .T.)

	For nCont := 1 To Len(aSM0)
		If aSM0[nCont, 1] == cEmpAnt
            cFilRep := xFilial(cFilSM0, aSM0[nCont, 2])
            If ( aScan(aFilAux, { |x| x == cFilRep } ) ) == 0
                RecLock(cAliasTRB, .T.)
                    (cAliasTRB)->FILIAL	 := cFilRep
                    (cAliasTRB)->NOME  	 := aSM0[nCont, 7]
                    (cAliasTRB)->FILCOMP := aSM0[nCont, 2]
                (cAliasTRB)->(MsUnlock())
                aAdd(aFilAux, cFilRep)
            EndIf
		EndIf
	Next nCont
Else 
	cAliasTRB := cAliasTmp
EndIf

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO", (oSize:aWindSize[3]*1.1), (oSize:aWindSize[3]*0.4) , .F., .F. ) // Não dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 	// Espaço ao lado dos objetos 0, entre eles 3
oSize:lProp 	:= .F. 				// Proporcional
oSize:Process() 	   				// Dispara os calculos

Begin Sequence
    
    If lGpea420
        nProces   := fProcSist(@aRecProc) //Processos de sistema
        lProcUser := fProcUser(@cAliasTab) //Processos de usuário
    Else     
        lTpAuse := fTpAusUser(@cAliasTab) //Tipo de ausências de usuário
    EndIf
    
    If lProcUser .Or. lTpAuse
    
        aStru       := {}
        aLstIndices := {}
        Aadd(aStru, {"OK"		, "C", 2			  , 0})
        Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial , 0})
        Aadd(aStru, {"COD"  	, "C", 5			  , 0})
        Aadd(aStru, {"DESCRI"  	, "C", 50			  , 0})
        Aadd(aStru, {"RECNO"  	, "N", 10			  , 0})
        AAdd(aLstIndices, {"FILIAL", "COD"})
        AAdd(aLstIndices, {"DESCRI"})

        cAliasProc := GetNextAlias()

        oArqForm := RhCriaTrab(cAliasProc, aStru, aLstIndices)

        While !(cAliasTab)->(Eof())
            RecLock(cAliasProc, .T.)
            (cAliasProc)->FILIAL := If(lGpea420, (cAliasTab)->RCJ_FILIAL, (cAliasTab)->RCM_FILIAL)
            (cAliasProc)->COD    := If(lGpea420, (cAliasTab)->RCJ_CODIGO, (cAliasTab)->RCM_TIPO)
            (cAliasProc)->DESCRI := If(lGpea420, (cAliasTab)->RCJ_DESCRI, (cAliasTab)->RCM_DESCRI)
            (cAliasProc)->RECNO  := (cAliasTab)->R_E_C_N_O_
            (cAliasProc)->(MsUnlock())
            (cAliasTab)->(DbSkip())
        EndDo

        cCod   := If(lGpea420, STR0002, STR0022) //"Processo" ### "Tipo"
        cTitle := If(lGpea420, STR0004, STR0023) //"Réplica de Processos" ### //"Réplica de Tipos de Ausências"
        cCabec := If(lGpea420, STR0005, STR0024) //"Selecione os Processos/Tipo de Ausências para replicar"
        
        AAdd(aColumns, FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||(cAliasProc)->FILIAL}") )
        aColumns[Len(aColumns)]:SetTitle(STR0001) //"Filial"
        aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
        aColumns[Len(aColumns)]:SetDecimal(0)
        aColumns[Len(aColumns)]:SetPicture("@!")

        AAdd(aColumns, FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||(cAliasProc)->COD}") )
        aColumns[Len(aColumns)]:SetTitle(cCod) //"Processo" ### "Tipo"
        aColumns[Len(aColumns)]:SetSize(5)
        aColumns[Len(aColumns)]:SetDecimal(0)
        aColumns[Len(aColumns)]:SetPicture("@!")

        AAdd(aColumns, FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||(cAliasProc)->DESCRI}") )
        aColumns[Len(aColumns)]:SetTitle(STR0003) //"Descrição"
        aColumns[Len(aColumns)]:SetSize(50)
        aColumns[Len(aColumns)]:SetDecimal(0)
        aColumns[Len(aColumns)]:SetPicture("@!")

        DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi(cTitle) From 0,0 TO 380,930 OF oMainWnd PIXEL 

        // Cria o conteiner onde serão colocados os paineis
        oTela	:= FWFormContainer():New( oDlgGrid )
        cIdGrid := oTela:CreateHorizontalBox( 80 )

        oTela:Activate( oDlgGrid, .F. )

        //Cria os paineis onde serao colocados os browses
        oPanel := oTela:GeTPanel( cIdGrid )

        @ oSize:GetDimension("CABECALHO", "LININI")+08, oSize:GetDimension("CABECALHO", "COLINI")+6 SAY OemToAnsi(cCabec) Of oDlgGrid Pixel FONT oFont 

        oMark := FWMarkBrowse():New()

        oMark:SetOwner(oPanel)
        oMark:SetAlias(cAliasProc)
        oMark:SetTemporary(.T.)
        oMark:SetColumns(aColumns)
        oMark:SetFieldMark('OK')
        oMark:SetIgnoreARotina(.T.)
        oMark:SetMenuDef('')

        oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasProc ), oMark:Refresh(.T.)  }

        oMark:Activate()

        SetMarkAll(oMark:Mark(), .T., cAliasProc) //Marca todos os registros

        oMark:Refresh(.T.)

        //Botoes
        oBtn1:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+320, OemToAnsi(STR0006),oDlgGrid, {||nOpcX := 1, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Confirmar"			         
        oBtn2:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+370, OemToAnsi(STR0007),oDlgGrid, {||nOpcX := 0, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Cancelar"

        ACTIVATE MSDIALOG oDlgGrid CENTERED

        If nOpcX == 1

            //Adiciona filiais selecionadas
            (cAliasProc)->(dbGoTop())

            While (cAliasProc)->(!EOF())
                If !Empty((cAliasProc)->OK)
                    aAdd(aRecProc, (cAliasProc)->RECNO)
                EndIf
                (cAliasProc)->(dbSkip())
            EndDo
        Else 
            Break
        EndIf

        If lGpea420 .And. Len(aRecProc) == nProces .And. !MsgYesNo(OemToAnsi(STR0008), OemToAnsi(STR0009)) //"Nenhum processo de usuário foi selecionado, deseja seguir com a réplica para os processos padrões do sistema? ## "Atenção"
            Break 
        EndIf

        If !lGpea420 .And. Len(aRecProc) == 0  
            MsgInfo(OemToAnsi(STR0025)) //"Nenhum Tipo de Ausência foi selecionado" 
            Break 
        EndIf

        lProcSist := .T.

    EndIf

    If !lGpea420 .And. !lTpAuse
        MsgInfo(OemToAnsi(STR0031)) //"Não existem Tipos de Ausências de usuário para replicar"
        Break
    EndIF    

    If lGpea420 .And. Len(aRecProc) == nProces .And. !lProcSist .And. !MsgYesNo(OemToAnsi(STR0010), OemToAnsi(STR0009)) //"Não existem processos de usuário, deseja seguir com a réplica para os processos padrões do sistema?" ## "Atenção"
        Break 
    EndIf
    
    nOpcX    := 0
    aColumns := {}
    cTitle   := If(lGpea420, STR0004, STR0023) //"Réplica de Processos" ### //"Réplica de Tipo de Ausências"
    cCabec   := If(lGpea420, STR0012, STR0026) //"Selecione as filiais para replicar os Processos" ### "Selecione as filiais para replicar os Tipos de Ausências"
   
    AAdd(aColumns, FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
    aColumns[Len(aColumns)]:SetTitle(STR0001) //"Filial"
    aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
    aColumns[Len(aColumns)]:SetDecimal(0)
    aColumns[Len(aColumns)]:SetPicture("@!")

    AAdd(aColumns, FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
    aColumns[Len(aColumns)]:SetTitle(STR0011) //"Nome"
    aColumns[Len(aColumns)]:SetSize(Len(SM0->M0_NOME))
    aColumns[Len(aColumns)]:SetDecimal(0)
    aColumns[Len(aColumns)]:SetPicture("@!")

    DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi(cTitle) From 0,0 TO 380,930 OF oMainWnd PIXEL //"Réplica de Processos" ### //"Réplica de Tipo de Ausências"

    // Cria o conteiner onde serão colocados os paineis
    oTela	:= FWFormContainer():New( oDlgGrid )
    cIdGrid := oTela:CreateHorizontalBox( 80 )

    oTela:Activate( oDlgGrid, .F. )

    //Cria os paineis onde serao colocados os browses
    oPanel	:= oTela:GeTPanel( cIdGrid )

    @ oSize:GetDimension("CABECALHO", "LININI")+08 , oSize:GetDimension("CABECALHO", "COLINI")+6 SAY OemToAnsi(cCabec) Of oDlgGrid Pixel FONT oFont //"Selecione as filiais onde os Processos serão replicados" ### "Selecione as filiais onde os Tipos de Ausências serão replicados"

    oMark := FWMarkBrowse():New()

    oMark:SetOwner(oPanel)
    oMark:SetAlias(cAliasTRB)
    oMark:SetTemporary(.T.)
    oMark:SetColumns(aColumns)
    oMark:SetFieldMark('OK')
    oMark:SetFilterDefault( " (cAliasTRB)->FILCOMP <> cFilAnt " )
    oMark:SetIgnoreARotina(.T.)
    oMark:SetMenuDef('')

    oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

    oMark:Activate()

    SetMarkAll(oMark:Mark(), .T., cAliasTRB) //Marca todos os registros

    oMark:Refresh(.T.)

    //Botoes
    oBtn1:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+320, OemToAnsi(STR0006),oDlgGrid, {||nOpcX := 1, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Confirmar"			         
    oBtn2:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+370, OemToAnsi(STR0007),oDlgGrid, {||nOpcX := 0, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Cancelar"

    ACTIVATE MSDIALOG oDlgGrid CENTERED

    If nOpcX == 1

        //Adiciona filiais selecionadas
        (cAliasTRB)->(dbGoTop())

        While (cAliasTRB)->(!EOF())
            If !Empty((cAliasTRB)->OK) .And. (cAliasTRB)->FILCOMP <> cFilAnt
                aAdd(aRet, (cAliasTRB)->FILCOMP)
            EndIf
            (cAliasTRB)->(dbSkip())
        EndDo

        If Empty(aRet)
            MsgInfo(OemToAnsi(STR0013)) //"Nenhuma filial selecionada"
            Break 
        EndIf

    EndIf

End Sequence

RestArea(aArea)

Return aRet

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca todas as filiais
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function SetMarkAll(cMarca, lMarcar, cAliasTRB)

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

/*/{Protheus.doc} fProcUser
Busca os processos de usuário
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function fProcUser(cAlias)

Local cWhere := "%RCJ.RCJ_FILIAL = '" + xFilial("RCJ") + "' AND RCJ.RCJ_ORIGEM = 2%" 
Local lRet   := .F.

BeginSql alias cAlias
	SELECT * FROM %table:RCJ% RCJ 
	WHERE %exp:cWhere%
    AND RCJ.%NotDel% 
    ORDER BY RCJ.RCJ_CODIGO
EndSql

If ( cAlias )->( !Eof() )
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} fProcSist
Busca os processos padrões de sistema
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function fProcSist(aRecProc)

Local cWhere := "%RCJ.RCJ_FILIAL = '" + xFilial("RCJ") + "' AND RCJ.RCJ_ORIGEM = '1'%" 
Local cAlias := GetNextAlias()

BeginSql alias cAlias
	SELECT * FROM %table:RCJ% RCJ 
	WHERE %exp:cWhere%
    AND RCJ.%NotDel% 
    ORDER BY RCJ.RCJ_CODIGO
EndSql

While ( cAlias )->( !Eof() )
    aAdd(aRecProc, (cAlias)->R_E_C_N_O_)
    (cAlias)->(dbSkip())
EndDo

(cAlias)->(DbCloseArea())

Return Len(aRecProc)

/*/{Protheus.doc} fTpAusUser
Busca os tipos de ausências de usuário
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function fTpAusUser(cAlias)

Local cWhere := "%RCM.RCM_FILIAL = '" + xFilial("RCM") + "' AND RCM.RCM_TIPO > 018%" 
Local lRet   := .F.

BeginSql alias cAlias
	SELECT * FROM %table:RCM% RCM
	WHERE %exp:cWhere%
    AND RCM.%NotDel% 
    ORDER BY RCM.RCM_TIPO
EndSql

If ( cAlias )->( !Eof() )
	lRet := .T.
EndIf

Return lRet

/*/{Protheus.doc} GP941Proc
Processa as filiais selecionadas para os processos selecionados
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function GP941Proc(aFilAux, aRecProc)

Local aRCJEnchoice := {}
Local aRCJCols     := {}
Local aLogTitle    := {}
Local aLogItens    := {}
Local aLogAux      := {}   
Local aLogTime     := {} 
Local cFilAux      := cFilAnt
Local cFormName    := ""
Local nY           := 0
Local nX           := 0

GPProcRegua(Len(aRecProc))

For nY := 1 To Len(aRecProc)

    RCJ->(DbGoTo(aRecProc[nY]))

    cFormName := RCJ->(RCJ_CODIGO + " - " + RCJ_DESCRI)

    If Empty(aLogTitle)
        aAdd(aLogTitle, OemToAnsi(STR0014))          //"Tempo de processamento"
        aAdd(aLogTime, OemToAnsi(STR0015) + Time())  //"Início do Processamento: "
        aAdd(aLogTitle, OemToAnsi(STR0016))          //"Os seguintes registros foram processados:"
    EndIf 

    aAdd(aLogAux, cFormName)

    aRCJEnchoice := {}
    aRCJCols     := {}

    aRCJCols     := RCJ->( GdBuildCols( @aRCJEnchoice, NIL, NIL, NIL, "RCJ", { "RCJ_FILIAL" }, NIL, "RCJ" ) )

	For nX := 1 To Len( aRCJEnchoice )
		SetMemVar( aRCJEnchoice[nX, 02], aRCJCols[1, nX], .T., .T. )
	Next nX
 
    GPIncProc( OemToAnsi(STR0017) + aRCJCols[1, 2], 50, .T. ) //"Replicando Processo: "
    GrvProces(aRCJEnchoice, aRCJCols, aFilAux)

Next nY

cFilAnt := cFilAux

If Len(aLogTitle) > 0
    aAdd(aLogTime, OemToAnsi(STR0018) + Time()) //"Fim do Processamento: "
    aAdd(aLogItens, aClone(aLogTime))
    aAdd(aLogItens, aClone(aLogAux))
    aAdd(aLogTitle, OemToAnsi(STR0019)) //"Filiais processadas"
    aAdd(aLogItens, aFilAux)
    MsAguarde( { || fMakeLog( aLogItens, aLogTitle, "GPEM941", NIL, FunName(), OemToAnsi(STR0020) ) },  OemToAnsi(STR0020)) //"Log de réplica de Processos"
EndIf

Return Nil

/*/{Protheus.doc} GP941TpAus
Processa as filiais selecionadas para os tipos de ausência
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function GP941TpAus(aFilAux, aRecProc)

Local aRCMEnchoice := {}
Local aRCMCols     := {}
Local aLogTitle    := {}
Local aLogItens    := {}
Local aLogAux      := {}   
Local aLogTime     := {} 
Local cFilAux      := cFilAnt
Local cFormName    := ""
Local nY           := 0
Local nX           := 0
Local lRet         := .T.

GPProcRegua(Len(aRecProc))

For nY := 1 To Len(aRecProc)

    RCM->(DbGoTo(aRecProc[nY]))

    cFormName := RCM->(RCM_TIPO + " - " + RCM_DESCRI)

    If Empty(aLogTitle)
        aAdd(aLogTitle, OemToAnsi(STR0014))         //"Tempo de processamento"
        aAdd(aLogTime, OemToAnsi(STR0015) + Time()) //"Início do Processamento: "
        aAdd(aLogTitle, OemToAnsi(STR0016))         //"Os seguintes registros foram processados:"
    EndIf 

    aAdd(aLogAux, cFormName)

    aRCMEnchoice := {}
    aRCMCols     := {}

    aRCMCols     := RCM->( GdBuildCols( @aRCMEnchoice, NIL, NIL, NIL, "RCM", { "RCM_FILIAL", "RCM_TIPO" }, NIL, "RCM" ) )

	For nX := 1 To Len( aRCMEnchoice )
		SetMemVar( aRCMEnchoice[nX, 02], aRCMCols[1, nX], .T., .T. )
	Next nX
 
    GPIncProc( OemToAnsi(STR0028) + RCM->RCM_TIPO, 50 ) //"Replicando Tipo de Ausência: "
    lRet := GrvTpAuse(aRCMEnchoice, aRCMCols, aFilAux)
    
    If !lRet 
      Return Nil
    EndIf  
Next nY

cFilAnt := cFilAux

If Len(aLogTitle) > 0
    aAdd(aLogTime, OemToAnsi(STR0018) + Time()) //"Fim do Processamento: "
    aAdd(aLogItens, aClone(aLogTime)) 
    aAdd(aLogItens, aClone(aLogAux))
    aAdd(aLogTitle, OemToAnsi(STR0019)) //"Filiais processadas"
    aAdd(aLogItens, aFilAux)
    MsAguarde( { || fMakeLog( aLogItens, aLogTitle, "GPEM941", NIL, FunName(), OemToAnsi(STR0027) ) },  OemToAnsi(STR0027)) //Log de réplica dos Tipos de Ausências"
EndIf

DbSetOrder(1)

Return lRet

/*/{Protheus.doc} GrvProces
Gravação dos processos na RCJ 
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function GrvProces(aRCJEnchoice, aRCJCols, aFilAux)

Local nX        := 0
Local nFil      := 0
Local cFilAux   := "" 

For nFil := 1 To Len(aFilAux)
    cFilAux := xFilial("RCJ", aFilAux[nFil])

    If (RCJ->(DbSeek(cFilAux + aRCJCols[1, 2])))
        RecLock("RCJ", .F.)
        DbDelete()
        MsUnLock()
    EndIf

    RecLock("RCJ", .T.)

    RCJ->RCJ_FILIAL := cFilAux

    For nX := 1 To Len(aRCJEnchoice)
        If aRCJEnchoice[nX, 2] $ "RCJ_ALI_WT*RCJ_REC_WT" 
            Loop
        EndIf
        &("RCJ->"+aRCJEnchoice[nX, 2]) := aRCJCols[1, nX]
    Next nX

    RCJ->(MsUnLock())

Next nFil

Return Nil

/*/{Protheus.doc} GrvTpAuse
Gravação dos tipos de ausências na RCM
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function GrvTpAuse(aRCMEnchoice, aRCMCols, aFilAux)

Local nX        := 0
Local nFil      := 0
Local cFilAux   := ""
Local cFil      := cFilAnt
Local lRet      := .T.

For nFil := 1 To Len(aFilAux)
    
    cFilAnt := cFilAux := xFilial("RCM", aFilAux[nFil])

    If !ChkRCM()
        cFilAnt := xFilial("SRV", aFilAux[nFil])
        fCargaRCM(.F.)
        cFilAnt := cFilAux
    EndIf

    If !ChkRCM()
        MsgInfo(OemToAnsi(STR0030)) //"Não será possível replicar Tipos de Ausências de usuário sem que exista os Tipos de Ausências padrões de sistema. Verifique o cadastro de Verbas!"
        lRet := .F.
        Return lRet 
    EndIf

    DbSetOrder(2)
    If (RCM->(DbSeek(cFilAux + aRCMCols[1, 1])))
        RecLock("RCM", .F.)
        DbDelete()
        MsUnLock()
    EndIf

    RecLock("RCM", .T.)

    RCM->RCM_FILIAL := cFilAux
    RCM->RCM_TIPO   := GETSX8NUM("RCM", "RCM_TIPO")

    For nX := 1 To Len(aRCMEnchoice)
        If aRCMEnchoice[nX, 2] $ "RCM_ALI_WT*RCM_REC_WT" 
            Loop
        EndIf
        &("RCM->"+aRCMEnchoice[nX, 2]) := aRCMCols[1, nX]
    Next nX

    RCM->(MsUnLock())
    ConfirmSx8()

Next nFil

cFilAnt := cFil

Return lRet

/*/{Protheus.doc} ChkRCM
Verifica se existe o tipo de ausência padrão
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static Function ChkRCM()

Local aArea := GetArea()
Local lRet 	:= .F.

DbSelectArea("RCM")
DbSetOrder(1)
If DbSeek(xFilial("RCM") + "001")
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} GP941Comp
Verifica compartilhamento da RCJ/RCM
@author Bruno Costa
@since 18/06/2024
@version 12
@Type Function
/*/
Static function GP941Comp()

Local cTab     := If(lGpea420, "RCJ", "RCM")
Local cMsnTab  := If(lGpea420, STR0021, STR0029)
Local cTabComp := FWModeAccess(cTab, 3) + FWModeAccess(cTab, 2) + FWModeAccess(cTab, 1)
Local nLayEmp  := Len(FWSM0Layout(cEmpAnt, 1))
Local nLayUni  := Len(FWSM0Layout(cEmpAnt, 2))
Local lRet     := .T.

If cTabComp == "CCC" .Or. (cTabComp == "CCE" .And. nLayEmp == 0) .OR. (cTabComp == "CEE" .And. nLayEmp == 0 .And. nLayUni == 0)
    MsgInfo(OemToAnsi(cMsnTab)) //"A tabela RCJ/RCM é compartilhada, sendo assim, não será possível replicar, pois os registros são únicos em todas as demais filiais"
    lRet := .F.  
EndIf

Return lRet
