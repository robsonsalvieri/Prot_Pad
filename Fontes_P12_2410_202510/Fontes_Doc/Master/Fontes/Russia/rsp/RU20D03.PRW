#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RU20D03.CH"

#DEFINE CRLF Chr(13)+Chr(10)


Function RU20D03()

    RU20D03_02()

Return Nil


/*/
{Protheus.doc} RU20D03_02()
    Data sorting and distribution function.

    @type Function

    @author iprokhorenko
    @since 2024/02/26
    @version 12.1.2310
    @return 
    @example RU20D03_02()
/*/
Static Function RU20D03_02()
    Local oData As Object
    Local cJson As Char
    Local aData As Array
    Local nType As Numeric

    Local cArqTxtJson As Char
    Local nHdl

    nType := Val(M->QS_CODSITE)

    cPath := cGetFile(, STR0001, 0, "", .F., nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE, 128, 256),.T., .T. )

    oData := JsonObject():New()

    If nType == 1 .Or. nType == 3
        aData := GetData(1)
        GetTemplate(@oData, 1,aData)
        SetData(@oData,aData,1)
        cJson := EncodeUtf8(oData:toJson(), "cp1252")

        cArqTxtJson := cPath + "HHJson"+ "_" + FwTimeStamp(1) + ".json"
        nHdl := fCreate(cArqTxtJson)
        If fWrite(nHdl,cJson,Len(cJson)) != Len(cJson)
            If !MsgAlert(STR0002+STR0003,STR0004)
                
            EndIf
        EndIf
        fClose(nHdl)
    endif

    If nType == 2 .Or. nType == 3
        aData := GetData(2)
        GetTemplate(@oData, 2)
        SetData(@oData,aData,2)
        cJson := oData:toJson()

        cArqTxtJson := cPath + "AvitoJson"+ "_" + FwTimeStamp(1) + ".json"
        nHdl := fCreate(cArqTxtJson)
        If fWrite(nHdl,cJson,Len(cJson)) != Len(cJson)
            If !MsgAlert(STR0002+STR0003,STR0004)
                
            EndIf
        EndIf
        fClose(nHdl)
    endif

Return

/*/
{Protheus.doc} GetTemplate(oData, nType, aData)
    The function builds JSON templates for HH.ru AVITO.ru

    @type function
    @params oData Object, contains a template construct.
            nType Numeric, template type.
            aData Array, array with data.
    @author iprokhorenko
    @since 2024/02/26
    @return oData, JSON Object with PDF template .
/*/
Static Function GetTemplate(oData, nType, aData)
    Local cJson1 As Char
    Local cJson2 As Char
    Local cJson As Char
    Local nX as Numeric

    DEFAULT aData := {}
    
    // cJson1 := '{"professional_roles":[{"id":"96","name":""}],"schedule":{"id":"","name":""},"experience":{"id":"","name":""},"name":"", "description":"","addres":{"city": "??????","street": "???????? ????","building": "1","lat": 55.77315,"lng": 37.631775,"description": null,"raw": "??????, ???????? ????, 1","metro_stations": [],"can_edit": true,"id": "15697342"},"salary":{"from": 100000,"to": 150000,"currency": "RUR","gross": true},"vacancy_type":"open","area":{"id": "2","name": ""},"type":{"id":"open","name": ""},"billing_type":{"id":"standard","name":""},"key_skills":[{"name":""}'
    
    cJson1 := '{"professional_roles":[{"id":"96","name":""}],"schedule":{"id":"","name":""},"experience":{"id":"","name":""},"name":"", "description":"","adress":{"id":"15697342"},"salary":{"from": 100000,"to": 150000,"currency": "RUR","gross": true},"vacancy_type":"open","area":{"id": "2","name": ""},"type":{"id":"open","name": ""},"billing_type":{"id":"standard","name":""},"key_skills":[{"name":""}'
    
    if len(aData[9]) >1
        For nX := 2 to len(aData[9])
            cJson1 := cJson1 + ',{"name":""}'
        Next        
    EndIf
    cJson1 := cJson1 + "]}"

    cJson2 := '{"billing_type":{"id":"standard","name":"????????"},"business_area":"1","description":"","experience":"moreThan1","location":{"address":{"house":"1", "locality":"","street":""}},"schedule":"","title":""}'

    cJson := iif(nType == 1, cJson1, cJson2)
    oData:FromJson(cJson)

Return oData


/*/
{Protheus.doc} SetData(oData, aData, nType)
    Sets data in JSON File.
    Fills the template with standard strings from the CH file.

    @type function
    @params oData Object, contains a template construct.
            nType Numeric, template type.
            aData Array, array with data.
    @author iprokhorenko
    @since 2024/03/13
    @version 12.1.2310
    @return 
/*/
Static Function SetData(oData, aData, nType)
    Local nI as Numeric

    If nType == 1
        
        oData["professional_roles"][1]["id"] := AllTrim(aData[1][1])
        oData["professional_roles"][1]["name"] := AllTrim(aData[1][2])

        oData["schedule"]["id"] := AllTrim(aData[4][1])
        oData["schedule"]["name"] := AllTrim(aData[4][2])

        oData["experience"]["id"] := AllTrim(aData[3][1])
        oData["experience"]["name"] := AllTrim(aData[3][2])

        oData["name"] := AllTrim(aData[5])
        oData["description"] := AllTrim(aData[6])

        oData["salary"]["currency"] := AllTrim(aData[7][1])
        oData["salary"]["from"] := aData[7][2]
        oData["salary"]["gross"] := AllTrim(aData[7][3])
        oData["salary"]["to"] := aData[7][4]

        oData["type"]["id"] := AllTrim(aData[8])
        oData["type"]["name"] := AllTrim(STR0005)

        For nI:= 1 to len(aData[9])
            oData["key_skills"][nI]["name"] := AllTrim(aData[9][nI])
        Next
        oData["area"]["id"] := AllTrim(aData[11][2])
        oData["area"]["name"] := AllTrim(aData[11][1])

        oData["billing_type"]["name"] := "Стандарт" //AllTrim(aData[10])
        //"Стандарт"
    else
        oData["billing_type"] := AllTrim(aData[1])
        oData["business_area"] := AllTrim(aData[2])
        oData["description"] := AllTrim(aData[3])
        oData["experience"] := AllTrim(aData[4])

        oData["location"]["address"]["house"] := AllTrim(M->QS_DBUILD) 
        oData["location"]["address"]["locality"] := AllTrim(M->QS_DCITY) 
        oData["location"]["address"]["street"] := AllTrim(M->QS_DSTRIT) 

        oData["schedule"] := AllTrim(aData[6])
        oData["title"] := AllTrim(aData[7])
    EndIf

Return



/*/
{Protheus.doc} GetData(nType)
    Get data for JSON File.
    
    @type function
    @params nType Numeric, template type.

    @author iprokhorenko
    @since 2024/03/13
    @version 12.1.2310
    @return 
/*/
Static Function GetData(nType)
    Local aData as Array
    Local aDatTemp as Array
    Local aGetCoBrRusInfo as Array
    Local cMemo as Character
    Local aMemo  as Array

    aGetCoBrRusInfo := GetCoBrRUS(M->QS_FILPOST)

    aDatTemp := {}
    aData := {}

    aAdd(aDatTemp, {"AGA_FULL", AllTrim(M->QS_WPLACE)})
    aAdd(aDatTemp, {"AGA_MUNDES", AllTrim(M->QS_DCITY)})
    aAdd(aDatTemp, {"AGA_HOUSE", AllTrim(M->QS_DSTRIT)})
    aAdd(aDatTemp, {"AGA_END", AllTrim(M->QS_DBUILD)})

    cMemo := M->QS_MSKILL
    aMemo := StrTokArr( cMemo, CRLF )

    If nType == 1
        AAdd(aData, {RU20XFUN02("R001", M->QS_CDESPEC, 1, 6, 7, 10), RU20XFUN02("R001", M->QS_CDESPEC, 1, 6, 27, 70)}) // professional_roles
        AAdd(aData, {aDatTemp[1][2], aDatTemp[2][2]}) // adress
        AAdd(aData, {RU20XFUN02("R007",RU20XFUN02("R002", M->QS_WEXPER , 1, 3, 4, 2), 1, 2, 3, 50), RU20XFUN02("R002", M->QS_WEXPER, 1, 3, 6, 40) }) // schedule
        AAdd(aData, {RU20XFUN02("R006",RU20XFUN02("R003", M->QS_WSCHEDU, 1, 4, 5, 3), 1, 3, 4, 50), RU20XFUN02("R003", M->QS_WSCHEDU, 1, 4, 8, 40)}) // experience
        AAdd(aData, M->QS_DESCRIC) // name
        AAdd(aData, M->QS_PERFIL) // description
        AAdd(aData, {"RUB", M->QS_FIRSTLE, 'false', M->QS_FINALLE}) // salary
        AAdd(aData, "open") // type
        AAdd(aData, aMemo) // key_skills
        AAdd(aData, M->QS_PERFIL) // billing_type
        AAdd(aData, {M->QS_DCITY, GetCity(M->QS_DCITY)}) // area
    else
        AAdd(aData, "packageOrSingle") // billing_type
        AAdd(aData, RU20XFUN02("R001", M->QS_CDESPEC, 1, 6, 98, 10)) // business_area
        AAdd(aData, M->QS_PERFIL) // description
        AAdd(aData, RU20XFUN02("R002", M->QS_WEXPER, 1, 3, 47, 2)) // experience
        AAdd(aData, {aDatTemp[3][2], aDatTemp[2][2], aDatTemp[4][2]}) // adress
        AAdd(aData, RU20XFUN02("R003", M->QS_WSCHEDU, 1, 4, 46, 3)) // schedule
        AAdd(aData, M->QS_PERFIL) // description
    EndIf
Return aData


/*/
{Protheus.doc} GetCity(nType)
    Get data for JSON File.
    
    @type function
    @params nType Numeric, template type.

    @author iprokhorenko
    @since 2024/03/13
    @version 12.1.2310
    @return 
/*/
Static Function GetCity(cType)
    Local cCodeCity as Character
    Local cResult as Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local cSQL       As Character

    cCodeCity := ''
    cCodeCity := RU20XFUN02("R008", cType, 11, 50, 1, 10)

    If Empty(cCodeCity)
        
        cCodeCity := ""
        aArea := GetArea()

        cSQL := "SELECT F6K_SEQUEN, F6K_CONTEU FROM " + RetSQLName("F6K") + " WHERE F6K_FILIAL = ? AND F6K_CODIGO = ?  AND D_E_L_E_T_=' ' ORDER BY F6K_SEQUEN "
        oStatement := FWPreparedStatement():New(cSQL)
        oStatement:SetString(1, xFilial("F6K"))
        oStatement:SetString(2, "R008")
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        While (cTab)->(!Eof())
        
            If Lower(cType) $ Lower(substr((cTab)->F6K_CONTEU, 11, 50)) .Or. Lower(substr((cTab)->F6K_CONTEU, 11, 50)) $ Lower(cType)
                cCodeCity := AllTrim(substr((cTab)->F6K_CONTEU, 1, 10))
            EndIf
            (cTab)->(DbSkip())
            
        EndDo

        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)

        RestArea(aArea)
    EndIf

Return cCodeCity
