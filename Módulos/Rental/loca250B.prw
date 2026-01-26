#INCLUDE "LOCA250B.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"                                                                                                              

/*/{PROTHEUS.DOC} LOCA250A.PRW
ITUP BUSINESS - TOTVS RENTAL
ESTORNO DE EQUIPAMENTOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 21/06/2024
/*/

FUNCTION LOCA250B(a,b,c,d,lAuto) 
Local aArea	   	:= GETAREA() 
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cRet70    := ""
Local lRet      := .T.
Local nReg      
Local aSeq 
Local cBem
Local cSeq
Local lLib  
Local cNewSeq
Local nX
Local lProc 
Local cObra
Local cAS
Local cCodCli
Local cNomCli
Local cCodMun
Local cMunic
Local cEst
Local dDtIni
Local dDtFim
Local dPreDes
Local cLojCli
Local cProjet
Local cStatAtu
Local cStatNew
Local cQryLeg

Default lAuto   := .F.

    If !lMvLocBac
        Return .F.
    EndIf
    
    If SELECT("TMPLEG") > 0
        TMPLEG->( DBCLOSEAREA() )
    EndIf   

	// Ver o status correspondente ao 70 - em manutenção
	cQryLeg := "SELECT FQD_STATQY , FQD_STAREN FROM "+ RETSQLNAME("FQD") +" WHERE FQD_STAREN = '70' AND D_E_L_E_T_ = '' "	
	TCQUERY cQryLeg NEW ALIAS "TMPLEG"
	While TMPLEG->(!EOF())
		cRet70 += TMPLEG->FQD_STATQY + "*" 
        TMPLEG->(DBSKIP()) 
    EndDo
    TMPLEG->( DBCLOSEAREA() )

    If !ST9->T9_STATUS $ cRet70 .AND. ST9->T9_STATUS <> LOCA224K() // disponível
        Help( ,, "LOCA250B",, STR0001, 1, 0,,,,,,{STR0005}) //"O estorno é realizado para status em manutenção, ou disponível."
        RestArea(aArea)
        Return .F.
    EndIf

    // Posicionar no último registro da FQ4 do bem posicionado
    cBem := ST9->T9_CODBEM
    cSeq := ""
    nReg := 0
    FQ4->(dbSeek(xFilial("FQ4")+cBem))
    While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4") + cBem
        If FQ4->FQ4_SEQ > cSeq
            nReg := FQ4->(recno())
        EndIF
        FQ4->(dbSkip())
    EndDo
    
    If nReg == 0
        // Criar uma FQ4 com status disponível, atualizar a ST9 e voltar para o menu
        LOCXITU21("", LOCA224K(), "" , "", "")
        FQ4->(RecLock("FQ4",.F.))
        FQ4->FQ4_PROJET := ""
        FQ4->FQ4_OBRA   := ""
        FQ4->FQ4_AS     := ""
        FQ4->FQ4_CODCLI := ""
        FQ4->FQ4_NOMCLI := ""
        FQ4->FQ4_CODMUN := ""
        FQ4->FQ4_MUNIC  := ""
        FQ4->FQ4_EST    := ""
        FQ4->FQ4_DTINI  := ctod("")
        FQ4->FQ4_DTFIM  := ctod("")
        FQ4->FQ4_PREDES := ctod("")
        FQ4->FQ4_LOJCLI := ""
        FQ4->FQ4_AS := ""
        FQ4->(MsUnlock())
        ST9->(RecLock("ST9",.F.))
        ST9->T9_STATUS := LOCA224K()
        ST9->(MsUnlock())
        RestArea(aArea)
        Return .T.
    EndIF

    // Posicionar na FQ4 mais atual do bem
    FQ4->(dbGoto(nReg))
    cSeq := FQ4->FQ4_SEQ
    cStatAtu := FQ4->FQ4_STATUS

    cProjet := FQ4->FQ4_PROJET
    cObra   := FQ4->FQ4_OBRA
    cAS     := FQ4->FQ4_AS
    cCodCli := FQ4->FQ4_CODCLI
    cNomCli := FQ4->FQ4_NOMCLI
    cCodMun := FQ4->FQ4_CODMUN
    cMunic  := FQ4->FQ4_MUNIC
    cEst    := FQ4->FQ4_EST
    dDtIni  := FQ4->FQ4_DTINI
    dDtFim  := FQ4->FQ4_DTFIM
    dPreDes := FQ4->FQ4_PREDES
    cLojCli := FQ4->FQ4_LOJCLI
    cAS     := FQ4->FQ4_AS
   
    lProc := .T.
    If !lAuto
        lProc := .F.
        If MsgYesNo(STR0002,STR0003) //"Confirma o estorno do movimento?"###"Atenção!"
            lProc := .T.
        EndIf
    EndIf

    If lProc
        nReg := FQ4->(Recno())
        aSeq := {}
        cBem := FQ4->FQ4_CODBEM

        FQ4->(dbSeek(xFilial("FQ4")+cBem))
        While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4") + cBem
            aadd(aSeq,FQ4->FQ4_SEQ)
            FQ4->(dbSkip())
        EndDo

        FQ4->(dbGoto(nReg))
    
        aSeq := asort(aSeq,,,{|X,Y| X > Y })
        cNewSeq := ""
        cStatNew := ""
       
        If len(aSeq) == 1
            If FQ4->FQ4_STATUS <> LOCA224K() // disponível
                // Criar uma FQ4 como disponível
                LOCXITU21(cStatAtu, LOCA224K(), "" , "", "")
                FQ4->(RecLock("FQ4",.F.))
                FQ4->FQ4_PROJET := ""
                FQ4->FQ4_OBRA   := ""
                FQ4->FQ4_AS     := ""
                FQ4->FQ4_CODCLI := ""
                FQ4->FQ4_NOMCLI := ""
                FQ4->FQ4_CODMUN := ""
                FQ4->FQ4_MUNIC  := ""
                FQ4->FQ4_EST    := ""
                FQ4->FQ4_DTINI  := ctod("")
                FQ4->FQ4_DTFIM  := ctod("")
                FQ4->FQ4_PREDES := ctod("")
                FQ4->FQ4_LOJCLI := ""
                FQ4->FQ4_AS := ""
                FQ4->(MsUnlock())
                ST9->(RecLock("ST9",.F.))
                ST9->T9_STATUS := LOCA224K()
                ST9->(MsUnlock())
                RestArea(aArea)
                Return .T.
            Else
                // Já é um movimento disponível e não tem eventos anteriores
                Help( ,, "LOCA250B",, STR0001, 1, 0,,,,,,{STR0004}) //"Inconsistência nos dados."###"Não existe movimento anterior para a realização do estorno."
                RestArea(aArea)
                Return .F.
            EndIF
        Else
            lLib := .F.
            For nX := 1 to len(aSeq)
                If lLib
                    cNewSeq := aSeq[nX]
                    Exit
                EndIF
                If aSeq[nX] == cSeq
                    lLib := .T.
                EndIf
            Next

            cStatNew := ""
            FQ4->(dbSeek(xFilial("FQ4")+cBem))
            While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4") + cBem
                If FQ4->FQ4_SEQ == cNewSeq
                    cStatNew := FQ4->FQ4_STATUS 
                    Exit  
                EndIF
                FQ4->(dbSkip())
            EndDo

            // Criar uma FQ4 como disponível
            LOCXITU21(cStatAtu, cStatNew, "" , "", "")
            FQ4->(RecLock("FQ4",.F.))
            FQ4->FQ4_OBRA   := cObra
            FQ4->FQ4_AS     := cAs
            FQ4->FQ4_CODCLI := cCodCli
            FQ4->FQ4_NOMCLI := cNomCli
            FQ4->FQ4_CODMUN := cCodMun
            FQ4->FQ4_MUNIC  := cMunic
            FQ4->FQ4_EST    := cEst
            FQ4->FQ4_DTINI  := dDtIni
            FQ4->FQ4_DTFIM  := dDtFim
            FQ4->FQ4_PREDES := dPreDes
            FQ4->FQ4_LOJCLI := cLojCli
            FQ4->FQ4_AS     := cAS
            FQ4->FQ4_PROJET := cProjet
            FQ4->(MsUnlock())
            ST9->(RecLock("ST9",.F.))
            ST9->T9_STATUS := cStatNew
            ST9->(MsUnlock())
            RestArea(aArea)
            Return .T.
        EndIf
   
    EndIF
    
    RestArea(aArea)
Return lRet

