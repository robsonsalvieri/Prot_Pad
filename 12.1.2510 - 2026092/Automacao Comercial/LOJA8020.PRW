#include "totvs.ch"
#Include 'FWMVCDef.ch'
#Include 'LOJA8020.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA8020
Tela MVC classica (CRUD padrao) do cadastro de Precificação Psicológica (MGG).

@type   function
@author cruz.rafael | Squad Retail Backoffice
@since  06/08/2026
/*/
//-------------------------------------------------------------------
Function LOJA8020()
	Local oBrowse As Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("MGG")
	oBrowse:SetDescription(STR0001) // "Precificação Psicológica"
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados MVC do cadastro de Precificação Psicológica (MGG).

Estrutura carregada integralmente do dicionario (FWFormStruct) -

@type   function
@author cruz.rafael | Squad Retail Backoffice
@since  06/08/2026
@return object, instancia de MPFormModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     As Object
	Local oStruct    As Object
	Local oEventMain As Object

	oEventMain := LOJA8020EVDEF():New()

	oStruct := FWFormStruct(1, "MGG")

	oModel := MPFormModel():New("LOJA8020M")
	oModel:AddFields("MGGMASTER", /*cOwner*/, oStruct)
	oModel:SetDescription(STR0001) // "Precificação Psicológica"
	oModel:SetPrimaryKey({})
	oModel:GetModel("MGGMASTER"):SetDescription(STR0002) // "Dados da Precificação Psicológica"

	oModel:InstallEvent('LOJA8020EVDEF', /*cOwner*/, oEventMain)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Layout visual MVC do cadastro de Precificação Psicológica (MGG).

@type   function
@author cruz.rafael | Squad Retail Backoffice
@since  06/08/2026
@return object, instancia de FWFormView
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView   As Object
	Local oModel  As Object
	Local oStruct As Object

	oModel := FWLoadModel("LOJA8020")

	oStruct := FWFormStruct(2, "MGG")

	oStruct:SetProperty("MGG_ATE", MVC_VIEW_INSERTLINE, .T.)
	oStruct:SetProperty("MGG_DIGINT", MVC_VIEW_INSERTLINE, .T.)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_MGG", oStruct, "MGGMASTER")
	oView:CreateHorizontalBox("BOXMGG", 100)
	oView:SetOwnerView("VIEW_MGG", "BOXMGG")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Acoes de menu padrao do cadastro MVC de Precificação Psicológica (MGG):
Incluir, Alterar, Excluir, Visualizar e Copiar.

@type   function
@author cruz.rafael | Squad Retail Backoffice
@since  06/08/2026
@return array, itens de menu da rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aMenu As Array

	aMenu := {}

	aAdd(aMenu, {STR0003, "PesqBrw"         , 0, 1, 0, NIL}) // "Pesquisar"
	aAdd(aMenu, {STR0004, "VIEWDEF.LOJA8020", 0, 2, 0, Nil}) // "Visualizar"
	aAdd(aMenu, {STR0005, "VIEWDEF.LOJA8020", 0, 3, 0, Nil}) // "Incluir"
	aAdd(aMenu, {STR0006, "VIEWDEF.LOJA8020", 0, 4, 0, Nil}) // "Alterar"
	aAdd(aMenu, {STR0007, "VIEWDEF.LOJA8020", 0, 5, 0, Nil}) // "Excluir"
	aAdd(aMenu, {STR0008, "VIEWDEF.LOJA8020", 0, 9, 0, Nil}) // "Copiar"

Return aMenu


//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA8020EVDEF
Eventos padrão do cadastro de Precificação Psicológica (MGG)

As regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type   Class
@author cruz.rafael | Squad Retail Backoffice
@since  06/08/2026
/*/
//-------------------------------------------------------------------
CLASS LOJA8020EVDEF From FWModelEvent
	DATA nOpc As Numeric

	METHOD New() CONSTRUCTOR

	METHOD ModelPosVld()
	METHOD LJ8020VldDup()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe ESTA010EVDEF

@type   Method
@author cruz.rafael | Squad Retail Backoffice
@since  06/08/2026
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class LOJA8020EVDEF
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método de validação do modelo antes da gravação dos dados

@type   Method
@author cruz.rafael | Squad Retail Backoffice
@since  06/08/2026
@param  oModel - Modelo de dados de Precificação Psicológica
@return lValid - .T. se os dados estão válidos e podem ser gravados
/*/
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel) CLASS LOJA8020EVDEF
	Local lValid As Logical

	Default oModel := NIL

	lValid := .T.
	
	If oModel <> NIL .AND. (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
		If lValid
			lValid := ::LJ8020VldDup(oModel) // Valida se existe duplicidade
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ8020VldDup
Método de validação de duplicidade de Faixas de Valores

@type    Method
@author  cruz.rafael | Squad Retail Backoffice
@since   06/08/2026
@param   oModel - Modelo de dados de Prefixação Psicológica (MGG)
@return  lValid - .T. se os dados estão válidos e sem duplicidade
/*/
//-------------------------------------------------------------------
METHOD LJ8020VldDup(oModel) CLASS LOJA8020EVDEF
Local lValid     As Logical
Local cQuery     As Character
Local cAliasDup  As Character
Local cProblema  As Character
Local cSolucao   As Character
Local cRotina    As Character
Local nValDe     As Numeric
Local nValAte    As Numeric
Local oDup       As Object
Local oModelMGG  As Object
Local nParam     As Numeric

Default oModel := NIL

	If oModel <> NIL

		lValid    := .T.
		nParam    := 1
		oModelMGG := oModel:GetModel("MGGMASTER")
		nValDe    := oModelMGG:GetValue("MGG_DE")
		nValAte   := oModelMGG:GetValue("MGG_ATE")

		cQuery :=   "SELECT COUNT(*) AS QTD"
		cQuery +=    " FROM " + RetSqlName("MGG") + " MGG"
		cQuery +=   " WHERE MGG.MGG_FILIAL = ?"
		cQuery +=     " AND MGG.MGG_DE <= ? AND MGG.MGG_ATE >= ?"
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE
			cQuery += " AND MGG.R_E_C_N_O_ <> ?"
		EndIf
		cQuery +=     " AND MGG.D_E_L_E_T_ = ?"

		oDup := FWExecStatement():New(cQuery)

		oDup:SetString(nParam++, FWxFilial("MGG"))
		oDup:SetNumeric(nParam++, nValAte)
		oDup:SetNumeric(nParam++, nValDe)
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE
			oDup:SetNumeric(nParam++, MGG->(RECNO()))
		EndIf
		oDup:SetString(nParam++, Space(1))

		cAliasDup := GetNextAlias()
		oDup:OpenAlias(cAliasDup)

		If (cAliasDup)->QTD > 0
			lValid    := .F.
			cProblema := STR0009 // "Já existe faixa de valores neste intervalo."
			cSolucao  := STR0010 // "Ajuste o intervalo de valores para não haver sobreposição."
			cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf

		(cAliasDup)->(DBCloseArea())
		oDup:Destroy()
		oDup := nil 
	EndIf
Return lValid
