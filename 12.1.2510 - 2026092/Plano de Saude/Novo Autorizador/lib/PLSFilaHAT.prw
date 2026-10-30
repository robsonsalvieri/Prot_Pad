#INCLUDE "TOTVS.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fila Banco de Dados
Classe da engine de fila do processamento em uma tabela de entidade que será usada como fila

@author    everton.mateus
@version   V12
@since     06/12/2019
/*/
class PLSFilaHAT
    
    Data cError
	Data cProcId
	Data oCollection
	Data cCodOpe

    Method New(oCollection) Constructor
    Method setProcId(cProcId)
    Method setCodOpe(cCodOpe)
    Method checkQueue()
    Method setupQueue()
    Method lock(lBloq)
    Method getMsg()
    Method getNext()
    Method setEndProc()
    Method setExpired()

EndClass

Method New(oCollection) class PLSFilaHAT
    self:oCollection := oCollection
    self:cError		:= ""
return self

Method setProcId(cProcId) Class PLSFilaHAT
    self:cProcId := cProcId
Return 

Method setCodOpe(cCodOpe) Class PLSFilaHAT
    self:cCodOpe := cCodOpe
Return

Method checkQueue() Class PLSFilaHAT
Return ChkFile(self:oCollection:getAlias())

Method setupQueue() Class PLSFilaHAT
Return ChkFile(self:oCollection:getAlias())

Method lock(lBloq) Class PLSFilaHAT
    Local lOk   := .T.

    If lBloq
        while lOk 
            If LockByName(self:oCollection:getAlias(), .T., .T.)
                lOk := .F.
            EndIf
        enddo
    Else
        UnlockByName(self:oCollection:getAlias(), .T., .T.)
    EndIf

return lOk

Method getMsg() Class PLSFilaHAT
    Local lRet := .F.
    
    self:setExpired()
    self:lock(.T.)
    self:oCollection:setValue("processId", self:cProcId)
    If self:oCollection:setProcessing()
        lRet := self:oCollection:getMessage()
    EndIf
    self:lock(.F.)
Return lRet

Method getNext() Class PLSFilaHAT
    Local oEntity := nil
    If self:oCollection:hasNext()
        oEntity := self:oCollection:getNext()
    EndIf
Return oEntity

Method setEndProc() Class PLSFilaHAT
Return self:oCollection:setEndProc(self:oCollection:getDbRecno())

Method setExpired() Class PLSFilaHAT
Return self:oCollection:setExpired()

