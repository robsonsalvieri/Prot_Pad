#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA200.CH"

//----------------------------------------------------------------------
/*/{Protheus.doc} PCPA200Grv
Programa de manutenção de estruturas (SG1). Modelo para gravação dos dados.

@author Lucas Konrad França
@since 06/11/2018
@version 1.0

@return Nil
/*/
//----------------------------------------------------------------------
Function PCPA200Grv()
Return Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de gravação da SG1.

@author Lucas Konrad França
@since 06/11/2018
@version 1.0

@return oModel  - Modelo de dados da tabela SG1
/*/
//----------------------------------------------------------------------
Static Function ModelDef()
	Local oStrGrava := FWFormStruct(1,"SG1",{|cCampo| ! "|"+AllTrim(cCampo)+"|" $ "|G1_USERLGA|G1_USERLGI|"})
	Local oStruSGF  := FWFormStruct(1, "SGF")
	Local oModel    := MPFormModel():New('PCPA200Grv',,)

	oModel:SetDescription(STR0006) //"Estrutura de produtos"
	oModel:AddFields("SG1_MASTER", /*cOwner*/, oStrGrava)
	oModel:GetModel("SG1_MASTER"):SetDescription(STR0006) //"Estrutura de produtos"

	//GRID_OPE_COMP - Modelo de gravacao das exclusoes na SGF
	oModel:AddGrid("GRID_OPE_COMP", "SG1_MASTER", oStruSGF)
	oModel:GetModel("GRID_OPE_COMP"):SetDescription(STR0209) //"Relacionamento Operações x Componente"
	oModel:GetModel("GRID_OPE_COMP"):SetOptional(.T.)
	oModel:SetRelation( 'GRID_OPE_COMP', { { 'GF_FILIAL' , 'xFilial( "SGF" ) ' };
	                                     , { 'GF_PRODUTO', 'G1_COD'};
										 , { 'GF_TRT'    , 'G1_TRT'};
										 , { 'GF_COMP'   , 'G1_COMP'} } , SGF->( IndexKey( 1 ) ) )

	oModel:SetPrimaryKey({})
Return oModel

