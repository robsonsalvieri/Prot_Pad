#INCLUDE "TOTVS.CH"

#DEFINE POS_VIEW_STRUCT_CAMPO   1
#DEFINE POS_VIEW_STRUCT_ORDEM   2
#DEFINE POS_VIEW_STRUCT_TITULO  3
#DEFINE POS_VIEW_STRUCT_PICTURE 7

#DEFINE POS_MODEL_STRUCT_TITULO  1
#DEFINE POS_MODEL_STRUCT_CAMPO   3
#DEFINE POS_MODEL_STRUCT_TIPO    4
#DEFINE POS_MODEL_STRUCT_TAMANHO 5
#DEFINE POS_MODEL_STRUCT_DECIMAL 6
#DEFINE POS_MODEL_STRUCT_OBRIGAT 10
#DEFINE POS_MODEL_STRUCT_RELACAO 11
#DEFINE POS_MODEL_STRUCT_CONTEXT 14

#DEFINE POS_X3_CAMPO    1
#DEFINE POS_X3_ORDEM    2
#DEFINE POS_X3_TIPO     3
#DEFINE POS_X3_TAMANHO  4
#DEFINE POS_X3_DECIMAL  5
#DEFINE POS_X3_TITULO   6
#DEFINE POS_X3_PICTURE  7
#DEFINE POS_X3_PROPRI   8
#DEFINE POS_X3_CBOX     9
#DEFINE POS_X3_OBRIGAT 10
#DEFINE POS_X3_VISUAL  11

/*/{Protheus.doc} ProductionOrderForm
Classe com o objetivo de montar o formulário dinamico do programa PCPA650

@author renan.roeder
@since 30/11/2021
@version P12
/*/
Class ProductionOrderForm FROM LongNameClass

    DATA oCamposNaoAlterados AS Object
    DATA oPosicaoCampos      AS Object
    DATA oCampos             AS Object
    DATA cOperacao           AS Object

	Method New(cOperacao) Constructor
	Method Destroy()

    Method defineAtributosDinamicos(nPosicao,oCampoX3)
    STATIC Method retornaCamposUsadosDicionario(cAlias)

    Method montaCabecalho()
    Method camposCabecalhoNaoAlterados()
    Method defineCabecalhoPosicao()
    Method defineCabecalhoCampos()

    Method montaEngenhariaAba()
    Method defineEngenhariaAbaPosicao()
    Method defineEngenhariaAbaCampos()

    Method montaDetalhesAba()
    Method defineDetalhesAbaPosicao()
    Method defineDetalhesAbaCampos()

    Method montaOutrasInformacoesAba()
    Method defineOutrasInformacoesAbaCampos()

EndClass

/*/{Protheus.doc} New
Método construtor da classe.

@author renan.roeder
@since 30/11/2021
@version P12
@return Self, Object, Instância da classe ProductionOrder
/*/
Method New(cOperacao) Class ProductionOrderForm
    DEFAULT cOperacao := "create"

    Self:oCamposNaoAlterados := JsonObject():New()
    Self:oPosicaoCampos      := JsonObject():New()
    Self:oCampos             := JsonObject():New()
    Self:cOperacao           := cOperacao

Return Self

/*/{Protheus.doc} Destroy
Método utilizado para limpar as informações do objeto.

@author renan.roeder
@since 30/11/2021
@version P12
@return Nil
/*/
Method Destroy() Class ProductionOrderForm

	FreeObj(Self:oCamposNaoAlterados)
    FreeObj(Self:oPosicaoCampos)
    FreeObj(Self:oCampos)

Return

/*/{Protheus.doc} retornaCamposUsadosDicionario
Método utilizado para retornar os campos que estão marcados como USADO no dicionário

@author renan.roeder
@since 30/11/2021
@version P12
@param  cAlias    , Caracter, Alias a ser pesquisado
@return aCamUsados, Array   , Array com os campos que estão marcados como Usados.
/*/
Method retornaCamposUsadosDicionario(cAlias) Class ProductionOrderForm
	Local aCamUsados := {}
	Local nIndex     := 0
	Local oViewStruct := Nil
	Local oMdlStruct  := Nil
	Default cAlias   := "SC2"

	oMdlStruct  := FWFormStruct(1, cAlias)
	oViewStruct := FWFormStruct(2, cAlias)

	For nIndex := 1 To Len(oViewStruct:aFields)

		nPos := Ascan(oMdlStruct:aFields,{ |x| x[POS_MODEL_STRUCT_CAMPO] == oViewStruct:aFields[nIndex][POS_VIEW_STRUCT_CAMPO]})
		If nPos > 0
			aAdd(aCamUsados , { oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_CAMPO], ;
								oViewStruct:aFields[nIndex][POS_VIEW_STRUCT_ORDEM], ;
								oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_TIPO], ;
								oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_TAMANHO], ;
								oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_DECIMAL], ;
								oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_TITULO], ;
								oViewStruct:aFields[nIndex][POS_VIEW_STRUCT_PICTURE], ;
								GetSX3Cache(oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_CAMPO], "X3_PROPRI" ), ;
								RTrim(GetSX3Cache(oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_CAMPO], "X3_CBOX") ), ;
								oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_OBRIGAT],;
								GetSX3Cache(oMdlStruct:aFields[nPos][POS_MODEL_STRUCT_CAMPO], "X3_VISUAL" ) })
		EndIf
		
	Next nIndex

	FreeObj(oViewStruct)
	FreeObj(oMdlStruct)

Return aCamUsados

/*/{Protheus.doc} defineAtributosDinamicos
Método para atribuir ao json do formulário os atributos do dicionário de dados

@author renan.roeder
@since 30/11/2021
@version P12
@param 01 nPosicao, Numerico, posição do array no json do formulario
@param 02 oCampoX3, Array , Array com dados da SX3
@return Nil
/*/
Method defineAtributosDinamicos(nPosicao,oCampoX3) Class ProductionOrderForm

	Self:oCampos['items'][nPosicao][ 'label' ]             := oCampoX3[POS_X3_TITULO]
	Self:oCampos['items'][nPosicao][ 'maxLength' ]         := oCampoX3[POS_X3_TAMANHO]
	Self:oCampos['items'][nPosicao][ 'thousandMaxlength' ] := oCampoX3[POS_X3_TAMANHO]-oCampoX3[POS_X3_DECIMAL]
	Self:oCampos['items'][nPosicao][ 'decimalsLength' ]    := oCampoX3[POS_X3_DECIMAL]
	Self:oCampos['items'][nPosicao][ 'required' ]          := oCampoX3[POS_X3_OBRIGAT] == .T.

	If !Self:oCampos['items'][nPosicao]:HasProperty('order')
		Self:oCampos['items'][nPosicao][ 'order' ]         := oCampoX3[POS_X3_ORDEM]
	EndIf

	If Self:cOperacao == "view"
		Self:oCampos['items'][nPosicao][ 'disabled' ]      := .T.
	ElseIf !Self:oCampos['items'][nPosicao]:HasProperty('disabled')
		Self:oCampos['items'][nPosicao][ 'disabled' ]      := oCampoX3[POS_X3_VISUAL] == 'V'
	EndIf

	If oCampoX3[POS_X3_TIPO] == 'D'
		Self:oCampos['items'][nPosicao][ 'type' ]          := 'date'
		Self:oCampos['items'][nPosicao][ 'format' ]        := 'dd/mm/yyyy'
	EndIf

	If oCampoX3[POS_X3_DECIMAL] > 0 .Or. oCampoX3[POS_X3_TIPO] == 'N'
		Self:oCampos['items'][nPosicao][ 'type' ]          := 'currency'
	EndIf

    If !Self:oCampos['items'][nPosicao]:HasProperty('gridColumns')
		Self:oCampos['items'][nPosicao][ 'gridColumns' ]   := 2
	EndIf

	Self:oCampos['items'][nPosicao][ 'visible' ]           := .T.

Return

/*/{Protheus.doc} montaCabecalho
Método utilizado para montar o formulario de cabeçalho da ordem de produção.

@author renan.roeder
@since 30/11/2021
@version P12
@return Self:oCampos, Character, json com o formato correto para ser atribuido ao dynamicform
/*/
Method montaCabecalho() Class ProductionOrderForm
	Local aCamposDic := Self:retornaCamposUsadosDicionario()
	Local nX         := 0

    Self:camposCabecalhoNaoAlterados()
    Self:defineCabecalhoPosicao()
    Self:defineCabecalhoCampos()

	For nX = 1 To Len(aCamposDic)
		If Self:oPosicaoCampos:HasProperty(aCamposDic[nX][POS_X3_CAMPO])
			Self:defineAtributosDinamicos(Self:oPosicaoCampos[aCamposDic[nX][POS_X3_CAMPO]],aCamposDic[nX])
			If Self:cOperacao == "edit" .And. Self:oCamposNaoAlterados:HasProperty(aCamposDic[nX][POS_X3_CAMPO])
				Self:oCampos['items'][Self:oPosicaoCampos[aCamposDic[nX][POS_X3_CAMPO]]]['disabled'] = "true"
			EndIf
		EndIf
	Next nX

Return Self:oCampos

/*/{Protheus.doc} camposCabecalhoNaoAlterados
Método para definir quais campos do cabeçalho da ordem de produção não poderão ser alterados na edição do cadastro

@author renan.roeder
@since 30/11/2021
@version P12
@return Nil
/*/
Method camposCabecalhoNaoAlterados() Class ProductionOrderForm

	Self:oCamposNaoAlterados["C2_FILIAL" ] := .T.
	Self:oCamposNaoAlterados["C2_NUM"    ] := .T.
	Self:oCamposNaoAlterados["C2_ITEM"   ] := .T.
	Self:oCamposNaoAlterados["C2_SEQUEN" ] := .T.
	Self:oCamposNaoAlterados["C2_ITEMGRD"] := .T.
	Self:oCamposNaoAlterados["C2_PRODUTO"] := .T.
	Self:oCamposNaoAlterados["C2_QUANT"  ] := .T.
	Self:oCamposNaoAlterados["C2_QUJE"   ] := .T.
	Self:oCamposNaoAlterados["C2_PERDA"  ] := .T.
Return

/*/{Protheus.doc} defineCabecalhoPosicao
Método para definir posição dos campos do cabeçalho no json

@author renan.roeder
@since 30/11/2021
@version P12
@return Nil
/*/
Method defineCabecalhoPosicao() Class ProductionOrderForm

	Self:oPosicaoCampos['C2_FILIAL']   := 1
	Self:oPosicaoCampos['C2_NUM']      := 2
	Self:oPosicaoCampos['C2_ITEM']     := 3
	Self:oPosicaoCampos['C2_SEQUEN']   := 4
	Self:oPosicaoCampos['C2_TPOP']     := 5
	Self:oPosicaoCampos['C2_PRODUTO']  := 6
	Self:oPosicaoCampos['C2_QUANT']    := 7
	Self:oPosicaoCampos['C2_STATUS']   := 8
	Self:oPosicaoCampos['C2_LOCAL']    := 9
	Self:oPosicaoCampos['C2_UM']       := 10
	Self:oPosicaoCampos['C2_SEGUM']    := 11
	Self:oPosicaoCampos['C2_TPPR']     := 12
	Self:oPosicaoCampos['C2_EMISSAO']  := 13
	Self:oPosicaoCampos['C2_DATPRF']   := 14
	Self:oPosicaoCampos['C2_DATPRI']   := 15
	Self:oPosicaoCampos['SALDO_ORDEM'] := 16
Return

/*/{Protheus.doc} defineCabecalhoCampos
Método para definir estrutura estática dos campos do cabeçalho

@author renan.roeder
@since 30/11/2021
@version P12
@return Nil
/*/
Method defineCabecalhoCampos() Class ProductionOrderForm

	Self:oCampos["items"] := Array(Len(Self:oPosicaoCampos:getNames()))

	Self:oCampos["items"][Self:oPosicaoCampos["C2_FILIAL"]]                  := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_FILIAL"]][ "property"]     := "C2_FILIAL"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_FILIAL"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_FILIAL"]][ "order"]        := Self:oPosicaoCampos["C2_FILIAL"]
	Self:oCampos["items"][Self:oPosicaoCampos["C2_FILIAL"]][ "disabled"]     := "true"

	Self:oCampos["items"][Self:oPosicaoCampos["C2_NUM"]]                     := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_NUM"]][ "property"]        := "C2_NUM"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_NUM"]][ "gridColumns"]     := 3
	Self:oCampos["items"][Self:oPosicaoCampos["C2_NUM"]][ "order"]           := Self:oPosicaoCampos["C2_NUM"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEM"]]                    := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEM"]][ "property"]       := "C2_ITEM"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEM"]][ "gridColumns"]    := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEM"]][ "order"]          := Self:oPosicaoCampos["C2_ITEM"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEQUEN"]]                  := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEQUEN"]][ "property"]     := "C2_SEQUEN"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEQUEN"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEQUEN"]][ "order"]        := Self:oPosicaoCampos["C2_SEQUEN"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_TPOP"]]                    := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_TPOP"]][ "property"]       := "C2_TPOP"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_TPOP"]][ "gridColumns"]    := 3
	Self:oCampos["items"][Self:oPosicaoCampos["C2_TPOP"]][ "order"]          := Self:oPosicaoCampos["C2_TPOP"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_STATUS"]]                  := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_STATUS"]][ "property"]     := "C2_STATUS"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_STATUS"]][ "gridColumns"]  := 4
	Self:oCampos["items"][Self:oPosicaoCampos["C2_STATUS"]][ "order"]        := Self:oPosicaoCampos["C2_STATUS"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_TPPR"]]                    := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_TPPR"]][ "property"]       := "C2_TPPR"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_TPPR"]][ "gridColumns"]    := 3
	Self:oCampos["items"][Self:oPosicaoCampos["C2_TPPR"]][ "order"]          := Self:oPosicaoCampos["C2_TPPR"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]]["property"]                := "C2_PRODUTO"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "gridColumns"]            := 6
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "searchService"]          := "/api/pcp/v1/prodOrders/products"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "params"]                 := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "params"]["branchId"]     := ""
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"]                :=  Array(5)
    Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][1]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][1]["property"] := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][1]["label"]    := GetSX3Cache("B1_COD", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][2]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][2]["property"] := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][2]["label"]    := GetSX3Cache("B1_DESC", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][3]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][3]["property"] := "STANDARDWAREHOUSE"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][3]["label"]    := GetSX3Cache("B1_LOCPAD", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][4]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][4]["property"] := "UNITMEASURE"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][4]["label"]    := GetSX3Cache("B1_UM", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][5]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][5]["property"] := "SECONDUNITMEASURE"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "columns"][5]["label"]    := GetSX3Cache("B1_SEGUM", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "format"]                 :=  Array(2)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "format"][1]              := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "format"][2]              := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "fieldLabel"]             := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "fieldValue"]             := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "order"]                  := Self:oPosicaoCampos["C2_PRODUTO"]
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRODUTO"]][ "disabled"]               := Self:oPosicaoCampos["C2_PRODUTO"]
	

	Self:oCampos["items"][Self:oPosicaoCampos["C2_UM"]]                    := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_UM"]][ "property"]       := "C2_UM"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_UM"]][ "gridColumns"]    := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_UM"]][ "order"]          := Self:oPosicaoCampos["C2_UM"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEGUM"]]                 := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEGUM"]][ "property"]    := "C2_SEGUM"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEGUM"]][ "gridColumns"] := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEGUM"]][ "order"]       := Self:oPosicaoCampos["C2_SEGUM"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]]["property"]                := "C2_LOCAL"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "gridColumns"]            := 5
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "searchService"]          := "/api/pcp/v1/prodOrders/warehouses"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "params"]                 := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "params"]["branchId"]     := ""
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "columns"]                :=  Array(2)
    Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "columns"][1]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "columns"][1]["property"] := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "columns"][1]["label"]    := GetSX3Cache("NNR_CODIGO", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "columns"][2]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "columns"][2]["property"] := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "columns"][2]["label"]    := GetSX3Cache("NNR_DESCRI", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "format"]                 :=  Array(2)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "format"][1]              := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "format"][2]              := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "fieldLabel"]             := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "fieldValue"]             := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LOCAL"]][ "order"]                  := Self:oPosicaoCampos["C2_LOCAL"]

    Self:oCampos["items"][Self:oPosicaoCampos["C2_QUANT"]]                     := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_QUANT"]][ "property"]        := "C2_QUANT"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_QUANT"]][ "gridColumns"]     := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_QUANT"]][ "order"]           := Self:oPosicaoCampos["C2_QUANT"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_EMISSAO"]]                   := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_EMISSAO"]][ "property"]      := "C2_EMISSAO"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_EMISSAO"]][ "gridColumns"]   := 3
	Self:oCampos["items"][Self:oPosicaoCampos["C2_EMISSAO"]][ "order"]         := Self:oPosicaoCampos["C2_EMISSAO"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_DATPRF"]]                    := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_DATPRF"]][ "property"]       := "C2_DATPRF"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_DATPRF"]][ "gridColumns"]    := 3
	Self:oCampos["items"][Self:oPosicaoCampos["C2_DATPRF"]][ "order"]          := Self:oPosicaoCampos["C2_DATPRF"]

	Self:oCampos["items"][Self:oPosicaoCampos["C2_DATPRI"]]                    := JsonObject():New()
    Self:oCampos["items"][Self:oPosicaoCampos["C2_DATPRI"]][ "property"]       := "C2_DATPRI"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_DATPRI"]][ "gridColumns"]    := 3
	Self:oCampos["items"][Self:oPosicaoCampos["C2_DATPRI"]][ "order"]          := Self:oPosicaoCampos["C2_DATPRI"]

	Self:oCampos["items"][Self:oPosicaoCampos["SALDO_ORDEM"]]                  := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["SALDO_ORDEM"]][ "property"]     := "SALDO_ORDEM"
	Self:oCampos["items"][Self:oPosicaoCampos["SALDO_ORDEM"]][ "gridColumns"]  := 3
	Self:oCampos["items"][Self:oPosicaoCampos["SALDO_ORDEM"]][ "required"]     := "false"
	Self:oCampos["items"][Self:oPosicaoCampos["SALDO_ORDEM"]][ "type"]         := "currency"
	Self:oCampos["items"][Self:oPosicaoCampos["SALDO_ORDEM"]][ "disabled"]     := "true"
	Self:oCampos["items"][Self:oPosicaoCampos["SALDO_ORDEM"]][ "order"]        := Self:oPosicaoCampos["SALDO_ORDEM"]
Return

/*/{Protheus.doc} montaEngenhariaAba
Método utilizado para montar o formulario da aba de engenharia da ordem de produção.

@author renan.roeder
@since 30/11/2021
@version P12
@return Self:oCampos, Character, json com o formato correto para ser atribuido ao dynamicform
/*/
Method montaEngenhariaAba() Class ProductionOrderForm
	Local aCamposDic := Self:retornaCamposUsadosDicionario()
	Local nX         := 0

    Self:defineEngenhariaAbaPosicao()
    Self:defineEngenhariaAbaCampos()

	For nX := 1 To Len(aCamposDic)
		If Self:oPosicaoCampos:HasProperty(aCamposDic[nX][POS_X3_CAMPO])
			Self:defineAtributosDinamicos(Self:oPosicaoCampos[aCamposDic[nX][POS_X3_CAMPO]],aCamposDic[nX])
		EndIf
	Next nX

Return Self:oCampos

/*/{Protheus.doc} defineEngenhariaAbaPosicao
Método para definir a posição dos campos da aba de engenharia no json

@author renan.roeder
@since 30/11/2021
@version P12
@return Nil
/*/
Method defineEngenhariaAbaPosicao() Class ProductionOrderForm

	Self:oPosicaoCampos['C2_ROTEIRO'] := 1
	Self:oPosicaoCampos['C2_CC']      := 2
	Self:oPosicaoCampos['C2_REVISAO'] := 3
	Self:oPosicaoCampos['C2_PRIOR']   := 4

Return

/*/{Protheus.doc} defineEngenhariaAbaCampos
Método para definir atributos estáticos dos campos da aba de engenharia

@author renan.roeder
@since 30/11/2021
@version P12
@return Nil
/*/
Method defineEngenhariaAbaCampos() Class ProductionOrderForm

    Self:oCampos["items"] := Array(Len(Self:oPosicaoCampos:getNames()))

	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]]["property"]                := "C2_ROTEIRO"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "searchService"]          := "/api/pcp/v1/prodOrders/routes"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "params"]                 := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "params"]["product"]      := ""
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "params"]["branchId"]     := ""
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "columns"]                :=  Array(2)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "columns"][1]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "columns"][1]["property"] := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "columns"][1]["label"]    := GetSX3Cache("G2_CODIGO", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "columns"][2]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "columns"][2]["property"] := "PRODUCTID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "columns"][2]["label"]    := GetSX3Cache("G2_PRODUTO", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "format"]                 :=  Array(1)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "format"][1]              := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "fieldLabel"]             := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "fieldValue"]             := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ROTEIRO"]][ "visible"]                := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]]["property"]                := "C2_CC"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "gridColumns"]            := 4
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "searchService"]          := "/api/pcp/v1/prodOrders/costcenter"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "params"]                 := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "params"]["branchId"]     := ""
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "columns"]                :=  Array(2)
    Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "columns"][1]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "columns"][1]["property"] := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "columns"][1]["label"]    := GetSX3Cache("CTT_CUSTO", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "columns"][2]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "columns"][2]["property"] := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "columns"][2]["label"]    := GetSX3Cache("CTT_DESC01", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "format"]                 :=  Array(2)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "format"][1]              := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "format"][2]              := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "fieldLabel"]             := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "fieldValue"]             := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CC"]][ "visible"]                := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_REVISAO"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_REVISAO"]][ "property"]     := "C2_REVISAO"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_REVISAO"]][ "visible"]      := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRIOR"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRIOR"]][ "property"]       := "C2_PRIOR"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PRIOR"]][ "visible"]        := .F.

Return

/*/{Protheus.doc} montaDetalhesAba
Método utilizado para montar o formulario da aba de detalhes da ordem de produção.

@author renan.roeder
@since 30/11/2021
@version P12
@return Self:oCampos, Character, json com o formato correto para ser atribuido ao dynamicform
/*/
Method montaDetalhesAba() Class ProductionOrderForm
	Local aCamposDic := Self:retornaCamposUsadosDicionario()
	Local nX         := 0

    Self:defineDetalhesAbaPosicao()
    Self:defineDetalhesAbaCampos()

	For nX := 1 To Len(aCamposDic)
		If Self:oPosicaoCampos:HasProperty(aCamposDic[nX][POS_X3_CAMPO])
			Self:defineAtributosDinamicos(Self:oPosicaoCampos[aCamposDic[nX][POS_X3_CAMPO]],aCamposDic[nX])
		EndIf
	Next nX

Return Self:oCampos

/*/{Protheus.doc} defineDetalhesAbaPosicao
Método para definir a posição dos campos da aba de detalhes no json

@author renan.roeder
@since 30/11/2021
@version P12
@return Nil
/*/
Method defineDetalhesAbaPosicao() Class ProductionOrderForm

	Self:oPosicaoCampos['C2_GRADE']   := 1
	Self:oPosicaoCampos['C2_ITEMGRD'] := 2
	Self:oPosicaoCampos['C2_PEDIDO']  := 3
	Self:oPosicaoCampos['C2_ITEMPV']  := 4
	Self:oPosicaoCampos['C2_ITEMCTA'] := 5
	Self:oPosicaoCampos['C2_CLVL']    := 6
	Self:oPosicaoCampos['C2_LINHA']   := 7
	Self:oPosicaoCampos['C2_SEQMRP']  := 8
	Self:oPosicaoCampos['C2_PROGRAM'] := 9
	Self:oPosicaoCampos['C2_OPTERCE'] := 10
	Self:oPosicaoCampos['C2_DIASOCI'] := 11
Return

/*/{Protheus.doc} defineDetalhesAbaCampos
Método para definir atributos estáticos dos campos da aba de detalhes

@author renan.roeder
@since 30/11/2021
@version P12
@return Nil
/*/
Method defineDetalhesAbaCampos() Class ProductionOrderForm

	Self:oCampos["items"] := Array(Len(Self:oPosicaoCampos:getNames()))

	Self:oCampos["items"][Self:oPosicaoCampos["C2_GRADE"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_GRADE"]][ "property"]  := 'C2_GRADE'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_GRADE"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_GRADE"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMGRD"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMGRD"]][ "property"]  := 'C2_ITEMGRD'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMGRD"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMGRD"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_PEDIDO"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PEDIDO"]][ "property"]  := 'C2_PEDIDO'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PEDIDO"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PEDIDO"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMPV"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMPV"]][ "property"]  := 'C2_ITEMPV'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMPV"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMPV"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]]["property"]                := "C2_ITEMCTA"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "gridColumns"]            := 4
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "searchService"]          := "/api/pcp/v1/prodOrders/accountingitems"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "params"]                 := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "params"]["branchId"]     := ""
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "columns"]                :=  Array(2)
    Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "columns"][1]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "columns"][1]["property"] := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "columns"][1]["label"]    := GetSX3Cache("CTH_CLVL", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "columns"][2]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "columns"][2]["property"] := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "columns"][2]["label"]    := GetSX3Cache("CTH_DESC01", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "format"]                 :=  Array(2)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "format"][1]              := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "format"][2]              := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "fieldLabel"]             := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "fieldValue"]             := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_ITEMCTA"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]]["property"]                := "C2_CLVL"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "gridColumns"]            := 4
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "searchService"]          := "/api/pcp/v1/prodOrders/valueclassaccountingitems"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "params"]                 := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "params"]["branchId"]     := ""
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "columns"]                :=  Array(2)
    Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "columns"][1]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "columns"][1]["property"] := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "columns"][1]["label"]    := GetSX3Cache("CTD_ITEM", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "columns"][2]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "columns"][2]["property"] := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "columns"][2]["label"]    := GetSX3Cache("CTD_DESC01", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "format"]                 :=  Array(2)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "format"][1]              := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "format"][2]              := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "fieldLabel"]             := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "fieldValue"]             := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CLVL"]][ "visible"] := .F.

    Self:oCampos["items"][Self:oPosicaoCampos["C2_LINHA"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LINHA"]][ "property"]  := 'C2_LINHA'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LINHA"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_LINHA"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEQMRP"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEQMRP"]][ "property"]  := 'C2_SEQMRP'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEQMRP"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_SEQMRP"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_PROGRAM"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PROGRAM"]][ "property"]  := 'C2_PROGRAM'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PROGRAM"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_PROGRAM"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_OPTERCE"]] := JsonObject():New()
    Self:oCampos["items"][Self:oPosicaoCampos["C2_OPTERCE"]][ "property"]  := 'C2_OPTERCE'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_OPTERCE"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_OPTERCE"]][ "visible"] := .F.

	Self:oCampos["items"][Self:oPosicaoCampos["C2_DIASOCI"]] := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_DIASOCI"]][ "property"]  := 'C2_DIASOCI'
	Self:oCampos["items"][Self:oPosicaoCampos["C2_DIASOCI"]][ "gridColumns"]  := 2
	Self:oCampos["items"][Self:oPosicaoCampos["C2_DIASOCI"]][ "visible"] := .F.

Return

/*/{Protheus.doc} montaOutrasInformacoesAba
Método utilizado para montar o formulario da aba de outras informações da ordem de produção.

@author renan.roeder
@since 20/01/2022
@version P12
@return Self:oCampos, Character, json com o formato correto para ser atribuido ao dynamicform
/*/
Method montaOutrasInformacoesAba() Class ProductionOrderForm
	Local aCamposDic := Self:retornaCamposUsadosDicionario()
	Local aOutrasInf := {}
	Local nX         := 0

	Self:defineCabecalhoPosicao()
	Self:defineEngenhariaAbaPosicao()
	Self:defineDetalhesAbaPosicao()

	For nX := 1 To Len(aCamposDic)
		If !Self:oPosicaoCampos:HasProperty(aCamposDic[nX][POS_X3_CAMPO]) .And. aCamposDic[nX][POS_X3_PROPRI] != "U"
			aAdd(aOutrasInf, aCamposDic[nX])
		EndIf
	Next nX

	Self:oPosicaoCampos := JsonObject():New()
	Self:oCampos["items"] := Array(Len(aOutrasInf))
	For nX := 1 To Len(aOutrasInf)
		Self:oCampos["items"][nX]              := JsonObject():New()
		Self:oCampos["items"][nX][ "property"] := aOutrasInf[nX][POS_X3_CAMPO]
		Self:oCampos["items"][nX][ "visible"]  := .F.
		Self:oPosicaoCampos[aOutrasInf[nX][POS_X3_CAMPO]] := nX
		Self:defineAtributosDinamicos(nX, aOutrasInf[nX])
	Next nX
	Self:defineOutrasInformacoesAbaCampos()

	aSize(aCamposDic, 0)
	aSize(aOutrasInf, 0)

Return Self:oCampos

/*/{Protheus.doc} defineOutrasInformacoesAbaCampos
Método para definir atributos estáticos dos campos da aba de outras informações

@author renan.roeder
@since 20/01/2022
@version P12
@return Nil
/*/
Method defineOutrasInformacoesAbaCampos() Class ProductionOrderForm

	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "gridColumns"]            := 4
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "searchService"]          := "/api/pcp/v1/prodOrders/crops"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "params"]                 := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "params"]["branchId"]     := ""
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "columns"]                :=  Array(2)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "columns"][1]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "columns"][1]["property"] := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "columns"][1]["label"]    := GetSX3Cache("NJU_CODSAF", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "columns"][2]             := JsonObject():New()
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "columns"][2]["property"] := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "columns"][2]["label"]    := GetSX3Cache("NJU_DESCRI", "X3_TITULO")
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "format"]                 :=  Array(2)
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "format"][1]              := "ID"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "format"][2]              := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "fieldLabel"]             := "DESCRIPTION"
	Self:oCampos["items"][Self:oPosicaoCampos["C2_CODSAF"]][ "fieldValue"]             := "ID"

Return

