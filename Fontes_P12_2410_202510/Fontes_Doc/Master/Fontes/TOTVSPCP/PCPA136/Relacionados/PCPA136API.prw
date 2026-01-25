#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA136API.CH"

Static _nTamFil := Nil
Static _nTamCod := Nil
Static _nTamSeq := Nil
Static _nTamID  := Nil

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função A136APICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função A136APICnt
#DEFINE ARRAY_DEMAND_POS_FILIAL  1
#DEFINE ARRAY_DEMAND_POS_CODE    2
#DEFINE ARRAY_DEMAND_POS_SEQUEN  3
#DEFINE ARRAY_DEMAND_POS_PROD    4
#DEFINE ARRAY_DEMAND_POS_REV     5
#DEFINE ARRAY_DEMAND_POS_DATA    6
#DEFINE ARRAY_DEMAND_POS_TIPO    7
#DEFINE ARRAY_DEMAND_POS_DOC     8
#DEFINE ARRAY_DEMAND_POS_QUANT   9
#DEFINE ARRAY_DEMAND_POS_LOCAL   10
#DEFINE ARRAY_DEMAND_POS_OPC     11
#DEFINE ARRAY_DEMAND_POS_STR_OPC 12
#DEFINE ARRAY_DEMAND_POS_PROC    13
#DEFINE ARRAY_DEMAND_POS_TICKET  14
#DEFINE ARRAY_DEMAND_SIZE        15

Static _lMrpInSMQ := FWAliasInDic("SMQ", .F.) .And. Findfunction("mrpInSMQ")
Static _oTemp     := Nil

/*/{Protheus.doc} A136APICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array das demandas para integração.

@type  Function
@author lucas.franca
@since 16/05/2019
@version P12.1.25
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A136APICnt(cInfo)
	Local nValue := ARRAY_DEMAND_SIZE
	Do Case
	Case cInfo == "ARRAY_DEMAND_POS_FILIAL"
		nValue := ARRAY_DEMAND_POS_FILIAL
	Case cInfo == "ARRAY_DEMAND_POS_CODE"
		nValue := ARRAY_DEMAND_POS_CODE
	Case cInfo == "ARRAY_DEMAND_POS_SEQUEN"
		nValue := ARRAY_DEMAND_POS_SEQUEN
	Case cInfo == "ARRAY_DEMAND_POS_PROD"
		nValue := ARRAY_DEMAND_POS_PROD
	Case cInfo == "ARRAY_DEMAND_POS_REV"
		nValue := ARRAY_DEMAND_POS_REV
	Case cInfo == "ARRAY_DEMAND_POS_DATA"
		nValue := ARRAY_DEMAND_POS_DATA
	Case cInfo == "ARRAY_DEMAND_POS_TIPO"
		nValue := ARRAY_DEMAND_POS_TIPO
	Case cInfo == "ARRAY_DEMAND_POS_DOC"
		nValue := ARRAY_DEMAND_POS_DOC
	Case cInfo == "ARRAY_DEMAND_POS_QUANT"
		nValue := ARRAY_DEMAND_POS_QUANT
	Case cInfo == "ARRAY_DEMAND_POS_LOCAL"
		nValue := ARRAY_DEMAND_POS_LOCAL
	Case cInfo == "ARRAY_DEMAND_POS_OPC"
		nValue := ARRAY_DEMAND_POS_OPC
	Case cInfo == "ARRAY_DEMAND_POS_STR_OPC"
		nValue := ARRAY_DEMAND_POS_STR_OPC
	Case cInfo == "ARRAY_DEMAND_POS_PROC"
		nValue := ARRAY_DEMAND_POS_PROC
	Case cInfo == "ARRAY_DEMAND_SIZE"
		nValue := ARRAY_DEMAND_SIZE
	Case cInfo == "ARRAY_DEMAND_POS_TICKET"
		nValue := ARRAY_DEMAND_POS_TICKET
	Otherwise
		nValue := ARRAY_DEMAND_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} PCPA136API
Eventos de integração do Cadastro de Demandas do MRP

@author lucas.franca
@since 13/05/2019
@version P12
/*/
	CLASS PCPA136API FROM FWModelEvent
		DATA oTempTable     AS OBJECT
		DATA lIntegraMRP    AS LOGIC
		DATA lIntegraOnline AS LOGIC

		METHOD New() CONSTRUCTOR
		METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue)
		METHOD InTTS(oModel, cModelId)
		METHOD Destroy()

	ENDCLASS

/*/{Protheus.doc} NEW
Método construtor do evento de integração das integrações do cadastro de demandas.

@author lucas.franca
@since 13/05/2019
@version P12
/*/
METHOD New() CLASS PCPA136API
	//Carrega as variáveis Static.
	TamFields()

	::lIntegraMRP    := .F.
	::lIntegraOnline := .F.

	::lIntegraMRP := IntNewMRP("MRPDEMANDS", @::lIntegraOnline)

	If ::lIntegraMRP .And. ::lIntegraOnline
		If _oTemp == Nil
			_oTemp := P136APITMP()
		EndIf
		::oTempTable := _oTemp
	EndIf

Return Self

/*/{Protheus.doc} GridLinePreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação da linha do Grid

@author lucas.franca
@since 17/05/2019
@version P12
@param oSubModel , Object  , Modelo principal
@param cModelID  , Caracter, Id do submodelo
@param nLine     , Caracter, Linha do grid
@param cAction   , Caracter, Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId       , Caracter, nome do campo
@param xValue    , Caracter, Novo valor do campo
@param xCurrentVl, Caracter, Valor atual do campo
@return Nil
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentVl) CLASS PCPA136API
	Local lRet := .T.

	If oSubModel:GetOperation() == MODEL_OPERATION_UPDATE
		If cModelID == "SVR_DETAIL" .And. cAction == "SETVALUE" .And. cId != "VR_INTMRP" .And. cId != "CLEGEND"
			oSubModel:SetValue("VR_INTMRP","3")
			oSubModel:SetValue("CLEGEND",PCPA136IniLegend('3'))
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações
porém antes do final da transação.

@author lucas.franca
@since 13/05/2019
@version P12
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA136API

	//Só executa a integração se estiver parametrizado como Online
	If ::lIntegraMRP == .F. .Or. ::lIntegraOnline == .F.
		Return
	EndIf

	integraAPI(oModel, "SVR_DETAIL", Self)
	integraAPI(oModel, "SVR_GRADE", Self)

Return Nil

/*/{Protheus.doc} integraAPI
Integra dados com a API

@author brunno.costa
@since 13/05/2019
@version P12
@param oModel    , Object  , Modelo principal
@param cGridModel, Caracter, Id do submodelo com os dados para validação
@param Self      , objeto  , instancia atual desta classe
@return Nil
/*/
Static Function integraAPI(oModel, cGridModel, Self)
	Local aLines    := {}
	Local aDadosDel := {}
	Local aDadosInc := {}
	Local cRevisao  := ""
	Local lVRRev    := GetSx3Cache("VR_REV", "X3_TAMANHO") > 0
	Local nIndex    := 0
	Local nTotal    := 0
	Local nPos      := 0
	Local oMdlSVR
	Local oMdlSVB   := oModel:GetModel("SVB_MASTER")

	Default cGridModel := "SVR_DETAIL"

	oMdlSVR   := oModel:GetModel(cGridModel)

	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		nTotal := oMdlSVR:Length()
		//Adiciona todas as demandas que devem ser deletadas.
		For nIndex := 1 To nTotal
			aAdd(aDadosDel,Array(ARRAY_DEMAND_SIZE))
			nPos := Len(aDadosDel)

			//Adiciona as informações no array de exclusão
			aDadosDel[nPos][ARRAY_DEMAND_POS_FILIAL] := oMdlSVR:GetValue("VR_FILIAL",nIndex)
			aDadosDel[nPos][ARRAY_DEMAND_POS_CODE  ] := oMdlSVB:GetValue("VB_CODIGO")
			aDadosDel[nPos][ARRAY_DEMAND_POS_SEQUEN] := oMdlSVR:GetValue("VR_SEQUEN",nIndex)
		Next nIndex
	Else
		//Busca apenas as linhas que tiveram alguma alteração.
		aLines := oModel:GetModel(cGridModel):GetLinesChanged()
		nTotal := Len(aLines)

		//Adiciona as linhas que sofreram alguma modificação.
		For nIndex := 1 To nTotal
			If oMdlSVR:IsDeleted(aLines[nIndex]) .And. (oMdlSVR:IsInserted(aLines[nIndex]) .OR. oMdlSVR:GetDataID(aLines[nIndex]) == 0)
				Loop
			EndIf

			If oMdlSVR:IsDeleted(aLines[nIndex])
				//Adiciona nova linha no array de exclusão.
				aAdd(aDadosDel,Array(ARRAY_DEMAND_SIZE))
				nPos := Len(aDadosDel)

				//Adiciona as informações no array de exclusão
				aDadosDel[nPos][ARRAY_DEMAND_POS_FILIAL] := oMdlSVR:GetValue("VR_FILIAL",aLines[nIndex])
				aDadosDel[nPos][ARRAY_DEMAND_POS_CODE  ] := oMdlSVB:GetValue("VB_CODIGO")
				aDadosDel[nPos][ARRAY_DEMAND_POS_SEQUEN] := oMdlSVR:GetValue("VR_SEQUEN",aLines[nIndex])
			Else
				cRevisao := ""

				If lVRRev
					cRevisao := oMdlSVR:GetValue("VR_REV", aLines[nIndex])
				EndIf
				//Adiciona nova linha no array de inclusão/atualização.
				aAdd(aDadosInc,Array(ARRAY_DEMAND_SIZE))
				nPos := Len(aDadosInc)

				//Adiciona as informações no array de inclusão/atualização.
				aDadosInc[nPos][ARRAY_DEMAND_POS_FILIAL] := oMdlSVR:GetValue("VR_FILIAL",aLines[nIndex])
				aDadosInc[nPos][ARRAY_DEMAND_POS_CODE  ] := oMdlSVB:GetValue("VB_CODIGO")
				aDadosInc[nPos][ARRAY_DEMAND_POS_SEQUEN] := oMdlSVR:GetValue("VR_SEQUEN",aLines[nIndex])
				aDadosInc[nPos][ARRAY_DEMAND_POS_PROD  ] := oMdlSVR:GetValue("VR_PROD"  ,aLines[nIndex])
				aDadosInc[nPos][ARRAY_DEMAND_POS_REV   ] := cRevisao
				aDadosInc[nPos][ARRAY_DEMAND_POS_DATA  ] := oMdlSVR:GetValue("VR_DATA"  ,aLines[nIndex])
				aDadosInc[nPos][ARRAY_DEMAND_POS_TIPO  ] := oMdlSVR:GetValue("VR_TIPO"  ,aLines[nIndex])
				aDadosInc[nPos][ARRAY_DEMAND_POS_DOC   ] := oMdlSVR:GetValue("VR_DOC"   ,aLines[nIndex])
				aDadosInc[nPos][ARRAY_DEMAND_POS_QUANT ] := oMdlSVR:GetValue("VR_QUANT" ,aLines[nIndex])
				aDadosInc[nPos][ARRAY_DEMAND_POS_LOCAL ] := oMdlSVR:GetValue("VR_LOCAL" ,aLines[nIndex])

				If Empty(oMdlSVR:GetValue("VR_NRMRP", aLines[nIndex]))
					aDadosInc[nPos][ARRAY_DEMAND_POS_TICKET] := ""
					aDadosInc[nPos][ARRAY_DEMAND_POS_PROC  ] := "2"
				Else
					aDadosInc[nPos][ARRAY_DEMAND_POS_TICKET] := oMdlSVR:GetValue("VR_NRMRP", aLines[nIndex])
					aDadosInc[nPos][ARRAY_DEMAND_POS_PROC  ] := "1"
				EndIf

				If cGridModel == "SVR_GRADE"
					aDadosInc[nPos][ARRAY_DEMAND_POS_OPC] := oMdlSVR:GetValue("VR_MOPCGRD",aLines[nIndex])
				Else
					aDadosInc[nPos][ARRAY_DEMAND_POS_OPC] := oMdlSVR:GetValue("VR_MOPC"   ,aLines[nIndex])
				EndIf

				If cGridModel == "SVR_GRADE"
					aDadosInc[nPos][ARRAY_DEMAND_POS_STR_OPC] := oMdlSVR:GetValue("VR_OPCGRD" ,aLines[nIndex])
				Else
					aDadosInc[nPos][ARRAY_DEMAND_POS_STR_OPC] := oMdlSVR:GetValue("VR_OPC",aLines[nIndex])
				EndIf

				//Tratativa para enviar a filial correta.
				If Empty(aDadosInc[nPos][ARRAY_DEMAND_POS_FILIAL])
					//Quando é uma linha que foi incluída na grid, o modelo ainda não possui o valor da filial.
					aDadosInc[nPos][ARRAY_DEMAND_POS_FILIAL] := xFilial("SVR")
				EndIf
			EndIf
		Next nIndex
	EndIf

	If Len(aDadosDel) > 0
		PCPA136INT("DELETE", aDadosDel, Self:oTempTable)
	EndIf

	If Len(aDadosInc) > 0
		PCPA136INT("INSERT", aDadosInc, Self:oTempTable)
	EndIf

Return

/*/{Protheus.doc} Destroy
Método destrutor do evento de integração das integrações do cadastro de demandas.

@author lucas.franca
@since 15/05/2019
@version P12
/*/
METHOD Destroy() CLASS PCPA136API
	//Deleta a tabela temporária.
	If ::lIntegraMRP .And. ::lIntegraOnline
		::oTempTable:Delete()
		::oTempTable := Nil
		_oTemp := Nil
	EndIf
Return Self

/*/{Protheus.doc} PCPA136INT
Função que executa a integração de demandas com o MRP.

@type  Function
@author lucas.franca
@since 13/05/2019
@version P12.1.25
@param cOperation, Caracter, Operação que será executada ('DELETE'/'INSERT'/'SYNC')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param oTempTable, Object  , Tabela temporária para utilização no processamento da atualização. Tabela criada pela função P136APITMP.
@param aSuccess  , Array   , Carrega os registros que foram integrados com sucesso
@param aError    , Array   , Carrega os registros que não foram integrados por erro
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param lOnlyDel  , Logic   , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param lBuffer	 , Logic   , Define a sincronização em processo de buffer.
@return Nil
/*/
Function PCPA136INT(cOperation, aDados, oTempTable, aSuccess, aError, cUUID, lOnlyDel, lBuffer)
	Local aReturn   := {}
	Local cApi      := "MRPDEMANDS"
	Local lAllError := .F.
	Local nIndAux   := 0
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsonData := Nil

	Default aSuccess := {}
	Default aError   := {}
	Default cUUID    := ""
	Default lOnlyDel := .F.
	Default lBuffer  := .F.

	nTotal := Len(aDados)
	oJsonData := JsonObject():New()
	oJsonData["items"] := Array(0)

	For nIndex := 1 To nTotal

		If _lMrpInSMQ  .and. cOperation != "SYNC" .and. !mrpInSMQ(aDados[nIndex][ARRAY_DEMAND_POS_FILIAL])
			Loop	
		EndIf

		aAdd(oJsonData["items"], JsonObject():New())
		nIndAux := Len(oJsonData["items"])

		oJsonData["items"][nIndAux] := JsonObject():New()
		oJsonData["items"][nIndAux]["branchId"] := aDados[nIndex][ARRAY_DEMAND_POS_FILIAL]

		If ! (lOnlyDel .And. cOperation == "SYNC")
			oJsonData["items"][nIndAux]["code"    ] := aDados[nIndex][ARRAY_DEMAND_POS_FILIAL] +;
				aDados[nIndex][ARRAY_DEMAND_POS_CODE  ] +;
				cValToChar(aDados[nIndex][ARRAY_DEMAND_POS_SEQUEN])
			oJsonData["items"][nIndAux]["product" ] := aDados[nIndex][ARRAY_DEMAND_POS_PROD ]
			If cOperation $ "|INSERT|SYNC|"
				oJsonData["items"][nIndAux]["date"      ] := convDate(aDados[nIndex][ARRAY_DEMAND_POS_DATA ])
				oJsonData["items"][nIndAux]["revision"  ] := aDados[nIndex][ARRAY_DEMAND_POS_REV  ]
				oJsonData["items"][nIndAux]["source"    ] := getSource(aDados[nIndex][ARRAY_DEMAND_POS_TIPO])
				oJsonData["items"][nIndAux]["document"  ] := aDados[nIndex][ARRAY_DEMAND_POS_DOC  ]
				oJsonData["items"][nIndAux]["quantity"  ] := aDados[nIndex][ARRAY_DEMAND_POS_QUANT]
				oJsonData["items"][nIndAux]["warehouse" ] := aDados[nIndex][ARRAY_DEMAND_POS_LOCAL]
				oJsonData["items"][nIndAux]["demandCode"] := aDados[nIndex][ARRAY_DEMAND_POS_CODE]
				oJsonData["items"][nIndAux]["ticket"    ] := aDados[nIndex][ARRAY_DEMAND_POS_TICKET]

				If Empty(aDados[nIndex][ARRAY_DEMAND_POS_PROC])
					oJsonData["items"][nIndAux]["processed"] := '2'
				Else
					oJsonData["items"][nIndAux]["processed"] := aDados[nIndex][ARRAY_DEMAND_POS_PROC]
				EndIf

				If Empty(aDados[nIndex][ARRAY_DEMAND_POS_OPC])
					oJsonData["items"][nIndAux]["erpMemoOptional" ] := Nil
				Else
					oJsonData["items"][nIndAux]["erpMemoOptional" ] := aDados[nIndex][ARRAY_DEMAND_POS_OPC]
				EndIf

				If Empty(aDados[nIndex][ARRAY_DEMAND_POS_STR_OPC])
					oJsonData["items"][nIndAux]["erpStringOptional" ] := Nil
				Else
					oJsonData["items"][nIndAux]["erpStringOptional" ] := aDados[nIndex][ARRAY_DEMAND_POS_STR_OPC]
				EndIf

				If Empty(aDados[nIndex][ARRAY_DEMAND_POS_OPC])
					oJsonData["items"][nIndAux]["optional" ] := Nil
				Else
					oJsonData["items"][nIndAux]["optional" ] := MOpcToJson(aDados[nIndex][ARRAY_DEMAND_POS_OPC], 2)
				EndIf

			EndIf
		EndIf
	Next nIndex

	If cOperation $ "|INSERT|SYNC|"
		If cOperation == "INSERT"
			aReturn := MrpDemPost(oJsonData)
		Else
			aReturn := MrpDemSync(oJsonData, lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '1', cUUID)

		//Atualiza a flag de integração na tabela SVR
		A136UpdFlg(lAllError, aSuccess, aError, aDados, oTempTable, cUUID)
	Else
		aReturn := MrpDemDel(oJsonData)
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '2', cUUID)
	EndIf
	FreeObj(oJsonData)
	oJsonData := Nil

Return Nil

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type  Static Function
@author lucas.franca
@since 13/05/2019
@version P12.1.25
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(dData)
	Local cData := ""

	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
Return cData

/*/{Protheus.doc} getSource
Converte o Tipo de demanda da SVR (VR_TIPO) para o valor correspondente da API

@type  Static Function
@author lucas.franca
@since 16/05/2019
@version P12.1.25
@param cTipoSVR   , Caracter, Tipo de demanda da SVR
@return cSourceAPI, Caracter, Tipo de demanda para envio na API
/*/
Static Function getSource(cTipoSVR)
	Local cSourceAPI := "9"

	Do Case
	Case cTipoSVR == '1'
		cSourceAPI := '3'
	Case cTipoSVR == '3'
		cSourceAPI := '1'
	Case cTipoSVR $ '|2|4|9|'
		cSourceAPI := cTipoSVR
	EndCase
Return cSourceAPI

/*/{Protheus.doc} A136UpdFlg
Faz a atualização do status de integração nos registros da SVR.

@type  Static Function
@author lucas.franca
@since 14/05/2019
@version P12.1.25
@param lAllError , Logic   , Indica se ocorreu erro total na mensagem. Atualiza todas as demandas como erro.
@param aSuccess  , Array   , Indica os itens de demandas que foram processados com sucesso. Atualiza estes itens como integrado com sucesso.
@param aError    , Array   , Indica os itens de demandas que foram processados com erro. Atualiza estes itens como pendente de integração.
@param aDados    , Array   , ARRAY com os dados que foram enviados para a integração com o MRP.
@param oTempTable, Object  , Tabela temporária para utilização no processamento da atualização. Tabela criada pela função P136APITMP.
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@return Nil
/*/
Function A136UpdFlg(lAllError, aSuccess, aError, aDados, oTempTable, cUUID)
	Local aRegUpd    := {}
	Local nIndex     := 0
	Local nTotal     := 0

	Default cUUID := ""

	//Inicializa variáveis com o tamanho das informações.
	TamFields()

	If lAllError
		aRegUpd := {}
		nTotal := Len(aDados)
		//Carrega os índices da SVR que devem ter o VR_INTMRP atualizado para '2'
		For nIndex := 1 To nTotal
			aAdd(aRegUpd, {aDados[nIndex][ARRAY_DEMAND_POS_FILIAL], ;
				aDados[nIndex][ARRAY_DEMAND_POS_CODE  ], ;
				aDados[nIndex][ARRAY_DEMAND_POS_SEQUEN], ;
				PadR(aDados[nIndex][ARRAY_DEMAND_POS_FILIAL] +;
				aDados[nIndex][ARRAY_DEMAND_POS_CODE  ] +;
				cValToChar(aDados[nIndex][ARRAY_DEMAND_POS_SEQUEN]), _nTamID)})
		Next nIndex

		//Executa a atualização
		updRegs('2', aRegUpd, oTempTable, cUUID)
	Else
		nTotal := Len(aSuccess)
		If nTotal > 0
			aRegUpd := {}
			//Carrega os índices da SVR que devem ter o VR_INTMRP atualizado para '1'
			For nIndex := 1 To nTotal
				aAdd(aRegUpd, {P136GetInf(aSuccess[nIndex]["code"], "VR_FILIAL"), ;
					P136GetInf(aSuccess[nIndex]["code"], "VR_CODIGO"), ;
					P136GetInf(aSuccess[nIndex]["code"], "VR_SEQUEN"), ;
					PadR(aSuccess[nIndex]["code"], _nTamID)})
			Next nIndex

			//Executa a atualização
			updRegs('1', aRegUpd, oTempTable, cUUID)
		EndIf

		nTotal := Len(aError)
		If nTotal > 0
			aRegUpd := {}
			//Carrega os índices da SVR que devem ter o VR_INTMRP atualizado para '2'
			For nIndex := 1 To nTotal
				aAdd(aRegUpd, {P136GetInf(aError[nIndex]["detailedMessage"]["code"], "VR_FILIAL"), ;
					P136GetInf(aError[nIndex]["detailedMessage"]["code"], "VR_CODIGO"), ;
					P136GetInf(aError[nIndex]["detailedMessage"]["code"], "VR_SEQUEN"), ;
					PadR(aError[nIndex]["detailedMessage"]["code"], _nTamID) })
			Next nIndex

			//Executa a atualização
			updRegs('2', aRegUpd, oTempTable, cUUID)
		EndIf
	EndIf
Return

/*/{Protheus.doc} P136GetInf
Recupera uma informação do código único da demanda, formada por FILIAL+CODIGO+SEQUENCIA

@type Function
@author lucas.franca
@since 15/05/2019
@version P12.1.25
@param cCode  , Caracter, Código único da demanda
@param cField , Caracter, Campo desejado. (VR_FILIAL/VR_CODIGO/VR_SEQUEN)
@return xValue, Any     , Valor solicitado, de acordo com o parâmetro cField
/*/
Function P136GetInf(cCode, cField)
	Local xValue := Nil

	//Inicializa variáveis com o tamanho das informações.
	TamFields()

	Do Case
	Case cField == "VR_FILIAL"
		xValue := Left(cCode, _nTamFil)
	Case cField == "VR_CODIGO"
		xValue := SubStr(cCode,_nTamFil+1, _nTamCod)
	Case cField == "VR_SEQUEN"
		xValue := Val(SubStr(cCode,_nTamFil+_nTamCod+1, _nTamSeq))
	EndCase
Return xValue

/*/{Protheus.doc} P136APITMP
Monta a tabela temporária para auxiliar na atualização do VR_INTMRP.

@type  Function
@author lucas.franca
@since 15/05/2019
@version P12.1.25
@return oTempTable, Object, Objeto da tabela temporária.
/*/
Function P136APITMP()
	Local oTempTable := FwTemporaryTable():New()
	Local aFields    := {}

	//Inicializa variáveis com o tamanho das informações.
	TamFields()

	aAdd(aFields, {"FILIAL", "C", _nTamFil, 0})
	aAdd(aFields, {"CODIGO", "C", _nTamCod, 0})
	aAdd(aFields, {"SEQUEN", "N", _nTamSeq, 0})
	aAdd(aFields, {"IDREG" , "C", _nTamID , 0})

	oTempTable:SetFields(aFields)

	oTempTable:Create()
Return oTempTable


/*/{Protheus.doc} updRegs
Função que monta e executa a instrução UPDATE.

@type  Static Function
@author lucas.franca
@since 15/05/2019
@version P12.1.25
@param cStatus, Caracter, Status que será utilizado para atualizar o campo VR_INTMRP
@param aRegUpd, Array   , Array com os campos da chave única da tabela SVR para executar o update.
@param aRegUpd, Object  , Objeto da tabela temporária para auxiliar na atualização dos dados.
@param cUUID  , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@return Nil
/*/
Static Function updRegs(cStatus, aRegUpd, oTempTable, cUUID)
	Local cSqlStmt := ""
	Local cCols    := ""

	Default cUUID := ""

	//Primeiro limpa os dados da tabela temporária.
	cSqlStmt := "DELETE FROM " + oTempTable:GetRealName()
	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0001,TCSqlError() + cSqlStmt) //"Erro ao atualizar o STATUS de integração das demandas."
	EndIf

	//Insere os dados na tabela temporária.
	cCols := "FILIAL,CODIGO,SEQUEN,IDREG"

	//Insere os dados na tabela temporária.
	If TCDBInsert(oTempTable:cTableName,cCols,aRegUpd) < 0
		Final(STR0001,TCSqlError()) //"Erro ao atualizar o STATUS de integração das demandas."
	EndIf

	//Executa o UPDATE na tabela SVR
	cSqlStmt := " UPDATE " + RetSqlName("SVR")
	cSqlStmt +=    " SET VR_INTMRP = '" + cStatus + "' "
	cSqlStmt +=  " WHERE D_E_L_E_T_ = ' ' "
	cSqlStmt +=    " AND EXISTS( SELECT 1 "
	cSqlStmt +=                  " FROM " + oTempTable:GetRealName()
	cSqlStmt +=                 " WHERE FILIAL = VR_FILIAL "
	cSqlStmt +=                   " AND CODIGO = VR_CODIGO "
	cSqlStmt +=                   " AND SEQUEN = VR_SEQUEN "
	cSqlStmt +=                   " AND NOT EXISTS( SELECT 1 "
	cSqlStmt +=                                     " FROM " + RetSqlName("T4R") + " T4R "
	cSqlStmt +=                                    " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
	cSqlStmt +=                                      " AND T4R.T4R_API    = 'MRPDEMANDS' "
	cSqlStmt +=                                      " AND T4R.T4R_IDREG  = IDREG "
	cSqlStmt +=                                      " AND T4R.D_E_L_E_T_ = ' ' "
	If !Empty(cUUID)
		cSqlStmt +=                                  " AND T4R.T4R_IDPRC <> '" + cUUID + "' "
	EndIf
	cSqlStmt +=                                                                 " ) )"

	If TcSqlExec(cSqlStmt) < 0
		//Em caso de erro, finaliza o programa.
		Final(STR0001,TCSqlError() + cSqlStmt) //"Erro ao atualizar o STATUS de integração das demandas."
	EndIf
Return Nil

/*/{Protheus.doc} TamFields
Carrega as variáveis estáticas com o tamanho dos campos.

@type  Static Function
@author lucas.franca
@since 15/05/2019
@version P12.1.25
/*/
Static Function TamFields()
	If _nTamFil == Nil
		_nTamFil := GetSx3Cache("VR_FILIAL","X3_TAMANHO")
	EndIf
	If _nTamCod == Nil
		_nTamCod := GetSx3Cache("VR_CODIGO","X3_TAMANHO")
	EndIf
	If _nTamSeq == Nil
		_nTamSeq := GetSx3Cache("VR_SEQUEN","X3_TAMANHO")
	EndIf
	If _nTamID == Nil
		_nTamID := GetSx3Cache("T4R_IDREG","X3_TAMANHO")
	EndIf
Return Nil

