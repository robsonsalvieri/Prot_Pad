#include 'protheus.ch'
#include 'fwschedule.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PrjSched
Classe responsável pela criação de agendamentos do schedule
 
@since 20/03/2020
/*/
//-------------------------------------------------------------------
Class PrjSched FROM LongNameClass
    
    Data cFunction
    Data cDescricao
    Data cUserID
    Data cParam
    Data cPeriod
    Data cTime
    Data cEnv
    Data cEmpFil
    Data cStatus
    Data cPergunte
    Data dDate
    Data nModule
    Data aParamDef
    Data oSchdParam
    Data oSchdSource
    Data oDASchedule

    Method New()
    Method destroy()
    Method setFunc(cFunction)
    Method getFunc()
    Method setDescricao(cDescricao)
    Method getDescricao()
    Method setUserId(cUserID)
    Method setParam(cParam)
    Method setPeriod(cPeriod)
    Method setTime(cTime)
    Method setEnv(cEnv)
    Method setEmpFil(cEmp, cFil)
    Method setStatus(cStatus)
    Method setPergunte(cPergunte)
    Method setMvParams(aMvParams)
    Method setDate(dDate)
    Method setModule(nModule)
    Method setParamDef(aParamDef)
    Method createSched()
    Method insSched()
    Method delSched(cSchedID)
    Method bscSched(cFunction, cDescricao)

EndClass

Method New() Class PrjSched
    self:cFunction  := ""
    self:cUserID    := "000000"
    self:cParam     := ""
    self:cPeriod    := ALWAYS
    self:cTime      := "00:00"
    self:cEnv       := Upper(GetEnvServer())
    self:cEmpFil    := "T1/M SP 01;"
    self:cStatus    := SCHD_ACTIVE
    self:dDate      := Date()
    If Type("nModulo") == "N"
        self:nModule    := nModulo
    Else
        self:nModule    := 33
    EndIf
    self:aParamDef  := {}
    self:oSchdSource := FwSchdSourceInfo():New()
    self:oDASchedule := FWDASchedule():new()
    self:oSchdParam := FwSchdParam():New()
    self:oSchdParam:oFwSchdSourceInfo := self:oSchdSource
Return

Method destroy() Class PrjSched
    If !Empty(self:oSchdSource)
        FreeObj(self:oSchdSource)
        self:oSchdSource := nil
    EndIf
    If !Empty(self:oSchdParam)
        FreeObj(self:oSchdParam)
        self:oSchdParam := nil
    EndIf
Return

Method setFunc(cFunction) Class PrjSched
    self:cFunction := cFunction
Return

Method getFunc() Class PrjSched
Return self:cFunction

Method setDescricao(cDescricao) Class PrjSched
    self:cDescricao := cDescricao
Return

Method getDescricao() Class PrjSched
Return self:cDescricao

Method setUserId(cUserID) Class PrjSched
    self:cUserID := cUserID
Return

Method setParam(cParam) Class PrjSched
    self:cParam := cParam
Return

Method setPeriod(cPeriod) Class PrjSched
    self:cPeriod := cPeriod
Return

Method setTime(cTime) Class PrjSched
    self:cTime := cTime
Return

Method setEnv(cEnv) Class PrjSched
    self:cEnv := cEnv
Return

Method setEmpFil(cEmp, cFil) Class PrjSched
    self:cEmpFil := cEmp + IIf(!Empty(cFil),"/"+cFil,"") + ";"
Return

Method setStatus(cStatus) Class PrjSched
    self:cStatus := cStatus
Return

Method setPergunte(cPergunte) Class PrjSched
    self:oSchdSource:aOrdem := {}
    self:oSchdSource:cPergunte := cPergunte
    self:oSchdSource:cTipo := "P"
    self:oSchdSource:cTitulo := cPergunte
Return

Method setMvParams(aMvParams) Class PrjSched
    self:oSchdParam:aMvParams := aMvParams
    self:setParam(self:oSchdParam:toXML())
Return

Method setDate(dDate) Class PrjSched
    self:dDate := dDate
Return

Method setModule(nModule) Class PrjSched
    self:nModule := nModule
Return

Method setParamDef(aParamDef) Class PrjSched
    self:aParamDef := aParamDef
Return

Method createSched() Class PrjSched
    self:delSched(self:bscSched(self:cFunction, self:cDescricao))
    self:insSched()
Return

Method insSched() Class PrjSched
    Local oSchedule 	:= FWVOSchedule():new()
    
    oSchedule:cID          := self:oDASchedule:getNextID()
    oSchedule:cFunction    := self:cFunction
    oSchedule:cDescricao   := self:cDescricao
    oSchedule:cUserID 	   := self:cUserID
    oSchedule:cParam 	   := self:cParam
    oSchedule:cPeriod 	   := self:cPeriod
    oSchedule:cTime 	   := self:cTime
    oSchedule:cEnv 	       := self:cEnv
    oSchedule:cEmpFil 	   := self:cEmpFil
    oSchedule:cStatus 	   := self:cStatus
    oSchedule:dDate 	   := self:dDate
    oSchedule:nModule 	   := self:nModule

    self:oDASchedule:insertSchedule( oSchedule , .T.)

    oSchedule:reset()
    FreeObj(oSchedule)
    oSchedule := nil

Return

Method delSched(cSchedID) Class PrjSched
    Default cSchedID := ""
    If !Empty(cSchedID)
        FWDelSchedule(cSchedID)
    EndIf
Return

Method bscSched(cFunction, cDescricao) Class PrjSched 
    Local nSched := 0
    Local cId := ""
    Local aSched     := self:oDASchedule:ReadSchedules()
    Local nLenSched := Len(aSched)

    For nSched := 1 To nLenSched
        If Pad(aSched[nSched]:cFunction,20) == Pad(cFunction,20) .And. Pad(aSched[nSched]:cDescricao,60) == Pad(cDescricao,60)
            cID := aSched[nSched]:cID
            Exit
        EndIf
    Next nSched
Return cID                                                                                                                                            
