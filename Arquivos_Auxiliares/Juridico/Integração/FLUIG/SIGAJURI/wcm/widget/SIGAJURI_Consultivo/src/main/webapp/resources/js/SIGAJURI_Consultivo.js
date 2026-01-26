var wcmConsultivo = SuperWidget.extend({
	loading: null, // tela de Loading
	configConsultivo: null, // Datatable
	isDatatableBound: false,

    init: function(){
    	// soment no ViewMode
    	if(!this.isEditMode){
    		// Cria a tela de loading
	    	this.loading = FLUIGC.loading('#wcmConsultivo_'+this.instanceId);
	    	
	    	// Seta as mascaras dos campos de prioridade e valor
	    	// Nota: Foi utilizada uma library de mascara diferente da padrão. Ver arquivo "mascaras.js".
	    	$('#sPrioridade_'+this.instanceId).mask('0#', {reverse: false});
	    	
	    	// Carrega os dados das configuracoes de Consultivo existentes na Datatable.
	    	this.updateDatatableCons();
	    	
	    	// Carrega os Dropdowns de Assunto Juridico e Tipos de Follow-Up
	    	this.loadDatasetValues('dsAssJur', ['id', 'AssJur'], new Array(), null);
	    	this.loadDatasetValues('dsTipoSol', ['id', 'TipoSol'], new Array(), null);
    	}
    },

    bindings: {
        local: {
        	'open-zoom-grupo': ['click_mostraZoom'],
            'clear-zoom-grupo': ['click_clearZoom'],
            'open-zoom-usuario': ['click_mostraZoom'],
            'clear-zoom-usuario': ['click_clearZoom'],
            'save-button': ['click_saveConsultivo'],
            'clear-button': ['click_clearConsultivo'],
            'delete-button': ['click_deleteConsultivo'],
            'select-change': ['change_selectChange']
        }
    },
    
    /***
     * Função para carregar valores de Datasets do Fluig via AJAX, para não prender a execução. 
     * Customizada para alterar o retorno ao usuário e o tratamento dos dados com base no nome do Dataset consultado.
     * @param name Nome do Dataset a ser consultado.
     * @param fields Campos do Dataset a serem selecionados para retorno.
     * @param constraints Filtros a serem aplicados ao Dataset.
     * @param order Campos que vão determinar a ordem dos registros do Dataset.
     */
    loadDatasetValues : function(name, fields, constraints, order){
    	// salva a referencia ao objeto widget para poder utilizado de dentro das funcoes Callback.
    	var _this = this;
    	
    	// variavel contendo todos os campos de entrada para ser utilizada na chamada AJAX
    	var data = {
			"name":name,
			"fields":fields,
			"constraints":constraints,
			"order":order
		};
    	
    	// Cria uma variavel para receber o texto da tela de loading, dependendo do nome do Dataset consultado.
    	var msg = "";
    	switch (name){
    	case "dsAssJur":
    		msg = "${i18n.getTranslation('application.loading.dsAssJur')}";
    		break;
    	case "dsTipoSol":
    		msg = "${i18n.getTranslation('application.loading.dsTipoSol')}";
    		break;
    	case "wcmSIGAJURI_Consultivo":
    		msg = "${i18n.getTranslation('application.loading.wcmSIGAJURI_Consultivo')}";
    		break;
    	case "dsSaveConsultivo":
    		msg = "${i18n.getTranslation('application.loading.dsSaveConsultivo')}";
    		break;
    	case "dsDeleteConsultivo":
    		msg = "${i18n.getTranslation('application.loading.dsDeleteConsultivo')}";
    		break;
    	default:
    		msg = "${i18n.getTranslation('application.loading.Dataset')}";
    	}
    	
    	// Mostra a tela de loading com a mensagem determinada acima.
    	this.loading.show();
    	this.loading.setMessage("<h3>" + msg + "</h3>");
    	
    	// Realiza a chamada AJAX para recuperar os registros do Dataset.
    	simpleAjaxAPI.Create({
    		url: parent.ECM.restUrl + "dataset/datasets/", // Endereço do REST para consumir Datasets.
    		data: data, // Dados utilizados na chamada ao Dataset.
    		success: function(data){ // Funcao callback de sucesso.
				_this.loading.hide(); // Esconde a tela de loading.
    			if(data != null && data.values != null && data.values.length > 0){ // Caso o resultado não seja vazio.
    				// Determinar o que fazer com os dados a partir do nome do Dataset consultado.
    				switch (name){
    				case "dsAssJur":
    					// Carregar o dropdown de Assuntos juridicos
    					_this.loadSelect(data.values, 'AssJur');
    					break;
    				case "dsTipoSol":
    					// Carregar o dropdown de Tipos de Follow-Up
    					_this.loadSelect(data.values, 'TipoSol');
    					break;
    		    	case "wcmSIGAJURI_Consultivo":
    		    		// Carregar o Datatable de configurações de Consultivo
    		    		_this.loadDatatableCon(data.values);
    		    		break;
    				case "dsSaveConsultivo":
    					// Caso o Webservice tenha retornado 'ok', gerar um Toast e limpar os campos do Widget. Caso contrário, gerar uma modal de alerta.
    					if (data.values[0]['Status']=='ok'){
	    					FLUIGC.toast({
	        			        title: "${i18n.getTranslation('application.success.Title.dsSaveConsultivo')}",
	        			        message: "${i18n.getTranslation('application.success.dsSaveConsultivo')}",
	        			        type: 'success'
	        			    });
	    		    		_this.clearConsultivo();
    					} else {
    		    			FLUIGC.message.alert({
    		    			    message: data.values[0]['Status'],
    		    			    title: "${i18n.getTranslation('application.error.Title')}",
    		    			    label: "${i18n.getTranslation('application.button.Close')}"
    		    			}, function(el, ev) {
    		    			});
    					}
    					break;
    				case "dsDeleteConsultivo":
    					// Caso o Webservice tenha retornado 'ok', gerar um Toast e limpar os campos do Widget. Caso contrário, gerar uma modal de alerta.
    					if (data.values[0]['Status']=='ok'){
	    					FLUIGC.toast({
	        			        title: "${i18n.getTranslation('application.success.Title.dsDeleteConsultivo')}",
	        			        message: "${i18n.getTranslation('application.success.dsDeleteConsultivo')}",
	        			        type: 'success'
	        			    });
	    		    		_this.clearConsultivo();
    					} else {
    		    			FLUIGC.message.alert({
    		    			    message: data.values[0]['Status'],
    		    			    title: "${i18n.getTranslation('application.error.Title')}",
    		    			    label: "${i18n.getTranslation('application.button.Close')}"
    		    			}, function(el, ev) {
    		    			});
    					}
    					break;    					
    				default:
    					// Para casos de datasets genericos, gerar um Toast informando o sucesso da operacao.
    					FLUIGC.toast({
        			        title: "${i18n.getTranslation('application.warning.Title.Dataset')}",
        			        message: data.values[0].Status,
        			        type: 'success'
        			    });
    				}
    			}else{ // Caso o dataset retorne vazio, determinar qual mensagem utilizar e gerar um Toast informando a falta de registros.
    		    	var msgVazio = "${i18n.getTranslation('application.warning.Dataset')}";
    		    	var titleVazio = "${i18n.getTranslation('application.warning.Title.Dataset')}";
    		    	var typeVazio = 'warning';
    		    	switch (name){
    		    	case "dsAssJur":
    		    		msgVazio = "${i18n.getTranslation('application.warning.dsAssJur')}";
    		    		titleVazio = "${i18n.getTranslation('application.warning.Title.dsAssJur')}";
    		    		typeVazio = 'error';
    		    		break;
    		    	case "dsTipoSol":
    		    		msgVazio = "${i18n.getTranslation('application.warning.dsTipoFu')}";
    		    		titleVazio = "${i18n.getTranslation('application.warning.Title.dsTipoSol')}";
    		    		typeVazio = 'error';
    		    		break;
    		    	case "wcmSIGAJURI_Consultivo":
    		    		msgVazio = "${i18n.getTranslation('application.warning.wcmSIGAJURI')}";
    		    		titleVazio = "${i18n.getTranslation('application.warning.Title.wcmSIGAJURI')}";
    		    		typeVazio = 'info';
    		    		_this.loadDatatableCon(data.values);
    		    		break;
    		    	}
    				FLUIGC.toast({
    			        title: titleVazio,
    			        message: msgVazio,
    			        type: typeVazio
    			    });
    			}
    		},
    		error : function(jqXHR, textStatus, errorThrown){ // Funcao callback de falha.
    			// Esconde a tela de loading.
    			_this.loading.hide();
    			
    			// Gera um alerta com a falha ocorrida.
    			FLUIGC.message.alert({
    			    message: "${i18n.getTranslation('application.error.datasetFail')}" + errorThrown,
    			    title: "${i18n.getTranslation('application.error.Title.datasetFail')}",
    			    label: "${i18n.getTranslation('application.button.Close')}"
    			}, function(el, ev) {
    			});
    		}
    	});
	},
	
	/**
	 * Carrega os dados retornados pelo dataset na dropdown correta.
	 * @param data Retorno do Dataset consultado.
	 * @param tipoSelect Qual Select deve ser populado por essa chamada.
	 */
	loadSelect: function(data, tipoSelect){
		var select = null;
		var options = null;
		var skipFirst = false;
		
		// Determinar qual DOM Select deve ser selecionado a partir do tipo de select foi passado e popular o valor padrão do select.
		switch (tipoSelect){
		case "AssJur":
    		select = $('#sAssuntoJuridico_'+this.instanceId);
    		options = '<option value="">' + "${i18n.getTranslation('application.placeholder.AssuntosJuridicos.StandardValue')}" + '</option>';
    		skipFirst = true;
    		break;
    	case "TipoSol":
    		select = $('#sTipoSol_'+this.instanceId);
    		options = '<option value="">' + "${i18n.getTranslation('application.placeholder.TipoSol.StandardValue')}" + '</option>';
    		break;
    	default: return;
		}
		
		// Para cada registro retornado do Dataset, incluir uma opção no select.		
		for (var i = 0; i < data.length; i++){
			if (i == 0 && skipFirst){
				continue;
			}else{
				options += '<option value="' + data[i]['id'] + '">' + data[i][tipoSelect] + '</option>';
			}
		}
		
		// seta as opções no dataset selecionado.
		select.html(options);
	},
    
	/**
	 * Função para bind do evento Change do Select.
	 * Essa função faz com que os valores do Select atuem como filtros para a Datatable, que é recarregada a cada alteração de valor nos Selects.
	 * @param el Elemento Select que disparou o evento.
	 * @param ev Objeto do evento em si.
	 */
	selectChange: function(el,ev){
		this.updateDatatableCons();
	},
	
	/**
	 * Função para bind do evento Click dos botões de zoom utilizados.
	 * @param el Elemento do Botão que disparou o evento.
	 * @param ev Objeto do evento em si.
	 */
    mostraZoom: function(el,ev){
    	var tipo = el.id; // Recupera a id do botão que disparou o evento para determinar qual tipo de zoom deve ser executado.
    	var that = this; // Mantém uma referência do Widget para ser usada em callbacks.
    	var type = ""; 
    	var ds = "";
    	var zoomTitle = "";
    	var resultFields = "id,Desc";
    	
    	// Determina titulo, campos e datasets a serem utilizados com base em qual zoom foi acionado.
    	switch(tipo){    	
    	case "zoomUsuarioResponsavel_"+this.instanceId:
    		type = "usuario";
    		ds = "colleague";
    		zoomTitle = "${i18n.getTranslation('application.zoom.Usuario.Title')}";
    		dataFields = "colleagueName, " + "${i18n.getTranslation('application.zoom.Usuario.Header')}";
            resultFields = "mail,colleagueName";
    		break;
        case "zoomGrupoResponsavel_"+this.instanceId:
            type = "grupo";
            ds = "dsGrupos";
            zoomTitle = "${i18n.getTranslation('application.zoom.Grupo.Title')}";
            dataFields = "Desc," + "${i18n.getTranslation('application.zoom.Grupo.Header')}";
            break;            
    	}
    	
    	// Abre a janela de zoom de acordo com as variaveis determinadas.
    	window.open("/webdesk/zoom.jsp?datasetId=" + ds + "&dataFields=" + dataFields + "&resultFields=" + resultFields + "&type=" + type + "&title=" + zoomTitle, "zoom", "status , scrollbars=no ,width=600, height=350 , top=0 , left=0");
    	// Prepara uma variavel para receber a função que lida com o retorno do Zoom.
    	var newSelectedItem = function(selectedItem){
    		that.selectedZoomItem(selectedItem);
    	};
    	setSelectedZoomItem = newSelectedItem;
    },
    
    
    /**
     * Função para lidar com o retorno do zoom.
     * @param selectedItem Item selecionado no zoom.
     */
    selectedZoomItem: function(selectedItem){
    	// trata o retorno do Zoom de acordo com o seu tipo, preenchendo os campos da widget correspondentes.
    	switch(selectedItem.type){
	    	case "usuario":
	    		$('#cdUsuarioResponsavel_'+this.instanceId).val(selectedItem.mail);
	    		$('#sUsuarioResponsavel_'+this.instanceId).val(selectedItem.colleagueName);
	    		break;
	    	case "grupo":
	    		$('#cdGrupoResponsavel_'+this.instanceId).val(selectedItem.id);
	    		$('#sGrupoResponsavel_'+this.instanceId).val(selectedItem.Desc);
	    		break;
    	}
    	this.changeZoomEnable('selecionar', selectedItem.type);
    },
    
    /**
     * Função para bind do evento Click dos botões de limpar campo com zoom.
     * @param el Elemento Botão que disparou o evento.
     * @param ev Objeto do evento em si.
     */
    clearZoom: function(el,ev){
    	var tipo = el.id; // Separa o id do botão.
    	var val = $('#cdUsuarioResponsavel_'+this.instanceId).val();
    	// Limpa os campos de acordo com qual dos botões foi pressionado.
    	switch(tipo){    	
	    	case "clearUsuarioResponsavel_"+this.instanceId:
	     	    $('#cdUsuarioResponsavel_'+this.instanceId).val('');
	     	    $('#sUsuarioResponsavel_'+this.instanceId).val('');
	    		break;
	    	case "clearGrupoResponsavel_"+this.instanceId:
	     	    $('#cdGrupoResponsavel_'+this.instanceId).val('');
	     	    $('#sGrupoResponsavel_'+this.instanceId).val('');
	    		break;
    	}
    	if (val != null){
            this.changeZoomEnable('limpar',tipo);
        }
    },
    
    /**
     * Função para bind do evento de Click do botão de salvar configuração de follow-up.
     * Essa função salva os dados preenchidos na base da widget, criando um registro novo ou atualizando um já existente, de forma automática.
     * A lógica pesada de inserção e edição está no código do dataset dsSaveFollowUp, deixando o trabalho pesado para ser executado no servidor.
     */
    saveConsultivo: function(){
    	// Realiza a validação do formulário da widget e, se tudo estiver OK, monta o array de dados nas Constraints e chama o Dataset que executa o procedimento.
    	if (this.validateFields()){
	    	var fields = new Array();
	    	var constraints = new Array();
	    	constraints.push(DatasetFactory.createConstraint('cdAssJur', $('#sAssuntoJuridico_'+this.instanceId).val(), $('#sAssuntoJuridico_'+this.instanceId).val(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('sAssJur', $('#sAssuntoJuridico_'+this.instanceId+' :selected').text(), $('#sAssuntoJuridico_'+this.instanceId+' :selected').text(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('cdTipoSol', $('#sTipoSol_'+this.instanceId).val(), $('#sTipoSol_'+this.instanceId).val(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('sTipoSol', $('#sTipoSol_'+this.instanceId+' :selected').text(), $('#sTipoSol_'+this.instanceId+' :selected').text(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('cdGrupo', $('#cdGrupoResponsavel_'+this.instanceId).val(), $('#cdGrupoResponsavel_'+this.instanceId).val(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('sGrupo', $('#sGrupoResponsavel_'+this.instanceId).val(), $('#sGrupoResponsavel_'+this.instanceId).val(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('cdUser', $('#cdUsuarioResponsavel_'+this.instanceId).val(), $('#cdUsuarioResponsavel_'+this.instanceId).val(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('sUser', $('#sUsuarioResponsavel_'+this.instanceId).val(), $('#sUsuarioResponsavel_'+this.instanceId).val(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('sPrioridade', $('#sPrioridade_'+this.instanceId).val(), $('#sPrioridade_'+this.instanceId).val(), ConstraintType.MUST));
	    	constraints.push(DatasetFactory.createConstraint('sPrazo', $('#sPrazo_'+this.instanceId).val(), $('#sPrazo_'+this.instanceId).val(), ConstraintType.MUST));
	      	constraints.push(DatasetFactory.createConstraint('sPrazoEnc', $('#sPrazoEnc_'+this.instanceId).val(), $('#sPrazoEnc_'+this.instanceId).val(), ConstraintType.MUST));
	  	  
	    	
	    	this.loadDatasetValues('dsSaveConsultivo', fields, constraints, null);
    	}
    },
    
    /**
     * Função para bind do evento de Click do botão de limpar campos da widget.
     * Essa função limpa todos os campos e recarrega a Datatable, limpando assim sua seleção e garantindo os dados mais recentes.
     */
    clearConsultivo: function(){
    	// Limpa o valor de todos os campos.
	    $('#sAssuntoJuridico_'+this.instanceId).val('');
	    $('#sTipoSol_'+this.instanceId).val('');
	    $('#cdGrupoResponsavel_'+this.instanceId).val('');
	    $('#sGrupoResponsavel_'+this.instanceId).val('');
	    $('#cdUsuarioResponsavel_'+this.instanceId).val('');
	    $('#sUsuarioResponsavel_'+this.instanceId).val('');
	    $('#sPrioridade_'+this.instanceId).val('');
	    $('#sPrazo_'+this.instanceId).val('');
	    $('#sPrazoEnc_'+this.instanceId).val('');
	    
	    
	    // Recarrega a Datatable.
	    this.updateDatatableCons();
    },
    
    /**
     * Função para bind do evento de Click do botão de deletar configuração de Follow-Up selecionada.
     * Essa função apaga uma configuração que tenha sido delecionada na Datatable.
     */
    deleteConsultivo: function(){
    	// Recupera a linha selecionada.
    	var selectedRow = this.configConsultivo.getRow(this.configConsultivo.selectedRows()[0]);
    	
    	// Caso haja uma linha selecionada, realiza a chamada ao dataset dsDeleteFollowUp que faz a exclusão da linha pelo seu cardId.
    	if (selectedRow != null){
    		var fields = new Array();
        	var constraints = new Array();
        	constraints.push(DatasetFactory.createConstraint('cdCardId', selectedRow['metadata#id'], selectedRow['metadata#id'], ConstraintType.MUST));
        	
        	this.loadDatasetValues('dsDeleteConsultivo', fields, constraints, null);    		
    	}
    },
    
    deleteConsultivoById: function(id){
		var fields = new Array();
    	var constraints = new Array();
    	constraints.push(DatasetFactory.createConstraint('cdCardId', id, id, ConstraintType.MUST));
    	
    	this.loadDatasetValues('dsDeleteConsultivo', fields, constraints, null);
    },
    
    /**
     * Recarrega a Datatable com os valores passados como parametro. 
     * É o ponto final do recarregamento da Datatable. 
     * Para a parte inicial, ver updateDatatableCons.
     * @param data Valores retornados pela chamada ao Dataset.
     */
    loadDatatableCon: function(data){
    	var _this = this; // Guarda uma referencia ao objeto Widget para uso em funções de callback.
    	
    	// Constroi a Datatable com os dados passados, provindos do Dataset.
    	this.configConsultivo = FLUIGC.datatable('#dtConsultivo_'+this.instanceId, {
    		dataRequest: data,
    		renderContent: '.template_datatable_consul',
    	    //renderContent: ['metadata#id', 'cdAssJur', 'sAssJur', 'cdTipoFu', 'sTipoFu','cdUser', 'sUser', 'sPrioridade'],
    	    header: [
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.Id')}",
    	        	'display': false
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.cdAssJur')}",
    	        	'display': false
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.sAssJur')}",
    	        	'standard': true
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.cdTipoSol')}",
    	        	'display': false
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.sTipoSol')}"
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.cdGrupo')}",
    	        	'display': false
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.sGrupo')}"
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.cdUser')}",
    	        	'display': false
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.sUser')}"
    	        },
    	        {
    	        	'title': "${i18n.getTranslation('application.datatable.column.sPrioridade')}"
        		},
    	        {
        			'title': "${i18n.getTranslation('application.datatable.column.sPrazo')}"
        		},
        		{
        			'title': "${i18n.getTranslation('application.datatable.column.sPrazoEnc')}"
        		},
        		
    	        {
        			'title': "${i18n.getTranslation('application.datatable.column.btnDelete')}",
    	        	'size': 'col-md-1 center-align'
    	        }
    	    ],
    	    multiSelect: false,
    	    classSelected: 'info',
    	    search: {
	   	        enabled: false
	   	    },
	   	    navButtons: {
	   	        enabled: false
	   	    },
	   	    actions: {
	   	        enabled: false
	   	    },
	   	    tableStyle: 'table-striped'
    	}, function (err, data){ // Função executada após o preenchimento da Datatable, realiza o binding dos eventos da datatable.
    		if (!_this.isDatatableBound){ 
    			_this.datatableBinding();
    		}
    	});
    },
    
    /**
     * Realiza o binding dos eventos da Datatable.
     */
    datatableBinding: function(){
    	var _this = this;// Guarda uma referencia ao objeto Widget para uso em funções de callback.
    	var campoPreenchido = '';
    	// Bind do evento onSelectRow da Datatable, disparado ao selecionar uma linha. Popula os campos do formulario com os valores da linha.
    	$('#dtConsultivo_'+this.instanceId).on('fluig.datatable.onselectrow', function(){
    	    var selectedRow = _this.configConsultivo.getRow(_this.configConsultivo.selectedRows()[0]);
    	    $('#sAssuntoJuridico_'+_this.instanceId).val(selectedRow.cdAssJur);
    	    $('#sTipoSol_'+_this.instanceId).val(selectedRow.cdTipoSol);
    	    $('#cdGrupoResponsavel_'+_this.instanceId).val(selectedRow.cdGrupo);
    	    $('#sGrupoResponsavel_'+_this.instanceId).val(selectedRow.sGrupo);
    	    $('#cdUsuarioResponsavel_'+_this.instanceId).val(selectedRow.cdUser);
    	    $('#sUsuarioResponsavel_'+_this.instanceId).val(selectedRow.sUser);
    	    $('#sPrioridade_'+_this.instanceId).val(selectedRow.sPrioridade);
    	    $('#sPrazo_'+_this.instanceId).val(selectedRow.sPrazo);
    	    $('#sPrazoEnc_'+_this.instanceId).val(selectedRow.sPrazoEnc);

    	    
    	    
    	});
    	
    	$('#dtConsultivo_'+this.instanceId).on('click', '[data-delete-row]', function(ev){
    		var id = ev.currentTarget.id.split('_')[1];
    		FLUIGC.message.confirm({
    		    message: "${i18n.getTranslation('application.datatable.column.btnDelete.comfirmText')}",
    		    title: "${i18n.getTranslation('application.datatable.column.btnDelete.comfirmTitle')}",
    		    labelYes: "${i18n.getTranslation('application.datatable.column.btnDelete.comfirmYes')}",
    		    labelNo: "${i18n.getTranslation('application.datatable.column.btnDelete.comfirmNo')}"
    		}, function(result, el, ev) {
    		    if (result){
    		    	_this.deleteConsultivoById(id);
    		    } else {
    		    	_this.clearConsultivo();
    		    }
    		});
    	});
    	
    	if ($('#cdGrupoResponsavel_'+_this.instanceId).val() != ''){
    		campoPreenchido = 'grupo';
    	} else if ( $('#cdUsuarioResponsavel_'+_this.instanceId).val()){
    		campoPreenchido = 'usuario';
    	}
    	
    	if (campoPreenchido != ''){
    		this.changeZoomEnable('selecionar', campoPreenchido);
    	}
    		
    	this.isDatatableBound = true;
    },
    
    changeZoomEnable: function(oper,tipo){
        switch(oper){
            case "selecionar":
                switch(tipo){
                    case "usuario":
                        $("#cdGrupoResponsavel_"+this.instanceId).prop('disabled', true);
                        $("#sGrupoResponsavel_"+this.instanceId).prop('disabled', true);
                        $('#zoomGrupoResponsavel_'+this.instanceId).prop('disabled', true);
                        $('#clearGrupoResponsavel_'+this.instanceId).prop('disabled', true);
                        break;
                    case "grupo":
                        $('#cdUsuarioResponsavel_'+this.instanceId).prop('disabled', true);   
                        $('#sUsuarioResponsavel_'+this.instanceId).prop('disabled', true);   
                        $('#zoomUsuarioResponsavel_'+this.instanceId).prop('disabled', true);
                        $('#clearUsuarioResponsavel_'+this.instanceId).prop('disabled', true);
                        
                        break;
                }
                break;
            case "limpar":
                $("#cdGrupoResponsavel_"+this.instanceId).prop('disabled', false);
                $("#sGrupoResponsavel_"+this.instanceId).prop('disabled', false);   
                $('#zoomGrupoResponsavel_'+this.instanceId).prop('disabled', false);
                $('#clearGrupoResponsavel_'+this.instanceId).prop('disabled', false);

                $('#cdUsuarioResponsavel_'+this.instanceId).prop('disabled', false);   
                $('#sUsuarioResponsavel_'+this.instanceId).prop('disabled', false);   
                $('#zoomUsuarioResponsavel_'+this.instanceId).prop('disabled', false);
                $('#clearUsuarioResponsavel_'+this.instanceId).prop('disabled', false);
                break;
        }
    },
    
    /**
     * Prepara os dados para a chamada AJAX que vai popular a Datatable. 
     * É o ponto de inicio do recarregamento da Datatable.
     * Para a parte final, ver loadDatatableCon
     */
    updateDatatableCons: function(){
    	// Recupera os valores dos selects para que eles atuem como filtros.
    	var selectAssJur = $('#sAssuntoJuridico_'+this.instanceId).val();
    	var selectTipoSol = $('#sTipoSol_'+this.instanceId).val();
    	// Prepara variaveis de Campos, Filtros e Ordenação para chamar o Dataset.
    	var constraints = new Array();
    	var sort = new Array();
    	var fields = new Array('metadata#id', 'cdAssJur', 'sAssJur', 'cdTipoSol', 'sTipoSol', 'cdGrupo', 'sGrupo', 'cdUser', 'sUser', 'sPrioridade', 'sPrazo', 'sPrazoEnc');
    	
    	// garante a seleção contenha apenas configurações ativas, descartando as versões antigas de registros que foram editados.
    	constraints.push(DatasetFactory.createConstraint('metadata#active', true, true, ConstraintType.MUST));

    	// Esses dois IFs trabalham para garantir que os Selects atuem como filtros para a Datatable.
    	if (selectAssJur != ''){
    		constraints.push(DatasetFactory.createConstraint('cdAssJur', selectAssJur, selectAssJur, ConstraintType.MUST));
    	}
    	
    	if (selectTipoSol != ''){
    		constraints.push(DatasetFactory.createConstraint('cdTipoSol', selectTipoSol, selectTipoSol, ConstraintType.MUST));
    	}
    	
    	// Campos de ordenação.
    	sort.push('cdAssJur');
    	sort.push('cdTipoSol');
    	sort.push('cdUser');
    	sort.push('cdGrupo');
    	
    	// Dispara a chamada ao Dataset via AJAX.
    	this.loadDatasetValues('wcmSIGAJURI_Consultivo', fields , constraints, sort);
    },
    
    /**
     * Valida os valores dos campos da Widget.
     * @return {Boolean} TRUE caso os campos estejam válidos, FALSE caso haja algum erro de preenchimento.
     */
    validateFields: function(){
    	// Recupera os valores do formulario da widget.
    	var cdAssJur = $('#sAssuntoJuridico_'+this.instanceId).val();
	    var cdTipoSol = $('#sTipoSol_'+this.instanceId).val();
	    var cdGrupo = $('#cdGrupoResponsavel_'+this.instanceId).val();
	    var cdUser = $('#cdUsuarioResponsavel_'+this.instanceId).val();
	    var sPrioridade = $('#sPrioridade_'+this.instanceId).val();
	    var sPrazo = $('#sPrazo_'+this.instanceId).val();
	    
	    
	    // Começa a montagem da mensagem de validação.
	    var msg = "<h3>${i18n.getTranslation('application.error.Validation')}</h3><ul>";
	    var success = true;
	    
	    if (cdAssJur == ''){ // Valida se o campo Assunto Juridico foi preenchido.
	    	msg += "<li>${i18n.getTranslation('application.label.AssJur')}</li>";
	    	success = false;
	    }
	    if (cdTipoSol == ''){ // Valida se o campo Tipo de Solicitação foi preenchido.
	    	msg += "<li>${i18n.getTranslation('application.label.TipoSol')}</li>";
	    	success = false;
	    }
	    if ((cdUser == '') && (cdGrupo == '')){ // Valida se o campo Usuario foi preenchido.
	    	msg += "<li>${i18n.getTranslation('application.label.Usuario.Grupo')}</li>";
	    	success = false;
	    }
	    if (sPrioridade == ''){ // Valida se o campo Prioridade foi preenchido.
	    	msg += "<li>${i18n.getTranslation('application.label.Prioridade')}</li>";
	    	success = false;
	    }
	    if (sPrazo == ''){ // Valida se o campo Prazo foi preenchido.
	    	msg += "<li>${i18n.getTranslation('application.label.Prazo')}</li>";
	    	success = false;
	    }
	    
	        
	    msg += "</ul>";
	    
	    // Caso o formulário não passe na validação, exibe a mensagem para o usuário, indicando os problemas,
	    if (!success){
		    FLUIGC.message.alert({
			    message: msg,
			    title: "${i18n.getTranslation('application.error.Title.Validate')}",
			    label: "${i18n.getTranslation('application.button.Close')}"
			}, function(el, ev) {
			});
	    }
	    
	    // retorna o resultado da validação.
	    return success;
    }
});