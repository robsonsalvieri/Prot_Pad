#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "RHNP12.CH"


WSRESTFUL home DESCRIPTION STR0001 //"Serviço responsável pelos eventos da home."

//****************************** GETs ***********************************

WSMETHOD GET vacCountdown ;
DESCRIPTION EncodeUTF8(STR0002) ; //"Retorna os dependentes do usuário."
PATH "/home/events/vacationDate/{employeeId}" ;
PRODUCES 'application/json;charset=utf-8'

END WSRESTFUL

// -------------------------------------------------------------------
// - Retorna o contador de férias
// -------------------------------------------------------------------

WSMETHOD GET vacCountdown WSSERVICE home

Local oVac       := JsonObject():New()

Local aDataLogin := {}
Local aQryParam  := Self:aQueryString
Local lHabil	 := .F.

Local cCodRD0	 := ""
Local cRD0Login  := ""
Local cBranchVld := ""
Local cMatSRA    := ""
Local cToken	 := ""
Local cKeyId	 := ""
Local cJson		 := ""

::SetHeader('Access-Control-Allow-Credentials' , "true")

cToken      := Self:GetHeader('Authorization')
cKeyId  	:= Self:GetHeader('keyId')

aDataLogin := GetDataLogin(cToken,,cKeyId)
If Len(aDataLogin) > 0
    cCodRD0	    := aDataLogin[3]
    cRD0Login	:= aDataLogin[2]
    cBranchVld	:= aDataLogin[5]
    cMatSRA	    := aDataLogin[1]
EndIf

//Busca a permissão
fPermission(cBranchVld, cRD0Login, cCodRD0, "dashboardVacationCountdown", @lHabil)
If !lHabil
    SetRestFault(400, EncodeUTF8( STR0003 )) //"Permissão negada ao contador de férias."
    Return (.F.)
EndIf

fVacCount( cBranchVld, cMatSRA, aQryParam, @oVac )

cJson := oVac:toJson()
::SetResponse(cJson)

FreeObj( oVac )

Return (.T.)
