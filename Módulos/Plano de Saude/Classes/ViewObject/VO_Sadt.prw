#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

class VO_Sadt from VO_Guia
	
	data oContExec      as Object 	HIDDEN //classe de VO_Contratado
	data oContSol       as Object  HIDDEN //classe VO_Contratado
	data oProfSol       as Object  HIDDEN //classe VO_Profissional
	data oProfExec      as Object  HIDDEN //classe VO_Profissional
	data cIndCli        as String  HIDDEN 
	data dDatSol        as Date    HIDDEN 
	
	data dDtRelS  as Date HIDDEN
	data dDtRelS2 as Date HIDDEN
	data dDtRelS3 as Date HIDDEN
	data dDtRelS4 as Date HIDDEN
	data dDtRelS5 as Date HIDDEN
	data dDtRelS6 as Date HIDDEN
	data dDtRelS7 as Date HIDDEN
	data dDtRelS8 as Date HIDDEN
	data dDtRelS9 as Date HIDDEN
	data dDtRelS1 as Date HIDDEN

	data aProcedimentos as Array   HIDDEN //Classe VO_Procedimento
	
	method New() Constructor
	
	method setContSol()
	method getContSol()
	
	method setContExec()
	method getContExec()
	
	method setProfSol()
	method getProfSol()
	
	method setProfExec()
	method getProfExec()
	
	method setIndCli()
	method getIndCli()
				
	method setProcedimentos()
	method getProcedimentos()

	method setDatSol()
	method getDatSol()
	
	method setdDtRlS()
	method getdDtRlS()
		
	method setdDtRlS2()
	method getdDtRlS2()
	
	method setdDtRlS3()
	method getdDtRlS3()
	
	method setdDtRlS4()
	method getdDtRlS4()
	
	method setdDtRlS5()
	method getdDtRlS5()
	
	method setdDtRlS6()
	method getdDtRlS6()
	
	method setdDtRlS7()
	method getdDtRlS7()
	
	method setdDtRlS8()
	method getdDtRlS8()
	
	method setdDtRlS9()
	method getdDtRlS9()
	
	method setdDtRlS1()
	method getdDtRlS1()

endClass

method new() class VO_Sadt

	::oContExec      := VO_Contratado():New()
	::oContSol       := VO_Contratado():New()
	::oProfSol       := VO_Profissional():New()
	::oProfExec       := VO_Profissional():New()
	::cIndCli        := ""
	::dDatSol 			:= DATE()
	
		::dDtRelS		:= Date()
	::dDtRelS2 	:= Date()
	::dDtRelS3 	:= Date()
	::dDtRelS4 	:= Date()
	::dDtRelS5 	:= Date()
	::dDtRelS6 	:= Date()
	::dDtRelS7 	:= Date()
	::dDtRelS8 	:= Date()
	::dDtRelS9 	:= Date()
	::dDtRelS1 	:= Date()

	::aProcedimentos := {} //Classe VO_Procedimento
	
	//atributos da superclasse VO_GUIA
	_Super:New() 

return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setContExec
Seta o valor contExec
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setContExec(oContExec) class VO_Sadt
    ::oContExec := oContExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getContExec
Retorna o valor contExec
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getContExec() class VO_Sadt
return(::oContExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setContSol
Seta o valor contSol
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setContSol(oContSol) class VO_Sadt
    ::oContSol := oContSol
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getContSol
Retorna o valor contSol
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getContSol() class VO_Sadt
return(::oContSol)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfSol
Seta o valor oProfSol
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfSol(oProfSol) class VO_Sadt
    ::oProfSol := oProfSol
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProfSol
Retorna o valor oProfSol
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProfSol() class VO_Sadt
return(::oProfSol)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProfExec
Seta o valor oProfExec
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProfExec(oProfExec) class VO_Sadt
    ::oProfExec := oProfExec
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getProfExec
Retorna o valor oProfExec
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getProfExec() class VO_Sadt
return(::oProfExec)

//-------------------------------------------------------------------
/*/{Protheus.doc} setIndCli
Seta o valor cIndCli
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setIndCli(cIndCli) class VO_Sadt
    ::cIndCli := cIndCli
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getIndCli
Retorna o valor cIndCli
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getIndCli() class VO_Sadt
return(::cIndCli)

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcedimentos
Seta o valor procedimentos
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setProcedimentos(aProcedimentos) class VO_Sadt
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
method getProcedimentos() class VO_Sadt
return(::aProcedimentos)

//-------------------------------------------------------------------
/*/{Protheus.doc} setDatSol
Seta o valor DatSol
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method setDatSol(dDatSol) class VO_Sadt
    ::dDatSol := dDatSol
return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getDatSol
Retorna o valor DatSol
@author Karine Riquena Limp
@since 24/05/2016
@version P12
/*/
//-------------------------------------------------------------------
method getDatSol() class VO_Sadt
return(::dDatSol)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS(dDtRelS) class VO_SADT
return ::dDtRelS := dDtRelS


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS(dDtRelS) class VO_SADT
return(::dDtRelS)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS2
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS2(dDtRelS2) class VO_SADT
return ::dDtRelS2 := dDtRelS2


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS2
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS2(dDtRelS2) class VO_SADT
return(::dDtRelS2)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS3
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS3(dDtRelS3) class VO_SADT
return ::dDtRelS3 := dDtRelS3


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS3
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS3(dDtRelS3) class VO_SADT
return(::dDtRelS3)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS4
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS4(dDtRelS4) class VO_SADT
return ::dDtRelS4 := dDtRelS4


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS4(dDtRelS4) class VO_SADT
return(::dDtRelS4)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS5
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS5(dDtRelS5) class VO_SADT
return ::dDtRelS5 := dDtRelS5


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS5
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS5(dDtRelS5) class VO_SADT
return(::dDtRelS5)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS6
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS6(dDtRelS6) class VO_SADT
return ::dDtRelS6 := dDtRelS6


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS6
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS6(dDtRelS6) class VO_SADT
return(::dDtRelS6)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS7
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS7(dDtRelS7) class VO_SADT
return ::dDtRelS7:= dDtRelS7


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS7
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS7(dDtRelS7) class VO_SADT
return(::dDtRelS7)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS8
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS8(dDtRelS8) class VO_SADT
return ::dDtRelS8 := dDtRelS8


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS8
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS8(dDtRelS8) class VO_SADT
return(::dDtRelS8)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS9
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS9(dDtRelS9) class VO_SADT
return ::dDtRelS9 := dDtRelS9


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS9
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS9(dDtRelS9) class VO_SADT
return(::dDtRelS9)


//-------------------------------------------------------------------
/*/{Protheus.doc} setdDtRlS1
Atribui Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method setdDtRlS1(dDtRelS1) class VO_SADT
return ::dDtRelS1 := dDtRelS1


//-------------------------------------------------------------------
/*/{Protheus.doc} getdDtRlS1
Recupera Valor da data de procedimentos serializados
@author Renan Martins
@since 09/2018
@version P12
/*/
//-------------------------------------------------------------------
method getdDtRlS1(dDtRelS1) class VO_SADT
return(::dDtRelS1)


//-------------------------------------------------------------------
/*/{Protheus.doc} VO_Sadt
Somente para compilar a classe
@author Karine Riquena Limp
@since 20/05/2016
@version P12
/*/
//-------------------------------------------------------------------
Function VO_Sadt
Return