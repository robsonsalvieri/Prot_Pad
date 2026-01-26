#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFDCE           
Gera o registro DCE da DIEF-CE 
Registro tipo DCE - Documentos cancelados, Mapas Resumo de ECF e outros documentos autorizados por AIDF

Regime Normal - Informar quando houver emissão de documentos  fiscais autorizados  pelo fisco, mas não obrigados  a escrituração  e documentos  fiscais cancelados.
Regime de pagamento  for ME. MS, OUTROS  ou ESPECIAL  - informar todos os documentos  fiscais emitidos e/ou cancelados,  autorizados pela Sefaz.

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFDCE( aWizard, cRegime, cJobAux )
Local cNomeReg	:= "DCE"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro DCE, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QryDCE( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )

		If GeraDCE(cAliasQry)
			cStrReg	:= cNomeReg
			cStrReg	+= GetTpDisp( cAliasQry )												//Tipo de dispositivo  autorizado
			cStrReg	+= GetSitdoc(  cAliasQry )												//Situação dos documentos, vide tabela 06.
			cStrReg	+= StrZero(Val((cAliasQry)->C20_NUMDOC), 10)							//Número inicial dos documentos  fiscais autorizados
			cStrReg	+= 	GetNumFim( cAliasQry ) 												//Número final dos documentos  fiscais autorizados
			cStrReg	+= StrZero(Val((cAliasQry)->C6V_NDIINI), 10)							//Número inicial do dispositivo  autorizado
			cStrReg	+= GetFimAIDF( cAliasQry ) 												//Número final do dispositivo  autorizado
			cStrReg	+= PadR(Val((cAliasQry)->C01_CODIGO), 2)								//Modelo dos documentos  fiscais autorizados
			cStrReg	+= PadR((cAliasQry)->C20_SERIE, 5)										//Série dos documentos  fiscais autorizados
			cStrReg	+= PadR((cAliasQry)->C20_SUBSER, 5)									//SubSérie  dos documentos  fiscais autorizados
			cStrReg	+= StrZero(Val((cAliasQry)->C0T_NUNAUT), 11)							//Número da AIDF dos documentos  fiscais autorizados.
			cStrReg	+= CRLF
			
			AddLinDIEF( )
			
			WrtStrTxt( nHandle, cStrReg )
		
		EndIf
		
		( cAliasQry )->( dbSkip() )
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
/*/{Protheus.doc} QryDCE             
Seleciona os dados para geração do registro DCE 

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryDCE( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

cSelect 	:= " C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_NDOCF, C20_DTDOC, C20_DTES, "
cSelect 	+= " C01_CODIGO, C0T_NUNAUT, C6V_NDIINI, C6V_NDIFIN, C6C_CODIGO, C02_CODIGO "
cFrom   	:= RetSqlName("C20") + " C20 "
cFrom   	+= " LEFT JOIN " + RetSqlName("C01") + " C01 ON (C01_ID = C20_CODMOD AND C01.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C0T") + " C0T ON (C0T_ID = C20_AIDF AND C0T_FILIAL = C20_FILIAL  AND C0T.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C6V") + " C6V ON (C6V_ID = C0T_ID AND C6V_FILIAL = C0T_FILIAL AND C6V.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C6C") + " C6C ON (C0T_CODISP = C6C_ID AND C6C.D_E_L_E_T_ = '') "
cFrom   	+= " LEFT JOIN " + RetSqlName("C02") + " C02 ON (C20_CODSIT = C02_ID AND C02.D_E_L_E_T_ = '') "
cWhere  	:= " C20.D_E_L_E_T_ = '' "
cWhere  	+= " AND C20_FILIAL = '" + xFilial( "C20" ) + "' "
cWhere  	+= " AND ( "
cWhere  	+= " 		(C20_DTDOC BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' AND C20_INDOPE = 1 )  "		//Lançamentos de Saída
cWhere  	+= " 		OR (C20_DTES BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' AND C20_INDOPE = 0 ) "		//Lançamentos de Entrada
cWhere  	+= " ) "  
cWhere  	+= " AND C02_CODIGO IN ('02', '04') "
cWhere  	+= " AND C01_CODIGO IN ('01', '1A', '02', '04', '06', '07', '08', '09', '10', '11', '13', '14', '15', '16', "
cWhere  	+= " '17', '18', '20', '21', '22', '23', '24', '25', '36', '37', '38', '39', '55', '57', '96') "

cSelect 	:= "%" + cSelect 		+ "%"
cFrom   	:= "%" + cFrom   		+ "%"
cWhere  	:= "%" + cWhere   	+ "%"

BeginSql Alias cAliasQry

	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpDisp             
Espécie de dispositivo  autorizado,  vide tabela 05.

01	Blocos
02	Formulário contínuo
03	Formulário de segurança
04	Jogos soltos
05	ECF
06	Nota Fiscal Eletrônica
07	Conhecimento de Transporte Eletrônico

@author David Costa
@since  10/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetTpDisp( cAliasQry ) 		

Local cTpDisp	:= "00"

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
ElseIf(AllTrim((cAliasQry)->C6C_CODIGO) == "02" .Or. AllTrim((cAliasQry)->C01_CODIGO) == "55")
	cTpDisp := "06"
ElseIf(AllTrim((cAliasQry)->C6C_CODIGO) == "07" .Or. AllTrim((cAliasQry)->C01_CODIGO) == "57")
	cTpDisp := "07"
EndIf

Return( cTpDisp )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSitdoc             
Situação dos documentos, vide tabela 06.

1	Emitido
2	Cancelado

@author David Costa
@since  10/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetSitdoc( cAliasQry ) 		

Local cSitdoc	:= "0"

If(AllTrim((cAliasQry)->C02_CODIGO) $ "02|04")
	cSitdoc := "2"
ElseIf(AllTrim((cAliasQry)->C02_CODIGO) == "00")
	cSitdoc := "1"
EndIf

Return( cSitdoc )

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraDCE             
Verifica se esta nota deverá gerar o registro DCE

@author David Costa
@since  20/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraDCE( cAliasQry ) 	

Local lGeraDCE	:= .F.

If(!Empty((cAliasQry)->C0T_NUNAUT) .Or. (cAliasQry)->C01_CODIGO $ "|55|57" )
	lGeraDCE := .T.
EndIf

Return(lGeraDCE)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumFim             
Retorno o numero final do documento, caso esteja em branco retorna o numero inicial

@author David Costa
@since  20/11/2015
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
/*/{Protheus.doc} GetFimAIDF             
Retorna o numero Final autorizado pela AIDF

@author David Costa
@since  20/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetFimAIDF( cAliasQry, cRegime ) 

Local cNumFim	:= ""

If(!((cAliasQry)->C01_CODIGO $ "55"))
	cNumFim := StrZero(Val((cAliasQry)->C6V_NDIFIN), 10)	
Else
	cNumFim := StrZero(0, 10)	
EndIf

Return(cNumFim)