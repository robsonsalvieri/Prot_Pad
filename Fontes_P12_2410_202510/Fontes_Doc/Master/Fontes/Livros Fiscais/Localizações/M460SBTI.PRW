#INCLUDE "PROTHEUS.CH"

Static oQryExec := Nil
Static lSC6CodMun := SC6->(ColumnPos("C6_CODMUN")) > 0
Static lSC6TpActi := SC6->(ColumnPos("C6_TPACTIV")) > 0
Static lSD2CodMun := SD2->(ColumnPos("D2_CODMUN")) > 0
Static lSD2TpActi := SD2->(ColumnPos("D2_TPACTIV")) > 0

/*/{Protheus.doc} M460SBTI
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
Function M460SBTI(cCalculo,nItem,aInfo)

Local aAreaSFC   := {}
Local aImpRef    := {}
Local aImpVal    := {}
Local aItemInfo  := {}
Local cCFO       := ""
Local cCodIca    := ""
Local cCodMun    := ""
Local cCpoLivro  := ""
Local cFunName   := FunName()
Local cImpIncid  := ""
Local cImpuesto  := ""
Local cTES       := ""
Local lRet       := .F.
Local nAliq      := 0
Local nBase      := 0
Local nDecs      := 0
Local nI         := 0
Local nImporte   := 0
Local nMoeda     := 1
Local nMoedSFF   := 1
Local nTaxaMoed  := 1
Local xRet       := Nil

Default cCalculo := ""
Default nItem	 := 0
Default aInfo	 := {}

    lPedidos := IIf(Type("lPedidos") <> "U", lPedidos, .F.)

    lRet := lSC6CodMun .And. lSC6TpActi .And. lSD2CodMun .And. lSD2TpActi
    lRet := lRet .And. SA1->A1_RETICA == "S"

    lXfis := (MaFisFound() .And. ProcName(1)<>"EXECBLOCK")

    If !lxFis
        aItemInfo := ParamIxb[1]
        xRet      := ParamIxb[2]
    EndIf

    If lRet
        If !lxFis
            If Len(xRet) >= 10
                cImpuesto := xRet[1]
                cImpIncid := xRet[10]
            EndIf

            cTes      := SF4->F4_CODIGO
            cCFO      := SF4->F4_CF

            cCodIca   := SC6->C6_TPACTIV
            cCodMun   := SC6->C6_CODMUN

            nMoeda    := IIf(lPedidos, SC5->C5_MOEDA, SF2->F2_MOEDA)
            nTaxaMoed := IIf(lPedidos, SC5->C5_TXMOEDA, SF2->F2_TXMOEDA)
        Else
            xRet := 0
            cCFO := MaFisRet(nItem,"IT_CF")
            cTES := MaFisRet(nItem,"IT_TES")

            If Len(aInfo) >= 2
                cImpuesto := aInfo[01]
                cCpoLivro := aInfo[02]
            EndIF

            If cFunName $ "MATA410"
                nPosCMSC6	:=  aScan(aHeader,{|x| AllTrim(x[2])=="C6_CODMUN"})
                nPosTPSC6	:=	aScan(aHeader,{|x| AllTrim(x[2])=="C6_TPACTIV"})

                If nPosTPSC6 > 0
                    cCodIca	:= aCols[nItem][nPosTPSC6]
                EndIf
                If nPosCMSC6 > 0
                    cCodMun	:= aCols[nItem][nPosCMSC6]
                EndIf

                If Type("M->C5_MOEDA") <> "U" 
					nMoeda := M->C5_MOEDA
					nTaxaMoed := M->C5_TXMOEDA	
                EndIf
            ELSE
                cCodIca := MaFisRet(nItem,"IT_TPACTIV")
                cCodMun := MaFisRet(nItem,"IT_CODMUN")
                nMoeda    := MaFisRet(, "NF_MOEDA")
                nTaxaMoed := MaFisRet(, "NF_TXMOEDA")
            EndIf
        EndIf
    EndIf

    If lRet

        nDecs := MsDecimais(nMoeda)

        //Consulta la tabla SFF
        M460BomSFF(cImpuesto, cCodMun, cCodICA, cCFO, @nAliq, @nImporte, @nMoedSFF)

        If !lXFis

            If nAliq > 0
                nBase   := BaseImpInc(aItemInfo, cImpIncid)
            EndIf

            //Realiza el calculo de la Sobretasa solo si se cumple con el valor indicado en la SFF.
            If xMoeda(nBase, nMoeda, 1, Nil, Nil, nTaxaMoed) >= xMoeda(nImporte, nMoedSFF, 1)
                xRet[2]   := nAliq
                xRet[3]   := nBase
                xRet[4]   := Round(nBase * (nAliq / 100), nDecs)
            EndIf

        Else
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
    EndIf

Return( xRet )

/*/{Protheus.doc} BaseImpInc
    Obtiene valor de impuesto para base de cálculo
    @type Function
    @author luis.samaniego
    @since 26/02/2025
    @version 12.1.2410
    @param
        aItemInfo, Array, Información de ítem e impuestos.
        cImpIncid, Character, Códigos de impuestos a usar en la base de cálculo.
    @return nBase, Numeric, Valor de base para cálculo de impuesto.
    /*/
Static Function BaseImpInc(aItemInfo, cImpIncid)
Local nI := 0
Local nImpInc := 0
Local nBase := 0

Default aItemInfo := {}
Default cImpIncid := ""

    If Len(aItemInfo) >= 6 .And. !Empty(cImpIncid)
        nI := At( cImpIncid,";" )
        nI := IIf(nI == 0, Len(AllTrim(cImpIncid)) + 1, nI )
        
        While nI > 1
            nImpInc:= AScan( aItemInfo[6], {|x| x[1] == Left(cImpIncid, nI - 1)})
            If nImpInc > 0
                nBase := aItemInfo[6, nImpInc, 4]
            Endif
            cImpIncid := Stuff(cImpIncid, 1, nI, "" )
            nI := At(cImpIncid, ";")
            nI := IIf(nI == 0, Len(AllTrim(cImpIncid)) + 1, nI)
        EndDo
    EndIf

Return nBase

/*/{Protheus.doc} M460BomSFF
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
Static Function M460BomSFF(cImpuesto, cCodMun, cCodICA, cCFO, nAliq, nImporte, nMoedSFF)
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
        cQuery += " SFF.FF_IMPOSTO, SFF.FF_ALIQ, SFF.FF_IMPORTE, SFF.FF_MOEDA, SFF.FF_CFO_V, SFF.FF_CODMUN, SFF.FF_COD_TAB "
        cQuery += " FROM ? SFF "
        cQuery += " WHERE "
        cQuery += " SFF.FF_FILIAL = ? "
        cQuery += " AND SFF.FF_IMPOSTO = ? "
        cQuery += " AND SFF.FF_CODMUN = ? "
        cQuery += " AND SFF.FF_COD_TAB = ? "
        cQuery += " AND (SFF.FF_CFO_V = ? OR SFF.FF_CFO_V = ?) "
        cQuery += " AND SFF.D_E_L_E_T_ = ? "
        cQuery += " ORDER BY SFF.FF_CFO_V "

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
