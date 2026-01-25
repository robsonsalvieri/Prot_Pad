#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA200.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função A200APICnt
//para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função A200APICnt
//Campos do CABEÇALHO
#DEFINE ARRAY_ESTRU_CAB_POS_FILIAL      1
#DEFINE ARRAY_ESTRU_CAB_POS_PAI         2
#DEFINE ARRAY_ESTRU_CAB_POS_QBASE       3
#DEFINE ARRAY_ESTRU_CAB_POS_COMPON      4
#DEFINE ARRAY_ESTRU_CAB_SIZE            4
//Campos do COMPONENTE
#DEFINE ARRAY_ESTRU_CMP_POS_COMP        1
#DEFINE ARRAY_ESTRU_CMP_POS_SEQ         2
#DEFINE ARRAY_ESTRU_CMP_POS_REVINI      3
#DEFINE ARRAY_ESTRU_CMP_POS_REVFIM      4
#DEFINE ARRAY_ESTRU_CMP_POS_QTDNEC      5
#DEFINE ARRAY_ESTRU_CMP_POS_VLDINI      6
#DEFINE ARRAY_ESTRU_CMP_POS_VLDFIM      7
#DEFINE ARRAY_ESTRU_CMP_POS_PERDA       8
#DEFINE ARRAY_ESTRU_CMP_POS_QTDFIXA     9
#DEFINE ARRAY_ESTRU_CMP_POS_GRPOPC      10
#DEFINE ARRAY_ESTRU_CMP_POS_ITEMOPC     11
#DEFINE ARRAY_ESTRU_CMP_POS_POTENC      12
#DEFINE ARRAY_ESTRU_CMP_POS_FANTASM     13
#DEFINE ARRAY_ESTRU_CMP_POS_ALTERNATIVO 14
#DEFINE ARRAY_ESTRU_CMP_POS_RECNO       15
#DEFINE ARRAY_ESTRU_CMP_POS_LOCAL       16
#DEFINE ARRAY_ESTRU_CMP_SIZE            16
//Campos do ALTERNATIVO
#DEFINE ARRAY_ESTRU_ALT_POS_ALTERN      1
#DEFINE ARRAY_ESTRU_ALT_POS_TIPOCONV    2
#DEFINE ARRAY_ESTRU_ALT_POS_FATORCONV   3
#DEFINE ARRAY_ESTRU_ALT_POS_VIGENCIA    4
#DEFINE ARRAY_ESTRU_ALT_POS_ESTOQUE     5
#DEFINE ARRAY_ESTRU_ALT_POS_SEQUENCIA   6
#DEFINE ARRAY_ESTRU_ALT_SIZE            6

Static _lMrpInSMQ := FWAliasInDic("SMQ", .F.) .And. Findfunction("mrpInSMQ")

/*/{Protheus.doc} A200APICnt
Recupera o valor das constantes utilizadas para
auxiliar na montagem do array das estruturas para integração.

@type  Function
@author lucas.franca
@since 11/07/2019
@version P12.1.27
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A200APICnt(cInfo)
	Local nValue := ARRAY_ESTRU_CAB_SIZE
	Do Case
		Case cInfo == "ARRAY_ESTRU_CAB_POS_FILIAL"
			nValue := ARRAY_ESTRU_CAB_POS_FILIAL
		Case cInfo == "ARRAY_ESTRU_CAB_POS_PAI"
			nValue := ARRAY_ESTRU_CAB_POS_PAI
		Case cInfo == "ARRAY_ESTRU_CAB_POS_QBASE"
			nValue := ARRAY_ESTRU_CAB_POS_QBASE
		Case cInfo == "ARRAY_ESTRU_CAB_POS_COMPON"
			nValue := ARRAY_ESTRU_CAB_POS_COMPON
		Case cInfo == "ARRAY_ESTRU_CAB_SIZE"
			nValue := ARRAY_ESTRU_CAB_SIZE
		Case cInfo == "ARRAY_ESTRU_CMP_POS_COMP"
			nValue := ARRAY_ESTRU_CMP_POS_COMP
		Case cInfo == "ARRAY_ESTRU_CMP_POS_SEQ"
			nValue := ARRAY_ESTRU_CMP_POS_SEQ
		Case cInfo == "ARRAY_ESTRU_CMP_POS_REVINI"
			nValue := ARRAY_ESTRU_CMP_POS_REVINI
		Case cInfo == "ARRAY_ESTRU_CMP_POS_REVFIM"
			nValue := ARRAY_ESTRU_CMP_POS_REVFIM
		Case cInfo == "ARRAY_ESTRU_CMP_POS_QTDNEC"
			nValue := ARRAY_ESTRU_CMP_POS_QTDNEC
		Case cInfo == "ARRAY_ESTRU_CMP_POS_VLDINI"
			nValue := ARRAY_ESTRU_CMP_POS_VLDINI
		Case cInfo == "ARRAY_ESTRU_CMP_POS_VLDFIM"
			nValue := ARRAY_ESTRU_CMP_POS_VLDFIM
		Case cInfo == "ARRAY_ESTRU_CMP_POS_PERDA"
			nValue := ARRAY_ESTRU_CMP_POS_PERDA
		Case cInfo == "ARRAY_ESTRU_CMP_POS_QTDFIXA"
			nValue := ARRAY_ESTRU_CMP_POS_QTDFIXA
		Case cInfo == "ARRAY_ESTRU_CMP_POS_GRPOPC"
			nValue := ARRAY_ESTRU_CMP_POS_GRPOPC
		Case cInfo == "ARRAY_ESTRU_CMP_POS_ITEMOPC"
			nValue := ARRAY_ESTRU_CMP_POS_ITEMOPC
		Case cInfo == "ARRAY_ESTRU_CMP_POS_POTENC"
			nValue := ARRAY_ESTRU_CMP_POS_POTENC
		Case cInfo == "ARRAY_ESTRU_CMP_POS_FANTASM"
			nValue := ARRAY_ESTRU_CMP_POS_FANTASM
		Case cInfo == "ARRAY_ESTRU_CMP_POS_ALTERNATIVO"
			nValue := ARRAY_ESTRU_CMP_POS_ALTERNATIVO
		Case cInfo == "ARRAY_ESTRU_CMP_POS_RECNO"
			nValue := ARRAY_ESTRU_CMP_POS_RECNO
		Case cInfo == "ARRAY_ESTRU_CMP_POS_LOCAL"
			nValue := ARRAY_ESTRU_CMP_POS_LOCAL
		Case cInfo == "ARRAY_ESTRU_CMP_SIZE"
			nValue := ARRAY_ESTRU_CMP_SIZE
		Case cInfo == "ARRAY_ESTRU_ALT_POS_ALTERN"
			nValue := ARRAY_ESTRU_ALT_POS_ALTERN
		Case cInfo == "ARRAY_ESTRU_ALT_POS_TIPOCONV"
			nValue := ARRAY_ESTRU_ALT_POS_TIPOCONV
		Case cInfo == "ARRAY_ESTRU_ALT_POS_FATORCONV"
			nValue := ARRAY_ESTRU_ALT_POS_FATORCONV
		Case cInfo == "ARRAY_ESTRU_ALT_POS_VIGENCIA"
			nValue := ARRAY_ESTRU_ALT_POS_VIGENCIA
		Case cInfo == "ARRAY_ESTRU_ALT_POS_ESTOQUE"
			nValue := ARRAY_ESTRU_ALT_POS_ESTOQUE
		Case cInfo == "ARRAY_ESTRU_ALT_POS_SEQUENCIA"
			nValue := ARRAY_ESTRU_ALT_POS_SEQUENCIA
		Case cInfo == "ARRAY_ESTRU_ALT_SIZE"
			nValue := ARRAY_ESTRU_ALT_SIZE
		Otherwise
			nValue := ARRAY_ESTRU_CAB_SIZE
	EndCase
Return nValue

/*/{Protheus.doc} PCPA200MRP
Identifica os dados que sofreram alteração e executa a integração
com o novo MRP.

@type  Function
@author lucas.franca
@since 11/07/2019
@version P12.1.27
@param 01 oEvent    , Object   , Objeto do evento default do programa PCPA200
@param 02 oModel    , Object   , Objeto do modelo de dados da tela.
@param 03 oIntegra  , Object   , Objeto com códigos de produtos pais para executar a integração de inclusão/atualização. (opcional)
@param 04 cOperation, Character, Operação executada ("INSERT"/"SYNC"/"DELETE")
@param 05 aSuccess  , Array    , Carrega os registros que foram integrados com sucesso
@param 06 aError    , Array    , Carrega os registros que não foram integrados por erro
@param 07 lOnlyDel  , Logic    , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param 08 lReproc   , Logic    , Indica que está sendo executada uma operação de reprocessamento.
@param 09 cUUID     , Character, Código identificador do processo de reprocessamento na tabela T4R.
@return Nil
/*/
Function PCPA200MRP(oEvent, oModel, oIntegra, cOperation, aSuccess, aError, lOnlyDel, lReproc, cUUID)
	Local aChaves    := {}
	Local aCompDel   := {}
	Local aDadosCab  := {}
	Local aDadosCmp  := {}
	Local aDadosInc  := {}
	Local aEstrDel   := {}
	Local cChave     := ""
	Local cFil       := ""
	Local cPai       := ""
	Local lDeleta    := .F.
	Local lIntegra   := .T.
	Local nIndex     := 0
	Local nTamFilial := 0
	Local nTamProd   := 0
	Local nTotal     := 0
	Local oFields    := Nil
	Local oLinDel    := Nil
	Local oLines     := Nil
	Local oPaiInt    := JsonObject():New()

	Default aError     := {}
	Default aSuccess   := {}
	Default cOperation := "INSERT"
	Default cUUID      := ""	
	Default lOnlyDel   := .F.
	Default lReproc    := .F.

	If oEvent == Nil .And. oIntegra == Nil 
		Return
	EndIf

	If oEvent != Nil
		oLinDel := oEvent:oDadosCommit["oLinDel"]
		oLines  := oEvent:oDadosCommit["oLines"]
		oFields := oEvent:oDadosCommit["oFields"]
	EndIf

	If oModel != Nil
		If oModel:GetOperation() == MODEL_OPERATION_DELETE
			lDeleta := .T.
		EndIf
	EndIf

	lIntegra := !lReproc
	//Busca os dados de Atualização/Inclusão/Exclusão
	If lDeleta .Or. (lReproc .And. cOperation == "DELETE")
		//Monta array com os dados.
		aDadosCab := Array(ARRAY_ESTRU_CAB_SIZE)

		If lIntegra
			//Dados do cabeçalho
			aDadosCab[ARRAY_ESTRU_CAB_POS_FILIAL] := oModel:GetModel("SG1_DETAIL"):GetValue("G1_FILIAL")
			aDadosCab[ARRAY_ESTRU_CAB_POS_PAI   ] := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
		Else
			nTamFilial := FwSizeFilial()
			nTamProd   := GetSx3Cache("G1_COD", "X3_TAMANHO")
			aChaves    := oIntegra:GetNames()
			nTotal     := Len(aChaves)

			For nIndex := 1 to nTotal
				cChave  := aChaves[nIndex]

				aDadosCab[ARRAY_ESTRU_CAB_POS_FILIAL] := Left(cChave, nTamFilial)
				aDadosCab[ARRAY_ESTRU_CAB_POS_PAI   ] := cPai := SubStr(cChave, nTamFilial + 1, nTamProd)
			Next
		EndIf

		aAdd(aEstrDel, aDadosCab)
	Else
		If oIntegra == Nil
			oIntegra := JsonObject():New()
			aChaves  := oLines:GetNames()
			nTotal   := Len(aChaves)
			For nIndex := 1 To nTotal
				cChave := aChaves[nIndex]

				//Proteção para não gravar um registro que tenha ficado inválido
				If oLines[cChave] == Nil;
				   .Or. Empty(oLines[cChave][oFields["G1_COD"]]);
				   .Or. Empty(oLines[cChave][oFields["G1_COMP"]])
					Loop
				EndIf

				cFil := oLines[cChave][oFields["G1_FILIAL"]]
				cPai := oLines[cChave][oFields["G1_COD"]]
				If Empty(cFil)
					cFil := xFilial("SG1")
				EndIf

				If oIntegra[cFil+cPai] == Nil
					oIntegra[cFil+cPai] := 0
				EndIf
				oIntegra[cFil+cPai]++
			Next nIndex
		EndIf

		aDadosInc := cargaSG1(oIntegra, oModel, lOnlyDel, @aEstrDel)

		//Busca os dados de Exclusão.
		//A exclusão é feita somente quando revisão manual.
		If oEvent != Nil .And. !oEvent:mvlRevisaoAutomatica
			oPaiInt := JsonObject():New()
			aChaves := oLinDel:GetNames()
			nTotal  := Len(aChaves)
			For nIndex := 1 To nTotal
				cChave := aChaves[nIndex]
				If oLinDel[cChave] == Nil .Or. !oLinDel[cChave] .Or. oLines[cChave] == Nil .Or. oLines[cChave][oFields["NREG"]] <= 0
					Loop
				EndIf
				If oPaiInt[oLines[cChave][oFields["G1_COD"]]] == Nil
					//Monta array com os dados.
					aDadosCab := Array(ARRAY_ESTRU_CAB_SIZE)
					//Dados do cabeçalho
					aDadosCab[ARRAY_ESTRU_CAB_POS_FILIAL] := oLines[cChave][oFields["G1_FILIAL"]]
					aDadosCab[ARRAY_ESTRU_CAB_POS_PAI   ] := oLines[cChave][oFields["G1_COD"]]
					aDadosCab[ARRAY_ESTRU_CAB_POS_COMPON] := {}
					oPaiInt[oLines[cChave][oFields["G1_COD"]]] := aClone(aDadosCab)
				EndIf

				aDadosCmp := Array(ARRAY_ESTRU_CMP_SIZE)
				aDadosCmp[ARRAY_ESTRU_CMP_POS_RECNO] := oLines[cChave][oFields["NREG"]]

				aAdd(oPaiInt[oLines[cChave][oFields["G1_COD"]]][ARRAY_ESTRU_CAB_POS_COMPON], aClone(aDadosCmp))

			Next nIndex

			aChaves := oPaiInt:GetNames()
			nTotal  := Len(aChaves)
			For nIndex := 1 To nTotal
				aAdd(aCompDel, aClone(oPaiInt[aChaves[nIndex]]))
			Next nIndex
		EndIf
	EndIf

	If Len(aCompDel) > 0
		PCPA200INT("DELETE", aCompDel, 2, @aSuccess, @aError, lOnlyDel, /*lBuffer*/, lIntegra, lReproc, cUUID)
	EndIf

	If Len(aEstrDel) > 0
		PCPA200INT("DELETE", aEstrDel, 1, @aSuccess, @aError, lOnlyDel, /*lBuffer*/, lIntegra, lReproc, cUUID)
	EndIf

	If Len(aDadosInc) > 0 .OR. cOperation == "SYNC"
		PCPA200INT(cOperation, aDadosInc, Nil, @aSuccess, @aError, lOnlyDel, /*lBuffer*/, lIntegra, lReproc, cUUID)
	EndIf

	aSize(aChaves  , 0)
	aSize(aDadosCab, 0)
	aSize(aDadosCmp, 0)
	aSize(aDadosInc, 0)
	aSize(aCompDel , 0)
	aSize(aEstrDel , 0)

	If oPaiInt != Nil
		FreeObj(oPaiInt)
	EndIf
	If oIntegra != Nil
		FreeObj(oIntegra)
	EndIf
Return Nil

/*/{Protheus.doc} getQtdBase
Retorna a quantidade base de um produto.

@type  Static Function
@author lucas.franca
@since 11/07/2019
@version P12.1.27
@param oModel   , Object   , Modelo de dados da tela do PCPA200
@param cProduct , Character, Código do produto.
@return nQtdBase, Numeric  , Quantidade base do produto
/*/
Static Function getQtdBase(oModel, cProduct)
	Local nQtdBase := 1

	If oModel != Nil .And. cProduct == oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
		nQtdBase := oModel:GetModel("SG1_MASTER"):GetValue("NQTBASE")
	Else
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+cProduct))
			nQtdBase := RetFldProd(cProduct,"B1_QB")
		EndIf
	EndIf
Return nQtdBase

/*/{Protheus.doc} A200APIAlt
Faz a carga dos produtos alternativos de um componente da estrutura.

@type  Static Function
@author lucas.franca
@since 12/07/2019
@version P12.1.27
@param cPai , Character, Código do produto PAI
@param cComp, Character, Código do produto componente
@return aAltern, Array, Array com os dados dos produtos alternativos.
/*/
Function A200APIAlt(cPai, cComp)
	Local aAltern := {}
	Local cChave  := ""
	Local nPos    := 0

	SGI->(dbSetOrder(1))
	cChave := xFilial("SGI") + cComp
	If SGI->(dbSeek(cChave))
		While SGI->(!Eof()) .And. SGI->GI_FILIAL+SGI->GI_PRODORI == cChave
			If SGI->GI_MRP == "S"
				aAdd(aAltern, Array(ARRAY_ESTRU_ALT_SIZE))
				nPos++

				aAltern[nPos][ARRAY_ESTRU_ALT_POS_ALTERN   ] := SGI->GI_PRODALT
				aAltern[nPos][ARRAY_ESTRU_ALT_POS_SEQUENCIA] := SGI->GI_ORDEM
				aAltern[nPos][ARRAY_ESTRU_ALT_POS_TIPOCONV ] := SGI->GI_TIPOCON
				aAltern[nPos][ARRAY_ESTRU_ALT_POS_FATORCONV] := SGI->GI_FATOR
				aAltern[nPos][ARRAY_ESTRU_ALT_POS_VIGENCIA ] := SGI->GI_DATA
				aAltern[nPos][ARRAY_ESTRU_ALT_POS_ESTOQUE  ] := SGI->GI_ESTOQUE
			EndIf
			SGI->(dbSkip())
		End
	EndIf
Return aAltern

/*/{Protheus.doc} PCPA200INT
Função que executa a integração das estruturas com o MRP.

@type  Function
@author lucas.franca
@since 16/07/2019
@version P12.1.27
@param 01 cOperation, Character, Operação que será executada ('DELETE'/'INSERT'/'SYNC')
@param 02 aDados    , Array    , Array com os dados que devem ser integrados com o MRP.
@param 03 nOpcao    , Numeric  , Opção para exclusão de estruturas. (1=Estrutura inteira; 2=Componente da estrutura; 3=Alternativo do componente)
@param 04 aSuccess  , Array    , Carrega os registros que foram integrados com sucesso
@param 05 aError    , Array    , Carrega os registros que não foram integrados por erro
@param 06 lOnlyDel  , Logic    , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param 07 lBuffer   , Logic	   , Define a sincronização em processo de buffer.
@param 08 lIntegra  , Logic    , Indica que está sendo executada uma operação de integração.
@param 09 lReproc   , Logic    , Indica que está sendo executada uma operação de reprocessamento.
@param 10 cUUID     , Character, Código identificador do processo de reprocessamento na tabela T4R.
@return Nil
/*/
Function PCPA200INT(cOperation, aDados, nOpcao, aSuccess, aError, lOnlyDel, lBuffer, lIntegra, lReproc, cUUID)
	Local aReturn   := {}
	Local aAltern   := {}
	Local aCompon   := {}
	Local cApi      := "MRPBILLOFMATERIAL"
	Local lAllError := .F.
	Local lUnlock   := .T.
	Local nIndAux   := 0
	Local nIndex    := 0
	Local nIndCmp   := 0
	Local nIndAlt   := 0	
	Local nTotal    := 0
	Local nTotCmp   := 0
	Local nTotAlt   := 0
	Local oJsonData := Nil
	Local oJsonCmp  := Nil
	Local oJsonAlt  := Nil

	Default nOpcao   := 2
	Default aSuccess := {}
	Default aError   := {}
	Default lOnlyDel := .F.
	Default lBuffer  := .F.
	Default lIntegra := .F.
	Default lReproc  := .F.
	Default cUUID    := ""

	lUnlock := lIntegra .Or. lReproc

	nTotal := Len(aDados)
	oJsonData := JsonObject():New()
	oJsonData["items"] := Array(0)

	For nIndex := 1 To nTotal

		//Valida integração 		
		If _lMrpInSMQ .and. cOperation != "SYNC" .and. !mrpInSMQ(aDados[nIndex][ARRAY_ESTRU_CAB_POS_FILIAL])  
			Loop
		EndIf
		
		aAdd(oJsonData["items"], JsonObject():New())
		nIndAux := Len(oJsonData["items"])
	
		//Monta o cabeçalho
		oJsonData["items"][nIndAux] := JsonObject():New()
		oJsonData["items"][nIndAux]["branchId"] := aDados[nIndex][ARRAY_ESTRU_CAB_POS_FILIAL]

		If !(cOperation == "SYNC" .And. lOnlyDel)
			oJsonData["items"][nIndAux]["product" ] := aDados[nIndex][ARRAY_ESTRU_CAB_POS_PAI   ]
			If cOperation $ "|INSERT|SYNC|"
				oJsonData["items"][nIndAux]["itemAmount"] := aDados[nIndex][ARRAY_ESTRU_CAB_POS_QBASE]
			EndIf

			//Adiciona os componentes
			If aDados[nIndex][ARRAY_ESTRU_CAB_POS_COMPON] != Nil .And. Len(aDados[nIndex][ARRAY_ESTRU_CAB_POS_COMPON]) > 0
				nTotCmp := Len(aDados[nIndex][ARRAY_ESTRU_CAB_POS_COMPON])

				oJsonData["items"][nIndAux]["listOfMRPComponents"] := Array(nTotCmp)
				For nIndCmp := 1 To nTotCmp
					aCompon := aDados[nIndex][ARRAY_ESTRU_CAB_POS_COMPON][nIndCmp]

					oJsonData["items"][nIndAux]["listOfMRPComponents"][nIndCmp] := JsonObject():New()
					oJsonCmp := oJsonData["items"][nIndAux]["listOfMRPComponents"][nIndCmp]

					oJsonCmp["component"            ] := aCompon[ARRAY_ESTRU_CMP_POS_COMP]
					oJsonCmp["sequence"             ] := aCompon[ARRAY_ESTRU_CMP_POS_SEQ]
					oJsonCmp["startRevison"         ] := aCompon[ARRAY_ESTRU_CMP_POS_REVINI]
					oJsonCmp["endRevison"           ] := aCompon[ARRAY_ESTRU_CMP_POS_REVFIM]
					oJsonCmp["quantity"             ] := aCompon[ARRAY_ESTRU_CMP_POS_QTDNEC]
					oJsonCmp["startDate"            ] := convDate(aCompon[ARRAY_ESTRU_CMP_POS_VLDINI])
					oJsonCmp["endDate"              ] := convDate(aCompon[ARRAY_ESTRU_CMP_POS_VLDFIM])
					oJsonCmp["percentageScrap"      ] := aCompon[ARRAY_ESTRU_CMP_POS_PERDA]
					oJsonCmp["fixedQuantity"        ] := getQtdFixa(aCompon[ARRAY_ESTRU_CMP_POS_QTDFIXA])
					oJsonCmp["optionalGroup"        ] := aCompon[ARRAY_ESTRU_CMP_POS_GRPOPC]
					oJsonCmp["optionalItem"         ] := aCompon[ARRAY_ESTRU_CMP_POS_ITEMOPC]
					oJsonCmp["potency"              ] := aCompon[ARRAY_ESTRU_CMP_POS_POTENC]
					oJsonCmp["warehouse"            ] := aCompon[ARRAY_ESTRU_CMP_POS_LOCAL]
					oJsonCmp["isGhostMaterial"      ] := aCompon[ARRAY_ESTRU_CMP_POS_FANTASM]
					oJsonCmp["code"                 ] := aDados[nIndex][ARRAY_ESTRU_CAB_POS_FILIAL] + cValToChar(aCompon[ARRAY_ESTRU_CMP_POS_RECNO])
					//Adiciona os alternativos se existir.
					If aCompon[ARRAY_ESTRU_CMP_POS_ALTERNATIVO] != Nil .And. Len(aCompon[ARRAY_ESTRU_CMP_POS_ALTERNATIVO]) > 0
						nTotAlt := Len(aCompon[ARRAY_ESTRU_CMP_POS_ALTERNATIVO])
						oJsonCmp["listOfMRPAlternatives"] := Array(nTotAlt)
						For nIndAlt := 1 To nTotAlt
							aAltern := aCompon[ARRAY_ESTRU_CMP_POS_ALTERNATIVO][nIndAlt]
							oJsonCmp["listOfMRPAlternatives"][nIndAlt] := JsonObject():New()
							oJsonAlt := oJsonCmp["listOfMRPAlternatives"][nIndAlt]

							oJsonAlt["alternative"     ] := aAltern[ARRAY_ESTRU_ALT_POS_ALTERN]
							oJsonAlt["conversionType"  ] := getConvType(aAltern[ARRAY_ESTRU_ALT_POS_TIPOCONV])
							oJsonAlt["conversionFactor"] := aAltern[ARRAY_ESTRU_ALT_POS_FATORCONV]
							oJsonAlt["vigency"         ] := convDate(aAltern[ARRAY_ESTRU_ALT_POS_VIGENCIA])
							oJsonAlt["inventory"       ] := aAltern[ARRAY_ESTRU_ALT_POS_ESTOQUE]
							oJsonAlt["sequence"        ] := aAltern[ARRAY_ESTRU_ALT_POS_SEQUENCIA]
						Next nIndAlt
					EndIf
				Next nIndCmp
			EndIf
		EndIf
	Next nIndex
	
	If testLock(lUnlock)
		If cOperation $ "|INSERT|SYNC|"
			If cOperation == "INSERT"
				aReturn := MrpBOMPost(oJsonData)
			Else
				aReturn := MrpBOMSync(oJsonData,lBuffer)
			EndIf
			PrcPendMRP(aReturn, cApi, oJsonData, lReproc, @aSuccess, @aError, @lAllError, '1', cUUID, lIntegra)
		Else
			aReturn := MrpEstrDel(oJsonData, nOpcao)
			PrcPendMRP(aReturn, cApi, oJsonData, lReproc, @aSuccess, @aError, @lAllError, '2', cUUID, lIntegra)
		EndIf
	Else
		addPendT4R(oJsonData, Iif(cOperation == "DELETE", "2", "1"), lReproc, lIntegra, cUUID)
	EndIf

	FreeObj(oJsonData)
	oJsonData := Nil

	aSize(aReturn , 0)
	aSize(aAltern , 0)
	aSize(aCompon , 0)

	If oJsonData != Nil
		FreeObj(oJsonData)
		oJsonData := Nil
	EndIf
	If oJsonCmp != Nil
		FreeObj(oJsonCmp)
		oJsonCmp := Nil
	EndIf
	If oJsonAlt != Nil
		FreeObj(oJsonAlt)
		oJsonAlt := Nil
	EndIf

Return Nil

/*/{Protheus.doc} getQtdFixa
Transforma o valor da quantidade fixa da SG1 para o valor correspondente
que deve ser enviado para a API

@type  Static Function
@author lucas.franca
@since 16/07/2019
@version P12.1.27
@param cG1FixVar, Character, Valor do campo G1_FIXVAR para realizar conversão ao valor recebido na API
@return cFixVar, Character, Valor convertido para o esperado na API
/*/
Static Function getQtdFixa(cG1FixVar)
	Local cFixVar := "2"

	If cG1FixVar == "F"
		cFixVar := "1"
	EndIf
Return cFixVar

/*/{Protheus.doc} getConvType
Transforma o valor do fator de conversão da SGI para o valor correspondente
que deve ser enviado para a API

@type  Static Function
@author lucas.franca
@since 16/07/2019
@version P12.1.27
@param cGIConvType, Character, Valor do campo GI_TIPOCON para realizar conversão ao valor recebido na API
@return cConvType , Character, Valor convertido para o esperado na API
/*/
Static Function getConvType(cGIConvType)
	Local cConvType := "1"

	If cGIConvType == "D"
		cConvType := "2"
	EndIf
Return cConvType

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
	If !Empty(dData)
		cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)
	EndIf
Return cData

/*/{Protheus.doc} cargaSG1
Faz a carga dos dados da SG1, buscando direto na tabela.
Irá fazer a busca de todos os códigos pais recebidos no objeto
json oIntegra.

@type  Static Function
@author lucas.franca
@since 16/07/2019
@version P12.1.27
@param oIntegra , Object, Objeto JSON com os códigos PAIS que devem ser carregados.
@param oModel   , Object, Objeto do modelo de dados do PCPA200
@param lOnlyDel , Logic , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param aDadosDel, Array , Array com dados de produtos que devem enviar a exclusão de estrutura.
@return aDadosInc, Array, Array com os dados da estrutura.
/*/
Static Function cargaSG1(oIntegra, oModel, lOnlyDel, aDadosDel)
	Local aChaves    := {}
	Local aDadosInc  := {}
	Local aDadosCab  := {}
	Local aDadosCmp  := {}
	Local cChave     := ""
	Local cFil       := ""
	Local cPai       := ""
	Local cQuery     := ""
	Local cAliasQry  := ""
	Local nIndex     := 0
	Local nTotal     := 0
	Local nTamFilial := FwSizeFilial()
	Local nTamProd   := GetSx3Cache("G1_COD"  , "X3_TAMANHO")
	Local nTamQtd    := GetSx3Cache("G1_QUANT", "X3_TAMANHO")
	Local nDecQtd    := GetSx3Cache("G1_QUANT", "X3_DECIMAL")
	Local nTamPerda  := GetSx3Cache("G1_PERDA", "X3_TAMANHO")
	Local nDecPerda  := GetSx3Cache("G1_PERDA", "X3_DECIMAL")
	Local oQuery     := Nil
	Local cPrdTable  := SuperGetMv("MV_ARQPROD",.F.,"SB1")

	Default aDadosDel := {}
	Default lOnlyDel  := .F.

	aChaves := oIntegra:GetNames()
	nTotal  := Len(aChaves)

	For nIndex := 1 To nTotal
		cChave := aChaves[nIndex]
		If oIntegra[cChave] == Nil .Or. oIntegra[cChave] <= 0
			Loop
		EndIf

		cFil := Left(cChave, nTamFilial)
		cPai := SubStr(cChave, nTamFilial + 1, nTamProd)

		//Monta array com os dados.
		aDadosCab := Array(ARRAY_ESTRU_CAB_SIZE)
		//Dados do cabeçalho
		aDadosCab[ARRAY_ESTRU_CAB_POS_FILIAL] := cFil
		If ! (lOnlyDel .And. Empty(cPai))
			aDadosCab[ARRAY_ESTRU_CAB_POS_PAI   ] := cPai
			aDadosCab[ARRAY_ESTRU_CAB_POS_COMPON] := {}

			If Empty(aDadosCab[ARRAY_ESTRU_CAB_POS_FILIAL])
				aDadosCab[ARRAY_ESTRU_CAB_POS_FILIAL] := xFilial("SG1")
			EndIf

			//Se o produto está bloqueado, será enviada a operação de exclusão para esta estrutura.
			If prdBlock(cPai)
				aAdd(aDadosDel, aClone(aDadosCab))
				Loop
			EndIf

			aDadosCab[ARRAY_ESTRU_CAB_POS_QBASE ] := getQtdBase(oModel, cPai)
			If oQuery == Nil
				If cPrdTable == "SBZ"

					cQuery := "SELECT SG1.G1_COMP,"
					cQuery += "	   SG1.G1_TRT,"
					cQuery += "	   SG1.G1_QUANT,"
					cQuery += "	   SG1.G1_INI,"
					cQuery += "	   SG1.G1_FIM,"
					cQuery += "	   SG1.G1_REVINI,"
					cQuery += "	   SG1.G1_REVFIM,"
					cQuery += "	   SG1.G1_PERDA,"
					cQuery += "	   SG1.G1_FIXVAR,"
					cQuery += "	   SG1.G1_POTENCI,"
					cQuery += "	   SG1.G1_GROPC,"
					cQuery += "	   SG1.G1_OPC,"
					cQuery += "	   SG1.G1_LOCCONS,"

					cQuery += "	   CASE "
					cQuery += "		  WHEN SG1.G1_FANTASM = ' ' "
					cQuery += "		  THEN"
					cQuery += "			  CASE "
					cQuery += "				  WHEN SBZ.BZ_FANTASM = 'S' "
					cQuery += "				  THEN 'T' "
					cQuery += "				  WHEN SBZ.BZ_FANTASM = 'N' "
					cQuery += "				  THEN 'F' "
					cQuery += "				  ELSE CASE"
					cQuery += "						  WHEN SB1.B1_FANTASM = 'S' "
					cQuery += "						  THEN 'T'"
					cQuery += "						  WHEN SB1.B1_FANTASM = 'N' "
					cQuery += "						  THEN 'F'"
					cQuery += "						  ELSE 'F'"
					cQuery += "					    END"
					cQuery += "			  END "
					cQuery += "		WHEN SG1.G1_FANTASM = '1'"
					cQuery += "			THEN 'T'"
					cQuery += "			ELSE 'F'"
					cQuery += "	END AS FANTASMA,"

					cQuery += "	SG1.R_E_C_N_O_ AS RECSG1,"
					cQuery += "	(SELECT COUNT(SGI.GI_FILIAL) FROM "+RetSqlName("SGI")+" SGI  WHERE  SGI.GI_FILIAL = '"+xFilial("SGI")+"' AND SGI.GI_PRODORI = SG1.G1_COMP AND SGI.GI_MRP = 'S' AND SGI.D_E_L_E_T_ = ' ' )  AS ALTERNATIVOS"
					cQuery += "	FROM "+RetSqlName("SG1")+" SG1 INNER JOIN "+RetSqlName("SB1")+" SB1"
					cQuery += "	ON B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SG1.G1_COMP AND SB1.D_E_L_E_T_ = ' '"

					cQuery += "	LEFT OUTER JOIN "+RetSqlName("SBZ")+" SBZ"
					cQuery += "	   ON SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"' AND SB1.B1_COD =  SBZ.BZ_COD AND SBZ.D_E_L_E_T_ = ' '"

					cQuery += "	WHERE  SG1.G1_FILIAL = ? "
					cQuery += "	  AND SG1.D_E_L_E_T_ = ' '"
					cQuery += "	  AND SG1.G1_COD     = ? "

				Else
					cQuery := " SELECT SG1.G1_COMP, "
					cQuery +=        " SG1.G1_TRT, "
					cQuery +=        " SG1.G1_QUANT, "
					cQuery +=        " SG1.G1_INI, "
					cQuery +=        " SG1.G1_FIM, "
					cQuery +=        " SG1.G1_REVINI, "
					cQuery +=        " SG1.G1_REVFIM, "
					cQuery +=        " SG1.G1_PERDA, "
					cQuery +=        " SG1.G1_FIXVAR, "
					cQuery +=        " SG1.G1_POTENCI, "
					cQuery +=        " SG1.G1_GROPC, "
					cQuery +=        " SG1.G1_OPC, "
					cQuery +=        " SG1.G1_LOCCONS, "
					cQuery +=        " CASE WHEN SG1.G1_FANTASM = ' ' THEN "
					cQuery +=                  " CASE WHEN (SELECT SB1.B1_FANTASM "
					cQuery +=                               " FROM " + RetSqlName("SB1") + " SB1 "
					cQuery +=                              " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
					cQuery +=                                " AND SB1.D_E_L_E_T_ = ' ' "
					cQuery +=                                " AND SB1.B1_COD     = SG1.G1_COMP ) = 'S' THEN 'T' "
					cQuery +=                  " ELSE 'F' "
					cQuery +=                  " END "
					cQuery +=             " WHEN SG1.G1_FANTASM = '1' THEN 'T' "
					cQuery +=             " ELSE 'F' "
					cQuery +=        " END AS FANTASMA, "
					cQuery +=        " SG1.R_E_C_N_O_ AS RECSG1, "
					cQuery +=        " (SELECT COUNT(SGI.GI_FILIAL) "
					cQuery +=           " FROM " + RetSqlName("SGI") + " SGI "
					cQuery +=          " WHERE SGI.GI_FILIAL  = '" + xFilial("SGI") + "' "
					cQuery +=            " AND SGI.GI_PRODORI = SG1.G1_COMP "
					cQuery +=            " AND SGI.GI_MRP = 'S' "
					cQuery +=            " AND SGI.D_E_L_E_T_ = ' ' ) AS ALTERNATIVOS "
					cQuery +=   " FROM " + RetSqlName("SG1") + " SG1 "
					cQuery +=  " WHERE SG1.G1_FILIAL  = ? "
					cQuery +=    " AND SG1.D_E_L_E_T_ = ' ' "
					cQuery +=    " AND SG1.G1_COD     = ? "
				EndIf

				cQuery := ChangeQuery(cQuery)
				oQuery := FWPreparedStatement():New(cQuery)
			EndIf

			oQuery:SetString(1,cFil)
			oQuery:SetString(2,cPai)

			cQuery := oQuery:GetFixQuery()

			cAliasQry := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)
			TcSetField(cAliasQry, "G1_INI"  , "D", 8        , 0)
			TcSetField(cAliasQry, "G1_FIM"  , "D", 8        , 0)
			TcSetField(cAliasQry, "G1_QUANT", "N", nTamQtd  , nDecQtd)
			TcSetField(cAliasQry, "G1_PERDA", "N", nTamPerda, nDecPerda)

			While (cAliasQry)->(!Eof())

				aDadosCmp := Array(ARRAY_ESTRU_CMP_SIZE)
				aDadosCmp[ARRAY_ESTRU_CMP_POS_COMP   ] := (cAliasQry)->G1_COMP
				aDadosCmp[ARRAY_ESTRU_CMP_POS_SEQ    ] := (cAliasQry)->G1_TRT
				aDadosCmp[ARRAY_ESTRU_CMP_POS_QTDNEC ] := (cAliasQry)->G1_QUANT
				aDadosCmp[ARRAY_ESTRU_CMP_POS_VLDINI ] := (cAliasQry)->G1_INI
				aDadosCmp[ARRAY_ESTRU_CMP_POS_VLDFIM ] := (cAliasQry)->G1_FIM
				aDadosCmp[ARRAY_ESTRU_CMP_POS_REVINI ] := (cAliasQry)->G1_REVINI
				aDadosCmp[ARRAY_ESTRU_CMP_POS_REVFIM ] := (cAliasQry)->G1_REVFIM
				aDadosCmp[ARRAY_ESTRU_CMP_POS_PERDA  ] := (cAliasQry)->G1_PERDA
				aDadosCmp[ARRAY_ESTRU_CMP_POS_QTDFIXA] := (cAliasQry)->G1_FIXVAR
				aDadosCmp[ARRAY_ESTRU_CMP_POS_POTENC ] := (cAliasQry)->G1_POTENCI
				aDadosCmp[ARRAY_ESTRU_CMP_POS_GRPOPC ] := (cAliasQry)->G1_GROPC
				aDadosCmp[ARRAY_ESTRU_CMP_POS_ITEMOPC] := (cAliasQry)->G1_OPC
				aDadosCmp[ARRAY_ESTRU_CMP_POS_LOCAL  ] := (cAliasQry)->G1_LOCCONS
				aDadosCmp[ARRAY_ESTRU_CMP_POS_FANTASM] := Iif(AllTrim((cAliasQry)->FANTASMA) == "T", .T., .F.)
				aDadosCmp[ARRAY_ESTRU_CMP_POS_RECNO  ] := (cAliasQry)->RECSG1
				If (cAliasQry)->ALTERNATIVOS > 0
					aDadosCmp[ARRAY_ESTRU_CMP_POS_ALTERNATIVO] := A200APIAlt(cPai, (cAliasQry)->G1_COMP)
				Else
					aDadosCmp[ARRAY_ESTRU_CMP_POS_ALTERNATIVO] := {}
				EndIf
				aAdd(aDadosCab[ARRAY_ESTRU_CAB_POS_COMPON], aClone(aDadosCmp))

				(cAliasQry)->(dbSkip())
			End
			(cAliasQry)->(dbCloseArea())
		EndIf
		If !Empty(aDadosCab[ARRAY_ESTRU_CAB_POS_COMPON])
			aAdd(aDadosInc, aClone(aDadosCab))
		EndIf
	Next nIndex

	aSize(aDadosCab, 0)
	aSize(aDadosCmp, 0)
	aSize(aChaves  , 0)
	If oQuery != Nil
		oQuery:Destroy()
		oQuery := Nil
	EndIf
Return aDadosInc

/*/{Protheus.doc} prdBlock
Verifica se um produto está bloqueado

@type  Static Function
@author lucas.franca
@since 23/09/2021
@version P12
@param cProduto, Character, Código do produto
@return lRet, Logic, Identifica se o produto está bloqueado
/*/
Static Function prdBlock(cProduto)
	Local lRet := .F.

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+cProduto))

	lRet := SB1->B1_MSBLQL == "1"

Return lRet

/*/{Protheus.doc} testLock
Testa o lock para verificar se pode executar a integração ou se o programa de sincronização está rodando.
@type  Static Function
@author Lucas Fagundes
@since 15/08/2022
@version P12
@param 01 lUnlock, Logico, Indica que deve realizar o unlock caso o teste do lock retorne .T.
@return lExec, Logico, .T. pode realizar a integração.
                       .F. programa de sincronização está rodando, não irá integrar (grava pendência na T4R).
/*/
Static Function testLock(lUnlock)
	lExec := LockByName("P140_ESTRUT",.T.,.F.)

	If lExec .And. lUnlock
		UnLockByName("P140_ESTRUT", .T., .F.)
	EndIf

Return lExec

/*/{Protheus.doc} addPendT4R
Adiciona pendência na tabela T4R quando não foi possivel chamar a API devido ao lock realizado pelo programa de sincronização.
@type  Static Function
@author Lucas Fagundes
@since 12/08/2022
@version P12
@param 01 oJsonData, Object, Objeto JSON que seria enviado para a API.
@param 02 cTipo, Caractere , Tipo de operação que será salva na coluna T4R_TIPO: "1" - Inclusão/Alteração
                                                                                 "2" - Exclusão
@param 03 lReproc , Logico   , Indica que está pendência está sendo inserida em um reprocessamento.
@param 04 lIntegra, Logico   , Indica que está pendência está sendo inserida em uma integração.
@param 05 cUUID   , Caractere, Código identificador do processo na tabela T4R.
@return Nil
/*/
Static Function addPendT4R(oJsonData, cTipo, lReproc, lIntegra, cUUID)
	Local aAux    := {}
	Local aPend   := {}
	Local cApi    := "MRPBILLOFMATERIAL"
	Local nIndex  := 0
	Local nTotal  := Len(oJsonData["items"])
	Local cIdReg := ""

	For nIndex := 1 To nTotal
		cIdReg := oJsonData["items"][nIndex]["branchId"] + oJsonData["items"][nIndex]["product"]
		aAux := Array(PCPInMrpCn("PEND_TAMANHO"))

		aAux[PCPInMrpCn("PEND_CODIGO") ] := cIdReg
		aAux[PCPInMrpCn("PEND_STATUS") ] := "2"
		aAux[PCPInMrpCn("PEND_ATRJSON")] := Nil
		aAux[PCPInMrpCn("PEND_POSICAO")] := Nil
		aAux[PCPInMrpCn("PEND_MSGRET") ] := STR0249 // "Integração realizada com sincronização em andamento"
		aAux[PCPInMrpCn("PEND_MSGENV") ] := oJsonData["items"][nIndex]:toJson()

		aAdd(aPend, aAux)
	Next

	PInMrpPend(0, Nil, lReproc, cApi, aPend, cTipo, cUUID, lIntegra)

	FwFreeArray(aPend)
Return Nil

/*/{Protheus.doc} P200Reproc
Reprocessa os registros pendêntes recebidos no parâmetro oJsonData.
(Chamada de reprocessamento do PCPA142)
@type  Function
@author Lucas Fagundes
@since 16/08/2022
@version P12
@param 01 oJsonData, Object   , Objeto JSON com os registros selecionados para serem reprocessados.
@param 02 cTipo    , Caractere, Tipo de operação que foi realizada "1" - Inclusão / Alteração
                                                                   "2" - Exclusão
@return Nil
/*/
Function P200Reproc(oJsonData, cTipo)
	Local cIdReg   := ""
	Local nIndex   := 0
	Local nTotal   := 0
	Local oIntegra := JsonObject():New()
	
	nTotal := Len(oJsonData["items"])

	For nIndex := 1 to nTotal
		// Monta o id do registro do processamento passado para buscar os dados atualizados no reprocessamento.
		cIdReg := oJsonData["items"][nIndex]["branchId"] + oJsonData["items"][nIndex]["product"]
		oIntegra[cIdReg] := 1
	Next

	If cTipo == "2"
		PCPA200MRP(Nil, Nil, oIntegra, "DELETE", Nil, Nil, .F., .T., "")
	Else
		PCPA200MRP(Nil, Nil, oIntegra, "INSERT", Nil, Nil, .F., .T., "")
	EndIf

	FreeObj(oIntegra)
	oIntegra := Nil
Return Nil

/*/{Protheus.doc} P200RepAll
Reprocessa os registros pendêntes da tabela T4R.
(Chamada de reprocessamento realizada na abertura do MRP)
@type  Function
@author Lucas Fagundes
@since 17/08/2022
@version P12
@param cUUID, Caractere, Código identificador do processo na tabela T4R.
@return Nil
/*/
Function P200RepAll(cUUID)
	Local cAlias  := GetNextAlias()
	Local cIdReg  := ""
	Local cQuery  := ""
	Local oDeleta := JsonObject():New()
	Local oSync   := JsonObject():New()

	cQuery := GetQryT4R(cUUID)

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)
	While (cAlias)->(!Eof())
		cIdReg := (cAlias)->T4R_IDREG

		If (cAlias)->T4R_TIPO == "2"
			oDeleta[cIdReg] := 1
		Else
			oSync[cIdReg] := 1
		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If Len(oDeleta:getNames()) > 0
		PCPA200MRP(Nil, Nil, oDeleta, "DELETE", Nil, Nil, .F., .T., cUUID)
	EndIf

	If Len(oSync:getNames()) > 0
		PCPA200MRP(Nil, Nil, oSync, "INSERT", Nil, Nil, .F., .T., cUUID)
	EndIf

	FreeObj(oDeleta)
	oDeleta := Nil
	FreeObj(oSync)
	oSync := Nil
Return Nil

/*/{Protheus.doc} getQryT4R
Monta query para buscar registros da API de estrutura na tabela T4R.
@type  Static Function
@author Lucas Fagundes
@since 17/08/2022
@version P12
@param 01 cUUID , Caractere, Usado para filtrar o campo T4R_IDPRC.
@return cQuery  , Caractere, Query para buscar registros da API de estrutura na tabela T4R.
/*/
Static Function getQryT4R(cUUID)
	Local cQuery := ""

	cQuery := " SELECT T4R_IDREG, T4R_TIPO "
	cQuery += " FROM " + RetSqlName("T4R")
	cQuery += " WHERE D_E_L_E_T_ = ' '"
	cQuery +=   " AND T4R_FILIAL = '" + xFilial("T4R") + "'"
	cQuery +=   " AND T4R_API = 'MRPBILLOFMATERIAL'"

	If !Empty(cUUID)
		cQuery += " AND T4R_IDPRC = '" + cUUID + "'"
	EndIf

Return cQuery
