#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'GTPU002.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU002
Tarifas - Urbano

@author Breno Gomes
@since 06/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------

Function GTPU002()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0001)
oBrowse:SetAlias("H6S")
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

@author Breno Gomes
@since 06/02/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.GTPU002", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.GTPU002", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.GTPU002", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.GTPU002", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.GTPU002", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@author Breno Gomes
@since 06/02/2024
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel     := NIL
Local oStructH6S := FWFormStruct( 1, "H6S" ) 
Local oStructH6T := FWFormStruct( 1, "H6T" )
Local oStructH6U := FWFormStruct( 1, "H6U" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MpFormModel():New( "GTPU002", /*Pré-Validacao*/,  {|oModel| GTPUPosVld(oModel)}/*Pos-Validacao*/,/*Commit*/ )
oModel:SetDescription( STR0008 ) //"Dados de Tarifas"

oModel:AddFields("H6SMASTER", NIL, oStructH6S, /*Pre-Validacao*/, /*Pos-Validacao*/ )   
oModel:AddGrid( "H6TDETAIL", "H6SMASTER" /*cOwner*/, oStructH6T, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ ) //HISTORICO
oModel:AddGrid( "H6UDETAIL", "H6SMASTER" /*cOwner*/, oStructH6U, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ ) //AMARRAÇÃO FORMAPAG

oModel:GetModel("H6SMASTER"):SetDescription( STR0008 ) //"Dados de Tarifas"
oModel:GetModel("H6TDETAIL"):SetDescription( STR0009 ) //"Histórico de vigência     
oModel:GetModel("H6UDETAIL"):SetDescription( STR0010 ) //"Formas de pagamento"

oModel:SetRelation("H6TDETAIL", {{"H6T_FILIAL", "XFILIAL('H6T')" }, {"H6T_CODH6S", "H6S_CODIGO" }}, H6T->( IndexKey( 3 )))   //HISTORICO
oModel:SetRelation("H6UDETAIL", {{"H6U_FILIAL", "XFILIAL('H6U')" }, {"H6U_CODH6S", "H6S_CODIGO" }}, H6U->( IndexKey( 1 )))   //AMARRAÇÃO FORMAPAG

oModel:GetModel("H6TDETAIL" ):SetUniqueLine( { "H6T_DTINIV","H6T_DTFIMV","H6T_CODH6S" } )
oModel:GetModel("H6TDETAIL"):SetDelAllLine( .T. ) 

oModel:GetModel("H6UDETAIL" ):SetUniqueLine( { "H6U_CODH6R" } )
oModel:GetModel("H6UDETAIL"):SetDelAllLine( .T. ) 

oModel:SetOptional( "H6TDETAIL" , .T. )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Breno Gomes
@since 07/02/2024
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView      := Nil
Local oModel     := FWLoadModel( "GTPU002" )
Local oStructH6S := FWFormStruct( 2, "H6S" )  //MASTER
Local oStructH6T := FWFormStruct( 2, "H6T" )  //DETAIL HISTORICO
Local oStructH6U := FWFormStruct( 2, "H6U" )  //DETAIL FORMAS DE PAGAMENTO X TARIFAS

//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
oStructH6T:RemoveField('H6T_CODH6S')  
oStructH6U:RemoveField('H6U_CODH6S')  

oView := FWFormView():New()     

oView:SetModel( oModel )
oView:SetDescription( STR0001 ) //"Tarifas - Urbano"

oView:AddField("GTPU002_MASTER" , oStructH6S, "H6SMASTER" )
oView:AddGrid( "GTPU002_DETAIL" , oStructH6U, "H6UDETAIL" )  
oView:AddGrid( "GTPU002_DETAIL1", oStructH6T, "H6TDETAIL" )     

oView:CreateHorizontalBox( "FORMMASTER" , 40 )
oView:CreateHorizontalBox( "FORMDETAIL" , 30 )
oView:CreateHorizontalBox( "FORMDETAIL1", 30 )

oView:SetOwnerView( "H6SMASTER" , "FORMMASTER" )   
oView:SetOwnerView( "H6UDETAIL" , "FORMDETAIL" )   
oView:SetOwnerView( "H6TDETAIL" , "FORMDETAIL1" ) 

oView:EnableTitleView( "GTPU002_DETAIL" , STR0010  ) //"Formas de pagamento"
oView:EnableTitleView( "GTPU002_DETAIL1", STR0009) //"Histórico de vigência"
                                                    
oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPUPosVld
Valida informações ao salvar.
Uso no cadastro de Tarifas

@param 	oModel - Model a ser verificado

@Return lRet   - .T./.F. As informações são válidas ou não

@author Breno Gomes 
@since 08/02/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GTPUPosVld(oModel)
Local lRet := .T.
	//Valida se a data final é maior que a data inicial da vigência
	If oModel:GetValue("H6SMASTER","H6S_DTFIMV") < oModel:GetValue("H6SMASTER","H6S_DTINIV")
		lRet := .F.
		Help( ,, 'Help',"GTPUPosVld", STR0011, 1, 0 )//"Data final da vigência deve ser maior que a data inicial"
	EndIf
return lRet
