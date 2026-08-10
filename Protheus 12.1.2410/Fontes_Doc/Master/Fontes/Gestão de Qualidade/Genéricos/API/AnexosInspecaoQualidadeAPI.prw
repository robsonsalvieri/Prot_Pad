#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AnexosInspecaoQualidadeAPI.CH"

#DEFINE nPosCPS_Considera                  1
#DEFINE nPosCPS_Titulo_Interface           2
#DEFINE nPosCPS_Titulo_API                 3
#DEFINE nPosCPS_Protheus                   4
#DEFINE nPosCPS_Tipo                       5
#DEFINE nPosCPS_Tamanho                    6
#DEFINE nPosCPS_Decimal                    7
#DEFINE nPosCPS_Alias                      8
#DEFINE nPosCPS_Protheus_Externo           9

/*/{Protheus.doc} qualityinspectionattachments
API Resultados Anexos da Inspeção da Qualidade
@author brunno.costa
@since  31/10/2024
/*/
WSRESTFUL qualityinspectionattachments DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Anexos Inspeção de Qualidade"

	WSDATA PictureCode as STRING OPTIONAL
	WSDATA RecnoQER    as STRING OPTIONAL
	WSDATA RecnoQPR    as STRING OPTIONAL
	WSDATA RecnoQQM    as STRING OPTIONAL

	WSMETHOD GET listprocessattachments;
    DESCRIPTION STR0002; //"Retorna lista de anexos de uma amostra de resultados"
    WSSYNTAX "api/qip/v1/listprocessattachments/{RecnoQPR}" ;
    PATH "/api/qip/v1/listprocessattachments" ;
    TTALK "v1"

	WSMETHOD GET listincomingattachments;
    DESCRIPTION STR0002; //"Retorna lista de anexos de uma amostra de resultados"
    WSSYNTAX "api/qie/v1/listincomingattachments/{RecnoQER}" ;
    PATH "/api/qie/v1/listincomingattachments" ;
    TTALK "v1"

	WSMETHOD GET attachedfile;
    DESCRIPTION STR0003; //"Retorna Arquivo em base 64"
    WSSYNTAX "api/qip/v1/attachedfile/{RecnoQQM}" ;
    PATH "/api/qip/v1/attachedfile" ;
    TTALK "v1"

	WSMETHOD DELETE attachedfile;
    DESCRIPTION STR0004; //"Deleta arquivo anexo"
    WSSYNTAX "api/qip/v1/attachedfile/{RecnoQQM}" ;
    PATH "/api/qip/v1/attachedfile" ;
    TTALK "v1"

	WSMETHOD POST savefile;
	DESCRIPTION STR0005; //"Salva Arquivo Anexo"
	WSSYNTAX "api/qip/v1/savefile" ;
	PATH "/api/qip/v1/savefile" ;
	TTALK "v1"

	WSMETHOD GET canqipreceivefiles;
	DESCRIPTION STR0006; //"Indica se o ambiente está preparado para o recebimento de arquivos do QIP"
	WSSYNTAX "api/qip/v1/canqipreceivefiles" ;
	PATH "/api/qip/v1/canqipreceivefiles" ;
	TTALK "v1"

	WSMETHOD GET canqiereceivefiles;
	DESCRIPTION STR0007; //"Indica se o ambiente está preparado para o recebimento de arquivos do QIE"
	WSSYNTAX "api/qie/v1/canqiereceivefiles" ;
	PATH "/api/qie/v1/canqiereceivefiles" ;
	TTALK "v1"

	WSMETHOD GET repositoryimage;
    DESCRIPTION STR0021; //"Retorna Imagem do Repositório em base 64"
    WSSYNTAX "api/qip/v1/repositoryimage/{PictureCode}" ;
    PATH "/api/qip/v1/repositoryimage" ;
    TTALK "v1"

ENDWSRESTFUL

WSMETHOD POST savefile WSSERVICE qualityinspectionattachments
    Local oAPIClass  := AnexosInspecaoQualidadeAPI():New(Self)
Return oAPIClass:SalvaAnexo(DecodeUTF8(Self:GetContent()))

WSMETHOD GET canqipreceivefiles WSSERVICE qualityinspectionattachments
    Local oAPIClass  := AnexosInspecaoQualidadeAPI():New(Self)
Return oAPIClass:PodeReceberArquivosQIP()

WSMETHOD GET canqiereceivefiles WSSERVICE qualityinspectionattachments
    Local oAPIClass  := AnexosInspecaoQualidadeAPI():New(Self)
Return oAPIClass:PodeReceberArquivosQIE()

WSMETHOD GET listprocessattachments PATHPARAM RecnoQPR WSSERVICE qualityinspectionattachments
    Local oAPIClass  := AnexosInspecaoQualidadeAPI():New(Self)
Return oAPIClass:RetornaListaDeAnexosDeUmaAmostraQIP(Val(Self:RecnoQPR))

WSMETHOD GET listincomingattachments PATHPARAM RecnoQER WSSERVICE qualityinspectionattachments
    Local oAPIClass  := AnexosInspecaoQualidadeAPI():New(Self)
Return oAPIClass:RetornaListaDeAnexosDeUmaAmostraQIE(Val(Self:RecnoQER))

WSMETHOD GET attachedfile PATHPARAM RecnoQQM WSSERVICE qualityinspectionattachments
    Local oAPIClass  := AnexosInspecaoQualidadeAPI():New(Self)
Return oAPIClass:RetornaAnexoAPartirDoRecnoDaQQM(Val(Self:RecnoQQM))

WSMETHOD GET repositoryimage PATHPARAM PictureCode WSSERVICE qualityinspectionattachments
    Local oAPIClass  := AnexosInspecaoQualidadeAPI():New(Self)
	Default Self:PictureCode := ""
Return oAPIClass:RetornaFotoRepositorioDeImagens(Self:PictureCode)

WSMETHOD DELETE attachedfile PATHPARAM RecnoQQM WSSERVICE qualityinspectionattachments
    Local oAPIClass  := AnexosInspecaoQualidadeAPI():New(Self)
	Self:SetContentType("")
Return oAPIClass:DeletaAnexoAmostra(Val(Self:RecnoQQM))

/*/{Protheus.doc} AnexosInspecaoQualidadeAPI
Regras de Negocio - API Anexos Inspeção da Qualidade
@author brunno.costa
@since  31/10/2024
/*/
CLASS AnexosInspecaoQualidadeAPI FROM LongNameClass

	DATA cDetailedMessage            as STRING
	DATA cErrorMessage               as STRING
	DATA lForcaInexistenciaDiretorio as LOGICAL
	DATA lTemQQM                     as LOGICAL
	DATA lTemQQMModulo               as LOGICAL
	DATA oAPIManager                 as OBJECT
    DATA oWSRestFul                  as OBJECT

    METHOD new(oWSRestFul) CONSTRUCTOR
	METHOD CriaPasta(cDiretorio)
	METHOD DeletaAnexoAmostra(nRecnoQQM)
	METHOD ErrorBlock(e)
	METHOD ExcluiAnexosERelacionamento(cFilQPR, cChave)
	METHOD ExcluiArquivoAnexo(cNome)
	METHOD MapeiaCamposQQM(cCampos)
	METHOD PodeReceberArquivosQIE()
	METHOD PodeReceberArquivosQIP()
	METHOD RegistraAnexo(oContent, cStatus, cChave, cModulo)
	METHOD RegistraAnexos(oItemAPI, oRegistro, cModulo)
	METHOD RetornaAnexoAPartirDoRecnoDaQQM(nRecnoQQM)
	METHOD RetornaFotoRepositorioDeImagens(cCodigo)
	METHOD RetornaListaDeAnexosDeUmaAmostraQIE(nRecnoQER)
	METHOD RetornaListaDeAnexosDeUmaAmostraQIP(nRecnoQPR)
	METHOD SalvaAnexo(cContent, lSucesso)

ENDCLASS

METHOD new(oWSRestFul) CLASS AnexosInspecaoQualidadeAPI
     Self:oWSRestFul                  := oWSRestFul
	 Self:oAPIManager                 := QualityAPIManager():New(Nil, oWSRestFul, Nil)
	 Self:lForcaInexistenciaDiretorio := .F.
	 Self:lTemQQM                     := !Empty(FWX2Nome( "QQM" ))
	 Self:lTemQQMModulo               := !Empty(GetSx3Cache("QQM_MODULO" ,"X3_TAMANHO"))
	 Self:cErrorMessage               := ""
	 Self:cDetailedMessage            := ""
Return Self

/*/{Protheus.doc} MapeiaCamposQQM
Mapeia os Campos da tabela QQM do Protheus - Anexos Inspeção Qualidade     
@author brunno.costa
@since  31/10/2024
@param 01 - cCampos, String, string com os campos [nPosCPS_Titulo_API] para consideração separados por vírgula
@return aMapaCampos, Array , {{lConsidera, Titulo Interface, Título API, Campo Protheus, Tipo, Tamanho, Decimal}, ...}
                             {{nPosCPS_Considera, ..., nPosCPS_Decimal}, ...}
/*/
METHOD MapeiaCamposQQM(cCampos) CLASS AnexosInspecaoQualidadeAPI

    Local aMapaCampos := {}

	aAdd(aMapaCampos, {.T., "UID"         , "uid"         , "QQM_MSUID" , "C"  , GetSx3Cache("QQM_MSUID" ,"X3_TAMANHO"), 0, "QQM" })
	aAdd(aMapaCampos, {.T., "TipoMime"    , "mimeType"    , "QQM_MIME"  , "C"  , GetSx3Cache("QQM_MIME"  ,"X3_TAMANHO"), 0, "QQM" })
	aAdd(aMapaCampos, {.T., "NomeOriginal", "originalName", "QQM_NOMEOR", "C"  , GetSx3Cache("QQM_NOMEOR","X3_TAMANHO"), 0, "QQM" })
	aAdd(aMapaCampos, {.T., "Recno"       , "recno"       , "RECNOQQM"  , "NN" , 0                                     , 0, "QQM" })
	aAdd(aMapaCampos, {.T., "Tamanho"     , "size"        , "QQM_SIZE"  , "N"  , GetSx3Cache("QQM_SIZE","X3_TAMANHO")  , 0, "QQM" })
	

    aMapaCampos := Self:oAPIManager:MarcaCamposConsiderados(cCampos, aMapaCampos, nPosCPS_Protheus)

Return aMapaCampos

/*/{Protheus.doc} ErrorBlock
Proteção para Execução de Error.log
@author brunno.costa
@since  31/10/2024
@param 01 - e, objeto, objeto de errror.log
/*/
METHOD ErrorBlock(e) CLASS AnexosInspecaoQualidadeAPI
	
	Local cCallStack := ""
	Local nIndAux    := Nil
	Local nTotal     := 10
	
	For nIndAux := 2 to (1+nTotal)
		cCallStack += " <- " + ProcName(nIndAux) + " line " + cValToChar(ProcLine(nIndAux))
	Next nIndAux

	Self:cErrorMessage    := Iif(Empty(Self:cErrorMessage) , STR0008 + " - AnexosInspecaoQualidadeAPI", Self:cErrorMessage ) //"Erro Interno"
	Self:cDetailedMessage := e:Description + cCallStack
	Self:oAPIManager:lWarningError := .F.
	
Return

/*/{Protheus.doc} SalvaAnexo
Salva Anexo
@author brunno.costa
@since  31/10/2024
@param 01 - cContent, caracter, conteúdo em JSON
@param 02 - lSucesso, lógico  , variável para facilitar cobertura de erro
/*/
METHOD SalvaAnexo(cContent, lSucesso) CLASS AnexosInspecaoQualidadeAPI

	Local aBase64     := {}
	Local bErrorBlock := Nil
	Local cBase64     := Nil
	Local cError      := ""
	Local cNomeOrig   := ""
	Local cNomeReal   := ""
	Local cPath       := SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\")
	Local cResp       := Nil
	Local oContent    := JsonObject():New()
	Local oResponse   := JsonObject():New()
	Local oSelf       := Self
	
	Default lSucesso := Self:lTemQQM

	bErrorBlock := ErrorBlock({|e| lSucesso := .F., cError := e:Description, oSelf:ErrorBlock(e), Break(e)})
	Begin Sequence
		oContent:fromJson(cContent)
		cNomeOrig := oContent['originalFileName']
		cNomeReal := oContent['uid'] + "." + aTail(StrtoKarr(oContent['originalFileName'],"."))
		If lSucesso
			aBase64   := StrtoKarr(oContent['base64File'],",")
			cBase64   := aBase64[2]
			lSucesso  := Self:CriaPasta(cPath) == 0
			lSucesso  := lSucesso .AND. !Empty(Decode64(cBase64, Lower(cPath + cNomeReal)))
		EndIf
	Recover
	End Sequence
	ErrorBlock(bErrorBlock)

	Self:oWSRestFul:SetContentType("application/json")

	If lSucesso

		Self:oAPIManager:RespondeValor("result", .T., "", "")
		StartJob("QQMSTATUPD", GetEnvServer(), .F., cEmpAnt, cFilAnt, oContent:toJson())
		
	Else
		oResponse['code'         ] := 403
		oResponse['errorCode'    ] := 403

		oResponse['response'     ] := STR0009 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." //"Falha ao salvar o anexo"
		oResponse['message'      ] := STR0009 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." + Self:cErrorMessage //"Falha ao salvar o anexo"
		oResponse['errorMessage' ] := STR0009 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." + Self:cDetailedMessage //"Falha ao salvar o anexo"
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
		SetRestFault(403, EncodeUtf8(STR0009 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." + Self:cErrorMessage), .T.,; //"Falha ao salvar o anexo"
					 403, EncodeUtf8(STR0009 + " '" + Iif(ValType(cNomeOrig) == "C", cNomeOrig, "")  + "'." + Self:cDetailedMessage)) //"Falha ao salvar o anexo"
	EndIf

Return 

/*/{Protheus.doc} RegistraAnexos
Registra início do recebimento do anexo
@author brunno.costa
@since  31/10/2024
@param 01 - oItemAPI , objeto  , objeto com os dados do item recebidos na API
@param 02 - oRegistro, objeto  , objeto JSON com os dados para gravação na QPR
@param 03 - cModulo  , caracter, modulo para relacionamento do registro
/*/
METHOD RegistraAnexos(oItemAPI, oRegistro, cModulo) CLASS AnexosInspecaoQualidadeAPI

	Local nAnexos   := 0
	Local nIndAnexo := 0

	Default cModulo := "QIP"

	If !Self:lTemQQM
		Self:oAPIManager:lWarningError := .T.
		Self:cErrorMessage             := STR0010 //"Protheus desatualizado, atualize o dicionário para inclusão da tabela QQM - Anexos Inspeção Qualidade."
		Self:cDetailedMessage          := STR0010 //"Protheus desatualizado, atualize o dicionário para inclusão da tabela QQM - Anexos Inspeção Qualidade."
	ElseIf oItemAPI[ 'attachments' ] != Nil .AND. ValType(oItemAPI[ 'attachments' ]) == "A"
		nAnexos   := Len(oItemAPI[ 'attachments' ])
		For nIndAnexo := 1 to nAnexos
			If cModulo == "QIE"
				Self:RegistraAnexo(oItemAPI[ 'attachments', nIndAnexo], "1", oRegistro["QER_CHAVE"], cModulo)
			Else
				Self:RegistraAnexo(oItemAPI[ 'attachments', nIndAnexo], "1", oRegistro["QPR_CHAVE"], cModulo)
			EndIf
		Next
	EndIf

Return

/*/{Protheus.doc} RegistraAnexo
Registra atualização de status do anexo
@author brunno.costa
@since  31/10/2024
@param 01 - oContent, objeto  , objeto JSON com os dados do anexo para registro
@param 02 - cStatus , caracter, status do anexo: 1=Registrado; 2=Upload Completo
@param 03 - cChave  , caracter, QPR_CHAVE relacionado ao anexo
@param 04 - cModulo  , caracter, modulo para relacionamento do registro
/*/
METHOD RegistraAnexo(oContent, cStatus, cChave, cModulo) CLASS AnexosInspecaoQualidadeAPI

	Local cBanco     := Upper(TcgetDB())
	Local lExiste    := .F.

	If "ORACLE" $ cBanco
		oContent['uid'] := Upper(AllTrim(StrTran(oContent['uid'], "-", "")))
	Else
		oContent['uid'] := Upper(AllTrim(oContent['uid']))
	EndIf

	DbSelectArea("QQM")
	QQM->(DbSetOrder(2))
	lExiste := QQM->(DbSeek(oContent['uid'])) .Or. QQM->(DbSeek(Lower(oContent['uid'])))

	//Aguarda gravação e liberação da transação principal
	While !lExiste .AND. cStatus == "2" //2 - Upload Completo
		lExiste := QQM->(DbSeek(oContent['uid'])) .Or. QQM->(DbSeek(Lower(oContent['uid'])))
		Sleep(500)
	EndDo

	RecLock("QQM", !lExiste)
	If !lExiste
		QQM->QQM_FILIAL := xFilial("QQM")
		QQM->QQM_FILQPR := Iif(cModulo == "QIE", xFilial("QER"), xFilial("QPR"))
		QQM->QQM_MSUID  := oContent['uid']
		QQM->QQM_MIME   := oContent['mimeType']
		QQM->QQM_SIZE   := oContent['size']
		QQM->QQM_NOMEOR := oContent['originalFileName']
		QQM->QQM_LOCAL  := "2"

		If Self:lTemQQMModulo
			QQM->QQM_MODULO := cModulo
		EndIF

		If !Empty(cChave) .AND. Empty(QQM->QQM_CHAVE)
			QQM->QQM_CHAVE := cChave
		EndIf
	EndIf

	QQM->QQM_STATUP := Iif(QQM->QQM_STATUP != "2", cStatus, QQM->QQM_STATUP)

	QQM->(MsUnlock())

Return 

/*/{Protheus.doc} CriaPasta
Método que cria pastas e sub-pastas conforme parametro caso estas não existam.
@type  METHOD
@author brunno.costa
@since  31/10/2024
@param 01 - cDiretorio, caractere, diretório a ser criado.
@return nReturn, numérico, código do erro na criação do diretório
/*/
METHOD CriaPasta(cDiretorio) CLASS AnexosInspecaoQualidadeAPI

	Local aPastas  := StrTokArr(cDiretorio, "\")
	Local cCaminho := "\"
	Local nPasta   := 0
	Local nPastas  := Len(aPastas)
	Local nReturn  := 0

	For nPasta := 1 to nPastas
		cCaminho += aPastas[nPasta] + "\"
		If !ExistDir(cCaminho)
			nReturn  := MakeDir(cCaminho)
			If nReturn != 0 .Or. Self:lForcaInexistenciaDiretorio //Apoio cobertura
				Self:cDetailedMessage += STR0011 + " '" + cDiretorio + "': " + cValToChar(nReturn) //"Erro na criação do diretório"
				nReturn := Iif(Self:lForcaInexistenciaDiretorio, -1, Self:lForcaInexistenciaDiretorio)
				Exit
			EndIf
		EndIf
	Next

Return nReturn

/*/{Protheus.doc} PodeReceberArquivosQIP
Indica se o ambiente está preparado para o recebimento de arquivos - módulo QIP
@author brunno.costa
@since  31/10/2024
@return lRetorno, lógico, indica se o ambiente está preparado para o recebimento de arquivos - módulo QIP
/*/
METHOD PodeReceberArquivosQIP() CLASS AnexosInspecaoQualidadeAPI
     
	Local cResp     := ""
    Local lRetorno  := Self:lTemQQM
	Local oResponse := JsonObject():New()
	
	oResponse['canReceveFiles' ] := Iif(lRetorno, 'true', 'false')

	Self:oWSRestFul:SetContentType("application/json")

	If lRetorno
		//Processou com sucesso.
		HTTPSetStatus(200)
		oResponse['code'         ] := 200
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
		
	Else
		oResponse['showWarningError' ] := .T.
		oResponse['code'         ]     := 403
		oResponse['errorCode'    ]     := 403
		oResponse['errorMessage' ]     := STR0010 //"Protheus desatualizado, atualize o dicionário para inclusão da tabela QQM - Anexos Inspeção Qualidade."
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
		SetRestFault(403, cResp, .T.,;
		             403, cResp)
	EndIf

Return lRetorno

/*/{Protheus.doc} PodeReceberArquivosQIE
Indica se o ambiente está preparado para o recebimento de arquivos - módulo QIE
@author brunno.costa
@since  31/10/2024
@return lRetorno, lógico, indica se o ambiente está preparado para o recebimento de arquivos - módulo QIE
/*/
METHOD PodeReceberArquivosQIE() CLASS AnexosInspecaoQualidadeAPI
     
	Local cResp     := ""
    Local lRetorno  := Self:lTemQQM .And. Self:lTemQQMModulo
	Local oResponse := JsonObject():New()
	
	oResponse['canReceveFiles' ] := Iif(lRetorno, 'true', 'false')

	Self:oWSRestFul:SetContentType("application/json")

	If lRetorno
		//Processou com sucesso.
		HTTPSetStatus(200)
		oResponse['code'         ] := 200
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
		
	Else
		oResponse['showWarningError' ] := .T.
		oResponse['code'         ]     := 403
		oResponse['errorCode'    ]     := 403
		oResponse['errorMessage' ]     := STR0012 //"Protheus desatualizado, atualize o dicionário para atualização da tabela 'QQM - Anexos Inspeção Qualidade' com novo campo de controle QQM_MODULO."
		cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
		Self:oWSRestFul:SetResponse( cResp )
		SetRestFault(403, cResp, .T.,;
		             403, cResp)
	EndIf

Return lRetorno

/*/{Protheus.doc} RetornaListaDeAnexosDeUmaAmostraQIP
Retorna uma lista de anexos referentes a amostra 
@type method
@author brunno.costa
@since  31/10/2024
@param nRecnoQPR, numérico, RECNO da amostra de resultados
@return lSucesso, lógico, indica se conseguiu retornar a lista
/*/
METHOD RetornaListaDeAnexosDeUmaAmostraQIP(nRecnoQPR) CLASS AnexosInspecaoQualidadeAPI
	
	Local cAlias      := Nil
    Local cQuery      := ""
	Local lSucesso    := .F.
	Local nPagina     := 1
	Local nTamPag     := 999
	Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposQQM("*"), Self:oWSRestFul)
	Local oQLTQueryM  := QLTQueryManager():New()

	If Self:lTemQQM

		cQuery := " SELECT QQM_NOMEOR, "
		cQuery +=		 " RECNOQQM, "
		cQuery +=		 " QQM_MSUID, "
		cQuery += 		 " QQM_MIME, "
		cQuery += 		 " QQM_SIZE "
		cQuery += " FROM "
		cQuery +=  " (SELECT QPR_FILIAL, "
		cQuery += 		   " QPR_CHAVE "
		cQuery +=	" FROM " + RetSqlName("QPR")
		cQuery +=	" WHERE R_E_C_N_O_ = '" + cValToChar(nRecnoQPR) + "' "
		cQuery +=		  " AND D_E_L_E_T_ = ' ' ) QPR "
		cQuery += " INNER JOIN "
		cQuery +=  " (SELECT QQM_FILQPR, "
		cQuery += 		   " QQM_CHAVE, "
		cQuery += 		   " R_E_C_N_O_ RECNOQQM, "
		cQuery +=		   " QQM_NOMEOR, "
		cQuery +=		   " QQM_MSUID, "
		cQuery += 		   " QQM_MIME, "
		cQuery += 		   " QQM_SIZE "
		cQuery += 	" FROM " + RetSqlName("QQM")
		cQuery += 	" WHERE D_E_L_E_T_ = ' ' "
		
		If Self:lTemQQMModulo
			cQuery +=  " AND (QQM_MODULO  = 'QIP' OR COALESCE(QQM_MODULO, ' ')  = ' ') "
		EndIf

		cQuery +=  " ) QQM ON QQM_FILQPR = QPR.QPR_FILIAL "
		cQuery +=       " AND QQM_CHAVE = QPR_CHAVE "

		Self:cErrorMessage := STR0013 + cQuery //"Erro na execução da query: "

		cQuery := oQLTQueryM:changeQuery(cQuery)
		cAlias := oQLTQueryM:executeQuery(cQuery)

		Self:cErrorMessage := ""
		
		If lSucesso := (cAlias)->(!Eof())
			lSucesso := oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
		EndIf

		(cAlias)->(dbCloseArea())

	EndIf

Return lSucesso

/*/{Protheus.doc} RetornaListaDeAnexosDeUmaAmostraQIE
Retorna uma lista de anexos referentes a amostra 
@type method
@author brunno.costa
@since  31/10/2024
@param nRecnoQER, numérico, RECNO da amostra de resultados
@return lSucesso, lógico, indica se conseguiu retornar a lista
/*/
METHOD RetornaListaDeAnexosDeUmaAmostraQIE(nRecnoQER) CLASS AnexosInspecaoQualidadeAPI
	
	Local cAlias      := Nil
    Local cQuery      := ""
	Local lSucesso    := .F.
	Local nPagina     := 1
	Local nTamPag     := 999
	Local oAPIManager := QualityAPIManager():New(Self:MapeiaCamposQQM("*"), Self:oWSRestFul)
	Local oQLTQueryM  := QLTQueryManager():New()

	If Self:lTemQQM

		cQuery := " SELECT QQM_NOMEOR, "
		cQuery +=		 " RECNOQQM, "
		cQuery +=		 " QQM_MSUID, "
		cQuery += 		 " QQM_MIME, "
		cQuery += 		 " QQM_SIZE "
		cQuery += " FROM "
		cQuery +=  " (SELECT QER_FILIAL, "
		cQuery += 		   " QER_CHAVE "
		cQuery +=	" FROM " + RetSqlName("QER")
		cQuery +=	" WHERE R_E_C_N_O_ = '" + cValToChar(nRecnoQER) + "' "
		cQuery +=		  " AND D_E_L_E_T_ = ' ' ) QER "
		cQuery += " INNER JOIN "
		cQuery +=  " (SELECT QQM_FILQPR, "
		cQuery += 		   " QQM_CHAVE, "
		cQuery += 		   " R_E_C_N_O_ RECNOQQM, "
		cQuery +=		   " QQM_NOMEOR, "
		cQuery +=		   " QQM_MSUID, "
		cQuery += 		   " QQM_MIME, "
		cQuery += 		   " QQM_SIZE "
		cQuery += 	" FROM " + RetSqlName("QQM")
		cQuery += 	" WHERE D_E_L_E_T_ = ' ' "
		
		If Self:lTemQQMModulo
			cQuery += " AND QQM_MODULO  = 'QIE' "
		EndIf

		cQuery +=  " ) QQM ON QQM_FILQPR = QER.QER_FILIAL "
		cQuery +=       " AND QQM_CHAVE = QER_CHAVE "

		Self:cErrorMessage := STR0013 + cQuery //"Erro na execução da query: "

		cQuery := oQLTQueryM:changeQuery(cQuery)
		cAlias := oQLTQueryM:executeQuery(cQuery)

		Self:cErrorMessage := ""
		
		If lSucesso := (cAlias)->(!Eof())
			lSucesso := oAPIManager:ProcessaListaResultados(cAlias, nPagina, nTamPag)
		EndIf

		(cAlias)->(dbCloseArea())

	EndIf

Return lSucesso

/*/{Protheus.doc} RetornaAnexoAPartirDoRecnoDaQQM
Retorna anexo em base64 a partir do recno
@type method
@author brunno.costa
@since  31/10/2024
@param nRecnoQQM, numerico, RECNO do anexo 
@return lSucesso, lógico, indica se conseguiu retornar o anexo
/*/
METHOD RetornaAnexoAPartirDoRecnoDaQQM(nRecnoQQM) CLASS AnexosInspecaoQualidadeAPI

	Local cArquivo   := ""
	Local cBanco     := Upper(TcgetDB())
	Local cBase64    := Nil
	Local cPath      := AllTrim(SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\"))
	Local cResp      := Nil
	Local lSizeError := .F.
	Local lSucesso   := .F.
	Local lTemArqui  := .F.
	Local oResponse  := JsonObject():New()

	If Self:lTemQQM
		DbSelectArea("QQM")
		QQM->(DbGoTo(nRecnoQQM))

		If "ORACLE" $ cBanco
			cArquivo := Lower(AllTrim(TRANSFORM( Alltrim(QQM->QQM_MSUID),"@R ########-####-####-####-############") + "." + aTail(StrtoKarr(QQM->QQM_NOMEOR,"."))))
		Else
			cArquivo := AllTrim(Alltrim(QQM->QQM_MSUID) + "." + aTail(StrtoKarr(QQM->QQM_NOMEOR,".")))
		EndIf

		If Val(GetPvProfString( "GENERAL", "MAXSTRINGSIZE", "0", GetSrvIniName() )) < 100
			lSizeError := .T.
			//STR0015 "Vulneravilidade identificada no download de arquivos do APP Inspecao de Processos."
			//STR0014 "Informe na tag MaxStringSize do AppServer.Ini um valor igual ou superior a 100."
			FWLogMsg("WARN", "", "SIGAQIP", "AnexosInspecaoQualidadeAPI", "", "", STR0015 + STR0014, 0, 0) 
		EndIf

		If (lTemArqui := File(cPath + cArquivo))
			cBase64  := StartJob("QLT64Data", GetEnvServer(), .T., Lower( cPath + cArquivo ))
			lSucesso := !Empty(cBase64)
		EndIf


		If lSucesso
			Self:oWSRestFul:SetContentType("application/octet-stream")
			Self:oWSRestFul:SetResponse( cBase64 )
			HTTPSetStatus(200)

		Else
			Self:oWSRestFul:SetContentType("application/json")

			If lSizeError .AND. lTemArqui
				//STR0016 "Não foi possivel recuperar o arquivo selecionado."
				//STR0014 "Informe na tag MaxStringSize do AppServer.Ini um valor igual ou superior a 100."
				Self:cErrorMessage    := STR0016 + " " + STR0014
				Self:cDetailedMessage := STR0016 + " " + STR0014
			Else
				Self:cErrorMessage 	  := STR0016                           //"Não foi possivel recuperar o arquivo selecionado."
				Self:cDetailedMessage := Iif(!lTemArqui,STR0017 + cPath ,; //"Arquivo não localizado na pasta ##"
														STR0018)           //"Falha ao recuperar o arquivo."
			EndIf

			oResponse['code'         ] := 403
			oResponse['errorCode'    ] := 403
			oResponse['message'      ] := Self:cErrorMessage
			oResponse['errorMessage' ] := Self:cDetailedMessage
			cResp := EncodeUtf8(FwJsonSerialize( oResponse, .T. ))
			Self:oWSRestFul:SetResponse( cResp )

			SetRestFault(403, EncodeUtf8(Self:cErrorMessage), .T.,;
			             403, EncodeUtf8(Self:cDetailedMessage))
		EndIf
	EndIf
Return lSucesso

/*/{Protheus.doc} RetornaFotoRepositorioDeImagens
Retorna foto do repositório de imagens em base64 a partir do código
@type method
@author brunno.costa
@since  22/07/2025
@param cCodigo, caracter, codigo da foto no repositório de imagens
@return lSucesso, lógico, indica se conseguiu retornar o anexo
/*/
METHOD RetornaFotoRepositorioDeImagens(cCodigo) CLASS AnexosInspecaoQualidadeAPI

	Local cArquivo   := Lower(FWUUIDV4() + "_qlt_tmp.jpg")
	Local cBase64    := ""
	Local lSizeError := .F.
	Local lSucesso   := .F.
	Local lTemArqui  := .F.
	Local nErase     := Nil
	
	//Foi possivel extrair a imagem do repositorio
	If !Empty(cCodigo) .And. RepExtract(AllTrim(cCodigo), cArquivo)

		If Val(GetPvProfString( "GENERAL", "MAXSTRINGSIZE", "0", GetSrvIniName() )) < 100
			lSizeError := .T.
			//STR0015 "Vulneravilidade identificada no download de arquivos do APP Inspecao de Processos."
			//STR0014 "Informe na tag MaxStringSize do AppServer.Ini um valor igual ou superior a 100."
			FWLogMsg("WARN", "", "AnexosInspecaoQualidadeAPI", "AnexosInspecaoQualidadeAPI", "", "", STR0015 + STR0014, 0, 0) 
		EndIf

		If (lTemArqui := File("\system\" + cArquivo))
			cBase64   := StartJob("QLT64Data", GetEnvServer(), .T., Lower( "\system\" + cArquivo ))
			lSucesso  := !Empty(cBase64)
			nErase    := fErase("\system\" + cArquivo)
			// STR0020 "Falha"
			// STR0019 "na deleção do Arquivo"
			Iif(nErase == -1, FWLogMsg('INFO',, 'AnexosInspecaoQualidadeAPI', FunName(), '', '01', STR0020 + " '" + cValToChar(nErase) + "' " + STR0019 + " '" + cArquivo + "'." , 0, 0, {}), "")
		EndIf

	EndIf

	Self:oWSRestFul:SetContentType("application/octet-stream")
	Self:oWSRestFul:SetResponse( cBase64 )
	HTTPSetStatus(200)
	
Return lSucesso

/*/{Protheus.doc} QLT64Data
Thread Intermediária para tratamento de erro de binário devido MaxStringSize pequeno
@type function
@author brunno.costa
@since  31/10/2024
@param 01 - cFilePath, caminho do arquivo
@return cData64, caracter, dados do arquivo em Base64
/*/
Function QLT64Data(cFilePath)
Return StartJob("QLT64DataX", GetEnvServer(), .T., cFilePath)

/*/{Protheus.doc} QLT64DataX
Função que chama método do binário para retornar arquivo em base 64, utilizado em Thread para garantir continuidade no fluxo de execução principal
@type function
@author brunno.costa
@since  31/10/2024
@param 01 - cFilePath, caminho do arquivo
@return cData64, caracter, dados do arquivo em Base64
/*/
Function QLT64DataX(cFilePath)
Return Encode64(, cFilePath)

/*/{Protheus.doc} ExcluiAnexosERelacionamento
Exclui Anexos e relacionamentos relacionados a amostra QPR_CHAVE
@author brunno.costa
@since  31/10/2024
@param 01 - cFilQPR , caracter, filial do registro da QPR
@param 02 - cChave  , caracter, QPR_CHAVE relacionado ao anexo
@param 03 - cModulo , caracter, modulo de origem do vinculo
/*/
METHOD ExcluiAnexosERelacionamento(cFilQPR, cChave, cModulo) CLASS AnexosInspecaoQualidadeAPI

	Local cBanco      := Upper(TcgetDB())
	Local cFilQQM     := ""
	Local nMaximo     := 60 //60 * 10 = 600 segundos = 10 minutos
	Local nTentativas := 0

	Default cChave  := ""
	Default cFilQPR := ""

	Self:lTemQQM := Iif(Self:lTemQQM == Nil, !Empty(FWX2Nome( "QQM" )), Self:lTemQQM)
	If Self:lTemQQM
		cFilQQM     := xFilial("QQM")
		DbSelectArea("QQM")
		QQM->(DbSetOrder(1))
		If QQM->(DbSeek(cFilQQM + cFilQPR + cChave ))
			While !QQM->(Eof())            .AND.;
				QQM->QQM_FILIAL == cFilQQM .AND.;
				QQM->QQM_FILQPR == cFilQPR .AND.;
				QQM->QQM_CHAVE  == cChave

				If Self:lTemQQMModulo
					If     cModulo == "QIP" .AND. QQM->QQM_MODULO != cModulo .AND. !Empty(QQM->QQM_MODULO)
						QQM->(DbSkip())
						Loop
					ElseIf cModulo == "QIE" .AND. QQM->QQM_MODULO != cModulo
						QQM->(DbSkip())
						Loop
					EndIF
				EndIf

				While QQM->QQM_STATUP == "1" .AND. nTentativas < nMaximo
					Sleep(10000)//10 segundos
					nTentativas++
					QQM->(DbSeek(cFilQQM + cFilQPR + cChave ))
				EndDo

				If "ORACLE" $ cBanco
					Self:ExcluiArquivoAnexo(Lower(AllTrim(TRANSFORM( Alltrim(QQM->QQM_MSUID),"@R ########-####-####-####-############") + "." + aTail(StrtoKarr(QQM->QQM_NOMEOR,".")))))
				Else
					Self:ExcluiArquivoAnexo(Lower(AllTrim(QQM->QQM_MSUID) + "." + aTail(StrTokArr(AllTrim(QQM->QQM_NOMEOR), "."))))
				EndIf

				RecLock("QQM", .F.)
				QQM->(DbDelete())
				QQM->(MsUnlock())
				
				QQM->(DbSkip())
			EndDo
		EndIf
	EndIf

Return 

/*/{Protheus.doc} ExcluiArquivoAnexo
Exclui arquivo anexo
@author brunno.costa
@since  31/10/2024
@param 01 - cNome , caracter, nome do arquivo anexo com extensão
/*/
METHOD ExcluiArquivoAnexo(cNome) CLASS AnexosInspecaoQualidadeAPI
	Local cPath  := SuperGetMV("MV_QLDINSP", .F., "system\anexos_inspecao\")
	Local nErase := fErase(cPath + cNome)
	// STR0020 "Falha"
	// STR0019 "na deleção do Arquivo"
	Iif(nErase == -1, FWLogMsg('INFO',, 'SIGAQIP', FunName(), '', '01', STR0020 + " '" + cValToChar(nErase) + "' " + STR0019 + " '" + cPath + cNome + "'." , 0, 0, {}), "")
Return

/*/{Protheus.doc} DeletaAnexoAmostra
Chamado pelo Endpoint para exclusão do anexo da amostra
@author brunno.costa
@since  31/10/2024
@param 01 - nRecnoQQM, número  , RECNO do registro do anexo na tabela QQM
/*/
METHOD DeletaAnexoAmostra(nRecnoQQM) CLASS AnexosInspecaoQualidadeAPI

	Local cBanco     := Upper(TcgetDB())

	Self:oWSRestFul:SetContentType("")

	DbSelectArea("QQM")
	QQM->(DbGoTo(nRecnoQQM))

	If "ORACLE" $ cBanco
		Self:ExcluiArquivoAnexo(Lower(AllTrim(TRANSFORM( Alltrim(QQM->QQM_MSUID),"@R ########-####-####-####-############") + "." + aTail(StrtoKarr(QQM->QQM_NOMEOR,".")))))
	Else
		Self:ExcluiArquivoAnexo(Lower(AllTrim(QQM->QQM_MSUID) + "." + aTail(StrTokArr(AllTrim(QQM->QQM_NOMEOR), "."))))
	EndIf

	RecLock("QQM", .F.)
	QQM->(DbDelete())
	QQM->(MsUnlock())

	HTTPSetStatus(204)

Return

/*/{Protheus.doc} QLTExAAmIn
Exclui Arquivo Anexo relacionado a Amostra da Inspeção
@type  Function
@author brunno.costa
@since  31/10/2024
@param 01 - cEmpAux, caracter, empresa para abertura do ambiente
@param 02 - cFilAux, caracter, filial para abertura do ambiente
@param 03 - cFilQPR, caracter, filial do registro na QPR para exclusão
@param 04 - cChave , caracter, chave do registro da amostra na QPR
@param 05 - cModulo, caracter, modulo de origem
/*/
Function QLTExAAmIn(cEmpAux, cFilAux, cFilQPR, cChave, cModulo)
	
	Local oAnexos := Nil

	If FindClass(Upper("ResultadosEnsaiosInspecaoDeProcessosAPI"))
		//Seta job para nao consumir licenças
		RpcSetType(3)
		// Seta job para empresa filial desejada
		RpcSetEnv( cEmpAux, cFilAux,,, 'QIP')
		oAnexos := AnexosInspecaoQualidadeAPI():New(Nil)
		oAnexos:ExcluiAnexosERelacionamento(cFilQPR, cChave, cModulo)
		RpcClearEnv()
	EndIf
	
Return


/*/{Protheus.doc} QQMSTATUPD
Thread para atualização do status da tabela QQM - Sem consumir licença e sem travar retorno pro usuário
@type  Function
@author brunno.costa
@since  17/04/2025
@param 01 - cEmpAux     , caracter, empresa para abertura do ambiente
@param 02 - cFilAux     , caracter, filial para abertura do ambiente
@param 03 - cJsonContent, caracter, conteúdo em JSON
/*/
Function QQMSTATUPD(cEmpAux, cFilAux, cJsonContent)

	local cThReadID	:= threadID()
	Local oContent  := JsonObject():New()
	Local oAPIClass := Nil

	FWLogMsg('INFO',, 'QQMSTATUPD', "QQMSTATUPD", '', '01', "QQMSTATUPD - Inicio - " + Time() + " - " + str(cThReadID) , 0, 0, {})

	//Seta job para nao consumir licenças
	RpcSetType(3)

	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpAux, cFilAux,,, 'QIP')

	oContent:fromJson(cJsonContent)
	oAPIClass := AnexosInspecaoQualidadeAPI():New(Nil)
	oAPIClass:RegistraAnexo(oContent, "2")	

	RpcClearEnv()

	FWLogMsg('INFO',, 'QQMSTATUPD', "QQMSTATUPD", '', '01', "QQMSTATUPD - Termino - " + Time() + " - " + str(cThReadID) , 0, 0, {})
	
Return


