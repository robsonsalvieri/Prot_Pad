#include "TOTVS.CH"
#include 'FWMVCDEF.CH'
#define MSGCAB 'mensagemEnvioANS'
#define HEADER 'cabecalho'
#define BODY   'Mensagem'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenMonXTQ
    Classe para importacao dos arquivos XTQ/XTQ ansParaOperadora do Monitoramento

    @type  Class
    @author everton.mateus
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenMonXTQ
    
    Data cCodOpe as String
    Data cFolder as String
    Data cFileName as String
    Data cFileExten as String
    Data cError as String
    Data cDate as String
    Data cHora as String
    Data oXml
    Data lAuto      
    Data cXmlAuto   
    Data cTissVersion   

    Data cAno       as String
    Data cMes       as String
    Data cLote      as String

    Method New() Constructor
    Method destroy()
    Method procLote()
    Method factImportador(cTipoLote)
    Method startFile(oCltBKW)
    Method vldCabec()
    Method setError(cError)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author everton.mateus
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenMonXTQ

    self:cCodOpe     := ""
    self:cFolder     := ""
    self:cFileName   := ""
    self:cFileExten  := ""
    self:cError      := ""
    self:cDate       := ""
    self:cHora       := ""
    self:oXml        := nil

    self:cAno        := ""
    self:cMes        := ""
    self:cLote       := ""
	
	self:lAuto       := .F.
    self:cXmlAuto    := ""
    self:cTissVersion:=""

Return self

Method destroy() Class CenMonXTQ
    If !Empty(self:oXml)
        FreeObj(self:oXml)
        self:oXml := nil
    EndIf
Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procLote
    Processa a geracao XTQ de um lote

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procLote() Class CenMonXTQ
    Local aArquivos := {}
    Local nFile := 0
    Local nLen := 0
    Local cPath := "/ans:mensagemEnvioANS/ans:cabecalho/ans:identificacaoTransacao"
    Local oImp := nil
    Local cPathSrv := "\monitoramento\xtq\"
    Local aAnos := {}
    Local aMeses := {}
    Local nAno := 0
    Local nLenAno := 0
    Local nMes := 0
    Local nLenMes := 0
    Local cTipo := ""
    Local cAno := ""
    Local cMes := ""
	aAnos := Directory(PLSMUDSIS(cPathSrv) + "*.*", "D")
    nLenAno := Len(aAnos)
    For nAno := 1 to nLenAno
        cAno := aAnos[nAno][1]
        cTipo := aAnos[nAno][5]
        If !(cAno == "." .OR. cAno == ".." ) .AND. cTipo == "D"
            aMeses := Directory(PLSMUDSIS(cPathSrv) + "\" + cAno +"\*.*", "D")
            nLenMes := Len(aMeses)
            For nMes := 1 to nLenMes
                cMes := aMeses[nMes][1]
                cTipo := aMeses[nMes][5]
                If !(cMes == "." .OR. cMes == ".." ) .AND. cTipo == "D"
                    aArquivos := Directory(PLSMUDSIS(cPathSrv)  + "\" + cAno + "\" + cMes + "\*.xtq", "D")
                    nLen := Len(aArquivos)
                    For nFile := 1 to nLen
                        self:cCodOpe := Substr(aArquivos[nFile][1],1,6)
                        self:cFolder := cPathSrv + "\" + cAno + "\" + cMes + "\"
                        self:cFileName := aArquivos[nFile][1]
                        self:startFile()
                        if empty(self:cError)
                            oImp := self:factImportador()
                            oImp:oXml := self:oXml
                            oImp:cCodOpe := self:cCodOpe
                            oImp:cFolder := self:cFolder
                            oImp:cFileName := self:cFileName
                            oImp:cAno  := Substr(oImp:oXML:XPathGetNodeValue( cPath+"/ans:competenciaLote"),1,4)
                            oImp:cMes  := "0"+Substr(oImp:oXML:XPathGetNodeValue( cPath+"/ans:competenciaLote"),5,2)
                            oImp:cLote := self:cLote
                            oImp:cDate := self:cDate                            
                            oImp:cHora := self:cHora
                            oImp:cTissVersion := self:cTissVersion
                            oImp:procFile()
                            oImp:destroy()
                        endIf
                        FreeObj(oImp)
                        oImp := nil
                        FErase(self:cFolder+self:cFileName)
                    Next nFile
                 EndIf
            Next nMes
        EndIf
    Next nAno
Return

Method factImportador(cTipoLote) Class CenMonXTQ
    Local oGerador := nil
    Default cTipoLote := ""

    oGerador := CenXTQGui():New()
   
Return oGerador

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} startFile
    Inicia a importacao de um arquivo XTQ/XTQ

    @type  Class
    @author everton.mateus
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method startFile(oCltBKW) Class CenMonXTQ

    Local cPathFile  := self:cFolder+self:cFileName
    Local aNS        := {}
    Local lOK        := .F.

    self:oXML := TXmlManager():New()
    lOK  := iif(self:lAuto,self:oXML:Read(self:cXmlAuto,nil,nil,self:oXML:Parse_nsclean),self:oXML:ReadFile( cPathFile,,self:oXML:Parse_nsclean))
    
    if lOK
        aNS := self:oXML:XPathGetRootNsList()
        self:oXML:XPathRegisterNs(aNS[1,1],aNS[1,2])
        self:vldCabec() //Valida dados do cabecalho
    else
        self:setError("Erro: "+self:oXML:Error())
    endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldCabec
    Valida o cabecalho de um XTQ e verifica se o lote existe

    @type  Class
    @author everton.mateus
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method vldCabec() Class CenMonXTQ
    
    Local cCodOpeFil := ""
    Local cPath      := "/ans:mensagemEnvioANS/ans:cabecalho"

    if self:oXml:XPathHasNode(cPath)

        cCodOpeFil := self:oXML:XPathGetNodeValue( cPath+"/ans:registroANS" )
        iif(empty(cCodOpeFil) .Or. self:cCodOpe <> cCodOpeFil,self:setError('O código da operadora informada na tag "ans:registroANS" é diferente da operadora padrão.'),nil)
        self:cLote := self:oXML:XPathGetNodeValue( cPath+"/ans:identificacaoTransacao/ans:numeroLote" )
        self:cDate := self:oXML:XPathGetNodeValue( cPath+"/ans:identificacaoTransacao/ans:dataRegistroTransacao" )
        self:cHora := self:oXML:XPathGetNodeValue( cPath+"/ans:identificacaoTransacao/ans:horaRegistroTransacao" )
        self:cTissVersion := self:oXML:XPathGetNodeValue( cPath+"/ans:versaoPadrao" )

    else
        self:setError('Nao foi encontrada a estrutura "'+cPath+'"')
    endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setError
    Seta um erro ao atributo correspondente

    @type  Class
    @author everton.mateus
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method setError(cError) Class CenMonXTQ
    self:cError := cError
Return

