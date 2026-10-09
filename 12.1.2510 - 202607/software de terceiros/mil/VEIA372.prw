/*/{Protheus.doc} VEIA372
	Função utilizada para chamada da aplicação PO-UI "Central de aprovações"
	@type  Function
    @author Bruno Forcato / Renan Migliaris
	@since 29/06/2025
	/*/
Function VEIA372()
    FwCallApp('dms-aprovamil',/*owner*/,/*oEngine*/,/*oChannel*/,/*cHost*/,/*cSource*/,/*Param7*/,/*Param8*/,/*Param9*/,.t.)
return

Static Function JsToAdvpl(oWebChannel,cType,cContent)
    if (cType == 'preLoad')
        oWebChannel:AdvPLToJS('displayOnlyFont', '')
    endif
Return .T.
