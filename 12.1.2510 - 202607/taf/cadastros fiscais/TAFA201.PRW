#INCLUDE "PROTHEUS.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "FWMVCDEF.CH"                                                                                                                                                                                                                                                                                    
#INCLUDE "TAFA201.CH"                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                          
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
/*/{Protheus.doc} TAFA201                                                                                                                                                                                                                                                                                 
Cadastro MVC -                                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                                                          
@author Gustavo Baptista                                                                                                                                                                                                                                                                                   
@since 29/01/2013                                                                                                                                                                                                                                                                                         
@version 1.0                                                                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                                                          
/*/                                                                                                                                                                                                                                                                                                       
//-------------------------------------------------------------------                                                                                                                                                                                                                                     
Function TAFA201()                                                                                                                                                                                                                                                                                          
	Taf201Vld() //Chama a função de validação
	MsgInfo('Prezado cliente, o cadastro de consolidação diária de notas fiscais foi descontinuado!')
Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf201Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões 

lJob - Informa se foi chamado por Job

@return .T.

@author Paulo V.B. Santana
@since 24/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf201Vld(cAlias,nRecno,nOpc,lJob)
	Local aLogErro   := {}
Return(aLogErro)                                                                                                                                                                                                                                                             
