#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_ValorTotal
	
	data valProc   as Numeric HIDDEN
	data valDia    as Numeric HIDDEN
	data valTxAlu  as Numeric HIDDEN
	data valMat    as Numeric HIDDEN
	data valMed    as Numeric HIDDEN
	data valOPME   as Numeric HIDDEN
	data valGasMed as Numeric HIDDEN
	data valTotGer as Numeric HIDDEN
	
	method New() Constructor
	
	method setValProc()
	method getValProc()
	
	method setValDia()
	method getValDia()
	
	method setValTxAlu()
	method getValTxAlu()
	
	method setValMat()
	method getValMat()
	
	method setValMed()
	method getValMed()
	
	method setValOPME()
	method getValOPME()
	
	method setValGasMed()
	method getValGasMed()
	
	method setValTotGer()
	method getValTotGer()
	
endClass

method new() class VO_ValorTotal

	::valProc   := 0
	::valDia    := 0
	::valTxAlu  := 0
	::valMat    := 0
	::valMed    := 0
	::valOPME   := 0
	::valGasMed := 0
	::valTotGer := 0
	
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setValProc
Seta o valor valProc
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValProc(valProc) class VO_ValorTotal
    ::valProc := valProc
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValProc
Retorna o valor valProc
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValProc() class VO_ValorTotal
return(::valProc)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValDia
Seta o valor valDia
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValDia(valDia) class VO_ValorTotal
    ::valDia := valDia
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValDia
Retorna o valor valDia
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValDia() class VO_ValorTotal
return(::valDia)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValTxAlu
Seta o valor valTxAlu
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValTxAlu(valTxAlu) class VO_ValorTotal
    ::valTxAlu := valTxAlu
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValTxAlu
Retorna o valor valTxAlu
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValTxAlu() class VO_ValorTotal
return(::valTxAlu)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValMat
Seta o valor valMat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValMat(valMat) class VO_ValorTotal
    ::valMat := valMat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValMat
Retorna o valor valMat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValMat() class VO_ValorTotal
return(::valMat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValMed
Seta o valor valMed
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValMed(valMed) class VO_ValorTotal
    ::valMed := valMed
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValMed
Retorna o valor valMed
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValMed() class VO_ValorTotal
return(::valMed)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValOPME
Seta o valor valOPME
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValOPME(valOPME) class VO_ValorTotal
    ::valOPME := valOPME
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValOPME
Retorna o valor valOPME
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValOPME() class VO_ValorTotal
return(::valOPME)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValGasMed
Seta o valor valGasMed
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValGasMed(valGasMed) class VO_ValorTotal
    ::valGasMed := valGasMed
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValGasMed
Retorna o valor valGasMed
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValGasMed() class VO_ValorTotal
return(::valGasMed)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValTotGer
Seta o valor valTotGer
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValTotGer(valTotGer) class VO_ValorTotal
    ::valTotGer := valTotGer
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getValTotGer
Retorna o valor valTotGer
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValTotGer() class VO_ValorTotal
return(::valTotGer)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_ValorTotal
Somente para compilar a classe
@author Karine Riquena Limp
@since 23/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_ValorTotal
Return