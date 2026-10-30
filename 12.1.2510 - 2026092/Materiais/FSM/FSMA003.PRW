
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FSMA003
@author Vitor kwon
@since 08/11/2023
@version 1.0
/*/
//-------------------------------------------------------------------

PUBLISH MODEL REST NAME FSMGRUPOSPRODUTO source FSMA003 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados
@author Vitor Kwon
@since 30/20/2023
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()

Local oModel    := NIL
Local oStruSBM  := FWFormStruct( 1, "SBM" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "FSMA003", /*Pre-Validacao*/, /*Pos-Validacao*/,,/*Commit*/,/*Cancel*/)
oModel:AddFields( "SBMMASTER", NIL, oStruSBM, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( 'Grupo de produtos' ) 

oModel:GetModel( "SBMMASTER" ):SetDescription( 'Grupo de produtos' ) 


Return oModel
