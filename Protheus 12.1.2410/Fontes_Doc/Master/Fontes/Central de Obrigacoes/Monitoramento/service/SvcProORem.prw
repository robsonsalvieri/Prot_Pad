#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcProORem()
    
    Local oSvcProORem := SvcProORem():New()
    oSvcProORem:run()
    FreeObj(oSvcProORem)
    oSvcProORem := nil

return

/*/{Protheus.doc} 
    Job que processa as guias de Outras Remunerações que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobProORem(cEmp, cFil)
    Local oSvcProORem := nil
	rpcSetType(3)    
	rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    oSvcProORem := SvcProORem():New()
    If oSvcProORem:beforeProc()
        oSvcProORem:setProcId(ThreadId())
        While !KillApp() .and. oSvcProORem:keepProc()
            oSvcProORem:logMsg("W","vai processar: procNextMsg")
            oSvcProORem:procNextMsg()
        EndDo
    EndIf

    oSvcProORem:destroy()
    FreeObj(oSvcProORem)
    oSvcProORem := nil
    DelClassIntf()
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que processa as guias de fornecimento direto que chegaram via API
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcProORem From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcProORem
    _Super:New()
    self:cFila  := "FILA_PROC_OUTRAS_REM"
    self:cJob   := "JobProORem"
    self:cObs   := "Processa guias de Outras Remunerações da API"
    self:oFila  := CenFilaBd():New(CenCltB2V():New())
    self:oProc  := CenPrMoRem():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcProORem
    self:oProc:cCodOpe := oObj:getValue("operatorRecord")
    self:oProc:cSeqGui := oObj:getValue("formSequential")
    self:oProc:proRemuAPI(oObj)
Return