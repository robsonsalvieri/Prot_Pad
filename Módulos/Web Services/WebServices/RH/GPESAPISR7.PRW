#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "GPEM923.CH"
#INCLUDE "GPESAPISR7.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} GPESAPISR7
Realiza chamada da API de histórico funcional para envio dos dados à integração.
@type  Function
@author Wesley Alves Pereira
@since 28/04/2020
@version 1.0
/*/
Function GPESAPISR7(aData)

    Local oBody

    Local lRet	 	:= .F.
    Local cBody     := ""
    Local nI        := 0
    Local lAborta   := .F.
    Local cResource := ""
    Local cIde      := ""
    Local cOpe      := ""
    Local nRec      := 0
    Local cCodSucss := "200|201|202|203|204"
    Local cMat      := ""
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)

    For nI := 1 To Len(aData)

        cOpe := aData[nI][01]
        nRec := aData[nI][02]
        cIde := aData[nI][03]

        cMat := aData[nI][04]+"|"+aData[nI][05]+"|"+aData[nI][06]

        DbselectArea("RJP")
        RJP->(DbGoTo(nRec))

        If  Alltrim(cOpe) == "I" .OR. Alltrim(cOpe) == "A"

            oBody := JsonObject():new()
            oBody['id']                          := cIde
            oBody['erpId']                       := cIde
            oBody['erpCompany']                  := aData[nI][04]
            oBody['erpBranch']                   := aData[nI][05]
            oBody['employee']                    := AllTrim(cMat)
            oBody['occurrenceDate']              := fDtHrToJsn(aData[nI][07], AllTrim(RJP->RJP_HORA))
            oBody['costCenter']                  := aData[nI][08]
            oBody['costCenterDescription']       := aData[nI][09]
            oBody['department']                  := aData[nI][10]
            oBody['departmentDescription']       := aData[nI][11]
            oBody['occupation']                  := aData[nI][12]
            oBody['occupationDescription']       := aData[nI][13]
            oBody['employeePosition']            := aData[nI][14]
            oBody['employeePositionDescription'] := aData[nI][15]
            oBody['sefipCategory']               := aData[nI][16]

            cBody := fComprJSn(@oBody)
            FreeObj( oBody )
            cResource := "/ttalk/functionalHistory?branchId="+cBranc+"&companyId="+cCompany
        Else
            cResource := "/ttalk/functionalHistory"
            cResource += "/" + Escape(cIde) // Parâmetro para exclusão
            cResource += "?branchId="+cBranc+"&companyId="+cCompany
        EndIf

        // Chamada da API do Quirons
        lRet := prepIntQrn(nRec, cResource, cBody, cOpe, cCodSucss, @lAborta)

        If lAborta
            EXIT
        EndIf

    Next nI

Return lRet
