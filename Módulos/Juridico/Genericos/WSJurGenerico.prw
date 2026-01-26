#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSJURGENERICO.CH"

WSRESTFUL WSJurGenerico DESCRIPTION STR0001 // "Webservice Genérico Jurídico"
	WSDATA model         AS STRING
	WSDATA field         AS STRING
	WSDATA fnName        AS STRING
	WSDATA fnMethodsWS   AS STRING
	WSDATA httpVerb      AS STRING
	WSDATA operation     AS STRING
	WSDATA methodName    AS STRING
	WSDATA tableName     AS STRING
	WSDATA filtercpo     AS STRING
	WSDATA filterinfo    AS STRING
	WSDATA fieldSearch   AS STRING
	WSDATA searchKey     AS STRING
	WSDATA pageValue     AS STRING
	WSDATA cpoOrdem      AS STRING
	WSDATA defaultFilter AS STRING

	// API's Struct/MVC
	WSMETHOD GET gtModelStruct DESCRIPTION STR0002 PATH "struct/{model}"          PRODUCES APPLICATION_JSON //"Retorna a estrutura do MVC"

	// API's Lib
	WSMETHOD GET gtLibVersion  DESCRIPTION STR0003 PATH "lib/version"             PRODUCES APPLICATION_JSON //"Retorna a versão da Lib"
	WSMETHOD GET fnExist       DESCRIPTION STR0004 PATH "lib/function/{fnName}"   PRODUCES APPLICATION_JSON //"Verifica se a Função existe"
	WSMETHOD GET tabInDic      DESCRIPTION STR0009 PATH "lib/table/{tableName}"   PRODUCES APPLICATION_JSON //"Verifica se a tabela existe no dicionário"
	
	WSMETHOD PUT tblMultExist  DESCRIPTION STR0010 PATH "lib/table/multi"         PRODUCES APPLICATION_JSON //"Verificação multipla de tabelas"
	WSMETHOD PUT adapts        DESCRIPTION STR0011 PATH "adapts"                  PRODUCES APPLICATION_JSON //"Retorna a lista da tabelada informada"
END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET - fnExist
Verifica se a função existe

@param model     - Path  - Fonte MVC a ser chamado
@param field     - Query - Campo a ser retornado
@param operation - Query - Tipo de operação da consulta

@since 28/09/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET fnExist PATHPARAM fnName WSREST WSJurGenerico
Local lRet      := .T.
Local oResponse := JSonObject():New()

	oResponse['function'] := JSonObject():New()
	oResponse['function']['name']   := Self:fnName
	
	If (!Empty(Self:fnName))
		oResponse['function']['exists'] := FindFunction(oResponse['function']['name'])
	Else
		oResponse['function']['exists'] := .F.
	EndIf

	Self:SetContentType("application/json")
	Self:SetResponse(oResponse:toJson())

	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} gtModelStruct
Retorna a estrutura do MVC

@param model     - Path - Fonte MVC a ser chamado
@param field     - Query - Campo a ser retornado
@param operation - Query - Tipo de operação da consulta

@since 28/09/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET gtModelStruct PATHPARAM model WSRECEIVE field, operation WSREST WSJurGenerico
Local lRet        := .T.
Local oResponse   := nil
Local cRotinaMVC  := Self:model
Local cCampo      := Self:field
Local lOpInclusao := .F.
Local cHdAssjur   := Self:GetHeader("cAssJur")

Default cCampo := ""

	If (!Empty(cHdAssJur))
		Private cTipoASJ   := cHdAssjur
		Private c162TipoAs := cHdAssjur
	EndIf

	If (!Empty(Self:operation))
		lOpInclusao := Self:operation == "inclusao"
	EndIf

	If !Empty(cRotinaMVC)
		oResponse := StructMdl(cRotinaMVC, cCampo, lOpInclusao)
		If ValType(oResponse) == "J"
			Self:SetContentType("application/json")
			Self:SetResponse(oResponse:toJson())
			oResponse:fromJson("{}")
			oResponse := NIL
		Else
			lRet := .F.
		EndIf
	Else
		lRet := JRestError(404, STR0007) // "É necessário passar o modelo a ser consultado."
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} tabInDic
Retorna a tabela existe no dicionário

@param tableName - Nome da tabela

@since 11/10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET tabInDic PATHPARAM tableName WSREST WSJurGenerico
Local lRet      := .T.
Local oResponse := JSonObject():New()

	oResponse['table']              := JSonObject():New()
	oResponse['table']['tableName'] := Self:tableName
	oResponse['table']['exists']    := FWAliasInDic(Self:tableName)

	Self:SetContentType("application/json")
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} tabInDic
Retorna a tabela existe no dicionário

@body - Lista de Tabelas a serem verificadas
	{
		"tables": [
			"O0W","NSZ","NX0","ZZZ"
		]
	}

@returns 
	[
		{ "table": "O0W", "exist": true },
		{ "table": "NSZ", "exist": true },
		{ "table": "NX0", "exist": true },
		{ "table": "ZZZ", "exist": false },
	]

@since 11/10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD PUT tblMultExist WSREST WSJurGenerico
Local cTableName  := ""
Local cBody       := Self:GetContent()
Local oBody       := JSonObject():New()
Local aJSonResp   := {}
Local nI          := 0
Local lRet        := .T.

	oBody:FromJSon(cBody)
	If Len(oBody['tables']) > 0
		For nI := 1 To Len(oBody['tables'])
			cTableName := oBody['tables'][nI]
			aAdd(aJSonResp, JSonObject():New())
			aTail(aJSonResp)['table'] := cTableName
			aTail(aJSonResp)['exist'] := FWAliasInDic(cTableName)
		Next nI
	EndIf

	Self:SetContentType("application/json")
	Self:SetResponse(FWJsonSerialize(aJSonResp, .F., .F., .T.))
	aSize(aJSonResp, 0)
	aJSonResp := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} gtLibVersion
Retorna a versão da Lib do Protheus

@since 11/10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET gtLibVersion WSREST WSJurGenerico
Local lRet      := .T.
Local oResponse := JSonObject():New()

	oResponse['lib']            := JSonObject():New()
	oResponse['lib']['version'] := __FWLibVersion()
	
	Self:SetContentType("application/json")
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StructMdl
Busca da estrutura de uma determinada rotina. 

@param  cRotina     : Nome da rotina em mvc para buscar a estrutura
@param  cNomeCampo  : No do campo a ser encontrado
@param  lOpInclusao : Está em operação de Inclusão

@return oResponse - Objeto json com a estrutura da rotina

@author Willian Kazahaya
@since 27/09/2023
/*/
//-------------------------------------------------------------------
Static Function StructMdl(cRotina, cNomeCampo, lOpInclusao)
Local oResponse  := nil
Local oView      := nil
Local oViewMdl   := nil
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
Local nV         := 0
Local nF         := 0
Local aViewMdl   := {}
Local aSubViewFld:= {}

Default cRotina    := ''
Default cNomeCampo := ''
Default lOpInclusao:= .F.

	If !Empty(cRotina)
		If lOpInclusao
			oModel := FwLoadModel(cRotina)
			oModel:SetOperation(3)
			oModel:Activate()
		EndIf

		oView  := FwLoadView(cRotina)

		If ValType(oView) == "O"
			oViewMdl := oView:GetModel()

			oResponse := JsonObject():New()
			oResponse['title']   := JConvUTF8(oView:GetDescription())
			oResponse['struct']  := {}
			oResponse['modelId'] := oViewMdl:GetId()

			aModels := oViewMdl:GetAllSubModels()

			For nI := 1 To Len(aModels)
				aViewField := {}
				aViewMdl   := {}

				aAdd(oResponse['struct'],JsonObject():New())
				aTail(oResponse['struct'])['id']   := aModels[nI]:GetId() //nome modelo
				aTail(oResponse['struct'])['type'] := aModels[nI]:ClassName() //Field/Grid
				aTail(oResponse['struct'])['fields'] := {}

				aAuxFlds   := aTail(oResponse['struct'])['fields']

				aMdlFields := aModels[nI]:GetStruct():GetFields()

				// Verifica se existe o Modelo dentro das Views
				aViewMdl := aClone(oView:GetModelsId())
				If aScan(aViewMdl,aModels[nI]:GetId()) > 0
					
					// Loop em todas as Views a partir do model
					For nV := 1 to Len(aViewMdl)
						If aViewMdl[nV] == aModels[nI]:GetId()
							aSubViewFld := aClone(oView:aViews[nV][3]:oStructView:GetFields())
							For nF := 1 to Len(aSubViewFld)
								aAdd(aViewField, aSubViewFld[nF] )
							Next nF

							aSize(aSubViewFld, 0)
						EndIf
				
					//aViewField := aClone(oView:GetViewStruct(aModels[nI]:GetId()):GetFields())
					Next nV
				Endif
				aSize(aViewMdl, 0 )

				If (!Empty(cNomeCampo) .And. aScan(aMdlFields, {|x| x[3] == cNomeCampo }) == 0)
					Loop
				EndIf

				For nX := 1 To Len(aMdlFields)
					If (Empty(cNomeCampo) .Or. (!Empty(cNomeCampo) .And. aMdlFields[nX][3] == cNomeCampo))
						cF3         := ''
						aOptions    := Nil
						lCanChange  := .T.
						nPos        := 0

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
								Next nZ
							EndIf
						EndIf

						aAdd(aAuxFlds,JsonObject():New())

						aTail(aAuxFlds)['field']         := aMdlFields[nX][3]
						aTail(aAuxFlds)['description']   := JConvUTF8(aMdlFields[nX][1])
						aTail(aAuxFlds)['type']          := aMdlFields[nX][4]
						aTail(aAuxFlds)['size']          := aMdlFields[nX][5]
						aTail(aAuxFlds)['decimal']       := aMdlFields[nX][6]
						aTail(aAuxFlds)['filter']        := AllTrim(cF3)
						aTail(aAuxFlds)['options']       := buildOpts(aMdlFields[nX][3], aOptions)
						aTail(aAuxFlds)['isBrowse']      := getSx3Cache(aMdlFields[nX][3],'X3_BROWSE') == 'S'
						aTail(aAuxFlds)['isRequired']    := aMdlFields[nX][10]
						aTail(aAuxFlds)['isView']        := nPos > 0
						aTail(aAuxFlds)['isVirtual']     := getSx3Cache(aMdlFields[nX][3],'X3_CONTEXT') == 'V'
						aTail(aAuxFlds)['hasSequencial'] := lHasXENum
						aTail(aAuxFlds)['canChange']     := lCanChange
						aTail(aAuxFlds)['descComplet']   := JConvUTF8(aMdlFields[nX][2])

						If (lOpInclusao .And. aMdlFields[nX][11] != Nil)
							// Valor de campo caractere ou memo
							If aMdlFields[nX][4] $ "C|M"
								aTail(aAuxFlds)['initValue'] := JConvUTF8(oModel:GetValue(aModels[nI]:GetId(), aMdlFields[nX][3]))
							Else
								// Valor de campo data
								If aMdlFields[nX][4] == "D" .And. VALTYPE(oModel:GetValue(aModels[nI]:GetId(), aMdlFields[nX][3])) == "D"
									aTail(aAuxFlds)['initValue'] := DTOS(oModel:GetValue(aModels[nI]:GetId(), aMdlFields[nX][3]))
								Else
									aTail(aAuxFlds)['initValue'] := oModel:GetValue(aModels[nI]:GetId(), aMdlFields[nX][3])
								EndIf
							EndIf
						Else 
							aTail(aAuxFlds)['initValue'] := ''
						EndIf
					EndIf
				Next nX
			Next nI

			oView:Destroy()
			FwFreeObj(oView)

			If (lOpInclusao)
				oModel:Destroy()
				FwFreeObj(oModel)
			EndIf
		Else
			JRestError(404, STR0008) // 'O modelo informado não contem view configurada! Favor verificar.'
		Endif

		oView := nil
	Endif
Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} buildOpts(cField, aOptions)
Monta as opções do campo

@param cField - Campo a ser pesquisado
@param aOptions - Opções atuais

@author Willian Kazahaya
@since 29/08/2024
/*/
//-------------------------------------------------------------------
Static Function buildOpts(cField, aOptions)
Local cFldCbox := ""
Local cTemp    := ""
Local aOpts    := {}
Local aItenOpt := {}
Local nI       := 0
Default aOptions := {}
	If (Len(aOptions) == 0)
		cFldCbox := GetSx3Cache(cField, "X3_CBOX")
		
		If (!Empty(cFldCbox))	
			If (at("#",cFldCbox) == 1)
				cTemp := AllTrim(SubStr(cFldCbox,2))
				cFldCbox := Eval({|| &(cTemp)})
				aOpts := StrTokArr(cFldCbox, ";")		
			Else 
				aOpts := StrTokArr(cFldCbox, ";")
			EndIf

			For nI := 1 To Len(aOpts)
				aItenOpt := StrTokArr(aOpts[nI], "=")

				aAdd(aOptions, JsonObject():New())
				aTail(aOptions)['value'] := aItenOpt[1]
				aTail(aOptions)['label'] := JConvUTF8(aItenOpt[2])
			Next nI
		EndIf

		aSize(aOpts, 0)
		aSize(aItenOpt, 0)	
	EndIf
Return aOptions

//-------------------------------------------------------------------
/*/{Protheus.doc} Adapts
Retorna lista com as informações da tabela, para ser usada como adapters

@param tableName - Path - Nome da tabela

@param field - Query - Campos para o Select
@param filtercpo - Query - Campos para o Where
@param filterinfo - Query - Valores para o Where
@param searchKey - Query - Valor digitado pelo usuario
@param pageValue - Query - Valor de paginação
@param cpoOrdem - Query - Ordenação
@param defaultFilter - Query - Filtro padrão

@body 
	{
		fields: ["",""],
		filter: [
			{
				field: ''
				value: '',
			}
		],
		defaultFilter: "", //A1_ATIVO = '1'
		pageSize: 10,
		searchkey: {
			fields: ["",""],
			value: ""
		},
		table: ""
		order: [
			{
				field: "",
				orderType: "asc" | "desc"
			}
		]
	}


@since 11/10/2023
/*/
//-------------------------------------------------------------------
WSMETHOD PUT Adapts WSREST WSJurGenerico
Local oResponse  := JSonObject():New() // resposta da api
Local oQuery     := Nil // Objeto para query
Local cTabela    := ""
Local aCampos    := {}
Local cAliasQry  := ""
Local cQuery     := "SELECT " // Inicio da Query
Local cTpDtBase  := AllTrim(Upper(TCGetDB())) // Tipo de database do sistema
Local aCpoSrch   := {}
Local cSearchKey := ""
Local cCpoComp   := "" // filtro com os campos compostos
Local nPage      := 10
Local cCpoFil    := ""
Local cTable     := ""
Local nX         := 0 // Contador do FOR
Local nIndexJSon := 0 // Contador dos registros
Local oBody      := JSonObject():New()
Local aParams    := {}

Local cCurrentFld:= ""
Local xCurrentVld:= Nil

	oBody:FromJSon(Self:GetContent())
	itensJson := oBody:GetNames()
	cTable := oBody['table']
	aCampos := oBody['fields']

	// Monta os campos do Select
	For nX := 1 to Len(aCampos)
		cQuery += "?,"

		aAdd(aParams, {"U", JQryStFld(aCampos[nX], cTpDtBase)} )
	Next nX

	cQuery := SubStr(cQuery, 1, Len(cQuery) - 1)

	cCpoFil := Iif(Substr(cTable,1,1) == "S", Substr(cTable,2)+"_FILIAL", cTable+"_FILIAL") // Campo de filial da tabela
	cQuery += " FROM " + RetSqlName(cTable)
	cQuery += " WHERE ? = ?"
		
	aAdd(aParams, {"U", cCpoFil } )
	aAdd(aParams, {"C", xFilial(cTable) } )

	cQuery += " AND D_E_L_E_T_ = ' '"

	If (!Empty(oBody['defaultFilter']))
		cQuery += " AND ?"
		aAdd(aParams, {"U", oBody['defaultFilter']} )
	EndIf
	
	// Monta os filtros informados
	For nX := 1 to Len(oBody['filter'])
		cCurrentFld := AllTrim(oBody['filter'][nX]['field'])
		xCurrentVld := AllTrim(oBody['filter'][nX]['value'])
		
		// Pega o nome do campo sem a tabela
		cBlq := Iif(Substr(cTabela,1,1) == "S", Substr(cCurrentFld,4), Substr(cCurrentFld,5))

		If cBlq $ "MSBLQL|BLOCKED|BLOQ" // Inverte a logica para campos de Bloqueio, pois existe a possibilidade de estarem em branco e serem validos
			cQuery +=  " AND ? <> ?"
			aAdd(aParams, { "U", cCurrentFld })
			aAdd(aParams, { ValType(xCurrentVld), xCurrentVld })
		Else
			cQuery +=  " AND ? = ?"
			aAdd(aParams, { "U", cCurrentFld })
			aAdd(aParams, { ValType(xCurrentVld), xCurrentVld })
		EndIf
	Next nX

	cSearchKey := Decode64(oBody['searchkey']['value'])
	aCpoSrch := oBody['searchkey']['fields']

	// Monta o filtro informado
	If !Empty(cSearchKey)
		cSearchKey := '%' + Lower(Trim(StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' ))) + '%'
		For nX := 1 to Len(aCpoSrch)
			// Valida se o filtro vai ser singular ou composto
			If Len(aCpoSrch[nX]) > 10
				cCpoComp := StrTran(aCpoSrch[nX], "|", "||")
				
				cQuery += " OR LOWER(?) LIKE ? "
				aAdd(aParams, { "U",  cCpoComp })
				aAdd(aParams, { "C",  cSearchKey })
			Else
				cCpoComp := aCpoSrch[nX]
				If nX == 1
					cQuery += " AND (LOWER(LTRIM(RTRIM(?))) LIKE ?"
					cQuery +=  " OR LOWER(LTRIM(RTRIM(?))) LIKE ?"
					aAdd(aParams, { "U",  cCpoComp })
					aAdd(aParams, { "C",  cSearchKey })
					aAdd(aParams, { "U",  JurFormat(cCpoComp, .T./*lAcentua*/) })
					aAdd(aParams, { "C",  cSearchKey })
				Else
					cQuery += " OR LOWER(LTRIM(RTRIM(?))) LIKE ?"
					cQuery +=  " OR LOWER(LTRIM(RTRIM(?))) LIKE ?"
					aAdd(aParams, { "U",  cCpoComp })
					aAdd(aParams, { "C",  cSearchKey })
					aAdd(aParams, { "U",  JurFormat(cCpoComp, .T./*lAcentua*/) })
					aAdd(aParams, { "C",  cSearchKey })
				EndIf
			EndIf
		Next nX
		cQuery +=  ")"
	EndIf

	If (aScan(itensJson, "order") > 0 .And. Len(oBody['order']) > 0)
		cQuery += " ORDER BY "
		For nX := 1 To Len(oBody['order'])
			If (Lower(oBody['order'][nX]['orderType']) == "desc")
				cQuery += " LOWER(LTRIM(RTRIM(?))) DESC,"
			Else
				cQuery += " LOWER(LTRIM(RTRIM(?))),"
			EndIf
			
			aAdd(aParams, {"U", oBody['order'][nX]['field']})
		Next nX

		cQuery := SubStr(cQuery, 1, Len(cQuery) - 1)
	EndIf

	oQuery := FWPreparedStatement():New(cQuery)

	oQuery := JQueryPSPr(oQuery, aParams)
	cQuery := oQuery:GetFixQuery()
	cQuery := StrTran(cQuery, "' '", "'#$#'") // Tratamento para não tirar o ' ' com espaço

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery, "'#$#'", "' '") // Tratamento para Multibanco

	cAliasQry := GetNextAlias() // Alias para a Query
	MpSysOpenQuery(cQuery, cAliasQry)

	oResponse["info"] := {}

	While !(cAliasQry)->(Eof()) .And. nIndexJSon < nPage

		nIndexJSon++
		aAdd(oResponse["info"], JsonObject():New())

		//Laço para preencher as informações do objeto JSON
		For nX:= 1 to Len(aCampos)
			oResponse["info"][nIndexJSon][aCampos[nX]] := JConvUTF8((cAliasQry)->(&(aCampos[nX])))
		Next nX

		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DbCloseArea())

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
	oResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JQryStFld(cNomeCampo, cTpDb)
Verifica o tipo do Campo para retornar para o SELECT

@param cNomeCampo: Nome do campo a ser avaliado
@param cTpDb: Tipo do Banco 

@return cRet: Retorno do field

@author Willian Kazahaya
@since 13/03/2024
/*/
//-------------------------------------------------------------------
Static Function JQryStFld(cNomeCampo, cTpDb)
Local cTipoFld := AllTrim(getSx3Cache(AllTrim(cNomeCampo) ,'X3_TIPO'))
Local cRet     := ""
Local nTam     := 8000
Local nReduz   := 0

Default cTpDb := AllTrim(Upper(TCGetDB())) // Tipo de database do sistema
	If (cTpDb == "ORACLE" .OR. cTpDb == "POSTGRES")
		nTam := 4000
	EndIf

	If (cTipoFld == "M")
		cRet := JQryMemo( cNomeCampo, cTpDb, nReduz, nTam ) + " " + cNomeCampo
	Else
		cRet := cNomeCampo
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetPagSize(nPage, nPageSize)
Calcula a Paginação

@param nPage - Numero da pagina
@param nPageSize - Quantidade de registros por pagina

@returns [1] - Indica se haverá filtro ou não
		 [2] - Indice do registro inicial
		 [3] - Indice do registro final

@author Willian Kazahaya
@since 13/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function JStPagSize(nPage, nPageSize)
Local lFiltraPag := (nPageSize != Nil .And. nPage != Nil)
Local nRegMin    := 0
Local nRegMax    := 0

	If (lFiltraPag)
		nRegMax := Val(nPage) * Val(nPageSize)
		nRegMin := (Val(nPage)-1) * Val(nPageSize)
	EndIf
Return { lFiltraPag, nRegMin, nRegMax }


//------------------------------------------------------------------------------
/* /{Protheus.doc} JAddFldMVC()
Função responsável por setar os campos na estrutura
@param oStruct, object, (Descrição do parâmetro)

@since 04/06/2024
@version 1.0
/*/
//------------------------------------------------------------------------------
Function JAddFldMVC(oStruct,cField)
	oStruct:AddField(;
		FWX3Titulo(cField)                                                      , ; // [01] C Titulo do campo
		""                                                                      , ; // [02] C ToolTip do campo
		cField                                                                  , ; // [03] C identificador (ID) do Field
		TamSx3(cField)[3]                                                       , ; // [04] C Tipo do campo
		TamSx3(cField)[1]                                                       , ; // [05] N Tamanho do campo
		TamSx3(cField)[2]                                                       , ; // [06] N Decimal do campo
		FwBuildFeature(STRUCT_FEATURE_VALID,GetSx3Cache(cField,"X3_VALID") )    , ; // [07] B Code-block de validação do campo
		NIL                                                                     , ; // [08] B Code-block de validação When do campoz
		NIL                                                                     , ; // [09] A Lista de valores permitido do campo
		.F.                                                                     , ; // [10] L Indica se o campo tem preenchimento obrigatório
		FwBuildFeature(STRUCT_FEATURE_INIPAD,GetSx3Cache(cField,"X3_RELACAO") ) , ; // [11] B Code-block de inicializacao do campo
		.F.                                                                     , ; // [12] L Indica se trata de um campo chave
		.F.                                                                     , ; // [13] L Indica se o campo pode receber valor em uma operação de update.
		.T.                                                                     ;   // [14] L Indica se o campo é virtual
	)
Return 
