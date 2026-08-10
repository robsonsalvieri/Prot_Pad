function beforeCancelProcess(colleagueId,processId){
	var lAtu = false;

	if (getValue("WKUserComment") == null || getValue("WKUserComment") == "") {
		throw "A observação deve ser preenchida";
	}else{
		hAPI.setCardValue("sStatusProc","3");	//3=Cancelado

		if (hAPI.getCardValue("sRevisaDoc") != "2") {
			if (updateContrato()){
				//validar se alguma parte foi incluída.
				if (hAPI.getCardValue("sPassivo")==""){
					hAPI.setCardValue("sPassivo",hAPI.getCardValue("sRazaoSocial"));
					hAPI.setCardValue("optPassivo","optOutros");
				}else if (hAPI.getCardValue("sAtivo")==""){
					hAPI.setCardValue("sAtivo",hAPI.getCardValue("sRazaoSocial"));
					hAPI.setCardValue("optAtivo","optOutros");
				}
			}else{
				throw "Erro ao atualizar o assunto jurídico no SIGAJURI.";
			}
		}

		lAtu = encerraAssJurSIGAJURI(hAPI.getCardValue("cdAssJur"), hAPI.getCardValue("cdCajuri"), "2", getValue("WKUserComment"), getMailByUserId(colleagueId) );
	}

	if (lAtu == false){
		throw "Erro ao atualizar o SIGAJURI. O workflow não pode ser cancelada.";
	}
	
}

function encerraAssJurSIGAJURI(cdAssJur,cdCajuri, sStatus, sObs, sUser ){
	var constraints = new Array();
	var response = null;
	var cdFilialNS7 = hAPI.getCardValue("cdFilialNS7");
	
	constraints.push(DatasetFactory.createConstraint("cdAssJur", cdAssJur, cdAssJur, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStatus", sStatus, sStatus, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sObs", sObs, sObs, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sUser", sUser, sUser, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdCajuri", cdCajuri, cdCajuri, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdFilialNS7", cdFilialNS7, cdFilialNS7, ConstraintType.MUST));
		
	try{
		response = DatasetFactory.getDataset("dsEnceAssJurSIGAJURI", null, constraints, null);
	}catch(e){
		log.error("** encerraAssJurSIGAJURI: Falha ao buscar dataset.");
		log.error("** encerraAssJurSIGAJURI: ERRO: " + e.message);
	}
	
	if (response){
		var retorno = response.getValue(0, "retorno");
		
		if (String(retorno) == "true"){
			return true;
		} else {
			log.error("*** encerraAssJurSIGAJURI: ERRO: retorno falso do SIGAJURI ");
			return false;
		}
	}	else{
		log.error("** encerraAssJurSIGAJURI: Response false ");
	}
	
	return false;
}