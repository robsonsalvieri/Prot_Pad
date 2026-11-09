#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "AGDA180.ch"

/*/{Protheus.doc} AGDA180
Cadastro de Destinação das Sobras
@type function
@version 12
@author gilson.venturi
@since 27/08/2026
/*/
Function AGDA180()
	Local oMBrowse := Nil

	If !TableInDic('NFE') .or. NF4->(FieldPos("NF4_CODSOB")) <= 0 
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NFE" )
	oMBrowse:SetDescription( FwSX2Util():GetX2Name("NFE") ) //"Destinação das Sobras"
	oMBrowse:AddLegend("NFE_STATUS=='1'","BLUE"   ,X3Combo( "NFE_STATUS", "1" ))
	oMBrowse:AddLegend("NFE_STATUS=='2'","WHITE"  ,X3Combo( "NFE_STATUS", "2" ))
	oMBrowse:AddLegend("NFE_STATUS=='3'","YELLOW" ,X3Combo( "NFE_STATUS", "3" ))
	oMBrowse:AddLegend("NFE_STATUS=='4'","ORANGE" ,X3Combo( "NFE_STATUS", "4" ))
	oMBrowse:AddLegend("NFE_STATUS=='5'","WHITE"  ,X3Combo( "NFE_STATUS", "5" ))
	oMBrowse:AddLegend("NFE_STATUS=='6'","GREEN"  ,X3Combo( "NFE_STATUS", "6" ))
	
	If hasSmartX()
		oMBrowse:setSmartX()
	EndIf

	oMBrowse:Activate()

Return Nil


/*/{Protheus.doc} MenuDef
Define as opções disponíveis na rotina de Destinação das Sobras
@type function
@version 12
@author gilson.venturi
@since 27/08/2026
@return variant, opcoes de menu
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001  ACTION "VIEWDEF.AGDA180" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0002  ACTION "VIEWDEF.AGDA180" OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.AGDA180" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.AGDA180" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Define o modelo de dados do cadastro de Destinação das Sobras
@type function
@version 12
@author gilson.venturi
@since 27/08/2026
@return object, modelo MVC
/*/
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNFE := FWFormStruct(1, "NFE")
	Local oStructNFF := FWFormStruct(1, "NFF")
	Local oStructNF4 := FWFormStruct(1, "NF4")
	Local oEvent     := AGDA180EVT():New()

	oModel := MPFormModel():New("AGDA180")

	oModel:AddFields("NFEMASTER", Nil, oStructNFE)
	oModel:AddGrid("NFFDETAIL", "NFEMASTER", oStructNFF)
	oModel:AddGrid("NF4DETAIL", "NFEMASTER", oStructNF4)

	oModel:SetRelation("NFFDETAIL", {{"NFF_FILIAL", "NFE_FILIAL"},{"NFF_CODIGO", "NFE_CODIGO"}},NFF->(IndexKey(1)))
	oModel:SetRelation("NF4DETAIL", {{"NF4_FILIAL", "NFE_FILIAL"},{"NF4_CODSOB", "NFE_CODIGO"}},NF4->(IndexKey(3)))

	oModel:SetPrimaryKey({"NFE_FILIAL", "NFE_CODIGO"})

	oModel:GetModel("NFEMASTER"):SetDescription(STR0005 ) //"Destinação de Sobras")
	oModel:GetModel("NFFDETAIL"):SetDescription(STR0018) //"Titulos financeiros à pagar
	oModel:GetModel("NFFDETAIL"):SetOptional(.T.)
	oModel:GetModel("NF4DETAIL"):SetDescription(STR0019) //"Cotas de capital Social"
	oModel:GetModel("NF4DETAIL"):SetOptional(.T.)

	oModel:InstallEvent("AGDA180EVT", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Define a interface MVC do cadastro de Destinação das Sobras
@type function
@version 12
@author gilson.venturi
@since 27/08/2026
@return object, view MVC
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("AGDA180")
	Local oStructNFE := FWFormStruct(2, "NFE")
	Local oStructNFF := FWFormStruct(2, "NFF")
	Local oStructNF4 := FWFormStruct(2, "NF4", {|cField| ( AllTrim(cField) ) $ "NF4_CODCOO|NF4_LOJCOO|NF4_MATCOO|NF4_NOMCOO|NF4_QTDCOT|NF4_VLRCAP|NF4_STATUS"})
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
    oStructNFE:RemoveField("NFE_STATUS")
    oStructNFF:RemoveField("NFF_FILIAL")
    oStructNFF:RemoveField("NFF_CODIGO")

	oView:AddField("VIEW_NFE", oStructNFE, "NFEMASTER")
	oView:AddGrid("VIEW_NFF", oStructNFF, "NFFDETAIL")
	oView:AddGrid("VIEW_NF4", oStructNF4, "NF4DETAIL")

    oView:CreateHorizontalBox("BOX_NFE", 50)
	oView:CreateHorizontalBox("BOX_GRID", 50)

	oView:CreateFolder( 'FOLDER_GRID', 'BOX_GRID')

	oView:AddSheet('FOLDER_GRID','FOLDER_NFF',STR0018)
	oView:CreateHorizontalBox( 'BOX_NFF', 100, , , 'FOLDER_GRID', 'FOLDER_NFF')

	oView:AddSheet('FOLDER_GRID','FOLDER_NF4',STR0019)
	oView:CreateHorizontalBox( 'BOX_NF4', 100, , , 'FOLDER_GRID', 'FOLDER_NF4')

	oView:SetOwnerView("VIEW_NFE", "BOX_NFE")
	oView:SetOwnerView('VIEW_NFF','BOX_NFF')
	oView:SetOwnerView('VIEW_NF4','BOX_NF4')

	oView:SetViewProperty('VIEW_NF4', "GRIDSEEK", {.T.})
	oView:SetViewProperty('VIEW_NF4', "GRIDFILTER", {.T.})

	oView:SetViewProperty('VIEW_NFF', "GRIDSEEK", {.T.})
	oView:SetViewProperty('VIEW_NFF', "GRIDFILTER", {.T.})


Return oView

/*/{Protheus.doc} AGDA180CPO
Função para gatilho de campo - dicionario de dados 
@type function
@version  P12
@author gilson.venturi
@since 27/08/2026
@return numeric, % calculado
/*/
Function AGDA180CPO()
    Local cReadVar   := ReadVar()
    Local nResultado := 0

	If "NFE_PRCINT" $ cReadVar
        nResultado := 100 - M->NFE_PRCINT
    elseif "NFE_PRCPGT" $ cReadVar
        nResultado := 100 - M->NFE_PRCPGT
	EndIf

Return nResultado

/*/{Protheus.doc} AGDA180VLD
Validação de campos da tabela NFE via dicionario de dados SX3
@type function
@version  P12
@author gilson.venturi
@since 27/08/2026
@return Logical, Valor .T. ou .F.
/*/
Function AGDA180VLD()
    Local cReadVar   := ReadVar()
    Local lRet 		:= .T.

	If "NFE_ORIGEM" $ cReadVar
		If !ExistCpo('NFB',M->NFE_ORIGEM,1)
			AGDHELP(STR0007,STR0009,STR0010)//"Ajuda","Código origem sobra inválido.","Informe outro código de origem sobra."
			lRet := .F.
		elseif ExistCpo('NFE',M->NFE_ORIGEM+M->NFE_TIPO+M->NFE_ANOREF,2)
			AGDHELP(STR0007,STR0017)//"Ajuda","Já existe registro com esta informação"
			lRet := .F.
		endif
	EndIf

Return lRet

/*/{Protheus.doc} AGDA180MBVL
Validacao de Combo de Baixa
@type function
@version 12
@author gilson.venturi
@since 27/08/2026
@return variant, true se motivo de baixa existe, false caso contrario
/*/
Function AGDA180MBVL()
	Local aMotBx     := ReadMotBx()
	Local aCbxBaixa  := {}
	Local lRet		:= .F.

	/*Cria lista de motivos de baixa*/
	aEval(aMotBx, {|e| aadd(aCbxBaixa, ALLTRIM(Left(e,3))) } )
	if AScanX(aCbxBaixa, M->NFE_MOTBXA ) > 0
		lRet := .T.
	endif
	
Return lRet

/*/{Protheus.doc} AGDA180MBCX
Opções do combo de motivos de baixa
@type function
@version 12
@author gilson.venturi
@since 27/08/2026
@return variant, lista de opcoes
/*/
Function AGDA180MBCX()
	Local aMotBx     := ReadMotBx()
	Local aCbxBaixa  := ""
	aEval(aMotBx, {|e| aCbxBaixa := aCbxBaixa + ALLTRIM(Left(e,3)) + "=" + ALLTRIM(SubStr(e,7,10)) + ";" } )
Return aCbxBaixa
