#Include 'Protheus.ch'
#Include 'tdsBirt.ch'

/*
TORG-12
*/
Function RU05R01()
Local oRpt

if ExistBlock("RU05R01E")
    DEFINE REPORT oRpt NAME RU05R01E_TORG12 TITLE 'TORG12'
else
    DEFINE REPORT oRpt NAME RU05R01_TORG12 TITLE 'TORG12' 
endif

ACTIVATE REPORT oRpt
 
Return
// Russia_R5
                   
//Merge Russia R14 
                   
                   
