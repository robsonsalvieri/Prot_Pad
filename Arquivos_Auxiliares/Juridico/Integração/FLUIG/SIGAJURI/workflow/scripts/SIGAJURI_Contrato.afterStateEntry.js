function afterStateEntry(sequenceId){
var INICIO           = 1;
var ABRIR            = 2;
var VALIDADOC        = 4;
var REVISADOC        = 21;
var GERARMINUTA      = 6;
var PREENCHEMINUT    = 8;
var VALIDAMINUTA     = 13;
var MINUTAFINAL      = 15;
var FINALIZACONTRATO = 17;
var CANCREVCONT      = 25;
var ENCASSINATURA    = 31;
var VALASSINATURA    = 36;
var REVASSINATURA    = 40;
var FIM              = 19;
var step             = parseInt(getValue("WKCurrentState"));
var users            = new java.util.ArrayList();
var nextState        = null;
var cUser            = "";
var numSolic         = getValue("WKNumProces");
var aPassosJur       = [ABRIR, VALIDADOC, MINUTAFINAL,PREENCHEMINUT];
var sStatusProc      = "1";
var codAnexoAssDigit = "";

	log.info("*** afterStateEntry Contrato: Iniciando. Atividade: " + step + "/Sequence Id: " + sequenceId);

	if (aPassosJur.indexOf(step) > -1){
		sStatusProc = "1";
	}else{
		sStatusProc = "2";
	}

	log.info("resul aPassosJur.indexOf(step):" + aPassosJur.indexOf(step) + ",sStatusProc:" + sStatusProc);

	hAPI.setCardValue("sStatusProc",sStatusProc); //1 - Pendente Jurídico, 2 - Solicitante, 3 - Cancelado, 4 - Concluído

	switch(step){
		case 0:
			break;

		case ABRIR:
			log.info("*** afterStateEntry Contrato: Inicio Abrir.");
			
			hAPI.setCardValue("numSolic", numSolic);
			//cria o assunto contrato no SIGAJURI
			if (incluiContratoSIGAJURI()){
				nextState = VALIDADOC;
				users.clear();

				if (hAPI.getCardValue("sAprovacao") == "true"){
					cUser = getAdminCol();
				}else{
					cUser = hAPI.getCardValue("cdAdvogado");
				}

				hAPI.setCardValue("sExecutorFluig",cUser);
				users.add(cUser);
				hAPI.setCardValue("cdResponsavel",hAPI.getCardValue("cdAdvogado"));
				hAPI.setCardValue("cdSolicitante", getColleagueIdByMail(hAPI.getCardValue("cdSolicitante")));

				//validar se alguma parte foi incluída.
				if (hAPI.getCardValue("sPassivo")==""){
					hAPI.setCardValue("sPassivo",hAPI.getCardValue("sRazaoSocial"));
					hAPI.setCardValue("optPassivo","optOutros");
				}else if (hAPI.getCardValue("sAtivo")==""){
					hAPI.setCardValue("sAtivo",hAPI.getCardValue("sRazaoSocial"));
					hAPI.setCardValue("optAtivo","optOutros");
				}

				hAPI.setAutomaticDecision(nextState, users, "Decisao Automatica: Encaminhado para Análise de documentos. Responsável: " + hAPI.getCardValue("sAdvogado") );
			}else{
				throw "Erro ao criar o assunto jurídico no SIGAJURI.";
			}

			log.info("*** afterStateEntry Contrato: Final Abrir.");
			break;

		case VALIDADOC:
			log.info("*** afterStateEntry Contrato: Inicio ValidaDoc.");

			//inclusão do follow-up no SIGAJURI se o fluxo de aprovações estiver ligado	
			if (hAPI.getCardValue("sAprovacao") == "true" && hAPI.getCardValue("sRevisaDoc") != "2"){
				var sPrazo = getPrazo();
				hAPI.setCardValue("dtPrazoTarefa",getCurrentDate(Number(sPrazo)));
				setDueDate(hAPI.getCardValue("dtPrazoTarefa"),hAPI.getCardValue("sExecutorFluig"))

				incluiFollowupSIGAJURI(getValue("WKUserComment"));

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

				hAPI.setCardValue("sRevisaDoc","2");
			} else if (hAPI.getCardValue("sRevisaDoc") != "2") {
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
			log.info("*** afterStateEntry Contrato: Final ValidaDoc.");
			break;

		case GERARMINUTA:
			log.info("*** afterStateEntry Contrato: Inicio GerarMinuta.");
			//valida se a minuta foi gerada automaticamente

			users.clear();

			if (geraMinutaAuto()){
				//se a minuta foi gerada, devemos avançar para o step de validação da minuta
				nextState = VALIDAMINUTA;
				users.add(hAPI.getCardValue("cdSolicitante"));
				hAPI.setAutomaticDecision(nextState, users, "Decisao Automatica: Foi gerada minuta automaticamente. Tarefa enviada ao solicitante para análise da minuta.");
				
			}else{
				//caso não exista padrão de minuta para gerar automaticament
				
				hAPI.setCardValue("sExecutorFluig",hAPI.getCardValue("cdResponsavel"));
				users.add(hAPI.getCardValue("cdResponsavel"));
				nextState = PREENCHEMINUT;
				hAPI.setAutomaticDecision(nextState, users, "Decisao Automatica: Nào existe minuta padrão do SIGAJURI. A minuta deverá ser preenchida manualmente." );
			}
			log.info("*** afterStateEntry Contrato: Final ValidaMinuta.");
			break;

		case REVISADOC:
			log.info("*** afterStateEntry Contrato: Inicio RevisaDoc.");

			hAPI.setCardValue("sRevisaDoc","1"); //seta que passou pela revisão de doc

			//valida se existe alguma observação que deva ser anexada a tarefa.
			if (hAPI.getCardValue("sAprovacao") == "true" && hAPI.getCardValue("sRevisaDoc") != "2"){
				if (hAPI.getCardValue("sObsFW") != ""){		
					hAPI.setTaskComments(hAPI.getCardValue("cdAdvogado"), numSolic,  0, hAPI.getCardValue("sObsFW"));
					hAPI.setCardValue("sObsFW","");
				}else{
					hAPI.setTaskComments(hAPI.getCardValue("cdAdvogado"), numSolic,  0, getValue("WKUserComment"));
				}
			}

			log.info("*** afterStateEntry Contrato: Final RevisaDoc.");
			break;

		case CANCREVCONT:
			log.info("*** afterStateEntry Contrato: Inicio CancRevCont.");
			//efetua o cancelamento do workflow
			hAPI.setCardValue("sStatusProc","3");	//3=Cancelado

			var obs = "";

			if (getValue("WKUserComment") == null || getValue("WKUserComment") == "") {
				obs = "tarefa cancelada via FLUIG na etapa de Revisão da documentação";
			}else{
				obs = getValue("WKUserComment");
			}

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

			lAtu = encerraAssJurSIGAJURI(hAPI.getCardValue("cdAssJur"), hAPI.getCardValue("cdCajuri"), "2", obs , getMailByUserId(colleagueId) );

			log.info("*** afterStateEntry Contrato: Final CancRevCont.");
			break;

		case MINUTAFINAL:
			log.info("*** afterStateEntry Contrato: Inicio MinutaFinal.");
			//Atualiza o prazo do advogado
			var sPrazo = getPrazo();
			hAPI.setCardValue("dtPrazoTarefa",getCurrentDate(Number(sPrazo)));
			setDueDate(hAPI.getCardValue("dtPrazoTarefa"),hAPI.getCardValue("sExecutorFluig"))
			
			log.info("*** afterStateEntry Contrato: Final MinutaFinal.");
			break;

		case ENCASSINATURA:
			log.info("*** afterStateEntry Contrato: Inicio EncaminhaAssinatura.");
			log.info("*** afterStateEntry Contrato: Final EncaminhaAssinatura.");
			break;

		case VALASSINATURA:
			log.info("*** afterStateEntry Contrato: Inicio ValidaAssinatura.");
			log.info("*** afterStateEntry Contrato: Final ValidaAssinatura.");
			break;

		case REVCASSINATURA:
			log.info("*** afterStateEntry Contrato: Inicio RevisaAssinatura.");
			log.info("*** afterStateEntry Contrato: Final RevisaAssinatura.");
			break;

		case FINALIZACONTRATO:
			log.info("*** afterStateEntry Contrato: Inicio FinalizaContrato.");
	
			log.info("*** afterStateEntry Contrato: Final FinalizaContrato.");
			break;

		case FIM:
			log.info("*** afterStateEntry Contrato: Inicio FIM.");
			hAPI.setCardValue("sStatusProc","4");
			log.info("*** afterStateEntry Contrato: Final FIM.");
			break;

		default:
			break;
	}
	
	//grava os documentos na pasta
	gravaDocs();
}



function getMailByUserId(cUser){
	log.info("*** getMailByUserId: Recuperando Mail.");
	log.info("*** afterStateEntry Contrato: Inicio getMailByUserId." + cUser);
	var fields = new Array();
	var constraints = new Array();
	var colleagues = null;
	var UserId = cUser;
	
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
	log.info("*** afterStateEntry Contrato: Final getMailByUserId. Retorno:" + UserId );
	return UserId;
}

function getCardsBySol(cdTipoCon){		
	var cards = null;
	
	var fields = new Array("metadata#id");
	var constraints = new Array();
	log.info("*** afterStateEntry Contrato: Inicio getCardsBySol." + cdTipoCon);
	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoCon", cdTipoCon, cdTipoCon, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStatusProc", "1", "1", ConstraintType.MUST));
	
	try {
		cards = DatasetFactory.getDataset("SIGAJURI_Contrato", fields, constraints, null);
		
		log.info("*** getCardsBySol:" + cards.rowsCount);
		log.info("*** afterStateEntry Contrato: Final getCardsBySol. Retorno: " + cards.rowsCount);
		return cards.rowsCount;
	}catch(e){
		log.error("*** getCardsBySol: Falha ao buscar dataset.");
		log.error("*** getCardsBySol: ERRO: " + e.message);
	}
	log.info("*** afterStateEntry Contrato: Final getCardsBySol.");
	return 0;
	
}

function getCardsByUser(cdTipoCon, cdUser){		
	var cards = null;
	log.info("*** afterStateEntry Contrato: Inicio getCardsByUser.");
	
	var fields = new Array("metadata#id");
	var constraints = new Array();
	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoCon", cdTipoCon, cdTipoCon, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sMailAdvogado", cdUser, cdUser, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStatusProc", "1", "1", ConstraintType.MUST));
	
	log.info("*** getCardsByUser: cdTipoCon:" + cdTipoCon + ", cdAdvogado:" + cdUser);
	
	try {
		cards = DatasetFactory.getDataset("SIGAJURI_Contrato", fields, constraints, null);
		
		log.info("*** getCardsByUser:" + cards.rowsCount);
		log.info("*** afterStateEntry Contrato: Final getCardsByUser. Retorno: " + cards.rowsCount);
		return cards.rowsCount;
	}catch(e){
		log.error("*** getCardsByUser: Falha ao buscar dataset.");
		log.error("*** getCardsByUser: ERRO: " + e.message);
	}
	log.info("*** afterStateEntry Contrato: Final getCardsByUser.");
	return 0;
	
}

function gravaDocs(){
	var calendar = java.util.Calendar.getInstance().getTime();
	var attachments = hAPI.listAttachments();
	var nParentFolder =  Number(hAPI.getCardValue("sPastaCaso"));
	var aDocsCur = [];
	var aDocs = [];
	var curDoc;
	var nLenaDoc = 0;
	var sDocsCur = "";
	
	log.info("*** gravaDocs - Iniciando gravação dos documentos");
	
	if (hAPI.getCardValue("sDocs") != null && hAPI.getCardValue("sDocs") != ""){
		sDocsCur = hAPI.getCardValue("sDocs");
		aDocsCur = sDocsCur.split(";");
	}
	
	for (var i = 0; i < attachments.size(); i++) {
        var doc = attachments.get(i);
         
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
        doc.setPublisherId(getAdminCol())
        doc.setColleagueId(getAdminCol())
         
        try{
        	hAPI.publishWorkflowAttachment(doc);
        	aDocs.push(curDoc);
        }catch (e) {
        	log.error("*** gravaDocs - Problemas na criação do documento: " + e.message);
        }
    }
    
	nLenaDoc =  aDocs.length;
	if (nLenaDoc == null){
		nLenaDoc = 0;
	} 
	
	if (nLenaDoc > 0){
    	//grava documentos
    	if (sDocsCur != null && sDocsCur != ""){
    		sDocsCur = sDocsCur + ";";
    	}
    	
    	sDocsCur = sDocsCur + aDocs.join(";");
    	
    	hAPI.setCardValue("sDocs", sDocsCur);
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
	
	Now = addWorkDays(Now,nDias);

	return Now.getDate() + "/" + (Now.getMonth()+1).toString() + "/" + Now.getFullYear().toString();
}

function incluiContratoSIGAJURI(){
	var constraints = new Array();
	var response = null;
	var sMailSolicitante = getMailByUserId(hAPI.getCardValue("cdSolicitante"));
	var sCnpj = hAPI.getCardValue("sCnpj"); //cpf sem pontuação
	var sPastaCaso = "";
	var sValor = hAPI.getCardValue("sValor");
	var aCustom = hAPI.getCardData(getValue("WKNumProces"));
	var keys = aCustom.keySet().toArray();
	var sException = "sValor,sCampoRetorno,sCnpj,sMailSolicitante,numSolic";
	
	log.info("*** afterStateEntry Contrato: Inicio incluiContratoSIGAJURI.");
	
	if (sCnpj != null){
		sCnpj = sCnpj.replace("/", "");
		sCnpj = sCnpj.replace("-", "");
		sCnpj = sCnpj.replace(".", "");
	}else{
		sCnpj = "";
	}
	
	if (sValor == null){
		sValor = '0';
	}
	
	constraints.push(DatasetFactory.createConstraint("sCnpj", sCnpj , sCnpj, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sCampoRetorno", "sObsFW", "sObsFW", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sValor", sValor, sValor, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sMailSolicitante", sMailSolicitante, sMailSolicitante, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdWF", hAPI.getCardValue("numSolic"), hAPI.getCardValue("numSolic"), ConstraintType.MUST));
	
	var count = 0;
	var valorField = "";
	
	for (var key in keys) {
		count++;
        var field = keys[key];

        if (sException.search(field) < 0){ //sValor
        	//valorField = hAPI.getCardValue(field);
        	valorField = aCustom.get(field);
        	if (valorField == null){
        		valorField = "";
        	}
        	constraints.push(DatasetFactory.createConstraint(field.toString(), hAPI.getCardValue(field), hAPI.getCardValue(field), ConstraintType.MUST));
        } 
    }
	
	try{
		response = DatasetFactory.getDataset("dsInsContratoSIGAJURI", null, constraints, null);
	}catch(e){
		log.error("** incluiContratoSIGAJURI: Falha ao buscar dataset.");
		log.error("** incluiContratoSIGAJURI: ERRO: " + e.message);
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
		
		log.info("*** afterStateEntry Contrato: Final incluiContratosSIGAJURI. Retorno: True");
		return true;
		
	}else{
		log.error("** incluiContratoSIGAJURI: Retorno sem linhas ");
	}
	
	log.info("*** afterStateEntry Contrato: Final incluiContratoSIGAJURI. Retorno: Falso");
	return false;
}

function getColleagueIdByMail(Email){
	var fields = new Array();
	var constraints = new Array();
	var sort = new Array();
	var colleagues = null;
	var colID = Email;
	log.info("*** afterStateEntry Contrato: Inicio getColleagueIdByMail. Parâmetro:" + Email);
	fields.push("colleaguePK.colleagueId");
	
	constraints.push(DatasetFactory.createConstraint("active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("mail", Email, Email, ConstraintType.MUST));
	
	try{
		colleagues = DatasetFactory.getDataset("colleague", fields, constraints, sort);
		
		if (colleagues && colleagues.rowsCount > 0){
			colID = colleagues.getValue(0, "colleaguePK.colleagueId");
		}
	}catch(e){
		log.error("*** getColleagueIdByMail: Falha ao recuperar o dataset.");
		log.error("*** getColleagueIdByMail: ERROR: " + e.message);
	}
	
	log.info("*** afterStateEntry Contrato: Final getColleagueIdByMail. Retorno " + colID);
	return colID;
}

function getAdminCol(){
	// Recupera valores do dataset de parametros (Login e senha de Admin, Id do Form da Widget e Id da Empresa) para chamar o webservice.
	var dsParamsSIGAJURI = DatasetFactory.getDataset("dsParamsSIGAJURI", new Array(), new Array(), null);
	var sAdmin = dsParamsSIGAJURI.getValue(0, "sAdmin");
	
	var colid = getColleagueIdByMail(sAdmin);
	
	return colid;
}

function geraMinutaAuto(){
	var constraints = new Array();
	var response = null;
	log.info("*** afterStateEntry Contrato: Inicio getMinutaAuto.");
	 
	constraints.push(DatasetFactory.createConstraint("cdCajuri"   , hAPI.getCardValue("cdCajuri")   , hAPI.getCardValue("cdCajuri")   , ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoCon"  , hAPI.getCardValue("cdTipoCon")  , hAPI.getCardValue("cdTipoCon")  , ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdFilialNS7", hAPI.getCardValue("cdFilialNS7"), hAPI.getCardValue("cdFilialNS7"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sTipoImpr"  , hAPI.getCardValue("sTipoImpr")  , hAPI.getCardValue("sTipoImpr")  , ConstraintType.MUST));
		
	try{
		response = DatasetFactory.getDataset("dsGeraMinutaSIGAJURI", null, constraints, null);
		
		if (response!=null){
			if (response.getValue(0, "id_peticao") != "0"){
				//anexa o documento que foi criado na pasta do caso pelo 
				hAPI.attachDocument(parseInt(response.getValue(0, "id_peticao")));
				log.info("*** afterStateEntry Contrato: Final getMinutaAuto. Retorno: True");
				return true;
				
			}else{
				log.error("** dsGeraMinutaSIGAJURI: Retorno sem linhas ");
			}
		}
	}catch(e){
		log.error("** dsGeraMinutaSIGAJURI: Falha ao buscar dataset.");
		log.error("** dsGeraMinutaSIGAJURI: ERRO: " + e.message);
	}
	log.info("*** afterStateEntry Contrato: Final getMinutaAuto. Retorno: False");
	return false;
}

function incluiFollowupSIGAJURI(sCompDesc){
	var constraints = new Array();
	var response = null;
	log.info("*** afterStateEntry Contrato: Inicio incluiFollowupSIGAJURI. Parâmetro:" + sCompDesc);
	if (sCompDesc == null){
		sCompDesc = "";
	}else{
		sCompDesc = sCompDesc.replaceAll("\\<.*?>","");
		sCompDesc = sCompDesc + '\n' + " --- " + '\n' + hAPI.getCardValue("sDescSol");
	}
	
	constraints.push(DatasetFactory.createConstraint("cdCajuri", hAPI.getCardValue("cdCajuri"), hAPI.getCardValue("cdCajuri"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdWF", hAPI.getCardValue("numSolic"), hAPI.getCardValue("numSolic"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("dtPrazoTarefa", hAPI.getCardValue("dtPrazoTarefa"), hAPI.getCardValue("dtPrazoTarefa"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoOrigem", "Contrato", "Contrato", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sDescricao", sCompDesc, sCompDesc, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdCodOrigem", hAPI.getCardValue("cdTipoCon"), hAPI.getCardValue("cdTipoCon"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStepDestino", hAPI.getCardValue("sStepDestinoConc"), hAPI.getCardValue("sStepDestinoConc"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sStepDestinoFalha", hAPI.getCardValue("sStepDestinoCanc"), hAPI.getCardValue("sStepDestinoCanc"), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sCampoRetorno", "sObsFW", "sObsFW", ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sSolicitante", getMailByUserId(hAPI.getCardValue("cdSolicitante")), getMailByUserId(hAPI.getCardValue("cdSolicitante")), ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdFilialNS7", hAPI.getCardValue("cdFilialNS7"), hAPI.getCardValue("cdFilialNS7"), ConstraintType.MUST));
		
	try{
		response = DatasetFactory.getDataset("dsInsFollowupSIGAJURI", null, constraints, null);
	}catch(e){
		log.error("** dsInsFollowupSIGAJURI: Falha ao buscar dataset.");
		log.error("** dsInsFollowupSIGAJURI: ERRO: " + e.message);
	}
	
	if (response.getValue(0, "cdFollowup") != "0"){		
		log.error("** dsInsFollowupSIGAJURI: Incluido fw: " + response.getValue(0, "cdFollowup"));
		log.info("*** afterStateEntry Contrato: Final incluiFollowupSIGAJURI. Retorno: True");
		return true;
	}else{
		log.error("** dsInsFollowupSIGAJURI: Retorno sem linhas ");
	}
	log.info("*** afterStateEntry Contrato: Final incluiFollowupSIGAJURI. Retorno: False");
	return false;
}

function getPrazo(){	
	var cdTipoCon = hAPI.getCardValue("cdTipoCon");
	var lRet = false;
	var sPrazo = 0;
	
	var fields = new Array("metadata#id", "sPrioridade","cdAssJur", "sPrazo", "cdUser", "cdTipoCon", "sUser");
	var constraints = new Array();
	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoCon", cdTipoCon, cdTipoCon, ConstraintType.MUST));
		
	try {
		configs = DatasetFactory.getDataset("wcmSIGAJURI_Contratos", fields, constraints, null);
		sPrazo = configs.getValue(0, "sPrazo");
		return sPrazo;
	}catch(e){
		log.error("*** ContratoResp: Falha ao buscar dataset.");
		log.error("*** ContratoResp: ERRO: " + e.message);
	}
	
	return 0;
}

function getPastaDocs(cdFollowup){	
	var cards = null;
	var sPastaCaso = "0";
	var fields = new Array("metadata#id","sPastaCaso");
	var constraints = new Array();
	
	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdFollowUp", cdFollowup, cdFollowup, ConstraintType.MUST));
	
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

function setDueDate(sData,colleagueId){
	var segundos = 50400;
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
		
		hAPI.setDueDate(processo, 0, colleagueId, dtPrazo, segundos);
	}
	
}

function addWorkDays(startDate, days) {
    if(isNaN(days)) {
        console.log("Value provided for \"days\" was not a number");
        return
    }

    if(!(startDate instanceof Date)) {
        console.log("Value provided for \"startDate\" was not a Date object");
        return
    }

    // Get the day of the week as a number (0 = Sunday, 1 = Monday, .... 6 = Saturday)
    var dow = startDate.getDay();
    var daysToAdd = parseInt(days);

    // If the current day is Sunday add one day
    if (dow == 0){
        daysToAdd++;
    }

    // If the start date plus the additional days falls on or after the closest Saturday calculate weekends

    if (dow + daysToAdd >= 6) {

        //Subtract days in current working week from work days

        var remainingWorkDays = daysToAdd - (5 - dow);

        //Add current working week's weekend

        daysToAdd += 2;

        if (remainingWorkDays > 5) {

            //Add two days for each working week by calculating how many weeks are included

            daysToAdd += 2 * Math.floor(remainingWorkDays / 5);

            //Exclude final weekend if remainingWorkDays resolves to an exact number of weeks
            if (remainingWorkDays % 5 == 0){
                daysToAdd -= 2;

        }
        }
    }

    startDate.setDate(startDate.getDate() + daysToAdd);

    return startDate;
}

function updateContrato() {
	var response = null;
	var sort = new Array("retorno");
	var constraints = new Array();
	var codWf = hAPI.getCardValue("numSolic")
	var cdCajuri = hAPI.getCardValue("cdCajuri")
	var cdFilialNS7 = hAPI.getCardValue("cdFilialNS7")
	var sDescSol = hAPI.getCardValue("sDescSol")
	var sObservacao = hAPI.getCardValue("sObservacao")
	var cdAtivo = hAPI.getCardValue("cdAtivo")
	var cdPassivo = hAPI.getCardValue("cdPassivo")
	var cdEntPassivo = hAPI.getCardValue("cdEntPassivo")
	var cdEntAtivo = hAPI.getCardValue("cdEntAtivo")
	var sRenovacao = hAPI.getCardValue("sRenovacao")
	var sValor = hAPI.getCardValue("sValor")
	var sVigenciaDe = hAPI.getCardValue("sVigenciaDe")
	var sVigenciaAte = hAPI.getCardValue("sVigenciaAte")
	var sCondPagamento = hAPI.getCardValue("sCondPagamento")
	var aCustom = hAPI.getCardData(getValue("WKNumProces"));
	var keys = aCustom.keySet().toArray();
	var sException = "numSolic,cdCajuri,cdFilialNS7,sDescSol,sObservacao,cdAtivo,cdPassivo,cdEntPassivo,";
		sException += "cdEntAtivo,sValor,sVigenciaAte,sVigenciaDe,sCondPagamento";

	constraints.push(DatasetFactory.createConstraint("cdWF"          , codWf, codWf, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdCajuri"      , cdCajuri, cdCajuri, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdFilialNS7"   , cdFilialNS7, cdFilialNS7, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sDescSol"      , sDescSol, sDescSol, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sObservacao"   , sObservacao, sObservacao, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdAtivo"       , cdAtivo, cdAtivo, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdPassivo"     , cdPassivo, cdPassivo, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdEntPassivo"  , cdEntPassivo, cdEntPassivo, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdEntAtivo"    , cdEntAtivo, cdEntAtivo, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sValor"        , sValor, sValor, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sVigenciaDe"   , sVigenciaDe, sVigenciaDe, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sVigenciaAte"  , sVigenciaAte, sVigenciaAte, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sCondPagamento", sCondPagamento, sCondPagamento, ConstraintType.MUST));

	var count = 0;
	var valorField = "";

	for (var key in keys) {
		count++;
		var field = keys[key];

		if (sException.search(field) < 0){
			valorField = aCustom.get(field);
			if (valorField == null){
				valorField = "";
			}
			constraints.push(DatasetFactory.createConstraint(field.toString(), hAPI.getCardValue(field), hAPI.getCardValue(field), ConstraintType.MUST));
		}
	}

	try{
		response = DatasetFactory.getDataset("dsUpdateContrato", null, constraints, null);
	}catch(e){
		log.error("** dsUpdateContrato: Falha ao buscar dataset.");
		log.error("** dsUpdateContrato: ERRO: " + e.message);
	}

	if (response){
		var retorno = response.getValue(0, "retorno");
		
		if (String(retorno) == "true"){
			return true;
		} else {
			log.error("*** dsUpdateContrato: ERRO: retorno falso do SIGAJURI ");
			return false;
		}
	}	else{
		log.error("** dsUpdateContrato: Response false ");
	}

	return false
}
