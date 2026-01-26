#Include 'Protheus.ch'

Function TAFGIR110(aWizard, nValor, nCont)
Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		 := "0110" //Registro

Local cIndDeclar := space(15)

Local cIndPeriod   := "M" //Indicador de Periodicidade (Fixo)

Local cMesRefer    := Substr(aWizard[1][4],1,2) //Mes Referencia
Local cAnoRefer    := Substr(aWizard[1][4],4,4) //Ano Referencia

Local cIndRetif    := aWizard[1][5] //Indicador de Retificadora

Local nVlSaldAnt	:= StrTran(StrTran(cValToChar(aWizard[1][6]),",",""),".","") //Valor do Saldo Anterior SCE
Local nVlCredEnr	:= StrTran(StrTran(cValToChar(aWizard[1][7]),",",""),".","") //Valor do Crédito de Energia SCE
Local nVlEstProv	:= StrTran(StrTran(cValToChar(aWizard[1][8]),",",""),".","") //Valor do Estorno de Provisão SCE
Local nVlProv		:= StrTran(StrTran(cValToChar(aWizard[1][9]),",",""),".","") //Valor de Provisão SCE

Local deObers      := aWizard[2][5] //Observação
Local deObersST    := aWizard[2][6] //Observação ST

//Representante Legal
Local cNomeRep	:= ""
Local cDDDRep		:= ""
Local cFoneRep	:= ""

//Contador
Local iIDCont    := aWizard[3][1]
Local cNomeCont  := ""
Local cEmailCont := ""
Local cDDDCont   := ""
Local cFoneCont  := ""

Local cStrTxt	 := ""

nCont := 2

Begin Sequence
	DbSelectArea("C1E") //Representante Legal
	DbSelectArea("C2J") //Contador

	//REPRESENTANTE LEGAL
	C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL + C1E_FILTAF + C1E_ATIVO
	If C1E->(DbSeek(xFilial("C1E") + FWGETCODFILIAL + "1"))
		cNomeRep 	:= C1E->C1E_NOMCNT
		cDDDRep	:= C1E->C1E_DDDFON
		cFoneRep 	:= C1E->C1E_FONCNT
	EndIf

	//CONTADOR
	C2J->(DbSetOrder(5))
	If C2J->(DbSeek(xFilial("C2J") + iIDCont ))
		cNomeCont   	:= Substr(C2J->C2J_NOME , 1, 64)
		cEmailCont  	:= Substr(C2J->C2J_EMAIL, 1,40)
		cDDDCont		:= C2J->C2J_DDD
		cFoneCont 		:= Substr(C2J->C2J_FONE , 1, 8)
	Endif

	cStrTxt := cReg
	cStrTxt += StrZero(1,15) //Identificador da Declaração
	
	cStrTxt += Substr(SM0->M0_INSC,1,8) 
	
	cStrTxt += cAnoRefer //Ano de Referência
	cStrTxt += cMesRefer //Mês de Referência
	cStrTxt += (If ((cIndRetif == "0 - Não"),"N","S")) //Indicador de Retificadora
	cStrTxt += "M" //Indicador de Periodicidade
	cStrTxt += trim(cNomeRep) + space(64 - len(trim(cNomeRep))) //Nome do Representante Legal
	cStrTxt += trim(cDDDRep)  + space(4  - len(trim(cDDDRep)))  //DDD Representante Legal
	cStrTxt += trim(cFoneRep) + space(8  - len(trim(cFoneRep))) //Telefone do Representante Legal

	cStrTxt += trim(cNomeCont)	 + space(64 - len(trim(cNomeCont)))  //Nome do Contabilista
	cStrTxt += trim(cEmailCont)  + space(40 - len(trim(cEmailCont))) //Correio Eletrônico
	cStrTxt += trim(cDDDCont)	 + space(4  - len(trim(cDDDCont)))   //DDD Contabilista
	cStrTxt += trim(cFoneCont)	 + space(8  - len(trim(cFoneCont)))  //Telefone do Contabilista

	cStrTxt += strZero(SldCredAnt(cAnoRefer + cMesRefer, FWGETCODFILIAL) * 100,15) //Valor do Saldo Anterior
	cStrTxt += strZero(SldCrAntST(cAnoRefer + cMesRefer, FWGETCODFILIAL) * 100,15) //Valor do Saldo Anterior ST
	//cStrTxt += strZero(SldCredAnt(cAnoRefer + cMesRefer, SM0->M0_CODFIL) * 100,15) //Valor do Saldo Anterior
	//cStrTxt += strZero(SldCrAntST(cAnoRefer + cMesRefer, SM0->M0_CODFIL) * 100,15) //Valor do Saldo Anterior ST



	cStrTxt += trim(deObers)   + space(255 - len(trim(deObers)))   //Observação
	cStrTxt += trim(deObersST) + space(255 - len(trim(deObersST))) //Observação ST

	cStrTxt += StrZero(VAL(nVlSaldAnt),15) //Valor do Saldo Anterior SCE
	cStrTxt += StrZero(VAL(nVlCredEnr),15) //Valor do Crédito de Energia SCE
	cStrTxt += StrZero(VAL(nVlEstProv),15) //Valor do Estorno de Provisão SCE
	cStrTxt += StrZero(VAL(nVlProv   ),15) //Valor de Provisão SCE

	cStrTxt += (If ((aWizard[2][1] == "0 - Não"),"N","S")) //Ind. Sem Mov. Operações Próprias	S/N
	cStrTxt += (If ((aWizard[2][2] == "0 - Não"),"N","S")) //Ind. Sem Mov. Substituição Tributária	S/N
	cStrTxt += (If ((aWizard[2][3] == "0 - Não"),"N","S")) //Ind. Sem Mov. Outros ICMS	S/N
	cStrTxt += (If ((aWizard[2][4] == "0 - Não"),"N","S")) //Ind. Sem Mov. ALC/ZFM

	cStrTxt += space(14) //Filler
	cStrTxt += StrZero(nCont,5) //Contador de linha

	cStrTxt += CRLF

	nCont++ //acrescenta um  no contador para o proximo registro

	nValor += SldCredAnt(cAnoRefer + cMesRefer, FWGETCODFILIAL) +;
			   SldCrAntST(cAnoRefer + cMesRefer, FWGETCODFILIAL) +;
			   VAL(StrTran(cValToChar(aWizard[1][6]),",",".")) +;
			   VAL(StrTran(cValToChar(aWizard[1][7]),",",".")) +;
			   VAL(StrTran(cValToChar(aWizard[1][8]),",",".")) +;
			   VAL(StrTran(cValToChar(aWizard[1][9]),",","."))

	WrtStrTxt( nHandle, cStrTxt )

	GerTxtGIRJ( nHandle, cTxtSys, cReg )


	Recover
	lFound := .F.
End Sequence

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
Static Function SldCredAnt( cAnoMesRef, cFilSel )

Local cSelect := ""
Local cFrom   := ""
Local cWhere  := ""
Local cAliasSld := GetNextAlias()
Local nSldCredAnt := 0
Local cDtiniRef := CTOD("01/"+substr(cAnoMesRef,5,2)+"/"+substr(cAnoMesRef,1,4))
Local cDtFimRef := Lastday(stod(cAnoMesRef+'01'),0)

cSelect := "C2S_CREANT"

cFrom := RetSqlName("C2S") + " C2S "

cWhere := "     C2S_FILIAL = '" + cFilSel + "'"
cWhere += " AND C2S_DTINI >= '" + dtos(cDtiniRef) + "' "
cWhere += " AND C2S_DTFIN <= '" + dtos(cDtFimRef) + "' "
cWhere += " AND C2S.D_E_L_E_T_ != '*' "

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
Static Function SldCrAntST( cAnoMesRef, cFilSel )

Local cSelect := ""
Local cFrom   := ""
Local cWhere  := ""
Local cAliasSldST := GetNextAlias()
Local nSldCredAST := 0
Local cDtiniRef := CTOD("01/"+substr(cAnoMesRef,5,2)+"/"+substr(cAnoMesRef,1,4))
Local cDtFimRef := Lastday(stod(cAnoMesRef+'01'),0)


cSelect := "SUM(C3J_CREANT) CREANT"

cFrom := RetSqlName("C3J") + " C3J"

cWhere := "    C3J_FILIAL = '" + cFilSel + "'"
cWhere += "AND C3J_DTINI >= '" + dtos(cDtiniRef) + "' "
cWhere += "AND C3J_DTFIN <= '" + dtos(cDtFimRef) + "' "
cWhere += "AND C3J.D_E_L_E_T_ != '*' "

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

nSldCredAST := (cAliasSldST)->(CREANT)

(cAliasSldST)->(dbCloseArea())

//Aviso("Query - Testes: CR=05-2", AllTrim(GetLastQuery()[2]),{"OK"},3)

Return nSldCredAST