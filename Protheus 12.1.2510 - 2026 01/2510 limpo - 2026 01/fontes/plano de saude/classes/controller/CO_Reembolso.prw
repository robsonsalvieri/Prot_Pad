#include 'totvs.ch'
#INCLUDE "FWMVCDEF.CH"

CLASS CO_Reembolso FROM CO_Guia

	METHOD New() CONSTRUCTOR
	METHOD addGuiaReembolso(aDados, aItens)
	METHOD montaReembolso(aDados, aItens)
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS CO_Reembolso
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} addGuiaReembolso

Método para adicionar dados da guia de honorário

@author Rodrigo Morgon
@since 25/11/2016
@version P12
/*/
//-------------------------------------------------------------------
Method addGuiaReembolso(aDados, aItens) class CO_Reembolso
	
	Local oObjGuiRee := NIL	
	oObjGuiRee := self:montaReembolso(aDados, aItens)
	
return oObjGuiRee

//-------------------------------------------------------------------
/*/{Protheus.doc} montaReembolso
Metodo para montar campos pertinentes a guia de reembolso
@author Rodrigo Morgon
@since 25/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method montaReembolso(aDados, aItens) class CO_Reembolso

	Local oObjReemb	:= VO_Reembolso():New()
	
	Local cCodOpe		:= PLSRETDAD( aDados,"OPEMOV","" )
	Local cCodRda    	:= PLSRETDAD( aDados,"CODRDA","" )
	Local dDatPro 	:= PLSRETDAD( aDados,"DATPRO",CtoD("") )
	Local cCodLoc 	:= PLSRETDAD( aDados,"CODLOC","" )
	Local cCodEsp 	:= PLSRETDAD( aDados,"CODESP","" )
	Local cCnes 		:= PLSRETDAD( aDados,"CNES","" )
	Local cCodPExe   	:= PLSRETDAD( aDados,"CDPFEX","" )
	Local cEspExec  	:= PLSRETDAD( aDados,"ESPEXE","" )
	Local cEspExe   	:= iif(!Empty(cEspExec), cEspExec, PLSRETDAD(aItens[1],"ESPPRO",""))
	Local cCodPSol   	:= PLSRETDAD( aDados,"CDPFSO","" )
	Local cEspSol   	:= PLSRETDAD( aDados,"ESPSOL","" )
	Local cMatric   	:= PLSRETDAD( aDados,"USUARIO","" )
	
	//Monta cabeçalho da guia de reembolso (BD5)
	_Super:montaGuia(oObjReemb, aDados, aItens)		
			
	//Monta procedimentos da guia de reembolso (BD6)
	oObjReemb:setContExec(_Super:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))
	oObjReemb:setProfExec(_Super:addProf(cCodOpe, cCodPExe, cEspExe))
	oObjReemb:setProfSol(_Super:addProf(cCodOpe, cCodPSol, cEspSol))
	oObjReemb:setProcedimentos(_Super:getLstProcedimentos(cMatric, aItens, oObjReemb))
		
return oObjReemb
