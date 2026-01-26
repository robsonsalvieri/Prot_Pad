<div id="wcmConsultivo_${instanceId}" class="super-widget wcm-widget-class fluig-style-guide" data-params="wcmConsultivo.instance()">
	<h2>${i18n.getTranslation('application.label.title')}</h2>
	<hr />
	<form class="form-horizontal" role="form">
		<input type="hidden" id="hiddenLoading_${instanceId}"></input>
		<div class="form-group">
			<label for="sAssuntoJuridico_${instanceId}" class="col-md-2 control-label">${i18n.getTranslation('application.label.AssJur')}*</label>
			<div class="col-md-10">
				<select class="form-control" id="sAssuntoJuridico_${instanceId}" data-select-change data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.AssJur')}">
					<option value="">${i18n.getTranslation('application.placeholder.AssuntosJuridicos')}</option>
				</select>
			</div>
		</div>
		<div class="form-group">
			<label for="sTipoSol_${instanceId}" class="col-md-2 control-label">${i18n.getTranslation('application.label.TipoSol')}*</label>
			<div class="col-md-10">
				<select class="form-control" id="sTipoSol_${instanceId}" data-select-change data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.TipoSol')}">
					<option value="">${i18n.getTranslation('application.placeholder.TipoSol')}</option>
				</select>
			</div>
		</div>
		<div class="form-group">
			<input type="hidden" id="cdGrupoResponsavel_${instanceId}"></input>
			<label for="sGrupoResponsavel_${instanceId}" class="col-md-2 control-label">${i18n.getTranslation('application.label.GrupoResp')}*</label>
			<div class="col-md-10 ">
				<div class="input-group">
					<input type="text" class="form-control" id="sGrupoResponsavel_${instanceId}" placeholder="${i18n.getTranslation('application.placeholder.GrupoResp')}" readonly data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Grupo.text')}"></input>
					<span class="input-group-addon fs-cursor-pointer" id="zoomGrupoResponsavel_${instanceId}" data-open-zoom-Grupo>
						<span class="fluigicon fluigicon-search zoomCustomer" data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Grupo.search')}"></span>
					</span>
					<span class="input-group-addon fs-cursor-pointer" id="clearGrupoResponsavel_${instanceId}" data-clear-zoom-Grupo>
						<span class="fluigicon fluigicon-trash zoomCustomer" data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Grupo.trash')}"></span>
					</span>
				</div>
			</div>
		</div>
		<div class="form-group">
			<input type="hidden" id="cdUsuarioResponsavel_${instanceId}"></input>
			<label for="sUsuarioResponsavel_${instanceId}" class="col-md-2 control-label">${i18n.getTranslation('application.label.UsuarioResp')}*</label>
			<div class="col-md-10 ">
				<div class="input-group">
					<input type="text" class="form-control" id="sUsuarioResponsavel_${instanceId}" placeholder="${i18n.getTranslation('application.placeholder.UsuarioResp')}" readonly data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Usuario.text')}"></input>
					<span class="input-group-addon fs-cursor-pointer" id="zoomUsuarioResponsavel_${instanceId}" data-open-zoom-usuario>
						<span class="fluigicon fluigicon-search zoomCustomer" data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Usuario.search')}"></span>
					</span>
					<span class="input-group-addon fs-cursor-pointer" id="clearUsuarioResponsavel_${instanceId}" data-clear-zoom-usuario>
						<span class="fluigicon fluigicon-trash zoomCustomer" data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Usuario.trash')}"></span>
					</span>
				</div>
			</div>
		</div>
		<div class="form-group">
			<label for="sPrioridade_${instanceId}" class="col-md-2 control-label">${i18n.getTranslation('application.label.Prioridade')}*</label>
			<div class="col-md-3">
				<input type="text" class="form-control" id="sPrioridade_${instanceId}" placeholder="${i18n.getTranslation('application.placeholder.Prioridade')}" data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Prioridade')}"></input>
			</div>
			<label for="sPrazo_${instanceId}" class="col-md-2 control-label">${i18n.getTranslation('application.label.Prazo')}*</label>
			<div class="col-md-3">
				<input type="text" class="form-control" id="sPrazo_${instanceId}" placeholder="${i18n.getTranslation('application.placeholder.Prazo')}" data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Prazo')}"></input>
			</div>
		</div>
		<div class="form-group">
			<label for="sPrazoEnc_${instanceId}" class="col-md-2 control-label">${i18n.getTranslation('application.label.PrazoEnc')}*</label>
			<div class="col-md-3">
				<input type="text" class="form-control" id="sPrazoEnc_${instanceId}" placeholder="${i18n.getTranslation('application.placeholder.PrazoEnc')}" data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.PrazoEnc')}"></input>
			</div>
		</div>
		<div class="form-group">
	        <div class="col-sm-offset-2 col-sm-10">
            	<button class="btn btn-default" data-save-button data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Save')}">${i18n.getTranslation('application.button.Save')}</button>
            	<button class="btn btn-default" data-clear-button data-toggle="tooltip" data-placement="top" title="${i18n.getTranslation('application.tooltip.Clear')}">${i18n.getTranslation('application.button.Clear')}</button>
        	</div>
		</div>
		<script type="text/template" class="template_datatable_consul">
		    <tr>
		    	<td>{{metadata#id}}</td>
		    	<td>{{cdAssJur}}</td>
		    	<td>{{sAssJur}}</td>
		    	<td>{{cdTipoSol}}</td>
		    	<td>{{sTipoSol}}</td>
		    	<td>{{cdGrupo}}</td>
		    	<td>{{sGrupo}}</td>		    	
		    	<td>{{cdUser}}</td>
		    	<td>{{sUser}}</td>
		    	<td>{{sPrioridade}}</td>
		    	<td>{{sPrazo}}</td>
		    	<td>{{sPrazoEnc}}</td>
		    
		        <td class="center-align">
		        	<span class="btn btn-xs" id="deleteRow_{{metadata#id}}" data-delete-row data-toggle="tooltip" data-placement="left" title="${i18n.getTranslation('application.tooltip.Delete')}">
						<span class="fluigicon fluigicon-trash zoomCustomer"></span>
					</span>
				</td>
		    </tr>
		</script>
		<div class="form-group">
			<div class="col-sm-12" id="dtConsultivo_${instanceId}"></div>
		</div>
	</form>
</div>
<script type="text/javascript" src="/webdesk/vcXMLRPC.js"></script>
<script type="text/javascript" src="/SIGAJURI_Consultivo/resources/js/mascaras.js"></script>