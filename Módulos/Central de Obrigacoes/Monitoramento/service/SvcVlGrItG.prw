#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Serviço de validação em grupo dos itens das guias de monitoramento tiss
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlGrItG From Service
	   
    Method New() 
    Method runProc()
    
EndClass

Method New() Class SvcVlGrItG
    _Super:New()
    self:cFila := "FILA_VLD_GUI_MON_GRP"
    self:cJob := "JobVlGrItG"
    self:cObs := "Valid. grupo dos itens das guias de monitoramento"
    self:oFila := CenFilaBd():New(CenCltBKS():New())
    self:oProc := CenVldItMGui():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcVlGrItG
    self:oProc:setOper(self:cCodOpe)
    self:oProc:vldGrupo(self:oFila:oCollection)
Return