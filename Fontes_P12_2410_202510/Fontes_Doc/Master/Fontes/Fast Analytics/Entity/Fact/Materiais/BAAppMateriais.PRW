#INCLUDE "BADEFINITION.CH"

NEW APP MATERI

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppMateriais
Modelagem da area de Materiais.

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Class BAAppMateriais
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome unico para a area. 

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppMateriais
	::cApp := "Materiais"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensoes) disponiveis da area, deve ser 
necessariamente o nome das classes das entidades.

@author  Helio Leal
@author  henrique.cesar
@since   05/03/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppMateriais
Return	{   "ESTOQUE", + ; //Fato BAEstoque
			"COMPRAS", + ; //Fato BACompras
			"COMPCARTEIRA", + ; //Fato BAComprasCart
			"COMPDEVOLUCAO", + ; //Fato BAComprasDev
			"COMPRECEBIMENTO", + ; //Fato BAComprasRec
			"EMPRESA", + ; //Dimensao BAEmpresa
			"FILIAL", + ; //Dimensao BAFilial
			"FORNECEDOR", + ; //Dimensao BAFornecedor
			"COMPRADOR", + ; //Dimensao BAComprador
			"TRANSPORTADORA", + ; //Dimensao BATransportadora
			"GRPFORNECEDOR", + ; //Dimensao BAGrpFornecedor
			"GRPESTOQUE", + ; //Dimensao BAGrpEstoque
			"UNMEDITEM", + ; //Dimensao BAUnMedItem
			"ITEM", + ; //Dimensao BAItem
			"CONDPGTO", + ; //Dimensao BACondPgto
			"CENTROCUSTO", + ; //Dimensao BACentroCusto	
			"TES", + ; //Dimensao BATes
			"CFOP", + ; //Dimensao BACFOP 
			"FAMCOM", + ; //Dimensao BAFamCom
			"FAMMAT", + ; //Dimensao BAFamMat		
			"REGIAO", + ; //Dimensao BARegiao
			"DEPOSITO", + ; //Dimensao BADeposito
			"SITCOMPRA", + ; //Dimensao BASitCompra 
			"MOEDA", + ;
			"COTACAO" } 

