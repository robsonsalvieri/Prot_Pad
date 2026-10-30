#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIC356.CH"

/*/{Protheus.doc} VEIC356()
Consulta para visualizar os Cotitulares relacionados a Entrada de Usados - SOMENTE ARGENTINA que possui COTITULARES
VEIA356 - Cadastro em MVC do VWM - Cotitulares relacionados a Entrada de Usados

@author Andre Luis Almeida
@since 05/08/2026
@version 1.0
@return NIL
/*/
Function VEIC356(cVVF_FILIAL,cVVF_TRACPA)
Local cFiltro       := ""
Default cVVF_FILIAL := ""
Default cVVF_TRACPA := ""
If cPaisLoc == "ARG" .and. FWAliasInDic("VWM")
	If !Empty(cVVF_TRACPA)
		VVF->(DbSetOrder(1))
		If VVF->(DbSeek( cVVF_FILIAL + cVVF_TRACPA ))
			VC3560011_Visualizar()
		EndIf
	Else
		////////////////////////////////////////////////////////////////////////////////////////
		// Filtro do Browse - visualizar somente Entrada por Compra de Usados com Cotitulares //
		////////////////////////////////////////////////////////////////////////////////////////
		cFiltro := "VVF_OPEMOV = '0' AND VVF_SITNFI = '1' AND " // Entrada por Compra Valida
		cFiltro += "EXISTS ( SELECT VWM.VWM_TRACPA FROM "+RetSQLName("VWM")+" VWM WHERE VWM.VWM_FILIAL=VVF_FILIAL AND VWM.VWM_TRACPA=VVF_TRACPA AND VWM.D_E_L_E_T_=' ' )" // Possui Cotitulares
		oBrwVVF := FWMBrowse():New()
		oBrwVVF:SetAlias("VVF")
		oBrwVVF:SetDescription(STR0001) // Cotitulares na Entrada de Usados
		oBrwVVF:SetMenuDef( 'VEIC356' )
		oBrwVVF:SetFilterDefault("@ "+cFiltro)
		oBrwVVF:DisableDetails()
		oBrwVVF:DisableLocate()
		oBrwVVF:SetAmbiente(.F.)
		oBrwVVF:SetWalkthru(.F.)
		oBrwVVF:SetUseFilter()
		oBrwVVF:ForceQuitButton()
		oBrwVVF:Activate()
	EndIf
EndIf
Return

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 05/08/2026
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE STR0002 ACTION 'VC3560011_Visualizar' OPERATION 2 ACCESS 0 // Visualizar
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 05/08/2026
@version 1.0
@Return oModel
/*/
Static Function ModelDef()

Local oStrVVF := FWFormStruct( 1, "VVF", { |cCampo|  ALLTRIM(cCampo) $ "VVF_FILIAL/VVF_TRACPA" } )
Local oStrVWM := FWFormStruct( 1, "VWM")

oModel := MPFormModel():New("VEIC356", /* bPre */ , /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields( 'VVFMASTER', /*cOwner*/, oStrVVF, /* <bPre> */ , /* <bPost> */ , /* <bLoad>  { |oModel| loadCab(oModel) }*/ )
oModel:AddGrid( 'VWMDETAIL', 'VVFMASTER', oStrVWM)
oModel:GetModel('VVFMASTER'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR
oModel:SetDescription(STR0001) // Cotitulares na Entrada de Usados
oModel:GetModel('VWMDETAIL'):SetOptional( .T. ) // Deixar passar em branco
oModel:SetRelation('VWMDETAIL', { { 'VWM_FILIAL' , 'VVF_FILIAL' } , { 'VWM_TRACPA' , 'VVF_TRACPA' } }, VWM->( IndexKey(2) ) )
oModel:SetPrimaryKey( { "VWM_FILIAL", "VWM_TRACPA" , "VWM_CODIGO" } )

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 05/08/2026
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVWM := FWFormStruct(2, "VWM", { |cCampo| !ALLTRIM(cCampo) $ "VWM_FILIAL/VWM_CODIGO/VWM_TRACPA/VWM_CODUSR/VWM_DATMOV/VWM_HORMOV/" } )
//
oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})
oView:CreateHorizontalBox( 'TELAVWM' , 100 )
oView:AddGrid( 'VIEW_VWM', oStrVWM, 'VWMDETAIL' )
oView:SetOwnerView( "VIEW_VWM" , "TELAVWM" )
//
Return oView

/*/{Protheus.doc} VC3560011_Visualizar
Visualizar Cotitulares na Entrada de Usados

@author Andre Luis Almeida
@since 06/08/2026
@version 1.0
/*/
Function VC3560011_Visualizar()
Local oView
Local cTitTela := STR0001+" - "+AllTrim(RetTitle("VVF_FILIAL"))+": "+VVF->VVF_FILIAL+" - "+AllTrim(RetTitle("VVF_TRACPA"))+": "+VVF->VVF_TRACPA // Cotitulares na Entrada de Usados
Private oModel
oView := FWViewExec():New()
oView:setSource("VEIC356")
oView:setModal(.F.)
oView:setTitle(cTitTela)
oView:setOperation( MODEL_OPERATION_VIEW ) // View
oView:setReduction(20) // Redução de 20% da tela
oView:openView(.F.)
lRetorno := (oView:getButtonPress() == 0)
oView:DeActivate()
Return