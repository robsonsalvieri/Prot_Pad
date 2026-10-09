#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "backofficeapprovals.ch"

static __oAprHshQry := HMNew() // Objeto que armazena as querys base

//-------------------------------------------------------------------
/*/{Protheus.doc} backofficeApprovals
API para retornar os dados relacionados ao processo de aprovação 
de alçadas para o cenário de aprovação 
via aplicativo Meu Protheus.

@author TOTVS
@since 25/07/2023 
/*/
//-------------------------------------------------------------------
WSRESTFUL backofficeApprovals DESCRIPTION STR0001//"Aprovação de documentos"


	WSDATA page			            AS INTEGER OPTIONAL // página
	WSDATA pageSize		            AS INTEGER OPTIONAL // tamanho da página
	WSDATA OrderBy                  AS INTEGER OPTIONAL // ordenação na demonstração do resultado dos documentos 1 = decrescente 2 = crescente
	WSDATA typeApprovals            AS STRING           // Tipo do documento a ser aprovado / Tipo do Documento a ter os itens consultados
	WSDATA documentId               AS STRING           // Identificador(RecNo) do documento(SCR)
	WSDATA approverCode		        AS STRING OPTIONAL  // código do aprovador
	WSDATA searchKey                AS STRING OPTIONAL  // chave de pesquisa
	WSDATA initDate                 AS STRING OPTIONAL  // data inicial
	WSDATA endDate                  AS STRING OPTIONAL  // data final
	WSDATA documentType             AS STRING OPTIONAL  // tipo de documento
	WSDATA documentBranch           AS STRING OPTIONAL  // filial do documento
	WSDATA documentStatus           AS STRING OPTIONAL  // status do documento
	WSDATA itemGroup                AS STRING OPTIONAL  // item do grupo de aprovação
	WSDATA mainTable                AS STRING OPTIONAL  // Propriedade utilizada pela classe MobileService
	WSDATA recordNumber             AS STRING OPTIONAL  //  Número da solicitação ou do pedido de compra
	WSDATA itemNumber               AS STRING OPTIONAL  // Item da solicitação ou do pedido de compra
	WSDATA itemAlias                AS STRING OPTIONAL  // Alias utilizado para carregar informações adicionais
	WSDATA itemRecno                AS INTEGER          // Recno utilizado para carregar informações adicionais
	WSDATA productCode              AS STRING OPTIONAL  // código do produto
	WSDATA objectCode               AS STRING OPTIONAL  // código do objeto de conhecimento
	WSDATA typeApproval             AS STRING OPTIONAL  // tipo de documento (PC, IP, MD, IM, SC, CT)
	WSDATA sourceName               AS STRING OPTIONAL  // nome do fonte com extensão (.prw, .tlpp, etc.)


	WSMETHOD GET approvalsList;// Retorna a lista de documentos do usuário
	DESCRIPTION STR0010; // Retorna a lista de documentos aprovados, reprovados ou pendentes de aprovação, apenas do aprovador logado
	WSSYNTAX "/api/com/approvals/v1/approvalsList";
		PATH "/api/com/approvals/v1/approvalsList";
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET getItemsByDoc;
		DESCRIPTION STR0013; //Obtem a lista de itens do documento
	WSSYNTAX "/api/com/approvals/v1/{typeApprovals}/{documentId}/items";
		PATH "/api/com/approvals/v1/{typeApprovals}/{documentId}/items";
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET itemAdditionalInformation ;
		DESCRIPTION STR0014 ;//"Retorna as informações adicionais para um item de um pedido ou solicitação de compra."
	WSSYNTAX "api/com/approvals/v1/itemAdditionalInformation";
		PATH "api/com/approvals/v1/itemAdditionalInformation";
		TTALK "v1";
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET historyByItem ;
		DESCRIPTION STR0017 ;//Retorna a lista com os últimos lançamentos de compras para o produto
	PATH "api/com/approvals/v1/historybyitem"  ;
		TTALK "v1" ;
		WSSYNTAX "api/com/approvals/v1/historybyitem" ;
		PRODUCES APPLICATION_JSON

	WSMETHOD GET attachments ;// Retorna um anexo
	DESCRIPTION STR0019 ;
		WSSYNTAX "api/com/approvals/v1/attachments/{objectCode}";
		PATH  "api/com/approvals/v1/attachments/{objectCode}";
		TTALK "v1" ;
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET listAttachments ;
		DESCRIPTION STR0020 ;// Retorna a lista de anexos
	WSSYNTAX "/api/com/approvals/v1/listAttachments/{documentId}";
		PATH  "/api/com/approvals/v1/listAttachments/{documentId}";
		TTALK "v1" ;
		PRODUCES APPLICATION_JSON;

	WSMETHOD GET getHistByDoc ;
		DESCRIPTION STR0020;// Retorna histórico de aprovação de determinado documento
	WSSYNTAX "/api/com/approvals/v1/getHistByDoc/{documentId}";
		PATH  "api/com/approvals/v1/getHistByDoc/{documentId}" ;
		TTALK "v1" ;
		PRODUCES APPLICATION_JSON;

	WSMETHOD PUT approveBatch ;//Aprovação por lote
	DESCRIPTION STR0002 ;//'Aprovação de documentos por Lote'
	WSSYNTAX "/api/com/approvals/v1/batchApprovals/{typeApprovals}" ;
		PATH "api/com/approvals/v1/batchApprovals/{typeApprovals}" ;
		PRODUCES APPLICATION_JSON ;

	WSMETHOD GET totalApprovals;
		DESCRIPTION STR0025;//Retorna a quantidade de documentos aprovados, reprovados e penedentes de aprovação do usuário
	PATH "api/com/approvals/v1/{typeApproval}/{documentStatus}/totalApprovals"  ;
		TTALK "v1" ;
		WSSYNTAX "api/com/approvals/v1/{typeApproval}/{documentStatus}/totalApprovals" ;
		PRODUCES APPLICATION_JSON

	WSMETHOD GET userSummary;
		DESCRIPTION STR0026;//Retorna um resumo com as informações do dashboard do usuário logado
	PATH "api/com/approvals/v1/userSummary"  ;
		TTALK "v1" ;
		WSSYNTAX "api/com/approvals/v1/userSummary" ;
		PRODUCES APPLICATION_JSON

	WSMETHOD GET sourceInfo;
		DESCRIPTION STR0027; //Retorna informações do fonte compilado no RPO
	PATH "/api/com/approvals/v1/sourceInfo" ;
		WSSYNTAX "/api/com/approvals/v1/sourceInfo?sourceName={sourceName}" ;
		PRODUCES APPLICATION_JSON

	WSMETHOD GET getMeasurementGroup;
		DESCRIPTION "Retorna fornecedores e clientes da medição";
		PATH "/api/com/approvals/v1/measurements/{documentId}/parties";
		TTALK "v1" ;
		WSSYNTAX "/api/com/approvals/v1/measurements/{documentId}/parties";
		PRODUCES APPLICATION_JSON;

END WSRESTFUL

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} approvalsList
    Método para retornar a lista de documentos aprovados,reprovados ou pendentes de aprovação do aprovador logado
@author Jose Renato
@since 26/07/2023
@return lRet, lógico, se a mensagem foi recebida com sucesso 
/*/
//-------------------------------------------------------------------------------------
WSMETHOD GET approvalsList WSRECEIVE documentType, documentBranch, documentStatus, initDate, endDate, searchkey, page, pageSize, orderBy  WSSERVICE backofficeApprovals
	Local oResponse             := JsonObject():New()
	Local cJson                 := ""
	Local lRet                  := .F.

	Default Self:documentType   := ""
	Default Self:documentBranch := ""
	Default Self:documentStatus := "02"
	Default Self:initDate       := ""
	Default Self:endDate        := ""
	Default Self:searchkey      := ""
	Default Self:page           := 1
	Default Self:pageSize       := 10
	Default Self:orderBy        := 1

	lRet := LoadApprovalResult( @oResponse, @Self )

	cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

	::SetResponse( cJson )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} totalApprovals
    Método para retornar o total de documentos pendentes de aprovação do aprovador logado (PC, IP, MD, IM e SC)
@author Deijai Miranda Almeida
@since 26/08/2024
@return lRet, lógico, se a mensagem foi recebida com sucesso 
/*/
//-------------------------------------------------------------------------------------
WSMETHOD GET totalApprovals PATHPARAM typeApproval, documentStatus WSSERVICE backofficeApprovals
	Local oResponse             := JsonObject():New()
	Local lRet                  := .F.
	Local cJson                 := ""

	Default Self:typeApproval   := "IP"
	Default Self:documentStatus := "02"

	lRet := GetTotalCount( @oResponse, @Self )

	cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

	::SetResponse( cJson )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadApprovalResult
Função responsável pela busca das informações de documentos em alçada

@param @oResponse, object, Objeto que armazena os registros a apresentar.
@param @oSelf, object, Objeto principal do WS

@return boolean, .T. se encontrou registros e .F. se ocorreu erro.
@author José Renato
@since 26/07/2023
/*/
//----------------------------------------------------------------------------------
Static Function LoadApprovalResult( oResponse, oSelf )
	Local oQuery
	Local cTmp          := ""
	Local nRecords      := 0
	Local lRet          := .T.
	Local lHasNext      := .T.
	Local cDocType      := ""

	dbSelectArea( "SAK" )
	dbSetOrder( 2 ) //AK_FILIAL + AK_USER

	If MsSeek( xFilial( "SAK" ) + __cUserId )
		cTmp := GetNextAlias()
		oSelf:approverCode := SAK->AK_USER
		cDocType:= oSelf:documentType

		oQuery := GetQueryApprovals( cDocType, oSelf)
		SetQueryValues( @oQuery, cDocType, oSelf )

		MPSysOpenQuery( ChangeQuery(oQuery:getFixQuery()) , cTmp )

		dbSelectArea( cTmp )

		oResponse[ "documents" ] := {}

		If ( cTmp )->( !Eof() )
			COUNT TO nRecords
			oResponse[ "documents" ] := SetJson( cTmp, oSelf )

			IF ( nRecords < oSelf:pageSize )
				lHasNext := .F.
			EndIf
		Else
			lHasNext := .F.
		EndIf

		oResponse[ "hasNext" ] := lHasNext

		( cTmp )->( DBCloseArea() )
	Else
		lRet := .F.
		SetRestFault(400, EncodeUTF8( STR0011 ), .T., 400, EncodeUTF8( STR0012 ) )
	EndIf

	oQuery := NIL
	FreeObj( oQuery )
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} GetQueryApprovals
Função responsável por chamar a geração da query relacionada ao tipo de operação
a ser realizada

@param cDocType, caracter, Identifica qual a query será retornada
@param oSelf, object, Objeto principal do WS
@param lId, lógico, se possui um número de identificação

@return object, Objeto contendo a query a ser executada pelo REST.
@author José Renato
@since 27/07/2023
/*/
//----------------------------------------------------------------------------------
Static Function GetQueryApprovals( cDocType, oSelf, lId)
	Local oPrepare
	Local cName         := ""
	Local cTreatQuery   := ""
	Local lUseCache     := .T.

	Default lId         := .F.

	If !Empty(oSelf:initDate) .OR. !Empty(oSelf:endDate) .OR. !Empty(oSelf:searchKey)
		lUseCache := .F.
	EndIf

	If Empty( cDocType )
		cDocType := "All"
	EndIf

	cName := Alltrim( 'GET_' + cDocType + IIF( lId, "_ById", "" ) ) + '_' + cEmpAnt

	If !lUseCache
		cName += "_" + DtoS(Date()) + "_" + StrTran(Time(), ":", "") + "_" + Str(Randomize(1, 1000), 4, 0)
	EndIf

	If lUseCache .AND. !HMGet( __oAprHshQry, cName, @cTreatQuery )
		cTreatQuery := CreateQueryModel( cDocType, oSelf, lId )

		If !Empty( cTreatQuery )
			HMSet( __oAprHshQry, cName, cTreatQuery )
		EndIf
	ElseIf !lUseCache
		cTreatQuery := CreateQueryModel( cDocType, oSelf, lId )
	EndIf

	If !Empty( cTreatQuery )
		oPrepare := FWPreparedStatement():New( cTreatQuery )
	EndIf
Return oPrepare

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CreateQueryModel
Função responsável por criar a query base de acordo com a operação solicitada.
As querys devem ser montadas respeitando o conceito da função FWPreparedStatement().

IMPORTANTE: Ao utilizar o controle de paginação (<<PAGE_CONTROL>>) na query, ao 
        renomear a coluna é OBRIGATÓRIO o uso do identificador "AS" para que não 
        ocorra quebra ao efetuar o parsear. Exemplo: SUM(TOTAL) AS TOTAL

@param cDocType, caracter, Identifica qual a query será montada
@param oSelf, objeto, objeto principal do WS
@param lId, lógico,  indica se retorna um registro específico

@return caracter, String contendo a query base a ser executada pelo REST.
@author Jose Renato
@since 27/07/2023
/*/
//----------------------------------------------------------------------------------
Static Function CreateQueryModel( cDocType, oSelf, lId )
	Local cQuery        := ""
	Local cOrderBy      := ""
	Local nNumLen       := 0
	Local cFields       := ""
	Local cJoin         := ""
	Local cWhere        := ""
	Local cGroupBy      := ""
	Local cWhereId      := ""
	Local cIniDate      := ""
	Local cEndDate      := ""
	Local cSearchKey    := ""
	Local cRetBy        := ""
	Local nOrderType    := ""
	Local lDtFilter     := .F.
	Local lFindFilter   := .F.
	Local lAlcSolCtb    := .F.
	Local nTamCN9IC     := 0
	Local nTamPlanIC    := 0
	Local nPosPlan      := 0

	Default lId         := .F.

	cIniDate    := oSelf:initDate
	cEndDate    := oSelf:endDate
	cSearchKey  := oSelf:searchKey
	nOrderType  := oSelf:orderBy

	cRetBy      := RetBy( nOrderType )

	lDtFilter   := !Empty( cIniDate ) .And. !Empty( cEndDate )
	lFindFilter := !Empty( cSearchKey )
	lAlcSolCtb 	:= SuperGetMv("MV_APRSCEC",.F.,.F.)

	cFields:= "CR_FILIAL, CR_NUM, CR_TOTAL, (CR_TOTAL * CR_TXMOEDA) AS TOTCONVERT, CR_TIPO, CR_GRUPO, CR_ITGRP, CR_STATUS, CR_MOEDA, CR_TXMOEDA, CR_EMISSAO, SCR.R_E_C_N_O_ AS REGSCR,"

	If lId
		cWhereId := " AND  SCR.R_E_C_N_O_ =  ? "
	EndIf

	If lDtFilter
		cWhere +=   " AND CR_EMISSAO BETWEEN '" + AllTrim( cIniDate ) + "' AND  '" + AllTrim( cEndDate ) + "' "
	EndIf

	Do Case

	Case cDocType == "All" .Or. Empty( cDocType )
		If cDocType == "All"
			cDocType := ""
		EndIf
		cOrderBy    := "CR_NUM" + cRetBy

		cFields := Subs( cFields, 1, len( cFields ) - 1 )

		If lFindFilter
			cWhere += " AND CR_NUM LIKE '%" + cSearchKey + "%' "
		EndIf

	Case cDocType $ "PC|AE"
		cOrderBy    := "C7_NUM" + cRetBy

		cFields += "A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, C7_FILIAL, C7_EMISSAO"

		cJoin += " INNER JOIN " + RetSqlName( "SC7" ) + " SC7 ON " + FWJoinFilial( "SC7", "SCR" ) + " AND CR_NUM = C7_NUM AND SC7.D_E_L_E_T_ = ' '"
		cJoin += " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON " + FWJoinFilial( "SA2", "SC7" ) + " AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
		cJoin += " INNER JOIN " + RetSqlName( "SE4" ) + " SE4 ON " + FWJoinFilial( "SE4", "SC7" ) + " AND E4_CODIGO = C7_COND AND SE4.D_E_L_E_T_ = ' ' "
		cJoin += " LEFT JOIN "  + RetSqlName( "SY1" ) + " SY1 ON " + FWJoinFilial( "SY1", "SC7" ) + " AND C7_USER = Y1_USER AND SY1.D_E_L_E_T_ = ' ' "

		If lFindFilter
			cWhere +=   " AND (A2_NOME LIKE '%" + cSearchKey + "%' OR A2_NREDUZ LIKE '%" + cSearchKey + "%' OR A2_COD LIKE '%" + cSearchKey + "%' OR C7_NUM LIKE '%" + cSearchKey + "%' ) "
		EndIf

		cGroupBy:= " GROUP BY A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, C7_FILIAL, C7_EMISSAO, CR_ITGRP, CR_GRUPO, CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_ "

	Case cDocType == "IP"
		cOrderBy    := "C7_NUM" + cRetBy

		cFields += "A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, C7_FILIAL, C7_EMISSAO, CTT_DESC01 "

		cJoin += " INNER JOIN " + RetSqlName( "SC7" ) + " SC7 ON " + FWJoinFilial( "SC7", "SCR" ) + " AND CR_NUM = C7_NUM AND SC7.D_E_L_E_T_ = ' '"
		cJoin += " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON " + FWJoinFilial( "SA2", "SC7" ) + " AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
		cJoin += " INNER JOIN " + RetSqlName( "SE4" ) + " SE4 ON " + FWJoinFilial( "SE4", "SC7" ) + " AND E4_CODIGO = C7_COND AND SE4.D_E_L_E_T_ = ' ' "
		cJoin += " LEFT JOIN "  + RetSqlName( "CTT" ) + " CTT ON " + FWJoinFilial( "CTT", "SC7" ) + " AND C7_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "
		cJoin += " LEFT JOIN "  + RetSqlName( "SY1" ) + " SY1 ON " + FWJoinFilial( "SY1", "SC7" ) + " AND C7_USER = Y1_USER AND SY1.D_E_L_E_T_ = ' ' "
		cJoin += " LEFT JOIN " + RetSqlName( "DBM" ) + " DBM ON " + FWJoinFilial( "DBM", "SCR" ) + " AND DBM_NUM = CR_NUM  AND DBM_GRUPO = CR_GRUPO AND DBM_ITGRP = CR_ITGRP AND DBM.D_E_L_E_T_ = ' ' "

		If lFindFilter
			cWhere +=   " AND (A2_NOME LIKE '%" + cSearchKey + "%' OR A2_NREDUZ LIKE '%" + cSearchKey + "%' OR A2_COD LIKE '%" + cSearchKey + "%' OR C7_NUM LIKE '%" + cSearchKey + "%' ) "
		EndIf

		cWhere += "AND CASE WHEN CR_TIPO = 'IP' AND DBM_ITEM = C7_ITEM THEN 1 "
		cWhere += "WHEN CR_TIPO <> 'IP' AND DBM_ITEM IS NULL THEN 1 "
		cWhere += "ELSE 0 "
		cWhere += "END = 1"

		cGroupBy:= " GROUP BY A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, C7_FILIAL, C7_EMISSAO, CR_ITGRP, CR_GRUPO, CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_STATUS, CR_MOEDA, CR_EMISSAO, CTT_DESC01, SCR.R_E_C_N_O_ "

	Case cDocType == "SC"
		cOrderBy  := "C1_NUM" + cRetBy

		cFields   += " C1_SOLICIT, C1_EMISSAO, C1_FILIAL, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, "

		If lAlcSolCtb
			cFields   += " (CASE C1_CC WHEN ' ' THEN CX_CC ELSE C1_CC END) AS C1_CC, "
		Else
			cFields   += " C1_CC,"
		EndIf

		cFields   += " C1_TOTAL, CTT_DESC01 "
		cJoin     += " INNER JOIN " + RetSqlName( "SC1" ) + " SC1 ON " + FWJoinFilial( "SC1", "SCR" ) + " AND C1_NUM = CR_NUM AND SC1.D_E_L_E_T_ = ' ' "
		cJoin     += " INNER JOIN " + RetSqlName( "DBM" ) + " DBM ON " + FWJoinFilial( "DBM", "SCR" ) + " AND DBM_NUM = CR_NUM  AND DBM_ITEM = C1_ITEM AND DBM_GRUPO = CR_GRUPO AND DBM_ITGRP = CR_ITGRP AND DBM.D_E_L_E_T_ = ' ' "

		If lAlcSolCtb
			cJoin += " LEFT JOIN " + RetSqlName( "SCX" ) + " SCX ON " + FWJoinFilial( "SCX", "DBM" ) + " AND SCX.CX_SOLICIT = DBM.DBM_NUM AND SCX.CX_ITEMSOL = DBM.DBM_ITEM  AND SCX.CX_ITEM = DBM.DBM_ITEMRA AND SCX.D_E_L_E_T_ = ' ' "
			cJoin += " LEFT JOIN " + RetSqlName( "CTT" ) + " CTT ON " + FWJoinFilial( "CTT", "SC1" ) + " AND CTT_CUSTO = (CASE C1_CC WHEN ' ' THEN CX_CC ELSE C1_CC END)  AND CTT.D_E_L_E_T_ = ' ' "
		Else
			cJoin += " LEFT JOIN " + RetSqlName( "CTT" ) + " CTT ON " + FWJoinFilial( "CTT", "SC1" ) + " AND CTT_CUSTO = C1_CC  AND CTT.D_E_L_E_T_ = ' ' "
		EndIf

		If  lFindFilter
			cJoin += " AND (C1_SOLICIT LIKE '%" + cSearchKey + "%' OR C1_NUM LIKE '%" + cSearchKey + "%' ) "
		EndIf

		cGroupBy:= "GROUP BY CR_ITGRP, CR_GRUPO, CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_, C1_SOLICIT, C1_CC, C1_TOTAL, C1_FILIAL, C1_NUM, C1_EMISSAO, CTT_DESC01"

		If lAlcSolCtb
			cGroupBy += ", CX_CC"
		EndIf

	Case cDocType $ "MD|IM"
		cOrderBy    := "CND_CONTRA" + cRetBy

		cFields  += "CND_CONTRA, CND_COMPET, CND.R_E_C_N_O_ AS REGGEN"
		nNumLen  := GetSx3Cache("CND_NUMMED","X3_TAMANHO")

		cJoin +=  " INNER JOIN " + RetSqlName( "CND" ) + " CND ON " + FWJoinFilial( "CND", "SCR" ) + " "
		cJoin +=  " AND CND_NUMMED = SUBSTRING(CR_NUM, 1,"+Alltrim( STR( nNumLen ))+")"

		If lFindFilter
			cJoin +=   " AND ( CND.CND_NUMMED LIKE '%" + cSearchKey + "%' OR "
			cJoin +=   "CND.CND_CONTRA LIKE '%" + cSearchKey + "%' ) "
		EndIf

		cJoin +=  " AND CND.D_E_L_E_T_ = ' ' "

		cJoin +=  " INNER JOIN " + RetSqlName( "CNA" ) + " CNA ON " + FWJoinFilial( "CNA", "CND" ) + " "
		cJoin +=  " AND CNA.CNA_CONTRA = CND.CND_CONTRA "
		cJoin +=  " AND CNA.D_E_L_E_T_ = ' ' "

		cGroupBy := " GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_GRUPO, CR_ITGRP, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_, CND_CONTRA, CND_COMPET, CND.R_E_C_N_O_ "

	Case cDocType == "CT"
		cOrderBy    := "CNA_CONTRA" + cRetBy

		cFields  += "CNA_CONTRA, CNA_NUMERO AS PLANIL, CNA_REVISA AS REV, CNA_DTINI, CNA_DTFIM, CNA.R_E_C_N_O_ AS REGGEN"

		cJoin +=  " INNER JOIN ( "
		cJoin +=  "   SELECT CNA_FILIAL, CNA_CONTRA, MIN(CNA_NUMERO) AS CNA_NUMERO, "
		cJoin +=  "          CNA_REVISA, CNA_DTINI, CNA_DTFIM, MIN(R_E_C_N_O_) AS R_E_C_N_O_ "
		cJoin +=  "   FROM " + RetSqlName( "CNA" ) + " "
		cJoin +=  "   WHERE D_E_L_E_T_ = ' ' "

		If lFindFilter
			cJoin +=   " AND CNA_CONTRA LIKE '%" + AllTrim(cSearchKey) + "%' "
		EndIf

		cJoin +=  "   GROUP BY CNA_FILIAL, CNA_CONTRA, CNA_REVISA, CNA_DTINI, CNA_DTFIM "
		cJoin +=  " ) CNA ON " + FWJoinFilial( "CNA", "SCR" ) + " "
		cJoin +=  " AND CNA_CONTRA = CR_NUM "

	Case cDocType == "IC"
		cOrderBy   := "CNA_CONTRA" + cRetBy
		nTamCN9IC  := TamSX3("CN9_NUMERO")[1]
		nTamPlanIC := TamSX3("CNA_NUMERO")[1]
		nPosPlan   := nTamCN9IC + TamSX3("CN9_REVISA")[1] + 1

		cFields += " CNA_CONTRA, CNA_NUMERO AS PLANIL, CNA_REVISA AS REV, CNA_DTINI, CNA_DTFIM, CNA.R_E_C_N_O_ AS REGGEN "

		cJoin += " INNER JOIN " + RetSqlName( "CN9" ) + " CN9 "
		cJoin += " ON CN9.CN9_FILIAL = SCR.CR_FILIAL "
		cJoin += " AND CN9.CN9_NUMERO = RTRIM(LEFT(SCR.CR_NUM, " + AllTrim(Str(nTamCN9IC)) + ")) "
		cJoin += " AND CN9.D_E_L_E_T_ = ' ' "
		cJoin += " INNER JOIN " + RetSqlName( "CNA" ) + " CNA "
		cJoin += " ON " + FWJoinFilial( "CNA", "SCR" ) + " "
		cJoin += " AND CNA.CNA_CONTRA = CN9.CN9_NUMERO "
		cJoin += " AND CNA.CNA_REVISA = CN9.CN9_REVISA "
		cJoin += " AND CNA.CNA_NUMERO = SUBSTRING(SCR.CR_NUM, " + AllTrim(Str(nPosPlan)) + ", " + AllTrim(Str(nTamPlanIC)) + ") "
		cJoin += " AND CNA.D_E_L_E_T_ = ' ' "

		If lFindFilter
			cWhere += " AND CN9.CN9_NUMERO LIKE '%" + AllTrim(cSearchKey) + "%' "
		EndIf

		cGroupBy := " GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_GRUPO, CR_ITGRP, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_, CNA_CONTRA, CNA_NUMERO, CNA_REVISA, CNA_DTINI, CNA_DTFIM, CNA.R_E_C_N_O_ "

	Case cDocType == "SA"
		cOrderBy  := "CP_NUM" + cRetBy

		cFields += "CP_SOLICIT, CP_EMISSAO, CP_FILIAL, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, CP_CC, CTT_DESC01"
		cJoin     += " INNER JOIN " + RetSqlName( "SCP" ) + " SCP ON " + FWJoinFilial( "SCP", "SCR" ) + "  AND CP_NUM = CR_NUM AND SCP.D_E_L_E_T_ = ' ' "
		cJoin     += " LEFT JOIN "  + RetSqlName( "CTT" ) + " CTT ON " + FWJoinFilial( "CTT", "SCP" ) + "  AND CTT_CUSTO = CP_CC  AND CTT.D_E_L_E_T_ = ' ' "
		cJoin     += " INNER JOIN " + RetSqlName( "DBM" ) + " DBM ON " + FWJoinFilial( "DBM", "SCR" ) + "  AND DBM_NUM = CR_NUM  AND DBM_ITEM = CP_ITEM AND DBM_GRUPO = CR_GRUPO AND DBM_ITGRP = CR_ITGRP AND DBM.D_E_L_E_T_ = ' ' "

		If  lFindFilter
			cJoin += " AND (CP_SOLICIT LIKE '%" + cSearchKey + "%' OR CP_NUM LIKE '%" + cSearchKey + "%' ) "
		EndIf

		cGroupBy:= "Group By CR_ITGRP, CR_GRUPO, CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_, CP_SOLICIT, CP_CC, CP_FILIAL, CP_NUM, CP_EMISSAO, CTT_DESC01"

	Case cDocType == "PV"
		cOrderBy := "C5_NUM" + cRetBy

		cFields += " A1_NREDUZ, C5_NUM, E4_DESCRI, A3_NOME, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, C5_FILIAL, C5_EMISSAO "

		cJoin += " INNER JOIN " + RetSqlName( "SC5" ) + " SC5 ON " + FWJoinFilial( "SC5", "SCR" ) + " AND C5_NUM = CR_NUM AND SC5.D_E_L_E_T_ = ' ' "
		cJoin += " INNER JOIN " + RetSqlName( "SA1" ) + " SA1 ON " + FWJoinFilial( "SA1", "SC5" ) + " AND C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cJoin += " LEFT JOIN "  + RetSqlName( "SE4" ) + " SE4 ON " + FWJoinFilial( "SE4", "SC5" ) + " AND E4_CODIGO = C5_CONDPAG AND SE4.D_E_L_E_T_ = ' ' "
		cJoin += " LEFT JOIN "  + RetSqlName( "SA3" ) + " SA3 ON " + FWJoinFilial( "SA3", "SC5" ) + " AND A3_COD = C5_VEND1 AND SA3.D_E_L_E_T_ = ' ' "

		If lFindFilter
			cWhere += " AND (A1_NOME LIKE '%" + cSearchKey + "%' OR A1_NREDUZ LIKE '%" + cSearchKey + "%' OR A1_COD LIKE '%" + cSearchKey + "%' OR C5_NUM LIKE '%" + cSearchKey + "%') "
		EndIf

		cGroupBy := " GROUP BY A1_NREDUZ, C5_NUM, E4_DESCRI, A3_NOME, C5_FILIAL, C5_EMISSAO, CR_ITGRP, CR_GRUPO, CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_ "

	Case cDocType == "DV"
		cOrderBy := "C5_NUM" + cRetBy

		cFields += " A1_NREDUZ, C5_NUM, E4_DESCRI, A3_NOME, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, C5_FILIAL, C5_EMISSAO "

		cJoin += " INNER JOIN " + RetSqlName( "SC5" ) + " SC5 ON " + FWJoinFilial( "SC5", "SCR" ) + " AND C5_NUM = CR_NUM AND SC5.D_E_L_E_T_ = ' ' "
		cJoin += " INNER JOIN " + RetSqlName( "SA1" ) + " SA1 ON " + FWJoinFilial( "SA1", "SC5" ) + " AND C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
		cJoin += " LEFT JOIN "  + RetSqlName( "SE4" ) + " SE4 ON " + FWJoinFilial( "SE4", "SC5" ) + " AND E4_CODIGO = C5_CONDPAG AND SE4.D_E_L_E_T_ = ' ' "
		cJoin += " LEFT JOIN "  + RetSqlName( "SA3" ) + " SA3 ON " + FWJoinFilial( "SA3", "SC5" ) + " AND A3_COD = C5_VEND1 AND SA3.D_E_L_E_T_ = ' ' "

		If lFindFilter
			cWhere += " AND (A1_NOME LIKE '%" + cSearchKey + "%' OR A1_NREDUZ LIKE '%" + cSearchKey + "%' OR A1_COD LIKE '%" + cSearchKey + "%' OR C5_NUM LIKE '%" + cSearchKey + "%') "
		EndIf

		cGroupBy := " GROUP BY A1_NREDUZ, C5_NUM, E4_DESCRI, A3_NOME, C5_FILIAL, C5_EMISSAO, CR_ITGRP, CR_GRUPO, CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_ "

	EndCase

	cQuery := " SELECT <<PAGE_CONTROL>>, " + AllTrim(cFields) + " " + ;
		" FROM " + RetSqlName( "SCR" ) + " SCR " + ;
		cJoin + ;
		" WHERE CR_FILIAL IN (?) " + ;
		" AND CR_TIPO IN (?) " + ;
		" AND CR_STATUS IN (?) " + ;
		" AND CR_USER = ? " + ;
		cWhere + ;
		cWhereId + ;
		" AND SCR.D_E_L_E_T_ = ' ' "  + cGroupBy

	If !Empty( cQuery )
		cQuery := QueryPageControl( cQuery, cOrderBy, cDocType, lId )
	EndIf
Return cQuery

//----------------------------------------------------------------------------------
/*/{Protheus.doc} QueryPageControl
Função responsável por atribuir o tratamento de paginação, caso a tag PAGE_CONTROL
seja utilizada na query.

@param cQuery, caracter, Query original para tratamento
@param cOrderBy, caracter, instrução de ordenação por operação
@param cDocType, tipo de alçada do documento
@param lId, lógico, se possui um número de identificação do registro

@return caracter, query com o tratamento para paginação
@author Jose Renato
@since 27/07/2023
/*/
//----------------------------------------------------------------------------------
Static Function QueryPageControl( cQuery, cOrderBy, cDocType, lId )
	Local nPosStart    := 0
	Local nPosEnd      := 0
	Local nPosFrom     := 0
	Local cAuxQuery    := ""
	Local cFields      := ""
	Local cPageControl := ""
	Local cTag         := "<<PAGE_CONTROL>>"

	Default cQuery   := ""
	Default lId      := .F.

	If !lId

		IF At( cTag, cQuery ) > 0
			nPosStart  := At( cTag, cQuery )
			cAuxQuery  := SubStr( cQuery, nPosStart )

			nPosEnd := Len( cTag )
			nPosFrom := At( " FROM ", cAuxQuery )
			cFields := Alltrim( Subs( cAuxQuery, nPosEnd + 2, nPosFrom - nPosEnd - 2 ) )
			cFields := AdjustFields( cFields )

			cPageControl := cFields + " FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY " + cOrderBy + " ) AS LINE "
			cQuery := StrTran( cQuery, cTag, cPageControl )
			cQuery += ' ) TABLE_AUX '

			cQuery  +=  "WHERE LINE BETWEEN ? AND ?  "
		EndIf
	Else
		cQuery := StrTran( cQuery, cTag +  ",", "")
	EndIf
Return cQuery

//----------------------------------------------------------------------------------
/*/{Protheus.doc} SetQueryValues
Função responsável por atribuir os valores na query de acordo com a operação

@param @oQuery, object, objeto que armazena as informações da query
@param cDocType, caracter, identifica qual a query será montada no tipo de alçada do documento
@param oSelf, object, objeto principal do WS
@param nId, número de identificação do registro(Recno)
@Return Nil

@author Jose Renato
@since 27/07/2023
/*/
//----------------------------------------------------------------------------------
Static Function SetQueryValues( oQuery, cDocType, oSelf, nId )
	Local nRecStart     := 0
	Local nRecFinish    := 0
	Local aBranches     := {}
	Local aBranSCR      := {}
	Local nX            := 0
	Local cBranches     := ""
	Default nId         := 0

	nRecStart  := ( ( oSelf:page - 1 ) * oSelf:pageSize ) + 1
	nRecFinish := ( nRecStart + oSelf:pageSize ) - 1

	cBranches := RetApprovalBranch( oSelf )
	aBranches := StrTokArr( cBranches, "," )

	Do Case

	Case Empty( cDocType ) .Or. cDocType == "All"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { "SC", "MD", "IM", "PC", "IP", "AE", "CT", "IC", "SA", "PV", "DV" } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		oQuery:SetNumeric( 5, nRecStart )
		oQuery:SetNumeric( 6, nRecFinish )

	Case cDocType $ "PC|IP|AE"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { cDocType } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )

		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType == "SC"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { "SC" } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType $ "MD|IM"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { cDocType } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType == "CT"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { "CT" } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType == "IC"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { "IC" } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType == "SA"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { "SA" } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType == "PV"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { "PV" } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType == "DV"

		For nX := 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ) )
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:SetIn( 2, { "DV" } )
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	EndCase
Return

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RetBy
Função responsável por retornar qual OrderBy deverá ser utilizado na ordenação 

@param nOrderType, numérico,  tipo de ordenação a ser utilizada 1 = Decrescente, 2 = Crescente

@return cOrderBy, caracter com tipo de ordenação a ser utilizado
@author Jose Renato
@since 07/08/2023
/*/
//----------------------------------------------------------------------------------
Static Function RetBy( nOrderType )
	Local cOrderBy     := ""
	Default nOrderType := 1

	Do Case
	Case nOrderType == 1
		cOrderBy := " DESC"
	Case nOrderType == 2
		cOrderBy := " ASC"
	End Case

Return cOrderBy

//----------------------------------------------------------------------------------
/*/{Protheus.doc} AdjustFields
Função responsável por ajustar os campos na query de paginação quando utilizado 
alguma função de agregação ou renomear o nome do campo.
Esta função só é acionada quando o controle de paginação está sendo usado.

@param cFields, caracter, Campos da query

@return caracter, Campos tratados da query
@author Jose Renato
@since 01/08/2023
/*/
//----------------------------------------------------------------------------------
Static Function AdjustFields( cFields )
	Local aFields := {}
	Local nItem := 0
	Local nPosAs := 0
	Local cAdjustFields := ''
	Local cField := ''

	If At( ' AS ', cFields ) > 0
		aFields := StrToArray( cFields, ',' )
		For nItem := 1 to len( aFields )
			If nItem > 1
				cAdjustFields += ', '
			EndIf

			cField := aFields[ nItem ]
			If ' AS ' $ Upper( cField )
				nPosAs := At( " AS ", Upper( cField ) )

				cAdjustFields += SubStr( cField, nPosAs + 4 )
			Else
				cAdjustFields += cField
			EndIf
		Next
	EndIf
Return cAdjustFields

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetJson
Função que prepara as informações necessárias para serem utilizadas no retorno do Get

@param cTmp, caracter, alias que esta sendo verificado
@param oSelf, objeto, objeto principal do WS

@return aData, array, componente com as propriedades no formato JSON para envio à plataforma.
@author  Jose Renato
@since   02/08/2023
/*/
//-------------------------------------------------------------------------------------
Static Function SetJson( cTmp, oSelf )
	Local aData		:= {}
	Local aMakeDoc	:= {}

	Default cTmp := "SCR"

	( cTmp )->( DbGoTop() )

	While ( cTmp )->( !EOF() )

		aMakeDoc := MakeDocuments( cTmp, oSelf )

		aAdd( aData, aMakeDoc )
		( cTmp )->( dBSkip() )
	EndDo
Return aData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeDocuments
Função que prepara as informações necessárias para a montagem dos dados do documento com alçada.

@param cTmp, caracter, alias que esta sendo verificado
@param oSelf, object, objeto principal do WS

@return jData, json com os dados do documento
@author  Jose Renato
@since   02/08/2023
/*/
//-------------------------------------------------------------------------------------
Static Function MakeDocuments( cTmp, oSelf )

	Local jData := NIL
	Local cDoc  := ""

	Default cTmp := "SCR"

	cDoc := ReturnDocType(( cTmp )->CR_TIPO )

	jData := JsonObject():New()

	jData[ "documentBranch" ]       := ( cTmp )->CR_FILIAL
	jData[ "documentNumber" ]       := EncodeUTF8( Alltrim(( cTmp )->CR_NUM ))
	jData[ "documentTotal" ]        := ( cTmp )->CR_TOTAL
	jData[ "documentExchangeValue"] := ( cTmp )->TOTCONVERT
	jData[ "documentType" ]         := EncodeUTF8( Alltrim(( cTmp )->CR_TIPO ))
	jData[ "documentUserName" ]     := EncodeUTF8( Alltrim(UsrRetName(__cUserId )))
	jData[ "documentGroupAprov" ]   := EncodeUTF8( Alltrim(( cTmp )->CR_GRUPO ))
	jData[ "documentItemGroup" ]    := EncodeUTF8( Alltrim(( cTmp )->CR_ITGRP ))
	jData[ "documentStatus" ]       := EncodeUTF8( Alltrim(( cTmp )->CR_STATUS ))
	jData[ "documentCurrency" ]     := ( cTmp )->CR_MOEDA
	jData[ "documentExchangeRate" ] := ( cTmp )->CR_TXMOEDA
	jData[ "documentSymbol"	]		:= Alltrim(GetSymbol(( cTmp )->CR_MOEDA))
	jData[ "documentStrongSymbol"]  := Alltrim(GetSymbol(1))
	jData[ "documentCreated" ]      := ( cTmp )->CR_EMISSAO
	jData[ "scrId" ]                := ( cTmp )->REGSCR

	jData[ cDoc ] := MakeJsonDocInfo( cTmp, cDoc, oSelf )

Return jData

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReturnDocType
Função que retorna o tipo de documento a ser utilizado para preenchimento do json

@param cDoc, caracter, tipo de documento em alçada a ser verificado.

@return cDocRet, caracter, tipo de documento retornado
@author  Jose Renato
@since   02/08/2023
/*/
//-------------------------------------------------------------------------------------
Static Function ReturnDocType( cDoc )
	Local cDocRet := ""

	Do Case
	Case cDoc == "SC"
		cDocRet := "purchaseRequest"
	Case cDoc $ "PC|IP|AE"
		cDocRet := "purchaseOrder"
	Case cDoc $ "MD|IM"
		cDocRet := "measurements"
	Case cDoc == "CT"
		cDocRet := "contracts"
	Case cDoc == "IC"
		cDocRet := "contractItem"
	Case cDoc == "SA"
		cDocRet := "warehouseRequest"
	Case cDoc == "PV"
		cDocRet := "salesOrder"
	Case cDoc == "DV"
		cDocRet := "salesDiscount"
	EndCase

Return cDocRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} MakeJsonDocInfo
Função que prepara as informações necessárias para a montagem dos dados do json.

@param cTmp, caracter, alias que esta sendo verificado
@param cType, caracter, tipo de alçada que passara por preenchimento dos dados
@param oSelf, object, Objeto principal do WS

@return array, vetor com os dados do tipo de alçada
@author  Jose Renato
@since   02/08/2023
/*/
//-------------------------------------------------------------------------------------
Static Function MakeJsonDocInfo( cTmp, cType, oSelf )
	Local aDoc       := {}
	Local aParties   := {}
	Local aFilBranch := {}
	Local jDoc
	Local cAlias     := ""
	Local cTable     := ""
	Local cDocType   := ""
	Local nRegGen    := 0
	Local cCodCTT    := ""
	Local cDescCTT   := ""
	Local cCRNum     := ""
	Local oQuery
	Local nI         := 0
	Local cBranches  := ""

	cDocType := oSelf:documentType
	cBranches := RetApprovalBranch( oSelf )
	aFilBranch := StrTokArr( cBranches, "," )

	If Empty( cDocType )
		cAlias  := GetNextAlias()
		nRegGen := IIF( cDocType $ "MD|IM", ( cTmp )->REGGEN, ( cTmp )->REGSCR )
		oQuery  := GetQueryApprovals( ( cTmp )->CR_TIPO, oSelf, nRegGen > 0 )
		SetQueryValues( @oQuery, ( cTmp )->CR_TIPO, oSelf, nRegGen )
		MPSysOpenQuery( ChangeQuery(oQuery:getFixQuery()) , cAlias )
	EndIf

	cTable := IIF( Empty( cDocType ), cAlias, cTmp )

	Do Case
	Case cType == "contracts"
		jDoc := JsonObject():New()
		jDoc["contractNumber"] := EncodeUTF8( AllTrim( ( cTable )->CNA_CONTRA ) )
		jDoc["date"]           := EncodeUTF8( AllTrim( ( cTable )->CNA_DTINI ) )
		jDoc["initialTerm"]    := EncodeUTF8( AllTrim( ( cTable )->CNA_DTINI ) )
		jDoc["finalTerm"]      := EncodeUTF8( AllTrim( ( cTable )->CNA_DTFIM ) )
		jDoc["recno"]          := ( cTable )->REGGEN
		aAdd( aDoc, jDoc )
		FreeObj( jDoc )

	Case cType == "contractItem"
		jDoc := JsonObject():New()
		jDoc["contractNumber"] := EncodeUTF8( AllTrim( ( cTable )->CNA_CONTRA ) )
		jDoc["sheetNumber"]    := EncodeUTF8( AllTrim( ( cTable )->PLANIL ) )
		jDoc["revision"]       := EncodeUTF8( AllTrim( ( cTable )->REV ) )
		jDoc["initialTerm"]    := EncodeUTF8( AllTrim( ( cTable )->CNA_DTINI ) )
		jDoc["finalTerm"]      := EncodeUTF8( AllTrim( ( cTable )->CNA_DTFIM ) )
		jDoc["recno"]          := ( cTable )->REGGEN
		aAdd( aDoc, jDoc )
		FreeObj( jDoc )

	Case cType == "measurements"
		jDoc := JsonObject():New()

		If ( cTable )->( FieldPos( "CR_NUM" ) ) > 0
			cCRNum := AllTrim( ( cTable )->CR_NUM )
			DbSelectArea( "CND" )
			CND->( DbSetOrder(4) )

			If CND->( DbSeek( xFilial("CND", ( cTable )->CR_FILIAL ) + PadR( cCRNum, 6 ) ) )
				aParties := GetCtrtPrt( CND->CND_CONTRA, cCRNum, aFilBranch )
				jDoc["contractNumber"] := EncodeUTF8( AllTrim( CND->CND_CONTRA ) )
				jDoc["competence"]     := EncodeUTF8( AllTrim( CND->CND_COMPET ) )
				jDoc["recno"]          := ( cTable )->REGGEN

				For nI := 1 To Len( aParties )
					If aParties[nI]["type"] == "F" .And. !jDoc:HasProperty("supplyerName")
						jDoc["supplyerName"] := EncodeUTF8( aParties[nI]["name"] )
					ElseIf aParties[nI]["type"] == "C" .And. !jDoc:HasProperty("customerName")
						jDoc["customerName"] := EncodeUTF8( aParties[nI]["name"] )
					EndIf
				Next
			EndIf
		EndIf

		aAdd( aDoc, jDoc )
		FreeObj( jDoc )

	Case cType == "purchaseRequest"
		jDoc := JsonObject():New()
		jDoc["requesterName"] := EncodeUTF8( AllTrim( ( cTable )->C1_SOLICIT ) )
		jDoc["date"]          := ( cTable )->C1_EMISSAO
		jDoc["CostCenter"]    := EncodeUTF8( AllTrim( ( cTable )->CTT_DESC01 ) )
		aAdd( aDoc, jDoc )
		FreeObj( jDoc )

	Case cType == "purchaseOrder"
		jDoc := JsonObject():New()
		jDoc["supplyerName"]           := EncodeUTF8( AllTrim( ( cTable )->A2_NREDUZ ) )
		jDoc["paymentTermDescription"] := EncodeUTF8( AllTrim( ( cTable )->E4_DESCRI ) )
		jDoc["purchaserName"]          := EncodeUTF8( AllTrim( ( cTable )->Y1_NOME ) )
		jDoc["date"]                   := ( cTable )->C7_EMISSAO

		If ( cTmp )->CR_TIPO == "IP"
			If jDoc["itemDescriptionCostCenter"] == NIL .Or. Empty( jDoc["itemDescriptionCostCenter"] )
				cCodCTT  := GetAdvFVal( "DBL", "DBL_CC", fwxFilial("DBL") + AllTrim( ( cTmp )->CR_GRUPO + ( cTmp )->CR_ITGRP ), 1 )
				cDescCTT := GetAdvFVal( "CTT", "CTT_DESC01", fwxFilial("CTT") + cCodCTT, 1 )
				jDoc["itemDescriptionCostCenter"] := EncodeUTF8( AllTrim( cDescCTT ) )
			EndIf
		EndIf
		aAdd( aDoc, jDoc )
		FreeObj( jDoc )

	Case cType == "warehouseRequest"
		jDoc := JsonObject():New()
		jDoc["requesterName"] := EncodeUTF8( AllTrim( ( cTable )->CP_SOLICIT ) )
		jDoc["date"]          := ( cTable )->CP_EMISSAO
		jDoc["CostCenter"]    := EncodeUTF8( AllTrim( ( cTable )->CTT_DESC01 ) )
		aAdd( aDoc, jDoc )
		FreeObj( jDoc )

	Case cType == "salesOrder"
		jDoc := JsonObject():New()
		jDoc["customerName"]           := EncodeUTF8( AllTrim( ( cTable )->A1_NREDUZ ) )
		jDoc["paymentTermDescription"] := EncodeUTF8( AllTrim( ( cTable )->E4_DESCRI ) )
		jDoc["salesRepresentative"]    := EncodeUTF8( AllTrim( ( cTable )->A3_NOME ) )
		jDoc["date"]                   := ( cTable )->C5_EMISSAO
		jDoc["branch"]                 := EncodeUTF8( AllTrim( ( cTable )->C5_FILIAL ) )
		aAdd( aDoc, jDoc )
		FreeObj( jDoc )

	Case cType == "salesDiscount"
		jDoc := JsonObject():New()
		jDoc["customerName"]           := EncodeUTF8( AllTrim( ( cTable )->A1_NREDUZ ) )
		jDoc["paymentTermDescription"] := EncodeUTF8( AllTrim( ( cTable )->E4_DESCRI ) )
		jDoc["salesRepresentative"]    := EncodeUTF8( AllTrim( ( cTable )->A3_NOME ) )
		jDoc["date"]                   := ( cTable )->C5_EMISSAO
		jDoc["branch"]                 := EncodeUTF8( AllTrim( ( cTable )->C5_FILIAL ) )
		aAdd( aDoc, jDoc )
		FreeObj( jDoc )

	EndCase

	FWFreeArray( aFilBranch )
Return aDoc

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCtrtPrt
Busca dados de Cliente e Fornecedor do contrato vinculado à medição

@type Static Function
@param cContract, character, Código do contrato
@param cMedicao, character, Número da medição
@param aFiliais, array, Array com as filiais a serem consideradas na busca (Default: {cFilAnt})
@return aResult, array, Array de objetos JSON com fornecedores e clientes encontrados.
Cada objeto contém: type (F=Fornecedor/C=Cliente), code, store, name
@author Deijaí Miranda Almeida
@since 23/11/2025
/*/
//-------------------------------------------------------------------
Static Function GetCtrtPrt(cContract, cMedicao, aFiliais)
	Local oQuery     As Object
	Local cQuery     As Character
	Local cAlias     As Character
	Local cKey       As Character
	Local aResult    As Array
	Local aKeys      As Array
	Local oParty     As Object
	Local nParam     As Numeric
	Local cFilSA1    As Character
	Local cFilSA2    As Character

	oQuery   := Nil
	cQuery   := ""
	cAlias   := ""
	cKey     := ""
	aResult  := {}
	aKeys    := {}
	oParty   := Nil
	nParam   := 1
	cFilSA1  := ""
	cFilSA2  := ""

	Default aFiliais := {cFilAnt}

	cFilSA1 := FWxFilial('SA1')
	cFilSA2 := FWxFilial('SA2')

	cQuery := " SELECT DISTINCT "
	cQuery += "     CNA.CNA_FORNEC, "
	cQuery += "     CNA.CNA_LJFORN, "
	cQuery += "     SA2.A2_NREDUZ AS NOME_FORNECEDOR, "
	cQuery += "     CNA.CNA_CLIENT, "
	cQuery += "     CNA.CNA_LOJACL, "
	cQuery += "     SA1.A1_NREDUZ AS NOME_CLIENTE "
	cQuery += " FROM " + RetSqlName("CNE") + " CNE "
	cQuery += " INNER JOIN " + RetSqlName("CNA") + " CNA "
	cQuery += "     ON CNA.CNA_FILIAL = CNE.CNE_FILIAL "
	cQuery += "     AND CNA.CNA_CONTRA = CNE.CNE_CONTRA "
	cQuery += "     AND CNA.CNA_NUMERO = CNE.CNE_NUMERO "
	cQuery += "     AND CNA.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery += "     ON SA2.A2_FILIAL = ? "
	cQuery += "     AND SA2.A2_COD = CNA.CNA_FORNEC "
	cQuery += "     AND SA2.A2_LOJA = CNA.CNA_LJFORN "
	cQuery += "     AND SA2.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "     ON SA1.A1_FILIAL = ? "
	cQuery += "     AND SA1.A1_COD = CNA.CNA_CLIENT "
	cQuery += "     AND SA1.A1_LOJA = CNA.CNA_LOJACL "
	cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CNE.CNE_FILIAL IN (?) "
	cQuery += "     AND CNE.CNE_NUMMED = ? "
	cQuery += "     AND CNE.D_E_L_E_T_ = ' ' "

	oQuery := FwExecStatement():New(cQuery)

	oQuery:SetString(nParam++, cFilSA2)
	oQuery:SetString(nParam++, cFilSA1)
	oQuery:SetIn(nParam++, aFiliais)
	oQuery:SetString(nParam++, PadR(AllTrim(cMedicao), TamSX3("CNE_NUMMED")[1]))

	cAlias := oQuery:OpenAlias()

	If Select(cAlias) > 0
		DbSelectArea(cAlias)
		(cAlias)->(DbGoTop())

		While !(cAlias)->(EoF())
			If !Empty((cAlias)->CNA_FORNEC) .And. !Empty(AllTrim((cAlias)->NOME_FORNECEDOR))
				cKey := "F" + AllTrim((cAlias)->CNA_FORNEC) + AllTrim((cAlias)->CNA_LJFORN)

				If aScan(aKeys, cKey) == 0
					AAdd(aKeys, cKey)
					oParty := JsonObject():New()
					oParty["type"]  := "F"
					oParty["code"]  := AllTrim((cAlias)->CNA_FORNEC)
					oParty["store"] := AllTrim((cAlias)->CNA_LJFORN)
					oParty["name"]  := AllTrim((cAlias)->NOME_FORNECEDOR)
					aAdd(aResult, oParty)
				EndIf
			EndIf

			If !Empty((cAlias)->CNA_CLIENT) .And. !Empty(AllTrim((cAlias)->NOME_CLIENTE))
				cKey := "C" + AllTrim((cAlias)->CNA_CLIENT) + AllTrim((cAlias)->CNA_LOJACL)

				If aScan(aKeys, cKey) == 0
					AAdd(aKeys, cKey)
					oParty := JsonObject():New()
					oParty["type"]  := "C"
					oParty["code"]  := AllTrim((cAlias)->CNA_CLIENT)
					oParty["store"] := AllTrim((cAlias)->CNA_LOJACL)
					oParty["name"]  := AllTrim((cAlias)->NOME_CLIENTE)
					aAdd(aResult, oParty)
				EndIf
			EndIf

			(cAlias)->(DbSkip())
		EndDo

		(cAlias)->(DbCloseArea())
	EndIf

	oQuery:Destroy()
	FreeObj(oQuery)
	FreeObj(oParty)
	FwFreeArray(aKeys)

Return aResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RetApprovalBranch
Função que retorna em quais filiais o usuário é aprovador

@param oSelf, object, Objeto principal do WS

@return cBranches, caracter, filiais em que o usuário possui acesso
@author  Jose Renato
@since   22/08/2023
/*/
//-------------------------------------------------------------------------------------
Static Function RetApprovalBranch(oSelf)
	Local oStatement := FWPreparedStatement():New()
	Local cQuery        := ""
	Local cAliasSAK     := ""
	Local cBranches     := ""
	Local nBrancSize    := 0
	Local nPosBranch    := 0
	Local aUserInfo     := {}
	Local aDataUsr      := {}
	Local nBranchSAK    := 0
	Local nX            := 0
	Local nSizeEmp      := Len( cEmpAnt )

	cBranches:= IIF( Empty( oSelf:documentBranch ), cFilAnt, "" )

	If oSelf:documentBranch == "All"

		PswSeek( __cUserID, .T. )

		aDataUsr := PswRet()[2][6]

		nBranchSAK := BIFilialLen( "SAK", cEmpAnt )
		nBrancSize := FwSizeFilial( cEmpAnt )

		cQuery:= "SELECT DISTINCT AK_FILIAL FROM " +RetSQLName("SAK")+ " "
		cQuery+= "WHERE AK_USER = ? "

		oStatement:SetQuery(cQuery)
		oStatement:SetString(1,__cUserId)

		cQuery := oStatement:GetFixQuery()

		cQuery    := ChangeQuery( cQuery )
		cAliasSAK := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSAK, .F., .T. )

		If aDataUsr[1] == "@@@@"

			While ( cAliasSAK )->( !EOF() )

				aAdd( aUserInfo, cEmpAnt+ PadR(( cAliasSAK )->AK_FILIAL, nBranchSAK ))

				( cAliasSAK )->( dBSkip() )

			EndDo

		Else
			aUserInfo:=  aClone(aDataUsr)

		EndIf

		( cAliasSAK )->( DbGoTop() )

		While ( cAliasSAK )->( !EOF() )

			nPosBranch:= aScan( aUserInfo, {|x| PadR( x, nBranchSAK + nSizeEmp ) == cEmpAnt+ PadR(( cAliasSAK )->AK_FILIAL, nBranchSAK)  } )

			If nPosBranch > 0
				For nX:= nPosBranch to Len( aUserInfo )
					If cEmpAnt+AllTrim( ( cAliasSAK )->AK_FILIAL ) $ aUserInfo[nX]
						If !(SUBSTR( aUserInfo[nX], nSizeEmp+1 ) $ cBranches)
							cBranches += SUBSTR( aUserInfo[nX], nSizeEmp+1 )+","
						EndIf
					Else
						Exit
					EndIf
				Next
			EndIf

			( cAliasSAK )->( dBSkip() )

		EndDo

		( cAliasSAK )->( dbCloseArea() )

		cBranches := Subs( cBranches, 1, len( cBranches ) - 1 )

	ElseIf Empty( cBranches )

		cBranches := oSelf:documentBranch

	EndIf

	oStatement := NIL
	FreeObj( oStatement )

Return cBranches

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} approveBatch
	Função responsável pela aprovação de documentos em lote
@author philipe.pompeu
@since 25/07/2023
@return lResult, lógico, se a mensagem foi recebida com sucesso 
/*/
//-------------------------------------------------------------------------------------
	WSMETHOD PUT approveBatch PATHPARAM typeApprovals WSREST backofficeApprovals
	Local aApprovals:= {}
	Local aResult   := {}
	Local lResult   := .T.
	Local lCleanMdl := .T.
	Local cResponse := ""
	Local cBody     := ""
	Local nCode     := 400
	Local nX        := 0
	Local jResponse := Nil
	Local jRequest  := Nil
	Local jBatch    := Nil
	Local oBatch    := Nil

	cBody	:= Self:GetContent()

	jResponse := JsonObject():New()
	jResponse['documents'] := {}

	If !Empty(cBody)

		jRequest := JsonObject():New()

		jRequest:FromJSON(cBody)

		If jRequest:HasProperty('approvals')
			aApprovals := jRequest['approvals']

			lCleanMdl := (AllTrim(self:typeApprovals) == "MD")

			for nX := 1 to Len(aApprovals)
				jBatch := aApprovals[nX]

				oBatch := BatchApprovals():New(jBatch['branch'], self:typeApprovals)

				oBatch:setCleanModel(lCleanMdl)

				oBatch:setDocuments(jBatch['documents'])

				oBatch:processBatch()

				aEval(oBatch:getResult(), {|x|  aAdd(aResult, x) })
			next nX

			nCode := GetRespCode(aResult)

			jResponse['documents'] := aResult

		EndIf

	EndIf

	cResponse := jResponse:ToJSON()

	Self:setStatus(nCode)
	Self:SetResponse( cResponse )

	FreeObj( jResponse )
	FreeObj( oBatch )
Return( lResult )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRespCode
	Retorna o código http com base em <aDocuments>
@author philipe.pompeu
@since 25/07/2023
@param aDocuments, vetor, lista de documentos processados
@return nCode, numérico, código do status http
/*/
//-------------------------------------------------------------------------------------
Static Function GetRespCode(aDocuments)
	Local nCode := 400
	Local nX    := 0
	Local lHasFail := .F.
	Local lHasSuccess := .F.

	for nX := 1 to Len(aDocuments)
		If (aDocuments[nX]["success"])
			if !lHasSuccess
				lHasSuccess := .T.
			endif
		Else
			if !lHasFail
				lHasFail := .T.
			endif
		EndIf
	next nX

	If (lHasFail .And. lHasSuccess)
		nCode := 207
	ElseIf lHasSuccess
		nCode := 200
	EndIf
Return nCode

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BatchApprovals
	Definição da classe responsável pela aprovação de documentos em lote
@author philipe.pompeu
@since 25/07/2023
/*/
//-------------------------------------------------------------------------------------
	Class BatchApprovals
		Data cFilApp as Character
		Data cType as Character
		Data cUser as Character

		Data aDocuments  As Array
		Data aResponse  As Array

		Data lCleanModel as Logical

		Data oModel094 as Object
		Data jCurrentDoc as Object

		Method New(cFilApp, cType) Constructor

		Method setDocuments(aDocuments)
		Method processBatch()
		Method processDocument()
		Method addToResponse(lSuccess,cDetails)
		Method getResult()
		Method setCleanModel(lCleanMdl)

	EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
	Método construtor da classe
@author philipe.pompeu
@since 25/07/2023
@param cFilApp  , caractere, código da filial na qual os documentos devem ser aprovados
@param cType    , caractere, tipo dos documentos do lote
/*/
//-------------------------------------------------------------------------------------
Method New(cFilApp, cType) Class BatchApprovals
	Self:cFilApp    := cFilApp
	Self:cType      := cType
	Self:cUser      := __cUserId
	Self:aDocuments := {}
	Self:aResponse  := {}
	Self:lCleanModel := .F.
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} setDocuments
	Set da propriedade Documents(documentos que devem ser processados no lote)
@author philipe.pompeu
@since 25/07/2023
@param aDocuments  , array, lista de documentos
/*/
Method setDocuments(aDocuments) Class BatchApprovals

	Self:aDocuments := aClone(aDocuments)
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} processBatch
	Realiza o processamento dos documentos em <aDocuments>
@author philipe.pompeu
@since 25/07/2023
/*/
//-------------------------------------------------------------------------------------
Method processBatch() Class BatchApprovals
	Local aAreas    := {SCR->(GetArea()), GetArea()}
	Local jDocument := Nil
	Local nX        := 0
	Local cFilBkp   := cFilAnt
	Local cSeek     := ""
	Local cKey      := ""
	Local cItGroup  := ""
	Local nItGrpSize:= GetSx3Cache('CR_ITGRP'   ,'X3_TAMANHO')
	Local nDocIdSize:= GetSx3Cache('CR_NUM'     ,'X3_TAMANHO')
	Local lSuccess  := .F.
	Local cDetails  := ""

	cFilAnt := ::cFilApp

	SCR->(DbSetOrder(2))

	cSeek := xFilial("SCR") + ::cType

	SCR->(DbSeek(cSeek))

	for nX := 1 to Len(::aDocuments)
		jDocument   := ::aDocuments[nX]
		cDetails    := ""

		jDocument['documentId'] := PadR(jDocument['documentId'], nDocIdSize)

		::jCurrentDoc := jDocument

		If (lSuccess := SCR->(DbSeek(cSeek + jDocument['documentId'] + ::cUser)))

			If(jDocument['scrId'])
				SCR->(DbGoTo(jDocument['scrId']))
			EndIf

			cItGroup := jDocument['itemGroup']

			If !Empty(cItGroup)
				cItGroup := PadR(cItGroup, nItGrpSize)
				cKey := SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_USER

				While SCR->(!Eof()) .And. (SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_USER == cKey)
					If SCR->CR_ITGRP == cItGroup
						Exit
					EndIf
					SCR->(DbSkip())
				EndDo
			EndIf

			If (::oModel094 == Nil)
				::oModel094 := FWLoadModel('MATA094')
			EndIf

			lSuccess := ::processDocument()

			If !lSuccess .And. ::oModel094:HasErrorMessage()
				cDetails := I18N(STR0003, ;
					{::oModel094:GetErrorMessage()[6], ::oModel094:GetErrorMessage()[7]})
			EndIf

			If ::oModel094:IsActive()
				::oModel094:DeActivate()
			EndIf

			If ::lCleanModel
				FreeObj(::oModel094)
			EndIf
		Else
			cDetails := I18N(STR0004,{ AllTrim(jDocument['documentId']) })
		EndIf

		::addToResponse(lSuccess, cDetails)

	next nX

	cFilAnt := cFilBkp

	aEval(aAreas,{|x| RestArea(x) })
	FwFreeArray(aAreas)
	FreeObj(::oModel094)
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} processDocument
	Realiza a aprovação/rejeição do documento atual(jCurrentDoc)
@author philipe.pompeu
@since 25/07/2023
@return lResult, lógico, se a operação foi realizada com sucesso
/*/
//-------------------------------------------------------------------------------------
Method processDocument() Class BatchApprovals
	Local aAreas        := {SCR->(GetArea()), GetArea()}
	Local lResult       := .T.
	Local cOperation    := ""
	Local cJustif       := STR0009
	Local jDocument     := ::jCurrentDoc

	If !(Empty(jDocument['justification']))
		cJustif := DecodeUTF8(Alltrim(jDocument['justification']))
	EndIf

	cOperation := IIF(jDocument['toApprove'], '001', '005')
	A094SetOp(cOperation)

	::oModel094:SetOperation(MODEL_OPERATION_UPDATE)
	If (lResult := ::oModel094:Activate())

		::oModel094:GetModel("FieldSCR"):SetValue( 'CR_OBS' , cJustif )

		lResult := (::oModel094:VldData() .And. ::oModel094:CommitData())
	EndIf

	aEval(aAreas,{|x| RestArea(x) })
	FwFreeArray(aAreas)
Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} addToResponse
	Inclui o documento atual(jCurrentDoc) na resposta
@author philipe.pompeu
@since 25/07/2023
@param lSuccess, lógico, se a operação foi realizada com sucesso
@param cDetails, caractere, detalhes do erro caso a operação tenha falhado
/*/
//-------------------------------------------------------------------------------------
Method addToResponse(lSuccess,cDetails) Class BatchApprovals
	Local jDocResult    := JsonObject():New()
	Local cMessage      := ""
	Local cDocId        := AllTrim(::jCurrentDoc['documentId'])
	Local cFailMsg      := ""
	Local cSuccessMsg   := ""

	If (::jCurrentDoc['toApprove'])
		cFailMsg    := STR0005
		cSuccessMsg := STR0006
	Else
		cFailMsg    := STR0007
		cSuccessMsg := STR0008
	EndIf

	cMessage := IIF(lSuccess, cSuccessMsg, cFailMsg)
	cMessage := I18N(cMessage, { cDocId })

	jDocResult['success']           := lSuccess
	jDocResult['documentId']        := cDocId
	jDocResult['documentBranch']    := EncodeUTF8(SCR->CR_FILIAL)
	jDocResult['documentType']      := EncodeUTF8(SCR->CR_TIPO)
	jDocResult['message']           := EncodeUTF8(cMessage)
	jDocResult['detailedMessage']   := EncodeUTF8(cDetails)
	jDocResult['statusApprovals']   := EncodeUTF8(SCR->CR_STATUS)
	jDocResult['documentTotal']     := SCR->CR_TOTAL

	aAdd(::aResponse, jDocResult)
Return nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getResult
	Obtem o resultado da operação de processamento do lote
@author philipe.pompeu
@since 25/07/2023
@return aResponse, vetor, lista de JsonObject com o resultado do processamento
/*/
//-------------------------------------------------------------------------------------
Method getResult()  Class BatchApprovals

Return self:aResponse

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} setCleanModel
	Permite informar se deve recarregar o modelo do mata094 para cada um dos documentos do lote
@author philipe.pompeu
@since 28/07/2023
@param lCleanMdl, lógico, se deve limpar o modelo
/*/
//-------------------------------------------------------------------------------------
Method setCleanModel(lCleanMdl) Class BatchApprovals
	::lCleanModel := lCleanMdl
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getItemsByDoc
	Método responsável pelo retorno dos itens de determinado documento
@author philipe.pompeu
@since 21/08/2023
@PathParam typeApprovals , caractere , tipo do documento[purchaserequest=SC, purchaseorder=PC,contractmeasurement=MD]
@PathParam documentId   , caractere , recNo do documento(SCR)
@QueryParam page        , numérico  , página atual
@QueryParam pageSize    , numérico  , tamanho da página
@QueryParam itemGroup   , caractere , item do documento(DBM)
/*/
//-------------------------------------------------------------------------------------
WSMETHOD GET getItemsByDoc PATHPARAM typeApprovals, documentId WSRECEIVE page, pageSize, itemGroup WSSERVICE backofficeApprovals
	Local nTypeIndex := 0
	Local nCode      := 400
	Local nRecId     := 0
	Local jResponse  := Nil
	Local cOper      := ""
	Local cResponse  := ""
	Local cVldTypes  := ""
	Local aTypes     := { ;
		{'purchaserequest'      , 'purchaseRequestItems'     , 'SC'     }, ;
		{'warehouserequest'     , 'warehouseRequestItems'    , 'SA'     }, ;
		{'purchaseorder'        , 'purchaseOrderItems'       , 'PC|IP|AE'}, ;
		{'salesorder'           , 'salesOrderItems'          , 'PV'     }, ;
		{'salesdiscount'        , 'salesDiscountItems'       , 'DV'     }, ;
		{'contracts'            , 'contractsItems'           , 'CT'     }, ;
		{'contractmeasurement'  , 'contractMeasurementItems' , 'MD|IM'  } ;
		}

	Default Self:page      := 1
	Default Self:pageSize  := 10
	Default Self:itemGroup := ""

	nTypeIndex := aScan( aTypes, {|x| x[1] == Lower( AllTrim( Self:typeApprovals ) ) } )
	If nTypeIndex > 0
		cOper     := aTypes[nTypeIndex,2]
		cVldTypes := aTypes[nTypeIndex,3]
		nRecId    := Val( Self:documentId )

		If nRecId > 0
			SCR->( DbGoTo( nRecId ) )

			If SCR->( !Eof() ) .And. AllTrim( SCR->CR_TIPO ) $ cVldTypes
				If cOper == 'contractMeasurementItems'
					jResponse := getMDItems( nRecId )
					If ValType( jResponse ) == "J"
						nCode := 200
					EndIf
				Else
					nCode     := 200
					jResponse := JsonObject():New()
					Self:itemGroup := PadR( Self:itemGroup, GetSx3Cache( 'CR_ITGRP', 'X3_TAMANHO' ) )
					MobJSONResult( cOper, Self, @jResponse )
				EndIf
			EndIf
		EndIf
	EndIf

	If nCode > 299
		jResponse := BadReqResponse()
	EndIf

	If ValType( jResponse ) == "J"
		cResponse := jResponse:ToJSON()
	EndIf

	Self:SetStatus( nCode )
	Self:SetResponse( cResponse )

	FWFreeArray( aTypes )
	FreeObj( jResponse )
Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetPropByOper
	Função estática que será acionada pela classe <MobileService> e deve retornar a relação
entre propriedades e os campos da consulta
@author philipe.pompeu
@since 21/08/2023
@param cOper, caractere, código da operação sendo realizada
@return aProperties, vetor, relação entre propriedades do json e os campos da query
/*/
//-------------------------------------------------------------------------------------
Static Function SetPropByOper( cOper )
	Local aProperties := {}

	Do Case
	Case cOper == 'warehouseRequestItems'
		aProperties := { ;
			{ "CP_NUM"      , "requestNumber"      }, ;
			{ 'CP_ITEM'     , 'requestItem'        }, ;
			{ 'CP_PRODUTO'  , "itemProduct"        }, ;
			{ 'CP_UM'       , "unitMeasurement"    }, ;
			{ 'CP_QUANT'    , "quantity"           }, ;
			{ 'CP_CC'       , "costCenter"         }, ;
			{ 'B1_DESC'     , "itemSkuDescription" }, ;
			{ "CR_GRUPO"    , "groupAprov"         }, ;
			{ "CR_ITGRP"    , "itemGroup"          } ;
			}

	Case cOper == 'purchaseRequestItems'
		aProperties := { ;
			{ "C1_NUM"      , "requestNumber"      }, ;
			{ 'C1_ITEM'     , 'requestItem'        }, ;
			{ 'C1_PRODUTO'  , "itemProduct"        }, ;
			{ 'C1_UM'       , "unitMeasurement"    }, ;
			{ 'C1_QUANT'    , "quantity"           }, ;
			{ 'C1_CC'       , "costCenter"         }, ;
			{ 'C1_TOTAL'    , "itemTotal"          }, ;
			{ 'C1_PRECO'    , "unitValue"          }, ;
			{ 'C1_MOEDA'    , "currency"           }, ;
			{ 'B1_DESC'     , "itemSkuDescription" }, ;
			{ "CR_GRUPO"    , "groupAprov"         }, ;
			{ "CR_ITGRP"    , "itemGroup"          } ;
			}

	Case cOper == "purchaseOrderItems"
		aProperties := { ;
			{ 'C7_NUM'      , "purchaseOrderNumber" }, ;
			{ 'C7_ITEM'     , 'purchaseOrderItem'  }, ;
			{ 'C7_CC'       , "costCenter"         }, ;
			{ 'C7_QUANT'    , "quantity"           }, ;
			{ 'C7_TOTAL'    , "itemTotal"          }, ;
			{ 'C7_PRECO'    , "unitValue"          }, ;
			{ 'C7_PRODUTO'  , "itemSku"            }, ;
			{ 'B1_DESC'     , "itemSkuDescription" }, ;
			{ 'C7_UM'       , "unitMeasurement"    }, ;
			{ "CR_GRUPO"    , "groupAprov"         }, ;
			{ "CR_ITGRP"    , "itemGroup"          }, ;
			{ 'C7_MOEDA'    , "currency"           } ;
			}

	Case cOper == "salesOrderItems"
		aProperties := { ;
			{ 'C6_NUM'      , "salesOrderNumber"   }, ;
			{ 'C6_ITEM'     , "salesOrderItem"     }, ;
			{ 'C6_PRODUTO'  , "itemSku"            }, ;
			{ 'B1_DESC'     , "itemSkuDescription" }, ;
			{ 'C6_QTDVEN'   , "quantity"           }, ;
			{ 'C6_PRCVEN'   , "unitValue"          }, ;
			{ 'C6_VALOR'    , "itemTotal"          }, ;
			{ 'C6_UM'       , "unitMeasurement"    }, ;
			{ 'C6_TES'      , "tes"                }, ;
			{ 'C6_LOCAL'    , "warehouse"          }, ;
			{ 'C6_PEDCLI'   , "customerOrderNumber"}, ;
			{ "CR_GRUPO"    , "groupAprov"         }, ;
			{ "CR_ITGRP"    , "itemGroup"          } ;
			}

	Case cOper == "salesDiscountItems"
		aProperties := { ;
			{ 'C6_NUM'      , "salesOrderNumber"   }, ;
			{ 'C6_ITEM'     , "salesOrderItem"     }, ;
			{ 'C6_PRODUTO'  , "itemSku"            }, ;
			{ 'B1_DESC'     , "itemSkuDescription" }, ;
			{ 'C6_QTDVEN'   , "quantity"           }, ;
			{ 'C6_PRCVEN'   , "unitValue"          }, ;
			{ 'C6_VALOR'    , "itemTotal"          }, ;
			{ 'C6_UM'       , "unitMeasurement"    }, ;
			{ 'C6_TES'      , "tes"                }, ;
			{ 'C6_LOCAL'    , "warehouse"          }, ;
			{ 'C6_PEDCLI'   , "customerOrderNumber"}, ;
			{ "CR_GRUPO"    , "groupAprov"         }, ;
			{ "CR_ITGRP"    , "itemGroup"          } ;
			}
	EndCase
Return aProperties

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} QueryModel
	Função estática que será acionada pela classe <MobileService> e deve retornar o FWPreparedStatement
com a query a ser executada pelo serviço
@author philipe.pompeu
@since 21/08/2023
@param cOper, caractere, operação sendo realizada
@param oSelf, objeto, instância do webservice backOfficeApprovals
@param oService, objeto, instância de MobileService
@return oStatement, objeto, instância de FWPreparedStatement
/*/
//-------------------------------------------------------------------------------------
Static Function QueryModel( cOper, oSelf, oService )
	Local aQueryInfo   := {}
	Local aMainWhere   := {}
	Local aVariables   := {}
	Local cMainTable   := ''
	Local cFields      := ''
	Local cOrderBy     := ''
	Local cQuery       := ''
	Local cServiceName := 'backofficeApprovals'
	Local nTesSize     := 0
	Local lExsCompl    := SF1->(FieldPos("F1_TPCOMPL")) > 0

	Do Case
	Case cOper == 'warehouseRequestItems'
		cMainTable := 'SCP'
		cFields := 'CP_NUM, CP_ITEM, CP_PRODUTO, CP_UM, CP_QUANT, CP_CC'

		aMainWhere := { {"CP_FILIAL = ? ", xFilial( cMainTable ) } }

		aJoin := { { "SCR", "INNER", { 'CR_GRUPO', 'CR_ITGRP' }, ;
			{   { "CR_FILIAL = ?", xFilial( "SCR" ) }, ;
			{ "CR_NUM = CP_NUM" }, ;
			{ 'SCR.R_E_C_N_O_ = ?', val( oSelf:documentId ) } } }, ;
			{ "SB1", "INNER", 'B1_DESC' , ;
			{ { "B1_FILIAL = ?", xFilial( "SB1" ) }, ;
			{ "B1_COD = CP_PRODUTO" } } }, ;
			{ "DBM", "INNER", '' , ;
			{ { "DBM_FILIAL = ?", xFilial( "DBM" ) }, ;
			{ "DBM_NUM = CR_NUM" }, ;
			{ "DBM_ITEM = CP_ITEM" }, ;
			{ "DBM_ITGRP = CR_ITGRP" }, ;
			{ "DBM_GRUPO = CR_GRUPO" }, ;
			{ "DBM_USER = CR_USER" } } } ;
			}

		aQueryInfo := { cMainTable, cFields, aMainWhere, aJoin }

	Case cOper == 'purchaseRequestItems'
		cMainTable := 'SC1'
		cFields := 'C1_NUM, C1_ITEM, C1_PRODUTO, C1_UM, C1_QUANT, C1_CC, C1_TOTAL, C1_PRECO, C1_MOEDA'

		aMainWhere := { {"C1_FILIAL = ? ", xFilial( cMainTable ) } }

		aJoin := { { "SCR", "INNER", { 'CR_GRUPO', 'CR_ITGRP' }, ;
			{   { "CR_FILIAL = ?", xFilial( "SCR" ) }, ;
			{ "CR_NUM = C1_NUM" }, ;
			{ 'SCR.R_E_C_N_O_ = ?', val( oSelf:documentId ) } } }, ;
			{ "SB1", "INNER", 'B1_DESC' , ;
			{ { "B1_FILIAL = ?", xFilial( "SB1" ) }, ;
			{ "B1_COD = C1_PRODUTO" } } }, ;
			{ "DBM", "INNER", '' , ;
			{ { "DBM_FILIAL = ?", xFilial( "DBM" ) }, ;
			{ "DBM_NUM = CR_NUM" }, ;
			{ "DBM_ITEM = C1_ITEM" }, ;
			{ "DBM_ITGRP = CR_ITGRP" }, ;
			{ "DBM_GRUPO = CR_GRUPO" }, ;
			{ "DBM_USER = CR_USER" } } } ;
			}

		aQueryInfo := { cMainTable, cFields, aMainWhere, aJoin }

	Case cOper == "purchaseOrderItems"
		cMainTable  := 'SC7'
		cOrderBy := 'C7_ITEM'

		cQuery := "SELECT <<PAGE_CONTROL>>, C7_NUM, C7_ITEM, C7_CC, C7_QUANT, C7_TOTAL, C7_PRECO, C7_PRODUTO, C7_UM, B1_DESC, C7_MOEDA, CR_GRUPO, CR_ITGRP "
		cQuery +=   " FROM " + RetSqlName( "SC7" ) + " SC7 "
		cQuery +=   " INNER JOIN " + RetSqlName( "SCR" ) + " SCR ON CR_FILIAL = '" + XFilial("SCR") + "' AND CR_NUM = C7_NUM AND SCR.D_E_L_E_T_ = ' '"
		cQuery +=   " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON B1_FILIAL = '" + XFilial( "SB1" ) + "' AND B1_COD = C7_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "

		If !Empty(AllTrim(oSelf:itemGroup))
			cQuery +=   " INNER JOIN " + RetSqlName( "DBM" ) + " DBM ON DBM_FILIAL = '" + XFilial("DBM") + "' AND DBM_NUM = C7_NUM AND DBM_ITEM = C7_ITEM AND CR_ITGRP = DBM_ITGRP"
			cQuery +=   " AND CR_USER = DBM_USER AND DBM.D_E_L_E_T_ = ' ' "
		EndIf

		cQuery +=   " WHERE C7_FILIAL = '" + XFilial("SC7") + "' "
		cQuery +=     " AND SCR.R_E_C_N_O_ = ? "
		cQuery +=     " AND CR_ITGRP = ? "
		cQuery +=     " AND SC7.D_E_L_E_T_ = ' ' "
		cQuery +=     " GROUP BY C7_NUM,C7_ITEM,C7_CC,C7_QUANT,C7_TOTAL ,C7_PRECO,C7_PRODUTO,C7_UM,B1_DESC,C7_MOEDA, CR_GRUPO, CR_ITGRP "

		aAdd( aVariables, { 'N', 'SCR.R_E_C_N_O_ = ?', val( oSelf:documentId ) } )
		aAdd( aVariables, { 'C', 'CR_ITGRP = ?', oSelf:itemGroup } )

		oService := MobileService():New(cServiceName)
		oService:SetOrderBy(cOrderBy)
		oService:SetItemsName("purchaseOrderItems")
		oStatement := oService:SetQuery( cQuery )
		oService:SetVariables( aVariables )

	Case cOper == "salesOrderItems"
		cMainTable := 'SC6'
		cOrderBy   := 'C6_ITEM'

		cQuery := "SELECT <<PAGE_CONTROL>>, "
		cQuery += " C6_NUM, C6_ITEM, C6_PRODUTO, C6_UM, C6_QTDVEN, C6_PRCVEN, "
		cQuery += " C6_VALOR, C6_TES, C6_LOCAL, C6_PEDCLI, "
		cQuery += " B1_DESC, CR_GRUPO, CR_ITGRP "
		cQuery += " FROM " + RetSqlName( "SC6" ) + " SC6 "
		cQuery += " INNER JOIN " + RetSqlName( "SCR" ) + " SCR "
		cQuery += " ON CR_FILIAL = '" + xFilial("SCR") + "' "
		cQuery += " AND CR_NUM = C6_NUM "
		cQuery += " AND SCR.D_E_L_E_T_ = ' ' "

		cQuery += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 "
		cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " AND B1_COD = C6_PRODUTO "
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery += " AND SCR.R_E_C_N_O_ = ? "

		cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY "
		cQuery += " C6_NUM, C6_ITEM, C6_PRODUTO, C6_UM, C6_QTDVEN, C6_PRCVEN, "
		cQuery += " C6_VALOR, C6_TES, C6_LOCAL, C6_PEDCLI, "
		cQuery += " B1_DESC, CR_GRUPO, CR_ITGRP "

		aAdd( aVariables, { 'N', 'SCR.R_E_C_N_O_ = ?', Val( oSelf:documentId ) } )

		oService := MobileService():New(cServiceName)
		oService:SetOrderBy(cOrderBy)
		oService:SetItemsName("salesOrderItems")
		oStatement := oService:SetQuery( cQuery )
		oService:SetVariables( aVariables )

	Case cOper == "salesDiscountItems"
		cMainTable := 'SC6'
		cOrderBy   := 'C6_ITEM'

		cQuery := "SELECT <<PAGE_CONTROL>>, "
		cQuery += " C6_NUM, C6_ITEM, C6_PRODUTO, C6_UM, C6_QTDVEN, C6_PRCVEN, "
		cQuery += " C6_VALOR, C6_TES, C6_LOCAL, C6_PEDCLI, "
		cQuery += " B1_DESC, CR_GRUPO, CR_ITGRP "
		cQuery += " FROM " + RetSqlName( "SC6" ) + " SC6 "
		cQuery += " INNER JOIN " + RetSqlName( "SCR" ) + " SCR "
		cQuery += " ON CR_FILIAL = '" + xFilial("SCR") + "' "
		cQuery += " AND CR_NUM = C6_NUM "
		cQuery += " AND SCR.D_E_L_E_T_ = ' ' "

		cQuery += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 "
		cQuery += " ON B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " AND B1_COD = C6_PRODUTO "
		cQuery += " AND SB1.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery += " AND SCR.R_E_C_N_O_ = ? "

		cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY "
		cQuery += " C6_NUM, C6_ITEM, C6_PRODUTO, C6_UM, C6_QTDVEN, C6_PRCVEN, "
		cQuery += " C6_VALOR, C6_TES, C6_LOCAL, C6_PEDCLI, "
		cQuery += " B1_DESC, CR_GRUPO, CR_ITGRP "

		aAdd( aVariables, { 'N', 'SCR.R_E_C_N_O_ = ?', Val( oSelf:documentId ) } )

		oService := MobileService():New(cServiceName)
		oService:SetOrderBy(cOrderBy)
		oService:SetItemsName("salesDiscountItems")
		oStatement := oService:SetQuery( cQuery )
		oService:SetVariables( aVariables )

	Case cOper == "historyByItem"
		cMainTable := 'SD1'
		nTesSize := GetSx3Cache( "D1_TES", "X3_TAMANHO" )
		cOrderBy := 'D1_EMISSAO DESC '

		cQuery := "SELECT <<PAGE_CONTROL>>, D1_EMISSAO, A2_NOME, D1_QUANT, D1_VUNIT "
		cQuery +=   " FROM " + RetSqlName( "SD1" ) + " SD1 "
		cQuery +=   " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON A2_FILIAL = ? AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
		If (lExsCompl)
			cQuery +=   " INNER JOIN " + RetSqlName( "SF1" ) + " SF1 ON SF1.F1_FILIAL = ? "
			cQuery +=   "   AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE "
			cQuery +=   "   AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA "
			cQuery +=   "   AND NOT (SF1.F1_TIPO = '5' AND SF1.F1_TPCOMPL = '3') AND SF1.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery +=   " WHERE D1_FILIAL = ? "
		cQuery +=     " AND D1_COD = ? "
		cQuery +=     " AND D1_TIPO NOT IN ('D', 'B') "
		cQuery +=     " AND D1_TES <> '" + Space( nTesSize ) + "' "
		cQuery +=     " AND SD1.D_E_L_E_T_ = ' ' "

		aAdd( aVariables, { 'C', 'A2_FILIAL = ?', XFilial( "SA2" ) } )
		If (lExsCompl)
			aAdd( aVariables, { 'C', 'F1_FILIAL = ?', FwxFilial( "SF1" ) } )
		EndIf
		aAdd( aVariables, { 'C', 'D1_FILIAL = ?', XFilial( "SD1" ) } )
		aAdd( aVariables, { 'C', 'D1_COD = ?', oSelf:productCode  } )

		oService := MobileService():New( )
		oService:SetOrderBy(cOrderBy)
		oStatement := oService:SetQuery( cQuery )
		oService:SetVariables( aVariables )

	EndCase

	If oService == NIL
		oService := MobileService():New(cServiceName)
		oStatement := oService:MakeQueryModel( aQueryInfo )
	EndIf

	oSelf:mainTable := cMainTable

	FWFreeArray( aVariables )
Return oStatement

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} getMDItems
	Função responsável por retornar os itens de uma medição com base no documento(SCR)
@author philipe.pompeu
@since 21/08/2023
@param nRecSCR, numérico, recno do documento
@return jResponse, objeto, instância de JsonObject com os dados da medição
/*/
//-------------------------------------------------------------------------------------
Static Function getMDItems(nRecSCR)
	Local aArea     := SCR->(GetArea())
	Local jResponse := Nil

	If FindFunction('WS121GetMd')
		SCR->(DbGoTo(nRecSCR))
		jResponse := WS121GetMd( SCR->CR_NUM, SCR->CR_TIPO, SCR->CR_MOEDA, SCR->CR_TOTAL)
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
Return jResponse

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BadReqResponse
	Retorna um objeto no formato padrão para resposta 400(Bad Request)
@author philipe.pompeu
@since 21/08/2023
@return jResponse, objeto, instância de JsonObject
/*/
//-------------------------------------------------------------------------------------
Static Function BadReqResponse()
	Local jResponse := JsonObject():New()

	jResponse['code']            := 400
	jResponse['origin']          := ""
	jResponse['message']         := EncodeUTF8("Bad Request")
	jResponse['detailedMessage'] := ""
Return jResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} itemAdditionalInformation
    Método para retornar as informações adicionais do item do pedido ou da solicitação de compra

@author Jose Renato
@since 14/11/2023
@param recordNumber, caractere, número do pedido ou solicitação de compra
@param itemNumber, caractere, item do pedido ou da solicitação de compra
@return lRet, lógico, se retornou os dados relacionados ao item do pedido ou da solicitação.

/*/
//-------------------------------------------------------------------
WSMETHOD GET itemAdditionalInformation WSRECEIVE recordNumber, itemNumber WSSERVICE backofficeApprovals
	Local aArea         := SCR->(GetArea())
	Local oResponse     := JsonObject():New()
	Local aFields       := {}
	Local cJson         := ""
	Local cFields       := ""
	Local cField        := ""
	Local cType         := ""
	Local lRet          := .F.
	Local nRec          := 1
	Local nIndexTable   := 1
	Local oService      := Nil
	Local oItem         := Nil
	Local cServiceName  := 'backofficeApprovals'
	Local cRecordNumber := ""
	Local cItem         := ""
	Local cTable        := ""
	Local cObsField     := ""
	Local cDoc          := ""
	Local lMeasurements := .F.
	Local nResponse     := 400
	Local nPos          := 0
	Local cMoreFields   := ""
	Local cExecBlock    := ""
	Local nX            := 0
	Local aTemp         := {}
	Local cMessage      := ""

	cRecordNumber := Self:recordNumber
	cItem         := Self:itemNumber

	dbSelectArea( "SAK" )
	dbSetOrder( 2 )

	If MsSeek( xFilial( "SAK" ) + __cUserId )
		SCR->( DbGoTo( Self:itemRecno ) )
		cDoc := ReturnDocType( SCR->CR_TIPO )

		Do Case
		Case cDoc == "purchaseOrder"
			cObsField   := "C7_OBS"
			cMoreFields := "C7_DATPRF, C7_QUJE, C7_OBS"
			cTable      := "SC7"
			nIndexTable := 1
			If ExistBlock( "MT094CPC" )
				cExecBlock := "MT094CPC"
			Else
				cExecBlock := "MPADDCPO"
			EndIf

		Case cDoc == "purchaseRequest"
			cObsField   := "C1_OBS"
			cMoreFields := "C1_OBS"
			cTable      := "SC1"
			nIndexTable := 1
			cExecBlock  := "MPADDCPO"

		Case cDoc == "warehouseRequest"
			cObsField   := "CP_OBS"
			cMoreFields := "CP_OBS"
			cTable      := "SCP"
			nIndexTable := 1
			cExecBlock  := "MPADDCPO"

		Case cDoc == "measurements"
			cObsField   := "CND_OBS"
			cMoreFields := "CND_OBS"
			cTable      := "CND"
			nIndexTable := 4
			cExecBlock  := "MPADDCPO"
			If getMDItems( Self:itemRecno ) <> NIL
				lMeasurements := .T.
			EndIf

		Case cDoc == "contracts" .Or. cDoc == "contractItem"
			cObsField   := "CN9_REVISA"
			cMoreFields := "CN9_REVISA"
			cTable      := "CN9"
			nIndexTable := 1
			cExecBlock  := "MPADDCPO"
			lMeasurements := .T.

		Case cDoc == "salesOrder"
			cObsField   := "C6_TES"
			cMoreFields := "C6_TES,C6_LOCAL,C6_PEDCLI"
			cTable      := "SC6"
			nIndexTable := 1
			cExecBlock  := "MPADDCPO"

		Case cDoc == "salesDiscount"
			cObsField   := "C6_TES"
			cMoreFields := "C6_TES,C6_LOCAL,C6_PEDCLI"
			cTable      := "SC6"
			nIndexTable := 1
			cExecBlock  := "MPADDCPO"

		EndCase

		(cTable)->( DbSetOrder( nIndexTable ) )

		If ( cTable )->( dbSeek( XFilial ( cTable ) + IIF( !lMeasurements, cRecordNumber + cItem, cRecordNumber ) ) )
			oService := MobileService():New( cServiceName, cExecBlock )
			oService:SetMainTable( cTable )
			cFields := oService:AddFieldsbyPE()

			If !Empty( cFields )
				cFields := cMoreFields + "," + cFields
			Else
				cFields := cMoreFields
			EndIf

			aTemp := StrToArray( cFields, ',' )
			For nX := 1 To Len( aTemp )
				If aScan( aFields, AllTrim( aTemp[nX] ) ) == 0
					aAdd( aFields, AllTrim( aTemp[nX] ) )
				EndIf
			Next

			oResponse[ "itemsAdditionalInformation" ] := {}
			oResponse[ "hasNext" ] := .F.

			For nRec := 1 To Len( aFields )
				cField := aFields[nRec]
				nPos := ( cTable )->( FieldPos( cField ) )
				If nPos > 0
					cType := FWSX3Util():GetFieldType( cField )
					oItem := JsonObject():New()
					oItem[ "label" ] := EncodeUTF8( FWX3Titulo( cField ) )
					oItem[ "type" ]  := cType

					If cType == "D"
						oItem[ "data" ] := DToS( ( cTable )->( FieldGet( nPos ) ) )
					ElseIf cType == "M" .Or. cObsField $ cField
						oItem[ "data" ] := EncodeUTF8( ( cTable )->( FieldGet( nPos ) ) )
					Else
						oItem[ "data" ] := EncodeUTF8( AllTrim( ( cTable )->( FieldGet( nPos ) ) ) )
					EndIf

					AAdd( oResponse[ "itemsAdditionalInformation" ], oItem )
				EndIf
			Next

			cJson := FWJsonSerialize( oResponse, .F., .F., .T. )
			Self:SetResponse( cJson )
			nResponse := 200
			lRet := .T.
		Else
			cMessage := STR0016
		EndIf
	Else
		cMessage := STR0011
	EndIf

	If nResponse == 400
		SetRestFault( 400, EncodeUTF8( cMessage ), .T., 400, EncodeUTF8( cMessage ) )
	EndIf

	RestArea( aArea )
	FreeObj( oItem )
	FreeObj( oService )
	FWFreeArray( aFields )
	FWFreeArray( aTemp )
Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} historyByItem
Serviço que retorna as últimas compras de um determinado produto

@param page, number, número da página para retorno
@param pageSize, number, número de registros por página
@param productCode, caracter, código do produto para pesquisa
@return lRet, lógico, se retornou os dados relacionados ao histórico.


@author Jose Renato
@since 24/11/2023 
/*/
//------------------------------------------------------------------------------------------------
WSMETHOD GET historyByItem WSRECEIVE page, pageSize, productCode WSSERVICE backofficeApprovals
	Local oResponse     := JsonObject():New()
	Local cOper         := "historyByItem"
	Local cJson         := ""
	Local lRet          := .T.
	Local nResponse     := 400

	Default Self:page        := 1
	Default Self:pageSize    := 10
	Default Self:productCode  := ""

	If !Empty( Self:productCode )
		cApprover := MobChkApprover( 2 )

		If !Empty( cApprover )
			Self:approverCode := cApprover

			MobJSONResult( cOper, @Self, @oResponse )

			nResponse:= 200
		Else
			lRet := .F.
			cMessage:= STR0011
		EndIf

		cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

		::SetResponse( cJson )
	Else
		cMessage:= STR0018
	EndIf

	If nResponse == 400
		SetRestFault( 400, EncodeUTF8( cMessage ), .T., 400, EncodeUTF8( cMessage )  )
	EndIf

	lRet:= ( nResponse == 200 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} attachments
    Método para retornar o anexo do documento
@author Jose Renato
@since 08/12/2023

@param objectCode, object, código do objeto para pesquisa

@return lRet, lógico, se retornou o anexo
/*/
//-------------------------------------------------------------------
WSMETHOD GET attachments PATHPARAM objectCode WSSERVICE backofficeApprovals
	Local oResponse     := JsonObject():New()
	Local oFb           := NIL
	Local oItem         := Nil
	Local cJson         := ""
	Local lRet          := .F.
	Local lFileInDB     := .F.
	Local cDirDoc       := Alltrim(MsDocPath())
	Local cFileName     := ""
	Local cExtension    := ""
	Local cArq          := ""
	Local nSize         := 0
	Local cFullFilePath := ""
	Local cFilePath     := ""
	Local nResponse     := 400
	Local cMessage      := ""
	Local oFileReader   := NIL
	Local lProcessFile  := .F.

	Default Self:objectCode := ""

	ACB->( DbSetOrder( 1 ) )
	If ACB->( DbSeek( FwXFilial( "ACB" ) + Self:objectCode ) )
		oResponse[ "itemsAttachments" ] := {}
		oResponse[ "hasNext" ] := .F.

		oItem := JsonObject():New()

		cFilePath := Lower( ACB->ACB_OBJETO )
		If !Empty( cFilePath )
			cFullFilePath := cDirDoc + "\" + cFilePath
			If ACB->(FieldPos("ACB_BINID")) > 0 .and. !Empty( ACB->ACB_BINID )
				If oFb == NIL
					oFb := MPFilesBinary():New()
				EndIf
				lFileInDB := oFb:ReadFB( ACB->ACB_BINID, cDirDoc + "\", cFilePath, .F. )
				lProcessFile :=  (lFileInDB .And. File( cFullFilePath ))
			Else
				lProcessFile := File( cFullFilePath )
			EndIf
			If lProcessFile
				oFileReader := FWFileReader():New(cFullFilePath)
				If oFileReader:Open()
					nSize := oFileReader:GetFileSize()
					If nSize > 0
						cArq := oFileReader:FullRead()
						SplitPath( cFullFilePath, '', '', @cFileName, @cExtension )
						oItem[ "name" ]  := AllTrim( cFileName )
						oItem[ "type" ]  := cExtension
						oItem[ "file" ]  := Encode64( cArq )

						Aadd( oResponse[ "itemsAttachments" ], oItem )
						nResponse := 200
					EndIf
					oFileReader:Close()
				EndIf
			EndIf

		EndIf

	Else
		cMessage := I18N( STR0015, { Self:objectCode })
	EndIf

	If !Empty(cArq)
		cJson := FWJsonSerialize( oResponse, .F., .F., .T. )
		::SetResponse( cJson )
		lRet := .T.
	Else
		SetRestFault( nResponse, EncodeUTF8( STR0023 ), .T., nResponse, EncodeUTF8( STR0024 ) )
	EndIf

	If nResponse == 400
		SetRestFault( 400, EncodeUTF8( cMessage ), .T., 400, EncodeUTF8( cMessage ) )
	EndIf

	FwFreeObj(oFileReader)
	FwFreeObj(oFb)
	FwFreeObj(oItem)
	FwFreeObj(oResponse)
	lRet := ( nResponse == 200 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} listttachments
    Método para retornar a lista de anexos

@author Jose Renato
@since 08/12/2023

@param documentId, caracter, identificação do registro

@return lRet, lógico, se retornou a lista de anexos
/*/
//-------------------------------------------------------------------
WSMETHOD GET listAttachments PATHPARAM documentId WSSERVICE backofficeApprovals
	Local oResponse     := JsonObject():New()
	Local oFb           := NIL
	Local oItem         := Nil
	Local cJson         := ""
	Local lRet          := .F.
	Local lFileInDB     := .F.
	Local cDirDoc       := Alltrim(MsDocPath())
	Local nResponse     := 400
	Local cFilePath     := ""
	Local cMessage      := ""
	Local nRecId        := 0
	Local cEntity       := ""
	Local cFileName     := ""
	Local cExtension    := ""
	Local cFilCpo       := ""
	Local cFilEnt       := ""
	Local cSearchKey    := ""
	Local nTamCodEnt    := 0
	Local cFullFilePath := ""
	Local nSize         := 0
	Local nSavSize      := 0
	Local oFileReader   := NIL
	Local cX2Unico      := ""
	Local lProcessFile  := .F.
	Local lIsSC         := .F.
	Local nTamCN9Att    := 0
	Local cContraAtt     := ""
	Local cFilCN9Att     := ""

	oResponse[ "itemsAttachments" ] := {}
	oResponse[ "hasNext" ] := .F.
	nRecId := Val( Self:documentId )

	SCR->( DbGoTo( nRecId ) )

	If ( SCR->( !Eof( ) ) )
		cEntity := RetTypeEnt( )
		cMessage := STR0021

		If ( cEntity )->( Found( ) )
			cFilCpo := PrefixoCpo( cEntity )+'_FILIAL'
			cFilEnt := ( cEntity )->(&( cFilCpo ))
			nTamCodEnt := GetSx3Cache("AC9_CODENT", "X3_TAMANHO")

			lIsSC := (cEntity == "SC1")

			Do CASE
			Case cEntity == "CN9"
				cSearchKey := FwXFilial( "AC9" ) + cEntity + cFilEnt + ;
					PADR( CN9->CN9_NUMERO, nTamCodEnt )

			Case cEntity == "CNA"
				nTamCN9Att := TamSX3("CN9_NUMERO")[1]
				cContraAtt := Left( AllTrim(SCR->CR_NUM), nTamCN9Att )
				cFilCN9Att := GetAdvFVal("CN9", "CN9_FILIAL", ;
					xFilial("CN9") + PadR(cContraAtt, nTamCN9Att) + ;
					Space(GetSx3Cache("CN9_REVISA","X3_TAMANHO")), 1)
				cSearchKey := FwXFilial( "AC9" ) + "CN9" + cFilCN9Att + ;
					PADR( cContraAtt, nTamCodEnt )

			Case SCR->CR_TIPO == "SA"
				nResponse := Iif( AddAttByType( oResponse, "SA", cFilEnt, nTamCodEnt, cDirDoc, oFb, Nil ), 200, nResponse )
				cSearchKey := ""

			Case lIsSC
				nResponse := Iif( AddAttByType( oResponse, "SC", cFilEnt, nTamCodEnt, cDirDoc, oFb, cEntity ), 200, nResponse )
				cSearchKey := ""

			Case SCR->CR_TIPO == "IP"
				nResponse := Iif( AddAttByType( oResponse, "IP", cFilEnt, nTamCodEnt, cDirDoc, oFb, Nil ), 200, nResponse )
				cSearchKey := ""

			Case SCR->CR_TIPO $ "PV|DV"
				cSearchKey := FwXFilial( "AC9" ) + "SC5" + cFilEnt + ;
					PADR( AllTrim( SC5->C5_NUM ), nTamCodEnt )

			Otherwise
				If SCR->CR_TIPO == "PC"
					cX2Unico := "C7_FILIAL+C7_NUM"
					nTamCodEnt := FwSizeFilial() + GetSx3Cache( "C7_NUM", "X3_TAMANHO" )
				Else
					cX2Unico := FWX2Unico( cEntity )
				EndIf
				cSearchKey := FwXFilial( "AC9" ) + cEntity + cFilEnt + PADR(( cEntity )->(&( cX2Unico )), nTamCodEnt)
			EndCase

			If !Empty(cSearchKey) .AND. !lIsSC
				AC9->( DbSetOrder( 2 ) )
				If AC9->(DbSeek( cSearchKey ))
					While AC9->(!EOF()) .AND. ( AC9->( AC9_FILIAL + AC9_ENTIDA + AC9_FILENT + LEFT( AC9_CODENT, nTamCodEnt ) )  == cSearchKey )
						oItem := JsonObject():New()
						lProcessFile := .F.
						ACB->( DbSetOrder( 1 ) )
						If ACB->( DbSeek( FwXFilial( "ACB" ) + AC9->AC9_CODOBJ ) )
							cFilePath := Lower( ACB->ACB_OBJETO )
							If !Empty( cFilePath )
								cFullFilePath := cDirDoc + "\" + cFilePath
								If ACB->(FieldPos("ACB_BINID")) > 0 .and. !Empty( ACB->ACB_BINID )
									If oFb == NIL
										oFb := MPFilesBinary():New()
									EndIf
									lFileInDB := oFb:ReadFB( ACB->ACB_BINID, cDirDoc + "\", cFilePath, .F. )
									lProcessFile := (lFileInDB .And. File( cFullFilePath ))
								Else
									lProcessFile :=  File( cFullFilePath )
								EndIf
								If lProcessFile
									oFileReader := FWFileReader():New(cFullFilePath)
									If oFileReader:Open()
										nSize := oFileReader:GetFileSize()
										nSavSize := Round((nSize/1024)/1024, 2)
										oFileReader:Close()
										SplitPath( cFilePath, '', '', @cFileName, @cExtension )
										oItem[ "name" ]     := AllTrim( cFileName )
										oItem[ "code" ]     := AllTrim( AC9->AC9_CODOBJ )
										oItem[ "type" ]     := AllTrim( cExtension )
										oItem[ "size" ]     := nSavSize
										oItem[ "sizeType" ] := "MB"
										Aadd( oResponse[ "itemsAttachments" ], oItem )
										nResponse := 200
									EndIf
								EndIf
							EndIf
						EndIf
						AC9->( dbSkip( ) )
					EndDo
				Else
					If nResponse != 200
						cMessage := I18N( STR0015, { cSearchKey })
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		cMessage := I18N( STR0015, { ::documentId } )
	EndIf

	cJson := FWJsonSerialize( oResponse, .F., .F., .T. )
	::SetResponse( cJson )

	If nResponse == 400
		SetRestFault( 400, EncodeUTF8( cMessage ), .T., 400, EncodeUTF8( cMessage ) )
	EndIf

	FwFreeObj(oFileReader)
	FwFreeObj(oFb)
	FwFreeObj(oItem)
	FwFreeObj(oResponse)
	lRet := ( nResponse == 200 )

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AddAttByType
    Função unificada para buscar e adicionar anexos de diferentes tipos de documentos.
    
    Tipos suportados:
    - "SA" (Solicitação de Armazenagem): usa DBM+SCP, chave NUM+ITEM[+LOCAL]
    - "IP" (Item de Pedido): usa DBM+SC7, chave única da tabela
    - "SC" (Solicitação de Compra): usa SC1 diretamente, chave única da entidade
    
    SA e IP percorrem DBM filtrado por SCR, depois varrem o alias correspondente.
    SC busca diretamente na SC1 pelo número posicionado, sem usar DBM.

    @param oResponse  , objeto   , JsonObject por referência contendo "itemsAttachments"
    @param cTipo      , caractere, tipo: "SA", "IP" ou "SC"
    @param cFilEnt    , caractere, filial da entidade para chave AC9
    @param nTamCodEnt , numérico , tamanho do CODENT para PADR
    @param cDirDoc    , caractere, diretório base de documentos
    @param oFb        , objeto   , MPFilesBinary por referência
    @param cEntity    , caractere, obrigatório para "SC", alias da entidade
    @return lFoundAny , lógico   , .T. se encontrou anexos
    @since 09/02/2026
    @author Deijaí Miranda Almeida
/*/
//-------------------------------------------------------------------------------------
Static Function AddAttByType( oResponse, cTipo, cFilEnt, nTamCodEnt, cDirDoc, oFb, cEntity )
	Local lFoundAny   := .F.
	Local cSearchKey  := ""
	Local cNum        := ""
	Local cItem       := ""
	Local cNumPad     := ""
	Local cItemPad    := ""
	Local cAlias      := ""
	Local cX2Unico    := ""
	Local nOrderAlias := 1
	Local cNumField   := ""
	Local cItemField  := ""
	Local cLocalConcat:= ""
	Local lUseDBM     := .T.

	Do Case
	Case cTipo == "SA"
		cAlias      := "SCP"
		cNumField   := "CP_NUM"
		cItemField  := "CP_ITEM"
		cLocalConcat:= IIF( SCP->(FieldPos("CP_LOCAL")) > 0, "+CP_LOCAL", "" )

	Case cTipo == "IP"
		cAlias      := "SC7"
		cNumField   := "C7_NUM"
		cItemField  := "C7_ITEM"
		cX2Unico    := FWX2Unico("SC7")

	Case cTipo == "SC"
		cAlias      := "SC1"
		cNumField   := "C1_NUM"
		cItemField  := "C1_ITEM"
		lUseDBM     := .F.
		cX2Unico    := FWX2Unico( cEntity )
	EndCase

	If !lUseDBM
		cNumPad := PadR( AllTrim(SC1->C1_NUM), GetSx3Cache(cNumField, "X3_TAMANHO") )
		(cAlias)->( DbSetOrder( nOrderAlias ) )
		If (cAlias)->( DbSeek( xFilial(cAlias) + cNumPad ) )
			While (cAlias)->(!EOF()) .And. (cAlias)->&(SubStr(cNumField,1,2)+"_FILIAL") == xFilial(cAlias) .And. (cAlias)->&(cNumField) == cNumPad
				cItem      := (cAlias)->&(cItemField)
				cSearchKey := FwXFilial("AC9") + cEntity + cFilEnt + PadR( (cAlias)->(&(cX2Unico)), nTamCodEnt )
				If AddAttKey( @oResponse, cSearchKey, nTamCodEnt, cDirDoc, @oFb, cItem )
					lFoundAny := .T.
				EndIf
				(cAlias)->( DbSkip() )
			EndDo
		EndIf
		Return lFoundAny
	EndIf

	If DBM->( DbSeek( SCR->( CR_FILIAL + CR_TIPO + CR_NUM + CR_GRUPO + CR_ITGRP ) ) )
		(cAlias)->( DbSetOrder( nOrderAlias ) )
		While !DBM->( Eof() ) .And. DBM->DBM_FILIAL == SCR->CR_FILIAL .And. DBM->DBM_TIPO == SCR->CR_TIPO .And. DBM->DBM_NUM == SCR->CR_NUM .And. DBM->DBM_GRUPO == SCR->CR_GRUPO .And. DBM->DBM_ITGRP == SCR->CR_ITGRP
			cNum     := AllTrim( cValToChar( DBM->DBM_NUM ) )
			cItem    := AllTrim( cValToChar( DBM->DBM_ITEM ) )
			cNumPad  := PadR( cNum,  GetSx3Cache(cNumField,  "X3_TAMANHO") )
			cItemPad := PadR( cItem, GetSx3Cache(cItemField, "X3_TAMANHO") )

			If (cAlias)->( DbSeek( xFilial(cAlias) + cNumPad + cItemPad ) )
				While !(cAlias)->( Eof() ) .And. (cAlias)->&(SubStr(cNumField,1,2)+"_FILIAL") == xFilial(cAlias) .And. (cAlias)->&(cNumField) == cNumPad .And. (cAlias)->&(cItemField) == cItemPad
					If cTipo == "SA"
						cSearchKey := FwXFilial("AC9") + cAlias + cFilEnt + PadR( (cAlias)->(&( cNumField + "+" + cItemField + cLocalConcat )), nTamCodEnt )
					Else
						cSearchKey := FwXFilial("AC9") + cAlias + cFilEnt + PadR( (cAlias)->(&(cX2Unico)), nTamCodEnt )
					EndIf

					If AddAttKey( @oResponse, cSearchKey, nTamCodEnt, cDirDoc, @oFb, (cAlias)->&(cItemField) )
						lFoundAny := .T.
					EndIf
					(cAlias)->( DbSkip() )
				EndDo
			EndIf
			DBM->( DbSkip() )
		EndDo
	EndIf

Return lFoundAny

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AddAttKey
    Varre os registros de anexos no AC9 para uma determinada chave de busca (SearchKey) e,
    para cada anexo encontrado, resolve o arquivo via ACB (e binário, quando aplicável),
    montando e adicionando itens no array "itemsAttachments" do JSON de resposta.

    Pode receber opcionalmente o item da SC (C1_ITEM) para incluir no JSON como campo "item",
    permitindo que o consumidor identifique a qual item o anexo pertence.

    @param oResponse  , objeto  , JsonObject por referência contendo "itemsAttachments"
    @param cSearchKey , caractere, chave de busca completa (AC9_FILIAL+ENTIDA+FILENT+CODENT PADR)
    @param nTamCodEnt , numérico , tamanho do CODENT (controle de LEFT e comparação)
    @param cDirDoc    , caractere, diretório base de documentos (MsDocPath)
    @param oFb        , objeto  , MPFilesBinary por referência (pode vir NIL e será instanciado)
    @param cItemOpt   , caractere, opcional, item da SC para enriquecer JSON (default "")
    @return lFoundAny , lógico  , .T. se adicionou pelo menos 1 anexo, caso contrário .F.
    @since 29/01/2026
    @author Deijaí Miranda Almeida
/*/
//-------------------------------------------------------------------------------------
Static Function AddAttKey( oResponse, cSearchKey, nTamCodEnt, cDirDoc, oFb, cItemOpt )
	Local lFoundAny   := .F.
	Local cFileName   := ""
	Local cExtension  := ""
	Local nSavSize    := 0
	Local oItem       := NIL
	Default cItemOpt := ""

	AC9->( DbSetOrder( 2 ) )
	If AC9->( DbSeek( cSearchKey ) )
		While AC9->(!EOF()) .AND. ( AC9->( AC9_FILIAL + AC9_ENTIDA + AC9_FILENT + LEFT( AC9_CODENT, nTamCodEnt ) ) == cSearchKey )
			cFileName  := ""
			cExtension := ""
			nSavSize   := 0

			If BuildAttIt( cDirDoc, @oFb, AC9->AC9_CODOBJ, @nSavSize, @cFileName, @cExtension )
				cExtension := Iif( Left(AllTrim(cExtension),1) == ".", SubStr(AllTrim(cExtension),2), AllTrim(cExtension) )
				oItem := JsonObject():New()
				oItem[ "name" ]     := AllTrim( cFileName )
				oItem[ "code" ]     := AllTrim( AC9->AC9_CODOBJ )
				oItem[ "type" ]     := cExtension
				oItem[ "size" ]     := nSavSize
				oItem[ "sizeType" ] := "MB"

				If !Empty(cItemOpt)
					oItem[ "item" ] := AllTrim(cItemOpt)
				EndIf

				AAdd( oResponse[ "itemsAttachments" ], oItem )
				lFoundAny := .T.
			EndIf
			AC9->( DbSkip() )
		EndDo
	EndIf
Return lFoundAny

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BuildAttIt
    Resolve e valida um anexo a partir do código do objeto (AC9_CODOBJ), consultando a ACB
    e garantindo a existência do arquivo físico, seja ele armazenado diretamente no disco
    ou materializado a partir de binário (ACB_BINID).

    Quando o arquivo é válido, retorna nome, extensão e tamanho (MB) por referência.

    @param cDirDoc    , caractere, diretório base de documentos (MsDocPath)
    @param oFb        , objeto   , MPFilesBinary (por referência, pode vir NIL)
    @param cCodObj    , caractere, código do objeto (AC9_CODOBJ)
    @param nSavSize   , numérico , por referência, tamanho do arquivo em MB
    @param cFileName  , caractere, por referência, nome do arquivo (sem extensão)
    @param cExtension , caractere, por referência, extensão do arquivo
    @return lOk       , lógico   , .T. se o arquivo foi resolvido com sucesso
    @since 29/01/2026
    @author Deijaí Miranda Almeida
/*/
//-------------------------------------------------------------------------------------
Static Function BuildAttIt( cDirDoc, oFb, cCodObj, nSavSize, cFileName, cExtension )

	Local lOk          := .F.
	Local cFilePath    := ""
	Local cFullPath    := ""
	Local lFileInDB    := .F.
	Local lProcessFile := .F.
	Local oReader      := NIL
	Local nSize        := 0
	Local cSeekKey     := ""

	Default cDirDoc    := ""
	Default cCodObj    := ""
	Default nSavSize   := 0
	Default cFileName  := ""
	Default cExtension := ""

	cDirDoc := AllTrim( cValToChar( cDirDoc ) )
	cCodObj := AllTrim( cValToChar( cCodObj ) )

	If !Empty(cDirDoc) .AND. !( Right(cDirDoc,1) $ "\/" )
		cDirDoc += "\"
	EndIf

	cSeekKey := FwXFilial("ACB") + cCodObj
	ACB->( DbSetOrder( 1 ) )
	If ACB->( DbSeek( cSeekKey ) )
		cFilePath := Lower( AllTrim( cValToChar( ACB->ACB_OBJETO ) ) )
		cFullPath := cDirDoc + cFilePath
		If ACB->( FieldPos("ACB_BINID") ) > 0 .AND. !Empty( ACB->ACB_BINID )
			If oFb == NIL
				oFb := MPFilesBinary():New()
			EndIf
			lFileInDB := oFb:ReadFB( ACB->ACB_BINID, cDirDoc, cFilePath, .F. )
			lProcessFile := ( lFileInDB .AND. File( cFullPath ) )
		Else
			lProcessFile := File( cFullPath )
		EndIf
		If lProcessFile
			oReader := FWFileReader():New( cFullPath )
			If oReader:Open()
				nSize := oReader:GetFileSize()
				nSavSize := Round( ( nSize / 1024 ) / 1024, 2 )
				oReader:Close()
				SplitPath( cFilePath, "", "", @cFileName, @cExtension )
				lOk := .T.
			EndIf
		EndIf
	EndIf
	FwFreeObj( oReader )
Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} RetTypeEnt
    Retorna a entidade baseado no tipo de alçada presente na tabela SCR
@author Jose Renato
@since 29/12/2023

@return cEntity, caractere, entidade a ser utilizada na chave de busca da tabela AC9
/*/
//-------------------------------------------------------------------
Static Function RetTypeEnt()
	Local cEntity := ""
	Local nTamCN9Ent := 0
	Local cContraEnt := ""
	Local cRevisaEnt := ""

	Do Case
	Case SCR->CR_TIPO $ "PC|IP|AE"
		cEntity := "SC7"
		SC7->( DbSetOrder( 1 ) )
		If SCR->CR_TIPO == "IP"
			DBM->( DbSetOrder( 1 ) )
			DBM->( DbSeek( SCR->( CR_FILIAL + CR_TIPO + CR_NUM + CR_GRUPO + CR_ITGRP ) ) )
			SC7->( DbSeek( xFilial("SC7") + ;
				PadR( AllTrim(DBM->DBM_NUM), GetSx3Cache("C7_NUM", "X3_TAMANHO") ) + ;
				PadR( AllTrim(DBM->DBM_ITEM), GetSx3Cache("C7_ITEM", "X3_TAMANHO") ) ) )
		Else
			SC7->( DbSeek( xFilial( "SC7" ) + AllTrim( SCR->CR_NUM ) ) )
		EndIf

	Case SCR->CR_TIPO == "SC"
		cEntity := "SC1"
		DBM->( DbSetOrder( 1 ) )
		SC1->( DbSetOrder( 1 ) )
		DBM->( DbSeek( SCR->( CR_FILIAL + CR_TIPO + CR_NUM + CR_GRUPO + CR_ITGRP ) ) )
		SC1->( DbSeek( xFilial("SC1") + ;
			PadR( AllTrim(DBM->DBM_NUM), GetSx3Cache("C1_NUM", "X3_TAMANHO") ) + ;
			PadR( AllTrim(DBM->DBM_ITEM), GetSx3Cache("C1_ITEM", "X3_TAMANHO") ) ) )

	Case SCR->CR_TIPO $ "PV|DV"
		cEntity := "SC5"
		SC5->( DbSetOrder( 1 ) )
		SC5->( DbSeek( xFilial("SC5") + ;
			PadR( AllTrim(SCR->CR_NUM), GetSx3Cache("C5_NUM", "X3_TAMANHO") ) ) )

	Case SCR->CR_TIPO $ "IM|MD"
		cEntity := "CND"
		CND->( DbSetOrder( 4 ) )
		CND->( DbSeek( xFilial( "CND" ) + Left( SCR->CR_NUM, GetSx3Cache("CND_NUMMED","X3_TAMANHO") ) ) )

	Case SCR->CR_TIPO == "CT"
		cEntity := "CN9"
		CN9->( DbSetOrder( 1 ) )
		CN9->( DbSeek( xFilial( "CN9" ) + SCR->CR_NUM ) )

	Case SCR->CR_TIPO == "IC"
		nTamCN9Ent := TamSX3("CN9_NUMERO")[1]
		cContraEnt := Left( AllTrim(SCR->CR_NUM), nTamCN9Ent )
		cRevisaEnt := Posicione("CN9", 1, xFilial("CN9") + PadR(cContraEnt, nTamCN9Ent) + ;
			Space(GetSx3Cache("CN9_REVISA","X3_TAMANHO")), "CN9_REVISA")
		cEntity := "CNA"
		CNA->( DbSetOrder( 1 ) )
		CNA->( DbSeek( xFilial("CNA") + PadR(cContraEnt, nTamCN9Ent) + cRevisaEnt ) )

	Case SCR->CR_TIPO == "SA"
		cEntity := "SCP"
		DBM->( DbSetOrder( 1 ) )
		SCP->( DbSetOrder( 1 ) )
		DBM->( DbSeek( SCR->( CR_FILIAL + CR_TIPO + CR_NUM + CR_GRUPO + CR_ITGRP ) ) )
		SCP->( DbSeek( xFilial("SCP") + ;
			PadR( AllTrim(DBM->DBM_NUM), GetSx3Cache("CP_NUM", "X3_TAMANHO") ) + ;
			PadR( AllTrim(DBM->DBM_ITEM), GetSx3Cache("CP_ITEM", "X3_TAMANHO") ) ) )

	EndCase

Return cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} getHistByDoc
    Método para retornar o histórico de aprovação de determinado documento

@param documentId, caracter , identificação do registro(recNo do documento(SCR))

@return lRet, lógico, se retornou o histórico de aprovação
@author Jose Renato
@since 20/12/2023
/*/
//-------------------------------------------------------------------
WSMETHOD GET getHistByDoc PATHPARAM documentId WSSERVICE backofficeApprovals
	Local nRecId    := 0
	Local oResponse := Nil
	Local oItem     := Nil
	Local nResponse := 400
	Local cKey      := ""
	Local cMessage  := ""
	Local cStatus   := ""
	Local nIndex    := ""
	Local aStatus   := {}

	nRecId  := Val( Self:documentId )

	If nRecId > 0
		SCR->( DbGoTo( nRecId ) )

		If ( SCR->( !Eof( ) ) )

			cKey:= SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM
			SCR->( DbSetOrder( 1 ) )
			SCR->( DbSeek( cKey ))
			aStatus:= RetSx3Box( Posicione( "SX3", 2, "CR_STATUS", "X3CBox()" ),,, GetSx3Cache( "CR_STATUS", "X3_TAMANHO" ) )
			oResponse   := JsonObject():New()
			oResponse[ "approvalHistory" ] := {}

			While SCR->( !EOF( ) ) .And. SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM == cKey

				nIndex  := aScan( aStatus,{ |x| x[2] == SCR->CR_STATUS } )

				If nIndex > 0
					cStatus := AllTrim( aStatus[nIndex,3] )
				EndIf
				oItem       := JsonObject():New()

				oItem[ "documentNumber" ]       := FwHttpEncode( Alltrim( SCR->CR_NUM ) )
				oItem[ "approvalDate" ]         := DTOS( SCR->CR_DATALIB )
				oItem[ "level" ]                := FwHttpEncode( SCR->CR_NIVEL )
				oItem[ "approvalName" ]         := Upper( UsrRetName( SCR->CR_USER ) )
				oItem[ "status" ]               := FwHttpEncode( cStatus )
				oItem[ "responsibleApprover" ]  := Upper( UsrRetName( SCR->CR_USERLIB ) )
				oItem[ "justification" ]        := FwHttpEncode( Alltrim( SCR->CR_OBS  ) )
				oItem[ "documentType" ]         := FwHttpEncode( Alltrim( SCR->CR_TIPO ) )

				If !Empty( SCR->CR_ITGRP )
					oItem[ "documentItemGroup"  ]   := FwHttpEncode( Alltrim( SCR->CR_ITGRP ) )
					oItem[ "recno" ]                :=  SCR->( Recno( ) )
				EndIf

				Aadd( oResponse[ "approvalHistory" ], oItem )

				nResponse:= 200

				SCR->( dbSkip( ))
			EndDo
		Else
			cMessage:= I18N( STR0015, { nRecId })
		EndIf
	Else
		cMessage:= I18N( STR0015, { nRecId })
	EndIf

	cJson   := FWJsonSerialize( oResponse, .F., .F., .T. )
	::SetResponse( cJson )

	If nResponse == 400
		SetRestFault( 400, FwHttpEncode( cMessage ), .T., 400, FwHttpEncode( cMessage )  )
	EndIf

	lRet:= ( nResponse == 200 )

	FreeObj( oItem )
	FreeObj( oResponse )
	FwFreeArray( aStatus )

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetSymbol
    Função para retornar o simbolo da moeda de acordo com o tipo na SCR
    @type  Static Function
    @author Victor Vieira
    @since 04/07/2024
    @param nCurrency, numerico, Tipo da Moeda SCR
    @return cSymbol, Caracter, Retorna o simbulo da moeda
/*/
//-------------------------------------------------------------------------------------
Static Function GetSymbol(nCurrency)

	Local cSymbol As Character
	Default nCurrency := 1

	nCurrency := Iif(nCurrency == 0, 1, nCurrency)

	cSymbol := EncodeUTF8(AllTrim(SuperGetMv('MV_SIMB' + cValToChar(nCurrency), .F., '1')))

Return cSymbol

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTotalCount
    Função para retornar o total de documentos pendentes de aprovação de acordo com o tipo na SCR (PC, IP, SC, MD e IM)
    @type  Static Function
    @author Deijaí Miranda Almeida
    @since 26/08/2024
    @param nCurrency, numerico, Tipo da Moeda SCR
    @return lRet, Lógico, Retorna verdadeiro ou falso
/*/
//-------------------------------------------------------------------------------------
Static Function GetTotalCount( oResponse, oSelf)
	Local oStatement   := FWPreparedStatement():New()
	Local cQuery       := ""
	Local lRet         := .T.
	Local cTmp         := ""
	Local nTotal       := 0

	dbSelectArea( "SAK" )
	dbSetOrder( 2 )
	If MsSeek( xFilial( "SAK" ) + __cUserId )
		cTmp := GetNextAlias()

		cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName( "SCR" ) + " SCR "
		cQuery += " WHERE SCR.CR_FILIAL = ?"
		cQuery += " AND SCR.CR_TIPO = ?"
		cQuery += " AND SCR.CR_STATUS = ?"
		cQuery += " AND SCR.CR_USER = ?"
		cQuery += " AND SCR.D_E_L_E_T_ = ?"

		oStatement:SetQuery(cQuery)
		oStatement:SetString(1, FWxFilial('SCR'))
		oStatement:SetString(2, oSelf:typeApproval)
		oStatement:SetString(3, oSelf:documentStatus)
		oStatement:SetString(4, SAK->AK_USER)
		oStatement:SetString(5, ' ')

		cQuery := oStatement:GetFixQuery()

		If !Empty( cQuery )
			cQuery := ChangeQuery(cQuery)
			cTmp := MPSysOpenQuery(cQuery)

			dbSelectArea( cTmp )
			If ( cTmp )->( !Eof() ) .AND. ( cTmp )->TOTAL > 0
				oResponse[ "total" ] := {}
				oResponse[ "total" ] := ( cTmp )->TOTAL
			Else
				SetRestFault(400, EncodeUTF8( STR0015 ), .T., 400, EncodeUTF8( STR0016 ) )
				lRet := .F.
			EndIf
		EndIf
		(cTmp)->(DbCloseArea())

	ElseIf oSelf:typeApproval == "AC"
		nTotal := GetPrstTot()

		oResponse[ "total" ] := {}
		oResponse[ "total" ] := nTotal
	Else
		SetRestFault(400, EncodeUTF8( STR0011 ), .T., 400, EncodeUTF8( STR0012 ) )
		lRet := .F.
	EndIf

	oStatement := NIL
	FreeObj( oStatement )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} userSummary
    Método para retornar um resumo com as informações do dashboard do usuário logado, incluindo saldo disponível, moeda associada e grupos de aprovação do usuário. Esse endpoint é utilizado para exibir um painel com dados relevantes do perfil do usuário no sistema de aprovação de documentos.
/*  
    @author Deijai Miranda Almeida
    @since 08/11/2024
    @return lRet, lógico, se a mensagem foi recebida com sucesso 
/*/
//-------------------------------------------------------------------------------------
WSMETHOD GET userSummary WSSERVICE backofficeApprovals
	Local oResponse := JsonObject():New()
	Local cJson := ""
	Local lRet := .F.
	Local cUserID := RetCodUSR()

	oResponse["userId"]           := cUserID
	oResponse["availableBalance"] := GetBalance(cUserID)
	oResponse["currency"]         := GetUsrCur(cUserID)
	oResponse["approvalGroups"]   := GetGrpApv(cUserID)

	cJson := FWJsonSerialize(oResponse, .F., .F., .T.)

	::SetResponse(cJson)
	lRet := .T.
	FreeObj(oResponse)
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} sourceInfo
    Método para retornar informações de qualquer fonte compilado no RPO. Este método verifica o objeto ADVPL informado no parâmetro `sourceName`, retornando nome do fonte, linguagem, modo de compilação, data e hora da última modificação. Serve como base de comparação para controle de versão entre o ERP e o aplicativo.
@param sourceName, caractere, nome do fonte com extensão (.prw, .tlpp, etc.)
@since 01/06/2025
@see GetApoInfo
@return JSON, objeto contendo as informações do fonte ou mensagem de erro caso não encontrado
@author Deijaí Miranda Almeida
/*/
//-------------------------------------------------------------------------------------
WSMETHOD GET sourceInfo WSRECEIVE sourceName WSSERVICE backofficeApprovals
	Local oResponse := JsonObject():New()
	Local cFonte    := AllTrim(Self:sourceName)
	Local aDados    := {}
	Local cJson     := ""
	Local lRet      := .F.

	If Empty(cFonte)
		SetRestFault(400, EncodeUTF8( STR0029 ), .T., 400, EncodeUTF8( STR0029 ) )
		lRet := .F.
	Else
		aDados := GetApoInfo(cFonte)

		If Len(aDados) > 0
			oResponse["source"]   := aDados[1]
			oResponse["language"] := aDados[2]
			oResponse["compiler"] := aDados[3]
			oResponse["date"]     := DToS(aDados[4])
			oResponse["time"]     := aDados[5]
			lRet := .T.
		Else
			SetRestFault(400, EncodeUTF8( STR0028 ), .T., 400, EncodeUTF8( STR0028 ) )
			lRet := .F.
		EndIf
	EndIf

	cJson := FWJsonSerialize(oResponse, .F., .F., .T.)
	::SetResponse(cJson)
	FreeObj(oResponse)
	FwFreeArray(aDados)
Return lRet

//-------------------------------------------------------------------
/* {Protheus.doc} getMeasurementGroup
Método para retornar todos os fornecedores e clientes vinculados a uma medição
Consulta apenas: CXN (Planilhas da Medição)

@author Deijaí Miranda Almeida
@since 08/12/2025
@param documentId, numérico, RecNo do documento SCR
@return lRet, lógico, se retornou os dados
/*/
//-------------------------------------------------------------------
WSMETHOD GET getMeasurementGroup PATHPARAM documentId WSSERVICE backofficeApprovals
	Local oResponse As Object
	Local aMedGrp   As Array
	Local cJson     As Character
	Local lRet      As Logical
	Local nRecId    As Numeric
	Local nResponse As Numeric
	Local cMessage  As Character

	oResponse := JsonObject():New()
	aMedGrp   := {}
	cJson     := ""
	lRet      := .F.
	nRecId    := 0
	nResponse := 400
	cMessage  := ""

	nRecId := Val(Self:documentId)

	If nRecId > 0
		SCR->(DbGoTo(nRecId))

		If SCR->(!Eof()) .And. SCR->CR_TIPO $ "MD|IM"
			aMedGrp := GetMedGrp(nRecId)
			If Len(aMedGrp) > 0
				oResponse["groups"]  := aMedGrp
				oResponse["hasNext"] := .F.
				nResponse := 200
			EndIf
		Else
			cMessage := I18N(STR0015, {nRecId})
		EndIf
	EndIf
	cJson := FWJsonSerialize(oResponse, .F., .F., .T.)
	::SetResponse(cJson)
	If nResponse == 400
		SetRestFault(400, EncodeUTF8(cMessage), .T., 400, EncodeUTF8(cMessage))
	EndIf
	lRet := (nResponse == 200)
	FreeObj(oResponse)
	FwFreeArray(aMedGrp)
Return lRet

//-------------------------------------------------------------------
/* {Protheus.doc} GetMedGrp
Busca fornecedores e clientes vinculados às planilhas da medição
Consulta apenas: CXN (Planilhas da Medição)

@param nRecSCR - RecNo da tabela SCR (documento de aprovação)
@return aResult - Array de objetos JSON com fornecedores/clientes únicos
@author Deijaí Miranda Almeida
@since 08/12/2025
*/
//-------------------------------------------------------------------
Static Function GetMedGrp(nRecSCR)
	Local oQuery      As Object
	Local cQuery      As Character
	Local cAlias      As Character
	Local aResult     As Array
	Local aKeys       As Array
	Local cKey        As Character
	Local oMedGrp     As Object
	Local cNumMed     As Character
	Local cFilMed     As Character
	Local cFilCXN     As Character
	Local cFilSA1     As Character
	Local cFilSA2     As Character
	Local nTamNumMed  As Numeric

	oQuery     := Nil
	cQuery     := ""
	cAlias     := ""
	aResult    := {}
	aKeys      := {}
	cKey       := ""
	oMedGrp    := Nil
	cNumMed    := ""
	cFilMed    := ""
	cFilCXN    := ""
	cFilSA1    := ""
	cFilSA2    := ""
	nTamNumMed := 0

	Default nRecSCR := 0

	SCR->(DbGoTo(nRecSCR))

	cNumMed := AllTrim(SCR->CR_NUM)
	cFilMed := SCR->CR_FILIAL

	cFilCXN := xFilial('CXN', cFilMed)
	cFilSA1 := xFilial('SA1', cFilMed)
	cFilSA2 := xFilial('SA2', cFilMed)

	nTamNumMed := TamSX3("CXN_NUMMED")[1]

	cQuery := " SELECT DISTINCT "
	cQuery += "     CXN.CXN_FORNEC AS FORNEC, "
	cQuery += "     CXN.CXN_LJFORN AS LJFORN, "
	cQuery += "     SA2.A2_NREDUZ AS NOME_FORNECEDOR, "
	cQuery += "     CXN.CXN_CLIENT AS CLIENT, "
	cQuery += "     CXN.CXN_LJCLI AS LOJACL, "
	cQuery += "     SA1.A1_NREDUZ AS NOME_CLIENTE "
	cQuery += " FROM " + RetSqlName("CXN") + " CXN "
	cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery += "     ON SA2.A2_FILIAL = ? "
	cQuery += "     AND SA2.A2_COD = CXN.CXN_FORNEC "
	cQuery += "     AND SA2.A2_LOJA = CXN.CXN_LJFORN "
	cQuery += "     AND SA2.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "     ON SA1.A1_FILIAL = ? "
	cQuery += "     AND SA1.A1_COD = CXN.CXN_CLIENT "
	cQuery += "     AND SA1.A1_LOJA = CXN.CXN_LJCLI "
	cQuery += "     AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE CXN.CXN_FILIAL = ? "
	cQuery += "     AND CXN.CXN_NUMMED = ? "
	cQuery += "     AND CXN.CXN_CHECK = ? "
	cQuery += "     AND CXN.D_E_L_E_T_ = ' ' "

	oQuery := FWExecStatement():New(ChangeQuery(cQuery))
	oQuery:SetString(1, cFilSA2)
	oQuery:SetString(2, cFilSA1)
	oQuery:SetString(3, cFilCXN)
	oQuery:SetString(4, PadR(cNumMed, nTamNumMed))
	oQuery:SetString(5, "T")

	cAlias := oQuery:OpenAlias()

	While !(cAlias)->(EoF())
		If !Empty((cAlias)->FORNEC) .And. !Empty(AllTrim((cAlias)->NOME_FORNECEDOR))
			cKey := "F" + AllTrim((cAlias)->FORNEC) + AllTrim((cAlias)->LJFORN)
			If aScan(aKeys, cKey) == 0
				AAdd(aKeys, cKey)
				oMedGrp := JsonObject():New()
				oMedGrp["type"]  := "F"
				oMedGrp["code"]  := EncodeUTF8(AllTrim((cAlias)->FORNEC))
				oMedGrp["store"] := EncodeUTF8(AllTrim((cAlias)->LJFORN))
				oMedGrp["name"]  := EncodeUTF8(AllTrim((cAlias)->NOME_FORNECEDOR))
				aAdd(aResult, oMedGrp)
			EndIf
		EndIf

		If !Empty((cAlias)->CLIENT) .And. !Empty(AllTrim((cAlias)->NOME_CLIENTE))
			cKey := "C" + AllTrim((cAlias)->CLIENT) + AllTrim((cAlias)->LOJACL)
			If aScan(aKeys, cKey) == 0
				AAdd(aKeys, cKey)
				oMedGrp := JsonObject():New()
				oMedGrp["type"]  := "C"
				oMedGrp["code"]  := EncodeUTF8(AllTrim((cAlias)->CLIENT))
				oMedGrp["store"] := EncodeUTF8(AllTrim((cAlias)->LOJACL))
				oMedGrp["name"]  := EncodeUTF8(AllTrim((cAlias)->NOME_CLIENTE))
				aAdd(aResult, oMedGrp)
			EndIf
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	(cAlias)->(DbCloseArea())
	oQuery:Destroy()
	FreeObj(oQuery)
	oQuery := NIL
	FreeObj(oMedGrp)
	oMedGrp := NIL
	FwFreeArray(aKeys)
Return aResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBalance
    Método para retornar o saldo disponível do usuário logado. Este método calcula e retorna o saldo financeiro disponível para o usuário, considerando limites e restrições aplicáveis, facilitando o controle de aprovações com base no saldo.
/*  
    @param cUserID, código do usuário
    @since 08/11/2024  
    @author Deijaí Miranda Almeida
    @return aSaldoDisp, array, contendo objetos JSON com código, saldo disponível, símbolo da moeda, limite e tipo de cada item relacionado ao saldo
/*/
//-------------------------------------------------------------------------------------
Static Function GetBalance(cUserID)
	Local oItem      := Nil
	Local aSaldoDisp := {}
	Local aAprov     := {}
	Local cQuery     := ''
	Local oQrySAK    := Nil
	Local cAliasSAK  := GetNextAlias()
	Default cUserID  := ""

	oQrySAK := FWPreparedStatement():New()

	cQuery := " SELECT AK_COD, AK_MOEDA, AK_LIMITE, AK_TIPO "
	cQuery += " FROM "+ RetSqlName("SAK")
	cQuery += " WHERE AK_FILIAL = ? "
	cQuery += " AND AK_USER = ? "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	oQrySAK:SetQuery(cQuery)
	oQrySAK:SetString(1,FWXFILIAL("SAK"))
	oQrySAK:SetString(2,cUserID)

	cQuery := oQrySAK:GetFixQuery()
	MpSysOpenQuery(cQuery,cAliasSAK)

	While (!(cAliasSAK)->(Eof()))
		oItem := JsonObject():New()
		aSaldoDisp :=  MaSalAlc((cAliasSAK)->AK_COD, dDataBase,.T.)

		oItem["code"]               := (cAliasSAK)->AK_COD
		oItem["availableBalance"]   := aSaldoDisp[1]
		oItem["currencySymbol"]     := GetSymbol((cAliasSAK)->AK_MOEDA)
		oItem["limit"]              := (cAliasSAK)->AK_LIMITE
		oItem["type"]               := (cAliasSAK)->AK_TIPO
		oItem["currentApprovAmount"]:= GetApvAmt((cAliasSAK)->AK_COD, (cAliasSAK)->AK_TIPO)
		AAdd(aAprov, oItem)
		(cAliasSAK)->(DBSkip())
	Enddo
	(cAliasSAK)->(dbCloseArea())
	FreeObj( oItem )
	FreeObj( oQrySAK )
	FwFreeArray( aSaldoDisp )
Return aAprov

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetUsrCur
    Método para retornar a moeda associada ao usuário logado. Este método busca a moeda padrão atribuída ao usuário no sistema, facilitando a exibição de valores financeiros no formato correto.
/*  
    @param cUserID, código do usuário
    @since 08/11/2024
    @author Deijaí Miranda Almeida
    @return cMoeda, string, símbolo da moeda associada ao usuário
/*/
//-------------------------------------------------------------------------------------
Static Function GetUsrCur(cUserID)
	Local cMoeda := "R$"

	DbSelectArea("SCS")
	If DbSeek(xFilial("SCS") + __cUserId)
		cMoeda := Alltrim(GetSymbol(SCS->CS_MOEDA))
	EndIf

Return cMoeda

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetGrpApv
    Método para retornar os grupos de aprovação associados ao usuário logado. Este método consulta e retorna uma lista de grupos de aprovação aos quais o usuário pertence, incluindo código e descrição de cada grupo.
/*  
    @param cUserID, código do usuário aprovador
    @since 08/11/2024
    @author Deijaí Miranda Almeida
    @return aGrpAprv, array, lista contendo objetos JSON com código e descrição de cada grupo de aprovação
/*/
//---------------------------------------------------------------------------------------
Static Function GetGrpApv(cUserID)
	Local oItem     := Nil
	Local aGrupos   := {}
	Local cQuery    := ''
	Local oQrySAL   := Nil
	Local cAliasSAL := GetNextAlias()
	Default cUserID := ""

	oQrySAL := FWPreparedStatement():New()

	cQuery := " SELECT AL_FILIAL, AL_COD, AL_DESC, AL_APROV "
	cQuery += " FROM "+ RetSqlName("SAL")
	cQuery += " WHERE AL_FILIAL = ? "
	cQuery += " AND AL_USER = ? "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	oQrySAL:SetQuery(cQuery)
	oQrySAL:SetString(1,FWXFILIAL("SAL"))
	oQrySAL:SetString(2,cUserID)

	cQuery := oQrySAL:GetFixQuery()
	MpSysOpenQuery(cQuery,cAliasSAL)

	While (!(cAliasSAL)->(Eof()))
		oItem := JsonObject():New()
		oItem["code"]        := (cAliasSAL)->AL_COD
		oItem["description"] := (cAliasSAL)->AL_DESC
		AAdd(aGrupos, oItem)
		(cAliasSAL)->(DBSkip())
	Enddo
	(cAliasSAL)->(dbCloseArea())
	FreeObj( oItem )
	FreeObj( oQrySAL )
Return aGrupos

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetApvAmt
    Método para retornar o valor total aprovado pelo usuário no mês corrente. Este valor representa a soma dos valores de documentos aprovados pelo aprovador logado no período do mês atual, facilitando o acompanhamento dos valores mensais aprovados.
/*  
    @param cApprov, código do aprovador, cType tipo
    @since 08/11/2024
    @author Deijaí Miranda Almeida
    @return nVlApr, numérico, total aprovado no dia, sema ou dia corrente
/*/
//-------------------------------------------------------------------------------------
Static Function GetApvAmt(cApprov, cType)
	Local nVlAprov  := 0
	Local dDtIni    := FirstDate(dDatabase)
	Local dDtFin    := LastDate(dDatabase)
	Local cQuery    := ''
	Local oQrySCR   := Nil
	Local cAliasSCR := GetNextAlias()

	Default cApprov := ''
	Default cType   := ''

	IF cType == 'D'
		dDtIni := dDatabase
		dDtFin := dDatabase
	ElseIf cType == 'S'
		dDtIni := DaySub(dDatabase, 7)
		dDtFin := dDatabase
	EndIf

	oQrySCR := FWPreparedStatement():New()

	cQuery := " SELECT SUM(CR_TOTAL) AS SLD "
	cQuery += " FROM "+ RetSqlName("SCR")
	cQuery += " WHERE CR_APROV = ? "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " AND CR_STATUS = ? "
	cQuery += " AND CR_DATALIB BETWEEN ? AND ? "
	cQuery := ChangeQuery(cQuery)

	oQrySCR:SetQuery(cQuery)
	oQrySCR:SetString(1,cApprov)
	oQrySCR:SetString(2, '03')
	oQrySCR:SetString(3, DtoS(dDtIni))
	oQrySCR:SetString(4, DtoS(dDtFin))

	cQuery := oQrySCR:GetFixQuery()
	MpSysOpenQuery(cQuery,cAliasSCR)

	If !(cAliasSCR)->(Eof())
		nVlAprov := (cAliasSCR)->SLD
	EndIf

	(cAliasSCR)->(dbCloseArea())
	FreeObj( oQrySCR )
Return nVlAprov

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPrstTot
    Carrega a quantitade total pendente de contas na tela principal
    @author ali.neto
    @since 19/08/2025
/*/
//-------------------------------------------------------------------
Static Function GetPrstTot()

	Local aUser        As Array
	Local cBranchFLF   As Character
	Local cBranchSA1   As Character
	Local cBranchCTT   As Character
	Local cBranchFO7   As Character
	Local cApprovers   As Character
	Local cInApprovers As Character

	Local oQuery    := Nil
	Local cQuery    := ""
	Local cAliasTmp := ""
	Local nTot      := 0
	Local aApprovers:= {}

	If MATXUser(__cUserID,@aUser)

		cQuery     := ""
		cAliasTmp  := GetNextAlias()
		cBranchFLF := xFilial( "FLF" )
		cBranchSA1 := xFilial( "SA1" )
		cBranchCTT := xFilial( "CTT" )
		cBranchFO7 := xFilial( "FO7" )

		cApprovers   := GetApprov( aUser[1] )
		cInApprovers := FormatIn( cApprovers, "," )
		aApprovers   := StrTokArr(cApprovers,",")

		oQuery := FWPreparedStatement():New()

		cQuery += "SELECT COUNT(*) AS TotReg "
		cQuery += "FROM " +RetSQLName("FLF")+ " FLF "
		cQuery += "INNER JOIN " + RetSqlName("FLN") + " FLN "
		cQuery += "ON FLN.FLN_FILIAL = FLF.FLF_FILIAL "
		cQuery += "AND FLN.FLN_TIPO = FLF.FLF_TIPO "
		cQuery += "AND FLN.FLN_PRESTA = FLF.FLF_PRESTA "
		cQuery += "AND FLN.FLN_PARTIC = FLF.FLF_PARTIC "
		cQuery += "AND FLN.FLN_STATUS = '1' "
		cQuery += "AND FLN.FLN_TPAPR = '1' "
		cQuery += "AND FLN.FLN_APROV IN ( ? ) "
		cQuery += "AND FLN.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN " +RetSQLName("FL5")+ " FL5 "
		cQuery += "ON FL5.FL5_FILIAL = FLF.FLF_FILIAL "
		cQuery += "AND FL5.FL5_VIAGEM = FLF.FLF_VIAGEM "
		cQuery += "LEFT JOIN " + RetSQLName("FO7") + " FO7 "
		cQuery += "ON FO7.FO7_FILIAL = ? "
		cQuery += "AND FO7.FO7_TPVIAG = FLF.FLF_TIPO "
		cQuery += "AND FO7.FO7_PRESTA = FLF.FLF_PRESTA "
		cQuery += "AND FO7.FO7_PARTIC = FLF.FLF_PARTIC "
		cQuery += "AND FO7.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN " +RetSQLName("SA1")+ " SA1 "
		cQuery += "ON SA1.A1_FILIAL = ? "
		cQuery += "AND SA1.A1_COD <> ? "
		cQuery += "AND SA1.A1_COD = FLF.FLF_CLIENT "
		cQuery += "AND SA1.A1_LOJA = FLF.FLF_LOJA "
		cQuery += "LEFT JOIN " +RetSQLName("CTT")+ " CTT "
		cQuery += "ON CTT.CTT_FILIAL = ? "
		cQuery += "AND CTT.CTT_CUSTO = FLF.FLF_CC "
		cQuery += "AND CTT.D_E_L_E_T_  = ' ' "
		cQuery += "WHERE FLF.FLF_FILIAL = ? "
		cQuery += "AND FLF.FLF_STATUS = '4' "
		cQuery += "AND FLF.D_E_L_E_T_ = ' ' "

		oQuery:SetQuery(cQuery)
		oQuery:SetIn(1, aApprovers)
		oQuery:SetString(2, cBranchFO7)
		oQuery:SetString(3, cBranchSA1)
		oQuery:SetString(4, Space(TamSx3("A1_COD")[1]))
		oQuery:SetString(5, cBranchCTT)
		oQuery:SetString(6, cBranchFLF)

		cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery(), cAliasTmp)

		If !(cAliasTmp)->(EoF())
			nTot := (cAliasTmp)->TotReg
		EndIf
		(cAliasTmp)->(dbCloseArea())
	EndIf

	FWFreeArray(aUser)
	FWFreeArray(aApprovers)
	FreeObj(oQuery)
Return nTot

//-------------------------------------------------------------------
/*/{Protheus.doc} GetApprov
Carrega os códigos de participante que possuem o usuário logado como 
aprovador ou substituto

@param cApprover, caracter, código do participante

@return caracter, participantes que utilizam o usuário logado como 
aprovador ou substituto.

@author Totvs
@since 19/08/2025
/*/
//-------------------------------------------------------------------
Static Function GetApprov( cApprover )

	Local cApprovers := ""
	Local cQuery     := ""
	Local oQuery     := Nil
	Local cAliasTmp  := GetNextAlias()

	Default cApprover := ''

	oQuery := FWPreparedStatement():New()

	cQuery := "SELECT RD0_APROPC " + ;
		"FROM " + RetSqlName( "RD0" ) + " RD0 " + ;
		"WHERE RD0.RD0_FILIAL = ? " + ;
		"AND RD0.RD0_APSUBS = ? " + ;
		"AND RD0.D_E_L_E_T_ = ' ' "

	oQuery:SetQuery(cQuery)
	oQuery:SetString(1, xFilial( "RD0" ))
	oQuery:SetString(2, cApprover)

	cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery(), cAliasTmp)

	cApprovers := cApprover

	While ( cAliasTmp )->( !EoF() )
		cApprovers += ',' + ( cAliasTmp )->RD0_APROPC
		( cAliasTmp )->( DbSkip() )
	End

	(cAliasTmp)->( DbCloseArea() )

	FreeObj(oQuery)
Return cApprovers

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MATXUser
Função genérica para obter matricula e nome do usuário no cadastro
de recursos (RD0)

@param cUserId		Código do usuário logado no sistema
@param aUser		Array que conterá: [1] Matricula   [2] Nome do recurso.
@param lHelp		Apresenta Help ou não
@return lRet		Retorna se existe cadastro de participante para o usuário
@author Totvs
@since 19/08/2025
@version 
/*/
//-------------------------------------------------------------------------------
Function MATXUser(cUserId,aUser)

	Local oQuery     := Nil
	Local cQuery     := ""
	Local lRet       := .F.
	Local lRD0_VIAJA := RD0->(FieldPos("RD0_FVIAJ")) > 0
	Local cAliasTmp  := GetNextAlias()

	Default aUser   := {}
	Default cUserId := ""

	oQuery := FWPreparedStatement():New()

	cQuery   := " SELECT "
	cQuery   += " RD0_CODIGO, RD0_NOME, RD0_MSBLQL, RD0_DTADEM "
	cQuery   += " FROM " + RetSqlName("RD0")
	cQuery   += " WHERE "
	cQuery   += " RD0_FILIAL = ? AND "
	cQuery   += " RD0_USER = ? AND "
	cQuery   += " RD0_MSBLQL <> '1' AND "
	If lRD0_VIAJA
		cQuery   += " RD0_FVIAJ IN ('1', '') AND "
	EndIf
	cQuery   += " D_E_L_E_T_ = ' ' "

	oQuery:SetQuery(cQuery)
	oQuery:SetString(1, xFilial("RD0"))
	oQuery:SetString(2, cUserId)

	cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery(), cAliasTmp)

	If (cAliasTmp)->(!EOF())
		If Empty((cAliasTmp)->RD0_DTADEM)
			aUser := {(cAliasTmp)->RD0_CODIGO,(cAliasTmp)->RD0_NOME}
			lRet := .T.
		Endif
	EndIf

	(cAliasTmp)->(dbCloseArea())
	FreeObj(oQuery)
Return lRet
