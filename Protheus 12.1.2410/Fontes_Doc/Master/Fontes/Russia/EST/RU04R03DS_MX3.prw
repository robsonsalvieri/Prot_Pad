#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"

/*
Autor:			Artem Nikitenko
Data:			25.12.2020
Description: 	Data set in birt format
*/
 
dataset RU04R03DS
Title 'MX3'
Description "MX3"

PERGUNTE "RU02R01DS" //will be RU04R03DS soon

Columns
DEFINE COLUMN H01H	TYPE CHARACTER 	SIZE 200	DECIMALS 0 LABEL "Company data"	//1H
DEFINE COLUMN H02H	TYPE CHARACTER 	SIZE 390	DECIMALS 0 LABEL "2H" 			//2H
DEFINE COLUMN H03H	TYPE CHARACTER 	SIZE 9		DECIMALS 0 LABEL "OKPO"			//3H
DEFINE COLUMN H04H	TYPE CHARACTER 	SIZE 20		DECIMALS 0 LABEL "H04H" 		//4H
DEFINE COLUMN H05H	TYPE CHARACTER 	SIZE 11		DECIMALS 0 LABEL "H05H" 		//5H
DEFINE COLUMN H06H	TYPE CHARACTER 	SIZE 8		DECIMALS 0 LABEL "H06H" 		//6H
DEFINE COLUMN H07H	TYPE CHARACTER 	SIZE 12		DECIMALS 0 LABEL "H07H" 		//7H

DEFINE COLUMN I01I	TYPE CHARACTER 	SIZE 6		DECIMALS 0 LABEL "I01I"		//2I	
DEFINE COLUMN I02I	TYPE CHARACTER 	SIZE 254	DECIMALS 0 LABEL "I02I"		//2I		
DEFINE COLUMN I03I	TYPE CHARACTER 	SIZE 15		DECIMALS 0 LABEL "I03I"		//3I
DEFINE COLUMN I04I	TYPE CHARACTER 	SIZE 3		DECIMALS 0 LABEL "I04I"		//4I
DEFINE COLUMN I05I	TYPE CHARACTER 	SIZE 100	DECIMALS 0 LABEL "I05I"		//5I
DEFINE COLUMN I06I	TYPE CHARACTER 	SIZE 4		DECIMALS 0 LABEL "I06I"		//6I
DEFINE COLUMN I07I	TYPE NUMERIC 	SIZE 11		DECIMALS 2 LABEL "I07I"		//7I
DEFINE COLUMN I08I	TYPE NUMERIC 	SIZE 14		DECIMALS 2 LABEL "I08I"		//8I
DEFINE COLUMN I09I	TYPE NUMERIC 	SIZE 14		DECIMALS 2 LABEL "I09I"		//9I
DEFINE COLUMN I10I	TYPE NUMERIC 	SIZE 20		DECIMALS 2 LABEL "I10I"		//10I
DEFINE COLUMN I11I	TYPE NUMERIC 	SIZE 20		DECIMALS 2 LABEL "I11I"		//11I
DEFINE COLUMN I12I	TYPE NUMERIC 	SIZE 20		DECIMALS 2 LABEL "I12I"		//12I
DEFINE COLUMN I13I	TYPE NUMERIC 	SIZE 20		DECIMALS 2 LABEL "I13I"		//13I
DEFINE COLUMN I14I	TYPE CHARACTER 	SIZE 60		DECIMALS 0 LABEL "I14I"		//14I
DEFINE COLUMN I15I	TYPE CHARACTER 	SIZE 60		DECIMALS 0 LABEL "I15I"		//15I

DEFINE query "SELECT * FROM %WTable:1% "

process dataset

	Local cWTabAlias, cMvpar01 as char
	Local lRet as logical

	lRet 	:= .F.
	cWTabAlias := ::createWorkTable()

	cMvpar01 := alltrim(self:execParamValue( "MV_PAR01" ))
	Processa({|_lEnd| lRet := X60NOT(cWTabAlias, cMvpar01)}, ::title())

return .T.

/*---------------------------------------------------------------------------------------------*/
static function X60NOT(cAliasMov,cMvpar01)
	Local aArea, aRet	as array
	Local nSum07I, nSum09I, nGetSxe, nNumOfLine	as Numeric
	Local cQ3descsu, cRanome, cR2nome2, cQuery, cAliasTM2, cAliasTMP, cAdr as Char
	local iAdrExi := .T.

	aRet := GetCoBrRUS()
	cAdr := ''
	nNumOfLine:=0

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

	cQuery := " SELECT F42_NAME, F42_DSCCRG " 
	cQuery += " FROM " + RetSqlName("F42")
	cQuery += " WHERE F42_FILIAL = '" + xFilial("F42") + "'"
	cQuery += " AND F42_EMPL = '" + cMvpar01 + "' "
	cQuery += " AND F42_REPORT IN ('MX-3', 'MX3', 'ALL') "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	cAliasTM2	:= GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTM2, .T., .T.)
	DbSelectArea(cAliasTM2)
	(cAliasTM2)->(DbGoTop())
	If alltrim((cAliasTM2)->F42_NAME) = ''
		cR2nome2    := ''
	Else
		cQ3descsu	:= alltrim((cAliasTM2)->F42_DSCCRG)
		cRanome		:= alltrim((cAliasTM2)->F42_NAME)
		cR2nome2	:= alltrim(substr(alltrim(cRanome), 1, (at(' ', alltrim(cRanome), 1))))
		cR2nome2	:= alltrim(cR2nome2) + (' ') + alltrim(substr(alltrim(cRanome), (at(' ', alltrim(cRanome), 1)), 2))
		cR2nome2	:= alltrim(cR2nome2) + alltrim('.') + alltrim(substr(alltrim(cRanome), (at(' ', alltrim(cRanome), len(cR2nome2))), 2)) + '.'
	Endif
	(cAliasTM2)->(dbCloseArea())

	aArea 	:= getArea()
	nSum07I 	:= 0
	nSum09I 	:= 0
	nGetSxe	:= GetSxeNum("SF1", "F1_MSIDENT")

	cAliasTMP	:= GetNextAlias()

	cQuery := " SELECT F1_EMISSAO, A1_NREDUZ, A1_ENDENT, A1_TEL, A1_FAX,"
	cQuery += " F1_DOC, F1_FORNECE, F1_LOJA, F1_DTDIGIT, F1_VALIMP1, F1_VALBRUT, F1_VALMERC, F1_MOEDA,"
	cQuery += " D1_COD, D1_QUANT, D1_UM, D1_VUNIT, D1_LOCAL, B1_DESC, D1_CC, F1_MSIDENT,D1_DESCRI,"
	cQuery += " D1_VALIMP1, D1_ALQIMP1, D1_TOTAL, AH_UNIMED, D1_TIPODOC, AH_CODOKEI, AH_DESCPO,"
	cQuery += " D1_CC, NNR_DESCRI, AH_UMRES, D1_ITEM, F5Q_NUMBER, F5Q_EDATE"
	cQuery += " FROM " + RetSqlName("SF1") + " SF1"

	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1"
	cQuery += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery += " AND SA1.A1_COD = SF1.F1_FORNECE"
	cQuery += " AND SA1.A1_LOJA = SF1.F1_LOJA "
	cQuery += " AND SA1.D_E_L_E_T_=' '"

	cQuery += " INNER JOIN " + RetSqlName("SD1") + " SD1"
	cQuery += " ON SD1.D1_FILIAL =	'" + xFilial("SD1") + "'"
	cQuery += " AND SD1.D1_DOC = SF1.F1_DOC"
	cQuery += " AND SD1.D1_SERIE = SF1.F1_SERIE"
	cQuery += " AND SD1.D1_FORNECE = SF1.F1_FORNECE"
	cQuery += " AND SD1.D1_LOJA = SF1.F1_LOJA"
	cQuery += " AND SD1.D1_TIPODOC = SF1.F1_TIPODOC"
	cQuery += " AND SD1.D1_ESPECIE = SF1.F1_ESPECIE"
	cQuery += " AND SD1.D_E_L_E_T_ = ' '"

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
		nNumOfLine++

		If !empty(aRet[3]) .AND. !empty(aRet[3][1]) .AND. !empty(aRet[3][1][10])
			H01H 	:=  alltrim(aRet[3,1,10]);
			+','+alltrim(aRet[3,1,12]);
			+','+alltrim(aRet[3,1,13]);
			+','+alltrim(aRet[3,1,15]);
			+','+alltrim(aRet[3,1,16]);
			+','+alltrim(aRet[3,1,17]);
			+','+alltrim(aRet[3,1,18]);
			+ '.'
		Endif
		H02H	:=alltrim((cAliasTMP)->A1_NREDUZ) + alltrim((cAliasTMP)->A1_ENDENT) + alltrim((cAliasTMP)->A1_TEL) + alltrim((cAliasTMP)->A1_FAX)
		H03H	:=aRet[1][12][2]
		H04H	:=(cAliasTMP)->F5Q_NUMBER

		If empty((cAliasTMP)->F5Q_EDATE)
			H05H	:= ''
		Else
			H05H	:=DTOC(STOD((cAliasTMP)->F5Q_EDATE))
		EndIf

		H06H	:=(cAliasTMP)->F1_DOC

		If empty((cAliasTMP)->F1_EMISSAO)
			H07H	:= ''
		Else
			H07H	:=DTOC(STOD((cAliasTMP)->F1_EMISSAO))
		EndIf
		
		H08H	:=alltrim((cAliasTMP)->A1_NREDUZ) + alltrim((cAliasTMP)->A1_ENDENT)

		I01I	:=	alltrim(str(nNumOfLine))
		I02I	:=	(cAliasTMP)->D1_DESCRI
		I03I	:=	(cAliasTMP)->D1_COD
		I04I	:=	'-'
		I05I	:=	(cAliasTMP)->AH_DESCPO
		I06I	:=	alltrim((cAliasTMP)->AH_CODOKEI)
		I07I	:=	(cAliasTMP)->D1_QUANT
		nSum07I	+= 	(cAliasTMP)->D1_QUANT
		I08I	:=	(cAliasTMP)->D1_VUNIT
		I09I	:=	(cAliasTMP)->D1_TOTAL
		nSum09I	+=	(cAliasTMP)->D1_TOTAL
		I10I	:=	nSum07I	//Sum each page for I07I
		I11I	:=	nSum09I	//Sum each page for I09I
		I12I	:=	nSum07I
		I13I	:=	nSum09I
		I14I 	:=	alltrim(cQ3descsu)
		I15I 	:=	alltrim(cR2nome2)

		MsUnlock()
		(cAliasTMP)->(dbSkip())

	EndDo

	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
	ConfirmSx8()

Return .T.
                   
//Merge Russia R14 
                   
                   
