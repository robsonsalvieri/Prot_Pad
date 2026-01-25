#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função A119APICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função A119APICnt
#DEFINE ARRAY_PRODVERS_POS_FILIAL  1
#DEFINE ARRAY_PRODVERS_POS_CODE    2
#DEFINE ARRAY_PRODVERS_POS_PROD    3
#DEFINE ARRAY_PRODVERS_POS_DTINI   4
#DEFINE ARRAY_PRODVERS_POS_DTFIM   5
#DEFINE ARRAY_PRODVERS_POS_QTDINI  6
#DEFINE ARRAY_PRODVERS_POS_QTDFIM  7
#DEFINE ARRAY_PRODVERS_POS_REVISAO 8
#DEFINE ARRAY_PRODVERS_POS_ROTEIRO 9
#DEFINE ARRAY_PRODVERS_POS_LOCAL   10
#DEFINE ARRAY_PRODVERS_SIZE        10

Static _lMrpInSMQ := FWAliasInDic("SMQ", .F.) .And. Findfunction("mrpInSMQ")

/*/{Protheus.doc} A119APICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array de versão da produção para integração.

@type  Function
@author lucas.franca
@since 11/06/2019
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A119APICnt(cInfo)
	Local nValue := ARRAY_PRODVERS_SIZE
	Do Case
		Case cInfo == "ARRAY_PRODVERS_POS_FILIAL"
			nValue := ARRAY_PRODVERS_POS_FILIAL
		Case cInfo == "ARRAY_PRODVERS_POS_CODE"
			nValue := ARRAY_PRODVERS_POS_CODE
		Case cInfo == "ARRAY_PRODVERS_POS_PROD"
			nValue := ARRAY_PRODVERS_POS_PROD
		Case cInfo == "ARRAY_PRODVERS_POS_DTINI"
			nValue := ARRAY_PRODVERS_POS_DTINI
		Case cInfo == "ARRAY_PRODVERS_POS_DTFIM"
			nValue := ARRAY_PRODVERS_POS_DTFIM
		Case cInfo == "ARRAY_PRODVERS_POS_QTDINI"
			nValue := ARRAY_PRODVERS_POS_QTDINI
		Case cInfo == "ARRAY_PRODVERS_POS_QTDFIM"
			nValue := ARRAY_PRODVERS_POS_QTDFIM
		Case cInfo == "ARRAY_PRODVERS_POS_REVISAO"
			nValue := ARRAY_PRODVERS_POS_REVISAO
		Case cInfo == "ARRAY_PRODVERS_POS_ROTEIRO"
			nValue := ARRAY_PRODVERS_POS_ROTEIRO
		Case cInfo == "ARRAY_PRODVERS_POS_LOCAL"
			nValue := ARRAY_PRODVERS_POS_LOCAL
		Case cInfo == "ARRAY_PRODVERS_SIZE"
			nValue := ARRAY_PRODVERS_SIZE
		Otherwise
			nValue := ARRAY_PRODVERS_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} PCPA119API
Eventos de integração do Cadastro de Versão da produção do MRP

@author lucas.franca
@since 11/06/2019
@version P12.1.27
/*/
CLASS PCPA119API FROM FWModelEvent
	DATA lIntegraMRP    AS LOGIC
	DATA lIntegraOnline AS LOGIC

	METHOD New() CONSTRUCTOR
	METHOD InTTS(oModel, cModelId)

ENDCLASS

/*/{Protheus.doc} NEW
Método construtor do evento de integração das integrações do cadastro de versão da produção.

@author lucas.franca
@since 11/06/2019
@version P12.1.27
/*/
METHOD New() CLASS PCPA119API

	::lIntegraMRP    := .F.
	::lIntegraOnline := .F.

	::lIntegraMRP := IntNewMRP("MRPPRODUCTIONVERSION", @::lIntegraOnline)

Return Self

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações
porém antes do final da transação.

@author lucas.franca
@since 11/06/2019
@version P12.1.27
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA119API
	Local aDadosInt := {}
	Local cOperacao := ""
	Local oMdlSVC   := oModel:GetModel("SVCMASTER")

	//Só executa a integração se estiver parametrizado como Online
	If ::lIntegraMRP == .F. .Or. ::lIntegraOnline == .F.
		Return
	EndIf

	//Adiciona nova linha no array de integração.
	aAdd(aDadosInt,Array(ARRAY_PRODVERS_SIZE))

	//Adiciona as informações no array de inclusão/atualização.
	aDadosInt[1][ARRAY_PRODVERS_POS_FILIAL ] := oMdlSVC:GetValue("VC_FILIAL")
    aDadosInt[1][ARRAY_PRODVERS_POS_CODE   ] := oMdlSVC:GetValue("VC_VERSAO")
	aDadosInt[1][ARRAY_PRODVERS_POS_PROD   ] := oMdlSVC:GetValue("VC_PRODUTO")
	aDadosInt[1][ARRAY_PRODVERS_POS_DTINI  ] := oMdlSVC:GetValue("VC_DTINI")
	aDadosInt[1][ARRAY_PRODVERS_POS_DTFIM  ] := oMdlSVC:GetValue("VC_DTFIM")
	aDadosInt[1][ARRAY_PRODVERS_POS_QTDINI ] := oMdlSVC:GetValue("VC_QTDDE")
	aDadosInt[1][ARRAY_PRODVERS_POS_QTDFIM ] := oMdlSVC:GetValue("VC_QTDATE")
	aDadosInt[1][ARRAY_PRODVERS_POS_REVISAO] := oMdlSVC:GetValue("VC_REV")
	aDadosInt[1][ARRAY_PRODVERS_POS_ROTEIRO] := oMdlSVC:GetValue("VC_ROTEIRO")
	aDadosInt[1][ARRAY_PRODVERS_POS_LOCAL]   := oMdlSVC:GetValue("VC_LOCCONS")

	//Tratativa para enviar a filial correta.
	If Empty(aDadosInt[1][ARRAY_PRODVERS_POS_FILIAL])
		aDadosInt[1][ARRAY_PRODVERS_POS_FILIAL] := xFilial("SVC")
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		cOperacao := "DELETE"
	Else
		cOperacao := "INSERT"
	EndIf

	If Len(aDadosInt) > 0
		PCPA119INT(cOperacao, aDadosInt)
	EndIf
Return Nil

/*/{Protheus.doc} PCPA119INT
Função que executa a integração da versão da produção com o MRP.

@type  Function
@author lucas.franca
@since 11/06/2019
@version P12.1.27
@param cOperation, Caracter, Operação que será executada ('DELETE'/'INSERT'/'SYNC')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param lOnlyDel  , Logic   , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param lBuffer   , Logic   , Define a sincronização em processo de buffer.
@return Nil
/*/
Function PCPA119INT(cOperation, aDados, aSuccess, aError, cUUID, lOnlyDel, lBuffer)
	Local aReturn   := {}
	Local cApi      := "MRPPRODUCTIONVERSION"
	Local lAllError := .F.
	Local nIndAux   := 0
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsonData := Nil

	Default aSuccess := {}
	Default aError   := {}
	Default lOnlyDel := .F.
	Default lBuffer  := .F.	

	nTotal := Len(aDados)
	oJsonData := JsonObject():New()
	oJsonData["items"] := Array(0)
	
	For nIndex := 1 To nTotal
	
		If _lMrpInSMQ .and. cOperation != "SYNC" .and. !mrpInSMQ(aDados[nIndex][ARRAY_PRODVERS_POS_FILIAL]) 
			Loop
		EndIf		

		aAdd(oJsonData["items"], JsonObject():New())
		nIndAux := Len(oJsonData["items"])

		oJsonData["items"][nIndAux] := JsonObject():New()
		oJsonData["items"][nIndAux]["branchId"] := aDados[nIndex][ARRAY_PRODVERS_POS_FILIAL]		

		If ! (lOnlyDel .And. cOperation == "SYNC")

			oJsonData["items"][nIndAux]["code"    ] := aDados[nIndex][ARRAY_PRODVERS_POS_FILIAL] +;
														aDados[nIndex][ARRAY_PRODVERS_POS_CODE  ] +;
														aDados[nIndex][ARRAY_PRODVERS_POS_PROD]
			If cOperation $ "|INSERT|SYNC|"
				oJsonData["items"][nIndAux]["product"      ] := aDados[nIndex][ARRAY_PRODVERS_POS_PROD]
				If !Empty(aDados[nIndex][ARRAY_PRODVERS_POS_DTINI])
					oJsonData["items"][nIndAux]["startDate"] := convDate(aDados[nIndex][ARRAY_PRODVERS_POS_DTINI])
				EndIf
				If !Empty(aDados[nIndex][ARRAY_PRODVERS_POS_DTFIM])
					oJsonData["items"][nIndAux]["endDate"] := convDate(aDados[nIndex][ARRAY_PRODVERS_POS_DTFIM])
				EndIf
				oJsonData["items"][nIndAux]["startQuantity"] := aDados[nIndex][ARRAY_PRODVERS_POS_QTDINI]
				oJsonData["items"][nIndAux]["endQuantity"  ] := aDados[nIndex][ARRAY_PRODVERS_POS_QTDFIM]
				oJsonData["items"][nIndAux]["revision"     ] := aDados[nIndex][ARRAY_PRODVERS_POS_REVISAO]
				oJsonData["items"][nIndAux]["routing"      ] := aDados[nIndex][ARRAY_PRODVERS_POS_ROTEIRO]
				oJsonData["items"][nIndAux]["warehouse"    ] := aDados[nIndex][ARRAY_PRODVERS_POS_LOCAL]
			EndIf
		EndIf
	Next nIndex

	If cOperation $ "|INSERT|SYNC|"
		If cOperation == "INSERT"
			aReturn := MrpVPPost(oJsonData)
		Else
			aReturn := MrpVPSync(oJsonData, lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '1', cUUID)
	Else
		aReturn := MrpVPDel(oJsonData)
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '2', cUUID)
	EndIf

	FreeObj(oJsonData)
	oJsonData := Nil

Return Nil

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type  Static Function
@author lucas.franca
@since 11/06/2019
@version P12.1.27
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(dData)
	Local cData := ""

	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
Return cData
