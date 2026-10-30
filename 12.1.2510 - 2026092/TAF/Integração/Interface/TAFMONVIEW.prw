#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'FwMvcDef.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Este PRW foi criado para a exibicao do View da tabela CU0 para o
monitor de integracao / validacao

@Return
oModel - Modelo criado para a exibicao das informacoes da tabela de
inconsistencias

@author Rodrigo Aguilar
@since 13/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oStruCU0 := FWFormStruct( 1, 'CU0' )  		  //Estrutura de dicionario da tabela CU0
    Local oModel   := MPFormModel():New( 'TAFMONVIEW' )   //Model do Monitor

    oModel:AddFields( 'MODEL_CU0', /*cOwner*/, oStruCU0 ) //Inclui os campos na tela

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View para exibicao das informacoes na tela

@Return
oView - View criado para a exibicao das informacoes da tabela de
inconsistencias

@author Rodrigo Aguilar
@since 13/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------                                                   
Static Function ViewDef()

    Local oModel   := FWLoadModel( 'TAFMONVIEW' ) //Carrega Model do Monitor
    Local oStruCU0 := FWFormStruct( 2, 'CU0' )    //Carrega estrutura da tabela CU0
    Local oView   := FWFormView():New()           //Cria View para exibir as informacoes

    oView:SetModel( oModel )
    oView:AddField( 'VIEW_CU0', oStruCU0, 'MODEL_CU0' )
    oView:CreateHorizontalBox( 'PAINEL', 100 )
    oView:SetOwnerView( 'VIEW_CU0' , 'PAINEL' )

Return ( oView )
