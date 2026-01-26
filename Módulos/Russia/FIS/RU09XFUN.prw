#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'TOTVS.CH'
#include 'topconn.ch'
#include 'ru09xfun.ch'

Static __PDETAIL := 'F63PDETAIL|F64PDETAIL'
Static __RDETAIL := 'F63RDETAIL|F64RDETAIL'


/*/{Protheus.doc} RU09XTIOSQFilter
Filter for the Standard Query for Smart TIO.
@author Konstantin Cherchik
@since 04/11/2018
@edit  30 April 2022 astepanov
@version P12.1.20
@type function
/*/
Function RU09XTIOSQFilter() 

Local aArea             as Array
Local aAreaTMP          as Array
Local cSupplierID       as Character
Local cClientID         as Character
Local cProductID        as Character
Local cLoja             as Character
Local cProdTaxGroup     as Character 
Local cProdGrpType      as Character
Local cSupTaxGrp        as Character
Local cCusTaxGrp        as Character
Local cB1Grupo          as Character
Local cRulesKey         as Character
Local cNFTipoNF         as Character
Local cNFOperNF         as Character
Local cNFEspecie        as Character
Local lFoundKey         as Logical
Local lCompra           as Logical
Local lRet              as Logical
Local oModel            as Object


aArea := GetArea()

cNFTipoNF := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie:= Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

oModel      := FWModelActive()

/* Get the necessary information to determine the Smart TIO code, depending on the source. */ 

If (IsInCallStack("MATA121"))

    cSupplierID := M->CA120FORN
    cLoja       := M->CA120LOJ
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_PRODUTO')} )]

ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))

    If !EMPTY(AllTrim(M->C5_TIPO)) .And. AllTrim(M->C5_TIPO)=='B'
        cSupplierID := M->C5_CLIENTE
    Else
        cClientID   := M->C5_CLIENTE
    EndIf
    cLoja       := M->C5_LOJACLI
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_PRODUTO')} )]

ElseIf (IsInCallStack("CNTA300RUS"))

    If (IsInCallStack("CN300ALTER"))

        oModel      := FWModelActive()
        lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'),oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO'))

        If lCompra
            cSupplierID := AllTrim(oModel:GetValue('CNADETAIL','CNA_FORNEC'))
            cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LJFORN'))
            cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
        Else
            cClientID   := AllTrim(oModel:GetValue('CNADETAIL','CNA_CLIENT'))
            cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LOJACL'))
            cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
        EndIf

    ElseIf (IsInCallStack("CN300InCOM")) 

        oModel      := FWModelActive()

        cSupplierID := AllTrim(oModel:GetValue('CNADETAIL','CNA_FORNEC'))
        cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LJFORN'))
        cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))

    ElseIf (IsInCallStack("CN300InVEN")) 

        oModel      := FWModelActive()

        cClientID   := AllTrim(oModel:GetValue('CNADETAIL','CNA_CLIENT'))
        cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LOJACL'))
        cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))

    Endif

ElseIf (IsInCallStack("CNTA121RUS")) 

    oModel      := FWModelActive()
    lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA"))

    If lCompra
        cSupplierID   := AllTrim(oModel:GetValue('CXNDETAIL','CXN_FORCLI'))
        cLoja       := AllTrim(oModel:GetValue('CXNDETAIL','CXN_LOJA')) 
        cProductID  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))
    Else
        cClientID := AllTrim(oModel:GetValue('CXNDETAIL','CXN_FORCLI'))
        cLoja       := AllTrim(oModel:GetValue('CXNDETAIL','CXN_LOJA'))
        cProductID  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))
    EndIf

ElseIf (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N")  .OR. cNFEspecie == 'NCC')

    cSupplierID := M->F1_FORNECE
    cLoja       := M->F1_LOJA
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_COD')} )]


ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == 'NDC') 

    cClientID   := M->F2_CLIENTE
    cLoja       := M->F2_LOJA
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_COD')} )]

ElseIf (RU05XFN010_CheckModel(oModel, "RU05D01"))
    cClientID   := AllTrim(oModel:GetValue('F5YMASTER','F5Y_CLIENT'))
    cLoja       := AllTrim(oModel:GetValue('F5YMASTER','F5Y_BRANCH'))
    cProductID  := AllTrim(oModel:GetValue('F5ZDETAIL_AFTER','F5Z_ITMCOD'))
EndIf

If (!empty(AllTrim(cClientID))) 
    dbSelectArea("SA1")
    aAreaTMP := SA1->(GetArea())
    dbSetOrder(1)
    If MsSeek(xFilial("SA1")+cClientID+cLoja)
        cCusTaxGrp      := PADR(SA1->A1_GRPTRIB,GetSx3Cache("F51_GRPCUS","X3_TAMANHO"), " ")
    EndIf
    RestArea(aAreaTMP)
EndIf

If (!empty(AllTrim(cSupplierID)))
    dbSelectArea("SA2")
    aAreaTMP := SA2->(GetArea())
    dbSetOrder(1)
    If MsSeek(xFilial("SA2")+cSupplierID+cLoja)
        cSupTaxGrp      := PADR(SA2->A2_GRPTRIB,GetSx3Cache("F51_GRPSUP","X3_TAMANHO")," ")
    EndIf
    RestArea(aAreaTMP)
EndIf

If (!empty(AllTrim(cProductID)))
    dbSelectArea("SB1")
    aAreaTMP := SB1->(GetArea())
	dbSetOrder(1)
	If MSSeek(xFilial("SB1") + cProductID)
        cProdTaxGroup   := PADR(SB1->B1_GRTRIB,GetSx3Cache("F51_PRDGRP","X3_TAMANHO")," ")
        cB1Grupo        := SB1->B1_GRUPO
    EndIf
    RestArea(aAreaTMP)
    dbSelectArea("SBM")
    aAreaTMP := SBM->(GetArea())
	dbSetOrder(1)
    If MSSeek(xFilial("SBM") + cB1Grupo)
        cProdGrpType    := PADR(SBM->BM_TIPGRU,GetSx3Cache("F51_TPPRD","X3_TAMANHO")," ")
    EndIf
    RestArea(aAreaTMP)
EndIf

//Search for a Smart TIO code that matches filter conditions.
lRet := .F.
If !Empty(cProdTaxGroup) .and. !Empty(cProdGrpType) .and. !(Empty(cSupTaxGrp) .and. Empty(cCusTaxGrp))
    //cProdTaxGroup and cProdGrpType MUST be filled, one of cSupTaxGrp and cCusTaxGrp CAN be empty,
    //also we suggest that cursor in F50 table positioned correctly.
    DBSelectArea("F51")
    F51->(DBSetOrder(6)) // F51_FILIAL+F51_KEY+F51_PRDGRP+F51_TPPRD+F51_GRPSUP+F51_GRPCUS from SIX table
    If MSSeek(xFilial("F51")+F50->F50_KEY+cProdTaxGroup+cProdGrpType) // use part of index key for searching
        lFoundKey := .F.
        While !lFoundKey .and. F51->F51_FILIAL == xFilial("F51") .and. F51->F51_KEY == F50->F50_KEY .and. F51->F51_PRDGRP == cProdTaxGroup .and. F51->F51_TPPRD == cProdGrpType
            //Filter conditions
            If     !Empty(cSupTaxGrp) .and. cSupTaxGrp == F51->F51_GRPSUP
                lFoundKey := .T.
            ElseIf !Empty(cCusTaxGrp) .and. cCusTaxGrp == F51->F51_GRPCUS
                lFoundKey := .T.
            ElseIf Empty(F51->F51_GRPSUP) .and. Empty(F51->F51_GRPCUS)
                If     Empty(cSupTaxGrp) .and. Empty(F50->F50_TI)
                    lFoundKey := .T.
                ElseIf Empty(cCusTaxGrp) .and. Empty(F50->F50_TO)
                    lFoundKey := .T.
                EndIf
            EndIf //End of Filter conditions
            If lFoundKey // after successful search we will be positioned on correct F51 record
                cRulesKey := F51->F51_KEY
                lRet      := .T.
            Else
                F51->(DBSkip(1))
            EndIf
        EndDo
    EndIf
EndIf //End of searching

RestArea(aArea)

Return lRet


/*/{Protheus.doc} RU09XTIOTrigger
Filter for the Standard Query for Smart TIO
@author Konstantin Cherchik
@since 04/11/2018
@edit astepanov 17 May 2022
@version P12.1.20
@type function
/*/
Function RU09XTIOTrigger(nCaller as Numeric) 

Local aArea             as Array
Local aAreaTMP          as Array
Local cAlias            as Character
Local cQuery            as Character
Local cSupplierID       as Character
Local cClientID         as Character
Local cProductID        as Character
Local cLoja             as Character
Local cProdTaxGroup     as Character 
Local cProdGrpType      as Character
Local cSupTaxGrp        as Character
Local cCusTaxGrp        as Character
Local cB1Grupo          as Character
Local cRulesKey         as Character
Local cCNBOper          as Character
Local cNFTipoNF         as Character
Local cNFOperNF         as Character
Local cNFEspecie        as Character 
Local lCompra           as Logical
Local oModel            as Object

aArea := GetArea()

cNFTipoNF  := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF  := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie := Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

/* Get the necessary information to determine the Smart TIO code, depending on the source. */ 

If (IsInCallStack("MATA121"))

    If !(empty(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_OPER')} )]))
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_TES')} )] := Space(TamSX3("C7_TES")[1])
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_CF')} )] := Space(TamSX3("C7_CF")[1])
    EndIf 

    cSupplierID := M->CA120FORN
    cLoja       := M->CA120LOJ
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_PRODUTO')} )]

ElseIf (IsInCallStack("CNTA300RUS"))

    If (IsInCallStack("CN300ALTER"))

        oModel      := FWModelActive()
        lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'),oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO'))

        If lCompra
            cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

            If !(empty(cCNBOper))
                oModel:GetModel("CNBDETAIL"):LoadValue("CNB_TE",Space(TamSX3("CNB_TE")[1]))
                oModel:GetModel("CNBDETAIL"):LoadValue("CNB_CF",Space(TamSX3("CNB_CF")[1]))
            EndIf

            cSupplierID := AllTrim(oModel:GetValue('CNADETAIL','CNA_FORNEC'))
            cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LJFORN'))
            cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
        Else
            cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

            If !(empty(cCNBOper))
                oModel:GetModel("CNBDETAIL"):LoadValue("CNB_TS",Space(TamSX3("CNB_TS")[1]))
                oModel:GetModel("CNBDETAIL"):LoadValue("CNB_CF",Space(TamSX3("CNB_CF")[1]))
            EndIf

            cClientID   := AllTrim(oModel:GetValue('CNADETAIL','CNA_CLIENT'))
            cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LOJACL'))
            cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
        EndIf

    ElseIF (IsInCallStack("CN300InCOM"))

        oModel      := FWModelActive()
        cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

        If !(empty(cCNBOper))
            oModel:GetModel("CNBDETAIL"):LoadValue("CNB_TE",Space(TamSX3("CNB_TE")[1]))
            oModel:GetModel("CNBDETAIL"):LoadValue("CNB_CF",Space(TamSX3("CNB_CF")[1]))
        EndIf

        cSupplierID := AllTrim(oModel:GetValue('CNADETAIL','CNA_FORNEC'))
        cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LJFORN'))
        cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))

    ElseIF (IsInCallStack("CN300InVEN"))

        oModel      := FWModelActive()
        cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

        If !(empty(cCNBOper))
            oModel:GetModel("CNBDETAIL"):LoadValue("CNB_TS",Space(TamSX3("CNB_TS")[1]))
            oModel:GetModel("CNBDETAIL"):LoadValue("CNB_CF",Space(TamSX3("CNB_CF")[1]))
        EndIf

        cClientID   := AllTrim(oModel:GetValue('CNADETAIL','CNA_CLIENT'))
        cLoja       := AllTrim(oModel:GetValue('CNADETAIL','CNA_LOJACL'))
        cProductID  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))

    EndIf

ElseIf (IsInCallStack("CNTA121RUS")) 

    oModel      := FWModelActive()
    lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA"))

    cCNBOper    := AllTrim(oModel:GetValue('CNEDETAIL','CNE_OPER'))

    If !(empty(cCNBOper))
        oModel:GetModel("CNEDETAIL"):LoadValue("CNE_TES",Space(Max(TamSX3("CNE_TE")[1],TamSX3("CNE_TS")[1])))
        oModel:GetModel("CNEDETAIL"):LoadValue("CNE_CF",Space(TamSX3("CNB_CF")[1]))
    EndIf

    If lCompra
        cSupplierID   := AllTrim(oModel:GetValue('CXNDETAIL','CXN_FORCLI'))
        cLoja       := AllTrim(oModel:GetValue('CXNDETAIL','CXN_LOJA')) 
        cProductID  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))
    Else
        cClientID := AllTrim(oModel:GetValue('CXNDETAIL','CXN_FORCLI'))
        cLoja       := AllTrim(oModel:GetValue('CXNDETAIL','CXN_LOJA'))
        cProductID  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))
    EndIf

ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA")) .And. ! IsInCallStack("CN130MANUT")

    If !(empty(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_OPER')} )]))
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_TES')} )] := Space(TamSX3("C6_TES")[1])
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_CF')} )] := Space(TamSX3("C6_CF")[1])
    EndIf

    If !EMPTY(AllTrim(M->C5_TIPO)) .And. AllTrim(M->C5_TIPO)=='B'
        cSupplierID := M->C5_CLIENTE
    Else
        cClientID   := M->C5_CLIENTE
    EndIf
    cLoja       := M->C5_LOJACLI
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_PRODUTO')} )]

ElseIf (cNFOperNF == "E") .And. ! IsInCallStack("CN130MANUT")

    If !(empty(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_OPER')} )]))
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_TES')} )] := Space(TamSX3("D1_TES")[1])
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_CF')} )] := Space(TamSX3("D1_CF")[1])
    EndIf

    cSupplierID := M->F1_FORNECE
    cLoja       := M->F1_LOJA
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_COD')} )]


ElseIf (cNFOperNF == "S") .And. ! IsInCallStack("CN130MANUT")

    If !(empty(aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_OPER')} )]))
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_TES')} )] := Space(TamSX3("D2_TES")[1])
        aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_CF')} )] := Space(TamSX3("D2_CF")[1])
    EndIf

    cClientID   := M->F2_CLIENTE
    cLoja       := M->F2_LOJA 
    cProductID  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_COD')} )]

EndIf

If (!empty(AllTrim(cClientID)))
    dbSelectArea("SA1")
    aAreaTMP := SA1->(GetArea())
    dbSetOrder(1)
    If MsSeek(xFilial("SA1")+cClientID+cLoja)
        cCusTaxGrp      := PADR(SA1->A1_GRPTRIB,GetSx3Cache("F51_GRPCUS","X3_TAMANHO"), " ")
    EndIf
    RestArea(aAreaTMP)
EndIf

If (!empty(AllTrim(cSupplierID)))
    dbSelectArea("SA2")
    aAreaTMP := SA2->(GetArea())
    dbSetOrder(1)
    If MsSeek(xFilial("SA2")+cSupplierID+cLoja)
        cSupTaxGrp      := PADR(SA2->A2_GRPTRIB,GetSx3Cache("F51_GRPSUP","X3_TAMANHO")," ")
    EndIf
    RestArea(aAreaTMP)
EndIf 

If (!empty(AllTrim(cProductID)))
    dbSelectArea("SB1")
    aAreaTMP := SB1->(GetArea())
	dbSetOrder(1)
	If dbSeek(xFilial("SB1") + cProductID)
        cProdTaxGroup   := PADR(SB1->B1_GRTRIB,GetSx3Cache("F51_PRDGRP","X3_TAMANHO")," ")
        cB1Grupo        := SB1->B1_GRUPO
    EndIf
    RestArea(aAreaTMP)
    dbSelectArea("SBM")
    aAreaTMP := SBM->(GetArea())
	dbSetOrder(1)
    If dbSeek(xFilial("SBM") + cB1Grupo)
        cProdGrpType    := PADR(SBM->BM_TIPGRU,GetSx3Cache("F51_TPPRD","X3_TAMANHO"), " ")
    EndIf
    RestArea(aAreaTMP)
EndIf

// Search for a Smart TIO code that matches the conditions.
cRulesKey := Space(GetSx3Cache("F50_CODE","X3_TAMANHO"))
If  !Empty(cProdTaxGroup) .and. !Empty(cProdGrpType) .and. !(Empty(cSupTaxGrp) .and. Empty(cCusTaxGrp)) .and. !IsBlind()
    //cProdTaxGroup and cProdGrpType MUST be filled, one of cSupTaxGrp and cCusTaxGrp CAN be empty.
    cSupTaxGrp := IIf(Empty(cSupTaxGrp),Space(GetSx3Cache("F51_GRPSUP","X3_TAMANHO")),cSupTaxGrp)
    cCusTaxGrp := IIf(Empty(cCusTaxGrp),Space(GetSx3Cache("F51_GRPCUS","X3_TAMANHO")),cCusTaxGrp)
    cQuery := " SELECT F50.F50_CODE         F50_CODE                           "
    cQuery += " FROM                                                           "
    cQuery += "     ( SELECT F51.F51_KEY    F51_KEY                            "
    cQuery += "       FROM     " + RetSqlName("F51") + " F51                   "
    cQuery += "       WHERE  F51.F51_FILIAL  = '" + xFilial("F51") + "'        "
    cQuery += "          AND F51.F51_PRDGRP  = '" + cProdTaxGroup  + "'        "
    cQuery += "          AND F51.F51_TPPRD   = '" + cProdGrpType   + "'        "
    cQuery += "          AND (F51.F51_GRPSUP = '" + cSupTaxGrp     + "'        "
    cQuery += "               OR                                               "
    cQuery += "               F51.F51_GRPCUS = '" + cCusTaxGrp     + "'        "
    cQuery += "              )                                                 "
    cQuery += "          AND F51.D_E_L_E_T_  = ' '                     )   F51 "
    cQuery += " INNER JOIN                                                     "
    cQuery += "     ( SELECT F50.F50_CODE   F50_CODE,                          "
    cQuery += "              F50.F50_KEY    F50_KEY                            "
    cQuery += "       FROM     " + RetSqlName("F50") + " F50                   "
    cQuery += "       WHERE  F50.F50_FILIAL  = '" + xFilial("F50") + "'        "
    cQuery += "          AND F50.D_E_L_E_T_  = ' '                     )   F50 "
    cQuery += " ON F51.F51_KEY = F50.F50_KEY                                   "
    cQuery := ChangeQuery(cQuery)
    cAlias := MPSysOpenQuery(cQuery)
    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())
    If !Eof()
        cRulesKey := (cAlias)->F50_CODE
        DbSkip() // go to next line, if we have only one line, eof() must return .T.
    EndIf
    If !Eof() //we have more than one line, so we make cRulesKey empty again
        // https://jiraproducao.totvs.com.br/browse/RULOC-2954
        cRulesKey := Space(GetSx3Cache("F50_CODE","X3_TAMANHO"))
    EndIf
    (cAlias)->(DBCloseArea())
EndIf

RestArea(aArea)

/*
    Call the field validation functions manually, 
    because when values put into the field by trigger, 
    validation doesn't start automatically.
*/
If !Empty(cRulesKey)
    If (IsInCallStack("MATA121"))
        M->C7_OPER   := cRulesKey
        RUSmtCd(1,cRulesKey)
        RUSmtTio(1,cRulesKey)
    ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))
        M->C6_OPER   := cRulesKey
    ElseIf (IsInCallStack("CNTA300RUS")) 
        If (IsInCallStack("CN300ALTER"))
            lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'),oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO'))
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_OPER",cRulesKey)
            If lCompra
                RUSmtCd(1,cRulesKey)
                RUSmtTio(1,cRulesKey)  
            Else
                RUSmtCd(2,cRulesKey)
                RUSmtTio(2,cRulesKey)  
            EndIf
        ElseIf (IsInCallStack("CN300InCOM")) 
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_OPER",cRulesKey)
            RUSmtCd(1,cRulesKey)
            RUSmtTio(1,cRulesKey)  
        ElseIf (IsInCallStack("CN300InVEN")) 
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_OPER",cRulesKey)
        EndIf
    ElseIf (IsInCallStack("CNTA121RUS")) 
        oModel:GetModel("CNEDETAIL"):SetValue("CNE_OPER",cRulesKey)
        RUSmtTio(Iif(CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA")),1,2),cRulesKey)
        RUSmtCd(Iif(CN300RetSt("COMPRA",0,oModel:GetModel('CXNDETAIL'):GetValue('CXN_NUMPLA'),oModel:GetModel("CNDMASTER"):GetValue("CND_CONTRA")),1,2),cRulesKey)
    ElseIf (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N") .OR. cNFEspecie == "NCC")
        M->D1_OPER   := cRulesKey
        RUSmtCd(1,cRulesKey)
        RUSmtTio(1,cRulesKey)
    ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == "NDC")
        M->D2_OPER   := cRulesKey 
        RUSmtCd(2,cRulesKey)
        RUSmtTio(2,cRulesKey)
    EndIf
ElseIf IsBlind()
    RUSmtCd(Iif(cNFOperNF == "E",1,2),cRulesKey)
    RUSmtTio(Iif(cNFOperNF == "E",1,2),cRulesKey)
Else
    If (IsInCallStack("MATA121"))
        MaFisRef("IT_TES","MT120",CriaVar("C7_TES"))
    ElseIf (IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N"))
        MaFisRef("IT_TES","MT100",CriaVar("D1_TES")) 
    EndIf
EndIf

Return cRulesKey


/*/{Protheus.doc} RUSmtTio
Function to return TIO Code
@author Konstantin Cherchik
@since 04/16/2018
@version P12.1.20
@type function
/*/
Function RUSmtTio(nOperType,cSmartCode)
Local cCurField     as Character
Local cCodeTIO      as Character
Local cCNBOper      as Character
Local cCNEOper      as Character
Local cNFTipoNF     as Character
Local cNFOperNF     as Character
Local cNFEspecie    as Character
Local aAreaF50	    as Array
Local aArea         as Array
Local lRet          as Logical
Local lCompra       as Logical
Local oModel        as Object

DEFAULT nOperType   := 0
DEFAULT cCodeTIO    :=  Space(TamSX3("F50_TI")[1])

aArea           := GetArea()
aAreaF50	    := F50->(GetArea())
lRet            := .T.

cNFTipoNF := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie:= Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

/* If validation function was called automatically, we need to store Operation tipe value. */

If (empty(AllTrim(cSmartCode)) .and. (!empty(M->C7_OPER)))
    cSmartCode := M->C7_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->D1_OPER)))
    cSmartCode := M->D1_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->C6_OPER)))
    cSmartCode := M->C6_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->D2_OPER)))
    cSmartCode := M->D2_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. ((IsInCallStack("CN300InCOM")) .Or. (IsInCallStack("CN300InVEN")) .Or. (IsInCallStack("CN300ALTER"))))

    oModel      := FWModelActive()
    cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

    If (!empty(cCNBOper) .and. !empty(M->CNB_OPER))
        cSmartCode := M->CNB_OPER 
    EndIf

ElseIf (empty(AllTrim(cSmartCode)) .and. (IsInCallStack("CNTA121RUS")))

    oModel      := FWModelActive()
    cCNEOper    := AllTrim(oModel:GetValue('CNEDETAIL','CNE_OPER'))

    If (!empty(cCNEOper) .and. !empty(M->CNE_OPER))
        cSmartCode := M->CNE_OPER 
    EndIf

EndIf 

If (!empty(AllTrim(cSmartCode)))

    dbSelectArea("F50")
    dbSetOrder(2)
    dbSeek(xFilial("F50")+cSmartCode)
    While(F50->(!Eof()) .And. xFilial("F50")+cSmartCode=xFilial("F50")+F50->F50_CODE)  
        If (nOperType == 1)
            cCodeTIO := F50->F50_TI
        ElseIf (nOperType == 2)
            cCodeTIO := F50->F50_TO
        EndIf
        If(!Empty(cCodeTIO))
            Exit
        EndIf
        F50->(DbSkip())
    EndDo
EndIf 

/*
    Because the validation function puts value of cCodeTIO in the fields automatically,
    it is need to simulate entering these values, as if they were inserted manually.
    To run validation of these fields.
*/
If lRet

    cCurField := __ReadVar
    SX3->(dbSetOrder(2))

    If (IsInCallStack("MATA121"))
        __ReadVar := "C7_OPER"
        If SX3->(dbSeek("C7_TES "))
            cCurField   := "M->C7_TES"
            M->C7_TES   := cCodeTIO
            __ReadVar   := cCurField
            &(SX3->X3_VALID)    
            MaFisAlt("IT_TES", cCodeTIO, N)
        EndIf

        __ReadVar   := "C7_PRODUTO"
    ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))
        __ReadVar := "C6_OPER"
        If SX3->(dbSeek("C6_TES "))
            cCurField   := "M->C6_TES"
            M->C6_TES   := cCodeTIO
             __ReadVar   := cCurField
            &(SX3->X3_VALID)
            MaFisAlt("IT_TES", cCodeTIO, N)
        
        EndIf

        __ReadVar   := "C6_PRODUTO"
    ElseIf (IsInCallStack("CNTA300RUS"))

        If (IsInCallStack("CN300ALTER"))
            oModel      := FWModelActive()
            lCompra	    := CN300RetSt("COMPRA",0,oModel:GetModel('CNADETAIL'):GetValue('CNA_NUMERO'),oModel:GetModel('CN9MASTER'):GetValue('CN9_NUMERO'))
            
            If lCompra
                oModel:GetModel("CNBDETAIL"):SetValue("CNB_TE",cCodeTIO)
            Else
                oModel:GetModel("CNBDETAIL"):SetValue("CNB_TS",cCodeTIO)
            EndIf

        ElseIf (IsInCallStack("CN300InCOM")) 

            oModel      := FWModelActive()
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_TE",cCodeTIO)

        ElseIf (IsInCallStack("CN300InVEN")) 

            oModel      := FWModelActive()
            oModel:GetModel("CNBDETAIL"):SetValue("CNB_TS",cCodeTIO)

        EndIf
    ElseIf (IsInCallStack("CNTA121RUS")) 

        oModel      := FWModelActive()
        oModel:GetModel("CNEDETAIL"):SetValue("CNE_TES",cCodeTIO)
        oModel:GetModel("CNEDETAIL"):LoadValue("CNE_TES",cCodeTIO)

    ElseIf (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N") .OR. cNFEspecie == "NCC")
        If !IsBlind()
            __ReadVar := "D1_OPER"
            If SX3->(dbSeek("D1_TES "))
                cCurField   := "M->D1_TES"
                M->D1_TES   := cCodeTIO
                __ReadVar   := cCurField
                &(SX3->X3_VALID)    
                MaFisAlt("IT_TES", cCodeTIO, N)
            __ReadVar   := "D1_COD"
            EndIf
        Else    // (02/10/19): Seek value in autogeneration array  
            cCodeTIO := RU09XFUN01_ValueByField("D1_TES")
            MaFisAlt("IT_TES", cCodeTIO, N)
        EndIf
    
    ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == "NDC")
        If !IsBlind()
            __ReadVar := "D2_OPER"
            If SX3->(dbSeek("D2_TES "))
                cCurField   := "M->D2_TES"
                M->D2_TES   := cCodeTIO
                __ReadVar   := cCurField
                &(SX3->X3_VALID)
                MaFisAlt("IT_TES", cCodeTIO, N)
            EndIf
            __ReadVar   := "D2_COD"
        Else    // (02/10/19): Seek value in autogeneration array
            cCodeTIO := RU09XFUN01_ValueByField("D2_TES")
            MaFisAlt("IT_TES", cCodeTIO, N)
        EndIf
    EndIf

EndIf

RestArea(aAreaF50)
RestArea(aArea)

Return (cCodeTIO)


/*/{Protheus.doc} RUSmtCd
Function to return VAT Code 
@author Konstantin Cherchik
@since 04/16/2018
@version P12.1.20
@type function
/*/ 
Function RUSmtCd(nOperType,cSmartCode)
Local cCurField     as Character                                
Local cCodeVAT      as Character
Local cCNBOper      as Character
Local cCNEOper      as Character
Local cNFTipoNF     as Character
Local cNFOperNF     as Character
Local cNFEspecie    as Character
Local lRet          as Logical
Local aAreaF50      as Array
Local aArea         as Array
Local oModel        as Object

DEFAULT nOperType   := 0 
DEFAULT cCodeVAT    :=  Space(TamSX3("F50_VCI")[1])

aArea           := GetArea()
aAreaF50	    := F50->(GetArea())
lRet            := .T.

cNFTipoNF := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie:= Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

If (empty(AllTrim(cSmartCode)) .and. (!empty(M->C7_OPER))) 
    cSmartCode := M->C7_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->D1_OPER)))
    cSmartCode := M->D1_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->C6_OPER)))
    cSmartCode := M->C6_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. (!empty(M->D2_OPER)))
    cSmartCode := M->D2_OPER
ElseIf (empty(AllTrim(cSmartCode)) .and. ((IsInCallStack("CN300InCOM")) .Or. (IsInCallStack("CN300InVEN")) .Or. (IsInCallStack("CN300ALTER"))))

    oModel      := FWModelActive()
    cCNBOper    := AllTrim(oModel:GetValue('CNBDETAIL','CNB_OPER'))

    If (!empty(cCNBOper) .and. !empty(M->CNB_OPER))
        cSmartCode := M->CNB_OPER
    EndIf
ElseIf (empty(AllTrim(cSmartCode)) .and. (IsInCallStack("CNTA121RUS")))

    oModel      := FWModelActive()
    cCNEOper    := AllTrim(oModel:GetValue('CNEDETAIL','CNE_OPER'))

    If (!empty(cCNEOper) .and. !empty(M->CNE_OPER))
        cSmartCode := M->CNE_OPER 
    EndIf
EndIf

If (!empty(AllTrim(cSmartCode)))

    dbSelectArea("F50")
    dbSetOrder(2)    
    dbSeek(xFilial("F50")+cSmartCode)
    While(F50->(!Eof()) .And. xFilial("F50")+cSmartCode=xFilial("F50")+F50->F50_CODE)
        If (nOperType == 1) 
            cCodeVAT := F50->F50_VCI 
        ElseIf (nOperType == 2)
            cCodeVAT := F50->F50_VCO
        EndIf
        If(!Empty(cCodeVAT))
            Exit
        EndIf
        F50->(DbSkip())
    EndDo
EndIf

/*
    Because the validation function puts value of cCodeTIO in the fields automatically,
    it is need to simulate entering these values, as if they were inserted manually.
    To run validation of these fields.
*/
If lRet

    cCurField   := __ReadVar
    SX3->(dbSetOrder(2))    

    If (IsInCallStack("MATA121"))
        __ReadVar := "C7_OPER"
        If SX3->(dbSeek("C7_CF "))
            cCurField   := "M->C7_CF"
            M->C7_CF   := cCodeVAT
            __ReadVar   := cCurField           
            &(SX3->X3_VALID)   
            MaFisAlt("IT_CF", cCodeVAT, N) 
        EndIf

        __ReadVar   := "C7_PRODUTO"
    ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))
        __ReadVar := "C6_OPER"
        If SX3->(dbSeek("C6_CF "))
            cCurField   := "M->C6_CF"
            M->C6_CF   := cCodeVAT
            __ReadVar   := cCurField
            &(SX3->X3_VALID)
            MaFisAlt("IT_CF", cCodeVAT, N)
        EndIf

        __ReadVar   := "C6_PRODUTO"
    ElseIf ((IsInCallStack("CN300InCOM")) .Or. (IsInCallStack("CN300InVEN")) .Or. (IsInCallStack("CN300ALTER")))

        oModel := FWModelActive()
        oModel:GetModel("CNBDETAIL"):SetValue("CNB_CF",cCodeVAT)

    ElseIf (IsInCallStack("CNTA121RUS"))

        oModel := FWModelActive()
        oModel:GetModel("CNEDETAIL"):SetValue("CNE_CF",cCodeVAT)
    ElseIf (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N") .OR. cNFEspecie == "NCC")
        If !IsBlind()
            __ReadVar := "D1_OPER"
            If SX3->(dbSeek("D1_CF "))
                cCurField   := "M->D1_CF"
                M->D1_CF   := cCodeVAT
                __ReadVar   := cCurField
                &(SX3->X3_VALID)    
                MaFisAlt("IT_CF", cCodeVAT, N)
            EndIf
            __ReadVar   := "D1_COD"
        Else
            cCodeVAT := RU09XFUN01_ValueByField("D1_CF")
            MaFisAlt("IT_CF", cCodeVAT, N)
        EndIf
    ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == "NDC")
        If !IsBlind()
            __ReadVar := "D2_OPER"
            If SX3->(dbSeek("D2_CF "))
                cCurField   := "M->D2_CF"
                M->D2_CF   := cCodeVAT
                __ReadVar   := cCurField
                &(SX3->X3_VALID)
                MaFisAlt("IT_CF", cCodeVAT, N) 
            EndIF
            __ReadVar   := "D2_COD"
        Else
            cCodeVAT := RU09XFUN01_ValueByField("D2_CF")
            MaFisAlt("IT_CF", cCodeVAT, N)
        EndIf
    EndIf
EndIf

RestArea(aAreaF50)
RestArea(aArea)

Return (cCodeVAT)


/*/{Protheus.doc} RU09XFUNCFValid
Function for validation of C6_CF field in MATA410 
@author Konstantin Cherchik
@since 04/26/2018
@version P12.1.20
@type function
/*/ 
Function RU09XFUNCFValid(cFiscalCode)
Local nHOper    as Numeric
Local lRet      as Logical
Local cOperType as Character

DEFAULT lRet        := .F.
DEFAULT cOperType   := Space(TamSX3("F50_CODE")[1])

cOperType   := M->C6_OPER
If Empty(cOperType) .And. Type("aHeader") == "A" .And. Type("aCols") == "A"
    nHOper      := AScan(aHeader, {|x| AllTrim(x[2]) == "C6_OPER"})
    If !Empty(nHOper)
        cOperType   := aCols[N, nHOper] 
        M->C6_OPER  := cOperType
    EndIf
EndIf

If ((!(empty(AllTrim(cOperType))) .And. !(empty(AllTrim(cFiscalCode)))) .Or. ((empty(AllTrim(cOperType))) .And. (empty(AllTrim(cFiscalCode)))))
    lRet := .T.
EndIf

Return lRet


/*/{Protheus.doc} RU09XFUNHelp
The function of notifying the user,
to do not forget to check the tax codes after
he changed the supplier or the customer
@author Konstantin Cherchik
@since 04/26/2018
@version P12.1.20
@type function
/*/ 
Function RU09XFUNHelp() 
Local lRet          as Logical
Local cProductCode  as Character
Local cNFTipoNF     as Character
Local cNFOperNF     as Character
Local cNFEspecie    as Character
Local oModel        as Object

DEFAULT lRet           := .T.

cNFTipoNF := Iif(MaFisFound(), MaFisRet(, "NF_TIPONF"), "")
cNFOperNF := Iif(MaFisFound(), MaFisRet(, "NF_OPERNF"), "")
cNFEspecie:= Iif(MaFisFound(), MaFisRet(, "NF_ESPECIE"), "")

cProductCode := ""

If (IsInCallStack("MATA121"))

    cProductCode  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C7_PRODUTO')} )]


ElseIf (IsInCallStack("A410INCLUI") .Or. IsInCallStack("A410ALTERA") .Or. IsInCallStack("A410COPIA"))

    cProductCode  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('C6_PRODUTO')} )]

ElseIf (IsInCallStack("CNTA121RUS"))

    oModel  := FWModelActive() 

    cProductCode  := AllTrim(oModel:GetValue('CNEDETAIL','CNE_PRODUT'))    


ElseIf ((IsInCallStack("CN300InCOM")) .Or. (IsInCallStack("CN300InVEN"))  .Or. (IsInCallStack("CN300ALTER")))

    oModel  := FWModelActive() 

    cProductCode  := AllTrim(oModel:GetValue('CNBDETAIL','CNB_PRODUT'))
ElseIF (cNFOperNF == "E")//(IsInCallStack("MATA101N") .or. IsInCallStack("MATA102N") .OR. cNFEspecie == "NCC")

    cProductCode  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D1_COD')} )]

ElseIf (cNFOperNF == "S")//(IsInCallStack("MATA467N") .OR. IsInCallStack("MATA462N") .OR. cNFEspecie == "NDC")

    cProductCode  := aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == ('D2_COD')} )]

EndIf

If (!(empty(AllTrim(cProductCode))))

    MsgInfo(" " + STR0001  + " ")

EndIf

Return lRet


/*/{Protheus.doc} RU09XFUNCntType
The function to determine which
type of contract, purchase or sales contract.
    True  - Purchase
    False - Sales
Used in CNTA300, trigger for CNB_OPER.
@author Konstantin Cherchik
@since 08/27/2018
@version P12.1.21
@type function
@return Boolean
/*/ 

Function RU09XFUNCntType (cCNANumero, cCN9Numero)
Local lRet  as Logical
Local cType as Character
Local nMode as Numeric

DEFAULT lRet := .T.

cType := "COMPRA"
nMode := 0

lRet	    := CN300RetSt(cType,nMode,cCNANumero,cCN9Numero)

Return lRet


/*/{Protheus.doc} RU09XFUNWrapCntType
The support function for RU09XFUNCntType
to avoid the problem with 40 symbols
of x7_condic parameter in triggers.
Used in CNTA300, trigger for CNB_OPER.
@author Konstantin Cherchik
@since 08/27/2018
@version P12.1.21
@type function
@return RU09XFUNCntType()
/*/ 

Function RU09XFUNWrapCntType()

Return RU09XFUNCntType(FwFldGet("CNA_NUMERO"),FwFldGet("CN9_NUMERO"))


/*/{Protheus.doc} RU09XFUN01_ValueByField
Function returns value of filds from autogeneration array
@author Velmozhnya Alexandra
@since 03/10/2019
@version P12.1.27
@type function
@return Value of cField
/*/ 
Function RU09XFUN01_ValueByField(cField)
Local cRet      as Character    // Returned value 
Local nPos      as Numeric      // Position in aAutoItens

cRet := ''

If !Empty(cField)
    If ValType(aAutoItens) == "A" .and. !Empty(aAutoItens[1])
        nPos := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == (cField) } )
        cRet := Iif(nPos > 0 ,aAutoItens[n][nPos][2] , Space(TamSX3(cField)[1]))
    Else
        cRet := Space(TamSX3(cField)[1])
    EndIf
EndIf

Return cRet


Function RU09XFUN02_OpenCommercialinvoice(oView As Object, cType As Character)
Local lRet      as Logical
Local aArea     as Array
Local aAreaHead as Array
Local aAreaDet  as Array
Local aTmpMenu  as Array
Local oRootModel    as Object
Local oMdlHead  as Object
Local cDocSer   as Character

Private aRotina as Array

aArea := GetArea()
lRet := .T.

If (ValType(oView) != "O")
	lRet := .F.
EndIf

If (lRet)
    oRootModel := oView:GetModel():oFormModel
    lRet := lRet .and. RU05XFN010_CheckModel(oRootModel, "RU05D01")
EndIf

If (lRet)
oMdlHead := oRootModel:getModel("F5YMASTER")
Do Case
    Case cType == "B"
        cDocSer := oMdlHead:GetValue("F5Y_DOCORI") + oMdlHead:GetValue("F5Y_SERORI")
    Case cType == "I"
        cDocSer := oMdlHead:GetValue("F5Y_DOCDEB") + oMdlHead:GetValue("F5Y_SERDEB")
        lRet := lRet .and. !Empty(oMdlHead:GetValue("F5Y_DOCDEB"))
    Case cType == "D"
        cDocSer := oMdlHead:GetValue("F5Y_DOCCRD") + oMdlHead:GetValue("F5Y_SERCRD")
        lRet := lRet .and. !Empty(oMdlHead:GetValue("F5Y_DOCCRD"))
EndCase
EndIf

If (lRet)
    //if click was on before model record it is necessary to identify type of original document
    cType := Iif(oMdlHead:GetValue("F5Y_ORIGIN") == "2" .And. cType == "B","U",cType)

    aTmpMenu := AClone(aRotina)
    aRotina	:=	{{"","",0,2,0,Nil},;
                {"","",0,2,0,Nil},;
                {"","",0,2,0,Nil},;
                {"","",0,2,0,Nil}}

    Do Case
        Case cType $ "BI"
            aAreaHead := SF2->(GetArea())
            aAreaDet:= SD2->(GetArea())

            DbSelectArea("SF2")
            SF2->(DbSetOrder(1))
            
            If (SF2->(DbSeek(xFilial('SF2') + cDocSer + oMdlHead:GetValue("F5Y_CLIENT") + oMdlHead:GetValue("F5Y_BRANCH"))))
                CtbDocSaida()	// open View SF2/SD2
            EndIf
        Case cType == "D"
            aAreaHead := SF1->(GetArea())
            aAreaDet:= SD1->(GetArea())
            DbSelectArea("SF1")
            SF1->(DbSetOrder(1))
            
            If (SF1->(DbSeek(xFilial('SF1')+ cDocSer + oMdlHead:GetValue("F5Y_CLIENT") + oMdlHead:GetValue("F5Y_BRANCH"))))
                CtbDocEnt()	//open View of SF1/SD1
            EndIf
        Case cType == "U"
            aAreaHead := F5Y->(GetArea())
            aAreaDet:= F5Z->(GetArea())
            DBSelectArea("F5Y")
            DBSetOrder(2)
            If (F5Y->(DBSeek(FWxFilial("F5Y") + oMdlHead:GetValue("F5Y_CLIENT") + oMdlHead:GetValue("F5Y_BRANCH") +cDocSer)))
                FWExecView(STR0002,"RU05D01",MODEL_OPERATION_VIEW) //"Unified Logistics Correction Document"
            EndIf
    EndCase
    RestArea(aAreaDet)
    RestArea(aAreaHead)

    aRotina := AClone(aTmpMenu)
EndIf
RestArea(aArea)
Return Nil


/*/{Protheus.doc} RU09XFUN03_F35_TYPE_ComboBox
Returns combobox for F35_TYPE field
@author Ivanov Alexander
@since 05/02/2019
@version P12.1.27
@type function
@return combobox
/*/ 
Function RU09XFUN03_F35_TYPE_ComboBox()
    Local aItems as Array
	aItems := {STR0003, STR0004, STR0005, STR0006, STR0007, STR0014}
Return RU99XFUN04_MakeCombo(aItems)

/*/{Protheus.doc} RU09XFUN05_ViewCanActivate
Make common changes for oView object for VAT routines.
@author artem.kostin
@since 30.03.2020
@version P12.1.30
@type	function
@return	lRet, process flow control
/*/ 
Function RU09XFUN05_ViewCanActivate(oView as Object)
// Process control
Local lRet			as logical
// Operation number
Local nOperation	as Numeric
// model object
Local oModel		as Object
Local cModelId		as Character
// view structures
Local oStructF35	as Object
Local oStructF36	as Object
Local oStructF5P	as Object
// arrays of removed fields
Local aRmF35		as Array
Local aRmF36		as Array
Local aRmF5P		as Array

lRet		:= .T.
nOperation	:= oView:GetOperation()
oStructF35	:= oView:GetViewStruct("F35_M")
oStructF36	:= oView:GetViewStruct("F36_D")
oStructF5P	:= oView:GetViewStruct("F5P_D")

aRmF35		:= {"F35_IDATE ", "F35_CURR  ", "F35_VATVL ", "F35_VALGR ", "F35_VATBS ", "F35_VATCOD", "F35_VATVL1", "F35_VATBS1", "F35_BOOKEY", "F35_CONTRA"}
aRmF36		:= {"F36_FILIAL", "F36_KEY   ", "F36_DOCKEY", "F36_TYPE  ", "F36_DOC   ", "F36_EXC_V1", "F36_VATVS1", "F36_EXC_V1", "F36_DTLA  ", "F36_INVCUR", "F36_CLIENT", "F36_BRANCH"} //F36_INVDOC;F36_INVSER;F36_DESC"
aRmF5P		:= {"F5P_KEY   "}

RU09XFUN06_RemoveFields(oStructF35, aRmF35)
RU09XFUN06_RemoveFields(oStructF36, aRmF36)
RU09XFUN06_RemoveFields(oStructF5P, aRmF5P)

oModel := oView:GetModel()
lRet := lRet .and. RU05XFN010_CheckModel(oModel, oModel:GetId())
If (lRet .and. !(cModelId $ "RU09T07"))
	RU09XFUN06_RemoveFields(oStructF35, {"F35_VTCD2D", "F35_SAVEPB"})
EndIf

If (nOperation == MODEL_OPERATION_INSERT)
	// removes fields from F35 structure
	oStructF35:RemoveField("F35_DOC")
	oStructF35:RemoveField("F35_BOOK")
	// removes fields from F36 structure
	oStructF36:RemoveField("F36_DOC")
EndIf
Return lRet

/*/{Protheus.doc} RU09XFUN06_RemoveFields
Removes fields by name from array from the given structure.
@author artem.kostin
@since 30.03.2020
@version P12.1.30
@type	function
@return	lRet, process flow control
/*/ 
Function RU09XFUN06_RemoveFields(oStruct as Object, aFields as Array)
// iterators
Local nI	as Numeric

If (ValType(oStruct) == "O")
	For nI := 1 to len(aFields)
		oStruct:RemoveField(aFields[nI])
	Next nI
EndIf
Return

/*{Protheus.doc} RU09XFUN07_F35_CONUNI_ComboBox
@description Use conventional units (Yes\No) combobox creation
@author alexander.ivanov
@since 26/05/2020
@version 1.0
@project MA3 - Russia
*/
Function RU09XFUN07_F35_CONUNI_ComboBox()
    Local aItems as Array
	aItems := {STR0008, STR0009}
Return RU99XFUN04_MakeCombo(aItems)



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09XFUN08_ClsTaxRate 
    old RUXXNF201_ClsTaxRate
Function takes TaxAmount, TaxBase, calculates:
CalcTaxRate = (TaxAmount/TaxBase)*100 and look for closest Tax rate 
to CalcTaxRate in F30 table, and returns Tax rate from F30 table.
TaxRates with  "/" like 18/118 or 10/110 will be passed during search
process
Function returns 0 in next cases:
1) We found closest tax rate equls to 0
2) nTaxBase == 0 or input parameters are not NUMERIC
3) F30_RATE field doesn't contain a value which we can convert to NUMERIC
4) F30 table is empty

@param       NUMERIC nTaxAmnt {0..max}
             NUMERIC nTaxBase {0..max}
@return      NUMERIC nRet     {0..max}
@example     
@author      astepanov
@since       November/15/2018
@version     1.0
@project     MA3
@see         FI-CF-23-5 (3.2.3)
/*/
//-----------------------------------------------------------------------
Function RU09XFUN08_ClsTaxRate(nTaxAmnt,nTaxBase)

	Local   nRet     AS NUMERIC
	Local   CalTxRat AS NUMERIC
	Local   TaxRate  AS NUMERIC
	Local   aAreaF30 AS ARRAY
	Local   Differ   AS NUMERIC
	Default nTaxAmnt := 0
	Default nTaxBase := 1

	If VALTYPE(nTaxAmnt) == "N" .and.;
	VALTYPE(nTaxBase) == "N" .and.;
	nTaxBase          != 0

		CalTxRat := (nTaxAmnt / nTaxBase) * 100
		nRet := 0
		Differ := 99999999 //8 characters

		aAreaF30 := F30->(GetArea())
		DbSelectArea("F30")
		F30->(DbSetOrder(1))
		F30->(DbGoTop())

		While ! F30->(EoF())
			If "/" $ F30->F30_RATE 
				F30->(DbSkip())
				Loop
			Else
				TaxRate := VAL(F30->F30_RATE)
				If Abs(TaxRate - CalTxRat) < Differ
					Differ := Abs(TaxRate - CalTxRat)
					nRet   := TaxRate
				EndIf
			EndIf
		F30->(DbSkip())
		EndDo

		RestArea(aAreaF30)
	Else
		nRet := 0
	EndIf

Return nRet




//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09XFUN09_Aux_mata461TaxSC6_TO_SD2 
Auxiliary function responsible for transporting values from tax fields positioned in table SC6 to table SD2 in Russian font due to the request of the product owner

@param       
             
@return      
@example     
@author      eduardo.Flima
@since       14/12/2020
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------
Function RU09XFUN09_Aux_mata461TaxSC6_TO_SD2()
	SD2->D2_ALQIMP1  := SC6->C6_ALQIMP1
	SD2->D2_BASIMP1  := SC6->C6_BASIMP1
	SD2->D2_VALIMP1  := SC6->C6_VALIMP1
Return .T.



//-----------------------------------------------------------------------
/*/{Protheus.doc} RU09XFN011_X7_condic_check
Function for trigger to field D1_TOTAL in D1_QUANT and D1_VUNIT
@param cFieldA, cFieldB -- fiekd names      
             
@return GdFieldGet(cFieldA)*GdFieldGet(cFieldB)>0     
@example     
@author      eradchinskii
@since       20/12/2022
@version     1.0
@project     MA3
/*/
//-----------------------------------------------------------------------

Function RU09XFN011_X7_condic_check(cFieldA, cFieldB)

Return GdFieldGet(cFieldA) * GdFieldGet(cFieldB) > 0


/*/{Protheus.doc} RU09XFN012_Protect_Invoice_Generation
    Method responsiple to use a468nFatura inside a transaction to avoid have data storedn when the operation is canceled
    @type  Function
    @author eduardo.Flima
    @since 23/03/2023
    @version 23/03/2023
    @param cAlias       , Character , Alias fof the FIle
    @param aParams      , Array     , Array of the parameters
    @param lAutPrep     , Logical   , If it is an automatic prepayment
    @see (links_or_references)
/*/
Function RU09XFN012_Protect_Invoice_Generation(cAlias,aParams,lAutPrep)
    Local lDisarm :=.F.

    Default lAutPrep := .F.
    Begin Transaction
        a468nFatura(cAlias,aParams,,,,,,,,,lAutPrep,@lDisarm)
        If lDisarm
            DisarmTransaction()
        Endif 
    End Transaction
Return .T.

/*/{Protheus.doc} RU09XFN013_Remove_fields
    Remove fields from struct in window
    @type  Function
    @author ogalyandina
    @since 10/10/2023
    @version 2210
    @param  oSrtuct as Object , 
            cTabNam as Character, 
            aFields as Array of Characters
    @return oSrtuct
    /*/
Function RU09XFN013_Remove_fields(oSrtuct, cTabNam, aFields)
    Local nCnt := 0
    if VALTYPE( aFields ) == "A"
        FOR nCnt := 1 TO Len(aFields)
            oSrtuct:RemoveField(cTabNam + aFields[nCnt])
        NEXT
    Endif
Return oSrtuct

/*/{Protheus.doc} RU09XFN014_RetnunEntityData
@description Function to return Supplier/Customer codes, branchs, names and other stuff
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 24/10/2023
@param cTable, Character, Table alias
@param cField, Character, Field name or field name part
@return xRet,  Variant,   Returns the the date from the selected field
/*/
Function RU09XFN014_RetnunEntityData(cTable As Character, cField As Character) As Variant

    Local xRet  As Variant
    Local lType As Logical
    Local cSuCl As Character
    Local cSCBr As Character
    Local lInclusion As Logical 
    Local cPrefAlias as Character     

    cPrefAlias := iif(LEFT(cTable,1) == 'S' .and. len(cTable)==3,right(cTable,2),cTable)
    If Type('INCLUI') != "L"
        lInclusion :=.F.
    Else
         lInclusion :=  INCLUI
    EndIf

    cSuCl := ""
    cSCBr := "" 


    If cField $ "ADJDT"
        xRet := SToD("")
    Else
        xRet := ""
    EndIf

    If cTable == "F64"
        lType := F64->F64_TYPE == "1"

        If !Empty(F64->F64_KEY)
            If !lInclusion 
                If lType
                    If cField $ "ADJNR|INVCUR"
                        xRet := Posicione("F37", 3, xFilial("F37") + F64->F64_KEY, "F37_" + cField)
                    EndIf

                    If cField $ "SUCL|SUCLBR"
                        xRet := Posicione("F37", 3, xFilial("F37") + F64->F64_KEY, IIf(cField == "SUCL", "F37_FORNEC", "F37_BRANCH"))
                    EndIf

                    If cField == "SUCLNM"
                        cSuCl := Posicione("F37", 3, xFilial("F37") + F64->F64_KEY, "F37_FORNEC")
                        cSCBr := Posicione("F37", 3, xFilial("F37") + F64->F64_KEY, "F37_BRANCH")
                        xRet := Posicione("SA2", 1, xFilial("SA2") + cSuCl + cSCBr, "A2_NOME")
                    EndIf

                    If cField == "ADJDT"
                        xRet := Posicione("F37", 3, xFilial("F37") + F64->F64_KEY, "F37_ADJDT")
                    EndIf
                Else
                    If cField $ "ADJNR|INVCUR"
                        xRet := Posicione("F35", 3, xFilial("F35") + F64->F64_KEY, "F35_" + cField)
                    EndIf

                    If cField $ "SUCL|SUCLBR"
                        xRet := Posicione("F35", 3, xFilial("F35") + F64->F64_KEY, IIf(cField == 'SUCL', "F35_CLIENT", "F35_BRANCH"))
                    EndIf

                    If cField == "SUCLNM"
                        cSuCl := Posicione("F35", 3, xFilial("F35") + F64->F64_KEY, "F35_CLIENT")
                        cSCBr := Posicione("F35", 3, xFilial("F35") + F64->F64_KEY, "F35_BRANCH")
                        xRet := Posicione("SA1", 1, xFilial("SA1") + F64->F64_SUCL + F64->F64_SUCLBR, "A1_NOME")
                    EndIf

                    If cField == "ADJDT"
                        xRet := Posicione("F35", 3, xFilial("F35") + F64->F64_KEY, "F35_ADJDT")
                    EndIf
                EndIf
            EndIf
        EndIf
    ElseIf cTable == "F63"
        lType := F63->F63_TYPE == "1"

        If !Empty(F63->F63_KEY)
            If !lInclusion 
                If lType
                    If cField $ "ADJNR|INVCUR|C_RATE"
                        xRet := Posicione("F37", 3, xFilial("F37") + F63->F63_KEY, "F37_" + cField)
                    EndIf

                    If cField $ "SUCL|SUCLBR"
                        xRet := Posicione("F37", 3, xFilial("F37") + F63->F63_KEY, IIf(cField == "SUCL", "F37_FORNEC", "F37_BRANCH"))
                    EndIf

                    If cField == "SUCLNM"
                        cSuCl := Posicione("F37", 3, xFilial("F37") + F63->F63_KEY, "F37_FORNEC")
                        cSCBr := Posicione("F37", 3, xFilial("F37") + F63->F63_KEY, "F37_BRANCH")
                        xRet := Posicione("SA2", 1, xFilial("SA2") + cSuCl + cSCBr, "A2_NOME")
                    EndIf

                    If cField == "ADJDT"
                        xRet := Posicione("F37", 3, xFilial("F37") + F63->F63_KEY, "F37_ADJDT")
                    EndIf
                Else
                    If cField $ "ADJNR|INVCUR"
                        xRet := Posicione("F35", 3, xFilial("F35") + F63->F63_KEY, "F35_" + cField)
                    EndIf

                    If cField $ "SUCL|SUCLBR"
                        xRet := Posicione("F35", 3, xFilial("F35") + F63->F63_KEY, IIf(cField == 'SUCL', "F35_CLIENT", "F35_BRANCH"))
                    EndIf

                    If cField == "SUCLNM"
                        cSuCl := Posicione("F35", 3, xFilial("F35") + F63->F63_KEY, "F35_CLIENT")
                        cSCBr := Posicione("F35", 3, xFilial("F35") + F63->F63_KEY, "F35_BRANCH")
                        xRet := Posicione("SA1", 1, xFilial("SA1") + cSuCl + cSCBr, "A1_NOME")
                    EndIf

                    If cField == "ADJDT"
                        xRet := Posicione("F35", 3, xFilial("F35") + F63->F63_KEY, "F35_ADJDT")
                    EndIf
                EndIf
            EndIf
        EndIf
    ElseIf cTable == "F32"
        If cField == "F32_SUPNAM"
            xRet := Posicione("SA2", 1, xFilial("SA2") + F32->F32_SUPPL + F32->F32_SUPUN, "A2_NOME")
        ElseIf cField == "F32_CUSTNM"
            xRet := Posicione("SA1", 1, xFilial("SA1") + F32->F32_CUSTOM + F32->F32_CUSTUN, "A1_NOME")
        EndIf
    ElseIf cTable == "F34"
        If cField == "F34_SUPNAM"
            xRet := Posicione("SA2", 1, xFilial("SA2") + F34->F34_SUPPL + F34->F34_SUPUN, "A2_NOME")
        ElseIf cField == "F34_CUSTNM"
            xRet := Posicione("SA1", 1, xFilial("SA1") + F34->F34_CUSTOM + F34->F34_CUSTUN, "A1_NOME")
        EndIf
    ElseIf cTable == "F54"
        If cField == "F54_SUPNAM"
            xRet := Posicione("SA2", 1, xFilial("SA2") + F54->F54_SUPPL + F54->F54_SUPBRA, "A2_NOME")
        ElseIf cField == "F54_CLINAM"
            xRet := Posicione("SA1", 1, xFilial("SA1") + F54->F54_CLIENT + F54->F54_CLIBRA, "A1_NOME")
        EndIf
    ElseIf cTable == "F62"
        If cField == "F62_SUPNAM"
            xRet := Posicione("SA2", 1, xFilial("SA2") + F62->F62_SUPPL + F62->F62_SUPBRA, "A2_NOME")
        EndIf
    EndIf

Return(xRet)

/*/{Protheus.doc} RU09XFN015_ReturnTypesOfTitles
Filter allowed types of financial titles
@type Function
@author Fernando Nicolau
@project MA3 - Russia
@since 14/11/2023
/*/
Function RU09XFN015_ReturnTypesOfTitles() As Logical

    Local nI     As Numeric
    Local cVars  As Character
    Local cChave As Character
    Local nTamMv As Numeric

    Private nTam     As Numeric
    Private aCat     As Array
    Private MvRet    As Character
    Private MvPar    As Character
    Private cTitulo  As Character
    Private MvParDef As Character

    nI     := 0
    cVars  := ""
    cChave := ""
    nTamMv := 0

    nTam     := 0 
    aCat     := {}
    MvRet    := Alltrim(ReadVar())
    MvPar    := &(Alltrim(ReadVar()))
    cTitulo  := ""
    MvParDef := ""

    If IsInCallStack("RU09T03RUS")
        cVars := MVPAGANT + "|" + MV_CPNEG
    ElseIf IsInCallStack("RU09T02RUS")
        cVars := MVRECANT + "|" + MV_CRNEG
    EndIf

    nTam := 3
    cTitulo := STR0020 //"Types of financial titles"
    nTamMv := Len(&MvRet)

    SX5->(DbSetOrder(1))
    SX5->(DbSeek(XFilial("SX5") + "05"))

    While SX5->(!Eof()) .And. (xFilial("SX5") == SX5->X5_FILIAL .And. SX5->X5_TABELA == '05')
        cChave := AllTrim(SX5->X5_CHAVE)
        cChave := cChave + Space(TamSX3("E1_TIPO")[1] - Len(cChave))

        If cChave $ cVars
            MvParDef += cChave
            aAdd(aCat, cChave + " - " + AllTrim(SX5->(X5Descri())))
        EndIf

        SX5->(DbSkip())
    End

    //Options dialog
    f_Opcoes(@MvPar, cTitulo, aCat, MvParDef, 12, 49, .F., nTam)

    //Separates the return with ";"
    &MvRet := ""
    For nI := 1 To Len(MvPar)
        If !("*" $ SubStr(MvPar, nI, 3)) .And. !Empty(SubStr(MvPar, nI, 3))
            &MvRet  += SubStr(MvPar, nI, 3) + ";"
            nI += 2
        EndIf
    Next

    //Removes the last character
    &MvRet := SubStr(&MvRet, 1, Len(&MvRet) -1)
    &MvRet := PadR(&MvRet, nTamMv)

    //Sets the return to a private variable
    cRetSX505 := &MvRet

Return(.T.)

/*/{Protheus.doc} RU09XFN016_ValidTypeVAT
@description Function to valid the types of VAT - now it's a programm stub!
@type Static Function
@author Leandro Nunes
@project MA3 - Russia
@since 24/10/2023
/*/
Function RU09XFN016_ValidTypeVAT() 

Return(.T.)

/*/{Protheus.doc} RU09XFN017_ValidTypesOfTitles
@description Function to be used with the Standard Query to select the types of bills
@type Static Function
@author Eduardo Lima
@project MA3 - Russia
@since 18/11/2023
@param cOper, Character,  Model to be saved
@return lRet,  Logical, If saving process is ok
/*/
Function RU09XFN017_ValidTypesOfTitles(cOper As Character) As Logical

    Local aTypeNon As Array
    Local aReadVar As Array
    Local lRet     As Logical
    Local nX       As Numeric
    lOCAL cReadVar As Character
    Local cTitle   As Character
    Local cSoluc   As Character
    Local cHelp    As Character
    Local cFilter  As Character

    lRet     := .T.
    cReadVar := &(AllTrim(ReadVar()))
    aReadVar := Separa(cReadVar, ";")
    nx       := 0
    aTypeNon := {}
    cTitle   := ""
    cSoluc   := ""
    cHelp    := ""

    If cOper = "P"
        cFilter := MVPAGANT + "|" + MV_CPNEG
    Else
        cFilter := MVRECANT + "|" + MV_CRNEG
    EndIf
    cFilter := StrTran(cFilter, " ", "") // clear empty spaces 

    for nX := 1 To Len(aReadVar)
        If !AllTrim(aReadVar[nX]) $ cFilter
            aAdd(aTypeNon, AllTrim(aReadVar[nX])) 
        EndIf
    Next

    If Len(aTypeNon) > 0
        cTitle := STR0015 // "Type Of Bill Not Found"
        If Len(aTypeNon)== 1
            cHelp := STR0016 // "Type"
            cHelp += " " + aTypeNon[1] + " "
        Else
            cHelp := STR0017 + CRLF // "Types"
            for nX := 1 to Len(aTypeNon)
                cHelp += " " + aTypeNon[nX] + " " + CRLF 
            Next
        EndIf
        cHelp += STR0018 // "Not found for this operation!"
        cSoluc := STR0019 // "Choose a valid type of bill for this operation"
        lRet := .F.
        Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,, {cSoluc})
    EndIf 
     
Return(lRet)

/*/{Protheus.doc} RU09XFN018_VldParTo
Valid if a parameter is filled with zzz or ЯЯЯ
@type function
@author Eduardo Lima
@since 18/11/2023
@param cParam   , Character , Item to be validated as default is the readvar()
@return logical, return_description
/*/
Function RU09XFN018_VldParTo(cParam as Character) As Logical

    Local lRet As Logical
    Local cLatin As Character
    Local cCiril As Character
    
    Default cParam := &(ReadVar())

    cLatin := Replicate('Z', (Len(AllTrim(cParam))))
    cCiril := Replicate(CHR(223), (Len(AllTrim(cParam))))//cirilic for ЯЯЯ

    lRet := Upper(AllTrim(cParam)) == cLatin .Or. Upper(AllTrim(cParam)) == cCiril

Return lRet

/*/{Protheus.doc} RU09XFN019_VldParKeyF3
Validates whether the record entered in the parameter exists
@type function
@author Fernando Nicolau
@since 08/12/2023
@param cField, character, Field in which the parameter content will be searched
@return logical, Indicates whether the parameter content is valid or not
/*/
Function RU09XFN019_VldParKeyF3(cField As Character) As Logical

    Local lRet          As Logical
    Local cAlias        As Character
    Local cQuery        As Character
	Local cAlQuery      As Character
    Local cTitle        As Character
    Local cHelp         As Character
    Local cSoluc        As Character
    Local cPrefAlias    As Character
    lRet     := .F.
    cAlias   := ""
    cQuery   := ""
    cAlQuery := GetNextAlias()
    cTitle   := ""
    cHelp    := ""
    cSoluc   := ""
    cPrefAlias := "" 

    cAlias := GetSX3Cache(cField, "X3_ARQUIVO")
    cPrefAlias := iif(LEFT(cAlias,1) == 'S' .and. len(calias)==3,right(calias,2),cAlias)
	cQuery := "SELECT " + CRLF
	cQuery += " COUNT(*) SOMA " + CRLF
	cQuery += "FROM " + CRLF
	cQuery += "    " + RetSqlName(cAlias) + " T1 " + CRLF
	cQuery += "WHERE "  + CRLF
	cQuery += "    T1." + cPrefAlias + "_FILIAL = '" + xFilial(cAlias) + "' AND " + CRLF
	cQuery += "    T1." + cField + " = '" + &(ReadVar()) + "' AND " + CRLF
	cQuery += "    T1.D_E_L_E_T_ = ' ' " + CRLF

    cQuery := ChangeQuery(cQuery)

	If Select(cAlQuery) > 0
		(cAlQuery)->(DbCloseArea())
	EndIf
	DbUseArea(.T., 'TOPCONN', TCGENQRY(,, cQuery), cAlQuery, .F., .T.)
	If (cAlQuery)->SOMA > 0
		lRet := .T.
    Else
        cTitle  := cField + " " + STR0021   //NOT FOUND
        cHelp   := STR0022 + " " + &(ReadVar()) + " " + STR0023 + " " + cField + " " + STR0024 + " " + cAlias //Value - Not found for the field - In the table
        cSoluc  := STR0025 + " " + cField //Please choose a valid value for the field
        Help(Nil, Nil, cTitle, Nil, cHelp, 1, 0,,,,,, {cSoluc})
	EndIf
	(cAlQuery)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} RU09XFN020_VldParKeyF3_with_previows_key
    Valid a value in determinated table that need a previows value in the key like SX5
    @type  Function
    @author eduardo.Flima
    @since 09/12/2023
    @version 09/12/2023
    @param cTable   , Character , Table to be validated
    @param cKeyPrev , Character , Previows key to be added in the search
    @param cParam   , Character , Item to be validated as default is the readvar()
    @return lRet    , Logical, If it is valid
/*/
Function RU09XFN020_VldParKeyF3_with_previows_key(cTable As Character, cKeyPrev As Character, cParam As Character) As Logical
    Local lRet As Logical
    
    Default cParam := &(Readvar())

    lRet := ExistCpo(cTable, cKeyPrev + cParam)

Return lRet

/*/{Protheus.doc} RU09XFN021_WriteHead
Writes the titles of details data exported from Sales/Purcheses Books
@type function  
@author Eduardo Lima
@since 16/01/2024
@param nHandle, numeric, Handle file number
@param aStruct, array, Table Struct
/*/
Function RU09XFN021_WriteHead(nHandle As Numeric, aStruct As Array)
	Local nX 		As Numeric
	Local cString 	As Character
	Local aArea  	As Array
	Local aAreaSX3  As Array

	aArea := GetArea()
	aAreaSX3 := SX3->(GetArea())
	cString := ""

	For nX := 1 To Len(aStruct)
		cString += AllTrim(Posicione("SX3", 2, aStruct[nX, 1], "X3Titulo()")) + ";"
	Next nX
	FWrite(nHandle, cString + CRLF)

	RestArea(aAreaSX3)
	RestArea(aArea)
Return

/*/{Protheus.doc} RU09XFN022_WriteData
Writes details data exported from Sales/Purcheses Books
@type function
@author Eduardo Lima
@since 16/01/2024
@param nHandle, numeric, Handle file number
@param aStruct, array, Table Struct
@param cTable, character, Table
@param cMessage, character, Message for IncProc
/*/
Function RU09XFN022_WriteData(nHandle As Numeric, aStruct As Array, cTable As Character, cMessage As Character)
	Local cString	As Character
	Local cField	As Character
	Local cType		As Character
	Local nX		As Numeric
	Local cNumType 	As Character
	Local cDateType	As Character
	
	cDateType := "D"
	cNumType := "N"
	cString := ""

	For nX := 1 To Len(aStruct)
		cField := aStruct[nX, 1]
		cType := aStruct[nX, 2]

		If (cType == cNumType)
			cString += StrTran(STR(&(cTable + "->" + cField)), '.', ',') + ";"
		ElseIf (cType == cDateType)
			cString += DtoC(&(cTable + "->" + cField)) + ";"
		Else
			cString += &(cTable + "->" + cField) + ";"
		EndIf
	Next nX
	FWrite(nHandle, cString + CRLF)
	IncProc(cMessage + StrZero(nX, 10))
Return 


/*/{Protheus.doc} RU09XFN023_AdvancesVATSqlQuery
Generic Select Query for VAT Advances
@type function
@author Fernando Nicolau
@since 08/01/2024
@param oSubModel, object, Submodel
@return character, Query
/*/
Function RU09XFN023_AdvancesVATSqlQuery(oSubModel As Object)

	Local cQuery As Character
	Local nLine As Numeric
    Local cTabFK As Character
    Local cTabVAT As Character
    Local cTabVATDet As Character
    Local cAdvType As Character
    Local cTabSupCli As Character
    Local cAliasFin As Character
    Local cFldSupCli As Character
    Local cTabVATAdv as Character

    If oSubModel:GetId() $ __PDETAIL
        cTabFK := "FK2"
        cTabVAT := "F37"
        cTabVATDet := "F38"
        cAdvType := "3"
        cTabSupCli := "SA2"
        cAliasFin := "SE2"
        cFldSupCli := "_FORNEC"
    ElseIf oSubModel:GetId() $ __RDETAIL
        cTabFK := "FK1"
        cTabVAT := "F35"
        cTabVATDet := "F36"
        cAdvType := "6"
        cTabSupCli := "SA1"
        cAliasFin := "SE1"
        cFldSupCli := "_CLIENT"
    EndIf
    cTabVATAdv := left(oSubModel:GetId(),3)

	cQuery := "SELECT "
	cQuery += "	" + cTabFK + "." + cTabFK + "_DATA, "
	cQuery += "	" + cTabFK + "." + cTabFK + "_SEQ, "
	cQuery += "	" + cTabFK + "." + cTabFK + "_HISTOR, "
    cQuery += "	" + cTabFK + "." + cTabFK + "_ID" + cTabFK + ", "
    cQuery += "	SUM(" + cTabFK + "." + cTabFK + "_VLMOE2) " + cTabFK + "_VLMOE2, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_DOC, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_PDATE, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_KEY, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_INVSER, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_INVDOC, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + cFldSupCli + ", "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_BRANCH, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_INVCUR, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_ADJNR, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_ADJDT, "
    cQuery += "	" + cTabVAT + "." + cTabVAT + "_C_RATE, "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_VATCOD, "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_VATCD2, "
	cQuery += "	SUM(" + cTabVATDet + "." + cTabVATDet + "_VATVL1) " + cTabVATDet + "_VATVL, "
	cQuery += "	SUM(" + cTabVATDet + "." + cTabVATDet + "_VATVL1 + " + cTabVATDet + "." + cTabVATDet + "_VATBS1) " + cTabVATDet + "_VALGR, "
	cQuery += "	SUM(" + cTabVATDet + "." + cTabVATDet + "_VATBS1) " + cTabVATDet + "_VATBS, "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_VATRT, "

    If oSubModel:GetId() $ __PDETAIL
        cQuery += " " + cTabSupCli + ".A2_NOME, "
    ElseIf oSubModel:GetId() $ __RDETAIL
        cQuery += " " + cTabSupCli + ".A1_NOME, "
    EndIf

	cQuery += "	" + cTabVAT + "." + cTabVAT + "_INVDT, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_CNEE_B, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_CNOR_C, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_CNOR_B, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_CNEE_C "
	cQuery += "FROM "
	cQuery += "	" + RetSQLName(cTabVAT) + " " + cTabVAT + " "
	cQuery += "LEFT JOIN " + RetSQLName(cTabVATDet) + " " + cTabVATDet + "  "
	cQuery += " ON "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_FILIAL = " + cTabVAT + "." + cTabVAT + "_FILIAL "
	cQuery += "	AND " + cTabVATDet + ".D_E_L_E_T_ = ' ' "
	cQuery += "	AND " + cTabVATDet + "." + cTabVATDet + "_KEY = " + cTabVAT + "." + cTabVAT + "_KEY "
	cQuery += "LEFT JOIN " + RetSQLName(cTabSupCli) + " " + cTabSupCli + "  "
	cQuery += " ON "
    
    If oSubModel:GetId() $ __PDETAIL
        cQuery += "	" + cTabSupCli + ".A2_FILIAL = '" + xFilial(cTabSupCli) + "' "
        cQuery += "	AND " + cTabSupCli + ".A2_COD = " + cTabVAT + "." + cTabVAT + cFldSupCli + " "
        cQuery += "	AND " + cTabSupCli + ".A2_LOJA = " + cTabVAT + "." + cTabVAT + "_BRANCH "
    ElseIf oSubModel:GetId() $ __RDETAIL
        cQuery += "	" + cTabSupCli + ".A1_FILIAL = '" + xFilial(cTabSupCli) + "' "
        cQuery += "	AND " + cTabSupCli + ".A1_COD = " + cTabVAT + "." + cTabVAT + cFldSupCli + " "
	    cQuery += "	AND " + cTabSupCli + ".A1_LOJA = " + cTabVAT + "." + cTabVAT + "_BRANCH "
    EndIf
    cQuery += "	AND " + cTabSupCli + ".D_E_L_E_T_ = ' ' "

	cQuery += "INNER JOIN " + RetSQLName("FK7") + " FK7 "
	cQuery += " ON "
	cQuery += "	FK7.FK7_FILIAL = '" + xFilial("FK7") + "' "
	cQuery += "	AND FK7.FK7_PREFIX = " + cTabVAT + "." + cTabVAT + "_PREFIX "
	cQuery += "	AND FK7.FK7_NUM = " + cTabVAT + "." + cTabVAT + "_NUM "
	cQuery += "	AND FK7.FK7_PARCEL = " + cTabVAT + "." + cTabVAT + "_PARCEL "
	cQuery += "	AND FK7.FK7_TIPO = " + cTabVAT + "." + cTabVAT + "_TIPO "
	cQuery += "	AND FK7.FK7_CLIFOR = " + cTabVAT + "." + cTabVAT + cFldSupCli + " "
	cQuery += "	AND FK7.FK7_LOJA = " + cTabVAT + "." + cTabVAT + "_BRANCH "
	cQuery += "	AND FK7.FK7_ALIAS = '" + cAliasFin + "' "
	cQuery += "	AND FK7.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSQLName(cTabFK) + " " + cTabFK + " "
	cQuery += " ON "
	cQuery += "	" + cTabFK + "." + cTabFK + "_FILIAL = '" + xFilial(cTabFK) + "' "
	cQuery += "	AND " + cTabFK + "." + cTabFK + "_IDDOC = FK7.FK7_IDDOC "
	cQuery += "	AND " + cTabFK + ".D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSQLName("FKA") + " FKA "
	cQuery += " ON "
	cQuery += "	FKA.FKA_FILIAL = '" + xFilial("FKA") + "' "
	cQuery += "	AND FKA.FKA_IDORIG = " + cTabFK + "." + cTabFK + "_ID" + cTabFK + " "
	cQuery += "	AND FKA.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_FILIAL = '" + xFilial(cTabVAT) + "' "
	cQuery += "	AND " + cTabVAT + ".D_E_L_E_T_ = ' ' "
	cQuery += "	AND " + cTabVAT + "." + cTabVAT + "_BOOK = ' ' "
	cQuery += "	AND " + cTabVAT + "." + cTabVAT + "_TYPE = '"+ cAdvType + "' "
	cQuery += "	AND " + cTabFK + "." + cTabFK + "_TPDOC IN ('BA', 'VL') "
	cQuery += "	AND NOT EXISTS ( "
	cQuery += "	SELECT "
	cQuery += "		1 "
	cQuery += "	FROM "
	cQuery += "		" + RetSQLName(cTabFK) + " " + cTabFK + "_AUX "
	cQuery += "	INNER JOIN " + RetSQLName("FKA") + " FKA_AUX "
	cQuery += "  ON "
	cQuery += "		FKA_AUX.FKA_FILIAL = FKA.FKA_FILIAL "
	cQuery += "		AND FKA_AUX.FKA_IDORIG = " + cTabFK + "_AUX." + cTabFK + "_ID" + cTabFK + " "
	cQuery += "		AND FKA_AUX.FKA_TABORI = '" + cTabFK + "' "
	cQuery += "		AND FKA_AUX.D_E_L_E_T_ = ' ' "
	cQuery += "	WHERE "
	cQuery += "		" + cTabFK + "_AUX." + cTabFK + "_FILIAL = " + cTabFK + "." + cTabFK + "_FILIAL "
	cQuery += "		AND FKA_AUX.FKA_IDPROC = FKA.FKA_IDPROC "
	cQuery += "		AND " + cTabFK + "_AUX." + cTabFK + "_TPDOC IN ('ES') "
	cQuery += "			AND " + cTabFK + "_AUX.D_E_L_E_T_ = ' ' "
	cQuery += " ) "

	For nLine := 1 to oSubModel:Length(.F.)
		oSubModel:GoLine(nLine)

		If !Empty(AllTrim(oSubModel:GetValue(cTabVATAdv + "_KEY")))
			// Excludes the records which are already in the model from SQL select.
			cQuery += " AND NOT ("
			cQuery += " " + cTabVATDet + "." + cTabVATDet + "_KEY = '" + oSubModel:GetValue(cTabVATAdv + "_KEY") + "'"
			cQuery += " AND " + cTabVATDet + "." + cTabVATDet + "_VATCOD = '" + oSubModel:GetValue(cTabVATAdv + "_VATCOD") + "'"
			cQuery += " )"
		EndIf

	Next nLine

Return(cQuery)


/*/{Protheus.doc} RU09XFN024_AdvancesVATGroupBy
Generic Group By for VAT Advances
@type function
@author Fernando Nicolau
@since 08/01/2024
@return character, Query
/*/
Function RU09XFN024_AdvancesVATGroupBy(oSubModel As Object)
	Local cQuery as Character
    Local cTabFK As Character
    Local cTabVAT As Character
    Local cTabVATDet As Character
    Local cTabSupCli As Character
    Local cFldSupCli As Character

    If oSubModel:GetId() $ __PDETAIL
        cTabFK := "FK2"
        cTabVAT := "F37"
        cTabVATDet := "F38"
        cTabSupCli := "SA2"
        cFldSupCli := "_FORNEC"
    ElseIf oSubModel:GetId() $ __RDETAIL
        cTabFK := "FK1"
        cTabVAT := "F35"
        cTabVATDet := "F36"
        cTabSupCli := "SA1"
        cFldSupCli := "_CLIENT"
    EndIf

	cQuery := "GROUP BY "
	cQuery += "	" + cTabFK + "." + cTabFK + "_DATA, "
	cQuery += "	" + cTabFK + "." + cTabFK + "_SEQ, "
	cQuery += "	" + cTabFK + "." + cTabFK + "_HISTOR, "
	cQuery += "	" + cTabFK + "." + cTabFK + "_ID" + cTabFK + ", "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_DOC, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_PDATE, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_KEY, "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_VATCOD, "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_VATCD2, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_INVDT, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_INVSER, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_INVDOC, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + cFldSupCli + ", "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_BRANCH, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_INVCUR, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_CNEE_B, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_CNOR_C, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_CNOR_B, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_CNEE_C, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_ADJNR, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_ADJDT, "
    cQuery += "	" + cTabVAT + "." + cTabVAT + "_C_RATE, "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_VATRT, "
	If oSubModel:GetId() $ __PDETAIL
        cQuery += " " + cTabSupCli + ".A2_NOME "
    ElseIf oSubModel:GetId() $ __RDETAIL
        cQuery += " " + cTabSupCli + ".A1_NOME "
    EndIf
	cQuery += "ORDER BY "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_DOC, "
	cQuery += "	" + cTabVAT + "." + cTabVAT + "_PDATE, "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_VATCOD, "
	cQuery += "	" + cTabVATDet + "." + cTabVATDet + "_VATCD2 "
Return(cQuery)

/*/{Protheus.doc} Function RU09XFN025_OpenInflowinvoice
Open Inflow invoice

@type function
@author E.Prokhorenko
@since 07/04/2024
@version 13.1.2310
@param	oView, 		Object,		View 
@param  cType,      Character,  Type
@return 
/*/

Function RU09XFN025_OpenInflowinvoice(oView As Object, cType As Character)
Local lRet          As Logical
Local aArea         As Array
Local aAreaHead     As Array
Local aAreaDet      As Array
Local aTmpMenu      As Array
Local oRootModel    As Object
Local oMdlHead      As Object
Local cDocSer       As Character

Private aRotina     As Array

aArea := GetArea()
lRet := .T.

If (ValType(oView) != "O")
	lRet := .F.
EndIf

If (lRet)
    oRootModel := oView:GetModel():oFormModel
    lRet := lRet .and. RU05XFN010_CheckModel(oRootModel, "RU02D01")
EndIf

If (lRet)
oMdlHead := oRootModel:getModel("F5YMASTER")
Do Case
    Case cType == "B"
        cDocSer := oMdlHead:GetValue("F5Y_DOCORI") + oMdlHead:GetValue("F5Y_SERORI")
    Case cType == "I"
        cDocSer := oMdlHead:GetValue("F5Y_DOCDEB") + oMdlHead:GetValue("F5Y_SERDEB")
        lRet := lRet .and. !Empty(oMdlHead:GetValue("F5Y_DOCDEB"))
    Case cType == "D"
        cDocSer := oMdlHead:GetValue("F5Y_DOCCRD") + oMdlHead:GetValue("F5Y_SERCRD")
        lRet := lRet .and. !Empty(oMdlHead:GetValue("F5Y_DOCCRD"))
EndCase
EndIf

If (lRet)
    //if click was on before model record it is necessary to identify type of original document
    cType := Iif(oMdlHead:GetValue("F5Y_ORIGIN") == "4" .And. cType == "B","U",cType)

    aTmpMenu := AClone(aRotina)
    aRotina	:=	{{"","",0,2,0,Nil},;
                {"","",0,2,0,Nil},;
                {"","",0,2,0,Nil},;
                {"","",0,2,0,Nil}}

    Do Case
        Case cType $ "BI"
            aAreaHead := SF1->(GetArea())
            aAreaDet:= SD1->(GetArea())

            DbSelectArea("SF1")
            SF1->(DbSetOrder(1))
            
            If (SF1->(DbSeek(xFilial('SF1') + cDocSer + oMdlHead:GetValue("F5Y_SUPPL") + oMdlHead:GetValue("F5Y_SUPBR"))))
                CtbDocEnt()	//open View of SF1/SD1
            EndIf
        Case cType == "D"
            aAreaHead := SF2->(GetArea())
            aAreaDet:= SD2->(GetArea())
            DbSelectArea("SF2")
            SF2->(DbSetOrder(1))
            
            If (SF2->(DbSeek(xFilial('SF2')+ cDocSer + oMdlHead:GetValue("F5Y_SUPPL") + oMdlHead:GetValue("F5Y_SUPBR"))))
                CtbDocSaida()	// open View SF2/SD2
            EndIf
        Case cType == "U"
            aAreaHead := F5Y->(GetArea())
            aAreaDet:= F5Z->(GetArea())
            DBSelectArea("F5Y")
            DBSetOrder(6)//F5Y_FILIAL+F5Y_SUPPL+F5Y_SUPBR+F5Y_DOC+F5Y_SERIE 
            If (F5Y->(DBSeek(FWxFilial("F5Y") + oMdlHead:GetValue("F5Y_SUPPL") + oMdlHead:GetValue("F5Y_SUPBR") +cDocSer)))
                FWExecView(STR0002,"RU02D01",MODEL_OPERATION_VIEW) //"Unified Purchases Correction Document"
            EndIf
    EndCase
    RestArea(aAreaDet)
    RestArea(aAreaHead)

    aRotina := AClone(aTmpMenu)
EndIf
RestArea(aArea)
Return Nil

/*/{Protheus.doc} RU09XFN026_HideFldBrw
    This function is designed to hide one or more Fields in a browse.
    @type  Function
    @author eduardo.Flima
    @since 27/03/2024
    @version 27/03/2024
    @param oBrowse  , Object    ,  FWMBrowse object instance 
    @param cFields  , Character ,  Fields to hide in the format "XXX_FIELD1|XXX_FIELD2|..."    
    @return oBrowse , Object    , FWMBrowse object instance with the fields removed
/*/
Function RU09XFN026_HideFldBrw(oBrowse as Object ,cFields as Character)
    Local aColBrw   as Array
    Local aaddFld   as Array
    Local nX        as Numeric 

    Default cFields := ""

    aColBrw := oBrowse:LoadColumns()
    aaddFld :={}

    for nX := 1 to len(aColBrw)
        If !aColBrw[nx][12] $ cFields
            aadd(aaddFld,aColBrw[nx][12])
        Endif 
    next nX

    oBrowse:SetOnlyFields(aaddFld)
Return oBrowse

/*/{Protheus.doc} RU09XFN027_updarotina_MATA468n
    Update menu in routine MATA468n for russia localization.
    @type  Function
    @author eduardo.Flima
    @since 30/07/2024
    @version 30/07/2024
    @param aRotina      , Array     ,  Array with menu itens original
    @param cGenInv      , Character ,  Caption Generate Invoices
    @param cAutPreRel   , Character ,  Caption Automatic Prepayment Relation
    @param cPrepMaint   , Character ,  Caption Prepayment Maintenance
    @return aRotina     , Array     ,  Array with menu itens modifies 
/*/
Function RU09XFN027_updarotina_MATA468n(aRotina as Array, cGenInv as Character, cAutPreRel as Character, cPrepMaint as Character)
    Local nX as numeric
    // Transform 'a468nFatura("TRB",aParams)' into RU09XFN012("TRB",aParams)
    nX := aScan(aRotina,{|x| AllTrim(x[1]) == cGenInv} )
    If nX > 0  
        aRotina[nX] := { cGenInv,'RU09XFN012("TRB",aParams)'  , 0 , 3} //"Generate Invoices"    
    Else
        aAdd(aRotina, { cGenInv,'RU09XFN012("TRB",aParams)'  , 0 , 3} ) //"Generate Invoices"    
    Endif 

    // add Automatic Prepayment Relation and Prepayment Maintenance
 	aAdd(aRotina, { cAutPreRel,'RU09XFN012("TRB",aParams,.T.)', 0 , 3} )  //Automatic Prepayment Relation
 	aAdd(aRotina, { cPrepMaint,'RU05XFN00M("TRB", aParams)' , 0 , 3} )			//Prepayment Maintenance


Return aRotina

/*/{Protheus.doc} RU09XFN028_updvalues_a468NCompAd
    Update values to run compensation 
    @type  Function
    @author eduardo.Flima
    @since 30/07/2025
    @version 30/07/2025
    @param lPedidos , Logical       , variable responsible for identofy if it is SC9 or SD2
    @param cPedido  , Character     , Code of the request
    @param aRecs    , Array         , array with the recno of the requests
    @param cFilSD2  , Character     , Branch of table SD2    
    @return nValTot , Numeric       , Value to be compensated
/*/
Function RU09XFN028_updvalues_a468NCompAd(lPedidos as Logical, cPedido as Character, aRecs as Array, cFilSD2 as Character)
    LOCAL nValTot AS Numeric
    LOCAL nValTax AS Numeric
    
    nValTot := 0
    nValTax := 0
    //Valor total do faturamento
    //Function coied from A468NP1Vlr maibe is better change the function A468NP1Vlr
	If lPedidos
        DbSelectArea("SC9")
        DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
        If DbSeek( xFilial("SC9")+cPedido )
			While SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == cPedido
			    If aScan(aRecs, {|x|x==SC9->(RECNO())}) > 0
		            nValTax += SC9->C9_QTDLIB * RU05XFN01P(SC9->C9_PEDIDO,SC9->C9_ITEM ) //RU05XFN01P_Get_ValImp_From_SC6
					nValTot += SC9->C9_QTDLIB * SC9->C9_PRCVEN + nValTax
                EndIf
                SC9->(DbSkip())
            End
        EndIf
    Else
        DbSelectArea("SD2")
        DbSetOrder(8) //D2_FILIAL+D2_PEDIDO+D2_ITEMPV
        If DbSeek(xFilial('SD2')+cPedido)
            While SD2->D2_FILIAL == cFilSD2 .AND. SD2->D2_PEDIDO == cPedido
                If aScan(aRecs, {|x|x == SD2->(RECNO())}) > 0
                    nValTot += SD2->D2_TOTAL
                EndIf
                SD2->(DbSkip())
            End
            //SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
            //If SF2->(DbSeek(xFilial('SD2')+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))
            //	nValTot += SF2->F2_FRETE+SF2->F2_SEGURO+SF2->F2_DESPESA
            //EndIf
        EndIf
    Endif
Return nValTot

/*/{Protheus.doc} RU09XFN029_Compensate_values_a468NCompAd
    Function responsible for settling invoices in routine A468N for the Russia process.
    @type  Function
    @author eduardo.Flima
    @since 30/07/2025
    @version 30/07/2025
    @param aRelAdvRUS  , Array , Array with the compensation settings 
/*/
Function RU09XFN029_Compensate_values_a468NCompAd(aRelAdvRUS as Array)
    Local aSvParPerg     as Array
    Local nI             as Numeric
    Local lContabiliza   as Logical
    Local lDigita        as Logical
    Local nValTot2       as Numeric
    Local aTxMoeda       as array
    Local nTaxaCM        as Numeric
    Local lAglutina 	:= .F.    

    aSvParPerg := {}
    For	nI := 1 To 14  //save the conttent of MV before call pergunte
        AAdd(aSvParPerg, &("MV_PAR" + StrZero(nI, 2)))
    Next nI
	Pergunte("FIN330",.F.)
    lContabiliza := MV_PAR09
    lDigita := MV_PAR07
    //Russia clears all billing related advance payments
    For nI := 1 To Len(aRelAdvRUS)
        If nI <= len(aRelAdvRUS)
            SE1->(MsGoTo(aRelAdvRUS[nI][1]))
            nValTot2 := aRelAdvRUS[nI][3]
            //Do not calculate exchange rate variation
            aTxMoeda := {}
            aAdd(aTxMoeda,{SE1->E1_MOEDA,SE1->E1_TXMOEDA})
            nTaxaCM := SE1->E1_TXMOEDA
            MaIntBxCR(3,{aRelAdvRUS[nI][1]},,{aRelAdvRUS[nI][2]},,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,SE1->E1_VALOR,,;
                {nValTot2},,nTaxaCM,aTxMoeda)
            SE1->(MsGoTo(aRelAdvRUS[nI][2]))
            //record FR3
            FaGrvFR3("R","",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,aRelAdvRUS[nI][3],SF2->F2_DOC,SF2->F2_SERIE)
        EndIf
    Next nI
    For nI := 1 To Len(aSvParPerg)  //restore conttent of MV after call pergunte
        &("MV_PAR" + StrZero(nI, 2)) := aSvParPerg[nI]
    Next nI
Return 


/*/{Protheus.doc} RU09XFN030_Prepare_Values_a468nDupl
    Function responsible for preparing values for the process of generating invoice installments
    @type  Function
    @author eduardo.Flima
    @since 30/07/2025
    @version 30/07/2025
    @param nTotBasM     , Numeric    , Total base for calculation 
    @param nTotBruM     , Numeric    , Gross total for calculation
    @param nTotImpM     , Numeric    , Total tax amount for calculation
    @param nBasImp1     , Numeric    , Total tax base for calculation
    @param nValImp1     , Numeric    , Tax amount for calculation
    @param nValorTo     , Numeric    , Total tax amount
    @param aVencRusB    , Array      , Tax base per installment 
    @param aVencRusT    , Array      , Total amount per installment
    @param aVencRusI    , Array      , Tax per installment
    @param aVenc        , Array      , Installments
    @param aImpVarSF2   , Array      , tax configuration
    @param nValTot      , Numeric    , Total Value
/*/
Function RU09XFN030_Prepare_Values_a468nDupl(nTotBasM as Numeric,;
                                                nTotBruM as Numeric,;
                                                nTotImpM as Numeric,;
                                                nBasImp1 as Numeric,;
                                                nValImp1 as Numeric,;
                                                nValorTo as Numeric,;
                                                aVencRusB as Array,;
                                                aVencRusT as Array,;
                                                aVencRusI as Array,;
                                                aVenc     as Array,;
                                                aImpVarSF2 as Array,;
                                                nValTot as Numeric)
    Local nI as Numeric 
    Local nPerc as  Numeric

	NTotBasM   := 0
	NTotBruM   := 0
	NTotImpM   := 0
	nBasImp1   := 0
	nValImp1   := 0
	nValorTo   := 0
    nI         := 0 
    nPerc      := 0 
	For nI := 1 To Len(aImpVarSF2)
		Do Case
			Case aImpVarSF2[nI][1]  == "F2_BASIMP1"
				nBasImp1 += aImpVarSF2[nI][2]
			Case aImpVarSF2[nI][1]  == "F2_VALIMP1"
				nValImp1 += aImpVarSF2[nI][2]
		EndCase
	Next nI
	nValorTo   := nBasImp1 + nValImp1
	aVencRusB := {}
	aVencRusT := {}
	aVencRusI := {}
	For nI := 1 To Len(aVenc)
		nPerc := aVenc[nI][2] / nValTot
		aAdd(aVencRusB,({aVenc[nI][1],nBasImp1 * nPerc}))
		aAdd(aVencRusT,({aVenc[nI][1],nValorTo * nPerc}))
		aAdd(aVencRusI,({aVenc[nI][1],nValImp1 * nPerc}))
	Next nI
Return 
