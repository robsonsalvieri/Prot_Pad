#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "QIEA217EVDEF.CH"
#INCLUDE "TOTVS.CH"

#DEFINE _LLA 9  //Laudo do laboratorio
#DEFINE _LOP 10 //Laudo da Operacao

/*/{Protheus.doc} QIEA217EVDEF
Eventos padrões do cadastro de Anexos de Amostras
@author brunno.costa
@since 17/12/2024
@version P12
/*/
CLASS QIEA217EVDEF FROM FWModelEvent

	DATA cChaveAtual as STRING
	DATA cQPath      as STRING
	DATA cQPathTrm   as STRING
	DATA lAtualDB    as LOGICAL
	DATA oExclusao   as OBJECT
	DATA oInclusao   as OBJECT
	DATA oModel      as OBJECT

	//Métodos MVC
	METHOD New() CONSTRUCTOR
	
	//Métodos Auxiliares - Regras de Negócio
	METHOD abrirAnexo()
	METHOD carregaItensDaGrid(oModel)
	METHOD excluirAnexoMemoria()
	METHOD incluirAnexoMemoria()
	METHOD permiteManutenirAnexos()
	METHOD persisteAnexosAmostra(cChaveQER)
	METHOD persisteExclusaoAnexos()
	METHOD persisteInclusaoAnexos(cChaveQER)
	METHOD retornaMimeType(cExtensao)
	METHOD retornaTamanhoDoArquivo(cArquivo, cPath)
	METHOD temLaudoGeral()
	METHOD temLaudoLaboratorio()
	METHOD temLaudoOperacao()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe
@author brunno.costa
@since 17/12/2024
@version P12
@return Nil
/*/
METHOD New() CLASS QIEA217EVDEF
	Self:cQPathTrm  := AllTrim(QDOPATH()[3])
	Self:cQPath     := QEPXFUNAuxClass():resolveMVDiretorioServidor("MV_QLDINSP", "system\anexos_inspecao\")
Return

/*/{Protheus.doc} excluirAnexoMemoria
Realiza Exclusão de Anexo de Amostra (em memória)
@author rafael.hesse, brunno.costa
@since 23/05/2023
@version P12
@return Nil
/*/
METHOD excluirAnexoMemoria() CLASS QIEA217EVDEF

	Local cUID         := Nil
	Local nPosicaoItem := 0
	Local nRecnoQQM    := Nil
	Local oGridModel   := Nil
	Local oModel       := NIL
	Local oSelf        := Nil
	Local oView        := FWViewActive()

	If Self:permiteManutenirAnexos()
		oModel           := oView:GetModel()
		oGridModel       := oModel:GetModel("QQM_DETAIL")
		oSelf            := gtMdlEvent(oModel, "QIEA217EVDEF")
		Self             := oSelf
		nRecnoQQM        := oGridModel:GetValue("NREG")

		If Empty(oGridModel:GetValue("QQM_MSUID"))

			MsgInfo(STR0009) //STR0009 - "Nenhum anexo selecionado para exclusão."

		Else

			//Registro do Banco - Anexo Pré-Existente
			If nRecnoQQM > 0
				Self:cChaveAtual := oGridModel:GetValue("QQM_FILQPR") + oGridModel:GetValue("QQM_CHAVE")
				If Self:oExclusao[Self:cChaveAtual] == Nil
					Self:oExclusao[Self:cChaveAtual] := JsonObject():New()
				EndIf
				Self:oExclusao[Self:cChaveAtual, Str(nRecnoQQM)] := .T.

			//Registro em Memória - Anexo incluído na operação
			Else
			
				Self:cChaveAtual := oGridModel:GetValue("QQM_CHAVE")

				If Self:oInclusao[Self:cChaveAtual] != NIL
					cUID             := oGridModel:GetValue("QQM_MSUID")
					nPosicaoItem     := aScan(Self:oInclusao[Self:cChaveAtual], {|oAnexo| oAnexo["QQM_MSUID"] == cUID })
					If nPosicaoItem > 0
						Self:oInclusao[Self:cChaveAtual][nPosicaoItem]["deleted"] := .T.
					EndIf
				EndIf
			EndIf

			oGridModel:ClearData(.F., .F.)
			oGridModel:DeActivate()
			oGridModel:lForceLoad := .T.
			oGridModel:bLoad      := {|| Self:carregaItensDaGrid(oModel) }
			oGridModel:Activate()

			If oView:isActive()
				oView:Refresh("V_QQM_DETAIL")
			EndIf

		EndIf
		
	EndIf
	
Return

/*/{Protheus.doc} abrirAnexo
Método para abertura do arquivo anexo posicionado na GRID MVC
@author brunno.costa
@since 17/12/2024
@version P12
@return Nil
/*/
METHOD abrirAnexo() CLASS QIEA217EVDEF

	Local nOpc       := 1
	Local oGridModel := Nil
	Local oModel     := Nil
	Local oView      := FWViewActive()

	oModel     := oView:GetModel()
	oGridModel := oModel:GetModel("QQM_DETAIL")

	If Empty(oGridModel:GetValue("QQM_MSUID"))
		MsgInfo(STR0008) //STR0008 - "Nenhum anexo selecionado para visualização."
	Else
		QEPXFUNAuxClass():visualizaAnexoComFallback(oGridModel:GetValue("QQM_MSUID"),;
													oGridModel:GetValue("QQM_NOMEOR"),;
													Self:cQPath,;
													Self:cQPathTrm,;
													nOpc,;
													"QQM")
	EndIf

Return 

/*/{Protheus.doc} incluirAnexoMemoria
Método para inclusão de anexo
@author brunno.costa
@since 17/12/2024
@version P12
@return Nil
/*/

METHOD incluirAnexoMemoria() CLASS QIEA217EVDEF

	Local aFields    := Nil
	Local aLoad      := {}
	Local cNomeReal  := ""
    Local cArqAnexo  := ""
	Local cRetorno   := ""
	Local cUID       := ""
	Local nOpc       := 1
	Local oAnexo     := JsonObject():New()
	Local oGridModel := Nil
	Local oModel     := Nil
	Local oSelf      := Nil
	Local oView      := FWViewActive()

	If Self:permiteManutenirAnexos()
		oModel           := oView:GetModel()
		aFields          := oModel:GetModel("QQM_DETAIL"):oFormModelStruct:aFields
		oGridModel       := oModel:GetModel("QQM_DETAIL")
		oSelf            := gtMdlEvent(oModel, "QIEA217EVDEF")
		cUID             := FWUUIDV4( AllTrim(Upper(TcgetDB())) != "ORACLE")
        cArqAnexo        := QEPXFUNAuxClass():nomeFisicoAnexo(cUID, "")
		Self             := oSelf

		//STR0001 - "Aguarde..."
		//STR0002 - "Copiando Anexo"
		MsgRun(STR0001, STR0002, {|| cRetorno := QVRFANEXO(nOpc, @cNomeReal, "QQM", Self:cQPath, cArqAnexo, 35000) })

		If !Empty(cRetorno)

			If (Self:oInclusao[Self:cChaveAtual] == Nil)
				Self:oInclusao[Self:cChaveAtual] := {}
			EndIf

			oAnexo   := JsonObject():New()
			oAnexo["QQM_MSUID"]  := cUID
			oAnexo["QQM_NOMEOR"] := cNomeReal
			oAnexo["deleted"]    := .F.
			aAdd(Self:oInclusao[Self:cChaveAtual], oAnexo)

			oGridModel:ClearData(.F., .F.)
			oGridModel:DeActivate()
			oGridModel:lForceLoad := .T.

			aLoad            := Self:carregaItensDaGrid(oModel)
			oGridModel:bLoad := {|| aLoad }
			oGridModel:Activate()

			If oView:isActive()
				oView:Refresh("V_QQM_DETAIL")
			EndIf

		EndIf
	Else
		//STR0003 - "A amostra da inspeção já possui laudo relacionado."
		//STR0004 - "Selecione outra amostra para incluir anexos ou remova o laudo relacionado à amostra."
		Help(NIL, NIL, "QIEA217LAUDO", NIL, STR0003, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0004})
	EndIf
	
Return 

/*/{Protheus.doc} LoadGrid
Retorna array com os dados a serem inseridos na Grid
@author brunno.costa
@since 17/12/2024
@version P12
@param 01 - oModel  , object    , modelo principal
@return aLoad, array, array com os dados para exibição na GRID MVC
/*/
METHOD carregaItensDaGrid(oModel) CLASS QIEA217EVDEF

	Local aAreaQQM  := QQM->(GetArea())
	Local aDefDados := {}
	Local aFields   := oModel:GetModel("QQM_DETAIL"):oFormModelStruct:aFields
	Local aLoad     := {}
	Local aNovoItem := {}
	Local cKeyRec   := ""
	Local lMarcado  := .F.
	Local nIndAne   := 0
	Local nIndCps   := 0
	Local oExcCh    := Nil

	aAdd(aDefDados,0)
	aAdd(aDefDados,{})
	For nIndCps := 1 to Len(aFields)
		aAdd(aDefDados[2],Nil)
	Next nIndCps

	If !Empty(Self:cChaveAtual)
		//Tratamento para registros salvos em banco de dados - INICIO
		QQM->(dbSetOrder(1))
		If Self:lAtualDB .AND. QQM->(dbSeek(xFilial('QQM') + Self:cChaveAtual, .F.))
			While !QQM->(Eof()) .And. ;
			       QQM->QQM_FILIAL == xFilial("QQM") .And. ;
			       QQM->QQM_FILQPR + QQM->QQM_CHAVE  == Self:cChaveAtual

				cKeyRec  := Str(QQM->(Recno()))
				oExcCh   := Self:oExclusao[Self:cChaveAtual]
				lMarcado := .F.
				If oExcCh != Nil .And. aScan(oExcCh:GetNames(), {|c| c == cKeyRec }) > 0
					lMarcado := (oExcCh[cKeyRec] == .T.)
				EndIf
				If !lMarcado

					aNovoItem    := aClone(aDefDados)
					For nIndCps := 1 to Len(aFields)
						If AllTrim(aFields[nIndCps][3]) == "NREG"
							aNovoItem[2, nIndCps] := QQM->(Recno())
						ElseIf !aFields[nIndCps][14] //Verifica se é campo virtual
							aNovoItem[2, nIndCps] := QQM->(&(aFields[nIndCps][3]))
						EndIf
					Next nIndCps
	
					aAdd(aLoad, aClone(aNovoItem))
				EndIf
				QQM->(dbSkip())
			End
		EndIf
		//Tratamento para registros salvos em banco de dados - FIM

		//Tratamento carga de registros em memória - INICIO
		If Self:oInclusao[Self:cChaveAtual] != Nil
			For nIndAne := 1 to Len(Self:oInclusao[Self:cChaveAtual])

				Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_SIZE"] := Iif(Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_SIZE"] == Nil,;				
																		   Self:retornaTamanhoDoArquivo(Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_MSUID"] + ".";
																		                                + aTail(StrTokArr(Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_NOMEOR"], "."))),;
																		   Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_SIZE"])

				If !Self:oInclusao[Self:cChaveAtual][nIndAne]["deleted"]
					aNovoItem   := aClone(aDefDados)
					For nIndCps := 1 to Len(aFields)
						If AllTrim(aFields[nIndCps][3]) == "NREG"
							aNovoItem[2, nIndCps] := 0
						ElseIf AllTrim(aFields[nIndCps][3]) == "QQM_MSUID"
							aNovoItem[2, nIndCps] := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_MSUID"]
						ElseIf AllTrim(aFields[nIndCps][3]) == "QQM_SIZE"
							aNovoItem[2, nIndCps] := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_SIZE"]
						ElseIf AllTrim(aFields[nIndCps][3]) == "QQM_NOMEOR"
							aNovoItem[2, nIndCps] := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_NOMEOR"]
						ElseIf AllTrim(aFields[nIndCps][3]) == "QQM_CHAVE"
							aNovoItem[2, nIndCps] := Self:cChaveAtual
						EndIf
					Next nIndCps
					aAdd(aLoad, aNovoItem)
				EndIf
			Next
		EndIf
		//Tratamento carga de registros em memória - FIM

	EndIf

	If Empty(aLoad)
		aAdd(aLoad, aClone(aDefDados))
	EndIf

	QQM->(RestArea(aAreaQQM))

Return aLoad

/*/{Protheus.doc} persisteAnexosAmostra
Salva Anexos da Amostra
@author brunno.costa
@since 16/05/2023
@version P12
@param 01 - cChaveQER, caracter, QER_CHAVE para relacionamento do registro
/*/
METHOD persisteAnexosAmostra(cChaveQER) CLASS QIEA217EVDEF

	Local aAreaQQM  := QQM->(GetArea())

	Self:persisteInclusaoAnexos(cChaveQER)
	Self:persisteExclusaoAnexos()
	//Limpa marcacoes ja persistidas desta chave para evitar acumulo entre gravacoes
	If !Empty(Self:cChaveAtual)
		If Self:oInclusao != Nil
			Self:oInclusao[Self:cChaveAtual] := {}
		EndIf
		If Self:oExclusao != Nil
			Self:oExclusao[Self:cChaveAtual] := JsonObject():New()
		EndIf
	EndIf
	
	QQM->(RestArea(aAreaQQM))

Return

/*/{Protheus.doc} persisteInclusaoAnexos
Persiste Gravação dos Anexos no Banco e Protheus_Data
@author rafael.hesse / brunno.costa
@since 23/05/2023
@version P12
@param 01 - cChaveQER, caracter, QER_CHAVE para relacionamento do registro
/*/
METHOD persisteInclusaoAnexos(cChaveQER) CLASS QIEA217EVDEF

	Local aAreaQQM  := QQM->(GetArea())
	Local cArqAnexo := ""
	Local cExtensao := ""
	Local cFiLQER   := xFilial("QER")
	Local cFiLQQM   := xFilial("QQM")
	Local cHelpId   := "QEPNAOCOP2"
	Local cProblema := STR0005 //"Falha ao copiar arquivo de anexo para o servidor."
	Local cSolucao  := STR0006 + AllTrim(cValToChar(GetMV("MV_QLDINSP"))) + STR0007 //"Verifique o parametro MV_QLDINSP (atual: '" + "' ). O diretorio deve existir e ter permissao de escrita no servidor."
	Local nIndAne   := 0

	If Self:oInclusao[Self:cChaveAtual] != Nil
		For nIndAne := 1 to Len(Self:oInclusao[Self:cChaveAtual])
			If !Self:oInclusao[Self:cChaveAtual][nIndAne]["deleted"]
				cArqAnexo := QEPXFUNAuxClass():nomeFisicoAnexo(Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_MSUID"], Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_NOMEOR"])
				cExtensao := aTail(StrTokArr(Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_NOMEOR"], "."))

				If QEPXFUNAuxClass():copiaArquivoParaServidor(cArqAnexo, Self:cQPathTrm, Self:cQPath, cHelpId, cProblema, cSolucao)
					RecLock("QQM", .T.)
					QQM->QQM_FILIAL := cFiLQQM
					QQM->QQM_FILQPR := cFiLQER
					QQM->QQM_CHAVE  := cChaveQER
					QQM->QQM_MSUID  := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_MSUID"]
					QQM->QQM_SIZE   := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_SIZE"]
					QQM->QQM_NOMEOR := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_NOMEOR"]
					QQM->QQM_LOCAL  := "2"
					QQM->QQM_STATUP := "2"
					QQM->QQM_MIME   := Self:retornaMimeType(cExtensao)
					If !Empty(GetSx3Cache("QQM_MODULO" ,"X3_TAMANHO"))
						QQM->QQM_MODULO := "QIE"
					EndIf
					QQM->(MsUnlock())
				EndIf
			EndIf
		Next
	EndIf
	
	QQM->(RestArea(aAreaQQM))

Return

/*/{Protheus.doc} persisteExclusaoAnexos
Persiste Exclusão dos Anexos no Banco e Protheus_Data
@author rafael.hesse / brunno.costa
@since 23/05/2023
@version P12
/*/
METHOD persisteExclusaoAnexos() CLASS QIEA217EVDEF

	Local aAreaQQM  := QQM->(GetArea())
	Local aRecnos   := Nil
	Local nIndRec   := 0
	Local nRecnoQQM := 0
	Local cArqAnexo := ""
	Local cExtensao := ""
	Local lExcluido := .F.
	Local lMarcado  := Nil

	If Self:oExclusao[Self:cChaveAtual] != Nil
		aRecnos := Self:oExclusao[Self:cChaveAtual]:GetNames()
		For nIndRec := 1 to Len(aRecnos)
			//So exclui registros realmente marcados (.T.); ignora Nil e nao-logicos
			lMarcado := Self:oExclusao[Self:cChaveAtual, aRecnos[nIndRec]]
			If ValType(lMarcado) != "L" .Or. !lMarcado
				Loop
			EndIf
			
			lExcluido := .F.

			//Posiciona registro na QQM
			nRecnoQQM := Val(aRecnos[nIndRec])
			QQM->(DbGoTop())
			QQM->(DbGoTo(nRecnoQQM))
			
			//Verifica nome do arquivo fisico
			cExtensao := aTail(StrTokArr(QQM->QQM_NOMEOR, "."))
			cArqAnexo := QEPXFUNAuxClass():nomeFisicoAnexo(QQM->QQM_MSUID, QQM->QQM_NOMEOR)

			If !File(Self:cQPath + cArqAnexo)
				cArqAnexo := Lower(AllTrim(StrTran(QQM->QQM_MSUID, "-", ""))) + "." + Lower(AllTrim(cExtensao))
			EndIf

			//Apagar arquivo na Protheus_Data
			If File(Self:cQPath + cArqAnexo)
				If FErase(Self:cQPath + cArqAnexo) <> -1
					lExcluido := .T.
				End
			Else
				lExcluido := .T.
			EndIf

			//Apaga registro da QQM
			If lExcluido
				RecLock("QQM", .F.)
				QQM->(DbDelete())
				QQM->(MsUnlock())
			EndIf
		Next
		
	EndIf
	
	QQM->(RestArea(aAreaQQM))

Return

/*/{Protheus.doc} retornaTamanhoDoArquivo
Retorna tamanho do arquivo em KB

@author brunno.costa
@since 16/05/2023
@version P12
@param 01 - cArquivo, caracter, nome do arquivo para checagem
@param 02 - cPath   , caracter, diretório do arquivo
@return nTamanho, número, tamanho do arquivo em KB
/*/
METHOD retornaTamanhoDoArquivo(cArquivo, cPath) CLASS QIEA217EVDEF	
Return QAFILESIZE(cArquivo, cPath)

/*/{Protheus.doc} retornaMimeType
Retorna o Mime Type do arquivo
@author brunno.costa
@since 16/05/2023
@version P12
@param 01 - cExtensao, caracter, extensão do arquivo
@return cMimeType, caracter, mime type do arquivo
/*/
METHOD retornaMimeType(cExtensao) CLASS QIEA217EVDEF	
	Local cMimeType := ""
	cExtensao := Lower(cExtensao)
	cMimeType := Iif(cExtensao == "txt" , "text/plain"                                                               , cMimeType)
    cMimeType := Iif(cExtensao == "jpeg", "image/jpeg"                                                               , cMimeType)
    cMimeType := Iif(cExtensao == "jpg" , "image/jpeg"                                                               , cMimeType)
    cMimeType := Iif(cExtensao == "png" , "image/png"                                                                , cMimeType)
    cMimeType := Iif(cExtensao == "gif" , "image/gif"                                                                , cMimeType)
    cMimeType := Iif(cExtensao == "bmp" , "image/bmp"                                                                , cMimeType)
    cMimeType := Iif(cExtensao == "pdf" , "application/pdf"                                                          , cMimeType)
    cMimeType := Iif(cExtensao == "xls" , "application/excel"                                                        , cMimeType)
    cMimeType := Iif(cExtensao == "doc" , "application/msword"                                                       , cMimeType)
    cMimeType := Iif(cExtensao == "ppt" , "application/mspowerpoint"                                                 , cMimeType)
    cMimeType := Iif(cExtensao == "zip" , "application/x-compressed"                                                 , cMimeType)
    cMimeType := Iif(cExtensao == "wav" , "audio/wav"                                                                , cMimeType)
    cMimeType := Iif(cExtensao == "mp3" , "audio/mpeg3"                                                              , cMimeType)
    cMimeType := Iif(cExtensao == "mp4" , "video/mp4"                                                                , cMimeType)
    cMimeType := Iif(cExtensao == "docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"  , cMimeType)
    cMimeType := Iif(cExtensao == "xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"        , cMimeType)
    cMimeType := Iif(cExtensao == "pptx", "application/vnd.openxmlformats-officedocument.presentationml.presentation", cMimeType)
Return cMimeType

/*/{Protheus.doc} permiteManutenirAnexos
Identifica se permite manutenir anexos da amostra
@author brunno.costa
@since 16/05/2023
@version P12
@return lPermite, lógico, indica se permite manutenir anexos da amostra
/*/
METHOD permiteManutenirAnexos() CLASS QIEA217EVDEF
	Local lPermite := .T.
	lPermite := !(Self:temLaudoLaboratorio() .OR. Self:temLaudoGeral() .OR. !Empty(M->QEL_LAUDO))
Return lPermite

/*/{Protheus.doc} temLaudoLaboratorio
Indica se possui laudo de laboratório
@author brunno.costa
@since 16/05/2023
@version P12
@return lPossui, lógico, indica se possui laudo de laboratorio
/*/
METHOD temLaudoLaboratorio() CLASS QIEA217EVDEF
	Local lPossui := .T.
	Local nPosLau := aScan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_LAUDO"})
	lPossui := !Empty(aResultados[nFldLab,9,nPosLau])
Return lPossui

/*/{Protheus.doc} temLaudoGeral
Indica se possui laudo geral
@author brunno.costa
@since 16/05/2023
@version P12
@return lPossui, lógico, indica se possui laudo geral
/*/
METHOD temLaudoGeral() CLASS QIEA217EVDEF
	Local lPossui    := .T.
	Local nPosLauGer := aScan(aCpoEnc[1],{|x|AllTrim(x)=="QEL_LAUDO"}) //posicao do Laudo do Laboratorio/Geral da Entrada
	lPossui := !Empty(aResultados[nFldLabGer,1,nPosLauGer]) 
Return lPossui

/*/{Protheus.doc} gtMdlEvent
Recupera a referencia do objeto dos Eventos do modelo.
@author brunno.costa
@since 17/12/2024
@version P12
@param 01 - oModel  , Object   , Modelo de dados
@param 02 - cIdEvent, Character, ID do evento que se deseja recuperar.
@return oEvent , Object Referência do evento do modelo de dados.
/*/

Static Function gtMdlEvent(oModel, cIdEvent)
	Local nIndex  := 0
	Local oEvent  := Nil
	Local oMdlPai := Nil

	If oModel != Nil
		oMdlPai := oModel:GetModel()
	EndIf

	If oMdlPai != Nil .And. AttIsMemberOf(oMdlPai, "oEventHandler", .T.) .And. oMdlPai:oEventHandler != NIL
		For nIndex := 1 To Len(oMdlPai:oEventHandler:aEvents)
			If oMdlPai:oEventHandler:aEvents[nIndex]:cIdEvent == cIdEvent
				oEvent := oMdlPai:oEventHandler:aEvents[nIndex]
				Exit
			EndIf
		Next nIndex
	EndIf

Return oEvent
