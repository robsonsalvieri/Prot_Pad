#Include "Protheus.ch"
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGS05

Rotina de geração do registro CR=05 da GIA-SP

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
Function TAFGS05( aWizard, cFilSel, cJobAux, cInscEst, cCNPJ, cCNAE, cMesRef, cAnoRef, lSomaFil, cIn )
Local oError	 := ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )
Local cREG 		 := "CR05" + cInscEst
Local cStrTxt 	 := ""
Local cTxtSys  	 := CriaTrab( , .F. ) + ".TXT"
Local nHandle    := MsFCreate( cTxtSys )
Local cAnoMesRef := Alltrim(aWizard[1][11]) + Alltrim(aWizard[1][9])
Local cAnoMesIni := Alltrim(aWizard[1][13]) + Alltrim(aWizard[1][12])
Local cMesAnoRef := Alltrim(aWizard[1][9]) + Alltrim(aWizard[1][11])
Local cRegTrib   := Alltrim( Left(aWizard[1][10],2) )
Local lFound     := .T.

Default cMesRef		:= ""
Default	cAnoRef		:= ""
Default	lSomaFil	:= .F.
Default	cIn			:= ""

//Tratamento para exibição de mensagem para o usuário final, caso ocorra erro durante o processamento
Begin Sequence

cStrTxt:= "05" 												                                          	// Identificador do registro
cStrTxt+= Iif(Empty(StrTran(cInscEst,".","")),space(12),Right(StrTran(cInscEst,".",""),12))	            // IE
cStrTxt+= IiF(Empty(cCNPJ),space(14),cCNPJ)				                                          		// CNPJ	
cStrTxt+= '0000000'											                                          	// CNAE
cStrTxt+= Left(aWizard[1][10],2)							                                          	// Reg. Tributário
cStrTxt+= cAnoMesRef																					// Referencia (Ano Mes)
cStrTxt+= IIF(cRegTrib == "02", cAnoMesIni, "000000"	)	                                          	// Referencia (Ano Mes Ini)
cStrTxt+= Left(aWizard[1][6],2)																			// Tipo da Gia
cStrTxt+= Left(aWizard[1][7],1)																			// Movimento
cStrTxt+= Left(aWizard[1][8],1)																			// Transmitida
cStrTxt+= xConvGIA(SldCredAnt(cAnoMesRef, cFilSel, cIn),15)												// SaldoCredPeriodoAnt
cStrTxt+= xConvGIA(SldCrAntST(cAnoMesRef, cFilSel, cIn),15)												// SaldoCredPeriodoAntST
cStrTxt+= "53113791000122" 									                                          	// OrigemSoftware - CPF OU CNPJ  do Fabricante (Totvs)
cStrTxt+= "0"																							// OrigemPreDig
cStrTxt+= Iif(cRegTrib == "02",xConvGIA( val(Alltrim(aWizard[1][14])),15), Replicate("0",15) )			// ICMSFixPer
cStrTxt+= Replicate("0",32)							                              		              	// ChaveInterna
cStrTxt+= CRLF

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

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SldCredAnt

Rotina retorna o Saldo Saldo Credor do Período Anterior.

@Param cAnoMesRef -> Ano/Mês de referencia

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function SldCredAnt( cAnoMesRef, cFilSel, cIn )

Local cSelect := ""
Local cFrom   := ""
Local cWhere  := ""
Local cAliasSld := GetNextAlias()
Local nSldCredAnt := 0
Local cDtiniRef := Firstday(stod(cAnoMesRef+'01'),1)
Local cDtFimRef := Lastday(stod(cAnoMesRef+'01'),0)

Default	cIn	:= ""

cSelect := "C2S_CREANT "

cFrom := RetSqlName("C2S") + " C2S "

cWhere := "    C2S_FILIAL IN ("+"'"+cFilSel+"'"+ Iif(!Empty(cIn),", "+cIn ,"")+") "
cWhere += " AND C2S_DTINI >= '" + dtos(cDtiniRef) + "' "
cWhere += "AND  C2S_DTFIN <= '" + dtos(cDtFimRef) + "' "
cWhere += "AND C2S.D_E_L_E_T_ = ''"

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

BeginSql Alias cAliasSld
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
EndSql

nSldCredAnt := (cAliasSld)->(C2S_CREANT)

(cAliasSld)->(dbCloseArea())

//Aviso("Query - Testes: CR=05-1", AllTrim(GetLastQuery()[2]),{"OK"},3)

Return nSldCredAnt

//---------------------------------------------------------------------
/*/{Protheus.doc} SldCrAntST

Rotina retorna o Saldo Saldo Credor do Período Anterior de ICMS - ST.

@Param cAnoMesRef -> Ano/Mês de referencia

@Author Paulo V.B. Santana
@Since 17/04/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function SldCrAntST( cAnoMesRef, cFilSel, cIn)

Local cSelect := ""
Local cFrom   := ""
Local cWhere  := ""
Local cAliasSldST := GetNextAlias()
Local nSldCredAST := 0
Local cDtiniRef := Firstday(stod(cAnoMesRef+'01'),1)
Local cDtFimRef := Lastday(stod(cAnoMesRef+'01'),0)

Default	cIn	:= ""

cSelect := "C3J_CREANT"

cFrom := RetSqlName("C3J") + " C3J"

cWhere := "    C3J_FILIAL IN ("+"'"+cFilSel+"'"+ Iif(!Empty(cIn),", "+cIn ,"")+") "
cWhere += "AND C3J_DTINI >= '" + dtos(cDtiniRef) + "' "
cWhere += "AND C3J_DTFIN <= '" + dtos(cDtFimRef) + "' "
cWhere += "AND C3J.D_E_L_E_T_ = ''"

cSelect  := "%" + cSelect  + "%"
cFrom    := "%" + cFrom    + "%"
cWhere   := "%" + cWhere   + "%"

BeginSql Alias cAliasSldST
	SELECT
		%Exp:cSelect%
	FROM
		%Exp:cFrom%
	WHERE
		%EXP:cWhere%
EndSql

nSldCredAST := (cAliasSldST)->(C3J_CREANT)

(cAliasSldST)->(dbCloseArea())

//Aviso("Query - Testes: CR=05-2", AllTrim(GetLastQuery()[2]),{"OK"},3)

Return nSldCredAST


