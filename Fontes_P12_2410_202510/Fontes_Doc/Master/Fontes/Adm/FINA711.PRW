#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA711
	Job para calculo dos saldos para o Novo Gestor Financeiro

	@param cCompany, character, código do grupo de empresas
	@param cBranch , character, código da filial

	@author renato.ito
	@since 23/02/2021
/*/
//-------------------------------------------------------------------
Function FINA711(cCompany As Character, lAutomato As Logical)
	Local cLastDate   as Character
	Local cJobTime    as Character
	Local lStamp      as Logical
	Local lProcDoc	  as Logical
	Local lProcPed    as Logical
	Local lError	  as Logical
	Local cStartTime  as Character
	Local cStartJob   as Character
	Local cFnc        as Character // macro executar função tlpp pra não gerar erro de compilação no release 17
	Local cLockName   as Character
	Local cLckAuxNam  as Character
	Local cCodSch	  as Character
	Local oDocSer     as Object
	Local oOrders	  as Object
	Local jJobTime	  as Json
	Local jNewJTime   as Json

	Default lAutomato	:= .F. // Variável deverá ser retirada apos a criação do Pergunte FIN711

	lError	:= .F.
	lProcDoc := lProcPed := .T.
	jNewJTime := JsonObject():new()

	If !lAutomato
		If ValType(MV_PAR01) == "N" .and. MV_PAR01 == 2
			lProcDoc := .F.
			FwLogMsg("INFO",, "FINA711", "FINA711", "", "Parameters", "Titles will not be processed" )
		Endif

		If ValType(MV_PAR02) == "N" .and. MV_PAR02 == 2
			lProcPed := .F.
			FwLogMsg("INFO",, "FINA711", "FINA711", "", "Parameters", "Orders will not be processed" )
		Endif
	EndIf

	cLockName := cEmpAnt + " - FINA711"
	cCodSch := "FINA711('" + cEmpAnt + "')"

	If (AliasInDic('F76') .And. AliasInDic('F75') .And. F710VDic())
		If ( lProcDoc .Or. lProcPed ) 
			// Verifica se exite um job em execução
			If &("gfin.util.schedule.validBranchesSchedule(cCodSch)")
				lStamp      := .T.
				cStartJob   := Time()
				jJobTime	:= JsonObject():New()

				jJobTime := getTfcJob()

				ConOut(CRLF + "["+ cLockName + "] Started")
				// inicia o job de titulos
				If lProcDoc
					cJobTime:= updTime()
					cLckAuxNam	:= cLockName + ' - DOC'
					If LockByName( cLckAuxNam, .T./*lEmpresa*/, .F./*lFilial*/ )
						cStartTime := Time()
						cFnc := 'gfin.job.DocumentsBalance():new()'
						oDocSer := &cFnc
						oDocSer:setLastUpdateDate(jJobTime['TJOBDOC'])
						oDocSer:processDocuments()
						If oDocSer:lOk
							ConOut(CRLF + "["+ cLckAuxNam + "] Documents processing time: "+ ElapTime(cStartTime, Time()))
							ConOut("["+ cLckAuxNam + "] Documents updated: "+ cValToChar(oDocSer:insertions))
							jNewJTime['TJOBDOC'] := cJobTime
						Else
							ConOut(CRLF + "["+ cLckAuxNam  + "][ERROR] " + oDocSer:errorMessage)
							lError	:= .T.
						EndIf
						UnLockByName(cLckAuxNam, .T./*lEmpresa*/, .F./*lFilial*/ )
					Else
						ConOut(CRLF + "["+ cLckAuxNam + "] Running on another thread" )	
					EndIf
				EndIf
				// inicia o job de pedidos
				If lProcPed
					cJobTime:= updTime()
					cLckAuxNam	:= cLockName + ' - ORDER'
					If LockByName( cLckAuxNam, .T./*lEmpresa*/, .F./*lFilial*/ )
						cStartTime := Time()
						cFnc := 'gfin.job.OrdersBalance():new()'
						oOrders := &cFnc
						oOrders:setLastDateTime(jJobTime['TJOBORD'])
						oOrders:setCurrentDateTime(cJobTime)
						oOrders:processOrders()
						If oOrders:isOK()
							ConOut(CRLF + "["+ cLckAuxNam + "] Orders processing time: "+ ElapTime(cStartTime, Time()))
							ConOut("["+ cLckAuxNam + "] Orders updated: "+ cValToChar(oOrders:getInserts()))
							jNewJTime['TJOBORD'] := cJobTime
						Else
							ConOut(CRLF + "["+ cLckAuxNam + "][ERROR] " + oOrders:getErrorMessage())
							lError	:= .T.
						EndIf
						UnLockByName(cLckAuxNam, .T./*lEmpresa*/, .F./*lFilial*/ )
					Else
						ConOut(CRLF + "["+ cLckAuxNam + "] Running on another thread" )
					EndIf
				EndIf

				updTfcJob(jNewJTime)
				If !lError
					ConOut(CRLF + "["+ cLockName + "] finished. Duration: "+ ElapTime(cStartJob, Time()))
				Else
					ConOut(CRLF + "["+ cLockName + "] finished with error"+ ElapTime(cStartJob, Time()))
				EndIf
			Else
				FwLogMsg('ERROR',, "FINA711", "FINA711", "", 'Schedule', "Scheduling with more than one branch registered, or unspecified branch. Adjust the schedule to run only one branch." )
			EndIf
		EndIf
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc } updTime
	@description Atualiza a string de data do schedule.
	@return cJobTime, char, devolve a string formatada.
	@author Luiz Nai
	@since 30/10/2024
/*/
//-------------------------------------------------------------------
Function updTime()
	Local cJobTime As Character
	If FindFunction("gfin.util.GetDBTimeStamp")
		cJobTime := &("gfin.util.GetDBTimeStamp(TcGetDB())")
	Else
		cJobTime := FWTimeStamp(6, DATE(), TIME())
	EndIf

	cJobTime := StrTran(cJobTime, 'T', ' ')
	cJobTime := StrTran(cJobTime, 'Z', '')
return cJobTime

//-------------------------------------------------------------------
/*/{Protheus.doc } updTfcJob
	@description Atualiza o conteúdo do parâmetro MV_TFCJOBT, tomando cuidado para não sobrepor
	uma alterção que pode ter ocorrido em outra tarefa executada em paralelo.
	@param jValue, json, Valores atualizados para o parâmetro MV_TFCJOBT
	@author Guilherme de Sordi / Luiz Nai
	@since 01/10/2024
/*/
//-------------------------------------------------------------------
Static Function updTfcJob(jValue as json)
	Local jNewValue	As Json

	if empty(jValue:getNames())
		return
	endIf
	
	jNewValue := getTfcJob()

	if jValue:HasProperty('TJOBORD')
		jNewValue['TJOBORD'] := jValue['TJOBORD']
	endIf
	if jValue:HasProperty('TJOBDOC')
		jNewValue['TJOBDOC'] := jValue['TJOBDOC']
	endIf
	PutMv("MV_TFCJOBT", jNewValue:toJson())
return

//-------------------------------------------------------------------
/*/{Protheus.doc } getTfcJob
	@description Carrega para um JSON o conteúdo do parâmetro MV_TFCJOBT (Data da última execução do job TFC).
	Contém proteção para o caso do parâmetro ainda estar no formato antigo (isto é, uma string com a data da última execução em vez
	de um JSON separando títulos e pedidos).
	Quando uma das propriedades não existe, ou o parâmetro não existe, é definido como padrão
	o valor " " (string com um espaço em branco), porque é isso o que espera receber
	o método setLastUpdateDate() no cenário em que ele tem que processar tudo.
	@return jLastExec, json, Contém data e hora da última execução do job, com as propriedades TJOBDOC e TJOBORD
	@author guilherme.sordi@totvs.com.br
	@since 01/10/2024
/*/
//-------------------------------------------------------------------
Static Function getTfcJob() as json
	local jLastExec as json
	local jMVContent as json
	local cMVContent as character
	
	jLastExec := JsonObject():new()	
	jLastExec['TJOBDOC'] := " "
	jLastExec['TJOBORD'] := " "

	jMVContent := JsonObject():new()

	cMVContent := GetMV("MV_TFCJOBT",,'')

	If !Empty(cMVContent)
		If Empty(jMVContent:FromJson(cMVContent))
			If jMVContent:HasProperty("TJOBDOC")
				jLastExec['TJOBDOC'] := jMVContent['TJOBDOC']
			EndIf
			If jMVContent:HasProperty("TJOBORD")
				jLastExec['TJOBORD'] := jMVContent['TJOBORD']
			EndIf
		Else
			jLastExec['TJOBDOC'] := cMVContent
			jLastExec['TJOBORD'] := cMVContent
		EndIf
	EndIf
Return jLastExec

//-------------------------------------------------------------------
/*/{Protheus.doc } FinBulkFun
	Realiza a inserção de dados na tabela

	@param cAls, character, tabela do banco em que os dados serão inseridos
	@param numrec , numeric, numero de registro para realização do commit
	@param cAlsTmp , character, temporária com os dados para inserção
		(dados não duplicados)
	@param aFields, array, estrutura de campos da temporária
	@param nTotRecs, numeric, total de registros inseridos na tabela
	@param cFilOri, character, campo _FILORI da tabela (caso haja)

	@return  lRet, logical, define se foi possível a execução do FWBulk

@author Rodrigo Oliveira
@since jun|2024
/*/
//-------------------------------------------------------------------
Function FinBulkFun(cAls As Character, numrec As Numeric, cAlsTmp As Character, aFields As Array, nTotRecs As Numeric, cFilOri As Character) As Logical
  	Local cFilReg		As Character
	Local oBulk			As Object
	Local nX			:= 0 As Numeric
	Local nTamFlds		:= 0 As Numeric
	Local lRet			As Logical
	Local lFilOrig		As Logical
	Local aArea			As Array
	Local aTmpArea		As Array

	Default cAls		:= ""
	Default cAlsTmp		:= ""
	Default cFilOri		:= ""
	Default aFields		:= {}
	Default nTotRecs	:= 0

	lRet		:= .F.
	lFilOrig	:= !Empty(cFilOri)
	
	aArea 		:= GetArea(cAls)
	aTmpArea	:= GetArea(cAlsTmp)

  	// inserir daqui os dados na tabela
	oBulk := FindTcRecord():New(RetSqlName(cAls), numrec)
	
	If oBulk:lUseBulk .And. !Empty(cAls) .And. !Empty(cAlsTmp)
		lRet := .T.
		nTamFlds	:= Len(aFields)
		If !Empty(cAlsTmp)
			(cAlsTmp)->(DbGoTop())
			While !(cAlsTmp)->(Eof())
				For nX := 1 to nTamFlds
					If lFilOrig .And. '_FILIAL' $ aFields[nX][1]
						cFilReg	:= FWxFilial(cAls, (cAlsTmp)->&cFilOri)
						oBulk:setValue(aFields[nX][1], cFilReg)
					Else
						oBulk:setValue(aFields[nX][1], (cAlsTmp)->&(aFields[nX][1]))
					EndIf
				Next nX
				oBulk:AddBulk()
				nTotRecs++
				(cAlsTmp)->(DbSkip())
			EndDo
		EndIf

		oBulk:ExecFlush()
		oBulk:Clean()
		oBulk:Destroy()

		RestArea(aTmpArea)
		RestArea(aArea)
		
		FwFreeArray(aFields)
		FwFreeArray(aTmpArea)
		FwFreeArray(aArea)
		
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
	Execucao da rotina via Schedule.
	@return  aParam
/*/
//-------------------------------------------------------------------
Static Function SchedDef()
	Local aParam := {}

	aParam := 	{"P"	,;	//Tipo R para relatorio P para processo
				"FIN711",;	//Nome do grupo de perguntas (SX1)
				Nil		,;	//cAlias (para Relatorio)
				Nil		,;	//aArray (para Relatorio)
				Nil		}	//Titulo (para Relatorio)
Return aParam
