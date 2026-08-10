#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
	 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA088

Estimar Fretes: 
Realiza cálculos do tipo "Estimativa" para documentos de carga que não tenham
cálculos do tipo normal relacionados.

Uso Generico.

@sample
GFEA088()

@author Alan Victor Lamb
@since 16/12/2013
@version 1.0
--------------------------------------------------------------------------------------------------/*/

Function GFEA088()
	Private cFilDe
	Private cFilAte
	Private dEmisDe
	Private dEmisAte
	Private cNumDCDe
	Private cNumDCAte
	Private cTranspDe
	Private cTranspAte
	Private nTabFrt
	Private nRecal
	Private nMemCal
	Private GFEResult := GFEViewProc():New()
	
	If !IsBlind()
		SugereData()
	EndIf
	
	If !IsBlind()
		If VldPergunte()
			Processa({|| ProcessaDoctos()},"Calculando...", "")
			GFEResult:Show("Estimativa de Cálculos de Frete para Provisão", "Documentos calculados", "Erros", "Um ou mais Documentos não foram calculados, clique no botão 'Erros' para mais detalhes.")
		EndIf
	Else
		Pergunte("GFEA088", .F.)
		
		GFEResult:EnableLog("calculo_estimativas","Cálculo de estimativa")
		GFEResult:Add("Parâmetros")
		
		BatchProcess("GFEA088","GFEA088",,{ || ProcessaDoctos(.T.) })
		
		GFEResult:GFELOG:Save()
		GFEResult:GFELOG:EndLog()
	EndIf
	
Return Nil

/*/{Protheus.doc} VldPergunte
Validação dos parametros informados no pergunte:
- Deve ser informada a faixa de data de emissão dos documentos de carga
- Não pode informar 'Data de Emissão de' maior do que 'Data de Emissão até'
- Não pode informar datas de emissão de meses diferentes
	
@author Alan Victor Lamb
@since 30/12/2013
@version 1.0		

@return lRet
/*/
Static Function VldPergunte()
	Local nMesDe, nAnoDe, nMesAte, nAnoAte
		
	If !Pergunte("GFEA088", .T.)
		Return
	EndIf
		
	cFilDe		:= MV_PAR01
	cFilAte		:= MV_PAR02
	dEmisDe		:= MV_PAR03
	dEmisAte	:= MV_PAR04
	cNumDcDe	:= MV_PAR05
	cNumDcAte	:= MV_PAR06
	cTranspDe	:= MV_PAR07
	cTranspAte	:= MV_PAR08
	nTabFrt		:= MV_PAR09
	nRecal		:= MV_PAR10
	nMemCal		:= MV_PAR11
	
	If Empty(dEmisDe) .Or. Empty(dEmisAte)
		MsgStop("Informe a faixa de data de emissão dos documentos de carga.", "Atenção")
		Return .F.
	EndIf
		
	If dEmisDe > dEmisAte
		MsgStop("A 'Data Emissão de' deve ser menor do que a 'Data Emissão até'.", "Atenção")
		Return .F.
	EndIf
		
	nMesDe 	:= MONTH(dEmisDe)
	nAnoDe 	:= YEAR(dEmisDe)
	nMesAte := MONTH(dEmisAte)
	nAnoAte := YEAR(dEmisAte)
		
	If nMesDe != nMesAte .Or. nAnoDe != nAnoAte
		MsgStop("Não é permitido informar datas de emissão de meses diferentes.", "Atenção")
		Return .F.
	EndIf
		
	If Empty(GetMv("MV_TABPRO")) .and. nTabFrt == 2
		MsgInfo("Por favor adicionar uma Tabela de Estimativa nos Parâmetros do Módulo, aba Contabilização. ", "Atenção")
		Return .F.
	EndIf
	
Return .T.

Function GFEA088ATE()
	Local dDtDe  := MV_PAR03
	Local dDtAte := MV_PAR04
	
	If !Empty(dDtDe)
		Return VldDatas(dDtDe, dDtAte)
	EndIf	
Return .F.

Static Function VldDatas(dDtDe, dDtAte)
	Local nMesDe, nAnoDe, nMesAte, nAnoAte
	
	If dDtDe > dDtAte
		MsgStop("A 'Data Emissão de' deve ser menor do que a 'Data Emissão até'.", "Atenção")
		Return .F.
	EndIf
	
	nMesDe 	:= MONTH(dDtDe)
	nAnoDe 	:= YEAR(dDtDe)
	nMesAte := MONTH(dDtAte)
	nAnoAte := YEAR(dDtAte)
	
	If nMesDe != nMesAte .Or. nAnoDe != nAnoAte
		MsgStop("Não é permitido informar datas de emissão de meses diferentes.", "Atenção")
		Return .F.
	EndIf
	
Return .T.

Static Function SchedDef()

       // aReturn[1] - Tipo

       // aReturn[2] - Pergunte

       // aReturn[3] - Alias

       // aReturn[4] - Array de ordem

       // aReturn[5] - Titulo

Return { "P", "GFEA088", "", {}, "" }

/*/{Protheus.doc} ProcessaDoctos
Realiza processamento do cálculo de estimativa.

Uso exclusivo.
	
@author Alan Victor Lamb
@since 30/12/2013
@version 1.0		

@return 
/*/
Static Function ProcessaDoctos(lLoadParam)
	Local nTotal
	Local nQtdeCalc
	Local nQtdeNCalc
	Local cQuery := ""
	Local nAtual := 0
	Local lRet   := .T.
	Local cTmp	 := GetNextAlias()

	Default lLoadParam := .F.

	If lLoadParam
		cFilDe		:= MV_PAR01
		cFilAte		:= MV_PAR02
		dEmisDe		:= MV_PAR03
		dEmisAte	:= MV_PAR04
		nTabFrt		:= MV_PAR05
		nRecal		:= MV_PAR06
		nMemCal		:= MV_PAR07
	EndIf
	
	cQuery += "SELECT GW1.GW1_FILIAL"
	cQuery += "	   	, GW1.GW1_CDTPDC"
	cQuery += "	    , GW1.GW1_EMISDC"
	cQuery += "	    , GW1.GW1_SERDC"
	cQuery += "  	, GW1.GW1_NRDC"
	cQuery += "     , COUNT(CASE WHEN GWF.GWF_TPCALC = '1' THEN 1 END) QTD_CALC_NORMAL"
	cQuery += "     , COUNT(CASE WHEN GWF.GWF_TPCALC = '8' THEN 1 END) QTD_CALC_EST"
	cQuery += "  FROM " + RetSQLName("GW1") + " GW1"
	cQuery += "	INNER JOIN " + RetSQLName("GWU") + " GWU"
	cQuery += "	   ON GWU.GWU_FILIAL = GW1.GW1_FILIAL"
	cQuery += "   AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "   AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += "   AND GWU.GWU_SERDC  = GW1.GW1_SERDC"
	cQuery += "   AND GWU.GWU_NRDC = GW1.GW1_NRDC"
	cQuery += "   AND GWU.GWU_PAGAR = '1'"
	cQuery += "	  AND GWU.GWU_CDTRP >= '"+cTranspDe+"'"
	cQuery += "	  AND GWU.GWU_CDTRP <= '"+cTranspAte+"'"
	cQuery += "   AND GWU.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GWH") + " GWH"
	cQuery += "    ON GWH.GWH_FILIAL = GW1.GW1_FILIAL"
	cQuery += "   AND GWH.GWH_CDTPDC = GW1.GW1_CDTPDC"
	cQuery += "   AND GWH.GWH_EMISDC = GW1.GW1_EMISDC"
	cQuery += "   AND GWH.GWH_SERDC = GW1.GW1_SERDC"
	cQuery += "   AND GWH.GWH_NRDC = GW1.GW1_NRDC"
	cQuery += "   AND GWH.D_E_L_E_T_ = ''"
	cQuery += "  LEFT JOIN " + RetSQLName("GWF") + " GWF"
	cQuery += "    ON GWF.GWF_FILIAL = GWH.GWH_FILIAL"
	cQuery += "   AND GWF.GWF_NRCALC = GWH.GWH_NRCALC"
	cQuery += "   AND GWF.D_E_L_E_T_ = ' '"
	cQuery += " WHERE GW1.D_E_L_E_T_ = ''"
	cQuery += "   AND GW1.GW1_FILIAL >= '"+cFilDe+"'"
	cQuery += "   AND GW1.GW1_FILIAL <= '"+cFilAte+"'"
	cQuery += "   AND GW1.GW1_DTEMIS >= '"+DtoS(dEmisDe)+"'"
	cQuery += "   AND GW1.GW1_DTEMIS <= '"+DtoS(dEmisAte)+"'"
	cQuery += "	  AND GW1.GW1_NRDC >= '"+cNumDcDe+"'"
	cQuery += "	  AND GW1.GW1_NRDC <= '"+cNumDcAte+"'"
	cQuery += "   AND GW1.GW1_SIT NOT IN ('2','7','8')"
	cQuery += " GROUP BY GW1.GW1_FILIAL"
	cQuery += "	    , GW1.GW1_CDTPDC"
	cQuery += "	    , GW1.GW1_EMISDC"
	cQuery += "	    , GW1.GW1_SERDC"
	cQuery += "     , GW1.GW1_NRDC"

	If TCGETDB() = 'OPENEDGE'
		cQuery += " HAVING QTD_CALC_NORMAL = 0 "
	Else
		cQuery += " HAVING COUNT(CASE WHEN GWF.GWF_TPCALC = '1' THEN 1 END) = 0 "
	EndIf

	//
	// Desconsidera documentos que já tenham cálculo de estimativa gerado (param recálculo = não)
	//
	If nRecal == 2
		If TCGETDB() = 'OPENEDGE'
			cQuery += "    AND QTD_CALC_EST = 0 "
		Else
			cQuery += "    AND COUNT(CASE WHEN GWF.GWF_TPCALC = '8' THEN 1 END) = 0 "
		EndIf
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTmp, .F., .T.)

	dbSelectArea( (cTmp) )
	(cTmp)->( dbGoTop() )
	
	If (cTmp)->( Eof() )
		GFEResult:SetWarningIcon()
		GFEResult:Add("Nenhum documento encontrado para a faixa informada")

		lRet := .F.
	EndIf

	If lRet
		GFEResult:Add("Cálculo de estimativa")
		GFEResult:Add("")
		GFEResult:Add(Replicate("-", 72))
		GFEResult:Add(MontaLinha("Tipo","Emissor","Série","Número","Estimativa"))
		GFEResult:Add(Replicate("-", 72))
		
		nTotal		:= 0
		nQtdeCalc 	:= 0
		nQtdeNCalc	:= 0
		
		While !(cTmp)->( Eof() )
			nTotal++
			(cTmp)->( dbSkip() )
		EndDo
		
		If !IsBlind()
			ProcRegua(nTotal)
		EndIf
		
		nAtual := 1
		
		(cTmp)->( dbGoTop() )
		
		While !(cTmp)->( Eof() )
			If !IsBlind()
				IncProc("Documento " + AllTrim(Str(nAtual)) + " de " + AllTrim(Str(nTotal)) + "...")
			EndIf
			
			// Tabela de provisão utilizada (Transportador ou Estimativa (parametros do gfe))
			nTabProv := If(nTabFrt == 1, 2, 1)
				
			A088CLCEST((cTmp)->GW1_FILIAL, (cTmp)->GW1_CDTPDC, (cTmp)->GW1_EMISDC, (cTmp)->GW1_SERDC, (cTmp)->GW1_NRDC, nTabProv, nMemCal == 1, GFEResult, @nQtdeNCalc, @nQtdeCalc)
			
			nAtual++
			(cTmp)->( dbSkip() )
		EndDo
		
		GFEResult:Add("")
		GFEResult:Add(Replicate("-", 72))
		GFEResult:Add("Documentos considerados: " 	+ AllTrim(Str(nTotal)))
		GFEResult:Add("Estimativa realizada com sucesso: " 	+ AllTrim(Str(nQtdeCalc)))
		GFEResult:Add("Estimativa não realizada: " 			+ AllTrim(Str(nQtdeNCalc)))
	EndIf
	
	(cTmp)->(dbCloseArea())
	GFEDElTab(cTmp)
Return 

/*/{Protheus.doc} MontaLinha
Monta uma linha com informações do documento de carga para o log de processamento
Uso Exclusivo.

@author Alan Victor Lamb
@since 30/12/2013
@version 1.0
		
@param cTipo, character, Tipo do Documento
@param cEmissor, character, Emissor
@param cSerie, character, Série
@param cNumero, character, Número
@param cEstimativa, character, Valor do cálculo de Estimativa

@return cRet

@example
MontaLinha("NFS", "100", "1", "123", "R$ 100,00")
/*/
Static Function MontaLinha(cTipo, cEmissor, cSerie, cNumero, cEstimativa )
	Local cRet
	
	cSerie := Transform(cSerie, "!!!")
	
	cRet := PadR(cTipo, 	TamSX3("GW1_CDTPDC")[1])	+ " | " + ;
			PadR(cEmissor,	TamSX3("GW1_EMISDC")[1])	+ " | " + ;
			PadR(cSerie, 	3) 	+ " | " + ;
			PadR(cNumero, 	TamSX3("GW1_NRDC")[1]) 	+ " | " + ;
			cEstimativa
Return cRet

/*/{Protheus.doc} SugereData
Sugestão da data conforme data do último fechamento 
nos campos "Data Emissão de" e "Data Emissão Até" 
no pergunte GFEA088

Uso exclusivo.
	
@author Alan Victor Lamb
@since 30/12/2013
@version 1.0		
/*/
Static Function SugereData()

	Local dUltFech := SuperGetMv('MV_DTULFE')
	Local dProx
	
	If !Empty(dUltFech)
		// Sugere "data emissão de"
		dProx := dUltFech + 1
		SetMVValue("GFEA088","MV_PAR03",dProx)
		
		// Sugere "data emissão até"
		dProx:= CtoD(STR(Last_Day(dProx)) + "/" + STR(MONTH(dProx)) + "/" + STR(YEAR(dProx)))
		SetMVValue("GFEA088","MV_PAR04",dProx)
	EndIf
	
Return

/*/{Protheus.doc} GFEVLCLCES
Retorna valor do calculo de estimativa/provisão de um documento de carga.
Caso não exista cálculo retorna 0.
	
@author Alan Victor Lamb
@since 30/12/2013
@version 1.0
		
@param cTPDC, character, Tipo do Documento
@param cEMISDC, character, Emissor
@param cSERDC, character, Série
@param cNRDC, character, Número

@return nValor, valor do frete

@example
nValor := GFEVLCLCES("NFS", "100", "1", "123")
/*/
Function GFEVLCLCES(cTPDC, cEMISDC, cSERDC, cNRDC)
	Local nValor := 0
	
	dbSelectArea("GWH")
	dbSelectArea("GWF")
	
	GWH->( dbSetOrder(2) )
	GWF->( dbSetOrder(1) )
	
	If GWH->( dbSeek( xFilial("GWH") + cTPDC + cEMISDC + cSERDC + cNRDC  ) )
		While !GWH->( Eof() ) .And. ;
				GWH->GWH_FILIAL == xFilial("GWH") .And. ;
				GWH->GWH_CDTPDC == cTPDC .And. ;
				GWH->GWH_EMISDC == cEMISDC .And. ;
				GWH->GWH_SERDC == cSERDC .And. ;
				GWH->GWH_NRDC == cNRDC
			
				If GWF->( dbSeek( GWH->GWH_FILIAL + GWH->GWH_NRCALC ) )
					If GWF->GWF_TPCALC == "8"
						nValor += VLTOTFRET()
					EndIf
				EndIf
				
			GWH->( dbSkip() )
		EndDo
	EndIf
Return nValor

/*/{Protheus.doc} A088CLCEST
Realiza o cálculo de estimativa para um documento de carga.
Pode ser usado no escopo do GFEA088 ou como ação relacionada para o GFEC094.
	
@author Alan Victor Lamb
@since 06/03/2014
@version 1.0
		
@param cFilDoc, C, Filial do documento de carga
@param cCDTPDC, C, Código do tipo de documento de carga
@param cEMISDC, C, Emitente documento de carga
@param cSERDC, C, Série documento de carga
@param cNRDC, C, Número documento de carga
@param nTabProv, N, 0=Não é cálculo de provisão,1=Utiliza tabela de provisão, 2=Utiliza tabela do transportador para cálculo de provisão
@param lSalvaLog, L, Indica se salva a memória do cálculo e do rateio contábil (Uso GFEA088)
@param oGFELog, O, Objeto de log utilizado na execução (Uso GFEA088)
@param nQtdeNCalc, N, Variável que contém o contador de cálculos não realizados (Uso GFEA088)
@param nQtdeCalc, N, Variável que contém o contador de cálculos realizados (Uso GFEA088)

@return nVlFret, valor do cálculo de estimativa gerado

@example
nVlFret := A088CLCEST(GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC)
/*/
Function A088CLCEST(cFilDoc, cCDTPDC, cEMISDC, cSERDC, cNRDC, nTabProv, lSalvaLog, oGFELog, nQtdeNCalc, nQtdeCalc)
	Local aAgrFrt  := {}
	Local aDocCarg := {}
	Local aTrchDoc := {}
	Local aItDoc   := {}
	Local aRetCalc := {}
	Local nQtde
	Local cCdTpOp
	Local cFilAtu
	Local nVlFret  := 0
	Local aErr
	Local nY
	Local cValor
	Local aTrechos
	
	Default nQtdeNCalc := 0
	Default nQtdeCalc  := 0
	Default oGFELog	   := Nil
	Default nTabProv   := 2
	Default lSalvaLog  := .T.
	
	dbSelectArea("GW1")
	dbSelectArea("GWB")
	dbSelectArea("GWU")
	dbSelectArea("GW8")
	
	// Se o ERP integrado for o DATASUL, utiliza o parametro MV_TPOPEMB, senão MV_CDTPOP
	If SuperGetMV("MV_CADERP",.T.,"") $ "1" .And. SuperGetMV("MV_ERPGFE",.T.,"") $ "1"
		cCdTpOp := SuperGetMV("MV_TPOPEMB",.T.,"")
	Else
		cCdTpOp := SuperGetMV("MV_CDTPOP",.T.,"")
	EndIf
		
	If GW1->( dbSeek(cFilDoc + cCDTPDC + cEMISDC + cSERDC + cNRDC ) )
		// Totaliza unitizadores do documento selecionado
		nQtde := 0
		
		GWB->( dbSetOrder(02) )
		GWB->( dbSeek( cFilDoc + cCDTPDC + cEMISDC + cSERDC + cNRDC ) )
		While !GWB->(Eof()) .AND. ;
			  GWB->GWB_FILIAL == GW1->GW1_FILIAL .AND. ;
			  GWB->GWB_CDTPDC == GW1->GW1_CDTPDC .AND. ;
			  GWB->GWB_EMISDC == GW1->GW1_EMISDC .AND. ;
			  GWB->GWB_SERDC  == GW1->GW1_SERDC  .AND. ;
			  GWB->GWB_NRDC   == GW1->GW1_NRDC
			nQtde += GWB->GWB_QTDE
			GWB->(dbSkip())
		EndDo

		aAdd(aDocCarg,{GW1->GW1_EMISDC, ;	// Emitente do Documento
					   GW1->GW1_SERDC , ; 	// Serie do Documento
					   GW1->GW1_NRDC  , ; 	// Numero do Documento
					   GW1->GW1_CDTPDC, ; 	// Tipo do Documento
					   GW1->GW1_CDREM , ;  	// Remetente do Documento
					   GW1->GW1_CDDEST, ; 	// Destinatario do Documento
					   GW1->GW1_ENTEND, ; 	// Endereco de Entrega
					   GW1->GW1_ENTBAI, ; 	// Bairro de entrega
					   GW1->GW1_ENTNRC, ; 	// Cidade de Entrega
					   GW1->GW1_ENTCEP, ; 	// CEP de Entrega
					   GW1->GW1_NRREG , ;  	// Região de destino
					   GW1->GW1_TPFRET, ; 	// Tipo de Frete
					   GW1->GW1_ICMSDC, ; 	// ICMS?
					   GW1->GW1_USO   , ;  	// Finalidade da mercadoria
					   GW1->GW1_CARREG, ; 	// Número do carregamento
					   GW1->GW1_NRDC , ;  	// Numero do Agrupador
					   If(nQtde > 0, nQtde, GW1->GW1_QTVOL)}) //Quantidade

					   
		aTrechos := XFBGWUDC(,GW1->GW1_FILIAL,GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC)
		For nY := 1 To Len(aTrechos)
			If aTrechos[nY,5] == '01' .And. Empty(aTrechos[nY,6])
				If Empty(oGFELog)
					MsgStop("Não há transportador no primeiro trecho deste documento.","Aviso")
				Else
					nQtdeNCalc++
					oGFELog:Add(MontaLinha(GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC,"NÃO HÁ TRANSPORTADOR NO PRIMEIRO TRECHO"))
				EndIf
				
				Return nVlFret
			EndIf
			aAdd(aTrchDoc,aClone(aTrechos[nY]))
		Next nY
		
		// Itens do Documento
		GW8->( dbSetOrder(01) )
		GW8->( dbSeek( cFilDoc + cCDTPDC + cEMISDC + cSERDC + cNRDC ) )
		While GW8->(!Eof()) .AND. ;
			  GW8->GW8_FILIAL == GW1->GW1_FILIAL .AND. ;
			  GW8->GW8_EMISDC == GW1->GW1_EMISDC .AND. ;
			  GW8->GW8_CDTPDC == GW1->GW1_CDTPDC .AND. ;
			  GW8->GW8_SERDC  == GW1->GW1_SERDC  .AND. ;
			  GW8->GW8_NRDC   == GW1->GW1_NRDC

			aAdd(aItDoc,{GW8->GW8_EMISDC, ;	// Emitente do Documento
					     GW8->GW8_SERDC , ;	// Serie do Documento
					     GW8->GW8_NRDC  , ;	// Numero do Documento
					     GW8->GW8_CDTPDC, ;	// Tipo do Documento
					     GW8->GW8_ITEM  , ;	// Item
					     GW8->GW8_CDCLFR, ;	// Classificacao de Frete
					     GW8->GW8_TPITEM, ;	// Classificacao de Frete
					     GW8->GW8_QTDE  , ;	// Quantidade do Item
					     GW8->GW8_PESOR , ;	// Peso do Item
					     GW8->GW8_PESOC , ;	// Peso Cubado
					     GW8->GW8_QTDALT, ;	// Quantidade/Peso Alternativo
					     GW8->GW8_VALOR , ;	// Valor do Item
					     GW8->GW8_VOLUME, ;	// Volume ocupado (m3)
					     GW8->GW8_TRIBP})  	// Frete tributado PIS

			GW8->( dbSkip() )
		EndDo
		
		If Len(aTrchDoc) == 0 .OR. Len(aItDoc) == 0
			//Documento não possui trechos ou itens
			If Empty(oGFELog) 
				MsgStop("Documento não possui trechos ou itens.", "Aviso") // Quando executado via ação relacionada
			Else
				oGFELog:Add(MontaLinha(GW1->GW1_CDTPDC,GW1->GW1_EMISDC,GW1->GW1_SERDC,GW1->GW1_NRDC,"CÁLCULO SEM SUCESSO"))
				nQtdeNCalc++
			EndIf
		Else
			aAdd(aAgrFrt,{ GW1->GW1_NRDC,  ;	// Numero do Agrupador
	  		  aTrchDoc[1][6],  ;				// Transportador
	  		  , ; 								// Tipo de Veiculo
			  , ; 								// Classificacao de Frete
			  cCdTpOp, ; 						// Tipo de Operacao
			  0, ; 								// Distancia Percorrida
			  , ; 								// Cidade Destino
			  , ;   								// CEP Destino
			  "0"})
			
			cFilAtu  := cFilAnt
			cFilAnt  := GW1->GW1_FILIAL
			aRetCalc := GFECLCFRT(aAgrFrt, aDocCarg, aTrchDoc, aItDoc, /*aTblFrt*/, .T./*lReal*/, 0/*iLogProc*/, nTabProv/*nTabProv*/, /*lParCons*/, /*iTpSimul*/, .T. /*lCalcLote*/, .T. /* HideProgress */, lSalvaLog/* lSaveLog*/)
			cFilAnt  := cFilAtu
			
			If aRetCalc[1]
				nVlFret := GFEVLCLCES(cCDTPDC, cEMISDC, cSERDC, cNRDC)

				If !Empty(oGFELog)
					If nVlFret > 0
						cValor := "R$ " + AllTrim(Transform(nVlFret, "@E 999,999,999.99")) 
					Else
						cValor := "CÁLCULO NÃO ENCONTRADO"							
					EndIf

					oGFELog:Add(MontaLinha(cCDTPDC, cEMISDC, cSERDC, cNRDC,cValor))

					nQtdeCalc++
				EndIf
			Else
				aErr := GFECalcErr(aRetCalc[3][1][2])
				
				For nY := 1 To Len(aRetCalc[3][1][4])
       				aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aRetCalc[3][1][4][nY]) 
       			Next
		       	
		       	If Empty(oGFELog)
					MsgStop("Não foi possível gerar cálculo para este documento. " + aErr[1])
				Else
					oGFELog:Add(MontaLinha(cCDTPDC, cEMISDC, cSERDC, cNRDC,aErr[1]))

					nQtdeNCalc++
				EndIf
			EndIf
		EndIf
	EndIf
Return nVlFret