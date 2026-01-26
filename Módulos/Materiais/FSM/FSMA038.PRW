#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMKITSATENDENTE source FSMA038 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local oStruJOA	:= FWFormStruct(1,"JOA")
Local oStruJOB	:= FwFormStruct(1,'JOB')

oStruJOA:AddField("Quantidade JOB"      ,"Quantidade"  ,"JOA_QTDTOT","C",TamSx3('JO3_QUANTI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStruJOB:AddField("Descrição Do Produto","Descr.Prod","JOB_DSCSB1","C",TamSx3('B1_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	

oModel := MPFormModel():New('FSMA038', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JOAMASTER',nil,oStruJOA)

oModel:AddGrid('JOBDETAIL','JOAMASTER',oStruJOB )

oModel:SetRelation('JOBDETAIL', {{'JOB_FILIAL', 'xFilial("JOB")'},;
                                 {'JOB_CODJOA', 'JOA_CODIGO'}},;
                                 JOB->(IndexKey(1)))

oModel:GetModel( "JOAMASTER" ):SetDescription( 'Kits de atendimento' ) 

oModel:GetModel( "JOBDETAIL" ):SetDescription( 'Itens dos Kits de Atendimento' )     
                            
oModel:SetPrimaryKey({"JOA_FILIAL","JOA_CODIGO"})

oStruJOA:SetProperty("JOA_QTDTOT",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'getQtdJOB()'))

oStruJOA:SetProperty("JOA_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JOA","JOA_CODIGO")'))

oStruJOB:SetProperty("JOB_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JOB","JOB_CODIGO")'))
           
oStruJOB:SetProperty("JOB_DSCSB1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SB1",1,xFilial("SB1")+JOB->JOB_CODPRO,"B1_DESC"),"")'))
                     
oModel:GetModel("JOBDETAIL"):SetOptional(.T.)     

Return oModel



//-------------------------------------------------------------------
/*/{Fonte} - 
@author Vitor Kwon
@since 28/07/2025
@Return - Verifica a quantidade de registros na tabela JOB - Itens 
@version 1.0
*/
//-------------------------------------------------------------------
Function getQtdJOB()

Local aArea 	:= GetArea()
Local cAliasTmp		:= GetNextAlias()
Local cQry := ''
local oQry
Local nQuant      := 0

        cQry := " SELECT COUNT(*) QUANT "
        cQry += " from "+RetSqlName("JOB")+"  JOB "
        cQry += " WHERE JOB.D_E_L_E_T_ = ' ' "
        cQry += " AND JOB.JOB_FILIAL  = ? "
        cQry += " AND JOB_CODJOA = ? " 

        oQry := FwPreparedStatement():New(cQry)
        oQry:SetString(1, xFilial("JOB"))
        oQry:SetString(2, JOA->JOA_CODIGO)
        cQry := oQry:GetFixQuery()
        MPSysOpenQuery(cQry, cAliasTmp)

        nQuant := (cAliasTmp)->QUANT


(cAliasTmp)->(dbCloseArea())

oQry:Destroy()

FwFreeObj( oQry )

RestArea(aArea)

Return nQuant

