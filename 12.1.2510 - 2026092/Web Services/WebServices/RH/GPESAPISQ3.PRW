#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} GPESAPISQ3
Realiza chamada da API de Cargos para envio dos dados à integração.
@type  Function
@author Wesley Alves Pereira
@since 25/08/2020
@version 1.0
/*/
Function GPESAPISQ3(aData)
    
    Local oBody

    Local lRet	 	:= .F.
    Local cBody     := ""
    Local nI        := 0
    Local lAborta   := .F.
    Local cResource := ""
    Local cIde      := ""
    Local cOpe      := ""
    Local cCodSucss := "200|201|202|203|204"
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)
    Local nRec      := 0

    For nI := 1 To Len(aData)
        cOpe := aData[nI][1]
        nRec := aData[nI][2]
        cIde := aData[nI][3]

        If  Alltrim(cOpe) == "I" .OR. Alltrim(cOpe) == "A"
            oBody := JsonObject():new()
            oBody['id']         := cIde
            oBody['description']    := aData[nI][8]
            oBody['observation']    := aData[nI][10]

            cBody       := fComprJSn(@oBody)
            FreeObj( oBody )
            cResource   := "/ttalk/position?branchId=" +cBranc+"&companyId="+cCompany
        Else
            cResource := "/ttalk/position"
            cResource += "/" + cIde // Parâmetro para exclusão
            cResource += "?branchId="+cBranc+"&companyId="+cCompany
        EndIf

        // Chamada da API do Quirons
        lRet := prepIntQrn(nRec, cResource, cBody, cOpe, cCodSucss, @lAborta)

        If lAborta
            EXIT
        EndIf

    Next nI

Return lRet
