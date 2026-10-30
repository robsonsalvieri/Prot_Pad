#INCLUDE "FWMVCDEF.CH"
#include "TOTVS.CH"
#include "FWCOMMAND.CH"
#include "OFIA261.ch"
#Include "protheus.ch"
#Include "totvs.ch"
#Include "rwmake.ch"



Static oSoConfig
Static cFilFiltro
Static o261ArrHlp

Static o261Model1
Static o261Model2

Static cMVMIL0006 := GetNewPar("MV_MIL0006","")
Static lMVMIL0185 := GetNewPar("MV_MIL0185",.F.)

/*/{Protheus.doc} OFIA261
	Tela de configurao do BlackBird John Deere

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
		FMX_HELP("OA261ERR01",STR0001,STR0002)	// #Integrao com o Blackbird da John Deere no est habilitado. ##Verifique o contedo do parmetro MV_MIL0185.
		return 
	endif 

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0003)	// #Configuraes SO(Blackbird) John Deere
	oExecView:setSource("OFIA261")
	oExecView:setOK({ |oModel| OA2610013_Confirmar(oModel) })
	oExecView:setCancel({ || .T. })
	
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
	//SET CASE ON
Return .T.


/*/{Protheus.doc} ViewDef
	Definio da tela principal
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
Static Function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1   := o261Model1:GetView()
	Local oStr2   := o261Model2:GetView()
	Local aFields := oStr1:GetFields()
	Local nX := 0

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('BOX1', 40 )
	oView:CreateHorizontalBox('BOX2', 60 )

	oStr1:AddFolder("001", "Mapeamentos De/Para")
	oStr1:AddFolder("002", "Parametros de Conexão")

	For nX := 1 to len(aFields)
		oStr1:SetProperty(aFields[nX][1],MVC_VIEW_FOLDER_NUMBER,"001")
	Next nX

	oStr1:SetProperty("AMBIENTE",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("AUTENTIC",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("KEY1",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("KEY2",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("SRVAUT1",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("SRVAUT2",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("USUARIO1",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("USUARIO2",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("SENHA1",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("SENHA2",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("ESCOPO1",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("ESCOPO2",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("END1",MVC_VIEW_FOLDER_NUMBER,"002")
	oStr1:SetProperty("END2",MVC_VIEW_FOLDER_NUMBER,"002")

	oView:AddField('FORM1', oStr1, 'MASTER')
	oView:AddGrid('GRID1', oStr2, 'FILIAIS')

	oView:createVerticalBox('BOX_GRID', 90	, 'BOX2')
	oView:createVerticalBox('BOX_BTN', 10, 'BOX2')

	oView:SetOwnerView('FORM1','BOX1')
	oView:SetOwnerView('GRID1','BOX_GRID')

	oView:EnableTitleView('FORM1', 'Configurao')
	oView:EnableTitleView('GRID1', 'Filiais')

	oView:SetCloseOnOk({||.T.})

	oView:addUserButton(STR0004							,'', { |oView| OA2610073_LogTransmissao(oView)}					,,,, 								.f. )	// #Log Transmisso
	oView:addUserButton("Transmitir Location"			,'', { |oView| OA2610033_CriarAtualizar(oView)}					,,, { MODEL_OPERATION_UPDATE } , 	.f. )	// #Transmitir Registro
	oView:addUserButton(STR0006							,'', { |oView| OA2610083_Deletar(oView)}						,,, { MODEL_OPERATION_UPDATE } , 	.f. )	// #Deletar Registro
	
	oView:AddOtherObject("VIEW_OTHER", {|oPanel| tBtnCont(oPanel)})
	oView:SetOwnerView('VIEW_OTHER' , 'BOX_BTN')	//View do Boto da Grid.

Return oView



/*/{Protheus.doc} tBtnCont
	Criando o Botão da Grid
	
	@type function
	@author Marcos Vieira
	@since 21/06/2025
/*/
Static Function tBtnCont(oPanel)

	Local cFont := "Arial" 
	Local oFontBtn := TFont():New(cFont,,-12,,.T.)

	oBtnT:= TButton():New( 11, , "Transmitir Location Contract",oPanel,{||OA2610143_CriarAtualizarLocationContract()}, 95,15,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )

Return



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

	oModel := MPFormModel():New('OFIA261',,{ |oModel| OA2610136_TudoOk( oModel ) })
	oModel:SetDescription(STR0007)	// #Configurao Blackbird

	oModel:AddFields("MASTER",,oStr1,,,{|| OA2610023_Load01Dados() })
	oModel:AddGrid("FILIAIS" , "MASTER", oStr2,,,,, {|| OA2610043_Load02Dados() })


	oModel:getModel("MASTER"):SetDescription(STR0008)	// #Configurações
	oModel:getModel("FILIAIS"):SetDescription(STR0009)	// #Conexão
	oModel:GetModel("FILIAIS"):SetUniqueLine( { "GRD_1_DEALER" } )

	oModel:SetPrimaryKey({})


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
		{'cTitulo'     , STR0010 },;	// #Cd. Matriz
		{'nTamanho'    , FWSizeFilial() },;
		{'cIdField'    , 'MATRIZID' },;
		{'lObrigat'    , .T.        },;
		{'cLookUp'     , 'SM0'      },;
		{'bValid'      , FWBuildFeature( STRUCT_FEATURE_VALID , "OA2610103_ValidFilial()" ) },;
		{'cTooltip'    , STR0011 } ;	// #Informa o cdigo da Filial Matriz do Protheus.
		})
	oMd1:AddField({;
		{'cTitulo'     , STR0012 },;	// #Dealer ID
		{'nTamanho'    , 6          },;
		{'cIdField'    , 'DEALERID' },;
		{'lObrigat'    , .T.        },;
		{'cTooltip'    , STR0013 } ;	// #Informe o ID do Dealer que ser utilizado no Header das mensagens.
		})
	oMd1:AddField({;
		{'cTitulo'     , STR0014 },;	// #Ambiente
		{'nTamanho'    , 1          },;
		{'cIdField'    , 'AMBIENTE' },;
		{'lObrigat'    , .T.        },;
		{'bValid'      , {|oMdl, cAttr, uValAnt| oMdl:GetValue("AMBIENTE") $ '12' }},;
		{'bWhen'       , {|| !OA2610134_VerrificaIntegracaoDynamicsHabilitado() }},;
		{'aComboValues', {STR0015, STR0016} },;	// #1=SANDBOX (Testes) ##2=PRODUCTION (Produção)
		{'cTooltip'    , STR0017 } ;	// #Ambiente atual
		})
	oMd1:AddField({;
		{'cTitulo'     , STR0096 },;	// #Autenticao
		{'nTamanho'    , 1          },;
		{'cIdField'    , 'AUTENTIC' },;
		{'lObrigat'    , .F.        },;
		{'bValid'      , {|oMdl, cAttr, uValAnt| oMdl:GetValue("AUTENTIC") $ '12' }},;
		{'aComboValues', {STR0069, STR0070} },;	// #1=Subscription-Key ##2=OAuth v2
		{'cTooltip'    , STR0071 } ;	// #Metodo de autenticao atual
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
	
	//Inicio campos AUTH2
	oMd1:AddField({;
		{'cTitulo'     , STR0072 },;	// #Servidor Aut. SandBox
		{'cPicture'    , '@A'        },;
		{'nTamanho'    , 250        },;
		{'cIdField'    , 'SRVAUT1'  },;
		{'bWhen'       , {|oMdl| oMdl:GetValue("AUTENTIC") == '2'}          },;
		{'cTooltip'    , STR0073 } ;	// #Url do servidor aut. SandBox
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0074 },;	// #Servidor Aut. Produção
		{'cPicture'    , '@A'        },;
		{'nTamanho'    , 250        },;
		{'cIdField'    , 'SRVAUT2'  },;
		{'bWhen'       , {|oMdl| oMdl:GetValue("AUTENTIC") == '2'}          },;
		{'cTooltip'    , STR0075 } ;	// #Url do servidor aut. Produção
	})
	
	
	
	oMd1:AddField({;
		{'cTitulo'     , STR0080 },;	// #Usuário SandBox
		{'nTamanho'    , 100        },;
		{'cPicture'    , '@A'        },;
		{'cIdField'    , 'USUARIO1'  },;
		{'bWhen'       , {|oMdl| oMdl:GetValue("AUTENTIC") == '2'}          },;
		{'cTooltip'    , STR0081 } ;	// #Usuário Sandbox Atual
	})
	
	oMd1:AddField({;
		{'cTitulo'     , STR0082 },;	// #Usuário Produção
		{'nTamanho'    , 100        },;
		{'cPicture'    , '@A'        },;
		{'cIdField'    , 'USUARIO2'  },;
		{'bWhen'       , {|oMdl| oMdl:GetValue("AUTENTIC") == '2'}          },;
		{'cTooltip'    , STR0083 } ;	// #Usuário Produção Atualo
	})
	
	oMd1:AddField({;
		{'cTitulo'     , STR0084 },;	// #Senha SandBox
		{'cPicture'    , '@A'        },;
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'SENHA1'  },;
		{'bWhen'       , {|oMdl| oMdl:GetValue("AUTENTIC") == '2'}          },;
		{'cTooltip'    , STR0085 } ;	// #Senha Sandbox Atual
	})
	
	oMd1:AddField({;
		{'cTitulo'     , STR0086 },;	// #Senha Produção
		{'cPicture'    , '@A'        },;
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'SENHA2'  },;
		{'bWhen'       , {|oMdl| oMdl:GetValue("AUTENTIC") == '2'}          },;
		{'cTooltip'    , STR0087 } ;	// #Senha Produção Atualo
	})
	
	oMd1:AddField({;
		{'cTitulo'     , STR0092 },;	// #ESCOPO SandBox
		{'cPicture'    , '@A'        },;
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'ESCOPO1'  },;
		{'bWhen'       , {|oMdl| oMdl:GetValue("AUTENTIC") == '2'}          },;
		{'cTooltip'    , STR0093 } ;	// #ESCOPO Sandbox Atual
	})
	
	oMd1:AddField({;
		{'cTitulo'     , STR0094 },;	// #ESCOPO Produção
		{'cPicture'    , '@A'        },;
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'ESCOPO2'  },;
		{'bWhen'       , {|oMdl| oMdl:GetValue("AUTENTIC") == '2'}          },;
		{'cTooltip'    , STR0095 } ;	// #Senha Produção Atualo
	})
	

	//Fim campos AUTH2
	oMd1:AddField({;
		{'cTitulo'     , STR0022 },;	// #Endereo Sandbox
		{'cPicture'    , '@A'        },;
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'END1'  },;
		{'bWhen'       , {|| .f.}          },;
		{'cTooltip'    , STR0023 } ;	// #Informado no parametro MV_MIL0197.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0024 },;	// #Endereo Produção
		{'cPicture'    , '@A'        },;
		{'nTamanho'    , 100        },;
		{'cIdField'    , 'END2'  },;
		{'bWhen'       , {|| .f.}          },;
		{'cTooltip'    , STR0025 } ;	// #Informado no parametro MV_MIL0198.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0026 },;	// #Categoria Padro
		{'nTamanho'    , GetSx3Cache("VV2_CATVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV2_CATVEI' },;
		{'lObrigat'    , .T. },;
		{'cLookUp'     , 'VVB   ' },;
		{'cTooltip'    , STR0027 } ;	// #Categoria padro que ser usada ao criar modelo via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0028 },;	// #Tipo de Modelo Padro
		{'nTamanho'    , GetSx3Cache("VV2_TIPVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV2_TIPVEI' },;
		{'lObrigat'    , .T. },;
		{'cLookUp'     , 'VV8   ' },;
		{'cTooltip'    , STR0029 } ;	// #Tipo de modelo padro que ser usada ao criar modelo via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0030 },;	// #Espcie de Modelo Padro
		{'nTamanho'    , GetSx3Cache("VV2_ESPVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV2_ESPVEI' },;
		{'lObrigat'    , .T. },;
		{'cLookUp'     , 'VVE   ' },;
		{'cTooltip'    , STR0031 } ;	// #Espcie de modelo padro que ser usada ao criar modelo via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0032 },;	// #Combustvel Padro p/ Equipamento
		{'nTamanho'    , GetSx3Cache("VV1_COMVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV1_COMVEI' },;
		{'aComboValues', OFXFA0154_GetCboxAsArray("VV1_COMVEI")},;
		{'cTooltip'    , STR0033 } ;	// #Combustvel padro ao criar equipamento via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0034 },;	// #Estado padro p/ Equipamento
		{'nTamanho'    , GetSx3Cache("VV1_ESTVEI", "X3_TAMANHO") },;
		{'cIdField'    , 'VV1_ESTVEI' },;
		{'aComboValues', OFXFA0154_GetCboxAsArray("VV1_ESTVEI")},;
		{'cTooltip'    , STR0035 } ;	// #Estado padro ao criar equipamento via SO.
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0036 },;	// #Local padro p/ Equipamento
		{'nTamanho'    , GetSx3Cache("VV1_LOCPAD", "X3_TAMANHO") },;
		{'cIdField'    , 'VV1_LOCPAD' },;
		{'cLookUp'     , 'NNR' },;
		{'cTooltip'    , STR0037 } ;	// #Local padro ao criar equipamento via SO.
	})

	oMd1:AddField({;
		{'cTitulo'     , STR0088 },;	// #Tipo Tempo Cliente
		{'nTamanho'    , GetSx3Cache("VOI_TIPTEM", "X3_TAMANHO")        },;
		{'cIdField'    , 'TTCLIENTE'  },;
		{'cLookUp'     , 'VOIPUB' },;
		{'bValid'      , {|oMdl| OA2610137_ValidaTT(oMdl:GetValue("TTCLIENTE"), '1') }},;
		{'cTooltip'    , STR0091 } ;	// #Escolha o tipo de tempo que será utlizado na abertatura das OS
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0089 },;	// #Tipo Tempo Interno
		{'nTamanho'    , GetSx3Cache("VOI_TIPTEM", "X3_TAMANHO")        },;
		{'cIdField'    , 'TTINTERNO'  },;
		{'cLookUp'     , 'VOIINT' },;
		{'bValid'      , {|oMdl| OA2610137_ValidaTT(oMdl:GetValue("TTINTERNO"), '3') }},;
		{'cTooltip'    , STR0091 } ;	// #Escolha o tipo de tempo que será utlizado na abertatura das OS
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0090 },;	// #Tipo Tempo Garantia
		{'nTamanho'    , GetSx3Cache("VOI_TIPTEM", "X3_TAMANHO")        },;
		{'cIdField'    , 'TTGARANTIA'  },;
		{'cLookUp'     , 'VOIGAR' },;
		{'bValid'      , {|oMdl| OA2610137_ValidaTT(oMdl:GetValue("TTGARANTIA"), '2') }},;
		{'cTooltip'    , STR0091 } ;	// #Escolha o tipo de tempo que será utlizado na abertatura das OS
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
	oCfgAtu['AUTENTIC'],;
	cChaveS,;
	cChaveP,;
	oCfgAtu['SRVAUT1'],;
	oCfgAtu['SRVAUT2'],;
	oCfgAtu['USUARIO1'],;
	oCfgAtu['USUARIO2'],;
	oCfgAtu['SENHA1'],;
	oCfgAtu['SENHA2'],;
	oCfgAtu['ESCOPO1'],;
	oCfgAtu['ESCOPO2'],;
	cEndS,;
	cEndP,;
	oCfgAtu['VV2_CATVEI'],;
	oCfgAtu['VV2_TIPVEI'],;
	oCfgAtu['VV2_ESPVEI'],;
	oCfgAtu['VV1_COMVEI'],;
	oCfgAtu['VV1_ESTVEI'],;
	oCfgAtu['VV1_LOCPAD'],;
	oCfgAtu['TTCLIENTE'],;
	oCfgAtu['TTINTERNO'],;
	oCfgAtu['TTGARANTIA'];
}, 0}

/*/{Protheus.doc} OA2610063_GetModel02
	Definio dos dados que sero configurados modelo 2
	
	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
Static Function OA2610063_GetModel02()
	Local oMd2 := OFDMSStruct():New()
	oMd2:AddField({;
		{'cTitulo'     , STR0038 },;	// #Empresa
		{'nTamanho'    , len(cEmpAnt)            },;
		{'cIdField'    , 'GRD_1_EMPRESA' },;
		{'lObrigat'    , .T.          },;
		{'lCanChange'  , .T.          },; 
		{'bValid'      , {|oMdl| OA2610133_ValidaFilial(oMdl) .AND. OA261016B_ValidarHabilitada(oMdl)}},;
		{'cTooltip'    , STR0060 } ;	// #Se habilita filial para responder ao Blackbird
		})
	
	oMd2:AddField({;
		{'cTitulo'     , STR0039 },;	// #Empresa
		{'nTamanho'    , len(cFilAnt)            },;
		{'cIdField'    , 'GRD_1_FILIAL' },;
		{'lObrigat'    , .F.          },;
		{'lCanChange'  , .T.          },; 
		{'bValid'      , {|oMdl| OA2610133_ValidaFilial(oMdl) .AND. OA261016B_ValidarHabilitada(oMdl)}},;
		{'cTooltip'    , STR0061 } ;	// #Se habilita filial para responder ao Blackbird
		})
	oMd2:AddReadOnly(STR0040, "GRD_1_NOME", 80)	// #Nome
	oMd2:AddReadOnly(STR0067, "GRD_1_NOMEFILIAL", 80)	// #Filial
	
	oMd2:AddField({;
		{'cTitulo'     , STR0041 },;	// #Codigo Dealer
		{'nTamanho'    , 10            },;
		{'cIdField'    , 'GRD_1_DEALER' },;
		{'lObrigat'    , .T.          },;
		{'lCanChange'  , .T.          },; 
		{'bValid'      , {|oMdl| OA2610133_ValidaFilial(oMdl) .AND. OA261016B_ValidarHabilitada(oMdl)}},;
		{'cTooltip'    , STR0062 } ;	// #Se habilita filial para responder ao Blackbird
		})

	oMd2:AddField({;
		{'cTitulo'     , "Franchise" },;	// #
		{'nTamanho'    , tamsx3("VKB_CODIGO")[1]            },;
		{'cIdField'    , 'GRD_1_FRANCHISE' },;
		{'lObrigat'    , .F.          },;
		{'lCanChange'  , .T.          },; 
		{'bValid'      , {|oMdl| OA261016B_ValidarHabilitada(oMdl)}},;
		{'cTooltip'    , STR0065 } ,;
		{"cLookUp"     , "VKB261"}; //F3 - Nao documentado em FwFormModelStruct
		})

	oMd2:AddField({;
		{'cTitulo'     , "Conta Principal" },;	// #,
		{'nTamanho'    , 1            },;
		{'cIdField'    , 'GRD_1_MAINACC' },;
		{'lObrigat'    , .T.          },;
		{'lCanChange'  , .T.          },; 
		{'aComboValues', {STR0043, STR0044}},;	// #1=Sim ##0=Não
		{'bValid'      , {|oMdl| OA261016B_ValidarHabilitada(oMdl)}},;
		{'cTooltip'    , STR0066 } ;	// "Indica se é a conta principal para a Filial posicionada"
		})

	oMd2:AddField({;
		{'cTitulo'     , STR0042 },;	// #Habilitada
		{'nTamanho'    , 1            },;
		{'cIdField'    , 'GRD_1_HABIL' },;
		{'lObrigat'    , .T.          },;
		{'lCanChange'  , .T.          },; // TODO: Alterar para somente leitura quando subir para producao
		{'bValid'      , {|oMdl, cAttr, uValAnt| OA2610135_ValidaHabilitado(oMdl:GetValue(cAttr))}},;
		{'aComboValues', {STR0043, STR0044}},;	// #1=Sim ##0=No
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
	local aSM0 := Nil
	local aFilAux := Nil
	local aCfgAtual := oCfgAtu['FILIAIS']
	local aCfg := {}
	local nX := 1
	local cBkpFilAnt := cFilAnt
	Local oFil := Nil
	Local nTamContrato := 10
	Local nTamFranchise := tamsx3("VKB_CODIGO")[1]

	If Empty(aCfgAtual)
		aSM0 := FWLoadSm0()

		For nX := 1 to len(aSM0)

			if cEmpAnt <> aSM0[nX][SM0_GRPEMP] //.or. empty(GetNewPar("MV_MIL0005"," "))
				loop
			endif

			aFilAux    := Array(8)
			aFilAux[1] := aSM0[nX][SM0_GRPEMP] // Codigo da Empresa
			aFilAux[2] := aSM0[nX][SM0_CODFIL] // Codigo da Filial
			aFilAux[3] := aSM0[nX][SM0_NOMRED] // Nome da Filial
			aFilAux[4] := aSM0[nX][SM0_NOME] // Nome da Filial
			
			cFilAnt := aSM0[nX][SM0_CODFIL]
			aFilAux[5] := PadR(GetNewPar("MV_MIL0005"," "),nTamContrato) // Codigo da Filial na JDBV
			
			If Empty(aFilAux[5])
				aFilAux[5] := Space(nTamContrato)
			EndIf

			aFilAux[6] := space(nTamFranchise)

			aFilAux[7] := "0"
	
			aFilAux[8] := "0"

			aadd(aCfg, {0, aClone(aFilAux)})
		Next

	Else
		For nX := 1 to len(aCfgAtual)
			oFil := aCfgAtual[nX]

			aFilAux    := Array(8)
			aFilAux[1] := oFil["EMPRESA"] // Codigo da Empresa
			aFilAux[2] := oFil["FILIAL"] // Codigo da Filial
			aFilAux[3] := FWSM0Util():getSM0FullName(oFil["EMPRESA"], oFil["FILIAL"]) // Nome da Empresa
			aFilAux[4] := FWSM0Util():GetSM0Data(oFil["EMPRESA"], oFil["FILIAL"] , { "M0_FILIAL" } )[1,2] // Nome da Filial
			
			If oFil:hasProperty("CONTRATO")
				aFilAux[5] := left(oFil["CONTRATO"],nTamContrato)
			EndIf

			If Empty(aFilAux[5])
				cFilAnt := oFil["FILIAL"]
				aFilAux[5] := PadR(GetNewPar("MV_MIL0005"," "),nTamContrato)
			EndIf
			
			if oFil:hasProperty("FRANCHISE")
				aFilAux[6] := left(oFil["FRANCHISE"],nTamFranchise)
			endif

			If Empty(aFilAux[6])
				aFilAux[6] := space(nTamFranchise)
			endif

			if oFil:hasProperty("MAINACC")
				aFilAux[7] := oFil["MAINACC"]
			endif

			If Empty(aFilAux[7])
				aFilAux[7] := "0"
			endif

			aFilAux[8] := oFil["HABILITADA"]
			aadd(aCfg, {0, aClone(aFilAux)})
		Next nX
	EndIf 

	cFilAnt := cBkpFilAnt
	
Return aCfg

/*/{Protheus.doc} OA2610013_Confirmar
	Salva os dados e fecha janela de configurao
	
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
	oCfgAtu["URL"]  := "" // Nao iremos gravar a URL, somente manter a TAG para depois carregar pela classe de configurao
	oCfgAtu["VV2_CATVEI"] := oMaster:GetValue("VV2_CATVEI")
	oCfgAtu["VV2_TIPVEI"] := oMaster:GetValue("VV2_TIPVEI")
	oCfgAtu["VV2_ESPVEI"] := oMaster:GetValue("VV2_ESPVEI")
	oCfgAtu["VV1_COMVEI"] := oMaster:GetValue("VV1_COMVEI")
	oCfgAtu["VV1_ESTVEI"] := oMaster:GetValue("VV1_ESTVEI")
	oCfgAtu["VV1_LOCPAD"] := oMaster:GetValue("VV1_LOCPAD")
	oCfgAtu["AUTENTIC"] := oMaster:GetValue("AUTENTIC")
	oCfgAtu["SRVAUT1"] := oMaster:GetValue("SRVAUT1")
	oCfgAtu["SRVAUT2"] := oMaster:GetValue("SRVAUT2")
	// oCfgAtu["TENANTID1"] := oMaster:GetValue("TENANTID1")
	// oCfgAtu["TENANTID2"] := oMaster:GetValue("TENANTID2")
	oCfgAtu["USUARIO1"] := oMaster:GetValue("USUARIO1")
	oCfgAtu["USUARIO2"] := oMaster:GetValue("USUARIO2")
	oCfgAtu["SENHA1"] := oMaster:GetValue("SENHA1")
	oCfgAtu["SENHA2"] := oMaster:GetValue("SENHA2")
	oCfgAtu["ESCOPO1"] := oMaster:GetValue("ESCOPO1")
	oCfgAtu["ESCOPO2"] := oMaster:GetValue("ESCOPO2")
	oCfgAtu['TTCLIENTE'] := oMaster:GetValue("TTCLIENTE")
	oCfgAtu['TTINTERNO'] := oMaster:GetValue("TTINTERNO")
	oCfgAtu['TTGARANTIA'] := oMaster:GetValue("TTGARANTIA")

	for nX := 1 to oGridFil:Length()
		oGridFil:GoLine(nX)
		if ! oGridFil:IsDeleted()
			oEl := JsonObject():New()
			oEl["EMPRESA"] := oGridFil:GetValue("GRD_1_EMPRESA")
			oEl["FILIAL"] := oGridFil:GetValue("GRD_1_FILIAL")
			oEl["CONTRATO"] := oGridFil:GetValue("GRD_1_DEALER")
			oEl["FRANCHISE"] := oGridFil:GetValue("GRD_1_FRANCHISE")
			oEl["MAINACC"] := oGridFil:GetValue("GRD_1_MAINACC")
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
			FMX_HELP(STR0047,STR0048)	// #Registro j enviado ##Selecione um outro registro.
			Return .f.
		EndIf
		cComando  := "UPDATE"
		cMsgVX5 := "02" // LocationUpdateInDbs
	EndIf

	If Empty( oAuxModel:GetValue("GRD_1_DEALER") )
		FMX_HELP(STR0049,STR0050)	// #Necessrio informar cdigo do Dealer. ##Verificar contedo do parmetro MV_MIL0005.
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
	Visualizao dos logs de transmisso do registro da grid posicionado
	
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
		FMX_HELP(STR0053,STR0054)	// #Registro no transmitido ##Selecione um registro transmitido anteriormente.
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
		FMX_HELP(STR0056,STR0057)	// #Falha na transmisso do registro. ##Verifique o problema e tente novamente.
		return .f.
	endif

Return .t.

/*/{Protheus.doc} OA2610103_ValidFilial
	Validao do campo de Filial MATRIZ da Master
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Function OA2610103_ValidFilial()
Return ExistCpo("SM0", cEmpAnt+FWFldGet('MATRIZID',/*nLinha*/,/*oModel*/,.T.))


/*/{Protheus.doc} OA2610113_FaltaParametros
	Verifica se os parametros do cabecalho da tela foram persistidos no banco de dados.
	Para transmisso de algum registros o codigo da matriz, Dealer ID e Subscription Key devem ser informados e gravados no banco de dados.
	
	@type function
	@author Rubens Takahashi
	@since 31/08/2021
/*/
Static Function OA2610113_FaltaParametros()

	Local oVldConfig := OFSoConfig():New()
	oVldConfig := oVldConfig:GetConfig()

	If Empty(oVldConfig['MATRIZID']) .or. Empty(oVldConfig['DEALERID'])
		FMX_HELP('OA261SEMPARAM',STR0058,STR0059)	// #Parmetros bsicos no foram gravados na base. ##Necessrio informar os campos do cabealho desta tela e confirmar a gravao antes da transmisso de qualquer registro na base de dados.
		Return .t.
	EndIf

Return .f.


/*/{Protheus.doc} OA2610123_integraDynamics 
	Verifica se o ambiente esta integrado com o Dynamics

	o Parametro lFilCheck  opcional, por padrao  .t. e verifica se a filial selecionada est habilitada no Dynamics.
	Checagem necessria para tratar o caso de Rental.
	
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

/*/{Protheus.doc} OA2610133_ValidaGrupo
	Verifica se o grupo digitado pertence ao grupo de empresas
	@type function
	@author Iury Soares Azevedo
	@since 26/05/2025
/*/
Static Function OA2610133_ValidaFilial(oModel)
	Local lRet := .T.
	Local cCodEmp := oModel:GetValue("GRD_1_EMPRESA")
	Local cCodFil := oModel:GetValue("GRD_1_FILIAL")
	Local cNome := ""
	If !Empty(cCodEmp) .AND. !Empty(cCodFil)
		cNome := FWSM0Util():getSM0FullName(cCodEmp, cCodFil)
		lRet :=  !Empty(cNome)

		If lRet 
			oModel:LoadValue("GRD_1_NOME",cNome)
		EndIf	

	EndIf
Return lRet

/*/{Protheus.doc} OA2610134_VerrificaIntegracaoDynamicsHabilitado
	percorre o grid e veirica se alguma das configuracoes esta habilitada
	@type function
	@author Iury Soares Azevedo
	@since 26/05/2025
/*/
Static Function OA2610134_VerrificaIntegracaoDynamicsHabilitado()
	Local lRet := .F.
	Local oModel := FwModelActive()
	Local oFiliais := oModel:GetModel("FILIAIS")
	Local nX := 0
	Local aSaveLines := FWSaveRows()
	
	For nX := 1 to oFiliais:Length()
		oFiliais:GoLine(nX)
		If !oFiliais:IsDeleted();
			.AND. oFiliais:GetValue("GRD_1_HABIL") =="1"
			lRet := .T.
			Exit
		EndIf

	Next nX

	FWRestRows( aSaveLines )
Return lRet
/*/{Protheus.doc} OA2610135_ValidaHabilitado
	Verifica se o o valor do campo habilita esta correto e da um refresh na tela para atualizar o campo Ambiente
	@type function
	@author Iury Soares Azevedo
	@since 26/05/2025
/*/
Static Function OA2610135_ValidaHabilitado(cValor)
	Local lRet := cValor $ '0|1'
	Local oView	:= FWViewActive()
	
	oView:Refresh()
Return lRet	
/*/{Protheus.doc} OA2610136_TudoOk
	Verifica se o o valor do campo habilita esta correto e da um refresh na tela para atualizar o campo Ambiente
	@type function
	@author Iury Soares Azevedo
	@since 26/05/2025
/*/
Static Function OA2610136_TudoOk(oModel)
	Local cDealer As Charactere

	Local oFiliais := oModel:GetModel("FILIAIS")
	Local nX := 0
	Local nY := 0
	Local aSaveLines := FWSaveRows()
	Local lRet := .T.

	cDealer := ""
	cFranchise := ""
	cHabilit := ""
	
	For nX := 1 to oFiliais:Length()
		oFiliais:GoLine(nX)
		If !oFiliais:IsDeleted()
			cDealer := AllTrim(oFiliais:GetValue("GRD_1_DEALER"))
			
			For nY := 1 to oFiliais:Length()
				If nY != nX
					oFiliais:GoLine(nY)
					If !oFiliais:IsDeleted();
						.AND. (AllTrim(oFiliais:GetValue("GRD_1_HABIL")) == "1"); //so valida se estiver habilitada
						.AND. AllTrim(oFiliais:GetValue("GRD_1_DEALER")) == cDealer
						lRet := .F.
						FMX_HELP("OA261ERR02",STR0063,STR0064)
						Exit
					Endif

					lRet := OA261016B_ValidarHabilitada(oFiliais) // Verifica se Grid contém campos com o Habilitada e Franchise em branco

					if !lRet
						FMX_HELP("FRANCHNPREEN", STR0068) // "Franchise não preenchida."
					Endif
				EndIf
			Next nY
			
		EndIf
		If !lRet
			Exit
		EndIf
	Next nX

	FWRestRows( aSaveLines )
	


Return lRet



/*/{Protheus.doc} OA2610143_CriarAtualizarLocationContract
	Criar ou atualizar Location Contract no SO
	
	@type function
	@author Rubens Takahashi
	@since 11/06/2025
/*/
Static Function OA2610143_CriarAtualizarLocationContract()

	Local oView		:= FWViewActive()
	Local oAuxModel := oView:GetModel("FILIAIS")

	Local cComando  := "INSERT"
	Local cMsgVX5 := "01"     // LocationCreatedInDbs

	if OA2610153_TransmitirLocationContract( oAuxModel, cComando, cMsgVX5)
		MsgInfo(STR0052)	// #Registro Enviado.
	endif

Return .t.


/*/{Protheus.doc} OA2610143_CriarAtualizarLocationContract
	Criar ou atualizar Location Contract no SO
	
	@type function
	@author Rubens Takahashi
	@since 11/06/2025
/*/
Static Function OA2610153_TransmitirLocationContract( oAuxModel, cComando , cMsgVX5)
	Local oSoLocContract        := nil
	Local oMessage := nil
	//local jResp
	//local cBckFil := cFilAnt

	//cFilAnt := oAuxModel:GetValue("GRD_1_FILIAL")

	//If OA2610113_FaltaParametros()
	//	Return .f.
	//EndIf

	//oSoLocation        := OFSoLocation():New(oAuxModel:GetValue("GRD_1_EMPRESA"), oAuxModel:GetValue("GRD_1_FILIAL"))
	oSoLocContract     := OFSoLocationContract():New(oAuxModel:GetValue("GRD_1_DEALER"))

	Do Case
		Case cComando == "INSERT"
			oMessage := OFSoLocationContractCreatedInDbsMessage():new(oSoLocContract)
		Case cComando == "UPDATE"
			jResp := oSoLocationService:SendUpdatedMessage(oSoLocation)
		Case cComando == "DELETE"
			jResp := oSoLocationService:SendRemovedMessage(oSoLocation)
	EndCase

	FWMsgRun(, {|oSay| oMessage:Send() }, "John Deere - Blackbird - Location Contract", "") // "John Deere - Blackbird"

	lTransmitido := (oMessage:oSoRequest:GetHTTPResponse() == 200)

	//cFilAnt := cBckFil

	//if jResp:hasProperty("errors")
	//	FMX_HELP(STR0056,STR0057)	// #Falha na transmissão do registro. ##Verifique o problema e tente novamente.
	//	return .f.
	//endif

Return .t.

/*/{Protheus.doc} OA2610143_CriarAtualizarLocationContract
	Valida se o tipo escolhido existe e se percente a situacao selecionada
	@type function
	@author Iury Soares Azevedo
	@since 23/10/2025
/*/
Static Function OA2610137_ValidaTT(cTT, cSituacao)
	Local lRet := .T.
	If !Empty(cTT)
		VOI->(dbSelectArea("VOI"))
		VOI->(dbSetOrder(1))
		If !VOI->(MsSeek(xFilial("VOI")+cTT));
			.OR. VOI->VOI_SITTPO != cSituacao
			lRet := .F.
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} OA261016B_ValidarHabilitada
	Validar a Model02 quando campo Habilitado está ativo
	
	@type function
	@author Alecsandre Ap. Fabiano S. Ferreira
	@since 24/06/2025
/*/
Static Function OA261016B_ValidarHabilitada(oModel As Object) As Logical
	Local lRet As Logical
	Local cCodEmp As Charactere
	Local cCodFil As Charactere

	lRet := .T.
	cCodEmp := oModel:GetValue("GRD_1_EMPRESA")
	cCodFil := oModel:GetValue("GRD_1_FILIAL")

	If !Empty(cCodEmp) .AND. !Empty(cCodFil)
		if oModel:GetValue("GRD_1_HABIL") == "1" .AND. Empty(oModel:GetValue("GRD_1_FRANCHISE"))
			FMX_HELP("FRANCHNPREEN", STR0068) // "Franchise não preenchida."
			lRet := .F.
		Endif
	EndIf
Return lRet


