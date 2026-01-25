#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

Static __lV3UPerApu := nil
//-------------------------------------------------------------------
/*/{Protheus.doc} WSQry4010()
Query dos pendentes de apuração e relatorio R4010

@author Denis Souza
@since 25/10/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function WSQry4010( cPerApu, aFil, aInfEUF, nPage, nSize, lAll, oPrepare )

Local cCompC1H   as character
Local cDataIni   as character
Local cDataFim   as character
Local cDtConta   as character
Local cBd		 as character
Local cQuery     as character
Local cQryRel    as character
Local cQryTot    as character
Local cIsNull	 as character
Local cTopRow    as character
Local cQueryFin  as character
Local lHasNext   as logical
Local lRowNum    as logical
Local lApuSTri   as logical
Local nTotReg    as numeric
Local nV3SIdNatR as numeric
Local nC30CNatRe as numeric
Local nV3VCNatRe as numeric
Local nTmPrId40  as numeric
Local nI         as numeric
Local aBind      as array
Local aFilsC20   as array
Local oPrepTot   as object

Default cPerApu  := ""
Default aFil     := {}
Default aInfEUF  := {}
Default nPage 	 := 1
Default nSize 	 := 20
Default lAll     := .F.
Default oPrepare := Nil

cQuery     := ""
cQryRel    := ""
cQryTot    := ""
cIsNull    := ""
cDataIni   := cPerApu + "01" //ex: 20220201
cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
cDtConta   := SuperGetMv('MV_TAFDT40',.F.,'2')
cAlias	   := ""
cAliasTot  := ""
cTopRow    := ""
cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cBd		   := Upper(AllTrim(TcGetDb()))
aFilsC20   := Separa(StrTran(StrTran(StrTran(TafRetFilC("C20", aFil),"(",""),")",""),"'",""),",")
lHasNext   := .F.
nTotReg    := 0
nV3SIdNatR := FWSX3Util():GetFieldStruct('V3S_IDNATR')[3]
nC30CNatRe := FWSX3Util():GetFieldStruct('C30_CNATRE')[3]
nV3VCNatRe := FWSX3Util():GetFieldStruct('V3V_CNATRE')[3]
nTmPrId40  := FWSX3Util():GetFieldStruct('C20_PRID40')[3]
nI         := 0
lRowNum    := Iif(FindFunction("TafBdVers"),TafBdVers(),.F.)
lApuSTri   := SuperGetMv('MV_TAFSTRI',.F.,.F.)
aBind      := {}
oPrepTot   := Nil

cIsNull := Iif(!("INFORMIX" $ cBd), "COALESCE", "NVL")

cQuery := " TMP.FILIAL, TMP.CPF, TMP.NIF,  TMP.CODPAR,  TMP.NOME, TMP.QTDDOC, TMP.VLBRUT, TMP.BASECA, TMP.VLTRIB, TMP.VLDED, TMP.VLD FROM ( "
cQuery += " SELECT TMPA.FILIAL FILIAL, TMPA.CPF CPF , TMPA.NIF NIF , TMPA.CODPAR CODPAR, TMPA.NOME NOME, COUNT(TMPA.DOCTO) QTDDOC, SUM(TMPA.VLBRUT) VLBRUT, "
cQuery += " SUM(TMPA.BASECA) BASECA, SUM(TMPA.VLTRIB) VLTRIB,  SUM(TMPA.VLDED) VLDED, MIN(TMPA.VLD) VLD FROM ( "
cQuery += " SELECT TBGER.FILIAL, TBGER.CPF, TBGER.NIF, TBGER.CODPAR, TBGER.DOCTO, TBGER.SERIE, SUM(TBGER.VLBRUT) VLBRUT, SUM(TBGER.BASECA) BASECA, "
cQuery += " SUM(TBGER.VLTRIB) VLTRIB, SUM(TBGER.VLDED) VLDED "
cQuery += ", " + QryFilNome(cBd,cCompC1H,aInfEUF,@aBind)
cQuery += " , CASE WHEN MIN( TBGER.PRID40 ) = ? THEN ? ELSE ? END VLD "
aadd(aBind, space(1))
aadd(aBind, 'notValidated')
aadd(aBind, 'validated')

cQuery += " FROM ( "

//Importante: O cQryRel sera utilizado para o relatorio analitico, posteriormente o conteudo eh agregado no cQuery
cQryRel := " SELECT DISTINCT 'FAT' ROTINA, LEM.LEM_FILIAL FILIAL, LEM.LEM_NUMERO DOCTO, LEM.LEM_PREFIX SERIE, ' ' SEQUEN, C1H.C1H_CPF CPF, "
cQryRel += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIF ELSE ? END NIF, "
cQryRel += " CASE WHEN (C1H.C1H_PAISEX <> ? AND C1H.C1H_NIF = ? ) THEN C1H.C1H_CODPAR ELSE ? END CODPAR, "
cQryRel += cIsNull + " (V3S.V3S_VALOR, 0) VLBRUT, " + cIsNull + " (V47.V47_BASECA, 0) BASECA, " + cIsNull + "(V47.V47_VLTRIB, 0) VLTRIB, "
cQryRel += " ( SELECT SUM( " + cIsNull + " (V4L.V4L_VLRDED, 0) ) FROM " + RetSqlName("V4L") + " V4L WHERE "
cQryRel += " V4L.V4L_FILIAL = LEM.LEM_FILIAL AND V4L.V4L_ID = LEM.LEM_ID AND V4L.V4L_IDPART = LEM.LEM_IDPART AND V4L.V4L_NUMFAT = LEM.LEM_NUMERO "
cQryRel += " AND V4L.V4L_IDNATR = V3S.V3S_IDNATR AND V4L.V4L_DECTER = V3S.V3S_DECTER AND V4L.V4L_IDTRIB = V47.V47_IDTRIB AND V4L.D_E_L_E_T_ = ?) VLDED, "
cQryRel += " LEM.LEM_PRID40 PRID40 "
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))

cQryRel += QryFilFat(cCompC1H,aInfEUF,nV3SIdNatR,aFilsC20,cDataIni,cDataFim,nTmPrId40,,,,,cDtConta,lApuSTri,,@aBind)

cQryRel += " UNION ALL "

cQryRel += " SELECT 'NFS' ROTINA, C20.C20_FILIAL FILIAL, C20.C20_NUMDOC DOCTO, C20.C20_SERIE SERIE,? SEQUEN, C1H.C1H_CPF CPF, "
cQryRel += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIF ELSE ? END NIF, "
cQryRel += " CASE WHEN (C1H.C1H_PAISEX <> ? AND C1H.C1H_NIF = ? )  THEN C1H.C1H_CODPAR ELSE ? END CODPAR, "
cQryRel += cIsNull + " (SUM(C30.C30_TOTAL),0) VLBRUT, " + cIsNull + " (SUM(C35.C35_BASE),0) BASECA, " + cIsNull + " (SUM(C35.C35_VALOR),0) VLTRIB, "
cQryRel += " ( SELECT SUM( " + cIsNull + " (V4C.V4C_VLRDED,0) ) VLDED FROM " + RetSqlName("V4C") + " V4C "
cQryRel += " WHERE  V4C.V4C_FILIAL = C20.C20_FILIAL AND V4C.V4C_CHVNF = C20.C20_CHVNF AND V4C.D_E_L_E_T_ = ?) VLDED, "
cQryRel += " MIN(C20.C20_PRID40) PRID40 "
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))

cQryRel += QryFilNota(cCompC1H,aInfEUF,nC30CNatRe,aFilsC20,cDataIni,cDataFim,nTmPrId40,,,,,cDtConta,lApuSTri,,@aBind)

cQryRel += " UNION ALL "

cQryRel += " SELECT 'PGT' ROTINA, V3U.V3U_FILIAL FILIAL, V3U.V3U_NUMERO DOCTO, V3U.V3U_SERIE SERIE, V3U.V3U_SEQUEN SEQUEN, C1H.C1H_CPF CPF, "
cQryRel += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIF ELSE ? END NIF, "
cQryRel += " CASE WHEN (C1H.C1H_PAISEX <> ? AND C1H.C1H_NIF = ? ) THEN C1H.C1H_CODPAR ELSE ? END CODPAR, "
cQryRel += cIsNull + " (V3V.V3V_VALOR, 0) VLBRUT, " + cIsNull + " (V46.V46_BASE, 0) BASECA, " + cIsNull + " (V46.V46_VALOR, 0) VLTRIB, "
cQryRel += " ( SELECT SUM( " + cIsNull + "(V4I.V4I_VLRDED,0) ) FROM " + RetSqlName("V4I") + " V4I WHERE V4I.V4I_FILIAL = V3U.V3U_FILIAL "
cQryRel += " AND V4I.V4I_ID = V3U.V3U_ID AND V4I.V4I_IDNAT = V3V.V3V_CNATRE AND V4I.V4I_IDTRIB = V46.V46_IDTRIB AND V4I.D_E_L_E_T_ = ?) VLDED, "
cQryRel += " V3U.V3U_PRID40 PRID40 "
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))

cQryRel += QryFilPgto(cCompC1H,aInfEUF,nV3VCNatRe,aFilsC20,cDataIni,cDataFim,nTmPrId40,,,,,lApuSTri,,@aBind)

cQryRel += " UNION ALL"

cQryRel += " SELECT 'PLS' ROTINA, "
cQryRel += " V4B.V4B_FILIAL FILIAL, "
cQryRel += " V4B.V4B_ID DOCTO, "
cQryRel += " ' ' SERIE, "
cQryRel += " ' ' SEQUEN, "
cQryRel += " C1H.C1H_CPF CPF, "
cQryRel += " CASE WHEN C1H.C1H_PAISEX <> ? THEN C1H.C1H_NIF ELSE ? END NIF, "
cQryRel += " CASE WHEN (C1H.C1H_PAISEX <> ? AND C1H.C1H_NIF = ? ) THEN C1H.C1H_CODPAR ELSE ? END CODPAR, "
cQryRel += " 0 VLBRUT, 0 BASECA, 0 VLTRIB, 0 VLDED, V4B.V4B_PRID40 PRID40 "
cQryRel += " FROM " + RetSqlName("V4B") + " V4B "
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))
aadd(aBind, space(1))

cQryRel += QryFilReemb(cCompC1H,aInfEUF,aFilsC20,cDataIni,cDataFim,nTmPrId40,,,,@aBind)

cQuery  += cQryRel
cQuery  += " ) TBGER GROUP BY TBGER.FILIAL, TBGER.CPF, TBGER.NIF, TBGER.CODPAR,TBGER.DOCTO, TBGER.SERIE "
cQuery  += " ) TMPA "
cQuery  += " GROUP BY TMPA.FILIAL,  TMPA.CPF,  TMPA.NIF, TMPA.CODPAR, TMPA.NOME) TMP "

If !lAll .And. nPage > 0 .And. nSize > 0 //paginacao e contagem considerando os dados ja agrupados
	cAliasTot := GetNextAlias()
	cQryTot := " SELECT COUNT(TBTOT.FILIAL || TBTOT.CPF || TBTOT.NIF || TBTOT.CODPAR ) QTDREG FROM ( SELECT " + cQuery + " ) TBTOT " 
	
	If !("DB2" $ cBd )
		cQryTot := ChangeQuery(cQryTot)
	endif

	oPrepTot := FwExecStatement():New(cQryTot)

	For nI := 1 To Len(aBind)
		If Valtype(aBind[nI]) == 'C'
			oPrepTot:setString( nI, aBind[nI] )
		ElseIf Valtype(aBind[nI]) == 'N'
			oPrepTot:setNumeric( nI, aBind[nI] )
		ElseIf Valtype(aBind[nI]) == 'A'
			oPrepTot:setIn( nI, aBind[nI] )
		Endif
	Next nI

	oPrepTot:cbasequery := oPrepTot:getfixquery()
	oPrepTot:OpenAlias(cAliasTot)

	If ( cAliasTot )->( !Eof() )
		nTotReg := (cAliasTot)->QTDREG
	EndIf

	(cAliasTot)->(DBCloseArea())

	If oPrepTot != Nil
		oPrepTot:Destroy()
		freeobj(oPrepTot)
		oPrepTot := nil
	EndIf

	lHasNext := Iif((nPage * nSize) >= nTotReg, .F., .T.)
EndIf

If !lAll .And. lRowNum .And. nPage > 0 .And. nSize > 0
	cQueryFin := "SELECT TAB.LINE_NUMBER,TAB.VLD,TAB.FILIAL,TAB.CPF,TAB.NIF,TAB.CODPAR,TAB.QTDDOC,TAB.VLBRUT,TAB.BASECA,TAB.VLTRIB,TAB.NOME,TAB.VLDED "
	cQueryFin += "FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY TMP.VLD, TMP.FILIAL, TMP.CPF ) LINE_NUMBER, " + cQuery + " ) TAB "
	cQueryFin += "WHERE TAB.LINE_NUMBER BETWEEN ? AND ? "
	aadd(aBind, cValToChar(((nPage-1)*nSize) +1))
	aadd(aBind, cValToChar(nSize*nPage))
ElseIf !lAll .And. !lRowNum .And. nPage > 0 .And. nSize > 0
	cQueryFin := "SELECT " + cQuery + " ORDER BY TMP.VLD, TMP.FILIAL, TMP.CPF "
	cQueryFin += "OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nSize) + " ) ROWS "
	cQueryFin += "FETCH NEXT " + cValToChar(nSize) + " ROWS ONLY "
EndIf

If lAll	.And. nPage == 0 .And. nSize == 0
	cQueryFin := " SELECT " + cQuery + " ORDER BY TMP.VLD, TMP.FILIAL, TMP.CPF "
	lHasNext  := .F.
EndIf

If !("DB2" $ cBd )
	cQueryFin := ChangeQuery( cQueryFin )
EndIf

cAlias := GetNextAlias()

oPrepare := FwExecStatement():New(cQueryFin)

For nI := 1 To Len(aBind)
	If Valtype(aBind[nI]) == 'C'
		oPrepare:setString( nI, aBind[nI] )
	ElseIf Valtype(aBind[nI]) == 'N'
		oPrepare:setNumeric( nI, aBind[nI] )
	ElseIf Valtype(aBind[nI]) == 'A'
	    oPrepare:setIn( nI, aBind[nI] )
	Endif
Next nI

oPrepare:cbasequery := oPrepare:getfixquery()
oPrepare:OpenAlias(cAlias)

aSize(aBind,0)

Return {cAlias, nTotReg, lHasNext}

//-------------------------------------------------------------------
/*/{Protheus.doc} TafJoinC1H()
Tratamento de Join com a C1H

@author Denis Souza
@since 26/10/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function TafJoinC1H( cCompC1H , aInfEUF, cCmpJoin)

Local cString    := ''
Default cCompC1H := ''
Default aInfEUF  := {}
Default cCmpJoin := ''

If cCompC1H == "EEE"
	cString := " C1H.C1H_FILIAL = " + cCmpJoin
Else
	If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cString := " LTRIM(RTRIM(SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) = LTRIM(RTRIM(SUBSTRING(" + cCmpJoin + ", 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cString := " LTRIM(RTRIM(SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1]) + "))) = LTRIM(RTRIM(SUBSTRING(" +cCmpJoin + ", 1," + cValToChar(aInfEUF[1]) + "))) "
	//Necessario pois a filial faz parte do indice do bd, tratamento totalmente compartilhado ou sem gestão de empresa com compartilhado apenas no modo (filial).
	Else
		cString := " C1H.C1H_FILIAL = '" + xFilial( "C1H" ) + "' "
	EndIf
EndIf

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0024010()
Monta Json de acordo com a query

@author Denis Souza
@since 25/10/2022
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Function WS0024010(aApurac, oEstruct, cPeriodo, cEvent, aFiliais, lAll, oValidationError)

local cAliasR4010  As character
local cBranch	   As character
local cFil		   As character
local cStatus	   As character
local cCPF		   As character
local nTSintetic   As numeric
local lhasNext     As logical
local lValid	   As logical
local lEmptyPrId40 As logical
local aFilCPF	   As Array

Default aApurac  := {'',0,.F.}
Default oEstruct := Nil
Default cPeriodo := '' 
Default cEvent 	 := ''
Default aFiliais := {}
Default lAll     := .F.
Default oValidationError := Nil

cAliasR4010 := aApurac[1]
lhasNext    := aApurac[3]
cBranch		:= ""
nTSintetic 	:= 0

lEmptyPrId40 := .T.
lValid  	 := .F.
aFilCPF      := {}

if oValidationError == Nil
	oValidationError := JsonObject():New()
endif
if oValidationError["registryKey"] == Nil
	oValidationError["registryKey"] := {}
endif

if !(cAliasR4010)->(EOF())

	(cAliasR4010)->(DbGoTop())

	While !(cAliasR4010)->(EOF())
		aadd(oEstruct["eventDetail"],JsonObject():New())
		nTSintetic := len(oEstruct["eventDetail"])
		cFil 	:= (cAliasR4010)->FILIAL
		cCPF	:= (cAliasR4010)->CPF
		cStatus := iif(Lower(Alltrim((cAliasR4010)->VLD))=="notvalidated","notValidated","validated")
		oEstruct["eventDetail"][nTSintetic]["status"]          := cStatus
		oEstruct["eventDetail"][nTSintetic]["branchId"]        := cFil
		oEstruct["eventDetail"][nTSintetic]["providerCPF"]     := cCPF
		oEstruct["eventDetail"][nTSintetic]["key"]			   := cCPF 
		oEstruct["eventDetail"][nTSintetic]["providerName"]    := alltrim(EncodeUTF8((cAliasR4010)->NOME)) 
		oEstruct["eventDetail"][nTSintetic]["totalDocs"]       := (cAliasR4010)->QTDDOC
		oEstruct["eventDetail"][nTSintetic]["grossAmount"]     := (cAliasR4010)->VLBRUT
		oEstruct["eventDetail"][nTSintetic]["incomeTaxAmount"] := (cAliasR4010)->VLTRIB
		oEstruct["eventDetail"][nTSintetic]["incomeTaxBase"]   := (cAliasR4010)->(BASECA+VLDED)
		oEstruct["eventDetail"][nTSintetic]["providerCode"]    := (cAliasR4010)->CODPAR
		oEstruct["eventDetail"][nTSintetic]["nif"]    		   := (cAliasR4010)->NIF

		oEstruct["eventDetail"][nTSintetic]["errors"]          := 'errors'
		If Len(oValidationError["registryKey"]) > 0 // Chave de busca do erro da apuração			
			oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"] := KeyError( oEstruct["eventDetail"][nTSintetic] , oValidationError )
		EndIf
		(cAliasR4010)->(dbSkip())
	EndDo
else
	aadd(oEstruct["eventDetail"],JsonObject():New())
	oEstruct["eventDetail"] := {}
endif

oEstruct['hasNext'] := lhasNext

(cAliasR4010)->(DBCloseArea())

aSize(aFilCPF,0)
aFilCPF := {}

Return oEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilNome        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilNome(cBd,cCompC1H,aInfEUF,aBind)

Local cQry  as character
Local cTop  as character
Local cTopRow as character

Default cBd      := ''
Default cCompC1H := ''
Default aInfEUF  := {}
Default aBind    := {}

cQry 	:= ""
cTop	:= ""
cTopRow := ""

Iif( cBd $ "INFORMIX", cTop += " C1H_NOME FROM (SELECT FIRST 1 C1H.C1H_NOME ", cTop += "")  
Iif( cBd $ "INFORMIX", cTopRow += " ) ", cTopRow += "")  

cQry := " ( SELECT "
If cBd $ "ORACLE|POSTGRES|DB2"
	cTop += " C1H.C1H_NOME "
	If cBd $ "ORACLE"
		cTopRow := " AND ROWNUM <= ? "
	ElseIf cBd $ "POSTGRES|DB2"
		cTopRow := " LIMIT ? "
	EndIf
ElseIf cBd $ "MSSQL7|MSSQL"
	cTop += " MAX(C1H.C1H_NOME) "
Endif

cQry += cTop
cQry += " FROM " + RetSqlName("C1H") + " C1H WHERE "
cQry += TafJoinC1H( cCompC1H , aInfEUF, "TBGER.FILIAL" )
cQry += " AND ((TBGER.CPF <> ? AND C1H.C1H_CPF = TBGER.CPF AND C1H.C1H_PPES = ? ) "
cQry += " OR ( TBGER.CODPAR <> ? AND C1H.C1H_CODPAR = TBGER.CODPAR AND C1H.C1H_PEEXTE = ?) "
cQry += " OR (TBGER.NIF <> ? AND C1H.C1H_NIF = TBGER.NIF AND C1H.C1H_PEEXTE = ?)) "
cQry += " AND C1H.D_E_L_E_T_ = ? "
aadd(aBind, space(1))
aadd(aBind, '1')
aadd(aBind, space(1))
aadd(aBind, '1')
aadd(aBind, space(1))
aadd(aBind, '1')
aadd(aBind, space(1))
          
If cBd $ "ORACLE|INFORMIX|DB2"
	cQry += cTopRow
	aadd(aBind, 1)
EndIf
If cBd $ "POSTGRES"
	cQry += " ORDER BY C1H.C1H_FILIAL " + cTopRow
	aadd(aBind, 1)
EndIf

cQry += " ) NOME "

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilFat        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilFat(cCompC1H,aInfEUF,nV3SIdNatR,aFilsC20,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F,nLevel,cDtConta,lApuSTri,cFilDoc,aBind)

Local cQry := ''

Default cCompC1H   := ''
Default aInfEUF	   := {}
Default nV3SIdNatR := 0
Default aFilsC20   := {}		
Default cDataIni   := ''
Default cDataFim   := ''
Default nTmPrId40  := 0
Default lReport    := .F.
Default cCompV3X   := ''
Default cCompV4F   := ''
Default nLevel     := 1
Default cDtConta   := '2'
Default lApuSTri   := .F.
Default cFilDoc    := cFilAnt
Default aBind      := {}

cQry := " FROM " + RetSqlName("LEM") + " LEM "
cQry += " INNER JOIN " + RetSqlName("C1H") + " C1H ON "
cQry += TafJoinC1H( cCompC1H , aInfEUF, "LEM.LEM_FILIAL" )
cQry += " AND C1H.C1H_ID = LEM.LEM_IDPART AND ((C1H.C1H_CPF <> ? AND C1H.C1H_PPES = ?) OR (C1H.C1H_PEEXTE = ? AND C1H.C1H_PAISEX <> ?) ) AND C1H.D_E_L_E_T_ = ? "
aadd(aBind, space(1))
aadd(aBind, '1')
aadd(aBind, '1')
aadd(aBind, space(1))
aadd(aBind, space(1)) 

if lReport
	cQry += " LEFT JOIN " + RetSqlName("T9A") + " T9A ON T9A.T9A_FILIAL = ? AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ? "
	aadd(aBind, xFilial("T9A")) 
	aadd(aBind, space(1)) 
endif

cQry += " INNER JOIN " + RetSqlName("V3S") + " V3S ON "
cQry += " V3S.V3S_FILIAL = LEM.LEM_FILIAL AND V3S.V3S_ID = LEM.LEM_ID AND V3S.V3S_IDPART = LEM.LEM_IDPART AND V3S.V3S_NUMFAT = LEM.LEM_NUMERO "
cQry += " AND V3S.V3S_IDNATR <> ? AND V3S.D_E_L_E_T_ = ? "
aadd(aBind, space(nV3SIdNatR))
aadd(aBind, space(1)) 

if lReport .Or. nLevel == 2
	cQry += " INNER JOIN " + RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = ? AND V3O.V3O_ID = V3S.V3S_IDNATR AND V3O.D_E_L_E_T_ = ? "
	aadd(aBind, xFilial("V3O"))
	aadd(aBind, space(1))
	If lReport .And. nLevel == 1
		cQry += " LEFT JOIN " + RetSqlName("V4F") + " V4F ON " //T160 ( V4F ) Despesas Processuais e RRA
		If cCompV4F == "EEE"
			cQry += " V4F.V4F_FILIAL = V3S.V3S_FILIAL "
		Else
			If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
				cQry += " LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V3S.V3S_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
			ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
				cQry += " LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V3S.V3S_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
			Else
				cQry += " V4F.V4F_FILIAL = ? "
				aadd(aBind, xFilial("V4F"))
			EndIf
		EndIf
		cQry += " AND V4F.V4F_ID = V3S.V3S_IDPROC AND V4F.D_E_L_E_T_ = ? "
		aadd(aBind, space(1))

		cQry += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON " //T159 ( V3X ) FCI e SCP
		If cCompV3X == "EEE"
			cQry += " V3X.V3X_FILIAL = LEM.LEM_FILIAL " 
		Else
			If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
				cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
			ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
				cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
			Else
				cQry += " V3X.V3X_FILIAL = ? "
				aadd(aBind, xFilial("V3X"))
			EndIf
		EndIf
		cQry += " AND V3X.V3X_ID = V3S.V3S_IFCISC AND V3X.D_E_L_E_T_ = ? "
		aadd(aBind, space(1))
	EndIf
endif

cQry += " LEFT JOIN " + RetSqlName("V47") + " V47 ON " //T154AH ( V47 ) Tributos do pagamento
cQry += " V47.V47_FILIAL = V3S.V3S_FILIAL AND V47.V47_ID = LEM.LEM_ID AND V47.V47_IDPART = LEM.LEM_IDPART AND V47.V47_NUMFAT = LEM.LEM_NUMERO AND V47.V47_IDNATR = V3S.V3S_IDNATR "
cQry += " AND V47.V47_DECTER = V3S.V3S_DECTER AND V47.V47_IDTRIB = ? AND V47.D_E_L_E_T_ = ? "
aadd(aBind, '000012')
aadd(aBind, space(1))

If nLevel == 1
	If "TMPFIL" $ aFilsC20[1]
		cQry += " WHERE LEM.LEM_FILIAL IN (" + aFilsC20[1] + ") AND "
	Else
		cQry += " WHERE LEM.LEM_FILIAL IN (?) AND "
		aadd(aBind,aFilsC20)
	EndIF
Elseif nLevel == 2
	cQry += " WHERE LEM.LEM_FILIAL = ? AND "
	aadd(aBind, xFilial('LEM', cFilDoc))
EndIf

cQry += " LEM."+ iif(cDtConta == '2','LEM_DTEMIS','LEM_DTCONT')+" BETWEEN ? AND ? AND "
cQry += " LEM.LEM_NATTIT = ? "
aadd(aBind, cDataIni)
aadd(aBind, cDataFim)
aadd(aBind, '0')
	
If lApuSTri
	cQry += " AND V3S.V3S_IDNATR IN (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.V3O_TRIB <> ? AND V3O.D_E_L_E_T_ = ?) "
	aadd(aBind, '8')
	aadd(aBind, space(1))
Else
	cQry += " AND V47.V47_IDTRIB IS NOT NULL "
EndIf

cQry += " AND LEM.D_E_L_E_T_ = ? "
aadd(aBind, space(1))

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilNota        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilNota(cCompC1H,aInfEUF,nC30CNatRe,aFilsC20,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F,nLevel,cDtConta,lApuSTri,cFilDoc,aBind)

Local cQry    := ''

Default cCompC1H   := ''
Default aInfEUF	   := {}
Default nC30CNatRe := 0
Default aFilsC20   := {}
Default cDataIni   := ''
Default cDataFim   := ''
Default nTmPrId40  := 0
Default lReport    := .F.
Default cCompV3X   := ''
Default cCompV4F   := ''
Default nLevel     := 1
Default cDtConta   := '2'
Default lApuSTri   := .F.
Default cFilDoc    := cFilAnt
Default aBind      := {}

cQry := "FROM " + RetSqlName("C20") + " C20 " //T013 ( C20 ) Documento Fiscal
cQry += "INNER JOIN " + RetSqlName("C1H") + " C1H ON " //Participantes
cQry += TafJoinC1H( cCompC1H , aInfEUF, "C20.C20_FILIAL" )
cQry += " AND C1H.C1H_ID = C20.C20_CODPAR AND ((C1H.C1H_CPF <> ? AND C1H.C1H_PPES = ?)  OR (C1H.C1H_PEEXTE = ? AND C1H.C1H_PAISEX <> ?) ) AND C1H.D_E_L_E_T_ = ? "
aadd(aBind, space(1))
aadd(aBind, '1')
aadd(aBind, '1')
aadd(aBind, space(1))
aadd(aBind, space(1))

if lReport
	cQry += "LEFT JOIN " + RetSqlName("T9A") + " T9A ON " //Forma de tributacao
	cQry += "T9A.T9A_FILIAL = ? AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ? "
	aadd(aBind, xFilial("T9A"))
	aadd(aBind, space(1))
endif

cQry += " INNER JOIN " + RetSqlName("C30") + " C30 ON " //T015 ( C30 ) Itens da nota fiscal natureza rendimento
cQry += " C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.C30_CNATRE <> ? AND C30.D_E_L_E_T_ = ? "
aadd(aBind, space(nC30CNatRe))
aadd(aBind, space(1))

if lReport .Or. nLevel == 2
	cQry += " INNER JOIN " + RetSqlName("V3O") + " V3O ON " //Natureza de operacao
	cQry += " V3O.V3O_FILIAL = ? "
	cQry += " AND V3O.V3O_ID = C30.C30_CNATRE "
	cQry += " AND V3O.D_E_L_E_T_ = ? "
	aadd(aBind, xFilial("V3O"))
	aadd(aBind, space(1))
	
	If lReport .And. nLevel == 1
		cQry += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON " //T159 ( V3X  FCI e SCP
		If cCompV3X == "EEE"
			cQry += " V3X.V3X_FILIAL = C20.C20_FILIAL "
		Else
			If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
				cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
			ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
				cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(C20.C20_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
			Else
				cQry += " V3X.V3X_FILIAL = ? "
				aadd(aBind, xFilial("V3X"))
			EndIf
		EndIf
		cQry += " AND V3X.V3X_ID = C30.C30_IFCISC "
		cQry += " AND V3X.D_E_L_E_T_ = ? "
		aadd(aBind, space(1))
	EndIf
endif

cQry += " LEFT JOIN " + RetSqlName("C35") + " C35 ON " //T015AE ( C35 ) Tributos do Item
cQry += " C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF = C30.C30_CHVNF AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE AND C35.C35_CODTRI = ? AND C35.D_E_L_E_T_ = ? "
cQry += " LEFT JOIN " + RetSqlName("LEM") + " LEM ON " //T154 ( LEM ) Fatura
cQry += " LEM.LEM_FILIAL = C20.C20_FILIAL AND LEM.LEM_DOCORI = C20.C20_CHVNF AND LEM.D_E_L_E_T_ = ? "
aadd(aBind, '000012')
aadd(aBind, space(1))
aadd(aBind, space(1))

If nLevel == 1
	If "TMPFIL" $ aFilsC20[1]
		cQry += " WHERE C20.C20_FILIAL IN (" + aFilsC20[1] + ") AND "
	Else
		cQry += " WHERE C20.C20_FILIAL IN (?) AND "
		aadd(aBind,aFilsC20)
	EndIf
	cQry += " C20.C20_INDOPE = ? AND "
	aadd(aBind, '0')
Elseif nLevel == 2
	cQry += " WHERE C20.C20_FILIAL = ? AND C20.C20_INDOPE = ? AND "
	aadd(aBind, xFilial('C20',cFilDoc))
	aadd(aBind, '0')
EndIf

If cDtConta == '2'
	cQry += " C20.C20_DTDOC "
Else
	cQry += " C20.C20_DTCONT "
EndIf

cQry += " BETWEEN ? AND ? "
cQry += " AND LEM.LEM_DOCORI IS NULL "
aadd(aBind, cDataIni)
aadd(aBind, cDataFim)

If lApuSTri
	cQry += " AND C30.C30_CNATRE IN (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.V3O_TRIB <> ? AND V3O.D_E_L_E_T_ = ?) "
	aadd(aBind, '8')
	aadd(aBind, space(1))
Else
	cQry += " AND C35.C35_CODTRI IS NOT NULL "
EndIf

cQry += " AND C20.D_E_L_E_T_ = ? "
aadd(aBind, space(1))

if !lReport .And. nLevel == 1
	cQry += " GROUP BY C20.C20_FILIAL, C20.C20_CHVNF, C20.C20_NUMDOC, C20.C20_SERIE, C1H.C1H_CPF, C1H.C1H_PAISEX, C1H.C1H_NIF , C1H.C1H_CODPAR "
endif

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilPgto        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilPgto(cCompC1H,aInfEUF,nV3VCNatRe,aFilsC20,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F,nLevel,lApuSTri,cFilDoc, aBind)

Local cQry    := ''
Local cDataIniD := ''

Default cCompC1H   := ''
Default aInfEUF	   := {}
Default nV3VCNatRe := 0
Default aFilsC20   := {}
Default cDataIni   := ''
Default cDataFim   := ''
Default nTmPrId40  := 0
Default lReport    := .F.
Default cCompV3X   := ''
Default cCompV4F   := ''
Default nLevel     := 1
Default lApuSTri   := .F.
Default cFilDoc    := cFilAnt
Default aBind      := {}

IniVarStat()

cQry := "FROM " + RetSqlName("V3U") + " V3U " //T158 ( V3U ) Pagamento das Parcelas

cQry += "INNER JOIN " + RetSqlName("V3V") + " V3V ON " //T158AA ( V3V ) Natureza Rendimento
cQry += "V3V.V3V_FILIAL = V3U.V3U_FILIAL AND V3V.V3V_ID = V3U.V3U_ID AND V3V.V3V_CNATRE <> ? AND V3V.D_E_L_E_T_ = ? "
aadd(aBind,Space(nV3VCNatRe))
aadd(aBind,space(1))

if lReport
	cQry += " LEFT JOIN " + RetSqlName("V4F") + " V4F ON " //T160 ( V4F ) Despesas Processuais e RRA
	If cCompV4F == "EEE"
		cQry += " V4F.V4F_FILIAL = V3V.V3V_FILIAL "
	Else
		If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		Else
			cQry += " V4F.V4F_FILIAL = ? "
			aadd(aBind,xFilial("V4F"))
		EndIf
	EndIf
	cQry += " AND V4F.V4F_ID = V3V.V3V_IDPROC "
	cQry += " AND V4F.D_E_L_E_T_ = ? "
	aadd(aBind,space(1))

	cQry += " LEFT JOIN " + RetSqlName("V3X") + " V3X ON " //T159 ( V3X ) FCI e SCP
	If cCompV3X == "EEE"
		cQry += " V3X.V3X_FILIAL = V3V.V3V_FILIAL "
	Else
		If cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
		ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQry += " LTRIM(RTRIM(SUBSTRING(V3X.V3X_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V3V.V3V_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
		Else
			cQry += " V3X.V3X_FILIAL = ? "
			aadd(aBind,xFilial("V3X"))
		EndIf
	EndIf
	cQry += " AND V3X.V3X_ID = V3V.V3V_IFCISC "
	cQry += " AND V3X.D_E_L_E_T_ = ? "
	aadd(aBind,space(1))
endif

cQry += "INNER JOIN " + RetSqlName("V3O")  + " V3O ON " //Natureza
cQry += "V3O.V3O_FILIAL = ? AND V3O.V3O_ID = V3V.V3V_CNATRE AND V3O.D_E_L_E_T_ = ? "
aadd(aBind,xFilial("V3O"))
aadd(aBind,space(1))

cQry += "INNER JOIN " + RetSqlName("C1H") + " C1H ON " //Participantes
cQry += TafJoinC1H( cCompC1H , aInfEUF, "V3U.V3U_FILIAL" )
cQry += " AND C1H.C1H_ID = V3U.V3U_IDPART AND ((C1H.C1H_CPF <> ? AND C1H.C1H_PPES = ?) OR (C1H.C1H_PEEXTE = ? AND C1H.C1H_PAISEX <> ?) ) AND C1H.D_E_L_E_T_ = ? "
aadd(aBind,space(1))
aadd(aBind,'1')
aadd(aBind,'1')
aadd(aBind,space(1))
aadd(aBind,space(1))

if lReport
	cQry += "LEFT JOIN " + RetSqlName("T9A") + " T9A ON " //Forma de tributacao
	cQry += "T9A.T9A_FILIAL = ? AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ? "
	aadd(aBind,xFilial("T9A"))
	aadd(aBind,space(1))
endif

cQry += "LEFT JOIN " + RetSqlName("V46") + " V46 ON " //T158AB ( V46 ) Tributos Pagamento
cQry += "V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3U.V3U_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = ? AND V46.D_E_L_E_T_ = ? "
aadd(aBind,'000028')
aadd(aBind,space(1))

If nLevel == 1
	If "TMPFIL" $ aFilsC20[1]
		cQry += " WHERE V3U.V3U_FILIAL IN (" + aFilsC20[1] + ") "
	Else	
		cQry += " WHERE V3U.V3U_FILIAL IN (?) "
		aadd(aBind,aFilsC20)
	EndIf
Elseif nLevel == 2
	cQry += " WHERE V3U.V3U_FILIAL = ? "
	aadd(aBind,xFilial('V3U',cFilDoc))
EndIf
cQry += " AND V3U.V3U_NATTIT = ? "
cQry += " AND ( ( V3U.V3U_DTPAGT BETWEEN ? AND ? "
aadd(aBind,'0')
aadd(aBind,cDataIni)
aadd(aBind,cDataFim)
	
If lApuSTri
	cQry += " AND V3V.V3V_CNATRE IS NOT NULL "
	If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
		cQry += " AND V3O.V3O_CODIGO <> ? "
		aadd(aBind,'12001')
	EndIf	
Else
	cQry += " AND (V46.V46_IDTRIB IS NOT NULL OR (V3O.V3O_TRIB = ? "
	aadd(aBind,'8')
	If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
		cQry += " AND V3O.V3O_CODIGO <> ? "
		aadd(aBind,'12001')
	EndIf	
	cQry += " ) ) "	
EndIf 
cQry += " ) "
If FindFunction("DtIniLucDiv") .and. __lV3UPerApu
	cDataIniD := DtoS( DtIniLucDiv( SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4)) )
	cQry += " OR (V3U.V3U_DTPAGT BETWEEN ? AND ? "
	cQry += " AND (( V3U.V3U_PRID40 = ? "
	cQry += " AND ( V3U.V3U_PERAPU = ? OR V3U.V3U_PERAPU = ?)) " 
	cQry += " OR ( V3U.V3U_PRID40 != ? AND V3U.V3U_PERAPU = ? ) " 
	cQry += " )) "
	cQry += " AND V3O.V3O_CODIGO = ? "
	aadd(aBind,cDataIniD)
	aadd(aBind,cDataFim)
	aadd(aBind,space(nTmPrId40))
	aadd(aBind,space(6))
	aadd(aBind,SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4))
	aadd(aBind,space(nTmPrId40))
	aadd(aBind,SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4))
	aadd(aBind,'12001')
EndIf
cQry += " ) "
cQry += " AND V3U.D_E_L_E_T_ = ? "
aadd(aBind,space(1))

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFilReemb        
@Return nil
@author Denis Souza
@since  26/10/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function QryFilReemb(cCompC1H,aInfEUF,aFilsC20,cDataIni,cDataFim,nTmPrId40,lReport,nLevel,cFilDoc,aBind)

Local cQry := ''

Default cCompC1H  := ''
Default aInfEUF	  := {}
Default aFilsC20  := {}
Default cDataIni  := ''
Default cDataFim  := ''

Default nTmPrId40 := 0
Default lReport   := .F.
Default nLevel    := 1
Default cFilDoc   := cFilAnt
Default aBind     := {}

if lReport
	cQry += " FROM " + RetSqlName("V4B") + " V4B "
endif

cQry += "INNER JOIN " + RetSqlName("C1H") + " C1H ON "
cQry += TafJoinC1H( cCompC1H , aInfEUF, "V4B.V4B_FILIAL" )
cQry += " AND C1H.C1H_ID = V4B.V4B_IDPART AND ((C1H.C1H_CPF <> ? AND C1H.C1H_PPES = ?) OR (C1H.C1H_PEEXTE = ? AND C1H.C1H_PAISEX <> ?) ) AND C1H.D_E_L_E_T_ = ? "
aadd(aBind,space(1))
aadd(aBind,'1')
aadd(aBind,'1')
aadd(aBind,space(1))
aadd(aBind,space(1))

if lReport
	cQry += "LEFT JOIN " + RetSqlName("T9A") + " T9A ON "
	cQry += "T9A.T9A_FILIAL = ? AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ? "
	cQry += "LEFT JOIN " + RetSqlName("V3R") + " V3R ON "
	cQry += "V3R.V3R_FILIAL = ? AND V3R.V3R_ID = V4B.V4B_IDPART AND V3R.V3R_CODIGO = V4B.V4B_CODDEP AND V3R.D_E_L_E_T_ = ? "
	aadd(aBind,xFilial("T9A"))
	aadd(aBind,space(1))
	aadd(aBind,xFilial("V3R"))
	aadd(aBind,space(1))
endif

If nLevel == 2
	cQry += "WHERE V4B.V4B_FILIAL = ? AND "
	aadd(aBind,cFilDoc)
Else
	If "TMPFIL" $ aFilsC20[1]
		cQry += "WHERE V4B.V4B_FILIAL IN (" + aFilsC20[1] + ") AND "
	Else
		cQry += "WHERE V4B.V4B_FILIAL IN (?) AND "
		aadd(aBind,aFilsC20)
	EndIf
EndIf	

cQry += "V4B.V4B_DTPGTO BETWEEN ? AND ? AND V4B.D_E_L_E_T_ = ? "
aadd(aBind,cDataIni)
aadd(aBind,cDataFim)
aadd(aBind,space(1))

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Denis Souza /Jose Felipe
@since 04/11/2022
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)

local cKeyError as character
local nX        as numeric
local cKey 		as character
cKeyError       := ""
cKey	        := ""
nX              := 1

If !Empty(alltrim(oEstruct["key"]))  
	cKey := alltrim(oEstruct["key"])
ElseIf !Empty(alltrim(oEstruct["nif"]))
	cKey := alltrim(oEstruct["nif"])
ElseIf !Empty(alltrim(oEstruct["providerCode"]))
	cKey := alltrim(oEstruct["providerCode"])
EndIf	

For nX := 1 to Len(oValidationError["registryKey"])
	if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
		if alltrim(oValidationError["registryKey"][nX]["id"]) == cKey
			cKeyError := oValidationError["registryKey"][nX]["error"]
		endif
	endif
Next nX

return ( cKeyError )

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WsRel4010
Função responsável por retornar a query para geração do relatorio em planilha

@author Denis Souza
@since 10/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
function WsRel4010(cPeriod,cCompC1G,cCompC1H,aInfEUF,aFilsC20,aFilsLEM,aFilsV3U,aFilsV4B,cBanco,cCompV3X,cCompV4F,oTabTemp,aBind)

local cQry 		  as character
local cDataIni    as Character
local cDataFim    as Character
local nV3SIdNatR  as numeric
local nC30CNatRe  as numeric
local nV3VCNatRe  as numeric
local nTmPrId40   as numeric
local lReport     as logical
local lApuSTri    as logical
local cDtConta 	  as character

default cPeriod  := ''
default cCompC1G := ''
default cCompC1H := ''
default aInfEUF  := {}
default aFilsC20 := {}
default aFilsLEM := {}
default aFilsV3U := {}
default aFilsV4B := {}
default cBanco   := ''
default cCompV3X := ''
default cCompV4F := ''
default oTabTemp := Nil
default aBind    := {}

cQry 	 := ''
cDataIni := cPeriod + "01" //ex: 20220201
cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

cDtConta   := SuperGetMv('MV_TAFDT40',.F.,'2')
nV3SIdNatR := FWSX3Util():GetFieldStruct('V3S_IDNATR')[3]
nC30CNatRe := FWSX3Util():GetFieldStruct('C30_CNATRE')[3]
nV3VCNatRe := FWSX3Util():GetFieldStruct('V3V_CNATRE')[3]
nTmPrId40  := FWSX3Util():GetFieldStruct('C20_PRID40')[3]
lReport    := .T.
lApuSTri   := SuperGetMv('MV_TAFSTRI',.F.,.F.)

//Bloco com campos provenientes das notas
cQry += TafNtField(cBanco,cCompC1G,aInfEUF,cDtConta,@aBind)
cQry += QryFilNota(cCompC1H,aInfEUF,nC30CNatRe,aFilsC20,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F,,cDtConta,lApuSTri,,@aBind)
cQry += "GROUP BY C20.C20_FILIAL,C20.C20_CHVNF,C20.C20_NUMDOC,C20.C20_SERIE, "
cQry += " C20."+ iif(cDtConta == '2','C20_DTDOC','C20_DTCONT')+","
cQry += " C20.C20_FCISCP,C20.C20_CODPAR,C1H.C1H_CPF,C1H.C1H_CODPAR,C1H.C1H_INDNIF,C1H.C1H_NIF,C1H.C1H_NOME,C1H.C1H_PAISEX,"
cQry += " T9A.T9A_DESCRI,V3X.V3X_CNPJ,C30.C30_NUMITE,C30.C30_CODITE,V3O.V3O_CODIGO,C35.C35_CODTRI,C35.C35_ALIQ "

cQry += "UNION ALL " //Bloco com campos provenientes das faturas

cQry += TafFtField(cDataIni,cDataFim,cCompV4F,cCompC1G,aInfEUF,cBanco,cDtConta,@aBind)
cQry += QryFilFat(cCompC1H,aInfEUF,nV3SIdNatR,aFilsLEM,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F,,cDtConta,lApuSTri,,@aBind)
cQry += "GROUP BY LEM.LEM_FILIAL,LEM.LEM_ID,LEM.LEM_NUMERO, "
cQry += " LEM."+ iif(cDtConta == '2','LEM_DTEMIS','LEM_DTCONT')+","
cQry += " LEM.LEM_FCISCP,LEM.LEM_VLBRUT,LEM.LEM_IDPART,C1H.C1H_CPF,C1H.C1H_CODPAR,C1H.C1H_INDNIF,C1H.C1H_NIF,C1H.C1H_NOME,C1H.C1H_PAISEX,"
cQry += " T9A.T9A_DESCRI,V3X.V3X_CNPJ,V3S.V3S_IDPROC,V3S.V3S_IDNATR,V3S.V3S_DECTER,V4F.V4F_NRPROC,V4F.V4F_INDRRA,V4F.V4F_CNPJOR,V3O.V3O_CODIGO,V47.V47_IDTRIB,V47.V47_ALIQ) FAT "

cQry += "UNION ALL " //Bloco com campos provenientes dos pagamentos

cQry += TafPgtField(cDataIni,cDataFim,cBanco,cCompV4F,cCompC1H,cCompC1G,aInfEUF,@aBind)
cQry += QryFilPgto(cCompC1H,aInfEUF,nV3VCNatRe,aFilsV3U,cDataIni,cDataFim,nTmPrId40,lReport,cCompV3X,cCompV4F,,lApuSTri,,@aBind)
cQry += "GROUP BY V3U.V3U_FILIAL,V3U.V3U_NUMERO,V3U.V3U_PARCEL,V3U.V3U_DTPAGT,V3U.V3U_ID,V3U.V3U_FCISCP,V3U.V3U_IDPART,C1H.C1H_CPF,C1H.C1H_CODPAR,C1H.C1H_INDNIF,C1H.C1H_NIF,C1H.C1H_NOME,"
cQry += "T9A.T9A_DESCRI,V3X.V3X_CNPJ,V3V.V3V_CNATRE,V3V.V3V_IDPROC,V3V.V3V_VALOR,V3O.V3O_CODIGO,V4F.V4F_INDRRA,V4F.V4F_NRPROC,V4F.V4F_CNPJOR) PGT "

cQry += "UNION ALL " //Bloco com campos provenientes dos reembolsos \ plano de saude

cQry += TafPlsField(cCompC1H,aInfEUF,aFilsV4B,cDataIni,cDataFim,nTmPrId40,lReport,@oTabTemp,cBanco)

cQry := TafGerField() + " FROM ( " + cQry //Campos Gerais do Relatorio

cQry += ") TBGER ORDER BY FILIAL,CPF,DTEMISPGT,DOCTO,NUMITE,SERIEPARC,CODNAT "

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Colunas Gerais do Relatorio R4010

@author Denis Souza
@since 14/02/2023
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafGerField()

local cQry as Character

cQry := "SELECT TBGER.FILIAL"	//01 Filial / Nome da filial / CNPJ
cQry += ",TBGER.CPF"			//02 CPF Beneficiário
cQry += ",TBGER.CODPAR"	 		//03 Código participante
cQry += ",TBGER.INDNIF"	 		//04 Indicativo NIF
cQry += ",TBGER.NIF"			//05 N° NIF
cQry += ",TBGER.FRMTRIB" 		//06 Forma Tributação
cQry += ",TBGER.NOME"			//07 Nome Beneficiário
cQry += ",TBGER.ROTINA"	 		//08 Tipo
cQry += ",TBGER.SERIEPARC" 		//09 Série / Parcela
cQry += ",TBGER.DOCTO"			//10 N° Documento
cQry += ",TBGER.NUMITE"	 		//11 N° do Item
cQry += ",TBGER.DTEMISPGT"		//12 Data emissão/pagamento
cQry += ",TBGER.ID"		 		//13 ID do documento
cQry += ",TBGER.CODNAT"	 		//14 Natureza de Rendimento
cQry += ",TBGER.INDFCISCP"		//15 Indicativo de FCI/SCP
cQry += ",TBGER.CNPJFCISCP" 	//16 CNPJ da FCI/SCP
cQry += ",TBGER.NRRRAPJD"		//17 Informação de RRA ou Proce
cQry += ",TBGER.INDRRA"	 		//18 N° de Inscrição do process
cQry += ",TBGER.CNPJOR"	 		//19 CNPJ Origem Recurso
cQry += ",TBGER.CUSTADV" 		//20 Total de Custas com advogados
cQry += ",TBGER.CUSTJUD" 		//21 Total de Custas Judiciais
cQry += ",TBGER.VALBRUTO"   	//22 Valor do documento
cQry += ",TBGER.BASEIR"	 		//23 Base de Cálculo IR
cQry += ",TBGER.ALIQIR"	 		//24 Alíquota do IR
cQry += ",TBGER.VALIR"	 		//25 Valor do IR
cQry += ",TBGER.TOTDEDU"    	//26 Total de deduções
cQry += ",TBGER.TDEDUDEP"   	//27 Valor total das deduções de dependentes
cQry += ",TBGER.TOTISEN"		//28 Total de Rendimentos Isentos
cQry += ",TBGER.VBSIR"	 		//29 Valor do Rendimento Suspenso por processo judicial
cQry += ",TBGER.VRSIR"	 		//30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",TBGER.TDEDUSUSP"  	//31 Valor da dedução suspensa
cQry += ",TBGER.NPROCREF"   	//32 N° do Processo Referenciado
cQry += ",TBGER.CNPJPLS"		//33 CNPJ PLS 
cQry += ",TBGER.BENEPLS"		//34 Beneficiário PLS
cQry += ",TBGER.CPFDEPE"		//35 CPF Dependente 
cQry += ",TBGER.TIPPGTO"		//36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",TBGER.VPGTPLS"		//37 Valor pago PLS
cQry += ",TBGER.REEMBAN"		//38 Reembolso ano anterior
cQry += ",TBGER.TPMEDIC"		//39 Tipo de Inscrição Médico
cQry += ",TBGER.NINSMED "		//40 Nr. Inscrição Médico

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TafFtField
Registros/Campos provenientes das faturas que se enquadram no R4010

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafFtField(cDataIni,cDataFim,cCompV4F,cCompC1G,aInfEUF,cBanco,cDtConta,aBind)

local cQry 		as character
local cConcat	as character

Default cDataIni := ''
Default cDataFim := ''
Default cCompV4F := ''
Default cCompC1G := ''
Default aInfEUF  := {}
Default cBanco   := ''
Default cDtConta := '2'
Default aBind    := {}

If !( cBanco $ ( "INFORMIX|ORACLE|OPENEDGE|POSTGRES|DB2" ) ) //tratamento do concat devido tcsqlexec nao converte com o padrao || no sql
	cConcat := ' + '
Else
	cConcat := ' || '
EndIf

cQry := "SELECT "
cQry += "FAT.FILIAL"	  //01 Filial / Nome da filial / CNPJ da filial
cQry += ",FAT.CPF"		  //02 CPF Beneficiário
cQry += ",FAT.CODPAR"	  //03 Código participante
cQry += ",FAT.INDNIF"	  //04 Indicativo NIF
cQry += ",FAT.NIF"		  //05 N° NIF
cQry += ",FAT.FRMTRIB"	  //06 Forma Tributação
cQry += ",FAT.NOME"		  //07 Nome Beneficiário
cQry += ",FAT.ROTINA"	  //08 Tipo
cQry += ",FAT.SERIEPARC"  //09 Série / Parcela
cQry += ",FAT.DOCTO"	  //10 N° Documento
cQry += ",FAT.NUMITE"	  //11 N° do Item
cQry += ",FAT.DTEMISPGT"  //12 Data emissão/pagamento
cQry += ",FAT.ID"		  //13 ID do documento
cQry += ",FAT.CODNAT"	  //14 Natureza de Rendimento
cQry += ",FAT.INDFCISCP"  //15 Indicativo de FCI/SCP
cQry += ",FAT.CNPJFCISCP" //16 CNPJ da FCI/SCP
cQry += ",FAT.NRRRAPJD"	  //17 Informação de RRA ou Processo Judicial
cQry += ",FAT.INDRRA"	  //18 N° de Inscrição do processo RRA/Processo Judicial
cQry += ",FAT.CNPJOR"	  //19 CNPJ Origem Recurso
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V4GADV.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GADV ON V4GADV.V4G_FILIAL = V4F.V4F_FILIAL "
else
	cQry += ",NVL((SELECT SUM(V4GADV.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GADV ON V4GADV.V4G_FILIAL = V4F.V4F_FILIAL "
endif
cQry += "AND V4GADV.V4G_ID = V4F.V4F_ID AND V4GADV.V4G_TPDESP = ? AND V4GADV.V4G_DTDESP BETWEEN ? AND ? AND V4GADV.D_E_L_E_T_ = ? WHERE "
aadd(aBind,'1')
aadd(aBind,cDataIni)
aadd(aBind,cDataFim)
aadd(aBind,space(1))

If cCompV4F == "EEE"
	cQry += "V4F.V4F_FILIAL = FAT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(FAT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(FAT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	Else
		cQry += "V4F.V4F_FILIAL = ? "
		aadd(aBind,xFilial("V4F"))
	EndIf
EndIf
cQry += "AND V4F.V4F_ID = FAT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ?), 0) CUSTADV " //20 Total de Custas com advogados
aadd(aBind,space(1))

If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V4GJUD.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GJUD ON V4GJUD.V4G_FILIAL = V4F.V4F_FILIAL "
else
	cQry += ",NVL((SELECT SUM(V4GJUD.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GJUD ON V4GJUD.V4G_FILIAL = V4F.V4F_FILIAL "
endif
cQry += "AND V4GJUD.V4G_ID = V4F.V4F_ID AND V4GJUD.V4G_TPDESP = ? AND V4GJUD.V4G_DTDESP BETWEEN ? AND ? AND V4GJUD.D_E_L_E_T_ = ? WHERE "
aadd(aBind,'2')
aadd(aBind,cDataIni)
aadd(aBind,cDataFim)
aadd(aBind,space(1))

If cCompV4F == "EEE"
	cQry += " V4F.V4F_FILIAL = FAT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(FAT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(FAT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	Else
		cQry += "V4F.V4F_FILIAL = ? "
		aadd(aBind,xFilial("V4F"))
	EndIf
EndIf
cQry += "AND V4F.V4F_ID = FAT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ?), 0) CUSTJUD " //21 Total de Custas Judiciais	
aadd(aBind,space(1))

cQry += ",FAT.VALBRUTO"	//22 Valor do documento
cQry += ",FAT.BASEIR"	//23 Base de Cálculo IR
cQry += ",FAT.ALIQIR"	//24 Alíquota do IR
cQry += ",FAT.VALIR"	//25 Valor do IR
cQry += ",FAT.TOTDEDU"  //26 Total de deduções
cQry += ",FAT.TDEDUDEP" //27 Valor total das deduções de dependentes
cQry += ",FAT.TOTISEN"	//28 Total de Rendimentos Isentos
cQry += ",FAT.VBSIR"	//29 Valor do Rendimento Suspenso por processo judicial
cQry += ",FAT.VRSIR"	//30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",FAT.TDEDUSUSP"//31 Valor da dedução suspensa
cQry += ",FAT.NPROCREF" //32 N° do Processo Referenciado
cQry += ",FAT.CNPJPLS"	//33 CNPJ PLS 
cQry += ",FAT.BENEPLS"	//34 Beneficiário PLS
cQry += ",FAT.CPFDEPE"	//35 CPF Dependente 
cQry += ",FAT.TIPPGTO"	//36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",FAT.VPGTPLS"	//37 Valor pago PLS
cQry += ",FAT.REEMBAN"	//38 Reembolso ano anterior
cQry += ",FAT.TPMEDIC"	//39 Tipo de Inscrição Médico
cQry += ",FAT.NINSMED "	//40 Nr. Inscrição Médico

cQry += "FROM ( "

cQry += "SELECT "
cQry += "LEM.LEM_FILIAL FILIAL" 					//01 Filial / Nome da filial / CNPJ da filial
cQry += ",C1H.C1H_CPF CPF"		 					//02 CPF Beneficiário
cQry += ",C1H.C1H_CODPAR CODPAR" 					//03 Código participante

//04 Indicativo NIF
cQry += ",CASE WHEN C1H.C1H_INDNIF = ? THEN ? WHEN C1H.C1H_INDNIF = ? THEN ? "
cQry += "WHEN C1H.C1H_INDNIF = ? THEN ? ELSE ? END INDNIF "
aadd(aBind,'1')
aadd(aBind,'Possui')
aadd(aBind,'2')
aadd(aBind,'Dispensado')
aadd(aBind,'3')
aadd(aBind,'Pais nao exige')
aadd(aBind,'Nao Informado')

cQry += ",C1H.C1H_NIF NIF" 						 	//05 N° NIF
cQry += "," + iif(!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(T9A.T9A_DESCRI, '') FRMTRIB" 	//06 Forma Tributação
cQry += ",C1H.C1H_NOME NOME"						//07 Nome Beneficiário
cQry += ",'FAT' ROTINA"							 	//08 Tipo
cQry += " ,' ' SERIEPARC"							//09 Série / Parcela
cQry += ",LEM.LEM_NUMERO DOCTO"					 	//10 N° Documento
cQry += ",' ' NUMITE"								//11 N° do Item
cQry += ",LEM."+ iif(cDtConta == '2','LEM_DTEMIS','LEM_DTCONT')+" DTEMISPGT" //12 Data emissão/pagamento
cQry += ",LEM.LEM_ID ID"							//13 ID do documento
cQry += ",V3O.V3O_CODIGO CODNAT"					//14 Natureza de Rendimento

//15 Indicativo de FCI/SCP
cQry += ",CASE WHEN LEM.LEM_FCISCP = ? THEN ? WHEN LEM.LEM_FCISCP = ? THEN ? ELSE ? END INDFCISCP"
aadd(aBind,'1')
aadd(aBind,'FCI')
aadd(aBind,'2')
aadd(aBind,'SCP')
aadd(aBind,'Nao Informado')

cQry += "," + iif(!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(V3X.V3X_CNPJ, '') CNPJFCISCP"	//16 CNPJ da FCI/SCP
cQry += ",V3S.V3S_IDPROC IDRRAPJUD"				 	//Utilizado no join sobre a query executada CMPS 20 e 21
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE(V4F.V4F_NRPROC, '') NRRRAPJD"	//17 Informação de RRA ou Processo Judicial
	//18 N° de Inscrição do processo RRA/Processo Judicial
	cQry += ",COALESCE( CASE WHEN V4F.V4F_INDRRA = ? THEN ? ELSE ? END , '') INDRRA"
	cQry += ",COALESCE(V4F.V4F_CNPJOR, '') CNPJOR"		//19 CNPJ Origem Recurso
	cQry += ",LEM.LEM_VLBRUT VALBRUTO"					//22 Valor do documento
	cQry += ",COALESCE(SUM(V47.V47_BASECA),0) BASEIR"	//23 Base de Cálculo IR
	cQry += ",COALESCE(V47.V47_ALIQ, 0) ALIQIR"		 	//24 Alíquota do IR
	cQry += ",COALESCE(SUM(V47.V47_VLTRIB),0) VALIR"	//25 Valor do IR
	aadd(aBind,'1')
	aadd(aBind,'Sim')
	aadd(aBind,'Nao')
else
	cQry += ",NVL(V4F.V4F_NRPROC, '') NRRRAPJD"	//17 Informação de RRA ou Processo Judicial
	//18 N° de Inscrição do processo RRA/Processo Judicial
	cQry += ",NVL( CASE WHEN V4F.V4F_INDRRA = ? THEN ? ELSE ? END , '') INDRRA"
	cQry += ",NVL(V4F.V4F_CNPJOR, '') CNPJOR"		//19 CNPJ Origem Recurso
	cQry += ",LEM.LEM_VLBRUT VALBRUTO"					//22 Valor do documento
	cQry += ",NVL(SUM(V47.V47_BASECA),0) BASEIR"	//23 Base de Cálculo IR
	cQry += ",NVL(V47.V47_ALIQ, 0) ALIQIR"		 	//24 Alíquota do IR
	cQry += ",NVL(SUM(V47.V47_VLTRIB),0) VALIR"	//25 Valor do IR
	aadd(aBind,'1')
	aadd(aBind,'Sim')
	aadd(aBind,'Nao')
endif
//26 Total de deduções
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(V4L.V4L_VLRDED) FROM " + RetSqlName("V4L") + " V4L WHERE V4L.V4L_FILIAL = LEM.LEM_FILIAL AND V4L.V4L_ID = LEM.LEM_ID "
else
	cQry += ",NVL((SELECT SUM(V4L.V4L_VLRDED) FROM " + RetSqlName("V4L") + " V4L WHERE V4L.V4L_FILIAL = LEM.LEM_FILIAL AND V4L.V4L_ID = LEM.LEM_ID "
endif
cQry += "AND V4L.V4L_IDPART = LEM.LEM_IDPART AND V4L.V4L_NUMFAT = LEM.LEM_NUMERO AND V4L.V4L_IDNATR = V3S.V3S_IDNATR "
cQry += "AND V4L.V4L_DECTER = V3S.V3S_DECTER AND V4L.V4L_IDTRIB = V47.V47_IDTRIB AND V4L.V4L_IDTRIB = ? AND V4L.D_E_L_E_T_ = ?),0) TOTDEDU "
aadd(aBind,'000012')
aadd(aBind,space(1))

//27 Valor total das deduções de dependentes
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(V83.V83_VALDED) FROM " + RetSqlName("V83") + " V83 WHERE V83.V83_FILIAL = LEM.LEM_FILIAL AND V83.V83_ID = LEM.LEM_ID "
else
	cQry += ",NVL((SELECT SUM(V83.V83_VALDED) FROM " + RetSqlName("V83") + " V83 WHERE V83.V83_FILIAL = LEM.LEM_FILIAL AND V83.V83_ID = LEM.LEM_ID "
endif
cQry += "AND V83.V83_IDPART = LEM.LEM_IDPART AND V83.V83_NUMFAT = LEM.LEM_NUMERO AND V83.V83_IDNATR = V3S.V3S_IDNATR AND V83.V83_DECTER = V3S.V3S_DECTER "
cQry += "AND V83.V83_IDTRIB = V47.V47_IDTRIB AND V83.V83_IDTRIB = ? AND V83.D_E_L_E_T_ = ?),0) TDEDUDEP "
aadd(aBind,'000012')
aadd(aBind,space(1))

//28 Total de Rendimentos Isentos
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(V4M.V4M_VLRISE) FROM " + RetSqlName("V4M") + " V4M WHERE V4M.V4M_FILIAL = LEM.LEM_FILIAL AND V4M.V4M_ID = LEM.LEM_ID "
else
	cQry += ",NVL((SELECT SUM(V4M.V4M_VLRISE) FROM " + RetSqlName("V4M") + " V4M WHERE V4M.V4M_FILIAL = LEM.LEM_FILIAL AND V4M.V4M_ID = LEM.LEM_ID "
endif
cQry += "AND V4M.V4M_IDPART = LEM.LEM_IDPART AND V4M.V4M_NUMFAT = LEM.LEM_NUMERO AND V4M.V4M_IDNATR = V3S.V3S_IDNATR "
cQry += "AND V4M.V4M_DECTER = V3S.V3S_DECTER AND V4M.V4M_IDTRIB = V47.V47_IDTRIB AND V4M.V4M_IDTRIB = ? AND V4M.D_E_L_E_T_ = ?),0) TOTISEN "
aadd(aBind,'000012')
aadd(aBind,space(1))

//29 Valor do Rendimento Suspenso por processo judicial
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(T9E.T9E_BSSUSP) FROM " + RetSqlName("T9E") + " T9E WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
else
	cQry += ",NVL((SELECT SUM(T9E.T9E_BSSUSP) FROM " + RetSqlName("T9E") + " T9E WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
endif
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = ? AND T9E.D_E_L_E_T_ = ?),0) VBSIR "
aadd(aBind,'000012')
aadd(aBind,space(1))

//30 Valor da retenção nao efetuada devido Processo Ref
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(T9E.T9E_VALSUS) FROM " + RetSqlName("T9E") + " T9E WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
else
	cQry += ",NVL((SELECT SUM(T9E.T9E_VALSUS) FROM " + RetSqlName("T9E") + " T9E WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
endif
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = ? AND T9E.D_E_L_E_T_ = ?),0) VRSIR "
aadd(aBind,'000012')
aadd(aBind,space(1))

//31 Valor da dedução suspensa (Diferente da nota, onde V88 está por item, do pagamento, onde V90 está por natureza a V89 da fatura nao possui vinculo direto com a natureza)
If !("INFORMIX" $ cBanco)  
	cQry += ",COALESCE((SELECT SUM(V89.V89_VALDED) FROM " + RetSqlName("V89") + " V89 WHERE V89.V89_FILIAL = LEM.LEM_FILIAL AND V89.V89_ID = LEM.LEM_ID "
else
	cQry += ",NVL((SELECT SUM(V89.V89_VALDED) FROM " + RetSqlName("V89") + " V89 WHERE V89.V89_FILIAL = LEM.LEM_FILIAL AND V89.V89_ID = LEM.LEM_ID "
endif
cQry += "AND V89.V89_IDPT9E = LEM.LEM_IDPART AND V89.V89_NFAT9E = LEM.LEM_NUMERO AND V89.V89_CODTRI = ? "
cQry += "AND V89.V89_TPPROC"+cConcat+"V89.V89_NUMPRO"+cConcat+"V89.V89_IDSUSP IN ( "
cQry += "SELECT DISTINCT T9E.T9E_TPPROC"+cConcat+"T9E.T9E_NUMPRO"+cConcat+"T9E.T9E_IDSUSP " 
cQry += "FROM " + RetSqlName("T9E") + " T9E WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = ? AND T9E.D_E_L_E_T_ = ?) "
cQry += "AND V89.D_E_L_E_T_ = ?),0) TDEDUSUSP "
aadd(aBind,'000012')
aadd(aBind,'000012')
aadd(aBind,space(1))
aadd(aBind,space(1))

//32 N° do Processo Referenciado
cQry += iif(!("INFORMIX" $ cBanco),",COALESCE(( " , ",NVL(( ")
If !( cBanco $ ( "INFORMIX|ORACLE|OPENEDGE|POSTGRES|DB2" ) )
	cQry += "SELECT TOP 1 C1G.C1G_NUMPRO "
Else
	cQry += "SELECT C1G.C1G_NUMPRO "
EndIf
cQry += "FROM " + RetSqlName("T9E") + " T9E INNER JOIN " + RetSqlName("C1G") + " C1G ON "
If cCompC1G == "EEE"
	cQry += " C1G.C1G_FILIAL = T9E.T9E_FILIAL "
Else
	If cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(T9E.T9E_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompC1G == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(T9E.T9E_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	Else
		cQry += "C1G.C1G_FILIAL = ? "
		aadd(aBind,xFilial("C1G"))
	EndIf
EndIf
cQry += "AND C1G.C1G_ID = T9E.T9E_NUMPRO AND C1G.D_E_L_E_T_ = ? "
cQry += "WHERE T9E.T9E_FILIAL = LEM.LEM_FILIAL AND T9E.T9E_ID = LEM.LEM_ID AND T9E.T9E_IDPART = LEM.LEM_IDPART "
cQry += "AND T9E.T9E_NUMFAT = LEM.LEM_NUMERO AND T9E.T9E_CNATRE = V3S.V3S_IDNATR AND T9E.T9E_CODTRI = ? AND T9E.D_E_L_E_T_ = ? "
aadd(aBind,space(1))
aadd(aBind,'000012')
aadd(aBind,space(1))

if cBanco == "ORACLE"
	cQry += " AND ROWNUM <= ? "
	aadd(aBind,1)
Elseif cBanco $ "POSTGRES|DB2"
	cQry += " LIMIT ? "
	aadd(aBind,1)
Endif
cQry += " ),'') NPROCREF " 

cQry += ",' ' CNPJPLS"  //33 CNPJ PLS
cQry += ",' ' BENEPLS"  //34 Beneficiário PLS
cQry += ",' ' CPFDEPE"  //35 CPF Dependente
cQry += ",' ' TIPPGTO"  //36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",0 VPGTPLS" 	//37 Valor pago PLS
cQry += ",0 REEMBAN" 	//38 Reembolso ano anterior
cQry += ",' ' TPMEDIC"  //39 Tipo de Inscrição Médico
cQry += ",' ' NINSMED " //40 Nr. Inscrição Médico

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes das notas fiscais que se enquadram no R4020

@author Denis Souza
@since 03/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafNtField( cBanco, cCompC1G, aInfEUF,cDtConta, aBind)

local cQry as Character

default cBanco   := ''
default cCompC1G := ''
default aInfEUF  := {}
default cDtConta := '2'
default aBind    := {}

cQry := "SELECT "
cQry += "C20.C20_FILIAL FILIAL" 					  //01 Filial / Nome da filial / CNPJ da filial
cQry += ",C1H.C1H_CPF CPF"							  //02 CPF Beneficiário
cQry += ",C1H.C1H_CODPAR CODPAR" 					  //03 Código participante

//04 Indicativo NIF
cQry += ",CASE WHEN C1H.C1H_INDNIF = ? THEN ? WHEN C1H.C1H_INDNIF = ? THEN ? "
cQry += "WHEN C1H.C1H_INDNIF = ? THEN ? ELSE ? END INDNIF"
aadd(aBind,'1')
aadd(aBind,'Possui')
aadd(aBind,'2')
aadd(aBind,'Dispensado')
aadd(aBind,'3')
aadd(aBind,'Pais nao exige')
aadd(aBind,'Nao Informado')


cQry += ",C1H.C1H_NIF NIF"							  //05 N° NIF
cQry += "," + Iif(!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(T9A.T9A_DESCRI, '') FRMTRIB" 	  //06 Forma Tributação 
cQry += ",C1H.C1H_NOME NOME" 						  //07 Nome Beneficiário
cQry += ",'NFS' ROTINA"							  	  //08 Tipo
cQry += ",C20.C20_SERIE SERIEPARC"				  	  //09 Série / Parcela
cQry += ",C20.C20_NUMDOC DOCTO"					  	  //10 N° Documento
cQry += ",C30.C30_NUMITE NUMITE"					  //11 N° do Item
cQry += ",C20."+ iif(cDtConta == '2','C20_DTDOC','C20_DTCONT')+" DTEMISPGT"  //12 Data emissão/pagamento
cQry += ",C20.C20_CHVNF ID"						  	  //13 ID do documento
cQry += ",V3O.V3O_CODIGO CODNAT"					  //14 Natureza de Rendimento

//15 Indicativo de FCI/SCP
cQry += ",CASE WHEN C20.C20_FCISCP = ? THEN ? WHEN C20.C20_FCISCP = ? THEN ? ELSE ? END INDFCISCP"
aadd(aBind,'1')
aadd(aBind,'FCI')
aadd(aBind,'2')
aadd(aBind,'SCP')
aadd(aBind,'Nao Informado')

If !("INFORMIX" $ cBanco)  
	cQry += ",COALESCE(V3X.V3X_CNPJ, '') CNPJFCISCP"	  //16 CNPJ da FCI/SCP
	cQry += ",'' NRRRAPJD" 							  	  //17 Informação de RRA ou Processo Judicial
	cQry += ",'' INDRRA"								  //18 N° de Inscrição do processo RRA/Processo Judicial
	cQry += ",'' CNPJOR"								  //19 CNPJ Origem Recurso
	cQry += ",0 CUSTADV"								  //20 Total de Custas com advogados
	cQry += ",0 CUSTJUD"								  //21 Total de Custas Judiciais
	cQry += ",COALESCE(SUM(C30.C30_TOTAL), 0) VALBRUTO"   //22 Valor do documento
	cQry += ",COALESCE(SUM(C35.C35_BASE), 0) BASEIR"	  //23 Base de Cálculo IR
	cQry += ",COALESCE(C35.C35_ALIQ, 0) ALIQIR"		  	  //24 Alíquota do IR
	cQry += ",COALESCE(SUM(C35.C35_VALOR), 0) VALIR"	  //25 Valor do IR
else
	cQry += ",NVL(V3X.V3X_CNPJ, '') CNPJFCISCP"	  //16 CNPJ da FCI/SCP
	cQry += ",'' NRRRAPJD" 							  	  //17 Informação de RRA ou Processo Judicial
	cQry += ",'' INDRRA"								  //18 N° de Inscrição do processo RRA/Processo Judicial
	cQry += ",'' CNPJOR"								  //19 CNPJ Origem Recurso
	cQry += ",0 CUSTADV"								  //20 Total de Custas com advogados
	cQry += ",0 CUSTJUD"								  //21 Total de Custas Judiciais
	cQry += ",NVL(SUM(C30.C30_TOTAL), 0) VALBRUTO"   //22 Valor do documento
	cQry += ",NVL(SUM(C35.C35_BASE), 0) BASEIR"	  //23 Base de Cálculo IR
	cQry += ",NVL(C35.C35_ALIQ, 0) ALIQIR"		  	  //24 Alíquota do IR
	cQry += ",NVL(SUM(C35.C35_VALOR), 0) VALIR"	  //25 Valor do IR
endif
//26 Total de deduções
If !("INFORMIX" $ cBanco)  
	cQry += ",COALESCE((SELECT SUM(V4C.V4C_VLRDED) FROM " + RetSqlName("V4C") + " V4C WHERE V4C.V4C_FILIAL = C20.C20_FILIAL AND V4C.V4C_CHVNF = C20.C20_CHVNF "
else
	cQry += ",NVL((SELECT SUM(V4C.V4C_VLRDED) FROM " + RetSqlName("V4C") + " V4C WHERE V4C.V4C_FILIAL = C20.C20_FILIAL AND V4C.V4C_CHVNF = C20.C20_CHVNF "
endif
cQry += "AND V4C.V4C_NUMITE = C30.C30_NUMITE AND V4C.V4C_CODITE = C30.C30_CODITE AND V4C.V4C_CODTRI = C35.C35_CODTRI "
cQry += "AND V4C.V4C_CODTRI = ? AND V4C.D_E_L_E_T_ = ?),0) TOTDEDU "
aadd(aBind,'000012')
aadd(aBind,space(1))

//27 Valor total das deduções de dependentes
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(V84.V84_VALDED) FROM " + RetSqlName("V84") + " V84 WHERE V84.V84_FILIAL = C20.C20_FILIAL AND V84.V84_CHVNF = C20.C20_CHVNF "
else
	cQry += ",NVL((SELECT SUM(V84.V84_VALDED) FROM " + RetSqlName("V84") + " V84 WHERE V84.V84_FILIAL = C20.C20_FILIAL AND V84.V84_CHVNF = C20.C20_CHVNF "
endif
cQry += "AND V84.V84_IDPART = C20.C20_CODPAR AND V84.V84_NUMITE = C30.C30_NUMITE AND V84.V84_CODITE = C30.C30_CODITE AND V84.V84_CODTRI = C35.C35_CODTRI "
cQry += "AND V84.V84_CODTRI = ? AND V84.D_E_L_E_T_ = ?),0) TDEDUDEP "
aadd(aBind,'000012')
aadd(aBind,space(1))

//28 Total de Rendimentos Isentos
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(V4D.V4D_VLRISE) FROM " + RetSqlName("V4D") + " V4D WHERE V4D.V4D_FILIAL = C20.C20_FILIAL AND V4D.V4D_CHVNF = C20.C20_CHVNF "
else
	cQry += ",NVL((SELECT SUM(V4D.V4D_VLRISE) FROM " + RetSqlName("V4D") + " V4D WHERE V4D.V4D_FILIAL = C20.C20_FILIAL AND V4D.V4D_CHVNF = C20.C20_CHVNF "
endif
cQry += "AND V4D.V4D_NUMITE = C30.C30_NUMITE AND V4D.V4D_CODITE = C30.C30_CODITE AND V4D.V4D_CODTRI = C35.C35_CODTRI "
cQry += "AND V4D.V4D_CODTRI = ? AND V4D.D_E_L_E_T_ = ?),0) TOTISEN "
aadd(aBind,'000012')
aadd(aBind,space(1))

//29 Valor do Rendimento Suspenso por processo judicial
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(T9Q.T9Q_BSSUSP) FROM " + RetSqlName("T9Q") + " T9Q WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF "
else
	cQry += ",NVL((SELECT SUM(T9Q.T9Q_BSSUSP) FROM " + RetSqlName("T9Q") + " T9Q WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF "
endif
cQry += "AND T9Q.T9Q_NUMITE = C30.C30_NUMITE AND T9Q.T9Q_CODTRI = ? AND T9Q.D_E_L_E_T_ = ?),0) VBSIR "
aadd(aBind,'000012')
aadd(aBind,space(1))

//30 Valor da retenção nao efetuada devido Processo Ref
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(T9Q.T9Q_VALSUS) FROM " + RetSqlName("T9Q") + " T9Q WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF "
else
	cQry += ",NVL((SELECT SUM(T9Q.T9Q_VALSUS) FROM " + RetSqlName("T9Q") + " T9Q WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF "
endif
cQry += "AND T9Q.T9Q_NUMITE = C30.C30_NUMITE AND T9Q.T9Q_CODTRI = ? AND T9Q.D_E_L_E_T_ = ?),0) VRSIR "
aadd(aBind,'000012')
aadd(aBind,space(1))

//31 Valor da dedução suspensa
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(V88.V88_VALDED) FROM " + RetSqlName("V88") + " V88 WHERE V88.V88_FILIAL = C20.C20_FILIAL AND V88.V88_CHVNF = C20.C20_CHVNF "
else
	cQry += ",NVL((SELECT SUM(V88.V88_VALDED) FROM " + RetSqlName("V88") + " V88 WHERE V88.V88_FILIAL = C20.C20_FILIAL AND V88.V88_CHVNF = C20.C20_CHVNF "
endif
cQry += "AND V88.V88_NUMITE = C30.C30_NUMITE AND V88.V88_IDPROC = C30.C30_CODITE AND V88.V88_CODTRI = ? AND V88.D_E_L_E_T_ = ?),0) TDEDUSUSP "
aadd(aBind,'000012')
aadd(aBind,space(1))

cQry += iif(!("INFORMIX" $ cBanco) , ",COALESCE(( " , ",NVL(( ")
If !( cBanco $ ( "INFORMIX|ORACLE|OPENEDGE|POSTGRES|DB2" ) )
	cQry += "SELECT TOP 1 C1G.C1G_NUMPRO "
Else
	cQry += "SELECT C1G.C1G_NUMPRO "
EndIf
cQry += "FROM " + RetSqlName("T9Q") + " T9Q INNER JOIN "  + RetSqlName("C1G") + " C1G ON "
If cCompC1G == "EEE"
	cQry += " C1G.C1G_FILIAL = T9Q.T9Q_FILIAL "
Else
	If cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(T9Q.T9Q_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompC1G == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(T9Q.T9Q_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	Else
		cQry += "C1G.C1G_FILIAL = ? "
		aadd(aBind,xFilial("C1G"))
	EndIf
EndIf
cQry += "AND C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ = ? "
cQry += "WHERE T9Q.T9Q_FILIAL = C20.C20_FILIAL AND T9Q.T9Q_CHVNF = C20.C20_CHVNF AND T9Q.T9Q_NUMITE = C30.C30_NUMITE "
cQry += "AND T9Q.T9Q_ID = C30.C30_CODITE AND T9Q.T9Q_CODTRI = ? AND T9Q.D_E_L_E_T_ = ? "
aadd(aBind,space(1))
aadd(aBind,'000012')
aadd(aBind,space(1))

if cBanco == "ORACLE"
	cQry += " AND ROWNUM <= ? "
	aadd(aBind,1)
Elseif cBanco $ "POSTGRES|DB2"
	cQry += " LIMIT ? "
	aadd(aBind,1)
Endif

cQry += " ),'') NPROCREF "	//32 N° do Processo Referenciado

cQry += ",' ' CNPJPLS "		//33 CNPJ PLS
cQry += ",' ' BENEPLS "		//34 Beneficiário PLS
cQry += ",' ' CPFDEPE "		//35 CPF Dependente
cQry += ",' ' TIPPGTO "		//36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",0 VPGTPLS " 		//37 Valor pago PLS
cQry += ",0 REEMBAN " 		//38 Reembolso ano anterior
cQry += ",' ' TPMEDIC "		//39 Tipo de Inscrição Médico
cQry += ",' ' NINSMED "		//40 Nr. Inscrição Médico

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes dos pagamentos que se enquadram no R4010

@author Denis Souza
@since 15/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafPgtField( cDataIni, cDataFim, cBanco, cCompV4F, cCompC1H, cCompC1G, aInfEUF, aBind)

Local cQry 	   	 as Character
Local nC1HCNPJ 	 as Numeric
Local nV3SIDNATR as Numeric

Default cDataIni := ''
Default cDataFim := ''
Default cBanco   := ''
Default cCompV4F := ''
Default cCompC1G := ''
Default aInfEUF  := {}
Default aBind    := {}

nC1HCNPJ   := FWSX3Util():GetFieldStruct('C1H_CNPJ')[3]
nV3SIDNATR := FWSX3Util():GetFieldStruct('V3S_IDNATR')[3]

cQry := "SELECT PGT.FILIAL"  //01 Filial / Nome da filial / CNPJ da filial
cQry += ",PGT.CPF"			 //02 CPF Beneficiário
cQry += ",PGT.CODPAR"		 //03 Código participante
cQry += ",PGT.INDNIF"		 //04 Indicativo NIF
cQry += ",PGT.NIF"			 //05 N° NIF
cQry += ",PGT.FRMTRIB"		 //06 Forma Tributação
cQry += ",PGT.NOME"		 	 //07 Nome Beneficiário
cQry += ",PGT.ROTINA"		 //08 Tipo
cQry += ",PGT.SERIEPARC"	 //09 Série / Parcela
cQry += ",PGT.DOCTO"		 //10 N° Documento
cQry += ",PGT.NUMITE"		 //11 N° do Item
cQry += ",PGT.DTEMISPGT"	 //12 Data emissão/pagamento
cQry += ",PGT.ID"			 //13 ID do documento
cQry += ",PGT.CODNAT"		 //14 Natureza de Rendimento
cQry += ",PGT.INDFCISCP"	 //15 Indicativo de FCI/SCP
cQry += ",PGT.CNPJFCISCP"	 //16 CNPJ da FCI/SCP
cQry += ",PGT.NRRRAPJD"	 	 //17 N° de Inscrição do processo RRA/Processo Judicial
cQry += ",PGT.INDRRA"		 //18 Informação de RRA ou Processo Judicial
cQry += ",PGT.CNPJOR"		 //19 CNPJ Origem Recurso
If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE(( SELECT SUM(V4GADV.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GADV ON V4GADV.V4G_FILIAL = V4F.V4F_FILIAL "
else
	cQry += ",NVL(( SELECT SUM(V4GADV.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GADV ON V4GADV.V4G_FILIAL = V4F.V4F_FILIAL "
endif
cQry += "AND V4GADV.V4G_ID = V4F.V4F_ID AND V4GADV.V4G_TPDESP = ? AND V4GADV.V4G_DTDESP BETWEEN ? AND ? AND V4GADV.D_E_L_E_T_ = ? WHERE "
aadd(aBind,'1')
aadd(aBind,cDataIni)
aadd(aBind,cDataFim)
aadd(aBind,space(1))

If cCompV4F == "EEE"
	cQry += "V4F.V4F_FILIAL = PGT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(PGT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(PGT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	Else
		cQry += "V4F.V4F_FILIAL = ? "
		aadd(aBind,xFilial("V4F"))
	EndIf
EndIf
cQry += "AND V4F.V4F_ID = PGT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ?), 0) CUSTADV " //20 Total de Custas com advogados
aadd(aBind,space(1))

If !("INFORMIX" $ cBanco) 
	cQry += ",COALESCE((SELECT SUM(V4GJUD.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GJUD ON V4GJUD.V4G_FILIAL = V4F.V4F_FILIAL "
else
	cQry += ",NVL((SELECT SUM(V4GJUD.V4G_VLDESP) FROM " + RetSqlName("V4F") + " V4F INNER JOIN " + RetSqlName("V4G") + " V4GJUD ON V4GJUD.V4G_FILIAL = V4F.V4F_FILIAL "
endif
cQry += "AND V4GJUD.V4G_ID = V4F.V4F_ID AND V4GJUD.V4G_TPDESP = ? AND V4GJUD.V4G_DTDESP BETWEEN ? AND ? AND V4GJUD.D_E_L_E_T_ = ? WHERE "
aadd(aBind,'2')
aadd(aBind,cDataIni)
aadd(aBind,cDataFim)
aadd(aBind,space(1))

If cCompV4F == "EEE"
	cQry += " V4F.V4F_FILIAL = PGT.FILIAL "
Else
	If cCompV4F == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(PGT.FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompV4F == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(V4F.V4F_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(PGT.FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	Else
		cQry += "V4F.V4F_FILIAL = ? "
		aadd(aBind,xFilial("V4F"))
	EndIf
EndIf
cQry += "AND V4F.V4F_ID = PGT.IDRRAPJUD AND V4F.D_E_L_E_T_ = ?), 0) CUSTJUD " //21 Total de Custas Judiciais
aadd(aBind,space(1))

cQry += ",PGT.VALBRUTO"  //22 Valor do documento
cQry += ",PGT.BASEIR"	 //23 Base de Cálculo IR
cQry += ",PGT.ALIQIR"	 //24 Alíquota do IR
cQry += ",PGT.VALIR"	 //25 Valor do IR
cQry += ",PGT.TOTDEDU"	 //26 Total de deduções  	
cQry += ",PGT.TDEDUDEP"  //27 Valor total das deduções de dependentes 
cQry += ",PGT.TOTISEN"	 //28 Total de Rendimentos Isentos
cQry += ",PGT.VBSIR"	 //29 Valor do Rendimento Suspenso por processo judicial
cQry += ",PGT.VRSIR"	 //30 Valor da retenção nao efetuada devido Processo Ref
cQry += ",PGT.TDEDUSUSP" //31 Valor da dedução suspensa
cQry += ",PGT.NPROCREF"	 //32 N° do Processo Referenciado
cQry += ",PGT.CNPJPLS" 	 //33 CNPJ PLS
cQry += ",PGT.BENEPLS" 	 //34 Beneficiário PLS
cQry += ",PGT.CPFDEPE" 	 //35 CPF Dependente
cQry += ",PGT.TIPPGTO" 	 //36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",PGT.VPGTPLS" 	 //37 Valor pago PLS
cQry += ",PGT.REEMBAN" 	 //38 Reembolso ano anterior
cQry += ",PGT.TPMEDIC" 	 //39 Tipo de Inscrição Médico
cQry += ",PGT.NINSMED "  //40 Nr. Inscrição Médico

cQry += " FROM ( "

cQry += "SELECT "
cQry += "V3U.V3U_FILIAL FILIAL"				 	//01 Filial / Nome da filial / CNPJ da filial
cQry += ",C1H.C1H_CPF CPF"						//02 CPF Beneficiário
cQry += ",C1H.C1H_CODPAR CODPAR"				//03 Código participante

//04 Indicativo NIF
cQry += ",CASE WHEN C1H.C1H_INDNIF = ? THEN ? WHEN C1H.C1H_INDNIF = ? THEN ? "
cQry += "WHEN C1H.C1H_INDNIF = ? THEN ? ELSE ? END INDNIF "
aadd(aBind,'1')
aadd(aBind,'Possui')
aadd(aBind,'2')
aadd(aBind,'Dispensado')
aadd(aBind,'3')
aadd(aBind,'Pais nao exige')
aadd(aBind,'Nao Informado')

cQry += ",C1H.C1H_NIF NIF"						//05 N° NIF
cQry += "," + iif(!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(T9A.T9A_DESCRI,'') FRMTRIB"	//06 Forma Tributação
cQry += ",C1H.C1H_NOME NOME"					//07 Nome Beneficiário
cQry += ",'PGT' ROTINA"						  	//08 Tipo
cQry += ",V3U.V3U_PARCEL SERIEPARC"				//09 Série / Parcela
cQry += ",V3U.V3U_NUMERO DOCTO"				  	//10 N° Documento
cQry += ",' ' NUMITE"							//11 N° do Item
cQry += ",V3U.V3U_DTPAGT DTEMISPGT"			 	//12 Data emissão/pagamento
cQry += ",V3U.V3U_ID ID"						//13 ID do documento
cQry += ",V3O.V3O_CODIGO CODNAT"				//14 Natureza de Rendimento

//15 Indicativo de FCI/SCP
cQry += ",CASE WHEN V3U.V3U_FCISCP = ? THEN ? WHEN V3U.V3U_FCISCP = ? THEN ? ELSE ? END INDFCISCP"
aadd(aBind,'1')
aadd(aBind,'FCI')
aadd(aBind,'2')
aadd(aBind,'SCP')
aadd(aBind,'Nao Informado')

If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE(V3X.V3X_CNPJ,'') CNPJFCISCP" 	//16 CNPJ da FCI/SCP
	cQry += ",COALESCE(V4F.V4F_NRPROC,'') NRRRAPJD " 	//17 N° de Inscrição do processo RRA/Processo Judicial
	cQry += ",COALESCE( CASE WHEN V4F.V4F_INDRRA = ? THEN ? ELSE ? END , '') INDRRA" //18 Informação de RRA ou Processo Judicial
	cQry += ",COALESCE(V4F.V4F_CNPJOR,'') CNPJOR"		//19 CNPJ Origem Recurso
	aadd(aBind,'1')
	aadd(aBind,'Sim')
	aadd(aBind,'Nao')
else
	cQry += ",NVL(V3X.V3X_CNPJ,'') CNPJFCISCP" 	//16 CNPJ da FCI/SCP
	cQry += ",NVL(V4F.V4F_NRPROC,'') NRRRAPJD " 	//17 N° de Inscrição do processo RRA/Processo Judicial
	cQry += ",NVL( CASE WHEN V4F.V4F_INDRRA = ? THEN ? ELSE ? END , '') INDRRA" //18 Informação de RRA ou Processo Judicial
	cQry += ",NVL(V4F.V4F_CNPJOR,'') CNPJOR"		//19 CNPJ Origem Recurso
	aadd(aBind,'1')
	aadd(aBind,'Sim')
	aadd(aBind,'Nao')
endif
cQry += ",V3V.V3V_IDPROC IDRRAPJUD"			  		//Utilizado no join query acima campos 20 e 21

cQry += ",V3V.V3V_VALOR VALBRUTO "					//22 Valor do documento

//23 Base de Cálculo IR
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V46.V46_BASE) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT SUM(V46.V46_BASE) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
endif
cQry += "AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = ? AND V46.D_E_L_E_T_ = ?),0) BASEIR" 
aadd(aBind,'000028')
aadd(aBind,space(1))

//24 Alíquota do IR
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT V46.V46_ALIQ FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT V46.V46_ALIQ FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
endif
cQry += "AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = ? AND V46.D_E_L_E_T_ = ?),0) ALIQIR"
aadd(aBind,'000028')
aadd(aBind,space(1)) 

//25 Valor do IR
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V46.V46_VALOR) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT SUM(V46.V46_VALOR) FROM " + RetSqlName("V46") + " V46 WHERE V46.V46_FILIAL = V3U.V3U_FILIAL AND V46.V46_ID = V3U.V3U_ID "
endif
cQry += "AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.V46_IDTRIB = ? AND V46.D_E_L_E_T_ = ?),0) VALIR"
aadd(aBind,'000028')
aadd(aBind,space(1))  

//26 Total de deduções
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V4I.V4I_VLRDED) FROM " + RetSqlName("V4I") + " V4I WHERE V4I.V4I_FILIAL = V3U.V3U_FILIAL AND V4I.V4I_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT SUM(V4I.V4I_VLRDED) FROM " + RetSqlName("V4I") + " V4I WHERE V4I.V4I_FILIAL = V3U.V3U_FILIAL AND V4I.V4I_ID = V3U.V3U_ID "
endif
cQry += "AND V4I.V4I_IDNAT = V3V.V3V_CNATRE AND V4I.V4I_IDTRIB = ? AND V4I.D_E_L_E_T_ = ?),0) TOTDEDU"
aadd(aBind,'000028')
aadd(aBind,space(1))  

//27 Valor total das deduções de dependentes
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V85.V85_VALDED) FROM " + RetSqlName("V85") + " V85 WHERE V85.V85_FILIAL = V3U.V3U_FILIAL AND V85.V85_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT SUM(V85.V85_VALDED) FROM " + RetSqlName("V85") + " V85 WHERE V85.V85_FILIAL = V3U.V3U_FILIAL AND V85.V85_ID = V3U.V3U_ID "
endif
cQry += "AND V85.V85_IDPART = V3U.V3U_IDPART AND V85.V85_IDNAT = V3V.V3V_CNATRE AND V85.V85_IDTRIB = ? AND V85.D_E_L_E_T_ = ?),0) TDEDUDEP"
aadd(aBind,'000028')
aadd(aBind,space(1))  

//28 Total de Rendimentos Isentos
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V4J.V4J_VLRISE) FROM " + RetSqlName("V4J") + " V4J WHERE V4J.V4J_FILIAL = V3U.V3U_FILIAL AND V4J.V4J_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT SUM(V4J.V4J_VLRISE) FROM " + RetSqlName("V4J") + " V4J WHERE V4J.V4J_FILIAL = V3U.V3U_FILIAL AND V4J.V4J_ID = V3U.V3U_ID "
endif
cQry += "AND V4J.V4J_IDNAT = V3V.V3V_CNATRE AND V4J.V4J_IDTRIB = ? AND V4J.D_E_L_E_T_ = ?),0) TOTISEN"
aadd(aBind,'000028')
aadd(aBind,space(1))  

//29 Valor do Rendimento Suspenso por processo judicial
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V4H.V4H_VBASSU) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT SUM(V4H.V4H_VBASSU) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID "
endif
cQry += "AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = ? AND V4H.D_E_L_E_T_ = ?),0) VBSIR"
aadd(aBind,'000028')
aadd(aBind,space(1))  

//30 Valor da retenção nao efetuada devido Processo Ref
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V4H.V4H_VALSUS) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT SUM(V4H.V4H_VALSUS) FROM " + RetSqlName("V4H") + " V4H WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID "
endif
cQry += "AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = ? AND V4H.D_E_L_E_T_ = ?),0) VRSIR"
aadd(aBind,'000028')
aadd(aBind,space(1))  

//31 Valor da dedução suspensa
If !("INFORMIX" $ cBanco)
	cQry += ",COALESCE((SELECT SUM(V90.V90_VALDED) FROM " + RetSqlName("V90") + " V90 WHERE V90.V90_FILIAL = V3U.V3U_FILIAL AND V90.V90_ID = V3U.V3U_ID "
else
	cQry += ",NVL((SELECT SUM(V90.V90_VALDED) FROM " + RetSqlName("V90") + " V90 WHERE V90.V90_FILIAL = V3U.V3U_FILIAL AND V90.V90_ID = V3U.V3U_ID "
endif
cQry += "AND V90.V90_CNATRE = V3V.V3V_CNATRE AND V90.V90_IDTRIB = ? AND V90.D_E_L_E_T_ = ?),0) TDEDUSUSP"
aadd(aBind,'000028')
aadd(aBind,space(1))  

cQry += iif(!("INFORMIX" $ cBanco),",COALESCE(( ",",NVL(( ")
If !( cBanco $ ( "INFORMIX|ORACLE|OPENEDGE|POSTGRES|DB2" ) )
	cQry += "SELECT TOP 1 C1G.C1G_NUMPRO "
Else
	cQry += "SELECT C1G.C1G_NUMPRO "
EndIf
cQry += "FROM " + RetSqlName("V4H") + " V4H INNER JOIN "  + RetSqlName("C1G") + " C1G ON "
If cCompC1G == "EEE"
	cQry += " C1G.C1G_FILIAL = V4H.V4H_FILIAL "
Else
	If cCompC1G == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V4H.V4H_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + "))) "
	ElseIf cCompC1G == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cQry += "LTRIM(RTRIM(SUBSTRING(C1G.C1G_FILIAL,1, " + cValToChar(aInfEUF[1]) + "))) " + " = LTRIM(RTRIM(SUBSTRING(V4H.V4H_FILIAL,1, " +  cValToChar(aInfEUF[1]) + "))) "
	Else
		cQry += "C1G.C1G_FILIAL = ? "
		aadd(aBind,xFilial("C1G"))  
	EndIf
EndIf
cQry += "AND C1G.C1G_ID = V4H.V4H_IDPROC AND C1G.D_E_L_E_T_ = ? "
cQry += "WHERE V4H.V4H_FILIAL = V3U.V3U_FILIAL AND V4H.V4H_ID = V3U.V3U_ID "
cQry += "AND V4H.V4H_CNATRE = V3V.V3V_CNATRE AND V4H.V4H_IDTRIB = ? AND V4H.D_E_L_E_T_ = ? "
aadd(aBind,space(1))
aadd(aBind,'000028')
aadd(aBind,space(1))

if cBanco == "ORACLE"
	cQry += "AND ROWNUM <= ? "
	aadd(aBind,1)
Elseif cBanco $ "POSTGRES|DB2"
	cQry += "LIMIT ? "
	aadd(aBind,1)
Endif

cQry += " ),'') NPROCREF" //32 N° do Processo Referenciado

cQry += ",' ' CNPJPLS"	  //33 CNPJ PLS
cQry += ",' ' BENEPLS"	  //34 Beneficiário PLS
cQry += ",' ' CPFDEPE"	  //35 CPF Dependente
cQry += ",' ' TIPPGTO"	  //36 Tipo Pagamento (Reembolso ou Co-Participação)
cQry += ",0 VPGTPLS" 	  //37 Valor pago PLS
cQry += ",0 REEMBAN" 	  //38 Reembolso ano anterior
cQry += ",' ' TPMEDIC"	  //39 Tipo de Inscrição Médico
cQry += ",' ' NINSMED "	  //40 Nr. Inscrição Médico

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Registros/Campos provenientes dos pagamento\reembolso PLS que se enquadram no R4010

@author Denis Souza
@since 15/02/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function TafPlsField(cCompC1H,aInfEUF,aFilsV4B,cDataIni,cDataFim,nTmPrId40,lReport,oTabTemp,cBanco)

Local cQry 		as Character
Local cInto 	as Character
Local cTabName 	as Character
Local cFields	as Character
Local aStru 	as Array
Local aBind     as Array
Local oPrepare  as Object
Local nI        as Numeric

Default cCompC1H   := ''
Default aInfEUF	   := {}
Default aFilsV4B   := {}
Default cDataIni   := ''
Default cDataFim   := ''
Default nTmPrId40  := 0
Default lReport    := .F.
Default oTabTemp   := Nil
Default cBanco     := ''

aBind    := {}
oPrepare := Nil
nI       := 0
aStru    := {{'FILIAL' 	 ,GetSx3Cache('V4B_FILIAL'	,'X3_TIPO'),GetSx3Cache('V4B_FILIAL','X3_TAMANHO'),GetSx3Cache('V4B_FILIAL'	,'X3_DECIMAL')},; //01
			{'CPF' 	  	 ,GetSx3Cache('C1H_CPF'   	,'X3_TIPO'),GetSx3Cache('C1H_CPF'   ,'X3_TAMANHO'),GetSx3Cache('C1H_CPF'   	,'X3_DECIMAL')},; //02
			{'CODPAR' 	 ,GetSx3Cache('C1H_CODPAR'	,'X3_TIPO'),GetSx3Cache('C1H_CODPAR','X3_TAMANHO'),GetSx3Cache('C1H_CODPAR'	,'X3_DECIMAL')},; //03
			{'INDNIF' 	 ,"C",15,0},; //04
			{'NIF'    	 ,GetSx3Cache('C1H_NIF'   	,'X3_TIPO'),GetSx3Cache('C1H_NIF'   ,'X3_TAMANHO'),GetSx3Cache('C1H_NIF'   	,'X3_DECIMAL')},; //05
			{'FRMTRIB'	 ,GetSx3Cache('T9A_DESCRI'	,'X3_TIPO'),GetSx3Cache('T9A_DESCRI','X3_TAMANHO'),GetSx3Cache('T9A_DESCRI'	,'X3_DECIMAL')},; //06
			{'NOME'		 ,GetSx3Cache('C1H_NOME'	,'X3_TIPO'),GetSx3Cache('C1H_NOME'	,'X3_TAMANHO'),GetSx3Cache('C1H_NOME'	,'X3_DECIMAL')},; //07
			{'ROTINA'	 ,"C",3,0 },; //08
			{'SERIEPARC' ,"C",1,0 },; //09
			{'DOCTO'	 ,"C",1,0 },; //10
			{'NUMITE'	 ,"C",1,0 },; //11
			{'DTEMISPGT' ,GetSx3Cache('V4B_DTPGTO'	,'X3_TIPO'),GetSx3Cache('V4B_DTPGTO','X3_TAMANHO'),GetSx3Cache('V4B_DTPGTO'	,'X3_DECIMAL')},; //12
			{'ID' 		 ,GetSx3Cache('V4B_ID'		,'X3_TIPO'),GetSx3Cache('V4B_ID'	,'X3_TAMANHO'),GetSx3Cache('V4B_ID'		,'X3_DECIMAL')},; //13
			{'CODNAT' 	 ,"C",1,0 },; //14
			{'INDFCISCP' ,"C",15,0},; //15
			{'CNPJFCISCP',"C",1,0 },; //16
			{'INDRRA' 	 ,"C",3,0 },; //17
			{'NRRRAPJD'  ,"C",1,0 },; //18
			{'CNPJOR'    ,"C",1,0 },; //19
			{'CUSTADV'   ,"N",1,0 },; //20
			{'CUSTJUD'   ,"N",1,0 },; //21
			{'VALBRUTO'  ,"N",1,0 },; //22
			{'BASEIR'    ,"N",1,0 },; //23
			{'ALIQIR'    ,"N",1,0 },; //24
			{'VALIR'     ,"N",1,0 },; //25
			{'TOTDEDU'   ,"N",1,0 },; //26
			{'TDEDUDEP'  ,"N",1,0 },; //27
			{'TOTISEN'   ,"N",1,0 },; //28
			{'VBSIR'   	 ,"N",1,0 },; //29
			{'VRSIR'   	 ,"N",1,0 },; //30
			{'TDEDUSUSP' ,"N",1,0 },; //31
			{'NPROCREF'  ,"C",1,0 },; //32
			{'CNPJPLS'   ,GetSx3Cache('V4B_CNPJ'	,'X3_TIPO'),GetSx3Cache('V4B_CNPJ'	,'X3_TAMANHO'),GetSx3Cache('V4B_CNPJ'	,'X3_DECIMAL')},;//33
			{'BENEPLS'   ,"C",10,0},; //34
			{'CPFDEPE'   ,GetSx3Cache('V3R_CPF'		,'X3_TIPO'),GetSx3Cache('V3R_CPF'	,'X3_TAMANHO'),GetSx3Cache('V3R_CPF'	,'X3_DECIMAL')},;//35
			{'TIPPGTO'   ,"C",15,0},; //36
			{'VPGTPLS'   ,GetSx3Cache('V4B_VLRPGT'	,'X3_TIPO'),GetSx3Cache('V4B_VLRPGT','X3_TAMANHO'),GetSx3Cache('V4B_VLRPGT'	,'X3_DECIMAL')},;//37
			{'REEMBAN'   ,GetSx3Cache('V4B_VRBANT'	,'X3_TIPO'),GetSx3Cache('V4B_VRBANT','X3_TAMANHO'),GetSx3Cache('V4B_VRBANT'	,'X3_DECIMAL')},;//38
			{'TPMEDIC'   ,"C",15,0},;//39
			{'NINSMED'   ,GetSx3Cache('V4B_NRINSC'	,'X3_TIPO'),GetSx3Cache('V4B_NRINSC','X3_TAMANHO'),GetSx3Cache('V4B_NRINSC'	,'X3_DECIMAL')}	}//40

//Cria tabela temporaria (TCGenQry Error - Query greater than 32768 bytes)
oTabTemp := FWTemporaryTable():New(,aStru)
oTabTemp:Create()
cTabName := oTabTemp:GetRealName()

cInto 	:= "INSERT INTO " + cTabName + "( "
cFields := "FILIAL"		 //01
cFields += ",CPF"		 //02
cFields += ",CODPAR"	 //03
cFields += ",INDNIF"	 //04
cFields += ",NIF"		 //05
cFields += ",FRMTRIB"	 //06
cFields += ",NOME"		 //07
cFields += ",ROTINA"	 //08
cFields += ",SERIEPARC"  //09
cFields += ",DOCTO"		 //10
cFields += ",NUMITE"	 //11
cFields += ",DTEMISPGT"	 //12
cFields += ",ID"		 //13
cFields += ",CODNAT"	 //14
cFields += ",INDFCISCP"	 //15
cFields += ",CNPJFCISCP" //16
cFields += ",INDRRA"	 //17
cFields += ",NRRRAPJD"	 //18
cFields += ",CNPJOR"	 //19
cFields += ",CUSTADV"	 //20
cFields += ",CUSTJUD"	 //21
cFields += ",VALBRUTO"	 //22
cFields += ",BASEIR"	 //23
cFields += ",ALIQIR"	 //24
cFields += ",VALIR"		 //25
cFields += ",TOTDEDU"	 //26
cFields += ",TDEDUDEP"	 //27
cFields += ",TOTISEN"	 //28
cFields += ",VBSIR"		 //29
cFields += ",VRSIR"		 //30
cFields += ",TDEDUSUSP"	 //31
cFields += ",NPROCREF"	 //32
cFields += ",CNPJPLS"	 //33
cFields += ",BENEPLS"	 //34
cFields += ",CPFDEPE"	 //35
cFields += ",TIPPGTO"	 //36
cFields += ",VPGTPLS"	 //37
cFields += ",REEMBAN"	 //38
cFields += ",TPMEDIC"	 //39
cFields += ",NINSMED"	 //40

cInto += cFields + " ) ( "

cInto += "SELECT DISTINCT V4B.V4B_FILIAL FILIAL"  //01 Filial /Nome da filial /CNPJ da filial
cInto += ",C1H.C1H_CPF CPF"		  				  //02 CPF Beneficiário
cInto += ",C1H.C1H_CODPAR CODPAR" 				  //03 Código participante

//04 Indicativo NIF
cInto += ",CASE WHEN C1H.C1H_INDNIF = ? THEN ? WHEN C1H.C1H_INDNIF = ? THEN ? "
cInto += "WHEN C1H.C1H_INDNIF = ? THEN ? ELSE ? END INDNIF "
aadd(aBind,'1')
aadd(aBind,'Possui')
aadd(aBind,'2')
aadd(aBind,'Dispensado')
aadd(aBind,'3')
aadd(aBind,'Pais nao exige')
aadd(aBind,'Nao Informado')

cInto += ",C1H.C1H_NIF NIF"						  //05 N° NIF
cInto += "," + iif(!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(T9A.T9A_DESCRI,'') FRMTRIB"   //06 Forma Tributação
cInto += ",C1H.C1H_NOME NOME"		 			  //07 Nome Beneficiário
cInto += ",'PLS' ROTINA"			 	 		  //08 Tipo
cInto += ",' ' SERIEPARC"			 			  //09 Série / Parcela
cInto += ",' ' DOCTO"				 			  //10 N° Documento
cInto += ",' ' NUMITE"				 			  //11 N° do Item
cInto += ",V4B.V4B_DTPGTO DTEMISPGT"	 		  //12 Data emissão/pagamento
cInto += ",V4B.V4B_ID ID"			 			  //13 ID do documento
cInto += ",' ' CODNAT"				 			  //14 Natureza de Rendimento
cInto += ",' ' INDFCISCP"			 			  //15 Indicativo de FCI/SCP
cInto += ",' ' CNPJFCISCP" 			 			  //16 CNPJ da FCI/SCP
cInto += ",' ' INDRRA"	  			 			  //17 N° de Inscrição do processo RRA/Processo Judicial
cInto += ",' ' NRRRAPJD" 			 			  //18 Informação de RRA ou Processo Judicial
cInto += ",' ' CNPJOR"	  			 			  //19 CNPJ Origem Recurso
cInto += ",0 CUSTADV" 				 			  //20 Total de Custas com advogados
cInto += ",0 CUSTJUD"				 			  //21 Total de Custas Judiciais
cInto += ",0 VALBRUTO" 				 			  //22 Valor do documento
cInto += ",0 BASEIR" 				 			  //23 Base de Cálculo IR
cInto += ",0 ALIQIR" 				 			  //24 Alíquota do IR
cInto += ",0 VALIR" 				 	 		  //25 Valor do IR
cInto += ",0 TOTDEDU" 				 			  //26 Total de deduções
cInto += ",0 TDEDUDEP" 				 			  //27 Valor total das deduções de dependentes
cInto += ",0 TOTISEN"	 			 			  //28 Total de Rendimentos Isentos
cInto += ",0 VBSIR"	 				 			  //29 Valor do Rendimento Suspenso por processo judicial
cInto += ",0 VRSIR"	 				 			  //30 Valor da retenção nao efetuada devido Processo Ref
cInto += ",0 TDEDUSUSP"				 			  //31 Valor da dedução suspensa
cInto += ",' ' NPROCREF" 			 			  //32 N° do Processo Referenciado
cInto += ",V4B.V4B_CNPJ CNPJPLS"	 	 		  //33 CNPJ PLS

//34 Beneficiário PLS
cInto += ",CASE WHEN V4B.V4B_INDBEN = ? THEN ? ELSE ? END BENEPLS"
aadd(aBind,'1')
aadd(aBind,'Titular')
aadd(aBind,'Dependente')

cInto += "," + iif(!("INFORMIX" $ cBanco),"COALESCE","NVL") + "(V3R.V3R_CPF,'') CPFDEPE"	  //35 CPF Dependente

//36 Tipo Pagamento (Reembolso ou Co-Participação)
cInto += ",CASE WHEN V4B.V4B_TPPGTO = ? THEN ? ELSE ? END TIPPGTO"
aadd(aBind,'1')
aadd(aBind,'Co Participacao')
aadd(aBind,'Reembolso')

cInto += ",V4B.V4B_VLRPGT VPGTPLS" 	 			  //37 Valor pago PLS
cInto += ",V4B.V4B_VRBANT REEMBAN" 	 			  //38 Reembolso ano anterior

//39 Tipo de Inscrição Médico
cInto += ",CASE WHEN V4B.V4B_TPINSC = ? THEN ? ELSE ? END TPMEDIC"
aadd(aBind,'1')
aadd(aBind,'Pessoa Juridica')
aadd(aBind,'Pessoa Fisica')

cInto += ",V4B.V4B_NRINSC NINSMED " 	 		  //40 Nr. Inscrição Médico

cInto += QryFilReemb(cCompC1H,aInfEUF,aFilsV4B,cDataIni,cDataFim,nTmPrId40,lReport,,,@aBind) + ')'

if "ORA" $ cBanco //invalid identifier
	cInto := STRTRAN(cInto,"SUBSTRING","SUBSTR")
endif

oPrepare := FwExecStatement():New( cInto )
For nI := 1 To Len(aBind)
	If Valtype(aBind[nI]) == 'C'
		oPrepare:setString( nI, aBind[nI] )
	ElseIf Valtype(aBind[nI]) == 'A'
		oPrepare:setIn( nI, aBind[nI] )
	Endif
Next nI
cInto := oPrepare:getFixQuery()

tcSqlExec( cInto ) //Inclui registros na tabela temporária

cQry := "SELECT " + cFields + " FROM " + cTabName

Return cQry

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Query Invoice Detail (Segundo nível pendente apuração e relatório)

@author Rafael Leme
@since 08/08/2023
@version 1.0 
/*/
//---------------------------------------------------------------------------------------------------------------
Function QryInv4010( cPerApu, aFil, aInfEUF, cCPF, cNif, cCodPart, cFilDoc, oPrepare )

Local aFiliais	 As Array
Local aBind      As Array
Local cCompC1H   As Character
Local cDataIni   As Character
Local cDataFim   As Character
Local cBd		 As Character
Local cQuery     As Character
Local cIsNull	 As Character
Local cAlias     As Character
local cDtConta   AS Character
Local nV3SIdNatR As numeric
Local nC30CNatRe As numeric
Local nV3VCNatRe As numeric
Local nTmPrId40  As numeric
Local nLevel     As numeric
Local nI         As numeric
Local lApuSTri   As Logical

Default cPerApu  := ""
Default aFil     := {}
Default aInfEUF  := {}
Default cCodPart := ""
Default cNif     := ""
Default cFilDoc  := cFilAnt
Default oPrepare := Nil

cQuery     := ""
cIsNull    := ""
cDataIni   := cPerApu + "01" //ex: 20220201
cDataFim   := DtoS( LastDay( StoD( cDataIni ) ) )
cAlias	   := ""
cCompC1H   := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cBd		   := Upper(AllTrim(TcGetDb()))
aFiliais   := Separa(StrTran(StrTran(StrTran(TafRetFilC("C20", aFil),"(",""),")",""),"'",""),",")
nV3SIdNatR := FWSX3Util():GetFieldStruct('V3S_IDNATR')[3]
nC30CNatRe := FWSX3Util():GetFieldStruct('C30_CNATRE')[3]
nV3VCNatRe := FWSX3Util():GetFieldStruct('V3V_CNATRE')[3]
nTmPrId40  := FWSX3Util():GetFieldStruct('C20_PRID40')[3]
cIsNull    := Iif(!("INFORMIX" $ cBd), "COALESCE", "NVL")
nLevel     := 2
nI         := 0
cDtConta   := SuperGetMv('MV_TAFDT40',.F.,'2')
lApuSTri   := SuperGetMv('MV_TAFSTRI',.F.,.F.)
aBind      := {}

cQuery += " SELECT TBGER.ROTINA ROTINA, "
cQuery += " TBGER.DOCTO DOCTO, "
cQuery += " TBGER.SERIE SERIE, "
cQuery += " TBGER.NATREN NATREN, "
cQuery += " TBGER.DATAGER DATAGER, "
cQuery += " TBGER.VLBRUT VLBRUT, "
cQuery += " TBGER.BASEIR BASEIR, "
cQuery += " TBGER.VALIR VALIR, "
cQuery += " TBGER.VLDED VLDED "
cQuery += " FROM ( "
cQuery += " 		SELECT 'FAT'          ROTINA, "
cQuery += " 			LEM.LEM_NUMERO         DOCTO, "
cQuery += " 			LEM.LEM_PREFIX         SERIE, "
cQuery += " 			V3O.V3O_CODIGO        NATREN, "
cQuery += " 			LEM."+ iif(cDtConta == '2','LEM_DTEMIS','LEM_DTCONT')+" DATAGER,"
cQuery += 						cIsNull + "(V3S.V3S_VALOR, 0) VLBRUT, " 
cQuery += 						cIsNull + "(V47.V47_BASECA, 0) BASEIR, " 
cQuery += 						cIsNull + "(V47.V47_VLTRIB, 0) VALIR, "
cQuery += "				( "
cQuery += "					SELECT "
cQuery += "						SUM( " + cIsNull + " (V4L.V4L_VLRDED, 0) ) "
cQuery += "					FROM " + RetSqlName("V4L") + " V4L " 
cQuery += "					WHERE V4L.V4L_FILIAL = LEM.LEM_FILIAL "
cQuery += "						AND V4L.V4L_ID = LEM.LEM_ID "
cQuery += "						AND V4L.V4L_IDPART = LEM.LEM_IDPART "
cQuery += "						AND V4L.V4L_NUMFAT = LEM.LEM_NUMERO "
cQuery += "						AND V4L.V4L_IDNATR = V3S.V3S_IDNATR "
cQuery += "						AND V4L.V4L_DECTER = V3S.V3S_DECTER "
cQuery += "						AND V4L.V4L_IDTRIB = V47.V47_IDTRIB "
cQuery += "						AND V4L.D_E_L_E_T_ = ? "
cQuery += "				) VLDED "
aadd(aBind,Space(1))

cQuery += QryFilFat(cCompC1H,aInfEUF,nV3SIdNatR,aFiliais,cDataIni,cDataFim,nTmPrId40,,,,nLevel,cDtConta,lApuSTri,cFilDoc,@aBind)

If !Empty(StrTran( cCPF,"'","" ))
	cQuery += " AND C1H.C1H_CPF = ? "
	aadd(aBind,StrTran(cCPF,"'",""))
ElseIf !Empty(cNif)
	cQuery += " AND C1H.C1H_NIF = ? "
	aadd(aBind,cNif)
Else
	cQuery += " AND C1H.C1H_CODPAR = ? "
	aadd(aBind,cCodPart)
EndIf

cQuery += " UNION ALL "

cQuery += " SELECT 'NFS'    ROTINA, "
cQuery += " 	C20.C20_NUMDOC   DOCTO, "
cQuery += " 	C20.C20_SERIE    SERIE, "
cQuery += " 	V3O.V3O_CODIGO  NATREN, "
cQuery += " 	C20."+ iif(cDtConta == '2','C20_DTDOC','C20_DTCONT')+" DATAGER,"
cQuery += 		cIsNull + " (SUM(C30.C30_TOTAL),0) VLBRUT, " 
cQuery += 		cIsNull + " (SUM(C35.C35_BASE),0) BASEIR, " 
cQuery +=		cIsNull + " (SUM(C35.C35_VALOR),0) VALIR, "
cQuery += " 	( "
cQuery += " 		SELECT "
cQuery += " 			SUM( " + cIsNull + " (V4C.V4C_VLRDED,0) ) VLDED "
cQuery += " 		FROM " + RetSqlName("V4C") + " V4C "
cQuery += " 		WHERE V4C.V4C_FILIAL = C20.C20_FILIAL "
cQuery += " 			AND V4C.V4C_CHVNF = C20.C20_CHVNF "
cQuery += " 		AND V4C.D_E_L_E_T_ = ? "
cQuery += " 	) VLDED "
aadd(aBind,space(1))

cQuery += QryFilNota(cCompC1H,aInfEUF,nC30CNatRe,aFiliais,cDataIni,cDataFim,nTmPrId40,,,,nLevel,cDtConta,lApuSTri,cFilDoc,@aBind)

If !Empty(StrTran( cCPF, "'", "" ))
	cQuery += " AND C1H.C1H_CPF = ? "
	aadd(aBind,StrTran(cCPF,"'",""))
ElseIf !Empty(cNif)
	cQuery += " AND C1H.C1H_NIF = ? "
	aadd(aBind,cNif)
Else
	cQuery += " AND C1H.C1H_CODPAR = ? "
	aadd(aBind,cCodPart)
EndIf

cQuery += " GROUP BY C20.C20_NUMDOC, C20.C20_SERIE,  V3O.V3O_CODIGO, "
cQuery += " C20."+ iif(cDtConta == '2','C20_DTDOC','C20_DTCONT')+" "
cQuery += " , C20.C20_FILIAL, C20.C20_CHVNF "

cQuery += " UNION ALL"

cQuery += " SELECT          'PGT' ROTINA, "
cQuery += " 	V3U.V3U_NUMERO         DOCTO, "
cQuery += " 	V3U.V3U_SERIE          SERIE, "
cQuery += " 	V3O.V3O_CODIGO        NATREN, "
cQuery += " 	V3U.V3U_DTPAGT       DATAGER, "
cQuery += 		cIsNull + " (V3V.V3V_VALOR, 0) VLBRUT, " 
cQuery += 		cIsNull + " (V46.V46_BASE, 0) BASEIR, " 
cQuery += 		cIsNull + " (V46.V46_VALOR, 0) VALIR, "
cQuery += " 	(
cQuery += " 		SELECT 
cQuery += " 			SUM( " + cIsNull + "(V4I.V4I_VLRDED,0) ) 
cQuery += " 		FROM " + RetSqlName("V4I") + " V4I 
cQuery += " 		WHERE V4I.V4I_FILIAL = V3U.V3U_FILIAL "
cQuery += " 			AND V4I.V4I_ID = V3U.V3U_ID 
cQuery += " 			AND V4I.V4I_IDNAT = V3V.V3V_CNATRE 
cQuery += " 			AND V4I.V4I_IDTRIB = V46.V46_IDTRIB 
cQuery += " 			AND V4I.D_E_L_E_T_ = ?
cQuery += " 	) VLDED "
aadd(aBind,space(1))

cQuery += QryFilPgto(cCompC1H,aInfEUF,nV3VCNatRe,aFiliais,cDataIni,cDataFim,nTmPrId40,,,,nLevel,lApuSTri,cFilDoc,@aBind)

If !Empty(StrTran( cCPF, "'", "" ))
	cQuery += " AND C1H.C1H_CPF = ? "
	aadd(aBind,StrTran(cCPF,"'",""))
ElseIf !Empty(cNif)
	cQuery += " AND C1H.C1H_NIF = ? "
	aadd(aBind,cNif)
Else
	cQuery += " AND C1H.C1H_CODPAR = ? "
	aadd(aBind,cCodPart)
EndIf

cQuery += " UNION ALL"

cQuery += " SELECT 'PLS'    ROTINA, "
cQuery += " 	V4B.V4B_CNPJ     DOCTO, "
cQuery += " 	CASE WHEN V4B.V4B_INDBEN = ? THEN ? ELSE ? END SERIE, "
cQuery += " 	' '             NATREN, "
cQuery += " 	V4B.V4B_DTPGTO DATAGER, "
cQuery += " 	0               VLBRUT, "
cQuery += " 	0               BASEIR, "
cQuery += " 	0                VALIR, "
cQuery += " 	0			   	VLDED "
cQuery += " FROM " + RetSqlName("V4B") + " V4B "
aadd(aBind, '1')
aadd(aBind, 'Titular')
aadd(aBind, 'Dependente')

cQuery += QryFilReemb(cCompC1H,aInfEUF,aFiliais,cDataIni,cDataFim,nTmPrId40,,nLevel,cFilDoc,@aBind)

If !Empty(StrTran( cCPF, "'", "" ))
	cQuery += " AND C1H.C1H_CPF = ? "
	aadd(aBind,StrTran(cCPF,"'",""))
ElseIf !Empty(cNif)
	cQuery += " AND C1H.C1H_NIF = ? "
	aadd(aBind,cNif)
Else
	cQuery += " AND C1H.C1H_CODPAR = ? "
	aadd(aBind,cCodPart)
EndIf

cQuery += " ) TBGER "
cQuery += " ORDER BY "
cQuery += " TBGER.ROTINA, "
cQuery += " TBGER.DATAGER "

If !("DB2" $ cBd )
	cQuery := ChangeQuery( cQuery )
EndIf

cAlias := GetNextAlias()

oPrepare := FwExecStatement():New(cQuery)

For nI := 1 To Len(aBind)
	If Valtype(aBind[nI]) == 'C'
		oPrepare:setString( nI, aBind[nI] )
	EndIf
Next nI

oPrepare:cbasequery := oPrepare:getfixquery()
oPrepare:OpenAlias(cAlias)

aSize(aBind,0)

Return {cAlias}

//-------------------------------------------------------------------
/*/{Protheus.doc} WS002D4010

@description Monta a mensagem JON de retorno referente ao invoice detail
@author Rafael de Paula Leme
@since 09/08/2023
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function WS002D4010(aApurac, oEstruct)

	Local nTotInv as Numeric

	nTotInv := 0

    while !(aApurac[1])->(eof())

        aAdd( oEstruct["invoices"],JsonObject():New())
        nTotInv   :=  len(oEstruct["invoices"])

        //Tipo
        oEstruct["invoices"][nTotInv]["type"]         := (aApurac[1])->ROTINA

        //Documento
        oEstruct["invoices"][nTotInv]["document"]     := (aApurac[1])->DOCTO

        //Série
        oEstruct["invoices"][nTotInv]["series"]       := (aApurac[1])->SERIE

        //Natureza do Rendimento
        oEstruct["invoices"][nTotInv]["natureIncome"] := (aApurac[1])->NATREN

        //Data do fato gerador
        oEstruct["invoices"][nTotInv]["date"]         := StoD((aApurac[1])->DATAGER)

        //Valor Bruto
        oEstruct["invoices"][nTotInv]["grossValue"]   := (aApurac[1])->VLBRUT

        //Base Imposto (IR)
        oEstruct["invoices"][nTotInv]["taxBase"]      := (aApurac[1])->(BASEIR + VLDED)

		//Valor Imposto (IR)
		oEstruct["invoices"][nTotInv]["taxAmount"]    := (aApurac[1])->VALIR

        (aApurac[1])->(dbSkip())
    endDo

Return oEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} IniVarStat        

Inicializa as variaveis statics

@Return nil 

@author Karen Honda
@since  17/11/2023
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Static Function IniVarStat()
If __lV3UPerApu == nil
	__lV3UPerApu := TafColumnPos("V3U_PERAPU")
EndIf
Return
