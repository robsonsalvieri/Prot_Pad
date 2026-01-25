#INCLUDE 'protheus.ch'
#INCLUDE 'fwmvcdef.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'ru09t12.ch'
 
#DEFINE _QUOTESIGN '"'
#DEFINE _QUOTEESC '&#34;'
#DEFINE _PCSCODE '796' // code for Pcs UoM

function ru09t1201
    ExportInvF()
return

/*/{Protheus.doc} ExportInvF
     performs creation of outgoing XML Invoice Factura from user input

     @type Function
     @return Nil

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function ExportInvF()
    local cXml := ""
    Local cArq as Character
    Local cDir as Character

    Local nHandle as Numeric
    Local cFilename := ""


    If MyParamBox() // if Selection parameters were completed with OK
        cXml := CreateXml1(mv_par01,mv_par02,mv_par03,mv_par04,@cFilename)

        if !Empty(cXml)
            cDir:= tFileDialog( STR0001,STR0002,, "C:\temp\out", .F., GETF_RETDIRECTORY ) //STR0001="File XML | *.xml",STR0002="C:\temp\"
            cArq := cDir + "\" + cFilename + ".xml"
            nHandle := FCreate(cArq)
	
            If nHandle > 0
                FWrite(nHandle, cXml)
                FClose(nHandle)
                AVISO(STR0005, STR0003+" "+cArq, {"Ok"}, 1) //STR0003="XML file created",STR0005='Info"
            endif
        endif
    endif
return

/*/{Protheus.doc} CreateXml1
     performs creation of outgoing XML from user input

     @type Function
     @parameter cSerie char, docuemt series, in
     @parameter cDocno char, document number, in
     @parameter cClient char, client code, in
     @parameter cFilename char, rresulting filename for EDO operator, out
     @return cXml, char, complete XML structure

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static Function CreateXml1(cClient, cClientLoj, cDateDoc, cDocno, cFilename)
    local cDocKey := ""
    //seller data
    local cCompNameS := ""
    local cINNS := ""
    local cKPPS := ""
    local cIndexS  := ""
    local cRegionS := ""
    local cCityS   := ""
    local cStreetS := ""
    local cHouseS  := ""
    Local cCountryS := ""
    Local lOk := .F.
    // Buyer/client data
    local cCompNameB := ""
    local cINNB := ""
    local cKPPB := ""
    local cIndexB  := ""
    local cRegionB := ""
    local cCityB   := ""
    local cStreetB := ""
    local cHouseB  := ""
    Local cCountryB := ""
    //items data
    Local aItems := {}
    Local nSumNET := 0
    Local nSumTOT := 0
    Local nSumVAT := 0
    Local nQtyNet := 0
    //EDE Operator Data
    Local cBUYER_ID := ""			
    Local cSELLER_ID := ""
    Local cEDE_INN := ""
    Local cEDE_ID := ""
    Local cEDE_NAME := ""
    //Signor data
    Local cPosition := ""			
    Local cFamily := ""			
    Local cName := ""			
    Local cParname := ""
    //XML data
    Local cXml := ""
    Local cXmlIt := ""
    Local nCnt as Numeric
    Local cSndDat := ""
    local cSndTim := ""
    Local cUUID := ""

    cSndDat := FormatDate(dtos(Date()))
    cSndTim := StrTran(Time(),":",".")
    cUUID := UUIDRandom()
    cFilename := ""

    if GetDocHead(cDocno, cClient, cClientLoj, cDateDoc, @cDocKey) 

        lOk := GetSeller(cDateDoc,@cCompNameS,@cINNS, @cKPPS,@cCountryS,@cIndexS,@cRegionS,@cCityS,@cStreetS,@cHouseS)

        lOk := GetBuyer(cDateDoc,cClient,cClientLoj,@cCompNameB,@cINNB,@cKPPB,@cCountryB,@cIndexB,@cRegionB,@cCityB,@cStreetB,@cHouseB) 

        lOk := GetDocItms(cDocKey, cClient, @aItems, @nSumNET, @nSumTOT, @nSumVAT, @nQtyNet) 

        lOk := GetEDEdata(cINNB,cKPPB,@cBUYER_ID,@cSELLER_ID,@cEDE_INN,@cEDE_ID,@cEDE_NAME) 

        lOk := GetSignor(@cPosition,@cFamily,@cName,@cParname) 

        if lOk 
            // Fill XML template
            cFilename := 'ON_NSCHFDOPPR_'+cBUYER_ID+'_'+cSELLER_ID+'_'+cDateDoc+'_'+cUUID

            cXml += '<?xml version="1.0" encoding="windows-1251"?>'
            cXml += '<Ôàéë ÈäÔàéë="'+cFilename+'" ÂåðñÔîðì="5.01" ÂåðñÏðîã="Diadoc 1.0">'
            cXml += '  <ÑâÓ÷ÄîêÎáîð ÈäÎòïð="'+cSELLER_ID+'" ÈäÏîë="'+cBUYER_ID+'">'
            cXml += '    <ÑâÎÝÄÎòïð ÈÍÍÞË="'+cEDE_INN+'" ÈäÝÄÎ="'+cEDE_ID+'" ÍàèìÎðã="'+cEDE_NAME+'" />'
            cXml += '  </ÑâÓ÷ÄîêÎáîð>'
            cXml += '  <Äîêóìåíò ÊÍÄ="1115131" ÂðåìÈíôÏð="'+cSndTim+'" ÄàòàÈíôÏð="'+cSndDat+'" ÍàèìÝêîíÑóáÑîñò="'+cCompNameS+'" Ôóíêöèÿ="Ñ×Ô" >'
            cXml += '    <ÑâÑ÷Ôàêò ÍîìåðÑ÷Ô="'+cDocno+'" ÄàòàÑ÷Ô="'+FormatDate(cDateDoc)+'" ÊîäÎÊÂ="'+cCountryS+'">'
            cXml += '      <ÑâÏðîä>'
            cXml += '        <ÈäÑâ>'
            cXml += '          <ÑâÞËÓ÷ ÍàèìÎðã="'+cCompNameS+'" ÈÍÍÞË="'+cINNS+'" ÊÏÏ="'+cKPPS+'" />'
            cXml += '        </ÈäÑâ>'
            cXml += '        <Àäðåñ>'
            cXml += '          <ÀäðÐÔ Èíäåêñ="'+cIndexS+'" ÊîäÐåãèîí="'+cRegionS+'" Ãîðîä="'+cCityS+'" Óëèöà="'+cStreetS+'" Äîì="'+cHouseS+'" />'
            cXml += '        </Àäðåñ>'
            cXml += '      </ÑâÏðîä>'
            cXml += '      <ÃðóçÎò>'
            cXml += '        <ÃðóçÎòïð>'
            cXml += '        <ÈäÑâ>'
            cXml += '          <ÑâÞËÓ÷ ÍàèìÎðã="'+cCompNameS+'" ÈÍÍÞË="'+cINNS+'" ÊÏÏ="'+cKPPS+'" />'
            cXml += '        </ÈäÑâ>'
            cXml += '        <Àäðåñ>'
            cXml += '          <ÀäðÐÔ Èíäåêñ="'+cIndexS+'" ÊîäÐåãèîí="'+cRegionS+'" Ãîðîä="'+cCityS+'" Óëèöà="'+cStreetS+'" Äîì="'+cHouseS+'" />'
            cXml += '        </Àäðåñ>'
            cXml += '        </ÃðóçÎòïð>'
            cXml += '      </ÃðóçÎò>'
            cXml += '      <ÃðóçÏîëó÷>'
            cXml += '        <ÈäÑâ>'
            cXml += '          <ÑâÞËÓ÷ ÍàèìÎðã="'+cCompNameB+'" ÈÍÍÞË="'+cINNB+'" ÊÏÏ="'+cKPPB+'" />'
            cXml += '        </ÈäÑâ>'
            cXml += '        <Àäðåñ>'
            cXml += '          <ÀäðÐÔ Èíäåêñ="'+cIndexB+'" ÊîäÐåãèîí="'+cRegionB+'" Ãîðîä="'+cCityB+'" Óëèöà="'+cStreetB+'" Äîì="'+cHouseB+'" />'
            cXml += '        </Àäðåñ>'
            cXml += '      </ÃðóçÏîëó÷>'
            cXml += '      <ÑâÏîêóï>'
            cXml += '        <ÈäÑâ>'
            cXml += '          <ÑâÞËÓ÷ ÍàèìÎðã="'+cCompNameB+'" ÈÍÍÞË="'+cINNB+'" ÊÏÏ="'+cKPPB+'" />'
            cXml += '        </ÈäÑâ>'
            cXml += '        <Àäðåñ>'
            cXml += '          <ÀäðÐÔ Èíäåêñ="'+cIndexB+'" ÊîäÐåãèîí="'+cRegionB+'" Ãîðîä="'+cCityB+'" Óëèöà="'+cStreetB+'" Äîì="'+cHouseB+'" />'
            cXml += '        </Àäðåñ>'
            cXml += '      </ÑâÏîêóï>'
            cXml += '      <ÄîïÑâÔÕÆ1 ÍàèìÎÊÂ="Ðîññèéñêèé ðóáëü" />'
            cXml += '    </ÑâÑ÷Ôàêò>'
            cXml += '    <ÒàáëÑ÷Ôàêò>'

            for nCnt :=1 to Len(aItems)
                cXmlIt := ''	
                cXmlIt += '      <ÑâåäÒîâ ÍîìÑòð="'+Alltrim(Str(aItems[nCnt,1]))+'" ÍàèìÒîâ="'+Alltrim(aItems[nCnt,2])+'" '
                cXmlIt += '       ÎÊÅÈ_Òîâ="'+Alltrim(aItems[nCnt,3])+'" ÊîëÒîâ="'+Alltrim(Str(aItems[nCnt,4]))+'" ÖåíàÒîâ="'+Alltrim(Str(aItems[nCnt,5]))+'"'
                cXmlIt += '       ÑòÒîâÁåçÍÄÑ="'+Alltrim(Str(aItems[nCnt,6]))+'" ÍàëÑò="'+Alltrim(Str(aItems[nCnt,7]))+'%" ÑòÒîâÓ÷Íàë="'+Alltrim(Str(aItems[nCnt,8]))+'">'
                cXmlIt += '        <Àêöèç>'
                cXmlIt += '          <ÁåçÀêöèç>áåç àêöèçà</ÁåçÀêöèç>'
                cXmlIt += '        </Àêöèç>'
                cXmlIt += '        <ÑóìÍàë>'
                cXmlIt += '          <ÑóìÍàë>'+Alltrim(Str(aItems[nCnt,9]))+'</ÑóìÍàë>'
                cXmlIt += '        </ÑóìÍàë>'
                cXmlIt += '        <ÄîïÑâåäÒîâ ÊîäÒîâ="'+Alltrim(aItems[nCnt,10])+'" ÍàèìÅäÈçì="'+Alltrim(aItems[nCnt,11])+'" />'
                cXmlIt += '      </ÑâåäÒîâ>'

                cXml += cXmlIt
            next

            cXml += '      <ÂñåãîÎïë ÑòÒîâÁåçÍÄÑÂñåãî="'+Alltrim(Str(nSumNET))+'" ÑòÒîâÓ÷ÍàëÂñåãî="'+Alltrim(Str(nSumTOT))+'">'
            cXml += '        <ÑóìÍàëÂñåãî>'
            cXml += '          <ÑóìÍàë>'+Alltrim(Str(nSumVAT))+'</ÑóìÍàë>'
            cXml += '        </ÑóìÍàëÂñåãî>'
            cXml += '        <ÊîëÍåòòîÂñ>'+Alltrim(Str(nQtyNet))+'</ÊîëÍåòòîÂñ>'
            cXml += '      </ÂñåãîÎïë>'
            cXml += '    </ÒàáëÑ÷Ôàêò>'
            cXml += '    <ÑâÏðîäÏåð>'
            cXml += '      <ÑâÏåð ÑîäÎïåð="Òîâàðû ïåðåäàíû">'
            cXml += '        <ÎñíÏåð ÍàèìÎñí="ñ÷åò-ôàêòóðà" ÍîìÎñí="'+cDocno+'" ÄàòàÎñí="'+FormatDate(cDateDoc)+'" />'
            cXml += '      </ÑâÏåð>'
            cXml += '    </ÑâÏðîäÏåð>'
            cXml += '    <Ïîäïèñàíò ÎñíÏîëí="ñîñòàâëåíèå è îòïðàâêà äîóêìåíòîâ" ÎáëÏîëí="1" Ñòàòóñ="1">'
            cXml += '      <ÞË ÈÍÍÞË="'+cINNS+'" Äîëæí="'+cPosition+'" ÍàèìÎðã="'+cCompNameS+'">'
            cXml += '        <ÔÈÎ Ôàìèëèÿ="'+cFamily+'" Èìÿ="'+cName+'" Îò÷åñòâî="'+cParname+'" />'
            cXml += '      </ÞË>'
            cXml += '    </Ïîäïèñàíò>'
            cXml += '  </Äîêóìåíò>'
            cXml += '</Ôàéë>'
        endif
    
    else
        AVISO(STR0005, STR0004, {"Ok"}, 1) //STR0004="Process failed",STR0005="Info"
    endif
Return cXml

/*/{Protheus.doc} GetSignor
     get person that signed the document

     @type Function
     @parameter cPosition char, position, out
     @parameter cFamily char, family, out
     @parameter cName char, name, out
     @parameter cParname char, paternal name, out
     @return lOk, Boolean

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function GetSignor(cPosition,cFamily,cName,cParname)  
    local aParamBox := {}
    local aRet := {} 
    local lOk := .F.
    Local cSignCod := ""
    Local cF3 := "F42XML"
    Local aSaveArea as Array
    Local aArea  as Array    

    aAdd(aParamBox,{1,"Signer code",Space(60),"","",cF3,"",60,.F.}) 
    aAdd(aParamBox,{1,"Signer name",Space(60),"","","","",60,.F.}) 
    aAdd(aParamBox,{1,"Signer position",Space(60),"","","","",60,.F.}) 

    lOk := ParamBox(aParamBox,"Select signer",@aRet)  

    if lOk 
        cSignCod := Alltrim(mv_par01)
        aSaveArea := GetArea() 
        //get signer FIO
        aArea := SRA->(GetArea())    
        DbSelectArea("SRA")
        DbSetOrder(13) //D	RA_MAT+RA_FILIAL                                                                                                                                                                                                                                                 
        SRA->(DbGoTop())    

        if SRA->(MsSeek(cSignCod + xFilial('SRA') ))
            cFamily := SRA->RA_PRISOBR
            cName := SRA->RA_PRINOME
            cParname := SRA->RA_SECNOME
            cPosition := Alltrim(mv_par03)
            lOk = .T.
        else
            lOk := .F.
        endif

        RestArea(aSaveArea) 
    endif
Return lOk

/*/{Protheus.doc} GetEDEdata
     redurns EDE related parameters from F8A table

     @type Function
     @parameter cINNB char, Buyers' INN
     @parameter cKPPB char, Buyer's KPP
     @parameter cBUYER_ID char, buyer's ID in EDE system
     @parameter cSELLER_ID char, seller's ID in EDE system
     @parameter cEDE_INN char, INN of EDE operator system
     @parameter cEDE_ID char, ID of EDE operator system
     @parameter cEDE_NAME char, Name of EDE operator system
     @return lOk, Boolean

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function GetEDEdata(cINNB,cKPPB,cBUYER_ID,cSELLER_ID,cEDE_INN,cEDE_ID,cEDE_NAME) 
    Local lOk := .T.  
    Local aSaveArea as Array
    Local aAreaF2  as Array    
    local cEDSys := "2BM" // Kontur

    aSaveArea := GetArea() 
    aAreaF2 := F8A->(GetArea())    
    DbSelectArea("F8A")
    DbSetOrder(1)           
    
    //get our ID                                                                                   
    F8A->(DbGoTop())    
    if F8A->(MsSeek(xFilial('F8A') + Padr(cEDSys, 10, "") + Padr("EDOURID", 20, "") ))
        cSELLER_ID := Alltrim(F8A->F8A_EDEVAL)
    endif

    //get client (buyer) ID                                                                                   
    F8A->(DbGoTop())    
    if F8A->(MsSeek(xFilial('F8A') + Padr(cEDSys, 10, "") + Padr("EDCLIID", 20, "") + Padr(cINNB, 12, "") ))
        cBUYER_ID := Alltrim(F8A->F8A_EDEVAL)
    endif

    // get operator id and other                                                                           
    F8A->(DbGoTop())    
    if F8A->(MsSeek(xFilial('F8A') + Padr(cEDSys, 10, "") + Padr("EDEOP", 20, "") ))
        cEDE_NAME := Alltrim(F8A->F8A_EDEVAL)
        cEDE_NAME  := StrTran(cEDE_NAME,_QUOTESIGN,_QUOTEESC)
        cEDE_ID := Alltrim(cEDSys)
        cEDE_INN := Alltrim(F8A->F8A_EDEINN)
    endif

    RestArea(aSaveArea) 
Return lOk

/*/{Protheus.doc} GetDocHead
     returns documen t header info

     @type Function
     @parameter cSerie char, doc series, in
     @parameter cDocno char, doc number, in
     @parameter cClient char, client code, in
     @parameter cClientLoj char, client department, in
     @parameter cDateDoc char, document date, out
     @parameter cNumDoc char, document date, out
     @return lOk, Boolean

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function GetDocHead(cNumDoc, cClient, cClientLoj, cDateDoc, cDocKey)
    Local aSaveArea as Array
    Local aAreaF2  as Array    
    Local lOk := .F.  

    aSaveArea := GetArea() 
    //get header
    aAreaF2 := F35->(GetArea())    
    DbSelectArea("F35")
    DbSetOrder(2) //2	F35_FILIAL+F35_CLIENT+F35_BRANCH+DTOS(F35_PDATE)+F35_DOC+F35_TYPE                                                                                                                                                                                                 
    F35->(DbGoTop())    

    if F35->(MsSeek(xFilial('F35') + cClient + cClientLoj + cDateDoc + cNumDoc))
        cDocKey := F35->F35_KEY
        lOk = .T.
    endif

    RestArea(aSaveArea) 
return lOk

/*/{Protheus.doc} GetSeller
     returns seller info info & address

     @type Function
     @parameter cPrintdate char, date of printing (for address validity), in
     @parameter cCompName char, out
     @parameter cINN char, out
     @parameter cKPP char, out
     @parameter cCountry char, out
     @parameter cIndex char, out
     @parameter cRegion char, out
     @parameter cCity char, out
     @parameter cStreet char, out
     @parameter cHouse char, out
     @return lOk, Boolean

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function GetSeller(cPrintdate,cCompName,cINN,cKPP,cCountry,cIndex,cRegion,cCity,cStreet,cHouse) // our company
    Local lOk := .F.  
    Local aCompanyInfo:= {} As Array
    Local aBranchInfo := {} As Array

    cCompName := ""
    cINN   := "" 
    cKPP := ""

    aCompanyInfo := GetCompnInf('2', FWGrpCompany(),FWCompany(), FWUnitBusiness())
    aBranchInfo := GetBranchInf(FWGrpCompany(),FWCompany(), FWUnitBusiness(), FWFilial())
    cCompName  := aCompanyInfo[1]
    cCompName  := StrTran(cCompName,_QUOTESIGN,_QUOTEESC)

    cINN   := aCompanyInfo[2] 
    cKPP := aBranchInfo[2]
    GetAdress("SM0",GetMyAgacodent(2),"0",cPrintDate,@cCountry,@cIndex,@cRegion,@cCity,@cStreet,@cHouse)

    if !Empty(cINN)
        lOk = .T.
    endif    

return lOk


/*/{Protheus.doc} GetBuyer
     returns buyer info info & address

     @type Function
     @parameter cPrintdate char, date of printing (for address validity), in
     @parameter cBuyerCod char, buyers code, in
     @parameter cBuyerLoj char, buyers dept, in
     @parameter cCompName char, out
     @parameter cINN char, out
     @parameter cKPP char, out
     @parameter cCountry char, out
     @parameter cIndex char, out
     @parameter cRegion char, out
     @parameter cCity char, out
     @parameter cStreet char, out
     @parameter cHouse char, out
     @return lOk, Boolean

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function GetBuyer(cPrintdate,cBuyerCod,cBuyerLoj,cCompName,cINN,cKPP,cCountry,cIndex,cRegion,cCity,cStreet,cHouse) 
    Local lOk := .F.  
    Local aArea      As Array
    Local cByerodent := ""

    cCompName := ""
    cINN   := "" 
    cKPP := ""
    aArea := GetArea()

    DbSelectArea("SA1")
    dbSetOrder(1)
    If dbseek(XFilial("SA1")+cBuyerCod+cBuyerLoj)
        cCompName := AllTrim(SA1->A1_NOME)
        cCompName  := StrTran(cCompName,_QUOTESIGN,_QUOTEESC)

        cINN   := AllTrim(SA1->A1_CODZON)
        cKPP := AllTrim(SA1->A1_INSCGAN)

        cByerodent  := XFilial("SA1")+cBuyerCod+cBuyerLoj
        GetAdress("SA1",cByerodent,"0",cPrintDate,@cCountry,@cIndex,@cRegion,@cCity,@cStreet,@cHouse)
    EndIf 

    if !Empty(cINN)
        lOk = .T.
    endif    

return lOk

/*/{Protheus.doc} GetDocItms
     returns buyer info info & address

     @type Function
     @parameter cSerie char, doc series, in
     @parameter cDocno char, doc number, in
     @parameter cClient char, client/buyer code, in
     @parameter aItems array, document items, out
     @parameter nSumNET numeric, amount net, out
     @parameter nSumTOT numeric, amount gross, out
     @parameter nSumVAT numeric, amount vat, out
     @parameter nQtyNet numeric, quantity (pcs only), out
     @return lOk, Boolean

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function GetDocItms(cDocKey, cClient, aItems, nSumNET, nSumTOT, nSumVAT, nQtyNet)
    
    Local oStatement As Object
    Local cQuery := " " 
    Local aArea      As Array
    Local cTab       As Character
    Local lOk := .F.
    local nCnt := 1
    local cPcsCod := _PCSCODE

    nSumNET := 0
    nSumTOT := 0
    nSumVAT := 0 
    nQtyNet := 0

    aArea := GetArea()
    
    cQuery += " select "
    cQuery += " B1_DESC, "
    cQuery += " AH_CODOKEI," 
    cQuery += " F36_QUANT, " // qty
    cQuery += " F36_VUNIT," //price
    cQuery += " F36_VALUE, "//net amount
    cQuery += " F36_VATRT," // vat rate (%)
    cQuery += " F36_VALGR," // gross amount
    cQuery += " F36_VATVL, " // vat value
    cQuery += " F36_ITMCOD," 
    cQuery += " B1_UM "
    cQuery += " from "+RetSqlName("F36")+" f36 "
    cQuery += " join "+RetSqlName("SB1")+" sb1 on F36_ITMCOD = B1_COD and SB1.D_E_L_E_T_ = '' and B1_FILIAL = '"+xFilial("SB1")+"' "
    cQuery += " join "+RetSqlName("SAH")+" sah on B1_UM = AH_UNIMED and SAH.D_E_L_E_T_ = '' and AH_FILIAL = '"+xFilial("SAH")+"' "
    cQuery += " where F36_KEY = '"+cDocKey+"'"
    cQuery += " and F36_FILIAL = '"+xFilial("F36")+"'"
    cQuery += " and F36.d_e_l_e_t_ = ''"

    oStatement := FWPreparedStatement():New(cQuery)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    While (cTab)->(!EOF())
        AAdd(aItems, {nCnt, ;
            Alltrim((cTab)->B1_DESC), ;
            Alltrim((cTab)->AH_CODOKEI), ;
            (cTab)->F36_QUANT, ;
            (cTab)->F36_VUNIT, ;
            (cTab)->F36_VALUE, ;
            (cTab)->F36_VATRT, ;
            (cTab)->F36_VALGR, ; 
            (cTab)->F36_VATVL, ;
            Alltrim((cTab)->F36_ITMCOD), ;
            Alltrim((cTab)->B1_UM) ;
        } )
        (cTab)->(dbSkip())
        nCnt += 1
        if Alltrim((cTab)->AH_CODOKEI) == cPcsCod
            nQtyNet += (cTab)->F36_QUANT
        endif
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    // get totals
    cQuery := " select "
    cQuery += " Sum(F36_VALUE) as Net, "//net amount
    cQuery += " Sum(F36_VALGR) as Gross," // gross amount
    cQuery += " Sum(F36_VATVL) as Vat " // vat value
    cQuery += " from "+RetSqlName("F36")+" f36 "
    cQuery += " where F36_KEY = '"+cDocKey+"'"
    cQuery += " and F36_FILIAL = '"+xFilial("F36")+"'"
    cQuery += " and F36.d_e_l_e_t_ = ''"

    oStatement := FWPreparedStatement():New(cQuery)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    nSumNET := (cTab)->Net
    nSumTOT := (cTab)->Gross
    nSumVAT := (cTab)->Vat

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    
    DBSelectArea(aArea)

return lOk


/*/{Protheus.doc} MyParamBox
     returns user input for selection of document to export

     @type Function
     @return lRes, Boolean

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function MyParamBox()
   local aParamBox := {}
   local aRet := {} 
   local lRes := .F.
   Local cLoad := 'ZKONTUR3'

    BoxParamAdd(@aParamBox,"F35_CLIENT","Client","SA1",.T.)
    BoxParamAdd(@aParamBox,"F35_BRANCH","Branch","",.T.)
    BoxParamAdd(@aParamBox,"F35_PDATE","Doc Date","",.T.)
    BoxParamAdd(@aParamBox,"F35_DOC","Doc No","",.T.)
    BoxParamAdd(@aParamBox,"F35_TYPE","Doc Type","",.F.)

    lRes := ParamBox(aParamBox,STR0006,@aRet,/*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosx*/,/*nPosy*/,/*oMainDlg*/,cLoad,.T.,.T.)//STR0006="Document selection"

Return lRes

/*/{Protheus.doc} MyParamBox
     adds parambox parameter

     @type Function
     @return Nil

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/static function BoxParamAdd(aParamBox,cFldName,cText,cF3,lMandatory)
    local cValid := ''

    aAdd(aParamBox,{1,cText,Space(TamSx3(cFldName)[1]),"",cValid,cF3,"",TamSx3(cFldName)[1],lMandatory})
Return

/*/{Protheus.doc} GetAdress
     returns buyer info info & address

     @type Function
     @parameter cAliasP
     @parameter cKeyP
     @parameter cTipo
     @parameter cDate
     @parameter cCountry
     @parameter cIndex
     @parameter cRegion
     @parameter cCity
     @parameter cStreet
     @parameter cHouse
     @return lOk, Boolean

     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
Static Function GetAdress(cAliasP,cKeyP,cTipo,cDate,cCountry,cIndex,cRegion,cCity,cStreet,cHouse)

    Local cQuery 	As Character
    Local cTab 		As Character


    cIndex  := ""
    cRegion := ""
    cCity   := ""
    cStreet := ""
    cHouse  := ""
    cCountry := ""

    if (!empty(cAliasP) .and. !empty(cKeyP) .and. !empty(cTipo))
        cQuery := " SELECT AGA.R_E_C_N_O_ AS AGAREC FROM " + RetSqlName("AGA") + " AGA "
        cQuery += " WHERE AGA.AGA_FILIAL = '"+xFilial("AGA")+"'"
        cQuery += " AND AGA_ENTIDA = '" + cAliasP + "'"
        cQuery += " AND AGA_CODENT = '" + cKeyP + "'"
        cQuery += " AND AGA_TIPO = '" + cTipo + "'"
        If !empty(cDate)
           // cQuery += " AND AGA.AGA_FROM <= '" + cDate +  "' AND AGA.AGA_TO >= '" + cDate +  "' "
        endif
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        cTab := MPSysOpenQuery(cQuery)

        If (cTab)->(!EOF())
            AGA->(dbGoTo((cTab)->AGAREC))
            cCountry := ALLTRIM(AGA->AGA_PAIS)
            cIndex  := ALLTRIM(AGA->AGA_CEP)
            cRegion := ALLTRIM(AGA->AGA_EST)
            cCity   := ALLTRIM(AGA->AGA_MUNDES)
            cStreet := ALLTRIM(AGA->AGA_END)
            cHouse  := ALLTRIM(AGA->AGA_HOUSE)
        Else
        cAgaFull        := " "
        EndIf
        (cTab)->( dbCloseArea() )
    endif
Return

/*/
{Protheus.doc} GetMyAgacodent()
     returns aga_codent of our company, depends on level
    @type Function
    @params nLevel, Numeric, CO_TIPO
            nLevel = 0 - Group company
            nLevel = 1 - Company
            nLevel = 2 - Buisness unit
            nLevel = 3 - Filial 
    @author 
    @since 
    @version 
    @return cAGACodent
    @example 
/*/
Static Function GetMyAgacodent(nLevel)
    local cAGACodent    As Character
    Local aArea         As Array
    Default nLevel := 3

    aArea	:= GetArea()
    DbSelectArea("XX8")
    XX8->(dbSetOrder(1))
    XX8->(dbGoTop())
    

    cAGACodent := xFilial("AGA")+PADR(FWGrpCompany(),LEN(XX8->XX8_GRPEMP))+IIF(nLevel == 0, "0" , "")
    //0 - XX8_TIPO

    If nLevel >= 1 
        cAGACodent += PADR(FWCompany(),LEN(XX8->XX8_EMPR) )+IIF(nLevel == 1, "1" , "")
        //1 - XX8_TIPO
        If nLevel >= 2 
            cAGACodent += PADR(FWUnitBusiness(),LEN(XX8->XX8_UNID) ) +IIF(nLevel == 2, "2" , "")
            //2 - XX8_TIPO
            If nLevel == 3
                cAGACodent += PADR(FWFilial(),LEN(XX8->XX8_CODIGO) ) 
            EndIf
        Endif
    EndIf
    RestArea(aArea)
Return cAGACodent

/*/
{Protheus.doc} GetCompnInf()
    Get information about company
    @type Function
    @params cType, Character, CO_TIPO
           cType = 0 - Group company
           cType = 1 - Company
           cType = 2 - Buisness unit
        cGroupCode  , Character, CO_COMPGRP
        cCompanyCode, Character, CO_COMPEMP
        cBusUnitCode, Character, CO_COMPUNI
    @author 
    @since 
    @version 
    @return aCompanyInfo
            aCompanyInfo[1] - CO_FULLNAM // Full name.
            aCompanyInfo[2] - CO_INN // INN. 
            aCompanyInfo[3] - CO_KPP // KPP.
            aCompanyInfo[4] - CO_TYPE // CO_TYPE
            aCompanyInfo[5] - CO_OGRN // CO_OGRN
    @example GetCompnInf(nType, cGroupCode, cCompanyCode, cBusUnitCode)
/*/
Static Function GetCompnInf(cType, cGroupCode, cCompanyCode, cBusUnitCode)
    Local cQuery := ""          As Character
    Local oStatement := Nil     As Object
    Local aArea := GetArea()    As Array
    Local aCompanyInfo := {}    As Array

    // Make SQL query.
    cQuery := " SELECT CO_TIPO, CO_COMPGRP, CO_COMPEMP, CO_COMPUNI, CO_FULLNAM, CO_SHORTNM, CO_INN, CO_KPP, CO_PHONENU, CO_OKVED, CO_OKTMO, CO_LOCLTAX, CO_TYPE, CO_OGRN "
    cQuery += " FROM SYS_COMPANY_L_RUS " 
    cQuery += " WHERE "
    cQuery += "         CO_TIPO = ? "
    If(Val(cType) >= 0)
        cQuery += " AND CO_COMPGRP = ?  "
    EndIf
    If(Val(cType) >= 1)
        cQuery += " AND CO_COMPEMP = ?  "
    EndIf
    If(Val(cType) == 2)
        cQuery += " AND CO_COMPUNI = ?  "
    EndIf
    cQuery += "     AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cType)
    If(Val(cType) >= 0)
        oStatement:SetString(2, cGroupCode)
    EndIf
    If(Val(cType) >= 1)
        oStatement:SetString(3, cCompanyCode)
    EndIf
    If(Val(cType) == 2)
        oStatement:SetString(4, cBusUnitCode)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    While !(cTab)->(Eof())
        
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_FULLNAM)) // Full name.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_INN    )) // INN.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_KPP    )) // KPP.
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_TYPE   ))// CO_TYPE
        aAdd(aCompanyInfo, Alltrim((cTab)->CO_OGRN   ))// CO_OGRN

        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())

    If Type("oStatement") <> "U"
        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)

Return aCompanyInfo


/*/
{Protheus.doc} GetBranchInf()
    Get information about filial(branch)
    @type Function
    @params cGroupCode  , Character, BR_COMPGRP
            cCompanyCode, Character, BR_COMPEMP
            cBusUnitCode, Character, BR_COMPUNI
            cFilialCode , Character, BR_BRANCH
    @author 
    @since 
    @version 
    @return aBranchInfo
            aBranchInfo[1] - BR_TYPE // Type of filial
            aBranchInfo[2] - BR_KPP // KPP. 
            aBranchInfo[2] - BR_FULLNAM // Full name of the branch
    @example GetBranchInf(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
/*/
Static Function GetBranchInf(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
    Local cQuery := ""          As Character
    Local oStatement := Nil     As Object
    Local aArea := GetArea()    As Array
    Local aBranchInfo := {}     As Array

    // Make SQL query.
    cQuery := " SELECT BR_BRANCH, BR_TYPE, BR_FULLNAM, BR_KPP "
    cQuery += " FROM SYS_BRANCH_L_RUS " 
    cQuery += " WHERE "
    cQuery += "         BR_COMPGRP = ? "
    cQuery += "     AND BR_COMPEMP = ? "
    cQuery += "     AND BR_COMPUNI = ? "
    cQuery += "     AND BR_BRANCH  = ? "
    cQuery += "     AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cGroupCode  )
    oStatement:SetString(2, cCompanyCode)
    oStatement:SetString(3, cBusUnitCode)
    oStatement:SetString(4, cFilialCode )

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    While !(cTab)->(Eof())
        
        aAdd(aBranchInfo, Alltrim((cTab)->BR_TYPE)) // Type of filial.
        aAdd(aBranchInfo, Alltrim((cTab)->BR_KPP )) // KPP.
        aAdd(aBranchInfo, Alltrim((cTab)->BR_FULLNAM))// Full name of the branch

        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())

    If Type("oStatement") <> "U"
        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)

Return aBranchInfo

/*/{Protheus.doc} FormatDate
     returns user input for selection of document to export

     @type Function
     @return cFdata char formatted data
     @parameter cData char date
     @author mpopenker
     @since 04.06.2024
     @version 12.1.2310
*/
static function FormatDate(cData) // 20230927 -> 27.09.2023
   local cFData as character

   cFData := Substr(alltrim(cData), 7, 2) + "." + Substr(alltrim(cData), 5, 2) + "." + Substr(alltrim(cData), 1, 4) 

Return cFData
                   
//Merge Russia R14 
                   
