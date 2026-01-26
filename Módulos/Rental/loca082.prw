#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOCA082.CH"

/*/{Protheus.doc} LOCA082.PRW
ITUP Business - TOTVS RENTAL
Pedido de Venda x Locação 

@type Function
@author José Eulálio
@since 16/08/2022
@version P12

/*/
Function LOCA082 
Local oBrowse

	aRotina := MenuDef() 					   
	oBrowse := FwmBrowse():NEW() 			   
	oBrowse:SetAlias("FPY")					   
	oBrowse:SetDescription(STR0001) //'Status do Equipamento x Contrato Rental'
	oBrowse:Activate() 						   

Return( NIL )
//---------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aBotao := {}

ADD OPTION aBotao Title 'Visualizar' 	Action 'VIEWDEF.LOCA082' OPERATION 2 ACCESS 0
//ADD OPTION aBotao Title 'Incluir' 		Action 'VIEWDEF.LOCA081' OPERATION 3 ACCESS 0
//ADD OPTION aBotao Title 'Alterar' 	Action 'VIEWDEF.LOCA081' OPERATION 4 ACCESS 0
//ADD OPTION aBotao Title 'Excluir' 	Action 'VIEWDEF.LOCA081' OPERATION 5 ACCESS 0
ADD OPTION aBotao Title 'Imprimir' 		Action 'VIEWDEF.LOCA082' OPERATION 8 ACCESS 0
	
Return aBotao

// Preparaçao do modelo de dados
Static Function ModelDef()
Local oModel
Local oModFPZ
Local oStrFPY:= FWFormStruct(1,'FPY')	
Local oStrFPZ:= FWFormStruct(1,'FPZ')	
Local oStrSC6:= FWFormStruct(1,'SC6', {|xCampo| xCampo <> "C6_INFAD "})

oModel := MPFormModel():New('MODELFPY') 
oModel:addFields('FPYMASTER',,oStrFPY)    
oModel:addGrid('SC6DETAIL','FPYMASTER',oStrSC6)
oModel:addGrid('FPZDETAIL','SC6DETAIL',oStrFPZ)
oModel:SetDescription(STR0001)  //'Status do Equipamento x Contrato Rental'
oModel:getModel('FPYMASTER'):SetDescription(STR0001) //'Status do Equipamento x Contrato Rental'	
oModFPZ := oModel:GetModel('FPZDETAIL')
oModel:GetModel( 'SC6DETAIL' ):SetOnlyQuery ( .T. )
//oModFPZ:SetNoInsertLine(.T.)
//oModFPZ:SetNoUpdateLine(.T.)
//oModFPZ:SetNoDeleteLine(.T.)
oModel:SetRelation('SC6DETAIL', { { 'C6_FILIAL', "xFilial('SC6')" }, { 'C6_NUM', 'FPY_PEDVEN' } }, SC6->(IndexKey(1)) )
oModel:SetRelation('FPZDETAIL', { { 'FPZ_FILIAL', "xFilial('FPZ')" }, { 'FPZ_PEDVEN', 'FPY_PEDVEN' }, { 'FPZ_PROJET', 'FPY_PROJET' }, { 'FPZ_ITEM', 'C6_ITEM' }}, FPZ->(IndexKey(1)) )
oModel:SetPrimaryKey({ 'FPY_FILIAL','FPY_PEDVEN' })
//oModel:SetPrimaryKey({ 'FPZ_FILIAL','FPZ_PEDVEN','FPZ_PROJET','FPZ_ITEM' })
Return oModel

//-------------------------------------------------------------------
// Montagem da interface
Static Function ViewDef()
Local oView
Local oModel := ModelDef()		
Local oStrFPY:= FWFormStruct(2, 'FPY')    
Local oStrSC6:= FWFormStruct(2, 'SC6', {|xCampo| xCampo <> "C6_INFAD "})
Local oStrFPZ:= FWFormStruct(2, 'FPZ' , { |x| !(ALLTRIM(x) $ 'FPZ_PEDVEN|FPZ_PROJET') } )    
oView := FWFormView():New()		
oView:SetModel(oModel)			 
oView:AddField('VIEWFPY' , oStrFPY,'FPYMASTER' )  
// Cria a estrutura das grids em formato de árvore
oView:AddGrid('VIEWSC6'  , oStrSC6,'SC6DETAIL' )
oView:AddGrid('VIEWFPZ'  , oStrFPZ,'FPZDETAIL' )

oView:CreateHorizontalBox( 'TELA', 20)
oView:CreateHorizontalBox( 'GRID1', 40)
oView:CreateHorizontalBox( 'GRID2', 40)


oView:SetOwnerView('VIEWFPY','TELA')
oView:SetOwnerView("VIEWSC6",'GRID1')
oView:SetOwnerView("VIEWFPZ",'GRID2')

Return oView

/*/{Protheus.doc} LOCxPed
ITUP Business - TOTVS RENTAL
ExecView da Rotina

@type Function
@author José Eulálio
@since 09/08/2022
@version P12

/*/
Function LOCA0821(cNumPed)
Local cStatus	:= ""
Local nOperLoc	:= MODEL_OPERATION_VIEW
Local aAreaFPY	:= FPY->(GetArea())
Local aButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} 

Default cNumPed	:= ""

If !Empty(cNumPed)
	FPY->(DbSetOrder(1)) //
	If FPY->(DbSeek(xFilial("FPY") + cNumPed))
		SC6->(DbSeek(xFilial("SC6") + cNumPed))
		/*If ALTERA
			nOperLoc	:= MODEL_OPERATION_UPDATE
		EndIf*/
		FWExecView(STR0001,'LOCA082', nOperLoc	, , { || .T. }, ,100 ,aButtons )
	EndIf
EndIf

//restaura a área e limpa array
RestArea(aAreaFPY)
aSize(aAreaFPY,0)

Return cStatus

/*/{Protheus.doc} LOCxPed
ITUP Business - TOTVS RENTAL
Rotina automática

@type Function
@author José Eulálio
@since 09/08/2022
@version P12

/*/
Function LOCA0822(aCab,aItens,nOperLoc)
Local nX		:= 0
Local nY		:= 0
/*
Local oModel 	:= Nil
Local oModelFPZ	:= Nil

Default nOperLoc	:= MODEL_OPERATION_INSERT

Private lMsErroAuto := .F.

oModel := FwLoadModel ("LOCA082")
oModel:SetOperation(nOperLoc)
oModel:Activate()
oModelFPZ := oModel:GetModel("FPZDETAIL")
SC6->(dbSetOrder(1))
//prepara cabeçalho
For nX := 1 To Len(aCab)
	oModel:SetValue("FPYMASTER", aCab[nX][1] , aCab[nX][2])
Next nX

//prepara itens
For nX := 1 To Len(aItens)
	oModelFPZ:AddLine()
	For nY := 1 To Len(aItens[nX])
		xxx := oModelFPZ:SetValue(aItens[nX][ny][1] , aItens[nX][ny][2])
	Next nY
Next nX

//valida e grava modelo
If oModel:VldData()
	oModel:CommitData()
	//MsgInfo("Registro INCLUIDO!", "Atenção")
Else
	VarInfo("",oModel:GetErrorMessage())
EndIf

oModel:DeActivate()
oModel:Destroy()
oModel := NIL
*/
//prepara cabeçalho
RecLock("FPY", .T.)
For nX := 1 To Len(aCab)
	FPY->(FieldPut( FieldPos( aCab[nX][1]) , aCab[nX][2]))
Next nX
MsUnlock()
//prepara itens
For nX := 1 To Len(aItens)
	RecLock("FPZ", .T.)
	For nY := 1 To Len(aItens[nX])
		FPZ->(FieldPut( FieldPos(aItens[nX][ny][1]), aItens[nX][ny][2]))
	Next nY
	MsUnlock()
Next nX

Return


