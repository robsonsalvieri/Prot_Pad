#include "TOTVS.CH"
#include "msobject.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjCustomer
Classe responsavel por informações do cliente

@type       Class
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Class LjCustomer

    Data oMessageError  as Object
    Data cName          as Character
    Data cDocument      as Character
    Data oPhone         as Object
    Data dBirthday      as Data
    Data cEmail         as Character
    Data cGender        as Character

    Method New(cName,cDocument,cEmail,oPhone,dBirthday,cGender)
    Method GetName()
    Method GetDocument()
    Method GetEmail()
    Method GetPhone()
    Method GetBirthday()
    Method GetGender()

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@param      cName, Caractere, Nome
@param      cDocument, Caractere, Código do documento
@param      cEmail, Caractere, Endereço de e-mail
@param      oPhone, LjPhone, Objeto com informações do telefone
@param      dBirthday, Data, Data de nascimento
@param      cGender, Caractere, Gênero sexual
@return     LjCustomer, Objeto instânciado
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method New(cName,cDocument,cEmail,oPhone,dBirthday,cGender) Class LjCustomer

    Default cGender := ""

    Self:oMessageError := LjMessageError():New()
    
    Self:cName      := cName
    Self:cDocument  := cDocument
    Self:cEmail     := cEmail
    Self:oPhone     := oPhone
    Self:dBirthday  := dBirthday
    Self:cGender    := cGender

Return Self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetName
Retorna o nome

@type       Method
@return     Caractere, Nome
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetName() Class LjCustomer
Return Alltrim(Self:cName)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDocument
Retorna o código do documento

@type       Method
@return     Caractere, Código do documento
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetDocument() Class LjCustomer
Return Alltrim(Self:cDocument)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetEmail
Retorna o e-mail

@type       Method
@return     Caractere, Endereço de e-mail
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetEmail() Class LjCustomer
Return Alltrim(Self:cEmail)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPhone
Retorna informações do telefone

@type       Method
@return     LjPhone, Objeto com informações do telefone
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetPhone() Class LjCustomer
Return Self:oPhone

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPhone
Retorna a data de nascimento

@type       Method
@return     Data, Data de nascimento
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetBirthday() Class LjCustomer
Return Self:dBirthday

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetGender
Retorna o gênero

@type       Method
@return     Caractere, Gênero do Cliente
@author     Rafael Tenorio da Costa
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetGender() Class LjCustomer
Return Alltrim(Self:cGender)