#Include "Protheus.ch"

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RB_TMS
@autor		: Fabio Marchiori Sampaio
@descricao	: Atualização De Dicionários Para UpdDistr
@since		: Dez./2017
@using		: UpdDistr Para TMS
@review	:
@param		: 	cVersion 	: Versão do Protheus, Ex. ‘12’
				cMode 		: Modo de execução. ‘1’=Por grupo de empresas / ‘2’=Por grupo de empresas + filial (filial completa)
				cRelStart	: Release de partida. Ex: ‘002’ ( Este seria o Release no qual o cliente está)
				cRelFinish	: Release de chegada. Ex: ‘005’ ( Este seria o Release ao final da atualização)
				cLocaliz	: Localização (país). Ex: ‘BRA’
/*/
//---------------------------------------------------------------------------------------------------

Function RBE_TMS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

Default cVersion		:= ''
Default cMode			:= '1'
Default cRelStart		:= "007"
Default cRelFinish		:= ''
Default cLocaliz		:= ''

#IFDEF TOP
	If SuperGetMV("MV_INTTMS",, .F.)
		TmsLogMsg(,'Inicio RBE_TMS: ' + Time())
		 		
		TmsLogMsg(,'Fim RBE_TMS: ' + Time())
	EndIf
#ENDIF
	
Return NIL
