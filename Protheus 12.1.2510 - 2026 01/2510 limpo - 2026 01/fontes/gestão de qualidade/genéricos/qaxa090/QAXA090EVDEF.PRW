#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "QAXA090EVDEF.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} QAXA090EVDEF
Eventos padrões do cadastro de Anexos de Amostras
@author brunno.costa
@since 23/10/2025
/*/
CLASS QAXA090EVDEF FROM FWModelEvent

	DATA cChaveAtual as STRING
	DATA oModel      as OBJECT

	//Métodos MVC
	METHOD new() CONSTRUCTOR
	METHOD activate(oModel, cModelId)
	METHOD inTTS(oModel, cModelId)
	METHOD modelPosVld(oModel, cModelId)
	METHOD modelPreVld(oModel, cModelId)

	//Métodos Auxiliares - Regras de Negócio
	METHOD abrirAnexo()
	METHOD abrirURL()
	METHOD abrirViaQQO()
	METHOD carregaItensDaGrid(oModel)
	METHOD copiaArquivoProServidor(cArquivo)
	METHOD criaPasta(cDiretorio, nCobertura)
	METHOD excluirAnexoMemoria()
	METHOD localizaEVinculaAnexo()
	METHOD persisteExclusaoAnexo()
	METHOD persisteInclusaoAnexo()
	METHOD preparaALoadFromDataModel(aDefDados, aFields)
	METHOD preparaItemParaGridDB(aDefDados, aFields)
	METHOD retornaMimeType(cExtensao)
	METHOD retornaTamanhoDoArquivo(cArquivo, cPath)
	METHOD vinculaRelacionamentosMemoria(oModel)

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe
@author brunno.costa
@since 23/10/2025
@version P12
@return Nil
/*/
METHOD New() CLASS QAXA090EVDEF
Return

/*/{Protheus.doc} Activate
Método que é chamado pelo MVC quando ocorrer a ativação do Model.
Esse evento ocorre uma vez no contexto do modelo principal.
@author brunno.costa
@since 26/06/2018
@version 1.0
@return .T.
/*/
METHOD activate(oModel, cModelId) Class QAXA090EVDEF

	Local lRet 			:= .T.

Return lRet


/*/{Protheus.doc} abrirAnexo
Método para abertura do arquivo anexo
@author brunno.costa
@since 23/10/2025
@version P12
@return Nil
/*/
METHOD abrirAnexo() CLASS QAXA090EVDEF

	Local cArquivo  := ""
	Local cExtensao := ""
	Local cPath     := SuperGetMV("MV_QAXARQD", .F., "system\arquivos_manufatura\")
	Local cUID      := ""
	Local nOpc      := 1

	cUID := Lower(AllTrim(QQN->QQN_MSUID))
	cUID := Iif(!("-"$cUID), Lower(AllTrim(TRANSFORM( Alltrim(cUID),"@R ########-####-####-####-############"))), cUID)

	cExtensao  := AllTrim(aTail(StrtoKarr(QQN->QQN_NOMEOR,".")))
	cArquivo   := AllTrim(cUID) + "." + cExtensao
	QVRFANEXO(nOpc,cArquivo,"QQN",cPath)

Return 

/*/{Protheus.doc} abrirURL
Método para abertura do URL posicionada
@author brunno.costa
@since 23/10/2025
@version P12
@return Nil
/*/
METHOD abrirURL() CLASS QAXA090EVDEF

	Local cURL := "http://"

	If ("://" $ Lower(QQN->QQN_URL))
		cURL := QQN->QQN_URL
	Else
		cURL += QQN->QQN_URL
	EndIf

	//STR0001 - "Abrindo a URL, aguarde."
	//STR0002 - "URL"
	MsgRun(STR0001, STR0002,{|| ShellExecute("open", cURL,"","", 1) } )

Return 

/*/{Protheus.doc} abrirViaQQO
Abre arquivo ou URL via QQO
@author brunno.costa
@since 31/10/2025
@version P12
/*/
METHOD abrirViaQQO() CLASS QAXA090EVDEF

	Local oDetail := Nil
	Local oModel  := FWModelActive()

	If oModel:VldData()

		oDetail := oModel:GetModel("QQO_DETAIL")

		If !Empty(oDetail:GetValue("QQO_MSUID")) .And. QLTQueryManager():dbSeek("QQN", oDetail:GetValue("QQO_MSUID"))

			If      QQN->QQN_ORIGEM == "1"
				Self:abrirAnexo()

			ElseIf  QQN->QQN_ORIGEM == "2"
				Self:abrirURL()

			EndIf

		EndIf

	EndIf

Return 

/*/{Protheus.doc} localizaEVinculaAnexo
Método para inclusão de anexo
@author brunno.costa
@since 23/10/2025
@version P12
@return Nil
/*/
METHOD localizaEVinculaAnexo() CLASS QAXA090EVDEF

	Local cNomeReal := ""
	Local cRetorno  := ""
	Local cUID      := ""
	Local nOpc      := 1
	Local oMaster   := Nil
	Local oModel    := Nil
	Local oView     := FWViewActive()

	oModel  := oView:GetModel()
	oMaster := oModel:GetModel("QQN_MASTER")
	cUID    := FWUUIDV4( AllTrim(Upper(TcgetDB())) != "ORACLE")

	//STR0003 - "Aguarde..."
	//STR0004 - "Copiando Arquivo"
	MsgRun(STR0003, STR0004, {|| cRetorno := QVRFANEXO(nOpc, @cNomeReal, "QQN", Alltrim(QDOPATH()[3]), cUID, 35000) })

	If !Empty(cRetorno)

		oMaster:LoadValue("QQN_MSUID" , cUID)
		oMaster:LoadValue("QQN_NOMEOR", cNomeReal)

		If oView:isActive()
			oView:Refresh("V_QQN_MASTER")
		EndIf

	EndIf
	
Return 

/*/{Protheus.doc} carregaItensDaGrid
Retorna array com os dados a serem inseridos na Grid
@author brunno.costa
@since 23/10/2025
@version P12
@param 01 - oModel  , object    , modelo principal
@return aLoad, array, array com os dados para exibição na GRID MVC
/*/
METHOD carregaItensDaGrid(oModel) CLASS QAXA090EVDEF

	Local aAreaQQO  := QQO->(GetArea())
	Local aDefDados := {}
	Local aFields   := oModel:GetModel("QQO_DETAIL"):oFormModelStruct:aFields
	Local aLoad     := {}
	Local cFilQQO   := xFilial("QQO")
	Local nIndCps   := 0

	aAdd(aDefDados,0)
	aAdd(aDefDados,{})
	For nIndCps := 1 to Len(aFields)
		aAdd(aDefDados[2],Nil)
	Next nIndCps
	
	//Tratamento para registros salvos em banco de dados - INICIO
	QQO->(dbSetOrder(1))
	If cEntidade == "QQN"
		If QLTQueryManager():dbSeek("QQO", QQN->QQN_MSUID)
			While !QQO->(Eof()) .And. QQO->QQO_FILIAL == cFilQQO .And. QQO->QQO_MSUID == QQN->QQN_MSUID

				aAdd(aLoad, Self:preparaItemParaGridDB(aDefDados, aFields))
				
				QQO->(dbSkip())
			End
		EndIf
	
	ElseIf aDataQQO != Nil
		
		aLoad := Self:preparaALoadFromDataModel(aDefDados, aFields)

	ElseIf cEntidade == "QP6"

		//QQO_FILIAL+QQO_FILENT+QQO_ENTIDA+QQO_PRODUT+QQO_REVI+QQO_ROTEIR+QQO_OPERAC+QQO_ENSAIO+QQO_GRUPO+QQO_REVIGR
		If QQO->(DbSeek(cFilQQO + M->QP6_FILIAL + "QP6" + M->QP6_PRODUT + M->QP6_REVI ))
			While !QQO->(Eof()) .And.;
				QQO->QQO_FILIAL == cFilQQO       .And.;
				QQO->QQO_FILENT == M->QP6_FILIAL .And.;
				QQO->QQO_ENTIDA == "QP6"         .And.;
				QQO->QQO_PRODUT == M->QP6_PRODUT .And.;
				QQO->QQO_REVI   == M->QP6_REVI

				aAdd(aLoad, Self:preparaItemParaGridDB(aDefDados, aFields))
				
				QQO->(dbSkip())
			End
		EndIf

	ElseIf cEntidade == "QE6"

		//QQO_FILIAL+QQO_FILENT+QQO_ENTIDA+QQO_PRODUT+QQO_REVI+QQO_ROTEIR+QQO_OPERAC+QQO_ENSAIO+QQO_GRUPO+QQO_REVIGR
		If QQO->(DbSeek(cFilQQO + M->QE6_FILIAL + "QE6" + M->QE6_PRODUT + M->QE6_REVI ))
			While !QQO->(Eof()) .And.;
				QQO->QQO_FILIAL == cFilQQO       .And.;
				QQO->QQO_FILENT == M->QE6_FILIAL .And.;
				QQO->QQO_ENTIDA == "QE6"         .And.;
				QQO->QQO_PRODUT == M->QE6_PRODUT .And.;
				QQO->QQO_REVI   == M->QE6_REVI

				aAdd(aLoad, Self:preparaItemParaGridDB(aDefDados, aFields))
				
				QQO->(dbSkip())
			End
		EndIf

	ElseIf cEntidade == "QQC"

		QQO->(dbSetOrder(2))
		//QQO_FILIAL+QQO_FILENT+QQO_ENTIDA+QQO_GRUPO+QQO_REVIGR+QQO_ROTEIR+QQO_OPERAC+QQO_ENSAIO
		If QQO->(DbSeek(cFilQQO + M->QQC_FILIAL + "QQC" + M->QQC_GRUPO + M->QQC_REVI ))
			While !QQO->(Eof()) .And.;
				QQO->QQO_FILIAL == cFilQQO       .And.;
				QQO->QQO_FILENT == M->QQC_FILIAL .And.;
				QQO->QQO_ENTIDA == "QQC"         .And.;
				QQO->QQO_GRUPO  == M->QQC_GRUPO  .And.;
				QQO->QQO_REVIGR == M->QQC_REVI

				aAdd(aLoad, Self:preparaItemParaGridDB(aDefDados, aFields))
				
				QQO->(dbSkip())
			End
		EndIf

	EndIf
	//Tratamento para registros salvos em banco de dados - FIM

	If Empty(aLoad)
		aAdd(aLoad, aClone(aDefDados))
	EndIf

	QQO->(RestArea(aAreaQQO))

Return aLoad

/*/{Protheus.doc} preparaItemParaGridDB
Prepara item para inclusão na Grid
@author brunno.costa
@since 31/10/2025
@version P12
@param 01 - aDefDados, array, array com a definição dos dados
@param 02 - aFields  , array, array com a definição dos campos do modelo
@return aClone(aNovoItem), array, array com os dados do item para inclusão na Grid
/*/
METHOD preparaItemParaGridDB(aDefDados, aFields) CLASS QAXA090EVDEF

	Local aNovoItem := {}
	Local nIndCps   := 0

	aNovoItem    := aClone(aDefDados)

	For nIndCps := 1 to Len(aFields)
		If AllTrim(aFields[nIndCps][3]) == "NREG"
			aNovoItem[2, nIndCps] := QQO->(Recno())

		ElseIf aFields[nIndCps][14] //Verifica se é campo virtual
			If !Empty(GetSx3Cache(aFields[nIndCps][3], "X3_INIBRW"))
				aNovoItem[2, nIndCps] := &(GetSx3Cache(aFields[nIndCps][3], "X3_INIBRW"))
			EndIf

		ElseIf !aFields[nIndCps][14] //Verifica se NÃO é campo virtual
			aNovoItem[2, nIndCps] := QQO->(&(aFields[nIndCps][3]))

		EndIf
	Next nIndCps

Return aClone(aNovoItem)

/*/{Protheus.doc} preparaALoadFromDataModel
Prepara array de itens para inclusão na Grid a partir do DataModel
@author brunno.costa
@since 31/10/2025
@version P12
@param 01 - aDefDados, array, array com a definição dos dados
@param 02 - aFields  , array, array com a definição dos campos do modelo
@return aLoad, array, array com os dados para exibição na GRID MVC
/*/
METHOD preparaALoadFromDataModel(aDefDados, aFields) CLASS QAXA090EVDEF

	Local aCols   := aDataQQO[2]
	Local aHeader := aDataQQO[1]
	Local aLoad   := {}
	Local nPosUID := Ascan(aHeader,{|x| AllTrim(x[2])=="QQO_MSUID"})
	Local nRow    := 0

	For nRow := 1 To Len(aCols)
		If !aTail(aCols[nRow]) .And. !Empty(aCols[nRow, nPosUID])//Indica se o registro está marcado para exclusão ou vazio
			aAdd(aLoad,{0,aClone(aCols[nRow])})
		EndIf
	Next

Return aLoad

/*/{Protheus.doc} persisteInclusaoAnexo
Persiste Gravação dos Anexos no Banco e Protheus_Data
@author brunno.costa
@since 23/10/2025
@version P12
/*/
METHOD persisteInclusaoAnexo() CLASS QAXA090EVDEF

	Local cArqAnexo  := ""
	Local cExtensao  := ""
	Local cOriginal  := ""
	Local lPersistiu := .T.
	Local nPos       := 0
	Local oView      := FWViewActive()

	oModel  := oView:GetModel()
	oMaster := oModel:GetModel("QQN_MASTER")
		
	cArqAnexo := Lower(oMaster:getValue("QQN_MSUID"))
	cArqAnexo := Iif(!("-"$cArqAnexo), Lower(AllTrim(TRANSFORM( Alltrim(cArqAnexo),"@R ########-####-####-####-############"))), cArqAnexo)

	cOriginal := oMaster:getValue("QQN_NOMEOR")
	nPos      := RAT(".", cOriginal)
	If nPos > 0
		cExtensao := AllTrim(aTail(StrtoKarr(cOriginal,".")))
		cArqAnexo += "." + cExtensao
	EndIf
	
	lPersistiu := Self:copiaArquivoProServidor(cArqAnexo)

Return lPersistiu

/*/{Protheus.doc} persisteExclusaoAnexo
Persiste Exclusão dos Anexos no Banco e Protheus_Data
@author brunno.costa
@since 23/10/2025
@version P12
/*/
METHOD persisteExclusaoAnexo() CLASS QAXA090EVDEF

	Local cPath     := SuperGetMV("MV_QAXARQD", .F., "system\arquivos_manufatura\")
	Local cArqAnexo := ""
	Local cExtensao := ""
	Local lExcluido := .F.

	cArqAnexo := Lower(AllTrim(QQN->QQN_MSUID) )
	cArqAnexo := Iif(!("-"$cArqAnexo), Lower(AllTrim(TRANSFORM( Alltrim(cArqAnexo),"@R ########-####-####-####-############"))), cArqAnexo)
	cExtensao := AllTrim(aTail(StrtoKarr(QQN->QQN_NOMEOR,".")))
	cArqAnexo += "." + cExtensao

	//Apagar arquivo na Protheus_Data
	If File(cPath + cArqAnexo)
		If FErase(cPath + cArqAnexo) <> -1
			lExcluido := .T.
		End
	Else
		lExcluido := .T.
	EndIf

Return lExcluido

/*/{Protheus.doc} copiaArquivoProServidor
Copia arquivo para o servidor
@author brunno.costa
@since 23/10/2025
@version P12
@param 01 - cArqAnexo, caracter, nome do arquivo
@return lSucesso, lógico, indica se conseguiu copiar o arquivo para o servidor
/*/
METHOD copiaArquivoProServidor(cArqAnexo) CLASS QAXA090EVDEF

	Local cPath     := SuperGetMV("MV_QAXARQD", .F., "system\arquivos_manufatura\")
	Local cQPathTrm := Alltrim(Alltrim(QDOPATH()[3]))
	Local lSucesso  := .F.
	Local oDocControl := QDODocumentControl():New()

	If Self:criaPasta(cPath) == 0

		cQPathTrm += Iif(!Right( cQPathTrm,1 ) == "\", "\", "")
		cPath     += Iif(!Right( cPath,1 )     == "\", "\", "")

		//Copia para o Server
		lSucesso := oDocControl:copiaProtegidaArquivo(cQPathTrm + cArqAnexo, cPath + cArqAnexo) 

	EndIf

Return lSucesso

/*/{Protheus.doc} retornaTamanhoDoArquivo
Retorna tamanho do arquivo em KB
@author brunno.costa
@since 23/10/2025
@version P12
@param 01 - cArquivo, caracter, nome do arquivo para checagem
@param 02 - cPath   , caracter, diretório do arquivo
@return nTamanho, número, tamanho do arquivo em KB
/*/
METHOD retornaTamanhoDoArquivo(cArquivo, cPath) CLASS QAXA090EVDEF	
Return QAFILESIZE(cArquivo, cPath)

/*/{Protheus.doc} retornaMimeType
Retorna o Mime Type do arquivo
@author brunno.costa
@since 23/10/2025
@version P12
@param 01 - cExtensao, caracter, extensão do arquivo
@return cMimeType, caracter, mime type do arquivo
/*/
METHOD retornaMimeType(cExtensao) CLASS QAXA090EVDEF	
	Local cMimeType := ""
	cExtensao := AllTrim(Lower(cExtensao))
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

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.
@author brunno.costa
@since 23/10/2025
@version 1.0
@param 01 - oModel  , Object   , Modelo de dados
@param 02 - cModelId, Character, ID do modelo de dados
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS QAXA090EVDEF
	
	Local cArquivo  := ""
	Local cExtensao := ""
	Local cUID      := ""

	If lInclui
	
		RecLock("QQN", .F.)
		QQN->QQN_USER   := RetCodUsr()
		QQN->QQN_DTINC  := Date()

		If !Empty(QQN->QQN_NOMEOR)

			cUID := Lower(AllTrim(QQN->QQN_MSUID))
			cUID := Iif(!("-"$cUID), Lower(AllTrim(TRANSFORM( Alltrim(cUID),"@R ########-####-####-####-############"))), cUID)

			cExtensao  := AllTrim(aTail(StrtoKarr(QQN->QQN_NOMEOR,".")))
			cArquivo   := AllTrim(cUID) + "." + cExtensao
			
			QQN->QQN_LOCALF := "1" //Físico
			QQN->QQN_ORIGEM := "1"
			QQN->QQN_MIME   := Self:retornaMimeType(cExtensao)
			QQN->QQN_SIZE   := Self:retornaTamanhoDoArquivo(cArquivo, AllTrim(SuperGetMV("MV_QAXARQD", .F., "system\arquivos_manufatura\")))
		
		ElseIf !Empty(QQN->QQN_URL)
			QQN->QQN_ORIGEM := "2"

		EndIf

		QQN->(MsUnlock())

	EndIf

Return Nil

/*/{Protheus.doc} criaPasta
Cria pasta no diretório padrão do parâmetro MV_QAXARQD
@author brunno.costa
@since 23/10/2025
@param 01 - cCaminho  , caracter, caminho da pasta a ser criada
@param 02 - nCobertura, número , indica se deve exibir mensagem de erro
@return nReturn, número , código de retorno da criação da pasta
/*/
METHOD criaPasta(cCaminho, nCobertura) CLASS QAXA090EVDEF

	Local nReturn  := 0
	
	Default cCaminho := AllTrim(SuperGetMV("MV_QAXARQD", .F., "system\arquivos_manufatura\"))
	Default nCobertura := 0

	If !ExistDir(cCaminho)
		nReturn  := MakeDir(cCaminho)
		If nReturn != 0 .Or. nCobertura == 1
			//STR0005 - "Falha na criação do diretório"
			//STR0006 - "Revise as permissões de acesso na execução do AppServer.EXE e a configuração do parâmetro MV_QAXARQD."
			Help(NIL, NIL, "QAXA090USED", NIL, STR0005 + " '" + cCaminho + "'.", 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006})
			nReturn := Iif(nCobertura, -1, nReturn)
		EndIf
	EndIf

Return nReturn

/*/{Protheus.doc} ModelPreVld
Método para pré validação do modelo

@author brunno.costa
@since 23/10/2025

@param 01 - oModel  , objeto, Modelo de dados
@param 02 - cModelId, caracter, ID do modelo de dados
@return lRet, lógico, Indica se o modelo de dados está válido
/*/
METHOD ModelPreVld(oModel, cModelId) CLASS QAXA090EVDEF

	Local cUID    := ""
	Local lRet    := .T.
	Local oDetail := oModel:GetModel("QQO_DETAIL")
	Local oMaster := oModel:GetModel("QQN_MASTER")
	
	If Empty(oMaster:getValue("QQN_ORIGEM") ) .And. (lInclui .Or. lUpdate) .And. cOrigem != "0"
		oMaster:LoadValue("QQN_ORIGEM", cOrigem)
	EndIf

	If Empty(oMaster:getValue("QQN_MSUID") ) .And. (lInclui .Or. lUpdate)
		cUID    := FWUUIDV4( AllTrim(Upper(TcgetDB())) != "ORACLE")
		oMaster:LoadValue("QQN_MSUID", cUID)
	EndIf

	
	If cEntidade != "QQN"
		
		If (lInclui)

			oDetail:LoadValue("QQO_FILENT", xFilial(cEntidade) )

		ElseIf (lUpdate)

			oDetail:LoadValue("QQO_FILENT", &("M->" + cEntidade + "_FILIAL") )

		EndIf

		If (lInclui .Or. lUpdate)
		
			oDetail:LoadValue("QQO_FILIAL", xFilial("QQO"))
			oDetail:LoadValue("QQO_ENTIDA", cEntidade)

			If cEntidade == "QP6"
				oDetail:LoadValue("QQO_PRODUT", M->QP6_PRODUT)
				oDetail:LoadValue("QQO_REVI"  , M->QP6_REVI  )

			ElseIf cEntidade == "QE6"
				oDetail:LoadValue("QQO_PRODUT", M->QE6_PRODUT)
				oDetail:LoadValue("QQO_REVI"  , M->QE6_REVI  )

			ElseIf cEntidade == "QQC"
				oDetail:LoadValue("QQO_GRUPO" , M->QQC_GRUPO )
				oDetail:LoadValue("QQO_REVIGR", M->QQC_REVI  )

			EndIf

			If Empty(oDetail:getValue("QQO_USER") ) 
				oDetail:LoadValue("QQO_USER", RetCodUsr())
			EndIf

			If Empty(oDetail:getValue("QQO_DTINC") ) 
				oDetail:LoadValue("QQO_DTINC", Date())
			EndIf

		EndIf

	EndIf


Return lRet

/*/{Protheus.doc} ModelPosVld
Método para validação do modelo
@author brunno.costa
@since 23/10/2025
@param 01 - oModel  , objeto, Modelo de dados
@param 02 - cModelId, caracter, ID do modelo de dados
@return lRet, lógico, Indica se o modelo de dados está válido
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS QAXA090EVDEF

	Local lRet       := .T.
	Local oGridModel := oModel:GetModel("QQO_DETAIL")
	Local oMaster    := oModel:GetModel("QQN_MASTER")
	
	If lDelete .And. (oGridModel:Length() > 1 .Or. !Empty(oGridModel:GetValue("QQO_ENTIDA",1)))

		//STR0011 - "Exclusão não permitida: arquivo em uso."
		//STR0012 - "Escolha um arquivo sem relacionamentos para excluir."
		Help(NIL, NIL, "ExistQQO", NIL, STR0011, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0012})
		lRet := .F.

	EndIf

	If lRet .And. oMaster:getValue("QQN_ORIGEM") == "1"	

		If lInclui
		
			If Empty(oMaster:getValue("QQN_NOMEOR"))
				//STR0007 - "Arquivo não vinculado."
				//STR0008 - "Localize e vincule o arquivo e tente novamente."
				Help(NIL, NIL, "QQN_NOMEOR", NIL, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0008})
				lRet := .F.

			Else
				lRet := Self:persisteInclusaoAnexo()

			EndIf

		ElseIf lDelete
			
			lRet := Self:persisteExclusaoAnexo()

		EndIf
	
	ElseIf lRet .And. oMaster:getValue("QQN_ORIGEM") == "2" .And. Empty(oMaster:getValue("QQN_URL"))

		//STR0009 - "URL Arquivo obrigatória."
		//STR0010 - "Informe a URL do arquivo e tente novamente."
		Help(NIL, NIL, "QQN_URL", NIL, STR0009, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0010})
		lRet := .F.

	EndIf

Return lRet

/*/{Protheus.doc} vinculaRelacionamentosMemoria
Método que é chamado pelo MVC quando chamar o commit padrão MVC dos relacionamentos.
@author brunno.costa
@since 31/10/2025
@version 1.0
@param 01 - oModel  , objeto, Modelo de dados
@return .T.
/*/
METHOD vinculaRelacionamentosMemoria(oModel) Class QAXA090EVDEF

	Local lRet    := .T.

	aDataQQO := aClone(oModel:GetModel("QQO_DETAIL"):GetOldData())

Return lRet
