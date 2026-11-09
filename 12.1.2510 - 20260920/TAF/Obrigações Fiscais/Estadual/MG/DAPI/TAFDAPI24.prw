#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI24

Rotina de geração do Detalhamento Tipo 24 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informações da filial em processamento

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI24(aWizard, nCont, aFil)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "24"
Local cStrTxt		:= ""
Local nPos			:= 0
Local aDetalhe   := {}
Local lFound      := ""
Private cFilDapi := aFil[1]
Private cUFID    := aFil[7]

Begin Sequence

	cStrTxt := cREG 									               	    	 				  //Tipo Linha					- Valor Fixo: 00
	cStrTxt += Substr(aFil[5],1,13)					              	 				 		  //Inscrição Estadual		- M0_INSC ( SIGAMAT )
	cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				  //Ano Referência
	cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //Mês Referência
	cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				  //Dia final referência
	cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				  //Dia Inicial referência

	/***** DETALHAMENTO TIPO 24 -  Compensação de Saldo ********/
	aDetalhe := Tp24Compen(aWizard[1][1], aWizard[1][2])

	While nPos < Len(aDetalhe)
		nPos++
		nCont++

		cStrTxt := Left(cStrTxt,25) + PADL(Alltrim(aDetalhe[nPos,5]),15,"0")           	//IE
		cStrTxt := Left(cStrTxt,40) + PADL(Alltrim(aDetalhe[nPos,1]),9)					//Nota Fiscal
		cStrTxt := Left(cStrTxt,49) + PADL(Alltrim(aDetalhe[nPos,2]),3)					//Serie
		cStrTxt := Left(cStrTxt,52) + FormatData(STOD(aDetalhe[nPos,3]),.F.,5)			//Data Documento
		cStrTxt := Left(cStrTxt,62) + FormatData(STOD(aDetalhe[nPos,3]),.F.,5)			//Data do Visto
		cStrTxt := Left(cStrTxt,68) + StrTran(StrZero(aDetalhe[nPos,4], 16, 2),".","")	//Valor do Ajuste
		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	EndDo

	GerTxtDAPI( nHandle, cTxtSys, cReg, cFilDapi)

Recover
	lFound := .F.

End Sequence

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Tp24Compen

Função para buscar as notas fiscais de Compensação de Crédito.

@Param dIni	->	Data inicial do período
		dFim	->	Data final do período

@Return aNFCompens -> Array com as notas fiscais de compensação de crédito

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Tp24Compen(dIni, dFim)
	Local cStrQuery 	:= ""
	Local cAliasNF 	:= GetNextAlias()
	Local aNFCompens 	:= {}

	//[D1D05006] Compensação de Crédito - Data da Nota Fiscal deve estar compreendida no mês posterior ao período de referência
	dIni := MonthSum(dIni,1)
	dFim := MonthSum(dFim,1)

	cStrQuery := "SELECT C20_NUMDOC NUMDOC, "
	cStrQuery +=       " C20_SERIE  SERIE, "
	cStrQuery +=       " C20_DTES  DTDOC, "
	cStrQuery +=       " C20_VLDOC  VLDOC, "
	cStrQuery +=       " C1H_IE     IE "
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
	cStrQuery +=   "  AND C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' "
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

    While (cAliasNF)->(!Eof())

      aAdd(aNFCompens, {(cAliasNF)->NUMDOC, (cAliasNF)->SERIE, (cAliasNF)->DTDOC, (cAliasNF)->VLDOC, (cAliasNF)->IE})

      (cAliasNF)->(DbSkip())
  EndDo

  (cAliasNF)->(DbCloseArea())

Return aNFCompens