#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDefEst
Função que inclui os campos de regra de custo na funcao ViewDef() da FISA160.

@type Function

@param   oCabecalho	,object(FWFormStruct)	,objeto FWFormStruct() da tabela F2B passado por referencia
@param   aOrdem		,array	               ,Define a ordem dos 2 campos
@param   cGroupName	,character	            ,ID do agrupador de campos

@param sempre .T., logico

@author reynaldo
@since 28/08/2024
@version 12.1.2410

/*/
//-------------------------------------------------------------------
Function EstViewDef(oCabecalho as object, aOrdem as array, cGroupName as character)

   oCabecalho:SetProperty("F2B_RCUSTO" , MVC_VIEW_ORDEM  , "20")
   oCabecalho:SetProperty("F2B_DCUSTO" , MVC_VIEW_ORDEM  , "21")

   oCabecalho:SetProperty("F2B_RCUSTO" , MVC_VIEW_GROUP_NUMBER, cGroupName )
   oCabecalho:SetProperty("F2B_DCUSTO" , MVC_VIEW_GROUP_NUMBER, cGroupName )

   oCabecalho:SetProperty("F2B_RCUSTO", MVC_VIEW_TITULO, "Custo")
   oCabecalho:SetProperty("F2B_DCUSTO", MVC_VIEW_TITULO, "Desc. Custo")

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTGravF2B
Função que grava os campos da tabela F2B, a qual o modulo de estoque é responsavel, pelo Model

@type Function

@param   oModel	,object(FWFormStruct)	,objeto FWFormStruct() da tabela F2B passado por referencia

@param sempre .T., logico

@author reynaldo
@since 28/08/2024
@version 12.1.2410

/*/
//-------------------------------------------------------------------
Function ESTGravF2B(oModel)
Local cRegra := oModel:GetValue ('FISA160',"F2B_RCUSTO")     // Config Arred  

    F2B->F2B_RCUSTO  := cRegra
    
Return .T.
