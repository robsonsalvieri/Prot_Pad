#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico no server
    @type  Function
    @author everton.mateus
    @since 09/12/2019
/*/
Main Function SvcVlInFDi()
    
    Local aSvcVldr  := {}
    Local nLen      := 0
    Local nVldr     := 0

    aSvcVldr := {;
                    SvcVlInFDi():New(),;
                    SvcVlItFDi():New();
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
Function JobVlInFDi(cEmp, cFil, lJob, cCodOpe)
    Local oSvc := SvcVlInFDi():New()
    Default cEmp := cEmpAnt
    Default cFil := cFilAnt
    Default lJob := .T.
    oSvc:setCodOpe(cCodOpe)
    JobVldInMon(cEmp, cFil, lJob, oSvc)
Return

Static Function SchedDef()
Return { "P","PLSVALSIB",,{},""}

/*/{Protheus.doc} 
    Servico que valida individualmente os itens das guias de fornecimento direto
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlInFDi From Service
	   
    Method New() 
    Method runProc(oObj)
    
EndClass

Method New() Class SvcVlInFDi
    _Super:New()
    self:cFila := "FILA_VLD_GUI_FOR_DIR_IND"
    self:cJob := "JobVlInFDi"
    self:cObs := "Valida indiv itens de fornecimento direto"
    self:oFila := CenFilaBd():New(CenCltBVQ():New())
    self:oProc := CenVldFDir():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc(oObj) Class SvcVlInFDi
	self:oProc:setEntity(oObj)
    self:oProc:vldIndiv(self:oFila:oCollection)
Return