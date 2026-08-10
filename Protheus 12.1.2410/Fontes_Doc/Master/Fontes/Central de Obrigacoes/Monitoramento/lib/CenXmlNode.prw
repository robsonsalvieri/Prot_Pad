#include "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} 
    Classe de controle de nós em XML
    @type  Class
    @author lima.everton
    @since 18/12/2019
    @version version
/*/

#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF

#DEFINE NAME 1
#DEFINE NODE 2
#DEFINE ATRIBUTE 1
#DEFINE VALUE 2

Class XmlNode

	Data cNodeName
	Data cValue
	Data lObrig
	Data lKeepOpen
	Data cXml
	Data cHashValues
	Data aNodes
	Data hAtribute
	Data cNameSpace
       
	Method New(cNodeName, cValue) Constructor
	Method Destroy()
	Method setXML(cXml)
	Method getXML()
	Method getHashValues()
	Method getNodeName()
	Method setNodeName(cNodeName)
	Method getValue()
	Method setValue(cValue)
	Method setObrig(lObrig)
	Method addNode(cNodeId, cNodeName)
	Method getNode(cNodeId)
	Method openTag(cTagName,hAtribute)
	Method seriAtrib(hAtribute)
	Method closeTag(cTagName)
	Method setAtribute(cAtribute,cValue)
	Method serialize()
	Method setNameSpace(cNameSpace)
	Method getNameSpace()
	Method clearChildren()
	Method keepOpen()
	Method closeTags()

EndClass

Method New(cNodeName, cValue) Class XmlNode
	self:cXml := ""
	self:cHashValues := ""
	self:cNodeName := cNodeName
	self:cValue := ""
	self:lObrig := .T.
	self:lKeepOpen := .F.
	self:cNameSpace := ""
	self:hAtribute := THashMap():New()
	self:aNodes := {}
Return self

Method Destroy() Class XmlNode

	If !Empty(self:aNodes)
		self:clearChildren()
	EndIf

	DelClassIntf()
	
Return

Method setXML(cXml) Class XmlNode
	self:cXml := cXml
Return

Method getXML() Class XmlNode
Return self:cXml

Method getHashValues() Class XmlNode
Return self:cHashValues

Method getNodeName() Class XmlNode
Return self:cNodeName

Method setNodeName(cNodeName) Class XmlNode
	self:cNodeName := cNodeName
Return 

Method getValue() Class XmlNode
Return self:cValue

Method setValue(cValue) Class XmlNode
	self:cValue := cValue
Return self

Method setObrig(lObrig) Class XmlNode
	self:lObrig := lObrig
Return self

Method addNode(cNodeId, cNodeName) Class XmlNode
	Default cNodeName := cNodeId
	Default cValue := ""
    AAdd(self:aNodes, {cNodeId,XmlNode():New(cNodeName)})
	self:aNodes[Len(self:aNodes)][NODE]:setNameSpace(self:getNameSpace())
Return self:aNodes[Len(self:aNodes)][NODE]

Method getNode(cNodeId) Class XmlNode
    Local nPos := 0
    Local oNode := Nil
    nPos := aScan(self:aNodes,{ |aNodes| AllTrim(aNodes[1]) == cNodeId })
    If nPos > 0 
        oNode := self:aNodes[nPos,NODE]
    EndIf
Return oNode

Method openTag(cTagName,hAtribute) Class XmlNode
    Local cTagOpen := ''
	Default cTagName := "noName"
	Default hAtribute := THashMap():New()

	cTagOpen += '<'
	cTagOpen += self:getNameSpace()
	cTagOpen += cTagName
    cTagOpen += self:seriAtrib(hAtribute)
    cTagOpen += '>' //+ CRLF
Return cTagOpen

Method seriAtrib(hAtribute) Class XmlNode
	Local aAtribList := {}
	Local nLen := 0
	Local nAtrib := 0
	Local cValue := ""
	Local cAtribute := ""
	Default hAtribute := THashMap():New()

	hAtribute:list(aAtribList)
	nLen := Len(aAtribList)
	For nAtrib := 1 to nLen
		hAtribute:get(aAtribList[nAtrib][ATRIBUTE],@cValue)
		cAtribute += ' '+aAtribList[nAtrib][ATRIBUTE]+'='+'"'+ cValue +'"'
	Next nAtrib	

Return cAtribute

Method closeTag(cTagName) Class XmlNode
Return '</'+self:getNameSpace()+cTagName+'>'

Method setAtribute(cAtribute,cValue) Class XmlNode
	self:hAtribute:set(cAtribute,cValue)
Return

Method serialize() Class XmlNode
	Local nNode := 0
	Local nLenNodes := Len(self:aNodes)
	Local cValue := cValToChar(self:getValue())
	Local lPrintTag := self:lObrig .OR. (!Empty(cValue) .OR. nLenNodes > 0)

	If lPrintTag
		self:cXml += self:openTag(self:getNodeName(), self:hAtribute)
		For nNode := 1 to nLenNodes
			self:cXml += self:aNodes[nNode][NODE]:serialize()
			self:cHashValues += self:aNodes[nNode][NODE]:getHashValues()
		Next nNode
		self:cXml += cValue
		self:cHashValues += cValue
		If !self:lKeepOpen
			self:cXml += self:closeTag(self:getNodeName())
		EndIf
	EndIf

Return self:getXML()

Method closeTags() Class XmlNode
	Local nNode := 0
	Local cXml := ""
	Local nLenNodes := Len(self:aNodes)
	
	If self:lKeepOpen
		For nNode := 1 to nLenNodes
			cXml += self:aNodes[nNode][NODE]:closeTags()
		Next nNode
		cXml += self:closeTag(self:getNodeName())
	EndIf

Return cXml

Method setNameSpace(cNameSpace) Class XmlNode
	self:cNameSpace := cNameSpace
Return

Method keepOpen(lKeepOpen) Class XmlNode
	self:lKeepOpen := lKeepOpen
Return

Method getNameSpace() Class XmlNode
Return self:cNameSpace

Method clearChildren() Class XmlNode
	Local nNode := 0
	Local nLen := Len(self:aNodes)
	For nNode := 1 to nLen
		self:aNodes[nNode][NODE]:destroy()
		FreeObj(self:aNodes[nNode][NODE])
		self:aNodes[nNode][NODE] := nil
	Next nNode
	
	For nNode := 1 to nLen
		aDel(self:aNodes,nNode)
	Next
	
	aSize(self:aNodes,0)
	self:aNodes := {}
Return
