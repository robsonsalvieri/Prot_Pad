#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFEST             
Gera o registro EST da DIEF-CE 
Registro tipo EST - Registro de totalização de inventário

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFEST( aWizard, cRegime, cJobAux )

Local cNomeReg	:= "EST"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError	:= ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro EST, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	cStrReg	:= cNomeReg
	cStrReg	+= TAFDecimal(GetVEsT( aWizard ), 13, 2, Nil )									//Valor total do inventário
	cStrReg	+= CRLF
	
	AddLinDIEF( )
	
	WrtStrTxt( nHandle, cStrReg )
		
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
/*/{Protheus.doc} GetVEsT             
Seleciona o valor do inventario do periodo

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------

Static Function GetVEsT( aWizard )

Local cAliasQry	:= GetNextAlias()
Local nVEsT		:= 0
Local dDataIni 	:= aWizard[1][5]
Local dDataFim	:= aWizard[1][6]
Local cSelect		:=	""
Local cFrom		:=	""
Local cWhere		:=	""
Local cTabela1	:=	""

cTabela1 := RetSqlName("C5A")

cSelect 	:= " C5A.C5A_VINV "
cFrom   	:= cTabela1 + " C5A "
cWhere  	:= " C5A.D_E_L_E_T_= '' " 
cWhere  	+= " AND C5A.C5A_FILIAL = '" + xFilial( "C5A" ) + "' "
cWhere  	+= " AND C5A.C5A_DTINV BETWEEN '" + DToS( dDataIni ) + "' AND '" + DToS( dDataFim ) + "' "

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

DbSelectArea(cAliasQry) 
nVEsT := (cAliasQry)->C5A_VINV

If( nVEsT < 0)
	AddLogDIEF( "Registro EST: O valor informado no estoque está inválido")
EndIf

(cAliasQry)->(dbclosearea())

Return ( nVEsT )
 