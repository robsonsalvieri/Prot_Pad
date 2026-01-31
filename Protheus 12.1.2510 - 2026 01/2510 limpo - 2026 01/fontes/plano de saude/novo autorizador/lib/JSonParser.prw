#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

/*/ Atendimento | Autorizador | JSonParser
Recebe uma String em formato JSon e Des-Serializa em um objeto HashMap
@author Victor Silva
@since 11/2017
/*/

Class JSonParser

	Data cJson
	Data hMap
    Data lJsonValid
    
    Method New() Constructor
    Method setJson(cJson)
	Method parseJson()
	Method get(xKey)
	Method set(xKey,xValue)
    Method setJsonValid(lValid)
    Method isJsonValid()

EndClass

Method New() Class JSonParser
    self:hMap := THashMap():New()
Return self

Method setJson(cJson) Class JSonParser
    self:cJson := cJson
Return

Method parseJson() Class JSonParser
    Local oJson         := TJsonParser():New()
    Local aJsonFields   := {}
    Local aRetErr       := {}
    Local nQtdCampos    := 0
    Local nLenJson      := Len(self:cJson)
    Local nRetParser    := 0

    if oJson:Json_Hash(self:cJson, nLenJson, @aJsonFields, @nRetParser, @self:hMap)

        Do Case
            Case Len(aJsonFields[1]) >= 2
                nQtdCampos := Len(aJsonFields[1][2])
            Case Len(aJsonFields[1][1]) >= 2
                nQtdCampos := Len(aJsonFields[1][1][2])
        EndCase
        
        self:hMap:set("success",.T.)
        self:hMap:set("qtdCampos",nQtdCampos)
        self:setJsonValid(.T.)
    else
        nQtdCampos := Len(aJsonFields)
        self:hMap := THashMap():New()
        self:hMap:set("success",.F.)
        self:setJsonValid(.F.)
        aAdd(aRetErr, "##### [JSON][ERR] #####")
        aAdd(aRetErr, "Parser com erro")
        aAdd(aRetErr, "MSG len: " + AllTrim(Str(nQtdCampos)))
        aAdd(aRetErr, "Bytes lidos: " + AllTrim(Str(nRetParser)))
        aAdd(aRetErr, "Erro a partir: " + SubStr(self:cJson, (nRetParser+1)))
        self:hMap:set("errMsg",aClone(aRetErr))
    endif

Return self:hMap

Method get(xKey) Class JSonParser   
    Local xValue := ""
    self:hMap:get(xKey,@xValue)
Return xValue

Method set(xKey,xValue) Class JSonParser
Return self:hMap:set(xKey,xValue)

Method setJsonValid(lValid) Class JSonParser
    self:lJsonValid := lValid
Return

Method isJsonValid() Class JSonParser
Return self:lJsonValid
//