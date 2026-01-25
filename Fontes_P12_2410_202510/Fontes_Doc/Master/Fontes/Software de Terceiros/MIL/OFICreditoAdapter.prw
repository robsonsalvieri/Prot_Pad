#include 'totvs.ch'
#include "parmtype.ch"


/*/{Protheus.doc} OFICreditoAdapter
	Adapter criada para consultas api das aprovações de créditos. 
	@author Renan Migliaris
	@since 09/04/2025
	/*/
Class OFICreditoAdapter from FWAdapterBaseV2
	public data numOrc
	public data numLib

	method new(cVerb) constructor
	method setNumOrc(cNumOrc)
	method setNumLib(cNumLib)
	method getAprovacoesCredito(cSearch, cFilter)
	method getItensAprovacaoCredito(cSearch, cFilter)
	method getOfixa019OrcsApr(cSearch, cFilter, cId)
	method getVO3(cSearch, cFilter)
	method getVO4(cSearch, cFilter)
	method _getQueryCredito()
	method _getQueryOfixa019()
	method _getQueryItens()
	method _getVO3Query()
	method _getVO4Query()
EndClass

/*/{Protheus.doc} OFICreditoAdapter new
	Método construtor da classe
	@author Renan Migliaris
	@since 09/04/2025
	/*/
method new(cVerb) class OFICreditoAdapter
	_Super:New(cVerb, .t.)
return self

/*/{Protheus.doc} OFICreditoAdapter setNumOrc
	Seta o numORc como uma proprieda da classe. A intenção é que o numOrc funcione como um id para os retornos da api
	@author Renan Migliaris
	@since 09/04/2025
	/*/
method setNumOrc(cNumOrc) class OFICreditoAdapter
	::numOrc := cNumOrc
return

/*/{Protheus.doc} OFICreditoAdapter setNumLib
	Seta o NumLib como uma proprieda da classe. A intenção é que o NumLib funcione como um id para os retornos da api
	@author Bruno Forcato
	@since 16/04/2025
	/*/
method setNumLib(cNumLib) class OFICreditoAdapter
	::numLib := cNumLib
return


/*/{Protheus.doc} OFICreditoAdapter
	Retorna aprovações de crédito 
	@author Renan Migliaris
	/*/
method getAprovacoesCredito(cSearch, cFilter) class OFICreditoAdapter
	local aArea	:= {}
	local cWhere := ''
	local oSqlHelper := DMS_SqlHelper():new()
	local cSafeSearch := ''
	default cSearch := ''
	default cFilter := ''
	aArea := FwGetArea()

	getVs1Fields(self)
	::SetQuery(::_getQueryCredito())

	cWhere += " VS1.VS1_STATUS = '3'" //fase orçamento aprovação balcao
	cWhere += " AND VS1.D_E_L_E_T_ = ' '"

	if !empty(self:numOrc)
		cWhere += " AND VS1.VS1_NUMORC = '"+alltrim(self:numOrc)+"'"
	endif

	if !empty(cSearch)
		cSafeSearch := oSqlHelper:_escapeSql(cSearch)
		cWhere += " AND ("
		cWhere += " VS1.VS1_NCLIFT = '"+alltrim(cSafeSearch)+"'"
		cWhere += " OR VS1.VS1_CLIFAT = '"+alltrim(cSafeSearch)+"'"
		cWhere += " OR SA3.A3_NOME = '"+alltrim(cSafeSearch)+"'"
		cWhere += " OR VS1.VS1_NUMORC = '"+alltrim(cSafeSearch)+"'"
		cWhere += " ) "
	endif

	cWhere += "AND VS1.VS1_FILIAL = "+xFilial("VS1")
	::SetWhere(cWhere)

	if ::Execute()
		::FillGetResponse()
	endif
	freeobj(oSqlHelper)
	FwRestArea(aArea)
return
/*/{Protheus.doc} OFICreditoAdapter
	Retorna os itens de aprovações de crédito
	/*/
method getItensAprovacaoCredito(cSearch, cFilter) class OFICreditoAdapter
	local aArea	:= {}
	local cWhere := ''
	default cSearch := ''
	default cFilter := ''
	aArea := FwGetArea()

	getVs3Fields(self)
	::SetQuery(::_getQueryItens())
	
	cWhere += " VS3.D_E_L_E_T_ = ' '"
	if !empty(self:numOrc)
		cWhere += " AND VS3.VS3_NUMORC = '"+alltrim(self:numOrc)+"'"
	endif

	::SetWhere(cWhere)

	if ::Execute()
		::FillGetResponse()
	endif

	FwRestArea(aArea)
return .t.

/*/{Protheus.doc} OFICreditoAdapter
	Retorna oramentos para aprovacao da ofixa019
	/*/
method getOfixa019OrcsApr(cSearch, cFilter, cId) CLASS OFICreditoAdapter

    Local aArea     := {}
    Local cWhere    := ''
    Local oSqlHelp  := DMS_SqlHelper():new()
	local cSafeSearch := ''
    Local cFunc     := ''
    Local cConcat   := ''
    Local cDataRef  := ''
    Local cTamDthLib := ''
    
    Default cSearch := ''
    Default cFilter := ''
	aArea := FwGetArea()

    getOfixa019Fields(self)
    ::SetQuery(::_getQueryOfixa019())

    cFunc := oSqlHelp:CompatFunc("SUBSTR")
    cConcat := oSqlHelp:Concat({cFunc + "(VSW_DATHOR,7,2)", cFunc + "(VSW_DATHOR,4,2)",cFunc + "(VSW_DATHOR,1,2)" })
    cDataRef := Right(dtos(ddatabase - GetNewPar("MV_MIL0017",15)), 6)
    cTamDthLib := Space(TamSX3("VSW_DTHLIB")[1])
    cWhere := cFunc + "(VSW_NUMORC,1,2) = 'OS'"
    cWhere += " AND " + cConcat + " > '" + cDataRef + "'"
    cWhere += " AND VSW_DTHLIB = '" + cTamDthLib + "'"
	cWhere += " AND D_E_L_E_T_ = ' ' "
	cWhere += " AND VSW_FILIAL = "+xFilial("VSW")

	if !empty(cId)
		cWhere += " AND VSW_LIBVOO = '" +cId+ "'" 
	endif

	if !empty(cSearch)
		cSafeSearch := oSqlHelp:_escapeSql(cSearch)
		cWhere += " AND ("
		cWhere += " VSW_NUMORC = '"+alltrim(cSafeSearch)+"'"
		cWhere += " OR VSW_CODCLI = '"+alltrim(cSafeSearch)+"'"
		cWhere += " OR VSW_LOJA = '"+alltrim(cSafeSearch)+"'"
		cWhere += " ) "
	endif

    ::SetWhere(cWhere)

	if ::Execute()
		::FillGetResponse()
	endif
	
	freeobj(oSqlHelp)
    FwRestArea(aArea)
Return .t.

/*/{Protheus.doc} OFICreditoAdapter getVO3
	Monta o adapter para buscar os dados da VO3 
	@author Bruno Forcato
	@since 16/04/2025
/*/
method getVO3(cSearch, cFilter) class OFICreditoAdapter
	local aArea	:= {}
	local cWhere := ''
	default cSearch := ''
	default cFilter := ''
	aArea := FwGetArea()

	getVO3Fields(self)
	::SetQuery(::_getVO3Query())
	
	cWhere += " VO3.D_E_L_E_T_ = ' '"
	if !empty(self:numLib)
		cWhere += " AND VO3.VO3_LIBVOO = '"+alltrim(self:numLib)+"'"
	endif

	::SetWhere(cWhere)

	if ::Execute()
		::FillGetResponse()
	endif

	FwRestArea(aArea)
return .t.

/*/{Protheus.doc} OFICreditoAdapter getVO4
	Monta o adapter para buscar os dados da VO4
	@author Bruno Forcato
	@since 16/04/2025
/*/
method getVO4(cSearch, cFilter) class OFICreditoAdapter
	local aArea	:= {}
	local cWhere := ''
	default cSearch := ''
	default cFilter := ''
	aArea := FwGetArea()

	getVO4Fields(self)
	::SetQuery(::_getVO4Query())
	
	cWhere += " VO4.D_E_L_E_T_ = ' '"
	if !empty(self:numLib)
		cWhere += " AND VO4.VO4_LIBVOO = '"+alltrim(self:numLib)+"'"
	endif

	::SetWhere(cWhere)

	if ::Execute()
		::FillGetResponse()
	endif

	FwRestArea(aArea)
return .t.


/*/{Protheus.doc} OFICreditoAdapter setNumOrc
	Monta a query que irá buscar os pendentes de aprovação de crédito
	@author Renan Migliaris
	@since 09/04/2025
	/*/
method _getQueryCredito() class OFICreditoAdapter
	local cQuery := ''

	cQuery := " SELECT #QueryFields# "
	cQuery += " FROM "+RetSqlName("VS1")+" VS1 "
	cQuery +=   " LEFT JOIN " + RetSqlName( 'SE4' ) + " SE4"
	cQuery +=       " ON E4_CODIGO = VS1_FORPAG "
	cQuery +=   " LEFT JOIN " + RetSqlName( 'SA3' ) + " SA3"
	cQuery +=       " ON A3_COD = VS1_CODVEN "
	cQuery += " WHERE #QueryWhere#"
return cQuery

/*/{Protheus.doc} getVs1Fields
	Monta os campos da Vs1 que serão utilizados pela adapter 
	@type  Static Function
	@author Renan Migliaris
	@since 09/04/2025
/*/
Static Function getVs1Fields(oSelf)
	oSelf:AddMapFields("VS1_FILIAL", "VS1_FILIAL", .t., .f., { "VS1_FILIAL", "C", 2, 	0 	})
	oSelf:AddMapFields("VS1_NUMORC", "VS1_NUMORC", .t., .f., { "VS1_NUMORC", "C", 8, 	0 	})
	oSelf:AddMapFields("VS1_NCLIFT", "VS1_NCLIFT", .t., .f., { "VS1_NCLIFT", "C", 40, 	0 	})
	oSelf:AddMapFields("VS1_LOJA"  , "VS1_LOJA"  , .t., .f., { "VS1_LOJA"  , "C", 2, 	0 	})
	oSelf:AddMapFields("VS1_DATALT", "VS1_DATALT", .t., .f., { "VS1_DATALT", "D", 8, 	0 	})
	oSelf:AddMapFields("VS1_DATVAL", "VS1_DATVAL", .t., .f., { "VS1_DATVAL", "D", 8, 	0 	})
	oSelf:AddMapFields("VS1_STATUS", "VS1_STATUS", .t., .f., { "VS1_STATUS", "C", 1, 	0 	})
	oSelf:AddMapFields("VS1_TIPORC", "VS1_TIPORC", .t., .f., { "VS1_TIPORC", "C", 1, 	0 	})
	oSelf:AddMapFields("VS1_PEDSTA", "VS1_PEDSTA", .t., .f., { "VS1_PEDSTA", "C", 1, 	0 	})
	oSelf:AddMapFields("VS1_CLIFAT", "VS1_CLIFAT", .t., .f., { "VS1_CLIFAT", "C", 6, 	0 	})
	oSelf:AddMapFields("E4_DESCRI",  "E4_DESCRI",  .t., .f., { "E4_DESCRI",  "C", 15, 	0 	})
	oSelf:AddMapFields("A3_NOME", 	 "A3_NOME",	   .t., .f., { "A3_NOME", 	 "C", 40,	0 	})
Return

/*/{Protheus.doc} OFICreditoAdapter _getQueryOfixa019
	Monta a query que irá buscar os  Itens da aprovação de crédito da parte de Oficina
	@author Bruno Forcato
	@since 14/04/2025
	/*/
method _getQueryOfixa019() class OFICreditoAdapter
	local cQuery := ''

	cQuery := " SELECT #QueryFields# "
	cQuery += " FROM "+RetSqlName("VSW")+" VSW "
	cQuery += " WHERE #QueryWhere#"
return cQuery

/*/{Protheus.doc} getOfixa019Fields
	Monta os campos da aprovação de crédito ofixa019
	@type  Static Function
	@author Renan Migliaris
	@since 15/04/2025
/*/
Static Function getOfixa019Fields(oSelf)
	oSelf:AddMapFields("VSW_NUMORC", "VSW_NUMORC", .t., .f.)
	oSelf:AddMapFields("VSW_CODCLI", "VSW_CODCLI", .t., .f.)
	oSelf:AddMapFields("VSW_LIBVOO", "VSW_LIBVOO", .t., .f.)
	oSelf:AddMapFields("VSW_LOJA"  , "VSW_LOJA"  , .t., .f.)
	oSelf:AddMapFields("VSW_USUARI", "VSW_USUARI", .t., .f.)
	oSelf:AddMapFields("VSW_VALCRE", "VSW_VALCRE", .t., .f.)
	oSelf:AddMapFields("VSW_DATHOR", "VSW_DATHOR", .t., .f.)
	oSelf:AddMapFields("VSW_DTHLIB", "VSW_DTHLIB", .t., .f.)
	oSelf:AddMapFields("VSW_MOTIVO", "VSW_MOTIVO", .t., .f.)
	oSelf:AddMapFields("VSW_NUMATE", "VSW_NUMATE", .t., .f.)
	oSelf:AddMapFields("VSW_RISANT", "VSW_RISANT", .t., .f.)
	oSelf:AddMapFields("VSW_LCANT" , "VSW_LCANT" , .t., .f.)
	oSelf:AddMapFields("VSW_TIPTEM", "VSW_TIPTEM", .t., .f.)
	oSelf:AddMapFields("RECNO", "R_E_C_N_O_", .t., .f., { "R_E_C_N_O_", "N", 15, 0 })
Return

/*/{Protheus.doc} OFICreditoAdapter _getQueryItens
	Monta a query que irá buscar os  Itens da aprovação de crédito
	@author Bruno Forcato
	@since 14/04/2025
	/*/
method _getQueryItens() class OFICreditoAdapter
	local cQuery := ''

	cQuery := " SELECT #QueryFields# "
	cQuery += " FROM "+RetSqlName("VS3")+" VS3 "
	cQuery += " WHERE #QueryWhere#"
return cQuery

/*/{Protheus.doc} OFICreditoAdapter getVs3Fields
	Monta os campos da VS3 que serão utilizados pela adapter 
	@author Bruno Forcato
	@since 14/04/2025
/*/
Static Function getVs3Fields(oSelf)
	oSelf:AddMapFields("VS3_GRUITE", "VS3_GRUITE", .t., .f., { "VS3_GRUITE", "C", 4, 	0 	})
	oSelf:AddMapFields("VS3_CODITE", "VS3_CODITE", .t., .f., { "VS3_CODITE", "C", 27, 	0 	})
	oSelf:AddMapFields("VS3_VALPEC", "VS3_VALPEC", .t., .f., { "VS3_VALPEC", "N", 14, 	0 	})
	oSelf:AddMapFields("VS3_QTDITE", "VS3_QTDITE", .t., .f., { "VS3_QTDITE", "N", 10, 	0 	})
	oSelf:AddMapFields("VS3_CODTES", "VS3_CODTES", .t., .f., { "VS3_CODTES", "C", 3, 	0 	})
	oSelf:AddMapFields("VS3_PERDES", "VS3_PERDES", .t., .f., { "VS3_PERDES", "N", 7, 	0 	})
	oSelf:AddMapFields("VS3_VALTOT", "VS3_VALTOT", .t., .f., { "VS3_VALTOT", "N", 12, 	0 	})
Return

/*/{Protheus.doc} OFICreditoAdapter _getVO3Query
	Monta a query que irá buscar os peças da aprovação de crédito da parte de Oficina
	@author Bruno Forcato
	@since 16/04/2025
	/*/
method _getVO3Query() class OFICreditoAdapter
	local cQuery := ''

	cQuery := " SELECT #QueryFields# "
	cQuery += " FROM "+RetSqlName("VO3")+" VO3 "
	cQuery += " WHERE #QueryWhere#"
return cQuery

/*/{Protheus.doc} OFICreditoAdapter getVO3Fields
	Monta os campos da VO3 que serão utilizados pela adapter 
	@author Bruno Forcato
	@since 16/04/2025
/*/
Static Function getVO3Fields(oSelf)
	oSelf:AddMapFields("VO3_FILIAL", "VO3_FILIAL", .t., .f.)
	oSelf:AddMapFields("VO3_TIPTEM", "VO3_TIPTEM", .t., .f.)
	oSelf:AddMapFields("VO3_LOJA"  , "VO3_LOJA"  , .t., .f.)
	oSelf:AddMapFields("VO3_GRUITE", "VO3_GRUITE", .t., .f.)
	oSelf:AddMapFields("VO3_CODITE", "VO3_CODITE", .t., .f.)
	oSelf:AddMapFields("VO3_QTDREQ", "VO3_QTDREQ", .t., .f.)
	oSelf:AddMapFields("VO3_OPER"  , "VO3_OPER"  , .t., .f.)
	oSelf:AddMapFields("VO3_VALPEC", "VO3_VALPEC", .t., .f.)
	oSelf:AddMapFields("VO3_CODTES", "VO3_CODTES", .t., .f.)
	oSelf:AddMapFields("VO3_LIBVOO", "VO3_LIBVOO", .t., .f.)
Return

/*/{Protheus.doc} OFICreditoAdapter _getVO4Query
	Monta a query que irá buscar os Serviços da aprovação de crédito da parte de Oficina
	@author Bruno Forcato
	@since 16/04/2025
	/*/
method _getVO4Query() class OFICreditoAdapter
	local cQuery := ''

	cQuery := " SELECT #QueryFields# "
	cQuery += " FROM "+RetSqlName("VO4")+" VO4 "
	cQuery += " WHERE #QueryWhere#"
return cQuery

/*/{Protheus.doc} OFICreditoAdapter getVO4Fields
	Monta os campos da VO4 que serão utilizados pela adapter 
	@author Bruno Forcato
	@since 16/04/2025
/*/
Static Function getVO4Fields(oSelf)
	oSelf:AddMapFields("VO4_FILIAL", "VO4_FILIAL", .t., .f.)
	oSelf:AddMapFields("VO4_TIPTEM", "VO4_TIPTEM", .t., .f.)
	oSelf:AddMapFields("VO4_LOJA"  , "VO4_LOJA"  , .t., .f.)
	oSelf:AddMapFields("VO4_FATPAR", "VO4_FATPAR", .t., .f.)
	oSelf:AddMapFields("VO4_GRUSER", "VO4_GRUSER", .t., .f.)
	oSelf:AddMapFields("VO4_CODSER", "VO4_CODSER", .t., .f.)
	oSelf:AddMapFields("VO4_TIPSER", "VO4_TIPSER", .t., .f.)
	oSelf:AddMapFields("VO4_DATINI", "VO4_DATINI", .t., .f.)
	oSelf:AddMapFields("VO4_HORINI", "VO4_HORINI", .t., .f.)
	oSelf:AddMapFields("VO4_DATFIN", "VO4_DATFIN", .t., .f.)
	oSelf:AddMapFields("VO4_HORFIN", "VO4_HORFIN", .t., .f.)
	oSelf:AddMapFields("VO4_LIBVOO", "VO4_LIBVOO", .t., .f.)
Return
