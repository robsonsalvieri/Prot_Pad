#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA412B.CH"
//-----------------------------------------------------
/*/{Protheus.doc} WMSA412B
Programa para estornar a conferência de um volume
@author amanda.vieira
@since 09/01/2017
@version 1.0
/*/
//-----------------------------------------------------
Function WMSA412B()
Return Nil
//----------------------------------------------------------
/*/{Protheus.doc} WMSA412B
ModelDef
@author  Amanda Rosa Vieira
@version P11
@Since   09/01/2017
@version 2.0
/*/
//----------------------------------------------------------
Static Function ModelDef()
Local oModel := MPFormModel():New('WMSA412B',{|oModel|BeforeCMdl(oModel)},/*{|oModel|ValidMdl(oModel)}*/,{|oModel|CommitModel(oModel)})
Local oStr1 := FWFormStruct(1,'DCU')
Local oStr2 := FWFormStruct(1,'DCV')
Local bStatus  := {||Iif(DCV->DCV_STATUS=="1",'BR_AMARELO',Iif(DCV->DCV_STATUS=="3",'BR_VERMELHO','BR_AZUL'))}

	oStr1:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStr2:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)

	oModel:AddFields('A412DCU',,oStr1)
	oModel:AddGrid('A412DCV','A412DCU',oStr2)
	oModel:SetRelation('A412DCV', { { 'DCV_FILIAL', 'xFilial("DCV")' }, { 'DCV_CODVOL', 'DCU_CODVOL' } }, DCV->(IndexKey(1)) )
	
	oModel:GetModel('A412DCV'):SetNoInsertLine( .T. )
	oModel:GetModel('A412DCV'):SetNoDeleteLine( .T. )
	oModel:GetModel('A412DCV'):SetNoUpdateLine( .T. )
	oModel:GetModel('A412DCV'):SetOptional( .T. )
	
	oModel:SetDescription(STR0001) //Monitor
	oModel:GetModel("A412DCV"):SetDescription(STR0002) //Expedição
	oModel:SetPrimaryKey({"DCV_FILIAL","DCV_CODMNT","DCV_CODVOL","DCV_PRDORI","DCV_CODPRO","DCV_LOTE","DCV_SUBLOT","DCV_ITEM","DCV_SEQUEN"})
Return oModel
//----------------------------------------------------------
/*/{Protheus.doc} WMSA412B
ViewDef
@author  Amanda Rosa Vieira
@version P11
@Since   09/01/2017
@version 2.0
/*/
//----------------------------------------------------------
Static Function ViewDef()
Local oModel := ModelDef()
Local oStr1  := FWFormStruct(2,'DCU')
Local oStr2  := FWFormStruct(2,'DCV')
Local oView  := Nil
	oStr2:RemoveField('DCV_STATUS')
	
	oView  := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:CreateHorizontalBox('MASTER',0,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/)
	oView:CreateHorizontalBox('DETAIL',100)
	
	oView:AddField( 'VIEW_DCU', oStr1, 'A412DCU')
	
	oView:CreateFolder('IDFOLDER','DETAIL')
	oView:AddSheet('IDFOLDER','IDSHEET01',STR0003) //Itens do Volume
	oView:CreateHorizontalBox('DETAIL_1', 100,,,'IDFOLDER', 'IDSHEET01')
	oView:AddGrid( 'VIEW_DCV', oStr2, 'A412DCV')
	oView:SetOnlyView('A412DCV')
	oView:SetOwnerView('A412DCV','DETAIL_1')
	
	oView:SetOwnerView('A412DCU','MASTER')
	oView:SetUseCursor(.F.)
Return oView
//----------------------------------------------------------
/*/{Protheus.doc} BeforeCMdl
Realiza alteração no modelo
@author  Amanda Rosa Vieira
@version P11
@Since   09/01/2017
@version 2.0
/*/
//----------------------------------------------------------
Static Function BeforeCMdl(oModel)
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:LMODIFY := .T.
	EndIf
Return .T.
//----------------------------------------------------------
/*/{Protheus.doc} CommitModel
Estorna Conferência do Volume
@author  Amanda Rosa Vieira
@version P11
@Since   09/01/2017
@version 2.0
/*/
//----------------------------------------------------------
Static Function CommitModel(oModel)
Local aAreaD01  := D02->(GetArea())
Local aAreaD02  := D02->(GetArea())
Local aAreaD03  := D02->(GetArea())
Local aAreaD04  := D04->(GetArea())
Local aAreaDCU  := DCU->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aVolume   := {}
Local aTamSx3   := TamSx3("DCV_QUANT")
Local cQuery    := ""
Local cAliasQry := ""
Local cVolume   := oModel:GetModel("A412DCU"):GetValue("DCU_CODVOL")
	cQuery := " SELECT DCV.DCV_CODPRO,"
	cQuery +=        " DCV.DCV_CARGA,"
	cQuery +=        " DCV.DCV_PEDIDO,"
	cQuery +=        " DCV.DCV_LOTE,"
	cQuery +=        " DCV.DCV_SUBLOT,"
	cQuery +=        " DCV.DCV_ITEM,"
	cQuery +=        " DCV.DCV_SEQUEN,"
	cQuery +=        " DCV.DCV_PRDORI,"
	cQuery +=        " DCV.DCV_QUANT,"
	cQuery +=        " D02.D02_CODEXP"
	cQuery +=   " FROM "+RetSqlName('DCV')+" DCV"
	cQuery +=  " INNER JOIN "+RetSqlName('D02')+" D02
	cQuery +=     " ON D02.D02_FILIAL = '"+xFilial('D02')+"'"
	cQuery +=    " AND D02.D02_CODEXP = (SELECT MAX(D01_CODEXP) D01_CODEXP
	cQuery +=                            " FROM "+RetSqlName('D01')+" D01
	cQuery +=                           " WHERE D01.D01_FILIAL = '"+xFilial('D01')+"'"
	cQuery +=                             " AND D01.D01_CARGA  = D02.D02_CARGA
	cQuery +=                             " AND D01.D01_PEDIDO = D02.D02_PEDIDO
	cQuery +=                             " AND D01.D_E_L_E_T_ = ' ')
	cQuery +=    " AND D02.D02_CARGA  = DCV.DCV_CARGA
	cQuery +=    " AND D02.D02_PEDIDO = DCV.DCV_PEDIDO
	cQuery +=    " AND D02.D02_PRDORI = DCV.DCV_PRDORI
	cQuery +=    " AND D02.D02_CODPRO = DCV.DCV_CODPRO
	cQuery +=    " AND D02.D02_LOTE   = DCV.DCV_LOTE
	cQuery +=    " AND D02.D02_SUBLOT = DCV.DCV_SUBLOT
	cQuery +=    " AND D02.D_E_L_E_T_ = ' '
	cQuery +=  " WHERE DCV.DCV_FILIAL = '"+xFilial('DCV')+"'"
	cQuery +=    " AND DCV.DCV_CODVOL = '"+cVolume+"'"
	cQuery +=    " AND DCV.DCV_CODMNT = (SELECT MAX(DCS_CODMNT) DCS_CODMNT"
	cQuery +=                            " FROM "+RetSqlName('DCS')+" DCS"
	cQuery +=                           " WHERE DCS.DCS_FILIAL = '"+xFilial('DCS')+"'"
	cQuery +=                             " AND DCS.DCS_CARGA  = DCV.DCV_CARGA"
	cQuery +=                             " AND DCS.DCS_PEDIDO = DCV.DCV_PEDIDO"
	cQuery +=                             " AND DCS.D_E_L_E_T_ = ' ')"
	cQuery +=    " AND DCV.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	TcSetField(cAliasQry,'DCV_QUANT','N',aTamSX3[1],aTamSX3[2])
	//Monta array para ser utilizado na função de estorno
	While (cAliasQry)->(!EoF())
		AAdd(aVolume,{(cAliasQry)->DCV_CODPRO,; //Código do produto
			          0,;                       //Quantidade já conferida
			          (cAliasQry)->DCV_QUANT,; //Quantidade do Produto
			          (cAliasQry)->DCV_CARGA,;  //Carga
			          (cAliasQry)->DCV_PEDIDO,; //Pedido
			          (cAliasQry)->DCV_LOTE,;   //Lote
			          (cAliasQry)->DCV_SUBLOT,; //Sub-lote
			          (cAliasQry)->DCV_ITEM,;   //Item
			          (cAliasQry)->DCV_SEQUEN,; //Sequência
			          (cAliasQry)->DCV_PRDORI,; //Produto Origem
			          	cVolume               ,;  //Código do Volume
			          (cAliasQry)->D02_CODEXP}) //Código de Expedição
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	WMS102GrvE(,,,,,,,,,,,aVolume)
	RestArea(aAreaD01)
	RestArea(aAreaD02)
	RestArea(aAreaD03)
	RestArea(aAreaD04)
	RestArea(aAreaDCU)
	RestArea(aAreaSC9)
Return .T.
