#include 'protheus.ch'

/*/{Protheus.doc} VEDadosAdicionaisClienteApi
	Classe responsavel por tratar dados que entraram ou serao buscado na tabela VCF
	
	@type function
	@author Vinicius Gati
	@since 29/11/2018
/*/
Class VEDadosAdicionaisClienteApi from VERegistroSql
	method New() constructor
	method GetStrRelField()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 29/11/2018
/*/
Method New() Class VEDadosAdicionaisClienteApi
	_Super:New('VCF')
	::AddFields({;
		"VCF_FILIAL", "VCF_CODCLI", "VCF_LOJCLI", "VCF_LATITU","VCF_LONGIT","VCF_VENPEC",;
		"VCF_VENVEI","VCF_VENSRV","VCF_VENVEU","VCF_VENPNE","VCF_VENOUT","VCF_DIAPEP","VCF_DIAPER",;
		"VCF_DIAPES","VCF_DIAVEU","VCF_DIAPNE","VCF_DIAOUT","VCF_OFIPRO", "VCF_UUID","R_E_C_N_O_";
	})

	::PermiteAssign({;
		"VCF_LATITU","VCF_LONGIT","VCF_VENPEC","VCF_VENVEI","VCF_VENSRV","VCF_VENVEU","VCF_VENPNE","VCF_VENOUT",;
		"VCF_DIAPEP","VCF_DIAPER","VCF_DIAPES","VCF_DIAVEU","VCF_DIAPNE","VCF_DIAOUT","VCF_OFIPRO","id_SA1";
	})
	::HasOne('VEClienteApi', {{{||xFilial('SA1')}, 'A1_FILIAL'}, {'VCF_CODCLI', 'A1_COD'}, {'VCF_LOJCLI', 'A1_LOJA'}})
	::AddDefScope({|self| self:AndNotEq('VCF_UUID', ' ') })
Return SELF

/*/{Protheus.doc} GetStrField
	Retorna o campo que será usado como chave de relacao
	no json de quem herdar um cliente terá recno_SA1: com o valor definido neste metodo que será
	retornado do sql
	
	@type function
	@author Vinicius Gati
	@since 03/12/2018
/*/
Method GetStrRelField() Class VEDadosAdicionaisClienteApi
Return self:cAlias + ".VCF_UUID as id_" + self:cAlias