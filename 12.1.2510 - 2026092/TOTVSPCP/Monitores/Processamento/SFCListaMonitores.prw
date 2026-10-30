#INCLUDE "TOTVS.CH"
#INCLUDE "PCPMONITOR.CH"

Function SFCListaMonitores(aMonitores)

    IIF(FindClass("EficienciaSFC")     , aAdd(aMonitores,{"EficienciaSFC"     , STR0312}), Nil) //"Efiência SFC"
    IIF(FindClass("QualidadeSFC")      , aAdd(aMonitores,{"QualidadeSFC"      , STR0349}), Nil) //"Qualidade SFC"
    IIF(FindClass("DisponibilidadeSFC"), aAdd(aMonitores,{"DisponibilidadeSFC", STR0353}), Nil) //"Disponibilidade SFC"
    IIF(FindClass("EficienciaOEESFC")  , aAdd(aMonitores,{"EficienciaOEESFC"  , STR0359}), Nil) //"Eficiência OEE SFC"

Return
