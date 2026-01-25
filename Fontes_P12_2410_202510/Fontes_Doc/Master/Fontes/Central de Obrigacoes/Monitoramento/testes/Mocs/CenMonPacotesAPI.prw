#INCLUDE "PROTHEUS.CH"
#define CodOpePad "417505"

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonPacotesAPI
Classes para geracao de registros de pacotes BRC para casos de teste

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS CenMonPacotesAPI

	Data BRC_FILIAL as String
	Data BRC_CODOPE as String
	Data BRC_SEQGUI as String
	Data BRC_SEQITE as String
	Data BRC_CDTBIT as String
	Data BRC_CDPRIT as String
	Data BRC_QTPRPC as Float

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
METHOD NEW() CLASS CenMonPacotesAPI

	self:BRC_FILIAL	:= xFilial("BRC")
	self:BRC_CODOPE := CodOpePad
	self:BRC_SEQGUI := ""
	self:BRC_SEQITE := ""
	self:BRC_CDTBIT := ""
	self:BRC_CDPRIT := ""
	self:BRC_QTPRPC := 0

Return self