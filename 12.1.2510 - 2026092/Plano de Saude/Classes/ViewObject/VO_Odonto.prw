#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Odonto from VO_Guia
	
	/* Campos na tela:
	43~49 Finalização
	*/	
	data oContExec       as Object 	HIDDEN //classe de VO_Contratado
	data oProfExec		as Object	HIDDEN //classe de VO_Profissional
	data oProfSol			as Object	HIDDEN //classe de VO_Profissional
	data cTipAto         as String 	HIDDEN
	data aProcedimentos 	as Array 	HIDDEN //classe de VO_ProcOdonto
		
	method New() Constructor
	
	method setContExec()
	method getContExec()
	
	method setProfExec()
	method getProfExec()
	
	method setProfSol()
	method getProfSol()
	
	method setTipAto()
	method getTipAto()
	
	method setProcedimentos()
	method getProcedimentos()
	
endClass

method new() class VO_Odonto
	
	::oContExec      := VO_Contratado():New()
	::oProfExec  	  := VO_Profissional():New()
	::oProfSol  	  := VO_Profissional():New()  
    ::cTipAto 				:= "1"
	::aProcedimentos := {} //Classe VO_ProcOdonto	   
	
	_Super:New() 

return self

/*/{Protheus.doc} setContExec
Seta o valor contExec
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setContExec(oContExec) class VO_Odonto
    ::oContExec := oContExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getContExec
Retorna o valor contExec
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getContExec() class VO_Odonto
return(::oContExec)


//-------------------------------------------------------------------
/*/{Protheus.doc} setProfExec
Seta o valor oProfExec
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfExec(oProfExec) class VO_Odonto
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
method getProfExec() class VO_Odonto
return(::oProfExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfSol
Seta o valor oProfSol
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfSol(oProfSol) class VO_Odonto
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
method getProfSol() class VO_Odonto
return(::oProfSol)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipAto
Seta o valor TipAto
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipAto(cTipAto) class VO_Odonto
    ::cTipAto := cTipAto
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipAto
Retorna o valor TipAto
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipAto() class VO_Odonto
return(::cTipAto)


//-------------------------------------------------------------------
/*/{Protheus.doc} getProcedimento
Retorna o valor oProcedimento
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcedimentos() class VO_Odonto
return(::aProcedimentos)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcedimento
Seta o valor oProcedimento
@author Karine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProcedimentos(aProcedimentos) class VO_Odonto
    ::aProcedimentos := aProcedimentos
return

//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Odonto
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Odonto
Return