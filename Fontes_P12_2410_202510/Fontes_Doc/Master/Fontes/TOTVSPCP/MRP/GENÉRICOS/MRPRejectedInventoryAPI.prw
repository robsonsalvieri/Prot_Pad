#INCLUDE "TOTVS.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função CQAPICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função CQAPICnt
#DEFINE ARRAY_CQ_POS_FILIAL   1
#DEFINE ARRAY_CQ_POS_PROD     2
#DEFINE ARRAY_CQ_POS_QTDE     3
#DEFINE ARRAY_CQ_POS_LOCAL    4
#DEFINE ARRAY_CQ_POS_DATA     5
#DEFINE ARRAY_CQ_POS_QTD_DEV  6
#DEFINE ARRAY_CQ_POS_CODE     7
#DEFINE ARRAY_CQ_POS_LOTE     8
#DEFINE ARRAY_CQ_POS_SBLOTE   9
#DEFINE ARRAY_CQ_SIZE         9

/*/{Protheus.doc} CQAPICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array de CQ para integração.

@type  Function
@author brunno.costa
@since 13/07/2020
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function CQAPICnt(cInfo)
	Local nValue := ARRAY_CQ_SIZE

	Do Case
		Case cInfo == "ARRAY_CQ_POS_FILIAL"
			nValue := ARRAY_CQ_POS_FILIAL
		Case cInfo == "ARRAY_CQ_POS_PROD"
			nValue := ARRAY_CQ_POS_PROD
		Case cInfo == "ARRAY_CQ_POS_QTDE"
			nValue := ARRAY_CQ_POS_QTDE
		Case cInfo == "ARRAY_CQ_POS_LOCAL"
			nValue := ARRAY_CQ_POS_LOCAL
		Case cInfo == "ARRAY_CQ_POS_DATA"
			nValue := ARRAY_CQ_POS_DATA
		Case cInfo == "ARRAY_CQ_POS_QTD_DEV"
			nValue := ARRAY_CQ_POS_QTD_DEV
		Case cInfo == "ARRAY_CQ_POS_CODE"
			nValue := ARRAY_CQ_POS_CODE
		Case cInfo == "ARRAY_CQ_SIZE"
			nValue := ARRAY_CQ_SIZE
		Case cInfo == "ARRAY_CQ_POS_LOTE"
			nValue := ARRAY_CQ_POS_LOTE
		Case cInfo == "ARRAY_CQ_POS_SBLOTE"
			nValue := ARRAY_CQ_POS_SBLOTE
		Otherwise
			nValue := ARRAY_CQ_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} PcpCQInt
Função que executa a integração do CQ com o MRP.

@type  Function
@author brunno.costa
@since 13/07/2020
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
Function PcpCQInt(cOperation, aDados, aSuccess, aError, cUUID, lOnlyDel,lBuffer)
	Local aReturn   := {}
	Local cApi      := "MRPREJECTEDINVENTORY"
	Local cCode     := ""
	Local lAllError := .F.
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsonData := Nil
	Local lConsidLt := Iif(FindFunction("mrpLoteCQ"), mrpLoteCQ(), .F.)

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
		oJsonData["items"][nIndex]["branchId"] := aDados[nIndex][ARRAY_CQ_POS_FILIAL ]

		If !(lOnlyDel .And. cOperation == "SYNC")
			cCode := aDados[nIndex][ARRAY_CQ_POS_FILIAL ] + ;
			         aDados[nIndex][ARRAY_CQ_POS_PROD   ] + ;
			         aDados[nIndex][ARRAY_CQ_POS_LOCAL  ] + ;
			         aDados[nIndex][ARRAY_CQ_POS_DATA   ]
			         
			If lConsidLt
				cCode += aDados[nIndex][ARRAY_CQ_POS_LOTE  ] + ;
				         aDados[nIndex][ARRAY_CQ_POS_SBLOTE]
			EndIf

			oJsonData["items"][nIndex]["code"    ] := cCode
			If cOperation == "CLEAR"
				oJsonData["items"][nIndex]["product"    ] := aDados[nIndex][ARRAY_CQ_POS_PROD]
				oJsonData["items"][nIndex]["warehouse"  ] := aDados[nIndex][ARRAY_CQ_POS_LOCAL]
				oJsonData["items"][nIndex]["invoiceDate"] := convDate(StoD(aDados[nIndex][ARRAY_CQ_POS_DATA]))
				oJsonData["items"][nIndex]["lot"        ] := aDados[nIndex][ARRAY_CQ_POS_LOTE]
				oJsonData["items"][nIndex]["subLot"     ] := aDados[nIndex][ARRAY_CQ_POS_SBLOTE]
			Else
				If cOperation $ "|INSERT|SYNC|"
					oJsonData["items"][nIndex]["product"         ] := aDados[nIndex][ARRAY_CQ_POS_PROD]
					oJsonData["items"][nIndex]["quantity"        ] := aDados[nIndex][ARRAY_CQ_POS_QTDE]
					oJsonData["items"][nIndex]["warehouse"       ] := aDados[nIndex][ARRAY_CQ_POS_LOCAL]
					oJsonData["items"][nIndex]["invoiceDate"     ] := convDate(StoD(aDados[nIndex][ARRAY_CQ_POS_DATA]))
					oJsonData["items"][nIndex]["returnedQuantity"] := aDados[nIndex][ARRAY_CQ_POS_QTD_DEV]
					oJsonData["items"][nIndex]["lot"             ] := aDados[nIndex][ARRAY_CQ_POS_LOTE]
					oJsonData["items"][nIndex]["subLot"          ] := aDados[nIndex][ARRAY_CQ_POS_SBLOTE]
				EndIf
			EndIf
		EndIf
	Next nIndex

	If cOperation $ "|INSERT|SYNC|"
		If cOperation == "INSERT"
			aReturn := MrpRIPost(oJsonData)
		Else
			aReturn := MrpRISync(oJsonData,lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '1', cUUID)
	Else
		If cOperation == "CLEAR"
			aReturn := MrpRIClr(oJsonData)
			PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '3', cUUID)
		Else
			aReturn := MrpRIDel(oJsonData)
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
@since 13/07/2020
@version P12.1.27
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(dData)
	Local cData := ""

	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)

Return cData
