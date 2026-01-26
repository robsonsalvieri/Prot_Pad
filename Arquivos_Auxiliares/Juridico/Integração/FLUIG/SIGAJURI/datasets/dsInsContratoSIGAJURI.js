function createDataset(fields, constraints, sortFields) {
	var dsContratoSIGAJURI = DatasetBuilder.newDataset();
	dsContratoSIGAJURI.addColumn("cdCajuri");
	dsContratoSIGAJURI.addColumn("sCodigoJuridico");
	dsContratoSIGAJURI.addColumn("sAprovacao");
	dsContratoSIGAJURI.addColumn("cdFollowup");
	dsContratoSIGAJURI.addColumn("sPastaCaso");
	
	var retorno = true;
	var cdWF;
	var cdFilialNS7;
	var cdAreaSol;
	var dtPrazoTarefa;
	var sSolicitante;
	var sMailAdvogado;
	var cdTipoCon;
	var sDescSol;
	var sObservacao;
	var cdAssJur;
	var sMailSolicitante;
	var sCampoRetorno;
	var sStepDestinoConc;
	var sRazaoSocial;
	var sCnpj;
	var sEndereco;
	var sBairro;
	var sEstado;
	var sCidade;
	var sCep;
	var cdAtivo;
	var cdPassivo;
	var cdEntPassivo;
	var cdEntAtivo;
	var sTipoParte;
	var sRenovacao;
	var sValor;
	var sVigenciaDe;
	var sVigenciaAte;
	var sCondPagamento;
	var sStepDestinoCanc;
	var sResponsavel;
	var sTipoImpressao;

	try{
		// Parâmetros para Autenticação básica
		var dsParamsSIGAJURI = DatasetFactory.getDataset("dsParamsSIGAJURI", new Array(), new Array(), null);
        var sUserAuth = dsParamsSIGAJURI.getValue(0,"sUserAuth");
	    var sPassAuth = dsParamsSIGAJURI.getValue(0,"sPassAuth");

		var service = ServiceManager.getService('SIGAJURI');
		var serviceHelper = service.getBean();
		var serviceLocator = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.WSFLUIGJURIDICO');
		var IncContService = serviceLocator.getWSFLUIGJURIDICOSOAP();
		var authBasicService = serviceHelper.getBasicAuthenticatedClient(IncContService, sUserAuth, sPassAuth);
		
		var aDados = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.STRUCONTRATOASSUNTO');
		
		var sServiceCustom = serviceHelper.instantiate('wsfluigjuridico.sigajuri.totvs.com.ARRAYOFSTRUCUSTOM');
		
		for (var i = 0; i < constraints.length; i++){
			if (constraints[i].fieldName == "cdWF"){
				cdWF             = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "cdFilialNS7"){
				cdFilialNS7      = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "cdAreaSol"){
				cdAreaSol        = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "dtPrazoTarefa"){
				dtPrazoTarefa    = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sSolicitante"){
				sSolicitante     = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sMailAdvogado"){
				sMailAdvogado    = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "cdTipoCon"){
				cdTipoCon        = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sDescSol"){
				sDescSol         = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sObservacao"){
				sObservacao      = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "cdAssJur"){
				cdAssJur         = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sMailSolicitante"){
				sMailSolicitante = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sCampoRetorno"){
				sCampoRetorno    = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sStepDestinoConc"){
				sStepDestinoConc = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sRazaoSocial"){
				sRazaoSocial     = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sCnpj"){
				sCnpj            = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sEndereco"){
				sEndereco        = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sBairro"){
				sBairro          = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sEstado"){
				sEstado          = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sCidade"){
				sCidade          = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sCep"){
				sCep             = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "cdAtivo"){
				cdAtivo          = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "cdPassivo"){
				cdPassivo        = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "cdEntPassivo"){
				cdEntPassivo     = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "cdEntAtivo"){
				cdEntAtivo       = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sTipoParte"){
				sTipoParte       = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sRenovacao"){
				sRenovacao       = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sValor"){
				sValor           = constraints[i].initialValue.replace(".","").replace(",",".");
			} else if (constraints[i].fieldName == "sVigenciaDe"){
				sVigenciaDe      = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sVigenciaAte"){
				sVigenciaAte     = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sCondPagamento"){
				sCondPagamento   = constraints[i].initialValue;
			} else if (constraints[i].fieldName == "sStepDestinoCanc"){
				sStepDestinoCanc = constraints[i].initialValue;
			} else {
				sServiceCustom.getSTRUCUSTOM().add(createDSCustom(serviceHelper, constraints[i].fieldName,constraints[i].initialValue));
			}
		}

		//Seta os valores das variáveis.
		aDados.setSOLICITACAO(cdWF);
		aDados.setESCRITORIO(cdFilialNS7);
		aDados.setAREA(cdAreaSol);
		aDados.setDATAINCLUSAO(dtPrazoTarefa);
		aDados.setSOLICITANTE(sSolicitante);
		aDados.setADVOGADO(sMailAdvogado);	
		aDados.setTIPOCONTRATO(cdTipoCon);		
		aDados.setDESCRICAOSOLICITACAO(sDescSol);
		aDados.setOBSERVACOES(sObservacao);
		aDados.setTIPOASSUNTOJURIDICO(cdAssJur);
		aDados.setEMAILSOLICITANTE(sMailSolicitante);		
		aDados.setCAMPORETORNO(sCampoRetorno);
		aDados.setSTEPDESTINOCONC(sStepDestinoConc);
		aDados.setNOMEPARTEC(sRazaoSocial);
		aDados.setCGCPARTEC(sCnpj);
		aDados.setENDERECOPARTEC(sEndereco);	
		aDados.setBAIRROPARTEC(sBairro);
		aDados.setESTADOPARTEC(sEstado);
		aDados.setMUNICIPIOPARTEC(sCidade);			
		aDados.setCEPPARTEC(sCep);
		aDados.setPOLOATIVO(cdAtivo);
		aDados.setPOLOPASSIVO(cdPassivo);
		aDados.setENTPOLOPASSIVO(cdEntPassivo);		
		aDados.setENTPOLOATIVO(cdEntAtivo);			
		aDados.setTIPOPESSOAPARTEC(sTipoParte);
		aDados.setRENOVACAOAUTO(sRenovacao);		
		aDados.setVALORCONTRATO(sValor);
		aDados.setVIGENCIAINICIO(sVigenciaDe);
		aDados.setVIGENCIAFIM(sVigenciaAte);
		aDados.setCONDICAO(sCondPagamento);
		aDados.setSTEPDESTINOCANC(sStepDestinoCanc);
		aDados.setCAMPOCUSTOMIZADOS(sServiceCustom);

		// Chamar a gera��o de Contratos
		retorno = authBasicService.mtgeracontratoassuntojuridico(aDados);
		
		dsContratoSIGAJURI.addRow( new Array(retorno.getNUMEROCONSULTA(), retorno.getCODIGOJURIDICO(), retorno.getFLUXOAPROVACAO(), retorno.getCODIGOFOLLOWUP(), retorno.getPASTACASO()) );
	}
	catch(e){
		dsContratoSIGAJURI.addRow(new Array("","",""));
		log.info("dsContratoSIGAJURI: Erro ao gerar um assunto contrato no SIGAJURI: " + e.message);
	}
	
	return dsContratoSIGAJURI;
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