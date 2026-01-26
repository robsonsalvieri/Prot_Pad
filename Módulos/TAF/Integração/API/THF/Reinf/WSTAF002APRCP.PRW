#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'

#DEFINE SINTETICO 1,1
#DEFINE ANALITICO 2,1
#DEFINE EVTDETAIL 1
#DEFINE HASNEXTED 3

Static __oTmpFil := Nil
 
//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 

Monta a mensagem JSON de retorno referente a 2010 e 2020

@author Henrique Fabiano Pateno Pereira
@since 16/04/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
function WS002APRCP(aApurac, oEstruct, cPeriod, aFilToReinf, cEvento, oValidationError, lHasNext)
  
    local cIDAux     as character
    local cBranch    as character
    local cCGC       as character
    local cCnpjCno	 as character
    local cDescr	 as character 
    local nTSintItem as numeric 
    local aFil       as array
    local aSM0       as array
    local lNewArray  as logical  
	local lTotDoc    as logical

    default oValidationError["registryKey"] := {}
    default lHasNext                        := .F.

    cIDAux     := ""
    cBranch    := ""
    cCGC	   := ""
    cCnpjCno   := ""
    cDescr	   := ""
    nTSintItem := 0
    aFil       := {}
    aSM0       := {}
    lNewArray  := .F.
	lTotDoc    := (aApurac[EVTDETAIL])->(FieldPos("TOTDOC")) > 0

    While !(aApurac[EVTDETAIL])->(eof())

        if Alltrim((aApurac[EVTDETAIL])->CINDOBRA) == '1' .OR. Alltrim((aApurac[EVTDETAIL])->CINDOBRA) == '2'
            cCnpjCno := Alltrim((aApurac[EVTDETAIL])-> CCNPJTMPR)
            cDescr	 := (aApurac[EVTDETAIL])-> CDSOBRA
        else
            cCnpjCno := Alltrim((aApurac[EVTDETAIL])-> CNPJ)
            cDescr	 := (aApurac[EVTDETAIL])-> C1HNOME
        endIf
            
		aadd(oEstruct["eventDetail"],JsonObject():New())  
		nTSintItem := len(oEstruct["eventDetail"]) 

		aSM0 := FWSM0Util():GetSM0Data( SM0->M0_CODIGO , (aApurac[EVTDETAIL])->FIL , { "M0_FILIAL", "M0_CGC"} )

		cBranch := aSM0[1][2]
		cCGC    := aSM0[2][2]

		aFil := RetFil(aFilToReinf, cCGC)

		//Nome da filial
		oEstruct["eventDetail"][nTSintItem]["branch"]		            := alltrim(EncodeUTF8(cBranch))
		//Nome da filial
		oEstruct["eventDetail"][nTSintItem]["branchId"]		            := (aApurac[EVTDETAIL])->FIL
		//CNPJ
		oEstruct["eventDetail"][nTSintItem]["taxNumber"]	            := cCnpjCno
		//Quantidade de notas/faturas
		oEstruct["eventDetail"][nTSintItem]["totalInvoice"]             := Iif( lTotDoc,(aApurac[EVTDETAIL])->TOTDOC,0)
		//Id de apuração
		oEstruct["eventDetail"][nTSintItem]["key"]			            := cCnpjCno 
		//Razão Social
		oEstruct["eventDetail"][nTSintItem]["company"]		            := cDescr
		//Status
		oEstruct["eventDetail"][nTSintItem]["status"]		            := Iif( lTotDoc, Iif(Empty((aApurac[EVTDETAIL])->PROCID),'validated','notValidated') ,Iif(TafRStatEv(cPeriod,,,cEvento,aFil,2,,,,,cCnpjCno ) $ ' |0|1|2|', 'notValidated', 'validated'))
        //Total Bruto
        oEstruct["eventDetail"][nTSintItem]["totalGrossValue"]          :=  (aApurac[EVTDETAIL])->VLRTBRUTO 
        //Total da base de cálculo
        oEstruct["eventDetail"][nTSintItem]["totalTaxBase"]             :=  (aApurac[EVTDETAIL])->VLRTBRET                 
        //Total dos tributos
        oEstruct["eventDetail"][nTSintItem]["totalTaxes"]               :=  (aApurac[EVTDETAIL])->NVLTlRTPC        
        //Propriedade errors que habilita o icone no frontend
    	oEstruct["eventDetail"][nTSintItem]["errors"]                   := 'errors'

        If Len(oValidationError["registryKey"]) > 0
            // Chave de busca do erro da apuração
            oEstruct["eventDetail"][nTSintItem]["keyValidationErrors"]  := KeyError(oEstruct["eventDetail"][nTSintItem], oValidationError)
        EndIf

        (aApurac[EVTDETAIL])->(DbSkip())
       
    EndDo

    oEstruct['hasNext'] := aApurac[HASNEXTED]

	(aApurac[EVTDETAIL])->(DBCloseArea())

return oEstruct

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 

Monta a mensagem JON de retorno referente a 2010 e 2020 na visão detalhada das notas
para cada participante essa função é executada 1 unica vez

@author Henrique Fabiano Pateno Pereira
@since 16/04/2019 
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
function Det002APRCP(oEstruct, aApurac, cCNPJ)

local nTAnalytic    :=  0 

    (aApurac[ANALITICO])->(dbGoTop())
     
    While !(aApurac[ANALITICO])->(eof())  

        aAdd( oEstruct["invoices"],JsonObject():New())
        nTAnalytic   :=  len(oEstruct["invoices"]) 
       
        //Tipo
        oEstruct["invoices"][nTAnalytic]["type"]  :=  (aApurac[ANALITICO])->ROTINA
        
        //Num. doc
        oEstruct["invoices"][nTAnalytic]["invoice"]  :=  (aApurac[ANALITICO])->NUMDOCTO
        
        // Série        
        oEstruct["invoices"][nTAnalytic]["invoiceSeries"]  :=  (aApurac[ANALITICO])->SERIE

        // Cód. serviço 
        oEstruct["invoices"][nTAnalytic]["serviceCode"]  :=  (aApurac[ANALITICO])->CODSERVIC + "-" + WsDService((aApurac[ANALITICO])->CODSERVIC)
        
        // Data de emissão  
        oEstruct["invoices"][nTAnalytic]["issueDate"]  :=  (aApurac[ANALITICO])->DTEMISSNF 
       
        // Valor bruto
        oEstruct["invoices"][nTAnalytic]["grossValue"]  :=  (aApurac[ANALITICO])->VLRBRUTO
        
        // Base de Cálculo 
        oEstruct["invoices"][nTAnalytic]["taxBase"]  :=  (aApurac[ANALITICO])->VLRBASERET
        
        // Alíquota

        oEstruct["invoices"][nTAnalytic]["aliquot"]  :=  (aApurac[ANALITICO])->ALIQ //(aApurac[ANALITICO])->VLRBASERET 
        
        // Tributo
        oEstruct["invoices"][nTAnalytic]["tax"]  :=  (aApurac[ANALITICO])->VLRRETENC

		(aApurac[ANALITICO])->(DbSkip()) 
	endDo

return oEstruct

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} 

Retorna a filial corrente, para consulta dos status dos registros a serem transmitidos

@author Bruno Cremaschi
@since 29/10/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
static function RetFil(aLoadFil, cCGC)

local nX    as numeric
local aRet  as array

nX := 0
aRet := {}

for nX := 1 to len(aLoadFil)
    If aLoadFil[nX][6] == AllTrim(cCGC)
        aAdd(aRet, aLoadFil[nx])
    EndIf
next nX

return aRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Leticia Campos
@since 30/07/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------

Static Function KeyError(oEstruct, oValidationError)
    local cKeyError as character
    local nX        as numeric

    cKeyError       := ""
    nX              := 1

    For nX := 1 to Len(oValidationError["registryKey"])
        if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
            if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
                cKeyError := oValidationError["registryKey"][nX]["error"]
            endif
        endif
    Next nX

return ( cKeyError )

Static Function GetCGCFil( aFil )

	Local cAliasFil    as character
	Local cTabTmp      as character
	Local cInsert      as character
	Local cInsertValue as character
	Local cTable       as character
	Local nTamFil      as numeric
	Local nTamEmp      as numeric
	Local nX           as numeric
	Local aFilCGC      as array
	Local aStruTmp     as array

	cAliasFil    := ''
	cTabTmp      := GetNextAlias()
	cInsert      := ''
	cInsertValue := ''
	cTable       := ''
	nX           := 0
	nTamFil	     := TamSX3("C20_FILIAL")[1]
	nTamEmp      := Len(cEmpAnt)
	aFilCGC      := {}
	aStruTmp     := {}
	
	aAdd( aStruTmp, {'TMPEMP','C',nTamEmp,0} )
	aAdd( aStruTmp, {'TMPFIL','C',nTamFil,0} )
	aAdd( aStruTmp, {'TMPCGC','C',14,0} )

	If __oTmpFil <> Nil 
		__oTmpFil:Delete()
		__oTmpFil := Nil
	EndIf

	__oTmpFil := FwTemporaryTable():New( cTabTmp )
	__oTmpFil:SetFields( aStruTmp )
	__oTmpFil:AddIndex( '01', {'TMPEMP','TMPFIL'} )
	__oTmpFil:Create()

	cTable	:= __oTmpFil:GetRealName()

	cInsert := " INSERT INTO " + cTable  + " (TMPEMP, TMPFIL, TMPCGC) "

	For nX := 1 To Len(aFil)
		cInsertValue := " VALUES ('" + cEmpAnt + "','" + AllTrim( aFil[nX][2] ) + "','" + Posicione("SM0", 1, cEmpAnt + AllTrim( aFil[nX][2] ), "M0_CGC") + "')  "
		TcSqlExec( cInsert + cInsertValue)
	Next

	( cTabTmp )->(DbGoTop())

Return cTable

/*/{Protheus.doc} EvtDet1020
	(Função responsável por gerar a query com as informações necessárias para o eventDetail)
	@type  Function
	@author Rafael de Paula Leme
	@since 22/09/2022
	@version 1.0
/*/
Function EvtDet1020(cPerApu, cReg, aFil, aInfEUF, nPage, nSize)

	Local cFiliais	as Character
	Local cCompC1H  as Character
	Local cDataIni  as Character
	Local cDataFim  as Character
    Local cTableSM0 as Character
	Local cBd		as Character
	Local cQuery    as Character
	Local cQryPrin  as Character
	Local cTopRow   as Character
	Local lHasNext  as Logical
	Local nTotReg   as numeric
	Local lRowNum   as Logical

	Default cPerApu := ""
	Default cReg 	:= ""

	cQuery          := ""
	cQryPrin		:= "" 
	cDataIni        := cPerApu + "01" //ex: 20220201
	cDataFim        := DtoS( LastDay( StoD( cDataIni ) ) )
    cTableSM0       := GetCGCFil(aFil)
	cAlias		    := GetNextAlias()
	cAliasTot       := ""
	cTopRow         := ""
	cCompC1H		:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
	cBd				:= Upper(AllTrim(TcGetDb()))
	cFiliais		:= TafRetFilC("C20", aFil)
	nTotReg         := 0
	lHasNext        := .F.
	lRowNum     	:= .F.
	
	If FindFunction("TafBdVers")
		lRowNum := TafBdVers()
	EndIf	

	cQuery += " FIL, EVENTO, PERIODO, CTPINSC, CNRINDC, CCNPJTMPR, CTPINSCTOM, CINDOBRA, CIDOBRA, CDSOBRA, "
	cQuery += " CNPJ, C1HNOME, PROCID, VLRTBRUTO, VLRTBRET, NVLTLRTPC, VLRTRADIC, VLRTNRPRNC, VLRTNRADIC, TOTDOC, CODPAR "
	cQuery += " FROM ("
    cQuery += " SELECT Q2.Q1FIL FIL, Q2.Q1EVENTO EVENTO, Q2.Q1PERIODO PERIODO, Q2.Q1CTPINSC CTPINSC, Q2.Q1CNRINDC CNRINDC, " 
	cQuery += " Q2.Q1CCNPJTMPR CCNPJTMPR, Q2.Q1CTPINSCTOM CTPINSCTOM, Q2.Q1CINDOBRA CINDOBRA, Q2.Q1CIDOBRA CIDOBRA, "
	If cBd $ "INFORMIX"
		cQuery += " NVL(Q2.Q1DSCOBRA,'') CDSOBRA, "
	else
		cQuery += " COALESCE(Q2.Q1DSCOBRA,'') CDSOBRA, "
	endif
	cQuery += " Q2.Q1CNPJ CNPJ, "
	cQuery += " Q2.CODPAR, "
	If cBd $ "INFORMIX"
		cQuery += " NVL((SELECT "
	else
		cQuery += " COALESCE((SELECT "
	endif

	If cBd $ "ORACLE|POSTGRES|DB2"
		cQuery += " C1H.C1H_NOME "
		If cBd $ "ORACLE"
			cTopRow := " AND ROWNUM <= 1 "
		ElseIf cBd $ "POSTGRES|DB2 "
			cTopRow := " LIMIT 1 "
		EndIf
	ElseIf cBd $ "INFORMIX"
		cQuery += " C1H_NOME FROM (SELECT FIRST 1 C1H.C1H_NOME "
	ElseIf cBd $ "MSSQL7"
		cQuery += " TOP 1 C1H.C1H_NOME "
	Endif

	cQuery += " FROM " + RetSqlName("C1H") + " C1H "
	cQuery += " WHERE "

	If cCompC1H == "EEE"
		cQuery += " C1H.C1H_FILIAL = Q2.Q1FIL AND "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") = SUBSTRING(Q2.Q1FIL, 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") AND "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1]) + ") = SUBSTRING(Q2.Q1FIL, 1," + cValToChar(aInfEUF[1]) + ") AND "
		EndIf
	EndIf

	cQuery += " C1H.C1H_CNPJ = Q2.Q1CNPJ AND C1H.C1H_PPES = '2' AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' AND Q2.CODPAR = C1H.C1H_ID "
	
	If cBd $ "ORACLE"
		cQuery += cTopRow
	EndIf

	If cBd $ "POSTGRES"
		cQuery += " ORDER BY C1H.C1H_FILIAL " + cTopRow
	EndIf

	If cBd $ "INFORMIX"
		cQuery += " )"
	EndIf

	cQuery += "), ' ') C1HNOME, "
	
	cQuery += " MAX(Q2.Q1PROCID) PROCID, SUM(Q2.Q1VLRBRUTO) VLRTBRUTO, SUM(Q2.Q1VLRBASERET) VLRTBRET, SUM(Q2.Q1NVLTLRTPC) NVLTLRTPC, "
	cQuery += " SUM(Q2.Q1VLRADICIONAL) VLRTRADIC, SUM(Q2.Q1VLRNRETPRINC) VLRTNRPRNC, SUM(Q2.Q1VLRNRETADIC) VLRTNRADIC,CASE WHEN Q1CIDOBRA = '' THEN COUNT(DISTINCT Q2.Q1NUMDOCTO) ELSE COUNT( Q2.Q1NUMDOCTO) END TOTDOC "

    cQuery += " FROM ( "
	
    cQuery += " SELECT Q1.FIL Q1FIL, Q1.ROTINA Q1ROTINA, Q1.EVENTO Q1EVENTO, Q1.PERIODO Q1PERIODO, Q1.CNRINDC Q1CNRINDC, "
	cQuery += " CASE WHEN Q1.EVENTO = 'R-2010' THEN CASE WHEN Q1.NRINSC IS NOT NULL AND  LTRIM(RTRIM(Q1.NRINSC)) <> 'SEM CODIGO' AND Q1.INDOBRA <> '0' "
    cQuery += " THEN Q1.TPINSC ELSE '1' END ELSE '1' END Q1CTPINSC, "
	cQuery += " CASE WHEN Q1.NRINSC IS NOT NULL AND  LTRIM(RTRIM(Q1.NRINSC)) <> 'SEM CODIGO' AND Q1.INDOBRA <> '0' THEN Q1.INDOBRA ELSE '0' END Q1CINDOBRA, "
	cQuery += " CASE WHEN Q1.NRINSC IS NOT NULL AND  LTRIM(RTRIM(Q1.NRINSC)) <> 'SEM CODIGO' AND Q1.INDOBRA <> '0' THEN Q1.IDOBRA ELSE '' END Q1CIDOBRA, "
    cQuery += " CASE WHEN Q1.NRINSC IS NOT NULL AND  LTRIM(RTRIM(Q1.NRINSC)) <> 'SEM CODIGO' AND Q1.INDOBRA <> '0' THEN SUBSTRING(Q1.NRINSC,1,14) ELSE Q1.CNPJ END Q1CCNPJTMPR, "
	cQuery += " CASE WHEN Q1.EVENTO = 'R-2010' THEN '' ELSE CASE WHEN Q1.NRINSC IS NOT NULL AND  LTRIM(RTRIM(Q1.NRINSC)) <> 'SEM CODIGO' AND Q1.INDOBRA <> '0' THEN Q1.TPINSC ELSE '1' END END Q1CTPINSCTOM, "
	cQuery += " Q1.DSCOBRA Q1DSCOBRA, Q1.PROCID Q1PROCID, Q1.NUMDOCTO Q1NUMDOCTO, "
	cQuery += " Q1.CNPJ Q1CNPJ, Q1.VLRBRUTO Q1VLRBRUTO, "
	cQuery += " Q1.VLRBASERET Q1VLRBASERET,	(Q1.VLRRETENCAO + Q1.VLRRETSUB) Q1NVLTLRTPC, Q1.VLRADICIONAL Q1VLRADICIONAL, Q1.VLRNRETPRINC Q1VLRNRETPRINC, Q1.VLRNRETADIC Q1VLRNRETADIC, Q1.CODPAR CODPAR "

	cQuery += " FROM ( "

	cQuery += " SELECT '" + cReg + "' EVENTO, '" + cPerApu + "' PERIODO, 'NFS' ROTINA, TMPSM0.TMPCGC CNRINDC, "
    cQuery += " C20.C20_FILIAL FIL, C20.C20_NUMDOC NUMDOCTO, "
	cQuery += " C20.C20_VLDOC VLRBRUTO, "
	cQuery += " CASE WHEN C20.C20_IDOBR <> ' ' AND (T9C.T9C_INDOBR = '1' OR T9C.T9C_INDOBR = '2') THEN ' ' ELSE C20.C20_CODPAR END CODPAR, "
	cQuery += " T9C.T9C_TPINSC TPINSC, T9C.T9C_NRINSC NRINSC, T9C.T9C_ID IDOBRA, T9C.T9C_DSCOBR DSCOBRA, "
	cQuery += " T9C.T9C_INDOBR INDOBRA,	"
	cQuery += " CASE WHEN C20.C20_IDOBR <> ' ' AND (T9C.T9C_INDOBR = '1' OR T9C.T9C_INDOBR = '2') THEN T9C.T9C_NRINSC ELSE C1H.C1H_CNPJ END CNPJ, "
	cQuery += " C20.C20_IDOBR CODOBR, "

	cQuery += " SUM(C35.C35_BASE) VLRBASERET, SUM(C35.C35_VALOR) VLRRETENCAO, SUM(C35.C35_VLSCON) VLRRETSUB, SUM(C35.C35_VLRNPG) VLRNRETPRINC, "
	cQuery += " SUM(C35.C35_VLRADI) VLRADICIONAL, SUM(C35.C35_VLRANP) VLRNRETADIC,"
	cQuery += " CASE WHEN C20.C20_PROCID = '' THEN '1' ELSE '' END PROCID "

	cQuery += " FROM "

	cQuery += RetSqlName("C20") + " C20"

    cQuery += " INNER JOIN " + cTableSM0 + " TMPSM0 ON TMPSM0.TMPEMP = '" + cEmpAnt + "' AND TMPSM0.TMPFIL = C20.C20_FILIAL "
	cQuery += " INNER JOIN " + RetSqlName("C30") + " C30 ON C20.C20_FILIAL = C30_FILIAL AND C30.D_E_L_E_T_ = ' ' AND C20.C20_CHVNF = C30.C30_CHVNF AND C30.C30_IDTSER <> ' ' AND C30.C30_TPREPA = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("C35") + " C35 ON C30.C30_FILIAL = C35_FILIAL AND C30.C30_CHVNF = C35.C35_CHVNF AND C30.C30_NUMITE = C35.C35_NUMITE AND "
	cQuery += " C30.C30_CODITE = C35.C35_CODITE AND C35.C35_CODTRI = '000013' AND C35.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("C8C") + " C8C ON C8C.C8C_ID = C30.C30_IDTSER AND C8C.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "  + RetSqlName("T9C") + " T9C ON T9C.T9C_ID = C20.C20_IDOBR AND T9C.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR AND C1H.C1H_PPES = '2' AND C1H.C1H_CNPJ <> '' AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' "

	If cCompC1H == "EEE"
		cQuery += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL, 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL, 1," + cValToChar(aInfEUF[1]) + ") "
		EndIf
	EndIf

	cQuery += " WHERE "
	cQuery += " C20.C20_FILIAL IN " + cFiliais + " AND C20.D_E_L_E_T_ = ' ' AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') AND "
	
	If cReg == "R-2010"
		cQuery += " C20.C20_INDOPE = '0' AND "
	ElseIf cReg == "R-2020"
		cQuery += " C20.C20_INDOPE = '1' AND "
	EndIf

	cQuery += " C20.C20_DTDOC BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
	cQuery += " GROUP BY TMPSM0.TMPCGC, C20.C20_FILIAL, C20.C20_NUMDOC, C20.C20_VLDOC, C20.C20_CODPAR, "
	cQuery += " T9C.T9C_TPINSC, T9C.T9C_NRINSC, T9C.T9C_ID, T9C.T9C_DSCOBR,T9C.T9C_INDOBR, C1H.C1H_CNPJ, "
    cQuery += " C20.C20_IDOBR, C20.C20_PROCID "

	cQuery += " UNION ALL "

    cQuery += " SELECT '" + cReg + "' EVENTO, '" + cPerApu + "' PERIODO, 'FAT' ROTINA, TMPSM0.TMPCGC CNRINDC, "
	cQuery += " LEM.LEM_FILIAL FIL, LEM.LEM_NUMERO NUMDOCTO, "
	cQuery += " LEM.LEM_VLBRUT VLRBRUTO, "
	cQuery += " CASE WHEN LEM.LEM_IDOBRA <> ' ' AND (T9C.T9C_INDOBR = '1' OR T9C.T9C_INDOBR = '2') THEN ' ' ELSE C1H.C1H_ID END CODPAR, "
	cQuery += " T9C.T9C_TPINSC TPINSC, T9C.T9C_NRINSC NRINSC, "
	cQuery += " T9C.T9C_ID IDOBRA, T9C.T9C_DSCOBR DSCOBRA, T9C.T9C_INDOBR INDOBRA,  "
	cQuery += " CASE WHEN LEM.LEM_IDOBRA <> ' ' AND (T9C.T9C_INDOBR = '1' OR T9C.T9C_INDOBR = '2') THEN T9C.T9C_NRINSC ELSE C1H.C1H_CNPJ END CNPJ, "
	cQuery += " '0' CODOBR, T5M.T5M_BSINSS VLRBASERET, T5M.T5M_VLINSS VLRRETENCAO, T5M.T5M_VLRETS VLRRETSUB, "
	cQuery += " T5M.T5M_VLRETP VLRNRETPRINC, T5M.T5M_VLADIC VLRADICIONAL, T5M.T5M_VLADNE VLRNRETADIC, "
	cQuery += " CASE WHEN LEM.LEM_PROCID = '' THEN '1' ELSE '' END PROCID "

	cQuery += " FROM "

	cQuery += RetSqlName("LEM") + " LEM"

	cQuery += " INNER JOIN " + cTableSM0 + " TMPSM0 ON TMPSM0.TMPEMP = '" + cEmpAnt + "' AND TMPSM0.TMPFIL = LEM.LEM_FILIAL "
    cQuery += " INNER JOIN " + RetSqlName("T5M") + " T5M ON T5M.T5M_FILIAL = LEM.LEM_FILIAL AND T5M.T5M_ID = LEM.LEM_ID AND T5M.T5M_IDPART = LEM.LEM_IDPART AND T5M.T5M_IDTSER <> ' ' AND T5M.T5M_TPREPA = ' ' AND "
	cQuery += " T5M.T5M_NUMFAT = LEM.LEM_NUMERO AND T5M.T5M_BSINSS > 0 AND T5M.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("C8C") + " C8C ON C8C.C8C_ID = T5M.T5M_IDTSER AND C8C.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "  + RetSqlName("T9C") + " T9C ON T9C.T9C_FILIAL = LEM.LEM_FILIAL AND T9C.T9C_ID = LEM.LEM_IDOBRA AND T9C.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = LEM.LEM_IDPART AND C1H.C1H_PPES = '2' AND C1H.C1H_CNPJ <> '' AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ = ' ' "

	If cCompC1H == "EEE"
		cQuery += "AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "
	Else
		If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1] + aInfEUF[2]) + ") "
		ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1, " + cValToChar(aInfEUF[1]) + ") " + " = SUBSTRING(LEM.LEM_FILIAL,1, " +  cValToChar(aInfEUF[1]) + ") "
		EndIf
	EndIf

	cQuery += " WHERE "
	
	cQuery	+= " LEM.LEM_FILIAL IN " + cFiliais + " AND LEM.LEM_DOCORI = ' ' AND LEM.D_E_L_E_T_ = ' ' AND "

	If cReg == "R-2010"
		cQuery += " LEM.LEM_NATTIT = '0' AND "
	ElseIf cReg == "R-2020"
		cQuery += " LEM.LEM_NATTIT = '1' AND "
	EndIf

	cQuery += " LEM.LEM_DTEMIS BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
    cQuery += " ) Q1) Q2 "

    cQuery += " GROUP BY "
	cQuery += " Q2.Q1FIL, Q2.Q1EVENTO, Q2.Q1PERIODO, Q2.Q1CTPINSC, Q2.Q1CNRINDC, Q2.Q1CINDOBRA, Q2.Q1CIDOBRA, Q2.Q1DSCOBRA, "
	cQuery += " Q2.Q1CCNPJTMPR, Q2.Q1CTPINSCTOM, Q2.CODPAR, "
	cQuery += " Q2.Q1CNPJ ) Q3  "

	// Se tiver paginação, busco a quantidade total de registro para poder retornar ao Front (lHasNext)
	// se existe uma próxima página.
	If nPage > 0 .And. nSize > 0
		cAliasTot := GetNextAlias()
		
		cQueryTot := "SELECT COUNT(Q4.EVENTO) QTDEREGS FROM ( SELECT " +  cQuery + ") Q4"

		If !("DB2" $ cBD)
			cQueryTot := ChangeQuery(cQueryTot)
		EndIf	
		TCQuery cQueryTot New Alias (cAliasTot)

		nTotReg := (cAliasTot)->QTDEREGS

		(cAliasTot)->(DBCloseArea())

		lHasNext := Iif((nPage * nSize) > nTotReg, .F., .T.)
	EndIf

	If !lRowNum 
		cQryPrin := " SELECT " + cQuery
		cQryPrin += " ORDER BY "
		cQryPrin += " Q3.PROCID DESC, Q3.PERIODO, Q3.CTPINSC, Q3.CNRINDC, Q3.CCNPJTMPR, Q3.CTPINSCTOM "

		If nPage > 0 .And. nSize > 0
			cQryPrin += " OFFSET ( " + cValToChar(nPage-1) + " * " + cValToChar(nSize) + " ) ROWS"
			cQryPrin += " FETCH NEXT " + cValToChar(nSize) + " ROWS ONLY"
		EndIf	
	Else
		cQryPrin := "SELECT * FROM ( "
    	cQryPrin += "SELECT ROW_NUMBER() OVER( ORDER BY Q3.PROCID DESC, Q3.PERIODO, Q3.CTPINSC, Q3.CNRINDC, Q3.CCNPJTMPR, Q3.CTPINSCTOM) LINE_NUMBER, "
		cQryPrin += cQuery
		cQryPrin += " ) TAB "
		If nPage > 0 .And. nSize > 0
   			cQryPrin += "WHERE LINE_NUMBER BETWEEN " + cValToChar(((nPage-1)*nSize) +1) + " AND " + cValToChar(nSize*nPage)
		EndIf
	EndIf
	If !("DB2" $ cBD)
		cQryPrin := ChangeQuery(cQryPrin)
	EndIf	

	TCQuery cQryPrin New Alias (cAlias)

Return {cAlias, nTotReg, lHasNext}


