var _mestre = "";
var _detalhe = "";


function loadApplet(sObject){
	document.write(sObject);
}


function changeAppSize(){ 
    if (navigator.appName=="Microsoft Internet Explorer") {
	    document.AppKpi.width = document.body.clientWidth;
	    document.AppKpi.height = document.body.clientHeight;
    } else {
	    document.embeds["AppKpi"].width = window.innerWidth;
	    document.embeds["AppKpi"].height = window.innerHeight;
	}
}


function abrir(cUrl){
    window.open(cUrl,"popupImageWindow","toolbar=no,location=no,directories=no,status=yes,menubar=no,scrollbars=no,resizable=yes,copyhistory=no,width=450,height=200,screenX=150,screenY=150,top=150,left=150");
}


/**
 * Define como ordenável todas as tabelas que utilizam a classe 'tablesorter'.
 */
$(function() {
	var tabela = $(".tablesorter");
	
	tabela.each(function () {
		$(this).tablesorter({
			dateFormat: "uk"
		});
	});  
});


/**
 * Controla ordem e limita sele??o de apenas dois dos checkboxes (mestre e detalhe).
 * @param objeto checkbox selecionado.
 */
function sgiSelecaoSintese( objeto ) {
	var checkbox = $("input:checkbox");
	var marcado = $("input:checkbox:checked");
	var desabilitado = $("input:checkbox:disabled");

	//Valor inicial do mestre e detalhe.
	_mestre = "";
	_detalhe = "";

	//Disponibilidade de sele??o dos campos.
	if( marcado.length == 2 ){
		checkbox.each(function () {
			if( $(this).attr("checked") != true ){
				$(this).attr("disabled", true);
			}
		});                    
	}else{
		if( desabilitado.length > 0 ){
			desabilitado.each(function () {
				$(this).attr("disabled", false);
			});
		}                  
	}

	//Ordem de sele??o da coluna mestre e detalhe.
	if( marcado.length > 0 ){
		marcado.each(function () {
			if ( objeto.value != $(this).attr("value")){
				_mestre = $(this).attr("value");
			}
		});

		if ( objeto.checked == true ){
			if( _mestre == "" ){
				_mestre = objeto.value;
			}else if( _mestre != objeto.value ){
				_detalhe = objeto.value;
			}
		}
	}
}


/**
 * Realiza a requisi??o e passagem de par?metros para s?ntese.
 * @param url url base para s?ntese.
 */
function sgiRequisicaoSintese( url ) {
	if( _mestre != "" ){
		url += ( "&mestre=" + _mestre );
		if( _detalhe != "" ){
			url += ( "&detalhe=" + _detalhe );
		}
		document.location.href = url;
	}                
}