//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#include "AP5MAIL.CH"
#Include 'OFIA611.CH'

static aItens := {}

/*/{Protheus.doc} OFIA611

	Gestão de geração de solicitações de Transferência e Sugestão de Compra

@author Renato Vinicius
@since 19/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
 
Function OFIA611( xTipReg, xFILREG, xCODREG, xAutoIte, lMensagem, lReserv )

	Local aArea
	Local oView611  := FWLoadView("OFIA611")
	Local oModel611 := FWLoadModel("OFIA611")

	Default xTipReg  := "1"
	Default xAutoIte := {}
	Default xFILREG  := ""
	Default xCODREG  := ""
	Default lMensagem:= .f.

	Private lOk      := .f.
	Private lContinue:= .t.
	Private lRes     := .f.

	cTipReg := xTipReg
	aItens  := xAutoIte
	cFILREG := xFILREG
	cCODREG := xCODREG

	aArea := sGetArea(,"VS1")
	aArea := sGetArea(aArea,"VS3")
	aArea := sGetArea(aArea,"VSJ")

	If Len(aItens) == 0
		aItens := OA6110065_LevantaItens(cTipReg,cFILREG,cCODREG)
		If Len(aItens) == 0
			lContinue := .f.
		ElseIf lMensagem
			If !MsgNoYes(STR0001) // "Há itens sem estoque. Deseja gerar as solicitações para composição do estoque?"
				lContinue := .f.
			EndIf
		EndIf
	EndIf

	If lContinue

		oModel611:GetModel("MODPARAM"):bLoad := {|oModel| OA6110035_LoadFieldCabec(cTipReg,cFILREG,cCODREG,oModel) }
		oModel611:GetModel("MODDET"):bLoad := {|oModelIte| OA6110045_LoadFieldItens(aItens,oModelIte) }
		oModel611:SetOperation(MODEL_OPERATION_UPDATE)
		oModel611:Activate()

		oStrParam := oView611:GetViewStruct("MODPARAM")
		oStrSolic := oView611:GetViewStruct("MODDET")

		If cTipReg == "3"
			oStrParam:RemoveField("PARCODVS1")
			oStrSolic:RemoveField("SEQUEN")
		Else
			oStrParam:RemoveField("PARCODVO1")
			oStrSolic:RemoveField("CODVSJ")
		EndIf

		oView611:SetModel(oModel611)
		oView611:SetOperation(MODEL_OPERATION_UPDATE)

		oExecView := FWViewExec():New()
		oExecView:setTitle(STR0002) // "Gestão de itens sem estoque"
		oExecView:setModel(oModel611)
		oExecView:SetView(oView611)
		oExecView:SetOperation( MODEL_OPERATION_UPDATE )
		oExecView:setOK({ || .T. })
		oExecView:setCancel({ || .T. })
		oExecView:openView(.T.)
	EndIf

	lReserv := lRes

	sRestArea(aArea)

Return lOk

/*/{Protheus.doc} ModelDef

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function ModelDef()

	Local oModel 

	Local oMModPAR 		:= OA6110015_CamposGridPAR()
	Local oMModDET 		:= OA6110025_CamposGridItens()

	Local oModeloPAR 	:= oMModPAR:GetModel()
	Local oModeloSOL 	:= oMModDET:GetModel()

	Local oModEVDEF := OFIA611EVDEF():New()

	lRes := .f.

	oModeloSOL:AddTrigger( "QTDTRA", "QTDPEND", {|| .T.}, { |oModel| OA6110055_QtdPendente( oModel ) } )
	oModeloSOL:AddTrigger( "QTDAGU", "QTDPEND", {|| .T.}, { |oModel| OA6110055_QtdPendente( oModel ) } )

	oModel := MPFormModel():New( 'OFIA611', /* bPre */, /* bValid */ , {|| lOk := OA6110075_GeraSolicitacao(oModEVDEF,@lRes) } /* bCommit */ , { || lOk := .f., .T. } /* bCancel */ )
	oModel:AddFields('MODPARAM'	, /* cOwner */	, oModeloPAR , /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )

	oModel:AddGrid('MODDET'		,'MODPARAM'		, oModeloSOL , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )

	oModel:AddCalc('CALCTOT', 'MODPARAM', 'MODDET', 'QTDPEND' , 'TOTPEND' , 'SUM',,, STR0003 ) //"Tot Pendente"

	oModel:SetDescription(STR0001)

	oModel:GetModel('MODPARAM'):SetDescription( STR0004 ) // "Parâmetros"
	oModel:GetModel("MODDET"  ):SetDescription( STR0005 ) // "Itens sem estoque"

	oModel:GetModel("MODDET"):SetNoInsertLine( .T. )
	oModel:GetModel("MODDET"):SetNoDeleteLine( .T. )

	oModel:InstallEvent("OFIA611EVDEF", /*cOwner*/, oModEVDEF )

	oModel:SetPrimaryKey({})
	
Return oModel

/*/{Protheus.doc} ViewDef

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'OFIA611' )
	Local oView 	:= Nil

	Local oMModPAR := OA6110015_CamposGridPAR()
	Local oMModDET := OA6110025_CamposGridItens()

	Local oModeloPar := oMModPAR:GetView()
	Local oModeloSOL := oMModDET:GetView()

	Local lNSugest := GetNewPar("MV_SUGCOS","N") == "N"
	Local lNTranf  := GetNewPar("MV_MIL0209",.f.) == .F.

	If lNSugest
		oModeloSOL:RemoveField("QTDAGU")
	EndIf

	If lNTranf
		oModeloSOL:RemoveField("QTDTRA")
	EndIf

	oModeloSOL:RemoveField("QTRARET")
	oModeloSOL:RemoveField("LOCARM")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField('PARSUG'	, oModeloPar , 'MODPARAM')
	oView:EnableTitleView('PARSUG', STR0004 ) // "Parametros"

	oView:AddGrid('ITEMSUG'	, oModeloSOL , 'MODDET')
	oView:EnableTitleView('ITEMSUG', STR0005 ) // "Itens sem estoque"

	oView:CreateHorizontalBox('BOX_PARAM',15)
	oView:SetOwnerView('PARSUG','BOX_PARAM' )

	oView:CreateHorizontalBox('BOX_ITEMSUG',85)
	oView:SetOwnerView('ITEMSUG' ,'BOX_ITEMSUG')

	oView:SetFieldAction( 'QTDTRA', { |oModel, cIDView, cField, xValue| OA6110085_AtualizaTransf( oModel, 'MODDET', cField, xValue ) } )

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})
	
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

/*/{Protheus.doc} OA6110015_CamposGridPAR

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA6110015_CamposGridPAR()

	Local oRetorno := OFDMSStruct():New()
	
	oRetorno:AddField( { ;
				{ "cTitulo"  , STR0006 } ,; // "Tipo Registro"
				{ "cTooltip" , STR0006 } ,;
				{ "cIdField" , "PARTIPOOP" } ,;
				{ "cTipo"    , "C" } ,;
				{ "nTamanho" , 1 } ,;
				{ "lCanChange" , .f. } ,;
				{ "aComboValues" , {"1=" + STR0007, "2=" + STR0008, "3=" + STR0009 } } ; // "Balcão" // "Pedido de Orçamento" // "Oficina"
			})

	oRetorno:AddFieldDictionary( "VS1", "VS1_FILIAL"  , { {"cIdField" , "PARFILIAL" }, { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VS1", "VS1_NUMORC"  , { {"cIdField" , "PARCODVS1" } } )
	oRetorno:AddFieldDictionary( "VO1", "VO1_NUMOSV"  , { {"cIdField" , "PARCODVO1" } } )

Return oRetorno

/*/{Protheus.doc} OA6110025_CamposGridItens

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA6110025_CamposGridItens()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddFieldDictionary( "VSJ", "VSJ_CODIGO" , { {"cIdField" , "CODVSJ"}, { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_SEQUEN" , { {"cIdField" , "SEQUEN"}, { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_GRUITE" , { {"cIdField" , "GRUITE"}, { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_CODITE" , { {"cIdField" , "CODITE"}, { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_QTDITE" , { {"cIdField" , "QTDITE"}, { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_QTDEST" , { {"cIdField" , "QTDEST"} } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_QTDTRA" , { {"cIdField" , "QTDTRA"}, { "lCanChange" , .t. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_QTDAGU" , { {"cIdField" , "QTDAGU"}, { "lCanChange" , .t. } } )
	oRetorno:AddFieldDictionary( "VS3", "VS3_QTDTRA" , { {"cIdField" , "QTRARET"},{ "lCanChange" , .f. } } ) // Campo utilizado para gravar o que foi digitado na tela de distribuição da quantidade a ser transferida
	oRetorno:AddFieldDictionary( "VS3", "VS3_LOCAL"  , { {"cIdField" , "LOCARM"},{ "lCanChange" , .f. } } ) // Campo utilizado para gravar o que foi digitado na tela de distribuição da quantidade a ser transferida

	oRetorno:AddField({ { 'cIdField'     , 'QTDPEND' } ,;
						{ 'cTitulo'      , STR0010 } ,; // "Qnt. Pendente"
						{ 'cTooltip'     , STR0010 } ,; // "Qnt. Pendente"
						{ 'cTipo'        , 'N' } ,;
						{ 'nTamanho'     , 12 } ,;
						{ 'nDecimal'     , 8 },;
						{ 'cPicture'     , GetSX3Cache("VS3_QTDITE","X3_PICTURE")} ,;
						{ 'lVirtual'     , .t. } ,;
						{ 'lCanChange'   , .f. } } )

	oRetorno:AddField({ { "cIdField" , "RECREG" } ,;
						{ "cTitulo"  , "RecNo" } ,;
						{ "cTooltip" , "RecNo" } ,;
						{ "cTipo"    , "N" } ,;
						{ "nTamanho" , 15 } ,;
						{ "lCanChange" , .f. } ,;
						{ "lVirtual" , .t. } })

Return oRetorno

/*/{Protheus.doc} OA6110035_LoadFieldCabec

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA6110035_LoadFieldCabec(cTipReg,cFILREG,cCODREG,oModel)

	Local aRetorno := {}
	Local oStruct := oModel:GetStruct()
	Local aFields := oStruct:GetFields()

	aRetorno := Array(Len(aFields))

	aRetorno[ 1 ] := cTipReg
	aRetorno[ 2 ] := cFILREG
	aRetorno[ 3 ] := cCODREG
	aRetorno[ 4 ] := cCODREG

Return aRetorno

/*/{Protheus.doc} OA6110045_LoadFieldItens

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA6110045_LoadFieldItens(aItens,oModelIte)

	Local nI      := 0
	Local nJ      := 0
	Local oStruct := oModelIte:GetStruct()
	Local aFields := oStruct:GetFields()

	Local nCPQTDITE  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "QTDITE"  } )
	Local nCPQTDEST  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "QTDEST"  } )
	Local nCPQTDTRA  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "QTDTRA"  } )
	Local nCPQTDAGU  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "QTDAGU"  } )
	Local nCPQTPEND  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "QTDPEND" } )
	Local nCPQTRARET := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "QTRARET" } )

	Local aRetorno := {}
	Local nValor   := 0

	For ni := 1 to Len(aItens)

		AADD( aRetorno , { Len(aRetorno) + 1 , Array(Len(aFields)) } )

		nPos := Len(aRetorno)

		For nJ := 1 to Len(aItens[nI])
			If ( nPosCP := aScan( aFields, { |x| AllTrim( x[MVC_MODEL_IDFIELD] ) == AllTrim( aItens[nI][nJ][1] ) } ) ) > 0
				aRetorno[ nPos , 2 ][ nPosCP ] := aItens[nI][nJ][2]
				If nCPQTDTRA == nPosCP // Replica a informação do campo QTDTRA para o campo QTRARET no carregamento dos campos
					aRetorno[ nPos , 2 ][ nCPQTRARET ] := aItens[nI][nJ][2]
				EndIf
			EndIf
		Next

		nValor := aRetorno[ nPos , 2 ][ nCPQTDITE ]
		nValor -= aRetorno[ nPos , 2 ][ nCPQTDEST ]
		nValor -= aRetorno[ nPos , 2 ][ nCPQTDTRA ]
		nValor -= aRetorno[ nPos , 2 ][ nCPQTDAGU ]

		aRetorno[ nPos , 2 ][ nCPQTPEND ] := nValor

	Next

Return aRetorno

/*/{Protheus.doc} OA6110055_QtdPendente

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OA6110055_QtdPendente( oModItem )

	nValor := oModItem:GetValue("QTDITE")
	nValor -= oModItem:GetValue("QTDEST")
	nValor -= oModItem:GetValue("QTRARET") // Considero o que foi digitado na distribuição da quantidade transferida
	nValor -= oModItem:GetValue("QTDAGU")

Return nValor

/*/{Protheus.doc} OA6110065_LevantaItens

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Function OA6110065_LevantaItens(cTipReg,cFILREG,cCODREG)

	Local aPecSemEst := {}
	Local aPecAux    := {}
	Local cTab       := ""
	Local oRpm       := OFJDRpmConfig():New()
	Local nSldEst    := 0
	Local nQtdIte    := 0

	If cTipReg == "3"
		cQuery := "SELECT VSJ.VSJ_GRUITE AS GRUITE, "
		cQuery += 		" VSJ.VSJ_CODITE AS CODITE, "
		cQuery += 		" ' '            AS SEQUEN, "
		cQuery += 		" VSJ.VSJ_CODIGO AS CODVSJ, "
		cQuery += 		" VSJ.VSJ_QTDITE AS QTDITE, "
		cQuery += 		" VSJ.VSJ_QTDRES AS QTDRES, "
		cQuery += 		" VSJ.VSJ_QTDTRA AS QTDTRA, "
		cQuery += 		" VSJ.VSJ_QTDAGU AS QTDAGU, "
		cQuery += 		" VSJ.VSJ_LOCAL  AS LOCARM, "
		cQuery += 		" VSJ.VSJ_RESPEC AS RESERV, "
		cQuery += 		" VSJ.R_E_C_N_O_ AS RECREG "
		cQuery += " FROM " + RetSqlName("VSJ") + " VSJ "
		cQuery += " WHERE VSJ.VSJ_FILIAL = ? "
		cQuery += 	" AND VSJ.VSJ_NUMOSV = ? "
		cQuery += 	" AND VSJ.VSJ_MOTPED = ? "
		cQuery += 	" AND VSJ.D_E_L_E_T_ = ? "
		cQuery += 	" AND ( VSJ.VSJ_QTDITE - VSJ.VSJ_QTDTRA - VSJ.VSJ_QTDAGU - VSJ.VSJ_QTDRES ) > 0 "
	Else
		cQuery := "SELECT VS3.VS3_GRUITE AS GRUITE, "
		cQuery += 		" VS3.VS3_CODITE AS CODITE, "
		cQuery += 		" VS3.VS3_SEQUEN AS SEQUEN, "
		cQuery += 		" ' '            AS CODVSJ, "
		cQuery += 		" VS3.VS3_QTDITE AS QTDITE, "
		cQuery += 		" VS3.VS3_QTDRES AS QTDRES, "
		cQuery += 		" VS3.VS3_QTDTRA AS QTDTRA, "
		cQuery += 		" VS3.VS3_QTDAGU AS QTDAGU, "
		cQuery += 		" VS3.VS3_LOCAL  AS LOCARM, "
		cQuery += 		" VS3.VS3_RESERV AS RESERV, "
		cQuery += 		" VS3.R_E_C_N_O_ AS RECREG "
		cQuery += " FROM " + RetSqlName("VS3") + " VS3 "
		cQuery += " WHERE VS3.VS3_FILIAL = ? "
		cQuery += 	" AND VS3.VS3_NUMORC = ? "
		cQuery += 	" AND VS3.VS3_MOTPED = ? "
		cQuery += 	" AND VS3.D_E_L_E_T_ = ? "
		cQuery += 	" AND ( VS3.VS3_QTDITE - VS3.VS3_QTDTRA - VS3.VS3_QTDAGU - VS3.VS3_QTDRES ) > 0 "
	EndIf

	oExecQuery := FwExecStatement():New(cQuery)

	oExecQuery:SetString(1, cFILREG )
	oExecQuery:SetString(2, cCODREG )
	oExecQuery:SetString(3, ' ' )
	oExecQuery:SetString(4, ' ' )

	cTab := oExecQuery:OpenAlias()

	While !(cTab)->(Eof())

		SB1->(DbSetOrder(7))
		SB1->(DbSeek( xFilial("SB1") + (cTab)->GRUITE + (cTab)->CODITE ))

		nSldEst := 0

		If (cTab)->RESERV == "1"
			nSldEst += (cTab)->QTDRES
		Else
			If oRpm:lNovaConfiguracao
				If !Empty( (cTab)->LOCARM )
					nSldEst += oRpm:SaldoTotalDaPeca( SB1->B1_COD, cFilAnt, (cTab)->LOCARM )
				EndIf
			Else
				nSldEst += FS_SALDOESTQ( SB1->B1_COD, (cTab)->LOCARM )
			EndIf
		EndIf

		nQtdIte := (cTab)->QTDITE
		nQtdIte -= (cTab)->QTDTRA
		nQtdIte -= (cTab)->QTDAGU

		If nSldEst >= nQtdIte
			(cTab)->(DbSkip())
			Loop
		EndIf

		aadd(aPecAux,{ "GRUITE",(cTab)->GRUITE })
		aadd(aPecAux,{ "CODITE",(cTab)->CODITE })
		aadd(aPecAux,{ "SEQUEN",(cTab)->SEQUEN })
		aadd(aPecAux,{ "QTDITE", nQtdIte })
		aadd(aPecAux,{ "QTDEST", nSldEst })
		aadd(aPecAux,{ "QTDTRA", 0 })
		aadd(aPecAux,{ "QTDAGU", 0 })
		aadd(aPecAux,{ "RECREG",(cTab)->RECREG })
		aadd(aPecAux,{ "CODVSJ",(cTab)->CODVSJ })
		aadd(aPecAux,{ "LOCARM",(cTab)->LOCARM })

		aAdd(aPecSemEst,aClone(aPecAux))

		(cTab)->(DbSkip())

	EndDo

	(cTab)->(DbCloseArea())

Return aPecSemEst


/*/{Protheus.doc} OA6110075_GeraSolicitacao

@author Renato Vinicius
@since 03/02/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA6110075_GeraSolicitacao(oModEVDEF, lRes)

	Local oModel	:= FWModelActive()

	Local nx        := 0
	Local ny        := 0
	Local nPosVDD   := 0
	Local cOrigem   := "OR" // Orçamento
	Local cTipo     := "01"
	Local cTipo2    := ""
	Local cRecNo    := VS1->(RecNo())
	Local cDocto    := ""
	Local aVDD      := {}
	Local lRetorno  := .t.

	Local aAuxVDD   := {}
	Local lVDDQTDORI:= VDD->(FieldPos('VDD_QTDORI')) > 0 // Qtd.Original
	Local lTemEmail := ( FindFunction("VA0100071_ExisteEmail") .and. FindFunction("OXA0200051_EnviarEmail") )

	Local aPedTransf:= {}
	Local nLinIte   := 0

	Local cTabIte := "VS3"
	Local cTabCab := "VS1"
	Local cDbSeek := "VS3->VS3_NUMORC"
	Local cFilVO1 := ""
	Local cCodVO1 := ""
	Local cFilVS1 := ""
	Local cCodVS1 := ""

	Local aPecRes := {}
	Local aReserv := oModEVDEF:GetItensReserva()
	Local aSugest := oModEVDEF:GetItensSugestaoCompra()
	Local aTransf := oModEVDEF:GetItensTransferencia()
	Local aAtuali := oModEVDEF:GetAtualizaItens()

	Local lCpoSOLCPR := .f.
	Local lCpoSOLTRF := .f.

	oModPar := oModel:GetModel('MODPARAM')
	oModIte := oModel:GetModel('MODDET'  )

	cTpOpe  := oModPar:GetValue("PARTIPOOP")

	If cTpOpe == "3"

		cFilVO1 := oModPar:GetValue("PARFILIAL")
		cCodVO1 := oModPar:GetValue("PARCODVO1")

	Else

		cFilVS1 := oModPar:GetValue("PARFILIAL")
		cCodVS1 := oModPar:GetValue("PARCODVS1")

	EndIf

	If Len(aTransf) == 0 .and. Len(aSugest) == 0 // Não tem transferência e Sugestão de Compra
		FMX_HELP("OA611ERR004", STR0011 ) //"Não há solicitações para serem geradas."
		Return .f.
	EndIf

	// Reserva as peças antes de gerar as solicitações
	If Len(aReserv) > 0

		Do Case
			Case cTpOpe == "2" // Pedido de Orçamento
				cOrigem := "PD"
				cTipo   := "06"
			Case cTpOpe == "3" // Oficina
				cOrigem := "OF"
				cTipo   := "13"
				cRecNo  := VO1->(RecNo())
				aPecRes := aClone(aReserv)
		End Case

		cDocto := OA4820015_ProcessaReservaItem(cOrigem,cRecNo,"A","R",aPecRes,cTipo,,.t.,cTipo2)

		If Empty(cDocto)
			lRetorno := .f.
			DisarmTransaction()
			break
		EndIf

		lRes := .t.

	EndIf

	// Gera transferência entre Filiais
	aVDD := {}

	for nX := 1 to Len(aTransf)

		nLinIte    := aTransf[nX,1]
		aPedTransf := aTransf[nX,2]
			
		DBSelectArea("VDD")
		DBSetOrder(4)

		for nY := 1 to Len(aPedTransf)

			DBSelectArea("VDD")
			DBSetOrder(4)

			If cTpOpe == "3"
				aRetVDD := OXA0200045_LevantaPedidoTransferencia(cFilVO1, , aPedTransf[nY,1], aPedTransf[nY,2], aPedTransf[nY,5], "S" , cCodVO1, oModIte:GetValue("CODVSJ", nLinIte ) )
			Else
				aRetVDD := OXA0200045_LevantaPedidoTransferencia(cFilVS1, cCodVS1, aPedTransf[nY,1], aPedTransf[nY,2], aPedTransf[nY,5], "S" )
			EndIf

			if Len(aRetVDD) == 0

				aCriaVdd := {}

				If cTpOpe == "3"

					aAdd(aAuxVDD,{"VDD_FILOSV", cFilVO1 })
					aAdd(aAuxVDD,{"VDD_NUMOSV", cCodVO1 })
					aAdd(aAuxVDD,{"VDD_CODVSJ", oModIte:GetValue("CODVSJ", nLinIte )})

				Else

					aAdd(aAuxVDD,{"VDD_FILORC", cFilVS1 })
					aAdd(aAuxVDD,{"VDD_NUMORC", cCodVS1 })

				EndIf

				aAdd(aAuxVDD,{"VDD_GRUPO" , aPedTransf[nY,1]})
				aAdd(aAuxVDD,{"VDD_CODITE", aPedTransf[nY,2]})
				aAdd(aAuxVDD,{"VDD_QUANT" , aPedTransf[nY,4]})
				aAdd(aAuxVDD,{"VDD_FILPED", aPedTransf[nY,5]})
				aAdd(aAuxVDD,{"VDD_STATUS", "S"})
				aAdd(aAuxVDD,{"VDD_TIPTRA", "0"})
				aAdd(aAuxVDD,{"VDD_VENTRA", VS1->VS1_CODVEN})

				If lVDDQTDORI // Qtd.Original
					aAdd(aAuxVDD, {"VDD_QTDORI", aPedTransf[nY,4]}) // Qtd.Original
				EndIf

				aAdd(aCriaVdd,aClone(aAuxVDD))

				oModelVDD 	:= FWLoadModel( 'OFIXA020' )
				lRetMVCAuto := FWMVCRotAuto(oModelVDD,"VDD",3,{{"VDDMASTER",aCriaVdd[1]}})
				if ! lRetMVCAuto
					FMX_HELP("OA611ERR003", STR0012 ) //"Não foi possível criar a solicitação de pedido de transferência"
					DisarmTransaction()
					Break
				endif

				If lTemEmail
					nPosVDD := aScan(aVDD, {|x| x[1] == aPedTransf[nY,5] }) // Pesquisa a Filial
					If nPosVDD == 0 // Enviar um e-mail por Filial
						aAdd(aVDD,{aPedTransf[nY,5],{}})
						nPosVDD := len(aVDD)
					EndIf
					aAdd(aVDD[nPosVDD,2],{ aPedTransf[nY,1] , aPedTransf[nY,2] , "" , aPedTransf[nY,4] })
				EndIf
			endif
		Next
	Next

	//Gera Solicitação de Sugestão de Compra
	If Len(aSugest) > 0

		lRetorno := OFIA485(aSugest)
		If !lRetorno
			DisarmTransaction()
			break
		EndIf

	EndIf

	If cTpOpe == "3"

		cTabIte := "VSJ"
		cTabCab := "VSJ"
		cDbSeek := "VSJ_NUMOSV"

	EndIf

	lCpoSOLCPR := &(cTabCab+"->(ColumnPos('"+cTabCab+"_SOLCPR')) > 0")
	lCpoSOLTRF := &(cTabCab+"->(ColumnPos('"+cTabCab+"_SOLTRF')) > 0")

	oModIte := oModel:GetModel('MODDET')

	// Atualização dos registros de Orçamento e OS
	For nx := 1 to Len(aAtuali)

		DbSelectArea(cTabIte)
		DbGoTo(aAtuali[nx,2])

		If lCpoSOLCPR .or. lCpoSOLTRF
			DbSelectArea(cTabCab)
			DbSeek(xFilial(cTabCab)+&(cDbSeek))
		EndIf

		If aAtuali[nx,3] // Atualiza o campo de Sugestão

			DbSelectArea(cTabIte)
			RecLock(cTabIte,.f.)
				&(cTabIte+"->"+cTabIte+"_QTDAGU") += oModIte:GetValue("QTDAGU", aAtuali[nx,1] )
			MsUnLock()

			If lCpoSOLCPR
				DbSelectArea(cTabCab)
				RecLock(cTabCab,.f.)
					&(cTabCab+"->"+cTabCab+"_SOLCPR") := "1"
				MsUnLock()
			EndIf

		EndIf

		If aAtuali[nx,4] // Atualiza o campo de Transferencia

			DbSelectArea(cTabIte)
			If ColumnPos(cTabIte+"_QTDTRA") > 0

				RecLock(cTabIte,.f.)
					&(cTabIte+"->"+cTabIte+"_QTDTRA") += oModIte:GetValue("QTDTRA", aAtuali[nx,1] )
				MsUnLock()

				If lCpoSOLTRF
					DbSelectArea(cTabCab)
					RecLock(cTabCab,.f.)
						&(cTabCab+"->"+cTabCab+"_SOLTRF") := "1"
					MsUnLock()
				EndIf

			EndIf

		EndIf

	Next

	If len(aVDD) > 0
		For nPosVDD := 1 to len(aVDD)
			If VA0100071_ExisteEmail( aVDD[nPosVDD,1] , "002001" )
				// Envio de Email - Evento: 002001 = Inclusão do Pedido de Transferencia
				OXA0200051_EnviarEmail( aVDD[nPosVDD,1] , "002001" , STR0013 + " - " + STR0014 , "3" , aClone(aVDD[nPosVDD,2]) , VS1->VS1_CODVEN , cFilVS1 , cCodVS1, cFilVO1) // Transferência de Peças - Pedido Incluido
			EndIf
		Next
	EndIf

Return lRetorno

/*/{Protheus.doc} OA6110085_AtualizaTransf

@author Renato Vinicius
@since 18/05/2026
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OA6110085_AtualizaTransf( oModel, cModID, cField, xValue )

	Local nQDTra := oModel:GetModel(cModID):GetValue("QTRARET") // Quantidade retornada da digitação da tela de solicitações de transferencia
	Local nLnGrd := oModel:GetModel(cModID):GetLine()

	oModel:GetModel(cModID):LoadValue("QTDTRA", nQDTra, nLnGrd)

Return