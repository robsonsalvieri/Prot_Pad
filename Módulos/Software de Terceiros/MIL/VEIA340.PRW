#INCLUDE "VEIA340.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} VEIA340()
	Cadastro de meta de vendas

	@author Daniel Apolinario
	@since 18/06/2024
/*/
Function VEIA340()
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("VER")
	oBrowse:SetDescription(STR0001) // Metas de Venda
	oBrowse:Activate()
Return


/*/{Protheus.doc} MenuDef()
	menuDef

	@author Daniel Apolinario
	@since 18/06/2024
/*/
Static Function MenuDef()
	Local cRotina := "VEIA340"
	Local aRotina := {}

	aRotina := FWMVCMenu(cRotina)
Return aRotina


/*/{Protheus.doc} ModelDef()
	Model Def

	@author Daniel Apolinario
	@since 18/06/2024
/*/
Static Function ModelDef()
	Local oModel
	Local oStruct := FWFormStruct(1, "VER")

	// Adicionando Valid dos campos
	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340001F_ValidVer_CodMar()")
	oStruct:SetProperty('VER_CODMAR', MODEL_FIELD_VALID, bAuxValid)

	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340002F_ValidVer_ModVei()")
	oStruct:SetProperty('VER_MODVEI', MODEL_FIELD_VALID, bAuxValid)

	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340003F_ValidVer_Mes()")
	oStruct:SetProperty('VER_MES', MODEL_FIELD_VALID, bAuxValid)

	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340004F_ValidVer_Ano()")
	oStruct:SetProperty('VER_ANO', MODEL_FIELD_VALID, bAuxValid)

	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340005F_ValidVer_Pe()")
	oStruct:SetProperty('VER_PE', MODEL_FIELD_VALID, bAuxValid)

	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340006F_ValidVer_CodVen()")
	oStruct:SetProperty('VER_CODVEN', MODEL_FIELD_VALID, bAuxValid)
	
	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340007F_ValidVer_Agrupa()")
	oStruct:SetProperty('VER_AGRUPA', MODEL_FIELD_VALID, bAuxValid)

	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340008F_ValidVer_Valor()")
	oStruct:SetProperty('VER_VALOR', MODEL_FIELD_VALID, bAuxValid)

	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID, "Vazio() .or. VA340009F_ValidVer_CodFil()")
	oStruct:SetProperty('VER_CODFIL', MODEL_FIELD_VALID, bAuxValid)


	oModel := MPFormModel():New("VEIA340",/*Pré-Validacao*/,/*Pós-Validacao*/,/*Confirmacao da Gravação*/,/*Cancelamento da Operação*/)

	oModel:AddFields("VERMASTER", /*cOwner*/, oStruct)
	oModel:SetDescription(STR0002) // Modelo de Metas de Venda
	oModel:GetModel():SetDescription(STR0001) // Metas de Venda

	oModel:SetPrimaryKey({"VER_FILIAL", "VER_PREFIX", "VER_ANO", "VER_MES"})

		
	// Relação dos campos
	oModel:AddRules( 'VERMASTER', 'VER_MODVEI', 'VERMASTER', 'VER_CODMAR', 3)

Return oModel


/*/{Protheus.doc} ViewDef()
	View Def

	@author Daniel Apolinario
	@since 18/06/2024
/*/
Static Function ViewDef()
	Local oView 
	Local oModel  := FWLoadModel("VEIA340")
	Local oStruct := FWFormStruct(2, "VER")

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_VER", oStruct, "VERMASTER")
	oView:CreateHorizontalBox("TELA", 100)
	oView:SetOwnerView("VIEW_VER" ,"TELA")
Return oView


/*/{Protheus.doc} VVA340001F_ValidVerCodMar()
    Valid do campo VER_CODMAR
   
    @author Daniel Apolinario
    @since 18/06/2024
/*/
Function VA340001F_ValidVer_CodMar()
    Local cCodMar := FWFldGet("VER_CODMAR")

    VE1->(dbSetOrder(1))
    lRet := VE1->(msSeek(xFilial("VE1") + cCodMar))

	if lRet
		MV_PAR01 := cCodMar
	EndIf
    
return lRet


/*/{Protheus.doc} VA340002F_ValidVer_ModVei()
    Valid do campo VER_MODVEI
   
    @author Daniel Apolinario
    @since 30/04/2024
/*/
Function VA340002F_ValidVer_ModVei()
    Local cModVei := FWFldGet("VER_MODVEI")
    Local cCodMar := FWFldGet("VER_CODMAR")

    VV2->(dbSetOrder(1))
    lRet := VV2->(msSeek(xFilial("VV2") + cCodMar + cModVei))
    
return lRet


/*/{Protheus.doc} VVA340003F_ValidVer_Mes()
    Valid do campo VER_MES
   
    @author Daniel Apolinario
    @since 18/06/2024
/*/
Function VA340003F_ValidVer_Mes()
	Local cMes := FWFldGet("VER_MES")
	Local lRet := .t.

	if  (Val(cMes) < 1 .or. Val(cMes) > 12)
		lRet := .f.
	Else
		cMes := StrZero(val(cMes), 2)
		FWFldPut("VER_MES",cMes,/*nLinha*/,/*oModel*/,.T.,.T.)
	Endif

return lRet


/*/{Protheus.doc} VVA340004F_ValidVerAno()
    Valid do campo VER_ANO
   
    @author Daniel Apolinario
    @since 18/06/2024
/*/
Function VA340004F_ValidVer_Ano()
	Local cAno := FWFldGet("VER_ANO")
	Local lRet := .t.

	cAno := StrZero(val(cAno), 4)

	if val(cAno) < Year(dDataBase)
		lRet := .f.
	Endif
    
return lRet


/*/{Protheus.doc} VA340005F_ValidVer_Pe
	Valid do campo VER_PE

	@author Daniel Apolinario
	@since 18/06/2024
/*/
Function VA340005F_ValidVer_Pe()
	Local lRet	  := .t.
	Local nPtEqui := FWFldGet("VER_PE")

	if !Positivo(nPtEqui)
		lRet := .f.
	EndIf
Return lRet


/*/{Protheus.doc} VA340006F_ValidVer_CodVen()
	Valid do campo VER_CODVEN

	@author Daniel Apolinario
	@since 16/08/2024
/*/
Function VA340006F_ValidVer_CodVen()
	Local cCodVen := FWFldGet("VER_CODVEN")

	SA3->(DBSetOrder(1))
	lRet := SA3->(msSeek(xFilial("SA3") + cCodVen))
Return lRet


/*/{Protheus.doc} VA340007F_ValidVer_Agrupa()
	Valid do campo VER_AGRUPA

	@author Daniel Apolinario
	@since 16/08/2024
/*/
Function VA340007F_ValidVer_Agrupa()
	Local cAgrupa := FWFldGet("VER_AGRUPA")
	Local cChaVX5 := "035" // Agrupadores Metas de Vendas

	VX5->(DBSetOrder(1))
	lRet := VX5->(msSeek(xFilial("VX5") + cChaVX5 + cAgrupa))
Return lRet


/*/{Protheus.doc} VA340008F_ValidVer_Valor
	Valid do campo VER_VALOR

	@author Daniel Apolinario
	@since 18/06/2024
/*/
Function VA340008F_ValidVer_Valor()
	Local lRet	  := .t.
	Local nValor := FWFldGet("VER_VALOR")

	if !Positivo(nValor)
		lRet := .f.
	EndIf
Return lRet


/*/{Protheus.doc} VA340009F_ValidVer_CodFil
	Valid do campo VER_CODFIL

	@author Daniel Apolinario
	@since 18/06/2024
/*/
Function VA340009F_ValidVer_CodFil()
	Local lRet	  := .t.
	Local cCodFil := FWFldGet("VER_CODFIL")

	if !ExistCpo("SM0",cEmpAnt + cCodFil)
		lRet := .f.
	EndIf
Return lRet
