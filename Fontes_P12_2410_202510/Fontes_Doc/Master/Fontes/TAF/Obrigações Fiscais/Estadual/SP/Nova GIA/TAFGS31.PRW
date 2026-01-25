#Include "Protheus.ch"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGS31

Rotina de geração do registro CR=31 da GIA-SP - Registros de EXPORTAÇÃO

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
Function TAFGS31( aWizard, cFilSel, cJobAux, cInscEst, cCNPJ, cCNAE, cMesRef, cAnoRef, lSomaFil, cIn  )
Local oError	:=	ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )
Local cREG		:= "CR31" + cInscEst
Local cStrTxt	:= ""
Local cTxtSys	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle	:= MsFCreate( cTxtSys )
Local cAnoMesRef:= Alltrim (aWizard[1][11]) + Alltrim(aWizard[1][9])
Local cAliasQry	:= GetNextAlias()
Local nQtd31   	:= 0
Local lFound   	:= .T.
Local aReg		:= {}
Local i 		:= 0

Default cMesRef			:= ""
Default	cAnoRef			:= ""
Default	lSomaFil		:= .F.
Default	cIn				:= ""

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

/*QryCR31(cAnoMesRef,cFilSel,cAliasQry, cIn)

//Formata o campo conforme manual da GIA
While ( cAliasQry )->( !Eof() )
	aadd( aReg, padl( strtran( Alltrim ( ( cAliasQry )->C4F_NRORE ), '/' , '' ) , 15 , '0' ) )
	( cAliasQry )->( dbSkip() )
End
( cAliasQry )->( dbCloseArea())

//Ordena o array conforme manual da GIA
aSort(aReg)

//Grava arquivo da gia
for i := 1 to len( aReg )
	nQtd31++
	cStrTxt := '31'
	cStrTxt += aReg[i]
	cStrTxt += CRLF
	WrtStrTxt( nHandle, cStrTxt )
next
*/
cStrTxt:= "QTD" + STRZERO(nQtd31,4)
WrtStrTxt( nHandle, cStrTxt )
GerTxtGIA( nHandle, cTXTSys, cReg)

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


//------------------------------------------------------------------------------
/*/{Protheus.doc} QueryCR31

Efetua query que busca os registros referentes aos Registro de Exportação - CR=31

@Param canoMEsRef-> Ano e mes referencia 
		cFilSel -> Filial selecionada

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//------------------------------------------------------------------------------

Function QryCR31(cAnoMesRef,cFilSel,cAliasQry, cIn)
Local cSelect   := ""
Local cWhere    := ""
Local cFrom     := ""
Local cGroupBy  := ""
Local cDtiniRef := Dtos(Firstday(stod(cAnoMesRef+'01'),1))
Local cDtFimRef := dtos(Lastday(stod(cAnoMesRef+'01'),0))
Local cInC2F	:= ""
Local cInC1H	:= ""

Default	cIn	:= ""

lIN	:=	Iif( !Empty(cIn), .T., .F. )

cSelect := "C4F.C4F_NRORE "

cFrom := RetSqlName("C30")+ " C30 "
cFrom += "INNER JOIN " + RetSqlName("C20") + " C20 ON C30.C30_FILIAL 	= C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF 	AND C20.D_E_L_E_T_ = '' "
cFrom += "INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C30.C30_CFOP   	= C0Y.C0Y_ID 												AND C0Y.D_E_L_E_T_ = '' "
cFrom += "INNER JOIN " + RetSqlName("C4G") + " C4G ON C4G_FILIAL 		= C20_FILIAL AND C4G.D_E_L_E_T_ = '' "//C4G_NUMDOC 		= C20_NUMDOC 		AND
cFrom += "INNER JOIN " + RetSqlName("C4F") + " C4F ON C4F_FILIAL 		= C20_FILIAL AND C4G_ID = C4F_ID  						AND C4F.D_E_L_E_T_ = '' "

cWhere := "    C20_FILIAL 		 IN (" + Iif( lIN, cIn , "'" +cFilSel+ "'") + ") "
cWhere += "AND C20.C20_DTDOC  	>= '" + cDtiniRef + "' AND C20.C20_DTDOC <='" + cDtFimRef + "' "
cWhere += "AND C4F.C4F_DTAVB   	IS NOT NULL "
cWhere += "AND C4F.C4F_DTAVB   >=  '" + cDtiniRef + "' AND C4F.C4F_DTAVB <='" + cDtFimRef + "' "
cWhere += "AND (C0Y.C0Y_CODIGO	>= '7000' AND C0Y.C0Y_CODIGO<='7999') AND C30.D_E_L_E_T_ = '' "
cWhere += "AND C4F.C4F_NRORE <> ''"

cGroupBy := "C4F.C4F_NRORE "

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"
cGroupBy := "%" + cGroupBy + "%"

BeginSql Alias cAliasQry
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
   GROUP BY	
		%Exp:cGroupBy%		

EndSql

//Aviso("Query - Testes: CR-31", AllTrim(GetLastQuery()[2]),{"OK"},3)

Return
