#INCLUDE "TOTVS.CH"
#INCLUDE "QLTListaMonitores.CH"

Function QLTListaMonitores(aMonitores)
    
    Iif(FindClass("InspecoesDeProcessoPendentes"), aAdd(aMonitores, {"InspecoesDeProcessoPendentes", STR0002}), Nil) //"Inspeções Processo Pendentes"
    Iif(FindClass("EntradasAInspecionar")        , aAdd(aMonitores, {"EntradasAInspecionar"        , STR0001}), Nil) //"Entradas à Inspecionar"
    Iif(FindClass("OcorrenciasDeMelhoriasQNC")   , aAdd(aMonitores, {"OcorrenciasDeMelhoriasQNC"   , STR0003}), Nil) //"Ocorrências de Melhorias QNC
    Iif(FindClass("NaoConformidadesPotenciais")  , aAdd(aMonitores, {"NaoConformidadesPotenciais"  , STR0004}), Nil) //"Não Conformidades Potenciais"
    Iif(FindClass("NaoConformidadesExistentes")  , aAdd(aMonitores, {"NaoConformidadesExistentes"  , STR0005}), Nil) //"Não Conformidades Existentes"
    Iif(FindClass("PendenciasDeDocumentos")      , aAdd(aMonitores, {"PendenciasDeDocumentos"      , STR0006}), Nil) //"Pendências de Documentos"
    Iif(FindClass("AvisosDeDocumentos")          , aAdd(aMonitores, {"AvisosDeDocumentos"          , STR0007}), Nil) //"Avisos de Documentos"
    Iif(FindClass("DocumentosVencidos")          , aAdd(aMonitores, {"DocumentosVencidos"          , STR0008}), Nil) //"Documentos Vencidos"
    Iif(FindClass("DocumentosAVencer")           , aAdd(aMonitores, {"DocumentosAVencer"           , STR0009}), Nil) //"Documentos à Vencer"

Return
