#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFSTB           
Gera o registro STB da DIEF-CE 
Registro tipo STB - Valores do ICMS-ST e FECOP-ICMS-ST a recolher

Um contribuinte  pode possuir nenhum ou vários registros.
A partir de Janeiro/2011, o contribuinte de Regime de Pagamento ME e EPP - optante do Simples Nacional  deverá obrigatoriamente informar  este registro

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  11/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFSTB( aWizard, cRegime, cJobAux )
Local cNomeReg	:= "STB"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro STB, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QrySTB( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
		
		cStrReg	:= cNomeReg
		cStrReg	+= TpICMSST( cAliasQry )												//Código do tipo de ICMS-ST  a recolher, conforme  a tabela 22.
		cStrReg	+= TAFDecimal( ( cAliasQry )->C3N_VLROBR, 13, 2, Nil)			//Valor do código do ICMS a recolher.
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
/*/{Protheus.doc} QrySTB             
Seleciona os dados para geração do registro STB 

@author David Costa
@since  11/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QrySTB( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""

cSelect	:= " SUM(C3N_VLROBR) C3N_VLROBR, C3E_CODIGO "
cFrom		:= RetSqlName("C3J")  + " C3J "
cFrom		+= " LEFT JOIN " + RetSqlName("C3N") + " C3N ON (C3J_ID = C3N_ID AND C3J_FILIAL = C3N_FILIAL AND C3N.D_E_L_E_T_ = '') "
cFrom		+= " LEFT JOIN " + RetSqlName("C3E") + " C3E ON (C3E_ID = C3N_CODOBR AND C3E.D_E_L_E_T_ ='') "
cWhere		:= " C3J.D_E_L_E_T_ = '' "
cWhere  	+= " AND C3J_FILIAL = '" + xFilial( "C3J" ) + "' "
cWhere		== " AND C3E_CODIGO IN ('001','002','007','008','009','999') "
cWhere		+= " AND C3J_DTINI BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' " 
cWhere		+= " AND C3J_DTFIN BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' " 
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
/*/{Protheus.doc} TpICMSST             
Código do tipo de ICMS-ST  a recolher, conforme  a tabela 22.

01	ICMS-ST a recolher nas entradas internas
02	Valor do Fecop-ICMS-ST das saídas internas
03	ICMS-ST a recolher das saidas internas
04	Valor do Fecop-ICMS-ST das entradas interestaduais
05	ICMS-ST a recolher das saidas interestaduais
06	Valor do Fecop-ICMS-ST das entradas internas

@author David Costa
@since  11/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TpICMSST( cAliasQry )

Local cTpICMSST	:= "00"

//ICMS DA SUBSTITUICAO TRIBUTARIA PELAS ENTRADAS
If(( cAliasQry )->C3E_CODIGO $ "001")
	cTpICMSST	= "01"

//ICMS DA SUBSTITUICAO TRIBUTARIA PELAS SAIDAS PARA O ESTADO
ElseIf(( cAliasQry )->C3E_CODIGO $ "002")
	cTpICMSST	= "03"

//ICMS DA SUBSTITUICAO TRIBUTARIA PELAS SAIDAS PARA OUTRO ESTADO
ElseIf(( cAliasQry )->C3E_CODIGO $ "999")
	cTpICMSST	= "05"

//VALOR DO FECOP-ICMS-ST DAS SAÍDAS INTERNAS
ElseIf(( cAliasQry )->C3E_CODIGO $ "007")
	cTpICMSST	= "02"

//VALOR DO FECOP-ICMS-ST DAS ENTRADAS INTERESTADUAIS
ElseIf(( cAliasQry )->C3E_CODIGO $ "008")
	cTpICMSST	= "04"

//VALOR DO FECOP-ICMS-ST DAS ENTRADAS INTERNAS
ElseIf(( cAliasQry )->C3E_CODIGO $ "009")
	cTpICMSST	= "06"
	
EndIf

Return( cTpICMSST )
