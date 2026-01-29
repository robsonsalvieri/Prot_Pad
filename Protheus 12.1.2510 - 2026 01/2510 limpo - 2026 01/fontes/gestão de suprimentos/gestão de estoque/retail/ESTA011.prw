#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ESTA011.CH"

PUBLISH MODEL REST NAME ESTA011 SOURCE ESTA011

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA011
Parâmetro para cálculo de Consumo e Indicadores

@type    Function
@author  Jesus Jorge
@since   15/10/2025
@version 12
/*/
//-------------------------------------------------------------------
Function ESTA011()
	Local oBrowse As Object

	Pergunte("ESTA011", .F.) // Carrega o pergunte para preencher os MV_PAR
	SetKey(VK_F12, {|| Pergunte("ESTA011", .T.)})

	aArea := GetArea()

	// Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("D4R")
	oBrowse:SetDescription(STR0007) // "Parâmetros para cálculo de Consumo e Indicadores"
	oBrowse:DisableDetails()

	// Ativa a Browse
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type    Function
@author  Jesus Jorge
@since   15/10/2025
@version 12

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
	aAdd(aRotina, {STR0002, "VIEWDEF.ESTA011", 0, 2, 0, NIL }) // "Visualizar"
	aAdd(aRotina, {STR0003, "E011Inclui()"   , 0, 3, 0, NIL }) // "Incluir"
	aAdd(aRotina, {STR0004, "VIEWDEF.ESTA011", 0, 4, 0, NIL }) // "Alterar"
	aAdd(aRotina, {STR0005, "VIEWDEF.ESTA011", 0, 5, 0, NIL }) // "Excluir"
	aAdd(aRotina, {STR0006, "VIEWDEF.ESTA011", 0, 8, 0, NIL }) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} E011Inclui
Determinar a acao

@author  Jorge Martins
@since   20/10/2025
@version 12
/*/
//-------------------------------------------------------------------
Function E011Inclui()
	Local oModel As Object

	oModel := FWLoadModel("ESTA011")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	E011LoadMd(@oModel) // Carga dos modelos de dados

	FWExecView(STR0007, "ESTA011", 3,, {||lRet := .T., lRet}, , , , , , , oModel) // "Parâmetros para cálculo de Consumo e Indicadores"

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Indicadores - Lote economico

@type    Function
@author  Jesus Jorge
@since   15/10/2025
@version 12

@return  oModel - Modelo de dados
@obs     D4RMASTER - Dados principais
         D4SDETAIL - Detalhe de tipos de materias
         D4TDETAIL - Detalhe de grupos de materias
         D4UDETAIL - Detalhe de peso de giro e consumo

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     As Object
	Local oStruD4R   As Object
	Local oStruD4S   As Object
	Local oStruD4T   As Object
	Local oStruD4U   As Object
	Local oEventMain As Object
	Local aRelD4S    As Array
	Local aRelD4T    As Array
	Local aRelD4U    As Array

	oEventMain := ESTA011EVDEF():New()

	oStruD4R   := FWFormStruct(1, "D4R")
	oStruD4S   := FWFormStruct(1, "D4S")
	oStruD4T   := FWFormStruct(1, "D4T")
	oStruD4U   := FWFormStruct(1, "D4U")

	oStruD4S:SetProperty("D4S_CTIPO" , MODEL_FIELD_OBRIGAT, .T.) // Define o campo D4S_CTIPO como obrigatório
	oStruD4T:SetProperty("D4T_CGRUPO", MODEL_FIELD_OBRIGAT, .T.) // Define o campo D4T_CGRUPO como obrigatório
	oStruD4U:SetProperty("D4U_TPIND" , MODEL_FIELD_OBRIGAT, .T.) // Define o campo D4U_TPIND como obrigatório

	// Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("ESTA011", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("D4RMASTER", /*cOwner*/, oStruD4R)
	oModel:AddGrid("D4SDETAIL", "D4RMASTER", oStruD4S, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
	oModel:AddGrid("D4TDETAIL", "D4RMASTER", oStruD4T, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)
	oModel:AddGrid("D4UDETAIL", "D4RMASTER", oStruD4U, /*bLinePre*/, /*bLinePost*/, /*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)

	oModel:GetModel("D4SDETAIL"):SetUniqueLine({"D4S_CTIPO"})  // Define o campo D4S_CTIPO como chave única do detalhe D4SDETAIL
	oModel:GetModel("D4TDETAIL"):SetUniqueLine({"D4T_CGRUPO"}) // Define o campo D4T_CGRUPO como chave única do detalhe D4TDETAIL
	oModel:GetModel("D4UDETAIL"):SetUniqueLine({"D4U_TPIND"})  // Define o campo D4U_TPIND como chave única do detalhe D4UDETAIL

	oModel:GetModel("D4UDETAIL"):SetNoDeleteLine(.T.) // Impede a exclusão de linhas no detalhe D4UDETAIL
	oModel:GetModel("D4UDETAIL"):SetMaxLine(2) // Define o número máximo de linhas do detalhe D4UDETAIL

	aRelD4S := {}
	aRelD4T := {}
	aRelD4U := {}

	// Fazendo o relacionamento (D4R e D4S)
	aAdd(aRelD4S, {"D4S_FILIAL", "FWxFilial('D4S')"} )
	aAdd(aRelD4S, {"D4S_CINDIC", "D4R_COD"})
	oModel:SetRelation("D4SDETAIL", aRelD4S, D4S->(IndexKey(1)))

	// Fazendo o relacionamento (D4R e D4T)
	aAdd(aRelD4T, {"D4T_FILIAL", "FWxFilial('D4T')"} )
	aAdd(aRelD4T, {"D4T_CINDIC", "D4R_COD"})
	oModel:SetRelation("D4TDETAIL", aRelD4T, D4T->(IndexKey(1)))

	// Fazendo o relacionamento (D4R e D4U)
	aAdd(aRelD4U, {"D4U_FILIAL", "FWxFilial('D4U')"} )
	aAdd(aRelD4U, {"D4U_CINDIC", "D4R_COD"})
	oModel:SetRelation("D4UDETAIL", aRelD4U, D4U->(IndexKey(1)))

	oModel:SetOptional("D4TDETAIL", .T. ) // Define o detalhe D4TDETAIL como opcional no modelo de dados

	oModel:InstallEvent('ESTA011EVDEF', /*cOwner*/, oEventMain)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Indicadores - Lote economico

@type    Function
@author  Jesus Jorge
@since   15/10/2025
@version 12

@return oView - View de dados
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView    As Object
	Local oModel   As Object
	Local oStruD4R As Object
	Local oStruD4S As Object
	Local oStruD4T As Object
	Local oStruD4U As Object
	
	oModel   := FWLoadModel("ESTA011")
	oStruD4R := FWFormStruct(2, "D4R")
	oStruD4S := FWFormStruct(2, "D4S")
	oStruD4T := FWFormStruct(2, "D4T")
	oStruD4U := FWFormStruct(2, "D4U")

	// Removendo campos de chave estrangeira que fazem parte do relacionamento
	oStruD4S:RemoveField("D4S_CINDIC")
	oStruD4T:RemoveField("D4T_CINDIC")
	oStruD4U:RemoveField("D4U_CINDIC")

	// Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)

	// Redefinindo os títulos dos campos para manter o padrão da tela antiga

	// Agrupador 001 - Gerais
	oStruD4R:SetProperty("D4R_ATUCON", MVC_VIEW_TITULO, STR0009) // "Consumo do Mês"
	oStruD4R:SetProperty("D4R_MOVINV", MVC_VIEW_TITULO, STR0010) // "Considerar movimentos de inventário?"
	oStruD4R:SetProperty("D4R_GRVABC", MVC_VIEW_TITULO, STR0027) // "Classificação ABC"

	oStruD4R:SetProperty("D4R_CALLEC", MVC_VIEW_TITULO, STR0014) // "Lote Econômico"
	oStruD4R:SetProperty("D4R_CALCPP", MVC_VIEW_TITULO, STR0015) // "Ponto de Pedido"

	oStruD4R:SetProperty("D4R_CALCES", MVC_VIEW_TITULO, STR0016) // "Estoque de Segurança"
	oStruD4R:SetProperty("D4R_TPSEGU", MVC_VIEW_TITULO, STR0018) // "Tipo (Média de consumo / Previsão de venda)"
	oStruD4R:SetProperty("D4R_MESSEG", MVC_VIEW_TITULO, STR0017) // "Meses"

	oStruD4R:SetProperty("D4R_AJUFIN", MVC_VIEW_TITULO, STR0019) // "Ajusta lote Econômico pela disponibilidade financeira"
	oStruD4R:SetProperty("D4R_VALFIN", MVC_VIEW_TITULO, STR0020) // "Valor da disponibilidade"

	// Agrupador 002 - Cálculo de média de consumo
	oStruD4R:SetProperty("D4R_TPCALC", MVC_VIEW_TITULO, STR0011) // "Método"
	oStruD4R:SetProperty("D4R_TPINCR", MVC_VIEW_TITULO, STR0012) // "Incremento"
	oStruD4R:SetProperty("D4R_NUMMES", MVC_VIEW_TITULO, STR0013) // "Número de Meses"
	oStruD4R:SetProperty("D4R_ZRMDNG", MVC_VIEW_TITULO, STR0046) // "Zera média negativa?"
	
	// Agrupador 003 - Faixas da classificação ABC
	oStruD4R:SetProperty("D4R_PERIOA", MVC_VIEW_TITULO, STR0021) // "Período de Aquisição (Meses)(A)"
	oStruD4R:SetProperty("D4R_PERIOB", MVC_VIEW_TITULO, STR0022) // "Período de Aquisição (Meses)(B)"
	oStruD4R:SetProperty("D4R_PERIOC", MVC_VIEW_TITULO, STR0023) // "Período de Aquisição (Meses)(C)"
	oStruD4R:SetProperty("D4R_PERCTA", MVC_VIEW_TITULO, STR0024) // "Distribuição Percentual (%) (A)"
	oStruD4R:SetProperty("D4R_PERCTB", MVC_VIEW_TITULO, STR0025) // "Distribuição Percentual (%) (B)"
	oStruD4R:SetProperty("D4R_PERCTC", MVC_VIEW_TITULO, STR0026) // "Distribuição Percentual (%) (C)"

	// Agrupador 004 - Filtros por armazem e produto
	oStruD4R:SetProperty("D4R_PRDSGP", MVC_VIEW_TITULO, STR0053) // "Analisa produtos sem grupo"

	oStruD4R:SetProperty("D4R_DESC"  , MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo D4R_DESC
	oStruD4R:SetProperty("D4R_CALCPP", MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo D4R_CALCPP
	oStruD4R:SetProperty("D4R_MESSEG", MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo D4R_MESSEG
	oStruD4R:SetProperty("D4R_PERIOC", MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo D4R_PERIOC
	oStruD4R:SetProperty("D4R_LOCATE", MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo D4R_LOCATE
	oStruD4R:SetProperty("D4R_PRDATE", MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo D4R_PRDATE	

	oStruD4U:SetProperty("D4U_TPIND",  MVC_VIEW_CANCHANGE, .F.) // Impede alteração do campo D4U_TPIND

	oView:AddField("VIEW_D4R", oStruD4R, "D4RMASTER")
	oView:AddGrid("VIEW_D4S",  oStruD4S, "D4SDETAIL")
	oView:AddGrid("VIEW_D4T",  oStruD4T, "D4TDETAIL")
	oView:AddGrid("VIEW_D4U",  oStruD4U, "D4UDETAIL")
	
	// Partes da tela
	oView:CreateHorizontalBox("CABEC_D4R", 45)
	oView:CreateHorizontalBox("GRID_MIDDLE", 30)
	oView:CreateVerticalBox("GRIDLEFT_D4S" , 50, "GRID_MIDDLE")
	oView:CreateVerticalBox("GRIDRIGHT_D4T", 50, "GRID_MIDDLE")
	oView:CreateHorizontalBox("BOTTOM_D4U", 25)
	
	oView:SetOwnerView("VIEW_D4R", "CABEC_D4R")
	oView:SetOwnerView("VIEW_D4S", "GRIDLEFT_D4S")
	oView:SetOwnerView("VIEW_D4T", "GRIDRIGHT_D4T")
	oView:SetOwnerView("VIEW_D4U", "BOTTOM_D4U")
	
	oView:EnableTitleView("VIEW_D4R", STR0028) // "Parametrização de cálculo"
	oView:EnableTitleView("VIEW_D4S", STR0029) // "Filtro por tipo de materiais"
	oView:EnableTitleView("VIEW_D4T", STR0030) // "Filtro por grupos de materiais"
	oView:EnableTitleView("VIEW_D4U", STR0031) // "Pesos para cálculo de giro e consumo"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA011EVDEF
Eventos padrão do cadastro de Parâmetros para cálculo de Consumo e Indicadores.

As regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    Class
@author  Jorge Martins
@since   20/10/2025
@version 12
 
/*/
//-------------------------------------------------------------------
CLASS ESTA011EVDEF From FWModelEvent
	DATA nOpc As Numeric

	METHOD New() CONSTRUCTOR

	METHOD ModelPosVld()
	METHOD E011VlCpos()
	METHOD E011DisPrc()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe ESTA010EVDEF

@type    Method
@author  Jorge Martins
@since   20/10/2025
@version 12
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class ESTA011EVDEF
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método de validação do modelo antes da gravação dos dados

@type    Method
@author  Jorge Martins
@since   20/10/2025
@version 12
@param   oModel - Modelo de dados de regras de dias de antecedência para vencimento
@param   cID    - Identificador do modelo
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel, cID) CLASS ESTA011EVDEF
	Local lValid As Logical

	lValid := .T.

	::nOpc := oModel:GetOperation()
	
	If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
		If lValid
			lValid := ::E011VlCpos(oModel) // Valida se os valores dos campos estão corretos
		EndIf
		If lValid
			lValid := ::E011DisPrc(oModel) // Valida se a distribuição percentual é igual a 100%
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E011VlCpos
Método de validação dos valores dos campos

@type    Method
@author  Jorge Martins
@since   20/10/2025
@version 12
@param   oModel - Modelo de dados de parâmetros para cálculo de Consumo e Indicadores
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD E011VlCpos(oModel) CLASS ESTA011EVDEF
	Local lValid    As Logical
	Local cProblema As Character
	Local cSolucao  As Character
	Local cRotina   As Character

	lValid  := .T.
	cRotina := ProcName(0) // Nome da rotina onde ocorreu o erro
	
	If oModel:GetValue("D4RMASTER", "D4R_CALCES") // Se cálculo do estoque de segurança estiver marcado
		If Empty(oModel:GetValue("D4RMASTER", "D4R_TPSEGU"))
			lValid    := .F.
			cProblema := STR0038 // "O tipo para cálculo do estoque de segurança não foi informado."
			cSolucao  := STR0039 // "Informe o tipo para cálculo do estoque de segurança."
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		ElseIf oModel:GetValue("D4RMASTER", "D4R_MESSEG") == 0
			lValid    := .F.
			cProblema := STR0040 // "O número de meses para cálculo do estoque de segurança não foi informado."
			cSolucao  := STR0041 // "Informe o número de meses para cálculo do estoque de segurança."
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf
	EndIf

	If lValid .And. oModel:GetValue("D4RMASTER", "D4R_TPCALC") == "2" // Se o método de cálculo for pela tendência
		If oModel:GetValue("D4RMASTER", "D4R_NUMMES") == 0
			lValid    := .F.
			cProblema := STR0042 // "O número de meses para cálculo pela tendência não foi informado."
			cSolucao  := STR0043 // "Informe o número de meses para cálculo pela tendência."
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf
	EndIf

	If lValid .And. oModel:GetValue("D4RMASTER", "D4R_AJUFIN") // Se ajustar lote econômico pela disponibilidade financeira
		If oModel:GetValue("D4RMASTER", "D4R_VALFIN") == 0
			lValid    := .F.
			cProblema := STR0044 // "O valor da disponibilidade financeira não foi informado."
			cSolucao  := STR0045 // "Informe o valor da disponibilidade financeira."
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E011DisPrc
Método de validação de distribuição percentual ser igual a 100%

@type    Method
@author  Jorge Martins
@since   20/10/2025
@version 12
@param   oModel - Modelo de dados de parâmetros para cálculo de Consumo e Indicadores
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD E011DisPrc(oModel) CLASS ESTA011EVDEF
	Local lValid    As Logical
	Local cProblema As Character
	Local cSolucao  As Character
	Local cRotina   As Character

	lValid := .T.
	
	If oModel:GetValue("D4RMASTER", "D4R_PERCTA") + ;
	   oModel:GetValue("D4RMASTER", "D4R_PERCTB") + ;
	   oModel:GetValue("D4RMASTER", "D4R_PERCTC") <> 100
		lValid    := .F.
		cProblema := STR0032 // "A distribuição percentual da classificação ABC não soma 100%"
		cSolucao  := STR0033 // "Certifique-se que a soma dos três percentuais seja 100%."
		cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
		Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} E011Carga
Indica se o sistema deve carregar os tipos e grupos de materiais na 
inclusão de um novo indicador, conforme o parâmetro MV_PAR01 do pergunte ESTA011.

@type    Function
@author  Jorge Martins
@since   16/10/2025
@version 12
@return  lCarga - .T. - Carrega os tipos e grupos de materiais
                  .F. - Não carrega
/*/
//-------------------------------------------------------------------
Static Function E011Carga()
	Local lCarga As Logical

	lCarga := MV_PAR01 == 1 // Sim

Return lCarga

//-------------------------------------------------------------------
/*/{Protheus.doc} E011LoadMd
Rotina de carga dos campos dos modelos de dados

@type    Function
@author  Jorge Martins
@since   16/10/2025
@version 12
@param   oModel - Objeto do modelo
@param   lCarga - Indica se deve carregar os tipos e grupos de materiais 
                  (usado via automação - ADVPR)
/*/
//-------------------------------------------------------------------
Function E011LoadMd(oModel, lCarga)

	Default lCarga := E011Carga() // Carga dos tipos e grupos de materiais somente se o parametro do pergunte estiver habilitado

	E011LdD4R(@oModel) // Carga do modelo principal
	
	If lCarga // Carga dos tipos e grupos de materiais somente se o parametro do pergunte estiver habilitado
		E011LdD4S(@oModel) // Carga dos tipos de materiais
		E011LdD4T(@oModel) // Carga dos grupos de materiais
	EndIf
	
	E011LdD4U(@oModel) // Carga do peso de giro e consumo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E011LdD4R
Rotina de carga do modelo principal

@type    Function
@author  Jorge Martins
@since   16/10/2025
@version 12
@param   oModel - Objeto do modelo
/*/
//-------------------------------------------------------------------
Static Function E011LdD4R(oModel)

	oModel:SetValue("D4RMASTER", "D4R_GRVABC", .T.)
	oModel:SetValue("D4RMASTER", "D4R_PERIOA", 1)
	oModel:SetValue("D4RMASTER", "D4R_PERIOB", 1)
	oModel:SetValue("D4RMASTER", "D4R_PERIOC", 1)
	oModel:SetValue("D4RMASTER", "D4R_PERCTA", 30)
	oModel:SetValue("D4RMASTER", "D4R_PERCTB", 30)
	oModel:SetValue("D4RMASTER", "D4R_PERCTC", 40)
	oModel:SetValue("D4RMASTER", "D4R_LOCATE", PadR( , TamSx3("D4R_LOCATE")[1], "Z"))
	oModel:SetValue("D4RMASTER", "D4R_PRDATE", PadR( , TamSx3("D4R_PRDATE")[1], "Z"))

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E011LdD4S
Rotina de carga do grid de tipo de materiais

@type    Function
@author  Jorge Martins
@since   16/10/2025
@version 12
@param   oModel - Objeto do modelo
/*/
//-------------------------------------------------------------------
Static Function E011LdD4S(oModel)
	Local aRetSX5 As Array
	Local cCod    As Character
	Local nQtdSX5 As Numeric
	Local nLenSX5 As Numeric

	aRetSX5 := FWGetSX5("02")
	nLenSX5 := Len(aRetSX5)

	For nQtdSX5 := 1 To nLenSX5
		cCod  := aRetSX5[nQtdSX5, 3]
		oModel:SetValue("D4SDETAIL", "D4S_CTIPO", cCod)
		If nQtdSX5 <> nLenSX5
			oModel:GetModel("D4SDETAIL"):AddLine()
		EndIf
	Next

	oModel:GetModel("D4SDETAIL"):GoLine(1)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E011LdD4T
Rotina de carga do grid de grupo de materiais

@type    Function
@author  Jorge Martins
@since   16/10/2025
@version 12
@param   oModel - Objeto do modelo
/*/
//-------------------------------------------------------------------
Static Function E011LdD4T(oModel)
	Local cQuery    As Character
	Local cCod      As Character
	Local cAliasGrp As Character
	Local nParam    As Numeric
	Local oGrupo    As Object
	Local lAddLine  As Logical

	lAddLine  := .F. // Controla a inclusão de linhas no grid
	nParam    := 1
	cAliasGrp := GetNextAlias()

	cQuery := "SELECT SBM.BM_GRUPO"
	cQuery +=  " FROM " + RetSqlName("SBM") + " SBM"
	cQuery += " WHERE SBM.BM_FILIAL = ?"  // #1
	cQuery +=   " AND SBM.D_E_L_E_T_ = ?" // #2

	oGrupo := FwExecStatement():New(cQuery)

	oGrupo:SetString(nParam++, FWxFilial("SBM")) // #1
	oGrupo:SetString(nParam++, Space(1))         // #2

	oGrupo:OpenAlias(cAliasGrp)

	While !(cAliasGrp)->(EOF())
		cCod := (cAliasGrp)->BM_GRUPO
		If lAddline // Na primeira vez não adiciona linha
			oModel:GetModel("D4TDETAIL"):AddLine()
		Else
			lAddLine := .T.
		EndIf
		oModel:SetValue("D4TDETAIL", "D4T_CGRUPO", cCod)

		(cAliasGrp)->(DbSkip())
	EndDo

	(cAliasGrp)->(DBCloseArea())

	oModel:GetModel("D4TDETAIL"):GoLine(1)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E011LdD4U
Rotina de carga do grid de peso de giro e consumo

@type    Function
@author  Jorge Martins
@since   16/10/2025
@version 12
@param   oModel - Objeto do modelo
/*/
//-------------------------------------------------------------------
Static Function E011LdD4U(oModel)
	Local nTipo  As Numeric
	Local nMes   As Numeric
	Local cPesos As Character
	Local aPesos As Array

	aPesos := Array(12)
	cPesos := GetMv("MV_PESOS")
	cPesos := SubStr(cPesos, 1, 12)
	cPesos := cPesos + Space(12 - Len(cPesos))

	For nMes := 1 To 12
		aPesos[nMes] := Val(SubStr(cPesos, nMes, 1))
	Next nMes
	
	For nTipo := 1 To 2 // Inclui as linhas dos tipos 1 - Peso de giro e 2 - Peso de consumo
		oModel:SetValue("D4UDETAIL", "D4U_TPIND", Transform(nTipo, "@9"))
		oModel:SetValue("D4UDETAIL", "D4U_MES01", aPesos[01])
		oModel:SetValue("D4UDETAIL", "D4U_MES02", aPesos[02])
		oModel:SetValue("D4UDETAIL", "D4U_MES03", aPesos[03])
		oModel:SetValue("D4UDETAIL", "D4U_MES04", aPesos[04])
		oModel:SetValue("D4UDETAIL", "D4U_MES05", aPesos[05])
		oModel:SetValue("D4UDETAIL", "D4U_MES06", aPesos[06])
		oModel:SetValue("D4UDETAIL", "D4U_MES07", aPesos[07])
		oModel:SetValue("D4UDETAIL", "D4U_MES08", aPesos[08])
		oModel:SetValue("D4UDETAIL", "D4U_MES09", aPesos[09])
		oModel:SetValue("D4UDETAIL", "D4U_MES10", aPesos[10])
		oModel:SetValue("D4UDETAIL", "D4U_MES11", aPesos[11])
		oModel:SetValue("D4UDETAIL", "D4U_MES12", aPesos[12])
		If nTipo <> 2
			oModel:GetModel("D4UDETAIL"):AddLine()
		EndIf
	Next

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} E011VldVal
Rotina de validação dos campos

@Obs: Função utilizada no X3_VALID dos campos da tabela D4R

@type    Function
@author  Jorge Martins
@since   20/10/2025
@version 12
@param   cField - Campo a ser validado
@param   xValue - Conteúdo do campo
/*/
//-------------------------------------------------------------------
Function E011VldVal(cField, xValue)
	Local lValid    As Logical
	Local cProblema As Character
	Local cSolucao  As Character
	Local cRotina   As Character
	Local cVarZZZ   As Character

	lValid := .T.

	// Campos que não podem ser negativos ou zero
	If cField $ "D4R_PERIOA|D4R_PERIOB|D4R_PERIOC|D4R_PERCTA|D4R_PERCTB|D4R_PERCTC|D4R_VALFIN"
		If xValue <= 0
			lValid    := .F.
			cProblema := STR0034 // "O valor não pode ser negativo ou zero."
			cSolucao  := STR0035 // "Informe um valor maior que zero."
			cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf
	
	// Campos que não podem ser negativos, zero ou maior que 12
	ElseIf cField $ "D4R_MESSEG|D4R_NUMMES"
		If xValue < 1 .Or. xValue > 12
			lValid    := .F.
			cProblema := STR0036 // "O número de meses deve estar entre 1 e 12 meses."
			cSolucao  := STR0037 // "Informe um valor válido."
			cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf
	
	// Campos de local de estoque (armazém) que devem existir na tabela correspondente
	ElseIf cField $ "D4R_LOCDE|D4R_LOCATE"
		If cField == "D4R_LOCDE" .And. !Empty(xValue) .And. !ExistCpo("NNR", xValue)
			lValid    := .F.
			cProblema := STR0047 // "O código de local de estoque (armazém) informado não existe."
			cSolucao  := STR0048 // "Informe um código de local de estoque (armazém) válido ou deixe o campo sem conteúdo."
			cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf

		If cField == "D4R_LOCATE" .And. !Empty(xValue)
			cVarZZZ := PadR( , TamSx3("D4R_LOCATE")[1], "Z")
			If xValue <> cVarZZZ .And. !ExistCpo("NNR", xValue)
				lValid    := .F.
				cProblema := STR0047 // "O código de local de estoque (armazém) informado não existe."
				cSolucao  := I18n(STR0049, {cVarZZZ}) // "Informe um código de local de estoque (armazém) válido ou preencha com o valor '#1'."
				cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
				Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
			EndIf
		EndIf

	// Campos de produto devem existir na tabela correspondente
	ElseIf cField $ "D4R_PRDDE|D4R_PRDATE"
		If cField == "D4R_PRDDE" .And. !Empty(xValue) .And. !ExistCpo("SB1", xValue)
			lValid    := .F.
			cProblema := STR0050 // "O código de produto informado não existe."
			cSolucao  := STR0051 // "Informe um código de produto válido ou deixe o campo sem conteúdo."
			cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf

		If cField == "D4R_PRDATE" .And. !Empty(xValue)
			cVarZZZ := PadR( , TamSx3("D4R_PRDATE")[1], "Z")
			If xValue <> cVarZZZ .And. !ExistCpo("SB1", xValue)
				lValid    := .F.
				cProblema := STR0050 // "O código de produto informado não existe."
				cSolucao  := I18n(STR0052, {cVarZZZ}) // "Informe um código de produto válido ou preencha com o valor '#1'."
				cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
				Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
			EndIf
		EndIf
	EndIf

Return lValid
