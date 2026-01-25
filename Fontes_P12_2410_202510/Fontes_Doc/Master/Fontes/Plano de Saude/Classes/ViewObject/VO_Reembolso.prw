#include 'totvs.ch'

CLASS VO_Reembolso FROM VO_Guia

	data aProcedimentos as Array   HIDDEN //Classe VO_ProcGeral
	data oContExec     as Object  HIDDEN //classe de VO_Contratado
	data oProfExec     as Object  HIDDEN //classe de VO_Profissional
	data oProfSol	     as Object  HIDDEN //classe de VO_Profissional

	METHOD New() CONSTRUCTOR

	method setProcedimentos()
	method getProcedimentos()
	
	method setContExec()
	method getContExec()
	
	method setProfExec()
	method getProfExec()
	
	method setProfSol()
	method getProfSol()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS VO_Reembolso

	::oContExec		:= VO_Contratado():New()
	::oProfExec  	:= VO_Profissional():New()
	::oProfSol  	:= VO_Profissional():New()	
	::aProcedimentos:= {}
	
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcedimentos
Seta o valor procedimentos
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProcedimentos(aProcedimentos) class VO_Reembolso
    ::aProcedimentos := aProcedimentos
return

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcedimentos
Retorna o valor procedimentos
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcedimentos() class VO_Reembolso
return(::aProcedimentos)

//-------------------------------------------------------------------
/*/{Protheus.doc} setContExec
Seta o valor oContExec
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method setContExec(oContExec) class VO_Reembolso
    ::oContExec := oContExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getContExec
Retorna o valor oContExec
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method getContExec() class VO_Reembolso
return(::oContExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfExec
Seta o valor oProfExec
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfExec(oProfExec) class VO_Reembolso
    ::oProfExec := oProfExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProfExec
Retorna o valor oProfExec
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProfExec() class VO_Reembolso
return(::oProfExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfSol
Seta o valor oProfSol
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfSol(oProfSol) class VO_Reembolso
    ::oProfSol := oProfSol
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProfSol
Retorna o valor oProfSol
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProfSol() class VO_Reembolso
return(::oProfSol)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Reembolso
Somente para compilar a classe
@author Rodrigo Morgon
@since 28/11/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Reembolso
Return