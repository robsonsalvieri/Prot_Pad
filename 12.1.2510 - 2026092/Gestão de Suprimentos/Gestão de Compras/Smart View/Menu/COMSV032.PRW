#include 'protheus.ch'
#include 'fwmvcdef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} COMSV032 - xml importer receipt list
    lista de recibos do importador xml
@since 14/02/2024
/*/
//-------------------------------------------------------------------
Function COMSV032()

    //1º parâmetro = Tipo XML ?
    //2º parâmetro = Dt. import. De ?
    //3º parâmetro = Dt. import. Ate ?

    totvs.framework.treports.callTReports('backoffice.sv.com.xmlimporterreceiptlist',,,,,.F.,,,)

return
