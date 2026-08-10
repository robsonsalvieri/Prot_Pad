#INCLUDE "locxitu.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'DBTREE.CH'

/*/{PROTHEUS.DOC} LOCXITU.PRW
ITUP BUSINESS - TOTVS RENTAL
Conjunto de fun็๕es para uso geral do m๓dulo Rental
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

// ROTINA PARA VALIDAR O SALDO NO ORวAMENTO.
// FRANK ZWARG FUGA EM 21/09/2020
FUNCTION LOCXITU01()
LOCAL _LRET     := .T. // RETORNO SE O PRODUTO POSSUI SALDO EM ESTOQUE E POSSIBILITA A UTILIZAวรO DELE.
LOCAL _CPRODUTO
LOCAL _NQUANT
LOCAL _AAREA    := GETAREA()
LOCAL _NSALDO   := 0
LOCAL _CLOCAL

    IF ALLTRIM(UPPER(READVAR())) == "M->FPA_PRODUT"
        _CPRODUTO   := M->FPA_PRODUT
        _NQUANT     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})]
        _CLOCAL     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCAL"})]
    ELSEIF ALLTRIM(UPPER(READVAR())) == "M->FPA_QUANT"
        _CPRODUTO   := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]
        _NQUANT     := M->FPA_QUANT
        _CLOCAL     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCAL"})]
    ELSEIF ALLTRIM(UPPER(READVAR())) == "M->FPA_LOCAL"
        _CPRODUTO   := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]
        _NQUANT     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})]
        _CLOCAL     := M->FPA_LOCAL
    ENDIF


    // SE A ROTINA ESTA CONFIGURADA PARA ITENS PAIS E FILHOS E O PRODUTO ษ UMA ESTRUTURA DA SG1 A ROTINA TRATA EM OUTRO PONDO DO SISTEMA
    IF SUPERGETMV("MV_LOCX028",,.F.)
        SG1->(DBSETORDER(1))
        IF SG1->(DBSEEK(XFILIAL("SG1")+ALLTRIM(_CPRODUTO)))
            RETURN .T.
        ENDIF
    ENDIF

    SB1->(DBSETORDER(1))
    IF SB1->(DBSEEK(XFILIAL("SB1")+_CPRODUTO))
        _NSALDO := CALCEST(SB1->B1_COD, _CLOCAL, DDATABASE + 1, SB1->B1_FILIAL)[1]
        IF _NQUANT > _NSALDO
            MSGALERT(STR0001+ALLTRIM(STR(_NSALDO)),STR0002) //"SALDO ATUAL: "###"O SALDO EM ESTOQUE ษ MENOR DO QUE A QUANTIDADE INFORMADA."
            _NMSGX ++
        ENDIF
    ENDIF

    RESTAREA(_AAREA)
RETURN _LRET

// FRANK ZWARG FUGA
// 28/09/2020 - VISรO POR ESTRUTURA DA ZAG
FUNCTION LOCXITU02()
LOCAL _NX, _NY
LOCAL _CPRODUTO
LOCAL _AEST         := {}
LOCAL _CSEQ

LOCAL ODLGX
LOCAL AJANEST 	    := MSADVSIZE()
LOCAL OEMPTREE
LOCAL OFONT1:=TFONT():NEW("ARIAL",9,10,,.T.,,,,.T.,.F.)
LOCAL AOBJECTS := {}
LOCAL _COBRA
LOCAL _NSEQ

PRIVATE COPCAO       := ""

    AADD( AOBJECTS, { 100, 100, .T., .T. } )
    AINFO   := { AJANEST[1] , AJANEST[2] , AJANEST[3] , AJANEST[4] , 3 , 3 }
    APOSOBJ := MSOBJSIZE( AINFO , AOBJECTS , .T. )

    IF SUPERGETMV("MV_LOCX028",,.F.)
        // VERIFICAR SE EXISTE UM ITEM QUE TENHA CONFIGURAวรO COM ESTRUTURA.
        FOR _NX := 1 TO LEN(ODLGPLA:ACOLS)
            IF !ODLGPLA:ACOLS[_NX][LEN(ODLGPLA:AHEADER)+1]
                _CPRODUTO := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]
                _CSEQ     := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})]
                _CQTD     := ALLTRIM(STR(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})]))
                _CQTD     += STR0003+DTOC(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTINI"})]) //" / DT.INI: "
                _CQTD     += STR0004+DTOC(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTENRE"})]) //" / DT.FIM: "
                _CQTD     += STR0005+DTOC(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTFIM"})]) //" / PROX.FAT: "
                _CQTD     += STR0006+ALLTRIM(STR(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})])) //" / DIAS LOC: "

                IF !EMPTY(_CSEQ)
                    AADD(_AEST,{_CPRODUTO,_CSEQ,_NX,_CQTD})
                ENDIF
            ENDIF
        NEXT
        IF LEN(_AEST) > 0
            DEFINE MSDIALOG ODLGX FROM AJANEST[7],0 TO AJANEST[6],AJANEST[5] TITLE STR0007 OF OMAINWND PIXEL  //"VISรO POR ESTRUTURA."
            OEMPTREE  := DBTREE():NEW(APOSOBJ[1][1], APOSOBJ[1][2], APOSOBJ[1][3], APOSOBJ[1][4],ODLGX,,,.T.,,OFONT1)
            OEMPTREE:SETSCROLL(2,.T.)
            OEMPTREE:SETSCROLL(1,.T.)

            PIXELIMAGE1 := "FOLDER5"
            IMAGE2 := "FOLDER6"
            ANODES := {}
            ARESULT := {}

            _COBRA := ""
            _NSEQ  := 1
            FOR _NX := 1 TO LEN(_AEST)
                IF SUBSTR(_AEST[_NX][02],1,3) <> _COBRA .AND. EMPTY(SUBSTR(_AEST[_NX][02],5,1))
                    SB1->(DBSETORDER(1))
                    SB1->(DBSEEK(XFILIAL("SB1")+SUBSTR(_AEST[_NX][01],1,TAMSX3("B1_COD")[1])))
                    AADD(ANODES,{'00',STRZERO(_NSEQ,3,0),"",ALLTRIM(SB1->B1_DESC)+STR0008+_AEST[_NX][4],IMAGE1,IMAGE2})         // RAIZ //" / QTD: "
                    AADD(ARESULT,{_AEST[_NX][03]})
                    _NSEQ ++
                    _COBRA := SUBSTR(_AEST[_NX][02],1,3)
                    FOR _NY := 1 TO LEN(_AEST)
                        IF SUBSTR(_AEST[_NY][02],1,3) == _COBRA .AND. !EMPTY(SUBSTR(_AEST[_NY][02],5,1))
                            SB1->(DBSETORDER(1))
                            SB1->(DBSEEK(XFILIAL("SB1")+SUBSTR(_AEST[_NY][01],1,TAMSX3("B1_COD")[1])))
                            AADD(ANODES,{'01',STRZERO(_NSEQ,3,0),"",ALLTRIM(SB1->B1_DESC)+STR0008+_AEST[_NX][4],IMAGE1,IMAGE2})         // FILHOS //" / QTD: "
                            AADD(ARESULT,{_AEST[_NY][03]})
                            _NSEQ ++
                        ENDIF
                    NEXT



                ENDIF
            NEXT


            OEMPTREE:PTSENDTREE( ANODES )


            ACTIVATE MSDIALOG ODLGX CENTERED ON INIT ENCHOICEBAR(ODLGX , {|| COPCAO:=OEMPTREE:CURRENTNODEID,ODLGX:END() } , {|| COPCAO:="",ODLGX:END()} , , )

        ELSE
            MSGALERT(STR0009,STR0010) //"NENHUM PRODUTO POSSUI ESTRUTURA."###"ATENวรO!"
        ENDIF
    ELSE
        MSGALERT(STR0011,STR0010) //"ROTINA EXCLUSIVA DO RENTAL CONFIGURADO POR VISรO DE ESTRUTURA."###"ATENวรO!"
    ENDIF
RETURN


// VALIDACAO PARA INDICAR NO GATILHO DO CAMPO FPA_SEQSUB SE OS CAMPOS PODEM SER ATUALIZADOS AUTOMATICAMENTE.
// FRANK ZWARG FUGA EM 05/20/2020
// GATILHAR SOMENTE SE O PRODUTO AINDA NรO FOI DIGITADO.
FUNCTION LOCXITU03()
LOCAL _LRET := .T.
    IF !EMPTY(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]) .OR. EMPTY(M->FPA_SEQSUB)
        _LRET := .F.
    ENDIF
RETURN _LRET

// RETORNO DO CONTEฺDO DO GATILHO DO SX7 DO CAMPO FPA_SEQSUB
// FRANK ZWARG FUGA EM 05/10/2020
FUNCTION LOCXITU04(CCAMPO)
LOCAL _XREC
LOCAL _CSEQ     := M->FPA_SEQSUB
LOCAL _CTEMP    := "FPA->"+CCAMPO
LOCAL _NX       := 0
Local nPosSeqG  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})
Local nPosProd  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})
Local nPosDesc  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DESPRO"})
Local nPosQuant := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})
Local nPosPrcU  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})
// SIGALOC94-846 - 19/07/2023 - Jose Eulalio - Campos solicitados por Rafael Charrua
//Local nPosTipo  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TIPOSE"})
Local nPosCodT  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CODTAB"})
Local nPosDesT  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DESTAB"})
Local nPosLoca  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCAL"})
Local nPosCara  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CARAC"})
Local nPosObse  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_OBSSER"})
Local nPosMinD  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_MINDIA"})
Local nPosMinM  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_MINMES"})
Local nPosAcre  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ACRESC"})
//Local nPosVlBr  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLBRUT"})
Local nPosPDes  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PDESC"})
Local nPosVrHo  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRHOR"})
Local nPosTpGu  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TPGUIM"})
Local nPosGuim  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GUIMON"})
Local nPosTpGD  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TPGUID"})
Local nPosGuiD  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GUIDES"})
Local nPosTpIs  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TPISS"})
Local nPosPeri  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PERISS"})
Local nPosVrIs  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRISS"})
Local nPosVrSe  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRSEGU"})
Local nPosHrIn  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_HRINI"})
Local nPosHrFi  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_HRFIM"})
Local nPosDtFi  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTFIM"})
Local nPosDtEn  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTENRE"})
Local nPosLocD  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})
Local nPosDtPr  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTPRRT"})
Local nPosUltF  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ULTFAT"})
Local nPosSaba  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SABADO"})
Local nPosDomi  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DOMING"})
Local nPosConP  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CONPAG"})
Local nPosTipP  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TIPPAG"})
Local nPosObs  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_OBS"})
Local nPosHrFa  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_HRFRAQ"})
Local nPosVlRe  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLHREX"})
Local nPosCus5  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CUSTO"})
Local nPosNatu  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NATURE"})
Local nPosFile  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_FILEMI"})
Local nPosAjus  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AJUSTE"})
Local nPosDAju  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DAJUST"})
Local nPosNive  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NIVER"})
Local nPosTesF  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TESFAT"})
Local nPosTesR  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TESREM"})
Local nPosCliF  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CLIFAT"})
Local nPosLojF  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOJFAT"})
Local nPosNomF  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NOMFAT"})
Local nPosQtdP  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QTDPRC"})
Local nPosTpBa  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TPBASE"})


    IF VALTYPE(&(_CTEMP)) == "C"
        _XREC := ""
    ELSEIF VALTYPE(&(_CTEMP)) == "N"
        _XREC := 0
    ELSEIF VALTYPE(&(_CTEMP)) == "L"
        _XREC := .T.
    ELSEIF VALTYPE(&(_CTEMP)) == "M"
        _XREC := ""
    ENDIF

    FOR _NX := 1 TO LEN(ODLGPLA:ACOLS)
        IF !ODLGPLA:ACOLS[_NX][LEN(ODLGPLA:AHEADER)+1]
            IF ODLGPLA:ACOLS[_NX][nPosSeqG] == _CSEQ // SEQUENCIA DA SUBSTITUICAO
                // SIGALOC94-846 - 14/07/2023 - Jose Eulalio - Solicitado copiar os campos abaixo quando preenchido SeqSub
                // Verificar possibilidade para no futuro fazer via Gatilho
                If CCAMPO == "FPA_VLBRUT"
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosProd]    := ODLGPLA:ACOLS[_NX][nPosProd]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosDesc]    := ODLGPLA:ACOLS[_NX][nPosDesc]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosQuant]   := ODLGPLA:ACOLS[_NX][nPosQuant]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosPrcU]    := ODLGPLA:ACOLS[_NX][nPosPrcU]
                    // SIGALOC94-846 - 19/07/2023 - Jose Eulalio - Campos solicitados por Rafael Charrua
                    //ODLGPLA:ACOLS[ODLGPLA:nAt][nPosTipo]    := ODLGPLA:ACOLS[_NX][nPosTipo]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosCodT]    := ODLGPLA:ACOLS[_NX][nPosCodT]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosDesT]    := ODLGPLA:ACOLS[_NX][nPosDesT]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosLoca]    := ODLGPLA:ACOLS[_NX][nPosLoca]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosCara]    := ODLGPLA:ACOLS[_NX][nPosCara]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosObse]    := ODLGPLA:ACOLS[_NX][nPosObse]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosMinD]    := ODLGPLA:ACOLS[_NX][nPosMinD]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosMinM]    := ODLGPLA:ACOLS[_NX][nPosMinM]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosAcre]    := ODLGPLA:ACOLS[_NX][nPosAcre]

                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosPDes]    := ODLGPLA:ACOLS[_NX][nPosPDes]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosVrHo]    := ODLGPLA:ACOLS[_NX][nPosVrHo]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosTpGu]    := ODLGPLA:ACOLS[_NX][nPosTpGu]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosGuim]    := ODLGPLA:ACOLS[_NX][nPosGuim]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosTpGD]    := ODLGPLA:ACOLS[_NX][nPosTpGD]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosGuiD]    := ODLGPLA:ACOLS[_NX][nPosGuiD]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosTpIs]    := ODLGPLA:ACOLS[_NX][nPosTpIs]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosPeri]    := ODLGPLA:ACOLS[_NX][nPosPeri]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosVrIs]    := ODLGPLA:ACOLS[_NX][nPosVrIs]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosVrSe]    := ODLGPLA:ACOLS[_NX][nPosVrSe]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosHrIn]    := ODLGPLA:ACOLS[_NX][nPosHrIn]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosHrFi]    := ODLGPLA:ACOLS[_NX][nPosHrFi]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosDtFi]    := ODLGPLA:ACOLS[_NX][nPosDtFi]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosDtEn]    := ODLGPLA:ACOLS[_NX][nPosDtEn]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosLocD]    := ODLGPLA:ACOLS[_NX][nPosLocD]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosDtPr]    := ODLGPLA:ACOLS[_NX][nPosDtPr]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosUltF]    := ODLGPLA:ACOLS[_NX][nPosUltF]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosSaba]    := ODLGPLA:ACOLS[_NX][nPosSaba]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosDomi]    := ODLGPLA:ACOLS[_NX][nPosDomi]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosConP]    := ODLGPLA:ACOLS[_NX][nPosConP]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosTipP]    := ODLGPLA:ACOLS[_NX][nPosTipP]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosObs]    := ODLGPLA:ACOLS[_NX][nPosObs]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosHrFa]    := ODLGPLA:ACOLS[_NX][nPosHrFa]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosVlRe]    := ODLGPLA:ACOLS[_NX][nPosVlRe]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosCus5]    := ODLGPLA:ACOLS[_NX][nPosCus5]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosNatu]    := ODLGPLA:ACOLS[_NX][nPosNatu]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosFile]    := ODLGPLA:ACOLS[_NX][nPosFile]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosAjus]    := ODLGPLA:ACOLS[_NX][nPosAjus]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosDAju]    := ODLGPLA:ACOLS[_NX][nPosDAju]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosNive]    := ODLGPLA:ACOLS[_NX][nPosNive]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosTesF]    := ODLGPLA:ACOLS[_NX][nPosTesF]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosTesR]    := ODLGPLA:ACOLS[_NX][nPosTesR]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosCliF]    := ODLGPLA:ACOLS[_NX][nPosCliF]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosLojF]    := ODLGPLA:ACOLS[_NX][nPosLojF]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosNomF]    := ODLGPLA:ACOLS[_NX][nPosNomF]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosQtdP]    := ODLGPLA:ACOLS[_NX][nPosQtdP]
                    ODLGPLA:ACOLS[ODLGPLA:nAt][nPosTpBa]    := ODLGPLA:ACOLS[_NX][nPosTpBa]
                EndIf
                _XREC := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])==CCAMPO})]
            ENDIF
        ENDIF
    NEXT

RETURN _XREC


// ROTINA PARA REPLICAR O CONTEUDO DOS CAMPOS
// FRANK 23/10/20
FUNCTION LOCXITU05()
LOCAL XCONTEUDO
LOCAL _NX
LOCAL _CSEQ
LOCAL _DINI
LOCAL _DFIM
LOCAL _CCAMPO := ALLTRIM(READVAR())
LOCAL _NPRCX
LOCAL _NQTDX
LOCAL _NVLRX
LOCAL _NACRX
LOCAL _NPDEX

    IF !EMPTY(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})])
        IF EMPTY(SUBSTR(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],5,1) )
            _CSEQ := SUBSTR(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],1,3)
            IF MSGYESNO(STR0012,STR0010) //"CONFIRMA A PASSAGEM DOS DADOS PARA TODAS AS LINHAS DOS ITENS FILHOS?"###"ATENวรO!"
                FOR _NX := 1 TO LEN(ODLGPLA:ACOLS)
                    IF !ODLGPLA:ACOLS[_NX][LEN(ODLGPLA:AHEADER)+1]
                        IF SUBSTR(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],1,3) == _CSEQ
                            IF !EMPTY(SUBSTR(ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],5,1) )
                                ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])==ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO)))})] := &(_CCAMPO)

                                IF ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO))) == "FPA_DTFIM" .OR. ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO))) == "FPA_DTINI"
                                    _DINI := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTINI"})]
                                    _DFIM := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTFIM"})]
                                    IF !EMPTY(_DINI) .AND. !EMPTY(_DFIM)
                                        ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})] := _DFIM - _DINI + 1
                                    ELSE
                                        ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})] := 0
                                    ENDIF
                                ENDIF

                                IF ALLTRIM(SUBSTR(_CCAMPO,4,LEN(_CCAMPO))) == "FPA_CODTAB"
                                    //RUNTRIGGER(2,_NX,NIL,,"FPA_CODTAB")
                                    DA0->(DBSETORDER(1))
                                    DA0->(DBSEEK(XFILIAL("DA0")+ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CODTAB"})]))
                                    SB1->(DBSETORDER(1))
                                    SB1->(DBSEEK(XFILIAL("SB1")+ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]))

                                    ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DESTAB"})] := DA0->DA0_DESCRI
                                    ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})] := GETADVFVAL('DA1','DA1_PRCVEN',XFILIAL('DA1')+DA0->DA0_CODTAB+SB1->B1_COD,1,SB1->B1_PRV1,.T.)
                                    ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLBRUT"})] := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})] * ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})]

                                    _NPRCX := 0
                                    _NQTDX := 0
                                    _NPDEX := 0
                                    _NACRX := 0

                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"}) > 0
                                        _NPRCX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})]
                                    ENDIF
                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"}) > 0
                                        _NQTDX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_QUANT"})]
                                    ENDIF
                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLBRUT"}) > 0
                                        _NVLRX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VLBRUT"})]
                                    ENDIF
                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PDESC"}) > 0
                                        _NPDEX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PDESC"})]
                                    ENDIF
                                    IF ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ACRESC)"}) > 0
                                        _NACRX := ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ACRESC)"})]
                                    ENDIF

                                    ODLGPLA:ACOLS[_NX][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRHOR"})]  := (((_NPRCX * _NQTDX -(_NVLRX*(_NPDEX/100))) + (_NACRX)))
                                    ODLGPLA:REFRESH()

                                ENDIF

                            ENDIF
                        ENDIF
                    ENDIF
                NEXT
            ENDIF
            ODLGPLA:REFRESH()
        ENDIF
    ENDIF
    XCONTEUDO := &(_CCAMPO)
RETURN XCONTEUDO


// ROTINA PARA MONTAR A TABELA TEMPORมRIA EM SUBSTITUICAO DA CREATABLE
// FRANK EM 23/11/20
FUNCTION LOCXITU06(_NOPC, OTABLE, AFIELDS, AINDICES)
LOCAL CALIAS        AS CHAR
LOCAL CTABLENAME    AS CHAR
LOCAL _CTEMP
LOCAL _NX

    CALIAS := ""
    CTABLENAME := ""

    IF _NOPC == 3 // CRIA A TABELA TEMPORมRIA

        OTABLE := FWTEMPORARYTABLE():NEW( /*CALIAS*/, /*AFIELDS*/)

        OTABLE:SETFIELDS(AFIELDS)

        FOR _NX := 1 TO LEN(AINDICES)
            _CTEMP := "OTABLE:ADDINDEX('"+ALLTRIM(STR(_NX))+"', {'"+ALLTRIM(AINDICES[_NX][01])+"'} )"
            &(_CTEMP)
        NEXT

        OTABLE:CREATE()

        CALIAS := OTABLE:GETALIAS()

        CTABLENAME := OTABLE:GETREALNAME()

    ELSE // DELETA A TABELA TEMPORมRIA

        OTABLE:DELETE()

    ENDIF

RETURN {OTABLE, CALIAS, CTABLENAME}



#Include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ LOCDIASG  บ Autor ณ IT UP Business     บ Data ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Montas dias de Disponibilidade Alternados                  บฑฑ
ฑฑบ          ณ Chamada: LOCDISAC / LOCDISFR / LOC_A143 / LOCDISMO         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LOCXITU07( cQryInt , cCpoChv , cCpoDtI , cCpoDtF , dParDtI , dParDtF , cCpoFil )
Local aArea    := {}
Local cArqDias := ""
Local aCpoDia  := {}
Local cFrotAtu := ""
Local dDTAtu   := ""
Local I        := 0
Local cQryTer

Default cQryInt := "Select * from DTDT ORDER BY 1,2,3"
Default cCpoChv := "NOME"
Default cCpoDtI := "DATAI"
Default cCpoDtF := "DATAF"
Default dParDtI := StoD("20110101")
Default dParDtF := StoD("20110228")

    If Select("SX6") == 0
        RpcSetType(3)
        RpcSetEnv("06" , "01" , , , "FAT")
    Else
        aArea := GetArea()
    EndIf

    // Cria campos para tabela que sera abastecida com dias disponiveis
    aAdd( aCpoDia , {cCpoChv , "C" , 16,0} )
    aAdd( aCpoDia , {"DTINI" , "D" , 08,0} )
    aAdd( aCpoDia , {"DTFIM" , "D" , 08,0} )
    aAdd( aCpoDia , {cCpoDtI , "D" , 08,0} )
    aAdd( aCpoDia , {cCpoDtF , "D" , 08,0} )

    If cCpoFil <> Nil
        aAdd( aCpoDia , {cCpoFil, "C" , 02,0} )
    EndIf

    DIAS  := "TR34A"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
    IF TCCANOPEN(DIAS)
        TCDELFILE(DIAS)
    ENDIF
    DBCREATE(DIAS, aCpoDia, "TOPCONN")
    DBUSEAREA(.T., "TOPCONN", DIAS, (DIAS), .F., .F.)

    CT34B  := "TR34B"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
    IF TCCANOPEN(CT34B)
        TCDELFILE(CT34B)
    ENDIF
    DBCREATE(CT34B, aCpoDia, "TOPCONN")
    DBUSEAREA(.T., "TOPCONN", CT34B, (CT34B), .F., .F.)

    cQryAlt := "UPDATE " + CT34B + " SET " + cCpoDtI + "="+ dtos(dParDtI )+ " WHERE " + cCpoDtI + "< " + dtos(dParDtI )
    &('tcsqlexec(cQryAlt)')

    cQryAlt := "UPDATE " + CT34B + " SET " + cCpoDtF + "="+ dtos(dParDtF )+ " WHERE " + cCpoDtF + "> " + dtos(dParDtF )
    &('tcsqlexec(cQryAlt)')

    // Abre Novamente em TOP
    //DIAS->(dbClosearea())
    cQryTer := "SELECT DISTINCT "
    &('cQryTer += ccpoChv')
    &('cQryTer += If(cCpoFil <> Nil, "," + cCpoFil,"")')
    cQryTer += ","
    &('cQryTer += cCPODtI')
    cQryTer += ","
    &('cQryTer += cCPODTF')
    cQryTer += " from "
    &('cQryTer += CT34B')
    cQryTer += " ORDER BY "
    &('cQryTer += SUBSTR(CqRYINT,AT("ORDER BY", CQRYINT)+8,LEN(cQryInt))')
    dbUseArea(.T., "TOPCONN" , TCGenQry(,,cQryTer), "TRBDIA",.T.,.F.)
    TCSETFIELD("TRBDIA",cCpoDtI,"D",8,0)
    TCSETFIELD("TRBDIA",cCpoDtF,"D",8,0)

    cFrotAtu := TRBDIA->&cCpoChv + If(cCpoFil <> Nil, TRBDIA->&cCpoFil,"")
    dDTAtu   := dParDtI
    dDTFim   := dParDtF
    aChvBem  := {}

    While TRBDIA->( ! EOF() )
        If cCpoFil <> Nil
            M->&cCpoFil := TRBDIA->&cCpoFil
        EndIf

        M->&cCpoChv := TRBDIA->&cCpoChv
        M->&cCpoDtI := TRBDIA->&cCpoDtI
        M->&cCpoDtF := TRBDIA->&cCpoDtF

        dDTRes := TRBDIA->&cCpoDtF + 1

        If     dDTAtu < TRBDIA->&cCpoDtI
            dDTFim := TRBDIA->&cCpoDtI-1
        Elseif dDTAtu > TRBDIA->&cCpoDtF
            dDTFim := dParDtF
            dDTAtu := dDTRes
        EndIf

        TRBDIA->( dbSkip() ) 						// Avanca o ponteiro do registro no arquivo

        For I := 1 To 2
            If dDTAtu <= dDTFim .and. ( M->&cCpoDtI <> dParDtI .or. I==2).AND. dDTAtu <> M->&cCpoDtI
                RecLock("DIAS", .T.)
                If cCpoFil <> Nil
                    DIAS->&cCpoFil := M->&cCpoFil
                EndIf
                aAdd(aChvBem, M->&cCpoChv)
                DIAS->&cCpoChv := M->&cCpoChv
                DIAS->DTINI    := dDTAtu
                DIAS->DTFIM    := dDTFim
                DIAS->&cCpoDtI := M->&cCpoDtI
                DIAS->&cCpoDtF := M->&cCpoDtF
                DIAS->(MsUnLock())
            EndIf

            dDtAtu := dDTRes

            If cFrotAtu <> TRBDIA->&cCpoChv+If(cCpoFil <> Nil, TRBDIA->&cCpoFil,"").and.(dDTFim<>dParDtF.or.Ascan( aChvBem, M->&cCpoChv)== 0   )
                dDTFim   := dParDtF
                cFrotAtu := TRBDIA->(&cCpoChv) + If(cCpoFil <> Nil, TRBDIA->&cCpoFil,"")
                dDTRes   := dParDtI
            Else
                dDTFim   := dDTRes
                Exit
            EndIf
        Next I
        If dDTFim == dParDtF
            dDtAtu := dParDtI
        EndIf
    EndDo

    TRBDIA->(dbCloseArea())

    If Len(aArea) > 0
        RestArea(aArea)
    EndIf

Return DIAS //cArqDias


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณ LOCDIAS   บ Autor ณ IT UP Business     บ Data ณ 30/06/2007 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณ Montas dias de Disponibilidade Alternados                  บฑฑ
ฑฑบ          ณ Chamada: LOCDISMO.prw                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Especifico GPO                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function LOCXITU08(cQryInt , cCpoChv , cCpoDtI , cCpoDtF , dParDtI , dParDtF , cCpoFil)

Local cArqDias  := ""
Local aCpoDia   := {}
Local cFrotAtu  := ""
Local dDTAtu    := ""
Local I         := 0
Local cQryTer

Default cQryInt := "Select * from DTDT ORDER BY 1,2,3"
Default cCpoChv := "NOME"
Default cCpoDtI := "DATAI"
Default cCpoDtF := "DATAF"
Default dParDtI := stod("20110101")
Default dParDtF := stod("20110228")

    If Select("SX6") == 0
        RpcSetType(3)
        RpcSetEnv("06" , "01" , , , "FAT")
    EndIf

    // Cria campos para tabela que sera abastecida com dias disponiveis
    aAdd( aCpoDia     , {cCpoChv , "C" , 16,0} )
    aAdd( aCpoDia     , {"DTINI" , "D" , 08,0} )
    aAdd( aCpoDia     , {"DTFIM" , "D" , 08,0} )
    aAdd( aCpoDia     , {cCpoDtI , "D" , 08,0} )
    aAdd( aCpoDia     , {cCpoDtF , "D" , 08,0} )
    If cCpoFil <> Nil
        aAdd( aCpoDia , {cCpoFil , "C" , 02,0} )
    EndIf

    DIAS  := "TR34D"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
    IF TCCANOPEN(DIAS)
        TCDELFILE(DIAS)
    ENDIF
    DBCREATE(DIAS, aCpoDia, "TOPCONN")
    DBUSEAREA(.T., "TOPCONN", DIAS, (DIAS), .F., .F.)

    If Select("CT34DX") > 0
        CT34DX->(dbCloseArea())
    Endif

    CT34DX  := "TR34E"+SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)+SUBSTR(TIME(),7,2)
    IF TCCANOPEN(CT34DX)
        TCDELFILE(CT34DX)
    ENDIF
    DBCREATE(CT34DX, aCpoDia, "TOPCONN")

    cQryAlt := "UPDATE " + CT34DX + " SET " + cCpoDtI + "="+ DtoS(dParDtI )+ " WHERE " + cCpoDtI + "< " + DtoS(dParDtI )
    &('tcsqlexec(cQryAlt)')
    cQryAlt := "UPDATE " + CT34DX + " SET " + cCpoDtF + "="+ DtoS(dParDtF )+ " WHERE " + cCpoDtF + "> " + DtoS(dParDtF )
    &('tcsqlexec(cQryAlt)')

    cQryTer := "SELECT DISTINCT "
    &('cQryTer += ccpoChv')
    cQryTer += If(cCpoFil <> Nil, "," + cCpoFil,"")
    cQryTer += ","
    &('cQryTer += cCPODtI')
    cQryTer += ","
    &('cQryTer += cCPODTF')
    cQryTer += " FROM "
    &('cQryTer += CT34DX')
    cQryTer += " ORDER BY "
    &('cQryTer += SUBSTR(CqRYINT,AT("ORDER BY", CQRYINT)+8,LEN(cQryInt))')
    dbUseArea(.T., "TOPCONN" , TCGenQry(,,cQryTer), "CT34DY",.T.,.F.)
    TCSETFIELD("CT34DY",cCpoDtI,"D",8,0)
    TCSETFIELD("CT34DY",cCpoDtF,"D",8,0)

    cFrotAtu := CT34DY->&cCpoChv + If(cCpoFil <> Nil, CT34DY->&cCpoFil,"")
    dDTAtu   := dParDtI
    dDTFim   := dParDtF

    aChvBem  := {}

    While CT34DY->(!EOF())
        If cCpoFil <> Nil
            M->&cCpoFil := CT34DY->&cCpoFil
        EndIf
        M->&cCpoChv := CT34DY->&cCpoChv
        M->&cCpoDtI := CT34DY->&cCpoDtI
        M->&cCpoDtF := CT34DY->&cCpoDtF
        dDTRes := CT34DY->&cCpoDtF + 1
        If dDTAtu < CT34DY->&cCpoDtI
            dDTFim := CT34DY->&cCpoDtI-1
        Elseif dDTAtu > CT34DY->&cCpoDtF
            dDTFim := dParDtF
            dDTAtu := dDTRes
        EndIf
        CT34DY->(dbSkip()) // Avanca o ponteiro do registro no arquivo

        For I:=1 To 2
            If dDTAtu <= dDTFim .and. ( M->&cCpoDtI <> dParDtI .or. I==2)
                RecLock("DIAS", .T.)
                If cCpoFil <> Nil
                    DIAS->&cCpoFil := M->&cCpoFil
                EndIf
                aAdd(aChvBem, M->&cCpoChv)
                DIAS->&cCpoChv := M->&cCpoChv
                DIAS->DTINI    := dDTAtu
                DIAS->DTFIM    := dDTFim
                DIAS->&cCpoDtI := M->&cCpoDtI
                DIAS->&cCpoDtF := M->&cCpoDtF
                DIAS->(MsUnLock())
            EndIf
            dDtAtu := dDTRes
            If cFrotAtu <> CT34DY->&cCpoChv+If(cCpoFil <> Nil, CT34DY->&cCpoFil,"").and.(dDTFim<>dParDtF.or.Ascan( aChvBem, M->&cCpoChv)== 0   )
                dDTFim   := dParDtF
                cFrotAtu := CT34DY->(&cCpoChv) + If(cCpoFil <> Nil, CT34DY->&cCpoFil,"")
                dDTRes   := dParDtI
            Else
                Exit
            EndIf
    Next I

        If dDTFim == dParDtF
            dDtAtu := dParDtI
        EndIf
    EndDo

    CT34DY->(dbCloseArea())

Return DIAS //cArqDias


// Validacao do cliente na aba localidade
// Frank - 01/02/21
Function LOCXITU09
Local _lRet     := .T.
Local _cCli     := ODLGOBR:ACOLS[ODLGOBR:NAT][ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_CLIORI"})]
Local _cLoj     := ODLGOBR:ACOLS[ODLGOBR:NAT][ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_LOJORI"})]
Local _aArea    := GetArea()
Local _lAcha    := .F.

    SA1->(dbSetOrder(1))
    If Readvar() == "M->FP1_CLIORI"
        _cCli := &(Readvar())
        _lAcha := SA1->(dbSeek(xFilial("SA1")+_cCli))
    Else
        _cLoj := &(Readvar())
        _lAcha := SA1->(dbSeek(xFilial("SA1")+_cCli+_cLoj))
    EndIf

    If !_lAcha
        Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; //"RENTAL: "
        Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist๊ncia nos dados."
        {STR0015}) //"Cliente nใo localizado."
        _lRet := .F.
    EndIF
    RestArea(_aArea)
Return _lRet

// Frank Zwarg Fuga - 26/04/2021
// Rotina para fazer o reajuste dos contratos.
Function LOCXITU18
Local _cPerg    := "LOCP078"
Local aSize     := MsAdvSize()
Local oDlg
Local aObjects  := {}
Local aInfo
Local aPosObj
Local _cTitulo  := ""
Local CVARGRP
Local oOk       := LoadBitmap( GetResources(), "LBOK")
Local oNo       := LoadBitmap( GetResources(), "LBNO")
Local _nValor   := 0
Local _dFim     := ctod("")
Local _dProx    := ctod("")
Local _dAniv    := ctod("")
Local _nKm1     := 0
Local _nValor2  := 0
Local _dFim2    := ctod("")
Local _dProx2   := ctod("")
Local _dAniv2   := ctod("")
Local _cObs     := space(100)
Local _nGrava   := 0
Local _cTemp
Local _nTemp
Local _nZ
Local lContinua := .T.
Local nTotal    := 0
Local nTotaln   := 0
Local nDesc     := 0
Local nAcres    := 0

Private _aEsp   := {}
Private _nTot   := 0
Private _lProv  := .F.
Private _aItens := {}
Private oListP5
Private oVlr
Private ofim
Private oprox
Private oani
Private oVlr2
Private ofim2
Private oprox2
Private oani2
Private oObs
Private oKmi
Private oKmf
Private _nKm2   := 0
Private lInverte := .F.
Private oTotal
Private oTotaln
Private oDesc
Private oAcres
Private nPVlrn
Private nPVlro
Private nPDes
Private nPAcre
Private nPQtd
Private nPRecno


    oOk := LoadBitmap( GetResources(), "LBOK")
    oNo := LoadBitmap( GetResources(), "LBNO")


    (LOCXCONV(1))->(dbSetOrder(1))
    (LOCXCONV(1))->(dbSeek("FPA"))
    While !(LOCXCONV(1))->(Eof()) .and. GetSx3Cache(&(LOCXCONV(2)),"X3_ARQUIVO") == "FPA"
        If GetSx3Cache(&(LOCXCONV(2)),"X3_PROPRI") == "U" .and. X3Usado(&(LOCXCONV(2))) .and. GetSx3Cache(&(LOCXCONV(2)),"X3_CONTEXT") == "R" .and. GetSx3Cache(&(LOCXCONV(2)),"X3_TIPO") <> "M"
            aadd(_aEsp,{GetSx3Cache(&(LOCXCONV(2)),"X3_CAMPO"),GetSx3Cache(&(LOCXCONV(2)),"X3_TITULO")})
        EndIf
        (LOCXCONV(1))->(dbSkip())
    EndDo

    // Redimensionamento da tela
    AAdd( aObjects, { 100, 100, .T., .T. } ) // MsSelect
    AAdd( aObjects, {  50,  50, .T., .T. } ) // GetFixo
    aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
    aPosObj := MsObjSize( aInfo, aObjects,.T.)

    If !Pergunte(_cPerg,.T.)
        MsgAlert(STR0019,STR0010) //"Processo cancelado pelo usuแrio."###"Aten็ใo!"
        Return
    EndIf

    DEFINE FONT oFont  NAME "MonoAs" SIZE 0, -9 BOLD

    If MV_PAR01 == 1
        _cTitulo := STR0177 //"Reajuste dos contratos."

        Processa( {|| lContinua := LOCXITU12(_aEsp) }, STR0080 ) //"Localizando os contratos vแlidos."

    Else
        LOCXITU16(_aEsp)
        Return
    EndIf

    If lContinua

        DEFINE MSDIALOG oDlg TITLE _cTitulo From aSize[7],00 To aSize[6],aSize[5] of oMainWnd PIXEL

            @ aPosObj[1][1],aPosObj[1][2] LISTBOX oListP5 VAR cVarGrp FIELDS HEADER "";
            SIZE aPosObj[1][4],aPosObj[1][3]-70 ON DBLCLICK ( _aItens[oListP5:nAt,1] := !_aItens[oListP5:nAt,1],oListP5:Refresh() ) OF oDlg PIXEL

            aadd(oListP5:aheaders,STR0043) //"Projeto"
            aadd(oListP5:aheaders,STR0044) //"Cliente"
            aadd(oListP5:aheaders,STR0045) //"Loja"
            aadd(oListP5:aheaders,STR0046) //"Nome Cliente"
            aadd(oListP5:aheaders,STR0047) //"Obra"
            aadd(oListP5:aheaders,STR0048) //"Sequencia"
            aadd(oListP5:aheaders,STR0049) //"Produto"
            aadd(oListP5:aheaders,STR0050) //"Nome Produto"
            aadd(oListP5:aheaders,STR0051) //"Bem"
            aadd(oListP5:aheaders,STR0052) //"Nome Bem"
            aadd(oListP5:aheaders,STR0053) //"AS"
            aadd(oListP5:aheaders,STR0054) //"Valor parcela antigo"
            aadd(oListP5:aheaders,STR0055) //"Valor parcela novo"
            aadd(oListP5:aheaders,STR0056) //"Indice aplicado"
            aadd(oListP5:aheaders,STR0057) //"Tipo de indice"
            aadd(oListP5:aheaders,STR0058) //"Tipo de calculo"
            aadd(oListP5:aheaders,STR0059) //"Aniversario antigo"
            aadd(oListP5:aheaders,STR0060) //"Aniversario novo"
            aadd(oListP5:aheaders,STR0061) //"Data fim antigo"
            aadd(oListP5:aheaders,STR0062) //"Data fim novo"
            aadd(oListP5:aheaders,STR0063) //"Prox.fat. antigo"
            aadd(oListP5:aheaders,STR0064) //"Prox.fat. novo"
            aadd(oListP5:aheaders,STR0065) //"Observacao"
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                aadd(oListP5:aheaders,STR0066) //"Vl.Uni.Franq antigo"
                aadd(oListP5:aheaders,STR0067) //"Vl.Uni.Franq novo"
            EndIF

            aadd(oListP5:aheaders,STR0081) //"Quantidade"
            aadd(oListP5:aheaders,STR0082) //Total antigo
            aadd(oListP5:aheaders,STR0083) //Total novo
            aadd(oListP5:aheaders,STR0084) //Acr้scimo
            aadd(oListP5:aheaders,STR0085) //Desconto

            For _nZ := 1 to len(_aEsp)
                aadd(oListP5:aheaders,_aEsp[_nZ,2])
            Next

            oListP5:REFRESH()

            oListP5:SetArray(_aItens)
            oListP5:REFRESH()
            oListP5:bChange := {|| LOCXITU13()}
            oListP5:bHeaderClick = {|| LOCTU18T()}

            _cTemp := "{||{ If(_aItens[oListP5:nAt,1],oOk,oNo),"
            _cTemp += "_aItens[oListP5:nAt,2],"
            _cTemp += "_aItens[oListP5:nAt,3],"
            _cTemp += "_aItens[oListP5:nAt,4],"
            _cTemp += "_aItens[oListP5:nAt,5],"
            _cTemp += "_aItens[oListP5:nAt,6],"
            _cTemp += "_aItens[oListP5:nAt,7],"
            _cTemp += "_aItens[oListP5:nAt,8],"
            _cTemp += "_aItens[oListP5:nAt,9],"
            _cTemp += "_aItens[oListP5:nAt,10],"
            _cTemp += "_aItens[oListP5:nAt,11],"
            _cTemp += "_aItens[oListP5:nAt,12],"
            _cTemp += "_aItens[oListP5:nAt,13],"
            _cTemp += "_aItens[oListP5:nAt,14],"
            _cTemp += "_aItens[oListP5:nAt,15],"
            _cTemp += "_aItens[oListP5:nAt,16],"
            _cTemp += "_aItens[oListP5:nAt,17],"
            _cTemp += "_aItens[oListP5:nAt,18],"
            _cTemp += "_aItens[oListP5:nAt,19],"
            _cTemp += "_aItens[oListP5:nAt,20],"
            _cTemp += "_aItens[oListP5:nAt,21],"
            _cTemp += "_aItens[oListP5:nAt,22],"
            _cTemp += "_aItens[oListP5:nAt,23],"
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                _cTemp += "_aItens[oListP5:nAt,24],"
                _cTemp += "_aItens[oListP5:nAt,25],"
                _cTemp += "_aItens[oListP5:nAt,26],"
                _cTemp += "_aItens[oListP5:nAt,27],"
                _cTemp += "_aItens[oListP5:nAt,28],"
                _cTemp += "_aItens[oListP5:nAt,29],"
                _cTemp += "_aItens[oListP5:nAt,30],"
                _cTemp += "_aItens[oListP5:nAt,31]"
                _nTemp := 32
            Else
                _cTemp += "_aItens[oListP5:nAt,24],"
                _cTemp += "_aItens[oListP5:nAt,25],"
                _cTemp += "_aItens[oListP5:nAt,26],"
                _cTemp += "_aItens[oListP5:nAt,27],"
                _cTemp += "_aItens[oListP5:nAt,28],"
                _cTemp += "_aItens[oListP5:nAt,29]"
                _nTemp := 30
            EndIF

            For _nZ := 1 to len(_aEsp)
                _cTemp += ",_aItens[oListP5:nAt,"+alltrim(str(_nTemp))+"]"
                _nTemp ++
            Next
            _cTemp += "}}"

            oListP5:bLine := &(_cTemp)
            oListP5:REFRESH()

            aPosObj[2][1] -= 70
            @ aPosObj[2][1]+35,aPosObj[2][2] SAY STR0068 Font oFont Pixel Of oDlg //"Valor unitแrio reajustado: "
            @ aPosObj[2][1]+48,aPosObj[2][2] SAY STR0069 Font oFont Pixel Of oDlg //"Data final: "
            @ aPosObj[2][1]+61,aPosObj[2][2] SAY STR0070 Font oFont Pixel Of oDlg //"Pr๓ximo faturamento: "
            @ aPosObj[2][1]+74,aPosObj[2][2] SAY STR0071 Font oFont Pixel Of oDlg //"Data do aniversแrio: "
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                @ aPosObj[2][1]+87,aPosObj[2][2] SAY STR0072 Font oFont Pixel Of oDlg //"Vl.Uni.Franq reajustado: "
            EndIF
            @ aPosObj[2][1]+100,aPosObj[2][2] SAY STR0086 Font oFont Pixel Of oDlg //"Valor Total:"
            @ aPosObj[2][1]+100,aPosObj[2][2]+180 SAY STR0087 Font oFont Pixel Of oDlg //"Valor total original: "

            @ aPosObj[2][1]+35,aPosObj[2][2]+180 SAY STR0088 Font oFont Pixel Of oDlg //"Valor unitแrio original: "
            @ aPosObj[2][1]+48,aPosObj[2][2]+180 SAY STR0089 Font oFont Pixel Of oDlg //"Data final original: "
            @ aPosObj[2][1]+61,aPosObj[2][2]+180 SAY STR0090 Font oFont Pixel Of oDlg //"Pr๓ximo faturamento original: "
            @ aPosObj[2][1]+74,aPosObj[2][2]+180 SAY STR0091 Font oFont Pixel Of oDlg //"Data do aniversแrio original: "
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                @ aPosObj[2][1]+87,aPosObj[2][2]+180 SAY STR0073 Font oFont Pixel Of oDlg //"Vl.Uni.Franq original: "
            EndIF
            @ aPosObj[2][1]+113,aPosObj[2][2]+180 SAY STR0092 Font oFont Pixel Of oDlg //"Acr้scimo:"
            @ aPosObj[2][1]+126,aPosObj[2][2]+180 SAY STR0093 Font oFont Pixel Of oDlg //"Desconto:"

            @ aPosObj[2][1]+35,aPosObj[2][2]+350 SAY STR0074 Font oFont Pixel Of oDlg //"Observa็ใo: "

            //@ aPosObj[2][1]+35,aPosObj[2][2]+75 MSGET oVlr var _nValor PICTURE("99999999.99") valid LOCXITU14("VALOR") Size  50,10 Pixel Of oDlg
            @ aPosObj[2][1]+35,aPosObj[2][2]+75 MSGET oVlr var _nValor PICTURE("99999999.99") when .f. Size  50,10 Pixel Of oDlg
            @ aPosObj[2][1]+48,aPosObj[2][2]+75 MSGET oFim var _dFim valid LOCXITU14("FIM") Size  50,10 Pixel Of oDlg
            @ aPosObj[2][1]+61,aPosObj[2][2]+75 MSGET oProx var _dProx valid LOCXITU14("PROX") Size  50,10 Pixel Of oDlg
            @ aPosObj[2][1]+74,aPosObj[2][2]+75 MSGET oAni var _dAniv valid LOCXITU14("NIVER") Size  50,10 Pixel Of oDlg
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                @ aPosObj[2][1]+87,aPosObj[2][2]+75 MSGET oKmf var _nKm2 PICTURE("99999999.99") valid LOCXITU14("KM") Size  50,10 Pixel Of oDlg when .f.
            EndIF
            @ aPosObj[2][1]+100,aPosObj[2][2]+75 MSGET oTotaln var nTotaln valid LOCXITU14("TOTAL") PICTURE("99999999.99") Size  50,10 Pixel Of oDlg

            @ aPosObj[2][1]+35,aPosObj[2][2]+270 MSGET oVlr2 var _nValor2 PICTURE("99999999.99") Size  50,10 Pixel Of oDlg when .f.
            @ aPosObj[2][1]+48,aPosObj[2][2]+270 MSGET ofim2 var _dFim2 Size  50,10 Pixel Of oDlg when .f.
            @ aPosObj[2][1]+61,aPosObj[2][2]+270 MSGET oprox2 var _dProx2 Size  50,10 Pixel Of oDlg when .f.
            @ aPosObj[2][1]+74,aPosObj[2][2]+270 MSGET oani2 var _dAniv2 Size  50,10 Pixel Of oDlg when .f.
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                @ aPosObj[2][1]+87,aPosObj[2][2]+270 MSGET oKmi var _nKm1 PICTURE("99999999.99") Size  50,10 Pixel Of oDlg when .f.
            EndIF
            @ aPosObj[2][1]+100,aPosObj[2][2]+270 MSGET oTotal var nTotal PICTURE("99999999.99") Size  50,10 Pixel Of oDlg when .f.
            @ aPosObj[2][1]+113,aPosObj[2][2]+270 MSGET oAcres var nAcres PICTURE("99999999.99") Size  50,10 Pixel Of oDlg when .f.
            @ aPosObj[2][1]+126,aPosObj[2][2]+270 MSGET oDesc var nDesc PICTURE("99999999.99") Size  50,10 Pixel Of oDlg when .f.

            //@ aPosObj[2][1]+48,aPosObj[2][2]+350 MSGET oObs var _cObs Size  50120,35 Pixel Of oDlg valid LOCXITU14("OBS")
            @ aPosObj[2][1]+48,aPosObj[2][2]+350 MSGET oObs var _cObs Size  150,10 Pixel Of oDlg valid LOCXITU14("OBS")

            //@ aPosObj[2][1]+74,aPosObj[2][2]+400 BUTTON "Aplicar altera็ใo"	SIZE 070,015 OF oDlg PIXEL ACTION( msgalert("TESTE") )
            //@ 190,300 BUTTON "Sair"		        SIZE 040,015 OF oPnlZP5 PIXEL ACTION oDlg:End()

        Activate MsDialog oDlg CENTERED On Init EnchoiceBar(oDlg,{|| If(MsgYesNo(STR0030,STR0010),If(.T.,(_nGrava:=1,oDlg:end()),.F.) ,.F.)},{|| oDlg:end()},,) //"Confirma a grava็ใo dos registros?"###"Aten็ใo!"

        If _nGrava == 1
            _nTot := 0
            Processa({|| ProcReaj() }, STR0075, STR0076, .t.) //"Gravando os reajustes." ####  "Aguarde..."
            MsgAlert(STR0020+alltrim(str(_nTot))+STR0021,STR0022) //"Processo realizado com sucesso, "###" contrato(s) reajustado(s)."###"Reajuste Contratual!"
        EndIF
    EndIf

Return .T.

// Controle para marcar todas as linhas do reajuste
Static Function LOCTU18T
Local nX
    If lInverte
        lInverte := .F.
        If MsgYesNo(STR0077,STR0010) //"Deseja selecionar todas as linhas?"###"Aten็ใo!"
            For nX := 1 to len(_aItens)
                _aItens[nX,1] := .T.
            Next
            oListP5:REFRESH()
        EndIF
    Else
        lInverte := .T.
        If MsgYesNo(STR0078,STR0010) //"Deseja desmarcar todas as linhas?"###"Aten็ใo!"
            For nX := 1 to len(_aItens)
                _aItens[nX,1] := .F.
            Next
            oListP5:REFRESH()
        EndIF
    EndIF
Return .t.

// Gravacao do reajuste de contrato
Static Function ProcReaj
Local _nZ
Local _nX
Local nIndice       := 0
Local _MV_LOC278    := getmv("MV_LOCX278",,.F.)
Local _LOCXIT02     := EXISTBLOCK("LOCXIT02")
Local _LOCXIT01     := EXISTBLOCK("LOCXIT01")
Local lAltera       := .F.

    ProcRegua(len(_aItens))
    
    // DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da gera็ใo do tํtulo provis๓rio pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
            _MV_LOC278 := .T.
        Else
            _MV_LOC278 := .F.
        EndIf
    EndIf

    If _MV_LOC278
        If MsgYesNo(STR0037,STR0010) //"Deseja atualizar os tํtulos provis๓rios?"###"Aten็ใo!"
            _lProv := .T.
        Else
            _lProv := .F.
        EndIf
    EndIF

    FPA->(dbSetOrder(1))
    For _nX := 1 to len(_aItens)
        lAltera := .F.
        IncProc()
        If _aItens[_nX,1]
            FPA->(dbSeek(xFilial("FPA")+_aItens[_nX,2]+_aItens[_nX,6]+_aItens[_nX,7]))
            //If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
            //    FPA->(dbGoto(_aItens[_nX, nPRecno ]))
            //else
            FPA->(dbGoto(_aItens[_nX, nPRecno ]))
            //EndIF
            FPA->(RecLock("FPA",.F.))
            // Atualizacao do valor unitario
            _nVRTOTO := FPA->FPA_PRCUNI
            FPA->FPA_PRCUNI := _aItens[_nX,14] // Valor unitario
            FPA->FPA_VLBRUT := FPA->FPA_QUANT*FPA->FPA_PRCUNI // Valor bruto
            FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT - (FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC))) // Valor base
            //FPA->FPA_VLHREX := FPA->FPA_VRHOR / FPA->FPA_MINDIA / FPA->FPA_LOCDIA // R$ Hrs Extra
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                FPA->FPA_VLHREX := _aItens[_nX,26]
            EndIF

            // Data final
            _dDTFIMO := FPA->FPA_DTENRE
            FPA->FPA_DTENRE := _aItens[_nX,21] // data final
            // Proximo faturamento
            _dULTFAO := FPA->FPA_DTFIM
            If FPA->FPA_DTFIM <> _aItens[_nX,23]
                lAltera := .T.
            EndIF
            FPA->FPA_DTFIM  := _aItens[_nX,23] // proximo faturamento
            If !empty(FPA->FPA_DTINI) .and. !empty(FPA->FPA_DTFIM) .and. lAltera
                IF empty(FPA->FPA_ULTFAT)
                    FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_DTINI + 1
                Else
                    FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_ULTFAT + 1
                EndIF
            EndIf

            // Data do aniversario
            _dANIVE2 := FPA->FPA_NIVER
            If MV_PAR19 == 1
                FPA->FPA_NIVER := _aItens[_nX,19] // data do aniversario
            EndIf
            FPA->(MsUnlock())

            // Atualiza็ใo do tํtulo provis๓rio
            // Frank em 26/20/2021
            If _MV_LOC278 .and. _lProv
                // Deleta os tํtulos provis๓rios
			    LOCA013DEL(2, FPA->FPA_PROJET, FPA->FPA_AS)
                
                /*FQB->(dbSetOrder(1))
                FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
                If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                    SE1->(dbSetOrder(1))
                    SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR))
                    While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
                        SE1->(RecLock("SE1",.F.))
                        SE1->(dbDelete())
                        SE1->(MsUnlock())
                        SE1->(dbSkip())
                    EndDo
                    While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                        FQB->(RecLock("FQB",.F.))
                        FQB->(dbDelete())
                        FQB->(MsUnlock())
                        FQB->(dbSkip())
                    EndDo
                EndIf
                */
                FP0->(dbSetOrder(1))
                FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
                _nRegX := FPA->(Recno())
                loca01318() // criacao do titulo provisorio
                FPA->(dbGoto(_nRegX))
            EndIF

            _cCod := GETSX8NUM("FQ9","FQ9_COD")
            ConfirmSx8()

            If MV_PAR21 == "1"
                IncProc(STR0038) //"Calculando o Indice acumulado."
                nIndice := ValIndice(FPA->FPA_AJUSTE,FPA->FPA_NIVER)
            Else
                nIndice := MV_PAR20
            EndIf

            FQ9->(RecLock("FQ9",.T.))
            FQ9->FQ9_FILIAL := xFilial("FQ9")
            FQ9->FQ9_PROJET := FPA->FPA_PROJET
            FQ9->FQ9_OBRA   := FPA->FPA_OBRA
            FQ9->FQ9_SEQGRU := FPA->FPA_SEQGRU
            FQ9->FQ9_PRODUT := FPA->FPA_PRODUT
            FQ9->FQ9_GRUA   := FPA->FPA_GRUA
            FQ9->FQ9_AS     := FPA->FPA_AS
            FQ9->FQ9_VRTOTO := _nVRTOTO
            FQ9->FQ9_VRTOTN := FPA->FPA_PRCUNI
            FQ9->FQ9_INDICE := MV_PAR08
            FQ9->FQ9_TPCALC := "A"
            FQ9->FQ9_DATA   := dDataBase
            FQ9->FQ9_HORA   := time()
            FQ9->FQ9_ANIVER := _dANIVE2
            FQ9->FQ9_ANIVE2 := FPA->FPA_NIVER
            FQ9->FQ9_OBS    := _aItens[_nX,24]
            FQ9->FQ9_DTFIMO := _dDTFIMO
            FQ9->FQ9_DTFIMN := FPA->FPA_DTENRE
            FQ9->FQ9_ULTFAO := _dULTFAO
            FQ9->FQ9_ULTFAN := FPA->FPA_DTFIM
            FQ9->FQ9_COD    := _cCod
            FQ9->FQ9_XATUIN := nIndice

            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                FQ9->FQ9_VLHREX := FPA->FPA_VLHREX
                FQ9->FQ9_VLHREO := _aItens[_nX,25]
            EndIF

            For _nZ := 1 to len(_aEsp)
                _cCampo1 := _aEsp[_nZ][01]
                _cCampo1 := "FQ9_"+substr(_aEsp[_nZ][01],5,10)
                _cCampo2 := _aEsp[_nZ][01]
                (LOCXCONV(1))->(dbSetOrder(2))
                If (LOCXCONV(1))->(dbSeek(_cCampo1))
                    &("FQ9->"+_cCampo1) := &("FPA->"+_cCampo2)
                EndIF
            Next

            FQ9->(MsUnlock())

            IF _LOCXIT02
                EXECBLOCK("LOCXIT02" , .T. , .T. , {1})  // 1 = Inclusao, 2 = Exclusao
            ENDIF

            IF _LOCXIT01
                EXECBLOCK("LOCXIT01" , .T. , .T. , {1,_aItens[_nX,15]})  // 1 = Inclusao, 2 = Exclusao
            ENDIF

            _nTot ++
        EndIF
    Next
Return

// Frank Zwarg Fuga - 28/04/2021
// Atualizacao da listbox do reajuste com os novos valores
Function LOCXITU14(cGet)
    If cGet == "VALOR"
        _aItens[oListP5:nAt][14] := transform(oVlr:cText,"99999999.99")
    ElseIf cGet == "FIM"
        _aItens[oListP5:nAt][21] := ofim:cText
    ElseIf cGet == "PROX"
        _aItens[oListP5:nAt][23] := oprox:cText
    ElseIf cGet == "NIVER"
        _aItens[oListP5:nAt][19] := oani:cText
    ElseIf cGet == "OBS"
        _aItens[oListP5:nAt][24] := oObs:cText
    ElseIf cGet == "KM"
        _aItens[oListP5:nAt][25] := oKmi:cText
        _aItens[oListP5:nAt][26] := oKmf:cText
    ElseIF cGet == "TOTAL"
        _nTemp := oTotaln:cText
        // tirar o acrescimo e somar os descontos
        _nTemp := _nTemp - _aItens[oListP5:nAt][nPAcre] + _aItens[oListP5:nAt][nPDes]
        // Encontrar o valor unitario reajustado
        _aItens[oListP5:nAt][14] := _nTemp / _aItens[oListP5:nAt][nPQtd]
        oVlr:cText := _aItens[oListP5:nAt][14]
    EndIf
    oListP5:refresh()
Return .T.

// Frank Zwarg Fuga - 28/04/2021
// Atualizacao da tela do reajuste
Function LOCXITU13
    // Valor original
    oVlr2:cText := _aItens[oListP5:nAt][13]     // valor original
    ofim2:cText := _aItens[oListP5:nAt][20]     // data final original
    oprox2:cText := _aItens[oListP5:nAt][22]    // proximo faturamento original
    oani2:cText := _aItens[oListP5:nAt][18]     // aniversario original
    If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
        oKmi:cText := _aItens[oListP5:nAt][25]  // Vl.Uni.Franq original
    EndIF
    oTotal:cText := _aItens[oListP5:nAt][nPVlro]
    oDesc:cText := _aItens[oListP5:nAt][nPAcre]
    oAcres:cText := _aItens[oListP5:nAt][nPDes]

    // Valor a ser aplicado
    oVlr:cText := _aItens[oListP5:nAt][14]      // valor reajustado
    ofim:cText := _aItens[oListP5:nAt][21]      // data final reajustado
    oprox:cText := _aItens[oListP5:nAt][23]     // proximo faturamento reajustado
    oani:cText := _aItens[oListP5:nAt][19]      // aniversario reajustado
    oObs:cText := _aItens[oListP5:nAt][24]      // observacao
    If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
        oKmf:cText := _aItens[oListP5:nAt][26] // Vl.Uni.Franq reajustado
    EndIf
    oTotaln:cText := _aItens[oListP5:nAt][nPVlrn]

Return .T.


// Frank Zwarg Fuga - 27/04/21
// Localizando os contratos para a realiza็ใo do reajuste
Function LOCXITU12(_aEsp)
Local _cQuery       := ""
Local _nX           := 0
Local _nZ           := 0
Local nIndice       := 0
Local _aArea        := GetArea()
Local _aResult      := {}
Local aButtons      := {}
Local aSays         := {}
//Local _MV_LOC067    := GetMV("MV_LOCX067",,.F.)
//Local lMvLocBac	    := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra็ใo com M๓dulo de Loca็๕es SIGALOC
Local lContinua     := .T.

    ProcRegua(3)

    _cQuery := "SELECT FPA.R_E_C_N_O_ AS REG "
    _cQuery += "FROM "+RetSqlName("FPA")+" FPA "
    _cQuery += "INNER JOIN "+RetSqlName("FP0")+" FP0 ON FP0.FP0_FILIAL = FPA.FPA_FILIAL AND FP0.FP0_PROJET = FPA.FPA_PROJET "
    _cQuery += " AND FP0.D_E_L_E_T_ = '' AND FP0.FP0_CLI >= ? AND FP0.FP0_CLI <= ? "
    _cQuery += " AND FP0.FP0_LOJA >= ? AND FP0.FP0_LOJA <= ? AND FP0.FP0_CLI > '' "
    _cQuery += " AND FP0.FP0_STATUS NOT IN ('6','7','A','B','C','8') "
    _cQuery += "WHERE FPA.D_E_L_E_T_ = '' "
    _cQuery += " AND FPA.FPA_PROJET >= ? "
    _CQUERY += " AND FPA.FPA_PROJET <= ? "
    _CQUERY += " AND FPA.FPA_DTINI >= ? "
    _CQUERY += " AND FPA.FPA_DTINI <= ? "
    _CQUERY += " AND FPA.FPA_GRUA >= ? "
    _CQUERY += " AND FPA.FPA_GRUA <= ? "
    //_CQUERY += " AND FPA.FPA_AJUSTE = '"+MV_PAR08+"' " // Filtro removido a pedido do Lui em 29/06/21
    // 04/05/2032 - SIGALOC94-624 - Jose Eulalio - Cadastro de Indice Mensal
    IF !empty(MV_PAR08)
        _CQUERY += " AND FPA.FPA_AJUSTE = ? "
    EndIF
    _CQUERY += " AND FPA.FPA_PRODUT >= ? "
    _CQUERY += " AND FPA.FPA_PRODUT <= ? "
    If !empty(MV_PAR17)
        _CQUERY += " AND FPA.FPA_NIVER >= ? "
    EndIF
    If !empty(MV_PAR18)
        _CQUERY += " AND FPA.FPA_NIVER <= ? "
    EndIF
    _CQUERY += " AND FPA.FPA_OBRA >= ? "
    _CQUERY += " AND FPA.FPA_OBRA <= ? "
    _CQUERY += " AND FPA.FPA_QUANT > 0 "
    _cQuery += " AND FPA.FPA_NFRET = '' " // Frank em 14/07/22 Card 429 sprint bug
    _cQuery += " AND FPA.FPA_TIPOSE <> 'S' " // Frank em 14/07/22 Card 429 sprint bug
    _cQuery += "ORDER BY FPA.FPA_PROJET + FPA.FPA_OBRA + FPA.FPA_SEQGRU "

    If Select("TFPA") > 0
        TFPA->(dbCloseArea())
    EndIf

    _cQuery := CHANGEQUERY(_cQuery)
    aBindParam := {XFILIAL("FP0")}

    cComando := "{"+'MV_PAR09'+","+'MV_PAR11'+","+'MV_PAR10'+","+'MV_PAR12'+","+'MV_PAR02'+","
    cComando += 'MV_PAR03'+","+'dtos(MV_PAR04)'+","+'dtos(MV_PAR05)'+","+'MV_PAR06'+","
    cComando += 'MV_PAR07'
    IF !empty(MV_PAR08)
        cComando += ","+'MV_PAR08'
    EndIF
    cComando += ","+'MV_PAR13'+","+'MV_PAR14'
    If !empty(MV_PAR17)
        cComando += ","+'dtos(MV_PAR17)'
    EndIF
    If !empty(MV_PAR18)
        cComando += ","+'dtos(MV_PAR18)'
    EndIF
    cComando += ","+'MV_PAR15'
    cComando += ","+'MV_PAR16'
    cComando += "}"
    aBindParam := &(cComando)

    MPSysOpenQuery(_cQuery,"TFPA",,,aBindParam)

    //dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery), "TFPA", .F., .T. )

    IncProc(STR0100) //"Sele็ใo dos registros."

    While !TFPA->(Eof())

        FPA->(dbGoto(TFPA->REG))

        // Card DSERLOCA-1911 - Frank em 02/01/24
        If (FPA->FPA_TIPOSE == "Z" .and. !empty(FPA->FPA_ULTFAT)) .or. FPA->FPA_TIPOSE == "S"
            TFPA->(dbSkip())
            LOOP
        EndIF

        //Prote็ใo para quando nao ้ alterado o pergunte
        If ValType(MV_PAR21) == "N"
            MV_PAR21 := cValToChar(MV_PAR21)
        EndIf

        //valida reajuste automatico
        If MV_PAR21 == "1"
            If Empty(FPA->FPA_AJUSTE) .Or. Empty(FPA->FPA_NIVER)
                If Len(aSays) == 0
                    Aadd(aSays, STR0039) //"Para Reajuste Automแtico ้ obrigat๓rio preencher o ํndice [FPA_AJUSTE] e "
                    Aadd(aSays, STR0040) //"o aniversแrio [FPA_NIVER]."
                    Aadd(aSays, STR0041) //"Itens nใo preenchidos (Filial + Projeto + Obra + Seq):"
                EndIf
                Aadd(aSays, FPA->FPA_FILIAL + FPA->FPA_PROJET + FPA->FPA_OBRA + FPA->FPA_SEQGRU )
                lContinua := .F.
            EndIf
        EndIf

        If lContinua

            FP0->(dbSetOrder(1))
            FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
            If empty(FP0->FP0_CLI)
                TFPA->(dbSkip())
                Loop
            EndIf
            SA1->(dbSetOrder(1))
            SA1->(dbSeek(xFilial("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA))
            SB1->(dbSetOrder(1))
            SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
            ST9->(dbSetOrder(1))
            ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))

            // Melhoria feita em 16/12/21 por Frank card 215
            //SIGALOC94-624 - 26/06/2023- Jose Eulalio - Lui informou que nใo deve ser consideramo esse parametro
            If !Empty(FPA->FPA_DTPRRT)
                If dDataBase >= FPA->FPA_DTPRRT
                    TFPA->(dbSkip())
                    Loop
                EndIF
            EndIf

            If MV_PAR21 == "1"
                IncProc(STR0101) //"Calculando o Indice acumulado."
                nIndice := ValIndice(FPA->FPA_AJUSTE,FPA->FPA_NIVER)
            Else
                nIndice := MV_PAR20
            EndIf

            aadd(_aResult,{ .T.,; // 1
                            FPA->FPA_PROJET,;//2
                            FP0->FP0_CLI,;//3
                            FP0->FP0_LOJA,;//4
                            SA1->A1_NOME,;//5
                            FPA->FPA_OBRA,;//6
                            FPA->FPA_SEQGRU,;//7
                            FPA->FPA_PRODUT,;//8
                            SB1->B1_DESC,;//9
                            FPA->FPA_GRUA,;//10
                            iif(ST9->(Eof()),"",ST9->T9_NOME),;//11
                            FPA->FPA_AS,;//12
                            transform(FPA->FPA_PRCUNI,"99999999.99"),;//13
                            transform(FPA->FPA_PRCUNI,"99999999.99"),;//14
                            Transform(nIndice ,"999999.99999"),;//15
                            FPA->FPA_AJUSTE,;//16
                            "Atualiza็ใo",;//17
                            FPA->FPA_NIVER,;//18
                            IIF(MV_PAR19 == 1, YearSum(FPA->FPA_NIVER, 1), FPA->FPA_NIVER),;//19
                            FPA->FPA_DTENRE,;//20
                            FPA->FPA_DTENRE,;//21
                            FPA->FPA_DTFIM,;//22
                            FPA->FPA_DTFIM,;//23
                            space(100)})

            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                AADD(_aResult[len(_aResult)],&("FPA->FPA_VLHREX")) // anterior//24
                AADD(_aResult[len(_aResult)],&("FPA->FPA_VLHREX")) // corrigido//25
            EndIF

            AADD(_aResult[len(_aResult)],&("FPA->FPA_QUANT")) //26
            nPQtd := len(_aResult[len(_aResult)])
            AADD(_aResult[len(_aResult)],&("FPA->FPA_VRHOR"))//27
            nPVlro := len(_aResult[len(_aResult)])
            AADD(_aResult[len(_aResult)],&("FPA->FPA_VRHOR")) //28
            nPVlrn := len(_aResult[len(_aResult)])
            AADD(_aResult[len(_aResult)],&("FPA->FPA_ACRESC")) //29
            nPAcre := len(_aResult[len(_aResult)])
            AADD(_aResult[len(_aResult)],&("FPA->FPA_VLBRUT*FPA->FPA_PDESC/100")) //30
            nPDes := len(_aResult[len(_aResult)])

            For _nZ := 1 to len(_aEsp)
                AADD(_aResult[len(_aResult)],&("FPA->"+_aEsp[_nZ][01]))
            Next
            AADD(_aResult[len(_aResult)],FPA->(Recno()))
            nPRecno := len(_aResult[len(_aResult)])

        EndIf

        TFPA->(dbSkip())
    EndDo

    If lContinua
        IncProc(STR0094) //"Montagem do ambiente de sele็ใo."

        If len(_aResult) == 0
            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                aadd(_aResult,{.F.,"","","","","","","","","","","",0,"0","0","",ctod(""),ctod(""),"",ctod(""),ctod(""),ctod(""),ctod(""),space(100),0,0,0,0,0,0,0})
            Else
                aadd(_aResult,{.F.,"","","","","","","","","","","",0,"0","0","",ctod(""),ctod(""),"",ctod(""),ctod(""),ctod(""),ctod(""),space(100),0,0,0,0,0})
            EndIF

            For _nZ := 1 to len(_aEsp)
                AADD(_aResult[len(_aResult)],Criavar("FPA->"+_aEsp[_nZ][01]))
            Next

            AADD(_aResult[len(_aResult)],0) // recno
            nPVlro  := 27
            nPDes   := 30
            nPAcre  := 29
            nPQtd   := 26
            nPVlrn  := 28
        EndIf

        IncProc(STR0095) //"Aplica็ใo do reajuste."

        For _nX := 1 to len(_aResult)
            //_nTemp := ( val(_aResult[_nX][14]) * val(_aResult[_nX][15])) / 100
            //_nTemp := val(_aResult[_nX][14]) + _nTemp
            //_aResult[_nX][14] := transform(_nTemp,"99999999.99")

            // Valor total
            _nTemp := _aResult[_nX][nPVlro]
            // tirar o acrescimo e somar os descontos
            _nTemp := _nTemp - _aResult[_nX][nPAcre] + _aResult[_nX][nPDes]
            _nTemp += (_nTemp * val(_aResult[_nX][15]))/100
            // Encontrar o valor unitario reajustado
            _aResult[_nX][14] := _nTemp / _aResult[_nX][nPQtd]
            _nTemp += _aResult[_nX][nPAcre]
            _nTemp -= _aResult[_nX][nPDes]
            _aResult[_nX][nPVlrn] := _nTemp



            If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                _nTemp := ( _aResult[_nX][25] * val(_aResult[_nX][15])) / 100
                _nTemp := _aResult[_nX][25] + _nTemp
                _aResult[_nX][26] := _nTemp
            EndIF

        next

        _aItens := _aResult // _aItens private da fun็ใo LOCXITU18
    Else

        aAdd(aButtons, { 1, .T., {|| lOk := .T., FechaBatch() }} )
        FormBatch(STR0042 , aSays , aButtons )  //"Itens sem Aniversแrio"

    EndIf

    RestArea(_aArea)

Return lContinua



// Frank Zwarg Fuga - 27/04/2021
// Gatilho para atualiza็ใo do campo FPA_PRCUNI
Function LOCXITU11(_cCampo)
Local _nRet    := 0
Local _cCodTab := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CODTAB"})]
Local _nPrcUni := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRCUNI"})]
Local _cProdut := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]
Local _aArea   := GetArea()
Local _lCalc   := .F.
    IF empty(ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AJUSTE"})])
        _lCalc := .T.
    Else
        If MsgYesNo(STR0031,STR0032) //"Deseja atualizar o valor unitแrio?"###"Recแlculo do valor unitแrio."
            _lCalc := .T.
        EndIF
    EndIf
    If _lCalc
        SB1->(dbSetorder(1))
        If SB1->(dbSeek(xFilial("SB1")+_cProdut))
            If _cCampo == "FPA_CODTAB"
                _nRet := GetAdvFVal('DA1','DA1_PRCVEN',xFilial('DA1')+_cCodTab+SB1->B1_COD,1,SB1->B1_PRV1,.t.)
            ElseIf _cCampo == "FPA_PRODUT"
                _nRet := GetAdvFVal('DA1','DA1_PRCVEN',xFilial('DA1')+_cCodTab+SB1->B1_COD,1,SB1->B1_PRV1,.t.)
            ElseIf _cCampo == "FPA_SEQSUB"
                _nRet := LOCXITU04("FPA_PRCUNI")
            Else
                _nRet := _nPrcUni
            EndIf
        EndIf
        If empty(_cProdut) .or. SB1->(Eof())
            _nRet := 0
        EndIf
    Else
        _nRet := _nPrcUni
    EndIf
    RestArea(_aArea)
Return _nRet


// Valida็ใo do campo FPA_TESFAT
// Frank Zwarg Fuga - 17/05/21
Function LOCXITU15
Local _lRet     := .T.
Local _aArea    := GetArea()

    SF4->(dbSetOrder(1))
    If SF4->(dbSeek(xFilial("SF4")+M->FPA_TESFAT))
        If SF4->F4_TIPO <> "S"
            _lRet := .F.
            Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; // "RENTAL: "
            Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; // "Inconsist๊ncia nos dados."
            {STR0016}) // "A TES selecionada nใo ้ de saํda."
        EndIf
    Else
        _lRet := .F.
        Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; // "RENTAL: "
        Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; // "Inconsist๊ncia nos dados."
        {STR0017}) // "A TES informada nใo foi localizada."
    EndIf
    RestArea(_aArea)
Return _lRet


// Rotina de extorno do reajuste contratual
// Frank Zwarg Fuga
// 03/06/21
Function LOCXITU16(_aEsp)
Local _cFiltro := ""
PRIVATE cCadastro := STR0096 //"Estorno dos reajustes"

    dbSelectArea("FQ9")
    dbSetOrder(1)

    _cFiltro := "FQ9_PROJET >= '"+MV_PAR02+"' and FQ9_PROJET <= '"+MV_PAR03+"' "
    _cFiltro += "and FQ9_OBRA >= '"+MV_PAR15+"' and FQ9_OBRA <= '"+MV_PAR16+"' "
    _cFiltro += "and FQ9_PRODUT >= '"+MV_PAR13+"' and FQ9_PRODUT <= '"+MV_PAR14+"' "
    _cFiltro += "and FQ9_GRUA >= '"+MV_PAR06+"' and FQ9_GRUA <= '"+MV_PAR07+"' "
    IF !empty(MV_PAR17) .or. !empty(MV_PAR18)
        _cFiltro += "and FQ9_ANIVE2 >= '"+dtos(MV_PAR17)+"' and FQ9_ANIVE2 <= '"+dtos(MV_PAR18)+"' "
    EndIF
    IF !empty(MV_PAR04) .or. !empty(MV_PAR05)
        _cFiltro += "and FQ9_DATA >= '"+dtos(MV_PAR04)+"' and FQ9_DATA <= '"+dtos(MV_PAR05)+"' "
    EndIF
    IF !empty(MV_PAR08)
        _cFiltro += "and FQ9_INDICE = '"+MV_PAR08+"' "
    EndIF


    PRIVATE AROTINA   := {{STR0097 ,"AXPESQUI"  ,0,1},; //"Pesquisar"
                        {STR0098,"AXVISUAL"  ,0,2},; //"Visualizar"
                        {STR0099 ,"LOCXITU17" ,0,4}} //"Restaurar"

    MBROWSE( 6,1,22,75,        "FQ9" ,,,,,,,,,,,,,,_cFiltro)

Return


// Estorno dos movimentos de reajuste
// Frank Zwarg Fuga - 03/06/21

Function LOCXITU17
Local _nReg
Local _cProj := FQ9->FQ9_PROJET
Local _dData := FQ9->FQ9_DATA
Local _cHora := FQ9->FQ9_HORA
Local _MV_LOC278 := getmv("MV_LOCX278",,.F.)
Local _LOCXIT01 := EXISTBLOCK("LOCXIT01")

    If FQ9->FQ9_MSBLQL == "1"
        MsgAlert(STR0023,STR0024) // "Reajuste jแ restaurado."###"Processo bloqueado."
        Return
    EndIf

    // DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da gera็ใo do tํtulo provis๓rio pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
            _MV_LOC278 := .T.
        Else
            _MV_LOC278 := .F.
        EndIf
    EndIf

    // Nใo permitir um estorno de um registro menor
    _nReg := FQ9->(Recno())
    FQ9->(dbSetOrder(1))
    FQ9->(dbSeek(xFilial("FQ9")+_cProj))
    While !FQ9->(Eof()) .and. FQ9->FQ9_FILIAL == xFilial("FQ9") .and. FQ9->FQ9_PROJET == _cProj
        If FQ9->FQ9_MSBLQL <> "1"
            If FQ9->FQ9_DATA > _dData
                MsgAlert(STR0025,STR0026) // "Existe um reajuste mais atual do que o posicionado."###"Processo bloqueado!"
                FQ9->(dbGoto(_nReg))
                Return .F.
            EndIF
            IF FQ9->FQ9_DATA == _dData .and. FQ9->(Recno()) <> _nReg
                IF FQ9->FQ9_HORA > _cHora
                    MsgAlert(STR0025,STR0026) // "Existe um reajuste mais atual do que o posicionado."###"Processo bloqueado!"
                    FQ9->(dbGoto(_nReg))
                    Return .F.
                EndIF
            EndIF
        EndIF
        FQ9->(dbSkip())
    EndDo
    FQ9->(dbGoto(_nReg))

    If MsgYesNo(STR0033,STR0010) //"Confirma a restaura็ใo dos valores?"###"Aten็ใo!"
        FPA->(dbSetOrder(1))
        If FPA->(dbSeek(xFilial("FPA")+FQ9->(FQ9_PROJET+FQ9_OBRA+FQ9_SEQGRU)))
            If FPA->(RecLock("FPA",.F.))
                // Atualizacao do valor unitario
                FPA->FPA_PRCUNI := FQ9->FQ9_VRTOTO // Valor unitario
                FPA->FPA_VLBRUT := FPA->FPA_QUANT*FPA->FPA_PRCUNI // Valor bruto
                FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT - (FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC))) // Valor base
                If FPA->(FieldPos("FPA_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREX")) > 0 .and. FQ9->(FieldPos("FQ9_VLHREO")) > 0
                    FPA->FPA_VLHREX := FQ9->FQ9_VLHREO // R$ Hrs Extra
                EndIF

                // Data final
                FPA->FPA_DTENRE := FQ9->FQ9_DTFIMO // data final
                // Proximo faturamento
                FPA->FPA_DTFIM  := FQ9->FQ9_ULTFAO // proximo faturamento
                If !empty(FPA->FPA_DTINI) .and. !empty(FPA->FPA_DTFIM)
                    FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_DTINI + 1
                EndIf


                // Data do aniversario
                If MV_PAR19 == 1
                    FPA->FPA_NIVER := FQ9->FQ9_ANIVER // data do aniversario
                EndIf
                FPA->(MsUnlock())

                // Atualiza็ใo do tํtulo provis๓rio
                // Frank em 26/20/2021
                If _MV_LOC278
                    FQB->(dbSetOrder(1))
                    FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
                    If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                        SE1->(dbSetOrder(1))
                        SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR))
                        While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
                            SE1->(RecLock("SE1",.F.))
                            SE1->(dbDelete())
                            SE1->(MsUnlock())
                            SE1->(dbSkip())
                        EndDo
                        While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == FPA->FPA_PROJET+FPA->FPA_AS
                            FQB->(RecLock("FQB",.F.))
                            FQB->(dbDelete())
                            FQB->(MsUnlock())
                            FQB->(dbSkip())
                        EndDo
                    EndIf
                    FP0->(dbSetOrder(1))
                    FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
                    _nRegX := FPA->(Recno())
                    loca01318() // criacao do titulo provisorio
                    FPA->(dbGoto(_nRegX))
                EndIF

                IF _LOCXIT01
                    EXECBLOCK("LOCXIT01" , .T. , .T. , {2, FQ9->FQ9_XATUIN}) // 1 = Inclusao, 2 = Exclusao
                ENDIF

                FQ9->(RecLock("FQ9"),.F.)
                FQ9->FQ9_MSBLQL := "1"
                FQ9->(MsUnlock())

                MsgAlert(STR0027,STR0028) //"Processo realizado com sucesso."###"Reajuste estornado."
            EndIF
        EndIf
    EndIF
Return

// Rotina para o calculo do ISS no contrato (manuten็ใo)
// Frank Z Fuga em 15/07/21 - usado no SX7
// DSERLOCA - 2523 - Rossana

Function LOCXITU10

Local _nValor := 0
Local _cTipo  := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TPISS"})]
Local _nBase  := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRHOR"})]
Local _nImp   := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PERISS"})]
Local _nFrIda := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GUIMON"})]
Local _nFrVol := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GUIDES"})]

Local _nVSegu := 0
Local _nVMob  := 0
Local _nDesm  := 0

Local cX3_USADO := ""

    cX3_USADO := GetSX3Cache("FPA_VRSEGU", "X3_USADO")
    If x3Uso(cX3_USADO)
        _nVSegu := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRSEGU"})]
    EndIf

    cX3_USADO := ""
    cX3_USADO := GetSX3Cache("FPA_VRMOB", "X3_USADO")
    If x3Uso(cX3_USADO)
        _nVMob  := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRMOB"})]
    EndIf

    cX3_USADO := ""
    cX3_USADO := GetSX3Cache("FPA_VRDES", "X3_USADO")
    If x3Uso(cX3_USADO)
        _nDesm  := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VRDES"})]
    EndIf

    IF _cTipo $ "X "
        _nValor := 0
    ElseIF _cTipo=="I"
        _nValor := (_nBase + _nVSegu + _nVMob + _nDesm + _nFrIda + _nFrVol) * (_nImp / 100)
    ElseIf _cTipo=="N"
        _nValor := ((_nBase + _nVSegu + _nVMob + _nDesm + _nFrIda + _nFrVol)/ (100 - _nImp) * 100) - (_nBase + _nVSegu + _nVMob + _nDesm + _nFrIda + _nFrVol)
    EndIF

Return _nValor

// Rotina responsแvel por gatilhar componentes da estrutura de bens nos itens do Projeto
// Fernando Alves em 09/07/2021
// Frank Zwarg Fuga - produtiza็ใo em 27/08/21
Function LOCXITU19
Local lRet      := .T.
Local cAliasSTC := GetNextAlias()
Local cEquip    := ''
Local aItem     := {}
Local nI  		:= 0
Local nJ  		:= 0
Local cSeq      := StrZero(Len(ODLGPLA:ACOLS),3,0)
Local aItemAux  := {}

Local aULTPECASR := {}
Local nPos 		 := 0
Local nPosSequ  := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_SEQGRU"  })
Local nPosProd  := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_PRODUT"  })
Local nPosDesc  := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_DESPRO"  })
Local nPosEquip := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_GRUA"    })
Local nPosDesEq := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_DESGRU"  })
Local nPosQuant := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_QUANT"  })

Local nPosXX01 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_AS"    })
Local nPosXX02 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_NFREM"  })
Local nPosXX03 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_DNFREM"  })
Local nPosXX04 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_SERREM"  })
Local nPosXX05 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_ITEREM"  })
Local nPosVincB := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})

Local nPosXX06 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_PRCUNI"  })
Local nPosXX07 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_VRHOR"  })
Local nPosXX08 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_VLBRUT"  })

Local nPosXX09 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_NFRET"  })
Local nPosXX10 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_SERRET"  })
Local nPosXX11 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_ITERET"  })
Local nPosXX12 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_DNFRET"  })

Local nPosXX13 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_PEDIDO"  })
Local nPosXX14 := Ascan(ODLGPLA:AHEADER,{|x|Alltrim(Upper(x[2])) == "FPA_VIAGEM"  })

Local _aArea := GetArea()
Local _cSeq1 := "000"
Local cQuery

    IF !OFOLDER:NOPTION == 3
        Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; //"RENTAL: "
                        Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist๊ncia nos dados."
                        {STR0018}) //"Selecionar a aba Loca็ใo."
        RETURN .F.
    ENDIF

    For nJ := 1 to Len(ODLGPLA:ACOLS)
        If !ODLGPLA:ACOLS[nJ][len(ODLGPLA:AHEADER)+1]
            If substr(ODLGPLA:ACOLS[nJ][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],1,3) > _cSeq1
                _cSeq1 := substr(ODLGPLA:ACOLS[nJ][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})],1,3)
            EndIF
        EndIF
    Next
    _cSeq1 := Soma1(_cSeq1)
    _cSeq2 := "000"

    For nJ := 1 to Len(ODLGPLA:ACOLS)

        cEquip  := ODLGPLA:ACOLS[nJ][nPosEquip]
        aItem   := ODLGPLA:ACOLS[nJ]

        If !Empty(cEquip) .And. Empty(Alltrim(ODLGPLA:ACOLS[nJ][nPosVincB])) .and. !ODLGPLA:ACOLS[nJ][len(ODLGPLA:AHEADER)+1]

            // ------------------------------------------------------------------------
            // Utilizo a Fun็ใo padrใo para obter a estrutura de produtos de reposi็ใo
            // ------------------------------------------------------------------------
            aULTPECASR := NGPEUTIL(cEquip)

            //BeginSQL Alias cAliasSTC
            //SELECT TC_COMPONE FROM %Table:STC% STC WHERE TC_CODBEM = %Exp:cEquip% AND STC.%NotDel%
            //EndSQL

            /*
            +cEquip+
            */

            cQuery := "SELECT TC_COMPONE FROM "
            cQuery += RetSqlName("STC")+" STC WHERE "
            cQuery += "TC_CODBEM = ? AND D_E_L_E_T_ = '' "
            cQuery := CHANGEQUERY(cQuery)
            aBindParam := {cEquip}

// DSERLOCA - 2392 - Rossana em 21/02/2024 - Erro na Sintaxe do comando MPSysOpenQuery
//         Anterior -> cAliasSTC := MPSysOpenQuery(cEquip,,,,aBindParam)

            MPSysOpenQuery(cQuery,cAliasSTC,,,aBindParam)


            If (cAliasSTC)->(!Eof())

                If MsgYesNo(STR0034, STR0010) //"Deseja carregar a estrutura do bem?"###"Aten็ใo"

                    While (cAliasSTC)->(!Eof())

                        nPos := aScan(ODLGPLA:ACOLS,{|x| AllTrim(x[nPosEquip])== Alltrim((cAliasSTC)->TC_COMPONE) })

                        If nPos == 0

                            aItemAux:= aClone(aItem)
                            cSeq := Soma1(cSeq)

                            ST9->(dbSetOrder(1))
                            ST9->(dbSeek(xFilial("ST9")+(cAliasSTC)->TC_COMPONE))
                            SB1->(dbSetOrder(1))
                            SB1->(dbSeek(xFilial("SB1")+ST9->T9_CODESTO))

                            aItemAux[nPosSequ]  := cSeq
                            aItemAux[nPosProd]  := ST9->T9_CODESTO
                            aItemAux[nPosDesc]  := SB1->B1_DESC
                            aItemAux[nPosEquip] := (cAliasSTC)->TC_COMPONE
                            aItemAux[nPosDesEq] := ST9->T9_NOME
                            _cSeq2 := Soma1(_cSeq2)
                            aItemAux[nPosVincB] := _cSeq1+"."+_cSeq2

                            aItemAux[nPosXX01] := ''
                            aItemAux[nPosXX02] := ''
                            aItemAux[nPosXX03] := StoD('')
                            aItemAux[nPosXX04] := ''
                            aItemAux[nPosXX05] := ''

                            aItemAux[nPosXX06] := 0
                            aItemAux[nPosXX07] := 0
                            aItemAux[nPosXX08] := 0

                            aItemAux[nPosXX09] := ''
                            aItemAux[nPosXX10] := ''
                            aItemAux[nPosXX11] := ''
                            aItemAux[nPosXX12] := StoD('')

                            aItemAux[nPosXX13] := ''
                            aItemAux[nPosXX14] := ''

                            //DbSelectArea('ST9')
                            //ST9->(dbSetOrder(1))
                            //If ST9->(dbSeek( xFilial("ST9") + (cAliasSTC)->TC_COMPONE ))


                            //Endif

                            If len(aItemAux) > 0
                                ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})] := _cSeq1
                            EndIf
                            aAdd(ODLGPLA:ACOLS, aItemAux)

                        EndIf

                        (cAliasSTC)->(DbSkip())
                    EndDo

                    For nI := 1 to Len(aULTPECASR)

                        nPos := aScan(ODLGPLA:ACOLS,{|x| AllTrim(x[nPosProd])== Alltrim(aULTPECASR[nI][1]) })

                        If nPos == 0

                            aItemAux:= aClone(aItem)
                            cSeq := Soma1(cSeq)

                            aItemAux[nPosSequ]  := cSeq

                            aItemAux[nPosProd]  := aULTPECASR[nI][1]
                            aItemAux[nPosDesc]  := POSICIONE('SB1',1,xFilial('SB1')+aItemAux[nPosProd],'B1_DESC')
                            aItemAux[nPosEquip] := ''
                            aItemAux[nPosDesEq] := ''
                            _cSeq2 := Soma1(_cSeq2)
                            aItemAux[nPosVincB] := _cSeq1+"."+_cSeq2

                            aItemAux[nPosXX01] := ''
                            aItemAux[nPosXX02] := ''
                            aItemAux[nPosXX03] := StoD('')
                            aItemAux[nPosXX04] := ''
                            aItemAux[nPosXX05] := ''

                            aItemAux[nPosXX06] := 0
                            aItemAux[nPosXX07] := 0
                            aItemAux[nPosXX08] := 0

                            aItemAux[nPosXX09] := ''
                            aItemAux[nPosXX10] := ''
                            aItemAux[nPosXX11] := ''
                            aItemAux[nPosXX12] := StoD('')

                            aItemAux[nPosXX13] := ''
                            aItemAux[nPosXX14] := ''

                            TPY->(dbSetOrder(1))
                            If TPY->(dbSeek(xFilial("TPY")+cEquip+aULTPECASR[nI][1]))
                                aItemAux[nPosQuant] := TPY->TPY_QUANTI
                            EndIF

                            If len(aItemAux) > 0
                                ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})] := _cSeq1
                            EndIf
                            aAdd(ODLGPLA:ACOLS, aItemAux)

                        EndIf

                    Next nI

                    (cAliasSTC)->(DbCloseArea())

                EndIf

            Else
                For nI := 1 to Len(aULTPECASR)

                    nPos := aScan(ODLGPLA:ACOLS,{|x| AllTrim(x[nPosProd])== Alltrim(aULTPECASR[nI][1]) })

                    If nPos == 0

                        aItemAux:= aClone(aItem)
                        cSeq := Soma1(cSeq)

                        aItemAux[nPosSequ]  := cSeq

                        aItemAux[nPosProd]  := aULTPECASR[nI][1]
                        aItemAux[nPosDesc]  := POSICIONE('SB1',1,xFilial('SB1')+aItemAux[nPosProd],'B1_DESC')
                        aItemAux[nPosEquip] := ''
                        aItemAux[nPosDesEq] := ''
                        _cSeq2 := Soma1(_cSeq2)
                        aItemAux[nPosVincB] := _cSeq1+"."+_cSeq2

                        aItemAux[nPosXX01] := ''
                        aItemAux[nPosXX02] := ''
                        aItemAux[nPosXX03] := StoD('')
                        aItemAux[nPosXX04] := ''
                        aItemAux[nPosXX05] := ''

                        aItemAux[nPosXX06] := 0
                        aItemAux[nPosXX07] := 0
                        aItemAux[nPosXX08] := 0

                        aItemAux[nPosXX09] := ''
                        aItemAux[nPosXX10] := ''
                        aItemAux[nPosXX11] := ''
                        aItemAux[nPosXX12] := StoD('')

                        aItemAux[nPosXX13] := ''
                        aItemAux[nPosXX14] := ''

                        TPY->(dbSetOrder(1))
                        If TPY->(dbSeek(xFilial("TPY")+cEquip+aULTPECASR[nI][1]))
                            aItemAux[nPosQuant] := TPY->TPY_QUANTI
                        EndIF

                        If len(aItemAux) > 0
                            ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})] := _cSeq1
                        EndIf
                        aAdd(ODLGPLA:ACOLS, aItemAux)

                    EndIf

                Next nI
            EndIf
        EndIf

    Next nJ

    RestArea(_aArea)

Return lRet

// Atualizar o c๓digo da estrutura da FPA
// Frank Zwarg Fuga em 27/08/21
Function LOCXITU20
LOCAL APARAMBOX := {}
LOCAL ARET 		:= {}
LOCAL CPAI      := "   "
LOCAL CFILHO1   := "   "
LOCAL CFILHO2   := "   "
LOCAL CFILHO3   := "   "
Local _cTitu    := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})]

    IF !OFOLDER:NOPTION == 3
        Help(Nil,	Nil,STR0013+alltrim(upper(Procname())),; //"RENTAL: "
                        Nil,STR0014,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsist๊ncia nos dados."
                        {STR0018}) //"Selecionar a aba Loca็ใo."
        RETURN .F.
    ENDIF

    AADD(APARAMBOX,{1,STR0102  , cPai,   "999", "", "", "", 50, .T.}) //"Cod Pai"
    AADD(APARAMBOX,{1,STR0103, cFilho1, "999", "", "", "", 50, .F.}) //"Nivel 1 Filho"
    AADD(APARAMBOX,{1,STR0104, cFilho2, "999", "", "", "", 50, .F.}) //"Nivel 2 Filho"
    AADD(APARAMBOX,{1,STR0105, cFilho3, "999", "", "", "", 50, .F.}) //"Nivel 3 Filho"
    IF PARAMBOX(APARAMBOX,STR0106,@ARET,,,,,,,,.F.) //"Estrutura de produtos/bens"
        cPai := ARET[1]
        cFilho1 := ARET[2]
        cFilho2 := ARET[3]
        cFilho3 := ARET[4]
    ENDIF

    If empty(cPai)
        MsgAlert(STR0029,STR0010) //"Nใo foi selecionado o item Pai."###"Aten็ใo!"
        Return .F.
    EndIF

    If MsgYesNo(STR0035,STR0036+_cTitu) // "Confirma o processo de estrutura de produtos?"###"Produto: "
        ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQEST"})] := cPai+"."+cFilho1+"."+cFilho2+"."+cFilho3+"MAN"
    EndIF

Return .T.


// Gravacao do historico dos bens
// Antigo T9STSALT
// Frank Zwarg Fuga em 30/08/21
Function LOCXITU21(_cStsOld, _cStsNew, _cContr, _cDocto, _cSerie, _lDel)
Local _aAreaOld  := GetArea()
Local _aAreaSB1  := SB1->(GetArea())
Local _aAreaZAG  := FPA->(GetArea())
Local _aAreaZA0  := FP0->(GetArea())
Local _aAreaSD2  := SD2->(GetArea())
Local _aAreaSD1  := SD1->(GetArea())
Local _cTpMov    := ""
Local _cOS       := "" 			// Referente OS
Local _cServic   := "" 			// Referente OS
//cal   _dPreLib   := CtoD("") 		// Referente OS
Local _cLog      := ""
Local _cUserName := ""
Local _lExclui   := .f.
Local _lBemProj  := .T.
Local _lOS       := .F.
Local cCLI	     := ""
Local cLojCli	 := ""
Local cCLINOM    := ""
Local cCOD_MUN   := ""
Local cMUN       := ""
Local cEST	     := ""
Local dDTINI     := CtoD("")
Local dDTFIM     := CtoD("")
Local lMvLocBac	 := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integra็ใo com M๓dulo de Loca็๕es SIGALOC
Local lMVNG1LOC	 := SuperGetMv("MV_NG1LOC",.F.,.F.) //Integra็ใo com M๓dulo de Loca็๕es SIGALOC
//Local cTipoServ  := ''
Default _lDel := .F.

    SA1->(dbSetOrder(1))
    SHB->(dbSetOrder(1))
    FP1->(dbSetOrder(1))
    FP0->(dbSetOrder(1))

    SHB->(dbSeek( xFilial("SHB") + ST9->T9_CENTRAB )) 		// --> Para pegar o nome do centro de trabalho
    FP1->(dbSeek( FPA->FPA_FILIAL + FPA->FPA_PROJET + FPA->FPA_OBRA))
    FP0->(dbSeek( FPA->FPA_FILIAL + FPA->FPA_PROJET))
    SA1->(dbSeek( xFilial("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA ))


    cCLI	   := FP1->FP1_CLIORI
    cLojCli	   := FP1->FP1_LOJORI
    cCLINOM	   := FP1->FP1_NOMORI
    cCOD_MUN   := SA1->A1_COD_MUN
    cMUN	   := SA1->A1_MUN
    cEST	   := SA1->A1_EST
    dDTINI	   := FPA->FPA_DTINI
    dDTFIM     := FPA->FPA_DTENRE

    _cUserName := Upper(AllTrim(cUserName))


    If _lDel
        _lExclui := _lDel
    EndIf

    If !lMvLocBac
        If TQY->(dbSeek(xFilial("TQY") + _cStsNew ))
            _cTpMov := STR0107 + _cStsNew + "-" + AllTrim(TQY->TQY_DESTAT) //"Status: "
        EndIf
    Else
        If FQD->(dbSeek(xFilial("FQD") + _cStsNew ))
            _cTpMov := STR0107 + _cStsNew + "-" + AllTrim( If( !empty(FQD->FQD_STAREN), Posicione("SX5",1,xFilial("SX5")+"QY"+ FQD->FQD_STAREN,"X5_DESCRI"), STR0108) ) //"Status: "###"Minuta"
        EndIf
    EndIf

    If     IsInCallStack("LOCA013")  .And.  IsInCallStack("LOCA001")  .And.   IsInCallStack("LOCA01302")  .And.  IsInCallStack("LOCA01301")
        // --> Gerando contrato
        // Se for gera็ใo de contrato passa para status de contrato gerado!
        _cLog    := STR0109 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0110 + AllTrim(_cContr) + STR0111 + FPA->FPA_OBRA //"Bem "###" alocado no contrato "###" - Obra: "

    ElseIf IsInCallStack("LOCA013")  .And.  IsInCallStack("LOCA001")  .And. ! IsInCallStack("LOCA01302")  .And.  IsInCallStack("LOCA01301")
        // --> Ap๓s troca de bem na ZAG quando jแ existe AS
        // Se for gera็ใo de contrato e houver diferen็a entre DTQ e ZAG altera o bem antigo para disponํvel
        _cLog := STR0112 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0113 + AllTrim(_cContr) + STR0114 + FPA->FPA_OBRA //"Bem "###" disponํvel ap๓s atualizar contrato "###" - Obra: "

    ElseIf (IsInCallStack("LOCA001")  .And.  IsInCallStack("LOCA040")) .or. IsInCallStack("LOCA259XCN")
        // --> Cancelamento de AS
        // Cancelamento de AS retorna para disponํvel
        _cLog := STR0115 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0116 + AllTrim(_cContr) + STR0117 + STR0118 + FPA->FPA_OBRA //"Bem "###" disponํvel ap๓s As: "###" ser cancelada."###" - Obra: "

    ElseIf IsInCallStack("U_LOCC001Y")
        // --> Troca em lote
        If     _cStsNew == "10"
            _cLog := STR0119 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0120 + AllTrim(_cContr) + STR0121 + FPA->FPA_OBRA //"Bem "###" em contrato "###" - Obra: "
        ElseIf _cStsNew == "00"
            _cLog := STR0122 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0123 + AllTrim(_cContr) + STR0124 + FPA->FPA_OBRA //"Bem "###" disponํvel ap๓s troca em lote no contrato "###" - Obra: "
        EndIf

    ElseIf IsInCallStack("LOCA040")  .And.  IsInCallStack("LOCA040")
        // --> Troca de bem ๚nico
        If     _cStsNew == "10"
            _cLog := STR0125 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0126 + AllTrim(_cContr) + STR0127 + FPA->FPA_OBRA //"Bem "###" em contrato "###" Obra: "
        ElseIf _cStsNew == "00"
            _cLog := STR0128 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0129 + AllTrim(_cContr) + STR0130 + FPA->FPA_OBRA //"Bem "###" disponํvel ap๓s troca ๚nica no contrato "###" - Obra: "
        EndIf

    ElseIf IsInCallStack("U_SF2460I") .or. IsInCallStack("LOCM003")
        // --> Gera็ใo de nf de remessa
        _cLog    := STR0131 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0132 + _cDocto +"/"+_cSerie + STR0133 + AllTrim(_cContr) + STR0134 + FPA->FPA_OBRA //"Bem "###" remessado NF: "###" contrato "###" - Obra: "

    ElseIf IsInCallStack("U_SF2520E") .or. IsInCallStack("LOCM002")
        // --> Exclusใo de nf de remessa
        If     _cStsNew == "10"
            _cLog := STR0135 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0136 + _cDocto +"/"+_cSerie + STR0137 + AllTrim(_cContr) + STR0138 + FPA->FPA_OBRA //"Bem "###" em contrato ap๓s estorno remessa NF: "###" contrato "###" - Obra: "
        ElseIf _cStsNew == "00"
            _cLog := STR0139 + AllTrim(ST9->T9_CODBEM) + STR0140 + _cDocto +"/"+_cSerie //"Bem "###" disponivel ap๓s estornar envio ao parceiro da NF: "###
            _lBemProj  := .F.
            _lBemParca := .T.
            SA1->(dbSeek(xFilial("SA1") + SC6->(C6_CLI+C6_LOJA)))
            cCLI	   := SA1->A1_COD
            cLojCli	   := SA1->A1_LOJA
            cCLINOM	   := SA1->A1_NOME
            cCOD_MUN   := SA1->A1_COD_MUN
            cMUN	   := SA1->A1_MUN
            cEST	   := SA1->A1_EST
            dDTFIM     := dDataBase
        EndIf
    ElseIf IsInCallStack("U_GERNFRET") 		// --> Altera็ใo da data de solicita็ใo de retirada
        If ! _lExclui
            _cLog := STR0141 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0142 + AllTrim(_cContr) + STR0143 + FPA->FPA_OBRA //"Bem "###" com data de solicita็ใo preenchida no contrato "###" - Obra: "
        Else
            _cLog := STR0144 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0145 + AllTrim(_cContr) + STR0146 + FPA->FPA_OBRA //"Bem "###" com data de solicita็ใo estornada no contrato "###" - Obra: "
        EndIf

    ElseIf IsInCallStack("U_MT103FIM")  .or. IsInCallStack("LOCM008")		// Doc de entrada - GERNFRET
        If AllTrim( Str(_nOpc) ) $ "3;4" .And. AllTrim(_cContr) <> "PARCEIRO"
            _cLog := STR0147 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0148 + _cDocto +"/"+_cSerie + STR0149 + AllTrim(_cContr) + STR0150 + FPA->FPA_OBRA //"Bem "###" retornado NF: "###" contrato "###" - Obra: "
        ElseIf _nOpc == 5 .And. AllTrim(_cContr) <> "PARCEIRO"
            _cLog := STR0151 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0152 + _cDocto +"/"+_cSerie + STR0153 + AllTrim(_cContr) + STR0154 + FPA->FPA_OBRA //"Bem "###" entegue ap๓s estorno da NF: "###" contrato "###" - Obra: "
        ElseIf AllTrim( Str(_nOpc) ) $ "3;4" .And. AllTrim(_cContr) == "PARCEIRO"
            _cLog      := STR0155 + AllTrim(ST9->T9_CODBEM) + STR0156 + _cDocto +"/"+_cSerie //"Bem "###" retornado do parceiro NF: "
            _lBemProj  := .F.
            _lBemParca := .T.
            SA1->(dbSeek(xFilial("SA1") + SC6->(C6_CLI+C6_LOJA)))
            cCLI	   := SA1->A1_COD
            cLojCli	   := SA1->A1_LOJA
            cCLINOM	   := SA1->A1_NOME
            cCOD_MUN   := SA1->A1_COD_MUN
            cMUN	   := SA1->A1_MUN
            cEST	   := SA1->A1_EST
            dDTFIM     := dDataBase
        ElseIf _nOpc == 5 .And. AllTrim(_cContr) == "PARCEIRO"
            _cLog      := STR0157 + AllTrim(ST9->T9_CODBEM) + STR0158 + _cDocto +"/"+_cSerie //"Bem "###" em parceiro ap๓s estorno da NF: "
            _lBemProj  := .F.
            _lBemParca := .T.
            SA1->(dbSeek(xFilial("SA1") + SC6->(C6_CLI+C6_LOJA)))
            cCLI	   := SA1->A1_COD
            cLojCli	   := SA1->A1_LOJA
            cCLINOM	   := SA1->A1_NOME
            cCOD_MUN   := SA1->A1_COD_MUN
            cMUN	   := SA1->A1_MUN
            cEST	   := SA1->A1_EST
            dDTFIM     := dDataBase
        EndIf

    ElseIf IsInCallStack("U_M460FIM") 		// Pedido de venda para parceiros
        If _cStsNew == SuperGetMV("MV_LOCX270",.F.,"09")
            _cLog      := STR0159 + AllTrim(ST9->T9_CODBEM) + STR0160 + _cDocto +"/"+_cSerie //"Bem "###" enviado ao parceiro NF: "
            _lBemProj  := .F.
            _lBemParca := .T.
            SA1->(dbSeek(xFilial("SA1") + SC6->(C6_CLI+C6_LOJA)))
            cCLI	   := SA1->A1_COD
            cLojCli	   := SA1->A1_LOJA
            cCLINOM	   := SA1->A1_NOME
            cCOD_MUN   := SA1->A1_COD_MUN
            cMUN	   := SA1->A1_MUN
            cEST	   := SA1->A1_EST
            dDTINI	   := dDataBase
        EndIf

    ElseIf IsInCallStack("U_MNTA080H")
        If ! _lExclui
            _cLog := STR0161 + AllTrim(ST9->T9_CODBEM) + STR0162 //"Bem "###" incluido/alterado"
        Else
            _cLog := STR0163 + AllTrim(ST9->T9_CODBEM) + STR0164 //"Bem "###" Excluido"
        EndIf
        _lBemProj  := .F.
        _lBemParca := .F.
        _lOS       := .F.

    ElseIf IsInCallStack("U_MNTA2903")  .Or.  IsInCallStack("U_MNTA420P")
    //	_dPreLib   := M->TJ_XPRELIB
        _cServic   := M->TJ_SERVICO
        _cOS       := M->TJ_ORDEM
        _cLog      := STR0165 + AllTrim(ST9->T9_CODBEM) + STR0166 + _cOS //"Bem "###" em manuten็ใo na OS: "
        _lBemProj  := .F.
        _lBemParca := .F.
        If !Empty(_cContr)
            If AllTrim(_cContr) == "PARCEIRO"
                cCLI	 := FQ4->FQ4_CODCLI
                cLojCli  := FQ4->FQ4_LOJCLI
                cCLINOM  := FQ4->FQ4_NOMCLI
                cCOD_MUN := FQ4->FQ4_CODMUN
                cMUN	 := FQ4->FQ4_MUNIC
                cEST	 := FQ4->FQ4_EST
            EndIf
            _lOS         := .T.
        EndIf

    ElseIf IsInCallStack("U_MNTA400F")  .Or.  IsInCallStack("U_MNTA8801")
    //	_cTpMov    := "Ordem de Servi็o"
    //	_dPreLib   := STJ->TJ_XPRELIB
        _cServic   := STJ->TJ_SERVICO
        _cOS       := STJ->TJ_ORDEM
        If IsInCallStack("U_MNTA400F")
            _cLog  := STR0167 + AllTrim(ST9->T9_CODBEM) + STR0168 + _cOS //"Bem "###" ap๓s finaliza็ใo da OS: "
        Else
            _cLog  := STR0169 + AllTrim(ST9->T9_CODBEM) + STR0170 + _cOS //"Bem "###" ap๓s a reabertura da OS: "
        EndIf
        _lBemProj  := .F.
        _lBemParca := .F.

        If !Empty(_cContr)
            If AllTrim(_cContr) == "PARCEIRO"
                cCLI	 := FQ4->FQ4_CODCLI
                cLojCli  := FQ4->FQ4_LOJCLI
                cCLINOM  := FQ4->FQ4_NOMCLI
                cCOD_MUN := FQ4->FQ4_CODMUN
                cMUN	 := FQ4->FQ4_MUNIC
                cEST	 := FQ4->FQ4_EST
            EndIf
            _lOS   := .T.
        EndIf

    ElseIf IsInCallStack("U_LOCT039")
        _cLog := STR0171 + AllTrim(ST9->T9_CODBEM) + STR0172 //"Disponibilizacao/Retorno "###" incluido."
        _lBemProj  := .F.
        _lBemParca := .F.
        _lOS       := .F.

    ElseIf IsInCallStack("LOCA050") //.And. _cStsNew = "00"//Dennis - chamado 27401
        _lBemProj  := .F.
        _lBemParca := .F.
        _lOS       := .F.

    ElseIf IsInCallStack("U_SF1100E")
        // --> Gera็ใo de nf de remessa
        _cLog    := STR0173 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0174 + _cDocto +"/"+_cSerie + STR0175 + AllTrim(_cContr) + STR0176 + FPA->FPA_OBRA //"Bem "###" Cancelamento da NF de entrada: "###" contrato "###" - Obra: "
   
    ElseIf IsInCallStack("LOCA259ETR")  // Gestใo de Demanda Troca na Separa็ใo
        // --> Troca de bem ๚nico
        If _cStsNew == "00"
            _cLog := STR0128 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0129 + AllTrim(_cContr) + STR0130 + FPA->FPA_OBRA //"Bem "###" disponํvel ap๓s troca na separa็ใo no contrato "###" - Obra: "
        else 
            _cLog := STR0125 + FPA->FPA_SEQGRU + "/" + AllTrim(ST9->T9_CODBEM) + STR0126 + AllTrim(_cContr) + STR0127 + FPA->FPA_OBRA //"Bem "###" em contrato "###" Obra: "
        EndIf

    EndIf

    // Card 1367
    // Utilizar o cliente que estiver vindo da SC5, pois existem regras especํficas para o encontro do cliente
    // Frank Fuga em 19/12/23
    If IsInCallStack("U_SF2460I") .or. IsInCallStack("LOCM003") .or. IsInCallStack("LOCA010")
        SA1->(dbSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
        cCLI	   := SC5->C5_CLIENTE
        cLojCli	   := SC5->C5_LOJACLI
        cCLINOM	   := SA1->A1_NOME
        cCOD_MUN   := SA1->A1_COD_MUN
        cMUN	   := SA1->A1_MUN
        cEST	   := SA1->A1_EST
    EndIF

    _cLog := _cLog +" - "+ _cTpMov + " - " + _cUserName + " - " + FWTimeStamp(2,Date(),Time())
    _cSeq := GetSx8Num("FQ4","FQ4_SEQ")
    ConfirmSx8()

    FQ4->(RecLock("FQ4",.T.))
        FQ4->FQ4_FILIAL         := xFilial("FQ4")
        FQ4->FQ4_CODBEM         := ST9->T9_CODBEM
        FQ4->FQ4_NOME	        := ST9->T9_NOME
        FQ4->FQ4_STSOLD         := _cStsOld
        FQ4->FQ4_STATUS         := _cStsNew
        If !lMvLocBac
            FQ4->FQ4_DESTAT         := Posicione("TQY",1,xFilial("TQY")+_cStsNew,"TQY_DESTAT")
        Else
        // Pesquisar status na FQD antes de ir na SX5 - 14/03/2024 Rossana
            FQD->(DBSetOrder(2))
            If FQD->(dbSeek(xFilial("FQD") + _cStsNew ))
                FQ4->FQ4_DESTAT     := AllTrim( If( !empty(FQD->FQD_STAREN), Posicione("SX5",1,xFilial("SX5")+"QY"+ FQD->FQD_STAREN,"X5_DESCRI"), "Minuta") )
            EndIf
        EndIf

        FQ4->FQ4_CODFAM         := ST9->T9_CODFAMI
        FQ4->FQ4_TIPMOD         := ST9->T9_TIPMOD
        FQ4->FQ4_FABRIC         := ST9->T9_FABRICA
        // Alterado para usar o campo padrใo do ST9 - 27/09/23 Alexandre Circenis

        FQ4->FQ4_SUBLOC         := IF( ST9->T9_PROPRIE = '2', 'S','N')

        FQ4->FQ4_POSCON         := ST9->T9_POSCONT
        FQ4->FQ4_CENTRA         := ST9->T9_CENTRAB
        FQ4->FQ4_NOMTRA         := SHB->HB_NOME
        FQ4->FQ4_OS		        := _cOS
        FQ4->FQ4_SERVIC         := _cServic
    //	FQ4->FQ4_PRELIB         := _dPreLib
        FQ4->FQ4_DOCUME         := _cDocto
        FQ4->FQ4_SERIE          := _cSerie
        If _lBemProj .Or. _lBemParca .Or. _lOS
            FQ4->FQ4_CODCLI     := cCLI
            FQ4->FQ4_LOJCLI     := cLojCli
            FQ4->FQ4_NOMCLI     := cCLINOM
            FQ4->FQ4_CODMUN     := cCOD_MUN
            FQ4->FQ4_MUNIC      := cMUN
            FQ4->FQ4_EST	    := cEST
        EndIf
        If _lBemProj  .Or. _lOS
            FQ4->FQ4_PROJET     := _cContr
            If AllTrim(_cContr) <> "PARCEIRO"
                FQ4->FQ4_OBRA   := FPA->FPA_OBRA
                FQ4->FQ4_AS		:= FPA->FPA_AS
                FQ4->FQ4_PREDES := FPA->FPA_DTSCRT
                FQ4->FQ4_DTINI  := dDTINI
                FQ4->FQ4_DTFIM  := dDTFIM
                FQ4->FQ4_TPSERV := RetX3Combo("FPA_TIPOSE", FPA->FPA_TIPOSE)
                if Type("FQ4->FQ4_PRELIB") = 'D' // Quando torca o tipo do Campo
                    FQ4->FQ4_PRELIB := FPA->FPA_DTPRRT
                else
                // Rossana - DESERLOCA 3178 - ajuste para aparecer o ano com 2 posi็๕es na tela e nใo truncar
                    FQ4->FQ4_PRELIB := SubStr(Dtoc(FPA->FPA_DTPRRT),1,6)+SubStr(Dtoc(FPA->FPA_DTPRRT),9,2)
                Endif
            EndIf
        EndIf
        FQ4->FQ4_LOG	        := _cLog
        FQ4->FQ4_SEQ            := _cSeq
    FQ4->(MsUnLock())

    // Gravar o hist๓rico no manuten็ใo de ativos
    If lMvLocBac
        // Controle do X2_UNICO
        TPN->(dbSetOrder(1))
        While TPN->(dbSeek(xFilial("TPN")+FQ4->FQ4_CODBEM+dtos(dDataBase)+substr(time(),1,5)))
            Sleep(500)
        EndDo
        TPN->(RecLock("TPN",.T.))
        TPN->TPN_FILIAL := xFilial("TPN")
        TPN->TPN_CODBEM := FQ4->FQ4_CODBEM
        TPN->TPN_DTINIC := dDataBase
        TPN->TPN_HRINIC := time()
        TPN->TPN_CCUSTO := FPA->FPA_CUSTO
        TPN->TPN_CTRAB  := FQ4->FQ4_CENTRA
        TPN->TPN_UTILIZ := "U"
        TPN->TPN_POSCON := 0
        TPN->TPN_POSCO2 := 0
        TPN->TPN_OBSERV := FQ4->FQ4_DESTAT
        TPN->(MsUnlock())
    EndIF

    // Gravar o hist๓rico no gestใo de servi็os
    If lMVNG1LOC .and. lMvLocBac
        AA3->(dbSetOrder(1))
        If AA3->(dbSeek(xFilial("AA3")+FP0->FP0_CLI+FP0->FP0_LOJA+ST9->T9_CODESTO+ST9->T9_CODBEM))
            AAF->(dbSetOrder(1))
            AAF->(RecLock("AAF",.T.))
            AAF->AAF_FILIAL := xFilial("AAF")
            AAF->AAF_CODCLI := FP0->FP0_CLI
            AAF->AAF_LOJA   := FP0->FP0_LOJA
            AAF->AAF_CODPRO := AA3->AA3_CODPRO
            AAF->AAF_NUMSER := AA3->AA3_NUMSER
            AAF->AAF_DTINI  := dDataBase
            AAF->AAF_NSERAC := AA3->AA3_NUMSER
            AAF->AAF_PRODAC := AA3->AA3_CODPRO
            AAF->AAF_LOGINI := FQ4->FQ4_DESTAT
            AAF->(MsUnlock())
        EndIF
    EndIF

    IF EXISTBLOCK("LOCX21A")
        EXECBLOCK("LOCX21A",.T.,.T.,{})
    ENDIF

    RestArea( _aAreaSD1 )
    RestArea( _aAreaSD2 )
    RestArea( _aAreaZA0 )
    RestArea( _aAreaZAG )
    RestArea( _aAreaSB1 )
    RestArea( _aAreaOld )

Return

/*Chamada do MATA103*/
/*Dennis Calabrez - 14/10/21*/
Function LOCXITU22(cVar1,cVar2,aLinha,aItensped,cDocSF2,cCliente,cLoja,lCliente,cTipoNF,lPoder3)
Local lRet := .T.

    lRet := M103FILDV(@aLinha,@aItensped,cDocSF2,cCliente,cLoja,lCliente,@cTipoNF,@lPoder3,.F.)

Return lRet

/*Chamada do LOCA010*/
/*Dennis Calabrez - 14/10/21*/
Function LOCXITU23( cVar1, cVar2, _cNotax, _cSeriex)
Local lRet := .T.

    lRet := LOCA010Y(_cNotax, _cSeriex)

Return lRet


// Rotina para validar se pode ser alterado a moeda informada.
// Frank Zwarg Fuga em 22/10/21
Function LOCXITU24
Local _lRet := .T.
Local _cContrato := M->FP0_PROJET
Local _aArea := GetArea()

    FPA->(dbSetOrder(1))
    FPA->(dbSeek(xFilial("FPA")+_cContrato))
    While !FPA->(Eof()) .and. FPA->FPA_FILIAL+FPA->FPA_PROJET == xFilial("FPA")+_cContrato
        IF !empty(FPA->FPA_AS)
            _lRet := .F. // nใo permitir alterar a moeda se jแ houver a gera็ใo de contrato
            Exit
        EndIF
        FPA->(dbSkip())
    EndDo
    RestArea(_aArea)
Return _lRet

// Rotina para ajuste dos debitos tecnicos
// Frank Z Fuga em 04/04/2022
Function LOCXCONV(_nConv)
Local _cTexto

    /*
    1 - "SX3"
    2 - "SX3->X3_CAMPO"
    3 - "SX3->X3_USADO"
    4 - "SX3->X3_ORDEM"
    */
    If _nConv == 1
        _cTexto := "SX3"
    ElseIf _nConv == 2
        _cTexto := "SX3->X3_CAMPO"
    ElseIf _nConv == 3
        _cTexto := "SX3->X3_USADO"
    ElseIf _nConv == 4
        _cTexto := "SX3->X3_ORDEM"
    ElseIf _nConv == 5
        _cTexto := "X3_TIPO"
    EndIF
Return _cTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCXITU25
@description	Gatilho do campo FQ7_TPROMA para atualizar os campos
                FQ7_LCCDES e FQ7_LCLDES.
                Quando o parโmetro estiver ligado (.T.) o cliente destino
				informado na aba conjunto transportador serแ o utilizado
				como cliente da nota fiscal de remessa, gerada a partir
				da rotina de romaneio.
@author			Jos้ Eulแlio
@since     		06/04/2022
/*/
//-------------------------------------------------------------------
Function LOCXITU25(cCampo)
Local lLOCX304	:= SuperGetMV("MV_LOCX304",.F.,.F.)
Local cRet		:= ""
Local nLcCDes 	:= 0
Local nLcLDes 	:= 0
Local nCliOri 	:= 0
Local nLojOri 	:= 0

    //caso o parโmetro esteja ligao e seja viagem de Ida
    If lLOCX304 .And. &(ReadVar()) == "0"
        //Atuliza cliente
        If cCampo == "FQ7_LCCDES"
            nCliOri := ASCAN(odlgobr:AHEADER,{|X|ALLTRIM(X[2])=="FP1_CLIORI"  })
            If !(Empty(odlgobr:aCols[odlgobr:nAt][nCliOri]))
                cRet	:= odlgobr:aCols[odlgobr:nAt][nCliOri]
            Else
                cRet	:= FP0->FP0_CLI
            EndIf
        //Atuliza Loja
        ElseIf cCampo == "FQ7_LCLDES"
            nLojOri := ASCAN(odlgobr:AHEADER,{|X|ALLTRIM(X[2])=="FP1_LOJORI"  })
            If !(Empty(odlgobr:aCols[odlgobr:nAt][nLojOri]))
                cRet	:= odlgobr:aCols[odlgobr:nAt][nLojOri]
            Else
                cRet	:= FP0->FP0_LOJA
            EndIf
        EndIf
    Else
        //caso nใo tenha o parโmetro ativado ou nใo seja viagem de ida, mant้m o valor
        //Atuliza cliente
        If cCampo == "FQ7_LCCDES"
            nLcCDes := ASCAN(odlgcnp:AHEADER,{|X|ALLTRIM(X[2])=="FQ7_LCCDES"  })
            cRet	:= odlgcnp:aCols[odlgcnp:nAt][nLcCDes]
        //Atualiza Loja
        ElseIf cCampo == "FQ7_LCLDES"
            nLcLDes := ASCAN(odlgcnp:AHEADER,{|X|ALLTRIM(X[2])=="FQ7_LCLDES"  })
            cRet	:= odlgcnp:aCols[odlgcnp:nAt][nLcLDes]
        EndIf
    EndIf

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCXITU26
@description	Retorna se o produto o bem ou produto ้ acess๓rio SIGALOC
@author			Jos้ Eulแlio
@since     		06/04/2022
/*/
//-------------------------------------------------------------------
Function LOCXITU26(cProd)
Local lRet      := .F.
Local cLocx014 	:= SUPERGETMV("MV_LOCX014",.F.,"") // PRODUTO ACESSORIO
Local CGRPAND	:= ""
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaST9	:= ST9->(GetArea())
Local aArea	    := GetArea()

Default cProd   := ""

    //Default cBem    := "" //Caso seja necessแrio buscar pelo Bem descomentar o trecho abaixo e enviar o segundo parโmetro

    //se nใo indicou produto e indicou bem, busca o produto (T9_CODESTO)
    /*If Empty(cProd) .And. !Empty(cBem)
        ST9->(DbSetOrder(1))
        If ST9->(DbSeek(xFilial("ST9") + cBem))
            cProd := ST9->T9_CODESTO
        EndIf
    EndIf*/

    //retorna produto que estแ configurado com acess๓rio
    IF SBM->(FIELDPOS("BM_XACESS")) > 0
        CGRPAND := LOCA00189()
    ELSE
        CGRPAND := cLocx014
    ENDIF

    //verifica se o produto estแ entre os acess๓rios
    SB1->(DbSetOrder(1))
    If SB1->(DbSeek(xFilial("SB1") + cProd))
        lRet := AllTrim(SB1->B1_GRUPO) $ CGRPAND
    EndIf

    RestArea(aAreaSB1)
    RestArea(aAreaST9)
    RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xGeraInd
@description	Gera Historico de Indice na CN6 (FUNวรO DIDมTICA PARA GERAR CENARIOS DE TESTE)
@author			Jos้ Eulแlio
@since     		03/05/2023
/*/
//-------------------------------------------------------------------
/*
User Function xGeraInd()
Local cChavCN7  := ""
Local nIndCN7   := 1
Local nValMes   := 0
Local dDataAux  := StoD("")
Local aAreaCN6  := CN6->(GetArea())
Local aAreaCN7  := CN7->(GetArea())

If MsgYesNo("Deseja gerar historico do indice?")
    CN6->(DbSetOrder(1)) //CN6_FILIAL+CN6_CODIGO
    While !(CN6->(Eof()))
        nValMes := 0
        If CN6->CN6_TIPO == "1"
            nIndCN7     := 1 //CN7_FILIAL+CN7_CODIGO+DTOS(CN7_DATA)
            cChavCN7    := "20220502"
            dDataAux    := StoD(cChavCN7)
        Else
            nIndCN7 := 2 // CN7_FILIAL+CN7_CODIGO+CN7_COMPET
            cChavCN7    := "07/2022"
            dDataAux    := StoD("20220701")
        EndIf
        CN7->(DbSetOrder(nIndCN7))
        //se ja rodou, pula fora
        //If !CN7->(DbSeek(CN6->CN6_FILIAL + CN6->CN6_CODIGO + cChavCN7))
        If CN6->CN6_TIPO == "1" .And. CN7->(DbSeek(CN6->CN6_FILIAL + CN6->CN6_CODIGO + cChavCN7))
            While dDataAux < dDataBase
                nValMes := Month(dDataAux) + (Month(dDataAux) / 100)
                If CN6->CN6_TIPO == "1"
                    If CN7->(DbSeek(CN6->CN6_FILIAL + CN6->CN6_CODIGO + DtoS(dDataAux)))
                        RecLock("CN7",.F.)
                    Else
                        RecLock("CN7",.T.)
                    EndIf
                        nValMes := Month(dDataAux) + (Day(dDataAux) / 100)
                        CN7->CN7_FILIAL := CN6->CN6_FILIAL
                        CN7->CN7_CODIGO := CN6->CN6_CODIGO
                        CN7->CN7_DATA   := dDataAux
                        CN7->CN7_VLREAL := nValMes
                        CN7->CN7_TPPROJ := "1"
                    CN7->(MsUnLock())
                Else
                    RecLock("CN7",.T.)
                        CN7->CN7_FILIAL := CN6->CN6_FILIAL
                        CN7->CN7_CODIGO := CN6->CN6_CODIGO
                        CN7->CN7_COMPET := StrZero(Month(dDataAux),2,0) + "/" + cValToChar(Year(dDataAux))
                        CN7->CN7_VLREAL := nValMes
                        CN7->CN7_TPPROJ := "1"
                    CN7->(MsUnLock())
                    dDataAux := LastDate(dDataAux)
                EndIf
                dDataAux := dDataAux + 1
            EndDo
        EndIf
        CN6->(DbSkip())
    EndDo
EndIf

RestArea(aAreaCN6)
RestArea(aAreaCN7)

Return
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ValIndice
@description	Retorna valor do indice acumulado
@author			Jos้ Eulแlio
@since     		04/05/2023
/*/
//-------------------------------------------------------------------
Static Function ValIndice(cIndReaj,dDtNiver)
Local cChave    := ""
Local nRet      := 0
Local nDivMedia:= 0
Local nIndCN7   := 0
Local aAreaCN6  := CN6->(GetArea())
Local aAreaCN7  := CN7->(GetArea())

Default cIndReaj := ""
Default dDtNiver := StoD("")

    CN6->(DbSetOrder(1)) //CN6_FILIAL+CN6_CODIGO

    //posiciona no ํndice
    If CN6->(DbSeek(xFilial("CN6") + cIndReaj))

        //guarda chave para localizar hist๓rico
        cChave := CN6->CN6_FILIAL + CN6->CN6_CODIGO
        //retorna um ano a partir da data de aniversแrio
        dDataAux    := MonthSub(dDtNiver,12) + 1

        //monta chave de acordo com o tipo de indice 1=diario , 2=mensal
        If CN6->CN6_TIPO == "1"
            nIndCN7     := 1 //CN7_FILIAL+CN7_CODIGO+DTOS(CN7_DATA)
            cChavCN7    := DtoS(dDataAux)
        Else
            nIndCN7     := 2 // CN7_FILIAL+CN7_CODIGO+CN7_COMPET
            cChavCN7    := StrZero(Month(dDataAux),2,0) + "/" + cValToChar(Year(dDataAux))
        EndIf

        //roda o historico de indices
        CN7->(DbSetOrder(nIndCN7))
        While dDataAux <= dDtNiver
            If CN7->(DbSeek(CN6->CN6_FILIAL + CN6->CN6_CODIGO + cChavCN7))
                //incrementa o divisor
                nDivMedia++
                //soma total para tirar a m้dia, posteriormente
                nRet += CN7->CN7_VLREAL
            EndIf
            //incrementa data
            If CN6->CN6_TIPO == "1"
                dDataAux    := dDataAux + 1
                cChavCN7    := DtoS(dDataAux)
            Else
                dDataAux    := MonthSum(dDataAux,1)
                cChavCN7    := StrZero(Month(dDataAux),2,0) + "/" + cValToChar(Year(dDataAux))
            EndIf
        EndDo

        //pega media dos indices acumulados
        nRet    := nRet / nDivMedia

    EndIf

    RestArea(aAreaCN6)
    RestArea(aAreaCN7)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetX3Combo
Retorna descricao do X3_CBOX

@param cCampo, character, Campo para ser pesquisado no SX3
@param cConteudo, character, Conteudo do campo pesquisado
@return cCaption, character, Descricao conforme X3_CBOX
@author  Eduardo Gomes Junior
@version P12
@since   23/09/2015
/*/
//-------------------------------------------------------------------
Static Function RetX3Combo(cCampo, cConteudo)

Local cCaption	:= ""
Local aSx3Box   	:= RetSx3Box(Posicione("SX3", 2, cCampo, "X3CBox()"),,, 1)
Local nPos			:= AScan(aSx3Box, {|aBox| aBox[2] == cConteudo})

    If	nPos > 0
        cCaption := AllTrim(aSx3Box[nPos][3])
    Endif

Return(cCaption)

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCXITU27
@description	Valida a AS na STZ
@author			Circenis
@since     		12/04/2024
/*/
//-------------------------------------------------------------------
Function LOCXITU27(cAS, cBem)
Local lRet      := .T.
Local aAreaFQ5	:= FQ5->(GetArea())
Local aArea	    := GetArea()

if !Empty(cBem)

    if !Empty(cAS)
        dbSelectArea("FQ5")
        dbSetOrder(9)
        if dbSeek(xFilial("FQ5")+cAS)

            if FQ5->FQ5_GUINDA <> cBem
                Help( ,, 'STJ_ASXFQ5',, STR0179+ FQ5->FQ5_GUINDA+STR0178+cBem, 1, 0 ) //". Informe uma AS que esteja relacionada com o Bem " //'A AS informada estแ relacionada o Bem '
                lRet := .F.
            endif

        else
           Help( ,, 'STJ_AS1',, STR0180, 1, 0 ) //'AS nใo encontrada, informe uma AS valida!'
            lRet := .F.

        endif
    endif
else
    Help( ,, 'STJ_AS2',, STR0181, 1, 0 ) //'S๓ informar a AS ap๓s informar o codigo do Bem.'
    lRet := .F.
endif

RestArea(aAreaFQ5)
RestArea(aArea)

Return lRet
