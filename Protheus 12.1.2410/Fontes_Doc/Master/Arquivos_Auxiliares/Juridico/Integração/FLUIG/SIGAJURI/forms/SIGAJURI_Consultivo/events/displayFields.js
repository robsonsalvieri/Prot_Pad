function displayFields(form,customHTML){
	var mode = form.getFormMode();
		
	if(mode == "ADD"){
		form.setEnabled("sResposta",false);
		loadConfigUser(form, getValue("WKUser"));
		loadCurrentDate(form);
		form.setValue("numSolic",getValue("WKNumProces"));
	}
	
	lockFields(form, mode);
}

function loadConfigUser(form, user){
	//Setar nome de usuário
	var c1 = DatasetFactory.createConstraint("colleaguePK.colleagueId",user,user,ConstraintType.MUST);
	 
	var fields = new Array("colleagueName", "mail");
	var constraints = new Array(c1);
	var dataset = DatasetFactory.getDataset("colleague",fields,constraints,null);
	var userName = "";
	var userEmail = "";
	
	if(dataset.rowsCount == 1){
		userName = dataset.getValue(0, "colleagueName");
//		userEmail = dataset.getValue(0, "mail");
	}
	
	form.setValue("sSolicitante",userName);
	form.setValue("cdSolicitante",user);
	
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
			form.setVisible("cdTipoSol", false);
			form.setVisible("cdFilialNS7", false);
		}
	}else if (mode=="ADD"){
		form.setVisible("sAreaSol", false);
		form.setVisible("sTipoSol", false);
		form.setVisible("sFilialNS7", false);
	}
}