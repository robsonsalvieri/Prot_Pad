#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "OFIA484.CH"

Function OFIA484()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VB5')
	oBrowse:SetDescription(STR0001) //'Sugestão de compra'
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA484')

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStrVB5 := FWFormStruct(1, "VB5")

	oModel := MPFormModel():New('OFIA484',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oModel:AddFields('VB5MASTER',/*cOwner*/ , oStrVB5)
	oModel:SetPrimaryKey( { "VB5_FILIAL", "VB5_CODIGO" } )
	oModel:SetDescription(STR0001)
	oModel:GetModel('VB5MASTER'):SetDescription(STR0002) //"Dados de sugestão de compra"

	oModel:InstallEvent("OFIA484EVDEF", /*cOwner*/, OFIA484EVDEF():New("OFIA484") )

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVB5:= FWFormStruct(2, "VB5")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'VB5', 100)
	oView:AddField('VIEW_VB5', oStrVB5, 'VB5MASTER')
	oView:EnableTitleView('VIEW_VB5', STR0001)
	oView:SetOwnerView('VIEW_VB5','VB5')

Return oView

/*/{Protheus.doc} OA4840015_ItemSugestaoCompra
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 25/11/2022
/*/

Function OA4840015_ItemSugestaoCompra(cFilOrc, cNumOrc, cCodProd, cGruIte, cCodIte, cSeqIte, cSugCom, cPedCpa, cItePed, cSolCpa, cIteSol, cFornece, cLoja, lSaldo, cCondVB5, lOrdDec, lROrcCan, cFilOs, cNumOs)

	Local cFiltro   := ""

	Default cGruIte := ""
	Default cCodIte := ""
	Default cFilOrc := ""
	Default cNumOrc := ""
	Default cSugCom := ""
	Default cPedCpa := ""
	Default cItePed := ""
	Default cSolCpa := ""
	Default cIteSol := ""
	Default cFornece:= ""
	Default cLoja   := ""
	Default lSaldo  := .f.
	Default lOrdDec := .t.
	Default lROrcCan:= .f.

	//Filtros da Sugestão de Compra
	cFiltro := 	" VB5.VB5_FILIAL = '" + xFilial("VB5") + "' "
	cFiltro += 	" AND VB5.D_E_L_E_T_ = ' ' "

	If !Empty(cSugCom)
		cFiltro += 	" AND VB5.VB5_CODSFJ = '" + cSugCom + "' "
	EndIf

	If !Empty(cPedCpa)
		cFiltro += 	" AND VB5.VB5_PEDCPA = '" + cPedCpa + "' "
	EndIf

	If !Empty(cItePed)
		cFiltro += 	" AND VB5.VB5_ITEPED = '" + cItePed + "' "
	EndIf

	If !Empty(cFilOrc) .and. !Empty(cNumOrc)
		cFiltro += 	" AND VB5.VB5_ORIGEM = '1' "
		cFiltro += 	" AND VB5.VB5_FILORC = '" + cFilOrc + "' "
		cFiltro += 	" AND VB5.VB5_NUMORC = '" + cNumOrc + "' "
	EndIf

	If !Empty(cFilOs) .and. !Empty(cNumOs)
		cFiltro += 	" AND VB5.VB5_ORIGEM = '2' "
		cFiltro += 	" AND VB5.VB5_FILORC = '" + cFilOs + "' "
		cFiltro += 	" AND VB5.VB5_NUMORC = '" + cNumOs + "' "
	EndIf
	
	If !Empty(cCodProd)
		cFiltro += 	" AND VB5.VB5_COD = '" + cCodProd + "'"
	Else
		If !Empty(cGruIte) .and. !Empty(cCodIte)
			cFiltro += 	" AND VB5.VB5_GRUITE = '" + cGruIte + "'"
			cFiltro += 	" AND VB5.VB5_CODITE = '" + cCodIte + "' "
		EndIf
		If !Empty(cSeqIte)
			cFiltro += 	" AND VB5.VB5_SEQITE = '" + cSeqIte + "' "
		EndIf
	EndIf

	If lROrcCan
		cFiltro += " AND ( EXISTS ( "
		cFiltro += 				" SELECT VS1_NUMORC "
		cFiltro += 				" FROM " + RetSqlName("VS1") + " VS1 "
		cFiltro += 				" WHERE VS1.VS1_FILIAL = VB5.VB5_FILORC "
		cFiltro += 					" AND VS1.VS1_NUMORC = VB5.VB5_NUMORC "
		cFiltro += 					" AND VS1.VS1_STATUS <> 'C' "
		cFiltro += 					" AND VS1.D_E_L_E_T_ = ' ' ) "
		cFiltro += 		" OR EXISTS ( "
		cFiltro += 				" SELECT VSJ_NUMOSV "
		cFiltro += 				" FROM " + RetSqlName("VSJ") + " VSJ "
		cFiltro += 				" WHERE VSJ.VSJ_FILIAL = VB5.VB5_FILOSV "
		cFiltro += 					" AND VSJ.VSJ_NUMOSV = VB5.VB5_NUMOSV "
		cFiltro += 					" AND VSJ.VSJ_CODIGO = VB5.VB5_CODVSJ "
		cFiltro += 					" AND VSJ.VSJ_MOTPED = ' ' "
		cFiltro += 					" AND VSJ.D_E_L_E_T_ = ' ' ) "
		cFiltro += " ) "
	EndIf

	If !Empty(cCondVB5)
		cFiltro += " AND " + cCondVB5
	EndIf

	If lSaldo
		Return OA4840035_SaldoItemSugestaoCompra(cFiltro)
	EndIf

Return OA4840045_ItensSugestaoCompra(cFiltro,cSolCpa,cIteSol,lOrdDec)

/*/{Protheus.doc} OA4840025_NumeroSugestaoCompra
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 25/11/2022
/*/

Function OA4840025_NumeroSugestaoCompra(cTipoSug,lNovaSug)

	Local cCodSug := ""
	Local lAglSug := GetNewPar("MV_MIL0053","S") == "S"
	Local lNewRes := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?

	Default lNovaSug := .f.
	Default lGerNro  := .t.
	
	VEJ->( DbSetOrder(2) )
	VEJ->( DbSeek(xFilial("VEJ") + cTipoSug ) )

	If lAglSug .and. lNewRes

		cQuery := "SELECT SFJ.FJ_CODIGO "
		cQuery += "FROM " + RetSQLName("SFJ") + " SFJ "
		cQuery += "WHERE SFJ.FJ_FILIAL = '" + xFilial("SFJ") +"' "
		cQuery += 	"AND SFJ.FJ_TIPPED = '" + VEJ->VEJ_TIPPED + "' "
		cQuery += 	"AND SFJ.FJ_SOLICIT = ' ' "
		cQuery += 	"AND SFJ.FJ_FORNECE = ' ' "
		cQuery += 	"AND SFJ.FJ_LOJA = ' ' "
		cQuery += 	"AND SFJ.FJ_FILENT = ' ' "
		cQuery += 	"AND SFJ.FJ_COND = ' ' "
		cQuery += 	"AND SFJ.D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY 1 DESC"

		cCodSug := FM_SQL(cQuery)

		If Empty(cCodSug)

			lNovaSug := .t.

		EndIf

	Else

		lNovaSug := .t.

	EndIf

	If lNovaSug

		While .T.
			cCodSug  := GetSXENum("SFJ","FJ_CODIGO",,1)
			SFJ->(DBSetOrder(1))
			If SFJ->(DBSeek(xFilial("SFJ") + cCodSug))
				ConfirmSX8()
			Else
				Exit
			Endif
		Enddo

	EndIf

Return cCodSug



/*/{Protheus.doc} OA4840035_SaldoItemSugestaoCompra
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 20/12/2022
/*/

Function OA4840035_SaldoItemSugestaoCompra(cFiltro)

	Local cQuery   := ""
	Local nRetorno := 0

	//Query de execução para levantamento das informações
	cQuery := "SELECT "
	cQuery += " SUM(VB5.VB5_QTDSUG) "
	cQuery += "FROM " + RetSqlName("VB5") + " VB5 "
	cQuery += " WHERE "
	cQuery += cFiltro

	nRetorno := FM_SQL(cQuery)

Return nRetorno

/*/{Protheus.doc} OA4840035_SaldoItemSugestaoCompra
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 20/12/2022
/*/

Function OA4840045_ItensSugestaoCompra( cFiltro, cSolCpa, cIteSol, lOrdDec )

	Local cQuery   := ""
	Local aRetorno := {}

	Default cFornece := ""
	Default cLoja    := ""
	Default lOrdDec  := .t.

	cQuery := "SELECT "
	cQuery += " VB5.R_E_C_N_O_ AS VB5RECNO "
	cQuery += "FROM " + RetSqlName("VB5") + " VB5 "
	cQuery += " WHERE "
	cQuery += cFiltro

	If lOrdDec
		cQuery += " ORDER BY VB5_CODIGO DESC"
	EndIf

	TcQuery cQuery New Alias "TMPVB5"

	While !TMPVB5->(Eof())

		aAdd(aRetorno,{TMPVB5->VB5RECNO, cSolCpa, cIteSol})
		TMPVB5->(DbSkip())

	EndDo

	TMPVB5->(DbCloseArea())

Return aRetorno


/*/{Protheus.doc} OA4840095_BaixaMovimentoCompra
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 20/12/2022
/*/

Function OA4840095_BaixaMovimentoCompra( cPedido, cItePed, cCodProd, cTesEnt, nQtdCom, cFornece, cLoja, cFilNf, cNotaFis, cSerNf, cAmrLoc )

	Local aRestArea := sGetArea()

	aRestArea := sGetArea(aRestArea,"VS1")
	aRestArea := sGetArea(aRestArea,"VS3")

	If !OA4840065_ValidaNotaFiscalEntrada(cTesEnt)
		Return
	EndIf

	OA4840105_BaixaTransferenciaFilial( cCodProd, nQtdCom, cFornece, cLoja, cFilNf, cNotaFis, cSerNf)
	OA4840055_BaixaSugestaoCompra( cPedido, cItePed, cCodProd, nQtdCom, cFornece, cLoja, cNotaFis, cSerNf, cAmrLoc)

	DbSelectArea("VS1")
	sRestArea(aRestArea)

Return

/*/{Protheus.doc} OA4840055_BaixaSugestaoCompra
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 20/12/2022
/*/

Function OA4840055_BaixaSugestaoCompra( cPedido, cItePed, cCodProd, nQtdCom, cFornece, cLoja, cNotaFis, cSerNf, cAmrLoc)

	Local nI      := 0
	Local aResIte := {}
	Local cOriReg := ""

	aInfCpa := OA4840075_PedidoCompra( cCodProd, cPedido, cItePed, cFornece, cLoja)

	For nI := 1 to Len(aInfCpa)

		VB5->(DbGoTo(aInfCpa[nI,1]))

		cOriReg := VB5->VB5_ORIGEM

		If !OA4840065_ValidaNotaFiscalEntrada(,VB5->VB5_NUMORC,VB5->VB5_NUMOSV,VB5->VB5_GRUITE,VB5->VB5_CODITE,cOriReg)
			Loop
		Endif

		nQtdRes := If( VB5->VB5_QTDAGU >= nQtdCom , nQtdCom, VB5->VB5_QTDAGU )

		// Atualiza o Registro de Ocorrencia de Sug. de Compra
		aItem := {}
		aadd(aItem,{"VB5_CODIGO" , VB5->VB5_CODIGO			, Nil})
		aadd(aItem,{"VB5_PEDCPA" , cPedido					, Nil})
		aadd(aItem,{"VB5_ITEPED" , cItePed					, Nil})
		aadd(aItem,{"VB5_QTDAGU" , VB5->VB5_QTDAGU - nQtdRes, Nil})

		oModelVB5 := FWLoadModel( 'OFIA484' )
		FWMVCRotAuto(oModelVB5,"VB5",MODEL_OPERATION_UPDATE,{{"VB5MASTER", aItem}})

		If cOriReg == "1"

			OA4840125_NroOrcamentoBalcao(VB5->VB5_FILORC, VB5->VB5_NUMORC, VB5->VB5_SEQITE, VB5->VB5_GRUITE, VB5->VB5_CODITE, VB5->VB5_CODIGO, nQtdRes, @aResIte, "SU", "11", cFornece, cLoja , cNotaFis, cSerNf )

		ElseIf cOriReg == "2"

			OA4840135_NroOrdemServico(VB5->VB5_FILOSV, VB5->VB5_NUMOSV, VB5->VB5_GRUITE, VB5->VB5_CODITE, VB5->VB5_CODIGO, VB5->VB5_CODVSJ, nQtdRes, @aResIte, "SUOF", "12", cFornece, cLoja , cNotaFis, cSerNf, cAmrLoc )

		EndIf

		nQtdCom -= nQtdRes

	Next

	If Len(aResIte) > 0
		OA4840085_ReservaItemSugestao(aResIte,"R")
	EndIf

Return

/*/{Protheus.doc} OA4840065_ValidaBaixaSugestaoCompra
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 20/12/2022
/*/

Function OA4840065_ValidaNotaFiscalEntrada(cTesEnt,cNUMORC,cNUMOSV,cGRUITE,cCODITE,cORIGEM)

	Default cTesEnt := ""
	Default cNUMORC := ""
	Default cNUMOSV := ""
	Default cGRUITE := ""
	Default cCODITE := ""
	Default cORIGEM := ""

	If !Empty(cTesEnt)
		DbSelectArea("SF4")
		DbSeek( xFilial("SF4") + cTesEnt)
		If SF4->F4_ESTOQUE == "N"
			Return .f.
		EndIf
	EndIf

	if cORIGEM == "1"
		If !Empty(cNUMORC)
			If OX001020B_RetornaStatusOrcamento(,cNUMORC,cGRUITE,cCODITE) == "C" // se status for igual a cancelado, deve armazenar no padrão
				Return .f.
			EndIf
		EndIf
	Else
		If !Empty(cNUMOSV)
			If OM0100015_RetornaStatusOS(cNUMOSV,cGRUITE,cCODITE) == "C" // se status for igual a cancelado, deve armazenar no padrão
				Return .f.
			EndIf
		Endif
	EndIf

Return .t.

/*/{Protheus.doc} OA4840075_PedidoCompra
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 20/12/2022
/*/

Function OA4840075_PedidoCompra(cCodProd, cPedido, cItePed, cFornece, cLoja)

	Local aRetorno := {}
	Local cQuery   := ""

// Não contemplará o tratamento para Solicitações de Pedido uma vez que dependendo do processo executado o vinculo
// com a sugestão de compra é perdido, por exemplo: geração de cotações ou aglutinação de solicitações de pedido

	cQuery := "SELECT SFJ.FJ_CODIGO"
	cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
	cQuery += 	" JOIN " + RetSqlName("SFJ") + " SFJ "
	cQuery += 		"  ON SFJ.FJ_FILIAL = '" + xFilial("SFJ") + "'"
	cQuery += 		" AND SFJ.FJ_SOLICIT = SC7.C7_NUM "
	cQuery += 		" AND SFJ.FJ_FORNECE = SC7.C7_FORNECE "
	cQuery += 		" AND SFJ.FJ_LOJA = SC7.C7_LOJA"
	cQuery += 		" AND SFJ.FJ_TIPGER = '2' "
	cQuery += 		" AND SFJ.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SC7.C7_FILIAL = '" +xFilial("SC7")+ "' "
	cQuery += 	" AND SC7.C7_NUM  = '" +cPedido+ "'"
	cQuery += 	" AND SC7.C7_ITEM = '" +cItePed+ "'"
	cQuery += 	" AND SC7.C7_PRODUTO = '" +cCodProd+ "'"
	cQuery += 	" AND SC7.C7_FORNECE = '" +cFornece+ "'"
	cQuery += 	" AND SC7.C7_LOJA    = '" +cLoja   + "'"
	cQuery += 	" AND SC7.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPSC7"

	If !TMPSC7->(Eof())

		cCondVB5 := "VB5_QTDAGU > 0"

		aRetorno := aClone( OA4840015_ItemSugestaoCompra( , , cCodProd, , , ,TMPSC7->FJ_CODIGO , , , , , cFornece, cLoja, , cCondVB5, .f., .t.) )

	EndIf

	TMPSC7->(DbCloseArea())

Return aRetorno

/*/{Protheus.doc} OA4840085_ReservaItemSugestao
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 20/12/2022
/*/

Function OA4840085_ReservaItemSugestao(aReserv,cOperacao)

	Local nI := 0
	Local nRecNo  := 0
	Local cOrigem := ""
	Local cTipo   := ""
	Local aRegRes := {}

	Default aReserv := {}

	For nI := 1 to Len(aReserv)

		nRecNo  := aReserv[nI,1]
		cOrigem := aReserv[nI,2]
		cTipo   := aReserv[nI,3]
		aRegRes := aReserv[nI,4]

		If cOrigem == "SU" .or. cOrigem == "TR"
			DbSelectArea("VS1")
			VS1->(DbGoTo(nRecNo))
		ElseIf cOrigem == "SUOF"
			DbSelectArea("VSJ")
			VSJ->(DbGoTo(nRecNo))
		EndIf

		cDocto := OA4820015_ProcessaReservaItem( cOrigem, nRecNo,"A",cOperacao,aRegRes,cTipo)

		/*
			Quando quando for feita uma sugestão de compras oficina com a reserva oficina desativada será feita uma VSJ duplicada
			apenas com as quantidades aguardadas no pedido de compra
			Os campo referente a quantidade serão incrementados de acordo com a quantidade que for feita a entrada na nota
		*/
		If SuperGetMV("MV_RITEORC") == "N" .AND. cOrigem == "SUOF" .AND. VSJ->VSJ_QTDDIG <= 0
			RecLock("VSJ",.f.)
				VSJ->VSJ_QTDINI := VSJ->VSJ_QTDRES
				VSJ->VSJ_QTDITE := VSJ->VSJ_QTDRES
			MsUnLock()
		EndIf
	Next

Return

/*/{Protheus.doc} OA4840105_BaixaTransferenciaItem
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/01/2023
/*/

Function OA4840105_BaixaTransferenciaFilial( cCodProd, nQtdCom, cFornece, cLoja, cFilNf, cNotaFis, cSerNf )

	Local nQtdRes := 0
	Local aRecVDD := {}
	Local aResIte := {}
	Local nI      := 0
	Local lVDDNUMOSV  := VDD->(FieldPos("VDD_NUMOSV")) > 0

	aRecVDD := OA4840115_NroTransferenciaItem(cCodProd, cFornece, cLoja, cFilNf, cNotaFis, cSerNf)

	For nI := 1 to Len (aRecVDD)

		VDD->(DbGoTo(aRecVDD[nI]))

		If !OA4840065_ValidaNotaFiscalEntrada(,VDD->VDD_NUMORC,,VDD->VDD_GRUPO,VDD->VDD_CODITE,"1")
			Loop
		Endif

		nQtdRes := If(VDD->VDD_QUANT >= nQtdCom , nQtdCom , VDD->VDD_QUANT)

		If lVDDNUMOSV .and. Empty(VDD->VDD_NUMORC)
			OA4840135_NroOrdemServico(VDD->VDD_FILOSV, VDD->VDD_NUMOSV, VDD->VDD_GRUPO, VDD->VDD_CODITE, , VDD->VDD_CODVSJ, nQtdRes, @aResIte, "TROF", "15" )
		Else
			OA4840125_NroOrcamentoBalcao(VDD->VDD_FILORC, VDD->VDD_NUMORC, , VDD->VDD_GRUPO, VDD->VDD_CODITE, , nQtdRes, @aResIte, "TR", "15" )
		EndIf

		DbSelectArea("VDD")
		RecLock("VDD",.f.)
			VDD->VDD_STATUS := "C"
		MsUnLock()

		nQtdCom -= nQtdRes

	Next

	If Len(aResIte) > 0
		OA4840085_ReservaItemSugestao(aResIte,"R")
	EndIf

Return

/*/{Protheus.doc} OA4840105_BaixaTransferenciaItem
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/01/2023
/*/

Function OA4840115_NroTransferenciaItem(cCodProd, cFornece, cLoja, cFilNf, cNotaFis, cSerNf)

	Local aRetVDD := {}
	Local cQuery  := ""
	Local oSqlHlp := DMS_SqlHelper():New()

	Local lVDDFILOSV:= VDD->(FieldPos("VDD_FILOSV")) > 0

	cQuery := "SELECT VDD.R_E_C_N_O_ "
	cQuery += "FROM " + RetSQLName("VDD") + " VDD "
	cQuery += "JOIN " + RetSQLName("SB1") + " SB1 "
	cQuery += 	"  ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += 	" AND SB1.B1_COD    = '" + cCodProd + "' "
	cQuery +=	 	" AND SB1.B1_GRUPO  = VDD.VDD_GRUPO "
	cQuery +=	 	" AND SB1.B1_CODITE = VDD.VDD_CODITE "
	cQuery += 	" AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE VDD.VDD_FILIAL = '" + xFilial("VDD") + "' "
	
	cQuery +=	 " AND "
	cQuery +=	 " ( "
	cQuery +=	 " VDD.VDD_FILORC = '" + cFilNf + "' "

	If lVDDFILOSV
		cQuery +=	 " OR VDD.VDD_FILOSV = '" + cFilNf + "' "
	EndIf

	cQuery +=	 " ) "
	cQuery +=	 " AND VDD.VDD_NUMNFI = '" + cNotaFis + "' "
	cQuery +=	 " AND VDD.VDD_SERNFI = '" + cSerNf + "' "
	cQuery +=	 " AND VDD.VDD_CODFOR = '" + cFornece + "' "
	cQuery +=	 " AND VDD.VDD_LOJA   = '" + cLoja + "' "
	cQuery +=	 " AND VDD.VDD_STATUS = 'E' "
	cQuery +=	 " AND VDD.D_E_L_E_T_ = ' ' "

	aRetVDD := oSqlHlp:GetSelectArray(cQuery)

Return aRetVDD

/*/{Protheus.doc} OA4840105_BaixaTransferenciaItem
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/01/2023
/*/

Function OA4840125_NroOrcamentoBalcao(cFilOrc, cNumOrc, cSeqIte, cGruIte, cCodIte, cCodVB5, nQtdRes, aResIte, cOrigem, cTipo, cFornece, cLoja , cNotaFis, cSerNf)

	Local cQuery  := ""
	Local nRecVS3 := 0
	Local nRecVS1 := 0
	Local nPos    := 0

	Default cFilOrc := ""
	Default cNumOrc := ""
	Default cSeqIte := ""
	Default cGruIte := ""
	Default cCodIte := ""
	Default cCodVB5 := ""
	Default cOrigem := ""
	Default cTipo   := ""
	Default nQtdRes := 0
	Default cNotaFis:= ""
	Default cSerNf  := ""
	Default cFornece:= ""
	Default cLoja   := ""

	cQuery := "SELECT VS3.R_E_C_N_O_ VS3RECNO, VS1.R_E_C_N_O_ VS1RECNO "
	cQuery += " FROM " + RetSqlName("VS3") + " VS3 "
	cQuery += " JOIN " + RetSqlName("VS1") + " VS1 "
	cQuery += 	"  ON VS1.VS1_FILIAL = VS3.VS3_FILIAL "
	cQuery += 	" AND VS1.VS1_NUMORC = VS3.VS3_NUMORC "
	cQuery += 	" AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VS3.VS3_FILIAL = '" + cFilOrc + "' "

	If !Empty(cNumOrc)
		cQuery += 	" AND VS3.VS3_NUMORC = '" + cNumOrc + "' "
	EndIf

	If !Empty(cSeqIte)
		cQuery += 	" AND VS3.VS3_SEQUEN = '" + cSeqIte + "' "
	EndIf

	If !Empty(cGruIte)
		cQuery += 	" AND VS3.VS3_GRUITE = '" + cGruIte + "' "
	EndIf

	If !Empty(cCodIte)
		cQuery += 	" AND VS3.VS3_CODITE = '" + cCodIte + "' "
	EndIf

	cQuery += 	" AND VS3.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVS3"

	If !TMPVS3->(Eof())

		// Reserva do item
		nRecVS3 := TMPVS3->VS3RECNO
		nRecVS1 := TMPVS3->VS1RECNO

		nPos := aScan(aResIte,{ |x| x[1] == nRecVS1 }) // Recno VS1
		If nPos == 0
			aAdd(aResIte,{nRecVS1,cOrigem,cTipo,{{nRecVS3,nQtdRes,cCodVB5, cNotaFis, cSerNf, cFornece, cLoja }}})
		Else
			aAdd(aResIte[nPos,4],{nRecVS3,nQtdRes,cCodVB5, cNotaFis, cSerNf, cFornece, cLoja })
		EndIf

	Endif

	TMPVS3->(DbCloseArea())

Return

/*/{Protheus.doc} OA4840105_BaixaTransferenciaItem
	

	@type function
	@author Renato Vinicius de Souza Santos
	@since 03/01/2023
/*/

Function OA4840135_NroOrdemServico(cFilOsv, cNumOsv, cGruIte, cCodIte, cCodVB5, cCodVSJ, nQtdRes, aResIte, cOrigem, cTipo, cFornece, cLoja , cNotaFis, cSerNf, cAmrLoc)

	Local cQuery  := ""
	Local nPos    := 0

	Default cFilOsv := ""
	Default cNumOsv := ""
	Default cGruIte := ""
	Default cCodIte := ""
	Default cCodVB5 := ""
	Default cOrigem := ""
	Default cTipo   := ""
	Default nQtdRes := 0

	cQuery := "SELECT VSJ.R_E_C_N_O_ VSJRECNO "
	cQuery += " FROM " + RetSqlName("VSJ") + " VSJ "
	cQuery += " WHERE VSJ.VSJ_FILIAL = '" + cFilOsv + "' "

	If !Empty(cNumOsv)
		cQuery += 	" AND VSJ.VSJ_NUMOSV = '" + cNumOsv + "' "
	EndIf

	If !Empty(cGruIte)
		cQuery += 	" AND VSJ.VSJ_GRUITE = '" + cGruIte + "' "
	EndIf

	If !Empty(cCodIte)
		cQuery += 	" AND VSJ.VSJ_CODITE = '" + cCodIte + "' "
	EndIf

	If !Empty(cCodVSJ)
		cQuery += 	" AND VSJ.VSJ_CODIGO = '" + cCodVSJ + "' "
	EndIf

	cQuery += 	" AND VSJ.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVSJ"

	If !TMPVSJ->(Eof())

		// Reserva do item
		nRecVSJ := TMPVSJ->VSJRECNO

		nPos := aScan(aResIte,{ |x| x[1] == nRecVSJ }) // Recno VSJ
		If nPos == 0
			aAdd(aResIte,{nRecVSJ,cOrigem,cTipo,{{nRecVSJ,nQtdRes,cCodVB5,cNotaFis,cSerNf,cFornece,cLoja,cAmrLoc}}})
		EndIf

	Endif

	TMPVSJ->(DbCloseArea())

Return
