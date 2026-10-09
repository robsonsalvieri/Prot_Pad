#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Dente
	
	data elemDent as String HIDDEN
	data condClin as String HIDDEN
	
	method New() Constructor
	
	method setElemDent()
	method getElemDent()

	method setCondClin()
	method getCondClin()

endClass

method new() class VO_Dente

	::elemDent := ""
	::condClin := ""

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setElemDent
Seta o valor elemDent
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setElemDent(elemDent) class VO_Dente
    ::elemDent := elemDent
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getElemDent
Retorna o valor elemDent
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getElemDent() class VO_Dente
return(::elemDent)


//-------------------------------------------------------------------
/*/{Protheus.doc} setCondClin
Seta o valor condClin
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCondClin(condClin) class VO_Dente
    ::condClin := condClin
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getCondClin
Retorna o valor condClin
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCondClin() class VO_Dente
return(::condClin)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Dente
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Dente
Return