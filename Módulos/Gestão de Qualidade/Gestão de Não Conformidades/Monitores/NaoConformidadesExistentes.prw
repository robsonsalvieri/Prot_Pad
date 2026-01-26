#INCLUDE "TOTVS.CH"
#INCLUDE "QLTMONITORDEF.CH"
#INCLUDE "OcorrenciasDeMelhoriasQNC.CH"

/*/{Protheus.doc} NaoConformidadesExistentes
Classe para prover os dados do Monitor de Ocorrências de Melhoria do Módulo Controle de Não Conformidades (QNC)
@type Class
@author brunno.costa
@since 19/10/2023
@version P12.1.2310
@return Nil
/*/
Class NaoConformidadesExistentes FROM LongNameClass
	
    //Métodos Padrões
    Static Method BuscaDados(oFiltros, cTipo, cSubTipo, cTpFicha)
	Static Method BuscaDetalhes(oFiltro, nPagina, cTpFicha)
	Static Method CargaMonitor()
    Static Method ValidaPropriedades(oFiltros)

EndClass

/*/{Protheus.doc} CargaMonitor
Realiza a carga do Monitor padrão na base de dados
@type Method
@author brunno.costa
@since 19/10/2023
@version P12.1.2310
@return lRet, logico, Indica se conseguiu realizar a carga
/*/
Method CargaMonitor() Class NaoConformidadesExistentes
    Local lRet        := .T.
    Local nIndTag     := 0
    Local oCarga      := PCPMonitorCarga():New()
    Local oExemplo    := JsonObject()     :New()
    Local oParametros := JsonObject()     :New()
        
    If !PCPMonitorCarga():monitorAtualizado("NaoConformidadesExistentes")
        
        oCarga:setaTitulo(STR0072) //"Não Conformidades Existentes"
        oCarga:setaObjetivo(STR0073) //"Apresentar o número de Não Conformidades Existentes do módulo Controle de Não Conformidades com origem de um módulo específico ou de qualquer módulo, de um determinado Departamento Origem ou Destino ou qualquer departamento, dentro de um período configurado, utilizando o conceito de semáforo para indicar os níveis Aceitável, Atenção e Crítico."
        oCarga:setaAgrupador(STR0003) //"Qualidade"
        oCarga:setaFuncaoNegocio("NaoConformidadesExistentes")
        oCarga:setaTiposPermitidos("chart;info")
        oCarga:setaTiposGraficoPermitidos("gauge")
        oCarga:setaTipoPadrao("info")
        oCarga:setaTipoGraficoPadrao("")
        oCarga:setaTipoDetalhe("detalhe")

        oExemplo := OcorrenciasDeMelhoriasQNC():MontaJsonInfo(@oExemplo,123,{"10","0"},"2")

        oExemplo["tags"] := {}
        PCPMonitorUtils():AdicionaTagMonitor(oExemplo["tags"],@nIndTag,"po-icon-calendar",DtoC(dDataBase-180) + " - " + DtoC(dDataBase))

        oCarga:setaExemploJsonTexto(.F.,oExemplo)

        //STR0004 - "Filial Ocorrência"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeFilial(@oCarga, "01_QI2_FILIAL", STR0004 + "*")

        //STR0005 - Atenção
        //STR0006 - Urgente
        //STR0007 - Semáforo
        oCarga:setaPropriedade("02_SEMAFORO", STR0005 + ";" + STR0006, STR0007 + " (" + STR0005 + ";" + STR0006 + ")*",1,30,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12",/*oEstilos*/,/*cIcone*/,/*oParametros*/)

        //STR0008 - "Módulo Origem"
        oCarga:setaPropriedade("03_MODULOORIGEM" ,"",STR0008,5,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboModuloOrigem(oParametros["03_MODULOORIGEM"]))
        
        //STR0009 - "Período"
        oCarga:setaPropriedade("04_TIPOPERIODO","",STR0009 + "*",4,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboPeriodos(oParametros["04_TIPOPERIODO"]))

        //STR0010 - STR0011 - "Período personalizado (anos)"
        oCarga:setaPropriedade("05_PERIODO_PERSONALIZADO","9",STR0010 + " (" + STR0011 + ")",2,1,0,"po-lg-6 po-xl-6 po-md-6 po-sm-12")

        //STR0012 - "Situação Ocorrência"
        oCarga:setaPropriedade("06_SITUACAO" ,"",STR0012,5,,,"po-lg-6 po-xl-6 po-md-6 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboSituacao(oParametros["06_SITUACAO"]))

        //STR0013 - "Filial Origem"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeFilial(@oCarga, "07_QI2_FILORI", STR0013)
        
        //STR0014 - "Departamento Origem"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeLookupTabela(@oCarga, "08_QI2_ORIDEP",STR0014,.F.,"QAD","QAD_CUSTO","QAD_DESC",7)

        //STR0015 - "Filial Destino"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeFilial(@oCarga, "09_QI2_FILDEP", STR0015)
        
        //STR0016 - "Departamento Origem"
        OcorrenciasDeMelhoriasQNC():SetaPropriedadeLookupTabela(@oCarga, "10_QI2_DESDEP",STR0016,.F.,"QAD","QAD_CUSTO","QAD_DESC",9)

        //STR0017 - "Status"
        oCarga:setaPropriedade("11_STATUS","",STR0017,5,,,"po-lg-12 po-xl-12 po-md-12 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboStatus(oParametros["11_STATUS"]))

        //STR0065 - "Status Plano de Ação"
        oCarga:setaPropriedade("12_STATUS_PA","",STR0065,5,,,"po-lg-12 po-xl-12 po-md-12 po-sm-12",,,OcorrenciasDeMelhoriasQNC():MontaComboStatusPlanoDeAcao(oParametros["12_STATUS_PA"]))

        lRet := iif(oCarga:gravaMonitorPropriedades(), lRet, .F.)
        oCarga:Destroy()
    EndIf
    FreeObj(oExemplo)
    FreeObj(oParametros)
Return lRet

/*/{Protheus.doc} BuscaDados
Responsável por realizar a busca dos dados que serão exibidos no monitor (gráfico ou texto)

@type Class
@author brunno.costa
@since 19/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto Json, Contém as propriedades do monitor usadas para filtrar a query de busca
@param 02 - cTipo   , caracter   , Tipo chart/info
@param 03 - cSubTipo, caracter   , Tipo de grafico pie/bar/column
@return cJsonDados, caracter   , Retorna um novo Json em formato texto, pronto para conversão e exibição no front
/*/
Method BuscaDados(oFiltros, cTipo, cSubTipo) Class NaoConformidadesExistentes
    Local cTpFicha := "2"
Return OcorrenciasDeMelhoriasQNC():BuscaDados(oFiltros, cTipo, cSubTipo, cTpFicha)

/*/{Protheus.doc} BuscaDetalhes
Realiza a busca dos dados para montar os detalhes do Monitor
@type Method
@author brunno.costa
@since 19/10/2023
@version P12.1.2310
@param 01 - oFiltros, objeto, objeto json com os filtros da consulta 
@param 02 - nPagina , número, número de página da consulta
@param 03 - cTpFicha, caracter, comparação /para filtro do tipo de ficha
@return cJson, string Json, string com os dados de detalhes para exibição em tabela de detalhes
/*/
Method BuscaDetalhes(oFiltros, nPagina, cTpFicha) Class NaoConformidadesExistentes
       Local cTpFicha := "2"
Return OcorrenciasDeMelhoriasQNC():BuscaDetalhes(oFiltros, nPagina, cTpFicha)


/*/{Protheus.doc} ValidaPropriedades
Valida os dados informados nas propriedades do Monitor
@type Method
@author brunno.costa
@since 19/10/2023
@version P12.1.2310
@param  oFiltros, objeto json, Objeto json com os filtros para a consulta dos dados
@return aRetorno, array      , [1] logico - indica se os dados são válidos [2] caracter - mensagem de erro
/*/
Method ValidaPropriedades(oFiltros) Class NaoConformidadesExistentes
Return OcorrenciasDeMelhoriasQNC():ValidaPropriedades(oFiltros)
