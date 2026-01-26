#INCLUDE "PROTHEUS.CH"
#define CodOpePad "417505"

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonEventosAPI 
Classes para geracao de registros de eventos BRB para casos de teste

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS CenMonEventosAPI 

    Data BRB_FILIAL	as String
    Data BRB_CODOPE	as String
    Data BRB_SEQGUI	as String
    Data BRB_SEQITE	as String
    Data BRB_CODTAB	as String
    Data BRB_CODGRU	as String
    Data BRB_CODPRO	as String
    Data BRB_CDDENT	as String
    Data BRB_CDREGI	as String
    Data BRB_CDFACE	as String	
    Data BRB_QTDINF	as Float
    Data BRB_VLRINF	as Float
    Data BRB_QTDPAG	as Float
    Data BRB_VLPGPR	as Float
    Data BRB_VLRPGF	as Float
    Data BRB_CNPJFR	as String
    Data BRB_VLRCOP	as Float
    Data BRB_VLRGLO	as Float
    Data BRB_PACOTE	as String
	Data Pacotes    as Array

    Method New() CONSTRUCTOR
	Method setPacote(oPacote)
	//Method Commit(lInclui)

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonEventosAPI
Construtor CenMonEventosAPI

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD NEW() CLASS CenMonEventosAPI

    self:BRB_FILIAL	:= xFilial("BRB")
    self:BRB_CODOPE	:= CodOpePad
    self:BRB_SEQGUI	:= ""
    self:BRB_SEQITE	:= ""
    self:BRB_CODTAB	:= ""
    self:BRB_CODGRU	:= ""
    self:BRB_CODPRO	:= ""
    self:BRB_CDDENT	:= ""
    self:BRB_CDREGI	:= ""
    self:BRB_CDFACE	:= ""
    self:BRB_QTDINF	:= 0
    self:BRB_VLRINF	:= 0
    self:BRB_QTDPAG	:= 0
    self:BRB_VLPGPR	:= 0
    self:BRB_VLRPGF	:= 0
    self:BRB_CNPJFR	:= ""
    self:BRB_VLRCOP	:= 0
    self:BRB_VLRGLO	:= 0
    self:BRB_PACOTE	:= "0"
	self:Pacotes    := {}

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} Commit
Commit CenMonEventosAPI

@author renan.almeida
@since 03/09/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Method setPacote(oPacote) Class CenMonEventosAPI
	aadd(self:Pacotes,oPacote)
Return