#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#INCLUDE "OFIA410.CH"

static oFIA410ModStru

/*/{Protheus.doc} OFIA410
	Tela de configuração do DTF JD

	@author Jose Luis Silveira Filho
	@since  17/08/2021
/*/
Function OFIA410(cConta)
	local cDescricao   := STR0001
	default cConta     := ""
	Private oConfig    := OFJDDTFConfig():New()
	Private oJdConfig  := Nil
	Private oCfgAtu    := oConfig:GetConfig(cConta)
	Private lNovoCombo := GetNewPar("MV_MIL0210", .F.)

	cAccRpm := nil

	if lNovoCombo
		if cConta != "OLD"
			cDescricao := STR0001 + " - " + " Conta : " + cConta
		endif

		if empty(cConta)
			//"Não é possível acessar essa rotina diretamente quando usando configuração combo Latam, utilize programa: "
			Alert(STR0024+" OFIA512->"+STR0025+"->"+STR0026) // "Ações Relacionadas" //"Abrir Configurações DTF"
			return .F.
		endif
		cAccRpm := cConta
		oJdConfig := OFJDConfig():New(nil, cAccRpm)
	endif

	oExecView := FWViewExec():New()
	oExecView:setTitle(cDescricao)//"Diretorios DTF"
	oExecView:setSource("OFIA410")
	oExecView:setOK({ |oModel| OA410001A_Confirmar(oModel) })
	oExecView:setCancel({ || .T. })
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
Return .T.

/*/{Protheus.doc} OA410001A_Confirmar
	Salva os dados e fecha janela de configuração
	
	@type function
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
static function OA410001A_Confirmar(oForm)

	Local oDTFConfig      := OFJDDTFConfig():New()
	local oMaster  := oForm:GetModel("MASTER")
	Local nCntFor := 0
	Local cPref := ""

	For nCntFor := 1 to 2

		if nCntFor == 2 //aba de local de origem
			cPref := "O"
		EndIf

		oCfgAtu[ cPref + "CGPoll"]                     := AllTrim(oMaster:GetValue( cPref + "CGPoll"))
		oCfgAtu[ cPref + "Cotacao_Maquina"]            := AllTrim(oMaster:GetValue( cPref + "Cotacao_Maquina"))
		oCfgAtu[ cPref + "PMMANAGE"]                   := AllTrim(oMaster:GetValue( cPref + "PMMANAGE"))
		oCfgAtu[ cPref + "DPMEXT"]                     := AllTrim(oMaster:GetValue( cPref + "DPMEXT"))
		oCfgAtu[ cPref + "Warranty"]                   := AllTrim(oMaster:GetValue( cPref + "Warranty"))
		oCfgAtu[ cPref + "Incentivo_Maquina"]          := AllTrim(oMaster:GetValue( cPref + "Incentivo_Maquina"))
		oCfgAtu[ cPref + "UP_Incentivo_Maquina"]       := AllTrim(oMaster:GetValue( cPref + "UP_Incentivo_Maquina"))
		oCfgAtu[ cPref + "JDPRISM"]                    := AllTrim(oMaster:GetValue( cPref + "JDPRISM"))
		oCfgAtu[ cPref + "Parts_Info"]                 := AllTrim(oMaster:GetValue( cPref + "Parts_Info"))
		oCfgAtu[ cPref + "Parts_Locator"]              := AllTrim(oMaster:GetValue( cPref + "Parts_Locator"))
		oCfgAtu[ cPref + "Authorized_Parts_Returns"]   := AllTrim(oMaster:GetValue( cPref + "Authorized_Parts_Returns"))
		oCfgAtu[ cPref + "Parts_Surplus_Returns"]      := AllTrim(oMaster:GetValue( cPref + "Parts_Surplus_Returns"))
		oCfgAtu[ cPref + "Parts_Subs"]                 := AllTrim(oMaster:GetValue( cPref + "Parts_Subs"))
		oCfgAtu[ cPref + "SMManage"]                   := AllTrim(oMaster:GetValue( cPref + "SMManage"))
		oCfgAtu[ cPref + "DFA"]                        := AllTrim(oMaster:GetValue( cPref + "DFA"))
		oCfgAtu[ cPref + "ELIPS"]                      := AllTrim(oMaster:GetValue( cPref + "ELIPS"))
		oCfgAtu[ cPref + "NAO_CLASSIFICADOS"]          := AllTrim(oMaster:GetValue( cPref + "NAO_CLASSIFICADOS"))

		Fgx_MDirR(oCfgAtu[ cPref + "CGPoll"])
		Fgx_MDirR(oCfgAtu[ cPref + "Cotacao_Maquina"])
		Fgx_MDirR(oCfgAtu[ cPref + "PMMANAGE"])
		Fgx_MDirR(oCfgAtu[ cPref + "DPMEXT"])
		Fgx_MDirR(oCfgAtu[ cPref + "Warranty"])
		Fgx_MDirR(oCfgAtu[ cPref + "Incentivo_Maquina"])
		Fgx_MDirR(oCfgAtu[ cPref + "UP_Incentivo_Maquina"])
		Fgx_MDirR(oCfgAtu[ cPref + "JDPRISM"])
		Fgx_MDirR(oCfgAtu[ cPref + "Parts_Info"])
		Fgx_MDirR(oCfgAtu[ cPref + "Parts_Locator"])
		Fgx_MDirR(oCfgAtu[ cPref + "Authorized_Parts_Returns"])
		Fgx_MDirR(oCfgAtu[ cPref + "Parts_Surplus_Returns"])
		Fgx_MDirR(oCfgAtu[ cPref + "Parts_Subs"])
		Fgx_MDirR(oCfgAtu[ cPref + "SMManage"])
		Fgx_MDirR(oCfgAtu[ cPref + "DFA"])
		Fgx_MDirR(oCfgAtu[ cPref + "ELIPS"])
		Fgx_MDirR(oCfgAtu[ cPref + "NAO_CLASSIFICADOS"])
	Next

	oConfig:SaveConfig(oCfgAtu)

	oDTFConfig:GetConfig(cAccRpm)
	oDTFConfig:criaDirDTF()

return .t.

/*/{Protheus.doc} ViewDef
	Definição da tela principal
	
	@type function
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
Static Function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1

	oStr1   := oFIA410ModStru:GetView()

	oStr1:RemoveField('OCGPoll')
	//oStr1:RemoveField('OPMMANAGE'                )
	oStr1:RemoveField('OWarranty'                )
	oStr1:RemoveField('OIncentivo_Maquina'       )
	//oStr1:RemoveField('ODPMEXT'                  )
	oStr1:RemoveField('OJDPRISM'                  )
	oStr1:RemoveField('OParts_Info'              )
	oStr1:RemoveField('OAuthorized_Parts_Returns')
	oStr1:RemoveField('OParts_Subs'              )
	oStr1:RemoveField('ONAO_CLASSIFICADOS'       )

	oStr1:AddFolder("DTF",STR0002)//"DTFAPI"
	oStr1:AddFolder("ORIGEM",STR0023)//"Local de Origem dos arquivos"

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('TELA', 100)

	oView:AddField('FORM1', oStr1, 'MASTER')

	if lNovoCombo
		oView:AddUserButton("Edição em Lote de Caminhos (COMBO)","BUTTON", { |oView| OA4100034_TrocarPasta(oView, oModel) }) // Importar Arquivos
	endif

	oView:SetOwnerView('FORM1','TELA')
Return oView

/*/{Protheus.doc} ModelDef
	Modelo
	
	@type function
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
Static Function Modeldef()
	Local oModel
	Local oStr1

	if oFIA410ModStru == nil
		oFIA410ModStru := GetModel01()
	endif

	oStr1 := oFIA410ModStru:GetModel()

	oModel := MPFormModel():New('OFIA410')
	oModel:SetDescription(STR0003) // 'Integração John Deere'

	oModel:AddFields("MASTER",,oStr1,,,{|| OA410002A_Load01Dados() })

	oModel:getModel("MASTER"):SetDescription(STR0004)//"Configurações - DTF"

	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} GetModel01
	Dados base do funcionamento
	
	@type function
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
Static Function GetModel01()

	Local oMd1 := OFDMSStruct():New()
	Local nCntFor := 0

	For nCntFor := 1 to 2

		cPref := ""
		cFolder := "DTF"

		if nCntFor == 2 //aba de local de origem
			cPref := "O"
			cFolder := "ORIGEM"
		EndIf

		oMd1:AddField({;
			{'cTitulo'     , 'CGPoll'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'CGPoll'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0006} ;//"Diretorio CGPoll"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Cotacao_Maquina'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'Cotacao_Maquina'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0007} ; //"Diretorio Cotacao_Maquina"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'PMMANAGE'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'PMMANAGE'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0008} ; //"Diretorio PMMANAGE"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'DPMEXT'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'DPMEXT'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0009} ;//"Diretorio DPMEXT"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Warranty'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'Warranty'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0010} ;//"Diretorio Warranty"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Incentivo_Maquina'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'Incentivo_Maquina'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0011} ;//"Diretorio Incentivo_Maquina"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'UP_Incentivo_Maquina'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'UP_Incentivo_Maquina'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0022} ;//"Diretorio Incentivo_Maquina"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'JDPRISM'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'JDPRISM'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0012} ;//"Diretorio JDPRISM"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Parts_Info'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'Parts_Info'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0013} ;//"Diretorio Parts_Info"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Parts_Locator'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'Parts_Locator'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0014} ;//"Diretorio Parts_Locator"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Authorized_Parts_Returns'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'Authorized_Parts_Returns'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0015} ;//"Diretorio Authorized_Parts_Returns"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Parts_Surplus_Returns'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'Parts_Surplus_Returns'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0016} ;//"Diretorio Parts_Surplus_Returns"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Parts_Subs'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'Parts_Subs'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0017} ;//"Diretorio Parts_Subs"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'SMManage'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'SMManage'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0018} ;//"Diretorio SMManage"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'DFA'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'DFA'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0019} ;//"Diretorio DFA"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'ELIPS'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'ELIPS'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0020} ;//"Diretorio ELIPS"
		})

		oMd1:AddField({;
			{'cTitulo'     , 'NAO_CLASSIFICADOS'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref+'NAO_CLASSIFICADOS'      },;
			{'cFolder'     , cFolder      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0021} ; //"Diretorio Não Classificados"
		})

	Next

return oMd1

/*/{Protheus.doc} OA410002A_Load01Dados
	Dados da entidade principal
	
	@type function5
	@author Jose Luis Silveira Filho
	@since 17/08/2021
/*/
Static function OA410002A_Load01Dados()

//Local oDTFConfig      := OFJDDTFConfig():New()
//
//	oDTFConfig:GetConfig()
//	oDTFConfig:criaDirDTF()

Return {{;
		PadR(oCfgAtu['CGPoll'                   ],50),;
		PadR(oCfgAtu['Cotacao_Maquina'          ],50),;
		PadR(oCfgAtu['PMMANAGE'                 ],50),;
		PadR(oCfgAtu['DPMEXT'                   ],50),;
		PadR(oCfgAtu['Warranty'                 ],50),;
		PadR(oCfgAtu['Incentivo_Maquina'        ],50),;
		PadR(oCfgAtu['UP_Incentivo_Maquina'     ],50),;
		PadR(oCfgAtu['JDPRISM'                  ],50),;
		PadR(oCfgAtu['Parts_Info'               ],50),;
		PadR(oCfgAtu['Parts_Locator'            ],50),;
		PadR(oCfgAtu['Authorized_Parts_Returns' ],50),;
		PadR(oCfgAtu['Parts_Surplus_Returns'    ],50),;
		PadR(oCfgAtu['Parts_Subs'               ],50),;
		PadR(oCfgAtu['SMManage'                 ],50),;
		PadR(oCfgAtu['DFA'                      ],50),;
		PadR(oCfgAtu['ELIPS'                    ],50),;
		PadR(oCfgAtu['NAO_CLASSIFICADOS'        ],50),;
		PadR(oCfgAtu['OCGPoll'                  ],50),; //Origem
		PadR(oCfgAtu['OCotacao_Maquina'         ],50),; //Origem
		PadR(oCfgAtu['OPMMANAGE'                ],50),; //Origem
		PadR(oCfgAtu['ODPMEXT'                  ],50),; //Origem
		PadR(oCfgAtu['OWarranty'                ],50),; //Origem
		PadR(oCfgAtu['OIncentivo_Maquina'       ],50),; //Origem
		PadR(oCfgAtu['OUP_Incentivo_Maquina'    ],50),; //Origem
		PadR(oCfgAtu['OJDPRISM'                 ],50),; //Origem
		PadR(oCfgAtu['OParts_Info'              ],50),; //Origem
		PadR(oCfgAtu['OParts_Locator'           ],50),; //Origem
		PadR(oCfgAtu['OAuthorized_Parts_Returns'],50),; //Origem
		PadR(oCfgAtu['OParts_Surplus_Returns'   ],50),; //Origem
		PadR(oCfgAtu['OParts_Subs'              ],50),; //Origem
		PadR(oCfgAtu['OSMManage'                ],50),; //Origem
		PadR(oCfgAtu['ODFA'                     ],50),; //Origem
		PadR(oCfgAtu['OELIPS'                   ],50),; //Origem
		PadR(oCfgAtu['ONAO_CLASSIFICADOS'       ],50);  //Origem
	} , 0}


/*/{Protheus.doc} OA4100034_TrocarPasta
	
	
	@type function
	@author Vinicius Gati
	@since 17/11/2025
/*/
function OA4100034_TrocarPasta(oView, oModel)
	local aParamBox := {}
	local aRet := {}

	oModel := oModel:GetModel("MASTER")

	AADD(aParamBox,{1,STR0029, space(50),"","","",".T.",80,.T.}) // "Caminho sem o dealer code principal"
	if !ParamBox(aParamBox, "Caminho",@aRet,,,,,,,,.T.) //"Número do Pedido de Fábrica"
		Alert(STR0027) //'Alteração cancelada'
	else
		aRet[1] := strtran(aRet[1], "/", "\")
		if valtype(oJdConfig:GetAccount()) != "C"
			Alert(STR0028) // "Alteração cancelada, configuração não encontrada"
		else
			oModel:SetValue('CGPoll'                  , OA4100044_AjustaPath(alltrim(aRet[1]) + "\CGPoll\"                   + oJdConfig:GetAccount()))
			oModel:SetValue('Cotacao_Maquina'         , OA4100044_AjustaPath(alltrim(aRet[1]) + "\Cotacao_Maquina\"          + oJdConfig:GetAccount()))
			oModel:SetValue('PMMANAGE'                , OA4100044_AjustaPath(alltrim(aRet[1]) + "\PMMANAGE\"                 + oJdConfig:GetAccount()))
			oModel:SetValue('DPMEXT'                  , OA4100044_AjustaPath(alltrim(aRet[1]) + "\DPMEXT\"                   + oJdConfig:GetAccount()))
			oModel:SetValue('Warranty'                , OA4100044_AjustaPath(alltrim(aRet[1]) + "\Warranty\"                 + oJdConfig:GetAccount()))
			oModel:SetValue('Incentivo_Maquina'       , OA4100044_AjustaPath(alltrim(aRet[1]) + "\Incentivo_Maquina\"        + oJdConfig:GetAccount()))
			oModel:SetValue('JDPRISM'                 , OA4100044_AjustaPath(alltrim(aRet[1]) + "\JDPRISM\"                  + oJdConfig:GetAccount()))
			oModel:SetValue('Parts_Info'              , OA4100044_AjustaPath(alltrim(aRet[1]) + "\Parts_Info\"               + oJdConfig:GetAccount()))
			oModel:SetValue('Parts_Locator'           , OA4100044_AjustaPath(alltrim(aRet[1]) + "\Parts_Locator\"            + oJdConfig:GetAccount()))
			oModel:SetValue('Authorized_Parts_Returns', OA4100044_AjustaPath(alltrim(aRet[1]) + "\Authorized_Parts_Returns\" + oJdConfig:GetAccount()))
			oModel:SetValue('Parts_Surplus_Returns'   , OA4100044_AjustaPath(alltrim(aRet[1]) + "\Parts_Surplus_Returns\"    + oJdConfig:GetAccount()))
			oModel:SetValue('Parts_Subs'              , OA4100044_AjustaPath(alltrim(aRet[1]) + "\Parts_Subs\"               + oJdConfig:GetAccount()))
			oModel:SetValue('SMManage'                , OA4100044_AjustaPath(alltrim(aRet[1]) + "\SMManage\"                 + oJdConfig:GetAccount()))
			oModel:SetValue('DFA'                     , OA4100044_AjustaPath(alltrim(aRet[1]) + "\DFA\"                      + oJdConfig:GetAccount()))
			oModel:SetValue('ELIPS'                   , OA4100044_AjustaPath(alltrim(aRet[1]) + "\ELIPS\"                    + oJdConfig:GetAccount()))
			oModel:SetValue('UP_Incentivo_Maquina'    , OA4100044_AjustaPath(alltrim(aRet[1]) + "\UP_Incentivo_Maquina\"     + oJdConfig:GetAccount()))
			oModel:SetValue('NAO_CLASSIFICADOS'       , OA4100044_AjustaPath(alltrim(aRet[1]) + "\NAO_CLASSIFICADOS\"        + oJdConfig:GetAccount()))
			oView:SetModified(.T.)
		endif
	endif
return .t.


/*/{Protheus.doc} OA4100044_AjustaPath
	Tenta ajustar o path para problemas comuns como barras duplicadas, triplicadas ou invertidas
	
	@type function
	@author Vinicius Gati
	@since 17/11/2025
/*/
function OA4100044_AjustaPath(cPath)
	cPath := strtran(alltrim(cPath), "/", "\") // normaliza as barras
	cPath := strtran(cPath, "\\", "\")
	cPath := strtran(cPath, "\\", "\")
	cPath := strtran(cPath, "\\", "\") // faz isso algumas vezes pra evitar duplicação, triplicação , etc de barras
return cPath
