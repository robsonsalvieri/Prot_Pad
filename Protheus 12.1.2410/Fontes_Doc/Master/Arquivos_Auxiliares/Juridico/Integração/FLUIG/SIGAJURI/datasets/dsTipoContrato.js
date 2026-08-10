function createDataset(fields, constraints, sortFields) {
	// Dataset para recuperar os Tipos de Contrato do SIGAJURI via Webservice. 
	
	var dsTipoCon = DatasetBuilder.newDataset();
	dsTipoCon.addColumn("id");
	dsTipoCon.addColumn("TipoCon");
	
	try{
		// Parâmetros para Autenticação básica
		var dsParamsSIGAJURI = DatasetFactory.getDataset("dsParamsSIGAJURI", new Array(), new Array(), null);
        var sUserAuth = dsParamsSIGAJURI.getValue(0,"sUserAuth");
	    var sPassAuth = dsParamsSIGAJURI.getValue(0,"sPassAuth");

		var service = ServiceManager.getService('SIGAJURI');
		var serviceHelper = service.getBean();
		var serviceLocator = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.WSFLUIGJURIDICO');
		var TipoConService = serviceLocator.getWSFLUIGJURIDICOSOAP();
		var authBasicService = serviceHelper.getBasicAuthenticatedClient(TipoConService, sUserAuth, sPassAuth);
		
		var TipoCon = authBasicService.mttiposcontratos();
		var Dados = TipoCon.getDADOS().getSTRUDADOS();
		
		dsTipoCon.addRow(new Array("-", "-"));
		
		for(var i = 0; i < Dados.size(); i++){
			dsTipoCon.addRow(new Array(Dados.get(i).getCODIGO(), Dados.get(i).getDESCRICAO().trim()));
		}	
	}
	catch(e){
		dsTipoCon.addRow(new Array("", e.message));
	}
	
	return dsTipoCon;
}