#INCLUDE "TOTVS.CH"

Function STFWCMemCache() ; Return

Class STFWCMemCache
	Data aMemCache

	Method STFWCMemCache()	
	Method Put(cKey, uData, nMinutesToExpire)
	Method Contains(cKey)
	Method Get(cKey)
	Method Find(cKey)
	Method IsValidCache(nPos)
	Method Invalidate()
	Method Remove(cKey)
	Method RemoveByPos(nPos)
EndClass

Method STFWCMemCache() Class STFWCMemCache
	Self:aMemCache := {}
Return

Method Put(cKey, uData, nMinutesToExpire) Class STFWCMemCache
	Local oNow	:= Nil
	Local nPos :=0	
	Default nMinutesToExpire	:= -1
	
	If nMinutesToExpire > 0
		oNow := TMKDateTime():Now()
		oNow:PlusMinutes(nMinutesToExpire)
	EndIf
	
	nPos := AScan(Self:aMemCache, {|x| x[1] == cKey })
	If nPos > 0
		Self:aMemCache[nPos][2] := uData
		Self:aMemCache[nPos][3] := oNow
	Else
		AAdd(Self:aMemCache, {cKey, uData, oNow})
	EndIf
Return .T.

Method Contains(cKey) Class STFWCMemCache
Return IF(Self:Find(cKey) > 0, .T., .F.)

Method Get(cKey) Class STFWCMemCache
	Local nPos		:= 0
	Local uRet		:= Nil
	
	nPos := Self:Find(cKey)
	// Localizou a chave
	If nPos > 0
		// Verifica se o cache é válido
		If Self:IsValidCache(nPos)			
			uRet := Self:aMemCache[nPos][2]
		Else
			Self:RemoveByPos(nPos)		
		EndIf
	EndIf
Return uRet

Method Find(cKey) Class STFWCMemCache
	Local nPos := 0
	nPos := AScan(Self:aMemCache, {|x| x[1] == cKey })
Return nPos

Method IsValidCache(nPos) Class STFWCMemCache
	Local oNow		:= Nil
	Local lRet		:= .F.
	
	If Self:aMemCache[nPos][3] != Nil
		// Verifica se já expirou o cache
		oNow := TMKDateTime():Now()
		lRet := oNow:LessThan(Self:aMemCache[nPos][3])
	Else
		lRet := .T.
	EndIf
Return lRet

Method Invalidate() Class STFWCMemCache
	Self:aMemCache := {}
Return

Method Remove(cKey) Class STFWCMemCache
	Local nPos := 0
	nPos := AScan(Self:aMemCache, {|x| x[1] == cKey })
	If nPos > 0
		Self:RemoveByPos(nPos)		
	EndIf
Return

Method RemoveByPos(nPos) Class STFWCMemCache
	ADel(Self:aMemCache, nPos)
	ASize(Self:aMemCache, Len(Self:aMemCache)-1)
Return