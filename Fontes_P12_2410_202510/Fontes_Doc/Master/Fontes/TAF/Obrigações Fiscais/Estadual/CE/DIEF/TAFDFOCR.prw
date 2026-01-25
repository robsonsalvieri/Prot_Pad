#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFOCR            
Gera o registro OCR da DIEF-CE 
Registro tipo OCR - Outros Créditos

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  03/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFOCR( aWizard, cRegime, cJobAux )
Local cNomeReg	:= "OCR"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro OCR, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})
Local lError		:= .F.

Begin Sequence

	QryOCR( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
	
		cStrReg	:= cNomeReg
		cStrReg	+= GetEspe(cAliasQry)										//Código da espécie do crédito
		cStrReg	+= TAFDecimal((cAliasQry)->C2T_VLRAJU, 13, 2, Nil)		//Valor do crédito
		cStrReg	+= GetDesc((cAliasQry))										//Descrição  de outro crédito
		cStrReg	+= CRLF

		AddLinDIEF( )
	
		WrtStrTxt( nHandle, cStrReg )
		
		lError := lError .Or. TAFDFDAE( nHandle, cAliasQry )
		
		( cAliasQry )->( dbSkip() )
	EndDo
	
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
/*/{Protheus.doc} QryOCR             
Seleciona os dados para geração do registro OCR 

@author David Costa
@since  03/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QryOCR( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""

cSelect 	:= " CHY_CODIGO, C2T_VLRAJU, C2T.R_E_C_N_O_ REC, C2T_ID, C2T_CODAJU "
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
cWhere  	+= " AND CHY_CODIGO IN ('01505', '01506', '01507', '01508', '01509', '01510', '01511', "
cWhere  	+= " '01512', '01513', '01514', '01515', '01516', '01517', '00718', '00205') "  

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
Código da espécie do crédito, vide tabela 08.

01	Crédito Presumido
02	Crédito Antecipado
03	Crédito Diferencial de Alíquota
04	Crédito Transferência de Crédito
05	Crédito bens de Ativo Imobilizado
06	Crédito Restituição de Indébito
07	Crédito ICMS a Mais ou em Duplicidade
08	Crédito ICMS Importação Diferido
09	Crédito decorrente de Auto de Infração
11	Estorno débito reversão de Reserva de Transferência
12	Saldo credor periodo anterior
15	Créditos extemporâneos
16	Saldo de ICMS Antecipado - EPP / ME
91	Crédito Outros
92	Estorno Débito Outros
 

@author David Costa
@since 03/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetEspe( cAliasQry )

Local cEspe	:= ""

Do Case
	//01	Crédito Presumido
	Case (cAliasQry)->CHY_CODIGO == "01505"
		cEspe := "01"
	//02	Crédito Antecipado
	Case (cAliasQry)->CHY_CODIGO == "01506"
		cEspe := "02"
	//05	Crédito bens de Ativo Imobilizado
	Case (cAliasQry)->CHY_CODIGO == "01507"
		cEspe := "05"
	//06	Crédito Restituição de Indébito
	Case (cAliasQry)->CHY_CODIGO == "01508"
		cEspe := "06"
	//07	Crédito ICMS a Mais ou em Duplicidade
	Case (cAliasQry)->CHY_CODIGO == "01509"
		cEspe := "07"
	//08	Crédito ICMS Importação Diferido
	Case (cAliasQry)->CHY_CODIGO == "01510"
		cEspe := "08"
	//09	Crédito decorrente de Auto de Infração
	Case (cAliasQry)->CHY_CODIGO == "01511"
		cEspe := "09"
	//11	Estorno débito reversão de Reserva de Transferência
	Case (cAliasQry)->CHY_CODIGO == "01512"
		cEspe := "11"
	//12	Saldo credor periodo anterior
	Case (cAliasQry)->CHY_CODIGO == "01513"
		cEspe := "12"
	//15	Créditos extemporâneos
	Case (cAliasQry)->CHY_CODIGO == "01514"
		cEspe := "15"
	//16	Saldo de ICMS Antecipado - EPP / ME
	Case (cAliasQry)->CHY_CODIGO == "01515"
		cEspe := "16"
	//91	Crédito Outros
	Case (cAliasQry)->CHY_CODIGO == "01516"
		cEspe := "91"
	//92	Estorno Débito Outros
	Case (cAliasQry)->CHY_CODIGO == "01517"
		cEspe := "92"
	//03	Crédito Diferencial de Alíquota
	Case (cAliasQry)->CHY_CODIGO == "00718"
		cEspe := "03"
	//04	Crédito Transferência de Crédito
	Case (cAliasQry)->CHY_CODIGO == "00205"
		cEspe := "04"
	OtherWise
		cEspe := "00" 
EndCase

Return( cEspe )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDesc             
Retorna a descrição  de outro crédito.

@author David Costa
@since 14/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function GetDesc( cAliasQry )

Local cDesc	:= ""

DbSelectArea("C2T")
C2T->( MsGoto( (cAliasQry)->REC ) )
cDesc := PadR(C2T->C2T_AJUCOM, 100)
DbCloseArea("C2T")

Return( cDesc )