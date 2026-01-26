#INCLUDE "TOTVS.CH"
#INCLUDE "TAFEXECSMARTVIEW.CH"

/*/{Protheus.doc} TAFEXECSMARTVIEW
	Chamada de Objetos de Negócio SmartView após validações de configuração

	@type  		Function
	@author 	Fabio Mendonca
	@since 		27/06/2024
	@version 	1.0
	@param 		cIdObjSmartView, character, Id do Objeto de Negócios
	@Param 		cGrpPerg, character, Grupo de Perguntas usado no objeto
	@Param 		cReleaseMin, character, Release mínima para o objeto
	@Param 		lRunNoInterface, logical, Indica se irá executar sem interface
	@Param 		lWizard, logical, Indica se exibe o wizard de configuração do Smart View, caso o ambiente não esteja preparado
	@return 	lExecSV, logical, Se Objeto de Negócios Smart View conseguiu ser executado com sucesso

	@see 		https://tdn.totvs.com/pages/releaseview.action?pageId=821195415 (Padrão de Nomenclatura objetos Smart View)
				https://tdn.totvs.com/display/TREP/SMART+VIEW (Home Smart View)
/*/
Function TAFEXECSMARTVIEW( cIdObjSmartView as Character, cGrpPerg as Character, cReleaseMin as Character,;
						   lRunNoInterface as Logical, lWizard as Logical ) as Logical

	Local cError  as Character
	Local lExecSV as Logical
	Local lBlind  as Logical

	Default cReleaseMin 	:= "12.1.2310"
	Default lRunNoInterface := .F.
	Default lWizard 		:= .T.

	lExecSV := .F.
	lBlind 	:= IsBlind()

	If GetRpoRelease() >= cReleaseMin

		lExecSV := totvs.framework.smartview.util.isConfig()
		If ( !lExecSV .And. !lBlind ); FWAlertError( STR0001 ); EndIf //"Smart View não configurado."

	Else

		If !lBlind; FWAlertError( STR0002 ); EndIf //"Rotina não disponível"

	EndIf

	If isTAFInCloud()

		If !lBlind; FWAlertError( STR0003 ); EndIf //"Rotina não disponível para ambientes Smart e-Social"
		lExecSV := .F. 

	EndIf 

	If lExecSV	

		If FWSX1Util():ExistPergunte( cGrpPerg )

			lExecSV := totvs.framework.treports.callTReports( cIdObjSmartView,,,,, lRunNoInterface,, lWizard, @cError ) //"rh.sv.taf.esocialconference"

			If !lExecSV

				TAFConOut( "Não foi possível executar o seguinte Objeto de Négocio Smart View: " + cIdObjSmartView )
				TAFConOut( "Erro completo retornado pela função callTReports: " + cError )

			EndIf
		
		Else
		
			If !lBlind; FWAlertError( STR0004, STR0005 ); EndIf //#"Grupo de Perguntas não existe." ##"Smart View"
			lExecSV := .F.
		
		EndIf

	EndIf

Return lExecSV
