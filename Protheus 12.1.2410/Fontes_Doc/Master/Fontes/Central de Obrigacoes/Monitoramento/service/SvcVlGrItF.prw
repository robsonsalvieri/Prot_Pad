#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Serviço de validação em grupo dos itens das guias de fornecimento direto
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class SvcVlGrItF From Service
	   
    Method New() 
    Method runProc()
    
EndClass

Method New() Class SvcVlGrItF
    _Super:New()
    self:cFila := "FILA_VLD_GUI_ITEM_FDIR_GRP"
    self:cJob := "JobVlGrItF"
    self:cObs := "Valid. em grupo dos itens de fornecimento direto"
    self:oFila := CenFilaBd():New(CenCltBVT():New())
    self:oProc := CenVldItFDir():New()
    self:oCenLogger:setFileName(self:cJob)
Return self

Method runProc() Class SvcVlGrItF
    self:oProc:setOper(self:cCodOpe)
    self:oProc:vldGrupo(self:oFila:oCollection)
Return