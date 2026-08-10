#INCLUDE "TOTVS.CH"

//Define constantes para utilizar nos arrays.
//Ao criar novas constantes, adicionar na função A381APICnt
#DEFINE ARRAY_POS_FILIAL    1
#DEFINE ARRAY_POS_PROD      2
#DEFINE ARRAY_POS_OP        3
#DEFINE ARRAY_POS_OP_ORIG   4
#DEFINE ARRAY_POS_DATA      5
#DEFINE ARRAY_POS_SEQ       6
#DEFINE ARRAY_POS_QTD       7
#DEFINE ARRAY_POS_QSUSP     8
#DEFINE ARRAY_POS_LOCAL     9
#DEFINE ARRAY_POS_XOPER     10
#DEFINE ARRAY_POS_RECNO     11
#DEFINE ARRAY_SIZE          11

/*/{Protheus.doc} A381APICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array dos empenhos para integração.

@type  Function
@author brunno.costa
@since 22/07/2019
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A381APICnt(cInfo)
	Local nValue := ARRAY_SIZE
	Do Case
		Case cInfo == "ARRAY_POS_FILIAL"
			nValue := ARRAY_POS_FILIAL
		Case cInfo == "ARRAY_POS_PROD"
			nValue := ARRAY_POS_PROD
		Case cInfo == "ARRAY_POS_OP"
			nValue := ARRAY_POS_OP
		Case cInfo == "ARRAY_POS_OP_ORIG"
			nValue := ARRAY_POS_OP_ORIG
		Case cInfo == "ARRAY_POS_DATA"
			nValue := ARRAY_POS_DATA
		Case cInfo == "ARRAY_POS_SEQ"
			nValue := ARRAY_POS_SEQ
		Case cInfo == "ARRAY_POS_QTD"
			nValue := ARRAY_POS_QTD
		Case cInfo == "ARRAY_POS_QSUSP"
			nValue := ARRAY_POS_QSUSP
		Case cInfo == "ARRAY_POS_LOCAL"
			nValue := ARRAY_POS_LOCAL
		Case cInfo == "ARRAY_POS_XOPER"
			nValue := ARRAY_POS_XOPER
		Case cInfo == "ARRAY_POS_RECNO"
			nValue := ARRAY_POS_RECNO
		Otherwise
			nValue := ARRAY_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} PCPA381INT
Função que executa a integração dos empenhos com o MRP.

@type  Function
@author brunno.costa
@since 22/07/2019
@version P12.1.27
@param cOperation, Caracter, Operação que será executada ('DELETE' ou 'INSERT')
@param aDados    , Array   , Array com os dados para integracao com a API do MRP
@param cUUID     , Caracter, Identificador do processo do SCHEDULE. Utilizado para atualização de pendências.
@param lOnlyDel  , Logic   , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param lBuffer   , Logic  , Define a sincronização em processo de buffer.
@return Nil
/*/
Function PCPA381INT(cOperDEF, aDados, aSuccess, aError, cUUID, lOnlyDel, lBuffer)
	Local aReturn    := {}
	Local cOperation := ""
	Local lAllError  := .F.
	Local lDelete    := .F.
	Local nIndex     := 0
	Local nIndAux    := 0
	Local nTotal     := 0
	Local oJsDelete  := Nil
	Local oJsInsert  := Nil
	Local oJsonData  := Nil
	Local cApi 		 := "MRPALLOCATIONS"

	Default aSuccess := {}
	Default aError   := {}
	Default cUUID    := ""
	Default lOnlyDel := .F.
	Default lBuffer	 := .F.

	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		//Identifica o metodo de envio do registro para API
		cOperation := Iif(Empty(aDados[nIndex][ARRAY_POS_XOPER]), cOperDEF, aDados[nIndex][ARRAY_POS_XOPER])
		lDelete    := .F.

		//Prepara os objetos JSON de DELETE e INSERT
		If cOperation == "DELETE" .OR. ( !lOnlyDel .And. (aDados[nIndex][ARRAY_POS_QTD] + aDados[nIndex][ARRAY_POS_QSUSP]) == 0)
			If oJsDelete == Nil
				oJsDelete := JsonObject():New()
				oJsDelete["items"] := {}
			EndIf
			oJsonData := oJsDelete
			lDelete := .T.
		Else
			If oJsInsert == Nil
				oJsInsert := JsonObject():New()
				oJsInsert["items"] := {}
			EndIf
			oJsonData := oJsInsert
		EndIf

		//Adiciona novo registro no array
		aAdd(oJsonData["items"], JsonObject():New())
		nIndAux := Len(oJsonData["items"])
		
		oJsonData["items"][nIndAux]["branchId"] := aDados[nIndex][ARRAY_POS_FILIAL]
		
		If ! (lOnlyDel .And. cOperation == "SYNC")
			oJsonData["items"][nIndAux]["code"] := aDados[nIndex][ARRAY_POS_RECNO]

			If cOperation $ "|INSERT|SYNC|" .And. !lDelete
				oJsInsert["items"][nIndAux]["product"            ] := aDados[nIndex][ARRAY_POS_PROD     ]
				oJsInsert["items"][nIndAux]["productionOrder"    ] := aDados[nIndex][ARRAY_POS_OP       ]
				oJsInsert["items"][nIndAux]["productionOrderOrig"] := aDados[nIndex][ARRAY_POS_OP_ORIG  ]
				oJsInsert["items"][nIndAux]["allocationDate"     ] := convDate(aDados[nIndex][ARRAY_POS_DATA])
				oJsInsert["items"][nIndAux]["sequence"           ] := aDados[nIndex][ARRAY_POS_SEQ]
				oJsInsert["items"][nIndAux]["quantity"           ] := aDados[nIndex][ARRAY_POS_QTD]
				oJsInsert["items"][nIndAux]["suspendedQuantity"  ] := aDados[nIndex][ARRAY_POS_QSUSP]
				oJsInsert["items"][nIndAux]["warehouse"          ] := aDados[nIndex][ARRAY_POS_LOCAL]
			EndIf
		EndIf
	Next nIndex

	If nTotal == 0
		If oJsInsert == Nil
			oJsInsert := JsonObject():New()
			oJsInsert["items"] := {}
			cOperation := "SYNC"
		EndIf
	EndIf

	//Envia operações de DELETE
	If oJsDelete != Nil
		aReturn := MrpEmpDel(oJsDelete)
		PrcPendMRP(aReturn, cApi, oJsDelete, .F., @aSuccess, @aError, @lAllError, '3', cUUID)
		FreeObj(oJsDelete)
		oJsDelete := Nil
	EndIf

	//Envia operações de INSERT
	If oJsInsert != Nil
		If cOperation == "INSERT"
			aReturn := MrpEmpPost(oJsInsert)
		ElseIf cOperation == "SYNC"
			aReturn := MrpEmpSync(oJsInsert,lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsInsert, .F., @aSuccess, @aError, @lAllError, '3', cUUID)
		FreeObj(oJsInsert)
		oJsInsert := Nil
	EndIf

	aSize(aReturn, 0)

Return Nil

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD

@type  Static Function
@author brunno.costa
@since 22/07/2019
@version P12.1.27
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(dData)
	Local cData := ""

	cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
Return cData


