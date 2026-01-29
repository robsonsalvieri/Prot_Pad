#INCLUDE "ESTA010.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

PUBLISH MODEL REST NAME ESTA010 SOURCE ESTA010

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA010
Regras de dias de antecedência para vencimento

@type    Function
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Function ESTA010()
Local oBrowse As Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0007) // "Regras de dias de antecedência para vencimento"
	oBrowse:SetAlias("D4Q")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type    Function
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610

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

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina As Array

	aRotina := {}

	aAdd(aRotina, {STR0001, "PesqBrw"        , 0, 1, 0, .T. }) // "Pesquisar"
	aAdd(aRotina, {STR0002, "VIEWDEF.ESTA010", 0, 2, 0, NIL }) // "Visualizar"
	aAdd(aRotina, {STR0003, "VIEWDEF.ESTA010", 0, 3, 0, NIL }) // "Incluir"
	aAdd(aRotina, {STR0004, "VIEWDEF.ESTA010", 0, 4, 0, NIL }) // "Alterar"
	aAdd(aRotina, {STR0005, "VIEWDEF.ESTA010", 0, 5, 0, NIL }) // "Excluir"
	aAdd(aRotina, {STR0006, "VIEWDEF.ESTA010", 0, 8, 0, NIL }) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Regras de dias de antecedência para vencimento

@type    Function
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610

@return oView - View de dados
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView   As Object
Local oModel  As Object
Local oStruct As Object

	oModel  := FWLoadModel("ESTA010")
	oStruct := FWFormStruct(2, "D4Q")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("ESTA010_VIEW", oStruct, "D4QMASTER")
	oView:CreateHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView("ESTA010_VIEW", "FORMFIELD")
	oView:SetDescription(STR0007) // "Regras de dias de antecedência para vencimento"
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Regras de dias de antecedência para vencimento

@type    Function
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610
@return  oModel - Modelo de dados
@obs     D4QMASTER - Dados do Regras de dias de antecedência para vencimento

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     as Object
Local oStructD4Q as Object
Local oEventMain as Object

	oStructD4Q := FWFormStruct(1, "D4Q")
	oEventMain := ESTA010EVDEF():New()

	// Monta o modelo do formulário
	oModel:= MPFormModel():New("ESTA010", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields("D4QMASTER", NIL, oStructD4Q, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription(STR0008) // "Modelo de Dados de Regras de dias de antecedência para vencimento"
	oModel:GetModel("D4QMASTER"):SetDescription(STR0009) // "Dados de Regras de dias de antecedência para vencimento"
	oModel:InstallEvent('ESTA010EVDEF', /*cOwner*/, oEventMain)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA010EVDEF
Eventos padrão do cadastro de Regras de dias de antecedência para vencimento.

As regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    Class
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610
 
/*/
//-------------------------------------------------------------------
CLASS ESTA010EVDEF From FWModelEvent
	DATA nOpc        As Numeric
	DATA lFWCodFil   As Logical
	DATA lHistFiscal As Logical

	METHOD New() CONSTRUCTOR

	METHOD ModelPosVld()
	METHOD E010VldDup()
	METHOD E010DiasZr()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe ESTA010EVDEF

@type    Method
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class ESTA010EVDEF
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método de validação do modelo antes da gravação dos dados

@type    Method
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610
@param   oModel - Modelo de dados de regras de dias de antecedência para vencimento
@param   cID    - Identificador do modelo
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cID) CLASS ESTA010EVDEF
Local lValid As Logical

	lValid := .T.

	::nOpc := oModel:GetOperation()
	
	If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
		If lValid
			lValid := ::E010DiasZr(oModel) // Valida se o campo dias é diferente de zero
		EndIf

		If lValid
			lValid := ::E010VldDup(oModel) // Valida se existe duplicidade
		EndIf

	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E010VldDup
Método de validação de duplicidade de registros

@type    Method
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610
@param   oModel - Modelo de dados de regras de dias de antecedência para vencimento
@return  lValid - .T. se os dados estão válidos e sem duplicidade

/*/
//-------------------------------------------------------------------
METHOD E010VldDup(oModel) CLASS ESTA010EVDEF
Local lValid    As Logical
Local cQuery    As Character
Local cAliasDup As Character
Local cProblema As Character
Local cSolucao  As Character
Local cRotina   As Character
Local oDup      As Object
Local oModelD4Q As Object
Local nParam    As Numeric

	lValid    := .T.
	nParam    := 1
	cAliasDup := GetNextAlias()
	oModelD4Q := oModel:GetModel("D4QMASTER")

	cQuery :=   "SELECT COUNT(1) AS QTDE"
	cQuery +=    " FROM " + RetSqlName("D4Q") + " D4Q"
	cQuery +=   " WHERE D4Q.D4Q_FILIAL = ?"
	cQuery +=     " AND D4Q.D4Q_CPROD  = ?"
	cQuery +=     " AND D4Q.D4Q_CTIPO  = ?"
	cQuery +=     " AND D4Q.D4Q_CCATEG = ?"
	cQuery +=     " AND D4Q.D4Q_CGRUPO = ?"

	If ::nOpc == MODEL_OPERATION_UPDATE
		cQuery += " AND D4Q.D4Q_COD <> ?"
	EndIf
	cQuery +=     " AND D4Q.D_E_L_E_T_ = ' '"

	oDup := FwExecStatement():New(cQuery)

	oDup:SetString(nParam++, FWxFilial("D4Q"))
	oDup:SetString(nParam++, oModelD4Q:GetValue("D4Q_CPROD"))
	oDup:SetString(nParam++, oModelD4Q:GetValue("D4Q_CTIPO"))
	oDup:SetString(nParam++, oModelD4Q:GetValue("D4Q_CCATEG"))
	oDup:SetString(nParam++, oModelD4Q:GetValue("D4Q_CGRUPO"))
	If ::nOpc == MODEL_OPERATION_UPDATE
		oDup:SetString(nParam++, oModelD4Q:GetValue("D4Q_COD"))
	EndIf

	oDup:OpenAlias(cAliasDup)

	If !(cAliasDup)->(EOF()) .And. (cAliasDup)->QTDE > 0 // Se existir regra com os mesmos parâmetros informa o erro
		lValid    := .F.
		cProblema := STR0010 // "Já existe uma regra cadastrada com os mesmos parâmetros."
		cSolucao  := STR0011 // "Verifique os dados informados e tente novamente."
		cRotina   := ProcName(1) // Nome da rotina onde ocorreu o erro
		Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
	EndIf

	(cAliasDup)->(DBCloseArea())

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E010DiasZr
Método de validação de quantidade de dias igual a zero

@type    Method
@author  Jorge Martins
@since   03/10/2025
@version 12.1.2610
@param   oModel - Modelo de dados de regras de dias de antecedência para vencimento
@return  lValid - .T. se os dados estão válidos e dias não estão zerados

/*/
//-------------------------------------------------------------------
METHOD E010DiasZr(oModel) CLASS ESTA010EVDEF
Local lValid    As Logical
Local cProblema As Character
Local cSolucao  As Character
Local cRotina   As Character

	lValid    := .T.
	
	If oModel:GetValue("D4QMASTER", "D4Q_DIAS") == 0 // Valida se o campo dias é diferente de zero
		lValid    := .F.
		cProblema := STR0012 // "Não é permitido cadastrar um regra com 0 dias."
		cSolucao  := STR0013 // "Verifique a quantidade de dias informada."
		cRotina   := ProcName(1) // Nome da rotina onde ocorreu o erro
		Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
	EndIf

Return lValid
