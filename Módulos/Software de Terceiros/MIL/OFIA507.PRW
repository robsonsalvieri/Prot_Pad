
#Include "Protheus.ch"
#include "FWMVCDEF.CH"
#include "OFIA507.CH"

Static oModel01
Static oModelCustom
Static oArrHelper

Static oModelFld1
Static oModelFld2
Static oModelFld3
Static oModelFld4

/*/{Protheus.doc} OFIA507
	Importação de remitos e faturas de pedidos

	@author Vinicius Gati & Marcelo Iuspa
	@since 07/11/2024
/*/
Function OFIA507()

	If cPaisLoc == "BRA" .Or. (GetSX3Cache("F1_PROVENT", "X3_TAMANHO") == Nil)
		/*+--------------------------------------------------------------+
		  | Marcelo Iuspa em 06/01/2025                                  |
		  | Rotina não deve ser executada no ambiente BRA (DVARMIL-6874) |
		  +--------------------------------------------------------------+*/
		FMX_HELP("OFIA507NO_BR", STR0047, STR0048)   // "Esta rotina não pode ser executada para esta configuração de país", "Executar em outra configuração de país ou verifique o procedimento"
		Return
	Endif

	Private oConfig := OFJDConfig():New("OFIA507")
	Private cTipArq := "0"
	Private oProcImpXML

	aFatHdStr := {}
	aFatItStr := {}
	aFatRdp := {}
	aRemStr := {}
	OA5070014_LoadLayoutVars()

	FWExecView(STR0001, "OFIA507", MODEL_OPERATION_UPDATE) //"Importação de Faturas e Remitos - América Latina"
Return


function OA5070014_LoadLayoutVars()

	aFatHdStr := {}
	aadd(aFatHdStr, {"TIPO_LINHA"          , 002, Nil }) // "Tipo Registro (01-Cabecera)"
	aadd(aFatHdStr, {"PONTO_VENDA"         , 004, Nil }) // "Pto Venta"
	aadd(aFatHdStr, {"NUMERO_FATURA"       , 008, Nil }) // "Nro Fatura"
	aadd(aFatHdStr, {"DATA_FATURA"         , 010, {|z| Ctod(z) }}) // "Fecha Factura"
	aadd(aFatHdStr, {"TIPO_PEDIDO"         , 003, Nil }) // "Tipo Pedido"
	aadd(aFatHdStr, {"CONCESSIONARIO"      , 005, Nil }) // "Concesionario"     
	aadd(aFatHdStr, {"COTACAO"             , 010, { |z| val(z) }}) // "Cotización del Dólar"
	aadd(aFatHdStr, {"TOTALB_PESOS"        , 015, { |z| val(z) }}) // "Subtotal Bruto en Pesos"
	aadd(aFatHdStr, {"BONIFICACAO"         , 015, { |z| val(z) }}) // "Bonificación en Pesos" 
	aadd(aFatHdStr, {"CAMPO_4"             , 015, { |z| val(z) }}) // "Recargo en Pesos"  
	aadd(aFatHdStr, {"CAMPO_5"             , 015, { |z| val(z) }}) // "Subtotal Neto en Pesos"
	aadd(aFatHdStr, {"IMP_IVA"             , 015, { |z| val(z) }}) // "Importe IVA en Pesos"  
	aadd(aFatHdStr, {"CAMPO_7"             , 015, { |z| val(z) }}) // "Otros Impuestos en Pesos"
	aadd(aFatHdStr, {"CAMPO_8"             , 015, { |z| val(z) }}) // "Percepción IB Pesos"   
	aadd(aFatHdStr, {"CAMPO_9"             , 015, { |z| val(z) }}) // "Percepción IVA Pesos"  
	aadd(aFatHdStr, {"TOTAL_PESOS"         , 015, { |z| val(z) }}) // "Total en Pesos"    
	aadd(aFatHdStr, {"CAMPO_11"            , 015, { |z| val(z) }}) // "Subtotal Bruto en Dólares"
	aadd(aFatHdStr, {"CAMPO_12"            , 015, { |z| val(z) }}) // "Bonificación en Dólares"
	aadd(aFatHdStr, {"CAMPO_13"            , 015, { |z| val(z) }}) // "Recargo en Dólares"
	aadd(aFatHdStr, {"CAMPO_14"            , 015, { |z| val(z) }}) // "Subtotal Neto en Dólares"
	aadd(aFatHdStr, {"CAMPO_15"            , 015, { |z| val(z) }}) // "Importe IVA en Dolares"
	aadd(aFatHdStr, {"CAMPO_16"            , 015, { |z| val(z) }}) // "Otros Impuestos en Dólares"
	aadd(aFatHdStr, {"CAMPO_17"            , 015, { |z| val(z) }}) // "Percepción IB Dólares" 
	aadd(aFatHdStr, {"CAMPO_18"            , 015, { |z| val(z) }}) // "Percepción IVA Dólares"
	aadd(aFatHdStr, {"CAMPO_19"            , 015, { |z| val(z) }}) // "Total en Dólares"
	aadd(aFatHdStr, {"CAMPO_20"            , 001, Nil }) // "Tipo Factura (Letra)"  
	aadd(aFatHdStr, {"CONTA"               , 006, Nil }) // "Tipo Negocio (Casa Central - Sucursal)"
	aadd(aFatHdStr, {"CAMPO_21"            , 100, Nil }) // "Comentarios"
	aadd(aFatHdStr, {"CAMPO_TIPO_PEDIDO_2" , 003, Nil }) // "Tipo Pedido (Sistemma origem)"
	aadd(aFatHdStr, {"CAMPO_22"            , 001, Nil }) // "Carácter Fijo (-)" 
	aadd(aFatHdStr, {"CAMPO_TIPO_PEDIDO_3" , 002, Nil }) // "Tipo Pedido (Comprobante)"
	aadd(aFatHdStr, {"CAMPO_23"            , 001, Nil }) // "Carácter Fijo"     
	
	aFatItStr := {}
	aadd(aFatItStr, { "TIPO_LINHA"           ,  2, Nil }) //Tipo Registro (02-Detalhe)
	aadd(aFatItStr, { "LINHA"                ,  5, Nil }) //Nro Linea
	aadd(aFatItStr, { "NUMERO_PEDIDO"        ,  8, Nil }) //Nro Pedido DNS
	aadd(aFatItStr, { "REMITO"               ,  8, Nil }) //Nro Remito
	aadd(aFatItStr, { "QUANTIDADE"           , 15, { |z| val(z) } }) //Cant. Pedida
	aadd(aFatItStr, { "QTD_RECEBIDA"         , 15, { |z| val(z) } }) //Cant. Enviada
	aadd(aFatItStr, { "PECA"                 , 16, Nil }) //Pieza    
	aadd(aFatItStr, { "PECA_SUBSTITUTA"      , 16, Nil }) //Pieza Substituta
	aadd(aFatItStr, { "CAMPO_1"              , 30, Nil }) //Pieza Descripción
	aadd(aFatItStr, { "CAMPO_2"              , 16, Nil }) //Despacho Aduana
	aadd(aFatItStr, { "PRECO_UNITARIO"       , 15, { |z| val(z) } }) //Precio unitario
	aadd(aFatItStr, { "PRECO_TOTAL"          , 15, { |z| val(z) } }) //Precio total
	aadd(aFatItStr, { "COMMENT"              , 100, Nil }) //Comentarios - Descripción
	aadd(aFatItStr, { "FACTORIG"             , 13 , Nil }) //Factura de referencia NC/ND

	aFatRdp := {}
	aadd(aFatRdp, { "TIPO_LINHA" ,  2, Nil }) //"Tipo Registro (03-Percepciones)"
	aadd(aFatRdp, { "CAMPO_2"    ,  1, Nil }) //"Prov."       
	aadd(aFatRdp, { "CAMPO_3"    , 25, Nil }) //"Percepción"  
	aadd(aFatRdp, { "CAMPO_4"    , 15, {|z| Val(z) }}) //"Percepción en Pesos"
	aadd(aFatRdp, { "CAMPO_5"    , 15, {|z| Val(z) }}) //"Percepción IB Dólares"  

	aRemStr := {}
	aadd(aRemStr, {"REMITO"          , 08, Nil }) //"Nro. de Remito"
	aadd(aRemStr, {"NUMERO_PEDIDO"   , 12, Nil }) //"Nro. de Pedido"
	aadd(aRemStr, {"PECA"            , 16, Nil }) //"Cód. de Pieza"
	aadd(aRemStr, {"DESCRICAO"       , 30, Nil }) //"Desc. Pieza"
	aadd(aRemStr, {"QUANTIDADE"      , 15, { |z| Val(z)} }) //"Cant. Enviada"
	aadd(aRemStr, {"DEALER_CODE"     , 12, Nil }) //"Refer. Dealer"
	aadd(aRemStr, {"CONTA"           , 07, Nil }) //"Cuenta Suc."
	aadd(aRemStr, {"PECA_SUBSTITUTA" , 16, Nil }) //"Cód Pieza Substituta"
return .t.


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
	oStrFld1 := oModelFld1:GetView()
	oStrFld2 := oModelFld2:GetView()
	oStrFld3 := oModelFld3:GetView()
	oStrFld4 := oModelFld4:GetView()

	oStr1:RemoveField("ERROR")

	lAnyCustom := OA5070374_TemCamposCustomizados("1", oArrHelper) .or.;
		OA5070374_TemCamposCustomizados("2", oArrHelper) .or.;
		OA5070374_TemCamposCustomizados("3", oArrHelper) .or.;
		OA5070374_TemCamposCustomizados("4", oArrHelper)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('FIELD_BOX'   , oStr1   , 'BASE')

	if lAnyCustom
		oView:CreateHorizontalBox('BOX', 50)
		oView:CreateHorizontalBox('BOX_CUSTOM', 50)

		oView:CreateVerticalBox('BOX_FLDS1' , 25, 'BOX_CUSTOM')
		oView:CreateVerticalBox('BOX_FLDS2' , 25, 'BOX_CUSTOM')
		oView:CreateVerticalBox('BOX_FLDS3' , 25, 'BOX_CUSTOM')
		oView:CreateVerticalBox('BOX_FLDS4' , 25, 'BOX_CUSTOM')
	else
		oView:CreateHorizontalBox('BOX', 100)
		oView:CreateHorizontalBox('BOX_CUSTOM', 0)
	endif

	if OA5070374_TemCamposCustomizados("1", oArrHelper)
		oView:AddField('FIELD_FLDS_1', oStrFld1, 'FIELD_FLDS_1')
		oView:SetOwnerView('FIELD_FLDS_1', 'BOX_FLDS1')
		oView:EnableTitleView('FIELD_FLDS_1', STR0090) //"Campos da Fatura"
	endif

	if OA5070374_TemCamposCustomizados("2", oArrHelper)
		oView:AddField('FIELD_FLDS_2', oStrFld2, 'FIELD_FLDS_2')
		oView:SetOwnerView('FIELD_FLDS_2', 'BOX_FLDS2')
		oView:EnableTitleView('FIELD_FLDS_2', STR0091) //"Campos do Remito"
	endif

	if OA5070374_TemCamposCustomizados("3", oArrHelper)
		oView:AddField('FIELD_FLDS_3', oStrFld3, 'FIELD_FLDS_3')
		oView:SetOwnerView('FIELD_FLDS_3', 'BOX_FLDS3')
		oView:EnableTitleView('FIELD_FLDS_3', STR0092) //"Campos Nota Crédito"
	endif

	if OA5070374_TemCamposCustomizados("4", oArrHelper)
		oView:AddField('FIELD_FLDS_4', oStrFld4, 'FIELD_FLDS_4')
		oView:SetOwnerView('FIELD_FLDS_4', 'BOX_FLDS4')
		oView:EnableTitleView('FIELD_FLDS_4', STR0093) //"Campos Nota Debito"
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
		oModel01   := OA5070294_GetModel01()
		oModelFld1 := OA5070204_CmpsFatura()
		oModelFld2 := OA5070214_CamposRemito()
		oModelFld3 := OA5070224_CamposNotaCred()
		oModelFld4 := OA5070234_CampoNDeb()
	EndIf

	oStr1 := oModel01:GetModel()
	oStr1:AddTrigger( "LOJA_FORNECEDOR", "PROVINCIA" , {|| .t. }, { |oModel| OA5030175_Trigger() } )

	oStrFld1 := oModelFld1:GetModel()
	oStrFld2 := oModelFld2:GetModel()
	oStrFld3 := oModelFld3:GetModel()
	oStrFld4 := oModelFld4:GetModel()

	oModel := MPFormModel():New('OFIA507',,,{ |oModel| OA5070034_Importar(oModel) })
	oModel:SetDescription(STR0002) // "Dados para importação"
	
	oModel:AddFields("BASE",,oStr1,,,{|| Load01Dados() })

	if OA5070374_TemCamposCustomizados("1", oArrHelper)
		oModel:AddFields("FIELD_FLDS_1","BASE",oStrFld1,,,{|| OA5070244_CriaVarFatura() })
		oModel:GetModel("FIELD_FLDS_1"):SetDescription(STR0090) // "Campos da Fatura"
		conout("STR0090", STR0090)
	endif
	if OA5070374_TemCamposCustomizados("2", oArrHelper)
		oModel:AddFields("FIELD_FLDS_2","BASE",oStrFld2,,,{|| OA5070254_CriaVarRemito() })
		oModel:GetModel("FIELD_FLDS_2"):SetDescription(STR0091) // "Campos do Remito"
		conout("STR0091", STR0091)
	endif
	if OA5070374_TemCamposCustomizados("3", oArrHelper)
		oModel:AddFields("FIELD_FLDS_3","BASE",oStrFld3,,,{|| OA5070264_CriaVarNCredito() })
		oModel:GetModel("FIELD_FLDS_3"):SetDescription(STR0092) // "Campos Nota Crédito"
		conout("STR0092", STR0092)
	endif
	if OA5070374_TemCamposCustomizados("4", oArrHelper)
		oModel:AddFields("FIELD_FLDS_4","BASE",oStrFld4,,,{|| OA5070274_CriaVarNDebito() })
		oModel:GetModel("FIELD_FLDS_4"):SetDescription(STR0093) // "Campos Nota Debito"
		conout("STR0093", STR0093)
	endif

	oModel:GetModel("BASE"):SetDescription(STR0002) //"Dados para importação"

	oModel:SetPrimaryKey({})
return oModel

/*/{Protheus.doc} OA5070294_GetModel01
	Definicao da struct usada no filtro
	
	@type function
	@author Vinicius Gati
	@since 07/06/2024
/*/
Static Function OA5070294_GetModel01()
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
		{'cIdField' , "TES_ENTRADA" },;
		{'cTitulo'  , STR0052 },; //"TES Entrada"
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_SERIE" , {;
		{'cIdField' , "REMITO_SERIE" },;
		{'cTitulo'  , STR0020 },; //"Série do Remito"
		{'lObrigat' , .t. } ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_SERIE" , {;
		{'cIdField' , "FATURA_SERIE" },;
		{'cTitulo'  , STR0053 },; //"Série da Fatura"
		{'lObrigat' , .t. } ;
	})

	oMd:AddFieldDictionary( "SD1" , "D1_TES" , {;
		{'cIdField' , "TES_NFCRED" },;
		{'cTitulo'  , STR0054 },; //"TES Nota Crédito"
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SD1" , "D1_TES" , {;
		{'cIdField' , "TES_NFDEB" },;
		{'cTitulo'  , STR0055 },; //"TES Nota Débito"
		{'lObrigat' , .T. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF1" , "F1_SERIE" , {;
		{'cIdField' , "NOTACD_SERIE" },;
		{'cTitulo'  , STR0056 },; //"Série Nota de Cred/Deb"
		{'lObrigat' , .t. } ;
	})

	oMd:AddFieldDictionary( "SD1" , "D1_COD" , {;
		{'cIdField' , "ITEM_TAXA" },;
		{'cTitulo'  , STR0057 },; //"Cód Item Sobretaxa"
		{'lObrigat' , .t. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SD1" , "D1_TES" , {;
		{'cIdField' , "TES_TAXA" },;
		{'cTitulo'  , STR0058 },; //"TES Item Sobretaxa"
		{'lObrigat' , .t. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
	})

	oMd:AddFieldDictionary( "SF2" , "F2_MOEDA"   , {;
		{"cIdField" , "MOEDA" },;
		{'cTitulo'  , STR0086 },;
		{'lObrigat' , .t. },;
		{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }};
	})

	If cPaisLoc <> "BRA" .AND. (GetSX3Cache("F1_PROVENT", "X3_TAMANHO") <> Nil)
		oMd:AddFieldDictionary( "SF1" , "F1_PROVENT" , {;
			{'cIdField' , "PROVINCIA" },;
			{'lObrigat' , .t. },;
			{'bValid'   , { |a,b,c,d| VldCampoTela(a,b,c,d) }} ;
		})
	Endif

	If cPaisLoc <> "BRA" .AND. (GetSX3Cache("CFH_CODIGO", "X3_TAMANHO") <> Nil)
		oMd:AddFieldDictionary( "CFH" , "CFH_CODIGO" , {;
			{'cIdField'   , "PTOREMITO" },;
			{'cTitulo'    , STR0073 },;
			{'lObrigat'   , .t. },;
			{'lCanChange' , .t. } ;
		})
	Endif

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
		Case cField $ "TES_ENTRADA/TES_NFCRED/TES_NFDEB/TES_TAXA"
			dbSelectArea("SF4")
			dbSetOrder(1)

			lRet := ( dbSeek(xFilial("SF4") + cSeek ) )

			If cField == "TES_NFCRED"
				lTes := MaAvalTes("S",SF4->F4_CODIGO)
			Else
				lTes := MaAvalTes("E",SF4->F4_CODIGO)
			EndIf

			If lRet .and. lTes
				If cField == "TES_ENTRADA"
					lRet := ( SF4->F4_ESTOQUE == 'S' .and. SF4->F4_DUPLIC == 'S' )
				Else // Demais campos de TES
					lRet := ( SF4->F4_ESTOQUE == 'N' .and. SF4->F4_DUPLIC == 'S' )
				endif
			endif
		Case cField == "ITEM_TAXA"
			dbSelectArea("SB1")
			dbSetOrder(1)
			lRet := dbSeek(xFilial("SB1") + cSeek )
		Case cField == "PROVINCIA"
			lRet := ExistCpo("SX5","12"+cSeek)
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
	AAdd(aDados, oConfig:GetValue("CFG_TES_ENTRADA", Space(GetSX3Cache("F4_CODIGO", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_REMITO_SERIE", Space(GetSX3Cache("F1_SERIE", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_FATURA_SERIE", Space(GetSX3Cache("F1_SERIE", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_TES_NFCRED", Space(GetSX3Cache("F4_CODIGO", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_TES_NFDEB", Space(GetSX3Cache("F4_CODIGO", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_NOTACD_SERIE", Space(GetSX3Cache("F1_SERIE", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_ITEM_TAXA", Space(GetSX3Cache("B1_COD", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_TES_TAXA", Space(GetSX3Cache("F4_CODIGO", "X3_TAMANHO"))))
	AAdd(aDados, oConfig:GetValue("CFG_MOEDA", 0 ))
	If GetSX3Cache("F1_PROVENT", "X3_TAMANHO") <> Nil
		AAdd(aDados, oConfig:GetValue("CFG_PROVINCIA", Space(GetSX3Cache("F1_PROVENT", "X3_TAMANHO"))))
	EndIf

	If GetSX3Cache("CFH_CODIGO", "X3_TAMANHO") <> Nil
		AAdd(aDados, oConfig:GetValue("CFG_PTOVNDREM", Space(GetSX3Cache("CFH_CODIGO", "X3_TAMANHO"))))
	EndIf

	AAdd(aDados, "0")

Return { aDados, 0 }

/*/{Protheus.doc} OA5070024_Identifica
	identifica o tipo de arquivo

	@type method
	@author Vinicius Gati
	@since 28/10/2024
/*/
Function OA5070024_Identifica(oModel)
	local cNomArq := alltrim(oModel:GetValue("ARQUIVO"))

	if empty(cNomArq)
		alert(STR0026)//"Selecione um arquivo valido primeiro.")
		return .t.
	endif

	oFile := FWFileReader():New(cNomArq)

    if oFile:Open() .and. oFile:hasLine()
		cLine := oFile:getLine()
		if len(cLine) > 116
			cTipArq := "1" // Fatura
		else
			cTipArq := "2" // Remito
		endif
	endif
	oFile:Close()
Return .t.


/*/{Protheus.doc} OA5070034_Importar
	Importa o arquivo selecionado

	@type method
	@author Vinicius Gati
	@since 28/10/2024
/*/
Function OA5070034_Importar(oModel)

	oProcImpXML := MsNewProcess():New({ |lEnd| OA5070031_ExecutaImportacao(oModel) }, STR0037, "", .f.) //importando
	oProcImpXML:Activate()

Return .t.

Function OA5070031_ExecutaImportacao(oModel)

	oProcImpXML:SetRegua1(3)
	

	oProcImpXML:IncRegua1(STR0070) // "Processando"

	oModelBase := oModel:GetModel("BASE")

	OA5030121_Gravar_Configuracao(oModelBase)

	OA5070024_Identifica(oModelBase)

	cMarca := oModelBase:GetValue("MARCA")
	if empty(cMarca)
		MsgStop(STR0031) //"A marca é obrigatória"
		return .t.
	endif

	// tem pedido jdprism pendente?
	cQuery := " SELECT COUNT(*) FROM "+RetSqlName('SC7')
	cQuery += "  WHERE C7_FILIAL  = '"+xFilial('SC7')+"' "
	cQuery += "    AND C7_PEDFAB  = 'JDPRISM' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	if FM_SQL(cQuery) > 0
		cMsg := STR0032 // "Um pedido importado via jdprism encontras-se pendente, "
		cMsg += STR0033  + chr(13) + chr(10) //"tem certeza que deseja continuar com a importação?"
		cMsg += STR0034 //"Isto pode fazer com que um pedido seja duplicado e o estoque encomendado seja alterado."
		if ! MsgNoYes(cMsg, STR0035) //"Atenção!"
			MsgStop(STR0036)//"Operação cancelada, o pedido pendente pode ser adequado na rotina de Importações JDPRISM (OFINJD44)")
			return .T.
		endif
	endif

	OA5070044_ImportaArquivo(oModel, cMarca, oModelBase:GetValue("ARQUIVO") )

Return .t.


/*/{Protheus.doc} OA5070044_ImportaArquivo
	Importa o arquivo XML realmente e adequa o SC7 conforme

	@type method
	@author Vinicius Gati
	@since 28/10/2024
/*/
Function OA5070044_ImportaArquivo(oModel, cMarca, cFullPathToFile)
	local nX := 1
	local nY := 1
	local oRpmConfig := OFJDRpmConfig():New()
	local cBckFlal := cFilAnt
	Local lErro := .f.
	Local nProc := 0
	Local oModelBase
	Private oLogger := DMS_Logger():New("OFIA507.LOG")

	lSucesso := .f.

	oProcImpXML:IncRegua1(STR0070) // "Processando"

	oModelBase := oModel:GetModel("BASE")

	if cTipArq == "1" // Fatura

		aFaturas := LeFatura(cFullPathToFile)
		aFaturas := oArrHelper:GroupByBlock(aFaturas, { |oFat| oFat["CONTA"] })

		oProcImpXML:SetRegua2(len(aFaturas))
		oProcImpXML:IncRegua2(STR0071) // "Importando faturas..."

		for nX := 1 to len(aFaturas)
			cDealerCode := aFaturas[nX, 1]
			cFilAnt := oRpmConfig:GetFilial(cDealerCode)
			cSegmto := oRpmConfig:oNovaConfiguracao:GetSegmtoByDealerCode(cDealerCode)
			if empty(cSegmto)
				alert(STR0046) //"Processo abortado."
				return .f.
			endif
			for nY := 1 to len(aFaturas[nX, 2])
				lSucesso := OA5070064_importarFaturas(aFaturas[nX, 2, nY], cMarca, oModel, @lErro) // faturas da filial
				if ! lSucesso
					exit
				endif
			next
			if ! lSucesso
				exit
			endif
			nProc++
			oProcImpXML:IncRegua2(STR0071 + " " + cvaltochar(nX) + " / " + cvaltochar(len(aFaturas)))
		next
	else // cTipArq == "2" // Remito

		aRemitos := LeRemito(cFullPathToFile)
		aRemitos := oArrHelper:GroupByBlock(aRemitos, { |jRemito| jRemito["CONTA"] })

		oProcImpXML:SetRegua2(len(aRemitos))
		oProcImpXML:IncRegua2(STR0072) // "Importando remitos..."

		for nX := 1 to len(aRemitos)
			cDealerCode := aRemitos[nX, 1]
			cFilAnt := oRpmConfig:GetFilial(cDealerCode)
			cSegmto := oRpmConfig:oNovaConfiguracao:GetSegmtoByDealerCode(cDealerCode)
			if empty(cSegmto)
				alert(STR0046) //"Processo abortado."
				return .f.
			endif
			lSucesso := OA5070074_importarRemitos(aClone(aRemitos[nX, 2]), oModel, @lErro, cDealerCode)
			if ! lSucesso
				exit
			endif
			nProc++
			oProcImpXML:IncRegua2(STR0072 + " " + cvaltochar(nX) + " / " + cvaltochar(len(aRemitos)))
		next
	endif
	oProcImpXML:IncRegua1(STR0070) // "Processando"

	If lErro
		oModelBase:SetValue("ERROR", "1")
	EndIf

	cFilAnt := cBckFlal

	if ValType(oModelBase) != "U" .and. lSucesso
		oModelBase:LoadValue("ARQUIVO", STR0044 + " " + cFullPathToFile + " " + STR0045)//"importado com sucesso."
	endif
	aLinha := {}
	aDadFat := {}
	oProcImpXML := nil
return .t.

Static Function LeRemito(cFullPathToFile)
	local aRemitos := {}

	oFile := FWFileReader():New(cFullPathToFile)
    if oFile:Open()
		while oFile:hasLine()
			cLinha := oFile:getLine()
			cTipo := left(cLinha, 2)
			aadd(aRemitos, OA5070054_InterpretaLinha(cLinha, aRemStr))
		end do
	endif
Return aRemitos


Static Function LeFatura(cFullPathToFile)
	local aPedidos := {}
	local jLastPed

	oFile := FWFileReader():New(cFullPathToFile)
    if oFile:Open()
		while oFile:hasLine()
			cLinha := oFile:getLine()
			cTipo := left(cLinha, 2)
			if cTipo == "01"
				jLastPed := OA5070054_InterpretaLinha(cLinha, aFatHdStr)
				aadd(aPedidos, jLastPed)
			elseif cTipo == "02"
				if ValType(jLastPed) == "U"
					alert(STR0038) //"Layout de arquivo inválido, impossível continuar.")
					return {}
				endif
				if ValType(jLastPed["ITENS"]) == "U"
					jLastPed["ITENS"] := {}
				endif
				aadd(jLastPed["ITENS"], OA5070054_InterpretaLinha(cLinha, aFatItStr))
			elseif cTipo == "03"
				if ValType(jLastPed) == "U"
					alert(STR0038)
					return {}
				endif
				jLastPed["RODAPE"] := OA5070054_InterpretaLinha(cLinha, aFatRdp)
			endif
		end do
	endif
Return aPedidos

function OA5070054_InterpretaLinha(cLinha, aEstrutura)
	local nX := 1
	local jJson := JsonObject():new()

	for	nX := 1 to len(aEstrutura)
		cAttr := aEstrutura[nX, 1]
		xValue := left(cLinha, aEstrutura[nX, 2])
		if ValType(aEstrutura[nX, 3]) == "B"
			xValue := eval(aEstrutura[nX, 3], xValue)
		endif
		if nX < len(aEstrutura)
			if len(cLinha) - aEstrutura[nX, 2] > 0
				cLinha := right(cLinha, len(cLinha) - aEstrutura[nX, 2]) // cortando a linha pra nao precisar controlar inicio e fim
			endif
		endif
		jJson[cAttr] := xValue
	next
return jJson

/*/{Protheus.doc} OA5070064_importarFaturas
	importar fatura identificando pedido

	@type method
	@author Vinicius Gati
	@since 29/10/2024
/*/
function OA5070064_importarFaturas(jFatura, cMarca, oModel, lErro)
	Local nY := 1
	Local oArrHelper := DMS_ArrayHelper():New()
	Local aItens := jFatura["ITENS"]
	Local lNCred := jFatura["CAMPO_TIPO_PEDIDO_3"] == "NC"
	Local lNDeb  := jFatura["CAMPO_TIPO_PEDIDO_3"] == "ND"
	Local cTpSis := jFatura["CAMPO_TIPO_PEDIDO_2"]
	Local oModelBase := oModel:GetModel("BASE")
	Local cObserv := ""
	Local cNota := PadL( StrTran(jFatura["PONTO_VENDA"] + jFatura["NUMERO_FATURA"],"-",""), GetSX3Cache("F1_DOC","X3_TAMANHO") , "0")
	Local cSerie := If( lNCred .or. lNDeb , oModelBase:GetValue("NOTACD_SERIE") , oModelBase:GetValue("FATURA_SERIE") )
	Local cFunName:= FunName()
	Local cTitLog := ""

	If At("Chasis:",jFatura["CAMPO_21"]) > 0 // Se for uma fatura de veículo desconsidera o registro
		Return .t.
	EndIf

	dbSelectArea("SA2")
	dbSetOrder(1)
	if ! dbSeek(xFilial("SA2") + oModelBase:GetValue("FORNECEDOR") + oModelBase:GetValue("LOJA_FORNECEDOR"))
		MsgStop(STR0039) //"Não foi possível selecionar fornecedor, abortando.")
		return .f.
	endif

	if valFatEx( lNCred, cNota, cSerie, SA2->A2_COD, SA2->A2_LOJA)
		return .t. // nao pode parar importacao, vai ser comum
	endif

	DbSelectArea("VE4")
	nRecnoVE4 := FM_SQL("SELECT R_E_C_N_O_ FROM " + RetSqlName("VE4") + " WHERE VE4_FILIAL = '"+xfilial("VE4")+"' AND VE4_CODFOR = '"+SA2->A2_COD+"' AND VE4_LOJFOR = '"+SA2->A2_LOJA+"' AND VE4_PREFAB = '"+cMarca+"' AND D_E_L_E_T_ = ' ' ")
	If nRecnoVE4 <= 0
		MsgStop(STR0040 + Alltrim(SA2->A2_CGC) +; //"Não foi possível encontrar o cadastro do fornecedor com CNPJ "
			STR0041,STR0035) //" na rotina Parâmetro Marca (OFIPA980). A operação será abortada. Por favor verifique!" 
		Return .f.
	else
		DbGoTo(nRecnoVE4)
	EndIf

	if Empty(SA2->A2_COND) .and. Empty(VE4->VE4_PGTNFP)
		MsgStop(STR0042) //"Nenhuma condição de pagamento detectada, campos lidos: A2_COND e VE4_PGTNFP")
		return .f.
	EndIf

	aPedsFat := oArrHelper:GroupByBlock(aItens, { |jItem| jItem["NUMERO_PEDIDO"] })
	for nY := 1 to len(aPedsFat)
		if ! empty(aPedsFat[nY,1])
			OA5070104_AtuPedido(cMarca, SA2->A2_COD, SA2->A2_LOJA, VE4->VE4_PGTNFP, aPedsFat[nY,1])
		endif
	next

	aItens := oArrHelper:Map(aItens, { |jItemFat| OA5070094_buscPedFat(jItemFat,@cObserv) })

	aCabFactura := {}
	aItsFactura := {}

	lMsErroAuto := .F.

	If lNCRed

		cTitLog := STR0063 // "Nota de Crédito"
		lRet := OA5070145_ArrayNotaCredito( @aCabFactura, @aItsFactura, jFatura, aItens, oModel, cTpSis, cNota, @cObserv )

		if lRet
			SetFunName("MATA466N")
			MsExecAuto({ |x,y,z| MATA466N(x,y,z) }, aCabFactura, aItsFactura, 3)
			SetFunName(cFunName)
			
			if ! lMsErroAuto .and. valFatEx( lNCred, cNota, cSerie, SA2->A2_COD, SA2->A2_LOJA)
				// gravar campos custom
				reclock("SF2", .F.)
				for nY := 1 to len(aCabFactura)
					if left(aCabFactura[nY, 1], 4) == "F2_X"
						&("SF1->"+aCabFactura[nY, 1]) := aCabFactura[nY, 2]
					endif
				next
				SF2->(msUnlock())
			endif

		EndIf

	ElseIf lNDeb

		cTitLog := STR0064 // "Nota de Débito"
		lRet := OA5070155_ArrayNotaDebito( @aCabFactura, @aItsFactura, jFatura, aItens, oModel, cTpSis, cNota, @cObserv )

		if lRet
			SetFunName("MATA466N")
			MsExecAuto({ |x,y,z| MATA466N(x,y,z) }, aCabFactura, aItsFactura, 3)
			SetFunName(cFunName)

			if ! lMsErroAuto .and. valFatEx( lNCred, cNota, cSerie, SA2->A2_COD, SA2->A2_LOJA)
				// gravar campos custom
				reclock("SF1", .F.)
				for nY := 1 to len(aCabFactura)
					if left(aCabFactura[nY, 1], 4) == "F1_X"
						&("SF1->"+aCabFactura[nY, 1]) := aCabFactura[nY, 2]
					endif
				next
				SF1->(msUnlock())
			endif

		EndIf

	Else

		cTitLog := STR0065 // "Fatura Entrada"
		lRet := OA5070135_ArrayDeFatura( @aCabFactura, @aItsFactura, jFatura, aItens, oModel, cNota, @cObserv )

		if lRet
			SetFunName("MATA101N")
			MsExecAuto({ |x,y,z| MATA101N(x,y,z) }, aCabFactura, aItsFactura, 3)
			SetFunName(cFunName)

			if ! lMsErroAuto .and. valFatEx( lNCred, cNota, cSerie, SA2->A2_COD, SA2->A2_LOJA)
				// gravar campos custom
				reclock("SF1", .F.)
				for nY := 1 to len(aCabFactura)
					if left(aCabFactura[nY, 1], 4) == "F1_X"
						&("SF1->"+aCabFactura[nY, 1]) := aCabFactura[nY, 2]
					endif
				next
				SF1->(msUnlock())
			endif

		EndIf

	EndIf

	if lMsErroAuto
		cObserv += MostraErro("\")
	endif

	lErro := !Empty(cObserv)

	If lErro
		oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFIA507'             },;
				{'VQL_TIPO'       , cTitLog               },;
				{'VQL_DADOS'      , cNota                 },;
				{'VQL_FILORI'     , xFilial("SD2")        },;
				{'VQL_MSGLOG'     , cObserv               } ;
		})
	EndIf

return .t.

/*/{Protheus.doc} OA5070074_importarRemitos
	importar Remito

	@type method
	@author Vinicius Gati itag-air.local
	@since 29/10/2024
/*/
function OA5070074_importarRemitos(aImportRem, oModelPrinc, lErro, cDealerCode )
	local nX := 1
	local nY := 1
	// local nZ := 1
	local cNumIte := Repl("0", GetSX3Cache("D1_ITEM", "X3_TAMANHO"))
	Local nVlrIte := 0
	Local cObserv := ""
	Local lContinua := .f.
    Local lRemExist := .f.
	Local aSize   := FWGetDialogSize( oMainWnd )
	Local aNewBot  := {{"Analitic" ,{|| OA5070191_Legenda() },STR0082}} // Legenda
	Local nTamDOC  := GetSX3Cache("F1_DOC","X3_TAMANHO")
	local oArrHelper := DMS_ArrayHelper():New()
	Local aSoRemitos := {}
	Private aVetRem := {}
	Private oTemRem := LoadBitmap( GetResources(), "AVGOIC1" )
	Private oOk := LoadBitmap( GetResources(), "LBTIK" )
	Private oNo := LoadBitmap( GetResources(), "LBNO" )
	Private cCadastro := STR0075+" - "+STR0076+": "+cFilAnt+" - "+STR0077+": "+cDealerCode // Selecionar Remitos para Importação / Filial / Dealer Number
	Private lMarcarRem := .f.

	oModel := oModelPrinc:GetModel("BASE")

	dbSelectArea("SA2")
	dbSetOrder(1)
	if ! dbSeek(xFilial("SA2") + oModel:GetValue("FORNECEDOR") + oModel:GetValue("LOJA_FORNECEDOR"))
		MsgStop(STR0039) //"Não foi possível selecionar fornecedor, abortando.")
		return .f.
	endif

	DbSelectArea("VE4")
	nRecnoVE4 := FM_SQL("SELECT R_E_C_N_O_ FROM " + RetSqlName("VE4") + " WHERE VE4_FILIAL = '"+xfilial("VE4")+"' AND VE4_CODFOR = '"+SA2->A2_COD+"' AND VE4_LOJFOR = '"+SA2->A2_LOJA+"' AND VE4_PREFAB = '"+cMarca+"' AND D_E_L_E_T_ = ' ' ")
	If nRecnoVE4 <= 0
		MsgStop(STR0040 + Alltrim(SA2->A2_CGC) +; //"Não foi possível encontrar o cadastro do fornecedor com CNPJ "
			STR0041,STR0035) //" na rotina Parâmetro Marca (OFIPA980). A operação será abortada. Por favor verifique!" 
		Return .f.
	else
		DbGoTo(nRecnoVE4)
	EndIf

	if Empty(SA2->A2_COND) .and. Empty(VE4->VE4_PGTNFP)
		MsgStop(STR0042) //"Nenhuma condição de pagamento detectada, campos lidos: A2_COND e VE4_PGTNFP")
		return .f.
	EndIf

	if Empty(oModel:GetValue("REMITO_SERIE"))
		MsgStop(STR0043) //"Série do remito é obrigatória, favor preencher para dar andamento.")
		return .f.
	endif

	cTitLog := STR0007 // Remito

	aSoRemitos := oArrHelper:GroupByBlock(aImportRem, { |jRemito| jRemito["REMITO"] })

    // Carregar REMITOS
	for nX := 1 to len(aSoRemitos)
		cRemito := PadL(oModel:GetValue("PTOREMITO")+aSoRemitos[nX, 1],nTamDOC, "0")
        cSerRem := oModel:GetValue("REMITO_SERIE")
		lRemExist := vldRemEx( .f. , cRemito, cSerRem , SA2->A2_COD, SA2->A2_LOJA )
        aAdd(aVetRem,{IIf(lRemExist,2,0),cRemito,cSerRem,IIf(lRemExist,SF1->F1_EMISSAO,dDataBase)})
    Next
    // TELA de SELECAO dos REMITOS
	oDlg507Rem := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro , , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )
		oLBRemitos := TWBrowse():New(1,1,100,100,,,,oDlg507Rem,,,,,{ || OA5070181_seleciona_Remito(oLBRemitos:nAt) , oLBRemitos:Refresh() },,,,,,,.F.,,.T.,,.F.,,,)
		oLBRemitos:AddColumn( TCColumn():New( " " , { || IIf(aVetRem[oLBRemitos:nAt,1]==2,oTemRem,IIf(aVetRem[oLBRemitos:nAt,1]==1,oOk,oNo)) },,,,"LEFT" ,10,.T.,.F.,,,,.F.,) )
		oLBRemitos:AddColumn( TCColumn():New( STR0007 , { || aVetRem[oLBRemitos:nAt,2] } ,,,,"LEFT" ,70,.F.,.F.,,,,.F.,) ) // Remito
		oLBRemitos:AddColumn( TCColumn():New( STR0078 , { || aVetRem[oLBRemitos:nAt,3] } ,,,,"LEFT" ,40,.F.,.F.,,,,.F.,) ) // Serie
		oLBRemitos:AddColumn( TCColumn():New( STR0079 , { || Transform(aVetRem[oLBRemitos:nAt,4],"@D") } ,,,,"LEFT" ,80,.F.,.F.,,,,.F.,) ) // Data
		oLBRemitos:AddColumn( TCColumn():New( STR0016 , { || SA2->A2_COD } ,,,,"LEFT" ,55,.F.,.F.,,,,.F.,) ) // Fornecedor
		oLBRemitos:AddColumn( TCColumn():New( STR0080 , { || SA2->A2_LOJA } ,,,,"LEFT" ,30,.F.,.F.,,,,.F.,) ) // Loja
		oLBRemitos:AddColumn( TCColumn():New( STR0081 , { || SA2->A2_NOME } ,,,,"LEFT" ,150,.F.,.F.,,,,.F.,) ) // Nome
		oLBRemitos:setArray( aVetRem )
		oLBRemitos:bHeaderClick := { |oObj,nCol| IIf( nCol == 1 , ( lMarcarRem := !lMarcarRem , aEval( aVetRem , { |x| x[1] := IIf(x[1]==2,2,IIf(lMarcarRem,1,0)) } ) ) ,Nil) , oLBRemitos:Refresh() }
		oLBRemitos:Align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE MSDIALOG oDlg507Rem ON INIT EnchoiceBar(oDlg507Rem,{|| lContinua := .t. , oDlg507Rem:End() },{|| oDlg507Rem:End() },,aNewBot)

	If !lContinua .or. aScan(aVetRem,{ |x| x[1] == 1 }) == 0 // Se cancelou a tela ou não selecionou nenhum Remito
		return .t.
	EndIf

	aPedRem := {}
	for nX := 1 to len(aImportRem)
		jRemito := aImportRem[nX]
		cRemito := PadL(oModel:GetValue("PTOREMITO")+jRemito["REMITO"],nTamDOC, "0")
		nPosRem := aScan(aVetRem,{ |x| x[1] == 1 .and. x[2] == cRemito })
		If nPosRem > 0
			aAdd(aPedRem,aImportRem[nPosRem])
		EndIf
	Next
	aPedRem := oArrHelper:Map(aPedRem, { |jRemito| OA5070084_buscPedRem(jRemito) })
	//
	aPedsFat := oArrHelper:GroupByBlock(aPedRem, { |jItem| jItem["NUMERO_PEDIDO"] })
	for nX := 1 to len(aPedsFat)
		if ! empty(aPedsFat[nX,1])
			OA5070104_AtuPedido(cMarca, SA2->A2_COD, SA2->A2_LOJA, VE4->VE4_PGTNFP, aPedsFat[nX,1])
		endif
	next

	for nX := 1 to len(aSoRemitos)

        cRemito := aVetRem[nX,2] 
        cSerRem := aVetRem[nX,3]

        If aVetRem[nX,1] <> 1 .or. vldRemEx( .f. , cRemito, cSerRem , SA2->A2_COD, SA2->A2_LOJA )
        	loop
        EndIf

		nTotal  := 0
		aItens  := aSoRemitos[nX, 2]
		
		aCabRemito := {}
		aItsRemito := {}
		cObserv    := ""

		aAdd(aCabRemito, { "F1_EMISSAO" , dDataBase               , Nil })
		if ! Empty(SA2->A2_COND)
			aAdd(aCabRemito, { "F1_COND"    , SA2->A2_COND             , Nil })
		elseif ! Empty(VE4->VE4_PGTNFP)
			aAdd(aCabRemito, { "F1_COND"    , VE4->VE4_PGTNFP          , Nil })
		endif
		aAdd(aCabRemito, { "F1_FORNECE" , SA2->A2_COD             , Nil })
		aAdd(aCabRemito, { "F1_LOJA"    , SA2->A2_LOJA            , Nil })
		aadd(aCabRemito, { "F1_EST"     , SA2->A2_EST             , Nil })
		aAdd(aCabRemito, { "F1_DOC"     , cRemito                 , Nil })
		aAdd(aCabRemito, { "F1_FORMUL"  , "N"                     , Nil })
		aadd(aCabRemito, { "F1_TIPODOC" , " "                     , Nil }) // precisa passar mesmo que em branco pois no fonte do backoffice identifica o tipo da nota usando existencia desse campo
		aadd(aCabRemito, { "F1_TXMOEDA" , criavar("F1_TXMOEDA")   , Nil })
		aadd(aCabRemito, { "F1_PROVENT" , oModel:GetValue("PROVINCIA"), Nil })
		if ! Empty(cSerRem)
			aAdd(aCabRemito, { "F1_SERIE"   , cSerRem, Nil })
		endif

		OA5070354_PreencheArrRemito(@aCabRemito, oModelPrinc, .T., oArrHelper)
		
		for nY := 1 to len(aItens)
			jItemRemito := aItens[nY]

			aD1Data := {}

			dbSelectArea("SB1")
			dbSetOrder(1)
			if alltrim(jItemRemito["PECA"]) != alltrim(jItemRemito["PECA_SUBSTITUTA"])
				dbSeek(xFilial("SB1") + jItemRemito["PECA_SUBSTITUTA"])
			else
				dbSeek(xFilial("SB1") + jItemRemito["PECA"])
			endif

			nVlrIte := 0
			SB5->(DbSetOrder(1) )
			If SB5->(DbSeek( xFilial("SB5") + SB1->B1_COD ) )
				nVlrIte := SB5->B5_PRV2
			EndIf

			cNumIte := SOMA1(cNumIte)
			AADD( aD1Data , { "D1_ITEM"    , cNumIte                                  , Nil } )
			AADD( aD1Data , { "D1_COD"     , SB1->B1_COD                              , Nil } )
			AADD( aD1Data , { "D1_UM"      , SB1->B1_UM                               , Nil } )
			If ! Empty(jItemRemito["C7_NUM"])
				AADD( aD1Data , { "D1_PEDIDO"  , jItemRemito["C7_NUM"]                , Nil } )
			EndIf
			If ! Empty(jItemRemito["C7_ITEM"])
				AADD( aD1Data , { "D1_ITEMPC"  , jItemRemito["C7_ITEM"]               , Nil } )
			endif
			if ! Empty(jItemRemito["C7_LOCAL"])
				AADD( aD1Data , { "D1_LOCAL"   , jItemRemito["C7_LOCAL"]              , Nil } )
			else
				AADD( aD1Data , { "D1_LOCAL"   , SB1->B1_LOCPAD                       , Nil } ) // se nao achou C7 usa o locpad
			endif
			AADD( aD1Data , { "D1_QUANT"   , jItemRemito["QUANTIDADE"]                , Nil } )
			AADD( aD1Data , { "D1_VUNIT"   , nVlrIte                                  , Nil } )
			AADD( aD1Data , { "D1_TOTAL"   , nVlrIte * jItemRemito["QUANTIDADE"]      , Nil } )
			AADD( aD1Data , { "D1_TES"     , oModel:GetValue("TES_ENTRADA")           , Nil } )
			AADD( aD1Data , { "D1_DOC"     , cRemito                                  , Nil } )
			if ! Empty(oModel:GetValue("REMITO_SERIE"))
				AADD(aD1Data, { "D1_SERIE"   , oModel:GetValue("REMITO_SERIE")        , Nil } )
			endif
			aadd(aD1Data, { "D1_PROVENT" , oModel:GetValue("PROVINCIA"), Nil })

			nTotal += nVlrIte * jItemRemito["QUANTIDADE"]

			OA5070354_PreencheArrRemito(@aD1Data, oModelPrinc, .F., oArrHelper)

			aadd(aItsRemito, aclone(aD1Data))
		next
		
		aAdd(aCabRemito, { "F1_VALMERC" , nTotal, Nil })

		lMsErroAuto := .F.
		MsExecAuto({ |x,y,z| MATA102N(x,y,z) }, aCabRemito, aItsRemito, 3)

		if lMsErroAuto
			cObserv += MostraErro("\")
		endif
		if ! lMsErroAuto .and. vldRemEx( .f. , cRemito, cSerRem , SA2->A2_COD, SA2->A2_LOJA )
			// gravar campos custom
			reclock("SF1", .F.)
			for nY := 1 to len(aCabRemito)
				if left(aCabRemito[nY, 1], 4) == "F1_X"
					&("SF1->"+aCabRemito[nY, 1]) := aCabRemito[nY, 2]
				endif
			next
			SF1->(msUnlock())
		endif

		lErro := !Empty(cObserv)

		If lErro
			oLogger:LogToTable({;
					{'VQL_AGROUP'     , 'OFIA507'             },;
					{'VQL_TIPO'       , cTitLog               },;
					{'VQL_DADOS'      , cRemito               },;
					{'VQL_FILORI'     , xFilial("SD1")        },;
					{'VQL_MSGLOG'     , cObserv               } ;
			})
		EndIf

	next

return .t.

/*/{Protheus.doc} vldRemEx
	Verifica se algum remito já está no SF1 para cancelar importação

	@type method
	@author Vinicius Gati
	@since 30/10/2024
/*/
static function vldRemEx(lCredito, cRemito, cSerie, cFornece, cLoja)
return valFatEx(lCredito,cRemito, cSerie, cFornece, cLoja)

/*/{Protheus.doc} valFatEx
	Verifica se algum remito já está no SF1 para cancelar importação

	@type method
	@author Vinicius Gati
	@since 31/10/2024
/*/
static function valFatEx(lCredito, cFatura, cSerie, cFornece, cLoja)

	Local lRetorno := .f.

	Default lCredito := .f.

	If lCredito // Se for nota de crédito deve verificar na SF2
		lRetorno := SF2->(DbSeek( xFilial("SF2") + cFatura + cSerie + cFornece + cLoja ))
	Else
		lRetorno := SF1->(DbSeek( xFilial("SF1") + cFatura + cSerie + cFornece + cLoja ))
	EndIf

return lRetorno

/*/{Protheus.doc} OA5070084_buscPedRem
	Remito não tem informação de linha nem sublinha então vamos tentar encontrar o C7 mais condizente com o recebido
	sabemos que isso pode causar problemas por exp anteriores porém é o que da pra fazer hoje

	Quando não encontra a qtd exata pra baixar pegamos o C7 com a menor diferença da qtdd recebida

	@type method
	@author Vinicius Gati
	@since 30/10/2024
/*/
function OA5070084_buscPedRem(jRemito)
	local cQuery := ""
	local nX := 1
	local oSql := DMS_SqlHelper():New()
	local aServem := {} // a ideia é colocar aqui os pedidos que servem para baixar, ou seja, sao os mais proximos da qtd faltante e recebida
	local aPerfeito := {}
	local oEscolha, oItem
	
	cQuery := " SELECT C7_FILIAL, C7_NUM, C7_ITEM, R_E_C_N_O_ as RECNO, C7_QUANT, "
	cQuery += "        C7_SLITPED, C7_RESIDUO, C7_ENCER, C7_QUJE, C7_LOCAL  "
	cQuery += "   FROM " + RetSqlName("SC7")
	cQuery += "  WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	if ! empty(jRemito["PECA_SUBSTITUTA"]) .and. alltrim(jRemito["PECA_SUBSTITUTA"]) != alltrim(jRemito["PECA"])
		cQuery += "    AND ( C7_PRODUTO = '"+jRemito["PECA"]+"' OR C7_PRODUTO = '"+jRemito["PECA_SUBSTITUTA"]+"' ) "
	else
		cQuery += "    AND C7_PRODUTO = '"+jRemito["PECA"]+"' "
	endif
	cQuery += "    AND C7_PEDFAB = '"+jRemito["NUMERO_PEDIDO"]+"' "
	cQuery += "    AND C7_QUANT >= '"+cvaltochar(jRemito["QUANTIDADE"])+"' "
	cQuery += "    AND C7_RESIDUO = ' ' "
	cQuery += "    AND C7_ENCER   = ' ' "
	cQuery += "    AND C7_QUANT > C7_QUJE "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	aDados := oSql:GetSelect({ ;
		{ 'campos', {"C7_FILIAL", "C7_NUM", "C7_ITEM", "RECNO", "C7_SLITPED", "C7_QUANT", "C7_RESIDUO", "C7_ENCER", "C7_QUJE", "C7_LOCAL"} }, ;
		{ 'query', cQuery } ;
	})
	for nX := 1 to len(aDados) //todo: tratar o substituto de forma melhor, acho que tem que sincronizar o pedido qdo tem substituto, bom de qlqr  jeito nao da pra fazer agora por falta de tempo
		oItem := aDados[nX]
		nFaltante := oItem:GetValue("C7_QUANT") - oItem:GetValue("C7_QUJE", 0)
		
		if nFaltante == jRemito["QUANTIDADE"]
			aadd(aPerfeito, oItem)
		else
			oItem:SetValue("diferenca", nFaltante - jRemito["QUANTIDADE"])
			aadd(aServem, oItem)
		endif
	next

	if len(aPerfeito) >= 1
		oEscolha := aPerfeito[1]
	else
		for nX := 1 to len(aServem)
			oItem := aServem[nX]
			if oItem:GetValue("diferenca", -1) <= 0
				loop
			endif
			if valtype(oEscolha) == "U" .or. oItem:GetValue("diferenca", 999) < oEscolha:Gv("diferenca", 999)
				oEscolha := oItem
			endif
		next
	endif

	if valtype(oEscolha) != "U"
		jRemito["C7_NUM"]   := oEscolha:GetValue("C7_NUM")
		jRemito["C7_ITEM"]  := oEscolha:GetValue("C7_ITEM")
		jRemito["C7_LOCAL"] := oEscolha:GetValue("C7_LOCAL")
	else
		// todo: se nao encontrou C7 o que fazer? logar algo?
	endif
return jRemito

/*/{Protheus.doc} OA5070094_buscPedFat
	Busca pedido da fatura caso não tenha remito associado

	Aqui a linha existe, a sublinha não, acredito que a principio vamos matar a linha e boa

	@type method
	@author Vinicius Gati
	@since 30/10/2024
/*/
Function OA5070094_buscPedFat(jItemFat,cObserv)
	local cQuery := ""
	local nX := 1
	local oSql := DMS_SqlHelper():New()
	local aServem := {} // a ideia é colocar aqui os pedidos que servem para baixar, ou seja, sao os mais proximos da qtd faltante e recebida
	local aPerfeito := {}
	local oEscolha, oItem
	
	If Empty(jItemFat["NUMERO_PEDIDO"])
		Return jItemFat
	EndIf

	cQuery := " SELECT C7_FILIAL, C7_NUM, C7_ITEM, R_E_C_N_O_ as RECNO, C7_QUANT, "
	cQuery += "        C7_SLITPED, C7_RESIDUO, C7_ENCER, C7_QUJE, C7_LOCAL  "
	cQuery += "   FROM " + RetSqlName("SC7")
	cQuery += "  WHERE C7_FILIAL = '" + xFilial("SC7") + "' "
	if ! empty(jItemFat["PECA_SUBSTITUTA"]) .and. alltrim(jItemFat["PECA_SUBSTITUTA"]) != alltrim(jItemFat["PECA"])
		cQuery += "    AND ( C7_PRODUTO = '"+jItemFat["PECA"]+"' OR C7_PRODUTO = '"+jItemFat["PECA_SUBSTITUTA"]+"' ) "
	else
		cQuery += "    AND C7_PRODUTO = '"+jItemFat["PECA"]+"' "
	endif
	cQuery += "    AND C7_PEDFAB = '"+jItemFat["NUMERO_PEDIDO"]+"' "
	cQuery += "    AND C7_RESIDUO = ' ' "
	cQuery += "    AND C7_ENCER   = ' ' "
	cQuery += "    AND C7_QUANT > C7_QUJE "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	aDados := oSql:GetSelect({ ;
		{ 'campos', {"C7_FILIAL", "C7_NUM", "C7_ITEM", "RECNO", "C7_SLITPED", "C7_QUANT", "C7_RESIDUO", "C7_ENCER", "C7_QUJE", "C7_LOCAL"} }, ;
		{ 'query' , cQuery } ;
	})

	for nX := 1 to len(aDados) //todo: tratar o substituto de forma melhor, acho que tem que sincronizar o pedido qdo tem substituto, bom de qlqr  jeito nao da pra fazer agora por falta de tempo
		oItem := aDados[nX]
		nFaltante := oItem:GetValue("C7_QUANT") - oItem:GetValue("C7_QUJE", 0)

		if val(oItem:GetValue("C7_ITEM")) == val(jItemFat["LINHA"])
			aadd(aPerfeito, oItem)
		endif
		
		if nFaltante == jItemFat["QTD_RECEBIDA"]
			aadd(aPerfeito, oItem)
		else
			oItem:SetValue("diferenca", nFaltante - jItemFat["QTD_RECEBIDA"])
			aadd(aServem, oItem)
		endif
	next

	if len(aPerfeito) >= 1
		oEscolha := aPerfeito[1]
	else
		for nX := 1 to len(aServem)
			oItem := aServem[nX]
			if oItem:GetValue("diferenca", -1) <= 0
				loop
			endif

			if valtype(oEscolha) == "U" .or. oItem:GetValue("diferenca", 999) < oEscolha:Gv("diferenca", 999)
				oEscolha := oItem
			endif
		next
	endif

	if valtype(oEscolha) != "U"
		jItemFat["C7_NUM"]   := oEscolha:GetValue("C7_NUM")
		jItemFat["C7_ITEM"]  := oEscolha:GetValue("C7_ITEM")
		jItemFat["C7_LOCAL"] := oEscolha:GetValue("C7_LOCAL")
	else
		// todo: se nao encontrou C7 o que fazer? logar algo?
		cObserv += STR0066 + " ( " + jItemFat["PECA"] + " - " + jItemFat["NUMERO_PEDIDO"] + " )" + chr(13) + chr(10) // "Item não encontrado no pedido de compra "
	endif
return jItemFat

/*/{Protheus.doc} OA5070104_AtuPedido
	Atualiza o pedido com o Jdpoint e antes busca os itens, eu preencho o aVetped 
	aqui pois a regra é um pouco diferente pra argentina visto que a linha
	não parece funcionar bem lá pois não vem na nota

	@type method
	@author Vinicius Gati
	@since 12/11/2024
/*/
Function OA5070104_AtuPedido(cMarca, cForn, cLoja, cCond, cPedFab)
	local cAliasSC7 := GetNextAlias()
	local aVetPed   := {}
	local lProblema := .f.

	cQuery := " SELECT SC7.R_E_C_N_O_ SC7RECNO, SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO, SC7.C7_PEDFAB, "
	cQuery += "        SC7.C7_ITEPED , SC7.C7_QUANT  , SC7.C7_QUJE , SC7.C7_QTDACLA,  "
	cQuery += "        SC7.C7_SLITPED, SC7.C7_RESIDUO, SC7.C7_ENCER, "
	cQuery += "        (SC7.C7_QUANT - SC7.C7_QUJE - SC7.C7_QTDACLA) SALDOPED "
	cQuery += "   FROM " + RetSqlName("SC7") + " SC7 "
	cQuery += "   JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.B1_COD = SC7.C7_PRODUTO  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE "
	cQuery += "        SC7.C7_FILIAL  = '" + xFilial("SC7") + "'  "
	cQuery += "    AND SC7.C7_PEDFAB  = '" + cPedFab        + "'  "
	cQuery += "    AND SC7.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSC7, .T., .T. )
	while !(cAliasSC7)->( Eof() )

		cNumPedC7 := (cAliasSC7)->C7_NUM

		lProblema := (cAliasSC7)->C7_RESIDUO == 'S' .or. (cAliasSC7)->C7_ENCER == 'E' .or. (cAliasSC7)->C7_QUJE <> 0 .or. (cAliasSC7)->C7_QTDACLA <> 0

		aAdd(aVetPed, {;
			(cAliasSC7)->C7_PEDFAB,;
			(cAliasSC7)->C7_PRODUTO,;
			(cAliasSC7)->C7_ITEPED,;
			(cAliasSC7)->C7_NUM,;
			(cAliasSC7)->C7_ITEM,;
			0,;
			(cAliasSC7)->SC7RECNO,;
			IIf( lProblema , "residuo" , "naousado" ) ;
		})
		(cAliasSC7)->(dbSkip())

	End do
	(cAliasSC7)->(dbCloseArea())

	//lOk := OFJD10I( ;
	//	cPedFab    ,; // cPedJD 
	//	cForn      ,; // cFornece 
	//	cLoja      ,; // cLoja 
	//	cCond      ,; // cCondicao 
	//	cMarca     ,; // cCodMarca 
	//	.T.        ,; // lImpXml // isso só serve pra atualizar uma coisa na tela que nao existe aqui, então false
	//	aVetPed    ,; // aVetPed // copiei do 44 mas pra mim nao deveria passar aqui
	//) 
return .f.// lOk

/*/{Protheus.doc} VX0000071_Item_Remito
	Retorna o D1_ITEM e F1_SERIE da origem (ARGENTINA)

@type static function
@author Andre Luis Almeida
@since 26/07/2024
/*/
Function OA5070114_ItemOrigem( cNroDoc , cSerDoc , cCodFor , cLojFor , cB1_COD, cItens )

	Local cQuery := ""
	Local aInfFT := {"",""}
	Local aDados := {}
	local nX     := 1
	local oSql   := DMS_SqlHelper():New()
	local oItem

	Default cNroDoc := ""
	Default cSerDoc := ""
	Default cCodFor := ""
	Default cLojFor := ""
	Default cB1_COD := ""
	Default cItens  := ""

	cQuery := "SELECT F1_SERIE , D1_ITEM "
	cQuery += "  FROM "+RetSqlName("SD1") + " SD1 "
	cQuery += 	" JOIN " +RetSqlName("SF1") + " SF1 "
	cQuery += 		"  ON SF1.F1_FILIAL  = SD1.D1_FILIAL "
	cQuery += 		" AND SF1.F1_DOC     = SD1.D1_DOC "
	cQuery += 		" AND SF1.F1_SERIE   = SD1.D1_SERIE "
	cQuery += 		" AND SF1.F1_FORNECE = SD1.D1_FORNECE "
	cQuery += 		" AND SF1.F1_LOJA    = SD1.D1_LOJA "
	cQuery += 		" AND SF1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD1.D1_FILIAL  = '" + xFilial("SD1") + "'"
	
	cQuery += 	" AND SD1.D1_DOC     = '" + cNroDoc +"'"

	If !Empty(cSerDoc)
		cQuery += 	" AND SD1.D1_SERIE = '" + cSerDoc +"'"
	EndIf

	cQuery += 	" AND SD1.D1_COD     = '" + cB1_COD +"'"
	cQuery += 	" AND SD1.D1_FORNECE = '" + cCodFor +"'"
	cQuery += 	" AND SD1.D1_LOJA    = '" + cLojFor +"'"
	cQuery += 	" AND SD1.D_E_L_E_T_ = ' '"
	
	If !Empty(cItens)
		cQuery += 	" AND " + oSql:Concat( { "SD1.D1_COD" , "SD1.D1_ITEM" }) + " NOT IN (" + cItens + ")"
	EndIf

	aDados := oSql:GetSelect({ ;
		{ 'campos', {"F1_SERIE", "D1_ITEM"} }, ;
		{ 'query' , cQuery } ;
	})

	for nX := 1 to len(aDados) //todo: tratar o substituto de forma melhor, acho que tem que sincronizar o pedido qdo tem substituto, bom de qlqr  jeito nao da pra fazer agora por falta de tempo

		oItem := aDados[nX]

		aInfFT[1] := oItem:GetValue("F1_SERIE")
		aInfFT[2] := oItem:GetValue("D1_ITEM")

		If !Empty(cItens)
			cItens += ","
		EndIf
		cItens += "'" + cB1_COD + oItem:GetValue("D1_ITEM") + "'"

		Exit

	Next

Return aInfFT

/*/{Protheus.doc} OA5070135_ArrayDeFatura
	Retorna o D1_ITEM da Fatura de Origem (ARGENTINA)

@type static function
@author Renato Vinicius
@since 22/04/2025
/*/
Function OA5070135_ArrayDeFatura( aCabFactura, aItsFactura, jFatura, aItens, oModelPrinc, cNota, cObserv )

	local lCabRem := .f.
	Local aD1Data := {}
	Local nY      := 0
	local cNumIte := Repl("0", GetSX3Cache("D1_ITEM", "X3_TAMANHO"))
	local aNfOrig := {}
	local cIteOri := ""
	Local cNumRem := ""
	Local cCodTes := ""
	Local cItens  := ""
	Local oModelBase := oModelPrinc:GetModel("BASE")

	aAdd(aCabFactura, { "F1_EMISSAO" , jFatura["DATA_FATURA"]   , Nil })
	
	if ! Empty(SA2->A2_COND)
		aAdd(aCabFactura, { "F1_COND"    , SA2->A2_COND             , Nil })
	elseif ! Empty(VE4->VE4_PGTNFP)
		aAdd(aCabFactura, { "F1_COND"    , VE4->VE4_PGTNFP          , Nil })
	endif

	aAdd(aCabFactura, { "F1_FORNECE" , SA2->A2_COD                     , Nil })
	aAdd(aCabFactura, { "F1_LOJA"    , SA2->A2_LOJA                    , Nil })
	aAdd(aCabFactura, { "F1_EST"     , SA2->A2_EST                     , Nil })
	aAdd(aCabFactura, { "F1_DOC"     , cNota                           , Nil })
	aAdd(aCabFactura, { "F1_FORMUL"  , "N"                             , Nil })
	aAdd(aCabFactura, { "F1_TIPODOC" , " "                             , Nil }) // precisa passar mesmo que em branco pois no fonte do backoffice identifica o tipo da nota usando existencia desse campo
	aAdd(aCabFactura, { "F1_MOEDA"   , oModelBase:GetValue("MOEDA")    , Nil })
	aAdd(aCabFactura, { "F1_TXMOEDA" , jFatura["COTACAO"]              , Nil })
	aadd(aCabFactura, { "F1_PROVENT" , oModelBase:GetValue("PROVINCIA"), Nil })
	aadd(aCabFactura, { "F1_VALMERC" , jFatura["TOTAL_PESOS"]          , Nil })
	aadd(aCabFactura, { "F1_VALBRUT" , jFatura["TOTALB_PESOS"]         , Nil })
	aadd(aCabFactura, { "F1_VALIMP1" , jFatura["IMP_IVA"]              , Nil })
	aadd(aCabFactura, { "F1_DESCONT" , jFatura["BONIFICACAO"]          , Nil })

	if ! Empty(oModelBase:GetValue("FATURA_SERIE"))
		aAdd(aCabFactura, { "F1_SERIE"   , oModelBase:GetValue("FATURA_SERIE"), Nil })
	endif

	OA5070344_PreencheArrFatura(@aCabFactura, oModelPrinc, .T., oArrHelper)

	aItsFactura := {}

	for nY := 1 to len(aItens)
		jItemPedido := aItens[nY]

		aD1Data := {}

		cNumRem := PadL(oModelBase:GetValue("PTOREMITO")+jItemPedido["REMITO"],GetSX3Cache("F1_DOC","X3_TAMANHO"),"0")

		cCodItem := jItemPedido["PECA"]
		If !Empty(Alltrim(jItemPedido["PECA_SUBSTITUTA"]))
			cCodItem := jItemPedido["PECA_SUBSTITUTA"]
		EndIf

		cCodTes := oModelBase:GetValue("TES_ENTRADA")
		If Empty(cCodItem) // Quando está em branco se trata de uma linha de bonificação
			cCodTes  := oModelBase:GetValue("TES_TAXA")
			cCodItem := oModelBase:GetValue("ITEM_TAXA")
			cNumRem  := "" // O código de Remito vem com 00000000
		EndIf

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + cCodItem )

		cNumIte := SOMA1(cNumIte)
		AADD( aD1Data , { "D1_ITEM"    , cNumIte                                  , Nil })
		AADD( aD1Data , { "D1_COD"     , SB1->B1_COD                              , Nil })
		AADD( aD1Data , { "D1_UM"      , SB1->B1_UM                               , Nil })
		AADD( aD1Data , { "D1_DOC"     , cNota                                    , Nil })
		AADD( aD1Data , { "D1_TES"     , cCodTes                                  , Nil })

		if !Empty(cNumRem)
			/*aNfOrig
				[1] - Série de Origem
				[2] - Sequencial do item na nota de origem
			*/

			aNfOrig := OA5070114_ItemOrigem( cNumRem , oModelBase:GetValue("REMITO_SERIE") , SA2->A2_COD , SA2->A2_LOJA , SB1->B1_COD, @cItens )
			cIteOri := aNfOrig[2]
			
			If !Empty(cIteOri)
				AADD(aD1Data, { "D1_REMITO"  , cNumRem                         , Nil })
				AADD(aD1Data, { "D1_SERIREM" , oModelBase:GetValue("REMITO_SERIE") , Nil })
				AADD(aD1Data, { "D1_ITEMREM" , cIteOri                         , Nil})
				if !lCabRem
					AADD(aCabFactura, { "F1_REMITO", cNumRem                   , Nil })
				endif
				lCabRem := .t.
			Else
				cObserv += STR0067 + " ( " + cNumRem + " - " + SB1->B1_COD + " )" + chr(13) + chr(10) // "Remito informado no item da Fatura não encontrado"
			EndIf
		endif
		If ! Empty(jItemPedido["C7_NUM"])
			AADD( aD1Data , { "D1_PEDIDO"  , jItemPedido["C7_NUM"]                , Nil })
		EndIf
		If ! Empty(jItemPedido["C7_ITEM"])
			AADD( aD1Data , { "D1_ITEMPC"  , jItemPedido["C7_ITEM"]               , Nil })
		endif
		if ! Empty(jItemPedido["C7_LOCAL"])
			AADD( aD1Data , { "D1_LOCAL"   , jItemPedido["C7_LOCAL"]              , Nil })
		else
			AADD( aD1Data , { "D1_LOCAL"   , SB1->B1_LOCPAD                       , Nil }) // se nao achou C7 usa o locpad
		endif
		AADD( aD1Data , { "D1_QUANT"   , jItemPedido["QUANTIDADE"]                , Nil })
		AADD( aD1Data , { "D1_VUNIT"   , Round( jItemPedido["PRECO_TOTAL"] / jItemPedido["QUANTIDADE"] , GetSX3Cache("D1_VUNIT","X3_DECIMAL")) , Nil })
		AADD( aD1Data , { "D1_TOTAL"   , jItemPedido["PRECO_TOTAL"] , Nil })
		aadd( aD1Data , { "D1_PROVENT" , oModelBase:GetValue("PROVINCIA"), Nil })

		OA5070344_PreencheArrFatura(@aD1Data, oModelPrinc, .F., oArrHelper)

		aadd(aItsFactura, aclone(aD1Data))
	next

Return Len(aItsFactura) > 0

/*/{Protheus.doc} OA5070145_ArrayNotaCredito
	Retorna o D1_ITEM da Fatura de Origem (ARGENTINA)

@type static function
@author Renato Vinicius
@since 22/04/2025
/*/
Function OA5070145_ArrayNotaCredito( aCabFactura, aItsFactura, jFatura, aItens, oModel, cTpSis, cNota, cObserv )
	Local aD2Data := {}
	Local nY      := 0
	Local lNGrvFt := .t.
	Local cNroFT  := ""
	Local aNfOrig := {}
	Local cIteOri := ""
	Local cSerOri := ""
	Local oModelBase := oModel:GetModel("BASE")

	aAdd(aCabFactura, { "F2_EMISSAO" , jFatura["DATA_FATURA"]   , Nil })

	if ! Empty(SA2->A2_COND)
		aAdd(aCabFactura, { "F2_COND"    , SA2->A2_COND             , Nil })
	elseif ! Empty(VE4->VE4_PGTNFP)
		aAdd(aCabFactura, { "F2_COND"    , VE4->VE4_PGTNFP          , Nil })
	endif

	aAdd(aCabFactura, { "F2_DOC"     , cNota                       , Nil })
	aAdd(aCabFactura, { "F2_FORMUL"  , "N"                         , Nil })
	aadd(aCabFactura, { "F2_PROVENT" , oModelBase:GetValue("PROVINCIA"), Nil })
	aadd(aCabFactura, { "F2_VALMERC" , jFatura["TOTAL_PESOS"]      , Nil })
	aadd(aCabFactura, { "F2_VALBRUT" , jFatura["TOTALB_PESOS"]     , Nil })
	aadd(aCabFactura, { "F2_VALIMP1" , jFatura["IMP_IVA"]          , Nil })
	aadd(aCabFactura, { "F2_MOEDA"   , oModelBase:GetValue("MOEDA")    , Nil })
	aadd(aCabFactura, { "F2_TXMOEDA" , jFatura["COTACAO"]          , Nil })
	aAdd(aCabFactura, { "F2_CLIENTE" , SA2->A2_COD                 , Nil })
	aAdd(aCabFactura, { "F2_LOJA"    , SA2->A2_LOJA                , Nil })
	aAdd(aCabFactura, { "F2_EST"     , SA2->A2_EST                 , Nil })
	aadd(aCabFactura, { "F2_TIPO"    , "D"                         , Nil })
	aadd(aCabFactura, { "F2_ESPECIE" , 'NCP'                       , Nil })
	aadd(aCabFactura, { "F2_TIPODOC" , "07"                        , Nil })
	aadd(aCabFactura, { "F2_DESCONT" , jFatura["BONIFICACAO"]      , Nil })

	if ! Empty(oModelBase:GetValue("NOTACD_SERIE"))
		aAdd(aCabFactura, { "F2_SERIE"   , oModelBase:GetValue("NOTACD_SERIE"), Nil })
	endif

	OA5070324_PreencheArrIntNotaCredito(@aCabFactura, oModel, .T. /*cabeca?*/)

	for nY := 1 to len(aItens)
		jItemPedido := aItens[nY]

		aD2Data := {}

		If cTpSis == "DNS"
			nPosFT := At("FAC:F460",jItemPedido["COMMENT"]) // Número da nota fiscal de origem que consta no comentário
			If nPosFT > 0
				cNroFT := Subs(jItemPedido["COMMENT"],nPosFT+8,13) // Mais 8 caracteres para que pegue o conteúdo após o FAC:F460
			Else
				Loop
			EndIf
		ElseIf cTpSis == "SAP"
			cNroFT := PadL( StrTran(jItemPedido["FACTORIG"],"-",""), GetSX3Cache("F1_DOC","X3_TAMANHO") , "0") // Número da nota fiscal de origem
		EndIf

		dbSelectArea("SB1")
		dbSetOrder(1)
		if ! empty(alltrim(jItemPedido["PECA_SUBSTITUTA"])) .and. alltrim(jItemPedido["PECA"]) != alltrim(jItemPedido["PECA_SUBSTITUTA"])
			dbSeek(xFilial("SB1") + jItemPedido["PECA_SUBSTITUTA"])
		else
			dbSeek(xFilial("SB1") + jItemPedido["PECA"])
		endif

		/*aNfOrig
			[1] - Série de Origem
			[2] - Sequencial do item na nota de origem
		*/
		aNfOrig := OA5070114_ItemOrigem( cNroFT, , SA2->A2_COD , SA2->A2_LOJA , SB1->B1_COD )
		cSerOri := aNfOrig[1]
		cIteOri := aNfOrig[2]

		AADD( aD2Data , { "D2_COD"     , SB1->B1_COD                              , Nil })
		AADD( aD2Data , { "D2_UM"      , SB1->B1_UM                               , Nil })
		AADD( aD2Data , { "D2_DOC"     , cNota                                    , Nil })
		AADD( aD2Data , { "D2_TES"     , oModelBase:GetValue("TES_NFCRED")        , Nil })
		AADD( aD2Data , { "D2_LOCAL"   , SB1->B1_LOCPAD                           , Nil }) // se nao achou C7 usa o locpad
		AADD( aD2Data , { "D2_QUANT"   , jItemPedido["QUANTIDADE"]                , Nil })
		AADD( aD2Data , { "D2_PRCVEN"  , Round( jItemPedido["PRECO_TOTAL"] / jItemPedido["QUANTIDADE"] , GetSX3Cache("D2_PRCVEN","X3_DECIMAL")) , Nil })
		AADD( aD2Data , { "D2_TOTAL"   , jItemPedido["PRECO_TOTAL"]               , Nil })
		AADD( aD2Data , { "D2_PROVENT" , oModelBase:GetValue("PROVINCIA")         , Nil })

		OA5070324_PreencheArrIntNotaCredito(@aD2Data, oModel, .F. /*cabeca?*/)

		If !Empty(cIteOri)
			If lNGrvFt
				AADD(aCabFactura, { "F2_NFORIG"  , cNroFT    , Nil })
				AADD(aCabFactura, { "F2_SERORIG" , cSerOri   , Nil } )
				lNGrvFt := .f.
			EndIf
			AADD( aD2Data , { "D2_NFORI"   , cNroFT                                   , Nil })
			AADD( aD2Data , { "D2_SERIORI" , cSerOri                                  , Nil })
			AADD( aD2Data , { "D2_ITEMORI" , cIteOri                                  , Nil })
		Else

			cObserv += STR0068 + " ( " + SB1->B1_COD + " - " + cNroFT + " )" + chr(13) + chr(10) //"Item da nota não encontrado na fatura de origem "

		EndIf

		AADD(aItsFactura, aclone(aD2Data))

	next

Return Len(aItsFactura) > 0

/*/{Protheus.doc} OA5070155_ArrayNotaDebito
	Retorna o D1_ITEM da Fatura de Origem (ARGENTINA)

@type static function
@author Renato Vinicius
@since 22/04/2025
/*/
Function OA5070155_ArrayNotaDebito( aCabFactura, aItsFactura, jFatura, aItens, oModel, cTpSis, cNota, cObserv )
	Local aD1Data := {}
	Local nY      := 0
	local lNGrvFt := .t.
	local cNroFT  := ""
	local cSerOri := ""
	Local oModelBase := oModel:GetModel("BASE")

	aAdd(aCabFactura, { "F1_EMISSAO" , jFatura["DATA_FATURA"]   , Nil })

	if ! Empty(SA2->A2_COND)
		aAdd(aCabFactura, { "F1_COND"    , SA2->A2_COND             , Nil })
	elseif ! Empty(VE4->VE4_PGTNFP)
		aAdd(aCabFactura, { "F1_COND"    , VE4->VE4_PGTNFP          , Nil })
	endif

	aAdd(aCabFactura, { "F1_DOC"     , cNota                       , Nil })
	aAdd(aCabFactura, { "F1_FORMUL"  , "N"                         , Nil })
	aadd(aCabFactura, { "F1_PROVENT" , oModelBase:GetValue("PROVINCIA"), Nil })

	aadd(aCabFactura, { "F1_VALMERC" , jFatura["TOTAL_PESOS"]      , Nil })
	aadd(aCabFactura, { "F1_VALBRUT" , jFatura["TOTALB_PESOS"]     , Nil })
	aadd(aCabFactura, { "F1_VALIMP1" , jFatura["IMP_IVA"]          , Nil })
	aadd(aCabFactura, { "F1_MOEDA"   , oModelBase:GetValue("MOEDA")    , Nil })
	aadd(aCabFactura, { "F1_TXMOEDA" , jFatura["COTACAO"]          , Nil })
	aAdd(aCabFactura, { "F1_FORNECE" , SA2->A2_COD                 , Nil })
	aAdd(aCabFactura, { "F1_LOJA"    , SA2->A2_LOJA                , Nil })
	aAdd(aCabFactura, { "F1_EST"     , SA2->A2_EST                 , Nil })
	aadd(aCabFactura, { "F1_TIPO"    , "C"                         , Nil })
	aadd(aCabFactura, { "F1_ESPECIE" , 'NDP'                       , Nil })
	aadd(aCabFactura, { "F1_TIPODOC" , "09"                        , Nil })
	aadd(aCabFactura, { "F1_DESCONT" , jFatura["BONIFICACAO"]      , Nil })

	if ! Empty(oModelBase:GetValue("NOTACD_SERIE"))
		aAdd(aCabFactura, { "F1_SERIE"   , oModelBase:GetValue("NOTACD_SERIE"), Nil })
	endif

	OA5070364_PreencheArrDebito(@aCabFactura, oModel, .T., oArrHelper)

	for nY := 1 to len(aItens)
		jItemPedido := aItens[nY]

		aD1Data := {}

		If cTpSis == "DNS"
			nPosFT := At("FAC:F460",jItemPedido["COMMENT"])// Número da nota fiscal de origem que consta no comentário
			If nPosFT > 0
				cNroFT := Subs(jItemPedido["COMMENT"],nPosFT+8,13) // Mais 8 caracteres para que pegue o conteúdo após o FAC:F460
			Else
				Loop
			EndIf
		ElseIf cTpSis == "SAP"
			cNroFT := PadL( StrTran(jItemPedido["FACTORIG"],"-",""), GetSX3Cache("F1_DOC","X3_TAMANHO") , "0") // Número da nota fiscal de origem
		EndIf

		dbSelectArea("SB1")
		dbSetOrder(1)
		if ! empty(alltrim(jItemPedido["PECA_SUBSTITUTA"])) .and. alltrim(jItemPedido["PECA"]) != alltrim(jItemPedido["PECA_SUBSTITUTA"])
			dbSeek(xFilial("SB1") + jItemPedido["PECA_SUBSTITUTA"])
		else
			dbSeek(xFilial("SB1") + jItemPedido["PECA"])
		endif

		/*aNfOrig
			[1] - Série de Origem
			[2] - Sequencial do item na nota de origem
		*/
		aNfOrig := OA5070114_ItemOrigem( cNroFT, , SA2->A2_COD , SA2->A2_LOJA , SB1->B1_COD )
		cSerOri := aNfOrig[1]
		cIteOri := aNfOrig[2]

		AADD( aD1Data , { "D1_COD"     , SB1->B1_COD                              , Nil })
		AADD( aD1Data , { "D1_UM"      , SB1->B1_UM                               , Nil })
		AADD( aD1Data , { "D1_DOC"     , cNota                                    , Nil })
		AADD( aD1Data , { "D1_TES"     , oModelBase:GetValue("TES_NFDEB")         , Nil })
		AADD( aD1Data , { "D1_LOCAL"   , SB1->B1_LOCPAD                           , Nil }) // se nao achou C7 usa o locpad
		AADD( aD1Data , { "D1_QUANT"   , jItemPedido["QUANTIDADE"]                , Nil })
		AADD( aD1Data , { "D1_VUNIT"   , Round( jItemPedido["PRECO_TOTAL"] / jItemPedido["QUANTIDADE"] , GetSX3Cache("D1_VUNIT","X3_DECIMAL")) , Nil })
		AADD( aD1Data , { "D1_TOTAL"   , jItemPedido["PRECO_TOTAL"]               , Nil })
		AADD( aD1Data , { "D1_PROVENT" , oModelBase:GetValue("PROVINCIA")         , Nil })

		If !Empty(cIteOri)

			If lNGrvFt
				AADD(aCabFactura, { "F1_NFORIG"  , cNroFT    , Nil })
				AADD(aCabFactura, { "F1_SERORIG" , cSerOri   , Nil })
				lNGrvFt := .f.
			EndIf
			AADD( aD1Data , { "D1_NFORI"   , cNroFT                                   , Nil })
			AADD( aD1Data , { "D1_SERIORI" , cSerOri                                  , Nil })
			AADD( aD1Data , { "D1_ITEMORI" , cIteOri                                  , Nil })

		Else

			cObserv += STR0068 + " ( " + SB1->B1_COD + " - " + cNroFT + " )" + chr(13) + chr(10) // "Item da nota não encontrado na fatura de origem "

		EndIf

		OA5070364_PreencheArrDebito(@aD1Data, oModel, .F., oArrHelper)

		AADD(aItsFactura, aclone(aD1Data))

	next

Return Len(aItsFactura) > 0

/*/{Protheus.doc} OA5030121_Gravar_Configuracao
	Salva os dados preenchidos na tela
	
	@type function
	@author Andre Luis Almeida
	@since 28/04/2025
/*/
static function OA5030121_Gravar_Configuracao(oModel)
	Local jJson := JsonObject():New()
	jJson["CFG_MARCA"]           := oModel:GetValue("MARCA")
	jJson["CFG_FORNECEDOR"]      := oModel:GetValue("FORNECEDOR")
	jJson["CFG_LOJA_FORNECEDOR"] := oModel:GetValue("LOJA_FORNECEDOR")
	jJson["CFG_TES_ENTRADA"]     := oModel:GetValue("TES_ENTRADA")
	jJson["CFG_REMITO_SERIE"]    := oModel:GetValue("REMITO_SERIE")
	jJson["CFG_FATURA_SERIE"]    := oModel:GetValue("FATURA_SERIE")
	jJson["CFG_TES_NFCRED"]      := oModel:GetValue("TES_NFCRED")
	jJson["CFG_TES_NFDEB"]       := oModel:GetValue("TES_NFDEB")
	jJson["CFG_NOTACD_SERIE"]    := oModel:GetValue("NOTACD_SERIE")
	jJson["CFG_ITEM_TAXA"]       := oModel:GetValue("ITEM_TAXA")
	jJson["CFG_TES_TAXA"]        := oModel:GetValue("TES_TAXA")
	jJson["CFG_MOEDA"]           := oModel:GetValue("MOEDA")
	jJson["CFG_PROVINCIA"]       := oModel:GetValue("PROVINCIA")
	jJson["CFG_PTOVNDREM"]       := oModel:GetValue("PTOREMITO")

	oConfig:Save(jJson)
return .t.

/*/{Protheus.doc} OA5030165_ConsultaErro
	
	@type function
	@author Renato Vinicius
	@since 02/05/2025
/*/
static function OA5030165_ConsultaErro(oView)

	Local oModel := oView:GetModel()
	Local oModelBase := oModel:GetModel("BASE")

	If oModelBase:GetValue("ERROR") == "1"
		If MsgYesNo(STR0069) // "Houve inconsistencias na importação. Deseja visualizar?"
			OFIC020("OFIA507","@ VQL_AGROUP='OFIA507' AND VQL_DATAI='" + DtoS(dDataBase) + "'",.f.)
		EndIf
	EndIf

Return

/*/{Protheus.doc} OA5030165_ConsultaErro
	
	@type function
	@author Renato Vinicius
	@since 02/05/2025
/*/
Static Function OA5030175_Trigger(oModel)

	Local oModCab := FwModelActive()
	Local cRetorno:= ""

	SA2->(DbSeek(xFilial("SA2")+oModCab:GetValue("BASE","FORNECEDOR")+oModCab:GetValue("BASE","LOJA_FORNECEDOR")))
	cRetorno := SA2->A2_EST

Return cRetorno

/*/{Protheus.doc} OA5070181_seleciona_Remito
	Marca/Desmarca o Remito
	
	@type function
	@author Andre Luis Almeida
	@since 20/06/2025
/*/
Static Function OA5070181_seleciona_Remito(nLinVet)
If aVetRem[oLBRemitos:nAt,1] <> 2 // Pode Marcar/Desmarcar o Remito
	If aVetRem[oLBRemitos:nAt,1] == 0
		aVetRem[oLBRemitos:nAt,1] := 1
	Else
		aVetRem[oLBRemitos:nAt,1] := 0
	EndIf
EndIf
Return

/*/{Protheus.doc} OA5070191_Legenda
	Legenda importação do Remito
	
	@type function
	@author Andre Luis Almeida
	@since 20/06/2025
/*/
Static Function OA5070191_Legenda()
Local aLegenda  := {{ 'AVGOIC1' , STR0083 },; // Já Importado
					{ 'LBNO'    , STR0084 },; // Não selecionado
					{ 'LBTIK'   , STR0085 } } // Selecionado
BrwLegenda(STR0082,"",aLegenda) // Legenda Remito
Return

/*/{Protheus.doc} OA5070204_CmpsFatura
	Campos customizados de 1=Fatura (SF1/SD1)
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
/*/
Static Function OA5070204_CmpsFatura()
	Local oMd := OFDMSStruct():New()
	Local nX := 1
	Local aFldCus := {}
	
	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "1" })

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

/*/{Protheus.doc} OA5070214_CamposRemito
	Campos customizados de 2=Remito (SF1/SD1)
	
	@type function
	@author Andre Luis Almeida
	@since 15/08/2025
/*/
Static Function OA5070214_CamposRemito()
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

/*/{Protheus.doc} OA5070224_CamposNotaCred
	Campos customizados de 3=Nota Credito (SF2/SD2)
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
/*/
Static Function OA5070224_CamposNotaCred()
	Local oMd := OFDMSStruct():New()
	Local nX := 1
	Local aFldCus := {}
	
	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "3" })

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

/*/{Protheus.doc} OA5070234_CampoNDeb
	Campos customizados de 4=Nota Debito (SF1/SD1)
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
/*/
Static Function OA5070234_CampoNDeb()
	Local oMd := OFDMSStruct():New()
	Local nX := 1
	Local aFldCus := {}
	
	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "4" })

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

Static Function OA5070244_CriaVarFatura()
	Local nX := 1
	Local aFldCus := {}
	Local aDados := {}
	
	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "1" })

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

Static Function OA5070254_CriaVarRemito()
	Local nX := 1
	Local aFldCus := {}
	Local aDados := {}
	
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

Static Function OA5070264_CriaVarNCredito()
	Local nX := 1
	Local aFldCus := {}
	Local aDados := {}
	
	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "3" })

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

Static Function OA5070274_CriaVarNDebito()
	Local nX := 1
	Local aFldCus := {}
	Local aDados := {}
	
	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == "4" })

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

/*/{Protheus.doc} OA507284_jToa
	Transforma json em array pra deixar padrao o PE criado se for campo de dicionario ou customizado
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
/*/
Static Function OA507284_jToa(jObject)
	local nX := 1
	local aArrayCampo := {}

	if valtype(jObject) != "J"
		FMX_HELP("OFIA507JTOA", STR0062/*"Erro"*/, STR0087 /*"Campo customizado está configurado errado no ponto de entrada, caso não seja dicionário precisa ter dados compativeis com FWFormModelStruct com tipo JsonObject"*/)
	endif

	aAtributos := jObject:GetNames()

	for nX := 1 to len(aAtributos)
		cName := aAtributos[nX]
		aadd(aArrayCampo, { cName , jObject[cName] })
	next
return  aData

/*{Protheus.doc} OA5070344_PreencheArrFatura
	Preenche o array de integracao com os campos customizados

	aArrInt é o array com os dados
	oModel é o model da tela que contem os dados
	Parametro lCab é pra saber se precisa da cabeca ou dos itens
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
*/
Function OA5070344_PreencheArrFatura(aArrInt, oModel, lCab, oArrHelper)
	Default lCab := .f.
	Default oArrHelper := DMS_ArrayHelper():New()

	if lCab
		OA5070334_IntegracaoCustomizados(@aArrInt, oModel, "1", "SF1", "F1_", oArrHelper)
	else
		OA5070334_IntegracaoCustomizados(@aArrInt, oModel, "1", "SD1", "D1_", oArrHelper)
	endif
return

/*{Protheus.doc} OA5070354_PreencheArrRemito
	Preenche o array de integracao com os campos customizados

	aArrInt é o array com os dados
	oModel é o model da tela que contem os dados
	Parametro lCab é pra saber se precisa da cabeca ou dos itens
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
*/
Function OA5070354_PreencheArrRemito(aArrInt, oModel, lCab, oArrHelper)
	Default lCab := .f.
	Default oArrHelper := DMS_ArrayHelper():New()

	if lCab
		OA5070334_IntegracaoCustomizados(@aArrInt, oModel, "2", "SF1", "F1_", oArrHelper)
	else
		OA5070334_IntegracaoCustomizados(@aArrInt, oModel, "2", "SD1", "D1_", oArrHelper)
	endif
return

/*{Protheus.doc} OA5070364_PreencheArrDebito
	Preenche o array de integracao com os campos customizados

	aArrInt é o array com os dados
	oModel é o model da tela que contem os dados
	Parametro lCab é pra saber se precisa da cabeca ou dos itens
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
*/
Function OA5070364_PreencheArrDebito(aArrInt, oModel, lCab, oArrHelper)
	Default lCab := .f.
	Default oArrHelper := DMS_ArrayHelper():New()

	if lCab
		OA5070334_IntegracaoCustomizados(@aArrInt, oModel, "4", "SF1", "F1_", oArrHelper)
	else
		OA5070334_IntegracaoCustomizados(@aArrInt, oModel, "4", "SD1", "D1_", oArrHelper)
	endif
return

/*{Protheus.doc} OA5070324_PreencheArrIntNotaCredito
	Preenche o array de integracao com os campos customizados

	aArrInt é o array com os dados
	oModel é o model da tela que contem os dados
	Parametro lCab é pra saber se precisa da cabeca ou dos itens
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
*/
Function OA5070324_PreencheArrIntNotaCredito(aArrInt, oModel, lCab, oArrHelper)
	Default lCab := .f.
	Default oArrHelper := DMS_ArrayHelper():New()

	if lCab
		OA5070334_IntegracaoCustomizados(@aArrInt, oModel, "3", "SF2", "F2_", oArrHelper)
	else
		OA5070334_IntegracaoCustomizados(@aArrInt, oModel, "3", "SD2", "D2_", oArrHelper)
	endif
return

/*{Protheus.doc} OA5070334_IntegracaoCustomizados
	Preenche o array de integracao com os campos customizados

	aArrInt é o array com os dados
	oModel é o model da tela que contem os dados
	cTipo é a integracao sendo de 1 a 4
	cAlias, cPrefix sao os campos que definem a tabela que vai ser preenchida
	
	@type function
	@author Vinicius Gati
	@since 15/08/2025
*/
Function OA5070334_IntegracaoCustomizados(aArrInt, oModel, cTipo, cAlias, cPrefix, oArrHelper)
	local nX := 1
	local oModelFlds
	local aFldCus := {}
	Default oArrHelper := DMS_ArrayHelper():New()

	oModelFlds := oModel:GetModel("FIELD_FLDS_" + cTipo)

	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif

	// filtrar somente os campos dessa integracao
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == cTipo })

	for nX := 1 to len(aFldCus)
		jFld := aFldCus[nX]

		lDic := jFld["isDic"]

		if lDic
			if cAlias == jFld["alias"]
				aadd(aArrInt, {jFld["campo"], oModelFlds:GetValue(jFld["campo"]), Nil})
			endif
		else
			if len(jFld["cIdField"]) < len(cPrefix)
				FMX_HELP("OA5070334_1", STR0088, STR0089) // "Campo menor que o prefixo identificado"  "Verificar ponto de entrada OA507FLDS"
			endif

			if cPrefix == left(jFld["cIdField"], len(cPrefix))
				aadd(aArrInt, {jFld["cIdField"], oModelFlds:GetValue(jFld["cIdField"]), Nil})
			endif
		endif
	next
return

/*{Protheus.doc} OA5070374_TemCamposCustomizados
	Verifica se existem campos customizados do determinado tipo

	@type function
	@author Vinicius Gati
	@since 15/08/2025
*/
Function OA5070374_TemCamposCustomizados(cTipo, oArrHelper)
	local aFldCus := {}
	Default oArrHelper := DMS_ArrayHelper():New()

	if ExistBlock("OA507FLDS")
		aFldCus := ExecBlock("OA507FLDS",.f.,.f.)
	endif
	aFldCus := oArrHelper:Select(aFldCus, { |jCust| alltrim(cvaltochar(jCust["tipo"])) == cTipo })
Return len(aFldCus) > 0
