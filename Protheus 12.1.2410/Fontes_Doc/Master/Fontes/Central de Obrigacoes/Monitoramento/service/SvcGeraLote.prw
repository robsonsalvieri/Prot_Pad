#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcGeraLote()
    
    Local oSvcGeraLote := SvcGeraLote():New()
    oSvcGeraLote:run()
    FreeObj(oSvcGeraLote)
    oSvcGeraLote := nil

return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Job que processa as guias que chegaram via API
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobGeraLote(cEmp, cFil, lJob, cCodOpe)
    Local oSvcGeraLote  := {}
    Default lJob    := .T.
    Default cCodOpe := ""

	If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf

    oSvcGeraLote := SvcGeraLote():New()
    oSvcGeraLote:setCodOpe(cCodOpe)
    If oSvcGeraLote:beforeProc()
        oSvcGeraLote:logMsg("W","vai gerar os lotes")
        oSvcGeraLote:runProc()
        oSvcGeraLote:logMsg("W","geração de lotes concluída")
    EndIf
    oSvcGeraLote:destroy()
    FreeObj(oSvcGeraLote)
    oSvcGeraLote := nil

    DelClassIntf()
Return

/*/{Protheus.doc} 
    Serviço de validação em grupo das guias de monitoramento tiss
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcGeraLote From Service
	   
    Method New() 
    Method runProc()
    
EndClass

Method New() Class SvcGeraLote
    _Super:New()
    self:cFila := "FILA_VLD_GERA_LOTE"
    self:cJob := "JobGeraLote"
    self:cObs := "Gera os lotes para o XML"
    self:oFila := nil
    self:oProc := CenPrMoLot():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcGeraLote
    self:oProc:cCodOpe := self:cCodOpe
    self:oProc:procAddLot()
Return