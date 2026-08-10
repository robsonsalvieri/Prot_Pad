#INCLUDE "TOTVS.CH"	
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Fileio.ch"

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFWSGARBAGE
Api de Limpeza das tabelas do TAF.

@return true

@author Evandro dos Santos O. Teixeira
@since 18/04/2018
@version 1.0
/*/ 
//--------------------------------------------------------------------------- 
WSRESTFUL TAFWSGARBAGE   DESCRIPTION   "Serviço para Chamada do TAFInteg() - Central de Automação."

WSDATA sourceBranch 	AS STRING
WSDATA eventType		AS STRING
WSDATA deleteMode   	AS INTEGER 

WSMETHOD GET 		 0001 DESCRIPTION   "Método que realiza a consulta do termino do processamento de Exclusão"	  			WSSYNTAX "/delete/getStatus/" PATH "/delete/getStatus/"
WSMETHOD DELETE 	 DESCRIPTION   		"Método de Exclusão." PRODUCES APPLICATION_JSON //"Método de Exclusão de registros utilizando o TafTicket."

END WSRESTFUL

//----------------------------------------------------------------------------
/*/{Protheus.doc} DELETE
Metodo para exclusao de regitros no TAF.

@return true

@author Evandro dos Santos O. Teixeira
@since 18/04/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
WSMETHOD DELETE WSREST TAFWSGARBAGE

	Local lDelete		as logical
	Local lRet			as logical
	Local cChave		as character
	Local cFuncIPC		as character
	Local cFuncREST		as character
	Local cUId			as character
	Local cValorR		as character	
	Local cCodFilERP	as character	
	Local cCorErr		as character
	Local cDescErr		as character
	Local oSelf			as object
	Local nI			as numeric	
	Local aRetorno		as array
	Local nVal 			as numeric

	Local aQryParam     as array
	
	cFuncREST 	:= "TAFWSPROCDEL"
	cChave		:= "PROCDEL"
	cUId 		:= "uUIDTafProcessDel" 
	cValorR 	:= 'respProcDEL'
	cCorErr 	:= ''
	cDescErr 	:= ''

	lDelete		:=	.T.
	cBody		:=	""
  	aRetorno	:= {}
  	nI 			:= 0
	nVal		:= 0
  	
  	aQryParam := {}
  	
  	oSelf := ::Self
	cBody := ::GetContent()
	
	VarGetXD(cUId,cChave,@nVal)

	If nVal == 1 
		::Self:SetResponse(setMsgResponse("002","Existe um processo de Exclusao em Andamento. Aguarde o Termino para uma nova requisicao.",.F.))
	Else
		
		lRet := VarSetUID(cUId, .T.)
	
		If Empty(cBody)
			SetRestFault(704,"Arquivo vazio. ") //
			lPost := .F.
		Else
			cCodFilERP := WSGetPostFil(cBody)
		EndIf 
		
		If Empty(cCodFilERP)
			::Self:SetResponse(setMsgResponse("811","Nao foi possível identificar a filial (sourceBranch (TAFFIL)) no corpo da mensagem",.F.)) //"Não foi possível identificar a filial # " no corpo da mensagem."      
		Else
			If WSST2ValFil(cCodFilERP,@cFuncIPC,@cCorErr,@cDescErr) 
	
				oSelf:SetContentType("application/json")
				If TAFSCALLIPC(cFuncIPC,cFuncREST,cUId,cChave,cValorR,{},cBody,cCodFilERP)
					::Self:SetResponse(setMsgResponse("","Funcao Iniciada.",.T.))
				Else
					::Self:SetResponse(setMsgResponse("813","Time Out.",.F.))
				EndIf 
			Else
				::Self:SetResponse(setMsgResponse("803","O valor do campo sourceBranch (TAFFIL) nao está cadastro no complemento de empresas.",.F.)) //"O valor do campo "#" não está cadastro no complemento de empresas."  
			EndIf
		EndIf
		
	EndIf 

Return (lDelete)

//----------------------------------------------------------------------------
/*/{Protheus.doc} GET 0001
Verifica se o processo de exclusão está em andamento.

@return true

@author Evandro dos Santos O. Teixeira
@since 18/04/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
WSMETHOD GET 0001 WSSERVICE TAFWSGARBAGE

	Local cUuId := "uUIDTafProcessDel"
	Local cChave := "PROCDEL"
	
	Local nVal := 0

	::SetContentType("application/json") 
	
	If Len(::aURLParms) > 1
	
		If ::aURLParms[2] == "getStatus"
		
			If VarGetXD(cUuId,cChave,@nVal)

				If nVal == 1 
					::Self:SetResponse(setMsgResponse("","Processo de Exclusao em execucao.",.T.,"1")) 
				Else
					::Self:SetResponse(setMsgResponse("","Nao ha processo de Exclusao em execucao.",.T.,"0")) 
				EndIf 
			Else
				::Self:SetResponse(setMsgResponse("","Nao ocorreu nenhuma execucao do processo de exclusao apos a inicializacao do ambiente.",.T.,"9"))
			EndIf 

		Else
			::Self:SetResponse(setMsgResponse("801","Parametro Invalido.",.F.,"0")) 
		EndIf 
	
	EndIf 

Return .T.

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFWSPROCDEL
Método de Exclusão de base TAF.

@param cUId	- Identificador da sessão de Variáveis Globais.
@param cChave - Identificador da chave (tabela X) HashMap
@param cValorR - Variável onde será armazenado o valor da chave ("Tabela A").
@param aQryParam - Parâmetros de entrada do método GET.
@param cBody - Mensagem enviada no Body do POST
@param cCodFilERP - Filial do ERP

@return Nil 

@author Evandro dos Santos O. Teixeira
@since 18/04/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Function TAFWSPROCDEL(cUId,cChave,cValorR,aQryParam,cBody,cCodFilERP)

	Local oModel := Nil 
	Local nX := 0
	Local nY := 0
	Local cTable := ""
	Local cSqlDel := ""
	Local cSqlUpd := ""
	Local cFilTAF := ""
	Local cModel := ""
	Local cTipoEvt := ""
	Local cMsgErr := ""
	Local cEventosParam := ""
	Local cEscopo := ""
	Local lEraseST2 := .T.
	Local lEraseXERP := .T.
	Local nCodErr := 0
	Local aResponse := {}
	Local aRotinas := {}
	Local aTablesExec := {}
	Local lVirgula := .F.
	Local lFirst := .T.
	

	Private oJson := Nil 
	
	If FWJsonDeserialize(cBody,@oJson)
		
		If !(Type("oJson:tableSt2Erase") == "U")          
			lEraseST2 := oJson:tableSt2Erase
		EndIf 
		
		If !(Type("oJson:tableXErpErase") == "U")       
			lEraseXERP := oJson:tableXErpErase
		EndIf 
		
		If !(Type("oJson:layouts") == "U")       
			cEventosParam := oJson:layouts
		EndIf 
		
		If Type("oJson:eventType") == "U"          
			cTipoEvt := "ALL"
		Else
			cTipoEvt := oJson:eventType
		EndIf 
		
		If Type("oJson:scopeIntegration") == "U"          
			cEscopo := "0"
		Else
			cEscopo := oJson:scopeIntegration
		EndIf 
		
	Else
		nCodErr := 705 
		cMsgErr := "Erro ao realizar parser da mensagem"
	EndIf 
	
	If cEscopo == "3" 
		aRotinas := TAFRotinas(,,.T.,2) //eSocial
	ElseIf cEscopo == "2"
		aRotinas := TAFRotinas(,,.T.,3) //ECF
	ElseIf cEscopo =="1"
		aRotinas := TAFRotinas(,,.T.,1) //Fiscal
	ElseIf cEscopo =="4"
		aRotinas := TAFRotinas(,,.T.,5) //Reinf
	ElseIf cEscopo =="5"
		aRotinas := TAFRotinas(,,.T.,6) //Genericos
	Else
		aRotinas := TAFRotinas(,,.T.,0) //Todos
	EndIf
	

	aAdd(aResponse,'"lastExecution" : [' )

	For nY := 1 To Len(aRotinas)

				
		cModel := aRotinas[nY][1]
		cLayout := AllTrim(aRotinas[nY][4])
	
		If !(cEscopo $ "3|4") .Or. (cTipoEvt == aRotinas[nY][12] .Or. cTipoEvt == "ALL")
		
			If Empty(cEventosParam) .Or. (cLayout $ cEventosParam)

				If cModel == "TAFA050"
				
					cTable := "C1E"
		
					cSqlUpd := " UPDATE " + RetSqlName("C1E")
					cSqlUpd += " SET "
					cSqlUpd += " C1E_EVENTO = 'I'"
					//cSqlUpd += ",C1E_STATUS = ' '" 

					
					If !Empty(cFilTAF)
						cSqlUpd += " WHERE " + cTable + "_FILTAF = '" + cFilTAF + "'"
						cSqlUpd += " AND C1E_ATIVO = '1' "
					EndIf 	
					
					If lVirgula 
						aAdd(aResponse,',')
					Else
						lVirgula := .T.
					EndIf 
		
					aAdd(aResponse,'{"layout" : ' + '"' + cLayout + '"')
					aAdd(aResponse,',"tables" : [')
					
					If checkTables(cTable,aTablesExec)
						eraseTabs(.T.,@aResponse,cSqlUpd,cTable,cLayout,lEraseST2,lEraseXERP,cCodFilERP)
					Endif
					
					aAdd(aResponse,']')
					aAdd(aResponse,'}')
	
					//Fazer melhoria para limpar a CR9
					//Fazer melhoria para limpar os registros não ativos da C1E
		
				ElseIf !Empty(cLayout) .AND. cLayout != "TAUTO"
		
					TAFConOut("Limpando modelo " + cModel + " Layout " + cLayout )
					oModel := FWLoadModel(cModel)
					
					If  oModel != Nil 
					
						If lVirgula 
							aAdd(aResponse,',')
						Else
							lVirgula := .T.
						EndIf 
		
						aAdd(aResponse,'{"layout" : ' + '"' + cLayout + '"')
						aAdd(aResponse,',"tables" : [')
			
						For nX := 1 To Len(oModel:aAllSubModels)
						
							If Len(oModel:aAllSubModels[nX]:oFormModelStruct:aTable) > 0
							
								cTable := oModel:aAllSubModels[nX]:oFormModelStruct:aTable[1]
								
								If checkTables(cTable,aTablesExec)
				
									cSqlDel := "DELETE FROM " + RetSqlName(cTable) 
									If !Empty(cFilTAF)
										cSqlDel += " WHERE " + cTable + "_FILIAL = '" + cFilTAF + "'"
									EndIf 
									
									eraseTabs(lFirst,@aResponse,cSqlDel,cTable,cLayout,lEraseST2,lEraseXERP,cCodFilERP)
									lFirst := .F.
									
								EndIf 
								
							EndIf 
							
						Next nX 
						
						aAdd(aResponse,']')
						aAdd(aResponse,'}')
						lFirst := .T.
						
						TafClearModel(oModel)
						
					EndIf 
		
				EndIf
			EndIf
		EndIf 
		
	Next nY
	
	aAdd(aResponse,']' )
	
	aAdd(aResponse,',"date" : "' + DTOC(Date()) + '"')
	aAdd(aResponse,',"time" : "' + Time() + '"')
	
	TAFFinishWS(cChave,cUId,cValorR,aResponse ,3)
	varInfo('aresponse',aResponse)

Return Nil 

//----------------------------------------------------------------------------
/*/{Protheus.doc} checkTables
Verifica se a tabela já foi excluida por outro evento.

@param cTable - Codigo da Tabela
@param aTables - Array com as tabelas já excluidas

@return lRet - Informa se a tabela já foi excluida por outro evento.

@author Evandro dos Santos O. Teixeira
@since 18/04/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function checkTables(cTable,aTables)

	Local lRet := .T. 

	If aScan(aTables,{|t|t == cTable}) == 0
		aAdd(aTables,cTable)
	Else
		lRet := .F.
	EndIf 
	
Return lRet

//----------------------------------------------------------------------------
/*/{Protheus.doc} eraseTabs
Realiza a exclusao das tabelas de um determinado Modelo e monta o array de 
response.

@param lFirst - Indica que é a primeira tabela a ser excluida do Modelo.
@param aResponse - Array para as mensagens de response
@param cSql - Sql para Delete da tabela
@param lOk - Identifica se a operação foi realizada com sucesso.
@param cTable - Tabela que será excluida
@param cEvento - Evento referente as tabelas
@param lEraseST2 - Determina se os dados do evento na ST2 devem ser excluidos
@param lEraseXERP - Determina se os dados do evento na XERP devem ser excluidos
@param cCodFilERP - Codigo da Filial do ERP

@return Nil

@author Evandro dos Santos O. Teixeira
@since 18/04/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function eraseTabs(lFirst,aResponse,cSql,cTable,cEvento,lEraseST2,lEraseXERP,cCodFilERP)

	Local cOperation := "delete"
	Local cSqlDel    := ""

	Default cCodFilERP := ""
	Default lEraseXERP := .T.
	Default lEraseST2  := .T. 
	Default cEvento    := ""
	Default cTable	   := ""
	
	If cTable == "C1E"
		cOperation := "update"
	EndIf  

	If !lFirst
		aAdd(aResponse,',')
	EndIf 

	aAdd(aResponse,'{"table" : "' + cTable + '"')
	TAFConOut("Tabela:" + cTable)
	
	If TCCanOpen(RetSqlName(cTable))

		If TcSqlExec(cSql) < 0
	
			aAdd(aResponse,',"success" : false')
			aAdd(aResponse,',"operation" : "' + cOperation + '"')
			aAdd(aResponse,',"error" : "'  + TCSQLError() + '"')
		Else
	
			aAdd(aResponse,',"success" : true')
			aAdd(aResponse,',"operation" : "' + cOperation + '"')
	
			If lEraseST2
	
				cSqlDel := " DELETE FROM TAFST2 WHERE TAFFIL = '" + cCodFilERP + "'"
	
				If TcSqlExec(cSqlDel) < 0
					aAdd(aResponse,',"tableSt2Erase" : false')
					aAdd(aResponse,',"error" : "'  + TCSQLError() + '"')
				Else
					aAdd(aResponse,',"tableSt2Erase" : true')
					
					If lEraseXERP
						cSqlDel := " DELETE "
						cSqlDel += " FROM TAFXERP "  
						cSqlDel += " WHERE EXISTS "
						cSqlDel += " (SELECT 1 "
						cSqlDel += " FROM TAFST2 ST2 "
						cSqlDel += " WHERE ST2.TAFKEY = TAFXERP.TAFKEY AND ST2.TAFTICKET = TAFXERP.TAFTICKET "
						cSqlDel += " AND ST2.TAFTPREG = '" + cEvento + "' AND ST2.TAFFIL = '" + cCodFilERP + "') "
						
						If TcSqlExec(cSqlDel) < 0
							aAdd(aResponse,',"tableXErpErase" : false')
							aAdd(aResponse,',"error" : "'  + TCSQLError() + '"')
						Else
							aAdd(aResponse,',"tableXErpErase" : true')	
						EndIf 
					Else
						aAdd(aResponse,',"tableXErpErase" : false')
					Endif 
					
				EndIf 
			Else
				aAdd(aResponse,',"tableSt2Erase" : false')
			EndIf 
			
		EndIf 
	Else
		aAdd(aResponse,',"success" : false')
		aAdd(aResponse,',"operation" : "none"')
		aAdd(aResponse,',"error" : "Tabela ' + cTable + ' não existe no banco de dados."')
	EndIf 

	aAdd(aResponse,'}')

Return Nil 

//----------------------------------------------------------------------------
/*/{Protheus.doc} setMsgResponse
Cria Json de resposta para as mensagens.

@param cCodErr - Codigo do Erro (Se Houver)
@param cDescription - Descrição da execução
@param lOk - Identifica se a operação foi realizada com sucesso.
@param cStatus - Status da operação 
		   0 - Exclusao Finalizada/Não Iniciada
		   1 - Exclusao em Andamento
		   9 - Exclusão não executa nenhum vez antes da chamada do metodo GET
		   
@return cResponse - String para o Response do REST

@author Evandro dos Santos O. Teixeira
@since 18/04/2018
@version 1.0
/*/
//--------------------------------------------------------------------------- 
Static Function setMsgResponse(cCodErr,cDescription,lOk,cStatus,cRespCompl)

	Local cResponse := ""
	Local cUuId := "uUIDTafProcessDel"
	Local aRetorno := {}
	Local cValorR 	:= 'respProcDEL'
	Local nI := 0
	
	Default cCodErr := ""
	Default cDescription := ""
	Default lOk := .T.
	Default cRespCompl := ""
	Default cStatus := ""

	cResponse := '{'
	If lOk
		cResponse += '"success" : true'
	Else
		cResponse += '"success" : false'
	EndIf 
	
	If !Empty(cCodErr)
		cResponse += ','
		cResponse += '"errorCode" : "' + cCodErr + '"'
	EndIf 
	
	If !Empty(cStatus)
		cResponse += ','
		cResponse += '"status" : "' + cStatus + '"'
	EndIf 
	
	If !Empty(cRespCompl)
		cResponse += cRespCompl
	EndIf 
	
	cResponse += ','
	cResponse += '"description" : "' + cDescription  + '"'
	
	If cStatus == "0" //Retorno ultimos evento excluidos
		If VarGetAD(cUuId,cValorR,@aRetorno) 
			If !Empty(aRetorno)
				cResponse += ','
				For nI := 1 To Len(aRetorno)
					cResponse += aRetorno[nI]
				Next nI
				aSize(aRetorno,0)
			EndIf 
		Endif 
	EndIf 
	
	cResponse += '}'

Return (cResponse)