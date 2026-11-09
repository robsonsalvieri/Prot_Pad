#include "protheus.ch"

function VEClienteApi()
return

/*/{Protheus.doc} VEClienteApi
	Classe para ajudar na criação de APIs rest e regras de negócio para a mesma
	
	@type function
	@author Vinicius Gati
	@since 30/10/2018
/*/
class VEClienteApi from VERegistroSql
	method New() constructor
	method GetStrRelField() 
end class

/*/{Protheus.doc} New
	Construtor simples VEClienteApi

	@author Vinicius Gati
	@since  13/06/2014
/*/
Method New() Class VEClienteApi
	_Super:New('SA1')
	::AddFields({"R_E_C_N_O_","A1_MSBLQL","A1_FILIAL","A1_TIPO","A1_COD","A1_PESSOA","A1_LOJA","A1_NOME","A1_DDD","A1_TEL","A1_CGC","A1_NREDUZ","A1_EST","A1_COD_MUN","A1_BAIRRO","A1_CEP","A1_END","A1_MUN","A1_IBGE","A1_CONTATO","A1_INSCR","A1_PAIS","A1_TIPCLI","A1_GRPTRIB","A1_EMAIL","SA1.D_E_L_E_T_ as deleted"})
	::PermiteAssign({"A1_CONTATO","A1_DDD","A1_TEL","A1_EMAIL"})

	if SA1->(fieldPos("A1_XGRPCLI")) > 0
		::AddFields({"A1_XGRPCLI"})
		::PermiteAssign({"A1_XGRPCLI"})
	endif
	if SA1->(fieldPos("A1_XDATALT")) > 0
		::AddFieldsTimestamp({"A1_XDATALT"})
		::AddFields({"A1_XDATALT"})
	endif
	if SA1->(fieldPos("A1_XDATINC")) > 0
		::AddFieldsTimestamp({"A1_XDATINC"})
		::AddFields({"A1_XDATINC"})
	endif
	If SA1->(FieldPos("A1_YESTCOB")) > 0
		::AddFields({"A1_YESTCOB"})
		::PermiteAssign({"A1_YESTCOB"})
	endif

	::HasOne('VEDadosAdicionaisClienteApi', {{{||xFilial('VCF')}, 'VCF_FILIAL'}, {'VCF_CODCLI', 'A1_COD'}, {'VCF_LOJCLI', 'A1_LOJA'}})

	::AddField(::cQAlias + ".A1_FILIAL + " + ::cQAlias + ".A1_COD + " + ::cQAlias + ".A1_LOJA AS A1_UUID")

	::SetPKField(::cQAlias + ".A1_FILIAL + " + ::cQAlias + ".A1_COD + " + ::cQAlias + ".A1_LOJA")

	::cFieldFil := 'A1_FILIAL'
Return Self

/*/{Protheus.doc} GetStrField
	Retorna o campo que será usado como chave de relacao
	no json de quem herdar um cliente terá recno_SA1: com o valor definido neste metodo que será
	retornado do sql
	
	@type function
	@author Vinicius Gati
	@since 03/12/2018
/*/
Method GetStrRelField() Class VEClienteApi
Return self:cQAlias + ".A1_FILIAL + " + self:cQAlias + ".A1_COD + " + self:cQAlias + ".A1_LOJA" + " as id_" + self:cQAlias