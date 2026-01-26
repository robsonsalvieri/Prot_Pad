#INCLUDE "BADEFINITION.CH"
NEW APP LOGISTICA

Class BAAppLogistica
	Data cApp
 
	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome único para a área.
 
@author   Helio Leal
@author   henrique.cesar
@since    05/03/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppLogistica
	::cApp := "Logistica"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensões) disponíveis da área, deve ser
necessariamente o nome das classes das entidades.
 
@author  Helio Leal
@author  Angelo Lee
@since   28/02/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppLogistica
Return  { ;
			"EMPRESA", ;
			"FILIAL", ;
			"DEPOSITO", ;
			"ITEM", ;
			"FAMMAT", ;
			"GRPESTOQUE", ;
			"UNMEDITEM", ;
			"CLIENTE", ;
			"FORNECEDOR", ;
			"ESTFISICA", ;
			"TIPESTFIS", ;
			"MOTBLOQUEIOSALDO", ;
			"OCUPARMAZEM", ;
			"DISPITEMESTOQUE", ;
			"DISPLOTEESTOQUE", ;
			"BLQSALITEMLOTE", ;
			"VOLDOCTOEXPEDICAO", ;
			"VOLITEMEXPEDICAO", ;
			"CICVIDEXPEDICAO", ;
			"CICVIDRECEBIMENTO", ;
			"CIDADEGFE", ;
			"EMITENTEGFE", ;
			"DOCUMENTOCARGAGFE", ;
			"ITEMDOCUMENTOCARGAGFE", ;
			"GFEOCORRENCIA", ;
			"GFECALCULADO", ;
			"GFECNH", ;
			"GFECTRATO", ;
			"TRECHODOCUMENTOCARGAGFE" 	};