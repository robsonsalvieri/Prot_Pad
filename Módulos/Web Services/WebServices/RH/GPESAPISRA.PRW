#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} GPESAPISRA
Realiza chamada da API de Funcionários para envio dos dados à integração com a NG.
@type  Function
@author martins.marcio
@since 24/04/2020
@version 1.0
/*/
Function GPESAPISRA(aData)

    Local oBody

    Local lRet	 	:= .F.
    Local cBody     := ""
    Local nI        := 0
    Local lAborta   := .F.
    Local cResource := ""
    Local cOperac   := ""
    Local nRec      := 0
    Local cId       := ""
    Local nGenerFun := 0 // 1-M / 2-F
    Local nStatFunc := 0 //1 - Ativo / 2 - Demitido / 3 - Férias / 4 - Afastado / 5 - Atestado / 6 - Quitação
    Local cCodSucss := "200|201|202|203|204"
    Local cPhone    := ""
    Local cBranc    := Escape(cFilAnt)
	Local cCompany  := Escape(cEmpAnt)

    For nI := 1 To Len(aData)

        cOperac     := aData[nI][1]
        nRec        := aData[nI][2]
        cId         := aData[nI][3]
        nGenerFun   := IIf(aData[nI][10] == "M",1,IIf(aData[nI][10] == "F",2,0))
        nStatFunc   := fGetSitua(aData[nI][23]) //RA_SITFOLH
        cPhone      := fFormTel(ALLTRIM(aData[nI][22][1]), ALLTRIM(aData[nI][22][2]))

        // Montagem dos demais campos do Body
        If !(cOperac == "E")
            oBody := JsonObject():new()
            oBody['id']             := aData[nI][3]
            oBody['erpCompany']     := aData[nI][4]
            oBody['erpBranch']      := aData[nI][5]
            oBody['registration']   := aData[nI][6]
            oBody['name']           := aData[nI][7]
            oBody['birth']          := formatDate(DtoS(aData[nI][8]))
            oBody['cpf']            := aData[nI][9]
            oBody['gender']         := nGenerFun
            If !Empty(aData[nI][11])
                oBody['rg']         := AllTrim(aData[nI][11])
            EndIf
            If !Empty(aData[nI][12])
                oBody['email']      := AllTrim(aData[nI][12])
            EndIf
            oBody['workshift']      := aData[nI][13]
            oBody['workshiftDescription'] := aData[nI][30]
            oBody['costCenter']     := aData[nI][14]
            oBody['costCenterDescription']  := aData[nI][31]
            oBody['occupation']     := aData[nI][15]
            oBody['occupationDescription']  := aData[nI][32]
            oBody['department']  := aData[nI][16]
            oBody['departmentDescription']  := aData[nI][33]
            oBody['street']         := aData[nI][17]
            oBody['number']         := Val(aData[nI][18])
            oBody['district']       := aData[nI][19]
            oBody['city']           := aData[nI][20]
            oBody['zipCode']        := aData[nI][21]
            If !Empty(cPhone)
                oBody['phone']      := cPhone
            EndIf
            oBody['situation']      := nStatFunc
            oBody['eSocialRoleId']  := aData[nI][24]
            oBody['admissionDate']  := formatDate(DtoS(aData[nI][25]))
            If !Empty(aData[nI][26])
                oBody['dismissalDate']  := formatDate(DtoS(aData[nI][26]))
            Else
                oBody['dismissalDate']  := Nil
            Endif
            oBody['pisCode']        := aData[nI][27]
            oBody['eSocialId']      := aData[nI][28]
            oBody['sefipCategory']  := aData[nI][29] //13.7 Cod GFIP no PPP

            oBody['mothersName']    := aData[nI][34]

            do case
                case aData[nI][35] == 'S' // Solteiro
                    oBody['civilStatus'] := 1
                case aData[nI][35] == 'C' // Casado
                    oBody['civilStatus'] := 2
                case aData[nI][35] == 'D' // Divorciado
                    oBody['civilStatus'] := 3
                case aData[nI][35] == 'V' // Viúvo
                    oBody['civilStatus'] := 4
                case aData[nI][35] == 'Q' // Separado Judicialmente
                    oBody['civilStatus'] := 5
            end case

            oBody['ctps']             := aData[nI][36]

            DO Case
                CASE aData[nI][37] $ ("10/20/25/30/35/40") //Ensino Básico/Fundamental
                    oBody['educationLevel'] := 1
                CASE aData[nI][37] $ ("45/50") //Ensino Médio
                    oBody['educationLevel']  := 2
                CASE aData[nI][37] $ ("55/85") //Graduação
                    oBody['educationLevel'] := 3
                CASE aData[nI][37] $ ("65") //Mestrado
                    oBody['educationLevel'] := 4
                CASE aData[nI][37] $ ("75/95") //Doutorado
                    oBody['educationLevel'] := 5
            END CASE

            oBody['state']                  := aData[nI][38]
            oBody['rais']                   := aData[nI][39]
            oBody['eSocialCategory']        := aData[nI][40]
            oBody['position']               := aData[nI][41] //cargo
            oBody['positionDescription']    := aData[nI][42] //descricao do cargo

            oBody['defFisica']              := aData[nI][43]
            oBody['defVisual']              := aData[nI][44]
            oBody['defAuditiva']            := aData[nI][45]
            oBody['defMental']              := aData[nI][46]
            oBody['defIntelectual']         := aData[nI][47]
            oBody['reabReadap']             := aData[nI][48]
            If !Empty(aData[nI][49])
                oBody['lastExamDate']       := formatDate(DtoS(aData[nI][49]))
            EndIf
            If !Empty(aData[nI][50])
                oBody['socialName']       := aData[nI][50]
            EndIf

            // Converte o objeto para texto e o compacta
            cBody := fComprJSn(@oBody)
            FreeObj( oBody )
            cResource   := "/ttalk/employee?branchId="+cBranc+"&companyId="+cCompany
        Else
            cResource := "/ttalk/employee"
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

//-------------------------------------------------------------------
/*/{Protheus.doc} function fCompress
Recebe o campo RA_SITFOLH e retorna o codigo de situation para a API
@author  Marcio Felipe Martins
@since   28/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fGetSitua(cSitFolh)

    Local nRet := 0

    Do Case
        Case Empty(cSitFolh)
            nRet := 1
        Case cSitFolh == "A"
            nRet := 4
        Case cSitFolh == "D"
            nRet := 2
        Case cSitFolh == "F"
            nRet := 3
        Case cSitFolh == "T"
            nRet := 2
    EndCase

Return nRet
