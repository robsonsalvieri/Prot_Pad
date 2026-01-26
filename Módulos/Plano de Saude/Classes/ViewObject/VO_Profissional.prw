#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Profissional	
	                                      //Executante      //Solicitante
	data cCodOpe  as String HIDDEN        //BD5_OPEEXE      //BD5_OPESOL
	data cEstProf as String HIDDEN        //BD5_ESTEXE      //BD5_ESTSOL
	data cSigCr   as String HIDDEN        //BD5_SIGEXE      //BD5_SIGLA
	data cNumCr   as String HIDDEN        //BD5_REGEXE      //BD5_REGSOL
	data cNomProf as String HIDDEN        //BD5_NOMEXE      //BD5_NOMSOL
	data cCdProf  as String HIDDEN        //BD5_CDPFRE      //BD5_CDPFSO
	data cEspProf as String HIDDEN        //BD5_ESPEXE      //BD5_ESPSOL
	
	method New() Constructor
	
	method setCodOpe()
	method getCodOpe()
	
	method setEstProf()
	method getEstProf()
	
	method setSigCr()
	method getSigCr()
	
	method setNumCr()
	method getNumCr()
	
	method setNomProf()
	method getNomProf()
	
	method setCdProf()
	method getCdProf()
	
	method setEspProf()
	method getEspProf()
	
	
endClass

method new() class VO_Profissional

	::cCodOpe  := ""
	::cEstProf := ""
	::cSigCr   := ""
	::cNumCr   := ""
	::cNomProf := ""
	::cCdProf  := ""
	::cEspProf := ""

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodOpe
Seta o valor cCodOpe
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodOpe(cCodOpe) class VO_Profissional
    ::cCodOpe := cCodOpe
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodOpe
Retorna o valor cCodOpe
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodOpe() class VO_Profissional
return(::cCodOpe)

//-------------------------------------------------------------------
/*/{Protheus.doc} setEstProf
Seta o valor cEstProf
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setEstProf(cEstProf) class VO_Profissional
    ::cEstProf := cEstProf
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getEstProf
Retorna o valor cEstProf
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getEstProf() class VO_Profissional
return(::cEstProf)

//-------------------------------------------------------------------
/*/{Protheus.doc} setSigCr
Seta o valor cSigCr
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSigCr(cSigCr) class VO_Profissional
    ::cSigCr := cSigCr
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getSigCr
Retorna o valor cSigCr
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSigCr() class VO_Profissional
return(::cSigCr)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNumCr
Seta o valor cNumCr
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNumCr(cNumCr) class VO_Profissional
    ::cNumCr := cNumCr
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNumCr
Retorna o valor cNumCr
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNumCr() class VO_Profissional
return(::cNumCr)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNomProf
Seta o valor cNomProf
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNomProf(cNomProf) class VO_Profissional
    ::cNomProf := cNomProf
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNomProf
Retorna o valor cNomProf
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNomProf() class VO_Profissional
return(::cNomProf)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCdProf
Seta o valor cCdProf
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCdProf(cCdProf) class VO_Profissional
    ::cCdProf := cCdProf
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCdProf
Retorna o valor cCdProf
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCdProf() class VO_Profissional
return(::cCdProf)

//-------------------------------------------------------------------
/*/{Protheus.doc} setEspProf
Seta o valor cEspProf
@authorKarine Riquena Limp
@since06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setEspProf(cEspProf) class VO_Profissional
    ::cEspProf := cEspProf
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getEspProf
Retorna o valor cEspProf
@author Karine Riquena Limp
@since 06/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getEspProf() class VO_Profissional
return(::cEspProf)

//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Profissional
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Profissional
Return