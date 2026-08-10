#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA712.CH"

/*/{Protheus.doc} ConsultaSetup
Classe para construção de tela de filtro multivalorado
@author Marcelo Neumann
@since 09/08/2019
@version P12
/*/
CLASS ConsultaSetup FROM LongClassName

	DATA cCodigo    AS STRING
	DATA cDescricao AS STRING
	DATA nOpcao     AS INTEGER
	DATA oView      AS OBJECT

	METHOD New() CONSTRUCTOR
	METHOD AbreTela()
	METHOD Destroy()
	METHOD GetCodigo()
	METHOD GetDescricao()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para a Consulta de Setup
@author Marcelo Neumann
@since 09/08/2019
@version P12
@return Self, objeto, classe ConsultaSetup
/*/
METHOD New() CLASS ConsultaSetup

	::cCodigo    := Nil
	::cDescricao := Nil
	::oView      := Nil
	::nOpcao     := 0

Return Self

/*/{Protheus.doc} Destroy
Método para limpar da memória os objetos utilizados pela classe
@author Marcelo Neumann
@since 09/08/2019
@version P12
@return Nil
/*/
METHOD Destroy() CLASS ConsultaSetup

	If ::oView <> Nil
		::oView:DeActivate()
		FreeObj(::oView)
	EndIf

Return

/*/{Protheus.doc} AbreTela
Método para abrir a tela de consulta/filtro multivalorado
@author Marcelo Neumann
@since 09/08/2019
@version P12
@return nOpcao, numérico, indica a opção selecionada
/*/
METHOD AbreTela() CLASS ConsultaSetup
	Local aArea     := GetArea()
	Local aButtons  := { {.F.,Nil    },{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
	                     {.T.,STR0166},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} } //"Selecionar"
	Local oViewExec := FWViewExec():New()

	::nOpcao := 0

	If ::oView == Nil
		::oView := ViewDef()

		//Adiciona os botões
		::oView:AddUserButton(STR0168, "", {|| AcaoBotao(self, 2)}   , , , , .T.) //"Copiar"
		::oView:AddUserButton(STR0169, "", {|oView| ExcluiSet(oView)}, , , , .T.) //"Excluir"
	EndIf

	oViewExec:setView(::oView)
	oViewExec:setTitle(STR0011) //"Setup de Configuração"
	oViewExec:setOperation(MODEL_OPERATION_VIEW)
	oViewExec:setReduction(65)
	oViewExec:setButtons(aButtons)
	oViewExec:setCancel({|| AcaoBotao(self, 1)})
	oViewExec:openView(.F.)

	RestArea(aArea)

Return ::nOpcao

/*/{Protheus.doc} ModelDef
Definição do Modelo
@author Marcelo Neumann
@since 09/08/2019
@version P12
@return oModel, objeto, modelo definido
/*/
Static Function ModelDef()

	Local oModel    := MPFormModel():New('PCPA712Con')
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := FWFormStruct(1, "HW2", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|HW2_CODIGO|HW2_DESCRI|"})

	//Cria campo para o modelo invisível
	oStruCab:AddField(STR0148, STR0148, "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , ) //"Consulta"

	//FLD_INVISIVEL - Modelo "invisível"
	oModel:addFields('FLD_INVISIVEL', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("FLD_INVISIVEL"):SetDescription(STR0148) //"Consulta"
	oModel:GetModel("FLD_INVISIVEL"):SetOnlyQuery(.T.)

	//::cModelName - Grid de resultados (o nome deve ser atribuido através da propriedade ::cModelName)
	oModel:AddGrid("GRID_RESULTS", "FLD_INVISIVEL", oStruGrid)
	oModel:GetModel("GRID_RESULTS"):SetDescription(STR0011) //"Setup de Configuração"
	oModel:GetModel("GRID_RESULTS"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID_RESULTS"):SetOptional(.T.)
	oModel:SetRelation("GRID_RESULTS",{{"HW2_FILIAL","xFilial('HW2')"},{"HW2_PARAM","'mrpStartDate'"}}, HW2->(IndexKey(1)))

	oModel:SetDescription(STR0148) //"Consulta"
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@author Marcelo Neumann
@since 09/08/2019
@version P12
@return oView, objeto, view definida
/*/
Static Function ViewDef()

	Local oStruGrid := FWFormStruct(2, "HW2", {|cCampo| "|" + AllTrim(cCampo) + "|" $ "|HW2_CODIGO|HW2_DESCRI|"})
	Local oView     := FWFormView():New()
	Local oModel    := FWLoadModel("PCPA712Con")

	//Definições da View
	oView:SetModel(oModel)

	//V_GRID_RESULTS - View da Grid com resultado da pesquisa
	oView:AddGrid("V_GRID_RESULTS", oStruGrid, "GRID_RESULTS")

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_GRID", 100)
	oView:SetOwnerView("V_GRID_RESULTS", 'BOX_GRID')

	//Habilita os botões padrões de filtro e pesquisa
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDFILTER", {.T.})
	oView:SetViewProperty("V_GRID_RESULTS", "GRIDSEEK", {.T.})

Return oView

/*/{Protheus.doc} LoadMdlFld
Carga do modelo mestre (invisível)
@author Marcelo Neumann
@since 09/08/2019
@version P12
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadMdlFld()

	Local aLoad := {}

	aAdd(aLoad, {"A"}) //dados
	aAdd(aLoad, 1    ) //recno

Return aLoad

/*/{Protheus.doc} AcaoBotao
Método chamado ao pressionar algum botão da tela
@author Marcelo Neumann
@since 09/08/2019
@version P12
@param 01 oSelf , objeto  , classe da tela de consulta
@param 02 nOpcao, numérico, indicador do botão clicado
@return lFechaTela, lógico, indicador para sempre fechar a tela
/*/
Static Function AcaoBotao(oSelf, nOpcao)

	Local oModel     := oSelf:oView:GetModel()
	Local lFechaTela := .F.

	oSelf:cCodigo    := oModel:GetModel("GRID_RESULTS"):GetValue("HW2_CODIGO")
	oSelf:cDescricao := oModel:GetModel("GRID_RESULTS"):GetValue("HW2_DESCRI")

	If Empty(oSelf:cCodigo)
		oSelf:nOpcao := 0
	Else
		oSelf:nOpcao := nOpcao
	EndIf

	If nOpcao == 1
		lFechaTela := .T.
	Else
		oSelf:oView:CloseOwner()
	EndIf

Return lFechaTela

/*/{Protheus.doc} ExcluiSet
Método chamado ao pressionar o botão "Excluir" da tela
@author Marcelo Neumann
@since 09/08/2019
@version P12
@param oView, objeto, view principal
@return lógico, retorna true para atualizar a tela
/*/
Static Function ExcluiSet(oView)

	Local oModel  := oView:GetModel()
	Local cCodigo := oModel:GetModel("GRID_RESULTS"):GetValue("HW2_CODIGO")
	Local cSqlDel := ""

	If !Empty(cCodigo)
		If ApMsgYesNo(STR0170 + AllTrim(cCodigo) + "?", STR0169) //"Deseja realmente excluir o Setup " "Excluir"
			cSqlDel := "UPDATE " + RetSqlName("HW2")      + ;
						 " SET D_E_L_E_T_   = '*',"       + ;
						 	 " R_E_C_D_E_L_ = R_E_C_N_O_" + ;
					   " WHERE HW2_FILIAL = '" + xFilial("HW2") + "'" + ;
						 " AND HW2_CODIGO = '" + cCodigo + "'"

			If TcSqlExec(cSqlDel) < 0
				Help(' ', 1, "Help", , STR0171, 2, 0, , , , , , ) //"Erro ao excluir o Setup."
			EndIf

			oModel:DeActivate()
			oModel:Activate()
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} GetCodigo
Método para recuperar os registros que foram selecionados na consulta
@author Marcelo Neumann
@since 09/08/2019
@version P12
@return ::cCodigo, caracter, código do setup selecionado na tela
/*/
METHOD GetCodigo() CLASS ConsultaSetup

Return ::cCodigo

/*/{Protheus.doc} GetDescricao
Método para recuperar os registros que foram selecionados na consulta
@author Marcelo Neumann
@since 09/08/2019
@version P12
@return ::cDescricao, caracter, descrição do setup selecionado na tela
/*/
METHOD GetDescricao() CLASS ConsultaSetup

Return ::cDescricao
