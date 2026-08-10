function beforeStateEntry(sequenceId){
var INICIO           = 1;
var ABRIR            = 2;
var VALIDADOC        = 4;
var GERARMINUTA      = 6;
var PREENCHEMINUT    = 8;
var VALIDAMINUTA     = 13;
var MINUTAFINAL      = 15;
var FINALIZACONTRATO = 17;
var REVISADOC        = 21;
var CANCREVCONT      = 25;
var ENCASSINATURA    = 31;
var VALASSINATURA    = 36;
var REVASSINATURA    = 40;
var CANCASSINATURA   = 45;
var step             = parseInt(getValue("WKCurrentState"));
var cErrorMessage    = "";
var cdDocAsign       = hAPI.getCardValue("cdDocAsign");
var constraints      = new Array();
var fields           = new Array();

	log.info("*** beforeStateEntry Contrato: Inicio.");
	try{
		switch(step){
			case ABRIR:
				log.info("*** beforeStateEntry Contrato: Inicio Abrir.");

				hAPI.setCardValue("sStepDestinoConc","6");
				hAPI.setCardValue("sStepDestinoCanc","21");
				hAPI.setCardValue("sRevisaDoc","2");
				
				log.info("*** beforeStateEntry Contrato: Configura o Responsavel pela tarefa.");
				if (setInfoConfig()){
					log.info("*** ContratoResp: Advogado:" + hAPI.getCardValue("sAdvogado"));
					log.info("*** ContratoResp: Data Prazo:" + hAPI.getCardValue("dtPrazoTarefa"));
				}else{
					log.error("*** beforeStateEntry Contrato: Não foi possível determinar o responsável pelo contrato");
					cErrorMessage = "Não foi possível determinar o responsável pelo contrato";
					throw cErrorMessage
				}
				break;
			case ENCASSINATURA:
				var dsAssinadores = null;
				log.info("*** beforeStateEntry Contrato: Inicio Encaminha Assinatura!");

				hAPI.setCardValue("docAsign","");
				hAPI.setCardValue("sAssLista","");
				hAPI.setCardValue("sAssHiddenList", "");
				
				fields = new Array('email');
				
				dsAssinadores = verificaAssinadores(constraints, fields);

				if (dsAssinadores == null){
					cErrorMessage = "Integração com a VertSign não detectada no fluig. Favor fazer a instalação para habilitar este recurso!"
					throw cErrorMessage
				} else {
					if (dsAssinadores.rowsCount > 0){
						log.info("*** beforeStateEntry Contrato: Assinadores validados!");
					}else{
						cErrorMessage = "Não há assinadores cadastrados! Favor verificar!";
						throw cErrorMessage
					}
				}
				
				gravaDocs();
				if (!verificaAnexos() ){
					cErrorMessage = "Não há anexos em .pdf, .doc ou .docx na pasta do caso! Favor verificar!";
					throw cErrorMessage
				} else {
					log.info("*** beforeStateEntry Contrato: Anexos validados!");
				}
				
				log.info("*** beforeStateEntry Contrato: Fim Encaminha Assinatura!");
				break;	
			case VALASSINATURA:
				var sHiddenList = hAPI.getCardValue("sAssHiddenList");
				
				log.info("*** beforeStateEntry Contrato: Inicio Valida Assinatura! cdDocAsign:" + cdDocAsign + " | sHiddenList: " + sHiddenList);
				
				if (((sHiddenList == "") || (cdDocAsign == ""))){
					cErrorMessage = "Não há assinadores ou documento selecionado!";
					throw cErrorMessage
				}
				
				enviaDoctVertSign(cdDocAsign, sHiddenList)
				log.info("*** beforeStateEntry Contrato: Fim Valida Assinatura!");
				break;
			case REVASSINATURA:
				log.info("*** beforeStateEntry Contrato: Inicio Revisa Assinatura!");
				log.info("*** beforeStateEntry Contrato: Fim Revisa Assinatura!");
				break;
			case CANCASSINATURA: 
				log.info("*** beforeStateEntry Contrato: Inicio Cancelamento Solicitação Assinatura!");
				deleteDoctoVertsign(cdDocAsign);
				log.info("*** beforeStateEntry Contrato: Fim Cancelamento Solicitação Assinatura!");
				break;
			default:
				break;
		}
	}catch(e){
		log.info("*** beforeStateEntry Contrato: Erro.");
		var errorClass = null;
		if (cErrorMessage == ""){
			cErrorMessage = e.message;
			errorClass = e;
		} else {
			errorClass = cErrorMessage;
		}
		switch(step){
			case ABRIR:
				log.error("*** beforeStateEntry Contrato: Abrir. Erro " + cErrorMessage)
				throw errorClass;
				break;
			case ENCASSINATURA:
				log.error("*** beforeStateEntry Contrato: Encaminha Assinatura. Erro " + cErrorMessage)
				throw errorClass;
				break;
			case VALASSINATURA:
				log.error("*** beforeStateEntry Contrato: Valida Assinatura. Erro " + cErrorMessage)
				throw errorClass;
			default:
				break;
		}
	}
	log.info("*** beforeStateEntry Contrato: Fim.");
}

function setInfoConfig(){	
var cdTipoCon      = hAPI.getCardValue("cdTipoCon");
var configs        = null;
var nPerc          = 0; //porcentagem de atribuição do usuário
var cdUser         = 0;
var sUser          = 0;
var lRet           = false;
var sPrazo         = 0;
var nMenor         = 9999;
var nMenorAux      = 9999;
var idMenor        = -1;
var idMenorAux     = -1;
var qtdSol         = -1;
var qtdUser        = 0;
var fields         = new Array("metadata#id", "sPrioridade","cdAssJur", "sPrazo", "cdUser", "sUser", "cdTipoCon", "cdGrupo", "sGrupo");
var constraints    = new Array();
var order          = new Array("sPrioridade");
var lGrupo         = false;
var cdResponsavel;
var sResponsavel;
var cdAssJur;

	constraints.push(DatasetFactory.createConstraint("metadata#active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("cdTipoCon", cdTipoCon, cdTipoCon, ConstraintType.MUST));
	
	try {
		configs = DatasetFactory.getDataset("wcmSIGAJURI_Contratos", fields, constraints, order);
	}catch(e){
		log.error("*** beforeStateEntry ContratoResp: Falha ao buscar dataset.");
		log.error("*** beforeStateEntry ContratoResp: ERRO: " + e.message);
	}

	if (!configs || configs.rowsCount <= 0){
		log.info("*** beforeStateEntry ContratoResp: Nenhuma configuração. encontrada. Não irá para o FLUIG.");
		throw "Nenhuma configuração encontrada. Solicitação não poderá ser registrada no FLUIG.";
		return false;
	}

	log.info("*** ContratoResp: Processando dados encontrados: " + configs.rowsCount);

	for (var i = 0; i < configs.rowsCount; i++){
		log.info("*** beforeStateEntry ContratoResp: Avaliando " + configs.getValue(i, "cdTipoCon"));

		//definição da prioridade
		if (configs.rowsCount==1){
			nPerc = 10;
		}else{
			nPerc = Number(configs.getValue(i, "sPrioridade"));
		}

		//se o campo está igual a 10, deve receber todas as solicitações.
		if (nPerc == 10){
			idMenor = i;   
			lRet = true;
			break; //sai do loop 
		}else{
			//pega a quantidade de solicitações ativas para determinado tipo de solicitação
			if (qtdSol==-1){
				qtdSol = getCardsBySol(configs.getValue(i, "cdTipoCon"));
			}

			cdResponsavel = configs.getValue(i,"cdUser");
			sResponsavel  = configs.getValue(i,"sUser");

			if ((cdResponsavel == null) || (cdResponsavel == '')){
				cdResponsavel =  configs.getValue(i,"cdGrupo");
				sResponsavel = configs.getValue(i,"sGrupo");
			}

			qtdUser = getCardsByUser(configs.getValue(i, "cdTipoCon"),cdResponsavel);

			log.info("*** beforeStateEntry ContratoResp: qtdSol " + qtdSol);
			log.info("*** beforeStateEntry ContratoResp: qtdUser " + qtdUser);
			log.info("*** beforeStateEntry ContratoResp: valida menor (qtdUser < nMenorAux):(" + qtdUser + " < " + nMenorAux);

			//preenche o menor, independete se for elegível ou não.
			if (qtdUser < nMenorAux){
				nMenorAux = qtdUser;
				idMenorAux = i;
			}

			log.info("*** beforeStateEntry ContratoResp idMenorAux:" + idMenorAux);
			log.info("*** beforeStateEntry ContratoResp: (((qtdSol/10)*nPerc) ) = " +((qtdSol/10)*nPerc));
			
			//valida se o usuário deve receber a tarefa atual, baseado no campo prioridade

			if ((qtdUser < ((qtdSol/10)*nPerc)) || qtdUser == 0 || ((qtdSol/10)*nPerc) < 1 ){

				if (qtdUser < nMenor){
					nMenor = qtdUser;
					idMenor = i;
				}
				
				lRet = true;
			}
		}
	}
	
	log.info("*** beforeStateEntry Contrato: Fim laço: lRet =" + lRet + ", idMenorAux=" + idMenorAux);

	if ((lRet==false) && (idMenorAux > -1)){
		lRet = true;
		idMenor = idMenorAux;
		nMenor = nMenorAux;
	}

	//Usuário válido como executor

	if (lRet){
		log.info("*** beforeStateEntry ContratoResp: menor = " + idMenor + ", qtd:" + nMenor );        
		
		cdResponsavel = configs.getValue(idMenor, "cdUser");
		sResponsavel = configs.getValue(idMenor, "sUser");
		
		if ((cdResponsavel == null) || (cdResponsavel == '')){
			sResponsavel  = configs.getValue(idMenor,"sGrupo");
			cdResponsavel = configs.getValue(idMenor,"cdGrupo");
			lGrupo        = true;
		}
		
		log.info("*** beforeStateEntry ContratoResp: cdResponsavel = " + cdResponsavel + ", sResponsavel:" + sResponsavel + ", lGrupo:" + lGrupo);
		
		sPrazo = configs.getValue(idMenor, "sPrazo");
		cdAssJur = configs.getValue(idMenor, "cdAssJur");
		
		if (!lGrupo){
			hAPI.setCardValue("cdAdvogado",getColleagueIdByMail(cdResponsavel));
			hAPI.setCardValue("sMailAdvogado",getMailByUserId(cdResponsavel));
		} else {
			hAPI.setCardValue("cdAdvogado","Pool:Group:" + cdResponsavel);
			hAPI.setCardValue("sMailAdvogado",cdResponsavel);
		}

		hAPI.setCardValue("sAdvogado",sResponsavel);
		hAPI.setCardValue("cdAssJur",cdAssJur);
		
		hAPI.setCardValue("dtPrazoTarefa", getCurrentDate(Number(sPrazo)));
	}

	return lRet;
	
}

function verificaAnexos(){
	var pastaCaso   = hAPI.getCardValue("sPastaCaso");

	return getQtdFilesByExt(pastaCaso, '.pdf;.doc;.docx');
}

function getQtdFilesByExt(pastaCaso, extension){
	var constraints = new Array();
	var configs     = null;

	constraints.push(DatasetFactory.createConstraint("PastaCaso", pastaCaso, pastaCaso, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("FiltExtensao", extension, extension, ConstraintType.MUST));
	
	configs = DatasetFactory.getDataset("dsAnexos", null, constraints, null);
	
	return (configs.rowsCount > 0);
}

function verificaAssinadores(constraints, fields){
	var dsAssinadores = null;
	
	try {
		dsAssinadores = DatasetFactory.getDataset("ds_vertsign_assinantes", fields, constraints, null);
		
	}catch(e){
		log.error("*** getAssinadores: " + e.message);
	}
	return dsAssinadores;
}

function findDoctoById(codAnexo){
	var dsDocto = null;
	var constraints = new Array();
	var fields = new Array("documentPK.documentId","documentPK.version","parentDocumentId","documentDescription");
	var cErrorMessage = ""
		
	constraints.push(DatasetFactory.createConstraint("documentPK.documentId", codAnexo, codAnexo, ConstraintType.MUST));
	
	try {	
		dsDocto = DatasetFactory.getDataset("document", fields, constraints, null);
		
		if (dsDocto.rowsCount == 0){
			cErrorMessage = "Não foi possivel encontrar o documento selecionado"
			throw cErrorMessage
		} else {
			lastVersion = dsDocto.rowsCount - 1;
		}
	
	}catch(e){
		log.error("*** beforeStateEntry Contrato: enviaDoctoVertSign [" + cErrorMessage + "]");
		throw cErrorMessage
	}
	
	return [dsDocto, lastVersion]
}

function enviaDoctVertSign(codAnexo, sHiddenList) {
	var doc = null;
	var dsDocto = null;
	var dsAssinadores = null;
	var arraySigners = new Array();
	var constraints = new Array();
	var arrayEmails = new Array();
	var fields = new Array("nome", "email", "cpf", "tipoAssinatura")
	var horaEnv = getCurrentHour();
	var dataEnv = getCurrentDate();
	var newDocto = false;
	var lastVersion = -1;
	var i = 0;
	
	log.info("*** beforeStateEntry Contrato: Enviando documento para VertSign. CodAnexo[" + codAnexo + "] | sHiddenList [" + sHiddenList + "]");

	dsDocto = findDoctoById(codAnexo);
	
	doc = dsDocto[0];
	lastVersion = dsDocto[1];
	
	arrayEmails = sHiddenList.split(";");
	dsAssinadores = verificaAssinadores(constraints, fields);
	
	if (dsAssinadores.rowsCount == 0 ) {
		log.info("*** beforeStateEntry Contrato: Não há assinadores no cadastro de assinador da VertSign!");
		throw "Não há assinadores no cadastro de assinador da VertSign!";
	}
	
	var indexAssinador = -1;
    for (i = 0; i < arrayEmails.length; i++){
        indexAssinador = findIndex(dsAssinadores, arrayEmails[i], "email", true);
        if ( indexAssinador > -1 ) {
            var emailDecrip = hex2a(dsAssinadores.getValue(indexAssinador,"email"))
            
            arraySigners.push(
                {
                    nome: String(dsAssinadores.getValue(indexAssinador,"nome")),
                    email: String(emailDecrip),
                    cpf: String(hex2a(dsAssinadores.getValue(indexAssinador,"cpf"))),
                    tipo: String(dsAssinadores.getValue(indexAssinador,"tipoAssinatura")),
                    status: "Pendente"
                }
            )
        }
    }
	
	if (arraySigners.length > 0) {
		if (lastVersion >= 0) {
			// Verifica se o Documento existe no DataSet da Vertsign para evitar duplicata
			newDocto = existDoctoDSVertsign(doc.getValue(lastVersion, 'documentPK.documentId'),doc.getValue(lastVersion, 'parentDocumentId'))
			var c1 = DatasetFactory.createConstraint("codArquivo", doc.getValue(lastVersion, 'documentPK.documentId'), doc.getValue(lastVersion, 'documentPK.documentId'), ConstraintType.MUST);
			
			if (newDocto){
				var mailRemetente = getMailByUserId(hAPI.getCardValue("cdResponsavel"));
				var nomeRemetente = getUsrNameByMail(mailRemetente) + " - " + mailRemetente;
				
				// Cria registro de formulario
				constraints.push(DatasetFactory.createConstraint("nmArquivo", doc.getValue(lastVersion,'documentDescription'), doc.getValue(lastVersion,'documentDescription'), ConstraintType.MUST));
				constraints.push(c1);
				constraints.push(DatasetFactory.createConstraint("vrArquivo", doc.getValue(lastVersion, 'documentPK.version'), doc.getValue(lastVersion, 'documentPK.version'), ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("codPasta", doc.getValue(lastVersion, 'parentDocumentId'), doc.getValue(lastVersion, 'parentDocumentId'), ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("codRemetente", getValue("WKUser"), getValue("WKUser"), ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("emailAssinantes", mailRemetente, mailRemetente, ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("formDescription", doc.getValue(lastVersion, 'documentDescription'), doc.getValue(lastVersion, 'documentDescription'), ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("status", "Enviando para assinatura", "Enviando para assinatura", ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("metodo", "create", "create", ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("dataEnvio", dataEnv, dataEnv, ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("horaEnvio", horaEnv, horaEnv, ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("nmRemetente", nomeRemetente, nomeRemetente, ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("jsonSigners", JSON.stringify(arraySigners), JSON.stringify(arraySigners), ConstraintType.MUST));
				constraints.push(DatasetFactory.createConstraint("numSolic", getValue("WKNumProces"), getValue("WKNumProces"), ConstraintType.MUST));
				
				var dsAux = DatasetFactory.getDataset("ds_auxiliar_vertsign", null, constraints, null);
				
				if (dsAux.rowsCount > 0 && dsAux.getValue(0,"Result") == "OK"){
					log.info("*** beforeStateEntry Contrato: Enviando documento para assinatura pelo VertSign");
					forceUploadVertsign(c1);
				}
			}
			// Chama o DataSet de upload manual para sincronizar com a Vertsign
			// DatasetFactory.getDataset("ds_upload_vertsign_manual", null, null, null);
		} else {
			throw "É preciso anexar o documento para continuar o processo!";
		}
	} else {
		log.info("*** beforeStateEntry Contrato: Não foi encontrado no cadastro de assinador os assinantes: " + hAPI.getCardValue("sAssLista"));
		throw "Não foi encontrado no cadastro de assinantes da vertSign, os e-mails: " + hAPI.getCardValue("sAssLista");
	}
}

/*
 * Função para forçar o upload do documento para a Vertsign
 */
function forceUploadVertsign(constraintArquivo){
	var constraints = new Array();
	constraints.push(constraintArquivo);
	
	return DatasetFactory.getDataset("ds_upload_vertsign_manual", null, constraints, null);
}

function deleteDoctoVertsign(codAnexo){
var dsFormAux = null;
var dsDelete = null;
var constraintsFormAux = new Array();
var constraintsDelete = new Array();
var fieldsFormAux = new Array("codArquivo","idCreate")
var fieldsDelete = new Array();
	log.info("*** beforeStateEntry Contrato: Iniciando a exclusão do Docto na Vertsign. Anexo:" + codAnexo);

	// Busca a chave do Arquivo no ds_form_aux_vertsign
	constraintsFormAux.push(DatasetFactory.createConstraint("codArquivo", codAnexo, codAnexo, ConstraintType.MUST));
	dsFormAux = DatasetFactory.getDataset("ds_form_aux_vertsign", fieldsFormAux, constraintsFormAux, null);
	log.info("*** beforeStateEntry Contrato: Executado dataset dsFormAux. [deleteDocto]" + dsFormAux.getValue(0,"idCreate"));
	
	// Cria a constraint com o Id de Criação 
    constraintsDelete.push(DatasetFactory.createConstraint("idCreate", dsFormAux.getValue(0,"idCreate"), dsFormAux.getValue(0,"idCreate"), ConstraintType.MUST));
    
    log.info("*** beforeStateEntry Contrato: Executa o Delete");

    // Executa o dataset de exclusão da Vertsign
    try{
    	dsDelete = DatasetFactory.getDataset("ds_delete_vertsign", null, constraintsDelete, null);
    } catch (e) {
    	log.info("*** beforeStateEntry Contrato: Erro no Dataset de Exclusão:" + e.message)
    }
    
    log.info("*** beforeStateEntry Contrato: Executado dataset dsDelete. [deleteDocto]. Length:" + dsDelete.values.length);
    
    // Verificação de sucesso
    if (dsDelete.rowsCount > 0){
    	if (dsDelete.getValue(0,"Result") == "OK"){
   			deleteRegistroVertsign(dsFormAux.getValue(0,"idCreate"));
   			log.info("*** beforeStateEntry Contrato: Documento excluido VertSign!");
    	}
    }
}

function deleteRegistroVertsign(idCreate){
var constraints = new Array();
var codRegistro = retornaRegistro(idCreate)
	
	constraints.push(DatasetFactory.createConstraint("idRegistro", codRegistro, codRegistro, ConstraintType.MUST))
	constraints.push(DatasetFactory.createConstraint("status", "Cancelado", "Cancelado", ConstraintType.MUST))
	constraints.push(DatasetFactory.createConstraint("metodo", "update", "update", ConstraintType.MUST))
	
	var c1 = DatasetFactory.createConstraint("idCreate", idCreate, idCreate, ConstraintType.MUST);

	try {
		var dsFormAux = DatasetFactory.getDataset("ds_form_aux_vertsign", null, [c1], null);
		if (dsFormAux.rowsCount > 0) {
	        var codDocOrigem = dsFormAux.getValue(0,"codArquivo");
	        var verDocOrigem = dsFormAux.getValue(0,"vrArquivo");
	        
	        var dsAux = DatasetFactory.getDataset("ds_auxiliar_vertsign", null, constraints, null);
	        
	        if (dsAux.rowsCount > 0){
	        	log.info("*** beforeStateEntry Contrato: Registro excluido! DsAuxiliarVertsign.");
	        } else {
	        	log.error("*** beforeStateEntry Contrato: Não foi possivel realizar a exclusão");
	        }
		}	
	} catch (e) {
		log.error("*** beforeStateEntry Contrato: " + e.message)
	}
	
}

function retornaRegistro(id) {
    var c1 = DatasetFactory.createConstraint("idCreate", id, id, ConstraintType.MUST);
    var constraints = [c1];
    var dataset = DatasetFactory.getDataset("ds_documents_vertsign", null, constraints, null);

    if (dataset.rowsCount > 0) {
        var idRegistro = dataset.getValue(0,"idRegistro");
        return idRegistro;
    }
}

function existDoctoDSVertsign(doctoId , parentId){
	var constraints = new Array()
	constraints.push(DatasetFactory.createConstraint("codArquivo", doctoId, doctoId, ConstraintType.MUST))
	constraints.push(DatasetFactory.createConstraint("codPasta", parentId, parentId, ConstraintType.MUST))
	var dataset = DatasetFactory.getDataset("ds_form_aux_vertsign", null, constraints, null);
	
	
	return (dataset.rowsCount == 0);
}

function findIndex(aX, cVal, cEntity, lDecript){
	var index;
	var nLenaX = -1;

	nLenaX = aX.rowsCount;
	if (nLenaX == null){
		nLenaX = 0;
	}

	for (index = 0; index < nLenaX; index++) {
		if (lDecript){
			var decript = hex2a(aX.getValue(index,cEntity))
			if (decript == cVal){
				return index;
			}
		} else {
			if (aX.getValue(index,cEntity) == cVal){
				return index;
			}
		}
	}

	return -1;
}

function getCurrentHour(){
	var dataAtual = new Date();
	dataAtual.setHours(dataAtual.getHours() - 1);

	var hour = dataAtual.getHours().toString();
	var minutes = dataAtual.getMinutes().toString();
	var seconds  = dataAtual.getSeconds().toString();

	return (hour[1] ? hour : "0" + hour[0]) + ":" +
		   (minutes[1] ? minutes : "0" + minutes[0]) + ":" +
		   (seconds[1] ? seconds : "0" + seconds[0]);
}

function getUsrNameByMail(Email){
	log.info("*** getUsrNameByMail: Recuperando UserName.");
	var fields = new Array();
	var constraints = new Array();
	var sort = new Array();
	var colleagues = null;
	var userName = Email;

	fields.push("colleagueName");
	
	constraints.push(DatasetFactory.createConstraint("active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("mail", Email, Email, ConstraintType.MUST));

	try {
		colleagues = DatasetFactory.getDataset("colleague", fields, constraints, sort);

		if (colleagues && colleagues.rowsCount > 0){
			userName = colleagues.getValue(0, "colleagueName");
		}
	} catch(e) {
		log.error("*** getUsrNameByMail: Falha ao recuperar o dataset.");
		log.error("*** getUsrNameByMail: ERROR: " + e.message);
	}

	return userName;
}


function hex2a(r) {
    for (var t = String(r), n = "", e = 0; e < t.length && "00" !== t.substr(e, 2); e += 2) n += String.fromCharCode(parseInt(t.substr(e, 2), 16));
    return n;
}
function a2hex(r) {
    for (var t = [], n = 0, e = (r = String(r)).length; n < e; n++) {
        var o = Number(r.charCodeAt(n)).toString(16);
        t.push(o);
    }
    return t.join("");
}