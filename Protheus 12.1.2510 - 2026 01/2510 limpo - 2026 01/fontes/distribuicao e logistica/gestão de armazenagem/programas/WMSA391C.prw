#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA391C.CH"

#DEFINE WMSA391C01 "WMSA391C01"
#DEFINE WMSA391C02 "WMSA391C02"

//----------------------------------------------------
/*/{Protheus.doc} WMSA391C
Programa que contém a regra de estorno do produto do volume
@author felipe.m
@since 07/05/2015
@version 1.0
/*/
//----------------------------------------------------
Function WMSA391C()
Return Nil
//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0001 ACTION "WMS391EPrd()" OPERATION 4 ACCESS 0 // Estornar Produto Volume
Return aRotina
//-------------------------------------------------------------------//
//-------------------------Funcao ModelDef---------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()
Local oModel := MPFormModel():New('WMSA391C',{|oModel| BeforeCMdl(oModel) },{|oModel| ValidMdl(oModel) },{|oModel| CommitMdl(oModel) })
Local oStr1 := FWFormStruct(1,'DCV')
	oStr1:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	
	oModel:AddFields('A391DCV',,oStr1)
	
	oModel:SetVldActivate({|oModel| VldActive(oModel) })
	oModel:SetActivate({|oModel| SetActive(oModel) })
Return oModel
//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()
Local oModel := ModelDef()
Local oView  := FWFormView():New()
Local oStr1  := FWFormStruct(2,'DCV')
	oStr1:SetProperty('*',MVC_VIEW_CANCHANGE,.F.)
	
	oView:SetModel(oModel)
	oView:AddField( 'VIEW_DCV', oStr1, 'A391DCV')
	
	oView:CreateHorizontalBox( 'BOXDCV', 100)
	
	oView:EnableTitleView('VIEW_DCV', STR0002) // Itens Volume
	
	oView:SetOwnerView('VIEW_DCV','BOXDCV')
Return oView
//---------------------------------------------------------------------//
//---Impede o estorno de carga/pedido diferente da montagem corrente---//
//---------------------------------------------------------------------//
Static Function VldActive(oModel)
Local lRet := .T.
	
	If DCV->DCV_CODMNT != DCS->DCS_CODMNT
		oModel:SetErrorMessage("A391DCV"/*[cIdForm]*/,/*[cIdField]*/,"A391DCV"/*[cIdFormErr]*/,/*[cIdFieldErr]*/,/*[cId]*/,STR0003/*[cMessage]*/,/*[cSoluction]*/,/*[xValue]*/,/*[xOldValue]*/) // Só é possível estornar itens da montagem corrente."
		lRet := .F.
	EndIf
Return lRet
//------------------------------------------------------------------//
//----Realiza alguma alteração no modelo para chamar o ValidMdl-----//
//------------------------------------------------------------------//
Static Function SetActive(oModel)
	oModel:GetModel("A391DCV"):SetValue("DCV_STATUS", oModel:GetModel("A391DCV"):GetValue("DCV_STATUS"))
Return .T.
//-----------------------------------------------------------//
//--------------Validação do modelo de dados-----------------//
//-----------------------------------------------------------//
Static Function ValidMdl(oModel)
Local lRet := .T.
Local cQuery := ""
Local oModelDCV := oModel:GetModel("A391DCV")
Local cAliasQry := ""
Local oMntVol := Nil

	// Validação do Estorno por Documento
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oMntVol := WMSDTCMontagemVolume():New()
		oMntVol:SetCodMnt(DCV->DCV_CODMNT)
		oMntVol:SetCarga(DCV->DCV_CARGA)
		oMntVol:SetPedido(DCV->DCV_PEDIDO)
		oMntVol:LoadData()
		// Valida apenas quanto não 'Libera o estorno do volume' (DCS_LIBEST) 
		If oMntVol:GetLibEst() == "2"
			cQuery := " SELECT 1 "
			cQuery +=   " FROM "+RetSqlName("SC9")+" SC9"
			cQuery +=  " WHERE SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
			cQuery +=    " AND SC9.C9_PEDIDO = '"+DCV->DCV_PEDIDO+"'"
			cQuery +=    " AND SC9.C9_ITEM = '"+DCV->DCV_ITEM+"'"
			cQuery +=    " AND SC9.C9_SEQUEN = '"+DCV->DCV_SEQUEN+"'"
			cQuery +=    " AND SC9.C9_PRODUTO = '"+DCV->DCV_PRDORI+"'"
			cQuery +=    " AND SC9.C9_NFISCAL <> ' '" 
			cQuery +=    " AND SC9.D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				oModel:SetErrorMessage("A391DCT", ,"A391DCT",,,STR0004,) // Produto não pode ser estornado, pois está faturado!
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
		EndIf
		If lRet
			cQuery := " SELECT 1 "
			cQuery +=   " FROM "+RetSqlName("D00")
			cQuery +=  " WHERE D00_FILIAL = '"+xFilial("D00")+"'"
			cQuery +=    " AND D00_CARGA = '"+DCV->DCV_CARGA+"'"
			cQuery +=    " AND D00_PEDIDO = '"+DCV->DCV_PEDIDO+"'"
			cQuery +=    " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If (cAliasQry)->(!Eof())
				oModel:SetErrorMessage("A391DCT", ,"A391DCT",,,STR0005,STR0006) // Documento não pode ser estornado, pois possui endereçamento! // Estorne primeiramente o endereçamento.
				lRet := .F.
			EndIf
			(cAliasQry)->(dbCloseArea())
			If oModelDCV:GetValue("DCV_STATUS") == "2"
				If DCS->DCS_LIBPED <> "6"
					oModel:SetErrorMessage("A391DCV", ,"A391DCV",,,STR0007,STR0008+DCS->DCS_LIBPED+"'.") // Documento não pode ser estornado, pois já foi endereçado! // Liberação está definida como DC5_LIBPED = 
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
Return lRet
//------------------------------------------//
//------Força a modificação do modelo-------//
//------------------------------------------//
Static Function BeforeCMdl(oModel)
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:LMODIFY := .T.
	EndIf
Return .T.
//-------------------------------------//
//-------Estorno do produto------------//
//-------------------------------------//
Function WMS391EPrd()
Local aAreaAnt := GetArea()
Local lRet := .T.

	//Verifica se o volume está conferido
	If !WMSA391VIC(DCV->DCV_CODMNT,/*DCV_CARGA*/,/*DCV_PEDIDO*/,DCV->DCV_CODVOL)
		WmsMessage(STR0010,WMSA391C02) // "Carga/Pedido possui conferencia de expedicao, estorne a conferencia primeiramente!"
		lRet := .F.
	Else
		lRet := FWExecView(STR0001,'WMSA391C',4,,{ || .T. },,,,{ || .T. }) == 0 // Estornar Produto Volume
	EndIf
	
	WMSA391REF()
RestArea(aAreaAnt)
Return lRet
//------------------------------------------//
//------------Comit do modelo---------------//
//------------------------------------------//
Static Function CommitMdl(oModel)
Local lRet := .T.
Local oModelDCV := oModel:GetModel("")

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		lRet := FwFormCommit(oModel,,,,{|oModel| bInTTSAtuMVC(oModel)})
	EndIf
Return lRet
//------------------------------------------//
//---------Gração dentro da transação-------//
//------------------------------------------//
Static Function bInTTSAtuMVC(oModel)
Local oModelDCV := oModel:GetModel("A391DCV")
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		WmA391GrvE(3,;                                // nAcao
		           DCS->DCS_CARGA,;                   // cCarga
		           DCS->DCS_PEDIDO,;                  // cPedido
		           oModelDCV:GetValue("DCV_CODVOL"),; // cCodVol
		           oModelDCV:GetValue("DCV_PRDORI"),; // cPrdOri
		           oModelDCV:GetValue("DCV_CODPRO"),; // cProduto
		           oModelDCV:GetValue("DCV_LOTE"),;   // cLote
		           oModelDCV:GetValue("DCV_SUBLOT"),; // cSubLote
		           DCS->DCS_CODMNT,;                  // cCodMnt
		           Nil,;                              // nQtdEst
		           DCV->(Recno()),;                   // nRecDCV
		           DCS->DCS_LIBPED)                   // cLibPed
	EndIf
Return .T. 
