#INCLUDE 'protheus.ch'
#INCLUDE 'fwmvcdef.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'ru09t13.ch'

#DEFINE _QUOTESIGN '"'
#DEFINE _QUOTEESC '&#34;'

#define RU09T03_SF1_FIELDS_HISTORY	"F1_FILIAL |F1_SERIE  |F1_DOC    |F1_DTDIGIT|F1_EMISSAO|F1_BASIMP1|F1_VALIMP1|F1_VALBRUT|F1_STATUSR|F1_LOJA   |F1_FORNECE|F1_CONUNI  |"

#DEFINE _B1_DESC 1
#DEFINE _B1_COD 2
#DEFINE _B1_TE 3
#DEFINE _D1_QUANT 4
#DEFINE _D1_VUNIT 5
#DEFINE _D1_CF 6
#DEFINE _XX_NET 7
#DEFINE _XX_GROSS 8
#DEFINE _D1_UM 9
#DEFINE _XX_VAT 10
#DEFINE _B1_CONTA 11
#DEFINE _B1_CC 12
#DEFINE _B1_ITEMCC 13
#DEFINE _B1_CLVL 14
#DEFINE _B1_LOCPAD 15
#DEFINE _D1_ALQIMP1 16

#DEFINE _TAX_TYPE_FIN "2" //tax type: final (not preliminary)

/*/{Protheus.doc} ru09t1301
     performs creation of incoming  Invoice Factura from user selected XML

     @type Function
     @return Nil

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
function ru09t1301
    ImportXml()
return

/*/{Protheus.doc} ImportXml
     performs creation of incoming  Invoice Factura from user selected XML

     @type Function
     @return Nil

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function ImportXml
    local cXml := ""
    Local cArq as Character
    Local nLen := 0
    Local nHandle as Numeric

    cArq := TFileDialog("*.xml|*.XML",'Files',1, "C:\temp\",.F.)

    nHandle := FOPEN( cArq )

    if nHandle > 0
        nLen := FSeek(nHandle, 0, 2)
        FSeek(nHandle, 0, 0)
        cXml := Space(nLen)
        FRead(nHandle, @cXml, nLen)
        FClose(nHandle)

        If Len(cXml) > 0
            ParseXml(cXml)
        endif
    endif

return

/*/{Protheus.doc} ParseXml
     performs parsing of incoming XML from user selected file

     @type Function
     @parameter cXml, char, complete XML structure
     @return lOk, boolean

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
Static function ParseXml(cXml)
    Local lOk := .F.
    Local oXML := TXmlManager():New()
    local aArr := {}
    local cTabLinName := "—вед“ов"
    //----//
    local cSndId := ""
    local cF1_doc := ""
    local cF1_emissao := ""
    local cF1_moeda := ""
    local aDocLin := {}
    local aDocument := {}
    local cB1_DESC := ""
    local cD1_QUANT := ""
    local cD1_VUNIT := ""
    local cD1_CF := ""
    local cXX_NET := ""
    local cXX_GROSS := ""
    local cXX_VAT := ""
    local cb1_cod := ""
    local cB1_TE := ""
    local cD1_UM := ""
    local cB1_CONTA := ""
    local cB1_CC := ""
    local cB1_ITEMCC := ""
    local cB1_CLVL := ""  
    local cB1_LOCPAD := ""
    local cD1_ALQIMP1 := ""
    //
    local cINNSeller := ""
    local cKPPSeller := ""
    local cINNShipper := ""
    local cKPPShipper := ""
    //
    local cRefTyp := ""
    local cRefDocNo := ""
    local cRefDocDt := ""


    oXML:bDecodeUtf8 := .T.
    lOk := oXML:Parse( cXML )

    if lOk
        //Document header data
        cINNSeller := GetAttr(oXML,"/‘айл/ƒокумент/—в—ч‘акт/—вѕрод/»д—в/—вёЋ”ч","»ЌЌёЋ")
        cKPPSeller := GetAttr(oXML,"/‘айл/ƒокумент/—в—ч‘акт/—вѕрод/»д—в/—вёЋ”ч"," ѕѕ")
        cINNShipper := GetAttr(oXML,"/‘айл/ƒокумент/—в—ч‘акт/√рузќт/√рузќтпр/»д—в/—вёЋ”ч","»ЌЌёЋ")
        cKPPShipper := GetAttr(oXML,"/‘айл/ƒокумент/—в—ч‘акт/√рузќт/√рузќтпр/»д—в/—вёЋ”ч"," ѕѕ")
        cRefTyp := GetAttr(oXML,"/‘айл/ƒокумент/—вѕродѕер/—вѕер/ќснѕер","Ќаимќсн")
        cRefDocNo := GetAttr(oXML,"/‘айл/ƒокумент/—вѕродѕер/—вѕер/ќснѕер","Ќомќсн")
        cRefDocDt := FormatDate(GetAttr(oXML,"/‘айл/ƒокумент/—вѕродѕер/—вѕер/ќснѕер","ƒатаќсн"))

        lOk := oXML:DOMChildNode() //—в”чƒокќбор
        aArr := {}
        aArr := oXML:DOMGetAttArray()
        cSndId := GetAttArr(aArr,"»дќтпр")

        lOk := oXML:DOMNextNode() //ƒокумент

        lOk := oXML:DOMChildNode() //—в—ч‘акт
        aArr := {}
        aArr := oXML:DOMGetAttArray()
        cF1_doc := GetAttArr(aArr,"Ќомер—ч‘")
        cF1_emissao := FormatDate(GetAttArr(aArr,"ƒата—ч‘"))
        cF1_moeda := GetMoeda(GetAttArr(aArr," одќ ¬"))

        lOk := oXML:DOMNextNode() //“абл—ч‘акт
        lOk := oXML:DOMChildNode() //—вед“ов 1

        while lOk 
            if oXML:cName !=  EncodeUtf8(cTabLinName, "cp1251" )
                lOk := oXML:DOMNextNode()
                loop
            endif

            aDocLin := {}
            aArr := {}
            aArr := oXML:DOMGetAttArray()
            cB1_DESC := GetAttArr(aArr,"Ќаим“ов")
            cD1_QUANT := GetAttArr(aArr," ол“ов")
            cD1_VUNIT := GetAttArr(aArr,"÷ена“ов")
            cXX_NET := GetAttArr(aArr,"—т“овЅезЌƒ—")
            cXX_GROSS := GetAttArr(aArr,"—т“ов”чЌал")
            cD1_UM := GetUoM(GetAttArr(aArr,"ќ ≈»_“ов"))
            cD1_ALQIMP1 := Strtran(GetAttArr(aArr,"Ќал—т"),"%","")
            cD1_CF := GetTaxCode(cD1_ALQIMP1) 

            GetMatData(cB1_DESC, @cB1_COD, @cB1_TE, @cB1_CONTA, @cB1_CC, @cB1_ITEMCC, @cB1_CLVL, @cB1_LOCPAD)
            
            lOk := oXML:DOMChildNode()//<јкциз>
            lOk := oXML:DOMNextNode()//<—умЌал>
            lOk := oXML:DOMChildNode()//<—умЌал> -- text

            cXX_VAT := alltrim(oXML:ctext)

            lOk := oXML:DOMParentNode() //
            lOk := oXML:DOMNextNode()//<ƒоп—вед“ов >
            aArr := oXML:DOMGetAttArray()

            lOk := oXML:DOMParentNode() //
            
            lOk := oXML:DOMNextNode()//next tab line

            aAdd(aDocLin,cB1_DESC) //1
            aAdd(aDocLin,cB1_COD)  //2
            aAdd(aDocLin,cB1_TE)   //3
            aAdd(aDocLin,Val(cD1_QUANT)) //4
            aAdd(aDocLin,Val(cD1_VUNIT)) //5
            aAdd(aDocLin,cD1_CF) //6
            aAdd(aDocLin,Val(cXX_NET)) //7
            aAdd(aDocLin,Val(cXX_GROSS)) //8
            aAdd(aDocLin,cD1_UM) //9
            aAdd(aDocLin,Val(cXX_VAT)) //10
            aAdd(aDocLin,cB1_CONTA) //11
            aAdd(aDocLin,cB1_CC) //12
            aAdd(aDocLin,cB1_ITEMCC) //13
            aAdd(aDocLin,cB1_CLVL) //14
            aAdd(aDocLin,cB1_LOCPAD) //15
            aAdd(aDocLin,Val(cD1_ALQIMP1)) //16

            aAdd(aDocument,aDocLin)
        enddo

        // post document into system
        lOk := CreateDoc( cINNSeller, cKPPSeller, cINNShipper, cKPPShipper, cF1_doc, cF1_emissao, cF1_moeda, aDocument)
        
    else
        Alert(STR0004)//"Failed to parse XML"
    endif

Return lOk

/*/{Protheus.doc} CreateDoc
     creates a new invoice factura from supplied data

     @type Function
     @parameter cINNSeller, char, INn of the seller
     @parameter cKPPSeller, char, KPP of the seller
     @parameter cINNShipper, char, INN of the shipper
     @parameter cKPPShipper, char, KPP of the shipper
     @parameter cF1_doc, char, document number
     @parameter cF1_emissao, char, document date
     @parameter cF1_moeda, char, document currency
     @parameter aDocument, array, document lines
     @return lOk, boolean

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function CreateDoc(cINNSeller, cKPPSeller, cINNShipper, cKPPShipper, cF1_doc, cF1_emissao, cF1_moeda, aDocument)
    local lOk := .T.
    local cA2_COD := ""
    local cA2_LOJA := ""
    local cA2_NATUREZ := ""
    local nI := 0
    local nNet := 0
    local nGross :=0
    local nVat := 0
    local dDate := StoD(cF1_emissao)
    local aError := {}
    Local cMSAUTOLOG
    // Submodels
    Local oModelF37 as object
    Local oModelF38 as object

    local oModel := FWLoadModel("RU09T03")//("ZKONTUR04")


    //get vendor
    lOk := GetVend(cINNSeller, cKPPSeller, @cA2_COD, @cA2_LOJA,@cA2_NATUREZ)

    if !lOk 
        Alert(STR0001+" "+cINNSeller+ " "+ cKPPSeller)
    else
    
        oModel:SetOperation(3)
        oModel:Activate()
        oModelF37 := oModel:GetModel("F37master")
        oModelF38 := oModel:GetModel("F38detail")
        
	    oModel:GetModel("F38detail"):SetNoInsertLine(.F.)

        for nI := 1 to Len(aDocument)
            lOk := lOk .and. oModelF38:LoadValue("F38_ITEM", StrZero(nI, TamSX3("F38_ITEM")[1]))
            lOk := lOk .and. oModelF38:LoadValue("F38_ITMCOD", aDocument[nI,_B1_COD])	// Prod./Service Description
            lOk := lOk .and. oModelF38:LoadValue("F38_ITMDES", aDocument[nI,_B1_DESC])
            lOk := lOk .and. oModelF38:LoadValue("F38_DESC", aDocument[nI,_B1_DESC])
            lOk := lOk .and. oModelF38:LoadValue("F38_UM", aDocument[nI,_D1_UM])
            lOk := lOk .and. oModelF38:LoadValue("F38_QUANT", aDocument[nI,_D1_QUANT]) 
            lOk := lOk .and. oModelF38:LoadValue("F38_VUNIT", aDocument[nI,_D1_VUNIT]) // Unit Value
            lOk := lOk .and. oModelF38:LoadValue("F38_VALUE", aDocument[nI,_XX_GROSS])  //Total Value
            lOk := lOk .and. oModelF38:LoadValue("F38_VATBS", aDocument[nI,_XX_NET]) // VAT Base
            lOk := lOk .and. oModelF38:LoadValue("F38_VATVL", aDocument[nI,_XX_VAT])  //VAT Value
            lOk := lOk .and. oModelF38:LoadValue("F38_VALGR", aDocument[nI,_XX_GROSS])  //Gross Total
            lOk := lOk .and. oModelF38:LoadValue("F38_VATBS1", aDocument[nI,_XX_NET])  // VAT Base in Currency 1
            lOk := lOk .and. oModelF38:LoadValue("F38_VATVL1", aDocument[nI,_XX_VAT])  // VAT Value in Currency 1
            lOk := lOk .and. oModelF38:LoadValue("F38_VATRT", aDocument[nI,_D1_ALQIMP1])  //
            lOk := lOk .and. oModelF38:LoadValue("F38_VATCOD", aDocument[nI,_D1_CF])  //
            lOk := lOk .and. oModelF38:LoadValue("F38_INVSER", "")
            lOk := lOk .and. oModelF38:LoadValue("F38_INVDOC", "")
            lOk := lOk .and. oModelF38:LoadValue("F38_INVDT", dDate)
            lOk := lOk .and. oModelF38:LoadValue("F38_ITDATE", dDate)	
            lOk := lOk .and. oModelF38:LoadValue("F38_INVIT","")
            lOk := lOk .and. oModelF38:LoadValue("F38_ORIGIN", "")	// Country Origin

            nNet += aDocument[nI,_XX_NET]
            nGross += aDocument[nI,_XX_GROSS]
            nVat += aDocument[nI,_XX_VAT]
        next

        
        lOk := lOk .and. oModelF37:LoadValue("F37_FORNEC", cA2_COD)	 // vendor code
        lOk := lOk .and. oModelF37:LoadValue("F37_BRANCH", cA2_LOJA) // vendor branch

        lOk := lOk .and. oModelF37:LoadValue("F37_VATVL", nVat)	// VAT Value
        lOk := lOk .and. oModelF37:LoadValue("F37_VALGR", nGross)	// Gross Total
        lOk := lOk .and. oModelF37:LoadValue("F37_VATBS", nNet)	// VAT Base
        lOk := lOk .and. oModelF37:LoadValue("F37_VATVL1", nVat)	// Gross Total in rubles
        lOk := lOk .and. oModelF37:LoadValue("F37_VATBS1", nNet)	// VAT Base in rubles
        lOk := lOk .and. oModelF37:LoadValue("F37_VALUE", nGross)	// Total Value
        lOk := lOk .and. oModelF37:LoadValue("F37_PDATE", dDate)
        lOk := lOk .and. oModelF37:LoadValue("F37_DOC", cF1_doc)


        if lOk
            lOk := oModel:VldData()
            if lOk
                lOk := oModel:CommitData()
                Alert(STR0002+cF1_doc+" "+DtoS(dDate)+" "+STR0003+" "+cA2_COD+" "+cA2_LOJA)//STR0002=Created Inv-fact є, STR0003=from vendor
            endif
        endif

        if !lOk 
            aError := oModel:GetErrorMessage()
            cMSAUTOLOG := ""
            aEval( aError, { |x| cMSAUTOLOG+= iif(x!=Nil,x,"")+CRLF})
            Alert(cMSAUTOLOG)
        endif
    endif

    oModel:DeActivate()
Return lOk
 
/*/{Protheus.doc} FormatDate
     cformatts date to internal format

     @type Function
     @parameter cData, char, date
     @return cFData, char

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function FormatDate(cData) //27.09.2023 ->20230927
   local cFData as character

   cFData := Substr(alltrim(cData), 7, 4) + Substr(alltrim(cData), 4, 2) + Substr(alltrim(cData), 1, 2) 

Return cFData

/*/{Protheus.doc} GetUoM
     find Unit of Measure by OKEI code

     @type Function
     @parameter cOKEI, char, OKEI code
     @return lUoM, char

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function GetUoM(cOKEI)
    Local oStatement As Object
    Local cQuery := " " 
    Local aArea := GetArea()
    local cTab := ""
    local lUoM := ""
    
    cQuery += " select AH_UNIMED from "+RetSqlName("SAH")+" sah "
    cQuery += " where ah_filial = '"+xFilial("SAH")+"' and AH_CODOKEI = '"+cOKEI+"' and d_e_l_e_t_ = ''"

    oStatement := FWPreparedStatement():New(cQuery)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    lUoM := Alltrim((cTab)->AH_UNIMED)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    DBSelectArea(aArea[1])

return lUoM

/*/{Protheus.doc} GetTaxCode
     find internal Tax Code by tax rate

     @type Function
     @parameter cRate, char, Tax rate (i.e. 10 or 20)
     @return lDC, char

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function GetTaxCode(cRate)
    Local oStatement As Object
    Local cQuery := " " 
    Local aArea := GetArea()
    local cTab := ""
    local lDC := ""
    
    cQuery += " select * from "+RetSqlName("F31")+" f31 join "+RetSqlName("F30")+" f30 on f31_rate = f30_code  "
    cQuery += " where f30_filial = '" + xFilial("F30") + "' f30_rate = '"+cRate+"' and f30.d_e_l_e_t_ = '' f31_filial = '" + xFilial("F31") + "' and f31_type = '"+_TAX_TYPE_FIN+"' and f31.d_e_l_e_t_ = '' "

    oStatement := FWPreparedStatement():New(cQuery)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    lDC := Alltrim((cTab)->F31_CODE)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    DBSelectArea(aArea[1])

return lDC


/*/{Protheus.doc} GetMoeda
     find internal currency code by its international code

     @type Function
     @parameter cCurrCod, char, curr  code
     @return nMoeda, Numeric

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function GetMoeda(cCurrCod)
    Local oStatement As Object
    Local cQuery := " " 
    Local aArea := GetArea()
    local cTab := ""
    local nMoeda := 0
    
    cQuery += " select CTO_MOEDA from "+RetSqlName("CTO")+" cto "
    cQuery += " where cto_filial = '"+xFilial("CTO")+"' and CTO_CLSMOE = '"+cCurrCod+"' and d_e_l_e_t_ = ''"

    oStatement := FWPreparedStatement():New(cQuery)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    nMoeda := Val(Alltrim((cTab)->CTO_MOEDA))

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    DBSelectArea(aArea[1])

return nMoeda 

/*/{Protheus.doc} GetVend
     get vendor data

     @type Function
     @parameter cINN, char, vendor INN
     @parameter cKPP, char, vendor KPP
     @parameter cA2_COD, char, vendor code
     @parameter cA2_LOJA, char, vendor branch
     @parameter cA2_NATUREZ, char, 
     @return lOk, boolean

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function GetVend(cINN, cKPP, cA2_COD, cA2_LOJA, cA2_NATUREZ)
    Local oStatement As Object
    Local cQuery := " " 
    Local aArea := GetArea()
    Local lOk := .F.
    local cTab := ""
    
    cQuery += " select A2_COD, A2_LOJA, A2_NATUREZ from "+RetSqlName("SA2")+" sa2 "
    cQuery += " where a2_filial = '"+xFilial("SA2")+"' and A2_CODZON = '"+cINN+"' and A2_KPP = '"+cKPP+"' and d_e_l_e_t_ = ''"

    oStatement := FWPreparedStatement():New(cQuery)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    ca2_cod := Alltrim((cTab)->A2_COD)
    ca2_loja := Alltrim((cTab)->A2_LOJA)
    cA2_NATUREZ := Alltrim((cTab)->A2_NATUREZ)
    if !Empty(ca2_cod)
        lOk := .T.
    endif

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    DBSelectArea(aArea[1])
    
Return lOk

/*/{Protheus.doc} GetMatData
     get material data by its text description

     @type Function
     @parameter cDesc, char
     @parameter cB1_COD, char 
     @parameter cB1_TE, char 
     @parameter cB1_CONTA, char 
     @parameter cB1_CC, char 
     @parameter cB1_ITEMCC, char 
     @parameter cB1_CLVL, char 
     @parameter cB1_LOCPAD, char
     @return lOk, boolean

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function GetMatData(cDesc,cB1_COD, cB1_TE, cB1_CONTA, cB1_CC, cB1_ITEMCC, cB1_CLVL, cB1_LOCPAD )
    Local oStatement As Object
    Local cQuery := " " 
    Local aArea := GetArea()
    Local lOk := .F.
    local cTab := ""
    
    cQuery += " select B1_COD, B1_TE, B1_CONTA, B1_CC, B1_ITEMCC, B1_CLVL, B1_LOCPAD  "
    cQuery += " from "+RetSqlName("SB1")+" sb1 "
    cQuery += " where b1_filial = '"+xFilial("SB1")+"' and B1_DESC = '"+cDesc+"' and d_e_l_e_t_ = ''"

    oStatement := FWPreparedStatement():New(cQuery)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    cB1_COD := Alltrim((cTab)->B1_COD)
    cB1_TE := Alltrim((cTab)->B1_TE)
    cB1_CONTA := Alltrim((cTab)->B1_CONTA)
    cB1_CC := Alltrim((cTab)->B1_CC)
    cB1_ITEMCC := Alltrim((cTab)->B1_ITEMCC)
    cB1_CLVL := Alltrim((cTab)->B1_CLVL)
    cB1_LOCPAD := Alltrim((cTab)->B1_LOCPAD)
    if !Empty(cB1_COD)
        lOk := .T.
    endif

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    DBSelectArea(aArea[1])
Return lOk

/*/{Protheus.doc} GetAttArr
     get XML attribute by name

     @type Function
     @parameter aArr, array
     @parameter cAttNam, char 
     @return cAttr, char

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
static function GetAttArr(aArr,cAttNam)
    local cAttr := ""
    local nCount := 0
    for nCount := 1 to Len(aArr)
        if alltrim(aArr[nCount,1]) == EncodeUtf8(alltrim(cAttNam), "cp1251" ) 
            cAttr := alltrim(DecodeUtf8(aArr[nCount,2], "cp1251" ))
            exit
        endif
    next
return cAttr

/*/{Protheus.doc} GetAtt
     get XML attribute by name

     @type Function
     @parameter oXML, object
     @parameter cPath, char
     @parameter cAttNam, char 
     @return cAttr, char

     @author mpopenker
     @since 07.06.2024
     @version 12.1.2310
*/
Static function GetAttr(oXML,cPath,cAtt)
    local cVal := ""
    cVal := oXML:XPathGetAtt( EncodeUtf8(cPath, "cp1251" ), EncodeUtf8(cAtt, "cp1251" ) )
    cVal := alltrim(DecodeUtf8(cVal, "cp1251" ))
Return cVal

                   
//Merge Russia R14 
                   
