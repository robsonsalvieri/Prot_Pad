#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Serviço de validação em grupo dos pacotes das guias de monitoramento tiss
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlGrPcG From Service
    Method New() 
    Method runProc()
EndClass

Method New() Class SvcVlGrPcG
    _Super:New()
    self:cFila := "FILA_VLD_PCT_GUI_MON_GRP"
    self:cJob := "JobVlGrPcG"
    self:cObs := "Valid. grupo de pacotes das guias de monitoramento"
    self:oFila := CenFilaBd():New(CenCltBKT():New())
    self:oProc := CenVldPcMGui():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcVlGrPcG
    self:oProc:setOper(self:cCodOpe)
    self:oProc:vldGrupo(self:oFila:oCollection)
Return