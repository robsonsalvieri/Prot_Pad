function enableFields(form){
	var INICIO = 1;
	var ABRIR = 2;
	var AGUARDANDORESP = 6;
	var RESPENVIADA = 8;
	var REVISAR = 13;
	var FIM = 10;
	
	var step = parseInt(getValue("WKNumState"));
	var fields = new Array();
	
	log.info("step: " + step);
	
	switch(step){
	case 0:
		break;
	case AGUARDANDORESP:
		fields.push("sResposta");
		break;
	case RESPENVIADA:
		disableAllFields(form);
		break;
	case REVISAR:
		fields.push("sDescSol");
		fields.push("sObservacao");
		break;
	default:
		break;
	}
	
	if (fields.length > 0){
		disableAllFields(form);
		enableSelectedFields(form, fields);
	}
	
}

function disableAllFields(form) {
	var fields = form.getCardData();
	var iterator = fields.keySet().iterator();
	while (iterator.hasNext()) {
		var curField = iterator.next();
		form.setEnabled(curField, false);
	}
}

function enableSelectedFields(form, fields) {
	for (var i = 0; i < fields.length; i++) {
		form.setEnabled(fields[i], true);
	}
}