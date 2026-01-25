#include 'protheus.ch'

Function TAFGRSOBS(aWizard, aFilial, cDatIni, cDatFim, cCabecalho)

Local cTxtSys  	as char
Local nHandle   as numeric
Local cREG 		as char
Local lFound    as logical
Local cStrTxt   as char
Local nI	    as numeric
Local aLinhas   as array
Local cLinha	as char
Local nCont     as numeric

Begin Sequence

	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle   	:= MsFCreate( cTxtSys )
	cREG		:= "OBS"
	lFound      := .T.
	cLinha   	:= ""
	nCont       := 0
	aLinhas 	:= {}

	cObs := Alltrim(aWizard[1][13])

	While Len(cObs) > 0
		nCont++

		If(nCont == 50)
			aAdd(aLinhas,{nCont, cLinha})
			cLinha := ""
			nCont  := 0
		EndIf

		If Len(cObs) > 80
			cLinha += substr(cObs, 1, 80)
			cObs := substr(cObs, 81, Len(cObs))
		Else
			cLinha += substr(cObs, 1, Len(cObs)) + space(80 - Len(cObs))
			aAdd(aLinhas,{nCont, cLinha})
			cObs := ""
		EndIf
	EndDo

	For nI := 1 To Len(aLinhas)
		cStrTxt := cCabecalho
		cStrTxt += StrZero(++nSeqGIARS,4)
		cStrTxt += "OBS "
		cStrTxt += StrZero(aLinhas[nI][1], 2, 0)
		cStrTxt += aLinhas[nI][2]
		cStrTxt += CRLF
		WrtStrTxt( nHandle, cStrTxt)
	Next

	GerTxtGRS( nHandle, cTxtSys, aFilial[1] +"_" + cReg)

Recover
	lFound := .F.

End Sequence


Return

