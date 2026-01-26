#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFPRD             
Gera o registro PRD da DIEF-CE 
Registro tipo PRD - Produtos / Serviços

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  17/07/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFPRD( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "PRD"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError 	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro PRD, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QryPRD( cAliasQry, aWizard, cRegime, cJobAux )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )
	
		cStrReg	:= cNomeReg
		cStrReg	+= PadR((cAliasQry)->C1L_CODIGO, 30)						//Código do produto ou serviço
		cStrReg	+= PadR((cAliasQry)->C1L_DESCRI, 60) 						//Descrição do produto ou serviço.
		cStrReg	+= PadR((cAliasQry)->C1J_CODIGO, 2)						//Unidade de Medida
		cStrReg	+= GetTpProd(cAliasQry)										//Tipo produto/Serviço
		cStrReg	+= PadR((cAliasQry)->C0A_CODIGO, 20)						//Codigo NCM
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
/*/{Protheus.doc} QryPRD             
Seleciona os produto para geração do registro PRD

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------

Static Function QryPRD( cAliasQry, aWizard, cRegime )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""

//Gerar Inventario
If( aWizard[1][4] == "3 - Inventário" )

	cSelect 	:= " C1L_CODIGO, C1L_DESCRI, C1J_CODIGO,  C2M_CODIGO, C0A_CODIGO "
	
	cFrom   	:= RetSqlName("C1L") + " C1L "
	
	cFrom   	+= " LEFT JOIN " + RetSqlName("C5B") + " C5B ON (C1L.C1L_FILIAL = C5B.C5B_FILIAL AND C1L.C1L_ID = C5B.C5B_CODITE AND C5B.D_E_L_E_T_= '') "
	cFrom   	+= " LEFT JOIN " + RetSqlName("C5A") + " C5A ON (C5A.C5A_FILIAL = C5B.C5B_FILIAL AND C5A.C5A_ID = C5B.C5B_ID AND C5A.D_E_L_E_T_= '') "
	cFrom		+= " LEFT JOIN " + RetSqlName("C1J") + " C1J ON (C1J.C1J_ID = C1L.C1L_UM AND C1J.C1J_FILIAL = C1L.C1L_FILIAL AND C1J.D_E_L_E_T_ = '') "
	cFrom		+= " LEFT JOIN " + RetSqlName("C2M") + " C2M ON (C1L.C1L_TIPITE = C2M.C2M_ID AND C2M.D_E_L_E_T_ = '') "
	cFrom		+= " LEFT JOIN " + RetSqlName("C0A") + " C0A ON (C1L.C1L_CODNCM = C0A.C0A_ID AND C0A.D_E_L_E_T_ = '') "
	
	cWhere  	:= " C1L.D_E_L_E_T_= '' "
	cWhere  	+= " AND C5A.C5A_FILIAL = '" + xFilial( "C5A" ) + "' "
	cWhere  	+= " AND C5A.C5A_DTINV BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "  
	
	cGroupBy	:= " C1L_CODIGO, C1L_DESCRI, C1J_CODIGO, C2M_CODIGO, C0A_CODIGO "
Else
	cSelect 	:= " C1L_CODIGO, C1L_DESCRI, C1J_CODIGO,  C2M_CODIGO, C0A_CODIGO "
	
	cFrom   	:= RetSqlName("C1L") + " C1L "
	
	cFrom		+= " LEFT JOIN " + RetSqlName("C1J") + " C1J ON (C1J.C1J_ID = C1L.C1L_UM AND C1J.C1J_FILIAL = C1L.C1L_FILIAL AND C1J.D_E_L_E_T_ = '') "
	cFrom		+= " LEFT JOIN " + RetSqlName("C2M") + " C2M ON (C1L.C1L_TIPITE = C2M.C2M_ID AND C2M.D_E_L_E_T_ = '') "
	cFrom		+= " LEFT JOIN " + RetSqlName("C0A") + " C0A ON (C1L.C1L_CODNCM = C0A.C0A_ID AND C0A.D_E_L_E_T_ = '') "
	
	cWhere  	:= " C1L.D_E_L_E_T_= '' "
	cWhere  	+= " AND C1L.C1L_FILIAL = '" + xFilial( "C1L" ) + "' "
	cWhere  	+= " AND C1L_ID IN (" + GetFiltroPRD(aWizard, cRegime) + ") "
	
	cGroupBy	:= " C1L_CODIGO, C1L_DESCRI, C1J_CODIGO, C2M_CODIGO, C0A_CODIGO "
EndIf

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

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpProd             
Retorna o tipo do produto/Serviço Conforme esperado pela DIEF-CE

Tipo do produto/serviço:
1 - Mercadoria
2 - Serviço com incidência de ICMS
3 - Serviço sem incidência de ICMS

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------

Static Function GetTpProd( cAliasQry )

Local cTipoProd	:= ""

If((cAliasQry)->C2M_CODIGO == "11")
	cTipoProd	:= "3"
ElseIf((cAliasQry)->C2M_CODIGO == "09")
	cTipoProd	:= "2"
Else
	cTipoProd	:= "1"
EndIf

Return ( cTipoProd )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFiltroPRD             
Retorno o ID dos produtos que deverão ser gerados no arquivo

@author David Costa
@since  11/12/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------

Static Function GetFiltroPRD( aWizard, cRegime )

Local cFiltroPRD	:=	""

GetPRDDOC( @cFiltroPRD, aWizard, cRegime )
GetPRDCFC( @cFiltroPRD, aWizard, cRegime )

//Remove a ultima virgula
If(!Empty(cFiltroPRD))
	cFiltroPRD := Substr(cFiltroPRD, 1, Len(cFiltroPRD)-1)
Else
	cFiltroPRD := "''"
EndIf

Return ( cFiltroPRD )

