#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} GPESAPISQG
Realiza chamada da API de candidatos para envio dos dados à integração.
@type  Function
@author Emerson Grassi Rocha
@since 21/03/2024
@version 1.0
/*/
Function GPESAPISQG(aData)
    
    Local oBody

    Local lRet	 	:= .F.
    Local cBody     := ""
    Local nI        := 0
    Local lAborta   := .F.
    Local cResource := ""
    Local cIde      := ""
    Local cOpe      := ""
    Local cCodSucss := "200|201|202|203|204"
    Local cPhone    := ""
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)
    Local nRec      := 0

    For nI := 1 To Len(aData)
        cOpe := aData[nI][1]
        nRec := aData[nI][2]
        cIde := aData[nI][3]

        If  Alltrim(cOpe) == "I" .OR. Alltrim(cOpe) == "A"
            oBody := JsonObject():new()
            oBody['id']             := cIde
            oBody['company']        := aData[nI][04]
            oBody['branch']         := aData[nI][05]
            oBody['registration']   := aData[nI][06]
            oBody['name']           := ALLTRIM(aData[nI][07])
            oBody['birth']          := formatDate(aData[nI][08])
            oBody['cpf']            := aData[nI][09]
            oBody['gender']         := aData[nI][10]

            If !Empty(aData[nI][11])
                oBody['rg'] := ALLTRIM(aData[nI][11])
            EndIf

            If !Empty(aData[nI][12])
                oBody['email'] := ALLTRIM(aData[nI][12])
            EndIf

            oBody['street']         := ALLTRIM(aData[nI][13])
            oBody['number']         := aData[nI][14]
            oBody['district']       := ALLTRIM(aData[nI][15])
            oBody['city']           := ALLTRIM(aData[nI][16])
            oBody['zipCode']        := ALLTRIM(aData[nI][17])

            cPhone := fFormTel(ALLTRIM(aData[nI][18]), ALLTRIM(aData[nI][19]))

            If !Empty(cPhone)
                oBody['phone'] := cPhone
            EndIf

            cBody := fComprJSn(@oBody)
            FreeObj( oBody )
            cResource := "/ttalk/person?branchId="+cBranc+"&companyId="+cCompany
 
        Else
            cResource := "/ttalk/person"
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
@author  Emerson Grassi Rocha
@since   21/03/2024
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
