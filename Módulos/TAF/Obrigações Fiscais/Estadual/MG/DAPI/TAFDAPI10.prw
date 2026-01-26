#Include 'Protheus.ch'

Static nEstFEM    := 0
Static nVlrRecST  := 0
Static nVlrDevEnt := 0
Static nTotRec    := 0
Static nRecEfetiv := 0
static _nTmFil 	  := GetSx3Cache( 'C20_FILIAL', 'X3_TAMANHO' )
static _nTmNDoc   := GetSx3Cache( 'C20_NUMDOC', 'X3_TAMANHO' )
static _nTmBs  	  := GetSx3Cache( 'C35_BASE'  , 'X3_TAMANHO' )
static _nDcBs 	  := GetSx3Cache( 'C35_BASE'  , 'X3_DECIMAL' )
static _nTmVOper  := GetSx3Cache( 'C30_VLOPER', 'X3_TAMANHO' )
static _nDcVOper  := GetSx3Cache( 'C30_VLOPER', 'X3_DECIMAL' )
static _nTmImpo   := GetSx3Cache( 'C35_VALOR' , 'X3_TAMANHO' )
static _nDcImpo   := GetSx3Cache( 'C35_VALOR' , 'X3_DECIMAL' )
static _nTmVsCred := GetSx3Cache( 'C35_VLSCRE', 'X3_TAMANHO' )
static _nDcVsCred := GetSx3Cache( 'C35_VLSCRE', 'X3_DECIMAL' )
static _nTmVIsen  := GetSx3Cache( 'C35_VLISEN', 'X3_TAMANHO' )
static _nDcVIsen  := GetSx3Cache( 'C35_VLISEN', 'X3_DECIMAL' )
static _nTmVNTrib := GetSx3Cache( 'C35_VLNT'  , 'X3_TAMANHO' )
static _nDcVNTrib := GetSx3Cache( 'C35_VLNT'  , 'X3_DECIMAL' )
static _nTmBsNTri := GetSx3Cache( 'C35_BASENT', 'X3_TAMANHO' )
static _nDcBsNTri := GetSx3Cache( 'C35_BASENT', 'X3_DECIMAL' )
static _nTmBsVOut := GetSx3Cache( 'C35_VLOUTR', 'X3_TAMANHO' )
static _nDcBsVOut := GetSx3Cache( 'C35_VLOUTR', 'X3_DECIMAL' )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFDAPI10

Rotina de geração das linhas Tipo 10 da DAPI-MG

@Param aWizard	->	Array com as informacoes da Wizard
		nCont ->	Contador das linhas do arquivo
		aFil	->	Array com as informações da filial em processamento		

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFDAPI10(aWizard, nCont, aFil, lTermo)

Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
Local nHandle   	:= MsFCreate( cTxtSys )
Local cREG 		:= "10"
Local cStrTxt		:= ""
Local aReg10		:= {}
Local nPos			:= 0
Local aTotalEnt  	:= {0,0,0,0,0,0,0,0,0,0,0}
Local aTotalSai  	:= {0,0,0,0,0,0,0,0,0,0}
Local nI         	:= 0
Local nTotImp    	:= 0
Local lFound        := .T.
Local nPerAjust     := 0

Private cFilDapi 	:= aFil[1]
Private cUFID    	:= aFil[7]
Private dtCorte		:= aWizard[1][1]

Default lTermo := .F.

Begin Sequence   
	
	nPerAjust := GetNewPar( "MV_ALQPONT",0,cFilDapi) //Percentual de ajuste por pontualidade
		
	cStrTxt := cREG 									               	    	 				  //Tipo Linha					- Valor Fixo: 00
	cStrTxt += Substr(aFil[5],1,13)					              	 				 		  //Inscrição Estadual		- M0_INSC ( SIGAMAT )
	cStrTxt := Left(cStrTxt,15) + StrZero(Year(aWizard[1][1]),4,0)    		 				  //Ano Referência
	cStrTxt := Left(cStrTxt,19) + StrZero(Month(aWizard[1][1]),2,0)		 				  //Mês Referência
	cStrTxt := Left(cStrTxt,21) + StrZero(Day(aWizard[1][2]),2,0)			 				  //Dia final referência
	cStrTxt := Left(cStrTxt,23) + StrZero(Day(aWizard[1][1]),2,0)			 				  //Dia Inicial referência    
       
	
	//OPERAÇÕES ENTRADA	
	opEntDtrUF(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10, @aTotalEnt)
	opEntOutUF(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10,@aTotalEnt)
	opEntExter(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10,@aTotalEnt, @nTotImp)
	
	For nI := 1 to Len(aTotalEnt)	   
		addLinha(cStrTxt,"043",StrZero(nI,2,0),aTotalEnt[nI],@aReg10)				
	Next
	
	//OPERAÇÕES SAÍDA	
	opSaiDtrUF(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10, @aTotalSai)
	opSaiOutUF(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10, @aTotalSai)
	opSaiExter(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10, @aTotalSai)
	
	For nI := 1 to Len(aTotalSai)		
		addLinha(cStrTxt,"065",StrZero(nI,2,0),aTotalSai[nI],@aReg10)				
	Next	
	
	//OUTROS CRÉDITOS/DÉBITOS
	OutrCreDeb( aWizard, cStrTxt, @aReg10 )
	
	//ICMS ST
	ICMSST(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10)
	
	//APURAÇÃO ICMS
	ApurICMS(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10)
	
	//OBRIGAÇÕES
	Obrigacoes(cStrTxt, aWizard[1][1], aWizard[1][2], @aReg10, nTotImp)
	
	//INF. COMPLEMENTAR
	InfCompl(aWizard,cStrTxt, @aReg10)
	
	//INF. ECONÔMICAS
	InfEconomi(aWizard[1][1], aWizard[1][2], cStrTxt, @aReg10)
	
	//INF. COMPL. APURAÇÃO
	ApurCompl(aWizard[1][1], aWizard[1][2],cStrTxt, @aReg10, cFilDapi, IIF(lTermo,nPerAjust,0))

	While nPos < Len(aReg10)
		nPos++
		nCont++
		WrtStrTxt( nHandle, aReg10[nPos] )  
	EndDo

	GerTxtDAPI( nHandle, cTxtSys, cReg, cFilDapi)

Recover
	lFound := .F.

End Sequence

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ApurICMS

Função gerar o bloco de informações referente a apuração de ICMS na DAPI

@Param cStrTxt	->	String com a chave da linha
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento
		aReg10	->	Array com as linhas do Registro 10

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ApurICMS(cStrTxt, dDtIni, dDtFim, aReg10)	
	Local nTotCred := 0
	Local nTotDeb  := 0
	
	nEstFEM := AjusApur(DToS(dDtIni), DTOS(dDtFim), "00120",,"ICMS")
	
	DbSelectArea("C2S")
	C2S->(DbSetOrder(1))
	If C2S->(DbSeek(cFilDapi + '0' + DTOS(dDtIni) + DTOS(dDtFim) + " "))
		nTotCred := C2S->C2S_CREANT + C2S->C2S_TOTCRE + C2S->C2S_TAJUCR + C2S->C2S_AJUCRE + C2S->C2S_ESTDEB
		nTotDeb  := C2S->C2S_TOTDEB + C2S->C2S_TAJUDB + C2S->C2S_ESTCRE + C2S->C2S_AJUDEB
		addLinha(cStrTxt,"087","00",C2S->C2S_CREANT,@aReg10)		
		addLinha(cStrTxt,"088","00",C2S->C2S_TOTCRE,@aReg10)
		addLinha(cStrTxt,"089","00",C2S->C2S_TAJUCR + C2S->C2S_AJUCRE ,@aReg10)
		addLinha(cStrTxt,"090","00",C2S->C2S_ESTDEB - nEstFEM,@aReg10) //Estorno de FEM lançado no 90.1 (120)
		addLinha(cStrTxt,"091","00",nTotCred,@aReg10)
		addLinha(cStrTxt,"092","00",C2S->C2S_CRESEG,@aReg10)
		
		addLinha(cStrTxt,"093","00",C2S->C2S_TOTDEB,@aReg10)
		addLinha(cStrTxt,"094","00",C2S->C2S_TAJUDB + C2S->C2S_AJUDEB,@aReg10)
		addLinha(cStrTxt,"095","00",C2S->C2S_ESTCRE,@aReg10)
		addLinha(cStrTxt,"096","00",nTotDeb,@aReg10)
		addLinha(cStrTxt,"097","00",C2S->C2S_SDOAPU,@aReg10)				
		addLinha(cStrTxt,"098","00",C2S->C2S_TOTDED,@aReg10)
		nTotRec := C2S->C2S_TOTREC
	EndIf
	
	C2S->(DbCloseArea())
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ApurST

Função buscar as informaões referente a apuração de ICMS ST 

@Param 	dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		

@Return aVlrApurST -> Array com os valores da apuração de ST no período

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ApurST(dDtIni, dDtFim)	
	Local aVlrApurST as array
	
	aVlrApurST := {} 
	
	DbSelectArea("C3J")
	C3J->(DbSetOrder(1))
	If C3J->(DbSeek(cFilDapi + cUFID + DToS(dDtIni) + DToS(dDtFim) + "1"))
		aAdd(aVlrApurST, C3J->C3J_CREANT)
		aAdd(aVlrApurST, C3J->C3J_VLRRES)
		aAdd(aVlrApurST, C3J->C3J_VLRDEV)				
		aAdd(aVlrApurST, C3J->C3J_CRDTRA)		
		aAdd(aVlrApurST, C3J->C3J_VLRREC)
	EndIf
	
	C3J->(DbCloseArea())
	
Return aVlrApurST

//---------------------------------------------------------------------
/*/{Protheus.doc} ICMSST

Função gerar o bloco de informações referente a apuração de ICMS ST na DAPI

@Param cStrTxt	->	String com a chave da linha
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento
		aReg10	->	Array com as linhas do Registro 10

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ICMSST(cStrTxt, dDtIni, dDtFim, aReg10)
 	Local aICMSST as array
 	Local aVlrApurST as array    
    
    aICMSST := {}
    aVlrApurST := {}
	
	//Base de cálculo subst. Tributária Interna
	aICMSST := VLICMSST(dDtIni, dDtFim, .T.,"S")
	If(Len(aICMSST) > 0)
		addLinha(cStrTxt,"076","00",aICMSST[1],@aReg10)	
		
		//Valor Retido Interno	
		addLinha(cStrTxt,"077","00",aICMSST[2],@aReg10)
	EndIf
	
	//Saldo credor-ST do per Anterior
	aVlrApurST := ApurST(dDtIni, dDtFim)
	If(Len(aVlrApurST) > 0)
		addLinha(cStrTxt,"078","00",aVlrApurST[1],@aReg10)
		
		//Restituição ICMS	
		addLinha(cStrTxt,"079","00",aVlrApurST[2],@aReg10)
		
		//Devoluções
		addLinha(cStrTxt,"080","00",aVlrApurST[3],@aReg10)
		
		//Saldo credor-ST p/ período seguinte
		addLinha(cStrTxt,"081","00",aVlrApurST[4],@aReg10)
		
		//ICMS substituição tributária a recolher
		addLinha(cStrTxt,"082","00",aVlrApurST[5],@aReg10)
		nVlrRecST := aVlrApurST[5]
	EndIF
	
	
	//Base de cálculo subst. Tributária Interestaduais
	aICMSST := {}
	aICMSST := VLICMSST(dDtIni, dDtFim, .F., "S")
	If(Len(aICMSST) > 0)
		addLinha(cStrTxt,"083","00",aICMSST[1],@aReg10)
		
		//Valor Retido Interestaduais	
		addLinha(cStrTxt,"084","00",aICMSST[2],@aReg10)
	EndIf
	
	//Base de cálculo subst. Tributária Devido (entradas)
	aICMSST := {}
	aICMSST := VLICMSST(dDtIni, dDtFim, .F., "E")
	If(Len(aICMSST) > 0)
		addLinha(cStrTxt,"085","00",aICMSST[1],@aReg10)		
	
		//Valor Devido (entradas)
		addLinha(cStrTxt,"086","00",aICMSST[2],@aReg10)
		nVlrDevEnt := aICMSST[2]
	EndIf	

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} Obrigacoes

Função gerar o bloco de OBRIGAÇÕES na DAPI

@Param cStrTxt	->	String com a chave da linha
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento
		aReg10	->	Array com as linhas do Registro 10
		nTotImp -> Valor total das importações

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function Obrigacoes(cStrTxt, dDtIni, dDtFim, aReg10, nTotImp)
 	Local nValAjust    as numeric
 	Local nTotalObr    as numeric	
 	Local nTotalAnt    as numeric

	nTotalObr := 0
	nTotalAnt := 0
			 
	addLinha(cStrTxt,"099","00",nTotRec,@aReg10)
	nTotalObr += nTotRec
	
	//Diferencial de alíquota
	nValAjust := AjusApur(DToS(dDtIni), DTOS(dDtFim), "00100",,"ICMS")
	nTotalObr += nValAjust	 
	addLinha(cStrTxt,"100","00",nValAjust,@aReg10)	
	
	//Substituição Tributária por Entradas	
	addLinha(cStrTxt,"101","00",nVlrDevEnt,@aReg10)
	nTotalObr += nVlrDevEnt
	
	//Substituição Tributária por Saídas	
	addLinha(cStrTxt,"102","00",nVlrRecST,@aReg10)
	nTotalObr += nVlrRecST
	
	//Serviço de Transporte de responsabilidade do remetente
	nValAjust := STTranspor(dDtIni, dDtFim)
	nTotalObr += nValAjust	
	addLinha(cStrTxt,"103","00",nValAjust,@aReg10)  
	
	//Outros
	nValAjust := AjusApur(DToS(dDtIni), DTOS(dDtFim), "00104",,"ICMS")
	nTotalObr += nValAjust
	addLinha(cStrTxt,"104","00",nValAjust,@aReg10)
	
	//Recolhcimento Efetivo
	nRecEfetiv := RecEfetivo(dDtIni, dDtFim)
	nTotalObr += nRecEfetiv
	
	//TOTAL OBRIGAÇÕES
	addLinha(cStrTxt,"105","00",nTotalObr,@aReg10)
	
	//Importação	
	addLinha(cStrTxt,"106","00",nTotImp,@aReg10)
	nTotalAnt += nTotImp
	
	//Débito Extemporâneo
	nValAjust := AjusApur(DToS(dDtIni), DTOS(dDtFim), "00107",,"ICMS")
	nTotalAnt += nValAjust
	addLinha(cStrTxt,"107","00",nValAjust,@aReg10)	
	
	//Substituição Tributária - ICMS ANTECIPADO NA ENTRADA 
	nValAjust := ICMSanteci(dDtIni, dDtFim, "'000002','000004','000009','000010'") //CST 10, 30, 60 E 70
	nTotalAnt += nValAjust
	addLinha(cStrTxt,"108","00",nValAjust,@aReg10)	
	
	//Outros - ICMS ANTECIPADO NA ENTRADA 
	nValAjust := ICMSanteci(dDtIni, dDtFim, "'000011'") //CST 90
	nTotalAnt += nValAjust
	addLinha(cStrTxt,"109","00",nValAjust,@aReg10)
	
	//Total ICMS Antecipado
	addLinha(cStrTxt,"110","00",nTotalAnt,@aReg10)

	addLinha(cStrTxt,"131","10",nTotRec,@aReg10)

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} VLICMSST

Função para buscar a base e o valor do ICMS ST no período 

@Param dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento
		lInterno -> Indica se a operação é Interna (.T.) ou Externa (.F.)
		cOper -> Indica se a operação é de Saída ou Entrada

@Return aICMSST -> Base e Valor do ICMS ST
@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function VLICMSST(dDtIni, dDtFim, lInterno, cOper)
	
	Local cStrQuery  := ""
	Local cAliasQry  := GetNextAlias()  
	Local aICMSST    := {}
	
  
  cStrQuery += " SELECT SUM(C7A_BASE) BASE,"  
  cStrQuery += 		 " SUM(C7A_IMPCRD) VALOR"
  cStrQuery +=   " FROM " + RetSqlName('C3J') + " C3J, "
  cStrQuery +=              RetSqlName('C7A') + " C7A, "
  cStrQuery +=              RetSqlName('C0Y') + " C0Y "  
  cStrQuery += "  WHERE C3J.C3J_FILIAL                = '" + cFilDapi + "' "  
  cStrQuery +=   "  AND C3J.C3J_DTINI  BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "'"
  cStrQuery +=   "  AND C3J.C3J_INDMOV = '1' "  
  cStrQuery +=   "  AND C7A.C7A_FILIAL = C3J.C3J_FILIAL "
  cStrQuery +=   "  AND C7A.C7A_ID     = C3J.C3J_ID " 
  
  If(Alltrim(cOper) == "S")
	  If(lInterno)  
	  	cStrQuery +=   "  AND C7A.C7A_ESTADO =  '" + cUFID + "'"
	  	cStrQuery +=   "  AND C0Y.C0Y_CODIGO NOT IN ('5351', '5352', '5353', '5354','5355', '5356') "
	  	If AllTrim(TCGetDB()) == "POSTGRES"
	   		cStrQuery +=   "  AND CAST(C0Y.C0Y_CODIGO AS INTEGER) BETWEEN 5000 AND 5999 "
	   	Else
	   		cStrQuery +=   "  AND C0Y.C0Y_CODIGO BETWEEN 5000 AND 5999 "
	   	EndIf
	  Else	  	
	  	cStrQuery +=   "  AND C0Y.C0Y_CODIGO NOT IN ('6351', '6352', '6353', '6354','6355', '6356') "  
	  	If AllTrim(TCGetDB()) == "POSTGRES"
	  		cStrQuery +=   "  AND CAST(C0Y.C0Y_CODIGO AS INTEGER) BETWEEN 6000 AND 6999 "
	  	Else
	   		cStrQuery +=   "  AND C0Y.C0Y_CODIGO BETWEEN 6000 AND 6999 "
	   	Endif
	  EndIf
  Else
 		cStrQuery +=   "  AND C0Y.C0Y_CODIGO NOT IN ('1351', '1352', '1353', '1354','1355', '1356', '2351', '2352', '2353', '2354','2355', '2356') "  
 		If AllTrim(TCGetDB()) == "POSTGRES"
 			cStrQuery +=   "  AND (CAST(C0Y.C0Y_CODIGO AS INTEGER) BETWEEN 1000 AND 2999 ) "
 		Else
	   		cStrQuery +=   "  AND (C0Y.C0Y_CODIGO BETWEEN 1000 AND 2999 ) "
	   	EndIf
  EndIf
  
  cStrQuery +=   "  AND C7A.C7A_CFOP   = C0Y.C0Y_ID "
  cStrQuery +=   "  AND C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' "  
  cStrQuery +=   "  AND C7A.C7A_IMPCRD > 0 "
  cStrQuery += "    AND C3J.D_E_L_E_T_                         = ' ' "
  cStrQuery += "    AND C7A.D_E_L_E_T_                         = ' ' "  
  cStrQuery += "    AND C0Y.D_E_L_E_T_                         = ' ' "    

  cStrQuery := ChangeQuery(cStrQuery)
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasQry,.T.,.T.)
  DbSelectArea(cAliasQry)
  dbGoTop()

  While (cAliasQry)->(!Eof())
	  aAdd(aICMSST,(cAliasQry)->BASE)
	  aAdd(aICMSST,(cAliasQry)->VALOR)
	  (cAliasQry)->(DbSkip())
  EndDo
  
  (cAliasQry)->(DbCloseArea())

Return aICMSST

//---------------------------------------------------------------------
/*/{Protheus.doc} STTranspor

Função para buscar o valor total de ICMS ST de Transporte no período

@Param dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		

@Return nSTTransp -> Valor Total de ICMS ST de Transporte
@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function STTranspor(dDtIni, dDtFim)
	Local nSTTransp as numeric
	
	Local cStrQuery   := ""
	Local cAliasQry  := GetNextAlias()
  
  cStrQuery += " SELECT SUM(C7A_IMPCRD) VALOR"  
  cStrQuery +=   " FROM " + RetSqlName('C3J') + " C3J, "
  cStrQuery +=              RetSqlName('C7A') + " C7A, "
  cStrQuery +=              RetSqlName('C0Y') + " C0Y "  
  cStrQuery += "  WHERE C3J.C3J_FILIAL                = '" + cFilDapi + "' "  
  cStrQuery +=   "  AND C3J.C3J_DTINI  BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "'"
  cStrQuery +=   "  AND C3J.C3J_INDMOV = '1' "
  cStrQuery +=   "  AND C7A.C7A_FILIAL = C3J.C3J_FILIAL "
  cStrQuery +=   "  AND C7A.C7A_ID     = C3J.C3J_ID "
  cStrQuery +=   "  AND C7A.C7A_CFOP   = C0Y.C0Y_ID "
  cStrQuery +=   "  AND C0Y.C0Y_CODIGO IN ('1351', '2351', '1352', '2352', '1353', '2353', '1354','2354', '1355', '2355', '1356', '2356') "
  cStrQuery +=   "  AND C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' "    
  cStrQuery += "    AND C3J.D_E_L_E_T_ = ' ' "
  cStrQuery += "    AND C7A.D_E_L_E_T_ = ' ' "  
  cStrQuery += "    AND C0Y.D_E_L_E_T_ = ' ' "    

  cStrQuery := ChangeQuery(cStrQuery)
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasQry,.T.,.T.)
  DbSelectArea(cAliasQry)
  dbGoTop()

  nSTTransp := (cAliasQry)->VALOR
  
  (cAliasQry)->(DbCloseArea())

Return nSTTransp

//---------------------------------------------------------------------
/*/{Protheus.doc} RecEfetivo

Função para buscar na sub-apuração o valor de Recolhimento Efetivo.

@Param dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		

@Return nVlRec -> Valor do Recolhimento Efetivo

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function RecEfetivo(dDtIni, dDtFim)
	Local nVlRec as numeric
	
	Local cStrQuery   := ""
	Local cAliasQry  := GetNextAlias()
  
	cStrQuery := " SELECT SUM(C2S.C2S_TOTREC) VALOR"	  
	cStrQuery +=   " FROM " + RetSqlName('C2S') + " C2S "	  
	cStrQuery += "  WHERE C2S.C2S_FILIAL                = '" + cFilDapi + "' "  
	cStrQuery +=   "  AND C2S.C2S_DTINI  BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "'"
	cStrQuery +=   "  AND C2S.C2S_TIPAPU = '1'"    //sub-apuracao
	cStrQuery +=   "  AND C2S.C2S_INDAPU = '3'"
	cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ' '"
	
	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasQry,.T.,.T.)
	DbSelectArea(cAliasQry)
	dbGoTop()
	
	nVlRec := (cAliasQry)->VALOR
	
	(cAliasQry)->(DbCloseArea())

Return nVlRec

//---------------------------------------------------------------------
/*/{Protheus.doc} ICMSanteci

Função para buscar o valor de ICMSST Antecipado

@Param dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		
		cCST   -> Códigos CSTs 

@Return nSTAnt -> Valor do ICMSST Antecipado

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ICMSanteci(dDtIni, dDtFim, cCST)
	Local nSTAnt as numeric
	
	Local cStrQuery   := ""
	Local cAliasQry  := GetNextAlias()
	
  IF(cCST == "'000011'")  
  	cStrQuery := " SELECT SUM(C35_VLOUTR) VALOR "
  Else
  	cStrQuery := " SELECT SUM(C35_VALOR) VALOR "
  EndIf
  
  cStrQuery +=   " FROM "+  RetSqlName('C20') + " C20, "
  cStrQuery +=              RetSqlName('C35') + " C35, "  
  cStrQuery +=              RetSqlName('C02') + " C02  "
  cStrQuery += "  WHERE C20.C20_FILIAL                = '" + cFilDapi + "' "  
  cStrQuery +=   "  AND C20.C20_FILIAL = C35.C35_FILIAL "
  cStrQuery +=   "  AND C20.C20_CHVNF  = C35.C35_CHVNF "
  cStrQuery +=   "  AND C20.C20_DTES  BETWEEN '" + DToS(dDtIni) + "' AND '" + DToS(dDtFim) + "'"
  cStrQuery +=   "  AND C20.C20_CODSIT =  C02.C02_ID "        
  cStrQuery +=   "  AND C02.C02_FILIAL =  '" + xFilial("C02") + "' "  
  cStrQuery +=   "  AND C02.C02_CODIGO  NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA  
  cStrQuery +=   "  AND C35.C35_CODTRI = '000017'"   
  cStrQuery +=   "  AND C35.C35_CST IN ("+cCST+")"
  cStrQuery += "    AND C35.D_E_L_E_T_ = ' ' "
  cStrQuery += "    AND C20.D_E_L_E_T_ = ' ' "
  cStrQuery += "    AND C02.D_E_L_E_T_ = ' ' "
  
  cStrQuery := ChangeQuery(cStrQuery)
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasQry,.T.,.T.)
  DbSelectArea(cAliasQry)
  dbGoTop()

  nSTAnt := (cAliasQry)->VALOR
  
  (cAliasQry)->(DbCloseArea())

Return nSTAnt

//---------------------------------------------------------------------
/*/{Protheus.doc} opEntDtrUF

Função para gerar os valores da operações de Entrada Dentro do Estado de MG

@Param cStrTxt -> Chave para a linha do registro
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		
		aReg10 -> Array com as linhas do registro 10
		aTotalEnt -> Array com os totais das operações de entrada

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function opEntDtrUF(cStrTxt, dIni, dFim, aReg10, aTotalEnt)
 	Local cCfop      	:= "" 	
 	Local aSubTotal 	:= {0,0,0,0,0,0,0,0,0,0,0}
	Local nI  			:= 0
	
	//COMPRAS
	cCfop          := "'1101', '1102', '1111', '1113', '1116', '1117','1118', '1120', '1121', '1122', '1124', '1125', '1126', '1401', '1403', '1501', '1651', '1652', '1653'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "016", @aReg10, @aSubTotal)
	
	//TRANSFERÊNCIAS
	cCfop          := "'1151','1152','1153','1154','1408','1409','1658','1659'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "017", @aReg10, @aSubTotal)
	
	//DEVOLUCOES
	cCfop          := "'1201','1202','1203','1204','1205','1206','1207','1208','1209','1410','1411','1503','1504','1660','1661','1662'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "018", @aReg10, @aSubTotal)	
	
	//ENERGIA ELETRICA
	cCfop          := "'1251','1252','1253','1254','1255','1256','1257'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "019", @aReg10, @aSubTotal)
	
	//COMUNICACAO
	cCfop          := "'1301','1302','1303','1304','1305','1306'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "020", @aReg10, @aSubTotal)
	
	//TRANSPORTE
	cCfop          := "'1351','1352','1353','1354','1355','1356','1360','1931','1932'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "021", @aReg10, @aSubTotal)
	
	//ATIVO IMOBILIZADO
	cCfop          := "'1406','1551','1552','1553','1554','1555','1604'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "022", @aReg10, @aSubTotal)
	
	//USO E CONSUMO	
	cCfop := "'1407','1556','1557','1653'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "023", @aReg10, @aSubTotal,.T.)
	
	//OUTROS
	cCfop          := "'1414','1415','1451','1452','1901','1902','1903','1904','1905','1906','1907','1908','1909','1910','1911','1912','1913','1914','1915','1916','1917','1918','1919','1920','1921','1922','1923','1924','1925','1926','1933','1663','1664','1949', '1934','1505','1506'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "024", @aReg10, @aSubTotal)
	
	//GERA SUBTOTAL
	for nI := 1 to Len(aSubTotal)	   	
		addLinha(cStrTxt,"025",StrZero(nI,2,0),aSubTotal[nI],@aReg10)		
		aTotalEnt[nI] += aSubTotal[nI]
	Next		
   
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} opEntOutUF

Função para gerar os valores da operações de Entrada Fora do Estado de MG

@Param cStrTxt -> Chave para a linha do registro
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		
		aReg10 -> Array com as linhas do registro 10
		aTotalEnt -> Array com os totais das operações de entrada

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function opEntOutUF(cStrTxt, dIni, dFim, aReg10, aTotalEnt)
 	Local cCfop      := "" 	
 	Local aSubTotal  := {0,0,0,0,0,0,0,0,0,0,0}
 	Local nI  			:= 0
	
	//COMPRAS
	cCfop          := "'2101','2102','2111','2113','2116','2117','2118','2120','2121','2122','2124','2125','2126','2128','2401','2403','2501','2651','2652','2653'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "026", @aReg10, @aSubTotal)
	
	//TRANSFERÊNCIAS
	cCfop          := "'2151','2152','2153','2154','2408','2409','2658','2659'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "027", @aReg10, @aSubTotal)
	
	//DEVOLUCOES
	cCfop          := "'2201','2202','2203','2204','2205','2206','2207','2208','2209','2410','2411','2503','2504','2660','2661','2662'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "028", @aReg10, @aSubTotal)	
	
	//ENERGIA ELETRICA
	cCfop          := "'2251','2252','2253','2254','2255','2256','2257'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "029", @aReg10, @aSubTotal)
	
	//COMUNICACAO
	cCfop          := "'2301','2302','2303','2304','2305','2306'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "030", @aReg10, @aSubTotal)
	
	//TRANSPORTE
	cCfop          := "'2351','2352','2353','2354','2355','2356','2931','2932'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "031", @aReg10, @aSubTotal)
	
	//ATIVO IMOBILIZADO
	cCfop          := "'2406','2551','2552','2553','2554','2555','2604'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "032", @aReg10, @aSubTotal)
	
	//USO E CONSUMO	
	cCfop := "'2407','2556','2557', '2653'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "033", @aReg10, @aSubTotal,.T.)
	
	//OUTROS
	cCfop          := "'2414','2415','2901','2902','2903','2904','2905','2906','2907','2908','2909','2910','2911','2912','2913','2914','2915','2916','2917','2918','2919','2920','2921','2922','2923','2924','2925','2663','2664','2949','2933','2934', '2505','2506'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "034", @aReg10, @aSubTotal)
	
	//GERA SUBTOTAL
	for nI := 1 to Len(aSubTotal)		
		addLinha(cStrTxt,"035",StrZero(nI,2,0),aSubTotal[nI],@aReg10)		
		aTotalEnt[nI] += aSubTotal[nI]
	Next
   
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} opEntExter

Função para gerar os valores da operações de Entrada de Importação

@Param cStrTxt -> Chave para a linha do registro
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		
		aReg10 -> Array com as linhas do registro 10
		aTotalEnt -> Array com os totais das operações de entrada
		nTotImp -> Total de importação

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function opEntExter(cStrTxt, dIni, dFim, aReg10, aTotalEnt, nTotImp)
 	Local cCfop      := "" 	
 	Local aSubTotal  := {0,0,0,0,0,0,0,0,0,0,0}
 	Local nI  			:= 0
	
	//COMPRAS
	cCfop          := "'3101','3102','3126','3127','3128','3651','3652','3653'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "036", @aReg10, @aSubTotal)
	
	//DEVOLUÇÕES
	cCfop          := "'3201','3202','3205','3206','3207','3211','3503'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "037", @aReg10, @aSubTotal)
	
	//ENERGIA
	cCfop          := "'3251','3301','3351','3352','3353','3354','3355','3356'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "038", @aReg10, @aSubTotal)	
	
	//ATIVO IMOBILIZADO
	cCfop          := "'3551','3553'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "039", @aReg10, @aSubTotal)
	
	//USO E CONSUMO	 
	cCfop := "'3556','3653'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "040", @aReg10, @aSubTotal,.T.)
	
	//OUTRAS
	cCfop          := "'3930','3949'"
	operEntrad(dIni, dFim, cCfop, cStrTxt, "041", @aReg10, @aSubTotal)	
	
	//GERA SUBTOTAL
	For nI := 1 to Len(aSubTotal)		
		addLinha(cStrTxt,"042",StrZero(nI,2,0),aSubTotal[nI],@aReg10)		
		aTotalEnt[nI] += aSubTotal[nI]
		IIF(nI == 3, nTotImp += aSubTotal[nI], Nil ) //acumular soma de importação para linha 106
		IIF(nI == 4, nTotImp += aSubTotal[nI], Nil )  //acumular soma de importação para linha 106
	Next		
   
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} opSaiDtrUF

Função para gerar os valores da operações de Saída dentro do Estado de MG

@Param cStrTxt -> Chave para a linha do registro
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		
		aReg10 -> Array com as linhas do registro 10
		aTotalSai -> Array com os totais das operações de saída		

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function opSaiDtrUF(cStrTxt, dIni, dFim, aReg10, aTotalSai)
 	Local cCfop      := "" 	
 	Local aSubTotal  := {0,0,0,0,0,0,0,0,0,0}
 	Local nI  			:= 0
	
	//VENDAS
	cCfop          := "'5101','5102','5103','5104','5105','5106','5109','5110','5111','5112','5113','5114','5115','5116','5117','5118','5119','5120','5122','5123','5124','5125','5401','5402','5403','5405','5501','5502','5651','5652','5653','5654','5655','5656','5667','5933'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "044", @aReg10, @aSubTotal)
	
	//TRANSFERÊNCIAS
	cCfop          := "'5151','5152','5153','5155','5156','5408','5409','5552','5557','5658','5659'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "045", @aReg10, @aSubTotal)
	
	//DEVOLUCOES
	cCfop          := "'5201','5202','5205','5206','5207','5208','5209','5210','5410','5411','5412','5413','5503','5553','5556','5660','5661','5662'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "046", @aReg10, @aSubTotal)	
	
	//ENERGIA ELETRICA
	cCfop          := "'5251','5252','5253','5254','5255','5256','5257','5258'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "047", @aReg10, @aSubTotal)
	
	//COMUNICACAO
	cCfop          := "'5301','5302','5303','5304','5305','5306','5307'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "048", @aReg10, @aSubTotal)
	
	//TRANSPORTE
	cCfop          := "'5351','5352','5353','5354','5355','5356','5357','5359','5360'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "049", @aReg10, @aSubTotal)	
	
	//OUTROS
	cCfop          := "'5414','5415','5451','5505','5551','5554','5555','5901','5902','5903','5904','5905','5906','5907','5908','5909','5910','5911','5912','5913','5914','5915','5916','5917','5918','5919','5920','5921','5922','5923','5924','5925','5926','5927','5928','5929','5931','5932','5934','5949','5657','5663','5664','5665','5666','5504'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "050", @aReg10, @aSubTotal)
	
	//GERA SUBTOTAL
	for nI := 1 to Len(aSubTotal)		
		addLinha(cStrTxt,"051",StrZero(nI,2,0),aSubTotal[nI],@aReg10)		
		aTotalSai[nI] += aSubTotal[nI]
	Next			
   
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} opSaiOutUF

Função para gerar os valores da operações de Saída fora do Estado de MG

@Param cStrTxt -> Chave para a linha do registro
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		
		aReg10 -> Array com as linhas do registro 10
		aTotalSai -> Array com os totais das operações de saída		

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function opSaiOutUF(cStrTxt, dIni, dFim,aReg10, aTotalSai)
 	Local cCfop      	:= "" 	
 	Local aSubTotal  	:= {0,0,0,0,0,0,0,0,0,0}
 	Local nI  			:= 0
	
	//VENDAS
	cCfop          := "'6101','6102','6103','6104','6105','6106','6107','6108','6109','6110','6111','6112','6113','6114','6115','6116','6117','6118','6119','6120','6122','6123','6124','6125','6401','6402','6403','6404','6501','6502','6651','6652','6653','6654','6655','6656','6667'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "052", @aReg10, @aSubTotal)
	
	//TRANSFERÊNCIAS
	cCfop          := "'6151','6152','6153','6155','6156','6408','6409','6552','6557','6658','6659'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "053", @aReg10, @aSubTotal)
	
	//DEVOLUCOES
	cCfop          := "'6201','6202','6205','6206','6207','6208','6209','6210','6410','6411','6412','6413','6503','6553','6556','6660','6661','6662'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "054", @aReg10, @aSubTotal)	
	
	//ENERGIA ELETRICA
	cCfop          := "'6251','6252','6253','6254','6255','6256','6257','6258'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "055", @aReg10, @aSubTotal)
	
	//COMUNICACAO
	cCfop          := "'6301','6302','6303','6304','6305','6306','6307'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "056", @aReg10, @aSubTotal)
	
	//TRANSPORTE
	cCfop          := "'6351','6352','6353','6354','6355','6356','6357','6359','6360'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "057", @aReg10, @aSubTotal)	
	
	//OUTROS
	cCfop          := "'6414','6415','6504','6551','6554','6555','6901','6902','6903','6904','6905','6906','6907','6908','6909','6910','6911','6912','6913','6914','6915','6916','6917','6918','6919','6920','6921','6922','6923','6924','6925','6929','6931','6932','6949','6657','6663','6664','6665','6666','6934','6933','6505'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "058", @aReg10, @aSubTotal)
	
	//GERA SUBTOTAL
	for nI := 1 to Len(aSubTotal)		
		addLinha(cStrTxt,"059",StrZero(nI,2,0),aSubTotal[nI],@aReg10)		
		aTotalSai[nI] += aSubTotal[nI]
	Next
   
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} opSaiExter

Função para gerar os valores da operações de Saída de Exportação

@Param cStrTxt -> Chave para a linha do registro
		dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento		
		aReg10 -> Array com as linhas do registro 10
		aTotalSai -> Array com os totais das operações de saída		

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function opSaiExter(cStrTxt, dIni, dFim, aReg10,aTotalSai)
 	Local cCfop      := "" 	
 	Local aSubTotal  	:= {0,0,0,0,0,0,0,0,0,0}
 	Local nI  			:= 0
	
	//COMPRAS
	cCfop          := "'7101','7102','7105','7106','7127','7651','7654','7667'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "060", @aReg10, @aSubTotal)
	
	//DEVOLUÇÕES
	cCfop          := "'7201','7202','7205','7206','7207','7210','7211','7553','7556'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "061", @aReg10, @aSubTotal)
	
	//ENERGIA
	cCfop          := "'7251','7301','7358'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "062", @aReg10, @aSubTotal)
	
	//OUTRAS
	cCfop          := "'7501','7551','7930','7949'"
	operSaida(dIni, dFim, cCfop, cStrTxt, "063", @aReg10, @aSubTotal)	
	
	//GERA SUBTOTAL
	for nI := 1 to Len(aSubTotal)		
		addLinha(cStrTxt,"064",StrZero(nI,2,0),aSubTotal[nI],@aReg10)		
		aTotalSai[nI] += aSubTotal[nI]
	Next		
   
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InfEconomi

Função para gerar os valores referente ao bloco de Informações Econômicas

@Param 	dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento
		cStrTxt -> Chave para a linha do registro		
		aReg10 -> Array com as linhas do registro 10				

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function InfEconomi(dIni,dFim, cStrTxt, aReg10)
	Local cStrQuery := ""
	Local cAliasApur  := GetNextAlias()
		
	cStrQuery := "SELECT C2X.C2X_INFADC, " 
	cStrQuery +=    "SUM(C2X.C2X_VLRINF) C2X_VLRINF "
	cStrQuery +=  " FROM " + RetSqlName('C2S') + " C2S, "   
	cStrQuery +=             RetSqlName('C2X') + " C2X "
	cStrQuery += "  WHERE C2S.C2S_FILIAL                = '" + cFilDapi + "' "
	cStrQuery +=   "  AND C2S.C2S_DTINI  BETWEEN '" + DToS(dIni) + "' AND '" + DToS(dFim) + "'"
	cStrQuery +=   "  AND C2S.C2S_TIPAPU = '0'"
	cStrQuery +=   "  AND C2S.C2S_INDAPU = ' '"
	cStrQuery +=   "  AND C2S.C2S_FILIAL = C2X.C2X_FILIAL "
	cStrQuery +=   "  AND C2S.C2S_ID     = C2X.C2X_ID "
	cStrQuery +=   "  AND C2X.C2X_INFADC IN ('MG000001','MG000002','MG000004') "
	cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ' ' "
	cStrQuery +=   "  AND C2X.D_E_L_E_T_ = ' ' "
	cStrQuery +=   "  GROUP BY C2X.C2X_INFADC "
	cStrQuery +=   "  ORDER BY C2X.C2X_INFADC "
	
	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasApur,.T.,.T.)
	
	DbSelectArea(cAliasApur)
	dbGoTop()  
  
    While (cAliasApur)->(!Eof()) 
	   Do Case
	  		Case (cAliasApur)->C2X_INFADC == 'MG000001
	   			// Nº de Empregados no último dia do período
  				addLinha(cStrTxt,"115","00",(cAliasApur)->C2X_VLRINF,@aReg10)
  				
			Case (cAliasApur)->C2X_INFADC == 'MG000002
				//  Valor da folha de pagamento
				addLinha(cStrTxt,"116","00",(cAliasApur)->C2X_VLRINF,@aReg10)
			
			Case (cAliasApur)->C2X_INFADC == 'MG000004
				//  Energia Eletrica Consumida no Período (kwh)
				addLinha(cStrTxt,"118","00",(cAliasApur)->C2X_VLRINF,@aReg10)
		EndCase
		
		(cAliasApur)->(DbSkip()) 
	 EndDo	
	
	DbCloseArea()
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} ApurCompl

Função para gerar valores complementares da apuração de ICMS e ICMSST

@Param 	dDtIni ->	Data Inicial do período de processamento
		dDtFim	->	Data Final do período de processamento
		cStrTxt -> Chave para a linha do registro		
		aReg10 -> Array com as linhas do registro 10				

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function ApurCompl(dDtIni, dDtFim, cStrTxt, aReg10, cFil, nPerAjust)
		
Local nValAjust as numeric 
Local nValFEM   as numeric
Local nValPont  as numeric // Ajuste por pontualidade
Local nX        as numeric
Local aApurST   as array

Default nPerAjust := 0

//Fundo de Err. Da Miséria FEM
nValFEM := AjusApur(DToS(dDtIni), DTOS(dDtFim), "00119",,"ICMSST")
addLinha(cStrTxt,"119","00",nValFEM,@aReg10)

//  Estorno FEM	
addLinha(cStrTxt,"120","00",nEstFEM,@aReg10)

//  Total FEM	
addLinha(cStrTxt,"121","00",nValFEM + nEstFEM, @aReg10)

//Total ICMS FEM Antecipado
nValAjust := AjusApur(DToS(dDtIni), DTOS(dDtFim), "00122",,"ICMSST")
addLinha(cStrTxt,"122","00",nValAjust,@aReg10)

//Recolhimento Efetivo
addLinha(cStrTxt,"123","00",nRecEfetiv,@aReg10)

//Linhas 124 e 125 não foram implementadas, pois esses campos foram desabilitados a partir do período de referência 05/2019

aApurST := FisApur("ST",val(Substr(DTOS(dDtFim),1,4)),val(Substr(DTOS(dDtFim),5,2)),2,0,"*",.F.,{},1,.F.,"")

For nX := 1 To Len(aApurST)

	If aApurST[nX,4] == "002.01"
		addLinha(cStrTxt,"126","00",aApurST[nX,3],@aReg10)
	EndIf
	
	If aApurST[nX,4] == "008.01"
		addLinha(cStrTxt,"128","00",aApurST[nX,3],@aReg10)
	EndIf

Next nX

//Linhas 127, 129, 132 e 133 - não foram encontradas referências no Protheus nem na documentação do SEFAZ-MG, portanto também não foram implementados.

If nPerAjust > 0
	nValPont := GetDapiPntVlr( nPerAjust, nTotRec * Val("0." + StrZero(nPerAjust,2)) )
	
	addLinha(cStrTxt,"130","00",nValPont,@aReg10)
	
	addLinha(cStrTxt,"131","00",nTotRec - nValPont,@aReg10)
EndIf
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InfCompl

Função para gerar as linhas referente a Informações Complementares

@Param 	aWizard	->	Array com as informacoes da Wizard		
		cStrTxt -> Chave para a linha do registro		
		aReg10 -> Array com as linhas do registro 10				

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function InfCompl(aWizard, cStrTxt, aReg10)
	Local nVlContab := 0
 
	//Exportação Indireta
	nVlContab := vlContabNF(DToS(aWizard[1][1]),DToS(aWizard[1][2]),"'7501'")
  	addLinha(cStrTxt,"111","00",nVlContab,@aReg10)
  	
  	//Saídas para SUFRAMA
	nVlContab := vlContabNF(DToS(aWizard[1][1]),DToS(aWizard[1][2]),"'6109','6110'")
  	addLinha(cStrTxt,"112","00",nVlContab,@aReg10)
  	
  	//Exportação Direta
	nVlContab := vlContabNF(DToS(aWizard[1][1]),DToS(aWizard[1][2]),"'7101','7102','7105','7106','7127'")
  	addLinha(cStrTxt,"113","00",nVlContab,@aReg10)
  	
  	//Remessa com fim específico de exportação
	nVlContab := vlContabNF(DToS(aWizard[1][1]),DToS(aWizard[1][2]),"'5501','5502','6501','6502'")
  	addLinha(cStrTxt,"114","00",nVlContab,@aReg10)
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} vlContabNF

Função para buscar valor contábil das notas fiscais

@Param 	cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento
		cCfop -> CFOPs

@Return nVlContab -> Valor contábil total
@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function vlContabNF(cPerIni, cPerFim, cCfop)
	Local cStrQuery   := ""
	Local cAliasNF  := GetNextAlias()
	Local nVlContab := 0
  
	cStrQuery += " SELECT SUM(C30.C30_VLOPER) VL_CONTAB"  
	cStrQuery +=   " FROM " + RetSqlName('C30') + " C30, "  
	cStrQuery +=              RetSqlName('C20') + " C20, "
	cStrQuery +=              RetSqlName('C02') + " C02, "
	cStrQuery +=              RetSqlName('C0Y') + " C0Y "	
	cStrQuery += "  WHERE C30.C30_FILIAL                = '" + cFilDapi + "' "  
	cStrQuery +=   "  AND C30.C30_FILIAL = C20.C20_FILIAL "
	cStrQuery +=   "  AND C30.C30_FILIAL = C30.C30_FILIAL "
	cStrQuery +=   "  AND C30.C30_CHVNF  = C20.C20_CHVNF "
	cStrQuery +=   "  AND C30.C30_CFOP   = C0Y.C0Y_ID " 
	cStrQuery +=   "  AND C20.C20_DTES BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"
	cStrQuery +=   "  AND C20.C20_CODSIT =  C02.C02_ID "        
	cStrQuery +=   "  AND C02.C02_FILIAL =  '" + xFilial("C02") + "' "  
	cStrQuery +=   "  AND C02.C02_CODIGO  NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA
	cStrQuery +=   "  AND C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' "  
	cStrQuery +=   "  AND C0Y.C0Y_CODIGO                IN ("+ cCfop+ ") "  
	cStrQuery += "    AND C30.D_E_L_E_T_                         = ' ' "
	cStrQuery += "    AND C20.D_E_L_E_T_                         = ' ' "
	cStrQuery += "    AND C02.D_E_L_E_T_                         = ' ' "
	cStrQuery += "    AND C0Y.D_E_L_E_T_                         = ' ' "	
	
	cStrQuery := ChangeQuery(cStrQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasNF,.T.,.T.)
	DbSelectArea(cAliasNF)
	dbGoTop() 	
	
	nVlContab := (cAliasNF)->VL_CONTAB
	
	DbCloseArea()
Return nVlContab

//---------------------------------------------------------------------
/*/{Protheus.doc} OutrCreDeb

Função para gerar as informações do bloco Outros Créditos/Débitos

@Param 	aWizard	->	Array com as informacoes da Wizard		
		cStrTxt -> Chave para a linha do registro		
		aReg10 -> Array com as linhas do registro 10


@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function OutrCreDeb( aWizard, cStrTxt, aReg10 )
  	Local nVlrAjus := 0
  	Local nTotAjus := 0
  	
  	//------- OUTROS CRÉDITOS ---//
  	// 066 - DETALHAMENTO DE CRÉDITOS RECEBIDOS
  	nVlrAjus := AjusApur(DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00066","0","ICMS")
  	nTotAjus += nVlrAjus  	
  	addLinha(cStrTxt,"066","00", nVlrAjus, @aReg10)
  	
  	// 067 - CRÉDITO PRESSUMIDO
  	nVlrAjus := AjusApur(DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00067","0","ICMS")
  	nTotAjus += nVlrAjus  	
  	addLinha(cStrTxt,"067","00", nVlrAjus, @aReg10)  	
  	
  	// 068 - Crédito Extemporâneo
  	nVlrAjus := AjusApur(DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00068","0","ICMS")
  	nTotAjus += nVlrAjus  	
  	addLinha(cStrTxt,"068","00", nVlrAjus, @aReg10)
  	
  	// 069 - Diferença de alíquota
  	nVlrAjus := AjusApur(DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00069","0","ICMS")
  	nTotAjus += nVlrAjus  	
  	addLinha(cStrTxt,"069","00", nVlrAjus, @aReg10)
  	
  	// 070 - Ressarcimento por ST
  	nVlrAjus := AjusApur(DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00070","0","ICMSST")
  	nTotAjus += nVlrAjus  	
  	addLinha(cStrTxt,"070","00", nVlrAjus, @aReg10)
  	
  	// 071 - Outros Créditos
  	nVlrAjus := AjusApur(DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00071","0","ICMS")
  	nTotAjus += nVlrAjus  	
  	addLinha(cStrTxt,"071","00", nVlrAjus, @aReg10)
  	
  	// 072 - Total Outros Créditos  	  	
  	addLinha(cStrTxt,"072","00", nTotAjus, @aReg10)
  	nTotAjus := 0  	
  	
  	//------- OUTROS CRÉDITOS ---//  	
  	// 073 - Créditos Transferidos	
  	nVlrAjus := AjusApur( DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00073", "1","ICMS" )
  	nTotAjus += nVlrAjus  	
  	addLinha(cStrTxt,"073","00", nVlrAjus, @aReg10)
  	
  	// 074 - Outros Débitos
  	nVlrAjus := AjusApur(DToS(aWizard[1][1]), DTOS(aWizard[1][2]), "00074","1","ICMS" )
  	nTotAjus += nVlrAjus  	
  	addLinha(cStrTxt,"074","00", nVlrAjus, @aReg10)
  	
  	// 075 - Total Outros Débitos
  	addLinha(cStrTxt,"075","00", nTotAjus, @aReg10)
	
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} AjusApur

Função para buscar valores dos ajustes da apuração de ICMS/ICMST e 
dos documentos fiscais

@Param 	cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento
		cSubitem -> Código do subitem
		cTipOpe -> Indica se é Entrada (0) ou Saída (1)
		cTrib -> Indica se é ICMS ou ICMSST

@Return nValAjus -> Valor total dos ajustes

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function AjusApur(cPerIni, cPerFim, cSubitem, cTipOpe, cTrib)
  Local nValAjus  := 0
  Local cStrQuery := ""
  Local cAliasApur  := GetNextAlias()
  
  If AllTrim(cTrib) == "ICMS"
	  
	  If(cSubitem != "00066")
		  cStrQuery := " SELECT SUM(C2T.C2T_VLRAJU)  VLR_AJUS"
		  cStrQuery +=   " FROM " + RetSqlName('C2S') + " C2S, "
		  cStrQuery +=              RetSqlName('C2T') + " C2T, "	  
		  cStrQuery +=              RetSqlName('CHY') + " CHY  "
		  cStrQuery += "  WHERE C2S.C2S_FILIAL                = '" + cFilDapi + "' "  
		  cStrQuery +=   "  AND C2S.C2S_TIPAPU = '0'"
		  cStrQuery +=   "  AND C2S.C2S_DTINI  BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"	  
		  cStrQuery +=   "  AND C2S.C2S_INDAPU = ' '"
		  cStrQuery +=   "  AND C2S.C2S_FILIAL = C2T.C2T_FILIAL "
		  cStrQuery +=   "  AND C2S.C2S_ID     = C2T.C2T_ID "	  
		  cStrQuery +=   "  AND C2T.C2T_IDSUBI = CHY.CHY_ID "
		  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "  
		  cStrQuery +=   "  AND CHY.CHY_IDUF   =  '" + cUFID + "'"
		  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"	  
		  cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ' '"
		  cStrQuery +=   "  AND C2T.D_E_L_E_T_ = ' '"
		  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"
	  EndIf	  
	  
	  if(!Empty(cTipOpe)) //considera os ajustes da nota (c197)
		  If(cSubitem != "00066")		  	 
		  	 cStrQuery += "  UNION "
		  	 cStrQuery += " SELECT SUM(C2D.C2D_VLICM) VLR_AJUS"
		  Else
		  	 cStrQuery += " SELECT SUM(C2D.C2D_BSICM) VLR_AJUS"
		  EndIf		  
		  
		  cStrQuery +=   " FROM " + RetSqlName('C20') + " C20, "
		  cStrQuery +=              RetSqlName('C2D') + " C2D, "
		  cStrQuery +=              RetSqlName('C02') + " C02,  "
		  cStrQuery +=              RetSqlName('CHY') + " CHY  "
		  
		  If(cSubitem == "00066")
		  		cStrQuery +=     ","+RetSqlName('T0V') + " T0V  "
		  EndIf
		  
		  cStrQuery += "  WHERE C20.C20_FILIAL                = '" + cFilDapi + "' "  
		  cStrQuery +=   "  AND C20.C20_DTES  BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"  
		  cStrQuery +=   "  AND C20.C20_FILIAL = C2D.C2D_FILIAL "
		  cStrQuery +=   "  AND C20.C20_CHVNF  = C2D.C2D_CHVNF "
		  cStrQuery +=   "  AND C20.C20_INDOPE = '"+ cTipOpe + "'"
		  cStrQuery +=   "  AND C20.C20_CODSIT =  C02.C02_ID "        
		  cStrQuery +=   "  AND C02.C02_FILIAL =  '" + xFilial("C02") + "' "  
		  cStrQuery +=   "  AND C02.C02_CODIGO  NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA
		  cStrQuery +=   "  AND C2D.C2D_IDSUBI = CHY.CHY_ID "
		  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "  	  
		  cStrQuery +=   "  AND CHY.CHY_IDUF   = '" + cUFID + "'"
		  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"
		  
		  If(cSubitem == "00066")
		  	cStrQuery +=   "  AND C2D.C2D_IDTMOT = T0V.T0V_ID "
		  	cStrQuery +=   "  AND T0V.T0V_CODIGO NOT IN ('00008','00009','00031','00032','00052','00053', '00061') "
		  	cStrQuery +=   "  AND T0V.T0V_FILIAL = '" + xFilial("T0V") + "' "  	  	
		  	cStrQuery +=   "  AND T0V.D_E_L_E_T_ = ' '"	  		
		  EndIf
		  
		  cStrQuery +=   "  AND C20.D_E_L_E_T_ = ' '"
		  cStrQuery +=   "  AND C2D.D_E_L_E_T_ = ' '"
		  cStrQuery +=   "  AND C02.D_E_L_E_T_ = ' '"
		  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"		  
	  EndIf	  
  Else
     cStrQuery := " SELECT  SUM(C3K.C3K_VLRAJU) VLR_AJUS"
	  cStrQuery +=   " FROM " + RetSqlName('C3J') + " C3J, "
	  cStrQuery +=              RetSqlName('C3K') + " C3K, "
	  cStrQuery +=              RetSqlName('CHY') + " CHY "  
	  cStrQuery += "  WHERE C3J.C3J_FILIAL                = '" + cFilDapi + "' "  
	  cStrQuery +=   "  AND C3J.C3J_UF     = '" + cUFID + "'"
	  cStrQuery +=   "  AND C3J.C3J_DTINI  BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"	  
	  cStrQuery +=   "  AND C3J.C3J_INDMOV = '1'"
	  cStrQuery +=   "  AND C3J.C3J_FILIAL = C3K.C3K_FILIAL "
	  cStrQuery +=   "  AND C3J.C3J_ID     = C3K.C3K_ID "
	  cStrQuery +=   "  AND C3K.C3K_IDSUBI = CHY.CHY_ID "
	  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "  
	  cStrQuery +=   "  AND CHY.CHY_IDUF   = '" + cUFID + "'"
	  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"
	  cStrQuery +=   "  AND C3J.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C3K.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"
	  
	  if(!Empty(cTipOpe)) //considera os ajustes da nota (c197)
		  cStrQuery +=   "  UNION "
		  cStrQuery += " SELECT SUM(C2D.C2D_VLICM) VLR_AJUS"
		  cStrQuery +=   " FROM " + RetSqlName('C20') + " C20, "
		  cStrQuery +=              RetSqlName('C2D') + " C2D, "
		  cStrQuery +=              RetSqlName('C02') + " C02, "
		  cStrQuery +=              RetSqlName('CHY') + " CHY "  
		  cStrQuery += "  WHERE C20.C20_FILIAL                = '" + cFilDapi + "' "  
		  cStrQuery +=   "  AND C20.C20_DTES     BETWEEN  '" + cPerIni + "' AND '" + cPerFim + "'"	  
		  cStrQuery +=   "  AND C20.C20_FILIAL = C2D.C2D_FILIAL "
		  cStrQuery +=   "  AND C20.C20_CHVNF  = C2D.C2D_CHVNF "
		  cStrQuery +=   "  AND C20.C20_INDOPE = '"+ cTipOpe + "'"
		  cStrQuery +=   "  AND C20.C20_CODSIT =  C02.C02_ID "        
		  cStrQuery +=   "  AND C02.C02_FILIAL =  '" + xFilial("C02") + "' "  
		  cStrQuery +=   "  AND C02.C02_CODIGO  NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA		  
		  cStrQuery +=   "  AND C2D.C2D_IDSUBI = CHY.CHY_ID "
		  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "  
		  cStrQuery +=   "  AND CHY.CHY_IDUF   = '" + cUFID + "'"
		  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"
		  cStrQuery +=   "  AND C20.D_E_L_E_T_ = ' '"
		  cStrQuery +=   "  AND C2D.D_E_L_E_T_ = ' '"
		  cStrQuery +=   "  AND C02.D_E_L_E_T_ = ' '"
		  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"		  
	  Endif
  EndIf
  
  cStrQuery := ChangeQuery(cStrQuery)
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasApur,.T.,.T.)
  DbSelectArea(cAliasApur)
  dbGoTop()
  
  While (cAliasApur)->(!Eof()) 
  		nValAjus += (cAliasApur)->VLR_AJUS
  	   (cAliasApur)->(DbSkip())  
  EndDo
  
  DbCloseArea()

Return nValAjus

//---------------------------------------------------------------------
/*/{Protheus.doc} OperEntrad

Função para buscar valores referente os documentos fiscais de entrada.

@Param 	dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento
		cCfop -> CFOP
		cStrTxt -> Chave da linha
		cLin 	-> Código da linha da DAPI
		aReg10 -> Array com as linhas do registro 10
		aSubTotal -> Subtotal das linhas
		lUsoCons -> Indica se é Uso e Consumo ou Não.

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function OperEntrad(dIni, dFim, cCfop, cStrTxt, cLin, aReg10, aSubTotal, lUsoCons )

Local aValCST    := {}
Local nIsentas   := 0
Local nNtribut   := 0
Local nDiferid   := 0
Local nSuspens   := 0
Local nOutras    := 0
Local nContabil  := 0
Local nBase      := 0
Local nImposto   := 0
Local nSemCred   := 0
Local nBaseNT    := 0
Local nX         := 0
Local oTTable    := Nil
Local nlA 		 := 0
Local aValIpi 	 := {}
Local lExec   	 := .F.
Local lFilNts 	 := .F.
Local lGroup  	 := .F.
Local cQry 	  	 := ""
Local cAliTmp 	 := ""

Default lUsoCons := .F.

//cria a Temporaria
TTableDapi( @oTTable, @cAliTmp )

//{ trecho1 }select do insert into na temporaria, por filial e nota, utilizado no join do { trecho2 }
lExec   := .F.
lFilNts := .T.
lGroup  := .T.
fnVlrOpera('000002', DToS(dIni), DToS(dFim), cCfop, lUsoCons, lExec, lFilNts, lGroup, @cQry, Nil)

cQry := "INSERT INTO " + cAliTmp + "(FILIAL, NUMDOC, BASE, VCONT, VIMPOS, VSCRED, VISEN, VNTRIB, VBNTRI, VOUTRO) " + cQry

If(TCSQLExec(cQry) < 0); MsgInfo(TCSQLError(),"Warning"); EndIf

//busca icms '000002'
lExec   := .T.
lFilNts := .F.
lGroup  := .T.
cQry 	:= ""
aValCST	:= fnVlrOpera('000002', DToS(dIni), DToS(dFim), cCfop, lUsoCons, lExec, lFilNts, lGroup, cQry, Nil )

For nX := 1 TO Len(aValCST)
	Do Case		   
	Case aValCST[nX,1] == "000005"  
		nIsentas := aValCST[nX,6]
	Case aValCST[nX,1] == "000006" 
		nNtribut := aValCST[nX,6]
	Case aValCST[nX,1] == "000008" 
		nDiferid := aValCST[nX,9]
	Case aValCST[nX,1] == "000007" 
		nSuspens := aValCST[nX,9]
	Case aValCST[nX,1] == "000011" 
		nOutras := aValCST[nX,9]		   
	EndCase	
	nContabil += aValCST[nX,2]
	nBase     += aValCST[nX,3]
	nImposto  += aValCST[nX,4]
	nSemCred  += aValCST[nX,5]
	nBaseNT   += aValCST[nX,8]
Next nX

//busca icms st '000004'
lExec   := .T.
lFilNts := .F.
lGroup  := .T.
cQry 	:= ""
aValCST	:= fnVlrOpera('000004', DTOS(dIni), DToS(dFim), cCfop, lUsoCons, lExec, lFilNts, lGroup, cQry, Nil )
IIF(len(aValCST)>0,nICMSST := aValCST[1,4],nICMSST := 0)	// VALOR IMPOST ICMS ST

If(lUsoCons)
	nBase    := 0
	nImposto := 0
EndIf

//{ trecho2 } Join Notas ICMS x IPI
lExec   := .T.
lFilNts := .T.
lGroup  := .T.
cQry 	:= ""
aValIpi := fnVlrOpera('000005', DToS(dIni), DToS(dFim), cCfop, lUsoCons, lExec, lFilNts, lGroup, cQry, cAliTmp )

for nlA := 1 to len( aValIpi )
	nOutras += aValIpi[nlA][4] //valor tributo ipi
next nlA

DelTmpDapi( @oTTable )

//SUBTOTAL
aSubTotal[1]  += nContabil //SUBTOTAL VL CONTABIL
aSubTotal[2]  += nBase     //SUBTOTAL BASE
aSubTotal[3]  += nImposto  //SUBTOTAL CREDITO
aSubTotal[4]  += nSemCred  //SUBTOTAL SEM APROV. CREDITO
aSubTotal[5]  += nIsentas  //SUBTOTAL ISENTAS
aSubTotal[6]  += nNtribut  //SUBTOTAL NAO TRIBUTADAS
aSubTotal[7]  += nBaseNT   //SUBTOTAL BASE NT
aSubTotal[8]  += nDiferid  //SUBTOTAL DIFERIMENTO
aSubTotal[9]  += nSuspens  //SUBTOTAL SUSPENSA
aSubTotal[10] += nICMSST   //SUBTOTAL ICMS ST
aSubTotal[11] += nOutras   //SUBTOTAL OUTRAS

//VALOR CONTABIL
addLinha(cStrTxt,cLin,"01",nContabil,@aReg10)	

//BASE CÁLCULO
addLinha(cStrTxt,cLin,"02",nBase,@aReg10)	

//IMPOSTO CREDITADO
addLinha(cStrTxt,cLin,"03",nImposto,@aReg10)	

//IMPOSTO SEM APROV. CREDITO
addLinha(cStrTxt,cLin,"04",nSemCred,@aReg10)	

//ISENTAS
addLinha(cStrTxt,cLin,"05",nIsentas,@aReg10)	

//NÃO TRIBUTADAS
addLinha(cStrTxt,cLin,"06",nNtribut,@aReg10)	

//PARC. BASE DE CÁLCULO REDUZIDA
addLinha(cStrTxt,cLin,"07",nBaseNT,@aReg10)	

//DIFERIMENTO
addLinha(cStrTxt,cLin,"08",nDiferid,@aReg10)	

//SUSPENSA
addLinha(cStrTxt,cLin,"09",nSuspens,@aReg10)	

//ICMS ST
addLinha(cStrTxt,cLin,"10",nICMSST,@aReg10)	

//OUTRAS
addLinha(cStrTxt,cLin,"11",nOutras,@aReg10)		

Return Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} operSaida

Função para buscar valores referente os documentos fiscais de saída.

@Param 	dIni ->	Data Inicial do período de processamento
		dFim ->	Data Final do período de processamento
		cCfop -> CFOP
		cStrTxt -> Chave da linha
		cLin 	-> Código da linha da DAPI
		aReg10 -> Array com as linhas do registro 10
		aSubTotal -> Subtotal das linhas
		lUsoCons -> Indica se é Uso e Consumo ou Não.

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function operSaida(dIni, dFim, cCfop, cStrTxt, cLin, aReg10,aSubTotal,lUsoCons) 
 Local aValCST    := {}
 Local nIsentas   := 0
 Local nNtribut   := 0
 Local nDiferid   := 0
 Local nSuspens   := 0
 Local nOutras    := 0
 Local nContabil  := 0
 Local nBase      := 0
 Local nImposto   := 0 
 Local nBaseNT    := 0
 Local nX         := 0
 Default lUsoCons := .F.
	
	aValCST := fnVlrOpera('000002', DToS(dIni), DToS(dFim), cCfop, lUsoCons)	

	For nX := 1 TO Len(aValCST)
		Do Case		   
		   Case aValCST[nX,1] == "000005"  
		      nIsentas := aValCST[nX,6]
		   Case aValCST[nX,1] == "000006" 
		      nNtribut := aValCST[nX,6]
		   Case aValCST[nX,1] == "000008" 
		      nDiferid := aValCST[nX,9]
		   Case aValCST[nX,1] == "000007" 
		      nSuspens := aValCST[nX,9]
		   Case aValCST[nX,1] == "000011" 
		      nOutras := aValCST[nX,9]		   
		EndCase 
		
		nContabil += aValCST[nX,2]
		nBase     += aValCST[nX,3]
		nImposto  += aValCST[nX,4]		
		nBaseNT   += aValCST[nX,8]
	Next
	
	aValCST	:= fnVlrOpera('000004', DToS(dIni), DToS(dFim), cCfop, lUsoCons)
	If(Len(aValCST) > 0)
		nICMSST := aValCST[1,4]
	EndIf
	
	//SUBTOTAL
	aSubTotal[1]   += nContabil   	// SUBTOTAL VL CONTABIL
	aSubTotal[2]   += nBase   		// SUBTOTAL BASE  
	aSubTotal[3]   += nImposto   	// SUBTOTAL CREDITO	
	aSubTotal[4]   += nIsentas     	// SUBTOTAL ISENTAS
	aSubTotal[5]   += nNtribut     	// SUBTOTAL NAO TRIBUTADAS
	aSubTotal[6]   += nBaseNT   	// SUBTOTAL BASE NT	
	aSubTotal[7]   += nDiferid     	// SUBTOTAL DIFERIMENTO
	aSubTotal[8]   += nSuspens     	// SUBTOTAL SUSPENSA
	aSubTotal[9]   += nICMSST		// SUBTOTAL ICMS ST
	aSubTotal[10]  += nOutras      	// SUBTOTAL OUTRAS	
	
	//VALOR CONTABIL
	addLinha(cStrTxt,cLin,"01",nContabil,@aReg10)	
	
	//BASE CÁLCULO
	addLinha(cStrTxt,cLin,"02",nBase,@aReg10)	
	
	//IMPOSTO DEBITADO
	addLinha(cStrTxt,cLin,"03",nImposto,@aReg10)	
	
	//ISENTAS
	addLinha(cStrTxt,cLin,"04",nIsentas,@aReg10)	
	
	//NÃO TRIBUTADAS
	addLinha(cStrTxt,cLin,"05",nNtribut,@aReg10)	
	
	//PARC. BASE DE CÁLCULO REDUZIDA
	addLinha(cStrTxt,cLin,"06",nBaseNT,@aReg10)	
	
	//DIFERIMENTO
	addLinha(cStrTxt,cLin,"07",nDiferid,@aReg10)	
	
	//SUSPENSA
	addLinha(cStrTxt,cLin,"08",nSuspens,@aReg10)	
	
	//ICMS ST
	addLinha(cStrTxt,cLin,"09",nICMSST,@aReg10)	
	
	//OUTRAS
	addLinha(cStrTxt,cLin,"10",nOutras,@aReg10)		
 
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fnVlrOpera

Função para buscar valores referente os documentos fiscais de saída e entrada
por CST

@Param 	cTributo -> Código do Tributo 
		cPerIni ->	Data Inicial do período de processamento
		cPerFim ->	Data Final do período de processamento
		cCfop -> CFOP		
		lUsoCons -> Indica se é Uso e Consumo ou Não.

@Return aValCST -> Array com os valores de ICMS/ICMSST por CST

@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function fnVlrOpera(cTributo, cPerIni, cPerFim, cCfop, lUsoCons, lExec, lFilNts, lGroup, cQry, cAliTmp )

Local cStrQuery   := ""
Local cAliasApur  := ""
Local aValCST     := {}
Local cSqlNat     := ""
Local cCampo      := ""
Local cGroupBy    := ""
Local aCursor     := {}
local lIcmsIpi 	  := .F.
local nlA         := 0
local aCFOP       := Separa( cCfop ,",")
Local lCfopDuplc  := .F.

Default lExec 	:= .T.
Default lFilNts := .F.
Default lGroup  := .T.
Default cAliTmp := ""

for nlA := 1 to Len( aCFOP )
	if Alltrim(aCFOP[nlA]) $ "'1653'|'2653'|'3653'"
		lCfopDuplc := .T.
		Exit
	endif
next nlA

lIcmsIpi := lFilNts .And. !lExec .And. cTributo == "000002"

if lCfopDuplc
	If(lUsoCons)
		cSqlNat := "AND C30.C30_FILIAL  = C1N.C1N_FILIAL "
		cSqlNat += "AND C30.C30_NATOPE  = C1N.C1N_ID "
		cSqlNat += "AND C1N.C1N_OBJOPE  = '01' "
	Else
		cSqlNat := "AND C30.C30_FILIAL  = C1N.C1N_FILIAL "
		cSqlNat += "AND C30.C30_NATOPE  = C1N.C1N_ID "
		cSqlNat += "AND C1N.C1N_OBJOPE  != '01' "
	EndIf
endif

if lGroup .And. (cTributo == "000002" .Or. cTributo == "000005")
	if lFilNts
		cGroupBy := " GROUP BY C20.C20_FILIAL, C20.C20_NUMDOC "
	else
		cCampo   := " C35.C35_CST CST, "
		cGroupBy := " GROUP BY  C35.C35_CST "
	endif
EndIf

cStrQuery += " SELECT " + cCampo
if lIcmsIpi
	cStrQuery += " DISTINCT C20.C20_FILIAL, C20.C20_NUMDOC, "
	cStrQuery += " SUM(C35_BASE) BASE, "
	cStrQuery += " SUM(C30_VLOPER) VCONT, "
	cStrQuery += " SUM(C35_VALOR) VIMPOS, "
	cStrQuery += " SUM(C35_VLSCRE) VSCRED, "
	cStrQuery += " SUM(C35_VLISEN) VISEN, "
	cStrQuery += " SUM(C35_VLNT) VNTRIB, "
	cStrQuery += " SUM(C35_BASENT) VBNTRI, "
	cStrQuery += " SUM(C35_VLOUTR) VOUTRO "
elseif (cTributo == "000005" )
	cStrQuery += " C20.C20_FILIAL, "
	cStrQuery += " C20.C20_NUMDOC, "
	cStrQuery += " SUM(TMP.VCONT) VCONT, "
	cStrQuery += " SUM(TMP.BASE) BASE, "
	cStrQuery += " CASE WHEN (SUM(TMP.VCONT) > (SUM(TMP.BASE) + SUM(TMP.VISEN) + SUM(TMP.VNTRIB) + SUM(TMP.VBNTRI) + SUM(TMP.VOUTRO))) THEN SUM(C35.C35_VALOR) ELSE 0 END VIMPOS "
else
	cStrQuery += " SUM(C35_BASE) BASE, "
	cStrQuery += " SUM(C30_VLOPER) VCONT, "
	cStrQuery += " SUM(C35_VALOR) VIMPOS, "
	cStrQuery += " SUM(C35_VLSCRE) VSCRED, "
	cStrQuery += " SUM(C35_VLISEN) VISEN, "
	cStrQuery += " SUM(C35_VLNT) VNTRIB, "
	cStrQuery += " SUM(C35_BASENT) VBNTRI, "
	cStrQuery += " SUM(C35_VLOUTR) VOUTRO "
endif

cStrQuery += " FROM " + RetSqlName('C35') + " C35, "
cStrQuery += RetSqlName('C30') + " C30, "
cStrQuery += RetSqlName('C20') + " C20, "
cStrQuery += RetSqlName('C02') + " C02, "
cStrQuery += RetSqlName('C0Y') + " C0Y "

if !Empty( cAliTmp )
	cStrQuery += "," + cAliTmp + " TMP "
endif

if lCfopDuplc
	cStrQuery += "," + RetSqlName('C1N') + " C1N "
endif

cStrQuery += " WHERE C35.C35_FILIAL = '" + cFilDapi + "' "
cStrQuery += " AND C35.C35_CHVNF  = C20.C20_CHVNF "
cStrQuery += " AND C35.C35_FILIAL = C20.C20_FILIAL "
cStrQuery += " AND C35.C35_FILIAL = C30.C30_FILIAL "
cStrQuery += " AND C35.C35_CHVNF  = C30.C30_CHVNF "
cStrQuery += " AND C35.C35_NUMITE = C30.C30_NUMITE "
cStrQuery += " AND C35.C35_CODITE = C30.C30_CODITE "
cStrQuery += " AND C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' "
cStrQuery += " AND C30.C30_CFOP   = C0Y.C0Y_ID "
cStrQuery += " AND C35.C35_CODTRI = '" + cTributo + "'"

if !Empty( cAliTmp )
	cStrQuery += " AND C20.C20_FILIAL = TMP.FILIAL "
	cStrQuery += " AND C20.C20_NUMDOC = TMP.NUMDOC "
endif

cStrQuery += " AND C20.C20_DTES  BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'" 
cStrQuery += " AND C20.C20_CODSIT = C02.C02_ID "
cStrQuery += " AND C02.C02_FILIAL = '" + xFilial("C02") + "' "  
cStrQuery += " AND C02.C02_CODIGO NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA
cStrQuery += " AND C0Y.C0Y_CODIGO IN ("+ cCfop+ ") "
cStrQuery += cSqlNat
cStrQuery += " AND C35.D_E_L_E_T_ = ' ' "
cStrQuery += " AND C30.D_E_L_E_T_ = ' ' "
cStrQuery += " AND C20.D_E_L_E_T_ = ' ' "
cStrQuery += " AND C02.D_E_L_E_T_ = ' ' "
cStrQuery += " AND C0Y.D_E_L_E_T_ = ' ' "

if lCfopDuplc
	cStrQuery += " AND C1N.D_E_L_E_T_ = ' ' "
endif

cStrQuery += cGroupBy

cStrQuery := ChangeQuery(cStrQuery)

if lExec
	cAliasApur := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasApur,.T.,.T.)
	DbSelectArea(cAliasApur)
	(cAliasApur)->(dbGoTop())
	While (cAliasApur)->(!Eof()) 
		aCursor := {}
		If(cTributo == "000002")
			aAdd(aCursor, (cAliasApur)->CST) //1
		ElseIf(cTributo == "000005")
			aAdd(aCursor, 'IPI')
		Else
			aAdd(aCursor, "ICMSST")
		EndIf
		aAdd(aCursor, (cAliasApur)->VCONT)  //2
		aAdd(aCursor, (cAliasApur)->BASE)   //3
		aAdd(aCursor, (cAliasApur)->VIMPOS) //4
		if cTributo != "000005"
			aAdd(aCursor, (cAliasApur)->VSCRED)
			aAdd(aCursor, (cAliasApur)->VISEN)
			aAdd(aCursor, (cAliasApur)->VNTRIB)
			aAdd(aCursor, (cAliasApur)->VBNTRI)
			aAdd(aCursor, (cAliasApur)->VOUTRO)
		endif
		aAdd(aValCST, aCursor)  	
		(cAliasApur)->(DbSkip())
	EndDo
	(cAliasApur)->(DbCloseArea())
else
	cQry := cStrQuery
endif

Return aValCST

//-------------------------------------------------------------------
/*/{Protheus.doc} DapiAprSQL

DapiAprSQL() - SQL Principal para busca de informações nos registros da DAPI

@Author Rafael Völtz
@Since 10/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function DapiAprSQL(cFil, cUFID, cPerIni, cPerFim, cSubitem, cTipOpe, cTrib)
  Local cStrQuery := ""
  Local cAliasApur  := GetNextAlias()
  Local aNFs        := {}
  Local aDetalha    := {}
  
  If AllTrim(cTrib) == "ICMS"
	  cStrQuery := " SELECT C2V.C2V_NRODOC NUM_DOC,"
	  cStrQuery += "        C2V.C2V_SERDOC SER_DOC,"
	  cStrQuery += "        C2V.C2V_DTDOC  DT_DOC,"
	  cStrQuery += "        C2V.C2V_DTVIST DT_VISTO,"
	  cStrQuery += "        SUM(C2V.C2V_VLRAJU) VALOR,"
	  cStrQuery += "        T0V.T0V_CODIGO MOTIVO,"
	  cStrQuery += "        C1H.C1H_IE     IE,"
	  cStrQuery += "        C1H.C1H_RAMO   RAMO_ATIV,"
	  cStrQuery += "        C09.C09_UF     UF, "
	  
	  If cSubItem == "00090"  //Estorno de Débito
	  	cStrQuery += "        C2T.R_E_C_N_O_ RECORD, "
	  EndIf
	  
	  cStrQuery += "        'C2T' TABELA "
	  cStrQuery +=   " FROM " + RetSqlName('C2S') + " C2S, "
	  cStrQuery +=              RetSqlName('C2T') + " C2T, "
	  cStrQuery +=              RetSqlName('C2V') + " C2V, "  
	  cStrQuery +=              RetSqlName('C1H') + " C1H, "
	  cStrQuery +=              RetSqlName('T0V') + " T0V, "
	  cStrQuery +=              RetSqlName('CHY') + " CHY, "
	  cStrQuery +=              RetSqlName('C09') + " C09  "
	  cStrQuery += "  WHERE C2S.C2S_FILIAL                = '" + cFil + "' "  
	  cStrQuery +=   "  AND C2S.C2S_TIPAPU = '0'"
	  cStrQuery +=   "  AND C2S.C2S_DTINI  BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"	  
	  cStrQuery +=   "  AND C2S.C2S_INDAPU = ' '"
	  cStrQuery +=   "  AND C2S.C2S_FILIAL = C2T.C2T_FILIAL "
	  cStrQuery +=   "  AND C2S.C2S_ID     = C2T.C2T_ID "
	  cStrQuery +=   "  AND C2T.C2T_FILIAL = C2V.C2V_FILIAL "
	  cStrQuery +=   "  AND C2T.C2T_ID     = C2V.C2V_ID "
	  cStrQuery +=   "  AND C2T.C2T_CODAJU = C2V.C2V_CODAJU "
	  cStrQuery +=   "  AND C2T.C2T_IDSUBI = CHY.CHY_ID "
	  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "  
	  cStrQuery +=   "  AND T0V.T0V_FILIAL = '" + xFilial("T0V") + "' "  
	  cStrQuery +=   "  AND C2T.C2T_IDTMOT = T0V.T0V_ID "	  	  
	  cStrQuery +=   "  AND C2V.C2V_FILIAL = C1H.C1H_FILIAL "
	  cStrQuery +=   "  AND C2V.C2V_CODPAR = C1H.C1H_ID "
	  cStrQuery +=   "  AND C1H.C1H_UF     = C09.C09_ID "
	  cStrQuery +=   "  AND C09.C09_FILIAL = '" + xFilial("C09") + "' "  
	  cStrQuery +=   "  AND CHY.CHY_IDUF   =  '" + cUFID + "'"
	  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"
	  cStrQuery +=   "  AND CHY.CHY_OPERAC = '0'"
	  If(cSubitem == "00066")
	  		cStrQuery +=   "  AND T0V.T0V_CODIGO NOT IN ('00008','00009','00031','00032','00052','00053', '00061') "
	  EndIf
	  cStrQuery +=   "  AND C2S.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C2T.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C2V.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C1H.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND T0V.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C09.D_E_L_E_T_ = ' ' "
	  cStrQuery += " GROUP BY C2V.C2V_NRODOC, "
        cStrQuery +=          " C2V.C2V_SERDOC, "
        cStrQuery +=          " C2V.C2V_DTDOC,  "
        cStrQuery +=          " C2V.C2V_DTVIST, "      
        cStrQuery +=          " T0V.T0V_CODIGO, "
        cStrQuery +=          " C1H.C1H_IE,     "
        cStrQuery +=          " C1H.C1H_RAMO,   "
        cStrQuery +=          " C09.C09_UF      "
	  
	  If cSubItem == "00090" //Estorno de Débito
	  	cStrQuery += 		", C2T.R_E_C_N_O_  "
	  EndIf
	
	  cStrQuery +=   "  UNION ALL"
	
	  cStrQuery += " SELECT C20.C20_NUMDOC NUM_DOC,"
	  cStrQuery += "        C20.C20_SERIE  SER_DOC,"
	  cStrQuery += "        C20.C20_DTES  DTDOC,"
	  cStrQuery += "        C2D.C2D_DTVIST DT_VISTO,"
	  cStrQuery += "        SUM(C2D.C2D_VLICM) VALOR,"
	  cStrQuery += "        T0V.T0V_CODIGO MOTIVO,"
	  cStrQuery += "        C1H.C1H_IE     IE,"
	  cStrQuery += "        C1H.C1H_RAMO   RAMO_ATIV,"
	  cStrQuery += "        C09.C09_UF     UF,  "	  
	  
	  If cSubItem == "00090" //Estorno de Débito
	  	cStrQuery += "        C2D.R_E_C_N_O_ RECORD,  "
	  EndIf
	  
	  cStrQuery += "        'C2D' TABELA "
	  cStrQuery +=   " FROM " + RetSqlName('C20') + " C20, "
	  cStrQuery +=              RetSqlName('C2D') + " C2D, "
	  cStrQuery +=              RetSqlName('C02') + " C02, "
	  cStrQuery +=              RetSqlName('C1H') + " C1H, "  
	  cStrQuery +=              RetSqlName('T0V') + " T0V, "
	  cStrQuery +=              RetSqlName('CHY') + " CHY, "
	  cStrQuery +=              RetSqlName('C09') + " C09  "
	  cStrQuery += "  WHERE C20.C20_FILIAL                = '" + cFil + "' "  
	  cStrQuery +=   "  AND C20.C20_DTES BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"  
	  cStrQuery +=   "  AND C20.C20_FILIAL = C2D.C2D_FILIAL "
	  cStrQuery +=   "  AND C20.C20_CHVNF  = C2D.C2D_CHVNF "
	  cStrQuery +=   "  AND C20.C20_INDOPE = '"+ cTipOpe + "'"
	  cStrQuery +=   "  AND C20.C20_CODSIT =  C02.C02_ID "        
	  cStrQuery +=   "  AND C02.C02_FILIAL =  '" + xFilial("C02") + "' "  
	  cStrQuery +=   "  AND C02.C02_CODIGO  NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA
	  cStrQuery +=   "  AND C20.C20_FILIAL = C1H.C1H_FILIAL "
	  cStrQuery +=   "  AND C20.C20_CODPAR = C1H.C1H_ID "
	  cStrQuery +=   "  AND C1H.C1H_UF     = C09.C09_ID "
	  cStrQuery +=   "  AND C09.C09_FILIAL = '" + xFilial("C09") + "' "  	  
	  cStrQuery +=   "  AND C2D.C2D_IDTMOT = T0V.T0V_ID "
	  cStrQuery +=   "  AND T0V.T0V_FILIAL = '" + xFilial("T0V") + "' "  	  
	  cStrQuery +=   "  AND C2D.C2D_IDSUBI = CHY.CHY_ID "
	  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "
	  cStrQuery +=   "  AND CHY.CHY_IDUF   = '" + cUFID + "'"
	  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"
	  cStrQuery +=   "  AND CHY.CHY_OPERAC = '0'"
	  
	  If(cSubitem == "00066")
	  		cStrQuery +=   "  AND T0V.T0V_CODIGO NOT IN ('00008','00009','00031','00032','00052','00053', '00061') "
	  EndIf
	  
	  cStrQuery +=   "  AND C20.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C2D.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C02.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C1H.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND T0V.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C09.D_E_L_E_T_ = ' '"
	  cStrQuery += " GROUP BY C20.C20_NUMDOC, "
      cStrQuery +=          " C20.C20_SERIE, "
      cStrQuery +=          " C20.C20_DTES, "
      cStrQuery +=          " C2D.C2D_DTVIST,"         
      cStrQuery +=          " T0V.T0V_CODIGO,"
      cStrQuery +=          " C1H.C1H_IE, "
      cStrQuery +=          " C1H.C1H_RAMO, "
      cStrQuery +=          " C09.C09_UF "
	  
	  If cSubItem == "00090" //Estorno de Débito
	  		cStrQuery += ", C2D.R_E_C_N_O_  "
	  EndIf
  Else
     
     cStrQuery := " SELECT C3M.C3M_NRODOC NUM_DOC,"
	  cStrQuery += "        C3M.C3M_SERDOC SER_DOC,"
	  cStrQuery += "        C3M.C3M_DTDOC  DT_DOC,"
	  cStrQuery += "        C3M.C3M_DTVIST DT_VISTO,"
	  cStrQuery += "        C3M.C3M_VLRAJU VALOR,"
	  cStrQuery += "        T0V.T0V_CODIGO MOTIVO, "	  
	  cStrQuery += "        C1H.C1H_IE IE"
	  cStrQuery +=   " FROM " + RetSqlName('C3J') + " C3J, "
	  cStrQuery +=              RetSqlName('C3K') + " C3K, "
	  cStrQuery +=              RetSqlName('C3M') + " C3M, "  
	  cStrQuery +=              RetSqlName('CHY') + " CHY, "
	  cStrQuery +=              RetSqlName('T0V') + " T0V, "	  
	  cStrQuery +=              RetSqlName('C1H') + " C1H "
	  cStrQuery += "  WHERE C3J.C3J_FILIAL                = '" + cFil + "' "  
	  cStrQuery +=   "  AND C3J.C3J_DTINI  BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"
	  cStrQuery +=   "  AND C3J.C3J_INDMOV = '1'"	  
	  cStrQuery +=   "  AND C3J.C3J_FILIAL = C3K.C3K_FILIAL "
	  cStrQuery +=   "  AND C3J.C3J_ID     = C3K.C3K_ID "
	  cStrQuery +=   "  AND C3K.C3K_FILIAL = C3M.C3M_FILIAL "
	  cStrQuery +=   "  AND C3K.C3K_ID     = C3M.C3M_ID "
	  cStrQuery +=   "  AND C3K.C3K_CODAJU = C3M.C3M_CODAJU "
	  cStrQuery +=   "  AND C3K.C3K_IDSUBI = CHY.CHY_ID "
	  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "
	  cStrQuery +=   "  AND T0V.T0V_FILIAL = '" + xFilial("T0V") + "' "
	  cStrQuery +=   "  AND T0V.T0V_ID     = C3K.C3K_IDTMOT "	  
	  cStrQuery +=   "  AND C3M.C3M_FILIAL = C1H.C1H_FILIAL "
	  cStrQuery +=   "  AND C3M.C3M_CODPAR = C1H.C1H_ID "
	  cStrQuery +=   "  AND CHY.CHY_IDUF   =  '" + cUFID + "'"
	  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"
	  cStrQuery +=   "  AND CHY.CHY_OPERAC = '1'"	  
	  cStrQuery +=   "  AND C3J.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C3K.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C3M.D_E_L_E_T_ = ' '"	  
	  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"	  
	  cStrQuery +=   "  AND T0V.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C1H.D_E_L_E_T_ = ' '"
	  
	  cStrQuery +=   "  UNION ALL"
	
	  cStrQuery += " SELECT C20.C20_NUMDOC NUM_DOC,"
	  cStrQuery += "        C20.C20_SERIE  SER_DOC,"
	  cStrQuery += "        C20.C20_DTES  DTDOC,"
	  cStrQuery += "        C2D.C2D_DTVIST DT_VISTO,"
	  cStrQuery += "        C2D.C2D_VLICM  VALOR,"
	  cStrQuery += "        T0V.T0V_CODIGO MOTIVO,"	  
	  cStrQuery += "        C1H.C1H_IE IE"	  	  
	  cStrQuery +=   " FROM " + RetSqlName('C20') + " C20, "
	  cStrQuery +=              RetSqlName('C2D') + " C2D, "	    
	  cStrQuery +=              RetSqlName('C02') + " C02, "
	  cStrQuery +=              RetSqlName('T0V') + " T0V, "
	  cStrQuery +=              RetSqlName('CHY') + " CHY, "	  
	  cStrQuery +=              RetSqlName('C1H') + " C1H "
	  cStrQuery += "  WHERE C20.C20_FILIAL                = '" + cFil + "' "  
	  cStrQuery +=   "  AND C20.C20_DTES BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"    
	  cStrQuery +=   "  AND C20.C20_FILIAL = C2D.C2D_FILIAL "
	  cStrQuery +=   "  AND C20.C20_CHVNF  = C2D.C2D_CHVNF "
	  cStrQuery +=   "  AND C20.C20_INDOPE = '"+ cTipOpe + "'"
	  cStrQuery +=   "  AND C20.C20_CODSIT =  C02.C02_ID "        
	  cStrQuery +=   "  AND C02.C02_FILIAL =  '" + xFilial("C02") + "' "  
	  cStrQuery +=   "  AND C02.C02_CODIGO  NOT IN ('02','04','05')" //CANCELADA, INUTILIZADA E DENEGADA	  	  
	  cStrQuery +=   "  AND C2D.C2D_IDTMOT = T0V.T0V_ID "
	  cStrQuery +=   "  AND T0V.T0V_FILIAL = '" + xFilial("T0V") + "' "
	  cStrQuery +=   "  AND C20.C20_FILIAL = C1H.C1H_FILIAL "
	  cStrQuery +=   "  AND C20.C20_CODPAR = C1H.C1H_ID "	  
	  cStrQuery +=   "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "
	  cStrQuery +=   "  AND CHY.CHY_ID     = C2D.C2D_IDSUBI  "
	  cStrQuery +=   "  AND CHY.CHY_IDUF   = '" + cUFID + "'"
	  cStrQuery +=   "  AND CHY.CHY_CODIGO = '" + cSubItem + "'"
	  cStrQuery +=   "  AND CHY.CHY_OPERAC = '1'"
	  cStrQuery +=   "  AND C20.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND C2D.D_E_L_E_T_ = ' '"	  
	  cStrQuery +=   "  AND C02.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND T0V.D_E_L_E_T_ = ' '"
	  cStrQuery +=   "  AND CHY.D_E_L_E_T_ = ' '"	 
	  cStrQuery +=   "  AND C1H.D_E_L_E_T_ = ' '" 
  EndIf
  
  cStrQuery := ChangeQuery(cStrQuery)
  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAliasApur,.T.,.T.)
  DbSelectArea(cAliasApur)
  dbGoTop()
  
  While (cAliasApur)->(!Eof()) 
	aNFs := {}
	aAdd(aNFs, (cAliasApur)->NUM_DOC)
	aAdd(aNFs, (cAliasApur)->SER_DOC)
	aAdd(aNFs, (cAliasApur)->DT_DOC)
	aAdd(aNFs, (cAliasApur)->DT_VISTO)
	aAdd(aNFs, (cAliasApur)->VALOR)
	aAdd(aNFs, (cAliasApur)->MOTIVO)
	aAdd(aNFs, (cAliasApur)->IE)
	
	If AllTrim(cTrib) == "ICMS"
		aAdd(aNFs, (cAliasApur)->RAMO_ATIV)
		aAdd(aNFS, (cAliasApur)->UF)
		If cSubItem == "00090" //Estorno de Débito
			aAdd(aNFS, (cAliasApur)->RECORD)
		Else
			aAdd(aNFS, 0)
		EndIf
		aAdd(aNFS, (cAliasApur)->TABELA)
	EndIf
      
	aAdd(aDetalha, aNFS)  	   
  	   
	(cAliasApur)->(DbSkip())  
  EndDo
  
  DbCloseArea()

Return aDetalha  

//---------------------------------------------------------------------
/*/{Protheus.doc} addLinha

Função para adicionar linhas no array do registro 10

@Param 	cStrTxt -> Chave da linha 
		cLin -> Código da linha na DAPI.
		cCol -> Código da coluna na DAPI.
		nValor -> Valor da linha/coluna		
		aReg10 -> Array com as linhas do registro 10
		
@Author Rafael Völtz
@Since 29/06/2016
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function addLinha(cStrTxt,cLin,cCol,nValor,aReg10)
   Local cLinha := ""
   
   IF(nValor > 0) .and. !(dtCorte >= CTOD('01/09/2016') .and. (cCol == '04' .and. cLin <="043")) 
	 	cLinha  := cStrTxt
		cLinha  += cLin                                                                   //Identificação da Linha            
		cLinha  += cCol                                                                   //Identificação da coluna
		cLinha  += StrTran(StrZero(nValor, 16, 2),".","")                                 //Valor Declarado
		cLinha  += CRLF
		aAdd(aReg10, cLinha)	
	EndIf

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDapiTot

Retorna o valor de nTotRec. Função chamada no fonte TAFDAPI37.
		
@Author Leandro Dourado
@Since 15/07/2019
@Version 1.0
/*/
//---------------------------------------------------------------------
Function GetDapiTot()
Return nTotRec

//---------------------------------------------------------------------
/*/{Protheus.doc} TTableDapi

Tabela Temporaria Dapi
		
@Author Denis Souza
@Since 11/10/2022
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function TTableDapi(oTTable, cAliTmp)

Local aStruct := {}

Default oTTable := Nil
Default cAliTmp := ""

Aadd( aStruct,{"FILIAL", "C", _nTmFil 	 , 0 		  } )
Aadd( aStruct,{"NUMDOC", "C", _nTmNDoc	 , 0 		  } )
Aadd( aStruct,{"BASE"  , "N", _nTmBs	 , _nDcBs 	  } )
Aadd( aStruct,{"VCONT" , "N", _nTmVOper	 , _nDcVOper  } )
Aadd( aStruct,{"VIMPOS", "N", _nTmImpo	 , _nDcImpo	  } )
Aadd( aStruct,{"VSCRED", "N", _nTmVsCred , _nDcVsCred } )
Aadd( aStruct,{"VISEN" , "N", _nTmVIsen	 , _nDcVIsen  } )
Aadd( aStruct,{"VNTRIB", "N", _nTmVNTrib , _nDcVNTrib } )
Aadd( aStruct,{"VBNTRI", "N", _nTmBsNTri , _nDcBsNTri } )
Aadd( aStruct,{"VOUTRO", "N", _nTmBsVOut , _nDcBsVOut } )

oTTable := FWTemporaryTable():New("TABNTS")
oTTable:SetFields(aStruct)
oTTable:AddIndex( "I1", {"FILIAL", "NUMDOC"} )
oTTable:Create()

cAliTmp := oTTable:GetRealName()

Return NIl

//---------------------------------------------------------------------
/*/{Protheus.doc} TTableDapi

Apaga a tabela temporaria apos utilizacao.
		
@Author Denis Souza
@Since 11/10/2022
@Version 1.0
/*/
//---------------------------------------------------------------------
Static Function DelTmpDapi( oTTable )

Default oTTable := Nil

If oTTable <> Nil
	oTTable:Delete()
	oTTable := Nil
EndIf

Return Nil
