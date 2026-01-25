#include "totvs.ch"
#include "OFCNHPrimSubCanalVenda.ch"

Function OFCNH0008();Return

/*/{Protheus.doc} OFCNHPrimSubCanalVenda

	@author       Vinicius Gati
	@since        26/01/2018
	@description  Canais de Venda

/*/
Class OFCNHPrimSubCanalVenda from LongNameClass
	Data aSubCanais

	METHOD New() CONSTRUCTOR
	Method CodTransf()
ENDCLASS

Method New() Class OFCNHPrimSubCanalVenda
	::aSubCanais := {}
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "CA"},;
		{"PERMITE"  , "ABV"},;
		{"DESCRICAO", STR0001};	//#"Concessionário CNH"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "CB"},;
		{"PERMITE"  , "ABV"},;
		{"DESCRICAO", STR0002};	//#"Administração Pública"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "CC"},;
		{"PERMITE"  , "ABV"},;
		{"DESCRICAO", STR0003};	//#"Revendedor Não Autorizado"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "A1"},;
		{"PERMITE"  , "ABV"},;
		{"DESCRICAO", STR0004};	//#"Conta Chave"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "C1"},;
		{"PERMITE"  , "ABV"},;
		{"DESCRICAO", STR0005};	//#"Cliente Agrícola"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "C2"},;
		{"PERMITE"  , "ABV"},;
		{"DESCRICAO", STR0006};	//#"Cliente Construção"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "D1"},;
		{"PERMITE"  , "ABV4"},;
		{"DESCRICAO", STR0007};	//#"Outra filial de posse"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "D2"},;
		{"PERMITE"  , "ABCD34 "},;
		{"DESCRICAO", STR0008};	//#"Interno como transferências ou CNH"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "D3"},;
		{"PERMITE"  , "ABV"},;
		{"DESCRICAO", STR0009};	//#"Diversos"
	}))
	AADD(::aSubCanais, DMS_DataContainer():New({ ;
		{"CODIGO"   , "D5"},;
		{"PERMITE"  , "A"},;
		{"DESCRICAO", STR0010};	//#"Serviços"
	}))
Return SELF

/*/{Protheus.doc} CodTransf
	Retorna o codigo subcanal padrão para transferencias

	@type function
	@author Vinicius Gati
	@since 13/04/2018
/*/
Method CodTransf() Class OFCNHPrimSubCanalVenda
Return 'D2'
