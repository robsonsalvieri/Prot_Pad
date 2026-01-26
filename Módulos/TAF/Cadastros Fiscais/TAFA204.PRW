#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA204.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA204                                                                                                                                                                                                                                                                                 
Cadastro MVC -                                                                                                                                                                                                                                                                           

                                                                                                                                                                                                                                                                                                          
@author Jefferson Guermandi                                                                                                                                                                                                                                                                                   
@since 08/02/2013                                                                                                                                                                                                                                                                                        
@version 1.0                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
/*/   
                                                                                                                                                                                                                                                                                                    
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA204
	TAF204Vld() //Chama a função de validação
	MsgInfo('Prezado cliente, o cadastro de bilhete de passagem foi descontinuado!')
Return .t.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} TAF204Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF204Vld(cAlias,nRecno,nOpc,lJob)
	Local aLogErro	:= {}
Return(aLogErro)

	                                                                                                                                                                                                                                                                                             