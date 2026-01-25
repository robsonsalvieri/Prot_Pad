#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class CO_Honorario from CO_Guia
		
	method New() Constructor
	method addGuiaHonorario(aDados, aItens)
	method montaHonorario(aDados, aItens)
	
endClass

method new() class CO_Honorario
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} CO_Honorario
Somente para compilar a classe
@author Karine Riquena Limp
@since 25/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function CO_Honorario
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} addGuiaHonorario

Método para adicionar dados da guia de honorário

@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
Method addGuiaHonorario(aDados, aItens) class CO_Honorario
	
	Local oObjGuiHon := NIL	
	oObjGuiHon := self:montaHonorario(aDados, aItens)
	
return oObjGuiHon

//-------------------------------------------------------------------
/*/{Protheus.doc} montaHonorario
Metodo para montar campos pertinentes a guia de honorario
@author Rodrigo Morgon
@since 14/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method montaHonorario(aDados, aItens) class CO_Honorario

	Local oObjHonor	:= VO_Honorario():New()
	Local oObjBoHon	:= BO_Honorario():New() 	
	Local aBoHonor 	:= {}
	Local cNumGuiInt	:= PLSRETDAD( aDados,"NUMLIB","" )
	Local cCodOpe		:= PLSRETDAD( aDados,"OPEMOV","" )
	Local cCodRda    	:= PLSRETDAD( aDados,"CODRDA","" )
	Local dDatPro 	:= PLSRETDAD( aDados,"DATPRO",CtoD("") )
	Local cCodLoc 	:= PLSRETDAD( aDados,"CODLOC","" )
	Local cCodEsp 	:= iif(!empty(PLSRETDAD( aDados,"CBORDA","")),PLSRETDAD( aDados,"CBORDA",""),PLSRETDAD( aDados,"CODESP","" ))
	Local cCnes 		:= PLSRETDAD( aDados,"CNES","" )
	Local cCodPExe   	:= PLSRETDAD( aDados,"CDPFEX","" )
	Local cEspExec  	:= PLSRETDAD( aDados,"ESPEXE","" )
	Local cEspExe   	:= iif(!Empty(cEspExec), cEspExec, PLSRETDAD(aItens[1],"ESPPRO",""))
	Local cCodPSol   	:= ""
	Local cEspSol   	:= PLSRETDAD( aDados,"ESPSOL","" )
	Local cMatric   	:= PLSRETDAD( aDados,"USUARIO","" )
	Local dDtIniFat		:= PLSRETDAD( aDados,"INIFAT","" )
	Local dDtFimFat		:= PLSRETDAD( aDados,"FIMFAT","" )
		
	_Super:montaGuia(oObjHonor, aDados, aItens)		
	
	oObjHonor:setTipAte("07")//Internação
	oObjHonor:setRegFor("1")	
	
	if !Empty(dDtIniFat)
		dDtIniFat := iif(valtype(dDtIniFat) != "D", CTOD(dDtIniFat) ,dDtIniFat)
		oObjHonor:setDtIniFat(dDtIniFat)
	endif
	
	if !Empty(dDtFimFat)	
		dDtFimFat := iif(valtype(dDtFimFat) != "D", CTOD(dDtFimFat) ,dDtFimFat)
		oObjHonor:setDtFimFat(dDtFimFat)
	endif
		
	//Cabeçalho
	aBoHonor := oObjBoHon:getCabec(cNumGuiInt)
	if(len(aBoHonor) > 0)
		oObjHonor:setGuiInt(aBoHonor[1])
		oObjHonor:setGuiPri(aBoHonor[2])
		oObjHonor:setSenha(aBoHonor[3])
		cCodPSol := aBoHonor[4]  	//Buscar o solicitante da Guia de Internação
		if len(aBoHonor) == 5
			oObjHonor:setNraOpe(aBoHonor[5])
		endif
	endif
	
	//Procedimentos
	oObjHonor:setContExec(_Super:addCont(cCodOpe, cCodRda, dDatPro, cCodLoc, cCodEsp, cCnes))
	oObjHonor:setProfExec(_Super:addProf(cCodOpe, cCodPExe, cEspExe))
	oObjHonor:setProfSol(_Super:addProf(cCodOpe, cCodPSol, cEspSol))
	oObjHonor:setProcedimentos(_Super:getLstProcedimentos(cMatric, aItens, oObjHonor))
			
return oObjHonor