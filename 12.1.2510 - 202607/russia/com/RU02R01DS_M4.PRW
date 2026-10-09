#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"

/*
Autor:			Artem Nikitenko.
Data:			11/10/17
Description: 	Data set in birt format
*/

dataset RU02R01DS
Title 'M-4'
Description "M-4"

PERGUNTE "RU02R01DS"

Columns
Define Column CO_DATA		TYPE CHARACTER 	SIZE 200 	DECIMALS 0 LABEL 'Company data'	//1H
Define Column CO_OKPO		TYPE CHARACTER 	SIZE 9 		DECIMALS 0 LABEL 'OKPO'			//2H
Define Column H_SYSCOD		TYPE CHARACTER 	SIZE 12 	DECIMALS 0 LABEL 'System code'	//3H
Define column H_D1_CC		TYPE CHARACTER 	SIZE 250 	DECIMALS 0 LABEL 'H_D1_CC'		//4H
Define Column H_IDATE 		TYPE CHARACTER 	SIZE 10 	DECIMALS 0 LABEL 'Posting Date' //5H
Define Column H_NAMWAREH 	TYPE CHARACTER 	SIZE 20 	DECIMALS 0 LABEL 'NNR_DESCRI'	//6H
Define Column CL_NAME 		TYPE CHARACTER 	SIZE 100 	DECIMALS 0 LABEL 'A2_NOME'		//7H
Define Column H_VENCOD 		TYPE CHARACTER 	SIZE 6 		DECIMALS 0 LABEL 'F1_FORNECE'	//8H
Define Column H_CONTA 		TYPE CHARACTER 	SIZE 20 	DECIMALS 0 LABEL 'A2_CONTA'		//9H
Define Column H_DOC			TYPE CHARACTER 	SIZE 16 	DECIMALS 0 LABEL 'H_DOC' 		//10H

Define Column IT_DESC		TYPE CHARACTER 	SIZE 254 	DECIMALS 0 LABEL 'B1_DESC'		//1i
Define Column IT_MATCOD		TYPE CHARACTER 	SIZE 15		DECIMALS 0 LABEL 'D1_COD'		//2i
Define column IT_CODERP		TYPE CHARACTER 	SIZE 4 		DECIMALS 0 LABEL 'AH_CODOKEI'	//3i
Define column IT_UMDESC		TYPE CHARACTER 	SIZE 9 		DECIMALS 0 LABEL 'UM DESCRIPTION'//4i
Define Column IT_QUANT		TYPE NUMERIC 	SIZE 11 	DECIMALS 2 LABEL 'D1_QUANT'		//5i and //6i
Define Column IT_UNIT_PR	TYPE NUMERIC 	SIZE 14 	DECIMALS 2 LABEL 'D1_VUNIT'		//7i
Define Column IT_VALUE 		TYPE NUMERIC 	SIZE 16 	DECIMALS 2 LABEL 'Item value'	//8i
Define Column IT_VAT		TYPE NUMERIC 	SIZE 14 	DECIMALS 2 LABEL 'D1_VALIMP1'	//9i
Define Column IT_VALTOT		TYPE NUMERIC 	SIZE 16 	DECIMALS 2 LABEL 'Item total value'//10i
Define Column Q3_DESCSU2 	TYPE CHARACTER 	SIZE 60 	DECIMALS 0 LABEL 'Q3_DESCSU2'	//13i
Define Column RA_NOME2 		TYPE CHARACTER 	SIZE 60 	DECIMALS 0 LABEL 'RA_NOME2'		//14i
Define Column TOT_SOGU		TYPE NUMERIC 	SIZE 16 	DECIMALS 2 LABEL 'TOT_SOGU'		//61i
Define Column TOT_GOODS		TYPE NUMERIC 	SIZE 16 	DECIMALS 2 LABEL 'Total goods value'//81i
Define Column TOT_VAT		TYPE NUMERIC 	SIZE 14 	DECIMALS 2 LABEL 'F1_VALIMP1'	//91i
Define Column TOT_VALUE 	TYPE NUMERIC 	SIZE 16 	DECIMALS 2 LABEL 'Total value'	//101i

Define Column H11H			TYPE CHARACTER 	SIZE 3 		DECIMALS 0 LABEL '11H'			//11H
Define Column H12H			TYPE CHARACTER 	SIZE 3 		DECIMALS 0 LABEL '12H'			//12H
Define Column H13H			TYPE CHARACTER 	SIZE 20		DECIMALS 0 LABEL '13H'			//13H
Define Column H14H			TYPE CHARACTER 	SIZE 3 		DECIMALS 0 LABEL '14H'			//14H

Define Column I11I			TYPE CHARACTER 	SIZE 3 		DECIMALS 0 LABEL '11I'			//11i
Define Column I12I			TYPE CHARACTER 	SIZE 3 		DECIMALS 0 LABEL '12I'			//12i

Define query "SELECT * FROM %WTable:1% "

process dataset

	Local cWTabAlias, cMvpar01 as char
	Local lRet as logical

	lRet 	:= .F.
	cWTabAlias := ::createWorkTable()

	chkFile("SA2")
	cMvpar01 := alltrim(self:execParamValue( "MV_PAR01" ))

	Processa({|_lEnd| lRet := X60NOT(cWTabAlias, cMvpar01)}, ::title())

return .T.

/*---------------------------------------------------------------------------------------------*/
static function X60NOT(cAliasMov,cMvpar01)
	Local aArea, aRet	as array
	Local nSumT, nGetSxe	as Numeric
	Local cQ3descsu, cRanome, cR2nome2, cQuery, cAliasTM2, cAliasTMP, cAdr as Char
	local iAdrExi := .T.

	aRet := GetCoBrRUS()
	cAdr := ''

	If !empty(aRet) .AND. !empty(aRet[3][2]) 
		If !empty(Alltrim(aRet[3][2][6]))
			cAdr += alltrim(aRet[3][2][6])
		Endif
		If !empty(alltrim(aRet[3][2][10]))
			cAdr += ", " + alltrim(aRet[3][2][10])
		Endif
		If !empty(alltrim(aRet[3][2][12]))
			cAdr += ", " + alltrim(aRet[3][2][12])
		Endif
		If !empty(alltrim(aRet[3][2][13]))
			cAdr += ", " + alltrim(aRet[3][2][13])
		Endif
		If !empty(alltrim(aRet[3][2][15]))
			cAdr += ", " + alltrim(aRet[3][2][15])
		Endif
		If !empty(alltrim(aRet[3][2][16]))
			cAdr += ", " + alltrim(aRet[3][2][16])
		Endif
		If !empty(alltrim(aRet[3][2][17]))
			cAdr += ", " + alltrim(aRet[3][2][17])
		Endif
		If !empty(alltrim(aRet[3][2][18]))
			cAdr += ", " + alltrim(aRet[3][2][18])
		Endif
		If !empty(cAdr)
			cAdr +="."
		Endif			
	Else
		Help(" ",1,"ADDRNOTEX2")
		iAdrExi := .F.
	Endif

	aSigners:=RU06D01GetSigner(cMvpar01,"IN ('M4','ALL','M-4')")

	cNotIni:= SF1->F1_DOC

	aArea 	:= getArea()
	nSumT 	:= 0
	nGetSxe	:= GetSxeNum("SF1", "F1_MSIDENT")

	cAliasTMP	:= GetNextAlias()

	cQuery := " SELECT A2_NOME, A2_END, A2_BAIRRO, A2_MUN, A2_PAIS, A2_EST, A2_CEP, A2_CONTA,"
	cQuery += " F1_DOC, F1_FORNECE, F1_LOJA, F1_DTDIGIT, F1_VALIMP1, F1_VALBRUT, F1_VALMERC, F1_MOEDA,"
	cQuery += " D1_COD, D1_QUANT, D1_UM, D1_VUNIT, D1_LOCAL, B1_DESC, D1_CC, F1_MSIDENT,"
	cQuery += " D1_VALIMP1, D1_ALQIMP1, D1_TOTAL, AH_UNIMED, D1_TIPODOC, AH_CODOKEI, AH_DESCPO,"
	cQuery += " D1_CC, NNR_DESCRI, AH_UMRES, D1_ITEM, F5Q_NUMBER "
	cQuery += " FROM " + RetSqlName("SF1") + " SF1"
	cQuery += " INNER JOIN " + RetSqlName("SA2") + " SA2"
	cQuery += " ON SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
	cQuery += " AND SA2.A2_COD = SF1.F1_FORNECE"
	cQuery += " AND SA2.A2_LOJA = SF1.F1_LOJA "
	cQuery += " AND SA2.D_E_L_E_T_=' '"
	cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1"
	cQuery += " ON SD1.D1_FILIAL = SF1.F1_FILIAL"
	cQuery += " AND SD1.D1_DOC = SF1.F1_DOC"
	cQuery += " AND SD1.D1_SERIE = SF1.F1_SERIE"
	cQuery += " AND SD1.D1_FORNECE = SF1.F1_FORNECE"
	cQuery += " AND SD1.D1_LOJA = SF1.F1_LOJA"
	cQuery += " AND SD1.D1_TIPODOC = SF1.F1_TIPODOC"
	cQuery += " AND SD1.D1_ESPECIE = SF1.F1_ESPECIE"
	cQuery += " AND SD1.D_E_L_E_T_ = ' '"
	cQuery += " AND SD1.D1_FILIAL =	'" + xFilial("SD1") + "'"
	cQuery += " INNER JOIN " + RetSqlName("SAH") + " SAH"
	cQuery += " ON SAH.AH_FILIAL = '" + xFilial("SAH") + "'"
	cQuery += " AND SAH.AH_UNIMED = SD1.D1_UM"
	cQuery += " AND SAH.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cQuery += " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'" 
	cQuery += " AND SB1.B1_COD = SD1.D1_COD"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName("NNR") + " NNR"
	cQuery += " ON NNR.NNR_FILIAL = SD1.D1_FILIAL"
	cQuery += " AND NNR.NNR_CODIGO = SD1.D1_LOCAL"
	cQuery += " AND NNR.D_E_L_E_T_ = ' '"
	cQuery += " LEFT JOIN " + RetSqlName("F5Q") + " F5Q"
	cQuery += " ON F5Q.F5Q_FILIAL = SF1.F1_FILIAL"
	cQuery += " AND F5Q.F5Q_UID = SF1.F1_F5QUID"
	cQuery += " AND F5Q.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
	cQuery += " AND SF1.F1_DOC = '" + SF1->F1_DOC + "'"
	cQuery += " AND SF1.F1_SERIE = '" + SF1->F1_SERIE + "'"
	cQuery += " AND SF1.F1_FORNECE = '" + SF1->F1_FORNECE + "'"
	cQuery += " AND SF1.F1_LOJA = '" + SF1->F1_LOJA + "'"
	cQuery += " AND SF1.F1_FORMUL = '" + SF1->F1_FORMUL + "'"
	cQuery += " AND SF1.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T.)
	DbSelectArea(cAliasTMP)
	(cAliasTMP)->(dbGotop())

	While (cAliasTMP)->(!EOF())

		RecLock(cAliasMov,.T.)

		If !empty(aRet[3][1]) .AND. !empty(aRet[3][1][7]) .AND. !empty(aRet[3][1][5]) ; 
				.AND. alltrim(aRet[3][1][7]) == '1' .AND. alltrim(aRet[3][1][5]) == '0'
			CO_DATA :=  ALLTRIM(aRet[1][5][2]) + ", " + ALLTRIM(aRet[1][13][2]) + "/" + ALLTRIM(aRet[1][14][2]) + cAdr //1H
		Else
			CO_DATA	:=  ALLTRIM(aRet[1][5][2]) + ", " + ALLTRIM(aRet[1][13][2]) + "/" + ALLTRIM(aRet[1][14][2]) + "."//1H
		Endif
			
		CO_OKPO			:= aRet[1][12][2] 				//2H
		H_SYSCOD		:= cValToChar(Val((nGetSxe)))	//3H
		
		If ExistBlock('RU02R01I')						//4H
			H_D1_CC		:= ExecBlock('RU02R01I', .T., .T., 'H_D1_CC')
		Else
			H_D1_CC		:= cAdr
		Endif
		
		H_IDATE 		:= StrTran(DTOC(Stod((cAliasTMP)->F1_DTDIGIT)), "/", ".")//5H
		H_NAMWAREH 		:= (cAliasTMP)->NNR_DESCRI		//6H
		CL_NAME			:= (cAliasTMP)->A2_NOME			//7H
		H_VENCOD 		:= (cAliasTMP)->F1_FORNECE		//8H
		H_CONTA 		:= (cAliasTMP)->A2_CONTA		//9H
		H_DOC			:= (cAliasTMP)->F1_DOC			//10H

		IT_DESC			:= (cAliasTMP)->B1_DESC 		//1i
		IT_MATCOD		:= (cAliasTMP)->D1_COD 			//2i
		IT_CODERP		:= (cAliasTMP)->AH_CODOKEI 		//3i
		IT_UMDESC	 	:= (cAliasTMP)->AH_UMRES		//4i
		IT_QUANT		:= (cAliasTMP)->D1_QUANT		//5i and //6i
		IT_UNIT_PR		:= (cAliasTMP)->D1_VUNIT		//7i
		IT_VALUE		:= (cAliasTMP)->D1_TOTAL		//8i
		IT_VAT			:= (cAliasTMP)->D1_VALIMP1		//9i
		nSumT 			:= nSumT + IT_QUANT
		TOT_SOGU		:= nSumT						//61i
		IT_VALTOT		:= (((cAliasTMP)->D1_TOTAL) + ((cAliasTMP)->D1_VALIMP1))	//10i
		TOT_VAT			:= (cAliasTMP)->F1_VALIMP1		//91i
		TOT_GOODS	 	:= (cAliasTMP)->F1_VALMERC		//81i
		TOT_VALUE	 	:= (cAliasTMP)->F1_VALBRUT		//101i
		
		If ExistBlock('RU02R01I')
			I11I		:= ExecBlock('RU02R01I', .T., .T., 'I11I')		//11i
			I12I		:= ExecBlock('RU02R01I', .T., .T., 'I12I')		//12i
			H11H		:= ExecBlock('RU02R01I', .T., .T., 'H11H')		//11H
			H12H		:= ExecBlock('RU02R01I', .T., .T., 'H12H')		//12H
			H14H		:= ExecBlock('RU02R01I', .T., .T., 'H14H')		//14H
		Else
			I11I		:= " "							//11i
			I12I		:= " "							//12i
			H11H		:= " "							//11H
			H12H		:= " "							//12H
			H14H		:= " "							//14H
		Endif
		
		H13H	   := (cAliasTMP)->F5Q_NUMBER		//13H
		RA_NOME2   := aSigners[2]			//13i
		Q3_DESCSU2 := aSigners[3]			//14i

		MsUnlock()
		(cAliasTMP)->(dbSkip())

	EndDo

	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
	ConfirmSx8()

Return .T.
//Merge Russia R14                   
