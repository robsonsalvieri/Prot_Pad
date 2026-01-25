#INCLUDe "BADEFINITION.CH"

NEW APP FINANCE

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppFinanceiro
Modelagem da area de Comercial.

@author  Helio Leal
@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Class BAAppFinanceiro
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome unico para a area. 

@author  Helio Leal
@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppFinanceiro
	::cApp := "Financeiro"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensoes) disponiveis da area, deve ser 
necessariamente o nome das classes das entidades.

@author  Helio Leal
@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppFinanceiro
Return	{   "PAGAMENTO", + ;
			"PAGCARTEIRA", + ;
			"RECARTEIRA", + ;
			"RECEBIMENTO", + ;
			"EMPRESA", + ;
			"FILIAL", + ;
			"ESPECDOC", + ;
			"TPCARTEIRA", + ;
			"CENTROCUSTO", + ;
			"NATFINANCEIRA", + ;
			"FORNECEDOR", + ;
			"REGIAO", + ;
			"GRPFORNECEDOR", + ;
			"CLIENTE", + ;
			"VENDEDORREPST", + ;
			"MODALCOBRANCA", + ;
			"GRPCLIENTE", + ;
			"BANCO", +;
			"MOEDA", +;
			"COTACAO" }

