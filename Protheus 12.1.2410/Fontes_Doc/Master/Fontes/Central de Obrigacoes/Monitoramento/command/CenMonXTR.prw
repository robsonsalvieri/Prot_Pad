#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

#define GUIMON '1'
#define GUIFOR '2'
#define GUIOUT '3'
#define GUIPRE '4'

#define MONTISSTAB "38"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenMonXTR
    Classe para importacao dos arquivos XTR/XTQ ansParaOperadora do Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenMonXTR 
    
    Data cCodOpe as String
    Data cFolder as String
    Data cFileName as String
    Data cFileExten as String
    Data cError as String
    Data oXml 
    Data oCltAtuReg
    Data oCltBKW
    Data oHmTissTer
    Data oHashCodes
    Data cCodObrig as String
    Data cAno as String
    Data cMes as String
    Data cLote as String
    
    Method New() Constructor
    Method destroy()
    Method startFile()
    Method vldCabec()
    Method procLote()
    Method factImportador(cTipoLote)
    Method procArqRej()
    Method atuLoteGui()    
    Method setError()
    Method grvCritica(oCritica)

EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenMonXTR

    self:cCodOpe    := ""
    self:cFolder    := ""
    self:cFileName  := ""
    self:cFileExten := ""
    self:cError     := ""
    self:cLote      := ""
    self:oXml       := nil
    self:oCltAtuReg := nil
    self:cCodObrig  := ""
    self:cAno       := ""
    self:cMes       := ""
    self:oCltBKW    := CenCltBKW():New()
    self:oHashCodes := CenMoCodFi():New()
    self:oHmTissTer := CenTissTer():New()
    
Return self

Method destroy() Class CenMonXTR
    If !Empty(self:oCltBKW)
        self:oCltBKW:destroy()
        FreeObj(self:oCltBKW)
        self:oCltBKW := nil
    EndIf
    If !Empty(self:oCltAtuReg)
        self:oCltAtuReg:destroy()
        FreeObj(self:oCltAtuReg)
        self:oCltAtuReg := nil
    EndIf
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
Method procLote() Class CenMonXTR
    Local aArquivos := {}
    Local nFile := 0
    Local nLen := 0
    Local cPath := "/ans:mensagemEnvioANS/ans:cabecalho/ans:identificacaoTransacao"
    Local oImp := nil
    Local cPathSrv := "\monitoramento\xtr\"
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
                    aArquivos := Directory(PLSMUDSIS(cPathSrv)  + "\" + cAno + "\" + cMes + "\*.xtr", "D")
                    nLen := Len(aArquivos)
                    For nFile := 1 to nLen
                        self:cCodOpe := Substr(aArquivos[nFile][1],1,6)
                        self:cFolder := cPathSrv + "\" + cAno + "\" + cMes + "\"
                        self:cFileName := aArquivos[nFile][1]
                        self:startFile()
                        if empty(self:cError)
                            oImp := self:factImportador(self:oCltBKW:getValue("BKW_FORREM"))
                            oImp:oCltBKW := self:oCltBKW
                            oImp:oXml := self:oXml
                            oImp:cCodOpe := self:cCodOpe
                            oImp:cFolder := self:cFolder
                            oImp:cFileName := self:cFileName
                            oImp:cAno  := Substr(oImp:oXML:XPathGetNodeValue( cPath+"/ans:competenciaLote"),1,4)
                            oImp:cMes  := "0"+Substr(oImp:oXML:XPathGetNodeValue( cPath+"/ans:competenciaLote"),5,2)
                            oImp:cLote := self:cLote
                            oImp:cCodObrig := self:cCodObrig
                            if oImp:oXml:XPathHasNode("/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:arquivoRejeitado")
                                oImp:procArqRej()
                            elseIf oImp:oXml:XPathHasNode("/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento")
                                oImp:procFile()
                                oImp:atuLoteGui()
                            endIf    
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

Method factImportador(cTipoLote) Class CenMonXTR
    Local oGerador := nil
    If cTipoLote == GUIMON 
        oGerador := CenXTRGui():New()
    ElseIf cTipoLote == GUIFOR 
        oGerador := CenXTRFor():New()
    ElseIf cTipoLote == GUIOUT 
        oGerador := CenXTRRem():New()
    ElseIf cTipoLote == GUIPRE 
        oGerador := CenXTRPre():New()
    EndIf
Return oGerador

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} startFile
    Inicia a importacao de um arquivo XTR

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method startFile() Class CenMonXTR

    Local cPathFile  := self:cFolder+self:cFileName
    Local aNS        := {}
    Local lOK        := .F.

    self:oXML := TXmlManager():New()
    lOK  := self:oXML:ReadFile( cPathFile,,self:oXML:Parse_nsclean)
    
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
    Valida o cabecalho de um XTR e verifica se o lote existe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method vldCabec() Class CenMonXTR

    Local cCodOpeFil := ""
    Local cPath      := "/ans:mensagemEnvioANS/ans:cabecalho"

    if self:oXml:XPathHasNode(cPath)

        cCodOpeFil := self:oXML:XPathGetNodeValue( cPath+"/ans:registroANS" )
        iif(empty(cCodOpeFil) .Or. self:cCodOpe <> cCodOpeFil,self:setError('O codigo da operadora informada na tag "ans:registroANS" � diferente da operadora padrao.'),nil)
        self:cLote := self:oXML:XPathGetNodeValue( cPath+"/ans:identificacaoTransacao/ans:numeroLote" )

        self:oCltBKW:setValue("operatorRecord",self:cCodOpe)
        self:oCltBKW:setValue("batchCode"     ,self:cLote)
        if self:oCltBKW:bscChaPrim()
            self:oCltBKW:mapFromDao()
            self:cCodObrig := self:oCltBKW:getValue("BKW_CDOBRI")
        else
            self:setError("O lote informado no arquivo "+self:cFileName+self:cFileExten+" nao foi encontrado no sistema.")
        endIf
    else
        self:setError('Nao foi encontrada a estrutura "'+cPath+'"')
    endIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procArqRej
    Processa um arquivo rejeitado

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procArqRej() Class CenMonXTR
    Local oCritica := CriticaB3F():New()
    Local cCodErro := self:oXML:XPathGetNodeValue("/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:arquivoRejeitado/ans:codigoRejeicao")

    //Gera registro na tabela B3F
    oCritica:setTpVld("3")
    oCritica:setAlias("BKW")
    oCritica:setChaveOri(BKW->(BKW_CODOPE+BKW_CODLOT))
    oCritica:setCodANS(cCodErro)
    oCritica:setDesOri(self:cLote)
    oCritica:setMsgCrit(self:oHmTissTer:getTermDesc(MONTISSTAB,cCodErro))

    self:grvCritica(oCritica)
        
    self:oCltBKW:setValue("status","5")
    self:oCltBKW:update()

    //Atualiza o status do lote nos registros
    self:oCltAtuReg:setValue("batchCode",self:cLote)
    self:oCltAtuReg:atuStaANS('5','9')
    self:oCltAtuReg:destroy()
    
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuLoteGui
    Atualiza um lote quando processado as guias (tag registrosRejeitados)

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method atuLoteGui() Class CenMonXTR
    
    Local nRegInc   := 0
    Local nRegAlt   := 0
    Local nRegExc   := 0
    Local nRegErros := 0

    //Atualiza o status do lote nos registros
    self:oCltAtuReg:setValue("batchCode",self:cLote)

    cPath := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:resumoProcessamentoTotais"
    nRegInc   := val(self:oXML:XPathGetNodeValue(cPath + "/ans:registrosIncluidos"))
    nRegAlt   := val(self:oXML:XPathGetNodeValue(cPath + "/ans:registrosAlterados"))
    nRegExc   := val(self:oXML:XPathGetNodeValue(cPath + "/ans:registrosExcluidos"))
    nRegErros := val(self:oXML:XPathGetNodeValue(cPath + "/ans:registrosComErros"))
            
    if nRegErros > 0
        self:oCltAtuReg:atuStaANS('5','6')
        self:oCltBKW:setValue("status","5")
    else
        self:oCltAtuReg:atuStaANS('6','5')
        self:oCltBKW:setValue("status","6")
    endIf
    self:oCltAtuReg:destroy()

    self:oCltBKW:setValue("includedRecords" ,nRegInc)
    self:oCltBKW:setValue("changedRecords"  ,nRegAlt)
    self:oCltBKW:setValue("deletedRecords"  ,nRegExc)
    self:oCltBKW:setValue("incorrectRecords",nRegErros)
    self:oCltBKW:update()

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodos Set
    Seta um erro ao atributo correspondente

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method setError(cError) Class CenMonXTR
    self:cError := cError
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} grvCritica
    Grava criticas da guias na B3F

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method grvCritica(oCritica,cIdCampo) Class CenMonXTR

    Local oVal       := nil
    Local nPosChar   := 0
    Default cIdCampo := ""

    dbSelectArea('B3F')
	B3F->(DbSetOrder(7))
    if !Empty(cIdCampo) .And. HMGet(self:oHashCodes:oHash,cIdCampo,oVal)
        if !Empty(oVal) .And. ((nPosChar := At("-",oVal))  > 0 )
            oCritica:setCpoCrit(Substr(oVal,1,nPosChar-1))
            oCritica:setSolCrit("Verifique o campo "+cIdCampo+": "+Substr(oVal,nPosChar+1,len(oVal)))
        endIf
    endIf
    oCritica:setCodCrit(oCritica:cCodANS)

    lRet := PlObInCrit(	self:cCodOpe,;
                        self:cCodObrig,;
                        self:cAno,;
                        self:cMes,;
						oCritica:cAlias,;
						STR((oCritica:cAlias)->(Recno()), 10, 0),;
						oCritica:cCodCrit,;
						oCritica:cMsgCrit,;
						oCritica:cSolCrit,;
						oCritica:cCpoCrit,;
						oCritica:cTpVld,;
						oCritica:cCodANS,;
						oCritica:cChaveOri,;
						oCritica:cDesOri,;
						oCritica:cStatus )

Return
