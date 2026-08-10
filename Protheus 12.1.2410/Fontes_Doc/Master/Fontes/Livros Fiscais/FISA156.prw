#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA156.CH"

PUBLISH MODEL REST NAME FISA156MOD

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA156
Códigos de Valores Declaratórios

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------
Function FISA156()

	Local oBrowse

	IF  AliasIndic("CDY") .And. CDY->(FieldPos("CDY_DTINI")) > 0 .and. CDY->(FieldPos("CDY_DTFIM")) > 0
		Private nRecno := CDY->(Recno())	
		
		oBrowse := FWMBrowse():New()
		oBrowse:SetDescription(STR0001)		
		oBrowse:SetAlias("CDY")
		oBrowse:SetUseFilter(.T.)
		oBrowse:Activate()		
	Else
		Help("",1,"Help","Help",STR0002,1,0) //Tabela CDY não cadastrada ou desatualizada, verifique atualização do dicionário de dados!
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA156' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA156' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA156' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA156' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructCAB := FWFormStruct(1,"CDY")    
	
	oModel	:=	MPFormModel():New('FISA156MOD',,{ |oModel| ValidForm(oModel) })
	
	oModel:AddFields('FISA156MOD',,oStructCAB)	

Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel("FISA156")
	Local oStructCAB := FWFormStruct(2,"CDY")	

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructCAB,'FISA156MOD')	

	oView:CreateHorizontalBox("CABEC",100)

	oView:SetOwnerView("VIEW_CAB","CABEC")	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas

@author Rafael dos Santos
@since 26.09.2018
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)

Local lRet        :=    .T.
Local cCodigo     :=    oModel:GetValue('FISA156MOD','CDY_CODAJU')
Local cDtini      :=    oModel:GetValue('FISA156MOD','CDY_DTINI')
Local nOperation  :=    oModel:GetOperation()
Local nRecno      := CDY->(Recno())
Local nRecnoVld   := 0

If (nOperation == MODEL_OPERATION_INSERT) .OR. (nOperation == MODEL_OPERATION_UPDATE)
	CDY->(DbSetOrder(1))
	//CDY_FILIAL, CDY_CODAJU, CDY_DTINI
	If CDY->(DbSeek(xFilial("CDY")+cCodigo+DTOS(cDtini)))
		If nOperation == MODEL_OPERATION_UPDATE //Alteração
			nRecnoVld :=  CDY->(Recno())
			If nRecnoVld <> nRecno
				Help(" ",1,"Help",,STR0007,1,0)//Registro já cadastrado
				lRet := .F.
			EndIf
		Else
			Help(" ",1,"Help",,STR0007,1,0)//Registro já cadastrado
			lRet := .F.
		EndIf
		//Volta Recno posicionado na tela
		CDY->(DbGoTo(nRecno))
	EndIf
EndIf

Return lRet




