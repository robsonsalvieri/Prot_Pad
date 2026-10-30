#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFINV             
Gera o registro INV da DIEF-CE 
Registro tipo INV - Detalhes do Inventário

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFINV( aWizard, cRegime, cJobAux )

Local cAliasQry	:= GetNextAlias()
Local cNomeReg	:= "INV"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro INV, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QryINV( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While !( cAliasQry )->( Eof() )

		cStrReg	:= cNomeReg
		cStrReg	+= PadR((cAliasQry)->C1L_CODIGO, 30)							//Código do produto ou serviço
		cStrReg	+= TAFDecimal((cAliasQry)->C5B_QTD, 17, 8, Nil)				//Quantidade existente no estoque na unidade especificada no registro PRD. 
		cStrReg	+= TAFDecimal((cAliasQry)->C5B_VUNIT, 17, 8, Nil)			//Valor unitário do produto na unidade padrão
		cStrReg	+= GetCond((cAliasQry)->C5B_INDPRO)							//Condição  de posse da mercadoria:
		cStrReg	+= GetSitProd((cAliasQry)->C2M_CODIGO)							//situação da mercadoria  ou produto inventariado
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
/*/{Protheus.doc} QryINV             
Seleciona os Detalhes  do Inventário

@author David Costa
@since  30/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------

Static Function QryINV( cAliasQry, aWizard )

Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cGroupBy  	:=	""
Local cTabela1	:=	""
Local cTabela2	:=	""
Local cTabela3	:=	""
Local cTabela4	:=	""

cTabela1 := RetSqlName("C1L")
cTabela2 := RetSqlName("C5B")
cTabela3 := RetSqlName("C5A")
cTabela4 := RetSqlName("C2M")

//Gerar Inventario
If( aWizard[1][4] == "3 - Inventário" )

	cSelect 	:= " C1L.C1L_CODIGO, C5B.C5B_QTD, C5B.C5B_VUNIT, C5B.C5B_INDPRO, C2M.C2M_CODIGO "
	cFrom   	:= cTabela1 + " C1L "
	cFrom   	+= " INNER JOIN " + cTabela2 + " C5B ON (C1L.C1L_FILIAL = C5B.C5B_FILIAL AND C1L.C1L_ID = C5B.C5B_CODITE AND C5B.D_E_L_E_T_= '') "
	cFrom   	+= " INNER JOIN " + cTabela3 + " C5A ON (C5A.C5A_FILIAL = C5B.C5B_FILIAL AND C5A.C5A_ID = C5B.C5B_ID AND C5A.D_E_L_E_T_= '') "
	cFrom		+= " LEFT JOIN " + cTabela4 + " C2M ON (C1L.C1L_TIPITE = C2M.C2M_ID AND C2M.D_E_L_E_T_ = '') "
	cWhere  	:= " C1L.D_E_L_E_T_= '' " 
	cWhere  	+= " AND C5A.C5A_FILIAL = '" + xFilial( "C5A" ) + "' "
	cWhere  	+= " AND C5A.C5A_DTINV BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "
	cGroupBy	:= " C1L.C1L_CODIGO, C5B.C5B_QTD, C5B.C5B_VUNIT, C5B.C5B_INDPRO, C2M.C2M_CODIGO "

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
/*/{Protheus.doc} GetCond             
Condição  de posse da mercadoria:
1 - pertencente  ao estabelecimento e em seu poder
2 - pertencente  ao estabelecimento e em poder de terceiros
3 - pertencente  a terceiros em poder do estabelecimento 

@author David Costa
@since  30/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------

Static Function GetCond( cC5B_INDPRO )

Local cCond	:= "0"

If( cC5B_INDPRO == '0' )
	cCond := "1"
ElseIf( cC5B_INDPRO == '1' )
	cCond := "2"
ElseIf( cC5B_INDPRO == '2' )
	cCond := "3"
EndIf

Return( cCond ) 
 
 //-------------------------------------------------------------------
/*/{Protheus.doc} GetSitProd             
Especificação da situação da mercadoria  ou produto inventariado, conforme  tabela 11 (situação das mercadorias  / produtos inventariados).

01	Mercadoria p/revenda
02	Matéria Prima
03	Produto em elaboração
04	Produto acabado
05	Material de acondicionamento e embalagem
06	Mercadoria recebida em consignação
07	Outras mercadorias ou produtos

@author David Costa
@since  30/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------

Static Function GetSitProd( cC2M_CODIGO )

Local cSitProd	:= "00"

If( cC2M_CODIGO == "00" )
	cSitProd := "01"
ElseIf( cC2M_CODIGO == "01" )
	cSitProd := "02"
ElseIf( cC2M_CODIGO == "03" )
	cSitProd := "03"
ElseIf( cC2M_CODIGO == "04" )
	cSitProd := "04"
ElseIf( cC2M_CODIGO == "02" )
	cSitProd := "05"
ElseIf( cC2M_CODIGO == "12" )
	cSitProd := "06"
ElseIf( cC2M_CODIGO == "99" )
	cSitProd := "07"
EndIf

Return( cSitProd ) 
