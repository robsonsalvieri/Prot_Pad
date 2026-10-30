#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "LOCA081.CH"   

/*/{Protheus.doc} LOCA081.PRW
ITUP Business - TOTVS RENTAL
Status do Equipamento x Contrato Rental

@type Function
@author José Eulálio
@since 05/08/2022
@version P12

/*/
Function LOCA081 /*RETIRAR USER FUNCION */
Local oBrowse

	aRotina := MenuDef() 					   
	oBrowse := FwmBrowse():NEW() 			   
	oBrowse:SetAlias("FQD")					   
	oBrowse:SetDescription(STR0001) //STR0001 //'Status do Equipamento x Contrato Rental'
	oBrowse:Activate() 						   

Return( NIL )
//---------------------------------------------------------------------------------------------

Static Function MenuDef()

Local aBotao := {}

ADD OPTION aBotao Title STR0002	Action 'VIEWDEF.LOCA081' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aBotao Title STR0003	Action 'VIEWDEF.LOCA081' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aBotao Title STR0004	Action 'VIEWDEF.LOCA081' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aBotao Title STR0006	Action 'VIEWDEF.LOCA081' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aBotao Title STR0005	Action 'VIEWDEF.LOCA081' OPERATION 8 ACCESS 0 //'Imprimir'
	
Return aBotao

// Preparaçao do modelo de dados
Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct(1,'FQD')	
oModel := MPFormModel():New('MODELFQD') 
oModel:addFields('FQDMASTER',,oStr1)    
oModel:SetDescription(STR0001)  //STR0001 //'Status do Equipamento x Contrato Rental'
oModel:getModel('FQDMASTER'):SetDescription(STR0001) //STR0001	 //'Status do Equipamento x Contrato Rental'
oModel:SetPrimaryKey({ 'FQD_STATQY' })
Return oModel

//-------------------------------------------------------------------
// Montagem da interface
Static Function ViewDef()
Local oView
Local oModel := ModelDef()		
Local oStr1:= FWFormStruct(2, 'FQD')    
oView := FWFormView():New()		
oView:SetModel(oModel)			 
oView:AddField('VIEWFQD' , oStr1,'FQDMASTER' )  
oView:CreateHorizontalBox( 'TELA', 100)			
oView:SetOwnerView('VIEWFQD','TELA')
Return oView

/*/{Protheus.doc} Tqy2Fqd
ITUP Business - TOTVS RENTAL
Retorna o Status do Bem no Contrato Rental a partir do STatus do bem

@type Function
@author José Eulálio
@since 09/08/2022
@version P12

/*/
Function Tqy2Fqd(cStatRef,cAliasRef)
Local cStatus	:= ""
Local nIndice	:= 1 //FQD_FILIAL+FQD_STATQY+FQD_STAREN
Local aAreaFqd	:= FQD->(GetArea())

Default cAliasRef := ""

//Seleciona o índice de acordo com o Alias
If cAliasRef == "AA3"
	nIndice	:= 3 //FQD_FILIAL+FQD_STAAA3
EndIf

//Localiza o Status do Bem
FQD->(DbSetOrder(1)) 
If FQD->(DbSeek(xFilial("FQD") + cStatRef))
	cStatus := FQD->FQD_STAREN
EndIf

//restaura a área e limpa array
RestArea(aAreaFqd)
aSize(aAreaFqd,0)

Return cStatus

/*/{Protheus.doc} Tqy2Fqd
ITUP Business - TOTVS RENTAL
Retorna o Status do Bem no Contrato Rental a partir do STatus do bem

@type Function
@author José Eulálio
@since 09/08/2022
@version P12

/*/
Function LOCA0810(cStatRef,cAliasRef)
Local cStatus	:= ""
Local nIndice	:= 1 //FQD_FILIAL+FQD_STATQY+FQD_STAREN
Local aAreaFqd	:= FQD->(GetArea())

Default cAliasRef := ""

//Seleciona o índice de acordo com o Alias
If cAliasRef == "AA3"
	nIndice	:= 3 //FQD_FILIAL+FQD_STAAA3
EndIf

//Localiza o Status do Bem
FQD->(DbSetOrder(1)) 
If FQD->(DbSeek(xFilial("FQD") + cStatRef))
	cStatus := FQD->FQD_STAREN
EndIf

//restaura a área e limpa array
RestArea(aAreaFqd)
aSize(aAreaFqd,0)

Return cStatus


// Rotina para inicializador do browse para os campos virtuais da FQD
// Frank Z Fuga em 03/05/2023
Function LOCA081A(cCampo,lSX7)
Local cTexto := ""
Local cVar   := ""
Default lSX7 := .F.
	If cCampo == "FQD_STATQY"
		If lSX7
			cVar := "M->FQD_STATQY"
		else
			cVar := "FQD->FQD_STATQY"
		EndIF
		If !empty( &(cVar) )
			cTexto := Posicione("TQY",1,xfilial("TQY") + &(cVar) ,"TQY_DESTAT")                
		else
			cTexto := STR0007 //"Minuta"
		EndIF
	ElseIf cCampo == "FQD_STAREN"
		If lSX7
			cVar := "M->FQD_STAREN"
		else
			cVar := "FQD->FQD_STAREN"
		EndIF
		If !empty( &(cVar) )
			cTexto := Posicione("SX5",1,xFilial("SX5")+"QY"+ &(cVar),"X5_DESCRI")             
		else
			cTexto := STR0007 //"Minuta"
		EndIF
	ElseIf cCampo == "FQD_STAAA3"
		If lSX7
			cVar := "M->FQD_STAAA3"
		else
			cVar := "FQD->FQD_STAAA3"
		EndIF
		If !empty( &(cVar) )
			cTexto := Posicione("SX5",1,xFilial("SX5")+"A5"+ &(cVar),"X5_DESCRI")             
		else
			cTexto := STR0007 //"Minuta"
		EndIF
	EndIF
Return cTexto
