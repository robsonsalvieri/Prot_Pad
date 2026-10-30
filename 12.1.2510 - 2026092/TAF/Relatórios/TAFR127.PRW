/*/{Protheus.doc} TAFR127
	Chamada do Objeto de Negócios rh.sv.taf.esocialconference

	@type  		Function
	@author 	Fabio Mendonca
	@since 		27/06/2024
	@version 	1.0

	@see 		https://tdn.totvs.com/pages/viewpage.action?pageId=806775823 ( Objeto de Negócio - eSocialConference - Visão de Dados - Conferência dos eventos do eSocial )
	/*/
Function TAFR127()

	Local cIdObjSmartView 	as Character
	Local cGrpPerg			as Character

	cIdObjSmartView := "rh.sv.taf.esocialconference"
	cGrpPerg		:= "ESOCIAL000"

	TAFEXECSMARTVIEW( cIdObjSmartView, cGrpPerg )

Return
