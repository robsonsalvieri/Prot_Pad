function servicetask36(attempt, message) {
var constraints = new Array();
var dataHoje = new Date()
var fields = new Array("statusAssinatura");
var numSolic = getValue("WKNumProces");
var sAssLista = hAPI.getCardValue("sAssLista");
var cdDocAsign = hAPI.getCardValue("cdDocAsign")
var cErrorMessage = ""
var horaEnv = dataHoje.toLocaleTimeString('pt-BR')
var dataEnv = dataHoje.toLocaleDateString('pt-BR');
var lastVersion = -1;

	log.info("*** ServiceTask Contrato [" + numSolic + "]: Chamando dataset de atualização");
	//DatasetFactory.getDataset("ds_package_vertsign", null, constraints, null);

	log.info("*** ServiceTask Contrato [" + numSolic + "]: Inicio Valida Assinatura! Tentativa:" + attempt);

	// Chama o dataSet de upload manual para sincronizar com a Vertsign
	log.info("*** Contrato Valida Assinatura [" + numSolic + "]: Lista de Assinadores: " + sAssLista);
	log.info("*** Contrato Valida Assinatura [" + numSolic + "]: Código Documento:" + cdDocAsign);	
	
	try {
		constraints.push(DatasetFactory.createConstraint("codArquivo", cdDocAsign, cdDocAsign, ConstraintType.MUST));
		var dsFormAux = DatasetFactory.getDataset("ds_form_aux_vertsign", fields, constraints, null);

		if (dsFormAux.rowsCount > 0){
			if (dsFormAux.getValue(0,"statusAssinatura") == "Assinado"){
				return true;
			} else {
				if (dsFormAux.getValue(0,"statusAssinatura") == "Pendente Assinatura"){
					cErrorMessage = "[" + numSolic + "] O documento ainda não foi assinado por todos os responsáveis. Status: "  + dsFormAux.getValue(0,"statusAssinatura");
				} else if (dsFormAux.getValue(0,"statusAssinatura") == "Enviando para assinatura"){
					cErrorMessage = "[" + numSolic + "] Houve erros durante o envio do documento, verifique novamente. Status: "  + dsFormAux.getValue(0,"statusAssinatura");
					log.info("*** ServiceTask Contrato [" + numSolic + "]: O documento não foi enviado para a Vertsign. CodAnexo[" + cdDocAsign + "] | Forçando reenvio. ");
					DatasetFactory.getDataset("ds_upload_vertsign_manual", null, constraints, null);
				} else {
					cErrorMessage = "[" + numSolic + "] O documento foi recusado por um dos responsáveis. Status: "  + dsFormAux.getValue(0,"statusAssinatura");
				}

				throw cErrorMessage;
			}
		} else {
			cErrorMessage = "[" + numSolic + "] O status do Documento é: Pendente Assinatura."
			throw cErrorMessage;
		}
	}catch(e){
		var errorClass = null;
		if (cErrorMessage == ""){
			cErrorMessage = e.message;
			errorClass = e;
		} else {
			errorClass = cErrorMessage;
		}
		log.error("*** ServiceTask Contrato: " + cErrorMessage);
		throw errorClass;
	}
	log.info("*** ServiceTask Contrato [" + numSolic + "]: Fim Valida Assinatura!");
}