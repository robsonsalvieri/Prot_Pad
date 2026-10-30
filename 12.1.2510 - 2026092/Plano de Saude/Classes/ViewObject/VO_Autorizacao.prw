#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Autorizacao
	
	data dataAut  as Date   HIDDEN //BD5_DATPRO
	data senhaAut as String HIDDEN //BD5_SENHA
	data valSenha as Date   HIDDEN //BD5_VALSEN
	
	method New() Constructor
	
	method setDataAut()
	method getDataAut()
	
	method setSenhaAut()
	method getSenhaAut()
	
	method setValSenha()
	method getValSenha()
	
endClass

method new() class VO_Autorizacao

	::dataAut  := date()
	::senhaAut := ""
	::valSenha := date()

return self
//-------------------------------------------------------------------
/*/{Protheus.doc} setDataAut
Seta o valor da data de autorização
@author Karine Riquena Limp
@since 23/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDataAut(dataAut) class VO_Autorizacao
::dataAut := dataAut
return   

//-------------------------------------------------------------------
/*/{Protheus.doc} setDataAut
Retorna o valor da data de autorização
@author Karine Riquena Limp
@since 23/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDataAut() class VO_Autorizacao
return(::dataAut)  

//-------------------------------------------------------------------
/*/{Protheus.doc} setSenhaAut
Seta o valor da senha de autorização
@author Karine Riquena Limp
@since 23/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setSenhaAut(senhaAut) class VO_Autorizacao
::senhaAut := senhaAut
return   

//-------------------------------------------------------------------
/*/{Protheus.doc} getSenhaAut
Retorna o valor da senha de autorização
@author Karine Riquena Limp
@since 23/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getSenhaAut() class VO_Autorizacao
return(::senhaAut)

//-------------------------------------------------------------------
/*/{Protheus.doc} setValSenha
Seta o valor da data de validade da autorização
@author Karine Riquena Limp
@since 23/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setValSenha(valSenha) class VO_Autorizacao
::valSenha := valSenha
return   

//-------------------------------------------------------------------
/*/{Protheus.doc} getValSenha
Retorna o valor da data de validade da autorização
@author Karine Riquena Limp
@since 23/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getValSenha() class VO_Autorizacao
return(::valSenha) 

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Autorizacao
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Autorizacao
Return