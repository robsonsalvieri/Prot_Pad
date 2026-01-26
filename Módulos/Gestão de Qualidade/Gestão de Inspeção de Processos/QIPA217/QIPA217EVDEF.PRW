#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "QIPA217EVDEF.CH"
#INCLUDE "TOTVS.CH"

#DEFINE _LLA 9  //Laudo do laboratorio
#DEFINE _LOP 10 //Laudo da Operacao

/*/{Protheus.doc} QIPA217EVDEF
Eventos padrões do cadastro de Anexos de Amostras
@author brunno.costa
@since 15/05/2023
@version P12
/*/
CLASS QIPA217EVDEF FROM FWModelEvent

	DATA cChaveAtual as STRING
	DATA lAtualDB    as LOGICAL
	DATA oInclusao   as OBJECT
	DATA oExclusao   as OBJECT
	DATA oModel      as OBJECT

	//Métodos MVC
	METHOD New() CONSTRUCTOR
	
	//Métodos Auxiliares - Regras de Negócio
	METHOD abrirAnexo()
	METHOD carregaItensDaGrid(oModel)
	METHOD copiaArquivoProServidor(cArquivo)
	METHOD excluirAnexoMemoria()
	METHOD incluirAnexoMemoria()
	METHOD permiteManutenirAnexos()
	METHOD persisteAnexosAmostra(cChaveQPR)
	METHOD persisteExclusaoAnexos()
	METHOD persisteInclusaoAnexos(cChaveQPR)
	METHOD retornaMimeType(cExtensao)
	METHOD retornaTamanhoDoArquivo(cArquivo, cPath)
	METHOD temLaudoGeral()
	METHOD temLaudoLaboratorio()
	METHOD temLaudoOperacao()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe
@author brunno.costa
@since 15/05/2023
@version P12
@return Nil
/*/
METHOD New() CLASS QIPA217EVDEF
Return

/*/{Protheus.doc} excluirAnexoMemoria
Realiza Exclusão de Anexo de Amostra (em memória)
@author rafael.hesse, brunno.costa
@since 23/05/2023
@version P12
@return Nil
/*/
METHOD excluirAnexoMemoria() CLASS QIPA217EVDEF

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
		oSelf            := gtMdlEvent(oModel, "QIPA217EVDEF")
		Self             := oSelf
		nRecnoQQM        := oGridModel:GetValue("NREG")

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

Return

/*/{Protheus.doc} abrirAnexo
Método para abertura do arquivo anexo posicionado na GRID MVC
@author brunno.costa
@since 15/05/2023
@version P12
@return Nil
/*/
METHOD abrirAnexo() CLASS QIPA217EVDEF

	Local cArquivo   := ""
	Local cBanco     := Upper(TcgetDB())
	Local cExtensao  := ""
	Local cPath      := SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\")
	Local cUID       := ""
	Local nOpc       := 1
	Local oGridModel := Nil
	Local oModel     := Nil
	Local oView      := FWViewActive()

	oModel     := oView:GetModel()
	oGridModel := oModel:GetModel("QQM_DETAIL")
	
	If "ORACLE" $ cBanco
		cUID := Lower(AllTrim(TRANSFORM( Alltrim(oGridModel:GetValue("QQM_MSUID")),"@R ########-####-####-####-############")))
	Else
		cUID := oGridModel:GetValue("QQM_MSUID")
	EndIf

	cExtensao  := aTail(StrtoKarr(oGridModel:GetValue("QQM_NOMEOR"),"."))
	cArquivo   := AllTrim(cUID) + "." + cExtensao
	QVRFANEXO(nOpc,cArquivo,"QQM",cPath)

Return 

/*/{Protheus.doc} incluirAnexoMemoria
Método para inclusão de anexo
@author brunno.costa
@since 15/05/2023
@version P12
@return Nil
/*/

METHOD incluirAnexoMemoria() CLASS QIPA217EVDEF

	Local aFields    := Nil
	Local aLoad      := {}
	Local cNomeReal  := ""
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
		oSelf            := gtMdlEvent(oModel, "QIPA217EVDEF")
		cUID             := FWUUIDV4( AllTrim(Upper(TcgetDB())) != "ORACLE")
		Self             := oSelf

		//STR0001 - "Aguarde..."
		//STR0002 - "Copiando Anexo"
		MsgRun(STR0001, STR0002, {|| cRetorno := QVRFANEXO(nOpc, @cNomeReal, "QQM", Alltrim(QDOPATH()[3]), cUID, 35000) })

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
		Help(NIL, NIL, "QIPA217LAUDO", NIL, STR0003, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0004})
	EndIf
	
Return 

/*/{Protheus.doc} LoadGrid
Retorna array com os dados a serem inseridos na Grid
@author brunno.costa
@since 15/05/2023
@version P12
@param 01 - oModel  , object    , modelo principal
@return aLoad, array, array com os dados para exibição na GRID MVC
/*/
METHOD carregaItensDaGrid(oModel) CLASS QIPA217EVDEF

	Local aAreaQQM  := QQM->(GetArea())
	Local aDefDados := {}
	Local aFields   := oModel:GetModel("QQM_DETAIL"):oFormModelStruct:aFields
	Local aLoad     := {}
	Local aNovoItem := {}
	Local nIndAne   := 0
	Local nIndCps   := 0

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

				If Self:oExclusao[Self:cChaveAtual]                           == Nil;
			      .OR.  Self:oExclusao[Self:cChaveAtual, Str(QQM->(Recno()))] == Nil;
			      .OR. !Self:oExclusao[Self:cChaveAtual, Str(QQM->(Recno()))]

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
@param 01 - cChaveQPR, caracter, QPR_CHAVE para relacionamento do registro
/*/
METHOD persisteAnexosAmostra(cChaveQPR) CLASS QIPA217EVDEF

	Local aAreaQQM  := QQM->(GetArea())

	Self:persisteInclusaoAnexos(cChaveQPR)
	Self:persisteExclusaoAnexos()
	
	QQM->(RestArea(aAreaQQM))

Return

/*/{Protheus.doc} persisteInclusaoAnexos
Persiste Gravação dos Anexos no Banco e Protheus_Data
@author rafael.hesse / brunno.costa
@since 23/05/2023
@version P12
@param 01 - cChaveQPR, caracter, QPR_CHAVE para relacionamento do registro
/*/
METHOD persisteInclusaoAnexos(cChaveQPR) CLASS QIPA217EVDEF

	Local aAreaQQM  := QQM->(GetArea())
	Local cArqAnexo := ""
	Local cExtensao := ""
	Local cFiLQPR   := xFilial("QPR")
	Local cFiLQQM   := xFilial("QQM")
	Local cOriginal := ""
	Local nIndAne   := 0
	Local nPos      := 0

	If Self:oInclusao[Self:cChaveAtual] != Nil
		For nIndAne := 1 to Len(Self:oInclusao[Self:cChaveAtual])
			If !Self:oInclusao[Self:cChaveAtual][nIndAne]["deleted"]
				cArqAnexo := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_MSUID"]
				cOriginal := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_NOMEOR"]
				nPos      := RAT(".", cOriginal)
				If nPos > 0
					cExtensao := aTail(StrtoKarr(cOriginal,"."))
					cArqAnexo += "." + cExtensao
				EndIf
				If Self:copiaArquivoProServidor(cArqAnexo)
					RecLock("QQM", .T.)
					QQM->QQM_FILIAL := cFiLQQM
					QQM->QQM_FILQPR := cFiLQPR
					QQM->QQM_CHAVE  := cChaveQPR
					QQM->QQM_MSUID  := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_MSUID"]
					QQM->QQM_SIZE   := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_SIZE"]
					QQM->QQM_NOMEOR := Self:oInclusao[Self:cChaveAtual][nIndAne]["QQM_NOMEOR"]
					QQM->QQM_LOCAL  := "2"
					QQM->QQM_STATUP := "2"
					QQM->QQM_MIME   := Self:retornaMimeType(cExtensao)
					If !Empty(GetSx3Cache("QQM_MODULO" ,"X3_TAMANHO"))
						QQM->QQM_MODULO := "QIP"
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
METHOD persisteExclusaoAnexos() CLASS QIPA217EVDEF

	Local aAreaQQM  := QQM->(GetArea())
	Local aRecnos   := Nil
	Local cPath     := SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\")
	Local nIndRec   := 0
	Local nRecnoQQM := 0
	Local cArqAnexo := ""
	Local cExtensao := ""
	Local lExcluido := .F.

	If Self:oExclusao[Self:cChaveAtual] != Nil
		aRecnos := Self:oExclusao[Self:cChaveAtual]:GetNames()
		For nIndRec := 1 to Len(aRecnos)
			lExcluido := .F.

			//Posiciona registro na QQM
			nRecnoQQM := Val(aRecnos[nIndRec])
			QQM->(DbGoTop())
			QQM->(DbGoTo(nRecnoQQM))
			
			//Verifica nome do arquivo físico
			cExtensao := aTail(StrtoKarr(QQM->QQM_NOMEOR,"."))
			cArqAnexo := AllTrim(QQM->QQM_MSUID) + "." + AllTrim(cExtensao)

			//Apagar arquivo na Protheus_Data
			If File(cPath + cArqAnexo)
				If FErase(cPath + cArqAnexo) <> -1
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

/*/{Protheus.doc} copiaArquivoProServidor
Copia arquivo para o servidor
@author brunno.costa
@since 16/05/2023
@version P12
@param 01 - cArqAnexo, caracter, nome do arquivo
@return lSucesso, lógico, indica se conseguiu copiar o arquivo para o servidor
/*/
METHOD copiaArquivoProServidor(cArqAnexo) CLASS QIPA217EVDEF

	Local cPath     := SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\")
	Local cQPathTrm := Alltrim(Alltrim(QDOPATH()[3]))
	Local lSucesso  := .F.

	cQPathTrm += Iif(!Right( cQPathTrm,1 ) == "\", "\", "")
	cPath     += Iif(!Right( cPath,1 )     == "\", "\", "")

	//Copia para o Server
	lSucesso := CpyT2S(cQPathTrm + cArqAnexo, cPath, .T.)
	Iif(lSucesso, FErase(cQPathTrm + cArqAnexo), Help(" ",1,"QEPNAOCOP"))

Return lSucesso

/*/{Protheus.doc} retornaTamanhoDoArquivo
Retorna tamanho do arquivo em KB

@author brunno.costa
@since 16/05/2023
@version P12
@param 01 - cArquivo, caracter, nome do arquivo para checagem
@param 02 - cPath   , caracter, diretório do arquivo
@return nTamanho, número, tamanho do arquivo em KB
/*/
METHOD retornaTamanhoDoArquivo(cArquivo, cPath) CLASS QIPA217EVDEF	
Return QAFILESIZE(cArquivo, cPath)

/*/{Protheus.doc} retornaMimeType
Retorna o Mime Type do arquivo
@author brunno.costa
@since 16/05/2023
@version P12
@param 01 - cExtensao, caracter, extensão do arquivo
@return cMimeType, caracter, mime type do arquivo
/*/
METHOD retornaMimeType(cExtensao) CLASS QIPA217EVDEF	
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
METHOD permiteManutenirAnexos() CLASS QIPA217EVDEF
	Local lPermite := .T.
	lPermite := !(Self:temLaudoLaboratorio() .OR. Self:temLaudoOperacao() .OR. Self:temLaudoGeral() .OR. !Empty(M->QPL_LAUDO))
Return lPermite

/*/{Protheus.doc} temLaudoLaboratorio
Indica se possui laudo de laboratório
@author brunno.costa
@since 16/05/2023
@version P12
@return lPossui, lógico, indica se possui laudo de laboratorio
/*/
METHOD temLaudoLaboratorio() CLASS QIPA217EVDEF
	Local lPossui := .T.
	Local nPosLau := Iif(lLayout, QP215GetLau(aSavGets[nOperacao,1],"QPM_LAUDO"), QP215GetLau(aSavGets[1,1],"QPM_LAUDO"))
	lPossui := !Empty(aResultados[nOperacao,_LLA,nFldLab,nPosLau])
Return lPossui

/*/{Protheus.doc} temLaudoOperacao
Indica se possui laudo de operação
@author brunno.costa
@since 16/05/2023
@version P12
@return lPossui, lógico, indica se possui laudo de operação
/*/
METHOD temLaudoOperacao() CLASS QIPA217EVDEF
	Local lPossui := .T.
	Local nPosLau := Iif(lLayout, QP215GetLau(aSavGets[nOperacao,1],"QPM_LAUDO"), QP215GetLau(aSavGets[1,1],"QPM_LAUDO"))
	//QP215ChkOpe(nPosOpe)
	//AADD(aRet,{lRetLab,cLab})
	lPossui := !Empty(aResultados[nOperacao,_LOP,nPosLau])
Return lPossui

/*/{Protheus.doc} temLaudoGeral
Indica se possui laudo geral
@author brunno.costa
@since 16/05/2023
@version P12
@return lPossui, lógico, indica se possui laudo geral
/*/
METHOD temLaudoGeral() CLASS QIPA217EVDEF
	Local lPossui    := .T.
	Local nPosLauGer := Iif(lLayout, QP215GetLau(aSavGets[nFldLauGer],"QPL_LAUDO"), QP215GetLau(aSavGets[1,2],"QPL_LAUDO"))
	lPossui := !Empty(aResultados[nFldLauGer,1,nPosLauGer])
Return lPossui

/*/{Protheus.doc} gtMdlEvent
Recupera a referencia do objeto dos Eventos do modelo.
@author brunno.costa
@since 15/05/2023
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


