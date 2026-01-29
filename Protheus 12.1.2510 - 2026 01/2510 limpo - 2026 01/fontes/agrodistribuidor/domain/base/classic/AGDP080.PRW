#Include "protheus.ch"
#Include "fwmvcdef.ch"
#INCLUDE "AGDP080.CH"


/*/{Protheus.doc} AGDP080
Cadastro de Regras Receituário
@type function
@version 12
@author carlos.augusto/jean.schulze
@see (https://jiraproducao.totvs.com.br/browse/DAGRODIST-2253)
@since 28/10/2025
/*/
Function AGDP080()
	Local oBrowse

	Private _cUFSelect    :=''             //Global para uso do Seletor de filial
	Private _cModelSXBNEZ := "MdFieldNEZ"  //Modelo de dados
	Private _cFieldSXBNEZ := "NEZ_LISTUF"  //campo do modelo

    If (.Not. TableInDic('NEY')) .Or. (.Not. TableInDic('NEZ'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

	oBrowse	:= FWMBrowse():New()
	oBrowse:SetAlias("NEY")
	oBrowse:SetDescription(STR0001) //"Regras de Receituário"
	oBrowse:DisableDetails()	
	oBrowse:Activate()
	
Return


/*/{Protheus.doc} MenuDef
MenuDef da Rotina
@author carlos.augusto
@since 28/10/2025
/*/
Static Function MenuDef()
    Local aRotina := {}
    Local cAction := "VIEWDEF.AGDP080"

    ADD OPTION aRotina TITLE STR0002 ACTION cAction OPERATION 2 ACCESS 0  //"Visualizar"
    ADD OPTION aRotina TITLE STR0003 ACTION cAction OPERATION 3 ACCESS 0  //"Incluir"
    ADD OPTION aRotina TITLE STR0004 ACTION cAction OPERATION 4 ACCESS 0  //"Alterar"
    ADD OPTION aRotina TITLE STR0005 ACTION cAction OPERATION 5 ACCESS 0  //"Excluir"

Return aRotina


/*/{Protheus.doc} ModelDef
ModelDef da Rotina
@author carlos.augusto
@since 28/10/2025
/*/
Static Function ModelDef()
	Local oModel 	 := Nil
	Local oStruNEY   := FWFormStruct( 1, 'NEY' )
	Local oStruNEZ   := FWFormStruct( 1, 'NEZ' ) 

    //Cria o modelo 	
	oModel := MPFormModel():New( 'AGDP080')
	oModel:SetDescription( STR0001 ) //"Regras de Receituário"

	// Adiciona a estrutura da Field
	oModel:AddFields( 'MdFieldNEY', /*cOwner*/, oStruNEY )
	
	// Adiciona a estrutura da Grid
	oModel:AddGrid( "MdFieldNEZ", "MdFieldNEY", oStruNEZ)
	oModel:GetModel("MdFieldNEZ"):SetUniqueLine({'NEZ_TES'})

	// Seta relacionamento
	oModel:SetRelation( 'MdFieldNEZ', {{'NEZ_FILIAL', 'fwxFilial("NEZ")'}, {'NEZ_CODREG', 'NEY_CODIGO'}}, NEZ->(IndexKey( 1 ) ) )
	
	oModel:SetPrimaryKey({"NEY_FILIAL", "NEY_CODIGO"})

Return oModel
                                                                                                         

/*/{Protheus.doc} ViewDef
ViewDef da Rotina
@author carlos.augusto
@since 28/10/2025
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel 	:= FWLoadModel('AGDP080')
	Local oStruNEY	:= FWFormStruct(2,'NEY')
	Local oStruNEZ	:= FWFormStruct(2,'NEZ')

	//Instância modelo de visualização
	oView := FwFormView():New()

	//Seta o modelo de dados
	oView:SetModel( oModel )
	oView:SetDescription( STR0001 ) //"Regras de Receituário"

	//Adiciona os campos na estrutura do modelo de dados
	oView:AddField("VIEW_NEY", oStruNEY, "MdFieldNEY")

	//Adiciona ao view um formulário do tipo FWFormGrid
	oView:AddGrid( "VIEW_NEZ", oStruNEZ, "MdFieldNEZ" )

	oView:AddIncrementField("VIEW_NEZ", "NEZ_ITEM")

	//Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "SUPERIOR", 15)
	oView:CreateHorizontalBox( "INFERIOR", 85)

	//Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( "VIEW_NEY", "SUPERIOR" )
	oView:SetOwnerView( "VIEW_NEZ", "INFERIOR" )

Return oView


/*/{Protheus.doc} AGDP080VLD
Valid da rotina
@author carlos.augusto
@since 28/10/2025
/*/
Function AGDP080VLD()
	Local cReadVar  := ReadVar()
	Local oModel    := FwModelActive()
	Local oNEZ		:= oModel:GetModel("MdFieldNEZ")
	Local nX        := 1
	Local aUFsCampo  := {}
	Local lRet     := .T.

	If "NEZ_LISTUF" $ cReadVar
		If !Empty(oNEZ:GetValue("NEZ_LISTUF"))
			aUFsCampo :=   StrTokArr2(oNEZ:GetValue("NEZ_LISTUF"), ";")  

 			aUFsCampo := ASort(aUFsCampo)
			For nX := 2 To Len(aUFsCampo)
				If AllTrim(aUFsCampo[nX]) == AllTrim(aUFsCampo[nX - 1])
					AGDHELP(STR0007, STR0008 + aUFsCampo[nX]+"." ,STR0010) //"UF duplicada""A UF informada está duplicada: ""Verifique a UF informada."
					lRet := .F.
					Exit
				EndIf
			Next

			If lRet
				For nX := 1 To Len(aUFsCampo)
					If !ExistCpo("SX5","12"+aUFsCampo[nX])   //aEstados[nX,3]
						lRet := .F.
						AGDHELP(STR0011, STR0009 + aUFsCampo[nX]+"." ,STR0010) //"UF inválida""A UF informada não existe: ""Verifique a UF informada."
						exit
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf

Return lRet

