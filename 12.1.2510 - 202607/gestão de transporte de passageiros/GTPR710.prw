#INCLUDE "TOTVS.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "GTPR710.CH"
#INCLUDE "FWPrintSetup.ch"
/*/{Protheus.doc} GTPR710
	Relatorio de Regras Produto x Tipo de Bilhete
	@type function
	@author  GTP | pedro.saboia
	@since 31/03/2026
	@obs pergunte GTPR710

	MV_PAR01    --> GIC_DTVEND  --> Data de  :
	MV_PAR02    --> GIC_DTVEND  --> Data ate :
	MV_PAR03    --> GIC_AGENCI  --> Agencia de :
	MV_PAR04    --> GIC_AGENCI  --> Agencia ate :
	MV_PAR05    --> GIC_BILHET  --> Bilhete de :
	MV_PAR06    --> GIC_BILHET  --> Bilhete Ate :
	MV_PAR07    --> ??????????  --> Esta configurado ? : | A=Ambos | C=Configurado | N=Nao Configurado |
/*/
Function GTPR710()
	Local cPerg   := 'GTPR710' as character
	Local oReport := Nil       as object

	If Pergunte(cPerg, .T.)
		oReport := ReportDef(cPerg)
		oReport:PrintDialog()
	EndIf

Return()
/*/{Protheus.doc} ReportDef
	Define a estrutura do relatorio (secoes e celulas).
	Segue o mesmo padrao do RELSC7: dois aliases distintos,
	oSection1 para cabecalho de agencia, oSection2 para detalhe do bilhete.
	@type function Static
	@author GTP | pedro.saboia
	@since 31/03/2026
	@param cPerg, character, pergunta para filtro de execucao
/*/
Static Function ReportDef(cPerg)
	Local cAliasAge := GetNextAlias() as character  // alias para query de agencias (oSection1)
	Local cAliasQry := GetNextAlias() as character  // alias para query de bilhetes (oSection2)
	Local cHelp     := ""             as character
	Local cTitle    := ""             as character
	Local oReport   := Nil            as object
	Local oSection1 := Nil            as object
	Local oSection2 := Nil            as object
	Default cPerg   := "GTPR710"

	cHelp  := STR0001 //'Produto x Tipo de Bilhete'
	cTitle := STR0001 //'Produto x Tipo de Bilhete'

	// Ambos os aliases passados para ReportPrint via closure -- padrao RELSC7
	oReport := TReport():New('GTPR710', cTitle, cPerg, {|oRpt| ReportPrint(oRpt, cAliasAge, cAliasQry)}, cHelp , /*lLandscape*/ , /*uTotalText*/ , .T./*lTotalInLine*/ , /*cPageTText*/ , /*lPageTInLine*/ , /*lTPageBreak*/ , /*nColSpace*/ ) 
	oReport:SetLandscape(.T.)

	// oSection1: cabecalho de agencia
	// SetNoFilter em todas as tabelas para o TReport nao tentar filtrar automaticamente
	oSection1 := TRSection():New(oReport, "Agencia", {"GIC", "GI6"})
	oSection1:SetNoFilter("GIC")
	oSection1:SetNoFilter("GI6")
	oSection1:SetHeaderSection(.F.)
	TRCell():New(oSection1, "CABECALHO", cAliasAge, ,, 200)

	// oSection2: linha de detalhe do bilhete
	oSection2 := TRSection():New(oReport, "Bilhete", {"GIC", "GI1", "GI2", "G9O", "H60", "H87", "GI6"})
	oSection2:SetNoFilter("GIC")
	oSection2:SetNoFilter("GI1")
	oSection2:SetNoFilter("GI2")
	oSection2:SetNoFilter("G9O")
	oSection2:SetNoFilter("H60")
	oSection2:SetNoFilter("H87")
	oSection2:SetNoFilter("GI6")
	oSection2:SetTotalInLine(.F.)

	TRCell():New(oSection2, "GIC_CODIGO", cAliasQry, STR0002 ,/*Picture*/, 031,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Codigo'
	TRCell():New(oSection2, "GIC_BILHET", cAliasQry, STR0003 ,/*Picture*/, 060,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .F./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Num. do Bilhete'
	TRCell():New(oSection2, "GIC_TIPO",   cAliasQry, STR0004 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Tp. Bilhete'
	TRCell():New(oSection2, "GIC_LINHA",  cAliasQry, STR0005 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Num. Linha'
	TRCell():New(oSection2, "GIC_LOCORI", cAliasQry, STR0006 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Cod. Origem'
	TRCell():New(oSection2, "GIC_LOCDES", cAliasQry, STR0007 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Cod. Destino'
	TRCell():New(oSection2, "UFORI",      cAliasQry, STR0008 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'UF Origem'
	TRCell():New(oSection2, "DSMUNIORI",  cAliasQry, STR0009 ,/*Picture*/, 100,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Municipio Ori.'
	TRCell():New(oSection2, "UFDES",      cAliasQry, STR0010 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'UF Destino'
	TRCell():New(oSection2, "DSMUNIDES",  cAliasQry, STR0011 ,/*Picture*/, 050,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Municipio Des.'
	TRCell():New(oSection2, "G9O_CODIGO", cAliasQry, STR0012 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Cod. Prod.'
	TRCell():New(oSection2, "H60_PRDTAR", cAliasQry, STR0013 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Prod. Tarifa'
	TRCell():New(oSection2, "H60_PRDTAX", cAliasQry, STR0014 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Prod. Taxa'
	TRCell():New(oSection2, "H60_PRDPED", cAliasQry, STR0015 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Prod. Pedagio'
	TRCell():New(oSection2, "H60_PRDGRT", cAliasQry, STR0016 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Prod. Gratui.'
	TRCell():New(oSection2, "H60_PRDSEG", cAliasQry, STR0017 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Prod. Seguro'
	TRCell():New(oSection2, "H60_PRDOUT", cAliasQry, STR0018 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Sentido'
	TRCell():New(oSection2, "GIC_CODG9B", cAliasQry, STR0019 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Categ. Bil.'
	TRCell():New(oSection2, "GIC_STATUS", cAliasQry, STR0020 ,/*Picture*/, 036,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , /*lBold*/ )  //'Status Bil.'
	TRCell():New(oSection2, "REGRA",      cAliasQry, STR0021 ,/*Picture*/, 220,.F./*lPixel*/, /*bBlock*/ , "RIGHT"/*cAlign*/ , .T./*lLineBreak*/ , "RIGHT"/*cHeaderAlign*/ , /*lCellBreak*/ , /*nColSpace*/ , .T./*lAutoSize*/ , /*nClrBack*/ , /*nClrFore*/ , .T./*lBold*/ ) //'Regra do Bilhete'

Return oReport
/*/{Protheus.doc} ReportPrint
	Monta as queries, itera por agencia (oSection1) e por bilhete (oSection2).
	Padrao identico ao RELSC7: loop externo por agencia com query propria,
	loop interno por bilhete com query propria aberta/fechada a cada agencia.
	@type function Static
	@author GTP | pedro.saboia
	@since 31/03/2026
	@param oReport,   object,    objeto TReport
	@param cAliasAge, character, alias da query de agencias (oSection1)
	@param cAliasQry, character, alias da query de bilhetes (oSection2)
/*/
Static Function ReportPrint(oReport, cAliasAge, cAliasQry)
	Local cAgeAtual    := ""   as character  // agencia corrente no loop externo
	Local cAteAgencia  := ""   as character
	Local cAteBilhete  := ""   as character
	Local cAteDataFim  := ""   as character
	Local cCodG9O      := ""   as character
	Local cDeAgencia   := ""   as character
	Local cDeBilhete   := ""   as character
	Local cDeDataIni   := ""   as character
	Local cG9OGQCCOD   := ""   as character
	Local cQryG90      := ""   as character
	Local cRegra       := ""   as character
	Local cQryCond     := ""   as character
	Local nConfigurado := 0    as numeric
	Local oSection1    := nil  as object
	Local oSection2    := nil  as object
	Default oReport    := nil
	Default cAliasAge  := ""
	Default cAliasQry  := ""

	// Parametros
	cDeDataIni   := DTOS(MV_PAR01)
	cAteDataFim  := DTOS(MV_PAR02)
	cDeAgencia   := MV_PAR03
	cAteAgencia  := MV_PAR04
	cDeBilhete   := MV_PAR05
	cAteBilhete  := MV_PAR06
	nConfigurado := MV_PAR07   // 1=AMBOS 2=CONFIGURADO 3=NAO CONFIGURADO
	cG9OGQCCOD := Space(TamSx3('G9O_GQCCOD')[1])

	If Empty(cDeDataIni)  ; cDeDataIni  := DTOS(dDataBase)                        ; EndIf
	If Empty(cAteDataFim) ; cAteDataFim := DTOS(dDataBase)                        ; EndIf
	If Empty(cDeAgencia)  ; cDeAgencia  := Space(TamSx3("GIC_AGENCI")[1])         ; EndIf
	If Empty(cAteAgencia) ; cAteAgencia := Replicate("Z",TamSx3("GIC_AGENCI")[1]) ; EndIf
	If Empty(cDeBilhete)  ; cDeBilhete  := Space(TamSx3("GIC_BILHET")[1])         ; EndIf
	If Empty(cAteBilhete) ; cAteBilhete := Replicate("Z",TamSx3("GIC_BILHET")[1]) ; EndIf

	// Abertura garantida das tabelas usadas nos seeks de RegRel/AplicaRegra
	dbSelectArea("GIC") ; dbSetOrder(1)
	dbSelectArea("G9O") ; dbSetOrder(2) //G9O_FILIAL+G9O_ORIGEM+G9O_TIPO+G9O_STATUS+G9O_GQCCOD+G9O_CODIGO
	dbSelectArea("GI2") ; dbSetOrder(1) //GI2_FILIAL+GI2_COD+GI2_VIA
	dbSelectArea("GQC") ; dbSetOrder(1) //GQC_FILIAL+GQC_CODIGO
	dbSelectArea("GZW") ; dbSetOrder(1) //GZW_FILIAL+GZW_CODGQC+GZW_EST
	dbSelectArea("H60") ; dbSetOrder(1) //H60_FILIAL+H60_CODG9O+H60_UF
	dbSelectArea("H87") ; dbSetOrder(1) //H87_FILIAL+H87_CODG9O+H87_LOCORI+H87_LOCDES

	oSection1 := oReport:Section(1)
	oSection2 := oReport:Section(2)

	// Filtro CONFIGURADO/NAO CONFIGURADO aplicado em AdvPL apos a query
	If nConfigurado == 2
		cQryCond := "% AND ISNULL(G9O.G9O_CODIGO,'') > '' %"
	ElseIf nConfigurado == 3
		cQryCond := "% AND ISNULL(G9O.G9O_CODIGO,'') = '' %"
	Else
		cQryCond := "% %"
	EndIf

	cQryG90 := "% AND ( "
	cQryG90 += " G.G9O_GQCCOD = GI2.GI2_TIPLIN "
	cQryG90 += " OR LTRIM(RTRIM(ISNULL(G.G9O_GQCCOD,''))) = '' "
	cQryG90 += " ) %"

	oSection1:BeginQuery()

	BeginSql Alias cAliasAge

		SELECT DISTINCT
			GIC.GIC_AGENCI,
			GI6.GI6_DESCRI

		FROM %Table:GIC% GIC

			INNER JOIN %Table:GI6% GI6
				ON  GI6.GI6_FILIAL = %xFilial:GI6%
				AND GI6.GI6_CODIGO = GIC.GIC_AGENCI
				AND GI6.%NotDel%

		WHERE GIC.%NotDel%
			AND GIC.GIC_FILIAL  = %xFilial:GIC%
			AND GIC.GIC_DTVEND  BETWEEN %Exp:cDeDataIni%  AND %Exp:cAteDataFim%
			AND GIC.GIC_AGENCI  BETWEEN %Exp:cDeAgencia%  AND %Exp:cAteAgencia%
			AND GIC.GIC_BILHET  BETWEEN %Exp:cDeBilhete%  AND %Exp:cAteBilhete%
			AND GIC.GIC_NUMPRO  > '000000000000000'
			AND GIC.GIC_CHVBPE  > ' '
			AND (
					GIC.GIC_STATUS IN ('V','D','T')
				OR (GIC.GIC_STATUS = 'E' AND GIC.GIC_VENDRJ = 'IVP')
				)

		ORDER BY GIC.GIC_AGENCI

	EndSql

	oSection1:EndQuery()

	// -------------------------------------------------------
	// LOOP EXTERNO: uma iteracao por agencia -- padrao RELSC7
	// -------------------------------------------------------
	(cAliasAge)->(dbGoTop())

	While !oReport:Cancel() .And. (cAliasAge)->(!Eof())

		cAgeAtual := (cAliasAge)->(GIC_AGENCI)

		// Imprime cabecalho da agencia
		oSection1:Init()
		oSection1:Cell("CABECALHO"):SetValue(STR0026 + cAgeAtual + ' ' + AllTrim((cAliasAge)->(GI6_DESCRI)))
		oSection1:PrintLine()

		// -------------------------------------------------------
		// QUERY INTERNA: bilhetes da agencia corrente
		// Aberta dentro do loop, fechada com dbCloseArea() -- padrao RELSC7
		// -------------------------------------------------------
		oSection2:BeginQuery()

		BeginSql Alias cAliasQry

			SELECT DISTINCT
				GIC.GIC_CODIGO,
				GIC.GIC_BILHET,
				GIC.GIC_STATUS,
				GIC.GIC_TIPO,
				GIC.GIC_LINHA,
				GIC.GIC_ORIGEM,
				GIC.GIC_LOCORI,
				GIC.GIC_LOCDES,
				GIC.GIC_CODG9B,
				GIC.GIC_AGENCI,

				GI6.GI6_DESCRI,

				GI2.GI2_TIPLIN,

				G9O.G9O_CODIGO,
				G9O.G9O_PRDTAR,
				G9O.G9O_PRDTAX,
				G9O.G9O_PRDPED,
				G9O.G9O_PRDSEG,
				G9O.G9O_PRDOUT,

				H60.H60_PRDTAR,
				H60.H60_PRDTAX,
				H60.H60_PRDPED,
				H60.H60_PRDGRT,
				H60.H60_GERFIS,
				H60.H60_CODG9O,
				H60.H60_PRDSEG,
				H60.H60_PRDOUT,

				H87.H87_PRDTAR,
				H87.H87_PRDTAX,
				H87.H87_PRDPED,
				H87.H87_PRDSEG,
				H87.H87_PRDOUT,
				H87.H87_CODG9O,
				H87.H87_LOCORI,
				H87.H87_LOCDES,

				GI1ORI.GI1_UF     AS UFORI,
				GI1ORI.GI1_DESCRI AS DSMUNIORI,

				GI1DES.GI1_UF     AS UFDES,
				GI1DES.GI1_DESCRI AS DSMUNIDES,

				CASE WHEN G9O.G9O_CODIGO IS NULL THEN 'N' ELSE 'S' END AS CONFIGURADO

			FROM %Table:GIC% GIC

				INNER JOIN %Table:GI1% GI1ORI
					ON  GI1ORI.GI1_FILIAL = %xFilial:GI1%
					AND GI1ORI.GI1_COD    = GIC.GIC_LOCORI
					AND GI1ORI.%NotDel%

				INNER JOIN %Table:GI1% GI1DES
					ON  GI1DES.GI1_FILIAL = %xFilial:GI1%
					AND GI1DES.GI1_COD    = GIC.GIC_LOCDES
					AND GI1DES.%NotDel%

				LEFT JOIN %Table:GI2% GI2
					ON  GI2.GI2_FILIAL = GIC.GIC_FILIAL
					AND GI2.GI2_COD    = GIC.GIC_LINHA
					AND GI2.%NotDel%
					OUTER APPLY (
						SELECT TOP 1
							G.G9O_FILIAL,
							G.G9O_CODIGO,
							G.G9O_PRDTAR,
							G.G9O_PRDTAX,
							G.G9O_PRDPED,
							G.G9O_PRDSEG,
							G.G9O_PRDOUT,
							G.G9O_GQCCOD
						FROM %Table:G9O% G
						WHERE G.G9O_FILIAL  = GIC.GIC_FILIAL
						AND G.G9O_ORIGEM = GIC.GIC_ORIGEM
						AND G.G9O_TIPO   = GIC.GIC_TIPO
						AND G.G9O_STATUS = GIC.GIC_STATUS
						%Exp:cQryG90%
						AND G.%NotDel%
						ORDER BY
						CASE
							WHEN G.G9O_GQCCOD = GI2.GI2_TIPLIN THEN 0
							ELSE 1
						END
					) G9O
				LEFT JOIN %Table:H60% H60
					ON  H60.H60_FILIAL  = G9O.G9O_FILIAL
					AND H60.H60_CODG9O  = G9O.G9O_CODIGO
					AND H60.H60_UF      = GI1ORI.GI1_UF
					AND H60.%NotDel%

				LEFT JOIN %Table:H87% H87
					ON  H87.H87_FILIAL  = G9O.G9O_FILIAL
					AND H87.H87_CODG9O  = G9O.G9O_CODIGO
					AND H87.H87_LOCORI  = GIC.GIC_LOCORI
					AND H87.H87_LOCDES  = GIC.GIC_LOCDES
					AND H87.%NotDel%

				INNER JOIN %Table:GI6% GI6
					ON  GI6.GI6_FILIAL  = %xFilial:GI6%
					AND GI6.GI6_CODIGO  = GIC.GIC_AGENCI
					AND GI6.%NotDel%

			WHERE GIC.%NotDel%
				AND GIC.GIC_FILIAL  = %xFilial:GIC%
				AND GIC.GIC_DTVEND  BETWEEN %Exp:cDeDataIni%  AND %Exp:cAteDataFim%
				AND GIC.GIC_AGENCI  = %Exp:cAgeAtual%
				AND GIC.GIC_BILHET  BETWEEN %Exp:cDeBilhete%  AND %Exp:cAteBilhete%
				AND GIC.GIC_NUMPRO  > '000000000000000'
				AND GIC.GIC_CHVBPE  > ' '
				%Exp:cQryCond%
				AND (
						GIC.GIC_STATUS IN ('V','D','T')
					OR (GIC.GIC_STATUS = 'E' AND GIC.GIC_VENDRJ = 'IVP')
					)

			ORDER BY GIC.GIC_CODIGO

		EndSql
		
		oSection2:EndQuery()

		// -------------------------------------------------------
		// LOOP INTERNO: bilhetes -- padrao RELSC7
		// dbGoTop() + While + Init + SetValue(todos) + PrintLine + dbSkip()
		// -------------------------------------------------------
		(cAliasQry)->(dbGoTop())

		oReport:StartPage()	
		oReport:SkipLine()

		While !oReport:Cancel() .And. (cAliasQry)->(!Eof())

			cCodG9O := AllTrim((cAliasQry)->(G9O_CODIGO))
			cRegra  := RegRel(cAliasQry)

			oSection2:Init()
			oSection2:Cell("GIC_CODIGO"):SetValue( (cAliasQry)->(GIC_CODIGO) )
			oSection2:Cell("GIC_BILHET"):SetValue( (cAliasQry)->(GIC_BILHET) )
			oSection2:Cell("GIC_TIPO")  :SetValue( (cAliasQry)->(GIC_TIPO)   )
			oSection2:Cell("GIC_LINHA") :SetValue( (cAliasQry)->(GIC_LINHA)  )
			oSection2:Cell("GIC_LOCORI"):SetValue( (cAliasQry)->(GIC_LOCORI) )
			oSection2:Cell("GIC_LOCDES"):SetValue( (cAliasQry)->(GIC_LOCDES) )
			oSection2:Cell("UFORI")     :SetValue( (cAliasQry)->(UFORI)      )
			oSection2:Cell("DSMUNIORI") :SetValue( (cAliasQry)->(DSMUNIORI)  )
			oSection2:Cell("UFDES")     :SetValue( (cAliasQry)->(UFDES)      )
			oSection2:Cell("DSMUNIDES") :SetValue( (cAliasQry)->(DSMUNIDES)  )
			oSection2:Cell("G9O_CODIGO"):SetValue( (cAliasQry)->(G9O_CODIGO) )
			oSection2:Cell("H60_PRDTAR"):SetValue( (cAliasQry)->(H60_PRDTAR) )
			oSection2:Cell("H60_PRDTAX"):SetValue( (cAliasQry)->(H60_PRDTAX) )
			oSection2:Cell("H60_PRDPED"):SetValue( (cAliasQry)->(H60_PRDPED) )
			oSection2:Cell("H60_PRDGRT"):SetValue( (cAliasQry)->(H60_PRDGRT) )
			oSection2:Cell("H60_PRDSEG"):SetValue( (cAliasQry)->(H60_PRDSEG) )
			oSection2:Cell("H60_PRDOUT"):SetValue( (cAliasQry)->(H60_PRDOUT) )
			oSection2:Cell("GIC_CODG9B"):SetValue( (cAliasQry)->(GIC_CODG9B) )
			oSection2:Cell("GIC_STATUS"):SetValue( (cAliasQry)->(GIC_STATUS) )
			oSection2:Cell("REGRA")     :SetValue( cRegra )
			oSection2:PrintLine()

			oReport:IncMeter()
			(cAliasQry)->(dbSkip())

		EndDo

		oSection2:Finish()
		(cAliasQry)->(dbCloseArea())  // fecha cursor interno -- padrao RELSC7

		(cAliasAge)->(dbSkip())       // avanca agencia

		oSection1:Finish()
		oReport:FatLine()

	EndDo

	(cAliasAge)->(dbCloseArea())      // fecha cursor externo -- padrao RELSC7

Return
/*/{Protheus.doc} RegRel
	Regra Relatorio -- calcula a descricao da regra de produto aplicada ao registro
	@type function Static
	@author pedro.saboia
	@since 02/04/2026
	@param cAliasQry, character, alias da query posicionado no registro corrente
	@param oSection,  object,    secao (nao utilizado no loop manual; mantido por compatibilidade)
	@return character, descricao da regra aplicada
/*/
Static Function RegRel(cAliasQry)
	Local cCodCateg   := ""   as character
	Local cCodG9O     := ""   as character
	Local cEstCal     := ""   as character
	Local cEstOri     := ""   as character
	Local cProdGrt    := ""   as character
	Local cResult     := ""   as character
	Local cTpBil      := ""   as character
	Local cTpLinha    := ""   as character
	Local lfound      := .F.  as logical
	Local lG9B_GRATUI := G9B->(FieldPos("G9B_GRATUI")) > 0
	Local lH60_GERFIS := .T.  as logical
	Local lSkip       := .F.  as logical
	Default cAliasQry := ""

	If !Empty(cAliasQry)
		cCodCateg := AllTrim((cAliasQry)->(GIC_CODG9B))
		cCodG9O   := AllTrim((cAliasQry)->(G9O_CODIGO))
		cEstCal   := AllTrim((cAliasQry)->(UFDES))
		cEstOri   := AllTrim((cAliasQry)->(UFORI))
		cTpBil    := AllTrim((cAliasQry)->(GIC_TIPO))
	EndIf

	cTpLinha := Posicione('GI2', 4, xFilial('GI2') + (cAliasQry)->(GIC_LINHA) + '2', 'GI2_TIPLIN')

	If MV_PAR07 == 3 // NAO CONFIGURADO -- regra ja filtrada, so exibe mensagem
		cResult := STR0022 // "Nao existe regra de produto x tipo bilhete cadastrada"
	Else
		cResult := AplicaRegra(cAliasQry, cCodCateg, cCodG9O, cEstOri, cEstCal, cTpBil, cTpLinha, lG9B_GRATUI, lH60_GERFIS, nil, @lfound, @lSkip, @cProdGrt)

		If Empty(cResult) .And. !lSkip
			cResult := STR0022 // "Nao existe regra de produto x tipo bilhete cadastrada"
		EndIf
	EndIf

Return cResult
/*/{Protheus.doc} AplicaRegra
	Encapsula a logica de busca de regra (Gratuidade > Trecho > Estado > Tipo Bilhete).
	@type function Static
	@author pedro.saboia
	@since 02/04/2026
	@param cAlias,      character, alias da query ativa
	@param cCodCateg,   character, codigo da categoria do bilhete
	@param cCodG9O,     character, codigo G9O encontrado
	@param cEstOri,     character, UF de origem
	@param cEstCal,     character, UF de calculo (destino)
	@param cTpBil,      character, tipo do bilhete
	@param cTpLinha,    character, tipo de linha da GI2
	@param lG9B_GRATUI, logical,   indica se deve verificar gratuidade em G9B
	@param lH60_GERFIS, logical,   indica se deve filtrar por H60_GERFIS
	@param oSection,    object,    secao para SetValue (nil no loop manual)
	@param lfound,      logical,   (by ref) indica se H60 foi encontrado
	@param lSkip,       logical,   (by ref) indica registro a ser pulado
	@param cProdGrt,    character, (by ref) produto de gratuidade encontrado
	@return character, descricao da regra aplicada
/*/
Static Function AplicaRegra(cAlias, cCodCateg, cCodG9O, cEstOri, cEstCal, cTpBil, cTpLinha, lG9B_GRATUI, lH60_GERFIS, oSection, lfound, lSkip, cProdGrt)
	Local cResult := "" as character
	Default cAlias := ''

	If G9O->(DbSeek(xFilial("G9O") + (cAlias)->(GIC_ORIGEM) + cTpBil + (cAlias)->(GIC_STATUS) + cTpLinha)) .Or. G9O->(DbSeek(xFilial("G9O") + (cAlias)->(GIC_ORIGEM) + cTpBil + (cAlias)->(GIC_STATUS) + Space(TamSx3('G9O_GQCCOD')[1])))

		If GetGratuidade(lG9B_GRATUI, cEstOri, cCodCateg, cEstCal, @lfound, cAlias)
			If lfound
				If (lH60_GERFIS .And. (cAlias)->(H60_GERFIS) == '2') .Or. !lH60_GERFIS
					cProdGrt := (cAlias)->(H60_PRDGRT)
					cResult  := STR0023 // "Regra de produto x tipo bilhete para gratuidade."
				Else
					cResult := STR0024 //"UF de origem do BP-e possui regra para nao gerar o documento fiscal para o tipo e status deste BP-e"
					lSkip   := .T.
				EndIf
			Else
				cResult := STR0025 //"Nao localizado regra de produto x tipo bilhete para gratuidade."
				lSkip   := .T.
			EndIf
		Else
			If !Empty((cAlias)->H87_CODG9O) .And. H87->(DbSeek(xFilial('H87') + cCodG9O + (cAlias)->(GIC_LOCORI) + (cAlias)->(GIC_LOCDES)))
				If H87->H87_GERFIS == '1'
					cResult := STR0026 // "Regra Produto x Trechos Linha"
				Else
					cResult :=  STR0024 // "UF de origem do BP-e possui regra para nao gerar o documento fiscal para o tipo e status deste BP-e"
					lSkip   := .T.
				EndIf
			Else
				If H60->(DbSeek(xFilial("H60") + cCodG9O + cEstOri))
					If (lH60_GERFIS .And. (cAlias)->(H60_GERFIS) == '1') .Or. !lH60_GERFIS
						cResult := STR0027 // "Regra Produto x Estados"
					Else
						cResult := STR0024 // "UF de origem do BP-e possui regra para nao gerar o documento fiscal para o tipo e status deste BP-e"
						lSkip   := .T.
					EndIf
				Else
					cResult := STR0028 // "Regra Produto x Tipo Bilhete"
				EndIf
			EndIf
		EndIf

	EndIf

Return cResult
/*/{Protheus.doc} GetGratuidade
	Localiza Regra de bilhete gratuito
	@type function Static
	@author pedro.saboia
	@since 20/02/2026
	@version 1.0
	@param lG9B_GRATUI, logical,   indica a existencia de regra na tabela G9B
	@param cEstOri,     character, Estado de origem para verificacao de regra
	@param cCodCateg,   character, Codigo da categoria do bilhete
	@param cEstCal,     character, Estado de calculo para verificacao de regra
	@param lfound,      logical,   (by ref) indica que existe regra de busca interna de gratuidade
	@param cAlias,      character, Alias temporario para verificacao de gratuidade
	@return logical, Retorna verdadeiro caso localiza regra de bilhete gratuito
/*/
Static Function GetGratuidade(lG9B_GRATUI, cEstOri, cCodCateg, cEstCal, lfound, cAlias)
	Local lGratuito     := .F. as logical
	Local lRetorno      := .F. as logical
	Default cAlias      := ""
	Default cCodCateg   := ""
	Default cEstCal     := ""
	Default cEstOri     := ""
	Default lfound      := .F.
	Default lG9B_GRATUI := .T.

	lGratuito := Iif(lG9B_GRATUI, GetAdvFval("G9B","G9B_GRATUI",xFilial("G9B")+cCodCateg,1), '') == '2'


	If lGratuito
		lRetorno := .T.
		lfound := ( H60->(DbSeek(xFilial("H60") + (cAlias)->(G9O_CODIGO) + cEstOri + cCodCateg)) .Or. ;
		            H60->(DbSeek(xFilial("H60") + (cAlias)->(G9O_CODIGO) + Space(TamSx3("H60_UF")[1]) + cCodCateg)) .Or. ;
		            H60->(DbSeek(xFilial("H60") + (cAlias)->(G9O_CODIGO) + cEstOri)) .Or. ;
		            H60->(DbSeek(xFilial("H60") + (cAlias)->(G9O_CODIGO) + cEstCal + cCodCateg)) )
	Else
		lRetorno := .F.
		lfound   := .F.
	EndIf


Return lRetorno
