#Include 'Protheus.ch'

Class PlsAutExecTestCase From FwDefaultTestCase
    
    Method  PlsAutExecTestCase()

    Method getCabecalho()    // Dados do cabeçalho      
    Method getAutorizacao()  // Dados da autorização        
    Method getBeneficiario() // Dados do beneficiário        
    Method getContSolic()  // Dados do solicitante (Contratado e Profissional)      
    Method getSolicitacao()  // Dados da solicitação       
    Method getContExec()   // Dados do executante (Contratado)       
    Method getAtendimento()  // Dados do atendimento           
    Method getExecProc()     // Procedimentos executados
    Method statusByProc()  // Retorna o status que o atendimento será gravado
	Method getObservacao()   // Observação
    Method getValorTotal()   // Valor total
    Method insert()
    Method grvAudito()

EndClass

Method  PlsAutExecTestCase() Class PlsAutExecTestCase
    _Super:FwDefaultTestCase()

    self:AddTestMethod("getCabecalho"   ,,"Retorna os dados do cabeçalho da guia")
    self:AddTestMethod("getAutorizacao" ,,"Retorna os dados da autorização")
    self:AddTestMethod("getBeneficiario",,"Retorna os dados do beneficiário")
    self:AddTestMethod("getContSolic"   ,,"Retorna os dados do contrado e profissional solicitante")
    self:AddTestMethod("getSolicitacao" ,,"Retorna os dados da solicitação")
    self:AddTestMethod("getContExec"    ,,"Retorna os dados do contratado executante")
    self:AddTestMethod("getAtendimento" ,,"Retorna os dados do atendimento")
    self:AddTestMethod("getExecProc"    ,,"Retorna os procedimentos executados")
    self:AddTestMethod("statusByProc"   ,,"Retorna o status do atendimento")
    self:AddTestMethod("getObservacao"  ,,"Retorna a observação")
    self:AddTestMethod("getValorTotal"  ,,"Retorna os valores totais")
    self:AddTestMethod("insert"         ,,"Insere uma execução de SP/SADT nas tabelas BEA, BE2, BEG e B4B")
    self:AddTestMethod("grvAudito"      ,,"Insere uma execução de SP/SADT e grava em auditoria")

Return

Method getCabecalho() Class PlsAutExecTestCase

    Local oExecucao    := criaExecucao()
	Local oResult   := FwTestHelper():New()

    Local cRegAns       := oExecucao:getRegAns()
    Local cNGuiPrest    := oExecucao:getGuiPrest()
    Local cVerTiss      := oExecucao:getVerTiss()
    Local cNGuiPri      := oExecucao:getNumGuiPri()

    oResult:activate()
    
    oResult:AssertTrue(cRegAns == "000000","Não retornou o registro ANS 000000, retornou " + cRegAns)
    oResult:AssertTrue(cNGuiPrest == "000120180800000190","Não retornou o número da guia prestador 000120180800000190, retornou " + cNGuiPrest)
    oResult:AssertTrue(cVerTiss == "03.03.03","Não retornou a versão da TISS 03.03.03, retornou " + cVerTiss)
    oResult:AssertTrue(cNGuiPri == "000120180800000151","Não retornou o número da guia principal 000120180800000151, retornou " + cNGuiPri)

Return oResult

Method getAutorizacao() Class PlsAutExecTestCase

    Local oExecucao    := criaExecucao()
	Local oResult   := FwTestHelper():New()
    
    Local nGuiOpe       := oExecucao:getNumGuiOpe()
    Local cDtAut        := oExecucao:getDtAut()
    Local cSenha        := oExecucao:getSenha()
    Local cDtValSen     := alltrim(oExecucao:getValSenha())

    oResult:activate()
    
    oResult:AssertTrue(nGuiOpe == "000120180800000190","Não retornou o número guia operadora 000120180800000190, retornou " + nGuiOpe)
    oResult:AssertTrue(cDtAut == "20180807","Não retornou a data de autorização 20180807, retornou " + cDtAut)
    oResult:AssertTrue(cSenha == "23017284191126528000","Não retornou a senha 23017284191126528000, retornou " + cSenha)
    oResult:AssertTrue(cDtValSen == "","Não retornou a data de validade em branco, retornou " + cDtValSen)

Return oResult

Method getBeneficiario() Class PlsAutExecTestCase

    Local oExecucao        := criaExecucao()
	Local oResult       := FwTestHelper():New()

    Local cMatric       := oExecucao:getNumCarteira()
    Local cAtendRN      := oExecucao:getAtendRN()
    Local cNumeroCNS    := oExecucao:getNumCNS()
    Local cNome         := oExecucao:getNomeBenef()

    oResult:activate()
    
    oResult:AssertTrue(cMatric == "00010002000003000","Não retornou o número da matrícula 00010002000003000, retornou " + cMatric)
    oResult:AssertTrue(cAtendRN == "0","Não retornou o atendimento RN 0 (N = Não), retornou " + cAtendRN)
    oResult:AssertTrue(cNumeroCNS == "135200315560018","Não retornou o número do CNS 135200315560018, retornou " + cNumeroCNS)
    oResult:AssertTrue(cNome == "PAULO VINICIUS BARBOSA","Não retornou o nome de beneficiário PAULO VINICIUS BARBOSA, retornou " + cNome)

Return oResult

Method getContSolic() Class PlsAutExecTestCase

    Local oExecucao        := criaExecucao()
	Local oResult       := FwTestHelper():New()

    Local cCodRda       := oExecucao:rdaSolCod()
    Local cCodLoc       := oExecucao:rdaSolLoc()
    Local cCpfCnpj      := oExecucao:rdaSolCgc()
    Local cNomeRda      := oExecucao:rdaSolNome()
    
    Local cNomeProf     := oExecucao:prfSolNome()
    Local cSiglaProf    := oExecucao:prfSolSigla()
    Local cNumeroProf   := oExecucao:prfSolNumero()
    Local cUfProf       := oExecucao:prfSolUf()
    Local cCbosProf     := oExecucao:prfSolCbos()
    Local cEspSolProf   := oExecucao:getEspSol()

    oResult:activate()
    
    oResult:AssertTrue(cCodRda == "000004","Não retornou o código do contratado 000004, retornou " + cCodRda)
    oResult:AssertTrue(cCodLoc == "001008","Não retornou o código do local, retornou " + cCodLoc)
    oResult:AssertTrue(cCpfCnpj == "34585221000190","Não retornou o CNPJ 34585221000190, retornou " + cCpfCnpj)
    oResult:AssertTrue(cNomeRda == "HOSPITAL BOM CLIMA","Não retornou o nome HOSPITAL BOM CLIMA, retornou " + cNomeRda)
    
    oResult:AssertTrue(cNomeProf == "DAIANE BERNARDE BATISTA","Não retornou o nome DAIANE BERNARDE BATISTA, retornou " + cNomeProf)
    oResult:AssertTrue(cSiglaProf == "CRM","Não retornou a sigla CRM, retornou " + cSiglaProf)
    oResult:AssertTrue(cNumeroProf == "654987","Não retornou o número do conselho 654987, retornou " + cNumeroProf)
    oResult:AssertTrue(cUfProf == "SP","Não retornou o a UF do conselho SP, retornou " + cUfProf)
    oResult:AssertTrue(cCbosProf == "225125","Não retornou o CBOS 225125, retornou " + cCbosProf)
    oResult:AssertTrue(cEspSolProf == "001","Não retornou o código de especialidade 001 (CBOS 225125), retornou " + cEspSolProf)

Return oResult

Method getSolicitacao() Class PlsAutExecTestCase

    Local oExecucao        := criaExecucao()
	Local oResult       := FwTestHelper():New()
    
    Local cDtSolic      := oExecucao:getDtSolic()
    Local cCarAtend     := oExecucao:getCarAtend()
    Local cIndCli       := oExecucao:getIndCli()

    oResult:activate()
    
    oResult:AssertTrue(cDtSolic == "20180806","Não retornou a data da solicitação 20180806, retornou " + cDtSolic)
    oResult:AssertTrue(cCarAtend == "1","Não retornou o caráter de atendimento 1 (eletivo), retornou " + cCarAtend)
    oResult:AssertTrue(cIndCli == "teste","Não retornou a indicação clínica teste, retornou " + cIndCli)

Return oResult

Method getContExec() Class PlsAutExecTestCase

    Local oExecucao        := criaExecucao()
	Local oResult       := FwTestHelper():New()
    
    Local cCodRda     := oExecucao:rdaExeCod()
    Local cCodLoc     := oExecucao:rdaExeLoc()
    Local cCpfCnpj    := oExecucao:rdaExeCgc()
    Local cNomeRda    := oExecucao:rdaExeNome()
    Local cCNES       := oExecucao:rdaExeCnes()
    Local cCodByCgc   := oExecucao:codPrestOpe()
    Local aLocByCod   := oExecucao:getLocalPrest()

    oResult:activate()

    oResult:AssertTrue(cCodRda == "000004","Não retornou o código do contratado 000004, retornou " + cCodRda)
    oResult:AssertTrue(cCodLoc == "001008","Não retornou o código do local, retornou " + cCodLoc)
    oResult:AssertTrue(cCpfCnpj == "34585221000190","Não retornou o CNPJ 34585221000190, retornou " + cCpfCnpj)
    oResult:AssertTrue(cNomeRda == "HOSPITAL BOM CLIMA","Não retornou o nome HOSPITAL BOM CLIMA, retornou " + cNomeRda)
    oResult:AssertTrue(cCNES == "9999999","Não retornou o CNES 9999999, retornou " + cCNES)
    oResult:AssertTrue(cCodByCgc == "000004","Não retornou o código do contratado 000004, retornou " + cCodByCgc)
    oResult:AssertTrue(!empty(aLocByCod),"Não retornou o local de atendimento pelo codigo")

    if len(aLocByCod) == 2
        oResult:AssertTrue(aLocByCod[1] == "001","Não retornou o codigo do local de atendimento pelo código, retornou " + aLocByCod[1])
        oResult:AssertTrue(aLocByCod[2] == "008","Não retornou o local de atendimento pelo código, retornou " + aLocByCod[2])
    endIf

Return oResult

Method getAtendimento() Class PlsAutExecTestCase

    Local oExecucao        := criaExecucao()
	Local oResult       := FwTestHelper():New()
    
    Local cTpAtend      := oExecucao:getTpAtend()
    Local cIndAci       := oExecucao:getIndAcid()
    Local cTpCons       := oExecucao:getTpCons()
    Local cMotEnc       := oExecucao:getMotEnc()

    oResult:activate()
    
    oResult:AssertTrue(cTpAtend == "04","Não retornou o tipo de atendimento 04 (Consulta), retornou " + cTpAtend)
    oResult:AssertTrue(cIndAci == "0","Não retornou a indicação de acidente 0 (Trabalho)" + cIndAci)
    oResult:AssertTrue(cTpCons == "1","Não retornou o tipo de consulta 1 (Primeira consulta), retornou " + cTpCons)
    oResult:AssertTrue(cMotEnc == "11","Não retornou o motivo de encerramento 11 (Alta curado), retornou " + cMotEnc)

Return oResult

Method getExecProc() Class PlsAutExecTestCase

    Local oExecucao         := criaExecucao()
	Local oResult           := FwTestHelper():New()
    
    Local aProcedimentos    := {}
    Local nTamProc          := 0
    Local aCriticas         := {}
    Local nTamCrit          := 0
    Local aPartic           := {}
    Local nTamPart          := 0

    Local nProced := 0
    Local nCritic := 0
    Local nPartic := 0

    oResult:activate()
    
    aProcedimentos := oExecucao:getProcedimentos()
    nTamProc         := Len(aProcedimentos)

    aCriticas := oExecucao:getNegativas()
    nTamCrit  := Len(aProcedimentos)

    aPartic := oExecucao:getPartic()
    nTamPart:= Len(aProcedimentos)

    oResult:AssertTrue(nTamProc > 0,"Não retornou nenhum procedimento")
    oResult:AssertTrue(nTamCrit > 0,"Não retornou nenhuma critica")
    oResult:AssertTrue(nTamPart > 0,"Não retornou nenhuma participacao")

    if nTamProc > 0 
        
        nProced := aScan(aProcedimentos, {|x| x[2] == "10101020"})
        oResult:AssertTrue(nProced > 0,"Não encontrou o procedimento 10101020 e deveria")

        if nProced > 0
            
            nCritic := aScan(aCriticas, { |x| x[1] == aProcedimentos[nProced][1] .and. x[2] == aProcedimentos[nProced][2] })
            oResult:AssertFalse(nCritic > 0,"Encontrou críticas para o procedimento 10101020 e não deveria")
            
            nPartic := aScan(aPartic, { |x| x[1] == aProcedimentos[nProced][1] .and. x[2] == aProcedimentos[nProced][2] })
            oResult:AssertTrue(nPartic > 0,"Não encontrou participação para o procedimento 10101020 e deveria")
        
        endIf

        nProced := aScan(aProcedimentos, {|x| x[2] == "20102089"})
        oResult:AssertTrue(nProced > 0,"Não encontrou o procedimento 20102089 e deveria")

        if nProced > 0
            
            nCritic := aScan(aCriticas, { |x| x[1] == aProcedimentos[nProced][1] .and. x[2] == aProcedimentos[nProced][2] })
            oResult:AssertTrue(nCritic > 0, "Não encontrou críticas para o procedimento 20102089 e deveria")
            
            nPartic := aScan(aPartic, { |x| x[1] == aProcedimentos[nProced][1] .and. x[2] == aProcedimentos[nProced][2] })
            oResult:AssertTrue(nPartic > 0, "Não encontrou participação para o procedimento 20102089 e deveria")
        
        endIf

    endIf

Return oResult

Method statusByProc() Class PlsAutExecTestCase

    Local oExecucao := criaExecucao()
	Local oResult   := FwTestHelper():New()
    
    Local cStatus   := ""

    oResult:activate()
    
    cStatus   := oExecucao:statusByProc()

    oResult:AssertTrue(cStatus == "6","Não retornou o status 6 (auditoria), retornou " + cStatus)

Return oResult

Method getObservacao() Class PlsAutExecTestCase

    Local oExecucao        := criaExecucao()
	Local oResult       := FwTestHelper():New()
    Local cObs      := oExecucao:getObsJust()

    oResult:activate()
    
    oResult:AssertTrue(cObs == "Observação teste","Não retornou a observação 'Observação teste', retornou " + cObs)

Return oResult

Method getValorTotal() Class PlsAutExecTestCase

    Local oExecucao        := criaExecucao()
	Local oResult       := FwTestHelper():New()

    Local cVlrProc := alltrim(str(oExecucao:getTotProc()))
    Local cVlrDiarias := alltrim(str(oExecucao:getTotDiar()))
    Local cVlrTxAlug := alltrim(str(oExecucao:getTotTxAlug()))
    Local cVlrMat := alltrim(str(oExecucao:getTotMat()))
    Local cVlrMed := alltrim(str(oExecucao:getTotMed()))
    Local cVlrOPME := alltrim(str(oExecucao:getTotOPME()))
    Local cVlrGasMed := alltrim(str(oExecucao:getTotGasMed()))
    Local cVlrTotGer := alltrim(str(oExecucao:getTotGeral()))

    oResult:activate()
    
    oResult:AssertTrue(cVlrProc == "100", "Não retornou o valor total de procedimentos 100, retornou " + cVlrProc)
    oResult:AssertTrue(cVlrDiarias == "0", "Não retornou o valor total de diarias 0, retornou " + cVlrDiarias)
    oResult:AssertTrue(cVlrTxAlug == "0", "Não retornou o valor total de taxas e alugueis 0, retornou " + cVlrTxAlug)
    oResult:AssertTrue(cVlrMat == "0", "Não retornou o valor total de materiais 0, retornou " + cVlrMat)
    oResult:AssertTrue(cVlrMed == "0", "Não retornou o valor total de medicamentos 0, retornou " + cVlrMed)
    oResult:AssertTrue(cVlrOPME == "0", "Não retornou o valor total de OPME 0, retornou " + cVlrOPME)
    oResult:AssertTrue(cVlrGasMed == "0", "Não retornou o valor total de gases medicinais 0, retornou " + cVlrGasMed)
    oResult:AssertTrue(cVlrTotGer == "100", "Não retornou o valor total geral 100, retornou " + cVlrTotGer)

Return oResult

static function retJsonExecucao()
    Local cJson := ""

    cJson += '    {'
    cJson += '  "guiaSP-SADT": {'
    cJson += '    "cabecalhoGuia": {'
    cJson += '      "registroANS": "000000",'
    cJson += '      "numeroGuiaPrestador": "000120180800000190",'
    cJson += '      "versaoTiss": "03.03.03",'
    cJson += '      "numeroGuiaPrincipal": "000120180800000151"'
    cJson += '    },'
    cJson += '    "dadosAutorizacao": {'
    cJson += '      "numeroGuiaOperadora": "000120180800000190",'
    cJson += '      "dataAutorizacao": "20180807",'
    cJson += '      "senha": "23017284191126528000",'
    cJson += '      "dataValidadeSenha": "        "'
    cJson += '    },'
    cJson += '    "dadosBeneficiario": {'
    cJson += '      "numeroCarteira": "00010002000003000",'
    cJson += '      "atendimentoRN": "N",'
    cJson += '      "nomeBeneficiario": "PAULO VINICIUS BARBOSA",'
    cJson += '      "numeroCNS": "135200315560018"'
    cJson += '    },'
    cJson += '    "dadosSolicitante": {'
    cJson += '      "contratadoSolicitante": {'
    cJson += '        "codigoContratado": "000004",'
    cJson += '        "dadosLocal": {'
    cJson += '          "local": "001008"'
    cJson += '        },'
    cJson += '        "cnpjContratado": "34585221000190",'
    cJson += '        "nomeContratado": "HOSPITAL BOM CLIMA"'
    cJson += '      },'
    cJson += '      "profissionalSolicitante": {'
    cJson += '        "nomeProfissional": "DAIANE BERNARDE BATISTA",'
    cJson += '        "conselhoProfissional": "06",'
    cJson += '        "numeroConselhoProfissional": "654987",'
    cJson += '        "UF": "35",'
    cJson += '        "CBOS": "225125"'
    cJson += '      }'
    cJson += '    },'
    cJson += '    "dadosSolicitacao": {'
    cJson += '      "dataSolicitacao": "20180806",'
    cJson += '      "caraterAtendimento": "1",'
    cJson += '      "indicacaoClinica": "teste"'
    cJson += '    },'
    cJson += '    "dadosExecutante": {'
    cJson += '      "contratadoExecutante": {'
    cJson += '        "codigoContratado": "000004",'
    cJson += '        "dadosLocal": {'
    cJson += '          "local": "001008"'
    cJson += '        },'
    cJson += '        "cnpjContratado": "34585221000190",'
    cJson += '        "nomeContratado": "HOSPITAL BOM CLIMA"'
    cJson += '      },'
    cJson += '      "cnes": "9999999"'
    cJson += '    },'
    cJson += '    "dadosAtendimento": {'
    cJson += '      "tipoAtendimento": "04",'
    cJson += '      "indicacaoAcidente": "0",'
    cJson += '      "tipoConsulta": "1",'
    cJson += '      "motivoEncerramento": "11"'
    cJson += '    },'
    cJson += '    "procedimentosExecutados": ['
    cJson += '      {'
    cJson += '        "procedimentoExecutado": {'
    cJson += '          "dataExecucao": "20180807",'
    cJson += '          "horaInicial": "10:00",'
    cJson += '          "horaFinal": "11:00",'
    cJson += '          "procedimento": {'
    cJson += '            "codigoTabela": "22",'
    cJson += '            "codigoProcedimento": "10101020",'
    cJson += '            "descricaoProcedimento": "Consulta em domicílio"'
    cJson += '          },'
    cJson += '          "quantidadeSolicitada": 1,'
    cJson += '          "quantidadeAutorizada": 1,'
    cJson += '          "viaAcesso": "2",'
    cJson += '          "tecnicaUtilizada": "2",'
    cJson += '          "reducaoAcrescimo": 1,'
    cJson += '          "valorUnitario": 50,'
    cJson += '          "valorTotal": 50,'
    cJson += '          "equipeSadt": ['
    cJson += '            {'
    cJson += '              "grauPart": "12",'
    cJson += '              "codigoContratado": "000004",'
    cJson += '              "cpfContratado": "84849538000165",'
    cJson += '              "nomeProf": "DAIANE BERNARDE BATISTA",'
    cJson += '              "conselho": "06",'
    cJson += '              "numeroConselhoProfissional": "654987",'
    cJson += '              "UF": "35",'
    cJson += '              "CBOS": "225125"'
    cJson += '            }'
    cJson += '          ],'
    cJson += '          "motivosNegativa": []'
    cJson += '        }'
    cJson += '      },'
    cJson += '      {'
    cJson += '        "procedimentoExecutado": {'
    cJson += '          "dataExecucao": "2080807",'
    cJson += '          "horaInicial": "10:00",'
    cJson += '          "horaFinal": "10:00",'
    cJson += '          "procedimento": {'
    cJson += '            "codigoTabela": "22",'
    cJson += '            "codigoProcedimento": "20102089",'
    cJson += '            "descricaoProcedimento": "Sistema Holter - 12 horas - 1 canal"'
    cJson += '          },'
    cJson += '          "quantidadeSolicitada": 1,'
    cJson += '          "quantidadeAutorizada": 0,'
    cJson += '          "viaAcesso": "2",'
    cJson += '          "tecnicaUtilizada": "2",'
    cJson += '          "reducaoAcrescimo": 1,'
    cJson += '          "valorUnitario": 50,'
    cJson += '          "valorTotal": 50,'
    cJson += '          "equipeSadt": ['
    cJson += '            {'
    cJson += '              "grauPart": "12",'
    cJson += '              "codigoContratado": "000004",'
    cJson += '              "cpfContratado": "84849538000165",'
    cJson += '              "nomeProf": "DAIANE BERNARDE BATISTA",'
    cJson += '              "conselho": "06",'
    cJson += '              "numeroConselhoProfissional": "654987",'
    cJson += '              "UF": "35",'
    cJson += '              "CBOS": "225125"'
    cJson += '            }'
    cJson += '          ],'
    cJson += '          "motivosNegativa": ['
    cJson += '            {'
    cJson += '              "motivoNegativa": {'
    cJson += '                "codigoGlosa": "1427",'
    cJson += '                "descricaoGlosa": "Para este procedimento necessita Auditoria.",'
    cJson += '                "codigoNoSistema": "025"'
    cJson += '              }'
    cJson += '            }'
    cJson += '          ]'
    cJson += '        }'
    cJson += '      }'
    cJson += '    ],'
    cJson += '    "observacao": "Observação teste",'
    cJson += '    "valorTotal": {'
    cJson += '      "valorProcedimentos": 100,'
    cJson += '      "valorDiarias": 0,'
    cJson += '      "valorTaxasAlugueis": 0,'
    cJson += '      "valorMateriais": 0,'
    cJson += '      "valorMedicamentos": 0,'
    cJson += '      "valorOPME": 0,'
    cJson += '      "valorGasesMedicinais": 0,'
    cJson += '      "valorTotalGeral": 100'
    cJson += '    }'
    cJson += '  }'
    cJson += '}'


Return cJson

static function criaExecucao()

    Local JParser := JSonParser():New()
    Local hMapAtend := nil
    Local oExecucao := nil
    
    JParser:setJson(retJsonExecucao())
    hMapAtend := JParser:parseJson()
    oExecucao := AutExecucao():New(hMapAtend)

Return oExecucao

Method insert() Class PlsAutExecTestCase
    
    Local oExecucao  := criaExecucao()
	Local oResult    := FwTestHelper():New()
    Local cNumGuia   := ""
    Local cOpeMov    := ""
    Local cAnoAut    := ""
    Local cMesAut    := ""
    Local cNumAut    := ""

    oResult:activate()
        
        oExecucao:insert()
        cNumGuia := oExecucao:getNumGuia()

        cOpeMov := SubStr(cNumGuia,1,4)
		cAnoAut := SubStr(cNumGuia,5,4)
		cMesAut := SubStr(cNumGuia,9,2)
		cNumAut := SubStr(cNumGuia,11,8)

        cTable := "BEG"
		cQuery := " BEG_OPEMOV = '" + cOpeMov + "' AND"
		cQuery += " BEG_ANOAUT = '" + cAnoAut + "' AND"
		cQuery += " BEG_MESAUT = '" + cMesAut + "' AND"
		cQuery += " BEG_NUMAUT = '" + cNumAut + "' AND"
        cQuery += " BEG_SEQUEN = '002' AND "
        cQuery += " BEG_CODGLO = '025'"
        
        oResult:UTQueryDB(cTable, "BEG_DESGLO",	cQuery, 'Para este procedimento necessita Auditoria')

        cTable := "B4B"
		cQuery := " B4B_OPEMOV = '" + cOpeMov + "' AND"
		cQuery += " B4B_ANOAUT = '" + cAnoAut + "' AND"
		cQuery += " B4B_MESAUT = '" + cMesAut + "' AND"
		cQuery += " B4B_NUMAUT = '" + cNumAut + "' AND"
        cQuery += " B4B_SEQUEN = '001'"

        oResult:UTQueryDB(cTable, "B4B_GRAUPA",	cQuery, '12')

    oResult:AssertTrue(oResult:lOk,"Erro na gravacao")
Return oResult

Method grvAudito() Class PlsAutExecTestCase
    
    Local oExecucao  := criaExecucao()
	Local oResult    := FwTestHelper():New()
    Local cNumGuia   := ""

    oResult:activate()
        
        oExecucao:insert()
        cNumGuia := oExecucao:getNumGuia()

        cTable := "B53"
		cQuery := " B53_FILIAL = '" + xFilial("B53") + "' AND"
		cQuery += " B53_NUMGUI = '" + cNumGuia + "'"

        oResult:UTQueryDB(cTable, "B53_MATUSU",	cQuery, '00010002000003000')

    oResult:AssertTrue(oResult:lOk,"Erro na gravacao da auditoria")

Return oResult