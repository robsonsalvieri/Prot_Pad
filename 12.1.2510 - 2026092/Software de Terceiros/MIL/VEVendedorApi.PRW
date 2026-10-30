#include 'protheus.ch'

function VEVendedorApi()
return

/*/{Protheus.doc} VEVendedorApi
	Classe que representa tabela Sa3 de vendedores 
	
	@type function
	@author Vinicius Gati
	@since 14/11/2018
/*/ 
Class VEVendedorApi from VERegistroSql
	Method New() constructor
	Method GetStrRelField()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 14/11/2018
/*/
Method New() Class VEVendedorApi
	_Super:New('SA3')
	::AddFields({;
		"A3_FILIAL", "R_E_C_N_O_","A3_COD","A3_NOME","A3_NREDUZ","A3_BAIRRO",;
		"A3_MUN","A3_EST","A3_CEP","A3_DDDTEL","A3_TEL","A3_CGC";
	})
	// ::PermiteAssign({;
	// 	"A3_NREDUZ","A3_DDDTEL","A3_TEL";
	// })
	::HasOne("VEProdutivoApi", {{{||xFilial('VAI')}, 'VAI_FILIAL' }, {'VAI_CODVEN', 'A3_COD'}})
	::AddField("SA3.A3_FILIAL + SA3.A3_COD AS A3_UUID")
	::AddDefScope({|self| self:AndNotEq('A3_MSBLQL', '1') })
	::cFieldFil := 'A3_FILIAL'
Return SELF

/*/{Protheus.doc} GetStrField
	Retorna o campo que será usado como chave de relacao
	no json de quem herdar um cliente terá recno_SA3: com o valor definido neste metodo que será
	retornado do sql
	
	@type function
	@author Vinicius Gati
	@since 03/12/2018
/*/
Method GetStrRelField() Class VEVendedorApi
Return self:cAlias + ".A3_FILIAL + " + self:cAlias + ".A3_COD  as id_" + self:cAlias