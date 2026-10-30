#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class CO_Odonto from CO_Guia
		
	method New() Constructor
	method montaOdonto(aGuia, aItens)
	method addGuiaOdonto(aGuia, aItens)

endClass

method new() class CO_Odonto
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} CO_Odonto
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function CO_Odonto
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} addGuiaOdonto
Metodo para adicionar uma guia Odonto
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addGuiaOdonto(aGuia, aItens) class CO_Odonto

local oObjGuiaOdonto := nil
	
	oObjGuiaOdonto := self:montaOdonto(aGuia, aItens)	
	
return oObjGuiaOdonto

//-------------------------------------------------------------------
/*/{Protheus.doc} montaSadt
Metodo para montar campos pertinentes a guia de odonto apenas
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method montaOdonto(aDados, aItens) class CO_Odonto
local objOdonto := VO_Odonto():New()
local cMatric       := PLSRETDAD( aDados,"USUARIO","" )

local cCodOpe			:= PLSRETDAD( aDados,"OPEMOV","" )
local cCodRda        := PLSRETDAD( aDados,"CODRDA","" )
local dDatPro 		:= PLSRETDAD( aDados,"DATPRO", PLSRETDAD( aDados,"DTINIFAT",CtoD("") ) )
local cCodLoc 		:= PLSRETDAD( aDados,"CODLOC","" )
local cCodEsp 		:= iif(!empty(PLSRETDAD( aDados,"CBORDA","")),PLSRETDAD( aDados,"CBORDA",""),PLSRETDAD( aDados,"CODESP","" ))
local cCnes 			:= PLSRETDAD( aDados,"CNES","" )

local cCodPExe       := PLSRETDAD( aDados,"CDPFEX","" )
local cEspExec       := PLSRETDAD( aDados,"ESPEXE","" )
local cEspExe        := iif(!Empty(cEspExec), cEspExec, PLSRETDAD(aItens[1],"ESPPRO",""))
local cCodPSol       := PLSRETDAD( aDados,"CDPFSO","" )
local cEspSol        := PLSRETDAD( aDados,"ESPSOL","" )
local cEspRSol       := PLSRETDAD( aDados,"CODESP","" )

	if ( empty(cEspSol) .and. !empty(cEspRSol) )
		cEspSol := cEspRSol
	endif	

   	_Super:montaGuia(objOdonto, aDados, aItens)
   	
   	objOdonto:setProfExe(_Super:addProf(cCodOpe, cCodPExe, cEspExe))   
   		
	objOdonto:setProfSol(_Super:addProf(cCodOpe, cCodPSol, cEspSol))
	
	objOdonto:setContExec(_Super:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))//classe VO_Contratado
	
	objOdonto:setProcedimentos(_Super:getProcOdo(cMatric, aItens, objOdonto))

	if Empty(objOdonto:getTipAto())
		objOdonto:setTipAto("1")	
	endif

	/*Tratamento no numero da impressão Odonto */
	if Empty(objOdonto:getNumImp())
		objOdonto:setNumImp(objOdonto:getCodOpe() + objOdonto:getAnoPag() + objOdonto:getMesPag() + objOdonto:getNumAut())	
	endif
	
return objOdonto