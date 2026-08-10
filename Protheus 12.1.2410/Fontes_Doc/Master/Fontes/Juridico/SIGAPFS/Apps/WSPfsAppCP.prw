#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "WSPFSAPPCP.CH"

Static aCstFldsSE2 := {}

WSRESTFUL WSPfsAppCP DESCRIPTION STR0001 //"Webservice App PFS - Contas a pagar"
	WSDATA recnoTitulo  AS STRING
	WSDATA ChaveBordero AS STRING
	WSDATA filtLeg      AS STRING
	WSDATA codEntidade  AS STRING
	WSDATA cEntidade    AS STRING
	WSDATA codFields    AS STRING
	WSDATA desFields    AS STRING
	WSDATA extFields    AS STRING
	WSDATA valorDig     AS STRING
	WSDATA filtRelSA2   AS STRING
	WSDATA searchKey    AS STRING
	WSDATA chaveTab     AS STRING
	WSDATA codParam     AS STRING
	WSDATA valorCod     AS STRING
	WSDATA valorLoja    AS STRING
	WSDATA codForn      AS STRING
	WSDATA codBanco     AS STRING
	WSDATA codItem      AS STRING
	WSDATA filtFilial   AS STRING
	WSDATA natCod       AS STRING
	WSDATA filtCCJuri   AS STRING
	WSDATA cCodTitulo   AS STRING
	WSDATA codOperacao  AS NUMBER
	WSDATA pageSize     AS NUMBER
	WSDATA page         AS NUMBER
	WSDATA lFiltroAdc   AS BOOLEAN
	WSDATA chaveCli     AS STRING
	WSDATA cobravel     AS STRING
	WSDATA tipo         AS STRING
	WSDATA qtdTotal     AS BOOLEAN
	WSDATA uf           AS STRING
	WSDATA TENANTID     AS STRING
	
	// Métodos GET
	WSMETHOD GET gtPrBaixAut         DESCRIPTION STR0002 PATH "param/baixaAut"                 PRODUCES APPLICATION_JSON // "Busca de parâmetros para Baixa Automática"
	WSMETHOD GET cmpFiltro           DESCRIPTION STR0003 PATH "filcmp"                         PRODUCES APPLICATION_JSON // "Busca os campos para filtro"
	WSMETHOD GET FornTitulo          DESCRIPTION STR0004 PATH "forntitpag"                     PRODUCES APPLICATION_JSON // "Busca os fornecedores que estão nos titulos"
	WSMETHOD GET TabGenerica         DESCRIPTION STR0005 PATH "congen/sx5/{codEntidade}"       PRODUCES APPLICATION_JSON // "Busca nas tabelas genéricas (SX5)"
	WSMETHOD GET ConGenerica         DESCRIPTION STR0006 PATH "congen/tab/{codEntidade}"       PRODUCES APPLICATION_JSON // "Consulta genérica de tabelas"
	WSMETHOD GET SysParam            DESCRIPTION STR0068 PATH "sysParam/{codParam}"            PRODUCES APPLICATION_JSON // "Consulta de Parâmetros do sistema"
	WSMETHOD GET CasClJur            DESCRIPTION STR0071 PATH "congen/cas"                     PRODUCES APPLICATION_JSON // "Consulta de Caso do cliente"
	WSMETHOD GET ForBco              DESCRIPTION STR0073 PATH "confor/{codForn}/bco"           PRODUCES APPLICATION_JSON // "Busca o banco do Fornecedor"
	WSMETHOD GET CmpHabilitado       DESCRIPTION STR0075 PATH "titpagcmp/{recnoTitulo}"        PRODUCES APPLICATION_JSON // "Campos habilitados do Contas a Pagar"
	WSMETHOD GET gtAnexos            DESCRIPTION STR0076 PATH "anexos/{recnoTitulo}"           PRODUCES APPLICATION_JSON // "Busca os anexos"
	WSMETHOD GET listPrefixos        DESCRIPTION STR0088 PATH "listPrefixos"                   PRODUCES APPLICATION_JSON // "Busca a lista de prefixos cadastrados"
	WSMETHOD GET getMotBaixa         DESCRIPTION STR0089 PATH "getMotBaixa"                    PRODUCES APPLICATION_JSON // "Busca a lista de motivos de baixa"
	WSMETHOD GET getNatureza         DESCRIPTION STR0091 PATH "getNatureza"                    PRODUCES APPLICATION_JSON // "Busca a lista de naturezas"
	WSMETHOD GET getTituPag          DESCRIPTION STR0092 PATH "getTituPag"                     PRODUCES APPLICATION_JSON // "Busca títulos a pagar"
	WSMETHOD GET bcoCNAB             DESCRIPTION STR0100 PATH "bcoCNAB"                        PRODUCES APPLICATION_JSON // "Busca bancos de acordo com parametro de bancos para CNAB (SEE)"

	// Métodos PUT
	WSMETHOD PUT DadosTit            DESCRIPTION STR0007 PATH "titpag"                         PRODUCES APPLICATION_JSON // "Busca os dados dos Titulos do Pagar"
	WSMETHOD PUT ConTotTit           DESCRIPTION STR0070 PATH "titpagcon/totalizadores"        PRODUCES APPLICATION_JSON // "Busca os totalizadores da Consulta de titulos"
	WSMETHOD PUT SubTitPag           DESCRIPTION STR0008 PATH "subtitpag"                      PRODUCES APPLICATION_JSON // "Substituir o Titulo do Pagar"
	WSMETHOD PUT AltTitPag           DESCRIPTION STR0009 PATH "titpag/{recnoTitulo}"           PRODUCES APPLICATION_JSON // "Alterar o Titulo do Pagar"
	WSMETHOD PUT MSysParam           DESCRIPTION STR0072 PATH "sysParam/multi"                 PRODUCES APPLICATION_JSON // "Busca multipla de parâmetros"
	WSMETHOD PUT VldPIX              DESCRIPTION STR0077 PATH "pix"                            PRODUCES APPLICATION_JSON // "Valida o QRCode PIX"
	WSMETHOD PUT VldLnDigitavel      DESCRIPTION STR0082 PATH "lnDigitavel"                    PRODUCES APPLICATION_JSON // "Valida a linha digitavel do Contas a Pagar"

	WSMETHOD PUT ConDesdobramento    DESCRIPTION STR0079 PATH "desdobramento"                  PRODUCES APPLICATION_JSON // "Busca os dados de Consulta dos Desdobramentos"
	WSMETHOD PUT TotDesdobramento    DESCRIPTION STR0080 PATH "desdobramento/totalizadores"    PRODUCES APPLICATION_JSON // "Busca os dados de Consulta dos Desdobramentos"

	// Métodos POST
	WSMETHOD POST CrtTitPag          DESCRIPTION STR0014 PATH "titpag"                         PRODUCES APPLICATION_JSON // "Criação de titulo do Pagar"
	WSMETHOD POST LiberaManu         DESCRIPTION STR0015 PATH "libpagmanual"                   PRODUCES APPLICATION_JSON // "Liberação Manual de Pagamento"
	WSMETHOD POST ChqSTitulo         DESCRIPTION STR0016 PATH "chequesemtitulo/{recnoTitulo}"  PRODUCES APPLICATION_JSON // "Cheque sem titulo"
	WSMETHOD POST BxAutTit           DESCRIPTION STR0017 PATH "titautbai"                      PRODUCES APPLICATION_JSON // "Baixa de Titulo Automatico"
	WSMETHOD POST PrBaixAut          DESCRIPTION STR0018 PATH "param/baixaAut"                 PRODUCES APPLICATION_JSON // "Alteração de Parâmetros para Baixa do Pagar"
	WSMETHOD POST BaixaTitulo        DESCRIPTION STR0010 PATH "titbai/{recnoTitulo}"           PRODUCES APPLICATION_JSON // "Baixa Manual de Titulo do Pagar"
	WSMETHOD POST BancFornec         DESCRIPTION STR0092 PATH "bancofornecedor/{codForn}"      PRODUCES APPLICATION_JSON // "Cadastra o banco do Fornecedor"
	WSMETHOD POST ExpCNAB            DESCRIPTION STR0095 PATH "expcnab"                        PRODUCES APPLICATION_JSON // "Emite os borderôs e gera o arquivo CNAB"
	WSMETHOD POST RetCNAB            DESCRIPTION STR0098 PATH "retcnab"                        PRODUCES APPLICATION_JSON // "Processa o retorno do CNAB"

	// Métodos DELETE
	WSMETHOD DELETE Titulo           DESCRIPTION STR0020 PATH "titpag/{recnoTitulo}"           PRODUCES APPLICATION_JSON // "Exclusão de Titulo"
	WSMETHOD DELETE ExcluiBaixa      DESCRIPTION STR0021 PATH "titexc/{recnoTitulo}"           PRODUCES APPLICATION_JSON // "Exclusão de baixa do Pagar"
	WSMETHOD DELETE CancelaBaixa     DESCRIPTION STR0022 PATH "titcan/{recnoTitulo}"           PRODUCES APPLICATION_JSON // "Cancela de baixa do Pagar"
	WSMETHOD DELETE Bordero          DESCRIPTION STR0023 PATH "canbrd/{ChaveBordero}"          PRODUCES APPLICATION_JSON // "Cancelamento de Borderô"
	WSMETHOD DELETE IBordero         DESCRIPTION STR0024 PATH "canbrdimp/{ChaveBordero}"       PRODUCES APPLICATION_JSON // "Cancelamento de Borderô - Imposto"
	WSMETHOD DELETE FatPag           DESCRIPTION STR0025 PATH "canfat/{recnoTitulo}"           PRODUCES APPLICATION_JSON // "Cancelamento de Fatura"
	WSMETHOD DELETE CCompensacao     DESCRIPTION STR0026 PATH "compens/{recnoTitulo}"          PRODUCES APPLICATION_JSON // "Cancelar Compensação"
	WSMETHOD DELETE ECompensacao     DESCRIPTION STR0027 PATH "compens/estornar/{recnoTitulo}" PRODUCES APPLICATION_JSON // "Estornar Compensação"
	WSMETHOD DELETE Cheque           DESCRIPTION STR0028 PATH "cheque/{recnoTitulo}"           PRODUCES APPLICATION_JSON // "Cancelar Cheque"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET FornTitulo
Retorna os parâmetros de Baixa automática

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/forntitpag

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET FornTitulo WSREST WSPfsAppCP
Local oResponse := JSonObject():New()
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local cQryGrp   := ""
Local cQryOrd   := ""
Local cQuery    := ""
Local cAlias    := ""
Local lRet      := .T.
Local nIndexJSon := 0

	cQrySel += " SELECT SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME "
	cQryFrm +=   " FROM " + RetSqlName("SA2") + " SA2 "
	cQryFrm +=  " INNER JOIN " + RetSqlName("SE2") + " SE2 "
	cQryFrm +=     " ON (SA2.A2_COD = SE2.E2_FORNECE  "
	cQryFrm +=    " AND SA2.A2_LOJA = SE2.E2_LOJA) "
	cQryWhr +=  " WHERE SA2.D_E_L_E_T_ = ' ' "
	cQryWhr +=    " AND SE2.D_E_L_E_T_ = ' ' "
	cQryGrp +=  " GROUP BY SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME "
	cQryOrd +=  " ORDER BY SA2.A2_NOME "

	cQuery := ChangeQuery( cQrySel + cQryFrm + cQryWhr + cQryGrp + cQryOrd )

	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	oResponse['fornecedor'] := {}

	While !(cAlias)->(Eof())
		nIndexJSon++
		Aadd(oResponse['fornecedor'], JsonObject():New())
		oResponse['fornecedor'][nIndexJSon]['codigo']   := (cAlias)->A2_COD
		oResponse['fornecedor'][nIndexJSon]['loja']     := (cAlias)->A2_LOJA
		oResponse['fornecedor'][nIndexJSon]['nome']     := (cAlias)->A2_NOME
		(cAlias)->( dbSkip() )
	End

	( cAlias )->( dbCloseArea() )
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SysParam
Busca de Parâmetros da SX6

@author willian.kazahaya
@since 31/07/2020
/*/
//-------------------------------------------------------------------
WSMethod GET SysParam PATHPARAM codParam WSREST WSPfsAppCP
Local oResponse  := JsonObject():New()
Local cCodParam  := AllTrim(Self:codParam)

	If Len(cFilant) < 8
		cFilant := PadR(cFilAnt,8)
	EndIf

	oResponse['sysParam'] := JsonObject():New()

	oResponse['sysParam']['name']  := cCodParam
	oResponse['sysParam']['value'] := SuperGetMv(cCodParam)

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MSysParam
Busca multiplica de parâmetros

@author willian.kazahaya
@since 24/09/2020
/*/
//-------------------------------------------------------------------
WSMethod PUT MSysParam WSREST WSPfsAppCP
Local oResponse  := JsonObject():New()
Local oJsonBody  := JsonObject():new()
Local oJsonSub   := JsonObject():new()
Local cBody      := ""
Local nI         := 0
Local nY         := 0
Local itensJs    := Nil

	cBody := StrTran(Self:GetContent(),CHR(10),"")

	retJson := oJsonBody:fromJson(cBody)
	itensJs := oJsonBody:GetNames()

	For nI := 1 To Len(itensJs)
		oJsonSub := oJsonBody:getJsonObject("params")
		oResponse['sysParam'] := {}

		For nY := 1 to Len(oJsonSub)
			aAdd(oResponse['sysParam'], JsonObject():New())
			oResponse['sysParam'][nY]['name']  := oJsonSub[nY]
			oResponse['sysParam'][nY]['value'] := jGetMV(oJsonSub[nY])
		Next nY
	Next nI

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldPIX
Valida o qrCode PIX

@author willian.kazahaya
@since 03/02/2021
/*/
//-------------------------------------------------------------------
WSMETHOD PUT VldPIX WSREST WSPfsAppCP
Local oBody     := JSonObject():New()
Local oResponse := JSonObject():New()
Local cBody     := ""
Local lRet      := .F.
Local qrCodePix := ""
Local aRetValPIX:= {}
Local itensJson
Local retJSon

	cBody := StrTran(Self:GetContent(), CHR(10),"")

	retJSon   := oBody:fromJson(cBody)
	itensJson := oBody:GetNames()

	qrCodePix := oBody:getJsonObject("qrCode")

	aRetValPIX := FinQRCode(qrCodePix,.F.,.T.)

	oResponse['qrCode'] := qrCodePix

	oResponse['gui'] := aRetValPIX[1]
	oResponse['url'] := aRetValPIX[2]
	oResponse['chave'] := aRetValPIX[3]

	lRet := !Empty(aRetValPIX[3])
	If (lRet)
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		lRet := setRespError(404, STR0078) //"O QRCode informe não é valido. Chave não encontrada!"
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT VldLnDigitavel
Valida o valor da linha digitavel

@example PUT -> http://127.0.0.1:9090/rest/WSPfsAppCP/lnDigitavel
@example Body
	{
	    "valor": "848500000005479901622028012052178866510058111220"
	}

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT VldLnDigitavel WSREST WSPfsAppCP
Local oBody     := JSonObject():New()
Local lRet      := .T.
Local cBody     := ""
Local cLinDigit := ""
Local itensJson := NIL
Local retJSon	:= NIL

	cBody := StrTran(Self:GetContent(), CHR(10),"")
	retJSon   := oBody:fromJson(cBody)
	itensJson := oBody:GetNames()

	cLinDigit := oBody:getJsonObject("valor")

	If !Empty(cLinDigit)
		lRet := VldCodBar(cLinDigit)
	EndIf

	If lRet
		Self:SetResponse('{"message":"' + JConvUTF8(STR0081) + '"}') // "Linha digitavel válida!"
	Else
		lRet := setRespError(404, STR0074) // "Valor da linha digitavel não é valida!"
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET CasClJur
Busca o caso a partir do cliente posicionado

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/congen/cli
@param valorDig    - Optional - Valor digitado no campo
@param valorCod    - Optional - Código do Cliente
@param valorLoja   - Optional - Loja do Cliente
@param codEntidade - Optional - Código do Caso
@param filtFilial  - Optional - Indica se filtra Filial com xFilial

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMethod GET CasClJur QUERYPARAM valorDig, valorCod, valorLoja, codEntidade, filtFilial WSREST WSPfsAppCP
Local oResponse  := JSonObject():New()
Local cAlias     := ""
Local cQuery     := ""
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryOrd    := ""
Local cFilConcat := ""
Local nIndexJSon := 0
Local nI         := 0
Local cSearchKey := Self:valorDig
Local cCodigo    := Self:valorCod
Local cLoja      := Self:valorLoja
Local cIdCaso    := Self:codEntidade
Local lFiltFil   := Self:filtFilial != 'false'
Local aFilFilt   := EmpFilUsu("NVE")

	cQrySel += " SELECT NVE.NVE_NUMCAS, NVE.NVE_TITULO, NVE.NVE_CCLIEN, NVE.NVE_LCLIEN"
	cQryFrm +=   " FROM " + RetSqlName("NVE") + " NVE"
	cQryFrm +=  " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQryFrm +=     " ON (SA1.A1_COD  = NVE.NVE_CCLIEN "
	cQryFrm +=    " AND SA1.A1_LOJA = NVE.NVE_LCLIEN)"
	cQryWhr +=  " WHERE NVE.NVE_SITUAC = '1'
	cQryWhr +=    " AND NVE.D_E_L_E_T_ = ' '"
	cQryWhr +=    " AND SA1.D_E_L_E_T_ = ' '"
	cQryOrd +=  " ORDER BY NVE.NVE_TITULO"

	If (lFiltFil)
		cQryWhr += " AND NVE.NVE_FILIAL = '" + FWxFilial("NVE") + "' "
		cQryWhr += " AND SA1.A1_FILIAL = '" + FWxFilial("SA1") + "'"
	Else
		For nI := 1 To Len(aFilFilt)
			cFilConcat += "'" + aFilFilt[nI] + "',"
		Next nI

		// Inclui as filiais que o usuário tem permissão
		If !Empty(cFilConcat)
			cQryWhr += " AND NVE.NVE_FILIAL IN (" + SubStr(cFilConcat,1, Len(cFilConcat)-1) + ")"
		EndIf
	EndIf

	// Pesquisa por valor digitado
	if !Empty(cSearchKey)
		cSearchKey := Upper(cSearchKey)
		cQryWhr += " AND ( UPPER(NVE_NUMCAS) LIKE '%" + AllTrim(cSearchKey) + "%'"
		cQryWhr +=    " OR UPPER(NVE_TITULO) LIKE '%" + AllTrim(cSearchKey) + "%')"
	EndIf

	// Pesquisa por código
	If !Empty(cCodigo) .And. (cCodigo != "undefined" .OR. cLoja != "undefined")
		cQryWhr += " AND UPPER(NVE_CCLIEN) = '" + cCodigo + "'"
		cQryWhr += " AND UPPER(NVE_LCLIEN) = '" + cLoja + "' "
	EndIf

	If !Empty(cIdCaso)
		cQryWhr += " AND NVE_NUMCAS = '" + cIdCaso + "'"
	EndIf

	// Monta a Query
	cQuery := ChangeQuery( cQrySel + cQryFrm + cQryWhr + cQryOrd )
	cAlias := GetNextAlias()

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	oResponse := {}

	// Monta o response
	While !(cAlias)->(Eof()) .And. nIndexJSon < 10
		nIndexJSon++
		Aadd(oResponse, JsonObject():New())
		oResponse[nIndexJSon]['numero']  := (cAlias)->(NVE_NUMCAS)
		oResponse[nIndexJSon]['titulo']  := JConvUTF8((cAlias)->(NVE_TITULO))
		oResponse[nIndexJSon]['cliente'] := (cAlias)->(NVE_CCLIEN)
		oResponse[nIndexJSon]['loja']    := (cAlias)->(NVE_LCLIEN)

		(cAlias)->( dbSkip() )
	End
	( cAlias )->( dbCloseArea() )
	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ForBco
Busca o Banco do Fornecedor. Primeiramente pela FIL, se não tiver, verifica a do Fornecedor (SA2)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/confor/{codForn}/bco
@param codForn     - PathParam - Valor contendo o código e loja do fornecedor
@param codBanco    - QueryParam - Código do banco

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET ForBco PATHPARAM codForn QUERYPARAM codBanco WSREST WSPfsAppCP
Local oResponse := JSonObject():New()
Local cAlias    := ""
Local cQuery    := ""
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local codForn   := Self:codForn
Local aForn     := JArrDistFl( codForn, "-" )
Local nIndexJSon:= 0

	cQrySel :=" SELECT FIL_BANCO, FIL_AGENCI, FIL_DVAGE, FIL_CONTA, FIL_DVCTA,"
	cQrySel +=       " COALESCE(SA6.A6_NOME, ' ') A6_NOME"
	cQryFrm :=  " FROM " + RetSqlName("FIL") + " FIL"
	cQryFrm +=  " LEFT JOIN " + RetSqlName("SA6") + " SA6"
	cQryFrm +=    " ON (SA6.A6_COD = FIL.FIL_BANCO"
	cQryFrm +=   " AND SA6.A6_AGENCIA = FIL.FIL_AGENCI"
	cQryFrm +=   " AND SA6.A6_DVAGE = FIL.FIL_DVAGE"
	cQryFrm +=   " AND SA6.A6_NUMCON = FIL.FIL_CONTA"
	cQryFrm +=   " AND SA6.A6_DVCTA = FIL.FIL_DVCTA"
	cQryFrm +=   JSqlFilCom("FIL", "SA6",,, "FIL_FILIAL", "A6_FILIAL")
	cQryFrm +=   " AND SA6.D_E_L_E_T_ = ' ' )"
	cQryWhr := " WHERE FIL.D_E_L_E_T_ = ' '"
	
	If (Len(aForn) > 1)
		cQryWhr +=   " AND FIL.FIL_FORNEC = '" + aForn[1] + "'"
		cQryWhr +=   " AND FIL.FIL_LOJA = '" + aForn[2] + "'"
	EndIf

	If (codForn != "all")
		cQryWhr +=   " AND FIL.FIL_FILIAL = '" + xFilial("FIL") + "'"
	EndIf

	cQuery := ChangeQuery( cQrySel + cQryFrm + cQryWhr )
	cAlias := GetNextAlias()

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	oResponse := {}

	While !(cAlias)->(Eof())
		nIndexJSon++
		Aadd(oResponse, JsonObject():New())
		oResponse[nIndexJSon]['nome']       := JConvUTF8((cAlias)->(A6_NOME))
		oResponse[nIndexJSon]['numBanco']   := (cAlias)->(FIL_BANCO)
		oResponse[nIndexJSon]['agencia']    := (cAlias)->(FIL_AGENCI)
		oResponse[nIndexJSon]['digAgencia'] := (cAlias)->(FIL_DVAGE)
		oResponse[nIndexJSon]['conta']      := (cAlias)->(FIL_CONTA)
		oResponse[nIndexJSon]['digConta']   := (cAlias)->(FIL_DVCTA)
		(cAlias)->( dbSkip() )
	End
	( cAlias )->( dbCloseArea() )

	If (nIndexJSon == 0)
		cQrySel :=" SELECT A2_BANCO, A2_AGENCIA, A2_DVAGE, A2_NUMCON, A2_DVCTA,"
		cQrySel +=       " COALESCE(SA6.A6_NOME, ' ') A6_NOME"
		cQryFrm :=  " FROM "+ RetSqlName("SA2") +" SA2"
		cQryFrm +=  " LEFT JOIN " + RetSqlName("SA6") + " SA6"
		cQryFrm +=    " ON (SA6.A6_COD = SA2.A2_BANCO"
		cQryFrm +=   " AND SA6.A6_AGENCIA = SA2.A2_AGENCIA"
		cQryFrm +=   " AND SA6.A6_DVAGE = SA2.A2_DVAGE"
		cQryFrm +=   " AND SA6.A6_NUMCON = SA2.A2_NUMCON"
		cQryFrm +=   " AND SA6.A6_DVCTA = SA2.A2_DVCTA"
		cQryFrm +=   " AND SA6.D_E_L_E_T_ = '' )"
		cQryWhr := " WHERE A2_COD = '" + aForn[1] + "'"
		cQryWhr +=   " AND A2_LOJA = '" + aForn[2] + "'"
		cQryWhr +=   " AND A2_FILIAL = '" + xFilial("SA2") + "'"
		cQryWhr +=   " AND SA2.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQrySel + cQryFrm + cQryWhr )
		cAlias := GetNextAlias()

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
		oResponse := {}

		While !(cAlias)->(Eof())
			nIndexJSon++
			Aadd(oResponse, JsonObject():New())
			oResponse[nIndexJSon]['nome']       := JConvUTF8((cAlias)->(A6_NOME))
			oResponse[nIndexJSon]['numBanco']   := (cAlias)->(A2_BANCO)
			oResponse[nIndexJSon]['agencia']    := (cAlias)->(A2_AGENCIA)
			oResponse[nIndexJSon]['digAgencia'] := (cAlias)->(A2_DVAGE)
			oResponse[nIndexJSon]['conta']      := (cAlias)->(A2_NUMCON)
			oResponse[nIndexJSon]['digConta']   := (cAlias)->(A2_DVCTA)
			(cAlias)->( dbSkip() )
		End

		( cAlias )->( dbCloseArea() )
	EndIf

	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET ConGenerica
Retorna os parâmetros de Baixa automática

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/param/baixaAut

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET ConGenerica PATHPARAM codEntidade QUERYPARAM codFields, desFields, valorDig, extFields, filtRelSA2 WSREST WSPfsAppCP
Local oResponse  := JSonObject():New()
Local lRet       := .T.
Local nIndexJSon := 0
Local nI         := 0
Local cQuery     := ""
Local cAlias     := ""
Local cTabela    := Self:codEntidade
Local cQrySel    := " SELECT "
Local cQryFrm    := " FROM "
Local cQryWhr    := " WHERE " + cTabela + ".D_E_L_E_T_ = ' ' "
Local cQryGrp    := ""
Local cQryOrd    := ""
Local cCamposSel := ""
Local cRelac     := ""
Local cFilUsu    := ""
Local cCampos    := Self:codFields + "," + Self:desFields
Local lFilRelSA2 := (!Empty(Self:filtRelSA2) .AND. Self:filtRelSA2 == "T")
Local aRelac     := {}
Local aCampos    := {}
Local aCmpFilt   := {}
Local aFilEnt    := EmpFilUsu(cTabela)

	If !Empty(Self:extFields)
		cCampos += "," + Self:extFields
	EndIf

	aCampos := JStrArrDst( cCampos, "," )

	For nI := 1 to Len(aCampos)
		cCamposSel += aCampos[nI] + ","
	Next nI

	// Monta o Select e o GroupBy com os Campos passados
	cCamposSel := SubStr(cCamposSel, 1, Len(cCamposSel) - 1)
	cQrySel += cCamposSel
	cQryGrp += " GROUP BY " + cCamposSel

	// Monta o filtro de Filial do usuário
	If (Len(aFilEnt)>0)
		cQryWhr += " AND "
		Do Case
			Case cTabela == "SA2"
				cQryWhr += "A2_FILIAL IN ("
			Case cTabela == "SED"
				cQryWhr += "ED_FILIAL IN ("
			Otherwise
				cQryWhr += cTabela + "_FILIAL IN ("
		End

		For nI := 1 To Len(aFilEnt)
			cFilUsu += "'" + aFilEnt[nI] + "',"
		Next nI

		cQryWhr += SubStr(cFilUsu, 1, Len(cFilUsu) - 1) + ')'
	EndIf

	// Monta o From
	cQryFrm += RetSqlName(cTabela) + " " + cTabela
	If (lFilRelSA2)
		Do Case
			Case cTabela == "SA2"
				cRelac := "SE2.E2_FORNECE = SA2.A2_COD AND SE2.E2_LOJA = SA2.A2_LOJA AND "
			Otherwise
				aRelac := JURSX9("SE2", cTabela)
				For nI := 1 To Len(aRelac)
					cRelac := cTabela + "." + AllTrim(aRelac[nI][1]) + " = SE2." + AllTrim(aRelac[nI][2]) + " AND "
				Next nI
		End

		cRelac  += " SE2.D_E_L_E_T_ = ' ' "
		cQryFrm += " INNER JOIN " + RetSqlName("SE2") + " SE2 ON (" + cRelac + ") "
	EndIf

	// Filtra caso tenha algum valor digitado
	If !Empty(self:valorDig)
		aCmpFilt   := JStrArrDst(Self:desFields, ",")
		cQryWhr += " AND ("

		For nI := 1 To Len(aCmpFilt)
			cQryWhr += " UPPER(" + aCmpFilt[nI] + ") LIKE '%" + Upper(self:valorDig) + "%' OR "
		Next nI

		cQryWhr := SubStr(cQryWhr, 1, Len(cQryWhr) - 3) + ")"
	EndIf

	// Monta a Query
	cQuery := ChangeQuery( cQrySel + cQryFrm + cQryWhr + cQryGrp + cQryOrd )

	cAlias := GetNextAlias()

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	oResponse['item'] := {}

	// Monta o response
	While !(cAlias)->(Eof())
		nIndexJSon++
		If (nIndexJSon <= 10)
			Aadd(oResponse['item'], JsonObject():New())

			For nI := 1 To Len(aCampos)
				oResponse['item'][nIndexJSon][aCampos[nI]] := JConvUTF8((cAlias)->&(aCampos[nI]))
			Next nI
		EndIf
		(cAlias)->( dbSkip() )
	End

	( cAlias )->( dbCloseArea() )
	Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TabGenerica
Busca de Registro na tabela genérica (SX5)

@author willian.kazahaya
@since 27/08/2019
/*/
//-------------------------------------------------------------------
WSMethod GET TabGenerica PATHPARAM codEntidade WSRECEIVE searchKey, chaveTab WSREST WSPfsAppCP
Local oResponse  := JSonObject():New()
Local cQuery     := ""
Local cAlias     := ""
Local cCodTab    := Self:codEntidade
Local cSearchKey := Self:searchKey
Local cChaveTab  := Self:chaveTab
Local nIndexJSon := 0

	cQuery := " SELECT SX5.X5_FILIAL FILIAL, SX5.X5_TABELA TABELA, SX5.X5_CHAVE CHAVE "
	cQuery +=       ", SX5.X5_DESCRI DESCRI, SX5.X5_DESCSPA DESCSPA, SX5.X5_DESCENG DESCENG "
	cQuery +=       ", SX5.R_E_C_N_O_ REC  "
	cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += " WHERE SX5.X5_TABELA = '" + Alltrim(cCodTab) + "' "
	cQuery +=   " AND SX5.D_E_L_E_T_ = ' ' "

	If !Empty(cSearchKey)
		cQuery += " AND (SX5.X5_DESCRI LIKE '%" + UPPER(AllTrim(StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' ))) + "%'"
		cQuery +=  " OR  SX5.X5_CHAVE LIKE '%" + UPPER(AllTrim(StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' ))) + "%')"
	ElseIf !Empty(cChaveTab)
		cQuery += " AND SX5.X5_CHAVE = '" + AllTrim(cChaveTab) + "'"
	Endif

	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['result'] := {}

	While !(cAlias)->(Eof())
		nIndexJSon++
		Aadd(oResponse['result'], JsonObject():New())
		oResponse['result'][nIndexJSon]['filial']    := (cAlias)->FILIAL
		oResponse['result'][nIndexJSon]['tabela']    := (cAlias)->TABELA
		oResponse['result'][nIndexJSon]['chave']     := (cAlias)->CHAVE
		oResponse['result'][nIndexJSon]['descricao'] := JConvUTF8((cAlias)->DESCRI)
		oResponse['result'][nIndexJSon]['descrispa'] := JConvUTF8((cAlias)->DESCSPA)
		oResponse['result'][nIndexJSon]['descrieng'] := JConvUTF8((cAlias)->DESCENG)

		(cAlias)->( dbSkip() )
	End

	(cAlias)->(dbCloseArea())

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} CmpHabilitado
Busca de Registro na tabela genérica (SX5)

@author willian.kazahaya
@since 27/08/2019
/*/
//-------------------------------------------------------------------
WSMETHOD GET CmpHabilitado PATHPARAM recnoTitulo WSRECEIVE codOperacao WSREST WSPfsAppCP
Local oResponse  := JSonObject():New()
Local cOperacao  := Self:codOperacao
Local aDadosTit  := gtDadoByRC(Self:recnoTitulo, 1, )
Local aCmpTitHab := {}
Local nI         := 0

	If (cOperacao == Nil)
		cOperacao := 4
	EndIf

	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )

	If Len(aDadosTit) > 0 ;
			.And. SE2->( dbSeek(aDadosTit[1][1][2]))

		aCmpTitHab := fa050MCpo(cOperacao)

		oResponse["campos"] := {}
		For nI := 1 To Len(aCmpTitHab)
			aAdd(oResponse["campos"], aCmpTitHab[nI])
		Next nI
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET gtPrBaixAut
Retorna os parâmetros de Baixa automática

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/param/baixaAut

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET gtPrBaixAut WSREST WSPfsAppCP
Local oResponse := JsonObject():New()
Local nI         := 0
Local lRet     := .F.
Local oObj := FWSX1Util():New()
Local aPergunte

	oObj:AddGroup("FIN090")
	oObj:SearchGroup()
	aPergunte := oObj:GetGroup("FIN090")

	Pergunte("FIN090", .F.)
	oResponse['params'] := {}
	If aPergunte != Nil
		For nI := 1 To Len(aPergunte[2])
			aAdd(oResponse['params'], JsonObject():New())
			oResponse['params'][nI]['id']    := JConvUTF8(aPergunte[2][nI]:CX1_ORDEM)
			oResponse['params'][nI]['desc']  := JConvUTF8(aPergunte[2][nI]:CX1_PERGUNT)
			oResponse['params'][nI]['tipo']  := JConvUTF8(aPergunte[2][nI]:CX1_TIPO)
			oResponse['params'][nI]['valor'] := &("MV_PAR" + aPergunte[2][nI]:CX1_ORDEM)

		Next nI
	EndIf

	If nI > 0
		lRet := .T.
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		lRet := setRespError(404, STR0029) //"Os parâmetros não foram encontrados na base!"
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET gtAnexos
Busca os Anexos

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/anexos/{recnoTitulo}

@param recnoTitulo - PathParam  - Recno do Titulo (SE2)
@param codItem     - QueryParam - Sequencial do Item
@param cEntidade   - QueryParam - Entidade a ser pesquisada

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET gtAnexos PATHPARAM recnoTitulo WSRECEIVE codItem, cEntidade WSREST WSPfsAppCP
Local oResponse := JsonObject():New()
Local cAliasNUM := ""
Local cQuery    := ""
Local nIndex    := 0
Local lRet      := .T.
Local cSE2Recno := Self:recnoTitulo
Local cItem     := Self:codItem
Local cEntidade := Self:cEntidade
Local lPesqBoth := .F.               // Indica se vai pesquisar tanto OHF quanto OHG

	If (Empty(cEntidade))
		lPesqBoth := .T.
		cEntidade := "OHF"
	EndIf

	cQuery := ChangeQuery(qryNUMOH(cSE2Recno, cItem, .F., cEntidade))
	cAliasNUM := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNUM, .F., .T.)

	oResponse['anexos'] := {}
	While (cAliasNUM)->(!Eof())
		nIndex++
		aAdd(oResponse["anexos"], JsonObject():New())
		oResponse["anexos"][nIndex]["codDocto"] := JConvUTF8((cAliasNUM)->(NUM_COD))
		oResponse["anexos"][nIndex]["nomeDocto"] := JConvUTF8((cAliasNUM)->(NUM_DOC))
		oResponse["anexos"][nIndex]["extensaoDocto"] := JConvUTF8((cAliasNUM)->(NUM_EXTEN))
		oResponse["anexos"][nIndex]["seqDesdobramento"] := JConvUTF8((cAliasNUM)->(SEQITEM))
		oResponse["anexos"][nIndex]["codNatureza"] := JConvUTF8((cAliasNUM)->(CODNATUR))
		oResponse["anexos"][nIndex]["descNatureza"] := JConvUTF8((cAliasNUM)->(ED_DESCRIC))
		oResponse["anexos"][nIndex]["prefixoTitulo"] := (cAliasNUM)->(E2_PREFIXO)
		oResponse["anexos"][nIndex]["numeroTitulo"] := (cAliasNUM)->(E2_NUM)
		oResponse["anexos"][nIndex]["parcelaTitulo"] := (cAliasNUM)->(E2_PARCELA)
		oResponse["anexos"][nIndex]["filialAnexo"] := (cAliasNUM)->(NUM_FILENT)
		oResponse["anexos"][nIndex]["tabelaOrigem"] := cEntidade

		(cAliasNUM)->( dbSkip() )
	End
	(cAliasNUM)->( dbCloseArea() )
	cAliasNUM := ""

	If (lPesqBoth)
		cQuery := ChangeQuery(qryNUMOH(cSE2Recno, cItem, .F., "OHG"))
		cAliasNUM := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNUM, .F., .T.)

		While (cAliasNUM)->( !Eof() )
			nIndex++
			aAdd(oResponse["anexos"], JsonObject():New())
			oResponse["anexos"][nIndex]["codDocto"] := JConvUTF8((cAliasNUM)->(NUM_COD))
			oResponse["anexos"][nIndex]["nomeDocto"] := JConvUTF8((cAliasNUM)->(NUM_DOC))
			oResponse["anexos"][nIndex]["extensaoDocto"] := JConvUTF8((cAliasNUM)->(NUM_EXTEN))
			oResponse["anexos"][nIndex]["seqDesdobramento"] := JConvUTF8((cAliasNUM)->(SEQITEM))
			oResponse["anexos"][nIndex]["codNatureza"] := JConvUTF8((cAliasNUM)->(CODNATUR))
			oResponse["anexos"][nIndex]["descNatureza"] := JConvUTF8((cAliasNUM)->(ED_DESCRIC))
			oResponse["anexos"][nIndex]["prefixoTitulo"] := (cAliasNUM)->(E2_PREFIXO)
			oResponse["anexos"][nIndex]["numeroTitulo"] := (cAliasNUM)->(E2_NUM)
			oResponse["anexos"][nIndex]["parcelaTitulo"] := (cAliasNUM)->(E2_PARCELA)
			oResponse["anexos"][nIndex]["filialAnexo"] := (cAliasNUM)->(NUM_FILENT)
			oResponse["anexos"][nIndex]["tabelaOrigem"] := "OHG"

			(cAliasNUM)->( dbSkip() )
		End

		(cAliasNUM)->( dbCloseArea() )
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT TotDesdobramento
Retorna os dados para a Consulta de Desdobramento

@Param - Optional - pageSize - Quantidade de registros por paginação
@Param - Optional - page - Numero da Pagina

@example - Body
	{
		"filter": [
			{
				"field": "_CCASO",
				"value": "000008",
				"type": "F3"
			},
			{
				"field": "_VALOR",
				"value": "12321||134321.46",
				"type": "Valor"
			},
			{
				"field": "E2_BAIXA",
				"value": "20210214||20210220",
				"type": "Data"
			},
			{
				"field": "_HISTOR",
				"value": "12 e21 2d 2dsadsa 21",
				"type": "String"
			}
		],
		"fields": [
			{
				"field": "VALOR",
				"name": "Valor Desdobramentos",
				"type": "Valor"
			}
		]
	}

@author Willian Kazahaya
@since 26/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT TotDesdobramento WSREST WSPfsAppCP
Local oResponse  := JsonObject():New()
Local lRet       := .T.
Local lRegSE2Ok  := .T.
Local lRegDSDOk  := .T.
Local aBodFilOrd := {}
Local cBody      := ""
Local cQuery     := ""
Local cAliasDb   := ""
Local chaveSE2   := ""
Local encChvSE2  := ""
Local cEntidade  := ""
Local nNumreg    := 0
Local nTotDesdob := 0.0
Local nTotPosPag := 0.0
Local nI         := 0

	cBody      := StrTran(Self:GetContent(),CHR(10),"")
	aBodFilOrd := FilOrdSQLDesdob(cBody)
	cQuery     := ChangeQuery(sqlConDesdob(aBodFilOrd))

	cAliasDb := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDb, .F., .T.)

	oResponse['totalizadores'] := JsonObject():New()

	// Inicializa as posições no JSONObject
	For nI := 1 To Len(aBodFilOrd[6])
		If (aBodFilOrd[6][nI][3] == "Valor")
			oResponse['totalizadores'][StrTran(aBodFilOrd[6][nI][1], " ","")] := 0
		ElseIf (aBodFilOrd[6][nI][3] == "Numero")
			oResponse['totalizadores'][StrTran(aBodFilOrd[6][nI][1], " ","")] := 0
		EndIf
	Next nI

	// Loop para preencher os dados
	While (cAliasDb)->(!Eof())
		chaveSE2 := (cAliasDb)->E2_FILIAL + ;
			(cAliasDb)->E2_PREFIXO + ;
			(cAliasDb)->E2_NUM + ;
			(cAliasDb)->E2_PARCELA + ;
			(cAliasDb)->E2_TIPO + ;
			(cAliasDb)->E2_FORNECE + ;
			(cAliasDb)->E2_LOJA

		encChvSE2 := Encode64(chaveSE2)

		cEntidade := (cAliasDb)->ORIGEM

		If (Len(aBodFilOrd[4]) > 0 .And. cEntidade == "SE2")
			lRegSE2Ok := VerRegFilt("SE2", chaveSE2, aClone(aBodFilOrd[4]))
		EndIf

		If (Len(aBodFilOrd[5]) > 0)
			lRegDSDOk := VerRegFilt(cEntidade, (cAliasDb)->E2_FILIAL + (cAliasDb)->IDDOC + (cAliasDb)->CITEM,aClone(aBodFilOrd[5]))
		EndIf

		If (lRegSE2Ok .And. lRegDSDOk)
			nNumReg++
			For nI := 1 To Len( aBodFilOrd[6] )
				If (aBodFilOrd[6][nI][3] == "Valor")
					oResponse['totalizadores'][StrTran(aBodFilOrd[6][nI][1], " ","")] += (cAliasDb)->&(aBodFilOrd[6][nI][2])
				ElseIf (aBodFilOrd[6][nI][3] == "Numero")
					oResponse['totalizadores'][StrTran(aBodFilOrd[6][nI][1], " ","")] += (cAliasDb)->&(aBodFilOrd[6][nI][2])
				EndIf
			Next nI

			If ((cAliasDb)->ORIGEM == "OHG")
				nTotPosPag += (cAliasDb)->VALOR
			Else
				nTotDesdob += (cAliasDb)->VALOR
			EndIf
		EndIf
		(cAliasDb)->(dbSkip())
	EndDo

	// Quantidade de registros
	oResponse['totalizadores']['quantidadeRegistros'] := nNumReg
	oResponse['totalizadores']['totalDesdobramentos'] := nTotDesdob
	oResponse['totalizadores']['totalPosPagamentos']  := nTotPosPag

	(cAliasDb)->(DbCloseArea())
	cAliasDb := ""

	If nNumReg != 0
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT ConDesdobramento
Retorna os dados para a Consulta de Desdobramento

@Param - Optional - pageSize - Quantidade de registros por paginação
@Param - Optional - page - Numero da Pagina

@example - Body
	{
		"filter": [
			{
				"field": "_CCASO",
				"value": "000008",
				"type": "F3"
			},
			{
				"field": "_VALOR",
				"value": "12321||134321.46",
				"type": "Valor"
			},
			{
				"field": "E2_BAIXA",
				"value": "20210214||20210220",
				"type": "Data"
			},
			{
				"field": "_HISTOR",
				"value": "12 e21 2d 2dsadsa 21",
				"type": "String"
			}
		],
		"order": [
			{
				"field": "E2_NATUREZ",
				"orderType": "A"
			},
			{
				"field": "E2_PREFIXO+E2_NUM+E2_PREFIXO",
				"orderType": "D"
			}
		]
	}

@author Willian Kazahaya
@since 26/02/2021
/*/
//-------------------------------------------------------------------
WSMETHOD PUT ConDesdobramento QUERYPARAM pageSize, page WSREST WSPfsAppCP
Local oResponse   := JsonObject():New()
Local cQuery      := ""
Local cBody       := ""
Local cAliasDb    := ""
Local chaveSE2    := ""
Local encChvSE2   := ""
Local cTipoCpo    := ""
Local lRegSE2Ok   := .T.
Local lRegDSDOk   := .T.
Local lExportRel  := .F.
Local aBodFilOrd  := {}
Local lFiltraPag  := (Self:pageSize != Nil .And. Self:page != Nil)
Local nIndex      := 0
Local nNumReg     := 0
Local nRegMin     := 0
Local nI          := 0
Local nRegMax     := 10

	If Empty(aCstFldsSE2)
		aCstFldsSE2 := JGtExtFlds("SE2", .F., .T., .F. )[1]
	EndIf

	// Verifica se haverá paginação e realiza os calculos
	If lFiltraPag
		If (Val(Self:pageSize) == 0 .And. Val(Self:page) == 0)
			lExportRel := .T.
			lFiltraPag := .F.
		Else
			nRegMax := Val(Self:pageSize) * Val(Self:page)
			nRegMin := (Val(Self:page)-1) * Val(Self:pageSize)
		EndIf
	EndIf

	cBody      := StrTran(Self:GetContent(),CHR(10),"")
	aBodFilOrd := FilOrdSQLDesdob(cBody)
	cQuery     := ChangeQuery(sqlConDesdob(aBodFilOrd))

	cAliasDb := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDb, .F., .T.)

	oResponse['desdobramento'] := {}
	While (cAliasDb)->(!Eof())
		chaveSE2 := (cAliasDb)->E2_FILIAL + ;
			(cAliasDb)->E2_PREFIXO + ;
			(cAliasDb)->E2_NUM + ;
			(cAliasDb)->E2_PARCELA + ;
			(cAliasDb)->E2_TIPO + ;
			(cAliasDb)->E2_FORNECE + ;
			(cAliasDb)->E2_LOJA

		encChvSE2 := Encode64(chaveSE2)

		cEntidade := (cAliasDb)->ORIGEM

		If (Len(aBodFilOrd[4]) > 0 .And. cEntidade == "SE2")
			lRegSE2Ok := VerRegFilt("SE2", chaveSE2, aClone(aBodFilOrd[4]))
		EndIf

		If (Len(aBodFilOrd[5]) > 0)
			lRegDSDOk := VerRegFilt(cEntidade, (cAliasDb)->E2_FILIAL + (cAliasDb)->IDDOC + (cAliasDb)->CITEM,aClone(aBodFilOrd[5]))
		EndIf

		If (lRegSE2Ok .And. lRegDSDOk)
			nIndex++
			If ((lFiltraPag .And. nIndex > nRegMin .And. nIndex <= nRegMax) .Or. lExportRel)
				DbSelectArea(cEntidade)
				dbGoTo((cAliasDb)->(ENTRECNO))

				nNumReg++
				aAdd(oResponse['desdobramento'], JsonObject():New())

				//Titulo
				oResponse['desdobramento'][nNumReg]['chaveTitulo']    = encChvSE2
				oResponse['desdobramento'][nNumReg]['SE2Recno']       = (cAliasDb)->SE2RECNO
				oResponse['desdobramento'][nNumReg]['filial']         = JConvUTF8((cAliasDb)->E2_FILIAL)
				oResponse['desdobramento'][nNumReg]['prefixo']        = JConvUTF8((cAliasDb)->E2_PREFIXO)
				oResponse['desdobramento'][nNumReg]['numero']         = JConvUTF8((cAliasDb)->E2_NUM)
				oResponse['desdobramento'][nNumReg]['parcela']        = JConvUTF8((cAliasDb)->E2_PARCELA)
				oResponse['desdobramento'][nNumReg]['tipo']           = JConvUTF8((cAliasDb)->E2_TIPO)
				oResponse['desdobramento'][nNumReg]['naturezaTitulo'] =  JConvUTF8((cAliasDb)->E2_NATUREZ)

				// Fornecedor
				oResponse['desdobramento'][nNumReg]['codFornecedor']  = JConvUTF8((cAliasDb)->E2_FORNECE)
				oResponse['desdobramento'][nNumReg]['lojaFornecedor'] = JConvUTF8((cAliasDb)->E2_LOJA)
				oResponse['desdobramento'][nNumReg]['fornecedor']     = JConvUTF8((cAliasDb)->A2_NOME)

				// Datas do Titulo
				oResponse['desdobramento'][nNumReg]['dataBaixa']      = JConvUTF8((cAliasDb)->E2_BAIXA)
				oResponse['desdobramento'][nNumReg]['dataVencto']     = JConvUTF8((cAliasDb)->E2_VENCTO)
				oResponse['desdobramento'][nNumReg]['dataVenctoReal'] = JConvUTF8((cAliasDb)->E2_VENCREA)

				// Moeda/Valor do Titulo
				oResponse['desdobramento'][nNumReg]['moeda']          = (cAliasDb)->E2_MOEDA
				oResponse['desdobramento'][nNumReg]['moedaSimbolo']   = JConvUTF8((cAliasDb)->CTO_SIMB)
				oResponse['desdobramento'][nNumReg]['taxaMoeda'] = (cAliasDb)->E2_TXMOEDA
				oResponse['desdobramento'][nNumReg]['valor'] = (cAliasDb)->VALOR

				oResponse['desdobramento'][nNumReg]['origem'] = JConvUTF8((cAliasDb)->ORIGEM)

				// Desdobramento
				oResponse['desdobramento'][nNumReg]['iddoc'] = JConvUTF8((cAliasDb)->IDDOC)
				oResponse['desdobramento'][nNumReg]['codItem'] = JConvUTF8((cAliasDb)->CITEM)
				oResponse['desdobramento'][nNumReg]['desdobCodNatureza'] = JConvUTF8((cAliasDb)->CNATUR)
				oResponse['desdobramento'][nNumReg]['desdobDesNatureza'] = encode64(AllTrim((cAliasDb)->ED_DESCRIC))
				oResponse['desdobramento'][nNumReg]['desdobCCJuriNatureza'] = JConvUTF8((cAliasDb)->ED_CCJURI)
				oResponse['desdobramento'][nNumReg]['desdobDataInclusao'] = JConvUTF8((cAliasDb)->DTINCL)

				// Escritório/Centro de Custo
				oResponse['desdobramento'][nNumReg]['codEscritorio'] = JConvUTF8((cAliasDb)->CESCR)
				oResponse['desdobramento'][nNumReg]['escritorio'] = encode64(AllTrim((cAliasDb)->NS7_NOME))
				oResponse['desdobramento'][nNumReg]['codCentroCusto'] = JConvUTF8((cAliasDb)->CCUSTO)
				oResponse['desdobramento'][nNumReg]['centroCusto'] = encode64(AllTrim((cAliasDb)->CTT_DESC01))

				// Participante/Solicitante
				oResponse['desdobramento'][nNumReg]['codSolicitante'] = JConvUTF8((cAliasDb)->CPART)
				oResponse['desdobramento'][nNumReg]['nomeSolicitante'] = encode64(AllTrim((cAliasDb)->PARTNOME))
				oResponse['desdobramento'][nNumReg]['siglaSolicitante'] = JConvUTF8((cAliasDb)->PARTSIGLA)
				oResponse['desdobramento'][nNumReg]['codParticipante'] = JConvUTF8((cAliasDb)->CPART2)
				oResponse['desdobramento'][nNumReg]['nomeParticipante'] = encode64(AllTrim((cAliasDb)->SOLICNOME))
				oResponse['desdobramento'][nNumReg]['siglaParticipante'] = JConvUTF8((cAliasDb)->SOLICSIGLA)

				// Rateio
				oResponse['desdobramento'][nNumReg]['codRateio'] = JConvUTF8((cAliasDb)->CRATEI)
				oResponse['desdobramento'][nNumReg]['rateio'] = encode64(AllTrim((cAliasDb)->OH6_DESCRI))

				// Cliente/Caso/Despesa
				oResponse['desdobramento'][nNumReg]['codCliente'] = JConvUTF8((cAliasDb)->CCLIEN)
				oResponse['desdobramento'][nNumReg]['lojaCliente'] = JConvUTF8((cAliasDb)->CLOJA)
				oResponse['desdobramento'][nNumReg]['cliente'] = encode64(AllTrim((cAliasDb)->A1_NOME))
				oResponse['desdobramento'][nNumReg]['codCaso'] = JConvUTF8((cAliasDb)->CCASO)
				oResponse['desdobramento'][nNumReg]['tituloCaso'] = encode64(AllTrim((cAliasDb)->NVE_TITULO))
				oResponse['desdobramento'][nNumReg]['codTipoDespesa'] = JConvUTF8((cAliasDb)->CTPDSP)
				oResponse['desdobramento'][nNumReg]['tipoDespesa'] = encode64(AllTrim((cAliasDb)->NRH_DESC))
				oResponse['desdobramento'][nNumReg]['quantidadeDespesa'] =(cAliasDb)->QTDDSP
				oResponse['desdobramento'][nNumReg]['dataDespesa'] = JConvUTF8((cAliasDb)->DTDESP)
				oResponse['desdobramento'][nNumReg]['cobraDespesa'] = JConvUTF8((cAliasDb)->COBRA)

				// Projeto
				oResponse['desdobramento'][nNumReg]['codProjeto'] = JConvUTF8((cAliasDb)->CPROJE)
				oResponse['desdobramento'][nNumReg]['projeto'] = JConvUTF8((cAliasDb)->OHL_DPROJE)
				oResponse['desdobramento'][nNumReg]['codItemProjeto'] = JConvUTF8((cAliasDb)->CITPRJ)
				oResponse['desdobramento'][nNumReg]['itemProjeto'] = JConvUTF8((cAliasDb)->OHM_DITEM)

				// Histórico
				oResponse['desdobramento'][nNumReg]['codHistoricoPadrao'] = JConvUTF8((cAliasDb)->CHISTP)
				oResponse['desdobramento'][nNumReg]['historicoPadrao'] = JConvUTF8((cAliasDb)->OHA_RESUMO)
				oResponse['desdobramento'][nNumReg]['historico'] = encode64(AllTrim((cEntidade)->&(cEntidade + "_HISTOR")))

				// Campos Customizados
				If !Empty(aCstFldsSE2)
					For nI := 1 to Len(aCstFldsSE2)
						If getSx3Cache(aCstFldsSE2[nI][1], 'X3_CONTEXT') == "R" .And. getSx3Cache(aCstFldsSE2[nI][1] ,'X3_BROWSE') == "S"
						cTipoCpo := getSx3Cache(aCstFldsSE2[nI][1] ,'X3_TIPO')
							If cTipoCpo == "N"
								oResponse['desdobramento'][nNumReg][aCstFldsSE2[nI][1]] := (cAliasDb)->(FieldGet(FieldPos(aCstFldsSE2[nI][1])))
							ElseIf cTipoCpo == "M"
								// Obtenção das informações dos campos MEMO
								SE2->(DbSetOrder(1))
								If (SE2->(DbSeek(chaveSE2)))
									cMemoCst := SE2->(FieldGet(FieldPos(aCstFldsSE2[nI][1])))
									oResponse['desdobramento'][nNumReg][aCstFldsSE2[nI][1]] := JConvUTF8(cMemoCst)
								EndIf
							Else
								oResponse['desdobramento'][nNumReg][aCstFldsSE2[nI][1]] := JConvUTF8((cAliasDb)->(FieldGet(FieldPos(aCstFldsSE2[nI][1]))))
							EndIf
						EndIf
					Next nI
				EndIf

			EndIf
		EndIf
		(cAliasDb)->(dbSkip())
	EndDo

	If (nIndex <= nRegMax)
		oResponse['hasNext'] := "false"
	else
		oResponse['hasNext'] := "true"
	EndIf

	(cAliasDb)->(DbCloseArea())
	cAliasDb := ""

	If nIndex == 0
		//setRespError(404, STR0030) //"Não foram encontrados titulos!"
		//lRet := .F.
	Else
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		oResponse:FromJSon("{}")
		oResponse := Nil
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT DadosTit
Retorna de todos os titulos

@param filtLeg  - Filtro de legenda
@param pageSize - Quantidade de itens por página
@param page     - Número da página

@example PUT -> http://127.0.0.1:9090/rest/WSPfsAppCP/titpag
@body - Exemplo de body da requisição:
{
  "filtro": [],
  "ordem": [],
  "searchkey": "teste",
  "datas": "E2_EMISSAO >= '20211028' AND E2_EMISSAO <= '20211028'",
  "prefixos": ["WYK", "AGL"]
}

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT DadosTit QUERYPARAM filtLeg, pageSize, page WSREST WSPfsAppCP
Local oResponse   := JsonObject():New()
Local aValLegen   := Fa040Legenda("SE2")
Local aQtdLegen   := {}
Local cAliasDb    := ""
Local cStatusTit  := ""
Local lRet        := .T.
Local lFiltraLeg  := !Empty(Self:filtLeg)
Local lFiltraPag  := (Self:pageSize != Nil .And. Self:page != Nil)
Local nIndex      := 0
Local nI          := 0
Local nRegMin     := 0
Local nRegMax     := 0
Local nNumReg     := 0
Local nQtdRegTot  := 0
Local nQtdAnxDsd  := 0
Local cBody       := ""
Local cQuery      := ""
Local cTipoCpo    := ""
Local cMemoCst    := ""
Local aCopyTit    := {}

	If Empty(aCstFldsSE2)
		aCstFldsSE2 := JGtExtFlds("SE2", .F., .T., .F. )[1]
	EndIf

	cBody := StrTran(Self:GetContent(),CHR(10),"")

	// Verifica se haverá paginação e realiza os calculos
	If lFiltraPag
		nRegMax := Val(Self:pageSize) * Val(Self:page)
		nRegMin := (Val(Self:page)-1) * Val(Self:pageSize)
	EndIf

	// Monta o array para o Totalizador por Legenda
	For nI := 1 To Len(aValLegen)
		//              "Nome da legenda", Qtd, Soma Valor Titulo
		aAdd(aQtdLegen, {aValLegen[nI][2], 0, 0 })
	Next nI

	cQuery   := ChangeQuery(QryConSE2(cBody))
	cAliasDb := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDb, .F., .T.)

	// Inicializa o agrupador "titulos"
	oResponse['titulos'] := {}

	// Loop pelos registros
	While (cAliasDb)->( !Eof() ) .And. (!lFiltraPag .Or. (lFiltraPag .And. nNumReg <= nRegMax))
		cStatusTit := ""

		DbSelectArea("SE2")
		dbGoTo((cAliasDb)->(SE2Recno))
		// Posiciona na linha da SE2 por conta da expressão da legenda a ser executada
		If SE2->( Recno() ) == (cAliasDb)->(SE2RECNO)
			For nI := 1 To Len(aValLegen)
				// Executa a função da legenda para atribuir a Legenda do Titulo
				If &(aValLegen[nI][1])
					If  ((lFiltraLeg .And. aValLegen[nI][2] == Self:filtLeg ) .Or. (!lFiltraLeg))
						cStatusTit := aValLegen[nI][2] // Atribui o status do titulo encontrado
						nNumReg++
					EndIf
					aQtdLegen[nI][3] += (cAliasDb)->(E2_VALOR) // Incluindo o valor total por tipo de legenda
					aQtdLegen[nI][2]++ // Adiciona ao totalizador de titulos
					nQtdRegTot++
					exit
				EndIf
			Next nI
		EndIf

		// Verifica a paginação
		If ((!lFiltraPag) .Or. (lFiltraPag .And. nNumReg > nRegMin .And. nNumReg <= nRegMax) ) .And. !Empty(cStatusTit)
			nIndex++
			aCopyTit := J273PreVld()
			nQtdAnxDsd := qtdNUMOH((cAliasDb)->(SE2RECNO)) + qtdNUMOH((cAliasDb)->(SE2RECNO),, "OHG") //Pesquisa a quantidade de anexos

			aAdd(oResponse['titulos'], JSonObject():New())
			oResponse['titulos'][nIndex]['filial']               := (cAliasDb)->(E2_FILIAL)
			oResponse['titulos'][nIndex]['prefixo']              := (cAliasDb)->(E2_PREFIXO)
			oResponse['titulos'][nIndex]['numero']               := JConvUTF8((cAliasDb)->(E2_NUM))
			oResponse['titulos'][nIndex]['parcela']              := (cAliasDb)->(E2_PARCELA)
			oResponse['titulos'][nIndex]['tipoTitulo']           := JConvUTF8((cAliasDb)->(E2_TIPO))
			oResponse['titulos'][nIndex]['codFornecedor']        := (cAliasDb)->(E2_FORNECE)
			oResponse['titulos'][nIndex]['lojaFornecedor']       := (cAliasDb)->(E2_LOJA)
			oResponse['titulos'][nIndex]['nomeFornecedor']       := encode64(AllTrim((cAliasDb)->A2_NOME))
			oResponse['titulos'][nIndex]['bloqueioFornecedor']   := (cAliasDb)->(A2_MSBLQL)
			oResponse['titulos'][nIndex]['codNatureza']          := (cAliasDb)->(E2_NATUREZ)
			oResponse['titulos'][nIndex]['descNatureza']         := encode64(AllTrim((cAliasDb)->ED_DESCRIC))
			oResponse['titulos'][nIndex]['centroCustaNatureza']  := (cAliasDb)->(ED_CCJURI)
			oResponse['titulos'][nIndex]['bloqueioNatureza']     := (cAliasDb)->(ED_MSBLQL)
			oResponse['titulos'][nIndex]['dataEmissao']          := (cAliasDb)->(E2_EMISSAO)
			oResponse['titulos'][nIndex]['dataVencto']           := (cAliasDb)->(E2_VENCTO)
			oResponse['titulos'][nIndex]['dataVenctoReal']       := (cAliasDb)->(E2_VENCREA)
			oResponse['titulos'][nIndex]['valorTitulo']          := (cAliasDb)->(E2_VALOR)
			oResponse['titulos'][nIndex]['valorConvertido']      := (cAliasDb)->(E2_VLCRUZ)
			oResponse['titulos'][nIndex]['saldoTitulo']          := (cAliasDb)->(E2_SALDO)
			oResponse['titulos'][nIndex]['dataBaixa']            := (cAliasDb)->(E2_BAIXA)
			oResponse['titulos'][nIndex]['dataLiberacao']        := (cAliasDb)->(E2_DATALIB)
			oResponse['titulos'][nIndex]['historico']            := encode64(AllTrim((cAliasDb)->E2_HIST))
			oResponse['titulos'][nIndex]['valorTransit']         := (cAliasDb)->(VLRTRANSIT)
			oResponse['titulos'][nIndex]['valorPosTran']         := (cAliasDb)->(VLRPOSTRAN)
			oResponse['titulos'][nIndex]['RecnoSE2']             := (cAliasDb)->(SE2RECNO)
			oResponse['titulos'][nIndex]['chaveSE2']             := Encode64((cAliasDb)->(E2_FILIAL) + ;
				(cAliasDb)->(E2_PREFIXO) + ;
				(cAliasDb)->(E2_NUM) + ;
				(cAliasDb)->(E2_PARCELA) + ;
				(cAliasDb)->(E2_TIPO) + ;
				(cAliasDb)->(E2_FORNECE) + ;
				(cAliasDb)->(E2_LOJA);
				)
			oResponse['titulos'][nIndex]['RecnoFK7']             := (cAliasDb)->(FK7RECNO)
			oResponse['titulos'][nIndex]['status']               := cStatusTit
			oResponse['titulos'][nIndex]['habCopiaTitulo']       := aCopyTit[1]
			oResponse['titulos'][nIndex]['msgCopiaTitulo']       := JConvUTF8(aCopyTit[2])
			oResponse['titulos'][nIndex]['qtdAnexos']            := nQtdAnxDsd
			oResponse['titulos'][nIndex]['origem']               := (cAliasDb)->(E2_ORIGEM)

			//------ CAMPOS ADICIONAIS
			If !Empty(aCstFldsSE2)
				For nI := 1 to Len(aCstFldsSE2)
					If getSx3Cache(aCstFldsSE2[nI][1], 'X3_CONTEXT') == "R" .And. getSx3Cache(aCstFldsSE2[nI][1] ,'X3_BROWSE') == "S"
					   cTipoCpo := getSx3Cache(aCstFldsSE2[nI][1] ,'X3_TIPO')
						If cTipoCpo == "N"
							oResponse['titulos'][nIndex][aCstFldsSE2[nI][1]] := (cAliasDb)->(FieldGet(FieldPos(aCstFldsSE2[nI][1])))
						ElseIf cTipoCpo == "M"
							// Obtenção das informações dos campos MEMO
							cMemoCst := SE2->(FieldGet(FieldPos(aCstFldsSE2[nI][1])))
							oResponse['titulos'][nIndex][aCstFldsSE2[nI][1]] := JConvUTF8(cMemoCst)
						Else
							oResponse['titulos'][nIndex][aCstFldsSE2[nI][1]] := JConvUTF8((cAliasDb)->(FieldGet(FieldPos(aCstFldsSE2[nI][1]))))
						EndIf
					EndIf
				Next nI
			EndIf
		EndIf

		(cAliasDb)->( dbSkip() )
	EndDo

	oResponse['listaPrefixos'] := JGtPrefixo(cBody)

	(cAliasDb)->( DbCloseArea() )
	cAliasDb := ""

	If nIndex > 0
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
		oResponse:FromJSon("{}")
		oResponse := Nil
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGtPrefixo(cBody)
Busca a lista de prefixos de acordo com o filtro realizado
sem considerar a paginação

@param cbody - Body da requisição com os filtros de pesquisa rápida,
intervalo de datas e prefixos e/ou ordenação
@return aRet - Array com a lista de prefixos filtrados

@since 25/02/2022
/*/
//-------------------------------------------------------------------
Static Function JGtPrefixo(cBody)
Local aRet     := {}
Local cQuery   := ""
Local cAliPref := ""

	cQuery := ChangeQuery(QryConSE2(cBody, .T.))
	cAliPref := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliPref, .F., .T.)

	While (cAliPref)->( !Eof())
		aAdd(aRet, (cAliPref)->E2_PREFIXO)
		(cAliPref)->( dbSkip() )
	EndDo

	(cAliPref)->( DbCloseArea() )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT ConTotTit
Retorna os totalizadores da Consulta de titulos

@example PUT -> http://127.0.0.1:9090/rest/WSPfsAppCP/titpagcon/totalizadores"

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT ConTotTit QUERYPARAM filtLeg WSREST WSPfsAppCP
Local oResponse := JsonObject():New()
Local aValLegen := Fa040Legenda("SE2")
Local aQtdLegen := {}
Local aTotalizad:= {0, 0, 0, 0} // Saldo / Total Desdobrado / Total Desdob. Pós-Pagto / Total Titulo
Local cAliasDb  := ""
Local lRet      := .T.
Local lFiltraLeg:= !Empty(Self:filtLeg)
Local nI        := 0
Local nNumReg   := 0
Local nQtdRegTot:= 0
Local nValorTot := 0
Local cBody     := ""
Local cBdBase   :=  (Upper(TcGetDb()))

	cBody := StrTran(Self:GetContent(),CHR(10),"")

	// Monta o array para o Totalizador por Legenda
	For nI := 1 To Len(aValLegen)
		//              "Nome da legenda", Qtd, Soma Valor Titulo, Saldo do Titulo
		aAdd(aQtdLegen, {aValLegen[nI][2], 0, 0, 0 })
	Next nI

	cQuery := ChangeQuery(QryConSE2(cBody))
	cAliasDb := GetNextAlias()

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDb, .F., .T.)

	// Loop pelos registros
	While (cAliasDb)->( !Eof() )
		DbSelectArea("SE2")
		dbGoTo((cAliasDb)->(SE2Recno))
		// Posiciona na linha da SE2 por conta da expressão da legenda a ser executada
		If SE2->( Recno() ) == (cAliasDb)->(SE2RECNO)
			For nI := 1 To Len(aValLegen)
				// Executa a função da legenda para atribuir a Legenda do Titulo
				If &(aValLegen[nI][1])
					If  ((lFiltraLeg .And. aValLegen[nI][2] == Self:filtLeg ) .Or. (!lFiltraLeg))
						nNumReg++
					EndIf
					aQtdLegen[nI][3] += (cAliasDb)->(E2_VALOR) // Incluindo o valor total por tipo de legenda
					aQtdLegen[nI][4] += (cAliasDb)->(E2_SALDO) // Incluindo o valor total por tipo de legenda
					aQtdLegen[nI][2]++ // Adiciona ao totalizador de titulos
					nQtdRegTot++
					exit
				EndIf
			Next nI
		EndIf

		aTotalizad[1] += (cAliasDb)->(E2_SALDO)

		if (cBdBase == "ORACLE")
			aTotalizad[2] += Val((cAliasDb)->(VLRTRANSIT))
			aTotalizad[3] += Val((cAliasDb)->(VLRPOSTRAN))
		else
			aTotalizad[2] += (cAliasDb)->(VLRTRANSIT)
			aTotalizad[3] += (cAliasDb)->(VLRPOSTRAN)
		EndIf
		aTotalizad[4] += (cAliasDb)->(E2_VALOR)

		(cAliasDb)->( dbSkip() )
	EndDo

	// Monta a estrutura do JSON para os totalizadores por legenda
	oResponse['totalLegenda'] := {}
	For nI := 1 To Len(aQtdLegen)
		aAdd(oResponse['totalLegenda'], JSonObject():New())
		oResponse['totalLegenda'][nI]['legenda'] := aQtdLegen[nI][1]
		oResponse['totalLegenda'][nI]['total']   := aQtdLegen[nI][2]
		oResponse['totalLegenda'][nI]['valorTot']:= aQtdLegen[nI][3]
		oResponse['totalLegenda'][nI]['saldoTot']:= aQtdLegen[nI][4]
		nValorTot += aQtdLegen[nI][3]
	Next nI

	oResponse['totalizadores'] := JSonObject():New()
	oResponse['totalizadores']['saldo']       := aTotalizad[1]
	oResponse['totalizadores']['transitoria'] := aTotalizad[2]
	oResponse['totalizadores']['transPosPag'] := aTotalizad[3]
	oResponse['totalizadores']['valorTitulo'] := aTotalizad[4]

	(cAliasDb)->( DbCloseArea() )

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} gtFilOrdBd(cBody)
Monta o array de Filtro e Ordenação do Body

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function gtFilOrdBd(cBody)
Local retJson
Local itensJs
Local oJsonBody := JsonObject():new()
Local oJsonSub  := JsonObject():new()
Local aFiltros  := {}
Local aOrder    := {}
Local nI        := 0
Local nY        := 0
Local cValor    := ""
Local cChave    := ""
Local cTipo     := ""
Local aSplitFil := {"E2_EMISSAO", "E2_FORNECE", "E2_VENCREA", "E2_VALOR"}

	retJson := oJsonBody:fromJson(cBody)
	itensJs := oJsonBody:GetNames()

	For nI := 1 To Len(itensJs)
		If (itensJs[nI] == "filtro")
			oJsonSub := oJsonBody:getJsonObject("filtro")
			For nY := 1 To Len(oJsonSub)
				cValor := oJsonSub[nY]["valor"] // oJsonSub[1][oJsonSub[1]:getNames()[1]] // Valor
				cChave := oJsonSub[nY]["chave"] // oJsonSub[1][oJsonSub[1]:getNames()[2]] // Chave
				Do Case
					Case aScan(aSplitFil, cChave) > 0
						aAdd(aFiltros, { cChave, StrToKArr(cValor, "||") } )
					Otherwise
						aAdd(aFiltros, { cChave, cValor } )
				EndCase
			Next nY

			oJsonSub := Nil
		Elseif (itensJs[nI] == "ordem")
			oJsonSub := oJsonBody:getJsonObject("ordem")
			For nY := 1 To Len(oJsonSub)
				cChave := oJsonSub[nY]["campo"] // oJsonSub[1][oJsonSub[1]:getNames()[1]] // Valor
				cTipo  := oJsonSub[nY]["ordenacao"] // oJsonSub[1][oJsonSub[1]:getNames()[2]] // Chave
				aAdd(aOrder, { cChave , cTipo })
			Next nY

			oJsonSub := Nil
		EndIf
	Next nI
Return { aFiltros, aOrder  }


//-------------------------------------------------------------------
/*/{Protheus.doc} QryConSE2(cBody, lPrefixo)
Monta a query para a Tela de consulta

@param cBody       - Body da requisição com os filtros/ordenação
@param lPrefixo    - Indica se irá buscar a lista de prefixos para preencher
o multiselect

@author Willian Kazahaya
@since 06/04/2020
/*/
//-------------------------------------------------------------------
Static Function QryConSE2(cBody, lPrefixo)
Local oJsonBody    := JsonObject():new()
Local aFiltros     := {}
Local aOrder       := {}
Local aPrefixos    := {}
Local cQrySel      := ""
Local cQryFrm      := ""
Local cQryWhr      := ""
Local cQryGrp      := ""
Local cQryOrd      := ""
Local cFilConcat   := ""
Local cOrdConcat   := ""
Local cSearchkey   := ""
Local cDatas       := ""
Local cPrefixos    := ""
Local cFiltrExtras := ""
Local cCpoCustom   := ""
Local nI           := 0
Local aFilFilt     := EmpFilUsu("SE2")
Local aBody        := gtFilOrdBd(cBody)
Local cBdBase      := (Upper(TcGetDb()))

Default lPrefixo   := .F.

	oJsonBody:fromJson(cBody)

	aFiltros     := aBody[1]
	aOrder       := aBody[2]
	cSearchkey   := IIF( VALTYPE(oJsonBody['searchkey']) <> "U", oJsonBody['searchkey'] , "" )
	cDatas       := IIF( VALTYPE(oJsonBody['datas'])     <> "U", oJsonBody['datas']     , "" )
	aPrefixos    := IIF( VALTYPE(oJsonBody['prefixos'])  <> "U", oJsonBody['prefixos']  , {} )
	cFiltrExtras := IIF( VALTYPE(oJsonBody['filtroExtra'])  <> "U", oJsonBody['filtroExtra'], "")
	
	// Pega os campos customizados
	For nI := 1 to Len(aCstFldsSE2)
		If getSx3Cache(aCstFldsSE2[nI][1], 'X3_CONTEXT') == "R" .And. getSx3Cache(aCstFldsSE2[nI][1] ,'X3_BROWSE') == "S" .And. getSx3Cache(aCstFldsSE2[nI][1] ,'X3_TIPO') != "M" // Não considera campo MEMO no browse
			cCpoCustom += aCstFldsSE2[nI][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
		EndIf
	Next nI

	If lPrefixo
		cQrySel := " SELECT " + cCpoCustom + " E2_PREFIXO "
	Else
		cQrySel := " SELECT " + cCpoCustom + " SE2.E2_FILIAL, SE2.E2_PREFIXO, SE2.E2_FORNECE, SE2.E2_PARCELA,"
		cQrySel +=        " SE2.E2_EMISSAO, SE2.E2_VENCTO, SE2.E2_VENCREA, SE2.E2_VALOR,"
		cQrySel +=        " SE2.E2_NATUREZ, SED.ED_DESCRIC, SED.ED_CCJURI, SED.ED_MSBLQL,"
		cQrySel +=        " SE2.E2_TIPO, SE2.E2_NUM, SE2.E2_LOJA, SA2.A2_NOME, SA2.A2_MSBLQL,"
		cQrySel +=        " SE2.E2_VLCRUZ, SE2.E2_SALDO, SE2.E2_BAIXA, SE2.E2_DATALIB, SE2.E2_HIST, SE2.E2_ORIGEM,"

		If (cBdBase == "ORACLE")
			cQrySel +=   " COALESCE(TO_CHAR(OHF.VALOR),'0') VLRTRANSIT,"
			cQrySel +=   " COALESCE(TO_CHAR(OHG.VALOR),'0') VLRPOSTRAN,"
		Else
			cQrySel +=   " COALESCE(OHF.VALOR,'0') VLRTRANSIT,"
			cQrySel +=   " COALESCE(OHG.VALOR,'0') VLRPOSTRAN,"
		EndIf

		cQrySel +=       " SE2.R_E_C_N_O_ SE2RECNO, FK7.R_E_C_N_O_ FK7RECNO, FK7.FK7_IDDOC FK7IDDOC"
	EndIf

	cQryFrm :=  " FROM " + RetSqlName("SE2") + " SE2"
	cQryFrm += " INNER JOIN " + RetSqlName("SA2") + " SA2"
	cQryFrm +=    " ON (SA2.A2_COD = SE2.E2_FORNECE"
	cQryFrm +=   " AND SA2.A2_LOJA = SE2.E2_LOJA"
	cQryFrm +=   JSqlFilCom("SE2", "SA2",,, "E2_FILIAL", "A2_FILIAL")
	cQryFrm +=   " AND SA2.D_E_L_E_T_ = ' ')"
	cQryFrm +=  " LEFT JOIN " + RetSqlName("FK7") + " FK7"
	cQryFrm +=    " ON (FK7.FK7_CHAVE = SE2.E2_FILIAL || '|' ||"
	cQryFrm +=                        " SE2.E2_PREFIXO || '|' ||"
	cQryFrm +=                        " SE2.E2_NUM || '|' ||"
	cQryFrm +=                        " SE2.E2_PARCELA || '|' ||"
	cQryFrm +=                        " SE2.E2_TIPO || '|' ||"
	cQryFrm +=                        " SE2.E2_FORNECE || '|' ||"
	cQryFrm +=                        " SE2.E2_LOJA"
	cQryFrm +=   " AND FK7.FK7_ALIAS = 'SE2'"
	cQryFrm +=   " AND FK7.D_E_L_E_T_ = ' ')"
	cQryFrm +=  " LEFT JOIN " + RetSqlName("SED") + " SED"
	cQryFrm +=    " ON (SED.ED_CODIGO = SE2.E2_NATUREZ"
	cQryFrm +=   JSqlFilCom("SE2", "SED",,, "E2_FILIAL", "ED_FILIAL")
	cQryFrm +=   " AND SED.D_E_L_E_T_ = ' ')"
	cQryFrm +=  " LEFT JOIN (SELECT OHF_IDDOC, SUM(OHF_VALOR) VALOR"
	cQryFrm +=               " FROM " + RetSqlName("OHF")
	cQryFrm +=              " WHERE D_E_L_E_T_ = ' '"
	cQryFrm +=              " GROUP BY OHF_IDDOC) OHF"
	cQryFrm +=    " ON (OHF.OHF_IDDOC = FK7.FK7_IDDOC)"
	cQryFrm +=  " LEFT JOIN (SELECT OHG_IDDOC, SUM(OHG_VALOR) VALOR"
	cQryFrm +=               " FROM " + RetSqlName("OHG")
	cQryFrm +=              " WHERE D_E_L_E_T_ = ' '"
	cQryFrm +=              " GROUP BY OHG_IDDOC) OHG"
	cQryFrm +=    " ON (OHG.OHG_IDDOC = FK7.FK7_IDDOC)"
	cQryWhr := " WHERE SE2.D_E_L_E_T_ = ' '"

	For nI := 1 To Len(aFilFilt)
		cFilConcat += "'" + aFilFilt[nI] + "',"
	Next nI

	// Inclui as filiais que o usuário tem permissão
	If !Empty(cFilConcat) .And. aScan(aFiltros, { |x| x[1] == "E2_FILIAL"}) == 0
		cQryWhr += " AND SE2.E2_FILIAL IN (" + SubStr(cFilConcat,1, Len(cFilConcat)-1) + ")"
	EndIf

	// Loop para inputar os filtros
	For nI := 1 To Len(aFiltros)
		Do Case
			Case aFiltros[nI][1] == "E2_FORNECE"
				cQryWhr += " AND E2_FORNECE = '" + aFiltros[nI][2][1] + "'"
				cQryWhr += " AND E2_LOJA = '" + aFiltros[nI][2][2]+ "'"
			Case aFiltros[nI][1] == "E2_EMISSAO"
				cQryWhr += " AND E2_EMISSAO >= '" + aFiltros[nI][2][1] + "'"
				cQryWhr += " AND E2_EMISSAO <= '" + aFiltros[nI][2][2] + "'"
			Case aFiltros[nI][1] == "E2_VENCREA"
				cQryWhr += " AND E2_VENCREA >= '" + aFiltros[nI][2][1]+ "'"
				cQryWhr += " AND E2_VENCREA <= '" + aFiltros[nI][2][2] + "'"
			Case aFiltros[nI][1] == "E2_NATUREZ"
				cQryWhr += " AND E2_NATUREZ = '" + aFiltros[nI][2] + "'"
			Case aFiltros[nI][1] == "CONCTITULO"
				cQryWhr += " AND ( E2_PREFIXO || E2_NUM || E2_PARCELA LIKE '%" + StrTran(aFiltros[nI][2], "-","") + "%')"
			Case aFiltros[nI][1] == "E2_VALOR"
				cQryWhr += " AND E2_VALOR >= " + aFiltros[nI][2][1]
				cQryWhr += " AND E2_VALOR <= " + aFiltros[nI][2][2]
			Otherwise
				cQryWhr += " AND " + aFiltros[nI][1] + " = '" + aFiltros[nI][2] + "'"
		EndCase
	Next nI

	// Pesquisa rápida
	If !Empty(cSearchkey)
		cQryWhr += " AND " + setVlrPesq(cSearchkey) + " "
	EndIf

	// Intervalo de datas
	If !Empty(cDatas)
		cQryWhr += " AND (" + cDatas + ") "
	EndIf

	// Prefixos
	If Len(aPrefixos) > 0
		For nI := 1 To Len(aPrefixos)
			cPrefixos += IIF( !Empty(cPrefixos), ",'" + aPrefixos[nI] + "'", "'" + aPrefixos[nI] + "'")
		Next nI

		cQryWhr += " AND ( E2_PREFIXO IN (" + cPrefixos + ") ) "
	EndIf

	// CNAB
	If VALTYPE(oJsonBody['filtCNAB']) != "U"
		cQryWhr += "AND (" + oJsonBody['filtCNAB'] + ") "
	EndIf

	If !Empty(cFiltrExtras)
		
		cFiltrExtras := FuncReplace("RETSQLNAME(", cFiltrExtras)
		cFiltrExtras := FuncReplace("XFILIAL(", cFiltrExtras)

		cQryWhr += "AND (" + cFiltrExtras + ") "
	EndIf

	If (lPrefixo)
		cQryGrp += " GROUP BY " + cCpoCustom + " E2_PREFIXO "
	EndIf

	// Loop para a Ordenação da query a partir do que foi selecionado em tela
	If (!lPrefixo)
		For nI := 1 To Len(aOrder)
			cOrdConcat := aOrder[nI][1]
			If (cOrdConcat == "E2_NUM")
				cOrdConcat := " SE2.E2_PREFIXO || SE2.E2_NUM || SE2.E2_PARCELA "
			ElseIf (cOrdConcat == "E2_FORNECE-E2_LOJA")
				cOrdConcat := " SA2.A2_NOME"
			ElseIf (cOrdConcat == "E2_NATUREZ")
				cOrdConcat := " SED.ED_DESCRIC"
			EndIf

			If (aOrder[nI][2] == "D")
				cQryOrd += " " + cOrdConcat + " DESC,"
			else
				cQryOrd += " " + cOrdConcat + " ,"
			EndIf
		Next nI

		If (cQryOrd != "")
			cQryOrd := " ORDER BY " + SubStr(cQryOrd, 1, Len(cQryOrd)-1)
		Else
			cQryOrd := " ORDER BY SE2.E2_VENCREA DESC "
		EndIf
	EndIf

	aSize(aOrder, 0)
	aSize(aFiltros, 0)
	aSize(aPrefixos, 0)

Return cQrySel + cQryFrm + cQryWhr + cQryGrp + cQryOrd

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT SubTitPag
Realiza a substituição do Titulo

@example PUT -> http://127.0.0.1:9090/rest/WSPfsAppCP/subtitpag
@example BODY -> {
	"titulos": [
		{ "prefixo": "WPR", "numero": "WPR008", "parcela": "00",
		  "tipo": "PR", "fornecedor": "WYK","loja": "01" }
	],
	"novoTitulo": {
		"E2_PREFIXO": "WSB", "E2_NUM": "WSB004", "E2_PARCELA": "00", "E2_TIPO": "BOL",
		"E2_FORNECE": "WYK", "E2_LOJA": "01", "E2_NATUREZ": "PARTWYK", "E2_EMISSAO": "20200323",
		"E2_VENCTO": "20210301", "E2_VENCREA": "20210401", "E2_VALOR": 100000, "E2_HIST": "Incluso na substituição vai POSTMAN",
		"E2_SALDO": 90000, "E2_VLCRUZ": 100000, "E2_MOEDA": 1, "E2_TXMOEDA": 1, "AUTBANCO": "247", "AUTAGENCIA": "1546", "AUTCONTA": "15465666"
	}
}
@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT SubTitPag WSREST WSPfsAppCP
Local oReqBody     := Nil
Local oLinhaTit    := Nil
Local nI           := 0
Local lRet         := .T.
Local aDadosTitulo := {}
Local aTitulos     := {}
Local aNovoTitulo  := {}
Local cBody        := ""

Private lMsErroAuto          := .F.
Private lAutoErrNoFile       := .T.

	cBody := StrTran(Self:GetContent(),CHR(10),"")
	FWJsonDeserialize(cBody,@oReqBody)

	If '"novoTitulo":' $ cBody
		oLinhaTit := oReqBody:novoTitulo
		AAdd(aNovoTitulo , {"E2_FILIAL"  , xFilial("SE2")                                                                              , Nil})
		AAdd(aNovoTitulo , {"E2_PREFIXO" , gtValJSON(oLinhaTit     , "E2_PREFIXO"     , cBody, ""            , TamSx3("E2_PREFIXO")[1] ), Nil})
		AAdd(aNovoTitulo , {"E2_NUM"     , gtValJSON(oLinhaTit     , "E2_NUM"         , cBody, ""            , TamSx3("E2_NUM")[1]     ), Nil})
		AAdd(aNovoTitulo , {"E2_PARCELA" , gtValJSON(oLinhaTit     , "E2_PARCELA"     , cBody, ""            , TamSx3("E2_PARCELA")[1] ), Nil})
		AAdd(aNovoTitulo , {"E2_TIPO"    , gtValJSON(oLinhaTit     , "E2_TIPO"        , cBody, ""            , TamSx3("E2_TIPO")[1]    ), Nil})
		AAdd(aNovoTitulo , {"E2_FORNECE" , gtValJSON(oLinhaTit     , "E2_FORNECE"     , cBody, ""            , TamSx3("E2_FORNECE")[1] ), Nil})
		AAdd(aNovoTitulo , {"E2_LOJA"    , gtValJSON(oLinhaTit     , "E2_LOJA"        , cBody, ""            , TamSx3("E2_LOJA")[1]    ), Nil})
		AAdd(aNovoTitulo , {"E2_NATUREZ" , gtValJSON(oLinhaTit     , "E2_NATUREZ"     , cBody, ""            , TamSx3("E2_NATUREZ")[1] ), Nil})
		AAdd(aNovoTitulo , {"E2_EMISSAO" , SToD(gtValJSON(oLinhaTit, "E2_EMISSAO"     , cBody, DTOS(Date()))                           ), Nil})
		AAdd(aNovoTitulo , {"E2_VENCTO"  , SToD(gtValJSON(oLinhaTit, "E2_VENCTO"      , cBody, DTOS(Date()))                           ), Nil})
		AAdd(aNovoTitulo , {"E2_VENCREA" , SToD(gtValJSON(oLinhaTit, "E2_VENCREA"     , cBody, DTOS(Date()))                           ), Nil})
		AAdd(aNovoTitulo , {"E2_VALOR"   , gtValJSON(oLinhaTit     , "E2_VALOR"       , cBody, 0                                       ), Nil})
		AAdd(aNovoTitulo , {"E2_HIST"    , gtValJSON(oLinhaTit     , "E2_HIST"        , cBody, ""            , TamSx3("E2_HIST")[1]    ), Nil})
		AAdd(aNovoTitulo , {"E2_SALDO"   , gtValJSON(oLinhaTit     , "E2_SALDO"       , cBody, 0                                       ), Nil})
		AAdd(aNovoTitulo , {"E2_MOEDA"   , gtValJSON(oLinhaTit     , "E2_MOEDA"       , cBody, 1                                       ), Nil})
		AAdd(aNovoTitulo , {"E2_VLCRUZ"  , gtValJSON(oLinhaTit     , "E2_VLCRUZ"      , cBody, 0                                       ), Nil})
		AAdd(aNovoTitulo , {"E2_TXMOEDA" , gtValJSON(oLinhaTit     , "E2_TXMOEDA"     , cBody, 0                                       ), Nil})
		AAdd(aNovoTitulo , {"E2_CODAPRO" , gtValJSON(oLinhaTit     , "E2_CODAPRO"     , cBody, ""            , TamSx3("E2_CODAPRO")[1] ), Nil})

		oLinhaTit := Nil
	EndIf

	//MSExecAuto({|a,b,c| FINA050(a,b,c)}, aTitulo, Nil, 8) //Efetua a operacao
	If '"titulos":' $ cBody
		For nI := 1 to Len(oReqBody:Titulos)
			oLinhaTit := oReqBody:Titulos[nI]
			aAdd(aDadosTitulo, {"E2_PREFIXO", gtValJSON(oLinhaTit , "prefixo"     , cBody, ""  , TamSx3("E2_PREFIXO")[1] ), Nil})
			aAdd(aDadosTitulo, {"E2_NUM"    , gtValJSON(oLinhaTit , "numero"      , cBody, ""  , TamSx3("E2_NUM")[1] )    , Nil})
			aAdd(aDadosTitulo, {"E2_PARCELA", gtValJSON(oLinhaTit , "parcela"     , cBody, ""  , TamSx3("E2_PARCELA")[1] ), Nil})
			aAdd(aDadosTitulo, {"E2_TIPO"   , gtValJSON(oLinhaTit , "tipo"        , cBody, ""  , TamSx3("E2_TIPO")[1] )   , Nil})
			aAdd(aDadosTitulo, {"E2_FORNECE", gtValJSON(oLinhaTit , "fornecedor"  , cBody, ""  , TamSx3("E2_FORNECE")[1] ), Nil})
			aAdd(aDadosTitulo, {"E2_LOJA"   , gtValJSON(oLinhaTit , "loja"        , cBody, ""  , TamSx3("E2_LOJA")[1] )   , Nil})

			oLinhaTit := Nil
			aAdd(aTitulos, aClone(aDadosTitulo))
			aSize(aDadosTitulo, 0)
		Next nI

		DbSelectArea("SE2")
		SE2->( DbSetOrder(1) )
		If Len(aNovoTitulo) > 0 .And. ;
				Len(aTitulos) > 0 .And. ;
				SE2->( DbSeek( xFilial("SE2") + aTitulos[1][1][2] + aTitulos[1][2][2] + aTitulos[1][3][2] + aTitulos[1][4][2] + aTitulos[1][5][2] + aTitulos[1][6][2] ))
			MSExecAuto({|a,b,c,d,e,f,g,h,i,j| FINA050(a,b,c,d,e,f,g,h,i,j)},aNovoTitulo,,6,,,,,,aTitulos)
		EndIf

		If lMsErroAuto
			lRet := setRespError(500, STR0031) //"Ocorreu um erro durante a substituição do Titulo a pagar"
		EndIf
	EndIf

	If lRet
		Self:SetResponse(getRespOk("SubstituirTituloPagar"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT - AltTitPag
Alteraçaõ de Titulo a pagar
@example PUT  -> http://localhost:12173/rest/WSPfsAppCP/titpag/{recnoTitulo}
@example Body ->
	{ "E2_VALOR": 200000, "E2_HIST": "Teste de alteração via POSTMAN",
	  "E2_SALDO": 120000, "E2_MOEDA": 2 }
@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD PUT AltTitPag PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local lRet         := .T.
Local aDadosTitulo := {}
Local aTitulo      := {}
Local aJsonExtra   := {}
Local cBody        := ""
Local cRecno       := ""
Local nIndex       := 0
Local aCmpsChave   := {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA", "E2_TIPO", "E2_FORNECE", "E2_LOJA"}
Local aExtCampos   := {"E2_NATUREZ","E2_EMISSAO","E2_VENCTO","E2_VENCREA","E2_VALOR","E2_HIST","E2_SALDO","E2_MOEDA","E2_VLCRUZ","E2_TXMOEDA","E2_CODAPRO"}
Local oJson        := JsonObject():new()
Local nI           := 0
Local cErroGRLog   := ""
Local cMsgError    := STR0032 // "Ocorreu um erro durante a alteração do Titulo a pagar"
Local itensJson
Local retJson

Private lMsErroAuto          := .F.
Private lAutoErrNoFile       := .T.

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1, aExtCampos)
	cBody := Self:GetContent()
	if (!Empty(cBody) .AND. cBody != "{}")
		retJson := oJson:fromJson(DecodeUTF8(cBody))
		itensJson := oJson:GetNames()

		DbSelectArea("SE2")
		SE2->( DbSetOrder(1) )
		If Len(aDadosTitulo) > 0 .And. SE2->(dbSeek(aDadosTitulo[1][1][2]))

			// Essa parte não passa por alteração por conta da Chave da Tabela ( X2_UNICO )
			If (nIndex := aScan(aDadosTitulo[1], {|x| x[1] == "E2_FILIAL" })) > 0
				AAdd(aTitulo , {"E2_FILIAL" , aDadosTitulo[1][nIndex][2], Nil})
			EndIf
			If (nIndex := aScan(aDadosTitulo[1], {|x| x[1] == "E2_PREFIXO" })) > 0
				AAdd(aTitulo , {"E2_PREFIXO" , aDadosTitulo[1][nIndex][2], Nil})
			EndIf
			If (nIndex := aScan(aDadosTitulo[1], {|x| x[1] == "E2_NUM" })) > 0
				AAdd(aTitulo , {"E2_NUM" , aDadosTitulo[1][nIndex][2], Nil})
			EndIf
			If (nIndex := aScan(aDadosTitulo[1], {|x| x[1] == "E2_PARCELA" })) > 0
				AAdd(aTitulo , {"E2_PARCELA" , aDadosTitulo[1][nIndex][2], Nil})
			EndIf
			If (nIndex := aScan(aDadosTitulo[1], {|x| x[1] == "E2_TIPO" })) > 0
				AAdd(aTitulo , {"E2_TIPO" , aDadosTitulo[1][nIndex][2], Nil})
			EndIf
			If (nIndex := aScan(aDadosTitulo[1], {|x| x[1] == "E2_FORNECE" })) > 0
				AAdd(aTitulo , {"E2_FORNECE" , aDadosTitulo[1][nIndex][2], Nil})
			EndIf
			If (nIndex := aScan(aDadosTitulo[1], {|x| x[1] == "E2_LOJA" })) > 0
				AAdd(aTitulo , {"E2_LOJA" , aDadosTitulo[1][nIndex][2], Nil})
			EndIf

			For nI := 1 To Len(itensJson)
				Do Case
					Case itensJson[nI] == "E2_LINDIG"
						If !Empty(oJson[itensJson[nI]])
							lRet := VldCodBar(CvJsonVal(oJson[itensJson[nI]], TamSx3(itensJson[nI])))
							If !lRet
								cMsgError := STR0074 //"Valor da linha digitavel não é valida!"
							EndIf
						EndIf
				End Case


				If (aScan(aCmpsChave, itensJson[nI]) == 0)
					AAdd(aTitulo , {itensJson[nI] , CvJsonVal(oJson[itensJson[nI]], TamSx3(itensJson[nI])) , Nil})
				EndIf
			Next nI

			If ( lRet )
				MSExecAuto({|a,b,c| FINA050(a,b,c)}, aTitulo, Nil, 4) //Efetua a operacao

				If (lMsErroAuto)
					aEval(GetAutoGRLog(), {|l| cErroGRLog += l + "|APP_CP_PFS|"})

					If !Empty(cErroGRLog)
						cMsgError := Left(cErroGRLog, At('|APP_CP_PFS|', cErroGRLog) - 1)
					EndIf

					lRet := setRespError(500, cMsgError)
				EndIf
			Else
				lRet := setRespError(400, cMsgError)
			EndIf
		Else
			lRet := setRespError(404, STR0033) //  "O titulo não foi encontrado!"
		EndIf
	EndIf

	If lRet
		extSE2ByPk(aTitulo, @cRecno)
		aAdd(aJsonExtra, {"Recno", cRecno})

		cCodigoTitulo := SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
		cCodigoTitulo := Encode64(cCodigoTitulo)
		aAdd(aJsonExtra, {"PkTitulo", cCodigoTitulo })

		aAdd(aJsonExtra, {"ValorBrutoSE2", JCPVlBruto(cRecno)})

		Self:SetResponse(getRespOk("AlterarTituloPagar", aJsonExtra))
		aSize(aJsonExtra, 0)
		oJson:FromJSon("{}")
		oJson := Nil
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PUT - BaixaTitulo
Baixa de titulos do Pagar
@example PUT  -> http://localhost:12173/rest/WSPfsAppCP/titbai/{recnoTitulo}
@example Body ->
	{ "MotivoBaixa": "DACAO", "HistoricoBaixa": "Baixa via POSTMAN" }

@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST BaixaTitulo PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local cBody        := Self:GetContent()
Local oReqBody     := Nil
Local aDadosTitulo := {}
Local aErrGrAuto   := {}
Local aBaixa       := {}
Local cTipoMotivo  := ""
Local cHistBaixa   := ""
Local cAliasDb     := ""
Local cFKTitulo    := getFKTitulo(Self:recnoTitulo)
Local lRet         := .T.
Local nCodHttp     := 0
Local cBanco       := ""
Local aInfoBanco   := {}
Local nQtdEspBnc   := TamSx3("A6_COD")[1]
Local nQtdEspAge   := TamSx3("A6_AGENCIA")[1]
Local nQtdEspCnt   := TamSx3("A6_NUMCON")[1]

Private lF080Auto       := .T.
Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1)

	FWJsonDeserialize(cBody,@oReqBody)

	cTipoMotivo := gtValJSON(oReqBody, "MotivoBaixa"         , cBody)
	cHistBaixa  := gtValJSON(oReqBody, "HistoricoBaixa"      , cBody)
	cBanco      := gtValJSON(oReqBody, "Banco"               , cBody, "")
	cValDesc    := gtValJSON(oReqBody, "ValorDesconto"       , cBody, 0)
	cValMulta   := gtValJSON(oReqBody, "ValorMulta"          , cBody, 0)
	cValJuros   := gtValJSON(oReqBody, "ValorJuros"          , cBody, 0)
	cValPagto   := gtValJSON(oReqBody, "ValorPagto"          , cBody, 0)
	cValEstrg   := gtValJSON(oReqBody, "ValorConvertido"     , cBody, 0)

	cBanco := strTran(cBanco, "-", ",")
	aInfoBanco := Iif(!empty(cBanco),strTokArr(cBanco, ","), {})

	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	if SE2->( dbSeek(aDadosTitulo[1][1][2]))
		aAdd(aBaixa,{"E2_PREFIXO" , aDadosTitulo[1][3][2]    ,Nil})
		aAdd(aBaixa,{"E2_NUM"     , aDadosTitulo[1][4][2]    ,Nil})
		aAdd(aBaixa,{"E2_PARCELA" , aDadosTitulo[1][5][2]    ,Nil})
		aAdd(aBaixa,{"E2_TIPO"    , aDadosTitulo[1][6][2]    ,Nil})
		aAdd(aBaixa,{"E2_FORNECE" , aDadosTitulo[1][7][2]    ,Nil})
		aAdd(aBaixa,{"E2_LOJA"    , aDadosTitulo[1][8][2]    ,Nil})
		aAdd(aBaixa,{"AUTMOTBX"   , cTipoMotivo     ,Nil}) //"Tipo motivo, ex: DACAO"
		aAdd(aBaixa,{"AUTHIST"    , cHistBaixa      ,Nil}) //"Baixa Automatica"
		If Len(aInfoBanco) > 0
			aAdd(aBaixa,{"AUTBANCO"   , PadL(aInfoBanco[1] + Space(nQtdEspBnc), nQtdEspBnc),Nil}) //"Banco"
			aAdd(aBaixa,{"AUTAGENCIA" , PadL(aInfoBanco[2] + Space(nQtdEspAge), nQtdEspAge),Nil}) //"Agencia"
			aAdd(aBaixa,{"AUTCONTA"   , PadL(aInfoBanco[3] + Space(nQtdEspCnt), nQtdEspCnt),Nil}) //"Conta"
		EndIf
		aAdd(aBaixa,{"AUTDESCONT" , cValDesc        ,Nil})
		aAdd(aBaixa,{"AUTMULTA"   , cValMulta       ,Nil})
		aAdd(aBaixa,{"AUTJUROS"   , cValJuros       ,Nil})
		aAdd(aBaixa,{"AUTVLRME"   , cValEstrg       ,Nil})

		lRet := MSExecAuto({| a,b,c,d,e,f | FINA080(a,b,c,d,e,f)} ,aBaixa,3,,,,)//3 para baixar ou 5 para cancelar a baixa.

		If lRet .And. !lMsErroAuto
			cAliasDb := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,qryFK2(cFKTitulo)), cAliasDb, .F., .T.)

			If (cAliasDb)->( !Eof() )
				If (cAliasDb)->FK2_RECPAG != "P"
					nCodHttp := 500
					lRet := .F.
				EndIf
			Else
				nCodHttp := 500
				lRet := .F.
			EndIf

			(cAliasDb)->( DbCloseArea() )
		else
			nCodHttp := 500
			lRet := .F.
		EndIf
	Else
		nCodHttp := 404
		lRet := .F.
	EndIf

	If lRet
		Self:SetResponse(getRespOk("BaixaTitulo"))
	Else
		aErrGrAuto := GetAutoGrLog()
		Do Case
			Case nCodHttp == 404
				lRet :=  setRespError(nCodHttp, STR0033) //  "O titulo não foi encontrado!"
			Case nCodHttp == 500
				If Len(aErrGrAuto) > 0
					lRet := setRespError(nCodHttp, aErrGrAuto[1])
				Else
					lRet := setRespError(nCodHttp, STR0090) //"Houve problema na baixa do Titulo selecionado!"
				EndIf
		End Case
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST - CrtTitPag
Desdobramento de Titulo - Transitória de Pós-Pagamento
@example POST  -> http://localhost:12173/rest/WSPfsAppCP/titpag
@example Body ->
{
	"E2_FORNECE": "WYK000",
	"E2_LOJA": "01",
	"E2_PREFIXO": "WTTS",
	"E2_NUM": "WTT003",
	"E2_PARCELA": "00",
	"E2_TIPO": "FOL",
	"E2_NATUREZ": "20.010.001",
	"E2_EMISSAO": "20200401",
	"E2_VENCTO": "20200401",
	"E2_VENCREA": "20200401",
	"E2_VALOR": 1000000,
	"E2_HIST": "Inclusão de Titulo a Pagar com Natureza Transitória",
	"E2_SALDO": 1000000,
	"E2_MOEDA": 1,
	"E2_VLCRUZ": 1000000,
	"E2_TXMOEDA": 0,
	"E2_CODAPRO": ""
}

@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST CrtTitPag  WSREST WSPfsAppCP
Local cBody         := ""
Local lRet          := .T.
Local aTitulo       := {}
Local aValid        := {}
Local oJson         := JsonObject():new()
Local nI            := 0
Local aJsonExtra    := {}
Local cRecno        := ""
Local cCodigoTitulo := ""
Local cHist         := ""
Local itensJson
Local retJson

Private lMsErroAuto := .F.
Private lMSHelpAuto := .F. // para nao mostrar os erro na tela

	cBody := DecodeUTF8(Self:GetContent())

	retJson := oJson:fromJson((cBody))
	itensJson := oJson:GetNames()

	AAdd(aTitulo , {"E2_FILIAL"  , xFilial("SE2") , Nil})
	For nI := 1 To Len(itensJson)
		If (itensJson[nI] == "E2_HIST")
			cHist := CvJsonVal(oJson[itensJson[nI]], TamSx3(itensJson[nI]))
			AAdd(aTitulo , {itensJson[nI] , cHist , Nil})
		else
			AAdd(aTitulo , {itensJson[nI] , CvJsonVal(oJson[itensJson[nI]], TamSx3(itensJson[nI])) , Nil})
		EndIf
	Next nI

	aValid := vldCrtTit(aTitulo)
	If aValid[1]
		MSExecAuto({|a,b,c| FINA050(a,b,c)}, aTitulo, Nil, 3) //Efetua a operacao

		If (lMsErroAuto)
			lRet := setRespError(500, STR0035) //"Ocorreu um erro durante a criação do Titulo a pagar"
		EndIf
	else
		lRet := setRespError(400, aValid[2])
	EndIf

	lRet := aValid[1] .And. !lMsErroAuto
	If lRet
		extSE2ByPk(aTitulo, @cRecno)
		aAdd(aJsonExtra, {"Recno", cRecno})

		cCodigoTitulo := SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA
		cCodigoTitulo := Encode64(cCodigoTitulo)
		aAdd(aJsonExtra, {"PkTitulo", cCodigoTitulo })

		aAdd(aJsonExtra, {"ValorBrutoSE2", JCPVlBruto(cRecno)})
		Self:SetResponse(getRespOk("CriarTituloPagar", aJsonExtra))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST - LiberaManu
Liberação de Titulos para pagamento - Em lote
@example POST  -> http://localhost:12173/rest/WSPfsAppCP/libpagmanual
@example Body ->
{
	"titulo": {
		"recno":[
			201,200,199
		]
	}
}

@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST LiberaManu WSREST WSPfsAppCP
Local aTitulo       := {}
Local aDadosTitulo  := {}
Local oReqBody      := Nil
Local cBody         := ""
Local nI            := 0
Local nCodHttp      := 0
Local lAuto         := .T.
Local lRet          := .T.

//-- Variáveis utilizadas para o controle de erro da rotina automática
Private lMsErroAuto        := .F.
Private lAutoErrNoFile    := .T.
	cBody := Self:GetContent()
	FWJsonDeserialize(cBody,@oReqBody)

	aDadosTitulo := gtDadoByRC(oReqBody:titulo:recno)

	SE2->( dbSetOrder(1) ) // E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_FORNECE + E2_LOJA
	For nI := 1 To Len(aDadosTitulo)
		aAdd(aTitulo,{aDadosTitulo[nI][aScan(aDadosTitulo[nI], {|x| x[1] == "E2_PREFIXO"})][2],  ;//Prefixo
			aDadosTitulo[nI][aScan(aDadosTitulo[nI], {|x| x[1] == "E2_NUM"})][2],      ;//Numero Titulo
			aDadosTitulo[nI][aScan(aDadosTitulo[nI], {|x| x[1] == "E2_PARCELA"})][2],  ;//Parcela
			aDadosTitulo[nI][aScan(aDadosTitulo[nI], {|x| x[1] == "E2_TIPO"})][2],     ;//Tipo
			aDadosTitulo[nI][aScan(aDadosTitulo[nI], {|x| x[1] == "E2_FORNECE"})][2],  ;//Fornecedor
			aDadosTitulo[nI][aScan(aDadosTitulo[nI], {|x| x[1] == "E2_LOJA"})][2]}     )//Loja

		// Posiciona no Registro para poder realizar a liberação
		If SE2->( dbSeek( aDadosTitulo[nI][1][2] ) ) .And. Empty(SE2->E2_DATALIB)
			MSExecAuto({|x,y,z,k,a| FA580MAN(x,y,z,k,a)},"SE2", aDadosTitulo[nI][aScan(aDadosTitulo[nI], {|x| x[1] == "Recno"})][2], 2, lAuto, aClone(aTitulo))
		EndIf

		aSize(aTitulo, 0)
		If lMsErroAuto
			lRet := setRespError(nCodHttp, STR0036) //"Houve um problema durante a liberação dos Titulos selecionados!"
		EndIf
	Next nI

	If lRet
		Self:SetResponse(getRespOk("LiberacaoPagto"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST - ChqSTitulo
Criação de Cheque sem Titulo
@example POST  -> http://localhost:12173/rest/WSPfsAppCP/chequesemtitulo/{recnoTitulo}
@example Body ->
{
  "AUTBANCO": "247",
  "AUTAGENCIA": "1546 ",
  "AUTCONTA": "15465666  ",
  "AUTCHEQUE": "232134324231421",
  "AUTVENCINI": "20200316",
  "AUTVENCFIM": "20200326",
  "AUTFORN": "WYK000",
  "AUTBENEF": "WILLIAN",
  "AUTNATUREZA": "PARTWYK   ",
  "AUTHIST": "TESTE DE CHEQUE"
}

@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST ChqSTitulo PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local aRetAuto      := {}
Local aDadosTitulo  := {}
Local oReqBody      := Nil
Local cBody         := ""
Local lRet          := .T.

//-- Variáveis utilizadas para o controle de erro da rotina automática
Private lMsErroAuto        := .F.
Private lAutoErrNoFile    := .T.
//Private nValor          := 0

	cBody := Self:GetContent()
	FWJsonDeserialize(cBody,@oReqBody)

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo)
	DbSelectArea("SE2")
	SE2->( dbSetOrder(1) )
	If Len(aDadosTitulo) > 0 .And. ;
			SE2->( dbSeek( aDadosTitulo[1][1][2] ) )

		aRetAuto := Array(0)
		//nValor := gtValJSON(oReqBody , "AUTVALOR"   , cBody, 0            , TamSx3("E5_VALOR")[1]     )
		aAdd(aRetAuto,{"AUTBANCO"   ,      gtValJSON(oReqBody , "AUTBANCO"   , cBody, ""           , TamSx3("E5_BANCO")[1]     )}) //"Banco"
		aAdd(aRetAuto,{"AUTAGENCIA" ,      gtValJSON(oReqBody , "AUTAGENCIA" , cBody, ""           , TamSx3("E5_AGENCIA")[1]   )}) //"Agencia"
		aAdd(aRetAuto,{"AUTCONTA"   ,      gtValJSON(oReqBody , "AUTCONTA"   , cBody, ""           , TamSx3("E5_CONTA")[1]     )}) //"Conta"
		aAdd(aRetAuto,{"AUTCHEQUE"  ,      gtValJSON(oReqBody , "AUTCHEQUE"  , cBody, ""           , TamSx3("E5_NUMCHEQ")[1]   )}) //"Cheque"
		aAdd(aRetAuto,{"AUTVENCINI" , SToD(gtValJSON(oReqBody , "AUTVENCINI" , cBody, DToS(Date()) , TamSx3("E5_DATA")[1])     )}) //"Dt Inicio"
		aAdd(aRetAuto,{"AUTVENCFIM" , SToD(gtValJSON(oReqBody , "AUTVENCFIM" , cBody, DToS(Date()) , TamSx3("E5_DATA")[1])     )}) //"Dt Fim"
		aAdd(aRetAuto,{"AUTFORN"    ,      gtValJSON(oReqBody , "AUTFORN"    , cBody, ""           , TamSx3("E5_CLIFOR")[1]    )}) //"Fornecedor"
		aAdd(aRetAuto,{"AUTBENEF"   ,      gtValJSON(oReqBody , "AUTBENEF"   , cBody, ""           , 0                         )}) //"Benefici"
		aAdd(aRetAuto,{"AUTNATUREZA",      gtValJSON(oReqBody , "AUTNATUREZA", cBody, ""           , TamSx3("E5_NATUREZ")[1]   )}) //"Natureza"
		//aAdd(aRetAuto,{"AUTVALOR",nValor}) //"Valor"

		//|-------------------------|
		//| COMMIT DA FUNÇÃO        |
		//|-------------------------|
		MSExecAuto({|a,b,c|FINA390(a,b,c)},,aRetAuto,2)

		If lMsErroAuto
			lRet := setRespError(500, STR0037) //"Erro ao gerar o cheque para o título selecionado!"
		EndIf
	EndIf

	If lRet
		Self:SetResponse(getRespOk("ChqueSemTitulo"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST - BxAutTit
Baixa automática de titulos
@example POST  -> http://localhost:12173/rest/WSPfsAppCP/titautbai
@example Body ->
{
  "recnoTitulos": [
	95,95,96,97,93
  ],
  "codBanco": "247",
  "codAgencia": "1546 ",
  "codConta": "15465666  ",
  "numCheque": "",
  "loteFin": "",
  "codNatureza": "02.020.001",
  "dataBaixa": "20200319"
}

@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST BxAutTit WSREST WSPfsAppCP
Local cBody := Self:GetContent()
Local oReqBody := Nil
Local lRet     := .T.
Local nCodHttp := 0
Local aRecnos  := {}
Local cBanco   := ""
Local cAgencia := ""
Local cConta   := ""
Local cCheque  := ""
Local cLoteFin := ""
Local cNaturez := ""
Local dBaixa   := Date()

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

	FWJsonDeserialize(cBody,@oReqBody)

	aRecnos   := gtValJSON(oReqBody, "recnoTitulos"        , cBody)
	cBanco    := gtValJSON(oReqBody, "codBanco"            , cBody)
	cAgencia  := gtValJSON(oReqBody, "codAgencia"          , cBody, "", 5 )
	cConta    := gtValJSON(oReqBody, "codConta"            , cBody, "", 10)
	cCheque   := gtValJSON(oReqBody, "numChque"            , cBody, "", 15)
	cLoteFin  := gtValJSON(oReqBody, "codBanco"            , cBody, "", 4 )
	cNatureza := gtValJSON(oReqBody, "codBanco"            , cBody, "", 10)
	dBaixa    := SToD(gtValJSON(oReqBody, "codBanco"       , cBody, DTOS(Date())))

	If Len(aRecnos) > 0
		lRet := FBxLotAut("SE2",aRecnos,cBanco,cAgencia,cConta,cCheque,cLoteFin,cNaturez,dBaixa)

		// Verifica se o titulo foi baixado
		If !(lRet .And. checkTitulo(aRecnos))
			lRet := setRespError(nCodHttp, STR0038) //"Houve um erro no processo de Baixa automática dos titulos selecionados!"

		EndIf
	Else
		lRet := setRespError(nCodHttp, STR0039) //"Os titulos a serem baixados não foram informados!"
	EndIf

	If lRet
		Self:SetResponse(getRespOk("BaixaAutomaticaTitulos"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Titulo
Exclusão do titulo

@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE Titulo PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local lRet         := .T.
Local aTitulo      := {}
Local nCodHttp     := 0
Local aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1)

Private lF080Auto       := .T.
Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	if Len(aDadosTitulo) > 0 .And. ;
			SE2->( dbSeek(aDadosTitulo[1][1][2]))
		aAdd(aTitulo, {"E2_PREFIXO" , aDadosTitulo[1][3][2] ,Nil})
		aAdd(aTitulo, {"E2_NUM"     , aDadosTitulo[1][4][2] ,Nil})
		aAdd(aTitulo, {"E2_PARCELA" , aDadosTitulo[1][5][2] ,Nil})
		aAdd(aTitulo, {"E2_TIPO"    , aDadosTitulo[1][6][2] ,Nil})
		aAdd(aTitulo, {"E2_FORNECE" , aDadosTitulo[1][7][2] ,Nil})
		aAdd(aTitulo, {"E2_LOJA"    , aDadosTitulo[1][8][2] ,Nil})
		MSExecAuto({|a,b,c| FINA050(a,b,c)}, aTitulo, Nil, 5) //Efetua a operacao

		If (lMsErroAuto)
			lRet := setRespError(nCodHttp, STR0040) // "Ocorreu um erro durante a exclusão do Titulo a pagar"
		EndIf
	Else
		lRet := setRespError(nCodHttp, STR0033) //  "O titulo não foi encontrado!"
	EndIf

	If lRet
		Self:SetResponse(getRespOk("ExcluirTituloPagar"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Exclusão de Baixa

@example http://localhost:12173/rest/WSPfsAppCP/titexc/{recnoTitulo}
@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE ExcluiBaixa PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local aDadosTitulo := {}
Local aErrGrAuto   := {}
Local aBaixa       := {}
Local cAliasDb     := ""
Local cFKTitulo    := getFKTitulo(Self:recnoTitulo)
Local lRet         := .T.
Local nCodHttp     := 0

Private lF080Auto       := .T.
Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1)
	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	If Len(aDadosTitulo) > 0 .And. ;
			SE2->( dbSeek(aDadosTitulo[1][1][2]))
		AADD(aBaixa, {"E2_PREFIXO" , aDadosTitulo[1][3][2]    ,Nil})
		AADD(aBaixa, {"E2_NUM"     , aDadosTitulo[1][4][2]    ,Nil})
		AADD(aBaixa, {"E2_PARCELA" , aDadosTitulo[1][5][2]    ,Nil})
		AADD(aBaixa, {"E2_TIPO"    , aDadosTitulo[1][6][2]    ,Nil})
		AADD(aBaixa, {"E2_FORNECE" , aDadosTitulo[1][7][2]    ,Nil})
		AADD(aBaixa, {"E2_LOJA"    , aDadosTitulo[1][8][2]    ,Nil})

		MSExecAuto({| a,b,c,d,e,f | FINA080(a,b,c,d,e,f)} ,aBaixa,6,,,,)//3 para baixar ou 5 para cancelar a baixa.

		If lRet .And. !lMsErroAuto
			cAliasDb := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,qryFK2(cFKTitulo)), cAliasDb, .F., .T.)

			If (cAliasDb)->( !Eof() )
				If (cAliasDb)->FK2_RECPAG != "R"
					nCodHttp := 500
					lRet := .F.
				EndIf
			Else
				nCodHttp := 500
				lRet := .F.
			EndIf

			(cAliasDb)->( DbCloseArea() )
		Else
			nCodHttp := 500
			lRet := .F.
		EndIf
	Else
		nCodHttp := 404
		lRet := .F.
	EndIf
	If lRet
		Self:SetResponse(getRespOk("ExclusaoBaixa"))
	Else
		aErrGrAuto := GetAutoGrLog()
		Do Case
			Case nCodHttp == 404
				lRet := setRespError(nCodHttp, STR0033) //  "O titulo não foi encontrado!"
			Case nCodHttp == 500
				If Len(aErrGrAuto) > 0
					lRet := setRespError(nCodHttp, aErrGrAuto[1])
				Else
					lRet := setRespError(nCodHttp, STR0041) //"Houve problema na Exclusão da baixa do Titulo selecionado!"
				EndIf
		End Case
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Cancelamento de Baixa

@example http://localhost:12173/rest/WSPfsAppCP/titcan/{recnoTitulo}
@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE CancelaBaixa PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local aDadosTitulo := {}
Local aErrGrAuto   := {}
Local aBaixa       := {}
Local cAliasDb     := ""
Local cFKTitulo    := getFKTitulo(Self:recnoTitulo)
Local lRet         := .T.
Local nCodHttp     := 0

Private lF080Auto       := .T.
Private lMsErroAuto     := .F.
Private lAutoErrNoFile  := .T.

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1)
	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	if SE2->( dbSeek(aDadosTitulo[1][1][2]))
		AADD(aBaixa,{"E2_PREFIXO" , aDadosTitulo[1][3][2]    ,Nil})
		AADD(aBaixa,{"E2_NUM"     , aDadosTitulo[1][4][2]    ,Nil})
		AADD(aBaixa,{"E2_PARCELA" , aDadosTitulo[1][5][2]    ,Nil})
		AADD(aBaixa,{"E2_TIPO"    , aDadosTitulo[1][6][2]    ,Nil})
		AADD(aBaixa,{"E2_FORNECE" , aDadosTitulo[1][7][2]    ,Nil})
		AADD(aBaixa,{"E2_LOJA"    , aDadosTitulo[1][8][2]    ,Nil})

		MSExecAuto({| a,b,c,d,e,f | FINA080(a,b,c,d,e,f)} ,aBaixa,5,,,,)//3 para baixar ou 5 para cancelar a baixa.

		If lRet .And. !lMsErroAuto
			cAliasDb := GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,qryFK2(cFKTitulo)), cAliasDb, .F., .T.)

			If (cAliasDb)->( !Eof() )
				If (cAliasDb)->FK2_RECPAG != "R"
					nCodHttp := 500
					lRet := .F.
				EndIf
			Else
				nCodHttp := 500
				lRet := .F.
			EndIf

			(cAliasDb)->( DbCloseArea() )
		Else
			nCodHttp := 500
			lRet := .F.
		EndIf
	Else
		nCodHttp := 404
		lRet := .F.
	EndIf

	If lRet
		Self:SetResponse(getRespOk("CancelamentoBaixa"))
	Else
		aErrGrAuto := GetAutoGrLog()
		Do Case
			Case nCodHttp == 404
				lRet := setRespError(nCodHttp, STR0033) //  "O titulo não foi encontrado!"
			Case nCodHttp == 500
				If Len(aErrGrAuto) > 0
					lRet := setRespError(nCodHttp, aErrGrAuto[1])
				Else
					lRet := setRespError(nCodHttp, STR0034) //"Houve problema no Cancelamento da baixa do Titulo selecionado!"
				EndIf
		End Case
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Borderô
Exclusão de Borderô

@example http://localhost:12173/rest/WSPfsAppCP/canbrd/{ChaveBordero}
@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE Bordero PATHPARAM ChaveBordero WSREST WSPfsAppCP
Local codBord  := Self:ChaveBordero
Local lRet     := .T.

	If vrBordero(codBord, "FINA240")
		SetMVValue("AFI240","MV_PAR01",codBord)
		FA240Canc()

		If vrBordero(codBord, "FINA240")
			lRet := setRespError(500, STR0042) //"Não foi possível excluir o borderô!"
		EndIf
	Else
		lRet := setRespError(404, STR0043) //"O borderô não foi encontrado! Verifique o numero digitado ou já não foi cancelado anteriormente!"
	EndIf

	If lRet
		Self:SetResponse(getRespOk("ExclusaoBordero"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Cancelamento de Bordero Impostos

@example http://localhost:12173/rest/WSPfsAppCP/canbrdimp/{ChaveBordero}
@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE IBordero PATHPARAM ChaveBordero WSREST WSPfsAppCP


	If vrBordero(codBord, "FINA241")
		SetMVValue("AFI240","MV_PAR01",codBord)
		FA241Canc(/*cAlias*/,/*nReg*/,/*nOpcx*/,/*aBorAut*/,.T.)

		If vrBordero(codBord, "FINA241")
			lRet := setRespError(500, STR0044) // "Não foi possível excluir o borderô de impostos!"
		EndIf
	Else
		lRet := setRespError(404, STR0045) // "O borderô de impostos não foi encontrado! Verifique o numero digitado ou já não foi cancelado anteriormente!"
	EndIf

	If lRet
		Self:SetResponse(getRespOk("ExclusaoBorderoImp"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Cancela da Faturanotific

@example http://localhost:12173/rest/WSPfsAppCP/canfat/{recnoTitulo}
@author Willian Kazahaya
@since 20/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE FatPag PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local aFatPagAut   := {}
Local aTitulos     := {}
Local aDadosTitulo := {}
Local aCmpExtra    := {"E2_NATUREZ", "E2_EMISSAO"}
Local lRet         := .T.

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1, aCmpExtra)
	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	If Len(aDadosTitulo) > 0 .And. ;
			SE2->( dbSeek(aDadosTitulo[1][1][2]))
		//aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_HIST"})][2]
		aFatPagAut := { aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_PREFIXO"})][2]  /*Prefixo*/,;
			aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_TIPO"})][2]     /*Tipo*/,;
			aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_NUM"})][2]      /*Numero da Fatura*/,;
			aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_NATUREZ"})][2]  /*Natureza*/, ;
			Date()                                                                  /*Data de*/,;
			Date()                                                                  /*Data Ate*/,;
			aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_FORNECE"})][2]  /*Fornecedor*/,;
			aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_LOJA"})][2]     /*Loja*/,;
			""                                                                      /*Fornecedor para geracao*/,;
			""                                                                      /*Loja do fornecedor para geracao*/,;
			""                                                                      /*Condicao de pagto*/,;
			/*Moeda*/,;
			aTitulos                                                                /*ARRAY com os titulos da fatura*/,;
			/*Valor de decrescimo*/,;
			/*Valor de acrescimo*/ }

		lRet := FINA290(4,aFatPagAut) //- nPosArotina,aFatPag

		If !(lRet .And. !vrFatura(aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_PREFIXO"})][2],;
				aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_NUM"})][2]    ,;
				aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_TIPO"})][2]   ,;
				aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_FORNECE"})][2],;
				aDadosTitulo[1][aScan(aDadosTitulo[1], {|x| x[1] == "E2_LOJA"})][2]   ))
			lRet := setRespError(500, STR0046) //"Não foi possivel realizar o cancelamento da fatura informada!"
		EndIf
	else
		lRet := setRespError(404, STR0047) //"O título informado não foi encontrado!"
	EndIF

	If lRet
		Self:SetResponse(getRespOk("CancelaFatura"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Cancela a compensação de titulo

@example http://localhost:12173/rest/WSPfsAppCP/compens/{recnoTitulo}
@author Willian Kazahaya
@since 07/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE CCompensacao PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local aDadosTitulo := {}
Local aCmpExtra    := {"E2_NATUREZ", "E2_EMISSAO"}
Local lRet         := .T.

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1, aCmpExtra)
	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	If Len(aDadosTitulo) > 0 .And. ;
			SE2->( dbSeek(aDadosTitulo[1][1][2]))
		FINA340(4, .T.)
	EndIf

	If lRet
		Self:SetResponse(getRespOk("CancelaCompensacao"))
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Exclui a compensação de titulo

@example http://localhost:12173/rest/WSPfsAppCP/compens/estornar/{recnoTitulo}
@author Willian Kazahaya
@since 07/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE ECompensacao PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local aDadosTitulo := {}
Local aCmpExtra    := {"E2_NATUREZ", "E2_EMISSAO"}
Local lRet         := .T.

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1, aCmpExtra)
	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	If Len(aDadosTitulo) > 0 .And. ;
			SE2->( dbSeek(aDadosTitulo[1][1][2]))
		FINA340(5, .T.)
	EndIf

	If lRet
		Self:SetResponse(getRespOk("EstornaCompensacao"))
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DELETE - Cancela o cheque

@example http://localhost:12173/rest/WSPfsAppCP/cheque/{recnoTitulo}
@author Willian Kazahaya
@since 07/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD DELETE Cheque PATHPARAM recnoTitulo WSREST WSPfsAppCP
Local oReqBody     := nil
Local aRetAuto     := {}
Local aDadosTitulo := {}
Local aCmpExtra    := {"E2_NATUREZ", "E2_EMISSAO"}
Local lRet         := .T.
Local cBody        := ""

	cBody := Self:GetContent()
	FWJsonDeserialize(cBody,@oReqBody)

	aDadosTitulo := gtDadoByRC(Self:recnoTitulo, 1, aCmpExtra)
	DbSelectArea("SE2")
	SE2->( DbSetOrder(1) )
	If Len(aDadosTitulo) > 0 .And. ;
			SE2->( dbSeek(aDadosTitulo[1][1][2]))

		aRetAuto := Array(0)

		aAdd(aRetAuto,{"AUTBANCO",      gtValJSON(oReqBody , "AUTBANCO"   , cBody, ""           , TamSx3("E5_BANCO")[1]   )}) //"Banco"
		aAdd(aRetAuto,{"AUTAGENCIA",    gtValJSON(oReqBody , "AUTAGENCIA" , cBody, ""           , TamSx3("E5_AGENCIA")[1] )}) //"Agencia"
		aAdd(aRetAuto,{"AUTCONTA",        gtValJSON(oReqBody , "AUTCONTA"   , cBody, ""           , TamSx3("E5_CONTA")[1]   )}) //"Conta"
		aAdd(aRetAuto,{"AUTCHEQUE",        gtValJSON(oReqBody , "AUTCHEQUE"  , cBody, ""           , TamSx3("E5_NUMCHEQ")[1] )}) //"Cheque"
		//|-------------------------|
		//| COMMIT DA FUNÇÃO        |
		//|-------------------------|
		MSExecAuto({|a,b,c|FINA390(a,b,c)},,aRetAuto,5)
	EndIf
Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} vldCrtTit(aTitulo)
Valida se os dados são validos para a Criação do Titulo do Pagar e
se já existe algum titulo criado com as mesmas informações

@param aTitulo - Array de dados do titulo
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function vldCrtTit(aTitulo)
Local aRet    := {.F.,""} // [1] Validado [2] Mensagem
Local cErrMsg := ""
Local nIndex  := 0

	// Verifica se o valor é válido
	nIndex := aScan(aTitulo,{|x| x[1] == "E2_VALOR"})
	If (aTitulo[nIndex][2] <= 0)
		cErrMsg := STR0048 // "O valor não pode ser menor ou igual a zero!"
	EndIf

	// Verifica que se o titulo já existe
	If extSE2ByPk(aTitulo)
		cErrMsg := STR0049 // "O titulo informado já existe na base!"
	EndIf

	aRet[1] := Empty(cErrMsg)
	aRet[2] := cErrMsg
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} JConvUTF8(cValue)
Converte o Texto para UTF8, removendo os CRLF por || e removendo os espaços laterais

@param cValue - Valor a ser formatado
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function JConvUTF8(cValue)
Local cReturn := ""

	cReturn := StrTran(EncodeUTF8(Alltrim(cValue)), CRLF, "||")
Return cReturn

//-----------------------------------------------------------------
/*/{Protheus.doc} gtValJSON(oObj, cValor, cJSON, xDefault, nQtdEsp)
Busca o valor no JSON. Verificando se ele existe no JSON e caso seja um campo
de texto, pode preencher o resto do Valor com espaços

@param oObj     - Objeto JSON
@param cValor   - Valor a ser procurado no Objeto
@param cJSON    - String JSON
@param xDefault - Valor default a ser retornado caso não encontre Valor no JSON
@param nQtdEsp  - Quantidade de espaços a preencher quando o campo é Caracter

@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function gtValJSON(oObj, cValor, cJSON, xDefault, nQtdEsp)
Local cRetValue := ""

Default cJSON    := ""
Default xDefault := ""
Default nQtdEsp  := 0


	If !Empty(cJSON)
		// Verifica se o campo existe no JSOn
		If ('"' + cValor + '":' $ StrTran(cJSON, " ", ""))
			cRetValue := &("oObj:" + cValor) // Realiza a macroexecução para buscar o valor do Objeto
		Else
			cRetValue := xDefault
		EndIf

		// Caso tenha que autocompletar espaços e se o valor é String
		If nQtdEsp > 0 .And. ValType(cRetValue) == "C"
			If DecodeUTF8(cRetValue) != Nil
				cRetValue := DecodeUTF8(cRetValue)
			EndIf
			cRetValue := PadL(cRetValue + Space(nQtdEsp), nQtdEsp)
		EndIf
	Else
		cRetValue := xDefault
	EndIf

Return cRetValue

//-----------------------------------------------------------------
/*/{Protheus.doc} CvJsonVal(xValor, aTamSx3)
Inclui os espaços a direita dos campos caracter e converte as datas

@param xValor - Valor que será informado no JSON
@param aTamSx3 - Chamada do TamSx3 do campo

@since 16/06/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function CvJsonVal(xValor, aTamSx3)
Local cRetValue := xValor
Local nQtdEsp   := 0 //Iif(aSize(aTamSx3) > 0, aTamSx3[1], 0)

	if (ValType(aTamSx3) == "A" .And. Len(aTamSx3) > 0)
		if (aTamSx3[3] == "C")
			// Caso tenha que autocompletar espaços e se o valor é String
			If nQtdEsp > 0 .And. ValType(cRetValue) == "C"
				cRetValue := AllTrim(cRetValue)
				If DecodeUTF8(cRetValue) != Nil
					cRetValue := DecodeUTF8(cRetValue)
				EndIf
				cRetValue := PadL(cRetValue + Space(nQtdEsp), nQtdEsp)
			EndIf
		elseif (aTamSx3[3] == "D")
			cRetValue := StoD(cRetValue)
		ElseIf (aTamSx3[3] == "N")
			cRetValue := cRetValue
		EndIf
	EndIf
Return cRetValue

//-----------------------------------------------------------------
/*/{Protheus.doc} getSIXTable(cTable, nIndice)
Busca o Indice da tabela

@param cTable - Tabela a ser pesquisada
@param nIndice - Numero do Indice a ser procurado

@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function getSIXTable(cTable, nIndice)
Local aArea    := getArea()
Local cIndice  := ""

Default nIndice := 1

	DbSelectArea(cTable)
	cIndice := IndexKey(nIndice)

	RestArea(aArea)
Return cIndice

//-----------------------------------------------------------------
/*/{Protheus.doc} gtDadoByRC(cRecno, cIndice, aCmpExtra)
Busca dados da SE2 pelo RECNO.

Caso seja necessário, há um Array para incluir outros campos como o
Saldo. A Query sempre irá retornar o Indice na primeira posição concatenado
e logo após os campos desse mesmo indice separados

@param cRecno - Recno a ser procurado. Pode ser tanto uma String com um Recno ou Array
@param nIndice - Numero do Indice da SE2. Os campos do indice serão inseridos na query
@param aCmpExtra - Array de campos extras da SE2

@return aRet
	[Linha][Campo][1] - Nome da Coluna
	[Linha][Campo][2] - Valor da Coluna

@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function gtDadoByRC(xRecno, cIndice, aCmpExtra, bFiltDelete)
Local aRet        := {}
Local aCmpIndex   := {}
Local aRegistro   := {}
Local nI          := 0
Local nLenCmpExt  := 0
Local cIndTable   := ""
Local cQuery      := ""
Local cQrySel     := ""
Local cQryFrm     := ""
Local cQryWhr     := ""
Local cAliasDb    := ""
Local cTable      := "SE2"

Default cIndice     := 1
Default aCmpExtra   := {"R_E_C_N_O_"}
Default bFiltDelete := .T.

	cIndTable := getSIXTable(cTable, cIndice)
	cQrySel := " SELECT " + StrTran(cIndTable, "+", "||" ) + " TblIndex, " + StrTran(cIndTable,"+",",")
	cQryFrm := " FROM " + RetSqlName(cTable)
	cQryWhr := " WHERE 1=1 "

	If ValType(xRecno) == "A"
		cQryWhr += " AND R_E_C_N_O_ IN (" + concatArr(xRecno) + ")"
	Else
		cQryWhr += " AND R_E_C_N_O_ = '" + xRecno + "'"
	EndIf
	If bFiltDelete
		cQryWhr += " AND D_E_L_E_T_ = ' ' "
	EndIf

	aCmpIndex := JStrArrDst(cIndTable,"+")
	nLenCmpExt := Len(aCmpExtra)
	For nI := 1 To nLenCmpExt
		If !(aCmpExtra[nI] $ cQrySel)
			cQrySel += "," + aCmpExtra[nI]
			aAdd(aCmpIndex, aCmpExtra[nI])
		Else
			ADel(aCmpExtra,nI)
			nI--
			nLenCmpExt--
		EndIf
	Next nI

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)

	cAliasDb := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDb, .F., .T.)

	// Monta o retorno, campo a campo
	While (cAliasDb)->( !Eof() )
		aAdd( aRegistro, {"TblIndex" ,(cAliasDb)->TblIndex} )

		For nI := 1 To Len(aCmpIndex)
			Do Case
				Case AllTrim(aCmpIndex[nI]) == "R_E_C_N_O_"
					aAdd( aRegistro, {"Recno", (cAliasDb)->(&(aCmpIndex[nI]))} )
				Otherwise
					aAdd( aRegistro, {aCmpIndex[nI], (cAliasDb)->(&(aCmpIndex[nI]))} )
			End Case
		Next nI

		aAdd(aRet, aClone(aRegistro))
		aSize(aRegistro, 0)

		(cAliasDb)->( dbSkip() )
	EndDo
	(cAliasDb)->( dbCloseArea() )
Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} extSE2ByPk(aTitulo)
Verifica se já existe um titulo gravado com os dados passados

@param aTitulo - Array de dados do Titulo. Obedecendo a estrutura abaixo
	[item][1] - Nome do campo
	[item][2] - Valor

@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function extSE2ByPk(aTitulo, cRecno )
Local lRet     := .T.
Local cAliasDb := ""
Local cQrySel  := ""
Local cQryFrm  := ""
Local cQryWhr  := ""
Local cQuery   := ""

Default cRecno := ""

	cQrySel := " SELECT SE2.R_E_C_N_O_ Recno "
	cQryFrm := " FROM " + RetSqlName("SE2") + " SE2 "
	cQryWhr := " WHERE SE2.D_E_L_E_T_ = ' ' "
	cQryWhr += sqlWhrBuild(aTitulo, "E2_FILIAL")
	cQryWhr += sqlWhrBuild(aTitulo, "E2_PREFIXO")
	cQryWhr += sqlWhrBuild(aTitulo, "E2_NUM")
	cQryWhr += sqlWhrBuild(aTitulo, "E2_PARCELA")
	cQryWhr += sqlWhrBuild(aTitulo, "E2_TIPO")
	cQryWhr += sqlWhrBuild(aTitulo, "E2_FORNECE")
	cQryWhr += sqlWhrBuild(aTitulo, "E2_LOJA")

	cQuery := ChangeQuery( cQrySel + cQryFrm + cQryWhr )

	cAliasDb := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasDb, .F., .T.)

	lRet := (cAliasDb)->( !Eof() )
	if (lRet)
		cRecno := (cAliasDb)->Recno
	EndIf
	(cAliasDb)->( DbCloseArea() )
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} sqlWhrBuild(aValores, cField, cApelido)
Monta a condição para o Where, validando o Tipo do dado

@param aValores - Array de valores. Respeitando a estutura
	[item][1]- Nome do campo
	[item][2]- Valor
@param cField - Campo a ser buscado
@param cApelido - Apelido da tabela
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function sqlWhrBuild(aValores, cField, cApelido)
Local cCondicao := ""
Local nIndex    := 0

Default cApelido := "SE2"

	nIndex := aScan(aValores, {|x| x[1]== cField })
	If nIndex > 0
		Do Case
			Case ValType(aValores[nIndex][2]) == "N"
				cCondicao := " AND " + cApelido + "." + cField + " = " + aValores[nIndex][2] + " "
			Case ValType(aValores[nIndex][2]) == "D"
				cCondicao := " AND " + cApelido + "." + cField + " = " + DToS(aValores[nIndex][2]) + " "
			Otherwise
				cCondicao := " AND " + cApelido + "." + cField + " = '" + aValores[nIndex][2] + "' "
		End Case
	EndIf
Return cCondicao

//-----------------------------------------------------------------
/*/{Protheus.doc} getFKTitulo(cSE2Recno)
Busca a FK do RECNO da SE2 passado

@param cSE2Recno - Recno da SE2
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function getFKTitulo(cSE2Recno)
Local cFKIdDoc  := ""
Local cAliasQry := ""

	cAliasQry := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,qryFK7IdDoc({cSE2Recno})), cAliasQry, .F., .T.)

	If ((cAliasQry)->( !Eof() ))
		cFKIdDoc := (cAliasQry)->FK7_IDDOC
	EndIf

	(cAliasQry)->(DbCloseArea())

Return cFKIdDoc


//-----------------------------------------------------------------
/*/{Protheus.doc} qryFK2(aRecnos)
Retorna a FK do Titulo

@param aRecnos - Recnos da SE2 a serem consultados
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function qryFK2(cFKIdDoc)
Local cQuery   := ""
Local cQrySel  := ""
Local cQryFrm  := ""
Local cQryWhr  := ""

	cQrySel := " SELECT FK2.FK2_IDDOC, FK2.FK2_RECPAG "
	cQryFrm := " FROM " + RetSqlName("FK2") + " FK2 "
	cQryWhr := " WHERE R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) "
	cQryWhr +=                     " FROM " + RetSqlName("FK2") + " FK2SUB  "
	cQryWhr +=                     " WHERE FK2SUB.FK2_IDDOC = '" + cFKIdDoc + "' "
	cQryWhr +=                       " AND FK2SUB.D_E_L_E_T_ = ' ') "

	cQuery := ChangeQuery( cQrySel + cQryFrm + cQryWhr )

Return cQuery

//-----------------------------------------------------------------
/*/{Protheus.doc} qryFK7IdDoc(aRecnos)
Retorna a FK do Titulo

@param aRecnos - Recnos da SE2 a serem consultados
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function qryFK7IdDoc(aRecnos)
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local cSE2Recno := ""
Default aRecnos := {}

	cSE2Recno := concatArr(aRecnos)

	cQrySel := " SELECT FK7.FK7_IDDOC, SE2.R_E_C_N_O_ Recno "
	cQryFrm := " FROM " + RetSqlName("SE2") + " SE2 INNER JOIN " + RetSqlName("FK7") + " FK7 ON (FK7.FK7_CHAVE = SE2.E2_FILIAL  || '|' || "
	cQryFrm +=                                                                                                 " SE2.E2_PREFIXO || '|' || "
	cQryFrm +=                                                                                                 " SE2.E2_NUM     || '|' || "
	cQryFrm +=                                                                                                 " SE2.E2_PARCELA || '|' || "
	cQryFrm +=                                                                                                 " SE2.E2_TIPO    || '|' || "
	cQryFrm +=                                                                                                 " SE2.E2_FORNECE || '|' || "
	cQryFrm +=                                                                                                 " SE2.E2_LOJA "
	cQryFrm +=                                                                                                 " AND SE2.D_E_L_E_T_ = ' ') "
	cQryWhr := " WHERE SE2.R_E_C_N_O_ IN (" + cSE2Recno + ")"

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)

Return cQuery

//-----------------------------------------------------------------
/*/{Protheus.doc} getRespOk(cOperation)
Monta a estrutura padrão para Resposta de sucesso

@param cOperation - Operação executada
@param aExtraInfo - Array de informações extras para o retorno
		[1] - Nome para o Response
		[2] - Valor
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function getRespOk(cOperation, aExtraInfo)
Local oResponse := JsonObject():New()
Local cMessage  := ""
Local nI        := 0

Default aExtraInfo := {}

	oResponse['operation'] := cOperation
	Do Case
		Case cOperation == "BaixaTitulo"
			cMessage :=  STR0050 //"A baixa do título foi realizada com sucesso!"
		Case cOperation == "CancelamentoBaixa"
			cMessage :=  STR0051 //"A baixa do título foi cancelada com sucesso!"
		Case cOperation == "ExclusaoBaixa"
			cMessage :=  STR0052 //"A baixa do título foi excluida com sucesso!"
		Case cOperation == "BaixaAutomaticaTitulos"
			cMessage :=  STR0053 //"A Baixa dos títulos selecionados foi realizada com sucesso!"
		Case cOperation == "CriarTituloPagar"
			cMessage :=  STR0054 //"O título foi criado com sucesso!"
		Case cOperation == "AlterarTituloPagar"
			cMessage :=  STR0055 //"O título foi alterado com sucesso!"
		Case cOperation == "ExcluirTituloPagar"
			cMessage :=  STR0056 //"O título foi excluido com sucesso!"
		Case cOperation == "SubstituirTituloPagar"
			cMessage :=  STR0057 //"O título foi substituido com sucesso!"
		Case cOperation == "LiberacaoPagto"
			cMessage :=  STR0058 //"Título(s) liberado(s) com sucesso!"
		Case cOperation == "ExclusaoBorderoImp"
			cMessage :=  STR0059 //"O borderô de impostos foi excluido com sucesso!"
		Case cOperation == "ExclusaoBordero"
			cMessage :=  STR0060 //"O borderô foi excluido com sucesso!"
		Case cOperation == "CancelaFatura"
			cMessage :=  STR0061 //"Fatura cancelada com sucesso!"
		Case cOperation == "CancelaCompensacao"
			cMessage :=  STR0062 //"A compensação foi cancelada com sucesso!"
		Case cOperation == "EstornaCompensacao"
			cMessage :=  STR0063 //"A compensação foi estornada com sucesso!"
		Case cOperation == "DesdobramentoSimples"
			cMessage :=  STR0064 //"A operação de desdobramento foi realizada com sucesso!"
		Case cOperation == "DesdobramentoTransitoria"
			cMessage :=  STR0065 //"A operação de transitória foi realizada com sucesso!"
		Case cOperation == "DesdobramentoPosPagto"
			cMessage :=  STR0066 //"A operação de desdobramento pós-pagamento foi realizada com sucesso!"
		Otherwise
			cMessage := STR0067 + " [" + cOperation + "]."
	End Case

	oResponse['status']  = 201
	oResponse['message'] = JurEncUTF8(cMessage)

	For nI := 1 To Len(aExtraInfo)
		oResponse[aExtraInfo[nI][1]] := aExtraInfo[nI][2]
	Next nI

Return FWJsonSerialize(oResponse, .F., .F., .T.)

//-----------------------------------------------------------------
/*/{Protheus.doc} setRespError(nCodHttp, cErrMessage)
Padroniza a resposta sempre convertendo o texto para UTF-8

@param nCodHttp - Código HTTP
@param cErrMessage - Mensagem de erro a ser convertido

@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function setRespError(nCodHttp, cErrMessage)
	SetRestFault(nCodHttp, JConvUTF8(cErrMessage), .T.)
Return .F.


//-----------------------------------------------------------------
/*/{Protheus.doc} concatArr(aValues)
Concatena os valores presentes no Array

@param aValues - Valores a serem concatenados
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function concatArr(aValues)
Local nI := 0
Local cRet := ""

	For nI := 1 To Len(aValues)
		Do case
			Case ValType(aValues[nI]) == "N"
				cRet += cValToChar(aValues[nI]) + ','
			Case ValType(aValues[nI]) == "D"
				cRet += DToS(aValues[nI]) + ','
			Otherwise
				cRet += "'"+ aValues[nI] + "',"
		End Case
	Next nI

	// Remove a ultima virgula
	If !Empty(cRet)
		cRet := SubStr(cRet, 1, Len(cRet)-1)
	EndIf
Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} checkTitulo(aRecnos)
Monta a estrutura padrão para Resposta de sucesso

@param cOperation - Operação executada
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function checkTitulo(aRecnos)
Local lRet     := .F.
Local cRecnos  := ""
Local cQrySel  := ""
Local cQryFrm  := ""
Local cQryWhr  := ""
Local cQuery   := ""
Local cAliasDb := ""

Default aRecnos := {}

	If Len(aRecnos) > 0
		cRecnos := concatArr(aRecnos)

		cQrySel := " SELECT SE2.R_E_C_N_O_ RECNO, FK7.FK7_CHAVE , COALESCE(FK2.FK2_RECPAG, '-') FK2_RECPAG "
		cQryFrm := " FROM " + RetSqlName("SE2") + " SE2 INNER JOIN " + RetSqlName("FK7") + " FK7 ON (FK7.FK7_CHAVE = SE2.E2_FILIAL  + '|' + "
		cQryFrm +=                                                                                                 " SE2.E2_PREFIXO + '|' + "
		cQryFrm +=                                                                                                 " SE2.E2_NUM     + '|' + "
		cQryFrm +=                                                                                                 " SE2.E2_PARCELA + '|' + "
		cQryFrm +=                                                                                                 " SE2.E2_TIPO    + '|' + "
		cQryFrm +=                                                                                                 " SE2.E2_FORNECE + '|' + "
		cQryFrm +=                                                                                                 " SE2.E2_LOJA
		cQryFrm +=                                                                             " AND FK7.D_E_L_E_T_ = ' ') "
		cQryFrm +=                                    " LEFT  JOIN (SELECT FK2SUB.* "
		cQryFrm +=                                                " FROM " + RetSqlName("FK2") + " FK2SUB INNER JOIN (SELECT MAX(FK2SUBMAX.R_E_C_N_O_) RECNO "
		cQryFrm +=                                                                                                  " FROM " + RetSqlName("FK2") + " FK2SUBMAX "
		cQryFrm +=                                                                                                  " GROUP BY FK2SUBMAX.FK2_IDDOC) FK7MAX ON (FK7MAX.RECNO = FK2SUB.R_E_C_N_O_)
		cQryFrm +=                                                " WHERE FK2SUB.D_E_L_E_T_ = ' ') FK2 ON (FK2.FK2_IDDOC = FK7.FK7_IDDOC) "
		cQryWhr := " WHERE SE2.R_E_C_N_O_ in (" + cRecnos + ")"

		// O subselect retornará o ultimo registro de Baixa dos titulos selecionados
		cQuery := ChangeQuery( cQrySel + cQryFrm + cQryWhr )
		cAliasDb := GetNextAlias()

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

		While ((cAliasQry)->( !Eof() )) .And. lRet
			lRet := !((cAliasQry)->(FK2_RECPAG) != "P")

			(cAliasQry)->( dbSkip() )
		EndDo

		(cAliasQry)->(DbCloseArea())

	EndIf
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} vrBordero(codBord, cRotina)
Verifica a quantidade de Borderos abertos para aquele titulo

@param codBord - Código do Bordero
@param cRotina - Código da Rotina de Origem. Default: Vazio

@return Boolean - Há mais de um Bordero para aquele titulo
@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function vrBordero(codBord, cRotina)
Local cAliasQry := ""
Local cQuery    := ""
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local lRet      := .F.

Default cRotina := ""

	cQrySel := " SELECT COUNT(*) QTD"
	cQryFrm :=   " FROM " + RetSqlName("SEA") + " SEA"
	cQryWhr :=  " WHERE EA_NUMBOR = '" + codBord + "'"
	cQryWhr +=    " AND D_E_L_E_T_ = ' ' "

	If !Empty(cRotina)
		cQryWhr += " AND EA_ORIGEM = '" + cRotina + "'"
	EndIf

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)
	cAliasQry := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	lRet := (cAliasQry)->QTD > 0

	(cAliasQry)->(DbCloseArea())
Return 	lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} vrFatura(cPrefixo, cNumero, cTipo, cFornCod, cFornLoj)
Verifica a quantidade de Faturas abertas para aquele titulo.

@param cPrefixo - Prefixo do titulo
@param cNumero  - Numero do Titulo
@param cTipo    - Tipo do Titulo
@param cFornCod - Código do Fornecedor
@param cFornLoj - Loja do fornecedor

@return Boolean - Se há mais de uma fatura para aquele titulo

@since 20/03/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function vrFatura(cPrefixo, cNumero, cTipo, cFornCod, cFornLoj)
Local cQuery    := ""
Local cQrySel   := ""
Local cQryFrm   := ""
Local cQryWhr   := ""
Local cAliasQry := ""
Local lRet      := .F.

	cQrySel := " SELECT COUNT(*) QTD"
	cQryFrm := " FROM " + RetSqlName("SE2")
	cQryWhr := " WHERE D_E_L_E_T_ = ' '"
	cQryWhr +=   " AND E2_FATPREF = '" + cPrefixo + "'"
	cQryWhr +=   " AND E2_FATURA  = '" + cNumero  + "'"
	cQryWhr +=   " AND E2_TIPOFAT = '" + cTipo    + "'"
	cQryWhr +=   " AND E2_FATFOR  = '" + cFornCod + "'"
	cQryWhr +=   " AND E2_LOJA    = '" + cFornLoj + "'"

	cQuery := ChangeQuery(cQrySel + cQryFrm + cQryWhr)
	cAliasQry := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

	lRet := (cAliasQry)->QTD > 0

	(cAliasQry)->(DbCloseArea())
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} qryNUMOH(cOHFIdDoc, cOHFCItem, lGetQuant, cEntidade)
Query para buscar os Anexos

@param cSE2Recno - Recno da SE2
@param cOHFIdDoc - Código FK7 do Titulo a pagar
@param cOHFCItem - Sequencial do Item
@param lGetQuant - Irá retornar somente o Count ou as colunas para o grid
@param cEntidade - Entidade a ser consultada

@since 28/12/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function qryNUMOH(cSE2Recno, cSeqItem, lGetQuant, cEntidade)
Local cQrySel := ""
Local cQryFrm := ""
Local cQryWhr := ""

Default cSE2Recno := ""
Default cSeqItem  := ""
Default lGetQuant := .T.
Default cEntidade := "OHF"

	If (lGetQuant)
		cQrySel := " SELECT COUNT(*) QTD "
	Else
		cQrySel := " SELECT NUM.NUM_COD, NUM.NUM_DOC, NUM.NUM_EXTEN, NUM.NUM_FILENT, " + cEntidade + "." + cEntidade + "_CITEM SEQITEM, "
		cQrySel +=          cEntidade + "." + cEntidade + "_CNATUR CODNATUR, SED.ED_DESCRIC, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA "
	EndIf

	cQryFrm :=   " FROM " + RetSqlName("SE2") + " SE2 "
	cQryFrm +=  " INNER JOIN " + RetSqlName("FK7") + " FK7 "
	cQryFrm +=     " ON (FK7.FK7_CHAVE = SE2.E2_FILIAL || '|' || "
	cQryFrm +=        " SE2.E2_PREFIXO || '|' || "
	cQryFrm +=        " SE2.E2_NUM || '|' || "
	cQryFrm +=        " SE2.E2_PARCELA || '|' || "
	cQryFrm +=        " SE2.E2_TIPO || '|' || "
	cQryFrm +=        " SE2.E2_FORNECE || '|' || "
	cQryFrm +=        " SE2.E2_LOJA "
	cQryFrm +=    " AND FK7.FK7_ALIAS = 'SE2' "
	cQryFrm +=    " AND FK7.D_E_L_E_T_ = ' ') "
	cQryFrm +=  " INNER JOIN " + RetSqlName(cEntidade) + " " + cEntidade + " "
	cQryFrm +=     " ON (" + cEntidade + "." + cEntidade + "_IDDOC = FK7.FK7_IDDOC "
	cQryFrm +=    " AND " + cEntidade + ".D_E_L_E_T_ = ' ') "
	cQryFrm +=  " INNER JOIN " + RetSqlName("NUM") + " NUM "
	cQryFrm +=     " ON (NUM.NUM_CENTID = " + cEntidade + "." + cEntidade + "_IDDOC || " + cEntidade + "_CITEM "
	cQryFrm +=    " AND NUM.NUM_ENTIDA = '" + cEntidade + "' "
	cQryFrm +=    " AND NUM.D_E_L_E_T_ = ' ') "
	cQryFrm +=  " INNER JOIN " + RetSqlName("SED") + " SED "
	cQryFrm +=     " ON (SED.ED_CODIGO = " + cEntidade + "." + cEntidade + "_CNATUR "
	cQryFrm +=          JSqlFilCom(cEntidade, "SED",,, cEntidade + "_FILIAL", "ED_FILIAL") + ")"
	cQryWhr :=  " WHERE SE2.D_E_L_E_T_ = ' ' "
	cQryWhr +=    " AND SE2.R_E_C_N_O_ = '" + cValToChar(cSE2Recno) + "' "

	If (!Empty(cSeqItem))
		cQryWhr +=    " AND " + cEntidade + "." + cEntidade + "_CITEM = '" + cSeqItem + "' "
	EndIf
Return cQrySel + cQryFrm + cQryWhr

//-----------------------------------------------------------------
/*/{Protheus.doc} qtdNUMOH(cSE2Recno, cItem, cEntidade)
Quebra a string em Array a partir do Limitador

@param cSE2Recno - Recno da SE2
@param cItem     - Código sequencial
@param cEntidade - Entidade a ser pesquisada

@since 04/01/2021
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function qtdNUMOH(cSE2Recno, cItem, cEntidade)
Local nQtd      := 0
Local cQuery    := ""
Local cAliasNUM := ""

Default cSE2Recno := ""
Default cItem     := ""
Default cEntidade := "OHF"

	cQuery := ChangeQuery(qryNUMOH(cSE2Recno, cItem, .T., cEntidade))
	cAliasNUM := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasNUM, .F., .T.)

	If (cAliasNUM)->( !Eof() )
		nQtd := (cAliasNUM)->QTD
	EndIf
	
	(cAliasNUM)->(DbCloseArea())

Return nQtd

//-----------------------------------------------------------------
/*/{Protheus.doc} JArrDistFl(cCmpList, cLimitador)
Quebra a string em Array a partir do Limitador

@param cCmpList - String a ser quebrada
@param cLimitador - Flag utilizada para quebrar a string em array
@since 05/11/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function JArrDistFl(cCmpList, cLimitador)
Local aReturn := {}
Local aAux    := {}
Local nCount  := 0
Local nIndex  := 0

	aAux := StrToKArr(cCmpList, cLimitador)

	For nCount:=1 To Len(aAux)
		nIndex := aScan(aReturn, UPPER(AllTrim(aAux[nCount] )))
		If nIndex > 0
			If !(aReturn[nIndex] == UPPER(AllTrim(aAux[nCount] )))
				Aadd(aReturn, UPPER(AllTrim(aAux[nCount] )))
			EndIf
		else
			Aadd(aReturn, UPPER(AllTrim(aAux[nCount] )))
		EndIf
	Next nCount
Return aReturn

//-----------------------------------------------------------------
/*/{Protheus.doc} jGetMV(cParam)
Busca o parâmetro SX6

@param cParam - Parâmetro a ser consultado
@since 09/12/2020
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function jGetMV(cParam)
Return SuperGetMv(cParam)


//-------------------------------------------------------------------
/*/{Protheus.doc} EmpFilUsu(cEntidade)
Retorna o array de Empresa/Filial que o usuário logado tem permissão

@Param cEntidade - Entidade a ser consultada a filial

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function EmpFilUsu(cEntidade)
Local aFiliais     := FWLoadSM0()
Local aFilUsu      := {}
Local aCompTab     := {}
Local nI           := 0
Local nY           := 0
Local cFilEntida   := ""

Default cEntidade  := ""

	If !Empty(cEntidade)
		aAdd(aCompTab, FWModeAccess(cEntidade,1)) // Empresa
		aAdd(aCompTab, FWModeAccess(cEntidade,2)) // Unidade
		aAdd(aCompTab, FWModeAccess(cEntidade,3)) // Filial
	EndIf

	For nI := 1 To Len(aFiliais)
		If (aFiliais[nI][11]) // Verifica se o usuário tem acesso. No LoadSM0 ele pega o usuário logado
			cFilEntida := ""
			If (aScan(aCompTab, "C") > 0) // Realiza tratamento no compartilhamento da tabela
				For nY := 1 To Len(aCompTab)
					If (aCompTab[nY] == "C")
						cFilEntida += Space(Len(aFiliais[nI][2+nY]))
					Else
						cFilEntida += aFiliais[nI][2+nY]
					EndIf
				Next nY
			Else
				cFilEntida := aFiliais[nI][3] + aFiliais[nI][4] + aFiliais[nI][5]
			EndIf

			If (aScan(aFilUsu, cFilEntida) == 0)
				aAdd(aFilUsu, cFilEntida)
			EndIf
		EndIf
	Next nI
Return aFilUsu

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} JSqlFilCom(cTabPai, cTabFil, cApePai, cApeFil, cCmpFilPai, cCmpFilFil)
Monta o Join de Filial levando em consideração o compartilhamento da tabela,
seja completamente compartilhando, parcialmente compartilhada ou totalmente exclusiva

@Param cTabPai    - Tabela Pai
@Param cTabFil    - Tabela Filha
@Param cApePai    - Apelido da tabela Pai na Query
@Param cAptFil    - Apelido da tabela Filha na Query
@Param cCmpFilPai - Campo de Filial da Tabela Pai
@Param cCmpFilFil - Campo de Filial da Tabela Filha

@Example - Parcialmente compartilhada (SA2 = CEE e SE2 = EEE)
	JSqlFilCom("SE2", "SA2",,, "E2_FILIAL", "A2_FILIAL")
@Return
	AND SUBSTRING(SE2.E2_FILIAL, 1, 5) = SUBSTRING(SA2.A2_FILIAL, 1, 5)

@Example - Totalmente compartilhada ou exclusiva (SE2 = EEE e SED = EEE)
	JSqlFilCom("SE2", "SED",,, "E2_FILIAL", "ED_FILIAL")
@Return
	AND SE2.E2_FILIAL = SED.ED_FILIAL

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//------------------------------------------------------------------------------------------
Function JSqlFilCom(cTabPai, cTabFil, cApePai, cApeFil, cCmpFilPai, cCmpFilFil)
Local cCompFil    := ""
Local aCompTabPai := {}
Local aCompTabFil := {}
Local nFilLenPai  := Len(AllTrim(FWxFilial(cTabPai)))
Local nFilLenFil  := Len(AllTrim(FWxFilial(cTabFil)))
Local cFilialPai  := ""
Local cFilialFil  := ""
Local nFilLenLow  := 0

Default cApePai := cTabPai
Default cApeFil := cTabFil
Default cCmpFilPai := cTabPai + "_FILIAL"
Default cCmpFilFil := cTabFil + "_FILIAL"

	aAdd(aCompTabPai, FWModeAccess(cTabPai,1)) // Empresa
	aAdd(aCompTabPai, FWModeAccess(cTabPai,2)) // Unidade
	aAdd(aCompTabPai, FWModeAccess(cTabPai,3)) // Filial

	aAdd(aCompTabFil, FWModeAccess(cTabFil,1)) // Empresa
	aAdd(aCompTabFil, FWModeAccess(cTabFil,2)) // Unidade
	aAdd(aCompTabFil, FWModeAccess(cTabFil,3)) // Filial

	If ((nFilLenFil == nFilLenPai) .Or. (nFilLenFil != nFilLenPai .And. (nFilLenFil != 0 .And. nFilLenPai != 0)))
		nFilLenPai := filLen(aCompTabPai)
		nFilLenFil := filLen(aCompTabFil)

		If ( nFilLenPai != nFilLenFil ) .And. ( nFilLenFil > 0 .Or. nFilLenPai > 0)
			nFilLenLow := nFilLenPai

			If (nFilLenLow == 0 )
				nFilLenLow := nFilLenFil
			ElseIf (nFilLenFil < nFilLenLow .And. nFilLenFil > 0)
				nFilLenLow := nFilLenFil
			EndIf

			If (nFilLenLow > 0)
				cFilialFil := "SUBSTRING(" +cApeFil + "." + cCmpFilFil + ",1," + cValToChar(nFilLenLow) + ")"
			Else
				cFilialFil := cApeFil + "." + cCmpFilFil
			EndIf

			If (nFilLenLow > 0)
				cFilialPai := "SUBSTRING(" +cApePai + "." + cCmpFilPai + ",1," + cValToChar(nFilLenLow) + ")"
			Else
				cFilialPai := cApePai + "." + cCmpFilPai
			EndIf

			cCompFil := " AND " + cFilialFil + " = " + cFilialPai
		Else
			cCompFil := " AND " + cApeFil  + "." + cCmpFilFil + " = " + cApePai + "." + cCmpFilPai
		EndIf
	EndIf
Return cCompFil

//-------------------------------------------------------------------
/*/{Protheus.doc} filLen(aCompTab)
Retorna a quantidade de caracteres presentes na filial da tabela

@Param - Array do compartilhamento da tabela

@author Willian Kazahaya
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function filLen(aCompTab)
Local aFilAtu    := FwArrFilAtu()
Local aLenFil    := { Len(aFilAtu[13]), Len(aFilAtu[14]), Len(aFilAtu[15]) }
Local nLenFilial := aFilAtu[8]
Local nI         := 0
Local nIndSubStr := 0

	For nI := 1 To Len(aLenFil)
		If (aCompTab[nI] == "C")
			Exit
		Else
			nIndSubStr += aLenFil[nI]
		EndIf
	Next nI

	If (nIndSubStr == nLenFilial)
		nIndSubStr := 0
	EndIf
Return nIndSubStr

//-----------------------------------------------------------------
/*/{Protheus.doc} sqlConDesdob(cBodyReq)
Monta a query da Consulta de Desdobramentos

@Param cBodyReq - Body recebido pela Requisição

@since 18/02/2021
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function sqlConDesdob(aBodFilOrd)
Local cQrySel    := ""
Local cQryFrm    := ""
Local cQryWhr    := ""
Local cQryOrd    := ""
Local cFilConcat := ""
Local cCpoCustom := ""
Local nI         := 0
Local aFilFilt   := EmpFilUsu("SE2")

Default aBodFilOrd := { /*cFiltroSE2*/, /*cFiltroDSD*/, /*cOrderBy*/, , }

	// Pega os campos customizados do título
	For nI := 1 to Len(aCstFldsSE2)
		If getSx3Cache(aCstFldsSE2[nI][1], 'X3_CONTEXT') == "R" .And. getSx3Cache(aCstFldsSE2[nI][1] ,'X3_BROWSE') == "S"
			cCpoCustom += "SE2." + aCstFldsSE2[nI][1] + "," // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
		EndIf
	Next nI

	cQrySel := " SELECT " + cCpoCustom + "DSD.SE2RECNO, DSD.VALOR, DSD.ORIGEM, DSD.IDDOC, DSD.CITEM,"
	cQrySel +=        " DSD.ENTRECNO, DSD.CNATUR, SEDDSD.ED_DESCRIC, SEDDSD.ED_CCJURI,"
	cQrySel +=        " DSD.CESCR, NS7.NS7_NOME, DSD.CCUSTO, CTT.CTT_DESC01,"
	cQrySel +=        " DSD.CPART, RD0PAR.RD0_NOME PARTNOME, RD0PAR.RD0_SIGLA PARTSIGLA,"
	cQrySel +=        " DSD.CPART2, RD0SOL.RD0_NOME SOLICNOME, RD0SOL.RD0_SIGLA SOLICSIGLA,"
	cQrySel +=        " DSD.CRATEI, OH6.OH6_DESCRI, DSD.CCLIEN, DSD.CLOJA, SA1.A1_NOME,"
	cQrySel +=        " DSD.CCASO, NVE.NVE_TITULO, DSD.CTPDSP, DSD.QTDDSP, NRH.NRH_DESC,"
	cQrySel +=        " DSD.DTDESP, DSD.COBRA, DSD.DTINCL, DSD.CPROJE, OHL.OHL_DPROJE,"
	cQrySel +=        " DSD.CITPRJ, OHM.OHM_DITEM, DSD.CHISTP, OHA.OHA_RESUMO,"
	cQrySel +=        " SE2.E2_FILIAL, SE2.E2_PREFIXO, SE2.E2_NUM, SE2.E2_PARCELA,"
	cQrySel +=        " SE2.E2_TIPO, SE2.E2_NATUREZ, SE2.E2_FORNECE, SE2.E2_LOJA,"
	cQrySel +=        " SE2.E2_MOEDA, CTO.CTO_SIMB, SE2.E2_TXMOEDA, SE2.E2_BAIXA,"
	cQrySel +=        " SE2.E2_VENCTO, SE2.E2_VENCREA, SA2.A2_NOME"

	cQryFrm :=   " FROM ( " + sqlDesdobra("OHF", aBodFilOrd[2]) + " UNION ALL " + sqlDesdobra("OHG", aBodFilOrd[2]) +") DSD"

	cQryFrm +=  " INNER JOIN " + RetSqlName("SE2") + " SE2"
	cQryFrm +=     " ON (SE2.R_E_C_N_O_ = DSD.SE2RECNO)"

	cQryFrm +=  " INNER JOIN " + RetSqlName("SA2") + " SA2"  //Fornecedor
	cQryFrm +=     " ON (SA2.A2_COD = SE2.E2_FORNECE"
	cQryFrm +=    " AND SA2.A2_LOJA = SE2.E2_LOJA"
	cQryFrm +=    JSqlFilCom("SE2", "SA2",,, "E2_FILIAL", "A2_FILIAL")
	cQryFrm +=    " AND SA2.D_E_L_E_T_ = ' ')"

	cQryFrm +=  " INNER JOIN " + RetSqlName("SED") + " SEDDSD" //Natureza Desdobramento
	cQryFrm +=     " ON ( SEDDSD.ED_CODIGO = DSD.CNATUR"
	cQryFrm +=    JSqlFilCom("OHF", "SED", "DSD", "SEDDSD", "FILIAL", "ED_FILIAL")
	cQryFrm +=    " AND SEDDSD.D_E_L_E_T_ = ' ' )"

	cQryFrm += joinCTOSE2() // Join de Moeda

	cQryFrm +=   " LEFT JOIN " + RetSqlName("RD0") + " RD0PAR" // Participante
	cQryFrm +=     " ON ( RD0PAR.RD0_CODIGO = DSD.CPART"
	cQryFrm +=    " AND RD0PAR.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("RD0") + " RD0SOL" // Solicitante
	cQryFrm +=     " ON ( RD0SOL.RD0_CODIGO = DSD.CPART2"
	cQryFrm +=    " AND RD0SOL.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("NS7") + " NS7" // Escritório
	cQryFrm +=     " ON ( NS7.NS7_COD = DSD.CESCR "
	cQryFrm +=    " AND NS7.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("CTT") + " CTT" // Centro de Custo
	cQryFrm +=     " ON ( CTT.CTT_CUSTO = DSD.CCUSTO"
	cQryFrm +=    " AND CTT.CTT_CESCRI = NS7.NS7_COD"
	cQryFrm +=    " AND CTT.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("SA1") + " SA1" // Cliente
	cQryFrm +=     " ON ( SA1.A1_COD = DSD.CCLIEN"
	cQryFrm +=    " AND SA1.A1_LOJA = DSD.CLOJA"
	cQryFrm +=    " AND SA1.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("NVE") + " NVE" // Caso
	cQryFrm +=     " ON ( NVE.NVE_NUMCAS = DSD.CCASO"
	cQryFrm +=    " AND NVE.NVE_CCLIEN = DSD.CCLIEN"
	cQryFrm +=    " AND NVE.NVE_LCLIEN = DSD.CLOJA"
	cQryFrm +=    " AND NVE.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("NRH") + " NRH" // Tipo de Despesa
	cQryFrm +=     " ON ( NRH.NRH_COD = DSD.CTPDSP"
	cQryFrm +=    " AND NRH.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("OH6") + " OH6" // Tabela de Rateio
	cQryFrm +=     " ON ( OH6.OH6_CODIGO = DSD.CRATEI"
	cQryFrm +=    " AND OH6.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("OHL") + " OHL" // Projeto
	cQryFrm +=     " ON ( OHL.OHL_CPROJE = DSD.CPROJE"
	cQryFrm +=    " AND OHL.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("OHM") + " OHM" // Item do Projeto
	cQryFrm +=     " ON ( OHM.OHM_ITEM = DSD.CITPRJ"
	cQryFrm +=    " AND OHM.OHM_CPROJE = DSD.CPROJE"
	cQryFrm +=    " AND OHM.D_E_L_E_T_ = ' ' )"

	cQryFrm +=   " LEFT JOIN " + RetSqlName("OHA") + " OHA" // Histórico padrão
	cQryFrm +=     " ON ( OHA.OHA_COD = DSD.CHISTP"
	cQryFrm +=    " AND OHA.D_E_L_E_T_ = ' ' )"

	cQryWhr +=  " WHERE COALESCE(SEDDSD.ED_CCJURI, ' ') <> '6'"  // Não retorna Transitórias
	cQryWhr +=    " AND COALESCE(SEDDSD.ED_CCJURI, ' ') <> '7'"  // Nem Pós-pagamento

	For nI := 1 To Len(aFilFilt)
		cFilConcat += "'" + aFilFilt[nI] + "',"
	Next nI

	// Inclui as filiais que o usuário tem permissão
	If !Empty(cFilConcat)
		cQryWhr += " AND SE2.E2_FILIAL IN (" + SubStr(cFilConcat,1, Len(cFilConcat)-1) + ")"
	EndIf

	If (aBodFilOrd[1] != "")
		cQryWhr += aBodFilOrd[1]
	EndIf


	If (aBodFilOrd[3] != "")
		cQryOrd += "  ORDER BY " + aBodFilOrd[3]
	Else
		cQryOrd += "  ORDER BY E2_PREFIXO,E2_NUM,E2_PARCELA, ORIGEM, CITEM"
	EndIf

Return cQrySel + cQryFrm + cQryWhr + cQryOrd

//-----------------------------------------------------------------
/*/{Protheus.doc} FilOrdSQL(cBody)
Prepara o Where e Order By com os dados do Body

@param cBody - String do Body

@returns cFiltroSE2 - Filtro de Titulos
         cFiltroDSD - Filtro de desdobramentos (OHF e OHG)
         cOrderBy   - Ordenação
         aFilSE2Run - Array de campos dinamicos do Titulo a serem filtrados
                [1] - Nome do campo
                [2] - Valor a ser filtrado
                [3] - Qual o tipo de igualdade. 1 = Valor total | 2 = Encontra pedaço
         aFilDSDRun - Array de campos dinamicos dos Desdobramentos a serem filtrados
                [1] - Nome do campo
                [2] - Valor a ser filtrado
                [3] - Qual o tipo de igualdade. 1 = Valor total | 2 = Encontra pedaço
         aFilFields - Array de campos para totalizadores
                [1] - Descrição do campo
                [2] - Nome do Campo no Select
                [3] - Tipo do Campo
@since 26/02/2021
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function FilOrdSQLDesdob(cBody)
Local oJsonBody := JsonObject():new()
Local oJsonSub  := JsonObject():new()
Local nI        := 0
Local nY        := 0
Local nX        := 0
Local cOrderType:= ""
Local cFiltroSE2:= ""
Local cFiltroDSD:= ""
Local cFiltroF3 := ""
Local cFiltro   := ""
Local cOrderBy  := ""
Local cFilField := ""
Local cFilType  := ""
Local cFilValue := ""
Local aFilValue := {}
Local aFilColumn:= {}
Local aFilDSDRun:= {}
Local aFilSE2Run:= {}
Local aFilFields:= {}
Local aRet      := {}
Local lCmpDesd  := .F.

	retJson := oJsonBody:fromJson(cBody)
	itensJs := oJsonBody:GetNames()

	For nI := 1 to Len(itensJs)
		If (itensJs[nI] == "filter")
			oJsonSub := oJsonBody:getJsonObject("filter")
			For nY := 1 to Len(oJsonSub)
				cFiltro   := " AND "
				cFilField := oJsonSub[nY]["field"]
				cFilValue := oJsonSub[nY]["value"]

				// Tipos existentes: F3, Valor, Data, String, Number, Combo
				cFilType  := oJsonSub[nY]["type"]

				// Se o campo tiver _ no inicio, o campo é de desdobramento
				lCmpDesd := ((AllTrim(SubStr(cFilField,1,1)) == "_") ;
					.OR. (AllTrim(SubStr(cFilField,1,3)) == "NVY"))

				aFilValue := StrToKArr(cFilValue, "||")

				Do Case
					Case cFilType == "F3"
						cFiltroF3 := ""
						aFilColumn := StrToKArr(cFilField, "+")
						aFilValue := StrToKArr(cFilValue, "-")
						For nX := 1 To Len(aFilColumn)
							cFiltroF3 += " AND " + aFilColumn[nX] + "='" + aFilValue[nX] + "'"
						Next nX

						cFiltro += SubStr(cFiltroF3, 5, Len(cFiltroF3)-4)
					Case cFilType == "Valor"
						cFiltro += "( " + cFilField + " >= " + aFilValue[1]
						cFiltro += " AND " + cFilField + " <= " + aFilValue[2] + ")"
					Case cFilType == "Data"
						cFiltro += "( " + cFilField + " >= '" + aFilValue[1] + "'"
						cFiltro += " AND " + cFilField + " <= '" + aFilValue[2] + "')"

					Case cFilType == "Numero"
						cFiltro := " AND " + cFilField + " = " + cFilValue
					Case cFilType == "Combo"
						cFiltro := ""
					Case cFilType == "Memo"
						If (lCmpDesd)
							aAdd(aFilDSDRun, { cFilField, DecodeUTF8(cFilValue), 2 } )
						Else
							aAdd(aFilSE2Run, { cFilField, DecodeUTF8(cFilValue), 2 } )
						EndIf
					Otherwise
						cFiltro += "UPPER( " + cFilField + ") LIKE '%" + AllTrim(Upper(cFilValue)) + "%'"
				EndCase

				If !(cFiltro == " AND ")
					If (lCmpDesd)
						cFiltroDSD += cFiltro
					Else
						cFiltroSE2 += cFiltro
					EndIf
				EndIf
				lCmpDesd := .F.
			Next nY
			oJsonSub := Nil
		ElseIf(itensJs[nI] == "sort")
			oJsonSub := oJsonBody:getJsonObject("sort")
			For nY := 1 to Len(oJsonSub)
				cOrderType := oJsonSub[nY]["sortType"]

				cOrderBy += StrTran(oJsonSub[nY]["field"], "+", "||")

				If (cOrderType == "D")
					cOrderBy += " DESC"
				EndIf

				cOrderBy += ","
			Next nY
			oJsonSub := Nil
		ElseIf(itensJs[nI] == "fields")
			oJsonSub := oJsonBody:getJsonObject("fields")

			For nY := 1 to Len(oJsonSub)
				aAdd(aFilFields, {oJsonSub[nY]["name"],;
					oJsonSub[nY]["field"],;
					oJsonSub[nY]["type"]})
			Next nY

		EndIf
	Next nI

	If (Len(cOrderBy) > 0)
		cOrderBy := SubStr(cOrderBy, 1, Len(cOrderBy)-1)
	EndIf

	aAdd(aRet,cFiltroSE2)
	aAdd(aRet,cFiltroDSD)
	aAdd(aRet,cOrderBy)
	aAdd(aRet,aClone(aFilSE2Run))
	aAdd(aRet,aClone(aFilDSDRun))
	aAdd(aRet,aClone(aFilFields))

	aSize(aFilSE2Run,0)
	aSize(aFilDSDRun,0)
	aSize(aFilFields,0)

Return aRet

//-----------------------------------------------------------------
/*/{Protheus.doc} sqlDesdobra(cEntidade, cFiltDesd)
Monta SQL para pegar informação do Desdobramento

@param cEntidade - Entidade (OHF ou OHG)
@Param cFiltDesd - Filtro do Desdobramento

@returns Query a ser executada

@since 18/02/2021
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function sqlDesdobra(cEntidade, cFiltDesd)
Local cQrySel    := "SELECT "
Local cQryFrm    := ""
Local cQryWhr    := ""
Local nI         := 0
Local aCmpDesdob := {'FILIAL','IDDOC','CITEM','CNATUR','VALOR','CPART','CESCR', ;
	'CCUSTO','CPART2','CRATEI','CCLIEN','CLOJA','CCASO', ;
	'CTPDSP','QTDDSP','DTDESP','COBRA','CPROJE','CITPRJ', ;
	'CHISTP','HISTOR','CDESP','DTINCL','DTCONT'} // Importante usar o pós-fixo da coluna

Default cFiltDesd := ""

	cQrySel := " SELECT SE2.R_E_C_N_O_ SE2RECNO, '" + cEntidade + "' ORIGEM,"

	For nI := 1 To Len(aCmpDesdob)
		// Resultado esperado =>  OHF.OHF_IDDOC IDDOC,
		cQrySel += " " + cEntidade + "." + cEntidade + "_" + aCmpDesdob[nI] + " " + aCmpDesdob[nI] + ","
	Next nI

	cQrySel +=       " FK7.R_E_C_N_O_ FK7RECNO, " + cEntidade + "." + "R_E_C_N_O_ ENTRECNO"
	cQryFrm :=  " FROM " + RetSqlName("SE2") + " SE2"
	cQryFrm += " INNER JOIN " + RetSqlName("FK7") + " FK7"
	cQryFrm +=    " ON (FK7.FK7_CHAVE = SE2.E2_FILIAL || '|' ||"
	cQryFrm +=                        " SE2.E2_PREFIXO || '|' ||"
	cQryFrm +=                        " SE2.E2_NUM || '|' ||"
	cQryFrm +=                        " SE2.E2_PARCELA || '|' ||"
	cQryFrm +=                        " SE2.E2_TIPO || '|' ||"
	cQryFrm +=                        " SE2.E2_FORNECE || '|' ||"
	cQryFrm +=                        " SE2.E2_LOJA"
	cQryFrm +=   " AND FK7.FK7_ALIAS = 'SE2'"
	cQryFrm +=   " AND FK7.D_E_L_E_T_ = ' ')"
	cQryFrm += " INNER JOIN " + RetSqlName(cEntidade) + " " + cEntidade
	cQryFrm +=    " ON (" + cEntidade + "." + cEntidade + "_IDDOC = FK7.FK7_IDDOC"
	cQryFrm +=   " AND " + cEntidade + ".D_E_L_E_T_ = ' ')
	cQryFrm +=  " LEFT JOIN " + RetSqlName("NVY") + " NVY"
	cQryFrm +=    " ON (NVY.NVY_CPAGTO = FK7.FK7_CHAVE"

	If (cEntidade == "OHF")
		cQryFrm += " AND NVY.NVY_ITDES = OHF.OHF_CITEM"
	ElseIf (cEntidade == "OHG")
		cQryFrm += " AND NVY.NVY_ITDPGT = OHG.OHG_CITEM"
	EndIf
	cQryFrm +=   " AND NVY.D_E_L_E_T_ = ' ')"


	cQryWhr := " WHERE SE2.D_E_L_E_T_ = ' '"

	cQryWhr += StrTran(StrTran(StrTran(cFiltDesd, "%_", "%" + cEntidade + "_"),"||_","||" + cEntidade + "_"), " _", " " + cEntidade +"_")

Return cQrySel + cQryFrm + cQryWhr

//-----------------------------------------------------------------
/*/{Protheus.doc} VerRegFilt(cEntidade, cChave, aFiltros)
Realiza os filtros por posicionamento na tabela

@param cEntidade - Entidade (SE2, OHF ou OHG)
@Param cChave - Chave do Registro
@Param aFiltros - Filtros a serem realizados
	[1] - Nome do campo. Para o Desdobramento eles virão com _ no inicio
	      para complementar com a entidade passada
	[2] - Valor a ser filtrado
	[3] - Qual o tipo de igualdade. 1 = Valor total | 2 = Encontra pedaço
@Param nIndice - Indice do Seek na tabela - Padrão: 1

@returns Query a ser executada

@since 03/03/2021
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function VerRegFilt(cEntidade, cChave, aFiltros, nIndice)
Local aArea    := GetArea()
Local aEntArea := (cEntidade)->(getArea())
Local lRegOk   := .F.
Local nI       := 0
Local lEntSE2  := cEntidade == "SE2"
Local cField   := ""
Local cValorFld:= ""

Default nIndice := 1

	DbSelectArea(cEntidade)
	(cEntidade)->( dbSetOrder(1) )

	If (cEntidade)->( DbSeek(cChave) )
		For nI := 1 To Len(aFiltros)
			// Verifica se é SE2. Se não for, concatena a entidade
			If (lEntSE2)
				cField := aFiltros[nI][1]
			Else
				cField := cEntidade + aFiltros[nI][1]
			EndIf

			// Faz um upper no valor
			cValorFld := Upper((cEntidade)->(&cField))

			If aFiltros[nI][3] == 1 // Se for comparação absoluta
				lRegOk := cValorFld == Upper(aFiltros[nI][2])
			Else // Senão é comparação parcial
				lRegOk := Upper(aFiltros[nI][2]) $ cValorFld
			EndIf

			If (!lRegOk)
				Exit
			EndIf
		Next nI
	EndIf

	RestArea(aEntArea)
	RestArea(aArea)
Return lRegOk

//-----------------------------------------------------------------
/*/{Protheus.doc} joinCTOSE2()
Monta o Join entre as tabelas CTO e SE2 observando o banco para
realizar a conversão correta dos dados

@returns Join da SE2 e CTO

@since 29/03/2021
@author Willian Kazahaya
/*/
//-----------------------------------------------------------------
Static Function joinCTOSE2()
Local cJoin   := ""
Local cBdBase := (Upper(TcGetDb()))

	cJoin :=   " LEFT JOIN " + RetSqlName("CTO") + " CTO"

	If (cBdBase == "MSSQL")
		cJoin += " ON ( CTO.CTO_MOEDA = SE2.E2_MOEDA"
	Else
		cJoin += " ON ( TO_NUMBER(CTO.CTO_MOEDA, '999') = SE2.E2_MOEDA"
	EndIf
	cJoin += JSqlFilCom("SE2", "CTO",,, "E2_FILIAL", "CTO_FILIAL")
	cJoin += " AND CTO.D_E_L_E_T_ = ' '"
	cJoin += " )"
Return cJoin

//-------------------------------------------------------------------
/*/{Protheus.doc} GET listPrefixos
Busca a lista de prefixos cadastrados

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/listPrefixos
@since 18/02/2022
/*/
//-------------------------------------------------------------------
WSMETHOD GET listPrefixos WSREST WSPfsAppCP
Local oResponse  := JsonObject():New()
Local cQuery     := ""
Local cFilConcat := ""
Local nI         := 0
Local aRet       := {}
Local aFilFilt   := EmpFilUsu("SE2")

	Self:SetContentType("application/json")
	oResponse['prefixos'] := {}

	cQuery := " SELECT DISTINCT SE2.E2_PREFIXO "
	cQuery +=      " FROM " + RetSqlName("SE2") + " SE2 "
	cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' "

	// Inclui as filiais que o usuário tem permissão
	For nI := 1 To Len(aFilFilt)
		cFilConcat += "'" + aFilFilt[nI] + "',"
	Next nI

	If !Empty(cFilConcat)
		cQuery += " AND SE2.E2_FILIAL IN (" + SubStr(cFilConcat,1, Len(cFilConcat)-1) + ") "
	EndIf

	aRet := JURSQL(cQuery, "*")

	// Lista em ordem alfabética
	If Len( aRet ) > 0
		aSort( aRet )

		For nI := 1 To Len(aRet)
			Aadd( oResponse['prefixos'], aRet[nI][1] )
		next nI
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} setVlrPesq(cSearchKey)
Monta o filtro de pesquisa rápida

@param cSearchKey  - Palavra chave para filtrar títulos

@returns filtro da pesquisa rápida
@since 18/02/2022
/*/
//-----------------------------------------------------------------
Static Function setVlrPesq(cSearchKey)
Local cQuery    := ""
Local nI        := 0
Local nValor    := Val(StrTran(cSearchKey,",","."))
Local lIsNumber := nValor > 0 .And. cValtoChar(nValor) == cSearchKey  // Garante que o cSearchKey contém somente caracteres numéricos.

	If nValor > 0
		cSearchKey := StrTran(cSearchKey, ',', '.')
	Else
		cSearchKey := StrTran(JurLmpCpo(DecodeUTF8(cSearchKey), .F.), '#', '')
	EndIf

	cQuery := " ( UPPER(E2_HIST) LIKE UPPER('%" + cSearchKey + "%') "
	cQuery +=     " OR UPPER(E2_NUM) LIKE UPPER('%" + cSearchKey + "%') "
	cQuery +=     " OR UPPER(A2_NOME) LIKE UPPER('%" + cSearchKey + "%') "
	cQuery +=     " OR UPPER(ED_DESCRIC) LIKE UPPER('%" + cSearchKey + "%') "

	If !Empty(aCstFldsSE2)
		For nI := 1 to Len(aCstFldsSE2)
			If getSx3Cache(aCstFldsSE2[nI][1], 'X3_CONTEXT') == "R"
				If lIsNumber .And. getSx3Cache(aCstFldsSE2[nI][1], 'X3_TIPO') == "N"
					cQuery += " OR " + aCstFldsSE2[nI][1] + " = " + cSearchkey
				Else
					cQuery += " OR UPPER(" + aCstFldsSE2[nI][1] + ") LIKE UPPER('%" + cSearchKey + "%')" // "%" + cSearchKey + "%"
				EndIf
			EndIf
		Next nI
	EndIf

	cQuery += ")"

	If lIsNumber
		cQuery += " OR E2_VALOR = " + cSearchKey + " "
	EndIf

Return " ( " + cQuery + ") "

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getMotBaixa
Busca a lista de prefixos cadastrados

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/getMotBaixa
@since 18/02/2022
/*/
//-------------------------------------------------------------------
WSMETHOD GET getMotBaixa WSREST WSPfsAppCP

Local oResponse  := JsonObject():New()
Local nI         := 0
Local aMotBx     := ReadMotBx()
Local nX := 1

	Self:SetContentType("application/json")
	oResponse['motivos'] := {}
	//-------------------------------------------------------
	// Estrutura da aMotBxBco
	// 1 - Sigla do Motivo de Baixa
	// 2 - Descrição do Motivo de Baixa
	// 3 - Movimenta Banco (S/N)
	// 4 - Comissão (S/N)
	// 5 - Carteira (A/P/R)
	// 5 - Cheque (S/N)
	//-------------------------------------------------------
	For nI := 1 to Len(aMotBx)
		If Substr(aMotBx[nI],34,01) $ "A|P" .And. !(substr(aMotBx[nI],01,03) $ "FAT|LOJ|LIQ|CEC|CMP")
			aAdd(oResponse['motivos'], JSonObject():New())
			oResponse['motivos'][nX]['sigla']     := substr(aMotBx[nI],01,03)
			oResponse['motivos'][nX]['descricao'] := substr(aMotBx[nI],07,10)
			oResponse['motivos'][nX]['movimenta'] := substr(aMotBx[nI],19,01)
			oResponse['motivos'][nX]['comissao']  := substr(aMotBx[nI],26,01)
			oResponse['motivos'][nX]['carteira']  := substr(aMotBx[nI],34,01)
			oResponse['motivos'][nX]['cheque']    := substr(aMotBx[nI],41,01)
			nX++
		EndIf
	Next
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JNatFuncion(nPage, nPageSize, cSearchKey, cNomeFunc)
Busca as naturezas

@since 27/08/2019

@param nPage       - Numero da página
@param nPageSize   - Quantidade de itens na página
@param cSearchKey  - palavra a ser pesquisada no código de natureza.
@param cCodNat     - Código da natureza a ser pesquisado.
@param cFilCCJur   - Centro de custo da natureza a ser pesquisado.
/*/
//-------------------------------------------------------------------
Function WSGetNat(nPage, nPageSize, cSearchKey, cCodNat, cFilCCJur)
Local oResponse    := JSonObject():New()
Local cAliasNat    := ""
Local aArea 	   := GetArea()
Local nIndexJSon   := 0
Local nQtdReg      := 0
Local cQuery       := ""

Default nPage      := 1
Default nPageSize  := 10
Default cSearchKey := ""
Default cCodNat    := ""
Default cFilCCJur  := ""

	cQuery :=  " SELECT ED_CODIGO, ED_DESCRIC, ED_TPCOJR, ED_CCJURI, ED_DESFAT "
	cQuery +=    " FROM " + RetSqlName("SED") + " SED "
	cQuery +=   " WHERE ED_MSBLQL = '2' AND ED_CPJUR = '1' AND D_E_L_E_T_ = ' ' "
	cQuery +=     " AND ED_FILIAL = '" + xFilial("SED") + "'"

	If !Empty(cFilCCJur)
		cQuery += " AND " + cFilCCJur
	EndIf

	If !Empty(cSearchKey)
		cSearchKey := StrTran( JurLmpCpo( cSearchKey, .F., .F. ), '#', '' )
		cQuery += " AND (LOWER(ED_CODIGO) LIKE '%" + Lower(Trim(cSearchKey)) + "%' "
		cQuery +=  " OR LOWER(" + JurFormat("ED_DESCRIC", .T./*lAcentua*/) + ") LIKE '%" + Lower(Trim(cSearchKey)) + "%')"
	EndIf

	If !Empty(cCodNat)
		cQuery += " AND ED_CODIGO = '" + cCodNat + "'
	EndIf

	cQuery    := ChangeQuery(cQuery)
	cAliasNat := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasNat, .T., .F. )

	oResponse['naturezas'] := {}

	nQtdRegIni := ((nPage-1) * nPageSize)

	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	While !(cAliasNat)->(Eof())

		nQtdReg++

		// Verifica se o registro está no range da pagina
		If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)

			nIndexJSon++
			Aadd(oResponse['naturezas'], JsonObject():New())

			oResponse['naturezas'][nIndexJSon]['codigo']            := EncodeUTF8((cAliasNat)->ED_CODIGO)
			oResponse['naturezas'][nIndexJSon]['descricao']         := JConvUTF8((cAliasNat)->ED_DESCRIC)
			oResponse['naturezas'][nIndexJSon]['descricaoConsulta'] := StrTran(JurLmpCpo((cAliasNat)->ED_DESCRIC, .F., .T. ), '#', ' ')
			oResponse['naturezas'][nIndexJSon]['tipoConta']         := (cAliasNat)->ED_TPCOJR
			oResponse['naturezas'][nIndexJSon]['cCusto']            := (cAliasNat)->ED_CCJURI
			oResponse['naturezas'][nIndexJSon]['cDesFat']           := (cAliasNat)->ED_DESFAT

		EndIf

		(cAliasNat)->( dbSkip())
	End

	(cAliasNat)->( DbCloseArea() )
	RestArea(aArea)

Return oResponse


//-------------------------------------------------------------------
/*/{Protheus.doc} GET getNatureza
Lista de Naturezas - GPEA010

@since 27/08/2019
@version 1.0

@param page       - Numero da página
@param pageSize   - Quantidade de itens na página
@param cDescriNat - palavra a ser pesquisada na descriçao da natureza
@param searchKey  - Código da natureza

http://localhost:12173/rest/WSPfsAppCP/getNatureza
/*/
//-------------------------------------------------------------------
WSMETHOD GET getNatureza WSRECEIVE page, pageSize, searchKey, natCod, filtCCJuri WSREST WSPfsAppCP
Local oResponse     := Nil
Local nPage         := Self:page
Local nPageSize     := Self:pageSize
Local cSearchKey    := Self:searchKey
Local cCodNat  		:= Self:natCod
Local cFilCCJuri    := Self:filtCCJuri

	Self:SetContentType("application/json")

	oResponse := WSGetNat(nPage, nPageSize, cSearchKey,cCodNat, cFilCCJuri)

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} WSGetTit
Retorna as informações do título ao editar um registro no PagPFS

@param cCodTitulo - código do título
@since 17/05/2022
//-------------------------------------------------------------------*/
Function WSGetTit(cCodTitulo)
Local oResponse    := JSonObject():New()
Local cTmpAlias    := ""
Local aArea        := GetArea()
Local cExtFlds     := ""
Local cCpoCustom   := ""
Local nPosPagPix   := -1
Local nI           := 0

Default cCodTitulo := ""

	// Pega os campos customizados
	For nI := 1 to Len(aCstFldsSE2)
		If getSx3Cache(aCstFldsSE2[nI][1], 'X3_CONTEXT') == "R"
			cCpoCustom += "," + aCstFldsSE2[nI][1] // Como o campo é adicionado sempre no começo da query não precisa tratar a ultima posição
		EndIf
	Next nI

	DbSelectArea("FKF")
	nPosPagPix := FKF->(ColumnPos("FKF_PAGPIX"))

	cExtFlds := "%" + cCpoCustom + cExtFlds + "%"

	//Utilizado o Embebed SQL por conta do campo FKF_PAGPIX que estava retornando nulo
	cTmpAlias := GetNextAlias()
	BeginSql Alias cTmpAlias
		Select 
			E2_FILIAL,E2_PREFIXO,E2_FORNECE,E2_LOJA,E2_NUM,E2_PARCELA,E2_NATUREZ,E2_VALOR,E2_SALDO,E2_VLCRUZ, 
			E2_HIST,E2_TIPO,E2_MOEDA,E2_TXMOEDA,E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_ISS,E2_BASEISS,E2_PRISS,E2_IRRF, 
			E2_BASEIRF,E2_INSS,E2_BASEINS,E2_PRINSS,E2_CODINS,E2_SEST,E2_COFINS,E2_BASECOF,E2_PIS,E2_STATUS, 
			E2_BASEPIS,E2_CSLL,E2_BASECSL,E2_FAMAD,E2_PARCFAM,E2_CIDE,E2_DATALIB,E2_PARCCID,E2_FABOV,E2_PARCFAB, 
			E2_FACS,E2_PARCFAC,E2_PERIOD,E2_VARIAC,E2_PARCFMP,E2_AGLIMP,E2_APLVLMN, 
			E2_ACRESC,E2_DECRESC,E2_DESDOBR,E2_LINDIG,E2_FORBCO,E2_FORCTA,E2_FORAGE,E2_FCTADV,E2_FAGEDV,E2_FORMPAG, 
			FK7_FILIAL,FK7_IDDOC,FK7_CHAVE, E2_ORIGEM, ED_CCJURI, ED_DESFAT, FKF.R_E_C_N_O_
			%Exp:cExtFlds%
		From %Table:SE2% SE2
			Left Join %Table:FK7% FK7 on
				FK7.FK7_FILIAL = %xFilial:FK7%
				AND FK7_ALIAS = 'SE2'
				AND FK7_CHAVE = E2_FILIAL  || '|' ||
								E2_PREFIXO || '|' ||
								E2_NUM     || '|' ||
								E2_PARCELA || '|' ||
								E2_TIPO    || '|' ||
								E2_FORNECE || '|' ||
								E2_LOJA
				AND FK7.%NotDel%
			Left Join %Table:FKF% FKF on
				FKF.FKF_FILIAL = %xFilial:FKF%
				AND FKF_IDDOC = FK7_IDDOC
				AND FKF.%NotDel%
			Inner Join %Table:SED% SED on
				SED.ED_FILIAL = %xFilial:SED%
				AND ED_CODIGO = E2_NATUREZ
				AND SED.%NotDel%
		Where
			E2_FILIAL||E2_PREFIXO||E2_NUM||E2_PARCELA||E2_TIPO||E2_FORNECE||E2_LOJA = %Exp:cCodTitulo%
			AND SE2.%NotDel%
	EndSql

	If (cTmpAlias)->(!Eof())
		oResponse['titulo'] := JSonObject():New()
		
		oResponse['pk']                   := Encode64(StrTran((cTmpAlias)->FK7_CHAVE, '|', ''))
		oResponse['titulo']["E2_FILIAL"]  := (cTmpAlias)->E2_FILIAL
		oResponse['titulo']["E2_PREFIXO"] := (cTmpAlias)->E2_PREFIXO
		oResponse['titulo']["E2_FORNECE"] := (cTmpAlias)->E2_FORNECE
		oResponse['titulo']["E2_LOJA"]    := (cTmpAlias)->E2_LOJA
		oResponse['titulo']["E2_NUM"]     := EncodeUTF8((cTmpAlias)->E2_NUM)
		oResponse['titulo']["E2_PARCELA"] := (cTmpAlias)->E2_PARCELA
		oResponse['titulo']["E2_NATUREZ"] := (cTmpAlias)->E2_NATUREZ
		oResponse['titulo']["E2_VALOR"]   := (cTmpAlias)->E2_VALOR
		oResponse['titulo']["E2_SALDO"]   := (cTmpAlias)->E2_SALDO
		oResponse['titulo']["E2_VLCRUZ"]  := (cTmpAlias)->E2_VLCRUZ
		oResponse['titulo']["E2_HIST"]    := EncodeUTF8((cTmpAlias)->E2_HIST)
		oResponse['titulo']["E2_TIPO"]    := (cTmpAlias)->E2_TIPO
		oResponse['titulo']["E2_MOEDA"]   := (cTmpAlias)->E2_MOEDA
		oResponse['titulo']["E2_TXMOEDA"] := (cTmpAlias)->E2_TXMOEDA
		oResponse['titulo']["E2_EMISSAO"] := (cTmpAlias)->E2_EMISSAO
		oResponse['titulo']["E2_VENCTO"]  := (cTmpAlias)->E2_VENCTO
		oResponse['titulo']["E2_VENCREA"] := (cTmpAlias)->E2_VENCREA
		oResponse['titulo']["E2_ISS"]     := (cTmpAlias)->E2_ISS
		oResponse['titulo']["E2_BASEISS"] := (cTmpAlias)->E2_BASEISS
		oResponse['titulo']["E2_PRISS"]   := (cTmpAlias)->E2_PRISS
		oResponse['titulo']["E2_IRRF"]    := (cTmpAlias)->E2_IRRF
		oResponse['titulo']["E2_BASEIRF"] := (cTmpAlias)->E2_BASEIRF
		oResponse['titulo']["E2_INSS"]    := (cTmpAlias)->E2_INSS
		oResponse['titulo']["E2_BASEINS"] := (cTmpAlias)->E2_BASEINS
		oResponse['titulo']["E2_PRINSS"]  := (cTmpAlias)->E2_PRINSS
		oResponse['titulo']["E2_CODINS"]  := (cTmpAlias)->E2_CODINS
		oResponse['titulo']["E2_SEST"]    := (cTmpAlias)->E2_SEST
		oResponse['titulo']["E2_COFINS"]  := (cTmpAlias)->E2_COFINS
		oResponse['titulo']["E2_BASECOF"] := (cTmpAlias)->E2_BASECOF
		oResponse['titulo']["E2_PIS"]     := (cTmpAlias)->E2_PIS
		oResponse['titulo']["E2_BASEPIS"] := (cTmpAlias)->E2_BASEPIS
		oResponse['titulo']["E2_CSLL"]    := (cTmpAlias)->E2_CSLL
		oResponse['titulo']["E2_BASECSL"] := (cTmpAlias)->E2_BASECSL
		oResponse['titulo']["E2_FAMAD"]   := (cTmpAlias)->E2_FAMAD
		oResponse['titulo']["E2_PARCFAM"] := (cTmpAlias)->E2_PARCFAM
		oResponse['titulo']["E2_CIDE"]    := (cTmpAlias)->E2_CIDE
		oResponse['titulo']["E2_PARCCID"] := (cTmpAlias)->E2_PARCCID
		oResponse['titulo']["E2_FABOV"]   := (cTmpAlias)->E2_FABOV
		oResponse['titulo']["E2_PARCFAB"] := (cTmpAlias)->E2_PARCFAB
		oResponse['titulo']["E2_FACS"]    := (cTmpAlias)->E2_FACS
		oResponse['titulo']["E2_PARCFAC"] := (cTmpAlias)->E2_PARCFAC
		oResponse['titulo']["E2_PERIOD"]  := (cTmpAlias)->E2_PERIOD
		oResponse['titulo']["E2_VARIAC"]  := (cTmpAlias)->E2_VARIAC
		oResponse['titulo']["E2_PARCFMP"] := (cTmpAlias)->E2_PARCFMP
		oResponse['titulo']["E2_AGLIMP"]  := (cTmpAlias)->E2_AGLIMP
		oResponse['titulo']["E2_APLVLMN"] := (cTmpAlias)->E2_APLVLMN
		oResponse['titulo']["E2_ACRESC"]  := (cTmpAlias)->E2_ACRESC
		oResponse['titulo']["E2_DECRESC"] := (cTmpAlias)->E2_DECRESC
		oResponse['titulo']["E2_DESDOBR"] := (cTmpAlias)->E2_DESDOBR
		oResponse['titulo']["E2_LINDIG"]  := (cTmpAlias)->E2_LINDIG
		oResponse['titulo']["E2_FORBCO"]  := (cTmpAlias)->E2_FORBCO
		oResponse['titulo']["E2_FORCTA"]  := (cTmpAlias)->E2_FORCTA
		oResponse['titulo']["E2_FORAGE"]  := (cTmpAlias)->E2_FORAGE
		oResponse['titulo']["E2_FCTADV"]  := (cTmpAlias)->E2_FCTADV
		oResponse['titulo']["E2_FAGEDV"]  := (cTmpAlias)->E2_FAGEDV
		oResponse['titulo']["E2_FORMPAG"] := (cTmpAlias)->E2_FORMPAG
		oResponse['titulo']["FK7_FILIAL"] := (cTmpAlias)->FK7_FILIAL
		oResponse['titulo']["FK7_IDDOC"]  := (cTmpAlias)->FK7_IDDOC
		oResponse['titulo']["E2_ORIGEM"]  := (cTmpAlias)->E2_ORIGEM
		oResponse['titulo']["ED_CCJURI"]  := (cTmpAlias)->ED_CCJURI
		oResponse['titulo']["ED_DESFAT"]  := (cTmpAlias)->ED_DESFAT

		If nPosPagPix > 0
			FKF->(DbGoTo((cTmpAlias)->R_E_C_N_O_))
			oResponse['titulo']["FKF_PAGPIX"] := EncodeUTF8(FKF->FKF_PAGPIX)
		EndIf

		//------ CAMPOS ADICIONAIS
		If !Empty(aCstFldsSE2)
			For nI := 1 to Len(aCstFldsSE2)
				If getSx3Cache(aCstFldsSE2[nI][1], 'X3_CONTEXT') == "R"
					If getSx3Cache(aCstFldsSE2[nI][1], 'X3_TIPO') == "N"
						oResponse['titulo'][aCstFldsSE2[nI][1]] := (cTmpAlias)->(FieldGet(FieldPos(aCstFldsSE2[nI][1])))
					Else
						oResponse['titulo'][aCstFldsSE2[nI][1]] := JConvUTF8((cTmpAlias)->(FieldGet(FieldPos(aCstFldsSE2[nI][1]))))
					EndIf
				EndIf
			Next nI
		EndIf
	Endif

	(cTmpAlias)->( DbCloseArea() )
	RestArea(aArea)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getTituPag
Lista de Titulos a pagar

@since 27/08/2019
@version 1.0
http://localhost:12173/rest/WSPfsAppCP/getTituPag
/*/
//-------------------------------------------------------------------
WSMETHOD GET getTituPag WSRECEIVE  cCodTitulo WSREST WSPfsAppCP
Local oResponse     := Nil
Local cCodTitulo  	:= Decode64(self:cCodTitulo)

	Self:SetContentType("application/json")

	oResponse := WSGetTit(cCodTitulo)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	oResponse:FromJSon("{}")
	oResponse := Nil
	
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} POST - BancFornec
Cadastra o banco do Fonecedor

@example POST  -> http://localhost:12173/rest/WSPfsAppCP/bancofornecedor/V1lLMDAzLTAw
@example Body  ->{
					"banco": "341", 
					"agencia": "9594",
					"digAgencia": "0",
					"Conta": "999999",
					"digConta": "9"
					"principal": "1" // 1 - principal, 2 - Normal
					"tipoonta": "1"  // 1 - Corrente, 2 - Poupança
				}

@since 20/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST BancFornec PATHPARAM codForn WSREST WSPfsAppCP
Local oRequest    := JsonObject():New()
Local oResponse   := JSonObject():New()
Local cBody       := Self:GetContent()
Local cPKFornec   := FWxFilial('SA2') + '-' + DECODE64( Self:codForn )
Local aRet        := {}

	oRequest:FromJson(cBody)

	aRet := AddBancFornec(cPKFornec, oRequest)

	If aRet[1]
		Self:SetContentType("application/json")
		oResponse['status'] := 'OK'
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		SetRestFault(400, JConvUTF8(aRet[2]))
	EndIf

Return  aRet[1]

//-------------------------------------------------------------------
/*/{Protheus.doc} Function AddBancFornec(cPKFornec, oRequest)
Cadastra o banco do Fonecedor

@param cPKFornec - Chave primaria do fornecedor
@param oRequest  - Objeto com os dados do banco

@return .T. - Sucesso

@since 20/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddBancFornec(cPKFornec, oRequest)
Local aArea       := GetArea()
Local cBanco      := AVKEY(oRequest['banco'],'FIL_BANCO')
Local cAgencia    := AVKEY(oRequest['agencia'],'FIL_AGENCI')
Local cDigAgencia := AVKEY(oRequest['digAgencia'],'FIL_DVAGE')
Local cConta      := AVKEY(oRequest['conta'],'FIL_CONTA')
Local cDigConta   := AVKEY(oRequest['digConta'],'FIL_DVCTA')
Local cPrincipal  := AVKEY(oRequest['principal'],'FIL_TIPO')
Local cTipoConta  := AVKEY(oRequest['tipoConta'],'FIL_TIPCTA')
Local cErrorMsg   := STR0093 // "Erro ao gravar o banco do fornecedor"
Local lContinua   := .T.
Local lRet        := .T.
Local aFornecedor := StrToKArr(cPKFornec,'-')
Local aRet        := {lRet, cErrorMsg}

	cPKFornec := AVKEY(aFornecedor[1],'A2_FILIAL')
	cPKFornec += AVKEY(aFornecedor[2],'A2_COD')
	cPKFornec += AVKEY(aFornecedor[3],'A2_LOJA')

	cPrincipal := If(Empty(cPrincipal), '1', cPrincipal)
	cTipoConta := If(Empty(cTipoConta), '1', cTipoConta)

	If !Empty(cBanco) .AND. !Empty(cAgencia) .AND. !Empty(cConta)
		// Verifica se o fornecedor já possui um banco cadastrado
		DbSelectArea("FIL")
		DbSetOrder(1) //FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+FIL_BANCO+FIL_AGENCI+FIL_CONTA

		// Verifica se o banco já está cadastrado
		If ('FIL')->( DbSeek(cPKFornec + "1" + cBanco + cAgencia + cConta) )
			cErrorMsg := STR0094 // "Banco já cadastrado"
			lRet := .F.
		ElseIf cPrincipal == '1' .AND. ('FIL')->( DbSeek(cPKFornec) )
			// Ajusta o fornecedor principal caso exista
			While lContinua .AND. FIL->(!Eof()) .AND. cPKFornec == FIL->FIL_FILIAL + FIL->FIL_FORNEC + FIL->FIL_LOJA
				// Muda o tipo para normal
				If (FIL_TIPO == '1')
					RecLock("FIL", .F.)
						FIL->FIL_TIPO := '2'
					FIL->( MsUnlock() )
					lContinua := .F.
				EndIf

				FIL->( dbSkip() )
			End
		EndIf

		// Cadastra o novo banco como principal
		If lRet .AND.RecLock("FIL", .T.)
			FIL->FIL_FILIAL := SubStr(cPKFornec, 1, TAMSX3("A2_FILIAL")[1])
			FIL->FIL_FORNEC := SubStr(cPKFornec, TAMSX3("A2_FILIAL")[1] +1, TAMSX3("A2_COD")[1])
			FIL->FIL_LOJA   := SubStr(cPKFornec, TAMSX3("A2_FILIAL")[1] + TAMSX3("A2_COD")[1] +1)
			FIL->FIL_TIPO   := cPrincipal
			FIL->FIL_BANCO  := cBanco
			FIL->FIL_AGENCI := cAgencia
			FIL->FIL_DVAGE  := cDigAgencia
			FIL->FIL_CONTA  := cConta
			FIL->FIL_DVCTA  := cDigConta
			FIL->FIL_DETRAC := '0'
			FIL->FIL_MOEDA  := 1
			FIL->FIL_TIPCTA := cTipoConta
			FIL->FIL_MOVCTO :='1'

			FIL->( MsUnlock() )

			// Atualiza SA2 com o novo banco
			If cPrincipal == "1"		
				DbSelectArea("SA2")
				DbSetOrder(1) //A2_FILIAL+A2_COD+A2_LOJA
				lRet := SA2->( DbSeek(cPKFornec) )

				If lRet .AND. RecLock("SA2", .F.)
					SA2->A2_BANCO   := cBanco
					SA2->A2_AGENCIA := cAgencia
					SA2->A2_DVAGE   := cDigAgencia
					SA2->A2_NUMCON  := cConta
					SA2->A2_DVCTA   := cDigConta
					SA2->( MsUnlock() )
				EndIf
			EndIf
		EndIf
	else
		lRet := .F.
	EndIf

	RestArea(aArea)

	aRet := {lRet, cErrorMsg}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} POST - BancFornec
Gera op arquivo CNAB para exportação

@example POST  -> http://localhost:12173/rest/WSPfsAppCP/expcnab
@example Body  ->	{
						"titulos":[9085,9086],
						"modPag": "01" ,
						"tipoPag": "20"
						"arq_Configuracao": "F420.2pe", 
						"arq_Saida": "teste.rem",
						"banco": "RND", 
						"agencia": "001", 
						"conta": "000001", 
						"subConta": "002", 
						"configCnab": 2, 
					}

@since 19/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST ExpCNAB WSREST WSPfsAppCP
Local aBordero  := {}
Local cBody     := Self:GetContent()
Local cFile     := ""
Local cTitulos  := ""
Local cBKPFil   := cFilAnt
Local lRet      := .F.
Local oRequest  := JsonObject():New()
Local oResponse := JSonObject():New()
Local cLocEnv   := Alltrim(SuperGetMV( "MV_LOCENV" , .F. , .F. ))
Local cExtensao := ""

	oRequest:FromJson(DecodeUTF8(cBody))
	cTitulos := JurArr2Str(oRequest["titulos"])

	// Trata a extensão do arquivo a ser gerado
	If !("." $ oRequest['extensao'])
		cExtensao := "." + oRequest['extensao']
	EndIf

	If File(oRequest['arq_Configuracao'])

		cFilAnt  := oRequest["filial"]
		aBordero := GerBordero(cTitulos, oRequest["modPag"], oRequest["tipoPag"])
		cFile    := JGeraCNAB(aBordero, oRequest, cLocEnv)

		oResponse['titulos'] := aBordero
		oResponse['arquivo'] := cFile

		If File(cFile)
			oResponse['export'] := {}
			Aadd(oResponse['export'], JsonObject():New())
			oResponse['export'][1]['fileurl']  := ""
			oResponse['export'][1]['extensao']  := cExtensao
			oResponse['export'][1]['filedata'] := encode64(DownloadBase(cFile))
			oResponse['export'][1]['namefile']  := oRequest["arq_Saida"] + cExtensao
			oResponse['export'][1]['diretorio'] := cFile

			Self:SetResponse(oResponse:toJson())
			lRet := .T.
		Else
			setRespError(400, JConvUTF8(STR0096)) // "Não foi possível gerar o CNAB"
		EndIf

		cFilAnt := cBKPFil

		oResponse:fromJson("{}")
		oResponse := NIL
	Else
		setRespError(400, I18N(STR0097 , {oRequest['arq_Configuracao']})) //"O arquivo de configuração #1 não foi encontrado no servidor. Verifique!"
	EndIf
 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Static Function GerBordero(cTitulos, cModPag, tipoPag)
Gera os borderôs de pagamento

@param cTitulos, string, R_E_C_N_O_ dos títulos separados por virgula
@param cModPag, string, Modelo de pafamento utilizado
@param cTitulos, string, Tipo de pagamento utilizado

@return aBordero, array, Array com os títulos
		aBordero[1][1] = R_E_C_N_O_ do título
		aBordero[1][2] = Número do borderô gerado
		aBordero[1][3] = Código do banco
@since 19/09/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerBordero(cTitulos, cModPag, tipoPag)
Local cAlias     := ""
Local cQry       := ""
Local aBorAut    := {}
Local aBordero   := {}

	// Busca dados dos títulos
	cQry := " SELECT SE2.R_E_C_N_O_ NUM_REG,"
	cQry +=        " SE2.E2_PORTADO, "
	cQry +=        " SE2.E2_FORBCO, "
	cQry +=        " SE2.E2_FORAGE , "
	cQry +=        " SE2.E2_FORCTA , "
	cQry +=        " SE2.E2_NUMBOR "
	cQry +=   " FROM " + RetSqlName('SE2') + " SE2"
	cQry +=  " WHERE SE2.D_E_L_E_T_ = ' ' "
	cQry +=    " AND SE2.R_E_C_N_O_ in (" + cTitulos + ") "
	cQry += "ORDER BY E2_FORBCO, E2_FORAGE, E2_FORCTA, NUM_REG "

	cAlias := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQry ), cAlias, .T., .F. )

	aAdd(aBorAut, cAlias )
	aAdd(aBorAut, (cAlias)->E2_FORBCO )
	aAdd(aBorAut, (cAlias)->E2_FORAGE )
	aAdd(aBorAut, (cAlias)->E2_FORCTA )
	aAdd(aBorAut, cModPag )
	aAdd(aBorAut, tipoPag )
	aAdd(aBorAut, Date() )
	aAdd(aBorAut, .F. )

	FinA241(0, aBorAut)

	( cAlias )->( dbCloseArea() )
	
	// Valida borderôs gerados
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQry ), cAlias, .T., .F. )

	While !(cAlias)->(Eof())
		aAdd(aBordero, {(cAlias)->NUM_REG, (cAlias)->E2_NUMBOR, (cAlias)->E2_FORBCO})
		(cAlias)->( dbSkip() )
	End

	( cAlias )->( dbCloseArea() )

Return aBordero

//-------------------------------------------------------------------
/*/{Protheus.doc} StatiC Function JGeraCNAB(aBordero, oParams, cLocEnv)
Gera o arquivo CNAB e disponibiliza para download

@param aBordero - Array com os borderôs gerados
@param oParams - Parâmetros para geração do CNAB
@param cLocEnv  - Conteúdo do MV_LOCENV

@return cFile - Nome do arquivo gerado

@since 20/05/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JGeraCNAB(aBordero, oParams, cLocEnv)
Local cFile  := ""
Local cDiretorio := "cnab_pfs"
Local cExtensao  := oParams['extensao']
Local aPerg  := {}

Private INCLUI := .F. //  Variável utilizada na função FA420GERA

	If !("." $ cExtensao)
		cExtensao := "." + cExtensao
	EndIf

	oParams["arq_Saida"] := lower(AllTrim(oParams["arq_Saida"]))

	// Arquivo de saída (CNAB_banco_NumeroBorderô.REM)
	If Empty(oParams["arq_Saida"])
		cFile := '\CNAB_' + oParams["banco"] + "_" + AllTrim(aBordero[1][2])
	ElseIf ! (SubStr(oParams["arq_Saida"], 1, 1) $ "/\") .And. !(":" $ oParams["arq_Saida"]) 
		cFile := "\" +  oParams["arq_Saida"]
	Else
		cFile := oParams["arq_Saida"]
	EndIf

	// Cria os diretórios caso não existam
	If !Empty(cLocEnv) // Conteudo do MV_LOCENV

		If At("/", cLocEnv) > 0 .OR. At("\", cLocEnv) > 0
			cLocEnv := Substr(cLocEnv, 2, Len(cLocEnv))
		EndIf

		// Verifica se existe o diretório do parâmetro. Se não existir irá criar
		If !EXISTDIR( ".\" + cLocEnv )
			MAKEDIR( ".\" + cLocEnv )
		EndIf

		// Verifica se existe a pasta cnab_pfs.
		If ":" $ cLocEnv
			If !EXISTDIR(cLocEnv + "\" + cDiretorio)
				MAKEDIR(cLocEnv + "\" + cDiretorio)
			EndIf

		Else
			If !EXISTDIR(".\" + cLocEnv + "\" + cDiretorio)
				MAKEDIR(".\" + cLocEnv + "\" + cDiretorio)
			EndIf
		EndIf

	Else
		cFile := cDiretorio + cFile
		If !EXISTDIR(".\" + cDiretorio )
			MAKEDIR(".\" + cDiretorio )
		EndIf
	EndIf

	cFile := JRepDirSO(cDiretorio + SubStr(cFile, rAt("\",cFile)))

	// Pergunte AFI420
	aAdd(aPerg, aBordero[1][2])                   // mv_par01 ( Do Bordero )
	aAdd(aPerg, aBordero[1][2])                   // mv_par02 ( Ate Bordero )
	aAdd(aPerg, oParams["arq_Configuracao"])      // mv_par03 ( Arq.Configuracao )
	aAdd(aPerg, cFile )                           // mv_par04 ( Arq. Saida )
	aAdd(aPerg, PadR(oParams["banco"], 3," "))    // mv_par05 ( Banco )
	aAdd(aPerg, PadR(oParams["agencia"], 5," "))  // mv_par06 ( Agencia )
	aAdd(aPerg, PadR(oParams["conta"], 10," "))   // mv_par07 ( Conta )
	aAdd(aPerg, PadR(oParams["subConta"], 3," ")) // mv_par08 ( Sub-Conta )
	aAdd(aPerg, oParams["configCnab"])            // mv_par09 ( Configuracao Cnab ? )
	aAdd(aPerg, 2)                                // mv_par10 ( Cons.Filiais Abaixo ) 
	aAdd(aPerg, '  ')                             // mv_par11 ( Filial de )
	aAdd(aPerg, 'ZZ')                             // mv_par12 ( Filial Ate )
	aAdd(aPerg, 0)                                // mv_par13 ( Receita Bruta Acumulada )
	aAdd(aPerg, 2)                                // mv_par14 ( Seleciona Filiais )

	If !Empty(cLocEnv)
		cFile := cLocEnv + "\" + cFile + cExtensao
	Else
		cFile := cFile + cExtensao
	EndIf

	If File(cFile)
		FErase(cFile)
	EndIf

	// Executa a geração do arquivo
	Fina420(2, aPerg)

Return cFile

//-------------------------------------------------------------------
/*/{Protheus.doc} POST - RetCNAB
Processa o Retorno do CNAB

@param Body {
				"empresa": "T1",
				"codigo": "D MG 01 ",
				"descricao": "Filial Belo Horizonte"
			}

@return {
			"message": "Empresa T1 Filial D MG 01 processado com sucesso!,
			"code": "200"
		}
@since 03/11/2022
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD POST RetCNAB HEADERPARAM TENANTID WSREST WSPfsAppCP
Local cBody       := Self:GetContent()
Local oRequest    := JsonObject():New()
Local oResponse   := JSonObject():New()
Local cMsgSuccess := ""

Private lExecJob := .T.
Private aMsgSch  := {}
Private aFA205R  := {}

	oRequest:FromJson(DecodeUTF8(cBody))  //localizar fonte que executa a chamada do RetCNAB que vem do POUI para pegar o cBody pra jogar no Postam

	FINA435(cEmpAnt,cFilAnt)

	cMsgSuccess := I18N(STR0099 , { cEmpAnt,cFilAnt}) //"Empresa #1 Filial #2 processado com sucesso!"
	oResponse:FromJSon('{"message": "' + cMsgSuccess + '", "code": "200"}')

	Self:SetResponse(oResponse:toJson())
	oResponse := Nil
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET bcoCNAB
Busca bancos de acordo com parametro de bancos para CNAB (SEE)

@example GET -> http://127.0.0.1:9090/rest/WSPfsAppCP/bcoCNAB

@since 09/11/2022
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET bcoCNAB WSREST WSPfsAppCP

Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local oResponse  := JSonObject():New()
Local cQuery     := ""
Local nIndexJSon := 0

	cQuery += " SELECT DISTINCT "
	cQuery +=        " SEE.EE_FILIAL, "
	cQuery +=        " SEE.EE_CODIGO, "
	cQuery +=        " SEE.EE_AGENCIA, "
	cQuery +=        " SEE.EE_DVAGE, "
	cQuery +=        " SEE.EE_CONTA, "
	cQuery +=        " SEE.EE_DVCTA, "
	cQuery +=        " SEE.EE_SUBCTA, "
	cQuery +=        " SEE.EE_EXTEN, "
	cQuery +=        " SEE.EE_RETAUT, "
	cQuery +=        " SEE.EE_DIRPAG, "
	cQuery +=        " SEE.EE_BKPPAG, "
	cQuery +=        " COALESCE(SA6.A6_NOME, ' ') A6_NOME "
	cQuery += " FROM " + RetSqlName("SEE") + " SEE "
	cQuery +=             " INNER JOIN " + RetSqlName("SA6") + " SA6 "
	cQuery +=                 " ON SA6.A6_COD = SEE.EE_CODIGO "
	cQuery +=                     " AND SA6.A6_AGENCIA = SEE.EE_AGENCIA "
	cQuery +=                     " AND SA6.A6_NUMCON = SEE.EE_CONTA "
	cQuery +=                     " AND SA6.A6_DVAGE = SEE.EE_DVAGE "
	cQuery +=                     " AND SA6.A6_DVCTA = SEE.EE_DVCTA "
	cQuery +=                     JSqlFilCom("SEE", "SA6",,, "EE_FILIAL", "A6_FILIAL")
	cQuery +=                     " AND SA6.D_E_L_E_T_ = ' ' "
	cQuery +=             " INNER JOIN " + RetSqlName("FIL") + " FIL "
	cQuery +=                 " ON FIL.FIL_BANCO = SA6.A6_COD "
	cQuery +=                     " AND FIL.FIL_AGENCI = SA6.A6_AGENCIA "
	cQuery +=                     " AND FIL.FIL_CONTA = SA6.A6_NUMCON "
	cQuery +=                     JSqlFilCom("FIL", "SA6",,, "FIL_FILIAL", "A6_FILIAL")
	cQuery +=                     " AND FIL.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SEE.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	oResponse['bancos'] := {}

	While !(cAlias)->(Eof())
		nIndexJSon++
		Aadd(oResponse['bancos'], JsonObject():New())
		oResponse['bancos'][nIndexJSon]['filial']     := (cAlias)->(EE_FILIAL)
		oResponse['bancos'][nIndexJSon]['nome']       := JConvUTF8((cAlias)->(A6_NOME))
		oResponse['bancos'][nIndexJSon]['numBanco']   := (cAlias)->(EE_CODIGO)
		oResponse['bancos'][nIndexJSon]['agencia']    := (cAlias)->(EE_AGENCIA)
		oResponse['bancos'][nIndexJSon]['digAgencia'] := (cAlias)->(EE_DVAGE)
		oResponse['bancos'][nIndexJSon]['conta']      := (cAlias)->(EE_CONTA)
		oResponse['bancos'][nIndexJSon]['digConta']   := (cAlias)->(EE_DVCTA)
		oResponse['bancos'][nIndexJSon]['subConta']   := (cAlias)->(EE_SUBCTA)
		oResponse['bancos'][nIndexJSon]['extensao']   := (cAlias)->(EE_EXTEN)
		oResponse['bancos'][nIndexJSon]['retauto']    := (cAlias)->(EE_RETAUT)
		oResponse['bancos'][nIndexJSon]['dirpag']     := (cAlias)->(EE_DIRPAG)
		oResponse['bancos'][nIndexJSon]['bkppag']     := (cAlias)->(EE_BKPPAG)

		(cAlias)->( dbSkip() )
	End

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	( cAlias )->( dbCloseArea() )
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FuncReplace
Susbstitui as funções ADVPL conforme os os dados de empresa e filial.

@param cFunction, Nome da função a ser substituída na query
@param cTexto   , String com o texto a ser tratado

@author Abner Fogaça | Ronaldo 
@since 24/11/2022
/*/
//-------------------------------------------------------------------
Static Function FuncReplace(cFunction, cTexto)
Local nI   := 1
Local cAux := ""

	While nI > 0
		nI   := At(cFunction, cTexto)
		cAux := SubStr(cTexto, nI)
		If nI > 0
			nI     := At(")", cAux)
			cAux   := SubStr(cAux, 1, nI)
			cTexto := StrTran(cTexto, cAux, &cAux)
		EndIf
	End

Return cTexto
