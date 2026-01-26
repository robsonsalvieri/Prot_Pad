#INCLUDE "FWMVCDEF.CH"
#include "TOTVS.CH"
#include "FWCOMMAND.CH"
#include "OFIA261.ch"

Static oSoConfig
Static cFilFiltro
Static o261ArrHlp

Static o261Model1
Static o261Model2

Static cMVMIL0006 := GetNewPar("MV_MIL0006","")
Static lMVMIL0185 := GetNewPar("MV_MIL0185",.F.)

/*/{Protheus.doc} OFIA261
	Tela de configuração do BlackBird John Deere

	@author Rubens Takahashi
	@since  29/06/2021
/*/
Function OFIA261()
	Private oArHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp   := DMS_SqlHelper():New()
	Private oConfig   := OFSoConfig():New()
	Private oCfgAtu   := oConfig:GetConfig()

	Private cChaveS := GetNewPar("MV_MIL0195", "")
	Private cChaveP := GetNewPar("MV_MIL0196", "")
	Private cEndS   := GetNewPar("MV_MIL0197", "")
	Private cEndP   := GetNewPar("MV_MIL0198", "")

	if GetNewPar("MV_MIL0185",.f.) == .f. // Verifica se o ambiente esta integrado com o Blackbird
		FMX_HELP("OA261ERR01",STR0001,STR0002)	// #Integração com o Blackbird da John Deere não está habilitado. ##Verifique o conteúdo do parâmetro MV_MIL0185.
		return 
	endif 


	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0003)	// #Configurações SO(Blackbird) John Deere
	oExecView:setSource("OFIA261")
	oExecView:setOK({ |oModel| OA2610013_Confirmar(oModel) })
	oExecView:setCancel({ || .T. })
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
Return .T.

/*/{Protheus.doc} ViewDef
	Definição da tela principal
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
Static Function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1   := o261Model1:GetView()
	Local oStr2   := o261Model2:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('BOX1', 40 )
	oView:CreateHorizontalBox('BOX2', 60 )

	oView:AddField('FORM1', oStr1, 'MASTER')
	oView:AddGrid('GRID1', oStr2, 'FILIAIS')

	oView:SetOwnerView('FORM1','BOX1')
	oView:SetOwnerView('GRID1','BOX2')

	oView:EnableTitleView('FORM1', 'Configuração')
	oView:EnableTitleView('GRID1', 'Filiais')

	oView:SetCloseOnOk({||.T.})

	oView:addUserButton(STR0004,'', { |oView| OA2610073_LogTransmissao(oView) },,,, .t. )	// #Log Transmissão
	oView:addUserButton(STR0005,'', { |oView| OA2610033_CriarAtualizar(oView)  },,, { MODEL_OPERATION_UPDATE } , .t. )	// #Transmitir Registro
	oView:addUserButton(STR0006,'', { |oView| OA2610083_Deletar(oView)  },,, { MODEL_OPERATION_UPDATE } , .t. )	// #Deletar Registro
Return oView

/*/{Protheus.doc} ModelDef
	Modelo
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
Static Function Modeldef()
	Local oModel
	Local oStr1
	Local oStr2

	if o261Model1 == NIL
		o261Model1 := OA2610053_GetModel01()
		o261Model2 := OA2610063_GetModel02()	
	endif

	oStr1 := o261Model1:GetModel()
	oStr2 := o261Model2:GetModel()

	oModel := MPFormModel():New('OFIA261')
	oModel:SetDescription(STR0007)	// #Configuração Blackbird

	oModel:AddFields("MASTER",,oStr1,,,{|| OA2610023_Load01Dados() })
	oModel:AddGrid("FILIAIS" , "MASTER", oStr2,,,,, {|| OA2610043_Load02Dados() })

	oModel:getModel("MASTER"):SetDescription(STR0008)	// #Configurações
	oModel:getModel("FILIAIS"):SetDescription(STR0009)	// #Conexão

	oModel:SetPrimaryKey({})

	oModel:getModel("FILIAIS"):SetNoInsertLine(.t.)

Return oModel

/*/{Protheus.doc} OA2610053_GetModel01
	Dados base do funcionamento
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
Static Function OA2610053_GetModel01()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'     , STR0010 },;	// #Cód. Matriz
		{'nTamanho'    , FWSizeFilial() },;
		{'cIdField'    , 'MATRIZID' },;
		{'lObrigat'    , .T.        },;
		{'cLookUp'     , 'SM0'      },;
		{'bValid'      , FWBuildFeature( STRUCT_FEATURE_VALID , "OA2610103_ValidFilial()" ) },;
		{'cTooltip'    , STR0011 } ;	// #Informa o código da Filial Matriz do Protheus.
		})
	oMd1:AddField({;
		{'cTitulo'     , STR0012 },;	// #Dealer ID
		{'nTamanho'    , 6          },;
		{'cIdField'    , 'DEALERID' },;
		{'lObrigat'    , .T.        },;
		{'cTooltip'    , STR0013 } ;	// #Informe o ID do Dealer que será utilizado no Header das mensagens.
		})
	oMd1:AddField({;
		{'cTitulo'     , STR0014 },;	// #Ambiente
		{'nTamanho'    , 1          },;
		{'cIdField'    , 'AMBIENTE' },;
		{'lObrigat'    , .T.        },;
		{'bValid'      , {|oMdl, cAttr, uValAnt| oMdl:GetValue("AMBIENTE") $ '12' }},;
		{'aComboValues', {STR0015, STR0016} },;	// #1=SANDBOX (Testes) ##2=PRODUCTION (Produção)
		{'cTooltip'    , STR0017 } ;	// #Ambiente atual
		})
	oMd1:AddField({;
		{'cTitulo'     , STR0018 },;	// #Chave Sandbox
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'KEY1'  },;
		{'bWhen'       , {|| .f.}          },;
		{'cTooltip'    , STR0019 } ;	// #Informado no parametro MV_MIL0195.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0020 },;	// #Chave Produção
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'KEY2'  },;
		{'bWhen'       , {|| .f.}          },;
		{'cTooltip'    , STR0021 } ;	// #Informado no parametro MV_MIL0196.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0022 },;	// #Endereço Sandbox
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'END1'  },;
		{'bWhen'       , {|| .f.}          },;
		{'cTooltip'    , STR0023 } ;	// #Informado no parametro MV_MIL0197.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0024 },;	// #Endereço Produção
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'END2'  },;
		{'bWhen'       , {|| .f.}          },;
		{'cTooltip'    , STR0025 } ;	// #Informado no parametro MV_MIL0198.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0026 },;	// #Categoria Padrão
		{'nTamanho'    , GetSx3Cache("VV2_CATVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV2_CATVEI' },;
		{'lObrigat'    , .T. },;
		{'cLookUp'     , 'VVB   ' },;
		{'cTooltip'    , STR0027 } ;	// #Categoria padrão que será usada ao criar modelo via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0028 },;	// #Tipo de Modelo Padrão
		{'nTamanho'    , GetSx3Cache("VV2_TIPVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV2_TIPVEI' },;
		{'lObrigat'    , .T. },;
		{'cLookUp'     , 'VV8   ' },;
		{'cTooltip'    , STR0029 } ;	// #Tipo de modelo padrão que será usada ao criar modelo via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0030 },;	// #Espécie de Modelo Padrão
		{'nTamanho'    , GetSx3Cache("VV2_ESPVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV2_ESPVEI' },;
		{'lObrigat'    , .T. },;
		{'cLookUp'     , 'VVE   ' },;
		{'cTooltip'    , STR0031 } ;	// #Espécie de modelo padrão que será usada ao criar modelo via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0032 },;	// #Combustível Padrão p/ Equipamento
		{'nTamanho'    , GetSx3Cache("VV1_COMVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV1_COMVEI' },;
		{'aComboValues', OFXFA0154_GetCboxAsArray("VV1_COMVEI")},;
		{'cTooltip'    , STR0033 } ;	// #Combustível padrão ao criar equipamento via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0034 },;	// #Estado padrão p/ Equipamento
		{'nTamanho'    , GetSx3Cache("VV1_ESTVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV1_ESTVEI' },;
		{'aComboValues', OFXFA0154_GetCboxAsArray("VV1_ESTVEI")},;
		{'cTooltip'    , STR0035 } ;	// #Estado padrão ao criar equipamento via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0036 },;	// #Local padrão p/ Equipamento
		{'nTamanho'    , GetSx3Cache("VV1_LOCPAD", "X3_TAMANHO") },;
		{'cIdField'    , 'VV1_LOCPAD' },;
		{'cLookUp'     , 'NNR' },;
		{'cTooltip'    , STR0037 } ;	// #Local padrão ao criar equipamento via SO.
	})
return oMd1

/*/{Protheus.doc} OA2610023_Load01Dados
	Dados da entidade principal
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
static function OA2610023_Load01Dados()
Return {{;
	oCfgAtu['MATRIZID'],;
	oCfgAtu['DEALERID'],;
	oCfgAtu['AMBIENTE'],;
	cChaveS,;
	cChaveP,;
	cEndS,;
	cEndP,;
	oCfgAtu['VV2_CATVEI'],;
	oCfgAtu['VV2_TIPVEI'],;
	oCfgAtu['VV2_ESPVEI'],;
	oCfgAtu['VV1_COMVEI'],;
	oCfgAtu['VV1_ESTVEI'],;
	oCfgAtu['VV1_LOCPAD'] ;
}, 0}

/*/{Protheus.doc} OA2610063_GetModel02
	Definição dos dados que serão configurados modelo 2
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
Static Function OA2610063_GetModel02()
	Local oMd2 := OFDMSStruct():New()
	oMd2:AddReadOnly(STR0038, "GRD_1_EMPRESA", GetSx3Cache("VS3_FILIAL", "X3_TAMANHO"))	// #Empresa
	oMd2:AddReadOnly(STR0039, "GRD_1_FILIAL", GetSx3Cache("VS3_FILIAL", "X3_TAMANHO"))	// #Filial
	oMd2:AddReadOnly(STR0040, "GRD_1_NOME", 200)	// #Nome
	oMd2:AddReadOnly(STR0041, "GRD_1_DEALER", 200)	// #Codigo Dealer
	oMd2:AddField({;
		{'cTitulo'     , STR0042 },;	// #Habilitada
		{'nTamanho'    , 1            },;
		{'cIdField'    , 'GRD_1_HABIL' },;
		{'lObrigat'    , .T.          },;
		{'lCanChange'  , .T.          },; // TODO: Alterar para somente leitura quando subir para producao
		{'bValid'      , {|oMdl, cAttr, uValAnt| oMdl:GetValue(cAttr) $ '01' }},;
		{'aComboValues', {STR0043, STR0044}},;	// #1=Sim ##0=Não
		{'cTooltip'    , STR0045 } ;	// #Se habilita filial para responder ao Blackbird
		})
return oMd2

/*/{Protheus.doc} OA2610043_Load02Dados
	Busca as configuracoes
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
static function OA2610043_Load02Dados()
	local aSM0          := FWLoadSm0()
	local aFilAux       := Nil
	local aCfgAtual     := oCfgAtu['FILIAIS']
	local aCfg          := {}
	local nX            := 1

	local cBkpFilAnt := cFilAnt

	For nX := 1 to len(aSM0)

		If cEmpAnt == aSM0[nX][SM0_GRPEMP]

			oFil := oArHlp:First(aCfgAtual, {|oEl| alltrim(oEl['FILIAL']) == alltrim(aSM0[nX][SM0_CODFIL]) })
			if valtype(oFil) == "U"
				oFil := JsonObject():New()
				oFil["HABILITADA"] := "0"
			endif

			aFilAux    := Array(5)
			aFilAux[1] := aSM0[nX][SM0_GRPEMP] // Codigo da Empresa
			aFilAux[2] := aSM0[nX][SM0_CODFIL] // Codigo da Filial
			aFilAux[3] := aSM0[nX][SM0_NOMRED] // Nome da Filial

			cFilAnt := aSM0[nX][SM0_CODFIL]
			aFilAux[4] := GetNewPar("MV_MIL0005","      ") // Codigo da Filial na JD

			aFilAux[5] := oFil["HABILITADA"]
			aadd(aCfg, {0, aClone(aFilAux)})
		Endif
	Next

	cFilAnt := cBkpFilAnt
	
Return aCfg

/*/{Protheus.doc} OA2610013_Confirmar
	Salva os dados e fecha janela de configuração
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
static function OA2610013_Confirmar(oForm)
	local oMaster  := oForm:GetModel("MASTER")
	local oGridFil := oForm:GetModel("FILIAIS")
	local nX       := 1
	local oEl
	local aFiliais := {}

	oCfgAtu["MATRIZID"] := oMaster:GetValue("MATRIZID")
	oCfgAtu["DEALERID"] := oMaster:GetValue("DEALERID")
	oCfgAtu["AMBIENTE"] := oMaster:GetValue("AMBIENTE")
	oCfgAtu["URL"]  := "" // Nao iremos gravar a URL, somente manter a TAG para depois carregar pela classe de configuração
	oCfgAtu["VV2_CATVEI"] := oMaster:GetValue("VV2_CATVEI")
	oCfgAtu["VV2_TIPVEI"] := oMaster:GetValue("VV2_TIPVEI")
	oCfgAtu["VV2_ESPVEI"] := oMaster:GetValue("VV2_ESPVEI")
	oCfgAtu["VV1_COMVEI"] := oMaster:GetValue("VV1_COMVEI")
	oCfgAtu["VV1_ESTVEI"] := oMaster:GetValue("VV1_ESTVEI")
	oCfgAtu["VV1_LOCPAD"] := oMaster:GetValue("VV1_LOCPAD")

	for nX := 1 to oGridFil:Length()
		oGridFil:GoLine(nX)
		if ! oGridFil:IsDeleted()
			oEl := JsonObject():New()
			oEl["EMPRESA"] := oGridFil:GetValue("GRD_1_EMPRESA")
			oEl["FILIAL"] := oGridFil:GetValue("GRD_1_FILIAL")
			oEl["HABILITADA"] := oGridFil:GetValue("GRD_1_HABIL")
			AADD(aFiliais, oEl)
		endif
	next
	oCfgAtu["FILIAIS"] := aFiliais

	oConfig:SaveConfig(oCfgAtu)
return .t.

/*/{Protheus.doc} OA2610033_CriarAtualizar
	Transmitir create or update do registro no SO
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Static Function OA2610033_CriarAtualizar(oView)

	Local oAuxModel := oView:GetModel("FILIAIS")
	
	Local cComando  := "INSERT"
	Local cMsgVX5 := "01"     // LocationCreatedInDbs

	If oAuxModel:GetValue("GRD_1_HABIL") == "1"
		If MsgNoYes(STR0046)	// #Deseja atualizar registro transmitido anteriormente
		Else
			FMX_HELP(STR0047,STR0048)	// #Registro já enviado ##Selecione um outro registro.
			Return .f.
		EndIf
		cComando  := "UPDATE"
		cMsgVX5 := "02" // LocationUpdateInDbs
	EndIf

	If Empty( oAuxModel:GetValue("GRD_1_DEALER") )
		FMX_HELP(STR0049,STR0050)	// #Necessário informar código do Dealer. ##Verificar conteúdo do parâmetro MV_MIL0005.
		Return .f.
	EndIf

	If ! MsgYesNo(STR0051)	// #Deseja transmitir registro das filiais filial selecionada?
		Return .t.
	EndIf

	if OA2610093_Transmitir( oAuxModel, cComando , cMsgVX5)
		oAuxModel:SetValue("GRD_1_HABIL", "1")
		MsgInfo(STR0052)	// #Registro Enviado.
	else
		return .f.
	endif


Return .t. 

/*/{Protheus.doc} OA2610073_LogTransmissao
	Visualização dos logs de transmissão do registro da grid posicionado
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Static Function OA2610073_LogTransmissao(oView)

	Local oAuxModel := oView:GetModel("FILIAIS")

	oAuxModel:GetValue("GRD_1_EMPRESA")
	oAuxModel:GetValue("GRD_1_FILIAL")
	OFIA262("@ VK5_ORITAB = 'SM0' AND VK5_ORIKEY = '" + oAuxModel:GetValue("GRD_1_EMPRESA") + oAuxModel:GetValue("GRD_1_FILIAL") + "' ", "SO_SMO_LOC")

Return

/*/{Protheus.doc} OA2610083_Deletar
	Transmitir delete do registro posicionado
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Static Function OA2610083_Deletar(oView)

	Local oAuxModel := oView:GetModel("FILIAIS")

	If oAuxModel:GetValue("GRD_1_HABIL") <> "1"
		FMX_HELP(STR0053,STR0054)	// #Registro não transmitido ##Selecione um registro transmitido anteriormente.
		Return .f.
	EndIf

	If ! MsgYesNo(STR0055)	// #Deseja deletar registro da filial selecionada?
		Return .t.
	EndIf

	if OA2610093_Transmitir( oAuxModel, "DELETE" , "03" )
		oAuxModel:SetValue("GRD_1_HABIL", "0")
		MsgInfo(STR0052)	// #Registro Enviado.
	endif

Return .t.

/*/{Protheus.doc} OA2610093_Transmitir
	Transmitir registro ao SO
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Static Function OA2610093_Transmitir( oAuxModel, cComando , cMsgVX5)
	Local oSoLocation        := nil
	Local oSoLocationService := nil
	local jResp
	local cBckFil := cFilAnt

	cFilAnt := oAuxModel:GetValue("GRD_1_FILIAL")

	If OA2610113_FaltaParametros()
		Return .f.
	EndIf

	oSoLocation        := OFSoLocation():New(oAuxModel:GetValue("GRD_1_EMPRESA"), oAuxModel:GetValue("GRD_1_FILIAL"))
	oSoLocationService := OFSoLocationService():new(cMsgVX5, oSoLocation:GetId())

	Do Case
		Case cComando == "INSERT"
			jResp := oSoLocationService:SendCreatedMessage(oSoLocation)
		Case cComando == "UPDATE"
			jResp := oSoLocationService:SendUpdatedMessage(oSoLocation)
		Case cComando == "DELETE"
			jResp := oSoLocationService:SendRemovedMessage(oSoLocation)
	EndCase

	cFilAnt := cBckFil

	if jResp:hasProperty("errors")
		FMX_HELP(STR0056,STR0057)	// #Falha na transmissão do registro. ##Verifique o problema e tente novamente.
		return .f.
	endif

Return .t.

/*/{Protheus.doc} OA2610103_ValidFilial
	Validação do campo de Filial MATRIZ da Master
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Function OA2610103_ValidFilial()
Return ExistCpo("SM0", cEmpAnt+FWFldGet('MATRIZID',/*nLinha*/,/*oModel*/,.T.))


/*/{Protheus.doc} OA2610113_FaltaParametros
	Verifica se os parametros do cabecalho da tela foram persistidos no banco de dados.
	Para transmissão de algum registros o codigo da matriz, Dealer ID e Subscription Key devem ser informados e gravados no banco de dados.
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Static Function OA2610113_FaltaParametros()

	Local oVldConfig := OFSoConfig():New()
	oVldConfig := oVldConfig:GetConfig()

	If Empty(oVldConfig['MATRIZID']) .or. Empty(oVldConfig['DEALERID'])
		FMX_HELP('OA261SEMPARAM',STR0058,STR0059)	// #Parâmetros básicos não foram gravados na base. ##Necessário informar os campos do cabeçalho desta tela e confirmar a gravação antes da transmissão de qualquer registro na base de dados.
		Return .t.
	EndIf

Return .f.


/*/{Protheus.doc} OA2610123_integraDynamics
	Verifica se o ambiente esta integrado com o Dynamics

	o Parametro lFilCheck é opcional, por padrao é .t. e verifica se a filial selecionada está habilitada no Dynamics.
	Checagem necessária para tratar o caso de Rental.
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Function OA2610123_integraDynamics(lFilCheck, cAuxFil)

	local lRetorno := .f.

	default lFilCheck := .t.

	//conout(" __        ___  __                 ___  ___  __   __        __        __      __                         __   __  ")
	//conout("/  ` |__| |__  /  ` |__/    | |\ |  |  |__  / _` |__)  /\  /  `  /\  /  \    |  \ \ / |\ |  /\   |\/| | /  ` /__` ")
	//conout("\__, |  | |___ \__, |  \    | | \|  |  |___ \__> |  \ /~~\ \__, /~~\ \__/    |__/  |  | \| /~~\  |  | | \__, .__/ ")
	//conout("                                                                                                                  ")

 	if cMVMIL0006 == "JD" .and. lMVMIL0185
		
		lRetorno := .t.
		
		if lFilCheck
			if oSoConfig == NIL
				oSoConfig  := OFSoConfig():New()
				o261ArrHlp := DMS_ArrayHelper():New()
				cFilFiltro := o261ArrHlp:Join(o261ArrHlp:Map(oSoConfig:GetHabilitadas(), {|oEl| oEl["FILIAL"] }), "/") + "/"
			endif

			if (alltrim(cAuxFil)+"/") $ cFilFiltro
			else
				lRetorno := .f.
			endif
		endif
	endif

Return lRetorno