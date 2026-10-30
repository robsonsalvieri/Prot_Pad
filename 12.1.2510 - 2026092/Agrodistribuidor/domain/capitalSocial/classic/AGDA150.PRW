#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "AGDA150.ch"

#DEFINE NAMESPACEAGD totvs.protheus.agrobusiness.agd

/*/{Protheus.doc} AGDA150
Cadastro de Atualização de Juros de Capital Social.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 13/07/2026
/*/
Function AGDA150()
	Local oMBrowse := Nil

	If .Not. TableInDic('NF7')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NF7" )
	oMBrowse:SetDescription( FwSX2Util():GetX2Name("NF7") ) //"Atualização de Juros de Capital Social"
	oMBrowse:AddLegend("NF7_STATUS=='1'","BLUE"   ,X3Combo( "NF7_STATUS", "1" ))
	oMBrowse:AddLegend("NF7_STATUS=='2'","WHITE"  ,X3Combo( "NF7_STATUS", "2" ))
	oMBrowse:AddLegend("NF7_STATUS=='3'","YELLOW" ,X3Combo( "NF7_STATUS", "3" ))
	oMBrowse:AddLegend("NF7_STATUS=='4'","ORANGE" ,X3Combo( "NF7_STATUS", "4" ))
	oMBrowse:AddLegend("NF7_STATUS=='5'","WHITE"  ,X3Combo( "NF7_STATUS", "5" ))
	oMBrowse:AddLegend("NF7_STATUS=='6'","GREEN"  ,X3Combo( "NF7_STATUS", "6" ))
	oMBrowse:AddLegend("NF7_STATUS=='7'","RED"    ,X3Combo( "NF7_STATUS", "7" ))
	oMBrowse:AddLegend("NF7_STATUS=='8'","BLUE"   ,X3Combo( "NF7_STATUS", "8" ))
	oMBrowse:AddLegend("NF7_STATUS=='9'","WHITE"  ,X3Combo( "NF7_STATUS", "9" ))

	If hasSmartX()
		oMBrowse:setSmartX()
	EndIf

	oMBrowse:Activate()

Return Nil


/*/{Protheus.doc} MenuDef
Define as opções disponíveis na rotina de Atualização de Juros
de Capital Social.
@type function
@version 12
@author rodrigo.nsoledade
@since 13/07/2026
@return variant, opcoes de menu
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001  ACTION "VIEWDEF.AGDA150" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0002  ACTION "VIEWDEF.AGDA150" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.AGDA150" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.AGDA150" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0010  ACTION "AGDA150CALC()"   OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE STR0014  ACTION "AGDA150APRV()"   OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE STR0015  ACTION "AGDA150REPR()"   OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE STR0019  ACTION "AGDXHIST('NF7',NF7->NF7_FILIAL+NF7->NF7_CODIGO)"   OPERATION 4 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Define o modelo de dados do cadastro de Atualização de Juros
de Capital Social.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 13/07/2026
@return object, modelo MVC
/*/
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNF7 := FWFormStruct(1, "NF7")
	Local oStructNF4 := FWFormStruct(1, "NF4")
	Local oEvent     := AGDA150EVT():New()

	oModel := MPFormModel():New("AGDA150")

	oModel:AddFields("NF7MASTER", Nil, oStructNF7)
	oModel:AddGrid("NF4DETAIL", "NF7MASTER", oStructNF4)

	oModel:SetRelation("NF4DETAIL", {{"NF4_FILIAL", "xFilial('NF4')"},{"NF4_CODJUR", "NF7_CODIGO"}},NF4->(IndexKey(2))) //NF4_FILIAL+NF4_CODJUR

	oModel:SetPrimaryKey({"NF7_FILIAL", "NF7_CODIGO"})

	oModel:GetModel("NF7MASTER"):SetDescription(STR0005 ) //"Atualização de Juros de Capital Social")
	oModel:GetModel("NF4DETAIL"):SetDescription(STR0006) //"Simulação por Cooperado")
	oModel:GetModel("NF4DETAIL"):SetOptional(.T.)
	oModel:GetModel("NF4DETAIL"):SetUniqueLine({"NF4_CODCOO", "NF4_LOJCOO"})

	oModel:InstallEvent("AGDA150EVT", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Define a interface MVC do cadastro de Atualização de Juros
de Capital Social.
@type function
@version 1.0
@author rodrigo.nsoledade
@since 13/07/2026
@return object, view MVC
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("AGDA150")
	Local oStructNF7 := FWFormStruct(2, "NF7")
	Local oStructNF4 := FWFormStruct(2, "NF4", {|cField| ( AllTrim(cField) ) $ "NF4_CODCOO|NF4_LOJCOO|NF4_MATCOO|NF4_NOMCOO|NF4_QTDCOT|NF4_VLRCAP|NF4_VALIMP|NF4_VALLIQ"})
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField("VIEW_NF7", oStructNF7, "NF7MASTER")
	oView:AddGrid("VIEW_NF4", oStructNF4, "NF4DETAIL")

	oView:CreateHorizontalBox("BOX_NF7", 40)
	oView:CreateHorizontalBox("BOX_NF4", 60)
	oView:SetOwnerView("VIEW_NF7", "BOX_NF7")
	oView:SetOwnerView("VIEW_NF4", "BOX_NF4")
	oView:EnableTitleView("VIEW_NF7",STR0005) //"Atualização de Juros de Capital Social"
	oView:EnableTitleView("VIEW_NF4",STR0006) //"Simulação por Cooperado"

Return oView

/*/{Protheus.doc} AGDA150CALC
Força a Execução do Cálculo de Juros
@type function
@version 12
@author jean.schulze
@since 7/20/2026
@return variant, nil
/*/
Function AGDA150CALC()
	Local oService := NAMESPACEAGD.CalculationInterestCapitalService():New()
	if !oService:hasScheduleConfigurado() .or. MsgNoYes(STR0020,STR0021)
		oService:calcular(NF7->NF7_CODIGO)
		if !oService:isSuccess()
			AGDHELP(STR0011, oService:getMessageError())
		else
			MsgInfo(oService:getResponse(), STR0012)
		endif
	endif	
Return nil

/*/{Protheus.doc} AGDA150APRV
Aprovação do Cálculo de Juros
@type function
@version 12
@author jean.schulze
@since 7/20/2026
@return variant, nil
/*/
Function AGDA150APRV()
	Local oService := NAMESPACEAGD.CalculationInterestCapitalService():New()
	oService:aprovar(NF7->NF7_CODIGO)
	if !oService:isSuccess()
		AGDHELP(STR0013, oService:getMessageError())
	else
		MsgInfo(oService:getResponse(), STR0016)
	endif
Return nil

/*/{Protheus.doc} AGDA150REPR
Reprovação do Cálculo de Juros
@type function
@version 12
@author jean.schulze
@since 7/20/2026
@return variant, nil
/*/
Function AGDA150REPR()
	Local oService := NAMESPACEAGD.CalculationInterestCapitalService():New()
	oService:reprovar(NF7->NF7_CODIGO)
	if !oService:isSuccess()
		AGDHELP(STR0013, oService:getMessageError())
	else
		MsgInfo(oService:getResponse(), STR0016)
	endif
Return nil

/*/{Protheus.doc} AGDA150VTJ
Validação para o campo NF7_TIPMOV via dicionario(SX3) 
@type function
@version 12
@author beatriz.dantas
@since 15/07/2026
@return Logical, .T. se o campo for válido, .F. caso contrário
/*/
Function AGDA150VTJ()
	If !Empty(M->NF7_TIPMOV)
		dbSelectArea("NF5")
		NF5->(dbSetOrder(1)) //NF5_FILIAL+NF5_CODIGO
		If NF5->(dbSeek(xFilial("NF5")+M->NF7_TIPMOV))
			If !(NF5->NF5_TIPO $ "7")
				AGDHELP( STR0002 , STR0025, STR0026 + AllTrim(X3CboxDesc( "NF5_TIPO", "7" )))  //"Tipo de movimentação inválido para inclusão de Juros de Capital." //"Informe uma movimentação do tipo "
				Return .F.
			Endif
		Else
			Return .F. //código informado não existe na NF5
		EndIf
	EndIf
Return .T.
