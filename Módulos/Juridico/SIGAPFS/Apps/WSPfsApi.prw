#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSPFSAPI.CH"

WSRESTFUL WSPfsApi DESCRIPTION STR0001 // "WebService para teste API"
	WSDATA pathArq      AS STRING
	WSDATA codDoc       AS STRING
	WSDATA codEntidade  AS STRING
	WSDATA nomeEnt      AS STRING
    WSDATA key          AS STRING
	WSDATA campoChave   AS STRING
	WSDATA mvcModel     AS STRING
	WSDATA xbAlias      AS STRING
	WSDATA searchKey    AS STRING
	WSDATA filtF3       AS STRING
	WSDATA filter       AS STRING
	WSDATA uf           AS STRING
	WSDATA tipo         AS STRING
	WSDATA cobravel     AS STRING
	WSDATA valorDig     AS STRING
	WSDATA codCliente   AS STRING
	WSDATA codCliLoja   AS STRING
	WSDATA tipoorig     AS STRING
	WSDATA participante AS STRING
	WSDATA filtFilial   AS STRING
	WSDATA rotina       AS STRING
	WSDATA extra        AS STRING
	WSDATA chaveEnt     AS STRING
	WSDATA entidade     AS STRING
	WSDATA filialLog    AS STRING
	WSDATA filialAnexo  AS STRING
	WSDATA tabela       AS STRING
	WSDATA chave        AS STRING
	WSDATA campos       AS STRING
	WSDATA isValid      AS STRING
	WSDATA isCustom     AS STRING
	WSDATA isTudo       AS STRING
	WSDATA ativo        AS BOOLEAN
	WSDATA camposAdc    AS BOOLEAN
	WSDATA bcoEscr      AS STRING
	WSDATA bcoPix       AS BOOLEAN
	WSDATA codLD        AS STRING
	WSDATA campo        AS STRING
	WSDATA fields       AS STRING

	// Métodos GET
	WSMETHOD GET DownloadFile       DESCRIPTION STR0002 PATH "legaldesk/anexo/download/{key}"                                                PRODUCES APPLICATION_JSON // "Download anexo via LegalDesk"
	WSMETHOD GET StructMVC          DESCRIPTION STR0021 PATH "mvc/struct/{MvcModel}"                                                         PRODUCES APPLICATION_JSON // "Busca a Estrutura do MVC"
	WSMETHOD GET existTab           DESCRIPTION STR0032 PATH "sx2/{key}"                                                                     PRODUCES APPLICATION_JSON // "Verifica se existe a tabela no ambiente"
	WSMETHOD GET gtSx3Data          DESCRIPTION STR0022 PATH "congen/sx3/{MvcModel}/{campoChave}"                                            PRODUCES APPLICATION_JSON // "Busca dados do campo"
	WSMETHOD GET getUsrLog          DESCRIPTION STR0047 PATH "getUsrLog"                                                                     PRODUCES APPLICATION_JSON // "Retorna o nome do usuário logado"
	WSMETHOD GET gtModelData        DESCRIPTION STR0023 PATH "congen/mvc/{mvcModel}"                                                         PRODUCES APPLICATION_JSON // "Busca os dados do modelo" 
	WSMETHOD GET getF3List          DESCRIPTION STR0024 PATH "getF3/{filtF3}/{xbAlias}"                                                      PRODUCES APPLICATION_JSON // 'Busca a lista de opções de um campo tipo F3'
	WSMETHOD GET getF3              DESCRIPTION STR0025 PATH "getF3/{filtF3}/{xbAlias}/{searchKey}"                                          PRODUCES APPLICATION_JSON // 'Busca o registro específico de um campo tipo F3'
	WSMETHOD GET CliJuri            DESCRIPTION STR0046 PATH "congen/cli"                                                                    PRODUCES APPLICATION_JSON // "Consulta de Clientes com complemento de clientes (NUH)"
	WSMETHOD GET listTipoAtDp       DESCRIPTION STR0042 PATH "listTipoAtDp"                                                                  PRODUCES APPLICATION_JSON // "Busca a lista de tipos de atividades não cobráveis e tipos de despesas não cobráveis"
	WSMETHOD GET listParticipantes  DESCRIPTION STR0043 PATH "listParticipantes"                                                             PRODUCES APPLICATION_JSON // "Busca a lista de participantes filtrando pelo tipo (1 - Funcionários Ativos, 2 - Sócios, 3 - Sócios ou Revisores, 4 - Assinam Fatura)"
	WSMETHOD GET listMunicipioporUF DESCRIPTION STR0044 PATH "listMunicipioporUF"                                                            PRODUCES APPLICATION_JSON // "Busca a lista de municípios de um estado específico"
	WSMETHOD GET listOriginacoes    DESCRIPTION STR0045 PATH "listOriginacoes"                                                               PRODUCES APPLICATION_JSON // "Busca a lista de originações (NRI) podendo filtrar somente as originações que são do tipo sócio."
	WSMETHOD GET GetAnexos          DESCRIPTION STR0048 PATH "getanexos/{chaveEnt}"                 WSSYNTAX "getanexos/{chaveEnt}"          PRODUCES APPLICATION_JSON // "Retorna arquivos anexados no cliente"
	WSMETHOD GET getDataTable       DESCRIPTION STR0049 PATH "getDataTable/{tabela}/{chave}"        WSSYNTAX "getDataTable/{tabela}/{chave}" PRODUCES APPLICATION_JSON // "Busca campos de um alias específico"
	WSMETHOD GET listCondPagamentos DESCRIPTION STR0052 PATH "listCondPagamentos"                   WSSYNTAX "listCondPagamentos"            PRODUCES APPLICATION_JSON // "Busca a lista de condições de pagamentos"
	WSMETHOD GET getTpRelFaturame   DESCRIPTION STR0058 PATH "getTpRelFaturame"                     WSSYNTAX "getTpRelFaturame"              PRODUCES APPLICATION_JSON // "Busca a lista do tipo de relatórios de faturamento"
	WSMETHOD GET getBancos          DESCRIPTION STR0061 PATH "getBancos"                            WSSYNTAX "getBancos"                     PRODUCES APPLICATION_JSON // "Busca a lista de bancos"
	WSMETHOD GET getMoedas          DESCRIPTION STR0063 PATH "getMoedas"                            WSSYNTAX "getMoedas"                     PRODUCES APPLICATION_JSON // "Busca a lista de moedas"
	WSMETHOD GET extFields          DESCRIPTION STR0068 PATH "extraFields"                          WSSYNTAX "extraFields"                   PRODUCES APPLICATION_JSON // "Lista dos campos obigatórios e customizados de uma tabela"
	WSMETHOD GET dataByCODLD        DESCRIPTION STR0070 PATH "dataByCODLD/{tabela}/{campo}/{codLD}" WSSYNTAX "dataByCODLD/{tabela}/{campo}/{codLD}" PRODUCES APPLICATION_JSON // "Busca registro a partir do campo _CODLD"

	// Métodos PUT
	WSMETHOD PUT cnvPfsTxt          DESCRIPTION STR0003 PATH "convert/txt"                                                                   PRODUCES APPLICATION_JSON // "Conversão de PDF para Texto"
	WSMETHOD PUT jVldCpo            DESCRIPTION STR0050 PATH "jVldCpo"                                                                       PRODUCES APPLICATION_JSON // "Valida se os campos existem no SX3"

	// Métodos POST
	WSMETHOD POST anxCreate         DESCRIPTION STR0005 PATH "anexo"                                                                         PRODUCES APPLICATION_JSON // "Cria anexo"
	WSMETHOD POST anxLdCreate       DESCRIPTION STR0005 PATH "legaldesk/anexo/upload"                                                        PRODUCES APPLICATION_JSON // "Cria anexo via LegalDesk"
	WSMETHOD POST fileImport        DESCRIPTION STR0005 PATH "arqretorno"                                                                    PRODUCES APPLICATION_JSON // "Importa arquivo de retorno do CNAB para o diretório da SEE do banco"
	WSMETHOD POST vinCa             DESCRIPTION STR0069 PATH "vincCasContr"                         WSSYNTAX "vincCasContr"                  PRODUCES APPLICATION_JSON // "Retorna se é possivel vincular o caso ao contrato"

	// Métodos DELETE
	WSMETHOD DELETE DeleteDoc       DESCRIPTION STR0006 PATH "anexos/{codDoc}"                                                               PRODUCES APPLICATION_JSON // "Exclusão do anexo"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET existTab 
Verifica se a tabela existe no Ambiente

@param key - Tabela a ser pesquisada

@author Willian.Kazahaya
@since 02/07/2021
@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/sx2/{key}

/*/
//-------------------------------------------------------------------
WSMETHOD GET existTab PATHPARAM key WSREST WsPfsApi
Local lTabInDic := .F.
Local oResponse := JsonObject():New()

	lTabInDic := FWAliasInDic(Self:key)
	oResponse['table'] := Self:key
	oResponse['exist'] := lTabInDic

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DownloadFile
Efetua o download do anexo selecionado

@param key - Chave da NUM a fazer download (NUM_FILIAL + NUM_COD) em base 64

@author Willian.Kazahaya
@since 00/00/2020
@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/legaldesk/anexo/donwload/{key}

/*/
//-------------------------------------------------------------------
WSMETHOD GET DownloadFile PATHPARAM key WSREST WSPfsApi
Local oAnexo      := Nil
Local lRet        := .T.
Local cTpAnexo    := ""
Local cEntidade   := ""
Local cCodEnt     := ""
Local cPathDown   := "\temp\"
Local cNomArq     := ""
Local nCodError   := 404 //Not Found
Local cMsgError   := STR0018 //"Chave primária inválida [#1]"
Local aDados	  := {}
Local cKey		  := Self:Key

	// Caso não tenha enviado o caminho do arquivo por queryParam
	If !Empty(cKey)
		cKey   := PadR(DeCode64(cKey), TamSx3("NUM_FILIAL")[1]+TamSx3("NUM_COD")[1])
		aDados := JurGetDados("NUM", 1, cKey, {"NUM_ENTIDA", "NUM_CENTID", "NUM_NUMERO","NUM_DESC", "NUM_DOC", "NUM_EXTEN"})
		
		If Len(aDados) > 0
			cTpAnexo  := AllTrim(SuperGetMv('MV_JDOCUME',, '2'))
			cEntidade := aDados[01]
			cCodEnt   := aDados[02]
			cNumero   := aDados[03]

			If !Empty(aDados[04])
				cNomArq := AllTrim(aDados[04])
			Else
				cNomArq := AllTrim(aDados[05]) + AllTrim(aDados[06])
			EndIf 
			oAnexo   := JPFSGetAnx(cEntidade, cCodEnt)

			If cTpAnexo == '2' //Base de Conhecimento
				
				cPathDown += AllTrim(cNumero)+"\"
				cPathArq := cPathDown + cNomArq

				// Verifica se a pasta temporária está criada, caso não, cria a pasta
				If CreatePathDown(@cPathDown) .And. !Empty(cPathArq)
					oAnexo:lSalvaTemp := .F.

					If lRet := oAnexo:Exportar("", cPathDown, cNumero, cNomArq)
						//Manda o arquivo
						lRet := JRespDown(Self, cPathArq)

						If lRet
							//Apaga o arquivo e o diretório criados temporariamente
							fErase(cPathArq)
							DirRemove(cPathDown)
						EndIf
					Else
						nCodError := 500
						cMsgError := STR0019 //"Não foi possível localizar o arquivo" '
						SetRestFault(nCodError, JConvUTF8(cMsgError))
					EndIf
				Else
					lRet := .F.
					nCodError := 500
					cMsgError := I18N(STR0020, {cPathDown,cValToChar(FError())}) //"Não foi possível criar a pasta #1 Erro: #2"
				EndIf
			Else
				lRet := .F.
				nCodError := 500
			    cMsgError := STR0019 //"Não foi possível localizar o arquivo"
				SetRestFault(nCodError, JConvUTF8(cMsgError))
			EndIf
		Else
			lRet := .F.
			cMsgError := I18N(cMsgError , {cKey}) //"Chave primária inválida [#1]"
			SetRestFault(nCodError, JConvUTF8(cMsgError))
		EndIf
	Else
		lRet := .F.
		cMsgError := I18N(cMsgError , {cValToChar(cKey)}) //"Chave primária inválida [#1]"
		SetRestFault(nCodError, JConvUTF8(cMsgError))
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GET StructMVC
Endpoint de busca da estrutura do MVC

@param mvcModel - Path - Fonte MVC a ser chamado

@author Willian.Kazahaya
@since 21/05/2021
@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/mvc/struct/{MvcModel}
/*/
//-------------------------------------------------------------------
WSMETHOD GET StructMVC PATHPARAM mvcModel WSREST WsPfsApi
Local lRet       := .T.
Local oResponse  := nil
Local mvcModel   := Self:mvcModel

	If !Empty(mvcModel)
		oResponse := JW77StrMdl(mvcModel, '')
		If ValType(oResponse) == "J"
			Self:SetContentType("application/json")
			Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		Else
			lRet := .F.
		EndIf
	Else
		lRet := setRespError(404, STR0027) // "É necessário passar o modelo a ser consultado."
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GET getF3
Busca a lista de dados da consulta do F3

@param  filtF3    Filtro adicional a ser aplicado, 
					'0' para não aplicar filtro
					'O0A_CCAUSA='001'condição sql para aplicar filtro
@param  xbAlias   Alias do campo procurado na SXB
@param  searchKey Código do registro a ser buscado
@return .T.       Lógico

@author Willian.Kazahaya
@since 21/05/2021

@example GET -> http://127.0.0.1:12173/rest/WSPfsApi/getF3/0/NRBJUR
@example GET -> http://127.0.0.1:12173/rest/WSPfsApi/getF3/O0A_CCAUSA=%27005%27/O0A
/*/
//-------------------------------------------------------------------
WSMETHOD GET getF3 PATHPARAM xbAlias, searchKey, filtF3  WSREST WsPfsApi
Local oResponse := JsonObject():New()
Local cXBAlias  := Self:xbAlias
Local cIdReg    := Self:searchKey
Local aOptions  := {}
Local nPos      := 0

	If Empty(cXBAlias)
		cXBAlias := ''
	EndIf

	aOptions := WPfsBscF3( cXBAlias ,,self:filtF3)

	Self:SetContentType("application/json")

	// Busca por código
	If !Empty(cIdReg)
		nPos := aScan(aOptions,{|x|  Lower(JurLmpCpo(cIdReg)) == Lower(JurLmpCpo(x[1])) })

		If(nPos > 0 ) 
			oResponse['value'] := aOptions[nPos][1]
			oResponse['label'] := jConvUTF8(aOptions[nPos][2])
		EndIf
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getF3List
Busca um determinado registro da lista do F3.
@param  filtF3    Filtro adicional a ser aplicado, 
					'0' para não aplicar filtro
					'O0A_CCAUSA='001'condição sql para aplicar filtro
@param  xbAlias    Alias do campo procurado na SXB
@param  rotina     Indica a rotina que fez a chamada
@param  extra      Indica um campon extra a ser retornado da busca
@param  filter     Filtro da busca de dados da lista F3.
@return .T.        Lógico

@author Willian.Kazahaya
@since 21/05/2021

@example GET -> http://127.0.0.1:12173/rest/WSPfsApi/getF3/NRBJUR
@example GET -> http://127.0.0.1:12173/rest/WSPfsApi/getF3/O0A_CCAUSA=%27005%27/O0A
/*/
//-------------------------------------------------------------------
WSMETHOD GET getF3List PATHPARAM xbAlias, filtF3, rotina, extra WSRECEIVE filter  WSREST WsPfsApi
Local oResponse  := JsonObject():New()
Local cXBAlias   := Self:xbAlias
Local cFilter    := Self:filter
Local cRotina    := self:rotina
Local cTableA    := ""
Local cCpoChaveA := ""
Local cCpoBuscaA := ""
Local cTableB    := ""
Local cCpoChaveB := ""
Local cCpoDescB  := ""
Local aOptions   := {}
Local nI         := 0

Default cRotina := ""
Default cExtra  := ""

	If Empty(cXBAlias)
		cXBAlias := ''
	EndIf

	If cRotina == "TIMESHEETS" .AND. cXBAlias $ "RD0"
		cExtra := "RD0_SIGLA"
	EndIf

	// Tratamento para combo de clientes na tela de TimeSheets
	If FindFunction("JQryCombo") .AND. cRotina == "TIMESHEETS" .AND. cXBAlias $ "SA1|NVE"
	
		If cXBAlias == "SA1" // Clientes
			cExtra := "A1_LOJA"
			self:filtF3 += " AND SA1.A1_LOJA = NUH.NUH_LOJA "
			cTableA    := "NUH"
			cCpoChaveA := "A1_COD"
			cCpoBuscaA := "NUH_COD"
			cTableB    := "SA1"
			cCpoChaveB := "A1_COD"
			cCpoDescB  := "A1_NOME"

		ElseIf cXBAlias == "NVE" // Casos
			cTableA    := "SA1"
			cCpoChaveA := "NVE_NUMCAS"
			cCpoBuscaA := "A1_COD"
			cTableB    := "NVE"
			cCpoChaveB := "NVE_CCLIEN"
			cCpoDescB  := "NVE_TITULO"
		EndIf

		aOptions := JQryCombo(cTableA, cCpoChaveA, cCpoBuscaA, cTableB, cCpoChaveB, cCpoDescB, cFilter, self:filtF3, .F., cExtra)
	Else
		aOptions := WPfsBscF3( cXBAlias, cFilter, self:filtF3, cExtra )
	EndIf

	Self:SetContentType("application/json")
	oResponse['items'] := {} 

	For nI := 1 To Len(aOptions)
		Aadd(oResponse['items'], JsonObject():New())
		aTail(oResponse['items'])['value'] := aOptions[nI][1]
		aTail(oResponse['items'])['label'] := jConvUTF8(aOptions[nI][2])

		If Len(aOptions[nI]) > 2
			aTail(oResponse['items'])['extra'] := AllTrim(aOptions[nI][3])
		Else
			aTail(oResponse['items'])['extra'] := ""
		EndIf

		If(nI = 30)
			Exit
		EndIf

	Next nI

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET gtSx3Data
Busca os dados do SX3 do campo informado
@param campoChave - Path - Campo a ser buscado no SX3

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/congen/sx3/{campoChave}

@author Willian Kazahaya
@since 07/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET gtSx3Data PATHPARAM campoChave, MvcModel WSREST WSPfsApi
Local aFieldsMdl := {}
Local oResponse  := JsonObject():New()
Local oFieldMdl  := ""
Local cCampo     := Self:campoChave
Local cModelo    := Self:MvcModel
Local tamSx3Res  := Tamsx3(cCampo)
Local lRet       := .T.

	If (Len(tamSx3Res) < 3 .Or. Empty(cCampo))
		lRet := setRespError(400, STR0028) //"O campo informado não existe na tabela!"
	Else
		oFieldMdl := JW77StrMdl(cModelo, cCampo)

		If (Len(oFieldMdl['struct'][1]['fields']) > 0)
			aFieldsMdl := oFieldMdl['struct'][1]['fields'][1]:GetNames()


			oResponse['SX3'] := JsonObject():New()
			oResponse['SX3']['titulo'] := JConvUTF8(GetSx3Cache(UPPER(oFieldMdl['struct'][1]['fields'][1]['field']),'X3_TITULO'))
			oResponse['SX3']['tamanho'] := oFieldMdl['struct'][1]['fields'][1]['size']
			oResponse['SX3']['decimal'] := oFieldMdl['struct'][1]['fields'][1]['decimal']
			oResponse['SX3']['tipo'] := oFieldMdl['struct'][1]['fields'][1]['type']

			If (oResponse['SX3']['tipo'] == "L")
				lRet := setRespError(400, STR0033) //"Campos lógicos não podem ser utilizados como filtro!"
			ElseIf (!Empty(GetSx3Cache(cCampo, 'X3_CBOX')))
				lRet := setRespError(400, STR0034) // "Campos combo não podem ser utilizados como filtro!"
			ElseIf (!Empty(GetSx3Cache(cCampo, 'X3_F3')))
				lRet := setRespError(400, STR0035) //"Campos de consulta a outras tabelas não podem ser utilizados como filtro!"
			ElseIf(GetSx3Cache(cCampo, 'X3_CONTEXT') == "V")
				lRet := setRespError(400, STR0041) //"Campos virtuais não podem ser utilizados como filtro!"
			Else 
				Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
			EndIf
		Else
			lRet := setRespError(400,  I18N(STR0036 , {cCampo})) //"O campo #1 não existe no modelo selecionado!"
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET gtSx3Data
Busca os dados do SX3 do campo informado
@param campoChave - Path - Campo a ser buscado no SX3

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/congen/mvc/{nomeModelo}

@author Willian Kazahaya
@since 07/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET gtModelData PATHPARAM mvcModel WSREST WSPfsApi
Local oResponse := JsonObject():New()
Local cModelo   := Self:mvcModel
Local oModel    := Nil
Local lRet      := .T.

	If (Empty(cModelo))
		lRet := setRespError(400, STR0029) //"Informe um modelo!"
	Else
		cModelo := UPPER(cModelo)
		oResponse['MVC'] := JsonObject():New()
		
		oResponse['MVC']['codigo'] := cModelo

		oModel := FwLoadModel(cModelo)
		If (ValType(oModel) != "O")
			lRet := setRespError(400, STR0030) //"O modelo informado não é MVC!"
		Else
			oResponse['MVC']['descricao'] := JConvUTF8(oModel:GetDescription())
			Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST anxLdCreate
Cria o anexo na pasta do Spool para o LegalDesk

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/legaldesk/anexo/upload
/*/
//-------------------------------------------------------------------
WSMETHOD POST anxLdCreate WSREST WSPfsApi
Local oRequest   := JSonObject():New()
Local oResponse  := JsonObject():New()
Local nMsgCode   := 400
Local cMsgErro   := ""
Local cEntidade  := ""
Local cCodEnt    := ""
Local cArquivo   := ""
Local aInfoBody  := {}
Local aResp      := {}
Local lCadAnxNUM := .F.
Local lRet       := .T.

	cArquivo := JWSRecFile(Self:GetContent(), HTTPHeader("content-type"), @oRequest)

	If oRequest:ToJson() != "{}"
		If VALTYPE( oRequest['entidade']) <> "U"
			cEntidade := oRequest['entidade']
		EndIf

		If VALTYPE( oRequest['codEntidade']) <> "U"
			cCodEnt   := oRequest['codEntidade']
		EndIf
	EndIf

	// Cria o anexo na Protheus_data
	If lRet .AND. !Empty(cArquivo) .AND. !Empty(cEntidade) .AND. !Empty(cCodEnt)

		If Empty(cMsgErro)
			// Verifica se irá cadastrar na NUM
			lCadAnxNUM := !Empty(cEntidade) .AND. !Empty(cCodEnt)
		
			If lCadAnxNUM

				If Empty(cMsgErro) .AND. !Empty(cEntidade) .AND. !Empty(cCodEnt)
					aResp := J026Anexar(cEntidade, xFilial(cEntidade), cCodEnt, "", cArquivo, .T.)

					If (aResp[1]) 
						oResponse['result'] := STR0016 //"Anexo copiado com sucesso." 
						oResponse['entityNUM'] := JSonObject():New() 
						oResponse['entityNUM']['id']     := aResp[3] 
						oResponse['entityNUM']['status'] := "CREATED" 
					Else 
						oResponse['result'] := JConvUTF8(aResp[2]) // Erro da criação da NUM
						oResponse['entityNUM'] := JSonObject():New() 	
						oResponse['entityNUM']['status'] := "ERROR" 
						oResponse['entityNUM']['id']     := ""							
					EndIf
				EndIf
			EndIf 
		EndIf
	
	ElseIf (!Empty(cEntidade) .AND. Empty(cCodEnt)) .OR. (Empty(cEntidade) .AND. !Empty(cCodEnt))
		cMsgErro := STR0038 // "A entidade e/ou código da entidade não foram informados"
		lRet := .F.

	Else
		oResponse['result']              := STR0016 // "Anexo copiado com sucesso."
		oResponse['entityNUM']           := JSonObject():New()
		oResponse['entityNUM']['id']     := ""
		oResponse['entityNUM']['status'] := "NOT_CREATED"
	EndIf

	If lRet
		Self:SetResponse(oResponse:toJson()) 
	Else 
		If !Empty(cMsgErro)
			SetRestFault(nMsgCode, JConvUTF8(cMsgErro)) 
		EndIf
	EndIf

	oResponse:FromJSon("{}")
	oResponse := NIL

	aSize(aInfoBody, 0)
	aSize(aResp, 0)
	aResp     := Nil
	aInfoBody := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET CliJuri
Consulta de Cliente ativo com NUH vinculada

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/congen/cli
@param valorDig    - Optional - Valor digitado no campo
@param codCliente  - Optional - Código do Cliente
@param codCliLoja  - Optional - Loja do Cliente
@param filtFilial  - Optional - Indica se filtra Filial com xFilial
@param camposAdc   - Optional - Indica se trata campos adicionais
                                da query.
@author Willian Kazahaya
@since 06/04/2020
/*/
//-------------------------------------------------------------------
WSMethod GET CliJuri QUERYPARAM valorDig, codCliente, codCliLoja, filtFilial, camposAdc, tipo WSREST WSPfsApi
Local oResponse  := JSonObject():New()
Local oCliente   := Nil
Local aArea      := GetArea()
Local aQuery     := {}
Local aParams    := {}
Local cAlias     := ""
Local cQuery     := ""
Local nIndexJSon := 0
Local nParam     := 0
Local cSearchKey := Self:valorDig
Local cCodigo    := Self:codCliente
Local cLoja      := Self:codCliLoja
Local lcpoAdici  := Self:camposAdc
Local lFiltFil   := Self:filtFilial != 'false'
Local cPerfil    := Self:tipo

Default cCodigo    := ""
Default cLoja      := ""
Default cSearchKey := ""
Default lcpoAdici  := .F.
Default cPerfil    := ""
	
	// Monta a Query
	aQuery := JCliQry(cSearchKey, cCodigo, cLoja, lFiltFil, , , , , lcpoAdici, cPerfil)
	cQuery  := aQuery[1]
	aParams := aQuery[2]
	cAlias  := GetNextAlias()

	oCliente := FWPreparedStatement():New(cQuery)
	
	oResponse := {}

	For nParam := 1 To Len(aParams)
		If ValType(aParams[nParam]) == "C"
			oCliente:SetString(nParam, aParams[nParam])
		ElseIf ValType(aParams[nParam]) == "A"
			oCliente:SetIn(nParam, aParams[nParam])
		EndIf
	Next
	
	cQuery := oCliente:GetFixQuery()
	MpSysOpenQuery(cQuery, cAlias)
	
	// Monta o response
	While !(cAlias)->(Eof()) .And. nIndexJSon < 10
		nIndexJSon++
		Aadd(oResponse, JsonObject():New())

		oResponse[nIndexJSon]['codigo']          := (cAlias)->(A1_COD)
		oResponse[nIndexJSon]['loja']            := (cAlias)->(A1_LOJA)
		oResponse[nIndexJSon]['nome']            := JConvUTF8((cAlias)->(A1_NOME))
		oResponse[nIndexJSon]['SiglaSocCliente'] := JConvUTF8((cAlias)->(RD0_SIGLA))
		If lcpoAdici
			oResponse[nIndexJSon]['escritorioFaturamento'] := JConvUTF8((cAlias)->(NUH_CESCR2))
			oResponse[nIndexJSon]['idiomaRelatorio']       := JConvUTF8((cAlias)->(NUH_CIDIO))
			oResponse[nIndexJSon]['tabelaHonorario']       := JConvUTF8((cAlias)->(NUH_CTABH))
			oResponse[nIndexJSon]['discriminaDespesas']    := JConvUTF8((cAlias)->(NUH_DSPDIS))
			oResponse[nIndexJSon]['numCaso']               := JConvUTF8(JA070NUMER((cAlias)->(A1_COD), (cAlias)->(A1_LOJA)))
			oResponse[nIndexJSon]['usaEbiling']            := JConvUTF8((cAlias)->(NUH_UTEBIL))
			oResponse[nIndexJSon]['codSocCliente']         := JConvUTF8((cAlias)->(NUH_CPART))
			oResponse[nIndexJSon]['codTpFech']             := JConvUTF8((cAlias)->(NUH_TPFECH))
			oResponse[nIndexJSon]["codDocEbil"]            := JConvUTF8(JurGetDados("NRX", 1, xFilial("NRX") + (cAlias)->NUH_CEMP, "NRX_CDOC"))
		EndIf
		(cAlias)->( dbSkip() )
	End
	oCliente:Destroy()
	( cAlias )->( dbCloseArea() )

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := NIL

	RestArea(aArea)
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST anxCreate
Cria o anexo

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/anexo

@author Willian Kazahaya
@since  05/03/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST anxCreate WSREST WSPfsApi
Local lRet         := .T.
Local aRetAnexo    := {}
Local oRequest     := JsonObject():New()
Local cArquivo     := ""
Local cEntidade    := ""
Local cCodEnt      := ""

	cArquivo := JWSRecFile(Self:GetContent(), HTTPHeader("content-type"), @oRequest)

	lRet := !Empty(cArquivo)

	If oRequest:ToJson() != "{}"
		If VALTYPE( oRequest['entidade']) <> "U"
			cEntidade := oRequest['entidade']
		EndIf

		If VALTYPE( oRequest['codEntidade']) <> "U"
			cCodEnt   := oRequest['codEntidade']
		EndIf

		If !Empty(cArquivo) .AND. !Empty(cEntidade) .AND. !Empty(cCodEnt)
			aRetAnexo := J026Anexar(cEntidade, xFilial(cEntidade), cCodEnt, "", cArquivo, .T.)
			
			If Len(aRetAnexo) == 3 .And. aRetAnexo[1] == .F. .And. !Empty(aRetAnexo[2])
				SetRespError(400, aRetAnexo[2])
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE DeleteDoc
Deleta documentos anexados.

@param codDoc      - String com os NUM_COD concatenados por virgula

@example [Sem Opcional] DELETE -> http://127.0.0.1:9090/rest/WSPfsApi/anexo

@author Willian.Kazahaya
@since 06/01/2021
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE DeleteDoc PATHPARAM codDoc WSREST WSPfsApi
Local cCodDoc    := Self:codDoc
Local oResponse  := JsonObject():New()
Local lRet       := {}
Local aCodNUM    := StrToArray( cCodDoc, ',' )
Local nI         := 0
Local nIndexJSon := 0
Local cEntidade  := ""
Local cCodEnt    := ""
Local cNameDoc   := ""

	oResponse['operation'] := "DeleteDocs"
	Self:SetContentType("application/json")
	oResponse['attachments'] := {}

	for nI := 1 to Len(aCodNUM)
		cNameDoc  := AllTrim(JurGetDados("NUM", 1, xFilial("NUM") + AllTrim(aCodNUM[nI]), "NUM_DESC"))
		cEntidade := AllTrim(JurGetDados("NUM", 1, xFilial("NUM") + AllTrim(aCodNUM[nI]), "NUM_ENTIDA"))
		cCodEnt   := AllTrim(JurGetDados("NUM", 1, xFilial("NUM") + AllTrim(aCodNUM[nI]), "NUM_CENTID"))

		lRet := deleteDocs(aCodNUM[nI], cEntidade, cCodEnt)

		nIndexJSon++
		Aadd(oResponse['attachments'], JsonObject():New())

		If lRet
			oResponse['attachments'][nIndexJSon]['isDelete']    := .T.
			oResponse['attachments'][nIndexJSon]['codDocument'] := aCodNUM[nI]
			oResponse['attachments'][nIndexJSon]['nameDocument'] := JConvUTF8(cNameDoc)
		EndIf
	Next nI

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT cnvPfsTxt
Converte o PDF para TXT

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/convert/txt

/*/
//-------------------------------------------------------------------
WSMETHOD PUT cnvPfsTxt WSREST WSPfsApi
Local oResponse := JsonObject():New()
Local oJSonBody := JsonObject():New()
Local cBody     := ""
Local itens     
Local lRet      := .T.

	cBody  := StrTran(Self:GetContent(),CHR(10),"")
	oJSonBody:fromJson(cBody)
	itens := oJSonBody:getNames()

	oResponse['texto'] := getText(oJsonBody:getJsonObject("file"))
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} deleteDocs
Função responsável por chamar a função da classe de anexo para deletar os documentos

@param cCodDoc     - Codigo do documento para pesquisa de Doc especifica
@param entidade    - Alias da entidade
@param codEntidade - Codigo da entidade

@since 06/01/2021
/*/
//-------------------------------------------------------------------
Static Function deleteDocs(cCodDoc, cEntidade, cCodEnt)
	Local lRet    := .F.
	Local cParam  := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
	Local oAnexo  := JPFSGetAnx(cEntidade, cCodEnt)

	Do Case
		Case cParam == '2' //Base de Conhecimento
			lRet :=  oAnexo:DeleteNUM(cCodDoc)
		Case cParam == '3' //Fluig
			lRet :=  oAnexo:Excluir(cCodDoc)
	EndCase

	FwFreeObj(oAnexo)
	oAnexo := Nil
return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getText(filePath)
Executa o pdfToText no arquivo pdf

@param filePath - Caminho do PDF a ser convertido

@since 06/01/2021
/*/
//-------------------------------------------------------------------
Static function getText(filePath)
	Local cMarca    := GetMark()
	Local cParams    := "-raw -nopgbrk -enc UTF-8"
	Local cNomeTxt  := "inicial_" + Lower(cMarca) + ".txt"
	Local cSpool    := "/spool/"
	Local cFile     := ""
	Local aLinhas   := {}
	Local nI        := 0
	Local cRootPath := GetSrvProfString("RootPath","") //Pega o conteúdo da chave RootPath do arquivo appserver.ini
	Local cCmd      := ""
	Local cInicTxt  := ""
	Local cMsgErro  := ""
	Local oTxt      := Nil
	Local cArquivo  := ""
	
	//Pega o nome do arquivo
	If rAt('\',cDirPdf) == 0
		cArquivo := SubStr(cDirPdf,rAt('/',cDirPdf)+1)
	Else
		cArquivo := SubStr(cDirPdf,rAt('\',cDirPdf)+1)
	Endif

	If At(':\',cDirPdf) > 0//valida se a inicial ja esta no root do servidor
		If CpyT2S(cDirPdf,cSpool) //Faz a cópia do arquivo para o servidor
			cDirPdf   := cRootPath + cSpool + cArquivo
		Endif
	Else
		cDirPdf := cRootPath + Replace(cDirPdf,'/','\') //substitui / por \ pois o \spool pode ser escrito das duas formas
	Endif
	
	//Monta o comando para ser executado via terminal
	DO CASE
		CASE "Windows" $ GetSrvInfo()[2]
			cDirPdf := cRootPath + cSpool + cArquivo
			cCmd    := 'pdftotext.exe ' + cParams + ' "'+cDirPdf+'" ' + cNomeTxt
			cFile   := cSpool + cNomeTxt

		CASE "Linux" $ GetSrvInfo()[2]
			cSpool  := "/spool/"
			cDirPdf := cRootPath + cSpool + cArquivo
			cCmd    := 'pdftotext ' + cParams + ' "'+cDirPdf+'" ' + cNomeTxt
			cFile   := cSpool + cNomeTxt
	END CASE
	//Monta o comando para ser executado via terminal

	cCmd    := 'pdftotext.exe ' + cParams + ' "'+filePath+'" ' + cNomeTxt
	cFile   := cSpool + cNomeTxt

	If  WaitRunSrv(cCmd, .T., cRootPath + cSpool) //Executa o comando para converter o PDF em TXT
		If File(cFile)
			oTxt := FWFileReader():New(cFile) //Cria um objeto file para realizar a leitura do arquivo TXT convertido
			If (oTxt:Open())
				If oTxt:hasLine()
					aLinhas := oTxt:getAllLines() //Transforma todas as linhas do arquivo em um array
					For nI := 1 To Len(aLinhas)
						cInicTxt += aLinhas[nI] + CRLF
					Next
					oTxt:Close()
				Else
					cMsgErro := JurMsgErro(STR0009,STR0010,STR0011)//("Não foi possível carregar o arquivo" ,"WSPfsApi","Verifique se o documento selecionado está correto") 
				Endif
			Endif
		Else 
			VarInfo("File não encontrado", cFile)
		Endif
	Else
		cMsgErro := JurMsgErro(STR0009,STR0010,STR0012) //("Não foi possível carregar o arquivo","WSPfsApi","Verifique se o executável pdftotext.exe se encontra na pasta do AppServer") 
	Endif

Return cInicTxt

//-------------------------------------------------------------------
/*/{Protheus.doc} JRespDown
Realiza a transmissão do documento

@param oWs       - Objeto do WS
@param cPathDown - caminho do arquivo a ser transferido
@since 07/10/2020

/*/
//-------------------------------------------------------------------
Function JRespDown(oWs, cPathArq)
Local lRet      := .T.
Local cNomeArq  := ""
Local cBuffer   := ""
Local nHandle   := 0
Local nBytes    := 0

Default cPathArq := "''"

	If File(cPathArq)
		cNomeArq := SubStr(cPathArq, Rat("/",cPathArq)+1)
		cNomeArq := SubStr(cNomeArq, Rat("\",cNomeArq)+1)
		oWs:SetContentType("Application/octet-stream")
		oWs:SetHeader("Content-Disposition",'attachment; filename="'+cNomeArq+'"')
		nHandle := FOPEN(cPathArq)  // Grava o ID do arquivo

		If nHandle > -1
			While (nBytes := FREAD(nHandle, @cBuffer, 524288)) > 0      // Lê os bytes
				oWs:SetResponse(cBuffer)
			EndDo

			FCLOSE(nHandle)
			lRet := .T.
		Else
			SetRestFault(500, JConvUTF8(STR0013)) //"Erro ao ler o arquivo"
		EndIf
	Else
		lRet := .F.
		SetRestFault(404, JConvUTF8(STR0007)) //"Arquivo não existe."
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFSGetAnx(cEntidade, cCodEnt,cCodProc)
Função responsável por identificar qual anexo está sendo utilizado para instanciar a classe

@param cEntidade    - Alias da entidade
@param cCodEnt      - Codigo da entidade
@param cCodProc     - Codigo do processo

@since 06/01/2020

/*/
//-------------------------------------------------------------------
Function JPFSGetAnx(cEntidade, cCodEnt, cCodProc)
Local cParam  := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
Local oAnexo  := Nil
Local nIndice := 1
Local lEntPFS := .T. // Indica se é entidade do SIGAPFS

Default cEntidade := ""
Default cCodEnt   := ""
Default cCodProc  := ""

	Do Case
	Case cParam == '1'
		oAnexo := TJurAnxWork():New(STR0014, cEntidade, xFilial(cEntidade), cCodEnt, nIndice /* nIndice */ , .F., lEntPFS) // "WorkSite"
	Case cParam == '2'
		oAnexo := TJurAnxBase():NewTHFInterface(cEntidade, cCodEnt, cCodProc, lEntPFS) // "Base de Conhecimento"
	Case cParam == '3'
		oAnexo := TJurAnxFluig():New(STR0015, cEntidade, xFilial(cEntidade), cCodEnt, nIndice, .F.) // "Documentos em Destaque - Fluig"
	EndCase
return oAnexo

//-----------------------------------------------------------------
/*/{Protheus.doc} CreatePathDown
Função responsavel pela criação do caminho da pasta /thf/download/

@param cPathDown - Caminho para criar a pasta de download
@since 27/07/2020
/*/
//-----------------------------------------------------------------
Static Function CreatePathDown(cPathDown)
	Local lRet     := .T.
	Local aAuxPath := nil
	Local cPathAux := ""
	Local cSlash   := If("Linux" $ GetSrvInfo()[2],'/','\')
	Local n1       := 0

	// Tratamento para S.O Linux
	If "Linux" $ GetSrvInfo()[2]
		cPathDown := StrTran(cPathDown,"\","/")
	Endif

	If !ExistDir(cPathDown)
		aAuxPath := Separa(cPathDown,cSlash)
		For n1 := 1 To Len(aAuxPath)
			If Empty(aAuxPath[n1])
				loop
			Endif

			cPathAux += cSlash+aAuxPath[n1]

			If !ExistDir(cPathAux)
				If MakeDir(cPathAux) <> 0
					lRet := .F.
					exit
				Endif
			Endif
		Next

		//Redundancia para garantir que a pasta foi criada depois de realizar a criação
		lRet := lRet .and. ExistDir(cPathDown)

		aSize(aAuxPath,0)
		aAuxPath := nil
	EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} JConvUTF8(cValue)
Converte o Texto para UTF8, removendo os CRLF por || e removendo os espaços laterais

@param cValue - Valor a ser formatado
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function JConvUTF8(cValue)
	Local cReturn := ""
	cReturn := StrTran(EncodeUTF8(Alltrim(cValue)), CRLF, "||")
Return cReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} JW77StrMdl
Busca da estrutura de uma determinada rotina. 

@param  cRotina: Nome da rotina em mvc para buscar a estrutura
@return oResponse - Objeto json com a estrutura da rotina

@author Willian Kazahaya
@since 12/05/2021
/*/
//-------------------------------------------------------------------
Function JW77StrMdl(cRotina, cNomeCampo)
Local oResponse  := nil
Local oView      := nil
Local oModel     := nil
Local aModels    := nil
Local aMdlFields := nil
Local aViewField := nil
Local aAuxFlds   := nil
Local aAuxCbox   := nil
Local aOptions   := nil
Local cF3        := ''
Local lCanChange := .T.
Local lHasXENum  := .F.
Local nPos       := 1
Local nI         := 1
Local nX         := 1
Local nZ         := 1
Local lCodManual := .F.
Local cCpoCodMan := "NUO_COD|" // Campos de códigos digitáveis

Default cRotina    := ''
Default cNomeCampo := ''

	If !Empty(cRotina)
		oView  := FwLoadView(cRotina)
		If ValType(oView) == "O"
			oModel := oView:GetModel()

			oResponse := JsonObject():New()
			oResponse['title']   := JConvUTF8(oView:GetDescription())
			oResponse['struct']  := {}
			oResponse['modelId'] := oModel:GetId()

			aModels := oModel:GetAllSubModels()

			For nI := 1 To Len(aModels)
				aViewField := {}

				aAdd(oResponse['struct'],JsonObject():New())
				aTail(oResponse['struct'])['id']   := aModels[nI]:GetId() //nome modelo
				aTail(oResponse['struct'])['type'] := aModels[nI]:ClassName() //Field/Grid
				aTail(oResponse['struct'])['fields'] := {}

				aAuxFlds   := aTail(oResponse['struct'])['fields']

				aMdlFields := aModels[nI]:GetStruct():GetFields()

				If aScan(oView:GetModelsId(),aModels[nI]:GetId()) > 0
					aViewField := aClone(oView:GetViewStruct(aModels[nI]:GetId()):GetFields())
				Endif
				
				If (!Empty(cNomeCampo) .And. aScan(aMdlFields, {|x| x[3] == cNomeCampo }) == 0)
					Loop
				EndIf

				For nX := 1 To Len(aMdlFields)
					If (Empty(cNomeCampo) .Or. (!Empty(cNomeCampo) .And. aMdlFields[nX][3] == cNomeCampo))
						cF3         := ''
						aOptions    := Nil
						lCanChange  := .T.
						nPos        := 0
						lCodManual  := AllTrim(aMdlFields[nX][3]) $ cCpoCodMan

						If !Empty(aMdlFields[nX][11])
							lHasXENum := AT('GETSXENUM',UPPER(GetCbSource(aMdlFields[nX][11]))) > 0
						Else
							lHasXENum := .F.
						Endif

						If Len(aViewField) > 0
							nPos      := aScan(aViewField,{|x| x[1] == aMdlFields[nX][3] })
						Endif
						
						If nPos > 0
							cF3        := aViewField[nPos][9]
							lCanChange := aViewField[nPos][10]

							If Len(aViewField[nPos][13]) > 0
								aOptions := {}

								For nZ := 1 to Len(aViewField[nPos][13])

									If Empty(aViewField[nPos][13][nZ]) .Or. At('=',aViewField[nPos][13][nZ]) == 0
										loop
									Endif

									aAdd(aOptions,JsonObject():New())
									aAuxCbox := Separa(aViewField[nPos][13][nZ],'=')
									aTail(aOptions)['value'] := aAuxCbox[1]
									aTail(aOptions)['label'] := JConvUTF8(aAuxCbox[2])
								Next
							EndIf
						EndIf

						aAdd(aAuxFlds,JsonObject():New())

						aTail(aAuxFlds)['field']         := aMdlFields[nX][3]
						aTail(aAuxFlds)['description']   := JConvUTF8(aMdlFields[nX][1])
						aTail(aAuxFlds)['type']          := aMdlFields[nX][4]
						aTail(aAuxFlds)['size']          := aMdlFields[nX][5]
						aTail(aAuxFlds)['decimal']       := aMdlFields[nX][6]
						aTail(aAuxFlds)['filter']        := AllTrim(cF3)
						aTail(aAuxFlds)['options']       := aOptions
						aTail(aAuxFlds)['isBrowse']      := getSx3Cache(aMdlFields[nX][3],'X3_BROWSE') == 'S'
						aTail(aAuxFlds)['isRequired']    := aMdlFields[nX][10]
						aTail(aAuxFlds)['isView']        := nPos > 0
						aTail(aAuxFlds)['isVirtual']     := getSx3Cache(aMdlFields[nX][3],'X3_CONTEXT') == 'V'
						aTail(aAuxFlds)['hasSequencial'] := lHasXENum
						aTail(aAuxFlds)['canChange']     := lCanChange
						aTail(aAuxFlds)['hasCodManual']  := lCodManual
					EndIf
				Next
			Next

			oView:Destroy()
			FwFreeObj(oView)
		Else
			setRespError(404, STR0037 )//'O modelo informado não contem view configurada! Favor verificar.'
		Endif

		oView := nil
	Endif
Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} WPfsBscF3
Retorna a lista de dados do F3 de campos customizados.

@param cF3:        Nome do XB_ALIAS que foi cadastrado para o campo customizado
@param cSearchKey: Conteúdo de busca
@param cFiltro:    Adiciona uma condição na busca dos dados
@param cExtra:     Indica campo extra a ser retornado na busca
@return aRet - Lista com os dados de retorno do F3
@since 02/09/2020
/*/
//-------------------------------------------------------------------
Static Function WPfsBscF3( cF3, cSearchKey, cfiltro, cExtra )
Local aArea      := GetArea()
Local cAlias     := ''
Local cQuery     := ''
Local cTabela    := ''
Local cChave     := ''
Local cLabel     := ''
Local cChvAuxSX5 := ''
Local cChaveSX5  := ''
Local nIndex     := 0
Local nPosCp     := 0
Local lContinua  := .F.
Local lSX5       := .F.
Local aRet       := {}
Local aStructF3  := {}

Default cFiltro := ""
Default cExtra  := ""

	//-- Busca as informações da consulta no SXB
	If !Empty(cF3)

		DbSelectArea("SXB")
		DbSetOrder(1) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA

		cF3:= PadR( cF3, 6 )

		If DbSeek( cF3  + '1' + '01' )
			cTabela := ALLTRIM(SXB->XB_CONTEM)
		EndIf

		lSX5 := cTabela == 'SX5' .Or. Len(AllTrim(cF3)) == 2

		While (SXB->XB_ALIAS == cF3)

			If SXB->XB_TIPO == '5'
				If Empty(cChave)
					cChave := ALLTRIM(SXB->XB_CONTEM)
				else
					cChave += " + " + ALLTRIM(SXB->XB_CONTEM)
				EndIf

			ElseIf lSX5 .And. SXB->XB_TIPO == '2'
				nIndex := At('jursxb(', Lower(SXB->XB_CONTEM))

				If nIndex > 0
					cChvAuxSX5 := SubStr(SXB->XB_CONTEM, nIndex + 8) 
					cChaveSX5 += SubStr(cChvAuxSX5 , 0, At(',', Lower(cChvAuxSX5)) - 2)
				EndIf
			EndIf
			SXB->(DbSkip())
		End

		SXB->(DbCloseArea())

		If (!Empty(cTabela) .And. !Empty(cChave)) .Or. Len(AllTrim(cF3)) == 2
			If !lSX5
				aStructF3 := FWSX3Util():GetAllFields(cTabela, .F.)

				//-- Busca campos que possuem _NOME ou _DESC, senão usa terceira coluna da tabela
				nPosCp := aScan( aStructF3, { |x| '_NOME' $ x } )

				If nPosCp <= 0
					nPosCp := aScan( aStructF3, { |x| '_DESC' $ x } )
				EndIf

				If nPosCp > 0
					cLabel := aStructF3[nPosCp]
				Else
					cLabel := aStructF3[3]
				EndIf
			Else
				If Empty(cTabela) .And. Len(AllTrim(cF3)) == 2
					cTabela = 'SX5'
					cChave := 'X5_CHAVE'
					lContinua := .T.
				EndIf

				Do Case
					Case FwRetIdiom() == "pt-br"
						cLabel := 'X5_DESCRI'

					Case FwRetIdiom() == "en"
						cLabel := 'X5_DESCENG'

					Case FwRetIdiom() == "es"
						cLabel := 'X5_DESCSPA'
				EndCase
			EndIf

			//-- Tratamento para retorno da consulta
			cChave := STRTRAN(cChave, cTabela + "->")

			If Substr(cTabela, 1, 1) == "S"
				cFilS := Substr(cTabela, 2) + "_FILIAL"
				If Substr(cTabela, 2) == SubStr(cChave, 1, 2)
					lContinua := .T.
				EndIf

			Else
				cFilS := cTabela + "_FILIAL"
				If Substr(cTabela, 1, 3) == SubStr(cChave, 1, 3)
					lContinua := .T.
				EndIf
			EndIf

			cChave := STRTRAN(cChave, " + ", " || ")

			//-- Busca os dados
			If lContinua

				cQuery := " SELECT " + cChave + " CHAVE, "
				cQuery +=        " " + cLabel + " LABEL  "

				If !Empty(cExtra)
					cQuery +=        " , " + cExtra + " EXTRA "
				EndIf

				cQuery += " FROM " + RetSqlName(cTabela) + " "
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery +=     " AND " + cFilS + " = '" + xFilial(cTabela) + "' "

				If !Empty(cSearchKey)
					cSearchKey := StrTran(cSearchKey,'-',' ')
					cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey, .F.), '#', ''))
					cQuery +=     " AND " +  JurFormat(cLabel, .T., .T.) + " LIKE '%" + cSearchKey + "%' "
				EndIf

				If cFiltro != '0'
					cQuery += " AND " + cFiltro
				EndIf

				If lSX5
					cQuery += " AND X5_TABELA = '" + IIF(!Empty(cChaveSX5), cChaveSX5, cF3) + "'"
				EndIf

				cQuery := ChangeQuery(cQuery)

				cAlias := GetNextAlias()
				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

				While !(cAlias)->(Eof())
					If !Empty(cExtra)
						aAdd( aRet, { (cAlias)->(CHAVE), (cAlias)->(LABEL), (cAlias)->(EXTRA) } )
					Else
						aAdd( aRet, { (cAlias)->(CHAVE), (cAlias)->(LABEL), "" } )
					EndIf
					(cAlias)->(DbSkip())
				End

				(cAlias)->(DbCloseArea())
			EndIf

		EndIf

	EndIf
	restArea(aArea)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} setRespError(nCodHttp, cErrMessage)
Padroniza a resposta sempre convertendo o texto para UTF-8

@param nCodHttp - Código HTTP
@param cErrMessage - Mensagem de erro a ser convertido

@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function setRespError(nCodHttp, cErrMessage)
	SetRestFault(nCodHttp, JConvUTF8(cErrMessage), .T.)
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} POST fileImport
Importar aquivo de retorno do CNAB para o diretório do Banco na SEE

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/arqretorno

@author reginaldo.borges
@since  03/05/2023
/*/
//-------------------------------------------------------------------
WSMETHOD POST fileImport WSREST WSPfsApi
Local lRet        := .T.
Local oRequest    := JsonObject():New()
Local aCodEnt     := {}
Local cChvBanco   := ""
Local cDirPag     := ""
Local cFilBanco   := ""
Local cArquivo    := ""
Local cArqSpool   := ""
Local nTamCodBco  := TamSX3("EE_CODIGO")[1]
Local nTamAgeBco  := TamSX3("EE_AGENCIA")[1]
Local nTamContBco := TamSX3("EE_CONTA")[1]
Local nTamSubBco  := TamSX3("EE_SUBCTA")[1]

	cArquivo := JWSRecFile(Self:GetContent(),  HTTPHeader("content-type"), @oRequest)

	If oRequest:ToJson() != "{}"
		If VALTYPE( oRequest['filialBanco']) <> "U"
			cFilBanco := oRequest['filialBanco']
		EndIf

		If VALTYPE( oRequest['codBanco']) <> "U"
			aCodEnt := oRequest['codBanco']
		EndIf

		If !Empty(cFilBanco) .AND. Len(aCodEnt) > 0
			cChvBanco := PADR(aCodEnt[2], nTamCodBco) +;
						PADR(Substr(aCodEnt[4], 1, At('-', aCodEnt[4]) - 1 ), nTamAgeBco) +;
						PADR(Substr(aCodEnt[6], 1, At('-', aCodEnt[6]) - 1 ), nTamContBco) +;
						PADR(aCodEnt[8], nTamSubBco)

			cDirPag := AllTrim(JurGetDados("SEE", 1, cFilBanco + cChvBanco, "EE_DIRPAG"))

			// Copia o arquivo para o diretório configurado no parâmetros de banco (EE_DIRPAG)
			If !Empty(cArquivo)
				cArqSpool := cDirPag + Substr(cArquivo, Rat('\', cArquivo) + 1, Len(cArquivo))
				lRet := __copyfile( cArquivo, cArqSpool )
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET listTipoAtDp
Consulta de Grid de tipos de exceção de valor hora por tipo de atividade

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/listTipoAtDp

@param cobravel - 1 = Sim / 2 = Não / 3 = Ambos
@param tipo     - 1 = Tipo de Atividade / 2 - Tipo de Despesa / 3 = Ambos
@param valordig - Valor digitado na pesquisa

@author Jorge Martins
@since  01/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET listTipoAtDp QUERYPARAM cobravel, tipo, valordig WSREST WSPfsApi
Local oResponse  := JSonObject():New()
Local cCobravel  := Self:cobravel
Local cTipo      := Self:tipo
Local cSearchKey := Self:valordig

	cCobravel  := IIf(Empty(cCobravel) , "3", cCobravel)
	cTipo      := IIf(Empty(cTipo)     , "3", cTipo)
	cSearchKey := IIf(Empty(cSearchKey), "" , cSearchKey)
	oResponse  := {}

	Aadd(oResponse, JsonObject():New())

	oResponse := JGtTpAtDp(cCobravel, cTipo, cSearchKey)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtTpAtDp
Consulta de Grid de tipos de atividades e tipos de despesas não cobráveis

@param cCobravel  - Optional - Indica se os tipos de atividades e despesas são cobráveis 
                             - 1 = Sim / 2 = Não / 3 = Ambos
@param cTipo      - Optional - Indica qual tipo será filtrado 
                             - 1 = Tipo de Atividade / 2 - Tipo de Despesa / 3 = Ambos
@param cSearchKey - Optional - Valor para pesquisa

@author Jorge Martins
@since  20/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGtTpAtDp(cCobravel, cTipo, cSearchKey)
Local oTpAtDp    := Nil
Local aTpAtDp    := {}
Local aParams    := {}
Local cQueryAtiv := ""
Local cQueryDesp := ""
Local cAliasQry  := ""
Local cQuery     := " SELECT * FROM ( "
Local nIndJson   := 0
Local nParam     := 0

	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo(cSearchKey, .F.),'#',''))
	EndIf

	// Query de tipo de atividade
	cQueryAtiv :=  " SELECT '1' TIPO, NRC_FILIAL FILIAL, NRC_COD CODTIPO, NRC_DESC DESCTIPO "
	cQueryAtiv +=    " FROM " + RetSqlName("NRC") + " NRC"
	cQueryAtiv +=   " WHERE NRC.NRC_FILIAL = ? "
	cQueryAtiv +=     " AND NRC.NRC_ATIVO = '1' "
	If cCobravel <> "3"
		cQueryAtiv += " AND NRC.NRC_TEMPOZ = ? "
	EndIf
	cQueryAtiv +=     " AND NRC.D_E_L_E_T_ = ' ' "

	// Pesquisa por valor digitado
	If !Empty(cSearchKey)
		cQueryAtiv += " AND ( " + JurFormat("NRC_COD", .T.,.T., "NRC") + " LIKE ?"
		cQueryAtiv +=         " OR " + JurFormat("NRC_DESC", .T.,.T., "NRC") + " LIKE ?"
		cQueryAtiv +=      ")"
	EndIf

	// Query de tipo de despesa
	cQueryDesp :=  " SELECT '2' TIPO, NRH_FILIAL FILIAL, NRH_COD CODTIPO, NRH_DESC DESCTIPO"
	cQueryDesp +=    " FROM " + RetSqlName("NRH") + " NRH"
	cQueryDesp +=   " WHERE NRH.NRH_FILIAL = ? "
	cQueryDesp +=     " AND NRH.NRH_ATIVO = '1' "
	If cCobravel <> "3"
		cQueryDesp += " AND NRH.NRH_COBRAR = ? "
	EndIf
	cQueryDesp +=     " AND NRH.D_E_L_E_T_ = ' ' "

	// Pesquisa por valor digitado
	If !Empty(cSearchKey)
		cQueryDesp += " AND ( " + JurFormat("NRH_COD", .T.,.T., "NRH") + " LIKE ?"
		cQueryDesp +=         " OR " + JurFormat("NRH_DESC", .T.,.T., "NRH") + " LIKE ?"
		cQueryDesp +=        ")"
	EndIf

	If cTipo == "1" // Tipo de atividade
		cQuery += cQueryAtiv

		AAdd(aParams, xFilial("NRC"))
		IIf(cCobravel <> "3", AAdd(aParams, cCobravel), Nil)
		IIf(!Empty(cSearchKey), aAdd(aParams, "%" + cSearchKey + "%"), Nil)
		IIf(!Empty(cSearchKey), aAdd(aParams, "%" + cSearchKey + "%"), Nil)
	
	ElseIf cTipo == "2" // Tipo de despesa
		cQuery += cQueryDesp

		AAdd(aParams, xFilial("NRH"))
		IIf(cCobravel <> "3", AAdd(aParams, cCobravel), Nil)
		IIf(!Empty(cSearchKey), aAdd(aParams, "%" + cSearchKey + "%"), Nil)
		IIf(!Empty(cSearchKey), aAdd(aParams, "%" + cSearchKey + "%"), Nil)
	
	Else // Ambos
		cQuery += cQueryAtiv
		cQuery += " UNION ALL "
		cQuery += cQueryDesp

		AAdd(aParams, xFilial("NRC"))
		IIf(cCobravel <> "3", AAdd(aParams, cCobravel), Nil)
		IIf(!Empty(cSearchKey), aAdd(aParams, "%" + cSearchKey + "%"), Nil)
		IIf(!Empty(cSearchKey), aAdd(aParams, "%" + cSearchKey + "%"), Nil)

		AAdd(aParams, xFilial("NRH"))
		IIf(cCobravel <> "3", AAdd(aParams, cCobravel), Nil)
		IIf(!Empty(cSearchKey), aAdd(aParams, "%" + cSearchKey + "%"), Nil)
		IIf(!Empty(cSearchKey), aAdd(aParams, "%" + cSearchKey + "%"), Nil)

	EndIf

	cQuery += " ) A"

	cQuery  := ChangeQuery(cQuery)

	oTpAtDp := FWPreparedStatement():New(cQuery)

	For nParam := 1 To Len(aParams)
		oTpAtDp:SetString(nParam, aParams[nParam])
	Next

	cAliasQry := GetNextAlias()
	cQuery    := oTpAtDp:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aTpAtDp, JSonObject():New())

		aTpAtDp[nIndJson]['chaveNRCNRH']       := Encode64((cAliasQry)->FILIAL + (cAliasQry)->CODTIPO)
		aTpAtDp[nIndJson]['tipo']              := JConvUTF8((cAliasQry)->TIPO)
		aTpAtDp[nIndJson]['codtpativdesp']     := JConvUTF8((cAliasQry)->CODTIPO)
		aTpAtDp[nIndJson]['destpativdesp']     := JConvUTF8((cAliasQry)->DESCTIPO)
		(cAliasQry)->(dbSkip())
	EndDo
	oTpAtDp:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aTpAtDp

//-------------------------------------------------------------------
/*/{Protheus.doc} GET listParticipantes
Consulta de Participantes, podendo:
- Filtrar por tipo ou; 
- Filtrar participantes válidos para um determinado tipo de originação

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/listParticipantes

@param tipo     - 1 - Funcionários Ativos
                  2 - Sócios
                  3 - Sócios ou Revisores
                  4 - Assinam Fatura
@param tipoorig - Tipo de originação
@param searchKey- Palavra a ser pesquisada no nome do participante

@author Jorge Martins
@since  22/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET listParticipantes QUERYPARAM tipo, tipoorig, searchKey WSREST WSPfsApi
Local cTipo      := IIf(Empty(Self:tipo)    , "", Self:tipo)
Local cTipoOrig  := IIf(Empty(Self:tipoorig), "", Self:tipoorig)
Local cSearchKey := IIf(Empty(Self:searchKey), "", Self:searchKey)
Local cIncSocio  := ""
Local oResponse  := {}

	If Empty(cTipo) .And. Empty(cTipoOrig)
		cTipo := "1"
	ElseIf Empty(cTipo) .And. !Empty(cTipoOrig)
		cIncSocio := JurGetDados('NRI', 1, xFilial('NRI') + cTipoOrig, 'NRI_INCSOC')
		cTipo     := IIf(cIncSocio == "1", "3", "1")
	EndIf

	Aadd(oResponse, JsonObject():New())

	oResponse := JGtPartic(cTipo, cSearchKey)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtPartic
Consulta de Participantes, podendo filtrar por tipo

@param cTipo    - Optional - Indica o tipo do participante
                          1 - Funcionários Ativos
                          2 - Sócios
                          3 - Sócios ou Revisores
                          4 - Assinam Fatura
@param searchKey - Optional - Palavra a ser pesquisada no nome do participante

@author Jorge Martins
@since  22/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGtPartic(cTipo, cSearchKey)
Local aParticip := {}
Local cAliasQry := GetNextAlias()
Local cQuery    := JQRYRD0AT(cTipo, Nil, Nil, cSearchKey)
Local nIndJson  := 0

	dbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliasQry, .T., .F. )

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aParticip, JSonObject():New())

		aParticip[nIndJson]['chaveRD0'] := Encode64(xFilial("RD0") + (cAliasQry)->RD0_CODIGO)
		aParticip[nIndJson]['codigo']   := JConvUTF8((cAliasQry)->RD0_CODIGO)
		aParticip[nIndJson]['nome']     := JConvUTF8((cAliasQry)->RD0_NOME)
		aParticip[nIndJson]['sigla']    := JConvUTF8((cAliasQry)->RD0_SIGLA)

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

Return aParticip

//-------------------------------------------------------------------
/*/{Protheus.doc} GET listMunicipioporUF
Consulta de municípios por estado

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/listMunicipioporUF

@param uf        - Sigla do estado (Ex: SP)
@param searchKey - Palavra a ser pesquisada no código ou nome do município

@author Jorge Martins
@since  22/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET listMunicipioporUF QUERYPARAM uf, searchKey WSREST WSPfsApi
Local cUF       := IIf(Empty(Self:uf), "", Self:uf)
Local cSearchKey       := IIf(Empty(Self:searchKey), "", Self:searchKey)
Local oResponse := {} 

	Aadd(oResponse, JsonObject():New())

	oResponse := JGtMunicUF(cUF, cSearchKey)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtMunicUF
Consulta de municípios por estado

@param cUF       - Sigla do estado (Ex: SP)
@param searchKey - Palavra a ser pesquisada no código ou nome do município

@author Jorge Martins
@since  22/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGtMunicUF(cUF, cSearchKey)
Local aMunicipio := {}
Local oMunicipio := Nil
Local cAliasQry  := GetNextAlias()
Local cQuery     := ""
Local nParam     := 0
Local nIndJson   := 0

	cQuery := " SELECT CC2.CC2_FILIAL,"
	cQuery +=        " CC2.CC2_CODMUN,"
	cQuery +=        " CC2.CC2_MUN,"
	cQuery +=        " CC2.CC2_EST"
	cQuery +=   " FROM " + RetSqlName("CC2") + " CC2"
	cQuery +=  " WHERE CC2.CC2_FILIAL = ?"
	If !Empty(cUF)
		cQuery += " AND CC2.CC2_EST = ?"
	EndIf
	cQuery +=     " AND CC2.D_E_L_E_T_ = ' '"
	If !Empty(cSearchKey)
		cSearchKey := StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' )
		cQuery += " AND (LOWER(CC2_CODMUN) LIKE ?" // "%" + Lower(Trim(cSearchKey)) + "%"
		cQuery += " OR LOWER(?) LIKE ?)" // JurFormat("CC2_MUN", .T./*lAcentua*/), "") - Lower(Trim(cSearchKey)), "")
	EndIf
	cQuery +=  " ORDER BY CC2.CC2_MUN"

	oMunicipio := FWPreparedStatement():New(cQuery)
	oMunicipio:SetString(++nParam, xFilial("CC2"))
	
	If !Empty(cUF)
		oMunicipio:SetString(++nParam, cUF)
	EndIf

	If !Empty(cSearchKey)
		oMunicipio:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
		oMunicipio:SetUnsafe(++nParam, JurFormat("CC2_MUN", .T./*lAcentua*/))
		oMunicipio:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
	EndIf

	cQuery := oMunicipio:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aMunicipio, JSonObject():New())

		aMunicipio[nIndJson]['chaveCC2']     := Encode64((cAliasQry)->CC2_FILIAL + (cAliasQry)->CC2_EST + (cAliasQry)->CC2_CODMUN)
		aMunicipio[nIndJson]['codmunicipio'] := JConvUTF8((cAliasQry)->CC2_CODMUN)
		aMunicipio[nIndJson]['municipio']    := JConvUTF8((cAliasQry)->CC2_MUN)
		aMunicipio[nIndJson]['uf']           := JConvUTF8((cAliasQry)->CC2_EST)

		(cAliasQry)->(dbSkip())
	EndDo
	oMunicipio:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aMunicipio

//-------------------------------------------------------------------
/*/{Protheus.doc} GET listOriginacoes
Consulta de Originações, podendo: 
- Filtrar somente as originações que são do tipo sócio;
- Filtrar as originações válidas para um determinado participante;
- Filtrar se retorna somente originações ativas

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/listOriginacoes

@param tipo          - 1 - Somente Sócios
                       2 - Funcionários Ativos
@param participante  - Código do participante (para filtro da questão de ser sócio)
@param ativo         - .T. - Somente originações ativas / .F. Todas as originações
@param tipoorig      - Define em qual cadastro a originação pode ser utilizada.
                       1 - Cliente
                       2 - Caso
                       3 - Ambos (Pode ser utilizada no cadastro do cliente e caso)

@author Abner Fogaça
@since  27/09/2023
/*/
//-------------------------------------------------------------------
WSMethod GET listOriginacoes QUERYPARAM tipo, participante, ativo, tipoorig WSREST WSPfsApi
Local cTipo     := IIf(Empty(Self:tipo), "", Self:tipo)
Local cPart     := IIf(Empty(Self:participante), "", Self:participante)
Local cTipoOrig := IIf(Empty(Self:tipoorig), "", Self:tipoorig)
Local lAtivo    := IIf(Empty(Self:ativo), .F., .T.)
Local lSocio    := .F.
Local oResponse := {}
	
	If Empty(cTipo) .And. !Empty(cPart)
		lSocio := JurGetDados("NUR", 1, xFilial("NUR") + cPart, "NUR_SOCIO") == "1"
		cTipo  := IIf(lSocio, "", "2")
	EndIf
	
	Aadd(oResponse, JsonObject():New())

	oResponse := JGtOrig(cTipo, lAtivo, cTipoOrig)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtOrig
Consulta de Participantes, podendo filtrar por tipo

@param cTipo     - Opcional - Indica se é:
                              1 - Somente originações de sócios
                              2 - Todas as originações
@param lAtivo    - Opcional - .T. - Somente originações ativas / .F. Todas as originações
@param cTipoOrig - Opcional - Define em qual cadastro a originação pode ser utilizada.
                              1 - Cliente
                              2 - Caso
                              3 - Ambos (Pode ser utilizada no cadastro do cliente e caso)
@author Abner Fogaça
@since  27/09/2023
/*/
//-------------------------------------------------------------------
Static Function JGtOrig(cTipo, lAtivo, cTipoOrig)
Local oTpOrig   := Nil
Local aListOrig := {}
Local aTpOrig   := StrToArray(cTipoOrig, ",")
Local aParams   := {}
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local nIndJson  := 0
Local nParam    := 0

	cQuery :=  " SELECT NRI.NRI_FILIAL,"
	cQuery +=         " NRI.NRI_COD,"
	cQuery +=         " NRI.NRI_DESC,"
	cQuery +=         " NRI.NRI_INCSOC,"
	cQuery +=         " NRI.NRI_PRAZOV,"
	cQuery +=         " NRI.NRI_ATIVO"
	cQuery +=    " FROM " + RetSqlName("NRI") + " NRI"
	cQuery +=   " WHERE NRI.NRI_FILIAL = ?"
	If !Empty(cTipo)
		cQuery += " AND NRI.NRI_INCSOC = ?"
	EndIf
	If lAtivo
		cQuery += " AND NRI.NRI_ATIVO = '1'"
	EndIf
	If !Empty(cTipoOrig)
		cQuery += " AND NRI.NRI_TIPO IN (?)"
	EndIf
	cQuery +=     " AND NRI.D_E_L_E_T_ = ' '"
	cQuery +=   " ORDER BY NRI.NRI_COD"

	aAdd(aParams, xFilial("NRI"))
	If !Empty(cTipo)
		aAdd(aParams, cTipo)
	EndIf
	If !Empty(cTipoOrig)
		aAdd(aParams, aTpOrig)
	EndIf
	
	oTpOrig := FWPreparedStatement():New(cQuery)
	
	For nParam := 1 To Len(aParams)
		If ValType(aParams[nParam]) == "C"
			oTpOrig:SetString(nParam, aParams[nParam])
		ElseIf ValType(aParams[nParam]) == "A"
			oTpOrig:SetIn(nParam, aParams[nParam])
		EndIf
	Next

	cQuery := oTpOrig:GetFixQuery()

	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aListOrig, JSonObject():New())

		aListOrig[nIndJson]['chaveNRI']       := Encode64((cAliasQry)->NRI_FILIAL + (cAliasQry)->NRI_COD)
		aListOrig[nIndJson]['codigo']         := JConvUTF8((cAliasQry)->NRI_COD)
		aListOrig[nIndJson]['descricao']      := JConvUTF8((cAliasQry)->NRI_DESC)
		aListOrig[nIndJson]['somentesocio']   := JConvUTF8((cAliasQry)->NRI_INCSOC)
		aListOrig[nIndJson]['quantidadedias'] := JConvUTF8(cValToChar((cAliasQry)->NRI_PRAZOV))
		aListOrig[nIndJson]['ativo']          := JConvUTF8((cAliasQry)->NRI_ATIVO)

		(cAliasQry)->(dbSkip())
	EndDo
	oTpOrig:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aListOrig

//-------------------------------------------------------------------
/*/{Protheus.doc} getUsrLog
Retorna o nome do usuário logado.

@author Abner Fogaça
@since  27/10/2023
@obs    Exemplo de uso, campo NVE_USUINC
/*/
//-------------------------------------------------------------------
WSMETHOD GET getUsrLog WSREST WSPfsApi
Local oResponse := JSonObject():New()
Local cCodUser  := USRRETNAME(__CUSERID)

	Self:SetContentType("application/json")
	
	oResponse['user'] := cCodUser
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := NIL
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getAnexos
Busca os Anexos vinculados a um cliente

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/getanexos/{chaveEnt}/entidade='{entidade}'

@param chaveEnt   - PathParam  - Chave da entidade referente ao anexo
@param Entidade    - QueryParam - Entidade a ser pesquisada
@param filialLog   - QueryParam - Filial que está logada
@param filialAnexo - QueryParam - Filial do cliente

@author Abner Fogaça
@since  03/10/2023
/*/
//-------------------------------------------------------------------
WSMethod GET GetAnexos PATHPARAM chaveEnt QUERYPARAM entidade, filialLog, filialAnexo WSREST WSPfsApi
Local oAnexos    := Nil
Local oResponse  := JSonObject():New()
Local cChaveEnt  := Alltrim(Decode64(Self:chaveEnt))
Local cEntidade  := AllTrim(Self:entidade)
Local cCpoFilEnt    := Iif(Substr(cEntidade,1,1) == 'S', Substr(cEntidade,2), cEntidade) + "_FILIAL"
Local cFilialLog := Iif(!Empty(xFilial('NUM')), IIf(ValType(Self:filialLog) == 'U', Space(TamSX3(cCpoFilEnt)[1]), Self:filialLog), xFilial('NUM'))
Local cFilEnt    := IIf(ValType(Self:filialAnexo) == 'U', Space(TamSX3(cCpoFilEnt)[1]), Self:filialAnexo)
Local cAliasNUM  := ""
Local cQuery     := ""
Local nIndex     := 0
Local nParam     := 0
Local lRet       := .T.

	cQuery += "SELECT NUM_FILIAL, NUM_FILENT, NUM_COD, NUM_DOC, NUM_EXTEN, NUM_CENTID, NUM_DESC, NUM_ENTIDA, NUM_DTINCL "
	cQuery += "  FROM " + RetSqlName( 'NUM' ) + " NUM "
	cQuery += " WHERE NUM_FILIAL = ? "
	If !Empty(Self:filialAnexo)
		cQuery += "   AND NUM_FILENT = ? "
	EndIf
	cQuery += "   AND NUM_ENTIDA = ? "
	cQuery += "   AND NUM_CENTID = ? "
	cQuery += "   AND NUM.D_E_L_E_T_ = ' ' "

	cAliasNUM := GetNextAlias()
	
	oResponse['anexos'] := {}
	
	oAnexos := FWPreparedStatement():New(cQuery)

	oAnexos:SetString(++nParam, cFilialLog)
	If !Empty(Self:filialAnexo)
		oAnexos:SetString(++nParam, cFilEnt)
	EndIf
	oAnexos:SetString(++nParam, cEntidade)
	oAnexos:SetString(++nParam, PadR(cChaveEnt, TamSX3('NUM_CENTID')[1]))
	
	cQuery := oAnexos:GetFixQuery()
	
	MpSysOpenQuery(cQuery, cAliasNUM)
	
		
	While (cAliasNUM)->(!Eof())
		nIndex++
		aAdd(oResponse["anexos"], JsonObject():New())
		oResponse["anexos"][nIndex]["filialAnexo"]     := (cAliasNUM)->(NUM_FILIAL) // Não colocar o JConvUTF8 na filial pois ele corta o espaço vazio da filial no final da string.
		oResponse["anexos"][nIndex]["filialEntidade"]  := (cAliasNUM)->(NUM_FILENT)
		oResponse["anexos"][nIndex]["codDocto"]        := JConvUTF8((cAliasNUM)->(NUM_COD))
		oResponse["anexos"][nIndex]["nomeDocto"]       := JConvUTF8((cAliasNUM)->(NUM_DOC))
		oResponse["anexos"][nIndex]["extensaoDocto"]   := JConvUTF8((cAliasNUM)->(NUM_EXTEN))
		oResponse["anexos"][nIndex]["descricaoDocto"]  := JConvUTF8((cAliasNUM)->(NUM_DESC))
		oResponse["anexos"][nIndex]["dataInclusaoArq"] := (cAliasNUM)->(NUM_DTINCL)
		(cAliasNUM)->( dbSkip() )
	EndDo
	oAnexos:Destroy()
	(cAliasNUM)->( dbCloseArea() )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT jVldCpo
Informa se os campos enviados no body existem no modelo.

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/jVldCpo

@param tabela - Tabela para buscar os dados
@param chave  - Chave do registro da tabela indicada
@param campos - Campos específicos da busca, separados por vírgula

@author Victor Hayashi
@since  15/12/2023
/*/
//-------------------------------------------------------------------
WSMETHOD PUT jVldCpo WSREST WSPfsApi
Local oResponse := JsonObject():New()
Local oJSonBody := JsonObject():New()
Local aCampos   := {}
Local aRet      := {}
Local nX        := 0
Local cBody     := ""
Local lRet      := .T.

	cBody  := StrTran(Self:GetContent(),CHR(10),"")
	oJSonBody:fromJson(cBody)
	aCampos := oJsonBody:getJsonObject("campos")

	For nX := 1 to Len(aCampos)
		aAdd(aRet, JSonObject():New())
		aRet[nX]['nomeCampo']  := aCampos[nX]['nomeCampo']
		If !Empty(GetSx3Cache(aCampos[nX]['nomeCampo'], 'X3_ORDEM'))
			aRet[nX]['exists'] := "true"
		Else
			aRet[nX]['exists'] := "false"
		EndIf
	Next nX

	oResponse := aRet
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getDataTable
Busca valores dos campos conforme alias e chave enviados

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/getDataTable/{aliasField}/{aliasKey}

@param tabela - Tabela para buscar os dados
@param chave  - Chave do registro da tabela indicada
@param campos - Campos específicos da busca, separados por vírgula

@author Jorge Martins
@since  15/12/2023
/*/
//-------------------------------------------------------------------
WSMethod GET getDataTable PATHPARAM tabela, chave QUERYPARAM campos WSREST WSPfsApi
Local cTabela   := Self:tabela
Local cChave    := Decode64(Self:chave)
Local aCampos   := IIf(Empty(Self:campos), {}, StrToArray(Self:campos, ","))
Local oResponse := {}
Local lRet      := .T.

	Aadd(oResponse, JsonObject():New())

	oResponse := JGtData(cTabela, cChave, aCampos)

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	oResponse := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtData
Consulta de Participantes, podendo filtrar por tipo

@param cTabela   - Tabela para buscar os dados
@param cChave    - Chave do registro da tabela indicada
@param aCampos   - Campos específicos para busca

@return aValores - Array com campos e valores

@author Jorge Martins
@since  15/12/2023
/*/
//-------------------------------------------------------------------
Static Function JGtData(cTabela, cChave, aCampos)
Local aArea    := GetArea()
Local aAreaTAB := (cTabela)->(GetArea())
Local aValores := {}
Local nIndJson := 0
Local nI       := 0

Private INCLUI := .F.

	If Empty(aCampos)
		aCampos := FWSX3Util():GetAllFields(cTabela, .F.)
	EndIf

	(cTabela)->(dbSetOrder(1))

	If (cTabela)->(DbSeek(cChave))
		For nI := 1 To Len(aCampos)
			nIndJson++
			aAdd(aValores, JSonObject():New())

			aValores[nIndJson]["campo"] := aCampos[nI]
			If GetSx3Cache(aCampos[nI], 'X3_CONTEXT') == 'V'
				 aValores[nIndJson]["valor"] := JConvUTF8(&(GetSx3Cache(aCampos[nI], 'X3_RELACAO')))
			Else
				aValores[nIndJson]["valor"] := JConvUTF8((cTabela)->(FieldGet(FieldPos(aCampos[nI]))))
			EndIf
		Next
	Else
		aValores := JSonObject():New()
		aValores["mensagem"] := JConvUTF8(I18N(STR0051, {cTabela, INFOSX2(cTabela, "X2_NOME")})) // "Registro não encontrado na tabela #1 - #2"
	EndIf

	RestArea(aAreaTAB)
	RestArea(aArea)

Return aValores

//-------------------------------------------------------------------
/*/{Protheus.doc} GET listCondPagamentos
Consulta condições de pagamentos

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/listCondPagamentos

@param cSearchkey - Palavra a ser pesquisada na condição ou descrição 
                    da condição de pagamento.

@author Reginaldo Borges
@since  17/01/2024
/*/
//-------------------------------------------------------------------
WSMethod GET listCondPagamentos QUERYPARAM searchkey WSREST WSPfsApi
Local oResponse  := {}
Local cSearchKey := IIf(Empty(Self:searchKey), "", Self:searchKey)

	Aadd(oResponse, JsonObject():New())

	oResponse := JCondPgto(cSearchKey)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JCondPgto
Consulta condições de pagamentos ativas

@param cSearchkey - Palavra a ser pesquisada na condição ou descrição 
                    da condição de pagamento.

@author Reginaldo Borges
@since  17/01/2024
/*/
//-------------------------------------------------------------------
Static Function JCondPgto(cSearchKey)
Local aCondPgto  := {}
Local cAliasQry  := GetNextAlias()
Local cQuery     := ""
Local oCondPagto := Nil
Local nParam     := 0
Local nIndJson   := 0

	cQuery := " SELECT E4_FILIAL,"
	cQuery +=        " E4_CODIGO,"
	cQuery +=        " E4_COND,"
	cQuery +=        " E4_DESCRI"
	cQuery +=   " FROM " + RetSqlName("SE4")
	cQuery +=  " WHERE E4_FILIAL = ?"
	cQuery +=    " AND E4_MSBLQL <> '1'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"
	If !Empty(cSearchKey)
		cSearchKey := StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' )
		cQuery += " AND (LOWER(E4_CODIGO) LIKE ?" // "'%" + Lower(Trim(cSearchKey)) + "%'"
		cQuery +=  " OR LOWER(E4_COND) LIKE ?" // "'%" + Lower(Trim(cSearchKey)) + "%'"
		cQuery +=  " OR LOWER(?) LIKE ?)" // JurFormat("E4_DESCRI", .T./*lAcentua*/) - "'%" + Lower(Trim(cSearchKey)) + "%'"
	EndIf

	oCondPagto := FWPreparedStatement():New(cQuery)
	oCondPagto:SetString(++nParam, xFilial("SE4"))

	If !Empty(cSearchKey)
		oCondPagto:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
		oCondPagto:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
		oCondPagto:SetUnsafe(++nParam, JurFormat("E4_DESCRI", .T./*lAcentua*/))
		oCondPagto:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
	EndIf

	cQuery := oCondPagto:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aCondPgto, JSonObject():New())

		aCondPgto[nIndJson]['chaveSE4']    := Encode64((cAliasQry)->E4_FILIAL + (cAliasQry)->E4_CODIGO)
		aCondPgto[nIndJson]['codigo']      := JConvUTF8((cAliasQry)->E4_CODIGO)
		aCondPgto[nIndJson]['codCondicao'] := JConvUTF8((cAliasQry)->E4_COND)
		aCondPgto[nIndJson]['descricao']   := JConvUTF8((cAliasQry)->E4_DESCRI)

		(cAliasQry)->(dbSkip())
	EndDo
	oCondPagto:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aCondPgto

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getTpRelFaturame
Consulta lista do tipo de relatório de faturamento

@param searchKey   - Palavra a ser pesquisada no código ou descrição
                     da tabela de relatório de faturamento
@param codCliente  - Obrigatório - Código do Cliente
@param codCliLoja  - Obrigatório - Loja do Cliente

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/getTpRelFaturame

@author Reginaldo Borges
@since  22/01/2024
/*/
//-------------------------------------------------------------------
WSMethod GET getTpRelFaturame QUERYPARAM searchKey, codCliente, codCliLoja WSREST WSPfsApi
Local oResponse  := {}
Local cSearchKey := IIf(Empty(Self:searchKey), "", Self:searchKey)
Local cCodCli    := IIf(Empty(Self:codCliente), "", Self:codCliente)
Local cLjCli     := IIf(Empty(Self:codCliLoja), "", Self:codCliLoja)

	Aadd(oResponse, JsonObject():New())

	oResponse := JTpRelFatu(cSearchKey, cCodCli, cLjCli)

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JTpRelFatu
Consulta lista do tipo de relatório de faturamento

@param searchKey - Palavra a ser pesquisada no código ou descrição
                   da tabela de relatório de faturamento
@param cCodCli   - Obrigatório - Código do Cliente
@param cLjCli    - Obrigatório - Loja do Cliente

@author Reginaldo Borges
@since  22/01/2024
/*/
//-------------------------------------------------------------------
Static Function JTpRelFatu(cSearchKey, cCodCli, cLjCli)
Local aTpRelFatura := {}
Local oTpRelFat    := Nil
Local cAliasQry    := GetNextAlias()
Local cQuery       := ""
Local nIndJson     := 0
Local nParam       := 0
Local lLojaAuto    := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	cQuery := " SELECT NRJ.NRJ_FILIAL,"
	cQuery +=        " NRJ.NRJ_COD,"
	cQuery +=        " NRJ.NRJ_DESC"
	cQuery +=   " FROM " + RetSqlName("NRJ") + " NRJ"
	cQuery +=  " WHERE NRJ.NRJ_FILIAL = ?" // 1 - xFilial("NRJ")
	cQuery +=    " AND NRJ.NRJ_ATIVO = '1'"
	cQuery +=    " AND NRJ.NRJ_COD NOT IN ( "
	cQuery +=                             " SELECT NUA.NUA_CTPREL"
	cQuery +=                              " FROM " + RetSqlName("NUA") + " NUA"
	cQuery +=                             " WHERE NUA.NUA_FILIAL = ?" // 2 - xFilial("NUA")
	cQuery +=                               " AND NUA.NUA_CCLIEN = ?" // 3 - cCodCli
	If lLojaAuto
		cQuery +=                           " AND NUA.NUA_CLOJA  = ?" // 4 - cLjCli
	EndIf
	cQuery +=                               " AND NUA.D_E_L_E_T_ = ' ') "
	cQuery +=   " AND NRJ.D_E_L_E_T_ = ' ' "
	If !Empty(cSearchKey)
		cSearchKey := StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' )
		cQuery += " AND (LOWER(NRJ_COD) LIKE ? " // 5- '%" + Lower(Trim(cSearchKey)) + "%'
		cQuery +=  " OR LOWER(?) LIKE ?)" // 6- JurFormat("NRJ_DESC", .T./*lAcentua*/) | 7 - '%" + Lower(Trim(cSearchKey)) + "%'
	EndIf

	oTpRelFat := FWPreparedStatement():New(cQuery)
	oTpRelFat:SetString(++nParam, xFilial("NRJ"))
	oTpRelFat:SetString(++nParam, xFilial("NUA"))
	oTpRelFat:SetString(++nParam, cCodCli)
	IF lLojaAuto
		oTpRelFat:SetString(++nParam, cLjCli)
	EndIf
	If !Empty(cSearchKey)
		oTpRelFat:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
		oTpRelFat:SetUnsafe(++nParam, JurFormat("NRJ_DESC", .T./*lAcentua*/))
		oTpRelFat:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
	EndIf

	cQuery := oTpRelFat:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aTpRelFatura, JSonObject():New())

		aTpRelFatura[nIndJson]['chaveNRJ']  := Encode64((cAliasQry)->NRJ_FILIAL + (cAliasQry)->NRJ_COD)
		aTpRelFatura[nIndJson]['codigo']    := JConvUTF8((cAliasQry)->NRJ_COD)
		aTpRelFatura[nIndJson]['descricao'] := JConvUTF8((cAliasQry)->NRJ_DESC)

		(cAliasQry)->(dbSkip())
	EndDo
	oTpRelFat:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aTpRelFatura

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getBancos
Consulta lista de bancos

@param searchKey - Palavra a ser pesquisada no código ou descrição
                   da tabela de bancos
@param bcoEscr   - Código do escritório para verificar amarração com o banco
@param bcoPix    - Indica se deve ser considerado apenas os bancos que tem
                   a opção PIX.

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/getBancos

@author Reginaldo Borges
@since  22/01/2024
/*/
//-------------------------------------------------------------------
WSMethod GET getBancos QUERYPARAM searchKey, bcoEscr, bcoPix WSREST WSPfsApi
Local oResponse  := {}
Local cSearchKey := IIf(Empty(Self:searchKey), "", Self:searchKey)
Local cCodEscr   := IIf(Empty(Self:bcoEscr), "", Self:bcoEscr)
Local lBcoPix    := IIf(Empty(Self:bcoPix) , .F., Self:bcoPix)

	Aadd(oResponse, JsonObject():New())

	oResponse := JBancos(cSearchKey, cCodEscr, lBcoPix)

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JBancos
Consulta lista de bancos

@param searchKey - Palavra a ser pesquisada no código, nome, agencia
                   ou conta da tabela de bancos
@param cCodEscr  - Código do escritório para verificar amarração com o banco
@param lBcoPix   - Indica se deve ser considerado apenas os bancos que tem
                   a opção PIX.

@author Reginaldo Borges
@since  22/01/2024
/*/
//-------------------------------------------------------------------
Static Function JBancos(cSearchKey, cCodEscr, lBcoPix)
Local aBancos   := {}
Local oBancos   := Nil
Local cAliasQry := GetNextAlias()
Local cTpDtBase :=  AllTrim(Upper(TCGetDB())) // Tipo de database do sistema
Local cQuery    := ""
Local nIndJson  := 0
Local nParam    := 0
Local lBcoScrit := !Empty(cCodEscr)

	cQuery := " SELECT SA6.A6_FILIAL,"
	cQuery +=        " SA6.A6_COD,"
	cQuery +=        " SA6.A6_NOME,"
	cQuery +=        " SA6.A6_AGENCIA,"
	cQuery +=        " SA6.A6_NUMCON"
	cQuery +=   " FROM " + RetSqlName("SA6") + " SA6"
	If lBcoScrit
		cQuery +=  " INNER JOIN " + RetSqlName("OHK") + " OHK"
		cQuery +=     " ON OHK.OHK_CBANCO = SA6.A6_COD"
		cQuery +=    " AND OHK.OHK_CAGENC = SA6.A6_AGENCIA"
		cQuery +=    " AND OHK.OHK_CCONTA = SA6.A6_NUMCON"
		cQuery +=    " AND OHK.OHK_CESCRI = ?"
		cQuery +=    " AND OHK.D_E_L_E_T_ = ' '"
	EndIf
	If lBcoPix .And. OH1->(ColumnPos("OH1_TIPREL")) > 0 // @12.1.2310 - O campo OH1_TIPREL foi criado junto com a opção de pagamento 3=Pix
		cQuery += " INNER JOIN "+ RetSqlName("F70") + " F70 "
		cQuery +=    " ON (F70.F70_FILIAL = SA6.A6_FILIAL "
		cQuery +=   " AND F70.F70_COD = SA6.A6_COD "
		cQuery +=   " AND F70.F70_AGENCI = SA6.A6_AGENCIA "
		cQuery +=   " AND F70.F70_NUMCON = SA6.A6_NUMCON "
		cQuery +=   " AND F70.F70_NUMCON = SA6.A6_NUMCON "
		cQuery +=   " AND F70.D_E_L_E_T_ = ' ') "
	EndIf
	cQuery +=  " WHERE SA6.A6_FILIAL = ?"
	cQuery +=    " AND SA6.A6_BLOCKED <> '1'"
	cQuery +=    " AND SA6.D_E_L_E_T_ = ' '"
	If !Empty(cSearchKey)
		cSearchKey := StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' )
		cQuery +=  " AND (LOWER(?) LIKE ?" // TRIM(A6_COD)||TRIM(A6_AGENCIA)||TRIM(A6_NUMCON) - "%" + cSearchKey + "%"
		cQuery +=   " OR LOWER(?) LIKE ?)" // JurFormat("A6_NOME", .T./*lAcentua*/)) - "%" + Lower(Trim(cSearchKey)) + "%"
	EndIf

	oBancos := FWPreparedStatement():New(cQuery)

	If lBcoScrit
		oBancos:SetString(++nParam, cCodEscr)
	EndIf

	oBancos:SetString(++nParam, FWxFilial("SA6", cFilAnt))

	If !Empty(cSearchKey)
		If cTpDtBase == "ORACLE"
			oBancos:SetUnsafe(++nParam, "LTRIM(RTRIM(A6_COD))||LTRIM(RTRIM(A6_AGENCIA))||LTRIM(RTRIM(A6_NUMCON))")
		ElseIf cTpDtBase == "MSSQL"
			oBancos:SetUnsafe(++nParam, "LTRIM(RTRIM(A6_COD))+LTRIM(RTRIM(A6_AGENCIA))+LTRIM(RTRIM(A6_NUMCON))")
		EndIf
		oBancos:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
		oBancos:SetUnsafe(++nParam, JurFormat("A6_NOME", .T./*lAcentua*/))
		oBancos:SetUnsafe(++nParam, "'%" + Lower(Trim(cSearchKey)) + "%'")
	EndIf

	cQuery := oBancos:GetFixQuery()
	MpSysOpenQuery(cQuery, cAliasQry)

	While ((cAliasQry)->(!Eof()))
		nIndJson++
		aAdd(aBancos, JSonObject():New())

		aBancos[nIndJson]['chaveSA6'] := Encode64((cAliasQry)->A6_FILIAL + (cAliasQry)->A6_COD + (cAliasQry)->A6_AGENCIA + (cAliasQry)->A6_NUMCON)
		aBancos[nIndJson]['codigo']   := JConvUTF8((cAliasQry)->A6_COD)
		aBancos[nIndJson]['nome']     := JConvUTF8((cAliasQry)->A6_NOME)
		aBancos[nIndJson]['agencia']  := JConvUTF8((cAliasQry)->A6_AGENCIA)
		aBancos[nIndJson]['conta']    := JConvUTF8((cAliasQry)->A6_NUMCON)

		(cAliasQry)->(dbSkip())
	EndDo
	oBancos:Destroy()
	(cAliasQry)->(dbCloseArea())

Return aBancos

//-------------------------------------------------------------------
/*/{Protheus.doc} POST vinCa
Valida se o Caso pode ser vinculado ao Contrato(NUT).

@example POST -> http://127.0.0.1:9090/rest/WSPfsApi/vincCasContr

@author Reginaldo Borges
@since  16/02/2024
/*/
//-------------------------------------------------------------------
WSMETHOD POST vinCa WSREST WSPfsApi
Local oResponse   := JsonObject():New()
Local oJSonBody   := JsonObject():New()
Local cBody       := StrTran(Self:GetContent(),CHR(10),"")
Local aBody       := {}
Local aInfoApi    := {}
Local lRet        := .T.
Local cMsgErro    := ""
Local cMsgSolucao := ""

	oJSonBody:fromJson(cBody)
	aBody := oJsonBody:getJsonObject("infoApi")

	aInfoApi := {aBody[1]["cAtivo"], aBody[1]["cTpHon"]}

	If aInfoApi[1] == "1" .And. J096CHon(aInfoApi[2]) // Indica se o tipo de honorário cobra hora
		aInfoApi := {aBody[1]["codContr"], aBody[1]["codCliente"], aBody[1]["lojaCliente"], aBody[1]["codCaso"], aBody[1]["dDtVigI"], aBody[1]["dDtVigF"]}
		lRet := J096VlTpHo(Nil, , , , , , , , aInfoApi, @cMsgErro, @cMsgSolucao) // Impede que seja informado casos amarrados a contratos de cobranca por hora em outro contrato com cobranca por hora
	EndIf

	If lRet
		aInfoApi := {aBody[1]["codCliente"], aBody[1]["lojaCliente"], aBody[1]["codCaso"], aBody[1]["codContr"], aBody[1]["cAtivo"], aBody[1]["cCobTab"],aBody[1]["cCobDes"], aBody[1]["dDtVigI"], aBody[1]["dDtVigF"]}
		lRet     := J096VDespTab( , , , , , , , aInfoApi, @cMsgErro, @cMsgSolucao) // Função utilizada para validar se o caso já esta associado a algum outro contrato que cobre Despesa ou Tabelado
	EndIf

	oResponse := {}
	Aadd(oResponse, JsonObject():New())
	If lRet
		oResponse[1]["lVincula"]    := 'true'
	Else
		oResponse[1]["lVincula"]    := 'false'
		oResponse[1]["cMsgErro"]    := JConvUTF8(cMsgErro)
		oResponse[1]["cMsgSolucao"] := JConvUTF8(cMsgSolucao)
	EndIf

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	aSize(oResponse, 0)
	oResponse := Nil

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET extFields
Retorna a lista de campos customizados e campos obrigatorios de um modelo.

@param searchKey   Tabela que se deseja estrutura

@since 16/02/2024

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/WSPfsApi/extraFields

/*/
//-------------------------------------------------------------------
WSMETHOD GET extFields WSRECEIVE searchKey, isValid, isCustom, isTudo WSREST WSPfsApi
Local oResponse  := JsonObject():New()
Local alCampos   := {}
Local aAux       := {}
Local csearchKey := self:searchKey
Local nIndex     := 0
Local nQtd       := 0
Local nI         := 1
Local nX         := 1
Local nY         := 1
Local lValid     := Self:isValid == 'true' .Or. Self:isValid == Nil
Local lCustom    := Self:isCustom == 'true' .Or. Self:isCustom == Nil
Local lTudo      := Self:isTudo == 'true' .Or. Self:isTudo == Nil

	Self:SetContentType("application/json")
	oResponse['custom'] := {}

	alCampos := JGtExtFlds(csearchKey, lValid, lCustom, lTudo )

	// Pega os campos da(s) tabela(s)
	For nI := 1 To Len(alCampos)
		If Len(alCampos[nI]) > 0
			Aadd(oResponse['custom'], JsonObject():New())
			nIndex++
			oResponse['custom'][nIndex]['tabela'] := getSx3Cache(alCampos[nI][1][1] ,'X3_ARQUIVO')
			oResponse['custom'][nIndex]['campos'] := {}

			// Obtem os campos de cada tabela
			For nX := 1 To Len(alCampos[nI])
				
				Aadd(oResponse['custom'][nIndex]['campos'], JsonObject():New())
				oResponse['custom'][nIndex]['campos'][nX]['tabela']      := getSx3Cache(alCampos[nI][nX][1] ,'X3_ARQUIVO')
				oResponse['custom'][nIndex]['campos'][nX]['ordem']       := Val(getSx3Cache(alCampos[nI][nX][1] ,'X3_ORDEM'))
				oResponse['custom'][nIndex]['campos'][nX]['campo']       := alCampos[nI][nX][1]
				oResponse['custom'][nIndex]['campos'][nX]['tamanho']     := getSx3Cache(alCampos[nI][nX][1] ,'X3_TAMANHO')
				oResponse['custom'][nIndex]['campos'][nX]['decimal']     := getSx3Cache(alCampos[nI][nX][1] ,'X3_DECIMAL')
				oResponse['custom'][nIndex]['campos'][nX]['mascara']     := AllTrim(getSx3Cache(alCampos[nI][nX][1] ,'X3_PICTURE'))
				oResponse['custom'][nIndex]['campos'][nX]['titulo']      := JConvUTF8(alCampos[nI][nX][3])
				oResponse['custom'][nIndex]['campos'][nX]['agrupamento'] := alCampos[nI][nX][12]
				oResponse['custom'][nIndex]['campos'][nX]['isCustom']    := ('_X' $ alCampos[nI][nX][1] ) .Or. ( '__' $ alCampos[nI][nX][1] )
				oResponse['custom'][nIndex]['campos'][nX]['required']    := X3Obrigat(alCampos[nI][nX][1])
				oResponse['custom'][nIndex]['campos'][nX]['isVirtual']   := alCampos[nI][nX][16]
				oResponse['custom'][nIndex]['campos'][nX]['isBrowse']    := getSx3Cache(alCampos[nI][nX][1] ,'X3_BROWSE') == "S"
				oResponse['custom'][nIndex]['campos'][nX]['isVisual']    := getSx3Cache(alCampos[nI][nX][1] ,'X3_VISUAL') == "V"
				oResponse['custom'][nIndex]['campos'][nX]['descComplet'] := JConvUTF8(alCampos[nI][nX][4])

				// Campos combobox
				If !Empty(getSx3Cache(alCampos[nI][nX][1] ,'X3_CBOX'))
					oResponse['custom'][nIndex]['campos'][nX]['tipo']    := 'CB'
					oResponse['custom'][nIndex]['campos'][nX]['opcoes']  := {}

					// Guarda as opções dos combobox
					For nY := 1 To Len(alCampos[nI][nX][13])
						If Empty(alCampos[nI][nX][13][nY])
							loop
						EndIf
						
						
						If Len(alCampos[nI][nX][13]) > 0
							aAux := StrToKArr(alCampos[nI][nX][13][nY], '=')
						EndIf

						Aadd(oResponse['custom'][nIndex]['campos'][nX]['opcoes'], JsonObject():New())
						aTail(oResponse['custom'][nIndex]['campos'][nX]['opcoes'])['label'] := IIF( Len(aAux) > 1, JConvUTF8(aAux[2]), "")
						aTail(oResponse['custom'][nIndex]['campos'][nX]['opcoes'])['value'] := IIF( Len(aAux) > 0, aAux[1], "")
					Next nY

				// Campos F3
				ElseIf !Empty(getSx3Cache(alCampos[nI][nX][1] ,'X3_F3'))
					oResponse['custom'][nIndex]['campos'][nX]['tipo']     := 'F3'
					oResponse['custom'][nIndex]['campos'][nX]['XB_ALIAS'] := AllTrim(getSx3Cache(alCampos[nI][nX][1],'X3_F3'))

				// Demais campos
				Else
					oResponse['custom'][nIndex]['campos'][nX]['tipo']    := getSx3Cache(alCampos[nI][nX][1] ,'X3_TIPO')
				EndIf

				nQtd++
			Next nX
		EndIf
	Next nI
	
	oResponse['length'] := nQtd

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	aSize(alCampos, 0)


Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET JGtExtFlds
Retorna um array de campos customizados e campos obrigatorios de um modelo.

@param searchKey   Tabela que se deseja estrutura

@since 16/02/2024

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/WSPfsApi/extraFields

/*/
//-------------------------------------------------------------------
Function JGtExtFlds(csearchKey, lValid, lCustom, lTudo )
Local aTables    := {}
Local aCustomFds := {}
Local aCampos   := {}
Local nI         := 0
Local nZ         := 0
Local oStruct    := Nil

Default csearchKey := ""
Default lValid     := .F.
Default lCustom    := .F.
Default lTudo      := .F.

	aTables := StrToKArr(csearchKey, "|")

	For nZ := 1 to Len(aTables)
		aAdd( aCustomFds, { aTables[nZ], aClone(aCampos) } ) // Tabela e campos
		aSize(aCampos, 0)
	Next

	// Monta a estrutura do modelo, para campos que são obrigatórios ou custom.
	For nI := 1 To Len(aCustomFds)
		If lTudo // Carrega todos os campos disponíveis
			oStruct := FWFormStruct( 2, aCustomFds[nI][1], , , ,.T.)
		ElseIf lValid // Todos campos obrigatórios, editáveis e customizados
			oStruct := FWFormStruct(2, aCustomFds[nI][1], ;
				{ | cCampo | ;
					getSx3Cache(cCampo, 'X3_VISUAL') != 'V'; // É editável
					.And. ( x3Obrigat( cCampo ); // É obrigatório no dicionário
					 .Or. (getSx3Cache(cCampo, 'X3_PROPRI') == 'U'); // É campo customizado
					);
				};
			)
		ElseIf lCustom // Carregada somente os campos customizados
			oStruct := FWFormStruct( 2, aCustomFds[nI][1],;
				{ | cCampo | getSx3Cache(cCampo, 'X3_PROPRI') == 'U' } ) // É campo customizado
		Else // Carrega todos os campos obrigatórios e customizados
			oStruct := FWFormStruct( 2, aCustomFds[nI][1],;
				{ | cCampo |;
					x3Obrigat(cCampo); // É um campo obrigatório
					.Or. getSx3Cache(cCampo, 'X3_PROPRI') == 'U' } ) // É campo customizado
		EndIf

		aAdd(aCampos, aClone(oStruct:aFields))
	Next nI

	aSize(aCustomFds[1], 0)

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} GET dataByCODLD
Busca chave da tabela e valores dos campos conforme CODLD enviado

@example GET -> http://127.0.0.1:9090/rest/WSPfsApi/dataByCODLD/{tabela}/{campo}/{codLD}

@param tabela - Tabela para buscar os dados
@param campo  - Campo de CODLD da tabela (Ex: NUH_CODLD)
@param codLD  - Código LegalDesk (CODLD) do registro

@queryparam fields - Campos específicos da busca, separados por vírgula (Opcional)
                     Também podem ser usados os valores: 
                     "UNIQUE": Para trazer as os campos que formam a chave única da tabela
                     "ALL"   : Para trazer todos os campos reais da tabela

@author Jorge Martins
@since  25/09/2024
/*/
//-------------------------------------------------------------------
WSMethod GET dataByCODLD PATHPARAM tabela, campo, codLD QUERYPARAM fields WSREST WSPfsApi
Local cTabela      := Self:tabela
Local cCpoCodLD    := Self:campo
Local cCodLD       := Self:codLD
Local cCampos      := Self:fields
Local aCampos      := {}
Local oResponse    := Nil
Local lRet         := .T.
Local lChave64     := .F.
Local lTrataLGPD   := .F.

	If Empty(cTabela) .Or. Empty(cCpoCodLD) .Or. Empty(cCodLD)
		SetRestFault(404, JConvUTF8(STR0071)) // "Não foram enviados os parâmetros necessários para a consulta. Verifique a tabela, campo e CODLD enviados na requisição."
		lRet := .F.
	ElseIf !AliasInDic(cTabela)
		SetRestFault(404, JConvUTF8(I18N(STR0072, {cTabela}))) // "Tabela '#1' não encontrada."
		lRet := .F.
	EndIf

	If lRet
		If Empty(cCampos) // Vai retornar somente a chave da tabela em Base64
			lChave64 := .T.
			aCampos  := StrToArray(FWX2Unico(cTabela), "+")
		ElseIf cCampos == "UNIQUE" // Vai retornar somente a chave da tabela (Campo e valor)
			aCampos := StrToArray(FWX2Unico(cTabela), "+")
		ElseIf cCampos == "ALL" // Vai retornar os campos reais da tabela (Campo e valor)
			aCampos    := {}
			lTrataLGPD := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.)
		Else // Vai retornar os campos reais da tabela enviados por parâmetro (Campo e valor)
			aCampos    := StrToArray(cCampos, ",")
			lTrataLGPD := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.)
		EndIf

		oResponse := JGtDataLD(cTabela, cCpoCodLD, cCodLD, aCampos, lChave64, @lRet, lTrataLGPD)

		If lRet
			Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		EndIf
	
		oResponse := Nil

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtDataLD
Consulta de Participantes, podendo filtrar por tipo

@param cTabela   - Tabela para buscar os dados
@param cCpoCodLD - Campo de CODLD da tabela
@param cCodLD    - CodLD do registro da tabela indicada
@param aCampos   - Campos específicos para busca
@param lChave64  - Indica se será retornado a chave do registro em formato base64
@param lRet      - Se .T. o registro foi encontrado, se .F. não encontrado

@return aValores - Array com campos e valores

@author Jorge Martins
@since  25/09/2024
/*/
//-------------------------------------------------------------------
Static Function JGtDataLD(cTabela, cCpoCodLD, cCodLD, aCampos, lChave64, lRet, lTrataLGPD)
Local aArea       := GetArea()
Local aAreaTAB    := (cTabela)->(GetArea())
Local aValores    := {}
Local nIndJson    := 0
Local nI          := 0
Local cResQRY     := ""
Local cChave64    := ""
Local cQuery      := ""
Local oDadosLD    := Nil
Local xValorCampo := Nil

Private INCLUI := .F.

	cTabela   := AllTrim(cTabela)
	cCpoCodLD := AllTrim(cCpoCodLD)
	cCodLD    := AllTrim(cCodLD)

	If Empty(aCampos)
		aCampos := FWSX3Util():GetAllFields(cTabela, .F.)
	EndIf

	(cTabela)->(dbSetOrder(1))

	If &(cTabela)->(ColumnPos(cCpoCodLD)) > 0
		
		cQuery := "SELECT R_E_C_N_O_ TABRECNO "
		cQuery +=  " FROM " + RetSqlName(cTabela)
		cQuery += " WHERE D_E_L_E_T_ = ' ' AND ? = ?"

		oDadosLD := FWPreparedStatement():New(cQuery)
		oDadosLD:SetUnsafe(1, cCpoCodLD)
		oDadosLD:SetString(2, cCodLD)
		
		cQuery  := oDadosLD:GetFixQuery()
		cResQRY := GetNextAlias()
		
		MpSysOpenQuery(cQuery, cResQRY)

		If !(cResQRY)->(Eof()) .And. (cResQRY)->TABRECNO > 0
		
			&(cTabela)->(dbGoTo((cResQRY)->TABRECNO))

			For nI := 1 To Len(aCampos)
				// Não exibirá campos virtuais, nem campos de restrição de acesso (LGPD)
				If GetSx3Cache(aCampos[nI], 'X3_CONTEXT') <> 'V' .And. (!lTrataLGPD .Or. !Empty(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {aCampos[nI]})))
					xValorCampo := (cTabela)->(FieldGet(FieldPos(aCampos[nI])))
					If lChave64
						cChave64 += xValorCampo
					Else
						cTipoCpo := GetSx3Cache(aCampos[nI], 'X3_TIPO')
						If cTipoCpo == "N"
							xValorCampo := cValToChar(xValorCampo)
						ElseIf cTipoCpo == "D"
							xValorCampo := DToS(xValorCampo)
						EndIf

						nIndJson++
						aAdd(aValores, JSonObject():New())
						aValores[nIndJson]["field"] := aCampos[nI]
						aValores[nIndJson]["value"] := JConvUTF8(xValorCampo)
					EndIf
				EndIf
			Next

			If lChave64
				cChave64 := Encode64(cChave64)
			EndIf

		Else
			SetRestFault(404, JConvUTF8(I18N(STR0051, {cTabela, INFOSX2(cTabela, "X2_NOME")}))) // "Registro não encontrado na tabela #1 - #2"
			lRet := .F.
		EndIf
		(cResQRY)->(dbCloseArea())
	Else
		SetRestFault(404, JConvUTF8(I18N(STR0073, {cCpoCodLD, cTabela, INFOSX2(cTabela, "X2_NOME")}))) // "Campo #1 não encontrado na tabela #2 - #3"
		lRet := .F.
	EndIf

	RestArea(aAreaTAB)
	RestArea(aArea)

Return IIf(lChave64, cChave64, aValores)