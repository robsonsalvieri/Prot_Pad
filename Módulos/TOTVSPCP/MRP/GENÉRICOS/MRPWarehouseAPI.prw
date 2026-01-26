#INCLUDE "TOTVS.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função WHAPICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função WHAPICnt
#DEFINE ARRAY_WH_POS_FILIAL   1
#DEFINE ARRAY_WH_POS_COD      2
#DEFINE ARRAY_WH_POS_TIPO     3
#DEFINE ARRAY_WH_POS_MRP      4
#DEFINE ARRAY_WH_POS_CODE     5
#DEFINE ARRAY_WH_SIZE         5

/*/{Protheus.doc} WHAPICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array de armazéns para integração.

@type  Function
@author douglas.heydt
@since 06/08/2020
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function WHAPICnt(cInfo)
	Local nValue := ARRAY_WH_SIZE
	Do Case
		Case cInfo == "ARRAY_WH_POS_FILIAL"
			nValue := ARRAY_WH_POS_FILIAL
		Case cInfo == "ARRAY_WH_POS_COD"
			nValue := ARRAY_WH_POS_COD
		Case cInfo == "ARRAY_WH_POS_TIPO"
			nValue := ARRAY_WH_POS_TIPO
		Case cInfo == "ARRAY_WH_POS_MRP"
			nValue := ARRAY_WH_POS_MRP
		Case cInfo == "ARRAY_WH_POS_CODE"
			nValue := ARRAY_WH_POS_CODE
		Case cInfo == "ARRAY_WH_SIZE"
			nValue := ARRAY_WH_SIZE
		Otherwise
			nValue := ARRAY_WH_SIZE
	EndCase
Return nValue
  
/*/{Protheus.doc} PcpWHInt
Função que executa a integração do CQ com o MRP.

@type  Function
@author douglas.heydt
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
Function PcpWHInt(cOperation, aDados, aSuccess, aError, cUUID, lOnlyDel, lBuffer)
	Local aReturn   := {}
	Local cApi 		:= "MRPWAREHOUSE"
	Local lAllError := .F.
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

	oJsonData["items"] := Array(nTotal)

	For nIndex := 1 To nTotal
		oJsonData["items"][nIndex] := JsonObject():New()
		oJsonData["items"][nIndex]["branchId"] := aDados[nIndex][ARRAY_WH_POS_FILIAL ]

		If !(lOnlyDel .And. cOperation == "SYNC")
			oJsonData["items"][nIndex]["code"    ] := aDados[nIndex][ARRAY_WH_POS_FILIAL ] + ;
													  aDados[nIndex][ARRAY_WH_POS_COD   ]
			If cOperation $ "|INSERT|SYNC|"
					oJsonData["items"][nIndex]["warehouse" ] := aDados[nIndex][ARRAY_WH_POS_COD]
                    oJsonData["items"][nIndex]["type"      ] := aDados[nIndex][ARRAY_WH_POS_TIPO]
					oJsonData["items"][nIndex]["usemrp"    ] := aDados[nIndex][ARRAY_WH_POS_MRP]
			EndIf
		EndIf
	Next nIndex

	If cOperation $ "|INSERT|SYNC|"
		If cOperation == "INSERT"
			aReturn := MrpWPost(oJsonData)
		Else
			aReturn := MrpWSync(oJsonData, lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '1', cUUID)
	Else
        aReturn := MrpWDel(oJsonData)
        PrcPendMRP(aReturn, cApi, oJsonData, .F., @aSuccess, @aError, @lAllError, '2', cUUID)
	EndIf

	FreeObj(oJsonData)
	oJsonData := Nil

Return Nil

/*/{Protheus.doc} intMrpWh

@type  Static Function
@author douglas.heydt
@since 13/07/2020
@version P12.1.27
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Function IntMrpWh(nOpcX, oModel)
	Local aDados   := {}
	Local aItem    := {}
	Local aSuccess := {}
	Local aError   := {}

	aAdd(aItem, xFilial("NNR"))
	aAdd(aItem, oModel:GetModel("NNRMASTER"):GetValue('NNR_CODIGO'))
	aAdd(aItem, oModel:GetModel("NNRMASTER"):GetValue('NNR_TIPO'))
	aAdd(aItem, oModel:GetModel("NNRMASTER"):GetValue('NNR_MRP'))
	aAdd(aDados, aItem)
	If nOpcX == 5
		PcpWHInt("DELETE", aDados, aSuccess, aError, , .F.)
	Else
		PcpWHInt("INSERT", aDados, aSuccess, aError, , .F.)
	EndIf
Return