#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_OutrasDesp
	
	data cRegAns    as String  HIDDEN
	data cNumGuiRef as String  HIDDEN
	data cCid		  as String  HIDDEN
	data cAteRn	  as String  HIDDEN
	data oContExec  as Object  HIDDEN //classe de VO_Contratado
	data cCodOpe	 as String  
	
	data dtIniFat      as Date    HIDDEN
	data dtFimFat      as Date    HIDDEN
	
	data aProcedimentos as Array   HIDDEN //Classe VO_Procedimento
	
	method New() Constructor
	
	method setRegAns()
	method getRegAns()
	
	method setNumGuiRef()
	method getNumGuiRef()
	
	method setAteRn()
	method getAteRn()
	
	method setCid()
	method getCid()
	
	method setContExec()
	method getContExec()
	
	method setProcedimentos()
	method getProcedimentos()
	
	method setDtIniFat()
	method getDtIniFat()
	
	method setDtFimFat()
	method getDtFimFat()
	
	method setCodOpe()
	method getCodOpe()
	
	

endClass

//-------------------------------------------------------------------
/*/{Protheus.doc} new
Construtor da classe
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method new() class VO_OutrasDesp

	::cRegAns       := ""
	::cNumGuiRef    := ""
	::cAteRn        := ""
	::cCid          := ""
	::oContExec     := VO_Contratado():New()
	
	::dtIniFat      := Date()
	::dtFimFat      := Date()
	
	::aProcedimentos := {}

	::cCodOpe	 := "" 

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setDtIniFat
Seta o valor dtIniFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtIniFat(dtIniFat) class VO_OutrasDesp
    ::dtIniFat := dtIniFat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDtIniFat
Retorna o valor dtIniFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDtIniFat() class VO_OutrasDesp
return(::dtIniFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDtFimFat
Seta o valor dtFimFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtFimFat(dtFimFat) class VO_OutrasDesp
    ::dtFimFat := dtFimFat
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDtFimFat
Retorna o valor dtFimFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDtFimFat() class VO_OutrasDesp
return(::dtFimFat)

//-------------------------------------------------------------------
/*/{Protheus.doc} setRegAns
Seta o valor cRegAns
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setRegAns(cRegAns) class VO_OutrasDesp
    ::cRegAns := cRegAns
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRegAns
Retorna o valor cRegAns
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getRegAns() class VO_OutrasDesp
return(::cRegAns)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNumGuiRef
Seta o valor cNumGuiRef
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNumGuiRef(cNumGuiRef) class VO_OutrasDesp
    ::cNumGuiRef := cNumGuiRef
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNumGuiRef
Retorna o valor cNumGuiRef
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNumGuiRef() class VO_OutrasDesp
return(::cNumGuiRef)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCid
Seta o valor cCid
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCid(cCid) class VO_OutrasDesp
    ::cCid := cCid
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCid
Retorna o valor cCid
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCid() class VO_OutrasDesp
return(::cCid)

//-------------------------------------------------------------------
/*/{Protheus.doc} setAteRn
Seta o valor cAteRn
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setAteRn(cAteRn) class VO_OutrasDesp
    ::cAteRn := cAteRn
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getAteRn
Retorna o valor cAteRn
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getAteRn() class VO_OutrasDesp
return(::cAteRn)

//-------------------------------------------------------------------
/*/{Protheus.doc} setContExec
Seta o valor oContExec
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setContExec(oContExec) class VO_OutrasDesp
    ::oContExec := oContExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getContExec
Retorna o valor oContExec
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getContExec() class VO_OutrasDesp
return(::oContExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcedimentos
Seta o valor aProcedimentos
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProcedimentos(aProcedimentos) class VO_OutrasDesp
    ::aProcedimentos := aProcedimentos
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcedimentos
Retorna o valor aProcedimentos
@author Karine Riquena Limp
@since 29/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcedimentos() class VO_OutrasDesp
return(::aProcedimentos)

//-------------------------------------------------------------------
/*/{Protheus.doc} VO_OutrasDesp
Somente para compilar a classe
@author Karine Riquena Limp
@since 23/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_OutrasDesp
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodOpe
Seta o valor cCodOpe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCodOpe(cCodOpe) class VO_OutrasDesp
    ::cCodOpe := cCodOpe
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodOpe
Retorna o valor cCodOpe
@author Rodrigo Morgon
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCodOpe() class VO_OutrasDesp
return(::cCodOpe)