function displayFields(form,customHTML){
	var mode = form.getFormMode();
	
	if(mode == "ADD"){
		var col = getUserByUserId(getValue("WKUser"));
		if (col!=null){
			form.setValue("sSolicitante",col.getValue(0, "colleagueName"));
			form.setValue("cdSolicitante",getValue("WKUser"));	
		}
		
		loadCurrentDate(form);
	}else if (mode=="MOD"){ //detecta transferências de responsáveis para atualizar o campo em próximas etapas
		if (form.getValue("cdResponsavel")!=getValue("WKUser") && form.getValue("sStatusProc")=="1" && form.getValue("cdResponsavel").indexOf("Pool:Group:") == -1){
			var col = getUserByUserId(getValue("WKUser"));
			if (col!=null){			
				form.setValue("cdResponsavel",getValue("WKUser"));
				form.setValue("sExecutorFluig",getValue("WKUser"));
				form.setValue("sMailAdvogado",col.getValue(0, "mail"));
				form.setValue("cdAdvogado",getValue("WKUser"));
				form.setValue("sAdvogado",col.getValue(0, "colleagueName"));
			}
		}else if (form.getValue("cdResponsavel")!=getValue("WKUser") && form.getValue("sStatusProc")=="2"){
			var col = getUserByUserId(getValue("WKUser"));
			if (col!=null){
				form.setValue("cdSolicitante",getValue("WKUser"));
				form.setValue("sSolicitante",col.getValue(0, "colleagueName"));
			}
		}
	}
	form.setValue("sStatusAtiv",getValue("WKNumState"));
	lockFields(form, mode);
}

function loadCurrentDate(form){
	//Setar data Atual
	var dataTemp = new Date();		
	var day = dataTemp.getDate().toString();
	var mes = (dataTemp.getMonth()+1).toString();		
	if(day.length == 1)
		day = 0+day;	
	if(mes.length == 1)
		mes = 0+mes;	
	var dataAtual = day+"/"+mes+"/"+dataTemp.getFullYear();
	form.setValue("dtSolicitacao",dataAtual);	
}

function lockFields(form, mode){	
	log.info("mode:" + mode);
	if (mode=="MOD"){
		//desabilita os campos da tela quando o cajuri está preenchido.
		if (form.getValue("cdCajuri") != ""){			
			form.setVisible("cdAreaSol", false);
			form.setVisible("cdTipoCon", false);
			form.setVisible("cdFilialNS7", false);
		}
	}else if (mode=="ADD"){
		form.setVisible("sAreaSol", false);
		form.setVisible("sTipoCon", false);
		form.setVisible("sFilialNS7", false);
	}
}

function getUserByUserId(cUser){
	var fields = new Array();
	var constraints = new Array();
	var colleagues = null;
	
	fields.push("mail");
	fields.push("colleagueName");
	
	constraints.push(DatasetFactory.createConstraint("active", true, true, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("colleaguePK.colleagueId", cUser, cUser, ConstraintType.MUST));
	
	try{
		colleagues = DatasetFactory.getDataset("colleague", fields, constraints, null);
		
		if (colleagues && colleagues.rowsCount > 0){
			return colleagues;
		}
	}catch(e){
		log.error("*** getMailByUserId: Falha ao recuperar o dataset.");
		log.error("*** getMailByUserId: ERROR: " + e.message);
		return null;
	}
	return null;
}