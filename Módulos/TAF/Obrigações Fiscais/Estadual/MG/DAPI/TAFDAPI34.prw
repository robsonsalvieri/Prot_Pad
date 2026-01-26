#Include 'Protheus.ch'

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI34

Rotina de geração do Detalhamento Tipo 34 e Tipo 35 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informações da filial em processamento		

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI34(aWizard, nCont, aFil)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "34"
Local cStrTxt		:= ""
Local nPos			:= 0
Local cPeriodo   := StrZero(Year(aWizard[1][1]),4,0) + StrZero(Month(aWizard[1][1]),2,0)
Local aDetalhe   := {}
Local aNFRemet   := {}
Local aDetalhe35 := {}
Local cNF      := "" 	
Local cSerNF   := ""
Local cSubNF   := ""
Local dDtDoc   := Nil
Local cModNF   := ""
Local cCodPar  := ""
Local dDtVisto := Nil
Local nVlAjus  := 0
Local cCodMot  := ""
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
	
	/***** DETALHAMENTO TIPO 34 - Utilização de Crédito ********/
	aDetalhe := Tp34Transf(aWizard[1][1], aWizard[1][2])
	nPos := 0
  
	While nPos < Len(aDetalhe)
		nPos++
		nCont++
		
		cNF 		:= aDetalhe[nPos,1]
		cSerNF 	:= aDetalhe[nPos,2]
		cSubNF 	:= aDetalhe[nPos,3]
		dDtDoc 	:= aDetalhe[nPos,4]
		cModNF 	:= aDetalhe[nPos,5]
		cCodPar   	:= aDetalhe[nPos,6]
		dDtVisto 	:= aDetalhe[nPos,7]
		nVlAjus 	:= aDetalhe[nPos,8]
		cCodMot 	:= aDetalhe[nPos,9]		
		
		cStrTxt := Left(cStrTxt,25) + StrZero(nPos, 10, 0)                   	//Identificador da Utilização de Crédito 	
		cStrTxt := Left(cStrTxt,35) + Right(cCodMot,2)                       	//Código do Motivo
		cStrTxt := Left(cStrTxt,37) + PADL(Alltrim(cNF),9)						//Nota Fiscal		
		cStrTxt := Left(cStrTxt,46) + PADL(Alltrim(cSerNF),3)					//Serie
		cStrTxt := Left(cStrTxt,49) + FormatData(STOD(dDtDoc),.F.,5)			//Data Documento
		cStrTxt := Left(cStrTxt,57) + FormatData(STOD(dDtVisto),.F.,5)			//Data do Visto
		cStrTxt := Left(cStrTxt,65) + StrTran(StrZero(nVlAjus, 16, 2),".","")	//Valor do Ajuste		
		cStrTxt += CRLF		
		WrtStrTxt( nHandle, cStrTxt)
		
		RemeteCred(cNF, cSerNF, cSubNF, dDtDoc, cModNF, cCodPar, nPos, @aDetalhe35)
		
	EndDo
	
	/***** DETALHAMENTO TIPO 35 - – Remetente de Crédito ********/
	cStrTxt := "35" 									               	    	 				  //Tipo Linha					- Valor Fixo: 00
	cStrTxt += Substr(aFil[5],1,13)					              	 				 		  //Inscrição Estadual		- M0_INSC ( SIGAMAT )
	cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				  //Ano Referência
	cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //Mês Referência
	cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				  //Dia final referência
	cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				  //Dia Inicial referência
	
	nPos := 0 
	While nPos < Len(aDetalhe35)
		nPos++
		nCont++
		cStrTxt := Left(cStrTxt,25) + StrZero(aDetalhe35[nPos,1], 10, 0)           		//Identificador da Utilização de Crédito 	
		cStrTxt := Left(cStrTxt,35) + PADL(Alltrim(aDetalhe35[nPos,6]),15,"0")         		//IE Remetente
		cStrTxt := Left(cStrTxt,50) + PADL(Alltrim(aDetalhe35[nPos,2]),9)					//Nota Fiscal		
		cStrTxt := Left(cStrTxt,59) + PADL(Alltrim(aDetalhe35[nPos,3]),3)					//Serie
		cStrTxt := Left(cStrTxt,62) + FormatData(STOD(aDetalhe35[nPos,4]),.F.,5)			//Data Documento
		cStrTxt := Left(cStrTxt,70) + FormatData(STOD(aDetalhe35[nPos,4]),.F.,5)			//Data do Visto
		cStrTxt := Left(cStrTxt,78) + StrTran(StrZero(aDetalhe35[nPos,5], 16, 2),".","")	//Valor do Ajuste		
		cStrTxt += CRLF		
		
		WrtStrTxt( nHandle, cStrTxt)
	EndDo   
	
	GerTxtDAPI( nHandle, cTxtSys, cReg, cFilDapi)

Recover
	lFound := .F.

End Sequence

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} Tp34Transf

Essa função tem por objetivo buscar nos ajustes da apuração as notas fiscais
que representam a utilização de créditos transferidos. As notas encontradas
geram a Linha Tipo 34 da DAPI

Com as informações retornadas, na função NotasRelac são buscadas as Notas de
Transferência que deram origem aos créditos utilizados.

@Author Rafael Völtz
@Since 21/04/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------
Static Function Tp34Transf(dIni, dFim)
	Local cStrQuery 	:= ""
	Local cAliasNF 	:= GetNextAlias()
	Local aNFTransf  	:= {} 	
		
	cStrQuery := " SELECT C2V.C2V_NRODOC NUM_DOC,"
	cStrQuery +=        " C2V.C2V_SERDOC SER_DOC,"
	cStrQuery +=        " C2V.C2V_SUBSER SUBSER,"
	cStrQuery +=        " C2V.C2V_DTDOC  DT_DOC,"
	cStrQuery +=        " C2V.C2V_CODMOD CODMOD,"
	cStrQuery +=        " C2V.C2V_CODPAR CODPAR,"
	cStrQuery +=        " C2V.C2V_DTVIST DT_VISTO,"
	cStrQuery +=        " C2V.C2V_VLRAJU VALOR,"	
	cStrQuery +=        " T0V.T0V_CODIGO MOTIVO "	  	  	  	  
	cStrQuery +=   " FROM " + RetSqlName('C2S') + " C2S, "
	cStrQuery +=              RetSqlName('C2T') + " C2T, "
	cStrQuery +=              RetSqlName('C2V') + " C2V, "
	cStrQuery +=              RetSqlName('T0V') + " T0V, "
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
	cStrQuery +=   "  AND C2T.C2T_IDTMOT = T0V.T0V_ID "
	cStrQuery +=   "  AND T0V.T0V_FILIAL = '" + xFilial("T0V") + "' "  
	cStrQuery +=   "  AND C2T.C2T_IDSUBI = CHY.CHY_ID "
	cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "   
	cStrQuery +=   "  AND CHY.CHY_IDUF   =  '" + cUFID + "'"
	cStrQuery +=   "  AND CHY.CHY_CODIGO = '00098'"  //Dedução - Utilização Crédito	
	cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C2T.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C2V.D_E_L_E_T_ = ' '"	  
	cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND T0V.D_E_L_E_T_ = ' '"	  
	
	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasNF,.T.,.T.)	
  	
	DbSelectArea(cAliasNF)
	dbGoTop()  
  
    While (cAliasNF)->(!Eof())      	
		
		aAdd(aNFTransf, {(cAliasNF)->NUM_DOC, (cAliasNF)->SER_DOC, (cAliasNF)->SUBSER, (cAliasNF)->DT_DOC, (cAliasNF)->CODMOD, (cAliasNF)->CODPAR, (cAliasNF)->DT_VISTO, (cAliasNF)->VALOR, (cAliasNF)->MOTIVO})
       
		(cAliasNF)->(DbSkip())      
  EndDo 
  
  (cAliasNF)->(DbCloseArea()) 
  
Return aNFTransf

//--------------------------------------------------------------------------
/*/{Protheus.doc} RemeteCred

Essa função tem por objetivo buscar as notas fiscais relacionadas T013AE
para gerar o registro LInha Tipo 35 da DAPI.

@Author Rafael Völtz
@Since 21/04/2016
@Version 1.0
/*/
//---------------------------------------------------------------------------
Static Function RemeteCred(cNF, cSerNF, cSubNF, dDtDoc, cModNF, cCodPar, nPos, aDetalhe35)

	Local cStrQuery 	:= ""
	Local cAliasNF 	:= GetNextAlias()		
	Local nValor     	:= ""
	Local cIE        	:= ""
	
	cStrQuery := " SELECT C26.C26_NUMDOC NUM_DOC,"
	cStrQuery +=        " C26.C26_SERIE SER_DOC,"
	cStrQuery +=        " C26.C26_SUBSER SUBSER,"
	cStrQuery +=        " C26.C26_DTDOC  DT_DOC,"
	cStrQuery +=        " C26.C26_CODMOD CODMOD,"
	cStrQuery +=        " C26.C26_CODPAR CODPAR "			  	  	  	  
	cStrQuery +=   " FROM " + RetSqlName('C20') + " C20, "
	cStrQuery +=              RetSqlName('C26') + " C26, "		  
	cStrQuery +=              RetSqlName('C02') + " C02  "
	cStrQuery += "  WHERE C20.C20_FILIAL                = '" + cFilDapi + "' "
	cStrQuery +=   "  AND C20.C20_FILIAL = C26.C26_FILIAL"
	cStrQuery +=   "  AND C20.C20_CHVNF  = C26.C26_CHVNF "
	cStrQuery +=   "  AND C20.C20_CODMOD = '" + Alltrim(cModNF) + "'"
	cStrQuery +=   "  AND C20.C20_INDOPE = '0' "  //operação entrada
	cStrQuery +=   "  AND C20.C20_INDEMI =  '0' " //emissão propria
	cStrQuery +=   "  AND C20.C20_CODPAR = '" + Alltrim(cCodPar) + "'"
	cStrQuery +=   "  AND C20.C20_SERIE  = '" + Alltrim(cSerNF) + "'"
	cStrQuery +=   "  AND C20.C20_SUBSER = '" + Alltrim(cSubNF) + "'"
	cStrQuery +=   "  AND C20.C20_NUMDOC = '" + Alltrim(cNF) + "'"
	cStrQuery +=   "  AND C20.C20_CODSIT =  C02.C02_ID "        
	cStrQuery +=   "  AND C02.C02_FILIAL =  '" + xFilial("C02") + "' "  
	cStrQuery +=   "  AND C02.C02_CODIGO  NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA	
	cStrQuery +=   "  AND C20.D_E_L_E_T_ = ' '"
	cStrQuery +=   "  AND C26.D_E_L_E_T_ = ' '"	  
	cStrQuery +=   "  AND C02.D_E_L_E_T_ = ' '"
	
	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasNF,.T.,.T.)	
  	
  	DbSelectArea("C20")
  	C20->(DbSetOrder(5))
  	
  	DbSelectArea("C2F")
  	C2F->(DbSetOrder(1))
  	
  	DbSelectArea("C1H")
  	C1H->(DbSetOrder(5))
	
	DbSelectArea(cAliasNF)
	dbGoTop()  
  
    
    While (cAliasNF)->(!Eof())
		
		If C20->(DbSeek(cFilDapi + '0'+ (cAliasNF)->CODMOD + (cAliasNF)->SER_DOC + (cAliasNF)->SUBSER + (cAliasNF)->NUM_DOC + (cAliasNF)->DT_DOC + (cAliasNF)->CODPAR))
			If C2F->(DbSeek(cFilDapi + C20->C20_CHVNF + '000002'))
				nValor := C2F->C2F_VALOR
			EndIf
			
			If C1H->(DbSeek(cFilDapi + C20->C20_CODPAR))
		    	cIE := C1H->C1H_IE
			EndIf		
		EndIf
				
		aAdd(aDetalhe35,{nPos, (cAliasNF)->NUM_DOC, (cAliasNF)->SER_DOC, (cAliasNF)->DT_DOC, nValor, cIE})
       
		(cAliasNF)->(DbSkip())      
  EndDo 
  
  (cAliasNF)->(DbCloseArea())
  C20->(DbCloseArea())
  C2F->(DbCloseArea())
  C1H->(DbCloseArea())
  
Return aDetalhe35

