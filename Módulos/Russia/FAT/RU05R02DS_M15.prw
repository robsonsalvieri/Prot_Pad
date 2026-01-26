#include "protheus.ch"
#Include 'birtdataset.ch'
#include "TOPCONN.CH"
#include "RU05R02.CH"

/*
Autors:			Artem Nikitenko.
Data:			29/03/18
Description: 	Data set in birt format
*/
 
dataset RU05R02DS
Title 'M-15'
Description "M-15"

	PERGUNTE "RU05R02DS" 

Columns

define Column A1_DOC		TYPE CHARACTER SIZE 20 LABEL	'A1_DOC'			//A1 System document number  F2_DOC
define Column A2_OKPO		TYPE CHARACTER SIZE 200 LABEL	'A2_OKPO'			//A2 OKPO code
define Column A3_DATA		TYPE CHARACTER SIZE 200 LABEL	'A3_DATA'			//A3 Company data
define Column A4_DOC		TYPE CHARACTER SIZE 12 LABEL	'A4_DOC'			//A4 Document date F2_EMISSAO
	
define Column A5_WHDESC		TYPE CHARACTER SIZE 200 LABEL 	'A5_WHDESC'			//A5 Warehouse description D2_LOCAL
define Column A5A_WARHN		TYPE CHARACTER SIZE 200 LABEL 	'A5A_WARHN'			//A5a type of warehouse
define Column A6_CONTAC		TYPE CHARACTER SIZE 200 LABEL 	'A6_CONTAC'			//A6 External sales contract date and number
define Column A7_CLIENT		TYPE CHARACTER SIZE 100 LABEL 	'A7_CLIENT'			//A7 Client�s name F2_CLIENTE
define Column A8_PACCOU		TYPE CHARACTER SIZE 200 LABEL	'A8_PACCOU'			//A8 Product account D2_CONTA
define Column A9_PDESC		TYPE CHARACTER SIZE 200 LABEL	'A9_PDESC'			//A9 Product description  B1_DESC
define Column A10_PCOD		TYPE CHARACTER SIZE 20 LABEL	'A10_PCOD'			//A10 Product (material) code D2_COD
define Column A11_OKEI		TYPE CHARACTER SIZE 20 LABEL	'A11_OKEI'			//A11 Base unit of measure system code (OKEI code) date AH_COD_CO
define Column A12_CODERP	TYPE CHARACTER SIZE 20 LABEL	'A12_CODERP'		//A12 Base unit of measure OKEI name AH_CODERP
define Column A13_QUANT		like D2_QUANT										//A13 Quantity  D2_QUANT
define Column A14_PRCVEN	like D2_PRCVEN										//A14 Price per base unit D2_PRCVEN
define Column A15_TOTAL		like D2_TOTAL										//A15 Total amount without VAT value D2_TOTAL
define Column A16_VATVAL	like D2_VALIMP1										//A16 VAT value D2_VALIMP1
define Column A17_TOTVAL	like D2_TOTAL										//A17 Total amount including VAT value D2_TOTAL + D2_VALIMP1
define Column A18_ATOTAL	like D2_TOTAL										//A18 amount total
define Column A19			TYPE CHARACTER SIZE 5 LABEL	 'A19'					//A19 " - "

define Column B1_PACCOU		TYPE CHARACTER SIZE 60 LABEL 'B1_PACCOU'			//B1 Product account D2_CONTA
define Column B2_PDESC		TYPE CHARACTER SIZE 60 LABEL 'B2_PDESC'				//B2 Product description  B1_DESC
define Column B3_PCOD		TYPE CHARACTER SIZE 60 LABEL 'B3_PCOD'				//B3 Product (material) code  D2_COD
define Column B4_OKEI		TYPE CHARACTER SIZE 60 LABEL 'B4_OKEI'				//B4 Base unit of measure system code (OKEI code)  AH_COD_CO
define Column B5_CODERP		TYPE CHARACTER SIZE 60 LABEL 'B5_CODERP'			//B5 Base unit of measure OKEI name	AH_CODERP
define Column B6_QUANT		like D2_QUANT 										//B6 Quantity D2_QUANT
define Column B7_PRCVEN		like D2_PRCVEN										//B7 Price per base unit D2_PRCVEN
define Column B8_TOTAL		like D2_TOTAL										//B8 Total amount without VAT value D2_TOTAL
define Column B9_VATVAL		like D2_VALIMP1										//B9  VAT value	D2_VALIMP1
define Column B10_TOTVAL	like D2_TOTAL										//B10  Total amount including VAT value	D2_TOTAL + D2_VALIMP1
define Column B11_QUANT		TYPE CHARACTER SIZE 60 LABEL 'D2_QUANT'				//B11  Quantity value in words from B6	D2_QUANT
define Column B12_TOTVAL	TYPE CHARACTER SIZE 60 LABEL 'B12_TOTVAL'			//B12  Total amount including VAT value in words from B10	 D2_TOTAL + D2_VALIMP1 
define Column B12_TOTVA2	TYPE CHARACTER SIZE 60 LABEL 'B12_TOTVA2'			//B12  Total amount including VAT value in words from B10	 D2_TOTAL + D2_VALIMP1
define Column B21_QUANT 	TYPE NUMERIC   SIZE 14 DECIMALS 2 LABEL 'B21_QUANT'	//B21  Quantity to be delivered

define Column B13_VATVAL	TYPE CHARACTER SIZE 60 LABEL 'B13_VATVAL'			//B13  VAT value	D2_VALIMP1 was changed
define Column B13_VATVA2	TYPE CHARACTER SIZE 60 LABEL 'B13_VATVA2'	

//signers
define Column B14_SPOS		TYPE CHARACTER SIZE 60 LABEL 'B14_SPOS'				//B14  Established position of �Director� role
define Column B15_SNAME		TYPE CHARACTER SIZE 60 LABEL 'B15_SNAME'			//B15  A name for �Director� role
define Column B16_SNAME		TYPE CHARACTER SIZE 60 LABEL 'B16_SNAME'			//B16  A name for �Chief accountant� role
define Column B17_SPOS		TYPE CHARACTER SIZE 60 LABEL 'B17_SPOS'				//B17  Established position of �Stockman� role
define Column B18_SNAME		TYPE CHARACTER SIZE 60 LABEL 'B18_SNAME'			//B18  A name for �Stockman� role
define Column B19_SPOS		TYPE CHARACTER SIZE 60 LABEL 'B19_SPOS'				//B19  Established position of �Stockman� role
define Column B20_SNAME		TYPE CHARACTER SIZE 60 LABEL 'B20_SNAME'			//B20  A name for �Stockman� role

define query 	"SELECT * FROM %WTable:1% "

process dataset

Local cWTabAlias as char
Local cMvpar01 	 as char 		//Director B14-B15
Local cMvpar02 	 as char 		//�h. Accountant B16
Local cMvpar03 	 as char 		//Stockman b17-b18
Local cMvpar04 	 as char 		//Stockman b19-b20

Local cSelFil  	 as char 
Local cEmissao 	 as char
Local cSelDoc  	 as char
Local lRet     	 as logical
local cClient  	 as char
local cSerie   	 as char

lRet 	:= .F.
cWTabAlias := self:createWorkTable()

chkFile("SF2")
cSelDoc  := SF2->F2_DOC
cSelFil  := SF2->F2_FILIAL
cEmissao := DTOC(SF2->F2_EMISSAO)
cClient  := SF2->F2_CLIENTE
cSerie 	 := SF2->F2_SERIE

cSelFil  :=strtran(cSelFil,'"',"")
cSelDoc  :=strtran(cSelDoc,'"',"")
cEmissao :=strtran(cEmissao,'"',"")
cClient  :=strtran(cClient,'"',"")
cSerie   :=strtran(cSerie,'"',"")

cMvpar01 := alltrim(self:execParamValue( "MV_PAR01" ))  //Director B14-B15
cMvpar02 := alltrim(self:execParamValue( "MV_PAR02" ))	//�h. Accountant B16
cMvpar03 := alltrim(self:execParamValue( "MV_PAR03" )) 	//Stockman b17-b18

If AScan(self:aexecparams,{|X|x[1] == 'MV_PAR04'}) > 0

	cMvpar04 := alltrim(self:execParamValue( "MV_PAR04" ))  //Stockman b19-b20
	If empty(cMvpar04)
		cMvpar04 := ''
	Endif

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

Processa({|_lEnd| lRet := X60NOT(cWTabAlias,cSelDoc,cSelFil,cEmissao,cMvpar01,cMvpar02,cMvpar03,cMvpar04,cClient,cSerie)}, ::title())

Return .T.

/* = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =*/

static function X60NOT(cAliasMov, cSelDoc, cSelFil, cEmissao, cMvpar01,cMvpar02,cMvpar03,cMvpar04,cClient,cSerie)
	Local aArea 	as array
	Local aCData 	as array
	Local aSigners 	as array
	Local cAliasTMP as Char
	Local cQuery	as Char
	local cSend 	as Char
	Local CFdata 	as Char
	Local nTotVal,nTotQua,nVatVal as Numeric
	Local lEBlockSQL as logical
	Local cKeyOfReport as Char

	lEBlockSQL:=.F.
	nTotVal := 0
	nTotQua := 0
	nVatVal := 0

	cKeyOfReport:="IN ('M-15', 'ALL', 'M15')" //SQL part
	aSigners := {}
	aadd (aSigners, RU06D01GetSigner(cMvpar01,cKeyOfReport)) 	//Director CHFDIR B14-B15
	aadd (aSigners, RU06D01GetSigner(cMvpar02,cKeyOfReport)) 	//Chf. Accountant CHFACC B16 
	aadd (aSigners, RU06D01GetSigner(cMvpar03,cKeyOfReport)) 	//Stockman STCMAN b17-b18

	If !Empty(cMvpar04)
		aadd (aSigners, RU06D01GetSigner(cMvpar04,cKeyOfReport)) 	//Stockman STCMAN b19-b20
	Endif

	aArea := getArea()

	aCData := FwComAltInf({'CO_OKPO','CO_FULLNAM','CO_COMPGRP','CO_COMPEMP','CO_TIPO','CO_PHONENU','CO_COMPUNI'})
	
	aadd(aCData,GetAdress())

	If !empty(aCData) .AND. !empty(aCData[8])

		WHILE AT(', ,', aCData[8])!=0
			aCData[8] := StrTran(aCData[8],', ,',',')
		ENDDO
		aCData[8] := StrTran(aCData[8],', .','.')
		WHILE AT(',,', aCData[8])!=0
			aCData[8] := StrTran(aCData[8],',,',',')
		ENDDO
		aCData[8] := StrTran(aCData[8],',.','.')

	Else
		Help(" ",1,"ADDRNOTEX2")
	Endif

	cQuery := "SELECT SF2.F2_DOC, SF2.F2_EMISSAO, SF2.F2_CLIENTE, SD2.D2_CONTA, SB1.B1_DESC, SD2.D2_COD, NNR.NNR_DESCRI, "
	cQuery += "SAH.AH_CODOKEI, SAH.AH_UMRES, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_VALIMP1, "
	cQuery += "COALESCE(SA1.A1_NOME,'') A1_NOME, COALESCE(SA2.A2_NOME,'') A2_NOME, F5Q_DESCR "
	If ExistBlock("RU05R02S")
		cQuery += ExecBlock('RU05R02S',.T.,.T.,'1')
		lEBlockSQL:=.T.
	Endif
	cQuery += "FROM " + RetSqlName("SF2") + " SF2 "

	cQuery += "INNER JOIN " + RetSqlName("SD2") + " SD2 "
	cQuery += "ON  SD2.D2_FILIAL  = SF2.F2_FILIAL "
	cQuery += "AND SD2.D2_DOC 	  = SF2.F2_DOC "
	cQuery += "AND SD2.D2_SERIE	  = SF2.F2_SERIE  "
	cQuery += "AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
	cQuery += "AND SD2.D2_LOJA	  = SF2.F2_LOJA "
	cQuery += "AND SD2.D2_TIPODOC = SF2.F2_TIPODOC "
	cQuery += "AND SD2.D2_ESPECIE = SF2.F2_ESPECIE "
	cQuery += "AND SD2.D2_TIPODOC = SF2.F2_TIPODOC "
	cQuery += "AND SD2.D2_FILIAL  = '" + cSelFil + "' "
	cQuery += "AND SD2.D_E_L_E_T_ = '' "

	cQuery += "INNER JOIN " + RetSqlName("SAH") + " SAH "
	cQuery += "ON SAH.AH_UNIMED = SD2.D2_UM "
	cQuery += "AND SAH.D_E_L_E_T_ = '' "
	cQuery += "AND SAH.AH_FILIAL = '"+xFilial('SAH')+"' "

	cQuery += "INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "ON SB1.D_E_L_E_T_ = '' "
	cQuery += "AND B1_COD = D2_COD "
	cQuery += "AND SB1.B1_FILIAL = '"+xFilial('SB1')+"' "

	cQuery += "INNER JOIN " + RetSqlName("NNR") + " NNR "
	cQuery += "ON NNR.D_E_L_E_T_ = '' "
	cQuery += "AND D2_FILIAL = NNR_FILIAL "
	cQuery += "AND D2_LOCAL = NNR_CODIGO "

	cQuery += "LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "ON SA1.D_E_L_E_T_ = '' "
	cQuery += "AND SF2.F2_CLIENTE = A1_COD "
	cQuery += "AND SA1.A1_FILIAL = '"+xFilial('SA1')+"' "

	cQuery += "LEFT JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery += "ON SA2.D_E_L_E_T_ = '' "
	cQuery += "AND SF2.F2_CLIENTE = A2_COD "
	cQuery += "AND SA2.A2_FILIAL = '"+xFilial('SA2')+"' "

	cQuery += "LEFT JOIN " + RetSqlName("F5Q") + " F5Q "
	cQuery += "ON F5Q.D_E_L_E_T_ = '' "
	cQuery += "AND F5Q.F5Q_A1COD = A1_COD "
	cQuery += "AND F5Q.F5Q_FILIAL = '"+xFilial('SA2')+"' "

	cQuery += "WHERE SF2.F2_FILIAL = '" + cSelFil + "' "
	cQuery += "AND SF2.D_E_L_E_T_ = '' "
	cQuery += "AND SF2.F2_DOC = '" + cSelDoc + "' "
	cQuery += "AND SF2.F2_CLIENTE = '" + cClient + "' "
	cQuery += "AND SF2.F2_SERIE = '" + cSerie + "' "

	cQuery := ChangeQuery(cQuery)

	cAliasTMP := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)

	/*--------------FULLNAM-------------------ADDRESS------------*/
	CFdata := AllTrim(aCData[2][2]) + ', ' + AllTrim(aCData[8]) + ', ' + AllTrim(aCData[6][2]) + "."
	WHILE AT(', ,', CFdata)!=0
		CFdata := StrTran(CFdata,', ,',',')
	ENDDO
	CFdata := StrTran(CFdata,', .','.')
	WHILE AT(',,', CFdata)!=0
		CFdata := StrTran(CFdata,',,',',')
	ENDDO
	CFdata := StrTran(CFdata,',.','.')
	A19 := " "
	(cAliasTMP)->(dbGotop())
	While (cAliasTMP)->(!EOF())
		RecLock(cAliasMov,.T.)

		PadR((cAliasTMP)->A1_NOME,GetSX3Cache("A1_NOME","X3_TAMANHO")," ")
		PadR((cAliasTMP)->A2_NOME,GetSX3Cache("A2_NOME","X3_TAMANHO")," ")

		A1_DOC		:= Alltrim(cValToChar(Val(((cAliasTMP)->F2_DOC)))) 		//A1 System document number  F2_DOC
		A2_OKPO 	:= aCData[1][2] 										//A2 OKPO code
		A3_DATA		:= CFdata 												//A3 Company data
		A4_DOC		:= cEmissao 											//A4 Document date F2_EMISSAO

		A5_WHDESC	:= (cAliasTMP)->NNR_DESCRI								//A5 Warehouse description D2_LOCAL NNR_DESCRI
		A5A_WARHN	:= ''
		A6_CONTAC	:= ''					  								//A6 External sales contract date and number Should be informed MANUALLY
		A8_PACCOU	:= (cAliasTMP)->D2_CONTA								//A9 Product description  B1_DESC
		cSend 		:= AllTrim((cAliasTMP)->A1_NOME)

		If ExistBlock("RU05R02I")
			A6_CONTAC	:= (cAliasTMP)->F5Q_DESCR 							//A6 External sales contract date and number
			A8_PACCOU	:= (cAliasTMP)->A2_NOME
			B21_QUANT	:= (cAliasTMP)->D2_QUANT							//B21 Quantity D2_QUANT
			cSend 		:= AllTrim((cAliasTMP)->A2_NOME)
		Endif
		
		If lEBlockSQL
			A5A_WARHN:=(cAliasTMP)->TIPONAME
		Endif

		WHILE AT(', ,', cSend)!=0
			cSend := StrTran(cSend,', ,',',')
		ENDDO
		cSend := StrTran(cSend,', .','.')
		WHILE AT(',,', cSend)!=0
			cSend := StrTran(cSend,',,',',')
		ENDDO
		cSend := StrTran(cSend,',.','.')

		A7_CLIENT	:= cSend 						//A7 Client name F2_CLIENTE  A2_NOME
		A9_PDESC	:= (cAliasTMP)->B1_DESC			//A9 Product description  B1_DESC
		A10_PCOD	:= (cAliasTMP)->D2_COD			//A10 Product (material) code D2_COD
		A11_OKEI	:= (cAliasTMP)->AH_CODOKEI		//A11 Base unit of measure system code (OKEI code) date AH_COD_CO
		A12_CODERP	:= (cAliasTMP)->AH_UMRES		//A12 Base unit of measure OKEI name AH_CODERP
		A13_QUANT	:= (cAliasTMP)->D2_QUANT		//A13 Quantity  D2_QUANT

		A14_PRCVEN	:= (cAliasTMP)->D2_PRCVEN		//A14 Price per base unit D2_PRCVEN

		A15_TOTAL	:= (cAliasTMP)->D2_PRCVEN		//A15 Total amount without VAT
		A16_VATVAL	:= (cAliasTMP)->D2_TOTAL		//A16 VAT value D2_VALIMP1
		A17_TOTVAL	:= (cAliasTMP)->D2_VALIMP1		//A17 Total amount
		A18_ATOTAL	:= (((cAliasTMP)->D2_TOTAL) + ((cAliasTMP)->D2_VALIMP1)) ///A18 amount total 
		
		IF empty(A19)
			A19 := " - "
		END

		B1_PACCOU	:= (cAliasTMP)->D2_CONTA		//B1 Product account D2_CONTA
		B2_PDESC	:= (cAliasTMP)->B1_DESC			//B2 Product description  B1_DESC
		B3_PCOD		:= (cAliasTMP)->D2_COD			//B3 Product (material) code  D2_COD
		B4_OKEI		:= (cAliasTMP)->AH_CODOKEI		//B4 Base unit of measure system code (OKEI code)  AH_COD_CO
		B5_CODERP	:= (cAliasTMP)->AH_UMRES		//B5 Base unit of measure OKEI name	AH_CODERP
		B6_QUANT	:= (cAliasTMP)->D2_QUANT		//B6 Quantity D2_QUANT
		B7_PRCVEN	:= (cAliasTMP)->D2_PRCVEN		//B7 Price per base unit D2_PRCVEN

		B8_TOTAL	:= (cAliasTMP)->D2_TOTAL 		//B8 Total amount without VAT value D2_TOTAL
		B9_VATVAL	:= (cAliasTMP)->D2_VALIMP1		//B9  VAT value	D2_VALIMP1
		B10_TOTVAL	:= (((cAliasTMP)->D2_TOTAL) + ((cAliasTMP)->D2_VALIMP1))//B10  Total amount including VAT value	D2_TOTAL + D2_VALIMP1
		
		B14_SPOS	:= AllTrim(aSigners[1][1]) 		//B14
		B15_SNAME	:= AllTrim(aSigners[1][2]) 		//B15
		B16_SNAME	:= AllTrim(aSigners[2][2]) 		//B16
		B17_SPOS	:= AllTrim(aSigners[3][1]) 		//B17
		B18_SNAME	:= AllTrim(aSigners[3][2]) 		//B18

		If !Empty(cMvpar04)
			B19_SPOS	:= AllTrim(aSigners[4][1]) 	//B19
			B20_SNAME	:= AllTrim(aSigners[4][2]) 	//B20
		Endif
		
		nVatVal		:= nVatVal + (cAliasTMP)->D2_VALIMP1		//B13  VAT value	D2_VALIMP1
		B13_VATVAL	:= Alltrim(str(noround(nVatVal,0)))
		if 	Decimal(nVatVal)==0
			B13_VATVA2 := '00'
		else
			B13_VATVA2 	:= alltrim(str(Decimal(nVatVal)))
		Endif
		
		nTotQua		:= nTotQua + (cAliasTMP)->D2_QUANT
		B11_QUANT	:= ALLTRIM(RU99X01(nTotQua,.T.,'1'))	//B11  Quantity value in words from B6	D2_QUANT
		
		nTotVal 	:= nTotVal + (((cAliasTMP)->D2_TOTAL) + ((cAliasTMP)->D2_VALIMP1))
		B12_TOTVAL	:= ALLTRIM(RU99X01(nTotVal,.T.,'1'))
		if Decimal(nTotVal) == 0
			B12_TOTVA2	:= STR0002
		else
			B12_TOTVA2 	:= ALLTRIM(RU99X01(Decimal(nTotVal),.T.,'1'))
		endif
		
		MsUnlock()
		(cAliasTMP)->(dbSkip())
	EndDo
	
	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
return .T.

/*------------------------get full address-----------------------------------------------------*/
/*We need to have 1 enter point. It should be MPCompaRUS.
Because of this I use GetCoBrRUS, that returns a lot of information and adresses (in the [3][..][..]). 
In future we will organize a special unic function for this. It's a tech debt. 
*/
static function GetAdress()
	local cRet as Char
	local aAdr as Array

	// if  AGA_TIPO == '1' then aAddres Phisical. use index 2
	aAdr := GetCoBrRUS()
	If  !empty(aAdr[3]) .AND. !empty(aAdr[3][2]) .AND. !empty(aAdr[3][2][22])
		cRet := aAdr[3][2][22]
	Else
		cRet := " "
	ENDIF

return cRet
// Russia_R5                   
//Merge Russia R14 
                   
                   
