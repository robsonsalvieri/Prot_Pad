#include 'protheus.ch'
#include 'TOPCONN.ch'

Class VEAprovacoesInfosAdapter from FWAdapterBaseV2
	public data codcli as character
	public data loja as character
	//indicador na requisição para a totalização por loja na query
	public data tLoja as logical

	Method new(cVerb) constructor
	Method setCodCli(cCodCli)
	Method setLoja(cLoja)
	Method setTLoja(lTLoja)
	Method getInfoClientes(lSomaLoja)
	Method getParcelasAbertas()
	Method _querySE1()
	Method _getTotalizadoresCliente()
EndClass

Method new(cVerb) class VEAprovacoesInfosAdapter
	_Super:new(cVerb, .T.)
	::tLoja := .f. //padroniza a totalização por loja como false
return self

Method setTLoja(lTLoja) class VEAprovacoesInfosAdapter
	::tLoja := lTLoja
Return

Method setCodCli(cCodCli) class VEAprovacoesInfosAdapter
	::codcli := cCodCli
return 

Method setLoja(cLoja) class VEAprovacoesInfosAdapter
	::loja := cLoja
return

/*/{Protheus.doc} _getTotalizadoresCliente
	Vai retornar alguns totalizadores que foram usados no semáforo para ser inserido no json enviado ao front-end 
	@author Renan Migliaris
	@since 31/08/2025
	/*/
Method _getTotalizadoresCliente() class VEAprovacoesInfosAdapter
	local aDados := {}
	local cQuery := ''
	local nTotVei := GetNewPar("MV_MIL0045", "1") //verifica se vai considerar titulos de veiculos também
	local cMVPreVei := GetNewPar("MV_PREFVEI", "VEI")
	local TMPSE1 := "TMPSE1"
	local aParams := {}

	cQuery := " SELECT SE1.E1_FILIAL , "
	cQuery +=       " SE1.E1_TIPO , "
	cQuery +=       " SE1.E1_NUM , "
	cQuery +=       " SE1.E1_PARCELA , "
	cQuery +=       " SE1.E1_EMISSAO , "
	cQuery +=       " SE1.E1_VENCREA , "
	cQuery +=       " SE1.E1_VALOR, "
	cQuery +=       " SE1.E1_SALDO "
	cQuery += " FROM " + RetSqlName( "SE1" ) + " SE1 "
	cQuery += "WHERE "
	cQuery +=       " SE1.E1_CLIENTE = ? AND "
	aadd(aParams, self:codCli)

	If ::tLoja // Credito por loja
		cQuery +=       " SE1.E1_LOJA = ? AND "
		aadd(aParams, self:loja)
	EndIf

	if nTotVei == "0"
	 	cQuery += "SE1.E1_PREFORI <> ? AND "
		aadd(aParams, cMVPreVei)	
	endif

	cQuery +=       " SE1.E1_SALDO <> 0 AND "
	cQuery +=       " SE1.D_E_L_E_T_=' ' "
	cQuery += " ORDER BY SE1.E1_FILIAL , SE1.E1_VENCREA , SE1.E1_NUM , SE1.E1_PARCELA "

	dbUseArea(.t., "TOPCONN", TcGenQry(,,VF0000012_AddParamsNoStatement(cQuery, aParams)), TMPSE1, .t., .t.)
	aDados := JsonObject():new()
	aDados["nValor"] := 0 //total em aberto
	aDados["nValCre"] := 0 //total em aberto de credito
	aDados["nValVenc"] := 0 //total em aberto vencido

	Do While !( TMPSE1 )->( Eof() )
		If ( TMPSE1 )->E1_TIPO $ 'NCC.RA '
			aDados["nValCre"] += ( TMPSE1 )->E1_SALDO
		Else
			aDados["nValor"] += ( TMPSE1 )->E1_SALDO
			If stod(( TMPSE1 )->E1_VENCREA) < dDataBase
				aDados["nValVenc"] += ( TMPSE1 )->E1_SALDO
			Endif
		EndIf
		dbSelectArea(TMPSE1)
		( TMPSE1 )->(dbSkip())
	Enddo
	( TMPSE1 )->(DbCloseArea())
Return aDados

Method getInfoClientes() class VEAprovacoesInfosAdapter
	local aArea 		:= {}
	local oResp 		:= nil
	local cQuery 		:= ''
	local cReturn 		:= ''
	local totalizadores := nil
	aArea := FwGetArea()
	cQuery := " SELECT SA1.A1_COD, SA1.A1_RISCO, SA1.A1_NOME "
		
	If ::tLoja
		cQuery += ", SA1.A1_LOJA "
	EndIf
	
	cQuery += ", SUM(SA1.A1_LC) AS A1_LC"
	cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
	cQuery += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery +=	 " AND SA1.A1_COD = '"    + ::codcli + "' "
	
	If ::tLoja
		cQuery += " AND SA1.A1_LOJA = '" + ::loja + "' "
	EndIf

	cQuery +=	 " AND SA1.D_E_L_E_T_ = ' ' "
	cQuery +=	 " GROUP BY SA1.A1_COD, SA1.A1_RISCO, SA1.A1_NOME "
	
	If ::tLoja
		cQuery += ", SA1.A1_LOJA"
	EndIf

	TCQUERY cQuery  NEW ALIAS "TMPSA1"
	oResp := JsonObject():new()
	oResp["a1_cod"		] 	:= TMPSA1->A1_COD
	oResp["a1_lc"		]	:= TMPSA1->A1_LC
	oResp["a1_risco"	]	:= TMPSA1->A1_RISCO
	oResp["a1_nome"		]	:= TMPSA1->A1_NOME

	if ::tLoja
		oResp["a1_loja"]	:= TMPSA1->A1_LOJA
	endif

	TMPSA1->(dbCloseArea())
	
	dbSelectArea("VCF")
	dbSetOrder(1)
	dbSeek(xFilial("VCF") +::codcli+::loja)
	oResp["vcf_nivimp"	]	:= VCF->VCF_NIVIMP //nivel de importância titulo
	oResp["vcf_areven"	]	:= VCF->VCF_AREVEN //area de venda 
	VCF->(dbCloseArea())

	dbSelectArea("VCB")
	dbSetOrder(1)
	DbSeek(xfilial("VCB") + oResp["vcf_areven"])
	oResp["vcb_desreg" 	]	:= VCB->VCB_DESREG //descrição da região de venda
	VCB->(dbCloseArea())

	totalizadores := ::_getTotalizadoresCliente()
	oResp["nValCre"] := totalizadores["nValCre"] //total em aberto de credito
	oResp["nValor"] := totalizadores["nValor"] //total em aberto
	oResp["nValVenc"] := totalizadores["nValVenc"] //total em aberto vencido
	oResp["nDif"] := oResp["a1_lc"] - totalizadores["nValor"] //diferença entre o total em aberto e o limite de crédito
	oResp["nAndamento"] := FG_AVALCRED(::codcli,::loja) //andamento (OS+Orc)
	
	cReturn := oResp:toJson()
	FwRestArea(aArea)
return cReturn

Method getParcelasAbertas() class VEAprovacoesInfosAdapter
	local aArea		:= {}
	local cWhere := ''
	local cOrder := ''
	aArea := FwGetArea()
	// cWhere += " E1_FILIAL = '"+xFilial("SE1")+"'"
	cWhere += " E1_CLIENTE = '"+::codcli+"'"
	if ::tLoja 
		cWhere += " AND E1_LOJA = '"+::loja+"'"
	endif
	cWhere += " AND E1_SALDO <> 0 "
	cWhere += " AND D_E_L_E_T_ = ' ' "

	cOrder := " E1_FILIAL , E1_VENCREA , E1_NUM , E1_PARCELA "

	setSE1Fields(self)
	::SetQuery(::_querySE1())
	::SetWhere(cWhere)
	::SetOrder(cOrder)

	if ::Execute()
		::FillGetResponse()
	endif

	FwRestArea(aArea)
return

Method _querySE1() class VEAprovacoesInfosAdapter
	local cQuery := ''
	cQuery := " SELECT #QueryFields# "
	cQuery += " FROM " + RetSqlName("SE1")
	cQUery += " WHERE #QueryWhere# "
return cQuery

/*/{Protheus.doc} setSE1Fields
	seta os campos SE1 da Adapter
	@type  Static Function
	@author Renan Migliaris
	@since 04/04/2025
/*/
Static Function setSE1Fields(oSelf)
	oSelf:AddMapFields("E1_FILIAL"	,   "E1_FILIAL"	 ,  .t., .f.)
    oSelf:AddMapFields("E1_TIPO"	,   "E1_TIPO"	 ,  .t., .f.)
    oSelf:AddMapFields("E1_NUM"		,	"E1_NUM"	 ,  .t., .f.)
    oSelf:AddMapFields("E1_PARCELA"	, 	"E1_PARCELA" ,  .t., .f.)
    oSelf:AddMapFields("E1_EMISSAO"	, 	"E1_EMISSAO" ,  .t., .f.)
    oSelf:AddMapFields("E1_VENCREA"	, 	"E1_VENCREA" ,  .t., .f.)
    oSelf:AddMapFields("E1_VALOR"	,   "E1_VALOR"	 ,  .t., .f.)
    oSelf:AddMapFields("E1_SALDO"	,   "E1_SALDO"	 ,  .t., .f.)
Return