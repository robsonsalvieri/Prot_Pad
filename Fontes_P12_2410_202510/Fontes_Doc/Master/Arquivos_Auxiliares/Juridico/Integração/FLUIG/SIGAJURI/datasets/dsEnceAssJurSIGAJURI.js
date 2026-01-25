function createDataset(fields, constraints, sortFields) {
	var dsEnceAssjur = DatasetBuilder.newDataset();
	dsEnceAssjur.addColumn("retorno");
	
	var cdAssJur	= "";
	var sStatus 	= "";
	var sObs 		= "";
	var sUser 		= "";
	var cdCajuri 	= "";
	var cdFilialNS7 = "";
	var sUserGroup  = "";
	
	var retorno = true;
	
	
	for (var i = 0; i < constraints.length; i++){
		if (constraints[i].fieldName == "cdAssJur"){
			cdAssJur = constraints[i].initialValue;
		} else if (constraints[i].fieldName == "sStatus"){
			sStatus = constraints[i].initialValue;			
		} else if (constraints[i].fieldName == "sObs"){
			sObs = constraints[i].initialValue;
		} else if (constraints[i].fieldName == "sUser"){
			sUser = constraints[i].initialValue;			
		} else if (constraints[i].fieldName == "cdCajuri"){
			cdCajuri = constraints[i].initialValue;			
		} else if (constraints[i].fieldName == "cdFilialNS7"){
			cdFilialNS7 = constraints[i].initialValue;			
		} else if (constraints[i].fieldName == "sUserGroup"){
			sUserGroup = constraints[i].initialValue;			
		}
	}
	
	try{
		// Parâmetros para Autenticação básica
		var dsParamsSIGAJURI = DatasetFactory.getDataset("dsParamsSIGAJURI", new Array(), new Array(), null);
        var sUserAuth = dsParamsSIGAJURI.getValue(0,"sUserAuth");
	    var sPassAuth = dsParamsSIGAJURI.getValue(0,"sPassAuth");
	
		var service = ServiceManager.getService('SIGAJURI');
		var serviceHelper = service.getBean();
		var serviceLocator = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.WSFLUIGJURIDICO');
		var UpdFUService = serviceLocator.getWSFLUIGJURIDICOSOAP();
		var authBasicService = serviceHelper.getBasicAuthenticatedClient(UpdFUService, sUserAuth, sPassAuth);
		
		var aDados = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.STRUENCERRA');
		aDados.setTIPOASSUNTOJURIDICO(cdAssJur);
		aDados.setOBSERVACOES(sObs);
		aDados.setASSUNTOJURIDICO(cdCajuri);
		aDados.setEMAILUSUARIOENCERRA(sUser);
		aDados.setSTATUS(sStatus);
		aDados.setESCRITORIO(cdFilialNS7);
		
		// caso seja consultivo e encerramento, manda o usuário que respondeu a solicitação para ser gravado como sigla2
		if (cdAssJur == "005" && sStatus == "1"){
			setSigla2(sUserGroup, cdFilialNS7, cdCajuri);		
		}

		retorno = authBasicService.mtjurencerraassjur(aDados);
		
		dsEnceAssjur.addRow(new Array(retorno));
	}
	catch(e){
		log.error("*** dsEnceAssJurSIGAJURI - ERRO: " + e.message);
		dsEnceAssjur.addRow(new Array(e.message));
	}
	
	return dsEnceAssjur;
}

function setSigla2(sUserGroup, cdFilialNS7, cdCajuri){
	try{
		// Parâmetros para Autenticação básica
		var dsParamsSIGAJURI = DatasetFactory.getDataset("dsParamsSIGAJURI", new Array(), new Array(), null);
        var sUserAuth = dsParamsSIGAJURI.getValue(0,"sUserAuth");
	    var sPassAuth = dsParamsSIGAJURI.getValue(0,"sPassAuth");
		
		var service = ServiceManager.getService('SIGAJURI');
		var serviceHelper = service.getBean();
		var serviceLocator = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.WSFLUIGJURIDICO');
		var IncConsService = serviceLocator.getWSFLUIGJURIDICOSOAP();
		var authBasicService = serviceHelper.getBasicAuthenticatedClient(IncConsService, sUserAuth, sPassAuth);
		
		retorno = authBasicService.mtatualizasigla2(sUserGroup, cdFilialNS7, cdCajuri);		
		
		return retorno;
		
	}
	catch(e){
		log.error("*** dsEnceAssJurSIGAJURI/ setSigla2 - Erro ao atualizar sigla2 SIGAJURI. ");
		log.error("*** dsEnceAssJurSIGAJURI/ setSigla2 - ERRO: " + e.message);
		
	}
	
	return false;
}