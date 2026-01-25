#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcImpXTR()
    
    Local oSvcImpXTR := SvcImpXTR():New()
    oSvcImpXTR:run()
    FreeObj(oSvcImpXTR)
    oSvcImpXTR := nil

return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Job que processa as guias que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobImpXTR(cEmp,cFil,lJob,cCodOpe)
    Local oSvcImpXTR  := {}
    Default lJob    := .T.
    Default cCodOpe := ""

	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    oSvcImpXTR := SvcImpXTR():New()
    oSvcImpXTR:logMsg("W","vai importar os arquivos XTR")
    oSvcImpXTR:runProc()
    oSvcImpXTR:logMsg("W","importação de arquivos XTR concluída")
    oSvcImpXTR:destroy()
    FreeObj(oSvcImpXTR)
    oSvcImpXTR := nil

    DelClassIntf()
Return

/*/{Protheus.doc} 
    Serviço de validação em grupo das guias de monitoramento tiss
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcImpXTR From Service

    Method New() 
    Method runProc()
EndClass

Method New() Class SvcImpXTR
    _Super:New()
    self:cFila := "FILA_IMP_XTR"
    self:cJob := "JobImpXTR"
    self:cObs := "Importa os arquivos XTR do monitoramento"
    self:oFila := nil
    self:oProc := CenMonXTR():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcImpXTR
    self:oProc:procLote()
Return