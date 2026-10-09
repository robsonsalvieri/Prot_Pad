/*/{Protheus.doc} TAFR128
	Chamada do Objeto de Negócios rh.sv.taf.esocialtransmition

	@type  		Function
	@author 	Fabio Mendonca
	@since 		28/06/2024
	@version 	1.0

	@see 		https://tdn.totvs.com/pages/viewpage.action?pageId=811698718 ( Objeto de Negócio - eSocialTransmition - Visão de Dados - Eventos Transmitidos do eSocial )
	/*/
Function TAFR128()

	Local cIdObjSmartView 	as Character
	Local cGrpPerg			as Character

	cIdObjSmartView := "rh.sv.taf.esocialtransmition"
	cGrpPerg		:= "ESOCIAL002"

	TAFEXECSMARTVIEW( cIdObjSmartView, cGrpPerg )

Return
