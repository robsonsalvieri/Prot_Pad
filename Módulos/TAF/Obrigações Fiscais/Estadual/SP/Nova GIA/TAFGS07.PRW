#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGS07

Rotina de geração do registro CR=07 da GIA-SP - Detalhes do Pagamento

@Param cCNAE		->	CNAE da Filial que de geração
		cCNPJ   	->	Cnpj da Filial que de geração
		cInscEst  	->	Inscrição Estadual da Filial que de geração
		aWizard	->	Array com as informacoes da Wizard
		cFilSel	->	Filiais selecionadas para o processamento
		cJobAux	->	Responsável pelo controle de término do Bloco - Multi Thread

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFGS07( aWizard, cFilSel, cJobAux, cInscEst, cCNPJ, cCNAE, cMesRef, cAnoRef, lSomaFil, cIn )

Local oError	 := ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )
Local cREG		 := "CR07" + cInscEst
Local cStrTxt    := ""
Local cTxtSys    := CriaTrab( , .F. ) + ".TXT"
Local nHandle    := MsFCreate( cTxtSys )
Local cMesAnoRef := Alltrim(aWizard[1][9]) + Alltrim(aWizard[1][11])
Local nQtd07     := 0
Local cAliasQry  := GetNextAlias()
Local lFound     := .T.

Default cMesRef		:= ""
Default	cAnoRef		:= ""
Default	lSomaFil	:= .F.
Default	cIn			:= ""

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

QryCR07(cMesAnoRef, cFilSel, cAliasQry, cIn)

While ( cAliasQry )->( !Eof() )
	
	cStrTxt:= "07"
	cStrTxt+= alltrim(( cAliasQry )->OPERACAO)
	cStrTxt+= xConvGIA( Iif( alltrim(( cAliasQry )->OPERACAO) == '0',( cAliasQry )->C2Z_VLOBRI, ( cAliasQry )->C3N_VLROBR  ), 15)
	cStrTxt+= Iif(alltrim(( cAliasQry )->OPERACAO) == '0',( cAliasQry )->C2Z_DTVCTO, ( cAliasQry )->C3N_DTDOC  )
	cStrTxt+= CRLF
	
	( cAliasQry )->( dbSkip() )
	nQtd07++
	
	WrtStrTxt( nHandle, cStrTxt )
	
End

( cAliasQry )->( dbCloseArea())

cStrTxt:= "QTD" + STRZERO(nQtd07,4)
WrtStrTxt( nHandle, cStrTxt )

GerTxtGIA( nHandle, cTXTSys, cReg )

Recover
	lFound := .F.

End Sequence

//Tratamento para ocorrência de erros durante o processamento
ErrorBlock( oError )

If !lFound
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

Else
	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()

EndIf

Return()


//---------------------------------------------------------------------
/*/{Protheus.doc} QueryCR07

Efetua query que busca os registros referentes aos detalhes do pagamento

@Param cMesAnoRef-> Ano e mes referencia 
		cFilSel -> Filial selecionada

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------

Function QryCR07(cMesAnoRef, cFilSel, cAliasQry, cIn)
Local cSelect := ""
Local cSelect2:= ""
Local cFrom   := ""
Local cFrom2  := ""
Local cWhere	:= ""
Local cWhere2	:= ""

Default	cIn	:= ""

cSelect := "'0' OPERACAO, C2Z_VLOBRI,C2Z_DTVCTO, C2Z_VLOBRI C3N_VLROBR, C2Z_DTVCTO C3N_DTDOC "

cFrom := RetSqlName("C2Z")+ " C2Z "
cFrom += "INNER JOIN " + RetSqlName("C2S") + " C2S ON C2Z.C2Z_FILIAL = C2S.C2S_FILIAL AND C2Z.C2Z_ID = C2S.C2S_ID "

cWhere := "    C2S_FILIAL IN ("+"'"+cFilSel+"'"+ Iif(!Empty(cIn),", "+cIn ,"")+") "
cWhere += "AND C2Z_MESREF = '" + ALLTRIM(cMesAnoRef) + "' "
cWhere += "AND C2Z.D_E_L_E_T_ = '' AND C2S.D_E_L_E_T_ = '' "

cSelect2 := "'1' OPERACAO, C3N_VLROBR C2Z_VLOBRI,C3N_DTDOC C2Z_DTVCTO,C3N_VLROBR,C3N_DTDOC "

cFrom2 := RetSqlName("C3N")+ " C3N "
cFrom2 += "INNER JOIN " + RetSqlName("C3J") + " C3J ON C3N.C3N_FILIAL = C3J.C3J_FILIAL AND C3N.C3N_ID = C3J.C3J_ID "

cWhere2 := "    C3J_FILIAL IN ("+"'"+cFilSel+"'"+ Iif(!Empty(cIn),", "+cIn ,"")+") "
cWhere2 += "AND C3N_MESREF = '" + ALLTRIM(cMesAnoRef) + "' "
cWhere2 += "AND C3N.D_E_L_E_T_ = '' AND C3J.D_E_L_E_T_ = '' "

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

cSelect2  := "%" + cSelect2  + "%"
cFrom2    := "%" + cFrom2    + "%"
cWhere2   := "%" + cWhere2   + "%"

BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
		
	UNION
	
	SELECT
		%Exp:cSelect2%
	FROM
		%Exp:cFrom2%
	WHERE
		%EXP:cWhere2%
		
EndSql
//Aviso("Query - Testes: CR=07", AllTrim(GetLastQuery()[2]),{"OK"},3)  

Return
