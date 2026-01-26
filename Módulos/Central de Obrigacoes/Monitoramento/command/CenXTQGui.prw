#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenXTQGui
    Classe para a importacao dos arquivos XTQ operadoraParaANS de Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Class CenXTQGui From CenMonXTQ

	Method New() Constructor
    Method procFile()
 
EndClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Construtor da classe

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method New() Class CenXTQGui

    _Super:new()
    self:cFileExten := ".xtq"
    self:cFolder    := "\monitoramento\xtq\"

return self


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} procFile
    Processa um arquivo XTE de Guia Monitoramento

    @type  Class
    @author renan.almeida
    @since 20200114
/*/
//------------------------------------------------------------------------------------------
Method procFile() Class CenXTQGui

    Local nGuia         := 0
    Local nTotGuias     := 0
    Local nLanc         := 0
    Local nTotLanc      := 0
    Local nOcoGuia      := 0
    Local nTotOcoGuia   := 0
    Local nItem         := 0
    Local nTotItens     := 0
    Local nOcItem       := 0
    Local nTotOcItens   := 0
    Local nPacote       := 0
    Local nTotPacote    := 0
    Local nOcPac        := 0
    Local nTotOcPac     := 0

    Local cPathGuia     := ""
    Local cPathLanc     := ""
    Local cPathOcoGuia  := ""
    Local cPathItens    := ""
    Local cPathOcItens  := ""
    Local cPathPacote   := ""
    Local cPathOcPac    := ""
    
    Local oCltB5I := CenCltB5I():New()
    Local oCltB5P := CenCltB5P():New()
    
    oCltB5I:setValue("B5I_CODOPE",self:cCodOpe)
    oCltB5I:setValue("B5I_NUMLOT",self:cLote)
    oCltB5I:setValue("B5I_TPTRAN","1")
    oCltB5I:setValue("B5I_CMPLOT",self:cAno + Substr(self:cMes,2,2))
    oCltB5I:setValue("B5I_DATPRO",StrTran(self:cDate,"-",""))
    oCltB5I:setValue("B5I_HORPRO",StrTran(self:cHora,":",""))
    oCltB5I:setValue("B5I_VERPAD",self:cTissVersion)
    oCltB5I:setValue("B5I_ARQUIV",self:cFileName)
    oCltB5I:setValue("B5I_STATUS","1")
    oCltB5I:insert()
    oCltB5I:destroy()

    cTagPai := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:controleQualidade"
    nTotGuias := self:oXML:XPathChildCount(cTagPai)

    for nGuia := 1 to nTotGuias

        cPathGuia := cTagPai + "/ans:guiaAtendimento["+cValtoChar(nGuia)+"]"
        
        cPathLanc := cPathGuia + "/ans:lancamentosCompetencia"
        nTotLanc := self:oXML:XPathChildCount(cPathLanc)
        for nLanc := 1 to nTotLanc
            cPathLanc := cPathGuia + "/ans:lancamentosCompetencia/ans:lancamento["+ cValtoChar(nLanc) +"]"
            oCltB5P:setValue("B5P_CODOPE",self:cCodOpe)
            oCltB5P:setValue("B5P_CMPLOT",self:cAno + Substr(self:cMes,2,2))
            oCltB5P:setValue("B5P_NUMLOT",self:cLote)
            oCltB5P:setValue("B5P_NMGOPE",self:oXML:XPathGetNodeValue(cPathGuia+"/ans:numeroGuiaOperadora"))
            oCltB5P:setValue("B5P_NMGPRE",self:oXML:XPathGetNodeValue(cPathGuia+"/ans:numeroGuiaPrestador"))
            oCltB5P:setValue("B5P_IDREEM",self:oXML:XPathGetNodeValue(cPathGuia+"/ans:identificadorReembolso"))
            oCltB5P:setValue("B5P_CNES"  ,self:oXML:XPathGetNodeValue(cPathGuia+"/ans:contratadoExecutante/ans:CNES")) 
            oCltB5P:setValue("B5P_CPFCGC",self:oXML:XPathGetNodeValue(cPathGuia+"/ans:contratadoExecutante/ans:codigoCNPJ_CPF"))
            oCltB5P:setValue("B5P_DATPRO",STRTRAN(self:oXML:XPathGetNodeValue(cPathGuia+"/ans:lancamentosCompetencia/ans:lancamento/ans:dataProcessamento"),"-",""))
            oCltB5P:setValue("B5P_CODPAD","")
            oCltB5P:setValue("B5P_CODPRO","")
            oCltB5P:setValue("B5P_CODGRU","")
            oCltB5P:setValue("B5P_CDDENT","")
            oCltB5P:setValue("B5P_CDREGI","")
            oCltB5P:setValue("B5P_CDFACE","")

            //erros da guia - nivel 1
            cPathOcoGuia := cPathLanc + "/ans:ocorrenciasLancamento"
            nTotOcoGuia := self:oXML:XPathChildCount(cPathOcoGuia)
            oCltB5P:setValue("B5P_NIVERR","1")
            for nOcoGuia := 1 to nTotOcoGuia
                cPathOcoGuia := cPathLanc + "/ans:ocorrenciasLancamento/ans:ocorrencia["+ cValtoChar(nOcoGuia) +"]"
                oCltB5P:setValue("B5P_CDCMER",self:oXML:XPathGetNodeValue(cPathOcoGuia+"/ans:codigoErro"))
                oCltB5P:setValue("B5P_CDCMGU",self:oXML:XPathGetNodeValue(cPathOcoGuia+"/ans:identificadorCampo"))
                oCltB5P:setValue("B5P_CONCAM",self:oXML:XPathGetNodeValue(cPathOcoGuia+"/ans:conteudoCampo"))
                oCltB5P:setValue("B5P_DESERR",allTrim( posicione( "B2R",1,xFilial( "B2R" ) + '38' + oCltB5P:getValue("B5P_CDCMER"),"B2R_DESTER" ) ) )
                oCltB5P:insert()
            Next nOcoGuia

            //erros de procedimento - nivel 2
            cPathItens := cPathLanc + "/ans:itensLancamento"
            nTotItens := self:oXML:XPathChildCount(cPathItens)
            oCltB5P:setValue("B5P_NIVERR","2")
            for nItem := 1 to nTotItens
                cPathItens := cPathLanc + "/ans:itensLancamento/ans:procedimentoItemAssistencial["+ cValtoChar(nItem) +"]"
                oCltB5P:setValue("B5P_CODPAD",self:oXML:XPathGetNodeValue(cPathItens+"/ans:codigoTabela"))
                oCltB5P:setValue("B5P_CODPRO",self:oXML:XPathGetNodeValue(cPathItens+"/ans:procedimento/ans:codigoProcedimento"))
                oCltB5P:setValue("B5P_CODGRU",self:oXML:XPathGetNodeValue(cPathItens+"/ans:procedimento/ans:grupoProcedimento"))
                oCltB5P:setValue("B5P_CDDENT",self:oXML:XPathGetNodeValue(cPathItens+"/ans:denteRegiao/ans:codDente"))
                oCltB5P:setValue("B5P_CDREGI",self:oXML:XPathGetNodeValue(cPathItens+"/ans:denteRegiao/ans:codRegiao"))
                oCltB5P:setValue("B5P_CDFACE",self:oXML:XPathGetNodeValue(cPathItens+"/ans:denteFace"))
                //SETAR CAMPOS DENTE FACE REGIAO
                cPathOcItens := cPathItens + "/ans:ocorrenciasProcedimentoItemAssistencial"
                nTotOcItens := self:oXML:XPathChildCount(cPathOcItens)
                for nOcItem := 1 to nTotOcItens
                    cPathOcItens := cPathItens + "/ans:ocorrenciasProcedimentoItemAssistencial/ans:ocorrencia["+ cValtoChar(nOcItem) +"]"
                    oCltB5P:setValue("B5P_CDCMER",self:oXML:XPathGetNodeValue(cPathOcItens+"/ans:codigoErro"))
                    oCltB5P:setValue("B5P_CDCMGU",self:oXML:XPathGetNodeValue(cPathOcItens+"/ans:identificadorCampo"))
                    oCltB5P:setValue("B5P_CONCAM",self:oXML:XPathGetNodeValue(cPathOcItens+"/ans:conteudoCampo"))
                    oCltB5P:setValue("B5P_DESERR",allTrim( posicione( "B2R",1,xFilial( "B2R" ) + '38' + oCltB5P:getValue("B5P_CDCMER"),"B2R_DESTER" ) ) )
                    oCltB5P:insert()
                Next nOcItem

                //erros de pacote - nivel 3
                cPathPacote := cPathItens + "/ans:detalhamentoPacote"
                nTotPacote := self:oXML:XPathChildCount(cPathPacote)
                oCltB5P:setValue("B5P_NIVERR","3")
                for nPacote := 1 to nTotPacote
                    cPathPacote := cPathItens + "/ans:detalhamentoPacote/ans:pacote["+ cValtoChar(nPacote) +"]"
                    oCltB5P:setValue("B5P_CODPAD",self:oXML:XPathGetNodeValue(cPathPacote+"/ans:codigoTabela"))
                    oCltB5P:setValue("B5P_CODPRO",self:oXML:XPathGetNodeValue(cPathPacote+"/ans:codigoProcedimento"))
                    oCltB5P:setValue("B5P_CODGRU",self:oXML:XPathGetNodeValue(cPathPacote+""))
                    oCltB5P:setValue("B5P_CDDENT","")
                    oCltB5P:setValue("B5P_CDREGI","")
                    oCltB5P:setValue("B5P_CDFACE","")
                    cPathOcPac := cPathPacote + "/ans:ocorrenciasPacote"
                    nTotOcPac := self:oXML:XPathChildCount(cPathOcPac)
                    for nOcPac := 1 to nTotOcPac
                        cPathOcPac := cPathPacote + "/ans:ocorrenciasPacote/ans:ocorrencia["+ cValtoChar(nTotOcPac) +"]"
                        oCltB5P:setValue("B5P_CDCMER",self:oXML:XPathGetNodeValue(cPathOcPac+"/ans:codigoErro"))
                        oCltB5P:setValue("B5P_CDCMGU",self:oXML:XPathGetNodeValue(cPathOcPac+"/ans:identificadorCampo"))
                        oCltB5P:setValue("B5P_CONCAM",self:oXML:XPathGetNodeValue(cPathOcPac+"/ans:conteudoCampo"))
                        oCltB5P:setValue("B5P_DESERR",allTrim( posicione( "B2R",1,xFilial( "B2R" ) + '38' + oCltB5P:getValue("B5P_CDCMER"),"B2R_DESTER" ) ) )
                        oCltB5P:insert()
                    Next nOcPac
                Next nPacote
            Next nItem
        Next nLanc

    next
    oCltB5I:destroy()
    oCltB5P:destroy()
    
return self
