#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI23

Rotina de geração do Detalhamento Tipo 23 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informações da filial em processamento

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI23(aWizard, nCont, aFil)

Local cTxtSys  	as char
Local nHandle   as numeric
Local cREG 		:= "23"
Local cStrTxt		:= ""
Local nPos			:= 0
Local aCtrlCred  := {}
Local nEstCultur := 0
Local nVlTotComp := 0
Local nVlTotTran := 0
Local nEstornCul := 0
Local nSldAntCul := 0
Local nAproprCul := 0
Local nLimiteCul := 0
Local nSldSegCul := 0
Local nTotDedCul := 0
Local nEstornEsp := 0
Local nSldAntEsp := 0
Local nAproprEsp := 0
Local nLimiteEsp := 0
Local nSldSegEsp := 0
Local nTotDedEsp := 0
Local nVlTotDedu := 0
Local nAliqEsp   := 0
Local nAliqCult  := 0
Local lFound      := ""
Private cFilDapi := aFil[1]
Private cUFID    := aFil[7]

Begin Sequence

	cStrTxt := cREG 									               	    	 		  //Tipo Linha		   - Valor Fixo: 00
	cStrTxt += Substr(aFil[5],1,13)					              	 				 	  //Inscrição Estadual - M0_INSC ( SIGAMAT )
	cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 			  //Ano Referência
	cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //Mês Referência
	cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 			  //Dia final referência
	cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 			  //Dia Inicial referência

	/***** DETALHAMENTO TIPO 23 - Deduções ********/
	aCtrlCred := CtrlCred(aWizard[1][1], aWizard[1][2])
	nAliqEsp  := GETNEWPAR( "MV_ALQESPO",0,cFilDapi)
	nAliqCult := GETNEWPAR( "MV_ALQCULT",0,cFilDapi)

	While nPos < Len(aCtrlCred)
		nPos++
	   If(aCtrlCred[nPos,2] == "MG092001") // Cultura
	   		nEstornCul := GetEstorno(aCtrlCred[nPos,1])
	   		nSldAntCul := aCtrlCred[nPos,3]
	   		nAproprCul := aCtrlCred[nPos,4]
	   		IIF(nAliqCult > 0, nLimiteCul := aCtrlCred[nPos,5], nLimiteCul := 0)
	   		nSldSegCul := aCtrlCred[nPos,6]

	   		nTotDedCul := (nSldAntCul + nAproprCul) - nEstornCul
	   EndIf

	   If(aCtrlCred[nPos,2] == "MG092002") // Esporte
	   		nEstornEsp := GetEstorno(aCtrlCred[nPos,1])
	   		nSldAntEsp := aCtrlCred[nPos,3]
	   		nAproprEsp := aCtrlCred[nPos,4]
	   		IIF(nAliqEsp > 0, nLimiteEsp := aCtrlCred[nPos,5], nLimiteEsp := 0)
	   		nSldSegEsp := aCtrlCred[nPos,6]

	   		nTotDedEsp := (nSldAntEsp + nAproprEsp) - nEstornEsp
	   EndIf
	EndDo

	if Len(aCtrlCred) > 0
		cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	    nHandle   	:= MsFCreate( cTxtSys )

		nVlTotComp := Tp24Compen(aWizard[1][1], aWizard[1][2])
		nVlTotTran := Tp34Transf(aWizard[1][1], aWizard[1][2])

		nVlTotDedu := nLimiteCul + nVlTotComp 	+ nVlTotTran + nLimiteEsp

		IIF(nVlTotDedu < 0, nVlTotDedu := 0, '')

		nCont++
		cStrTxt := Left(cStrTxt,25) + StrTran(StrZero(nSldAntCul, 16, 2),".","")  	//Saldo de incentivo à cultura do período anterior
		cStrTxt := Left(cStrTxt,40) + StrTran(StrZero(nAproprCul, 16, 2),".","")  	//Incentivo à cultura no período.
		cStrTxt := Left(cStrTxt,55) + StrTran(StrZero(nTotDedCul, 16, 2),".","")  	//Total dedução incentivo a cultura no período
		cStrTxt := Left(cStrTxt,70) + StrTran(StrZero(nLimiteCul, 16, 2),".","")  	//Valor limite p/ dedução incentivo à cultura no período
		cStrTxt := Left(cStrTxt,85) + StrTran(StrZero(nSldSegCul, 16, 2),".","")  	//Saldo credor dedução incentivo à cultura período Seguinte
		cStrTxt := Left(cStrTxt,100)+ StrTran(StrZero(nVlTotComp, 16, 2),".","")  	//Compensação de crédito entre estabelecimentos da mesma empresa no período
		cStrTxt := Left(cStrTxt,115)+ StrTran(StrZero(nVlTotDedu, 16, 2),".","")  	//Total de deduções no período
		cStrTxt := Left(cStrTxt,130)+ StrTran(StrZero(nVlTotTran, 16, 2),".","")  	//Utilização de Créditos Recebidos em Transferência
		cStrTxt := Left(cStrTxt,145)+ StrTran(StrZero(nAliqCult,  16, 2),".","")  	//Alíquota de dedução por incentivo à cultura no período
		cStrTxt := Left(cStrTxt,160)+ StrTran(StrZero(nEstornCul, 16, 2),".","")  	//Cultura Estorno
		cStrTxt := Left(cStrTxt,175)+ StrTran(StrZero(nSldAntEsp, 16, 2),".","")  	//Saldo de incentivo ao esporte do período anterior
		cStrTxt := Left(cStrTxt,190)+ StrTran(StrZero(nAproprEsp, 16, 2),".","")  	//Incentivo ao esporte no período
		cStrTxt := Left(cStrTxt,205)+ StrTran(StrZero(nTotDedEsp, 16, 2),".","")  	//Total dedução incentivo ao esporte no período
		cStrTxt := Left(cStrTxt,220)+ StrTran(StrZero(nLimiteEsp, 16, 2),".","")  	//Valor limite p/ dedução incentivo ao esporte no período
		cStrTxt := Left(cStrTxt,235)+ StrTran(StrZero(nSldSegEsp, 16, 2),".","")  	//Saldo credor dedução incentivo ao esporte período seguinte
		cStrTxt := Left(cStrTxt,250)+ StrTran(StrZero(nAliqEsp,   16, 2),".","")  	//Alíquota de dedução por incentivo ao esporte no período
		cStrTxt := Left(cStrTxt,265)+ StrTran(StrZero(nEstornEsp, 16, 2),".","")  	//Esporte Estorno
		cStrTxt += CRLF

		WrtStrTxt( nHandle, cStrTxt)
		GerTxtDAPI( nHandle, cTxtSys, cReg, cFilDapi)
	EndIf

Recover
	lFound := .F.

End Sequence

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} CtrlCred

Função para retornar os valores referente a Controle de Crédito
(1200 do SPED FISCAL) para os incentivos ao Esporte e a Cultura

@Param dIni	->	Data inicial do período
		dFim	->	Data final do período

@Return aCtrlCred -> Array com os valores totais do Controle de Crédito.

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function CtrlCred(dIni, dFim)
	Local cStrQuery 	:= ""
	Local cAliasAjus 	:= GetNextAlias()
	Local aCtrlCred 	:= {}

	cStrQuery := "SELECT C50.C50_ID 	 ID, "
	cStrQuery += "       C1A.C1A_CODIGO COD_AJUS, "
	cStrQuery += "       C50.C50_SLDCRD SALDO_CRED, "
	cStrQuery += "       C50.C50_CRDAPR CRED_APROPR, "
	cStrQuery += "       C50.C50_CRDUTI CRED_UTILZ, "
	cStrQuery += "       C50.C50_SDCRFI SALDO_TRANSP "
	cStrQuery +=  " FROM " + RetSqlName('C50') + " C50, "
	cStrQuery +=             RetSqlName('C1A') + " C1A "
	cStrQuery += "  WHERE C50.C50_FILIAL                = '" + cFilDapi + "' "
	cStrQuery +=   "  AND C50.C50_PERIOD  BETWEEN '" + DToS(dIni) + "' AND '" + DToS(dFim) + "'"
	cStrQuery +=   "  AND C50.C50_CODAJU    = C1A.C1A_ID  "
	cStrQuery +=   "  AND C1A.C1A_FILIAL = '" + xFilial("C1A") + "' "
	cStrQuery +=   "  AND C1A.C1A_CODIGO IN ('MG092001','MG092002') "  //Apropriação Cultura e Esporte
	cStrQuery +=   "  AND C1A.C1A_UF = '" + cUFID + "'"
	cStrQuery +=   "  AND C50.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C1A.D_E_L_E_T_ = ' '"

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasAjus,.T.,.T.)

	DbSelectArea(cAliasAjus)
	dbGoTop()

    While (cAliasAjus)->(!Eof())

       aAdd(aCtrlCred,{(cAliasAjus)->ID, (cAliasAjus)->COD_AJUS, (cAliasAjus)->SALDO_CRED, (cAliasAjus)->CRED_APROPR, (cAliasAjus)->CRED_UTILZ, (cAliasAjus)->SALDO_TRANSP})

       (cAliasAjus)->(DbSkip())
    EndDo

    (cAliasAjus)->(DbCloseArea())

Return aCtrlCred

//---------------------------------------------------------------------
/*/{Protheus.doc} GetEstorno

Função para buscar os valores referente a Estorno dos incentivos
ao Esporte e a Cultura

@Param nIdCtrlCre	->	ID do controle de crédito (1200 do SPED FISCAL)

@Return aCtrlCred -> Array com os valores totais do Controle de Crédito.

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function GetEstorno(nIdCtrlCre)
	Local cStrQuery 	:= ""
	Local cAliasEstr 	:= GetNextAlias()
	Local nVlEstorno 	:= 0

	cStrQuery := "SELECT SUM(C51.C51_CRUTIL) VLR_ESTORNO "
	cStrQuery +=  " FROM " + RetSqlName('C51') + " C51, "
	cStrQuery +=             RetSqlName('C4Z') + " C4Z "
	cStrQuery += "  WHERE C51.C51_FILIAL                = '" + cFilDapi + "' "
	cStrQuery +=   "  AND C51.C51_ID = '" + nIdCtrlCre + "'"
	cStrQuery +=   "  AND C51.C51_TPUTIL = C4Z.C4Z_ID  "
	cStrQuery +=   "  AND C4Z.C4Z_FILIAL = '" + xFilial("C4Z") + "' "
	cStrQuery +=   "  AND C4Z.C4Z_CODIGO = 'MG81'"  //Estorno
	cStrQuery +=   "  AND C51.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C4Z.D_E_L_E_T_ = ' '"

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasEstr,.T.,.T.)

	DbSelectArea(cAliasEstr)
	dbGoTop()

    nVlEstorno := (cAliasEstr)->VLR_ESTORNO

    (cAliasEstr)->(DbCloseArea())

Return nVlEstorno

//---------------------------------------------------------------------
/*/{Protheus.doc} Tp24Compen

Função para buscar o valor total da Compensação de Crédito.

@Param dIni	->	Data inicial do período
		dFim	->	Data final do período

@Return nVlTotComp -> Valor total da Compensação de Crédito no período

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Tp24Compen(dIni, dFim)
	Local cStrQuery 	:= ""
	Local cAliasNF 	:= GetNextAlias()
	Local nVlTotComp 	:= 0

	//[D1D05006] Compensação de Crédito - Data da Nota Fiscal deve estar compreendida no mês posterior ao período de referência

	dIni := MonthSum(dIni,1)
	dFim := MonthSum(dFim,1)

	cStrQuery := "SELECT SUM(C20_VLDOC) VALOR "
	cStrQuery +=  " FROM " + RetSqlName('C20') + " C20, "
	cStrQuery +=             RetSqlName('C1H') + " C1H, "
	cStrQuery +=             RetSqlName('C30') + " C30, "
	cStrQuery +=             RetSqlName('C0Y') + " C0Y, "
	cStrQuery +=             RetSqlName('C02') + " C02 "
	cStrQuery += "  WHERE C20.C20_FILIAL                = '" + cFilDapi + "' "
	cStrQuery +=   "  AND C20.C20_FILIAL = C1H.C1H_FILIAL "
	cStrQuery +=   "  AND C20.C20_CODPAR = C1H.C1H_ID    "
	cStrQuery +=   "  AND C20.C20_FILIAL = C30.C30_FILIAL"
	cStrQuery +=   "  AND C20.C20_CHVNF  = C30.C30_CHVNF"
	cStrQuery +=   "  AND C30.C30_CFOP   = C0Y.C0Y_ID"
	cStrQuery +=   "  AND C0Y.C0Y_FILIAL = ' '"
	cStrQuery +=   "  AND C0Y.C0Y_CODIGO = '1602'"
	cStrQuery +=   "  AND C20.C20_CODSIT =  C02.C02_ID "
	cStrQuery +=   "  AND C02.C02_FILIAL =  '" + xFilial("C02") + "' "
	cStrQuery +=   "  AND C02.C02_CODIGO  NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA
	cStrQuery +=   "  AND C20.C20_DTES BETWEEN '" + DToS(dIni) + "' AND '" + DToS(dFim) + "'"
	cStrQuery +=   "  AND C20.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C1H.D_E_L_E_T_ = ' '" 
	cStrQuery +=   "  AND C30.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C0Y.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C02.D_E_L_E_T_ = ' '"

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasNF,.T.,.T.)

	DbSelectArea(cAliasNF)
	dbGoTop()

  	nVlTotComp += (cAliasNF)->VALOR

  	(cAliasNF)->(DbCloseArea())

Return nVlTotComp

//---------------------------------------------------------------------
/*/{Protheus.doc} Tp34Transf

Função para buscar o valor total da Utilização de Créditos Transferidos

@Param dIni	->	Data inicial do período
		dFim	->	Data final do período

@Return nVlTotTran -> Valor total da Utilização de Créditos Transferidos

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Tp34Transf(dIni, dFim)
	Local cStrQuery 	:= ""
	Local cAliasNF 	:= GetNextAlias()
	Local nVlTotTran 	:= 0

	 cStrQuery := " SELECT SUM(C2V.C2V_VLRAJU) VALOR"
	  cStrQuery +=   " FROM " + RetSqlName('C2S') + " C2S, "
	  cStrQuery +=              RetSqlName('C2T') + " C2T, "
	  cStrQuery +=              RetSqlName('C2V') + " C2V, "
	  cStrQuery +=              RetSqlName('CHY') + " CHY  "
	  cStrQuery += "  WHERE C2S.C2S_FILIAL                = '" + cFilDapi + "' "
	  cStrQuery +=   "  AND C2S.C2S_DTINI  BETWEEN '" + DToS(dIni) + "' AND '" + DToS(dFim) + "'"
	  cStrQuery +=   "  AND C2S.C2S_TIPAPU = '0'"
	  cStrQuery +=   "  AND C2S.C2S_INDAPU = ' '"
	  cStrQuery +=   "  AND C2S.C2S_FILIAL = C2T.C2T_FILIAL "
	  cStrQuery +=   "  AND C2S.C2S_ID     = C2T.C2T_ID "
	  cStrQuery +=   "  AND C2T.C2T_FILIAL = C2V.C2V_FILIAL "
	  cStrQuery +=   "  AND C2T.C2T_ID     = C2V.C2V_ID "
	  cStrQuery +=   "  AND C2T.C2T_CODAJU = C2V.C2V_CODAJU "
	  cStrQuery +=   "  AND C2T.C2T_IDSUBI = CHY.CHY_ID "
	  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "
	  cStrQuery +=   "  AND CHY.CHY_IDUF   =  '" + cUFID + "'"
	  cStrQuery +=   "  AND CHY.CHY_CODIGO = '00098' " //Dedução - Utilização Crédito
	  cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C2T.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C2V.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"

	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasNF,.T.,.T.)

	DbSelectArea(cAliasNF)
	dbGoTop()

	nVlTotTran := (cAliasNF)->VALOR

 	(cAliasNF)->(DbCloseArea())

Return nVlTotTran