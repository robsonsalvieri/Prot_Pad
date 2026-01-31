#Include "Totvs.ch"

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
	Local JContent  := JsonObject():New() As Json
	Local JResponse := JsonObject():New() As Json
	Local JValue    := JsonObject():New() As Json
	Local lRet                            As Logical

	Do Case
	Case cType == "playload"
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
		lRet   := GerComx(aDocs)

		JResponse["success"]   := lRet

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	Case cType == "linkPurchaseOrder"
		JContent:fromJson(cContent)
		JValue := JContent:GetJsonObject("value")

		lRet   := linkOrder(JValue)

		JResponse["success"]   := lRet

		oWebChannel:AdvplToJs(JContent:GetJsonText("eventId"), JResponse:toJson())
	EndCase

	FWFreeObj(JContent)
	FWFreeObj(JValue)
	FWFreeObj(JResponse)
Return

//------------------------------------------------------------------------------
/* {Protheus.doc} linkOrder
    Função que realiza o vínculo do pedido de compra ao documento de entrada.

    @type Static Function
    @author Squad PIF
	@param JValue, Object, Objeto Json com os dados para vinculação
	@return .T.
	@see COMXCOL
*/
//------------------------------------------------------------------------------
Static Function linkOrder(JValue As Json)
	Local nX   := 0 
	Local lRet := .F.

	JDocument  := JValue:GetJsonObject("document")
	aOrders    := JValue:GetJsonObject("orders")

	cBranch   := PadR(JDocument:GetJsonText("branch")        ,TamSx3("F1_FILIAL")[1])
	cDocument := PadL(JDocument:GetJsonText("documentNumber"), TamSx3("F1_DOC")[1], "0")
	cSerie    := PadR(JDocument:GetJsonText("serie")         , TamSx3("F1_SERIE")[1])
	cSupplier := PadR(JDocument:GetJsonText("supplierCode")  , TamSx3("F1_FORNECE")[1])
	cStore    := PadR(JDocument:GetJsonText("supplierStore") , TamSx3("F1_LOJA")[1])

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

		aAdd(aLinha, {"TYPE"      ,nType        ,Nil}) // 1= Item 2= Doc
		aAdd(aLinha, {"PEDIDO"    ,cPedido      ,Nil})

		If nType == 1
			aAdd(aLinha, {"ITEM"      ,cItem    ,Nil})
			aAdd(aLinha, {"ITEMPED"   ,cItemPed ,Nil})
		EndIf

		aAdd(aVincPC, aLinha)

	Next

	IIF(IsBlind(), .T., COMXCOL(aCabec,aItens,4,,aVincPC, aPCVinc))

	lRet := len(aPCVinc) > 0

Return lRet


//------------------------------------------------------------------------------
/* {Protheus.doc} GerComx
    Função que monta os dados e chama o processo de geração dos documentos fiscais.

    @type Static Function
    @author Squad PIF
	@param aDocuments, Array, Array de objetos Json com os documentos a serem processados
	@return .T.
	@see COMCOLGER
*/
//------------------------------------------------------------------------------
Static Function GerComx(aDocuments As Array)
	Local aArea		    := FWGetArea()
	Local aAreaSDS	    := SDS->(FWGetArea())
	Local nX            := 0

	Private aRotina	    := {{""	,"PesqBrw",0,1,0,nil}, {""	,"COMCOLVIS",0,1,0,nil}, {""	,"COMCOLVIN",0,4,0,nil}}
	Private cMarca	    := GetMark()
	Private cCadastro   := "Importador XML"
	Private aRegMark    := {}
	Private lToma4NFOri	:= .T.
	Private cFilQry     := ''
	Private lRevA1A2	:= .F.
	Private acolsDkm	:= {}

	SDS->(DbSetOrder(1))

	For nX := 1 To len(aDocuments)

		JDoc      := aDocuments[nX]
		cBranch   := PadR(JDoc:GetJsonText("branch")  , TamSx3("F1_FILIAL")[1])
		cDocument := PadL(JDoc:GetJsonText("document"), TamSx3("F1_DOC")[1], "0")
		cSerie    := PadR(JDoc:GetJsonText("serie")   , TamSx3("F1_SERIE")[1])
		cSupplier := PadR(JDoc:GetJsonText("supplier"), TamSx3("F1_FORNECE")[1])
		cStore    := PadR(JDoc:GetJsonText("store")   , TamSx3("F1_LOJA")[1])

		If SDS->(MsSeek(FWxFilial("SDS", cBranch)+cDocument+cSerie+cSupplier+cStore))

			// Marca o registro
			RecLock("SDS", .F.)
			SDS->DS_OK := cMarca
			SDS->(MsUnlock())

			nRecSDS := SDS->(Recno())

			aAdd(aRegMark, nRecSDS)
		EndIF
	Next

	if len(aRegMark) > 0
		IIF(IsBlind(), .T., COMCOLGER())

		// Limpando os registros marcados
		COLREPCLICK(6)
	endif

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
	Local aArea		:= FWGetArea()
	Local aAreaSD1	:= SD1->(FWGetArea())
	Local aAreaSF1	:= SF1->(FWGetArea())
	Local lRet      := .F.

	cBranch   := PadR(cBranch  , TamSx3("F1_FILIAL")[1])
	cDocument := PadL(cDocument, TamSx3("F1_DOC")[1], "0")
	cSerie    := PadR(cSerie   , TamSx3("F1_SERIE")[1])
	cSupplier := PadR(cSupplier, TamSx3("F1_FORNECE")[1])
	cStore    := PadR(cStore   , TamSx3("F1_LOJA")[1])

	SF1->(DbSetOrder(1))
	SDS->(DbSetOrder(1))

	If SF1->(MsSeek(FWxFilial("SF1", cBranch)+cDocument+cSerie+cSupplier+cStore))

		if Empty(SF1->F1_STATUS)
			lRet := .T.
			DocumA103(4)
		Else
			lRet := .T.
			DocumA103(1)
		endif
	Elseif SDS->(MsSeek(FWxFilial("SDS", cBranch)+cDocument+cSerie+cSupplier+cStore))
		lRet := .T.
		AlterComx()
	EndIf

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
	Private aRotina	    := {{""	,"PesqBrw",0,1,0,nil}, {""	,"COMCOLVIS",0,1,0,nil}, {""	,"COMCOLVIN",0,4,0,nil}}
	Private cMarca	    := GetMark()
	Private cCadastro   := "Importador XML"
	Private aRegMark    := {}
	Private lToma4NFOri	:= .T.
	Private cFilQry     := ''
	Private lRevA1A2	:= .F.
	Private acolsDkm	:= {}

	IIF(IsBlind(), .T., COMCOLVIN())

Return


//------------------------------------------------------------------------------
/* {Protheus.doc} DocumA103
    Função para abrir o documento de entrada (MATA103) de acordo com a opção passada.

    @type Static Function
    @author Squad PIF
	@params nOpc, Numeric, Opção
	@return Nil
*/
//------------------------------------------------------------------------------
Static Function DocumA103(nOpc As Numeric)
	Private aRotina    := {{'' ,"AxPesqui", 0, 1}, {'' ,"A103NFiscal", 0, 2}, {'' ,"A103NFiscal", 0, 3}, {'' ,"A103NFiscal", 0, 4}}
	Private l103Auto   := .F.
	Private aAutoCab   := {}
	Private aAutoItens := {}
	Private cCadastro  := "Documento de Entrada"

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
	Local aArea		    := FWGetArea()
	Local aAreaSC7	    := SC7->(FWGetArea())
	Local aAreaSB1	    := SB1->(FWGetArea())
	Local lRet          := .F.

	Private aRotina	    := {{ , , 0 , 2 }}
	Private nTipoPed	:= 1
	Private l120Auto	:= .F.

	dbSelectArea("SC7")
	SC7->(dbSetOrder(1))
	If SC7->(MsSeek(FWxFilial("SC7", PadR(cBranch, TamSx3("C7_FILIAL")[1]))+cOrder))
		lRet := .T.
		IIF(IsBlind(), .T., MatA120(SC7->C7_TIPO,,,2))
	EndIf

	FWRestArea(aAreaSC7)
	FWRestArea(aAreaSB1)
	FWRestArea(aArea)

Return lRet
