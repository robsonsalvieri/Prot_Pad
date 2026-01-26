#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class CO_Sadt from CO_Guia
		
	method New() Constructor
	method montaSadt(aGuia, aItens)
	method addGuiaSadt(aGuia, aItens)
				
endClass

method new() class CO_Sadt
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} addGuiaSadt
Metodo para adicionar uma Sadt
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method addGuiaSadt(aGuia, aItens) class CO_Sadt

local oObjGuiaSadt := nil
	
oObjGuiaSadt := self:montaSadt(aGuia, aItens)
	
return oObjGuiaSadt

//-------------------------------------------------------------------
/*/{Protheus.doc} montaSadt
Metodo para montar campos pertinentes a guia de sadt apenas
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method montaSadt(aDados, aItens) class CO_Sadt
local objSadt := VO_Sadt():New()

local cCodOpe		:= PLSRETDAD( aDados,"OPEMOV","" )
local cCodRda       := PLSRETDAD( aDados,"CODRDA","" )
local dDatPro 		:= PLSRETDAD( aDados,"DATPRO", PLSRETDAD( aDados,"DTINIFAT",CtoD("") ) )
local cCodLoc 		:= PLSRETDAD( aDados,"CODLOC","" )
local cCodEsp 		:= iif(!empty(PLSRETDAD( aDados,"CBORDA","")),PLSRETDAD( aDados,"CBORDA",""),PLSRETDAD( aDados,"CODESP","" ))
local cCnes 		:= PLSRETDAD( aDados,"CNES","" )
local cCodPExe      := PLSRETDAD( aDados,"CDPFEX","" )
local cEspExec      := PLSRETDAD( aDados,"ESPEXE","" )
local cEspExe       := iif(!Empty(cEspExec), cEspExec, PLSRETDAD(aItens[1],"ESPPRO",""))
local cCodPSol      := PLSRETDAD( aDados,"CDPFSO","" )
local cEspSol       := PLSRETDAD( aDados,"ESPSOL","" )
local cMatric       := PLSRETDAD( aDados,"USUARIO","" )

_Super:montaGuia(objSadt, aDados, aItens)

//VERIFICAR NO SISTEMA DADOS DO CONTRATADO EXECUTANTE
objSadt:setContExec(_Super:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))//classe VO_Contratado
objSadt:setProfSol(_Super:addProf(cCodOpe, cCodPSol, cEspSol))
objSadt:setProfExec(_Super:addProf(cCodOpe, cCodPExe, cEspExe))
objSadt:setIndCli (PLSRETDAD( aDados,"INDCLI","" ))
objSadt:setTipCon (PLSRETDAD( aDados,"TIPCON","" ))
objSadt:setProcedimentos(_Super:getLstProcedimentos(cMatric, aItens, objSadt))

objSadt:setdDtRlS ( iif(empty(PLSRETDAD(aDados,"DTRLZ" ,"" )) , ctod(""), PLSRETDAD(aDados,"DTRLZ" ,"" )) ) 
objSadt:setdDtRlS2( iif(empty(PLSRETDAD(aDados,"DTRLZ2" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ2" ,"" )) )
objSadt:setdDtRlS3( iif(empty(PLSRETDAD(aDados,"DTRLZ3" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ3" ,"" )) )
objSadt:setdDtRlS4( iif(empty(PLSRETDAD(aDados,"DTRLZ4" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ4" ,"" )) )
objSadt:setdDtRlS5( iif(empty(PLSRETDAD(aDados,"DTRLZ5" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ5" ,"" )) )
objSadt:setdDtRlS6( iif(empty(PLSRETDAD(aDados,"DTRLZ6" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ6" ,"" )) )
objSadt:setdDtRlS7( iif(empty(PLSRETDAD(aDados,"DTRLZ7" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ7" ,"" )) )
objSadt:setdDtRlS8( iif(empty(PLSRETDAD(aDados,"DTRLZ8" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ8" ,"" )) )
objSadt:setdDtRlS9( iif(empty(PLSRETDAD(aDados,"DTRLZ9" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ9" ,"" )) )
objSadt:setdDtRlS1( iif(empty(PLSRETDAD(aDados,"DTRLZ1" ,"" )), ctod(""), PLSRETDAD(aDados,"DTRLZ1" ,"" )) )
			
return objSadt
