#INCLUDE "FATA141.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static __aPrepared := {} As Array

PUBLISH MODEL REST NAME FATA141 SOURCE FATA141

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA141
Categorias x Características de Produtos

@type    Function
@author  Jorge Martins
@since   25/11/2025
@version 12
/*/
//-------------------------------------------------------------------
Function FATA141()
Local oBrowse   As Object
Local cProblema As Character
Local cSolucao  As Character
Local cRotina   As Character

	If !AliasInDic("AQU") .Or. !AliasInDic("D4V")
		cProblema := STR0010 // "Ambiente desatualizado."
		cSolucao  := I18n(STR0011, {"01/03/2026"}) // "Necessário aplicar o pacote de expedição contínua backoffice com data igual ou superior à #1."
		cRotina   := ProcName(0) // Nome da rotina onde ocorreu o erro
		Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
	Else
		oBrowse := FWMBrowse():New()
		oBrowse:SetDescription(STR0007) // "Categorias x Características de Produtos"
		oBrowse:SetAlias("AQU")
		oBrowse:SetLocate()
		oBrowse:Activate()
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type    Function
@author  Jorge Martins
@since   25/11/2025
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
	aAdd(aRotina, {STR0002, "VIEWDEF.FATA141", 0, 2, 0, NIL }) // "Visualizar"
	aAdd(aRotina, {STR0003, "VIEWDEF.FATA141", 0, 3, 0, NIL }) // "Incluir"
	aAdd(aRotina, {STR0004, "VIEWDEF.FATA141", 0, 4, 0, NIL }) // "Alterar"
	aAdd(aRotina, {STR0005, "VIEWDEF.FATA141", 0, 5, 0, NIL }) // "Excluir"
	aAdd(aRotina, {STR0006, "VIEWDEF.FATA141", 0, 8, 0, NIL }) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Categorias x Características de Produtos

@type    Function
@author  Jorge Martins
@since   25/11/2025
@version 12

@return oView - View de dados
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView   As Object
Local oModel  As Object
Local oStruct As Object

	oModel  := FWLoadModel("FATA141")
	oStruct := FWFormStruct(2, "AQU")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oStruct:SetProperty("AQU_DCATEG", MVC_VIEW_INSERTLINE, .T.) // Faz uma quebra de linha após o campo Descrição da categoria
	
	oStruct:SetProperty("AQU_DCATEG", MVC_VIEW_TITULO, STR0017) // "Descrição da categoria"
	oStruct:SetProperty("AQU_DCARAC", MVC_VIEW_TITULO, STR0018) // "Descrição da característica"
	
	oView:AddField("FATA141_VIEW", oStruct, "AQUMASTER")
	oView:CreateHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView("FATA141_VIEW", "FORMFIELD")
	oView:SetDescription(STR0007) // "Categorias x Características de Produtos"
	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Categorias x Características de Produtos

@type    Function
@author  Jorge Martins
@since   25/11/2025
@version 12

@return  oModel - Modelo de dados
@obs     AQUMASTER - Dados do Categorias x Características de Produtos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     as Object
Local oStructAQU as Object
Local oEventMain as Object

	oStructAQU := FWFormStruct(1, "AQU")
	oEventMain := FATA141EVDEF():New()

	oStructAQU:SetProperty("AQU_CARAC" , MODEL_FIELD_OBRIGAT, .T.) // Define o campo Valor como obrigatório

	// Monta o modelo do formulário
	oModel:= MPFormModel():New("FATA141", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields("AQUMASTER", NIL, oStructAQU, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription(STR0008) // "Modelo de Dados de Categorias x Características de Produtos"
	oModel:GetModel("AQUMASTER"):SetDescription(STR0009) // "Dados de Categorias x Características de Produtos"
	oModel:InstallEvent('FATA141EVDEF', /*cOwner*/, oEventMain)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA141EVDEF
Eventos padrão do cadastro de Categorias x Características de Produtos.

As regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    Class
@author  Jorge Martins
@since   25/11/2025
@version 12
 
/*/
//-------------------------------------------------------------------
CLASS FATA141EVDEF From FWModelEvent
	DATA nOpc        As Numeric

	METHOD new() CONSTRUCTOR
	METHOD modelPosVld()
	METHOD fa141VldDup() // Valida duplicidade de registros
	METHOD fa141VldCat() // Valida se a característica já está vinculada nas categorias filhas ou superiores
	METHOD fa141InD4X() // Inclui o vínculo do produto com as características da categoria na tabela D4X
	METHOD fa141ExD4X() // Exclui o vínculo do produto com as características da categoria na tabela D4X
	METHOD fa141PrCat() // Busca os produtos da categoria

ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} new
Método construtor da classe FATA141EVDEF

@type    Method
@author  Jorge Martins
@since   25/11/2025
@version 12
/*/
//-------------------------------------------------------------------------------------------------------------
Method new() Class FATA141EVDEF
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} modelPosVld
Método de validação do modelo antes da gravação dos dados

@type    Method
@author  Jorge Martins
@since   25/11/2025
@version 12

@param   oModel - Modelo de dados de Categorias x Características de Produtos
@param   cID    - Identificador do modelo
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD modelPosVld(oModel, cID) CLASS FATA141EVDEF
Local lValid As Logical

Default oModel := Nil
Default cID    := ""

	lValid := .T.

	If oModel <> Nil
		::nOpc := oModel:GetOperation()
		
		If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
			If lValid
				lValid := ::FA141VldDup(oModel, ::nOpc == MODEL_OPERATION_UPDATE) // Valida se existe duplicidade
			EndIf

			If lValid
				lValid := ::FA141VldCat(oModel, ::nOpc == MODEL_OPERATION_UPDATE) // Valida se a característica já está vinculada em categorias filhas ou superiores
			EndIf

			If lValid .And. ::nOpc == MODEL_OPERATION_INSERT
				lValid := ::fa141InD4X(oModel) // Inclui o vínculo do produto com as características da categoria na tabela D4X
			EndIf
		EndIf

		If lValid  .And. ::nOpc == MODEL_OPERATION_DELETE
			lValid := ::fa141ExD4X(oModel) // Exclui o vínculo do produto com as características da categoria na tabela D4X para os vínculos antigos, somente para alteração
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} fa141VldDup
Método de validação de duplicidade de registros

@type    Method
@author  Jorge Martins
@since   25/11/2025
@version 12

@param   oModel     - Modelo de dados de Categorias x Características de Produtos
@param   lAlteracao - Indica se a operação é de alteração
@return  lValid     - .T. se os dados estão válidos e sem duplicidade

/*/
//-------------------------------------------------------------------
METHOD fa141VldDup(oModel, lAlteracao) CLASS FATA141EVDEF
Local lValid    As Logical
Local cQuery    As Character
Local cAliasDup As Character
Local cProblema As Character
Local cSolucao  As Character
Local cRotina   As Character
Local oDup      As Object
Local oModelAQU As Object
Local nParam    As Numeric

Default oModel     := Nil
Default lAlteracao := .F.

	lValid := .T.

	If oModel <> Nil

		nParam    := 1
		cAliasDup := GetNextAlias()
		oModelAQU := oModel:GetModel("AQUMASTER")

		cQuery :=   "SELECT COUNT(1) QTDE"
		cQuery +=    " FROM " + RetSqlName("AQU") + " AQU"
		cQuery +=   " WHERE AQU.AQU_FILIAL = ?" // #1
		cQuery +=     " AND AQU.AQU_CATEG  = ?" // #2
		cQuery +=     " AND AQU.AQU_CARAC  = ?" // #3
		cQuery +=     " AND AQU.D_E_L_E_T_ = ?" // #4
		If lAlteracao // Se for alteração, ignora o próprio registro na validação
			cQuery += " AND AQU.R_E_C_N_O_ <> ?" // #5
		EndIf

		oDup := FA141GetQry(cQuery) // Obtém o objeto de query preparada (FwExecStatement)

		oDup:SetString(nParam++, FWxFilial("AQU")) // #1
		oDup:SetString(nParam++, oModelAQU:GetValue("AQU_CATEG")) // #2
		oDup:SetString(nParam++, oModelAQU:GetValue("AQU_CARAC")) // #3
		oDup:SetString(nParam++, Space(1)) // #4
		If lAlteracao // Se for alteração, ignora o próprio registro na validação
			oDup:SetNumeric(nParam++, AQU->(Recno())) // #5
		EndIf

		oDup:OpenAlias(cAliasDup)

		If !(cAliasDup)->(EOF()) .And. (cAliasDup)->QTDE > 0 // Se existir vínculo com os mesmos parâmetros informa o erro
			lValid    := .F.
			cProblema := STR0012 // "Já existe um vínculo cadastrado com os mesmos parâmetros."
			cSolucao  := STR0013 // "Verifique os dados informados e tente novamente."
			cRotina   := ProcName(1) // Nome da rotina onde ocorreu o erro
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf

		(cAliasDup)->(DBCloseArea())
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} fa141VldCat
Método para validar se a característica já está vinculado em categorias filhas ou superiores

@type    Method
@author  Jorge Martins
@since   25/11/2025
@version 12

@param   oModel - Modelo de dados de Categorias x Características de Produtos
@return  lValid - .T. se os dados estão válidos
/*/
//-------------------------------------------------------------------
METHOD fa141VldCat(oModel, lAlteracao) CLASS FATA141EVDEF
Local lValid      As Logical
Local lValidFil   As Logical
Local lValidSup   As Logical
Local lRaiz       As Logical
Local cQuery      As Character
Local cAliasRep   As Character
Local cProblema   As Character
Local cSolucao    As Character
Local cRotina     As Character
Local cFilialACU  As Character
Local cFilialAQU  As Character
Local cSpcDelete  As Character
Local cCategoria  As Character
Local cCaract     As Character
Local cNivel      As Character
Local nRecnoAQU   As Numeric
Local nParam      As Numeric
Local nCategs     As Numeric
Local nQtdCategs  As Numeric
Local aCategorias As Array
Local oQuery      As Object
Local oModelAQU   As Object

Default oModel     := Nil
Default lAlteracao := .F.

	lValid    := .T.

	If oModel <> Nil

		oModelAQU := oModel:GetModel("AQUMASTER")

		aCategorias := {}
		cFilialACU  := FwxFilial("ACU")
		cFilialAQU  := FwxFilial("AQU")
		cSpcDelete  := Space(1)
		cCategoria  := oModelAQU:GetValue("AQU_CATEG")
		cCaract     := oModelAQU:GetValue("AQU_CARAC")
		lRaiz       := Empty(cCategoria)
		If lAlteracao
			nRecnoAQU := AQU->(Recno())
		EndIf

		aAdd(aCategorias, FA141GetFil(cFilialACU, cCategoria)) // Categorias filhas
		aAdd(aCategorias, FA141GetSup(cFilialACU, cCategoria)) // Categorias superiores

		For nCategs := 1 To Len(aCategorias)
			
			nQtdCategs := Len(aCategorias[nCategs]) // Quantidade de categorias filhas/superiores

			lValidFil := nCategs == 1 .And. (nQtdCategs > 0 .Or. lRaiz) // Valida categorias filhas
			lValidSup := nCategs == 2 .And. nQtdCategs > 0              // Valida categorias superiores

			If lValidFil .Or. lValidSup // Se existir categorias filhas ou superiores para validação

				cQuery :=   "SELECT COALESCE(ACU.ACU_COD, '') ACU_COD, COALESCE(ACU.ACU_DESC, '') ACU_DESC"
				cQuery +=    " FROM " + RetSqlName("AQU") + " AQU"
				cQuery +=    " LEFT JOIN " + RetSqlName("ACU") + " ACU"
				cQuery +=      " ON ACU.ACU_FILIAL = ?" // #1
				cQuery +=     " AND ACU.ACU_COD = AQU.AQU_CATEG"
				cQuery +=     " AND ACU.ACU_MSBLQL <> ?" // #2
				cQuery +=     " AND ACU.D_E_L_E_T_ = ?" // #3
				cQuery +=   " WHERE AQU.AQU_FILIAL = ?" // #4
				If lValidSup .Or. (lValidFil .And. !lRaiz)
					// Se for validação de categorias filhas e a categoria atual não for raiz não precisa validar uma categoria específica, 
					// pois se achar em qualquer filha já é problema
					cQuery += " AND AQU.AQU_CATEG IN (?)" // #5
				EndIf
				cQuery +=     " AND AQU.AQU_CARAC  = ?" // #6
				cQuery +=     " AND AQU.D_E_L_E_T_ = ?" // #7
				If lAlteracao // Se for alteração, ignora o próprio registro na validação
					cQuery += " AND AQU.R_E_C_N_O_ <> ?" // #8
				EndIf

				oQuery := FA141GetQry(cQuery) // Obtém o objeto de query preparada (FwExecStatement)

				nParam := 1
				oQuery:SetString(nParam++, cFilialACU) // #1
				oQuery:SetString(nParam++, "1") // #2
				oQuery:SetString(nParam++, cSpcDelete) // #3
				oQuery:SetString(nParam++, cFilialAQU) // #4
				If lValidSup .Or. (lValidFil .And. !lRaiz)
					oQuery:SetIn(nParam++, aCategorias[nCategs]) // #5
				EndIf
				oQuery:SetString(nParam++, cCaract) // #6
				oQuery:SetString(nParam++, cSpcDelete) // #7
				If lAlteracao // Se for alteração, ignora o próprio registro na validação
					oQuery:SetNumeric(nParam++, nRecnoAQU) // #8
				EndIf

				cAliasRep := GetNextAlias()
				oQuery:OpenAlias(cAliasRep)

				If !(cAliasRep)->(EOF()) // Se existir vínculo da característica em categorias filhas/superiores informa o erro
					If Empty((cAliasRep)->ACU_COD)
						cCategoria := STR0016 // "Raiz"
					Else
						cCategoria := AllTrim((cAliasRep)->ACU_COD) + " - " + AllTrim((cAliasRep)->ACU_DESC)
					EndIf
					
					If nCategs == 1 // Categorias filhas
						cNivel := STR0019 // "filha"
					Else // Categorias superiores
						cNivel := STR0020 // "superior"
					EndIf
					lValid    := .F.
					cProblema := I18n(STR0014, {cNivel, cCategoria}) // "A característica já está vinculada na categoria #1: '#2'
					cSolucao  := STR0015 // "Verifique a característica informada."
					cRotina   := ProcName(1) // Nome da rotina onde ocorreu o erro
					Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
				EndIf

				(cAliasRep)->(DBCloseArea())

			EndIf
		Next
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} FA141GetSup
Monta um array com as categorias de nível superior para validação
de replica de características

@type    Function
@author  Jorge Martins
@since   25/11/2025
@version 12

@param   cCategoria - Código da categoria atual
@param   cFilialACU - Filial da tabela ACU
@param   lInativas  - Inclui categorias inativas na busca
@return  aCategorias - Array com as categorias superiores
/*/
//-------------------------------------------------------------------
Static Function FA141GetSup(cFilialACU, cCategoria, lInativas)
Local aCategorias As Array
Local lRaiz       As Logical

Default cFilialACU := FwxFilial("ACU")
Default cCategoria := ""
Default lInativas  := .F.

	lRaiz       := .F.
	aCategorias := {}

	If !Empty(cCategoria) // Se a categoria atual não for vazia busca as categorias superiores
		While !lRaiz
			// Busca o código pai da categoria atual
			cCategoria := FA141AddPai(cFilialACU, cCategoria, lInativas)

			aAdd(aCategorias, cCategoria) // Adiciona a categoria atual ao array
			
			lRaiz := Empty(cCategoria) // Verifica se chegou na categoria raiz
		EndDo
	EndIf

Return aCategorias

//-------------------------------------------------------------------
/*/{Protheus.doc} FA141AddPai
Busca o código da categoria pai

@type    Function
@author  Jorge Martins
@since   25/11/2025
@version 12

@param   cFilialACU - Filial da tabela ACU
@param   cCategoria - Código da categoria atual
@param   lInativas  - Inclui categorias inativas na busca
@return  cPai - Código da categoria pai
/*/
//-------------------------------------------------------------------
Static Function FA141AddPai(cFilialACU as Character, cCategoria as Character, lInativas as Logical)
Local cPai      As Character
Local cQuery    As Character
Local nParam    As Numeric
Local cAliasPai As Character
Local oQuerySup As Object

Default cFilialACU := FwxFilial("ACU")
Default cCategoria := ""
Default lInativas  := .F.

	cPai      := ""
	cAliasPai := GetNextAlias()

	cQuery :=  " SELECT ACU.ACU_CODPAI"
	cQuery +=    " FROM " + RetSqlName("ACU") + " ACU"
	cQuery +=   " WHERE ACU.ACU_FILIAL = ?"  // #1
	cQuery +=     " AND ACU.ACU_COD = ?"     // #2
	If !lInativas // Se não for para incluir inativas
		cQuery += " AND ACU.ACU_MSBLQL <> ?" // #3
	EndIf
	cQuery +=     " AND ACU.D_E_L_E_T_ = ?"  // #4

	oQuerySup := FA141GetQry(cQuery) // Obtém o objeto de query preparada (FwExecStatement)

	nParam := 1
	oQuerySup:SetString(nParam++, cFilialACU)  // #1
	oQuerySup:SetString(nParam++, cCategoria)  // #2
	If !lInativas // Se não for para incluir inativas
		oQuerySup:SetString(nParam++, "1")     // #3
	EndIf
	oQuerySup:SetString(nParam++, Space(1))    // #4
	
	oQuerySup:OpenAlias(cAliasPai)

	If !(cAliasPai)->(EOF())
		cPai := (cAliasPai)->ACU_CODPAI
	EndIf

	(cAliasPai)->(DBCloseArea())

Return cPai

//-------------------------------------------------------------------
/*/{Protheus.doc} FA141GetFil
Monta um array com as categorias de nível inferior (filhas) para validação
de replica de características

@type    Function
@author  Jorge Martins
@since   25/11/2025
@version 12

@param   cCategoria - Código da categoria atual
@param   cFilialACU - Filial da tabela ACU
@return  aCategorias - Array com as categorias filhas
/*/
//-------------------------------------------------------------------
Static Function FA141GetFil(cFilialACU, cCategoria)
Local aCategorias As Array

Default cFilialACU := FwxFilial("ACU")
Default cCategoria := ""

	aCategorias := {}

	If !Empty(cCategoria) // Se a categoria atual não for vazia
		// Busca recursivamente todas as categorias descendentes
		FA141AddFil(cFilialACU, cCategoria, @aCategorias)
	EndIf

Return aCategorias

//-------------------------------------------------------------------
/*/{Protheus.doc} FA141AddFil
Busca o código da categoria filha

@type    Function
@author  Jorge Martins
@since   25/11/2025
@version 12

@param   cFilialACU - Filial da tabela ACU
@param   cCategoria - Código da categoria atual
@param   aCategorias - Array com as categorias filhas
/*/
//-------------------------------------------------------------------
Static Function FA141AddFil(cFilialACU, cCategoria, aCategorias)
Local cQuery    As Character
Local oQuery    As Object
Local nParam    As Numeric
Local cAliasFil As Character

Default cFilialACU  := FwxFilial("ACU")
Default cCategoria  := ""
Default aCategorias := {}

	cQuery := " SELECT ACU.ACU_COD"
	cQuery +=   " FROM " + RetSqlName("ACU") + " ACU"
	cQuery +=  " WHERE ACU.ACU_FILIAL = ?"  // #1
	cQuery +=    " AND ACU.ACU_CODPAI = ?"  // #2
	cQuery +=    " AND ACU.ACU_MSBLQL <> ?" // #3
	cQuery +=    " AND ACU.D_E_L_E_T_ = ?"  // #4

	oQuery := FWExecStatement():New(cQuery)

	nParam := 1
	oQuery:SetString(nParam++, cFilialACU)  // #1
	oQuery:SetString(nParam++, cCategoria)  // #2
	oQuery:SetString(nParam++, "1")         // #3
	oQuery:SetString(nParam++, Space(1))    // #3
	
	cAliasFil := GetNextAlias()
	oQuery:OpenAlias(cAliasFil)

	While !(cAliasFil)->(EOF())

		aAdd(aCategorias, (cAliasFil)->ACU_COD)

		// Busca filhos dessa categoria (recursão)
		FA141AddFil(cFilialACU, (cAliasFil)->ACU_COD, @aCategorias)

		(cAliasFil)->(DBSkip())

	EndDo

	(cAliasFil)->(DBCloseArea())

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} FA141GetQry
	Obtém o objeto (FwExecStatement) de query preparada para a expressão SQL informada.

	@sample     GetQuery(cQuery)
	@type       Function
	@param      cQuery, Character, Expressão SQL
	@return     oPrepared, Object, Objeto de query preparada
	@author     Jorge Martins / Squad Retail
	@since      17/11/2025
	@version    12.1.2610
/*/
//------------------------------------------------------------------------------
Static Function FA141GetQry(cQuery)
Local oPrepared    as Object
Local nPosPrepared as Numeric
Local cMD5         as Character

Default cQuery := ""

	cMD5 := MD5(cQuery)
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrepared,{FwExecStatement():New(cQuery), cMD5})
		nPosPrepared := Len(__aPrepared)
	Endif

	oPrepared := __aPrepared[nPosPrepared][1]

Return oPrepared

//-------------------------------------------------------------------
/*/{Protheus.doc} fa141InD4X
Função para incluir o vínculo do produto com as características 
da categoria na tabela D4X

@type    Method
@author  Jorge Martins | Protheus Retail
@since   04/03/2026
@version 12

@param   oModel - Modelo de dados de Categorias x Características de Produtos
@return         - .T. se os vínculos foram feitos corretamente

/*/
//-------------------------------------------------------------------
METHOD fa141InD4X(oModel) CLASS FATA141EVDEF
Local cFilD4X    As Character
Local cCategoria As Character
Local cProduto   As Character
Local cCaract    As Character
Local cAliasQry  As Character
Local oModelAQU  As Object

Default oModel := Nil

	If oModel <> Nil .And. oModel:IsActive() .And. FindFunction("Ft150Carac")

		oModelAQU  := oModel:GetModel("AQUMASTER")
		cCategoria := oModelAQU:GetValue("AQU_CATEG")
		cCaract    := oModelAQU:GetValue("AQU_CARAC")
		cFilD4X    := FwxFilial("D4X")

		cAliasQry  := ::fa141PrCat(cCategoria) // Busca os produtos vinculados na categoria

		While !(cAliasQry)->(Eof())
			cProduto   := (cAliasQry)->ACV_CODPRO
			cCategoria := (cAliasQry)->ACV_CATEGO

			If RecLock("D4X", .T.)
				D4X->D4X_FILIAL := cFilD4X
				D4X->D4X_PROD   := cProduto
				D4X->D4X_CARAC  := cCaract
				D4X->D4X_CATEGO := cCategoria
				D4X->(MsUnLock())
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo
	
		(cAliasQry)->(DbCloseArea())

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fa141PrCat
Busca os produtos vinculados na categoria para replicar as características na tabela D4X

@type    Method
@author  Jorge Martins
@since   04/03/2026
@version 12

@param   cCategoria - Código da categoria atual
@return  cAliasPrd - Alias com os produtos vinculados na categoria
/*/
//-------------------------------------------------------------------
METHOD fa141PrCat(cCategoria) CLASS FATA141EVDEF
Local cQuery     As Character
Local nParam     As Numeric
Local nCategs    As Numeric
Local cAliasPrd  As Character
Local oQueryPrd  As Object
Local aCategs    As Array
Local aCategFil  As Array

Default cCategoria := ""

	cAliasPrd := ""

	If !Empty(cCategoria)
		aCategs := {}
		aAdd(aCategs, cCategoria) // Adiciona a categoria atual no array
		aCategFil := FA141GetFil(FwxFilial("ACU"), cCategoria) // Busca as categorias filhas da categoria atual
		For nCategs := 1 To Len(aCategFil)
			aAdd(aCategs, aCategFil[nCategs]) // Adiciona as categorias filhas no array
		Next
	EndIf

	cAliasPrd := GetNextAlias()

	cQuery :=  " SELECT ACV.ACV_CODPRO, ACV.ACV_CATEGO"
	cQuery +=    " FROM " + RetSqlName("ACV") + " ACV"
	cQuery +=   " WHERE ACV.ACV_FILIAL = ?"    // #1
	If !Empty(cCategoria)
		cQuery += " AND ACV.ACV_CATEGO IN (?)" // #2
	EndIf
	cQuery +=     " AND ACV.ACV_CODPRO <> ?"   // #3
	cQuery +=     " AND ACV.D_E_L_E_T_ = ?"    // #4

	oQueryPrd := FA141GetQry(cQuery) // Obtém o objeto de query preparada (FwExecStatement)

	nParam := 1
	oQueryPrd:SetString(nParam++, FwxFilial("ACV")) // #1
	If !Empty(cCategoria)
		oQueryPrd:SetIn(nParam++, aCategs) // #2
	EndIf
	oQueryPrd:SetString(nParam++, Space(GetSx3Cache("ACV_CODPRO", "X3_TAMANHO"))) // #3
	oQueryPrd:SetString(nParam++, Space(1)) // #4

	oQueryPrd:OpenAlias(cAliasPrd)

Return cAliasPrd

//-------------------------------------------------------------------
/*/{Protheus.doc} fa141ExD4X
Função para excluir o vínculo do produto com as características

@type    Method
@author  cruz.rafael
@since   04/03/2026
@version 12

@param   cCategoria - Código da categoria atual
@return  lValid - Retorno da conclusão da validação
/*/
//-------------------------------------------------------------------
METHOD fa141ExD4X(oModel) CLASS FATA141EVDEF
Local lValid    As Logical
Local cQuery    As Character
Local cAliasExc As Character
Local cProblema As Character
Local cSolucao  As Character
Local cRotina   As Character
Local oExc      As Object
Local nParam    As Numeric
Local cCateg    As Character
Local cCarac    As Character
Local aAreaExc  As Array
Local aAreaD4X  As Array
Local nRecno    As Numeric
Local aCategs   As Array
Local aCategFil As Array
Local nCategs   As Numeric

Default oModel := Nil

	lValid := .T.

	If oModel <> Nil .And. oModel:IsActive() .And. FwAliasInDic("D4X")

		// Obtém as informações da categoria e característica do modelo
		cCateg := oModel:GetModel("AQUMASTER"):GetValue("AQU_CATEG")
		cCarac := oModel:GetModel("AQUMASTER"):GetValue("AQU_CARAC")
		
		aAreaExc := FwGetArea()
		aAreaD4X := D4X->(FwGetArea())

		If !Empty(cCateg)
			aCategs := {}
			aAdd(aCategs, cCateg) // Adiciona a categoria atual no array
			aCategFil := FA141GetFil(FwxFilial("ACU"), cCateg) // Busca as categorias filhas da categoria atual
			For nCategs := 1 To Len(aCategFil)
				aAdd(aCategs, aCategFil[nCategs]) // Adiciona as categorias filhas no array
			Next
		EndIf
		
		cAliasExc := GetNextAlias()

		cQuery :=   "SELECT D4X.R_E_C_N_O_ NRECNO"
		cQuery +=    " FROM " + RetSqlName("D4X") + " D4X"
		cQuery +=   " WHERE D4X.D4X_FILIAL = ?" // #1
		If !Empty(cCateg)
			cQuery += " AND D4X.D4X_CATEGO IN (?)" // #2
		EndIf
		cQuery +=     " AND D4X.D4X_CARAC = ?" // #3
		cQuery +=     " AND D4X.D_E_L_E_T_ = ?" // #4

		oExc := FA141GetQry(cQuery) // Obtém o objeto de query preparada (FwExecStatement)
		
		nParam := 1
		oExc:SetString(nParam++, FWxFilial("D4X")) // #1
		If !Empty(cCateg)
			oExc:SetIn(nParam++, aCategs) // #2
		EndIf
		oExc:SetString(nParam++, cCarac) // #3
		oExc:SetString(nParam++, Space(1)) // #4

		oExc:OpenAlias(cAliasExc)

		Begin Transaction

		While (cAliasExc)->(!EOF()) 
			nRecno := (cAliasExc)->NRECNO
			D4X->(dbGoTo(nRecno))
			If D4X->(SimpleLock())
				RecLock("D4X",.F.)
					D4X->(dbDelete())
				D4X->(MsUnlock())
			Else
				lValid    := .F.
				cProblema := STR0022 // "O registro foi bloqueado por outro usuário e não poderá ser excluído"
				cSolucao  := STR0023 // "Tente novamente mais tarde"
				cRotina   := ProcName(1) // Nome da rotina onde ocorreu o erro
				Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
				DisarmTransaction()
				Break
			EndIf
			(cAliasExc)->(DbSkip())
		EndDo

		End Transaction

		(cAliasExc)->(DBCloseArea())

		FwRestArea(aAreaD4X)
		FwRestArea(aAreaExc)
	EndIf

Return lValid
