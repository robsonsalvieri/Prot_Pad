#INCLUDE "BADEFINITION.CH"

NEW APP COMERCI

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppComercial
Modelagem da area de Comercial.

@author  Helio Leal
@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Class BAAppComercial
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome inico para a area. 

@author  Helio Leal
@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppComercial
	::cApp := "Comercial"
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
Method ListEntities() Class BAAppComercial
Return	{   "DEVOLUCOES", + ;
			"NOTAFISCAL", + ;
			"PEDIDO", + ;
			"TRANSPORTADORA", + ;
			"REGCOMERCIAL", + ;
			"GRPCLIENTE", + ;
			"REGIAO", + ;
			"UNMEDITEM", + ;
			"CLIENTE", + ;	
			"VENDEDORREPST", + ;
			"GRPESTOQUE", + ;		
			"ITEM", + ;
			"CONDPGTO", + ;
			"TES", + ;
			"CFOP", + ;
			"FILIAL", + ;
			"EMPRESA", + ;
			"MOEDA", + ;
			"COTACAO" }