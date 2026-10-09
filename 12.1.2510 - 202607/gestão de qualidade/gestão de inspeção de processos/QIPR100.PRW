
#Include "QIPR100.ch"
#Include "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ QIPR100  ³ Autor ³ Leandro S. Sabino     ³ Data ³ 31/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Amarracao Produto X Cliente 	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs:      ³ (Versao Relatorio Personalizavel) 		                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR1001	                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function QIPR100()

	Local oReport

	Private __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
	Private cPerg      := "QPR100"
	Private lProduto   := .F.
	
			
	Pergunte(cPerg,.F.) 
	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef()   ³ Autor ³ Leandro Sabino   ³ Data ³ 31/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montar a secao				                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDef()				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QIPR100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local oReport                                             
Local oSection1 

oReport   := TReport():New("QIPR100",OemToAnsi(STR0003),"QPR100",{|oReport| PrintReport(oReport)},OemToAnsi(STR0001)+OemToAnsi(STR0002))
oReport:SetLandscape()
//"Amarracao Produto x Cliente"##"Serao relacionados os Clientes com seus "##"respectivos Produtos e ensaios associados."

oSection1 := TRSection():New(oReport,OemToAnsi(STR0007),{"QQ7"})//"Produto"
TRCell():New(oSection1,"QQ7_PRODUT","QQ7") 
TRCell():New(oSection1,"QQ7_CLIENT","QQ7") 
TRCell():New(oSection1,"QQ7_LOJA"  ,"QQ7") 

oSection2 := TRSection():New(oSection1,OemToAnsi(STR0008),{"QQ7"})//"Ensaio"
TRCell():New(oSection2,"QQ7_LABOR" ,"QQ7") 
TRCell():New(oSection2,"QQ7_ENSAIO","QQ7") 
TRCell():New(oSection2,"cDESCPO","   ",TitSX3("QP1_DESCPO")[1],"",TamSX3("QP1_DESCPO")[1])
TRCell():New(oSection2,"QQ7_CODREC","QQ7") 
TRCell():New(oSection2,"QQ7_OPERAC","QQ7") 

Return oReport

/*/{Protheus.doc} PrintReport
Imprimir os campos do relatorio
@type  Function
@author Leandro Sabino
@since 30/05/2006
@version 2.0
@param oReport, Objeto, Objeto TReport para impressao
/*/
Static Function PrintReport( oReport )

	Local aAreaFunc := GetArea()
	Local cAliasQRY  := ""
	Local cChave    := ""
	Local cProdut   := ""
	Local cProdAnt  := ""
	Local cRevi     := ""
	Local lProdOk   := .F.
	Local lItemOk   := .F.
	Local cDescPo   := ""
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(1):Section(1)

	MakeSqlExpr("QPR100")

	cAliasQRY := QIPRDADOS()

	If !Empty(cAliasQRY)
		(cAliasQRY)->(DbGoTop())
		While !(cAliasQRY)->(Eof())

			If cProdAnt <> (cAliasQRY)->QQ7_PRODUT
				cProdAnt := (cAliasQRY)->QQ7_PRODUT
				cProdut  := cProdAnt
				cRevi    := QA_UltRevEsp(cProdut, dDataBase,,,"QIP")
				lProdOk  := !Empty(AllTrim(cRevi))
			EndIf

			lItemOk := .F.
			If lProdOk
				If AllTrim((cAliasQRY)->QP7_REVI) == AllTrim(cRevi)
					lItemOk := .T.
				EndIf

				If AllTrim((cAliasQRY)->QP8_REVI) == AllTrim(cRevi)
					lItemOk := .T.
				EndIf
			EndIf

			If lItemOk
				If cChave <> (cAliasQRY)->QQ7_PRODUT + (cAliasQRY)->QQ7_CLIENT + (cAliasQRY)->QQ7_LOJA
					cChave := (cAliasQRY)->QQ7_PRODUT + (cAliasQRY)->QQ7_CLIENT + (cAliasQRY)->QQ7_LOJA
					oSection1:Finish()
					oSection2:Finish()
					oSection1:Init()
					oSection1:Cell("QQ7_PRODUT"):SetValue((cAliasQRY)->QQ7_PRODUT)
					oSection1:Cell("QQ7_CLIENT"):SetValue((cAliasQRY)->QQ7_CLIENT)
					oSection1:Cell("QQ7_LOJA"):SetValue((cAliasQRY)->QQ7_LOJA)
					oSection1:PrintLine()
					oSection2:Init()
				EndIf

				cDescPo := ""
				If !Empty(AllTrim((cAliasQRY)->QP1_DESCPO))
					cDescPo := (cAliasQRY)->QP1_DESCPO
				EndIf

				oSection2:Cell("QQ7_LABOR"):SetValue((cAliasQRY)->QQ7_LABOR)
				oSection2:Cell("QQ7_ENSAIO"):SetValue((cAliasQRY)->QQ7_ENSAIO)
				oSection2:Cell("QQ7_CODREC"):SetValue((cAliasQRY)->QQ7_CODREC)
				oSection2:Cell("QQ7_OPERAC"):SetValue((cAliasQRY)->QQ7_OPERAC)
				oSection2:Cell("cDESCPO"):SetValue(cDescPo)
				oSection2:PrintLine()
			EndIf

			(cAliasQRY)->(DbSkip())
		EndDo
		(cAliasQRY)->(DbCloseArea())
	EndIf

	RestArea(aAreaFunc)

Return	

/*/{Protheus.doc} QIPRDADOS
Retorna dados do relatorio para processamento unico.
@type  Function
@author Willian.Ramalho
@since 03/06/2026
@version 1.0
@return Character, alias da query
/*/
Static Function QIPRDADOS()

	Local aBindParam := {}
	Local cAlias     := ""
	Local cQuery     := ""

	cQuery += " SELECT "
	cQuery += " 	QQ7.QQ7_PRODUT, "
	cQuery += " 	QQ7.QQ7_CLIENT, "
	cQuery += " 	QQ7.QQ7_LOJA, "
	cQuery += " 	QQ7.QQ7_LABOR, "
	cQuery += " 	QQ7.QQ7_ENSAIO, "
	cQuery += " 	QQ7.QQ7_CODREC, "
	cQuery += " 	QQ7.QQ7_OPERAC, "
	cQuery += " 	QP1.QP1_DESCPO, "
	cQuery += " 	QP7.QP7_REVI, "
	cQuery += " 	QP8.QP8_REVI "
	cQuery += " FROM " + RetSqlName("QQ7") + " QQ7 "
	cQuery += " LEFT JOIN " + RetSqlName("QP1") + " QP1 "
	cQuery += " 	ON QP1.QP1_FILIAL = ? "
	cQuery += " 	AND QP1.QP1_ENSAIO = QQ7.QQ7_ENSAIO "
	cQuery += " 	AND QP1.D_E_L_E_T_ = ? "
	cQuery += " LEFT JOIN " + RetSqlName("QP7") + " QP7 "
	cQuery += " 	ON QP7.QP7_FILIAL = ? "
	cQuery += " 	AND QP7.QP7_PRODUT = QQ7.QQ7_PRODUT "
	cQuery += " 	AND QP7.QP7_LABOR  = QQ7.QQ7_LABOR "
	cQuery += " 	AND QP7.QP7_ENSAIO = QQ7.QQ7_ENSAIO "
	cQuery += " 	AND QP7.QP7_CODREC = QQ7.QQ7_CODREC "
	cQuery += " 	AND QP7.QP7_OPERAC = QQ7.QQ7_OPERAC "
	cQuery += " 	AND QP7.D_E_L_E_T_ = ? "
	cQuery += " LEFT JOIN " + RetSqlName("QP8") + " QP8 "
	cQuery += " 	ON QP8.QP8_FILIAL = ? "
	cQuery += " 	AND QP8.QP8_PRODUT = QQ7.QQ7_PRODUT "
	cQuery += " 	AND QP8.QP8_LABOR  = QQ7.QQ7_LABOR "
	cQuery += " 	AND QP8.QP8_ENSAIO = QQ7.QQ7_ENSAIO "
	cQuery += " 	AND QP8.QP8_CODREC = QQ7.QQ7_CODREC "
	cQuery += " 	AND QP8.QP8_OPERAC = QQ7.QQ7_OPERAC "
	cQuery += " 	AND QP8.D_E_L_E_T_ = ? "
	cQuery += " WHERE QQ7.QQ7_FILIAL = ? "
	cQuery += " 	AND QQ7.QQ7_PRODUT >= ? "
	cQuery += " 	AND QQ7.QQ7_PRODUT <= ? "
	cQuery += " 	AND QQ7.QQ7_CLIENT >= ? "
	cQuery += " 	AND QQ7.QQ7_CLIENT <= ? "
	cQuery += " 	AND QQ7.QQ7_LOJA   >= ? "
	cQuery += " 	AND QQ7.QQ7_LOJA   <= ? "
	cQuery += " 	AND QQ7.D_E_L_E_T_ = ? "
	cQuery += " ORDER BY QQ7.QQ7_PRODUT, QQ7.QQ7_CLIENT, QQ7.QQ7_LOJA, QQ7.QQ7_LABOR, QQ7.QQ7_ENSAIO "

	aAdd(aBindParam, {xFilial("QP1"), "S"})
	aAdd(aBindParam, {" ", "S"})
	aAdd(aBindParam, {xFilial("QP7"), "S"})
	aAdd(aBindParam, {" ", "S"})
	aAdd(aBindParam, {xFilial("QP8"), "S"})
	aAdd(aBindParam, {" ", "S"})
	aAdd(aBindParam, {xFilial("QQ7"), "S"})
	aAdd(aBindParam, {mv_par01, "S"})
	aAdd(aBindParam, {mv_par02, "S"})
	aAdd(aBindParam, {mv_par03, "S"})
	aAdd(aBindParam, {mv_par05, "S"})
	aAdd(aBindParam, {mv_par04, "S"})
	aAdd(aBindParam, {mv_par06, "S"})
	aAdd(aBindParam, {" ", "S"})

	cAlias := QLTQueryManager():executeQueryWithBind(cQuery, aBindParam, .T.)

Return cAlias

