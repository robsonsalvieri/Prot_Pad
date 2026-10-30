#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FATA150A.CH"

Static __aPrep := {} As Array

PUBLISH MODEL REST NAME FATA150A SOURCE FATA150A

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do Cadastro de Categoria x Produto

@type    Function
@author  cruz.rafael
@since   01/12/2025
@version 12

@return  oModel - Modelo de dados
@obs     ACVMASTER - Dados principais da Categoria
         ACVDETAIL - Produtos
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     As Object
	Local oStruCab   AS Object
	Local oStruGrid  As Object
	Local oEventMain As Object
	Local bLinePost  As CodeBlock
	Local bPostGrid  As CodeBlock

	bLinePost := {|oGridModel| Ft150LinOk(oGridModel)}
	bPostGrid := {|oGridModel| Ft150TudOk(oGridModel)}
	
	oModel := MPFormModel():New("FATA150A", /*Pre-Validacao*/, /*Pós-Validação*/, /*Commit*/, /*Cancel*/)

	oStruCab := FWFormModelStruct():New()

	oEventMain := FATA150AEVDEF():New()

	// Montagem do cabeçalho fake - https://tdn.totvs.com.br/pages/releaseview.action?pageId=544183102
	oStruCab:AddTable("", {"CATEGORIA"}, STR0001, {||""}) // "Amarração Categoria x Grupo ou Produto"
	oStruCab:AddField(GetSx3Cache("ACV_CATEGO", "X3_TITULO"), "", "CATEGORIA", "C", GetSx3Cache("ACV_CATEGO", "X3_TAMANHO"), 0)
	oStruCab:SetProperty("CATEGORIA", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, 'FT150ACOD(FwFldGet("CATEGORIA"))'))
	
	// Estrutura do grid
	oStruGrid   := FWFormStruct(1, "ACV")
	oStruGrid:SetProperty("ACV_CATEGO" , MODEL_FIELD_OBRIGAT, .F.)
	oStruGrid:SetProperty("ACV_GRUPO"  , MODEL_FIELD_OBRIGAT, .F.)
	oStruGrid:SetProperty("ACV_CODPRO" , MODEL_FIELD_OBRIGAT, .F.)
	oStruGrid:SetProperty("ACV_REFGRD" , MODEL_FIELD_OBRIGAT, .F.)
	oStruGrid:SetProperty("ACV_CATEGO" , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, ""))
	oStruGrid:SetProperty("ACV_DESPRO" , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, ""))
	oStruGrid:SetProperty("ACV_DESGRU" , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, ""))
	oStruGrid:SetProperty("ACV_DESREF" , MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, ""))
	
	oModel:AddFields("ACVMASTER", /*cOwner*/, oStruCab, /*bPre*/, /*bPost*/, {|oMdl| LoadHidFld(oMdl)})
	oModel:AddGrid("ACVDETAIL", "ACVMASTER", oStruGrid,, bLinePost,, bPostGrid, {|oMdl| LoadGrid(oMdl)})

	oModel:GetModel("ACVDETAIL"):SetUseOldGrid(.T.)

	oModel:SetPrimaryKey({"ACV_FILIAL", "ACV_CATEGO", "ACV_GRUPO", "ACV_CODPRO", "ACV_REFGRD"})
	oModel:GetModel("ACVDETAIL"):SetUniqueLine({"ACV_CATEGO", "ACV_GRUPO", "ACV_CODPRO", "ACV_REFGRD"})
	oModel:InstallEvent('FATA150AEVDEF', /*cOwner*/, oEventMain)
	
	oModel:setActivate({ |oModel| OnActivate(oModel)})

Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} OnActivate
Função para criação do cabeçalho FAKE na inicialização do modelo

@type    function
@author  cruz.rafael
@since   01/12/2025
@version 12
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function OnActivate(oModel)

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE
		If oModel:GetOperation() == MODEL_OPERATION_INSERT
			oModel:LoadValue("ACVMASTER", "CATEGORIA", "FAKE")
		ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE
			oModel:SetValue("ACVMASTER", "CATEGORIA", ACV->ACV_CATEGO)
		Else
			oModel:LoadValue("ACVMASTER", "CATEGORIA", ACV->ACV_CATEGO)
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadHidFld
Efetua o carregamento dos campos da MASTER fake, para
que ocorra o correto relacionamento com a ACV

@type    Function
@author  cruz.rafael
@since   01/12/2025
@version 12

@param  oModel  - Objeto do modelo de dados
@return aReturn - Array de referência dos campos do cabeçalho preenchido.
/*/
//-------------------------------------------------------------------
Static Function LoadHidFld(oModel)
Local aReturn As Array

aReturn := {}

If oModel:GetOperation() <> MODEL_OPERATION_INSERT
	aAdd(aReturn, ACV->ACV_CATEGO)
EndIf

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} FATA150AEVDEF
Eventos padrão do cadastro de Categorias x Produtos.

As regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    Class
@author  cruz.rafael
@since   01/12/2025
@version 12
 
/*/
//-------------------------------------------------------------------
CLASS FATA150AEVDEF From FWModelEvent
	DATA nOpc        As Numeric

	METHOD new() CONSTRUCTOR

	METHOD modelPosVld()
	METHOD f150AVldDup() // Valida duplicidade de registros
	METHOD f150AInD4X() // Inclui o vínculo do produto com as características da categoria

ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} new
Método construtor da classe FATA150AEVDEF

@type    Method
@author  cruz.rafael
@since   01/12/2025
@version 12
/*/
//-------------------------------------------------------------------------------------------------------------
Method new() Class FATA150AEVDEF
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} modelPosVld
Método de validação do modelo antes da gravação dos dados

@type    Method
@author  cruz.rafael
@since   01/12/2025
@version 12

@param   oModel - Modelo de dados de Categorias x Características de Produtos
@param   cID    - Identificador do modelo
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD modelPosVld(oModel, cID) CLASS FATA150AEVDEF
Local lValid As Logical

Default oModel := Nil
Default cID    := ""

	lValid := .T.

	If oModel <> Nil
		::nOpc := oModel:GetOperation()
		
		If ::nOpc == MODEL_OPERATION_INSERT .Or. ::nOpc == MODEL_OPERATION_UPDATE
			If lValid .And. !SuperGetMv("MV_LJCATPR", .F., .F.) // Se .T., indica que pode ter amarracao de um produto a mais de uma categoria
				lValid := ::f150AVldDup(oModel, ::nOpc == MODEL_OPERATION_UPDATE) // Valida se existe duplicidade
			EndIf

			If lValid .And. ::nOpc == MODEL_OPERATION_INSERT
				lValid := ::f150AInD4X(oModel) // Inclui o vínculo do produto com as características da categoria
			EndIf
		EndIf
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} f150AVldDup
Método de validação de duplicidade de registros

@type    Method
@author  cruz.rafael
@since   01/12/2025
@version 12

@param   oModel     - Modelo de dados de Categorias x Características de Produtos
@param   lAlteracao - Indica se a validação é para alteração
@return  lValid     - .T. se os dados estão válidos e sem duplicidade

/*/
//-------------------------------------------------------------------
METHOD f150AVldDup(oModel, lAlteracao) CLASS FATA150AEVDEF
Local lValid    As Logical
Local cQuery    As Character
Local cAliasDup As Character
Local cProblema As Character
Local cSolucao  As Character
Local cRotina   As Character
Local oDup      As Object
Local oModelACV As Object
Local nParam    As Numeric
Local cCateg    As Character

Default oModel     := Nil
Default lAlteracao := .F.

	lValid    := .T.

	If oModel <> Nil

		nParam    := 1
		cAliasDup := GetNextAlias()
		cCateg    := oModel:GetModel("ACVMASTER"):GetValue("CATEGORIA")
		oModelACV := oModel:GetModel("ACVDETAIL")

		cQuery :=   "SELECT COUNT(1) QTDE"
		cQuery +=    " FROM " + RetSqlName("ACV") + " ACV"
		cQuery +=   " WHERE ACV.ACV_FILIAL = ?"  // #1
		cQuery +=     " AND ACV.ACV_CATEGO = ?"  // #2
		cQuery +=     " AND ACV.ACV_CODPRO = ?"  // #3
		cQuery +=     " AND ACV.ACV_GRUPO  = ?"  // #4
		cQuery +=     " AND ACV.ACV_REFGRD = ?"  // #5
		cQuery +=     " AND ACV.D_E_L_E_T_ = ?"  // #6
		If lAlteracao // Se for alteração, ignora o próprio registro na validação
			cQuery += " AND ACV.R_E_C_N_O_ <> ?" // #7
		EndIf

		oDup := F150AGetQr(cQuery) // Obtém o objeto de query preparada (FwExecStatement)

		oDup:SetString(nParam++, FWxFilial("ACV")) // #1
		If !lAlteracao .AND. Alltrim(cCateg) <> "FAKE"
			oDup:SetString(nParam++, oModel:GetModel("ACVMASTER"):GetValue("CATEGORIA")) // #2
		Else
			oDup:SetString(nParam++, oModelACV:GetValue("ACV_CATEGO"))  // #2
		EndIf
		oDup:SetString(nParam++, oModelACV:GetValue("ACV_CODPRO")) // #3
		oDup:SetString(nParam++, oModelACV:GetValue("ACV_GRUPO"))  // #4
		oDup:SetString(nParam++, oModelACV:GetValue("ACV_REFGRD")) // #5
		oDup:SetString(nParam++, Space(1)) // #6
		If lAlteracao // Se for alteração, ignora o próprio registro na validação
			oDup:SetNumeric(nParam++, ACV->(Recno())) // #7
		EndIf

		oDup:OpenAlias(cAliasDup)

		If !(cAliasDup)->(EOF()) .And. (cAliasDup)->QTDE > 0 // Se existir vínculo com os mesmos parâmetros informa o erro
			lValid    := .F.
			Do Case
				Case !Empty(oModelACV:GetValue("ACV_CODPRO"))
					cProblema := STR0002 // "O produto não é valido ou encontra-se amarrado a outra categoria."
				Case !Empty(oModelACV:GetValue("ACV_GRUPO"))
					cProblema := STR0003 // "O grupo de produto informado não é valido ou encontra-se amarrado a outra categoria."
				Case !Empty(oModelACV:GetValue("ACV_REFGRD"))
					cProblema := STR0004 // "A referência de grade informada não é valida ou encontra-se amarrada a outra categoria."
				OtherWise
					cProblema := STR0005 // "O produto/grupo/grade informado(a) não é valido(a) ou encontra-se amarrado(a) a outra categoria."
			EndCase
			cSolucao  := STR0006 // "Verifique os dados informados e tente novamente."
			cRotina   := ProcName(1) // Nome da rotina onde ocorreu o erro
			Help("", 1, "HELP", cRotina, cProblema, 1,,,,,,, {cSolucao})
		EndIf

		(cAliasDup)->(DBCloseArea())
	EndIf

Return lValid

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadGrid
Função estática para efetuar o load dos dados do grid

@param oModel - Objeto do modelo de dados
@return aData - Array com os dados para exibição no grid

@author cruz.rafael
@since 01/12/2025
@version 12
/*/
//-------------------------------------------------------------------
Static Function LoadGrid(oModel)
	Local aData     As Array
	Local aAreaGrd  As Array
	Local cAliasGrd As Character
	Local oQuery    As Object
	Local cQuery    As Character
	Local nParam    As Numeric

	aAreaGrd  := FwGetArea()
	cAliasGrd := GetNextAlias()

	cQuery := "SELECT ?, R_E_C_N_O_ RECNO " // #1
	cQuery +=   "FROM "+RetSqlName("ACV") + " ACV "
	cQuery +=  "WHERE ACV.ACV_FILIAL = ? "  // #2
	cQuery +=    "AND ACV.ACV_CATEGO = ? "  // #3
	cQuery +=    "AND ACV.D_E_L_E_T_ = ? "  // #4

	oQuery := F150AGetQr(cQuery) // Obtém o objeto de query preparada (FwExecStatement)

	nParam := 1
	oQuery:SetUnsafe(nParam++, F150AGetCp(oModel)) // #1
	oQuery:SetString(nParam++, FWxFilial("ACV")) // #2
	oQuery:SetString(nParam++, ACV->ACV_CATEGO) // #3
	oQuery:SetString(nParam++, Space(1)) // #4

	oQuery:OpenAlias(cAliasGrd)

	aData := FwLoadByAlias(oModel, cAliasGrd, "ACV", "RECNO", , .T.)

	(cAliasGrd)->(DBCloseArea())

	FWRestArea(aAreaGrd)

return aData

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados do Cadastro de Categoria x Produto

@type    Function
@author  cruz.rafael
@since   01/12/2025
@version 12

@return oView - View de dados
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView     As Object
	Local oModel    As Object
	Local oStruCab  As Object
	Local oStruGrid As Object

	oModel   := FWLoadModel( 'FATA150A' )
	oStruCab := FWFormViewStruct():New()

	oStruCab:AddField('CATEGORIA', '1', GetSx3Cache("ACV_CATEGO", "X3_TITULO"), GetSx3Cache("ACV_CATEGO", "X3_DESCRIC"),, 'Get',,,,.T. )
	oStruCab:SetProperty('CATEGORIA', MVC_VIEW_LOOKUP, "ACU")

	//Estrutura de Grid
	oStruGrid := FWFormStruct(2, "ACV", {|cCampo| !Alltrim( cCampo ) $ 'ACV_CATEGO|ACV_DESCAT' } )

	oView:= FWFormView():New() 

	oView:SetModel(oModel)
	oView:AddField('FATA150A_VIEW', oStruCab, 'ACVMASTER')
	oView:AddGrid('FATA150A_GRID', oStruGrid, 'ACVDETAIL')
	oView:CreateHorizontalBox("MAIN", 10)
	oView:CreateHorizontalBox("GRID", 90)
	oView:SetOwnerView('FATA150A_VIEW', 'MAIN')
	oView:SetOwnerView('FATA150A_GRID', 'GRID')
	oView:AddIncrementField('FATA150A_GRID', 'ACV_SEQPRD')
	oView:setDescription(STR0001) // "Amarração Categoria x Grupo ou Produto"

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} F150AGetQr
	Obtém o objeto (FwExecStatement) de query preparada para a expressão SQL informada.

	@sample     GetQuery(cQuery)
	@type       Function
	@param      cQuery, Character, Expressão SQL
	@return     oPrepared, Object, Objeto de query preparada
	@author     cruz.rafael / Squad Retail
	@since      01/12/2025
	@version    12
/*/
//------------------------------------------------------------------------------
Static Function F150AGetQr(cQuery)
	Local oPrepared as Object
	Local nPosPrep  as Numeric
	Local cMD5      as Character
	
	Default cQuery := ""

	cMD5 := MD5(cQuery)
	If (nPosPrep := Ascan(__aPrep,{|x| x[2] == cMD5})) == 0
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrep,{FwExecStatement():New(cQuery), cMD5})
		nPosPrep := Len(__aPrep)
	Endif

	oPrepared := __aPrep[nPosPrep][1]

Return oPrepared

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft150ACod
	Indica se o código da categoria é válido para o cadastro, ou seja, 
	se existe na tabela ACU e se tem vínculo com a ACV.

	@type    Function
	@author  cruz.rafael
	@since   10/01/2026
	@version 12
	@param   cCateg, Character, Código da Categoria
	@return  lRet, Logic, Validações do Código da Categoria
/*/
//------------------------------------------------------------------------------
Function Ft150ACod(cCateg)
	Local lRet := .T.

	Default cCateg := ""

	If Alltrim(cCateg) <> "FAKE"
		lRet := ExistCpo("ACU", FWFldGet("CATEGORIA")) .And. ExistChav("ACV", FWFldGet("ACV_CODPRO") + FWFldGet("CATEGORIA"), 5)
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} F150AGetCp
Função que retorna os campos do modelo

@type       Function
@author     Jorge Martins
@since      04/02/2026
@version    12
@param      oModelGrid , Object   , Objeto do modelo do grid
@return     cCampos    , Character, Campos do modelo
/*/
//------------------------------------------------------------------------------
Static Function F150AGetCp(oModelGrid)
	Local aFieldsGrd as Array
	Local cCampos    as Character
	Local nCpo       as Numeric

	Default oModelGrid := Nil

	If oModelGrid <> Nil
		aFieldsGrd := oModelGrid:GetStruct():GetFields()
		cCampos    := ""
		nCpo       := 1

		For nCpo := 1 To Len(aFieldsGrd)
			If aFieldsGrd[nCpo][MODEL_FIELD_VIRTUAL]
				cCampos += "'' " + aFieldsGrd[nCpo][MODEL_FIELD_IDFIELD] + ", "
			Else
				cCampos += aFieldsGrd[nCpo][MODEL_FIELD_IDFIELD] + ", "
			EndIf
		Next

		cCampos := SubStr(cCampos, 1, Len(cCampos) - 2)
	EndIf

Return cCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} f150AInD4X
Inclui o vínculo do produto com as características da categoria 
na tabela D4X quando a característica é vinculada a categoria

@type    Method
@author  Jorge Martins | Protheus Retail
@since   04/03/2026
@version 12

@param   oModel - Modelo de dados de Categorias x Características de Produtos
@return         - .T. se os vínculos foram feito corretamente

/*/
//-------------------------------------------------------------------
METHOD f150AInD4X(oModel) CLASS FATA150AEVDEF
Local nC        As Numeric
Local nP        As Numeric
Local nQtdProd  As Numeric
Local cFilD4X   As Character
Local cCateg    As Character
Local cCatRaiz  As Character
Local cProduto  As Character
Local aCaract   As Array
Local oModelACV As Object

Default oModel := Nil

	If oModel <> Nil .And. oModel:IsActive() .And. FwAliasInDic("D4X")

		cFilD4X   := FwxFilial("D4X")
		oModelACV := oModel:GetModel("ACVDETAIL")
		nQtdProd  := oModelACV:GetQtdLines()
		cCatRaiz  := Space(GetSx3Cache("ACV_CATEGO", "X3_TAMANHO")) // Categoria raiz sempre é vazia

		If nQtdProd > 0
			cCateg  := oModelACV:GetValue("ACV_CATEGO", 1)
			aCaract := F150ACarac(cCateg, cCatRaiz) // Obtem as características da categoria

			For nP := 1 To nQtdProd
				cProduto := oModelACV:GetValue("ACV_CODPRO", nP)

				If Len(aCaract) > 0 .And. !Empty(cProduto)
					For nC := 1 To Len(aCaract)
						If RecLock("D4X", .T.)
							D4X->D4X_FILIAL := cFilD4X
							D4X->D4X_PROD   := cProduto
							D4X->D4X_CARAC  := aCaract[nC][1]
							D4X->D4X_CATEGO := aCaract[nC][2]
							D4X->(MsUnLock())
						EndIf
					Next
				EndIf
			Next
		EndIf

		FwFreeArray(aCaract)

	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F150ACarac
Função para retornar as características vinculadas a uma categoria
e também características de níveis superiores

@type    Static Function
@author  Jorge Martins | Protheus Retail
@since   06/03/2026
@version 12

@param   cCategoria - Código da categoria
@param   cCatRaiz   - Código da categoria raiz (vazio)
@return  aCaract    - Array com as características e suas categorias
/*/
//-------------------------------------------------------------------
Static Function F150ACarac(cCategoria, cCatRaiz)
Local cQuery     as Character
Local cAliasQry  as Character
Local cFilialACU as Character
Local lCont      as Logical
Local nParam     as Numeric
Local oQuery     as Object
Local aCaract    as Array
Local aCateg     as Array
Local aArea      as Array
Local aAreaACU   as Array

Default cCategoria := ""
Default cCatRaiz   := ""

	aCaract    := {}
	aCateg     := {cCatRaiz}
	aArea      := FWGetArea()
	aAreaACU   := ACU->(FWGetArea())
	cFilialACU := FWxFilial("ACU")
	lCont      := .T.

	// Tratamento para buscar as características da Categoria Pai
	dbSelectArea("ACU")
	ACU->(DbSetOrder(1)) // ACU_FILIAL + ACU_COD
	While lCont
		aAdd(aCateg, cCategoria)

		If ACU->(MsSeek(cFilialACU + cCategoria)) .And. Empty(ACU->ACU_CODPAI)
			lCont := .F.
			Exit
		EndIf

		cCategoria := ACU->ACU_CODPAI
	EndDo

	cQuery :=   "SELECT AQU.AQU_CARAC, AQU.AQU_CATEG"
	cQuery +=    " FROM " + RetSqlName("AQU") + " AQU"
	cQuery +=   " WHERE AQU.AQU_FILIAL = ?"
	cQuery +=     " AND AQU.AQU_CATEG IN (?)"
	cQuery +=     " AND AQU.D_E_L_E_T_ = ?"

	oQuery := F150AGetQr(cQuery)

	nParam := 1
	oQuery:SetString(nParam++, FWxFilial("AQU"))
	oQuery:SetIn(nParam++, aCateg)
	oQuery:SetString(nParam++, Space(1))

	cAliasQry := GetNextAlias()
	oQuery:OpenAlias(cAliasQry)

	While !(cAliasQry)->(EOF())
		aAdd(aCaract, {(cAliasQry)->AQU_CARAC, (cAliasQry)->AQU_CATEG})
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DBCloseArea())

	FWRestArea(aAreaACU)
	FWRestArea(aArea)
	FwFreeArray(aCateg)

Return aCaract
