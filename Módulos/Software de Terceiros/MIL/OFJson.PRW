
#include 'protheus.ch'

/*/{Protheus.doc} OFJson
	Classe criada para substituir a interna nossa DMS_Json que na 25 parece que
	não funciona mais e a classe padrao JsonObject não atende a valores default
	
	@type function
	@author Vinicius Gati
	@since 30/04/2020
/*/
Class OFJson
	Data oIntJson

	Method New() CONSTRUCTOR
	Method fromJson()
	Method GetValue()
	Method SetValue()
	Method ToJson()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 30/04/2020
/*/
Method New() Class OFJson
	::oIntJson := JsonObject():New()
Return SELF


Method GetValue(cAttr, xDef) Class OFJson
	local uVal := self:oIntJson[cAttr]
	if ValType(uVal) == "U"
		return xDef
	endif
	if ValType(uVal) == "J"
		xobj := OFJson():New()
		xobj:fromJson(uVal:toJson())
		return xobj
	endif
return uVal

Method SetValue(cAttr, xVal) Class OFJson
	self:oIntJson[cAttr] := xVal
return

Method ToJson() Class OFJson
return self:oIntJson:toJson()

/*/{Protheus.doc} fromJson
	só repassa para o JsonObject

	@type function
	@author Vinicius Gati
	@since 30/04/2020
/*/
Method fromJson(cJson) Class OFJson
Return self:oIntJson:fromJson(cJson)