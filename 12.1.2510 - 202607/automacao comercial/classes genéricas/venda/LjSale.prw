#include "TOTVS.CH"
#include "msobject.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjSale
Classe responsavel por informações referente a venda

@type       Class
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Class LjSale

    Data oMessageError          as Object
    Data nNetSaleValue          as Numeric
    Data cPosCode               as Character
    Data cSellerName            as Character
    Data cSaleId                as Character
    Data nTotalQuantityItems    as Numeric
    Data cFiscalId              as Character
    Data aItens                 as Array
    Data aPayment               as Array
    Data cSellerId              as Character
    Data cStoreId               as Character

    Data oLjCustomer            as Object

    Method New( cSaleId             ,nNetSaleValue  ,cPosCode   ,cSellerName,;
                nTotalQuantityItems ,cFiscalId      ,aItens     ,aPayment   )

    Method GetSaleId()
    Method SetSaleId(cSaleId)

    Method GetNetSaleValue()
    Method SetNetSaleValue(nNetSaleValue)

    Method GetPosCode()
    Method SetPosCode(cPosCode)

    Method GetSellerName()
    Method SetSellerName(cSellerName)

    Method GetTotalQuantityItems()
    Method SetTotalQuantityItems(nTotalQuantityItems)

    Method GetFiscalId()
    Method SetFiscalId(cFiscalId)

    Method GetCustomer()
    Method SetCustomer(oLjCustomer)

    Method GetItens()
    Method SetItens(aItens)
    
    Method GetPayment()
    Method SetPayment(aPayment)

    Method GetSellerId()

    Method GetStoreId()

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@param      cSaleId, Caractere, Identificador da venda
@param      nNetSaleValue, Numérico, Valor líquido
@param      cPosCode, Caractere, Código da estação
@param      cSellerName, Caractere, Nome do vendedor
@param      nTotalQuantityItems, Numérico, Quantidade total de itens
@param      cFiscalId, Caractere, Identificador fiscal da venda
@return     LjSale, Objeto instânciado
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method New( cSaleId             ,nNetSaleValue  ,cPosCode   ,cSellerName,;
            nTotalQuantityItems ,cFiscalId      ,aItens     ,aPayment   ,;
            cSellerId           ,cStoreId       ) Class LjSale

    Default cPosCode            := ""
    Default cSellerName         := ""
    Default nTotalQuantityItems := 0
    Default cFiscalId           := ""
    Default nNetSaleValue       := 0
    Default aItens              := {}
    Default aPayment            := {}
    Default cSellerId           := ""
    Default cStoreId            := ""
    
    Self:oMessageError          := LjMessageError():New()
    Self:cSaleId                := cSaleId
    Self:nNetSaleValue          := nNetSaleValue
    Self:cPosCode               := cPosCode
    Self:cSellerName            := cSellerName
    Self:nTotalQuantityItems    := nTotalQuantityItems
    Self:cFiscalId              := cFiscalId
    Self:aItens                 := aItens
    Self:aPayment               := aPayment
    Self:cSellerId              := cSellerId
    Self:cStoreId               := cStoreId

Return Self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSaleId
Retorna o Identificador da venda

@type       Method
@return     Caractere, Identificador da venda
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetSaleId() Class LjSale
Return Self:cSaleId

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetSaleId
Atualiza o Identificador da venda

@type       Method
@param      cSaleId, Caractere, Identificador da venda
@return     Lógico, Define se a informação foi atualizada
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetSaleId(cSaleId) Class LjSale
    Self:cSaleId := cSaleId
Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetNetSaleValue
Retorna o valor líquido

@type       Method
@return     Numérico, Valor líquido
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetNetSaleValue() Class LjSale
Return Self:nNetSaleValue

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetNetSaleValue
Atualiza o valor líquido

@type       Method
@param      nNetSaleValue, Numérico, Valor líquido
@return     Lógico, Define se a informação foi atualizada
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetNetSaleValue(nNetSaleValue) Class LjSale
    Self:nNetSaleValue := nNetSaleValue
Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPosCode
Retorna o código da estação

@type       Method
@return     Caractere, Código da estação
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetPosCode() Class LjSale
Return Self:cPosCode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPosCode
Atualiza o código da estação

@type       Method
@param      cPosCode, Caractere, Código da estação
@return     Lógico, Define se a informação foi atualizada
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetPosCode(cPosCode) Class LjSale
    Self:cPosCode := cPosCode
Return Self:oMessageError:GetStatus()
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSellerName
Retorna o nome do vendedor

@type       Method
@return     Caractere, Nome do vendedor
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetSellerName() Class LjSale
Return Self:cSellerName

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetSellerName
Atualiza o nome do vendedor

@type       Method
@param      cSellerName, Caractere, Nome do vendedor
@return     Lógico, Define se a informação foi atualizada
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetSellerName(cSellerName) Class LjSale
    Self:cSellerName := cSellerName
Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTotalQuantityItems
Retorna a quantidade total de itens

@type       Method
@return     Numérico, Quantidade total de itens
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetTotalQuantityItems() Class LjSale
Return Self:nTotalQuantityItems

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetTotalQuantityItems
Atualiza a quantidade total de itens

@type       Method
@param      nTotalQuantityItems, Numérico, Quantidade total de itens
@return     Lógico, Define se a informação foi atualizada
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetTotalQuantityItems(nTotalQuantityItems) Class LjSale
    Self:nTotalQuantityItems := nTotalQuantityItems
Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFiscalId
Retorna o identificador fiscal da venda

@type       Method
@return     Caractere, Identificador fiscal da venda
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetFiscalId() Class LjSale
Return Self:cFiscalId

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetFiscalId
Atualiza o identificador fiscal da venda

@type       Method
@param      cFiscalId, Caractere, Identificador fiscal da venda
@return     Lógico, Define se a informação foi atualizada
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetFiscalId(cFiscalId) Class LjSale
    Self:cFiscalId := cFiscalId
Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCustomer
Retorna o cliente da venda

@type       Method
@return     LjCustomer, Objeto com as informações do cliente
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetCustomer() Class LjSale
return iif(Self:oLjCustomer == Nil,Nil,Self:oLjCustomer)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetCustomer
Atualiza o cliente da venda

@type       Method
@param      oLjCustomer, LjCustomer, Objeto com as informações do cliente
@return     Lógico, Define se a informação foi atualizada
@author     Lucas Novais (lnovais@)
@since      17/06/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetCustomer(oLjCustomer) Class LjSale
    Self:oLjCustomer := oLjCustomer
return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetItens
Retorna os itens da venda

@type       Method
@return     Lógico, Define se a informação foi atualizada
@author     Eduardo Sales
@since      21/10/2024
/*/
//-------------------------------------------------------------------------------------
Method GetItens() Class LjSale
    
	Local nX        := 0
	Local cJsItem   := ""

	For nX := 1 to Len(Self:aItens)
		cJsItem += '{'                                                                  + CRLF
		cJsItem += '	"itenID":' + AllTrim(STR(Self:aItens[nX][1])) + ','             + CRLF
		cJsItem += '	"productDescription":"' + AllTrim(Self:aItens[nX][2]) + '",'    + CRLF
		cJsItem += '	"productCode":"' + AllTrim(Self:aItens[nX][3]) + '",'           + CRLF
		cJsItem += '	"QuantityItems":"' + AllTrim(STR(Self:aItens[nX][4])) + '",'    + CRLF
		cJsItem += '	"grossSaleValue":"' + AllTrim(STR(Self:aItens[nX][5])) + '",'   + CRLF
		cJsItem += '	"netSaleValue":"' + AllTrim(STR(Self:aItens[nX][6])) + '"'      + CRLF
		cJsItem += '}'

		If nX < Len(Self:aItens)
			cJsItem += ',' + CRLF
		EndIf
	Next nX

Return cJsItem

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPayment
Retorna os pagamentos da venda

@type       Method
@return     aPayment, Array com as informações do pagamento 
@author     Eduardo Sales
@since      21/10/2024
/*/
//-------------------------------------------------------------------------------------
Method GetPayment() Class LjSale

	Local nX        := 0
	Local cJsPgto   := ""

	For nX := 1 to Len(Self:aPayment)
		cJsPgto += '{'																	+ CRLF
		cJsPgto += '	"paymentMethodId ":"'+ Self:aPayment[nX][1] + '",'      		+ CRLF
		cJsPgto += '	"description":"' + Self:aPayment[nX][2] + '",'          		+ CRLF
		cJsPgto += '	"netSaleValue ":"' + AllTrim(STR(Self:aPayment[nX][3])) + '" '  + CRLF
		cJsPgto += '}'

		If nX < Len(Self:aPayment)
			cJsPgto += ',' + CRLF
		EndIf
	Next nX

Return cJsPgto

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSellerId
Retorna o Id do vendedor

@type       Method
@return     cSellerId, Retorna Id do vendedor
@author     Eduardo Sales
@since      21/10/2024
/*/
//-------------------------------------------------------------------------------------
Method GetSellerId() Class LjSale
Return Self:cSellerId

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetItens
Atualiza os itens da venda

@type       Method
@return     aItens, Array com as informações do pagamento
@author     Eduardo Sales
@since      20/12/2024
/*/
//-------------------------------------------------------------------------------------
Method SetItens(aItens) Class LjSale
    Self:aItens := aItens
Return Self:oMessageError:GetStatus()

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPayment
Atualiza os pagamentos da venda

@type       Method
@return     Lógico, Define se a informação foi atualizada
@author     Eduardo Sales
@since      20/12/2024
/*/
//-------------------------------------------------------------------------------------
Method SetPayment(aPayment) Class LjSale
    Self:aPayment := aPayment
Return Self:oMessageError:GetStatus()
