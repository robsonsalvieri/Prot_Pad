#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcImpXTQ()
    
    Local oSvcImpXTQ := SvcImpXTQ():New()
    oSvcImpXTQ:run()
    FreeObj(oSvcImpXTQ)
    oSvcImpXTQ := nil

return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Job que processa as guias que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobImpXTQ(cEmp,cFil,lJob,cCodOpe)
    Local oSvcImpXTQ  := {}
    Default lJob    := .T.
    Default cCodOpe := ""

	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    oSvcImpXTQ := SvcImpXTQ():New()
    oSvcImpXTQ:logMsg("W","vai importar os arquivos XTQ")
    oSvcImpXTQ:runProc()
    oSvcImpXTQ:logMsg("W","importação de arquivos XTQ concluída")
    oSvcImpXTQ:destroy()
    FreeObj(oSvcImpXTQ)
    oSvcImpXTQ := nil

    DelClassIntf()
Return

/*/{Protheus.doc} 
    Serviço de validação em grupo das guias de monitoramento tiss
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcImpXTQ From Service

    Method New() 
    Method runProc()
EndClass

Method New() Class SvcImpXTQ
    _Super:New()
    self:cFila := "FILA_IMP_XTQ"
    self:cJob := "JobImpXTQ"
    self:cObs := "Importa os arquivos XTQ do monitoramento"
    self:oFila := nil
    self:oProc := CenMonXTQ():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcImpXTQ
    self:oProc:procLote()
Return