#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Serviço de validação em grupo das guias de fornecimento direto
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlGrFDi From Service
	   
    Method New() 
    Method runProc()
    
EndClass

Method New() Class SvcVlGrFDi
    _Super:New()
    self:cFila := "FILA_VLD_GUI_FDIR_GRP"
    self:cJob := "JobVlGrFDi"
    self:cObs := "Validação em grupo fornecimento direto"
    self:oFila := CenFilaBd():New(CenCltBVQ():New())
    self:oProc := CenVldFDir():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcVlGrFDi
    self:oProc:setOper(self:cCodOpe)
    self:oProc:vldGrupo(self:oFila:oCollection)
Return