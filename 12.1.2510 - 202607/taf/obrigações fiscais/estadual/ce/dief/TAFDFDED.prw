#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFDED           
Gera o registro DED da DIEF-CE 
Registro tipo DED - Deduções

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFDED( aWizard, cRegime, cJobAux )
Local cNomeReg	:= "DED"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro DED, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence
	
	QryDED( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
		cStrReg	:= cNomeReg
		cStrReg	+= GetEspe(cAliasQry)										//Código da espécie de dedução , vide tabela 10.
		cStrReg	+= TAFDecimal((cAliasQry)->C2T_VLRAJU, 13, 2, Nil)	//Valor da dedução
		cStrReg	+= CRLF
		
		( cAliasQry )->( dbSkip() )
		
		AddLinDIEF( )
		
		WrtStrTxt( nHandle, cStrReg )
	EndDo
	
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
/*/{Protheus.doc} QryDED             
Seleciona os dados para geração do registro DED 

@author David Costa
@since  09/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryDED( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

cSelect 	:= " CHY_CODIGO, C2T_VLRAJU "
cFrom   	:= RetSqlName("C2S") + " C2S "
cFrom   	+= " JOIN " + RetSqlName("C2T") + " C2T "
cFrom   	+= " 	JOIN " + RetSqlName("CHY") + " CHY "
cFrom   	+= " 		ON CHY_ID = C2T_IDSUBI "
cFrom   	+= " 		AND CHY.D_E_L_E_T_ = '' "
cFrom   	+= " 	ON C2T_ID = C2S_ID "
cFrom   	+= " 	AND C2T_FILIAL = C2S_FILIAL "
cFrom   	+= " 	AND C2T.D_E_L_E_T_ = '' "
cWhere  	:= " C2S_DTINI >= '" +  DToS(dDataIni) + "' "
cWhere  	+= " AND C2S_DTFIN <= '" +  DToS(dDataFim) + "' "
cWhere  	+= " AND C2S_FILIAL = '" + xFilial( "C2S" ) + "' "
cWhere  	+= " AND C2S.D_E_L_E_T_ = '' "
cWhere  	+= " AND CHY_CODIGO IN ('01501', '01502', '01503', '01504') " 

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
/*/{Protheus.doc} GetEspe             
Código da espécie de dedução , vide tabela 10.

01	Dedução referente ao FDI - provin
02	Dedução referente ao FECOP do ICMS Normal
03	Incentivo Fiscal
04	FDI - Transferência de Crédito

@author David Costa
@since 09/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetEspe( cAliasQry )

Local cEspe	:= ""

Do Case
	//01	Dedução referente ao FDI - provin
	Case (cAliasQry)->CHY_CODIGO == "01501"
		cEspe := "01"
	//02	Dedução referente ao FECOP do ICMS Normal
	Case (cAliasQry)->CHY_CODIGO == "01502"
		cEspe := "02"
	//03	Incentivo Fiscal
	Case (cAliasQry)->CHY_CODIGO == "01503"
		cEspe := "03"
	//04	FDI - Transferência de Crédito
	Case (cAliasQry)->CHY_CODIGO == "01504"
		cEspe := "04"
	OtherWise
		cEspe := "00" 
EndCase

Return( cEspe )