#INCLUDE "TOTVS.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

class CO_Consulta from CO_Guia
		
	method New() Constructor
	method montaConsulta(aDados, aItens)
	method addGuiaConsulta(aDados, aItens)
			
endClass

method new() class CO_Consulta
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} addGuiaConsulta
Metodo para adicionar uma consulta
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addGuiaConsulta(aDados, aItens) class CO_Consulta
	LOCAL oObjGuiaConsulta := nil	
	oObjGuiaConsulta := self:montaConsulta(aDados, aItens)
return oObjGuiaConsulta

//-------------------------------------------------------------------
/*/{Protheus.doc} montaConsulta
Metodo para montar campos pertinentes a guia de consulta apenas
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method montaConsulta(aDados, aItens) class CO_Consulta
local objConsulta := VO_Consulta():New()

local cCodOpe		:= PLSRETDAD( aDados,"OPEMOV","" )
local cCodRda		:= PLSRETDAD( aDados,"CODRDA","" )
local dDatPro 		:= PLSRETDAD( aDados,"DATPRO", PLSRETDAD( aDados,"DTINIFAT",CtoD("") ) )
local cCodLoc 		:= PLSRETDAD( aDados,"CODLOC","" )
local cCodEsp 		:= iif(!empty(PLSRETDAD( aDados,"CBORDA","")),PLSRETDAD( aDados,"CBORDA",""),PLSRETDAD( aDados,"CODESP","" ))
local cCnes 		:= PLSRETDAD( aDados,"CNES","" )
local cCodPExe		:= PLSRETDAD( aDados,"CDPFEX","" )
local cEspExec		:= PLSRETDAD( aDados,"ESPEXE","" )
local cEspExe 		:= iif(!Empty(cEspExec), cEspExec, PLSRETDAD(aItens[1],"ESPPRO",""))
local cCodPSol		:= PLSRETDAD( aDados,"CDPFSO","" )
local cEspSol 		:= PLSRETDAD( aDados,"ESPSOL","" )
local cMatric		:= PLSRETDAD( aDados,"USUARIO","" )

	_Super:montaGuia(objConsulta, aDados, aItens)
	objConsulta:setTipCon(PLSRETDAD( aDados,"TIPCON","" ))
	objConsulta:setContExec(_Super:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))
	objConsulta:setProfExec(_Super:addProf(cCodOpe, cCodPExe, cEspExe))
	objConsulta:setProfSol (_Super:addProf(cCodOpe, cCodPSol, cEspSol))
	objConsulta:setProcedimentos(_Super:getLstProcedimentos(cMatric, aItens, objConsulta))
			
return objConsulta
//-------------------------------------------------------------------
/*/{Protheus.doc} CO_Consulta
Somente para compilar a classe
@author Roberto Vanderlei
@since 01/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Function CO_Consulta                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
Return
