#INCLUDE "PROTHEUS.CH"
#define CodOpePad "417505"

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonNasObiAPI
Classes para geracao de registros de pacotes BRC para casos de teste

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS CenMonNasObiAPI

	Data BNW_FILIAL as String
	Data BNW_CODOPE as String
	Data BNW_SEQGUI as String
	Data BNW_TIPO   as String
	Data BNW_DECNUM as String

	Method New() CONSTRUCTOR
	//Method Commit(lInclui)
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonPacotesAPI
Construtor CenMonPacotesAPI

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD NEW() CLASS CenMonNasObiAPI

	self:BNW_FILIAL := xFilial("BNW")
	self:BNW_CODOPE := CodOpePad
	self:BNW_SEQGUI := ""
	self:BNW_TIPO   := ""
	self:BNW_DECNUM := ""

Return self
