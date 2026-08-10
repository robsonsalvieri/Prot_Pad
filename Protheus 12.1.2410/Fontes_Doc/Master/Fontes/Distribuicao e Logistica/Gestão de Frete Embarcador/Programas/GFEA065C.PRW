//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA065CDF
                 
Função que faz a preparação das variáveis para a tela de relacionamento.

Variáveis privadas necessárias para a função GFEA065C
	cTransportador : Transportador
	cTpCalc: Tipo do Cálculo (1=Normal; 2=Complementar Valor; 3=Complementar Imposto; 4=Reentrega; 5=Devolucao; 6=Redespacho; 7=Servico)
	cDataIni : Data Inicial
	cDataFim : Data Final
	nNrRomIni : Numero do romaneio inicial
	nNrRomFim : Numero do romaneio final
	cFilDocFrete : Filial do documento frete
	cEmisDF : Emissor do documento de frete
	cCdEsp : Espécie do documento de frete
	cSerDF : Série do documento de frete
	cNrDf : Número do Documento de frete
	dDataEmis : Data de emissão do documento de frete

@author 
@since 16/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA065CDF()
	Private cTransportador := GW3->GW3_EMISDF
	Private cDataIni
	Private cDataFim
	Private nNrRomIni
	Private nNrRomFim
	Private cClassRom
	Private cTORom
	Private cTPDocCar	
	Private cTipoCalculo
	Private cFilDocFrete	:= GW3->GW3_FILIAL
	Private cOrigem 		:= "GW3"
	Private cTpCalc 		:= GW3->GW3_TPDF
	Private cEmisDF 		:= GW3->GW3_EMISDF
	Private cCdEsp 			:= GW3->GW3_CDESP
	Private cSerDF 			:= GW3->GW3_SERDF
	Private cNrDf 			:= GW3->GW3_NRDF
	Private dDataEmis 		:= GW3->GW3_DTEMIS
	
	//Validações do Documento de Frete
	If !(GW3->GW3_SITFIS $ '1;6')
		Help( ,, 'HELP',, "Só é possível vincular documentos de carga, quando a situação no Fiscal estiver como Não Enviado ou Não se aplica.", 1, 0)
		Return .F.
	EndIf
	If !(GW3->GW3_SITREC $ '1;6')
		Help( ,, 'HELP',, "Só é possível vincular documentos de carga, quando a situação na Recebedoria estiver como Não Enviado ou Não se aplica.", 1, 0)
		Return .F.
	EndIf
	If !Empty(GW3->GW3_NRFAT)
		Help( ,, 'HELP',, "Só é possível vincular documentos de carga, quando o documento de frete não estiver vinculado a uma fatura.", 1, 0)
		Return .F.
	EndIf

	If Pergunte("GFEA065C")
		nNrRomIni	:= MV_PAR01
		nNrRomFim	:= MV_PAR02
		cDataIni	:= MV_PAR03
		cDataFim	:= MV_PAR04
		cClassRom	:= MV_PAR05
		cTORom		:= MV_PAR06
		cTPDocCar	:= MV_PAR07		
		//Função que faz a montagem da tela.
		GFEA065C()
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA065C
                 
Tela de vínculo do documento de carga para: Documentos de frete, EDI e CT-e

Variáveis privadas necessárias:
	cTransportador	: Transportador
	cTipoCalculo	: Tipo do Cálculo (1=Normal; 2=Complementar Valor; 3=Complementar Imposto; 4=Reentrega; 5=Devolucao; 6=Redespacho; 7=Servico)
	cDataIni
	cDataFim
	nNrRomIni
	nNrRomFim
	cTipoCalculo
	cFilDocFrete

@author 
@since 16/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA065C()
	Local nAlt := (GetScreenRes()[2] - 250)
	Local nLrg := (GetScreenRes()[1] - 100)
	Local oSize
	Local aPos

	Private aGW1View 						// Estrutura da GW1 para a viewdef
	Private aTTGW1 							// Estrutura da GW1 para a temp table
	Private cAliasGW1 	:= DefGW1Temp()	 	// Tabela temporária de dados para serem relacionados
	Private cAliGW1Rel 	:= DefGW1Temp() 	// Tabela temporária de dados relacionados.
	Private cMarca 		:= GetMark()
	Private cMarcaRel 	:= GetMark()
	Private aDocRel 	:= {}
	Private aDocRelDel	:= {}
	Private aDocCarg 	:= {}
	Private GFE65CLog 	:= GFEViewProc():New()
	
	Static oDlgDCRela
	
	GFE65CLog:EnableLog("relacionamento_docto_frete", "Relacionamento Doc Carga x Doc Frete")

	aNewButton := {}
	/* Aadd(aNewButton,{"Confirmar sem Contabilizar" ,{||GFEA065LOK(.F.), oDlgDCRela:End()}, "Confirmar sem Contabilizar", "Confirmar sem Contabilizar"}) */
	
	aGW1View := {{"Filial"			 , "GW1_FILIAL"	, "C", TamSX3("GW1_FILIAL")[1]	, 0, "!@"},;
			     {"Emissor"			 , "GW1_EMISDC"	, "C", TamSX3("GW1_EMISDC")[1]	, 0, "!@"},;
			     {"Nome Emissor"	 , "GU3_NMEMIT"	, "C", 60						, 0, "!@"},;
			     {"Série"			 , "GW1_SERDC"	, "C", TamSX3("GW1_SERDC")[1]	, 0, "!@"},;
			     {"Número"			 , "GW1_NRDC" 	, "C", TamSX3("GW1_NRDC")[1]	, 0, "!@"},;
			     {"Tipo do Documento", "GW1_CDTPDC"	, "C", TamSX3("GW1_CDTPDC")[1]	, 0, "!@"},;
			     {"Romaneio"		 , "GW1_NRROM"	, "C", TamSX3("GW1_NRROM")[1]	, 0, "!@"}}
	
	Processa({|| RunProc()}, "Carregando informações...") //Chama a função de carregamento das informações.
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000,000, nAlt,nLrg})
	oSize:lLateral     := .F.  						// Calculo vertical	
	oSize:Process() 								// Executa os calculos
	
	// Array com as posições dinamicas se quiser alterar o tamnho da tela é so alterar o tamanho do SetWindowSize
	aPos := {oSize:GetDimension("ENCHOICE","LININI"),; 
            oSize:GetDimension("ENCHOICE","COLINI"),;
            oSize:GetDimension("ENCHOICE","XSIZE"),;
            oSize:GetDimension("ENCHOICE","YSIZE")}
	
	DEFINE MSDIALOG oDlgDCRela TITLE "Relacionamento de Documentos de Carga" ;
		FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
		TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
		Of oMainWnd COLORS 0, 16777215 PIXEL	

	/* -- Layers -- */
	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgDCRela, .F., .T.)
	
	// Documento de Carga
	oFWLayer:AddLine('TOP', 50, .F.)
	oFWLayer:AddCollumn('DOCTOCARGA', 100, .T., 'TOP') 
	oLayerDC := oFWLayer:GetColPanel('DOCTOCARGA', 'TOP')
	
	// Documentos de carga relacionados
	oFWLayer:AddLine('BOTTON', 45, .F.) 
	oFWLayer:AddCollumn('DOCTOCARGAREL', 100, .T., 'BOTTON') 
	oLayerDCRel := oFWLayer:GetColPanel('DOCTOCARGAREL', 'BOTTON')

	//Browse dos Documentos de carga à relacionar	
	oMarkDC := FWMarkBrowse():New()
	oMarkDC:SetOwner(oLayerDC)
	oMarkDC:SetDescription("Documentos de Carga")
	oMarkDC:SetTemporary(.T.)
	oMarkDC:SetAlias(cAliasGW1)
	oMarkDC:SetFields(aGW1View)
	oMarkDC:SetFieldMark("OK")
	oMarkDC:ForceQuitButton(.F.)
	oMarkDC:SetAmbiente(.F.)
	oMarkDC:SetWalkthru(.F.)
	oMarkDC:DisableReport()
	oMarkDC:DisableSaveConfig()
	oMarkDC:DisableConfig()
	oMarkDC:GetFilterDefault()
	oMarkDC:DisableDetails()
	oMarkDC:SetMenuDef("")
	oMarkDC:SetAllMark({|| GFE65CALMK()})
	oMarkDC:SetCustomMarkRec({|| GFE65CMK()})
	oMarkDC:AddButton('Selecionar Todos',{|| GFE65CALMK()},,2,,.F.)
	oMarkDC:AddButton('Filtrar',{|| GFE65CFIL()},,2,,.F.)
	oMarkDC:AddButton('Adicionar',{|| GFE65CADD()},,2,,.F.)
   	oMarkDC:Activate() 
   
   //Browse dos documentos de carga relacionados.
   	oMarkDCRel := FWMarkBrowse():New()
	oMarkDCRel:SetOwner(oLayerDCRel)
	oMarkDCRel:SetDescription("Documentos de Carga Relacionados")
	oMarkDCRel:SetTemporary(.T.)
	oMarkDCRel:SetAlias(cAliGW1Rel)
	oMarkDCRel:SetFields(aGW1View)
	oMarkDCRel:SetFieldMark("OK")
	oMarkDCRel:ForceQuitButton(.F.)
	oMarkDCRel:SetAmbiente(.F.)
	oMarkDCRel:SetWalkthru(.F.)
	oMarkDCRel:DisableReport()
	oMarkDCRel:DisableSaveConfig()
	oMarkDCRel:DisableConfig()
	oMarkDCRel:DisableDetails()
	oMarkDCRel:GetFilterDefault()
	oMarkDCRel:SetMenuDef("")
	oMarkDCRel:SetAllMark({|| GFE65CAMKR()})
	oMarkDCRel:SetCustomMarkRec({|| GFE65CMKR()})
	oMarkDCRel:AddButton('Selecionar Todos',{|| GFE65CAMKR()},,2,,.F.)
	oMarkDCRel:AddButton('Remover',{|| GFE65CREM()},,2,,.F.)
   	oMarkDCRel:Activate() 
	
	ACTIVATE MSDIALOG oDlgDCRela ON INIT EnchoiceBar(oDlgDCRela,{||If(GFEA065LOK(.T.),oDlgDCRela:End(),NIL)},{||oDlgDCRela:End()},,aNewButton) CENTERED 
	
	GFEDelTab(cAliasGW1)
	GFEDelTab(cAliGW1Rel)
	aSize(aDocRel, 0)
	aSize(aDocCarg, 0)
	
Return .T.



Function RunProc()

	//Carrega Documentos de carga
	ProcRegua(1)
	CarDocCarga()
	
	//CarregaDocumentos de carga relacionados ao Documento de Frete
	ProcRegua(2)
	CarDocRelac()
	
Return



Function GFEA065LOK(lContabilizar)
	Local lRet := .T.
	If cOrigem == "GW3"
		Processa({|| lRet := GFEA065OK()}, "Vinculando documentos de carga...")
	EndIf
Return lRet


//Abre o model em edição para relacionar os novos documentos de carga.
Function GFEA065OK()
	Local nI
	Local nCountRel := Len(aDocRel)
	Local nCountDel := Len(aDocRelDel)
	Local aRetRateio := {}
	Local lAlterado := .F.
	Private cMotBloq := ""
	
	If nCountRel < 1
		Help( ,, 'HELP',, "É necessário ter pelo menos um documento de carga vinculado.", 1, 0)
		Return .F.
	EndIf
	
	GFE65CLog:Add("Filial: " + cFilDocFrete + ", Emissor: " + cEmisDF + ", Serie: " + AllTrim(cSerDf) + ", Doc: " + cNrDf)
	GFE65CLog:Add("")
	
	ProcRegua(nCountDel)
	
	GFE65CLog:Add("Documentos Eliminados:")
	
	For nI := 1 To nCountDel
		IncProc("Eliminando Documentos: " + cValToChar(nI) + "/" + cValToChar(nCountDel))
		dbSelectArea("GW4")
		dbSetOrder(1) // GW4_FILIAL+GW4_EMISDF+GW4_CDESP+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS)+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC
		If dbSeek(cFilDocFrete + cEmisDF + cCdEsp + cSerDf + cNrDf + DTOS(dDataEmis) + aDocRelDel[nI])
			GFE65CLog:Add("> Série: " + Alltrim(GW4->GW4_SERDC) + ", Doc Nr: " + Alltrim(GW4->GW4_NRDC), 2)
			lAlterado := .T.
			RecLock("GW4", .F.)
				dbDelete()
			MsUnlock()
		EndIf
	Next
	
	GFE65CLog:Add("")
	
	ProcRegua(nCountRel)
	
	GFE65CLog:Add("Documentos Relacionados:")
	
	For nI := 1 To nCountRel
		IncProc("Vinculando Documentos: " + cValToChar(nI) + "/" + cValToChar(nCountRel))
		dbSelectArea("GW4")
		dbSetOrder(1) // GW4_FILIAL+GW4_EMISDF+GW4_CDESP+GW4_SERDF+GW4_NRDF+DTOS(GW4_DTEMIS)+GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC
		If !dbSeek(cFilDocFrete + cEmisDF + cCdEsp + cSerDf + cNrDf + DTOS(dDataEmis) + aDocRel[nI][2] + aDocRel[nI][3] + aDocRel[nI][4] + aDocRel[nI][5])
			GFE65CLog:Add("> Série: " + Alltrim(aDocRel[nI][3]) + ", Doc Nr: " + Alltrim(aDocRel[nI][4]), 2)
			lAlterado := .T.
			RecLock("GW4", .T.)
				GW4->GW4_FILIAL	:= cFilDocFrete
				GW4->GW4_EMISDF	:= cEmisDF
				GW4->GW4_CDESP	:= cCdEsp
				GW4->GW4_SERDF	:= cSerDf
				GW4->GW4_NRDF	:= cNrDf
				GW4->GW4_DTEMIS	:= dDataEmis
				GW4->GW4_EMISDC	:= aDocRel[nI][2]
				GW4->GW4_SERDC	:= aDocRel[nI][3]
				GW4->GW4_NRDC	:= aDocRel[nI][4]
				GW4->GW4_TPDC	:= aDocRel[nI][5]
			MsUnlock()
		EndIf
	Next
	
	GFE65CLog:Add("")
	
	If lAlterado
		IncProc("Conferindo documento de frete")
		
		Conferencia()
		
		If SuperGetMV("MV_TPGERA",,"2") == "1"	
			ProcRegua(0)
			IncProc("Gerando grade contábil")
			aRetRateio := GFERatDF( .F., cCdEsp, cEmisDF, cSerDf, cNrDf, dDataEmis)
		    If aRetRateio[1] == .F.
		    	GFE65CLog:AddErro("Erro ao contabilizar documento de frete:")
		    	GFE65CLog:AddErro(aRetRateio[2])
		    EndIf
		EndIf
	Else
		GFE65CLog:Add("")
		GFE65CLog:Add("NENHUM DOCUMENTO RELACIONADO OU REMOVIDO!")
	EndIf
	
	GFE65CLog:Show("Relacionamento Doc Carga", "Processo Finalizado", "Detalhes", " Documento de Frete Atualizado! Clique no botão 'Detalhes' para mais detalhes.")
	
	oMarkDC:Refresh()
	oMarkDCRel:Refresh()
	oMarkDC:GoTop()
	oMarkDCRel:GoTop()
Return .T.


/*----------------------------------------------------------------------------------------------------
{Protheus.doc} Conferencia
Faz a conferência dos documentos relacionados, verificando nos cálculos se todas os documentos foram vinculados.
Uso Interno.

@Conferencia
GFEA065()

@author Israel A Possoli
@since 30/03/15
@version 1.0
------------------------------------------------------------------------------------------------------*/
Function Conferencia()
	Local oModelGW3 := FWLoadModel("GFEA065")
	Local lAprovado := .T.
	Local lAprovMLA := SuperGetMv("MV_ERPGFE",.F.,"1") == "1" .And. SuperGetMv("MV_DFMLA",.F.,"1") $ "2|3"
	Private nVlDiver := 0
	
	oModelGW3:SetOperation( 4 )
	oModelGW3:Activate()
	
	lAprovado := GFEA065CO(oModelGW3)
	
	RecLock("GW3", .F.)
		If lAprovado
			GW3->GW3_SIT	:= "3"
			GW3->GW3_USUBLQ := ""
			GW3->GW3_MOTBLQ	:= ""
			GW3->GW3_MOTREC	:= ""
			GW3->GW3_MOTFIS	:= ""
			GW3->GW3_DTAPR	:= DDATABASE
		Else
			GW3->GW3_SIT		:= "2"
			GW3->GW3_USUBLQ := cUserName
		   	GW3->GW3_MOTBLQ	:= cMotBloq
			GW3->GW3_DTBLQ	:= DDATABASE
			
			GW3->GW3_MOTAPR	:= ""
			GW3->GW3_DTAPR	:= CtoD('  /  /  ')
			GW3->GW3_USUAPR	:= ""
		EndIf
		If GFXCP12127("GW3_VLDIV")
			GW3->GW3_VLDIV := nVlDiver
		Endif
		
		If GfeVerCmpo({"GW3_SITMLA","GW3_MOTMLA"})
			If lAprovMLA
				If GW3->GW3_SITMLA == "7"
					GW3->GW3_SITMLA := "8" /* Atualizar registro no mla */ 
				Else
					GW3->GW3_SITMLA := "2" /*Pendente Atualização */
					GW3->GW3_MOTMLA := ""
				EndIf
			Else
				GW3->GW3_SITMLA := "6" /* Não se aplica. */ 
				GW3->GW3_MOTMLA := ""
			EndIf
		EndIf
	MsUnlock()
	oModelGW3:Destroy()
	FreeObj(oModelGW3)
	Return lAprovado
	
	/* ------------------------------------------
	   Conferência sem Model
	   ------------------------------------------
	
	Local nI		:= 0
	Local lRet 		:= .T.
	Local aCalcRel	:= {}

	dbSelectArea("GW4")
	dbSetOrder(1)
	dbSeek(cFilDocFrete + cEmisDF + cCdEsp + cSerDF + cNrDf + DTOS(dDataEmis))
	While !GW4->(Eof()) .AND. ;
		   GW4->GW4_FILIAL == cFilDocFrete 	.AND. ;
		   GW4->GW4_EMISDF == cEmisDF		.AND. ;
		   GW4->GW4_CDESP  == cCdEsp		.AND. ;
		   GW4->GW4_SERDF  == cSerDF		.AND. ;
		   GW4->GW4_NRDF   == cNrDf			.AND. ;
		   GW4->GW4_DTEMIS == dDataEmis
		   
		dbSelectArea("GWH")
		dbSetOrder(2)
		dbSeek(GW4->GW4_FILIAL + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC)
		While !GWH->(Eof()) .AND. ;
		       GWH->GWH_FILIAL	== GW4->GW4_FILIAL 	.AND. ;
		       GWH->GWH_CDTPDC	== GW4->GW4_TPDC 	.AND. ;
		       GWH->GWH_EMISDC 	== GW4->GW4_EMISDC 	.AND. ;
		       GWH->GWH_SERDC 	== GW4->GW4_SERDC 	.AND. ;
		       GWH->GWH_NRDC 	== GW4->GW4_NRDC
		       
			If AScan(aCalcRel, {|x| x == GWH->GWH_NRCALC}) <= 0
				AAdd(aCalcRel, GWH->GWH_NRCALC)
			Else
				dbSelectArea("GWH")
				GWH->(dbSkip())
				Loop
			EndIf		       
		       
			GWH->(dbSkip())
		EndDo
	
		GW4->(dbSkip())
	EndDo
	
    For nI := 1 To Len(aCalcRel)
    	dbSelectArea("GWH")
    	dbSetOrder(1)
    	dbSeek(cFilDocFrete + aCalcRel[nI])
    	While !GWH->(Eof()) .AND. GWH->GWH_NRCALC == aCalcRel[nI]
			If aScan(aDocRel, {|x| x[8] == GWH->GWH_FILIAL + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC + GWH->GWH_CDTPDC}) <= 0
    			lRet 	 := .F.
    			cMotBloq := " Nem todos os Documentos de Carga do Cálculo " + GWH->GWH_NRCALC + " foram relacionados ao Documento de Frete."
    			Exit
    		EndIf

    		dbSelectArea("GWH")
    		GWH->(dbSkip())
    	EndDo

    	If !lRet
    		Exit
    	EndIf
    Next nI
    */
    
Return(lRet)



//Marca o registro do documento de carga.
Function GFE65CMK()

	//dbSelectArea(cAliasGW1) 
	//(cAliasGW1)->( dbSetOrder(2) )     
	If ((cAliasGW1)->OK <> oMarkDC:Mark())
		RecLock(cAliasGW1, .F.)
			(cAliasGW1)->OK := oMarkDC:Mark()
		MsUnlock()
	ElseIf ((cAliasGW1)->OK == oMarkDC:Mark())
		RecLock(cAliasGW1, .F.)
			(cAliasGW1)->OK := "  "
		MsUnlock()
	EndIf
	
	oMarkDC:Refresh()
	//oMarkDC:GoTop()

Return

//Filtra os registros do documento de carga.
Function GFE65CFIL()

	If Pergunte("GFEA065C")
	
		nNrRomIni 	 := MV_PAR01
		nNrRomFim 	 := MV_PAR02
		cDataIni 	 := MV_PAR03
		cDataFim 	 := MV_PAR04
		//cTipoCalculo := MV_PAR05	
		cClassRom	:= MV_PAR05
		cTORom		:= MV_PAR06
		cTPDocCar	:= MV_PAR07			
		dbSelectArea(cAliasGW1)
		(cAliasGW1)->( dbSetorder(1) )
		ZAP
		
		CarDocCarga()
		
		oMarkDC:Refresh()
		oMarkDC:GoTop()
		oMarkDC:Refresh()
		
	EndIf

Return

//Marca todos os registros do documento de carga.
Function GFE65CALMK()
	
	oMarkDC:GoTop()
	
	dbSelectArea(cAliasGW1)
	dbSetOrder(1)
	(cAliasGW1)->( dbGoTop() )
	
	While !(cAliasGW1)->( Eof() )
		If ((cAliasGW1)->OK <> oMarkDC:Mark())
			RecLock(cAliasGW1, .F.)
				(cAliasGW1)->OK := oMarkDC:Mark()
			MsUnlock()
		ElseIf ((cAliasGW1)->OK == oMarkDC:Mark())
			RecLock(cAliasGW1, .F.)
				(cAliasGW1)->OK := "  "
			MsUnlock()
		EndIf
		(cAliasGW1)->( dbSkip() ) 
	EndDo
	
	oMarkDC:Refresh()
	oMarkDC:GoTop()
	oMarkDC:Refresh()

Return

//Marca o registro do documento de carga relacionado
Function GFE65CMKR()

	dbSelectArea(cAliGW1Rel)
	(cAliGW1Rel)->( dbSetOrder(1) )       
	If ((cAliGW1Rel)->OK <> oMarkDCRel:Mark())
		RecLock(cAliGW1Rel, .F.)
			(cAliGW1Rel)->OK := oMarkDCRel:Mark()
		MsUnlock()
	ElseIf ((cAliGW1Rel)->OK == oMarkDCRel:Mark())
		RecLock(cAliGW1Rel, .F.)
			(cAliGW1Rel)->OK := "  "
		MsUnlock()
	EndIf
	
	oMarkDCRel:Refresh()
	oMarkDCRel:GoTop()
	oMarkDCRel:Refresh()
	
Return

//Marca todos os registros do documento de carga relacionado
Function GFE65CAMKR()
	
	dbSelectArea(cAliGW1Rel)
	dbSetOrder(1)
	(cAliGW1Rel)->( dbGoTop() )
	
	While !(cAliGW1Rel)->( Eof() )
		If ((cAliGW1Rel)->OK <> oMarkDCRel:Mark())
			RecLock(cAliGW1Rel, .F.)
				(cAliGW1Rel)->OK := oMarkDCRel:Mark()
			MsUnlock()
		ElseIf ((cAliGW1Rel)->OK == oMarkDCRel:Mark())
			RecLock(cAliGW1Rel, .F.)
				(cAliGW1Rel)->OK := "  "
			MsUnlock()
		EndIf
		dbSkip() 
	EndDo
	
	oMarkDCRel:Refresh()
	oMarkDCRel:GoTop()
	oMarkDCRel:Refresh()

Return

//Remove os registros marcados do documento de frete
Function GFE65CREM()

	oMarkDC:GoTop()
	oMarkDCRel:GoTop()
	
	dbSelectArea(cAliGW1Rel)
	(cAliGW1Rel)->( dbSetOrder(1) )
	(cAliGW1Rel)->( dbGoTop() )
	While !(cAliGW1Rel)->( Eof() )
	
		If (cAliGW1Rel)->OK == oMarkDCRel:Mark()
		
			dbSelectArea(cAliasGW1)
			(cAliasGW1)->( dbSetOrder(1) )
			If !(cAliasGW1)->( dbSeek((cAliGW1Rel)->GW1_FILIAL+(cAliGW1Rel)->GW1_EMISDC+(cAliGW1Rel)->GW1_SERDC+(cAliGW1Rel)->GW1_NRDC) )	
			
				RecLock(cAliasGW1, .T.)
					(cAliasGW1)->GW1_FILIAL := (cAliGW1Rel)->GW1_FILIAL
					(cAliasGW1)->GW1_EMISDC := (cAliGW1Rel)->GW1_EMISDC
					(cAliasGW1)->GU3_NMEMIT := (cAliGW1Rel)->GU3_NMEMIT
					(cAliasGW1)->GW1_SERDC := (cAliGW1Rel)->GW1_SERDC
					(cAliasGW1)->GW1_NRDC := (cAliGW1Rel)->GW1_NRDC
					(cAliasGW1)->GW1_CDTPDC := (cAliGW1Rel)->GW1_CDTPDC
					(cAliasGW1)->GW1_NRROM := (cAliGW1Rel)->GW1_NRROM
				MsUnlock()
				
				aAdd(aDocCarg, {(cAliasGW1)->GW1_FILIAL,;
								(cAliasGW1)->GW1_EMISDC,;
								(cAliasGW1)->GW1_SERDC,;
								(cAliasGW1)->GW1_NRDC,;
								(cAliasGW1)->GW1_CDTPDC,;
								(cAliasGW1)->GW1_NRROM,;
								(cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC+(cAliasGW1)->GW1_CDTPDC})
								
								
				If aScan(aDocRelDel, (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + (cAliasGW1)->GW1_CDTPDC) <= 0
					// GW4_EMISDC+GW4_SERDC+GW4_NRDC+GW4_TPDC
					aAdd(aDocRelDel, (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + (cAliasGW1)->GW1_CDTPDC)
				EndIf
			
				nPos := aScan( aDocRel, { |x| x[7] == (cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC+(cAliasGW1)->GW1_CDTPDC } )
				If nPos > 0
					aDel(aDocRel, nPos)
					aSize(aDocRel, Len(aDocRel) - 1)
				EndIf
			
			
			EndIf
			
			RecLock(cAliGW1Rel, .F.)
				(cAliGW1Rel)->( dbDelete() )
			MsUnlock()
			
		EndIf
	
	(cAliGW1Rel)->( dbSkip() )
	EndDo

	oMarkDC:Refresh()
	oMarkDC:GoTop()
	oMarkDC:Refresh()
	
	oMarkDCRel:Refresh()
	oMarkDCRel:GoTop()
	oMarkDCRel:Refresh()

Return

//Adiciona o Documento de Carga ao documento de frete
Function GFE65CADD()

	Local nPos

	dbSelectArea(cAliasGW1)
	(cAliasGW1)->( dbGoTop() )
	While !(cAliasGW1)->( Eof() )
	
		If (cAliasGW1)->OK == oMarkDC:Mark()
		
			dbSelectArea(cAliGW1Rel)
			(cAliGW1Rel)->( dbSetOrder(1) )
			If !(cAliGW1Rel)->( dbSeek((cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC) )
			
				RecLock(cAliGW1Rel, .T.)
					(cAliGW1Rel)->GW1_FILIAL := (cAliasGW1)->GW1_FILIAL
					(cAliGW1Rel)->GW1_EMISDC := (cAliasGW1)->GW1_EMISDC
					(cAliGW1Rel)->GU3_NMEMIT := (cAliasGW1)->GU3_NMEMIT
					(cAliGW1Rel)->GW1_SERDC := (cAliasGW1)->GW1_SERDC
					(cAliGW1Rel)->GW1_NRDC := (cAliasGW1)->GW1_NRDC
					(cAliGW1Rel)->GW1_CDTPDC := (cAliasGW1)->GW1_CDTPDC
					(cAliGW1Rel)->GW1_NRROM := (cAliasGW1)->GW1_NRROM
				MsUnlock()
				
				aAdd(aDocRel, {(cAliGW1Rel)->GW1_FILIAL,;
								(cAliGW1Rel)->GW1_EMISDC,;
								(cAliGW1Rel)->GW1_SERDC,;
								(cAliGW1Rel)->GW1_NRDC,;
								(cAliGW1Rel)->GW1_CDTPDC,;
								(cAliGW1Rel)->GW1_NRROM,;
								(cAliGW1Rel)->GW1_FILIAL+(cAliGW1Rel)->GW1_EMISDC+(cAliGW1Rel)->GW1_SERDC+(cAliGW1Rel)->GW1_NRDC+(cAliGW1Rel)->GW1_CDTPDC })
								
				nPos := aScan(aDocRelDel, (cAliasGW1)->GW1_EMISDC + (cAliasGW1)->GW1_SERDC + (cAliasGW1)->GW1_NRDC + (cAliasGW1)->GW1_CDTPDC)
				If nPos > 0
					aDel(aDocRelDel, nPos)
					aSize(aDocRelDel, Len(aDocRelDel) - 1)
				EndIf
			
				nPos := aScan( aDocCarg, { |x| x[7] == (cAliGW1Rel)->GW1_FILIAL+(cAliGW1Rel)->GW1_EMISDC+(cAliGW1Rel)->GW1_SERDC+(cAliGW1Rel)->GW1_NRDC+(cAliGW1Rel)->GW1_CDTPDC } )
				If nPos > 0
					aDel(aDocCarg, nPos)
					aSize(aDocCarg, Len(aDocCarg) - 1)
				EndIf
			
			EndIf
			
			RecLock(cAliasGW1, .F.)
				(cAliasGW1)->( dbDelete() )
			MsUnlock()
			
		EndIf
	
	(cAliasGW1)->( dbSkip() )
	EndDo

	oMarkDC:Refresh()
	oMarkDC:GoTop()
	oMarkDC:Refresh()
	
	oMarkDCRel:Refresh()
	oMarkDCRel:GoTop()
	oMarkDCRel:Refresh()

Return

Function DefGW1Temp()

	aTTGW1 :={{"OK"         , "C", 02, 0},;
			  {"GW1_FILIAL" , "C", TamSX3("GW1_FILIAL")[1], 0},;
			  {"GW1_EMISDC" , "C", TamSX3("GW1_EMISDC")[1], 0},;
			  {"GU3_NMEMIT" , "C", TamSX3("GU3_NMEMIT")[1], 0},;
			  {"GW1_SERDC"  , "C", TamSX3("GW1_SERDC")[1], 0},;
			  {"GW1_NRDC"   , "C", TamSX3("GW1_NRDC")[1], 0},;
			  {"GW1_CDTPDC" , "C", TamSX3("GW1_CDTPDC")[1], 0},;
			  {"GW1_NRROM"  , "C", TamSX3("GW1_NRROM")[1], 0}}
	
Return GFECriaTab({aTTGW1, {"GW1_FILIAL+GW1_EMISDC+GW1_SERDC+GW1_NRDC", "OK"}})

Function CarDocRelac()

	Local cQuery := ""

	cQuery := "SELECT '  ' AS OK, GW1.GW1_FILIAL, GW1.GW1_EMISDC, GU3.GU3_NMEMIT, GW1.GW1_SERDC, GW1.GW1_NRDC, " 
	cQuery += " GW1.GW1_CDTPDC, GW1.GW1_NRROM, GW1.R_E_C_N_O_" 
	cQuery += "FROM " + RetSQLName("GW1") + " GW1 " 
	cQuery += "INNER JOIN " + RetSQLName("GW4") + " GW4 ON "
	cQuery += "	GW4.GW4_FILIAL = GW1.GW1_FILIAL AND " 
	cQuery += "	GW4.GW4_SERDC  = GW1.GW1_SERDC	AND "
	cQuery += "	GW4.GW4_NRDC   = GW1.GW1_NRDC	AND "
	cQuery += "	GW4.GW4_EMISDC = GW1.GW1_EMISDC "
	cQuery += "INNER JOIN " + RetSQLName("GU3") + " GU3 ON "
	cQuery += "	GU3.GU3_FILIAL = '" + xFilial("GU3") + "' AND "
	cQuery += "	GU3.GU3_CDEMIT = GW1.GW1_EMISDC "
	cQuery += "WHERE GW4.GW4_EMISDF = '" + cEmisDF + "' AND "
	cQuery += "	GW4.GW4_CDESP = '" + cCdEsp + "' AND "
	cQuery += "	GW4.GW4_FILIAL = '" + cFilDocFrete + "' AND "
	cQuery += "	GW4.GW4_SERDF  = '" + cSerDF + "' AND "
	cQuery += "	GW4.GW4_NRDF   = '" + cNrDf + "' AND	"
	cQuery += "	GW4.GW4_DTEMIS  = '" + DtoS(dDataEmis) + "' AND "
	cQuery += "	GW1.D_E_L_E_T_ = '' AND "
	cQuery += "	GW4.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	
	SqlToTrb(cQuery, aTTGW1, cAliGW1Rel)
	
	dbSelectArea(cAliGW1Rel)
	(cAliGW1Rel)->(dbGoTop())
	While !(cAliGW1Rel)->(Eof() )
		
		aAdd(aDocRel, {(cAliGW1Rel)->GW1_FILIAL,;
						(cAliGW1Rel)->GW1_EMISDC,;
						(cAliGW1Rel)->GW1_SERDC,;
						(cAliGW1Rel)->GW1_NRDC,;
						(cAliGW1Rel)->GW1_CDTPDC,;
						(cAliGW1Rel)->GW1_NRROM,;
						(cAliGW1Rel)->GW1_FILIAL+(cAliGW1Rel)->GW1_EMISDC+(cAliGW1Rel)->GW1_SERDC+(cAliGW1Rel)->GW1_NRDC+(cAliGW1Rel)->GW1_CDTPDC,;
						"OK" })
	
		(cAliGW1Rel)->(dbSkip())
	EndDo

Return

Function CarDocCarga()
	Local cQuery   := ""
	
	cQuery := " SELECT '  ' AS OK,  GW1.GW1_FILIAL, GW1.GW1_EMISDC, GU3.GU3_NMEMIT, GW1.GW1_SERDC, GW1.GW1_NRDC, GW1.GW1_CDTPDC, GW1.GW1_NRROM, GW1.R_E_C_N_O_"
	cQuery += " FROM " + RetSQLName("GW1") + " GW1 "
	cQuery += " INNER JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = GW1.GW1_FILIAL "
	cQuery += " 												AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC "
	cQuery += " 												AND GWU.GWU_EMISDC = GW1.GW1_EMISDC"
	cQuery += " 												AND GWU.GWU_SERDC = GW1.GW1_SERDC"
	cQuery += " 												AND GWU.GWU_NRDC = GW1.GW1_NRDC"
	cQuery += " 												AND GWU.GWU_CDTRP = '" + cTransportador + "'"
	cQuery += " 												AND GWU.GWU_PAGAR = '1'"
	cQuery += " 												AND GWU.D_E_L_E_T_ = ''"
	cQuery += " INNER JOIN " + RetSQLName("GWN") + " GWN"
	If GFXCP1212210('GW1_FILROM')
		cQuery += " ON GWN.GWN_FILIAL = GW1.GW1_FILROM"
	Else
		cQuery += " ON GWN.GWN_FILIAL = GW1.GW1_FILIAL"
	EndIf
	cQuery += " AND GWN.gwn_nrrom = GW1.gw1_nrrom "
	cQuery += " AND GWN.gwn_sit = '3' "
	cQuery += " AND GWN.gwn_dtimpl >= '" + DToS(cDataIni) + "' "
	cQuery += " AND GWN.gwn_dtimpl <= '" + DToS(cDataFim) + "' "
	If !empty(cClassRom) 
		cQuery += " 												AND GWN.GWN_CDCLFR = '" + cClassRom + "' "
	EndIf
	If !empty(cTORom) 	
		cQuery += " 												AND GWN.GWN_CDTPOP = '" + cTORom + "' "	
	Endif
	cQuery += " 												AND GWN.d_e_l_e_t_ = '' "
	cQuery += " INNER JOIN " + RetSQLName("GU3") + " GU3 ON GU3.gu3_filial = '' "
	cQuery += " 												AND GU3.gu3_cdemit = GW1.gw1_emisdc 	"
	cQuery += " 												AND GU3.D_E_L_E_T_ = ''"
	cQuery += " LEFT JOIN " + RetSQLName("GWH") + " GWH ON GWH.gwh_filial = GW1.gw1_filial "
	cQuery += " 											  AND GWH.gwh_serdc  = GW1.gw1_serdc "
	cQuery += " 											  AND GWH.gwh_nrdc   = GW1.gw1_nrdc "
	cQuery += " 											  AND GWH.gwh_emisdc = GW1.gw1_emisdc "
	cQuery += " 											  AND GWH.d_e_l_e_t_ = '' "
	cQuery += " LEFT JOIN " + RetSQLName("GWF") + " GWF ON GWF.gwf_filial = GWH.gwh_filial "
	cQuery += " 											  AND GWF.gwf_nrcalc = GWH.gwh_nrcalc "
	cQuery += " 											  AND GWF.gwf_transp = GWU.GWU_CDTRP"
	cQuery += " 											  AND GWF.GWF_SEQTRE = GWU.GWU_SEQ"
	cQuery += " 											  AND GWF.d_e_l_e_t_ = '' "
	cQuery += " LEFT JOIN " + RetSQLName("GW4") + " GW4 ON GW4.gw4_filial = GW1.gw1_filial "
	cQuery += " 											AND GW4.gw4_nrdc = GW1.gw1_nrdc "
	cQuery += " 											AND GW4.gw4_tpdc = GW1.gw1_cdtpdc "
	cQuery += " 											AND GW4.gw4_serdc = GW1.gw1_serdc "
	cQuery += " 											AND GW4.gw4_emisdc = GW1.gw1_emisdc"
	cQuery += " 											AND GW4.GW4_EMISDF = GWU.GWU_CDTRP"
	cQuery += " 											AND GW4.d_e_l_e_t_ = ' ' "		              
	cQuery += " LEFT JOIN " + RetSQLName("GW3") + " GW3 ON GW3.gw3_nrdf = GW4.gw4_nrdf "  
	cQuery += " 											AND GW3.gw3_filial = GW4.gw4_filial" 
	cQuery += " 											AND GW3.gw3_cdesp = GW4.gw4_cdesp" 
	cQuery += " 											AND GW3.gw3_emisdf = GW4.GW4_EMISDF " 
	cQuery += " 											AND GW3.gw3_dtemis = GW4.gw4_dtemis" 
	cQuery += " 											AND GW3.d_e_l_e_t_ = '' " 
	cQuery += " WHERE GW1.gw1_filial = '" + cFilDocFrete + "' " 
	cQuery += " AND GW1.gw1_nrrom >= '" + nNrRomIni + "'  " 
	cQuery += " AND GW1.gw1_nrrom <= '" + nNrRomFim + "'  " 
	If !empty(cTPDocCar) 
		cQuery += " AND GW1.GW1_CDTPDC = '" + cTPDocCar + "'  "	
	EndIf
	cQuery += " AND GW1.D_E_L_E_T_ = '' " 
	cQuery += " AND (GWH.GWH_NRDC IS NULL OR (GWH.GWH_NRDC IS NOT NULL AND GWF.GWF_NRCALC IS NOT NULL))" 
	cQuery += " AND (GW4.GW4_NRDC IS NULL OR (GW4.GW4_NRDC IS NOT NULL AND GW3.GW3_NRDF IS NOT NULL AND GW3.GW3_TPDF != '" + cTpCalc + "'))" 
	If SuperGetMV("MV_OBNENT",,"1") == "1"
		cQuery += "  AND GWF.GWF_NRCALC IS NOT NULL " 
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	
	SqlToTrb(cQuery, aTTGW1, cAliasGW1) 

	dbSelectArea(cAliasGW1)
	(cAliasGW1)->(dbGoTop())
	While !(cAliasGW1)->(Eof() )
		
		aAdd(aDocCarg, {(cAliasGW1)->GW1_FILIAL,;
						(cAliasGW1)->GW1_EMISDC,;
						(cAliasGW1)->GW1_SERDC,;
						(cAliasGW1)->GW1_NRDC,;
						(cAliasGW1)->GW1_CDTPDC,;
						(cAliasGW1)->GW1_NRROM,;
						(cAliasGW1)->GW1_FILIAL+(cAliasGW1)->GW1_EMISDC+(cAliasGW1)->GW1_SERDC+(cAliasGW1)->GW1_NRDC+(cAliasGW1)->GW1_CDTPDC})
						
		(cAliasGW1)->(dbSkip())
	EndDo
	
Return
