#include 'protheus.ch'
#include 'fwschedule.ch'
#include 'FWMVCDEF.CH'

#DEFINE CMPCAMPO	1
#DEFINE CMPTIPO		2
#DEFINE CMPSIZE		3
#DEFINE CMPDECIMAL	4
#DEFINE CMPTITULO	5
#DEFINE CMPEXIBE	6
#DEFINE CMPOBRIG	7
#DEFINE CMPWHEN 	8

Static __cTabTmp := ""
Static __aCampos := {}

Class PrjWzPgScd From PrjWzPg
	Data oMark

	Method new(aDados) Constructor
	Method getTabFlds()
	Method getTabTemp()
	Method fillTabTemp()
	Method addLegend()
	Method vldNextAction()
	Method endProcess()
	Method checkAgent()
	Method criaSchedules()
	Method newSched()

EndClass

Method new(aDados) Class PrjWzPgScd
	_Super:new(aDados)
	self:cTitle 	:= "Schedules"
	self:cDescri 	:= "Schedules de Configuração"
Return self

Method getTabFlds() Class PrjWzPgScd
	
	If Empty(self:aCampos)
		//{CMPCAMPO,CMPTIPO,CMPSIZE,CMPDECIMAL,CMPTITULO,CMPEXIBE,CMPOBRIG,CMPWHEN}
		aAdd(self:aCampos,{"ID"			,"C",015,0,"Id"				,.F.,.F.,.F.})
		aAdd(self:aCampos,{"NAME"		,"C",020,0,"Nome"			,.T.,.F.,.F.})
		aAdd(self:aCampos,{"DESCRI"		,"C",060,0,"Descrição"		,.T.,.F.,.F.})
		aAdd(self:aCampos,{"HORA"		,"C",005,0,"Horario Exec."	,.T.,.T.,.T.})
		aAdd(self:aCampos,{"USRPERIOD"	,"C",600,0,"Periodicidade"	,.T.,.F.,.F.})
		aAdd(self:aCampos,{"PERIOD"		,"C",254,0,"Periodicidade"	,.F.,.F.,.F.})
		aAdd(self:aCampos,{"PARAMS"		,"M",254,0,"Parâmetros"		,.F.,.F.,.F.})
		aAdd(self:aCampos,{"PERGUNTE"	,"C",015,0,"Pergunte"		,.F.,.F.,.F.})
		aAdd(self:aCampos,{"ENVDOK"		,"C",002,0,""				,.F.,.F.,.F.})
		__aCampos := self:aCampos
	EndIf
	
Return self:aCampos

Method getTabTemp() Class PrjWzPgScd
	Local oTabTemp := _Super:getTabTemp()
	__cTabTmp := _Super:getTabTemp():getAlias()
Return oTabTemp

Method fillTabTemp() Class PrjWzPgScd
	Local nSchedule	:= 0
	Local cCodigo	:= ""
	Local nLenSched	:= Len(self:aDados)
	Local cTabTemp 	:= self:getTabTemp():getAlias()
	Local oDaoSched := FWDASchedule():New()
	Local oPrjSched := PrjSched():New()
	Local oSched	:= nil	
	self:nTotReg := nLenSched
	For nSchedule := 1 TO nLenSched
		cCodigo := oPrjSched:bscSched(self:aDados[nSchedule]["nome"],self:aDados[nSchedule]["descricao"])
		RecLock(cTabTemp,.T.)
		(cTabTemp)->ID 			:= AllTrim(Str(nSchedule))
		(cTabTemp)->NAME 		:= self:aDados[nSchedule]["nome"]
		(cTabTemp)->PERGUNTE	:= self:aDados[nSchedule]["pergunte"]
		(cTabTemp)->ENVDOK		:= "XX"
		if empty(cCodigo)
			(cTabTemp)->HORA 		:= self:aDados[nSchedule]["horaexec"]
			(cTabTemp)->DESCRI		:= self:aDados[nSchedule]["descricao"]
			(cTabTemp)->PERIOD		:= self:aDados[nSchedule]["periodicidade"]
			(cTabTemp)->USRPERIOD	:= PrjPctPeri((cTabTemp)->PERIOD)
			(cTabTemp)->PARAMS 		:= ""
		Else
			oSched := oDaoSched:getSchedule(cCodigo)
			(cTabTemp)->HORA 		:= oSched:getTime()
			(cTabTemp)->USRPERIOD	:= PrjPctPeri(oSched:getPeriod())
			(cTabTemp)->DESCRI 		:= oSched:getDescricao()
			(cTabTemp)->PERIOD 		:= oSched:getPeriod()
			(cTabTemp)->PARAMS 		:= oSched:getParam()
			FreeObj(oSched)
			oSched := nil
		EndIf
		(cTabTemp)->(msUnLock())
	Next nSchedule
	FreeObj(oDaoSched)
	oDaoSched := nil
	FreeObj(oPrjSched)
	oPrjSched := nil
Return

Method addLegend() Class PrjWzPgScd
	self:oMark:AddLegend("PrjLegePrm() == .F.", "RED", "Parâmetros do Schedule NÃO preenchidos")
	self:oMark:AddLegend("PrjLegePrm() == .T.", "GREEN", "Parâmetros do Schedule preenchidos")
Return

Method vldNextAction() Class PrjWzPgScd
	Local cTabTemp := self:getTabTemp():getAlias()
	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!Eof())
		If (cTabTemp)->ENVDOK == self:oMark:cMark .And. !(PrjLegePrm())
			MsgAlert("É necessário inserir os parâmetros dos Schedules com legenda vermelha")
			Return .F.
		EndIf
		(cTabTemp)->(dbSkip())
	Enddo
	self:oMark:Refresh(.T.)
Return .T.

Method endProcess() Class PrjWzPgScd
	Processa({|| self:checkAgent()}, "Verificando Agent" )
	Processa({|| self:criaSchedules()}, "Criando/Atualizando Schedules" )
Return

Method checkAgent() Class PrjWzPgScd
	Local aAgent   := {}
    local cID       := ""
    Local nAgent    := 0
    Local nLenAgent := 0
	Local oDAAgent 		:= FWDASCHDAGENT():NEW()
    Local oAgentCO      := FWCOSCHDAGENT():NEW()
    Local oAgentServ    := FWCOSCHDSERVICE():NEW()
    aAgent     			:= oDAAgent:ReadAgents()
    If Empty(aAgent)
		IncProc("Criando Agent Padrão...")
        oAgentCO:ADDAGENTDEFAULT()
        aAgent     := oDAAgent:ReadAgents()
		nLenAgent := len(aAgent)
		ProcRegua(nLenAgent)
		For nAgent := 1 To nLenAgent
			IncProc("Iniciando Agents...")
			cID := aAgent[nAgent]["cID"]
			oAgentServ:startAgent(cID)
		Next nLenAgent
    EndIf
Return

Method criaSchedules() Class PrjWzPgScd
	Local oPrjSched := Nil
	Local cTabTemp:= self:getTabTemp():getAlias()
	
	ProcRegua(self:nTotReg)
	(cTabTemp)->(DbGoTop())
	While (cTabTemp)->(!Eof())
		If (cTabTemp)->ENVDOK == self:oMark:cMark
			IncProc("Criando Schedule " + (cTabTemp)->NAME)
			oPrjSched := self:newSched()
    		oPrjSched:createSched()
			oPrjSched:destroy()
		EndIf
		(cTabTemp)->(dbSkip())
	Enddo
Return

Method newSched() Class PrjWzPgScd
    Local cTabTemp:= self:getTabTemp():getAlias()
	Local oPrjSched := PrjSched():New()
    Local cUserID := __cUserId
    Local cPeriod := (cTabTemp)->PERIOD
    Local cTime := (cTabTemp)->HORA
    Local cEnv := Upper(GetEnvServer())
    Local cEmp := cEmpAnt
    Local cFil := cFilAnt
    Local cStatus := SCHD_ACTIVE
    Local cPergunte := (cTabTemp)->PERGUNTE
    Local cDescricao := (cTabTemp)->DESCRI
    Local dDate := Date()
    Local aParamDef := {}
    Local cFunction := (cTabTemp)->NAME
	Local cParams := IIf(Empty( (cTabTemp)->PARAMS ), getDefParam(cTabTemp),(cTabTemp)->PARAMS )

    oPrjSched:setFunc(cFunction)
    oPrjSched:setDescricao(cDescricao)
    oPrjSched:setUserId(cUserID)
    oPrjSched:setPeriod(cPeriod)
    oPrjSched:setTime(cTime)
    oPrjSched:setEnv(cEnv)
    oPrjSched:setEmpFil(cEmp,cFil)
    oPrjSched:setStatus(cStatus)
    oPrjSched:setDate(dDate)
    oPrjSched:setModule(nModulo)
    oPrjSched:setParamDef(aParamDef)
    oPrjSched:setPergunte(cPergunte)
	oPrjSched:setParam(cParams)

Return oPrjSched

Function PrjLegePrm()
	Local lOk
	Local cTabTemp 	:= __cTabTmp
	If Empty(AllTrim((cTabTemp)->PARAMS)) .And. !Empty(AllTrim((cTabTemp)->PERGUNTE))
		lOk := .F.
	Else
		lOk := .T.
	EndIf
Return lOk

Function PrjPctPeri(cPeriod)
	Local cString := ""
	Local cSemAux := ""
	Local nI
	Local nExecs
	Default cPeriod := ""

	if !Empty(cPeriod)
		If SubStr(cPeriod,1,1) == "A"
			cString += "Sempre Ativo"
		Else
			nExecs := Val(StrTran(StrTran(SubStr(cPeriod,at("Execs",cPeriod) + 6, 4),")"),";"))
			cString += Str(nExecs) + space(1)
			cString += "vez"
			If nExecs > 1
				cString += "es"
			EndIf
			cString += " no dia, "
			If SubStr(cPeriod,at("Interval",cPeriod) + 9, 5) != "00:00"
				cString += "a cada " 
				cString += SubStr(cPeriod,at("Interval",cPeriod) + 9, 5) 
				cString += "hs, "
			EndIf
			Do Case
				Case SubStr(cPeriod,1,1) == "D"
					if SubStr(cPeriod,at("EveryDay",cPeriod) + 10, 1) == "T"
						cString += "todos os dias"
					ElseIf SubStr(cPeriod,at("EveryDay",cPeriod) + 10, 1) == "F"
						cString += "a cada " 
						cString += StrTran(StrTran(SubStr(cPeriod,at("Day",cPeriod) + 4, 3),")"),";") 
						cString += " dia"
						if StrTran(StrTran(SubStr(cPeriod,at("Day",cPeriod) + 4, 3),")"),";") != "1"
							cString += "s"
						EndIf
					EndIf
				Case SubStr(cPeriod,1,1) == "W"
					cString += "Semanalmente ("
						cSemAux := StrTran(SubStr(cPeriod,3, 21),".")
						For nI := 1 To Len(cSemAux)
							if SubStr(cSemAux,nI, 1) == "T"
								if Right(cString,1) != "("
									cString += ", "
								EndIf
								cString += DiaSemana(,3,nI)
							EndIf
						Next
					cString += ")"
				Case SubStr(cPeriod,1,1) == "M"
					cString += "Mensalmente no dia " 
					cString += StrTran(StrTran(SubStr(cPeriod,at("Day",cPeriod) + 4, 3),")"),";") 
					cString += " de cada mês"
					
				Case SubStr(cPeriod,1,1) == "Y"
					cString += "Anualmente no dia " 
					cString += StrTran(StrTran(SubStr(cPeriod,at("Day",cPeriod) + 4, 3),")"),";") 
					cString += " do mês de " 
					cString += MesExtenso(Val(StrTran(StrTran(SubStr(cPeriod,at("Month",cPeriod) + 6, 3),")"),";")))
			EndCase
			If !empty(at("End",cPeriod))
				cString += ". "
				cString += "Termina em "
				cString += cValToChar(Stod(SubStr(cPeriod,at("End",cPeriod) + 4, 8)))
			EndIf
		EndIf
	EndIf
return AllTrim(cString)

Function PrjWzScPar()
	Local cTabTemp:= __cTabTmp
	Local lUpdate := .T.
	Local lInsert := .T.
	Local lInterface := .T.
	Local oSchdSource := Nil
    Local oSchdParam := Nil
	Local cParams := ""
	Local cMemoparm := ""
	Local cStaticparam := ""
	Local cDevice := ""
	Local nOrder := 1
	Local cRotina := (cTabTemp)->NAME
	Local cFile := ""
	Local aParamdef := {}
	Local lSchedfromtreport := .F.
	Local cRet := ""
	
	If Empty((cTabTemp)->PARAMS)
		cParams := getDefParam(cTabTemp)
	Else
		cParams := (cTabTemp)->PARAMS
	EndIf
	cMemoparm := cParams
	cStaticparam := cParams
	If !isBlind()
		cRet := FWUISCHDPARAM(@cMemoparm,@cStaticparam,@lUpdate,@lInsert,@lInterface,@cParams,@cDevice,@nOrder,@cRotina,@cFile,@aParamdef,@lSchedfromtreport)
	EndIf
	If !Empty(cRet)
		(cTabTemp)->PARAMS	:= cRet
	EndIf

Return

Static Function getDefParam(cTabTemp)
	Local cParams := ""

	oSchdSource := FwSchdSourceInfo():New()
	oSchdParam := FwSchdParam():New()
	oSchdParam:oFwSchdSourceInfo := oSchdSource
	oSchdSource:cTipo := "P"
	oSchdSource:cPergunte := (cTabTemp)->PERGUNTE
	oSchdSource:cAlias := ""
	oSchdSource:aOrdem := {}
	oSchdSource:cTitulo := ""
	cParams := oSchdParam:toXML()
	FreeObj(oSchdSource)
	oSchdSource := nil
Return cParams

Function PrjWzScPer()
	Local cTabTemp	:= __cTabTmp
	Local dDate := dDataBase
	Local cTime := ""
	Local cPeriod := (cTabTemp)->PERIOD
	Local nOpc := 3
	Local lNoEndDate := .F.
	Local xRet := ""
	If !isBlind()
		xRet := FWSCHDRECURRENCE(@dDate,@cTime,@cPeriod,@nOpc,@lNoenddate)
	EndIf
	if !Empty(xRet)
		(cTabTemp)->PERIOD	:= xRet
		(cTabTemp)->USRPERIOD := PrjPctPeri(xRet)
	EndIf

Return

Static Function MenuDef()
	Local aRotina 	:= {}

	aAdd( aRotina, { "Alterar"			,'VIEWDEF.PrjWzPgScd' 	, 0 , MODEL_OPERATION_UPDATE	} )
	aAdd( aRotina, { "Parametros"		,'PrjWzScPar()' 		, 0 , MODEL_OPERATION_UPDATE	} )
	aAdd( aRotina, { "Periodicidade"	,'PrjWzScPer()' 		, 0 , MODEL_OPERATION_UPDATE	} )

Return aRotina

Static Function ModelDef()
	Local oModel 	:= MPFormModel():New( "PrjWzPgScd" ) 
	Local oStruTmp 	:= FWFormModelStruct():New()
	Local nField := 0
	Local nLenCmps := Len(__aCampos)
	Local aCampos := {}

	Local cTitulo	:= ""
	Local cTooltip	:= ""
	Local cIdField	:= ""
	Local cTipo		:= "C"
	Local nTamanho	:= 10
	Local nDecimal	:= 0
	Local bValid	:= {||.T.}
	Local bWhen		:= {||.T.}
	Local aValues	:= {}
	Local lObrigat	:= .T.
	Local bInit		:= {||}
	Local lKey		:= .F.
	Local lNoUpd	:= .F.
	Local lVirtual	:= .F.
	Local cValid	:= ""
	
	For nField := 1 to nLenCmps
		aAdd(aCampos, __aCampos[nField][CMPCAMPO])
		cTitulo	 := __aCampos[nField][CMPTITULO]
		cTooltip := __aCampos[nField][CMPTITULO]
		cIdField := __aCampos[nField][CMPCAMPO]
		cTipo	 := __aCampos[nField][CMPTIPO]
		nTamanho := __aCampos[nField][CMPSIZE]
		nDecimal := __aCampos[nField][CMPDECIMAL]
		lObrigat := __aCampos[nField][CMPOBRIG]
		oStruTmp:AddField(cTitulo, cTooltip, cIdField, cTipo, nTamanho, nDecimal, bValid, bWhen, aValues, lObrigat, bInit, lKey, lNoUpd, lVirtual, cValid)
	Next nField

	oStruTmp:AddTable(__cTabTmp, aCampos, "Schedules do Módulo")

	oModel:AddFields( 'WZMASTER', , oStruTmp )
	oModel:SetPrimaryKey({"ID"})
	oModel:GetModel( 'WZMASTER' ):SetDescription( "Schedules" ) 
	oModel:SetDescription( "Schedules" )

Return oModel

Static Function ViewDef()  
	Local oModel   := FWLoadModel( 'PrjWzPgScd' )
	Local oStruTmp := FWFormViewStruct():New()
	Local oView    := FWFormView():New()
	Local nField := 0
	Local nLenCmps := Len(__aCampos)

	Local cIdField		:= ""
	Local cOrdem		:= ""
	Local cTitulo		:= ""
	Local cDescric		:= ""
	Local aHelp			:= {}
	Local cType			:= ""
	Local cPicture		:= "@!"
	Local bPictVar		:= {||}
	Local cLookUp		:= ""
	Local lCanChange	:= .T.
	Local cFolder		:= ""
	Local cGroup		:= ""
	Local aComboValues	:= {}
	Local nMaxLenCombo	:= 0
	Local cIniBrow		:= ""
	Local lVirtual		:= .F.
	Local cPictVar		:= ""
	Local lInsertLine	:= .F.
	Local nWidth		:= 0

	For nField := 1 to nLenCmps
		If __aCampos[nField][CMPEXIBE]
			cIdField := __aCampos[nField][CMPCAMPO]
			cOrdem	 := Alltrim(Str(nField))
			cTitulo	 := __aCampos[nField][CMPTITULO]
			cDescric := __aCampos[nField][CMPTITULO]
			cType	 := __aCampos[nField][CMPTIPO]
			nWidth	 := __aCampos[nField][CMPSIZE]
			lCanChange := __aCampos[nField][CMPWHEN]
			oStruTmp:AddField(cIdField, cOrdem, cTitulo, cDescric, aHelp, cType, cPicture, bPictVar, cLookUp, lCanChange, cFolder, cGroup,aComboValues,nMaxLenCombo, cIniBrow, lVirtual, cPictVar,lInsertLine,nWidth)
		EndIf
	Next nField

	oView:SetModel( oModel )
	oView:AddField( 'PrjWzPgScd' , oStruTmp, 'WZMASTER' )     
	oView:CreateHorizontalBox( 'GERAL', 100 )
	oView:SetOwnerView( 'PrjWzPgScd' , 'GERAL'  )
	oView:SetCloseOnOK( { || .T. } )

Return oView
