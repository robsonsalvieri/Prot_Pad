#include 'protheus.ch'

function VEProdutivoApi()
return

/*/{Protheus.doc} VEProdutivoApi
	Classe criada para controlar informacao e dados relacionados a produtivo 
	
	@type function
	@author Vinicius Gati
	@since 14/11/2018
/*/ 
Class VEProdutivoApi from VERegistroSql
	method New() constructor
EndClass 

/*/{Protheus.doc} New
	Construtor simples VEFrotaApi

	@author Vinicius Gati
	@since  13/06/2014
/*/
Method New() Class VEProdutivoApi
	_Super:New('VAI')
	::AddFieldsData({"VAI_DATDEM"})
	::AddFields({;
		"VAI_FILIAL","R_E_C_N_O_","VAI_CODTEC","VAI_NOMTEC","VAI_CPF"   ,"VAI_FUNCAO",;
		"VAI_EMAIL" ,"VAI_CODUSR","VAI_NOMUSU","VAI_FILPRO","VAI_CEVDIA","VAI_APROVA",;
		"VAI_CODVEN","VAI_DATDEM","VAI_UUID","D_E_L_E_T_";
	})
	::PermiteAssign({;
		"VAI_NOMTEC","VAI_EMAIL";
	})
	// relacoes
	::HasOne("VEVendedorApi", {{ {||xFilial('SA3')}, 'A3_FILIAL' }, {'A3_COD', 'VAI_CODVEN'}})
	::AddDefScope({|self| self:AndNotEq('VAI_UUID', ' ') })
Return SELF 