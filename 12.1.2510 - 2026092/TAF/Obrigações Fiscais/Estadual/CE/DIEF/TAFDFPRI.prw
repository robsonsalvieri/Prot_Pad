#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFPRI           
Gera o registro PRI da DIEF-CE 
Registro tipo PRI - Operações com produtos primários e regimes especiais

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFPRI( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "PRI"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro PRI, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QryPRI( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
	
		cStrReg	:= cNomeReg
		cStrReg	+= TAFDecimal((cAliasQry)->MUNICIPIO, 5, 0, Nil)			//Codigo do município
		cStrReg	+= TAFDecimal((cAliasQry)->C30_TOTAL, 13, 2, Nil )		//Valor das aquisições  de mercadorias  e serviços
		cStrReg	+= CRLF
		
		( cAliasQry )->( dbSkip() )
		
		AddLinDIEF( )
		
		WrtStrTxt( nHandle, cStrReg )
	End
	
	( cAliasQry )->( dbCloseArea())
	
	GerTxtReg( nHandle, cTXTSys, cNomeReg )

	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()
	
Recover
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

End Sequence

ErrorBlock(oLastError)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QryPRI             
Seleciona os dados para geração do registro PRI 

@author David Costa
@since  18/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryPRI( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""
Local cSelect2	:=	""
Local cFrom2		:=	""
Local cWhere2		:=	""
Local cGroupBy2  	:=	""
Local cSelect3	:=	""
Local cFrom3		:=	""
Local cWhere3		:=	""
Local cGroupBy3  	:=	""
Local cSelect4	:=	""
Local cFrom4		:=	""
Local cWhere4		:=	""
Local cGroupBy4  	:=	""

//----Operações de entrada com produto primarios

cSelect	:= " SUM(C30_TOTAL) C30_TOTAL, C07_CODIGO MUNICIPIO "
cFrom		:= RetSqlName("C20")  + " C20 "
cFrom		+= " JOIN " + RetSqlName("C30") + " C30  "
cFrom		+= " 	JOIN " + RetSqlName("C1L") + " C1L "
cFrom		+= " 		JOIN " + RetSqlName("C2M") + " C2M "
cFrom		+= " 		ON C2M_ID = C1L_TIPITE "
cFrom		+= " 			AND C2M.D_E_L_E_T_ = '' "
cFrom		+= " 			AND C2M.C2M_CODIGO = '01' "
cFrom		+= " 	ON C1L_ID = C30_CODITE "
cFrom		+= " 		AND C1L_FILIAL = C30_FILIAL "
cFrom		+= " 		AND C1L.D_E_L_E_T_ = '' "
cFrom		+= " ON C30_CHVNF = C20_CHVNF "
cFrom		+= " 	AND C30_FILIAL = C20_FILIAL "
cFrom		+= " 	AND C30.D_E_L_E_T_ = '' "
cFrom		+= " JOIN " + RetSqlName("C1H") + " C1H "
cFrom		+= " 	JOIN " + RetSqlName("C07") + " C07 "
cFrom		+= " 	ON C07_ID = C1H_CODMUN "
cFrom		+= " 		AND C07.D_E_L_E_T_ = '' "
cFrom		+= " ON C1H_ID = C20_CODPAR "
cFrom		+= " 	AND C1H_FILIAL = C30_FILIAL "
cFrom		+= " 	AND C1H.D_E_L_E_T_ = '' "
cFrom		+= " LEFT JOIN " + RetSqlName("C01") + " C01 "
cFrom		+= " ON C01_ID = C20_CODMOD  "
cFrom		+= " 	AND C01.D_E_L_E_T_ = '' "
cWhere		:= " C20.D_E_L_E_T_ = '' "
cWhere		+= " AND C20_FILIAL = '" + xFilial( "C20" ) + "' "
cWhere		+= " AND C20_DTES BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "
cWhere		+= " AND (C20_INDEMI = '0' "	//Emissão propria 
cWhere		+= " 	OR C01_CODIGO = '36') "	//Nota avulsa
cWhere		+= " AND C20_INDOPE = '0' "		//Entrada
cGroupBy	:= " C07_CODIGO "

cSelect	:= "%" + cSelect 		+ "%"
cFrom	 	:= "%" + cFrom   		+ "%"
cWhere  	:= "%" + cWhere   	+ "%"
cGroupBy  	:= "%" + cGroupBy   	+ "%"

//----Operações de saida com serviços de Telecomunicação/Comunicação

cSelect2	:= " SUM(C30_TOTAL) C30_TOTAL, C07_CODIGO MUNICIPIO "
cFrom2		:= RetSqlName("C20")  + " C20 "
cFrom2		+= " JOIN " + RetSqlName("C30") + " C30  "
cFrom2		+= " ON C30_CHVNF = C20_CHVNF "
cFrom2		+= " 	AND C30_FILIAL = C20_FILIAL "
cFrom2		+= " 	AND C30.D_E_L_E_T_ = '' "
cFrom2		+= " LEFT JOIN " + RetSqlName("C01") + "  C01 "
cFrom2		+= " ON C01_ID = C20_CODMOD  "
cFrom2		+= " 	AND C01.D_E_L_E_T_ = '' "
cFrom2		+= " JOIN " + RetSqlName("C38") + " C38 "
cFrom2		+= " 	JOIN " + RetSqlName("C1H") + " C1H "
cFrom2		+= " 		JOIN " + RetSqlName("C09") + " C09 "
cFrom2		+= " 		ON C09_ID = C1H_UF "
cFrom2		+= " 			AND C09.D_E_L_E_T_ = '' "
cFrom2		+= " 			AND C09_UF = 'CE' "
cFrom2		+= " 		JOIN " + RetSqlName("C07") + " C07 "
cFrom2		+= " 		ON C07_ID = C1H_CODMUN "
cFrom2		+= " 			AND C07.D_E_L_E_T_ = '' "
cFrom2		+= " 	ON C1H_ID = C38_CODPAR "
cFrom2		+= " 		AND C1H_FILIAL = C38_FILIAL "
cFrom2		+= " 		AND C1H.D_E_L_E_T_ = '' "
cFrom2		+= " ON C38_CHVNF = C30_CHVNF "
cFrom2		+= " 	AND C38_NUMITE = C30_NUMITE "
cFrom2		+= " 	AND C38_CODITE = C30_CODITE "
cFrom2		+= " 	AND C38.D_E_L_E_T_ = '' "
cWhere2	:= " C20.D_E_L_E_T_ = ''  "
cWhere2	+= " AND C20_FILIAL = '" + xFilial( "C20" ) + "' "
cWhere2	+= " AND C20_DTDOC BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "
cWhere2	+= " AND C20_INDOPE = '1' "		//-- Saida
cWhere2	+= " AND C01_CODIGO IN ('21', '22') "
cGroupBy2	:= " C07_CODIGO "

cSelect2	:= "%" + cSelect2		+ "%"
cFrom2	 	:= "%" + cFrom2  		+ "%"
cWhere2  	:= "%" + cWhere2   	+ "%"
cGroupBy2 	:= "%" + cGroupBy2  	+ "%"

//----Operações de saida com serviços de distribuição de água e Energia Elétrica

cSelect3	:= " SUM(C30_TOTAL) C30_TOTAL, C07_CODIGO MUNICIPIO "
cFrom3		:= RetSqlName("C20")  + " C20 "
cFrom3		+= " JOIN " + RetSqlName("C30") + " C30 "
cFrom3		+= " ON C30_CHVNF = C20_CHVNF "
cFrom3		+= " 	AND C30_FILIAL = C20_FILIAL "
cFrom3		+= " 	AND C30.D_E_L_E_T_ = '' "
cFrom3		+= " LEFT JOIN " + RetSqlName("C01") + " C01 "
cFrom3		+= " ON C01_ID = C20_CODMOD  "
cFrom3		+= " 	AND C01.D_E_L_E_T_ = '' "
cFrom3		+= " JOIN " + RetSqlName("C32") + " C32 "
cFrom3		+= " 	JOIN " + RetSqlName("C1H") + " C1H "
cFrom3		+= " 		JOIN " + RetSqlName("C09") + " C09 "
cFrom3		+= " 		ON C09_ID = C1H_UF "
cFrom3		+= " 			AND C09.D_E_L_E_T_ = '' "
cFrom3		+= " 			AND C09_UF = 'CE' "
cFrom3		+= " 		JOIN " + RetSqlName("C07") + " C07 "
cFrom3		+= " 		ON C07_ID = C1H_CODMUN "
cFrom3		+= " 			AND C07.D_E_L_E_T_ = '' "
cFrom3		+= " 	ON C1H_ID = C32_CODPAR "
cFrom3		+= " 		AND C1H_FILIAL = C32_FILIAL "
cFrom3		+= " 		AND C1H.D_E_L_E_T_ = '' "
cFrom3		+= " ON C32_CHVNF = C30_CHVNF "
cFrom3		+= " 	AND C32_NUMITE = C30_NUMITE "
cFrom3		+= " 	AND C32_CODITE = C30_CODITE "
cFrom3		+= " 	AND C32.D_E_L_E_T_ = '' "
cWhere3	:= " C20.D_E_L_E_T_ = ''  "
cWhere3	+= " AND C20_FILIAL = '" + xFilial( "C20" ) + "' "
cWhere3	+= " AND C20_DTDOC BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "
cWhere3	+= " AND C20_INDOPE = '1' "		//-- Saida
cWhere3	+= " AND C01_CODIGO IN ('06', '29') "
cGroupBy3	:= " C07_CODIGO "

cSelect3	:= "%" + cSelect3		+ "%"
cFrom3	 	:= "%" + cFrom3  		+ "%"
cWhere3  	:= "%" + cWhere3   	+ "%"
cGroupBy3 	:= "%" + cGroupBy3  	+ "%"

//----Operações de saida com serviços de Transporte

cSelect4	:= " SUM(C30_TOTAL) C30_TOTAL, C07_CODIGO MUNICIPIO "
cFrom4		:= RetSqlName("C20")  + " C20 "
cFrom4		+= " JOIN " + RetSqlName("C30") + " C30 "
cFrom4		+= " ON C30_CHVNF = C20_CHVNF "
cFrom4		+= " 	AND C30_FILIAL = C20_FILIAL "
cFrom4		+= " 	AND C30.D_E_L_E_T_ = '' "
cFrom4		+= " LEFT JOIN " + RetSqlName("C01") + " C01 "
cFrom4		+= " ON C01_ID = C20_CODMOD  "
cFrom4		+= " 	AND C01.D_E_L_E_T_ = '' "
cFrom4		+= " JOIN " + RetSqlName("C39") + " C39 "
cFrom4		+= " 	JOIN " + RetSqlName("C09") + " C09 "
cFrom4		+= " 	ON C09_ID = C39_UFORIG "
cFrom4		+= " 		AND C09.D_E_L_E_T_ = '' "
cFrom4		+= " 		AND C09_UF = 'CE' "
cFrom4		+= " 	JOIN " + RetSqlName("C07") + " C07 "
cFrom4		+= " 	ON C07_ID = C39_CMUNOR "
cFrom4		+= " 		AND C07.D_E_L_E_T_ = '' "
cFrom4		+= " ON C39_CHVNF = C30_CHVNF "
cFrom4		+= " 	AND C39_NUMITE = C30_NUMITE "
cFrom4		+= " 	AND C39_CODITE = C30_CODITE "
cFrom4		+= " 	AND C39.D_E_L_E_T_ = '' "
cWhere4	:= " C20.D_E_L_E_T_ = ''  "
cWhere4	+= " AND C20_FILIAL = '" + xFilial( "C20" ) + "' "
cWhere4	+= " AND C20_DTDOC BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "
cWhere4	+= " AND C20_INDOPE = '1' "		//-- Saida
cWhere4	+= " AND C01_CODIGO ='07' "
cGroupBy4	:= " C07_CODIGO "

cSelect4	:= "%" + cSelect4		+ "%"
cFrom4	 	:= "%" + cFrom4  		+ "%"
cWhere4  	:= "%" + cWhere4   	+ "%"
cGroupBy4 	:= "%" + cGroupBy4  	+ "%"

BeginSql Alias cAliasQry

	SELECT SUM(C30_TOTAL) C30_TOTAL, MUNICIPIO
	FROM (
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%
			GROUP BY
				%Exp:cGroupBy%
			UNION
			SELECT
				%Exp:cSelect2%
			FROM
				%Exp:cFrom2%
			WHERE
				%Exp:cWhere2%
			GROUP BY
				%Exp:cGroupBy2%
			UNION
			SELECT
				%Exp:cSelect3%
			FROM
				%Exp:cFrom3%
			WHERE
				%Exp:cWhere3%
			GROUP BY
				%Exp:cGroupBy3%
			UNION
			SELECT
				%Exp:cSelect4%
			FROM
				%Exp:cFrom4%
			WHERE
				%Exp:cWhere4%
			GROUP BY
				%Exp:cGroupBy4%
		) PRI
		GROUP BY MUNICIPIO
EndSql

Return
