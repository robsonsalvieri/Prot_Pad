#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_EquipeProc 
	
	data grauPart     as String HIDDEN
	data profissional as Object HIDDEN //Classe VO_Profissional
	data codNaOpe     as String HIDDEN
	data cpfCont      as String HIDDEN
		
	method New() Constructor
	
	method setGrauPart()
	method getGrauPart()
	
	method setProfissional()
	method getProfissional()
	
	method setCodNaOpe()
	method getCodNaOpe()
	
	method setCpfCont()
	method getCpfCont()
	
endClass

method new() class VO_EquipeProc

	::grauPart     := "" 
	::profissional := VO_Profissional():New()
	::codNaOpe     := "" 
	::cpfCont      := "" 

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setGrauPart
Seta o valor grauPart
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setGrauPart(grauPart) class VO_EquipeProc
    ::grauPart := grauPart
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getGrauPart
Retorna o valor grauPart
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getGrauPart() class VO_EquipeProc
return(::grauPart)


//-------------------------------------------------------------------
/*/{Protheus.doc} setProfissional
Seta o valor profissional
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfissional(profissional) class VO_EquipeProc
    ::profissional := profissional
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getProfissional
Retorna o valor profissional
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProfissional() class VO_EquipeProc
return(::profissional)


//-------------------------------------------------------------------
/*/{Protheus.doc} setCodNaOpe
Seta o valor codNaOpe
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodNaOpe(codNaOpe) class VO_EquipeProc
    ::codNaOpe := codNaOpe
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getCodNaOpe
Retorna o valor codNaOpe
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodNaOpe() class VO_EquipeProc
return(::codNaOpe)


//-------------------------------------------------------------------
/*/{Protheus.doc} setCpfCont
Seta o valor cpfCont
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCpfCont(cpfCont) class VO_EquipeProc
    ::cpfCont :=  cpfCont
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getCpfCont
Retorna o valor cpfCont
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCpfCont() class VO_EquipeProc
return(::cpfCont)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_EquipeProc
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_EquipeProc
Return