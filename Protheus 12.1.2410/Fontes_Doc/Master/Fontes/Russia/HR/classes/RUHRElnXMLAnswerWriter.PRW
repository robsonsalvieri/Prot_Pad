#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07T14RUS.CH"

// dublicate const: ru07t14rus
#DEFINE DELETE_NODE 1
#DEFINE NILABLE_NODE 2

/*/
{Protheus.doc} RUHRElnDataForElnItem

    Class for write answer by ELN/ZNS.

    @type Class
    @author dchizhov
    @since 11.04.2024
    @version 12.1.23.10
/*/
Class RUHRElnXMLAnswerWriter From LongNameClass

    Data oXMLManager As Object    // TXMLManager
    Data cXMLText    As Character // TXMLManager
    Data oNameSpaces As Array     // List of namespace
    Data aDelNode    As Array     // List of node wich must be deleted

    Method New(oJSample, nType) Constructor

    Method FillXml(oJson)
    Method CreateXMLNode(oJson)
    Method FillXMLNode(oJson)
    Method CreateXMLAttr(aAttr)
    Method SetNillable()
    Method WriteFile()

    Method GetXmlSTRFromJson(oJSample, nType)
    Method GetJsonSample1()
    Method GetJsonSampleB1ElnInfo()
    Method GetJsonSampleB1InsurerInfo()
    Method GetJsonSampleB1InsuredInfo()
    Method GetJsonSampleB1ReceivePaym()
    Method GetJsonSampleB1CalcData()
    Method GetJsonSampleB1InsuranCase()
    Method GetAttrSample1(cType)

    Method Destroy()

EndClass

/*/
{Protheus.doc} New(oJSample, nType)

    Default constructor.

    @type Method
    @param oJSample, JSON, Struct for XML.
    @param nType, Numeric, Type of answer (begin XML).
    @author dchizhov
    @since 11.04.2024
    @version 12.1.23.10
    @return RUHRElnXMLAnswerWriter, Object, RUHRElnXMLAnswerWriter instance.
    @example oXMLReader := RUHRElnXMLReaderPart02():New(cPath)
/*/
Method New(oJSample, nType) Class RUHRElnXMLAnswerWriter

    Local cEmpty As Character
    Local aNSpac As Array

    Default nType := 1
    Default oJSample := Nil
    
    If oJSample == Nil .Or. Empty(oJSample)
        oJSample := ::GetJsonSample1()
    EndIf

    Self:oNameSpaces := oJSample["nameSpaces"]

    Self:oXMLManager := TXMLManager():New()
    cEmpty := ::GetXmlSTRFromJson(oJSample["struct"], nType)
    Self:oXMLManager:Parse(cEmpty)
    aNSpac := Self:oXMLManager:XPathGetRootNsList()

    Self:oXMLManager:XPathRegisterNsList(aNSpac)
    ::aDelNode := {}

Return Self

/*/
{Protheus.doc} FillXml(oJson)

    Fill XML by data.

    @type Method
    @param oJson, JSON, Data for Filling.
    @author dchizhov
    @since 14.05.2024
    @version 12.1.23.10
    @return .T.
    @example FillXml(RU07T1427_FillJsonData(oXMLWriter:GetJsonSample()))
/*/
Method FillXml(oJson) Class RUHRElnXMLAnswerWriter

    ::CreateXMLNode(oJson[::oXMLManager:cName])
    ASort(::aDelNode, , , {|X, Y| X > Y})
    AEval(::aDelNode, {|X| ::oXMLManager:XPathDelNode(X)})

Return .T.

/*/
{Protheus.doc} CreateXMLNode(oJson)

    Fill XML by data.

    @type Method
    @param oJson, JSON, Data for Filling.
    @author dchizhov
    @since 14.05.2024
    @version 12.1.23.10
    @return .T.
    @example ::CreateXMLNode(oJson)
/*/
Method CreateXMLNode(oJson) Class RUHRElnXMLAnswerWriter

    Local aJson As Array
    Local nI    As Numeric
    Local oTemp  As Object
    Local oTemp2 As Object
    Local cTemp  As Character

    oTemp2 := JsonObject():New()
    
    oTemp := oJson["node"]
    aJson := oTemp:GetNames()
    For nI := 1 To Len(aJson)
        If oTemp2:HasProperty(oTemp[aJson[nI]]["nameProperty"])
            If oTemp2[oTemp[aJson[nI]]["nameProperty"]]:HasProperty("sameName")
                Aadd(oTemp2[oTemp[aJson[nI]]["nameProperty"]]["sameName"], aJson[nI])
            Else
                oTemp2[oTemp[aJson[nI]]["nameProperty"]]["sameName"] := { aJson[nI] }
                oTemp2[oTemp[aJson[nI]]["nameProperty"]]["numAtual"] := 0
            EndIf
        Else
            oTemp2[oTemp[aJson[nI]]["nameProperty"]] := JsonObject():New()
            oTemp2[oTemp[aJson[nI]]["nameProperty"]]["name"] :=  aJson[nI]
        EndIf
    Next nI
    If ::oXMLManager:DOMChildNode()
        cTemp := oTemp2[::oXMLManager:cName]["name"]
        oTemp2[::oXMLManager:cName]["numAtual"] := 1
        ::FillXMLNode(oTemp[cTemp])
        While ::oXMLManager:DOMHasNextNode()
            ::oXMLManager:DOMNextNode()
            If oTemp2[::oXMLManager:cName]:HasProperty("sameName") .And. oTemp2[::oXMLManager:cName]["numAtual"] > 0
                cTemp := oTemp2[::oXMLManager:cName]["sameName"][oTemp2[::oXMLManager:cName]["numAtual"]]
                oTemp2[::oXMLManager:cName]["numAtual"] += 1
            Else
                cTemp := oTemp2[::oXMLManager:cName]["name"]
            EndIf
            ::FillXMLNode(oTemp[cTemp])
        EndDo
        ::oXMLManager:DOMParentNode()
    EndIf

    FreeObj(oTemp2)
    oTemp2 := Nil

Return .T.

/*/
{Protheus.doc} FillXMLNode(oJson)

    Fill XML node.

    @type Method
    @param oJson, JSON, Data struct for Filling.
    @author dchizhov
    @since 16.05.2024
    @version 12.1.23.10
    @return .T.
    @example ::FillXMLNode(oJson[oTemp[::oXMLManager:cName]])
/*/
Method FillXMLNode(oJson) Class RUHRElnXMLAnswerWriter

    ::oXMLManager:DOMSetNode("", oJson["value"])
    If oJson["exception"]
        If oJson:HasProperty("simpleExc") .And. oJson["simpleExc"] 
            If oJson:HasProperty("typeException")
                If oJson["typeException"] == DELETE_NODE
                    Aadd(::aDelNode, ::oXMLManager:CPATH)
                ElseIf oJson["typeException"] == NILABLE_NODE
                    ::SetNillable()
                EndIf
            EndIf
            If oJson:HasProperty("maxLength")
                ::oXMLManager:DOMSetNode("", SubStr(oJson["value"], 1, oJson["maxLength"]))
            EndIf
        EndIf
    EndIf
    If oJson["complex"]
        ::CreateXMLNode(oJson)
    EndIf

Return .T.

/*/
{Protheus.doc} CreateXMLNode(oJson)

    Build string with attribute.

    @type Method
    @param aAttr, Array, Array of attribute.
    @author dchizhov
    @since 15.05.2024
    @version 12.1.23.10
    @return cSTRAttr
    @example ::CreateXMLAttr(oJson[oTemp[::oXMLManager:cName]]["attribute"])
/*/
Method CreateXMLAttr(aAttr) Class RUHRElnXMLAnswerWriter

    Local cSTRAttr As Character

    cSTRAttr := ""

    AEval(aAttr, {|X| cSTRAttr += " " + ::oNameSpaces[X["nameSpace"]] + X["name"] + "=" + '"' + X["value"] + '"'})

Return cSTRAttr

/*/
{Protheus.doc} SetNillable()

    Set nil value to current node in oXMLManager.

    @type Method
    @author dchizhov
    @since 16.05.2024
    @version 12.1.23.10
    @return .T.
    @example ::SetNillable()
/*/
Method SetNillable() Class RUHRElnXMLAnswerWriter

    Local aAtr As Array
    Local cAtr As Character

    aAtr := ::oXMLManager:DOMGetAttArray()
    cAtr := ""
    AEval(aAtr, {|X| Iif(X[1] == "xmlns:xsi", cAtr += "N", Iif(X[1] == "xsi:nil", cAtr += "V", Nil))})
    If !(cAtr $ "N")
        ::oXMLManager:DOMAddAtt("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
    EndIf
    If !(cAtr $ "V")
        ::oXMLManager:DOMAddAtt("xsi:nil", "true")
    EndIf

Return .T.

/*/
{Protheus.doc} WriteFile(cPathSrv)

    Write file.

    @type Method
    @param cPathSrv, Character, Path of Server.
    @author dchizhov
    @since 11.04.2024
    @version 12.1.23.10
    @return lResult, Logical, Success by Save file.
    @example oXMLReader := RUHRElnXMLReaderPart02():New(cPath)
/*/
Method WriteFile(cPathSrv) Class RUHRElnXMLAnswerWriter

    Local lResult As Logical

    lResult := ::oXMLManager:Save2File(cPathSrv)

Return lResult

/*/
{Protheus.doc} GetXmlSTRFromJson(oJSample)

    Write file.

    @type Method
    @param oJSample, JSON, Struct for XML.
    @param nType, Numeric, Type of answer (begin XML).
    @author dchizhov
    @since 17.04.2024
    @version 12.1.23.10
    @return .T.
    @example cEmpty += ::GetXmlSTRFromJson(oJSample, nType)
/*/
Method GetXmlSTRFromJson(oJSample, nType) Class RUHRElnXMLAnswerWriter

    Local cXML  As Character
    Local cTemp As Character 
    Local aName As Array
    Local aTemp As Array
    Local nI    As Numeric

    cXML := ""
    cTemp := ""
    aName := oJSample:GetNames()

    If nType == 1
        BeginContent var cXML
        <?xml version="1.0" encoding="UTF-8"?>
        EndContent
        aTemp := ::oNameSpaces:GetNames()
        ::oNameSpaces["nothingnamespace"] := ""
        cTemp := ::oNameSpaces[oJSample[aName[1]]["nameSpace"]] + ":" + oJSample[aName[1]]["nameProperty"]
        cXML += "<" + cTemp + " "
        For nI := 1 To Len(aTemp)
            cXML += Iif(::oNameSpaces[aTemp[nI]] <> "xmlns", "xmlns:", "") + ::oNameSpaces[aTemp[nI]] + '="' + aTemp[nI] + '"' + CRLF
            ::oNameSpaces[aTemp[nI]] += ":"
        Next nI
        cXML += Iif(oJSample[aName[1]]:HasProperty("attribute"), ::CreateXMLAttr(oJSample[aName[1]]["attribute"]), "") + ;
        ">" + Iif(oJSample[aName[1]]["complex"], CRLF + ::GetXmlSTRFromJson(oJSample[aName[1]]["node"], 0), "") + "</" + cTemp + ">"
    Else

        For nI := 1 To Len(aName)
            cTemp := ::oNameSpaces[oJSample[aName[nI]]["nameSpace"]] + oJSample[aName[nI]]["nameProperty"] 
            cXML += "<" + cTemp + Iif(oJSample[aName[nI]]:HasProperty("attribute"), ::CreateXMLAttr(oJSample[aName[nI]]["attribute"]), "") + ;
            ">" + Iif(oJSample[aName[nI]]["complex"], CRLF + ::GetXmlSTRFromJson(oJSample[aName[nI]]["node"], 0), "") + "</" + cTemp + ">" + CRLF
        Next nI
    EndIf

Return cXML

/*/
{Protheus.doc} GetJsonSample1()

    Get JSON-object whith needable struct for data.

    @type Method
    @author dchizhov
    @since 14.05.2024
    @version 12.1.23.10
    @return oJson, JSON, Json-object with data.
    @example oJSample := ::GetJsonSample1()
/*/
Method GetJsonSample1() Class RUHRElnXMLAnswerWriter

    Local cJson As Character
    Local oJson As Object

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "nameSpaces":{
            "http://www.fss.ru/integration/types/common/v01": "xmlns",
            "urn:ru:fss:integration:types:proactive:v01": "ns2",
            "urn:ru:fss:integration:types:proactive:benefit1:v01": "ns3",
            "http://www.fss.ru/integration/types/person/v02": "ns4",
            "urn:ru:fss:integration:types:proactive:benefit2:v01": "ns5",
            "urn:ru:fss:integration:types:proactive:benefit4:v01": "ns6",
            "urn:ru:fss:integration:types:proactive:benefit4:v02": "ns7",
            "urn:ru:fss:integration:types:proactive:benefit5:v01": "ns8",
            "urn:ru:fss:integration:types:proactive:benefit6:v01": "ns9"
        },
        "struct": {
            "approveSocialAssist": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "approveSocialAssist",
                "attribute": [
                    {
                        "nameSpace": "nothingnamespace",
                        "name": "responseOn",
                        "value": "00000000-0000-0000-0000-000000000000"
                    }
                ]
                ,
                "node": {
                    "socialAssistNum": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "socialAssistNum"
                    },
                    "benefit1Approve": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": true,
                        "value": "",
                        "nameProperty": "benefit1Approve",
                        "node": {
                        }
                    }
                }
            }
        }
    }
    EndContent
    oJson:FromJson(cJson)
    oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["elnInfo"] := ::GetJsonSampleB1ElnInfo()
    oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["insurerInfo"] := ::GetJsonSampleB1InsurerInfo()
    oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["insuredInfo"] := ::GetJsonSampleB1InsuredInfo()
    oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["receivePayment"] := ::GetJsonSampleB1ReceivePaym()
    oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["calculationData"] := ::GetJsonSampleB1CalcData()
    oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["insuranceCase"] := ::GetJsonSampleB1InsuranCase()

Return oJson

/*/
{Protheus.doc} GetJsonSampleB1ElnInfo()

    Get JSON-object whith Insurer info struct.

    @type Method
    @author dchizhov
    @since 16.05.2024
    @version 12.1.23.10
    @return oJson, JSON, Json-object with data.
    @example oJson["benefit1Approve"]["node"]["elnInfo"] := ::GetJsonSampleB1ElnInfo()
/*/
Method GetJsonSampleB1ElnInfo() Class RUHRElnXMLAnswerWriter

    Local cJson As Character
    Local oJson As Object

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
        "exception": false,
        "complex": true,
        "value": "",
        "nameProperty": "elnInfo",
        "node": {
            "code": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "code"
            }
        }
    }
    EndContent
    oJson:FromJson(cJson)
    oJson["attribute"] := ::GetAttrSample1()
    oJson["node"]["code"]["attribute"] := ::GetAttrSample1()

Return oJson

/*/
{Protheus.doc} GetJsonSampleB1InsurerInfo()

    Get JSON-object whith Insurer info struct.

    @type Method
    @author dchizhov
    @since 16.05.2024
    @version 12.1.23.10
    @return oJson, JSON, Json-object with data.
    @example oJson["benefit1Approve"]["node"]["insurerInfo"] := ::GetJsonSampleB1InsurerInfo()
/*/
Method GetJsonSampleB1InsurerInfo() Class RUHRElnXMLAnswerWriter

    Local cJson As Character
    Local oJson As Object

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
        "exception": false,
        "complex": true,
        "value": "",
        "nameProperty": "insurerInfo",
        "node": {
            "regNum": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "regNum"
            },
            "partTime": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "NONE",
                "nameProperty": "partTime"
            },
            "parentNo": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "parentNo"
            }
        }
    }
    EndContent
    oJson:FromJson(cJson)
    oJson["node"]["regNum"]["attribute"] := ::GetAttrSample1()
    oJson["node"]["partTime"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["parentNo"]["attribute"] := ::GetAttrSample1("4")

Return oJson

/*/
{Protheus.doc} GetJsonSampleB1InsuredInfo()

    Get JSON-object whith Insured info struct.

    @type Method
    @author dchizhov
    @since 16.05.2024
    @version 12.1.23.10
    @return oJson, JSON, Json-object with data.
    @example oJson["benefit1Approve"]["node"]["insuredInfo"] := ::GetJsonSampleB1InsuredInfo()
/*/
Method GetJsonSampleB1InsuredInfo() Class RUHRElnXMLAnswerWriter

    Local cJson As Character
    Local oJson As Object

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
        "exception": false,
        "complex": true,
        "value": "",
        "nameProperty": "insuredInfo",
        "node": {
            "category": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "INSURED",
                "nameProperty": "category"
            },
            "snils": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "snils"
            },
            "inn": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "inn"
            },
            "fullName": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "fullName",
                "node": {
                    "firstName": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "firstName"
                    },
                    "lastName": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "lastName"
                    },
                    "middleName": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "middleName"
                    }
                }
            },
            "birthDate": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "birthDate"
            },
            "gender": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "gender"
            },
            "taxpayer": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "taxpayer",
                "node": {
                    "taxpayerStatus": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "taxpayerStatus"
                    },
                    "countryCode": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "countryCode"
                    },
                    "address": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": true,
                        "value": "",
                        "nameProperty": "address",
                        "node": {
                            "houseGuid": {
                                "nameSpace": "nothingnamespace",
                                "exception": true,
                                "simpleExc": true,
                                "complex": false,
                                "value": "",
                                "nameProperty": "houseGuid"
                            },
                            "guid": {
                                "nameSpace": "nothingnamespace",
                                "exception": true,
                                "simpleExc": true,
                                "complex": false,
                                "value": "",
                                "nameProperty": "guid"
                            },
                            "house": {
                                "nameSpace": "nothingnamespace",
                                "exception": true,
                                "simpleExc": true,
                                "complex": false,
                                "value": "",
                                "nameProperty": "house"
                            },
                            "building": {
                                "nameSpace": "nothingnamespace",
                                "exception": true,
                                "simpleExc": true,
                                "complex": false,
                                "value": "",
                                "nameProperty": "building"
                            },
                            "flat": {
                                "nameSpace": "nothingnamespace",
                                "exception": false,
                                "complex": false,
                                "value": "",
                                "nameProperty": "flat"
                            }
                        }
                    },
                    "postalCode": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "postalCode"
                    }
                }
            },
            "id": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "id",
                "node": {
                    "type": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "type"
                    },
                    "series": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "series"
                    },
                    "num": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "num"
                    },
                    "issueDate": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "issueDate"
                    },
                    "dept": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": true,
                        "complex": false,
                        "simpleExc": true,
                        "maxLength": 200,
                        "value": "",
                        "nameProperty": "dept"
                    },
                    "endDate": {
                        "nameSpace": "http://www.fss.ru/integration/types/person/v02",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "endDate"
                    }
                }
            },
            "workContract": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": true,
                "simpleExc": true,
                "complex": false,
                "value": "",
                "nameProperty": "workContract"
            },
            "personPhone": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": true,
                "complex": false,
                "simpleExc": true,
                "maxLength": 30,
                "value": "",
                "nameProperty": "personPhone"
            }
        }
    }
    EndContent
    oJson:FromJson(cJson)
    oJson["node"]["category"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["snils"]["attribute"] := ::GetAttrSample1()
    oJson["node"]["inn"]["attribute"] := ::GetAttrSample1("3")
    oJson["node"]["fullName"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["birthDate"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["gender"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["taxpayer"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["id"]["attribute"] := ::GetAttrSample1("4")

Return oJson

/*/
{Protheus.doc} GetJsonSampleB1ReceivePaym()

    Get JSON-object whith receive payment struct.

    @type Method
    @author dchizhov
    @since 21.05.2024
    @version 12.1.23.10
    @return oJson, JSON, Json-object with data.
    @example oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["receivePayment"] := ::GetJsonSampleB1ReceivePaym()
/*/
Method GetJsonSampleB1ReceivePaym() Class RUHRElnXMLAnswerWriter

    Local cJson As Character
    Local oJson As Object

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
        "exception": false,
        "complex": true,
        "value": "",
        "nameProperty": "receivePayment",
        "node": {
            "bankInfo": {
                "nameSpace": "nothingnamespace",
                "exception": true,
                "simpleExc": true,
                "complex": true,
                "value": "",
                "nameProperty": "bankInfo",
                "node": {
                    "bankName": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "bankName"
                    },
                    "bik": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "bik"
                    },
                    "accountNum": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "accountNum"
                    }
                }
            },
            "cardMir": {
                "nameSpace": "nothingnamespace",
                "exception": true,
                "simpleExc": true,
                "complex": false,
                "value": "",
                "nameProperty": "cardMir"
            },
            "otherOrg": {
                "nameSpace": "nothingnamespace",
                "exception": true,
                "simpleExc": true,
                "complex": true,
                "value": "",
                "nameProperty": "otherOrg",
                "node": {
                    "nameOrg": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "nameOrg"
                    },
                    "bik": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "bik"
                    },
                    "accountNum": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "accountNum"
                    },
                    "personalOrgAccount": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "personalOrgAccount"
                    },
                    "personalInsuredAccount": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "personalInsuredAccount"
                    },
                    "kbk": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "kbk"
                    },
                    "regNumCorrectionalFacility": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "regNumCorrectionalFacility"
                    },
                    "innCorrectionalFacility": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "innCorrectionalFacility"
                    },
                    "kppCorrectionalFacility": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "kppCorrectionalFacility"
                    }
                }
            },
            "currentFiasAddress": {
                "nameSpace": "nothingnamespace",
                "exception": true,
                "simpleExc": true,
                "complex": true,
                "value": "",
                "nameProperty": "currentFiasAddress",
                "node": {
                    "houseGuid": {
                        "nameSpace": "nothingnamespace",
                        "exception": true,
                        "simpleExc": true,
                        "complex": false,
                        "value": "",
                        "nameProperty": "houseGuid"
                    },
                    "guid": {
                        "nameSpace": "nothingnamespace",
                        "exception": true,
                        "simpleExc": true,
                        "complex": false,
                        "value": "",
                        "nameProperty": "guid"
                    },
                    "house": {
                        "nameSpace": "nothingnamespace",
                        "exception": true,
                        "simpleExc": true,
                        "complex": false,
                        "value": "",
                        "nameProperty": "house"
                    },
                    "building": {
                        "nameSpace": "nothingnamespace",
                        "exception": true,
                        "simpleExc": true,
                        "complex": false,
                        "value": "",
                        "nameProperty": "building"
                    },
                    "flat": {
                        "nameSpace": "nothingnamespace",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "flat"
                    }
                }
            },
            "postalCode": {
                "nameSpace": "nothingnamespace",
                "exception": true,
                "simpleExc": true,
                "complex": false,
                "value": "",
                "nameProperty": "postalCode"
            }
        }
    }
    EndContent
    oJson:FromJson(cJson)
    oJson["attribute"] := ::GetAttrSample1("4")

Return oJson

/*/
{Protheus.doc} GetJsonSampleB1CalcData()

    Get JSON-object whith Calcucation data struct.

    @type Method
    @author dchizhov
    @since 21.05.2024
    @version 12.1.23.10
    @return oJson, JSON, Json-object with data.
    @example oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["calculationData"] := ::GetJsonSampleB1CalcData()
/*/
Method GetJsonSampleB1CalcData() Class RUHRElnXMLAnswerWriter

    Local cJson As Character
    Local oJson As Object

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
        "exception": false,
        "complex": true,
        "value": "",
        "nameProperty": "calculationData",
        "node": {
            "baseCalcDays": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "baseCalcDays"
            },
            "years": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "years",
                "node": {
                    "year1": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": true,
                        "value": "",
                        "nameProperty": "year",
                        "node": {
                            "calc": {
                                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                                "exception": false,
                                "complex": false,
                                "value": "",
                                "nameProperty": "calc"
                            },
                            "baseSum": {
                                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                                "exception": false,
                                "complex": false,
                                "value": "",
                                "nameProperty": "baseSum"
                            }
                        }
                    },
                    "year2": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": true,
                        "value": "",
                        "nameProperty": "year",
                        "node": {
                            "calc": {
                                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                                "exception": false,
                                "complex": false,
                                "value": "",
                                "nameProperty": "calc"
                            },
                            "baseSum": {
                                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                                "exception": false,
                                "complex": false,
                                "value": "",
                                "nameProperty": "baseSum"
                            }
                        }
                    }
                }
            },
            "kfReg": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "kfReg"
            },
            "kfShortDays": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "kfShortDays"
            },
            "experience": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "experience",
                "node": {
                    "insurYY": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "insurYY"
                    },
                    "insurMM": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "insurMM"
                    }, 
                    "notInsurYY": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": true,
                        "simpleExc": true,
                        "complex": false,
                        "value": "",
                        "nameProperty": "notInsurYY"
                    },
                    "notInsurMM": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": true,
                        "simpleExc": true,
                        "complex": false,
                        "value": "",
                        "nameProperty": "notInsurMM"
                    }
                }
            },
            "calcConditionList": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": true,
                "simpleExc": true,
                "complex": false,
                "value": "",
                "nameProperty": "calcConditionList"
            },
            "payPeriodFSS": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "payPeriodFSS",
                "node": {
                    "begin": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "begin"
                    },
                    "end": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "end"
                    }
                }
            },
            "excludePeriodList": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": true,
                "simpleExc": true,
                "complex": false,
                "value": "",
                "nameProperty": "excludePeriodList"
            },
            "downPeriodList": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": true,
                "simpleExc": true,
                "complex": false,
                "value": "",
                "nameProperty": "downPeriodList"
            }
        }
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["node"]["years"]["node"]["year1"]["node"]["calc"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["years"]["node"]["year1"]["node"]["baseSum"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["years"]["node"]["year2"]["node"]["calc"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["years"]["node"]["year2"]["node"]["baseSum"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["kfReg"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["kfShortDays"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["experience"]["node"]["insurYY"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["experience"]["node"]["insurMM"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["payPeriodFSS"]["node"]["begin"]["attribute"] := ::GetAttrSample1("4")
    oJson["node"]["payPeriodFSS"]["node"]["end"]["attribute"] := ::GetAttrSample1("2")

Return oJson

/*/
{Protheus.doc} GetJsonSampleB1InsuranCase()

    Get JSON-object whith insuranceCase data struct.

    @type Method
    @author dchizhov
    @since 21.05.2024
    @version 12.1.23.10
    @return oJson, JSON, Json-object with data.
    @example oJson["struct"]["approveSocialAssist"]["node"]["benefit1Approve"]["node"]["insuranceCase"] := ::GetJsonSampleB1InsuranCase()
/*/
Method GetJsonSampleB1InsuranCase() Class RUHRElnXMLAnswerWriter

    Local cJson As Character
    Local oJson As Object

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
        "exception": true,
        "complex": true,
        "simpleExc": true,
        "value": "",
        "nameProperty": "insuranceCase",
        "node": {
            "insuranceCaseState": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": false,
                "value": "",
                "nameProperty": "insuranceCaseState"
            },
            "n1": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "n1",
                "node": {
                    "num": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "num"
                    },
                    "issueDate": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "issueDate"
                    }
                }
            },
            "profIllnessAct": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "profIllnessAct",
                "node": {
                    "issueDate": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "issueDate"
                    }
                }
            },
            "freeFormAct": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "freeFormAct",
                "node": {
                    "num": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "num"
                    },
                    "issueDate": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "issueDate"
                    }
                }
            },
            "courtDecision": {
                "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                "exception": false,
                "complex": true,
                "value": "",
                "nameProperty": "courtDecision",
                "node": {
                    "num": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "num"
                    },
                    "issueDate": {
                        "nameSpace": "urn:ru:fss:integration:types:proactive:benefit1:v01",
                        "exception": false,
                        "complex": false,
                        "value": "",
                        "nameProperty": "issueDate"
                    }
                }
            }
        }
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["node"]["n1"]["node"]["num"]["attribute"] := ::GetAttrSample1("01")
    oJson["node"]["n1"]["node"]["issueDate"]["attribute"] := ::GetAttrSample1("01")
    oJson["node"]["profIllnessAct"]["node"]["issueDate"]["attribute"] := ::GetAttrSample1("01")
    oJson["node"]["freeFormAct"]["node"]["num"]["attribute"] := ::GetAttrSample1("01")
    oJson["node"]["freeFormAct"]["node"]["issueDate"]["attribute"] := ::GetAttrSample1("01")
    oJson["node"]["courtDecision"]["node"]["num"]["attribute"] := ::GetAttrSample1("01")
    oJson["node"]["courtDecision"]["node"]["issueDate"]["attribute"] := ::GetAttrSample1("01")

Return oJson

/*/
{Protheus.doc} GetAttrSample1(cType)

    Get array whith attribute (sample-1).

    @type Method
    @param cType, Character, Type of sample. (1 - FF; 2 - FT; 3 - TF; 4 - TT) and if len > 1 only 1 attr (2- editable, 3 - required)
    @author dchizhov
    @since 15.05.2024
    @version 12.1.23.10
    @return aAttr, Array, Json-object with aaray of attr.
    @example oJson["benefit1Approve"]["node"]["elnInfo"]["attribute"] := ::GetAttrSample1()
/*/
Method GetAttrSample1(cType) Class RUHRElnXMLAnswerWriter

    Local cJson As Character
    Local oJson As Object
    Local aAttr As Array
    Local lEAtr As Logical
    Local lRAtr As Logical
    Local nTemp As Numeric

    Default cType := "2"

    aAttr := {}

    BeginContent var cJson
    {
        "nameSpace": "urn:ru:fss:integration:types:proactive:v01"
    }
    EndContent 
    nTemp := Len(cType)
    lEAtr := nTemp < 3 
    lRAtr := nTemp <> 2
    If lEAtr
        oJson := JsonObject():New()
        oJson:FromJson(cJson)
        oJson["name"] := "editable"
        oJson["value"] := Iif(cType $ "12", "false", "true")
        Aadd(aAttr, oJson)
    EndIf
    If lRAtr
        oJson := JsonObject():New()
        oJson:FromJson(cJson)
        oJson["name"] := "required"
        oJson["value"] := Iif(cType $ "13", "false", "true")
        Aadd(aAttr, oJson)
    EndIf

Return aAttr

/*/
{Protheus.doc} Destroy()

    Destroy element.

    @type Method
    @author dchizhov
    @since 15.05.2024
    @version 12.1.23.10
    @return 
    @example oXMLWriter:Destroy()
/*/
Method Destroy() Class RUHRElnXMLAnswerWriter

    FreeObj(::oXMLManager)
    FreeObj(::oNameSpaces)
    FreeObj(::aDelNode)

    ::oXMLManager := Nil
    ::oNameSpaces := Nil

Return
