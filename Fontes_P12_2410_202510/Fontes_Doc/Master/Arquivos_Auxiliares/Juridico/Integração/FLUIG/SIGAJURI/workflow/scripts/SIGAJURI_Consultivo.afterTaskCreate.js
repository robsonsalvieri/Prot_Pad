function afterTaskCreate(colleagueId){
	var segundos = 50400;
	var lOk = false;
	var cSep = "-";
	var nDia = 2;
	var nMes = 1;
	var nAno = 0;
	var dataForm = hAPI.getCardValue("dtPrazoTarefa");
             
    // Recupera o numero da solicitação
    var processo = getValue("WKNumProces");
    
    log.info("*** Data Form:" + dataForm);
        	
	if (dataForm != null && dataForm.trim() != "" && dataForm != ""){
		
		//valida o separador entre / e -
	    if (dataForm.indexOf("/")>0){
    		cSep = "/";
    		nAno = 2;
    		nDia = 0;
    	}
	    var dateParts = dataForm.split(cSep);
	    log.info("*** due calculado: Dia:" + dateParts[nDia] + ", Mes:" +  dateParts[nMes] + ", Ano:" + dateParts[nAno]);
	    
    	var dtPrazo = new Date(dateParts[nAno], (dateParts[nMes] - 1), dateParts[nDia]); //Javascript reconhece 0 como janeiro, 1 fevereiro ....
		lOk = true;
    }
	        
    if (lOk){
		// Seta o prazo para as 14:00
		log.info("*** due setado: Data:" + dtPrazo.toString());
		hAPI.setDueDate(processo, 0, colleagueId, dtPrazo, segundos);
	}
}