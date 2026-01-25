#INCLUDE "RHNPLIB.CH"

/*/{Protheus.doc}WSMRHLIB01
- Fonte de funções genéricos do projeto Meu RH;
@author:	Henrique Ferreira
@since:		11/08/2023
/*/

/*/{Protheus.doc} MrhWeekDay
Retorna o dia da semana conforme a data passada.
@author:	Henrique Ferreira
@since:		11/08/2023
@param:		dData - Data
@return:	cReturn - Descrição do dia da semana, em inglês, conforme contrato de API.
/*/	
Function MrhWeekDay( dData )

Local aDia		:= Array( 7 , 2 )
Local cReturn	:= ""

aDia[ 01 , 01 ] := "Sunday"
aDia[ 01 , 02 ] :=  1	// "Domingo"
aDia[ 02 , 01 ] := "Monday"
aDia[ 02 , 02 ] :=  2	// "Segunda"
aDia[ 03 , 01 ] := "Tuesday"
aDia[ 03 , 02 ] :=  3	// "Terca"
aDia[ 04 , 01 ] := "Wednesday"
aDia[ 04 , 02 ] :=  4	// "Quarta"
aDia[ 05 , 01 ] := "Thursday"
aDia[ 05 , 02 ] :=  5	// "Quinta"
aDia[ 06 , 01 ] := "Friday"
aDia[ 06 , 02 ] :=  6	// "Sexta"
aDia[ 07 , 01 ] := "Saturday"
aDia[ 07 , 02 ] :=  7	// "Sabado"

cReturn := aDia[ Dow( dData ) , 01 ]

Return( cReturn )

Function fRH3Status( cCodFil, cCodReq )
    Local aArea := getArea()
    Local cDesc := ""

    DbSelectArea("RH3")
    DbSetOrder(1)

    If RH3->(DbSeek(cCodFil + cCodReq))
        cDesc := getStatusWKF(RH3->RH3_STATUS)
    EndIf

    RestArea(aArea)
Return cDesc
