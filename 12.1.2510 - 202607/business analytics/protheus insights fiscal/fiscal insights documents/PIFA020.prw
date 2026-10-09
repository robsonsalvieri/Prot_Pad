#include "Totvs.ch"
#include "PIFA020.ch"

//------------------------------------------------------------------------------
/* {Protheus.doc} PIFA020
    Chamada da rotina de Fiscal Insight NCM

    @type Function
    @author Squad PIF
    @return Nil
*/
//------------------------------------------------------------------------------
Function PIFA020()

	IIF(IsBlind(), .T., FwCallApp("pifa020"))

Return

//------------------------------------------------------------------------------
/* {Protheus.doc} JsToAdvpl
    Função que recebera as chamadas JavaScript

    @type Static Function
    @author Squad PIF
    @params oWebChannel, Object   , Instância da classe TWebChannel
    @params cType      , Character, Tipo
    @params cContent   , Character, Conteúdo
    @return Nil
*/
//------------------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel As Object, cType As Character, cContent As Character )
	Local JContent  := JsonObject():New() 	As Json
	Local JResponse := JsonObject():New() 	As Json
	Local JValue    := JsonObject():New() 	As Json
	Local lRet      := .F.                 	As Logical
	Local cBranch   := "" 					As Character
	Local cOrder	:= "" 					As Character
	Local cDocument := "" 					As Character
	Local cSerie    := "" 					As Character
	Local cSupplier := "" 					As Character
	Local cStore    := "" 					As Character
	Local aDocs     := Nil 					As Json

	Do Case
	Case cType == "viewPurchaseOrder"
		JContent:fromJson(cContent)
		JValue := JContent:GetJsonObject("value")

		cBranch   := JValue:GetJsonText("branch")
		cOrder    := JValue:GetJsonText("order")
		lRet      := ViewPurOrd(cBranch, cOrder)

		JResponse["success"]   := .T.

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	Case cType == "viewDocument"
		JContent:fromJson(cContent)
		JValue := JContent:GetJsonObject("value")

		cBranch   := JValue:GetJsonText("branch")
		cDocument := JValue:GetJsonText("document")
		cSerie    := JValue:GetJsonText("serie")
		cSupplier := JValue:GetJsonText("supplier")
		cStore    := JValue:GetJsonText("store")
		lRet      := ViewDocum(cBranch, cDocument, cSerie, cSupplier, cStore)

		JResponse["success"]   := lRet

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	Case cType == "invoiceGeneration"
		JContent:fromJson(cContent)
		JValue := JContent:GetJsonObject("value")

		aDocs  := JValue:GetJsonObject("documents")
		lRet   := ApplyComxOper(aDocs, 1)

		JResponse["success"]   := lRet

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	Case cType == "linkPurchaseOrder"
		JContent:fromJson(cContent)
		JValue := JContent:GetJsonObject("value")

		lRet   := ProcessOrderLink(JValue, .F.)

		JResponse["success"]   := lRet

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	Case cType == "unLinkPurchaseOrder"
		JContent:fromJson(cContent)
		JValue := JContent:GetJsonObject("value")

		lRet   := ProcessOrderLink(JValue, .T.)

		JResponse["success"]   := lRet

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	Case cType == "reprocessDocuments"
		JContent:fromJson(cContent)
		JValue := JContent:GetJsonObject("value")

		IIF(IsBlind(), .T., IIF(Pergunte('COLREP', .T.), COMCOLREP(), .F.))

		JResponse["success"]   := .T.

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	Case cType == "deleteDocument"
		JContent:fromJson(cContent)
		JValue := JContent:GetJsonObject("value")

		aDocs  := JValue:GetJsonObject("documents")
		lRet   := ApplyComxOper(aDocs, 2)

		JResponse["success"]   := lRet

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	EndCase

	FWFreeObj(JContent)
	FWFreeObj(JValue)
	FWFreeObj(JResponse)
	FWFreeObj(aDocs)
Return


//------------------------------------------------------------------------------
/* {Protheus.doc} ProcessOrderLink
    Função que realiza o vínculo ou desvínculo do pedido de compra no documento do importador XML (SDS/SDT).

    @type Static Function
    @author Squad PIF
	@param JValue, Object, Objeto Json com os dados para realizar o vínculo ou desvínculo
	@param lUnlink, Logical, Indica se é para realizar o vínculo ou desvínculo
	@return .T.
	@see COMXCOL
*/
//------------------------------------------------------------------------------
Static Function processOrderLink(JValue As Json, lUnlink As Logical)
	Local nX   		:= 0 	As Numeric
	Local lRet 		:= .F. 	As Logical
	Local cBranch   := "" 	As Character
	Local cDocument := "" 	As Character
	Local cSerie    := "" 	As Character
	Local cSupplier := "" 	As Character
	Local cStore    := "" 	As Character
	Local aCabec    := {} 	As Array
	Local aItens    := {} 	As Array
	Local aVincPC   := {} 	As Array
	Local aPCVinc   := {} 	As Array
	Local aLinha    := {} 	As Array
	Local nType     := 0 	As Numeric
	Local cItem	 	:= "" 	As Character
	Local cPedido 	:= "" 	As Character
	Local cItemPed  := "" 	As Character
	Local cFilBkp   := "" 	As Character
	Local JDocument := Nil 	As Json
	Local aOrders   := Nil 	As Json

	Private lMsErroAuto		:= .F. 	As Logical
	Private lAutoErrNoFile	:= .T. 	As Logical

	JDocument  := JValue:GetJsonObject("document")
	aOrders    := JValue:GetJsonObject("orders")

	cBranch   := PadR(JDocument:GetJsonText("branch")        , TamSx3("F1_FILIAL")[1])
	cDocument := PadL(JDocument:GetJsonText("documentNumber"), TamSx3("F1_DOC")[1], "0")
	cSerie    := PadR(JDocument:GetJsonText("serie")         , TamSx3("F1_SERIE")[1])
	cSupplier := PadR(JDocument:GetJsonText("supplierCode")  , TamSx3("F1_FORNECE")[1])
	cStore    := PadR(JDocument:GetJsonText("supplierStore") , TamSx3("F1_LOJA")[1])

	cFilBkp := cFilAnt
	cFilAnt := cBranch

	aCabec  := {}
	aItens  := {}
	aVincPC := {}
	aPCVinc := {}
	aAdd(aCabec,{"DS_FILIAL"    ,cBranch   ,Nil})
	aAdd(aCabec,{"DS_DOC"    	,cDocument ,Nil})
	aAdd(aCabec,{"DS_SERIE"  	,cSerie    ,Nil})
	aAdd(aCabec,{"DS_FORNEC"	,cSupplier ,Nil})
	aAdd(aCabec,{"DS_LOJA"   	,cStore    ,Nil})

	For nX := 1 to len(aOrders)
		aLinha   := {}
		nType    := aOrders[nX]:GetJsonObject("type")
		cItem    := aOrders[nX]:GetJsonText("item")
		cPedido  := aOrders[nX]:GetJsonText("order")
		cItemPed := aOrders[nX]:GetJsonText("orderItem")

		// Tratamento para evitar passar "null" para a rotina COMXCOL
		If cItem    == "null" ; cItem    := "" ; EndIf
		If cPedido  == "null" ; cPedido  := "" ; EndIf
		If cItemPed == "null" ; cItemPed := "" ; EndIf

		aAdd(aLinha, {"TYPE"          ,nType    ,Nil}) // 1= Item 2= Doc
		aAdd(aLinha, {"PEDIDO"        ,cPedido  ,Nil})

		If nType == 1 .Or. nType == 3 // Por item / Desvinculo
			aAdd(aLinha, {"ITEM"      ,cItem    ,Nil})
			aAdd(aLinha, {"ITEMPED"   ,cItemPed ,Nil})
		EndIf

		aAdd(aVincPC, aLinha)

	Next

	IIF(IsBlind(), .T., COMXCOL(aCabec,aItens,4,,aVincPC, aPCVinc))

	cFilAnt := cFilBkp

	lRet := len(aPCVinc) > 0

	FwFreeArray(aCabec)
	FwFreeArray(aItens)
	FwFreeArray(aVincPC)
	FwFreeArray(aPCVinc)
	FWFreeObj(JDocument)
	FWFreeObj(aOrders)

Return lRet


//------------------------------------------------------------------------------
/* {Protheus.doc} ApplyComxOper
    Função que realiza a operação de geração ou exclusão da nota fiscal no monitor COMXCOL (SDS/SDT) para os documentos selecionados.

    @type Static Function
    @author Squad PIF
	@param aDocuments, Array, Array de objetos Json com os documentos a serem processados
	@param nAction   , Numeric, Ação a ser realizada (1=Gerar Nota, 2=Excluir Nota)
	@return .T.
	@see COMCOLGER
*/
//------------------------------------------------------------------------------
Static Function ApplyComxOper(aDocuments As Array, nAction As Numeric)
	Local aArea		    := FWGetArea() 				As Array
	Local aAreaSDS	    := SDS->(FWGetArea()) 		As Array
	Local nX            := 0 						As Numeric
	Local JDoc          := Nil 						As Json
	Local cBranch       := "" 						As Character
	Local cDocument     := "" 						As Character
	Local cSerie        := "" 						As Character
	Local cSupplier     := "" 						As Character
	Local cStore        := "" 						As Character
	Local lYesNo        := .F. 						As Logical
	Local aCabec        := {} 						As Array
	Local aItens        := {} 						As Array

	Private aRotina	    := {{""	,"PesqBrw",0,1,0,nil}, {""	,"COMCOLVIS",0,1,0,nil}, {""	,"COMCOLVIN",0,4,0,nil}, {""	,"COMCOLEXC",0,4,0,nil}} As Array
	Private cMarca	    := GetMark() 				As Character
	Private cCadastro   := STR0004 					As Character // "Importador XML"
	Private aRegMark    := {} 						As Array
	Private lToma4NFOri	:= .T. 						As Logical
	Private cFilQry     := '' 						As Character
	Private lRevA1A2	:= .F. 						As Logical
	Private acolsDkm	:= {} 						As Array
	Private ALTERA      := .F. 						As Logical
	Private INCLUI      := .F. 						As Logical
	Private EXCLUI      := .F. 						As Logical
	Private VISUALIZA   := .F. 						As Logical
	Private lMsErroAuto := .F. 						As Logical
	Private lMsHelpAuto := .F. 						As Logical

	SDS->(DbSetOrder(1))
	SF1->(DbSetOrder(1))

	For nX := 1 To len(aDocuments)

		JDoc      := aDocuments[nX]
		cBranch   := PadR(JDoc:GetJsonText("branch")  , TamSx3("F1_FILIAL")[1])
		cDocument := PadL(JDoc:GetJsonText("document"), TamSx3("F1_DOC")[1])
		cSerie    := PadR(JDoc:GetJsonText("serie")   , TamSx3("F1_SERIE")[1])
		cSupplier := PadR(JDoc:GetJsonText("supplier"), TamSx3("F1_FORNECE")[1])
		cStore    := PadR(JDoc:GetJsonText("store")   , TamSx3("F1_LOJA")[1])

		// Caso o action seja exclusão verifica se a nota existe na SF1
		If SF1->(MsSeek(FWxFilial("SF1", cBranch)+cDocument+cSerie+cSupplier+cStore)) .And. nAction == 2
			ALTERA    := .F.
			INCLUI    := .F.
			EXCLUI    := .T.
			VISUALIZA := .F.

			lMsErroAuto := .F.
			lMsHelpAuto := .T.

			FwFreeArray(aCabec)
			FwFreeArray(aItens)
			aCabec := {}
			aItens := {}
			aadd(aCabec,{"F1_DOC"    	,SF1->F1_DOC})
			aadd(aCabec,{"F1_SERIE"  	,SF1->F1_SERIE})
			aadd(aCabec,{"F1_FORNECE"	,SF1->F1_FORNECE})
			aadd(aCabec,{"F1_LOJA"   	,SF1->F1_LOJA})

			If Empty(SF1->F1_STATUS)
				lYesNo := .T.
				IIF(IsBlind(), lYesNo := .T., lYesNo := MsgYesNo(STR0002, STR0001)) // "Novo Importador de Compras"

				If lYesNo
					IIF(IsBlind(), .T., MSExecAuto({|x,y,z,a,b| MATA140(x,y,z,a,b)},aCabec,aItens,5,,2))
				EndIf
			Else
				lYesNo := .T.
				IIF(IsBlind(), lYesNo := .T., lYesNo := MsgYesNo(STR0003, STR0001)) // "Novo Importador de Compras"

				If lYesNo
					IIF(IsBlind(), .T., MSExecAuto({|x,y,z,a| MATA103(x,y,z,a)},aCabec,aItens,5))
				EndIf
			EndIf

			If lMsErroAuto ; MostraErro() ; EndIf
		Else
			If SDS->(MsSeek(FWxFilial("SDS", cBranch)+cDocument+cSerie+cSupplier+cStore))

				// Marca o registro
				RecLock("SDS", .F.)
				SDS->DS_OK := cMarca
				SDS->(MsUnlock())

				aAdd(aRegMark, SDS->(Recno()))
			EndIF
		EndIf

	Next

	If len(aRegMark) > 0

		If nAction == 1 // Gerar Nota
			IIF(IsBlind(), .T., COMCOLGER())
		ElseIf nAction == 2 // Excluir Nota
			IIF(IsBlind(), .T., COMCOLEXC())
		EndIf

		// Limpando os registros marcados
		COLREPCLICK(6)
	EndIf

	FwFreeArray(aCabec)
	FwFreeArray(aItens)
	FwFreeArray(aRegMark)
	FWRestArea(aAreaSDS)
	FWRestArea(aArea)

Return .T.


//------------------------------------------------------------------------------
/* {Protheus.doc} ViewDocum
    Função para visualização do documento de entrada, pré-nota ou o documento do importador xml (SDS/SDT).

    @type Static Function
    @author Squad PIF
	@params cBranch  , Character, Filial
    @params cDocument, Character, Documento
    @params cSerie   , Character, Serie do documento
    @params cSupplier, Character, Código do fornecedor
    @params cStore   , Character, Loja do fornecedor
    @return lRet     , Logical  , Indica se conseguiu abrir a rotina
*/
//------------------------------------------------------------------------------
Static Function ViewDocum(cBranch As Character, cDocument As Character, cSerie As Character, cSupplier As Character, cStore As Character)
	Local aArea		:= FWGetArea() 			As Array
	Local aAreaSD1	:= SD1->(FWGetArea()) 	As Array
	Local aAreaSF1	:= SF1->(FWGetArea()) 	As Array
	Local lRet      := .F. 					As Logical
	Local cFilBkp   := cFilAnt 				As Character

	cBranch   := PadR(cBranch  , TamSx3("F1_FILIAL")[1])
	cDocument := PadL(cDocument, TamSx3("F1_DOC")[1])
	cSerie    := PadR(cSerie   , TamSx3("F1_SERIE")[1])
	cSupplier := PadR(cSupplier, TamSx3("F1_FORNECE")[1])
	cStore    := PadR(cStore   , TamSx3("F1_LOJA")[1])

	cFilAnt   := cBranch

	SF1->(DbSetOrder(1))
	SDS->(DbSetOrder(1))

	If SF1->(MsSeek(FWxFilial("SF1", cBranch)+cDocument+cSerie+cSupplier+cStore))

		If Empty(SF1->F1_STATUS)
			lRet := .T.
			DocumA103(4)
		Else
			lRet := .T.
			DocumA103(1)
		EndIf
	Elseif SDS->(MsSeek(FWxFilial("SDS", cBranch)+cDocument+cSerie+cSupplier+cStore))
		lRet := .T.
		AlterComx()
	EndIf

	cFilAnt := cFilBkp

	FWRestArea(aAreaSD1)
	FWRestArea(aAreaSF1)
	FWRestArea(aArea)
Return lRet


//------------------------------------------------------------------------------
/* {Protheus.doc} AlterComx
    Função para abrir o monitor COMXCOL (SDS/SDT) em modo de edição.

    @type Static Function
    @author Squad PIF
	@return Nil
*/
//------------------------------------------------------------------------------
Static Function AlterComx()
	// Variáveis Private usadas pela COMXCOL
	Private aRotina	    := {}					As Array	
	Private cMarca	    := GetMark()			As Character
	Private cCadastro   := STR0004      		As Character // "Importador XML"
	Private aRegMark    := {}					As Array
	Private lToma4NFOri	:= .T.					As Logical
	Private cFilQry     := ''					As Character
	Private lRevA1A2	:= .F.					As Logical
	Private acolsDkm	:= {}					As Array

	aRotina	    := {{""	,"PesqBrw",0,1,0,nil}, {""	,"COMCOLVIS",0,1,0,nil}, {""	,"COMCOLVIN",0,4,0,nil}}

	IIF(IsBlind(), .T., COMCOLVIN())

Return


//------------------------------------------------------------------------------
/* {Protheus.doc} DocumA103
    Função para executar função do documento de entrada (MATA103) de acordo com a opção passada.

    @type Static Function
    @author Squad PIF
	@params nOpc, Numeric, Opção
	@return Nil
*/
//------------------------------------------------------------------------------
Static Function DocumA103(nOpc As Numeric)
	Private aRotina    := {{'' ,"AxPesqui", 0, 1}, {'' ,"A103NFiscal", 0, 2}, {'' ,"A103NFiscal", 0, 3}, {'' ,"A103NFiscal", 0, 4}, {"", "A103NFiscal", 3 , 5}} As Array
	Private l103Auto   := .F. 								As Logical
	Private aAutoCab   := {} 								As Array
	Private aAutoItens := {} 								As Array
	Private cCadastro  := IIF(nOpc == 5, STR0005 + " - " + STR0006, STR0005) As Character // "Documento de Entrada - EXCLUIR"

	IIF(IsBlind(), .T., A103NFiscal( "SF1", SF1->(Recno()), nOpc))

Return


//------------------------------------------------------------------------------
/* {Protheus.doc} ViewPurOrd
    Função para visualização do pedido de compra.

    @type Static Function
    @author Squad PIF
    @params cBranch, Character, Filial
    @params cOrder , Character, Pedido de compra
    @return lRet   , Logical  , Indica se conseguiu abrir a rotina
    @see MaViewPC
*/
//------------------------------------------------------------------------------
Static Function ViewPurOrd(cBranch As Character, cOrder As character)
	Local aArea		    := FWGetArea() 				As Array
	Local aAreaSC7	    := SC7->(FWGetArea()) 		As Array
	Local aAreaSB1	    := SB1->(FWGetArea()) 		As Array
	Local lRet          := .F. 						As Logical
	Local cFilBkp       := cFilAnt 					As Character

	Private aRotina	    := {{ , , 0 , 2 }} 			As Array
	Private nTipoPed	:= 1 						As Numeric
	Private l120Auto	:= .F. 						As Logical
	Private cMarca	    := GetMark() 				As Character

	cBranch             := PadR(cBranch, TamSx3("C7_FILIAL")[1])
	cFilAnt             := cBranch

	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	If SC7->(MsSeek(FWxFilial("SC7", cBranch)+cOrder))
		lRet := .T.
		IIF(IsBlind(), .T., MatA120(SC7->C7_TIPO,,,2))
	EndIf

	cFilAnt := cFilBkp

	FWRestArea(aAreaSC7)
	FWRestArea(aAreaSB1)
	FWRestArea(aArea)

Return lRet

