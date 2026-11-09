#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    RELAGDG Autor ≥ Jo„o Victor Silva     ≥ Data ≥ 16/06/25 	  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Impressao RelatÛrio de Mov. Agrega/Desagrega       		  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function RELAGDG()

	Local oReport

	oReport := RptDefRel(oReport)

	if ValType(oReport) == "O"
		oReport:nFontBody := 10
		oReport:oPage:nPaperSize := 9
		oReport:SetLineHeight(45)
		oReport:SetRightAlignPrinter(.T.)
		oReport:PrintDialog()
	Endif

Return
 
/*/{Protheus.doc} RptDefRel
Cria o relatrio
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25
@param oReport, object, Objeto do relatrio
@param cTitulo, character, Ttulo do relatrio
@param cNomRel, character, Nome do relatrio
@param cDesc, character, Descrio do relatrio
@return object, Objeto do relatrio criado
/*/

Static Function RptDefRel(oReport)

	oReport := RunRptRel(oReport)

Return oReport
 
/*/{Protheus.doc} RunRptRel
Imprime o relatrio
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25
@param oReport, object, Objeto do relatorio
/*/
Static Function RunRptRel(oReport)

	Local aParam := fParamBox()

	if ValType(aParam) <> "A"
		return .f.
	endif

	oReport := fImpMov(oReport,aParam)
 
Return oReport
/*/{Protheus.doc} fImpMov
Apresentar as movimentaÁıes do Agrega/Desagregas
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25
@param oReport, object, Objeto do relatrio
@param nLin, numeric, Nmero da linha inicial do relatrio
@param nCol, numeric, Nmero da coluna inicial do relatrio
@return numeric, Nmero da linha atual do relatrio
/*/
Static Function fImpMov(oReport,aParam)

	Local cMV_PAR03 := AllTrim(cValtoChar(aParam[3]))
	Local cTitulo := "Relatorio PeÁas"

	if cMV_PAR03 = '1'
		cTitulo := "Relatorio Veiculos/AMS"
	Endif

	oReport := TReport():New( "RELAGDG",cTitulo,,{|oReport| fDadosAgrDes(aParam,oReport)})

	oReport:FatLine()

	oSection1 := TRSection():New( oReport, OemToAnsi("Secao 1"),{"VFJ","VFP","VV1","VFQ","SB1"},,.T.)

    oSection1:SetTotalInLine(.F.)

    TRCell():New(oSection1, "VFP_CODEXE", "VFP"   , "CÛdigo"    ,,TamSX3("VFP_CODEXE")[1])
	
	if cMV_PAR03 == "1" //Veiculos Maquinas
		TRCell():New(oSection1, "VFP_CHAINT" , "VFP", "CÛdigo AMS",  ,TamSX3("VFP_CHAINT")[1])
		TRCell():New(oSection1, "VV1_CHASSI" , "VV1", "Chassi AMS"  ,,TamSX3("VV1_CHASSI")[1])
	Else // PeÁas
		TRCell():New(oSection1, "VFQ_CODSB1" , "VFQ", "CÛdigo PeÁa" ,   ,TamSX3("VFQ_CODSB1")[1])
		TRCell():New(oSection1, "B1_DESC"    , "SB1", "DescriÁ„o PeÁa" ,,TamSX3("B1_DESC")[1])
		TRCell():New(oSection1, "VFQ_QUANT"  , "VFQ", "Qtde"           ,,TamSX3("VFQ_QUANT")[1])
	Endif 

	oSection2 := TRSection():New( oReport, OemToAnsi("Secao 2"),,,.T.)

	oSection2:SetTotalInLine(.F.)

Return oReport

/*/{Protheus.doc} fDadosAgr
Query para montar o array com as movimentacoes do Agrega
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25
/*/
Static Function fDadosAgrDes(aParam,oReport)

	Local cMV_PAR01 := aParam[1]
	Local cMV_PAR02 := AllTrim((aParam[2]))
	Local cMV_PAR03 := AllTrim((aParam[3]))
	Local cMV_PAR04 := AllTrim((aParam[4]))
	Local cChaint := ""

	Local cQuery := ""

	if !Empty(cMV_PAR01)
		cChaint := Posicione("VV1",2,xFilial("VV1")+cMV_PAR01, "VV1_CHAINT")
	Endif

	IF cMV_PAR03 = '1' //Veiculos/Maquinas
		cQuery := fQueryAMS(cMV_PAR02,cChaint,oReport,cMV_PAR04)
	Else //PeÁas
		cQuery := fQueryPeca(cMV_PAR02,cChaint,oReport,cMV_PAR04)
	Endif

Return 

 /* {Protheus.doc} fQueryVFP
Retorna o resultado da query da Agrega AMS (Saida)
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25 */

Static Function fQueryAMS(cOp,cChaint,oReport,cStatus)

	Local cQuery := ""
    Local oSection1 := Nil
	Local oSection2 := Nil
	Local cAlias := "PECORC"
	Local nTotal := 0

    //Pegando as secoes do relatorio
    oSection1 := oReport:Section(1)
	oSection2 := oReport:Section(2)

	If cOp == '1' .or. cOp == '3' // Agrega AMS ou Ambos 
		cQuery += 	"SELECT "
		cQuery +=   "VFJ.VFJ_CODIGO,"
		cQuery +=	"VFJ.R_E_C_N_O_ AS VFJ_RECNO,"
		cQuery +=	"VFM.R_E_C_N_O_ AS VFM_RECNO,"
		cQuery +=   "NULL AS VFP_RECNO,"
		cQuery +=   "NULL AS VFP_CUSUNI,"
		cQuery +=   "VFM.VFM_CUSUNI AS VFM_CUSUNI,"
		cQuery +=   "VV1.R_E_C_N_O_ AS VV1_RECNO"
		cQuery += 	" FROM " + RetSqlName("VFJ") + " VFJ"
		cQuery += 	" JOIN " + RetSqlName("VFM") + " VFM ON VFM.VFM_FILIAL = '" + xFilial("VFM") + "'"
		cQuery +=		" AND VFM.VFM_FILIAL = VFJ.VFJ_FILIAL"
		cQuery +=		" AND VFM.VFM_CODEXE = VFJ.VFJ_CODIGO"
		cQuery +=		" AND VFM.D_E_L_E_T_ = '' "
		cQuery += 	" JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
		cQuery +=		" AND VV1.VV1_CHAINT = VFM.VFM_CHAINT "
		cQuery +=		" AND VV1.D_E_L_E_T_ = '' "
		cQuery += 	"WHERE VFJ.VFJ_FILIAL = '" + xFilial("VFJ") + "'"
		cQuery +=	"AND VFJ.D_E_L_E_T_ = '' "
		cQuery +=   "AND VFJ_PROCES IN ('1','3','4') "

		if !Empty(cChaint)
			cQuery += "AND (CASE WHEN VFM.VFM_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END ) = '"+cChaint+"'"
		Endif
		
	Endif
	
	if cOp == '3'
		cQuery += "UNION ALL "
	Endif
		
	If cOp == '2' .or. cOp == '3' // Desagrega AMS ou Ambos
		cQuery += 	"SELECT "
		cQuery +=   "VFJ.VFJ_CODIGO,"
		cQuery +=   "VFJ.R_E_C_N_O_ AS VFJ_RECNO,"
		cQuery +=   "NULL AS VFM_RECNO,"
		cQuery +=   "VFP.R_E_C_N_O_ AS VFP_RECNO,"
		cQuery +=   "VFP.VFP_CUSUNI AS VFP_CUSUNI,"
		cQuery+=   "NULL AS VFM_CUSUNI,"
		cQuery +=   "VV1.R_E_C_N_O_ AS VV1_RECNO"
		cQuery += 	" FROM " + RetSqlName("VFJ") + " VFJ"
		cQuery += 	" JOIN " + RetSqlName("VFP") + " VFP ON VFP.VFP_FILIAL = '" + xFilial("VFP") + "'"
		cQuery +=		" AND VFP.VFP_FILIAL = VFJ.VFJ_FILIAL"
		cQuery +=		" AND VFP.VFP_CODEXE = VFJ.VFJ_CODIGO"
		cQuery +=		" AND VFP.D_E_L_E_T_ = '' "
		cQuery += 	" JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
		cQuery +=		" AND VV1.VV1_CHAINT = VFP.VFP_CHAINT"
		cQuery +=		" AND VV1.D_E_L_E_T_ = '' "
		cQuery += 	"WHERE VFJ.VFJ_FILIAL = '" + xFilial("VFJ") + "'"
		cQuery +=	"AND VFJ.D_E_L_E_T_ = '' "
		cQuery +=   "AND VFJ_PROCES IN ('2','3','4') "

		if !Empty(cChaint)
			cQuery += "AND (CASE WHEN VFP.VFP_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END ) = '"+cChaint+"' "
		Endif

	Endif

	if cStatus <> "4" // Diferente de Ambos Status
		cQuery += " AND VFJ.VFJ_STATUS = '"+cStatus+"'"
	endif

	cQuery += " ORDER BY VFJ_CODIGO ASC"
		
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )
	Do While !( cAlias )->( Eof() )
		oReport:SetMeter( (cAlias)->(RecCount()) )
		oSection1:Init()
		VFJ->(DBGOTO( ( cAlias )->VFJ_RECNO ))
		VV1->(DBGOTO( ( cAlias )->VV1_RECNO ))

		if cOp == '1' .or. cOp == '3'
			VFM->( DBGOTO( (cAlias)->VFM_RECNO ) )
			nTotal += ((cAlias)->VFM_CUSUNI)
		endif

		if cOp == '2' .or. cOp == '3'
			VFP->( DBGOTO( (cAlias)->VFP_RECNO ) )
			nTotal += ((cAlias)->VFP_CUSUNI)
		endif
		
		oSection1:PrintLine()
		oReport:SkipLine()

		( cAlias )->(dbSkip())
	
	Enddo

	( cAlias )->(dbCloseArea())
	oSection1:Finish()

	oSection2:Init()
	TRCell():New(oSection2, "PreÁo Total" ,, "PreÁo Total", "@E 999,999.99",12,,{|| nTotal })
	oSection2:PrintLine()
	oSection2:Finish()

Return

 /* {Protheus.doc} fQueryPeca
Retorna o resultado da query das movimentaÁıes de PeÁas
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25 */

Static Function fQueryPeca(cOp,cChaint,oReport,cStatus)

	Local cQuery := ""
	Local oSection1 := Nil
	Local oSection2 := Nil
	Local cAlias := "PECORC"
	Local nTotal := 0
     
    //Pegando as secoes do relatorio
    oSection1 := oReport:Section(1)
	oSection2 := oReport:Section(2)

	If cOp == '1' .or. cOp == '3' // Agrega PeÁas ou Ambos
		cQuery += 	"SELECT"
		cQuery +=   " VFJ.VFJ_CODIGO,"
		cQuery +=	"VFJ.R_E_C_N_O_ AS VFJ_RECNO,"
		cQuery +=	"VFN.R_E_C_N_O_ AS VFN_RECNO,"
		cQuery +=   "NULL AS VFQ_RECNO,"
		cQuery +=   "NULL AS VFQ_CUSUNI,"
		cQuery +=   "NULL AS VFQ_QUANT,"
		cQuery +=   "VFN.VFN_CUSUNI AS VFN_CUSUNI,"
		cQuery +=   "VFN.VFN_QUANT AS VFN_QUANT,"
		cQuery +=	"SB1.R_E_C_N_O_ AS SB1_RECNO,"
		cQuery +=	"VV1.R_E_C_N_O_ AS VV1_RECNO"
		cQuery += 	" FROM " + RetSqlName("VFJ") + " VFJ"
		cQuery += 	" JOIN " + RetSqlName("VFN") + " VFN ON VFN.VFN_FILIAL = '" + xFilial("VFN") + "'"
		cQuery +=		" AND VFN.VFN_FILIAL = VFJ.VFJ_FILIAL"
		cQuery +=		" AND VFN.VFN_CODEXE = VFJ.VFJ_CODIGO"
		cQuery +=		" AND VFN.D_E_L_E_T_ = '' "
		cQuery += 	" JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery +=		" AND SB1.B1_COD = VFN.VFN_CODSB1"
		cQuery +=		" AND SB1.D_E_L_E_T_ = '' "
		cQuery +=	" JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
		cQuery +=		" AND VV1.VV1_CHAINT = CASE WHEN VFN.VFN_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END"
		cQuery +=		" AND VV1.D_E_L_E_T_ = '' "
		cQuery += 	"WHERE VFJ.VFJ_FILIAL = '" + xFilial("VFJ") + "'"
		cQuery +=	"AND VFJ.D_E_L_E_T_ = '' "
		cQuery +=   "AND VFJ_PROCES IN ('1','3','4') "

		if !Empty(cChaint)
			cQuery += "AND (CASE WHEN VFN.VFN_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END ) = '"+cChaint+"'"
		Endif

	Endif
	
	if cOp == '3'
		cQuery += "UNION ALL "
	Endif
		
	If cOp == '2' .or. cOp == '3'// Desagrega de PeÁas ou Ambos
		cQuery += 	"SELECT"
		cQuery +=   " VFJ.VFJ_CODIGO,"
		cQuery +=	" VFJ.R_E_C_N_O_ AS VFJ_RECNO,"
		cQuery +=	          " NULL AS VFN_RECNO,"
		cQuery +=    "VFQ.R_E_C_N_O_ AS VFQ_RECNO,"
		cQuery +=    "VFQ.VFQ_CUSUNI AS VFQ_CUSUNI,"
		cQuery +=    "VFQ.VFQ_QUANT  AS VFQ_QUANT,"
		cQuery +=    "NULL AS VFN_CUSUNI,"
		cQuery +=    "NULL AS VFN_QUANT,"
		cQuery +=	" SB1.R_E_C_N_O_ AS SB1_RECNO,"
		cQuery +=	" VV1.R_E_C_N_O_ AS VV1_RECNO"
		cQuery += 	" FROM " + RetSqlName("VFJ") + " VFJ"
		cQuery += 	" JOIN " + RetSqlName("VFQ") + " VFQ ON VFQ.VFQ_FILIAL = '" + xFilial("VFQ") + "'"
		cQuery +=		" AND VFQ.VFQ_FILIAL = VFJ.VFJ_FILIAL"
		cQuery +=		" AND VFQ.VFQ_CODEXE = VFJ.VFJ_CODIGO"
		cQuery +=		" AND VFQ.D_E_L_E_T_ = '' "
		cQuery += 	" JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery +=		" AND SB1.B1_COD = VFQ.VFQ_CODSB1"
		cQuery +=		" AND SB1.D_E_L_E_T_ = '' "
		cQuery +=	" JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "'"
		cQuery +=		" AND VV1.VV1_CHAINT = CASE WHEN VFQ.VFQ_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END"
		cQuery +=		" AND VV1.D_E_L_E_T_ = '' "
		cQuery += 	"WHERE VFJ.VFJ_FILIAL = '" + xFilial("VFJ") + "'"
		cQuery +=	"AND VFJ.D_E_L_E_T_ = '' "
		cQuery +=   "AND VFJ_PROCES IN ('2','3','4') "

		if !Empty(cChaint)
			cQuery += "AND (CASE WHEN VFQ.VFQ_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END ) = '"+cChaint+"'"
		Endif

	Endif

	if cStatus <> "4" // Diferente de Ambos Status
		cQuery += " AND VFJ.VFJ_STATUS = '"+cStatus+"'"
	endif

	cQuery += " ORDER BY VFJ_CODIGO ASC"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T. )

	Do While !( cAlias )->( Eof() )
		oReport:SetMeter( (cAlias)->(RecCount()) )
		oSection1:Init()
		
		VFJ->(DBGOTO( ( cAlias )->VFJ_RECNO ))
		SB1->(DBGOTO( ( cAlias )->VFJ_RECNO ))
		VV1->(DBGOTO( ( cAlias )->VV1_RECNO ))

		if cOp == '1' .or. cOp == '3'
			VFN->( DBGOTO( (cAlias)->VFN_RECNO ) )
			nTotal += ((cAlias)->VFN_QUANT) * ((cAlias)->VFN_CUSUNI)
		endif

		if cOp == '2' .or. cOp == '3'
			VFQ->( DBGOTO( (cAlias)->VFQ_RECNO ) )
			nTotal += ((cAlias)->VFQ_QUANT) * ((cAlias)->VFQ_CUSUNI)
		endif
		
		oSection1:PrintLine()
		oReport:SkipLine()

		( cAlias )->(dbSkip())
	
	Enddo

	( cAlias )->(dbCloseArea())
	oSection1:Finish()
	oSection2:Init()
	TRCell():New(oSection2, "PreÁo Total" ,, "PreÁo Total", "@E 999,999.99",12,,{|| nTotal }, "CENTER")
	oSection2:PrintLine()
	oSection2:Finish()

Return

/* {Protheus.doc} fConvertData
Formata a string para DD/MM/AAAA
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25 */

Static function fConvertData(cData)

	Local cDataFormatada := ""

	cDataFormatada := SUBSTR(cData, 7, 2) + "/" +; //Dia
 					  SUBSTR(cData, 5, 2) + "/" +; //Mes
					  SUBSTR(cData, 1, 4) //Ano

Return cDataFormatada

/* {Protheus.doc} fParamBox
Executa e retorona os dados do Parambox
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25 */

Static Function fParamBox()

	Local cCodVV1 := Space(TamSx3('VV1_CHASSI')[1])
	
	Local aRet	   := {}
	local aCombo1  := {"1=Agrega","2=Desagrega","3=Ambos"}
	local aCombo2  := {"1=Veiculos/M·quinas","2=PeÁa"}
	local aCombo3  := {"0=Digitado","1=Efetivado","2=Cancelado","3=EfetivaÁ„o Pendente","4=Ambos"}
	local aPergs   := {}
	
	aAdd(aPergs, {1,'Chassi : ', cCodVV1, "", "",	"VV1", "", 100, .F.})

	aAdd(aPergs, {2,'Tipo : ',   "1", aCombo1, 100, "", .F.})
	aAdd(aPergs, {2,'Listar : ', "1", aCombo2, 100, "", .F.})
	aAdd(aPergs, {2,'Status : ', "0", aCombo3, 100, "", .F.})

	if !ParamBox(aPergs, "Informe os par‚metros",@aRet,,,,,,,,.t.,.t.)
		return .f.
	endif

Return aRet
