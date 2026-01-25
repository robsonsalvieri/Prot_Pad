#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "totvs.ch"
#Include "ap5mail.ch"
#include "TBICONN.CH"
#Include "Protheus.ch"

/*/LOCM008.PRW
ITUP Business - TOTVS RENTAL
author Frank Zwarg Fuga
since 21/03/2023
history 03/12/2020, Frank Zwarg Fuga, Fonte produtizado.
Este fonte antes era representado pelo ponto de entrada MT103FIM
Finalização do documento de entrada
/*/

Function LOCM008(nVar,nOpc)
Local aAreaOld := GetArea()
Local aAreaZAG := FPA->(GetArea())
Local aAreaSD1 := SD1->(GetArea())
Local aAreaTQY := TQY->(GetArea())
Local aAreaST9 := ST9->(GetArea())
Local aAreaZLF := FPN->(GetArea())
Local lEstCla  := .F.
Local cQuery   := ""
Local cSttCtr  := ""
Local lTemZUC  := .F. // Frank 19/10/20
Local nEnv            // Frank 19/10/20
Local nRet            // Frank 19/10/20
Local nRegX
Local lDel     := .F.
Local nReg
Local cProjX
Local lMarcacao
Local lLOCX278 := getmv("MV_LOCX278",,.F.)
Local lLOCX022 := SuperGetMV("MV_LOCX022",,.F.)
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local lMX103STS := ExistBlock("MX103STS")
Local lType := type("_nZuc")=="N"
Local cLOCX275 := SuperGetMV("MV_LOCX275",,"20")
//Local cQryPesq := ""
Local aAreaTmp
Local cProjx2
Local cProdx
Local cGruax
Local dDatax
Local lExiste := .F.

private CGRPAND	:= SUPERGETMV("MV_LOCX014",.F.,"" )  // FRANK 12/08/20
private _nOpc  := nVar // compatibilização para o funcionamento do locxitu21

    if nOpc == 0 // Tela de Nota entrada cancelada
        Return .T. // Se nOpc for igual a 1 tela aprovada
    endif

    // DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da geração do título provisório pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
            lLOCX278 := .T.
        Else
            lLOCX278 := .F.
        EndIf
    EndIf

    IF SBM->(FIELDPOS("BM_XACESS")) > 0
        CGRPAND := LOCA00189()
    ELSE
        CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
    ENDIF

    If Type("_lErroNf") == "L"
        _lErroNf := .F. // Frank - 04/11/20 - controle do erro na geracao da nota fiscal de entrada usado no A103devol
    EndIf

    If AtIsRotina("A140ESTCLA")
        lEstCla := .T.					// Estorno de Classificacao
    EndIf

    cQuery := "SELECT DISTINCT SD1.R_E_C_N_O_ SD1RECNO, "
    cQuery += "ZAG.R_E_C_N_O_ FPARECNO, "
    cQuery += "D1_FILIAL, D1_DOC, D1_SERIE, D1_EMISSAO, "
    cQuery += "D1_QUANT, D1_ITEM, D1_NFORI, D1_SERIORI, D1_ITEMORI "
    cQuery += "FROM " + RetSqlName("SD1") + " SD1 "
    cQuery += "INNER JOIN " + RetSqlName("SD2") + " SD2 "
    cQuery += "ON D2_FILIAL = D1_FILIAL "
    cQuery += "AND D2_DOC = D1_NFORI "
    cQuery += "AND D2_SERIE = D1_SERIORI "
    cQuery += "AND D2_ITEM = D1_ITEMORI "
    cQuery += "AND SD2.D_E_L_E_T_ = '' "
    if !lMvLocBac 
    else
        cQuery += "INNER JOIN "+RETSQLNAME("FPZ")+" FPZ (NOLOCK) "
		cQuery += "ON FPZ.FPZ_FILIAL = D2_FILIAL "
        cQuery += "AND FPZ.FPZ_PEDVEN =  D2_PEDIDO "
        cQuery += "AND FPZ.FPZ_ITEM = D2_ITEMPV "
        cQuery += "AND FPZ.D_E_L_E_T_ = ' ' "
        cQuery += "INNER JOIN "+RETSQLNAME("FPY")+" FPY (NOLOCK) "
		cQuery += "ON FPY.FPY_FILIAL = FPZ.FPZ_FILIAL "
        cQuery += "AND FPY.FPY_PEDVEN = FPZ.FPZ_PEDVEN "
        cQuery += "AND FPY.FPY_TIPFAT = 'R' "
        cQuery += "AND FPY.D_E_L_E_T_ = ' ' AND FPY.FPY_STATUS <> '2' "

    endif
    cQuery += "INNER JOIN " + RetSqlName("FPA") + " ZAG "
    cQuery += "ON FPA_FILREM = D2_FILIAL "
    cQuery += "AND FPA_NFREM = D2_DOC "
    cQuery += "AND FPA_SERREM = D2_SERIE "
    if !lMvLocBac 
    else
       cQuery += "AND FPA_AS     = FPZ_AS "
    endif
    cQuery += "AND FPA_DNFREM = D2_EMISSAO "
    cQuery += "AND ZAG.D_E_L_E_T_ = '' "
    cQuery += "INNER JOIN " + RetSqlName("FP0") + " ZA0 "
    cQuery += "ON  FP0_FILIAL = FPA_FILIAL "
    cQuery += "AND FP0_PROJET = FPA_PROJET "
    cQuery += "AND ZA0.D_E_L_E_T_ = '' "
    cQuery += "LEFT  JOIN " + RetSqlName("ST9") + " ST9 "
    cQuery += "ON T9_CODBEM = FPA_GRUA "
    cQuery += "AND ST9.D_E_L_E_T_ = '' "
    cQuery += "WHERE SD1.D1_FILIAL = ? "
    cQuery += "AND SD1.D1_DOC = ? "
    cQuery += "AND SD1.D1_SERIE = ? "
    cQuery += "AND SD1.D1_FORNECE = ? "
    cQuery += "AND SD1.D1_LOJA = ? "
    cQuery += "AND SD1.D1_EMISSAO = ? "
    cQuery += "AND SD1.D_E_L_E_T_ = '' "
    If Select("TRBFPA") > 0
        TRBFPA->(dbCloseArea())
    EndIf
    cQuery := CHANGEQUERY(cQuery)
    aBindParam := {SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, DtoS(SF1->F1_EMISSAO) }
	MPSysOpenQuery(cQuery,"TRBFPA",,,aBindParam)

    If TRBFPA->(!Eof())

        dbSelectArea("FPA")
        dbSelectArea("SD1")
        dbSelectArea("TQY")
        dbSelectArea("ST9")
        dbSelectArea("FPN")

        Do Case
        Case nVar == 3

            // Gravacao do codigo do romaneio
            If FWIsInCallStack("LOC05102") .or. FWIsInCallStack("LOCA029")
                SF1->(RecLock("SF1",.F.))
                SF1->F1_IT_ROMA := FQ2->FQ2_NUM 	// cRomaX
                SF1->(MsUnlock())
            EndIF

            cProjX := ""

            While TRBFPA->(!Eof())
                FPA->(dbGoTo(TRBFPA->FPARECNO))
                SD1->(dbGoTo(TRBFPA->SD1RECNO))

                cProjX := FPA->FPA_PROJET

                lMarcacao := .F. // indica se temos que gerar a FQZ no campo pv com X para não processar na emissão do faturamento automatico
                                // isto tem influencia para nao calcular a pro-rata duas vezes.

                If FPA->(RecLock("FPA",.F.))

                    // Verificar a quantidade que foi enviado x a quantidade retornada.
                    // Só armazenar a nota se for a ultima entrada, ou seja, se as quantidades forem iguais.
                    // Frank 19/10/20
                    FP0->(dbSetOrder(1))
                    FP0->(FPA->FPA_FILIAL+FPA->FPA_PROJET)

                    If lType // Variavel criada na rotina LOC05102.prw - frank 02/11/20
                        If _nZuc > 0
                            lTemZUC := .T.
                        Else
                            lTemZUC := .F.
                        EndIf
                    Else
                        lTemZUC := .F.
                    EndIf

                    // Tratamento dos titulos provisorios, deletar ao gerar a nota de devolução
                    // Frank em 26/20/2021
                    If lLOCX278 //getmv("MV_LOCX278",,.F.)

                        // Deleta os títulos provisórios
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
                        EndIf*/
                    EndIF

                    If FP0->FP0_TIPOSE == "L" .and. lTemZUC
                        nEnv := 0
                        If !empty(FPA->FPA_NFREM)
                            SC6->(dbSetOrder(4))
                            SC6->(dbSeek(FPA->FPA_FILREM+FPA->FPA_NFREM+FPA->FPA_SERREM))
                            While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NOTA+C6_SERIE) == FPA->FPA_FILREM+FPA->FPA_NFREM+FPA->FPA_SERREM
                                If alltrim(SC6->C6_ITEM) == alltrim(FPA->FPA_ITEREM)
                                    nEnv := SC6->C6_QTDVEN
                                    Exit
                                EndIF
                                SC6->(dbSkip())
                            EndDo
                        EndIf

                        nRet := 0

                        // Frank 06/06/25
                        FQ3->(dbSetOrder(3))
                        If FQ3->(dbSeek(xfilial("FQ3")+FPA->FPA_AS))
                            While !FQ3->(Eof()) .and. FQ3->(FQ3_FILIAL+FQ3_AS) == xFilial("FQ3")+FPA->FPA_AS
                                If FQ3->FQ3_VIAGEM == FPA->FPA_VIAGEM .and. FQ3->FQ3_NUM == SF1->F1_IT_ROMA
                                    FQ3->(Reclock("FQ3",.F.))
                                    FQ3->FQ3_NFRET  := SD1->D1_DOC
                                    FQ3->FQ3_SERRET := SD1->D1_SERIE
                                    FQ3->FQ3_FORNE  := SD1->D1_FORNECE
                                    FQ3->FQ3_LOJF   := SD1->D1_LOJA
                                    FQ3->(MsUnlock())
                                EndIf
                                FQ3->(dbSkip())
                            EndDo
                        EndIf

                        If FPA->FPA_QUANT == 0 .or. FPA->FPA_QUANT - SD1->D1_QUANT == 0 //nRet >= nEnv
                            FPA->FPA_NFRET  := SD1->D1_DOC
                            FPA->FPA_SERRET := SD1->D1_SERIE
                            FPA->FPA_DNFRET := SD1->D1_EMISSAO
                            FPA->FPA_ITERET := SD1->D1_ITEM
                            If Empty(FPA->FPA_DTPRRT)
                                FPA->FPA_DTPRRT	:= SD1->D1_EMISSAO
                            EndIf
                            If Empty(FPA->FPA_DTSCRT)
                                FPA->FPA_DTSCRT	:= FPA->FPA_DTPRRT
                            EndIf

                            // Uso do campo FPA_CONFIG
                            // No momento do estorno se for a nota informada neste campo, não devemos
                            // levar em consideração a quantidade
                            FPA->FPA_CONFIG := SD1->D1_DOC+SD1->D1_SERIE
                            lMarcacao := .T. // indica se temos que gerar a FQZ no campo pv com X para não processar na emissão do faturamento automatico
                                              // isto tem influencia para nao calcular a pro-rata duas vezes.
                        EndIF

                        // para efeito da cobranca diminuir a quantidade
                        If FPA->FPA_QUANT - SD1->D1_QUANT > 0
                            FPA->FPA_QUANT  := FPA->FPA_QUANT - SD1->D1_QUANT
                            FPA->FPA_VLBRUT := FPA->FPA_PRCUNI * FPA->FPA_QUANT
                            If FPA->(FieldPos("FPA_PACRES")) > 0                                                                        
                                 FPA->FPA_ACRESC := (FPA->FPA_QUANT*FPA->FPA_PRCUNI) * FPA->FPA_PACRES
                            EndIf
                            FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC)))
                        EndIF

                    Else
                        If FPA->FPA_QUANT == 0 .or. FPA->FPA_QUANT - SD1->D1_QUANT == 0
                            FPA->FPA_NFRET  := SD1->D1_DOC
                            FPA->FPA_SERRET := SD1->D1_SERIE
                            FPA->FPA_DNFRET := SD1->D1_EMISSAO
                            FPA->FPA_ITERET := SD1->D1_ITEM
                            If Empty(FPA->FPA_DTPRRT)
                                FPA->FPA_DTPRRT	:= SD1->D1_EMISSAO
                            EndIf
                            If Empty(FPA->FPA_DTSCRT)
                                FPA->FPA_DTSCRT	:= FPA->FPA_DTPRRT
                            EndIf

                            // Uso do campo FPA_CONFIG
                            // No momento do estorno se for a nota informada neste campo, não devemos
                            // levar em consideração a quantidade
                            FPA->FPA_CONFIG := SD1->D1_DOC+SD1->D1_SERIE
                            lMarcacao := .T. // indica se temos que gerar a FQZ no campo pv com X para não processar na emissão do faturamento automatico
                                            // isto tem influencia para nao calcular a pro-rata duas vezes.
                        EndIf
                        // para efeito da cobranca diminuir a quantidade
                        If FPA->FPA_QUANT - SD1->D1_QUANT > 0
                            FPA->FPA_QUANT  := FPA->FPA_QUANT - SD1->D1_QUANT
                            FPA->FPA_VLBRUT := FPA->FPA_PRCUNI * FPA->FPA_QUANT
                            If FPA->(FieldPos("FPA_PACRES")) > 0                                                                        
                                 FPA->FPA_ACRESC := (FPA->FPA_QUANT*FPA->FPA_PRCUNI) * FPA->FPA_PACRES
                            EndIf
                            FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC)))
                        EndIF
                    EndIf
                    FPA->(MsUnLock())
                EndIf

                // Registrar o log das notas de entradas x orçamentos
                // Frank Zwarg Fuga em 08/09/2020
                // Este registro é importante para quando houver devolução parcial
                If lLOCX022 //SuperGetMV("MV_LOCX022",,.F.)
                    ITLOGFQZ(SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_ITEM, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_EMISSAO, SD1->D1_COD, SD1->D1_QUANT, FPA->FPA_FILIAL, FPA->FPA_AS, nVar, FPA->FPA_PROJET, FPA->FPA_OBRA,lMarcacao)
                EndIf

                // Registrar as AS que fazem parte da nota para indicar no loca011 que a mesma foi gerada
                // Frank em 27/06/23. O array aAsgrv é private e gerado na rotina LOCA011.
                If FWIsInCallStack("LOCA011") .OR. FWIsInCallStack("LOCA01101")   // MI não passa pelo LOCA011    
                    if valtype(aAsgrv) == "A"
                        aadd(aAsgrv,FPA->FPA_AS)
                    EndIf
                EndIF

                If lTemZUC // Tem romaneio
                    cSttCtr := "60"
                Else
                    cSttCtr := "50"
                EndIF

                If lMX103STS
				    cSttCtr := Execblock("MX103STS",.T.,.T.,{nVar,cSttCtr})
			    EndIf

                If !Empty(FPA->FPA_GRUA) .and. RetStatus(cSttCtr)
                    ST9->(dbSetOrder(1))	// T9_FILIAL + T9_CODBEM
                    If ST9->(dbSeek( xFilial("ST9") + FPA->FPA_GRUA ))
                        If !empty(ST9->T9_STATUS)
                            If !lMvLocBac /*/
                                LOCXITU21(ST9->T9_STATUS,TQY->TQY_STATUS,FPA->FPA_PROJET,FPA->FPA_NFRET,FPA->FPA_SERRET)
                                If ST9->(RecLock("ST9",.F.))
                                    ST9->T9_STATUS := TQY->TQY_STATUS
                                    ST9->(MsUnLock())
                                EndIf /*/
                            else
                            // verifica se bem não está em outro contrato // Rossana - DSERLOCA 3414 - 08/07/24

                                // Frank 06/06/25
                                aAreaTmp := FPA->(GetArea())
                                cProjx2 := FPA->FPA_PROJET
                                cProdx := FPA->FPA_PRODUT
                                cGruax := FPA->FPA_GRUA
                                dDatax := FPA->FPA_DTINI
                                FPA->(dbSetOrder(5))
                                lExiste := .F.
                                If FPA->(dbSeek(xFilial("FPA")+cProjx2+cGruax))
                                    While !FPA->(Eof()) .and. FPA->(FPA_FILIAL+FPA_PROJET+FPA_GRUA) == xFilial("FPA")+cProjx2+cGruax
                                        If FPA->FPA_PRODUT == cProdx .and. FPA->FPA_DTINI > dDatax .and. empty(FPA->FPA_NFRET)
                                            lExiste := .T.
                                            exit
                                        EndIf
                                        FPA->(dbSkip())
                                    EndDo
                                EndIf
                                FPA->(RestArea(aAreaTmp))
                               
                                If !lExiste
                                    LOCXITU21(ST9->T9_STATUS,FQD->FQD_STATQY,FPA->FPA_PROJET,FPA->FPA_NFRET,FPA->FPA_SERRET)
                                    If ST9->(RecLock("ST9",.F.))
                                        ST9->T9_STATUS := FQD->FQD_STATQY
                                        ST9->(MsUnLock())
                                    EndIf
                                Else
                                   If FQ4->(dbSeek( xFilial("FQ4") + FPA->FPA_GRUA ))
                                        While !FQ4->(Eof()) .and. FQ4->FQ4_FILIAL+FQ4->FQ4_CODBEM==xFilial("FQ4") + FPA->FPA_GRUA
                                            If FQ4->FQ4_STATUS == "L3" .and. FQ4->FQ4_PROJET==FPA->FPA_PROJET
                                               If !SF1->(dbSeek( xFilial("SF1") + FQ4->FQ4_DOCUME + FQ4->FQ4_SERIE ))
                                                  IF RECLOCK("FQ4",.F.)
                                                     FQ4->FQ4_DOCUME := FPA->FPA_NFRET
                                                     FQ4->FQ4_SERIE  := FPA->FPA_SERRET
                                                     FQ4->(MsUnLock())
                                                  EndIf
                                               EndIf
                                            EndIf
                                            FQ4->(DbSkip())
                                        End
                                   EndIf
                                EndIf
                            EndIF
                        EndIF
                    EndIf
                EndIf

                TRBFPA->(dbSkip())
            EndDo

            // Tratamento dos titulos provisorios - voltar com os PR
            If lLOCX278 .and. !empty(cProjX)
                FP0->(dbSetOrder(1))
                FP0->(dbSeek(xFilial("FP0")+cProjX))
                nRegX := FPA->(Recno())
                loca01318() // criacao do titulo provisorio
                FPA->(dbGoto(nRegX))
            EndIF

        Case nVar == 5 .and. !lEstCla
            // Tratamento do status dos bens - Frank 12/06/2023
            if Select("TRABA") > 0
                TRABA->(dbCloseArea())
            endif

            cQuery := "SELECT D1_ITEM FROM "+RetSqlName("SD1") +" SD1 "
            cQuery += " WHERE D1_FILIAL='"+xFilial("SD1")+"'"
            cQuery += " AND D1_DOC= ? "
            cQuery += " AND D1_SERIE= ? "
            cQuery += " AND D1_FORNECE= ? "
            cQuery += " AND D1_LOJA= ? "
            cQuery := CHANGEQUERY(cQuery)
            aBindParam := {SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA}
			MPSysOpenQuery(cQuery,"TRABA",,,aBindParam)
            //cQuery += " and SD1.D_E_L_E_T_ = ' '" neste momento a SD1 já foi deletada só a SF1 que ainda não.
            //TcQuery cQuery New Alias "TRABA"
            While !TRABA->(Eof())
                FQZ->(dbSetOrder(1))
                If FQZ->(dbSeek(xFilial("FQZ")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+TRABA->D1_ITEM))
                    FPA->(dbSetOrder(6))
                    If FPA->(dbSeek(xFilial("FPA")+FQZ->FQZ_PROJET+FQZ->FQZ_AS))
                        SB1->(DBSETORDER(1))
                        SB1->(DBSEEK(XFILIAL("SB1")+FPA->FPA_PRODUT))
                        IF ! ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND) .OR. !EMPTY(FPA->FPA_GRUA)
                            If !Empty(FPA->FPA_GRUA) .and. RetStatus(cLOCX275)
                                ST9->(DBSETORDER(1))
                                IF ST9->(DBSEEK(XFILIAL("ST9")+FPA->FPA_GRUA))

                                    If lMvLocBac
                                        cLOCX275 := FQD->FQD_STATQY
                                    EndIF

                                    LOCXITU21(ST9->T9_STATUS,cLOCX275,FPA->FPA_PROJET,SF1->F1_DOC,SF1->F1_SERIE)
                                    IF RECLOCK("ST9",.F.)
                                        If lMvLocBac
                                            ST9->T9_STATUS := cLOCX275 
                                        EndIF
                                        ST9->(MSUNLOCK())
                                    ENDIF
                                EndIf
                            EndIF
                        EndIf
                    EndIF
                EndIf
                TRABA->(dbSkip())
            EndDo
            TRABA->(dbCloseArea())

            While TRBFPA->(!Eof())
                FPA->(dbGoTo(TRBFPA->FPARECNO))
                SD1->(dbGoTo(TRBFPA->SD1RECNO))

                // Frank em 22/07/22 - controle para ver se usar o conceito de AS
                lTemZUC := .F.
                lDel := .F.
                nReg := 0

                // Frank 06/06/25
                FP0->(dbSetOrder(1))
                FP0->(dbSeek(xfilial("FP0")+FPA->FPA_PROJET))

                FQ3->(dbSetOrder(3))
                If FQ3->(dbSeek(xfilial("FQ3")+FPA->FPA_AS))
                    While !FQ3->(Eof()) .and. FQ3->(FQ3_FILIAL+FQ3_AS) == xFilial("FQ3")+FPA->FPA_AS
                        If FQ3->FQ3_VIAGEM == FPA->FPA_VIAGEM .and. FQ3->FQ3_NUM == SF1->F1_IT_ROMA
                            lTemZUC := .T.
                        EndIf

                        If FP0->FP0_TIPOSE == "L" .and. lTemZUC
                            nRet := 0
                            FQ3->(Reclock("FQ3",.F.))
                            FQ3->FQ3_NFRET  := ""
                            FQ3->FQ3_SERRET := ""
                            FQ3->FQ3_FORNE  := ""
                            FQ3->FQ3_LOJF   := ""
                            FQ3->(MsUnlock())
                            If !lDel
                                nReg := FQ3->(Recno())
                            EndIF
                            lDel := .T.
                        EndIf

                        FQ3->(dbSkip())
                    EndDo
                EndIf

                If lDel
                    FQ3->(dbGoto(nReg))
                    FQ2->(dbSetOrder(1))
                    If FQ2->(dbSeek(xFilial("FQ2")+FQ3->FQ3_NUM))
                        FQ2->(RecLock("FQ2",.F.))
                        FQ2->FQ2_NFSER := ""
                        FQ2->(MsUnlock())
                    EndIF
                EndIF

                // Verificar a quantidade que foi enviado x a quantidade retornada.
                // Só armazenar a nota se for a ultima entrada, ou seja, se as quantidades forem iguais.
                // Frank 19/10/20

                FQ7->(dbSetOrder(1))
                FQ7->(dbSeek(xFilial("FQ7")+FPA->FPA_PROJET))
                While !FQ7->(Eof()) .and. FQ7->FQ7_FILIAL == xFilial("FQ7") .and. FQ7->FQ7_PROJET == FPA->FPA_PROJET
                    If FQ7->FQ7_NFRET == SD1->D1_DOC .and. FQ7->FQ7_SERRET == SD1->D1_SERIE .and. FQ7->FQ7_FORNE == SD1->D1_FORNECE .and. FQ7->FQ7_LOJF == SD1->D1_LOJA
                        FQ7->(RecLock("FQ7",.F.))
                        FQ7->FQ7_NFRET   := ""
                        FQ7->FQ7_SERRET  := ""
                        FQ7->FQ7_FORNE   := ""
                        FQ7->FQ7_LOJF    := ""
                        FQ7->(MsUnlock())
                    EndIf
                    FQ7->(dbSkip())
                EndDo

                If FPA->(RecLock("FPA",.F.))
                    FPA->FPA_NFRET  := ""
                    FPA->FPA_SERRET := ""
                    FPA->FPA_DNFRET := StoD("")
                    FPA->FPA_ITERET := ""
                    FPA->FPA_DTSCRT	:= StoD("") // Jose Eulalio - 29/09/2022 - SIGALOC94-522/Chamado 29981 - ALIGN - Não gera faturamento automático, quando teve nota de retorno

                    //If FP0->FP0_TIPOSE == "L" .and. !lTemZUC
                    If FP0->FP0_TIPOSE == "L" // Jose Eulalio - 29/09/2022 - o Saldo deverá sempre retornar no caso de retorno parcial
                        // para efeito da cobranca somar a quantidade
                        nRet := 0
                        _aAreaFQZ := FQZ->(GetArea())
                        FQZ->(dbSetOrder(2))
                        FQZ->(dbSeek(xFilial("FQZ")+FPA->FPA_PROJET))
                        While !FQZ->(Eof()) .and. FQZ->FQZ_FILIAL+FQZ->FQZ_PROJET == xFilial("FQZ")+FPA->FPA_PROJET
                            // o campo FPA_CONFIG identifica as notas que não devem ser computadas no estorno
                            If alltrim(FQZ->FQZ_DOC+FQZ->FQZ_SERIE) <> alltrim(FPA->FPA_CONFIG)
                                If FQZ->FQZ_DOC == SD1->D1_DOC .and. FQZ->FQZ_SERIE == SD1->D1_SERIE .and. alltrim(FQZ->FQZ_AS) == alltrim(FPA->FPA_AS)
                                    nRet += FQZ->FQZ_QTD
                                EndIF
                            EndIF
                            FQZ->(dbSkip())
                        EndDo
                        FQZ->(RestArea(_aAreaFQZ))
                        FPA->FPA_QUANT  := FPA->FPA_QUANT + nRet
                        FPA->FPA_VLBRUT := FPA->FPA_PRCUNI * FPA->FPA_QUANT
                        If FPA->(FieldPos("FPA_PACRES")) > 0                                                                        
                             FPA->FPA_ACRESC := (FPA->FPA_QUANT*FPA->FPA_PRCUNI) * FPA->FPA_PACRES
                        EndIf
                        FPA->FPA_VRHOR  := (((FPA->FPA_PRCUNI * FPA->FPA_QUANT -(FPA->FPA_VLBRUT*(FPA->FPA_PDESC/100))) + (FPA->FPA_ACRESC)))
                    EndIF
                    
                    // Cancelamento do log das notas de entrada x orçamento.
                    // Frank Z Fuga em 08/09/2020
                    If lLOCX022 //SuperGetMV("MV_LOCX022",,.F.)
                        ITLOGFQZ(SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_ITEM, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_EMISSAO, SD1->D1_COD, SD1->D1_QUANT, FPA->FPA_FILIAL, FPA->FPA_AS, nVar, FPA->FPA_PROJET, FPA->FPA_OBRA, .F.)
                    EndIf

                    // Tratamento dos titulos provisorios - voltar com os PR
                    If lLOCX278 //getmv("MV_LOCX278",,.F.)
                        FP0->(dbSetOrder(1))
                        FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
                        nRegX := FPA->(Recno())
                        loca01318() // criacao do titulo provisorio
                        FPA->(dbGoto(nRegX))
                    EndIF

                    FPA->(MsUnLock())

                EndIf

                FPN->(dbSetOrder(2))
                If FPN->(dbSeek(xFilial("FPN")+FPA->(FPA_AS+FPA_PROJET+FPA_OBRA+FPA_VIAGEM)))
                    While !FPN->(Eof()) .and. FPN->(FPN_FILIAL+FPN_AS+FPN_PROJET+FPN_OBRA+FPN_VIAGEM) == xFilial("FPN")+FPA->(FPA_AS+FPA_PROJET+FPA_OBRA+FPA_VIAGEM)
                        If FPN->FPN_DTFIM == SF1->F1_EMISSAO .and. empty(FPN->FPN_NUMPV) .and. (FPN->FPN_SITUAC = "1" .or. FPN->FPN_SITUAC = "2")
                            If FPN->(RecLock("FPN",.F.))
                                FPN->FPN_DTMEDP := (FPN->FPN_DTINIC)+(FPA->FPA_LOCDIA)-1
                                FPN->FPN_DTFIM  := (FPN->FPN_DTINIC)+(FPA->FPA_LOCDIA)-1
                                FPN->(MsUnlock())
                            EndIf
                        EndIf
                        FPN->(dbSkip())
                    EndDo
                EndIf

                TRBFPA->(dbSkip())
            EndDo
        EndCase
    EndIf


    TRBFPA->(dbCloseArea())

    FPN->(RestArea( aAreaZLF ))
    ST9->(RestArea( aAreaST9 ))
    TQY->(RestArea( aAreaTQY ))
    SD1->(RestArea( aAreaSD1 ))
    FPA->(RestArea( aAreaZAG ))
    RestArea( aAreaOld )


Return Nil

/*/RetStatus
Retorna status do bem.
author Michel Taipina
since 08/03/2019
/*/
Static Function RetStatus(cAux,lEstorno)
Local aAreaOld := GetArea()
Local lRet     := .F.
Local cQuery   := ""
//Local nRecTqy  := 0
Local nRecFQD  := 0
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC

Default lEstorno := .F.

    If !lMvLocBac

        /*
        + cAux +
        *//*/

        cQuery := "SELECT TQY_STATUS, TQY.R_E_C_N_O_ TQYRECNO "
        cQuery += " FROM " + RetSqlName("TQY") + " TQY "
        If lEstorno
            cQuery += " WHERE  TQY_STTCTR  < ? "
        Else
            cQuery += " WHERE  TQY_STTCTR >= ? "
        EndIf
        cQuery     += "   AND  TQY.D_E_L_E_T_ = '' "
        If lEstorno
            cQuery += " ORDER BY TQY_STTCTR DESC "
        Else
            cQuery += " ORDER BY TQY_STTCTR "
        EndIf
        If Select("TRBTQY") > 0
            TRBTQY->(dbCloseArea())
        EndIf
        cQuery := CHANGEQUERY(cQuery)
        aBindParam := {cAux}
		MPSysOpenQuery(cQuery,"TRBTQY",,,aBindParam)
        //TcQuery cQuery New Alias "TRBTQY"

        If TRBTQY->(!Eof())
            lRet    := .T.
            nRecTqy := TRBTQY->TQYRECNO
        EndIf

        TRBTQY->(dbCloseArea())

        RestArea( aAreaOld )

        If nRecTqy > 0
            TQY->(dbGoTo(nRecTqy))
        EndIf /*/
    else
        /*
        cAux
        */
        cQuery := "SELECT FQD_STATQY, FQD.R_E_C_N_O_ FQDRECNO "
        cQuery += " FROM " + RetSqlName("FQD") + " FQD "
        If lEstorno
            cQuery += " WHERE  FQD_STAREN  = ? "
        Else
            cQuery += " WHERE  FQD_STAREN  = ? "
        EndIf
        cQuery     += "   AND  FQD.D_E_L_E_T_ = '' "
        If lEstorno
            cQuery += " ORDER BY FQD_STAREN DESC "
        Else
            cQuery += " ORDER BY FQD_STAREN "
        EndIf
        If Select("TRBFQD") > 0
            TRBFQD->(dbCloseArea())
        EndIf
        cQuery := CHANGEQUERY(cQuery)
        aBindParam := {cAux}
		MPSysOpenQuery(cQuery,"TRBFQD",,,aBindParam)
        //TcQuery cQuery New Alias "TRBFQD"

        If TRBFQD->(!Eof())
            lRet    := .T.
            nRecFQD := TRBFQD->FQDRECNO
        EndIf

        TRBFQD->(dbCloseArea())

        RestArea( aAreaOld )

        If nRecFQD > 0
            FQD->(dbGoTo(nRecFQD))
        EndIf
    EndIF

Return lRet

// Rotina para criar o log das notas de entradas x movimentos da ZAG
// Frank Zwarg Fuga - 08/09/2020
Static Function ITLOGFQZ(cDoc, cSerie, cItem, cForne, cLoja, dEmiss, cProd, nQtd, cFilFPA, cAs, nVar, cProjet, cObra, lMarcacao)
Local NDIASTRB
Local lType := type("_nZuc")=="N"
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local cQryPesq  := ""
Local cQuery := ""

    // Rotina valida somente para o tipo de serviço Locação.
    If FP0->FP0_TIPOSE == "L"
        FQZ->(dbSetOrder(1))
        If nVar == 3
            FPA->(dbSetOrder(6))
            FPA->(dbSeek(cFilFPA+cProjet+cAs))
            // Quando for inclusão da nota de entrada fazer o log do registro
            If !FQZ->(dbSeek(cFilFPA+cDoc+cSerie+cForne+cLoja+cItem+"2"))
                FQZ->(RecLock("FQZ",.T.))
                FQZ->FQZ_FILIAL	:= cFilFPA
                FQZ->FQZ_DOC	:= cDoc
                FQZ->FQZ_SERIE	:= cSerie
                FQZ->FQZ_ITEM	:= cItem
                FQZ->FQZ_FORNE	:= cForne
                FQZ->FQZ_LOJA	:= cLoja
                FQZ->FQZ_EMISS	:= dEmiss
                FQZ->FQZ_COD	:= cProd
                FQZ->FQZ_QTD	:= nQtd
                FQZ->FQZ_AS		:= cAs
                FQZ->FQZ_MSBLQL	:= "2"
                FQZ->FQZ_PROJET	:= cProjet
                FQZ->FQZ_OBRA   := cObra
                FQZ->FQZ_VLRUNI := FPA->FPA_PRCUNI
                FQZ->FQZ_ULTFAT := FPA->FPA_ULTFAT
                FQZ->FQZ_DTINI  := FPA->FPA_DTINI
                FQZ->FQZ_DTFIM  := FPA->FPA_DTFIM
                FQZ->FQZ_VLRTOT := nQtd * FPA->FPA_PRCUNI
                FQZ->FQZ_RETIRA := dEmiss //FPA->FPA_DNFRET			//FPA_DTFIM
                If !empty(FQZ->FQZ_ULTFAT)
                    FQZ->FQZ_PERPRO := (FQZ->FQZ_RETIRA - FQZ->FQZ_ULTFAT)
                Else
                    FQZ->FQZ_PERPRO := (FQZ->FQZ_RETIRA - FQZ->FQZ_DTINI) + 1
                EndIf

                FP1->(dbSetOrder(1))
                FP1->(dbSeek(FPA->FPA_FILIAL+FPA->FPA_PROJET+FPA->FPA_OBRA))

                // Alterado por Frank em 21/07/22
                IF FP1->FP1_TPMES <> "0" // não é mes fechado
                    FQZ->FQZ_VLRPRO := (FQZ->FQZ_VLRTOT * FQZ->FQZ_PERPRO) / If(FPA->FPA_LOCDIA==0,1,FPA->FPA_LOCDIA)
                Else // se for mes fechado
                    NDIASTRB := 30
                    DO CASE
                        CASE FPA->FPA_TPBASE == "M"
                            NDIASTRB := 30
                        CASE FPA->FPA_TPBASE == "Q"
                            NDIASTRB := 15
                        CASE FPA->FPA_TPBASE == "S"
                            NDIASTRB :=  7
                        OTHERWISE
                            DO CASE
                            CASE FPA->( FIELDPOS("FPA_LOCDIA") ) > 0
                                NDIASTRB := FPA->FPA_LOCDIA
                            CASE FPA->( FIELDPOS("FPA_PREDIA") ) > 0
                                NDIASTRB := FPA->FPA_PREDIA
                            OTHERWISE
                                NDIASTRB := FPA->FPA_DTENRE - FPA->FPA_DTINI + 1
                            ENDCASE
                    ENDCASE
                    FQZ->FQZ_VLRPRO := (FQZ->FQZ_VLRTOT * FQZ->FQZ_PERPRO) / NDIASTRB
                EndIf

                //SIGALOC94-799 - 12/06/2023 - José Eulálio - O trecho abaixo estava comentado. Retornando para o PE, pois é importante para não gerar Faturamento automático na remessa total do item
                If lMarcacao
                    FQZ->FQZ_PV := "X"
                EndIF

                FQZ->(MsUnlock())

                // a nota de retorno quando refere-se a um romaneio é a ultima da ZUC que ainda não tem o campo
                // nfret preenchido.
                If lType // Variavel criada na rotina LOC05102.prw - frank 02/11/20
                    If _nZuc > 0
                        FQ7->(dbGoto(_nZuc))
                        FQ7->(RecLock("FQ7",.F.))
                        FQ7->FQ7_NFRET	:= cDoc
                        FQ7->FQ7_SERRET	:= cSerie
                        FQ7->FQ7_FORNE	:= cForne
                        FQ7->FQ7_LOJF	:= cLoja
                        FQ7->(MsUnlock())
                    EndIf
                EndIf

            EndIf
        EndIf
        If nVar == 5
            // Quando for realizado a exclusão da nota de entrada, verificar se o registro do log existe
            // Se existir deixar como cancelado, se não existir criar e deixar como cancelado
            If FQZ->(dbSeek(xFilial("FQZ")+cDoc+cSerie+cForne+cLoja+cItem))
                FQZ->(RecLock("FQZ",.F.))
                FQZ->FQZ_MSBLQL := "1"
                FQZ->FQZ_DTCANC	:= dDataBase
                FQZ->(dbDelete())
                FQZ->(MsUnlock())
            /* Se não existir nem grava Else
                FQZ->(RecLock("FQZ",.T.))
                FQZ->FQZ_FILIAL	:= xFilial("FQZ")
                FQZ->FQZ_DOC	:= cDoc
                FQZ->FQZ_SERIE	:= cSerie
                FQZ->FQZ_ITEM	:= cItem
                FQZ->FQZ_FORNE	:= cForne
                FQZ->FQZ_LOJA	:= cLoja
                FQZ->FQZ_EMISS	:= dEmiss
                FQZ->FQZ_COD	:= cProd
                FQZ->FQZ_QTD	:= nQtd
                FQZ->FQZ_AS		:= cAs
                FQZ->FQZ_MSBLQL	:= "1"
                FQZ->FQZ_DTCANC	:= dDataBase
                FQZ->FQZ_PROJET	:= cProjet
                FQZ->(dbDelete())
                FQZ->(MsUnlock())*/
            EndIf

    		If ! Empty(FPA->FPA_GRUA) .And. ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
	    		If !lMvLocBac /*/ Só será chamado com MVLOCBAC .T.
		    	/*	If Select("TRBTQY") > 0
			    		TRBTQY->(dbCloseArea())
		    		EndIf
			    	cQuery := " SELECT   TQY_STATUS"
    				cQuery += " FROM " + RetSqlName("TQY") + " TQY "
	    			cQuery += " WHERE    TQY.TQY_STTCTR < '50' "
		    		cQuery += "   AND    TQY.D_E_L_E_T_ = '' "
			    	cQuery += " ORDER BY TQY_STTCTR DESC "
    				cQuery := changequery(cQuery)
	    			TcQuery cQuery New Alias "TRBTQY"
		    		TRBTQY->(dbGotop()) // antes era na query top 1, agora pegamos o primeiro registro

			    	If ! TRBTQY->(Eof())
				    	LOCXITU21(ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM,.T.)
					    If RecLock("ST9",.F.)
	    					ST9->T9_STATUS := TRBTQY->TQY_STATUS
		    				ST9->(MsUnLock())
			    		EndIf
				    EndIf

				    TRBTQY->(dbCloseArea()) */
    			else
//	    			If Select("TRBFQD") > 0
//		    			TRBFQD->(dbCloseArea())
//			    	EndIf
                    cQryPesq := " SELECT   FPA_PROJET"
	    			cQryPesq += " FROM " + RetSqlName("FPA") + " FPA "
		    		cQryPesq += " WHERE  FPA.D_E_L_E_T_ = '' "
                    cQryPesq += "   AND  FPA.FPA_PROJET <> ? "
                    cQryPesq += "   AND  FPA.FPA_PRODUT = ? "
                    cQryPesq += "   AND  FPA.FPA_GRUA = ? "
                    cQryPesq += "   AND  FPA.FPA_NFRET = '' "
                    cQryPesq := changequery(cQryPesq)
                    aBindParam := {FPA->FPA_PROJET,FPA->FPA_PRODUT, FPA->FPA_GRUA}
	                MPSysOpenQuery(cQryPesq,"TRBPSQ",,,aBindParam)
					TRBPSQ->(dbGotop()) 
		    		If TRBPSQ->(Eof()) // verifica se bem não está em outro contrato // Rossana - DSERLOCA 3414 - 08/07/24
    
    				    cQuery := " SELECT   FQD_STATQY"
	        			cQuery += " FROM " + RetSqlName("FQD") + " FQD "
	    	    		cQuery += " WHERE    FQD.FQD_STAREN < '50' "
        				cQuery += "   AND    FQD.D_E_L_E_T_ = '' "
	    	    		cQuery += " ORDER BY FQD_STAREN DESC "
		     	    	cQuery := changequery(cQuery)
			          	TcQuery cQuery New Alias "TRBFQD"
    			    	TRBFQD->(dbGotop()) // antes era na query top 1, agora pegamos o primeiro registro

		    	    	If ! TRBFQD->(Eof())
		    	    		LOCXITU21(ST9->T9_STATUS,TRBFQD->FQD_STATQY,FPA->FPA_PROJET,FPA->FPA_NFREM,FPA->FPA_SERREM,.T.)
		             		If RecLock("ST9",.F.)
		        				ST9->T9_STATUS := TRBFQD->FQD_STATQY
			          			ST9->(MsUnLock())
			    	    	EndIf
			    	    EndIf
			
	    			    TRBFQD->(dbCloseArea())
                    EndIf
    			    TRBPSQ->(dbCloseArea())
		    	Endif
		    EndIf
        EndIf
    EndIf
Return .T.

