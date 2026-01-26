#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "WSPFSALTLOTE.CH"

Static _JWSAltLote := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WSPFSAltLote
Métodos WS da Alteração em lote do SIGAPFS

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSRESTFUL WSPFSAltLote DESCRIPTION STR0001 // "Webservice PFS - Alteração em Lote"

WSDATA codPart      as String
WSDATA entidade     as String
WSDATA searchKey    as String
WSDATA qtdTotal     as Boolean
WSDATA socioRevisor as Boolean
WSDATA pageSize     as Number
WSDATA page         as Number
WSDATA codCliente   as String

	WSMETHOD GET clientes        DESCRIPTION STR0002  PATH "cliente/{codPart}"                PRODUCES APPLICATION_JSON  // "Busca os clientes no qual o participante é sócio / revisor"
	WSMETHOD GET casos           DESCRIPTION STR0003  PATH "caso/{codPart}"                   PRODUCES APPLICATION_JSON  // "Busca os casos no qual o participante é sócio / revisor"
	WSMETHOD GET contratos       DESCRIPTION STR0004  PATH "contrato/{codPart}"               PRODUCES APPLICATION_JSON  // "Busca os contratos no qual o participante é sócio / revisor"
	WSMETHOD GET juncaoContratos DESCRIPTION STR0005  PATH "juncaoContrato/{codPart}"         PRODUCES APPLICATION_JSON  // "Busca registrso da junção no qual o participante é sócio / revisor"
	WSMETHOD GET preFaturas      DESCRIPTION STR0006  PATH "preFatura/{codPart}"              PRODUCES APPLICATION_JSON  // "Busca pre faturas no qual o participante é sócio / revisor"
	WSMETHOD GET fatAdicional    DESCRIPTION STR0007  PATH "faturaAdicional/{codPart}"        PRODUCES APPLICATION_JSON  // "Busca as faturas adicionais no qual o participante é sócio / revisor"
	WSMETHOD GET timesheet       DESCRIPTION STR0008  PATH "timesheet/{codPart}"              PRODUCES APPLICATION_JSON  // "Busca os time sheets no qual o participante é sócio / revisor"
	WSMETHOD GET titReceber      DESCRIPTION STR0009  PATH "tituloReceber/{codPart}"          PRODUCES APPLICATION_JSON  // "Busca os títulos a receber no qual o participante é sócio / revisor"
	WSMETHOD GET fatura          DESCRIPTION STR0010  PATH "fatura/{codPart}"                 PRODUCES APPLICATION_JSON  // "Busca as faturas no qual o participante é sócio / revisor"
	WSMETHOD GET socRevList      DESCRIPTION STR0017  PATH "listSociosRev/{entidade}"         PRODUCES APPLICATION_JSON  // "Busca a lista de sócios / revisores"

	WSMETHOD PUT altPreFatura    DESCRIPTION STR0011  PATH "revisor/preFatura/{codPart}"      PRODUCES APPLICATION_JSON  // "Alteração do Revisor na Pré-fatura"
	WSMETHOD PUT altContrato     DESCRIPTION STR0018  PATH "revisor/contrato/{codPart}"       PRODUCES APPLICATION_JSON  // "Alteração do sócio responsável do contrato"
	WSMETHOD PUT altCaso         DESCRIPTION STR0030  PATH "revisor/caso/{codPart}"           PRODUCES APPLICATION_JSON  // "Alteração de revisor e sócio do caso"
	WSMETHOD PUT altJuncoes      DESCRIPTION STR0027  PATH "revisor/juncaoContrato/{codPart}" PRODUCES APPLICATION_JSON  // "Alteração do sócio responsável das junções de contrato"
	WSMETHOD PUT altCliente      DESCRIPTION STR0034  PATH "revisor/cliente/{codPart}"        PRODUCES APPLICATION_JSON  // "Alteração do sócio responsável do cliente"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET clientes
Busca os clientes no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/cliente/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET clientes PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local lHasReg    := .F.
Local nIndPage   := 0
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aParams    := {}
Local aPaginacao := SetPagSize(Self:page, Self:pageSize)

Default cCodPart := ""
Default lTotal   := .F.

	cQuery := WSALQryCli(lTotal, @aParams, cCodPart)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cAlias, .T., .F. )
	lHasReg := !(cAlias)->(EOF())

	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If lHasReg
		If lTotal
			oResponse['total']   := (cAlias)->QTD_CLIENTES
		Else
			While (cAlias)->(!Eof())
				nIndPage++
				If (aPaginacao[1] .and. nIndPage > aPaginacao[3])
					oResponse['hasNext'] := .T.
					Exit
				ElseIf (!aPaginacao[1] .Or. ;
				        (aPaginacao[1] .And. nIndPage > aPaginacao[2] .And. nIndPage <= aPaginacao[3]))
					Aadd(oResponse['items'], JsonObject():New())
					aTail(oResponse['items'])['id']              := (cAlias)->A1_FILIAL + (cAlias)->A1_COD + (cAlias)->A1_LOJA
					aTail(oResponse['items'])['codGrupo']        := (cAlias)->A1_GRPVEN
					aTail(oResponse['items'])['grupo']           := JConvUTF8((cAlias)->ACY_DESCRI)
					aTail(oResponse['items'])['codCliente']      := (cAlias)->A1_COD

					If !lLojaAuto
						aTail(oResponse['items'])['codCliente']  := aTail(oResponse['items'])['codCliente'] + "-" +(cAlias)->A1_LOJA
					EndIf

					aTail(oResponse['items'])['cliente']         := JConvUTF8((cAlias)->A1_NOME)
					aTail(oResponse['items'])['cgcCliente']      := (cAlias)->A1_CGC
					aTail(oResponse['items'])['ativoCliente']    := (cAlias)->NUH_ATIVO

					aTail(oResponse['items'])['socio']           := JSonObject():New()
					aTail(oResponse['items'])['socio']['codigo'] := (cAlias)->NUH_CPART
					aTail(oResponse['items'])['socio']['nome']   := JConvUTF8((cAlias)->RD0_NOME)
					aTail(oResponse['items'])['socio']['sigla']  := JConvUTF8((cAlias)->RD0_SIGLA)

					aTail(oResponse['items'])['info']            := JSonObject():New()
					aTail(oResponse['items'])['info']['filial']  := (cAlias)->A1_FILIAL
					aTail(oResponse['items'])['info']['codigo']  := (cAlias)->A1_COD
					aTail(oResponse['items'])['info']['loja']    := (cAlias)->A1_LOJA
					aTail(oResponse['items'])['info']['nome']    := JConvUTF8((cAlias)->A1_NOME)
				EndIf
				(cAlias)->( dbSkip() )
			endDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALCliPart(lCount)
Responsável por filtrar os clientes de acordo com o participante
sócio responsável pelo cliente e responsável da cobrança

@param lCount   - Indica se deverá retornar a quantidade de registros
@param aParams  - Parâmetros da query
@param cCodPart - Código do participante
@return cQuery  - Query com filtros

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALQryCli(lCount, aParams, cCodPart)
Local cQuery  := ""
Local cQrySA1 := ""

Default lCount := .F.

	// SELECT
	If lCount
		cQuery += " SELECT COUNT(SA1PAI.R_E_C_N_O_) QTD_CLIENTES"
	Else
		cQuery += " SELECT SA1PAI.A1_FILIAL,"
		cQuery +=        " SA1PAI.A1_GRPVEN,"
		cQuery +=        " ACY.ACY_DESCRI,"
		cQuery +=        " SA1PAI.A1_COD,"
		cQuery +=        " SA1PAI.A1_LOJA,"
		cQuery +=        " SA1PAI.A1_NOME,"
		cQuery +=        " SA1PAI.A1_CGC,"
		cQuery +=        " NUH.NUH_ATIVO,"
		cQuery +=        " NUH.NUH_CPART,"
		cQuery +=        " RD0.RD0_SIGLA,"
		cQuery +=        " RD0.RD0_NOME"
	EndIf

	// FROM
	cQuery +=       " FROM " + RetSqlName("SA1") + " SA1PAI"
	cQuery +=      " INNER JOIN " + RetSqlName("NUH") + " NUH"
	cQuery +=         " ON NUH.NUH_FILIAL = SA1PAI.A1_FILIAL"
	cQuery +=        " AND NUH.NUH_COD = SA1PAI.A1_COD"
	cQuery +=        " AND NUH.NUH_LOJA = SA1PAI.A1_LOJA"
	cQuery +=        " AND NUH.D_E_L_E_T_ = ' '"
	cQuery +=      " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=         " ON RD0.RD0_CODIGO = NUH.NUH_CPART"
	cQuery +=        " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=       " LEFT JOIN " + RetSqlName("ACY") + " ACY"
	cQuery +=         " ON ( ACY.ACY_GRPVEN = SA1PAI.A1_GRPVEN"
	cQuery +=        " AND ACY.D_E_L_E_T_ = ' ' )"

	// WHERE
	cQuery +=      " WHERE SA1PAI.D_E_L_E_T_ = ' '"
	cQuery +=        " AND SA1PAI.A1_FILIAL = ? "
	aAdd(aParams, xFilial("SA1"))

	cQuery +=        " AND EXISTS ( "

	// Query SA1 que se repete no inicio de todos UNION ALL
	cQrySA1 +=              " SELECT 1"
	cQrySA1 +=                " FROM " + RetSqlName("SA1") + " SA1"
	cQrySA1 +=               " INNER JOIN " + RetSqlName("NUH") + " NUH"
	cQrySA1 +=                  " ON NUH.NUH_FILIAL = SA1.A1_FILIAL"
	cQrySA1 +=                 " AND NUH.NUH_COD = SA1.A1_COD"
	cQrySA1 +=                 " AND NUH.NUH_LOJA = SA1.A1_LOJA" 
	cQrySA1 +=                 " AND NUH.D_E_L_E_T_ = ' '"
	cQrySA1 +=               " WHERE SA1.A1_COD = SA1PAI.A1_COD"
	cQrySA1 +=                 " AND SA1.A1_LOJA = SA1PAI.A1_LOJA"
	cQrySA1 +=                 " AND SA1.A1_FILIAL = SA1PAI.A1_FILIAL"
	cQrySA1 +=                 " AND SA1.D_E_L_E_T_ = ' '"
	cQrySA1 +=                 " AND NUH.NUH_CPART = ? " // Sócio Responsável do cliente

	cQuery += cQrySA1
	aAdd(aParams, cCodPart)
	cQuery +=                 " AND NUH.NUH_ATIVO = '1'" // 1 = Ativo

	cQuery +=               " UNION ALL"

	// Verifica Clientes de Faturas Adicionais pendentes de faturamento
	cQuery += cQrySA1
	aAdd(aParams, cCodPart)
	cQuery +=                 " AND NUH.NUH_ATIVO = '2'" // Inativo
	cQuery +=                 " AND EXISTS ("
	cQuery +=                       " SELECT NVV.NVV_COD"
	cQuery +=                         " FROM " + RetSqlName("NVV") + " NVV"
	cQuery +=                        " INNER JOIN " + RetSqlName("NVW") + " NVW"
	cQuery +=                           " ON NVW.NVW_FILIAL = NVV.NVV_FILIAL"
	cQuery +=                          " AND NVW.NVW_CODFAD = NVV.NVV_COD"
	cQuery +=                          " AND NVW.D_E_L_E_T_ = ' '"
	cQuery +=                        " WHERE NVV.D_E_L_E_T_ = ' '"
	cQuery +=                          " AND NUH.NUH_COD = NVW.NVW_CCLIEN"
	cQuery +=                          " AND NUH.NUH_LOJA = NVW.NVW_CLOJA"
	cQuery +=                          " AND NVV.NVV_SITUAC = '1' )" // 1 = Pendente

	cQuery +=               " UNION ALL"

	// Verifica os Clientes de Time Sheets pendentes de faturamento
	cQuery += cQrySA1
	aAdd(aParams, cCodPart)
	cQuery +=                 " AND NUH.NUH_ATIVO = '2'" // Inativo
	cQuery +=                 " AND EXISTS ( "
	cQuery +=                     " SELECT NUE.NUE_COD"
	cQuery +=                      " FROM " + RetSqlName("NUE") + " NUE"
	cQuery +=                      " WHERE NUE.NUE_FILIAL = NUH.NUH_FILIAL"
	cQuery +=                        " AND NUE.NUE_CCLIEN = NUH.NUH_COD"
	cQuery +=                        " AND NUE.NUE_CLOJA = NUH.NUH_LOJA"
	cQuery +=                        " AND NUE.D_E_L_E_T_ = ' '"
	cQuery +=                        " AND NUE.NUE_SITUAC = '1' )" // 1=Pendente

	cQuery +=               " UNION ALL"

	// Verifica os Clientes de Lançamento Tabelados pendentes de faturamento
	cQuery += cQrySA1
	aAdd(aParams, cCodPart)
	cQuery +=                 " AND NUH.NUH_ATIVO = '2'" // Inativo
	cQuery +=                 " AND EXISTS ( "
	cQuery +=                       " SELECT NV4.NV4_COD"
	cQuery +=                         " FROM " + RetSqlName("NV4") + " NV4"
	cQuery +=                        " WHERE NV4.NV4_FILIAL = NUH.NUH_FILIAL"
	cQuery +=                          " AND NV4.NV4_CCLIEN = NUH.NUH_COD   "
	cQuery +=                          " AND NV4.NV4_CLOJA  = NUH.NUH_LOJA  "
	cQuery +=                          " AND NV4.D_E_L_E_T_ = ' '"
	cQuery +=                          " AND NV4.NV4_SITUAC = '1' )" // 1=Pendente

	cQuery +=               " UNION ALL"

	// Verifica os Clientes de Despesas pendentes de faturamento
	cQuery += cQrySA1
	aAdd(aParams, cCodPart)
	cQuery +=                 " AND NUH.NUH_ATIVO = '2'" // Inativo
	cQuery +=                 " AND EXISTS ( "
	cQuery +=                       " SELECT NVY.NVY_COD"
	cQuery +=                         " FROM " + RetSqlName("NVY") + " NVY"
	cQuery +=                        " WHERE NVY.NVY_FILIAL = NUH.NUH_FILIAL"
	cQuery +=                          " AND NVY.NVY_CCLIEN = NUH.NUH_COD"
	cQuery +=                          " AND NVY.NVY_CLOJA  = NUH.NUH_LOJA"
	cQuery +=                          " AND NVY.D_E_L_E_T_ = ' '"
	cQuery +=                          " AND NVY.NVY_SITUAC = '1' )"  // 1=Pendente

	cQuery +=               " UNION ALL"

	// Verifica os Clientes de Fixo parcelado pendentes de faturamento
	cQuery += cQrySA1
	aAdd(aParams, cCodPart)
	cQuery +=                 " AND NUH.NUH_ATIVO = '2'" // Inativo
	cQuery +=                 " AND EXISTS ( "
	cQuery +=                       " SELECT NT1.NT1_CCONTR"
	cQuery +=                         " FROM " + RetSqlName("NT1") + " NT1"
	cQuery +=                        " INNER JOIN " + RetSqlName("NT0") + " NT0"
	cQuery +=                           " ON NT0.NT0_FILIAL = NT1.NT1_FILIAL"
	cQuery +=                          " AND NT0.NT0_COD = NT1.NT1_CCONTR"
	cQuery +=                          " AND NT0.D_E_L_E_T_ = ' '"
	cQuery +=                        " INNER JOIN " + RetSqlName("NUT") + " NUT"
	cQuery +=                           " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL"
	cQuery +=                          " AND NUT.NUT_CCONTR = NT0.NT0_COD"
	cQuery +=                          " AND NUT.D_E_L_E_T_ = ' '"
	cQuery +=                        " WHERE NT1.D_E_L_E_T_ = ' '"
	cQuery +=                          " AND NUH.NUH_COD   = NUT.NUT_CCLIEN"
	cQuery +=                          " AND NUH.NUH_LOJA  = NUT.NUT_CLOJA"
	cQuery +=                          " AND NT1.NT1_SITUAC = '1' )" // 1=Pendente

	cQuery +=                   " ) "
	
	// Para count não precisa fazer ORDER BY
	If !lCount
		cQuery +=        " ORDER BY SA1PAI.A1_NOME"
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET casos
Busca os casos no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/caso/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET casos PATHPARAM codPart QUERYPARAM qtdTotal, codCliente WSREST WSPFSAltLote
Local aArea       := GetArea()
Local oResponse   := JSonObject():New()
Local lRet        := .T.
Local lHasReg     := .F.
Local nIndPage    := 0
Local cAlias      := GetNextAlias()
Local cQuery      := ""
Local cCodPart    := Self:codPart
Local lTotal      := Self:qtdTotal
Local cCodCliente := Self:codCliente
Local nI          := 0
Local nPosSitCas  := 0
Local aCbxSitCas  := STRTOKARR(JurEncUTF8(ALLTRIM(GetSx3Cache("NVE_SITUAC","X3_CBOX"))),";")
Local aParams     := {}
Local aParMltPart := {}
Local lLojaAuto   := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lMultRev    := SuperGetMV("MV_JMULTRV",, .F.)
Local aPaginacao  := SetPagSize(Self:page, Self:pageSize)

Default cCodPart    := ""
Default lTotal      := .F.
Default cCodCliente := ""

	For nI := 1 To Len(aCbxSitCas)
		aCbxSitCas[nI] := StrTokArr(aCbxSitCas[nI],"=")
	Next nI

	cQuery := WSALCasPart(lTotal, cCodCliente, @aParams, cCodPart)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cAlias, .T., .F. )

	lHasReg := !(cAlias)->(EOF())

	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If lHasReg
		If lTotal
			oResponse['total'] := (cAlias)->QTD_CASOS
		Else
			While (cAlias)->(!Eof())
				nIndPage++
				If (aPaginacao[1] .and. nIndPage > aPaginacao[3])
					oResponse['hasNext'] := .T.
					Exit
				ElseIf (!aPaginacao[1] .Or. ;
				        (aPaginacao[1] .And. nIndPage > aPaginacao[2] .And. nIndPage <= aPaginacao[3]))
					Aadd(oResponse['items'], JsonObject():New())
					aTail(oResponse['items'])['codigo']           := (cAlias)->NVE_FILIAL + (cAlias)->NVE_CCLIEN + ;
																(cAlias)->NVE_LCLIEN + (cAlias)->NVE_NUMCAS
					aTail(oResponse['items'])['codGrupoCliente']  := (cAlias)->NVE_CGRPCL
					aTail(oResponse['items'])['descGrupoCliente'] := JConvUTF8((cAlias)->ACY_DESCRI)
					aTail(oResponse['items'])['codCliente']       := (cAlias)->NVE_CCLIEN

					If !lLojaAuto
						aTail(oResponse['items'])['codCliente'] := (cAlias)->NVE_CCLIEN + ;
															" - " + (cAlias)->NVE_LCLIEN
					EndIf

					aTail(oResponse['items'])['cliente']    := JConvUTF8((cAlias)->A1_NOME)
					aTail(oResponse['items'])['codCaso']    := (cAlias)->NVE_NUMCAS
					aTail(oResponse['items'])['tituloCaso'] := JConvUTF8((cAlias)->NVE_TITULO)
					aTail(oResponse['items'])['codArea']    := (cAlias)->NVE_CAREAJ
					aTail(oResponse['items'])['area']       := JConvUTF8((cAlias)->NRB_DESC)

					nPosSitCas := aScan(aCbxSitCas, {|x| x[1] == (cAlias)->NVE_SITUAC})

					aTail(oResponse['items'])['situacao']              := JSonObject():New()
					aTail(oResponse['items'])['situacao']['codigo']    := (cAlias)->NVE_SITUAC
					aTail(oResponse['items'])['situacao']['descricao'] := JConvUTF8(aCbxSitCas[nPosSitCas][2])

					aTail(oResponse['items'])['socio']                 := JSonObject():New()
					aTail(oResponse['items'])['socio']['codigo']       := (cAlias)->SOCIOCODIGO
					aTail(oResponse['items'])['socio']['nome']         := JConvUTF8((cAlias)->SOCIONOME)
					aTail(oResponse['items'])['socio']['sigla']        := JConvUTF8((cAlias)->SOCIOSIGLA)

					aTail(oResponse['items'])['revisor']               := JSonObject():New()
					aTail(oResponse['items'])['revisor']['codigo']     := (cAlias)->REVCODIGO
					aTail(oResponse['items'])['revisor']['nome']       := JConvUTF8((cAlias)->REVNOME)
					aTail(oResponse['items'])['revisor']['sigla']      := JConvUTF8((cAlias)->REVSIGLA)
					aTail(oResponse['items'])['multRevisores']         := {}

					If (lMultRev)
						aAdd(aParMltPart, (cAlias)->NVE_CCLIEN)
						aAdd(aParMltPart, (cAlias)->NVE_LCLIEN)
						aAdd(aParMltPart, (cAlias)->NVE_NUMCAS)

						aTail(oResponse['items'])['multRevisores']     := MultPart(cQryMltPart("CASO"), aParMltPart)
						aSize(aParMltPart, 0)
					EndIf
				EndIf
				(cAlias)->( dbSkip() )
			EndDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL
	
	aSize(aParams,     0)
	aSize(aParMltPart, 0)
	aSize(aCbxSitCas,  0)
	aParams     := Nil
	aCbxSitCas  := Nil
	aParMltPart := Nil

	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALCasPart(lCount, cCodCliente, aQryParams, cCodPart)
Responsável por filtrar os casos de acordo com o participante revisor
do faturamento do caso, sócio responsável ou Revisor do remanejamento.
Filtra casos ativos e/ou casos inativos cujos lançamentos estão pendente
de faturamento.

@param lCount      - Indica se deverá retornar a quantidade de registros
@param cCodCliente - Código do Cliente
@param aQryParams  - Array de parâmetros
@param cCodPart    - Código do participante
@return cQuery     - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALCasPart(lCount, cCodCliente, aQryParams, cCodPart)
Local lMultRev := SuperGetMV("MV_JMULTRV",, .F.)
Local cQuery   := ""
Local cQryNVE  := ""

Default lCount      := .F.
Default cCodCliente := ""
Default aQryParams  := {}
Default cCodPart    := ""
	
	// SELECT
	If lCount
		cQuery += " SELECT COUNT(NVEPAI.R_E_C_N_O_) QTD_CASOS"
	Else
		cQuery += " SELECT NVE_FILIAL,"
		cQuery +=        " NVE_CGRPCL,"
		cQuery +=        " ACY_DESCRI,"
		cQuery +=        " NVE_CCLIEN,"
		cQuery +=        " NVE_LCLIEN,"
		cQuery +=        " A1_NOME,"
		cQuery +=        " NVE_NUMCAS,"
		cQuery +=        " NVE_TITULO,"
		cQuery +=        " NVE_CAREAJ,"
		cQuery +=        " NRB_DESC,"
		cQuery +=        " NVE_SITUAC,"
		cQuery +=        " NVEPAI.NVE_CPART1 REVCODIGO,"
		cQuery +=        " RD0REV.RD0_NOME REVNOME,"
		cQuery +=        " RD0REV.RD0_SIGLA REVSIGLA,"
		cQuery +=        " NVEPAI.NVE_CPART5 SOCIOCODIGO,"
		cQuery +=        " RD0SOC.RD0_NOME SOCIONOME,"
		cQuery +=        " RD0SOC.RD0_SIGLA SOCIOSIGLA"
	EndIf

	// FROM
	cQuery +=       " FROM " + RetSqlName("NVE") + " NVEPAI"
	cQuery +=      " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=         " ON ( SA1.A1_COD = NVEPAI.NVE_CCLIEN"
	cQuery +=              " AND SA1.A1_LOJA = NVEPAI.NVE_LCLIEN"
	cQuery +=              " AND SA1.D_E_L_E_T_ = ' ' )"
	cQuery +=      " INNER JOIN " + RetSqlName("RD0") + " RD0REV"
	cQuery +=         " ON ( RD0REV.RD0_CODIGO = NVEPAI.NVE_CPART1"
	cQuery +=              " AND RD0REV.D_E_L_E_T_ = ' ' )"
	cQuery +=      " INNER JOIN " + RetSqlName("RD0") + " RD0SOC"
	cQuery +=         " ON ( RD0SOC.RD0_CODIGO = NVEPAI.NVE_CPART5"
	cQuery +=              " AND RD0SOC.D_E_L_E_T_ = ' ' )"
	cQuery +=       " LEFT JOIN " + RetSqlName("NRB") + " NRB"
	cQuery +=         " ON ( NRB.NRB_COD = NVEPAI.NVE_CAREAJ"
	cQuery +=              " AND NRB.D_E_L_E_T_ = ' ' )"
	cQuery +=       " LEFT JOIN " + RetSqlName("ACY") + " ACY"
	cQuery +=         " ON ( ACY.ACY_GRPVEN = NVEPAI.NVE_CGRPCL"
	cQuery +=              " AND ACY.D_E_L_E_T_ = ' ' )"

	// WHERE
	cQuery +=      " WHERE NVEPAI.D_E_L_E_T_ = ' '"
	cQuery +=        " AND NVEPAI.NVE_FILIAL = ? "
	aAdd(aQryParams, xFilial("NVE"))

	cQuery +=        " AND EXISTS ( "

	// Query NVE que se repete no inicio de todos UNION ALL
	cQryNVE +=             " SELECT NVE_FILIAL,"
	cQryNVE +=                    " NVE_CCLIEN,"
	cQryNVE +=                    " NVE_LCLIEN,"
	cQryNVE +=                    " NVE_NUMCAS"
	cQryNVE +=               " FROM " + RetSqlName("NVE") + " NVE"
	cQryNVE +=              " WHERE NVE_CCLIEN = NVEPAI.NVE_CCLIEN"
	cQryNVE +=               "  AND NVE_LCLIEN = NVEPAI.NVE_LCLIEN"
	cQryNVE +=               "  AND NVE_FILIAL = NVEPAI.NVE_FILIAL"
	cQryNVE +=               "  AND NVE_NUMCAS = NVEPAI.NVE_NUMCAS"
	cQryNVE +=               "  AND NVE.D_E_L_E_T_ = ' '"

	// Participante como Sócio, Revisor ou Multiplo
	cQuery += cQryNVE
	cQuery +=                "  AND NVE.NVE_SITUAC = '1'" // 1 = Pendente
	cQuery +=                "  AND ( NVE.NVE_CPART1 = ? OR NVE.NVE_CPART5 = ? )"
	aAdd(aQryParams, cCodPart)
	aAdd(aQryParams, cCodPart)

	If(lMultRev)
		cQuery +=           " UNION ALL"

		// Participante como Sócio, Revisor ou Multiplo
		cQuery += cQryNVE
		cQuery +=             " AND NVE.NVE_SITUAC = '1'" // 1 = Pendente
		cQuery +=             " AND EXISTS ( SELECT OHN.OHN_CCASO,"
		cQuery +=                                 " OHN.OHN_CPART"
		cQuery +=                            " FROM " + RetSqlName("OHN") + " OHN"
		cQuery +=                           " WHERE OHN.D_E_L_E_T_ = ' '"
		cQuery +=                             " AND OHN.OHN_CPREFT = ' '"
		cQuery +=                             " AND OHN.OHN_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                             " AND OHN.OHN_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                             " AND OHN.OHN_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                             " AND OHN.OHN_CPART = ?"
		cQuery +=                             " AND OHN.OHN_FILIAL = ? )"
		aAdd(aQryParams, cCodPart)
		aAdd(aQryParams, xFilial("OHN"))
	EndIf

	cQuery +=               " UNION ALL"

	// Verifica Casos de Faturas Adicionais pendentes de faturamento
	cQuery += cQryNVE
	cQuery +=                 " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
	cQuery +=                 " AND ( NVE.NVE_CPART1 = ? OR NVE.NVE_CPART5 = ?)"
	aAdd(aQryParams, cCodPart)
	aAdd(aQryParams, cCodPart)
	cQuery +=                 " AND EXISTS ( SELECT NVV.NVV_COD"
	cQuery +=                                " FROM " + RetSqlName("NVV") + " NVV"
	cQuery +=                          " INNER JOIN " + RetSqlName("NVW") + " NVW"
	cQuery +=                                  " ON NVW.NVW_FILIAL = NVV.NVV_FILIAL"
	cQuery +=                                 " AND NVW.NVW_CODFAD = NVV.NVV_COD"
	cQuery +=                                 " AND NVW.D_E_L_E_T_ = ' '"
	cQuery +=                               " WHERE NVV.D_E_L_E_T_ = ' '"
	cQuery +=                                 " AND NVE.NVE_CCLIEN = NVW.NVW_CCLIEN"
	cQuery +=                                 " AND NVE.NVE_LCLIEN = NVW.NVW_CLOJA"
	cQuery +=                                 " AND NVE.NVE_NUMCAS = NVW.NVW_CCASO"
	cQuery +=                                 " AND NVV.NVV_SITUAC = '1'" // 1 = Pendente
	cQuery +=                                 " AND NVV.NVV_FILIAL = ? )"
	aAdd(aQryParams, xFilial("NVV"))

	If(lMultRev)
		cQuery +=           " UNION ALL"
		
		// Verifica Casos de Faturas Adicionais pendentes de faturamento
		cQuery += cQryNVE
		cQuery +=             " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
		cQuery +=             " AND EXISTS ( SELECT OHN.OHN_CCASO,"
		cQuery +=                                 " OHN.OHN_CPART"
		cQuery +=                            " FROM " + RetSqlName("OHN") + " OHN"
		cQuery +=                           " WHERE OHN.D_E_L_E_T_ = ' '"
		cQuery +=                             " AND OHN.OHN_CPREFT = ' '"
		cQuery +=                             " AND OHN.OHN_FILIAL = NVE.NVE_FILIAL"
		cQuery +=                             " AND OHN.OHN_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                             " AND OHN.OHN_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                             " AND OHN.OHN_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                             " AND OHN.OHN_CPART = ? )"
		aAdd(aQryParams, cCodPart)
		cQuery +=                             " AND EXISTS ( SELECT NVV.NVV_COD"
		cQuery +=                                     " FROM " + RetSqlName("NVV") + " NVV"
		cQuery +=                               " INNER JOIN " + RetSqlName("NVW") + " NVW"
		cQuery +=                                       " ON NVW.NVW_FILIAL = NVV.NVV_FILIAL"
		cQuery +=                                      " AND NVW.NVW_CODFAD = NVV.NVV_COD"
		cQuery +=                                      " AND NVW.D_E_L_E_T_ = ' '"
		cQuery +=                                    " WHERE NVV.D_E_L_E_T_ = ' '"
		cQuery +=                                      " AND NVE.NVE_CCLIEN = NVW.NVW_CCLIEN"
		cQuery +=                                      " AND NVE.NVE_LCLIEN = NVW.NVW_CLOJA"
		cQuery +=                                      " AND NVE.NVE_NUMCAS = NVW.NVW_CCASO"
		cQuery +=                                      " AND NVV.NVV_SITUAC = '1'" // 1 = Pendente
		cQuery +=                                      " AND NVV.NVV_FILIAL = ? )"
		aAdd(aQryParams, xFilial("NVV"))
	EndIf

	cQuery +=               " UNION ALL"
	
	// Verifica os casos de Time Sheets pendentes de faturamento
	cQuery += cQryNVE
	cQuery +=                 " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
	cQuery +=                 " AND ( NVE.NVE_CPART1 = ? OR NVE.NVE_CPART5 = ? )"
	aAdd(aQryParams, cCodPart)
	aAdd(aQryParams, cCodPart)
	cQuery +=                 " AND EXISTS ( SELECT NUE.NUE_COD"
	cQuery +=                                " FROM " + RetSqlName("NUE") + " NUE"
	cQuery +=                               " WHERE NUE.NUE_CCLIEN = NVE.NVE_CCLIEN"
	cQuery +=                                 " AND NUE.NUE_CLOJA = NVE.NVE_LCLIEN"
	cQuery +=                                 " AND NUE.NUE_CCASO = NVE.NVE_NUMCAS"
	cQuery +=                                 " AND NUE.D_E_L_E_T_ = ' '"
	cQuery +=                                 " AND NUE.NUE_SITUAC = '1'" // 1 = Pendente
	cQuery +=                                 " AND NUE.NUE_FILIAL = ? )"
	aAdd(aQryParams, xFilial("NUE"))

	If(lMultRev)

		cQuery +=           " UNION ALL"

		// Verifica os casos de Time Sheets pendentes de faturamento
		cQuery += cQryNVE
		cQuery +=             " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
		cQuery +=             " AND EXISTS ( SELECT OHN.OHN_CCASO,"
		cQuery +=                                 " OHN.OHN_CPART"
		cQuery +=                            " FROM " + RetSqlName("OHN") + " OHN"
		cQuery +=                           " WHERE OHN.D_E_L_E_T_ = ' '"
		cQuery +=                             " AND OHN.OHN_CPREFT = ' '"
		cQuery +=                             " AND OHN.OHN_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                             " AND OHN.OHN_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                             " AND OHN.OHN_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                             " AND OHN.OHN_CPART = ? "
		cQuery +=                             " AND OHN.OHN_FILIAL = ? )"
		aAdd(aQryParams, cCodPart)
		aAdd(aQryParams, xFilial("OHN"))
		cQuery +=                             " AND EXISTS (SELECT NUE.NUE_COD"
		cQuery +=                                           " FROM " + RetSqlName("NUE") + " NUE"
		cQuery +=                                          " WHERE NUE.NUE_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                                            " AND NUE.NUE_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                                            " AND NUE.NUE_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                                            " AND NUE.D_E_L_E_T_ = ' '"
		cQuery +=                                            " AND NUE.NUE_SITUAC = '1'" // 1 = Pendente
		cQuery +=                                            " AND NUE.NUE_FILIAL= ? )"
		aAdd(aQryParams, xFilial("NUE"))
	EndIf

	cQuery +=               " UNION ALL"

	// Verifica os casos de Lançamento Tabelados pendentes de faturamento
	cQuery += cQryNVE
	cQuery +=                 " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
	cQuery +=                 " AND ( NVE.NVE_CPART1 = ? OR NVE.NVE_CPART5 = ?)"
	aAdd(aQryParams, cCodPart)
	aAdd(aQryParams, cCodPart)
	cQuery +=                 " AND EXISTS ( SELECT NV4.NV4_COD"
	cQuery +=                                " FROM " + RetSqlName("NV4") + " NV4"
	cQuery +=                               " WHERE NV4.NV4_CCLIEN = NVE.NVE_CCLIEN"
	cQuery +=                                 " AND NV4.NV4_CLOJA = NVE.NVE_LCLIEN"
	cQuery +=                                 " AND NV4.NV4_CCASO = NVE.NVE_NUMCAS"
	cQuery +=                                 " AND NV4.D_E_L_E_T_ = ' '"
	cQuery +=                                 " AND NV4.NV4_SITUAC = '1'" // 1 = Pendente
	cQuery +=                                 " AND NV4.NV4_FILIAL = ? )"
	aAdd(aQryParams, xFilial("NV4"))

	If(lMultRev)

		cQuery +=           " UNION ALL"

		// Verifica os casos de Lançamento Tabelados pendentes de faturamento
		cQuery += cQryNVE
		cQuery +=                 " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
		cQuery +=                 " AND EXISTS ( SELECT OHN.OHN_CCASO,"
		cQuery +=                                     " OHN.OHN_CPART"
		cQuery +=                                " FROM " + RetSqlName("OHN") + " OHN"
		cQuery +=                               " WHERE OHN.D_E_L_E_T_ = ' '"
		cQuery +=                                 " AND OHN.OHN_CPREFT = ' '"
		cQuery +=                                 " AND OHN.OHN_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                                 " AND OHN.OHN_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                                 " AND OHN.OHN_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                                 " AND OHN.OHN_CPART = ? "
		cQuery +=                                 " AND OHN.OHN_FILIAL = ? )"
		aAdd(aQryParams, cCodPart)
		aAdd(aQryParams, xFilial("OHN"))
		cQuery +=                                 " AND EXISTS ( SELECT NV4.NV4_COD"
		cQuery +=                                                " FROM " + RetSqlName("NV4") + " NV4"
		cQuery +=                                               " WHERE NV4.NV4_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                                                 " AND NV4.NV4_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                                                 " AND NV4.NV4_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                                                 " AND NV4.D_E_L_E_T_ = ' '"
		cQuery +=                                                 " AND NV4.NV4_SITUAC = '1'" // 1 = Pendente
		cQuery +=                                                 " AND NV4.NV4_FILIAL = ? )"
		aAdd(aQryParams, xFilial("NV4"))
	EndIf

	cQuery +=               " UNION ALL"
	
	// Verifica os casos de Despesas pendentes de faturamento
	cQuery += cQryNVE
	cQuery +=                  " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
	cQuery +=                  " AND ( NVE.NVE_CPART1 = ? OR NVE.NVE_CPART5 = ? )"
	aAdd(aQryParams, cCodPart)
	aAdd(aQryParams, cCodPart)
	cQuery +=                  " AND EXISTS ( SELECT NVY.NVY_COD"
	cQuery +=                                 " FROM " + RetSqlName("NVY") + " NVY"
	cQuery +=                                " WHERE NVY.NVY_CCLIEN = NVE.NVE_CCLIEN"
	cQuery +=                                  " AND NVY.NVY_CLOJA = NVE.NVE_LCLIEN"
	cQuery +=                                  " AND NVY.NVY_CCASO = NVE.NVE_NUMCAS"
	cQuery +=                                  " AND NVY.D_E_L_E_T_ = ' '"
	cQuery +=                                  " AND NVY.NVY_SITUAC = '1'" // 1 = Pendente
	cQuery +=                                  " AND NVY.NVY_FILIAL = ? )"
	aAdd(aQryParams, xFilial("NVY"))

	

	If(lMultRev)

		cQuery +=           " UNION ALL"

		// Verifica os casos de Despesas pendentes de faturamento
		cQuery += cQryNVE
		cQuery +=             " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
		cQuery +=             " AND EXISTS ( SELECT OHN.OHN_CCASO,"
		cQuery +=                                 " OHN.OHN_CPART"
		cQuery +=                            " FROM " + RetSqlName("OHN") + " OHN"
		cQuery +=                           " WHERE OHN.D_E_L_E_T_ = ' '"
		cQuery +=                             " AND OHN.OHN_CPREFT = ' '"
		cQuery +=                             " AND OHN.OHN_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                             " AND OHN.OHN_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                             " AND OHN.OHN_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                             " AND OHN.OHN_CPART = ? "
		cQuery +=                             " AND OHN.OHN_FILIAL = ? )"
		aAdd(aQryParams, cCodPart)
		aAdd(aQryParams, xFilial("OHN"))
		cQuery +=                             " AND EXISTS ( SELECT NVY.NVY_COD"
		cQuery +=                                            " FROM " + RetSqlName("NVY") + " NVY"
		cQuery +=                                           " WHERE NVY.NVY_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                                             " AND NVY.NVY_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                                             " AND NVY.NVY_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                                             " AND NVY.D_E_L_E_T_ = ' '"
		cQuery +=                                             " AND NVY.NVY_SITUAC = '1'" // 1 = Pendente
		cQuery +=                                             " AND NVY.NVY_FILIAL = ? )"
		aAdd(aQryParams, xFilial("NVY"))
	EndIf

	cQuery +=               " UNION ALL"

	// Verifica os casos de Fixo parcelado pendentes de faturamento
	cQuery += cQryNVE
	cQuery +=                 " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
	cQuery +=                 " AND ( NVE.NVE_CPART1 = ? OR NVE.NVE_CPART5 = ? )"
	aAdd(aQryParams, cCodPart)
	aAdd(aQryParams, cCodPart)
	cQuery +=                 " AND EXISTS ( SELECT NT1.NT1_CCONTR"
	cQuery +=                                " FROM " + RetSqlName("NT1") + " NT1"
	cQuery +=                          " INNER JOIN " + RetSqlName("NT0") + " NT0"
	cQuery +=                                  " ON NT0.NT0_FILIAL = NT1.NT1_FILIAL"
	cQuery +=                                 " AND NT0.NT0_COD = NT1.NT1_CCONTR"
	cQuery +=                                 " AND NT0.D_E_L_E_T_ = ' '"
	cQuery +=                          " INNER JOIN " + RetSqlName("NUT") + " NUT"
	cQuery +=                                  " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL"
	cQuery +=                                 " AND NUT.NUT_CCONTR = NT0.NT0_COD"
	cQuery +=                                 " AND NUT.D_E_L_E_T_ = ' '"
	cQuery +=                               " WHERE NT1.D_E_L_E_T_ = ' '"
	cQuery +=                                 " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN"
	cQuery +=                                 " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA"
	cQuery +=                                 " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO"
	cQuery +=                                 " AND NT1.NT1_SITUAC = '1'" // 1 = Pendente
	cQuery +=                                 " AND NT1.NT1_FILIAL = ? )"
	aAdd(aQryParams, xFilial("NT1"))

	If(lMultRev)
		cQuery +=           " UNION ALL"

		// Verifica os casos de Fixo parcelado pendente de faturamento
		cQuery += cQryNVE
		cQuery +=             " AND NVE.NVE_SITUAC = '2'" // 2 = Encerrado
		cQuery +=             " AND EXISTS ( SELECT OHN.OHN_CCASO,"
		cQuery +=                                 " OHN.OHN_CPART"
		cQuery +=                            " FROM " + RetSqlName("OHN") + " OHN"
		cQuery +=                           " WHERE OHN.D_E_L_E_T_ = ' '"
		cQuery +=                             " AND OHN.OHN_CPREFT = ' '"
		cQuery +=                             " AND OHN.OHN_CCASO = NVE.NVE_NUMCAS"
		cQuery +=                             " AND OHN.OHN_CCLIEN = NVE.NVE_CCLIEN"
		cQuery +=                             " AND OHN.OHN_CLOJA = NVE.NVE_LCLIEN"
		cQuery +=                             " AND OHN.OHN_CPART = ? "
		cQuery +=                             " AND OHN.OHN_FILIAL = ? )"
		aAdd(aQryParams, cCodPart)
		aAdd(aQryParams, xFilial("OHN"))
		cQuery +=                             " AND EXISTS ( SELECT NT1.NT1_CCONTR"
		cQuery +=                                            " FROM " + RetSqlName("NT1") + " NT1"
		cQuery +=                                      " INNER JOIN " + RetSqlName("NT0") + " NT0"
		cQuery +=                                              " ON NT0.NT0_FILIAL = NT1.NT1_FILIAL"
		cQuery +=                                             " AND NT0.NT0_COD = NT1.NT1_CCONTR"
		cQuery +=                                             " AND NT0.D_E_L_E_T_ = ' '"
		cQuery +=                                      " INNER JOIN " + RetSqlName("NUT") + " NUT"
		cQuery +=                                              " ON NUT.NUT_FILIAL = NT0.NT0_FILIAL"
		cQuery +=                                             " AND NUT.NUT_CCONTR = NT0.NT0_COD"
		cQuery +=                                             " AND NUT.D_E_L_E_T_ = ' '"
		cQuery +=                                           " WHERE NT1.D_E_L_E_T_ = ' '"
		cQuery +=                                             " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN"
		cQuery +=                                             " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA"
		cQuery +=                                             " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO"
		cQuery +=                                             " AND NT1.NT1_SITUAC = '1'" // 1 = Pendente
		cQuery +=                                             " AND NT1.NT1_FILIAL = ? )"
		aAdd(aQryParams, xFilial("NT1"))
	EndIf

	cQuery +=                   " ) "

	// Filtro por cliente
	If !Empty(cCodCliente)
		cQuery +=                 " AND NVEPAI.NVE_CCLIEN = ? "
		aAdd(aQryParams, cCodCliente)
	EndIf

	// Para count não precisa fazer ORDER BY
	If !lCount
		cQuery +=                 " ORDER BY SA1.A1_NOME, NVEPAI.NVE_TITULO"
	EndIf	

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} GET contratos
Busca os contratos no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/contrato/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET contratos PATHPARAM codPart QUERYPARAM qtdTotal, codCliente, page, pageSize WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local lHasReg    := .F.
Local nIndPage   := 0
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal
Local cCodCliente:= Self:codCliente
Local aCliente   := {}
Local aParams    := {}
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aPaginacao := SetPagSize(Self:page, Self:pageSize)

Default cCodPart    := ""
Default lTotal      := .F.
Default cCodCliente := ""
	
	aAdd(aParams, cCodPart)

	If !Empty(cCodCliente)
		aCliente := StrTokArr(cCodCliente,"-" )
		aAdd(aParams, aCliente[1])
		aAdd(aParams, aCliente[2])
	EndIf

	cQuery := WSALContrPart(lTotal, cCodCliente)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cAlias, .T., .F. )

	lHasReg := !(cAlias)->(EOF())

	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If lHasReg
		If lTotal
			oResponse['total'] := (cAlias)->QTD_CONTRATOS
		Else
			While (cAlias)->(!Eof())
				nIndPage++
				If (aPaginacao[1] .and. nIndPage > aPaginacao[3])
					oResponse['hasNext'] := .T.
					Exit
				ElseIf (!aPaginacao[1] .Or. ;
				        (aPaginacao[1] .And. nIndPage > aPaginacao[2] .And. nIndPage <= aPaginacao[3]))
					Aadd(oResponse['items'], JsonObject():New())
					aTail(oResponse['items'])['codigo']            := (cAlias)->NT0_FILIAL + (cAlias)->NT0_COD
					aTail(oResponse['items'])['codGrupo']          := (cAlias)->NT0_CGRPCL
					aTail(oResponse['items'])['descGrupo']         := JConvUTF8((cAlias)->ACY_DESCRI)
					aTail(oResponse['items'])['codCliente']        := (cAlias)->NT0_CCLIEN

					If !lLojaAuto
						aTail(oResponse['items'])['codCliente']    := aTail(oResponse['items'])['codCliente'] + " - " + ;
																(cAlias)->NT0_CLOJA
					EndIf

					aTail(oResponse['items'])['cliente']           := JConvUTF8((cAlias)->A1_NOME)
					aTail(oResponse['items'])['descricao']         := JConvUTF8((cAlias)->NT0_NOME)
					aTail(oResponse['items'])['codTipoHonorario']  := (cAlias)->NT0_CTPHON
					aTail(oResponse['items'])['descTipoHonorario'] := JConvUTF8((cAlias)->NRA_DESC)
					aTail(oResponse['items'])['codSocio']          := (cAlias)->RD0_CODIGO
					aTail(oResponse['items'])['codOriginal']       := (cAlias)->RD0_CODIGO
					aTail(oResponse['items'])['siglaSocio']        := JConvUTF8((cAlias)->RD0_SIGLA)
					aTail(oResponse['items'])['descSocio']         := JConvUTF8((cAlias)->RD0_NOME)
					aTail(oResponse['items'])['situacao']          := (cAlias)->NT0_SIT
					aTail(oResponse['items'])['ativo']             := (cAlias)->NT0_ATIVO
					aTail(oResponse['items'])['updated']           := .F.
				EndIf
				(cAlias)->( dbSkip() )
			EndDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALContrPart(lCount, cCodCliente)
Responsável por filtrar os contratos de acordo com o participante revisor
sócio responsável. Filtra contratos ativos.

@param lCount      - Indica se deverá retornar a quantidade de registros
@param cCodCliente - Código do Cliente
@return cQuery     - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALContrPart(lCount, cCodCliente)
Local cQuery  := " SELECT"

Default lCount      := .F.
Default cCodCliente := ""

	If lCount
		cQuery += " COUNT(NT0.NT0_CPART1) QTD_CONTRATOS"
	Else
		cQuery += " NT0_FILIAL"
		cQuery += " ,NT0_COD"
		cQuery += " ,NT0_CGRPCL"
		cQuery += " ,NT0_CCLIEN"
		cQuery += " ,NT0_CLOJA"
		cQuery += " ,NT0_NOME"
		cQuery += " ,NT0_CTPHON"
		cQuery += " ,NT0_CPART1"
		cQuery += " ,NT0_SIT"
		cQuery += " ,NT0_ATIVO"
		cQuery += " ,RD0_CODIGO"
		cQuery += " ,RD0_SIGLA"
		cQuery += " ,RD0_NOME"
		cQuery += " ,ACY_DESCRI"
		cQuery += " ,A1_NOME"
		cQuery += " ,NRA_DESC"
	EndIf

	cQuery +=  " FROM " + RetSqlName( "NT0" ) + " NT0"
	cQuery += " INNER JOIN " + RetSqlName( "RD0" ) + " RD0"
	cQuery +=    " ON RD0.RD0_CODIGO = NT0.NT0_CPART1"
	cQuery +=   " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=  " LEFT JOIN " +  RetSqlName('ACY') + " ACY"
	cQuery +=    " ON (ACY.ACY_GRPVEN = NT0.NT0_CGRPCL"
	cQuery +=   " AND ACY.D_E_L_E_T_ = ' ')"
	cQuery += " INNER JOIN " + RetSqlName( "SA1" ) + " SA1"
	cQuery +=    " ON NT0.NT0_CCLIEN = SA1.A1_COD"
	cQuery +=   " AND NT0.NT0_CLOJA = SA1.A1_LOJA"
	cQuery +=   " AND SA1.D_E_L_E_T_  = ' '"
	cQuery += " INNER JOIN " + RetSqlName( "NRA" ) + " NRA"
	cQuery +=    " ON NT0.NT0_CTPHON = NRA.NRA_COD"
	cQuery +=   " AND NRA.D_E_L_E_T_ = ' '"
	cQuery += " WHERE NT0.NT0_CPART1 = ?"
	cQuery +=   " AND NT0.D_E_L_E_T_ = ' '"

	If !Empty(cCodCliente)
		cQuery += " AND NT0.NT0_CCLIEN = ?"
		cQuery += " AND NT0.NT0_CLOJA = ?"
	EndIf

	If !lCount
		cQuery += " ORDER BY NT0.NT0_COD"
	EndIf

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} GET juncaoContratos
Busca os contratos no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/juncaoContrato/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET juncaoContratos PATHPARAM codPart QUERYPARAM qtdTotal, codCliente WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local lHasReg    := .F.
Local nIndPage   := 0
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal
Local cCodCliente:= Self:codCliente
Local aCliente   := {}
Local aParams    := {cCodPart}
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aPaginacao := SetPagSize(Self:page, Self:pageSize)

Default cCodPart    := ""
Default lTotal      := .F.
Default cCodCliente := ""

	If !Empty(cCodCliente)
		aCliente := StrTokArr(cCodCliente,"-" )
		aAdd(aParams, aCliente[1])
		aAdd(aParams, aCliente[2])
	EndIf

	cQuery := WSALJContPart(lTotal, cCodCliente)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cAlias, .T., .F. )

	lHasReg := !(cAlias)->(EOF())

	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If lHasReg
		If lTotal
			oResponse['total'] := (cAlias)->QTD_JUNCAO
		Else
			While (cAlias)->(!Eof())
				nIndPage++
				
				If (aPaginacao[1] .and. nIndPage > aPaginacao[3])
					oResponse['hasNext'] := .T.
					Exit
				ElseIf (!aPaginacao[1] .Or. ;
				        (aPaginacao[1] .And. nIndPage > aPaginacao[2] .And. nIndPage <= aPaginacao[3]))
					Aadd(oResponse['items'], JsonObject():New())
					aTail(oResponse['items'])['codigo']     := (cAlias)->NW2_FILIAL + (cAlias)->NW2_COD
					aTail(oResponse['items'])['codGrupo']   := (cAlias)->NW2_CGRUPO
					aTail(oResponse['items'])['descGrupo']  := JConvUTF8((cAlias)->ACY_DESCRI)
					aTail(oResponse['items'])['codCliente'] := (cAlias)->NW2_CCLIEN

					If !lLojaAuto
						aTail(oResponse['items'])['codCliente'] := aTail(oResponse['items'])['codCliente'] + " - " + (cAlias)->NW2_CLOJA
					EndIf

					aTail(oResponse['items'])['cliente']     := JConvUTF8((cAlias)->A1_NOME)
					aTail(oResponse['items'])['descricao']   := JConvUTF8((cAlias)->NW2_DESC)
					aTail(oResponse['items'])['codSocio']    := (cAlias)->RD0_CODIGO
					aTail(oResponse['items'])['codOriginal'] := (cAlias)->RD0_CODIGO
					aTail(oResponse['items'])['siglaSocio']  := JConvUTF8((cAlias)->RD0_SIGLA)
					aTail(oResponse['items'])['descSocio']   := JConvUTF8((cAlias)->RD0_NOME)
					aTail(oResponse['items'])['updated']     := .F.
				EndIf
				(cAlias)->( dbSkip() )
			endDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALJContPart(lCount)
Responsável por filtrar os contratos da Junção de contratos de acordo
com o participante revisor da junção. Filtra contratos da Junção de
contratos que estão ativos. Considera se ao menos um dos contratos
da junção estiver ativo.

@param lCount      - Indica se deverá retornar a quantidade de registros
@param cCodCliente - Código do Cliente
@return cQuery     - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALJContPart(lCount, cCodCliente)
Local cQuery  := " SELECT"

Default lCount      := .F.
Default cCodcliente := " "

	If lCount
		cQuery += " COUNT(NW2.NW2_COD) QTD_JUNCAO"
	Else
		cQuery +=  " ACY.ACY_DESCRI"
		cQuery += " ,NW2.NW2_FILIAL"
		cQuery += " ,NW2.NW2_CGRUPO"
		cQuery += " ,NW2.NW2_CCLIEN"
		cQuery += " ,NW2.NW2_COD"
		cQuery += " ,NW2.NW2_CLOJA"
		cQuery += " ,NW2.NW2_DESC"
		cQuery += " ,NW2.NW2_CPART"
		cQuery += " ,SA1.A1_NOME"
		cQuery += " ,RD0.RD0_CODIGO"
		cQuery += " ,RD0.RD0_SIGLA"
		cQuery += " ,RD0.RD0_NOME"
	EndIf

	cQuery += " FROM " + RetSqlName( "NW2" ) + " NW2"
	cQuery +=       " INNER JOIN " + RetSqlName( "RD0" ) + " RD0"
	cQuery +=           " ON RD0.RD0_CODIGO = NW2.NW2_CPART"
	cQuery +=               " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=       " INNER JOIN ( SELECT NW3.NW3_CJCONT, COUNT(1) QTD"
	cQuery +=                      " FROM " + RetSqlName( "NW3" ) + " NW3" 
	cQuery +=                             " INNER JOIN " + RetSqlName( "NT0" ) + " NT0"
	cQuery +=                                 " ON (NT0.NT0_COD = NW3.NW3_CCONTR)"
	cQuery +=                             " WHERE NW3.D_E_L_E_T_ = ' '"
	cQuery +=                                  " AND NT0.D_E_L_E_T_ = ' '"
	cQuery +=                                  " AND NT0_ATIVO = '1'"   // Ativo? 1=Sim (Se ao menos um dos contratos da junção estiver ativo)
	cQuery +=                             " GROUP BY NW3.NW3_CJCONT"
	cQuery +=                             " HAVING COUNT(1) > 0"
	cQuery +=                   " ) SUBNW3"
	cQuery +=                      " ON (SUBNW3.NW3_CJCONT = NW2.NW2_COD)"

	// Cliente
	cQuery += " INNER JOIN " + RetSqlName( "SA1" ) + " SA1"
	cQuery +=       " ON NW2.NW2_CCLIEN = SA1.A1_COD"
	cQuery +=       " AND NW2.NW2_CLOJA = SA1.A1_LOJA"
	cQuery +=       " AND SA1.D_E_L_E_T_  = ' '"

	// Grupo de cliente
	cQuery += " LEFT JOIN " +  RetSqlName('ACY') + " ACY"
	cQuery +=      " ON (ACY.ACY_GRPVEN = NW2.NW2_CGRUPO"
	cQuery +=      " AND ACY.D_E_L_E_T_ = ' ')"

	cQuery += " WHERE NW2.D_E_L_E_T_ = ' '"
	cQuery +=       " AND NW2.NW2_CPART = ?"

	If !Empty(cCodCliente)
		cQuery += " AND NW2.NW2_CCLIEN = ?"
		cQuery += " AND NW2.NW2_CLOJA = ?"
	EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET preFaturas
Busca os contratos no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/preFatura/{codPart}

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET preFaturas PATHPARAM codPart QUERYPARAM qtdTotal, codCliente WSREST WSPFSAltLote
Local aArea      := GetArea()
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local lHasReg    := .F.
Local nIndPage   := 0
Local cAlias     := GetNextAlias()
Local cCodPart   := Self:codPart
Local lTotal     := Self:qtdTotal
Local cCodCliente:= Self:codCliente
Local aCliente   := {}
Local aParams    := {cCodPart, cCodPart, cCodPart}
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lMultRev   := SuperGetMV("MV_JMULTRV",, .F.)
Local aPaginacao := SetPagSize(Self:page, Self:pageSize)

Default cCodPart    := ""
Default lTotal      := .F.
Default cCodCliente := ""

	If !Empty(cCodCliente)
		aCliente := StrTokArr(cCodCliente,"-" )
		aAdd(aParams, aCliente[1])
		aAdd(aParams, aCliente[2])
	EndIf

	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL, WSALPFatPart(lTotal, cCodCliente), aParams ), cAlias, .T., .F. )

	lHasReg := !(cAlias)->(Eof())

	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If lHasReg
		If lTotal
			oResponse['total'] := (cAlias)->QTD_PRE_FAT
		Else
			While (cAlias)->(!Eof())
				nIndPage++
				
				If (aPaginacao[1] .and. nIndPage > aPaginacao[3])
					oResponse['hasNext'] := .T.
					Exit
				ElseIf (!aPaginacao[1] .Or. ;
				        (aPaginacao[1] .And. nIndPage > aPaginacao[2] .And. nIndPage <= aPaginacao[3]))
					Aadd(oResponse['items'], JsonObject():New())
					aTail(oResponse['items'])['codigo']         := (cAlias)->NX0_FILIAL + (cAlias)->NX0_COD
					aTail(oResponse['items'])['situacao']       := JConvUTF8((cAlias)->NX0_SITUAC)
					aTail(oResponse['items'])['dataEmissao']    := (cAlias)->NX0_DTEMI
					aTail(oResponse['items'])['vlrHonorario']   := (cAlias)->NX0_VLFATH
					aTail(oResponse['items'])['vlrDespesa']     := (cAlias)->NX0_VLFATD
					aTail(oResponse['items'])['codEscritorio']  := (cAlias)->NX0_CESCR
					aTail(oResponse['items'])['codCliente']     := (cAlias)->NX0_CCLIEN
					
					If !lLojaAuto
						aTail(oResponse['items'])['codCliente'] := aTail(oResponse['items'])['codCliente'] + " - " + (cAlias)->NX0_CLOJA
					EndIf
					
					aTail(oResponse['items'])['cliente']        := JConvUTF8((cAlias)->A1_NOME)
					aTail(oResponse['items'])['codContr']       := (cAlias)->NX0_CCONTR
					aTail(oResponse['items'])['capa']           := RetPartCapa(cAlias)
					aTail(oResponse['items'])['descEscritorio'] := JConvUTF8((cAlias)->NS7_NOME)
					aTail(oResponse['items'])['descMoeda']      := JConvUTF8((cAlias)->CTO_DESC)
					aTail(oResponse['items'])['simbMoeda']      := AllTrim((cAlias)->CTO_SIMB)
					aTail(oResponse['items'])['contratos']      := JConvUTF8(PreFatCont((cAlias)->NX0_COD))

					aTail(oResponse['items'])['casos']          := {}
					aTail(oResponse['items'])['casos']          := PreFatCaso((cAlias)->NX0_COD)
					
					aTail(oResponse['items'])['multRevisores']  := {}
					If (lMultRev)
						aTail(oResponse['items'])['multRevisores']  := MultPart(cQryMltPart('PREFATURA'), { (cAlias)->NX0_COD })
					EndIf
				EndIf
				(cAlias)->( dbSkip() )
			endDo
		EndIf
	EndIf

	(cAlias)->( DbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPartCapa(cAlias)
Responsável por filtrar as Pré-Faturas de acordo com o participante
revisor. Filtra contratos da Junção de
contratos que estão ativos. Considera se ao menos um dos contratos
da junção estiver ativo.

@param lCount  - Indica se deverá retornar a quantidade de registros
@return cQuery - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetPartCapa(cAlias)
Local oPart := JSonObject():New()

	oPart['codigo']      := (cAlias)->RD0_CODIGO
	oPart['nome']        := JConvUTF8((cAlias)->RD0_NOME)
	oPart['sigla']       := JConvUTF8((cAlias)->RD0_SIGLA)
	oPart['codOriginal'] := (cAlias)->RD0_CODIGO
	oPart['updated']     := .F.
	oPart['deleted']     := .F.
Return oPart

//-------------------------------------------------------------------
/*/{Protheus.doc} WSALPFatPart(lCount)
Responsável por filtrar as Pré-Faturas de acordo com o participante
revisor. Filtra contratos da Junção de
contratos que estão ativos. Considera se ao menos um dos contratos
da junção estiver ativo.

@param lCount      - Indica se deverá retornar a quantidade de registros
@param cCodCliente - Código do Cliente
@return cQuery     - Query

@author Rebeca Facchinato Asunção
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function WSALPFatPart(lCount, cCodCliente)
Local cQryPreFat  := " SELECT"
Local lMultRev    := SuperGetMV("MV_JMULTRV",, .F.)

Default lCount      := .F.
Default cCodCliente := ""

	If lCount
		cQryPreFat += " COUNT(NX0.NX0_CPART) QTD_PRE_FAT"
	Else
		cQryPreFat += "  NX0.NX0_FILIAL"
		cQryPreFat += " ,NX0.NX0_COD"
		cQryPreFat += " ,NX0.NX0_SITUAC"
		cQryPreFat += " ,NX0.NX0_DTEMI"
		cQryPreFat += " ,NX0.NX0_VLFATH"
		cQryPreFat += " ,NX0.NX0_VLFATD"
		cQryPreFat += " ,NX0.NX0_CESCR"
		cQryPreFat += " ,NX0.NX0_CCLIEN"
		cQryPreFat += " ,NX0.NX0_CLOJA"
		cQryPreFat += " ,SA1.A1_NOME"
		cQryPreFat += " ,NX0.NX0_CCONTR"
		cQryPreFat += " ,RD0CAPA.RD0_CODIGO"
		cQryPreFat += " ,RD0CAPA.RD0_NOME"
		cQryPreFat += " ,RD0CAPA.RD0_SIGLA"
		cQryPreFat += " ,NS7.NS7_NOME"
		cQryPreFat += " ,CTO.CTO_DESC"
		cQryPreFat += " ,CTO.CTO_SIMB"
	EndIf

	cQryPreFat +=  " FROM " + RetSqlName( "NX0" ) + " NX0"
	cQryPreFat += " INNER JOIN " + RetSqlName( "SA1" ) + " SA1"
	cQryPreFat +=    " ON NX0.NX0_CCLIEN  = SA1.A1_COD"
	cQryPreFat +=   " AND NX0.NX0_CLOJA   = SA1.A1_LOJA"
	cQryPreFat +=   " AND SA1.D_E_L_E_T_  = ' '"
	cQryPreFat += " INNER JOIN " + RetSqlName( "NS7" ) + " NS7"
	cQryPreFat +=    " ON NX0.NX0_CESCR   = NS7.NS7_COD"
	cQryPreFat +=   " AND NS7.D_E_L_E_T_  = ' '"
	cQryPreFat += " INNER JOIN " + RetSqlName( "RD0" ) + " RD0CAPA"
	cQryPreFat +=    " ON NX0.NX0_CPART   = RD0CAPA.RD0_CODIGO"
	cQryPreFat +=   " AND RD0CAPA.D_E_L_E_T_ = ' '"
	cQryPreFat += " INNER JOIN " + RetSqlName( "CTO" ) + " CTO"
	cQryPreFat +=    " ON CTO.CTO_MOEDA   = NX0.NX0_CMOEDA"
	cQryPreFat +=   " AND CTO.CTO_FILIAL  = NS7.NS7_CFILIA"
	cQryPreFat +=   " AND CTO.D_E_L_E_T_  = ' '"
	cQryPreFat += " WHERE NX0.D_E_L_E_T_  = ' '"
	cQryPreFat +=   " AND NX0_SITUAC IN('2',"   // 2 - Análise
	cQryPreFat +=                     " '3',"   // 3 - Alterada
	cQryPreFat +=                     " '7',"   // 7 - Minuta cancelada
	cQryPreFat +=                     " 'C',"   // C - Em revisão
	cQryPreFat +=                     " 'E',"   // E - Revisada com restrições
	cQryPreFat +=                     " 'B')"   // B - Minuta Sócio Cancelada
	cQryPreFat +=   " AND ( NX0.NX0_CPART = ?"
	cQryPreFat +=      " OR EXISTS ("
	cQryPreFat +=         " SELECT NX1.NX1_CPREFT"
	cQryPreFat +=           " FROM " + RetSqlName("NX1") + " NX1"
	cQryPreFat +=          " WHERE NX1.NX1_FILIAL = NX0.NX0_FILIAL"
	cQryPreFat +=            " AND NX1.NX1_CPREFT = NX0.NX0_COD"
	cQryPreFat +=            " AND NX1.NX1_CPART = ?"
	cQryPreFat +=            " AND NX1.D_E_L_E_T_ = ' '"
	cQryPreFat +=         " )"
	
	// Verifica se o participante está no grid em múltiplos revisores
	if (lMultRev)
		cQryPreFat +=      " OR EXISTS ("
		cQryPreFat +=         " SELECT OHN.OHN_CCASO"
		cQryPreFat +=           " FROM " + RetSqlName( "OHN" ) + " OHN"
		cQryPreFat +=          " INNER JOIN " + RetSqlName( "RD0" ) + " RD0"
		cQryPreFat +=             " ON RD0.RD0_CODIGO = OHN.OHN_CPART"
		cQryPreFat +=            " AND RD0.D_E_L_E_T_ = ' '"
		cQryPreFat +=          " WHERE OHN.OHN_FILIAL = NX0.NX0_FILIAL"
		cQryPreFat +=            " AND OHN.OHN_CPREFT = NX0.NX0_COD"
		cQryPreFat +=            " AND OHN.OHN_CPART = ?"
		cQryPreFat +=            " AND OHN.D_E_L_E_T_ = ' '"
		cQryPreFat +=          " )"
	EndIf

	cQryPreFat +=       " )"
	If !Empty(cCodCliente)
		cQryPreFat += " AND NX0.NX0_CCLIEN  = ?"
		cQryPreFat += " AND NX0.NX0_CLOJA   = ?"
	EndIf

	If !lCount
		cQryPreFat += " ORDER BY NX0.NX0_COD"
	EndIf
Return cQryPreFat

//-------------------------------------------------------------------
/*/{Protheus.doc} PreFatCaso(cPreFat)
Responsável por busca número do caso e título do caso

@param cPreFat - Código da Pré-Fatura 
@return cResp  - String com numero do caso + título do caso

@author Victor Gonçalves
@since 20/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PreFatCaso(cPreFat)
Local cQuery   := ""
Local cAlias   := ""
Local nIndexJS := 0
Local aResp    := {}

	cQuery += " SELECT NX1.NX1_FILIAL,"
	cQuery +=        " NVE.NVE_TITULO,"
	cQuery +=        " NVE.NVE_NUMCAS,"
	cQuery +=        " NX1.NX1_CPREFT,"
	cQuery +=        " NX1.NX1_CCONTR,"
	cQuery +=        " NX1.NX1_CJCONT,"
	cQuery +=        " NX1.NX1_CCLIEN,"
	cQuery +=        " NX1.NX1_CLOJA,"
	cQuery +=        " NX1.NX1_CCASO,"
	cQuery +=        " NX1.NX1_CPART,"
	cQuery +=        " RD0.RD0_SIGLA,"
	cQuery +=        " RD0.RD0_NOME"
	cQuery +=   " FROM " + RetSqlName("NX1") + " NX1"
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + " RD0"
	cQuery +=     " ON RD0.RD0_CODIGO = NX1.NX1_CPART"
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName( "NVE" ) + " NVE"
	cQuery +=     " ON NVE.NVE_FILIAL = NX1.NX1_FILIAL"
	cQuery +=    " AND NVE.NVE_CCLIEN = NX1.NX1_CCLIEN"
	cQuery +=    " AND NVE.NVE_LCLIEN = NX1.NX1_CLOJA"
	cQuery +=    " AND NVE.NVE_NUMCAS = NX1.NX1_CCASO"
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NX1.NX1_CPREFT = ?"
	cQuery +=    " AND NX1.D_E_L_E_T_ = ' '"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ cPreFat }), cAlias, .T., .T. )

	While !( cAlias )->(Eof()) 
		nIndexJS++
		aAdd(aResp, JsonObject():New())
		aResp[nIndexJS]['chave'] :=  (cAlias)->NX1_FILIAL ;
								   + (cAlias)->NX1_CPREFT ;
								   + (cAlias)->NX1_CCONTR ;
								   + (cAlias)->NX1_CJCONT ;
								   + (cAlias)->NX1_CCLIEN ;
								   + (cAlias)->NX1_CLOJA ;
								   + (cAlias)->NX1_CCASO 
		
		aResp[nIndexJS]['participante']                := JsonObject():New()
		aResp[nIndexJS]['participante']['codOriginal'] := (cAlias)->NX1_CPART
		aResp[nIndexJS]['participante']['codigo']      := (cAlias)->NX1_CPART
		aResp[nIndexJS]['participante']['nome']        := JConvUTF8((cAlias)->RD0_NOME)
		aResp[nIndexJS]['participante']['sigla']       := JConvUTF8((cAlias)->RD0_SIGLA)
		aResp[nIndexJS]['participante']['updated']     := .F.
		aResp[nIndexJS]['participante']['deleted']     := .F.

		aResp[nIndexJS]['caso']                        := JsonObject():New()
		aResp[nIndexJS]['caso']['codigo']              := (cAlias)->NVE_NUMCAS
		aResp[nIndexJS]['caso']['titulo']              := JConvUTF8((cAlias)->NVE_TITULO)

		(cAlias)->( dbSkip() )
	End

	( cAlias )->( dbCloseArea() )
Return aResp

//-------------------------------------------------------------------
/*/{Protheus.doc} PreFatCont(cPreFat)
Responsável por retornar o código e título do contrato

@param cPreFat - Código da Pré-Fatura 
@return cResp  - String com o código e título do contrato

@author Victor Gonçalves
@since 20/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PreFatCont(cPreFat)
Local cQuery := ""
Local cAlias := ""
Local cResp  := ""

	cQuery +=  " SELECT NT0.NT0_NOME"
	cQuery +=        " ,NT0.NT0_COD"
	cQuery +=       " FROM " + RetSqlName( "NX8" ) + " NX8"
	cQuery +=             " INNER JOIN " + RetSqlName( "NT0" ) + " NT0"
	cQuery +=                 " ON NX8.NX8_CCLIEN = NT0.NT0_CCLIEN"
	cQuery +=                     " AND NX8.NX8_CLOJA = NT0.NT0_CLOJA"
	cQuery +=                     " AND NX8.NX8_CCONTR = NT0.NT0_COD"
	cQuery += 	   " WHERE NX8.NX8_CPREFT = ?"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ cPreFat }), cAlias, .T., .T. )

	While !( cAlias )->(Eof()) 
		cResp += (cAlias)->NT0_COD + (cAlias)->NT0_NOME + ";"
		(cAlias)->( dbSkip() )
	End

	If Len(cResp) > 0
		cResp := SUBSTR( cResp, 0, Len(cResp)-1)
	EndIf

	( cAlias )->( dbCloseArea() )

Return cResp

//-------------------------------------------------------------------
/*/{Protheus.doc} PreFatMult(cPreFat)
Responsável por retornar a lista de mútiplos revisores  da pré fatura

@param cPreFat   - Código da Pré-Fatura
@return oResponse - Objeto com a lista de mútiplos revisores da pré fatura

@author Victor Gonçalves
@since 20/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MultPart(cQuery, aParams)
Local oResponse  := {}
Local aCboxTpRev := {}
Local cAliasMlt  := ""
Local nIndexJSon := 0
Local nI         := 0

Default cQuery   := ""
Default aParams  := {}

	// 1=Honorários;2=Despesas;3=Ambos
	aCboxTpRev := STRTOKARR(JurEncUTF8(ALLTRIM(GetSx3Cache("OHN_REVISA","X3_CBOX"))),";")

	For nI := 1 To Len(aCboxTpRev)
		aCboxTpRev[nI] := StrTokArr(aCboxTpRev[nI],"=")
	Next nI

	cAliasMlt := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL, cQuery, aParams ), cAliasMlt, .T., .T. )

	While !( cAliasMlt )->(Eof()) 
		nIndexJSon++
		Aadd(oResponse, JsonObject():New())
		oResponse[nIndexJSon]['chave'] := (cAliasMlt)->OHN_FILIAL ;
										+ (cAliasMlt)->OHN_CPREFT ;
										+ (cAliasMlt)->OHN_CCONTR ;
										+ (cAliasMlt)->OHN_CCLIEN ;
										+ (cAliasMlt)->OHN_CLOJA  ;
										+ (cAliasMlt)->OHN_CCASO  ;
										+ (cAliasMlt)->OHN_CPART  ;
										+ (cAliasMlt)->OHN_REVISA

		oResponse[nIndexJSon]['participante']                := JsonObject():New()
		oResponse[nIndexJSon]['participante']['codigo']      := (cAliasMlt)->RD0_CODIGO
		oResponse[nIndexJSon]['participante']['nome']        := JConvUTF8((cAliasMlt)->RD0_NOME)
		oResponse[nIndexJSon]['participante']['sigla']       := JConvUTF8((cAliasMlt)->RD0_SIGLA)
		oResponse[nIndexJSon]['participante']['codOriginal'] := (cAliasMlt)->RD0_CODIGO
		oResponse[nIndexJSon]['participante']['updated']     := .F.
		oResponse[nIndexJSon]['participante']['deleted']     := .F.

		nPosTipRev := aScan(aCboxTpRev, {|x| x[1] == (cAliasMlt)->OHN_REVISA})
		oResponse[nIndexJSon]['tipoRevisao']                 := JSonObject():New()
		oResponse[nIndexJSon]['tipoRevisao']['codigo']       := (cAliasMlt)->OHN_REVISA
		oResponse[nIndexJSon]['tipoRevisao']['descricao']    := JConvUTF8(aCboxTpRev[nPosTipRev][2])

		(cAliasMlt)->( dbSkip() )
	End

	( cAliasMlt )->( dbCloseArea() )

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET fatAdicional
Busca as Faturas Adicionais no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/faturaAdicional/{codPart}

@author Willian Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET fatAdicional PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local lRet       := .T.
Local lHasOcorre := .F.
Local lHasReg    := .F.
Local nIndexJSon := 0
Local cQuery     := ""
Local cAlias     := ""
Local oResponse  := JSonObject():New()
Local lTotal     := Self:qtdTotal

Default lTotal   := .F.

	DbSelectArea("NVV")
	lHasOcorre := NVV->(FieldPos("NVV_OCORRE")) > 0
	NVV->( DBCloseArea() )

	If lTotal
		cQuery += " SELECT COUNT(1) QtdTotal"
	Else
		cQuery += " SELECT NVV_COD,"
		cQuery +=        " NVV_DTBASE,"
		cQuery +=        " NVV_CGRUPO,"
		cQuery +=        " ACY.ACY_DESCRI,"
		cQuery +=        " NVV_CCLIEN,"
		cQuery +=        " NVV_CLOJA,"
		cQuery +=        " SA1.A1_NOME,"
		cQuery +=        " NVV_CCONTR,"
		cQuery +=        " NT0.NT0_NOME,"
		cQuery +=        " NVV_VALORH,"
		cQuery +=        " NVV_VALORT,"
		cQuery +=        " NVV_VALORD,"
		cQuery +=        " NVV_VALDTR"

		If lHasOcorre
			cQuery +=        " ,NVV_OCORRE"
		EndIf
	EndIf

	cQuery += " FROM " + RetSqlName('NVV') + " NVV INNER JOIN " +  RetSqlName('RD0') + " RD0 ON (RD0.RD0_CODIGO = NVV.NVV_CPART1"
	cQuery +=                                                                             " AND RD0.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " +  RetSqlName('SA1') + " SA1 ON (SA1.A1_COD = NVV.NVV_CCLIEN"
	cQuery +=                                                                             " AND SA1.A1_LOJA = NVV.NVV_CLOJA"
	cQuery +=                                                                             " AND SA1.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " +  RetSqlName('NT0') + " NT0 ON (NT0.NT0_COD = NVV.NVV_CCONTR"
	cQuery +=                                                                             " AND NT0.NT0_CCLIEN = NVV.NVV_CCLIEN"
	cQuery +=                                                                             " AND NT0.NT0_CLOJA = NVV.NVV_CLOJA"
	cQuery +=                                                                             " AND NT0.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " LEFT  JOIN " +  RetSqlName('ACY') + " ACY ON (ACY.ACY_GRPVEN = NVV.NVV_CGRUPO"
	cQuery +=                                                                             " AND ACY.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE NVV_CPART1 = ?"
	cQuery +=        " AND NVV.D_E_L_E_T_ = ' '"
	cQuery +=        " AND NVV.NVV_SITUAC = '1'" // 1=Pendente

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ Self:codPart }), cAlias, .T., .F. )

	lHasReg := !( cAlias )->(Eof())

	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If (lTotal)
		oResponse['total'] := (cAlias)->QtdTotal
	Else
		While !( cAlias )->(Eof())
			nIndexJSon++
			Aadd(oResponse['items'], JsonObject():New())
			aTail(oResponse['items'])['codigo']             := (cAlias)->NVV_COD
			aTail(oResponse['items'])['database']           := (cAlias)->NVV_DTBASE
			aTail(oResponse['items'])['codGrupo']           := (cAlias)->NVV_CGRUPO
			aTail(oResponse['items'])['descGrupo']          := JConvUTF8((cAlias)->ACY_DESCRI)
			aTail(oResponse['items'])['codCliente']         := (cAlias)->NVV_CCLIEN
			aTail(oResponse['items'])['lojaCliente']        := (cAlias)->NVV_CLOJA
			aTail(oResponse['items'])['cliente']            := JConvUTF8((cAlias)->A1_NOME)
			aTail(oResponse['items'])['codContrato']        := (cAlias)->NVV_CCONTR
			aTail(oResponse['items'])['nomeContrato']       := JConvUTF8((cAlias)->NT0_NOME)
			aTail(oResponse['items'])['valorTS']            := (cAlias)->NVV_VALORH
			aTail(oResponse['items'])['valorTabelado']      := (cAlias)->NVV_VALORT
			aTail(oResponse['items'])['valorDespesa']       := (cAlias)->NVV_VALORD
			aTail(oResponse['items'])['valorDespesaTrib']   := (cAlias)->NVV_VALDTR

			If lHasOcorre
				aTail(oResponse['items'])['flagOcorrencia'] := (cAlias)->NVV_OCORRE
			EndIf

			(cAlias)->( dbSkip() )
		End
	EndIf

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET timesheet
Busca os Time Sheets no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/timesheet/{codPart}

@author Willian Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET timesheet PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local lRet       := .T.
Local lHasReg    := .F.
Local cQuery     := ""
Local cAlias     := ""
Local cDesc      := ""
Local oResponse  := JSonObject():New()
Local lTotal     := Self:qtdTotal
Local cModeCTO   := FWModeAccess("CTO",1) + FWModeAccess("CTO",2) + FWModeAccess("CTO",3)

Default lTotal   := .F.

	If lTotal
		cQuery += " SELECT COUNT(1) QtdTotal"
	Else
		cQuery += " SELECT NUE.NUE_COD,"
		cQuery +=        " NUE.NUE_DATATS,"
		cQuery +=        " NUE.NUE_CPART1,"
		cQuery +=        " RD0SOL.RD0_NOME  NOME_SOL,"
		cQuery +=        " RD0SOL.RD0_SIGLA SIGLA_SOL,"
		cQuery +=        " NUE.NUE_CPART2,"
		cQuery +=        " RD0REV.RD0_NOME  NOME_REV,"
		cQuery +=        " RD0REV.RD0_SIGLA SIGLA_REV,"
		cQuery +=        " NUE.NUE_CCLIEN,"
		cQuery +=        " NUE.NUE_CLOJA,"
		cQuery +=        " SA1.A1_NOME,"
		cQuery +=        " NUE.NUE_CCASO,"
		cQuery +=        " NVE.NVE_TITULO,"
		cQuery +=        " NUE.NUE_CATIVI,"
		cQuery +=        " NRC.NRC_DESC,"
		cQuery +=        " NUE.NUE_HORAL,"
		cQuery +=        " NUE.NUE_HORAR,"
		cQuery +=        " NUE.NUE_UTL,"
		cQuery +=        " NUE.NUE_UTR,"
		cQuery +=        " NUE.NUE_COBRAR,"
		cQuery +=        " NUE.NUE_CMOEDA,"
		cQuery +=        " CTO.CTO_SIMB,"
		cQuery +=        " CTO.CTO_DESC,"
		cQuery +=        " NUE.NUE_VALOR,"
		cQuery +=        " NUE.NUE_FILIAL "
	EndIf

	cQuery += " FROM " +  RetSqlName("NUE") + " NUE INNER JOIN " +  RetSqlName("RD0") + " RD0SOL ON (RD0SOL.RD0_CODIGO = NUE.NUE_CPART1"
	cQuery +=                                                                                  " AND RD0SOL.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("RD0") + " RD0REV ON (RD0REV.RD0_CODIGO = NUE.NUE_CPART2"
	cQuery +=                                                                                  " AND RD0REV.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("SA1") + " SA1 ON (SA1.A1_COD     = NUE.NUE_CCLIEN"
	cQuery +=                                                                               " AND SA1.A1_LOJA    = NUE.NUE_CLOJA"
	cQuery +=                                                                               " AND SA1.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("NVE") + " NVE ON (NVE.NVE_CCLIEN = NUE.NUE_CCLIEN"
	cQuery +=                                                                               " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA"
	cQuery +=                                                                               " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO"
	cQuery +=                                                                               " AND NVE.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("NRC") + " NRC ON (NRC.NRC_COD    = NUE.NUE_CATIVI"
	cQuery +=                                                                               " AND NRC.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("NS7") + " NS7 ON (NS7.NS7_COD    = NUE.NUE_CESCR"
	cQuery +=                                                                               " AND NS7.D_E_L_E_T_ = ' ')"
	cQuery +=                                     " INNER JOIN " +  RetSqlName("CTO") + " CTO ON (CTO.CTO_MOEDA  = NUE.NUE_CMOEDA"
	
	// Somente inclui o relacionamento com o Escritório quando a moeda for exclusiva
	If !( cModeCTO  == "CCC" )
		cQuery +=                                                                          " AND CTO.CTO_FILIAL = NS7.NS7_CFILIA"
	EndIf

	cQuery +=                                                                               " AND CTO.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE ( NUE.NUE_CPART1 = ?"
	cQuery +=          " OR NUE.NUE_CPART2 = ? )"
	cQuery +=   " AND NUE.D_E_L_E_T_ = ' '"
	cQuery +=   " AND NUE.NUE_SITUAC = '1'"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ Self:codPart, Self:codPart }), cAlias, .T., .F. )

	lHasReg := !( cAlias )->(Eof())

	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If (lTotal)
		If !( cAlias )->(Eof())
			oResponse['total'] := (cAlias)->QtdTotal
		EndIf
	Else
		While !( cAlias )->(Eof())
			cDesc := JurGetDados("NUE", 1, (cAlias)->NUE_FILIAL + (cAlias)->NUE_COD, "NUE_DESC")
			Aadd(oResponse['items'], JsonObject():New())
			aTail(oResponse['items'])['codigo']           := (cAlias)->NUE_COD
			aTail(oResponse['items'])['data']             := (cAlias)->NUE_DATATS
			aTail(oResponse['items'])['codPartSolic']     := (cAlias)->NUE_CPART1
			aTail(oResponse['items'])['nomePartSolic']    := JConvUTF8((cAlias)->NOME_SOL)
			aTail(oResponse['items'])['siglaPartSolic']   := (cAlias)->SIGLA_SOL
			aTail(oResponse['items'])['codPartRevis']     := (cAlias)->NUE_CPART2
			aTail(oResponse['items'])['nomePartRevis']    := JConvUTF8((cAlias)->NOME_REV)
			aTail(oResponse['items'])['siglaPartRevis']   := (cAlias)->SIGLA_REV
			aTail(oResponse['items'])['codCliente']       := (cAlias)->NUE_CCLIEN
			aTail(oResponse['items'])['lojaCliente']      := (cAlias)->NUE_CLOJA
			aTail(oResponse['items'])['cliente']          := JConvUTF8((cAlias)->A1_NOME)
			aTail(oResponse['items'])['codCaso']          := (cAlias)->NUE_CCASO
			aTail(oResponse['items'])['tituloCaso']       := JConvUTF8((cAlias)->NVE_TITULO)
			aTail(oResponse['items'])['codAtividade']     := (cAlias)->NUE_CATIVI
			aTail(oResponse['items'])['descAtividade']    := JConvUTF8((cAlias)->NRC_DESC)
			aTail(oResponse['items'])['horaLancada']      := (cAlias)->NUE_HORAL
			aTail(oResponse['items'])['horaRevisada']     := (cAlias)->NUE_HORAR
			aTail(oResponse['items'])['UTLancada']        := (cAlias)->NUE_UTL
			aTail(oResponse['items'])['UTRevisada']       := (cAlias)->NUE_UTR
			aTail(oResponse['items'])['cobrar']           := (cAlias)->NUE_COBRAR
			aTail(oResponse['items'])['codMoeda']         := (cAlias)->NUE_CMOEDA
			aTail(oResponse['items'])['simbMoeda']        := (cAlias)->CTO_SIMB
			aTail(oResponse['items'])['descMoeda']        := JConvUTF8((cAlias)->CTO_DESC)
			aTail(oResponse['items'])['valorTS']          := (cAlias)->NUE_VALOR
			aTail(oResponse['items'])['descTS']           := JConvUTF8(cDesc)
			(cAlias)->( dbSkip() )
		End
	EndIf

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GET titReceber
Busca os Títulos a receber no qual o participante é sócio / revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/tituloReceber/{codPart}

@author Willian Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET titReceber PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local lRet       := .T.
Local lHasReg    := .F.
Local nIndexJSon := 0
Local cQuery     := ""
Local cAlias     := ""
Local oResponse  := JSonObject():New()
Local lTotal     := Self:qtdTotal
Local cAnoMes    := AnoMes(Date())

Default lTotal   := .F.

	If lTotal
		cQuery += " SELECT COUNT(*) QtdTotal"
	Else
		cQuery += " SELECT SE1.E1_PREFIXO"
		cQuery +=       " ,SE1.E1_NUM"
		cQuery +=       " ,SE1.E1_PARCELA"
		cQuery +=       " ,SE1.E1_TIPO"
		cQuery +=       " ,NXA.NXA_CPART"
		cQuery +=       " ,RD0.RD0_SIGLA"
		cQuery +=       " ,RD0.RD0_NOME"
		cQuery +=       " ,SE1.E1_NATUREZ"
		cQuery +=       " ,SED.ED_DESCRIC"
		cQuery +=       " ,SE1.E1_EMISSAO"
		cQuery +=       " ,SE1.E1_VENCTO"
		cQuery +=       " ,SE1.E1_VENCREA"
		cQuery +=       " ,SE1.E1_VALOR"
		cQuery +=       " ,SE1.E1_VLRREAL"
		cQuery +=       " ,OHH.OHH_SALDO"
		cQuery +=       " ,SE1.E1_HIST"
	EndIf

	cQuery += " FROM " + RetSqlName("OHH") + " OHH INNER JOIN " + RetSqlName("OHT") + " OHT ON (OHT.OHT_PREFIX = OHH.OHH_PREFIX"
	cQuery +=                                                                             " AND OHT.OHT_TITNUM = OHH.OHH_NUM"
	cQuery +=                                                                             " AND OHT.OHT_TITPAR = OHH.OHH_PARCEL"
	cQuery +=                                                                             " AND OHT.OHT_TITTPO = OHH.OHH_TIPO"
	cQuery +=                                                                             " AND OHT.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("SE1") + " SE1 ON (SE1.E1_PREFIXO = OHH.OHH_PREFIX"
	cQuery +=                                                                             " AND SE1.E1_NUM     = OHH.OHH_NUM"
	cQuery +=                                                                             " AND SE1.E1_PARCELA = OHH.OHH_PARCEL"
	cQuery +=                                                                             " AND SE1.E1_TIPO    = OHH.OHH_TIPO"
	cQuery +=                                                                             " AND SE1.E1_CLIENTE = OHH.OHH_CCLIEN"
	cQuery +=                                                                             " AND SE1.E1_LOJA    = OHH.OHH_CLOJA"
	cQuery +=                                                                             " AND SE1.E1_NATUREZ = OHH.OHH_CNATUR"
	cQuery +=                                                                             " AND SE1.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("NXA") + " NXA ON (NXA.NXA_CESCR  = OHT.OHT_FTESCR"
	cQuery +=                                                                             " AND NXA.NXA_COD    = OHT.OHT_CFATUR"
	cQuery +=                                                                             " AND NXA.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("NS7") + " NS7 ON (NS7.NS7_COD    = OHT.OHT_FTESCR"
	cQuery +=                                                                             " AND NS7.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("SA1") + " SA1 ON (SA1.A1_COD     = NXA.NXA_CCLIEN"
	cQuery +=                                                                             " AND SA1.A1_LOJA    = NXA.NXA_CLOJA"
	cQuery +=                                                                             " AND SA1.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("NT0") + " NT0 ON (NT0.NT0_COD    = NXA.NXA_CCONTR"
	cQuery +=                                                                             " AND NT0.NT0_CCLIEN = NXA.NXA_CCLIEN"
	cQuery +=                                                                             " AND NT0.NT0_CLOJA  = NXA.NXA_CLOJA"
	cQuery +=                                                                             " AND NT0.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("SED") + " SED ON (SED.ED_FILIAL  = NS7.NS7_CFILIA"
	cQuery +=                                                                             " AND SED.ED_CODIGO  = OHH.OHH_CNATUR"
	cQuery +=                                                                             " AND SED.D_E_L_E_T_ = ' ')"
	cQuery +=                                    " INNER JOIN " + RetSqlName("RD0") + " RD0 ON (RD0.RD0_CODIGO = NXA.NXA_CPART"
	cQuery +=                                                                             " AND RD0.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE NXA.NXA_CPART = ?"
	cQuery +=   " AND OHH.OHH_ANOMES = ?"
	cQuery +=   " AND OHH.D_E_L_E_T_ = ' '"

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ Self:codPart, cAnoMes }), cAlias, .T., .F. )

	lHasReg := !( cAlias )->(Eof())
	
	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If (lTotal)
		oResponse['total'] := (cAlias)->QtdTotal
	Else
		While !( cAlias )->(Eof())
			nIndexJSon++
			Aadd(oResponse['items'], JsonObject():New())
			aTail(oResponse['items'])['prefixo']            := (cAlias)->E1_PREFIXO
			aTail(oResponse['items'])['numero']             := (cAlias)->E1_NUM
			aTail(oResponse['items'])['parcela']            := (cAlias)->E1_PARCELA
			aTail(oResponse['items'])['tipo']               := (cAlias)->E1_TIPO
			aTail(oResponse['items'])['codPart']            := (cAlias)->NXA_CPART
			aTail(oResponse['items'])['siglaPart']          := (cAlias)->RD0_SIGLA
			aTail(oResponse['items'])['nomePart']           := JConvUTF8((cAlias)->RD0_NOME)
			aTail(oResponse['items'])['codNatureza']        := (cAlias)->E1_NATUREZ
			aTail(oResponse['items'])['descNatureza']       := JConvUTF8((cAlias)->ED_DESCRIC)
			aTail(oResponse['items'])['dataEmissao']        := (cAlias)->E1_EMISSAO
			aTail(oResponse['items'])['dataVencimento']     := (cAlias)->E1_VENCTO
			aTail(oResponse['items'])['dataVencimentoReal'] := (cAlias)->E1_VENCREA
			aTail(oResponse['items'])['valor']              := (cAlias)->E1_VALOR
			aTail(oResponse['items'])['valorReal']          := (cAlias)->E1_VLRREAL
			aTail(oResponse['items'])['saldo']              := (cAlias)->OHH_SALDO
			aTail(oResponse['items'])['historico']          := JConvUTF8((cAlias)->E1_HIST)
			(cAlias)->( dbSkip() )
		End
	EndIf

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GET fatura
Busca as Faturas pendente do Revisor

@example GET -> http://127.0.0.1:9090/rest/WSPFSAltLote/fatura/{codPart}

@author Willian Kazahaya
@since 27/03/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET fatura PATHPARAM codPart QUERYPARAM qtdTotal WSREST WSPFSAltLote
Local lRet       := .T.
Local lHasReg    := .F.
Local cQuery     := ""
Local cAlias     := ""
Local oResponse  := JSonObject():New()
Local lTotal     := Self:qtdTotal
Local cAnoMes    := AnoMes(Date())
Local cModeCTO   := FWModeAccess("CTO",1) + FWModeAccess("CTO",2) + FWModeAccess("CTO",3)

Default lTotal   := .F.

	If lTotal
		cQuery += " SELECT COUNT(1) QtdTotal"
		cQuery += " FROM ( SELECT OHH_CESCR, OHH_CFATUR"
		cQuery +=          " FROM " + RetSqlName("OHH") + " OHH"
		cQuery +=         " INNER JOIN " + RetSqlName("NXA") + " NXA ON (NXA.NXA_CESCR  = OHH.OHH_CESCR"
		cQuery +=                                                  " AND NXA.NXA_COD    = OHH.OHH_CFATUR"
		cQuery +=                                                  " AND NXA.D_E_L_E_T_ = ' ')"
		cQuery +=         " WHERE OHH.D_E_L_E_T_ = ' '"
		cQuery +=           " AND OHH_CFATUR <> ' '"
		cQuery +=           " AND NXA.NXA_CPART = ?"
		cQuery +=           " AND OHH_ANOMES = ?"
		cQuery +=         " GROUP BY OHH.OHH_CFATUR,"
		cQuery +=                  " OHH.OHH_CESCR) FATURAS_PART"
	Else
		cQuery += " SELECT OHH.OHH_CFATUR,"
		cQuery +=        " COUNT(1) QtdTitRec,"
		cQuery +=        " NXA.NXA_DTEMI,"
		cQuery +=        " NXA.NXA_CMOEDA,"
		cQuery +=        " CTO.CTO_DESC,"
		cQuery +=        " NXA.NXA_VLFATH,"
		cQuery +=        " NXA.NXA_VLFATD,"
		cQuery +=        " OHH.OHH_CESCR,"
		cQuery +=        " NS7.NS7_NOME,"
		cQuery +=        " NXA.NXA_CPART,"
		cQuery +=        " RD0.RD0_SIGLA,"
		cQuery +=        " RD0.RD0_NOME,"
		cQuery +=        " SUM(OHH.OHH_SALDO) OHH_SALDO"
		cQuery +=   " FROM " + RetSqlName("OHH") + " OHH"
		cQuery +=  " INNER JOIN " + RetSqlName("NXA") + " NXA ON (NXA.NXA_CESCR  = OHH.OHH_CESCR"
		cQuery +=                                           " AND NXA.NXA_COD    = OHH.OHH_CFATUR"
		cQuery +=                                           " AND NXA.D_E_L_E_T_ = ' ')"
		cQuery +=  " INNER JOIN " + RetSqlName("NS7") + " NS7 ON (NS7.NS7_COD    = NXA.NXA_CESCR"
		cQuery +=                                           " AND NS7.D_E_L_E_T_ = ' ')"
		cQuery +=                                    " INNER JOIN " + RetSqlName("CTO") + " CTO ON (CTO.CTO_MOEDA  = NXA.NXA_CMOEDA"
		
		// Somente inclui o relacionamento com o Escritório quando a moeda for exclusiva
		If !( cModeCTO  == "CCC" )
			cQuery +=                                                                          " AND CTO.CTO_FILIAL = NS7.NS7_CFILIA"
		EndIf

		cQuery +=                                                                             " AND CTO.D_E_L_E_T_ = ' ')"
		cQuery +=                                    " INNER JOIN " + RetSqlName("RD0") + " RD0 ON (RD0.RD0_CODIGO = NXA.NXA_CPART"
		cQuery +=                                                                             " AND RD0.D_E_L_E_T_ = ' ')"
		cQuery += " WHERE NXA.NXA_CPART = ?"
		cQuery +=   " AND OHH.OHH_ANOMES = ?"
		cQuery +=   " AND OHH.D_E_L_E_T_ = ' '"
		cQuery += " GROUP BY OHH.OHH_CESCR, "
		cQuery +=          " OHH.OHH_CFATUR,"
		cQuery +=          " NXA.NXA_DTEMI, "
		cQuery +=          " NXA.NXA_CMOEDA,"
		cQuery +=          " CTO.CTO_DESC,"
		cQuery +=          " NXA.NXA_VLFATH,"
		cQuery +=          " NXA.NXA_VLFATD,"
		cQuery +=          " NS7.NS7_NOME,"
		cQuery +=          " NXA.NXA_CPART,"
		cQuery +=          " RD0.RD0_SIGLA,"
		cQuery +=          " RD0.RD0_NOME"
	EndIf

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,{ Self:codPart, cAnoMes }), cAlias, .T., .F. )

	lHasReg := !( cAlias )->(Eof())
	
	oResponse['items']   := {}
	oResponse['hasNext'] := .F.

	If (lTotal)
		oResponse['total'] := (cAlias)->QtdTotal
	Else
		While !( cAlias )->(Eof())
			Aadd(oResponse['items'], JsonObject():New())
			aTail(oResponse['items'])['codigo']            := (cAlias)->OHH_CFATUR
			aTail(oResponse['items'])['quantTitulos']      := (cAlias)->QtdTitRec
			aTail(oResponse['items'])['dataEmissao']       := (cAlias)->NXA_DTEMI
			aTail(oResponse['items'])['codMoeda']          := (cAlias)->NXA_CMOEDA
			aTail(oResponse['items'])['descMoeda']         := JConvUTF8((cAlias)->CTO_DESC)
			aTail(oResponse['items'])['valorHonorario']    := (cAlias)->NXA_VLFATH
			aTail(oResponse['items'])['valorDespesa']      := (cAlias)->NXA_VLFATD
			aTail(oResponse['items'])['codEscritorio']     := (cAlias)->OHH_CESCR
			aTail(oResponse['items'])['nomeEscritorio']    := JConvUTF8((cAlias)->NS7_NOME)
			aTail(oResponse['items'])['codParticipante']   := (cAlias)->NXA_CPART
			aTail(oResponse['items'])['siglaParticipante'] := (cAlias)->RD0_SIGLA
			aTail(oResponse['items'])['nomeParticipante']  := JConvUTF8((cAlias)->RD0_NOME)
			aTail(oResponse['items'])['saldoFatura']       := (cAlias)->OHH_SALDO
			(cAlias)->( dbSkip() )
		End	
	EndIf

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(oResponse:toJson())
	
	oResponse:fromJson("{}")
	oResponse := NIL
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT altRevisor
Realiza a alteração em Lote do Revisor

@example PUT -> http://127.0.0.1:9090/rest/WSPFSAltLote/{entidade}/{codPart}

body
{
	"chave": "X2_UNICO (NX0)",
	"campoAlterado: ["revisor", "socio", "multiplo"],
	"participanteDestino": "RD0_CODIGO",
	"multiplos": [
		{
			"id": 0,
			"chave": "X2_UNICO (OHN)",
			"participanteDestino": "RD0_CODIGO"
		},
		{
			"id": 1,
			"chave": "X2_UNICO (OHN)",
			"participanteDestino": "RD0_CODIGO"
		}
	]
}

@author Willian Kazahaya
@since 20/04/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altPreFatura PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .F.
Local lMultRev   := SuperGetMV("MV_JMULTRV",, .F.)
Local cPartOri   := Decode64(Self:codPart) 
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cBody      := Self:GetContent()
Local cPreFatChv := ""
Local cCasoChv   := ""
Local cNewRd0Cod := ""
Local nIndJsCaso := 0
Local nC         := 0
Local nI         := 0
Local nX         := 0
Local lAltRevis  := .F.
Local lAltMltRev := .F.
Local lAltSocio  := .F.
Local aCmpAltera := {}
Local aBdCasoRev := {}
Local aBdMultRev := {}
Local aLote      := {}
Local oModel     := Nil
Local oModelNX8  := Nil
Local oModelNX1  := Nil
Local oModelOHN  := Nil

	oBody:fromJson(cBody)
	cPreFatChv := Decode64(oBody['chave'])
	aCmpAltera := oBody['campoAlterado']

	lAltSocio  := aScan(aCmpAltera, 'socio' ) > 0
	lAltRevis  := aScan(aCmpAltera, 'revisor' ) > 0
	lAltMltRev := aScan(aCmpAltera, 'multiplo') > 0

	DbSelectArea("NX0")
	NX0->( DbSetOrder(1) ) // NX0_FILIAL+NX0_COD+NX0_SITUAC

	If NX0->( DbSeek(cPreFatChv) )
		oModel := FWLoadModel("JURA202")
		oModel:SetOperation(4)
		oModel:Activate()

		If (lAltSocio)
			cNewRd0Cod := oBody['socio']['codigo']
			If (oModel:GetValue("NX0MASTER", "NX0_CPART") == cPartOri)
				lRet := oModel:SetValue("NX0MASTER","NX0_CPART", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0031) //"Erro na atualização do Participante Sócio!"
			EndIf
		EndIf

		If (lAltRevis .Or. lMultRev)
			If (lAltRevis)
				aBdCasoRev := oBody['casos']
			EndIf

			If (lMultRev)
				aBdMultRev := oBody['multiplos']
			EndIf
			
			oModelNX8 := oModel:GetModel("NX8DETAIL")
			For nC := 1 to oModelNX8:Length()
				cChaveContr :=  oModelNX8:GetValue( "NX8_FILIAL", nC ) + ;
								oModelNX8:GetValue( "NX8_CPREFT", nC ) + ;
								oModelNX8:GetValue( "NX8_CCONTR", nC ) 
				oModelNX8:GoLine(nC)
				aLote := PFCntDados(cChaveContr, aBdCasoRev, aBdMultRev)
				
				oModelNX1 := oModel:GetModel("NX1DETAIL")
				For nI := 1 to oModelNX1:Length()
					oModelNX1:GoLine(nI)
					cCasoChv := oModelNX1:GetValue( "NX1_FILIAL", nI ) + ;
								oModelNX1:GetValue( "NX1_CPREFT", nI ) + ;
								oModelNX1:GetValue( "NX1_CCONTR", nI ) + ;
								oModelNX1:GetValue( "NX1_CJCONT", nI ) + ;
								oModelNX1:GetValue( "NX1_CCLIEN", nI ) + ;
								oModelNX1:GetValue( "NX1_CLOJA", nI ) + ;
								oModelNX1:GetValue( "NX1_CCASO", nI ) 

					nIndJsCaso := aScan(aLote[1], {|x| Decode64(x['chave']) == cCasoChv })
					If (nIndJsCaso > 0 .And. lAltRevis)
						If (oModelNX1:GetValue("NX1_CPART", nI) == cPartOri)
							lRet := oModelNX1:SetValue("NX1_CPART", aLote[1][nIndJsCaso]['participante'])
						EndIf

						If (!lRet)
							lRet := JRestError(400, STR0014) //"Erro na atualização do Participante Revisor!"
						EndIf
					EndIf

					If Len(aLote[2]) > 0
						// Realizar a troca dos Multiplos revisores
						oModelOHN := oModel:GetModel("OHNDETAIL")
						If (lRet .And. (lMultRev .And. lAltMltRev .And. oModelOHN:Length() > 0))
							For nX := 1 To Len(aLote[2])
								lRet := AltMltRevMdl(oModelOHN, aLote[2][nX], cPartOri)

								If !lRet
									Exit
								EndIf
							Next nX
						EndIf
					EndIf
				Next nI
			Next nC
		EndIf

		// Roda os Valids e Commits
		If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
			lRet := JRestError(500, JMdlError(oModel))
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
	Else
		lRet := JRestError(400, STR0013) //"A pré-fatura não foi localizada. Favor verificar!"
	EndIf
	
	If (lRet)
		oResponse['codigo']  := cPreFatChv
		oResponse['message'] := STR0016    //"Pré-fatura atualizada com sucesso!"
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JWSIsAltLote
Retorna se é a Rotina de Alteração em Lote

@author Willian Kazahaya
@since 09/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWSIsAltLote()
Return _JWSAltLote

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT altContrato
Realiza a alteração em Lote do sócio responsável do contrato

@param codPart - Código do participante
@example PUT -> http://127.0.0.1:9090/rest/WSPFSAltLote/{entidade}/{codPart}

body
{
	"chave": "X2_UNICO (NT0)",
	"campoAlterado: ["socio"],
	"participanteDestino": "RD0_CODIGO",
	"socio": {
		"codigo": "003584"
	}
	"multiplos": []
}

@author Rebeca Facchinato Asunção
@since 18/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altContrato PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .F.
Local oModel     := Nil
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cPartOri   := Decode64(Self:codPart)
Local cBody      := Self:GetContent()
Local cChave     := ""
Local cNewRd0Cod := ""

	oBody:fromJson(cBody)
	cChave := Decode64(oBody['chave'])

	DbSelectArea("NT0")
	NT0->( DbSetOrder(1) )  // NT0_FILIAL + NT0_COD
	
	If NT0->(DbSeek( cChave ))
		oModel := FWLoadModel("JURA096")
		oModel:SetOperation(4)
		oModel:Activate()

		cNewRd0Cod := oBody['socio']['codigo']
		If !Empty(cNewRd0Cod)
			If (oModel:GetValue("NT0MASTER", "NT0_CPART1") == cPartOri) .AND. !(cNewRd0Cod == cPartOri)
				lRet := oModel:SetValue("NT0MASTER","NT0_CPART1", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0019) // "Erro na atualização do Participante sócio responsável!"
			EndIf

			If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
				lRet := JRestError(500, JMdlError(oModel))
			EndIf

			oModel:DeActivate()
			oModel:Destroy()
		Else
			lRet := JRestError(400, STR0021) // "Participante destino não encontrado!"
		EndIf
	Else
		lRet := JRestError(400, STR0022) // "O contrato não foi localizado. Favor verificar!"
	EndIf

	If (lRet)
		oResponse['codigo']  := cChave
		oResponse['message'] := STR0023    // "Contrato atualizado com sucesso!"
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET socRevList
Busca a lista de sócios / revisores, de acordo com a entidade selecionada

@param searchKey  - Código da natureza

@author Rebeca Facchinato Asunção
@since 19/05/2023
@version 1.0
http://localhost:12173/rest/WSPFSAltLote/listSociosRev/{entidade}
/*/
//-------------------------------------------------------------------
WSMETHOD GET socRevList PATHPARAM entidade QUERYPARAM searchKey, socioRevisor WSREST WSPFSAltLote

Local cAlias     := GetNextAlias()
Local oResponse  := JSonObject():New()
Local cEntidade  := self:entidade
Local cSearchKey := Self:searchKey
Local cQuery     := ""
Local nI         := 0
Local aDadosQry  := {}
Local aParams    := {}

Default cEntidade  := ""
Default cSearchKey := ""

	Self:SetContentType("application/json")
	oResponse['items'] := {}

	aDadosQry := aClone(JWSALPart(cSearchKey, cEntidade))
	aParams   := { xFilial("RD0"), xFilial("NUR") }
	if !empty(aDadosQry[2])
		aAdd(aParams, "%" + aDadosQry[2] + "%")
	EndIf
	cQuery    := aDadosQry[1]
	cQuery    := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TCGenQry2(NIL,NIL,cQuery,aParams), cAlias, .T., .F. )

	While !(cAlias)->(Eof())
		nI++
		aAdd(oResponse['items'], JsonObject():New())
		aTail(oResponse['items'])['codigo']  := (cAlias)->RD0_CODIGO
		aTail(oResponse['items'])['nome']    := JConvUTF8((cAlias)->RD0_NOME)
		aTail(oResponse['items'])['sigla']   := JConvUTF8((cAlias)->RD0_SIGLA)
		aTail(oResponse['items'])['socio']   := (cAlias)->NUR_SOCIO == '1'
		aTail(oResponse['items'])['revisor'] := (cAlias)->NUR_REVFAT == '1'

		If(nI == 30)
			Exit
		EndIf

		(cAlias)->( dbSkip() )
	EndDo

	(cAlias)->( dbCloseArea() )

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	aSize(aDadosQry, 0)
	aSize(aParams, 0)
	aDadosQry := Nil
	aParams   := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JWSALPart
Monta a query de busca de participantes de acordo com o tipo Sócios / Revisores

@param  searchKey  - valor a ser pesquisado (código / nome / sigla)
@param cEntidade   - Indica a entidade que que busca a lista de participantes
@return Array
		Array[1] - cQuery - Query para busca de participantes
		Array[2] - cSearchKey - Termo utilizado no filtro de busca

@author Rebeca Facchinato Asunção
@since 23/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Function JWSALPart( cSearchKey, cEntidade )
Local cQuery := ""
Local cCampo := "RD0_NOME || RD0_SIGLA || RD0_CODIGO"

Default cSearchKey := ""
Default cEntidade  := ""

	cQuery := " SELECT RD0.RD0_SIGLA"
	cQuery +=       " ,RD0.RD0_CODIGO"
	cQuery +=       " ,RD0.RD0_NOME"
	cQuery +=       " ,RD0.R_E_C_N_O_ RD0RECNO"
	cQuery +=       " ,NUR.NUR_SOCIO"
	cQuery +=       " ,NUR.NUR_REVFAT"
	cQuery +=  " FROM " + RetSqlName("RD0") + " RD0"
	cQuery += " INNER JOIN " + RetSqlName("NUR") + " NUR"
	cQuery +=    " ON (NUR.NUR_CPART = RD0.RD0_CODIGO"
	cQuery +=   " AND NUR.D_E_L_E_T_ = ' ')"
	cQuery += " WHERE RD0.D_E_L_E_T_ = ' '"
	cQuery +=   " AND RD0.RD0_MSBLQL = '2'" // Bloqueado? 2=Não
	cQuery +=   " AND RD0.RD0_TPJUR  = '1'" // Participante jurídico? 1=Sim
	cQuery +=   " AND RD0.RD0_FILIAL = ?"
	cQuery +=   " AND NUR.NUR_FILIAL = ?"
	
	If (cEntidade == "All" .OR. cEntidade == "PREFATURAS" .OR. cEntidade == "CASOS")
		cQuery += " AND (NUR.NUR_SOCIO = '1' OR  NUR.NUR_REVFAT = '1')"
	Else  // Contrato, Cliente e Juncao
		cQuery += " AND NUR.NUR_SOCIO = '1'"
	EndIf
	
	If !Empty(cSearchKey)
		If ValType(DecodeUTF8(cSearchKey)) <> "U"
			cSearchKey := DecodeUTF8(cSearchKey)
		EndIf

		cSearchKey := JurClearStr(cSearchKey, .T., .T.,.F., .T.)
		cCampo     := JurClearStr("RD0_NOME || RD0_SIGLA || RD0_CODIGO", .T., .T. , .T., .T.)
		cQuery     += " AND " + cCampo + " LIKE ?"
	EndIf
	cQuery += " ORDER BY RD0.RD0_NOME"
Return { cQuery, cSearchKey }

//-------------------------------------------------------------------
/*/{Protheus.doc} JMdlError(oModel)
Centraliza o retorno dos erros de Modelo

@param  oModel - Modelo que deu erro
@return cMsgError - Mensagem de erro

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JMdlError(oModel)
Local cMsgError := ""
	cMsgError := STR0024 + CRLF  // "Erro: "

	If !Empty(oModel:aErrorMessage[4])
		cMsgError += STR0025 + oModel:aErrorMessage[4] + CRLF  // "Campo: "
	EndIf

	If !Empty(oModel:aErrorMessage[5])
		cMsgError += STR0026 + oModel:aErrorMessage[5] + CRLF  // "Razao: "
	EndIf

	cMsgError += oModel:aErrorMessage[6] + CRLF   // Mensagem
Return cMsgError

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT altJuncoes
Realiza a alteração em Lote do sócio responsável da junção de contratos

@param codPart - Código do participante
@example PUT -> http://127.0.0.1:9090/rest/WSPFSAltLote/revisor/{entidade}/{codPart}

body
{
	"chave": "X2_UNICO (NW2)",
	"campoAlterado: ["socio"],
	"participanteDestino": "RD0_CODIGO",
	"socio": {
		"codigo": "003584"
	}
	"multiplos": []
}

@author Rebeca Facchinato Asunção
@since 31/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altJuncoes PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .F.
Local oModel     := Nil
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cPartOri   := Decode64(Self:codPart)
Local cBody      := Self:GetContent()
Local cChave     := ""
Local cNewRd0Cod := ""

	oBody:fromJson(cBody)
	cChave := Decode64(oBody['chave'])

	DbSelectArea("NW2")
	NW2->( DbSetOrder(1) )  // NW2_FILIAL + NW2_COD
	
	If NW2->(DbSeek( cChave ))
		oModel := FWLoadModel("JURA056")
		oModel:SetOperation(4)
		oModel:Activate()

		cNewRd0Cod := oBody['socio']['codigo']
		If !Empty(cNewRd0Cod)
			If (oModel:GetValue("NW2MASTER", "NW2_CPART") == cPartOri) .AND. !(cNewRd0Cod == cPartOri)
				lRet := oModel:SetValue("NW2MASTER","NW2_CPART", cNewRd0Cod)
				lRet := lRet .AND. oModel:SetValue("NW2MASTER","NW2_SIGLA", oBody['socio']['sigla'])
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0019) // "Erro na atualização do Participante sócio responsável!"
			EndIf

			If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
				lRet := JRestError(500, JMdlError(oModel))
			EndIf

			oModel:DeActivate()
			oModel:Destroy()

		Else
			lRet := JRestError(400, STR0021) // "Participante destino não encontrado!"
		EndIf

	Else
		lRet := JRestError(400, STR0028) // "A junção de contratos não foi localizada. Favor verificar!"
	EndIf

	If (lRet)
		oResponse['codigo']  := cChave
		oResponse['message'] := STR0029    // "Junção de contratos atualizada com sucesso!"
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} cQryMltPart(cEntida)
Gera a query dos Multiplos participantes

@param  cEntida - Entidade da query
@return cQuery  - Query a ser rodada

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function cQryMltPart(cEntida)
Local cQuery  := ""

	cQuery += "  SELECT RD0MULTI.RD0_NOME"
	cQuery +=        " ,RD0MULTI.RD0_CODIGO"
	cQuery +=        " ,RD0MULTI.RD0_SIGLA"
	cQuery +=        " ,OHN.OHN_FILIAL"
	cQuery +=        " ,OHN.OHN_CPREFT"
	cQuery +=        " ,OHN.OHN_CCONTR"
	cQuery +=        " ,OHN.OHN_CCLIEN"
	cQuery +=        " ,OHN.OHN_CLOJA"
	cQuery +=        " ,OHN.OHN_CCASO"
	cQuery +=        " ,OHN.OHN_CPART"
	cQuery +=        " ,OHN.OHN_REVISA"
	cQuery +=   " FROM " + RetSqlName( "OHN" ) + " OHN"
	cQuery +=  " INNER JOIN " + RetSqlName( "RD0" ) + " RD0MULTI"
	cQuery +=     " ON OHN.OHN_CPART = RD0MULTI.RD0_CODIGO"
	cQuery +=  " WHERE OHN.D_E_L_E_T_ = ' '"

	If (cEntida == "PREFATURA")
		cQuery +=    " AND OHN.OHN_CPREFT = ?"
	ElseIf (cEntida == "CASO")
		cQuery +=    " AND OHN.OHN_CPREFT = ' '"
		cQuery +=    " AND OHN.OHN_CCLIEN = ?"
		cQuery +=    " AND OHN.OHN_CLOJA = ?"
		cQuery +=    " AND OHN.OHN_CCASO = ?"
	EndIf
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} cQryMltPart(cEntida)
Gera a query dos Multiplos participantes

@param  cEntida - Entidade da query
@return cQuery  - Query a ser rodada

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altCaso PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .T.
Local lMultRev   := SuperGetMV("MV_JMULTRV",, .F.)
Local cPartOri   := Decode64(Self:codPart)
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cBody      := Self:GetContent()
Local cChvCaso   := ""
Local cNewRd0Cod := ""
Local nI         := 0
Local lAltRevis  := .F.
Local lAltMltRev := .F.
Local lAltSocio  := .F.
Local aCmpAltera := {}
Local oModel     := Nil

	oBody:fromJson(cBody)
	cChvCaso   := Decode64(oBody['chave'])
	aCmpAltera := oBody['campoAlterado']

	lAltRevis  := aScan(aCmpAltera, 'revisor' ) > 0
	lAltSocio  := aScan(aCmpAltera, 'socio'   ) > 0
	lAltMltRev := aScan(aCmpAltera, 'multiplo') > 0

	DbSelectArea("NVE")
	NVE->( DbSetOrder(1) )  // NVE_FILIAL + NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS + NVE_SITUAC

	If NVE->( DbSeek(cChvCaso) )
		oModel := FWLoadModel("JURA070")
		oModel:SetOperation(4)
		oModel:Activate()

		If lAltSocio
			cNewRd0Cod := oBody['socio']['codigo']
			If (oModel:GetValue("NVEMASTER", "NVE_CPART5") == cPartOri)
				lRet := oModel:SetValue("NVEMASTER","NVE_CPART5", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0031) //"Erro na atualização do Participante Sócio!"
			EndIf
		EndIf

		If lRet .AND. lAltRevis
			cNewRd0Cod := oBody['revisor']['codigo']
			If (oModel:GetValue("NVEMASTER", "NVE_CPART1") == cPartOri)
				lRet := oModel:SetValue("NVEMASTER","NVE_CPART1", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0014) //"Erro na atualização do Participante Revisor!"
			EndIf
		EndIf

		If lRet .AND. (lMultRev .And. lAltMltRev)
			aBdMultRev := oBody['multiplos']

			For nI := 1 To Len(aBdMultRev)
				lRet := AltMltRevMdl(oModel:GetModel("OHNDETAIL"), aBdMultRev[nI], cPartOri)

				If !lRet
					Exit
				EndIf
			Next nI
		EndIf
		
		// Roda os Valids e Commits
		If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
			lRet := JRestError(500, JMdlError(oModel))
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
	Else
		lRet := JRestError(400, STR0032) //"O caso não foi localizado. Favor verificar!"
	EndIf

	If (lRet)
		oResponse['codigo']  := cChvCaso
		oResponse['message'] := STR0033 // "Caso atualizado com sucesso!"
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AltMltRevMdl(oModelOHN, oItemRev, cPartOri)
Gera a query dos Multiplos participantes

@param oModelOHN - Modelo do grid de múltiplos
@param oItemRev  - Linha posicionada do grid de múltiplos
@param cPartOri  - Partipante origem
@return lRet     - 	Indica se atualizou os múltiplos com sucesso!

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AltMltRevMdl(oModelOHN, oItemRev, cPartOri)
Local lRet       := .T.
Local nIndLoc    := 0
Local nX         := 0
Local cChvMdlOHN := ""

	// Somente procura quando houve atualização ou exclusão
	If (oItemRev['deleted'] .Or. oItemRev['updated'] ) 
		For nX := 1 To oModelOHN:Length()
			If !oModelOHN:IsDeleted(nX)
				cChvMdlOHN := oModelOHN:GetValue("OHN_FILIAL",nX) + ;
								oModelOHN:GetValue("OHN_CPREFT",nX) + ;
								oModelOHN:GetValue("OHN_CCONTR",nX) + ;
								oModelOHN:GetValue("OHN_CCLIEN",nX) + ;
								oModelOHN:GetValue("OHN_CLOJA",nX)  + ;
								oModelOHN:GetValue("OHN_CCASO",nX)  + ;
								oModelOHN:GetValue("OHN_CPART",nX)  + ;
								oModelOHN:GetValue("OHN_REVISA",nX)

				// Verifica se a chave foi bate com a chave do JSON
				If (Decode64(oItemRev['chave']) == cChvMdlOHN)
					nIndLoc := nX
					Exit
				EndIf
			EndIf
		Next nX

		// OHN_FILIAL + OHN_CPREFT + OHN_CCONTR + OHN_CCLIEN + OHN_CLOJA + OHN_CCASO + OHN_CPART + OHN_REVISA
		If nIndLoc > 0
			oModelOHN:GoLine(nIndLoc)
			If (oItemRev['deleted'])
				lRet := oModelOHN:DeleteLine()
			ElseIf (oItemRev['updated'])
				If (cPartOri == oModelOHN:GetValue("OHN_CPART", nIndLoc))
					lRet := oModelOHN:SetValue("OHN_CPART", oItemRev['participante'])
				EndIf
			EndIf

			If !(lRet)
				lRet := JRestError(500, STR0015) //"Erro na atualização do Responsável Multiplo!"
			EndIf
		EndIf
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT altCliente
Realiza a alteração em Lote do sócio responsável do Cliente

@param codPart - Código do participante
@example PUT -> http://127.0.0.1:9090/rest/WSPFSAltLote/revisor/{entidade}/{codPart}

body
{
	"chave": "X2_UNICO (NW2)",
	"campoAlterado: ["socio"],
	"participanteDestino": "RD0_CODIGO",
	"socio": {
		"codigo": "003584"
	}
	"multiplos": []
}

@author Willian Kazahaya
@since 15/06/2023
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT altCliente PATHPARAM codPart WSREST WSPFSAltLote
Local lRet       := .F.
Local oModel     := Nil
Local oResponse  := JSonObject():New()
Local oBody      := JSonObject():New()
Local cPartOri   := Decode64(Self:codPart)
Local cBody      := Self:GetContent()
Local cChvCliente:= ""
Local cNewRd0Cod := ""

	oBody:fromJson(cBody)
	cChvCliente := Decode64(oBody['chave'])
	aCmpAltera  := oBody['campoAlterado']

	lAltSocio  := aScan( aCmpAltera, 'socio' ) > 0

	DbSelectArea("SA1")
	SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA

	If SA1->( DbSeek(cChvCliente) )
		oModel := FWLoadModel("JURA148")
		oModel:SetOperation(4)
		oModel:Activate()

		If lAltSocio
			cNewRd0Cod := oBody['socio']['codigo']
			If (oModel:GetValue("NUHMASTER", "NUH_CPART") == cPartOri)
				lRet := oModel:SetValue("NUHMASTER","NUH_CPART", cNewRd0Cod)
			EndIf

			If (!lRet)
				lRet := JRestError(400, STR0031) //"Erro na atualização do Participante Sócio!"
			EndIf
		EndIf

		// Roda os Valids e Commits
		If lRet .And. (!( oModel:VldData() ) .Or. !( oModel:CommitData() ))
			lRet := JRestError(500, JMdlError(oModel))
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
	Else
		lRet := JRestError(400, STR0036) //"O caso não foi localizado. Favor verificar!"
	EndIf
	
	If (lRet)
		oResponse['codigo']  := cChvCliente
		oResponse['message'] := STR0035 // "Caso atualizado com sucesso!"
		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PFCntDados(cChaveContr, aBdCasoRev, aBdMultRev)
Retorna os Dados de Caso e Revisores do Contrato posicionado

@param cChaveContr - Chave do Contrato a Posicionar
@param aBdCasoRev  - Array de Casos vindo da Alteração em Lote
@param aBdMultRev  - Array de Multiplos Revisores da Alteração em Lote
@return [1] - Dados do Caso encontrado
        [2] - Dados dos Multiplos Revisores

@author Willian Kazahaya
@since 25/05/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PFCntDados(cChaveContr, aBdCasoRev, aBdMultRev)
Local nC          := 0
Local nM          := 0
Local nTamChvCnt  := 0
Local aRet        := {}
Local aMultRevCnt := {}

Default cChaveContr := ""
Default aBdCasoRev  := {}
Default aBdMultRev  := {}

	//NX8_FILIAL+NX8_CPREFT+NX8_CCONTR
	nTamChvCnt := TamSX3("NX8_FILIAL")[1] + TamSX3("NX8_CPREFT")[1] + TamSX3("NX8_CCONTR")[1]

	For nC := 1 To Len(aBdCasoRev)
		If (cChaveContr == SubStr(Decode64(aBdCasoRev[nC]['chave']),1, nTamChvCnt))
			aAdd(aRet, aBdCasoRev[nC])
		EndIf
	Next nC

	For nM := 1 To Len(aBdMultRev)
		If (cChaveContr == SubStr(Decode64(aBdMultRev[nM]['chave']),1, nTamChvCnt))
			aAdd(aMultRevCnt, aBdMultRev[nM])
		EndIf
	Next nM 
Return { aRet, aMultRevCnt }


//-------------------------------------------------------------------
/*/{Protheus.doc} SetPagSize(nPage, nPageSize)
Calcula a Paginação

@param nPage - Numero da pagina
@param nPageSize - Quantidade de registros por pagina

@returns [1] - Indica se haverá filtro ou não
		 [2] - Indice do registro inicial
		 [3] - Indice do registro final

@author Willian Kazahaya
@since 13/03/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SetPagSize(nPage, nPageSize)
Local lFiltraPag := (nPageSize != Nil .And. nPage != Nil)
Local nRegMin    := 0
Local nRegMax    := 0

	If (lFiltraPag)
		nRegMax := Val(nPage) * Val(nPageSize)
		nRegMin := (Val(nPage)-1) * Val(nPageSize)
	EndIf
Return { lFiltraPag, nRegMin, nRegMax }
