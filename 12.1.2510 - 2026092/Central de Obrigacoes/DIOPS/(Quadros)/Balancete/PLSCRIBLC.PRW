#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#Include 'TOTVS.ch'

Function PLSBLCCRI()
	Alert("Função descontinuada")
Return NIL

Function PLSCRIBLC()
	Alert("Função descontinuada")
Return NIL
// #DEFINE DATA_TRIM  	1
// #DEFINE REGANS    	2
// #DEFINE COD_CONTA  	3
// #DEFINE DES_CONTA  	4
// #DEFINE SALDO_ANT  	5
// #DEFINE DEBITO   		6
// #DEFINE CREDITO    	7
// #DEFINE SALDO_FIN  	8

// //--------------------------------------------------------------------------------------------------
// /*/{Protheus.doc} MenuDef

// Defininao das opcoes do menu

// @author everton.mateus
// @since 29/03/2017
// /*/
// //--------------------------------------------------------------------------------------------------
// Static Function MenuDef()

// Local cAlerta := "AVISO('A validação será executada via JOB','Dentro de instantes o Status da conta será atualizado')"
// Local cRotVldBlc := 'PLSVALBLC(B8A->B8A_CODOPE,B8A->(RECNO()))'
// Private aRotina	:= {}

// aAdd( aRotina, { "Pesquisar"			, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
// aAdd( aRotina, { "Visualizar"			, 'VIEWDEF.PLSBLCCRI'	, 0 , 2 , 0 , NIL } ) //Visualizar
// aAdd( aRotina, { "Excluir"				, 'VIEWDEF.PLSBLCCRI'	, 0 , 5 , 0 , NIL } ) //Excluir
// aAdd( aRotina, { "Valid. Selec."		, cAlerta + "," + cRotVldBlc			, 0 , 3 , 0 , NIL } ) //Validações

// Return aRotina

// //--------------------------------------------------------------------------------------------------
// /*/{Protheus.doc} ModelDef

// Definicao do modelo MVC para a tabela B8A

// @return oModel	objeto model criado

// @author everton.mateus
// @since 29/03/2017
// /*/
// //--------------------------------------------------------------------------------------------------
// Static Function ModelDef()
// Local oStruB8A 	:= FWFormStruct( 1, 'B8A', , )
// Local oStruB3F 	:= FWFormStruct( 1, 'B3F' )
// Local oModel		:= MPFormModel():New( "Balancete", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// oModel:AddFields( 'B8AMASTER', NIL, oStruB8A )
// oModel:GetModel( 'B8AMASTER' ):SetDescription( "Balancete" )
// oModel:AddGrid( 'B3FDETAIL', 'B8AMASTER', oStruB3F )
// oModel:SetRelation( 'B3FDETAIL',  { 	{ 'B3F_FILIAL', 'xFilial( "B3F" )' },;
// 											{ 'B3F_ORICRI' , '"B8A"' },;
// 											{ 'B3F_CHVORI' , 'B8A->(Recno())' };
// 					}, B3F->( IndexKey( 1 ) ) )
// oModel:SetDescription( "Balancete" )

// oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Críticas" )
// oModel:GetModel( 'B3FDETAIL' ):SetOnlyView(.T.)
// oModel:GetModel( 'B3FDETAIL' ):SetOptional(.T.)

// Return oModel
// //--------------------------------------------------------------------------------------------------
// /*/{Protheus.doc} ViewDef

// Definicao da visao MVC para a tabela B8A

// @return oView	objeto view criado

// @author everton.mateus
// @since 29/03/2017
// /*/
// //--------------------------------------------------------------------------------------------------
// Static Function ViewDef()
// Local oModel   := FWLoadModel( 'PLSMVCBLC' )
// Local oStruB8A := FWFormStruct( 2, 'B8A' )
// Local oStruB3F := FWFormStruct( 2, 'B3F' )
// Local oView    := FWFormView():New()

// oView:SetModel( oModel )
// oView:AddField( 'VIEW_B8A' , oStruB8A, 'B8AMASTER' )
// oView:AddGrid( 'VIEW_B3F', oStruB3F, 'B3FDETAIL' )

// oStruB3F:RemoveField('B3F_CODOPE')
// oStruB3F:RemoveField('B3F_CDOBRI')
// oStruB3F:RemoveField('B3F_ANO')
// oStruB3F:RemoveField('B3F_CDCOMP')

// oView:CreateHorizontalBox( 'SUPERIOR', 40 )
// oView:CreateHorizontalBox( 'INFERIOR', 60 )

// oView:SetOwnerView( 'VIEW_B8A', 'SUPERIOR' )
// oView:SetOwnerView( 'VIEW_B3F', 'INFERIOR' )

// oView:EnableTitleView( 'VIEW_B8A', "Balancete" )
// oView:EnableTitleView( 'VIEW_B3F', "Críticas no Processamento" )

// Return oView