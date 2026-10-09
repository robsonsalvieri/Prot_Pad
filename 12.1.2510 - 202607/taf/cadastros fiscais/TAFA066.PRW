#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA066.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA066
Cadastro MVC - Detalhamento da contribuicao - PIS/PASEP e/ou Cofins  do periodo

@author Rodrigo Aguilar
@since 13/10/2014
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA066()
	Taf066Vld() //Chama a função de validação
	MsgInfo('Prezado cliente, o cadastro do detalhamento do PIS/PASEP e/ou Cofins foi descontinuado!')
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf066Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Rodrigo Aguilar
@since 20/10/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf066Vld(cAlias,nRecno,nOpc,lJob)
	Local aLogErro   := {}
Return(aLogErro)
