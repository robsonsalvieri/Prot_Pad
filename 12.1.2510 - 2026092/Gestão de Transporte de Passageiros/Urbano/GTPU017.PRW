#INCLUDE 'TOTVS.CH'
#INCLUDE 'GTPU017.CH'

/*/{Protheus.doc} GTPU017
    Rotina de execução de JOB do Urbano
    @type  Function
    @author João Pires
    @since 14/05/2025
    @version 1.0
    
    /*/
Function GTPU017()
    Local oBrowse := Nil

    oBrowse	:= FWMBrowse():New()
    oBrowse:SetAlias("GYS")
    oBrowse:SetDoubleClick({|| GTPMVIEW() })    
    oBrowse:AddButton(STR0001, {|| GTPUJ001(), oBrowse:Refresh() } ) //"+ Alocação Aut." 
    oBrowse:AddButton(STR0002, {|| GTPMVIEW() } ) //"Visualizar"
    oBrowse:SetDescription(STR0003)//"Logs de erros"
    oBrowse:SetFilterDefault( 'GYS_ROTINA == "GTPUJ001"')
    oBrowse:ExecuteFilter(.T.)
    oBrowse:Activate()


Return 
