function validateForm(form){
	if (form.getValue('sEmpresa') == null || form.getValue('sEmpresa') == ""){
		throw "Favor selecionar uma empresa a qual a consulta/parecer se refere.";
	}
	
	if (form.getValue('sDescSol') == null || form.getValue('sDescSol') == ""){
		throw "Favor informar uma descrição";
	}
}