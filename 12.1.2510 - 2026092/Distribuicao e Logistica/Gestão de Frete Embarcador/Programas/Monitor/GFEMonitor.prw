#INCLUDE "TOTVS.CH"
#INCLUDE "GFEMONITOR.CH"

/*/{Protheus.doc} GFEListaMonitores
Adiciona na lista o nome e descrição de todos os Monitores criados para o programa Gestão à vista
@type Method
@author Jefferson Hita
@since 08/08/2023
@version P12.1.2310
/*/
Function GFEListaMonitores(aMonitores)
    
    aAdd(aMonitores, {"DocFreteBloqueados", "Doc. Frete Bloqueados"})
    aAdd(aMonitores, {"MonitorCarregamento", "Monitor de Carregamento"})
    aAdd(aMonitores, {"MonitorEntrega", "Monitor de Entregas"})

Return
