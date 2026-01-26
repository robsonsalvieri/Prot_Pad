function enableFields(form){
	var INICIO = 1;
	var ABRIR = 2;
	var VALIDADOC = 4;
	var REVISADOC = 21;
	var GERARMINUTA = 6;
	var PREENCHEMINUT = 8;
	var VALIDAMINUTA = 13;
	var MINUTAFINAL = 15;
	var FINALIZACONTRATO = 17;
	
	var step = parseInt(getValue("WKNumState"));
	var fields = new Array();

	switch(step){
	case 0:
		break;
	case VALIDADOC:
		fields.push("sTipoImpr");
		break;
	case REVISADOC:
		fields.push("sDescSol");
		fields.push("sObservacao");
		fields.push("btnNovaParte");
		fields.push("sValor");
		fields.push("sCondPagamento");
		fields.push("sVigenciaDe");
		fields.push("sVigenciaAte");
		fields.push("cbRenova");
		fields.push("optAtivo");
		fields.push("optPassivo");
		fields.push("sRazaoSocial");
		fields.push("sTipoParte");
		fields.push("sCnpj");
		fields.push("sEndereco");
		fields.push("sCidade");
		fields.push("sEstado");
		fields.push("sCep");
		fields.push("sBairro");
		break;
	case PREENCHEMINUT:
	case VALIDAMINUTA:
	case MINUTAFINAL:
	case FINALIZACONTRATO:
		fields.push("cbRenova");
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