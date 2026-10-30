#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "AGDA140.ch"

/*/{Protheus.doc} AGDA140
Rotina para registrar abertura de conta de cotas e valores cooperado
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Function AGDA140()
	Local oMBrowse := Nil

	If .Not. TableInDic('NF4')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NF4" )
	oMBrowse:SetDescription( FwSX2Util():GetX2Name("NF4") )  //Movimentações Cotas Cooperados
	oMBrowse:AddLegend("NF4_OPTMOV=='1'","BLUE"   ,X3Combo( "NF5_TIPO", "1" ))
	oMBrowse:AddLegend("NF4_OPTMOV=='2'","GREEN"  ,X3Combo( "NF5_TIPO", "2" ))
	oMBrowse:AddLegend("NF4_OPTMOV=='3'","YELLOW" ,X3Combo( "NF5_TIPO", "3" ))
	oMBrowse:AddLegend("NF4_OPTMOV=='4'","RED"    ,X3Combo( "NF5_TIPO", "4" ))
	oMBrowse:AddLegend("NF4_OPTMOV=='5'","ORANGE" ,X3Combo( "NF5_TIPO", "5" ))
	oMBrowse:AddLegend("NF4_OPTMOV=='6'","GRAY"   ,X3Combo( "NF5_TIPO", "6" ))
	oMBrowse:AddLegend("NF4_OPTMOV=='7'","PINK"   ,X3Combo( "NF5_TIPO", "7" ))

	if hasSmartX()
		oMBrowse:setSmartX()
		oMBrowse:AddFilterSmartX("@ NF4_STATUS = '1'")
	endIf

	oMBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0001 Action 'VIEWDEF.AGDA140' OPERATION 2 ACCESS 0  //"Visualizar"
	ADD OPTION aRotina Title STR0014 Action 'AGDA140TFIN()'  OPERATION 4 ACCESS 0  //"Títulos Financeiros"

Return aRotina

/*/{Protheus.doc} ModelDef
Model do AGDA140
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruNF4  := FwFormStruct( 1, "NF4" )
	Local oEvent     := AGDA140EVT():New()

	oModel := MpFormModel():New( "AGDA140" )
	oModel:SetDescription(  FwSX2Util():GetX2Name("NF4") )  //"Movimentações Cotas Cooperados"

	// Adiciona a field no modelo de dados
	oModel:AddFields( "AGDA140_NF4", , oStruNF4)
	oModel:GetModel( "AGDA140_NF4" ):SetDescription(  FwSX2Util():GetX2Name("NF4") )  //Movimentações Cotas Cooperados
	oModel:SetPrimaryKey( { "NF4_FILIAL", "NF4_CODCOO", "NF4_LOJCOO", "NF4_IDMOV" } )

	oModel:InstallEvent("AGDA140EVT", /*cOwner*/, oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao do Model
@type function
@version 12
@author gilson.venturi
@since 18/06/2026
@return variant, nil
/*/
Static Function ViewDef()
	Local oModel	:= FwLoadModel( "AGDA140" )
	Local oStruNF4  := FwFormStruct( 2, "NF4" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados

	oStruNF4:removeField( "NF4_STATUS" ) // Remove o campo do formulário, pois será exibido apenas no grid
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NF4', oStruNF4, 'AGDA140_NF4' )

	oView:CreateHorizontalBox( 'CABEC', 100 )
	oView:SetOwnerView( 'VIEW_NF4', 'CABEC' )
	oView:EnableTitleView("VIEW_NF4")
	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} AGDA140TFIN
Exibe a Lista de Titulos Financeiros do movimento
@type function
@version 12
@author jean.schulze
@since 7/22/2026
@return variant, nil
/*/
Function AGDA140TFIN()
	SetFunName("AGDA145")
	AGDA145(NF4->NF4_CODCOO, NF4->NF4_LOJCOO, NF4->NF4_IDMOV)
	SetFunName("AGDA140")
Return nil

/*/{Protheus.doc} AGD140FNF5
Filtro consulta padrão(SXB) NF5NF4
@type function
@version 12
@author claudineia.reinert
@since 02/07/2026
@return Character, Filtro da consulta
/*/
Function AGD140FNF5()
	Local lRet := .T.
	If !Empty(M->NF4_OPTMOV) .AND. M->NF4_OPTMOV != NF5->NF5_TIPO
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} AGD140OPT
Retorna as opções para o campo X3_CBOX para o campo NF4_OPTMOV
@type function
@version  P12
@author claudineia.reinert
@since 06/07/2026
@return Character, opções do campo NF4_OPTMOV
/*/
Function AGD140OPT()
	Local cRet := GetSX3Cache("NF5_TIPO","X3_CBOX")
Return cRet

/*/{Protheus.doc} AGD140IBRW
Retorna o valor do campo para o X3_INIBRW
@type function
@version  P12
@author claudineia.reinert
@since 21/08/2026
@param cCampo, character, campo a ser verificado
@return variant, valor para o campo verificado
/*/
FUNCTION AGD140IBRW(cCampo)
	Local cRet := ""

	If Alltrim(cCampo) == "NF4_DEACAO"
		cRet := X3CBOXDESC("NF5_OPEXEC",POSICIONE("NF5",1,XFILIAL("NF5")+NF4->NF4_TIPMOV,"NF5_OPEXEC"))
	EndIf

return cRet
