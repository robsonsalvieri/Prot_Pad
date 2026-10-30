#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#include "RU04R01.CH"

/*
Autor:			Anastasiya Kulagina
Data:						31/10/2017
Last Update and author		09/06/2022 Artem Nikitenko
Description: Function for report M-11 print form
*/

Function RU04R01()

	Local oRpt as object
	Local lRet as logical
	
	lRet:=.T.
	if FwIsInCallStack('MATA311') .and. NNS->NNS_STATUS == '1'
		Help( ' ',1,STR0006,,STR0007,1,0) //not correct status for M11
		lRet:=.F.
	else
		//user edition of M11
		if ExistBlock("RuEBirtS")
			lRet:= Execblock("RuEBirtS",.F.,.F.,{'M11','RU04R01'})
		endif
		//standard edition of M11
		if lRet
			DEFINE REPORT oRpt NAME RU04R01_M11 TITLE "M-11"
			ACTIVATE REPORT oRpt
		endif
	endif
	
Return Nil
// Russia_R5                   
//Merge Russia R14 
                   
                   
