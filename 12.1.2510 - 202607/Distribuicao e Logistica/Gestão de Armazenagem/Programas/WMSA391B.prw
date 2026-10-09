#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA391B.CH"

#DEFINE WMSA391B01 "WMSA391B01"
#DEFINE WMSA391B02 "WMSA391B02"
#DEFINE WMSA391B03 "WMSA391B03"
#DEFINE WMSA391B04 "WMSA391B04"

Static _lWA091VMT := ExistBlock("WA091VMT")

//-----------------------------------------------------
/*/{Protheus.doc} WMSA391B
Programa que contém as regras por volume da montagem de volume
@author felipe.m
@since 07/05/2015
@version 1.0
/*/
//-----------------------------------------------------
Function WMSA391B()
Return Nil
//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
Local lExistBloc := ExistBlock("WMS391BM")

	ADD OPTION aRotina TITLE STR0001 ACTION "WMS391MVol()"  OPERATION 3 ACCESS 0 // Montar Volume
	ADD OPTION aRotina TITLE STR0002 ACTION "WMS391IVol()"  OPERATION 9 ACCESS 0 // Imprimir Etiqueta
	ADD OPTION aRotina TITLE STR0011 ACTION "WMS391IAll()"  OPERATION 9 ACCESS 0 // Imprimir Todos
	ADD OPTION aRotina TITLE STR0003 ACTION "WMS391EVol()"  OPERATION 4 ACCESS 0 // Estornar Volume

If lExistBloc
	aRotina := ExecBlock("WMS391BM",.F.,.F.,{aRotina})
End If

Return aRotina
//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//------------------Utilizado no Estorno do Volume-------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel := MPFormModel():New('WMSA391B',{|oModel| BeforeCMdl(oModel) },{|oModel| ValidMdl(oModel)},{|oModel| CommitMdl(oModel)})
Local oStr1 := FWFormStruct(1,'DCU')
Local oStr2 := FWFormStruct(1,'DCV')
Local bStatus  := {||Iif(DCV->DCV_STATUS=="1",'BR_AMARELO',Iif(DCV->DCV_STATUS=="3",'BR_VERMELHO','BR_AZUL'))}

	oStr1:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStr2:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

	// <cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])
	oStr2:AddField("", "", 'DCV_VSTATUS', 'C', 11, 0,,,,,bStatus,,,.T.) // Status // Situação da montagem de volumes

	oModel:AddFields('A391DCU',,oStr1)
	oModel:AddGrid('A391DCV','A391DCU',oStr2)
	oModel:SetRelation('A391DCV', { { 'DCV_FILIAL', 'xFilial("DCV")' }, { 'DCV_CODMNT', 'DCU_CODMNT' }, { 'DCV_CARGA', 'DCU_CARGA' }, { 'DCV_PEDIDO', 'DCU_PEDIDO' }, { 'DCV_CODVOL', 'DCU_CODVOL' } }, DCV->(IndexKey(3)) )
	oModel:GetModel('A391DCU'):SetOnlyView(.T.)
	oModel:SetActivate({|oModel| SetActive(oModel) })
Return oModel
//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oModel := ModelDef()
Local oView  := FWFormView():New()
Local oStr1  := FWFormStruct(2,'DCU')
Local oStr2  := FWFormStruct(2,'DCV')

	oStr1:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	oStr2:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)

	oStr2:AddField('DCV_VSTATUS', '01',"","", , 'GET', '@BMP', Nil, /*cLookUp*/,.F., /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/, /*cIniBrow*/, .T.) //Situação da montagem de volumes
	oStr2:RemoveField('DCV_STATUS')

	oView:SetModel(oModel)
	oView:AddField( 'VIEW_DCU', oStr1, 'A391DCU')
	oView:AddGrid( 'VIEW_DCV', oStr2, 'A391DCV')

	oView:CreateHorizontalBox( 'BOXDCU', 30)
	oView:CreateHorizontalBox( 'BOXDCV', 70)

	oView:EnableTitleView('VIEW_DCU', STR0005) // Volume
	oView:EnableTitleView('VIEW_DCV', STR0006) // Itens Volume

	oView:SetOwnerView('VIEW_DCU','BOXDCU')
	oView:SetOwnerView('VIEW_DCV','BOXDCV')
Return oView
//-------------------------------------------------------------------//
//--------------------Validação do modelo de dados-------------------//
//-------------------------------------------------------------------//
Static Function ValidMdl(oModel)
Local lRet := .T.
Local cQuery := ""
Local oModelDCV := oModel:GetModel("A391DCV")
Local cAliasQry := ""
Local oMntVol := Nil

	// Validação do Estorno por Documento
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oMntVol := WMSDTCMontagemVolume():New()
		oMntVol:SetCodMnt(DCU->DCU_CODMNT)
		oMntVol:SetCarga(DCU->DCU_CARGA)
		oMntVol:SetPedido(DCU->DCU_PEDIDO)
		oMntVol:LoadData()
		// Valida apenas quanto não 'Libera o estorno do volume' (DCS_LIBEST) 
		If oMntVol:GetLibEst() == "2"
			cQuery := " SELECT 1"
			cQuery +=   " FROM "+RetSqlName("DCV")+" DCV"
			cQuery +=  " INNER JOIN "+RetSqlName("SC9")+" SC9"
			cQuery +=     " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
			cQuery +=    " AND DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
			If WmsCarga(DCU->DCU_CARGA)
				cQuery +=    " AND SC9.C9_CARGA = DCV.DCV_CARGA"
			EndIf
			cQuery +=    " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
			cQuery +=    " AND SC9.C9_ITEM = DCV.DCV_ITEM"
			cQuery +=    " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
			cQuery +=    " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
			cQuery +=    " AND SC9.C9_NFISCAL <> ' '"
			cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
			cQuery +=  " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
			cQuery +=    " AND DCV.DCV_CODMNT = '"+DCU->DCU_CODMNT+"'"
			cQuery +=    " AND DCV.DCV_CARGA = '"+DCU->DCU_CARGA+"'"
			cQuery +=    " AND DCV.DCV_PEDIDO = '"+DCU->DCU_PEDIDO+"'"			
			cQuery +=    " AND DCV.DCV_CODVOL = '"+DCU->DCU_CODVOL+"'"
			cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				oModel:SetErrorMessage("A391DCT", ,"A391DCT",,,STR0007,) // Volume não pode ser estornado, pois possui item faturado!
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
		If lRet
			cQuery := " SELECT 1"
			cQuery +=   " FROM "+RetSqlName("D00")
			cQuery +=  " WHERE D00_FILIAL = '"+xFilial("D00")+"'"
			cQuery +=    " AND D00_CARGA = '"+DCU->DCU_CARGA+"'"
			cQuery +=    " AND D00_PEDIDO = '"+DCU->DCU_PEDIDO+"'"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				oModel:SetErrorMessage("A391DCT", ,"A391DCT",,,STR0012,STR0013) // Documento não pode ser estornado, pois possui endereçamento! // Estorne primeiramente o endereçamento.
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			If oModelDCV:GetValue("DCV_STATUS",1) == "2"
				If DCS->DCS_LIBPED <> "6"
					oModel:SetErrorMessage("A391DCV", ,"A391DCV",,,STR0014,STR0015+"'"+DCS->DCS_LIBPED+"'.") // Documento não pode ser estornado, pois já foi endereçado! // Liberação está definida como DC5_LIBPED =
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
//-------------------------------------------------------------------//
//-------------Função chamada após a ativação do modelo--------------//
//-------------------------------------------------------------------//
Static Function SetActive(oModel)
Local lRet := .T.
Local nI := 0

	// Realiza alguma alteração no modelo para chamar o ValidMdl
	oModel:GetModel("A391DCV"):SetValue("DCV_STATUS", oModel:GetModel("A391DCV"):GetValue("DCV_STATUS"))
Return lRet
//-------------------------------------------------------------//
//-----------Montagem de Volume Sem Coletor RF-----------------//
//-------------------------------------------------------------//
Function WMS391MVol()
Local aAreaAnt := GetArea()
Local lRet     := .T.
Local xRetPE   := Nil

	If DCS->DCS_STATUS == "3"
		WmsMessage(STR0009,WMSA391B01) // Pedido com todos os itens embalados.
		lRet := .F.
	EndIf

	If lRet .And. Empty(SuperGetMv("MV_WMSNVOL",.F.,""))
		WmsMessage(STR0010,WMSA391B02) // Parametro MV_CODVOL inexistente! Avise o Administrador do sistema!
		lRet := .F.
	EndIf

	// Permite executar validações antes da montagem de um volume
	If lRet .And. _lWA091VMT
		xRetPE := ExecBlock("WA091VMT",.F.,.F.,{DCS->DCS_CODMNT,DCS->DCS_CARGA,DCS->DCS_PEDIDO})
		If ValType(xRetPE) == "L"
			lRet := xRetPE
		EndIf
	EndIf

	If lRet
		lRet := FWExecView(STR0001,'WMSA391A',3,,{ || .T. },,30,,{ || .T. }) == 0 // Montar Volume
	EndIf

	RestArea(aAreaAnt)
	WMSA391REF()
Return lRet
//--------------------------------------------------------//
//-----------------Estorno do volume----------------------//
//--------------------------------------------------------//
Function WMS391EVol()
Local aAreaAnt := GetArea()
Local lRet := .T.

	//Verifica se o volume está conferido
	If DCU->DCU_STCONF == '2'
		WmsMessage(STR0017,WMSA391B03) // "Carga/Pedido possui conferencia de expedicao, estorne a conferencia primeiramente!"
		lRet := .F.
	Else
		// [cTitulo],<cPrograma>,[nOperation],[oDlg],[bCloseOnOK],[bOk],[nPercReducao],[aEnableButtons],[bCancel],[cOperatId],[cToolBar],[oModelAct]
		lRet := FWExecView(STR0003,'WMSA391B',4,,{ || .T. },,,,{ || .T. }) == 0 // Estornar Volume
	EndIf
	
	RestArea(aAreaAnt)
	WMSA391REF()
Return lRet

Function WMS391IAll()
Local aAreaAnt := GetArea()
Local aItens := {}
Local cLocImp := Space(TamSX3("CB5_CODIGO")[1])
	cQuery := "SELECT DCV.DCV_CODPRO,"
	cQuery +=       " DCV.DCV_LOTE,"
	cQuery +=       " DCV.DCV_SUBLOT,"
	cQuery +=       " DCV.DCV_QUANT,"
	cQuery +=       " DCV.DCV_CARGA,"
	cQuery +=       " DCV.DCV_PEDIDO,"
	cQuery +=       " DCV.DCV_CODVOL,"
	cQuery +=       " SC9.C9_CLIENTE,"
	cQuery +=       " SC9.C9_LOJA"
	cQuery +=  " FROM "+RetSqlName("DCV")+" DCV"
	cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9"
	cQuery +=    " ON SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
	cQuery +=   " AND SC9.C9_PEDIDO = DCV.DCV_PEDIDO"
	cQuery +=   " AND SC9.C9_ITEM = DCV.DCV_ITEM"
	cQuery +=   " AND SC9.C9_SEQUEN = DCV.DCV_SEQUEN"
	cQuery +=   " AND SC9.C9_PRODUTO = DCV.DCV_PRDORI"
	cQuery +=   " AND SC9.D_E_L_E_T_ = ' '"
	cQuery += " WHERE DCV.DCV_FILIAL = '"+xFilial("DCV")+"'"
	cQuery +=   " AND DCV.DCV_CODMNT = '"+DCS->DCS_CODMNT+"'"
	cQuery +=   " AND DCV.D_E_L_E_T_ = ' '"
	cQuery +=   " AND EXISTS ( SELECT 1"
	cQuery +=                  " FROM "+RetSqlName("DCU")+" DCU"
	cQuery +=                 " WHERE DCU.DCU_FILIAL = '"+xFilial("DCU")+"'"
	cQuery +=                   " AND DCU.DCU_CODVOL = DCV.DCV_CODVOL"
	cQuery +=                   " AND DCU.D_E_L_E_T_ = ' ' )"
	cQuery += " ORDER BY DCV.DCV_CODVOL"
	cQuery := ChangeQuery(cQuery)
	cAliasDCV := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasDCV,.F.,.T.)
	Do While (cAliasDCV)->(!Eof())
		(cAliasDCV)->(aAdd(aItens,{DCV_CODPRO,DCV_QUANT,DCV_CODVOL,DCV_LOTE,DCV_SUBLOT,DCV_CARGA,DCV_PEDIDO,C9_CLIENTE,C9_LOJA}))
		(cAliasDCV)->(dbSkip())
	EndDo
	(cAliasDCV)->(dbCloseArea())

	If !Empty(aItens)
		WMSR410ETI(aItens,,cLocImp)
	EndIf
	RestArea(aAreaAnt)
Return

Function WMS391IVol()
	WMSR410A(DCU->DCU_CODVOL,.F.)
Return
//------------------------------------------------------------//
//-------------Força a modificação do modelo------------------//
//------------------------------------------------------------//
Static Function BeforeCMdl(oModel)
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:LMODIFY := .T.
	EndIf
Return .T.
//----------------------------------------------------------//
//--------------Comite do modelo de dados-------------------//
//----------------------------------------------------------//
Static Function CommitMdl(oModel)
Local lRet := .T.
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		lRet := FwFormCommit(oModel,,,,{|oModel| bInTTSAtuMVC(oModel)})
	EndIf
Return lRet
//-------------------------------------------------------//
//-------Realiza a gravação do estorno na translação-----//
//-------------------------------------------------------//
Static Function bInTTSAtuMVC(oModel)
Local oModelDCU := oModel:GetModel("A391DCU")
Local lRet := .T.

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		WmA391GrvE(1,;                                // nAcao
		           DCS->DCS_CARGA,;                   // cCarga
		           DCS->DCS_PEDIDO,;                  // cPedido
		           oModelDCU:GetValue("DCU_CODVOL"),; // cCodVol
		           ,;                                 // cPrdOri
		           ,;                                 // cProduto
		           ,;                                 // cLote
		           ,;                                 // cSubLote
		           DCS->DCS_CODMNT,;                  // cCodMnt
		           ,;                                 // nQtdEst
		           ,;                                 // nRecDCV
		           DCS->DCS_LIBPED)                   // cLibPed
	EndIf
Return lRet
