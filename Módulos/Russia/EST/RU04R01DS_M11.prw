#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"
#include "RU04R01.CH"

/*
Autor:			Artem Nikitenko
Data:			2018.12.07
Description: 	Data set in birt format
Last Update and author: 	2022.05.09 Artem Nikitenko
*/

dataset RU04R01DS
	Title "M-11"
	Description "Print M-11"
	PERGUNTE "RU04R01DS"

Columns
define Column CO_DATA		TYPE CharACTER SIZE 200 LABEL 'Company data'		//1H  Company data
define Column CO_OKPO		TYPE CharACTER SIZE 9 LABEL 'CO_OKPO'				//2H  Company OKPO code
define Column D3_DOC		TYPE CharACTER SIZE 10 LABEL 'D3_DOC'				//3H  System Document number
define Column D3_EMISSAO	TYPE CharACTER SIZE 10 LABEL 'D3_EMISSAO'			//4H  Document date 
define Column D3_LOCAL1		TYPE CharACTER SIZE 30 LABEL 'D3_LOCAL1'			//5H  Issuing warehouse code, sender
define Column NR_DESCRI1	TYPE CharACTER SIZE 20 LABEL 'NR_DESCRI1'			//6H  Issuing warehouse name, sender
define Column D3_LOCAL2		TYPE CharACTER SIZE 30 LABEL 'D3_LOCAL2'			//7H  Receiving warehouse code, recipient
define Column NR_DESCRI2	TYPE CharACTER SIZE 20 LABEL 'NR_DESCRI2'			//8H  Receiving warehouse name, recipient
define Column H9_CONTA		TYPE CharACTER SIZE 4 LABEL 'H9_CONTA'				//9H  Conta contábil
define Column H10REQUEST	TYPE CharACTER SIZE 121 LABEL 'H10REQUEST'			//10H Who requested
define Column H11APPROV		TYPE CharACTER SIZE 121 LABEL 'H11APPROV'			//11H Who approved
define Column H12USNAME		TYPE CharACTER SIZE 121 LABEL 'H12USNAME'			//12H Through whom it is requested
define Column H13OpType		TYPE CharACTER SIZE 20 LABEL 'H13OpType'			//13H Operation type code
define Column H14ARec		TYPE CharACTER SIZE 20 LABEL 'H14ARec'				//14H Analytical accounting code
define Column H15AccUnit	TYPE CharACTER SIZE 20 LABEL 'H15AccUnit'			//15H Accounting unit of issue
define Column HEADTYPE		TYPE CharACTER SIZE 20 LABEL 'HEADTYPE'				//Title field name

define Column D3_CONTA		TYPE CharACTER SIZE 20 LABEL 'D3_CONTA'				//1i  Stock account code
define Column B1_DESC		TYPE CharACTER SIZE 254 LABEL 'B1_DESC'				//3i  Material description
define Column D3_COD		TYPE CharACTER SIZE 15 LABEL 'D3_COD'				//4i  Material code
define Column AH_CODOKEI	TYPE CharACTER SIZE 4 LABEL 'AH_CODOKEI'			//5i  Base unit of measure system code
define Column AH_UMRES		TYPE CharACTER SIZE 25 LABEL 'AH_UMRES'				//6i  Base unit of measure short name
define Column NNT_QUANT 	TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'NNT_QUANT'	//7i  Requested quantity in base units
define Column D3_QUANT		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'D3_QUANT'	//8i  Posted quantity in base units
define Column B1_UPRC		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'B1_UPRC'		//9i  Price per base unit
define Column D3_CUSTO1		TYPE NUMERIC SIZE 20 DECIMALS 2 LABEL 'D3_CUSTO1'	//10i Total value for the row without Tax (VAT)

define Column I16ARec		TYPE CharACTER SIZE 20 LABEL 'I16ARec'				//16I Analytical accounting code
define Column I17SerNum		TYPE CharACTER SIZE 30 LABEL 'I17SerNum'			//17I Serial number according to the warehouse file

define Column Q3_DESCSU1 	TYPE CharACTER SIZE 60 LABEL 'Q3_DESCSU1'			//11i issued by, position
define Column RA_NOME1 		TYPE CharACTER SIZE 60 LABEL 'RA_NOME1'				//12i issued by,Full name
define Column Q3_DESCSU2 	TYPE CharACTER SIZE 60 LABEL 'Q3_DESCSU2'			//13i Receiver, position
define Column RA_NOME2 		TYPE CharACTER SIZE 60 LABEL 'RA_NOME2'				//14i Receiver, Full name

define query "SELECT * FROM %WTable:1% "

process dataset

	Local cWTabAlias	as Char
	Local cMvpar01		as Char
	Local cMvpar02		as Char
	Local cMvpar03		as Char
	Local cMvpar04		as Char
	Local cMvpar05		as Char
	Local cSelFil		as Char
	Local cEmissao		as Char
	Local cSelDoc		as Char
	Local lRet			as Logical

	lRet 		:= .F.
	cWTabAlias 	:= Self:CreateWorkTable()

	If FwIsInCallStack('MATA311')
		cSelDoc := NNS->NNS_COD
		cSelFil := NNS->NNS_FILIAL
		cEmissao := DTOS(NNS->NNS_DATA)

	Else
		cSelDoc := SD3->D3_DOC
		cSelFil := SD3->D3_FILIAL
		cEmissao := DTOS(SD3->D3_Emissao)
	Endif

	cMvpar01	:=	Alltrim(Self:ExecParamValue( "MV_PAR01" ))
	cMvpar02	:=	Alltrim(Self:ExecParamValue( "MV_PAR02" ))

	If AScan(self:aexecparams,{|X|x[1] == 'MV_PAR03'}) > 0

		cMvpar03	:=	Alltrim(Self:ExecParamValue( "MV_PAR03" ))
		cMvpar04	:=	Alltrim(Self:ExecParamValue( "MV_PAR04" ))
		cMvpar05	:=	Alltrim(Self:ExecParamValue( "MV_PAR05" ))
	Endif

	If empty(cMvpar01)
		cMvpar01 := ''
	Endif
	If empty(cMvpar02)
		cMvpar02 := ''
	Endif
	If empty(cMvpar03)
		cMvpar03 := ''
	Endif
	If empty(cMvpar04)
		cMvpar04 := ''
	Endif
	If empty(cMvpar05)
		cMvpar05 := ''
	Endif

	Processa({|_lEnd| lRet := X60NOT(cWTabAlias, cMvpar01, cMvpar02, cMvpar03, cMvpar04, cMvpar05, cSelDoc, cSelFil, cEmissao) }, ::title())

Return .T.

/*---------------------------------------------------------------------------------------------*/
static function X60NOT(cAliasMov, cMvpar01, cMvpar02, cMvpar03, cMvpar04, cMvpar05, cSelDoc, cSelFil, cEmissao )
	Local aArea		 as Array
	Local aCDate	 as Array
	Local aSigners	 as Array
	local aAliasHead as Array
	Local cADDRESS	 as Char
	Local cAliasTMP	 as Char
	Local cQuery	 as Char
	Local cKeyOfReport as Char

	aAliasHead = {" ", " ", .F., " ", " ", .F.} // D3_LOCAL1 //5H, NR_DESCRI1 //6H, cFlag1, D3_LOCAL2 //7H, NR_DESCRI2//8H, cFlag2
	cKeyOfReport:="IN ('M-11', 'ALL','M11')"
	aSigners := { RU06D01GetSigner(cMvpar01,cKeyOfReport), RU06D01GetSigner(cMvpar02,cKeyOfReport), ;
	    RU06D01GetSigner(cMvpar03,cKeyOfReport), RU06D01GetSigner(cMvpar04,cKeyOfReport), RU06D01GetSigner(cMvpar05,cKeyOfReport) }

	aArea := getArea()
	
	aCDate := FwComAltInf({'CO_KPP','CO_INN','CO_OKPO','CO_FULLNAM','CO_PHONENU','CO_COMPGRP','CO_COMPEMP','CO_TIPO'})
	
	aadd(aCDate,GetAdress()) 
IF FWIsInCallStack("MATA311")

		cQuery := " SELECT NNT.NNT_DOC, SD3.D3_EMISSAO, NNR.NNR_DESCRI, SBE.BE_DESCRIC, SD3.D3_CF, SD3.D3_QUANT,"
		cQuery += " SB1.B1_CONTA, SB1.B1_DESC, NNT.NNT_PROD, SAH.AH_CODOKEI, SAH.AH_DESCPO,"
		cQuery += " NNT.NNT_QUANT, SD3.D3_CUSTO1, SD3.D3_LOCAL, CASE WHEN NNR_TIPO='1' THEN '" ;
				+ STR0001 + "' WHEN NNR_TIPO='2' THEN '" + STR0002 + "' ELSE '" + STR0003 + "' END AS TIPONAME "

		cQuery += " FROM " + RetSqlName("NNT") + " NNT "
	
		cQuery += " LEFT JOIN " + RetSqlName("SD3") + " SD3 "
		cQuery += " ON SD3.D3_DOC = NNT.NNT_DOC"
		cQuery += " AND SD3.D3_COD = NNT.NNT_PROD"
		cQuery += " AND SD3.D3_LOCALIZ = NNT.NNT_LOCALI"
		cQuery += " AND SD3.D3_LOTECTL = NNT.NNT_LOTECT"
		cQuery += " AND SD3.D3_FILIAL = '" + xFilial('SD3') + "' "
		cQuery += " AND SD3.D3_CF IN ('RE4','DE4') "
		cQuery += " AND SD3.D_E_L_E_T_=' ' "
	
		cQuery += " LEFT JOIN " + RetSqlName("NNR") + " NNR "
		cQuery += " ON NNR.NNR_CODIGO = SD3.D3_LOCAL " 
		cQuery += " AND NNR.NNR_FILIAL = '" + xFilial('NNR') + "' "
		cQuery += " AND NNR.D_E_L_E_T_=' ' "
	
		cQuery += " LEFT JOIN " + RetSqlName("SBE") + " SBE " 
		cQuery += " ON SBE.BE_LOCAL = SD3.D3_LOCAL "
		cQuery += " AND SBE.BE_LOCALIZ = SD3.D3_LOCALIZ "
		cQuery += " AND SBE.BE_FILIAL = '" + xFilial('SBE') + "' "
		cQuery += " AND SBE.D_E_L_E_T_=' ' "
	
		cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 " 
		cQuery += " ON SB1.B1_COD = NNT.NNT_PROD "
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' "
		cQuery += " AND SB1.D_E_L_E_T_=' ' " 
	
		cQuery += " LEFT JOIN " + RetSqlName("SAH") + " SAH " 
		cQuery += " ON SAH.AH_UNIMED = NNT.NNT_UM "
		cQuery += " AND SAH.AH_FILIAL = '" + xFilial('SAH') + "' "
		cQuery += " AND SAH.D_E_L_E_T_=' ' "
	
		cQuery += " WHERE "
		cQuery += " NNT.NNT_COD = '" + cSelDoc + "' " 
		cQuery += " AND NNT.D_E_L_E_T_ = ''
		cQuery += " ORDER BY NNT.R_E_C_N_O_ "

ELSE
	cQuery := "SELECT SD3.D3_EMISSAO, SD3.D3_TM, SD3.D3_CF, SD3.D3_LOCAL, SD3.D3_CONTA, "
	cQuery += "SD3.D3_COD, SD3.D3_QUANT, SB1.B1_DESC, SAH.AH_CODOKEI, SAH.AH_UMRES, "
	cQuery += "SB2.B2_CM1, SD3.D3_CUSTO1, SD3.R_E_C_N_O_, SBE.BE_DESCRIC, CASE WHEN NNR_TIPO='1' THEN '" ;
			+ STR0001 + "' WHEN NNR_TIPO='2' THEN '" + STR0002 + "' ELSE '" + STR0003 + "' END AS TIPONAME "
	cQuery += "FROM " + RetSqlName("SD3") + " SD3 "

	cQuery += "INNER JOIN " + RetSqlName("NNR") + " NNR "
	cQuery += "ON NNR.NNR_CODIGO = SD3.D3_LOCAL " 
	cQuery += "AND NNR.NNR_FILIAL = '" + xFilial('NNR') + "' "

	cQuery += "INNER JOIN " + RetSqlName("SBE") + " SBE " 
	cQuery += "ON SBE.BE_LOCAL = SD3.D3_LOCAL "
	cQuery += "AND SBE.BE_LOCALIZ = SD3.D3_LOCALIZ "
	cQuery += "AND SBE.BE_FILIAL = '" + xFilial('SBE') + "' "

	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 " 
	cQuery += "ON SB1.B1_COD = SD3.D3_COD "
	cQuery += "AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' "

	cQuery += "INNER JOIN " + RetSqlName("SAH") + " SAH " 
	cQuery += "ON SAH.AH_UNIMED = SD3.D3_UM "
	cQuery += "AND SAH.AH_FILIAL = '" + xFilial('SAH') + "' "

	cQuery += "INNER JOIN " + RetSqlName("SB2") + " SB2 "
	cQuery += "ON SB2.B2_COD = SB1.B1_COD "
	cQuery += "AND SB2.B2_LOCAL = SB1.B1_LOCPAD "
	cQuery += "AND SB2.B2_FILIAL = '" + xFilial('SB2') + "' "

	cQuery += "WHERE SD3.D3_CF IN ('DE4', 'RE4') "
	cQuery += "AND SD3.D_E_L_E_T_=' ' " 
	cQuery += "AND NNR.D_E_L_E_T_=' ' "
	cQuery += "AND SB1.D_E_L_E_T_=' ' " 
	cQuery += "AND SB2.D_E_L_E_T_=' ' " 
	cQuery += "AND SAH.D_E_L_E_T_=' ' " 
	cQuery += "AND SD3.D3_DOC = '" + cSelDoc + "' " 
	cQuery += "AND SD3.D3_EMISSAO = '" + cEmissao + "' "
	cQuery += "ORDER BY R_E_C_N_O_ "
ENDIF

	cQuery := ChangeQuery(cQuery)

	cAliasTMP := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)

	/*--------------FULLNAM---------------------------ADDRESS-------------------PHONENU---------------*/
	cADDRESS := AllTrim(aCDate[4][2])+ ',' + AllTrim(aCDate[9]) + ', ' + AllTrim(aCDate[5][2]) +  ', '+ STR0004 + AllTrim(aCDate[2][2]) + ', '+ STR0004 + AllTrim(aCDate[1][2]) + "."
	
	WHILE AT(', ,', cADDRESS) != 0
		cADDRESS := StrTran(cADDRESS,', ,',',')
	ENDDO
	
	cADDRESS := StrTran(cADDRESS,', .','.')
	
	WHILE AT(',,', cADDRESS) != 0
		cADDRESS := StrTran(cADDRESS,',,',',')
	ENDDO
	
	cADDRESS := StrTran(cADDRESS,',.','.')
	
	(cAliasTMP)->(dbGotop())
	
	While (cAliasTMP)->(!EOF()) //We read the temporary table and save the header so that they do not overflow while filling the table
		IF FWIsInCallStack("MATA311")

			IF ((cAliasTMP)->D3_CF == "RE4" .AND. aAliasHead[3]	== .F.)
				aAliasHead[2] 	:= (cAliasTMP)->TIPONAME
				IF (cAliasTMP)->D3_LOCAL == '90'
					aAliasHead[1]	:= (cAliasTMP)->BE_DESCRIC // D3_LOCAL1 //5H
				ELSE
					aAliasHead[1]	:= (cAliasTMP)->NNR_DESCRI
				ENDIF
				aAliasHead[3]	:= .T.
			ELSEIF ((cAliasTMP)->D3_CF == "DE4" .AND. aAliasHead[6]	== .F.)
				aAliasHead[5] 	:= (cAliasTMP)->TIPONAME
				IF (cAliasTMP)->D3_LOCAL == '90'
					aAliasHead[4]	:= (cAliasTMP)->BE_DESCRIC // D3_LOCAL2 //7H
				ELSE
					aAliasHead[4]	:= (cAliasTMP)->NNR_DESCRI
				ENDIF
				aAliasHead[6]	:= .T.
			ELSEIF empty((cAliasTMP)->D3_CF)
				aAliasHead[1] 	:="-"
				aAliasHead[2]	:="-"
				aAliasHead[3]	:=.T.
				aAliasHead[4]	:="-"
				aAliasHead[5]	:="-"
				aAliasHead[6]	:=.T.
			ENDIF
		ELSE
			IF ((cAliasTMP)->D3_TM == "999" .AND. aAliasHead[3]	== .F.)
				aAliasHead[1] 	:= (cAliasTMP)->D3_LOCAL
				IF (cAliasTMP)->D3_LOCAL == '90'
					aAliasHead[2]	:= (cAliasTMP)->BE_DESCRIC
				ELSE
					aAliasHead[2]	:= (cAliasTMP)->NNR_DESCRI
				ENDIF
				aAliasHead[3]	:= .T.
			ELSEIF ((cAliasTMP)->D3_TM == "499" .AND. aAliasHead[6]	== .F.)
				aAliasHead[4] 	:= (cAliasTMP)->D3_LOCAL
				IF (cAliasTMP)->D3_LOCAL == '90'
					aAliasHead[5]	:= (cAliasTMP)->BE_DESCRIC
				ELSE
					aAliasHead[5]	:= (cAliasTMP)->NNR_DESCRI
				ENDIF
				aAliasHead[6]	:= .T.
			ElseIf Empty((cAliasTMP)->D3_TM)
				aAliasHead[1] 	:="-"
				aAliasHead[2]	:="-"
				aAliasHead[3]	:=.T.
				aAliasHead[4]	:="-"
				aAliasHead[5]	:="-"
				aAliasHead[6]	:=.T.
			ENDIF
		ENDIF
			(cAliasTMP)->(dbSkip())
	ENDDO

	(cAliasTMP)->(dbGotop())

	While (cAliasTMP)->(!EOF())
		If  ((cAliasTMP)->D3_CF == 'RE4') .or. empty((cAliasTMP)->D3_CF)  //We read the temporary table, take the values where D3_CF == 'RE4' to exclude duplicates
			RecLock(cAliasMov,.T.)
			CO_DATA := cADDRESS
			CO_OKPO := aCDate[3][2]
			HEADTYPE := STR0005

			Q3_DESCSU1 	:= aSigners[1][3]	
			RA_NOME1 	:= aSigners[1][2]
			Q3_DESCSU2 	:= aSigners[2][3]
			RA_NOME2 	:= aSigners[2][2]
			H10REQUEST 	:= aSigners[3][3] + " " + aSigners[3][2]
			H11APPROV 	:= aSigners[4][3] + " " + aSigners[4][2]
			H12USNAME 	:= aSigners[5][3] + " " + aSigners[5][2]
			
			D3_LOCAL1	:= aAliasHead[1] 
			NR_DESCRI1	:= aAliasHead[2]
			D3_LOCAL2	:= aAliasHead[4]
			NR_DESCRI2	:= aAliasHead[5]

			H9_CONTA	:= " "
			H13OpType	:= " "
			H14ARec		:= " "
			H15AccUnit	:= " "
			I16ARec		:= " "
			I17SerNum	:= " "

			IF (LEN(cSelDoc) > 10 )
				D3_DOC := CVALTOChar(VAL(RIGHT(cSelDoc, 10)))
			ELSE
				D3_DOC	:= CVALTOChar(VAL(cSelDoc))
			ENDIF
			
				D3_EMISSAO  := DTOC (STOD ((cAliasTMP)->D3_EMISSAO))
				B1_DESC		:= (cAliasTMP)->B1_DESC
				AH_CODOKEI	:= (cAliasTMP)->AH_CODOKEI

				IF FWIsInCallStack("MATA311")
					NNT_QUANT 	:= (cAliasTMP)->NNT_QUANT
					D3_QUANT	:= (cAliasTMP)->NNT_QUANT
					B1_UPRC		:= (cAliasTMP)->D3_CUSTO1 / (cAliasTMP)->D3_QUANT
					D3_CUSTO1	:= (cAliasTMP)->D3_CUSTO1 / (cAliasTMP)->D3_QUANT * 0.8
					D3_COD		:= (cAliasTMP)->NNT_PROD
					D3_CONTA	:= (cAliasTMP)->B1_CONTA
					AH_UMRES	:= (cAliasTMP)->AH_DESCPO
				ELSE
					NNT_QUANT 	:= (cAliasTMP)->D3_QUANT
					D3_QUANT	:= (cAliasTMP)->D3_QUANT
					B1_UPRC		:= (cAliasTMP)->B2_CM1
					D3_CUSTO1	:= (cAliasTMP)->D3_CUSTO1
					D3_COD		:= (cAliasTMP)->D3_COD
					D3_CONTA	:= (cAliasTMP)->D3_CONTA
					AH_UMRES	:= (cAliasTMP)->AH_UMRES
				ENDIF

				If ExistBlock("RU04R01I")
					H9_CONTA 	:= ExecBlock('RU04R01I',.T.,.T.,'H9_CONTA')
					H13OpType	:= ExecBlock('RU04R01I',.T.,.T.,'H13OpType')
					H14ARec		:= ExecBlock('RU04R01I',.T.,.T.,'H14ARec')
					H15AccUnit	:= ExecBlock('RU04R01I',.T.,.T.,'H15AccUnit')
					I16ARec		:= ExecBlock('RU04R01I',.T.,.T.,'I16ARec')
					I17SerNum	:= ExecBlock('RU04R01I',.T.,.T.,'I17SerNum')
					NR_DESCRI1	:= ExecBlock('RU04R01I',.T.,.T.,'NR_DESCRI1')
					NR_DESCRI2	:= ExecBlock('RU04R01I',.T.,.T.,'NR_DESCRI2')
					HEADTYPE	:= ExecBlock('RU04R01I',.T.,.T.,'HEADTYPE')
				Endif
			MsUnlock()
		Endif

		(cAliasTMP)->(dbSkip())
	EndDo

	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
Return .T.

/*------------------------get full address-----------------------------------------------------*/
/*Din: We need to have 1 enter point. It should be MPCompaRUS.
Because of this I use GetCoBrRUS, that returns a lot of information and adresses (in the [3][..][..]). 
In future we will organize a special unic function for this. It's a tech debt. 
*/
Static Function GetAdress()
	Local cAgaFull as Char
	Local aCobrRUS:=GetCoBrRUS()
	// if  AGA_TIPO == '0' then aAddres Legal. use index 1
	If !Empty(aCobrRUS[3]) .AND. !Empty(aCobrRUS[3][1]) .AND. !Empty(aCobrRUS[3][1][22])
		cAgaFull := aCobrRUS[3][1][22]
	Else
		cAgaFull:= ''		
		Help(" ",1,"ADDRNOTEX2")
	EndIF
Return cAgaFull
/*---------------------------------------------------------------------------------------------*/
                   
//Merge Russia R14 
                   
                   
