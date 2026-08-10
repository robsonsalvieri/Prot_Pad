#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PROTHEUS.CH"

#INCLUDE "OFIA280.CH"

static oFIA280ModStru

/*/{Protheus.doc} OFIA280
	Tela de configuração do OKTA John Deere

	@author Vinicius Gati
	@since  17/01/2020
/*/
Function OFIA280()
	//Private oFIA280ModStru   := GetModel01()

	Private oConfig   := OFJDOktaConfig():New()
	Private oCfgAtu   := oConfig:GetConfig()

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0001) // "Configurações OKTA - John Deere"
	oExecView:setSource("OFIA280")
	oExecView:setOK({ |oModel| OA2800013_Confirmar(oModel) })
	oExecView:setCancel({ || .T. })
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
Return .T.

/*/{Protheus.doc} OA2800013_Confirmar
	Salva os dados e fecha janela de configuração
	
	@type function
	@author Vinicius Gati
	@since 17/01/2020
/*/
static function OA2800013_Confirmar(oForm)
	local oMaster  := oForm:GetModel("MASTER")
	local nCntFor
	local cPref
	local lAnyWithoutOfflineAcc := .f.
	local cApiSemOfflineAcc := ""

	oCfgAtu["OKTA_OAUTH2"]  := alltrim(oMaster:GetValue("OKTA_OAUTH2"))
	oCfgAtu["OKTA_ID"]  := AllTrim(oMaster:GetValue("OKTA_ID"))
	oCfgAtu["OKTA_SEC"] := AllTrim(oMaster:GetValue("OKTA_SEC"))
	oCfgAtu["OKTA_REDURI"] := AllTrim(oMaster:GetValue("OKTA_REDURI"))

	For nCntFor := 1 to 9

		Do Case
			Case nCntFor == 1 ; cPref := "WAR"
			Case nCntFor == 2 ; cPref := "PML"
			Case nCntFor == 3 ; cPref := "JDP"
			Case nCntFor == 4 ; cPref := "QTM"
			Case nCntFor == 5 ; cPref := "QTP"
			Case nCntFor == 6 ; cPref := "NFS"
			Case nCntFor == 7 ; cPref := "DTFG"
			Case nCntFor == 8 ; cPref := "DTFP"
			Case nCntFor == 9 ; cPref := "CIFT"
		EndCase

		oCfgAtu[ cPref + 'OKTA'    ] := "1"
		oCfgAtu[ cPref + 'URL'     ] := AllTrim(oMaster:GetValue( cPref + 'URL'     ))
		oCfgAtu[ cPref + 'AUTHSRV' ] := AllTrim(oMaster:GetValue( cPref + 'AUTHSRV' ))
		oCfgAtu[ cPref + 'URLAUTH' ] := AllTrim(oMaster:GetValue( cPref + 'URLAUTH' ))
		oCfgAtu[ cPref + 'SCOPE'   ] := AllTrim(oMaster:GetValue( cPref + 'SCOPE'   ))
		oCfgAtu[ cPref + 'URLWS'   ] := AllTrim(oMaster:GetValue( cPref + 'URLWS'   ))
		oCfgAtu[ cPref + 'OKTA_ID' ] := AllTrim(oMaster:GetValue( cPref + 'OKTA_ID' ))
		oCfgAtu[ cPref + 'OKTA_SEC'] := AllTrim(oMaster:GetValue( cPref + 'OKTA_SEC'))
		oCfgAtu[ cPref + 'OKTA_ID' ]  := AllTrim(oMaster:GetValue( cPref + 'OKTA_ID' ))
		oCfgAtu[ cPref + 'OKTA_SEC']  := AllTrim(oMaster:GetValue( cPref + 'OKTA_SEC' ))

		if ! "offline_access" $ AllTrim(oMaster:GetValue(cPref + 'SCOPE'))
			lAnyWithoutOfflineAcc := .t.
			cApiSemOfflineAcc += cPref + chr(13) + chr(10)
		endif

	Next nCntFor

	if lAnyWithoutOfflineAcc .and. oCfgAtu["OKTA_OAUTH2"] == "1"
		cApiSemOfflineAcc := StrTran(cApiSemOfflineAcc,"WAR", STR0003)// "Garantia"
		cApiSemOfflineAcc := StrTran(cApiSemOfflineAcc,"PML","PMLink")
		cApiSemOfflineAcc := StrTran(cApiSemOfflineAcc,"JDP","JDPoint")
		cApiSemOfflineAcc := StrTran(cApiSemOfflineAcc,"QTM","JDQuote2")
		cApiSemOfflineAcc := StrTran(cApiSemOfflineAcc,"QTP","Purchase Order")
		cApiSemOfflineAcc := StrTran(cApiSemOfflineAcc,"NFS", STR0004) // "Nota Fiscal"
		cApiSemOfflineAcc := StrTran(cApiSemOfflineAcc,"DTFG",STR0016) // "DTFGETAPI"
		cApiSemOfflineAcc := StrTran(cApiSemOfflineAcc,"DTFP",STR0017) // "DTFPUTAPI"

		// "Você tem escopos sem acesso offline, isso vai evitar o uso do scheduler para a Api."
		// "Apis sem o escopo necessário:"
		MsgInfo(STR0018 + chr(13) + chr(10) + chr(13) + chr(10) + STR0019 + chr(13) + chr(10) + cApiSemOfflineAcc, STR0020) //"Atenção"
	endif

	oConfig:SaveConfig(oCfgAtu)
return .t.

/*/{Protheus.doc} ViewDef
	Definição da tela principal
	
	@type function
	@author Vinicius Gati
	@since 17/01/2020
/*/
Static Function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1
	
	oStr1 := oFIA280ModStru:GetView()

	oStr1:AddFolder("GER",STR0002) // "Geral"
	oStr1:AddFolder("WAR",STR0003) // "Garantia"
	oStr1:AddFolder("JDP","JDPoint")
	oStr1:AddFolder("JDQ","JDQuote2")
	oStr1:AddFolder("NFS",STR0004) // "Nota fiscal de Compra"
	oStr1:AddFolder("DTFG",STR0016)//"DTFGETAPI"
	oStr1:AddFolder("DTFP",STR0017)//"DTFPUTAPI"
	oStr1:AddFolder("CIFT","CIFTAPI")//"CIFTAPI"

	oStr1:AddGroup("PML","PMLink","JDP",2)
	oStr1:AddGroup("ORD","Order Status","JDP",2)
	oStr1:AddGroup("QTM","Maintain Quote","JDQ",2)
	oStr1:AddGroup("QTP","Purchase Order","JDQ",2)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('TELA', 100)

	oView:AddField('FORM1', oStr1, 'MASTER')
	
	oView:SetOwnerView('FORM1','TELA')

	oView:AddUserButton(STR0026 /*"Auth. Scheduler"*/,"BUTTON", { |oView| OA2800024_AuthScheduler() }) // Importar Arquivos

Return oView

/*/{Protheus.doc} ModelDef
	Modelo
	
	@type function
	@author Vinicius Gati
	@since 17/01/2020
/*/
Static Function Modeldef()
	Local oModel
	Local oStr1

	if oFIA280ModStru == NIL
		oFIA280ModStru := GetModel01()
	endif
	
	oStr1 := oFIA280ModStru:GetModel()

	oModel := MPFormModel():New('OFIA280')
	oModel:SetDescription(STR0005) // 'Integração John Deere'
	
	oModel:AddFields("MASTER",,oStr1,,,{|| OA2600024_Load01Dados() })

	oModel:getModel("MASTER"):SetDescription(STR0006) // "Configurações - Okta"

	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} GetModel01
	Dados base do funcionamento
	
	@type function
	@author Vinicius Gati
	@since 17/01/2020
/*/
Static Function GetModel01()

	Local oMd1 := OFDMSStruct():New()
	Local cPref := ""
	Local nCntFor

	
	oMd1:AddField({;
		{'cTitulo'     , STR0021 },; //'oAuth2 ligado?'
		{'nTamanho'    , 1 },;
		{'aComboValues', {"0="+STR0022, "1="+STR0023} },;  //NAO/"Sim"
		{'bValid'      , { |a,b,c,d| OA50300074_ValidaOpcao(a,b,c,d, "0,1") }},;
		{'cIdField'    , 'OKTA_OAUTH2' },;
		{'cFolder'     , 'GER' },;
		{'lObrigat'    , .T. },;
		{'cTooltip'    , STR0024 }; //"Se ligado a autenticação será segura, sem necessidade de dados adicionais da equipe tecnica."
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Client ID'},;
		{'nTamanho'    , 50          },;
		{'cIdField'    , 'OKTA_ID'      },;
		{'cFolder'    , 'GER'      },;
		{'lObrigat'    , .T.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0007} ; // 'Client ID para obter Token de autenticação.'
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Client Secret'},;
		{'nTamanho'    , 100          },;
		{'cIdField'    , 'OKTA_SEC'      },;
		{'cFolder'    , 'GER'      },;
		{'lObrigat'    , .T.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0008 } ; // 'Client Secret para obter Token de autenticação.'
	})

	oMd1:AddField({;
		{'cTitulo'     , 'Redirect URI'},;
		{'nTamanho'    , 250 },;
		{'cIdField'    , 'OKTA_REDURI'      },;
		{'cFolder'    , 'GER'      },;
		{'lObrigat'    , .T.        },;
		{'cPicture'    , ''        },;
		{'cTooltip'    , STR0009 } ; // 'URI de redirecionamento.'
	})

	For nCntFor := 1 to 9

		cFolder := ""
		cGroup := ""
		Do Case
			Case nCntFor == 1
				cPref := "WAR"
				cFolder := "WAR"
			Case nCntFor == 2
				cPref := "PML"
				cFolder := "JDP"
				cGroup := "PML"
			Case nCntFor == 3
				cPref := "JDP"
				cFolder := "JDP"
				cGroup := "ORD"
			Case nCntFor == 4
				cPref := "QTM"
				cFolder := "JDQ"
				cGroup := "QTM"
			Case nCntFor == 5
				cPref := "QTP"
				cFolder := "JDQ"
				cGroup := "QTP"
			Case nCntFor == 6
				cPref := "NFS"
				cFolder := "NFS"
			Case nCntFor == 7
				cPref := "DTFG"
				cFolder := "DTFG"
			Case nCntFor == 8
				cPref := "DTFP"
				cFolder := "DTFP"
			Case nCntFor == 9
				cPref := "CIFT"
				cFolder := "CIFT"	
		EndCase

		oMd1:AddField({;
			{'cTitulo'     , 'URL Token'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'URL'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0011 } ; // 'URL para obtenção do Token'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Auth Server'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'AUTHSRV'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0012 } ; // 'ID do servidor de autenticação'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'URL Auth'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'URLAUTH'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0013 } ; // 'URL de Autenticação'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Escopo'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'SCOPE'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0014 } ; // 'Informe o escopo de conexão'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'URL WS'},;
			{'nTamanho'    , 150          },;
			{'cIdField'    , cPref + 'URLWS'      },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0015 } ; // 'URL do WebService'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Client ID'},;
			{'nTamanho'    , 50          },;
			{'cIdField'    , cPref + 'OKTA_ID'     },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0007} ; // 'Client ID para obter Token de autenticação.'
		})

		oMd1:AddField({;
			{'cTitulo'     , 'Client Secret'},;
			{'nTamanho'    , 100          },;
			{'cIdField'    , cPref + 'OKTA_SEC'     },;
			{'cFolder'    , cFolder      },;
			{'cGroup'    , cGroup      },;
			{'lObrigat'    , .F.        },;
			{'cPicture'    , ''        },;
			{'cTooltip'    , STR0008 } ; // 'Client Secret para obter Token de autenticação.'
		})

	Next nCntFor

return oMd1

/*/{Protheus.doc} OA2600024_Load01Dados
	Dados da entidade principal
	
	@type function5
	@author Vinicius Gati
	@since 17/01/2020
/*/
static function OA2600024_Load01Dados()
Return {{;
	PadR(iif(! empty(oCfgAtu['OKTA_OAUTH2']), oCfgAtu['OKTA_OAUTH2'], "0"),1) ,;
	PadR(oCfgAtu['OKTA_ID'],50) ,;
	PadR(oCfgAtu['OKTA_SEC'],100) ,;
	PadR(oCfgAtu['OKTA_REDURI'],250) ,;
	PadR(oCfgAtu['WARURL'],50) , PadR(oCfgAtu['WARAUTHSRV'],50) , PadR(oCfgAtu['WARURLAUTH'],50) , PadR(oCfgAtu['WARSCOPE'],50) , PadR(oCfgAtu['WARURLWS'],150) , PadR(oCfgAtu['WAROKTA_ID'],50) , PadR(oCfgAtu['WAROKTA_SEC'],100) ,;
	PadR(oCfgAtu['PMLURL'],50) , PadR(oCfgAtu['PMLAUTHSRV'],50) , PadR(oCfgAtu['PMLURLAUTH'],50) , PadR(oCfgAtu['PMLSCOPE'],50) , PadR(oCfgAtu['PMLURLWS'],150) , PadR(oCfgAtu['PMLOKTA_ID'],50) , PadR(oCfgAtu['PMLOKTA_SEC'],100) ,;
	PadR(oCfgAtu['JDPURL'],50) , PadR(oCfgAtu['JDPAUTHSRV'],50) , PadR(oCfgAtu['JDPURLAUTH'],50) , PadR(oCfgAtu['JDPSCOPE'],50) , PadR(oCfgAtu['JDPURLWS'],150) , PadR(oCfgAtu['JDPOKTA_ID'],50) , PadR(oCfgAtu['JDPOKTA_SEC'],100) ,;
	PadR(oCfgAtu['QTMURL'],50) , PadR(oCfgAtu['QTMAUTHSRV'],50) , PadR(oCfgAtu['QTMURLAUTH'],50) , PadR(oCfgAtu['QTMSCOPE'],50) , PadR(oCfgAtu['QTMURLWS'],150) , PadR(oCfgAtu['QTMOKTA_ID'],50) , PadR(oCfgAtu['QTMOKTA_SEC'],100) ,;
	PadR(oCfgAtu['QTPURL'],50) , PadR(oCfgAtu['QTPAUTHSRV'],50) , PadR(oCfgAtu['QTPURLAUTH'],50) , PadR(oCfgAtu['QTPSCOPE'],50) , PadR(oCfgAtu['QTPURLWS'],150) , PadR(oCfgAtu['QTPOKTA_ID'],50) , PadR(oCfgAtu['QTPOKTA_SEC'],100) ,;
	PadR(oCfgAtu['NFSURL'],50) , PadR(oCfgAtu['NFSAUTHSRV'],50) , PadR(oCfgAtu['NFSURLAUTH'],50) , PadR(oCfgAtu['NFSSCOPE'],50) , PadR(oCfgAtu['NFSURLWS'],150) , PadR(oCfgAtu['NFSOKTA_ID'],50) , PadR(oCfgAtu['NFSOKTA_SEC'],100) ,;
	PadR(oCfgAtu['DTFGURL'],50) , PadR(oCfgAtu['DTFGAUTHSRV'],50) , PadR(oCfgAtu['DTFGURLAUTH'],50) , PadR(oCfgAtu['DTFGSCOPE'],50) , PadR(oCfgAtu['DTFGURLWS'],150) , PadR(oCfgAtu['DTFGOKTA_ID'],50) , PadR(oCfgAtu['DTFGOKTA_SEC'],100) ,;
	PadR(oCfgAtu['DTFPURL'],50) , PadR(oCfgAtu['DTFPAUTHSRV'],50) , PadR(oCfgAtu['DTFPURLAUTH'],50) , PadR(oCfgAtu['DTFPSCOPE'],50) , PadR(oCfgAtu['DTFPURLWS'],150) , PadR(oCfgAtu['DTFPOKTA_ID'],50) , PadR(oCfgAtu['DTFPOKTA_SEC'],100) ,;
	PadR(oCfgAtu['CIFTURL'],50) , PadR(oCfgAtu['CIFTAUTHSRV'],50) , PadR(oCfgAtu['CIFTURLAUTH'],50) , PadR(oCfgAtu['CIFTSCOPE'],50) , PadR(oCfgAtu['CIFTURLWS'],150) , PadR(oCfgAtu['CIFTOKTA_ID'],50) , PadR(oCfgAtu['CIFTOKTA_SEC'],100)  ;
	} , 0}


/*/{Protheus.doc} OA2800024_AuthScheduler
	Fará autenticação de garantia e JDPoint para pegar tokens refresh no Scheduler.
	
	@type function
	@author Vinicius Gati
	@since 25/04/2025
/*/
function OA2800024_AuthScheduler()
	Local oOktaGar := OFJDOkta():New()
	Local oOktaPed := OFJDOkta():New()
	Local oOktaDTF := OFJDOkta():New()
	Local oOktaGET := OFJDOkta():New()
	Local cMensagem := ""

	oOktaPed:SetOrderStatusJDPoint()
	oOktaPed := oOktaPed:GetAuth()

	oOktaGar:SetWarranty()
	oOktaGar := oOktaGar:GetAuth()

	oOktaDTF:SetDTFPUTAPI()
	oOktaDTF := oOktaDTF:GetAuth()

	oOktaGET:SetDTFGETAPI()
	oOktaGET := oOktaGET:GetAuth()


	if empty(oOktaPed:_AccessToken) .or. empty(oOktaGar:_AccessToken) .or. empty(oOktaDTF:_AccessToken) .or. empty(oOktaGET:_AccessToken)
		cMensagem := STR0025 // "Erro ao autenticar nos serviço(s):"
		if empty(oOktaPed:_AccessToken)
			cMensagem += chr(13) + chr(10) + STR0003 // "Garantia"
		endif
		if empty(oOktaGar:_AccessToken)
			cMensagem += chr(13) + chr(10) + "JDPoint"
		endif
		if empty(oOktaDTF:_AccessToken)
			cMensagem += chr(13) + chr(10) + "DTF PUT"
		endif
		if empty(oOktaGET:_AccessToken)
			cMensagem += chr(13) + chr(10) + "DTF GET"
		endif

		MsgInfo(cMensagem, STR0020) // "Atenção"
	else
		MsgInfo(STR0027, STR0020) // "Autenticação realizada com sucesso!" "Atenção"
	endif

return .T.