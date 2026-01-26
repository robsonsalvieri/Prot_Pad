#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcGerXTE()
    
    Local oSvcGerXTE := SvcGerXTE():New()
    oSvcGerXTE:run()
    FreeObj(oSvcGerXTE)
    oSvcGerXTE := nil

return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Job que processa as guias que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobGerXTE(cEmp,cFil,lJob,cCodOpe,cCodObrig,cAno,cMes,cLote)
    Local oSvcGerXTE  := {}
    Default lJob    := .T.
    Default cCodOpe := ""
    Default cCodObrig := ""
    Default cAno  := ""
    Default cMes  := ""
    Default cLote  := ""

	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    oSvcGerXTE := SvcGerXTE():New()
    oSvcGerXTE:setCodOpe(cCodOpe)
    oSvcGerXTE:setCdObrig(cCodObrig)
    oSvcGerXTE:setAno(cAno)
    oSvcGerXTE:setMes(cMes)
    oSvcGerXTE:setLote(cLote)
   
    If oSvcGerXTE:beforeProc()
        oSvcGerXTE:logMsg("W","vai gerar os arquivos XTE")
        oSvcGerXTE:runProc()
        oSvcGerXTE:logMsg("W","geração de arquivos XTE concluída")
    EndIf
    oSvcGerXTE:destroy()
    FreeObj(oSvcGerXTE)
    oSvcGerXTE := nil

    DelClassIntf()
Return

/*/{Protheus.doc} 
    Serviço de validação em grupo das guias de monitoramento tiss
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcGerXTE From Service

    Data cCodObrig as String
    Data cAno as String
    Data cMes as String
    Data cLote as String

    Method New() 
    Method runProc()
    Method run(cCodOpe,cCodObrig,cAno,cComp)
    Method setCdObrig(cCodObrig)
    Method setAno(cAno)
    Method setMes(cMes)
    Method setLote(cLote)
EndClass

Method New() Class SvcGerXTE
    _Super:New()
    self:cFila := "FILA_VLD_GERA_XTE"
    self:cJob := "JobGerXTE"
    self:cObs := "Gera os arquivos XTE do monitoramento"
    self:oFila := nil
    self:oProc := CenGerXTE():New()
    self:cCodObrig := ""
    self:cAno := ""
    self:cMes := ""
    self:cLote := ""
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcGerXTE
    self:oProc:cCodOpe   := self:cCodOpe
    self:oProc:cCodObrig := self:cCodObrig
    self:oProc:cAno      := self:cAno
    self:oProc:cMes      := self:cMes
    self:oProc:cCodLote  := self:cLote

    self:oProc:gerArq()
Return

Method run(cCodOpe,cCodObrig,cAno,cMes,cLote) Class SvcGerXTE
    Local cCodOpe := MV_PAR01
    StartJob(self:cJob, GetEnvServer(), .F., cEmpAnt, cFilAnt, .T., cCodOpe,cCodObrig,cAno,cMes,cLote)
return

Method setCdObrig(cCodObrig) Class SvcGerXTE
    self:cCodObrig := cCodObrig
Return

Method setAno(cAno) Class SvcGerXTE
    self:cAno := cAno
Return

Method setMes(cMes) Class SvcGerXTE
    self:cMes := cMes
Return

Method setLote(cLote) Class SvcGerXTE
    self:cLote := cLote
Return