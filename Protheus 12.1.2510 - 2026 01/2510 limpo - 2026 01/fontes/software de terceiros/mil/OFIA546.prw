
#Include "Protheus.ch"
#include "FWMVCDEF.CH"
#include "OFIA507.CH"

Static oModel01
Static oModelCustom
Static oArrHelper

Static oModelFld

/*/{Protheus.doc} OFIA546
	Importação de remitos e faturas de pedidos

	@author Vinicius Gati & Marcelo Iuspa
	@since 07/11/2024
/*/
Function OFIA546()

	If cPaisLoc == "BRA" .Or. (GetSX3Cache("F1_PROVENT", "X3_TAMANHO") == Nil)
		/*+--------------------------------------------------------------+
		  | Marcelo Iuspa em 06/01/2025                                  |
		  | Rotina não deve ser executada no ambiente BRA (DVARMIL-6874) |
		  +--------------------------------------------------------------+*/
		FMX_HELP("OFIA508NO_BR", STR0047, STR0048)   // "Esta rotina não pode ser executada para esta configuração de país", "Executar em outra configuração de país ou verifique o procedimento"
		Return
	Endif

	Private oConfig := OFJDConfig():New("OFIA546")
	Private oProcImpXML

	FWExecView(STR0001, "OFIA546", MODEL_OPERATION_UPDATE) //"Importação de Faturas e Remitos - América Latina"

Return


/*/{Protheus.doc} ViewDef
	Definicao da view
	
	@type function
	@author Vinicius Gati
	@since 26/10/2024
/*/
static function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1

	oStr1    := oModel01:GetView()
	oStrFld2 := oModelFld:GetView()

	oStr1:RemoveField("ERROR")

	lAnyCustom := OA5070374_TemCamposCustomizados("2", oArrHelper)
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FIELD_BOX'   , oStr1   , 'BASE')

	if lAnyCustom
		oView:CreateHorizontalBox('BOX', 50)
		oView:CreateHorizontalBox('BOX_CUSTOM', 50)

		oView:CreateVerticalBox('BOX_FLDS2' , 100, 'BOX_CUSTOM')
	else
		oView:CreateHorizontalBox('BOX', 100)
		oView:CreateHorizontalBox('BOX_CUSTOM', 0)
	endif

	if OA5070374_TemCamposCustomizados("2", oArrHelper)
		oView:AddField('FIELD_FLDS_2', oStrFld2, 'FIELD_FLDS_2')
		oView:SetOwnerView('FIELD_FLDS_2', 'BOX_FLDS2')
		oView:EnableTitleView('FIELD_FLDS_2', STR0091) //"Campos do Remito"
	endif

	oView:SetOwnerView('FIELD_BOX','BOX')

	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})
	oView:SetUpdateMessage(STR0049, STR0074) //"Concluído" / "Processamento do arquivo finalizado !"

	// Retira o botão de "Salvar e Criar um Novo"
	oView:SetCloseOnOk({||.t.})
	oView:SetAfterOkButton( {|oView| OA5030165_ConsultaErro(oView)})

	oView:AddUserButton(STR0051,'IMPRESSAO', {|| OFIC020("OFIA507","VQL_AGROUP=='OFIA507'",.f.) }) // "Consultar Logs"

return oView

/*/{Protheus.doc} ModelDef
	Definicao do modelo
	
	@type function
	@author Vinicius Gati
	@since 26/10/2024
/*/

static function ModelDef()
	Local oModel
	Local oStr1

	If oModel01 == Nil
		oArrHelper := DMS_ArrayHelper():New()
		oModel01   := OA5460294_GetModel01()
		oModelFld := OA5460214_CamposRemito()
	EndIf

	oStr1 := oModel01:GetModel()
	oStr1:AddTrigger( "LOJA_FORNECEDOR", "PROVINCIA" , {|| .t. }, { |oModel| OA5070175_Trigger() } )

	oStrFld2 := oModelFld:GetModel()

	oModel := MPFormModel():New('OFIA546',,,{ |oModel| OA5070034_Importar(oModel) })
	oModel:SetDescription(STR0002) // "Dados para importação"
	
	oModel:AddFields("BASE",,oStr1,,,{|| Load01Dados() })

	if OA5070374_TemCamposCustomizados("2", oArrHelper)
		oModel:AddFields("FIELD_FLDS_2","BASE",oStrFld2,,,{|| OA5460254_CriaVarRemito() })
		oModel:GetModel("FIELD_FLDS_2"):SetDescription(STR0091) // "Campos do Remito"
		conout("STR0091", STR0091)
	endif
	oModel:GetModel("BASE"):SetDescription(STR0002) //"Dados para importação"

	oModel:SetPrimaryKey({})

return oModel

/*/{Protheus.doc} OA5460294_GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/

Static Function OA5460294_GetModel01()

	Local oMd := OFDMSStruct():New()

	oMd:AddField({;
		{'cTitulo'     , STR0003 },; // "Caminho do arquivo"
		{'cIdField'    , "ARQUIVO" },;
		{'nTamanho'    , 400 },;
		{'bValid'      , { |a,b,c,d| SelecionaArquivo(a,b,c,d) }},;
		{'lObrigat'    , .T. },;
		{'cTooltip'    , STR0004 } ; //"Caminho para o arquivo que será importado"
	})

	oMd:AddFieldDictionary( "VE4" , "VE4_PREFAB" , {;
		{'cIdField' , "MARCA" },;
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_FORNECE" , {;
		{'cIdField' , "FORNECEDOR" },;
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_LOJA" , {;
		{'cIdField' , "LOJA_FORNECEDOR" },;
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SD1" , "D1_TES" , {;
		{'cIdField' , "TES_REMITO" },;
		{'cTitulo'  , STR0096 },; //"TES Remito"
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_SERIE" , {;
		{'cIdField' , "REMITO_SERIE" },;
		{'cTitulo'  , STR0020 },; //"Série do Remito"
		{'lObrigat' , .t. } ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_PROVENT" , {;
		{'cIdField' , "PROVINCIA" },;
		{'lObrigat' , .t. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "CFH" , "CFH_CODIGO" , {;
		{'cIdField'   , "PTOREMITO" },;
		{'cTitulo'    , STR0073 },;
		{'lObrigat'   , .t. },;
		{'lCanChange' , .t. } ;
	})

	oMd:AddFieldDictionary( "SE2" , "E2_NATUREZ" , {;
		{'cIdField' , "NATURAGR" },;
		{'cTitulo'  , STR0097 + " AG " + "Remito" },; //"Natureza"
		{'bValid'   , FWBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. ExistCpo("SED")') }, ;
		{'lObrigat' , .f. } ;
	})

	oMd:AddFieldDictionary( "SE2" , "E2_NATUREZ" , {;
		{'cIdField' , "NATURCTR" },;
		{'cTitulo'  , STR0097 + " CT " + "Remito" },; //"Natureza"
		{'bValid'   , FWBuildFeature(STRUCT_FEATURE_VALID,'Vazio() .Or. ExistCpo("SED")') }, ;
		{'lObrigat' , .f. } ;
	})

	oMd:AddField({;
		{'cTitulo'      , STR0062 },; // "Erro"
		{'cIdField'     , "ERROR" },;
		{'nTamanho'     , 1 },;
		{'aComboValues' , {"0="+STR0060,"1="+STR0061}},; // "NÃO" / "SIM"
		{'lObrigat'     , .F. },;
		{'lWhen'        , .F. },;
		{'cTooltip'     , STR0059 } ; //"Ocorreu erro na importação"
	})

return oMd

/*/{Protheus.doc} OA50300034_SelecionaArquivo

    @author Vinicius Gati
    @since  07/06/2024
/*/
static function SelecionaArquivo(oModel, cField, xValue, xValueAntigo)
	Local oView := FWViewActive()

	cPath := cGetFile("",STR0024,,"",.T.,GETF_LOCALHARD,.T., .T.) // local
	If Empty(cPath)
		Return
	Endif
	oModel:LoadValue(cField, cPath)
	oView:Refresh()
return .t.

/*/{Protheus.doc} VldCampoTela
	validacao dos campos na tela

    @author Vinicius Gati
    @since  07/06/2024
/*/
static function VldCampoTela(oModel, cField, xValue, xValueAntigo)
	Local lRet     := .t.
	Local cSeek    := cvaltochar(xValue)
	If Empty(cSeek)
		Return .t.
	EndIf
	Do Case
		Case cField == "MARCA"
			dbSelectArea("VE1")
			dbSetOrder(1)
			lRet := dbSeek(xFilial("VE1") + cSeek )
		Case cField $ "FORNECEDOR/LOJA_FORNECEDOR"
			If cField == "FORNECEDOR"
				cSeek := cSeek+alltrim(oModel:GetValue("LOJA_FORNECEDOR"))
			Else
				cSeek := oModel:GetValue("FORNECEDOR")+cSeek
			EndIf
			dbSelectArea("SA2")
			dbSetOrder(1)
			lRet := dbSeek(xFilial("SA2") + cSeek )
		Case cField $ "TES_REMITO"
			dbSelectArea("SF4")
			dbSetOrder(1)

			lRet := ( dbSeek(xFilial("SF4") + cSeek ) )

			lTes := MaAvalTes("E",SF4->F4_CODIGO)

			If lRet .and. lTes
				lRet := ( SF4->F4_ESTOQUE == 'S' .and. SF4->F4_DUPLIC == 'N' )
			Else
				lRet := .f.
			endif
	EndCase
return lRet

/*/{Protheus.doc} Load01Dados
	default values for the filter
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
Static Function Load01Dados()
	Local aDados := {}

	AAdd(aDados, Space(400))
	AAdd(aDados, oConfig:GetValue("CFG_MARCA", Left(GetMV("MV_MIL0006") + Space(GetSX3Cache("VE4_PREFAB", "X3_TAMANHO")), GetSX3Cache("VE4_PREFAB", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_FORNECEDOR", Space(GetSX3Cache("A2_COD", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_LOJA_FORNECEDOR", Space(GetSX3Cache("A2_LOJA", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_TES_REMITO", Space(GetSX3Cache("F4_CODIGO", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_REMITO_SERIE", Space(GetSX3Cache("F1_SERIE", "X3_TAMANHO"))))

	If GetSX3Cache("F1_PROVENT", "X3_TAMANHO") <> Nil
		AAdd(aDados, oConfig:GetValue("CFG_PROVINCIA", Space(GetSX3Cache("F1_PROVENT", "X3_TAMANHO"))))
	EndIf

	If GetSX3Cache("CFH_CODIGO", "X3_TAMANHO") <> Nil
		AAdd(aDados, oConfig:GetValue("CFG_PTOREMITO", Space(GetSX3Cache("CFH_CODIGO", "X3_TAMANHO"))))
	EndIf

	//Agricola - Remito
	AAdd(aDados, oConfig:GetValue("CFG_NATURAGR", Space(GetSX3Cache("E2_NATUREZ", "X3_TAMANHO"))))

	//Construction - Remito
	AAdd(aDados, oConfig:GetValue("CFG_NATURCTR", Space(GetSX3Cache("E2_NATUREZ", "X3_TAMANHO"))))

	AAdd(aDados, "0")

Return { aDados, 0 }

/*/{Protheus.doc} OA5460214_CamposRemito
	Campos customizados de 2=Remito (SF1/SD1)
	
	@type function
	@author Andre Luis Almeida
	@since 15/08/2025
/*/

Static Function OA5460214_CamposRemito()
	Local oMd := OFDMSStruct():New()
	Local nX := 1
	Local aFldCus := {}
	
	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "2" })

	for nX := 1 to len(aFldCus)
		jFld := aFldCus[nX]

		lDic := jFld["isDic"]

		if lDic
			oMd:AddFieldDictionary(jFld["alias"], jFld["campo"], {})
		else
			oMd:AddField(OA507284_jToa(jFld))
		endif
	next

return oMd

/*/{Protheus.doc} OA5460254_CriaVarRemito
	Campos customizados de 2=Remito (SF1/SD1)
	
	@type function
	@author Andre Luis Almeida
	@since 15/08/2025
/*/

Static Function OA5460254_CriaVarRemito()
	Local nX := 1
	Local aFldCus := {}
	Local aDados := {}
	Local oArrHelper := DMS_ArrayHelper():New()
	
	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "2" })

	for nX := 1 to len(aFldCus)
		jFld := aFldCus[nX]

		lDic := jFld["isDic"]

		if lDic
			if empty(criavar(jFld["campo"]))
				cCriaVar := Space(GetSX3Cache(jFld["campo"], "X3_TAMANHO"))
				aadd(aDados, cCriaVar)
			else
				aadd(aDados, criavar(jFld["campo"]))
			endif
		else
			aadd(aDados, criavar(jFld["valor_default"]))
		endif
	next

Return { aDados, 0 }
