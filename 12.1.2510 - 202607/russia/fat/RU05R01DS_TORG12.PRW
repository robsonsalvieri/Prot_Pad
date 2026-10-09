#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"

Dataset RU05R01DS
	Title "TORG 12"
	Description "TORG 12 FORM"
	PERGUNTE "RU05R01DS"

SX3->(DbSetorder(2))

Columns
	Define Column CO_NAME TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Full name'//1H
	Define Column CO_ADDRESS TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Actual addr.'//1H
	Define Column CO_KPP TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'KPP'//1H
	Define Column CO_INN TYPE CHARACTER SIZE 12 DECIMALS 0 LABEL 'INN'//1H

	Define Column CO_OKPO TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'OKPO'//2H

	Define Column CL_NAME 		TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Full name 2'
	Define Column CL_ADDRESS	TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Customer data'//3H
	Define Column CL_INN		TYPE CHARACTER SIZE 12 DECIMALS 0 LABEL 'INN'
	Define Column CL_KPP		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'KPP'//1H
	Define Column CL_OKPO		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'CL_OKPO'//like A1_OKPO

	Define Column FI_NAME 		TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Full name'//LIKE ZD_FULL//4H
	Define Column FI_ADDRESS	TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL 'Actual addr.'//LIKE ZD_ACTADRE//4H
	Define Column FI_KPP		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'KPP'//LIKE ZD_KPP//4H
	Define Column FI_DATA		TYPE CHARACTER SIZE 200 DECIMALS 0 LABEL "Supplier's data"//4H
	Define Column FI_OKPO		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'FI_OKPO'//LIKE ZD_OKPO//4H

	Define Column H_CONTRACT	TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'Contract number 7H' //7H
	Define Column CO_DTEST TYPE CHARACTER SIZE 255 DECIMALS 0 LABEL "Deliverer data"

	Define Column H_DOC			TYPE NUMERIC SIZE 20 DECIMALS 0 LABEL 'System Document number 8H'//8H
	Define Column H_IDATE 		TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL 'Posting Date9H'//9H CHECK

	Define Column H_DDATE 		TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Isue date day'
	Define Column H_MDATE 		TYPE NUMERIC SIZE 2 DECIMALS 0 LABEL 'Isue date month'
	Define Column H_YDATE 		TYPE NUMERIC SIZE 4 DECIMALS 0 LABEL 'Isue date year'

	Define Column H_CURRENCY 	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'Currency Code'
	Define Column H_CURDESC		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'Currency Description'

	Define Column IT_ITEM		like D2_ITEM//1I
	Define Column IT_ITEMDSC	LIKE C6_DESCRI//2I
	Define Column IT_MATCODE 	TYPE CHARACTER SIZE 12//3I
	Define Column IT_MEASCOD	like AH_CODERP//4I
	Define Column IT_MEASDES	like AH_UMRES//5I
	Define Column IT_GRWEIGH	like D2_PESO//9I
	Define Column IT_DESC		like D2_DESC
	Define Column IT_QUANT		like D2_QUANT//10I
	Define column IT_UM			like D2_UM
	Define column IT_UMDESC		TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'UM DESCRIPTION'
	Define Column IT_UNIT_PR	like D2_PRCVEN
	Define Column IT_VALUE 		TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Item value'
	Define Column IT_EXCISE		like D2_VALIMP2
	Define Column IT_VAT_RAT	like D2_ALQIMP1
	Define Column IT_VAT		like D2_VALIMP1
	Define Column IT_VALTOT		TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Item total value'

	Define Column IT_COUNTRY	TYPE CHARACTER SIZE 3 DECIMALS 0 LABEL 'Country origin of goods code'
	Define Column IT_DESC_CO	TYPE CHARACTER SIZE 20 DECIMALS 0 LABEL 'Country origin of goods description'
	Define Column IT_CUSTOMS	TYPE CHARACTER SIZE 10 DECIMALS 0 LABEL 'Customs declaration'
	Define Column IT_NUM		TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Item number'
	Define Column IT_NUMTEXT	TYPE CHARACTER SIZE 80 DECIMALS 0 LABEL 'Text Item number'

	Define Column TOT_GOODS		TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Total goods value'
	Define Column TOT_EXCISE	like F2_VALIMP2
	Define Column TOT_VAT		like F2_VALIMP1
	Define Column TOT_VALUE 	TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Total value'
	Define Column TOT_VALUET	TYPE CHARACTER SIZE 110 DECIMALS 0 LABEL 'Text Total value'
	Define Column TOT_GWEIGH 	TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Total Gross Weight'
	Define Column TOT_QUANT 	TYPE NUMERIC SIZE 16 DECIMALS 2 LABEL 'Total Quant'
	Define Column F_CHIEFNAM	TYPE CHARACTER SIZE 200
	Define Column F_CHIEFBUH	TYPE CHARACTER SIZE 200
	Define Column F_STOCKMAN 	TYPE CHARACTER SIZE 200

	Define Column P_CHIEFNAM	TYPE CHARACTER SIZE 200
	Define Column P_CHIEFBUH	TYPE CHARACTER SIZE 200
	Define Column P_STOCKMAN 	TYPE CHARACTER SIZE 200
	/*Define Column TOT_CurRub	TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'Rubls'
	Define Column TOT_KOPEEK	TYPE CHARACTER SIZE 2 DECIMALS 0 LABEL 'Number Kopeikas'
	Define Column TOT_CurKop	TYPE CHARACTER SIZE 9 DECIMALS 0 LABEL 'Kopeikas'*/

	Define query 	"SELECT * FROM %WTable:1% WHERE %NotDel% ORDER BY IT_ITEM"

Process Dataset
	local cWTabAlias
	local cnt     := 0
	local lRet 	:= .f.
	Local cNotIni	:= SF2->F2_DOC
	Local cNotFin	:= SF2->F2_DOC
	Local aCodSigners as Array

    //cria a tabela
	cWTabAlias := ::createWorkTable()
	chkFile("SA1")

	aCodSigners := {}

	Aadd(aCodSigners,self:execParamValue( "MV_PAR01" ))
	Aadd(aCodSigners,self:execParamValue( "MV_PAR02" ))
	Aadd(aCodSigners,self:execParamValue( "MV_PAR03" ))

	Processa({|_lEnd| lRet := X60NOT(cWTabAlias,cNotIni,cNotFin,aCodSigners)}, ::title())

Return .T.



// static function GetSigners(cMvparN)
// 	Local aSigners 	as array
// 	Local cDESCSU 	as Char
// 	Local cRNome 	as Char
// 	Local cRANome 	as Char
// 	Local cAliasTM 	as Char
// 	Local cQuery 	as Char

// 	aSigners := {}
// 	If cMvparN==''
// 		cRANome := ''
// 		cDESCSU := ''
// 	Else	
// 		cQuery := "SELECT DISTINCT F42_NAME, Q3_DESCSUM "
// 		cQuery += "FROM " + RetSqlName("F42") + " F42 " 

// 		cQuery += "INNER JOIN " + RetSqlName("SQ3") + " SQ3 " 
// 		cQuery += "ON F42.F42_CARGO = SQ3.Q3_CARGO "
// 		cQuery += "AND SQ3.Q3_FILIAL = '"+xFilial('SQ3')+"' "

// 		cQuery += "AND F42.F42_EMPL = '" + cMvparN + "' " 
// 		cQuery += "AND F42.F42_REPORT IN ('TORG-12', 'ALL', 'TORG12') "
// 		cQuery += "AND F42.D_E_L_E_T_=' ' "
// 		cQuery += "AND SQ3.D_E_L_E_T_=' '"
	
// 		cQuery := ChangeQuery(cQuery)

// 		cAliasTM := GetNextAlias()

// 		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTM,.T.,.T.)
// 		DbSelectArea(cAliasTM)
// 		(cAliasTM)->(DbGoTop())
// 		cDESCSU := alltrim((cAliasTM)->Q3_DESCSUM)
// 		cRNome 	:= alltrim((cAliasTM)->F42_NAME)
		
// 		cRANome := alltrim(substr(alltrim(cRNome),1,(at(' ',alltrim(cRNome),1))))
// 		cRANome += ' ' + alltrim(substr(alltrim(cRNome),(at(' ',alltrim(cRNome),1)),2))
// 		cRANome += '.' + alltrim(substr(alltrim(cRNome),(at(' ',alltrim(cRNome),len(cRANome))),2)) +'.'		
// 		(cAliasTM)->(dbCloseArea())

// 	ENDIF
// 	Aadd(aSigners,cRANome)
// 	Aadd(aSigners,cDESCSU)
// 	Aadd(aSigners,cRNome)

// Return aSigners


Static Function GatherAdressData(aComData)
Local cAgaFull as char
Local oStatement := FWPreparedStatement():New()

cAddrKey := xFilial("SM0") + padr(aComData[1][1][2],Len(FwComAltInf({"XX8_GRPEMP"})[1][2]));
	+ padr(aComData[1][2][2],Len(FwComAltInf({"XX8_EMPR"})[1][2]));
	+ padr(aComData[1][4][2],Len(FwComAltInf({"XX8_CODIGO"})[1][2]))

cQuery := "SELECT AGA_FILIAL,AGA_CEP,AGA_BAIRRO,AGA_END,AGA_HOUSE,AGA_BLDNG,AGA_APARTM,AGA_MUNDES FROM "+RetSqlName("AGA")+" AGA WHERE AGA_TIPO = '0' AND AGA_ENTIDA = 'SM0' AND AGA_CODENT LIKE ? AND AGA_FILIAL = ? AND D_E_L_E_T_=' '"

oStatement:SetQuery(cQuery)
oStatement:SetLike(1,cAddrKey)
oStatement:SetString(2,FWxFilial('AGA'))

//TODO: Channge FWPreparedStatement later
cTab := MPSysOpenQuery(oStatement:GetFixQuery() ,"cTab")

cAgaFull := AllTrim(cTab->AGA_CEP)
cAgaFull += ", " + AllTrim(cTab->AGA_BAIRRO) + AllTrim(cTab->AGA_MUNDES)
cAgaFull += ", " + AllTrim(cTab->AGA_END)
cAgaFull += ", " + AllTrim(cTab->AGA_HOUSE)
cAgaFull += ", " + AllTrim(cTab->AGA_BLDNG)
cAgaFull += ", " + AllTrim(cTab->AGA_APARTM)
cAgaFull += "."

Return cAgaFull



Static Function X60NOT(cAliasMov, cNotIni,cNotFin,aCodSigners)
Local nTotVal := 0
Local nTotVat := 0
Local aComData as ARRAY
Local cLastBranch as char
Local cEmpAnt as char
Local cAgaFull as char
Local cAgaFull2 as char
Local cCHIEFNAM	as char	
Local cCHIEFBUH	as char
Local cSTOCKMAN as char
Local cTab as char
Local cTemp as Char
Local cSuperLegalAdr as Char
Local aArea   := getArea()
Local nCount 	:= 0
LOCAL nI		:= 0
Local nTotweight:= 0
Local nTotquant	:= 0
Local cFilSA1	:= FWxFilial("SA1")
Local cfilSD2	:= FWxFilial("SD2")
Local cFilSB1	:= FWxfilial("SB1")
Local cFilSF2	:= FWxfilial("SF2")
Local cAliasTMP	:= ""
Local cFactAnt:= ""
Local aItemInfo	:=	{}
Local iAdrExi := .T.
Local oStatement := FWPreparedStatement():New()
Local aSigners as Array
Local nX as Numeric
Local cKeyOfReport as Char

	cKeyOfReport:="IN ('M-15', 'ALL', 'M15')" //SQL part
	aSigners:={}
For nX:=1 to len(aCodSigners)
	Aadd(aSigners,RU06D01GetSigner(aCodSigners[nX],cKeyOfReport))
Next nX

aComData := GetCoBrRUS()
cSuperLegalAdr := GatherAdressData(aComData)

cAliasTMP	:= GetNextAlias()

cNotIni :=StrTran(cNotIni,'"',"")
cNotFin :=StrTran(cNotFin,'"',"")

oStatement:SetQuery("SELECT D2_ITEM, F2_DOC,B1_DESC, A1_FILIAL, A1_CODZON, A1_NOME, A1_INSCGAN, A1_END, A1_BAIRRO, A1_MUN, A1_PAIS, A1_EST, A1_CEP, A1_CGC, F2_DOC, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_VALIMP1, F2_VALIMP2, F2_VALBRUT, F2_VALMERC, D2_COD, D2_QUANT, D2_UM, D2_NUMLOTE, D2_LOTECTL, D2_DTVALID, D2_PRCVEN, D2_LOCAL, D2_VALIMP1, D2_ALQIMP1, D2_DESC, D2_TOTAL, D2_VALIMP2, F2_CONTRAT, F2_PBRUTO, AH_CODERP, AH_UMRES, AH_CODOKEI, D2_PESO, D2_REMITO, D2_PEDIDO, AGA.*, AI0.* FROM "+RetSqlName("SF2")+" SF2 INNER JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA AND SD2.D2_TIPODOC = SF2.F2_TIPODOC AND SD2.D2_ESPECIE = SF2.F2_ESPECIE AND SD2.D2_FILIAL = ? AND SD2.D_E_L_E_T_ = '' INNER JOIN "+RetSqlName("SAH")+" SAH ON SAH.AH_UNIMED = SD2.D2_UM AND SAH.D_E_L_E_T_ = '' AND SAH.AH_FILIAL = ? INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_ = '' AND SB1.B1_FILIAL = ? AND B1_COD = D2_COD	INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND SA1.D_E_L_E_T_ = '' AND SA1.A1_FILIAL = ? LEFT JOIN "+RetSqlName("AGA")+"  AGA ON AGA.AGA_ENTIDA = 'SA1' AND AGA.AGA_FILIAL = ? AND AGA.D_E_L_E_T_=' ' AND AGA.AGA_CODENT LIKE '%SA1.A1_FILIAL||SA1.A1_COD||SA1.A1_LOJA%' AND AGA.AGA_TIPO = '0' AND ? BETWEEN  AGA.AGA_FROM  AND AGA_TO AND AGA.D_E_L_E_T_ = '' LEFT JOIN  "+RetSqlName("AI0")+" AI0 ON AI0.AI0_CODCLI = SA1.A1_COD AND AI0.AI0_LOJA = SA1.A1_LOJA AND AI0.D_E_L_E_T_ = ''  AND AI0.AI0_FILIAL = ? WHERE SF2.F2_FILIAL = ? AND SF2.D_E_L_E_T_ = '' AND SF2.F2_DOC >= ? AND SF2.F2_DOC <= ? ")

oStatement:SetString(1,cfilSD2)
oStatement:SetString(2,FWxFilial("SAH"))
oStatement:SetString(3,cFilSB1)
oStatement:SetString(4,cFilSA1)
oStatement:SetString(5,FWxFilial('AGA'))
oStatement:SetDate(6,dDataBase)
oStatement:SetString(7,FWxfilial("AI0"))
oStatement:SetString(8,cFilSF2)
oStatement:SetString(9,cNotIni)
oStatement:SetString(10,cNotFin)

cAliasTMP := MPSysOpenQuery(oStatement:GetFixQuery() ,"cAliasTMP")

	Count to nCount	

	(cAliasTMP)->(dbGotop())
	While (cAliasTMP)->(!EOF())

		RecLock(cAliasMov,.T.) 	

		nI++
		aItemInfo	:=	GetImportInfo((cAliasTMP)->D2_COD,(cAliasTMP)->D2_LOCAL,(cAliasTMP)->D2_LOTECTL,(cAliasTMP)->D2_NUMLOTE)

		F_CHIEFNAM	:= AllTrim(aSigners[2,1])
		F_CHIEFBUH	:= AllTrim(aSigners[3,1])
		F_STOCKMAN 	:= AllTrim(aSigners[1,1])

		P_CHIEFNAM	:= AllTrim(aSigners[2,2])
		P_CHIEFBUH	:= AllTrim(aSigners[3,2])
		P_STOCKMAN	:= AllTrim(aSigners[1,2])

		cAgaFull:= ''

		CO_ADDRESS		:= AllTrim(cSuperLegalAdr)
		CO_NAME			:= AllTrim(aComData[1][5][2]) 
		CO_KPP			:= AllTrim(aComData[1][14][2])
		CO_INN			:= AllTrim(aComData[1][13][2])
		CO_OKPO			:= AllTrim(aComData[1][12][2])

		If !empty(AllTrim(aComData[1][5][2]))
			cAgaFull:= AllTrim(aComData[1][5][2]) 
		EndIf

		If !empty(aComData[1][13][2])
			cAgaFull:= cAgaFull + ', ' + AllTrim(aComData[1][13][2])
		EndIf

		If !empty(aComData[1][14][2])
				cAgaFull:= cAgaFull + ', ' + AllTrim(aComData[1][14][2])
			If !empty(aComData[1][13][2])
				cAgaFull:= cAgaFull + '/' + AllTrim(aComData[1][14][2])
			EndIf
		EndIf

		If !empty(AllTrim(cSuperLegalAdr))
			cAgaFull:= cAgaFull + ', ' +cSuperLegalAdr
		EndIf
		cAgaFull:= cAgaFull + '.'

		While AT(', ,', cAgaFull)!=0
    		cAgaFull := StrTran(cAgaFull,', ,',',')
   		EndDo
		While AT(', .', cAgaFull)!=0
    		cAgaFull := StrTran(cAgaFull,', .','.')
   		EndDo
		While AT('..', cAgaFull)!=0
    		cAgaFull := StrTran(cAgaFull,'..','.')
   		EndDo

		CO_DTEST  :=  AllTrim(cAgaFull) /* + AllTrim(CO_ADDRESS) + ", " + AllTrim(aRet[1][7][2]) + "."*/

		CL_NAME			:= AllTrim((cAliasTMP)->A1_NOME)
		CL_INN			:= AllTrim((cAliasTMP)->A1_CODZON)
		CL_KPP			:= AllTrim((cAliasTMP)->A1_INSCGAN)
		CL_OKPO			:= AllTrim((cAliasTMP)->AI0_OKPO)//(cAliasTMP)->A1_OKPO

		cAgaFull := AllTrim((cAliasTMP)->AGA_CEP)
		cAgaFull += ", " + AllTrim((cAliasTMP)->AGA_BAIRRO) + AllTrim((cAliasTMP)->AGA_MUNDES)
		cAgaFull += ", " + AllTrim((cAliasTMP)->AGA_END)
		cAgaFull += ", " + AllTrim((cAliasTMP)->AGA_HOUSE)
		cAgaFull += ", " + AllTrim((cAliasTMP)->AGA_BLDNG)
		cAgaFull += ", " + AllTrim((cAliasTMP)->AGA_APARTM)
		cAgaFull += "."

		cAgaFull2		:= AllTrim(CL_NAME) + ", " + AllTrim(CL_KPP) + "/" + AllTrim(CL_INN) + ", " + AllTrim(cAgaFull) + '.'

		While AT(', ,', cAgaFull2)!=0
    		cAgaFull2 := StrTran(cAgaFull2,', ,',',')
   		EndDo
		While AT(', .', cAgaFull2)!=0
    		cAgaFull2 := StrTran(cAgaFull2,', .','.')
   		EndDo
		While AT('..', cAgaFull2)!=0
    		cAgaFull2 := StrTran(cAgaFull2,'..','.')
   		EndDo

		CL_ADDRESS		:= cAgaFull2

		If iAdrExi 
			If !empty(aComData) .and. !empty(aComData[3]) .and. !empty(aComData[3][2]) .and. !empty(aComData[3][2][22])
				cAgaFull:= aComData[3][2][22]
			else
				Help(" ",1,"ADDRNOTEX2")
				iAdrExi:=.F.
			Endif
		Endif

		While AT(', ,', cAgaFull)!=0
    		cAgaFull := StrTran(cAgaFull,', ,',',')
   		EndDo
		While AT(', .', cAgaFull)!=0
    		cAgaFull := StrTran(cAgaFull,', .','.')
   		EndDo
		While AT('..', cAgaFull)!=0
    		cAgaFull := StrTran(cAgaFull,'..','.')
   		EndDo

		FI_ADDRESS		:= AllTrim(cAgaFull) //RU99CAdr("CO_ADDRESS") //SZD-> ZD_ACTADRE

		FI_NAME 		:= AllTrim(aComData[2][6][2]) //RU99CAdr("CO_NAME")    //SZD-> ZD_FULL	
		FI_KPP			:= AllTrim(aComData[2][5][2]) //RU99CAdr("CO_KPP")     //SZD-> ZD_KPP
		FI_OKPO			:= AllTrim(aComData[2][12][2]) //RU99CAdr("CO_OKPO")     //SZD-> ZD_OKPO

		cAgaFull2		:= AllTrim(aComData[2][6][2])+", "+AllTrim(aComData[2][5][2])+"/"+AllTrim(aComData[2][12][2])+", "+AllTrim(cAgaFull)

		While AT(', ,', cAgaFull2)!=0
    		cAgaFull2 := StrTran(cAgaFull2,', ,',',')
   		EndDo
		While AT(', .', cAgaFull2)!=0
    		cAgaFull2 := StrTran(cAgaFull2,', .','.')
   		EndDo
		While AT('..', cAgaFull2)!=0
    		cAgaFull2 := StrTran(cAgaFull2,'..','.')
   		EndDo

		FI_DATA			:= cAgaFull2 //AllTrim(CO_NAME)+", "+AllTrim(CO_KPP)+"/"+AllTrim(CO_INN)+", "+AllTrim(CO_ADDRESS)//AllTrim(SZD->ZD_FULL)+", "+AllTrim(SZD->ZD_KPP)+"/"+AllTrim(SZD->ZD_INN)+", "+AllTrim(SZD->ZD_ACTADRE)

		H_DOC			:= VAL((cAliasTMP)->F2_DOC)
		//H_CONTRACT		:= (cAliasTMP)->F2_CONTRAT
		If empty((cAliasTMP)->D2_REMITO)
			H_CONTRACT		:=(cAliasTMP)->d2_pedido
		else
			H_CONTRACT		:=(cAliasTMP)->D2_REMITO
		EndIf

		H_IDATE 		:= StrTran(DTOC(Stod((cAliasTMP)->F2_EMISSAO)),"/",".")//:= Stod((cAliasTMP)->SF2_IDATE)
		H_DDATE 		:= Val(SUBSTR((cAliasTMP)->F2_EMISSAO,7,2))
		H_MDATE 		:= Val(SUBSTR((cAliasTMP)->F2_EMISSAO,5,2))
		H_YDATE 		:= Val(SUBSTR((cAliasTMP)->F2_EMISSAO,1,4))
			//TODO: Implement currenmcy codes table
		H_CURRENCY		:= "643"
		H_CURDESC		:= "000"

		IT_DESC			:= (cAliasTMP)->D2_DESC
		IT_ITEMDSC		:= (cAliasTMP)-> B1_DESC
		IT_MATCODE 		:= (cAliasTMP)-> D2_COD
		IT_UM			:= (cAliasTMP)->D2_UM
		IT_MEASCOD		:= (cAliasTMP)->AH_CODOKEI//4I
		IT_MEASDES		:= (cAliasTMP)->AH_UMRES//5I
		IT_GRWEIGH		:= (cAliasTMP)->D2_PESO//9I
		IT_UMDESC	 	:= Posicione("SAH",1,xfilial("SAH")+(cAliasTMP)->D2_UM,"SAH->AH_UMRES")
		IT_UNIT_PR		:= (cAliasTMP)->D2_PRCVEN
		IT_QUANT		:= (cAliasTMP)->D2_QUANT
		IT_VALUE		:= (cAliasTMP)->D2_TOTAL
		IT_ITEM			:= (cAliasTMP)->D2_ITEM
		IT_VAT			:= (cAliasTMP)->D2_VALIMP1
		IT_VAT_RAT		:= (cAliasTMP)->D2_ALQIMP1/100
		IT_EXCISE		:= (cAliasTMP)->D2_VALIMP2
		IT_VALTOT		:= (cAliasTMP)->D2_TOTAL

		IT_COUNTRY		:= If(empty(aItemInfo[1]),"--",aItemInfo[1])
		IT_DESC_CO		:= If(empty(aItemInfo[2]),"--",aItemInfo[2])
		IT_CUSTOMS		:= If(empty(aItemInfo[3]),"--",aItemInfo[3])
		IT_NUM			:= nI

		TOT_VAT		:= (cAliasTMP)->F2_VALIMP1
		TOT_EXCISE		:= (cAliasTMP)->F2_VALIMP2
		TOT_GOODS	 	:= (cAliasTMP)->F2_VALMERC
		TOT_VALUE	 	:= (cAliasTMP)->F2_VALBRUT
		nTotweight	:= nTotweight+((cAliasTMP)->D2_PESO)
		nTotquant	:= nTotquant+((cAliasTMP)->D2_QUANT)
		nTotVal 	:=	nTotVal + TOT_VALUE

		TOT_QUANT := nTotquant
		TOT_VALUET		:= AllTrim(RU99X01(nTotVal,.T.,'1')+" " + Currency(nTotVal,1,'01')+" "+ iif(Decimal(nTotVal)<10,"0"+STR(Decimal(nTotVal),1),STR(Decimal(nTotVal),2))+" "+ Currency(nTotVal,2,'01'))//Extenso(TOT_VALUE,.T.,2)//Extenso(TOT_VALUE,.F.,1,,'3',.T.,.F.)
		IT_NUMTEXT		:= RU99X01(nI,.T.,'1')

		 /*TOT_CurRub		:= Currency(TOT_VALUE,1)
		 TOT_KOPEEK		:= Decimal(TOT_VALUE)
		 TOT_CurKop		:= Currency(TOT_VALUE,2)*/
		  //Extenso(IT_NUM,.T.,2)	

		MsUnlock()		
		(cAliasTMP)->(dbSkip())

	EndDo

	(cAliasTMP)->(dbCloseArea())
	RestArea(aArea)
	
Return .T. //nCount > 0



Static Function GetImportInfo(cCod,cLocal,cLote,cLoteCtl)
	Local aImpInfo	:=	{'','',''}
	sb8->(DbSetOrder(1))
	If sb8->(MsSeek(xFilial()+cCod+cLocal+cLoteCtl+cLote))
		aImpInfo[1]	:= SB8->B8_ORIGEM
		aImpInfo[2]	:= Posicione("SYA",1,xFilial("SYA")+SB8->B8_ORIGEM,"SYA->YA_DESCR")	
		aImpInfo[3]	:= SB8->B8_NUMDESP
	Endif

Return aImpInfo
// Russia_R5
                   
//Merge Russia R14 
                   
                   
