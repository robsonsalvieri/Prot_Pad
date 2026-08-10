$(function() {
	var step = parseInt($("#sStatusAtiv").val());
	var REVISADOC = 21;
	var cPassivo = '';
	var cCodPassivo = '';
	var cAuxPassivo = '';
	var cAuxCodPassivo = '';
	var cAtivo = '';
	var cCodAtivo = '';
	var cAuxAtivo = '';
	var cAuxCodAtivo = '';

    //altera visibilidade dos campos
    lockFields();
    setMascaras();

    //inicializa o switchee
    FLUIGC.switcher.init('#cbRenova');

    var sVigenciaDe = FLUIGC.calendar('#sVigenciaDe', {
        language: 'pt'
    });

    var sVigenciaAte = FLUIGC.calendar('#sVigenciaAte', {
        language: 'pt'
    });
    $('#zoomAnexoBtn').click(function(){
		var pastaCaso = $('#sPastaCaso').val();
		var sFiltro = 'PastaCaso,' + pastaCaso + ',FiltExtensao,.pdf;.doc;.docx';
		
		mostraZoom('ANX','',sFiltro);
	});

	$('#zoomAssinBtn').click(function(){
		mostraZoom('VERT','ASSIN');
	});

	$('#zoomTransferenciaBtn').click(function(){
		var resp = $('#sStatusProc').val();
		if (resp=='1'){
			mostraZoom('RESP', '');
		} else {
			mostraZoom('RESP', '');
	    }
	});

	$('#btnNovaParte').click(function() {
		limpaNovaParte();
		$("#dvNovaParte").toggle(true);
		
		//determina se o cadastro é para o pólo ativo ou passivo
		if ($('input[name=optAtivo]:radio:checked').val() == "optOutros") {
			//desabilita os campos para evitar que o zoom seja utilizado
			$('input[name="optAtivo"]').prop("disabled", true);
			$('#zoomAtivoBtn').toggle(false);

			cAtivo = $('#sAtivo').val()
			cCodAtivo = $('#cdAtivo').val()
			cAuxAtivo = $('#_sAtivo').val()
			cAuxCodAtivo = $('#_cdAtivo').val()

			//zera os campos caso exista algo preenchido
			$('#cdAtivo').val('');
			$('#sAtivo').val('');
			$('#_cdAtivo').val('');
			$('#_sAtivo').val('');
			$('#cdEntAtivo').val("NZ2");
		} else {
			//desabilita os campos para evitar que o zoom seja utilizado
			$('input[name="optPassivo"]').prop("disabled", true);
			$('#zoomPassivoBtn').toggle(false);

			cPassivo = $('#sPassivo').val()
			cCodPassivo = $('#cdPassivo').val()
			cAuxPassivo = $('#_sPassivo').val()
			cAuxCodPassivo = $('#_cdPassivo').val()

			//zera os campos caso exista algo preenchido
			$('#cdPassivo').val('');
			$('#sPassivo').val('');
			$('#_cdPassivo').val('');
			$('#_sPassivo').val('');
			$('#cdEntPassivo').val("NZ2");
		}

		$(this).prop("disabled", true);
	});

	$('#btnCancel').click(function() {
		$("#dvNovaParte").toggle(false);
	
		$('#btnNovaParte').prop("disabled", false);
	
		//determina se o cadastro é para o pólo ativo ou passivo
		if ($('input[name=optAtivo]:radio:checked').val() == "optOutros") {
			$('input[name="optAtivo"]').prop("disabled", false);
			$('#zoomAtivoBtn').toggle(true);
			$('#sAtivo').val(cAtivo);
			$('#cdAtivo').val(cCodAtivo);
			$('#_sAtivo').val(cAtivo);
			$('#_cdAtivo').val(cCodAtivo);
		} else {
			$('input[name="optPassivo"]').prop("disabled", false);
			$('#zoomPassivoBtn').toggle(true);
			$('#sPassivo').val(cPassivo);
			$('#cdPassivo').val(cCodPassivo);
			$('#_sPassivo').val(cPassivo);
			$('#_cdPassivo').val(cCodPassivo);
		}
	
		limpaNovaParte();
	});

    $('#btnLimpaForn').click(function() {
        limpaNovaParte();
    });

    $("#cdTipoCon").change(function() {
        if ($('#sTipoCon').is(":hidden")) {
            $('#sTipoCon').val($('#cdTipoCon option:selected').text());
        }
    });

    $("#cdAreaSol").change(function() {
        if ($('#sAreaSol').is(":hidden")) {
            $('#sAreaSol').val($('#cdAreaSol option:selected').text());
        }
    });

    $("#cdFilialNS7").change(function() {
        if ($('#sFilialNS7').is(":hidden")) {
            $('#sFilialNS7').val($('#cdFilialNS7 option:selected').text());
        }
    });

    FLUIGC.switcher.onChange($('#cbRenova'), function(event, state) {
        if ($('#cdCajuri').val() == "" || step == REVISADOC) {
            $('#sRenovacao').val(state ? "1" : "2");
        }
    });

    $('#btnTransferir').click(function() {
        $('#_sTransferencia').val('');
        $('#sTransferencia').val('');
        $("#dvTransferir").toggle();
        if ($('#dvTransferir').is(":hidden")) {
            $('#sTransferencia').val('');
            $('#_sTransferencia').val('');
        }
    });

	$('#zoomAtivoBtn').click(function(){
		var escritorio = $('#cdFilialNS7').val();
		
		if (escritorio != '-'){
			switch($('input[name=optAtivo]:radio:checked').val()){
				case "optCli":
					mostraZoom('EMP','A', escritorio);
					$('#cdEntAtivo').val('SA1');
					break;
				case "optForn":
					mostraZoom('FOR','A', escritorio);
					$('#cdEntAtivo').val('SA2');
					break;
				case "optOutros":
					mostraZoom('NZ2','A', escritorio);
					$('#cdEntAtivo').val('NZ2');
					break;
			}
		}
	});

	$('#zoomPassivoBtn').click(function(){
		var escritorio = $('#cdFilialNS7').val();
		
		if (escritorio != '-'){
			switch($('input[name=optPassivo]:radio:checked').val()){
				case "optCli":
					mostraZoom('EMP','P',escritorio);
					$('#cdEntPassivo').val('SA1');
					break;
				case "optForn":
					mostraZoom('FOR','P',escritorio);
					$('#cdEntPassivo').val('SA2');
					break;
				case "optOutros":
					mostraZoom('NZ2','P',escritorio);
					$('#cdEntPassivo').val('NZ2');
					break;
			}
		}
	});

	$("input[name='optAtivo']").on("change", function() {
		switch (this.value) {
			case "optCli":
				$('#btnNovaParte').prop("disabled", true);
				$('#optPassivoForn').prop("disabled", false);
				$('#optPassivoOutros').prop("disabled", false);
				break;
			case "optForn":
				$('#btnNovaParte').prop("disabled", true);
				$('#optPassivoForn').prop("disabled", false);
				$('#optPassivoOutros').prop("disabled", false);
				break;
			case "optOutros":
				$('#btnNovaParte').prop("disabled", false);
				$('#optPassivoForn').prop("disabled", true);
				$('#optPassivoOutros').prop("disabled", true);
				$('#optPassivoCli').prop("checked", true);
				break;
		}
	});

	$("input[name='optPassivo']").on("change", function() {
		switch (this.value) {
			case "optCli":
				$('#btnNovaParte').prop("disabled", true);
				$('#optAtivoForn').prop("disabled", false);
				$('#optAtivoOutros').prop("disabled", false);
				break;
			case "optForn":
				$('#btnNovaParte').prop("disabled", true);
				$('#optAtivoForn').prop("disabled", false);
				$('#optAtivoOutros').prop("disabled", false);
				break;
			case "optOutros":
				$('#btnNovaParte').prop("disabled", false);
				$('#optAtivoForn').prop("disabled", true);
				$('#optAtivoOutros').prop("disabled", true);
				$('#optAtivoCli').prop("checked", true);
				break;
		}
	});

	loadInitial();
});

function limpaNovaParte() {
    $('#sRazaoSocial').val('');
    $('#sCnpj').val('');
    $('#sEndereco').val('');
    $('#sComplemento').val('');
    $('#sBairro').val('');
    $('#sEstado').val('');
    $('#sCidade').val('');
    $('#sCep').val('');
}

function mostraZoom(id, polo,escritorio){
    var type = '';
    var ds = '';
    var zoomTitle = '';
    var zoomHeader = '';
    var zoomFields = '';
    var zoomFilter = '';
    var url        = '';
    polo = polo + "_"
    
    switch (id) {

        case 'EMP':
            type = polo + 'EMP';
            ds = 'dsClienteSigajuri';
            zoomTitle = 'Escolha uma empresa';
            zoomHeader = 'Razao_Social,Razão Social,Nome_Fantasia,Nome Fantasia,Cnpj,CNPJ';
            zoomFields = 'Id,Razao_Social,Nome_Fantasia,Cnpj';
			zoomFilter = 'Razao_Social, ,Escritorio,'+ escritorio
            break;
        case 'FOR':
            type = polo + 'FOR';
            ds = 'dsFornecedorSigajuri';
            zoomTitle = 'Escolha um fornecedor';
            zoomHeader = 'Razao_Social,Razão Social,Nome_Fantasia,Nome Fantasia,Cnpj,CNPJ';
            zoomFields = 'Id,Razao_Social,Nome_Fantasia,Cnpj';
			zoomFilter = 'Razao_Social, ,Escritorio,' + escritorio;
            break;
        case 'NZ2':
            type = polo + 'NZ2';
            ds = 'dsParteContrariaSIGAJURI';
            zoomTitle = 'Escolha uma parte';
            zoomHeader = 'Razao_Social,Razão Social,Cnpj,CNPJ';
            zoomFields = 'Id,Razao_Social,Cnpj';
			zoomFilter = 'Razao_Social, ,Escritorio,' + escritorio;
            break;
        case 'RESP':
        	type = polo + 'RESP';
            ds = "colleague";
            zoomTitle = "Usuários";
            zoomHeader = "colleagueName,Nome,mail,Email";
            zoomFields = "colleagueName,colleaguePK.colleagueId,mail";
            zoomFilter = "active,true"
            break;
        case 'ANX':
			type = polo + 'ANX';
			ds = 'dsAnexos';
			zoomTitle = 'Escolha um documento';
			zoomHeader = 'id,Cod,Desc,Documento';
			zoomFields = 'id,Desc';
			zoomFilter = 'Desc, ,' + escritorio ;
			break;
		case 'VERT':
			type = polo + "VERT"
			ds = 'ds_vertsign_assinantes';
			zoomTitle = 'Escolha os assinantes';
			zoomHeader = 'nome,Nome,cCpf,CPF,cEmail,E-mail'
			zoomFields = 'nome,email,cpf,cEmail,cCpf'
			zoomFilter = ''
			break;
    }
    // Montagem da URL
	url =  "?datasetId=" + ds;
	url += "&dataFields=" + zoomHeader; 
	url += "&resultFields=" + zoomFields;
	url += "&title=" + zoomTitle;
	
	if (type != ''){
		url += "&type=" + type;
	}

	if (zoomFilter != ''){
		url += "&filterValues=" + zoomFilter;  
	}
	
	window.open("/webdesk/zoom.jsp" + url, "zoom", "status , scrollbars=no ,width=600, height=350 , top=0 , left=0");
	
};

function setSelectedZoomItem(selectedItem) {
	var polo = selectedItem.type.substring(0, 1);
	var prefix = selectedItem.type.substring(0,selectedItem.type.indexOf("_"))
	var tipo = selectedItem.type.substring(selectedItem.type.indexOf("_") + 1)
	var sDescricao = '';
	
	switch (tipo){
		case "EMP":
		case "FOR":
		case "NZ2":
			if (tipo == "NZ2") {
				sDescricao = selectedItem.Razao_Social + ' - ' + selectedItem.Cnpj;
			} else {
				sDescricao = selectedItem.Razao_Social + ' - ' + selectedItem.Nome_Fantasia + ' - ' + selectedItem.Cnpj;
			}
			
			if (prefix != "") {
				//valida o polo para diferenciar os campos
				if (prefix == "A") {
					$('#cdAtivo').val(selectedItem.Id);
					$('#sAtivo').val(sDescricao);
					$('#_sAtivo').val(sDescricao);
					$('#_cdAtivo').val(selectedItem.Id);
				} else {
					$('#cdPassivo').val(selectedItem.Id);
					$('#sPassivo').val(sDescricao);
					$('#_cdPassivo').val(selectedItem.Id);
					$('#_sPassivo').val(sDescricao);
				}
			}
		break;
	}
	
	switch (tipo) {
		case 'EMP':
			if (prefix == "A") {
				$('#cdEntAtivo').val('SA1');
			} else {
				$('#cdEntPassivo').val('SA1');
			}
			break;
		case 'FOR':
			if (prefix == "A") {
			    $('#cdEntAtivo').val('SA2');
			} else {
			    $('#cdEntPassivo').val('SA2');
			}
			break;
		case 'NZ2':
			if (prefix == "A") {
				$('#cdEntAtivo').val('NZ2');
			} else {
				$('#cdEntPassivo').val('NZ2');
			}
			break;
		case 'RESP':
			$('#_sTransferencia').val(selectedItem.colleagueName);
			$('#sTransferencia').val(selectedItem.colleagueName);
					
			if ($('#sStatusProc').val()=="1"){
				$('#cdResponsavel').val(selectedItem["colleaguePK.colleagueId"]);
			}else{
				$('#cdSolicitante').val(selectedItem["colleaguePK.colleagueId"]);
			}
			break;
		case 'VERT':
			sAssLista = $('#sAssLista').val();
			sAssHiddenList = $("#sAssHiddenList").val();
			if (sAssLista.indexOf(selectedItem.cEmail) == -1){
				sAssLista = sAssLista + selectedItem.cEmail + ';';
				$('#sAssLista').val(sAssLista);
				
				sAssHiddenList = sAssHiddenList + hex2a(selectedItem.email) + ';';
				$("#sAssHiddenList").val(sAssHiddenList);
			}
			break;
		case 'ANX':
			$('#cdDocAsign').val(selectedItem['id']);
			$('#docAsign').val(selectedItem['Desc']);
			break;
	}
};

function lockFields() {
    //oculta div nova parte
    $("#dvNovaParte").toggle(false);
    $("#dvTransferir").toggle(false);
};

function setMascaras() {
	$('#sValor').mask('#.##0,00', {reverse: true});
	
};


function loadInitial() {
var lCarrega = true; //variável global para identificar o status da tarefa
var ABRIR = 2;
var REVISADOC = 21;
var ENCASSINATURA = 31;
var VALASSINATURA = 36;
var REVASSINATURA = 40;
var step = parseInt($("#sStatusAtiv").val());

	if ($('#cdCajuri').val() != "") {
		lCarrega = false;
	}
	
	//carrega os valores padrao para os campos caso não seja inclusão
	
	if ($('#sRenovacao').val() != "") {
		if ($('#sRenovacao').val() == "1") {
			FLUIGC.switcher.setTrue('#cbRenova');
		} else {
			FLUIGC.switcher.setFalse('#cbRenova');
		}
	}

	if (lCarrega) {
		if ($('#sTipoCon').is(":hidden")) {
			$('#sTipoCon').val($('#cdTipoCon option:selected').text());
		}
		if ($('#sAreaSol').is(":hidden")) {
			$('#sAreaSol').val($('#cdAreaSol option:selected').text());
		}

		if ($('#sFilialNS7').is(":hidden")) {
			$('#sFilialNS7').val($('#cdFilialNS7 option:selected').text());
		}

		$('#btnTransferir').toggle(!lCarrega);
	} else {
		//esconde botão do zoom
		$('#zoomAtivoBtn').toggle(step == REVISADOC);
		$('#zoomPassivoBtn').toggle(step == REVISADOC);

		if (step != REVISADOC) {
			FLUIGC.switcher.disable('#cbRenova');
		} else {
			if ($('input[name=optAtivo]:radio:checked').val() == "optOutros" ||
					$('input[name=optPassivo]:radio:checked').val() == "optOutros") {
				$('#btnNovaParte').prop("disabled", false);
			}
		}
	}

	$('#linkFolder').toggle(step != ABRIR && $('#sPastaCaso').val() != "");
	$('#pnAssDigital').toggle(step == ENCASSINATURA || step == REVASSINATURA);
}

function AnexoDoc() {
    var concAnexo = '';
    var context = window.parent.WCMAPI.getContextPath();
    var empresa = window.parent.WCMAPI.getTenantCode();
    var pastaCaso = document.getElementById("sPastaCaso").value;

    concAnexo = (context + '/p/' + empresa + '/ecmnavigation?app_ecm_navigation_doc=' + pastaCaso);

    if (pastaCaso != '') {
        window.open(concAnexo);
    }
}

function hex2a(hexx) {
	var hex = hexx.toString();
	var str = '';
	for (var i = 0; i < hex.length && hex.substr(i, 2) !== '00'; i += 2)
		str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
	return str;
}

function isNullOrUndefined(value, isVldTraco) {
	if ( value == null || value == '' || ( isVldTraco && value == '-') ) {
		return true;
	}

	return false;
}