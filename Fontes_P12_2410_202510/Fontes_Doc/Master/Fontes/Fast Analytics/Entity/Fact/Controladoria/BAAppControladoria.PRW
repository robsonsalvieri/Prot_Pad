#INCLUDE "BADEFINITION.CH"

NEW APP CONTROL

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppControladoria
Modelagem da area de Comercial.

@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Class BAAppControladoria
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome unico para a area. 

@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppControladoria
	::cApp := "Controladoria"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensoes) disponiveis da area, deve ser 
necessariamente o nome das classes das entidades.

@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppControladoria
Return	{ "LANCCONTAB", +;
	      "CONTABI", + ;
	      "ORCADO", +; 
	      "CONTACONTAB", + ;
          "EMPRESA", + ;
		  "FILIAL", + ;
		  "CENTROCUSTO", + ;
		  "ITEMCONTABIL", + ;
		  "CLASSEVALOR", +;
		  "MOEDA", +;
		  "COTACAO" }
