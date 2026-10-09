#INCLUDE "PROTHEUS.CH"

Static oQryExec := Nil
Static lSD1CodMun := SD1->(ColumnPos("D1_CODMUN")) > 0
Static lSD1TpActi := SD1->(ColumnPos("D1_TPACTIV")) > 0

/*/{Protheus.doc} M100SBTI
    Cálculo de sobretasa bomberil por ítem.
    @type Function
    @author luis.samaniego
    @since 26/02/2025
    @version 12.1.2410
    @param
        cCalculo, Character, Valor a cálcular (A=Alícuota, B=Base, V=Valor).
        nItem, Numeric, Número de ítem.
        aInfo, Array, Información de impuestos (Código impuesto, Campo libro fiscal).
    @return xRet, Undefinited, Valor de impuesto.
    /*/
Function M100SBTI(cCalculo,nItem,aInfo)

Local aAreaSFC  := {}
Local aImpRef   := {}
Local aImpVal   := {}
Local cCFO      := ""
Local cCodIca   := ""
Local cCodMun   := ""
Local cCpoLivro := ""
Local cImpIncid := ""
Local cImpuesto := ""
Local cTES      := ""
Local lRet      := .F.
Local nAliq     := 0
Local nBase     := 0
Local nDecs     := 0
Local nI        := 0
Local nImporte  := 0
Local nMoeda    := 1
Local nMoedSFF  := 1
Local nTaxaMoed := 1
Local xRet      := 0

Default cCalculo := ""
Default nItem    := 0
Default aInfo    := {}

    lRet := lSD1CodMun .And. lSD1TpActi
    lXfis := (MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

    If lRet .And. lxFis
        If MaFisRet(,"NF_CLIFOR" ) == "C"
            lRet := SA1->A1_RETICA == "S"
        Else
            lRet := SA2->A2_RETICA == "S"
        EndIf
    EndIf

    If lRet .And. lxFis
        xRet := 0

        cCFO    := MaFisRet(nItem,"IT_CF")
        cTES    := MaFisRet(nItem,"IT_TES")
        cCodIca := MaFisRet(nItem,"IT_TPACTIV")
        cCodMun := MaFisRet(nItem,"IT_CODMUN")

        nMoeda    := MaFisRet(, "NF_MOEDA")
        nTaxaMoed := MaFisRet(, "NF_TXMOEDA")
        nDecs     := MsDecimais(nMoeda)

        If Len(aInfo) >= 2
            cImpuesto := aInfo[01]
            cCpoLivro := aInfo[02]
        EndIF

        //Consulta la tabla SFF
        M100BomSFF(cImpuesto, cCodMun, cCodICA, cCFO, @nAliq, @nImporte, @nMoedSFF)

        Do Case
            Case cCalculo=="B"

                aAreaSFC := SFC->(GetArea())
                dbSelectArea("SFC")
                SFC->(DbSetOrder(2)) //FC_FILIAL+FC_TES+FC_IMPOSTO
                If (SFC->(MsSeek( xFilial("SFC") + cTES + cImpuesto)))
                    cImpIncid := Alltrim(SFC->FC_INCIMP)
                Endif
                SFC->(RestArea(aAreaSFC))

                If !Empty(cImpIncid)
                    aImpRef := MaFisRet(nItem, "IT_DESCIV")
                    aImpVal := MaFisRet(nItem, "IT_VALIMP")
                    For nI:=1 to Len(aImpRef)
                        If !Empty(aImpRef[nI])
                            If Trim(aImpRef[nI][1]) $ cImpIncid
                                nBase += aImpVal[nI]
                            Endif
                        Endif
                    Next nI
                Endif

                If nAliq > 0
                    xRet := nBase
                EndIf

            Case cCalculo == "A"

                xRet := nAliq

            Case cCalculo == "V"

                nAliq := MaFisRet(nItem, "IT_ALIQIV"+cCpoLivro)
                If nAliq > 0
                    nBase := MaFisRet(nItem, "IT_BASEIV"+cCpoLivro)
                EndIf

                //Realiza el calculo de la Sobretasa solo si se cumple con el valor indicado en la SFF.
                If xMoeda(nBase, nMoeda, 1, Nil, Nil, nTaxaMoed) >= xMoeda(nImporte, nMoedSFF, 1)
                    xRet := Round(nBase * (nAliq / 100), nDecs)
                EndIf

        EndCase
    EndIf

Return( xRet )

/*/{Protheus.doc} M100BomSFF
    Consulta la tabla SFF para obtener la configuración para la sobretasa bomberil.
    @type  Function
    @author luis.samaniego
    @since 05/03/2025
    @version 12.1.2410
    @param
        cImpuesto, Character, Código de impuesto.
        cCodMun, Character, Código de municipio.
        cCodICA, Character, Codido de tipo de actividad.
        cCFO, Character, Código fiscal.
        nAliq, Numeric, Valor de alícuota (FF_ALIQ).
        nImporte, Numeric, Valor minimo (FF_IMPORTE).
        nMoedSFF, Numeric, Moneda (FF_MOEDA).
    /*/
Static Function M100BomSFF(cImpuesto, cCodMun, cCodICA, cCFO, nAliq, nImporte, nMoedSFF)
Local cQuery      := ""
Local nOrd        := 1

Default cImpuesto := ""
Default cCodMun   := ""
Default cCodICA   := ""
Default cCFO      := ""
Default nAliq     := 0
Default nImporte  := 0
Default nMoedSFF  := 0

    If oQryExec == NIL
        cQuery := " SELECT "
        cQuery += " SFF.FF_IMPOSTO, SFF.FF_ALIQ, SFF.FF_IMPORTE, SFF.FF_MOEDA, SFF.FF_CFO_C, SFF.FF_CODMUN, SFF.FF_COD_TAB "
        cQuery += " FROM ? SFF "
        cQuery += " WHERE "
        cQuery += " SFF.FF_FILIAL = ? "
        cQuery += " AND SFF.FF_IMPOSTO = ? "
        cQuery += " AND SFF.FF_CODMUN = ? "
        cQuery += " AND SFF.FF_COD_TAB = ? "
        cQuery += " AND (SFF.FF_CFO_C = ? OR SFF.FF_CFO_C = ?) "
        cQuery += " AND SFF.D_E_L_E_T_ = ? "
        cQuery += " ORDER BY SFF.FF_CFO_C "

        cQuery := ChangeQuery(cQuery)
        oQryExec := FwExecStatement():New(cQuery)
    EndIf

    oQryExec:SetUnsafe(nOrd++, RetSqlName("SFF")) //Nombre tabla
    oQryExec:SetString(nOrd++, xFilial("SFF")) //Filial
    oQryExec:SetString(nOrd++, cImpuesto) //Impuesto
    oQryExec:SetString(nOrd++, cCodMun) //Municipio
    oQryExec:SetString(nOrd++, cCodICA) //Tipo Actividad
    oQryExec:SetString(nOrd++, cCFO) //Codigo fiscal
    oQryExec:SetString(nOrd++, ' ') //Código fiscal vacio
    oQryExec:SetString(nOrd++, ' ') //Delete

    nAliq    := oQryExec:ExecScalar("FF_ALIQ")
    nImporte := oQryExec:ExecScalar("FF_IMPORTE")
    nMoedSFF := oQryExec:ExecScalar("FF_MOEDA")

Return
