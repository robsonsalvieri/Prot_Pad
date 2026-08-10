#include "totvs.ch"
#include "parmtype.ch"

/*/{Protheus.doc} OFIMargemEDescontoAdapter
Classe Adapter para o serviço de aprovações aprova mil
@author Renan Migliaris
/*/
Class OFIMargemEDescontoAdapter From FWAdapterBaseV2
	public data cAprvlm
	public data cAprvlv
	public data aFilter

    Method New(cVerb) constructor
	Method getReprovados(cSearch, cFilter)
	Method getAprovacoes(cSearch, cFilter)
	Method getPecAproacao(cSearch, cFilter)
	Method getServAproacao(cSearch, cFilter)
	Method setAprvlv(cAprvlv)
	Method setAprVlm(cAprvlm)
	Method checkVS6(cNumIde)
	Method _getQueryAprovacoes()
	Method _getQueryItensAprovacao()
    
EndClass

Method New(cVerb, aFilter) class OFIMargemEDescontoAdapter
	default aFilter := {}
    _Super:New(cVerb, .T.)
	::aFilter := aFilter
return self

Method setAprvlv(cAprvlv) class OFIMargemEDescontoAdapter
	::cAprvlv := cAprvlv
return

Method setAprVlm(cAprvlm) class OFIMargemEDescontoAdapter
	::cAprvlm := cAprvlm
return

/*/{Protheus.doc} getReprovados
	Retorna as solicitações de aprovação que foram rejeitadas/reprovadas
	@type  Static Function
	@author Renan Migliaris
	@since 17/03/2025	
	@see https://tdn.totvs.com/display/public/framework/09.+FWAdapterBaseV2
/*/
Method getReprovados(cSearch, cFilter) class OFIMargemEDescontoAdapter
	local aArea 		:= {}
	local cWhere 		:= ''
	local aSearch		:= {}
	local oSqlHelper 	:= DMS_SqlHelper():new()
	local cSafeSearch	:= ''
	local cSCodCli		:= ''
	local cSLoja		:= ''
	default cSearch 	:= ''
	default cFilter 	:= ''
	
	aArea 				:= FwGetArea()
	
	getReprFields(self)
	::SetQuery(GetReprovadosQuery())

	cWhere += " VS6.VS6_DATREJ <> ' ' "
	cWhere += " AND VS6.VS6_USUREJ <> ' ' "
	cWhere += " AND VS6.VS6_HORREJ <> ' ' "
	cWhere += " AND VS6.D_E_L_E_T_ = ' ' "

if !Empty(cSearch)
	aSearch := SplitCodCliLoja(cSearch)
	if len(aSearch) == 1
		cSafeSearch := oSqlHelper:_escapeSql(aSearch[1])
		cWhere += " AND ( "
		cWhere += " 	VS6.VS6_USUREJ LIKE '%" + cSafeSearch + "%'"
		cWhere += "	 OR VS6.VS6_CODCLI = '" + cSafeSearch + "'"
		cWhere += "	 OR VS6.VS6_NUMORC = '" + cSafeSearch + "'"
		cWhere += "  OR VS6.VS6_NUMIDE = '"+ cSafeSearch + "'"
		cWhere += " )"
	elseif len(aSearch) > 1
		cSCodCli := oSqlHelper:_escapeSql(aSearch[1])
		cSLoja := oSqlHelper:_escapeSql(aSearch[2]) 
		cWhere += " AND VS6.VS6_CODCLI = '" + cSCodCli + "'"
		cWhere += " AND VS6.VS6_LOJA = '" + cSLoja + "'"
	endif
endif

	::SetWhere(cWhere)
	::SetOrder("VS6.VS6_DATREJ")

	if ::Execute()
		::FillGetResponse()
	endif
	freeobj(oSqlHelper)
	FwRestArea(aArea)
return

/*/{Protheus.doc} getAprovacoes
	Método para fornecer ao endpoint os itens a serem aprovados. 
	@author Renan Migliaris	
	@since 17/03/2025
/*/
Method getAprovacoes(cSearch, cFilter) class OFIMargemEDescontoAdapter
	local aArea			:= {}
	local cWhere 		:= ''
	local aSearch 		:= {}
	local oSqlHelper 	:= DMS_SqlHelper():new()
	local cSafeSearch	:= ''
	local cSCodCli		:= ''
	local cSLoja		:= ''
	default cSearch		:= ''
	default cFilter 	:= ''
	aArea 				:= FwGetArea()

	getAprFields(self)
	::SetQuery(::_GetQueryAprovacoes())

	cWhere := OF015001J_RetornaQueryAdapter()
	cWhere += " AND VS6.D_E_L_E_T_ =  ' '"

	if !Empty(alltrim(cSearch))
		aSearch := SplitCodCliLoja(cSearch)
		if Len(aSearch) == 1
			cSafeSearch := oSqlHelper:_escapeSql(aSearch[1])
			cWhere += " AND (VS6.VS6_NUMIDE = '" + cSafeSearch + "'"
			cWhere += " OR VS6.VS6_CODCLI = '" + cSafeSearch + "'"
			cWhere += " OR VS6.VS6_NUMORC = '" + cSafeSearch+ "')"
		elseif Len(aSearch) > 1
			cSCodCli := oSqlHelper:_escapeSql(aSearch[1])
			cSLoja := oSqlHelper:_escapeSql(aSearch[2])
			cWhere += " AND VS6.VS6_CODCLI = '" + cSCodCli + "'"
			cWhere += " AND VS6.VS6_LOJA = '" + cSLoja + "'"
		endif
	endif

	::SetWhere( cWhere )

	if ::Execute()
		::FillGetResponse()
	endif
	
	FwRestArea(aArea)
return

/*/{Protheus.doc} getPecAproacao
	Método para fornecer ao endpoint as peças do item a ser aprovado. 
	@author Bruno Forcato
	@since 07/04/2025
/*/
Method getPecAproacao(cSearch, cFilter) class OFIMargemEDescontoAdapter
	local aArea			:= {}
	local cWhere 		:= ''
	default cSearch		:= ''
	default cFilter 	:= ''
	aArea 				:= FwGetArea()

	getAprPecFields(self)
	::SetQuery(::_getQueryItensAprovacao())

	cWhere += " VS7.D_E_L_E_T_ = ' '"

	if !Empty(AllTrim(cFilter))
		cWhere += " AND VS7.VS7_NUMIDE = '" + cFilter + "'"
		cWhere += " AND VS7.VS7_CODITE <> ''"
	endif

	::SetWhere( cWhere )

	if ::Execute()
		::FillGetResponse()
	endif

	FwRestArea(aArea)
return

/*/{Protheus.doc} getServAproacao
	Método para fornecer ao endpoint as peças do item a ser aprovado. 
	@author Bruno Forcato
	@since 07/04/2025
/*/
Method getServAproacao(cSearch, cFilter) class OFIMargemEDescontoAdapter
	local aArea			:= {}
	local cWhere 		:= ''
	default cSearch		:= ''
	default cFilter 	:= ''
	aArea 				:= FwGetArea()

	getAprServFields(self)
	::SetQuery(::_getQueryItensAprovacao())

	cWhere += " VS7.D_E_L_E_T_ = ' '"

	if !Empty(AllTrim(cFilter))
		cWhere += " AND VS7.VS7_NUMIDE = '" + cFilter + "'"
		cWhere += " AND VS7.VS7_CODSER <> ''"
	endif

	::SetWhere( cWhere )

	if ::Execute()
		::FillGetResponse()
	endif

	FwRestArea(aArea)
return
/*/{Protheus.doc} _QueryAprovacoes
	Método para setar a query das aprovações pendentes
	@author Renan Migliaris	
	@since 17/03/2025
/*/
Method _GetQueryAprovacoes() class OFIMargemEDescontoAdapter
    local cQuery    	:= ''
	cQuery := " SELECT #QueryFields#"
	cQuery += " FROM "+ RetSqlName( 'VS6' ) + " VS6 "
	cQuery +=   " LEFT JOIN " + RetSqlName( 'SA1' ) + " SA1"
	cQuery +=       " ON VS6_CODCLI = A1_COD "
	cQuery +=           " AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE #QueryWhere#"
Return cQuery

/*/{Protheus.doc} _getQueryItensAprovacao
	Método para setar a query dos item da aprovação
	@author Bruno Forcato
	@since 07/04/2025
/*/
Method _getQueryItensAprovacao() class OFIMargemEDescontoAdapter
    local cQuery    	:= ''
	cQuery := " SELECT #QueryFields#"
	cQuery += 	" FROM "+ RetSqlName( 'VS7' ) + " VS7 "
	cQuery += " WHERE #QueryWhere#"
Return cQuery

/*/{Protheus.doc} getReprFields
	Faz o mapeamento dos fields a serem utilizados pela FWAdapterBaseV2
	@type  Static Function
	@author Renan Migliaris
	@since 17/03/2025	
	@see https://tdn.totvs.com/display/public/framework/09.+FWAdapterBaseV2
/*/
Static Function getReprFields(oSelf)
    oSelf:AddMapFields("VS6_DATAUT", 	"VS6_DATAUT", 	.T., 	.F., 	{ "VS6_DATAUT", "D", 8, 	0 	})
    oSelf:AddMapFields("VS6_DATREJ", 	"VS6_DATREJ", 	.T., 	.F., 	{ "VS6_DATREJ", "D", 8, 	0 	})
    oSelf:AddMapFields("VS6_TIPAUT", 	"VS6_TIPAUT", 	.T., 	.F., 	{ "VS6_TIPAUT", "C", 1, 	0 	})
    oSelf:AddMapFields("VS6_NUMIDE", 	"VS6_NUMIDE", 	.T., 	.F., 	{ "VS6_NUMIDE", "C", 10, 	0 	})
    oSelf:AddMapFields("VS6_TIPOCO", 	"VS6_TIPOCO", 	.T., 	.F., 	{ "VS6_TIPOCO", "C", 6, 	0 	})
	oSelf:AddMapFields("VS6_USUREJ", 	"VS6_USUREJ", 	.T., 	.F., 	{ "VS6_USUREJ", "C", 15, 	0 	})
	oSelf:AddMapFields("VS6_DATREJ", 	"VS6_DATREJ", 	.T., 	.F., 	{ "VS6_DATREJ", "D", 8, 	0 	})
	oSelf:AddMapFields("VS6_HORREJ", 	"VS6_HORREJ", 	.T., 	.F., 	{ "VS6_HORREJ", "N", 4, 	0 	})
	oSelf:AddMapFields("VS0_DESMOT", 	"VS0_DESMOT", 	.T., 	.F.,	{ "VS0_DESMOT", "C", 40,	0 	})
	oSelf:AddMapFields("A1_NREDUZ", 	"A1_NREDUZ", 	.T.,	.F.)
return

/*/{Protheus.doc} GetReprovadosQuery
	Retorna a query base para as reprovações 
	@author Renan Migliaris
	@since 17/03/2025
/*/
Static Function GetReprovadosQuery()
	local cQuery	:= ''
	
	cQuery := " SELECT #QueryFields#"
	cQuery += " FROM "+ RetSqlName( 'VS6' ) + " VS6 "
	cQuery +=   " LEFT JOIN " + RetSqlName( 'VS0' ) + " VS0"
	cQuery +=       " ON VS6_MOTREJ = VS0_CODMOT "
	cQuery +=       	" AND VS0_TIPASS = '000016'"
	cQuery +=           " AND VS0.D_E_L_E_T_ = ' '"
	cQuery += 	" LEFT JOIN " + RetSqlName( 'SA1' ) +" SA1 "
	cQuery += 		" ON VS6_LOJA = A1_LOJA "
	cQuery += 			" AND VS6_CODCLI = A1_COD "
	cQuery += " WHERE #QueryWhere#"
	
Return cQuery

/*/{Protheus.doc} getAprFields
	Faz o mapeamento dos fields a serem utilizados pela FWAdapterBaseV2
	@type  Static Function
	@author Renan Migliaris
	@since 26/03/2025
	@see https://tdn.totvs.com/display/public/framework/09.+FWAdapterBaseV2
/*/
Static Function getAprFields(oSelf)
	oSelf:AddMapFields("VS6_FILIAL", "VS6_FILIAL", .T., .F., { "VS6_FILIAL", "C", 3,  0 })
    oSelf:AddMapFields("VS6_DATAUT", "VS6_DATAUT", .T., .F., { "VS6_DATAUT", "D", 8,  0 })
    oSelf:AddMapFields("VS6_DATREJ", "VS6_DATREJ", .T., .F., { "VS6_DATREJ", "D", 8,  0 })
    oSelf:AddMapFields("VS6_TIPAUT", "VS6_TIPAUT", .T., .F., { "VS6_TIPAUT", "C", 1,  0 })
    oSelf:AddMapFields("VS6_NUMIDE", "VS6_NUMIDE", .T., .F., { "VS6_NUMIDE", "C", 10, 0 })
    oSelf:AddMapFields("VS6_TIPOCO", "VS6_TIPOCO", .T., .F., { "VS6_TIPOCO", "C", 6,  0 })
    oSelf:AddMapFields("VS6_NUMORC", "VS6_NUMORC", .T., .F., { "VS6_NUMORC", "C", 10, 0 })
	oSelf:AddMapFields("VS6_OBSMEM", "VS6_OBSMEM", .T., .T., { "VS6_OBSMEM", "C", 6, 0 })
	oSelf:AddMapFields("VS6_DATOCO", "VS6_DATOCO", .T., .F., { "VS6_DATOCO", "D", 8, 0 })
	oSelf:AddMapFields("VS6_HOROCO", "VS6_HOROCO", .T., .F., { "VS6_HOROCO", "N", 4, 0 })
	oSelf:AddMapFields("VS6_DESOCO", "VS6_DESOCO", .T., .F., { "VS6_DESOCO", "C", 30, 0 })
	oSelf:AddMapFields("VS6_USUARI", "VS6_USUARI", .T., .F., { "VS6_USUARI", "C", 15, 0 })
	oSelf:AddMapFields("VS6_CODCLI", "VS6_CODCLI", .T., .F., { "VS6_CODCLI", "C", 15, 0 })
	oSelf:AddMapFields("VS6_LOJA", "VS6_LOJA", .T., .F., { "VS6_LOJA", "C", 15, 0 })
Return

/*/{Protheus.doc} getAprPecFields
	Faz o mapeamento dos fields a serem utilizados pela FWAdapterBaseV2
	@type  Static Function
	@author Bruno Forcato
	@since 07/04/2025	
	@see https://tdn.totvs.com/display/public/framework/09.+FWAdapterBaseV2
/*/
Static Function getAprPecFields(oSelf)
    oSelf:AddMapFields("VS7_GRUITE", 	"VS7_GRUITE", 	.T., 	.F., 	{ "VS7_GRUITE", "C", 4, 	0 	})
    oSelf:AddMapFields("VS7_CODITE", 	"VS7_CODITE", 	.T., 	.F., 	{ "VS7_CODITE", "C", 27, 	0 	})
    oSelf:AddMapFields("VS7_DESPER", 	"VS7_DESPER", 	.T., 	.F., 	{ "VS7_DESPER", "N", 7, 	0 	})
    oSelf:AddMapFields("VS7_DESDES", 	"VS7_DESDES", 	.T., 	.F., 	{ "VS7_DESDES", "N", 7, 	0 	})
    oSelf:AddMapFields("VS7_VALORI", 	"VS7_VALORI", 	.T., 	.F., 	{ "VS7_VALORI", "N", 14, 	0 	})
	oSelf:AddMapFields("VS7_VALPER", 	"VS7_VALPER", 	.T., 	.F., 	{ "VS7_VALPER", "N", 14, 	0 	})
	oSelf:AddMapFields("VS7_VALDES", 	"VS7_VALDES", 	.T., 	.F., 	{ "VS7_VALDES", "N", 14, 	0 	})
	oSelf:AddMapFields("VS7_MARLUC", 	"VS7_MARLUC", 	.T., 	.F., 	{ "VS7_MARLUC", "N", 7, 	0 	})
	oSelf:AddMapFields("VS7_MARPER", 	"VS7_MARPER", 	.T., 	.F.,	{ "VS7_MARPER", "N", 7,		0 	})
	oSelf:AddMapFields("VS7_QTDITE", 	"VS7_QTDITE", 	.T., 	.F.,	{ "VS7_QTDITE", "N", 10,	0 	})
return 

/*/{Protheus.doc} getAprServFields
	Faz o mapeamento dos fields a serem utilizados pela FWAdapterBaseV2
	@type  Static Function
	@author Bruno Forcato
	@since 07/04/2025	
	@see https://tdn.totvs.com/display/public/framework/09.+FWAdapterBaseV2
/*/
Static Function getAprServFields(oSelf)
    oSelf:AddMapFields("VS7_GRUSER", 	"VS7_GRUSER", 	.T., 	.F., 	{ "VS7_GRUSER", "C", 4, 	0 	})
    oSelf:AddMapFields("VS7_CODSER", 	"VS7_CODSER", 	.T., 	.F., 	{ "VS7_CODSER", "C", 27, 	0 	})
	oSelf:AddMapFields("VS7_TIPSER", 	"VS7_TIPSER", 	.T., 	.F., 	{ "VS7_TIPSER", "C", 3, 	0 	})
    oSelf:AddMapFields("VS7_DESPER", 	"VS7_DESPER", 	.T., 	.F., 	{ "VS7_DESPER", "N", 7, 	0 	})
    oSelf:AddMapFields("VS7_DESDES", 	"VS7_DESDES", 	.T., 	.F., 	{ "VS7_DESDES", "N", 7, 	0 	})
    oSelf:AddMapFields("VS7_VALORI", 	"VS7_VALORI", 	.T., 	.F., 	{ "VS7_VALORI", "N", 14, 	0 	})
	oSelf:AddMapFields("VS7_VALPER", 	"VS7_VALPER", 	.T., 	.F., 	{ "VS7_VALPER", "N", 14, 	0 	})
	oSelf:AddMapFields("VS7_VALDES", 	"VS7_VALDES", 	.T., 	.F., 	{ "VS7_VALDES", "N", 14, 	0 	})
	oSelf:AddMapFields("VS7_QTDITE", 	"VS7_QTDITE", 	.T., 	.F.,	{ "VS7_QTDITE", "N", 10,	0 	})
return 


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
