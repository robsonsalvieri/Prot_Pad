#include "TOTVS.CH"
#include 'Fileio.ch'

/*/{Protheus.doc} 
    Classe de geranciamento, para criação de objetos XML
    @type  Class
    @author lima.everton
    @since 18/12/2019
    @version version
/*/

#DEFINE NAME 1
#DEFINE NODE 2
#DEFINE lLinux IsSrvUnix()
#IFDEF lLinux
	#DEFINE barra "\"
#ELSE
	#DEFINE barra "/"
#ENDIF

Class XmlManagement 

    Data cVersion
    Data cEncoding
    Data cStandalone
    Data cExtension
    Data cXSDFile
    Data cError
    Data cWarning
    Data cNameSpace
    Data nFile
    Data nHashFile
    Data dDateFile
    Data cTimeFile

    Data cPath
    Data cHeader
    Data cName
    Data cXml
    Data cHashValues
    Data aNodes
    Data aHashValues

    Method new() Constructor
    Method destroy()
    Method getExtension()
    Method setExtension(cExtension)
    Method addNode(cNodeName)
    Method addHashValue(cValue)
    Method getNode(cNodeName)
    Method setPath(cPath)
    Method setName(cName)
    Method setVersion(cVersion)
    Method setEncoding(cEncoding)
    Method setStandalone(cStandalone)
    Method setHeader(cHeader)
    Method setXML(cXML)
    Method setXSDFile(cXSDFile)
    Method getPath()
    Method getName()
    Method getVersion()
    Method getEncoding()
    Method getStandalone()
    Method getHeader()
    Method getXML()
    Method getXSDFile()
    Method headerSerialize()
    Method save(nFile, cStr)
    Method createFile()
    Method closeFiles()
    Method serialize()
    Method flush(oNode)
    Method getHash()
    Method getHashValues()
    Method vldSchema()
    Method setNameSpace(cNameSpace) 
    Method getNameSpace() 
    Method finishFile() 
    Method closeTag() 

EndClass

Method new() Class XmlManagement
	self:cXml := ""
	self:cHashValues := ""
    self:cVersion := "1.0" 
    self:cEncoding := "ISO-8859-1"
    self:cStandalone := "no"
    self:cExtension := ".xml"
    self:cXSDFile := ""
    self:cError := ""
    self:cWarning := ""
    self:cNameSpace := ""
    self:dDateFile := dDataBase
    self:cTimeFile := Time()
    self:aNodes := {}
    self:aHashValues := {}
    self:headerSerialize()
    self:nFile := 0
    self:nHashFile := 0
Return self

Method destroy() Class XmlManagement
    Local nLen := 0
    Local nNode := 0

	If !Empty(self:aNodes)
		nLen := Len(self:aNodes)
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
	EndIf

	If !Empty(self:aHashValues)
		nLen := Len(self:aHashValues)
		For nNode := 1 to nLen
			self:aHashValues[nNode][NODE]:destroy()
			FreeObj(self:aHashValues[nNode][NODE])
			self:aHashValues[nNode][NODE] := nil
		Next nNode

		For nNode := 1 to nLen
			aDel(self:aHashValues,nNode)
		Next
		
		aSize(self:aHashValues,0)
		self:aHashValues := {}
	EndIf

	DelClassIntf()
	
Return

Method getExtension() Class XmlManagement
Return self:cExtension

Method setExtension(cExtension) Class XmlManagement
    self:cExtension := cExtension
Return 

Method addNode(cNodeName) Class XmlManagement
    AAdd(self:aNodes, {cNodeName,XmlNode():New(cNodeName)})
    self:aNodes[Len(self:aNodes)][NODE]:setNameSpace(self:getNameSpace())
Return self:aNodes[Len(self:aNodes)][NODE]

Method addHashValue(cValue) Class XmlManagement
    self:save(self:nHashFile,cValue)
Return

Method getNode(cNodeName) Class XmlManagement
    Local nPos := 0
    Local oNode := Nil
    nPos := aScan(self:aNodes,{ |aNodes| AllTrim(aNodes[1]) == cNodeName })
    If nPos > 0 
        oNode := self:aNodes[nPos,NODE]
    EndIf
Return oNode

Method setPath(cPath) Class XmlManagement 
    self:cPath := cPath
Return 

Method setName(cName) Class XmlManagement 
    self:cName := cName
Return 

Method setVersion(cVersion) Class XmlManagement
    self:cVersion := cVersion
Return 

Method setEncoding(cEncoding) Class XmlManagement
    self:cEncoding := cEncoding
Return 

Method setStandalone(cStandalone) Class XmlManagement
    self:cStandalone := cStandalone
Return 

Method setHeader(cHeader) Class XmlManagement
    self:cHeader := cHeader
Return 

Method setXML(cXML) Class XmlManagement
    self:cXML := cXML
Return 

Method setXSDFile(cXSDFile) Class XmlManagement
    self:cXSDFile := cXSDFile
Return 

Method getPath() Class XmlManagement 
Return self:cPath

Method getName() Class XmlManagement 
Return self:cName

Method getVersion() Class XmlManagement
Return self:cVersion

Method getEncoding() Class XmlManagement
Return self:cEncoding

Method getStandalone() Class XmlManagement
Return self:cStandalone

Method getHeader() Class XmlManagement
Return self:cHeader

Method getXML() Class XmlManagement
Return self:cXML

Method getXSDFile() Class XmlManagement
Return self:cXSDFile

Method headerSerialize() Class XmlManagement 
    self:setHeader('<?xml version="'+self:getVersion()+'" encoding="'+self:getEncoding()+'" standalone="'+self:getStandalone()+'"?>')
Return

Method save(nFile, cStr) Class XmlManagement 
    If nFile > 0
        fwrite(nFile, cStr)
    EndIf
Return

Method createFile() Class XmlManagement 
    Local cFile := self:getPath()+barra+self:getName()+self:getExtension()
    self:nFile      := FCreate(cFile,0,,.F.)
    self:nHashFile  := FCreate(cFile+".hash",0,,.F.)
    self:save(self:nFile,self:getHeader())
Return

Method closeFiles() Class XmlManagement 
    fclose(self:nFile)
    fclose(self:nHashFile)
    FErase(self:getPath()+barra+self:getName()+self:getExtension()+".hash")
Return 

Method serialize() Class XmlManagement 
    Local nNode := 0
    Local nLen := 0
    Local cXml := ""
    Local cHashValues := ""

    nLen := Len(self:aNodes)
    For nNode := 1 to nLen
        cXml += self:aNodes[nNode][NODE]:serialize()
        cHashValues += self:aNodes[nNode][NODE]:getHashValues()
    Next nNode
    self:cXml := cXml
    self:cHashValues := cHashValues
Return self:getXML()

Method flush(oNode) Class XmlManagement 
    Local nNode := 0
    Local nLen := 0
    Local cXml := ""
    Local cHashValues := ""

    nLen := Len(self:aNodes)
    For nNode := 1 to nLen
        cXml += oNode:serialize()
        cHashValues += oNode:getHashValues()
    Next nNode

    self:save(self:nFile,cXml)
    self:save(self:nHashFile,cHashValues)
Return

Method getHash() Class XmlManagement
    Local cHash :=""
    Local cFileHash := self:getPath()+barra+self:getName()+self:getExtension()+".hash"
    fclose(self:nHashFile)
    cHash := MD5File(cFileHash,2)
    self:nHashFile := FOpen(cFileHash, FO_READWRITE+FO_EXCLUSIVE)
Return cHash

Method getHashValues() Class XmlManagement 
Return self:cHashValues

Method vldSchema() Class XmlManagement 
    Local cError := ""
    Local cWarning := ""
    Local lValid := .T.
    //trocar para validar o arquivo final gerado
    lValid := XmlFVldSch(self:getPath()+barra+self:getName()+self:getExtension(),self:cXSDFile, @cError, @cWarning )
    self:cError := cError
    self:cWarning := cWarning

Return lValid

Method setNameSpace(cNameSpace)  Class XmlManagement 
	self:cNameSpace := cNameSpace
Return

Method getNameSpace()  Class XmlManagement 
Return self:cNameSpace

Method finishFile()  Class XmlManagement 
    self:closeFiles()
Return self:cNameSpace

Method closeTag(oNode) Class XmlManagement
    Local cXml := ""

    cXml += oNode:closeTag(oNode:getNodeName())
    self:save(self:nFile,cXml)
Return