/*
Programa   : ESSRA400
Objetivo   : Chamar a rotina de Registro de Serviços com a opção Aquisição de Serviços
Retorno    : Nil
Autor      : Rafael Ramos Capuano - RRC
Data/Hora  : 17/08/2012 11:13 
Revisao    : 
*/

#Include 'Protheus.ch'
#Include "Average.ch"
Function ESSRA400(aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Local cTipo  := "A"
Default lCallInv := .F. 
ESSRS400(cTipo,aCab,aItens,aAnexos,nOpcAuto,lCallInv)
Return .T.

/* 
Funcao     : MenuDef() 
Parametros : Nenhum 
Retorno    : aRotina 
Objetivos  : Chamada da função MenuDef no programa onde a função está declarada. 
Autor      : Felipe Sales Martinez
Data       : 22/11/2012
*/ 
Static Function MenuDef() 
Local aRotina :={}
Private cAvStaticCall := "ESSRA400" 
Private cTpReg := "A" 

   aRotina := MDSRS400() //Static Call(ESSRS400, MenuDef) 

Return aRotina 
