#Include "Protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GIASTBR   ³ Autor ³ Rodrigo Zatt          ³ Data ³ 18.12.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³GIASTBR - Guia de Informacao e Apuracao do ICMS Mensal de   ³±±
±±³          ³Substituicao Tributaria para todos os estados brasileiros	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD -> Data incial do periodo - mv_par01     			  ³±±
±±³          ³ExpD -> Data final do periodo - mv_par02                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³16/04/2018³Vogas Junior   ³DSERFIS1-4798 Apresentar informacao de      ³±±
±±³          ³ DIFAL independente da informacao do campo FT_CREDST.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GIASTBR(dDtInicial, dDtFinal,cUf, cSomaFecp,cSomaFecpSt)
Local aTrbs		:= {}
Default cSomaFecp	:= "1"
Default cSomaFecpSt := "2"

//Gera arquivos temporarios
aTrbs := GeraTemp()
	
Processa({||ProGIAST(dDtInicial, dDtFinal, cUf, cSomaFecp,cSomaFecpSt)})

Return (aTrbs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProGIAST   ³ Autor ³Rodrigo Zatt           ³ Data ³ 18.12.08 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Registro da GIAST-BR                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProGIAST(dDtInicial, dDtFinal,cUf, cSomaFecp,cSomaFecpSt)	

	//³Processa Regitros
	ProcPrinc(dDtInicial, dDtFinal, cUf, cSomaFecp,cSomaFecpSt)		//Registro Principal

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProGIAST   ³ Autor ³Rodrigo Zatt           ³ Data ³ 18.12.08 ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processamento do Registro Principal                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcPrinc(dDtInicial, dDtFinal,cUF, cSomaFecp,cSomaFecpSt)
	Local cAliasSD1		:= "SD1"
	Local cAliasSD2		:= "SD2"
	Local cRessarST		:= Getnewpar("MV_RESST","")
	Local cCombusST		:= Getnewpar("MV_COMBST","")
	Local cTransfST		:= Getnewpar("MV_TRANFST","")
	Local nVlrProd		:= 0
	Local nVlrIPI		:= 0
	Local nVlrDesp		:= 0
	Local nVlrIcms		:= 0
	Local nBaseST  		:= 0
	Local nVlrST		:= 0
	Local nBaseProp		:= 0
	Local nVlrDev		:= 0
	Local nVlrRessarc	:= 0
	Local nVlrComb		:= 0
	Local nVlrCombST	:= 0
	Local nValorV		:= 0
	Local nContRG1		:= 0
	Local nContRG2		:= 0
	Local nContRG3		:= 0
	Local nValDifal		:= 0
	Local nValDifDev	:= 0
	Local nDevFECP		:= 0
	Local nTotDifal		:= 0
	Local nTotFecp		:= 0
	Local nVFecp		:= 0
	Local cVencto		:= ""
	Local cCnpjFor 		:= ""
	Local cAliasQry		:= ""
	Local cSubtrib      := IIf(FindFunction("GETSUBTRIB"), GetSubTrib(,.T.), SuperGetMv("MV_SUBTRIB"))
	Local cInsc         := Substr(cSubtrib,At(cUF,cSubtrib)+2,99) 	
	Local cInscOutrEst  := Iif(At("/",cInsc)>0,Substr(cInsc,0,At("/",cInsc)-1),cInsc)      
	Local cCdDifal		:= GetNewPar ("MV_GNDIFUF","")	//Codigo receita Difal por estado
	Local cCdFecp		:= GetNewPar ("MV_GNFPDUF","")	//Codigo receita FECP por estado
	Local cCodrec		:= ""
	Local cVecDif		:= ""
	Local cVencFec 		:= ""
	Local lVer12		:= SubStr( GetRpoRelease(),1,2 ) == "12"
	Local cSerie		:= ""	
	Local cEstado       := SuperGetMv("MV_ESTADO")
	Local cCidade       := SuperGetMv("MV_CIDADE")
	Local aStruSD1      := {}
	Local aStruSD2      := {}
	Local cQuery	    := ""
	Local nX		    := 0
	Local nForFilial	:= 0
	Local nForFinal		:= If(Len(aFilsCalc) > 1 .And.  MV_PAR07 == 1,Len(aFilsCalc),1) // Consolida Filial
	Local lSomaFecp		:= .T.
	Local lSomaFecpST	:= .F.
	Local lMvRPCBIZF    := GetNewPar("MV_RPCBIZF",.F.) .And. cUF $ GetNewPar("MV_RPCBIUF","") //Indica se deve ser retirado da base de cálculo do ICMS o desconto de PIS/Cofins para ZF Manaus.
	Local nBasImp       := 0
	Local nValImp       := 0 
	Local oPrepare      := Nil
	Local aBind         := {}
	
	Default aFilsCalc	:= { { .T., cFilAnt } }
	lSomaFecp			:= Iif( cSomaFecp == "1", .T., .F. )
	lSomaFecpST			:= Iif( cSomaFecpSt == "1", .T., .F. )

	//Tratamento para clientes onde se utiliza o CNPJ ao invés da Inscrição Estadual para o recolhimento do DIFAL
	If "CNPJ" $ cInscOutrEst
		cInscOutrEst:= ""
	EndIf

	For nForFilial := 1 to nForFinal
		
		//Quando não consolida filiais MATA950 ja realizada tratamento das filiais que serão processadas
		If nForFinal > 1
			//Verifica se filial esta selecionada
			If !aFilsCalc[nForFilial, 1]		
				Loop
			EndIf
			cFilAnt := aFilsCalc[ nForFilial, 2 ]
		Endif
		
		cQuery := "SELECT "
		cQuery += "SFT.FT_VFECPST, SFT.FT_VFESTRN, SFT.FT_VFESTMG, SFT.FT_VFESTMT, SD2.D2_VFCPDIF, SD2.D2_VALIPI, "
		cQuery += "SD2.D2_DIFAL, SD2.D2_CF, SD2.D2_VALICM, SD2.D2_BASEICM, SD2.D2_VALFRE, SD2.D2_SEGURO, SD2.D2_DESPESA, SD2.D2_ICMSRET, SD2.D2_TOTAL, "
		cQuery += "SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_SERIE, SD2.D2_DOC, SD2.D2_BRICMS, SD2.D2_TIPO, "
		cQuery += "SD2.D2_PICM, SFT.FT_BSICMOR, SFT.FT_DESCZFR "
		cQuery += "FROM " + RetSqlName("SD2") + " SD2 "
		
		cQuery += "LEFT JOIN "+ RetSqlName("SFT") + " SFT ON "
		cQuery += "SFT.FT_FILIAL  = ? AND "
		cQuery += "SFT.FT_NFISCAL = SD2.D2_DOC AND "
		cQuery += "SFT.FT_SERIE   = SD2.D2_SERIE AND "
		cQuery += "SFT.FT_CLIEFOR = SD2.D2_CLIENTE AND "
		cQuery += "SFT.FT_LOJA	  = SD2.D2_LOJA AND " 
		cQuery += "SFT.FT_PRODUTO = SD2.D2_COD AND " 
		cQuery += "SFT.FT_ITEM 	  = SD2.D2_ITEM AND " 
		cQuery += "SFT.FT_TIPOMOV = ? AND "
		cQuery += "(SFT.FT_CREDST <> ? OR SD2.D2_DIFAL > ?) " // Em operações com ST, não considera 4 assim como apuração de ICMS	
		
		cQuery += "WHERE "
		cQuery += "SD2.D2_FILIAL  =  ? AND "
		cQuery += "SD2.D2_EMISSAO >= ? AND "				
		cQuery += "SD2.D2_EMISSAO <= ? AND "
		cQuery += "(SD2.D2_DIFAL  >  ? OR SD2.D2_VFCPDIF > ? OR SD2.D2_ICMSRET > ?) AND "
		cQuery += "SD2.D2_TIPO    <> ? AND "
		cQuery += "SD2.D_E_L_E_T_ =  ? AND "
		cQuery += "SFT.D_E_L_E_T_ =  ? "

		aAdd(aBind, xFilial("SFT") )
		aAdd(aBind, 'S' )
		aAdd(aBind, '4' )
		aAdd(aBind, 0 )
		aAdd(aBind, xFilial("SD2") )
		aAdd(aBind, DtoS(dDtInicial) )
		aAdd(aBind, DtoS(dDtFinal) )
		aAdd(aBind, 0 )
		aAdd(aBind, 0 )
		aAdd(aBind, 0 )
		aAdd(aBind, 'S' )
		aAdd(aBind, Space(1))
		aAdd(aBind, Space(1))

		cQuery := ChangeQuery(cQuery)
		oPrepare := FwExecStatement():New( cQuery )
		
		For nX := 1 To Len(aBind)
			cTypeBind := Valtype(aBind[nX])
			If cTypeBind == 'C'
				oPrepare:setString(nX, aBind[nX])
			ElseIf cTypeBind == 'N'
				oPrepare:setNumeric(nX, aBind[nX])
			EndIf
		Next nX

		cAliasSD2 := "SD2_GIAST"
		oPrepare:cbasequery := oPrepare:GetFixQuery()
		oPrepare:OpenAlias(cAliasSD2)

		aStruSD2 := SD2->(dbStruct())
		For nX := 1 To Len(aStruSD2)
			If aStruSD2[nX][2] <> "C" .And. FieldPos(aStruSD2[nX][1])<>0
				TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
			EndIf
		Next nX

		aBind := {}

		Do While !((cAliasSD2)->(Eof()))                                                 

			dbSelectArea("SA1") 
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			
			If (cAliasSD2)->D2_TIPO =='D'
				dbSelectArea("SA2") 
				SA2->(DbSetOrder(1))
				SA2->(DbSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
			Endif
		
			dbSelectArea("SF2")        
			SF2->(dbSetOrder(1))
			SF2->(dbSeek(xFilial("SF2")+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA,.T.))
			
			If SF2->F2_EST == cUf
				If (cAliasSD2)->FT_DESCZFR > 0 //Desoneração Zona Franca
					If lMvRPCBIZF
						nBasImp := (cAliasSD2)->FT_BSICMOR + (cAliasSD2)->FT_DESCZFR
					else
						nBasImp := (cAliasSD2)->FT_BSICMOR
					EndIf	
					nValImp     := nBasImp * ((cAliasSD2)->D2_PICM / 100)
					nVlrProd	+= (cAliasSD2)->D2_TOTAL + (cAliasSD2)->FT_DESCZFR
					nBaseProp   += nBasImp  
					nVlrIcms    += nValImp
				Else
					nVlrProd	+= Iif((cAliasSD2)->D2_ICMSRET > 0 .or. (cAliasSD2)->D2_VFCPDIF > 0, (cAliasSD2)->D2_TOTAL, 0) //Soma somente quando houver ICMS ST ou FECP
					nBaseProp   += Iif((cAliasSD2)->D2_ICMSRET > 0,(cAliasSD2)->D2_BASEICM, 0)  
					nVlrIcms    += Iif((cAliasSD2)->D2_ICMSRET > 0,(cAliasSD2)->D2_VALICM, 0)
				EndIf
				nVlrIPI		+= Iif((cAliasSD2)->D2_ICMSRET > 0,(cAliasSD2)->D2_VALIPI, 0) //Soma somente quando houver ICMS ST	
				nVlrDesp 	+= Iif((cAliasSD2)->D2_ICMSRET > 0,(cAliasSD2)->D2_DESPESA + (cAliasSD2)->D2_SEGURO + (cAliasSD2)->D2_VALFRE,0)
				nBaseST     += (cAliasSD2)->D2_BRICMS  
				nVlrST      += Iif( Alltrim((cAliasSD2)->D2_CF)$cCombusST,0,(cAliasSD2)->D2_ICMSRET)		  		  
				nVlrComb 	+= Iif( Alltrim((cAliasSD2)->D2_CF)$cCombusST,(cAliasSD2)->D2_ICMSRET, 0) 
				nValDifal	+= (cAliasSD2)->D2_DIFAL
				nTotDifal	+= (cAliasSD2)->D2_DIFAL
				nTotFecp	+= (cAliasSD2)->D2_VFCPDIF
				nVFecp      += (cAliasSD2)->FT_VFECPST+(cAliasSD2)->FT_VFESTRN+(cAliasSD2)->FT_VFESTMG+(cAliasSD2)->FT_VFESTMT
				
				If Alltrim((cAliasSD2)->D2_CF)$cTransfST	
					dbSelectArea("RG3")  
					IF !RG3->(dbSeek(Alltrim(SA1->A1_INSCR)))
						RecLock("RG3",.T.)
						RG3->IE       := If ((cAliasSD2)->D2_TIPO =='D',SA2->A2_INSCR,SA1->A1_INSCR)
						RG3->BASE     := (cAliasSD2)->D2_BRICMS
						RG3->ICMSTR   := (cAliasSD2)->D2_ICMSRET 
						RG3->CONTRG3  += 1
						nContRG3 		+= 1
					Else                 
						RecLock("RG3",.F.)
						RG3->BASE		+= (cAliasSD2)->D2_BRICMS
						RG3->ICMSTR		+= (cAliasSD2)->D2_ICMSRET					
					EndIf
					MsUnlock()           
				EndIf
				
			EndIf
			(cAliasSD2)->(dbSkip())
		Enddo
		
		(cAliasSD2)->(dbCloseArea())
			
		If oPrepare != Nil
			oPrepare:Destroy()
			freeObj(oPrepare)
			oPrepare := Nil
		EndIf                      					

		If lVer12
			cSerie := Iif(SerieNfId(cAliasSD1,3,"D1_SERIE") == "D1_SDOC",", SD1.D1_SDOC ","")
		Endif
		
		cQuery := "SELECT "
		cQuery += "SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_BRICMS, SD1.D1_ICMSRET, SD1.D1_CF, SD1.D1_DTDIGIT, SD1.D1_EMISSAO, SD1.D1_TIPO, "
		cQuery += "SD1.D1_ICMNDES, SD1.D1_NFORI, SD1.D1_SERIORI, SD1.D1_DIFAL, SD1.D1_VFCPDIF, SD1.D1_COD, SD1.D1_ITEM, SD1.D1_VFECPST" + cSerie 
		cQuery += "FROM " + RetSqlName("SD1") + " SD1 "
		cQuery += "WHERE "
		cQuery += "SD1.D1_FILIAL = ? AND "
		cQuery += "SD1.D1_DTDIGIT >= ? AND "				
		cQuery += "SD1.D1_DTDIGIT <= ? AND "	
		cQuery += "((SD1.D1_ICMSRET > ? AND SD1.D1_TIPO <> ?) OR (SD1.D1_TIPO = ? AND (SD1.D1_DIFAL > ? OR SD1.D1_VFCPDIF > ?))) AND "
		cQuery += "SD1.D_E_L_E_T_= ? "

		aAdd(aBind, xFilial("SD1") )
		aAdd(aBind, DtoS(dDtInicial) )
		aAdd(aBind, DtoS(dDtFinal) )
		aAdd(aBind, 0 )
		aAdd(aBind, 'S' )
		aAdd(aBind, 'D' )
		aAdd(aBind, 0 )
		aAdd(aBind, 0)
		aAdd(aBind, Space(1))

		cQuery := ChangeQuery(cQuery)
		oPrepare  := FwExecStatement():New(cQuery)
		
		For nX := 1 To Len(aBind)
			cTypeBind := Valtype(aBind[nX])
			If cTypeBind == 'C'
				oPrepare:setString(nX, aBind[nX])
			ElseIf cTypeBind == 'N'
				oPrepare:setNumeric(nX, aBind[nX])
			EndIf
		Next nX

		cAliasSD1 := "SD1_GIAST"
		oPrepare:cbasequery := oPrepare:GetFixQuery()
		oPrepare:OpenAlias(cAliasSD1)

		aStruSD1 := SD1->(dbStruct())		
		For nX := 1 To Len(aStruSD1)
			If aStruSD1[nX][2] <> "C" .And. FieldPos(aStruSD1[nX][1])<>0
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX

		aBind := {}

		Do While !((cAliasSD1)->(Eof())) 

			dbSelectArea("SA2") 
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
		    cInscA2 = SA2->A2_INSCR   
		    dbSelectArea("SA1") 
	     	SA1->(DbSetOrder(1))
	        SA1->(DbSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
			dbSelectArea("SF1")        
			SF1->(dbSetOrder(1))
			SF1->(dbSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA,.T.))

			If SF1->F1_EST == cUf 
				
				//Quando devolução de DIFAL não gera Anexo 1
				If (cAliasSD1)->D1_TIPO =='D' .And. ((cAliasSD1)->D1_DIFAL > 0 .OR. (cAliasSD1)->D1_VFCPDIF > 0)					
					nValDifDev    	+= (cAliasSD1)->D1_DIFAL
					nDevFECP		+= (cAliasSD1)->D1_VFCPDIF
				EndIf	
				
				SFT->(DbSetOrder(1))
				SFT->(DbSeek(xFilial("SFT") + "E" +(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_DOC+;  
				(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM+(cAliasSD1)->D1_COD ) )

				If SFT->FT_CREDST = '4' .And. ALLTRIM(SFT->FT_NFISCAL) == ALLTRIM((cAliasSD1)->D1_DOC) .And.;
					ALLTRIM(SFT->FT_PRODUTO) == ALLTRIM((cAliasSD1)->D1_COD).And. SFT->FT_SERIE = (cAliasSD1)->D1_SERIE .And.; 
					ALLTRIM(SFT->FT_ITEM) == ALLTRIM((cAliasSD1)->D1_ITEM) 
					(cAliasSD1)->(dbSkip())
					Loop
				Endif
				
				If ((cAliasSD1)->D1_TIPO =='D' .Or. ((cAliasSD1)->D1_TIPO $ 'D|B' .And. AT("MG",cSubtrib) <> 0)) .And. !((cAliasSD1)->D1_DIFAL > 0 .OR. (cAliasSD1)->D1_VFCPDIF > 0)
					RG1->(DbSetOrder(1))
					dbSelectArea("RG1")
					If !(RG1->(dbSeek(padr((cAliasSD1)->D1_DOC,13,' ')+(cAliasSD1)->D1_SERIE)))
						RecLock("RG1",.T.)		
						RG1->NFISCAL	:= (cAliasSD1)->D1_DOC
						RG1->SERIE  	:= (cAliasSD1)->D1_SERIE
						IF lVer12
							RG1->SDOC  		:= SerieNfId(cAliasSD1,2,"D1_SERIE")
						Endif
						RG1->IE			:= SA1->A1_INSCR
						RG1->EMISSAO	:= Dtos((cAliasSD1)->D1_EMISSAO)
						RG1->ICMSDEV	:= (cAliasSD1)->D1_ICMSRET
						RG1->CONTRG1	:= nContRG1
						nVlrDev 		+= (cAliasSD1)->D1_ICMSRET
						nVFecp			-= (cAliasSD1)->D1_VFECPST			 			
						nContRG1      	+= 1
						MsUnlock()
					Else
						RecLock("RG1",.F.)
						RG1->ICMSDEV	+= (cAliasSD1)->D1_ICMSRET
						nVlrDev 		+= (cAliasSD1)->D1_ICMSRET
						nVFecp			-= (cAliasSD1)->D1_VFECPST
						MsUnlock()
					EndIf
				EndIf			            
				
				//Busca as notas fiscais de complemento de devolução - solicitado no chamado TIGTO8
				If (cAliasSD1)->D1_TIPO $'I|C|P'  .And. !Empty( (cAliasSD1)->D1_NFORI) .And. !Empty( (cAliasSD1)->D1_SERIORI) // Verifica se tem a NF é de complemento e se tem NF/Serie original preenchida
					IF (SA2->(dbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))) // Verifica se o fornecedor existe e guarda o CNPJ na variave,
						cCnpjFor:= SA2->A2_CGC
						SF1->(dbSetOrder(1))
						IF (SF1->(dbSeek(xFilial("SF1")+(cAliasSD1)->D1_NFORI+(cAliasSD1)->D1_SERIORI))  .And. SF1->F1_TIPO=="D") //Verifica se existe a nota/serie da Devolução informada manualmente
							IF (SA1->(dbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA))) .And. SA1->A1_CGC == cCnpjFor	//Verifica se o Cliente existe e compara com o CNPJ do Fornecedor
								RG1->(DbSetOrder(1))
								dbSelectArea("RG1")
								If !(RG1->(dbSeek(padl((cAliasSD1)->D1_DOC,13,' ')+(cAliasSD1)->D1_SERIE)))
									RecLock("RG1",.T.)
									RG1->NFISCAL	:= (cAliasSD1)->D1_DOC
									RG1->SERIE  	:= (cAliasSD1)->D1_SERIE
									IF lVer12
										RG1->SDOC  		:= SerieNfId(cAliasSD1,2,"D1_SERIE")
									Endif
									RG1->IE			:= SA2->A2_INSCR
									RG1->EMISSAO	:= Dtos((cAliasSD1)->D1_EMISSAO)
									RG1->ICMSDEV	:= (cAliasSD1)->D1_ICMSRET
									nVlrDev        	+= (cAliasSD1)->D1_ICMSRET
									nContRG1        += 1
									MsUnlock()
								Else
									RecLock("RG1",.F.)
									RG1->ICMSDEV	+= (cAliasSD1)->D1_ICMSRET
									nVlrDev 		+= (cAliasSD1)->D1_ICMSRET
									MsUnlock()
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
		
				If Alltrim((cAliasSD1)->D1_CF)$cTransfST	
					dbSelectArea("RG3")  
					IF !RG3->(dbSeek(Alltrim(SA2->A2_INSCR)))
						RecLock("RG3",.T.)
						RG3->IE		 	:= If ((cAliasSD1)->D1_TIPO =='D',SA1->A1_INSCR,SA2->A2_INSCR)
						RG3->BASE		:= (cAliasSD1)->D1_BRICMS
						RG3->ICMSTR		:= (cAliasSD1)->D1_ICMSRET 
						RG3->CONTRG3    += 1
						nContRG3 		+= 1
					Else                 
						RecLock("RG3",.F.)
						RG3->BASE		+= (cAliasSD1)->D1_BRICMS
						RG3->ICMSTR		+= (cAliasSD1)->D1_ICMSRET					
					EndIf
					MsUnlock()           
				EndIf
				If Alltrim((cAliasSD1)->D1_CF)$cRessarST   
					RG2->(DbSetOrder(1))
					dbSelectArea("RG2")
					If !(RG2->(dbSeek((cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE)))					
						nContRG2 += 1
						RecLock("RG2",.T.)
						RG2->NFISCAL	:= (cAliasSD1)->D1_DOC
						RG2->SERIE  	:= (cAliasSD1)->D1_SERIE
						IF lVer12
							RG2->SDOC  		:= SerieNfId(cAliasSD1,2,"D1_SERIE")
						Endif
						RG2->IE			:= SA2->A2_INSCR 
						RG2->EMISSAO	:= Dtos((cAliasSD1)->D1_DTDIGIT)
						RG2->ICMSRES	:= (cAliasSD1)->D1_ICMSRET
						RG2->CONTRG2 	+= 1
						nVlrRessarc		+= (cAliasSD1)->D1_ICMSRET
						MsUnlock()
					Else
						RecLock("RG2",.F.)
						RG2->ICMSRES	+= (cAliasSD1)->D1_ICMSRET
						nVlrRessarc	    += (cAliasSD1)->D1_ICMSRET
						MsUnlock()
					EndIf
				EndIf                                                                   
				If Alltrim((cAliasSD1)->D1_CF)$cCombusST	 
					nVlrCombST 	+= (cAliasSD1)->D1_ICMNDES   
				Else
					nVlrCombST 	+= 0
				EndIf   		    
			Endif			
			(cAliasSD1)->(dbSkip())
		EndDo
		
		(cAliasSD1)->(dbCloseArea())
			
		If oPrepare != Nil
			oPrepare:Destroy()
			freeObj(oPrepare)
			oPrepare := Nil
		EndIf   

		cQuery := "SELECT "
		cQuery += "SF6.F6_DTVENC AS F6_DTVENC, SF6.F6_VALOR AS F6_VALOR, SF6.F6_CODREC AS F6_CODREC, SF6.F6_TIPOIMP AS F6_TIPOIMP "
		cQuery += "FROM " + RetSQLName( "SF6" ) + " SF6 "
		cQuery += "WHERE "
		cQuery += "SF6.F6_FILIAL = ?    AND "
		cQuery += "SF6.F6_MESREF = ?    AND "
		cQuery += "SF6.F6_ANOREF = ?    AND "
		cQuery += "SF6.F6_EST    = ?    AND "
		cQuery += "SF6.F6_TIPOIMP IN(?) AND "
		cQuery += "SF6.D_E_L_E_T_ = ?"

		aAdd(aBind, xFilial("SF6") )
		aAdd(aBind, Alltrim(Str(Month(dDtInicial))) )
		aAdd(aBind, Alltrim(Str(Year(dDtFinal))) )
		aAdd(aBind, cUf )
		aAdd(aBind, {'B', '3'})
		aAdd(aBind, Space(1))

		cQuery := ChangeQuery(cQuery)
		oPrepare := FwExecStatement():New(cQuery)
		
		For nX := 1 To Len(aBind)
			cTypeBind := Valtype(aBind[nX])
			If cTypeBind == 'C'
				oPrepare:setString(nX, aBind[nX])
			ElseIf cTypeBind == 'N'
				oPrepare:setNumeric(nX, aBind[nX])
			ElseIf cTypeBind == 'A'
        		oPrepare:setIn(nX, aBind[nX] )
			EndIf
		Next nX

		cAliasQry := GetNextAlias()
		oPrepare:cbasequery := oPrepare:getfixquery()
		oPrepare:OpenAlias(cAliasQry)

		aBind := {}		

		dbSelectArea("RG4")

		Do While !((cAliasQry)->(Eof())) 
			cCodrec	:=	Alltrim((cAliasQry)->F6_CODREC)
			
			Do case
						
				Case (cAliasQry)->F6_TIPOIMP ='B' .And. !Empty(cCodrec) .And. cUf+cCodrec	$ cCdDifal // Difal
						cVecDif	:= If(Empty(cVecDif),(cAliasQry)->F6_DTVENC,cVecDif)
				Case (cAliasQry)->F6_TIPOIMP ='B' .And. !Empty(cCodrec) .And. cUf+cCodrec	$ cCdFecp //Fecp					
						cVencFec:=If(Empty(cVencFec),(cAliasQry)->F6_DTVENC,cVencFec)
				OtherWise
						cVencto	:= If(Empty(cVencto),(cAliasQry)->F6_DTVENC,cVencto)
						nValorV	+= (cAliasQry)->F6_VALOR
				EndCase
						
			(cAliasQry)->(dbSkip())
		EndDo

		(cAliasQry)->(dbCloseArea())
		
		If oPrepare != Nil
			oPrepare:Destroy()
			freeObj(oPrepare)
			oPrepare := Nil
		EndIf
	Next	

	//Processamento Registro RGP
	dbSelectArea("RGP")
	IF !(RGP->(dbSeek(StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4))))
		RecLock("RGP",.T.)
		RGP->IE         := cInscOutrEst
		RGP->PERIODOREF	:= StrZero(Month(dDtInicial),2)+StrZero(Year(dDtInicial),4)
		RGP->VENCTO	 	:= cVencto
		RGP->VALORV	 	:= Iif(!Empty(cVencto),nValorV,0)
		RGP->UF			:= cEstado
		RGP->VLRPROD   	:= nVlrProd
		RGP->VLRIPI   	:= nVlrIPI
		RGP->DESP       := nVlrDesp
		RGP->BASECALC  	:= nBaseProp
		RGP->ICMSPROP 	:= nVlrIcms	
		RGP->BASEST  	:= nBaseSt
		RGP->ICMSSUBST 	:= IIF(lSomaFecpST,nVlrST,nVlrST - nVFecp  )
		RGP->DEVOL	 	:= nVlrDev
		RGP->RESSARC 	:= nVlrRessarc
		RGP->COMBUST 	:= nVlrComb
		RGP->IMPDEV 	:= nVlrST - nVlrDev -  nVlrRessarc - IIF(lSomaFecpST,0,nVFecp)
		RGP->CREDPER 	:= 0
		RGP->TOTALREC   := (nVlrST - nVlrDev -  nVlrRessarc - IIF(lSomaFecpST,0,nVFecp)) + nVlrComb + nVlrCombST
		RGP->CIDADE     := cCidade
		RGP->DATAP      := Dtos(dDataBase)  
		RGP->CONTRG1    := nContRG1
		RGP->CONTRG2    := nContRG2
		RGP->CONTRG3    := nContRG3
		RGP->ICMCOMB	:= nVlrCombST
		RGP->REF39V1    := nVFecp
		RGP->REF39TDIF	:= Iif( lSomaFecp, nValDifal+nTotFecp, nValDifal )
		RGP->REF39TFCP	:= Iif((nTotFecp - nDevFECP) > 0,nTotFecp - nDevFECP,0)	
		RGP->REF39DA    := Iif( lSomaFecp, nValDifDev+nDevFECP, nValDifDev )
		MsUnlock()
	Endif

	//Atualiza Registro Anexo EC 87/15    ³
	If ((nTotDifal - nValDifDev) > 0) .or. (RGP->REF39TFCP > 0) //!RG4->(dbSeek(Alltrim(cDtRefChv)))
		RecLock("RG4", .T.)
			RG4->VALIMCS	:= Iif((nTotDifal - nValDifDev) > 0, nTotDifal - nValDifDev, 0) + Iif(lSomaFecp, RGP->REF39TFCP, 0) // Valor do ICMS
			RG4->VALFCP		:= RGP->REF39TFCP									 						                        // Valor do FECP
			RG4->DTVENC		:= Iif(RG4->VALIMCS > 0 .or. RG4->VALFCP > 0, Iif(!Empty(cVecDif), cVecDif, cVencto), '00000000')   // Data de Vencimento do ICMS Devido à UF de Destino
			RG4->VENCFCP	:= Iif(RG4->VALFCP > 0, Iif(!Empty(cVencFec), cVencFec, cVencto), '00000000')		                // Data de Vencimento do FECP Devido à UF de Destino		
		MsUnlock()				
	EndIf

Return Nil				

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Rodrigo Zatt           ³ Data ³ 18.12.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()
	Local aStru		:= {}
	Local aTrbs		:= {}
	Local cArq		:= ""
	
	//³Registro Tipo P - registro Principal                                                                           ³	
   	AADD(aStru,{"IE"       	    ,"C",014,0}) 
	AADD(aStru,{"PERIODOREF"	,"C",006,0})	//Periodo de Referencia - MMAAAA
	AADD(aStru,{"VENCTO"	    ,"C",008,0})	
	AADD(aStru,{"VALORV"    	,"N",015,2})	
	AADD(aStru,{"UF"		    ,"C",002,0})   	 
	AADD(aStru,{"VLRPROD"		,"N",015,2})   
	AADD(aStru,{"VLRIPI"		,"N",015,2})	
	AADD(aStru,{"DESP"			,"N",015,2})  	
	AADD(aStru,{"BASECALC"		,"N",015,2})  
	AADD(aStru,{"ICMSPROP"		,"N",015,2}) 
	AADD(aStru,{"BASEST"		,"N",015,2})
	AADD(aStru,{"ICMSSUBST"		,"N",015,2})	
	AADD(aStru,{"DEVOL"	    	,"N",015,2})
	AADD(aStru,{"RESSARC"		,"N",015,2})
	AADD(aStru,{"COMBUST"		,"N",015,2})
	AADD(aStru,{"IMPDEV"    	,"N",015,2})	
	AADD(aStru,{"CREDPER"   	,"N",015,2})	
	AADD(aStru,{"TOTALREC"  	,"N",015,2})	
	AADD(aStru,{"CIDADE"		,"C",030,0}) 
	AADD(aStru,{"DATAP"	    	,"C",008,2})	
	AADD(aStru,{"CONTRG1"    	,"N",006,0})	
	AADD(aStru,{"CONTRG2"    	,"N",006,0})		
	AADD(aStru,{"CONTRG3"    	,"N",006,0})	
	AADD(aStru,{"ICMCOMB"    	,"N",015,2})
	AADD(aStru,{"REF39V1"       ,"N",015,2})
	AADD(aStru,{"REF39TDIF"    	,"N",015,2})
	AADD(aStru,{"REF39TFCP"    	,"N",015,2})	
	AADD(aStru,{"REF39DA"       ,"N",015,2})
	
	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RGP")
	IndRegua("RGP",cArq,"PERIODOREF")
	AADD(aTrbs,{cArq,"RGP"})
	
	
	//Registro Anexo I	
	aStru	:= {}
	cArq	:= ""  
	AADD(aStru,{"NFISCAL"		,"C",013,0})   	
	AADD(aStru,{"SERIE"         ,"C",003,0})   
	AADD(aStru,{"IE"       	   	,"C",014,0}) 
	AADD(aStru,{"EMISSAO"    	,"C",008,0}) 
	AADD(aStru,{"ICMSDEV"    	,"N",015,2})
	AADD(aStru,{"CONTRG1"     	,"N",004,0})	
	AADD(aStru,{"SDOC"	     	,"C",003,0})	

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RG1")                      	
	IndRegua("RG1",cArq,"NFISCAL+SERIE")

	dbClearIndex()
	dbSetIndex(cArq + OrdBagExt())
	AADD(aTrbs,{cArq,"RG1"})
		
	//³Registro Anexo II	
	aStru	:= {}
	cArq	:= ""  
	AADD(aStru,{"NFISCAL"		,"C",013,0})
	AADD(aStru,{"SERIE"  		,"C",003,0})
	AADD(aStru,{"IE"       		,"C",014,0})
	AADD(aStru,{"EMISSAO"    	,"C",008,0})
	AADD(aStru,{"ICMSRES"    	,"N",015,2})
	AADD(aStru,{"CONTRG2"     	,"N",004,0})
	AADD(aStru,{"SDOC"	     	,"C",003,0})	

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RG2")                      	
	IndRegua("RG2",cArq,"NFISCAL+SERIE")
	dbClearIndex()
	dbSetIndex(cArq + OrdBagExt())
		
	AADD(aTrbs,{cArq,"RG2"})

	
	//Registro Anexo III	
	aStru	:= {}
	cArq	:= ""       
	AADD(aStru,{"IE"       		,"C",014,0}) 	//Codigo CFOP - Verificar Tabela
	AADD(aStru,{"BASE"      	,"N",015,2}) 	//Base de Calculo
	AADD(aStru,{"ICMSTR"    	,"N",015,2})	//Insentas/Nao Tributadas
	AADD(aStru,{"CONTRG3"     	,"N",004,0})	//Outras

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RG3")                      	
	IndRegua("RG3",cArq,"IE")
	AADD(aTrbs,{cArq,"RG3"})

	
	//Registro Anexo EC 87/15	
	aStru	:= {}
	cArq	:= ""       
	AADD(aStru,{"DTVENC"		,"C",008,0}) 	// Data de Vencimento do ICMS Devido à UF de Destino
	AADD(aStru,{"VALIMCS"	    ,"N",015,2}) 	// Valor do ICMS
	AADD(aStru,{"VENCFCP"	    ,"C",008,0})	// Data de Vencimento FCP
	AADD(aStru,{"VALFCP"		,"N",015,2})	// Valor do ICMS FCP

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RG4")
	IndRegua("RG4",cArq,"DTVENC")
	AADD(aTrbs,{cArq,"RG4"})

Return (aTrbs)

 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GIASTDEL    ºAutor  ³Rodrigo Zatt        º Data ³ 18.12.2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GIABRST                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Function GIASTDELE(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return
