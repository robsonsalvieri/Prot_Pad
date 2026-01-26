#INCLUDE "PROTHEUS.CH"

Function STFWCLimMemCache() ; Return

Class STFWCLimitedMemCache From STFWCMemCache
	Data nCacheLimit
	
	Method STFWCLimitedMemCache()
	Method Put(cKey, uData, nMinutesToExpire)
	Method LimitReached()
	Method ClearExpiredCache()	
EndClass

Method STFWCLimitedMemCache(nCacheLimit) Class STFWCLimitedMemCache
	Default nCacheLimit := 0
	Self:nCacheLimit := nCacheLimit
	_Super:STFWCMemCache()
Return

Method Put(cKey, uData, nMinutesToExpire) Class STFWCLimitedMemCache
	Local lRet	:= .F.
	If Self:LimitReached()
		If Self:ClearExpiredCache()
			lRet := _Super:Put(cKey, uData, nMinutesToExpire)
		EndIf
	Else
		lRet := _Super:Put(cKey, uData, nMinutesToExpire)
	EndIf
Return lRet

Method LimitReached() Class STFWCLimitedMemCache	
Return Self:nCacheLimit != 0 .And. Self:nCacheLimit <= Len(Self:aMemCache)

Method ClearExpiredCache() Class STFWCLimitedMemCache
	Local nCount	:= 0
	Local lRet		:= .F.
	
	For nCount := 1  To Len(Self:aMemCache)
		If !Self:IsValidCache(nCount)
			Self:RemoveByPos(nCount)
			lRet := .T.
			Exit
		EndIf
	Next	
Return lRet