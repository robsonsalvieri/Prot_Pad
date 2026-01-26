#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Honorario from VO_Guia
	
	data guiSolInt     as String  HIDDEN
	data senha         as String  HIDDEN
	data dtIniFat      as Date    HIDDEN
	data dtFimFat      as Date    HIDDEN
	data valTotHon     as Numeric HIDDEN
	data dtEmiGui      as Date    HIDDEN
	data cRegFor       as String  HIDDEN
	data cGuiInt       as String  HIDDEN
	data cCnpjRdaInt   as String  HIDDEN
	data cNomeRdaInt   as String  HIDDEN
	data cCnesRdaInt   as String  HIDDEN
	data aProcedimentos as Array   HIDDEN //Classe VO_ProcGeral
	data oContExec     as Object  HIDDEN //classe de VO_Contratado
	data oProfExec     as Object  HIDDEN //classe de VO_Profissional
	data oProfSol	     as Object  HIDDEN //classe de VO_Profissional
	
	method New() Constructor
	
	method setGuiSolInt()
	method getGuiSolInt()
	
	method setSenha()
	method getSenha()
		
	method setDtIniFat()
	method getDtIniFat()
	
	method setDtFimFat()
	method getDtFimFat()
	
	method setValTotHon()
	method getValTotHon()
	
	method setDtEmiGui()
	method getDtEmiGui()
	
	method setRegFor()
	method getRegFor()
		
	method setGuiInt()
	method getGuiInt()
	
	method setCnpjRdaInt()
	method getCnpjRdaInt()
	
	method setNomeRdaInt()
	method getNomeRdaInt()
	
	method setCnesRdaInt()
	method getCnesRdaInt()
	
	method setProcedimentos()
	method getProcedimentos()
	
	method setContExec()
	method getContExec()
	
	method setProfExec()
	method getProfExec()
	
	method setProfSol()
	method getProfSol()
	
endClass

method new() class VO_Honorario

	::guiSolInt    := ""
	::senha        := ""
	::dtIniFat     := Date()
	::dtFimFat     := Date()
	::valTotHon    := 0
	::dtEmiGui     := Date()
	::cRegFor		:= ""
	::cGuiInt 		:= ""
	::cCnpjRdaInt   := ""
	::cNomeRdaInt   := ""
	::cCnesRdaInt   := ""
	::oContExec		:= VO_Contratado():New()
	::oProfExec  	:= VO_Profissional():New()
	::oProfSol  	:= VO_Profissional():New()	
	::aProcedimentos:= {}
	
return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setGuiSolInt
Seta o valor guiSolInt
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setGuiSolInt(guiSolInt) class VO_Honorario
    ::guiSolInt := guiSolInt
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiSolInt
Retorna o valor guiSolInt
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getGuiSolInt() class VO_Honorario
return(::guiSolInt)


//-------------------------------------------------------------------
/*/{Protheus.doc} setSenha
Seta o valor senha
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSenha(senha) class VO_Honorario
    ::senha := senha
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getSenha
Retorna o valor senha
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSenha() class VO_Honorario
return(::senha)


//-------------------------------------------------------------------
/*/{Protheus.doc} setDtIniFat
Seta o valor dtIniFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtIniFat(dtIniFat) class VO_Honorario
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
method getDtIniFat() class VO_Honorario
return(::dtIniFat)


//-------------------------------------------------------------------
/*/{Protheus.doc} setDtFimFat
Seta o valor dtFimFat
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtFimFat(dtFimFat) class VO_Honorario
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
method getDtFimFat() class VO_Honorario
return(::dtFimFat)


//-------------------------------------------------------------------
/*/{Protheus.doc} setValTotHon
Seta o valor valTotHon
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValTotHon(valTotHon) class VO_Honorario
    ::valTotHon := valTotHon
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getValTotHon
Retorna o valor valTotHon
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValTotHon() class VO_Honorario
return(::valTotHon)


//-------------------------------------------------------------------
/*/{Protheus.doc} setDtEmiGui
Seta o valor dtEmiGui
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDtEmiGui(dtEmiGui) class VO_Honorario
    ::dtEmiGui :=  dtEmiGui
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} getDtEmiGui
Retorna o valor dtEmiGui
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDtEmiGui() class VO_Honorario
return(::dtEmiGui)

//-------------------------------------------------------------------
/*/{Protheus.doc} setRegFor
Seta o valor cRegFor
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setRegFor(cRegFor) class VO_Honorario
    ::cRegFor :=  cRegFor
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRegFor
Retorna o valor cRegFor
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getRegFor() class VO_Honorario
return(::cRegFor)

//-------------------------------------------------------------------
/*/{Protheus.doc} setGuiInt
Seta o valor cGuiInt
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setGuiInt(cGuiInt) class VO_Honorario
    ::cGuiInt := cGuiInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getGuiInt
Retorna o valor cGuiInt
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getGuiInt() class VO_Honorario
return(::cGuiInt)


//-------------------------------------------------------------------
/*/{Protheus.doc} setProcedimentos
Seta o valor procedimentos
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProcedimentos(aProcedimentos) class VO_Honorario
    ::aProcedimentos := aProcedimentos
return

//-------------------------------------------------------------------
/*/{Protheus.doc} getProcedimentos
Retorna o valor procedimentos
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProcedimentos() class VO_Honorario
return(::aProcedimentos)

//-------------------------------------------------------------------
/*/{Protheus.doc} setContExec
Seta o valor oContExec
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setContExec(oContExec) class VO_Honorario
    ::oContExec := oContExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getContExec
Retorna o valor oContExec
@author Karine Riquena Limp
@since 03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getContExec() class VO_Honorario
return(::oContExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfExec
Seta o valor oProfExec
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfExec(oProfExec) class VO_Honorario
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
method getProfExec() class VO_Honorario
return(::oProfExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfSol
Seta o valor oProfSol
@authorKarine Riquena Limp
@since03/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfSol(oProfSol) class VO_Honorario
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
method getProfSol() class VO_Honorario
return(::oProfSol)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCnpjRdaInt
Seta o valor cCnpjRdaInt
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCnpjRdaInt(cCnpjRdaInt) class VO_Honorario
    ::cCnpjRdaInt := cCnpjRdaInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCnpjRdaInt
Retorna o valor cCnpjRdaInt
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCnpjRdaInt() class VO_Honorario
return(::cCnpjRdaInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setNomeRdaInt
Seta o valor cNomeRdaInt
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setNomeRdaInt(cNomeRdaInt) class VO_Honorario
    ::cNomeRdaInt := cNomeRdaInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getNomeRdaInt
Retorna o valor cNomeRdaInt
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getNomeRdaInt() class VO_Honorario
return(::cNomeRdaInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} setCnesRdaInt
Seta o valor cCnesRdaInt
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method setCnesRdaInt(cCnesRdaInt) class VO_Honorario
    ::cCnesRdaInt := cCnesRdaInt
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getCnesRdaInt
Retorna o valor cCnesRdaInt
@author Rodrigo Morgon
@since 08/06/2016
@version P12
/*/
//-------------------------------------------------------------------
method getCnesRdaInt() class VO_Honorario
return(::cCnesRdaInt)

//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Honorario
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Honorario
Return