#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatBG8
    Classe abstrata para execução de comandos
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Class PEHatBG8 From PEHatGener

	Method New()
    Method montaCabec(oObj)

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe proGuiaAPI
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatBG8

    Default cPedido := ''
    
    _Super:New()
    self:nInd       := 1
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'procedureCode'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} montaCabec

@author  Renan Sakai
@version P12
@since    05.10.18
/*/
//-------------------------------------------------------------------
Method montaCabec(oObj) Class PEHatBG8

	oObj['healthInsurerId']    := self:cCodOpe
	oObj['ansRegistry']        := self:cSusep 
  	BG8->(DbSetOrder(1)) //BG8_FILIAL+BG8_CODINT+BG8_CODGRU+BG8_CODPAD+BG8_CODPSA+BG8_NIVEL
	if BG8->(MsSeek(xFilial("BG8")+self:cChaveBNV))
		BG7->(DbSetOrder(1)) //BG7_FILIAL+BG7_CODINT+BG7_CODGRU
		if BG7->(MsSeek(xFilial("BG7")+BG8->(BG8_CODINT+BG8_CODGRU)))
		    oObj['coverageGroupCode'] := Alltrim(BG7->BG7_CODGRU)
            oObj['coverageGroupName'] := Alltrim(BG7->BG7_DESCRI) 
		endIf
	endIf
    
Return