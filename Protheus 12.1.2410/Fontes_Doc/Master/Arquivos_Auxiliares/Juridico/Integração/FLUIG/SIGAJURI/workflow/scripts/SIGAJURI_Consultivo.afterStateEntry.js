function afterStateEntry(sequenceId){
var INICIO         	= 1;
var ABRIR          	= 2;
var AGUARDANDORESP 	= 6;
var RESPENVIADA    	= 8;
var FIM            	= 10;
var CANCREVSOL     	= 17;
var REVISAR        	= 13;
var step           	= parseInt(getValue("WKCurrentState"));
var users          	= new java.util.ArrayList();
var nextState      	= null;
var cUser          	= "";
var obs            	= "";
var cdFilialNS7     = "";
var cdCajuri        = "";
var sDescSol        = "";
var sObservacao     = "";

	log.info("*** afterStateEntry Consultivo: Iniciando. Atividade: " + step + "/Sequence Id: " + sequenceId);

	switch(step){
		case 0:
			break;
			
		case INICIO:
			break;
		
		case ABRIR:			
			//cria o assunto consultivo no SIGAJURI
			if (incluiConsultivoSIGAJURI()){
				nextState = AGUARDANDORESP;
				users.clear();

				//valida se vai ter aprovação para deixar a atividade com o admin antes de voltar ao solicitante.
				if (hAPI.getCardValue("sAprovacao") == "true"){
					cUser = getAdminCol();
				}else{
					cUser = hAPI.getCardValue("cdAdvogado");
				}
				hAPI.setCardValue("sExecutorFluig",cUser);
				users.add(cUser);
				hAPI.setAutomaticDecision(nextState, users, "Decisao Automatica: Encaminhado para Aguardando resposta. Responsável: " + hAPI.getCardValue("sAdvogado") );
				//Atualiza o prazo para encerramento da tarefa;
				hAPI.setCardValue("sPrazoEnc", Number(hAPI.getCardValue("sPrazoEnc")));
			
			}else{
				log.error("*** Consultivo: Erro ao criar o assunto jurídico no SIGAJURI."); 
				throw "Erro ao criar o assunto jurídico no SIGAJURI.";
			}
			break;
			
		case AGUARDANDORESP:
			hAPI.setCardValue("sResposta","");
			//valida se estava em revisão, para incluir um novo follow-up
			if (hAPI.getCardValue("sRevisao") == "true"){

				//Executa a função updateConsultivo para atualizar as informações dos campos sDescSol e sObservacao no SIGAJURI
				cdFilialNS7 = hAPI.getCardValue("cdFilialNS7");
				cdCajuri = hAPI.getCardValue("cdCajuri");
				sDescSol = hAPI.getCardValue("sDescSol");
				sObservacao = hAPI.getCardValue("sObservacao");
				updateConsultivo(cdFilialNS7, cdCajuri, sDescSol, sObservacao);
				
				//volta o valor do campo
				hAPI.setCardValue("sRevisao","false");
				
				//Atualiza o prazo da tarefa para o novo follow-up
				hAPI.setCardValue("dtPrazoTarefa", getCurrentDate(Number(hAPI.getCardValue("sPrazoDias"))));
								
				//inclui o Followup no SIGAJURI para a segunda etapa da consulta
				if (!incluiFollowupSIGAJURI()){
					log.error("*** Consultivo: Erro ao incluir novo followup no SIGAJURI."); 
				}
			}
			break;
		
		case REVISAR:
			hAPI.setCardValue("sRevisao","true");

			break;		

		case CANCREVSOL:
			//efetua o cancelamento do workflow
			hAPI.setCardValue("sStatusResp","2");
			hAPI.setCardValue("sStatusProc","2");
	
			if (getValue("WKUserComment") == null || getValue("WKUserComment") == "") {
				obs = "tarefa cancelada via FLUIG na etapa de Revisão da solicitação";
			}else{
				obs = getValue("WKUserComment");
			}
			lAtu = encerraAssJurSIGAJURI(hAPI.getCardValue("cdAssJur"), hAPI.getCardValue("cdCajuri"), hAPI.getCardValue("sStatusResp"), obs , getMailByUserId(colleagueId));
			break;

		case RESPENVIADA:
			hAPI.getCardValue("sResposta");
			
			// Seta o prazo de encerramento para as 18 horas
			if (hAPI.getCardValue("sPrazoEnc") > 0){
				hAPI.setCardValue("sPrazoEnc",getCurrentDate(Number(hAPI.getCardValue("sPrazoEnc"))))
			} else{
				hAPI.setCardValue("sPrazoEnc",getCurrentDate(90))//Number(hAPI.getCardValue("sPrazoEnc"))
			}

			setDueDate(hAPI.getCardValue("sPrazoEnc"),hAPI.getCardValue("sExecutorFluig"), 64800)
			
			log.info("*** afterStateEntry Consultivo: Resposta Enviada: Prazo de encerramento = "+hAPI.getCardValue("sPrazoEnc"));
	
			break;
		
		default: 
			break;
	}

	//grava os documentos na pasta   
	gravaDocs();
}

function getMailByUserId(cUser){
var fields      = new Array();
var constraints = new Array();
var colleagues  = null;
var UserId      = cUser;

	log.info("*** getMailByUserId: Recuperando Mail.");
	fields.push("mail");
	constraints.push(DatasetFactory.createConstraint("active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("colleaguePK.colleagueId", cUser, cUser, ConstraintType.MUST));

	try{
		colleagues = DatasetFactory.getDataset("colleague", fields, constraints, null);

		if (colleagues && colleagues.rowsCount > 0){
			UserId = colleagues.getValue(0, "mail");
		}
	}catch(e){
		log.error("*** getMailByUserId: Falha ao recuperar o dataset.");
		log.error("*** getMailByUserId: ERROR: " + e.message);
	}

	return UserId;
}

function getCardsBySol(cdTipoSol){		
var cards       = null;
var fields      = new Array("metadata#id");
var constraints = new Array();

	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoSol", cdTipoSol, cdTipoSol, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStatusProc", "1", "1", ConstraintType.MUST));

	try {
		cards = DatasetFactory.getDataset("SIGAJURI_Consultivo", fields, constraints, null);
		log.info("*** getCardsBySol:" + cards.rowsCount);
		return cards.rowsCount;

	}catch(e){
		log.error("*** getCardsBySol: Falha ao buscar dataset.");
		log.error("*** getCardsBySol: ERRO: " + e.message);
	}

	return 0;
}

function getCardsByUser(cdTipoSol, cdUser){		
var cards       = null;
var fields      = new Array("metadata#id");
var constraints = new Array();

	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoSol", cdTipoSol, cdTipoSol, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sMailAdvogado", cdUser, cdUser, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStatusProc", "1", "1", ConstraintType.MUST));
	
	log.info("*** getCardsByUser: cdTipoSol:" + cdTipoSol + ", cdAdvogado:" + cdUser);
	
	try {
		cards = DatasetFactory.getDataset("SIGAJURI_Consultivo", fields, constraints, null);
		log.info("*** getCardsByUser:" + cards.rowsCount);

		return cards.rowsCount;

	}catch(e){
		log.error("*** getCardsByUser: Falha ao buscar dataset.");
		log.error("*** getCardsByUser: ERRO: " + e.message);
	}
	
	return 0;
	
}

function gravaDocs(){
var calendar      = java.util.Calendar.getInstance().getTime();
var attachments   = hAPI.listAttachments();
var nParentFolder = Number(hAPI.getCardValue("sPastaCaso"));
var aDocsCur      = [];
var aDocs         = [];
var nLenaDoc      = 0;
var sDocsCur      = "";
var curDoc;
var doc;

log.info("*** gravaDocs - Iniciando gravação dos documentos");
	
	if (hAPI.getCardValue("sDocsCur") != null && hAPI.getCardValue("sDocsCur") != ""){
		sDocsCur = hAPI.getCardValue("sDocsCur");
		aDocsCur = sDocsCur.split(";");
	}
	
	for (var i = 0; i < attachments.size(); i++) {
		doc = attachments.get(i);

		if (doc.getDocumentType() != "7" && aScan(aDocsCur,doc.getDocumentId()) == true) {
			continue;
		}
		
		curDoc = doc.getDocumentId();
		doc.setParentDocumentId(nParentFolder);
		doc.setVersionDescription("Processo: " + getValue("WKNumProces"));
		doc.setExpires(false);
		doc.setCreateDate(calendar);
		doc.setInheritSecurity(true);
		doc.setTopicId(1);
		doc.setUserNotify(false);
		doc.setValidationStartDate(calendar);
		doc.setVersionOption("0");
		doc.setUpdateIsoProperties(true);

		try{
			hAPI.publishWorkflowAttachment(doc);
			aDocs.push(curDoc);        	
		}catch (e) {
			log.error("*** gravaDocs - Problemas na criação do documento: " + e.message);
		}
	}

	nLenaDoc = aDocs.length;
	if (nLenaDoc == null){
		nLenaDoc = 0;
	} 
		
	if (nLenaDoc > 0){
		//grava documentos
		if (sDocsCur != null && sDocsCur != ""){
			sDocsCur = sDocsCur + ";";
		}
		
		sDocsCur = sDocsCur + aDocs.join(";");
		
		hAPI.setCardValue("sDocsCur", sDocsCur);
		log.info("*** gravaDocs - Documentos anexados: " + sDocsCur);
	}
	
	log.info("*** gravaDocs - Finalizando gravação dos documentos");

}

function aScan(aX,cVal){
var index;
var nLenaX = 0;

	nLenaX = aX.length;
	if (nLenaX == null){
		nLenaX = 0;
	} 
		
	for	(index = 0; index < nLenaX; index++) {
		if (aX[index] == cVal){
			return true;
		}
	}
	
	return false;
}

function getCurrentDate(nDias){
	var dUtil = new Date();
	
	if (nDias === undefined){
		nDias = 0;
	}
	
	var Now = new Date();
	var dd  = Now.setDate(Now.getDate() + nDias);
	var yyyy = Now.getFullYear().toString();
	var mm = (Now.getMonth()+1).toString();		
	
	if (nDias > 0){
		while (Now.getDay() == 0 || Now.getDay() == 6 ){
			Now.setDate(Now.getDate() + 1);
		}
	}

	return Now.getDate() + "/" + (Now.getMonth()+1).toString() + "/" + Now.getFullYear().toString();

}

function incluiConsultivoSIGAJURI(){
	var constraints = new Array();
	var response = null;
	var sMailSolicitante = getMailByUserId(hAPI.getCardValue("cdSolicitante"));
	var sPastaCaso = "";
	
	constraints.push(DatasetFactory.createConstraint("cdAssJur", hAPI.getCardValue("cdAssJur"), hAPI.getCardValue("cdAssJur"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdWF", hAPI.getCardValue("numSolic"), hAPI.getCardValue("numSolic"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdFilialNS7", hAPI.getCardValue("cdFilialNS7"), hAPI.getCardValue("cdFilialNS7"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdEmpresa", hAPI.getCardValue("cdEmpresa"), hAPI.getCardValue("cdEmpresa"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdAreaSol", hAPI.getCardValue("cdAreaSol"), hAPI.getCardValue("cdAreaSol"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("dtPrazoTarefa", hAPI.getCardValue("dtPrazoTarefa"), hAPI.getCardValue("dtPrazoTarefa"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sSolicitante", hAPI.getCardValue("sSolicitante"), hAPI.getCardValue("sSolicitante"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sMailAdvogado", hAPI.getCardValue("sMailAdvogado"), hAPI.getCardValue("sMailAdvogado"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoSol", hAPI.getCardValue("cdTipoSol"), hAPI.getCardValue("cdTipoSol"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sDescSol", hAPI.getCardValue("sDescSol"), hAPI.getCardValue("sDescSol"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sObservacao", hAPI.getCardValue("sObservacao"), hAPI.getCardValue("sObservacao"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sMailSolicitante", sMailSolicitante, sMailSolicitante, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStepDestino", "8", "8", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStepDestinoFalha", "13", "13", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sCampoRetorno", "sResposta", "sResposta", ConstraintType.MUST));
		
	try{
		response = DatasetFactory.getDataset("dsInsConsultivoSIGAJURI", null, constraints, null);
	}catch(e){
		log.error("** incluiConsultivoSIGAJURI: Falha ao buscar dataset.");
		log.error("** incluiConsultivoSIGAJURI: ERRO: " + e.message);
	}
	
	if (response.getValue(0, "cdCajuri") != ""){
		
		sPastaCaso = response.getValue(0, "sPastaCaso");
		
		//Pega id da pasta do caso a partir do follow-up
		if (sPastaCaso == null || sPastaCaso == ""){
			sPastaCaso = getPastaDocs(response.getValue(0, "cdFollowup"));
		}
		
		hAPI.setCardValue("cdCajuri", response.getValue(0, "cdCajuri") );
		hAPI.setCardValue("sCodigoJuridico", response.getValue(0, "sCodigoJuridico") );
		hAPI.setCardValue("sAprovacao", response.getValue(0, "sAprovacao") );
		hAPI.setCardValue("sPastaCaso", sPastaCaso);
		
		return true;
		
	}else{
		log.error("** incluiConsultivoSIGAJURI: Retorno sem linhas ");
	}
	
	return false;
}

function getColleagueIdByMail(Email){
	var fields = new Array();
	var constraints = new Array();
	var sort = new Array();
	var colleagues = null;
	var colID = Email;
	
	fields.push("colleaguePK.colleagueId");
	
	constraints.push(DatasetFactory.createConstraint("active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("mail", Email, Email, ConstraintType.MUST));
	
	try{
		log.info("*** getColleagueIdByMail: Chamando Dataset.");
		colleagues = DatasetFactory.getDataset("colleague", fields, constraints, sort);
		
		log.info("*** getColleagueIdByMail: Processando UserName.");
		if (colleagues && colleagues.rowsCount > 0){
			colID = colleagues.getValue(0, "colleaguePK.colleagueId");
		}
	}catch(e){
		log.error("*** getColleagueIdByMail: Falha ao recuperar o dataset.");
		log.error("*** getColleagueIdByMail: ERROR: " + e.message);
	}
	
	return colID;
}

function getAdminCol(){
	// Recupera valores do dataset de parametros (Login e senha de Admin, Id do Form da Widget e Id da Empresa) para chamar o webservice.
	var dsParamsSIGAJURI = DatasetFactory.getDataset("dsParamsSIGAJURI", new Array(), new Array(), null);
	var sAdmin = dsParamsSIGAJURI.getValue(0, "sAdmin");
	
	var colid = getColleagueIdByMail(sAdmin);
	
	return colid;
}

function incluiFollowupSIGAJURI(){
	var constraints = new Array();
	var response = null;
	
	constraints.push(DatasetFactory.createConstraint("cdCajuri", hAPI.getCardValue("cdCajuri"), hAPI.getCardValue("cdCajuri"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdWF", hAPI.getCardValue("numSolic"), hAPI.getCardValue("numSolic"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("dtPrazoTarefa", hAPI.getCardValue("dtPrazoTarefa"), hAPI.getCardValue("dtPrazoTarefa"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoOrigem", "Consultivo", "Consultivo", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sDescricao", hAPI.getCardValue("sDescSol"), hAPI.getCardValue("sDescSol"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdCodOrigem", hAPI.getCardValue("cdTipoSol"), hAPI.getCardValue("cdTipoSol"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStepDestino", "8", "8", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStepDestinoFalha", "13", "13", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sCampoRetorno", "sResposta", "sResposta", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdFilialNS7", hAPI.getCardValue("cdFilialNS7"), hAPI.getCardValue("cdFilialNS7"), ConstraintType.MUST));
		
	try{
		response = DatasetFactory.getDataset("dsInsFollowupSIGAJURI", null, constraints, null);
	}catch(e){
		log.error("** dsInsFollowupSIGAJURI: Falha ao buscar dataset.");
		log.error("** dsInsFollowupSIGAJURI: ERRO: " + e.message);
	}
	
	if (response.getValue(0, "cdFollowup") != "0"){		
		log.error("** dsInsFollowupSIGAJURI: Incuido fw: " + response.getValue(0, "cdFollowup"));
		return true;
	}else{
		log.error("** dsInsFollowupSIGAJURI: Retorno sem linhas ");
	}
	
	return false;
}

function getPastaDocs(cdFollowup){	
	var cards = null;
	var sPastaCaso = "0";
	var fields = new Array("metadata#id","sPastaCaso");
	var constraints = new Array();
	
	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdFollowUp", cdFollowup, cdFollowup, ConstraintType.MUST));
	
	log.info("*** getPastaDocs - Follow-up: " + cdFollowup);
	
	try {	
		cards = DatasetFactory.getDataset("SIGAJURI_Followup", fields, constraints, null);
		
		if (cards.rowsCount == 1){
			sPastaCaso = cards.getValue(0, "sPastaCaso")
		}else{
			log.info("*** getPastaDocs - Não será retornada a pasta do caso, porque existe mais que 1 follow-up com este código no dataset SIGAJURI_Followup: " + cdFollowup);
		}
		
	}catch(e){
		log.error("*** getPastaDocs - Falha ao buscar dataset SIGAJURI_Follow-up: " + e.message);
	}
	
	return sPastaCaso;
}

function setDueDate(sData,colleagueId, sSegundos){
	var cSep = "-";
	var nDia = 2;
	var nMes = 1;
	var nAno = 0;
	var processo = getValue("WKNumProces");
	
	if (sData != null && sData.trim() != "" && sData != ""){
		
		//valida o separador entre / e -
	    if (sData.indexOf("/")>0){
    		cSep = "/";
    		nAno = 2;
    		nDia = 0;
    	}
	    
		var dateParts = sData.split(cSep);	    
		var dtPrazo = new Date(dateParts[nAno], (dateParts[nMes] - 1), dateParts[nDia]); //Javascript reconhece 0 como janeiro, 1 fevereiro ....
		
		hAPI.setDueDate(getValue("WKNumProces"), 0, colleagueId, dtPrazo, sSegundos);
	}
	
}

function lPad(n, width, z) {
	  z = z || '0';
	  n = n + '';
	  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

function updateConsultivo(cdFilialNS7, cdCajuri, sDescSol, sObservacao) {
	var constraints = new Array();
	var response = null;
	var sort = new Array("retorno");
	
	constraints.push(DatasetFactory.createConstraint("cdFilialNS7", cdFilialNS7, cdFilialNS7, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdCajuri", cdCajuri, cdCajuri, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sDescSol", sDescSol, sDescSol, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sObservacao", sObservacao, sObservacao, ConstraintType.MUST));

	
	try{
		response = DatasetFactory.getDataset("dsUpdateConsultivo", null, constraints, null);
	}catch(e){
		log.error("** dsUpdateConsultivo: Falha ao buscar dataset.");
		log.error("** dsUpdateConsultivo: ERRO: " + e.message);
	}
	
return
}
