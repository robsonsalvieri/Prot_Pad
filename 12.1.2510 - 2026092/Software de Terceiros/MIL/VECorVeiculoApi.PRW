#include 'protheus.ch'
#include 'VECorVeiculoApi.ch'

/*/{Protheus.doc} VECorVeiculoApi
	Classe de cor de veiculos
	
	@type function
	@author Vinicius Gati
	@since 06/12/2018
/*/
Class VECorVeiculoApi from VERegistroSql
	Method New() constructor
	Method GetStrRelField()
	Method BeforeDelete()
	Method Validate()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 06/12/2018
/*/
Method New() Class VECorVeiculoApi
	_Super:New('VVC')
	::AddFields({"VVC_FILIAL","R_E_C_N_O_","VVC_DESCRI","VVC_UUID","VVC_CODMAR","VVC_CORVEI"})
Return SELF

/*/{Protheus.doc} GetStrField
	Retorna o campo que será usado como chave de relacao
	no json de quem herdar um cliente terá recno_SA1: com o valor definido neste metodo que será
	retornado do sql
	
	@type function
	@author Vinicius Gati
	@since 03/12/2018
/*/
Method GetStrRelField() Class VECorVeiculoApi
Return self:GetQueryAlias() + ".VVC_UUID as id_" + self:cAlias

/*/{Protheus.doc} BeforeDelete
	Evita o delete deste modelo

	@type function
	@author Vinicius Gati
	@since 26/09/2019
/*/
Method BeforeDelete() Class VECorVeiculoApi
	self:AddError("API", STR0001) //"Não é permitido deletar este modelo via api."
Return _Super:BeforeDelete()

/*/{Protheus.doc} Validate
	Evita alteracao deste modelo

	@type function
	@author Vinicius Gati
	@since 26/09/2019
/*/
Method Validate() Class VECorVeiculoApi
	self:AddError("API", STR0002) //"Não é permitido alteração ou criação deste modelo"
Return _Super:Validate()
