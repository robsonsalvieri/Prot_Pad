#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA485.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA485
Cadastro MVC de Cadastro de Consolidação do E-Social                                                                                                                                                                                                                                                                                                                                                                                                                                                                             

@author Fabio V Santana
@since 19/12/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA485()
Local	oBrw		:=	FWmBrowse():New()

If TafAtualizado()
    oBrw:SetDescription(STR0001) //Cadastro de Consolidação do E-Social                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    oBrw:SetAlias('T93')
    oBrw:SetMenuDef( 'TAFA485' )
    oBrw:Activate()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 19/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWMVCMenu( "TAFA485" )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 19/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT93 	:= 	FWFormStruct( 1, 'T93' )
Local oStruT94 	:= 	FWFormStruct( 1, 'T94' )

Local oModel 	:= 	MPFormModel():New( 'TAFA485' )

oModel:AddFields('MODEL_T93',, oStruT93)
                                         
oModel:AddGrid('MODEL_T94', 'MODEL_T93', oStruT94)             
oModel:GetModel( 'MODEL_T94' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_T94' ):SetUniqueLine({'T94_NODE'}) 
oModel:SetRelation( 'MODEL_T94' , { { 'T94_FILIAL' , 'xFilial( "T94" )' } , { 'T94_EVENTO' , 'T93_EVENTO' } } , T94->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_T93" ):SetPrimaryKey( { "T93_EVENTO" } )                                                                                                                                  

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 19/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 		:= 	FWLoadModel( 'TAFA485' )
Local oStruT93 	:= 	FWFormStruct( 2, 'T93' )
Local oStruT94	:= 	FWFormStruct( 2, 'T94' )
Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T93', oStruT93, 'MODEL_T93' )
oView:EnableTitleView( 'VIEW_T93', STR0001 ) //"Cadastro de Consolidação do E-Social"
                                             
oView:AddGrid ( 'VIEW_T94', oStruT94, 'MODEL_T94' )
oView:EnableTitleView( 'VIEW_T94', STR0002) //Controle por Tag

oView:CreateHorizontalBox( 'FIELDST93', 20 )
oView:CreateHorizontalBox( 'GRIDT94', 80)

oView:SetOwnerView( 'VIEW_T93', 'FIELDST93' )
oView:SetOwnerView( 'VIEW_T94', 'GRIDT94' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCrtTag
Função que valida se é permitido alterar linha de grid

@return lReturn - Lógico

@author Denis.oliveira .and. Vitor.Siqueira
@since 05/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function VldCrtTag( cCmp, cEvento, lInteg )

Local lReturn 	:= .T.

Default cCmp		:= ""
Default cEvento	:= ""
Default lInteg	:= .F.

If cCmp == "2" .and. !(cEvento $ "000003|000023|000024|000025")
	If !lInteg
		Help( ,,"TAFA485",,STR0003, 5, 0 )
		lReturn := .F.
	Else
		lReturn := .F.
	EndIf

EndIf

Return lReturn
