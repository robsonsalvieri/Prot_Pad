#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'GTPU008.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU008
Cadastro de Pedágio

@author Djalma Mathias
@since 17/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Function GTPU008() 
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0001)
oBrowse:SetAlias("H72")
oBrowse:SetLocate()
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Djalma Mathias
@since 17/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.GTPU008", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.GTPU008", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.GTPU008", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.GTPU008", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.GTPU008", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina 
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@author Djalma Mathias
@since 17/02/2024
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := NIL
Local oStructH72 := FWFormStruct( 1, "H72" ) 
Local oStructH6T := FWFormStruct( 1, "H6T" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MpFormModel():New( "GTPU008", /*Pré-Validacao*/,  {|oModel| GTPUPosVld(oModel)}/*Pos-Validacao*/,/*Commit*/ )
oModel:SetDescription( STR0008 ) //"Dados de Pedágio"

oModel:AddFields("H72MASTER", NIL, oStructH72, /*Pre-Validacao*/, /*Pos-Validacao*/ )   
oModel:AddGrid( "H6TDETAIL", "H72MASTER" /*cOwner*/, oStructH6T, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ ) //HISTORICO

oModel:GetModel("H72MASTER"):SetDescription( STR0008 ) //"Dados de Pedagio"
oModel:GetModel("H6TDETAIL"):SetDescription( STR0009 ) //"Histórico de vigência     

oModel:SetRelation("H6TDETAIL", {{"H6T_FILIAL", "XFILIAL('H6T')" }, {"H6T_CODH72", "H72_CODIGO" }}, H6T->( IndexKey( 2 )))   //HISTORICO
                                                 
oModel:GetModel("H6TDETAIL" ):SetUniqueLine( { "H6T_DTINIV","H6T_DTFIMV","H6T_CODH72" } )
oModel:GetModel("H6TDETAIL"):SetDelAllLine( .T. ) 

oModel:SetOptional( "H6TDETAIL" , .T. ) 

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Djalma Mathias
@since 17/02/2024
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView      := Nil
Local oModel     := FWLoadModel( "GTPU008" )
Local oStructH72 := FWFormStruct( 2, "H72" )  //MASTER
Local oStructH6T := FWFormStruct( 2, "H6T" )  //DETAIL HISTORICO
                                               
//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
oStructH6T:RemoveField('H6T_CODH72')  

oView := FWFormView():New()     

oView:SetModel( oModel )
oView:SetDescription( STR0001 ) //"Pedagio - Urbano"

oView:AddField("GTPU008_MASTER" , oStructH72, "H72MASTER" )
oView:AddGrid( "GTPU008_DETAIL1", oStructH6T, "H6TDETAIL" )     

oView:CreateHorizontalBox( "FORMMASTER" , 40 )
oView:CreateHorizontalBox( "FORMDETAIL" , 30 )
oView:CreateHorizontalBox( "FORMDETAIL1", 30 )

oView:SetOwnerView( "H72MASTER" , "FORMMASTER" )     
oView:SetOwnerView( "H6TDETAIL" , "FORMDETAIL1" ) 

oView:EnableTitleView( "GTPU008_DETAIL1", STR0009) //"Histórico de vigência"
                                                    
oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPUPosVld
Valida informações ao salvar.
Uso no cadastro de Pedágio

@param 	oModel  	Model a ser verificado

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Djalma Mathias
@since 17/02/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GTPUPosVld(oModel)
Local lRet := .T.
	//Valida se a data final é maior que a data inicial da vigência
	If oModel:GetValue("H72MASTER","H72_DTFIMV") < oModel:GetValue("H72MASTER","H72_DTINIV")
		lRet := .F.
		Help( ,, 'Help',"GTPUPosVld", STR0010, 1, 0 )//"Data final da vigência deve ser maior que a data inicial"
	EndIf
return lRet
