#INCLUDE "TOTVS.CH"

#define ARQUIVO_LOG	"monitoramento_svcprocpre.log"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcProcPre()
    
    Local oSvcProcPre := SvcProcPre():New()
    oSvcProcPre:run()
    FreeObj(oSvcProcPre)
    oSvcProcPre := nil

return

/*/{Protheus.doc} 
    Job que processa as guias de Valor Pre Estabelecido que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobProcPre(cEmp, cFil)
    Local oSvcProcPre := nil
	Local oCenLogger := CenLogger():New()    
	rpcSetType(3)    
	rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    oSvcProcPre := SvcProcPre():New()
    If oSvcProcPre:beforeProc()
        oSvcProcPre:setProcId(ThreadId())
        While !KillApp() .and. oSvcProcPre:keepProc()
            oCenLogger:SetfileName(ARQUIVO_LOG)
            oCenLogger:addLine("observacao", "Inicia o processo: procNextMsg")
	        oCenlogger:addLog()
            oCenLogger:flush()
            oSvcProcPre:procNextMsg()
        EndDo
    EndIf

    oSvcProcPre:destroy()
    oCenLogger:destroy()
    FreeObj(oSvcProcPre)
    FreeObj(oCenLogger)
    oSvcProcPre := nil
    oCenLogger := nil
    DelClassIntf()
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que processa as guias de Valor Pre Estabelecido que chegaram via API
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcProcPre From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcProcPre
    _Super:New()
    self:cFila  := "FILA_PROC_PRE"
    self:cJob   := "JobProcPre"
    self:cObs   := "Servico que processa as guias de Valor Pre Estabelecido que chegaram via API"
    self:oFila  := CenFilaBd():New(CenCltB2X():New())
    self:oProc  := CenPrMoPre():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcProcPre
    self:oProc:cCodOpe := oObj:getValue("operatorRecord")
    self:oProc:cSeqGui := oObj:getValue("formSequential")
    self:oProc:proRemuAPI(oObj)
Return