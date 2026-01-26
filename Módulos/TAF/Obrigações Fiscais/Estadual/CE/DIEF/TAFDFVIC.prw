#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFVIC            
Gera o registro VIC da DIEF-CE 
Registro tipo VIC - Valores do ICMS a recolher dos contribuintes credenciados

Este registro substitui o antigo registro VIR. Nenhum ou vários registros por bloco de contribuinte.
A partir de Janeiro/2011, o contribuinte de Regime de Pagamento ME e EPP - optante do Simples Nacional  deverá obrigatoriamente 
informar  este registro.

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  11/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFVIC( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "VIC"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local cAliasQry	:= GetNextAlias()
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro VIC, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local nVlAntecip	:= 0
Local nVlDif		:= 0
Local nVlST		:= 0

Begin Sequence

	QryVIC( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
		
		cStrReg	:= cNomeReg
		cStrReg	+= GetTpICMS( cAliasQry )												//Código do ICMS dos contribuintes credenciados conforme  tabela 24.
		cStrReg	+= TAFDecimal( ( cAliasQry )->C2Z_VLOBRI, 13, 2, Nil)				//Valor do código do ICMS a recolher.
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
/*/{Protheus.doc} QryVIC             
Seleciona os dados para geração do registro VIC 

@author David Costa
@since  11/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryVIC( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""

cSelect	:= " SUM(C2Z_VLOBRI) C2Z_VLOBRI, C3E_CODIGO "
cFrom		:= RetSqlName("C2S")  + " C2S "
cFrom		+= " LEFT JOIN " + RetSqlName("C2Z") + " C2Z ON (C2S_ID = C2Z_ID AND C2S_FILIAL = C2Z_FILIAL AND C2Z.D_E_L_E_T_ = '') "
cFrom		+= " LEFT JOIN " + RetSqlName("C3E") + " C3E ON (C3E_ID = C2Z_CODOR AND C3E.D_E_L_E_T_ ='') "
cWhere		:= " C2S.D_E_L_E_T_ = '' "
cWhere  	+= " AND C2S_FILIAL = '" + xFilial( "C2S" ) + "' "
cWhere		+= " AND C3E_CODIGO IN ('003','005','010') "
cWhere		+= " AND C2S_DTINI BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' " 
cWhere		+= " AND C2S_DTFIN BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' " 
cGroupBy  	:= " C3E_CODIGO "

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
/*/{Protheus.doc} GetTpICMS             
Código do ICMS dos contribuintes credenciados conforme  tabela 24.

01	Valor do ICMS antecipado a recolher
02	Valor do ICMS Diferencial de Alíquota a recolher
03	Valor do ICMS Substituição Tributária nas entradas a recolher

@author David Costa
@since  11/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetTpICMS( cAliasQry )

Local cTpICMS	:= "00"

//ANTECIPACAO TRIBUTARIA
If(( cAliasQry )->C3E_CODIGO $ "005")
	cTpICMS	= "01"

//ANTECIPACAO DO DIFERENCIAL DE ALIQUOTAS DO ICMS
ElseIf(( cAliasQry )->C3E_CODIGO $ "003")
	cTpICMS	= "02"

//VALOR DO ICMS ST NAS ENTRADAS A RECOLHER (CONTRIBUINTE CREDENCIADO)
ElseIf(( cAliasQry )->C3E_CODIGO $ "010")
	cTpICMS	= "03"
	
EndIf

Return( cTpICMS )