#INCLUDE "PROTHEUS.CH"

Function GtpxRJPer(dDtIni, cHrIni, dDtFim, cHrFim)
Local aRetorno    	:= {}
Local cDataHoraIni  := ""
Local cDataHoraFim 	:= ""
Local cIntervIni  	:= ""
Local cIntervFim  	:= ""
Local cSomaTempo	:= ""

Default dDtIni      := dDataBase-1
Default cHrIni      := '00:00'
Default dDtFim      := dDataBase-1
Default cHrFim      := '23:59'

cDataHoraIni := DtoS(dDtIni) + StrTran(cHrIni,":","")
cDataHoraFim := DtoS(dDtFim) + StrTran(cHrFim,":","")

cIntervIni  	:= cDataHoraIni

While cIntervFim < cDataHoraFim

	cSomaTempo := IncTime(SubStr(cIntervIni, 9,2)+':'+SubStr(cIntervIni,11,2),0,20,0)

	If cSomaTempo > '23:59'
		cSomaTempo := AllTrim(StrZero(Val(SubStr(cSomaTempo,1,2)) - 24,2) + SubStr(cSomaTempo,3,3))
		cIntervFim := DtoS(DaySum(StoD(Substr(cIntervIni,1,8)),1)) + StrTran(cSomaTempo,":","")
	Else
		cIntervFim := SubStr(cIntervIni,1,8) + StrTran(Substr(cSomaTempo,1,5),":","")
	Endif

	If cIntervFim > cDataHoraFim
		cIntervFim := cDataHoraFim
	Endif

	aAdd(aRetorno, {Substr(cIntervIni,3,len(cIntervIni)), Substr(cIntervFim,3,len(cIntervFim))})

	cIntervIni := cIntervFim

	cSomaTempo := IncTime(SubStr(cIntervIni, 9,2)+':'+SubStr(cIntervIni,11,2),0,1,0)

	If cSomaTempo > '23:59'
		cSomaTempo := AllTrim(StrZero(Val(SubStr(cSomaTempo,1,2)) - 24,2) + SubStr(cSomaTempo,3,3))
		cIntervIni := DtoS(DaySum(StoD(Substr(cIntervIni,1,8)),1)) + StrTran(cSomaTempo,":","")
	Else
		cIntervIni := SubStr(cIntervIni,1,8) + StrTran(Substr(cSomaTempo,1,5),":","")
	Endif

Enddo

Return aRetorno
