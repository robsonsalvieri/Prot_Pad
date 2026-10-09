#include "totvs.ch"
#include "parmtype.ch"

/*/{Protheus.doc} VEAtendimentoAdapter
Classe Adapter para o serviço de aprovações aprova mil
@author Renan Migliaris
/*/
Class VEAtendimentoAdapter From FWAdapterBaseV2
	public data cAprvlm
	public data cAprvlv

    Method New(cVerb) constructor
	Method getAprovacoes(cSearch, cFilter)
	Method getReprovados(cSearch, cFilter)
	Method _getQueryVV9()
    
EndClass

Method New(cVerb) class VEAtendimentoAdapter
    _Super:New(cVerb, .T.)
return self


/*/{Protheus.doc} getAprovacoes
	Método para fornecer ao endpoint os itens a serem aprovados. 
	@author Bruno Forcato	
	@since 22/04/2025
/*/
Method getAprovacoes(cSearch, cFilter) class VEAtendimentoAdapter
	local aArea			:= {}
	local cWhere 		:= ''
	local aSearch		:= {}
	local oSqlHelper 	:= DMS_SqlHelper():new()
	local cSafeSearch	:= ''
	local cSCodCli		:= ''
	local cSLoja		:= ''
	local cAprova		:= ''
	default cSearch		:= ''
	default cFilter 	:= ''
	aArea 				:= FwGetArea()

	getVV9Fields(self)
	::SetQuery(::_getQueryVV9())

	dbSelectArea("VAI")
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
	cAprova := VAI->VAI_APROVA
	VAI->(dbCloseArea())
	
	if cAprova == "1"
		cWhere += " VV9.VV9_STATUS = 'P' "
	elseif cAprova == "2"
		cWhere += " VV9.VV9_STATUS IN ('P', 'O') "
	elseif cAprova == "3"
		cWhere += " VV9.VV9_STATUS = 'A' "
	else
	  	// caso vazio ou inválido
    	cWhere += " VV9.VV9_STATUS = 'P' "
	endif

	cWhere += " AND VV9.D_E_L_E_T_ = ' ' "
	cWhere += "AND VV9.VV9_FILIAL = "+xFilial("VV9")

	if !Empty(AllTrim(cSearch))
		aSearch := SplitCodCliLoja(cSearch)

		cWhere += "AND ("

		if len(aSearch) == 1
			cSafeSearch := oSqlHelper:_escapeSql(aSearch[1])
			cWhere += " VV9.VV9_NUMATE = '" + cSafeSearch + "'"
			cWhere += " OR VV9.VV9_FILIAL = '" + cSafeSearch + "'"
			cWhere += " OR VV9.VV9_CODCLI = '" + cSafeSearch + "'"
			cWhere += " OR VV9.VV9_LOJA LIKE '%" + cSafeSearch + "%'"
		elseif len(aSearch) > 1 
			cSCodCli := oSqlHelper:_escapeSql(aSearch[1])
			cSLoja := oSqlHelper:_escapeSql(aSearch[2])
			cWhere += "VV9.VV9_CODCLI = '"+ cSCodCli +"' AND VV9.VV9_LOJA = '"+ cSLoja +"'" 
		endif

		cWhere += " )"
	endif

	::SetWhere( cWhere )

	if ::Execute()
		::FillGetResponse()
	endif
	
	FwRestArea(aArea)
return

/*/{Protheus.doc} getReprovados
	Método para fornecer ao endpoint os itens que foram reprovados. 
	@author Bruno Forcato	
	@since 22/04/2025
/*/
Method getReprovados(cSearch, cFilter) class VEAtendimentoAdapter
	local aArea			:= {}
	local cWhere 		:= ''
	local oSqlHelper	:= DMS_SqlHelper():New()
	local cSafeSearch   := ''
	default cSearch		:= ''
	default cFilter 	:= ''
	aArea 				:= FwGetArea()

	getVV9Fields(self)
	::SetQuery(::_getQueryVV9())

	cWhere := "VV9.VV9_STATUS = 'R' AND VV9.D_E_L_E_T_ = ' ' "
	if !Empty(cSearch)
		cSafeSearch := oSqlHelper:_escapeSql(cSearch)
		cWhere += " AND ( "
		cWhere += "	 (SA1.A1_NOME LIKE '%" + cSafeSearch + "%')"
		cWhere += "  OR (SA1.A1_NREDUZ LIKE '%" + cSafeSearch + "%')"
		cWhere += "  OR (SA1.A1_CGC = '" + cSafeSearch + "')"
		cWhere += "  OR (VV9.VV9_NUMATE = '" + cSafeSearch + "')"
		cWhere += " ) "
	endif

	::SetWhere( cWhere )

	if ::Execute()
		::FillGetResponse()
	endif
	
	FwRestArea(aArea)
return


/*/{Protheus.doc} getAprFields
	Faz o mapeamento dos fields a serem utilizados pela FWAdapterBaseV2
	@type  Static Function
	@author Bruno Forcato
	@since 22/04/2025
	@see https://tdn.totvs.com/display/public/framework/09.+FWAdapterBaseV2
/*/
Static Function getVV9Fields(oSelf)
	oSelf:AddMapFields("VV9_FILIAL", "VV9_FILIAL", .T., .F.)
    oSelf:AddMapFields("VV9_NUMATE", "VV9_NUMATE", .T., .F.)
    oSelf:AddMapFields("VV9_STATUS", "VV9_STATUS", .T., .F.)
    oSelf:AddMapFields("VV9_CODCLI", "VV9_CODCLI", .T., .F.)
    oSelf:AddMapFields("VV9_LOJA", "VV9_LOJA", .T., .F.)
    oSelf:AddMapFields("VV9_TELVIS", "VV9_TELVIS", .T., .F.)
    oSelf:AddMapFields("VV9_NOMVIS", "VV9_NOMVIS", .T., .F.)
	oSelf:AddMapFields("VV9_MODVEI", "VV9_MODVEI", .T., .T.)
	oSelf:AddMapFields("A1_NOME", "A1_NOME", .T., .F.)
Return

/*/{Protheus.doc} _QueryAprovacoes
	Método para setar a query das aprovações pendentes
	@author Bruno Forcato
	@since 22/04/2025
/*/
Method _getQueryVV9() class VEAtendimentoAdapter
    local cQuery    	:= ''
	cQuery := " SELECT #QueryFields#"
	cQuery += " FROM "+ RetSqlName( 'VV9' ) + " VV9 "
	cQuery +=   " LEFT JOIN " + RetSqlName( 'SA1' ) + " SA1"
	cQuery +=       " ON VV9_CODCLI = A1_COD "
	cQuery +=           " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE #QueryWhere#"
Return cQuery


/*/{Protheus.doc} splitCodcliLoja
	Faz a separação do cSearch para a busca de codcli e loja
	Caso o usuário busque utilizando codcli + loja num modelo 00000 01 
	a função "quebra" a string e colca os dois elementos num array para utilização no cWhere composto por codcli + loja 
	@type  Static Function
	@author Renan Migliaris
	@since 25/03/2025
/*/
Static Function splitCodcliLoja(cSearch)
	local aSearch 	:= {}
	local nPos		:= 0

	nPos := At(" ", cSearch)

	if nPos > 0
		aAdd(aSearch, AllTrim(SubStr(cSearch, 1, nPos - 1))) // CodCli
        aAdd(aSearch, AllTrim(SubStr(cSearch, nPos + 1)))    // Loja
	else
		aadd(aSearch, AllTrim(cSearch))
	endif
	
Return aSearch
