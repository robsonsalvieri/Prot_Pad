#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "GPEM923.CH"
#INCLUDE "GPESAPISRB.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} nomeFunction
Realiza chamada da API de dependentes para envio dos dados à integração.
@type  Function
@author Wesley Alves Pereira
@since 23/04/2020
@version 1.0
/*/
Function GPESAPISRB(aData)
    
    Local oBody

    Local lRet	 	:= .F.
    Local cBody     := ""
    Local nI        := 0
    Local lAborta   := .F.
    Local cResource := ""
    Local nRec      := 0
    Local cOpe      := ""
    Local cIde      := ""
    Local cCodSucss := "200|201|202|203|204"
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)

    For nI := 1 To Len(aData)
        cOpe := aData[nI][1]
        nRec := aData[nI][2]
        cIde := aData[nI][3]

        If  Alltrim(cOpe) == "I" .OR. Alltrim(cOpe) == "A"
            oBody := JsonObject():new()
            oBody['id']         := cIde
            oBody['company']    := aData[nI][4]
            oBody['branch']     := aData[nI][5]
            oBody['employee']   := aData[nI][6]
            oBody['name']       := ALLTRIM(aData[nI][7])
            oBody['birth']      := formatDate(aData[nI][8])
            oBody['cpf']        := ALLTRIM(aData[nI][9])
            oBody['gender']     := aData[nI][10]

            cBody       := fComprJSn(@oBody)
            FreeObj( oBody )
            cResource   := "/ttalk/dependant?branchId=" +cBranc+"&companyId="+cCompany
        Else
            cResource := "/ttalk/dependant"
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

//-------------------------------------------------------------------
/*/{Protheus.doc} function formatDate
Return JSON Date Format
@author  Wesley Alves Pereira
@since   24/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function formatDate(cDate)
	Local cNewDate := ""

	DEFAULT cDate := ""

	IF !Empty(cDate)
		cNewDate := SubStr(cDate,1,4)+"-"+SubStr(cDate,5,2)+"-"+SubStr(cDate,7,2)+"T"+"00:00:00"
	Else
        cNewDate := "2099-12-31T00:00:00"
    EndIf

Return cNewDate
