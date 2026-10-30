#include "Totvs.ch"
#include "PIFA020.ch"

Static __lP020FLD  := ExistBlock( "P020FLD",,.T. )

//------------------------------------------------------------------------------
// Defines para os tipos de vínculo utilizados pela COMXCOL
//------------------------------------------------------------------------------
#define LINK_BY_ITEM 1
#define LINK_BY_DOC  2
#define UNLINK_ITEM  3

//------------------------------------------------------------------------------
/* {Protheus.doc} PIFA020
    Chamada da rotina de Novo Importador de XML
	@param lAutoma , Logical, Valida se a rotina é chamada a partir de uma automação (ADVPR)

    @type Function
    @author Squad PIF
    @since 27/11/2025
    @return Nil
*/
//------------------------------------------------------------------------------
Function PIFA020(lAutoma As Logical)
	Local nOpc 		:=  1 	As Numeric
	Local lBlind  	:= .F.	As Logical
	Local lAccess 	:= .F.	As Logical
	Local cUrl 		:= "https://produtos.totvs.com/ficha-tecnica/totvs-transmite/"

	Default lAutoma := .F.

	lBlind		:= IsBlind()
	lAccess 	:= totvs.protheus.backoffice.pif.util.CanAccess("PIFA020")

	If (lAccess .And. !lAutoma)
		IIF(lBlind, .T., FwCallApp("pifa020"))
	Else 
		nOpc := Aviso(STR0008, STR0009 + CRLF + CRLF + STR0010 , { STR0011 , STR0012 }, 2)
		If nOpc == 1
			ShellExecute("open",cUrl,"","",1)
		EndIf
	EndIf

Return

//------------------------------------------------------------------------------
/* {Protheus.doc} JsToAdvpl
    Função que recebe as chamadas JavaScript do frontend e direciona para as
    rotinas específicas de visualização, geração, vínculo, reprocessamento,
    exclusão e criação de pedido de compra.

    @type Static Function
    @author Squad PIF
    @since 27/11/2025
    @param oWebChannel, Object   , Instância da classe TWebChannel
    @param cType      , Character, Tipo da operação solicitada
    @param cContent   , Character, Conteúdo JSON enviado pelo frontend
    @return Nil
*/
//------------------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel As Object, cType As Character, cContent As Character )
	Local jContent  := JsonObject():New() 	As Json
	Local jResponse := JsonObject():New() 	As Json
	Local jResult 	:= JsonObject():New()	As Json
	Local jValue    := JsonObject():New() 	As Json
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
		jContent:fromJson(cContent)
		jValue := jContent:GetJsonObject("value")

		cBranch   := jValue:GetJsonText("branch")
		cOrder    := jValue:GetJsonText("order")
		lRet      := ViewPurOrd(cBranch, cOrder)

		jResponse["success"]   := .T.

		oWebChannel:AdvplToJs(jContent:GetJsonText("eventId"), jResponse:toJson())
	Case cType == "viewDocument"
		jContent:fromJson(cContent)
		jValue := jContent:GetJsonObject("value")

		cBranch   := jValue:GetJsonText("branch")
		cDocument := jValue:GetJsonText("document")
		cSerie    := jValue:GetJsonText("serie")
		cSupplier := jValue:GetJsonText("supplier")
		cStore    := jValue:GetJsonText("store")
		lRet      := ViewDocum(cBranch, cDocument, cSerie, cSupplier, cStore)

		jResponse["success"]   := lRet

		oWebChannel:AdvplToJs(jContent:GetJsonText("eventId"), jResponse:toJson())
	Case cType == "invoiceGeneration"
		jContent:fromJson(cContent)
		jValue := jContent:GetJsonObject("value")

		aDocs  := jValue:GetJsonObject("documents")
		lRet   := ApplyComxOper(aDocs, 1)

		jResponse["success"]   := lRet

		oWebChannel:AdvplToJs(jContent:GetJsonText("eventId"), jResponse:toJson())
	Case cType == "linkPurchaseOrder"
		jContent:fromJson(cContent)
		jValue := jContent:GetJsonObject("value")

		lRet   := ProcessOrderLink(jValue)

		jResponse["success"]   := lRet

		oWebChannel:AdvplToJs(jContent:GetJsonText("eventId"), jResponse:toJson())
	Case cType == "unLinkPurchaseOrder"
		jContent:fromJson(cContent)
		jValue := jContent:GetJsonObject("value")

		lRet   := ProcessOrderLink(jValue)

		jResponse["success"]   := lRet

		oWebChannel:AdvplToJs(jContent:GetJsonText("eventId"), jResponse:toJson())
	Case cType == "reprocessDocuments"
		jContent:fromJson(cContent)
		jValue := jContent:GetJsonObject("value")

		IIF(IsBlind(), .T., IIF(Pergunte('COLREP', .T.), COMCOLREP(), .F.))

		jResponse["success"]   := .T.

		oWebChannel:AdvplToJs(jContent:GetJsonText("eventId"), jResponse:toJson())
	Case cType == "deleteDocument"
		jContent:fromJson(cContent)
		jValue := jContent:GetJsonObject("value")

		aDocs  := jValue:GetJsonObject("documents")
		lRet   := ApplyComxOper(aDocs, 2)

		jResponse["success"]   := lRet

		oWebChannel:AdvplToJs(jContent:GetJsonText("eventId"), jResponse:toJson())
	Case cType == "createPurchaseOrder"
		jContent:fromJson(cContent)
		jValue := jContent:GetJsonObject("value")

		aDocs  := {}
		aAdd(aDocs, jValue:GetJsonObject("documents"))
		jResult := CreatePO(aDocs)

		jResponse["success"] := jResult["success"]
		If !Empty(jResult["message"])
			jResponse["message"] := jResult["message"]
		EndIf

		FWFreeObj(jResult)

		oWebChannel:AdvplToJs(jContent:GetJsonText("eventId"), jResponse:toJson())
	EndCase

	FWFreeObj(jContent)
	FWFreeObj(jValue)
	FWFreeObj(jResponse)
	FWFreeObj(aDocs)
Return


//------------------------------------------------------------------------------
/* {Protheus.doc} ProcessOrderLink
    Função que realiza o vínculo ou desvínculo do pedido de compra no documento do importador XML (SDS/SDT).

    @type Static Function
    @author Squad PIF
    @since 11/12/2025
    @param jValue, Json, Objeto Json com os dados para realizar o vínculo ou desvínculo
    @return Logical, .T. quando o vínculo foi realizado com sucesso
    @see COMXCOL
    @obs As variáveis Private lMsErroAuto e lAutoErrNoFile são obrigatórias para o controle de erro do COMXCOL em modo automático.
*/
//------------------------------------------------------------------------------
Static Function processOrderLink(jValue As Json)
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

	JDocument  := jValue:GetJsonObject("document")
	aOrders    := jValue:GetJsonObject("orders")

	cBranch   := PadR(JDocument:GetJsonText("branch")        , TamSx3("F1_FILIAL")[1])
	cDocument := PadR(JDocument:GetJsonText("documentNumber"), TamSx3("F1_DOC")[1])
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

		aAdd(aLinha, {"TYPE"          ,nType    ,Nil}) // 1= Item 2= Doc 3= Desvinculo
		aAdd(aLinha, {"PEDIDO"        ,cPedido  ,Nil})

		If nType == LINK_BY_ITEM .Or. nType == UNLINK_ITEM // Por item / Desvinculo
			aAdd(aLinha, {"ITEM"      ,cItem    ,Nil})
			aAdd(aLinha, {"ITEMPED"   ,cItemPed ,Nil})
		EndIf

		If nType == LINK_BY_DOC // Por documento
			aAdd(aLinha, {"ITEM"      ,""       ,Nil})
			aAdd(aLinha, {"ITEMPED"   ,""       ,Nil})
		EndIf

		aAdd(aVincPC, aLinha)

	Next

	IIF(IsBlind(), .T., COMXCOL(aCabec,aItens,4,,aVincPC, aPCVinc, .T.))

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
    @since 08/12/2025
    @param aDocuments, Array  , Array de objetos Json com os documentos a serem processados
    @param nAction   , Numeric, Ação a ser realizada (1=Gerar Nota, 2=Excluir Nota)
    @return Logical, .T. quando a operação é concluída
    @see COMCOLGER, COMCOLEXC
    @obs As variáveis Private aRotina, cMarca, cCadastro, aRegMark, lToma4NFOri, cFilQry, lRevA1A2, acolsDkm,
         ALTERA, INCLUI, EXCLUI, VISUALIZA, lMsErroAuto e lMsHelpAuto são obrigatórias para a execução das rotinas COMCOLGER/COMCOLEXC.
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
	Local nTamFilial    := TamSx3("F1_FILIAL")[1] 	As Numeric
	Local nTamDoc       := TamSx3("F1_DOC")[1]    	As Numeric
	Local nTamSerie     := TamSx3("F1_SERIE")[1]  	As Numeric
	Local nTamForn      := TamSx3("F1_FORNECE")[1] 	As Numeric
	Local nTamLoja      := TamSx3("F1_LOJA")[1]   	As Numeric
	
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
		cBranch   := PadR(JDoc:GetJsonText("branch")  , nTamFilial)
		cDocument := PadR(JDoc:GetJsonText("document"), nTamDoc)
		cSerie    := PadR(JDoc:GetJsonText("serie")   , nTamSerie)
		cSupplier := PadR(JDoc:GetJsonText("supplier"), nTamForn)
		cStore    := PadR(JDoc:GetJsonText("store")   , nTamLoja)

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
    @since 02/12/2025
    @param cBranch  , Character, Filial
    @param cDocument, Character, Documento
    @param cSerie   , Character, Serie do documento
    @param cSupplier, Character, Código do fornecedor
    @param cStore   , Character, Loja do fornecedor
    @return Logical, Indica se conseguiu abrir a rotina
*/
//------------------------------------------------------------------------------
Static Function ViewDocum(cBranch As Character, cDocument As Character, cSerie As Character, cSupplier As Character, cStore As Character)
	Local aArea		:= FWGetArea() 			As Array
	Local aAreaSD1	:= SD1->(FWGetArea()) 	As Array
	Local aAreaSF1	:= SF1->(FWGetArea()) 	As Array
	Local lRet      := .F. 					As Logical
	Local cFilBkp   := cFilAnt 				As Character

	cBranch   := PadR(cBranch  , TamSx3("F1_FILIAL")[1])
	cDocument := PadR(cDocument, TamSx3("F1_DOC")[1])
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
    @since 02/12/2025
    @return Nil
    @see COMCOLVIN
    @obs As variáveis Private aRotina, cMarca, cCadastro, aRegMark, lToma4NFOri, cFilQry, lRevA1A2 e acolsDkm
         são obrigatórias para a execução da rotina COMCOLVIN.
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
    @since 02/12/2025
    @param nOpc, Numeric, Opção
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
    @since 27/11/2025
    @param cBranch, Character, Filial
    @param cOrder , Character, Pedido de compra
    @return Logical, Indica se conseguiu abrir a rotina
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

//------------------------------------------------------------------------------
/* {Protheus.doc} CreatePO
    Função que cria pedido(s) de compra automaticamente a partir dos dados dos
    documentos importados (SDS/SDT) utilizando ExecAuto MATA120.

    @type Static Function
    @author Squad PIF
    @since 20/07/2026
    @param aDocs, Array, Array de objetos Json com os documentos no campo "documents"
    @return Json, Objeto com success (Logical) e message (Character) indicando o resultado da criação
    @table SDS, SDT, SA2, SC7
    @see MATA120
    @obs As variáveis Private lMsErroAuto, lMsHelpAuto e lAutoErrNoFile são obrigatórias
          para o controle de erro do MSExecAuto/MATA120.
*/
//------------------------------------------------------------------------------
Static Function CreatePO(aDocs As Array)
    Local lRet        := .T.  As Logical
    Local nX          := 0     As Numeric
    Local JDoc        := Nil   As Json
    Local jResult     := JsonObject():New() As Json
    Local cBranch     := ""   As Character
    Local cDocument   := ""   As Character
    Local cSerie      := ""   As Character
    Local cSupplier   := ""   As Character
    Local cStore      := ""   As Character
    Local aCabec      := {}   As Array
    Local aItens      := {}   As Array
    Local aArea       := FWGetArea() As Array
    Local aAreaSDS    := SDS->(FWGetArea()) As Array
    Local cQuery      := ""   As Character
    Local cAliasSDT   := ""   As Character
    Local oStmt       := Nil   As Object
    Local dEmission   := dDataBase As Date
    Local cCond       := ""   As Character
    Local cContact    := ""   As Character
    Local cFilEnt     := ""   As Character
    Local cPONum      := ""   As Character
    Local cTipoPed    := "1"  As Character
    Local cMessage    := ""   As Character
    Local nTamFilial  := TamSx3("DS_FILIAL")[1] As Numeric
    Local nTamDoc     := TamSx3("DS_DOC")[1]    As Numeric
    Local nTamSerie   := TamSx3("DS_SERIE")[1]  As Numeric
    Local nTamForn    := TamSx3("DS_FORNEC")[1] As Numeric
    Local nTamLoja    := TamSx3("DS_LOJA")[1]   As Numeric
	Local cCondPad	  := SuperGetMV("MV_CONDPAD", .F.) As Character
	Local aP020FLD	  := {} As Array
	Local aLogAuto    := {}   As Array
    
	Private lMsErroAuto    := .F. As Logical
    Private lMsHelpAuto    := .T. As Logical
    Private lAutoErrNoFile := .T. As Logical

    If aDocs != Nil
        For nX := 1 To len(aDocs)
            JDoc := aDocs[nX]

            cBranch   := PadR(JDoc:GetJsonText("branch")  , nTamFilial)
            cDocument := PadR(JDoc:GetJsonText("document") , nTamDoc)
            cSerie    := PadR(JDoc:GetJsonText("serie")    , nTamSerie)
            cSupplier := PadR(JDoc:GetJsonText("supplier"), nTamForn)
            cStore    := PadR(JDoc:GetJsonText("store")   , nTamLoja)

            dbSelectArea("SDS")
            SDS->(DbSetOrder(1))
            If !SDS->(MsSeek(FWxFilial("SDS", cBranch)+cDocument+cSerie+cSupplier+cStore))
                Loop
            EndIf

            dEmission := dDataBase
            cCond     := SDS->DS_COND
            cFilEnt   := SDS->DS_FILIAL

            dbSelectArea("SA2")
            SA2->(DbSetOrder(1))
            If SA2->(MsSeek(FWxFilial("SA2", cBranch)+cSupplier+cStore))
                If Empty(cCond)
                    cCond := SA2->A2_COND
                EndIf
                cContact := SA2->A2_CONTATO
            EndIf

            If Empty(cCond)
               cCond := cCondPad
            EndIf

            dbSelectArea("SC7")
            SC7->(DbSetOrder(1))
            cPONum := GetSXENum("SC7", "C7_NUM")
			While SC7->(DbSeek(FWxFilial("SC7", cBranch) + cPONum))
                ConfirmSX8()
                cPONum := GetSXENum("SC7", "C7_NUM")
            EndDo

            aCabec := {}
            aItens := {}

            aAdd(aCabec, {"C7_NUM"     , cPONum    , Nil})
            aAdd(aCabec, {"C7_FILIAL"  , cBranch   , Nil})
            aAdd(aCabec, {"C7_EMISSAO" , dEmission , Nil})
            aAdd(aCabec, {"C7_FORNECE" , cSupplier , Nil})
            aAdd(aCabec, {"C7_LOJA"    , cStore    , Nil})
            aAdd(aCabec, {"C7_COND"    , cCond     , Nil})
            aAdd(aCabec, {"C7_CONTATO" , cContact  , Nil})
            aAdd(aCabec, {"C7_FILENT"  , cFilEnt   , Nil})
            aAdd(aCabec, {"C7_TIPO"    , cTipoPed  , Nil})

            cQuery := " SELECT SDT.DT_ITEM, SDT.DT_COD, SDT.DT_UM, SDT.DT_QUANT, SDT.DT_VUNIT, SDT.DT_TOTAL, SDT.DT_DESCFOR, SDT.DT_TES, SDT.DT_LOCAL "
            cQuery += " FROM " + RetSqlName("SDT") + " SDT "
            cQuery += " WHERE SDT.DT_FILIAL = ? "
            cQuery += " AND SDT.DT_DOC     = ? "
            cQuery += " AND SDT.DT_SERIE   = ? "
            cQuery += " AND SDT.DT_FORNEC  = ? "
            cQuery += " AND SDT.DT_LOJA    = ? "
            cQuery += " AND SDT.DT_PEDIDO = ' ' "
            cQuery += " AND SDT.D_E_L_E_T_ = ' ' "
            cQuery += " ORDER BY SDT.DT_ITEM "

            cQuery := ChangeQuery(cQuery)

            oStmt := FwExecStatement():New(cQuery)
            oStmt:SetString(1, cBranch)
            oStmt:SetString(2, cDocument)
            oStmt:SetString(3, cSerie)
            oStmt:SetString(4, cSupplier)
            oStmt:SetString(5, cStore)

            cAliasSDT := oStmt:OpenAlias()

            aItens := BuildPOItm(cAliasSDT, dEmission)

            If len(aItens) > 0
                lMsErroAuto := .F.
                lMsHelpAuto := .T.

				//Ponto de Entrada para incluir campos adicionais da SC7 no execauto do pedido de compra
				If __lP020FLD
					aP020FLD := ExecBlock('P020FLD',.F.,.F.,{ aCabec, aItens } )
					If ( ValType(aP020FLD[1]) == "A" )
						aCabec := aClone(aP020FLD[1])
					EndIf
					If ( ValType(aP020FLD[2]) == "A" )
						aItens := aClone(aP020FLD[2])
					EndIf
				EndIf

                lRet := MSExecAuto({|u,v,x,y| MATA120(u,v,x,y)}, 1, aCabec, aItens, 3)
                
                If lRet .And. !lMsErroAuto
					ConfirmSX8()
                    lRet := processOrderLink(BuildLinkJson(cBranch, cDocument, cSerie, cSupplier, cStore, cPONum, aItens))
                Else
					RollBackSx8()
                    lRet := .F.
                    
					aLogAuto := GetAutoGRLog()
                    If len(aLogAuto) > 0
                        cMessage := FormatErrMsg(aLogAuto)
                    EndIf					
                EndIf
            Else
                lRet := .F.
				cMessage := STR0007 //Não existe produto vinculado para o documento. Efetue o vínculo do produto do fornecedor através da opção 'Abrir documento', no campo de produto através do F3 selecione um produto e concretize a amarração.
            EndIf

            (cAliasSDT)->(DbCloseArea())

            FwFreeArray(aCabec)
            FwFreeArray(aItens)
            oStmt:Destroy()
        Next
    EndIf

    FWRestArea(aAreaSDS)
    FWRestArea(aArea)

    jResult["success"] := lRet
    
	If !lRet .And. !Empty(cMessage)
        jResult["message"] := cMessage
    EndIf	

Return jResult

//------------------------------------------------------------------------------
/* {Protheus.doc} BuildLinkJson
    Monta o objeto Json no formato esperado pela ProcessOrderLink para realizar
    o vínculo automático do pedido de compra gerado com os itens da SDT. 
	Vínculo por Pedido completo, uma vez que ele é gerado com base na nota, deve atender totalmente.

    @type Static Function
    @author Squad PIF
    @since 22/07/2026
    @param cBranch   , Character, Filial do documento
    @param cDocument , Character, Número do documento
    @param cSerie    , Character, Série do documento
    @param cSupplier , Character, Código do fornecedor
    @param cStore    , Character, Loja do fornecedor
    @param cPONum    , Character, Número do pedido de compra gerado
    @param aItens    , Array    , Array de itens enviado ao ExecAuto MATA120
    @return jValue   , Json     , Objeto Json com documento e orders para vínculo
    @see CreatePO, ProcessOrderLink
*/
//------------------------------------------------------------------------------
Static Function BuildLinkJson(cBranch As Character, cDocument As Character, cSerie As Character, cSupplier As Character, cStore As Character, cPONum As Character, aItens As Array)
    Local jValue    := JsonObject():New() As Json
    Local JDocument := JsonObject():New() As Json
    Local aOrders   := {}                 As Array
    Local JOrder    := Nil                As Json

    JDocument["branch"]         := AllTrim(cBranch)
    JDocument["documentNumber"] := AllTrim(cDocument)
    JDocument["serie"]          := AllTrim(cSerie)
    JDocument["supplierCode"]   := AllTrim(cSupplier)
    JDocument["supplierStore"]  := AllTrim(cStore)

    JOrder := JsonObject():New()
    JOrder["type"]         := LINK_BY_DOC
    JOrder["order"]        := AllTrim(cPONum)
    JOrder["supplierCode"] := AllTrim(cSupplier)
    JOrder["supplierStore"] := AllTrim(cStore)
    aAdd(aOrders, JOrder)

    jValue["document"] := JDocument
    jValue["orders"]   := aOrders

Return jValue

//------------------------------------------------------------------------------
/* {Protheus.doc} BuildPOItm
    Monta o array de itens do pedido de compra a partir do alias aberto
    sobre a tabela SDT.

    @type Static Function
    @author Squad PIF
    @since 20/07/2026
    @param cAliasSDT, Character, Alias da query aberta sobre a SDT
    @param dEmission, Date     , Data de emissão do documento para C7_DATPRF
    @return Array, Array com os itens formatados para o ExecAuto MATA120
    @table SDT, SB1
    @see CreatePO
*/
//------------------------------------------------------------------------------
Static Function BuildPOItm(cAliasSDT As Character, dEmission As Date)
    Local aItens   	:= {} As Array
    Local aItem    	:= {} As Array
    Local cItem    	:= "" As Character
    Local cProduct 	:= "" As Character
    Local cUM      	:= "" As Character
    Local nQuant   	:= 0  As Numeric
    Local nPrice   	:= 0  As Numeric
    Local nTotal   	:= 0  As Numeric
    Local cDesc    	:= "" As Character
    Local cTES     	:= "" As Character
    Local cLocal   	:= "" As Character
    Local aAreaSB1 	:= SB1->(FWGetArea()) As Array
    Local nTamItem 	:= TamSx3("C7_ITEM")[1] As Numeric

    (cAliasSDT)->(DbGoTop())
    While !(cAliasSDT)->(Eof())
        aItem := {}
        cItem    := PadL(AllTrim((cAliasSDT)->DT_ITEM), nTamItem)
        cProduct := (cAliasSDT)->DT_COD
        cUM      := (cAliasSDT)->DT_UM
        nQuant   := (cAliasSDT)->DT_QUANT
        nPrice   := (cAliasSDT)->DT_VUNIT
        nTotal   := (cAliasSDT)->DT_TOTAL
        cDesc    := (cAliasSDT)->DT_DESCFOR
        cTES     := (cAliasSDT)->DT_TES
        cLocal   := (cAliasSDT)->DT_LOCAL

        If Empty(cLocal)
            dbSelectArea("SB1")
            SB1->(DbSetOrder(1))
            If SB1->(MsSeek(FWxFilial("SB1") + cProduct))
                cLocal := SB1->B1_LOCPAD
            EndIf
        EndIf

        aAdd(aItem, {"C7_ITEM"    , cItem     , Nil})
        aAdd(aItem, {"C7_PRODUTO" , cProduct  , Nil})
        aAdd(aItem, {"C7_UM"      , cUM       , Nil})
        aAdd(aItem, {"C7_QUANT"   , nQuant    , Nil})
        aAdd(aItem, {"C7_PRECO"   , nPrice    , Nil})
        aAdd(aItem, {"C7_TOTAL"   , nTotal    , Nil})
        aAdd(aItem, {"C7_DATPRF"  , dEmission , Nil})
        aAdd(aItem, {"C7_LOCAL"   , cLocal    , Nil})
        aAdd(aItem, {"C7_DESCRI"  , cDesc     , Nil})
        aAdd(aItem, {"C7_TES"     , cTES      , Nil})
        aAdd(aItem, {"C7_CONAPRO" , "L"       , Nil})
        aAdd(aItem, {"C7_QTDLIB"  , nQuant    , Nil})
        aAdd(aItem, {"C7_QTDENT"  , 0         , Nil})
		
        aAdd(aItens, aItem)

        (cAliasSDT)->(DbSkip())
    EndDo

    FWRestArea(aAreaSB1)

Return aItens

//------------------------------------------------------------------------------
/* {Protheus.doc} FormatErrMsg
    Formata as mensagens de erro retornadas pelo GetAutoGRLog do ExecAuto,
    removendo apenas tags HTML e mantendo o conteudo completo do erro.

    @type Static Function
    @author Squad PIF
    @since 07/08/2026
    @param aLogAuto, Array, Array retornado pela funcao GetAutoGRLog
    @return Character, String com as mensagens de erro formatadas
    @see GetAutoGRLog, CreatePO
*/
//------------------------------------------------------------------------------
Static Function FormatErrMsg(aLogAuto As Array)
    Local cMessage := "" As Character
    Local nX       := 0  As Numeric
    Local cLine    := "" As Character
    
    For nX := 1 To len(aLogAuto)
        cLine := AllTrim(aLogAuto[nX])
        
        cLine := StrTran(cLine, "<b>", "")
        cLine := StrTran(cLine, "</b>", "")
        cLine := StrTran(cLine, "<br>", "")
        cLine := StrTran(cLine, "</br>", "")
        cLine := StrTran(cLine, "&nbsp;", " ")
        
        If nX > 1
            cMessage += CRLF
        EndIf
        cMessage += cLine
    Next
    
Return cMessage
