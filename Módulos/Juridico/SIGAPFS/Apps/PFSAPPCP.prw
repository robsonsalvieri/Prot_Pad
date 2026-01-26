#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "PFSAPPCP.CH"
#INCLUDE "FILEIO.CH"
 
#DEFINE SW_SHOW	5	 // Mostra na posição mais recente da janela

//-------------------------------------------------------------------
/*/{Protheus.doc} PFSAPPCP
App do contas a pagar

@author Willian Yoshiaki Kazahaya
@since 02/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSAPPCP()
	// 1º Param: Nome da Aplicação
	// 6º Param: Nome do fonte caso seja diferente do App
	FWCallApp("PFSAPPCP")
Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} PFSAPPCDSD
App da Revisão de Desdobramentos

@author Willian Yoshiaki Kazahaya
@since 02/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSAPPCDSD()
	// 1º Param: Nome da Aplicação
	// 6º Param: Nome do fonte caso seja diferente do App
	FWCallApp("PFSAPPCP")

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} PFSAPPCROT
App do Cadastro de Rotinas Customizadas

@author Willian Yoshiaki Kazahaya
@since 10/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSAPPCROT()
	// 1º Param: Nome da Aplicação
	// 6º Param: Nome do fonte caso seja diferente do App
	FWCallApp("PFSAPPCP")
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} PFSAPPALTL
App da alteração em lote

@author Willian Yoshiaki Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSAPPALTL()
	// 1º Param: Nome da Aplicação
	// 6º Param: Nome do fonte caso seja diferente do App
	FWCallApp("PFSAPPCP")
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} PFSAPPCP
App do Cadastro de Cliente

@author Willian Yoshiaki Kazahaya
@since 02/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSAPPCLI()
	// 1º Param: Nome da Aplicação
	// 6º Param: Nome do fonte caso seja diferente do App
	FWCallApp("PFSAPPCP")
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} PFSAPPCP
App do Cadastro do Caso

@author Willian Yoshiaki Kazahaya
@since 02/09/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function PFSAPPCAS()
	// 1º Param: Nome da Aplicação
	// 6º Param: Nome do fonte caso seja diferente do App
	FWCallApp("PFSAPPCP")
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl(oWebChannel, cType, cContent)
Função que pode ser chamada do PO-UI quando dentro do Protheus

@param oWebChannel - TWebEngine utilizado para renderizar o PO-UI
@param cType - Parâmetro de tipo
@param cContent - Conteudo passado pelo PO-UI

@author Willian Yoshiaki Kazahaya
@since 07/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JsToAdvpl(oWebChannel, cType, cContent)
Local cContext     := ""

	If FWIsInCallStack("PFSAPPCP")
		cContext := "ContaPagar"
	ElseIf FWIsInCallStack("PFSAPPCDSD")
		cContext := "ConsultaDesdobramento"
	ElseIf FWIsInCallStack("PFSAPPCROT")
		cContext := "RotinasCustomizadas"
	ElseIf FWIsInCallStack("PFSAPPALTL")
		cContext := "AlteracaoLote"
	ElseIf FWIsInCallStack("PFSAPPCLI")
		cContext := "Cliente"
	ElseIf FWIsInCallStack("PFSAPPCAS")
		cContext := "Caso"
	EndIf

	Do Case
		Case cType == "preLoad"
			sendFilEmp(oWebChannel, cContext)
		Case cType == "a"
			JURA010()
		Case cType == "anexo"
			Processa({ || CriaAnx(cContent, .F. )}, STR0002, STR0004, .F.) //"Gerando planilha" "Aguarde..."
		Case cType == "exportar"
			Processa({ || CriaAnx(cContent, .T. )}, STR0003, STR0004, .F.) //"Gerando impressão" "Aguarde..."
		Case cType == "abrirAnexo"
			Processa({ || OpenAnx(cContent) }, STR0012, STR0004) //"Abrindo os arquivos selecionados"
		Case cType == "download"
			Processa({ || DLAnexos(cContent) }, STR0013, STR0004) //"Baixando os arquivos selecionados"
		Case cType == "qrCode"
			leitorQrCode()
		Case cType == "setFilial"
			setFilial(cContent)
		Case cType == "abrirPasta"
			GerArqCnab(cContent)
		Case cType == "appCliente"
			FWLsPutAsyncInfo("LS006",RetCodUsr(),"77","APPCLIENTE") // Acessando rotina de Clientes
		Case cType == "openImanage"
			openImng(cContent)
	EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} openImng(cContent)
Abre a tela de anexos para o IManage

@param cContent - Filial Logada

@author Willian Yoshiaki Kazahaya
@since 20/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function openImng(cContent)
Local oJsonObj  := JsonObject():New()
Local cEntidade := ""
Local cFilEnt   := ""
Local cEntId    := ""
Local nIndex    := 1
	
	oJsonObj:fromJson(cContent)
	
	cEntidade := oJsonObj['entidade']
	cFilEnt   := Decode64(oJsonObj['filial'])
	cEntId    := oJsonObj['chave']
	nIndex    := oJsonObj['index']

	oAnexo   := TJurAnxImng():New("", cEntidade, cFilEnt, cEntId, nIndex, .T.) // "IManage (Worksite)"
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} setFilial(cContent)
Seta a Filial logada 

@param cContent - Filial Logada

@author Willian Yoshiaki Kazahaya
@since 20/08/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function setFilial(cContent)
	cFilAnt := cContent
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaAnx(cContent, lTemp)
Cria o arquivo excel utilizando as funções do Protheus

@param cContent - Conteudo do arquivo em formato blob
@param lTemp - Flag de arquivo temporário ou não

@author Willian Yoshiaki Kazahaya
@since 07/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaAnx(cContent, lTemp)
Local oReqJSon   := Nil
Local aArqData   := {}
Local nI         := 0
Local nRet       := 0
Local cCamArq    := ""
Local cExcel     := ""
Local lCriaPast  := .F.
Local lWebAppJob := GetRemoteType() < 0 .Or. GetRemoteType() == 5 // Quando for executado por "StartJob" o valor é -1,  Quando for executado via WebApp é 5.

Default lTemp     := .F.

	IncProc()

	// Verifica se a criação será em diretório temporário ou não
	If lTemp
		cCamArq   := IIf(lWebAppJob, "\spool\", GetTempPath())
		lCriaPast := JurMkDir(cCamArq,.F.,.F.)
		cCamArq   += "tmprel" + GetMark()
	Else
		cCamArq     := cGetFile(STR0005 + "|*.*", STR0006, , "C:\", .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), ,.F.) //"Todos os arquivos" "Selecionar caminho"
	EndIf

	// Verifica se há caminho para o arquivo ser criado
	If (!Empty(cCamArq))
		If At(".xls",cCamArq) == 0
			cCamArq += ".xlsx"
		Endif

		FWJsonDeserialize(cContent,@oReqJSon)
		aArqData := oReqJSon:data

		nHDestino := FCREATE(cCamArq)

		If (nHDestino == -1 )
			JurMsgErro(STR0008)
		Else 
			For nI := 1 To Len(aArqData)
				cExcel += Chr(aArqData[nI])
			Next nI

			nBytesSalvo := FWRITE(nHDestino, cExcel)

			FCLOSE(nHDestino)

			If lWebAppJob
				If CpyS2TW(cCamArq, .T.) < 0 // Efetua download do arquivo
					JurMsgErro( I18n(STR0018, {cCamArq}) ) // "Erro ao efetuar o download do arquivo: #1"
				EndIf
			Else 
				if lTemp
					nRet := ShellExecute( 'open', cCamArq , '', "C:\", 1 )
				EndIf
			EndIf

			ApMsgInfo(STR0007) //"O documento foi gerado com sucesso!"
		EndIf
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} sendFilEmp(oWebChannel, cContext)
Envia os dados de pré-carregamento para o Angular

@Param oWebChannel - Classe para fazer a comunicação com o Angular
@Param cContext    - Identificador de qual tela será apresentada

@author Willian.Kazahaya
@since 04/08/2020
/*/ 
//-------------------------------------------------------------------
Static Function sendFilEmp(oWebChannel, cContext)
Local cJsonCompany := ""
Local aJson        := {}
Local aFiliais     := FWLoadSM0()
Local nI           := 0
Local nPos         := 0
Local oJSonResp    := Nil

	oJSonResp := JsonObject():New()

	For nI := 1 To Len(aFiliais)
		If aFiliais[nI][11] .And. aFiliais[nI][1] == cEmpAnt // Retorna as filiais que o usuário tem acesso da empresa logada.
			Aadd(aJson,JsonObject():new())
			nPos := Len(aJson)
			aJson[nPos]['empresa' ]   := aFiliais[nI][1]
			aJson[nPos]['filial' ]    := aFiliais[nI][2]
			aJson[nPos]['descricao' ] := aFiliais[nI][7]
		EndIf
	Next nI

	oJSonResp:Set(aJson)
	cJsonCompany := '{ "company_code" : "' + FWGrpCompany() + '", "branch_code":"' + FWCodFil() + '"}'
	oWebChannel:AdvPLToJS( "setCompany"   , cJsonCompany  )
	oWebChannel:AdvPLToJS( "setListFilUsu", Encode64(oJSonResp:toJSon()))
	oWebChannel:AdvPLToJS( "setDateDatabase", DTOS(dDatabase))
	oWebChannel:AdvPLToJS( "setContext", cContext )
	oWebChannel:AdvPLToJS( "setRemoteType", AllTrim(cValToChar(GetRemoteType())) )

	JurFreeArr(aFiliais)
	JurFreeArr(aJson)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} OpenAnx(cContent)
Abrir os anexos

@author Willian.Kazahaya
@since 13/01/2021
/*/
//-------------------------------------------------------------------
Static Function OpenAnx(cContent)
Local oAnexo      := Nil
Local cFolderDL   := ""
Local cArquivo    := ""
Local cNomePst    := StrTran(time(), ':', '') //Retirando ":" da hora (Ex: 10:50:55)
Local aAnexos     := JStrArrDst(cContent,",")
Local aArquivos   := {}
Local nI          := 0
Local lRet        := .T.

	cFolderDL := GetTempPath() + cNomePst

	If (!Empty(cFolderDL))
		If (!ExistDir(cFolderDL))
			If MakeDir(cFolderDL) <> 0
				JurMsgErro(STR0011)
				lRet := .F.
			Endif
		EndIf

		If (lRet)
			oAnexo   := JPFSGetAnx()
			For nI := 1 To Len(aAnexos)
				aAdd(aArquivos, aClone(gtAnxo(aAnexos[nI])))
			Next nI
			
			lRet := oAnexo:Exportar("",cFolderDL,,, aArquivos)

			If (lRet)
				For nI := 1 To Len(aArquivos)
					cArquivo := cFolderDL + AllTrim(aArquivos[nI][4]) + AllTrim(aArquivos[nI][5])
					ShellExecute("open", cArquivo, "", "", SW_SHOW)
				Next nI
			EndIf
		EndIf
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DLAnexos(cContent)
Download dos anexos quando o PagPFS for por dentro do Protheus

@author Willian.Kazahaya
@since 13/01/2021
/*/
//-------------------------------------------------------------------
Static Function DLAnexos(cContent)
Local oAnexo      := Nil
Local cFolderDL   := ""
Local cNomArq     := ""
Local cMsgErro    := ""
Local aAnexos     := JStrArrDst(cContent,",")
Local aArquivos   := {}
Local nI          := 0
Local lRet        := .T.
Local lWebApp     := GetRemoteType() == 5

	If lWebApp
		For nI := 1 To Len(aAnexos)
			cNomArq := "\SPOOL\" + AllTrim(gtAnxo(aAnexos[nI])[6])
			If CpyS2TW(cNomArq) < 0
				If Empty(cMsgErro)
					cMsgErro := STR0020 + CRLF // "Não foi possível realizar o download do(s) seguinte(s) arquivo(s): "
				EndIf
				cMsgErro += AllTrim(gtAnxo(aAnexos[nI])[6]) + CRLF
			EndIf
		Next
		IIF(!Empty(cMsgErro), JurMsgErro(cMsgErro,, STR0021), Nil) // "Tente novamente."
	Else
	
		cFolderDL := cGetFile(STR0005 + "|*.*", STR0006, , "C:\", .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_RETDIRECTORY), ,.F.) //"Todos os arquivos" "Selecionar caminho"

		If (!Empty(cFolderDL))
			If (!ExistDir(cFolderDL))
				If MakeDir(cFolderDL) <> 0
					JurMsgErro(STR0011) // "Erro ao criar a pasta!"
					lRet := .F.
				Endif
			EndIf

			If (lRet)
				oAnexo   := JPFSGetAnx()
				For nI := 1 To Len(aAnexos)
					aAdd(aArquivos, aClone(gtAnxo(aAnexos[nI])))
				Next nI
				oAnexo:Exportar("",cFolderDL,,cNomArq, aArquivos)
			EndIf
		EndIf
	EndIf
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} gtAnxo(cNumAnexo)
Monta do Array do anexo

@author Willian.Kazahaya
@since 13/01/2021
/*/
//-------------------------------------------------------------------
Static Function gtAnxo(cNumAnexo)
Local aRet    := {}
Local nI      := 0
Local aFields := {"NUM_FILIAL","NUM_COD","NUM_NUMERO","NUM_DOC","NUM_EXTEN", "NUM_DESC"}
Local cQrySel := ""
Local cQryFrm := ""
Local cQryWhr := ""
Local cAlias  := ""

	cQrySel := " SELECT "

	For nI := 1 to Len(aFields)
		cQrySel += aFields[nI] + ","
	Next

	cQrySel := Substring(cQrySel,1, Len(cQrySel)-1)
	cQryFrm :=  " FROM " + RetSqlName("NUM")
	cQryWhr := " WHERE NUM_COD = '" + cNumAnexo + "'"
	cQryWhr +=   " AND D_E_L_E_T_ = ' '"

	cQuery := cQrySel + cQryFrm + cQryWhr
	cAlias := GetNextAlias()

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While !(cAlias)->(Eof())
		For nI := 1 to Len(aFields)
			aAdd(aRet, (cAlias)->(&(aFields[nI])))
		Next

		(cAlias)->(DbSkip())
	End
	(cAlias)->( dbCloseArea() )
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} leitorQrCode()
Chama o leitor de código de barras

@author Willian.Kazahaya
@since 05/02/2021
/*/
//-------------------------------------------------------------------
Static Function leitorQrCode()
Local cDir As Character
Local lWebAppJob As Logical

	lWebAppJob := GetRemoteType() < 0 .Or. GetRemoteType() == 5 // Quando for executado por "StartJob" o valor é -1,  Quando for executado via WebApp é 5.

	If lWebAppJob
		MsgInfo(STR0019)// "Funcionalidade disponível somente para SmartClient DeskTop!"
	Else
		cDir := iif(GetOS()=="UNIX", Subs(getClientDir(),3), getClientDir()) 

		If GetOS() =="WINDOWS"
			If WaitRun(cDir + "barcode_scan.exe", 1 ) != 0
				MsgInfo(STR0009)// "Verifique se o executavel barcode_scan existe na pasta do smartclient"
				Return
			Endif
			MsgInfo(STR0010)//De um Ctrl+V no campo QR CODE
		Else
			If WaitRun(cDir + "barcode_scan", 1 ) != 0
				MsgInfo(STR0009)// "Verifique se o executavel barcode_scan existe na pasta do smartclient"
				Return
			Endif
			MsgInfo(STR0010)//De um Ctrl+V no campo QR CODE
		Endif
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetOS()
Verifica qual o sistema operacional

@author Willian.Kazahaya
@since 05/02/2021
/*/
//-------------------------------------------------------------------
Static Function GetOS() As Character
    Local cStringOS As Character
    Local cRet      As Character

    cStringOS := Upper(GetRmtInfo()[2])
    cRet      := ""

    If GetRemoteType() == 0 .or. GetRemoteType() == 1
        cRet := "WINDOWS"
    ElseIf GetRemoteType() == 2 
        cRet := "UNIX" // Linux ou MacOS		
    ElseIf GetRemoteType() == 5 
        cRet := "HTML" // Smartclient HTML		
    ElseIf ("ANDROID" $ stringOS)
        cRet := "ANDROID" 
    ElseIf ("IPHONEOS" $ stringOS)
        cRet := "IPHONEOS"
    EndIf
return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GerArqCnab(cContent)
Gera o arquivo CNAB para o usuário

@author Willian.Kazahaya
@since 10/10/2022
/*/
//-------------------------------------------------------------------
Static Function GerArqCnab(cContent)
Local cPath      := ""
Local aContent   := {}
Local lWebAppJob := GetRemoteType() < 0 .Or. GetRemoteType() == 5 // Quando for executado por "StartJob" o valor é -1,  Quando for executado via WebApp é 5.

	If VALTYPE(DECODEUTF8(cContent)) <> "U"
		cContent := DECODEUTF8( cContent )
	EndIf

	aContent := STRTOKARR( cContent, "," ) // 1= extensão, 2=título, 3=nome

	If lWebAppJob
		If CpyS2TW(aContent[2], .T.) < 0 // Efetua download do arquivo
			JurMsgErro( I18n(STR0018, {aContent[2]}) ) // "Erro ao efetuar o download do arquivo: #1"
		EndIf
	Else
		cPath := tFileDialog(;
		aContent[1],;      // Filtragem de tipos de arquivos que serão selecionados
		STR0017,;          // "Selecione o diretório para salvar o arquivo CNAB"
		,;                 // Compatibilidade
		aContent[2],;      // Diretório inicial da busca de arquivos
		.F.,;              // Se for .T., será uma Save Dialog, senão será Open Dialog
		GETF_RETDIRECTORY; // GETF_RETDIRECTORY será possível selecionar o diretório
		)

		If (!Empty(cPath))
			If CpyS2T( aContent[2], cPath )

				ShellExecute("open",  cPath , "", "", SW_SHOW)
			Else
				JurMsgErro(STR0014,, STR0015 + CRLF + aContent[2] + "") // "Não foi possivel salvar o arquivo na pasta indicada" //"O arquivo gerado encontra-se na pasta abaixo no servidor. "
			EndIf
		Else
			JurMsgErro(STR0016,,STR0015 + CRLF + aContent[2] + "") //"A transferência do arquivo CNAB para a pasta de destino foi cancelada." //" O arquivo gerado encontra-se na pasta abaixo no servidor. "
		EndIf

	EndIf

Return 
