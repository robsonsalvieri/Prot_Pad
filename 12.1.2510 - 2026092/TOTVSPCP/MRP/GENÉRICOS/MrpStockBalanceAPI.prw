#INCLUDE "TOTVS.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função EstqAPICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função EstqAPICnt
#DEFINE ARRAY_ESTOQUE_POS_FILIAL   1
#DEFINE ARRAY_ESTOQUE_POS_PROD     2
#DEFINE ARRAY_ESTOQUE_POS_LOCAL    3
#DEFINE ARRAY_ESTOQUE_POS_LOTE     4
#DEFINE ARRAY_ESTOQUE_POS_SUBLOTE  5
#DEFINE ARRAY_ESTOQUE_POS_VALIDADE 6
#DEFINE ARRAY_ESTOQUE_POS_QTD      7
#DEFINE ARRAY_ESTOQUE_POS_QTD_NPT  8
#DEFINE ARRAY_ESTOQUE_POS_QTD_TNP  9
#DEFINE ARRAY_ESTOQUE_POS_QTD_IND 10
#DEFINE ARRAY_ESTOQUE_POS_QTD_BLQ 11
#DEFINE ARRAY_ESTOQUE_POS_QTD_CQ  12
#DEFINE ARRAY_ESTOQUE_POS_CODE    13
#DEFINE ARRAY_ESTOQUE_SIZE        13

/*/{Protheus.doc} EstqAPICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array de pedido de compra para integração.

@type  Function
@author brunno.costa
@since 06/08/2019
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function EstqAPICnt(cInfo)
	Local nValue := ARRAY_ESTOQUE_SIZE
	Do Case
		Case cInfo == "ARRAY_ESTOQUE_POS_FILIAL"
			nValue := ARRAY_ESTOQUE_POS_FILIAL
		Case cInfo == "ARRAY_ESTOQUE_POS_PROD"
			nValue := ARRAY_ESTOQUE_POS_PROD
		Case cInfo == "ARRAY_ESTOQUE_POS_LOCAL"
			nValue := ARRAY_ESTOQUE_POS_LOCAL
		Case cInfo == "ARRAY_ESTOQUE_POS_LOTE"
			nValue := ARRAY_ESTOQUE_POS_LOTE
		Case cInfo == "ARRAY_ESTOQUE_POS_SUBLOTE"
			nValue := ARRAY_ESTOQUE_POS_SUBLOTE
		Case cInfo == "ARRAY_ESTOQUE_POS_VALIDADE"
			nValue := ARRAY_ESTOQUE_POS_VALIDADE
		Case cInfo == "ARRAY_ESTOQUE_POS_QTD"
			nValue := ARRAY_ESTOQUE_POS_QTD
		Case cInfo == "ARRAY_ESTOQUE_POS_QTD_NPT"
			nValue := ARRAY_ESTOQUE_POS_QTD_NPT
		Case cInfo == "ARRAY_ESTOQUE_POS_QTD_TNP"
			nValue := ARRAY_ESTOQUE_POS_QTD_TNP
		Case cInfo == "ARRAY_ESTOQUE_POS_QTD_IND"
			nValue := ARRAY_ESTOQUE_POS_QTD_IND
		Case cInfo == "ARRAY_ESTOQUE_POS_QTD_BLQ"
			nValue := ARRAY_ESTOQUE_POS_QTD_BLQ
		Case cInfo == "ARRAY_ESTOQUE_POS_QTD_CQ"
			nValue := ARRAY_ESTOQUE_POS_QTD_CQ
		Case cInfo == "ARRAY_ESTOQUE_POS_CODE"
			nValue := ARRAY_ESTOQUE_POS_CODE
		Case cInfo == "ARRAY_ESTOQUE_SIZE"
			nValue := ARRAY_ESTOQUE_SIZE
		Otherwise
			nValue := ARRAY_ESTOQUE_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} PcpEstqInt
Função que executa a integração do pedido de compra com o MRP.

@type  Function
@author brunno.costa
@since 06/08/2019
@version P12.1.27
@param cOperation, Caracter, Operação que será executada ('DELETE'/'INSERT'/'SYNC'/'CLEAR')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param aSuccess  , Array   , Carrega os registros que foram integrados com sucesso
@param aError    , Array   , Carrega os registros que não foram integrados por erro
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param lOnlyDel  , Logic   , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param lBuffer   , Logic   , Define a sincronização em processo de buffer.
@return Nil
/*/
Function PcpEstqInt(cOperation, aDados, aSuccess, aError, cUUID, lOnlyDel, lBuffer)
	Local aReturn   := {}
	Local lAllError := .F.
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsonData := Nil
	Local cApi 		:= "MRPSTOCKBALANCE"

	Default aSuccess := {}
	Default aError   := {}
	Default cUUID    := ""
	Default lOnlyDel := .F.
	Default lBuffer  := .F.

	nTotal := Len(aDados)
	oJsonData := JsonObject():New()

	oJsonData["items"] := Array(nTotal)

	For nIndex := 1 To nTotal
		oJsonData["items"][nIndex] := JsonObject():New()
		oJsonData["items"][nIndex]["branchId"] := aDados[nIndex][ARRAY_ESTOQUE_POS_FILIAL ]

		If ! (lOnlyDel .And. cOperation == "SYNC")
			If cOperation == "CLEAR"
				oJsonData["items"][nIndex]["product"  ] := aDados[nIndex][ARRAY_ESTOQUE_POS_PROD]
				oJsonData["items"][nIndex]["warehouse"] := aDados[nIndex][ARRAY_ESTOQUE_POS_LOCAL]
			Else
				oJsonData["items"][nIndex]["code"    ] := aDados[nIndex][ARRAY_ESTOQUE_POS_FILIAL ] + ;
															aDados[nIndex][ARRAY_ESTOQUE_POS_PROD   ] + ;
															aDados[nIndex][ARRAY_ESTOQUE_POS_LOCAL  ] + ;
															aDados[nIndex][ARRAY_ESTOQUE_POS_LOTE   ] + ;
															aDados[nIndex][ARRAY_ESTOQUE_POS_SUBLOTE] 

				If !Empty(aDados[nIndex][ARRAY_ESTOQUE_POS_VALIDADE])												
					oJsonData["items"][nIndex]["code"    ] += convDate(aDados[nIndex][ARRAY_ESTOQUE_POS_VALIDADE])
				EndIf

				If cOperation $ "|INSERT|SYNC|"
					oJsonData["items"][nIndex]["product"         ] := aDados[nIndex][ARRAY_ESTOQUE_POS_PROD]
					oJsonData["items"][nIndex]["warehouse"       ] := aDados[nIndex][ARRAY_ESTOQUE_POS_LOCAL]
					oJsonData["items"][nIndex]["lot"             ] := aDados[nIndex][ARRAY_ESTOQUE_POS_LOTE]
					oJsonData["items"][nIndex]["sublot"          ] := aDados[nIndex][ARRAY_ESTOQUE_POS_SUBLOTE]

					If !Empty(aDados[nIndex][ARRAY_ESTOQUE_POS_VALIDADE])
						oJsonData["items"][nIndex]["expirationDate" ] := convDate(aDados[nIndex][ARRAY_ESTOQUE_POS_VALIDADE])
					EndIf

					oJsonData["items"][nIndex]["availableQuantity"  	] := aDados[nIndex][ARRAY_ESTOQUE_POS_QTD]
					oJsonData["items"][nIndex]["consignedOut"       	] := aDados[nIndex][ARRAY_ESTOQUE_POS_QTD_NPT]
					oJsonData["items"][nIndex]["consignedIn"        	] := aDados[nIndex][ARRAY_ESTOQUE_POS_QTD_TNP]
					oJsonData["items"][nIndex]["unavailableQuantity"	] := aDados[nIndex][ARRAY_ESTOQUE_POS_QTD_IND]
					oJsonData["items"][nIndex]["blockedBalance"			] := aDados[nIndex][ARRAY_ESTOQUE_POS_QTD_BLQ]

				EndIf
			EndIf
		EndIf
	Next nIndex

	If cOperation $ "|INSERT|SYNC|"
		If cOperation == "INSERT"
			aReturn := MrpSBPost(oJsonData)
		Else
			aReturn := MrpSBSync(oJsonData,lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '1', cUUID)
	Else
		If cOperation == "CLEAR"
			aReturn := MrpSBClr(oJsonData)
			PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '3', cUUID)
		Else
			aReturn := MrpSBDel(oJsonData)
			PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '2', cUUID)
		EndIf
	EndIf

	FreeObj(oJsonData)
	oJsonData := Nil

Return Nil

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type  Static Function
@author brunno.costa
@since 06/08/2019
@version P12.1.27
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(dData)
	Local cData := ""

	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
Return cData
