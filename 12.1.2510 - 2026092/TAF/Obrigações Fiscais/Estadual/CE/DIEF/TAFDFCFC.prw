#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFCFC           
Registro tipo CFC 

Cupons Fiscais, Nota Venda a Consumidor, Bilhetes de passagem e Contas Energia Elétrica e Telefone.

@Param aWizard	->	Array com as informacoes da Wizard
 		cRegime-> Regime de recolhimento da Filial

@author David Costa
@since  07/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFCFC( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "CFC"
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError 	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro CFC, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence

	QryCFCMOV( cAliasQry, aWizard )
	MontarCFC( cAliasQry, cNomeReg, nHandle, .F., cRegime )
	
	cAliasQry	:= GetNextAlias()
	QryCFCCupom( cAliasQry, aWizard )
	lError := lError .Or. MontarCFC( cAliasQry, cNomeReg, nHandle, .T., cRegime )
	
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
/*/{Protheus.doc} QryCFCMOV            
Seleciona os dados para geração do registro CFC da DIEF-CE
Apenas os documentos de modelo '1A', '06', '13', '14', '15', '16', '20', '21', '22', '36', '37', '38', '39', '96'
Cadastrados nas movimentações fiscais  

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryCFCMOV( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""

cSelect 	:= " C20_INDEMI, C20_INDOPE, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_NDOCF, C20_DTDOC, C20_DTES, C20_CODPAR, C20_VLMERC, "
cSelect 	+= " C01_CODIGO, C0Y_CODIGO, C0T_NUNAUT, C2M_CODIGO, C6V_NDIINI, C6V_NDIFIN, C6C_CODIGO, C20_CHVNF, C20_VLDOC, "
cSelect 	+= " C20_VLSERV, C20_VLRFRT, C20_VLRDA, C20_VLRSEG, C20_VLDESC "
cFrom   	:= RetSqlName("C20") + " C20 "
cFrom   	+= " LEFT JOIN " + RetSqlName("C01") + " C01 ON (C01_ID = C20_CODMOD AND C01.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C30") + " C30 ON (C20_CHVNF = C30_CHVNF AND C20_FILIAL = C30_FILIAL AND C30.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C0Y") + " C0Y ON (C0Y_ID = C30_CFOP AND C0Y.D_E_L_E_T_ = '') "
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
cWhere  	+= " AND C01_CODIGO IN ('1A', '06', '13', '14', '15', '16', '20', '21', '22', '36', '37', '38', '39', '96') "
cGroupBy	:= " C20_INDEMI, C20_INDOPE, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_NDOCF, C20_DTDOC, C20_DTES, C20_CODPAR, "    
cGroupBy	+= " C01_CODIGO, C0Y_CODIGO, C0T_NUNAUT, C2M_CODIGO, C6V_NDIINI, C6V_NDIFIN, C6C_CODIGO, C20_CHVNF, "
cGroupBy	+= " C20_VLMERC, C20_VLSERV, C20_VLDOC, C20_VLRDA, C20_VLRSEG, C20_VLRFRT, C20_VLDESC "

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
/*/{Protheus.doc} QryCFCCupom            
Seleciona os dados para geração do registro CFC da DIEF-CE
Apenas cupons fiscais  

@author David Costa
@since  10/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryCFCCupom( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""

cSelect 	:= " C6I_DTEMIS, C01_CODIGO, C6I_NUMDOC, C0Y_CODIGO, C0W_ECFCX, C6I_ID, C6I_DTMOV, C6I_CMOD, C6I_VLDOC, C6I_CODSIT "

cFrom   	:= RetSqlName("C6I") + " C6I "

cFrom   	+= " LEFT JOIN " + RetSqlName("C6G") + " C6G "
cFrom   	+= " 	ON C6G_ID = C6I_ID "
cFrom   	+= " 	AND C6G_FILIAL = C6I_FILIAL "
cFrom   	+= " 	AND C6G_DTMOV = C6I_DTMOV "
cFrom   	+= " 	AND C6G.D_E_L_E_T_ = '' "

cFrom   	+= " LEFT JOIN " + RetSqlName("C01") + " C01 "
cFrom   	+= " 	ON C01.D_E_L_E_T_ = '' "
cFrom   	+= " 	AND C01_ID = C6I_CMOD "
//Itens do Cupom
cFrom   	+= " LEFT JOIN " + RetSqlName("C6J") + " C6J "
cFrom   	+= " 	ON C6J.D_E_L_E_T_ = '' "
cFrom   	+= " 	AND C6I_ID = C6J_ID "
cFrom   	+= " 	AND C6I_DTMOV = C6J_DTMOV "
cFrom   	+= " 	AND C6I_CMOD = C6J_CMOD "
cFrom   	+= " 	AND C6I_CODSIT = C6J_CODSIT "
cFrom   	+= " 	AND C6I_NUMDOC = C6J_NUMDOC "
cFrom   	+= " 	AND C6I_DTEMIS = C6J_DTEMIS "
//CFOP dos itens
cFrom   	+= " LEFT JOIN " + RetSqlName("C0Y") + " C0Y "
cFrom   	+= " 	ON C0Y.D_E_L_E_T_ = '' "
cFrom   	+= " 	AND C0Y_ID = C6J_CFOP "

cFrom   	+= " LEFT JOIN " + RetSqlName("C6F") + " C6F "
cFrom   	+= " 	ON C6G_ID = C6F_ID "
cFrom   	+= " 	AND C6G_FILIAL = C6F_FILIAL "
cFrom   	+= " 	AND C6F.D_E_L_E_T_ = '' "

cFrom   	+= " LEFT JOIN " + RetSqlName("C0W") + " C0W "
cFrom   	+= " 	ON C0W.D_E_L_E_T_ = '' "
cFrom   	+= " 	AND C0W_FILIAL = C6F_FILIAL "
cFrom   	+= " 	AND C0W_ID = C6F_CODECF "
//Situação do documento
cFrom   	+= " LEFT JOIN " + RetSqlName("C02") + " C02 "
cFrom   	+= " 	ON C02.D_E_L_E_T_ = '' "
cFrom   	+= " 	AND C02_ID = C6I_CODSIT "

cWhere  	:= " C6I_DTEMIS BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "
cWhere  	+= " AND C6I.D_E_L_E_T_ = '' "
cWhere  	+= " AND C6I_FILIAL = '" + xFilial( "C6I" ) + "' "
cWhere  	+= " AND C01_CODIGO = '37' "
cWhere  	+= " AND C02_CODIGO = '00' "

cGroupBy	:= " C6I_DTEMIS, C01_CODIGO, C6I_NUMDOC, C0Y_CODIGO, C0W_ECFCX, C6I_ID, C6I_DTMOV, C6I_CMOD, C6I_VLDOC, C6I_CODSIT " 

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
Static Function GetOper( cAliasQry, lCupom )

Local cOper	:= "00"

If(lCupom)
	cOper := "11"
ElseIf ((cAliasQry)->C20_INDEMI == "0" .And. (cAliasQry)->C20_INDOPE == "0")
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
Static Function GetTpDisp( cAliasQry, lCupom ) 		

Local cTpDisp	:= "00"

If(lCupom)
	cTpDisp := "05"
ElseIf(GetOper( cAliasQry, lCupom ) != "02")
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
Static Function GetNumFim( cAliasQry, lCupom) 		

Local cNumFim	:= ""

If(lCupom)
	cNumFim := GetNumDoc( cAliasQry, lCupom )
ElseIf(Empty((cAliasQry)->C20_NDOCF))
	cNumFim := StrZero(Val((cAliasQry)->C20_NUMDOC), 10)							//Número inicial dos documentos  fiscais.
Else
	cNumFim := StrZero(Val((cAliasQry)->C20_NDOCF), 10)							//Número Final dos documentos  fiscais.
EndIf

Return( cNumFim )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAIDF             
Retorna o numero AIDF

@author David Costa
@since  16/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetAIDF( cAliasQry, lCupom ) 

Local cAIDF	:= ""

If( lCupom )
	cAIDF := TAFDecimal(0, 11, 0, Nil)
Else
	cAIDF := TAFDecimal(Val((cAliasQry)->C0T_NUNAUT), 11, 0, Nil)
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
Static Function GetIniAIDF( cAliasQry, lCupom ) 

Local cNumIni	:= ""

If( lCupom )
	cNumIni := TAFDecimal(0, 10, 0, Nil)
Else
	cNumIni := StrZero(Val((cAliasQry)->C6V_NDIINI), 10)	
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
Static Function GetFimAIDF( cAliasQry, lCupom ) 

Local cNumFim	:= ""

If( lCupom )
	cNumFim := TAFDecimal(0, 10, 0, Nil)
Else
	cNumFim := StrZero(Val((cAliasQry)->C6V_NDIFIN), 10)	
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
/*/{Protheus.doc} MontarCFC             
Monta o registro CFC

@author David Costa
@since  09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MontarCFC( cAliasQry, cNomeReg, nHandle, lCupom, cRegime )

Local cStrReg		:= ""
Local lError		:= .F.

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

While !( cAliasQry )->( Eof() )
	
		cStrReg	:= cNomeReg
		cStrReg	+= GetOper( cAliasQry, lCupom ) 				//Operação  ou Prestação  a que se refere o documento
		cStrReg	+= GetModelo(cAliasQry)							//Modelo dos documentos  fiscais
		cStrReg	+= GetSerie( cAliasQry, lCupom )				//Série do documento  fiscal.
		cStrReg	+= GetSubSerie( cAliasQry, lCupom )			//Sub-série  do documento  fiscal
		cStrReg	+= GetNumDoc( cAliasQry, lCupom )				//Número inicial dos documentos  fiscais.
		cStrReg	+= GetNumFim(cAliasQry, lCupom)					//Número final dos documentos  fiscais.
		cStrReg	+= GetnCXa(cAliasQry, lCupom)					//Número do Caixa
		cStrReg	+= StrZero(Val((cAliasQry)->C0Y_CODIGO), 5)	//CFOP - Código Fiscal de Operação  e Prestação
		cStrReg	+= GetDEmis( cAliasQry, lCupom )				//Data da emissão.
		cStrReg	+= GetDataES( cAliasQry, lCupom )				//Data da operação  (entrada ou saída)
		cStrReg	+= GetAIDF( cAliasQry, lCupom )					//AIDF - Número da Autorização  para Impressão  de Documentos Fiscais
		cStrReg	+= GetTpDisp( cAliasQry, lCupom )				//Tipo de dispositivo  autorizado
		cStrReg	+= GetIniAIDF( cAliasQry, lCupom ) 			//Número inicial do dispositivo  autorizado
		cStrReg	+= GetFimAIDF( cAliasQry, lCupom )				//Número final do dispositivo  autorizado
		cStrReg	+= CRLF
		
		AddLinDIEF( )
		
		WrtStrTxt( nHandle, cStrReg )
		
		//OS registro filhos, deverão ser adicionado no arquivo logo após o pai
		lError := lError .Or. TAFDFITE( nHandle, cAliasQry, lCupom )
		lError := lError .Or. TAFDFTOT( nHandle, cAliasQry, cRegime, lCupom )
			
		( cAliasQry )->( DbSkip() )
	End

( cAliasQry )->( DbCloseArea())

Return( lError )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSerie             
Retorna a Serie do Documento

@author David Costa
@since  09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetSerie( cAliasQry, lCupom )

Local cSerie	:= ""

If( lCupom )
	cSerie := Space(5)
Else
	cSerie := PadR((cAliasQry)->C20_SERIE, 5)
EndIf	

Return( cSerie )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSubSerie             
Retorna a Serie do Documento

@author David Costa
@since  09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetSubSerie( cAliasQry, lCupom )

Local cSubSerie	:= ""

If( lCupom )
	cSubSerie := Space(5)
Else
	cSubSerie := PadR((cAliasQry)->C20_SUBSER, 5)
EndIf	

Return( cSubSerie )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumDoc             
Retorna o número inicial do Documento

@author David Costa
@since  09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetNumDoc( cAliasQry, lCupom )

Local cNumDoc	:= ""

If( lCupom )
	cNumDoc := TAFDecimal(Val((cAliasQry)->C6I_NUMDOC), 10, 0, Nil)
Else
	cNumDoc := TAFDecimal(Val((cAliasQry)->C20_NUMDOC), 10, 0, Nil)
EndIf	

Return( cNumDoc )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetnCXa             
Retorna o número do caixa

@author David Costa
@since  09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetnCXa( cAliasQry, lCupom )

Local cnCXa	:= ""

If( lCupom )
	cnCXa := TAFDecimal(Val((cAliasQry)->C0W_ECFCX), 4, 0, Nil)
Else
	cnCXa := TAFDecimal(0, 4, 0, Nil)
EndIf	

Return( cnCXa )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDEmis             
Retorna a Data de Emissão

@author David Costa
@since  09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetDEmis( cAliasQry, lCupom )

Local cDEmis	:= ""

If( lCupom )
	cDEmis := (cAliasQry)->C6I_DTEMIS
Else
	cDEmis := (cAliasQry)->C20_DTDOC
EndIf	

Return( cDEmis )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDataES             
Retorna a Data de Entrada/Saída

@author David Costa
@since  09/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetDataES( cAliasQry, lCupom )

Local cDataES	:= ""

If( lCupom )
	cDataES := (cAliasQry)->C6I_DTEMIS
Else
	cDataES := (cAliasQry)->C20_DTES
EndIf	

Return( cDataES )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPRDCFC            
Retorna um filtro com os IDs dos Produtos que serão gerados por este registro 

@author David Costa
@since  11/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function GetPRDCFC( cFiltroPRD, aWizard, cRegime )

Local cAliasQry	:=	GetNextAlias()
Local cCHVC6I 	:= "C6I_ID + C6I_DTMOV + C6I_CMOD + C6I_CODSIT + C6I_NUMDOC + C6I_DTEMIS"
Local cCHVC6J 	:= "C6J_ID + DTOS(C6J_DTMOV) + C6J_CMOD + C6J_CODSIT + C6J_NUMDOC + DTOS(C6J_DTEMIS)"

//-------------Documentos Fiscais----------------
QryCFCMOV( cAliasQry, aWizard )

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

While !( cAliasQry )->( Eof() )
	DbSelectArea("C30")
	C30->( DbSetOrder( 1 ) )
	
	If(C30->(MsSeek(xFilial("C30") + (cAliasQry)->C20_CHVNF)))
		
		While C30->(!Eof()) .And. (cAliasQry)->C20_CHVNF == C30->C30_CHVNF
			cFiltroPRD += " '" + C30->C30_CODITE + "',"
			C30->( dbSkip() )
		End
	EndIf
	DBCloseArea("C30")
	( cAliasQry )->( dbSkip() )
End

( cAliasQry )->( dbCloseArea())

//---------------Cupons Fiscais------------------
cAliasQry	:=	GetNextAlias()

QryCFCCupom( cAliasQry, aWizard )

DbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

While !( cAliasQry )->( Eof() )
	DbSelectArea("C6J")
	C6J->( DbSetOrder( 1 ) )
	
	If(C6J->(MsSeek(xFilial("C6J") + (cAliasQry)->&(cCHVC6I))))
		
		While C6J->(!Eof()) .And. (cAliasQry)->&(cCHVC6I) == C6J->&(cCHVC6J)
			cFiltroPRD += " '" + C6J->C6J_IT + "',"
			C6J->( dbSkip() )
		End
	EndIf
	DBCloseArea("C6J")
	( cAliasQry )->( dbSkip() )
End

( cAliasQry )->( dbCloseArea())

Return