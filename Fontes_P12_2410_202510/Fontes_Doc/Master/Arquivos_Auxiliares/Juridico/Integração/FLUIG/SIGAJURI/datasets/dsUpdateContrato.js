function createDataset(fields, constraints, sortFields) {
	var dsUpdateContrato = DatasetBuilder.newDataset();
	var cdFilialNS7 = '';
	var cdCajuri = '';
	var sDescSol = '';
	var sObservacao = '';
	var cdAtivo = '';
	var cdPassivo = '';
	var cdEntPassivo = '';
	var cdEntAtivo = '';
	var sRenovacao = '';
	var sValor = '';
	var sVigenciaDe = '';
	var sVigenciaAte = '';
	var sCondPagamento = '';
	var sCnpj = ''
	var sRazaoSocial = ''
	var sEndereco = ''
	var sBairro = ''
	var sEstado = ''
	var sCidade = ''
	var sCep = ''
	var sTipoParte = ''				
	var retorno = true;
	
	log.error("*** dsUpdateContrato - Inicio ");
	dsUpdateContrato.addColumn("retorno");
	
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
		
		var aDados = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.STRUATUALIZACONTRATO');
		var sServiceCustom = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.ARRAYOFSTRUCUSTOM');
	
		for (var i = 0; i < constraints.length; i++) {
			if (constraints[i].initialValue != null) {
				if (constraints[i].fieldName == "cdCajuri") {
					cdCajuri = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "cdFilialNS7") {
					cdFilialNS7 = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sDescSol") {
					sDescSol = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sObservacao") {
					sObservacao = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "cdAtivo") {
					cdAtivo = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "cdPassivo") {
					cdPassivo = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "cdEntPassivo") {
					cdEntPassivo = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "cdEntAtivo") {
					cdEntAtivo = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sRenovacao") {
					sRenovacao = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sValor") {
					sValor = constraints[i].initialValue.replace(".", "").replace(
							",", ".");
				} else if (constraints[i].fieldName == "sVigenciaDe") {
					sVigenciaDe = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sVigenciaAte") {
					sVigenciaAte = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sCondPagamento") {
					sCondPagamento = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sRazaoSocial"){
					sRazaoSocial = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sCnpj"){
					sCnpj = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sEndereco"){
					sEndereco = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sBairro"){
					sBairro = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sEstado"){
					sEstado = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sCidade"){ 
					sCidade = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sCep"){
					sCep = constraints[i].initialValue;
				} else if (constraints[i].fieldName == "sTipoParte"){
					sTipoParte = constraints[i].initialValue;
				} else {		
					sServiceCustom.getSTRUCUSTOM().add(createDSCustom(serviceHelper, constraints[i].fieldName,constraints[i].initialValue));				
				}			
			}
		}

		// Seta os valores das variáveis.
		aDados.setESCRITORIO(cdFilialNS7);
		aDados.setCAJURI(cdCajuri);
		aDados.setDESCSOLICITACAO(sDescSol);
		aDados.setOBSERVACAO(sObservacao);
		aDados.setPOLOATIVO(cdAtivo);
		aDados.setPOLOPASSIVO(cdPassivo);
		aDados.setENTPOLOPASSIVO(cdEntPassivo);
		aDados.setENTPOLOATIVO(cdEntAtivo);
		aDados.setRENOVACAOAUTO(sRenovacao);
		aDados.setVALORCONTRATO(sValor);
		aDados.setVIGENCIAINICIO(sVigenciaDe);
		aDados.setVIGENCIAFIM(sVigenciaAte);
		aDados.setCONDPAGAMENTO(sCondPagamento);
		aDados.setNOMEPARTEC(sRazaoSocial);
		aDados.setCPFPARTEC(sCnpj);
		aDados.setENDERECOPARTEC(sEndereco);
		aDados.setBAIRROPARTEC(sBairro);
		aDados.setUFPARTEC(sEstado);
		aDados.setCEPPARTEC(sCep);
		aDados.setTIPOPARTEC(sTipoParte);
		aDados.setMUNICPARTEC(sCidade);
		aDados.setCAMPOCUSTOMIZADOS(sServiceCustom);
		
		retorno = authBasicService.mtatualizacontrato(aDados);

		dsUpdateContrato.addRow(new Array(retorno));
	} catch (e) {
		log.error("*** dsUpdateContrato - ERRO: " + e.message);
		dsUpdateContrato.addRow(new Array(e.message));
	}

	return dsUpdateContrato;
}

function createDSCustom(serviceHelper,campo, valor){
	log.info("StruCustom: " + campo + " | Valor: " + valor);
	var aDadosCustom = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.STRUCUSTOM');
	aDadosCustom.setCCAMPO(campo);
	if (valor == null){
		aDadosCustom.setCVALOR("");
	} else {
		aDadosCustom.setCVALOR(valor);
	}
	return aDadosCustom;
}