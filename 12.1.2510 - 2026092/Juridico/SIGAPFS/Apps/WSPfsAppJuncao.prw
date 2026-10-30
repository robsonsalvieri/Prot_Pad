#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSPFSAPPJUNCAO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPfsAppJuncao
Métodos WS para Junção de contratos

@author Bruno Henrique Silva Soares
@since 04/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL WSPfsAppJuncao DESCRIPTION STR0001 // "Webservice para Junção de contratos"
	WSDATA pageSize     as Number
	WSDATA page         as Number

	WSMETHOD PUT  ListCaso   DESCRIPTION STR0002 PATH "listCaso"       PRODUCES APPLICATION_JSON // "Retorna dados de Casos"
	
	WSMETHOD POST JCtrCreate DESCRIPTION STR0003 PATH "juncaoContrato" PRODUCES APPLICATION_JSON // "Cria a Junção" 

End WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT ListCaso
Retorna a lista de Casos conforme contrato selecionado

@example PUT -> http://localhost:12173/rest/WSPfsAppJuncao/ListCaso?page=1&pageSize=10
@body - Exemplo de body da requisição:
			{
				"pkJuncao": "ICAgICAgICAwMDM1",
				"contratos": [
					"000330",
					"000331",
					"000332"
				]
			}

@param pageSize - Quantidade de itens por pagina
@param page     - Numero da paginação
			
@author Bruno Henrique Silva Soares
@since 05/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT ListCaso QUERYPARAM pageSize, page WSREST WSPfsAppJuncao
Local oJsonBody   := JsonObject():New()
Local oResponse   := JsonObject():New()
Local oNUT        := Nil
Local oNUTQtd     := Nil
Local cBody       := Self:GetContent()
Local cAlias      := GetNextAlias()
Local cQuery      := ""
Local cQueryQtd   := ""
Local aParams     := {}
Local aPaginacao  := {}
Local nTotal      := 0
Local nNumReg     := 0
Local lRet        := .T.

Default Self:page     := 1
Default Self:pageSize := 10

	If !Empty(cBody)
		oJsonBody:FromJson(cBody)
	EndIf

	aPaginacao := JStPagSize(Self:page, Self:pageSize)

	If VALTYPE(Self:page) == "C"
		Self:page := VAL(Self:page)
	EndIf

	If VALTYPE(Self:pageSize) == "C"
		Self:pageSize := VAL(Self:pageSize)
	EndIf

	cQuery += " SELECT NUT.NUT_CCONTR,"
	cQuery +=        " NT0.NT0_NOME,"
	cQuery +=        " NUT.NUT_CCLIEN,"
	cQuery +=        " NUT.NUT_CLOJA,"
	cQuery +=        " SA1.A1_NOME,"
	cQuery +=        " NUT.NUT_CCASO,"
	cQuery +=        " NVE.NVE_TITULO,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " RD0.RD0_CODIGO,"
	cQuery +=        " RD0.RD0_NOME"
	cQuery +=   " FROM " + RetSqlName("NUT") + " NUT"
	cQuery +=   " LEFT JOIN " + RetSqlName("NT0") + " NT0"
	cQuery +=     " ON (NT0.NT0_FILIAL = NUT.NUT_FILIAL"
	cQuery +=    " AND NT0.NT0_COD = NUT.NUT_CCONTR"
	cQuery +=    " AND NT0.D_E_L_E_T_ = ' ')"
	cQuery +=   " LEFT JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=     " ON (SA1.A1_COD = NUT.NUT_CCLIEN"
	cQuery +=    " AND SA1.A1_LOJA = NUT.NUT_CLOJA"
	cQuery +=    " AND SA1.D_E_L_E_T_ = ' ')"
	cQuery +=   " LEFT JOIN " + RetSqlName("NVE") + " NVE"
	cQuery +=     " ON (NVE.NVE_FILIAL = NUT.NUT_FILIAL"
	cQuery +=    " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN"
	cQuery +=    " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA"
	cQuery +=    " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO"
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' ')"
	cQuery +=   " LEFT JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=     " ON (RD0.RD0_FILIAL = NUT.NUT_FILIAL"
	cQuery +=    " AND RD0.RD0_CODIGO = NVE.NVE_CPART1"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' ')"
	cQuery +=  " WHERE NUT.NUT_CCONTR IN( ? )"
	aAdd(aParams, {"IN", oJsonBody['contratos']})
	cQuery +=    " AND NUT.D_E_L_E_T_ = ' '"
	cQueryQtd := cQuery
	cQuery +=  " ORDER BY NUT.NUT_CCONTR"

	oNUT := FWPreparedStatement():New(cQuery)
	oNUT := JQueryPSPr(oNUT, aParams)
	oNUTQtd := FWPreparedStatement():New(cQueryQtd)
	oNUTQtd := JQueryPSPr(oNUTQtd, aParams)

	cQuery := oNUT:GetFixQuery()
	MpSysOpenQuery(cQuery, cAlias)

	oResponse["casos"] := {}
	oResponse["hasNext"] := .F.

	While (cAlias)->(!EoF())
		nNumReg++
		If (aPaginacao[1] .and. nNumReg > aPaginacao[3])
			oResponse["hasNext"] := .T.
			Exit
		ElseIf (!aPaginacao[1] .Or. ;
				(aPaginacao[1] .And. nNumReg > aPaginacao[2] .And. nNumReg <= aPaginacao[3]))

			aAdd(oResponse["casos"], JsonObject():New())
			aTail(oResponse["casos"])["codContrato"]  := (cAlias)->NUT_CCONTR
			aTail(oResponse["casos"])["descContrato"] := JConvUTF8((cAlias)->NT0_NOME)
			aTail(oResponse["casos"])["codCliente"]   := (cAlias)->NUT_CCLIEN
			aTail(oResponse["casos"])["lojaCliente"]  := (cAlias)->NUT_CLOJA
			aTail(oResponse["casos"])["descCliente"]  := JConvUTF8((cAlias)->A1_NOME)
			aTail(oResponse["casos"])["codCaso"]      := (cAlias)->NUT_CCASO
			aTail(oResponse["casos"])["descCaso"]     := JConvUTF8((cAlias)->NVE_TITULO)
			aTail(oResponse["casos"])["sigPart"]      := (cAlias)->RD0_SIGLA
			aTail(oResponse["casos"])["codPart"]      := (cAlias)->RD0_CODIGO
			aTail(oResponse["casos"])["descPart"]     := JConvUTF8((cAlias)->RD0_NOME)
		EndIf

		(cAlias)->(dbSkip())
	EndDo

	nTotal := JTSQtdSql(oNUTQtd:GetFixQuery())
	oResponse["total"]   := nTotal
	oResponse["qtd"]     := Len(oResponse["casos"])

	(cAlias)->(dbCloseArea())
	aSize(aParams, 0)
	aParams := Nil

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := Nil
	oJsonBody := Nil
	oNUT      := Nil

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST JCtrCreate
Cria a Junção

@example POST -> localhost:12173/rest/WSPfsAppJuncao/juncaoContrato
@body - Exemplo de body da requisição:
		{
			"descricao": ""
            "contratoPrincipal": "",
            "listaContratos": [
                "","","","",""
            ]
        }

@author Willian Kazahaya
@since 06/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST JCtrCreate WSREST WSPfsAppJuncao
Local cFilOld     := cFilAnt
Local oModel      := Nil
Local oMdlNW3     := Nil
Local cBody       := Self:GetContent()
Local oBody       := JsonObject():New()
Local oResponse   := JSonObject():New()
Local lRet        := .T.
Local cCodJuncao  := ""
Local cAlsNt0     := ""
Local cContrPrinc := ""
Local cCodContr   := ""
Local cMsgErro    := ""
Local nI          := 0
Local aContrJunc  := {}

	oBody:FromJson(cBody)

	If (Len(oBody['listaContratos']) > 0 .And. !Empty(oBody['contratoPrincipal']))
		aContrJunc  := qryNW3Dados( oBody['listaContratos'] )
		If (Len(aContrJunc) == 0)
			cContrPrinc := oBody['contratoPrincipal']
			cAlsNt0     := qryNt0Dados( cContrPrinc )

			DbSelectArea("NT0")
			NT0->(DbSetOrder(1))
			If NT0->(DbSeek( xFilial("NT0") + cContrPrinc ))
				cFilAnt := (cAlsNt0)->NS7_CFILIA

				oModel := FwLoadModel("JURA056")
				oModel:SetOperation(MODEL_OPERATION_INSERT)
				oModel:Activate()

				oModel:LoadValue("NW2MASTER","NW2_CCLIEN", NT0->NT0_CCLIEN)
				oModel:SetValue("NW2MASTER","NW2_CLOJA", NT0->NT0_CLOJA)
				oModel:SetValue("NW2MASTER","NW2_CCONSU", cContrPrinc)
				oModel:SetValue("NW2MASTER","NW2_CPART", NT0->NT0_CPART1)
				oModel:SetValue("NW2MASTER","NW2_DESC", Decode64(oBody['descricao']))

				// Cadastra o Pagador na Junção com base no Contrato Principal
				SetMdlNXP( oModel )

				// Cadastra os Contratos da Junção
				oMdlNW3   := oModel:GetModel("NW3DETAIL")
				For nI := 1 To Len(oBody['listaContratos'])
					cCodContr := oBody['listaContratos'][nI]
					if (cCodContr != cContrPrinc)
						oMdlNW3:AddLine()
						oMdlNW3:SetValue("NW3_CCONTR", cCodContr)
					EndIf
				Next nI

				If (oModel:VldData() .And. oModel:CommitData())
					cCodJuncao := Encode64(oModel:GetValue("NW2MASTER","NW2_FILIAL") + ;
					                       oModel:GetValue("NW2MASTER","NW2_COD"))
				Else
					lRet := JRestError(500, oModel:GetErrorMessage()[06])
				EndIf
			Else
				lRet := JRestError(400, STR0004) // "Contrato principal não encontrado."
			EndIf
		Else
			For nI := 1 To Len(aContrJunc)
				cCodJuncao := aContrJunc[nI][1]
				cContrPrinc := aContrJunc[nI][2]
				//"Contratos(s): #1 já estão vinculados a junção #2."
				cMsgErro += I18n(STR0006 + CRLF, {cContrPrinc,cCodJuncao})
			Next nI

			//"O(s) contrato(s) selecionado(s) já se encontram vinculados a uma Junção de Contrato. #1 #2"
			lRet := JRestError(400, I18n(STR0005, {CRLF , cMsgErro} )) 
		EndIf
	Else
		lRet := JRestError(400, STR0007) // "Contrato principal e lista de contratos não informados."
	EndIf

	If (lRet)
		oResponse['chave-juncao'] := cCodJuncao
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
	EndIf
	
	oBody:FromJson("{}")
	aSize(aContrJunc, 0)
	cFilAnt := cFilOld
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMdlNXP( oModel, oMdl096NXP )
Define os dados de pagadores

@param oModel     - Modelo de Junção
@param oMdl096NXP - Modelo de Contrato

@author Willian Kazahaya
@since 06/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetMdlNXP( oModel, oMdl096NXP )
Local oModelNXP  := oModel:GetModel('NXPDETAIL')
Local cSQL := ""
Local aNXP := {}
Local nI   := 0

	cSQL := JA056QRY("NXP")
	
	aNXP := JurSQL(cSQL, "*")

	For nI := 1 To Len(aNXP)
		If nI > 1
			oModelNXP:AddLine()
		EndIf
		oModelNXP:SetValue( "NXP_CLIPG" , aNXP[nI][1])
		oModelNXP:SetValue( "NXP_LOJAPG", aNXP[nI][2])
		oModelNXP:SetValue( "NXP_PERCEN", aNXP[nI][14])
		oModelNXP:SetValue( "NXP_DESPAD", aNXP[nI][9])
		oModelNXP:SetValue( "NXP_CCONT" , aNXP[nI][3])
		oModelNXP:SetValue( "NXP_FPAGTO", aNXP[nI][4])
		oModelNXP:SetValue( "NXP_CCDPGT", aNXP[nI][5])
		oModelNXP:SetValue( "NXP_CBANCO", aNXP[nI][6])
		oModelNXP:SetValue( "NXP_CAGENC", aNXP[nI][7])
		oModelNXP:SetValue( "NXP_CCONTA", aNXP[nI][8])
		oModelNXP:SetValue( "NXP_CMOE"  , aNXP[nI][10])
		oModelNXP:SetValue( "NXP_CRELAT", aNXP[nI][11])
		oModelNXP:SetValue( "NXP_CIDIO" , aNXP[nI][12])
		oModelNXP:SetValue( "NXP_CIDIO2", aNXP[nI][13])
		oModelNXP:SetValue( "NXP_CNATPG", aNXP[nI][15])
		If (oModelNXP:CanSetValue("NXP_GROSHN"))
			oModelNXP:SetValue( "NXP_GROSHN", aNXP[nI][16])
		EndIf

		If (oModelNXP:CanSetValue("NXP_PERCGH")) 
			oModelNXP:SetValue( "NXP_PERCGH", aNXP[nI][17])
		EndIf
	Next nI
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} qryNt0Dados( cCodContr )
Busca a Filial do Contrato

@param cCodContr - Código do Contrato

@author Willian Kazahaya
@since 06/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function qryNt0Dados( cCodContr )
Local oQuery  := Nil
Local aParams := {}
Local cQuery  := ""
Local cAlsNt0 := ""

	cQuery := " SELECT NS7.NS7_CFILIA"
	cQuery +=   " FROM " + RetSqlName("NT0") + " NT0"
	cQuery +=  " INNER JOIN " + RetSqlName("NS7") + " NS7"
	cQuery +=     " ON (NS7.NS7_COD = NT0.NT0_CESCR"
	cQuery += 	 " AND NS7.D_E_L_E_T_ = ' ')"
	cQuery +=  " WHERE NT0.D_E_L_E_T_ = ' '"
	cQuery +=   " AND NT0.NT0_COD = ?"
	Aadd(aParams,{ "C", cCodContr })

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery   := JQueryPSPr(oQuery, aParams)

	cAlsNt0 := GetNextAlias()
	cQuery  := oQuery:GetFixQuery()

	MPSysOpenQuery(oQuery:GetFixQuery(), cAlsNt0)
Return cAlsNt0

//-------------------------------------------------------------------
/*/{Protheus.doc} qryNW3Dados( aCodCont )
Consulta de Contratos em Junções

@param aCodCont - Array de contratos

@author Willian Kazahaya
@since 06/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function qryNW3Dados( aCodCont )
Local aJuncao    := {}
Local aParams    := {}
Local cQuery     := ""
Local cAlsNW3    := ""
Local cCodContr  := ""
Local cCodJuncao := ""

	cQuery := " SELECT NW3.NW3_CJCONT, NW3.NW3_CCONTR"
	cQuery +=   " FROM " + RetSqlName("NW3") + " NW3"
	cQuery +=  " WHERE NW3.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NW3.NW3_CCONTR IN (?)"
	Aadd(aParams,{ "IN", aCodCont })

	cQuery +=  " ORDER BY NW3.NW3_CJCONT"
	
	oQuery := FWPreparedStatement():New(cQuery)
	oQuery := JQueryPSPr(oQuery, aParams)

	cAlsNW3 := GetNextAlias()
	MPSysOpenQuery(oQuery:GetFixQuery(), cAlsNW3)

	While ((cAlsNW3)->(!Eof()))
		If (Empty(cCodJuncao))
			cCodJuncao := (cAlsNW3)->NW3_CJCONT	
		ElseIf( cCodJuncao != (cAlsNW3)->NW3_CJCONT )
			aAdd(aJuncao, { cCodJuncao, SubStr(cCodContr, 1, Len(cCodContr) - 1) })
			cCodJuncao := (cAlsNW3)->NW3_CJCONT
		EndIf

		cCodContr += (cAlsNW3)->NW3_CCONTR + ","
		(cAlsNW3)->( DbSkip() )
	EndDo

	If (!Empty(cCodJuncao))
		aAdd(aJuncao, { cCodJuncao, SubStr(cCodContr, 1, Len(cCodContr) - 1)  })
	EndIf
Return aJuncao
