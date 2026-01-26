#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} 
    Funcao principal que e chamada para iniciar o servico de atualização de artefatos
    @type  Function
    @author everton.mateus
    @since 29/07/2020
/*/
Main Function SvcAtuArtefatos(lJob,lAuto)
    Default lJob := isBlind()
    Default lAuto:= .F.
    If lJob
        StartJob("JobAtuArtefatos", GetEnvServer(), .F., cEmpAnt, cFilAnt, lJob, lAuto)
    Else
        JobAtuArtefatos(cEmpAnt, cFilAnt,.F.,lAuto)
    EndIf
return

Function JobAtuArtefatos(cEmp,cFil,lJob,lAuto)
    Local oPrjCltBI8 := nil
    Local lBI8 := .F.
    Local lBI9 := .F.
    Default cEmp := "99"
    Default cFil := "01"
    Default lJob := isBlind()
    Default lAuto:= .F.
    
    If lJob
        rpcSetType(3)    
        rpcSetEnv( cEmp, cFil,,,GetEnvServer(),, )
    EndIf
    lBI8 := FWAliasInDic("BI8", .F.)
	lBI9 := FWAliasInDic("BI9", .F.)
	If lBI8 .AND. lBI9
        oPrjCltBI8 := PrjCltBI8():new()
        If oPrjCltBI8:getAtuAuto()
            While oPrjCltBI8:hasNext()
                PrjAtuArtefato(oPrjCltBI8:getNext(),lAuto)
            EndDo
        EndIf

        oPrjCltBI8:destroy()
        FreeObj(oPrjCltBI8)
        oPrjCltBI8 := nil
    Else
        Conout("As tabelas BI8 e BI9 não existem, atualize seu dicionário de dados.")
    Endif
Return

Function PrjAtuArtefato(oPrjArtefato,lAuto)
    Default oPrjArtefato :=  PrjArtefato():New(BI8->BI8_CODIGO,allTrim(BI8->BI8_ULTVER))
    Default lAuto        := .F.

    //Ajuste para automacao
    If lAuto
        oPrjArtefato:setConfig(ArtGetJson())
    Endif
    
    If oPrjArtefato:IniciaProcesso(isBlind())
    
        If oPrjArtefato:downAndSave() .And. oPrjArtefato:verifAtivo() .And. !Empty(oPrjArtefato:cRotina)
            oPrjArtefato:lancaRotina()
        EndIf
        If !isBlind() //Atualização via Tela
            If Empty(oPrjArtefato:getErro())
                oPrjArtefato:sucessoAtualizacao()
                MsgInfo("Artefato: " + BI8->BI8_CODIGO + " Versão: " + allTrim(BI8->BI8_ULTVER) + " atualizado com sucesso!")
            Else
                oPrjArtefato:falhaAtualizacao()
                MsgAlert(oPrjArtefato:getErro())
            EndIf
        Else //Atualização via Job
            If Empty(oPrjArtefato:getErro())
                oPrjArtefato:sucessoAtualizacao(.T.)
            Else
                oPrjArtefato:falhaAtualizacao(.T.)
            EndIf
            oPrjArtefato:saveErro(oPrjArtefato) //Salva/Limpa Erro na tabela BI9/BI8
        EndIf

        oPrjArtefato:FinalizaProcesso()

    Else

        oPrjArtefato:falhaAtualizacao(isBlind())
        If !isBlind()
            MsgAlert(oPrjArtefato:getErro())
        EndIf
        
    Endif

    oPrjArtefato:destroy()
    FreeObj(oPrjArtefato)
    oPrjArtefato := nil

Return

Static Function SchedDef()
Return { "P","",,{},""}



/*/{Protheus.doc} 
    Funcao chamada para trativas de automação, esse item estava no caso de testes porem estava dando erro de falta de função em debitos tecnicos
    @type  Function
    @author Totver
    @since 29/07/2020
/*/

Function ArtGetJson ()
    Local cJson := ""
    Local oJson := JsonObject():New()

    cJson += '{	 '
    cJson += '    "observacao": "Arquivo para testes", '
    cJson += '    "artefatos": ["999","998","997"], '
    cJson += '    "999": '
    cJson += '    { '
    cJson += '        "artefato":"Artefato de Teste", '
    cJson += '        "arquivo":"TerminologiasTISS_Tabela18", '
    cJson += '        "codigo":"999", '
    cJson += '        "versoes":["20200X"], '
    cJson += '        "20200X": '
    cJson += '        { '
    cJson += '            "versao":{ '
    cJson += '                "nome":"20200X", '
    cJson += '                "configuracoes":[ '
    cJson += '                    {} '
    cJson += '                ], '
    cJson += '			      "funcoesObrigatorias": [], '
    cJson += '                "camposObrigatorios": [] '
    cJson += '            }, '
    cJson += '            "repositorio": "https://arte.engpro.totvs.com.br", '
    cJson += '            "uri": "/PUBLIC/sigapls/artefatos/TerminologiasTISS_Tabela18_20200X.zip", '
    cJson += '            "rotina":"AllwaysTrue", '
    cJson += '            "tipoArquivo":"zip", '
    cJson += '            "destino":"\\AtualizadorTISS\\", '
    cJson += '            "ativo":true '
    cJson += '        } '
    cJson += '    }, '
    cJson += '    "998": '
    cJson += '    { '
    cJson += '        "artefato":"Artefato de Teste", '
    cJson += '        "arquivo":"TerminologiasTISS_Tabela18", '
    cJson += '        "codigo":"998", '
    cJson += '        "versoes":["20200X"], '
    cJson += '        "20200X": '
    cJson += '        { '
    cJson += '            "versao":{ '
    cJson += '                "nome":"20200X", '
    cJson += '                "configuracoes":[ '
    cJson += '                    {} '
    cJson += '                ] '
    cJson += '            }, '
    cJson += '            "repositorio": "https://arte.engpro.totvs.com.br", '
    cJson += '            "uri": "/PUBLIC/sigapls/artefatos/TerminologiasTISS_Tabela18_20200X.zip", '
    cJson += '            "rotina":"AllwaysTrue", '
    cJson += '            "tipoArquivo":"zip", '
    cJson += '            "destino":"", '
    cJson += '            "ativo":true '
    cJson += '        } '
    cJson += '    }, '
    cJson += '    "997": '
    cJson += '    { '
    cJson += '        "artefato":"Artefato de Teste", '
    cJson += '        "arquivo":"ArtefatoAntigo", '
    cJson += '        "codigo":"997", '
    cJson += '        "versoes":["2020","2019"], '
    cJson += '        "2020": '
    cJson += '        { '
    cJson += '            "versao":{ '
    cJson += '                "nome":"2020", '
    cJson += '               "configuracoes":[ '
    cJson += '                    {} '
    cJson += '                ] '
    cJson += '            }, '
    cJson += '            "repositorio": "https://arte.engpro.totvs.com.br", '
    cJson += '            "uri": "/PUBLIC/sigapls/artefatos/Testes/ArtefatoAntigo_2020.zip", '
    cJson += '            "rotina":"", '
    cJson += '            "tipoArquivo":"zip", '
    cJson += '            "destino":"\\TesteCentralAtualizaçao\\", '
    cJson += '            "ativo":true '
    cJson += '        }, '
    cJson += '        "2019": '
    cJson += '        { '
    cJson += '            "versao":{ '
    cJson += '                "nome":"2019", '
    cJson += '                "configuracoes":[ '
    cJson += '                    {} '
    cJson += '                ] '
    cJson += '            }, '
    cJson += '            "repositorio": "https://arte.engpro.totvs.com.br", '
    cJson += '            "uri": "/PUBLIC/sigapls/artefatos/Testes/ArtefatoAntigo_2019.zip", '
    cJson += '            "rotina":"", '
    cJson += '            "tipoArquivo":"zip", '
    cJson += '            "destino":"\\TesteCentralAtualizaçao\\", '
    cJson += '            "ativo":true '
    cJson += '        } '
    cJson += '    } '
    cJson += '} '
   oJson:FromJson(cJson)
Return oJson


