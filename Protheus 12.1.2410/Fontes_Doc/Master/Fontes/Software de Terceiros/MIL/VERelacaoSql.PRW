#include 'protheus.ch'

function VERelacaoSql()
return

/*/{Protheus.doc} VERelacaoSql
	Classe que representa uma relacao entre tabelas
	Será criada diretamente pela classe registroSql
	para melhorar a forma de uso.
	
	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/ 
Class VERelacaoSql
	Data oObj
	Data lCacheObj
	Data lCacheQry
	Data cTipo
	Data cClasse
	Data aChaves
	Data cQuery

	// {'ONE', 'SA1', { {'VC3_CODCLI', 'A1_COD'    }, {'VC3_LOJA'  , 'A1_LOJA'   }}, {'RELA.R_E_C_N_O_'}, {'RELA.R_E_C_N_O_'}};
	Method New() CONSTRUCTOR
	Method GetAlias()
	Method GetObj()
	Method GetTableName()
	Method GetDefaultScope()
	Method GetTipo()
	Method SetQuery()
	Method GetQuery()
	Method GetChaves()
	Method GetQueryAlias()
EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/
Method New(cTipo, cClasse, aChaves) Class VERelacaoSql
	::lCacheObj := .f.
	::lCacheQry := .f.
	::cTipo     := 'ONE'
	::aChaves   := aChaves
	::cClasse   := cClasse
	::cQuery    := ''
Return SELF

/*/{Protheus.doc} GetQueryAlias
	retorna o alias o objeto

	@type function
	@author Vinicius Gati
	@since 13/12/2018
/*/
Method GetQueryAlias() Class VERelacaoSql
Return self:GetObj():GetQueryAlias()

/*/{Protheus.doc} GetDefaultScope
	pega escopo padrao para adicionar nos joins

	@type function
	@author Vinicius Gati
	@since 10/12/2018
/*/
Method GetDefaultScope() Class VERelacaoSql
	local aScope  := self:GetObj():aDefScope
	aeval(aScope, {|scope| eval(scope, self:GetObj()) })
	aScope := self:GetObj():aConditions
	self:GetObj():Clear()
Return aScope

/*/{Protheus.doc} GetObj
	Retorna um objeto de classe do tipo da relacao

	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/
Method GetObj() Class VERelacaoSql
	if ! self:lCacheObj
		self:oObj      := &(self:cClasse + "():New()")
		self:lCacheObj := .t.
	endif
Return self:oObj

/*/{Protheus.doc} GetAliass
	Retorna o alias que representa a relacao

	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/
Method GetAlias() Class VERelacaoSql
Return self:GetObj():cAlias

/*/{Protheus.doc} GetTableName
	Retorna nome da tabela do alias da relacao

	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/
Method GetTableName(cAlias) Class VERelacaoSql
	if valtype(cAlias) == "C"
		return RetSqlName(self:GetObj():cAlias) + " " + cAlias
	endif
Return RetSqlName(self:GetObj():cAlias)

/*/{Protheus.doc} GetChaves
	Retorna as chaves do relacionamento para montar query

	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/
Method GetChaves() Class VERelacaoSql
Return self:aChaves

/*/{Protheus.doc} GetTipo
	Retorna o tipo da relacao

	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/
Method GetTipo() Class VERelacaoSql
Return self:cTipo

/*/{Protheus.doc} SetQuery
	Seta a query gravando um cache da relacao

	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/
Method SetQuery(cQuery) Class VERelacaoSql
	self:cQuery    := cQuery
	self:lCacheQry := .t.
Return .t.

/*/{Protheus.doc} GetQuery
	Pega query do cache

	@type function
	@author Vinicius Gati
	@since 16/11/2018
/*/
Method GetQuery() Class VERelacaoSql
Return self:cQuery
