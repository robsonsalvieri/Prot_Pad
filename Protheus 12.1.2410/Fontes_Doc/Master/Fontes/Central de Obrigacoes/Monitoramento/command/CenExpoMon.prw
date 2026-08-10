#include "TOTVS.CH"
#include 'FWMVCDEF.CH'
#define MSGCAB 'mensagemEnvioANS'
#define HEADER 'cabecalho'
#define BODY   'Mensagem'
#define OPEANS 'operadoraParaANS'
#define EPIL   'epilogo'
#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define barra "\"
    #define PATHMONIT '\monitoramento'
    #define XTEFOLDER '\monitoramento\xte'
    #define XTRFOLDER '\monitoramento\xtr'
    #define XTQFOLDER '\monitoramento\xtq'
#ELSE
	#define barra "/"
    #define PATHMONIT '/monitoramento'
    #define XTEFOLDER '/monitoramento/xte'
    #define XTRFOLDER '/monitoramento/xtr'
    #define XTQFOLDER '/monitoramento/xtq'

#ENDIF

#define NAME 1
#define NODE 2
#define QTDFLUSH 20
#define ARQUIVO_LOG	"geracao_de_arquivo_monitoramento"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenExpoMon
    Classe para a geracao dos arquivos XTE operadoraParaANS do Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenExpoMon

    Data cCodOpe as String
    Data cAno as String
    Data cMes as String 
    Data cCodObrig as String
    Data cFileName as String
    Data cError as String
    Data cWarning as String
    Data cVersion as String
	Data oCltAlias
    Data oCenLogger

    Method New() Constructor
    Method createDir()
    Method startFile()
    Method finishFile(oXml)
    Method atuBatch(oXml,oCltBKW)
    Method retFilName(oCltBKW)
    Method maskDate(cDate)
    Method maskValue(nValue)
    Method getVerTiss(cVersao)
    Method Destroy()
    Method flush(oNode)
    Method procLote(oCltBKW)
    Method procSemMov(oCltBKW)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenExpoMon
    self:cCodOpe   := ""
    self:cAno      := ""
    self:cMes      := ""
    self:cCodObrig := ""
    self:cFileName := ""
    self:cVersion  := "1.01.00"
    self:cError    := ""
    self:cWarning  := ""
    self:oCltAlias := nil
    self:oCenLogger := CenLogger():New()
Return self

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Destroy
    Finaliza/destroi objeto da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------

Method destroy() Class CenExpoMon

    If self:oCenLogger <> Nil 
        self:oCenLogger:destroy()
        FreeObj(self:oCenLogger)
        self:oCenLogger := Nil
    EndIf
    DelClassIntf()
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} createDir
    Cria diretorios basicos para o processamento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method createDir() Class CenExpoMon

    iif(!ExistDir(PATHMONIT),MakeDir(PLSMUDSIS(PATHMONIT)),nil)
    iif(!ExistDir(XTEFOLDER),MakeDir(PLSMUDSIS(XTEFOLDER)),nil)
    iif(!ExistDir(XTRFOLDER),MakeDir(PLSMUDSIS(XTRFOLDER)),nil)
    iif(!ExistDir(XTQFOLDER),MakeDir(PLSMUDSIS(XTQFOLDER)),nil)

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} startFile
    Processa a geracao XTE de um lote Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method startFile(oCltBKW) Class CenExpoMon

    Local oXml := XmlManagement():New()
    Local cPathFile := PLSMUDSIS(XTEFOLDER+barra+oCltBKW:getValue("referenceYear"))
    Local cLoc      := ""

    self:createDir()
    iif(!ExistDir(cPathFile),MakeDir(cPathFile),nil)
    cPathFile += barra+Substr(oCltBKW:getValue("commitmentCode"),2,2)
    iif(!ExistDir(cPathFile),MakeDir(cPathFile),nil)
    
    self:retFilName(oCltBKW) 
    oXml:setPath(cPathFile)
    oXml:setName(self:cFileName)
    oXml:setExtension(".xte")
    oXml:setNameSpace("ans:")
    cLoc:=PLSMUDSIS(PATHMONIT+barra)
    oXml:setXSDFile(cLoc+"tissMonitoramentoV1_01_00.xsd")
    oXml:createFile()

    oXml:addNode(MSGCAB):keepOpen(.T.)
    
    oXml:getNode(MSGCAB):setAtribute("xmlns:ans", "http://www.ans.gov.br/padroes/tiss/schemas")
    oXml:getNode(MSGCAB):setAtribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
    oXml:getNode(MSGCAB):setAtribute("xsi:schemaLocation", "http://www.ans.gov.br/padroes/tiss/schemas")

    //Cabecalho
    oXml:getNode(MSGCAB):addNode(HEADER):addNode('identificacaoTransacao')
    oXml:getNode(MSGCAB):getNode(HEADER):getNode('identificacaoTransacao'):addNode("tipoTransacao"):setValue("MONITORAMENTO")
    oXml:getNode(MSGCAB):getNode(HEADER):getNode('identificacaoTransacao'):addNode("numeroLote"):setValue(oCltBKW:getValue("batchCode"))
    oXml:getNode(MSGCAB):getNode(HEADER):getNode('identificacaoTransacao'):addNode("competenciaLote"):setValue(oCltBKW:getValue("referenceYear")+Substr(oCltBKW:getValue("commitmentCode"),2,2))
    oXml:getNode(MSGCAB):getNode(HEADER):getNode('identificacaoTransacao'):addNode("dataRegistroTransacao"):setValue(self:maskDate(Dtos(oXml:dDateFile)))
    oXml:getNode(MSGCAB):getNode(HEADER):getNode('identificacaoTransacao'):addNode("horaRegistroTransacao"):setValue(oXml:cTimeFile)
    oXml:getNode(MSGCAB):getNode(HEADER):addNode("registroANS"):setValue(self:cCodOpe)
    oXml:getNode(MSGCAB):getNode(HEADER):addNode("versaoPadrao"):setValue(self:cVersion)
    oXml:getNode(MSGCAB):addNode(BODY):keepOpen(.T.)
    oXml:getNode(MSGCAB):getNode(BODY):addNode(OPEANS):keepOpen(.T.)
    oXml:flush(oXml)

Return oXml


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} startFile
    Retorna o nome do arquivo que sera utilizado no lote

    @type  Class
    @author renan.almeida
    @since 20200115
/*/
//------------------------------------------------------------------------------------------
Method retFilName(oCltBKW) Class CenExpoMon

    Local cLastFile := ""
    Local cFileName := ""
    Local nContLot  := 0

    if empty(oCltBKW:getValue("file"))

        oCltArqBKW := CenCltBKW():New()
        oCltArqBKW:setValue("operatorRecord" ,oCltBKW:getValue("operatorRecord"))
        oCltArqBKW:setValue("requirementCode",oCltBKW:getValue("requirementCode"))
        oCltArqBKW:setValue("commitmentCode" ,oCltBKW:getValue("commitmentCode"))
        oCltArqBKW:setValue("referenceYear"  ,oCltBKW:getValue("referenceYear"))

        cLastFile  := oCltArqBKW:bscLastArq()
        nContLot := Val(Substr(cLastFile,13,4))
        nContLot++
        cFileName := oCltBKW:getValue("operatorRecord")+;
                     oCltBKW:getValue("referenceYear")+;
                     Substr(oCltBKW:getValue("commitmentCode"),2,2)+;
                     Strzero(nContLot,4)
        
        //Adiciona no lote o nome do arquivo que sera utilizado
        oCltAltLot := CenCltBKW():New()
        oCltAltLot:setValue("operatorRecord",oCltBKW:getValue("operatorRecord"))
        oCltAltLot:setValue("batchCode"     ,oCltBKW:getValue("batchCode"))
        if oCltAltLot:bscChaPrim()
            oCltAltLot:mapFromDao()
            oCltAltLot:SetValue("file",cFileName)
            oCltAltLot:update()
        endIf

        oCltArqBKW:destroy()
        FreeObj(oCltArqBKW)
        oCltArqBKW := nil

        oCltAltLot:destroy()
        FreeObj(oCltAltLot)
        oCltAltLot := nil

    else    
        cFileName := oCltBKW:getValue("file")
    endIf   

    self:cFileName := cFileName
    
Return 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} monta o epilogo do arquivo
    Finaliza o arquivo XTE com informacoes do epilogo

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method finishFile(oXml) Class CenExpoMon

    oXml:closeTag(oXml:getNode(MSGCAB):getNode(BODY):addNode(OPEANS))
    oXml:closeTag(oXml:getNode(MSGCAB):addNode(BODY))
    oXml:getNode(MSGCAB):addNode(EPIL)
    oXml:getNode(MSGCAB):getNode(EPIL):addNode("hash"):setValue(oXml:getHash())
    oXml:flush(oXml:getNode(MSGCAB):getNode(EPIL),.F.)
    oXml:closeTag(oXml:getNode(MSGCAB))
    oXml:finishFile()
    oXml:vldSchema()

    if !empty(oXml:cError) .Or. !empty(oXml:cWarning)
        self:oCenLogger:addLine("MENSAGEM", "Monitoramento - Arquivo "+self:cFileName+" gerado com falhas")
        If !empty(oXml:cError)
            self:oCenLogger:setLogType("E")
            self:oCenLogger:addLine("MENSAGEM", "Erro de schema: "+oXml:cError)
            self:oCenLogger:addLog()
        EndIf
        If !empty(oXml:cWarning)
            self:oCenLogger:setLogType("W")
            self:oCenLogger:addLine("MENSAGEM", "Avisos de schema: "+oXml:cWarning)
            self:oCenLogger:addLog()            
        EndIf
    else
        self:oCenLogger:setLogType("I")
        self:oCenLogger:addLine("MENSAGEM", "Monitoramento - Arquivo "+self:cFileName+" gerado com sucesso.")
        self:oCenLogger:addLog()        
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuBatch
    Finaliza geracao do XTE atualizando informacoes no lote

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method atuBatch(oXml,oCltBKW) Class CenExpoMon

    Local oCltAltLot := CenCltBKW():New()

    oCltAltLot:setValue("operatorRecord",oCltBKW:getValue("operatorRecord"))
    oCltAltLot:setValue("batchCode"     ,oCltBKW:getValue("batchCode"))
    if oCltAltLot:bscChaPrim()
        oCltAltLot:mapFromDao()
        if empty(oXml:cError) .and. empty(oXml:cWarning)
            oCltAltLot:SetValue("status","2")
            oCltAltLot:SetValue("xsdError","")
        else 
            oCltAltLot:SetValue("status","3")
            oCltAltLot:SetValue("xsdError",Alltrim(oXml:cError) + " " + Alltrim(oXml:cWarning))
        endIf
        oCltAltLot:SetValue("processingDate",oXml:dDateFile)
        oCltAltLot:SetValue("processingTime",StrTran(oXml:cTimeFile,":",""))
        oCltAltLot:SetValue("version",self:cVersion )
        oCltAltLot:update()
    endIf
    
    oCltAltLot:destroy()
    FreeObj(oCltAltLot)
    oCltAltLot := nil

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} maskDate
    Ajusta a data para o formato estabelecido pela ANS

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method maskDate(cDate) Class CenExpoMon
    if !Empty(cDate)
        cDate := Substr(cDate,1,4)+"-"+Substr(cDate,5,2)+"-"+Substr(cDate,7,2)
    endIf
Return cDate

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} maskValue
    Ajusta os valores para o formato estabelecido pela ANS

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method maskValue(nValue) Class CenExpoMon
    Local cRet := cValtoChar(nValue)
Return cRet

Method getVerTiss(cVersao) Class CenExpoMon
	Local cRet := ""
	Default cVersao := ""
	
	if( ! empty( cVersao ) )
		if( cVersao == "1.00.00" )
			cRet := "001"
		elseIf( cVersao == "1.01.00" )
			cRet := "002"
		elseIf( cVersao == "2.00.00" )
			cRet := "003"
		elseIf( cVersao == "2.01.01" )
			cRet := "004"
		elseIf( cVersao == "2.01.02" )
			cRet := "005"
		elseIf( cVersao == "2.01.03" )
			cRet := "006"
		elseIf( cVersao == "2.02.01" )
			cRet := "007"
		elseIf( cVersao == "2.02.02" )
			cRet := "008"
		elseIf( cVersao == "2.02.03" )
			cRet := "009"
		elseIf( cVersao == "3.00.00" )
			cRet := "010"
		elseIf( cVersao == "3.00.01" )
			cRet := "011"
		elseIf( cVersao == "3.01.00" )
			cRet := "012"
		elseIf( cVersao == "3.02.00" )
			cRet := "013"
		elseIf( cVersao == "3.02.01" )
			cRet := "014"
		elseIf( cVersao == "3.02.02" )
			cRet := "015"
		elseIf( cVersao == "3.03.00" )
			cRet := "016"
		elseIf( cVersao == "3.03.01" )
			cRet := "017"
		elseIf( cVersao == "3.03.02" )
			cRet := "018"	
		elseIf( cVersao == "3.03.03" )
			cRet := "019"	
		elseIf( cVersao == "3.04.00" )
			cRet := "020"		
		elseIf( cVersao == "3.04.01" )
			cRet := "021"		
		elseIf( cVersao == "3.05.00" )
			cRet := "022"		
		endIf
	endIf

Return cRet

Method flush(oNode) Class CenExpoMon
    Local nNode := 0
    Local nLenNodes := 0

    nLenNodes := Len(oNode:aNodes)
    for nNode := 1 to nLenNodes
        oXml:flush(oNode:aNodes[nNode][NODE])
    Next nNode
    oNode:clearChildren()
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procLote
    Processa a geracao XTE de um lote

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procLote(oCltBKW) Class CenExpoMon

    Local nCont := 0
    Local oAux  := nil

    self:oCltAlias:setValue("operatorRecord" ,self:cCodOpe)
    self:oCltAlias:SetValue("requirementCode",self:cCodObrig)
    self:oCltAlias:SetValue("referenceYear"  ,self:cAno)
    self:oCltAlias:SetValue("commitmentCode" ,self:cMes)
    self:oCltAlias:SetValue("batchCode"      ,oCltBKW:getValue("batchCode"))
    self:oCltAlias:SetValue("status","7")

    if self:oCltAlias:buscar()
        //Inicia o Arquivo (cabecalho/mensagem/operadoraParaAns)
        oXml := self:startFile(oCltBKW)
        while self:oCltAlias:HasNext()
            nCont++
            oAux := self:oCltAlias:GetNext()
            self:procRegist(oXml,oAux,cValtoChar(nCont))
            If nCont % QTDFLUSH == 0
                self:flush(oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS))
                DelClassIntf()
            EndIf
            oAux:destroy()
            FreeObj(oAux)
            oAux := nil
        endDo
        self:flush(oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS))
        DelClassIntf()
        //Finaliza o arquivo (epilogo e calculo do hash)
        self:finishFile(oXml)
        self:atuBatch(oXml,oCltBKW)

        //Informacoes para caso de teste
        self:cError   += oXml:cError
        self:cWarning += oXml:cWarning
    endIf
    
    self:oCltAlias:destroy()
    FreeObj(self:oCltAlias)
    self:oCltAlias := nil

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procSemMov
    Processa a geracao XTE de um lote sem movimentacao

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procSemMov(oCltBKW) Class CenExpoMon

    oXml := self:startFile(oCltBKW)
    oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS):addNode("semMovimentoInclusao"):setValue("5016")
    //Finaliza o arquivo (epilogo e calculo do hash)
    self:flush(oXml:getNode(MSGCAB):getNode(BODY):getNode(OPEANS))
    DelClassIntf()
    self:finishFile(oXml)
    
    self:cError    := oXml:cError
    self:cWarning  := oXml:cWarning
    
Return