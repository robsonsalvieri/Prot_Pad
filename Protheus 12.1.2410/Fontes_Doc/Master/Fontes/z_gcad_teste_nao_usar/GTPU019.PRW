#INCLUDE 'TOTVS.CH'
#INCLUDE "GTPU019.CH
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPU019

    @type Static Function
    @author Silas Gomes
    @since 31/07/2025
    @version 1.0
    @return oModel, return_type, return_description
/*/
//------------------------------------------------------------------------------
Function GTPU019()

    Local oBrowse  as object
	Local cMsgErro as character

	oBrowse  := Nil
	cMsgErro := ''

	If GU019VldDic(@cMsgErro)
	    oBrowse := FwMBrowse():New()
	    oBrowse:SetAlias('H84')
	    oBrowse:SetDescription(STR0001) // "Tipos de exceções"
		oBrowse:SetCacheView(.F.)
	    oBrowse:Activate()
	Else
	    FwAlertHelp(cMsgErro, STR0002) // "Banco de dados desatualizado, não será possível iniciar a rotina"
	Endif

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

    @type Static Function
    @author Silas Gomes
    @since 31/07/2025
    @version 1.0
    @return oModel, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina as array

	aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GTPU019' OPERATION 2 ACCESS 0	//'Visualizar'
	ADD OPTION aRotina TITLE "Incluir" ACTION 'VIEWDEF.GTPU019' OPERATION 3 ACCESS 0	//'Incluir'
	ADD OPTION aRotina TITLE "Alterar" ACTION 'VIEWDEF.GTPU019' OPERATION 4 ACCESS 0	//'Alterar'
	ADD OPTION aRotina TITLE "Excluir" ACTION 'VIEWDEF.GTPU019' OPERATION 5 ACCESS 0	//'Excluir'

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

    @type Static Function
    @author Silas Gomes
    @since 31/07/2025
    @version 1.0
    @return oModel, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel   as object
	Local oStruH84 as object

	oModel   := Nil
	oStruH84 := FwFormStruct(1, 'H84' )

	oModel := MPFormModel():New('GTPU019', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('H84MASTER',,oStruH84,,,)
	oModel:SetDescription(STR0001) // "Tipos de exceções"
	oModel:GetModel('H84MASTER'):SetDescription(STR0001) // "Tipos de exceções"

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	Função responsavel pela definição da view

	@type Static Function
    @author Silas Gomes
    @since 31/07/2025
    @version 1.0
    @return oModel, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView    as object
	Local oModel   as object
	Local oStruH84 as object

	oView    := FWFormView():New()
	oModel   := FwLoadModel( 'GTPU019' )
	oStruH84 := FWFormStruct(2, 'H84' )

	oView:SetModel(oModel)
	oView:AddField('VIEW_H84', oStruH84, 'H84MASTER')
	oView:SetDescription(STR0001) //"'Tipos de exceções'"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} GU019VldDic
	Função responsável por validação de dicionário

	@type Static Function
    @author Silas Gomes
    @since 31/07/2025
    @version 1.0
    @return oModel, return_type, return_description
/*/
//------------------------------------------------------------------------------
Static Function GU019VldDic(cMsgErro)

    Local lRet as logical

    Default cMsgErro := ''

    lRet := .T.

    // Verifica a tabela H84 no dicionário
    If !GTPxVldDic('H84', {}, .T., .F., @cMsgErro)
        lRet := .F.
    EndIf

    // Se não houve erro na tabela, verifica os campos
    If lRet .And. Empty(cMsgErro)
        If H84->(FieldPos('H84_FILIAL')) == 0 .Or. ;
           H84->(FieldPos('H84_CODIGO')) == 0 .Or. ;
           H84->(FieldPos('H84_DESCRI')) == 0 .Or. ;
           H84->(FieldPos('H84_TIPO')) == 0

            lRet := .F.
            cMsgErro := I18n("Campo", "H84_"+Substr(cMsgErro, At('_', cMsgErro)+1))
        EndIf
    EndIf

Return lRet
