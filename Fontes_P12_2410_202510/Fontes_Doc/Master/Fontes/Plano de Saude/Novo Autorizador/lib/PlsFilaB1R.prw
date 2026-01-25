#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} Fila Banco de Dados
Classe da engine de fila do processamento na tabela B1R

@author    victor.silva
@version   V12
@since     20210817
/*/
class PlsFilaB1R from CenFilaBD
    
    Method New() Constructor
    Method setEndProc()
    Method getDbRecno()

EndClass

Method New() class PlsFilaB1R
    _Super:new(PlsCltB1R():new())
return self

Method setEndProc(status) Class PlsFilaB1R
    self:oCollection:atuStatusByRecno(status)
    self:oCollection:setEndProc(self:oCollection:getDbRecno())
Return
