#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Contratado
	
	data cCodRda      as String HIDDEN //BD5_CODRDA | BD6_CODRDA
	data cOpeRda      as String HIDDEN //BD5_OPERDA
	data cNomRda      as String HIDDEN //BD5_NOMRDA | BD6_NOMRDA
	data cTipRda      as String HIDDEN //BD5_TIPRDA | BD6_TIPRDA
	data cCodLoc      as String HIDDEN //BD5_CODLOC | BD6_CODLOC
	data cLocal       as String HIDDEN //BD5_LOCAL  | BD6_LOCAL
	data cCodEsp      as String HIDDEN //BD5_CODESP | 
	data cCpfCnpjRda  as String HIDDEN //BD5_CPFRDA | BD6_CPFRDA
	data cDesLoc      as String HIDDEN //BD5_DESLOC | BD6_DESLOC
	data cEndLoc      as String HIDDEN //BD5_ENDLOC | BD6_ENDLOC
	data cTipPre      as String HIDDEN //BD5_TIPPRE | 
	data cCnes        as String HIDDEN //BD5_CNES   | 
	
	/*data consCont  segundo o xml deve ser gravado na guia de odonto o CRO e estado do contratado e hoje nao faz isso (só exige na guia de odonto)
	  data uf     */
	  
	method setCodRda()
	method getCodRda()
	
	method setOpeRda()
	method getOpeRda()
	
	method setNomRda()
	method getNomRda()
	
	method setTipRda()
	method getTipRda()
	
	method setCodLoc()
	method getCodLoc()
	
	method setLocal()
	method getLocal()
	
	method setCodEsp()
	method getCodEsp()
	
	method setCpfCnpjRda()
	method getCpfCnpjRda()
	
	method setDesLoc()
	method getDesLoc()
	
	method setEndLoc()
	method getEndLoc()
	
	method setTipPre()
	method getTipPre()
	
	method setCnes()
	method getCnes()
	  
	 method New() Constructor
	
endClass

method new() class VO_Contratado
            
 ::cCodRda     := ""
 ::cOpeRda     := ""
 ::cNomRda     := ""
 ::cTipRda     := ""
 ::cCodLoc     := ""
 ::cLocal      := ""
 ::cCodEsp     := ""
 ::cCpfCnpjRda := ""
 ::cDesLoc     := ""
 ::cEndLoc     := ""
 ::cTipPre     := ""
 ::cCnes       := ""
 
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodRda
Seta o valor cCodRda
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodRda(cCodRda) class VO_Contratado
    ::cCodRda := cCodRda
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodRda
Retorna o valor cCodRda
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodRda() class VO_Contratado
return(::cCodRda)

//-------------------------------------------------------------------
/*/{Protheus.doc} setOpeRda
Seta o valor cOpeRda
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setOpeRda(cOpeRda) class VO_Contratado
    ::cOpeRda := cOpeRda
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getOpeRda
Retorna o valor cOpeRda
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getOpeRda() class VO_Contratado
return(::cOpeRda)


//-------------------------------------------------------------------
/*/{Protheus.doc} setNomRda
Seta o valor cNomRda
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNomRda(cNomRda) class VO_Contratado
    ::cNomRda := cNomRda
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNomRda
Retorna o valor cNomRda
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNomRda() class VO_Contratado
return(::cNomRda)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipRda
Seta o valor cTipRda
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipRda(cTipRda) class VO_Contratado
    ::cTipRda := cTipRda
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipRda
Retorna o valor cTipRda
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipRda() class VO_Contratado
return(::cTipRda)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodLoc
Seta o valor cCodLoc
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodLoc(cCodLoc) class VO_Contratado
    ::cCodLoc := cCodLoc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodLoc
Retorna o valor cCodLoc
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodLoc() class VO_Contratado
return(::cCodLoc)

//-------------------------------------------------------------------
/*/{Protheus.doc} setLocal
Seta o valor cLocal
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setLocal(cLocal) class VO_Contratado
    ::cLocal := cLocal
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getLocal
Retorna o valor cLocal
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getLocal() class VO_Contratado
return(::cLocal)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodEsp
Seta o valor cCodEsp
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodEsp(cCodEsp) class VO_Contratado
    ::cCodEsp := cCodEsp
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodEsp
Retorna o valor cCodEsp
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodEsp() class VO_Contratado
return(::cCodEsp)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCpfCnpjRda
Seta o valor cCpfCnpjRda
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCpfCnpjRda(cCpfCnpjRda) class VO_Contratado
    ::cCpfCnpjRda := cCpfCnpjRda
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCpfCnpjRda
Retorna o valor cCpfCnpjRda
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCpfCnpjRda() class VO_Contratado
return(::cCpfCnpjRda)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDesLoc
Seta o valor cDesLoc
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDesLoc(cDesLoc) class VO_Contratado
    ::cDesLoc := cDesLoc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDesLoc
Retorna o valor cDesLoc
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDesLoc() class VO_Contratado
return(::cDesLoc)

//-------------------------------------------------------------------
/*/{Protheus.doc} setEndLoc
Seta o valor cEndLoc
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setEndLoc(cEndLoc) class VO_Contratado
    ::cEndLoc := cEndLoc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getEndLoc
Retorna o valor cEndLoc
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getEndLoc() class VO_Contratado
return(::cEndLoc)

//-------------------------------------------------------------------
/*/{Protheus.doc} setTipPre
Seta o valor cTipPre
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setTipPre(cTipPre) class VO_Contratado
    ::cTipPre := cTipPre
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getTipPre
Retorna o valor cTipPre
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getTipPre() class VO_Contratado
return(::cTipPre)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCnes
Seta o valor cCnes
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCnes(cCnes) class VO_Contratado
    ::cCnes := cCnes
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCnes
Retorna o valor cCnes
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCnes() class VO_Contratado
return(::cCnes)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Contratado
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Contratado
Return