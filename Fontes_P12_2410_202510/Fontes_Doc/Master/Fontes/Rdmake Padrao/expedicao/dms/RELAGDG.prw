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
	Local cTitulo  := "RelatÛrio Agrega/Desagrega"
	Local cNomRel  := "CÛdigo"
	Local cDesc    := "Ser· impresso as movimentaÁıes do chassi"

	oReport := RptDefRel(oReport,cTitulo,cNomRel,cDesc)
	oReport:nFontBody := 10
	oReport:oPage:nPaperSize := 9
	oReport:SetRightAlignPrinter(.T.)
	oReport:PrintDialog()

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

Static Function RptDefRel(oReport,cTitulo,cNomRel,cDesc)

	Local oSection1
 
	oReport := TReport():New(cNomRel,cTitulo,,{|oReport| RunRptRel(oReport)},cDesc)
 
	oReport:SetLineHeight(45)
 
	oSection1 := TRSection():New(oReport)
 
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

	Local oSection1 := oReport:Section(1)
	Local aParam := fParamBox()
	Local nLin      := 0260
	Local nCol      := 0060

	if ValType(aParam) <> "A"
		return .f.
	endif

	oSection1:Init()
	nLin := fImpMov(oReport,nLin,nCol,aParam)
	oSection1:Finish()
 
Return
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
Static Function fImpMov(oReport,nLin,nCol,aParam)

	Local nValTot := 0
	
	Local aQueryMov := fDadosAgrDes(aParam)

	Local cMV_PAR02 := AllTrim(cValtoChar(aParam[2]))
	Local cMV_PAR03 := AllTrim(cValtoChar(aParam[3]))

	Local oFont12b   := TFont():New("Courier New",9    ,12     ,.T.  ,.T.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )

	nLin+=0010
	oReport:SetRow(nLin)
	oReport:FatLine()
	nLin+=0010

	nLin+=0100
	oReport:Say(nLin,nCol+0001,"CÛdigo"					,oFont12b)
	oReport:Say(nLin,nCol+0250,"Data Movimen."			,oFont12b)
	oReport:Say(nLin,nCol+0550,"Movimen." 				,oFont12b)
	
	if cMV_PAR03 == "1" //Veiculos Maquinas
		oReport:Say(nLin,nCol+0850,"CÛdigo AMS"			,oFont12b)
		oReport:Say(nLin,nCol+1500,"Chassi AMS"			,oFont12b)
	Else // PeÁas
		oReport:Say(nLin,nCol+0750,"CÛdigo PeÁa"		,oFont12b)
		oReport:Say(nLin,nCol+1450,"DescriÁ„o PeÁa"		,oFont12b)
		oReport:Say(nLin,nCol+2100,Padl("Qtde",5)		,oFont12b)
	Endif

	oReport:Say(nLin,nCol+2200,Padl("Vlr. Uni",10)		,oFont12b)
	nLin+=0060

	if ValType(aQueryMov) == "A" .and. Len(aQueryMov) > 0
		aRet := fDadosMov(oReport,nLin,nCol,aQueryMov,nValTot,cMV_PAR03)
		nLin  := aRet[1]
		nValTot := aRet[2]
	Endif

	nLin+=0120
	oReport:Say(nLin,nCol+2000,Padl("Valor Total:",12), oFont12b)
	oReport:Say(nLin,nCol+2200,Padl(Transform(nValTot, "@E 999,999.99"),12),oFont12b)
	nLin+=0260

Return(nLin)

/*/{Protheus.doc} fDadosAgr
Query para montar o array com as movimentacoes do Agrega
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25
/*/
Static Function fDadosAgrDes(aParam)

	Local cMV_PAR01 := aParam[1]
	Local cMV_PAR02 := AllTrim(cValtoChar(aParam[2]))
	Local cMV_PAR03 := AllTrim(cValtoChar(aParam[3]))
	Local cChaint := ""

	Local cQuery := ""

	Local cAlias := "PECORC"

	Local nx := 0

	Local aDados := {}
	Local aDados0 := {}

	if !Empty(cMV_PAR01)
		cChaint := Posicione("VV1",2,xFilial("VV1")+cMV_PAR01, "VV1_CHAINT")
	Endif

	IF cMV_PAR03 = '1' //Veiculos/Maquinas
		cQuery := fQueryAMS(cMV_PAR02,cChaint)
	Else //PeÁas
		cQuery := fQueryPeca(cMV_PAR02,cChaint)
	Endif

	DBUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .F.)

	aQueryStruct := DBStruct()

		While (cAlias)->(!Eof())
			aDados0 := {}

			for nx := 1 to len(aQueryStruct)

				AAdd(aDados0, {aQueryStruct[nx][1], (cAlias)->&(aQueryStruct[nx][1])})

			Next

			AAdd(aDados,aDados0)

			(cAlias)->(DbSkip())

		End

	(cAlias)->(DbCloseArea())

Return aDados

/*/{Protheus.doc} fDadosMov
Query para montar o array com as movimentacoes do Agrega/Desagrega
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25
/*/

Static Function fDadosMov(oReport,nLin,nCol,aDados,nValTot,cMV_PAR03)

	Local nx	 	:= 0
	Local oFont		:= TFont():New("Courier New",9    ,12     ,.T.  ,.F.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )
	Local oFont12b   := TFont():New("Courier New",9    ,12     ,.T.  ,.T.  ,5    ,.T.  ,5    ,.T.  ,.F.       ,.F.    )
	Local nPosQua   := 0
	Local nLinCab      := 280
	
	cMaskQts	:= PesqPict("VFN","VFN_QUANT")
	cMaskVlu	:= PesqPict("VFN","VFN_CUSUNI")

	nPosCod := Ascan(aDados[1],{|x| x[1] == "CODEXE"})
	nPosDat := Ascan(aDados[1],{|x| x[1] == "VFJ_DATINC"})
	nPosTip := Ascan(aDados[1],{|x| x[1] == "AGRDES"})
	nPosInt := Ascan(aDados[1],{|x| x[1] == "CHAINT"})
	nPosCun := Ascan(aDados[1],{|x| x[1] == "CUSUNI"})
	if cMV_PAR03 == "1" //Veiculos Maquinas/AMS
		nPosIte := Ascan(aDados[1],{|x| x[1] == "CHAINTAMS"})
		nPosCha := Ascan(aDados[1],{|x| x[1] == "CHASSI"})
	Else // Pecas
		nPosIte := Ascan(aDados[1],{|x| x[1] == "CODSB1"})
		nPosDes := Ascan(aDados[1],{|x| x[1] == "DESCRI"})
		nPosQua := Ascan(aDados[1],{|x| x[1] == "QUANT" })
	Endif 

	For nx := 1 to Len(aDados)
		oReport:Say(nLinCab, nCol+0000,"Veiculo/M·quina: " + aDados[nx,nPosInt,2] ,oFont12b) //Chaint da movimentacao (Como Cabecalho das informacoes)

		nLin+= 0050

		oReport:Say(nLin, nCol+0001, aDados[nx,nPosCod,2], oFont) //CÛdigo
		oReport:Say(nLin, nCol+0250, fConvertData(aDados[nx,nPosDat,2]), oFont) //Data Movimen.

		oReport:Say(nLin, nCol+0550, aDados[nx,nPosTip,2], oFont) //MovimentaÁ„o

		if cMV_PAR03 == "1" //Veiculos Maquinas/AMS
			oReport:Say(nLin, nCol+0850, aDados[nx,nPosIte,2], oFont) //Chaint do AMS
			oReport:Say(nLin, nCol+1500, aDados[nx,nPosCha,2], oFont) //Chassi do AMS
		Else // Pecas
			oReport:Say(nLin, nCol+0750, aDados[nx,nPosIte,2], oFont) //Codigo do Item
			oReport:Say(nLin, nCol+1450, aDados[nx,nPosDes,2], oFont) //Descricao do Item
			oReport:Say(nLin, nCol+2100, PadL(AllTrim(Transform(aDados[nx,nPosQua,2],cMaskQts)),5), oFont) //Quantidade de item
			nValTot += aDados[nx,nPosQua,2] * aDados[nx,nPosCun,2] //Valor total baseado no valor do item com a quantidade da operaÁ„o
		Endif

		oReport:Say(nLin,nCol+2200, Padl(AllTrim(Transform(aDados[nx,nPosCun,2],cMaskVlu)),10), oFont) //Custo Unitario
		nLin+=0120
		nLinCab := nLin - 40

		oReport:SetRow(nLinCab - 10)
		oReport:FatLine()

		if cMV_PAR03 == "1" //Veiculos Maquinas/AMS
			nValTot += aDados[nx,nPosCun,2] //Incrementar os valores dos AMS
		EndiF 

	Next

Return {nLin, nValTot}

 /* {Protheus.doc} fQueryVFP
Retorna o resultado da query da Agrega AMS (Saida)
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25 */

Static Function fQueryAMS(cOp,cChaint)

	Local cQuery := ""

	If cOp == '1' .or. cOp == '3' // Agrega AMS ou Ambos
		cQuery += 	"SELECT"
		cQuery += 		" CASE"
		cQuery += 			" WHEN VFP.VFP_VEIMAQ = '1' THEN VFJ.VFJ_VV1001"
		cQuery +=			" ELSE VFJ.VFJ_VV1002"
		cQuery += 		" END AS CHAINT,"
		cQuery +=	" VFJ.VFJ_CODIGO,"
		cQuery +=	" VFP.VFP_CODIGO,"
		cQuery +=	" VFJ.VFJ_DATINC,"
		cQuery += 	" VFP.VFP_CODEXE AS CODEXE,"
		cQuery += 	" VFP.VFP_CHAINT AS CHAINTAMS,"
		cQuery += 	" VFP.VFP_CUSUNI AS CUSUNI,"
		cQuery += 		" 'AGREGA' AS AGRDES,"
		cQuery += 	" VV1.VV1_CHASSI AS CHASSI"
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

		if !Empty(cChaint)
			cQuery += "AND (CASE WHEN VFP.VFP_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END ) = '"+cChaint+"'"
		Endif

	Endif
	
	if cOp == '3'
		cQuery += "UNION ALL "
	Endif
		
	If cOp == '2' .or. cOp == '3' // Desagrega AMS ou Ambos
		cQuery += 	"SELECT"
		cQuery += 		" CASE"
		cQuery += 			" WHEN VFM.VFM_VEIMAQ = '1' THEN VFJ.VFJ_VV1001"
		cQuery +=			" ELSE VFJ.VFJ_VV1002"
		cQuery += 		" END AS CHAINT,"
		cQuery +=	" VFJ.VFJ_CODIGO,"
		cQuery +=	" VFM.VFM_CODIGO,"
		cQuery +=	" VFJ.VFJ_DATINC,"
		cQuery += 	" VFM.VFM_CODEXE AS CODEXE,"
		cQuery += 	" VFM.VFM_CHAINT AS CHAINTAMS,"
		cQuery += 	" VFM.VFM_CUSUNI AS CUSUNI,"
		cQuery += 		" 'Desagrega' AS AGRDES,"
		cQuery += 	" VV1.VV1_CHASSI AS CHASSI"
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

		if !Empty(cChaint)
			cQuery += "AND (CASE WHEN VFM.VFM_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END ) = '"+cChaint+"'"
		Endif
	Endif

	cQuery += " ORDER BY VFJ_CODIGO ASC"

Return cQuery

 /* {Protheus.doc} fQueryPeca
Retorna o resultado da query das movimentaÁıes de PeÁas
@type function
@version 1.0
@author Joao Victor Silva
@since 16/06/25 */

Static Function fQueryPeca(cOp,cChaint)

		Local cQuery := ""

	If cOp == '1' .or. cOp == '3' // Agrega PeÁas ou Ambos
		cQuery += 	"SELECT"
		cQuery += 		" CASE"
		cQuery += 			" WHEN VFN.VFN_VEIMAQ = '1' THEN VFJ.VFJ_VV1001"
		cQuery +=			" ELSE VFJ.VFJ_VV1002"
		cQuery += 		" END AS CHAINT,"
		cQuery +=	" VFJ.VFJ_CODIGO,"
		cQuery +=	" VFN.VFN_CODIGO,"
		cQuery +=	" VFJ.VFJ_DATINC,"
		cQuery += 	" VFN.VFN_CODEXE AS CODEXE,"
		cQuery += 	" VFN.VFN_CODSB1 AS CODSB1,"
		cQuery += 	" VFN.VFN_CUSUNI AS CUSUNI,"
		cQuery += 	" VFN.VFN_QUANT AS QUANT,"
		cQuery += 		" 'AGREGA' AS AGRDES,"
		cQuery += 	" SB1.B1_DESC AS DESCRI,"
		cQuery += 	" VV1.VV1_CHASSI"
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

		if !Empty(cChaint)
			cQuery += "AND (CASE WHEN VFN.VFN_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END ) = '"+cChaint+"'"
		Endif

	Endif
	
	if cOp == '3'
		cQuery += "UNION ALL "
	Endif
		
	If cOp == '2' .or. cOp == '3'// Desagrega de PeÁas ou Ambos
		cQuery += 	"SELECT"
		cQuery += 		" CASE"
		cQuery += 			" WHEN VFQ.VFQ_VEIMAQ = '1' THEN VFJ.VFJ_VV1001"
		cQuery +=			" ELSE VFJ.VFJ_VV1002"
		cQuery += 		" END AS CHAINT,"
		cQuery +=	" VFJ.VFJ_CODIGO,"
		cQuery +=	" VFQ.VFQ_CODIGO,"
		cQuery +=	" VFJ.VFJ_DATINC,"
		cQuery += 	" VFQ.VFQ_CODEXE AS CODEXE,"
		cQuery += 	" VFQ.VFQ_CODSB1 AS CODSB1,"
		cQuery += 	" VFQ.VFQ_CUSUNI AS CUSUNI,"
		cQuery += 	" VFQ.VFQ_QUANT AS QUANT,"
		cQuery += 		" 'Desagrega' AS AGRDES,"
		cQuery += 	" SB1.B1_DESC AS DESCRI,"
		cQuery += 	" VV1.VV1_CHASSI"
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

		if !Empty(cChaint)
			cQuery += "AND (CASE WHEN VFQ.VFQ_VEIMAQ = '1' THEN VFJ.VFJ_VV1001 ELSE VFJ.VFJ_VV1002 END ) = '"+cChaint+"'"
		Endif

	Endif

	cQuery += " ORDER BY VFJ_CODIGO ASC"

Return cQuery

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
	local aPergs   := {}
	
	aAdd(aPergs, {1,'Chassi : ', cCodVV1, "", "",	"VV1", "", 100, .F.})

	aAdd(aPergs, {2,'Tipo : ',   1, aCombo1, 100, "", .F.})
	aAdd(aPergs, {2,'Listar : ', 1, aCombo2, 100, "", .F.})

	if !ParamBox(aPergs, "Informe os par‚metros",@aRet,,,,,,,,.t.,.t.)
		return .f.
	endif

Return aRet
