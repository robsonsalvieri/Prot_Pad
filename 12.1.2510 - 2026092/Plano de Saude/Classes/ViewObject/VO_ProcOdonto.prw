#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_ProcOdonto from VO_Procedimento
	
	data cDenReg     as String  HIDDEN //BD6->BD6_DENREG
	data cFaDent     as String  HIDDEN //BD6->BD6_FADENT
	data cDesReg     as String  HIDDEN //BD6->BD6_DESREG
	data cFacDes     as String  HIDDEN //BD6->BD6_FACDES
	data nQtdUS      as Numeric HIDDEN
	data nValFran    as Numeric HIDDEN
	data lAutorizado as Logical HIDDEN
	
	data oObjProcedimento as Object HIDDEN //Apontando para um procedimento. 
		
	method New() Constructor

	method setDenReg()
	method getDenReg()
	
	method setFaDent()
	method getFaDent()
	
	method setDesReg()
	method getDesReg()
	
	method setFacDes()
	method getFacDes()
	
	method setQtdUS()
	method getQtdUS()
	
	method setValFran()
	method getValFran()
	
	method setAutorizado()
	method getAutorizado()

endClass

method new() class VO_ProcOdonto

	::cDenReg     := ""
	::cFaDent     := ""
	::cDesReg     := ""
	::cFacDes     := ""
	::nQtdUS      := 0
	::nValFran    := 0
	::lAutorizado := .F.
	_Super:New()               

return self


//-------------------------------------------------------------------
/*/{Protheus.doc} setDenReg
Seta o valor cDenReg
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDenReg(cDenReg) class VO_ProcOdonto
    ::cDenReg := cDenReg
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDenReg
Retorna o valor cDenReg
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDenReg() class VO_ProcOdonto
return(::cDenReg)

//-------------------------------------------------------------------
/*/{Protheus.doc} setFaDent
Seta o valor cFaDent
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setFaDent(cFaDent) class VO_ProcOdonto
    ::cFaDent := cFaDent
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getFaDent
Retorna o valor cFaDent
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getFaDent() class VO_ProcOdonto
return(::cFaDent)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDesReg
Seta o valor cDesReg
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDesReg(cDesReg) class VO_ProcOdonto
    ::cDesReg := cDesReg
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDesReg
Retorna o valor cDesReg
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDesReg() class VO_ProcOdonto
return(::cDesReg)

//-------------------------------------------------------------------
/*/{Protheus.doc} setFacDes
Seta o valor cFacDes
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setFacDes(cFacDes) class VO_ProcOdonto
    ::cFacDes := cFacDes
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getFacDes
Retorna o valor cFacDes
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getFacDes() class VO_ProcOdonto
return(::cFacDes)

//-------------------------------------------------------------------
/*/{Protheus.doc} setQtdUS
Seta o valor nQtdUS
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setQtdUS(nQtdUS) class VO_ProcOdonto
    ::nQtdUS := nQtdUS
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdUS
Retorna o valor nQtdUS
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getQtdUS() class VO_ProcOdonto
return(::nQtdUS)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValFran
Seta o valor nValFran
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValFran(nValFran) class VO_ProcOdonto
    ::nValFran := nValFran
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValFran
Retorna o valor nValFran
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValFran() class VO_ProcOdonto
return(::nValFran)

//-------------------------------------------------------------------
/*/{Protheus.doc} setAutorizado
Seta o valor lAutorizado
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setAutorizado(lAutorizado) class VO_ProcOdonto
    ::lAutorizado := lAutorizado
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getAutorizado
Retorna o valor lAutorizado
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getAutorizado() class VO_ProcOdonto
return(::lAutorizado)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_ProcOdonto
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_ProcOdonto
Return