#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA319.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAN605
Tela para exibir os dados da V57 - Conta contabeis por lucro da exploração

@author Karen Honda
@since 27/03/2024
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFAN605( cID, cIdCodL, cRegECF )

Default cID     := ""
Default cIdCodL := ""
Default cRegECF := ""

CEB->(DBSetOrder(1)) // CEB_FILIAL, CEB_ID, CEB_REGECF, CEB_IDCODL, R_E_C_N_O_, D_E_L_E_T_
If CEB->(DBSeek(xFilial("CEB") + cID + cRegECF + cIdCodL))
    FWExecView( STR0014,"TAFAN605", 1,,{||.T.},,,/*aEnableButtons*/,,,,  )//"Contas contábeis do Lucro da Exploração"
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef onde a CEB posicionada na grid Lucro da Exploração do TAFA319 será pai (field) da V57 (contas contabeis do lucro da exploração)

@author Karen Honda
@since 27/03/2024
@version 1.0

/*/ 
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCEB   As Object
Local oStruV57   As Object
Local oModel     As Object

oStruCEB    := FWFormStruct( 1, 'CEB', /*bAvalCampo*/, /*lViewUsado*/ )
oStruV57    := FWFormStruct( 1, 'V57', /*bAvalCampo*/, /*lViewUsado*/ )
oModel      := MPFormModel():New( 'TAFAN605' , , , )

oModel:AddFields("MODEL_CEBLC", /*cOwner*/, oStruCEB)
oModel:GetModel("MODEL_CEBLC"):SetPrimaryKey({'CEB_ID','CEB_REGECF','CEB_IDCODL'})
oModel:AddGrid("MODEL_V57","MODEL_CEBLC",oStruV57)
oModel:GetModel("MODEL_V57"):SetOptional(.T.)
oModel:GetModel("MODEL_V57"):SetUniqueLine({"V57_CODCTA", "V57_CODCUS"})
oModel:SetRelation("MODEL_V57",{ {"V57_FILIAL","xFilial('V57')"}, {"V57_ID","CEA_ID"}, {"V57_IDCODL","CEB_IDCODL"}, {"V57_REGECF","CEB_REGECF"} },V57->(IndexKey(1)) )
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define um model para a linha posicionada no lucro da exploracao (TAFA319), onde a mesma irá ser o cabeçalho 
da V57, pois por limitação do MVC, não foi possivel criar a grid na mesma tela, pois o mesmo ser perde por 
existir mais de uma grid da mesma tabela

@return nil

@author Karen Honda
@since 27/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCEB	As Object
Local oStruV57	As Object
Local oModel    As Object
Local oView     As Object

oStruCEB	:= FWFormStruct(2,'CEB' )
oStruV57	:= FWFormStruct( 2, 'V57')
oModel      := FWLoadModel("TAFAN605")
oStruCEB:SetProperty( "CEB_CODLAN" , MVC_VIEW_LOOKUP , "CH6B" )

oView := FWFormView():New( )
oView:SetModel( oModel )    

oView:AddField( 'VIEW_CEBLC', oStruCEB, 'MODEL_CEBLC' )
oView:AddGrid(  'VIEW_V57', oStruV57, 'MODEL_V57' )
oView:CreateHorizontalBox( 'BOX1', 040)
oView:CreateHorizontalBox( 'BOX2', 060)
oView:SetOwnerView('VIEW_CEBLC','BOX1')
oView:SetOwnerView('VIEW_V57','BOX2')   
//oStruCEB:RemoveField('CEB_ID')
oStruCEB:RemoveField('CEB_IDCODL')
oStruV57:RemoveField('V57_CTA')

Return oView
