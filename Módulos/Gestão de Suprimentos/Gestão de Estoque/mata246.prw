#INCLUDE 'Protheus.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA246.CH"
PUBLISH MODEL REST NAME MATA246 SOURCE MATA246 RESOURCE OBJECT oRestMata246
//-------------------------------------------------------------------
/*/{Protheus.doc} MATA246()
Movimentos Internos WMS

@author Bruno.Schmidt
@since  01/10/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA246()
Local oBrowse:= FWMBrowse():New()

	oBrowse:SetAlias('DH1')
	oBrowse:SetDescription(STR0001)
	oBrowse:SetMenuDef('MATA246')
	oBrowse:SetFilterDefault( "DH1_STATUS=='1'" )
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu

@author Bruno.Schmidt
@since  01/10/2015
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------	
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.MATA246' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.MATA246' OPERATION 5 ACCESS 0 // Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo

@author Bruno.Schmidt
@since  01/10/2015
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruDH1  := FWFormStruct( 1, 'DH1')
Local oModel    := Nil 
Local oWmsEvent := WMSModelEventMata246():New()

	//-- Cria a estrutura basica
	oModel := MPFormModel():New('MATA246', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	//-- Adiciona o componente de formulario no model 
	oModel:AddFields( 'DH1MASTER', /*cOwner*/  , oStruDH1)
	//-- Configura o model	
	oModel:SetPrimaryKey( {"DH1_DOC","DH1_PRODUT","DH1_LOTECT","DH1_TM","DH1_NUMSEQ"} )
	oModel:SetDescription(STR0001) 
	oModel:GetModel( 'DH1MASTER' ):SetDescription(STR0001)
	oModel:InstallEvent("WMSM246", /*cOwner*/, oWmsEvent)

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View

@author Bruno.Schmidt
@since  01/10/2015
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'MATA246' )
Local oStruDH1 := FWFormStruct( 2, 'DH1')

	oView := FWFormView():New()
	//-- Associa o View ao Model
	oView:SetModel( oModel )
	//-- Insere os componentes na view
	oView:AddField( 'VIEW_DH1', oStruDH1,'DH1MASTER' )
	//-- Cria os Box's
	oView:CreateHorizontalBox( 'CORPO',100)
	//-- Associa os componentes Cabecalho
	oView:SetOwnerView( 'VIEW_DH1' , 'CORPO')

Return oView

/*/{Protheus.doc} oRestMata246
	Instancia do FwRestModel para remover os metodos POST e PUT
	@type  Class
	@author Rodrigo Lombardi
	@since 02/02/2024
	@version 1.0	
/*/
Class oRestMata246 From FwRestModel

	Method SaveData()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveData
Método responsável por salvar o registro recebido pelo metodo PUT ou POST.
Se o parametro cPK não for informado, significa que é um POST.

@param	cPK			PK do registro.
@param	cData		Conteúdo a ser salvo
@param	@cError	Retorna o alguma mensagem de erro
@return	lRet		Indica se o registro foi salvo

@author Felipe Bonvicini Conti
@since 25/06/2015
@version P11, P12
/*/
//-------------------------------------------------------------------
Method SaveData(cPK, cData, cError) Class oRestMata246
local lRet := .F.
Default cData	:= ""
cError := STR0004 //Metodo Invalido
//Desativa os metodos PUT e POST retornando erro 400
Return lRet
