#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WMSA413A.CH"

#DEFINE WMSA413A01 "WMSA413A01"

//--------------------------------------------------
/*/{Protheus.doc} WMSA413A
Programa que contém a regra de estorno / exclusão do item do embarque (D0Z)
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Function WMSA413A()
Return Nil

Static Function MenuDef()
Local aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION "WMS413AEst()" OPERATION 4 ACCESS 0 // Estornar Item Conferência
Return aRotina

Static Function ModelDef()
Local oModel     := MPFormModel():New('WMSA413A',,,{|oModel| CommitMdl(oModel) })
Local oStrFldD0Z := FWFormStruct(1, 'D0Z')
Local oStrGrdD0Z := FWFormStruct(1, 'D0Z')
Local cEmbarque  := D0Z->D0Z_EMBARQ
Local cCarga     := D0Z->D0Z_CARGA
Local cPedido    := D0Z->D0Z_PEDIDO
Local cItem      := D0Z->D0Z_ITEM
Local cSequen    := D0Z->D0Z_SEQUEN
Local cPrdOri    := D0Z->D0Z_PRDORI
Local cProduto   := D0Z->D0Z_PRODUT

	oStrFldD0Z:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	oStrGrdD0Z:SetProperty('*',MODEL_FIELD_OBRIGAT,.F.)
	
	oModel:AddFields('D0ZFIELD',,oStrFldD0Z)

	oModel:AddGrid( 'D0ZGRID', 'D0ZFIELD'  , oStrGrdD0Z, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	
	oModel:SetRelation( 'D0ZGRID', {{'D0Z_FILIAL',"xFilial('D0Z')"},;
									   {'D0Z_EMBARQ','D0Z_EMBARQ'},;
									   {'D0Z_CARGA','D0Z_CARGA'},;
									   {'D0Z_PEDIDO','D0Z_PEDIDO'},;
									   {'D0Z_ITEM','D0Z_ITEM'},;
									   {'D0Z_SEQUEN','D0Z_SEQUEN'},;
									   {'D0Z_PRDORI','D0Z_PRDORI'};
									   } , D0Z->( IndexKey(1) )  )
	oModel:GetModel( 'D0ZGRID' ):SetDescription(STR0003) // Itens Embarque

	If lEstorno .And. !(cPrdOri == cProduto)
		oModel:GetModel( 'D0ZGRID' ):SetLoadFilter({{'D0Z_EMBARQ' ,"'"+cEmbarque+"'",1},;
												   {'D0Z_CARGA' ,"'"+cCarga+"'",1},;
												   {'D0Z_PEDIDO' ,"'"+cPedido+"'",1},;
												   {'D0Z_ITEM' ,"'"+cItem+"'",1},;
												   {'D0Z_SEQUEN' ,"'"+cSequen+"'",1},;
												   {'D0Z_PRDORI' ,"'"+cPrdOri+"'",1},;
												   {'D0Z_PRODUT' ,"'"+cProduto+"'",1}})
	Else
		oModel:GetModel( 'D0ZGRID' ):SetLoadFilter({{'D0Z_EMBARQ' ,"'"+cEmbarque+"'",1},;
												   {'D0Z_CARGA' ,"'"+cCarga+"'",1},;
												   {'D0Z_PEDIDO' ,"'"+cPedido+"'",1},;
												   {'D0Z_ITEM' ,"'"+cItem+"'",1},;
												   {'D0Z_SEQUEN' ,"'"+cSequen+"'",1},;
												   {'D0Z_PRDORI' ,"'"+cPrdOri+"'",1}})
	EndIf
	oModel:GetModel('D0ZGRID'):SetNoInsertLine( .T. )
	oModel:GetModel('D0ZGRID'):SetNoDeleteLine( .T. )
	oModel:GetModel('D0ZGRID'):SetNoUpdateLine( .T. )
	oModel:GetModel('D0ZGRID'):SetOptional( .T. )

	oModel:SetDescription(STR0004) //Embarque Expedição
	oModel:GetModel("D0ZFIELD"):SetDescription(STR0005) //Embarque Expedição Itens
	oModel:SetPrimaryKey({"D0Z_EMBARQ","D0Z_CARGA","D0Z_PEDIDO","D0Z_ITEM","D0Z_PRDORI","D0Z_PRODUT","D0Z_LOTECTL","D0Z_NUMLOT"})

	oModel:SetActivate({|oModel| SetActive(oModel) })
Return oModel

Static Function ViewDef()
Local oModel := ModelDef()
Local oView  := FWFormView():New()
Local oStrFldD0Z  := FWFormStruct(2,'D0Z')
Local oStrGrdD0Z  := FWFormStruct(2,'D0Z')

	oStrGrdD0Z:RemoveField('D0Z_FILIAL')

	oView:SetModel(oModel)
	oView:AddField( 'D0ZFIELD', oStrFldD0Z )
	oView:AddGrid('D0ZGRID', oStrGrdD0Z)

	oView:CreateHorizontalBox('MASTER',0,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/)
	oView:CreateHorizontalBox('DETAIL',100)	
	
	oView:CreateFolder('IDFOLDER','DETAIL')

	oView:AddSheet('IDFOLDER','IDSHEET01',STR0006) //Itens Embarque Expedição
	oView:CreateHorizontalBox('DETAIL_1', 100,,,'IDFOLDER', 'IDSHEET01')
	
	oView:SetOnlyView('D0ZGRID')
	oView:SetOwnerView('D0ZGRID', 'DETAIL_1')

	oView:SetOwnerView('D0ZFIELD','MASTER')
	oView:SetUseCursor(.F.)
Return oView
//--------------------------------------------------
/*/{Protheus.doc} SetActive
Realiza alguma alteração no modelo para possibilitar a confirmação da alteração.
@author  amanda.vieira
@since   18/06/2020
@version 1.0
@param 	 oModel, objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function SetActive(oModel)
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModel:GetModel("D0ZFIELD"):SetValue("D0Z_STATUS", oModel:GetModel("D0ZFIELD"):GetValue("D0Z_STATUS"))
	EndIf
	lEstorno := .F.
Return .T.
//--------------------------------------------------
/*/{Protheus.doc} EstItem
Inicia processo de estorno do item / WMS413AEst
@author  amanda.vieira
@since   18/06/2020
@version 1.0
/*/
//--------------------------------------------------
Function WMS413AEst()
Local lRet := .T.
	lEstorno := .T.
	lRet := FWExecView(STR0007,'WMSA413A',4,,{ || .T. },,,,{ || .T. }) == 0 // Estornar Item Conferência
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} CommitMdl
Realiza commit do modelo de dados
@author  amanda.vieira
@since   18/06/2020
@version 1.0
@param 	 oModel, objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function CommitMdl(oModel)
Return FWFormCommit(oModel,/*bBefore*/,/*bAfter*/,/*bAfterSTTS*/,{|oModel| InTTS(oModel)},/*bABeforeTTS*/,/*bIntegEAI*/)
//--------------------------------------------------
/*/{Protheus.doc} InTTS
Bloco de código chamado dentro da transação do commit
@author  amanda.vieira
@since   18/06/2020
@version 1.0
@param 	 oModel, objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function InTTS(oModel)
Local oEstEmbItem := Nil
Local oModelD0Z   := oModel:GetModel("D0ZFIELD")
Local cAliasD17   := ""
Local lRet        := .T.
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		//Deleta D17 caso não exista outra D0Z relacionada ao mesmo Id DCF
		cAliasD17 := GetNextAlias()
		BeginSql Alias cAliasD17
			SELECT D17.R_E_C_N_O_ RECNOD17
			  FROM  %Table:SC9% SC9
			 INNER JOIN %Table:D17% D17
			    ON D17.D17_FILIAL = %xFilial:D17%
			   AND D17.D17_EMBARQ = %Exp:oModelD0Z:GetValue("D0Z_EMBARQ")%
			   AND D17.D17_IDDCF = SC9.C9_IDDCF
			   AND D17.%NotDel%
			 WHERE SC9.C9_FILIAL = %xFilial:SC9%
			   AND SC9.C9_PEDIDO = %Exp:oModelD0Z:GetValue("D0Z_PEDIDO")%
			   AND SC9.C9_ITEM = %Exp:oModelD0Z:GetValue("D0Z_ITEM")%
			   AND SC9.C9_SEQUEN = %Exp:oModelD0Z:GetValue("D0Z_SEQUEN")%
			   AND SC9.%NotDel%
			   AND NOT EXISTS ( SELECT 1
								  FROM %Table:D0Z% D0Z
							     WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
								   AND D0Z.D0Z_EMBARQ = %Exp:oModelD0Z:GetValue("D0Z_EMBARQ")%
								   AND D0Z.D0Z_CARGA = SC9.C9_CARGA
								   AND D0Z.D0Z_PEDIDO = SC9.C9_PEDIDO
								   AND D0Z.D0Z_ITEM = SC9.C9_ITEM
								   AND D0Z.D0Z_SEQUEN <> SC9.C9_SEQUEN
								   AND D0Z.D0Z_PRDORI = SC9.C9_PRODUTO
								   AND D0Z.%NotDel% )
		EndSql
		If (cAliasD17)->(!EoF())
			D17->(dbGoTo( (cAliasD17)->RECNOD17 ))
			RecLock('D17', .F.)
			D17->(dbDelete())
			D17->(MsUnlock())
		EndIf
		(cAliasD17)->(DbCloseArea())
	Else 
		oEstEmbItem := WMSDTCEmbarqueExpedicaoItens():New()
		oEstEmbItem:GoToD0Z(D0Z->(Recno()))
		If !(lRet := oEstEmbItem:EstEmbItem())
			oModel:SetErrorMessage(oModel:GetId(),oModel:GetId(),,,WMSA413A01,oEstEmbItem:GetErro())
		EndIf
		FreeObj(oEstEmbItem)
	EndIf
Return lRet
//--------------------------------------------------
/*/{Protheus.doc} WMS413Est
Seta informação que o processo em execução trata-se de um estorno
@author  amanda.vieira
@since   18/06/2020
@version 1.0
@param 	 lProcEst, lógico, indica se o processo em execução é um estorno
/*/
//--------------------------------------------------
Static lEstorno := .F.
Function WMS413Est(lProcEst)

	lEstorno := lProcEst

Return
