#Include 'protheus.ch'

Class PrjImpOut
	Data cErro
	Data oCache
	Data lSoInclui

	Method new()
	Method destroy()
	Method getError()
	Method setError(cErro)
	Method tryExec(lSuccess, cError, oExecutor)
	Method save(oEntity)

EndClass

Method new() Class PrjImpOut
	self:cErro := ""
	self:oCache := THashMap():New()
	self:lSoInclui := .T.
Return self

Method destroy() Class PrjImpOut
	if !Empty(self:oCache)
		self:oCache:clean()
		FreeObj(self:oCache)
		self:oCache := nil
	EndIf
Return

Method getError() Class PrjImpOut
Return self:cErro

Method setError(cErro) Class PrjImpOut
	self:cErro := cErro
Return

Method tryExec(lSuccess, cError, oExecutor) Class PrjImpOut
	if !lSuccess
		self:setError( IIf(Empty(cError),oExecutor:getError(),cError) )
	EndIf
Return lSuccess

Method save(oEntity) Class PrjImpOut
Return lSuccess
