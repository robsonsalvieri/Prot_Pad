#Include "protheus.ch"
#include "topconn.ch"

/*/ LOCM011
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
TRATAMENTO NA ORDEM DE SERVICO CORRETIVA
DSERLOCA-1982 - Frank em 10/05/2024
/*/

Function LOCM011(nOpcx, cOs)
Private lImplemento := .F.

    If LOCM011A("FQG_FILIAL","FQG") .AND. SuperGetMV( 'MV_NG1LOC', .F., .F. )
        If LOCM011A("FQF_FILIAL","FQF") .and. LOCM011A("FQH_FILIAL","FQH") .and. LOCM011A("FQE_FILIAL","FQE")
            lImplemento := .T.
        EndIf
    EndIf

    If lImplemento
        If nOpcx == 5 // Tratamento no cancelamento da OS.
            LOCM011C(cOs)
        ElseIf nOpcx == 3 // Tratamento na inclusão da OS
            LOCM011D(cOs)
        ElseIf nOpcx == 4 // Tratamento na alteração da OS
            LOCM011E(cOs)
        EndIf
    EndIf
return .T.

/*/ LOCM011C
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
TRATAMENTO NO CANCELAMENTO DA ORDEM DE SERVICO CORRETIVA
DSERLOCA-1982 - Frank em 10/05/2024
/*/
Function LOCM011C(cOs)
Local cQuery
Local lTem

    If lImplemento
        // Colocar o flag de cancelado na tabela de implemento - FQG.
        If select("TRBOS") > 0
            TRBOS->(dbCloseArea())
        EndIf
        cQuery := " SELECT FQG.R_E_C_N_O_ AS REG "
        cQuery += " FROM " + RETSQLNAME("FQG") + " FQG "
        cQuery += " WHERE FQG.D_E_L_E_T_ = '' AND FQG.FQG_OS = ? "
        cQuery := CHANGEQUERY(cQuery)
        aBindParam := {cOs}
        MPSysOpenQuery(cQuery,"TRBOS",,,aBindParam)
        While !TRBOS->(Eof())
            FQG->(dbGoto(TRBOS->(REG)))
            FQG->(RecLock("FQG"),.F.)
            FQG->FQG_FEITO := "C"
            FQG->(MsUnlock())
            TRBOS->(dbSkip())
        EndDo
        TRBOS->(dbCloseArea())

        // Apagar o movimento do sub-status
        // Localizar o movimento do substatus
        lTem := .F.
        FQF->(dbSetOrder(5)) // Codigo do bem
        FQF->(dbSeek(xFilial("FQF")+STJ->TJ_CODBEM))
        While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_CODBEM) == xFilial("FQF")+STJ->TJ_CODBEM
            If FQF->FQF_OS == STJ->TJ_ORDEM
                lTem := .T.
                Exit
            EndIf
            FQF->(dbSkip())
        EndDo
        If lTem
            FQF->(RecLock("FQF",.F.))
            FQF->(dbDelete())
            FQF->(MsUnlock())
        EndIF
    EndIf
Return

/*/ LOCM011D
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
TRATAMENTO NA INCLUSAO DA ORDEM DE SERVICO CORRETIVA
DSERLOCA-1982 - Frank em 14/05/2024
/*/
Function LOCM011D(cOs)
Local cAs
Local aArea     := GetArea()
Local nReg      := 0
Local cSeq      := ""
Local cCod
Local cSequ
Local nI        := 0
Local nPosProd  := 0
Local nPosQuant := 0
Local cCust := ""//CENTRO DE CUSTO - BUSCAR DA FPA OU DA ST9

    If lImplemento
        cAs := STJ->TJ_AS
        If !empty(cAs)
            FPA->(dbSetOrder(3))
            If FPA->(dbSeek(xFilial("FPA")+cAs))

                If !empty(STJ->TJ_DTPRINI) .or. !empty(STJ->TJ_DTPRFIM) .or. !empty(STJ->TJ_DTPPINI) .or. !empty(STJ->TJ_DTPPFIM) .or. file("\SYSTEM\LOCA059X1.TXT")
                    FQ4->(dbSeek(xFilial("FQ4")+STJ->TJ_CODBEM))
                    While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4")+STJ->TJ_CODBEM
                        If FQ4->FQ4_SEQ > cSeq
                            cSeq := FQ4->FQ4_SEQ
                            nReg := FQ4->(Recno())
                        EndIf
                        FQ4->(dbSkip())
                    EndDo
                
                    // Se nReg for 0 criar a FQ4
                    If nReg == 0
                        ST9->(dbSetOrder(1))
                        ST9->(dbSeek(xFilial("ST9")+STJ->TJ_CODBEM))
                        LOCXITU21("",ST9->T9_STATUS,"","","")
                        FQ4->(RecLock("FQ4",.F.))
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
                        If empty(FQ4->FQ4_PROJET)
                            FQ4->FQ4_AS := ""
                        EndIf
                        FQ4->(MsUnlock())
                    EndIf
                    // Se nReg for > 0 posiconar na FQ4
                    If nReg > 0
                        FQ4->(dbGoto(nReg))
                    EndIf

                    cCod := GetSx8Num("FQF","FQF_COD")
                    ConfirmSx8()

                    // Gerar o registro do sub-status
                    FQF->(RecLock("FQF",.T.))
                    FQF->FQF_FILIAL := xFilial("FQF") 
                    FQF->FQF_CODBEM := STJ->TJ_CODBEM
                    FQF->FQF_STATUS := FQ4->FQ4_STATUS
                    FQF->FQF_CC     := FPA->FPA_CUSTO
                    FQF->FQF_DTINI  := dDataBase
                    FQF->FQF_HORA   := Time()
                    FQF->FQF_SUBST  := ACHAFQH(FQ4->FQ4_STATUS, STJ->TJ_SERVICO)
                    FQF->FQF_PROJET := FPA->FPA_PROJET
                    FQF->FQF_AS     := cAs
                    FQF->FQF_CONTA  := STJ->TJ_POSCONT
                    FQF->FQF_SEQ    := FQ4->FQ4_SEQ
                    FQF->FQF_OS     := STJ->TJ_ORDEM
                    FQF->FQF_DPPINI := STJ->TJ_DTPPINI
                    FQF->FQF_HPPINI := STJ->TJ_HOPPINI
                    FQF->FQF_DPPFIM := STJ->TJ_DTPPFIM
                    FQF->FQF_HPPFIM := STJ->TJ_HOPPFIM
                    FQF->FQF_DPRINI := STJ->TJ_DTPRINI
                    FQF->FQF_HPRINI := STJ->TJ_HOPRINI
                    FQF->FQF_DPRFIM := STJ->TJ_DTPRFIM
                    FQF->FQF_HPRFIM := STJ->TJ_HOPRFIM
                    FQF->FQF_COD    := cCod
                    FQF->(MsUnlock())
                EndIf
            EndIf
        EndIf
    EndIF
    RestArea(aArea)

    //Grava Custo extra se o campo TL_AS = SIM - Dennis Calabrez ISSEU - DSERLOCA-7613
    For nI := 1 to Len(AGETINS)
        If M->TL_AS = "S"//AGETINS[nI][25] == "S"

            cSequ := GetSx8Num("FPG","FPG_SEQ")
            ConfirmSx8()

            //STJ->(dbSetOrder(1))
            //STJ->(dbSeek(xFilial("STJ")+STL->TL_ORDEM))
            cCust := Posicione("FPA",1,xFilial("FPA")+STJ->TJ_PROJETO,"FPA_CUSTO")
            If Empty(cCust)
                cCust := Posicione("ST9",1,xFilial("ST9")+STJ->TJ_CODBEM,"T9_CCUSTO")
            EndIf
            // Gerar o registro custo extra
            FPG->(RecLock("FPG",.T.))
            FPG->FPG_FILIAL := xFilial("FPG") 
            FPG->FPG_PROJET := STJ->TJ_PROJETO
            FPG->FPG_OBRA   := STJ->TJ_OBRA
            FPG->FPG_NRAS   := STJ->TJ_AS
            FPG->FPG_CODDES := STJ->TJ_CODBEM
            FPG->FPG_DESPES := Posicione("ST9",1,xFilial("ST9")+STJ->TJ_CODBEM,"T9_NOME")
            nPosProd        := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_CODIGO"})
		    FPG->FPG_PRODUT := If(nPosProd > 0, aGETINS[nI][nPosProd], Space(15))
            FPG->FPG_DESCRI := Posicione("SB1",1,xFilial("SB1")+If(nPosProd > 0, aGETINS[nI][nPosProd], Space(30)),"B1_DESC")
            FPG->FPG_DOCORI := STJ->TJ_ORDEM+'-'+'0'
            FPG->FPG_JUNTO  := "S"
            FPG->FPG_DTENT  := dDataBase
            FPG->FPG_TIPO   := "4" // Indica que veio de uma OS
            FPG->FPG_CUSTO  := cCust
            FPG->FPG_SEQ    := cSequ
            FPG->FPG_STATUS := "1"
            nPosQuant       := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_QUANTID"})
            FPG->FPG_QUANT  := If(nPosQuant > 0, aGETINS[nI][nPosQuant], Space(15))
            FPG->FPG_VLUNIT := Posicione("SB1",1,xFilial("SB1")+If(nPosProd > 0, aGETINS[nI][nPosProd], Space(15)),"B1_PRV1")
            FPG->FPG_VALOR  :=  If(nPosQuant > 0, aGETINS[nI][nPosQuant], Space(15)) * Posicione("SB1",1,xFilial("SB1")+If(nPosProd > 0, aGETINS[nI][nPosProd], Space(15)),"B1_PRV1") 
            FPG->(MsUnlock())  
        EndIf
    Next nI
    DeletAS()
Return .T.

/*/ LOCM011E
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
TRATAMENTO NA ALTERACAO DA ORDEM DE SERVICO CORRETIVA
DSERLOCA-1982 - Frank em 14/05/2024
/*/
Function LOCM011E(cOs)
Local cAs
Local aArea := GetArea()
Local nReg  := 0
Local cSeq  := ""
Local cCod
Local lTem
Local nI    := 0
Local cCust := 0

    If lImplemento
        cAs := STJ->TJ_AS
        If !empty(cAs)
            FPA->(dbSetOrder(3))
            If FPA->(dbSeek(xFilial("FPA")+cAs))

                If !empty(STJ->TJ_DTPRINI) .or. !empty(STJ->TJ_DTPRFIM) .or. !empty(STJ->TJ_DTPPINI) .or. !empty(STJ->TJ_DTPPFIM) .or. file("\SYSTEM\LOCA059X1.TXT")

                    FQ4->(dbSeek(xFilial("FQ4")+STJ->TJ_CODBEM))
                    While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4")+STJ->TJ_CODBEM
                        If FQ4->FQ4_SEQ > cSeq
                            cSeq := FQ4->FQ4_SEQ
                            nReg := FQ4->(Recno())
                        EndIf
                        FQ4->(dbSkip())
                    EndDo

                    // Se nReg for 0 criar a FQ4
                    If nReg == 0
                        ST9->(dbSetOrder(1))
                        ST9->(dbSeek(xFilial("ST9")+STJ->TJ_CODBEM))
                        LOCXITU21("",ST9->T9_STATUS,"","","")
                        FQ4->(RecLock("FQ4",.F.))
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
                        If empty(FQ4->FQ4_PROJET)
                            FQ4->FQ4_AS := ""
                        EndIf
                        FQ4->(MsUnlock())
                    EndIf
                    // Se nReg for > 0 posiconar na FQ4
                    If nReg > 0
                        FQ4->(dbGoto(nReg))
                    EndIf

                    // Localizar o movimento do substatus
                    lTem := .F.
                    FQF->(dbSetOrder(5)) // Codigo do bem
                    FQF->(dbSeek(xFilial("FQF")+STJ->TJ_CODBEM))
                    While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_CODBEM) == xFilial("FQF")+STJ->TJ_CODBEM
                        If FQF->FQF_OS == STJ->TJ_ORDEM
                            lTem := .T.
                            Exit
                        EndIf
                        FQF->(dbSkip())
                    EndDo
                    
                    If !lTem
                        cCod := GetSx8Num("FQF","FQF_COD")
                        ConfirmSx8()
                        FQF->(RecLock("FQF",.T.))
                    Else
                        FQF->(RecLock("FQF",.F.))
                    EndIF

                    // Gerar o registro do sub-status
                    FQF->FQF_FILIAL := xFilial("FQF") 
                    FQF->FQF_CODBEM := STJ->TJ_CODBEM
                    FQF->FQF_STATUS := FQ4->FQ4_STATUS
                    FQF->FQF_CC     := FPA->FPA_CUSTO
                    FQF->FQF_DTINI  := dDataBase
                    FQF->FQF_HORA   := Time()
                    FQF->FQF_SUBST  := ACHAFQH(FQ4->FQ4_STATUS, STJ->TJ_SERVICO)
                    FQF->FQF_PROJET := FPA->FPA_PROJET
                    FQF->FQF_AS     := cAs
                    FQF->FQF_CONTA  := STJ->TJ_POSCONT
                    FQF->FQF_SEQ    := FQ4->FQ4_SEQ
                    FQF->FQF_OS     := STJ->TJ_ORDEM
                    FQF->FQF_DPPINI := STJ->TJ_DTPPINI
                    FQF->FQF_HPPINI := STJ->TJ_HOPPINI
                    FQF->FQF_DPPFIM := STJ->TJ_DTPPFIM
                    FQF->FQF_HPPFIM := STJ->TJ_HOPPFIM
                    FQF->FQF_DPRINI := STJ->TJ_DTPRINI
                    FQF->FQF_HPRINI := STJ->TJ_HOPRINI
                    FQF->FQF_DPRFIM := STJ->TJ_DTPRFIM
                    FQF->FQF_HPRFIM := STJ->TJ_HOPRFIM
                    If !lTem
                        FQF->FQF_COD    := cCod
                    EndIf
                    FQF->(MsUnlock())
                EndIf
            EndIf
        EndIf
    EndIF
    RestArea(aArea)

    //Grava Custo extra se o campo TL_AS = SIM - Dennis Calabrez ISSEU - DSERLOCA-7613
    DeletFPG()
    For nI := 1 to Len(AGETINS)
        If M->TL_AS = "S"//AGETINS[nI][25] == "S"

            cSequ := GetSx8Num("FPG","FPG_SEQ")
            ConfirmSx8()

            //STJ->(dbSetOrder(1))
            //dbSeek(xFilial("STJ")+STL->TL_ORDEM)
            cCust := Posicione("FPA",1,xFilial("FPA")+STJ->TJ_PROJETO,"FPA_CUSTO")
            If Empty(cCust)
                cCust := Posicione("ST9",1,xFilial("ST9")+STJ->TJ_CODBEM,"T9_CCUSTO")
            EndIf            
            // Gerar o registro custo extra
            FPG->(RecLock("FPG",.T.))
            FPG->FPG_FILIAL := xFilial("FPG") 
            FPG->FPG_PROJET := STJ->TJ_PROJETO
            FPG->FPG_OBRA   := STJ->TJ_OBRA
            FPG->FPG_NRAS   := STJ->TJ_AS
            FPG->FPG_CODDES := STJ->TJ_CODBEM
            FPG->FPG_DESPES :=  Posicione("ST9",1,xFilial("ST9")+STJ->TJ_CODBEM,"T9_NOME")
            xx := aScan(aHeaIns,{|x| Trim(Upper(x[2])) == "TL_CODIGO"})
		    M->TL_CODIGO := If(xx > 0, aGETINS[nI][xx], Space(15))
            FPG->FPG_PRODUT := M->TL_CODIGO
            FPG->FPG_DESCRI := Posicione("SB1",1,xFilial("SB1")+M->TL_CODIGO,"B1_DESC")
            FPG->FPG_DOCORI := STJ->TJ_ORDEM+'-'+"0"
            FPG->FPG_JUNTO  := "S"
            FPG->FPG_DTENT  := dDataBase
            FPG->FPG_TIPO   := "4" // Indica que veio de uma OS
            FPG->FPG_CUSTO  := cCust
            FPG->FPG_SEQ    := cSequ
            FPG->FPG_STATUS := "1"
            FPG->FPG_QUANT  := M->TL_QUANTID
            FPG->FPG_VLUNIT := Posicione("SB1",1,xFilial("SB1")+M->TL_CODIGO,"B1_PRV1")
            FPG->FPG_VALOR  := M->TL_QUANTID * Posicione("SB1",1,xFilial("SB1")+M->TL_CODIGO,"B1_PRV1") 
            FPG->(MsUnlock())          
        EndIf
    Next nI
    DeletAS()
Return .T.

/*/ ACHAFQH
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
LOCALIZA O SUB-STATUS DO SERVICO RELACIONADO NA OS
DSERLOCA-1982 - Frank em 14/05/2024
/*/

Function ACHAFQH(cStatus, cServico)
Local cSubStatus := ""
If !empty(cStatus) .and. !empty(cServico)
    FQH->(dbGotop())
    While !FQH->(Eof())
        If FQH->(FQH_FILIAL+FQH_STATUS+FQH_SERV) == xFilial("FQH")+cStatus+cServico
            cSubStatus := FQH->FQH_SUBSTA
            Exit
        EndIF
        FQH->(dbSkip()) 
    EndDo
EndIF
Return cSubStatus


/*/{PROTHEUS.DOC} LOCM011A
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE UM CAMPO EXISTE NO SX3
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/

Function LOCM011A(cCampo, cAlias)
Local a1Struct 
Local nP
Local lRet := .F.
    If !empty(cCampo) .and. !empty(cAlias)
        a1Struct := FWSX3Util():GetListFieldsStruct( cAlias, .F.)
        For nP := 1 to len(a1Struct)
            If upper(alltrim(a1Struct[nP][01])) == upper(alltrim(cCampo))
                lRet := .T.
                exit
            EndIf
        Next
    EndIF
Return lRet

/*/{Protheus.doc} DeletFPG
Deleta os custos extras não faturados  gerados pela OS
@type function
@version 1.0
@author Dennis Calabrez
@since 23/10/2025
/*/
Static Function DeletFPG()
Local cQuery 	:= ""
Local aArea 	:= GetArea()

	cQuery += "SELECT FPG.R_E_C_N_O_"
	cQuery += " FROM "+ RetSqlName("FPG") + " FPG (NOLOCK) "
	cQuery += " WHERE FPG_FILIAL = ? " // 1 xFilial("FPG")
	cQuery += " AND FPG_DOCORI LIKE ? "   // 2 M->TJ_ORDEM
	cQuery += " AND FPG_PVNUM = ''"  // Pedido não gerado
	cQuery += " AND FPG.D_E_L_E_T_ = ' ' "
	aBindParam := {xFilial("FPG"),M->TJ_ORDEM+"%"}
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"TRBFPG",,,aBindParam)

	while !TRBFPG->(Eof())
		dbSelectArea("FPG")
		dbGoto(TRBFPG->R_E_C_N_O_)
		if Empty(FPG->FPG_PVNUM) .AND. ALLTRIM(SubString(FPG->FPG_DOCORI, 7,11)) == "-0" // Pedido de Venda não foi gerado
			RecLock("FPG",.F.)
			FPG->(dbDelete())
			msUnlock()
		endif
		TRBFPG->(dbSkip())
	enddo

	TRBFPG->(dbCloseArea())
	RestArea(aArea)

Return

/*/{Protheus.doc} DeletAS
Deleta o conteúdo do campo TL_AS para não ir preenchido jo Retorno de O.S. Mod2
@type function
@version 1.0
@author Dennis Calabrez
@since 30/10/2025
/*/
Static Function DeletAS()
Local cQuery 	:= ""
Local aArea 	:= GetArea()

	cQuery += "SELECT STL.R_E_C_N_O_"
	cQuery += " FROM "+ RetSqlName("STL") + " STL "
	cQuery += " WHERE TL_FILIAL = ? " // 1 xFilial("STL")
	cQuery += " AND TL_ORDEM = ? "   // 2 M->TJ_ORDEM
	cQuery += " AND STL.D_E_L_E_T_ = ' ' "
	aBindParam := {xFilial("STL"),M->TJ_ORDEM}
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"TRBSTL",,,aBindParam)

	while !TRBSTL->(Eof())
		dbSelectArea("STL")
		dbGoto(TRBSTL->R_E_C_N_O_)
		RecLock("STL",.F.)
		STL->TL_AS := ""
		STL->(msUnlock())
		TRBSTL->(dbSkip())
	enddo

	TRBSTL->(dbCloseArea())
	RestArea(aArea)

Return
