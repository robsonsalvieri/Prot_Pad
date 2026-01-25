#include "TOTVS.CH"
#include "msobject.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjPhone
Classe responsavel por informações referente ao telefone

@type       Class
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Class LjPhone

    Data oMessageError  as Object
    Data cDDD           as Character
    Data cPhone         as Character

    Method New(cDDD,cPhone)

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@param      cDDD, Caractere, Discagem direta a distância
@param      cPhone, Caractere, Número do telefone
@return     LjPhone, Objeto instânciado
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method New(cDDD,cPhone) Class LjPhone
    Self:oMessageError := LjMessageError():New()

    Self:cDDD          := IIF( Empty(cDDD), "", cValToChar( Val(cDDD) ) )
    Self:cPhone        := cPhone
Return Self