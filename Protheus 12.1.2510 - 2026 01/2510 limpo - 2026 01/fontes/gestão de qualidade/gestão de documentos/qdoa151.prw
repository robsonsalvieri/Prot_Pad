#Include 'TOTVS.CH'
#Include 'FWMVCDEF.CH'
#INCLUDE "QDOA150.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} QDOA150
Cadastro de Departamentos

@author guilherme.pimentel
@since 26/06/2014
@version P12
@return nil
/*/
//-------------------------------------------------------------------
Function QDOA151()
Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('QAD')
	oBrowse:SetDescription(STR0006)//'Cadastro de Departamentos'

	oBrowse:AddLegend( "QAD_STATUS=='1'", "GREEN"		, STR0015 	)//'Departamento Ativo'
	oBrowse:AddLegend( "QAD_STATUS=='2'", "RED"		, STR0016)//'Departamento Inativo'

	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu

@author guilherme.pimentel
@since 26/06/2014
@version P12
@return aRotina
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina Title STR0002		Action 'VIEWDEF.QDOA151' OPERATION 2 ACCESS 0	//'Visualizar'
	ADD OPTION aRotina Title STR0003		Action 'VIEWDEF.QDOA151' OPERATION 3 ACCESS 0	//'Incluir'
	ADD OPTION aRotina Title STR0004		Action 'VIEWDEF.QDOA151' OPERATION 4 ACCESS 0	//'Alterar'
	ADD OPTION aRotina Title STR0005		Action 'VIEWDEF.QDOA151' OPERATION 5 ACCESS 0	//'Excluir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author guilherme.pimentel
@since 26/06/2014
@version P12
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
Local oStruQAD := FWFormStruct( 1, 'QAD' )
Local oStruQDT := FWFormStruct( 1, 'QDT' ) 

	oModel := MPFormModel():New('QDOA151',/*Pre-Validacao*/, {|oModel|VldTpRecbt(oModel)})

	oModel:AddFields( 'QADMASTER', /*cOwner*/, oStruQAD)
	oModel:AddGrid( 'QDTDETAIL', 'QADMASTER',oStruQDT)

	oModel:SetRelation( 'QDTDETAIL', {{ 'QDT_FILIAL', 'xFilial( "QDT" )' },{ 'QDT_FILDEP', 'xFilial( "QAD" )' },{ 'QDT_DEPTO', 'QAD_CUSTO'}}, QDT->(IndexKey(1)) )

	oModel:GetModel('QDTDETAIL'):SetUniqueLine( { 'QDT_CODMAN' } )

	oModel:SetDescription( STR0006 )

	oModel:GetModel( 'QADMASTER' ):SetDescription( STR0013 )//'Departamento'
	oModel:GetModel( 'QDTDETAIL' ):SetDescription( STR0009 )//'Pastas X Departamento'
	oModel:GetModel( 'QDTDETAIL' ):SetOptional( .T. )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author guilherme.pimentel
@since 26/06/2014
@version P12
@return oView
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oModel := ModelDef()
Local oStruQAD := FWFormStruct( 2, 'QAD', {|cCampo| !AllTrim(cCampo) $ "QAD_FILIAL"})
Local oStruQDT := FWFormStruct( 2, 'QDT', {|cCampo| !AllTrim(cCampo) $ "QDT_FILIAL,QDT_FILDEP,QDT_DEPTO,QDT_DESDEP"} )
Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_QAD', oStruQAD, 'QADMASTER' )
	oView:AddGrid( 'VIEW_QDT', oStruQDT, 'QDTDETAIL')

	If oStruQDT:HasField("QDT_FILCOD") .and. FWModeAccess("QDC",3) == "C"
		oStruQDT:RemoveField( "QDT_FILCOD")
	EndIf

	oView:CreateHorizontalBox( 'SUPERIOR', 30)
	oView:CreateHorizontalBox( 'INFERIOR', 70)

	oView:SetOwnerView( 'VIEW_QAD', 'SUPERIOR' )
	oView:EnableTitleView('VIEW_QAD',STR0013)//'Departamento'

	oView:SetOwnerView( 'VIEW_QDT', 'INFERIOR' )
	oView:EnableTitleView('VIEW_QDT',STR0009)//'Pastas X Departamento'

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} VldTpRecbt
Valida campo Tipo de recebimento da QAXA010

@author willian.ramalho
@since 25/07/2025
@type  Function
@param1 oModel, objeto, conteudo dos dados do MVC
@return False - Indica que o campo Tp Receb na QAXA010 do usuario é igual a 4 
/*/
//-------------------------------------------------------------------
Function VldTpRecbt(oModel)
Local cLoginQAD  := oModel:GetValue('QADMASTER', 'QAD_MAT')
Local cTpRecebto := Posicione("QAA", 1, xFilial("QAA") + cLoginQAD, "QAA_TPRCBT")
Local lRet       := .T.

	If cTpRecebto == "4"
		//STR0020 - O usuário não pode ser definido como responsável pelo departamento, pois no cadastro de usuários (rotina QAXA010), o campo Tipo de Recebimento está definido como 4 - Não Recebe.
		//STR0021 - Para que o usuário possa ser atribuído como responsável pelo departamento, é necessário alterar o campo Tipo de Recebimento no cadastro do usuário para um conteúdo diferente de 4 - Não Recebe.
		Help(NIL, NIL, "QDOATPRCBT", NIL, STR0020, 1, NIL, NIL, NIL, NIL, NIL, NIL, {STR0021})
		lRet:= .F.
	Endif

Return lRet
