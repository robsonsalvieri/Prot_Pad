#include "TOTVS.CH"
#INCLUDE 'TBICONN.CH'
#include "FWCOMMAND.CH"
#include "FWMVCDEF.CH"
#include "OFIA264.ch"

Static o264Model1
Static o264Model2
Static o264Model3

/*/{Protheus.doc} OFIA264
	Carga inicial Service Operation John Deere

	@author Vinicius Gati
	@since  24/10/2022
/*/
Function OFIA264()
	Private oArHlp    := DMS_ArrayHelper():New()
	Private oSqlHlp   := DMS_SqlHelper():New()
	// Private oModel1   := OA2640034_GetModel01()
	// Private oModel2   := OA2640044_GetModel02()
	// Private oModel3   := OA2640074_GetModel03()
	Private oConfig   := OFSoConfig():New()
	Private oCfgAtu   := oConfig:GetConfig()
	Private oLogger   := DMS_Logger():New()
	Private cDe       := FGX_Timestamp()
	Private nQtdMax   := 0
	Private nQtdProc  := 0
	Private lLimita   := .f.
	Private oTimer1
	Private lExibeHlp := .f.

	if ! oConfig:isValid()
		alert(STR0001)	// "Impossível continuar! É necessário configurar a integração Dynamics John Deere através da rotina OFIA261 antes de enviar a carga inicial"
		return .f.
	endif

	aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.F.,"Fechar"},{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},;
					  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0002)	// "Carga inicial Service Operation John Deere"
	oExecView:setSource("OFIA264")
	//oExecView:setOK({ || .T. })
	oExecView:setCancel({ || .T. })
	oExecView:SetButtons(aButtons)
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)
Return .T.

/*/{Protheus.doc} ViewDef
	Definição da tela principal

	@type function
	@author Vinicius Gati
	@since 24/10/2022
/*/
Static Function ViewDef()
	Local oModel  := Modeldef()
	Local oStr1   := o264Model1:GetView()
	Local oStr2   := o264Model2:GetView()
	Local oStr3   := o264Model3:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:CreateHorizontalBox('EMCIMA', 20)
	oView:CreateHorizontalBox('EMBAIXO', 80)

	oView:CreateVerticalBox('EMBAIXOESQ', 30, 'EMBAIXO')
	oView:CreateVerticalBox('EMBAIXODIR', 70, 'EMBAIXO')

	oView:AddField('VIEW_FORM1', oStr1, 'MASTER')
	oView:AddField('VIEW_LOG1', oStr2, 'LOG1')
	oView:AddField("VIEW_LOG2", oStr3, "LOG2")

	oView:SetOwnerView('VIEW_FORM1','EMCIMA')
	oView:SetOwnerView('VIEW_LOG1','EMBAIXOESQ')
	oView:SetOwnerView('VIEW_LOG2', 'EMBAIXODIR')


	oView:EnableTitleView('VIEW_FORM1', STR0003)	// 'Configuração'
	oView:EnableTitleView('VIEW_LOG1' , STR0004)	// 'Log Principal'
	oView:EnableTitleView('VIEW_LOG2' , STR0005)	// 'Log Detalhado'

	oView:SetCloseOnOk({||.T.})
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})

	oView:addUserButton(STR0006 ,'', { |oView| OA2640014_Iniciar(oView) },,,, .t. )	// Iniciar
Return oView

/*/{Protheus.doc} ModelDef
	Modelo

	@type function
	@author Vinicius Gati
	@since 24/10/2022
/*/
Static Function Modeldef()
	Local oModel
	Local oStr1
	Local oStr2
	Local oStr3

	If o264Model1 == NIL
		o264Model1 := OA2640034_GetModel01()
		o264Model2 := OA2640044_GetModel02()
		o264Model3 := OA2640074_GetModel03()
	Endif

	oStr1 := o264Model1:GetModel()
	oStr2 := o264Model2:GetModel()
	oStr3 := o264Model3:GetModel()
	
	oModel := MPFormModel():New('OFIA264')
	oModel:SetDescription(STR0007)	// 'Configuração Blackbird'

	oModel:AddFields("MASTER",         , oStr1,,,{|| OA2640054_Load01Dados() })
	oModel:AddFields("LOG1"  , "MASTER", oStr2,,,{|| OA2640064_Load02Dados() })
	oModel:AddFields("LOG2"  , "MASTER", oStr3,,,{|| OA2640084_Load03Dados() })

	oModel:getModel("MASTER"):SetDescription(STR0003)	// "Configuração"
	oModel:getModel("LOG1"):SetDescription(STR0004)	// "Log pricipal"
	oModel:GetModel("LOG2"):SetDescription(STR0005)	// "Log detalhado"

	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} OA2640014_Iniciar
	Levanta e continua o envio da carga necessária para o SO
	fazendo somente o que ainda não foi feito

	@type function
	@author Vinicius Gati
	@since 24/10/2022
/*/
Function OA2640014_Iniciar(oView)
	local oLogger    := DMS_Logger():New()
	local cNumExt := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'OFIA264'  },;
		{'VQL_TIPO'       , 'EXTRACAO' } ;
	})

	if valtype(oTimer1) == "U"
		//oTimer1 := TTimer():New(1000, { || OA2640104_RefreshUI(oView), OA2640174_ShowEndDialog(cNumExt) }, oView:oOwner )
		//oTimer1:Activate()
		cDe := FGX_Timestamp()
		//cFilePath := oView:GetValue("MASTER", "ARQUIVO")
		cFilePath := ""

		nQtdMax   := oView:GetValue("MASTER", "QTD_MAX_REG")
		lLimita   := oView:GetValue("MASTER", "LIMITAR_SN") == "1"
		lExibeHlp := oView:GetValue("MASTER", "EXIBE_HLP") == "1"
		lVldPend  := oView:GetValue("MASTER", "VLD_PEND") == "1"


		if oView:GetValue("MASTER", "ENTIDADE") == "0"
			//if lLimita
				OA2640114_SendCustomers({ cEmpAnt , cFilAnt, cNumExt, cFilePath })
				// MsgInfo("Dados enviados")
			//else
			//	StartJob("OA2640114_SendCustomers", GetEnvServer(), .F., { cEmpAnt , cFilAnt, cNumExt, cFilePath })
			//endif
		endif
			//	if oView:GetValue("MASTER", "ENTIDADE") == "1"
			//		if lLimita
			//			OA2640124_SendContacts({cEmpAnt , cFilAnt, cNumExt, cFilePath})
			//			MsgInfo("Dados enviados")
			//		else
			//			StartJob("OA2640124_SendContacts", GetEnvServer(), .F., { cEmpAnt , cFilAnt, cNumExt, cFilePath })
			//		endif
			//	endif
		if oView:GetValue("MASTER", "ENTIDADE") == "1"
			OA2640223_SendMakes({cEmpAnt , cFilAnt, cNumExt, cFilePath, oView})
		endif
		if oView:GetValue("MASTER", "ENTIDADE") == "2"
			OA2640243_SendModels({cEmpAnt , cFilAnt, cNumExt, cFilePath, oView})
		endif
		if oView:GetValue("MASTER", "ENTIDADE") == "3"
			//if lLimita
				OA2640134_SendEquipments({cEmpAnt , cFilAnt, cNumExt, cFilePath, oView})
			//else
			//	StartJob("OA2640134_SendEquipments", GetEnvServer(), .F., { cEmpAnt , cFilAnt, cNumExt, cFilePath })
			//endif
		endif
		MsgInfo(STR0008)	// "Dados enviados"
	endif
Return .t.

/*/{Protheus.doc} OA2640034_GetModel01
	Dados base do funcionamento

	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
Static Function OA2640034_GetModel01()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'     , STR0009 },;	// "Entidade à enviar"
		{'cIdField'    , 'ENTIDADE'},;
		{'nTamanho'    , 1},;
		{'lObrigat'    , .F.},;
		{'cTooltip'    , STR0010},;	// "Escolha a entidade a ser enviada"
		{'aComboValues', {"0=" + STR0011, "1=" + STR0012, "2=" + STR0013, "3=" + STR0014}} ;	// "Clientes", "Marcas", "Modelos", "Equipamentos"
	})
	//oMd1:AddButton("Selecione o arquivo para importar", "BTN_ARQUIVO", { |oModel, oObj|  OA2640204_GetFile(oModel, oObj) } )
	//oMd1:AddField({;
	//	{'cTitulo'     , 'Arquivo'},;
	//	{'cIdField'    , 'ARQUIVO'},;
	//	{'nTamanho'    , 255},;
	//	{'lObrigat'    , .F.},;
	//	{'bValid'      , {|| .t. } },;
	//	{'bWhen'       , {|| .t.} } ;
	//})
	oMd1:AddField({;
		{'cTitulo'     , STR0019 },;	// "Registros a serem enviados"
		{'cIdField'    , 'ENVIAR'},;
		{'nTamanho'    , 1},;
		{'lObrigat'    , .F.},;
		{'cTooltip'    , STR0015},;	// "Escolha se deseja enviar todos os registros (enviados ou não) ou somente não enviados (faltantes)"
		{'aComboValues', {"0=" + STR0016, "1=" + STR0017}} ;	// "Faltantes", "Todos"
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0018},;	// 'Limitar envios?'
		{'cIdField'    , 'LIMITAR_SN'},;
		{'nTamanho'    , 1},;
		{'lObrigat'    , .T.},;
		{'cTooltip'    , STR0079 },;	// "Informe uma quantidade de registros limite a serem enviados"
		{'aComboValues', {"0=" + STR0020, "1=" + STR0021}} ; // "Não", "Sim"
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0022},;	// 'Limite'
		{'cIdField'    , 'QTD_MAX_REG'},;
		{'nTamanho'    ,  6  },;
		{'cTipo'       , 'N' },;
		{'lObrigat'    , .F. },;
		{'bWhen'       , {|| .t.} } ;
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0080},; //Exibe Help?
		{'cIdField'    , 'EXIBE_HLP'},;
		{'nTamanho'    , 1},;
		{'lObrigat'    , .F.},;
		{'cTooltip'    , STR0078},; //Escolha se deseja exibir mensagens durante o processamento.
		{'aComboValues', {"0=" + STR0020, "1=" + STR0021}} ; // "Não", "Sim"
	})
	oMd1:AddField({;
		{'cTitulo'     , STR0081},; //Valida Pendências ?
		{'cIdField'    , 'VLD_PEND'},;
		{'nTamanho'    , 1},;
		{'lObrigat'    , .F.},;
		{'cTooltip'    , STR0082},; //Escolha se deseja validar pendências durante o processamento.
		{'aComboValues', {"0=" + STR0020, "1=" + STR0021}} ; // "Não", "Sim"
	})
return oMd1

/*/{Protheus.doc} OA2640044_GetModel02
	Campo para log

	@type function
	@author Rubens Takahashi
	@since 29/06/2021
/*/
Static Function OA2640044_GetModel02()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'     , STR0004 },;	// 'Log principal'
		{'nTamanho'    , 1000 },;
		{'cTipo'       , 'M' },;
		{'cIdField'    , 'LOG' },;
		{'cTooltip'    , STR0023 } ;	// "Informe a quantidade de threads a serem utilizadas para processar os dados"
	})
return oMd1

/*/{Protheus.doc} OA2640054_Load01Dados
	Dados base para abrir a tela

	@type method
	@author Vinicius Gati
	@since 27/10/2022
/*/
Function OA2640054_Load01Dados()
Return {{" ", "0", "1", 999999, "1", "1"}, 0}

/*/{Protheus.doc} OA2640064_Load02Dados
	Dados base para abrir a tela

	@type method
	@author Vinicius Gati
	@since 27/10/2022
/*/
Function OA2640064_Load02Dados()
Return {{" "}, 0}

/*/{Protheus.doc} OA2640074_GetModel03
	Dados base para abrir a tela

	@type method
	@author Vinicius Gati
	@since 27/10/2022
/*/
Function OA2640074_GetModel03()
	Local oMd1 := OFDMSStruct():New()
	oMd1:AddField({;
		{'cTitulo'     , STR0024 },;	// 'Log secundário'
		{'nTamanho'    , 920 },;
		{'cTipo'       , 'M' },;
		{'cIdField'    , 'LOG' } ;
	})
return oMd1

/*/{Protheus.doc} OA2640084_Load03Dados
	Dados base para abrir a tela

	@type method
	@author Vinicius Gati
	@since 27/10/2022
/*/
Function OA2640084_Load03Dados()
Return {{" "}, 0}

/*/{Protheus.doc} OA2640184_SendLocations
	Envia as filiais habilitadas

	@type method
	@author Vinicius Gati
	@since 28/10/2022
/*/
// Function OA2640184_SendLocations(aParams)
// 	Local nX := 1
// 	Local oLogDb
// 	Local aLogs
// 	Local oLog
// 	Local oLogDet
// 	Local aFilHab := {}
// 	local cFilBck
// 	local cEmpBck
// 	Private oConfig
// 	Private oCfgAtu

// 	if aParams != nil
// 		cFilBck := cFilAnt
// 		cEmpBck := cEmpAnt
// 		RpcSetEnv(aParams[1], aParams[2],,,"OFI", "OFIA264")
// 		cNumExt := aParams[3]
// 	endif

// 	oLogger := DMS_Logger():New()
// 	oLogDb  := OFSoOFIA264Log():New()
// 	aLogs   := oLogDb:Get()
// 	oLog    := aLogs[1]
// 	oLogDet := aLogs[2]

// 	oConfig := OFSoConfig():New()
// 	oCfgAtu := oConfig:GetConfig()

// 	oLogDet:SetValue(":title:", STR0025)	// "Buscando dados das filiais"
// 	oLogDet:SetValue(":detail:", STR0026)	// "Aguarde"
// 	oLogDet:SetValue(":progress:", "0%")

// 	oLog:SetValue(":title:", STR0027)	// "Iniciando processo de envio de carga inicial"
// 	oLog:SetValue(":detail:", STR0028)	// "Enviando Filiais (Locations)"
// 	oLog:SetValue(":progress:", "0%")
// 	oLogDb:Grava(oLog, oLogDet)

// 	ErrorBlock({ |e| oLogger:LogPilhaChamada("OFIA264", "ERRO_LOCATIONS") })

// 	aFiliais := oCfgAtu["FILIAIS"]
// 	oLogDet:SetValue(":title:", STR0029)	// "Filiais encontradas"
// 	For nX := 1 to Len(aFiliais)
// 		oEl := aFiliais[nX]
// 		if oEl["HABILITADA"] == "1"
// 			oLogDet:SetValue(":detail:", STR0030 + oEl["FILIAL"])	// "Fazendo envio da filial"
// 			oLogDet:SetValue(":progress:", cValtoChar(nX)+ " de " + cValtoChar(len(aFiliais)))
// 			oLogDb:Grava(oLog, oLogDet)
// 			oSoLocation := OFSoLocation():New(oEl["EMPRESA"], oEl["FILIAL"])
// 			oSoLocationService := OFSoLocationService():new("LocationCreatedInDbs", oSoLocation:GetId())
// 			oSoLocationService:SendCreatedMessage(oSoLocation)
// 			aadd(aFilHab, oEl)
// 			oLogger:LogToTable({;
// 				{'VQL_AGROUP'     , 'OFIA264'  },;
// 				{'VQL_TIPO'       , 'LOCATION' },;
// 				{'VQL_CODVQL'     , cNumExt },;
// 				{'VQL_DADOS'      , STR0031 + oEl["EMPRESA"] + STR0032 + oEl["FILIAL"] + STR0033} ;	// "Empresa '"	"' Filial '"	"' enviada.
// 			})
// 		else
// 			oLogDet:SetValue(":detail:", STR0032 + oEl["FILIAL"] + STR0034)	// "Filial "	" não habilitada, pulando."
// 			oLogDet:SetValue(":progress:", cValtoChar(nX)+ " de " + cValtoChar(len(aFiliais)))
// 			oLogDb:Grava(oLog, oLogDet)
// 			oLogger:LogToTable({;
// 				{'VQL_AGROUP'     , 'OFIA264'  },;
// 				{'VQL_TIPO'       , 'LOCATION' },;
// 				{'VQL_CODVQL'     , cNumExt },;
// 				{'VQL_DADOS'      , STR0031 + oEl["EMPRESA"] + STR0032 + oEl["FILIAL"] + STR0034} ;	// "Empresa '"	"' Filial '"	"' não habilitada, pulando. "
// 			})
// 		endif
// 	Next

// 	oLog:SetValue(":title:", STR0035)	// "Processamento de filiais terminado"
// 	oLog:SetValue(":detail:", "---")
// 	oLog:SetValue(":progress:", "---")
// 	oLogDet:SetValue(":progress:", STR0036)	// "Finalizado!"
// 	oLogDb:Grava(oLog, oLogDet)
// 	cFilAnt := cFilBck
// 	cEmpAnt := cEmpBck
// 	oLogger:CloseOpened(cNumExt)
// Return .t.

/*/{Protheus.doc} OA2640104_RefreshUI
	busca os logs e mostra na tela

	@type method
	@author Vinicius Gati
	@since 28/10/2022
/*/
// Function OA2640104_RefreshUI(oView)
// 	local oLogDb := OFSoOFIA264Log():New()
// 	local aLogs := oLogDb:Get()
// 	local oLog := aLogs[1]
// 	local oLogDet := aLogs[2]
// 	oView:GetModel("LOG1"):SetValue("LOG", oLog:ToString())
// 	oView:GetModel("LOG2"):SetValue("LOG", oLogDet:ToString())
// Return oView:Refresh()

/*/{Protheus.doc} OA2640114_SendCustomers
	Envia os clintes ao SO

	@type method
	@author Vinicius Gati
	@since 28/10/2022
/*/
Function OA2640114_SendCustomers(aParams)
	Local oLogDb
	Local aLogs
	Local oLog
	Local oLogDet

	Local nX := 1
	Local oLogger
	Local cNumExt
	Local cFilePath

	Private oConfig
	Private oCfgAtu

	//if aParams != nil
		//RpcSetEnv(aParams[1], aParams[2],,,"OFI", "OFIA264")
		cNumExt := aParams[3]
		cFilePath := aParams[4]
	//endif

	oLogger := DMS_Logger():New()
	aFilHab := OA2640144_FiliaisHabilitadas()

	oLogDb  := OFSoOFIA264Log():New()
	aLogs   := oLogDb:Get()
	oLog    := aLogs[1]
	oLogDet := aLogs[2]

	oLog:SetValue(":title:", STR0037)	// "Iniciando processo de envio de clientes"
	oLog:SetValue(":detail:", STR0038)	// "Aguarde..."
	oLog:SetValue(":progress:", "0%")
	oLogDet:SetValue(":title:", STR0039)	// "Buscando dados dos clientes"
	oLogDet:SetValue(":detail:", STR0038)	// "Aguarde..."
	oLogDet:SetValue(":progress:", "0%")
	oLogDb:Grava(oLog, oLogDet)

	//if valtype(cFilePath) != "U" .and. ! Empty(cFilePath)
	//	oTable := OFSOPreImportTable():New("1", cFilePath, cNumExt, aFilHab)
	//	oTable:ImportFile()
	//endif

	For nX := 1 to Len(aFilHab)
		if nX >= 2
			exit // cliente sempre compartillhado
		endif
		cFilEmpresa := aFilHab[nX]["FILIAL"]
		conout(STR0040 + cFilEmpresa)	// "Iniciando filial "
		Sleep(2000)

		//if oTable != nil
		//	oFetcher := oTable:GetFetcher({ |this| this:AddDefScope({ |t| t:AndEq("FILIAL", xFilial("SA1")):AndEq("IMPORTACAO", oTable:cImpCode ):AndEq("A1_") }) })
		//	OA2640194_SendCustomersWithFil(aFilHab[nX]["EMPRESA"], cFilEmpresa, cNumExt, oFetcher)
		//else
			//oPagFetcher := OFPaginatedFetcher():New(VEClienteApi():New())
			OA2640194_SendCustomersWithFil(aFilHab[nX]["EMPRESA"], cFilEmpresa, cNumExt/*, oPagFetcher*/)
		//endif

		oLog:SetValue(":detail:", STR0041 + cFilEmpresa)	// "Finalizado envio de clientes da filial "
		oLogDb:Grava(oLog, oLogDet)
	Next

	oLogger:CloseOpened(cNumExt)

	oLog:SetValue(":title:", STR0042)	// "Processamento de clientes finalizado"
	oLog:SetValue(":detail:", "---")
	oLog:SetValue(":progress:", "---")
	oLogDet:SetValue(":title:", "---")
	oLogDet:SetValue(":progress:", "---")
	oLogDet:SetValue(":status:", "100%")
	oLogDb:Grava(oLog, oLogDet)
Return .t.

/*/{Protheus.doc} OA2640124_SendContacts
	Envia os clintes ao SO

	@type method
	@author Vinicius Gati
	@since 28/10/2022
/*/
//Function OA2640124_SendContacts(aParams)
//	Local oLogDb
//	Local aLogs
//	Local oLog
//	Local oLogDet
//	Local oPagFetcher
//	Local nX := 1
//	Local oLogger
//	Local cNumExt
//	Local cFilePath
//	Local oTable := nil
//	Private oConfig
//	Private oCfgAtu
//
//	if aParams != nil
//		RpcSetEnv(aParams[1], aParams[2],,,"OFI", "OFIA264")
//		cNumExt := aParams[3]
//		cFilePath := aParams[4]
//	endif
//
//	oLogger := DMS_Logger():New()
//	aFilHab := OA2640144_FiliaisHabilitadas()
//
//	oLogDb  := OFSoOFIA264Log():New()
//	aLogs   := oLogDb:Get()
//	oLog    := aLogs[1]
//	oLogDet := aLogs[2]
//
//	oLog:SetValue(":title:", "Processamento de contatos iniciando")
//	oLog:SetValue(":detail:", "Aguarde...")
//	oLog:SetValue(":progress:", "0%")
//	oLogDet:SetValue(":title:", "Buscando dados dos equipamentos")
//	oLogDet:SetValue(":detail:", "Aguarde")
//	oLogDet:SetValue(":progress:", "0%")
//	oLogDb:Grava(oLog, oLogDet)
//
//	if valtype(cFilePath) != "U" .and. ! empty(cFilePath)
//		oTable := OFSOPreImportTable():New("2", cFilePath, cNumExt, aFilHab)
//		oTable:ImportFile()
//	endif
//
//	For nX := 1 to Len(aFilHab)
//		if nX >= 2
//			exit // cliente sempre compartillhado
//		endif
//		cFilEmpresa := aFilHab[nX]["FILIAL"]
//		conout("Iniciando filial " + cFilEmpresa)
//		Sleep(2000)
//
//		if oTable != nil
//			oFetcher := oTable:GetFetcher({ |this| this:AddDefScope({ |t| t:AndEq("FILIAL", xFilial("SU5")):AndEq("IMPORTACAO", oTable:cImpCode) }) })
//			OA2640154_SendContactsWithFil(aFilHab[nX]["EMPRESA"], cFilEmpresa, cNumExt, oFetcher)
//		else
//			oPagFetcher := PaginatedFetcher():New(OFContact():New())
//			OA2640154_SendContactsWithFil(aFilHab[nX]["EMPRESA"], cFilEmpresa, cNumExt, oPagFetcher)
//		endif
//
//		oLog:SetValue(":detail:", "Finalizado envio de contatos da filial " + cFilEmpresa)
//		oLogDb:Grava(oLog, oLogDet)
//	Next
//
//	oLogger:CloseOpened(cNumExt)
//
//	oLog:SetValue(":title:", "Processamento de contatos finalizado")
//	oLog:SetValue(":detail:", "---")
//	oLog:SetValue(":progress:", "---")
//	oLogDet:SetValue(":title:", "---")
//	oLogDet:SetValue(":progress:", "---")
//	oLogDet:SetValue(":status:", "100%")
//	oLogDb:Grava(oLog, oLogDet)
//Return .t.

/*/{Protheus.doc} OA2640134_SendEquipments
	Envia os Equipamentos ao SO

	@type method
	@author Vinicius Gati
	@since 28/10/2022
/*/
Function OA2640134_SendEquipments(aParams)
	Local oLogDb
	Local aLogs
	Local oLog
	Local oLogDet

	Local nX := 1
	Local oLogger
	Local cNumExt
	Local cFilePath

	Private oConfig
	Private oCfgAtu

	//if aParams != nil
	//	RpcSetEnv(aParams[1], aParams[2],,,"OFI", "OFIA264")
		cNumExt := aParams[3]
		cFilePath := aParams[4]
	//endif

	oLogger := DMS_Logger():New()
	aFilHab := OA2640144_FiliaisHabilitadas()

	oLogDb  := OFSoOFIA264Log():New()
	aLogs   := oLogDb:Get()
	oLog    := aLogs[1]
	oLogDet := aLogs[2]

	oLog:SetValue(":title:", STR0043)	// "Processamento de equipamentos/máquinas iniciando"
	oLog:SetValue(":detail:", STR0038)	// "Aguarde..."
	oLog:SetValue(":progress:", "0%")
	oLogDet:SetValue(":title:", STR0044)	// "Buscando dados dos equipamentos"
	oLogDet:SetValue(":detail:", STR0038)	// "Aguarde..."
	oLogDet:SetValue(":progress:", "0%")
	oLogDb:Grava(oLog, oLogDet)

	//if valtype(cFilePath) != "U" .and. ! empty(cFilePath)
	//	oTable := OFSOPreImportTable():New("3", cFilePath, cNumExt, aFilHab)
	//	oTable:ImportFile()
	//endif

	For nX := 1 to Len(aFilHab)

		if nX >= 2
			exit
		endif

		cFilEmpresa := aFilHab[nX]["FILIAL"]
		conout(STR0040 + cFilEmpresa)	// "Iniciando filial "
		Sleep(2000)

		//if oTable != nil
		//	oFetcher := oTable:GetFetcher({ |this| this:AddDefScope({ |t| t:AndEq("FILIAL", xFilial("VV1")):AndEq("IMPORTACAO", oTable:cImpCode) }) })
		//	OA2640164_SendEquipmentsWithFil(aFilHab[nX]["EMPRESA"], cFilEmpresa, cNumExt, oFetcher)
		//else
		//	oPagFetcher := PaginatedFetcher():New(VEVeiculoApi():New())
			OA2640164_SendEquipmentsWithFil(aFilHab[nX]["EMPRESA"], cFilEmpresa, cNumExt,/* oPagFetcher*/, aParams[5])
		//endif

		oLog:SetValue(":detail:", STR0045 + cFilEmpresa)	// "Finalizado envio de contatos da filial "
		oLogDb:Grava(oLog, oLogDet)
	Next

	oLogger:CloseOpened(cNumExt)

	oLog:SetValue(":title:", STR0046)	// "Processamento de equipamentos/máquinas finalizado"
	oLog:SetValue(":detail:", "---")
	oLog:SetValue(":progress:", "---")
	oLogDet:SetValue(":title:", "---")
	oLogDet:SetValue(":progress:", "---")
	oLogDet:SetValue(":status:", "100%")
	oLogDb:Grava(oLog, oLogDet)
Return .t.



/*/{Protheus.doc} OA2640223_SendMakes
	Envia Marcas ao SO

	@type method
	@author Rubens Takahashi
	@since 14/06/2023
/*/
Function OA2640223_SendMakes(aParams)
	Local oLogDb
	Local aLogs
	Local oLog
	Local oLogDet

	Local nX := 1
	Local oLogger
	Local cNumExt
	Local cFilePath


	Private oConfig
	Private oCfgAtu

	if aParams != nil
		//RpcSetEnv(aParams[1], aParams[2],,,"OFI", "OFIA264")
		cNumExt := aParams[3]
		cFilePath := aParams[4]
	endif

	oLogger := DMS_Logger():New()
	aFilHab := OA2640144_FiliaisHabilitadas()

	oLogDb  := OFSoOFIA264Log():New()
	aLogs   := oLogDb:Get()
	oLog    := aLogs[1]
	oLogDet := aLogs[2]

	oLog:SetValue(":title:", STR0047)	// "Processamento de marcas iniciando"
	oLog:SetValue(":detail:", STR0038)	// "Aguarde..."
	oLog:SetValue(":progress:", "0%")
	oLogDet:SetValue(":title:", STR0048)	// "Buscando dados das marcas"
	oLogDet:SetValue(":detail:", STR0038)	// "Aguarde..."
	oLogDet:SetValue(":progress:", "0%")
	oLogDb:Grava(oLog, oLogDet)

	For nX := 1 to Len(aFilHab)
		if nX >= 2
			exit // marca sempre compartillhado
		endif
		cFilEmpresa := aFilHab[nX]["FILIAL"]
		//conout("Iniciando filial " + cFilEmpresa)
		//Sleep(2000)

		OA2640233_SendMakesWithFil(aFilHab[nX]["EMPRESA"], cFilEmpresa, cNumExt)

		oLog:SetValue(":detail:", STR0049)	// "Finalizado envio de marcas"
		oLogDb:Grava(oLog, oLogDet)
	Next

	oLogger:CloseOpened(cNumExt)

	oLog:SetValue(":title:", STR0050)	// "Processamento de marcas finalizado"
	oLog:SetValue(":detail:", "---")
	oLog:SetValue(":progress:", "---")
	oLogDet:SetValue(":title:", "---")
	oLogDet:SetValue(":progress:", "---")
	oLogDet:SetValue(":status:", "100%")
	oLogDb:Grava(oLog, oLogDet)
Return .t.



/*/{Protheus.doc} OA2640243_SendModels
	Envia Modelos ao SO

	@type method
	@author Rubens Takahashi
	@since 14/06/2023
/*/
Function OA2640243_SendModels(aParams)
	Local oLogDb
	Local aLogs
	Local oLog
	Local oLogDet

	Local nX := 1
	Local oLogger
	Local cNumExt
	Local cFilePath


	Private oConfig
	Private oCfgAtu

	if aParams != nil
		//RpcSetEnv(aParams[1], aParams[2],,,"OFI", "OFIA264")
		cNumExt := aParams[3]
		cFilePath := aParams[4]
	endif

	oLogger := DMS_Logger():New()
	aFilHab := OA2640144_FiliaisHabilitadas()

	oLogDb  := OFSoOFIA264Log():New()
	aLogs   := oLogDb:Get()
	oLog    := aLogs[1]
	oLogDet := aLogs[2]

	oLog:SetValue(":title:", STR0051)	// "Processamento de modelos iniciando"
	oLog:SetValue(":detail:", STR0038)	// "Aguarde..."
	oLog:SetValue(":progress:", "0%")
	oLogDet:SetValue(":title:", STR0052)	// "Buscando dados das modelos"
	oLogDet:SetValue(":detail:", STR0038)	// "Aguarde..."
	oLogDet:SetValue(":progress:", "0%")
	oLogDb:Grava(oLog, oLogDet)

	For nX := 1 to Len(aFilHab)
		if nX >= 2
			exit // marca sempre compartillhado
		endif
		cFilEmpresa := aFilHab[nX]["FILIAL"]
		//conout("Iniciando filial " + cFilEmpresa)
		//Sleep(2000)
		OA2640253_SendModelsWithFil(aFilHab[nX]["EMPRESA"], cFilEmpresa, cNumExt)

		oLog:SetValue(":detail:", STR0053)	// "Finalizado envio de modelos"
		oLogDb:Grava(oLog, oLogDet)
	Next

	oLogger:CloseOpened(cNumExt)

	oLog:SetValue(":title:", STR0054)	// "Processamento de modelos finalizado"
	oLog:SetValue(":detail:", "---")
	oLog:SetValue(":progress:", "---")
	oLogDet:SetValue(":title:", "---")
	oLogDet:SetValue(":progress:", "---")
	oLogDet:SetValue(":status:", "100%")
	oLogDb:Grava(oLog, oLogDet)
Return .t.


/*/{Protheus.doc} OA2640144_FiliaisHabilitadas
	Envia os Equipamentos ao SO

	@type method
	@author Vinicius Gati
	@since 28/10/2022
/*/
Function OA2640144_FiliaisHabilitadas()
	Local aFilHab := {}
	Local aFiliais
	Local nX
	Private oConfig
	Private oCfgAtu
	oConfig := OFSoConfig():New()
	oCfgAtu := oConfig:GetConfig()
	aFiliais := oCfgAtu["FILIAIS"]
	if valtype(aFiliais) == "A"
		For nX := 1 to Len(aFiliais)
			oEl := aFiliais[nX]
			if oEl["HABILITADA"] == "1"
				aadd(aFilHab, oEl)
			endif
		next
	endif
return aFilHab

/*/{Protheus.doc}
	Envia os clintes ao SO de uma filial

	@type method
	@author Vinicius Gati
	@since 28/10/2022
/*/
Function OA2640194_SendCustomersWithFil(cEmpresa, cFilEmpresa, cNumExt/*, oPagFetcher*/)

	Local oLogDb
	Local aLogs
	Local oLog
	Local oLogDet

	Local nSucesso := 0
	Local nFalha := 0
	Local oLogger

	local cSQL
	local cQAlias := "TSA1"
	local oSqlHlp := DMS_SqlHelper():New()

	Private oConfig
	Private oCfgAtu

	cFilAnt := cFilEmpresa

	oLogger := DMS_Logger():New()
	oLogDb  := OFSoOFIA264Log():New()
	aLogs   := oLogDb:Get()
	oLog    := aLogs[1]
	oLogDet := aLogs[2]


	cSQL := "SELECT SA1.R_E_C_N_O_ A1RECNO, VK7.R_E_C_N_O_ VK7RECNO " +;
		" FROM " + RetSQLName("SA1") + " SA1 " +;
		" LEFT JOIN " + RetSQLName("VK7") + " VK7 ON " +;
		" VK7_FILIAL = '" + xFilial("VK7") + "' AND VK7_A1FIL = A1_FILIAL AND VK7_A1COD = A1_COD AND VK7_A1LOJA = A1_LOJA AND VK7.D_E_L_E_T_ = ' ' " +;
		" WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +;
		" AND (VK7_CODIGO IS NULL OR VK7_BBINTG <> '1' OR VK7_BBSYNC <> '1') " +;
		" AND SA1.D_E_L_E_T_ = ' '"
//		" AND SA1.A1_MSBLQL <> '1' " +;  &&Comentado para considerar os Clientes Bloqueados - Mauro - Innovare 07/08/2023

	if lLimita
		cSQL := oSqlHlp:TopFunc(cSQL, nQtdMax)
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlias, .F., .T. )
	if !(cQAlias)->(Eof())
		oLogDet:SetValue(":title:", cValtoChar(nQtdMax) + STR0055 + Chr(10) + chr(13))	// " clientes encontrados..."
	endif
	while !(cQAlias)->(Eof())

		SA1->(dbGoTo((cQAlias)->A1RECNO))

		oModel := FWLoadModel("CRMA980")
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

		oSA1Mod := oModel:GetModel("SA1MASTER")
		//oSA1Mod:SetValue("A1_EMAIL", upper(oSA1Mod:GetValue("A1_EMAIL")))
		cAuxNome := oSA1Mod:GetValue("A1_NOME")
		oSA1Mod:SetValue("A1_NOME", "DDD")
		oSA1Mod:SetValue("A1_NOME", cAuxNome)

		If lExibeHlp
			lMSHelpAuto := .f.
		Else
			lMSHelpAuto := .t.
		Endif

		if oModel:VldData() .and. oModel:CommitData()
			nSucesso += 1
			oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFIA264'  },;
				{'VQL_TIPO'       , 'CUSTOMER' },;
				{'VQL_FILORI'     , xFilial("SA1") },;
				{'VQL_CODVQL'     , cNumExt },;
				{'VQL_DADOS'      , STR0056 + STR0057 + SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA + "' "} ;	// "sucesso: "	"Chave: '"
			})
		else
			nFalha += 1
			aErro := oModel:GetErrorMessage()
			cChave := STR0057 + SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA + "' "	// "Chave: '"
			cValue := ' [' + alltrim(aErro[01]) + ' (' + alltrim(aErro[04]) + ')] ' + STR0058 + ': [' + alltrim(aErro[06]) + ']'	// "Erro"

			oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFIA264'  },;
				{'VQL_TIPO'       , 'CUSTOMER' },;
				{'VQL_FILORI'     , xFilial("SA1") },;
				{'VQL_CODVQL'     , cNumExt },;
				{'VQL_DADOS'      , cChave + cValue } ;
			})
		endif
		oModel:DeActivate()

		oLogDb:Grava(oLog, oLogDet)

		(cQAlias)->(dbSkip())
	end

	(cQAlias)->(dbCloseArea())

	oLog:SetValue(":title:", STR0059)	// "Processamento de clientes finalizado"
	oLog:SetValue(":detail:", "---")
	oLog:SetValue(":progress:", "---")
	oLogDet:SetValue(":progress:", "---")
	oLogDb:Grava(oLog, oLogDet)


//	while oPagFetcher:HasNext()
//		if ! OA2640214_PodeProcessar()
//			exit
//		endif
//		aCustomers := oPagFetcher:GetNext()
//		if lFirst
//			oLogDet:SetValue(":title:", cValtoChar(oPagFetcher:nCount) + " clientes encontrados..." + Chr(10) + chr(13))
//			lFirst := .f.
//		endif
//		For nX := 1 to Len(aCustomers)
//			if ! OA2640214_PodeProcessar()
//				exit
//			endif
//			if type("nQtdProc") != "U"
//				nQtdProc += 1
//			endif
//			oCustomer := aCustomers[nX]
//			conout("Cliente atual: código: " + oCustomer:Get("A1_COD"))
//			oLogDet:SetValue(":detail:", "Cliente atual: código: " + oCustomer:Get("A1_COD"))
//			oLogDet:SetValue(":progress:", oPagFetcher:GetFetchProgress() + "%" + chr(10) + chr(13) + " Sucesso: " + cValToChar(nSucesso) + " falhas: " + cValToChar(nFalha))
//
//			DBSelectArea("SA1")
//			dbSetOrder(1)
//			if DbSeek(oCustomer:Get("A1_FILIAL") + oCustomer:Get("A1_COD") + oCustomer:Get("A1_LOJA"))
//
//				if SA1->A1_MSBLQL == "1"
//					loop
//				endif
//
//				VK7->(dbSetOrder(2))
//				if VK7->(dbSeek( xFilial("VK7") + SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA ))
//					if VK7->VK7_BBINTG == "1" .and. VK7->VK7_BBSYNC == "1"
//						conout("customer ja sincronizado")
//						loop
//					endif
//				endif
//
//				oModel := FWLoadModel("CRMA980")
//				oModel:SetOperation(MODEL_OPERATION_UPDATE)
//				oModel:Activate()
//
//				oSA1Mod := oModel:GetModel("SA1MASTER")
//				//oSA1Mod:SetValue("A1_EMAIL", upper(oSA1Mod:GetValue("A1_EMAIL")))
//				cAuxNome := oSA1Mod:GetValue("A1_NOME")
//				oSA1Mod:SetValue("A1_NOME", "DDD")
//				oSA1Mod:SetValue("A1_NOME", cAuxNome)
//
//				if oModel:VldData() .and. oModel:CommitData()
//					nSucesso += 1
//					oLogger:LogToTable({;
//						{'VQL_AGROUP'     , 'OFIA264'  },;
//						{'VQL_TIPO'       , 'CUSTOMER' },;
//						{'VQL_FILORI'     , xFilial("VV1") },;
//						{'VQL_CODVQL'     , cNumExt },;
//						{'VQL_DADOS'      , "sucesso: " + "Chave: '"+oCustomer:Get("A1_FILIAL") + oCustomer:Get("A1_COD") + oCustomer:Get("A1_LOJA")+"' "} ;
//					})
//				else
//					nFalha += 1
//					aErro := oModel:GetErrorMessage()
//					cChave := "Chave: '"+oCustomer:Get("A1_FILIAL") + oCustomer:Get("A1_COD") + oCustomer:Get("A1_LOJA")+"' "
//					cValue := ' [' + alltrim(aErro[01]) + ' (' + alltrim(aErro[04]) + ')] Erro: [' + alltrim(aErro[06]) + ']'
//
//					oLogger:LogToTable({;
//						{'VQL_AGROUP'     , 'OFIA264'  },;
//						{'VQL_TIPO'       , 'CUSTOMER' },;
//						{'VQL_FILORI'     , xFilial("VV1") },;
//						{'VQL_CODVQL'     , cNumExt },;
//						{'VQL_DADOS'      , cChave + cValue } ;
//					})
//				endif
//			else
//				nFalha += 1
//				oLogger:LogToTable({;
//					{'VQL_AGROUP'     , 'OFIA264'  },;
//					{'VQL_TIPO'       , 'CUSTOMER' },;
//					{'VQL_FILORI'     , xFilial("VV1") },;
//					{'VQL_CODVQL'     , cNumExt },;
//					{'VQL_DADOS'      , "Cliente não encontrado: '" + oCustomer:Get("A1_COD") + oCustomer:Get("A1_LOJA") + "' " } ;
//				})
//			endif
//			oLogDb:Grava(oLog, oLogDet)
//		Next
//		oLogDet:SetValue(":detail:", " <- pulando pagina ->")
//		oLogDet:SetValue(":progress:", oPagFetcher:GetFetchProgress() + "%")
//		oLogDb:Grava(oLog, oLogDet)
//	end
//
//	oLog:SetValue(":title:", "Processamento de clientes finalizado")
//	oLog:SetValue(":detail:", "---")
//	oLog:SetValue(":progress:", "---")
//	oLogDet:SetValue(":progress:", "---")
//	oLogDb:Grava(oLog, oLogDet)
Return .t.

/*/{Protheus.doc} OA2640154_SendContactsWithFil
	Envia os Equipamentos ao SO

	@type method
	@author Vinicius Gati
	@since 28/10/2022
/*/
// Function OA2640154_SendContactsWithFil(cEmpRodar, cFilEmpresa, cNumExt, oPagFetcher)
// 	Local lFirst := .t.
// 	Local oLogDb
// 	Local aLogs
// 	Local oLog
// 	Local oLogDet
// 	Local nX := 1
// 	Local nSucesso := 0
// 	Local nFalha := 0
// 	Local oLogger
// 	Local bDefEB := ErrorBlock()
// 	Local aContact
// 	Local cAux
// 	Private oConfig
// 	Private oCfgAtu

// 	cEmpAnt := cEmpRodar
// 	cFilAnt := cFilEmpresa

// 	oLogger := DMS_Logger():New()
// 	oLogDb  := OFSoOFIA264Log():New()
// 	aLogs   := oLogDb:Get()
// 	oLog    := aLogs[1]
// 	oLogDet := aLogs[2]

// 	while oPagFetcher:HasNext()
// 		if ! OA2640214_PodeProcessar()
// 			exit
// 		endif

// 		aContacts := oPagFetcher:GetNext()
// 		if lFirst
// 			oLogDet:SetValue(":title:", cValtoChar(oPagFetcher:nCount) + STR0060 + Chr(10) + chr(13))	// " contatos encontrados..."
// 			oLogDb:Grava(oLog, oLogDet)
// 			lFirst := .f.
// 		endif
// 		For nX := 1 to Len(aContacts)
// 			if ! OA2640214_PodeProcessar()
// 				exit
// 			endif
// 			if type("nQtdProc") != "U"
// 				nQtdProc += 1
// 			endif
// 			oContact := aContacts[nX]
// 			dbSelectArea("SU5")
// 			dbSetOrder(1) // U5_FILIAL+U5_CODCONT+U5_IDEXC
// 			if dbSeek(oContact:Get("U5_FILIAL") + oContact:Get("U5_CODCONT") + oContact:Get("U5_IDEXC"))
// 				aContact := {}
// 				aAdd(aContact,{"U5_FILIAL", oContact:Get("U5_FILIAL"), Nil})
// 				aAdd(aContact,{"U5_CODCONT", oContact:Get("U5_CODCONT"), Nil})

// 				lMsErroAuto := .f.
// 				If lExibeHlp
// 					lMSHelpAuto := .f.
// 				Else
// 					lMSHelpAuto := .t.
// 				Endif

// 				MSExecAuto({|x,y,z,b| TMKA070(x,y,z,b)},aContact, 4, /** aEnds*/,/**aPhones */)

// 				If !lMsErroAuto
// 					nSucesso += 1
// 				Else
// 					nFalha += 1
// 					cAux := STR0061 + oContact:Get("U5_CONTAT") + STR0062 + oContact:Get("U5_CODCONT")	// "Contato falhando ao salvar: "	" código: "
// 					ConOut( cAux )
// 					oLogger:LogToTable({;
// 						{'VQL_AGROUP'     , 'OFIA264'  },;
// 						{'VQL_TIPO'       , 'CONTACT' },;
// 						{'VQL_FILORI'     , xFilial("VV1") },;
// 						{'VQL_CODVQL'     , cNumExt },;
// 						{'VQL_DADOS'      , cAux } ;
// 					})
// 				endif
// 				oLogDet:SetValue(":detail:", STR0063 + oContact:Get("U5_CONTAT"))	// "Contato atual: "
// 				oLogDet:SetValue(":progress:", oPagFetcher:GetFetchProgress() + "%" + chr(10) + chr(13) + STR0064 + cValToChar(nSucesso) + STR0065 + cValToChar(nFalha))	// " Sucesso: "	" falhas: "
// 				oLogDb:Grava(oLog, oLogDet)
// 			else
// 				nFalha += 1
// 				oLogger:LogToTable({;
// 					{'VQL_AGROUP'     , 'OFIA264' },;
// 					{'VQL_TIPO'       , 'CONTACT' },;
// 					{'VQL_FILORI'     , xFilial("VV1") },;
// 					{'VQL_CODVQL'     , cNumExt },;
// 					{'VQL_DADOS'      , STR0066 + oContact:Get("U5_FILIAL") + oContact:Get("U5_CODCONT") + oContact:Get("U5_IDEXC")+"'" } ;	// "Não encontrado: '"
// 				})
// 				conout(STR0067 + oContact:Get("U5_FILIAL") + oContact:Get("U5_CODCONT") + oContact:Get("U5_IDEXC")+"'")	// "Contato não encontrado chave '"
// 			endif
// 		next
// 		ErrorBlock(bDefEB)
// 	end

// 	oLogDet:SetValue(":progress:", "100%")
// 	oLogDb:Grava(oLog, oLogDet)
// return .t.

/*/{Protheus.doc} OA2640164_SendEquipmentsWithFil
	(long_description)
	@type  Function
	@author Vinicius Gati
	@since 2022/11/18
/*/
Function OA2640164_SendEquipmentsWithFil(cEmpRodar, cFilEmpresa, cNumExt, oPagFetcher, oView)

	Local oLogDb
	Local aLogs
	Local oLog
	Local oLogDet

	Local nSucesso := 0
	Local nFalha := 0
	Local oLogger
	Local bDefEB := ErrorBlock()

	local cSQL
	local cQAlias := "TVV1"
	local oSqlHlp := DMS_SqlHelper():New()

	local cSQLVQL

	Private oConfig
	Private oCfgAtu

	cFilAnt := cFilEmpresa

	oLogger := DMS_Logger():New()
	oLogDb  := OFSoOFIA264Log():New()
	aLogs   := oLogDb:Get()
	oLog    := aLogs[1]
	oLogDet := aLogs[2]

	if oView:GetValue("MASTER", "ENVIAR") == "1" // Todos os registros, limpando VQL
		TCSqlExec("DELETE FROM " + RetSQLName("VQL") + " WHERE VQL_FILIAL = '" + xFilial("VQL") + "' AND VQL_AGROUP = 'OFIA264'" +;
			" AND VQL_TIPO   = 'EQUIPMENT'" +;
			" AND VQL_FILORI = '" + xFilial("VV1") + "' ")
	endif

	//
	VQL->(dbSetOrder(2)) // VQL_FILIAL+VQL_AGROUP+VQL_TIPO+DTOS(VQL_DATAI)+STR(VQL_HORAI)
	if ! VQL->(dbSeek(xFilial("VQL") + PadR("OFIA264", tamSX3("VQL_AGROUP")[1]) + padR("EQUIP-ENVIANDO",tamSX3("VQL_TIPO")[1])))
		reclock("VQL",.T.)
		VQL->VQL_CODIGO := GetSxeNum("VQL", "VQL_CODIGO")
		VQL->VQL_FILIAL := xFilial("VQL")
		VQL->VQL_AGROUP := padR("OFIA264", tamSX3("VQL_AGROUP")[1])
		VQL->VQL_TIPO   := padR("EQUIP-ENVIANDO",tamSX3("VQL_TIPO")[1])
		ConfirmSx8()
		VQL->(msUnlock())
	endif
	//

	cSQLVQL := " WHERE VQL_FILIAL = '" + xFilial("VQL") + "' " + ;
		  " AND VQL_AGROUP = '" + padR("OFIA264", tamSX3("VQL_AGROUP")[1]) + "' " + ;
		  " AND VQL_TIPO = '" + padR("EQUIP-ENVIANDO",tamSX3("VQL_TIPO")[1]) + "' " + ;
		  " AND D_E_L_E_T_ = ' ' "

	cSQL := ""
	cSQL += " SELECT VV1.R_E_C_N_O_ VV1RECNO"
	cSQL += "   FROM " + RetSQLName("VV1") + " VV1 "
	cSQL += "  WHERE VV1.VV1_FILIAL = '" + xFilial("VV1") + "' "
	cSQL +=    " AND ( "
	cSQL +=          " ( VV1.VV1_BBDEL = '1' ) "
	cSQL +=          " OR "
	cSQL +=          " ( VV1.VV1_BBEQTY <> ' ' "
	cSQL +=          " AND VV1.VV1_BBPEND <> '1' "
	if oView:GetValue("MASTER", "ENVIAR") == "0" // faltantes
		cSQL +=       " AND ( VV1.VV1_BBINTG <> '1' OR VV1.VV1_BBSYNC <> '1') "
	endif
	if VV1->(FieldPos("VV1_MSBLQL")) > 0
		cSQL +=       " AND VV1.VV1_MSBLQL <> '1' "
	endif
	cSQL +=          " AND (VV1.VV1_SOLCID = ' ' OR VV1.VV1_SOLCID LIKE '" + alltrim(cEmpAnt) + "%') ) " // isso é a filial, gravado no OFIA502
	cSQL +=        " ) "

	cSQL += "    AND VV1.D_E_L_E_T_ = ' ' "
	//cSQL += "    AND VV1.VV1_PROATU <> ' ' " // na doc do bb https://jdbbmockstordata001.blob.core.windows.net/$web/bb-api-docs-dev/Equipment/latest/OpenApi.html#tag/CDS-Endpoints/operation/EquipmentCreatedInDbs consta que o cliente pode ser nil
	//cSQL += " AND VV1.VV1_FABMOD <> ' ' AND VV1.VV1_COMVEI <> ' ' AND VV1.VV1_CHASSI <> ' ' "

	cSQL += "  ORDER BY VV1.VV1_BBDEL DESC, VV1.R_E_C_N_O_ "

	if lLimita
		cSQL := oSqlHlp:TopFunc(cSQL, nQtdMax)
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlias, .F., .T. )

	if !(cQAlias)->(Eof())
		oLogDet:SetValue(":title:", cValtoChar(nQtdMax) + STR0068 + Chr(10) + chr(13))	// " equipamentos encontrados..."
	endif

	while !(cQAlias)->(Eof())

		dbselectarea("VV1")
		VV1->(dbGoTo((cQAlias)->VV1RECNO))

		Conout(STR0069 + vv1->vv1_chassi)	// "transmitindo "

		TCSqlExec("UPDATE " + RetSQLName("VQL") + " SET VQL_DADOS = '" + VV1->VV1_CHAINT + "-" + VV1->VV1_CHASSI + "', VQL_DATAI = '" + DtoS(dDatabase) + "', VQL_HORAI = " + STRTRAN(SUBSTR( TIME() , 1, 5), ":", "" ) + cSQLVQL)

		aErro := {}

		If lExibeHlp
			lMSHelpAuto := .f.
		Else
			lMSHelpAuto := .t.
		Endif
		if VV1->VV1_BBDEL == "1"
			if VV1->VV1_BBINTG == "1"
				VA0700053_ExcluirBlackbird("VV1" ,(cQAlias)->VV1RECNO,3,.f.)
			endif
		else

			IF VA0700033_TransmitirBlackBird("VV1" ,(cQAlias)->VV1RECNO,3,.f.,@aErro,.f.,lVldPend)
				nSucesso += 1
			else
				nFalha += 1
				ConOut(STR0070 + VV1->VV1_FILIAL + STR0071 + VV1->VV1_CHAINT + " - " + VV1->VV1_CHASSI)	// "Máquina falhando ao salvar: "	" código: "
				//varinfo("Erro",aErro)

				cChave := STR0057 + VV1->VV1_FILIAL + VV1->VV1_CHAINT +"' "	// "Chave: '"
				cValue := STR0072	// " - Erro indisponível "
				if len(aErro) >= 6
					cValue := ' [' + alltrim(aErro[01]) + ' (' + alltrim(aErro[04]) + ')] ' + STR0058 + ': [' + alltrim(aErro[06]) + ']'	// Erro
				endif

				oLogger:LogToTable({;
					{'VQL_AGROUP'     , 'OFIA264'  },;
					{'VQL_TIPO'       , 'EQUIPMENT' },;
					{'VQL_FILORI'     , xFilial("VV1") },;
					{'VQL_CODVQL'     , cNumExt },;
					{'VQL_DADOS'      , cChave + cValue } ;
				})
			endif
			oLogDet:SetValue(":detail:", STR0073 + VV1->VV1_CHAINT + " - " + VV1->VV1_CHASSI)	// "Chassi atual: "
			oLogDb:Grava(oLog, oLogDet)

		endif
		(cQAlias)->(dbSkip())

		//closeCursorPosicione()

	end

	(cQAlias)->(dbCloseArea())

	oLogDet:SetValue(":progress:", "100%")
	oLogDb:Grava(oLog, oLogDet)
Return .t.


Function OA2640233_SendMakesWithFil(cEmpresa, cFilEmpresa, cNumExt/*, oPagFetcher*/)

	Local oLogDb
	Local aLogs
	Local oLog
	Local oLogDet

	Local nSucesso := 0
	Local nFalha := 0
	Local oLogger

	local cSQL
	local cQAlias := "TVE1"
	local oSqlHlp := DMS_SqlHelper():New()
	local aErro

	Private oConfig
	Private oCfgAtu

	cFilAnt := cFilEmpresa

	oLogger := DMS_Logger():New()
	oLogDb  := OFSoOFIA264Log():New()
	aLogs   := oLogDb:Get()
	oLog    := aLogs[1]
	oLogDet := aLogs[2]


	cSQL := "SELECT R_E_C_N_O_ VE1RECNO " +;
		" FROM " + RetSQLName("VE1") + " VE1 " +;
		" WHERE VE1.VE1_FILIAL = '" + xFilial("VE1") + "'" +;
		  " AND VE1.VE1_BBSYNC <> '1' " +;
		  " AND VE1.D_E_L_E_T_  = ' '"

	if lLimita
		cSQL := oSqlHlp:TopFunc(cSQL, nQtdMax)
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlias, .F., .T. )
	if !(cQAlias)->(Eof())
		oLogDet:SetValue(":title:", cValtoChar(nQtdMax) + STR0074 + Chr(10) + chr(13))	// " marcas encontradas..."
	endif
	while !(cQAlias)->(Eof())

		dbSelectarea("VE1")
		VE1->(dbGoTo((cQAlias)->VE1RECNO))

		aErro := {}
		If lExibeHlp
			lMSHelpAuto := .f.
		Else
			lMSHelpAuto := .t.
		Endif
		if VA0310013_TransmitirBlackBird("VE1",(cQAlias)->VE1RECNO,3,.f., @aErro)
			nSucesso += 1
			oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFIA264'  },;
				{'VQL_TIPO'       , 'MAKE' },;
				{'VQL_FILORI'     , xFilial("VE1") },;
				{'VQL_CODVQL'     , cNumExt },;
				{'VQL_DADOS'      , STR0056 + STR0057 + VE1->VE1_FILIAL + VE1->VE1_CODMAR + "' "} ;	// "sucesso: "	"Chave: '"
			})
		else
			nFalha += 1
			cChave := STR0057 + VE1->VE1_FILIAL + VE1->VE1_CODMAR + "' "	// "Chave: '"
			cValue := ' [' + alltrim(aErro[01]) + ' (' + alltrim(aErro[04]) + ')] ' + STR0058 + ': [' + alltrim(aErro[06]) + ']'	// Erro

			oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFIA264'  },;
				{'VQL_TIPO'       , 'MAKE' },;
				{'VQL_FILORI'     , xFilial("VE1") },;
				{'VQL_CODVQL'     , cNumExt },;
				{'VQL_DADOS'      , cChave + cValue } ;
			})
		endif
		oLogDb:Grava(oLog, oLogDet)

		(cQAlias)->(dbSkip())
	end

	(cQAlias)->(dbCloseArea())

	oLog:SetValue(":title:", STR0075)	// "Processamento de marcas finalizado"
	oLog:SetValue(":detail:", "---")
	oLog:SetValue(":progress:", "---")
	oLogDet:SetValue(":progress:", "---")
	oLogDb:Grava(oLog, oLogDet)

Return .t.



Function OA2640253_SendModelsWithFil(cEmpresa, cFilEmpresa, cNumExt/*, oPagFetcher*/)

	Local oLogDb
	Local aLogs
	Local oLog
	Local oLogDet

	Local nSucesso := 0
	Local nFalha := 0
	Local oLogger

	local cSQL
	local cQAlias := "TVV2"
	local oSqlHlp := DMS_SqlHelper():New()
	local aErro

	Private oConfig
	Private oCfgAtu

	cFilAnt := cFilEmpresa

	oLogger := DMS_Logger():New()
	oLogDb  := OFSoOFIA264Log():New()
	aLogs   := oLogDb:Get()
	oLog    := aLogs[1]
	oLogDet := aLogs[2]


	cSQL := "SELECT R_E_C_N_O_ VV2RECNO " +;
		" FROM " + RetSQLName("VV2") + " VV2 " +;
		" WHERE VV2.VV2_FILIAL = '" + xFilial("VV2") + "'" +;
		  " AND VV2.VV2_BBSYNC <> '1' " +;
		  " AND VV2.D_E_L_E_T_  = ' '"

	if lLimita
		cSQL := oSqlHlp:TopFunc(cSQL, nQtdMax)
	endif
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cQAlias, .F., .T. )
	if !(cQAlias)->(Eof())
		oLogDet:SetValue(":title:", cValtoChar(nQtdMax) + STR0076 + Chr(10) + chr(13))	// " modelos encontrados..."
	endif
	while !(cQAlias)->(Eof())

		dbSelectarea("VV2")
		VV2->(dbGoTo((cQAlias)->VV2RECNO))

		aErro := {}
		If lExibeHlp
			lMSHelpAuto := .f.
		Else
			lMSHelpAuto := .t.
		Endif
		if VA0300033_TransmitirBlackBird("VV2",(cQAlias)->VV2RECNO,3,.f., @aErro, .f.)
			nSucesso += 1
			oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFIA264'  },;
				{'VQL_TIPO'       , 'MODEL' },;
				{'VQL_FILORI'     , xFilial("VV2") },;
				{'VQL_CODVQL'     , cNumExt },;
				{'VQL_DADOS'      , STR0056 + STR0057 + VV2->VV2_FILIAL + VV2->VV2_CODMAR + VV2->VV2_MODVEI + VV2->VV2_SEGMOD + "' "} ;	// "sucesso: "	"Chave: '"
			})
		else
			nFalha += 1
			cChave := STR0057 + VV2->VV2_FILIAL + VV2->VV2_CODMAR + VV2->VV2_MODVEI + VV2->VV2_SEGMOD + "' "	// "Chave: '"
			cValue := ' [' + alltrim(aErro[01]) + ' (' + alltrim(aErro[04]) + ')] Erro: [' + alltrim(aErro[06]) + ']'

			oLogger:LogToTable({;
				{'VQL_AGROUP'     , 'OFIA264'  },;
				{'VQL_TIPO'       , 'MODEL' },;
				{'VQL_FILORI'     , xFilial("VV2") },;
				{'VQL_CODVQL'     , cNumExt },;
				{'VQL_DADOS'      , cChave + cValue } ;
			})
		endif
		oLogDb:Grava(oLog, oLogDet)

		(cQAlias)->(dbSkip())
	end

	(cQAlias)->(dbCloseArea())

	oLog:SetValue(":title:", STR0059)	// "Processamento de clientes finalizado"
	oLog:SetValue(":detail:", "---")
	oLog:SetValue(":progress:", "---")
	oLogDet:SetValue(":progress:", "---")
	oLogDb:Grava(oLog, oLogDet)

Return .t.










/*/{Protheus.doc} OA2640174_ShowEndDialog
	Mostra o relatório final quando acaba
	@type  Function
	@author Vinicius Gati
	@since 2022/11/18
/*/
// Function OA2640174_ShowEndDialog(cNumExt)
// 	if oLogger:isClosed(cNumExt)
// 		oTimer1:DeActivate()
// 		oTimer1 := nil
// 		OFIC020("OFIA264", "VQL_CODIGO = '" + cNumExt + "' ")
// 		cAte := FGX_Timestamp()
// 		OFIA262(" VK5_DATINC >= '"+cDe+"' .AND. VK5_DATINC <= '"+cAte+"' ")
// 		nQtdProc = 0
// 	endif
// Return .t.

/*/{Protheus.doc} OA2640204_GetFile
	Pega arquivo para importar

	@type method
	@author Vinicius Gati
	@since 05/12/2022
/*/
// function OA2640204_GetFile(oModel, oModel2)
// 	local cFilePath := cGetFile( '*.json', STR0077, 1, '', .F.,  GETF_LOCALHARD )	// "Arquivo para importação"
// 	oModel:SetValue("ARQUIVO", cFilePath)
// Return .t.

/*/{Protheus.doc} OA2640204_GetFile
	Retorna se é possivel processar ou se o limite já foi alcançado

	@type method
	@author Vinicius Gati
	@since 14/12/2022
/*/
// function OA2640214_PodeProcessar()
// 	if type("nQtdProc") == "N" .and. type("lLimita") == "L"
// 		if lLimita
// 			return nQtdProc < nQtdMax
// 		endif
// 	endif
// return .t.



// static Function closeCursorPosicione()

// 	Local aArea := FWGetArea()
// 	Local nAlias
	
// 	Local aStru
// 	Local cAliasAtu

// 	For nAlias := 0 To 1023

// 		//Pega o alias da area atual
// 		cAliasAtu := Upper(Alias(nAlias))
	
// 		//Somente se houver alias e Garantia para prevenir se realmente ta aberto, para não confiar apenas na variável pública
// 		If ! Empty(cAliasAtu) .And. Select(cAliasAtu) > 0

// 			//Pula o registro caso seja tabelas internas
// 			If Left(cAliasAtu, 3) == "MP_" .Or. ;
// 				Left(cAliasAtu, 6) == "MPUSR_" .Or. ;
// 				Left(cAliasAtu, 7) == "MPMENU_" .Or. ;
// 				Left(cAliasAtu, 6) == "MPGRP_" .Or. ;
// 				Left(cAliasAtu, 1) == "X" .Or. ;
// 				Left(cAliasAtu, 4) == "TPH_" .Or. ;
// 				Left(cAliasAtu, 9) == "PROFALIAS"
// 				Loop
// 			EndIf

// 			astru := (cAliasAtu)->(DBStruct())

// 			// Temporario - ORACLE
// 			// Na AgroBaggio estava ficando um cursor aberto de um POSICIONE na VV2 e com isso estava derrubando o sistema
// 			if len(aStru) == 1
// 				if astru[1,1] == "VV2_DESMOD"
// 					(cAliasAtu)->(dbCloseArea())
// 					loop
// 				endif
// 			endif

// 		EndIf

// 	Next

// 	FWRestArea(aArea)
	
// Return