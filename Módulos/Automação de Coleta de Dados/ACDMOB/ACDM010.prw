#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'protheus.ch'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "ACDM010.ch"

Static _oHMACDQry := HMNew()
Static __aQryMD5  := {}
Static __lSaOrdSep  := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ACDMOB

Classe responsável por retornar uma Listagem de Documentos para conferencia

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//------------------------------------------------------------------------------
WSRESTFUL ACDMOB DESCRIPTION "Retorna uma lista de Documentos para conferencia"

	WSDATA SearchKey 		AS STRING	OPTIONAL
	WSDATA Status			AS STRING  	OPTIONAL
	WSDATA Page				AS INTEGER	OPTIONAL
	WSDATA PageSize			AS INTEGER	OPTIONAL
	WSDATA Code				AS STRING	OPTIONAL
	WSDATA statusOs			AS STRING  	OPTIONAL
	WSDATA ordemSep			AS STRING  	OPTIONAL

	WSDATA Sku				AS STRING	OPTIONAL
	WSDATA Warehouse		AS STRING	OPTIONAL
	WSDATA Document			AS STRING	OPTIONAL
	WSDATA Serie			AS STRING	OPTIONAL
	WSDATA Sequence			AS STRING	OPTIONAL
	WSDATA Supplier			AS STRING	OPTIONAL
	WSDATA Store			AS STRING	OPTIONAL
	WSDATA productId		AS STRING   OPTIONAL	// Código de pesquisa de um produto específico
	WSDATA searchSNumber 	AS STRING	OPTIONAL 	// Parâmetro para pesquisa de número de série

/*------------------------GETs--------------------------------------------*/

/*-------------------Get Conferência--------------------------------------*/
	WSMETHOD GET;
		DESCRIPTION "Retorna uma lista de Documentos para conferencia";
		WSSYNTAX "CHECKINGS/{SearchKey, Status, Page, PageSize}";
		PATH "checkings"       PRODUCES APPLICATION_JSON

	WSMETHOD GET  Code;
		DESCRIPTION "Retorna uma  Documento para conferencia";
		WSSYNTAX "CHECKINGS/{Code}";
		PATH "checkings/{code}"       PRODUCES APPLICATION_JSON

/*-------------------Get Separação--------------------------------------*/
	WSMETHOD GET  Separations;
		DESCRIPTION "Retorna uma lista de Documentos para separacao";
		WSSYNTAX "separations/{SearchKey, Status, Page, PageSize, statusOs, ordemSep}";
		PATH "separations"       PRODUCES APPLICATION_JSON


/*-------------------Get Separação--------------------------------------
WSMETHOD GET  oneSeparations;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "oneseparations/{SearchKey, Status, Page, PageSize,statusOs, ordemSep}";
PATH "oneseparations"       PRODUCES APPLICATION_JSON */

/*-------------------Get Inventario--------------------------------------*/
WSMETHOD GET  inventories;
DESCRIPTION "Retorna uma lista de Documentos para inventario";
WSSYNTAX "inventories/{SearchKey, Status, Page, PageSize}";
PATH "inventories"       PRODUCES APPLICATION_JSON


WSMETHOD GET  Code_inventories ;
DESCRIPTION "Retorna uma lista de Documentos para inventario";
WSSYNTAX "inventories/{Code}";
PATH "inventories/{code}"       PRODUCES APPLICATION_JSON


/*-------------------Gets Transferencia--------------------------------------*/

/*-------------------Get Produtos--------------------------------------*/
WSMETHOD GET  Products;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "products/{SearchKey, Status, Page, PageSize, productId, supplier, store, searchSNumber }";
PATH "products"       PRODUCES APPLICATION_JSON

/*-------------------Get Armazens--------------------------------------*/
WSMETHOD GET  Warehouse;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "warehouse/{SearchKey, Status, Page, PageSize}";
PATH "warehouse"       PRODUCES APPLICATION_JSON

/*-------------------Get Endereços--------------------------------------*/
WSMETHOD GET  Address;
DESCRIPTION "Retorna uma lista de Documentos para separacao";
WSSYNTAX "address/{SearchKey, Status, Page, PageSize}";
PATH "address"       PRODUCES APPLICATION_JSON

/*-------------------Get Divergences--------------------------------------*/
WSMETHOD GET  Divergences;
DESCRIPTION "Retorna uma lista de documentos para divergências";
WSSYNTAX "divergences/{SearchKey, Status, Page, PageSize}";
PATH "divergences"       PRODUCES APPLICATION_JSON

/*-------------------Get ApiVersion--------------------------------------*/
WSMETHOD GET  ApiVersion;
DESCRIPTION "Retorna a versão da API usada para o APP";
WSSYNTAX "ApiVersion/{SearchKey, Page, PageSize}";
PATH "ApiVersion"       PRODUCES APPLICATION_JSON

/*-------------------Gets Endereçamento--------------------------------------*/

/*-------------------Get Produtos a Endereçar--------------------------------*/
WSMETHOD GET toAddressDetail;
DESCRIPTION "Retorna uma lista de produtos a endereçar";
WSSYNTAX "toAddressDetail/{SearchKey, Page, PageSize, Sku, Warehouse, Document, Serie, Sequence, Supplier, Store}";
PATH "toAddressDetail"       PRODUCES APPLICATION_JSON

/*-------------------Get Produtos a Endereçar--------------------------------*/
WSMETHOD GET docToAddr;
DESCRIPTION "Retorna uma lista de documentos a endereçar";
WSSYNTAX "docToAddr/{SearchKey, Page, PageSize}";
PATH "docToAddr"       PRODUCES APPLICATION_JSON


/*------------------------PUTs--------------------------------------------*/

/*-------------------Put Conferência--------------------------------------*/
WSMETHOD PUT;
DESCRIPTION "Atualiza o Status da conferência no Protheus.";
WSSYNTAX "CHECKINGS/{Code}";
PATH "checkings/{code}"   PRODUCES APPLICATION_JSON

/*-------------------Put Separação--------------------------------------*/
WSMETHOD PUT Separations;
DESCRIPTION "Atualiza o Status da separação no Protheus.";
WSSYNTAX "SEPARATIONS/{Code}";
PATH "separations/{Code}"   PRODUCES APPLICATION_JSON

/*-------------------Put Separação--------------------------------------
WSMETHOD PUT oneSeparations;
DESCRIPTION "Atualiza o Status da separação no Protheus.";
WSSYNTAX "ONESEPARATIONS/{Code}";
PATH "oneseparations/{Code}"   PRODUCES APPLICATION_JSON */

/*-------------------Put Desfaz Separação-------------------------------*/
WSMETHOD PUT undoSeparations;
DESCRIPTION "Estorna a Separação e atualiza o Status no Protheus.";
WSSYNTAX "UNDOSEPARATIONS/{Code}";
PATH "undoseparations/{Code}"   PRODUCES APPLICATION_JSON

/*-------------------Put Inventario--------------------------------------*/
WSMETHOD PUT inventories;
DESCRIPTION "Atualiza o Status do inventario no Protheus.";
WSSYNTAX "inventories/{Code}";
PATH "inventories/{Code}"   PRODUCES APPLICATION_JSON

/*-------------------Put divergences--------------------------------------*/
WSMETHOD PUT Divergences;
DESCRIPTION "Associar divergência ao registro da ordem de separação.";
WSSYNTAX "divergences/{Code}";
PATH "divergences/{Code}"   PRODUCES APPLICATION_JSON

/*-------------------Put lotes--------------------------------------------*/
WSMETHOD PUT validLotes;
DESCRIPTION "Retorna uma validación del lote lido";
WSSYNTAX "validLotes/{Code}";
PATH "validLotes/{Code}" PRODUCES APPLICATION_JSON

/*-------------------Put enderecos----------------------------------------*/
WSMETHOD PUT validAddress;
DESCRIPTION "Retorna uma validação do endereço lido";
WSSYNTAX "validAddress/{Code}";
PATH "validAddress/{Code}" PRODUCES APPLICATION_JSON

/*------------------------POSTs--------------------------------------------*/
/*-------------------POST transferencia--------------------------------------*/
WSMETHOD POST transfer;
DESCRIPTION "Finaliza a transferencia do produto no Protheus.";
WSSYNTAX "transfer";
PATH "transfer"   PRODUCES APPLICATION_JSON

/*-------------------Get Saldo por endereco ou lote--------------------------------*/
WSMETHOD GET stockBalance;
DESCRIPTION "Retorna saldo de endereco ou lote do produto";
WSSYNTAX "stockBalance/{SearchKey, Page, PageSize, productId}";
PATH "stockBalance" PRODUCES APPLICATION_JSON

/*-------------------POST endereçamento --------------------------------------*/
WSMETHOD POST ToAddress ; 
    DESCRIPTION "Inclusao de enderecamento de produto." ;
    WSSYNTAX "toAddress" ;
    PATH "toAddress" PRODUCES APPLICATION_JSON

/*-------------------Put Encerra Separação-------------------------------*/
WSMETHOD PUT closePicking;
DESCRIPTION "Encerra separação - Apenas para separação de origem de uma solicitação ao armazém";
WSSYNTAX "separations/{Code}/closePicking";
PATH "separations/{Code}/closePicking"   PRODUCES APPLICATION_JSON


END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de Documentos para conferencia.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET  WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cType				:= '1'
Local cCodOpe   		:= CBRetOpe()
Local oJCheck 			:= JsonObject():New()
Local aJCheck		  	:= {}
Local lHasNext			:= .F.
Local cFilOld			:= cFilant
Local cTpConf           := ''

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 20

Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0002 //'Usuario nao cadastrado como conferente'
	 lRet			   := .F.
EndIf
If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))



	    GetCheck(1,UPPER(Self:SearchKey),Self:Status,cAlias )
	    If (cAlias)->(!EOF())

			cTpConf := SuperGetMv("MV_TPCONFF", .F., "1")

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
			If Self:PageSize > 10
				Self:PageSize := 10
			EndIf

	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJCheck 			:=  JsonObject():New()

	        While (cAlias)->(!EOF())

				// Conferencia por pre-nota exibir somente notas nao classificadas
				If ((cAlias)->TPCOF == "1" .Or. ((cAlias)->TPCOF == "0" .And. cTpConf == "1")) .And. !Empty((cAlias)->STATUS)
					(cAlias)->(DbSkip())
					Loop
				EndIf

	            nCount++

	            If (nCount >= nStart)

	                nEntJson++
	                 cType := If ( (cAlias)->TPCOF <> '0' , (cAlias)->TPCOF, cTpConf )

	                aAdd( aJCheck,  JsonObject():New() )
	                aJCheck[nEntJson]["code"			]	:= AllTrim( (cAlias)->CODE   				)
					aJCheck[nEntJson]["type"			]	:= cType
					aJCheck[nEntJson]["number"			]	:= AllTrim( (cAlias)->DOC    				)
	                If (cAlias)->TIPO $ "D|B"
						aJCheck[nEntJson]["supplier_name"	]	:= ""
						aJCheck[nEntJson]["customer_name"	]	:= EncodeUTF8(  AllTrim( (cAlias)->NAME 	) )	
					Else
						aJCheck[nEntJson]["supplier_name"	]	:= EncodeUTF8(  AllTrim( (cAlias)->NAME 	) )
						aJCheck[nEntJson]["customer_name"	]	:= ""
					Endif
	                aJCheck[nEntJson]["danfe"			]	:= AllTrim( (cAlias)->DANFE      			)
	                aJCheck[nEntJson]["status"			]	:= '0'



	                If nEntJson < Self:PageSize .And. nCount < nRecord
	                    //cResponse += ', '
	                Else
	                    Exit
	                EndIf

	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

	            (cAlias)->(DbSkip())
	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord
	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJCheck 				:=  JsonObject():New()
	    	oJCheck["checkings"]	:= aJCheck
	    	oJCheck["hasNext"] 		:= lHasNext

	    Endif

	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif


If lRet
	oJCheck["checkings"]	:= aJCheck
	oJCheck["hasNext"] 	:= lHasNext
	cResponse := FwJsonSerialize( oJCheck )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJCheck) == "O"
	FreeObj(oJCheck)
	oJCheck := Nil
Endif


Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} GetCheck()
Constroi um Query com a Seleção de dados para conferencias

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetCheck(nGet,cSearch,cStatus,cAliasQry,cCode )

Local cConcat       := IIF( !"MSSQL" $ TCGetDB(), "||", "+" )
Local cWhere		:= "% "
Local cSelect		:= "% ,F1_DOC " +  cConcat + " F1_SERIE " +  cConcat + " F1_FORNECE " +  cConcat + " F1_LOJA  CODE %"

Default cSearch     := ''
Default cStatus   	:= '1'
Default cCode	  	:= ' '

If nGet == 1

	If 	Len(alltrim(cSearch))== 1
		If alltrim(cSearch) == "'"
			cSearch     := '"'
		Endif
	Else
		cSearch := REPLACE(cSearch,"'","")
	Endif
	cSearch :=  AllTrim(Upper(FwNoAccent(cSearch)))
	If !Empty(cSearch)
	    cWhere  += " AND ( F1_DOC LIKE '%"  + cSearch + "%' OR" 
	    cWhere  += " F1_CHVNFE  LIKE '%"  	+ cSearch + "%' OR"
	    cWhere  += " ( F1_TIPO NOT IN ('D','B') AND  ( A2_COD   LIKE '%" + cSearch + "%' OR"
	    cWhere  +=                                   " A2_NOME	LIKE '%" + cSearch + "%' OR"
	    cWhere  +=                                   " A2_CGC   LIKE '%" + cSearch + "%' )) OR"
	    cWhere  += " ( F1_TIPO     IN ('D','B') AND  ( A1_COD   LIKE '%" + cSearch + "%' OR"
	    cWhere  +=                                   " A1_NOME	LIKE '%" + cSearch + "%' OR"
	    cWhere  +=                                   " A1_CGC   LIKE '%" + cSearch + "%' )))"
	EndIf
	cWhere  += " %"

	BeginSQL Alias cAliasQry

	SELECT F1_DOC DOC, F1_STATUS STATUS, F1_CHVNFE DANFE, 
	CASE F1_TIPO
	WHEN 'D' THEN A1_NOME
	WHEN 'B' THEN A1_NOME
	ELSE A2_NOME END NAME, 
	CASE F1_TIPO
	WHEN 'D' THEN '0'
	WHEN 'B' THEN '0'
	ELSE
	A2_CONFFIS END TPCOF, F1_TIPO TIPO
	%EXP:cSelect%
	FROM
		%Table:SF1% SF1
		LEFT JOIN %Table:SA2% SA2
			On SA2.A2_FILIAL = %xFilial:SA2%
			AND SF1.F1_TIPO NOT IN ('D','B')
			AND SA2.A2_COD = SF1.F1_FORNECE
			AND SA2.A2_LOJA = SF1.F1_LOJA
			AND SA2.%NotDel%
		LEFT JOIN %Table:SA1% SA1
			On SA1.A1_FILIAL = %xFilial:SA1%
			AND SF1.F1_TIPO IN ('D','B')
			AND SA1.A1_COD = SF1.F1_FORNECE
			AND SA1.A1_LOJA = SF1.F1_LOJA
			AND SA1.%NotDel%
	WHERE
		SF1.F1_FILIAL = %xFilial:SF1%
		AND SF1.F1_STATCON	= '0'
		AND SF1.%NotDel%
		%EXP:cWhere%
	EndSQL

Else

	cWhere += " AND F1_DOC " +  cConcat + " F1_SERIE " +  cConcat + " F1_FORNECE " +  cConcat + " F1_LOJA  = '" +  cCode + "' %"

	BeginSQL Alias cAliasQry
	SELECT F1_DOC DOC,F1_CHVNFE DANFE, 
	CASE F1_TIPO
	WHEN 'D' THEN A1_NOME
	WHEN 'B' THEN A1_NOME
	ELSE A2_NOME END NAME, 
	A2_CONFFIS TPCOF,CBE_NOTA NOTA, CBE_CODPRO CODPRO, F1_TIPO TIPO
	FROM
		%Table:SF1% SF1
		LEFT JOIN %Table:SA2% SA2
			On SA2.A2_FILIAL = %xFilial:SA2%
			AND SF1.F1_TIPO NOT IN ('D','B')
			AND SA2.A2_COD = SF1.F1_FORNECE
			AND SA2.A2_LOJA = SF1.F1_LOJA
			AND SA2.%NotDel%
		LEFT JOIN %Table:SA1% SA1
			On SA1.A1_FILIAL = %xFilial:SA1%
			AND SF1.F1_TIPO IN ('D','B')
			AND SA1.A1_COD = SF1.F1_FORNECE
			AND SA1.A1_LOJA = SF1.F1_LOJA
			AND SA1.%NotDel%
		LEFT JOIN %Table:CBE% CBE On
			CBE.CBE_FILIAL = SF1.F1_FILIAL
			AND	CBE.CBE_NOTA = SF1.F1_DOC
			AND	CBE.CBE_SERIE = SF1.F1_SERIE
			AND	CBE.CBE_FORNEC = SF1.F1_FORNECE
			AND	CBE.CBE_LOJA = SF1.F1_LOJA
			AND CBE.%NotDel%
	WHERE
		SF1.F1_FILIAL = %xFilial:SF1%
		AND SF1.%NotDel%
		%EXP:cWhere%
	EndSQL
EndIf


Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT / ACDMOB
 Altera o Status da conferencia ou finaliza no protheus

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD PUT WSSERVICE ACDMOB
Local oJChecking	:= Nil
Local nStatusCode   := 500
Local nDocItem		:= 0
Local cMessage		:= STR0001 //'Erro Interno'
Local cResponse 	:= ""
Local cBody			:= ""
Local cAliasDoc		:= ""
Local nX			:= 0
Local lRet			:= .T.
Local cNota     	:= ""
Local cSerie    	:= ""
Local cFornec   	:= ""
Local cLoja     	:= ""
Local cType			:= '1'
Local cCodOpe   	:= CBRetOpe()
Local oJCheck 		:= JsonObject():New()
Local aJCheckDoc	:= {}
Local cLote			:= ''
Local cDtValid		:= ''
Local dValidOrigem	:= ''
Local aRet			:= {}
Local aAreaSD1      := SD1->(GetArea())
Local nTamPRD       := TAMSX3("D1_COD")[1]
Local lClaCfDv  	:= SuperGetMv("MV_CLACFDV",.F.,.F.)

Self:SetContentType("application/json")


If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          :=STR0002 // 'Usuario nao cadastrado como conferente'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			oJChecking := JsonObject():New()

			If oJChecking:FromJSON(cBody) == Nil
				cNota     := Substr(Self:aURLParms[2],1,TamSX3("F1_DOC")[1])
				cSerie    := Substr(Self:aURLParms[2],TamSX3("F1_DOC")[1]+1,TamSX3("F1_SERIE")[1])
				cFornec   := Substr(Self:aURLParms[2],TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+1,TamSX3("F1_FORNECE")[1])
				cLoja     := Substr(Self:aURLParms[2],TamSX3("F1_DOC")[1]+TamSX3("F1_SERIE")[1]+TamSX3("F1_FORNECE")[1]+ 1,TamSX3("F1_LOJA")[1])

				SF1->(DbSetOrder(1))
				If SF1->( DbSeek( padr(xFilial("SF1"),TAMSX3("F1_FILIAL")[1]) + cNota + cSerie + cFornec + cLoja) ) .AND. !SF1->F1_STATCON $ "1|4" .AND. !EMPTY(SF1->F1_STATCON)

					If SF1->F1_TIPO $ "D|B"
						SA1->(DbSetOrder(1))  // A1_FILIAL+A1_COD+A1_LOJA
						SA1->( DbSeek( padr(xFilial("SA1"),TAMSX3("A1_FILIAL")[1]) + cFornec + cLoja) )
						cType := SuperGetMv("MV_TPCONFF",.F.,'1')
					Else
						SA2->(DbSetOrder(1))
						SA2->( DbSeek( padr(xFilial("SA2"),TAMSX3("A2_FILIAL")[1]) + cFornec + cLoja) )
						cType := If ( SA2->A2_CONFFIS <> '0' , SA2->A2_CONFFIS,SuperGetMv("MV_TPCONFF",.F.,'1') )
					Endif
					If oJChecking["status"] == '2'

						If  oJChecking:HasProperty("products")
							oJCheck 			:=  JsonObject():New()
							For nX := 1 To Len( oJChecking[ "products" ] )
								cLote			:= ''
								cDtValid		:= CtoD("  /  /  ")
								dValidOrigem	:= CtoD("  /  /  ")
							
								If oJChecking[ "products" ][nX]:HasProperty("batch") .AND. !EMPTY(oJChecking[ "products" ][nX][ "batch" ])
									cLote	:= oJChecking[ "products" ][nX][ "batch" ]
								EndIf
								If oJChecking[ "products" ][nX]:HasProperty("batchDate")
									If !EMPTY(oJChecking[ "products" ][nX][ "batchDate" ])
										cDtValid := CtoD(oJChecking[ "products" ][nX][ "batchDate" ])
									EndIf

									SD1->(DbOrderNickName("ACDSD101"))  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_LOTECTL+D1_NUMLOTE+DTOS(D1_DTVALID)
									If SD1->( DbSeek( xFilial("SD1") + cNota + cSerie + cFornec + cLoja + padr(oJChecking[ "products" ][nX][ "code" ],nTamPrd) + cLote) )
										dValidOrigem := SD1->D1_DTVALID
									EndIf
									RestArea(aAreaSD1)
								EndIf

								aRet:= GrvCBE(oJChecking["status"],Space(10),cNota,cSerie,cFornec,cLoja,oJChecking[ "products" ][nX][ "code" ],;
								             oJChecking[ "products" ][nX][ "quantity" ],cLote,cDtValid,@cMessage,@nStatusCode,cCodOpe,dValidOrigem )//

								If !aRet[1] .And. !lClaCfDv
									lRet 		:= .F.
									nStatusCode	:= 400
									cMessage 	:= aRet[2]
								Endif

							Next nX

							If lRet
					            oJCheck["code"			]	:= Alltrim(Self:aURLParms[2]   				)
								oJCheck["type"			]	:= cType
								oJCheck["number"		]	:= cNota
								If SF1->F1_TIPO $ "D|B"
									oJCheck["supplier_name"	]	:= ""
									oJCheck["customer_name"	]	:= EncodeUTF8(  AllTrim(SA1->A1_NOME  	) )
								Else
					            	oJCheck["supplier_name"	]	:= EncodeUTF8(  AllTrim(SA2->A2_NOME  	) )
									oJCheck["customer_name"	]	:= ""
								Endif
					            oJCheck["danfe"			]	:= Alltrim(SF1->F1_CHVNFE     			)
					            oJCheck["status"		]	:= '2'
							Else
								RecLock("SF1",.F.)
								SF1->F1_STATCON := "2"
								SF1->F1_QTDCONF := SF1->F1_QTDCONF+1
								SF1->(MsUnlock())
				            Endif
				        Else
				        	lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0014 //"Dados da conferencia nao enviados..."
						Endif

					Else

						RecLock("SF1",.F.)
						SF1->F1_STATCON := "3"
						SF1->(MsUnlock())

					    oJCheck["code"			]	:= Alltrim(Self:aURLParms[2]   				)
						oJCheck["type"			]	:= cType
						oJCheck["number"		]	:= cNota
						If SF1->F1_TIPO $ "D|B"
							oJCheck["supplier_name"	]	:= ""
							oJCheck["customer_name"	]	:= EncodeUTF8(  AllTrim(SA1->A1_NOME  	) )
						Else
			            	oJCheck["supplier_name"	]	:= EncodeUTF8(  AllTrim(SA2->A2_NOME  	) )
							oJCheck["customer_name"	]	:= ""
						Endif
					    oJCheck["danfe"			]	:= Alltrim(SF1->F1_CHVNFE     			)
					    oJCheck["status"		]	:= '1'
						
						cAliasDoc := GetNextAlias()

					    GetItNota(@cAliasDoc)

						While (cAliasDoc)->(!EOF())
							nDocItem++
							aAdd( aJCheckDoc,  JsonObject():New() )
							aRet := GetBarCode((cAliasDoc)->D1_COD, (cAliasDoc)->B1_CODBAR, cFornec,cLoja)
							If Len(aRet) <= 1
								aRet := aRet[1]
							EndIf
							aJCheckDoc[nDocItem]["item"				]	:= (cAliasDoc)->D1_ITEM
							aJCheckDoc[nDocItem]["product"			]	:= (cAliasDoc)->D1_COD
							aJCheckDoc[nDocItem]["barcode"			]	:= aRet						
							aJCheckDoc[nDocItem]["quantity"			]	:= (cAliasDoc)->D1_QUANT
							aJCheckDoc[nDocItem]["batch"			]	:= (cAliasDoc)->D1_LOTECTL
							aJCheckDoc[nDocItem]["batchDate"		]	:= (cAliasDoc)->D1_DTVALID

							(cAliasDoc)->(DbSkip())
						End
						 oJCheck["itensDoc"] := aJCheckDoc
						 aJCheckDoc := {}
						If Select(cAliasDoc) > 0
							(cAliasDoc)->(dbCloseArea())
						EndIf

					Endif
				Else
					lRet 		:= .F.
					nStatusCode	:= 404
					cMessage 	:= STR0004 //"Conferencia nao encontrada..."
				Endif
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf



If lRet
	If oJChecking["status"] == '2'
		StatusSF1(cNota,cSerie,cFornec,cLoja, .T.)
	Endif
	cResponse := oJCheck:ToJson()
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJCheck) == "O"
	FreeObj(oJCheck)
	oJCheck := Nil
Endif


Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCBE
 Função que grava a tabela CBE
@param	Code, array com dados para mudança do status

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function GrvCBE(cStatus,cID,cNota,cSerie,cFornec,cLoja,cProduto,nQtde,cLote,dValid,cMessage,nStatusCode,cCodOpe,dValidOrigem)

Local lRet		  := .T.
Local cMsgRet	  := ""
Local lDiverg	  := .F.
Local lPesqSA5    := SuperGetMv("MV_CBSA5",.F.,.F.)
Local cAliasB1	  := ""
Local aProd		  := {}
Local cQuery	  := ""
Local oExec		  := Nil

Static aCB0  	  := {}

Default cProduto  		:= ''
Default nQtde 	  		:= 0
Default cLote 	  		:= ''
Default dValid 	  		:= CtoD("  /  /  ")
Default dValidOrigem	:= CtoD("  /  /  ")

If !Empty(cLote)
	
	If Empty(dValid)

		aProd := CBRetEtiEan(cProduto)

		If Len(aProd) > 0
			dValid := aProd[4]
		EndIf

		// A data de validade do Lote será corrigida de acordo com a data de validade original 
		If dValid <> dValidOrigem
        	dValid := dValidOrigem
    	EndIf
	EndIf

EndIf

	If cStatus = '2'
		lDiverg	:= .F.

		cQuery := " SELECT B1_COD "
		cQuery += " 	,B1_PRVALID "
		cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
		cQuery += " WHERE SB1.B1_FILIAL = ? "
		cQuery += " AND ( "
		cQuery += " 		SB1.B1_CODBAR = ? "
		cQuery += " 		OR SB1.B1_COD = ? "
		cQuery += " 		) "
		cQuery += " AND SB1.B1_MSBLQL <> ? "
		cQuery += " AND SB1.D_E_L_E_T_ = ? "

		oExec := saveQryMD5(cQuery)

		oExec:SetString(1, FWxFilial("SB1"))
		oExec:SetString(2, cProduto)
		oExec:SetString(3, cProduto)
		oExec:SetString(4, "1")
		oExec:SetString(5, "")

		cAliasB1 := oExec:OpenAlias()
		
		If (cAliasB1)->(!EOF())
			cProduto := (cAliasB1)->B1_COD

			If !Empty(cLote) .And. Empty(dValid)
				dValid := dDataBase + (cAliasB1)->B1_PRVALID
			EndIf

		Else
			SA5->(dbSetorder(8)) //A5_CODBAR
			If lPesqSA5 .and. SA5->(dbSeek(padr(xFilial("SA5"),TAMSX3("A5_FILIAL")[1])+cFornec+cLoja+Padr(AllTrim(cProduto),TamSX3("A5_CODBAR")[1])))
				cProduto := SA5->A5_PRODUTO
				SB1->(DbSetOrder(1))
				If !SB1->(DBSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+cProduto))
					lDiverg	:= .T.
				Else
					If !Empty(cLote) .And. Empty(dValid)
						dValid := dDataBase + SB1->B1_PRVALID
					EndIf
				Endif
			Else
				SLK->( dbSetOrder(1) )
				If SLK->( DBSeek(padr(xFilial("SLK"),TAMSX3("LK_FILIAL")[1])+cProduto) )
					cProduto := SLK->LK_CODIGO
					If !SB1->(DBSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+cProduto))
						lDiverg	:= .T.
					Else
						If !Empty(cLote) .And. Empty(dValid)
							dValid := dDataBase + SB1->B1_PRVALID
						EndIf
					Endif
				Else
					lDiverg	:= .T.
				Endif
			Endif

		Endif

		If !lDiverg

			CBE->(DbSetOrder(1))
			cID := Padr(cID,10)
			If	CBE->(DBSeek(padr(xFilial("CBE"),TAMSX3("CBE_FILIAL")[1])+cID+cNota+cSerie+cFornec+cLoja+cProduto+cLote))
				If ! UsaCB0("01")
					RecLock("CBE",.f.)
					CBE->CBE_CODUSR	:= cCodOpe
					CBE->CBE_DATA	:= dDatabase
					CBE->CBE_HORA	:= Time()
					CBE->CBE_QTDE   += nQtde
					CBE->(MsUnLock())
				EndIf
			Else
				RecLock("CBE",.T.)
				CBE->CBE_FILIAL	:= xFilial("CBE")
				CBE->CBE_NOTA	:= cNota
				CBE->CBE_SERIE	:= cSerie    //SerieNfId("CBE",1,"CBE_SERIE",,,cSerie)
				CBE->CBE_FORNEC	:= cFornec
				CBE->CBE_LOJA	:= cLoja
				CBE->CBE_CODPRO	:= cProduto
				CBE->CBE_QTDE	:= nQtde
				CBE->CBE_LOTECT	:= cLote
				CBE->CBE_CODUSR	:= cCodOpe
				CBE->CBE_DTVLD	:= dValid
				CBE->CBE_CODETI	:= cID
				CBE->CBE_DATA	:= dDatabase
				CBE->CBE_HORA	:= Time()
				CBE->(MsUnLock())
			EndIf

			If confSaldo(cNota, cSerie, cFornec, cLoja, cProduto, cLote, nQtde)
				DistQtdConf(cProduto,nQtde,,cLote,dValid,cNota,cSerie,cFornec,cLoja)

				If Usacb0("01")
					aAdd(aCB0,CB0->CB0_CODETI) //-- Codigo da Etiqueta
					CBGrvEti("01",{,nQtde,cCodOpe,cNota,cSerie,cFornec,cLoja,NIL,NIL,NIL,NIL,NIL,,,,cLote,NIL,dValid},cID)
				EndIf
			Else
				lRet 	:= .F.
				cMsgRet := STR0036 //"Quantidade conferida maior do que o saldo restante."
			EndIf
		Else
			D3V->(DbSetOrder(2))
			If	!D3V->(DBSeek(padr(xFilial("D3V"),TAMSX3("D3V_FILIAL")[1])+'1'+ cNota+cSerie+cFornec+cLoja+cProduto+cLote))
				// Grava a tabela de divergencia
				RecLock("D3V",.t.)
				D3V->D3V_FILIAL	:= xFilial("D3V")
				D3V->D3V_CODIGO	:= GetSXENum("D3V", "D3V_CODIGO")
				D3V->D3V_ORIGEM	:= '1'
				D3V->D3V_MOTIVO	:= '1'
				D3V->D3V_NOTA	:= cNota
				D3V->D3V_SERIE	:= cSerie  // SerieNfId("D3V",1,"D3V_SERIE",,,cSerie)
				D3V->D3V_FORNEC	:= cFornec
				D3V->D3V_LOJA	:= cLoja
				D3V->D3V_CODPRO	:= cProduto
				D3V->D3V_QTDE	:= nQtde
				D3V->D3V_LOTECT	:= cLote
				D3V->D3V_CODUSR	:= cCodOpe
				D3V->D3V_DTVLD	:= dValid
				D3V->D3V_CODETI	:= cID
				D3V->D3V_DATA	:= dDatabase
				D3V->D3V_HORA	:= Time()
				D3V->D3V_STATUS	:= '1'
				D3V->(MsUnLock())
				ConfirmSx8()
			Endif

		Endif

		If Select(cAliasB1) > 0
			(cAliasB1)->(dbCloseArea())
		Endif

	EndIf



Return {lRet, cMsgRet}



//-------------------------------------------------------------------
/*/{Protheus.doc} GET/Code/ACDMOB
Retorna dados do codigo informado

@param  Code    , caracter, Codigo para Pesquisa.


@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		15/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET  Code WSRECEIVE Code WSSERVICE ACDMOB


Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local cType				:= '1'
Local cCodOpe   		:= CBRetOpe()
Local cStatus			:= ''
Local cFilOld			:= cFilant

Default Self:Code  := ''


Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0002 //'Usuario nao cadastrado como conferente'
	 lRet			   := .F.
EndIf
If lRet
   GetCheck(2,,,cAlias,Self:Code )
    If (cAlias)->(!EOF())

        cType 	:= If ( (cAlias)->TPCOF <> '0' , (cAlias)->TPCOF,SuperGetMv("MV_TPCONFF",.F.,1) )
        If Empty((cAlias)->NOTA ) .AND. Empty((cAlias)->CODPRO )
        	cStatus	:= '0'
        ElseIf	!Empty((cAlias)->NOTA) .AND. Empty((cAlias)->CODPRO)
        	cStatus	:= '2'
        Else
        	cStatus	:= '1'
        Endif
        cResponse += '{'
        cResponse +=    '"code":"'   		+ AllTrim( Self:Code		   				)      + '",'
        cResponse +=    '"type":"' 			+ cType											   + '",'
        cResponse +=    '"number":"'   		+ AllTrim( (cAlias)->DOC      )    				   + '",'
        If (cAlias)->TIPO $ "D|B"
			cResponse +=    '"supplier_name":"",'
			cResponse +=    '"customer_name":"' + EncodeUTF8(  AllTrim( (cAlias)->NAME 		) )    + '",'
		Else
			cResponse +=    '"supplier_name":"' + EncodeUTF8(  AllTrim( (cAlias)->NAME 		) )    + '",'
			cResponse +=    '"customer_name":"",'
		Endif
        cResponse +=    '"danfe":"'   		+ AllTrim( (cAlias)->DANFE      			)	   + '",'
        cResponse +=    '"status":"' 		+ cStatus     							       	   + '"'
        cResponse += '}'

    Else
       nStatusCode      := 404
       cMessage         :=STR0004 // "Conferencia nao encontrada"
       lRet			   	:= .F.
    EndIf

Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetSep()
Constroi um Query com a Seleção de dados para separação

@param  cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.
		cSep        , caracter, ordem de separação
		cStatusOS   , caracter, Filtrar o STATUS da ordem de separação ( CB7_STATUS ) Sendo 0-Não Iniciada, 1-Em andamento ( somente do usuário logado) ou  *-para ambas
@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetSep(cSearch,cStatus,cAliasQry,cSep,cStatusOS )
	Local cQuery      := ""
	Local cWhere      := ""
	Local nOrd        := 1
	Local i 		  := 0
	Local cCodOpe     := CBRetOpe()
	Local aBindValue  := {}	
	Local oExec       := NIL

	Default cSearch   := ''
	Default cStatus   := '1'
	Default cSep      := ''
	Default cStatusOS := '*'

	//Carrega variável static '__lSaOrdSep'
	FnVlSaOs()

	cQuery := "	SELECT DISTINCT  "
	cQuery += "		CB7_ORDSEP ORDEM "
	cQuery += "		,CB7_STATUS STATUS "
	cQuery += "		,CB7_TIPEXP TPSEP "
	cQuery += "		,CB7_ORIGEM ORIGEM "
	cQuery += "		,CB8_PROD "
	cQuery += "		,CB8_ITEM "
	cQuery += "		,CB8_PEDIDO PEDIDO "
	cQuery += "		,CB8_SEQUEN "
	cQuery += "		,CB8_LOCAL "
	cQuery += "		,CB8_LCALIZ "
	cQuery += "		,CB8_NUMSER "
	cQuery += "		,CB8_LOTECT "
	cQuery += "		,CB8_NUMLOT "
	cQuery += "		,CB8_QTDORI "
	cQuery += "		,A1_NOME NOME "
	cQuery += "		,B1_DESC DESCRI "
	cQuery += "		,B1_CODBAR CODBAR "
	cQuery += "		,( "
	cQuery += "			CASE  "
	cQuery += "				WHEN CB7_ORIGEM = '1' "
	cQuery += "					THEN CB8_PEDIDO "
	cQuery += "				ELSE ( "
	cQuery += "						CASE  "
	cQuery += "							WHEN CB7_ORIGEM = '2' "
	cQuery += "								THEN CB8_NOTA || CB8_SERIE "
	If !__lSaOrdSep
		cQuery += "							ELSE CB8_OP "
	Else
		cQuery += "							WHEN CB7_ORIGEM = '3' "
		cQuery += "								THEN CB8_OP "
		cQuery += "							ELSE CB8_NUMSA "
	EndIf
	cQuery += "							END "
	cQuery += "						) "
	cQuery += "				END "
	cQuery += "			) DOC "
	cQuery += "		,CB8_OCOSEP "
	cQuery += "		,( "
	cQuery += "			CASE  "
	cQuery += "				WHEN A1_CGC = ' ' "
	cQuery += "					THEN A1_COD "
	cQuery += "				ELSE A1_CGC "
	cQuery += "				END "
	cQuery += "			) CUSTOMER "
	cQuery += "		,A1_LOJA STORE "
	cQuery += "		,( "
	cQuery += "			CASE  "
	cQuery += "				WHEN A1_ENDENT = ' ' "
	cQuery += "					THEN A1_END "
	cQuery += "				ELSE A1_ENDENT "
	cQuery += "				END "
	cQuery += "			) ADDRESS "
	cQuery += "		,X5_DESCRI STATE "
	cQuery += "		,CC2_MUN CITY "
	cQuery += "		,CB8_CFLOTE "
	cQuery += "		,CB8_SALDOS "
	cQuery += "	FROM " + RetSqlName("CB7") + " CB7 "
	cQuery += "	INNER JOIN " + RetSqlName("CB8") + " CB8 ON CB8.CB8_FILIAL = CB7.CB7_FILIAL "
	cQuery += "		AND CB8.CB8_ORDSEP = CB7.CB7_ORDSEP "
	cQuery += "     AND ( CB8.CB8_SALDOS > ? OR ( CB7.CB7_ORIGEM = ? AND CB8.CB8_SALDOS = ? )) " //1-2-3
	cQuery += "		AND CB8.D_E_L_E_T_ = ? " //4
	cQuery += "	INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = ? " //5
	cQuery += "		AND SB1.B1_COD = CB8.CB8_PROD "
	cQuery += "		AND SB1.B1_MSBLQL <> ? " //6
	cQuery += "		AND SB1.D_E_L_E_T_ = ? " //7
	cQuery += "	LEFT JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = ? " //8
	cQuery += "		AND SC5.C5_NUM = CB8.CB8_PEDIDO "
	cQuery += "		AND SC5.D_E_L_E_T_ = ? " //9
	cQuery += "	LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_FILIAL = ? " //10
	cQuery += "		AND SA1.A1_COD = SC5.C5_CLIENTE "
	cQuery += "		AND SA1.A1_LOJA = SC5.C5_LOJACLI "
	cQuery += "		AND SA1.D_E_L_E_T_ = ? " //11
	cQuery += "	LEFT JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL = ? " //12
	cQuery += "		AND SF2.F2_DOC = CB8.CB8_NOTA "
	cQuery += "		AND SF2.F2_SERIE = CB8.CB8_SERIE "
	cQuery += "		AND SF2.F2_CLIENTE = SC5.C5_CLIENTE "
	cQuery += "		AND SF2.F2_LOJA = SC5.C5_LOJACLI "
	cQuery += "		AND SF2.D_E_L_E_T_ = ? " //13
	cQuery += "	LEFT JOIN " + RetSqlName("SX5") + " SX5 ON SX5.X5_FILIAL = ? " //14
	cQuery += "		AND SX5.X5_TABELA = ? " //15
	cQuery += "		AND SX5.X5_CHAVE = SA1.A1_EST "
	cQuery += "		AND SX5.D_E_L_E_T_ = ? " //16
	cQuery += "	LEFT JOIN " + RetSqlName("CC2") + " CC2 ON CC2.CC2_FILIAL = ? " //17
	cQuery += "		AND CC2.CC2_EST = SA1.A1_EST "
	cQuery += "		AND CC2.CC2_CODMUN = SA1.A1_COD_MUN "
	cQuery += "		AND CC2.D_E_L_E_T_ = ? " //18
	cQuery += "	WHERE CB7.CB7_FILIAL = ? " //19

	cSearch := AllTrim(Upper(FwNoAccent(cSearch)))

	If !Empty(cSep)
		cWhere += "AND CB7_ORDSEP  = ? "
		aAdd(aBindValue, cSep)
	EndIf
	
	If cStatusOS == "0"  // não iniciada
		cWhere += "AND CB7_STATUS = ? "
		aAdd(aBindValue, "0")
	ElseIf cStatusOS == "1" // em atendimento
		cWhere += "AND CB7_CODOPE = ? AND CB7_STATUS = ? "
		aAdd(aBindValue, cCodOpe)
		aAdd(aBindValue, "1")
	ElseIf cStatusOS == "9" // Finalizado
		cWhere += "AND CB7_CODOPE = ? AND CB7_STATUS = ? AND CB7_ORIGEM = ? "
		aAdd(aBindValue, cCodOpe)
		aAdd(aBindValue, "9")
		aAdd(aBindValue, "4")
	ElseIf cStatusOS == "*"
		cWhere += "AND ( CB7_STATUS = ? OR ( CB7_STATUS = ? AND CB7_CODOPE = ? )) "
		aAdd(aBindValue, "0")
		aAdd(aBindValue, "1")
		aAdd(aBindValue, cCodOpe)
	EndIf
	
	If !Empty(cSearch)
		cWhere  += "  AND ( CB7_ORDSEP   LIKE ?  OR "
		cWhere  += "  		CB8_PEDIDO   LIKE ?  OR "
		cWhere  += "  		CB8_OP     	 LIKE ?  OR "
		cWhere  += "  		CB8_NOTA     LIKE ?  OR "
		cWhere  += "  		B1_COD	     LIKE ?  OR "
		cWhere  += "  		B1_DESC	     LIKE ?  OR "
		cWhere  += "  		F2_CHVNFE  	 LIKE ?  OR "
		cWhere  += "  		A1_NOME		 LIKE ? )

		for i := 1 to 8
			aAdd(aBindValue, "%" + cSearch + "%")
		next i
	EndIf
	

	cWhere += "AND CB7.D_E_L_E_T_ = ? "

	cQuery += cWhere
	cQuery += "ORDER BY CB7_ORDSEP"
	If cStatusOS <> "*"
		cQuery += " DESC"
	EndIf
	cQuery += ", DOC"

	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)

	oExec:SetNumeric(nOrd++, 0) 				//1
	oExec:SetString(nOrd++, "4") 				//2
	oExec:SetNumeric(nOrd++, 0) 				//3
	oExec:SetString(nOrd++, " ") 				//4
	oExec:SetString(nOrd++, FWxFilial("SB1")) 	//5
	oExec:SetString(nOrd++, "1") 				//6
	oExec:SetString(nOrd++, " ") 				//7
	oExec:SetString(nOrd++, FWxFilial("SC5")) 	//8
	oExec:SetString(nOrd++, " ") 				//9
	oExec:SetString(nOrd++, FWxFilial("SA1")) 	//10
	oExec:SetString(nOrd++, " ") 				//11
	oExec:SetString(nOrd++, FWxFilial("SF2")) 	//12
	oExec:SetString(nOrd++, " ") 				//13
	oExec:SetString(nOrd++, FWxFilial("SX5")) 	//14
	oExec:SetString(nOrd++, "12") 				//15
	oExec:SetString(nOrd++, " ") 				//16
	oExec:SetString(nOrd++, FWxFilial("CC2")) 	//17
	oExec:SetString(nOrd++, " ") 				//18
	oExec:SetString(nOrd++, FWxFilial("CB7")) 	//19

	aEval(aBindValue, {|x| oExec:SetString(nOrd++, x) })

	oExec:SetString(nOrd++, " ")

	oExec:OpenAlias(cAliasQry)
	
	DbSelectArea(cAliasQry)

	oExec:Destroy()
	oExec := NIL

	FWFreeArray(aBindValue)

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCB9
 Função que grava a tabela CB9
@param

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		17/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function GrvCB9(cItem,cSeq,cProd,nQtde,cCodSep,cStatus,cCodOpe,nStatusCode,cMessage)

Local lRet := .T.

CB8->(DbSetOrder(1))
If CB8->(DbSeek(padr(xFilial("CB8"),TAMSX3("CB8_FILIAL")[1])+ cCodSep + cItem+cSeq+cProd ))



	CB9->(DbSetOrder(10))
	If CB9->(DbSeek(padr(xFilial("CB9"),TAMSX3("CB9_FILIAL")[1])+CB8->(CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT)))
		reclock("CB9",.F.)
		CB9->(dbDelete())
		CB9->(msUnlock())
	Endif
	RecLock("CB9",.T.)
	CB9->CB9_FILIAL := xFilial("CB9")
	CB9->CB9_ORDSEP := CB7->CB7_ORDSEP
	CB9->CB9_CODETI := ''
	CB9->CB9_PROD   := CB8->CB8_PROD
	CB9->CB9_CODSEP := cCodOpe
	CB9->CB9_ITESEP := CB8->CB8_ITEM
	CB9->CB9_SEQUEN := CB8->CB8_SEQUEN
	CB9->CB9_LOCAL  := CB8->CB8_LOCAL
	CB9->CB9_LCALIZ := CB8->CB8_LCALIZ
	CB9->CB9_LOTECT := CB8->CB8_LOTECT
	CB9->CB9_NUMLOT := CB8->CB8_NUMLOT
	CB9->CB9_NUMSER := CB8->CB8_NUMSER
	CB9->CB9_LOTSUG := CB8->CB8_LOTECT
	CB9->CB9_SLOTSU := CB8->CB8_NUMLOT
	CB9->CB9_NSERSU := CB8->CB8_NUMSER
	CB9->CB9_PEDIDO := CB8->CB8_PEDIDO
	CB9->CB9_QTESEP += nQtde
	CB9->CB9_STATUS := cStatus // separado
	CB9->(MsUnlock())

Else
	lRet := .F.
	nStatusCode	:= 404
	cMessage 	:= STR0018 //"Item da separacao nao encontrada..."
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de Documentos para inventario.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com os inventarios pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET inventories WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonInv 			:= JsonObject():New()
Local aJsonInv		  	:= {}
Local aJProdInv			:= {}
Local nStatusCode       := 500
Local cMessage          := 'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cCodOpe   		:= CBRetOpe()
Local nCounReg			:= 0
Local lHasNext			:= .F.
Local nX				:= 0
Local aProdInv			:= {}
Local nSaldo			:= 0
Local cFilOld			:= cFilant

Default Self:SearchKey  	:= ''
Default Self:Status			:= '1'
Default Self:Page       	:= 1
Default Self:PageSize   	:= 20

Self:SetContentType("application/json")


If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0010 //'Usuario nao cadastrado para inventário'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))

	    GetInv(1,UPPER(Self:SearchKey),Self:Status,cAlias,,cCodOpe,@nStatusCode,@cMessage )
	    If (cAlias)->(!EOF())

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
			If Self:PageSize > 10
				Self:PageSize := 10
			EndIf

	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJsonInv 			:=  JsonObject():New()


	        While (cAlias)->(!EOF())
	            nCount++


	            If (nCount >= nStart)

	                nEntJson++
	                aAdd( aJsonInv,  JsonObject():New() )
	                aJsonInv[nEntJson]["code"			]	:= Padr((cAlias)->CODINV,TamSX3("CBA_CODINV")[1]) + (cAlias)->NUM
	                aJsonInv[nEntJson]["inventorydate"	]	:= (cAlias)->DTMESTRE
					aJsonInv[nEntJson]["type"			]	:= AllTrim( (cAlias)->TIPINV 				)
					aJsonInv[nEntJson]["warehouse"		]	:= EncodeUTF8(AllTrim(Posicione("NNR",1,padr(xFilial("NNR"),TamSX3("NNR_FILIAL")[1])+AllTrim( (cAlias)->ARMAZEM),"NNR_DESCRI")))
	                aJsonInv[nEntJson]["address"		]	:= AllTrim( (cAlias)->LOCALIZ      			)
	                aJsonInv[nEntJson]["guided"			]	:= If(AllTrim( (cAlias)->INVGUI)== '1', 1, 0 )
	                aJsonInv[nEntJson]["recount"		]	:= If(AllTrim( (cAlias)->RECINV)== '1', 1, 0 )
					aJsonInv[nEntJson]["status"			]	:= AllTrim( (cAlias)->STATUS     		    )

	                If nEntJson < Self:PageSize .And. nCount < nRecord

	                Else
	                    Exit
	                EndIf


	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

				(cAlias)->(DbSkip())

	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize

	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonInv 				:=  JsonObject():New()
	    	oJsonInv["inventories"]	:= aJsonInv
	    	oJsonInv["hasNext"] 	:= lHasNext

	    EndIf

	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonInv["inventories"]	:= aJsonInv
	oJsonInv["hasNext"] 	:= lHasNext
	cResponse := FwJsonSerialize( oJsonInv )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonInv) == "O"
	FreeObj(oJsonInv)
	oJsonInv := Nil
Endif

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT  inventories / ACDMOB
Altera o Status da separacao ou finaliza no protheus

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD PUT inventories WSSERVICE ACDMOB

Local nStatusCode   := 500
Local oJInvent		:= Nil
Local cMessage		:= STR0001 //'Erro Interno'
Local cResponse 	:= ""
Local cBody			:= ""
Local nX			:= 0
Local lRet			:= .T.
Local cCodOpe   	:= CBRetOpe()
Local cAlias        := GetnextAlias()
Local oJsonInv 		:= JsonObject():New()
Local aJProdInv		:= {}
Local aProdInv		:= {}
Local nSaldo		:= 0
Local nQtd			:= 0
Local cCode			:= ""
Local cDescription	:= ""
Local cBatch		:= ""
Local cWarehouse	:= ""
Local cStatus		:= ""
Local cStatusAnt    := ""
Local aprodend		:= {}
Local lModelo1

Local cFilOld		:= cFilant

Self:SetContentType("application/json")


lModelo1 := GetMv("MV_CBINVMD")=="1"

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0010 //'Usuario nao cadastrado para inventario'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			FWJsonDeserialize(Upper(cBody),@oJInvent)

			If !Empty( oJInvent )

				CBA->(DbSetOrder(1))
				If CBA->( DbSeek( PADR(xFilial("CBA"),TamSX3("CBA_FILIAL")[1]) + Substr(Self:aURLParms[2],1,TamSX3("CBA_CODINV")[1])) )

					If oJInvent:Status == '2'
						CBB->(DbSetOrder(3))
						CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ Self:aURLParms[2]))
						If CBA->CBA_STATUS $ ('0|1') .AND. CBB->CBB_STATUS <> "2"

							If AttIsMemberOf(oJInvent,"readproducts")
								oJsonInv 					:=  JsonObject():New()
								oJsonInv["code"]			:= oJInvent:Code
								oJsonInv["type"]			:= oJInvent:Type
								oJsonInv["warehouse"]		:= oJInvent:warehouse
								oJsonInv["address"]			:= oJInvent:address
								oJsonInv["guided"]			:= oJInvent:guided
								oJsonInv["recount"]			:= oJInvent:recount
								oJsonInv["status"]			:= oJInvent:status

								If lRet
									For nX := 1 To Len( oJInvent:readproducts )
										If !empty(oJInvent:readproducts[nX]:Code)
											SB1->(DbSetOrder(1))
											cCode			:= ""
											cDescription	:= ""
											If SB1->(DbSeek(PadR(xFilial("SB1"),TamSX3("B1_FILIAL")[1])+ oJInvent:readproducts[nX]:code ))
												cCode			:= SB1->B1_COD
												cDescription	:= SB1->B1_DESC
											EndIf
										Else
											SB1->(DbSetOrder(5))
											cCode			:= ""
											cDescription	:= ""
											If SB1->(DbSeek(PadR(xFilial("SB1"),TamSX3("B1_FILIAL")[1])+ oJInvent:readproducts[nX]:Barcode ))
												cCode			:= SB1->B1_COD
												cDescription	:= SB1->B1_DESC
											EndIf
										EndIf
										// verifica se o produto tem embalagem
										nQtd := AcdMobEmb(cCode,oJInvent:readproducts[nX]:Quantity)

										// pega o lote do produto
										cBatch := oJInvent:readproducts[nX]:Batch

										// pega o armazem do produto
										cWarehouse := CBA->CBA_LOCAL

										lRet := GrvInv(cCode,oJInvent:readproducts[nX]:Address,;
														oJInvent:readproducts[nX]:Batch,nQtd,;
														cCodOpe,@nStatusCode,@cMessage,oJInvent:readproducts[nX]:Barcode,oJInvent:recount)

										cStatus := GetStsInv(cCode, cWarehouse, cBatch, nQtd, cStatus) //Retorna o Status do Lote

										If lRet

											aAdd( aJProdInv,  JsonObject():New() )
						                    aJProdInv[nX]["code"			]	:= cCode
						                    aJProdInv[nX]["barcode"			]	:= oJInvent:readproducts[nX]:Barcode
						                    aJProdInv[nX]["description"		]	:= EncodeUTF8(Alltrim(cDescription))
						                    aJProdInv[nX]["address"			]	:= oJInvent:readproducts[nX]:Address
						                    aJProdInv[nX]["batch"			]	:= oJInvent:readproducts[nX]:Batch
						                    aJProdInv[nX]["quantity"		]	:= nQtd

										Else
											exit
										Endif
									Next nX
								EndIf
								If lRet
									oJsonInv["products"] := aJProdInv
									aJProdInv := {}

										RecLock("CBA",.F.)
										CBA->CBA_CONTR := CBA->CBA_CONTR + 1
										If !lModelo1
											CBA->CBA_AUTREC:="2" // BLOQUEADO
											CBA->CBA_STATUS := cStatus
										else
											If CBA->CBA_CONTR < CBA->CBA_CONTS
												CBA->CBA_STATUS := '1'
											Else
												CBA->CBA_STATUS := '4'
											Endif	
										EndIf
										CBA->(MsUnlock())

										RecLock("CBB",.F.)
										CBB->CBB_STATUS := "2"
										CBB->(MsUnlock())

										AjustInv() // Ajusta inventario gravando com quantia 0 os produtos nao encontrados na contagem
								Else
									cResponse 	:= ''
								Endif
							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0021 //"Dados do inventario nao enviados..."
							Endif
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0020 //"inventario ja foi finalizada..."
						Endif
					ElseIf oJInvent:Status == '1'
						CBB->(DbSetOrder(3))
						CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ Self:aURLParms[2]))
						If CBA->CBA_STATUS $ '0|1' .AND. CBB->CBB_STATUS == "0"

							cStatusAnt := CBA->CBA_STATUS

							RecLock("CBA",.F.)
							CBA->CBA_STATUS := oJInvent:Status  // Iniciando inventario
							If CBA->(ColumnPos("CBA_DISPOS")) > 0
								CBA->CBA_DISPOS := "2" // Identifica que o inventario foi selecionado pelo App, nao podendo ser conferido via coletor
							EndIf
							CBA->(MsUnlock())

							RecLock("CBB",.F.)
							CBB->CBB_USU	:= cCodOpe
							CBB->CBB_NCONT 	:=  CBB->CBB_NCONT + 1
							CBB->CBB_STATUS := "1"
							CBB->(MsUnlock())

							GetInv(2,,oJInvent:Status,cAlias,Substr(Self:aURLParms[2],1,TamSX3("CBA_CODINV")[1]) )

							While (cAlias)->(!EOF())
								oJsonInv 		:=  JsonObject():New()

								oJsonInv["code"]			:= Self:aURLParms[2]
								oJsonInv["type"]			:= AllTrim( (cAlias)->TIPINV 				)
								oJsonInv["inventorydate"]	:= (cAlias)->DTMESTRE
								oJsonInv["warehouse"]		:= EncodeUTF8(AllTrim(Posicione("NNR",1,padr(xFilial("NNR"),TamSX3("NNR_FILIAL")[1])+AllTrim( (cAlias)->ARMAZEM),"NNR_DESCRI")))
								oJsonInv["address"]			:= AllTrim( (cAlias)->LOCALIZ      			)
								oJsonInv["guided"]			:= If(AllTrim( (cAlias)->INVGUI)== '1', 1, 0 )
								oJsonInv["recount"]			:= If(AllTrim( (cAlias)->RECINV)== '1', 1, 0 )
								oJsonInv["status"]			:= oJInvent:Status

								CBLoadEst(@aProdInv,.F., .T.)
								// Tratamento para nao duplicar os registros da tabela CBM
								If cStatusAnt == "0"
									IniciaCBM(aProdInv)
								EndIf
								SB1->(DbSetOrder(1))
								For nX := 1 to Len(aProdInv)

									SB1->(DbSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+ aProdInv[nX,1] ))

									aAdd( aJProdInv,  JsonObject():New() )
									aJProdInv[nX]["code"			]	:= AllTrim(aProdInv[nX,1])
									aJProdInv[nX]["barcode"			]	:= AllTrim(SB1->B1_CODBAR)
									aJProdInv[nX]["description"		]	:= EncodeUTF8(Alltrim(SB1->B1_DESC))
									aJProdInv[nX]["address"			]	:= AllTrim(aProdInv[nX,5])
									aJProdInv[nX]["batch"			]	:= AllTrim(aProdInv[nX,2])
									aJProdInv[nX]["unity"			]	:= SB1->B1_UM

									If AllTrim( (cAlias)->INVGUI ) $ '1|2'
										nSaldo	:= 0
										If aProdInv[nX,7] <> 0
											nSaldo := aProdInv[nX,7]
										Else
											If  AllTrim( (cAlias)->TIPINV ) == '1'
												SB2->(DbSetOrder(1))
												SB2->(DbSeek(padr(xFilial('SB2'),TAMSX3("B2_FILIAL")[1])+aProdInv[nX,1]+CBA->CBA_LOCAL))
												nSaldo := SaldoSB2(,.F.)
											Else
												nSaldo := SaldoSBF(CBA->CBA_LOCAL,aProdInv[nX,5],aProdInv[nX,1],,aProdInv[nX,2],)
											EndIf
										Endif

										aJProdInv[nX]["quantity"		]	:= nSaldo

									EndIf

								Next nX
								oJsonInv["products"] := aJProdInv
								aJProdInv := {}

								(cAlias)->(dbSkip())
							End

							If Select(cAlias) > 0
								(cAlias)->(dbCloseArea())
							Endif

						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0007 // "Inventario ja iniciada por outro contador ou finalizado..."

						EndIf
					ElseIf oJInvent:Status == '3'
						// Atualiza numero de contagens realizadas
						CBA->(DbSetOrder(1))
						CBA->(DbSeek(Padr(xFilial("CBA"),TamSX3("CBA_FILIAL")[1]) + Substr(Self:aURLParms[2],1,TamSX3("CBA_CODINV")[1])))
						RecLock("CBA",.F.)
						CBA->CBA_CONTR := CBA->CBA_CONTR + 1
						CBA->(MsUnlock())
						// Finaliza contagem
						CBB->(DbSetOrder(3))
						CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ Self:aURLParms[2]))
						RecLock("CBB",.F.)
						CBB->CBB_USU	:= cCodOpe
						CBB->CBB_NCONT 	:=  1
						CBB->CBB_STATUS := "2"
						CBB->(MsUnlock())
						// Grava contagens com quantidade zero
						AjustInv()	
					ElseIf oJInvent:Status == '9'

						CBB->(DbSetOrder(3))
						CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ Self:aURLParms[2]))
						If CBA->CBA_STATUS $ '1' .AND. CBB->CBB_STATUS == "1"
							RecLock("CBA",.F.)
							CBA->CBA_STATUS := "0"
							If CBA->(ColumnPos("CBA_DISPOS")) > 0
								CBA->CBA_DISPOS := " "	// Desfaz relacionamento do inventario com o App
							EndIf
							CBA->(MsUnlock())

							RecLock("CBB",.F.)
							CBB->CBB_USU	:= ""
							CBB->CBB_NCONT 	:=  0
							CBB->CBB_STATUS := "0"
							CBB->(MsUnlock())
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= EncodeUTF8("Não foi possível remover a seleção do inventário.")
						EndIf					
					Endif
				Else
					lRet 		:= .F.
					nStatusCode	:= 400
					cMessage 	:= STR0008  //"Inventario nao encontrado..."
				Endif
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf

If lRet
	cResponse := FwJsonSerialize( oJsonInv )
    Self:SetResponse( cResponse )
    If oJInvent:Status $ '2|3' .AND. CBA->CBA_CONTR >= CBA->CBA_CONTS
    	SB1->(DbSetOrder(1))
    	aiv035Fim(.T.,aprodend,.F.)
    	IF CBA->CBA_ANALIS = '2' .And. lModelo1
    		GrvCBB(CBA->CBA_CODINV,cCodOpe,@nStatusCode,@cMessage,.T.,lModelo1,.F.)
    	Endif
    EndIf
Else
	SetRestFault( nStatusCode, cMessage )
EndIf
If ValType(oJsonInv) == "O"
	FreeObj(oJsonInv)
	oJsonInv := Nil
Endif
Return( lRet )



//-------------------------------------------------------------------
/*/{Protheus.doc} GET/Code/ACDMOB
Retorna dados do codigo informado

@param  Code    , caracter, Codigo para Pesquisa.


@return cResponse	, Array, JSON com Array

@author	 	Fernando Amorim (Cafu)
@since		15/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET  Code_inventories WSRECEIVE Code WSSERVICE ACDMOB
Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local cType				:= '1'
Local cCodOpe   		:= CBRetOpe()
Local cStatus			:= ''
Local oJsonInv 			:= JsonObject():New()

Local cFilOld			:= cFilant

Default Self:Code  := ''

Self:SetContentType("application/json")


If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0010 //'Usuario nao cadastrado para inventario'
	 lRet			   := .F.
EndIf
If lRet
   GetInv(3,,,cAlias,Self:Code )
    If (cAlias)->(!EOF())

        While (cAlias)->(!EOF())
			oJsonInv 		:=  JsonObject():New()

			oJsonInv["code"]			:= Padr((cAlias)->CODINV,TamSX3("CBA_CODINV")[1]) + (cAlias)->NUM
			oJsonInv["type"]			:= AllTrim( (cAlias)->TIPINV 				)
			oJsonInv["warehouse"]		:= AllTrim(Posicione("NNR",1,padr(xFilial("NNR"),TamSX3("NNR_FILIAL")[1])+AllTrim( (cAlias)->ARMAZEM),"NNR_DESCRI"))
			oJsonInv["address"]			:= AllTrim( (cAlias)->LOCALIZ      			)
			oJsonInv["guided"]			:= If(AllTrim( (cAlias)->INVGUI)== '1', 1, 0 )
			oJsonInv["recount"]			:= If(AllTrim( (cAlias)->RECINV)== '1', 1, 0 )
			oJsonInv["status"]			:= AllTrim( (cAlias)->STATUS				)

			(cAlias)->(dbSkip())
		End

    Else
       nStatusCode      := 404
       cMessage         := STR0008 //"Inventario nao encontrada"
       lRet			   	:= .F.
    EndIf

Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	cResponse := FwJsonSerialize( oJsonInv )
    Self:SetResponse( cResponse )
Else
	SetRestFault( nStatusCode, cMessage )
EndIf
If ValType(oJsonInv) == "O"
	FreeObj(oJsonInv)
	oJsonInv := Nil
Endif


Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} GetInv()
Constroi um Query com a Seleção de dados para inventario

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetInv(nGet,cSearch,cStatus,cAliasQry,cInv,cCodOpe,nStatusCode,cMessage )

Local cConcat       := IIF( !"MSSQL" $ TCGetDB(), "||", "+" )
Local cWhere		:= "% "
Local cSelect		:= ""
Local cCamposCBA	:= ""
Local cAliasCBA     := ""
Local cTamProd      := Space(TamSX3("CBA_PROD")[1])
Local cSelInvGui    := ""
Local cNotInvGui    := ""
Local cExpJoin      := ""
Local cJoinSB8      := ""
Local cTypeProd     := ""
Local cCampos       := ""
Local lExistSB2     := .F.
Local lDesLotZer    := .F.
Local lModelo1      := SuperGetMv("MV_CBINVMD",.F.,"1") == "1"
Local lCbaInvGui    := CBA->(ColumnPos("CBA_INVGUI")) > 0
Local lCbaRecInv    := CBA->(ColumnPos("CBA_RECINV")) > 0
Local lCbaDispos    := CBA->(ColumnPos("CBA_DISPOS")) > 0
Local cFilStatus    := ""
Local cFilData      := ""
Local lRecont       := .F.
Local cRetQryPe		:= ""

Default cSearch     := ''
Default cStatus   	:= '1'
Default cInv   		:= ''

// Colunas que serao adicionadas ao Select do App
If lCbaInvGui
	cSelect := "% ,CBA_INVGUI INVGUI"
Else
	cSelect := "% ,1 INVGUI"
EndIf
If lCbaRecInv
	cSelect += " ,CBA_RECINV RECINV %"
Else
	cSelect += " ,1 RECINV %"
EndIf

// Retorna lista de inventarios
If nGet == 1
	// Filtro por Status
	cFilStatus := " AND ((CBA.CBA_STATUS IN ('0','1')"
	// Se o campo CBA_DISPOS existir, retira inventarios iniciados pelo Coletor e adiciona os iniciados pelo App com recontagem autorizada pelo monitor do ACD
	If lCbaDispos
		cFilStatus += " AND CBA.CBA_DISPOS <> '1') OR (CBA.CBA_STATUS = '3' AND CBA.CBA_DISPOS = '2' AND CBA.CBA_AUTREC = '1'))"
	Else
		cFilStatus += "))"
	EndIf
	// Filtro por data
	cFilData := " AND CBA.CBA_DATA <= '" + DToS(dDataBase) + "' %"

	// Filtro para inventario guiado
	cSelInvGui := "% AND CBA.CBA_TIPINV = '1'"
	If lCbaInvGui
		cSelInvGui += " AND CBA.CBA_INVGUI = '1'"
	EndIf
	cSelInvGui += cFilStatus
	cSelInvGui += cFilData

	// Filtro para inventario nao guiado
	cNotInvGui := "% AND (CBA.CBA_TIPINV <> '1' OR CBA.CBA_PROD = '" + cTamProd + "'"
	If lCbaInvGui
		cNotInvGui += " OR CBA.CBA_INVGUI <> '1')"
	Else
		cNotInvGui += ")"
	EndIf
	cNotInvGui += cFilStatus
	cNotInvGui += cFilData

	// Parametro para considerar somente produtos com tipos definidos
	cTypeProd := SuperGetMV("MV_MCDTPPR", .F., "")
	If Valtype(cTypeProd) != "C"
		cTypeProd := ""
	Else
		cTypeProd := StrTran(cTypeProd, " ", "")
	EndIf
	If !Empty(cTypeProd)
		cTypeProd := "'" + StrTran( cTypeProd, ",", "','" ) + "'"
		cExpJoin := " INNER JOIN " + RetSqlName("SB1") + " SB1"
		cExpJoin += " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cExpJoin += " AND SB1.B1_COD = CBA.CBA_PROD"
		cExpJoin += " AND SB1.B1_TIPO IN (" + cTypeProd + ")"
		cExpJoin += " AND SB1.D_E_L_E_T_ = ' ' "
	EndIf

	// Parametro para considerar somente produtos que constam na SB2
	lExistSB2 := SuperGetMV("MV_MCDPRSL", .F., .F.)
	If Valtype(lExistSB2) != "L"
	 	lExistSB2 := .F.
	EndIf
	If lExistSB2
		cSelInvGui := SubStr(cSelInvGui, 1, Len(cSelInvGui)-2) + " AND CBA.CBA_PROD <> '" + cTamProd + "' %"
		If Empty(cExpJoin)
			cExpJoin := " INNER JOIN " + RetSqlName("SB2") + " SB2"
		Else
			cExpJoin += " INNER JOIN " + RetSqlName("SB2") + " SB2"
		EndIf
		cExpJoin += " ON SB2.B2_FILIAL = '" + xFilial("SB2") + "'"
		cExpJoin += " AND SB2.B2_COD = CBA.CBA_PROD"
		cExpJoin += " AND SB2.B2_LOCAL = CBA.CBA_LOCAL"
		cExpJoin += " AND SB2.D_E_L_E_T_ = ' ' "
	EndIf

	lDesLotZer := SuperGetMV( "MV_MCDLTZR", .F., .F. ) // Desconsidera produtos com lote zerado e nao traz o inventario
	If lDesLotZer
		cJoinSB8 := " LEFT JOIN " + RetSqlName("SB8") + " SB8"
		cJoinSB8 += " ON SB8.B8_FILIAL = '" + xFilial("SB8") + "'"
		cJoinSB8 += " AND SB8.B8_PRODUTO = CBA.CBA_PROD"
		cJoinSB8 += " AND SB8.D_E_L_E_T_ = ' ' "

		If Empty(cExpJoin)
			cExpJoin := cJoinSB8
		Else
			cExpJoin += cJoinSB8
		EndIf

		cSelInvGui := SubStr(cSelInvGui, 1, Len(cSelInvGui)-2) + " AND (SB8.B8_SALDO > 0 OR " + MATIsNull() + "(SB8.B8_LOTECTL, ' ') = ' ') %"
		cNotInvGui := SubStr(cNotInvGui, 1, Len(cNotInvGui)-2) + " AND (SB8.B8_SALDO > 0 OR " + MATIsNull() + "(SB8.B8_LOTECTL, ' ') = ' ') %"
	EndIf

	cExpJoin := "%" + cExpJoin + "%"
	cJoinSB8 := "%" + cJoinSB8 + "%"

	// Primeiro select, retorna os inventarios conforme filtros para que seja gravada a tabela CBB
	cAliasCBA := GetNextAlias()
	If lCbaDispos
		cCamposCBA := "% CBA_CODINV CODINV, CBA_STATUS STATUS, CBA_AUTREC AUTREC, CBA_DISPOS DISPOS %"
	Else
		cCamposCBA := "% CBA_CODINV CODINV, CBA_STATUS STATUS, CBA_AUTREC AUTREC, ' ' DISPOS %"
	EndIf
	// Seleciona inventarios por produto e guiados respeitando os parametros MV_MCDTPPR e MV_MCDPRSL
	// mais os inventarios que nao sejam por produto ou nao sejam guiados (UNION)
	BeginSQL Alias cAliasCBA

		SELECT %EXP:cCamposCBA%
		FROM
			%Table:CBA% CBA
		%EXP:cExpJoin%
		WHERE
			CBA.CBA_FILIAL = %xFilial:CBA%
			%EXP:cSelInvGui%
			AND CBA.%NotDel%
		UNION
		SELECT %EXP:cCamposCBA%
		FROM %Table:CBA% CBA
		%EXP:cJoinSB8%
		WHERE CBA.CBA_FILIAL = %xFilial:CBA%
			%EXP:cNotInvGui%
			AND CBA.%NotDel%
		ORDER BY CODINV DESC

	EndSQL

	If (cAliasCBA)->(!EOF())
		While (cAliasCBA)->(!EOF())
			If !lModelo1 .And. (cAliasCBA)->AUTREC == "1" .And. (cAliasCBA)->DISPOS == "2"
				lRecont := .T.
			Else
				lRecont := .F.
			EndIf
			GrvCBB((cAliasCBA)->CODINV,cCodOpe,@nStatusCode,@cMessage,.F.,lModelo1,lRecont)
			(cAliasCBA)->(DBSKIP())
		End
	EndIf

	If Select(cAliasCBA) > 0
		(cAliasCBA)->(dbCloseArea())
	EndIf

	// Segundo select, retorna os inventarios definitivos para o App
	cCampos := "CBA.R_E_C_N_O_ RECCBA,CBA_CODINV CODINV,CBA_STATUS STATUS,CBA_TIPINV TIPINV,CBA_PROD PROD,CBA_LOCAL ARMAZEM,CBA_DATA DTMESTRE,CBA_LOCALI LOCALIZ,CBA_CONTS CONTS,CBB_NUM NUM"
	cCampos += SubStr(cSelect,3,Len(cSelect))
	cSelect := "% " + cCampos

	If Len(AllTrim(cSearch)) == 1
		If AllTrim(cSearch) == "'"
			cSearch := '"'
		EndIf
	Else
		cSearch := REPLACE(cSearch,"'","")
	EndIf
	cSearch := AllTrim(Upper(FwNoAccent(cSearch)))

	If !Empty( cSearch )
		// Ponto de Entrada para customizar a pesquisa na listagem de inventários
		If ExistBlock( "MCDFINV" )
			cRetQryPe := ExecBlock( "MCDFINV", .F., .F., { cSearch } )
			If !Empty( cRetQryPe )
				cWhere := "% " + cRetQryPe // Adiciona ao cWhere o retorno do PE, quando não for vazio
			EndIf
		Else 
			cWhere  += " AND ( CBA_CODINV  LIKE '%"   	+ cSearch + "%' OR"
			cWhere  += "  CBB_CODINV " +  cConcat + " CBB_NUM  LIKE '%"   	+ cSearch + "%' OR"
	    	cWhere  += "  CBA_PROD    LIKE '%"   	+ cSearch + "%' OR"
	    	cWhere  += "  CBA_LOCAL    LIKE '%"   	+ cSearch + "%' OR"
	    	cWhere  += "  CBA_LOCALI	LIKE '%"   	+ cSearch + "%')
		EndIf
	EndIf

	cWhere  += " %"
	
	BeginSQL Alias cAliasQry

		SELECT
			%EXP:cSelect%
		FROM
			%Table:CBA% CBA
		INNER JOIN 	%Table:CBB% CBB ON
			CBB.CBB_FILIAL = CBA.CBA_FILIAL
			AND CBB.CBB_CODINV = CBA.CBA_CODINV
			AND CBB.CBB_STATUS	= '0'
			AND CBB.CBB_USU <> %EXP:cCodOpe%
			AND CBB.%NotDel%
		%EXP:cExpJoin%
		WHERE
			CBA.CBA_FILIAL = %xFilial:CBA%
			%EXP:cSelInvGui%
			AND CBA.%NotDel%
			%EXP:cWhere%
		UNION
		SELECT %EXP:cSelect%
		FROM %Table:CBA% CBA
		INNER JOIN 	%Table:CBB% CBB ON
			CBB.CBB_FILIAL = CBA.CBA_FILIAL
			AND CBB.CBB_CODINV = CBA.CBA_CODINV
			AND CBB.CBB_STATUS	= '0'
			AND CBB.CBB_USU <> %EXP:cCodOpe%
			AND CBB.%NotDel%
		%EXP:cJoinSB8%
		WHERE
			CBA.CBA_FILIAL = %xFilial:CBA%
			%EXP:cNotInvGui%
			AND CBA.%NotDel%
			%EXP:cWhere%
		ORDER BY CODINV DESC

	EndSQL
// Retorna inventario especifico
ElseIf nGet == 2
	BeginSQL Alias cAliasQry

	SELECT CBA.R_E_C_N_O_  AS RECCBA,CBA_CODINV CODINV,CBA_STATUS STATUS,CBA_TIPINV TIPINV,CBA_PROD PROD,CBA_LOCAL ARMAZEM,CBA_LOCALI LOCALIZ,CBA_CONTS CONTS,CBA_DATA DTMESTRE
	%EXP:cSelect%
	FROM
		%Table:CBA% CBA
	WHERE
		CBA.CBA_FILIAL = %xFilial:CBA%
		AND CBA.CBA_STATUS	=  %Exp:cStatus%
		AND CBA.CBA_CODINV	= %Exp:cInv%
		AND CBA.%NotDel%
		ORDER BY CODINV DESC
	EndSQL
Else


	cWhere += " AND CBA.CBA_CODINV  = '" +  Substr(cInv,1,TamSX3("CBA_CODINV")[1]) + "' "
	cWhere += " AND CBB.CBB_NUM    = '" +  Substr(cInv,TamSX3("CBA_CODINV")[1]+1,TamSX3("CBB_NUM")[1]) + "' %"

	BeginSQL Alias cAliasQry

	SELECT 	CBA.R_E_C_N_O_  AS RECCBA,CBA_CODINV CODINV,CBA_STATUS STATUS,CBA_TIPINV TIPINV,CBA_PROD PROD,CBA_LOCAL ARMAZEM,CBA_DATA DTMESTRE,
			CBA_LOCALI LOCALIZ,CBA_CONTS CONTS,CBB_NUM NUM
	%EXP:cSelect%
	FROM
		%Table:CBA% CBA
	INNER JOIN 	%Table:CBB% CBB ON
		CBB.CBB_FILIAL = CBA.CBA_FILIAL
		AND CBB.CBB_CODINV = CBA.CBA_CODINV
		AND CBB.CBB_STATUS	= '0'
		AND CBB.%NotDel%
	WHERE
		CBA.CBA_FILIAL = %xFilial:CBA%
		AND CBA.CBA_STATUS	IN ('0','1')
		AND CBA.CBA_DATA	<= %Exp:ddatabase%
		AND CBA.%NotDel%
		%EXP:cWhere%
		ORDER BY CODINV DESC
	EndSQL

Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCBB
 Função que grava as tabelas de inventario do acd
@param

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		17/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function GrvCBB(cCodInv,cCodOpe,nStatusCode,cMessage,lExtra, lModelo1, lRecont)

Local nX			:= 0
Local nY			:= 0
Local lEncontrou    := .F.
Local nCriaCBB		:= 1
Local cUltCont      := ""
Local aCBC          := {}

Default lExtra		:= .F.
Default lModelo1	:= .T.
Default lRecont     := .F.

CBA->(dbSetOrder(1))
If CBA->(dbSeek(PADR(xFilial('CBA'),TamSX3("CBA_FILIAL")[1])+cCodInv))

	If !lExtra .And. !lRecont
		CBB->(dbSetOrder(1))
		lEncontrou := CBB->(dbSeek(PADR(xFilial('CBB'),TamSX3("CBB_FILIAL")[1])+ CBA->CBA_CODINV ))
		If !lEncontrou
			If lModelo1
				nCriaCBB :=	CBA->CBA_CONTS
			EndIf
			For nX :=  1 To nCriaCBB
				Reclock("CBB",.T.)
				CBB->CBB_FILIAL := xFilial("CBB")
				CBB->CBB_NUM    := CBProxCod('MV_USUINV') // pega o proximo id para o inventario por usuario
				CBB->CBB_CODINV := CBA->CBA_CODINV
				//CBB->CBB_USU    := cCodOpe
				CBB->CBB_STATUS := "0"
				CBB->(MsUnlock())
			Next nX
		EndIf
	Else
		If lRecont .And. !lModelo1
			// Retorna a ultima contagem do inventario
			cUltCont := CBUltCont(CBA->CBA_CODINV)

			// Tratamento para nao gravar CBB em duplicidade
			If !Empty(cUltCont)
				CBB->(dbSetOrder(3))
				lEncontrou := CBB->(DbSeek(PADR(xFilial("CBB"),TamSX3("CBB_FILIAL")[1]) + CBA->CBA_CODINV + cUltCont)) .And. CBB->CBB_STATUS $ "01"
			EndIf
		EndIf

		If !lEncontrou
			Reclock("CBB",.T.)
			CBB->CBB_FILIAL := xFilial("CBB")
			CBB->CBB_NUM    := CBProxCod('MV_USUINV') // pega o proximo id para o inventario por usuario
			CBB->CBB_CODINV := CBA->CBA_CODINV
			//CBB->CBB_USU    := cCodOpe
			CBB->CBB_STATUS := "0"
			CBB->(MsUnlock())

			RecLock("CBA",.F.)
			CBA->CBA_STATUS := '1'
			CBA->(MsUnlock())

			//-- transpor as contagens batidas para este usuario (mesmo tratamento do ACDV035)
			If lRecont .And. !Empty(cUltCont)
				CBC->(DbSetOrder(1))
				CBC->(DbSeek(xFilial("CBC")+cUltCont))
				While CBC->(!Eof() .And. xFilial("CBC")+cUltCont == CBC_FILIAL+CBC_NUM)
					If CBC->CBC_CONTOK == "1"
						aAdd(aCBC,Array(CBC->(FCount())))
						For nX := 1 To CBC->(FCount())
							aCBC[Len(aCBC),nX] := CBC->(FieldGet(nX))
						Next nX
					EndIf
					CBC->(DbSkip())
				End
				For nX := 1 to Len(aCBC)
					Reclock("CBC", .T.)
					For nY := 1 To CBC->(FCount())
						If CBC->(FieldName(nY)) == "CBC_CODINV"
							CBC->CBC_CODINV := CBB->CBB_CODINV
						ElseIf CBC->(FieldName(nY)) == "CBC_NUM"
							CBC->CBC_NUM := CBB->CBB_NUM
						Else
							CBC->(FieldPut(nY,aCBC[nX,nY]))
						EndIf
					Next nY
					CBC->(MsUnLock())
				Next nX
			EndIf
		EndIf

	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvInv
 Função que grava as tabelas de inventario do acd
@param  cProd       , char, codigo produto
        cEnder      , char, endereço produto
		cLoteProd   , char, lote produto
		nQuantInv   , numeric, quantiddade inventariada
		cCodOpe     , char, codigo opercao
		nStatusCode , numeric, status retorno api
		cMessage    , char, mensagem para retornar na api
		cCodBar     , char codigo barra produto
		nRecont     , numerico, define se é inventário com recontagem, sendo 0-Não haverá recontagem
								                                             1-haverá recontagem se a quantidade for diferente da primeira leitura
@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		17/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function GrvInv(cProd,cEnder,cLoteProd,nQuantInv,cCodOpe,nStatusCode,cMessage,cCodBar,nRecont)

Local lRet 		:= .T.
Local aProdInv	:= {}
LOcal nPos		:= 0
Local cAliasB1	:= GetnextAlias()

If !Empty(cProd)
	CBLoadEst(@aProdInv,.F.)
	nPos := ascan(aProdInv,{|x| x[1]+x[2]+x[4]+x[5]==PADR(cProd,TamSX3("CBC_COD")[1])+PADR(cLoteProd,TamSX3("CBC_LOTECT")[1]);
	+PADR(CBA->CBA_LOCAL,TamSX3("CBA_LOCAL")[1])+PADR(cEnder,TamSX3("CBC_LOCALI")[1])})
EndIf
If nPos > 0
	
	// caso for recontagem, exclui o registro e grava a 2a contagem
	If nRecont == 1
		CBC->(DbSetOrder(2))	//CBC_FILIAL+CBC_NUM+CBC_COD+CBC_LOCAL+CBC_LOCALI+CBC_LOTECT+CBC_NUMLOT+CBC_NUMSER+CBC_IDUNIT
		If CBC->(DbSeek(xFilial("CBC")+CBB->CBB_NUM+PADR(cProd,TamSX3("CBC_COD")[1])+PADR(CBA->CBA_LOCAL,TamSX3("CBA_LOCAL")[1])+PADR(cEnder,TamSX3("CBC_LOCALI")[1])+PADR(cLoteProd,TamSX3("CBC_LOTECT")[1])))
		   	CBC->(RecLock("CBC",.F.))
			CBC->(DbDelete())
			CBC->(MSUNLOCK())
		Endif
	Endif
	
	// efetua a gravação
	DbSelectArea("CBC")
	RecLock("CBC",.T.)
	CBC->CBC_FILIAL := xFilial("CBC")
	CBC->CBC_CODINV := CBB->CBB_CODINV
	CBC->CBC_NUM    := CBB->CBB_NUM
	CBC->CBC_LOCAL  := CBA->CBA_LOCAL
	CBC->CBC_LOCALI := cEnder
	CBC->CBC_COD    := cProd
	CBC->CBC_LOTECT := cLoteProd
	CBC->CBC_QUANT  := nQuantInv
	CBC->CBC_QTDORI := nQuantInv
	CBC->(MSUNLOCK())

Else
	BeginSQL Alias cAliasB1

	SELECT B1_COD
	FROM
		%Table:SB1% SB1
	WHERE
		SB1.B1_FILIAL = %xFilial:SB1%
		AND (SB1.B1_CODBAR	= %Exp:cCodBar% OR SB1.B1_COD	= %Exp:cCodBar%)
		AND SB1.%NotDel%
	EndSQL
	If (cAliasB1)->(!EOF())	.And. !Empty(cCodBar)

		If  !SB2->(DbSeek(padr(xFilial("SB2"),TAMSX3("B2_FILIAL")[1])+(cAliasB1)->B1_COD+CBA->CBA_LOCAL))
			CriaSB2((cAliasB1)->B1_COD,CBA->CBA_LOCAL,xFilial("SB2"))
		EndIf
		//-----------------------------------//
		//	Calculo de ambalagem 			//
		//---------------------------------//
		nQuantInv := AcdMobEmb((cAliasB1)->B1_COD,nQuantInv)

		RecLock("CBC",.T.)
		CBC->CBC_FILIAL := xFilial("CBC")
		CBC->CBC_CODINV := CBB->CBB_CODINV
		CBC->CBC_NUM    := CBB->CBB_NUM
		CBC->CBC_LOCAL  := CBA->CBA_LOCAL
		CBC->CBC_LOCALI := cEnder
		CBC->CBC_COD    := (cAliasB1)->B1_COD
		CBC->CBC_LOTECT := cLoteProd
		CBC->CBC_QUANT  := nQuantInv
		CBC->CBC_QTDORI := nQuantInv
		CBC->(MSUNLOCK())
	Else
		//grava D3V
		D3V->(DbSetOrder(3))
		If	!D3V->(DBSeek(padr(xFilial("D3V"),TAMSX3("D3V_FILIAL")[1])+'3'+ CBB->CBB_CODINV + cProd))
			// Grava a tabela de divergencia
			RecLock("D3V",.t.)
			D3V->D3V_FILIAL	:= xFilial("D3V")
			D3V->D3V_CODIGO	:= GetSXENum("D3V", "D3V_CODIGO")
			D3V->D3V_ORIGEM	:= '3'
			D3V->D3V_MOTIVO	:= '1'
			D3V->D3V_CODINV	:= CBB->CBB_CODINV
			D3V->D3V_NUMINV := CBB->CBB_NUM
			D3V->D3V_CODPRO	:= cProd
			D3V->D3V_CODBAR	:= cCodBar
			D3V->D3V_QTDE	:= nQuantInv
			D3V->D3V_LOCORI	:= CBA->CBA_LOCAL
			D3V->D3V_LOTECT	:= cLoteProd
			D3V->D3V_LCZORI	:= cEnder
			D3V->D3V_CODUSR	:= cCodOpe
			D3V->D3V_DATA	:= dDatabase
			D3V->D3V_HORA	:= Time()
			D3V->D3V_STATUS	:= '1'
			D3V->(MsUnLock())
			CONFIRMSX8()
		Endif


	Endif

	If Select(cAliasB1) > 0
		(cAliasB1)->(dbCloseArea())
	Endif
Endif
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AjustInv
 Função que grava as tabelas de inventario do acd
@param

@return lRet	, Logico,

@author	 	Fernando Amorim (Cafu)
@since		17/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
Function AjustInv()

Local aProdInv		:= {}
Local nX			:= 0

CBC->(dbSetOrder(2))
CBLoadEst(@aProdInv,.F.)

For nX := 1 to Len(aProdInv)
	If !CBC->(dbSeek(padr(xFilial('CBC'),TAMSX3("CBC_FILIAL")[1])+CBB->CBB_NUM+aProdInv[nX,1]+aProdInv[nX,4]+aProdInv[nX,5]+aProdInv[nX,2]+aProdInv[nX,3]+aProdInv[nX,6]))
		RecLock("CBC",.T.)
		CBC->CBC_FILIAL := xFilial("CBC")
		CBC->CBC_CODINV := CBB->CBB_CODINV
		CBC->CBC_NUM    := CBB->CBB_NUM
		CBC->CBC_LOCAL  := aProdInv[nX,4]
		CBC->CBC_LOCALI := aProdInv[nX,5]
		CBC->CBC_COD    := aProdInv[nX,1]
		CBC->CBC_LOTECT := aProdInv[nX,2]
		CBC->CBC_NUMLOT := aProdInv[nX,3]
		CBC->CBC_NUMSER := aProdInv[nX,6]
		CBC->CBC_QUANT  := 0
		CBC->(MSUNLOCK())
	Endif
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de produtos.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.
		productId	 , caracter, Código do produto ou código de barras para pesquisa.
		supplier	 , caracter, Código do fornecedor
		store        , caracter, Loja do fornecedor
		searchSNumber, caracter, Chave de Pesquisa para numero de serial ser considerado na consulta.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Products WSRECEIVE SearchKey, Status, Page, PageSize, productId, supplier, store, searchSNumber WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonProd			:= JsonObject():New()
Local aJsonProd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cCodOpe   		:= CBRetOpe()
Local lHasNext			:= .F.
Local cFilOld			:= cFilant
Local cProductCode		:= ''
Local oJsonLot			:= NIL
Local lPesqSA5 			:= SuperGetMv("MV_CBSA5",.F.,.F.)
Local aAreaSA5			:= SA5->(GetArea())
Local cDadosProd		:= SuperGetMV("MV_ARQPROD",.F.,"SB1")

Private cFilSBF			:= FWxFilial("SBF")

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100
Default Self:productId  := ''
Default Self:supplier   := ''
Default Self:store  	:= ''
Default Self:searchSNumber   := ''

Self:SetContentType("application/json")


If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))
	    GetTransf(1, UPPER(Self:SearchKey), Self:Status, cAlias, self:Page, self:PageSize, self:productId )

	    If (cAlias)->(!EOF())

	        COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        oJsonProd 			:=  JsonObject():New()

			oJsonProd["branch"	]	:= FWModeAccess("SB1",3)
			oJsonProd["business"]	:= FWModeAccess("SB1",1)
			oJsonProd["unit"	]	:= FWModeAccess("SB1",2)

	        While (cAlias)->(!EOF())
	            nCount++

	            If (nCount >= nStart)
					If cProductCode <> (cAlias)->PROD
						
						SA5->( DbSetOrder( 2 ) ) // A5_FILIAL+A5_PRODUTO+A5_FORNECE+A5_LOJA
						If lPesqSA5 .And. SA5->( MsSeek( xFilial( "SA5" ) + ( cAlias )->PROD) ) // Checa se existe o produto na tabela SA5 para preenchimento do Fornecedor e Loja			
							If Empty( self:supplier ) .And. Empty( self:store ) 
								While SA5->( !EOF() ) .And. xFilial( "SA5" ) + ( cAlias )->PROD == SA5->A5_FILIAL + SA5->A5_PRODUTO 
									
									SetProdInfo( cAlias, cDadosProd, @aJsonProd, @nEntJson, SA5->A5_FORNECE, SA5->A5_LOJA, Self:searchSNumber  )
																		
									SA5->( DbSkip() )
								EndDo
							Else 
								SetProdInfo( cAlias, cDadosProd, @aJsonProd, @nEntJson, self:supplier, self:store, Self:searchSNumber  )
							EndIf
						Else
							SetProdInfo( cAlias, cDadosProd, @aJsonProd, @nEntJson,,, Self:searchSNumber  )
						EndIf

						If nEntJson < Self:PageSize .And. nCount < nRecord

						Else
							Exit
						EndIf
					Else
						If ( !Empty( ( cAlias )->RASTRO ) .And. AllTrim( ( cAlias )->RASTRO ) <> 'N' )
							oJsonLot := JsonObject():New()
							oJsonLot[ "warehouse" ]	:= ( cAlias )->ARMAZEM
							oJsonLot[ "batch" ]		:= ( cAlias )->LOTE

							aAdd( aJsonProd[ nEntJson ][ "batchs" ], oJsonLot ) 
						EndIf
					EndIf
	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

				cProductCode := (cAlias)->PROD

				(cAlias)->(DbSkip())

	        EndDo

			If nRecord  < Self:PageSize
				lHasNext	:= .F.
			else
				lHasNext	:= .T.
			EndIf
	    Else
	    	oJsonProd 				:=  JsonObject():New()
	    	oJsonProd["products"]	:= aJsonProd
	    	oJsonProd["hasNext"] 	:= lHasNext
	    EndIf
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonProd["products"]		:= aJsonProd
	oJsonProd["hasNext"] 		:= lHasNext
	cResponse := oJsonProd:ToJson()
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

RestArea( aAreaSA5 )
FWFreeArray( aAreaSA5 )
FWFreeArray( aJsonProd )
FreeObj( oJsonProd )
FreeObj( oJsonLot )
oJsonProd := Nil
oJsonLot := Nil

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de armazens.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Warehouse WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonArm			:= JsonObject():New()
Local aJsonArm		  	:= {}
Local nStatusCode       := 500
Local cMessage          := STR0012 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cOrdem			:= ''
Local cCodOpe   		:= CBRetOpe()
Local nCounReg			:= 0
Local lHasNext			:= .F.
Local cFilOld			:= cFilant

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 20

Self:SetContentType("application/json")


If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))



	    GetTransf(2,UPPER(Self:SearchKey),Self:Status,cAlias )
	    If (cAlias)->(!EOF())

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
			If Self:PageSize > 20
				Self:PageSize := 20
			EndIf

	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJsonArm 			:=  JsonObject():New()

			oJsonArm["branch"	]	:= FWModeAccess("NNR",3)
			oJsonArm["business" ]	:= FWModeAccess("NNR",1)
			oJsonArm["unit"	    ]	:= FWModeAccess("NNR",2)

	        While (cAlias)->(!EOF())
	            nCount++


	            If (nCount >= nStart)

	                nEntJson++
	                aAdd( aJsonArm,  JsonObject():New() )

	                aJsonArm[nEntJson]["warehouse"			]	:= (cAlias)->CODARM
					aJsonArm[nEntJson]["description"		]	:= EncodeUTF8(Alltrim((cAlias)->DESCRI))

					If nEntJson < Self:PageSize .And. nCount < nRecord

	                Else
	                    Exit
	                EndIf


	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

				(cAlias)->(DbSkip())

	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize

	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonArm 				:=  JsonObject():New()
	    	oJsonArm["warehouses"]	:= aJsonArm
	    	oJsonArm["hasNext"] 	:= lHasNext

	    EndIf
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonArm["warehouses"]		:= aJsonArm
	oJsonArm["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonArm )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonArm) == "O"
	FreeObj(oJsonArm)
	oJsonArm := Nil
Endif

Return (lRet)




//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de endereços.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.

@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET Address WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cResponse         := ''
Local oJsonEnd			:= JsonObject():New()
Local aJsonEnd		  	:= {}
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cOrdem			:= ''
Local cCodOpe   		:= CBRetOpe()
Local nCounReg			:= 0
Local lHasNext			:= .F.
Local cFilOld			:= cFilant

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 20

Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))



	    GetTransf(3,UPPER(Self:SearchKey),Self:Status,cAlias )
	    If (cAlias)->(!EOF())

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())


	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJsonEnd 			:=  JsonObject():New()

			oJsonEnd["branch"	]	:= FWModeAccess("SBE",3)
			oJsonEnd["business" ]	:= FWModeAccess("SBE",1)
			oJsonEnd["unit"	    ]	:= FWModeAccess("SBE",2)

	        While (cAlias)->(!EOF())
	            nCount++


	            If (nCount >= nStart)
					SBE->(DbGoTo((cAlias)->REC))
	                nEntJson++
	                aAdd( aJsonEnd,  JsonObject():New() )

	                aJsonEnd[nEntJson]["warehouse"			]	:= (cAlias)->CODARM
	                aJsonEnd[nEntJson]["address"			]	:= (cAlias)->ADDRESS
					aJsonEnd[nEntJson]["description"		]	:= EncodeUTF8(Alltrim((cAlias)->DESCRIC))
					aJsonEnd[nEntJson]["status"				]	:= (cAlias)->STATUS
					If !RegistroOk("SBE")
						aJsonEnd[nEntJson]["status_msblql"	]	:= '1'
					Else
						aJsonEnd[nEntJson]["status_msblql"	]	:= '2'
					EndIf
					If nEntJson < Self:PageSize .And. nCount < nRecord

	                Else
	                    Exit
	                EndIf


	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

				(cAlias)->(DbSkip())

	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize

	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonEnd 				:=  JsonObject():New()
	    	oJsonEnd["addresses"]	:= aJsonEnd
	    	oJsonEnd["hasNext"] 	:= lHasNext

	    EndIf
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If lRet
	oJsonEnd["addresses"]		:= aJsonEnd
	oJsonEnd["hasNext"] 		:= lHasNext
	cResponse := FwJsonSerialize( oJsonEnd )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonEnd) == "O"
	FreeObj(oJsonEnd)
	oJsonEnd := Nil
Endif

Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} GetTransf()
Constroi um Query com a Seleção de produtos, uma com selação de armazens, uma com seleção de endereços

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.
		nPage		, numeric, Define qual o número da página a ser processada
		nPageSize	, numeric, Define a quantidade de registros por página
		cProductId	 , caracter, Código do produto ou código de barras para pesquisa.

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetTransf( nTp, cSearch, cStatus, cAliasQry, nPage, nPageSize, cProductId )

Local cDadosProd	:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
Local cTypeProduct	:= '' 
Local nRecStart		:= 0  // Define a quantidade de registros ja retornados
Local nRecFinish	:= 0  // Define o registro máximo à retornar
Local lExistSB2		:= .F.
Local lDesLotZer    := .F.
Local cQuery		:= ""
Local oExec			:= JsonObject():New()
Local nParam		:= 1
Local cColAlias	    := ""
Local lPesqSA5		:= .F.

Default cSearch     := ''
Default cStatus   	:= '1'
default nTp			:= 1
Default nPage		:= 1
Default nPageSize	:= 1
Default cProductId  := ''

nRecStart := ( (nPage - 1) * nPageSize ) + 1

nRecFinish := ( nRecStart + nPageSize ) - 1

If 	Len(alltrim(cSearch))== 1
	If alltrim(cSearch) == "'"
		cSearch     := '"'
	Endif
Else
	cSearch := REPLACE(cSearch,"'","")
Endif
cSearch :=  AllTrim(Upper(FwNoAccent(cSearch)))

If nTp == 1 // produto
	
	cTypeProduct	:= SuperGetMV( "MV_MCDTPPR", .F., "" )	// Determina os tipos de produto que serão sincronizados.
	lExistSB2		:= SuperGetMV( "MV_MCDPRSL", .F., .F. ) // Apresenta somente os registros presentes na SB2
	lDesLotZer		:= SuperGetMV( "MV_MCDLTZR", .F., .F. ) // Desconsidera produtos com lote zerado
	lPesqSA5		:= SuperGetMV( "MV_CBSA5"  , .F., .F. ) // Desconsidera a pesquisa dos itens da tabela SA5

	// Corrige eventuais erros no preenchimento dos parâmetros
	If Valtype(lExistSB2) != "L"
	 	lExistSB2 := .F.
	EndIf

	If Valtype( cTypeProduct ) != "C"
		cTypeProduct := ""	
	Else
		// Retira os espaços do parâmetro MV_MCDTPPR, pois eles podem resultar em erro na montagem da query
		cTypeProduct := StrTran( cTypeProduct, " ", "" )
	EndIf

	cQuery := " SELECT LINHA, PROD, CODBAR, DESCRI, RASTRO, LOCALIZ, ARMAZEM, LOTE, UNID, UNIDESC"
	If cDadosProd == "SBZ"
		cQuery += ", LOCALIZZ"
		cColAlias  += ", BZ_LOCALIZ LOCALIZZ "
	EndIf
	If lPesqSA5
		cQuery += ", CODBARSA5"
		cQuery += ", FORNECEDOR"
		cQuery += ", LOJAFORN"

		cColAlias += " ,A5_CODBAR CODBARSA5 "
		cColAlias += " ,A5_FORNECE FORNECEDOR "
		cColAlias += " ,A5_LOJA LOJAFORN "
	EndIf
	cQuery += " FROM ( "
	cQuery += " SELECT ROW_NUMBER() OVER ( "
	cQuery += " ORDER BY B1_COD "
	cQuery += " ,B8_LOCAL "
	cQuery += " ,B8_LOTECTL ) AS LINHA "
	cQuery += " ,B1_COD PROD "
	cQuery += " ,B1_CODBAR CODBAR "
	cQuery += " ,B1_DESC DESCRI "
	cQuery += " ,B1_RASTRO RASTRO "
	cQuery += " ,B1_LOCALIZ LOCALIZ "
	cQuery += " ,B8_LOCAL ARMAZEM "
	cQuery += " ,B8_LOTECTL LOTE "
	cQuery += " ,B1_UM UNID "
	cQuery += " ,AH_DESCPO UNIDESC "

	cQuery += cColAlias

	cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += " LEFT JOIN " + RetSqlName("SB8") + " SB8 "
	cQuery += "  ON SB8.B8_FILIAL = ? "
	cQuery += "  AND SB8.B8_PRODUTO = SB1.B1_COD "
	cQuery += "  AND SB8.D_E_L_E_T_ = ? "
	cQuery += "  AND SB1.B1_RASTRO <> ? "
	cQuery += " LEFT JOIN " + RetSqlName("SAH") + " SAH 
	cQuery += "  ON SAH.AH_FILIAL = ? "
	cQuery += "  AND SAH.AH_UNIMED = SB1.B1_UM "
	cQuery += "  AND SAH.D_E_L_E_T_ = ? "
	
	If lPesqSA5
		cQuery += " LEFT JOIN " + RetSqlName("SA5") + " SA5 "
		cQuery += "  ON SA5.A5_FILIAL = ? "
		cQuery += "  AND SA5.A5_PRODUTO = SB1.B1_COD " 
		cQuery += "  AND SA5.A5_CODBAR != ? "
		cQuery += "  AND SA5.D_E_L_E_T_ = ? "
	EndIf

	If cDadosProd == "SBZ"
		cQuery += " LEFT JOIN " + RetSqlName("SBZ") + " SBZ "
		cQuery += "  ON SBZ.BZ_FILIAL = ? "
		cQuery += "  AND SBZ.BZ_COD = SB1.B1_COD "
		cQuery += "  AND SBZ.D_E_L_E_T_ = ? "
	EndIf

	cQuery += " WHERE SB1.B1_FILIAL = ? "
	cQuery += " AND SB1.B1_MSBLQL <> ? "
	cQuery += " AND SB1.D_E_L_E_T_ = ? "

	If !Empty( cProductId )
		If lPesqSA5
			cQuery += " AND ( B1_COD = ? OR B1_CODBAR = ? OR A5_CODBAR = ? ) "
		Else
			cQuery += " AND ( B1_COD = ? OR B1_CODBAR = ? ) "
		EndIf
	ElseIf !Empty( cSearch )
		cQuery  += " AND ( B1_COD LIKE ? OR "
	    cQuery  += "B1_CODBAR LIKE ? OR "
	    cQuery  += "B1_DESC LIKE ? )"
	EndIf

	If !Empty(cTypeProduct)
		cQuery += " AND B1_TIPO IN ? "
	EndIf

	If lExistSB2
		cQuery += " AND B1_COD IN ( SELECT DISTINCT B2_COD FROM " + RetSqlName("SB2") + " SB2 WHERE B2_FILIAL = ? AND SB2.D_E_L_E_T_ = ? )" 
	EndIf

	If lDesLotZer
		cQuery += " AND (SB8.B8_SALDO > ? OR " + MATIsNull() + "(SB8.B8_LOTECTL, ' ') = ? )"
	EndIf

	cQuery += " 	) TABLE_SB1 "
	cQuery += " WHERE LINHA BETWEEN ? "  
	cQuery += " 		AND ? " 

	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)

	oExec:SetString(nParam++, FWxFilial("SB8"))
	oExec:SetString(nParam++, " ")
	oExec:SetString(nParam++, "N")
	oExec:SetString(nParam++, FWxFilial("SAH"))
	oExec:SetString(nParam++, " ")

	If lPesqSA5
		oExec:SetString(nParam++, FWxFilial("SA5"))
		oExec:SetString(nParam++, " ")
		oExec:SetString(nParam++, " ")
	EndIf

	If cDadosProd == "SBZ"
		oExec:SetString(nParam++, FWxFilial("SBZ"))
		oExec:SetString(nParam++, " ")
	EndIf

	oExec:SetString(nParam++, FWxFilial("SB1"))
	oExec:SetString(nParam++, "1")
	oExec:SetString(nParam++, " ")

	If !Empty( cProductId )
		If lPesqSA5
			oExec:SetString(nParam++, cProductId)
			oExec:SetString(nParam++, cProductId)
			oExec:SetString(nParam++, cProductId)
		Else
			oExec:SetString(nParam++, cProductId)
			oExec:SetString(nParam++, cProductId)
		EndIf
	ElseIf !Empty( cSearch )
		oExec:SetString(nParam++, "%" + cSearch + "%")
		oExec:SetString(nParam++, "%" + cSearch + "%")
		oExec:SetString(nParam++, "%" + cSearch + "%")
	EndIf

	If !Empty(cTypeProduct)
		oExec:SetUnSafe(nParam++, FormatIn(cTypeProduct, ","))
	EndIf

	If lExistSB2
		oExec:SetString(nParam++, FWxFilial("SB2"))
		oExec:SetString(nParam++, " ")
	EndIf

	If lDesLotZer
		oExec:SetNumeric(nParam++, 0)
		oExec:SetString(nParam++, " ")
	EndIf

	oExec:SetNumeric(nParam++, nRecStart)
	oExec:SetNumeric(nParam++, nRecFinish)

	oExec:OpenAlias(cAliasQry)

	DbSelectArea(cAliasQry)

ElseIf nTp == 2 // locais de estoque

	cQuery := " SELECT "
	cQuery += "   NNR_CODIGO CODARM "
	cQuery += " , NNR_DESCRI DESCRI  "
	cQuery += " FROM " + RetSqlName("NNR") + " NNR"
	cQuery += " WHERE NNR.NNR_FILIAL = ? "

	If !Empty(cSearch)
		cQuery  += " AND ( NNR_CODIGO  	LIKE ? OR "
	    cQuery  += " NNR_DESCRI    	LIKE ? ) "
	EndIf

	cQuery += " AND NNR.D_E_L_E_T_ = ? "
	cQuery += " ORDER BY NNR_CODIGO "

	cQuery := ChangeQuery(cQuery)

	oExec := FwExecStatement():New(cQuery)
	oExec:SetString(nParam++, FWxFilial("NNR"))

	If !Empty(cSearch)
		oExec:SetString(nParam++, "%" + cSearch + "%")
		oExec:SetString(nParam++, "%" + cSearch + "%")
	EndIf

	oExec:SetString(nParam++, " ")

	oExec:OpenAlias(cAliasQry)
	DbSelectArea(cAliasQry)

Else //Endereços

	cQuery := " SELECT  "
	cQuery += " 		SBE.BE_LOCAL CODARM "
	cQuery += " 		, SBE.BE_LOCALIZ ADDRESS "
	cQuery += " 		, SBE.BE_DESCRIC DESCRIC "
	cQuery += " 		, SBE.BE_STATUS STATUS "
	cQuery += " 		, SBE.R_E_C_N_O_ REC "
	cQuery += " FROM " + RetSqlName("SBE") + " SBE "
	cQuery += " WHERE SBE.BE_FILIAL = ? "

	If !Empty(cSearch)
		cQuery  += " AND ( BE_LOCAL  	LIKE ? OR"
		cQuery  += "  BE_LOCALIZ  	LIKE ? OR"
	    cQuery  += "  BE_DESCRIC    	LIKE ? )
	EndIf

	cQuery += " AND SBE.D_E_L_E_T_ = ? "
	cQuery += " ORDER BY BE_LOCAL,BE_LOCALIZ "

	cQuery := ChangeQuery(cQuery)

	oExec := FwExecStatement():New(cQuery)
	oExec:SetString(nParam++, FWxFilial("SBE"))

	If !Empty(cSearch)
		oExec:SetString(nParam++, "%" + cSearch + "%")
		oExec:SetString(nParam++, "%" + cSearch + "%")
		oExec:SetString(nParam++, "%" + cSearch + "%")
	EndIf

	oExec:SetString(nParam++, " ")

	oExec:OpenAlias(cAliasQry)
	DbSelectArea(cAliasQry)


Endif

FreeObj(oExec)

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} POST  transfer / ACDMOB
 finaliza a transferencia

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD POST transfer WSSERVICE ACDMOB

Local nStatusCode   := 500
Local oJTransfer	:= Nil
Local cMessage		:= ""
Local cResponse 	:= ""
Local cBody			:= ""
Local nX			:= 0
Local nQtdEmb		:= 0
Local lRet			:= .T.
Local cCodOpe   	:= CBRetOpe()
Local cAlias        := GetnextAlias()
Local cOrdem		:= ''
Local nCounReg		:= 0
Local aTransf		:= {}
Local oJsontrans	:= JsonObject():New()
Local aJtrans		:= {}
Local aSaldo		:= {}
Local lGrvD3V		:= .F.
Local cMotivo		:= ''
Local cPath     	:= GetSrvProfString("StartPath","")
Local cFile     	:= NomeAutoLog()
Local cMsgErro		:= ''
Local dValid		:= dDatabase
Local nCount 		:= 1
Local lAchouSB1		:= .F.
Local cDadosProd 	:= ''
Local lDadosSBZ		:= .T.

Local oError := ErrorBlock({|e| cMessage := STR0022, nStatusCode := 500, lRet := .F.}) // "Erro na leitura da requisicao. Contate o administrador do sistema."

Local nTamFil 		:= 0
Local nTamArmOrig	:= 0
Local nTamProd 		:= 0
Local nTamLote		:= 0
Local nTamEndDest 	:= 0

Private lMsHelpAuto , lMsErroAuto, lMsFinalAuto := .f.

Self:SetContentType("application/json")


If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0010 //'Usuario nao cadastrado para inventario'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			FWJsonDeserialize(Upper(cBody),@oJTransfer)

			If !Empty( oJTransfer )

				Begin Sequence

					nTamFil 	:= TAMSX3("D3V_FILIAL")[1]
					nTamArmOrig := TAMSX3("D3V_LOCORI")[1]
					nTamProd 	:= TAMSX3("B1_COD")[1] 
					nTamLote	:= TAMSX3("D3V_LOTECT")[1]
					nTamEndDest := TAMSX3("D3V_LCZDES")[1]

					oJsonTrans 		:=  JsonObject():New()
					aTransf	:= {}
					dbSelectArea("SD3")
					aadd (aTransf,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
					nCount := 1
					
					For nX := 1 To Len( oJTransfer )
						lGrvD3V	:= .F.
						lAchouSB1 := .F.
						SB1->(DbSetOrder(5))
						If SB1->(MsSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+oJTransfer[nX]:Code))
							lAchouSB1 := .T.
						Else
							SB1->(DbSetOrder(1))
							If SB1->(MsSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+oJTransfer[nX]:Code))
								lAchouSB1 := .T.
							EndIf
						Endif
						SB1->(DbSetOrder(1))
						If lAchouSB1
							nQtdEmb := AcdMobEmb(SB1->B1_COD,oJTransfer[nX]:Quantity)

							aSaldo  := CalcEst(SB1->B1_COD,oJTransfer[nX]:WarehouseOrigin,ddatabase+1)
							
							If aSaldo[1] < nQtdEmb
								lGrvD3V	:= .T.
								cMotivo := "2" // saldo divergente
							Else
								If  !SB2->(DbSeek(padr(xFilial("SB2"),TAMSX3("B2_FILIAL")[1])+SB1->B1_COD+oJTransfer[nX]:WarehouseEnd))
									//{Filial, Armazem, Estoque Disponivel, Branco}
									CriaSB2(SB1->B1_COD,oJTransfer[nX]:WarehouseEnd,xFilial("SB2"))

								EndIf
								lDadosSBZ		:= .F.
								If cDadosProd == "SBZ"
									dbSelectArea("SBZ")
									lDadosSBZ:=!RetArqProd(cCodPro)
								EndIf
								If BlqInvent(SB1->B1_COD,oJTransfer[nX]:WarehouseOrigin,,;
								If(IF(lDadosSBZ,SBZ->BZ_LOCALIZ,SB1->B1_LOCALIZ) = 'S',oJTransfer[nX]:AddressOrigin,""))
									lGrvD3V	:= .T.
									cMotivo := "3" // bloqueio por inventario
								Else
									If BlqInvent(SB1->B1_COD,oJTransfer[nX]:WarehouseEnd,,;
									If(IF(lDadosSBZ,SBZ->BZ_LOCALIZ,SB1->B1_LOCALIZ) = 'S',oJTransfer[nX]:AddressEnd,""))
										lGrvD3V	:= .T.
										cMotivo := "3" // bloqueio por inventario
									EndIf

								EndIf
								/*If Localiza(SB1->B1_COD,.T.)
									If EmpTy(oJTransfer[nX]:SerialNumber)
										lGrvD3V	:= .T.
										cMotivo := "4" // serial number não encontrado para o endereço
									Endif

								EndIf	*/

							Endif
						Else
							lGrvD3V	:= .T.
							cMotivo := "1" // produto não encontrado
						Endif
	
						nCount ++
						dValid := dDatabase+SB1->B1_PRVALID
						If Rastro(SB1->B1_COD)
							SB8->(DbSetOrder(3))
							If SB8->(DbSeek(padr(xFilial("SB8"),TAMSX3("B8_FILIAL")[1])+SB1->B1_COD+oJTransfer[nX]:WarehouseOrigin+oJTransfer[nX]:Batch))
								dValid := SB8->B8_DTVALID
							EndIf
						EndIf
						aAdd(aTransf,{})
						//Origem
						aTransf[nCount]:= {{"D3_COD"      , SB1->B1_COD              									,NIL}}
						aAdd(aTransf[nCount],{"D3_DESCRI" , SB1->B1_DESC               									,NIL})
						aAdd(aTransf[nCount],{"D3_UM"     , SB1->B1_UM                 									,NIL})
						aAdd(aTransf[nCount],{"D3_LOCAL"  , padr(oJTransfer[nX]:WarehouseOrigin,TAMSX3("D3_LOCAL")[1])	,NIL})
						aAdd(aTransf[nCount],{"D3_LOCALIZ", padr(oJTransfer[nX]:AddressOrigin,TAMSX3("D3_LOCALIZ")[1])	,NIL})
						//Destino
						aAdd(aTransf[nCount],{"D3_COD"    , SB1->B1_COD             	  								,NIL})
						aAdd(aTransf[nCount],{"D3_DESCRI" , SB1->B1_DESC               									,NIL})
						aAdd(aTransf[nCount],{"D3_UM"     , SB1->B1_UM             	  									,NIL})
						aAdd(aTransf[nCount],{"D3_LOCAL"  , padr(oJTransfer[nX]:WarehouseEnd,TAMSX3("D3_LOCAL")[1])		,NIL})
						aAdd(aTransf[nCount],{"D3_LOCALIZ", padr(oJTransfer[nX]:AddressEnd,TAMSX3("D3_LOCALIZ")[1])		,NIL})

						//Origem
						aAdd(aTransf[nCount],{"D3_NUMSERI", padr(oJTransfer[nX]:SerialNumber,TAMSX3("D3_NUMSERI")[1])	,NIL})
						aAdd(aTransf[nCount],{"D3_LOTECTL", padr(oJTransfer[nX]:Batch,TAMSX3("D3_LOTECTL")[1])			,NIL})
						aadd(aTransf[nCount],{"D3_NUMLOTE", CriaVar('D3_NUMLOTE')									    ,Nil})
						aAdd(aTransf[nCount],{"D3_DTVALID", dValid      												,NIL})

						aAdd(aTransf[nCount],{"D3_POTENCI", CriaVar("D3_POTENCI")      									,NIL})
						aAdd(aTransf[nCount],{"D3_QUANT"  , nQtdEmb  													,NIL})
						aAdd(aTransf[nCount],{"D3_QTSEGUM", CriaVar("D3_QTSEGUM")      									,NIL})
						aAdd(aTransf[nCount],{"D3_ESTORNO", CriaVar("D3_ESTORNO")      									,NIL})
						aAdd(aTransf[nCount],{"D3_NUMSEQ" , CriaVar("D3_NUMSEQ")		  								,NIL})

						//Destino
						aAdd(aTransf[nCount],{"D3_LOTECTL", padr(oJTransfer[nX]:Batch,TAMSX3("D3_LOTECTL")[1])			,NIL})
						aadd(aTransf[nCount],{"D3_NUMLOTE", CriaVar('D3_NUMLOTE') 										,Nil})
						aAdd(aTransf[nCount],{"D3_DTVALID", dValid	    												,NIL})

						If lGrvD3V
							D3V->(DbSetOrder(4))
							If	!D3V->(DBSeek(padr(xFilial("D3V"), nTamFil )+'4'+ Padr( oJTransfer[nX]:WarehouseOrigin, nTamArmOrig ) + ;
								Padr( SB1->B1_COD, nTamProd ) + Padr( oJTransfer[nX]:Batch, nTamLote ) + Padr( oJTransfer[nX]:addressEnd, nTamEndDest ) ) )
								
									// Grava a tabela de divergencia
									RecLock("D3V",.t.)
										D3V->D3V_FILIAL	:= xFilial("D3V")
										D3V->D3V_CODIGO	:= GetSXENum("D3V", "D3V_CODIGO")
										D3V->D3V_ORIGEM	:= '4'
										D3V->D3V_MOTIVO	:= cMotivo
										D3V->D3V_CODPRO	:= SB1->B1_COD
										D3V->D3V_QTDE	:= nQtdEmb
										D3V->D3V_LOTECT	:= oJTransfer[nX]:Batch
										D3V->D3V_CODUSR	:= cCodOpe
										D3V->D3V_DTVLD	:= dValid
										D3V->D3V_CODETI	:= ''
										D3V->D3V_DATA	:= dDatabase
										D3V->D3V_HORA	:= Time()
										D3V->D3V_STATUS	:= '1'
										D3V->D3V_UM     :=  SB1->B1_UM
										D3V->D3V_LOCORI := oJTransfer[nX]:WarehouseOrigin
										D3V->D3V_LCZORI := oJTransfer[nX]:AddressOrigin
										D3V->D3V_LOCDES := oJTransfer[nX]:WarehouseEnd
										D3V->D3V_LCZDES := oJTransfer[nX]:AddressEnd
										D3V->D3V_NUMSER := oJTransfer[nX]:SerialNumber

									D3V->(MsUnLock())
								ConfirmSx8()
							Endif
						EndIf

						aAdd( aJtrans,  	JsonObject():New() )
											aJtrans[nX]["code"				]	:= oJTransfer[nX]:Code
											aJtrans[nX]["WarehouseOrigin"	]	:= oJTransfer[nX]:WarehouseOrigin
											aJtrans[nX]["AddressOrigin"		]	:= padr(oJTransfer[nX]:AddressOrigin,TAMSX3("D3_LOCALIZ")[1])
											aJtrans[nX]["WarehouseEnd"		]	:= padr(oJTransfer[nX]:WarehouseEnd,TAMSX3("D3_LOCAL")[1])
											aJtrans[nX]["AddressEnd"		]	:= padr(oJTransfer[nX]:AddressOrigin,TAMSX3("D3_LOCALIZ")[1])
											aJtrans[nX]["serialNumber"		]	:= padr(oJTransfer[nX]:SerialNumber,TAMSX3("D3_NUMSERI")[1])
											aJtrans[nX]["batch"				]	:= oJTransfer[nX]:Batch
											aJtrans[nX]["quantity"			]	:= nQtdEmb

					Next nX

				End Sequence

				ErrorBlock(oError)

				oJsonTrans["transfers"] := aJtrans
				aJtrans := {}

				If !lRet
					cResponse 	:= ''
				Endif

			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf

		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf

If lRet
	cResponse := FwJsonSerialize( oJsonTrans )
    Self:SetResponse( cResponse )
	If Len(aTransf) > 1
    	lMsErroAuto := .F.
	    MSExecAuto({|x| MATA261(x)},aTransf)
	    If !lMsErroAuto
			CONFIRMSX8()
		Else
	    	lRet := .F.
			cMsgErro := MostraErro(cPath,cFile)
			conout( cMsgErro )
			nStatusCode := 500
			cMessage := cMsgErro // "Erro durante a transferencia. Contate o administrador do sistema."
		EndIf
	Endif
EndIf
If !lRet
	If empty(cMessage) 
		 cMessage := STR0012  //'Erro Interno'
	EndIF
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

If ValType(oJsonTrans) == "O"
	FreeObj(oJsonTrans)
	oJsonTrans := Nil
Endif

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de Documentos para conferencia.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Status       , numerico, Fazer o filtro por de conferências selecionadas ou não selecionadas. ex: 1 = não selecionadas;2= selecionadas
        Page         , numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 10.
        PageSize	 , numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 10 até 20.
        statusOs     , caracater, Informar filtro do status da ordem de separação, sendo 0 - somente não iniciadas, 1 - em andamento ( do usuário logado ) ou * - ambas
        ordemSep     , caracater, Informar ordem de separação CB7_ORDSEP
@return cResponse	, Array, JSON com Array com as conferências pendentes.

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET separations WSRECEIVE SearchKey, Status, Page, PageSize, statusOs, ordemSep WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local cAliasCB8         := GetnextAlias()
Local cResponse         := ''
Local oJsonSep 			:= JsonObject():New()
Local aJsonSep		  	:= {}
Local aJProdSep			:= {}
Local aJItemSep			:= {}
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nEntJson          := 0
Local nStart            := 0
Local cOrdem			:= ''
Local cCodOpe   		:= CBRetOpe()
Local nCounReg			:= 0
Local lHasNext			:= .F.
Local nCounProd			:= 0

Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 20
Default Self:statusOs   := '*'
Default Self:ordemSep  	:= ''

Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If !(Self:statusOs $ '0|1|9|*') .Or. Len(Self:statusOs) > 1
    lRet 		:= .F.
    nStatusCode := 400
    cMessage 	:= STR0027 //"Para filtrar status da ordem de separação utilize, 0-Não Iniciada, 1-Em andamento ou * para ambas"
Endif

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))



	    GetSep(UPPER(Self:SearchKey), Self:Status, cAlias, Self:ordemSep, Self:statusOs )
	    If (cAlias)->(!EOF())

	         COUNT TO nRecord
	        (cAlias)->(DBGoTop())

	        //-------------------------------------------------------------------
			// Limita a pagina.
			//-------------------------------------------------------------------
			If Self:PageSize > 10
				Self:PageSize := 10
			EndIf

	        If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
	        EndIf
	        oJsonSep 			:=  JsonObject():New()

	        cOrdem:= ''
	        While (cAlias)->(!EOF())
	        	If cOrdem <> (cAlias)->ORDEM
	        		nCount++
	        		cOrdem :=  (cAlias)->ORDEM

	        	ENdif


	            If (nCount >= nStart)
	                cOrdem :=  (cAlias)->ORDEM
	                nEntJson++
	                aAdd( aJsonSep,  JsonObject():New() )
	                cOrdem := (cAlias)->ORDEM
	                aJsonSep[nEntJson]["code"			]	:= AllTrim( (cAlias)->ORDEM 				)
					aJsonSep[nEntJson]["type"			]	:= AllTrim( (cAlias)->ORIGEM 				)
					aJsonSep[nEntJson]["activitys"		]	:= AllTrim( (cAlias)->TPSEP   				)
	               	aJsonSep[nEntJson]["status"			]	:= AllTrim( (cAlias)->STATUS     		    )

	                nCounReg := 0

	                While (cAlias)->(!EOF() .AND. (cAlias)->ORDEM == cOrdem)

	                	cDoc :=  (cAlias)->DOC
	                	nCounReg ++
	                	aAdd( aJItemSep,  JsonObject():New() )
	                	aJItemSep[nCounReg]["document"		]	:= (cAlias)->DOC
	                    aJItemSep[nCounReg]["name"			]	:= AllTrim( (cAlias)->NOME  	)
						aJItemSep[nCounReg]["customerCode"	]	:= AllTrim( (cAlias)->CUSTOMER  )
						aJItemSep[nCounReg]["customerUnit"	]	:= AllTrim( (cAlias)->STORE  	)
						aJItemSep[nCounReg]["customerAddress"]	:= AllTrim( (cAlias)->ADDRESS  	)
						aJItemSep[nCounReg]["state"			]	:= AllTrim( (cAlias)->STATE  	)
						aJItemSep[nCounReg]["city"			]	:= AllTrim( (cAlias)->CITY  	)						

	                 	nCounProd:= 0
	                 	While (cAlias)->(!EOF()) .AND. (cAlias)->ORDEM == cOrdem .AND. (cAlias)->DOC == cDoc
	                 		nCounProd++
		                    aAdd( aJProdSep,  JsonObject():New() )
		                    aJProdSep[nCounProd]["code"			]	:= (cAlias)->CB8_PROD
		                    aJProdSep[nCounProd]["barcode"		]	:= AllTrim( (cAlias)->CODBAR					)
		                    aJProdSep[nCounProd]["item"			]	:= (cAlias)->CB8_ITEM	 				
		                    aJProdSep[nCounProd]["sequence"		]	:= (cAlias)->CB8_SEQUEN 				
		                    aJProdSep[nCounProd]["description"	]	:= EncodeUTF8( (cAlias)->DESCRI			 		)
		                    aJProdSep[nCounProd]["warehouse"	]	:= (cAlias)->CB8_LOCAL		   			
		                    aJProdSep[nCounProd]["address"		]	:= (cAlias)->CB8_LCALIZ     			
							aJProdSep[nCounProd]["serialNumber"	]	:= (cAlias)->CB8_NUMSER				
		                    aJProdSep[nCounProd]["batch"		]	:= (cAlias)->CB8_LOTECT 				
							aJProdSep[nCounProd]["sublot"		]	:= (cAlias)->CB8_NUMLOT				
		                    aJProdSep[nCounProd]["quantity"		]	:= (cAlias)->CB8_QTDORI
							aJProdSep[nCounProd]["balance"		]	:= (cAlias)->CB8_SALDOS

							// -------------------------------------------------------------------------------------------//
							// Futura implementação de alteração de Lot e SubLot										  //
							//--------------------------------------------------------------------------------------------//
							aJProdSep[nCounProd]["newSNumber"	]	:= CriaVar('CB8_NUMSER')   						
					        aJProdSep[nCounProd]["newbatch"		]	:= CriaVar('CB8_LOTECTL') 		 				
							aJProdSep[nCounProd]["newsublot"	]	:= CriaVar('CB8_NUMLOTE')						

							// -------------------------------------------------------------------------------------------//
							// Implementação de alteração de Divergence										  //
							//--------------------------------------------------------------------------------------------//
							aJProdSep[nCounProd]["divergence"	]	:= (cAlias)->CB8_OCOSEP						

							// -------------------------------------------------------------------------------------------//
							// Implementação de alteração de Lot										  		  //
							//--------------------------------------------------------------------------------------------//
							aJProdSep[nCounProd]["cflote"	]	:= (cAlias)->CB8_CFLOTE				

		                	(cAlias)->(DbSkip())
		                End
		                aJItemSep[nCounReg]["products"] := aJProdSep
		                aJProdSep := {}
	                End

	                aJsonSep[nEntJson]["items"] := aJItemSep
					aJItemSep := {}


	                If nEntJson < Self:PageSize .And. nCount < nRecord

	                Else
	                    Exit
	                EndIf

	            Else
	        		(cAlias)->(DbSkip())
	            EndIf

	            If ( nEntJson == Self:PageSize )
	                Exit
				EndIf

	        EndDo

	        If nEntJson >= nRecord .Or. (nEntJson + nStart) >= nRecord .Or. nEntJson < Self:PageSize

	            lHasNext	:= .F.
	        Else
	            lHasNext	:= .T.
	        EndIf
	    Else
	    	oJsonSep 				:=  JsonObject():New()
	    	oJsonSep["separations"]	:= aJsonSep
	    	oJsonSep["hasNext"] 	:= lHasNext

	    EndIf
	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

If Select(cAliasCB8) > 0
	(cAliasCB8)->(dbCloseArea())
Endif
If lRet
	oJsonSep["separations"]	:= aJsonSep
	oJsonSep["hasNext"] 	:= lHasNext
	cResponse := FwJsonSerialize( oJsonSep )
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonSep) == "O"
	FreeObj(oJsonSep)
	oJsonSep := Nil
Endif

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GetRastro()
Constroi um Query com a Seleção de produtos, uma com selação de armazens, uma com seleção de endereços

@param  nGet     	, Numeric, Define qual Get está sendo consumido na pesquisa.
		cSearch     , caracter, Define quais valores será utilizado como chave de consulta.
        cStatus   	, caracter, Fazer o filtro por de conferências selecionadas ou não selecionadas.
        cAliasQry   , caracter, Alias para Query.

@return

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetIsep(cAliasCB8,cOrdSep,cOrigem )
Local cConcat       := IIF( !"MSSQL" $ TCGetDB(), "||", "+" )
Local cSelect		:= ""
If cOrigem == '1'

	BeginSQL Alias cAliasCB8

		SELECT CB8_PROD,CB8_ITEM,CB8_PEDIDO DOC,CB8_SEQUEN,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_QTDORI,A1_NOME NOME, B1_DESC DESCRI, B1_CODBAR CODBAR
		FROM
			%Table:CB8% CB8
			LEFT JOIN %Table:SC5% SC5 On
			SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = CB8.CB8_PEDIDO
			AND SC5.%NotDel%
			LEFT JOIN %Table:SA1% SA1 On
				SA1.A1_FILIAL = %xFilial:SA1%
				AND SA1.A1_COD = SC5.C5_CLIENTE
				AND SA1.A1_LOJA = SC5.C5_LOJACLI
				AND SA1.%NotDel%
			INNER JOIN %Table:SB1% SB1 On
				SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = CB8.CB8_PROD
				AND SB1.B1_MSBLQL  <> '1'
				AND SB1.%NotDel%
		WHERE
			CB8.CB8_FILIAL = %xFilial:CB8%
			AND CB8.CB8_ORDSEP	= %Exp:cOrdSep%
			AND CB8.%NotDel%

		ORDER BY CB8_ORDSEP,CB8_PEDIDO
	EndSQL
ElseIf cOrigem == '2'

	cSelect		:= "% ,CB8_NOTA " +  cConcat + " CB8_SERIE DOC  %"

	BeginSQL Alias cAliasCB8

		SELECT CB8_PROD,CB8_ITEM,CB8_PEDIDO PEDIDO,CB8_SEQUEN,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_QTDORI,A1_NOME NOME, B1_DESC DESCRI, B1_CODBAR CODBAR
		%EXP:cSelect%
		FROM
			%Table:CB8% CB8
			LEFT JOIN %Table:SC5% SC5 On
			SC5.C5_FILIAL = %xFilial:SC5%
			AND SC5.C5_NUM = CB8.CB8_PEDIDO
			AND SC5.%NotDel%
			LEFT JOIN %Table:SA1% SA1 On
				SA1.A1_FILIAL = %xFilial:SA1%
				AND SA1.A1_COD = SC5.C5_CLIENTE
				AND SA1.A1_LOJA = SC5.C5_LOJACLI
				AND SA1.%NotDel%
			INNER JOIN %Table:SB1% SB1 On
				SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = CB8.CB8_PROD
				AND SB1.B1_MSBLQL  <> '1'
				AND SB1.%NotDel%
		WHERE
			CB8.CB8_FILIAL = %xFilial:CB8%
			AND CB8.CB8_ORDSEP	= %Exp:cOrdSep%
			AND CB8.%NotDel%

		ORDER BY CB8_ORDSEP,CB8_NOTA
	EndSQL

Else
	BeginSQL Alias cAliasCB8

		SELECT CB8_PROD,CB8_ITEM,CB8_OP DOC,CB8_SEQUEN,CB8_LOCAL,CB8_LCALIZ,CB8_LOTECT,CB8_QTDORI, B1_DESC DESCRI, B1_CODBAR CODBAR, ' ' NOME
		FROM
			%Table:CB8% CB8
			INNER JOIN %Table:SB1% SB1 On
				SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = CB8.CB8_PROD
				AND SB1.B1_MSBLQL  <> '1'
				AND SB1.%NotDel%
		WHERE
			CB8.CB8_FILIAL = %xFilial:CB8%
			AND CB8.CB8_ORDSEP	= %Exp:cOrdSep%
			AND CB8.%NotDel%

		ORDER BY CB8_ORDSEP,CB8_OP
	EndSQL
EndIf




return



//-------------------------------------------------------------------
/*/{Protheus.doc} PUT  Separations / ACDMOB
 Altera o Status da separacao ou finaliza no protheus

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Fernando Amorim (Cafu)
@since		08/01/2019
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD PUT Separations WSSERVICE ACDMOB
Local oJSepara		:= Nil
Local nStatusCode   := 500
Local cMessage
Local cResponse 	:= ""
Local cBody			:= ""
Local nX			:= 0
Local aRet          := {}
Local lRet			:= .T.
Local cCodOpe   	:= CBRetOpe()
Local cAlias        := GetnextAlias()
Local cOrdem		:= ''
Local nCounReg		:= 0
Local nTamProd		:= 	TamSX3("CB8_PROD")	[1]
Local nTamCTL		:=	TamSX3("CB8_LOTECT")[1]
Local nTamSCTL		:=	TamSX3("CB8_NUMLOT")[1]
Local nTamNserie	:=	TamSX3("CB8_NUMSER")[1]
Local nTamEnd		:=  TamSX3("CB8_LCALIZ")[1]
Local oJsonSep 		:= JsonObject():New()
Local aJProdSep		:= {}
Local aJItemSep		:= {}
Local nCounProd		:= 0
LOcal cDoc			:= ""
Local cNumSa		:= ""
Local lEncerraSA	:= .F.

Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0013 // 'Usuario nao cadastrado para separacao'
	 lRet			   := .F.
EndIf

//Carrega variável static '__lSaOrdSep'
FnVlSaOs()

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			FWJsonDeserialize(cBody,@oJSepara)

			If !Empty( oJSepara )
				If SepTpAmb(oJSepara, @nStatusCode, @cMessage, @lRet)
					CB7->(DbSetOrder(1))
					If CB7->( MSSeek( padr(xFilial("CB7"),TAMSX3("CB7_FILIAL")[1]) + Self:aURLParms[2]) )

						If __lSaOrdSep
							cNumSa := CB7->CB7_NUMSA
						EndIf

						If oJSepara:Status == '2'
							
							If CB7->CB7_STATUS $ ('0|1')

								If AttIsMemberOf(oJSepara,"products")
									oJsonSep 				:=  JsonObject():New()
									oJsonSep["code"]		:= oJSepara:Code
									oJsonSep["type"]		:= oJSepara:Type
									oJsonSep["activitys"]	:= oJSepara:Activitys
									oJsonSep["status"]		:= oJSepara:Status
									If AttIsMemberOf(oJSepara,"conclude")
										lEncerraSA := oJSepara:conclude
									EndIf

									cCodCB0				:= CriaVar('CB0_CODETI')

									Begin Transaction
										For nX := 1 To Len( oJSepara:products )            //Parametros da funcao
											If Empty(oJSepara:products[nX]:divergence)
												If oJSepara:products[nX]:quantity == 0     //Caso encontre produto com quantidade 0 desconsidera
													Loop
												EndIf

												lRet := GravaCB8(oJSepara:products[nX]:quantity,;    //1  Quantidade 
																oJSepara:products[nX]:Warehouse,;   //2  armazém
																Padr(oJSepara:products[nX]:Address,nTamEnd) ,; //3  endereço
																Padr(oJSepara:products[nX]:Code,nTamProd)  	,; //4  Produto separado
																Padr(oJSepara:products[nX]:Batch,nTamCTL)	,; //5  Lote
																Padr(oJSepara:products[nX]:sublot,nTamSCTL)	,; //6  S Lote
																Padr(oJSepara:products[nX]:newbatch,nTamCTL),; //7  novo  Lote 
																Padr(oJSepara:products[nX]:newsublot,nTamSCTL),; //8  numero de série
																Padr(oJSepara:products[nX]:serialNumber,nTamNserie)	,; //9 numero de série
																cCodCB0										,;//10 código etiqueta CB0
																Padr(oJSepara:products[nX]:newSNumber,nTamNserie),;//11 Novo numero de série 
																.T.											,;//12   lApp - ativa tratamento mobile
																oJSepara:products[nX]:Item					,;//13 item 
																CB7->CB7_ORDSEP								,;//14 ordem de separação
																oJSepara:Type								,;//15 tipo de gravação
																oJSepara:products[nX]:Document				,;//16  documento
																oJSepara:products[nX]:Sequence    		    ,;//17 sequencia do pedido/doc/op
																.F.											,;//18 determina se irá validar o número de série CB8
																cNumSa		    		                     )//19 numero da SA
											Else
												lRet := .T.
											EndIf
											If lRet
												aAdd( aJProdSep,  JsonObject():New() )
												aJProdSep[nX]["code"			]	:= oJSepara:products[nX]:Code
												aJProdSep[nX]["barcode"			]	:= oJSepara:products[nX]:Barcode
												aJProdSep[nX]["item"			]	:= oJSepara:products[nX]:Item
												aJProdSep[nX]["sequence"		]	:= oJSepara:products[nX]:Sequence
												aJProdSep[nX]["description"		]	:= oJSepara:products[nX]:Description
												aJProdSep[nX]["warehouse"		]	:= oJSepara:products[nX]:Warehouse
												aJProdSep[nX]["address"			]	:= oJSepara:products[nX]:Address
												aJProdSep[nX]["serialNumber"	]	:= oJSepara:products[nX]:serialNumber
												aJProdSep[nX]["batch"			]	:= oJSepara:products[nX]:Batch
												aJProdSep[nX]["sublot"			]	:= oJSepara:products[nX]:sublot
												aJProdSep[nX]["quantity"		]	:= oJSepara:products[nX]:Quantity
												If AttIsMemberOf(oJSepara:products[nX],"balance")
													aJProdSep[nX]["balance"		]	:= oJSepara:products[nX]:Balance
												EndIf

												aJProdSep[nX]["newbatch"		]	:= oJSepara:products[nX]:newbatch
												aJProdSep[nX]["newsublot"		]	:= oJSepara:products[nX]:newsublot
												aJProdSep[nX]["newSNumber"		]	:= oJSepara:products[nX]:newSNumber
												aJProdSep[nX]["divergence"		]	:= oJSepara:products[nX]:divergence
											Else
												exit
											Endif
										Next nX

										If lRet
											aRet := FimProc166(.T.,CB7->CB7_ORDSEP, .T., lEncerraSA)
											// caso retornar erro no processamento da requisição, retorna mensagem para central de notificiação do app
											If aRet[1] == 10  
												lRet 		:= .F.
												nStatusCode	:= 400
												cMessage 	:= aRet[2] 

												If __lSaOrdSep .And. oJSepara:Type == "4"
													DisarmTransaction()
													Break
												EndIf
											Else
												oJsonSep["products"] := aJProdSep
												aJProdSep := {}
											Endif
										Else
											cResponse := ''
											nStatusCode	:= 400
											cMessage 	:= STR0028 //"Erro ao inserir separação" 
										Endif
									End Transaction
								Else
									lRet 		:= .F.
									nStatusCode	:= 400
									cMessage 	:= STR0014 //"Dados da separacao nao enviados..."
								Endif
							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0016 //"Separacao ja iniciada por outro separador ou finalizada..."
							Endif
						ElseIf oJSepara:Status == '1'

							If CB7->CB7_STATUS == '0' .Or. ( CB7->CB7_STATUS == '1' .And. CB7->CB7_CODOPE == cCodOpe )

								GetSep(,,cAlias,Alltrim(Self:aURLParms[2]) )

								While (cAlias)->(!EOF())
									oJsonSep 		:=  JsonObject():New()

									cOrdem	:= (cAlias)->ORDEM

									oJsonSep["code"]		:= AllTrim( (cAlias)->ORDEM   				)
									oJsonSep["type"]		:= AllTrim( (cAlias)->ORIGEM   				)
									oJsonSep["activitys"]	:= AllTrim( (cAlias)->TPSEP   				)
									oJsonSep["status"]		:= oJSepara:Status


									While (cAlias)->(!EOF() .AND. (cAlias)->ORDEM == cOrdem)

										cDoc :=  (cAlias)->DOC
										nCounReg ++
										aAdd( aJItemSep,  JsonObject():New() )
										aJItemSep[nCounReg]["document"		]	:= (cAlias)->DOC
										aJItemSep[nCounReg]["name"			]	:= AllTrim( (cAlias)->NOME  	)
										aJItemSep[nCounReg]["customerCode"	]	:= AllTrim( (cAlias)->CUSTOMER  )
										aJItemSep[nCounReg]["customerUnit"	]	:= AllTrim( (cAlias)->STORE  	)
										aJItemSep[nCounReg]["customerAddress"]	:= AllTrim( (cAlias)->ADDRESS  	)
										aJItemSep[nCounReg]["state"			]	:= AllTrim( (cAlias)->STATE  	)
										aJItemSep[nCounReg]["city"			]	:= AllTrim( (cAlias)->CITY  	)

										nCounProd:= 0
										While (cAlias)->(!EOF()) .AND. (cAlias)->ORDEM == cOrdem .AND. (cAlias)->DOC == cDoc
											nCounProd++
											aAdd( aJProdSep,  JsonObject():New() )
											aJProdSep[nCounProd]["code"			]	:= (cAlias)->CB8_PROD
											aJProdSep[nCounProd]["barcode"		]	:= AllTrim( (cAlias)->CODBAR					)
											aJProdSep[nCounProd]["item"			]	:= (cAlias)->CB8_ITEM	 				
											aJProdSep[nCounProd]["sequence"		]	:= (cAlias)->CB8_SEQUEN 				
											aJProdSep[nCounProd]["description"	]	:= EncodeUTF8((cAlias)->DESCRI			 		)
											aJProdSep[nCounProd]["warehouse"	]	:= (cAlias)->CB8_LOCAL		   			
											aJProdSep[nCounProd]["address"		]	:= (cAlias)->CB8_LCALIZ     			
											aJProdSep[nCounProd]["serialNumber"	]	:= (cAlias)->CB8_NUMSER     			
											aJProdSep[nCounProd]["batch"		]	:= (cAlias)->CB8_LOTECT 				
											aJProdSep[nCounProd]["sublot"		]	:= (cAlias)->CB8_NUMLOT				
											aJProdSep[nCounProd]["quantity"		]	:= (cAlias)->CB8_QTDORI
											aJProdSep[nCounProd]["balance"		]	:= (cAlias)->CB8_SALDOS
										// -------------------------------------------------------------------------------------------//
										// Futura implementação de alteração de Lot e SubLot										  //
										//--------------------------------------------------------------------------------------------//
											aJProdSep[nCounProd]["newSNumber"	]	:= CriaVar('CB8_NUMSER')   						
											aJProdSep[nCounProd]["newbatch"		]	:= CriaVar('CB8_LOTECTL') 		 				
											aJProdSep[nCounProd]["newsublot"	]	:= CriaVar('CB8_NUMLOTE')						
											aJProdSep[nCounProd]["divergence"	]	:= (cAlias)->CB8_OCOSEP				
										// -------------------------------------------------------------------------------------------//
										// Implementação de alteração de Lot										  		  //
										//--------------------------------------------------------------------------------------------//
											aJProdSep[nCounProd]["cflote"	]	:= (cAlias)->CB8_CFLOTE					

											(cAlias)->(DbSkip())
										End
										aJItemSep[nCounReg]["products"] := aJProdSep
										aJProdSep := {}
									End


									oJsonSep["items"] := aJItemSep
									aJItemSep := {}

								End

								RecLock("CB7",.F.)
								CB7->CB7_STATUS := oJSepara:Status
								CB7->CB7_DTINIS := dDataBase
								CB7->CB7_HRINIS := LEFT(TIME(),5)
								CB7->CB7_CODOPE := cCodOpe
								CB7->(MsUnlock())

								If Select(cAlias) > 0
									(cAlias)->(dbCloseArea())
								Endif

							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0016 //"Separacao ja iniciada por outro separador ou finalizada..."

							EndIf

						Endif
					Else
						lRet 		:= .F.
						nStatusCode	:= 400
						cMessage 	:= STR0017 //"Separacao nao encontrada..."
					Endif
				EndIf
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf

		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005  //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf

If lRet
	cResponse := FwJsonSerialize( oJsonSep )
    Self:SetResponse( cResponse )
Else
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonSep) == "O"
	FreeObj(oJsonSep)
	oJsonSep := Nil
Endif
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT  undoSeparations / ACDMOB
 Estorna e Atualiza o Status da separacao no protheus

@param	Code, array com dados para mudança do status

@return lRet	, caracter, JSON

@author	 	Leonardo Kichitaro
@since		05/02/2025
@version	12.1.2410
/*/
//-------------------------------------------------------------------
WSMETHOD PUT undoSeparations WSSERVICE ACDMOB

Local oJSepara		:= Nil
Local nStatusCode   := 500
Local cMessage
Local cResponse 	:= ""
Local cBody			:= ""
Local nX			:= 0
Local nRecCB7		:= 0
Local nTamProd		:= 	TamSX3("CB8_PROD")[1]
Local aRet          := {}
Local lRet			:= .T.
Local cCodOpe   	:= CBRetOpe()
Local oJsonSep 		:= JsonObject():New()
Local aJProdSep		:= {}

Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0013 // 'Usuario nao cadastrado para separacao'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			FWJsonDeserialize(cBody,@oJSepara)

			If !Empty( oJSepara )

				If SepTpAmb(oJSepara, @nStatusCode, @cMessage, @lRet)
					CB9->(DBSetOrder(6))
					CB7->(DbSetOrder(1))
					If CB7->( MSSeek( padr(xFilial("CB7"),TAMSX3("CB7_FILIAL")[1]) + Self:aURLParms[2]) )
						nRecCB7 := CB7->(Recno())
						If oJSepara:Status == '2'
							If CB7->CB7_ORIGEM == "4"
								If CB7->CB7_STATUS $ ('1|9')

									If AttIsMemberOf(oJSepara,"products")
										lRet					:= .F.
										oJsonSep 				:=  JsonObject():New()
										oJsonSep["code"]		:= oJSepara:Code
										oJsonSep["type"]		:= oJSepara:Type
										oJsonSep["activitys"]	:= oJSepara:Activitys
										oJsonSep["status"]		:= oJSepara:Status

										Begin Transaction
											For nX := 1 To Len( oJSepara:products )            //Parametros da funcao
												lRet := .T.
												If CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+oJSepara:products[nX]:Item+Padr(oJSepara:products[nX]:Code,nTamProd)+oJSepara:products[nX]:Warehouse))
													If CB9->CB9_QTESEP > 0
														lRet := .T.
														EstProc176(CB9->CB9_QTESEP)

														aAdd( aJProdSep,  JsonObject():New() )
														aJProdSep[nX]["code"			]	:= oJSepara:products[nX]:Code
														aJProdSep[nX]["barcode"			]	:= oJSepara:products[nX]:Barcode
														aJProdSep[nX]["item"			]	:= oJSepara:products[nX]:Item
														aJProdSep[nX]["sequence"		]	:= oJSepara:products[nX]:Sequence
														aJProdSep[nX]["description"		]	:= oJSepara:products[nX]:Description
														aJProdSep[nX]["warehouse"		]	:= oJSepara:products[nX]:Warehouse
														aJProdSep[nX]["address"			]	:= oJSepara:products[nX]:Address
														aJProdSep[nX]["serialNumber"	]	:= oJSepara:products[nX]:serialNumber
														aJProdSep[nX]["batch"			]	:= oJSepara:products[nX]:Batch
														aJProdSep[nX]["sublot"			]	:= oJSepara:products[nX]:sublot
														aJProdSep[nX]["quantity"		]	:= oJSepara:products[nX]:Quantity
														If AttIsMemberOf(oJSepara:products[nX],"balance")
															aJProdSep[nX]["balance"			]	:= oJSepara:products[nX]:Balance
														EndIf
														aJProdSep[nX]["newbatch"			]	:= oJSepara:products[nX]:newbatch
														aJProdSep[nX]["newsublot"		]	:= oJSepara:products[nX]:newsublot
														aJProdSep[nX]["newSNumber"		]	:= oJSepara:products[nX]:newSNumber
														aJProdSep[nX]["divergence"		]	:= oJSepara:products[nX]:divergence
													EndIf
												EndIf
											Next nX

											If lRet
												aRet := FimProc176(.T., CB7->CB7_ORDSEP)
												// caso retornar erro no processamento da requisição, retorna mensagem para central de notificiação do app
												If aRet[1] == 10  
													lRet 		:= .F.
													nStatusCode	:= 400
													cMessage 	:= aRet[2] 

													DisarmTransaction()
													Break
												Else
													CB7->(DbGoTo(nRecCB7))
													CB9->(DbSetOrder(12))
													If !CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
														RecLock("CB7",.F.)
														CB7->CB7_STATUS := "0"
														CB7->CB7_STATPA := " "
														CB7->CB7_DTINIS := Ctod("  /  /  ")
														CB7->CB7_HRINIS := "     "
														CB7->CB7_DTFIMS := Ctod("  /  /  ")
														CB7->CB7_HRFIMS := "     "
														CB7->CB7_CODOPE := Space(TamSX3("CB7_CODOPE")[1])
														CB7->(MsUnlock())
													EndIf

													oJsonSep["products"] := aJProdSep
													aJProdSep := {}
												Endif
											Else
												cResponse := ''
												nStatusCode	:= 400
												cMessage 	:= STR0038 //"Erro ao desfazer separação"
											Endif
										End Transaction
									Else
										lRet 		:= .F.
										nStatusCode	:= 400
										cMessage 	:= STR0039 //"Dados do estorno da separacao nao enviados..."
									Endif
								Else
									lRet 		:= .F.
									nStatusCode	:= 400
									cMessage 	:= STR0040 //"Separacao nao iniciada..."
								Endif
							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0041 //"Separacao nao é do tipo SA..."
							EndIf
						Endif
					Else
						lRet 		:= .F.
						nStatusCode	:= 400
						cMessage 	:= STR0017 //"Separacao nao encontrada..."
					Endif
				EndIf
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0005 //"Dados para atualizacao nao foram informados..."
			EndIf
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005  //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf

If lRet
	cResponse := FwJsonSerialize( oJsonSep )
    Self:SetResponse( cResponse )
Else
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
If ValType(oJsonSep) == "J"
	FreeObj(oJsonSep)
	oJsonSep := Nil
Endif
Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} SepTpAmb
 Função que valida tipo de separação e ambiente

@return logical

@author	 	Leonardo Kichitaro
@since		17/02/2025
@version	12.1.2410
/*/
//-------------------------------------------------------------------
Static Function SepTpAmb(oJSepara, nStatusCode, cMessage, lRet)

	Local lVldSep := .F.

	nStatusCode := 400
	cMessage	:= STR0037 //"Não é permitido separar ordem para SA com o ambiente desatualizado."
	lRet		:= .F.

	//Carrega variável static '__lSaOrdSep'
	FnVlSaOs()

	If oJSepara:Status == '1' .Or. oJSepara:Type <> "4" .Or. (__lSaOrdSep .And. oJSepara:Type == "4")
		nStatusCode := 500
		cMessage	:= ""
		lRet		:= .T.
		lVldSep		:= .T.
	EndIf

Return lVldSep

/*/{Protheus.doc} retorna itens da nota/pre nota
 Altera o Status da separacao ou finaliza no protheus

@param	tabela Temp
@author	 	andre.maximo
@since		25/09/2019
@version	12.1.25
/*/

Static Function GetItNota(cTab)
	Local cQuery := ""
	Local oExec  := NIL

	cQuery := " SELECT D1_ITEM " 
	cQuery += " 	,D1_COD " 
	cQuery += " 	,B1_CODBAR " 
	cQuery += " 	,D1_QUANT " 
	cQuery += " 	,D1_LOTECTL " 
	cQuery += " 	,D1_DTVALID " 
	cQuery += " FROM " + RetSqlName("SD1") + " SD1 " 
	cQuery += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = ? " 
	cQuery += " 	AND SB1.B1_COD = SD1.D1_COD " 
	cQuery += " 	AND SB1.D_E_L_E_T_ = ? " 
	cQuery += " WHERE SD1.D1_FILIAL = ? " 
	cQuery += " 	AND SD1.D1_DOC = ? " 
	cQuery += " 	AND SD1.D1_SERIE = ? " 
	cQuery += " 	AND SD1.D1_FORNECE = ? " 
	cQuery += " 	AND SD1.D1_LOJA = ? " 
	cQuery += " 	AND SD1.D_E_L_E_T_ = ? " 

	oExec := saveQryMD5(cQuery)
	
	oExec:SetString(1, FWxFilial("SB1"))
	oExec:SetString(2, " ")
	oExec:SetString(3, FWxFilial("SD1"))
	oExec:SetString(4, SF1->F1_DOC)
	oExec:SetString(5, SF1->F1_SERIE)
	oExec:SetString(6, SF1->F1_FORNECE)
	oExec:SetString(7, SF1->F1_LOJA)
	oExec:SetString(8, " ")

	oExec:OpenAlias(cTab)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de produtos a endereçar.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Page         , numerico, Número da página para retorno dos dados
        PageSize	 , numerico, Quantidade de registros por página

@return cResponse	, Array, JSON com os endereçamentos disponíveis

@author	 	Marcia Junko
@since		15/03/2021
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET toAddressDetail WSRECEIVE SearchKey, Page, PageSize, Sku, Warehouse, Document, Serie, Sequence, Supplier, Store WSSERVICE ACDMOB
    Local oResponse     := JsonObject():New() 
	Local cJson         := ""
    Local lRet          := .F.

    Default Self:searchKey  := ""
    Default Self:page       := 1
    Default Self:pageSize   := 10
	Default Self:Sku    	:= ""
	Default Self:Warehouse  := ""
	Default Self:Document   := ""
	Default Self:Serie    	:= ""
	Default Self:Sequence   := ""
	Default Self:Supplier   := ""
	Default Self:Store   	:= ""


    
	lRet := DTLstToAddress( @oResponse, @Self )
    
    cJson := oResponse:TOJSON()

	oResponse := nil

    ::SetResponse( cJson )

	FreeObj( oResponse )
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} GET/ACDMOB
Retorna uma lista de produtos a endereçar.

@param  SearchKey    , caracter, Chave de Pesquisa para ser considerado na consulta.
        Page         , numerico, Número da página para retorno dos dados
        PageSize	 , numerico, Quantidade de registros por página

@return cResponse	, Array, JSON com os endereçamentos disponíveis

@author	 	Marcia Junko
@since		15/03/2021
@version	12.1.17
/*/
//-------------------------------------------------------------------
WSMETHOD GET docToAddr WSRECEIVE SearchKey, Page, PageSize WSSERVICE ACDMOB
    Local oResponse     := JsonObject():New() 
	Local cJson         := ""
    Local lRet          := .F.

    Default Self:searchKey	:= ""
    Default Self:page		:= 1
    Default Self:pageSize	:= 10

	cBody := ::GetContent()
    
	lRet := GRLstToAddress( @oResponse, @Self )
    
    cJson := oResponse:TOJSON()

	oResponse := nil

    ::SetResponse( cJson )

	FreeObj( oResponse )
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} DTLstToAddress
Função responsável pela busca das informações de pedidos de compras

@param @oResponse, object, Objeto que armazena os registros a apresentar.
@param @oSelf, object, Objeto principal do WS

@return boolean, .T. se encontrou registros e .F. se ocorreu erro.
@author Marcia Junko
@since 15/03/2021
/*/
//----------------------------------------------------------------------------------
Static Function DTLstToAddress( oResponse, oSelf)
	Local aSvAlias		:= GetArea()
	Local aJResult		:= {}
	Local cQuery		:= ''
	Local cWhere		:= ''
	Local cTmpAlias     := GetnextAlias()
	Local cMessage      := STR0001 //'Erro Interno'
	Local cCodOpe   	:= CBRetOpe()
	Local nStatusCode	:= 500
	Local nRecord       := 0
	Local nRecStart		:= 0  // Define a quantidade de registros ja retornados
	Local nRecFinish	:= 0  // Define o registro máximo à retornar
	Local nLenResult	:= 0
	Local lHasNext		:= .F.
	Local lRet          := .T.
	Local oJResult		:= NIL
	Local oMessages		:= NIL

	If Empty( cCodOpe )
		nStatusCode := 403
		cMessage	:= STR0011 //'Usuario nao cadastrado como conferente'
		lRet		:= .F.
	EndIf

	If lRet
		oMessages  := JsonObject():New()

		nRecStart := ( ( oSelf:Page - 1 ) * oSelf:PageSize ) + 1

		nRecFinish := ( nRecStart + oSelf:PageSize ) - 1

		If !Empty( oSelf:searchKey )
			cWhere += " AND ( B1_COD LIKE '%" + oSelf:searchKey + "%' OR B1_CODBAR = '" + oSelf:searchKey + "')"
		EndIf

		If !Empty( oSelf:Document )
			cWhere += " AND ( DA_DOC = '" + oSelf:Document + "' )"
		EndIf

		If !Empty( oSelf:Serie )
			cWhere += " AND ( DA_SERIE = '" + oSelf:Serie + "' )"
		EndIf

		If !Empty( oSelf:Sequence )
			cWhere += " AND ( DA_NUMSEQ = '" + oSelf:Sequence + "' )"
		EndIf

		If !Empty( oSelf:Supplier )
			cWhere += " AND ( DA_CLIFOR = '" + oSelf:Supplier + "' )"
		EndIf

		If !Empty( oSelf:Store )
			cWhere += " AND ( DA_LOJA = '" + oSelf:Store + "' )"
		EndIf

		If !Empty( oSelf:Warehouse )
			cWhere += " AND ( DA_LOCAL = '" + oSelf:Warehouse + "' )"
		EndIf

		cQuery := "SELECT "
		cQuery += "	DA_PRODUTO, "
		cQuery += "	B1_DESC, "
		cQuery += "	DA_QTDORI, "
		cQuery += "	DA_SALDO, "
		cQuery += "	DA_DATA, "
		cQuery += "	DA_LOTECTL, "
		cQuery += "	DA_NUMLOTE, "
		cQuery += "	NNR_DESCRI, "
		cQuery += "	DA_LOCAL, " 
		cQuery += " DA_DOC, "
		cQuery += " DA_SERIE, "
		cQuery += " DA_CLIFOR, "
		cQuery += " DA_LOJA, "
		cQuery += " DA_TIPONF, "
		cQuery += " DA_ORIGEM, "
		cQuery += " DA_NUMSEQ FROM "
		cQuery += " 	( " 
		
		cQuery += " 		SELECT ROW_NUMBER() OVER (ORDER BY DA_PRODUTO, "

		cQuery += "			DA_LOCAL, DA_NUMSEQ) AS LINHA, "
		
		cQuery += "	 		DA_PRODUTO, "
		cQuery += "	 		DA_QTDORI, "
		cQuery += "	 		B1_DESC, "
		cQuery += "	 		DA_SALDO, "
		cQuery += "	 		DA_DATA, "
		cQuery += "	 		DA_LOTECTL, "
		cQuery += "	 		DA_NUMLOTE, "
		cQuery += "	 		NNR_DESCRI, "
		cQuery += "	 		DA_LOCAL, " 
		cQuery += "	 		DA_DOC, "
		cQuery += "	 		DA_SERIE, "
		cQuery += "	 		DA_CLIFOR, "
		cQuery += "	 		DA_LOJA, "
		cQuery += "	 		DA_TIPONF, "
		cQuery += "	 		DA_ORIGEM, "
		cQuery += "	 		DA_NUMSEQ " 
		cQuery += "	 	FROM " + RetSQLName( "SDA" ) + " SDA "
		cQuery += "	 	INNER JOIN " + RetSQLName( "SB1" ) + " SB1 ON B1_COD = DA_PRODUTO AND B1_FILIAL = '"+XFILIAL("SB1")+"' AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "	 	INNER JOIN " + RetSQLName( "NNR" ) + " NNR ON NNR_CODIGO = DA_LOCAL AND NNR_FILIAL = '"+XFILIAL("NNR")+"' AND NNR.D_E_L_E_T_ = ' ' "
		cQuery += " 	WHERE DA_FILIAL = '" + xFilial( "SDA" ) + "' " 
		cQuery += " 		AND DA_SALDO > 0 "
		
		cQuery += IIF( !Empty( cWhere ), cWhere, '' ) + " " 
		
		cQuery += " 	AND SDA.D_E_L_E_T_ = ' ' " 

		cQuery += " ) TABLE_TEMP "

		cQuery += " WHERE LINHA BETWEEN " + Alltrim( Str( nRecStart ) ) + " AND " + Alltrim( Str( nRecFinish ) )

		cQuery := ChangeQuery( cQuery )
		MPSysOpenQuery( cQuery, cTmpAlias )

		If ( cTmpAlias )->( !EOF() )
			nRecord := Contar( cTmpAlias, "!Eof()" )
		
			( cTmpAlias )->( DBGoTop() )

			oJResult :=  JsonObject():New()

			While ( cTmpAlias )->( !Eof() )
				aAdd( aJResult,  JsonObject():New() )
				nLenResult := Len( aJResult )

				aJResult[ nLenResult ][ "product" ]			 := ( cTmpAlias )->DA_PRODUTO
				aJResult[ nLenResult ][ "productName" ]		 := AllTrim(( cTmpAlias )->B1_DESC)
				aJResult[ nLenResult ][ "originalAmount" ]	 := ( cTmpAlias )->DA_QTDORI 
				aJResult[ nLenResult ][ "balance" ]			 := ( cTmpAlias )->DA_SALDO 

				aJResult[ nLenResult ][ "date" ] 			 := ( cTmpAlias )->DA_DATA 
				aJResult[ nLenResult ][ "lot" ] 			 := ( cTmpAlias )->DA_LOTECTL
				aJResult[ nLenResult ][ "sublot" ] 			 := ( cTmpAlias )->DA_NUMLOTE
				aJResult[ nLenResult ][ "warehouse" ]		 := AllTrim(( cTmpAlias )->DA_LOCAL) +"-"+ UPPER(AllTrim(( cTmpAlias )->NNR_DESCRI))
				aJResult[ nLenResult ][ "document" ]		 := ( cTmpAlias )->DA_DOC
				aJResult[ nLenResult ][ "invoiceSerie" ]	 := ( cTmpAlias )->DA_SERIE
				aJResult[ nLenResult ][ "customerCode" ]	 := ( cTmpAlias )->DA_CLIFOR
				aJResult[ nLenResult ][ "customerUnit" ]	 := ( cTmpAlias )->DA_LOJA
				aJResult[ nLenResult ][ "invoiceType" ]		 := ( cTmpAlias )->DA_TIPONF
				aJResult[ nLenResult ][ "source" ]			 := ( cTmpAlias )->DA_ORIGEM
				aJResult[ nLenResult ][ "sequencialNumber" ] := ( cTmpAlias )->DA_NUMSEQ

				( cTmpAlias )->( DBSkip() )
			End

			If nRecord < oSelf:PageSize
				lHasNext := .F.
			else
				lHasNext := .T.
			EndIf
		Else
			oResponse :=  JsonObject():New()
			oResponse[ "address" ] := aJResult
			oResponse[ "hasNext" ] := lHasNext
		EndIf

		( cTmpAlias )->( DBCloseArea() )
	EndIf

	If lRet
		oResponse["address"]	:= aClone( aJResult )
		oResponse["hasNext"] 	:= lHasNext
	Else
		SetRestFault( nStatusCode, EncodeUTF8( cMessage ) )
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aJResult )
	FreeObj( oJResult )
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GRLstToAddress
Função responsável pela busca das informações de pedidos de compras

@param @oResponse, object, Objeto que armazena os registros a apresentar.
@param @oSelf, object, Objeto principal do WS

@return boolean, .T. se encontrou registros e .F. se ocorreu erro.
@author Marcia Junko
@since 15/03/2021
/*/
//----------------------------------------------------------------------------------
Static Function GRLstToAddress( oResponse, oSelf)
	Local aSvAlias		:= GetArea()
	Local aJResult		:= {}
	Local cQuery		:= ''
	Local cWhere		:= ''
	Local cTmpAlias     := GetnextAlias()
	Local cMessage      := STR0001 //'Erro Interno'
	Local cCodOpe   	:= CBRetOpe()
	Local nStatusCode	:= 500
	Local nRecord       := 0
	Local nRecStart		:= 0  // Define a quantidade de registros ja retornados
	Local nRecFinish	:= 0  // Define o registro máximo à retornar
	Local nLenResult	:= 0
	Local lHasNext		:= .F.
	Local lRet          := .T.
	Local oJResult		:= NIL
	Local oMessages		:= NIL

	If Empty( cCodOpe )
		nStatusCode := 403
		cMessage	:= STR0011 //'Usuario nao cadastrado como conferente'
		lRet		:= .F.
	EndIf

	If lRet
		oMessages  := JsonObject():New()

		nRecStart := ( ( oSelf:Page - 1 ) * oSelf:PageSize ) + 1

		nRecFinish := ( nRecStart + oSelf:PageSize ) - 1

		If !Empty( oSelf:searchKey )
			cWhere += " AND (( DA_DOC LIKE '%" + oSelf:searchKey + "%' ) OR ( DA_CLIFOR LIKE '%" + oSelf:searchKey + "%' ))"
		EndIf

		cQuery := "SELECT "
		cQuery += "	DA_DATA, "
		cQuery += "	DA_LOTECTL, "
		cQuery += "	DA_NUMLOTE, "
		cQuery += " DA_DOC, "
		cQuery += " DA_SERIE, "
		cQuery += " DA_CLIFOR, "
		cQuery += " DA_LOJA, "
		cQuery += " DA_TIPONF, "
		cQuery += " DA_ORIGEM FROM "
		cQuery += " 	( " 
		
		cQuery += " 		SELECT ROW_NUMBER() OVER (ORDER BY "

		cQuery += "			DA_DATA) AS LINHA, "
		
		cQuery += "	 		DA_DATA, "
		cQuery += "	 		DA_LOTECTL, "
		cQuery += "	 		DA_NUMLOTE, "
		cQuery += "	 		DA_DOC, "
		cQuery += "	 		DA_SERIE, "
		cQuery += "	 		DA_CLIFOR, "
		cQuery += "	 		DA_LOJA, "
		cQuery += "	 		DA_TIPONF, "
		cQuery += "	 		DA_ORIGEM "
		cQuery += "	 	FROM " + RetSQLName( "SDA" ) + " SDA "
		cQuery += " 	WHERE DA_FILIAL = '" + xFilial( "SDA" ) + "' " 
		cQuery += " 		AND DA_SALDO > 0 "
		
		cQuery += IIF( !Empty( cWhere ), cWhere, '' ) + " " 
		
		cQuery += " 	AND SDA.D_E_L_E_T_ = ' ' "

		cQuery += "GROUP BY "
		cQuery += "	DA_DATA, "
		cQuery += "	DA_LOTECTL, "
		cQuery += "	DA_NUMLOTE, " 
		cQuery += " DA_DOC, "
		cQuery += " DA_SERIE, "
		cQuery += " DA_CLIFOR, "
		cQuery += " DA_LOJA, "
		cQuery += " DA_TIPONF, "
		cQuery += " DA_ORIGEM "

		cQuery += " ) TABLE_TEMP "

		cQuery += " WHERE LINHA BETWEEN " + Alltrim( Str( nRecStart ) ) + " AND " + Alltrim( Str( nRecFinish ) )

		cQuery := ChangeQuery( cQuery )
		MPSysOpenQuery( cQuery, cTmpAlias )

		If ( cTmpAlias )->( !EOF() )
			nRecord := Contar( cTmpAlias, "!Eof()" )
		
			( cTmpAlias )->( DBGoTop() )

			oJResult :=  JsonObject():New()

			While ( cTmpAlias )->( !Eof() )
				aAdd( aJResult,  JsonObject():New() )
				nLenResult := Len( aJResult )

				aJResult[ nLenResult ][ "date" ] 			 := ( cTmpAlias )->DA_DATA 
				aJResult[ nLenResult ][ "lot" ] 			 := ( cTmpAlias )->DA_LOTECTL
				aJResult[ nLenResult ][ "sublot" ] 			 := ( cTmpAlias )->DA_NUMLOTE
				aJResult[ nLenResult ][ "warehouse" ]		 := ""
				aJResult[ nLenResult ][ "document" ]		 := ( cTmpAlias )->DA_DOC
				aJResult[ nLenResult ][ "invoiceSerie" ]	 := ( cTmpAlias )->DA_SERIE
				aJResult[ nLenResult ][ "customerCode" ]	 := ( cTmpAlias )->DA_CLIFOR

				If AllTrim(( cTmpAlias )->DA_TIPONF) $ "NB "
					aJResult[ nLenResult ][ "customerName" ]	 := AllTrim(Posicione("SA2",1,XFILIAL("SA2")+( cTmpAlias )->DA_CLIFOR+( cTmpAlias )->DA_LOJA, "A2_NOME"))
				Else
					aJResult[ nLenResult ][ "customerName" ]	 := AllTrim(Posicione("SA1",1,XFILIAL("SA1")+( cTmpAlias )->DA_CLIFOR+( cTmpAlias )->DA_LOJA, "A1_NOME"))
				EndIf
				aJResult[ nLenResult ][ "customerUnit" ]	 := ( cTmpAlias )->DA_LOJA
				aJResult[ nLenResult ][ "invoiceType" ]		 := ( cTmpAlias )->DA_TIPONF

				If AllTrim((cTmpAlias)->DA_ORIGEM) == 'SD5'
					cOrigem := "REQ. LOTE"
				ElseIf  AllTrim((cTmpAlias)->DA_ORIGEM) == 'SD1'
					cOrigem := "DOC. ENTRADA"
				ElseIf  AllTrim((cTmpAlias)->DA_ORIGEM) == 'SD3'
					cOrigem := "MOV. INTERNA"
				ElseIf  AllTrim((cTmpAlias)->DA_ORIGEM) == 'SB9'
					cOrigem := "SLD. INICIAL"
				Else
					cOrigem := (cTmpAlias)->DA_ORIGEM
				EndIf

				aJResult[ nLenResult ][ "source" ]			 := cOrigem
				aJResult[ nLenResult ][ "sequencialNumber" ] := ""

				( cTmpAlias )->( DBSkip() )
			End

			If nRecord < oSelf:PageSize
				lHasNext := .F.
			else
				lHasNext := .T.
			EndIf
		Else
			oResponse :=  JsonObject():New()
			oResponse[ "address" ] := aJResult
			oResponse[ "hasNext" ] := lHasNext
		EndIf

		( cTmpAlias )->( DBCloseArea() )
	EndIf

	If lRet
		oResponse["address"]	:= aClone( aJResult )
		oResponse["hasNext"] 	:= lHasNext
	Else
		SetRestFault( nStatusCode, EncodeUTF8( cMessage ) )
	EndIf

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aJResult )
	FreeObj( oJResult )
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} POST  Address / ACDMOB
Serviço de inclusão de endereçamento de produto.

@return boolean, identifica se o endereçamento foi gerado.
@author	Marcia Junko
@since	15/03/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST ToAddress WSSERVICE ACDMOB
    Local cBody     As Character
    Local cJson     As Character
    Local lRet      As Logical
    Local oToAddress As Object

    cBody 	   := ::GetContent()
    oToAddress  := JsonObject():New()

    lRet := NewAddress( @oToAddress, cBody )

    If lRet 
		cJson := oToAddress:ToJson()
		::SetResponse( cJson )
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NewAddress
Cria o endereçamento do produto

@param oToAddress, object, Objeto da resposta
@param cBody, caracter, corpo da requisição

@return boolean, identifica se o endereçamento foi gerado.
@author	Marcia Junko
@since	15/03/2021
/*/
//-------------------------------------------------------------------
Static Function NewAddress( oToAddress, cBody )
	Local aHeader 		:= {}
	Local aItem   		:= {}
	Local aAddress		:= {}
	Local aDiverg		:= {}
	Local cCatch		:= ''
	Local cProduct 		:= ''
	Local cWarehouse	:= ''
	Local cAddress		:= ''
	Local cSeqNumber	:= ''
	Local cMessage		:= ''
	Local cPath     	:= ''
	Local cFile     	:= ''
	Local cIdent 		:= ''
	Local cItem			:= ''
	Local nAmount		:= 0
	Local nCodeSize		:= 0
	Local nWareSize		:= 0
	Local nSeqSize		:= 0
	Local nStatusCode	:= 0
	Local lRet			:= .T.
	Local oJsonTmp		:= NIL
	Local oMessages		:= NIL

    Private	lMsErroAuto := .F.

	oJsonTmp := JsonObject():New()
	oMessages := JsonObject():New()
	If !Empty( cBody )
		cCatch   := oJsonTmp:FromJSON( cBody )
		If cCatch == Nil
			SDA->( DbSetOrder(1) )  //DA_FILIAL + DA_PRODUTO + DA_LOCAL + DA_NUMSEQ + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA -- SALDO A DISTRIBUIR

			cProduct := oJsonTmp[ "productCode" ]
			cWarehouse := oJsonTmp[ "warehouse" ]
			cAddress := oJsonTmp[ "address" ]
			cSeqNumber := oJsonTmp[ "sequenceNumber" ]
			cItem := NextSDBItem( cProduct, cWarehouse, cSeqNumber )
			nAmount := oJsonTmp[ "amount" ]

			nCodeSize	:= TamSX3( "DA_PRODUTO" )[1]
			nWareSize	:= TamSX3( "DA_LOCAL" )[1]
			nSeqSize	:= TamSX3( "DA_NUMSEQ" )[1]

			If ( SDA->( MSSeek( xFilial( "SDA" ) + Padr( cProduct, nCodeSize ) + Padr( cWarehouse, nWareSize ) + Padr( cSeqNumber, nSeqSize ) ) ) ) 
				aHeader := { { "DA_PRODUTO", cProduct, Nil }, ;	  
							{ "DA_NUMSEQ", cSeqNumber, Nil } }

				aItem := { { "DB_ITEM", cItem, Nil }, ;                   
						{ "DB_ESTORNO", " ", Nil }, ;                   
						{ "DB_LOCALIZ", cAddress, Nil }, ;                   
						{ "DB_DATA", dDataBase, Nil }, ;                   
						{ "DB_QUANT", nAmount, Nil } }       

				aadd( aAddress, aItem )

				MSExecAuto( { | x, y, z | MATA265( x, y, z ) }, aHeader, aAddress, 3 ) 

				If !lMsErroAuto
					oToAddress[ "productCode" ]	:= cProduct
					oToAddress[ "warehouse" ] := cWarehouse
					oToAddress[ "address" ]	:= cAddress
					oToAddress[ "sequenceNumber" ] := cSeqNumber
					oToAddress[ "item" ] := cItem
					oToAddress[ "amount" ] := nAmount
				Else
					lRet := .F.
					nStatusCode := 403
					cPath := GetSrvProfString( "StartPath", "" )
					cFile := NomeAutoLog()
					cMessage := MostraErro( cPath, cFile )	

					cIdent := SDA->( DA_FILIAL + DA_PRODUTO + DA_LOCAL + DA_NUMSEQ + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA )

					Aadd( aDiverg, {'D3V_ORIGEM', '5'} )
					Aadd( aDiverg, {'D3V_MOTIVO', '5' } )
					Aadd( aDiverg, {'D3V_IDENT', cIdent } )
					Aadd( aDiverg, {'D3V_INFO', cMessage } )

					ACDM020GRV( aDiverg )
				EndIf
			Else
				nStatusCode := 400
        		cMessage := STR0024 //"Solicitação de endereçamento não localizada."
				lRet := .F.
			EndIf
		Else
			nStatusCode := 400
			cMessage := cCatch 
			lRet := .F.
		EndIf
	Else
		nStatusCode := 400
		cMessage := STR0025 //"Dados para endereçamento não foram informados." 
		lRet := .F.
	EndIf

    If !lRet
		oMessages[ "errorCode" ] := nStatusCode
        oMessages[ "errorMessage" ] := EncodeUTF8( cMessage )
        oToAddress := oMessages
        SetRestFault( oMessages["errorCode"], oMessages["errorMessage"] )
    EndIf

	FWFreeArray( aHeader )
	FWFreeArray( aItem )
	FWFreeArray( aAddress )
	FWFreeArray( aDiverg )
	FreeObj( oJsonTmp )
	FreeObj( oMessages )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NextSDBItem
Retorna o próximo sequencial para endereçar o produto

@param cProduct, caracter, código do produto
@param cWarehouse, caracter, código do armazén
@param cNumSeq, caracter, número sequencial

@return caracter, sequencial do endereçamento
@author	Marcia Junko
@since	15/03/2021
/*/
//-------------------------------------------------------------------
Static Function NextSDBItem( cProduct, cWarehouse, cNumSeq ) 
    Local cQuery := ''
    Local cTmp := GetNextAlias()
    Local nItem := 0

    cQuery := "SELECT MAX(DB_ITEM) AS ITEM FROM " + RetSQLName( "SDB" ) + " SDB " + ;
        " WHERE DB_FILIAL = '" + xFilial( "SDB" ) + "' " + ;
            " AND DB_PRODUTO = '" + cProduct + "' " + ;
			" AND DB_LOCAL = '" + cWarehouse + "' " + ;
            " AND DB_NUMSEQ = '" + cNumSeq + "' " + ;
            " AND SDB.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmp )

    If ( cTmp )->( !EOF() )
        nItem := Val( ( cTmp )->ITEM )
    Endif

    nItem++

    ( cTmp )->( DbCloseArea() )
Return StrZero( nItem, 4 )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetStsInv
Retorna retorna o status da contagem verificando quantidade do
produto em estoque.

@param cCode, caracter, código do produto
@param cWarehouse, caracter, código do armazem
@param cBatch, caracter, código do lote
@param nQtd, numeric, quantidade

@return caracter, status da CBA
@author	Leonardo Kichitaro
@since	20/09/2021
/*/
//-------------------------------------------------------------------
Static Function GetStsInv(cCode, cWarehouse, cBatch, nQtd, cStatus)

Local cRet		:= ''
Local aAreaSB2	:= SB2->(GetArea())
Local aAreaSB8	:= SB8->(GetArea())

If Empty(cStatus) .Or. cStatus == '4'
	If !Empty(cBatch)
		SB8->(dbSetOrder(3))
		If SB8->(dbSeek(xFilial("SB8")+cCode+cWarehouse+cBatch))
			If SB8->B8_SALDO - SB8->B8_EMPENHO <> nQtd
				cRet := '3'
			Else
				cRet := '4'
			EndIf
		EndIf
	Else
		SB2->(dbSetOrder(1))
		If SB2->(dbSeek(xFilial("SB2")+cCode+cBatch))
			If SaldoSB2() <> nQtd
				cRet := '3'
			Else
				cRet := '4'
			EndIf
		EndIf
	EndIf
Else
	cRet := cStatus
EndIf

RestArea(aAreaSB2)
RestArea(aAreaSB8)

Return cRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetBarCode
Retorna código de barras das tabelas SB1, SLK e SA5

@param	cCodPrd, caracter, código do produto
@param	cCodBar, caracter, código de barras no cadastro de produtos
@param	cFornec, caracter, código fornecedor
@param	cLoja, caracter, código loja fornecedor
@author	miqueias.coelho
@since	18/01/2023
/*/
//----------------------------------------------------------------------------------

Static Function GetBarCode(cCodPrd, cCodBar, cFor,cLoj )
	Local aRet		:= {}
	Local aAreaSA5 	:= SA5->(GetArea())
	Local aAreaSB1 	:= SB1->(GetArea())
	Local aAreaSLK 	:= SLK->(GetArea())
	Local aArea		:= GetArea()
	Local lPesqSA5 	:= SuperGetMv("MV_CBSA5",.F.,.F.)
	Local lUtilSLK 	:= SuperGetMv("MV_MCDSLK",.F.,.F.)
	Local cQryAlias := ""
	Local oQry 		:= NIL
	Local nOrd		:= 1

	DEFAULT cCodBar := ""
	DEFAULT cFor 	:= ""
	DEFAULT cLoj 	:= ""

	If !Empty( cCodBar )
		Aadd( aRet, Alltrim( cCodBar ) )
	EndIF

	If lPesqSA5 .And. (!Empty(cFor) .And. !Empty(cLoj))
		oQry := GetHMQuery( 'SA5_Codbar' )
		oQry:SetString( nOrd++, xFilial( "SA5" ) )
		oQry:SetString( nOrd++, cCodPrd )
		oQry:SetString( nOrd++, cFor )
		oQry:SetString( nOrd++, cLoj )
		oQry:SetString( nOrd++, " " )

		cQryAlias := oQry:OpenAlias()

		While ( cQryAlias )->( !Eof() )	   
			If !Empty( ( cQryAlias )->A5_CODBAR ) 
				Aadd( aRet, Alltrim( ( cQryAlias )->A5_CODBAR ) )
			EndIf
			( cQryAlias )->( DBSkip() )
		End
		( cQryAlias )->( DBCloseArea() )
	EndIf

	If lUtilSLK
		nOrd := 1

		oQry := GetHMQuery( 'SLK_Codbar' )
		oQry:SetString( nOrd++, xFilial( "SLK" ) )
		oQry:SetString( nOrd++, cCodPrd )
		oQry:SetString( nOrd++, " " )
		
		cQryAlias := oQry:OpenAlias()
		
		While ( cQryAlias )->( !Eof() )	   
			If !Empty( ( cQryAlias )->LK_CODBAR ) 
				Aadd( aRet, Alltrim( ( cQryAlias )->LK_CODBAR ) )
			EndIf
			( cQryAlias )->( DBSkip() )
		End
		( cQryAlias )->( DBCloseArea() )
	EndIf

	If Empty( aRet )
		aRet := {Space(TamSX3("B1_CODBAR")[1])}
	EndIf

	If oQry <> NIL
		oQry:Destroy()
		oQry := NIL
	EndIf
	
	RestArea(aAreaSA5)
	RestArea(aAreaSB1)
	RestArea(aAreaSLK)
	RestArea(aArea)
Return aRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetHMQuery
Função responsável por verificar no cache se a query já foi executada anteriormente.
Caso ainda não tenha sido executada, cria a query base de acordo com a operação que
está sendo executada.

@param cOper, caracter, Identifica qual a query será retornada
	   aFilter, array, Filtro adicional para consulta

@return object, Objeto contendo a query a ser executada.
@author Marcia Junko
@since 08/08/2023
/*/
//----------------------------------------------------------------------------------
Static Function GetHMQuery( cOper, aFilter )
	Local oExec := Nil
    Local cTreatQuery := ''
    Local cName := ''
    Local cQuery := ''

	DEFAULT aFilter := {}

    If !Empty( cOper )
        cName := Alltrim( cOper ) + '_' + cEmpAnt
        If !HMGet( _oHMACDQry, cName, @cTreatQuery )
			cQuery := BuildQuery( cOper, aFilter )
            If !Empty( cQuery )
				cTreatQuery := ChangeQuery( cQuery )

                HMSet( _oHMACDQry, cName, cTreatQuery )
            EndIf
        EndIf

        If !Empty( cTreatQuery )
            oExec := FWExecStatement():New( cTreatQuery )
        EndIf
    EndIf
Return oExec


//----------------------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Função responsável por gerar a query base de acordo com a operação.

@param cOper, caracter, Identifica qual a query será retornada
	   aFilter, array, Filtro adicional para consulta

@return caracter, Query base montada de acordo com a operação
@author Marcia Junko
@since 08/08/2023
/*/
//----------------------------------------------------------------------------------
Static Function BuildQuery( cOper, aFilter )
	Local cQuery := ""

	Default cOper := ""
	Default aFilter := {}

    If !Empty( cOper )
		Do Case 
			Case cOper == "SA5_Codbar"
				cQuery := "SELECT A5_CODBAR FROM " + RetSQLName( "SA5" ) + " SA5 " + ;
					" WHERE A5_FILIAL = ? " + ;
					" AND A5_PRODUTO = ? " + ;
					" AND A5_FORNECE = ? " + ;
					" AND A5_LOJA = ? " + ;
					" AND D_E_L_E_T_ = ? "

			Case cOper = "SLK_Codbar"
				cQuery := "SELECT LK_CODBAR FROM " + RetSQLName( "SLK" ) + " SLK " + ;
					" WHERE LK_FILIAL = ? " + ;
					" AND LK_CODIGO = ? " + ;
					" AND SLK.D_E_L_E_T_ = ? "

			Case "SBF_Info" $ cOper 

				cQuery := " SELECT  "
				cQuery += "  BF_LOCAL "
				cQuery += " ,BF_LOCALIZ "
				cQuery += " ,BF_NUMSERI "
				cQuery += " ,BF_LOTECTL "
				cQuery += " ,BF_NUMLOTE "
				cQuery += " FROM "+RetSqlName("SBF")+" SBF "
				cQuery += " WHERE SBF.BF_FILIAL = ? "
				cQuery += " AND SBF.BF_PRODUTO = ? "

				If !Empty( aFilter[1] )					
					cQuery += " AND SBF.BF_NUMSERI = ? "
				EndIf

				cQuery += " AND SBF.D_E_L_E_T_ = ? "

			Case cOper = "VldNumSer"

				cQuery := " SELECT CB9.R_E_C_N_O_ REG "
				cQuery += " FROM "+RetSqlName("CB9")+" CB9"
				cQuery += " INNER JOIN "+RetSqlName("SC9")+" SC9 ON "
				cQuery += " SC9.C9_FILIAL = ? AND "
				cQuery += " SC9.C9_PEDIDO = CB9.CB9_PEDIDO AND "
				cQuery += " SC9.C9_PRODUTO = CB9.CB9_PROD AND "
				cQuery += " SC9.C9_LOCAL = CB9.CB9_LOCAL AND "
				cQuery += " SC9.C9_ORDSEP = CB9.CB9_ORDSEP AND "
				cQuery += " SC9.C9_REMITO = ? AND "
				cQuery += " SC9.D_E_L_E_T_ = ? "
				cQuery += " WHERE CB9.CB9_FILIAL = ? AND "
				cQuery += " CB9.CB9_PROD = ? AND "
				cQuery += " CB9.CB9_NUMSER = ? AND "
				cQuery += " CB9.D_E_L_E_T_ = ? "

			Case "CB4_Info" $ cOper

				cQuery := " SELECT CB4_CODDIV COD " 
				cQuery += " 	   ,CB4_DESCRI DESCRI " 
				cQuery += " 	   ,CB4_TIPO TIPO " 
				cQuery += " FROM " + RetSqlName("CB4") + " CB4 " 
				cQuery += " WHERE CB4.CB4_FILIAL = ? "

				If !Empty( aFilter[1] )					
					cQuery += " AND CB4.CB4_CODDIV = ? "
				EndIf

				cQuery += "AND CB4.D_E_L_E_T_ = ? "
				
		EndCase
	EndIf

Return cQuery

//---------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetProdInfo
	Função responsável por retornar os dados dos produtos

@param  cAlias,     caracter, Alias da tabela em movimentação
@param  cDadosProd, caracter, Informa o tipo de tabela de sincronização do produto
@param  @aJsonProd, array   , Array com as informações do produto
@param  @nEntJson,  caracter, Número de entrada do json
@param  cFornec,    caracter, Código do Fornecedor
@param  cLoja,      caracter, Loja do Fornecedor
@param  cSNumber,   caracter, Número de série do produto

/*/
//---------------------------------------------------------------------------------------------------------
Static Function SetProdInfo( cAlias, cDadosProd, aJsonProd, nEntJson, cFornec, cLoja, cSNumber  )
	Local aSvAlias   := GetArea()
	Local oJsonLot   := NIL
	Local aRet       := {}
	Local aSerNum    := {}
	Local lValSer    := .T.
	
	Default cFornec  := ""
	Default cLoja    := ""
	Default cSNumber := ""

	nEntJson++
	aAdd( aJsonProd,  JsonObject():New() )

	aRet := GetBarCode(( cAlias )->PROD, ( cAlias )->CODBAR, cFornec, cLoja ) // Retorna array com os códigos de barras do produto
	If Len(aRet) <= 1
		aRet := aRet[1]
	EndIf
	aJsonProd[ nEntJson ][ "code" ]			:= ( cAlias )->PROD
	aJsonProd[ nEntJson ][ "barcode" ]		:= aRet
	aJsonProd[ nEntJson ][ "description" ]	:= EncodeUTF8(  AllTrim( ( cAlias )->DESCRI) )
	If cDadosProd <> "SBZ"

		If !Empty(cSNumber)
			// validar se o número de série enviado na busca está disponível em estoque para reserva
			lValSer := VldNumSeri(( cAlias )->PROD, cSNumber  )
		EndIf

		// Se estiver disponível para leitura, retorna as informações da tabela SBF da serial
		aSerNum := If(lValSer, GetNumSer(( cAlias )->PROD, ALLTRIM( cSNumber ) ), {})
		aJsonProd[ nEntJson ][ "address" ]	:= If( AllTrim( ( cAlias )->LOCALIZ ) = 'S', .T., .F. )
		aJsonProd[ nEntJson ][ "serials" ]  := aSerNum 
	Else
		aJsonProd[ nEntJson ][ "address" ]	:= If( AllTrim( If( !EMPTY( ( cAlias )->LOCALIZZ ), ( cAlias )->LOCALIZZ, ( cAlias )->LOCALIZ ) ) = 'S', .T., .F. )
	EndIf
	aJsonProd[ nEntJson ][ "batch" ] 		:= AllTrim( ( cAlias )->RASTRO ) // S=sublote,L=lote,N= não controla
	aJsonProd[ nEntJson ][ "batchs" ] 		:= {}

	If ( ( !Empty( ( cAlias )->RASTRO ) .And. AllTrim( ( cAlias )->RASTRO ) <> 'N' ) .And. !Empty( ( cAlias )->ARMAZEM ) )
		oJsonLot := JsonObject():New()
		oJsonLot[ "warehouse" ]	:= ( cAlias )->ARMAZEM
		oJsonLot[ "batch" ]		:= ( cAlias )->LOTE

		aAdd( aJsonProd[ nEntJson ][ "batchs" ], oJsonLot )
	EndIf

	aJsonProd[ nEntJson ][ "unitMeasurement" ]	:= ( cAlias )->UNID
	aJsonProd[ nEntJson ][ "unitDescription" ]	:= ( cAlias )->UNIDESC

	RestArea( aSvAlias ) 
	FWFreeArray( aSvAlias ) 
Return 

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetNumSer
Função responsável por retornar os dados de armazém, localização e número de série da SBF.

@param cSearch, caracter, Identifica o produto para a consulta
@param cSearchSNumber, caracter, Identifica o Serial Number para a consulta

@return Array, objeto com resultados de consulta
@author Duvan Hernandez
@since 15/01/2024
/*/
//----------------------------------------------------------------------------------

Static Function GetNumSer(cSearch,cSearchSNumber)
Local aSvAlias 	  := GetArea()
Local cQryAlias	  := ""
Local aJsonSer	  := {}
Local oJsonQry    := NIL
Local oQry		  := NIL
Local nOrd		  := 1

Default cSearch   := ''
Default cSearchSNumber	:= ''

If !Empty( cSearch )

	oQry := GetHMQuery( 'SBF_Info' + Iif( !Empty(cSearchSNumber), '_SNumber', ''), {cSearchSNumber}) 

	If oQry <> NIL
		oQry:SetString(nOrd++, cFilSBF)
		oQry:SetString(nOrd++, cSearch)

		If !Empty(cSearchSNumber)
			oQry:SetString(nOrd++, cSearchSNumber)
		EndIf

		oQry:SetString(nOrd++, " ") 

	EndIf

	cQryAlias := oQry:OpenAlias()

	While ( cQryAlias )->( !Eof() )	
 
		oJsonQry := JsonObject():New()
		oJsonQry[ "warehouse" ]	:= Alltrim( ( cQryAlias )->BF_LOCAL )
		oJsonQry[ "localiz" ]	:= Alltrim( ( cQryAlias )->BF_LOCALIZ )
		oJsonQry[ "serial" ]	:= Alltrim( ( cQryAlias )->BF_NUMSERI )
		oJsonQry[ "batch" ]		:= Alltrim( ( cQryAlias )->BF_LOTECTL )
		oJsonQry[ "sublot" ]	:= Alltrim( ( cQryAlias )->BF_NUMLOTE )
		aAdd( aJsonSer, oJsonQry )

		( cQryAlias )->( DBSkip() )
	End
	( cQryAlias )->( DBCloseArea() )
	

EndIF

If oQry <> NIL
	oQry:Destroy()
	oQry := NIL
EndIf

RestArea( aSvAlias )
FWFreeArray( aSvAlias )
FreeObj(oQry)
FreeObj(oJsonQry)

Return aJsonSer

//----------------------------------------------------------------------------------
/*/{Protheus.doc} VldNumSeri
Função responsável por validar se o serial lido não pertence a outra ordem de separação

@param cProd, caracter, Identifica o produto para a consulta
@param cNumSer, caracter, Identifica o Serial Number para a consulta

@return Bolean, Valide se o número de série não foi lido
@author Duvan Hernandez
@since 15/01/2024
/*/
//----------------------------------------------------------------------------------
Static Function VldNumSeri(cProd, cNumSer)
	Local aSvAlias 	:= GetArea()
	Local aSvSC9   	:= SC9->( GetArea() )
	Local aSvCB9   	:= CB9->( GetArea() )
	Local lRet 		:= .T.
	Local cQryvld   := ""
	Local cSubNSer	:= SuperGetMV("MV_SUBNSER",.F.,'1')
	Local oQry		:= Nil
	Local nOrd		:= 1

	If !Empty(Alltrim(cNumSer)) .AND. !Empty(Alltrim(cProd)) .AND. cSubNSer $ '2|3' 

		oQry := GetHMQuery( 'VldNumSer')

		If oQry <> NIL

			oQry:SetString(nOrd++, xFilial("SC9"))
			oQry:SetString(nOrd++," ") 
			oQry:SetString(nOrd++," ") 
			oQry:SetString(nOrd++, xFilial("CB9"))
			oQry:SetString(nOrd++,cProd)
			oQry:SetString(nOrd++,cNumSer) 
			oQry:SetString(nOrd++," ") 

		EndIf
		cQryvld := oQry:OpenAlias()

		If (cQryvld)->(!Eof()) .AND. (cQryvld)->REG > 0
			lRet := .F.
		EndIf
		( cQryvld )->( DBCloseArea() )
		
	EndIf
	
	If oQry <> NIL
		oQry:Destroy()
		oQry := NIL
	EndIf
	
	RestArea( aSvCB9 )
	RestArea( aSvSC9 )
	RestArea( aSvAlias )
	FWFreeArray( aSvCB9 )
	FWFreeArray( aSvSC9 )
	FWFreeArray( aSvAlias )
Return lRet
 


//-------------------------------------------------------------------------
/* {protheus.doc} GET  Divergences / ACDMOB
retorna as divergências criadas no sistema

@param SearchKey, caracter, filtro de busqueda
	   Status, caracter	 , satus
	   page, character	 , pagina inicial
	   PageSize, caracter , paginas maximas

@Return lRet , validação de processo booleano
@Author  Duvan Arley Hernandez Niño
@Since	15/01/2024
*/
//-------------------------------------------------------------------------
WSMETHOD GET Divergences WSRECEIVE SearchKey, Status, Page, PageSize WSSERVICE ACDMOB

Local cAlias            := GetnextAlias()
Local aSvAlias     		:= GetArea()
Local cResponse         := ''
Local oJsonDive			:= JsonObject():New()
Local aJsonDive		  	:= {}
Local nStatusCode       := 500
Local cMessage          := STR0001 //'Erro Interno'
Local lRet              := .T.
Local nCount            := 0
Local nRecord           := 0
Local nReg				:= 0
Local nEntJson          := 0
Local nStart            := 0
Local cCodOpe   		:= CBRetOpe()
Local lHasNext			:= .F.
Local oJsonLot			:= NIL
Default Self:SearchKey  := ''
Default Self:Status		:= '1'
Default Self:Page       := 1
Default Self:PageSize   := 100


Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0011 //'Usuario nao cadastrado como separador'
	 lRet			   := .F.
EndIf

If lRet
	If(Positivo(Self:Page) .And. Positivo(Self:PageSize))

		cAlias := GetDiver(Self:SearchKey,cAlias, @nRecord) 
   
		If  ( cAlias )->( !Eof() )	
        	// nStart -> primeiro registro da pagina
			// nReg -> numero de registros do inicio da pagina ao fim do arquivo
			If Self:Page > 1
	            nStart := ( (Self:Page-1) * Self:PageSize) +1
				nReg := nRecord - nStart + 1
			Else
				nReg := nRecord
	        EndIf

			// Valida a exitencia de mais paginas
			If nReg  > Self:PageSize
				lHasNext := .T. 
			Else
				lHasNext := .F.
			EndIf

			oJsonDive 			:=  JsonObject():New()

	        While  ( cAlias )->( !Eof() )	
	            nCount++

	            If (nCount >= nStart)
					nEntJson++
					aAdd( aJsonDive,  JsonObject():New() )

					aJsonDive[ nEntJson ][ "code" ]			:= ( cAlias )->COD
					aJsonDive[ nEntJson ][ "description" ]	:= EncodeUTF8(  AllTrim( ( cAlias )->DESCRI) )
					aJsonDive[ nEntJson ][ "type" ] 		:= AllTrim( ( cAlias )->TIPO )
					
					If Len(aJsonDive) >= Self:pageSize
						Exit
					EndIf

	            EndIf

				(cAlias)->(DbSkip())

	        EndDo

			(cAlias)->(dbCloseArea())

	    Else
	    	oJsonDive                := JsonObject():New()
	    	oJsonDive["divergences"] := aJsonDive
	    	oJsonDive["hasNext"]     := lHasNext
	    EndIf

	Else
	    lRet 		:= .F.
	    nStatusCode := 400
	    cMessage 	:= STR0003 //"Parametros de paginacao com valores Negativo..."
	EndIf
Endif

If lRet
	oJsonDive["divergences"]	:= aJsonDive
	oJsonDive["hasNext"] 		:= lHasNext
	cResponse := oJsonDive:ToJson()
    Self:SetResponse(cResponse)
Else
    SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

RestArea(aSvAlias)
FWFreeArray( aJsonDive )
FWFreeArray( aSvAlias )
FreeObj( oJsonDive )
FreeObj( oJsonLot )
oJsonDive := Nil
oJsonLot := Nil

Return (lRet)


//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetDiver
Função responsável por gerar a query base de acordo com a operação.

@param cSearch, caracter, Identifica o produto para a consulta
@param cSearchSNumber, caracter, Identifica o Serial Number para a consulta

@return caracter, matriz de resultados
@author Duvan Hernandez
@since 15/01/2024
/*/
//----------------------------------------------------------------------------------

Static Function GetDiver(cSearch,cQryAlias, nRecord)

	Local aSvAlias 	  := GetArea()
	Local oQry		  := Nil
	Local cQryCount	  := ""
	Local aBindValue  := {}
	Local oCount	  := NIL

	Default cSearch   := ''

	oQry := GetHMQuery( 'CB4_Info' + Iif( !Empty(cSearch), '_CODDIV', ''), {cSearch})
	
	aadd(aBindValue, xFilial("CB4"))

	If !Empty(cSearch)
		aadd(aBindValue, cSearch)
	EndIf

	aadd(aBindValue, " ")

	oQry:setParams(aBindValue)

	cQryAlias :=  oQry:OpenAlias()

	cQryCount := oQry:cBaseQuery
	cQryCount := "SELECT COUNT(CB4_CODDIV) QTDREG " + SubStr( cQryCount, at("FROM", Upper(cQryCount)) )
	cQryCount := ChangeQuery(cQryCount)
	oCount    := FwExecStatement():New(cQryCount)
	oCount:setParams(aBindValue)
	nRecord := oCount:ExecScalar("QTDREG")

	RestArea( aSvAlias )
	FWFreeArray( aSvAlias )
	
	If oQry <> NIL
		oQry:Destroy()
		oQry := NIL
	EndIf

	If oCount <> NIL
		oCount:Destroy()
		oCount := NIL
	EndIf

Return cQryAlias

//-------------------------------------------------------------------------
/* {protheus.doc} PUT  Divergences / ACDMOB
Alterar o estado do item de separação no Protheus

@param Code, caracter, code separatión
	   array, array	 , com dados para mudança do status

@Return lRet , validação de processo booleano
@Author  Duvan Arley Hernandez Niño
@Since	15/01/2024
*/
//-------------------------------------------------------------------------
WSMETHOD PUT divergences WSSERVICE ACDMOB
Local oJSepara    := Nil
Local nStatusCode := 500
Local cMessage
Local cResponse   := ""
Local cBody       := ""
Local lRet        := .T.
Local cCodOpe     := CBRetOpe()
Local cDivItemPv  := Alltrim(GetMV("MV_DIVERPV"))
Local cChSeek     := ''
Local cOs         := ""
Local cOsPedido   := ""
Local cOsProd     := ""
Local cOsLocal    := ""
Local cOsItem     := ""
Local cOsSequen   := ""
Local cOsLocaliz  := ""
Local cOsNumser   := ""
Local cOcoSep     := ""
Local cRetJson	  := ""

Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0013 // 'Usuario nao cadastrado para separacao'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( cBody )

			oJSepara := JsonObject():New()
			cRetJson := oJSepara:FromJson(cBody)

			If cRetJson == NIL

				If oJSepara:HasProperty("products") .And. !Empty(oJSepara["products"])
					CB7->(DbSetOrder(1)) //CB7_FILIAL+CB7_ORDSEP
					If CB7->( MSSeek( padr(xFilial("CB7"),TAMSX3("CB7_FILIAL")[1]) + Self:aURLParms[2]) )
						
						If  CB7->CB7_STATUS == '0' .OR. ( CB7->CB7_STATUS == '1' .AND. CB7->CB7_CODOPE == cCodOpe)

							If (ALLTRIM(oJSepara["divergence"])  $ cDivItemPv)
																
								CB8->(DbSetOrder(4)) // CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT
								cChSeek	:= (PadR(oJSepara[ "Code" ], 				 		  FWTamSX3("CB8_ORDSEP")[1])+;
											PadR(oJSepara[ "products" ][1][ "item" ], 	 	  FWTamSX3("CB8_ITEM")[1])+;
											PadR(oJSepara[ "products" ][1][ "code" ], 	 	  FWTamSX3("CB8_PROD")[1])+;
											PadR(oJSepara[ "products" ][1][ "warehouse" ], 	  FWTamSX3("CB8_LOCAL")[1])+;
											PadR(oJSepara[ "products" ][1][ "address" ],	  FWTamSX3("CB8_LCALIZ")[1])+;
											PadR(oJSepara[ "products" ][1][ "batch" ], 	 	  FWTamSX3("CB8_LOTECT")[1])+;
											PadR(oJSepara[ "products" ][1][ "sublot" ], 	  FWTamSX3("CB8_NUMLOT")[1])+;
											PadR(oJSepara[ "products" ][1][ "serialNumber" ], FWTamSX3("CB8_NUMSER")[1]))

								If CB8->(MSSeek(xFilial("CB8")+cChSeek))
									While CB8->(!Eof()) .AND. ;
											CB8->(CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER+CB8_PEDIDO)==;
											xFilial("CB8")+cChSeek+padr(oJSepara[ "products" ][1][ "document" ], FWTamSX3("CB8_PEDIDO")[1])	
										RecLock("CB8",.F.)
										
										CB8->CB8_OCOSEP := oJSepara["divergence"]
										
										CB8->(MsUnlock())
										
										cOs        := CB8->(CB8_ORDSEP)
										cOsPedido  := CB8->(CB8_PEDIDO)
										cOsProd    := CB8->(CB8_PROD)
										cOsLocal   := CB8->(CB8_LOCAL)
										cOsItem    := CB8->(CB8_ITEM)
										cOsSequen  := CB8->(CB8_SEQUEN)
										cOsLocaliz := CB8->(CB8_LCALIZ)
										cOsNumser  := CB8->(CB8_NUMSER)
										cOcoSep    := oJSepara["divergence"]
										CB8->(DbSkip())
									EndDo

									If !Empty( cOs )
										A166LimDivIt(cOs,cOsPedido,cOsProd,cOsLocal,cOsItem,cOsSequen,cOsLocaliz,cOsNumser,cOcoSep)
										If CB7->CB7_DIVERG != "1"   // marca divergencia na ORDEM DE SEPARACAO para que esta seja arrumada
											CB7->(RecLock("CB7"))
											CB7->CB7_DIVERG := "1"  // sim
											CB7->(MsUnlock())
										EndIf
									
										lRet 		:= .T.
										cResponse := "{}"									
									Else
										lRet 		:= .F.
										nStatusCode	:= 400
										cMessage 	:= STR0035 //"Pedido não encontrado na lista"
									
									EndIf								
								
								Else
									lRet 		:= .F.
									nStatusCode	:= 400
									cMessage 	:= STR0018 //"Item da separacao nao encontrada..."
								EndIf
									

							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0026  //"Divergência não configurada..."
							Endif
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0016 //"Separacao ja iniciada por outro separador ou finalizada..."
						Endif
					Else
						lRet 		:= .F.
						nStatusCode	:= 400
						cMessage 	:= STR0017 //"Separacao nao encontrada..."
					Endif
				Else
					lRet 		:= .F.
					nStatusCode	:= 400
					cMessage 	:= STR0014 //"Dados da separacao nao enviados..."
				EndIf
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0033 + cRetJson //"Falha ao popular JsonObject. Erro:"
			EndIf
			FreeObj(oJSepara)
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005  //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf

If lRet
    Self:SetResponse( cResponse )
Else
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return( lRet )

//-------------------------------------------------------------------------
/* {protheus.doc} PUT  validLotes / ACDMOB
Retorna informações sobre o lote consultado

@param	Code, array com dados para mudança do status

@return lRet	, caracter

@author	 	Duvan Arley Hernandez Niño
@since		10/07/2024
/*/
WSMETHOD PUT validLotes  WSSERVICE ACDMOB
Local oJSepara    := Nil
Local nStatusCode := 500
Local cMessage    := ""
Local cResponse   := ""
Local cBody       := ""
Local lRet        := .T.
Local lSaldo	  := .T.
Local cCodOpe     := CBRetOpe()
Local oJsonSep    := JsonObject():New()
Local cOrdsep     := ""
Local cDocument   := ""
Local cCodeProd   := ""
Local cWarehouse  := ""
Local cItem       := ""
Local cSequence   := ""
Local cAddress    := ""
Local cNumSer     := ""
Local nQuantity   := 0
Local cBatch      := ""
Local cSublot     := ""
Local cNewbatch   := ""
Local cNewsublot  := ""
Local cNewNumSer  := ""
Local nSaldoLote  := 0
Local nTamLoteCt  := FWTamSX3("B8_LOTECTL")[1]
Local nTamSerie   := FWTamSX3("CB8_NUMSER")[1]
Local nTamSubLot  := TamSX3("CB8_NUMLOT")[1]
Local cPesSerie   := ""
Local cPesLote    := ""
Local cPesSubLot  := ""


Local aArea		  := GetArea()

Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0013 // 'Usuario nao cadastrado para separacao'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( AllTrim(cBody) )

			oJSepara := JsonObject():New()
			cRetJson := oJSepara:FromJson(cBody)
			
			If cRetJson == NIL

				If chkPropert(propSep(), oJSepara, @lRet, @cMessage, @nStatusCode)
					CB7->(DbSetOrder(1)) //CB7_FILIAL+CB7_ORDSEP
					If CB7->( MSSeek( padr(xFilial("CB7"),FWTamSX3("CB7_FILIAL")[1]) + Self:aURLParms[2]) )
						
						If  CB7->CB7_STATUS == '0' .OR. ( CB7->CB7_STATUS == '1' .AND. CB7->CB7_CODOPE == cCodOpe)

							cOrdsep    := Self:aURLParms[2]
							cDocument  := oJSepara["document"]
							cCodeProd  := padr(oJSepara["code"],FWTamSX3("B8_PRODUTO")[1])
							cWarehouse := oJSepara["warehouse"]
							cItem      := oJSepara["item"]
							cSequence  := oJSepara["sequence"]
							cAddress   := padr(oJSepara["address"],FWTamSX3("CB8_LCALIZ")[1])
							cNumSer    := padr(oJSepara["serialNumber"], nTamSerie)
							nQuantity  := oJSepara["quantity"]
							cBatch     := padr(oJSepara["batch"], nTamLoteCt)
							cSublot    := padr(oJSepara["sublot"], nTamSubLot)							
							cNewbatch  := padr(oJSepara["newbatch"], nTamLoteCt)
							cNewsublot := padr(oJSepara["newsublot"], nTamSubLot)
							cNewNumSer := padr(oJSepara["newSNumber"], nTamSerie)
							
							cPesLote   := IF(!Empty(cNewbatch), cNewbatch, cBatch)
							cPesSubLot := IF(!Empty(cNewsublot), cNewsublot, cSublot)
							cPesSerie  := IF(!Empty(cNewNumSer), cNewNumSer, cNumSer)

							If CB7->CB7_ORIGEM == "4"
								lSaldo := .F.
							EndIf

							// Somente faz checagens de rastreabilidade se produto possuir tal controle
							If Rastro(cCodeProd)
								If ! CBExistLot(cCodeProd,cWarehouse,cAddress,cNewbatch,cNewsublot)
									cMessage := STR0030 //"Lote nao existe"
									nStatusCode	:= 400
									lRet := .F.

								EndIf
								If lRet .And. cNewbatch+cNewsublot != cBatch+cSublot
									// ----------------------------------------------------------------------------------------------------------------------------------------------------------------//
									// Na funcao CBExistLot(), caso a query na SBF não tenha retorno,
									// é feito um posicionamento na tabela SB8**. Acontece que ao passar endereco/cAddress/CB8_LCALIZ, o resultado da query é verdadeiro,
									// sendo assim não entra na condição onde a tabela foi posicionada, tendo como retorno vazio da funcao Alias(), tal funçao utilizada em SaldoLote() (sigacusb.prx),
									// gerando errolog ao final do programa, pois ele tenta reposicionar a tabela aberta no momento que SaldoLote() foi iniciada.
									//----------------------------------------------------------------------------------------------------------------------------------------------------------------//
									If Empty(Alias())  
										DbSelectArea("SBF")
									EndIf
									
									nSaldoLote := SaldoLote(cCodeProd,cWarehouse,cNewbatch,cNewsublot,,,,dDataBase,,lSaldo)
									If nSaldoLote < nQuantity
										cMessage :=  STR0029 //"Lote con saldo insuficiente""Lote com saldo insuficiente"
										nStatusCode	:= 400
										lRet := .F.
									EndIf
								EndIf
								// Nao permite informar lote pertencente a outro endereco
								If lRet .And. Localiza(cCodeProd)

									If !ACDVEndLot(cCodeProd,cPesLote,cPesSubLot,cPesSerie,cWarehouse,cAddress)
										cMessage := STR0031 //"Lote digitado pertence a outro endereco"
										nStatusCode	:= 400
										lRet := .F.
									EndIf
								EndIf
							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0032 //O produto não suporta rastreamento de lote
									
							EndIf
							
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0016 //"Separacao ja iniciada por outro separador ou finalizada..."
						Endif
					Else
						lRet 		:= .F.
						nStatusCode	:= 400
						cMessage 	:= STR0017 //"Separacao nao encontrada..."
					Endif
				EndIf
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0033 + cRetJson //"Falha ao popular JsonObject. Erro:"
			EndIf

			FreeObj(oJSepara)
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005  //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf
	
RestArea(aArea)

If lRet
	cResponse := oJsonSep:ToJson()
    Self:SetResponse( cResponse )
	FreeObj(oJsonSep)
Else
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
Return( lRet )

//-------------------------------------------------------------------------
/* {protheus.doc} PUT  validAddress / ACDMOB
Retorna informações sobre o endereço consultado

@param	Code, array com dados para mudança do status

@return lRet	, caracter

@author	 	Leonardo Kichitaro
@since		17/02/2025
/*/
//-------------------------------------------------------------------------
WSMETHOD PUT validAddress  WSSERVICE ACDMOB

Local oJSepara    := Nil
Local nStatusCode := 500
Local cMessage    := ""
Local cResponse   := ""
Local cBody       := ""
Local lRet        := .T.
Local cCodOpe     := CBRetOpe()
Local oJsonSep    := JsonObject():New()
Local cOrdsep     := ""
Local cDocument   := ""
Local cCodeProd   := ""
Local cWarehouse  := ""
Local cItem       := ""
Local cSequence   := ""
Local cAddress    := ""
Local cNumSer     := ""
Local cQuantity   := ""
Local cBatch      := ""
Local cSublot     := ""
Local cNewbatch   := ""
Local cNewsublot  := ""
Local cNewNumSer  := ""
Local nSaldoEnd	  := 0
Local nTamLoteCt  := FWTamSX3("B8_LOTECTL")[1]
Local nTamSerie   := FWTamSX3("CB8_NUMSER")[1]
Local nTamSubLot  := TamSX3("CB8_NUMLOT")[1]
Local cPesSerie   := ""
Local cPesLote    := ""
Local cPesSubLot  := ""

Local aArea		  := GetArea()

Self:SetContentType("application/json")

If Empty(cCodOpe)
	 nStatusCode       := 403
	 cMessage          := STR0013 // 'Usuario nao cadastrado para separacao'
	 lRet			   := .F.
EndIf

If lRet

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )

		cBody 	 	:= Self:GetContent()

		If !Empty( AllTrim(cBody) )

			oJSepara := JsonObject():New()
			cRetJson := oJSepara:FromJson(cBody)
			
			If cRetJson == NIL

				If oJSepara:HasProperty("code") .And. !Empty(oJSepara[ "code" ])
					CB7->(DbSetOrder(1)) //CB7_FILIAL+CB7_ORDSEP
					If CB7->( MSSeek( padr(xFilial("CB7"),FWTamSX3("CB7_FILIAL")[1]) + Self:aURLParms[2]) )
						
						If  CB7->CB7_STATUS == '0' .OR. ( CB7->CB7_STATUS == '1' .AND. CB7->CB7_CODOPE == cCodOpe)

							cOrdsep    := Self:aURLParms[2]
							cDocument  := oJSepara["document"]
							cCodeProd  := padr(oJSepara["code"],FWTamSX3("B8_PRODUTO")[1])
							cWarehouse := oJSepara["warehouse"]
							cItem      := oJSepara["item"]
							cSequence  := oJSepara["sequence"]
							cAddress   := padr(oJSepara["address"],FWTamSX3("CB8_LCALIZ")[1])
							cNumSer    := padr(oJSepara["serialNumber"], nTamSerie)
							cQuantity  := oJSepara["quantity"]
							cBatch     := padr(oJSepara["batch"], nTamLoteCt)
							cSublot    := padr(oJSepara["sublot"], nTamSubLot)							
							cNewbatch  := padr(oJSepara["newbatch"], nTamLoteCt)
							cNewsublot := padr(oJSepara["newsublot"], nTamSubLot)
							cNewNumSer := padr(oJSepara["newSNumber"], nTamSerie)
							
							cPesLote   := IF(!Empty(cNewbatch), cNewbatch, cBatch)
							cPesSubLot := IF(!Empty(cNewsublot), cNewsublot, cSublot)
							cPesSerie  := IF(!Empty(cNewNumSer), cNewNumSer, cNumSer)

							// Somente faz checagens de rastreabilidade se produto possuir tal controle
							If !Rastro(cCodeProd)
								If Localiza(cCodeProd)
									If Empty(cAddress)
										cMessage := "Endereco nao informado" //"Endereco nao informado"
										nStatusCode	:= 400
										lRet := .F.
									ElseIf !ACDVEndLot(cCodeProd,cPesLote,cPesSubLot,cPesSerie,cWarehouse,cAddress)
										cMessage := "Endereco nao existe" //"Endereco nao existe"
										nStatusCode	:= 400
										lRet := .F.
									EndIf

									If lRet
										DbSelectArea("SBF")

										nSaldoEnd := SaldoSBF(cWarehouse,cAddress,cCodeProd,cNumSer,cBatch,cSublot,,,,)

										If nSaldoEnd < cQuantity
											cMessage :=  STR0042 //"Endereco com saldo insuficiente"
											nStatusCode	:= 400
											lRet := .F.
										EndIf
									EndIf
								Else
									lRet 		:= .F.
									nStatusCode	:= 400
									cMessage 	:= STR0043 //"Produto nao possui controle por endereco"
								EndIf
							EndIf
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0016 //"Separacao ja iniciada por outro separador ou finalizada..."
						Endif
					Else
						lRet 		:= .F.
						nStatusCode	:= 400
						cMessage 	:= STR0017 //"Separacao nao encontrada..."
					Endif
				Else 
					lRet 		:= .F.
					nStatusCode	:= 400
					cMessage 	:= STR0034 + " -> code" //"Propriedade obrigatoria"
				EndIf
			Else
				lRet 		:= .F.
				nStatusCode	:= 400
				cMessage 	:= STR0033 + cRetJson //"Falha ao popular JsonObject. Erro:"
			EndIf

			FreeObj(oJSepara)
		Else
			lRet 		:= .F.
			nStatusCode	:= 400
			cMessage 	:= STR0005  //"Dados para atualizacao nao foram informados..."
		EndIf
	Else
		lRet 		:= .F.
		nStatusCode	:= 400
		cMessage 	:= STR0006 //"Dados para atualizacao nao foram informados ou Codigo nao encontrado..."
	EndIf

EndIf
	
RestArea(aArea)

If lRet
	cResponse := oJsonSep:ToJson()
    Self:SetResponse( cResponse )
	FreeObj(oJsonSep)
Else
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
Return( lRet )

//-------------------------------------------------------------------------
/* {protheus.doc} GET  ApiVersion / ACDMOB
Retorna a versão da API usada para o APP

@param SearchKey, caracter, filtro de busqueda
	   page, character	 , pagina inicial
	   PageSize, caracter , paginas maximas

@Return lRet , validação de processo booleano
@Author  Duvan Arley Hernandez Niño
@Since	01/08/2024
*/
//-------------------------------------------------------------------------
WSMETHOD GET ApiVersion WSSERVICE ACDMOB

Local aSvAlias    := GetArea()
Local cResponse   := ''
Local oResponse   := JsonObject():New()
Local oJsonApi    := JsonObject():New()
Local lRet        := .T.
Local aJsonApi    := {}

oJsonApi[ "api" ]		:= "getSeparations"
oJsonApi[ "version" ]	:= "3.0.0"

aAdd( aJsonApi, oJsonApi )

oResponse["apiVersion"]		:= aJsonApi
oResponse["hasNext"] 		:= .F.
cResponse := oResponse:toJson()
Self:SetResponse(cResponse)

RestArea(aSvAlias)
FWFreeArray( aSvAlias )

Return (lRet)



/*/{Protheus.doc} saveQryMD5
Reaproveita a consulta sem ter a necessidade de passar por changeQuery
@type function
@version  1.0
@author wellington.melo
@since 1/21/2025
@param cQuery, character, recebe a string da querry com bind
@return object, retorna o objeto criado
/*/
Static Function saveQryMD5(cQuery)
	Local cMD5       := ""
	Local nQry       := 0
	
	cMD5 := MD5(cQuery)
	nQry := AScan(__aQryMD5, {|x| x[1] == cMD5})
	If nQry == 0
		AAdd(__aQryMD5, {cMD5, FwExecStatement():New()})
	
		nQry := Len(__aQryMD5)
		__aQryMD5[nQry, 2]:SetQuery(ChangeQuery(cQuery))
	EndIf

Return __aQryMD5[nQry, 2]

/*/{Protheus.doc} confSaldo
confere se o saldo remanscente é menor do que o enviado pela o front
@type function
@version  
@author wellington.melo
@since 1/21/2025
@return logical, true/false
/*/

Static Function confSaldo(cDoc, cSerie, cFornec, cLoja, cProd, cLote, nQtde)
	Local cQuery    := ""
	Local cAlias    := ""
	Local oExec     := Nil
	Local nSaldo	:= 0
	Local lRet 		:= .T.

	Default cDoc    := ""
	Default cSerie  := ""
	Default cFornec := ""
	Default cLoja   := ""
	Default cProd   := ""

	cQuery := " SELECT D1_COD "
	cQuery += " 	,D1_LOTECTL "
	cQuery += " 	,SUM(D1_QUANT) QTD_TOT "
	cQuery += " 	,SUM(D1_QTDCONF) QTD_TOT_CONF  "
	cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " WHERE D1_FILIAL = ? "
	cQuery += " AND D1_DOC = ? "
	cQuery += " AND D1_SERIE = ? "
	cQuery += " AND D1_FORNECE = ? "
	cQuery += " AND D1_LOJA = ? "
	cQuery += " AND D1_COD = ?  "
	cQuery += " AND D1_LOTECTL = ?  "
	cQuery += " AND SD1.D_E_L_E_T_ = ? "
	cQuery += " GROUP BY D1_COD "
	cQuery += " 	,D1_LOTECTL "

	oExec := saveQryMD5(cQuery)

	oExec:SetString(1, FWxFilial("SD1"))
	oExec:SetString(2, cDoc)
	oExec:SetString(3, cSerie)
	oExec:SetString(4, cFornec)
	oExec:SetString(5, cLoja)
	oExec:SetString(6, cProd)
	oExec:SetString(7, cLote)
	oExec:SetString(8, "")

	cAlias := oExec:OpenAlias()

	If (cAlias)->(!EoF())
		nSaldo := (cAlias)->QTD_TOT - (cAlias)->QTD_TOT_CONF
	EndIf

	lRet := !(nQtde <= 0 .Or. nQtde > nSaldo)

	If Select(cAlias)
		(cAlias)->(DbCloseArea())
	EndIf

Return lRet

/*/{Protheus.doc} FnVlSaOs
Função para carregar a variavel static '__lSaOrdSep'
@author Leonardo Kichitaro
@since 21/02/2025
/*/
Static Function FnVlSaOs()
	//Validação do ambiente para Ordem de Separacao de SA
	If Type("__lSaOrdSep") == "U"
		If (__lSaOrdSep := FindFunction( 'AcdVldSA' ))
			__lSaOrdSep := AcdVldSA("CB7","CB7_NUMSA")
		EndIf
	EndIf
Return



/*/{Protheus.doc} chkPropert
AValia se os campos obrigatórios estão preenchidos e com o tipo correto
@type function
@version 1.0
@author wellington.melo
@since 7/21/2025
@param aFields, array, campos referente ao método
@param oJson, json, json da requisicao
@param lRet, logical, retorno para a api
@param cMessage, character, mensagem de erro
@param nStatusCode, numeric, status code da api
@return logical, retorar validacao das propriedades
/*/
Static Function chkPropert(aFields as array, oJson as Json, lRet as logical, cMessage as character, nStatusCode as numeric)

	Local aProperty  := {} as Array
	Local aObligator := {} as Array
	Local cProperty  := "" as Character
	Local cObligProp := "" as Character
	Local i                as Numeric
	Local nPos       := 0  as Numeric
	Local cType      := "" as Character
	Local xValue     := "" as Variant

	If !Empty(aFields)
		If ValType(oJson) == "J"
			aProperty := oJson:GetNames()
			//Adc apenas obrigatórios
			aEval(aFields, {|x| IF(x[4], aAdd(aObligator, x), .T. )  } )
			//Adc a string apenas campos nao foram encontraddos em aObligator com base no array Self:aFields
			//se o aScan for igual a 0, significa que o campo não foi encontrado no array Self:aFields
			//armazenar campos em cObligProp
			aEval(aObligator, { |x| cProperty := x[2], IF( aScan(aProperty, { |y| y == cProperty }) == 0, cObligProp += "| " + x[2] , .T. ) } )

			If Empty(cObligProp)
				for i := 1 to Len(aProperty)
					cProperty := aProperty[i]
					nPos := aScan(aObligator, { |x| x[2] == cProperty })
					If nPos > 0
						xValue := oJson[cProperty]
						cType  := ValType( xValue )
						If  cType == aObligator[nPos][3]
							If ( cType $ "C|A" .And. Empty( xValue ) ) .Or. ( cType == "N" .And. xValue <= 0 )
								lRet := .F.
								nStatusCode := 400
								cMessage := STR0044 + cProperty //"Valor do campo informado incorretamentem não pode ser vazio, 0 ou negativo. Campo: "
								Exit
							EndIf 
						Else
							lRet := .F.
							nStatusCode := 400
							cMessage := I18N(STR0045 ,{cProperty, cType, aObligator[nPos][3]}) // "Tipo do campo: " + cProperty + " informado como: " + cType + ", esperado: " + aObligator[nPos][3]
							Exit
						Endif
					EndIf
				next i
			Else
				lRet := .F.
				nStatusCode := 400
				cMessage := STR0034 //"Propriedade obrigatoria"
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} propSep
Função auxiliar para retornar os campos obrigatórios e tipos de dados usado em chkPropert
@type function
@version  1.0
@author wellington.melo
@since 7/21/2025
@return array, retorna campos api
/*/
Static Function propSep()
	Local aFields := {} as Array

	//{Campo X3, campo api, tipo, obrigatorio}
	aadd(aFields, {"CB7_ORDSEP", "code"    , FWSX3Util():GetFieldType( "CB7_ORDSEP" ), .T.})
	aadd(aFields, {"CB8_SALDOS", "quantity", FWSX3Util():GetFieldType( "CB8_SALDOS" ), .T.})
	aadd(aFields, {"CB8_LOTECT", "batch"   , FWSX3Util():GetFieldType( "CB8_LOTECT" ), .T.})
	aadd(aFields, {"CB8_LOTECT", "newbatch", FWSX3Util():GetFieldType( "CB8_LOTECT" ), .F.})

Return aFields



/*/{Protheus.doc} stockBalance
Método reporta o saldo de estoque por produto, lote e endereço. No momento da consulta numa separação da solicitação ao armazem.
@type GET method
@version  1.0
@author wellington.melo
@since 7/21/2025
/*/
WSMETHOD GET stockBalance WSRECEIVE SearchKey, Page, PageSize, productId WSSERVICE ACDMOB
	Local oResponse        := JsonObject():New()
	Local cBody            := ""  as Character
	Local lRet             := .F. as Logical
	Local cResponse        := ""  as Character
	Local cMessage         := ""  as Character

	Default Self:searchKey := ""
    Default Self:page      := 1
    Default Self:pageSize  := 10
    Default Self:productId := ""

	cBody := ::GetContent()

	lRet := stockBalan(@oResponse, @cMessage, Self:productId)

	cResponse := oResponse:ToJson()

	::SetResponse( cResponse )

Return lRet

/*/{Protheus.doc} stockBalan
Funcao resposavel por execeutar a query saldo lote e/ou endereço e montar o json de retorno
@type function
@version  1.0
@author wellington.melo
@since 8/6/2025
@param oResponse, object, json de reposta da api
@param cMessage, character, mensagem caso erro
@param cProductId, character, produto a ser consultado
@return logical, se a consulta foi realizada com sucesso
/*/
Static Function stockBalan(oResponse, cMessage, cProductId)
	Local cQuery     := ""  as Character
	Local aJsonSaldo := {}  as Array
	Local aJsonStock := {}  as Array
	Local lRet       := .T. as Logical
	Local cProduto   := ""  as Character
	Local cAlias     := ""  as Character
	Local nProd      := 0   as Numeric
	Local nParam     := 1   as Numeric
	Local oExec      := NIL as Object
	Local jProducts         as Json
	Local jStckItems        as Json
	Local jItems            as Json
	Local aArea      := FwGetArea()
	Local cDate      := dToc(Date())
	Local cTime      := Time()
		
	cQuery := sldLotEnd()
	
	oExec := saveQryMD5(cQuery)

	oExec:SetString(nParam++, FWxFilial("SB1"))
	oExec:SetString(nParam++, "")
	oExec:SetString(nParam++, FWxFilial("SBF"))
	oExec:SetString(nParam++, cProductId)
	oExec:SetNumeric(nParam++, 0)
	oExec:SetString(nParam++, "")

	oExec:SetString(nParam++, FWxFilial("SB1"))
	oExec:SetString(nParam++, "N")
	oExec:SetString(nParam++, "")
	oExec:SetString(nParam++, FWxFilial("SB8"))
	oExec:SetString(nParam++, cProductId)
	oExec:SetNumeric(nParam++, 0)
	oExec:SetString(nParam++, "")

	cAlias := oExec:OpenAlias()

	While (cAlias)->(!EoF())

		If cProduto <> (cAlias)->PRODUTO
			cProduto := (cAlias)->PRODUTO

			jProducts := JsonObject():New()
			jProducts[ "productId" ]       := (cAlias)->PRODUTO
			jProducts[ "barcode" ]         := (cAlias)->CODBAR
			jProducts[ "prodDescription" ] := (cAlias)->DESCRIC
			jProducts[ "syncDateAndTime" ] := cDate + " - " + cTime
			jProducts[ "stockInfoItems" ]  := {}

			aAdd(aJsonSaldo, jProducts)
		EndIf

		jStckItems := JsonObject():New()

		jStckItems[ "warehouse" ] := (cAlias)->ARMAZEM
		jStckItems[ "quantity" ]  := (cAlias)->QUANTIDADE
		jStckItems[ "allocated" ] := (cAlias)->EMPENHO
		jStckItems[ "address" ]   := (cAlias)->ENDERECO
		jStckItems[ "batch" ]     := (cAlias)->LOTE
		//Implmentacao futura
		// jStckItems[ "amount" ]          := SaldoLote((cAlias)->B8_PRODUTO, (cAlias)->B8_LOCAL, (cAlias)->B8_LOTECTL, (cAlias)->B8_NUMLOTE,,,,dDataBase,, .T.)
		// aJsonSaldo[nI][ "amount" ]          := SaldoSBF( (cAliasSbf)->BF_LOCAL, (cAliasSbf)->BF_LOCALIZ, (cAliasSbf)->BF_PRODUTO, (cAliasSbf)->BF_NUMSERI, (cAliasSbf)->BF_LOTECTL, (cAliasSbf)->BF_NUMLOTE,,,,,)
		nProd := Len(aJsonSaldo)

		aAdd(aJsonSaldo[nProd][ "stockInfoItems" ], jStckItems)

		(cAlias)->(DbSkip())			
	EndDo 

	(cAlias)->(dbCloseArea())

	If !Empty(aJsonSaldo)
		jItems := JsonObject():New()
		jItems[ "items" ] := aJsonSaldo
		jItems[ "hasNext" ] := .F.
		oResponse:Set(jItems)
	EndIf

	FwRestArea(aArea)
	FWFreeArray(aJsonSaldo)
	FWFreeArray(aJsonStock)
Return lRet


/*/{Protheus.doc} sldLotEnd
String da query resposável por retornar os lote e/ou endereço do item a ser consultado no momemento da separação ao Armazém.
@type function
@version  1.0
@author wellington.melo
@since 8/6/2025
@return character, retorna a query para ser executada
/*/
Static Function sldLotEnd()

	Local cQuery       := ""  as Character

	cQuery := " SELECT BF_FILIAL FILIAL "
	cQuery += " 	,BF_PRODUTO PRODUTO "
	cQuery += " 	,B1_CODBAR CODBAR "
	cQuery += " 	,B1_DESC DESCRIC "
	cQuery += " 	,BF_LOCAL ARMAZEM "
	cQuery += " 	,BF_QUANT QUANTIDADE "
	cQuery += " 	,BF_EMPENHO EMPENHO "
	cQuery += " 	,BF_LOCALIZ ENDERECO "
	cQuery += " 	,BF_LOTECTL LOTE "
	cQuery += " 	,BF_NUMLOTE SUBLOTE "
	cQuery += " 	,BF_NUMSERI SERIE "
	cQuery += " FROM " + RetSqlName("SBF") + " SBF "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += " ON B1_FILIAL = ? " //1
	cQuery += " 	AND B1_COD = BF_PRODUTO "
	cQuery += " 	AND SB1.D_E_L_E_T_ = ? " //2
	cQuery += " WHERE SBF.BF_FILIAL = ? " //3
	cQuery += " AND SBF.BF_PRODUTO = ? " //4
	cQuery += " AND SBF.BF_QUANT > ? " //5
	cQuery += " AND SBF.D_E_L_E_T_ = ? " //6

	cQuery += " UNION ALL "
	
	cQuery += " SELECT B8_FILIAL FILIAL "
	cQuery += " 	,B8_PRODUTO PRODUTO "
	cQuery += " 	,B1_CODBAR CODBAR "
	cQuery += " 	,B1_DESC DESCRIC "
	cQuery += " 	,B8_LOCAL ARMAZEM "
	cQuery += " 	,B8_SALDO QUANTIDADE "
	cQuery += " 	,B8_EMPENHO EMPENHO "
	cQuery += " 	,'' ENDERECO "
	cQuery += " 	,B8_LOTECTL LOTE "
	cQuery += " 	,B8_NUMLOTE SUBLOTE "
	cQuery += " 	,'' SERIE "
	cQuery += " FROM " + RetSqlName("SB8") + " SB8 "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += " 	ON B1_FILIAL = ? " //7
	cQuery += " 	AND B1_COD = B8_PRODUTO "
	cQuery += " 	AND B1_LOCALIZ = ? " //8
	cQuery += " 	AND SB1.D_E_L_E_T_ = ? " //9
	cQuery += " WHERE SB8.B8_FILIAL = ?  " //10
	cQuery += " AND SB8.B8_PRODUTO = ? " //11
	cQuery += " AND SB8.B8_SALDO > ? " //12
	cQuery += " AND SB8.D_E_L_E_T_ = ? " //13


Return cQuery



/*/{Protheus.doc} closePicking
Método responsável por encerrar uma separação - Por ora apenas com origem SA
{
    "code": "000199",
    "type": "4",
    "activitys": "00*",
    "status": "2",
    "conclude": true //Obrigatório
}
@type method
@version  1.0
@author wellington.melo
@since 23/08/2025
/*/
WSMETHOD PUT closePicking WSSERVICE ACDMOB

	Local nStatusCode := 500 as Numeric
	Local cResponse   := ""  as Character
	Local cBody       := ""  as Character
	Local aRet        := {}  as Array
	Local lRet        := .F. as Logical
	Local aJProdSep   := {}  as Array
	Local jResponse   := JsonObject():New()
	Local cMessage    := ""  as Character
	Local jBody              as Json
	Local jItems             as Json
	Local jProducts          as Json

	Self:SetContentType("application/json")

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[2] )
		cBody 	 	:= Self:GetContent()
		If !Empty( cBody )
			jBody := JsonObject():New()

			If jBody:FromJson(cBody) == NIL
				lRet := .T.
				If chkPropert(prCloseSep(), jBody, @lRet, @cMessage, @nStatusCode)
					CB7->(DbSetOrder(1))
					If CB7->( MSSeek( padr(xFilial("CB7"),TAMSX3("CB7_FILIAL")[1]) + Self:aURLParms[2]) )
						If CB7->CB7_ORIGEM == "4"
							If CB7->CB7_STATUS == "1"
								CB9->( DbSetOrder(14) )									
								If CB9->( MsSeek( FWxFilial("CB9") + CB7->CB7_NUMSA + CB7->CB7_ORDSEP ) )
									If jBody[ "conclude" ]
										aRet := FimProc166(.T., CB7->CB7_ORDSEP, .F., .T. )
										// caso retornar erro no processamento da requisição, retorna mensagem para central de notificiação do app
										If aRet[1] == 10  
											lRet 		:= .F.
											nStatusCode	:= 400
											cMessage 	:= aRet[2] 
										Else
											CB8->(DbSetOrder(11))
											If CB8->( MsSeek( FWxFilial("CB8") + CB7->CB7_ORDSEP + CB7->CB7_NUMSA ) )
												// Percorre os itens da separação para serem adicionados no array de produtos do json de retorno
												While CB8->( !EoF() ) .And. CB8->CB8_FILIAL == FWxFilial("CB8") .And. CB8->CB8_ORDSEP == CB7->CB7_ORDSEP .And. CB8->CB8_NUMSA == CB7->CB7_NUMSA

													jItems := JsonObject():New()

													jItems["productId" ]    := CB8->CB8_PROD
													jItems["item" ]         := CB8->CB8_ITEM
													jItems["sequence" ]     := CB8->CB8_SEQUEN
													jItems["warehouse" ]    := CB8->CB8_LOCAL
													jItems["address" ]      := CB8->CB8_LCALIZ
													jItems["serialNumber" ] := CB8->CB8_SERIE
													jItems["batch" ]        := CB8->CB8_LOTECT
													jItems["sublot" ]       := CB8->CB8_NUMLOT
													jItems["quantity" ]     := CB8->CB8_QTDORI
													jItems["balance" ]      := CB8->CB8_SALDOS

													aadd(aJProdSep, jItems)

													CB8->(DbSkip())
												EndDo

												jProducts := JsonObject():New()
												jProducts[ "products" ] := aJProdSep													
												jResponse:Set(jProducts)

												If !Empty(aJProdSep)
													FWFreeArray(aJProdSep)
												EndIf	
											EndIf
										EndIf
									EndIf
								Else
									lRet 		:= .F.
									nStatusCode	:= 400
									cMessage 	:= STR0046 //"Nao ha item separado"
								EndIf
							Else
								lRet 		:= .F.
								nStatusCode	:= 400
								cMessage 	:= STR0048 //"A ordem de separacao nao esta em separacao, verifique o status da separacao."
							EndIf
						Else
							lRet 		:= .F.
							nStatusCode	:= 400
							cMessage 	:= STR0041 //"Separacao nao é do tipo SA..."
						EndIf
					Else
						lRet 		:= .F.
						nStatusCode	:= 400
						cMessage 	:= STR0017 //"Separacao nao encontrada..."
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lRet
		cResponse := jResponse:ToJson()
		Self:SetResponse( cResponse )
	Else
		SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
	EndIf

	If ValType(jResponse) == "J"
		FreeObj(jResponse)
		jResponse := Nil
	EndIf

Return( lRet )

/*/{Protheus.doc} prCloseSep
Função auxiliar para retornar os campos obrigatórios e tipos de dados usado em chkPropert
Usado em: closePicking
@type function
@version  1.0
@author wellington.melo
@since 08/25/2025
@return array, retorna campos api
/*/
Static Function prCloseSep()
	Local aFields := {} as Array

	//{Campo X3, campo api, tipo, obrigatorio}
	aadd(aFields, {"", "conclude"    , "L", .T.})
	
Return aFields
