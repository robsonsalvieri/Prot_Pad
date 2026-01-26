#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PMobAtuCad.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PMobAtuCadMod
Classe responsável por tratar a atualização cadastral do beneficiário
na Analise de Beneficiários do sistema

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Class PMobAtuCadMod From PMobJornMod

	// Propriedades obrigatorias nas API da Mobile
	Data oParametersMap
	Data Message
	Data oConfig
	// Dados de Entrada
	Data cProtocolo
	Data nOperadora
	Data cMsHash
	Data cNomeBeneficiario
	Data cMatricula
	Data cTitMatricula
	Data aCampos
	// Dados de Saida
	Data cStatus
	Data osubmit_formularioMap

	Method New(oParametersMap) CONSTRUCTOR 

	// Metodos das regras de negocio da Classe
	Method submit_formulario()
	Method GravaForm()
	Method getsubmit_formulario()

	// Métodos de apoio para a regra de negocio
	Method GetMessage()
	
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método Construtor da Classe

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method New(oParametersMap) Class PMobAtuCadMod

	_Super:New()

	Self:lGravaLog := .T.
	Self:cArquivoLog := "pls_mobile_api_atualizacao_cadastral.log"

	Self:oParametersMap	:= oParametersMap	
	Self:Message := ""	
	Self:oConfig := Nil

	Self:cProtocolo := ""
	Self:nOperadora := 0
	Self:cMsHash := ""
	Self:cNomeBeneficiario := ""	
	Self:cMatricula := ""
	Self:cTitMatricula := ""
	Self:aCampos := ""

	Self:cStatus := ""
	Self:osubmit_formularioMap := JsonObject():New() 

Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} submit_formulario
Responsável por inserir uma nova solicitação de atualização cadastral 
para análise, o beneficiário envia seus dados pessoais, correções e 
alterações de seu cadastro.

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method submit_formulario() Class PMobAtuCadMod

	Local lRetorno := .T.
	// Dados recebidos do Json
	Self:cProtocolo := Self:oParametersMap["protocolo"]
	Self:cMsHash := Self:oParametersMap["mshash"]
	Self:nOperadora := Val(Self:oParametersMap["id_operadora"])
	Self:cNomeBeneficiario := Self:oParametersMap["nome"]
	Self:cMatricula := Self:oParametersMap["matricula"]
	Self:cTitMatricula := Self:oParametersMap["matricula_titular"]
	Self:aCampos := Self:oParametersMap["campos"]

	_Super:ImpLogApi("Protocolo Recebido: "+Self:cProtocolo)
	_Super:ImpLogApi("", .F.)
	
	BA1->(DBSetOrder(2))
	If BA1->(MsSeek(xFilial("BA1")+Self:cMatricula))

		lRetorno := Self:GravaForm()

		If lRetorno
			Self:osubmit_formularioMap["protocolo"] := _Super:SetAtributo(Self:cProtocolo, "String")
			Self:osubmit_formularioMap["mshash"] := Self:cMsHash
			Self:osubmit_formularioMap["status"] := _Super:SetAtributo(Self:cStatus, "String")
		EndIf
	Else	
		Self:Message := STR0001 // "Beneficiário não encontrado."
		lRetorno := .F.
	EndIf
	// Retorno com Crítica
	If !lRetorno
		Self:osubmit_formularioMap["data"] := {}
		Self:osubmit_formularioMap["critica"] := {}
		Self:osubmit_formularioMap["timestamp"] := FWTimeStamp(5)

		Self:osubmit_formularioMap["msg"] := _Super:SetAtributo(Self:Message, "String")	
		_Super:AddCritica(@Self:osubmit_formularioMap, 0, Self:Message, "/mobileSaude/submit_formulario")
	EndIf

	_Super:ImpLogApi("JSON de Retorno: "+Self:osubmit_formularioMap:ToJson())
	_Super:ImpLogApi(Replicate("=", 100), .F.)
	
Return lRetorno 


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaForm
Realiza a gravação do formulario pelo modelo de dados da analise de 
beneficiários (ModelDef)

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 11/03/2022
/*/
//------------------------------------------------------------------- 
Method GravaForm() Class PMobAtuCadMod

	Local lGravacao := .F.
	Local lErro := .F.
	Local nX := 0
	Local cCampoExterno := ""
	Local cCampoInterno := ""
	Local aAddCampos := {}
	Local cValueCampo := ""
	Local oDadosCampo := Nil
	Local oModel := Nil
	Local oModelBBA := Nil
	Local oModelB7L := Nil
	Local aDownload := {}
	Local lNewCampos := BBA->(FieldPos("BBA_IDOPER")) > 0 .And. BBA->(FieldPos("BBA_MSHASH")) > 0
	Local cTimeInicial := ""
	
	oModel := FWLoadModel("PLAltBenModel")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	oModelBBA := oModel:GetModel("MASTERBBA")
	oModelB7L := oModel:GetModel("DETAILB7L")

	oModelBBA:SetValue("BBA_MATRIC", Self:cMatricula)
	oModelBBA:SetValue("BBA_NROPRO", Self:cProtocolo)
	
	If lNewCampos
		oModelBBA:SetValue("BBA_IDOPER", Self:nOperadora)
		oModelBBA:SetValue("BBA_MSHASH", Self:cMsHash)
	EndIf

	_Super:ImpLogApi("*** Iniciando processamento dos campos informado no JSON ...", .F.)
	cTimeInicial := Time()

	If Len(Self:aCampos) > 0
		For nX := 1 To Len(Self:aCampos)

			cCampoExterno := Self:aCampos[nX]["name"]

			oDadosCampo := _Super:GetDeParaCampo(cCampoExterno, Nil, Nil, Nil, "0") // 0 = Campo

			If oDadosCampo["status"] .And. oDadosCampo["dados"]["ativo"] == "1" // 1 = Sim

				If oDadosCampo["dados"]["url"] == "1" // 1 = Sim
					aAdd(aDownload, {Self:aCampos[nX]["value"], Self:cProtocolo+"_"+StrZero(nX, 3)+"_"+cCampoExterno, ""})
				Else
					cCampoInterno := Upper(oDadosCampo["dados"]["campoInterno"])
					cValueCampo := Upper(Self:aCampos[nX]["value"])

					If cCampoInterno == "BA1_TELEFO"
						If !Empty(cValueCampo) .And. Len(cValueCampo) >= 3

							aAdd(aAddCampos, {"BA1_DDD", Substr(cValueCampo, 1, 2)})
							cValueCampo := Substr(cValueCampo, 3)

						EndIf 
					EndIf

					If nX > 1
						oModelB7L:AddLine()
					EndIf

					oModelB7L:SetValue("B7L_CAMPO", cCampoInterno)
					oModelB7L:SetValue("B7L_VLPOS", cValueCampo)
					oModelB7L:SetValue("B7L_USER", "MOBILE")			

					If !Empty(oModel:GetErrorMessage()[6])
						Self:Message := oModel:GetErrorMessage()[6]
						lErro := .T.
						Exit
					EndIf	
				EndIf
			Else
				Self:Message := cCampoExterno+STR0002 // " não configurado no cadastro de de/para, portanto não pode ser utilizado."
				lErro := .T.
				Exit
			EndIf

		Next nX

		If !lErro .And. Len(aAddCampos) > 0
			For nX := 1 To Len(aAddCampos)

				oModelB7L:AddLine()

				oModelB7L:SetValue("B7L_CAMPO", aAddCampos[nX][1])
				oModelB7L:SetValue("B7L_VLPOS", aAddCampos[nX][2])
				oModelB7L:SetValue("B7L_USER", "MOBILE")			

				If !Empty(oModel:GetErrorMessage()[6])
					Self:Message := oModel:GetErrorMessage()[6]
					lErro := .T.
					Exit
				EndIf

			Next nX
		EndIf

	EndIf

	_Super:ImpLogApi("*** Fim do processamento dos campos, tempo gasto: "+ElapTime(cTimeInicial, Time()), .F.)

	If lErro
		_Super:ImpLogApi("*** Falha no processamento dos campos: "+Self:Message, .F.)
	Else
		_Super:ImpLogApi("*** Processamento dos campos realizado com sucesso!", .F.)		
	EndIf

	_Super:ImpLogApi("", .F.)

	If !lErro .And. Len(aDownload) > 0
		_Super:ImpLogApi("*** Iniciando download dos arquivos recebidos...", .F.)
		cTimeInicial := Time()

		If !_Super:DownloadArquivos(@aDownload)
			Self:Message := STR0003 // "Não foi possivel realizar o download do arquivo enviado."
			lErro := .T.
		EndIf

		If lErro
			_Super:ImpLogApi("*** Falha no download, tempo gasto: "+ElapTime(cTimeInicial, Time()), .F.)
		Else
			_Super:ImpLogApi("*** Download realizado com suceso, tempo gasto: "+ElapTime(cTimeInicial, Time()), .F.)
		EndIf

		_Super:ImpLogApi("", .F.)
	EndIf

	If !lErro	
		_Super:ImpLogApi("*** Iniciando validação dos dados no modelo...", .F.)
		cTimeInicial := Time()

		If oModel:VldData()

			_Super:ImpLogApi("*** Validação realizada com sucesso, tempo gasto: "+ElapTime(cTimeInicial, Time()), .F.)
			_Super:ImpLogApi("", .F.)

			_Super:ImpLogApi("*** Iniciando a gravação do modelo ...", .F.)
			cTimeInicial := Time()

			oModel:CommitData()	

			_Super:ImpLogApi("*** Fim da gravação do modelo, tempo gasto: "+ElapTime(cTimeInicial, Time()), .F.)
			_Super:ImpLogApi("", .F.)

			oDadosCampo := _Super:GetDeParaCampo("status", "BBA_STATUS", Nil, BBA->BBA_STATUS, "1") // 1 = Valor

			Self:cStatus := IIf(oDadosCampo["status"], oDadosCampo["dados"]["valorExterno"], "")
			
			If Len(aDownload) > 0
				_Super:ImpLogApi("*** Iniciando a upload dos arquivos recebidos no protocolo...", .F.)
				cTimeInicial := Time()

				Self:AnexarArquivos(aDownload, "BBA", xFilial("BBA")+BBA->BBA_CODSEQ) 

				_Super:ImpLogApi("*** Fim do upload, tempo gasto: "+ElapTime(cTimeInicial, Time()), .F.)
				_Super:ImpLogApi("", .F.)
			EndIf
			
			lGravacao := .T.
		Else
			Self:Message := oModel:GetErrorMessage()[6] // Mensagem de Erro [6]
			lGravacao := .F.

			_Super:ImpLogApi("*** Falha na Validação: "+Self:Message, .F.)
			_Super:ImpLogApi("", .F.)
		EndIf
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	FreeObj(oModel)
	oModel := Nil

	_Super:ImpLogApi("Fim do processamento do protocolo!")
	_Super:ImpLogApi("", .F.)

Return lGravacao



//-------------------------------------------------------------------
/*/{Protheus.doc} getsubmit_formulario
Retorna o Map da solicitiação de atualização cadastral

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method getsubmit_formulario() Class PMobAtuCadMod
Return Self:osubmit_formularioMap


//-------------------------------------------------------------------
/*/{Protheus.doc} GetMessage
Retorna mensagens de erro dos métodos

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 02/03/2022
/*/
//------------------------------------------------------------------- 
Method GetMessage() Class PMobAtuCadMod
Return Self:Message