#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static oQrySD1 := Nil
Static oQrySF8 := Nil
Static oQrySF9 := Nil
Static aContent := {}
Static nItens := 0


//-------------------------------------------------------------------
/*/{Protheus.doc} FISCIAP()
Realiza a geração de CIAP ou Exclusão
@author Erich Buttner
@since 21/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISCIAP(nOpc,cAliasSD1,nQtdReq,cRotina,nF1Origem,nFilCiap,nCodCiap,aRecSF1Ori)
Local aAreaAnt   := GetArea()
Local nQtdD1     := 1
Local nVlrICMS   := 0
Local nDIfDec    := 0
Local nDIfIcm	 := 0
Local nX         := 0
Local nValFrete  := 0
Local nTotalNF   := If(Int((cAliasSD1)->D1_QUANT) > 0, Int((cAliasSD1)->D1_QUANT), 1)
Local nLaco      := 1
Local nSldParc   := 0
#IFDEF TOP 
	Local cQuery   := ""
#ENDIF 
Local cEstado    := GetNewPar("MV_ESTADO", "")
Local cSimpNac   := ""
Local cCIAP      := ""
Local cCIAPIni   := ""
Local cNum       := ""
Local cDaCiap    := GetNewPar("MV_DACIAP",'S') //Utilizado para calc. ICMS no CIAP. Se S= Considera valor de dif. aliquota se N= Nao considera dif. aliquota
Local cSTCiap    := GetNewPar("MV_STCIAP","N") //Utilizado para calc. ICMS no CIAP. Se S= Considera valor de ICMS ST se N= Nao considera ICMS ST.
Local cFTCiap    := GetNewPar("MV_FTCIAP","N") //Utilizado para calc. ICMS no CIAP. Se S= Considera valor de ICMS FRETE se N= Nao considera ICMS FRETE.
Local cAnCiap    := GetNewPar("MV_ANCIAP","N") //Utilizado para calc. ICMS no CIAP. Se S= Considera valor de ICMS ST Anterior se N= Nao considera ICMS ST Anterior.
Local cSf9CC     := GetNewPar("MV_F9CC", "")
Local cSf9CHVNF  := GetNewPar("MV_F9CHVNF", "")
Local cSf9PL     := GetNewPar("MV_F9PL", "")
Local cSf9Prod   := GetNewPar("MV_F9PROD", "")
Local cSf9Esp    := GetNewPar("MV_F9ESP", "")
Local cUfFor     := ""
Local lPzDifRS   := .F.
Local lDelFisico := SuperGetMV("MV_DELCIAP",.T.,1) == 1  //Se = 1 Deleta SFA e SF9 Fisicamente se = 2 Deleta logicamente
Local lF9DtIni   := SF9->(FieldPos("F9_DTINIUT")) > 0
Local lF9VldBAtv := SF9->(FieldPos("F9_VLDBATV")) > 0
Local lSpedFisc  := (SF9->(FieldPos("F9_VALFRET")) > 0 .And. SF9->(FieldPos("F9_VALICST")) > 0 .And. ;
						SF9->(FieldPos("F9_VALICCO")) > 0 .And. SF9->(FieldPos("F9_VALICMP")) > 0)
Local lFrtEx116	 := AllTrim(cFTCiap) == "S" .And. (FwIsInCallStack("MATA116") .Or. (FwIsInCallStack("MATA103") .And. (cAliasSD1)->D1_TIPO == "C" .And. SF1->F1_TPCOMPL == "3"))
Local lCodLivre  := .F.
Local aCiapParV  := &(GetNewPar("MV_CIAPVPA", ""))
Local cFSNCIAP   := GetNewPar("MV_FSNCIAP","1")
Local dDtDigit 	 := ""
Local cNfOrig	 := ""
Local cSerOrig	 := ""
Local cFornOrig	 := ""
Local cLjOrig    := ""
Local aAreaCompl := {}
Local lRndCiap	 := SuperGetMv("MV_RNDCIAP",.F.,.F.) 
Local aVlrFrt	 := {} 
Local nCalPerFre := 0   //Calculo Percentual de Frete.
Local nCalPerICC := 0   // Calculo Percentual do Difal
Local nLC102     := GetMV("MV_LC102")
Local cAliasQry  := ""
Local cQrySF9    := ""
Local cItemNFE   := ""
Local cCodProd   := ""
Local nQtdProd   := 0
Local nCount     := 0
Local aNfeSf9    := {}

Default nQtdReq    := 0
Default nF1Origem  := 0
Default nFilCiap   := 0
Default nCodCiap   := 0
Default aRecSF1Ori := {}

If nOpc == 1 .And. !((cAliasSD1)->D1_TIPO $ "C|I")//Inclusão SF9
	SA2->(MsSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
	cSimpNac := Iif(cPaisLoc == "BRA",SA2->A2_SIMPNAC,"")
	cUfFor	 := SA2->A2_EST
	
	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1")+(cAliasSD1)->D1_COD))
	
	//-- Desmembra itens no ativo
	If SF4->F4_BENSATF == "1"
		If ((cAliasSD1)->D1_TIPO <> "P") .And. ((cAliasSD1)->D1_TIPO <> "C")
			If !Empty(nQtdReq)
				nLaco := nQtdReq
			Else
				nLaco := Int((cAliasSD1)->D1_QUANT)
			EndIf
			nQtdD1 := 1
		Else
			If !Empty(nQtdReq)
				nQtdD1 := nQtdReq
			Else
				nQtdD1 := If(Int((cAliasSD1)->D1_QUANT) > 0, Int((cAliasSD1)->D1_QUANT), 1)
			EndIf
		EndIf
	Else
		If !Empty(nQtdReq)
			nQtdD1 := nQtdReq
		Else
			nQtdD1 := If(Int((cAliasSD1)->D1_QUANT) > 0, Int((cAliasSD1)->D1_QUANT), 1)
		EndIf
	EndIf
	
	nVlrICMS := (cAliasSD1)->D1_VALICM
	
	//Minas Gerais - Decreto 45.776, 21/11/2011 DOE/MG Art. 206
	//Simples nacional/Livro O ou Z/ICMS Complementar
	If (cSimpNac=="1" .Or. SubStr((cAliasSD1)->D1_CLASFIS,2,2) $ "40/41/50") .And. SF4->F4_LFICM$"OZ" .And. SF4->F4_COMPL=="S"
		nVlrICMS := IIf(AllTrim(cDACiap)=="S", 0, (cAliasSD1)->D1_ICMSCOM)
	Endif
	nDIfDec	:= 0

	DbSelectArea("SF9")
	DbSetOrder(1) //F9_FILIAL+F9_CODIGO

	If nF1Origem > 0 .And. nFilCiap > 0 .And. nCodCiap > 0 .And. aAutoCab[nF1Origem][2] == "ATFA060"
		If MsSeek(aAutoItens[1][nFilCiap][2]+aAutoItens[1][nCodCiap][2])
			nSldParc := SF9->F9_SLDPARC
		EndIf
	EndIf

	For nX := 1 To nLaco
		// Verifica codigo utilizado para previnir erro de chave duplicada
		lCodLivre := .F.
		While !lCodLivre
			cNum := CriaVar("F9_CODIGO",.T.)
			If MsSeek(xFilial("SF9")+cNum)
				//Tratamento incluido pois quando o cliente utilizava o parâmetro
				//como 1 e passou à utilizar como branco poderia o último registro
				//do ano anterior coinscindir com o primeiro do ano atual.
				If !cFSNCIAP $ "1|3"
					cNum := Soma1(SubStr(cNum,1,4))+SubStr(cNum,5,2)
					lCodLivre := .T.
				Else
					SF9->(ConfirmSX8())
				Endif
			Else
				lCodLivre := .T.
			EndIf
		EndDo

		cCIAP := cNum
		If nX == 1
			cCIAPIni := cCIAP
		Endif
		nValFrete := Iif(SF4->F4_DESPICM$"S/1/5",(cAliasSD1)->(D1_VALFRE*D1_PICM)/100,0)
		RecLock("SF9",.T.)
		SF9->F9_FILIAL := xFilial("SF9")
		SF9->F9_CODIGO := cCIAP
		SF9->F9_DESCRI := SB1->B1_DESC
		SF9->F9_FORNECE:= (cAliasSD1)->D1_FORNECE
		SF9->F9_LOJAFOR:= (cAliasSD1)->D1_LOJA
		SF9->F9_DOCNFE := (cAliasSD1)->D1_DOC
		SF9->F9_SERNFE := (cAliasSD1)->D1_SERIE
		SF9->F9_ITEMNFE:= (cAliasSD1)->D1_ITEM
		SF9->F9_PROPRIO:= IIF(Empty((cAliasSD1)->D1_FORMUL),"N",(cAliasSD1)->D1_FORMUL)
		SF9->F9_DTENTNE:= (cAliasSD1)->D1_DTDIGIT
		SF9->F9_DTEMINE:= (cAliasSD1)->D1_EMISSAO
		SF9->F9_FUNCIT := GetSx3Cache("F9_FUNCIT","X3_RELACAO") //Considera o conteúdo padrão
	
		//POR PADRÃO IRÁ CONSIDERAR DATA DE INÍCIO DE UTILIZAÇÃO A DATA DE ENTRADA DO BEM
		IF cPaisLoc == "BRA" .And. lF9DtIni
			SF9->F9_DTINIUT := (cAliasSD1)->D1_DTDIGIT
		EndIF
		
		//Verifica parametro MV_DACIAP, MV_STCIAP e MV_FTCIAP para calculo do valor de icms no registro Ciap
		If Alltrim(cDACiap) == "N" .And. AllTrim(cSTCiap) == "N" .And. AllTrim(cFTCiap) == "N" .And. AllTrim(cAnCiap) == "N"
			SF9->F9_VALICMS:= NoRound((nVlrICMS / nTotalNF) * nQtdD1,2)
			//Acumula valores a partir da 3 casa decimal
			nDIfDec	+= Iif(nX == nLaco, ((nVlrICMS / nQtdD1) - NoRound((nVlrICMS /  nTotalNF) * nQtdD1,2))*nTotalNF, 0)
		Else
			//ALTERACAO PARA CONTROLE DO VALOR DO ICMS
			
			SF9->F9_VALICMS := NoRound((nVlrICMS/ nTotalNF) * nQtdD1,2)
			nDIfIcm	+=	Iif(nX == nLaco,(((nVlrICMS/ nTotalNF) * nQtdD1) - NoRound((nVlrICMS/ nTotalNF) * nQtdD1,2))*nTotalNF, 0)
			If AllTrim(cDACiap) == "S"
				SF9->F9_VALICMS += NoRound(((cAliasSD1)->D1_ICMSCOM / nTotalNF) * nQtdD1,2)
				//Acumula valores a partir da 3 casa decimal
				nDIfDec	+= Iif(nX == nLaco, ((((cAliasSD1)->D1_ICMSCOM/ nTotalNF) * nQtdD1) - NoRound(((cAliasSD1)->D1_ICMSCOM/ nTotalNF) * nQtdD1,2))*nTotalNF, 0) 
			EndIf
			If AllTrim(cSTCiap) == "S"
				SF9->F9_VALICMS += NoRound(((cAliasSD1)->D1_ICMSRET/ nTotalNF) * nQtdD1,2)
				//Acumula valores a partir da 3 casa decimal
				nDIfDec	+= Iif(nX == nLaco, ((((cAliasSD1)->D1_ICMSRET/ nTotalNF) * nQtdD1) -NoRound(((cAliasSD1)->D1_ICMSRET/ nTotalNF) * nQtdD1,2))*nTotalNF, 0)
			EndIf
			If AllTrim(cFTCiap) == "S"
				SF9->F9_VALICMS += NoRound((nValFrete/ nTotalNF) * nQtdD1,2)
				//Acumula valores a partir da 3 casa decimal
				nDIfDec	+= Iif(nX == nLaco, (((nValFrete/ nTotalNF) * nQtdD1) - NoRound((nValFrete/ nTotalNF) * nQtdD1,2))*nTotalNF, 0)
			EndIf
			If AllTrim(cAnCiap) == "S"
				//-- ICMS ST informado no campo ICMS ST Operacao Anterior (D1_ICMNDES)
				SF9->F9_VALICMS += NoRound(((cAliasSD1)->D1_ICMNDES/ nTotalNF) * nQtdD1,2)
				//Acumula valores a partir da 3 casa decimal
				nDIfDec	+= Iif(nX == nLaco, ((((cAliasSD1)->D1_ICMNDES/ nTotalNF) * nQtdD1) - NoRound(((cAliasSD1)->D1_ICMNDES/ nTotalNF) * nQtdD1,2))*nTotalNF, 0)
			EndIf
		EndIf

		//GRAVACAO DE TODOS OS TIPOS DE ICMS EM CAMPOS SEPARADOS - SPEDFISCAL.
		If cPaisLoc == "BRA" .And. lSpedFisc
			If cFTCiap == 'S'
				SF9->F9_VALFRET := NoRound((nValFrete/ nTotalNF)* nQtdD1,2) 
			EndIf
			SF9->F9_VALICST := NoRound(((cAliasSD1)->D1_ICMSRET/ nTotalNF) * nQtdD1,2)
			SF9->F9_VALICCO := NoRound(((cAliasSD1)->D1_ICMSCOM/ nTotalNF) * nQtdD1,2)
			SF9->F9_VALICMP := NoRound((nVlrICMS/ nTotalNF) * nQtdD1,2)
		EndIf

		//Se for o último bem irá somar a diferença de arredondamento a partir da 3 casa decimal dos bens anteriores..
		If nX == nLaco .And. lRndCiap
			SF9->F9_VALICST	:= SF9->F9_VALICST +  ((((cAliasSD1)->D1_ICMSRET/ nTotalNF) * nQtdD1) -NoRound(((cAliasSD1)->D1_ICMSRET/ nTotalNF) * nQtdD1,2))*nTotalNF
			SF9->F9_VALICCO	:= SF9->F9_VALICCO +  ((((cAliasSD1)->D1_ICMSCOM/ nTotalNF) * nQtdD1) - NoRound(((cAliasSD1)->D1_ICMSCOM/ nTotalNF) * nQtdD1,2))*nTotalNF
			If cFTCiap == 'S'
				SF9->F9_VALFRET := SF9->F9_VALFRET +  (((nValFrete/ nTotalNF) * nQtdD1) - NoRound((nValFrete/ nTotalNF) * nQtdD1,2))*nTotalNF
			EndIf
			SF9->F9_VALICMS := SF9->F9_VALICMS + nDIfDec + nDIfIcm
			SF9->F9_VALICMP := SF9->F9_VALICMP + nDIfIcm
		EndIf

		//Débito por Diferencial de Alíquota de Ativo Imobilizado
		If cPaisLoc == "BRA" .And. lF9VldBAtv
			SF9->F9_VLDBATV := (cAliasSD1)->D1_ICMSCOM
		Endif

		IF cUfFor == "RS" .And. cEstado == "RS" .And. (cAliasSD1)->D1_EMISSAO >= CtoD('01/03/2014')
			lPzDifRS := .T.
		EndIf
		If cPaisLoc == "BRA"
			SF9->F9_QTDPARC := IIF(nSldParc > 0, nSldParc, IIF(lPzDifRS, 24, IIF(ValType(aCiapParV) == "A" .And. Len(aCiapParV) == 2 .And. SF9->F9_VALICMS <= aCiapParV[2], aCiapParV[1], nLC102)))
			SF9->F9_SLDPARC := IIf(nSldParc > 0,nSldParc,SF9->F9_QTDPARC)
			SF9->F9_PARCRED := IIF(ValType(aCiapParV) == "A" .And. Len(aCiapParV) == 2 .And. SF9->F9_VALICMS <= aCiapParV[2], "1", "")
		EndIf
		SF9->F9_ROTINA := cRotina
		SF9->F9_CFOENT := (cAliasSD1)->D1_CF
		SF9->F9_PICM   := (cAliasSD1)->D1_PICM

		If SF9->(FieldPos(cSf9CHVNF))>0
			SF9->&cSf9CHVNF := SF1->F1_CHVNFE
		EndIf

		If SF9->(FieldPos(cSf9CC))>0
			SF9->&cSf9CC := (cAliasSD1)->D1_CC
		EndIf

		If SF9->(FieldPos(cSf9PL)) >0
			SF9->&cSf9PL := (cAliasSD1)->D1_CONTA
		EndIf

		If SF9->(FieldPos(cSf9Prod)) >0
			SF9->&cSf9Prod := (cAliasSD1)->D1_COD
		EndIf

		If SF9->(FieldPos(cSf9Esp))>0
			SF9->&cSf9Esp := SF1->F1_ESPECIE
		EndIf
		// NOVOS CAMPOS - Issue https://jiraproducao.totvs.com.br/browse/DSERFIS1-23448
		IF SF9->(FieldPos("F9_QTDNF")) > 0
			SF9->F9_QTDNF := (cAliasSD1)->D1_QUANT
		EndIF 
		
		IF SF9->(FieldPos("F9_TPESP")) > 0
			SF9->F9_TPESP := SF1->F1_ESPECIE
		EndIF 
		
		IF SF9->(FieldPos("F9_CHAVENF")) > 0
			SF9->F9_CHAVENF := SF1->F1_CHVNFE
		EndIF 
		
		IF SF9->(FieldPos("F9_CODPROD")) > 0
			SF9->F9_CODPROD := (cAliasSD1)->D1_COD
		EndIF

		IF SF9->(FieldPos("F9_CCUSTO")) > 0
			SF9->F9_CCUSTO := (cAliasSD1)->D1_CC
		EndIF 

		IF SF9->(FieldPos("F9_PLCONTA")) > 0
			SF9->F9_PLCONTA := (cAliasSD1)->D1_CONTA
		EndIF 
	 
		//Classificacao do Ativo 01=BEM e 03=COMPONENTE.
		If cPaisLoc == "BRA"
			If SF4->F4_COMPONE = "1"
				SF9->F9_TIPO := "03"
			Else
				SF9->F9_TIPO := "01"
			EndIf
		EndIf
		//Amarracao do Bem principal
		If cPaisLoc == "BRA" .And. !Empty((cAliasSD1)->D1_CODBAIX)
			SF9->F9_CODBAIX := (cAliasSD1)->D1_CODBAIX
		EndIf
		If __lSX8
			ConfirmSX8()
		EndIf
	Next nLaco
	cCiap:= IIf( SF4->F4_BENSATF == "1", cCIAPIni, SF9->F9_CODIGO )
ElseIf nOpc == 1 .And. (cAliasSD1)->D1_TIPO $ "C|I"

	cSimpNac := Iif(cPaisLoc == "BRA",SA2->A2_SIMPNAC,"")
	aAreaCompl := SF1->(GetArea())

	If (cAliasSD1)->D1_TIPO == "C"
		If Len(aRecSF1Ori) > 0
			If AllTrim(SF1->F1_ORIGLAN) == 'F'
				SF1->(DbGoTo(SelcRecno(aRecSF1Ori)))
				dDtDigit	:= DtoS(SF1->F1_DTDIGIT)
				cNfOrig		:= SF1->F1_DOC
				cSerOrig	:= SF1->F1_SERIE
				cFornOrig	:= SF1->F1_FORNECE
				cLjOrig		:= SF1->F1_LOJA
			EndIf
		EndIf	
	Else
		SF1->(DbSetOrder(1))

		If SF1->(DbSeek(xFilial("SF1")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			dDtDigit	:= DtoS(SF1->F1_DTDIGIT)
			cNfOrig		:= SF1->F1_DOC
			cSerOrig	:= SF1->F1_SERIE
			cFornOrig	:= SF1->F1_FORNECE
			cLjOrig		:= SF1->F1_LOJA
		EndIf
	EndIf
	
	RestArea(aAreaCompl)

	nCont := 1
	nVlrFretAC := 0
	cItemNFE := (cAliasSD1)->D1_ITEM
	cCodProd := (cAliasSD1)->D1_COD

	//Foi necessária a criação de uma query para a SF9 por não haver índices com o Item da Nota Fiscal na SF9
	cAliasQry := fBuscSF9( dDtDigit, cNfOrig, cSerOrig, cCodProd, cFornOrig, cLjOrig )	

	While (cAliasQry)->(!Eof()) 
		SF9->(DbGoTo((cAliasQry)->RECSF9))
		If Empty(aVlrFrt)
			//Estou passando a quantidade de item a partir da SF9, pois durante a inclusão de conhecimento de frete com desmembramento o sistema grava a quantidade zerada na SD1.
			aVlrFrt   := CalcRatFre( cNfOrig, cSerOrig, cFornOrig, cLjOrig, cCodProd )
		EndIf

		If Len(aVlrFrt) > 0
			RecLock("SF9",.F.)

			SF9->F9_VALICMP += Iif((cAliasSD1)->D1_TIPO == "I",(cAliasSD1)->D1_VALICM/nQtdD1, 0)
			SF9->F9_VALICMS += Iif((cAliasSD1)->D1_TIPO == "I",(cAliasSD1)->D1_VALICM/nQtdD1, 0)
			
			nCalPerFre := ((cAliasSD1)->D1_VALICM)*(aVlrFrt[nCont]/100)
			nCalPerICC := ((cAliasSD1)->D1_ICMSCOM)*(aVlrFrt[nCont]/100)
			
			If lRndCiap
				nCalPerFre := Round(NoRound(nCalPerFre),2)
				nCalPerICC := Round(NoRound(nCalPerICC),2)
			EndIf
			
			nVlrFretAC += nCalPerFre
			if (cAliasSD1)->D1_TIPO == "C"
				SF9->F9_VALFRET += nCalPerFre
				If cDACiap == "S"
					SF9->F9_VALICCO += nCalPerICC
				endif
			endif			

			If (cFTCiap $ "N| ") .Or. (cSimpNac == "1") // legislação https://tdn.totvs.com/pages/releaseview.action?pageId=634631575
				SF9->F9_VALFRET:= 0
			Else
				SF9->F9_VALICMS += nCalPerFre
				if cDACiap == "S"
					SF9->F9_VALICMS += nCalPerICC
				endif
			Endif		
			SF9->(MsUnLock())		
		EndIf
		(cAliasQry)->(DbSkip())
		nCont++
	EndDo

	(cAliasQry)->(DbCloseArea())

Else
	If lDelFisico
		SF9->(dbSetOrder(2))
		If SF9->(dbSeek(xFilial("SF9")+(cAliasSD1)->(DTOS(D1_DTDIGIT)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)))
			While SF9->(!Eof()) .And.; 
					SF9->(F9_FILIAL+DTOS(F9_DTENTNE)+F9_DOCNFE+F9_SERNFE+F9_FORNECE+F9_LOJAFOR) == xFilial("SF9")+(cAliasSD1)->(DTOS(D1_DTDIGIT)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
				cQuery := "DELETE FROM "+RetSqlName("SFA")
				cQuery += " WHERE FA_FILIAL   = '"+xFilial("SFA")+"'"
				cQuery += "   AND FA_CODIGO   = '"+SF9->F9_CODIGO+"'"
				cQuery += "   AND D_E_L_E_T_  = ' '"
				TcSqlExec(cQuery)

				SF9->(DbSkip())
			End
		EndIf

		cQuery := "DELETE FROM "+RetSqlName("SF9")
		cQuery += " WHERE F9_FILIAL  = '"+ xFilial("SF9")+"'"
		cQuery += "   AND F9_DTENTNE = '"+ DtoS((cAliasSD1)->D1_DTDIGIT) +"'"
		cQuery += "   AND F9_DOCNFE  = '"+ (cAliasSD1)->D1_DOC +"'"
		cQuery += "   AND F9_SERNFE  = '"+ (cAliasSD1)->D1_SERIE +"'"
		cQuery += "   AND F9_FORNECE = '"+ (cAliasSD1)->D1_FORNECE +"'"
		cQuery += "   AND F9_LOJAFOR = '"+ (cAliasSD1)->D1_LOJA +"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		TcSqlExec(cQuery)
	Else
		
		DbSelectArea("SFA")
		SFA->(DbSetOrder(1))
			
		aNfeSf9 := NfeSf9(SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_COD,SD1->D1_NFORI,SD1->D1_SERIORI)
		if !Empty(aNfeSf9)
			for nCount := 1 to Len(aNfeSf9)
				If SD1->D1_TIPO $ "C|I"					
					SF9->(DBGOTO(aNfeSf9[nCount,13]))
					RecLock("SF9",.F.)
					If SD1->D1_TIPO = "C"
						if cFTCiap == "S"
							SF9->F9_VALICMS -= aNfeSf9[nCount,10]
							SF9->F9_VALFRET -= aNfeSf9[nCount,10]
						endif
						if cDACiap == "S"
							SF9->F9_VALICMS -= aNfeSf9[nCount,9]
							SF9->F9_VALICCO -= aNfeSf9[nCount,9]
						endif							
					ElseIf SD1->D1_TIPO = "I"
						SF9->F9_VALICMP -= aNfeSf9[nCount,7]
						SF9->F9_VALICMS -= aNfeSf9[nCount,8]
					EndIf							
					SF9->(MsUnLock())
				Else
					If SFA->(DbSeek(xFilial("SFA")+aNfeSf9[nCount,1]))
						RecLock("SFA",.F.)
						SFA->(DbDelete())
						SFA->(MsUnLock())
					EndIf
					RecLock("SF9",.F.)
					SF9->(DbDelete())
					SF9->(MsUnLock())
				EndIf
			next
		endif
		aSize(aNfeSf9,0)			
	EndIf
EndIf

If oQrySD1 <> Nil 
	FreeObj(oQrySD1)
	oQrySD1:= Nil 
EndIf

If oQrySF8 <> Nil 
	FreeObj(oQrySF8)
	oQrySF8:= Nil 
EndIf

If oQrySF9 <> Nil 
	FreeObj(oQrySF9)
	oQrySF9:= Nil 
EndIf

If nItens == 0
	aSize(aContent, 0)
EndIf

RestArea(aAreaAnt)

Return cCiap
//-------------------------------------------------------------------
/*/{Protheus.doc} FISCIAP()
//FUNÇÃO RESPONSÁVEL POR BUSCAR DADOS DA SD1 PARA POSICIONAR CORRETAMENTE OS DADOS NA SF9
@author eduardo.vicente
@since 15/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fBuscDdsSD1(lFrtEx116)
Local lAchouSF8 := .F.
Local cTemp		:= ""
Local aAreaSD1  := SD1->(GETAREA())
Local aAreaSFA  := SFA->(GETAREA())
Local aAreaSF8  := SF8->(GETAREA())
Local cDtDigit  := ""
Local cAliasQry := ""
Local cNfOrig   := ""
Local cSerOrig  := ""
Local cFornOrig := ""
Local cLjOrig   := ""
Local cCodProd  := ""
Local cQrySF8   := ""


If lFrtEx116
	//O registro da SF8 que faz o relacionamento com a nota fiscal de origem neste momento está deletado. 
	// por conta disso é feita a query considerando os registros deletados, ordenando pelo Recno mais novo.
	cTemp		:= GetNextAlias()

	If oQrySF8 == Nil
		cQrySF8 := "SELECT SF8.F8_DTDIGIT,SF8.F8_NFORIG,SF8.F8_SERORIG,SF8.F8_FORNECE,SF8.F8_LOJA, SF8.R_E_C_N_O_ AS SF8RECNO"
		cQrySF8 += " FROM " + RetSqlName('SF8')+" SF8 "
		cQrySF8 += " WHERE SF8.F8_FILIAL   = ?"
		cQrySF8 += " AND   SF8.F8_NFDIFRE  = ?"
		cQrySF8 += " AND   SF8.F8_SEDIFRE  = ?"
		cQrySF8 += " AND   SF8.F8_TRANSP   = ?"
		cQrySF8 += " AND   SF8.F8_LOJTRAN  = ?"

		cQrySF8 += "ORDER BY SF8RECNO DESC"

		cQrySF8 := ChangeQuery(cQrySF8)

		oQrySF8 := FWPreparedStatement():New(cQrySF8)
	EndIf

	oQrySF8:SetString(1,xFilial("SF8"))
	oQrySF8:SetString(2,SD1->D1_DOC)
	oQrySF8:SetString(3,SD1->D1_SERIE)
	oQrySF8:SetString(4,SD1->D1_FORNECE)
	oQrySF8:SetString(5,SD1->D1_LOJA)

	cQrySF8	:= oQrySF8:GetFixQuery()
	MPSysOpenQuery(cQrySF8, cTemp)

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	IF !(cTemp)->(Eof())
		lAchouSF8 := .T.
		cDtDigit  := (cTemp)->F8_DTDIGIT
		cNfOrig   := (cTemp)->F8_NFORIG
		cSerOrig  := (cTemp)->F8_SERORIG
		cCodProd  := SD1->D1_COD
		cFornOrig := (cTemp)->F8_FORNECE
		cLjOrig   := (cTemp)->F8_LOJA
	EndIf
	(cTemp)->(dbCloseArea())
EndIf

If !lAchouSF8
	cDtDigit  := Dtos(SD1->D1_DTDIGIT)
	cNfOrig   := SD1->D1_DOC
	cSerOrig  := SD1->D1_SERIE
	cFornOrig := SD1->D1_FORNECE
	cLjOrig   := SD1->D1_LOJA
	cCodProd  := SD1->D1_COD
EndIf

cAliasQry := fBuscSF9( cDtDigit, cNfOrig, cSerOrig, cCodProd, cFornOrig, cLjOrig )

RestArea(aAreaSD1)
RestArea(aAreaSFA)
RestArea(aAreaSF8)

Return cAliasQry

//-------------------------------------------------------------------
/*/{Protheus.doc} fBuscSF9()
Função responsável por filtrar corretamente os registros da SF9 com base na SD1. Retorna o Alias com o filtro aplicado.

@author leandro.faggyas
@since 20/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fBuscSF9( cDtDigit, cNfOrig, cSerOrig, cCodProd, cFornOrig, cLjOrig )
Local cAliasQry := GetNextAlias()
Local cQrySF9   := ""

If oQrySF9 == Nil
	cQrySF9 := "SELECT SF9.F9_FILIAL, SF9.F9_DTENTNE, SF9.F9_DOCNFE, SF9.F9_SERNFE, SF9.F9_FORNECE, SF9.F9_LOJAFOR, SF9.F9_CODPROD, SF9.F9_CODIGO, SF9.R_E_C_N_O_ AS RECSF9, SF9.F9_ITEMNFE"
	cQrySF9 += " FROM " + RetSqlName('SF9')+" SF9 "
	cQrySF9 += " WHERE SF9.F9_FILIAL   = ?"
	cQrySF9 += " AND   SF9.F9_DTENTNE  = ?"
	cQrySF9 += " AND   SF9.F9_DOCNFE   = ?"
	cQrySF9 += " AND   SF9.F9_SERNFE   = ?"
	cQrySF9 += " AND   SF9.F9_CODPROD  = ?"
	cQrySF9 += " AND   SF9.F9_FORNECE  = ?"
	cQrySF9 += " AND   SF9.F9_LOJAFOR  = ?"
	cQrySF9 += " AND   SF9.D_E_L_E_T_  = ' '"
	cQrySF9 += "ORDER BY 1,2,3,4,5,6,7,8"

	cQrySF9 := ChangeQuery(cQrySF9)
	oQrySF9 := FWPreparedStatement():New(cQrySF9)
EndIf

oQrySF9:SetString(1,xFilial("SF9"))
oQrySF9:SetString(2,cDtDigit)
oQrySF9:SetString(3,cNfOrig)
oQrySF9:SetString(4,cSerOrig)
oQrySF9:SetString(5,cCodProd)
oQrySF9:SetString(6,cFornOrig)
oQrySF9:SetString(7,cLjOrig)

cQrySF9	:= oQrySF9:GetFixQuery()
MPSysOpenQuery(cQrySF9, cAliasQry)
DbSelectArea(cAliasQry)

Return cAliasQry

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcRatFre()
Realiza o cálcula de frete proporcional, tomando a decisão de quando será necessário ou não realizar o cálculo com desmembramento (F4_BENSATF = "1") dos itens pela SF9.

@author leandro.faggyas
@since 20/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CalcRatFre( cNfOrig, cSerOrig, cFornOrig, cLjOrig, cCodProd )
Local nX        := 0
Local aVlrFrt   := {} 
Local aAreaSF4  := SF4->(GetArea())
Local aAreaSD1  := SD1->(GetArea())
Local cAliasQry := GetNextAlias()
Local nQtdProd  := 0
Local nQtdNF    := 0
Local nPercProd := 0
Local cQrySD1   := ""

If oQrySD1 == Nil
	cQrySD1 := "SELECT SD1.D1_QUANT, SD1.D1_TES, SD1.D1_VUNIT, SD1.R_E_C_N_O_ AS RECSD1"
	cQrySD1 += " FROM " + RetSqlName('SD1')+" SD1 "
	cQrySD1 += " WHERE SD1.D1_FILIAL  = ?"
	cQrySD1 += " AND   SD1.D1_DOC     = ?"
	cQrySD1 += " AND   SD1.D1_SERIE   = ?"
	cQrySD1 += " AND   SD1.D1_FORNECE = ?"
	cQrySD1 += " AND   SD1.D1_LOJA    = ?"
	cQrySD1 += " AND   SD1.D1_COD     = ?"
	cQrySD1 += " AND   SD1.D_E_L_E_T_ = ' '"

	cQrySD1 := ChangeQuery(cQrySD1)
	oQrySD1 := FWPreparedStatement():New(cQrySD1)
EndIf

oQrySD1:SetString(1,xFilial("SD1"))
oQrySD1:SetString(2,cNfOrig)
oQrySD1:SetString(3,cSerOrig)
oQrySD1:SetString(4,cFornOrig)
oQrySD1:SetString(5,cLjOrig)
oQrySD1:SetString(6,cCodProd)

cQrySD1	:= oQrySD1:GetFixQuery()
MPSysOpenQuery(cQrySD1, cAliasQry)
DbSelectArea(cAliasQry)

//Quando o documento de origem possui o mesmo produto em mais de um item, ao lançar um CTE pelo MATA116 o sistema tem o comportamento de agregar esse produto em um único item. 
//Portanto, para o cálculo de proporcionalização ocorrer corretamente, deverá ser feita a contagem da quantidade total do produto
While (cAliasQry)->(!EoF())
	nQtdProd += (cAliasQry)->D1_QUANT
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbGoTop())

While (cAliasQry)->(!EoF())

	nQtdNF := (cAliasQry)->D1_QUANT

	nPercProd := (nQtdNF/nQtdProd) * 100

	SF4->(DbSetOrder(1))
	If SF4->(DbSeek(xFilial("SF4")+(cAliasQry)->D1_TES))
		If SF4->F4_BENSATF == "1"
			For nX := 1 To nQtdNF
				nPercFrt := ((((cAliasQry)->D1_VUNIT / nQtdNF) * 100) / (cAliasQry)->D1_VUNIT) 
				nPercFrt := nPercFrt * (nPercProd/100) //Por conta da possibilidade do produto ter sido aglutinado durante o lançamento do CTE, o percentual calculado logo acima é divido pelo percentual total do produto no documento de origem
				aAdd(aVlrFrt,nPercFrt)
			Next nX
		Else
			nPercFrt := nPercProd //Caso não haja desmembramento, será considerado o percentual total do item do documento de origem
			aAdd(aVlrFrt,nPercFrt)
		EndIf
	EndIf
	(cAliasQry)->(DbSkip())
EndDo																																																																																																						

(cAliasQry)->(DbCloseArea())

RestArea(aAreaSF4)
RestArea(aAreaSD1)

Return aVlrFrt
/*/{Protheus.doc} SelcRecno
	Responável por indicar qual o recno correto de acordo com a quantidade de intens contidos na SD1 
	@type  Function
	@Rhuan Carvalho
	@since 13/12/2024
	@version version
	@param arraySf1, array, array contendo recno das notas SF1
	@return nRecno, number, número do recno que deve ser utilizado.
	/*/
Function SelcRecno(ArraySF1)
	Local nPos   := 0
	Local nRecno := 0
	Local cAlias := ""

	nPos := aScan(aContent, { |x| x[3] < x[2]})
	
	If nPos > 0
		nRecno := aContent[nPos][1]
		aContent[nPos][3]++
		If aContent[nPos][3] == aContent[nPos][2]
			nItens -=1
		EndIf
	Else
		cAlias := ContaItens(ArraySF1)
		While (cAlias)->(!Eof())
			aadd(aContent, {(cAlias)->RECNO, (cAlias)->QTD_ITENS, 0})
			(cAlias)->(DbSkip())
			nItens ++
		EndDo
		nRecno := aContent[1][1]
		aContent[1][3]++
		If aContent[1][3] == aContent[1][2]
			nItens -=1
		EndIf
	EndIf

Return nRecno

/*/{Protheus.doc} ContaItens
	Querie realizada utilizando um inner join da SF1 com a SD1. Sua finalidade é retornar o alias da quantidade itens associados 
	ao recno da SF1. 
	@type  Function
	@Rhuan Carvalho
	@since 13/12/2024
	@version version
	@param arraySf1, array, array contendo recno das notas SF1
	@return cAlias, caractere, Alias para pesquisa
	/*/
Function ContaItens(ArraySF1)
	Local cQuery := ""
	Local cAlias := ""
	Local cDelet := " "

	cQuery := " SELECT SF1.R_E_C_N_O_ RECNO, COUNT(F1_DOC) QTD_ITENS "
	
	cQuery += " FROM ? SD1 "
	cQuery += " INNER JOIN ? SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL "
	cQuery += " AND SF1.F1_DOC = SD1.D1_DOC "
	cQuery += " AND SF1.F1_SERIE = SD1.D1_SERIE "
	cQuery += " AND SF1.F1_FORNECE = SD1.D1_FORNECE "
	cQuery += " AND SF1.F1_LOJA = SD1.D1_LOJA "
	cQuery += " AND SF1.F1_TIPO = SD1.D1_TIPO"
	cQuery += " AND SF1.R_E_C_N_O_ IN (?) "
	cQuery += " AND SF1.D_E_L_E_T_ = ? "
	
	cQuery += " WHERE SD1.D1_FILIAL = ? "

	cQuery += " GROUP BY SF1.F1_DOC, SF1.R_E_C_N_O_ "

	cQuery += " ORDER BY SF1.F1_DOC"

	oQryCnt := FWExecStatement():New()
	oQryCnt:SetQuery(ChangeQuery(cQuery))
	
	oQryCnt:SetUnSafe(1, RetSqlName("SD1"))
	oQryCnt:SetUnSafe(2, RetSqlName("SF1"))
	oQryCnt:setIn(3, ArraySF1)
	oQryCnt:SetString(4, cDelet)
	oQryCnt:SetString(5, xFilial("SF1"))

	cAlias := oQryCnt:OpenAlias() 

Return cAlias

/*/{Protheus.doc} NfeSf9
	Funcao para pegar todas as ocorrencias do Item da SD1 da NOTA de Complemento X Nota Original X SF9 para estorno de impostos
	@type  Static Function
	@author Ricardo Henrique de Mello Lima
	@since 12/07/2025
	@version 12.1.2410
	@param cDocNFC, character, Numrero do Documento de Complemento
	@param cSerNFC, character, Serie do Documento de Complemento
	@param cFornNFC, character, Fornecedor do Documento de Complemento
	@param cLojaNFC, character, Loja do Fornecedor do Documento de Complemento
	@param cCodPro, character, Produto Aglutinado do Documento de Complemento
	@param cDocOrig, character, Documento Vinculado ao Complemento
	@param cSerOrig, character, Serie Documento Vinculado ao CTE
	@return aNfeSf9, array, SF9 SD1 Com Valores dos Impostos
/*/
Static Function NfeSf9(cDocNFC,cSerNFC,cFornNFC,cLojaNFC,cCodPro,cDocOrig,cSerOrig)

	Local cQuery := "" as character
	Local oQueryNFC := nil as object
	Local cAliasNFC := "" as character
	Local aNfeSf9 := {} as array

	cQuery := " WITH CTE AS ( "
	cQuery += " SELECT  "
	cQuery += " 	SD1.D1_FILIAL, "
	cQuery += " 	SD1.D1_DOC, "
	cQuery += " 	SD1.D1_SERIE, "
	cQuery += " 	SD1.D1_FORNECE, "
	cQuery += " 	SD1.D1_LOJA, "
	cQuery += " 	SD1.D1_NFORI, "
	cQuery += " 	SD1.D1_SERIORI, "
	cQuery += " 	SD1.D1_ITEMORI, "
	cQuery += " 	SD1.D1_QUANT, "
	cQuery += " 	SD1.D1_VALICM, "
	cQuery += " 	SD1.D1_ICMSCOM  "
	cQuery += " FROM  "
	cQuery += " 	"+RetSqlName("SD1")+" SD1  "
	cQuery += " WHERE  "
	cQuery += " 	SD1.D1_FILIAL = ?  "
	cQuery += " 	AND SD1.D1_DOC = ?  "
	cQuery += " 	AND SD1.D1_SERIE = ?  "
	cQuery += " 	AND SD1.D1_FORNECE = ?  "
	cQuery += " 	AND SD1.D1_LOJA = ? "
	cQuery += " 	AND SD1.D_E_L_E_T_ = ?), "
	cQuery += " NFE AS (SELECT "
	cQuery += " 	C.D1_FILIAL, "
	cQuery += " 	C.D1_DOC, "
	cQuery += " 	C.D1_SERIE, "
	cQuery += " 	C.D1_FORNECE, "
	cQuery += " 	C.D1_LOJA, "
	cQuery += " 	C.D1_NFORI, "
	cQuery += " 	C.D1_SERIORI, "
	cQuery += " 	C.D1_ITEMORI, "
	cQuery += " 	C.D1_VALICM, "
	cQuery += " 	C.D1_ICMSCOM, "
	cQuery += " 	SD1.D1_QUANT, "
	cQuery += " 	SF9.F9_CODIGO, "
	cQuery += " 	SF9.F9_CODPROD, "
	cQuery += " 	SF9.F9_DOCNFE, "
	cQuery += " 	SF9.F9_SERNFE, "
	cQuery += " 	SF9.F9_ITEMNFE, "
	cQuery += " 	SF9.F9_VALFRET, "
	cQuery += " 	SF9.F9_VALICCO, "
	cQuery += " 	SF9.F9_VALICMS, "
	cQuery += " 	SF9.F9_VALICMP, "
	cQuery += " 	SF9.F9_VALICST, "
	cQuery += " 	SF9.F9_ICMIMOB, "
	cQuery += " 	SF9.R_E_C_N_O_ "
	cQuery += " FROM CTE C "
	cQuery += " LEFT JOIN  "
	cQuery += " 	"+RetSqlName("SD1")+" SD1  "
	cQuery += " 	ON SD1.D1_FILIAL = C.D1_FILIAL  "
	cQuery += " 	AND SD1.D1_DOC = C.D1_NFORI "
	cQuery += " 	AND SD1.D1_SERIE = C.D1_SERIORI "
	cQuery += " 	AND SD1.D1_ITEM = C.D1_ITEMORI "
	cQuery += " 	AND SD1.D_E_L_E_T_ = ? "
	cQuery += " LEFT JOIN  "
	cQuery += " 	"+RetSqlName("SF9")+" SF9  "
	cQuery += " 	ON SF9.F9_FILIAL = SD1.D1_FILIAL "
	cQuery += " 	AND SF9.F9_DOCNFE = SD1.D1_DOC  "
	cQuery += " 	AND SF9.F9_SERNFE = SD1.D1_SERIE "
	cQuery += " 	AND SF9.F9_ITEMNFE = SD1.D1_ITEM "
	cQuery += " 	AND SF9.D_E_L_E_T_ = ?) "
	cQuery += " SELECT   "
	cQuery += " 	NFE.D1_FILIAL, "
	cQuery += " 	NFE.F9_CODIGO, "
	cQuery += " 	NFE.F9_CODPROD, "
	cQuery += " 	NFE.F9_DOCNFE, "
	cQuery += " 	NFE.F9_SERNFE, "
	cQuery += " 	NFE.F9_ITEMNFE, "
	cQuery += " 	NFE.F9_VALICMP, "
	cQuery += " 	NFE.F9_VALICMS, "
	cQuery += " 	NFE.F9_VALICCO, "
	cQuery += " 	NFE.F9_VALICST, "
	cQuery += " 	NFE.F9_VALFRET, "
	cQuery += " 	NFE.F9_ICMIMOB, "
	cQuery += " 	NFE.D1_ICMSCOM, "
	cQuery += " 	NFE.D1_VALICM, "
	cQuery += " 	NFE.D1_QUANT, "
	cQuery += " 	NFE.R_E_C_N_O_ "
	cQuery += " FROM NFE"
	cQuery += " WHERE "
	cQuery += "		NFE.F9_CODPROD = ? "
	cQuery += " 	AND NFE.F9_DOCNFE = ? "
	cQuery += " 	AND NFE.F9_SERNFE = ? "

	oQueryNFC := FWExecStatement():New(cQuery)
	oQueryNFC:SetString(1,FwXFilial("SD1"))
	oQueryNFC:SetString(2,cDocNFC)
	oQueryNFC:SetString(3,cSerNFC)
	oQueryNFC:SetString(4,cFornNFC)
	oQueryNFC:SetString(5,cLojaNFC)
	oQueryNFC:SetString(6," ")
	oQueryNFC:SetString(7," ")
	oQueryNFC:SetString(8," ")
	oQueryNFC:SetString(9,cCodPro)
	oQueryNFC:SetString(10,cDocOrig)
	oQueryNFC:SetString(11,cSerOrig)


	cAliasNFC := oQueryNFC:OpenAlias()
	
	while (cAliasNFC)->(!EOF())
			AAdd(aNfeSf9,{;
			(cAliasNFC)->F9_CODIGO,;
			(cAliasNFC)->F9_CODPROD,;
			(cAliasNFC)->F9_ITEMNFE,;
			(cAliasNFC)->D1_QUANT,;
			(cAliasNFC)->D1_ICMSCOM,;
			(cAliasNFC)->D1_VALICM,;
			(cAliasNFC)->F9_VALICMS,;
			(cAliasNFC)->F9_VALICMP,;
			(cAliasNFC)->F9_VALICCO,;
			(cAliasNFC)->F9_VALFRET,;
			(cAliasNFC)->F9_VALICST,;
			(cAliasNFC)->F9_ICMIMOB,;
			(cAliasNFC)->R_E_C_N_O_})
		(cAliasNFC)->(DBSKIP())
	enddo	

	oQueryNFC:Destroy()
	FreeObj(oQueryNFC)
	(cAliasNFC)->(DBCLOSEAREA())
	
Return aNfeSf9
