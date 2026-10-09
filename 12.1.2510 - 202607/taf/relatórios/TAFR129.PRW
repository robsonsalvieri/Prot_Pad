/*/{Protheus.doc} TAFR129
	Chamada do Objeto de Negócios rh.sv.taf.esocialtransmition

	@type  		Function
	@author 	Fabio Mendonca
	@since 		28/06/2024
	@version 	1.0

	@see 		https://tdn.totvs.com/pages/viewpage.action?pageId=814529706 ( Objeto de Negócio - eSocialworkerdashboard - Visão de Dados - Painel do trabalhador )
	/*/
Function TAFR129()

	Local cIdObjSmartView 	as Character
	Local cGrpPerg			as Character

	cIdObjSmartView := "rh.sv.taf.esocialworkerdashboard"
	cGrpPerg		:= "ESOCIAL001"

	TAFEXECSMARTVIEW( cIdObjSmartView, cGrpPerg )

Return
