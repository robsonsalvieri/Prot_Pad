#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'MATXDEF.CH'
#INCLUDE "OFIA001.CH"

/*/{Protheus.doc} OFIA001
Cadastro de tributos gerados
@author Rubens
@since 28/11/2018
@version 1.0


@type function
/*/

Function OFIA001()

	Local oBrowse


	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VW2')
	oBrowse:SetDescription(STR0001) // 'Cadastro de Tributos Gerados'
	oBrowse:Activate()
Return

/*/{Protheus.doc} ModelDef
Modelo de Dados
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Static Function ModelDef()
	
	Local oModel
	Local oStruVW2 := FWFormStruct( 1, 'VW2' )
	
	oModel := MPFormModel():New('OFIA001' )
	oModel:AddFields( 'MODEL_VW2',/*cOwner*/, oStruVW2)
	oModel:SetDescription( STR0002 )
	oModel:GetModel( 'MODEL_VW2' ):SetDescription( STR0003 ) // 'Dados de Modelo' 

Return oModel

/*/{Protheus.doc} ViewDef
Modelo de Dados
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Static Function ViewDef()

	Local oModel := FWLoadModel( 'OFIA001' )
	Local oStruVW2 := FWFormStruct( 2, 'VW2' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_VW2', oStruVW2, 'MODEL_VW2' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VW2', 'TELA' )

Return oView

/*/{Protheus.doc} MenuDef
Modelo de Dados
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.OFIA001' OPERATION 2 ACCESS 0 // 'Visualizar'
	//ADD OPTION aRotina Title STR0015 Action 'VIEWDEF.OFIA001' OPERATION 3 ACCESS 0 // 'Incluir'
	//ADD OPTION aRotina Title STR0016 Action 'VIEWDEF.OFIA001' OPERATION 4 ACCESS 0 // 'Alterar'
	//ADD OPTION aRotina Title STR0017 Action 'VIEWDEF.OFIA001' OPERATION 5 ACCESS 0 // 'Excluir'
	//ADD OPTION aRotina Title STR0018 Action 'VIEWDEF.OFIA001' OPERATION 8 ACCESS 0 // 'Imprimir'
	//ADD OPTION aRotina Title STR0019 Action 'VIEWDEF.OFIA001' OPERATION 9 ACCESS 0 // 'Copiar'
	//ADD OPTION aRotina Title STR0020 Action 'VA0300023_ReplComerc' OPERATION 4 ACCESS 0 // 'Replicar Comercialização'
Return aRotina


/*/{Protheus.doc} OA0010013_GravarTributosPorItem
Gravacao dos tributos de um item 
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Function OA0010013_GravarTributosPorItem(nItem, cIDVW2, nPerc)

	Local nPosFor
	Local aRelImpostos := OA0010043_RelacaoImpostos()
	Local nBkpN        := n
	Local cItemVW2     := ""
	Local nAuxValor    := 0
	Local nAuxbase     := 0
	Local nAuxAliq     := 0
	Local cRefer       := ""
	Local aImpItem     := {}
	Local lConout      := "OFIA001" $ GetNewPar("MV_MILDBG", "NAO")
	local cIdTrib
	local aAuxTribGen
	local lGravouVw2   := .F.
	
	Default cIDVW2 := ""
	Default nPerc := 1

	if ValType(aRelImpostos) <> "A"
		FMX_HELP("OFIA001ER001",STR0005) //Não foi possivel realizar a Gravação de Tributos por Item.
		return ""
	endif

	If empty(cIDVW2)
		cIDVW2 := OA0010023_NextID()
	Else
		OA0010063_ExcluiItens(cIdVW2)
	EndIf

	cItemVW2 := OA0010033_NextItem(cIDVW2)

	If lConout
		LogTrib(aRelImpostos, nItem, cIDVW2, cItemVW2, "Por Item")
	EndIf

	n := nItem
	For nPosFor := 1 To Len(aRelImpostos)

		nAuxValor := 0
		//Pode haver conflito entre nomes de impostos conhecidos TES x Tributo Genérico
		//Evitará de gravar o mesmo imposto mais de uma vez.
		//Cenário: 1 Item calcula ICMS pela TES, outro item, da mesma nota calcula ICMS pelo TG
		//A Função OA0010043_RelacaoImpostos(), que é o MaFisRet, retorna ICM 2 vezes no array, e está correto.
		If aScan(aImpItem, aRelImpostos[nPosFor, 1]) > 0 
			Loop
		EndIf

		lTrbGen := .f.
		If !Empty(aRelImpostos[nPosFor, 6]) .and. !(aRelImpostos[nPosFor, 6] $ "TG/NEW")
			lTrbGen := OA0010105_idTrib(aRelImpostos[nPosFor,6])
		endif
		
		cIdTrib := ""
		If !Empty(aRelImpostos[nPosFor, 6]) .and. !(aRelImpostos[nPosFor, 6] $ "TG/NEW") .and. ! lTrbGen

			nAuxValor := iif( OA0010153_RetFiscal("IT_VAL"  + aRelImpostos[nPosFor, 6]), &('MaFisRet(n,"IT_VAL'  + aRelImpostos[nPosFor, 6] + '")') , 0 )
			nAuxBase  := iif( OA0010153_RetFiscal("IT_BASE" + aRelImpostos[nPosFor, 6]), &('MaFisRet(n,"IT_BASE' + aRelImpostos[nPosFor, 6] + '")') , 0 )
			nAuxAliq  := iif( OA0010153_RetFiscal("IT_ALIQ" + aRelImpostos[nPosFor, 6]), &('MaFisRet(n,"IT_ALIQ' + aRelImpostos[nPosFor, 6] + '")') , 0 )
			cRefer    := "IT_VAL" + aRelImpostos[nPosFor,6]

		ElseIf !Empty(aRelImpostos[nPosFor, 1]) .and. aRelImpostos[nPosFor, 6] == "TG"
			//https://tdn.totvs.com/pages/releaseview.action?pageId=605867908 -- Documentação MaFisRet Tributos Genéricos
			
			aAuxTribGen := MafisRet(n,"IT_TRIBGEN",{aRelImpostos[nPosFor, 1],})
			//varinfo("aAuxTribGen",aAuxTribGen)
			//conout(aRelImpostos[nPosFor, 1])
			//msginfo("aAuxTribGen")
			if len(aAuxTribGen) > 0
				nAuxValor := aAuxTribGen[TG_IT_VALOR]
				nAuxBase  := aAuxTribGen[TG_IT_BASE]
				nAuxAliq  := aAuxTribGen[TG_IT_ALIQUOTA]
				cIdTrib   := aAuxTribGen[TG_IT_IDTRIB]
				cRefer    := "IT_TRIBGEN"
			endif
		EndIf

		
		If nAuxValor <> 0

			aAdd(aImpItem, aRelImpostos[nPosFor, 1])

			cItemVW2 := Soma1(cItemVW2)

			Reclock("VW2",.t.)
				VW2->VW2_FILIAL := xFilial("VW2")
				VW2->VW2_ID     := cIDVW2
				VW2->VW2_ITEM   := cItemVW2
				VW2->VW2_CODTRI := aRelImpostos[nPosFor, 1]
				VW2->VW2_IDTRIB := cIdtrib
				VW2->VW2_REFER  := cRefer
				VW2->VW2_BASE   := nAuxBase * nPerc
				VW2->VW2_ALIQ   := nAuxAliq 
				VW2->VW2_VALOR  := nAuxValor * nPerc
			VW2->(MsUnlock())

			lGravouVw2 := .T.
		EndIf
	Next nPosFor
	n := nBkpN
Return(IIF(lGravouVw2, cIDVW2, "")) // Senão gravou na VW2, retorna vazio 

Function OA0010153_RetFiscal(cRefFiscal)
	Local lRetorno := ! Empty(MaFisScan(cRefFiscal,.F.))
Return lRetorno


/*/{Protheus.doc} OA0010053_GravarTributosTotal
Gravacao dos tributos do cabecalho 
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Function OA0010053_GravarTributosTotal(cIDVW2)

	Local nPosFor
	//Local aRelImpostos := OA0010043_RelacaoImpostos()
	Local aRelImpostos := MaFisRodape(;
		1 /* nTipo */ ,;		// Quebra : 1 Imposto+Aliquota,  2-Imposto
		/* oJanela */ ,;		// Janela onde sera montado
		/* aImpostos */ ,;	// Relacao de Impostos que deverao aparecer ( Codigo )
		/* aPosicao */ ,;			// Array contendo Posicao e Tamanho
		/* bValidPrg */ ,;	// Validacao executada na Edicao dop Campo
		/* lVisual */ ,; // So para visualizacao
		/* cFornIss */ ,; //Fornecedor do ISS
		/* cLojaIss */ ,; //Loja do Fornecedor do ISS
		/* aRecSE2 */ ,;
		/* cDirf */ ,;
		/* cCodRet */ ,;
		/* oCodRet */ ,;
		/* nCombo */ ,;
		/* oCombo */ ,;
		/* dVencIss */ ,; 	//Vencimento ISS
		/* aCodR */ ,;
		/* cRecIss */ ,;	//Informa se recolhe o ISS ou nao
		/* oRecIss */ ,;
		/* lEditImp */ ,;	//Edicao de impostos dos Docs.Fiscais operacao de Inclusao, MV_EDITIMP ativado, Form.Proprio N e Especie NF/NCP/NDP/NDE/NCE (LOCALIZADO)
		/* cDescri */ ,;
		.T. /* lAPI */ )		//Indica se a chamada é realizada por API e portanto não pode exibir tela.

	//Local aRelImpostos := MaFisRet(,"NF_IMPOSTOS")
	Local aTrbGen := {}
	Local cItemVW2     := ""
	Local lConout      := "OFIA001" $ GetNewPar("MV_MILDBG", "NAO")
	local cIdTrib
	local lGravouVw2   := .F.
	
	Default cIDVW2 := ""

	if cPaisLoc == "BRA"
		aTrbGen := MaFisRet(,"NF_TRIBGEN")
	endif

	If empty(cIDVW2)
		cIDVW2 := OA0010023_NextID()
	Else
		OA0010063_ExcluiItens(cIdVW2)
	EndIf

	cItemVW2 := OA0010033_NextItem(cIDVW2)
	
	If lConout
		LogTrib(aRelImpostos,, cIDVW2, cItemVW2, "Total")
	EndIf

	For nPosFor := 1 To Len(aRelImpostos)

		If aRelImpostos[nPosFor,6] $ "NEW"
			Loop
		EndIf
		
		cIdTrib := ""
		If aRelImpostos[nPosFor,6] == "TG"
			if (nPosTrbGen := aScan(aTrbGen, { |x| x[TG_NF_SIGLA] == aRelImpostos[nPosFor,1]})) <> 0
				cIdtrib := aTrbGen[nPosTrbGen,TG_NF_IDTRIB]
			endif
		EndIf

		//If !Empty(aRelImpostos[nPosFor, 6]) .and. !(aRelImpostos[nPosFor, 6] $ "TG/NEW")
		//
		//	nAuxValor := &('MaFisRet(,"NF_VAL'  + aRelImpostos[nPosFor, 6] + '")')
		//	nAuxBase  := &('MaFisRet(,"NF_BASE' + aRelImpostos[nPosFor, 6] + '")')
		//	nAuxAliq  := &('MaFisRet(,"NF_ALIQ' + aRelImpostos[nPosFor, 6] + '")')
		//	cRefer    := "NF_VAL" + aRelImpostos[nPosFor,6]
		//
		//ElseIf !Empty(aRelImpostos[nPosFor, 1]) .and. aRelImpostos[nPosFor, 6] == "TG"
		//	//https://tdn.totvs.com/pages/releaseview.action?pageId=605867908 -- Documentação MaFisRet Tributos Genéricos
		//	
		//	nAuxValor := MafisRet(,"NF_TRIBGEN",{aRelImpostos[nPosFor, 1], 'TG_NF_VALOR'   })
		//	nAuxBase  := MafisRet(,"NF_TRIBGEN",{aRelImpostos[nPosFor, 1], 'TG_NF_BASE'    })
		//	nAuxAliq  := MafisRet(,"NF_TRIBGEN",{aRelImpostos[nPosFor, 1], 'TG_NF_ALIQUOTA'})
		//	cRefer    := "NF_TRIBGEN"
		//endif

		//Conout(aRelImpostos[nPosFor,6] + " - " + aRelImpostos[nPosFor, 1] + " - " + cvaltochar(nauxvalor))

		if aRelImpostos[nPosFor,5] <> 0

			cItemVW2 := Soma1(cItemVW2)

			RecLock("VW2",.t.)
				VW2->VW2_FILIAL := xFilial("VW2")
				VW2->VW2_ID     := cIDVW2
				VW2->VW2_ITEM   := cItemVW2
				VW2->VW2_CODTRI := aRelImpostos[nPosFor,1]
				VW2->VW2_REFER  := IIf(aRelImpostos[nPosFor,6] == "TG", "NF_TRIBGEN", "NF_VAL" + aRelImpostos[nPosFor,1])
				VW2->VW2_IDTRIB := cIdtrib
				VW2->VW2_BASE   := aRelImpostos[nPosFor,3]
				VW2->VW2_ALIQ   := aRelImpostos[nPosFor,4]
				VW2->VW2_VALOR  := aRelImpostos[nPosFor,5]
			VW2->(MsUnlock())

			lGravouVw2 := .T.
		endif

	Next nPosFor

Return (IIF(lGravouVw2, cIDVW2, ""))// Senão gravou na VW2, retorna vazio

/*/{Protheus.doc} OA0010023_NextID

@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Static Function OA0010023_NextID()
	local cNextVW2ID
	dbselectArea("VW2")
	dbGoTop()
	cNextVW2ID := GetSXENum("VW2","VW2_ID")
	ConfirmSx8()
return cNextVW2ID

/*/{Protheus.doc} OA0010033_NextItem

@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Static Function OA0010033_NextItem(cIDVW2)
	local cRetorno := FM_SQL("SELECT MAX(VW2_ITEM) FROM " + RetSQLName("VW2") + " WHERE VW2_FILIAL = '" + xFilial("VW2") + "' AND D_E_L_E_T_ = ' ' AND VW2_ID = '" + cIDVW2 + "' ")
	if empty(cRetorno)
		cRetorno := Replicate("0",tamsx3("VW2_ITEM")[1])
	endif
return cRetorno

/*/{Protheus.doc} OA0010043_RelacaoImpostos

@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
static Function OA0010043_RelacaoImpostos()
return MaFisRet(,"NF_IMPOSTOS")

/*/{Protheus.doc} OA0010063_ExcluiItens

@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Function OA0010063_ExcluiItens(cIdVW2)
	Local cSql  := ""
	Local aArea := GetArea()

	cSql := "SELECT R_E_C_N_O_ REG1 "
	cSql += "FROM " + RetSQLName("VW2") + " VW2 "
	cSql += "WHERE VW2_FILIAL = '" + xFilial("VW2") + "' AND D_E_L_E_T_ = ' ' AND VW2_ID = '" + cIDVW2 + "' "

	TcQuery ChangeQuery(cSql) New Alias "RECVW2"

	While !RECVW2->(Eof())
		VW2->(DbGoto(RECVW2->REG1))
		RecLock("VW2", .F.)
			VW2->(DbDelete())
		VW2->(MsUnlock())

		RECVW2->(DbSkip())
	End

	RECVW2->(DbCloseArea())
	RestArea(aArea)
Return()


/*/{Protheus.doc} LogTrib
Log da gravacao dos impostos
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Static Function LogTrib(aRelImpostos, nFiscal, cIDVW2, cItemVW2, cChamada)

	//Local nTamFiscal := MaFisRet(,"NF_QTDITENS")
	Local nPosFor    := 0

	Default nFiscal  := 0

	Conout(" ")
	Conout(" __   ___  __              __                       __   __   __  ___  __   __  ")
	Conout("|__) |__  /__` |  |  |\/| /  \             |  |\/| |__) /  \ /__`  |  /  \ /__` ")
	Conout("|  \ |___ .__/ \__/  |  | \__/             |  |  | |    \__/ .__/  |  \__/ .__/ ")
	Conout(" ")
	Conout(cChamada)
	Conout(" TOTAL IMPOSTOS                                                                 ")
	Conout(" ")
	varInfo("Impostos " + cChamada,aRelImpostos)
	Conout(" ")

	Conout(" ")

	If nFiscal == 0
		Return()
	EndIf

	n := nFiscal
	Conout("Item N  - " + cValToChar(nFiscal))
	ConOut("IDVW2   - " + cIDVW2)
	ConOut("ITEMVW2 - " + cItemVW2)
	For nPosFor := 1 To len(aRelImpostos)
		ConOut("-------------")
		Conout("Imposto " + PadL(cValToChar(nPosFor), 4, "0"))
		ConOut("-------------")
		ConOut(" ")
		ConOut(" ")
		varInfo("Impostos " + cChamada,aRelImpostos[nPosFor])
		ConOut(" ")
		ConOut(" ")
		If !Empty(aRelImpostos[nPosFor,6]) .and. !(AllTrim(aRelImpostos[nPosFor,6]) $ "NEW/TG")
			Conout("    IT_BASE - " + aRelImpostos[nPosFor,6] + " - " + cvaltochar(&('MaFisRet(n,"IT_BASE' + aRelImpostos[nPosFor,6] + '")')) )
			Conout("    IT_ALIQ - " + aRelImpostos[nPosFor,6] + " - " + cvaltochar(&('MaFisRet(n,"IT_ALIQ' + aRelImpostos[nPosFor,6] + '")')) )
			Conout("    IT_VAL - " + aRelImpostos[nPosFor,6] + " - " + cvaltochar(&('MaFisRet(n,"IT_VAL' + aRelImpostos[nPosFor,6] + '")')) )
		EndIf

		If aRelImpostos[nPosFor,6] == "TG"

			Conout(" ")
			Conout("    Tributos Genéricos - " + aRelImpostos[nPosFor,1])
			Conout(" ")
			aTribGen := MaFisRet(n,"IT_TRIBGEN",{ aRelImpostos[nPosFor,1]})

			If !Empty(aTribGen)

				Conout("        TG_IT_SIGLA..............: " + cvaltochar(aTribGen[TG_IT_SIGLA]) )
				Conout("        TG_IT_DESCRICAO..........: " + cvaltochar(aTribGen[TG_IT_DESCRICAO]) )
				Conout("        TG_IT_BASE...............: " + cvaltochar(aTribGen[TG_IT_BASE]) )
				Conout("        TG_IT_ID_REGRA...........: " + cvaltochar(aTribGen[TG_IT_ID_REGRA]) )
				Conout("        TG_IT_IDTRIB.............: " + cvaltochar(aTribGen[TG_IT_IDTRIB]) )
				Conout("        TG_IT_DESC_IDTRIB........: " + cvaltochar(aTribGen[TG_IT_DESC_IDTRIB]) )
				Conout("        TG_IT_ALIQUOTA...........: " + cvaltochar(aTribGen[TG_IT_ALIQUOTA]) )
				Conout("        TG_IT_VALOR..............: " + cvaltochar(aTribGen[TG_IT_VALOR]) )
			EndIf

		EndIf 
	Next nPosFor
	Conout(" ")

Return()

/*/{Protheus.doc} OA0010113_ResumoFiscalBrasil
Gera o resumo dos impostos gravados para exibicao na grid de impostos das rotinas de Movimentacao de Veiculos, Orcamento e Ordem de Serviço
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
function OA0010113_ResumoFiscalBrasil(cIdVW2, nTpRetorno, aParResFiscal)
	Local cAlVW2 := "TVW2"
	Local cQuery
	Local lConout      := "OFIA001" $ GetNewPar("MV_MILDBG", "NAO")

	if lConout
		Conout(" ")
		Conout(" __   ___  __              __      ___    __   __            ")
		Conout("|__) |__  /__` |  |  |\/| /  \    |__  | /__` /  `  /\  |    ")
		Conout("|  \ |___ .__/ \__/  |  | \__/    |    | .__/ \__, /~~\ |___ ")
		Conout("                                                             ")
		Conout(" ")
	endif

	cQuery := "SELECT VW2.VW2_CODTRI , VW2.VW2_IDTRIB, F2C.F2C_DESC, F2B.F2B_DESC, VW2.VW2_VALOR " +;
		"FROM " + RetSQLName("VW2") + " VW2 "+;
		" LEFT JOIN " + RetSQLName("F2C") + " F2C ON F2C.F2C_FILIAL = ? AND F2C.F2C_CODIGO = VW2.VW2_IDTRIB AND F2C.D_E_L_E_T_ = ' ' " +;
		" LEFT JOIN " + RetSQLName("F2B") + " F2B ON F2B.F2B_FILIAL = ? AND F2B.F2B_REGRA = VW2.VW2_CODTRI AND F2B.D_E_L_E_T_  = ' '" +;
		" WHERE VW2.VW2_FILIAL = ? " +;
		  " AND VW2.VW2_ID = ?" +;
		  " AND VW2.VW2_REFER IN (?)" +;
		  " AND VW2.VW2_IDTRIB IN (?)" +;
		  " AND VW2.D_E_L_E_T_ = ' '" +;
		" ORDER BY VW2.VW2_CODTRI"

	oExecQuery := FwExecStatement():New(cQuery)

	oExecQuery:SetString(1, FWxFilial("F2C"))
	oExecQuery:SetString(2, FWxFilial("F2B"))
	oExecQuery:SetString(3, FWxFilial("VW2"))
	oExecQuery:SetString(4, cIdVW2)
	oExecQuery:SetIn(5, {'NF_TRIBGE','IT_TRIBGE'} )
	oExecQuery:SetIn(6, OA0010123_ListaIDTributos(2) )
	cAlVW2 := oExecQuery:OpenAlias()

	While ! (cAlVW2)->(Eof())
		aAdd(aParResFiscal, {' ', AllTrim((cAlVW2)->F2B_DESC), (cAlVW2)->VW2_VALOR , (cAlVW2)->VW2_VALOR })
		(cAlVW2)->(dbSkip())
	end

	(cAlVW2)->(dbCloseArea())
	dbSelectarea("VW2")

return

/*/{Protheus.doc} OA0010143_ResumoFiscalMI
Gera o resumo dos impostos gravados para exibicao na grid de impostos das rotinas de Movimentacao de Veiculos, Orcamento e Ordem de Serviço
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
function OA0010143_ResumoFiscalMI(cIdVW2, nTpRetorno, aParResFiscal)
	Local cAlVW2 := "TVW2"
	Local cQuery
	Local lConout      := "OFIA001" $ GetNewPar("MV_MILDBG", "NAO")

	if lConout
		Conout(" ")
		Conout(" __   ___  __              __      ___    __   __            ")
		Conout("|__) |__  /__` |  |  |\/| /  \    |__  | /__` /  `  /\  |    ")
		Conout("|  \ |___ .__/ \__/  |  | \__/    |    | .__/ \__, /~~\ |___ ")
		Conout("                                                             ")
		Conout(" ")
	endif

	cQuery := "SELECT VW2.VW2_CODTRI , VW2.VW2_IDTRIB, FB.FB_DESCR, VW2.VW2_VALOR " +;
		"FROM " + RetSQLName("VW2") + " VW2 "+;
		" LEFT JOIN " + RetSQLName("SFB") + " FB ON FB.FB_FILIAL = ? AND FB.FB_CODIGO = VW2.VW2_CODTRI AND FB.D_E_L_E_T_  = ' '" +;
		" WHERE VW2.VW2_FILIAL = ? " +;
		  " AND VW2.VW2_ID = ?" +;
		  " AND VW2.D_E_L_E_T_ = ' '" +;
		" ORDER BY VW2.VW2_CODTRI"

	oExecQuery := FwExecStatement():New(cQuery)

	oExecQuery:SetString(1, FWxFilial("SFB"))
	oExecQuery:SetString(2, FWxFilial("VW2"))
	oExecQuery:SetString(3, cIdVW2)
	cAlVW2 := oExecQuery:OpenAlias()

	While ! (cAlVW2)->(Eof())
		aAdd(aParResFiscal, {' ', AllTrim((cAlVW2)->FB_DESCR), (cAlVW2)->VW2_VALOR , (cAlVW2)->VW2_VALOR })
		(cAlVW2)->(dbSkip())
	end

	(cAlVW2)->(dbCloseArea())
	dbSelectarea("VW2")

return

/*/{Protheus.doc} OA0010133_ResumoFiscalAtivo
Gera o resumo quando o fiscal esta ativo para exibicao na grid de impostos das rotinas de Movimentacao de Veiculos, Orcamento e Ordem de Serviço 
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
function OA0010133_ResumoFiscalAtivo(nTpRetorno , aParResFiscal, lSemFiltro)
	local aTrbGen
	Local nCntFor
	local cIdTributos
	Local lConout      := "OFIA001" $ GetNewPar("MV_MILDBG", "NAO")

	default lSemFiltro := .f.
	
	if lConout
		Conout(" ")
		Conout(" __   ___  __              __      ___    __   __                    ___         __  ")
		Conout("|__) |__  /__` |  |  |\/| /  \    |__  | /__` /  `  /\  |        /\   |  | \  / /  \ ")
		Conout("|  \ |___ .__/ \__/  |  | \__/    |    | .__/ \__, /~~\ |___    /~~\  |  |  \/  \__/ ")
		Conout("                                                                                     ")
		Conout(" ")
	endif

	if MaFisFound('NF')

		if lSemFiltro
			aResumoFiscal := MaFisRet(,"NF_IMPOSTOS")
			if lConout
				conout(" ")
				varInfo("NF_IMPOSTOS",aResumoFiscal)
				conout(" ")
			endif
			for nCntFor := 1 to Len(aResumoFiscal)
				if aResumoFiscal[nCntFor,IMP_NOME] <> "TG" .and. aResumoFiscal[nCntFor,IMP_VAL] <> 0
					aAdd(aParResFiscal, {' ', AllTrim(aResumoFiscal[nCntFor,IMP_DESC]), aResumoFiscal[nCntFor,IMP_VAL] , aResumoFiscal[nCntFor,IMP_VAL] })
				endif
			next nCntfor
		endif

		aTrbGen := MaFisRet(,"NF_TRIBGEN")
		if lConout
			conout(" ")
			varInfo("NF_TRIBGEN",aTrbGen)
			conout(" ")
		endif

		cIdTributos := OA0010123_ListaIDTributos(1)
		for nCntFor := 1 to Len(aTrbGen)
			if (( ! lSemFiltro .and. (empty(aTrbGen[nCntFor,TG_NF_IDTRIB]) .or. aTrbGen[nCntFor,TG_NF_IDTRIB] $ cIdTributos)) .or. lSemFiltro) .and. aTrbGen[nCntFor,TG_NF_VALOR] <> 0
				//cSQL := "SELECT F2E_DESC FROM " + RetSQLName("F2E") + " WHERE F2E_FILIAL = '" + xFilial("F2E") + "' AND F2E_IDTRIB = '" + aTrbGen[nCntFor,TG_NF_IDTRIB] + "' AND D_E_L_E_T_ = ' '"
				cSQL := "SELECT F2B_DESC FROM " + RetSQLName("F2B") + " WHERE F2B_FILIAL = '" + xFilial("F2B") + "' AND F2B_ID = '" + aTrbGen[nCntFor,TG_NF_ID_REGRA] + "' AND D_E_L_E_T_ = ' '"

				if nTpRetorno == 1
					aAdd(aParResFiscal, {' ', AllTrim(FM_SQL(cSQL)), aTrbGen[nCntFor,TG_NF_VALOR] , aTrbGen[nCntFor,TG_NF_VALOR] })
				endif

			endif
		next nCntfor
	endif

return

/*/{Protheus.doc} OA0010123_ListaIDTributos
Lista de ID de Tributos que serão considerados nos resumos dos impotos fiscais 
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
Function OA0010123_ListaIDTributos(nTpRet)
	do case
		case nTpRet == 1 ; Return "000052/000053/000054/000060/000061/000062/000063/000064/000065/000066/000067/000068/000069/000070"
		case nTpRet == 2 ; Return {"      ","000052","000053","000054","000060","000061","000062","000063","000064","000065","000066","000067","000068","000069","000070"}
	end case
Return ""

/*/{Protheus.doc} OA0010105_idTrib

De Para de um Imposto Legado para o ID do Tributo no Configurador de Tributos

@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
function OA0010105_idTrib(cImpostoLegado, aLstTrbGen, nLinha)
	local lTrbGen := .F.
	local cIdTrib := ""
	Default nLinha := n

	default aLstTrbGen := OA0010075_listaTG(nLinha)

	if cImpostoLegado == "TG"
		return .f.
	endif

	do Case
		//case cImpostoLegado == "" ; cIdTrib := "000002" // FUNRUR	GILRAT - FUNRURAL                                                                                   
		//case cImpostoLegado == "" ; cIdTrib := "000003" // SENAR 	SENAR - SERVIÇO NACIONAL DE APRENDIZAGEM RURAL                                                      
		//case cImpostoLegado == "" ; cIdTrib := "000004" // AFRMM 	AFRMM - Adicional ao Frete para Renovação da Marinha Mercante                                       
		//case cImpostoLegado == "" ; cIdTrib := "000005" // FABOV 	FABOV - Fundo de Apoio a Bovinocultura de Corte                                                     
		//case cImpostoLegado == "" ; cIdTrib := "000006" // FACS  	FACS - Fundo de Apoio à Cultura da Soja                                                             
		//case cImpostoLegado == "" ; cIdTrib := "000007" // FAMAD 	FAMAD - Fundo de Apoio à Madeira                                                                    
		//case cImpostoLegado == "" ; cIdTrib := "000008" // FASEMT	FASE/MT - Fundo Mato-Grossense de Apoio à Cultura da Semente                                        
		//case cImpostoLegado == "" ; cIdTrib := "000009" // FETHAB	FETHAB - Fundo Estadual de Transporte e Habitação                                                   
		//case cImpostoLegado == "" ; cIdTrib := "000010" // FUNDER	FUNDERSUL - Fundo de Desenvolvimento do Sistema Rodoviário do Estado de Mato Grosso do Sul          
		//case cImpostoLegado == "" ; cIdTrib := "000011" // FUNDES	FUNDESA - Fundo de Desenvolvimento e Defesa Sanitária Animal                                        
		//case cImpostoLegado == "" ; cIdTrib := "000012" // IMAMT 	IMA/MT - Instituto Maot-Grossense do Algodão                                                        
		//case cImpostoLegado == "" ; cIdTrib := "000013" // SEST  	SEST/SENAT - Serviço Social do Transporte/Serviço Nacional de Aprendizagem do Transporte            
		//case cImpostoLegado == "" ; cIdTrib := "000014" // TPDP  	TPDP - Taxa de Processamento de Despesa Pública do Estado da Paraíba                                
		case cImpostoLegado == "PS2" ; cIdTrib := "000015" // PIS   	PROGRAMA DE INTEGRAÇÃO SOCIAL                                                                       
		case cImpostoLegado == "CF2" ; cIdTrib := "000016" // COF   	CONTRIBUIÇÃO PARA FINANCIAMENTO DA SEGURIDADE SOCIAL                                                
		//case cImpostoLegado == "" ; cIdTrib := "000017" // II    	IMPOSTO DE IMPORTAÇÃO                                                                               
		case cImpostoLegado == "IRR" ; cIdTrib := "000018" // IRF   	IMPOSTO DE RENDA RETIDO NA FONTE                                                                    
		//case cImpostoLegado == "" ; cIdTrib := "000019" // INSS  	INSS - INSTITUTO NACIONAL DO SEGURO SOCIAL                                                          
		case cImpostoLegado == "ISS" ; cIdTrib := "000020" // ISS   	IMPOSTO SOBRE SERVIÇO                                                                               
		case cImpostoLegado == "ICM" ; cIdTrib := "000021" // ICMS  	ICMS - Imposto sobre Circulação de Mercadorias e Serviços                                           
		case cImpostoLegado == "IPI" ; cIdTrib := "000022" // IPI   	IPI - Imposto sobre Produtos Industrializados                                                       
		//case cImpostoLegado == "" ; cIdTrib := "000023" // CIDE  	CONTRIBUIÇÃO DE INTERVENÇÃO NO DOMÍNIO ECONÔMICO                                                    
		//case cImpostoLegado == "" ; cIdTrib := "000024" // CPRB  	CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE A RECEITA BRUTA                                                   
		//case cImpostoLegado == "" ; cIdTrib := "000025" // FEEF  	FUNDO ESTADUAL DE EQUILÍBRIO FISCAL                                                                 
		case cImpostoLegado == "CSL" ; cIdTrib := "000026" // CSL   	CONTRIBUIÇÃO SOCIAL SOBRE O LUCRO LÍQUIDO                                                           
		//case cImpostoLegado == "" ; cIdTrib := "000027" // PROTEG	FUNDO DE PROTEÇÃO SOCIAL DO ESTADO DE GOIÁS                                                         
		//case cImpostoLegado == "" ; cIdTrib := "000028" // FUMIPQ	FUNDO MUNICIPAL DE FOMENTO À MICRO E PEQUENA EMPRESA                                                
		//case cImpostoLegado == "" ; cIdTrib := "000029" // CRDPRE	CRÉDITO PRESUMIDO PARA ICMS                                                                         
		//case cImpostoLegado == "" ; cIdTrib := "000030" // CRPRST	CREDITO PRESUMIDO SOBRE PRESTACAO SERVICO DE TRANSPORTE COM ICMS/ST                                 
		//case cImpostoLegado == "" ; cIdTrib := "000031" // CPPROD	PRODEPE - PROGRAMA DE DESENVOLVIMENTO DO ESTADO DE PERNAMBUCO                                       
		//case cImpostoLegado == "" ; cIdTrib := "000032" // CRDPCT	CRÉDITO PRESUMIDO PELA CARGA TRIBUTÁRIA                                                             
		//case cImpostoLegado == "" ; cIdTrib := "000033" // SECP15	APOSENTADORIA ESPECIAL 15 ANOS                                                                      
		//case cImpostoLegado == "" ; cIdTrib := "000034" // SECP20	APOSENTADORIA ESPECIAL 20 ANOS                                                                      
		//case cImpostoLegado == "" ; cIdTrib := "000035" // SECP25	APOSENTADORIA ESPECIAL 25 ANOS                                                                      
		//case cImpostoLegado == "" ; cIdTrib := "000036" // INSSPT	INSS PATRONAL                                                                                       
		case cImpostoLegado == "DIFAL" ; cIdTrib := "000037" // DIFAL 	DIFAL - DIFERENCIAL DE ALIQUOTA                                                                     
		case cImpostoLegado == "CMP" ; cIdTrib := "000038" // CMP   	ICMS COMPLEMENTAR                                                                                   
		//case cImpostoLegado == "" ; cIdTrib := "000039" // ANTEC 	ANTECIPAÇÃO DE ICMS                                                                                 
		//case cImpostoLegado == "" ; cIdTrib := "000040" // FECPIC	FECP ICMS - FUNDO DE COMBATE À POBREZA                                                              
		//case cImpostoLegado == "" ; cIdTrib := "000041" // FCPST 	FECP ICMS ST - FUNDO DE COMBATE À POBREZA                                                           
		//case cImpostoLegado == "" ; cIdTrib := "000042" // FCPCMP	FECP ICMS COMPLEMENTAR- FUNDO DE COMBATE À POBREZA                                                  
		//case cImpostoLegado == "" ; cIdTrib := "000043" // COFRET	COFINS RETENÇÃO - CONTRIBUIÇÃO PARA FINANCIAMENTO DA SEGURIDADE SOCIAL                              
		//case cImpostoLegado == "" ; cIdTrib := "000044" // COFST 	COFINS SUBSTITUIÇÃO TRIBUTARIA - CONTRIBUIÇÃO PARA FINANCIAMENTO DA SEGURIDADE SOCIAL               
		//case cImpostoLegado == "" ; cIdTrib := "000045" // PISRET	PIS RETENÇÃO - PROGRAMA DE INTEGRAÇÃO SOCIAL                                                        
		//case cImpostoLegado == "" ; cIdTrib := "000046" // PISST 	PIS SUBSTITUIÇÃO TRIBUTARIA - PROGRAMA DE INTEGRAÇÃO SOCIAL                                         
		//case cImpostoLegado == "" ; cIdTrib := "000047" // ISSBI 	ISS BITRIBUTADO - CPOM                                                                              
		//case cImpostoLegado == "" ; cIdTrib := "000048" // PISMAJ	MAJORAÇÃO DAS ALÍQUOTAS DO PIS/PASEP-IMPORTAÇÃO                                                     
		//case cImpostoLegado == "" ; cIdTrib := "000049" // COFMAJ	MAJORAÇÃO DAS ALÍQUOTAS DO COFINS-IMPORTAÇÃO                                                        
		//case cImpostoLegado == "" ; cIdTrib := "000050" // DED   	DEDUÇÃO ICMS / ISS                                                                                  
		//case cImpostoLegado == "" ; cIdTrib := "000051" // FRTAUT	FRETE AUTONOMO                                                                                      
		//case cImpostoLegado == "" ; cIdTrib := "000052" // ICMDES	DESONERAÇÃO DE ICMS                                                                                 
		//case cImpostoLegado == "" ; cIdTrib := "000052" // DZFICM	DESONERAÇÃO DE ICMS POR ISENÇÃO DE IMPOSTO PARA ZONA FRANCA DE MANAUS                               
		//case cImpostoLegado == "" ; cIdTrib := "000053" // DZFPIS	DESONERAÇÃO DE PIS POR ISENÇÃO DE IMPOSTO PARA ZONA FRANCA DE MANAUS                                
		//case cImpostoLegado == "" ; cIdTrib := "000054" // DZFCOF	DESONERAÇÃO DE COFINS POR ISENÇÃO DE IMPOSTO PARA ZONA FRANCA DE MANAUS                             
		//case cImpostoLegado == "" ; cIdTrib := "000055" // ESTICM	ESTORNO DO CRÉDITO E DÉBITO NA APURAÇÃO DE ICMS                                                     
		case cImpostoLegado == "SOL" ; cIdTrib := "000056" // ICMSST	ICMS SUBSTITUIÇÃO TRIBUTÁRIA                                                                     
		//case cImpostoLegado == "" ; cIdTrib := "000057" // FRTEMB	FRETE EMBARCADOR                                                                                    
		//case cImpostoLegado == "" ; cIdTrib := "000058" // CRDOUT	CRÉDITO OUTORGADO                                                                                   
		//case cImpostoLegado == "" ; cIdTrib := "000059" // STMONO	TRIBUTAÇÃO MONOFÁSICA DE COMBUSTÍVEIS COBRADA ANTERIORMENTE                                         
		//case cImpostoLegado == "" ; cIdTrib := "000060" // IBSEST	IBS ESTADUAL                                                                                        
		//case cImpostoLegado == "" ; cIdTrib := "000061" // IBSMUN	IBS MUNICIPAL                                                                                       
		//case cImpostoLegado == "" ; cIdTrib := "000062" // CBSFED	CBS FEDERAL                                                                                         
		//case cImpostoLegado == "" ; cIdTrib := "000063" // ISFED 	IS FEDERAL                                                                                          
		//case cImpostoLegado == "" ; cIdTrib := "000064" // IBSERG	IBS Estadual Regular - IBS Est. antes de aplicação dos Benefícios.                                  
		//case cImpostoLegado == "" ; cIdTrib := "000065" // IBSMRG	IBS Municipal Regular - IBS Mun. antes de aplicação dos Benefícios.                                 
		//case cImpostoLegado == "" ; cIdTrib := "000066" // CBSREG	CBS Regular - CBS antes de aplicação dos Benefícios.                                                
		//case cImpostoLegado == "" ; cIdTrib := "000067" // IBSCRP	IBS Crédito Presumido.                                                                              
		//case cImpostoLegado == "" ; cIdTrib := "000068" // CBSCRP	CBS Crédito Presumido.                                                                              
		//case cImpostoLegado == "" ; cIdTrib := "000069" // IBSMON	IBS Operação Monofásica.                                                                            
		//case cImpostoLegado == "" ; cIdTrib := "000070" // CBSMON	CBS Operação Monofásica.                                                                            
		//case cImpostoLegado == "" ; cIdTrib := "000071" // FUST  	FUST - Fundo de Universalização dos Serviços de Telecomunicações.                                   
		//case cImpostoLegado == "" ; cIdTrib := "000072" // FUNTTE	FUNTTEL - Fundo para o Desenvolvimento Tecnológico das Telecomunicações.                            
	endcase

	if ! empty(cIdTrib)
		lTrbGen := aScan(aLstTrbGen, { |x| x[1] == cIdTrib .and. x[2] }) > 0
	endif

return lTrbGen

/*/{Protheus.doc} OA0010075_listaTG
Monta uma lista dos tributos que foram calculados e que possuem uma referencia dos impostos legados 
@author Rubens
@since 28/11/2018
@version 1.0

@type function
/*/
static function OA0010075_listaTG(nLinha)
	local aTrib := ListTrbLeg() // CONFXFIS - Função que retorna lista dos tributos legados que estão previstos/contemplados nos tributos genéricos
	Local nX
	local aNFItemTrbGen

	aNFItemTrbGen := MaFisRet(nLinha,"IT_TRIBGEN")

	for nX := 1 to Len(aTrib)
		aTrib[nX][2] := OA0010085_ChkTribLeg(aNFItemTrbGen, aTrib[nX][1])

		//if aTrib[nX][2]
		//	conout("     " + aTrib[nX][1] + "-" + AllTrim(FM_SQL("SELECT F2C_DESC FROM " + RetSQLName("F2C") + " WHERE F2C_FILIAL = '" + xFilial("F2C") + "' AND F2C_CODIGO = '" + aTrib[nX][1] + "' AND D_E_L_E_T_ = ' ' ")))
		//endif
	Next nX
	//	varinfo("aTrib",aTrib)

return aClone(aTrib)

static Function OA0010085_ChkTribLeg(aNFItemTrbGen, cIdtribLeg)
	Local nPosTrib	:= aScan(aNFItemTrbGen,{|x| Alltrim(x[TG_IT_IDTRIB]) == Alltrim(cIdtribLeg)})
Return nPosTrib > 0 .AND. ((aNFItemTrbGen[nPosTrib][TG_IT_BASE] > 0 .Or. aNFItemTrbGen[nPosTrib][TG_IT_VALOR]  > 0) .Or. aNFItemTrbGen[nPosTrib][TG_IT_VL_ZERO] .Or. aNFItemTrbGen[nPosTrib][TG_IT_LOAD])
