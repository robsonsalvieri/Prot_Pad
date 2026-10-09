#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} GPESAPISQB
Realiza chamada da API de departamentos para envio dos dados à integração.
@type  Function
@author Gisele Nuncherino
@since 18/08/2020
@version 1.0
/*/
Function GPESAPISQB(aData)
    
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
	Local cCompany  := Escape(cEmpAnt)

    For nI := 1 To Len(aData)
        cOpe := aData[nI][1]
        nRec := aData[nI][2]
        cIde := aData[nI][3]

        If  Alltrim(cOpe) == "I" .OR. Alltrim(cOpe) == "A"
            oBody := JsonObject():new()
            oBody['id']             := cIde
            oBody['description']    := aData[nI][06]


            cBody := fCompress(@oBody)
            FreeObj( oBody )
            cResource := "/ttalk/department?branchId="+Escape(cFilAnt)+"&companyId="+cCompany
        Else
            cResource := "/ttalk/department"
            cResource += "/" + cIde // Parâmetro para exclusão
            cResource += "?branchId="+Escape(cFilAnt)+"&companyId="+cCompany
        EndIf

        // Chamada da API do Quirons
        lRet := prepIntQrn(nRec, cResource, cBody, cOpe, cCodSucss, @lAborta)

        If lAborta
            EXIT
        EndIf

    Next nI

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Compacta os dados do retorno solicitado
@author  Gisele Nuncherino
@since   18/08/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fCompress(oObj)
	Local cJson    := ""
	Local cComp    := ""
	Local lCompact := .F.

	// Set gzip format to Json Object
	cJson := FWJsonSerialize(oObj,.T.,.T.)

	If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
		lCompact := .T.
	EndIf

	If(lCompact)
		::SetHeader('Content-Encoding','gzip')
		GzStrComp(cJson, @cComp, @nLenComp )
	Else
		cComp := cJson
	Endif

Return cComp
