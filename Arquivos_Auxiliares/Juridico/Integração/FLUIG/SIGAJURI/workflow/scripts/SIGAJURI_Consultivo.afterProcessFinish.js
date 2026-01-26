function afterProcessFinish(processId){	
   	log.info("*** afterProcessFinish: entrou:" + hAPI.getCardValue("sStatusResp"));
	try{
	   	var resposta = hAPI.getCardValue("sResposta");
	   	var obs = getValue("WKUserComment");
	   	if (obs != null && obs != ""){
	   		resposta += "\n" + obs;
	   	}
		if (hAPI.getCardValue("sStatusResp") == "1"){
	   		lAtu = encerraAssJurSIGAJURI(hAPI.getCardValue("cdAssJur"), hAPI.getCardValue("cdCajuri"), hAPI.getCardValue("sStatusResp"), resposta, getMailByUserId(hAPI.getCardValue("cdSolicitante")) );
	   	}
		hAPI.setCardValue("sStatusProc","2");
	}catch(e){
		log.error("*** afterProcessFinish: Falha ao encerrar a consulta.");
		log.error("*** afterProcessFinish: ERROR: " + e.message);
	}
	
}