#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFDOC           
Gera o registro DOC da DIEF-CE 
Registro tipo DOC - Todos os documentos
Exceto: Cupons Fiscais, Nota Venda a Consumidor, Bilhetes de passagem  e Contas Energia Elétrica e Telefone;  
Os documentos fiscais das operações  de saída, quando o Regime de Pagamento for ME, ME - Simples Nacional,  MS, OUTROS  ou ESPECIAL; 
E, os documentos fiscais das operações  de saída dos contribuintes EPP-Simples Nacional  e Produtor  Rural.
 
1 - Indica o início de um bloco de dados de um documento  fiscal.  Este bloco se finaliza com o registro TOT.  
Um contribuinte  pode conter nenhum ou vários registros deste tipo.
2 - Quando um documento  fiscal possuir mais de um CFOP, lançá-lo tantos forem os CFOPs exitentes.
3 - Com relação a exceção 1, as contas de energia e telefone deverão ser geradas neste tipo de registro pelas empresas  de 
regime ME Simples Nacional a partir de 01/07/2007  e  EPP Simples Nacional a partir de 01/01/2011. 

@Param aWizard	->	Array com as informacoes da Wizard
 		cRegime-> Regime de recolhimento da Filial

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFDOC( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "DOC"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro DOC, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F. 

Begin Sequence

	QryDOC( cAliasQry, aWizard, cRegime )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
	
		If(GeraDOC( cAliasQry, cRegime ))
			cStrReg	:= cNomeReg
			cStrReg	+= GetOper( cAliasQry ) 													//Operação  ou Prestação  a que se refere o documento
			cStrReg	+= GetModelo(cAliasQry)													//Modelo dos documentos  fiscais
			cStrReg	+= PadR((cAliasQry)->C20_SERIE, 5)										//Série do documento  fiscal.
			cStrReg	+= PadR((cAliasQry)->C20_SUBSER, 5)									//Sub-série  do documento  fiscal
			cStrReg	+= TAFDecimal(Val((cAliasQry)->C20_NUMDOC), 10, 0, Nil)				//Número inicial dos documentos  fiscais.
			cStrReg	+= GetNumFim(cAliasQry)													//Número final dos documentos  fiscais.
			cStrReg	+= StrZero(Val((cAliasQry)->C0Y_CODIGO), 5)							//CFOP - Código Fiscal de Operação  e Prestação
			cStrReg	+= (cAliasQry)->C20_DTDOC												//Data da emissão.
			cStrReg	+= (cAliasQry)->C20_DTES													//Data da operação  (entrada ou saída) 
			cStrReg	+= GetTpFrete( cAliasQry, cRegime ) 									//Tipo de Frete: 1 - CIF 2 - FOB
			cStrReg	+= GetAIDF( cAliasQry, cRegime )										//AIDF - Número da Autorização  para Impressão  de Documentos Fiscais
			cStrReg	+= GetTpDisp( cAliasQry, cRegime )										//Tipo de dispositivo  autorizado
			cStrReg	+= GetIniAIDF( cAliasQry, cRegime ) 									//Número inicial do dispositivo  autorizado
			cStrReg	+= GetFimAIDF( cAliasQry, cRegime )									//Número final do dispositivo  autorizado
						
			cStrReg	+= CRLF
			
			AddLinDIEF( )
			
			WrtStrTxt( nHandle, cStrReg )
			
			//OS registro filhos, deverão ser adicionado no arquivo logo após o pai
			If( cRegime $ "|01|")
				lError := lError .Or. TAFDFITE( nHandle, cAliasQry, .F. )
				lError := lError .Or. TAFDFDCT( nHandle, cAliasQry )
				lError := lError .Or. TAFDFPAR( nHandle, cAliasQry )
				lError := lError .Or. TAFDFREF( nHandle, cAliasQry )
			Else
				lError := lError .Or. TAFDFPAR( nHandle, cAliasQry )
			EndIf
			
			lError := lError .Or. TAFDFTOT( nHandle, cAliasQry, cRegime, .F. )
			
		EndIF
		
		( cAliasQry )->( dbSkip() )
	End
	
	( cAliasQry )->( dbCloseArea())
	
	GerTxtReg( nHandle, cTXTSys, cNomeReg )
	
	If( lError )
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux , "9" )
		GlbUnlock()
	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()
	EndIf
	
Recover
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

End Sequence

ErrorBlock(oLastError)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QryDOC             
Seleciona os dados para geração do registro DOC 

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryDOC( cAliasQry, aWizard, cRegime )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""

cSelect 	:= " C20_INDEMI, C20_INDOPE, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_NDOCF, C20_DTDOC, C20_DTES, C20_CODPAR, C20_VLMERC, C20_VLSERV, "
cSelect 	+= " C01_CODIGO, C0Y_CODIGO, C0X_CODIGO, C0T_NUNAUT, C2M_CODIGO, C6V_NDIINI, C6V_NDIFIN, C6C_CODIGO, C20_CHVNF, C20_VLDOC, "
cSelect 	+= " C20_VLRFRT, C20_VLRDA, C20_VLRSEG, C20_VLDESC, C6V_ID "
cFrom   	:= RetSqlName("C20") + " C20 "
cFrom   	+= " LEFT JOIN " + RetSqlName("C01") + " C01 ON (C01_ID = C20_CODMOD AND C01.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C30") + " C30 ON (C20_CHVNF = C30_CHVNF AND C20_FILIAL = C30_FILIAL AND C30.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C0Y") + " C0Y ON (C0Y_ID = C30_CFOP AND C0Y.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C0X") + " C0X ON (C20_INDFRT = C0X_ID AND C0X.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C0T") + " C0T ON (C0T_ID = C20_AIDF AND C0T_FILIAL = C20_FILIAL  AND C0T.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C1L") + " C1L ON (C1L_ID = C30_CODITE AND C1L_FILIAL = C30_FILIAL AND C1L.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C2M") + " C2M ON (C1L_TIPITE = C2M_ID AND C2M.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C6V") + " C6V ON (C6V_ID = C0T_ID AND C6V_FILIAL = C0T_FILIAL AND C6V.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C6C") + " C6C ON (C0T_CODISP = C6C_ID AND C6C.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C02") + " C02 ON (C20_CODSIT = C02_ID AND C02.D_E_L_E_T_ = '') "
cWhere  	:= " C20.D_E_L_E_T_ = '' "
cWhere  	+= " AND C20_FILIAL = '" + xFilial( "C20" ) + "' "
cWhere  	+= " AND ( "
cWhere  	+= " 		(C20_DTDOC BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' AND C20_INDOPE = 1 )  "		//Lançamentos de Saída
cWhere  	+= " 		OR (C20_DTES BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' AND C20_INDOPE = 0 ) "		//Lançamentos de Entrada
cWhere  	+= " ) "
cWhere  	+= " AND C02_CODIGO IN ('00', '06') "
cGroupBy	:= " C20_INDEMI, C20_INDOPE, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_NDOCF, C20_DTDOC, C20_DTES, C20_CODPAR, "    
cGroupBy	+= " C01_CODIGO, C0Y_CODIGO, C0X_CODIGO, C0T_NUNAUT, C2M_CODIGO, C6V_NDIINI, C6V_NDIFIN, C6C_CODIGO, C20_CHVNF, "
cGroupBy	+= " C20_VLMERC, C20_VLSERV, C20_VLDOC, C20_VLRDA, C20_VLRSEG, C20_VLRFRT, C20_VLDESC, C6V_ID "

//As contas de energia e telefone deverão ser geradas neste tipo de registro pelas empresas de regime ME Simples Nacional EPP Simples Nacional. 

If(cRegime $ "|07|08|")
	cWhere  	+= " AND C01_CODIGO IN ('01', '04', '06', '07', '08', '09', '10', '11', '17', '18', '21', '22', '23', '24', '25','55', '57') "
Else 
	cWhere  	+= " AND C01_CODIGO IN ('01', '04', '07', '08', '09', '10', '11', '17', '18', '23', '24', '25', '55', '57') "
EndIf

cSelect 	:= "%" + cSelect 		+ "%"
cFrom   	:= "%" + cFrom   		+ "%"
cWhere  	:= "%" + cWhere   	+ "%"
cGroupBy  	:= "%" + cGroupBy   	+ "%"

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

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOper             
Operação  ou Prestação  a que se refere o documento  do estabelecimento conforme  tabela de Operações  (tab. 07)

01	Entrada de mercadoria através de documento fiscal emitido pelo próprio contribuinte.
02	Entrada de mercadoria e / ou serviço através de documento fiscal emitido por outro contribuinte ou através de nota fiscal avulsa (emitida pela SEFAZ-CE).
03	Saída de mercadoria.
05	Prestação de serviço sujeito ao ICMS.
11	Redução Z.
12	Serviço sujeito ao ISS

@author David Costa
@since  04/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetOper( cAliasQry )

Local cOper	:= "00"

If ((cAliasQry)->C20_INDEMI == "0" .And. (cAliasQry)->C20_INDOPE == "0")
	cOper := "01"
ElseIf((cAliasQry)->C20_INDEMI == "1" .And. (cAliasQry)->C20_INDOPE == "0")
	cOper := "02"
ElseIf((cAliasQry)->C20_INDOPE == "1")
	cOper := "03"
ElseIf((cAliasQry)->C2M_CODIGO == "11")
	cOper := "05"
ElseIf((cAliasQry)->C2M_CODIGO == "09")
	cOper := "12"
EndIf

Return( cOper )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpDisp             
Espécie de dispositivo  autorizado,  vide tabela 05.
Preencher com ZERO, quando o Regime de Pagamento for ME, MS, Especial e Outros

01	Blocos
02	Formulário contínuo
03	Formulário de segurança
04	Jogos soltos
05	ECF
06	Nota Fiscal Eletrônica
07	Conhecimento de Transporte Eletrônico 

@author David Costa
@since  04/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetTpDisp( cAliasQry, cRegime ) 		

Local cTpDisp	:= "00"

If(GetModelo(cAliasQry) == "55")
		cTpDisp := "06"
ElseIf( !(cRegime $ ('|05|06|07|12|') ) .And. GetOper( cAliasQry ) != "02")
	If(AllTrim((cAliasQry)->C6C_CODIGO) == "04")
		cTpDisp := "01"
	ElseIf(AllTrim((cAliasQry)->C6C_CODIGO) == "03")
		cTpDisp := "02"
	ElseIf(AllTrim((cAliasQry)->C6C_CODIGO) == "00")
		cTpDisp := "03"
	ElseIf(AllTrim((cAliasQry)->C6C_CODIGO) == "05")
		cTpDisp := "04"
	ElseIf(AllTrim((cAliasQry)->C6C_CODIGO) == "06")
		cTpDisp := "05"
	ElseIf(AllTrim((cAliasQry)->C6C_CODIGO) == "02")
		cTpDisp := "06"
	ElseIf(AllTrim((cAliasQry)->C6C_CODIGO) == "07")
		cTpDisp := "07"
	EndIf
EndIf

Return( cTpDisp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumFim             
Retorno o numero final do documento, caso esteja em branco retorna o numero inicial

@author David Costa
@since  16/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetNumFim( cAliasQry ) 		

Local cNumFim	:= ""

If(Empty((cAliasQry)->C20_NDOCF))
	cNumFim	:= StrZero(Val((cAliasQry)->C20_NUMDOC), 10)							//Número inicial dos documentos  fiscais.
Else
	cNumFim	:= StrZero(Val((cAliasQry)->C20_NDOCF), 10)							//Número Final dos documentos  fiscais.
EndIf

Return( cNumFim )

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraDOC             
Verifica se o registro deve ser gerado para este documento

@author David Costa
@since  16/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraDOC( cAliasQry, cRegime ) 		

lGeraDoc	:= .F.

	If( cRegime $ ('|05|06|07|08|12|') .And. (cAliasQry)->C20_INDOPE == "1")
 		lGeraDoc := .F.
 	ElseIf( cRegime $ ('|12|') .And. (cAliasQry)->C20_INDOPE == "0" .And. (cAliasQry)->C20_INDEMI == "0")
 		lGeraDoc := .F.
 	Else
 		lGeraDoc := .T. 	
 	EndIf

Return( lGeraDoc )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpFrete             
Retorna o tipo do frete

@author David Costa
@since  16/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetTpFrete( cAliasQry, cRegime )

Local cTpFrete	:= ""

If( !(cRegime $ ('|05|06|07|12|') ) .And. (cAliasQry)->C0X_CODIGO $ "|1|2|")
	cTpFrete := (cAliasQry)->C0X_CODIGO
EndIf
 
cTpFrete := PadR(cTpFrete, 1)
 
Return(cTpFrete)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAIDF             
Retorna o numero AIDF

@author David Costa
@since  16/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetAIDF( cAliasQry, cRegime ) 

Local cAIDF	:= ""

If( !(cRegime $ ('|05|06|07|12|') ))							//Para este regime o numero da AIDF não deve ser informado
	cAIDF := TAFDecimal(Val((cAliasQry)->C0T_NUNAUT), 11, 0, Nil)
Else
	cAIDF := StrZero(0, 11)	
EndIf

Return(cAIDF)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetIniAIDF             
Retorna o numero inicial autorizado pela AIDF

@author David Costa
@since  16/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetIniAIDF( cAliasQry, cRegime ) 

Local cNumIni	:= ""

If( !(cRegime $ ('|05|06|07|12|') ) .And. !((cAliasQry)->C01_CODIGO $ "55"))
	cNumIni := StrZero(Val((cAliasQry)->C6V_NDIINI), 10)	
Else
	cNumIni := StrZero(0, 10)	
EndIf

Return(cNumIni)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFimAIDF             
Retorna o numero Final autorizado pela AIDF

@author David Costa
@since  16/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetFimAIDF( cAliasQry, cRegime ) 

Local cNumFim	:= ""

If( !(cRegime $ ('|05|06|07|12|') ) .And. !((cAliasQry)->C01_CODIGO $ "55"))
	cNumFim := StrZero(Val((cAliasQry)->C6V_NDIFIN), 10)	
Else
	cNumFim := StrZero(0, 10)	
EndIf

Return(cNumFim)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetModelo             
Retorna o modelo do documento fiscal

@author David Costa
@since  18/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetModelo( cAliasQry )

Local cModelo	:= ""

cModelo := PadR(Val((cAliasQry)->C01_CODIGO),2)

Return(cModelo)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPRDDOC             
Retorna um filtro com os IDs dos Produtos que serão gerados por este registro 

@author David Costa
@since  11/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GetPRDDOC( cFiltroPRD, aWizard, cRegime )

Local cAliasQry	:=	GetNextAlias()

QryDOC( cAliasQry, aWizard, cRegime )

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

While !( cAliasQry )->( Eof() )
	DbSelectArea("C30")
	C30->( DbSetOrder( 1 ) )
	
	If(C30->(MsSeek(xFilial("C30") + (cAliasQry)->C20_CHVNF)))
		
		While C30->(!Eof()) .And. (cAliasQry)->C20_CHVNF == C30->C30_CHVNF
			cFiltroPRD += " '" +C30->C30_CODITE + "',"
			C30->( dbSkip() )
		End
	EndIf
	( cAliasQry )->( dbSkip() )
End

( cAliasQry )->( dbCloseArea())

Return