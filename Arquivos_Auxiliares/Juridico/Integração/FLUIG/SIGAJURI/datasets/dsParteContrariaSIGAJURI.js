function createDataset(fields, constraints, sortFields) {
	// Dataset para recuperar os escritórios cadastrados no SIGAJURIS via Webservice (NS7).
	
	var dsParte = DatasetBuilder.newDataset();
	dsParte.addColumn("id");
	dsParte.addColumn("Razao_Social");
	dsParte.addColumn("Cnpj");
	
	var cFiltro = "";
	var cEscritorio = "";
	
	for (var i = 0; i < constraints.length; i++){			
		if (constraints[i].fieldName == "Razao_Social"){
			cFiltro = constraints[i].initialValue;
		}
		if (constraints[i].fieldName == "Escritorio"){
			cEscritorio = constraints[i].initialValue;
		}
		console.log("constraints: " + constraints[i].fieldName + "|" + constraints[i].initialValue);
	}
	
	try{
		// Parâmetros para Autenticação básica
		var dsParamsSIGAJURI = DatasetFactory.getDataset("dsParamsSIGAJURI", new Array(), new Array(), null);
        var sUserAuth = dsParamsSIGAJURI.getValue(0,"sUserAuth");
	    var sPassAuth = dsParamsSIGAJURI.getValue(0,"sPassAuth");

		var service = ServiceManager.getService('SIGAJURI');
		var serviceHelper = service.getBean();
		var serviceLocator = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.WSFLUIGJURIDICO');
		var AssJurService = serviceLocator.getWSFLUIGJURIDICOSOAP();
		var authBasicService = serviceHelper.getBasicAuthenticatedClient(AssJurService, sUserAuth, sPassAuth);
		
		var PartContraria = authBasicService.mtpartescontrarias(cFiltro, cEscritorio);
		var Dados = PartContraria.getSTRUPARTCONT();
		
		for(var i = 0; i < Dados.size(); i++){
			dsParte.addRow(new Array(Dados.get(i).getCODIGO(), Dados.get(i).getRAZAOSOCIAL().trim(), Dados.get(i).getCNPJ().trim()));
		}	
	}
	catch(e){
		dsParte.addRow(new Array("", e.message));
	}
	
	return dsParte;
}