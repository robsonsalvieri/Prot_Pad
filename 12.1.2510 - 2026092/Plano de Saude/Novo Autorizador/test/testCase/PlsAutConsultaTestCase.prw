#Include 'Protheus.ch'

Class PlsAutConsultaTestCase From FwDefaultTestCase
    
    Method  PlsAutConsultaTestCase()

    Method getRegAns()
    Method getGuiPrest()
    Method getNumGuiOpe()
    Method getNumCarteira()
    Method getAtendRN()
    Method getNumCNS()
    Method codPrestOpe()
    Method getCpfCnpjPrest()
	Method getNomePrest()
	Method getCnes()

    Method getNomeProf()
	Method getConsProf()
	Method getNumConsProf()
	Method getUfProf()
	Method getCbos()
	Method getIndAcid()
	Method getDataAtend()
	Method getTpConsulta()
	Method procCodTab()
	Method procCodPro()
	Method procValPro()
    Method getNegativas()
	Method getObservacao() 

    Method insert()
    Method grvAudito()

EndClass

Method  PlsAutConsultaTestCase() Class PlsAutConsultaTestCase 
    _Super:FwDefaultTestCase()

    self:AddTestMethod("getRegAns",,"Retorna o registro ANS da operadora")
    self:AddTestMethod("getGuiPrest",,"Retorna o número da guia no prestador")
    self:AddTestMethod("getNumGuiOpe",,"Retorna o número da guia na operadora")
    self:AddTestMethod("getNumCarteira",,"Retorna o número da carteirinha do beneficiário")
    self:AddTestMethod("getAtendRN",,"Retorna se o atendimento é para recém-nascido")
    self:AddTestMethod("getNumCNS",,"Retorna o número do cartão nacional de saúde do beneficiário")
    self:AddTestMethod("codPrestOpe",,"Retorna o código do prestador na operadora")
    self:AddTestMethod("getCpfCnpjPrest",,"Retorna o cpf ou cnpj do prestador")
    self:AddTestMethod("getCnes",,"Retorna o CNES do prestador")
    self:AddTestMethod("getNomeProf",,"Retorna o nome do profissional")
    self:AddTestMethod("getConsProf",,"Retorna o conselho regional do profissional")
    self:AddTestMethod("getNumConsProf",,"Retorna o número do conselho do profissional")
    self:AddTestMethod("getUfProf",,"Retorna a UF do profissional")
    self:AddTestMethod("getCbos",,"Retorna o CBOS do profissional")
    self:AddTestMethod("getIndAcid",,"Retorna se houve Indicação de acidente")
    self:AddTestMethod("getDataAtend",,"Retorna a data de atendimento")
    self:AddTestMethod("getTpConsulta",,"Retorna o tipo de consulta")
    self:AddTestMethod("procCodTab",,"Retorna a tabela do procedimento")
    self:AddTestMethod("procCodPro",,"Retorna o código do procedimento")
    self:AddTestMethod("procValPro",,"Retorna o valor apresentado para o procedimento")
    self:AddTestMethod("getNegativas",,"Retorna as negativas do procedimento")
    self:AddTestMethod("getObservacao",,"Retorna a observação do atendimento")

    self:AddTestMethod("insert",,"Insere uma consulta nas tabelas BEA, BE2 e BEG")
    self:AddTestMethod("grvAudito",,"Insere uma consulta e grava em auditoria")

Return

Method getRegAns() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cRegAns    := ""

    oResult:activate()
    
    cRegAns   := oConsulta:getRegAns()

    oResult:AssertTrue(cRegAns == "000000","Não retornou o registro ANS 000000, retornou " + cRegAns)

Return oResult

Method getGuiPrest() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cGuiPrest    := ""
   
    oResult:activate()

        cGuiPrest   := oConsulta:getGuiPrest()

    oResult:AssertTrue(cGuiPrest == "20180300000005","Não retornou o número de guia no prestador 20180300000005, retornou " + cGuiPrest)

Return oResult

Method getNumGuiOpe() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cNGuiOpe   := ""
   
    oResult:activate()

        cNGuiOpe := oConsulta:getNumGuiOpe()

    oResult:AssertTrue(empty(cNGuiOpe),"Não deveria retornar um numero de guia na operadora, retornou " + cNGuiOpe)

Return oResult

Method getNumCarteira() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cCarteirinha   := ""
   
    oResult:activate()

        cCarteirinha := oConsulta:getNumCarteira()

    oResult:AssertTrue(cCarteirinha == "00010002000003000","Não retornou a carteirinha 00010002000003000, retornou " + cCarteirinha)

Return oResult

Method getAtendRN() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cAtendRN   := ""
   
    oResult:activate()

        cAtendRN := oConsulta:getAtendRN()

    oResult:AssertTrue(cAtendRN == "0","Não retornou atendimento a RN = 0, retornou " + cAtendRN)

Return oResult

Method getNumCNS() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cNumCNS   := ""
   
    oResult:activate()

        cNumCNS := oConsulta:getNumCNS()

    oResult:AssertTrue(cNumCNS == "135200315560018","Não retornou o número de CNS esperado, retornou " + cNumCNS)

Return oResult

Method codPrestOpe() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cCodPrest   := ""
   
    oResult:activate()

        cCodPrest := oConsulta:codPrestOpe()

    oResult:AssertTrue(cCodPrest == "000004","Não retornou o código de prestador esperado, retornou " + cCodPrest)

Return oResult

Method getCpfCnpjPrest() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cCpfCnpjPrest   := ""
   
    oResult:activate()

        cCpfCnpjPrest := oConsulta:getCpfCnpjPrest()

    oResult:AssertTrue(cCpfCnpjPrest == "34585221000190" ,"Não retornou o CNPJ 34585221000190, retornou " + cCpfCnpjPrest)

Return oResult

Method getCnes() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cCnes   := ""
   
    oResult:activate()

        cCnes := oConsulta:getCnes()

    oResult:AssertTrue(cCnes == "999999" ,"Não retornou o CNES 999999, retornou " + cCnes)

Return oResult

Method getNomeProf() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cNomeProf   := ""
   
    oResult:activate()

        cNomeProf := oConsulta:getNomeProf()

    oResult:AssertTrue(cNomeProf == "DAIANE BERNARDE BATISTA" ,"Não retornou o nome DAIANE BERNARDE BATISTA, retornou " + cNomeProf)

Return oResult

Method getConsProf() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cConsProf   := ""
   
    oResult:activate()

        cConsProf := oConsulta:getConsProf()

    oResult:AssertTrue(cConsProf == "CRM" ,"Não retornou o Conselho Regional de Medicina, retornou " + cConsProf)

Return oResult

Method getNumConsProf() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cNumConsProf   := ""
   
    oResult:activate()

        cNumConsProf := oConsulta:getNumConsProf()

    oResult:AssertTrue(cNumConsProf == "654987" ,"Não retornou o Nº de conselho 654987, retornou " + cNumConsProf)

Return oResult

Method getUfProf() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cUfProf   := ""
   
    oResult:activate()

        cUfProf := oConsulta:getUfProf()

    oResult:AssertTrue(cUfProf == "SP" ,"Não retornou a UF SP, retornou " + cUfProf)

Return oResult

Method getCbos() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cCbos   := ""
   
    oResult:activate()

        cCbos := oConsulta:getCbos()

    oResult:AssertTrue(cCbos == "225125" ,"Não retornou o CBOS 225125, retornou " + cCbos)

Return oResult

Method getIndAcid() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cIndAcid   := ""
   
    oResult:activate()

        cIndAcid := oConsulta:getIndAcid()

    oResult:AssertTrue(cIndAcid == "9" ,"Não retornou indicação de acidente 9 (Não Acidente), retornou " + cIndAcid)

Return oResult

Method getDataAtend() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local dAtend     := ctod("")
   
    oResult:activate()

        dAtend := oConsulta:getDataAtend()

    oResult:AssertTrue(dAtend == stod("20180318") ,"Não retornou a data de atendimento 18/03/2018, retornou " + dtos(dAtend))

Return oResult

Method getTpConsulta() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cTpCons   := ""
   
    oResult:activate()

        cTpCons := oConsulta:getTpConsulta()

    oResult:AssertTrue(cTpCons == "1" ,"Não retornou o tipo de consulta 1 (Primeira Consulta), retornou " + cTpCons)

Return oResult
 
Method procCodTab() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cProcTab   := ""
   
    oResult:activate()

        cProcTab := oConsulta:procCodTab()

    oResult:AssertTrue(cProcTab == "01" ,"Não retornou a tabela 01 (22), retornou " + cProcTab)

Return oResult

Method procCodPro() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cProcCod   := ""
   
    oResult:activate()

        cProcCod := oConsulta:procCodPro()

    oResult:AssertTrue(cProcCod == "10101012" ,"Não retornou o código 10101012, retornou " + cProcCod)

Return oResult

Method procValPro() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local nProcVal   := ""
   
    oResult:activate()

        nProcVal := oConsulta:procValPro()

    oResult:AssertTrue(nProcVal == 200.30 ,"Não retornou o valor 200.30, retornou " + alltrim(str(nProcVal)))

Return oResult

Method getNegativas() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local aNegativas := ""
   
    oResult:activate()

        aNegativas := oConsulta:getNegativas()

    oResult:AssertTrue(Len(aNegativas) > 0 ,"Não retornou nenhuma negativa e deveria")

    if (Len(aNegativas) > 1)
        oResult:AssertTrue(aNegativas[1][1] == "1427" ,"Não retornou o código de glosa 1427 (Necessidade de auditoria médica), retornou" + aNegativas[1][1])
        oResult:AssertTrue(aNegativas[2][1] == "1803" ,"Não retornou o código de glosa 1803 (Idade do beneficiário incompatível com o procedimento), retornou" + aNegativas[2][1])
    endIf
    
Return oResult

Method getObservacao() Class PlsAutConsultaTestCase

    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cObs   := ""
   
    oResult:activate()

        cObs := oConsulta:getObservacao()

    oResult:AssertTrue(cObs == "Observação da consulta" ,"Não retornou a observação 'Observação da consulta', retornou " + cObs)

Return oResult

Method insert() Class PlsAutConsultaTestCase
    
    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cNumGuia   := ""
    Local cOpeMov    := ""
    Local cAnoAut    := ""
    Local cMesAut    := ""
    Local cNumAut    := ""

    oResult:activate()
        
        oConsulta:insert()
        cNumGuia := oConsulta:getNumGuia()

        cOpeMov := SubStr(cNumGuia,1,4)
		cAnoAut := SubStr(cNumGuia,5,4)
		cMesAut := SubStr(cNumGuia,9,2)
		cNumAut := SubStr(cNumGuia,11,8)

        cTable := "BEG"
		cQuery := " BEG_OPEMOV = '" + cOpeMov + "' AND"
		cQuery += " BEG_ANOAUT = '" + cAnoAut + "' AND"
		cQuery += " BEG_MESAUT = '" + cMesAut + "' AND"
		cQuery += " BEG_NUMAUT = '" + cNumAut + "' AND"
        cQuery += " BEG_SEQUEN = '001' AND "
        cQuery += " BEG_CODGLO = '025'"


        oResult:UTQueryDB(cTable, "BEG_DESGLO",	cQuery, 'Para este procedimento necessita Auditoria')

    oResult:AssertTrue(oResult:lOk,"Erro na gravacao")
Return oResult

Method grvAudito() Class PlsAutConsultaTestCase
    
    Local oConsulta  := criaConsulta()
	Local oResult    := FwTestHelper():New()
    Local cNumGuia   := ""

    oResult:activate()
        
        oConsulta:insert()
        cNumGuia := oConsulta:getNumGuia()

        cTable := "B53"
		cQuery := " B53_FILIAL = '" + xFilial("B53") + "' AND"
		cQuery += " B53_NUMGUI = '" + cNumGuia + "'"

        oResult:UTQueryDB(cTable, "B53_MATUSU",	cQuery, '00010002000003000')

    oResult:AssertTrue(oResult:lOk,"Erro na gravacao da auditoria")

Return oResult

static function retJsonConsulta()

    Local cJson := ""
    
    cJson += '{'
    cJson += '      "consultaGuia": {'
    cJson += '             "cabecalhoConsulta": {'
    cJson += '                 "registroANS": "000000",'
    cJson += '                 "numeroGuiaPrestador": "20180300000005"'
    cJson += '             },'
    cJson += '             "numeroGuiaOperadora": "",'
    cJson += '             "dadosBeneficiario": {'
    cJson += '                 "numeroCarteira": "00010002000003000",'
    cJson += '                 "atendimentoRN": "N",'
    cJson += '                 "nomeBeneficiario": "PAULO VINICIUS BARBOSA",'
    cJson += '                 "numeroCNS": "135200315560018"'
    cJson += '             },'
    cJson += '             "contratadoExecutante": {'
    cJson += '                 "cpfContratado": "",'
    cJson += '                 "cnpjContratado": "34585221000190",'
    cJson += '                 "nomeContratado": "HOSPITAL BOM CLIMA",'
    cJson += '                 "CNES": "999999"'
    cJson += '             },'
    cJson += '             "profissionalExecutante": {'
    cJson += '                 "nomeProfissional": "DAIANE BERNARDE BATISTA",'
    cJson += '                 "conselhoProfissional": "06",'
    cJson += '                 "numeroConselhoProfissional": "654987",'
    cJson += '                 "UF": "35",'
    cJson += '                 "CBOS": "225125"'
    cJson += '             },'
    cJson += '             "indicacaoAcidente": "9",'
    cJson += '             "dadosAtendimento": {'
    cJson += '                 "dataAtendimento": "2018-03-18",'
    cJson += '                 "tipoConsulta": "1",'
    cJson += '                 "procedimento": {'
    cJson += '                     "codigoTabela": "22",'
    cJson += '                     "codigoProcedimento": "10101012",'
    cJson += '                     "valorProcedimento": 200.30,'
    cJson += '                     "motivosNegativa": ['
    cJson += '                      {'
    cJson += '                            "motivoNegativa": {'
    cJson += '                              "codigoGlosa": "1427",'
    cJson += '                              "descricaoGlosa": "Necessidade de auditoria médica",'
    cJson += '                              "codigoNoSistema": "025"'
    cJson += '                            }'
    cJson += '                      },'
    cJson += '                      {'
    cJson += '                            "motivoNegativa": {'
    cJson += '                              "codigoGlosa": "1803",'
    cJson += '                              "descricaoGlosa": "Idade do beneficiário incompatível com o procedimento",'
    cJson += '                              "codigoNoSistema": "001"'
    cJson += '                            }'
    cJson += '                      }'
    cJson += '                     ]'
    cJson += '                 }'
    cJson += '             },'
    cJson += '             "observacao": "Observação da consulta"'
    cJson += '         }'
    cJson += '}'

Return cJson

static function criaConsulta()

    Local JParser := JSonParser():New()
    Local hMapAtend := nil
    Local oConsulta := nil
    
    JParser:setJson(retJsonConsulta())
    hMapAtend := JParser:parseJson()
    oConsulta := AutConsulta():New(hMapAtend)

Return oConsulta