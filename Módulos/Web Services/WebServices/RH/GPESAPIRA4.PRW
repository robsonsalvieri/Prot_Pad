#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"


/*/{Protheus.doc} GPESAPIRA4
Realiza chamada da API de Historico de Treinamentos para envio dos dados à integração com a NG.
@type  Function
@author martins.marcio
@since 22/04/2020
@version 1.0
/*/
Function GPESAPIRA4(aData)

    Local oBody

    Local lRet	 	:= .F.
    Local cBody     := ""
    Local nI        := 0
    Local lAborta   := .F.
    Local cResource := ""
    Local cOperac   := ""
    Local nRec      := 0
    Local cId       := ""
    Local cTraining := ""
    Local cCodSucss := "200|201|202|203|204"
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)

    For nI := 1 To Len(aData)

        cOperac := aData[nI][1]
        nRec    := aData[nI][2]
        cId     := aData[nI][3]

         // Montagem dos demais campos do Body
        If !(cOperac == "E")
            cTraining   := aData[nI][4] + "|" + xFilial("RA1",aData[nI][5]) + "|" + aData[nI][8]
            oBody := JsonObject():new()
            oBody['id']                 := cId
            oBody['erpId']              := aData[nI][3]
            oBody['erpCompany']         := aData[nI][4]
            oBody['erpBranch']          := aData[nI][5]
            oBody['employee']           := aData[nI][6]
            oBody['expectedDate']       := formatDate(DtoS(aData[nI][7]))
            oBody['training']           := cTraining
            oBody['trainingDescription'] := aData[nI][9]
            oBody['completionDate']     := formatDate(DtoS(aData[nI][10]))
            oBody['approval']           := aData[nI][11]
            oBody['expirationDate']     := formatDate(DtoS(aData[nI][12]))

            cBody := fComprJSn(@oBody)
            FreeObj( oBody )
            cResource := "/ttalk/trainingHistory?branchId="+cBranc+"&companyId="+cCompany
        Else
            cResource := "/ttalk/trainingHistory"
            cResource += "/" + cId  // Id para exclusão
            cResource += "?branchId="+cBranc+"&companyId="+cCompany
        EndIf

        // Chamada da API do Quirons
        lRet := prepIntQrn(nRec, cResource, cBody, cOperac, cCodSucss, @lAborta)

        If lAborta
            EXIT
        EndIf

    Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function formatDate
Return JSON Date Format
@author  Marcio Felipe Martins
@since   22/04/2020
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
