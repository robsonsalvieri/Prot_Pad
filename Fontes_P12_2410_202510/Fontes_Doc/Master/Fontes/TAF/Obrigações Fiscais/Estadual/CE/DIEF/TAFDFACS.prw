#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFACS           
Gera o registro ACS da DIEF-CE 
Registro tipo ACS - Administradoras de Centros Comerciais, shoppings ou empreendimentos semelhantes

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFACS( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "ACS"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro ACS, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QryACS( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
	
		cStrReg	:= cNomeReg
		cStrReg	+= GetCNPJLoj( cAliasQry )										//CNPJ do lojista.
		cStrReg	+= PadR((cAliasQry)->C1H_IE, 20)								//CGF do lojista.
		cStrReg	+= PadR((cAliasQry)->C1H_NOME, 60)								//Nome ou Razão Social do lojista.
		cStrReg	+= GetTpFatu( cAliasQry )										//Tipo de faturamento
		cStrReg	+= TAFDecimal((cAliasQry)->T31_VLRFAT, 13, 2, Nil)			//Valor total do faturamento  do lojista
		cStrReg	+= TAFDecimal((cAliasQry)->T31_VLRDEB, 13, 2, Nil)			//Valor da "nota débito" do lojista	
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
/*/{Protheus.doc} QryACS             
Seleciona os dados de Administratores de Centros Comerciais, shoppings ou empreendimentos semelhantes para geração do registro ACS 

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryACS( cAliasQry, aWizard )

Local cMes		 	:= SubStr( DToS( aWizard[1][5] ), 5, 2)
Local cAno		 	:= SubStr( DToS( aWizard[1][5] ), 1, 4)
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

cSelect 	:= " T31_VLRFAT, T31_VLRDEB, C1H_NOME, C1H_IE, C1H_CNPJ, C1H_CPF, C1H_RAMO "
cFrom   	:= RetSqlName("T30") + " T30 "
cFrom   	+= " INNER JOIN " + RetSqlName("T31") + " T31 ON (T31.T31_ID = T30.T30_ID AND T31.T31_FILIAL = T30.T30_FILIAL AND T31.D_E_L_E_T_ = '') "
cFrom   	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON (C1H.C1H_ID = T31.T31_CODPAR AND C1H.C1H_FILIAL = T31.T31_FILIAL AND C1H.D_E_L_E_T_ = '') "
cWhere  	:= " T30.D_E_L_E_T_ = '' "
cWhere  	+= " AND T30.T30_FILIAL = '" + xFilial("T30") + "' "
cWhere  	+= " AND SUBSTRING(T30.T30_PERIOD, 1, 2)	= '" + cMes + "' "
cWhere  	+= " AND SUBSTRING(T30.T30_PERIOD, 3, 4)	= '" + cAno + "' "  

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
/*/{Protheus.doc} GetCNPJLoj             
Retorna o CNPJ ou CPF do Lojista 

@author David Costa
@since 03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetCNPJLoj( cAliasQry )

Local cDocLoj	:= ""

If( !Empty(( cAliasQry )->C1H_CNPJ) )
	cDocLoj := AllTrim(( cAliasQry )->C1H_CNPJ)
Else
	cDocLoj := AllTrim(( cAliasQry )->C1H_CPF)
EndIf

cDocLoj := PadR(cDocLoj, 14)

Return( cDocLoj )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpFatu             
Retorna o Tipo do Faturamento do Lojista 

@author David Costa
@since  03/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetTpFatu( cAliasQry )

Local cTpFatu	:= "0"

If( ( cAliasQry )->C1H_RAMO $ "1" )
	cTpFatu := "1"
ElseIf( ( cAliasQry )->C1H_RAMO $ "2|3|" )
	cTpFatu := "2"
EndIf

Return( cTpFatu ) 

 