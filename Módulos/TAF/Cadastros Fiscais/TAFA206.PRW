#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA206.CH"

//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA206                                                                                                                                                                                                                                                                                 
Cadastro MVC -                                                                                                                                                                                                                                                                           

                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 13/02/2013                                                                                                                                                                                                                                                                                        
@version 1.0                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
/*/   
                                                                                                                                                                                                                                                                                                    
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA206()
	TAF206Vld() //Chama a função de validação
	MsgInfo('Prezado cliente, o cadastro de resumo diário de cupom fiscal emitido por ECF foi descontinuado!')
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF206Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//-----------------------------------------------------------------------------------
Function TAF206Vld(cAlias,nRecno,nOpc,lJob)
	Local aLogErro	:= {}
Return(aLogErro)
	                                                                                                                                                                                                                                                                                          