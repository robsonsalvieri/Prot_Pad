$(function(){
	
	//lockFields();
	
	$('#zoomEmpBtn').click(function(){
		var escritorio = $('#cdFilialNS7 option:selected').val();
		
		mostraZoom('EMP',escritorio);
	});
	
	$( "#cdTipoSol" ).change(function() {
		if ($('#sTipoSol').is(":hidden")){
			$('#sTipoSol').val($('#cdTipoSol option:selected').text());
		}
	});
	
	$( "#cdAreaSol" ).change(function() {
		if ($('#sAreaSol').is(":hidden")){
			$('#sAreaSol').val($('#cdAreaSol option:selected').text());
		}
	});
	
	$( "#cdFilialNS7" ).change(function() {
		if ($('#sFilialNS7').is(":hidden")){
			$('#sFilialNS7').val($('#cdFilialNS7 option:selected').text());
		}
	});
	
	//Carrega os valores iniciais dos combos
	loadInitial();
	

});

function mostraZoom(id, escritorio){
	var type = '';
	var ds = '';
	var zoomTitle = '';
	var zoomHeader = '';
	var zoomFields = '';
	var zoomFilter = '';
	
	switch(id){
	case 'EMP':
		type = 'EMP';
		ds = 'dsClienteSigajuri';
		zoomTitle = 'Escolha uma empresa';
		zoomHeader = 'Razao_Social,Razão Social,Nome_Fantasia,Nome Fantasia,Cnpj,CNPJ';
		zoomFields = 'Id,Razao_Social,Nome_Fantasia,Cnpj';
		zoomFilter = 'Razao_Social, ,Escritorio,'+ escritorio
		break;
	}
	
	window.open("/webdesk/zoom.jsp?datasetId=" + ds + "&dataFields=" + zoomHeader + "&resultFields=" + zoomFields + "&type=" + type + "&filterValues=" + zoomFilter + "&title=" + zoomTitle, "zoom", "status , scrollbars=no ,width=600, height=350 , top=0 , left=0");
};

function setSelectedZoomItem(selectedItem){
	var sDescricao = '';
	switch(selectedItem.type){
	case 'EMP':
		
		sDescricao = selectedItem.Razao_Social + ' - ' + selectedItem.Nome_Fantasia + ' - ' + selectedItem.Cnpj;
		
		$('#cdEmpresa').val(selectedItem.Id);
		$('#sEmpresa').val(sDescricao);
		break;
	}
};

function lockFields(){
	var lSelect = true;
	
	if ($('#cdCajuri').val() != ""){
		lSelect = false;
	}
		
	$('#sAreaSol').toggle(!lSelect);
	$('#sTipoSol').toggle(!lSelect);
	$('#sFilialNS7').toggle(!lSelect);
	
	$('#cdAreaSol').toggle(lSelect);
	$('#cdTipoSol').toggle(lSelect);
	$('#cdFilialNS7').toggle(lSelect);
	
};

function loadInitial(){
	var lCarrega = true; //variável global para identificar o status da tarefa
	
	if ($('#cdCajuri').val() != ""){
		lCarrega = false;
	}
	
	//carrega os valores padrao para os campos caso não seja inclusão
	
	if (lCarrega){
		if ($('#sTipoSol').is(":hidden")){
			$('#sTipoSol').val($('#cdTipoSol option:selected').text());
		}
		if ($('#sAreaSol').is(":hidden")){
			$('#sAreaSol').val($('#cdAreaSol option:selected').text());
		}
		if ($('#sFilialNS7').is(":hidden")){
			$('#sFilialNS7').val($('#cdFilialNS7 option:selected').text());
		}
	}else{
		//esconde botão do zoom
		$('#zoomEmpBtn').toggle(lCarrega);
	}
}