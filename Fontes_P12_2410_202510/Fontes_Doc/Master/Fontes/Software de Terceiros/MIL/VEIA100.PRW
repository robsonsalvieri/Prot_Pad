
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#include "VEIA100.CH"

static _lValProsp

/*/{Protheus.doc} Menudef
	MenuDef
	
	@type function
	@author Vinicius Gati
	@since 08/02/2019
/*/
Static Function MenuDef()
Return FWMVCMenu("VEIA100")

/*/{Protheus.doc} VEIA100
	Cadastro de frotas
	
	@type function
	@author Vinicius Gati
	@since 08/02/2019
/*/
function VEIA100()
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VC3')
	oBrowse:SetDescription(STR0001) //'Cadastro de Frota'
	oBrowse:Activate()
return .t.



/*/{Protheus.doc} ModelDef
	ModelDef
	
	@type function
	@author Vinicius Gati
	@since 08/02/2019
/*/
static function ModelDef()
	Local oStrVC3  := FWFormStruct(1, 'VC3')
	

	if _lValProsp == NIL
		_lValProsp := VA100005B_ValidaProspect()
	Endif

	oModel := MPFormModel():New(;
		'VEIA100',;
		,; // bPre
		{ |oMdl| VA1000024_PosSalvar(oMdl, _lValProsp) }; // bPost
	)
	

	oStrVC3:SetProperty('VC3_NOMCLI', MODEL_FIELD_INIT , {|oModel| VA1000034_CliName(oModel, _lValProsp) })
	oStrVC3:SetProperty('VC3_CODCLI', MODEL_FIELD_VALID, {|oModel| VA1000044_ExistCliente(oModel) })
	oStrVC3:SetProperty('VC3_LOJA'  , MODEL_FIELD_VALID, {|oModel| VA1000044_ExistCliente(oModel) })

	If _lValProsp
		oStrVC3:SetProperty('VC3_CODPRO', MODEL_FIELD_VALID, {|oModel| VA100006B_ExistProspect(oModel) })
		oStrVC3:SetProperty('VC3_LOJPRO', MODEL_FIELD_VALID, {|oModel| VA100006B_ExistProspect(oModel) })
	Endif

	oStrVC3:SetProperty('VC3_DATINC', MODEL_FIELD_WHEN , {|oModel| oModel:GetOperation() == MODEL_OPERATION_INSERT })

	oModel:AddFields('MASTER', , oStrVC3)
	oModel:GetModel('MASTER'):SetDescription(STR0003) // Frota
	oModel:SetPrimaryKey({'VC3_FILIAL', 'VC3_UUID'})
	oModel:SetDescription(STR0003) // Frota

	oModel:AddRules('MASTER', 'VC3_LOJA',   'MASTER', 'VC3_CODCLI', 3)
	
	If _lValProsp
		oModel:AddRules('MASTER', 'VC3_LOJPRO', 'MASTER', 'VC3_CODPRO', 3)
	EndIf

return oModel

/*/{Protheus.doc} ViewDef
	ViewDef
	
	@type function
	@author Vinicius Gati
	@since 08/02/2019
/*/
static function ViewDef()
	Local oModel   := Modeldef()
	Local oStruVC3 := FWFormStruct(2, 'VC3')

	oView := FWFormView():New()

	oStruVC3:SetProperty('VC3_DATALT', MVC_VIEW_CANCHANGE , INCLUI)
	
	oView:SetModel(oModel)
	oView:CreateHorizontalBox('BOX1', 100)
	oView:AddField('VIEW_MASTER', oStruVC3, 'MASTER')
	oView:SetOwnerView('VIEW_MASTER','BOX1')
	oView:EnableTitleView('VIEW_MASTER', STR0001) //'Cadastro Frota'

return oView

/*/{Protheus.doc} VA1000024_PosSalvar
	Envia os dados do modelo para integracoes salesforce

	@type function
	@author Vinicius Gati
	@since 13/02/2019
/*/
static function VA1000024_PosSalvar(oModel, lValProsp)
	local lCLiOk := !Empty(oModel:GetValue('MASTER', 'VC3_CODCLI')) .and. !Empty(oModel:GetValue('MASTER', 'VC3_LOJA'))
	// local oApi   := VEFrotaApi():New()
	local lProOk := .T.

	If lValProsp
		lProOk := !Empty(oModel:GetValue('MASTER', 'VC3_CODPRO')) .and. !Empty(oModel:GetValue('MASTER', 'VC3_LOJPRO'))
	Endif

	if !lCLiOk .and. !lProOk
		FMX_HELP("VA100ERR01",STR0004, STR0005) // "Cliente/Prospect Obrigatório."		"Necessário preencher o campo Cliente/Loja ou Prospect/Loja Prosp."
		return .F.
	endif
Return .t.

/*/{Protheus.doc} VA1000034_CliName
	Pega o nome do cliente
	
	@type function
	@author Vinicius Gati
	@since 13/02/2019
/*/
static function VA1000034_CliName(oModel, lValProsp)
	if !Empty(oModel:GetValue('VC3_CODCLI'))
		return Posicione("SA1", 1, xFilial("SA1")+oModel:GetValue('VC3_CODCLI')+oModel:GetValue('VC3_LOJA'), "A1_NREDUZ")
	elseif lValProsp .AND. !Empty(oModel:GetValue('VC3_CODPRO'))
		return Posicione("SUS", 1, xFilial("SUS")+oModel:GetValue('VC3_CODPRO')+oModel:GetValue('VC3_LOJPRO'), "US_NOME")
	endif
Return ""

/*/{Protheus.doc} VA1000044_ExistCliente
	Evento pos selecao de cliente ou prospect
	
	@type function
	@author Vinicius Gati
	@since 08/02/2019
/*/
function VA1000044_ExistCliente(oModel)
	local lRetorno

	if Empty(oModel:GetValue('VC3_CODCLI'))
		Return .t.
	endif

	lRetorno := ExistCpo("SA1", oModel:GetValue('VC3_CODCLI')+AllTrim(oModel:GetValue('VC3_LOJA')),NIL,NIL,.F.,.F.)
	if lRetorno .and. !empty(oModel:GetValue('VC3_LOJA')) .and. ! isBlind() .and. ;
		posicione("SA1",1,xFilial("SA1")+oModel:GetValue('VC3_CODCLI')+AllTrim(oModel:GetValue('VC3_LOJA')),"A1_MSBLQL") == "1"
		msgAlert(STR0006, STR0007)	// "Cadastro do cliente bloqueado, verifique!"		"Cliente bloqueado"
	endif

	if lRetorno .and. _lValProsp .and. (!(Empty(oModel:GetValue('VC3_CODPRO'))) .OR. !(Empty(oModel:GetValue('VC3_LOJPRO'))))
		oModel:LoadValue("VC3_CODPRO", "")
		oModel:LoadValue("VC3_LOJPRO", "")
	Endif
Return lRetorno


/*/{Protheus.doc} VA100006B_ExistProspect
	Evento pós seleção prospect
	
	@type function
	@author Alecsandre Ferreira
	@since 04/04/2022
/*/
function VA100006B_ExistProspect(oModel)
	Local lRetorno := .f.

	If _lValProsp .and. Empty(oModel:GetValue('VC3_CODPRO'))
		Return .t.
	endif

	If _lValProsp
		lRetorno := ExistCpo("SUS", oModel:GetValue('VC3_CODPRO')+AllTrim(oModel:GetValue('VC3_LOJPRO')))
	EndIf

	if _lValProsp .and. lRetorno .and. (!(Empty(oModel:GetValue('VC3_CODCLI'))) .OR. !(Empty(oModel:GetValue('VC3_LOJA'))))
		oModel:LoadValue("VC3_CODCLI", "")
		oModel:LoadValue("VC3_LOJA", "")
	Endif
	
Return lRetorno


/*/{Protheus.doc} VA100005B_ValidaProspect
	Valida os campos de Prospect(VC3_CODPRO e VC3_LOJPRO)
	
	@type function
	@author Alecsandre Ferreira
	@since 24/06/2022
/*/
Function VA100005B_ValidaProspect()
	If FieldPos("VC3_CODPRO") > 0 .AND. FieldPos("VC3_LOJPRO") > 0
		Return .T.
	Endif
Return .F.
