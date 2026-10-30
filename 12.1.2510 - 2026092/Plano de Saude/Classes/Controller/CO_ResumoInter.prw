#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class CO_ResumoInter from CO_Guia
		
	method New() Constructor
	method addGuiaResInt(aGuia, aItens)
	method montaResInt(aDados, aItens, lGeraNum, lVerLib, lGerPeg)
		
endClass

method new() class CO_ResumoInter
return self


//-------------------------------------------------------------------
/*/{Protheus.doc} addGuiaResInt
Método para adicionar uma Guia de Resumo de Internação
@author Renan Martins	
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method addGuiaResInt(aGuia, aItens) class CO_ResumoInter

	local oObjGuiaResInt := nil
		
	oObjGuiaResInt := self:montaResInt(aGuia, aItens)
	
return oObjGuiaResInt

//-------------------------------------------------------------------
/*/{Protheus.doc} montaResInt
Método para montar os campos da Guia de Resumo de Internação
@author Renan Martins	
@since 03/2017
@version P12
/*/
//-------------------------------------------------------------------
method montaResInt(aDados, aItens, lGeraNum, lVerLib, lGerPeg) class CO_ResumoInter
local objResInt     := VO_ResumoInter():New()
local cCodOpe       := PLSRETDAD( aDados,"OPEMOV","" )
local cCodRda       := PLSRETDAD( aDados,"CODRDA","" )
local dDatPro 		:= PLSRETDAD( aDados,"DATPRO", CtoD("") )
local cCodLoc 		:= PLSRETDAD( aDados,"CODLOC","" )
local cCodEsp 		:= iif(!empty(PLSRETDAD( aDados,"CBORDA","")),PLSRETDAD( aDados,"CBORDA",""),PLSRETDAD( aDados,"CODESP","" ))
local cCnes 		:= PLSRETDAD( aDados,"CNES","" )
local cMatric       := PLSRETDAD( aDados,"USUARIO","" )
default lGeraNum    := .T.
default lVerLib     := .T.
default lGerPeg     := .T.

   	_Super:montaGuia(objResInt, aDados, aItens, lGeraNum, lVerLib, lGerPeg)
   	
   	//VERIFICAR NO SISTEMA DADOS DO CONTRATADO EXECUTANTE
   	objResInt:setContExec(_Super:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))//classe VO_Contratado
	//objResInt:setProfSol(_Super:addProf(cCodOpe, cCodPSol, cEspSol))
	//objResInt:setProfExec(_Super:addProf(cCodOpe, cCodPExe, cEspExe))
	//objResInt:setIndCli (PLSRETDAD( aDados,"INDCLI","" ))
     objResInt:setGrpInt (PLSRETDAD( aDados,"TIPINT","" ))	
     objResInt:setTpInt ("0" + PLSRETDAD( aDados,"TIPINT","" ))
     objResInt:setRegInt(PLSRETDAD( aDados,"REGINT","" ))
     objResInt:setNumGuiSolInt( PLSRETDAD( aDados,"NUMSOL","" ) )
     objResInt:setCid2( PLSRETDAD( aDados,"CID2","" ) )
     objResInt:setCid3( PLSRETDAD( aDados,"CID3","" ) )
     objResInt:setCid4( PLSRETDAD( aDados,"CID4","" ) )
     objResInt:setCid4( PLSRETDAD( aDados,"CID4","" ) )
     objResInt:setCidObito( PLSRETDAD( aDados,"CID5","" ) )
     objResInt:setMotEncer( PLSRETDAD( aDados,"TIPSAI","" )  )
     objResInt:setDtIniFat( ctod(PLSRETDAD( aDados,"INIFAT","" ) ))
     objResInt:setHrIniFat( PLSRETDAD( aDados,"HRINIFAT","" ) )
     objResInt:setDtFimFat( ctod(PLSRETDAD( aDados,"FIMFAT","" ) ))
     objResInt:setHrFimFat( PLSRETDAD( aDados,"HRFIMFAT","" ) )
     objResInt:setobsFim  ( PLSRETDAD( aDados,"OBSERVAC","" ) )
     objResInt:settpCom   ( PLSRETDAD( aDados,"PADINT","" ) )
     objResInt:setpadCon  ( PLSRETDAD( aDados,"PADCON","" ) )
     
	//objResInt:setNumGuiSolInt (PLSRETDAD( aDados,"NUMSOL","" ))
	objResInt:setProcedimentos(_Super:getLstProcedimentos(cMatric, aItens, objResInt))
			
return objResInt


//-------------------------------------------------------------------
/*/{Protheus.doc} CO_ResumoInter
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function CO_ResumoInter
Return
