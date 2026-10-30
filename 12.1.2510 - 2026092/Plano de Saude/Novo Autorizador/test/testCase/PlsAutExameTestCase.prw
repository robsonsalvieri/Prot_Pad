#Include 'Protheus.ch'

Class PlsAutExameTestCase From FwDefaultTestCase
    
    Method  PlsAutExameTestCase()

    Method getRegAns()          
    Method getGuiPrest()          
    Method getNumGuiPri()         
    Method getNumGuiOpe()        
    Method getNumCarteira()         
    Method getAtendRN()          
    Method getNumCNS()             
    Method codPrestOpe()         
	Method getLocalPrest()
    Method getCpfCnpjPrest()        
    Method getNomeProf()           
    Method getConsProf()             
    Method getNumConsProf()          
    Method getUfProf()          
    Method getCbos()         
	Method getCodEsp()
    Method getCarAtend()         
    Method getDataSol()          
    Method getIndCli()         
    Method getProcedimentos()      
	Method statusByProc()   
    Method getNegativas()        
    Method getObservacao() 
    Method insert()
    Method grvAudito()

EndClass

Method  PlsAutExameTestCase() Class PlsAutExameTestCase
    _Super:FwDefaultTestCase()

    self:AddTestMethod("getRegAns",,"Retorna o registro ANS da operadora")
    self:AddTestMethod("getGuiPrest",,"Retorna o número da guia no prestador")
    self:AddTestMethod("getNumGuiPri",,"Retorna o número da guia no principal")
    self:AddTestMethod("getNumGuiOpe",,"Retorna o número da guia na operadora")
    self:AddTestMethod("getNumCarteira",,"Retorna o número da carteirinha do beneficiário")
    self:AddTestMethod("getAtendRN",,"Retorna se o atendimento é para recém-nascido")
    self:AddTestMethod("getNumCNS",,"Retorna o número do cartão nacional de saúde do beneficiário")
    self:AddTestMethod("codPrestOpe",,"Retorna o código do prestador na operadora")
    self:AddTestMethod("getLocalPrest",,"Retorna o local do prestador")
    self:AddTestMethod("getCpfCnpjPrest",,"Retorna o cpf ou cnpj do prestador")  
    self:AddTestMethod("getNomeProf",,"Retorna o nome do profissional")
    self:AddTestMethod("getConsProf",,"Retorna o conselho regional do profissional")
    self:AddTestMethod("getNumConsProf",,"Retorna o número do conselho do profissional")
    self:AddTestMethod("getUfProf",,"Retorna a UF do profissional")
    self:AddTestMethod("getCbos",,"Retorna o CBOS do profissional")
    self:AddTestMethod("getCodEsp",,"Retorna o código da especialidade a partir do CBOS")
    self:AddTestMethod("getCarAtend",,"Retorna o caráter do atendimento")
    self:AddTestMethod("getDataSol",,"Retorna a data de solicitação")
    self:AddTestMethod("getIndCli",,"Retorna a indicação clínica")
    self:AddTestMethod("getProcedimentos",,"Retorna os procedimentos solicitados")
    self:AddTestMethod("statusByProc",,"Retorna o status do atendimento")
    self:AddTestMethod("getNegativas",,"Retorna as criticas dos procedimentos")
    self:AddTestMethod("getObservacao",,"Retorna a observação do atendimento")  
    self:AddTestMethod("insert",,"Insere uma SP/SADT nas tabelas BEA, BE2 e BEG")
    self:AddTestMethod("grvAudito",,"Insere uma SP/SADT e grava em auditoria")

Return

Method getRegAns() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cRegAns   := ""

    oResult:activate()
    
    cRegAns   := oExame:getRegAns()

    oResult:AssertTrue(cRegAns == "000000","Não retornou o registro ANS 000000, retornou " + cRegAns)

Return oResult

Method getGuiPrest() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cGuiPrest := ""

    oResult:activate()
    
    cGuiPrest   := oExame:getGuiPrest()

    oResult:AssertTrue(cGuiPrest == "20180300000006","Não retornou o número de guia no prestador 20180300000006, retornou " + cGuiPrest)

Return oResult

Method getNumGuiPri() Class PlsAutExameTestCase

    Local oExame        := criaExame()
	Local oResult       := FwTestHelper():New()
    Local cNumGuiPri    := ""

    oResult:activate()
    
    cNumGuiPri   := oExame:getNumGuiPri()

    oResult:AssertTrue(empty(cNumGuiPri),"Não deveria retornar número de guia principal, retornou " + cNumGuiPri)

Return oResult

Method getNumGuiOpe() Class PlsAutExameTestCase

    Local oExame        := criaExame()
	Local oResult       := FwTestHelper():New()
    Local cNumGuiOpe    := ""

    oResult:activate()
    
    cNumGuiOpe   := oExame:getNumGuiOpe()

    oResult:AssertTrue(empty(cNumGuiOpe),"Não deveria retornar número de guia na operadora, retornou " + cNumGuiOpe)

Return oResult

Method getNumCarteira() Class PlsAutExameTestCase

    Local oExame        := criaExame()
	Local oResult       := FwTestHelper():New()
    Local cNumCarteira  := ""

    oResult:activate()
    
    cNumCarteira   := oExame:getNumCarteira()

    oResult:AssertTrue(cNumCarteira == "00010002000003000","Não retornou a carteirinha 00010002000003000, retornou " + cNumCarteira)

Return oResult

Method getAtendRN() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cAtendRN  := ""

    oResult:activate()
    
    cAtendRN   := oExame:getAtendRN()

    oResult:AssertTrue(cAtendRN == "0","Não retornou atendimento a RN = 0, retornou " + cAtendRN)

Return oResult

Method getNumCNS() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cNumCNS   := ""

    oResult:activate()
    
    cNumCNS   := oExame:getNumCNS()

    oResult:AssertTrue(cNumCNS == "135200315560018","Não retornou o número de CNS esperado, retornou " + cNumCNS)

Return oResult

Method codPrestOpe() Class PlsAutExameTestCase

    Local oExame        := criaExame()
	Local oResult       := FwTestHelper():New()
    Local cCodPrestOpe  := ""

    oResult:activate()
    
    cCodPrestOpe   := oExame:codPrestOpe()

    oResult:AssertTrue(cCodPrestOpe == "000004","Não retornou o código de prestador esperado, retornou " + cCodPrestOpe)

Return oResult

Method getLocalPrest() Class PlsAutExameTestCase

    Local oExame        := criaExame()
	Local oResult       := FwTestHelper():New()
    Local aLocalPrest   := {}
    Local nLocalPrest   := 0
    oResult:activate()
    
    aLocalPrest := oExame:getLocalPrest()
    nLocalPrest := Len(aLocalPrest)

    oResult:AssertTrue(nLocalPrest > 0,"Não retornou local de atendimento para o prestador")

    if nLocalPrest > 0
        oResult:AssertTrue(aLocalPrest[1] == "001" .and. aLocalPrest[2] == "008","Não o local de atendimento 001008, retornou " + aLocalPrest[1]+aLocalPrest[2])
    endIf

Return oResult

Method getCpfCnpjPrest() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cCpfCnpj  := ""

    oResult:activate()
    
    cCpfCnpj   := oExame:getCpfCnpjPrest()

    oResult:AssertTrue(cCpfCnpj == "34585221000190" ,"Não retornou o CNPJ 34585221000190, retornou " + cCpfCnpj)

Return oResult

Method getNomeProf() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cNomeProf := ""

    oResult:activate()
    
    cNomeProf   := oExame:getNomeProf()

    oResult:AssertTrue(cNomeProf == "DAIANE BERNARDE BATISTA" ,"Não retornou o nome DAIANE BERNARDE BATISTA, retornou " + cNomeProf)

Return oResult

Method getConsProf() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cConsProf := ""

    oResult:activate()
    
    cConsProf   := oExame:getConsProf()

    oResult:AssertTrue(cConsProf == "CRM" ,"Não retornou o Conselho Regional de Medicina, retornou " + cConsProf)

Return oResult

Method getNumConsProf() Class PlsAutExameTestCase

    Local oExame        := criaExame()
	Local oResult       := FwTestHelper():New()
    Local cNumConsProf  := ""

    oResult:activate()
    
    cNumConsProf   := oExame:getNumConsProf()

    oResult:AssertTrue(cNumConsProf == "654987" ,"Não retornou o Nº de conselho 654987, retornou " + cNumConsProf)

Return oResult

Method getUfProf() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cUfProf   := ""

    oResult:activate()
    
    cUfProf   := oExame:getUfProf()

    oResult:AssertTrue(cUfProf == "SP" ,"Não retornou a UF SP, retornou " + cUfProf)

Return oResult

Method getCbos() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cCbos     := ""

    oResult:activate()
    
    cCbos   := oExame:getCbos()

    oResult:AssertTrue(cCbos == "225125" ,"Não retornou o CBOS 225125, retornou " + cCbos)

Return oResult

Method getCodEsp() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cCodEsp     := ""

    oResult:activate()
    
    cCodEsp  := oExame:getCodEsp()

    oResult:AssertTrue(cCodEsp == "001","Não retornou a especialidade 001 para o CBOS 225125, retornou " + cCodEsp)

Return oResult

Method getCarAtend() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cCarAtend := ""

    oResult:activate()
    
    cCarAtend   := oExame:getCarAtend()

    oResult:AssertTrue(cCarAtend == "1","Não retornou o caráter de atendimento 1 (eletivo), retornou " + cCarAtend)

Return oResult

Method getDataSol() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cDataSol  := ""

    oResult:activate()
    
    cDataSol   := dtos(oExame:getDataSol())

    oResult:AssertTrue(cDataSol == "20180402","Não retornou a data de solicitação 02/04/2018, retornou " + cDataSol)

Return oResult

Method getIndCli() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cIndCli   := ""

    oResult:activate()
    
    cIndCli   := oExame:getIndCli()

    oResult:AssertTrue(cIndCli == "Indicação clínica do exame","Não retornou a indicação clinica 'Indicação clínica do exame', retornou " + cIndCli)

Return oResult

Method getProcedimentos() Class PlsAutExameTestCase

    Local oExame            := criaExame()
	Local oResult           := FwTestHelper():New()
    Local aProcedimentos    := ""
    Local nProcedimentos    := 0

    oResult:activate()
    
    aProcedimentos := oExame:getProcedimentos()
    nProcedimentos := Len(aProcedimentos)

    oResult:AssertTrue(nProcedimentos > 0,"Não retornou nenhum procedimento")

Return oResult

Method statusByProc() Class PlsAutExameTestCase

    Local oExame    := criaExame()
	Local oResult   := FwTestHelper():New()
    Local cStatus   := ""

    oResult:activate()
    
    cStatus   := oExame:statusByProc()

    oResult:AssertTrue(cStatus == "6","Não retornou o status 6 (auditoria), retornou " + cStatus)

Return oResult

Method getNegativas() Class PlsAutExameTestCase

    Local oExame        := criaExame()
	Local oResult       := FwTestHelper():New()
    Local aNegativas    := ""
    Local nNegativas    := 0

    oResult:activate()
    
    aNegativas := oExame:getNegativas()
    nNegativas := Len(aNegativas)

    oResult:AssertTrue(nNegativas > 0,"Não retornou nenhuma negativa")

Return oResult

Method getObservacao() Class PlsAutExameTestCase

    Local oExame        := criaExame()
	Local oResult       := FwTestHelper():New()
    Local cObservacao   := ""

    oResult:activate()
    
    cObservacao   := oExame:getObservacao()

    oResult:AssertTrue(cObservacao == "Observação do exame","Não retornou a observação 'Observação do exame', retornou " + cObservacao)

Return oResult

Method insert() Class PlsAutExameTestCase
    
    Local oExame  := criaExame()
	Local oResult    := FwTestHelper():New()
    Local cNumGuia   := ""
    Local cOpeMov    := ""
    Local cAnoAut    := ""
    Local cMesAut    := ""
    Local cNumAut    := ""

    oResult:activate()
        
        oExame:insert()
        cNumGuia := oExame:getNumGuia()

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

Method grvAudito() Class PlsAutExameTestCase
    
    Local oExame  := criaExame()
	Local oResult    := FwTestHelper():New()
    Local cNumGuia   := ""

    oResult:activate()
        
        oExame:insert()
        cNumGuia := oExame:getNumGuia()

        cTable := "B53"
		cQuery := " B53_FILIAL = '" + xFilial("B53") + "' AND"
		cQuery += " B53_NUMGUI = '" + cNumGuia + "'"

        oResult:UTQueryDB(cTable, "B53_MATUSU",	cQuery, '00010002000003000')

    oResult:AssertTrue(oResult:lOk,"Erro na gravacao da auditoria")

Return oResult

static function retJsonExame()
    Local cJson := ""

    cJson += '{'
    cJson += '	"sadtSolicitacaoGuia": {'
    cJson += '		"cabecalhoSolicitacao": {'
    cJson += '			"registroANS": "000000",'
    cJson += '			"numeroGuiaPrestador": "20180300000006"'
    cJson += '		},'
    cJson += '		"numeroGuiaPrincipal": "",'
    cJson += '      "numeroGuiaOperadora": "",'
    cJson += '		"dadosBeneficiario": {'
    cJson += '			"numeroCarteira": "00010002000003000",'
    cJson += '			"atendimentoRN": "N",'
    cJson += '			"nomeBeneficiario": "PAULO VINICIUS BARBOSA",'
    cJson += '			"numeroCNS": "135200315560018"'
    cJson += '		},'
    cJson += '		"dadosSolicitante": {'
    cJson += '			"contratadoSolicitante": {'
    cJson += '				"cpfContratado": "",'
    cJson += '				"cnpjContratado": "34585221000190",'
    cJson += '				"nomeContratado": "HOSPITAL BOM CLIMA"'
    cJson += '			},'
    cJson += '			"profissionalSolicitante": {'
    cJson += '				"nomeProfissional": "DAIANE BERNARDE BATISTA",'
    cJson += '				"conselhoProfissional": "06",'
    cJson += '				"numeroConselhoProfissional": "654987",'
    cJson += '				"UF": "35",'
    cJson += '				"CBOS": "225125"'
    cJson += '			}'
    cJson += '		},'
    cJson += '		"caraterAtendimento": "1",'
    cJson += '		"dataSolicitacao": "2018-04-02",'
    cJson += '		"indicacaoClinica": "Indicação clínica do exame",'
    cJson += '		"procedimentosSolicitados": ['
    cJson += '			{'
    cJson += '				"procedimento": {'
    cJson += '					"codigoTabela": "22",'
    cJson += '					"codigoProcedimento": "40103676",'
    cJson += '					"descricaoProcedimento": "Rinometria Acustica"'
    cJson += '				},'
    cJson += '              "motivosNegativa": ['
    cJson += '                  {'
    cJson += '                      "motivoNegativa": {'
    cJson += '                          "codigoGlosa": "1427",'
    cJson += '                          "descricaoGlosa": "Necessidade de auditoria médica",'
    cJson += '                          "codigoNoSistema": "025"'
    cJson += '                       }'
    cJson += '                  },'
    cJson += '                  {'
    cJson += '                      "motivoNegativa": {'
    cJson += '                          "codigoGlosa": "1803",'
    cJson += '                          "descricaoGlosa": "Idade do beneficiário incompatível com o procedimento",'
    cJson += '                          "codigoNoSistema": "001"'
    cJson += '                      }'
    cJson += '                  }'
    cJson += '              ],'
    cJson += '				"quantidadeSolicitada": 2,'
    cJson += '				"quantidadeAutorizada": 0'
    cJson += '			},'
    cJson += '			{'
	cJson += '			    "procedimento": {'
	cJson += '			    	"codigoTabela": "22",'
	cJson += '			    	"codigoProcedimento": "20101023",'
	cJson += '			    	"descricaoProcedimento": "Análise da proporcionalidade cineantropométrica"'
	cJson += '			    },'
	cJson += '			    "motivosNegativa": ['
	cJson += '			    	{'
	cJson += '			    		"motivoNegativa": {'
	cJson += '			    			"codigoGlosa": "1427",'
	cJson += '			    			"descricaoGlosa": "Necessidade de auditoria médica",'
	cJson += '			    			"codigoNoSistema": "025"'
	cJson += '			    		}'
	cJson += '			    	},'
	cJson += '			    	{'
	cJson += '			    		"motivoNegativa": {'
	cJson += '			    			"codigoGlosa": "1803",'
	cJson += '			    			"descricaoGlosa": "Idade do beneficiário incompatível com o procedimento",'
	cJson += '			    			"codigoNoSistema": "001"'
	cJson += '			    		}'
	cJson += '			    	}'
	cJson += '			    ],'
	cJson += '			    "quantidadeSolicitada": 1,'
	cJson += '			    "quantidadeAutorizada": 0'
	cJson += '		    }'
    cJson += '		],'
    cJson += '		"observacao": "Observação do exame"'
    cJson += '	}'
    cJson += '}'

Return cJson

static function criaExame()

    Local JParser := JSonParser():New()
    Local hMapAtend := nil
    Local oExame := nil
    
    JParser:setJson(retJsonExame())
    hMapAtend := JParser:parseJson()
    oExame := AutExame():New(hMapAtend)

Return oExame