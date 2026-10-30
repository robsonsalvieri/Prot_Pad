#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR810.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR810()
Lista os manifestos de encomendas 
@sample GTPR810()
@author Flavio Martins
@since 22/12/2022
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR810()
Local oReport
Local cPerg  := ''
Local nOpc   := 0

nOpc := Aviso(STR0001, STR0002, {STR0003, STR0004, STR0005}, 2) // "Impressão", "Selecione a opção de impressão do manifesto" {"Posicionado", "Selecionar","Cancelar"}

If nOpc == 2
	cPerg := 'GTPR810'
	Pergunte(cPerg, .T.)
Endif

If nOpc < 3
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Lista os manifestos de encomendas
@sample ReportDef(cPerg)
@param cPerg - caracter - Nome da Pergunta
@return oReport - Objeto - Objeto TREPORT
@author Flavio Martins 
@since 22/12/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)

Local cTitle    := STR0006 // "Relatório de Manifestos de Encomendas"
Local cHelp     := STR0007 // "Gera o relatório de manifestos de encomendas"
Local cAliasQry := GetNextAlias()
Local oReport
Local oSection1

oReport := TReport():New('GTPR810',cTitle,cPerg,{|oReport|ReportPrint(oReport,cAliasQry, cPerg)},cHelp,/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/)
oReport:SetLandscape(.T.)
oReport:nFontBody := 5
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport,cTitle,cAliasQry)
oSection1:SetTotalInLine(.F.)

TRCell():New(oSection1,"G99_CODIGO"	 , cAliasQry, STR0008, /*Picture*/, TamSX3("G99_CODIGO")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.F.) 												// "Código CTe"
TRCell():New(oSection1,"G99_TOMADO"	 , cAliasQry, STR0009, /*Picture*/, 12 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.F.) 																	// "Tomador"
TRCell():New(oSection1,"AGE_EMI" 	 , cAliasQry, STR0010, /*Picture*/, TamSx3('G99_CODEMI')[1]+TamSx3('GI6_DESCRI')[1]+3 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.F.) 						// "Agência Emissora"
TRCell():New(oSection1,"AGE_REC"     , cAliasQry, STR0011, /*Picture*/, TamSx3('G99_CODEMI')[1]+TamSx3('GI6_DESCRI')[1]+3/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.F.) 						// "Agência Recebedora"
TRCell():New(oSection1,"G99_QTDVO"	 , cAliasQry, STR0012, /*Picture*/, TamSX3("G99_QTDVO")[1]+TamSX3("A1_NOME")[1]+3 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.F.) 							// "Qtd. Vol."
TRCell():New(oSection1,"G99_VALOR"	 , cAliasQry, STR0013, /*Picture*/, TamSX3("G99_VALOR")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.F.) 												// "Vlr. Serviço"
TRCell():New(oSection1,"G9R_VALOR"	 , cAliasQry, STR0014, /*Picture*/, TamSX3("G9R_VALOR")[1] /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.F.) 												// "Vlr. Declarado"
TRCell():New(oSection1,"REMETENTE"	 , cAliasQry, STR0015, /*Picture*/, TamSX3("G99_CLIREM")[1]+TamSX3("A1_NOME")[1]+TamSX3("A1_LOJA")[1]+3 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.T.)	// "Remetente"
TRCell():New(oSection1,"DESTINATARIO", cAliasQry, STR0016, /*Picture*/, TamSX3("G99_CLIDES")[1]+TamSX3("A1_NOME")[1]+TamSX3("A1_LOJA")[1]+3 /*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/,,,,,,.T.) 	// "Destinatário"

oSection1:Cell("G99_CODIGO"):lHeaderSize 	:= .F.
oSection1:Cell("G99_TOMADO"):lHeaderSize 	:= .F.
oSection1:Cell("AGE_EMI"):lHeaderSize 		:= .F.
oSection1:Cell("AGE_REC"):lHeaderSize 		:= .F.
oSection1:Cell("REMETENTE"):lHeaderSize 	:= .F.
oSection1:Cell("DESTINATARIO"):lHeaderSize 	:= .F.
oSection1:Cell("G9R_VALOR"):lHeaderSize 	:= .F.
oSection1:Cell("G99_VALOR"):lHeaderSize 	:= .F.
oSection1:Cell("G99_QTDVO"):lHeaderSize 	:= .F.

oSection1:SetColSpace(1,.F.)
oSection1:SetAutoSize(.F.)
oSection1:SetLineBreak(.F.)

TRFunction():New(oSection1:Cell("G99_QTDVO"),NIL,"SUM",,,/*cPicture*/,,,,,,/*{|| }*/)
TRFunction():New(oSection1:Cell("G99_VALOR"),NIL,"SUM",,,"@E 9,999,999.99",,,,,,/*{|| }*/)
TRFunction():New(oSection1:Cell("G9R_VALOR"),NIL,"SUM",,,"@E 9,999,999.99",,,,,,/*{|| }*/)


Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
@sample ReportPrint(oReport, cAliasQry)
@param oReport - Objeto - Objeto TREPORT
@author Flavio Martins 
@since 22/12/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry,cPerg)
Local oSection1 := oReport:Section(1)
Local cCodGI9   := ""
Local cQuery	:= ''

oSection1:SetTotalText(STR0017) // "Totais do Manifesto"

If Empty(cPerg)
	cQuery := "% AND GI9.GI9_CODIGO = '" + GI9->GI9_CODIGO + "' %"
Else
	cQuery := "% AND GI9.GI9_CODIGO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"  
	cQuery += " AND GI9.GI9_EMISSA BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) + "'"
	cQuery += " AND GI9.GI9_VIAGEM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' %"
Endif

oSection1:BeginQuery()

BeginSql Alias cAliasQry

	SELECT GI9.GI9_CODIGO,
		   GI9.GI9_EMISSA,	
		   GI9.GI9_VIAGEM,
	       GI9.GI9_CODEMI,
	       GI9.GI9_CODREC,
		   G99.G99_CODIGO,
		   G99.G99_CODEMI,
		   G99.G99_CODREC,
	       G99.G99_CLIREM,
		   G99.G99_LOJREM,
	       G99.G99_CLIDES,
		   G99.G99_LOJDES,
	       G99.G99_QTDVO,
		   G99.G99_TOMADO,
		   G99.G99_VALOR,
	       SA1REM.A1_NOME AS NOME_REM,
	       SA1DES.A1_NOME AS NOME_DES,
	       SUM(G9R.G9R_VALOR) AS G9R_VALOR
	FROM %Table:GI9% GI9
	INNER JOIN %Table:GIF% GIF ON GIF.GIF_FILIAL = %xFilial:GIF%
	AND GIF.GIF_CODIGO = GI9.GI9_CODIGO
	AND GIF.%NotDel%
	INNER JOIN %Table:G99% G99 ON G99.G99_FILIAL = %xFilial:G99%
	AND G99.G99_CODIGO = GIF.GIF_CODG99
	AND G99.%NotDel%
	INNER JOIN %Table:SA1% SA1REM ON SA1REM.A1_FILIAL = %xFilial:SA1%
	AND SA1REM.A1_COD = G99.G99_CLIREM
	AND SA1REM.A1_LOJA = G99.G99_LOJREM
	AND SA1REM.%NotDel%
	INNER JOIN %Table:SA1% SA1DES ON SA1DES.A1_FILIAL = %xFilial:SA1%
	AND SA1DES.A1_COD = G99.G99_CLIDES
	AND SA1DES.A1_LOJA = G99.G99_LOJDES
	AND SA1DES.%NotDel%
	INNER JOIN %Table:G9R% G9R ON G9R.G9R_FILIAL = %xFilial:G9R%
	AND G9R.G9R_CODIGO = G99.G99_CODIGO
	AND G9R.%NotDel%
	WHERE GI9.GI9_FILIAL = GI9_FILIAL
	  %Exp:cQuery%
	  AND GI9.%NotDel%
	GROUP BY GI9.GI9_CODIGO,
		   	 GI9.GI9_EMISSA,	
		   	 GI9.GI9_VIAGEM,
	      	 GI9.GI9_CODEMI,
	       	 GI9.GI9_CODREC,
		     G99.G99_CODIGO,
		     G99.G99_CODEMI,
		     G99.G99_CODREC,
	         G99.G99_CLIREM,
			 G99.G99_LOJREM,
	         G99.G99_CLIDES,
			 G99.G99_LOJDES,
	         G99.G99_QTDVO,
		     G99.G99_TOMADO,
		     G99.G99_VALOR,
	         SA1REM.A1_NOME,
	         SA1DES.A1_NOME
	ORDER BY GI9.GI9_CODIGO
	
EndSql 

oSection1:EndQuery()

oReport:SetMeter((cAliasQry)->(RecCount()))

While !oReport:Cancel() .And. (cAliasQry)->(!Eof())	

	If cCodGI9 != (cAliasQry)->GI9_CODIGO
		
		If !Empty(cCodGI9)
			oReport:SkipLine(1)
			oSection1:Finish()
			oReport:EndPage()
			oReport:StartPage()
		Endif
		
		oReport:StartPage()
		oReport:PrtLeft(STR0018 + (cAliasQry)->GI9_CODIGO) // "Cód. do Manifesto : "
		oReport:SkipLine(1)
		oReport:PrtLeft(STR0019 + DtoC((cAliasQry)->GI9_EMISSA)) // "Data de Emissão   : "
		oReport:SkipLine(1)
		oReport:PrtLeft(STR0020 + (cAliasQry)->GI9_CODEMI + ' - ' + Posicione("GI6", 1, xFilial("GI6") + (cAliasQry)->GI9_CODEMI, "GI6_DESCRI")) // "Agência Emissora  : "
		oReport:SkipLine(1)
		oReport:PrtLeft(STR0021 + (cAliasQry)->GI9_CODREC + ' - ' + Posicione("GI6", 1, xFilial("GI6") + (cAliasQry)->GI9_CODREC, "GI6_DESCRI")) // "Agência Recebedora: "
		oReport:SkipLine(1)
		oReport:PrtLeft(STR0022 + (cAliasQry)->GI9_VIAGEM) // "Código da Viagem  : "
		oReport:SkipLine(2)
		oReport:PrintText(STR0023) // "Lista de CTe's do Manifesto"
		oReport:SkipLine(1)

		cCodGI9 := (cAliasQry)->GI9_CODIGO

	Endif

	oSection1:Init()
	oSection1:Cell("AGE_EMI"):SetValue((cAliasQry)->G99_CODEMI + ' - ' + Posicione("GI6", 1, xFilial("GI6") + (cAliasQry)->G99_CODEMI, "GI6_DESCRI"))
	oSection1:Cell("AGE_REC"):SetValue((cAliasQry)->G99_CODREC + ' - ' + Posicione("GI6", 1, xFilial("GI6") + (cAliasQry)->G99_CODREC, "GI6_DESCRI"))
	oSection1:Cell("REMETENTE"):SetValue((cAliasQry)->G99_CLIREM + '/' + (cAliasQry)->G99_LOJREM + ' - ' + (cAliasQry)->NOME_REM)
	oSection1:Cell("DESTINATARIO"):SetValue((cAliasQry)->G99_CLIDES + '/' + (cAliasQry)->G99_LOJDES + ' - ' + (cAliasQry)->NOME_DES)

	oSection1:PrintLine()
	
	(cAliasQry)->(dbSkip())  
	
End

oReport:SkipLine(1)
oSection1:Finish()

Return
