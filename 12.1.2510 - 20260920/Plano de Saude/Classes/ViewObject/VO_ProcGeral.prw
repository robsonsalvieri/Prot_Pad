#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_ProcGeral from VO_Procedimento
	
	data hrIni      as String  HIDDEN //BD6_HORPRO
	data hrFim      as String  HIDDEN //BD6_HORFIM
	data valTot     as Numeric HIDDEN //***** - não encontrado
	data redAcresc  as Numeric HIDDEN //BD6_PRPRRL
	data tecUtil    as String  HIDDEN //BD6_TECUTI
	data viaAcesso  as String  HIDDEN //BD6_VIA
	data equipeProc as Array   HIDDEN //Classe VO_EquipeProc
	
	method New() Constructor
	
	method setHrIni()
	method getHrIni()
	
	method setHrFim()
	method getHrFim()
	
	method setValTot()
	method getValTot()
	
	method setRedAcresc()
	method getRedAcresc()
	
	method setTecUtil()
	method getTecUtil()
	
	method setViaAcesso()
	method getViaAcesso()
	
	method setEquipeProc()
	method getEquipeProc()
	
endClass

method new() class VO_ProcGeral

	::hrIni      := ""
	::hrFim      := ""
	::valTot     := 0
	::redAcresc  := 0
	::tecUtil    := ""
	::viaAcesso  := ""
	::equipeProc := {} //Classe VO_EquipeProc
	
	//atributos da superclasse VO_Procedimento
	_Super:New() 
	
	//Campos da BD6 que não são replicados 
	_Super:New()              
	

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setHrIni
Seta o valor hrIni
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setHrIni(hrIni) class VO_ProcGeral
    ::hrIni := hrIni
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getHrIni
Retorna o valor hrIni
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getHrIni() class VO_ProcGeral
return(::hrIni)

//-------------------------------------------------------------------
/*/{Protheus.doc} setHrFim
Seta o valor hrFim
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setHrFim(hrFim) class VO_ProcGeral
    ::hrFim := hrFim
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getHrFim
Retorna o valor hrFim
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getHrFim() class VO_ProcGeral
return(::hrFim)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValTot
Seta o valor valTot
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValTot(valTot) class VO_ProcGeral
    ::valTot := valTot
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValTot
Retorna o valor valTot
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValTot() class VO_ProcGeral
return(::valTot)

//-------------------------------------------------------------------
/*/{Protheus.doc} setRedAcresc
Seta o valor redAcresc
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setRedAcresc(redAcresc) class VO_ProcGeral
    ::redAcresc := redAcresc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRedAcresc
Retorna o valor redAcresc
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getRedAcresc() class VO_ProcGeral
return(::redAcresc)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTecUtil
Seta o valor tecUtil
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTecUtil(tecUtil) class VO_ProcGeral
    ::tecUtil := tecUtil
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTecUtil
Retorna o valor tecUtil
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTecUtil() class VO_ProcGeral
return(::tecUtil)

//-------------------------------------------------------------------
/*/{Protheus.doc} setViaAcesso
Seta o valor viaAcesso
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setViaAcesso(viaAcesso) class VO_ProcGeral
    ::viaAcesso := viaAcesso
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getViaAcesso
Retorna o valor viaAcesso
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getViaAcesso() class VO_ProcGeral
return(::viaAcesso)

//-------------------------------------------------------------------
/*/{Protheus.doc} setEquipeProc
Seta o valor equipeProc
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setEquipeProc(equipeProc) class VO_ProcGeral
    aAdd(::equipeProc, equipeProc)
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getEquipeProc
Retorna o valor equipeProc
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getEquipeProc() class VO_ProcGeral
return(::equipeProc)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_ProcGeral
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_ProcGeral
Return