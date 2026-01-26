#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFMES           
Gera o registro MES da DIEF-CE 
Registro tipo MES - Operações de Saída dos Regimes de Pagamento ME, ME - Simples Nacional, MS, Especial e Outros, totalizado por CFOP.

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFMES( aWizard, cRegime, cJobAux )
Local cNomeReg	:= "MES"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError 	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro MES, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QryMES( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )

		cStrReg	:= cNomeReg
		cStrReg	+= StrZero( Val((cAliasQry)->C0Y_CODIGO), 5)				//Código Fiscal de Operação  e Prestação
		cStrReg	+= TAFDecimal((cAliasQry)->C30_TOTAL, 13, 2, Nil)		//Valor total dos produtos ou serviços.
		cStrReg	+= TAFDecimal(0, 13, 2, Nil)								//Valor da base do ICMS. A partir de Jan/2011 preencher com zero
		cStrReg	+= TAFDecimal((cAliasQry)->C35_ISE_NT, 13, 2, Nil)		//Valor total de Isentas ou não Tributadas.
		cStrReg	+= TAFDecimal((cAliasQry)->C35_VLOUTR, 13, 2, Nil)		//Valor total de Outras.
		cStrReg	+= TAFDecimal((cAliasQry)->C30_VLOPER, 13, 2, Nil)		//Valor total do documento  fiscal computados  todos os acréscimos  ou decréscimos.
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
/*/{Protheus.doc} QryMES             
Seleciona os dados para geração do registro MES

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryMES( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""
Local cTabela1	:=	""
Local cTabela2	:=	""
Local cTabela3	:=	""
Local cTabela4	:=	""
Local cTabela5	:=	""

cTabela1 := RetSqlName("C20")
cTabela2 := RetSqlName("C30")
cTabela3 := RetSqlName("C35")
cTabela4 := RetSqlName("C0Y")
cTabela5 := RetSqlName("C3S")

cSelect 	:= " SUM(C30_TOTAL) C30_TOTAL , SUM(C30_VLOPER) C30_VLOPER, SUM(C35_BASE) C35_BASE , SUM(C35_VLOUTR) C35_VLOUTR, SUM(C35_VLNT + C35_VLISEN) C35_ISE_NT, C0Y_CODIGO "
cFrom   	:= cTabela1 + " C20 "
cFrom   	+= " LEFT JOIN " + cTabela2 + " C30 ON (C20.C20_CHVNF = C30.C30_CHVNF AND C20.C20_FILIAL = C30.C30_FILIAL AND C30.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + cTabela3 + " C35 ON (C30.C30_CHVNF = C35.C35_CHVNF AND C30.C30_NUMITE = C35.C35_NUMITE AND C30.C30_CODITE = C35.C35_CODITE AND C35.D_E_L_E_T_ = '') "
cFrom		+= " LEFT JOIN " + cTabela4 + " C0Y ON (C30.C30_CFOP = C0Y.C0Y_ID AND C0Y.D_E_L_E_T_ = '') "
cFrom		+= " LEFT JOIN " + cTabela5 + " C3S ON (C35.C35_CODTRI = C3S.C3S_ID AND C3S.D_E_L_E_T_ = '') "
cWhere  	:= " C20.D_E_L_E_T_ = '' "
cWhere  	+= " AND C20.C20_FILIAL = '" + xFilial( "C20" ) + "' "
cWhere  	+= " AND C3S.C3S_CODIGO IN ('02', '03', '17')" 																						//Apenas o ICMS deve ser considerado
cWhere  	+= " AND C20.C20_DTDOC BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "
cWhere  	+= " AND C20_INDOPE = 1 " 		//Lançamentos de Saída
cGroupBy	:= " C0Y_CODIGO "
		

cSelect 	:= "%" + cSelect 		+ "%"
cFrom   	:= "%" + cFrom   		+ "%"
cWhere  	:= "%" + cWhere   	+ "%"
cGroupBy  	:= "%" + cGroupBy		+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
	GROUP BY
		%Exp:cGroupBy%
EndSql

Return 

