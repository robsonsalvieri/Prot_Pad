#INCLUDE "GFEA065.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//--------------------------------------------------------------------
/*{Protheus.doc} GFEA065B
	 
@author Alan Victor Lamb
@since 15/10/2013
@version 1.0		

@return Nil

@description
Função para incluir documento de frete a partir do documento de carga selecionado.

@example  
GFEA065B()
/*/
Function GFEA065B(cTpIclu)
	Local oDlg
	Local oLabel, oCombo, oButton, oGet, oSay, oGroup, oPanel, oPnl
	Local aTPDF 		:= StrTokArr(Posicione("SX3",2,"GW3_TPDF","X3_CBOX"),';')
	Local aTributacao	:= StrTokArr(Posicione("SX3",2,"GW3_TRBIMP","X3_CBOX"),';')
	Local aTPCTE 		:= StrTokArr(" ;" + Posicione("SX3",2,"GW3_TPCTE","X3_CBOX"),';')
	Local aEspecies 	:= GetEspecies()
	Local nLineSpace 	:= 11
	Local nLeft 		:= 005
	Local aButtons		:= {{"",{|| GFEA065B06_AddDC() },"Adicionar Docto"}, {"",{|| GFEA065B09_SellAll() },"Selecionar Todos"}}
	Local oSize
	Local lIsDark		:= GfeDark()
	Private lCpoSDoc	:= GfeVerCmpo({"GW1_SDOC"})
	Private lChaveUnica	:= TamSX3("GW1_SERDC")[1] == 14
	Private aEmissores
	Private oNo 		:= LoadBitmap(GetResources(), "LBNO")
	Private oOk 		:= LoadBitmap(GetResources(), "LBTIK")
	Private cCdRem
	Private cCdDest
	Private xGW3TPDF 	:= ""
	Private xEspecie 	:= ""
	Private xTribut		:= ""
	Private dDtEmiss
	Private cSerieDF 	:= Space(TamSX3("GW3_SERDF")[1])
	Private cNrDoc		:= Space(TamSX3("GW3_NRDF")[1])
	Private cCdTrp
	Private nValor		:= 0 // Valor Docto
	Private nTaxas		:= 0 // Taxas
	Private nPedagio	:= 0 // Vl Pedagio
	Private nBaseImp	:= 0 // Base Imposto
	Private nAliqImp	:= 0 //Aliq Impsoto
	Private nVlImp		:= 0 //Vl Imposto
	Private cCFOP		:= Space(TamSX3("GW3_CFOP")[1])
	Private cCTE		:= Space(TamSX3("GW3_CTE")[1])
	Private xTPCTE 		:= ""
	Private aDoctos		:= {}
	Private aOIdent		:= Array(18) // Objetos do grupo IDENTIFICACAO
	Private aOVal		:= Array(4) // Objetos do grupo Valores
	Private aOImp		:= Array(5) // Contem objetos (tget/combobox) da seção impostos (grupo, tributação, base, aliq, val)
	Private oBrwDc	
	
	Private cCTEUF 		:= PadR('', 2, '0')
	Private cCTEDtEm 	:= PadR('', 4, '0')
	Private cCTECNPJ 	:= PadR('', 14, '0')
	Private cCTEMod 	:= '57'
	Private cCTESerie	:= PadR('', 3, '0')
	Private cCTENr 		:= PadR('', 9, '0')
	Private cCTECOD 	:= PadR('', 8, '        ')
	Private cCTEDV 		:= PadR('', 1, ' ')
	Private cTpEmis		:= PadR('', 1, '1')
	Private cTpIcl		:= cTpIclu // Tipo de Inclusão: 1-Rapida/2-Chave Cte
	
	//Atualiza automaticamente a data base do sistema na virada do dia
	FwDateUpd(.T.)
	dDtEmiss := dDataBase

	If Empty(cTpIcl)
		cTpIcl := '1'
	EndIf 
	// Se não vier da tela de documetnos de carga, precisa posicionar em 
	// algum primeiro pra trazer os documentos relacionados
	If cTpIcl == '1'
		If !IsInCallStack("GFEA044")
			// Seletor doc carga
			If !GFEA065B06_AddDC(2)
				Return
			EndIf
		Else
			// Valida documento de carga posicionado
			If !GFEA065B08_ValidaDC(GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC)
				Return
			EndIf
		EndIf
		aEmissores	:= GetTransp()
	ElseIf cTpIcl == '2'
		aRet := GFEA065B06_AddDC(2)
		
		If  Len(aRet) > 0 .And. aRet[1][10]
			cCodEmit := aRet[2][1]
			cNomEmit := aRet[2][2]
			aTrp 	 := {}
		
			aAdd(aTrp, AllTrim(cCodEmit)+"="+AllTrim(cNomEmit))
			
			aEmissores  :=  aTrp
			cSerieDF 	:= 	aRet[1][5]
			cNrDoc		:= 	aRet[1][6]
			cCTEUF 		:=	aRet[1][1]
			cCTEDtEm 	:=	aRet[1][2]
			cCTECNPJ 	:=	aRet[1][3]
			cCTEMod 	:=	aRet[1][4]
			cCTESerie 	:=	aRet[1][5]
			cCTENr 		:=	aRet[1][6]
			cTpEmis		:=  aRet[1][7]
			cCTECOD 	:=	aRet[1][8]
			cCTEDV 		:=	aRet[1][9]
			xTPCTE		:=	"0"
			
			cDtAuxAtual := Dtos(Date())
			cDtAux2     := Substr(cDtAuxAtual,3,2) + Substr(cDtAuxAtual,5,2)
			cDia 		:= '01'
			cAno		:= '20'

			If cCTEDtEm == cDtAux2 
				dDtEmiss := SToD(Dtos(Date()))
			Else
				dDtEmiss := SToD(cAno+cCTEDtEm+cDia)
			EndIf
		Else 
			Return
		EndIf
	EndIf

	cCdTrp	:= PadR(Substr(aEmissores[1], 1, At("=", aEmissores[1])-1), TamSX3("GW3_EMISDF")[1])
		
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 550, 800})//-100
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	If lIsDark	
		DEFINE MSDIALOG oDlg TITLE "Digitar Documento de Frete" ;
								FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
								PIXEL	
	Else
		DEFINE MSDIALOG oDlg TITLE "Digitar Documento de Frete" ;
							FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
							TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
							COLORS 0, 16777215 PIXEL	
	EndIf
			
		// Adicionado FWLayer para adicionar rolagem ao formulário caso saia dos limites da resolução/tela
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlg,.F.)
		oFWLayer:AddLine('LINET',002,.F.)
		oFWLayer:AddLine('LINE',096,.F.)
		oFWLayer:AddLine('LINEB',002,.F.)
		oFWLayer:AddCollumn('COLL',002,.T.,'LINE')
		oFWLayer:AddCollumn('COL',096,.T.,'LINE')
		oFWLayer:AddCollumn('COLR',002,.T.,'LINE')
		oPanel := oFWLayer:GetColPanel('COL','LINE')
			
		// Identificação
		oGroup := TGroup():Create(oPanel,000,120,/*078*/80,/*078*/110,'Identificação',,,.T.)
		oGroup:Align := CONTROL_ALIGN_TOP
			
		aOIdent[1] := oGroup
			
		// Espécie (GW3_CDESP)
		TSay():New(009,nLeft,{|| "Espécie"},oGroup,,,,,,.T.,,,100,10,)
		aOIdent[2] := TComboBox():New(017,nLeft,bSETGET(xEspecie),aEspecies,100,10,oGroup,,{|oObj| ChangeEspecie(oObj) },/*bValid*/,,,.T.,/*oFont*/,,,/*bWhen*/,,,,,"xGW3TPDF",/*[cLabelText],[nLabelPos],[oLabelFont],[nLabelColor]*/)

		// Série (GW3_SERDF)
		TSay():New(009,(nLeft*2+100),{|| "Série"},oGroup,,,,,,.T.,,,15,10,)
		aOIdent[3] := TGet():New(017,(nLeft*2+100),bSETGET(cSerieDF),oGroup,TamSX3("GW3_SERDF")[1],10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,{|| ChangeSerie() }/*bChange*/,.F.,.F.,,"cSerieDF")
				
		// Nr Doc
		TSay():New(009,(nLeft*3+100+TamSX3("GW3_SERDF")[1]+25),{|| "Nr Documento"},oGroup,,,,,,.T.,,,70,10,)
		aOIdent[4] := TGet():New(017,(nLeft*3+100+TamSX3("GW3_SERDF")[1]+25),bSETGET(cNrDoc),oGroup,60,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,{|oObj| GFEA065B02_ChangeNRDF(oObj)},.F.,.F.,,"cNrDoc")

		// Dt Emissão
		TSay():New(009,nLeft*3+195,{|| "Dt Emissão" },oGroup,,,,,,.T.,,,100,10,)
		aOIdent[5] := TGet():New(017,(nLeft*3+195),bSETGET(dDtEmiss),oGroup,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,{|| ChangeData() }/*bChange*/,.F.,.F.,,"dDtEmiss",,,,.T.)
			
		//CFOP (natureza operação) verificar parametros/gatilhos
		TSay():New(009,(nLeft*4+245),{|| "CFOP" },oGroup,,,,,,.T.,,,100,10,)
		aOIdent[6] := TGet():New(017,(nLeft*4+245),bSETGET(cCFOP),oGroup,TamSX3("GW3_CFOP")[1] + 10,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCFOP")
			
		// Emissor
		TSay():New(030,nLeft,{|| "Emissor" },oGroup,,,,,,.T.,,,100,10,)
		aOIdent[7] := TComboBox():New(038,nLeft,bSETGET(cCdTrp),aEmissores,135,10,oGroup,,{|| ChangeEmissor() }/*bWhen*/,/*bValid*/,,,.T.,/*oFont*/,,,/*bWhen*/,,,,,"cCdTrp",/*[cLabelText],[nLabelPos],[oLabelFont],[nLabelColor]*/)
			
		// Tipo DF
		TSay():New(030,nLeft*2+135,{|| "Tipo" },oGroup,,,,,,.T.,,,100,10,)
		aOIdent[8] := TComboBox():New(038,nLeft*2+135,bSETGET(xGW3TPDF),aTPDF,100,10,oGroup,,/*bChange*/,/*bValid*/,,,.T.,/*oFont*/,,,/*bWhen*/,,,,,"xGW3TPDF",/*[cLabelText],[nLabelPos],[oLabelFont],[nLabelColor]*/)
		
		//Chave de acesso CT-e
		TSay():New(051,nLeft,{|| "Chave CT-e" },oGroup,,,,,,.T.,,,100,10,)
		aOIdent[9] := TGet():New(060,nLeft,bSETGET(cCTEUF),oGroup,6,10,"@!",/*bValid*/,,,,,,.T.,,,{||.F.}/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTEUF")
		aOIdent[10] := TGet():New(060,nLeft+17,bSETGET(cCTEDtEm),oGroup,12,10,"@!",/*bValid*/,,,,,,.T.,,,{||.F.}/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTEDtEm")
		aOIdent[11] := TGet():New(060,nLeft*2+38,bSETGET(cCTECNPJ),oGroup,50,10,"@!",/*bValid*/,,,,,,.T.,,,{||.F.}/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTECNPJ")
		aOIdent[12] := TGet():New(060,nLeft*3+86,bSETGET(cCTEMod),oGroup,6,10,"@!",/*bValid*/,,,,,,.T.,,,{||.F.}/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTEMod")
		aOIdent[13] := TGet():New(060,nLeft*4+98,bSETGET(cCTESerie),oGroup,6,10,"@!",/*bValid*/,,,,,,.T.,,,{||.F.}/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTESerie")
		aOIdent[14] := TGet():New(060,nLeft*5+117,bSETGET(cCTENr),oGroup,15,10,"@!",/*bValid*/,,,,,,.T.,,,{||.F.}/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTENr")
		aOIdent[15] := TGet():New(060,nLeft*7+146,bSETGET(cTpEmis),oGroup,4,10,"@!",/*bValid*/,,,,,,.T.,,,{|| Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1" }/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cTpEmis")
		aOIdent[16] := TGet():New(060,nLeft*6+168,bSETGET(cCTECOD),oGroup,15,10,"@!",/*bValid*/,,,,,,.T.,,,{|| Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1" }/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTECOD")
		aOIdent[17] := TGet():New(060,nLeft*7+200,bSETGET(cCTEDV),oGroup,4,10,"@!",/*bValid*/,,,,,,.T.,,,{|| Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1" }/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTEDV")
			
		// Tipo CT-e
		TSay():New(051,nLeft*8 + 225,{|| "Tipo CT-e" },oGroup,,,,,,.T.,,,100,10,)
		aOIdent[18] := TComboBox():New(060,nLeft*8 + 225,bSETGET(xTPCTE), aTPCTE,80,10, oGroup,,/*bChange*/, /*bValid*/,,,.T.,/*oFont*/,,,{|| Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1" } /*bWhen*/,,,,,"xTPCTE",/*[cLabelText],[nLabelPos],[oLabelFont],[nLabelColor]*/)
			
		nTop := 79
			
		oPnl := TPanel():New(nTop,0,,oPanel,,,,,,100,36,.F.,.F.)
		oPnl:Align := CONTROL_ALIGN_TOP
			
		// Valores
		oGroup := TGroup():Create(oPnl,0,0,36,135,'Valores',,,.T.)
		oGroup:Align := CONTROL_ALIGN_LEFT
			
		aOVal[1] := oGroup
			
		TSay():New(009,nLeft,{|| "Valor Docto" },oGroup,,,,,,.T.,,,100,10,)
		aOVal[2] := TGet():New(017,nLeft,bSETGET(nValor),oGroup,40,10,PESQPICT("GW3", "GW3_VLDF"),{|| nValor >= 0 },,,,,,.T.,,,/*bWhen*/,,,{||ChangeValor()}/*bChange*/,.F.,.F.,,"nValor",,,,.F.,.T.)
			
		TSay():New(009,(nLeft * 2 + 38),{|| "Taxas" },oGroup,,,,,,.T.,,,100,10,)
		aOVal[3] := TGet():New(017,(nLeft * 2 + 38),bSETGET(nTaxas),oGroup,40,10,PESQPICT("GW3", "GW3_FRPESO"),{|| nTaxas >= 0 },,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"nTaxas",,,,.F.,.T.)
			
		TSay():New(009,(nLeft * 3 + 76),{|| "Vl Pedágio" },oGroup,,,,,,.T.,,,100,10,)
		aOVal[4] := TGet():New(017,(nLeft * 3 + 76),bSETGET(nPedagio),oGroup,40,10,PESQPICT("GW3", "GW3_PEDAG"),{|| nPedagio >= 0 },,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"nPedagio",,,,.F.,.T.)
			
		// Impostos
		oGroup := TGroup():Create(oPnl,0,140,36,383,'Impostos',,,.T.)
		oGroup:Align := CONTROL_ALIGN_RIGHT
			
		aOImp[1] := oGroup
			
		// GW3_TRBIMP //Tributação
		TSay():New(009,nLeft+142,{|| "Tributação" },oGroup,,,,,,.T.,,,100,10,)
		aOImp[2] := TComboBox():New(017,nLeft+142,bSETGET(xTribut),aTributacao,70,10,oGroup,,{|| ChangeTributacao()}/*bChange*/,/*bValid*/,,,.T.,/*oFont*/,,,/*bWhen*/,,,,,"xTribut",/*[cLabelText],[nLabelPos],[oLabelFont],[nLabelColor]*/)
			
		// GW3_BASIMP  Base Imposto
		TSay():New(009,(nLeft * 2 + 210),{|| "Base Imposto" },oGroup,,,,,,.T.,,,100,10,)
		aOImp[3] := TGet():New(017,(nLeft * 2 + 210),bSETGET(nBaseImp),oGroup,40,10,PESQPICT("GW3", "GW3_BASIMP"),{|| nPedagio >= 0 },,,,,,.T.,,,/*bWhen*/,,,{|| ChangeBaseImp() }/*bChange*/,.F.,.F.,,"nBaseImp",,,,.F.,.T.)
			
		// GW3_PCIMP   Aliq Imposto
		TSay():New(009,(nLeft * 3 + 250),{|| "Aliq Imp." },oGroup,,,,,,.T.,,,100,10,)
		aOImp[4] := TGet():New(017,(nLeft * 3 + 250),bSETGET(nAliqImp),oGroup,20,10,PESQPICT("GW3", "GW3_PCIMP"),{|| nPedagio >= 0 },,,,,,.T.,,,/*bWhen*/,,,{|| ChangeAliquota() }/*bChange*/,.F.,.F.,,"nAliqImp",,,,.F.,.T.)
			
		// GW3_VLIMP   Vl Imposto
		TSay():New(009,(nLeft * 4 + 270),{|| "Vl Imp." },oGroup,,,,,,.T.,,,100,10,)
		aOImp[5] := TGet():New(017,(nLeft * 4 + 270),bSETGET(nVlImp),oGroup,40,10,PESQPICT("GW3", "GW3_VLIMP"),{|| nPedagio >= 0 },,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"nVlImp",,,,.F.,.T.)
			
		// Documentos
		nTop += 37
			
		oPnl := TPanel():New(nTop,0,,oPanel,,,,,,100,15,.F.,.F.)
		oPnl:Align := CONTROL_ALIGN_TOP
			
		TSay():New(005,000,{|| "Documentos relacionados" },oPnl,,,,,,.T.,,,100,10,)
			
		nTop += 15
			
		oPnl := TPanel():New(nTop,0,,oPanel,,,,,,100,120,.F.,.F.)
		oPnl:Align := CONTROL_ALIGN_TOP
			
		If cTpIcl == '1'
			aAdd(aDoctos, {.T., GW1->GW1_SERDC, GW1->GW1_NRDC, GW1->GW1_DANFE, GW1->GW1_CDTPDC, GW1->GW1_EMISDC })
				
			If lCpoSDoc
				aAdd(aDoctos[1],GW1->GW1_SDOC)
			EndIf

			oBrwDc := TWBrowse():New(010,000,200,90,,{'','Série','Nr Documento', 'Chave NF-e'},{20,30,30,30},;
			oPnl,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
			oBrwDc:lHScroll := .F.
			oBrwDc:lVScroll := .T.
			oBrwDc:lDisablePaint := .F.
			oBrwDc:Align := CONTROL_ALIGN_TOP      
				
			oBrwDc:SetArray(aDoctos)
			oBrwDc:bLine := {|oObj| GFEA065B05_BrwBLine(oObj) }
			oBrwDc:bLDblClick := {|| aDoctos[oBrwDc:nAt][1] := !aDoctos[oBrwDc:nAt][1],;                               
			oBrwDc:DrawSelect()}
			
			ChangeEmissor()
			ChangeData()
			ChangeSerie()
			ChangeEspecie(aOIdent[2])
			
			oDLG:Activate(,,,.T.,,,{|| GFEA065B04_CarregaDoctos(aDoctos), EnchoiceBar(oDlg,{|| If(GFEA065B03_ValidaForm(),oDlg:End(),Nil)}, {||oDlg:End()},,aButtons)})	
		
		ElseIf cTpIcl == '2'
			cAliasGWF := GetNextAlias()
			BeginSql Alias cAliasGWF
				SELECT  GWH.GWH_NRDC,
						GWH.GWH_SERDC,
						GWH.GWH_EMISDC,
						GWH.GWH_CDTPDC,
						GW1.GW1_DTEMIS,
						GWH.GWH_NRCALC
				FROM %TABLE:GWF% GWF
				INNER JOIN %TABLE:GWH% GWH
				ON GWH.GWH_FILIAL = GWF.GWF_FILIAL
				AND GWH.GWH_NRCALC = GWF.GWF_NRCALC
				AND GWH.GWH_EMISDC= GWF.GWF_EMIREM
				AND GWH.%NotDel%
				INNER JOIN %TABLE:GW1% GW1
				ON GW1.GW1_FILIAL = GWH.GWH_FILIAL
				AND GW1.GW1_NRDC = GWH.GWH_NRDC
				AND GW1.GW1_CDTPDC = GWH.GWH_CDTPDC
				AND GW1.GW1_EMISDC = GWH.GWH_EMISDC
				AND GW1.GW1_SERDC = GWH.GWH_SERDC
				AND GW1.%NotDel%
				WHERE GWF.GWF_TRANSP = %Exp:cCodEmit%
				AND GWF.GWF_EMISDF 	 = ' '
				AND GWF.GWF_SERDF    = ' '
				AND GWF.GWF_NRDF     = ' '
				AND GWF.GWF_DTEMDF   = ' '
				AND GWF.%NotDel%
				ORDER BY GW1_DTEMIS DESC
			ENDSQL

			While (cAliasGWF)->(!Eof())
				cDtEmiss    := (cAliasGWF)->GW1_DTEMIS
				cSerieDc	:= (cAliasGWF)->GWH_SERDC
				cNumDoc		:= (cAliasGWF)->GWH_NRDC
				cNrCalGWH	:= (cAliasGWF)->GWH_NRCALC
				cCdTpDc		:= (cAliasGWF)->GWH_CDTPDC
				cEmisDc		:= (cAliasGWF)->GWH_EMISDC
				
				aAdd(aDoctos,{.F.,cSerieDc,cNumDoc,StoD(cDtEmiss),cCdTpDc,cEmisDc,cNrCalGWH,' '})

				(cAliasGWF)->(dbSkip())
			EndDo
			(cAliasGWF)->(dbCloseArea())
			
			oBrwDc := TWBrowse():New(010,000,200,90,,{'','DT Emissão','Tp Doc Carga','Série','Nr Doc Carga', 'Nr Cálculo'},{20,40,40,30,40,40},;
			oPnl,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
			oBrwDc:lHScroll := .F.
			oBrwDc:lVScroll := .T.
			oBrwDc:lDisablePaint := .F.
			oBrwDc:Align := CONTROL_ALIGN_TOP      
				
			oBrwDc:SetArray(aDoctos)
			oBrwDc:bLine := {|oObj| GFEA065B05_BrwBLine(oObj) }
			oBrwDc:bLDblClick := {|| aDoctos[oBrwDc:nAt][1] := !aDoctos[oBrwDc:nAt][1],;                               
			oBrwDc:DrawSelect()}

			oDLG:Activate(,,,.T.,,,{|| GFEA065B04_CarregaDoctos(aDoctos), EnchoiceBar(oDlg,{|| If(GFEA065B03_ValidaForm(),oDlg:End(),Nil)}, {||oDlg:End()},,aButtons)})
		EndIf
Return Nil
//--------------------------------------------------------------------
Static Function ChangeTributacao()
	If xTribut == '2'
		nBaseImp := 0
		nAliqImp := 0
		nVlImp	  := 0
	Else
		ChangeValor()
	EndIf
Return
//--------------------------------------------------------------------
Static Function ChangeValor()
	nBaseImp := nValor
	
	If nAliqImp > 0
		nVlImp := Round(nValor * nAliqImp / 100, 2)
	EndIf
Return
//--------------------------------------------------------------------
Static Function ChangeTipo()
	If xGW3TPDF == '6'
		If Len(aEmissores) > 1
			cCdTrp	:= PadR(Substr(aEmissores[2], 1, At("=", aEmissores[2])-1), TamSX3("GW3_EMISDF")[1])
		EndIf
	EndIf
	
	GFEA065B04_CarregaDoctos()
Return
//--------------------------------------------------------------------
Static Function ChangeBaseImp()
	If nAliqImp > 0
		nVlImp := Round(nBaseImp * nAliqImp / 100, 2)
	EndIf
Return
//--------------------------------------------------------------------
Static Function ChangeAliquota()
	nVlImp := Round(nBaseImp * nAliqImp / 100, 2)
Return
//--------------------------------------------------------------------
Static Function ChangeEmissor()
	Local cNrCid := Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_NRCID")
	
	
	If Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1" 
		cCTEUF 	:= TMS120CdUf(POSICIONE("GU7",1,XFILIAL("GU7")+cNrCid,"GU7_CDUF"), "1")
		cCTECNPJ 	:= Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_IDFED")
		cCTEMod 	:= '57'
	Else
		cCTEUF := '00'
		cCTECNPJ := '00000000000000'
		cCTEMod 	:= '00'
	EndIf
	
	GFEA065B04_CarregaDoctos()
Return
//--------------------------------------------------------------------
Static Function ChangeSerie()

	dbSelectArea("GVT")
	dbSetOrder(1)
	dbSeek(xFilial("GVT")+ xEspecie)
		
	dbSelectArea("GU3")
	If dbSeek(xFilial("GU3")+cCdTrp)
		If ((GU3->GU3_CTE == "1") .and. !(IsNumeric(cSerieDF))) .and.(GVT->GVT_TPIMP != "2")
			MsgInfo("Transportador cadastrado para gerar chave ct-e, série do documento tem que ser númerica.")
			return .F.
		else
			If Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1"
				If Empty(cSerieDF) 
					cCTESerie := '000'
				Else		
					cCTESerie := StrZero(Val(cSerieDF), 3)	
				EndIf
			Else
				cCTESerie := '000'
			EndIf
		EndIf
	EndIf
	
Return 
//--------------------------------------------------------------------
Static Function ChangeData()
	If Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1"
		cCTEDtEm := Substr(AllTrim(Str(YEAR(dDtEmiss))), 3, 2) + StrZero(MONTH(dDtEmiss), 2)
	Else
		cCTEDtEm := '0000'
	EndIf  
Return
//--------------------------------------------------------------------
Static Function ChangeEspecie(oObj)
	Local aDescIm	:= {"ICMS", "ISS", "Sem Impostos" }
	Local cTpImp	:= Posicione("GVT",1,xFilial("GVT")+xEspecie,"GVT_TPIMP")
	Local nCount
	Local cNrCid := Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_NRCID")
	
	If !(cTpImp $ '123')
		cTpImp := '3'
	endIf
	
	aOImp[1]:SetText(aDescIm[Val(cTpImp)])
	
	For nCount := 2 To Len(aOImp)
	
		If cTpImp == "3"
			aOImp[nCount]:Disable()
		Else
			aOImp[nCount]:Enable()	
		EndIf
	
	Next nCount

	dbSelectArea("GVT")
	dbSetOrder(1)
	dbSeek(xFilial("GVT")+ xEspecie)
		
	If Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1" .and.(GVT->GVT_TPIMP != "2")	
		cCTEUF 	:= TMS120CdUf(POSICIONE("GU7",1,XFILIAL("GU7")+cNrCid,"GU7_CDUF"), "1")
		cCTECNPJ 	:= Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_IDFED")
		cCTEMod 	:= '57'
	Else
		cCTEUF := '00'
		cCTECNPJ := '00000000000000'
		cCTEMod 	:= '00'
		cCTEDtEm := '0000'
	EndIf	

	GFEA065B02_ChangeNRDF(aOIdent[4])
	
Return Nil
//--------------------------------------------------------------------
Function GFEA065B02_ChangeNRDF(oObj)
	Local cZeros	:= Posicione("GVT",1,xFilial("GVT")+xEspecie,"GVT_ZEROS")
	Local nQtZer
	
	//Formatação do número de acordo com a especie selecionada
	//1=Manter;2=Retirar;3=Preencher                                                                                                 
	If cZeros == "2"
		cNrDoc := PadR(GFEZapZero(AllTrim(cNrDoc)), TamSX3("GW3_NRDF")[1], " ")
	ElseIf cZeros == "3"
		nQtZer	:= Posicione("GVT",1,xFilial("GVT")+xEspecie,"GVT_QTALG")
		cNrDoc := PadL(AllTrim(cNrDoc), IIf(nQtZer == 0, TamSX3("GW3_NRDF")[1], nQtZer), "0")
	EndIf
	
	dbSelectArea("GVT")
	dbSetOrder(1)
	dbSeek(xFilial("GVT")+ xEspecie)
	
	If Posicione("GU3", 1, xFilial("GU3")+cCdTrp, "GU3_CTE") == "1" .and.(GVT->GVT_TPIMP != "2")	
		If Len(AllTrim(cNrDoc))<= 9
			cCTENr := PadL(AllTrim(cNrDoc), 9, "0")
		EndIf
	Else
		cCTENr := '000000000'
	EndIf
	
	oObj:Refresh()
Return Nil
//--------------------------------------------------------------------
Function GFEA065B03_ValidaForm()
	Local lRet 		:= .T.
	Local oFWMVCWindow, aCoors
	Local oView  	:= FWLoadView('GFEA065')
	Local oModel 	:= FWLoadModel('GFEA065')
	
	IF cTpIcl == '2'
		cNrDoc := aRet[1][6]
	EndIf

	If Empty(cNrDoc)
		MsgStop("Informe o número do documento!","Atenção")
		aOIdent[4]:SetFocus()
		lRet := .F. 
	EndIf
	
	If lRet .And. (xGW3TPDF <> '3' .And. nValor <= 0)
		MsgStop("Informe o valor do documento!","Atenção")
		aOVal[2]:SetFocus()
		lRet := .F.
	EndIf
	
	If lRet .And. aScan(aDoctos, {|x| x[1] == .T. }) == 0
	 	MsgStop("Você deve selecionar pelo menos um documento de carga para o documento de frete", "Atenção")
	 	lRet := .F.
	EndIf
	 
	If lRet .And. !Empty(ChaveCTE()) .And. !GFE065VLDV(ChaveCTE())
		//Verifica se a especie do documento de frete esta com o tipo 1- Obrigatório ou 2- Opcional
		GVT->(dbSetOrder(1))
		If GVT->(dbSeek(xFilial("GVT")+xEspecie))
			If GVT->(FieldPos("GVT_CHVCTE")) > 0 .And. GVT->GVT_CHVCTE != "3"
				MsgStop("Digito verificador do CT-e inválido!", "Atenção")
				aOIdent[15]:SetFocus()
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	If lRet 
		lRet := ValidaCadastro()
	EndIf
	
	If lRet 
		
		aCoors := FWGetDialogSize(oMainWnd)
		
		oView:SetModel(oModel)
		oView:EnableControlBar(.T.)
		oView:SetOperation(MODEL_OPERATION_INSERT)
		oView:SetUseCursor(.F.)
		oView:SetCloseOnOk({|| .T.})
		oView:oModel:SetActivate({|oModel|AbreCadastro(oModel,oView)})
		
		oFWMVCWindow := FWMVCWindow():New()
		oFWMVCWindow:SetUseControlBar(.T.)
		oFWMVCWindow:SetView(oView)
		oFWMVCWindow:SetCentered(.T.)
		oFWMVCWindow:SetPos(aCoors[1],aCoors[2])
		oFWMVCWindow:SetSize(aCoors[3],aCoors[4])
		oFWMVCWindow:SetTitle("Digitação documento de frete") 
		oFWMVCWindow:Activate(,,Nil,{|| lRet := .F., .T.})
		
	EndIf
	
	If lRet
	
		MsgInfo('O documento de frete ' + AllTrim(cNrDoc) + ' foi inserido com sucesso!', 'Inclusão documento de frete')
	
	EndIf
	
Return lRet
//--------------------------------------------------------------------
Static Function GetGW3Cpos()
	Local aCpoVal := {;
						{ 'GW3_NRDF'	, AllTrim(cNrDoc) 	},;
						{ 'GW3_SERDF'	, cSerieDF 			},;
						{ 'GW3_DTEMIS', dDtEmiss 			},;
						{ 'GW3_TPDF'	, xGW3TPDF 			},;
						{ 'GW3_CFOP'	, cCFOP 				},;
						{ 'GW3_CDESP'	, xEspecie 			},;
						{ 'GW3_EMISDF', cCdTrp 				},;
						{ 'GW3_VLDF'	, nValor 				},;
						{ 'GW3_TAXAS'	, nTaxas 				},;
						{ 'GW3_PEDAG'	, nPedagio 			},;
						{ 'GW3_TRBIMP', xTribut 				},;
						{ 'GW3_BASIMP', nBaseImp 			},;
						{ 'GW3_PCIMP'	, nAliqImp 			},;
						{ 'GW3_VLIMP'	, nVlImp 				};
						}
											
						
Return aCpoVal
//--------------------------------------------------------------------
Static Function ValidaCadastro()
	Local oModel 		:= FWLoadModel('GFEA065')
	Local nCount
	Local oModelGW4
	Local lRet 			:= .T.
	Local aAreaGW1 		:= GW1->(GetArea())
	Local aCpoVal 		:= GetGW3Cpos()
	Local cTpEmisAnt 	:= cTpEmis
	
	oModel:SetOperation(3)
	oModel:Activate()
	
	For nCount := 1 To Len(aCpoVal)
		
		If lRet .And. !Empty(aCpoVal[2]) .And. !oModel:SetValue('GFEA065_GW3', aCpoVal[nCount][1], aCpoVal[nCount][2])
			MsgStop( oModel:GetErrorMessage()[6], 'Atenção')
			lRet := .F.
			Exit
		EndIf
		
	Next nCount

	If cTpEmisAnt != "1"
		cTpEmis := cTpEmisAnt
	EndIf 
	
	oModel:LoadValue('GFEA065_GW3', 'GW3_CDREM', GW1->GW1_CDREM)
	oModel:LoadValue('GFEA065_GW3', 'GW3_CDDEST', GW1->GW1_CDDEST)
	
	If lRet .And. !Empty(ChaveCTE())
		oModel:SetValue('GFEA065_GW3', 'GW3_CTE', ChaveCTE())
	EndIf
	
	If lRet
		oModel:LoadValue('GFEA065_GW3', 'GW3_TPCTE', xTPCTE)
	EndIf
	
	oModelGW4 := oModel:GetModel('GFEA065_GW4')
	
	For nCount := 1 To Len(aDoctos)
		
		If aDoctos[nCount][1]
			oModelGW4:GoLine(oModelGW4:Length())
				
				oModelGW4:SetValue('GW4_NRDC', aDoctos[nCount][3])
				oModelGW4:SetValue('GW4_TPDC', aDoctos[nCount][5])
				oModelGW4:SetValue('GW4_SERDC', aDoctos[nCount][2])
				oModelGW4:SetValue('GW4_EMISDC', aDoctos[nCount][6]) 
				

				If lCpoSDoc
					If Len(aDoctos[nCount]) <= 7
						oModelGW4:SetValue('GW4_SDOCDC', aDoctos[nCount][7])
					Else
						oModelGW4:SetValue('GW4_SDOCDC', aDoctos[nCount][8])
					EndIf
				EndIf

				If lRet .And. !oModelGW4:VldLineData()
					MsgStop('Não foi possível incluir o documento: '+aDoctos[nCount][3]+CRLF+'Motivo: '+oModel:GetErrorMessage()[6],'')
					lRet := .F.
					Exit
				EndIf
			
				oModelGW4:AddLine(.T.)
		EndIf
		
	Next nCount
	// retirado em função da issue MLOG-1947
	/*If lRet //.And. !oModel:VldData()
		MsgStop( oModel:GetErrorMessage()[6], 'Atenção')
		lRet := .F.
	EndIf*/
	
	oModel:DeActivate()
	
	RestArea(aAreaGW1)
	
Return lRet
//--------------------------------------------------------------------
Static Function ChaveCTE()
	Local cRet 		:= ''
	Local lChaveCte := .T.
	
	//Verifica se a especie do documento de frete esta com o tipo 3- Não informar
	GVT->(dbSetOrder(1))
	If GVT->(dbSeek(xFilial("GVT")+xEspecie))
		If GVT->(FieldPos("GVT_CHVCTE")) > 0 .And. GVT->GVT_CHVCTE == "3"
			lChaveCte := .F.
		EndIf
	EndIf

	If !Empty(cCTECOD) .And. lChaveCte
		cRet := AllTrim(cCTEUF)+AllTrim(cCTEDtEm)+AllTrim(cCTECNPJ)+AllTrim(cCTEMod)+AllTrim(cCTESerie)+AllTrim(cCTENr)+AllTrim(cTpEmis)+AllTrim(cCTECOD)+AllTrim(cCTEDV)
	EndIf

Return cRet 
//--------------------------------------------------------------------
Static Function AbreCadastro(oModel, oView)
	Local nCount
	Local nDocs
	Local oModelGW4
	Local oModelGW3 	:= oModel:GetModel('GFEA065_GW3')
	Local aCpoVal 		:= GetGW3Cpos()
	Local cTpEmisAnt 	:= cTpEmis
	
	For nCount := 1 To Len(aCpoVal)
		If !Empty(aCpoVal[2])
			oModel:SetValue('GFEA065_GW3', aCpoVal[nCount][1], aCpoVal[nCount][2])
		EndIf
	Next nCount

	If cTpEmisAnt != "1"
		cTpEmis := cTpEmisAnt
	EndIf
	
	oModel:LoadValue('GFEA065_GW3', 'GW3_CDREM' , GW1->GW1_CDREM)
	oModel:LoadValue('GFEA065_GW3', 'GW3_CDDEST', GW1->GW1_CDDEST)
	oModelGW3:SetValue('GW3_NMREM', POSICIONE("GU3",1,XFILIAL("GU3")+FwFldGet("GW3_CDREM"),"GU3_NMEMIT"))
	oModelGW3:SetValue('GW3_NMDEST', POSICIONE("GU3",1,XFILIAL("GU3")+FwFldGet("GW3_CDDEST"),"GU3_NMEMIT"))
	
	If !Empty(ChaveCTE())
		oModel:SetValue('GFEA065_GW3', 'GW3_CTE', ChaveCTE())
	EndIf
	
	oModel:LoadValue('GFEA065_GW3', 'GW3_TPCTE', xTPCTE)
	
	oModelGW4	:= oModel:GetModel('GFEA065_GW4')
	nDocs 		:= 0
	
	For nCount := 1 To Len(aDoctos)
		
		If aDoctos[nCount][1]
			If nDocs != 0
				oModelGW4:AddLine(.T.)
			EndIf
			
			nDocs++
			
			oModelGW4:GoLine(oModelGW4:Length())
			oModelGW4:SetValue('GW4_NRDC', aDoctos[nCount][3])
			oModelGW4:SetValue('GW4_TPDC', aDoctos[nCount][5])
			oModelGW4:SetValue('GW4_SERDC', aDoctos[nCount][2])
			oModelGW4:SetValue('GW4_EMISDC', aDoctos[nCount][6])
			If lCpoSDoc
				If Len(aDoctos[nCount]) <= 7
					oModelGW4:SetValue('GW4_SDOCDC', aDoctos[nCount][7])
				Else
					oModelGW4:SetValue('GW4_SDOCDC', aDoctos[nCount][8])
				EndIf
			EndIf
 		EndIf
		
	Next nCount
	
Return
//--------------------------------------------------------------------
//
// Carregar documentos para TIPO e TRANSPORTADOR informados
//
Function GFEA065B04_CarregaDoctos(aDoctos)
	Local aDoc 	:= {}
	Local aDocRel := {}
	Local nCount
		
	IF cTpIcl == '1' 
		aAdd(aDoc, {.T., GW1->GW1_SERDC, GW1->GW1_NRDC, GW1->GW1_DANFE, GW1->GW1_CDTPDC, GW1->GW1_EMISDC })
		If lCpoSDoc
			aAdd(aDoc[1],GW1->GW1_SDOC)
		EndIf
		
		aDocRel := DCRelac(GW1->GW1_FILIAL, GW1->GW1_SERDC, GW1->GW1_NRDC, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, xGW3TPDF, cCdTrp)
		
		For nCount := 1 To Len(aDocRel)
		
			If aScan(aDoc, {|x| x[2] == aDocRel[nCount][2] .And. x[3] == aDocRel[nCount][3] .And. x[5] == aDocRel[nCount][5] .And. x[6] == aDocRel[nCount][6]  }) == 0
			
				aAdd(aDoc, aDocRel[nCount])
				
			EndIf
		
		Next nCount
		
		aDoctos := aDoc
	EndIf 
	
	oBrwDc:SetArray(aDoctos)
	oBrwDc:bLine := {|oObj| GFEA065B05_BrwBLine(oObj) }
	oBrwDc:Refresh()
	
Return Nil
//--------------------------------------------------------------------
Static Function DCRelac(cFILDC, cSERDC, cNRDC, cCDTPDC, cEMISDC, cTPDF, cCdTrp)
	Local aRet := {}
	Local aAreaGWF, aAreaGWH, aAreaGWH2, aAreaGW1
	
	dbSelectArea("GWF")
	dbSelectArea("GWH")
	
	aAreaGWF := GWF->( GetArea() )
	aAreaGWH := GWH->( GetArea() )
	aAreaGW1 := GW1->( GetArea() )
	
	GWH->( dbSetOrder(2) )
	GWF->( dbSetOrder(1) )
	
	// 1o Procurar qual o cálculo correto
	// 2o Procurar os documentos do cálculo
	
	If GWH->(dbSeek(cFILDC + cCDTPDC + cEMISDC + cSERDC + cNRDC))
		
		While GWH->(!Eof()) .And. GWH->GWH_FILIAL == cFILDC .And. ;
			GWH->GWH_CDTPDC == cCDTPDC .And. ;
			GWH->GWH_EMISDC == cEMISDC .And. ;
			GWH->GWH_SERDC == cSERDC .And. ;
			GWH->GWH_NRDC == cNRDC
				
				If GWF->( dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC) )
				
					// Se é o tipo de cálculo correto adiciona os doctos	
					If GWF->GWF_TPCALC == cTPDF .And. AllTrim(GWF->GWF_TRANSP) == AllTrim(cCdTrp)
						
						aAreaGWH2 := GWH->( GetArea() )
						
						GWH->( dbSetOrder(1) )
						
						If GWH->( dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC) )
						
							While GWH->(!Eof()) .And. GWH->GWH_FILIAL == GWF->GWF_FILIAL .And. ;
								GWH->GWH_NRCALC == GWF->GWF_NRCALC 
								
								nI := aAdd(aRet, {.F., GWH->GWH_SERDC, GWH->GWH_NRDC, ;
												Posicione("GW1",1,GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC,"GW1_DANFE"),;
												GWH->GWH_CDTPDC, GWH->GWH_EMISDC })
								If lCpoSDoc
									aAdd(nI,GWH->GWH_SDOCDC)
								EndIf
								
								GWH->( dbSkip() )
							EndDo
							
						EndIf
						
						RestArea( aAreaGWH2 )

					EndIf
					
				EndIf		
			 
			GWH->(dbSkip())
			
		EndDo
		
	EndIf
	
	RestArea(aAreaGW1)
	RestArea(aAreaGWF)
	RestArea(aAreaGWH)
	
Return aRet
//--------------------------------------------------------------------
Function GFEA065B05_BrwBLine(oObj)
	Local aLine := {}
	
	If !Empty(oObj:aArray)
		IF cTpIcl == '1'
			aLine := { If(oObj:aArray[oObj:nAt,01],oOK,oNO),oObj:aArray[oObj:nAt,If(lChaveUnica,07,02)],;
							oObj:aArray[oObj:nAt,03],oObj:aArray[oObj:nAt,04],oObj:aArray[oObj:nAt,05] }
		ElseIF cTpIcl == '2'
			aLine := { If(oObj:aArray[oObj:nAt,01],oOK,oNO),oObj:aArray[oObj:nAt,04],oObj:aArray[oObj:nAt,05],oObj:aArray[oObj:nAt,If(lChaveUnica,07,02)],;
							oObj:aArray[oObj:nAt,03],oObj:aArray[oObj:nAt,07] }
		EndIf
	EndIf
Return aLine
//--------------------------------------------------------------------
//
// nOrigem: 	1 - Botão ações relacionadas
//				2 - Ao inicializar a tela
//
Function GFEA065B06_AddDC(nOrigem)
	Local oWind
	Local aAreaGW1		:= GW1->( GetArea() )
	Local lRet 			:= .F.
	Local cCampoSrDc	:= SerieNfId('GW1',3,'GW1_SERDC')
	Local lIsDark		:= GfeDark()
	Default nOrigem 	:= 1
	Private cGW1NRDC 	:= Space(TamSX3("GW1_NRDC")[1])
	Private cGW1CDTPDC	:= Space(TamSX3("GW1_CDTPDC")[1])
	Private cGW1SERDC 	:= Space(TamSX3("GW1_SERDC")[1])
	Private cGW1EMISDC	:= Space(TamSX3("GW1_EMISDC")[1])
	Private cCTE		:= Space(TamSX3("GW3_CTE")[1])
	Private cGW1SDOC	:= ""
	Private aRet		:= {}
	
	If lCpoSDoc
		cGW1SDOC := Space(TamSX3("GW1_SERDC")[1])
	EndIf
		
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 150, If(lCpoSDoc,600,465)})
	oSize:lLateral     := .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),;
                 oSize:GetDimension("ENCHOICE","COLINI"),;
                 oSize:GetDimension("ENCHOICE","LINEND"),;
                 oSize:GetDimension("ENCHOICE","COLEND")}
	If lIsDark
		DEFINE MSDIALOG oWind TITLE "Incluir Documento de Frete" ;
								FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
								PIXEL	
	Else
		DEFINE MSDIALOG oWind TITLE "Incluir Documento de Frete" ;
								FROM oSize:aWindSize[1],oSize:aWindSize[2] ;
								TO oSize:aWindSize[3],oSize:aWindSize[4] ; 
								COLORS 0, 16777215 PIXEL	 
	EndIf 

		If cTpIcl == '1'
			TSay():New(aPosEnch[1]+009,aPosEnch[2]+005,{|| "Nr Documento"},oWind,,,,,,.T.,,,60,10,)
			oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+005,bSETGET(cGW1NRDC),oWind,60,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1NRDC",,,,.T.)
			oGet:cF3 := "GFEGW4"
			
			TSay():New(aPosEnch[1]+009,aPosEnch[2]+070,{|| "Tipo"},oWind,,,,,,.T.,,,50,10,)
			oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+070,bSETGET(cGW1CDTPDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1CDTPDC")
			
			TSay():New(aPosEnch[1]+009,aPosEnch[2]+125,{|| "Série"},oWind,,,,,,.T.,,,50,10,)
			oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+125,bSETGET(cGW1SERDC),oWind,50,10,"!!!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1SERDC")
			
			TSay():New(aPosEnch[1]+009,aPosEnch[2]+180,{|| "Emissor"},oWind,,,,,,.T.,,,50,10,)
			oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+180,bSETGET(cGW1EMISDC),oWind,50,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cGW1EMISDC")
			
			oWind:Activate(,,,.T.,,,{|| EnchoiceBar(oWind, {|| lRet := GFEA065B07_AddConfirm(cGW1SERDC, cGW1NRDC, cGW1EMISDC, cGW1CDTPDC, nOrigem), If(lRet,oWind:End(),.F.) }, {|| oWind:End() },,)})
		ElseIf cTpIcl == '2'
			TSay():New(aPosEnch[1]+009,aPosEnch[2]+070,{|| "Nr Chave CTe"},oWind,,,,,,.T.,,,70,10,)
			oGet := TGet():New(aPosEnch[1]+017,aPosEnch[2]+070,bSETGET(cCTE),oWind,140,10,"@!",/*bValid*/,,,,,,.T.,,,/*bWhen*/,,,/*bChange*/,.F.,.F.,,"cCTE")
			
			oWind:Activate(,,,.T.,,,{|| EnchoiceBar(oWind, {|| aRet := GFEA065B11_CarregaCte(cCTE), If(aRet[1][10],oWind:End(),.F.) }, {|| oWind:End() },,)})
			Return aRet
		EndIf

	If nOrigem != 2
		RestArea( aAreaGW1 )
	EndIf
Return lRet
//--------------------------------------------------------------------
//
// nOrigem: 	1 - Botão ações relacionadas
//				2 - Ao inicializar a tela
//
Function GFEA065B07_AddConfirm(cGW1SERDC, cGW1NRDC, cGW1EMISDC, cGW1CDTPDC, nOrigem,cGW1SDOC)
	Local aAreaGW1 	:= GW1->( GetArea() )
	Local cGW1FIL	:= GW1->GW1_FILIAL
	Local aDocRel	:= {}
	Local nCount
	Local lRet		:= .T.
	Local nI
	Local aRet 		:= {}
	Default nOrigem	:= 1
	
	// INI - Prepara campos para chamar tela de escolha de Doc. Carga, caso exista mais de um com as seguintes chaves em parâmetro
	If TamSx3("GW4_SERDC")[1] == 14
		aRet := GFE517TLDC( cGW1NRDC , cGW1CDTPDC , cGW1EMISDC , cGW1SERDC )

		If Len(aRet) > 0

			cGW1CDTPDC	:= aRet[6]
			cGW1EMISDC	:= aRet[2]
			cGW1SERDC	:= aRet[4]
			cGW1NRDC	:= aRet[5]
			If lCpoSDOC
				cGW1SDOC := Transform(aRet[4], "!!!")
			EndIf

		EndIf

	EndIf
	// FIM - Prepara campos para chamar tela de escolha de Doc. Carga, caso exista mais de um com as seguintes chaves em parâmetro
	
	If !GFEA065B08_ValidaDC(cGW1CDTPDC, cGW1EMISDC, cGW1SERDC, cGW1NRDC)
		lRet := .F.
	Else
		If nOrigem == 1
			
			If aScan(aDoctos, {|x| x[2] == cGW1SERDC .And. x[3] == cGW1NRDC .And. x[5] == cGW1CDTPDC .And. x[6] == cGW1EMISDC }) == 0 
			
				nI := aAdd(aDoctos, {.T., cGW1SERDC, cGW1NRDC, ;
									Posicione("GW1",1,xFilial("GW1")+cGW1CDTPDC+cGW1EMISDC+cGW1SERDC+cGW1NRDC,"GW1_DANFE"),;
									cGW1CDTPDC, cGW1EMISDC })
				If lCpoSDoc
					aAdd(nI,cGW1SDOC)
				EndIf
				
				aDocRel := DCRelac(xFilial("GW1"), cGW1SERDC, cGW1NRDC, cGW1CDTPDC, cGW1EMISDC, xGW3TPDF, cCdTrp)
				
				For nCount := 1 To Len(aDocRel)
					
					If aScan(aDoctos, {|x| x[2] == aDocRel[nCount][2] .And. x[3] == aDocRel[nCount][3] .And. x[5] == aDocRel[nCount][5] .And. x[6] == aDocRel[nCount][6]  }) == 0
		
						aAdd(aDoctos, aDocRel[nCount])
						
					EndIf
					
				Next nCount
																
				oBrwDc:SetArray(aDoctos)
				oBrwDc:bLine := {|oObj| GFEA065B05_BrwBLine(oObj) }
				oBrwDc:Refresh()
			
			Else
				MsgStop("Documento não pode ser adicionado pois já está na lista!", "Atenção")
				lRet := .F.
			EndIf
			
			RestArea( aAreaGW1 )
			
		ElseIf nOrigem == 2
			
			// Quando a origem for a tela deve ficar posicinado no documento
			dbSelectArea("GW1")
			GW1->(dbSetOrder(1))
			lRet := GW1->(dbSeek(xFilial("GW1")+cGW1CDTPDC+cGW1EMISDC+cGW1SERDC+cGW1NRDC))
			
		EndIf
	EndIf
	
Return lRet
//--------------------------------------------------------------------
Function GFEA065B11_CarregaCte(cCTE)
	Local aRet		  := {}
	Local cEmissorCte := ""
	Local cCodEmit	  := ""
	Local cNomEmit	  := ""
	Local cAliasGU3   := GetNextAlias()


	If Len(RTrim(cCTE)) == TamSX3("GW3_CTE")[1]

		aAdd(aRet,{SubStr(cCTE, 0,2),; //UF
		SubStr(cCTE, 3, 4),;  // AAMM Emissão
		SubStr(cCTE, 7, 14),; // CNPJ Emitente
		SubStr(cCTE, 21, 2),; // Modelo
		SubStr(cCTE, 23, 3),; // Série
		SubStr(cCTE, 26, 9),; // Numero Cte
		SubStr(cCTE, 35, 1),; // Forma Emissão	
		SubStr(cCTE, 36, 8),; // Código Numérico
		SubStr(cCTE, 44, 1),; // Dígito Verificador	
		.T.,;
		})

		cEmissorCte := aRet[1][3]

		BeginSql Alias cAliasGU3
			SELECT 	GU3.GU3_CDEMIT,
					GU3.GU3_NMEMIT
			FROM %TABLE:GU3% GU3
			WHERE GU3.GU3_IDFED = %Exp:cEmissorCte%
			AND GU3.%NotDel%
		EndSql

		If (cAliasGU3)->(!Eof())
			cCodEmit 	:= (cAliasGU3)->GU3_CDEMIT
			cNomEmit	:= (cAliasGU3)->GU3_NMEMIT

			aAdd(aRet,{cCodEmit,cNomEmit})
		Else
			MsgStop("Transportador não encontrado com o CNPJ: "+ cEmissorCte + ".", "Atenção")
			aRet[1][10] := .F.
		EndIf 
	Else
		MsgStop("Tamanho da chave de CT-e inválido!", "Atenção")
		aRet		:= Array(1,10)
		aRet[1][10] := .F.
	EndIf

Return aRet

Static Function GetTransp()
	Local aTrp 	 := {}
	Local aAreaGWU := GWU->( GetArea() )
	Local cAliasGWD := GetNextAlias()

	GWU->( dbSetOrder(1) )
	
	If GWU->( dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC) )
		
		While GWU->( !Eof() ) .And. ;
		      GWU->GWU_FILIAL == GW1->GW1_FILIAL .And. ;
		      GWU->GWU_CDTPDC == GW1->GW1_CDTPDC .And. ;
		      GWU->GWU_EMISDC == GW1->GW1_EMISDC .And. ;
		      GWU->GWU_SERDC == GW1->GW1_SERDC .And. ;
		      GWU->GWU_NRDC == GW1->GW1_NRDC
		      
			If GWU->GWU_PAGAR == "1"
				aAdd(aTrp, AllTrim(GWU->GWU_CDTRP) + "=" + AllTrim(Posicione("GU3",1,xFilial("GU3")+GWU->GWU_CDTRP,"GU3_NMEMIT")))
			EndIf
			
			GWU->( dbSkip() )
		EndDo
	EndIf
 
	BeginSQL Alias cAliasGWD
		SELECT GWD.GWD_PRESTS, GU3.GU3_NMEMIT
		FROM %Table:GWL% GWL
		LEFT JOIN %Table:GWD% GWD
		ON GWD.GWD_FILIAL = GWL.GWL_FILIAL
		AND GWD.GWD_NROCO = GWL.GWL_NROCO
		AND GWD.%NotDel%
		LEFT JOIN %Table:GU3% GU3
		ON GU3.GU3_FILIAL = %xFilial:GU3%
		AND GU3.GU3_CDEMIT = GWD.GWD_PRESTS
		AND GU3.%NotDel%
		WHERE GWL.GWL_FILDC = %Exp:GW1->GW1_FILIAL%
		AND GWL.GWL_TPDC = %Exp:GW1->GW1_CDTPDC%
		AND GWL.GWL_EMITDC = %Exp:GW1->GW1_EMISDC%
		AND GWL.GWL_SERDC = %Exp:GW1->GW1_SERDC%
		AND GWL.GWL_NRDC = %Exp:GW1->GW1_NRDC%
		AND GWL.%NotDel%
	EndSql

	While (cAliasGWD)->(!Eof())
		aAdd(aTrp, AllTrim((cAliasGWD)->GWD_PRESTS)+ "=" + AllTrim((cAliasGWD)->GU3_NMEMIT))
		(cAliasGWD)->( dbSkip() )
	EndDo
	(cAliasGWD)->(dbCloseArea())

	RestArea( aAreaGWU )
Return aTrp
//--------------------------------------------------------------------
Static Function GetEspecies()
	Local aEspecies := {}
	Local aArea
	
	dbSelectArea("GVT")
	aArea := GVT->( GetArea() )
	GVT->( dbSetOrder(2) )
	GVT->( dbSeek(xFilial("GVT")) )
	
	While GVT->( !Eof() ) 
		If GVT->GVT_SIT == "1"
			aAdd(aEspecies, AllTrim(GVT->GVT_CDESP) + "=" + AllTrim(GVT->GVT_DSESP))
		EndIf
		
		GVT->( dbSkip() )
	EndDo
	
	RestArea( aArea )
Return aEspecies
//--------------------------------------------------------------------
//
// Validação se o doc carga pode ser adicionado ao documento de frete
// Obs: a validação completa do programa GFEA065 é realizada na confirmação da tela
//
Function GFEA065B08_ValidaDC(cCdTpDc, cEmisDc, cSerDC, cNRDC)
	Local lRet    	:= .T.
	Local aArea      	:= GetArea()
	Local aAreaGW1, aAreaGWN, aAreaGWU
	
	dbSelectArea("GW1")
	dbSelectArea("GWN")
	dbSelectArea("GWU")
	
	aAreaGW1 := GW1->( GetArea() )
	aAreaGWN := GWN->( GetArea() )
	aAreaGWU := GWU->( GetArea() )
	
	// Verifica se o Documento de Carga existe e se o romaneio vinculado está Liberado
	
	GW1->( dbSetOrder(1) )
	If !GW1->( dbSeek(xFilial("GW1")+cCdTpDc+cEmisDc+cSerDC+cNRDC) )
		MsgStop("Documento de Carga não existe", "Atenção")
		lRet := .F.
	Else
		GWN->( dbSetOrder(1) )
		If GWN->( dbSeek(xFilial('GWN')+GW1->GW1_NRROM) )
			If !(GWN->GWN_SIT $ '3,4')
				MsgStop("O Romaneio relacionado a este Documento de Carga deve estar liberado ou encerrado.", "Atenção")
	   			lRet := .F.
	   		EndIf
	   	Else
	   		MsgStop("Não há romaneio relacionado ao Documento de Carga.", "Atenção")
   			lRet := .F.
		EndIf
	EndIf
	
	// Não permitir incluir Documentos de Carga na situação Cancelado ou Sinistradas
	If lRet
		If GW1->GW1_SIT == "7"
			MsgStop("Não é possível vincular um Documento de Carga Cancelado", "Atenção")
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		
		lRet := .F.
		
		GWU->( dbSetOrder(1) )
	
		If GWU->( dbSeek(xFilial("GW1")+cCdTpDc+cEmisDc+cSerDC+cNRDC) )
			
			While GWU->( !Eof() ) .And. ;
			      GWU->GWU_FILIAL == xFilial("GW1") .And. ;
			      GWU->GWU_CDTPDC == cCdTpDc .And. ;
			      GWU->GWU_EMISDC == cEmisDc .And. ;
			      GWU->GWU_SERDC == cSerDC .And. ;
			      GWU->GWU_NRDC == cNRDC
			      
				If GWU->GWU_PAGAR == "1"
					lRet := .T.
					Exit
				EndIf
				
				GWU->( dbSkip() )
			EndDo
		EndIf
		
		If !lRet
			MsgStop("Documento de carga não tem trechos a pagar!", "Atenção")
		EndIf
			
	EndIf
	
	RestArea(aAreaGW1)
	RestArea(aAreaGWU)
	RestArea(aAreaGWN)
	RestArea(aArea)

Return lRet

//--------------------------------------------------------------------
Static Function GFEA065B09_SellAll()
	Local nCount
	
	For nCount := 1 To Len(aDoctos)
		aDoctos[nCount][1] := .T.
	Next	
Return
