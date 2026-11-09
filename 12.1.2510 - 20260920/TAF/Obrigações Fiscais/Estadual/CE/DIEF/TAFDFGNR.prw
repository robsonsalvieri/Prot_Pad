#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFGNR           
Gera o registro GNR da DIEF-CE 
Registro tipo GNR - GNRE- Guia Nacional de Recolhimento Estadual.

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFGNR( aWizard, cRegime, cJobAux )
Local cNomeReg	:= "GNR"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro GNR, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QryGNR( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
	
		cStrReg	:= cNomeReg
		cStrReg	+= GetES(cAliasQry)
		cStrReg	+= GetIeDe(cAliasQry)
		cStrReg	+= PadR(TAFGetUF((cAliasQry)->C0R_UF), 2)													//Unidade da Federação  de origem
		cStrReg	+= PadR((cAliasQry)->C1V_CODIGO, 4)														//Número do banco arrecadador.
		cStrReg	+= PadR((cAliasQry)->C0R_CODAGE, 5)														//Número da agência arrecadadora
		cStrReg	+= PadR((cAliasQry)->C0R_DIGAGE, 2)														//Número do dígito da agência.
		cStrReg	+= PadR((cAliasQry)->C0R_CODAUT, 20)														//Número da autenticação mecânica  do banco.
		cStrReg	+= Iif(Empty((cAliasQry)->C0R_DTPGT), Replicate("0" ,8) , (cAliasQry)->C0R_DTPGT)	//Data do recolhimento.
		cStrReg	+= AllTrim((cAliasQry)->C6R_CODIGO)														//Código da receita
		cStrReg	+= (cAliasQry)->C0R_DTVCT																	//Data do vencimento.
		cStrReg	+= (cAliasQry)->ANO_PER + (cAliasQry)->MES_PER											//Período de referência
		cStrReg	+= TAFDecimal((cAliasQry)->C0R_VLRPRC, 13, 2, Nil)										//Valor principal.
		cStrReg	+= TAFDecimal((cAliasQry)->C0R_ATUMON, 13, 2, Nil)										//Valor da atualização  monetária.
		cStrReg	+= TAFDecimal((cAliasQry)->C0R_JUROS, 13, 2, Nil)										//Valor dos juros.
		cStrReg	+= TAFDecimal((cAliasQry)->C0R_MULTA, 13, 2, Nil)										//Valor da multa.
		cStrReg	+= TAFDecimal((cAliasQry)->C0R_VLDA, 13, 2, Nil)											//Valor Total.
		cStrReg	+= GetNumConv(cAliasQry)																		//Número do Convênio
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
/*/{Protheus.doc} QryGNR             
Seleciona os dados para geração do registro GNR 

@author David Costa
@since  30/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryGNR( cAliasQry, aWizard )

Local cMes		 	:= SubStr( DToS( aWizard[1][5] ), 5, 2)
Local cAno		 	:= SubStr( DToS( aWizard[1][5] ), 1, 4)
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

cSelect 	:= " C0R_UF, C1V_CODIGO, C0R_CODAGE, C0R_DIGAGE, C0R_CODAUT, C0R_DTPGT, C6R_CODIGO, "
cSelect 	+= " (SUBSTRING(C0R_PERIOD, 3, 4)) ANO_PER, (SUBSTRING(C0R_PERIOD, 1, 2)) MES_PER,  "
cSelect 	+= " C0R_DTVCT, C0R_PERIOD, C0R_VLRPRC, C0R_ATUMON, C0R_JUROS, C0R_MULTA, C0R_VLDA, C0R_CONVEN " 
cFrom   	:= RetSqlName("C0R") + " C0R "
cFrom   	+= " LEFT JOIN " + RetSqlName("C1V") + " C1V "
cFrom   	+= " 	ON C1V.D_E_L_E_T_ = '' "
cFrom   	+= " 		AND C1V_ID = C0R_CODBAN "
cFrom   	+= " LEFT JOIN " + RetSqlName("C6R") + " C6R "
cFrom   	+= " 	ON C6R.D_E_L_E_T_ = '' " 
cFrom   	+= " 		AND C6R_ID = C0R_CODREC  "
cWhere  	:= " C0R.D_E_L_E_T_ = '' "
cWhere  	+= " AND C0R_FILIAL = '" + xFilial( "C0R" ) + "' "
cWhere  	+= " AND SUBSTRING(C0R_PERIOD, 1, 2)	= '" + cMes + "' "
cWhere  	+= " AND SUBSTRING(C0R_PERIOD, 3, 4)	= '" + cAno + "' "
cWhere  	+= " AND C0R_CODDA = '1' "    

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
/*/{Protheus.doc} GetES
Se recolhimento em favor do Estado do Ceará, preencher com 'E'. Se
em favor de outros Estados, preencher com 'S'.

@author David Costa
@since 30/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetES( cAliasQry )

Local cES	:= ""

If(TAFGetUF((cAliasQry)->C0R_UF) == "CE")
	cES := "E"
Else
	cES := "S"
EndIf

Return( cES ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetIeDe
Inscrição Estadual na unidade da Federação destinatária do
estabelecimento substituto tributário.

@author David Costa
@since 30/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetIeDe( cAliasQry )

Local cIeDe	:= ""

If(TAFGetUF((cAliasQry)->C0R_UF) != "CE")
	
	DbSelectArea("C1E") 
	C1E->( DbSetOrder( 3 ) )
	
	If(C1E->(MsSeek( xFilial( "C1E" ) + cFilAnt )))
	
		DbSelectArea("C1F") 
		C1F->( DbSetOrder( 1 ) )
		
		If( C1F->(MsSeek( xFilial( "C1F" ) + C1E_ID + (cAliasQry)->C0R_UF)))
			cIeDe := AllTrim(C1F->C1F_IEST)
		EndIf
		
		DbCloseArea("C1F")
	EndIf
	
	DbCloseArea("C1E")	
Else
	cIeDe := " "
EndIf

cIeDe := PadR(cIeDe, 20)

Return( cIeDe ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNumConv
Número do Convênio ou Protocolo / Mercadorias. Preencher com o
conteúdo do Campo 15 da GNRE

@author David Costa
@since 30/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetNumConv( cAliasQry )

Local cNumConv	:= ""

If(!Empty((cAliasQry)->C0R_CONVEN))
	
	cNumConv := AllTrim((cAliasQry)->C0R_CONVEN)
Else
	cIeDe := " "
EndIf

cNumConv := PadR(cNumConv, 30)

Return( cNumConv )