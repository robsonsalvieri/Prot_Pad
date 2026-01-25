#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcVlInGMo()
    Local aSvcVldr  := {}
    Local nLen      := 0
    Local nVldr     := 0

    aSvcVldr := {;
                    SvcVlInGMo():New(),;
                    SvcVlInItG():New(),;
                    SvcVlInPcG():New();
                    }
    nLen := Len(aSvcVldr)
    For nVldr := 1 to nLen
        aSvcVldr[nVldr]:run()
        aSvcVldr[nVldr]:destroy()
        FreeObj(aSvcVldr[nVldr])
        aSvcVldr[nVldr] := nil
    Next nVldr
    DelClassIntf()

return

/*/{Protheus.doc} 
    Chama a validação individual
    
    @type  Function
    @author everton.mateus
    @since 06/12/2019
/*/
Function JobVlInGMo(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvcVlInGMo():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    oSvc:setCodOpe(cCodOpe)
    JobVldInMon(cEmp, cFil, lJob, oSvc)
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico de validação individual do cabeçalho das guias do monitoramento tiss
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlInGMo From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcVlInGMo
    _Super:New()
    self:cFila := "FILA_VLD_GUI_MON_IND"
    self:cJob := "JobVlInGMo"
    self:cObs := "Validação indiv cabeçalho guias monitoramento"
    self:oFila := CenFilaBd():New(CenCltBKR():New())
    self:oProc := CenVldMGui():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcVlInGMo
	self:oProc:setEntity(oObj)
    self:oProc:vldIndiv(self:oFila:oCollection)
Return
