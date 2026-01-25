#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Consulta from VO_Guia
	
	data oContExec     	as Object 	HIDDEN //classe de VO_Contratado
	data oProfExec		as Object	HIDDEN //classe de VO_Profissional
	data oProfSol			as Object	HIDDEN //classe de VO_Profissional
	data aProcedimentos 	as Array 	HIDDEN //classe de VO_Procedimento
	
	method New() Constructor
	
	method setContExec()
	method getContExec()
	
	method setProfExec()
	method getProfExec()
	
	method setProfSol()
	method getProfSol()
	
	method setProcedimentos()
	method getProcedimentos()
	
endClass

method new() class VO_Consulta
	::oContExec	  := VO_Contratado():New()
	::oProfExec  	  := VO_Profissional():New()
	::oProfSol  	  := VO_Profissional():New()
	::aProcedimentos := {}
	_Super:New() 
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setContExec
Seta o valor oContExec
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setContExec(oContExec) class VO_Consulta
    ::oContExec := oContExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getContExec
Retorna o valor oContExec
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getContExec() class VO_Consulta
return(::oContExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfExec
Seta o valor oProfExec
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfExec(oProfExec) class VO_Consulta
    ::oProfExec := oProfExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProfExec
Retorna o valor oProfExec
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProfExec() class VO_Consulta
return(::oProfExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfSol
Seta o valor oProfSol
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfSol(oProfSol) class VO_Consulta
    ::oProfSol := oProfSol
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProfSol
Retorna o valor oProfSol
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProfSol() class VO_Consulta
return(::oProfSol)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcedimento
Seta o valor aProcedimentos
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProcedimentos(aProcedimentos) class VO_Consulta
    ::aProcedimentos := aProcedimentos
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcedimento
Retorna o valor aProcedimentos
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcedimentos() class VO_Consulta
return(::aProcedimentos)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Consulta
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Consulta
Return