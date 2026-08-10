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
	Local lUseCache     := .T.  // Determina se deve usar o cache

	Default lId         := .F.

	// Decidir se deve usar cache com base nos filtros
	If !Empty(oSelf:initDate) .OR. !Empty(oSelf:endDate) .OR. !Empty(oSelf:searchKey)
		lUseCache := .F.  // Não usar cache para consultas com filtros
	EndIf

	If Empty( cDocType )
		cDocType := "All"
	EndIf

	cName := Alltrim( 'GET_' + cDocType + IIF( lId, "_ById", "" ) ) + '_' + cEmpAnt

	// Se estamos usando filtros, adicionar hash único para evitar colisões de cache
	If !lUseCache
		cName += "_" + DtoS(Date()) + "_" + StrTran(Time(), ":", "") + "_" + Str(Randomize(1, 1000), 4, 0)
	EndIf

	If lUseCache .AND. !HMGet( __oAprHshQry, cName, @cTreatQuery )
		cTreatQuery := CreateQueryModel( cDocType, oSelf, lId )

		If !Empty( cTreatQuery )
			HMSet( __oAprHshQry, cName, cTreatQuery )
		EndIf
	ElseIf !lUseCache  // Se não estiver usando cache, sempre gerar nova query
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
	Local cJoin         :=  ""
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

	Default lId         := .F.

	cIniDate    := oSelf:initDate
	cEndDate    := oSelf:endDate
	cSearchKey  := oSelf:searchKey
	nOrderType  := oSelf:orderBy

	cRetBy      := RetBy( nOrderType ) //Pode receber a ordenação por  1 = mais recentes, 2 = mais antigos

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

		// Adicionar filtro de busca para caso "All"
		If lFindFilter
			cWhere += " AND CR_NUM LIKE '%" + cSearchKey + "%' "
		EndIf

	Case cDocType $ "PC|AE" // Pedido de Compra e Autorizacao de Entrega
		cOrderBy    := "C7_NUM" + cRetBy

		cFields += "A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, C7_FILIAL, C7_EMISSAO"

		cJoin += " INNER JOIN " + RetSqlName( "SC7" ) + " SC7 ON " + FWJoinFilial( "SC7", "SCR" ) + " AND CR_NUM = C7_NUM AND SC7.D_E_L_E_T_ = ' '" // Pedido de Compra
		cJoin += " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON " + FWJoinFilial( "SA2", "SC7" ) + " AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' " // Fornecedores
		cJoin += " INNER JOIN " + RetSqlName( "SE4" ) + " SE4 ON " + FWJoinFilial( "SE4", "SC7" ) + " AND E4_CODIGO = C7_COND AND SE4.D_E_L_E_T_ = ' ' " // Condição de pagamento
		cJoin += " LEFT JOIN "  + RetSqlName( "SY1" ) + " SY1 ON " + FWJoinFilial( "SY1", "SC7" ) + " AND C7_USER = Y1_USER AND SY1.D_E_L_E_T_ = ' ' " // Compradores

		If lFindFilter
			cWhere +=   " AND (A2_NOME LIKE '%" + cSearchKey + "%' OR A2_NREDUZ LIKE '%" + cSearchKey + "%' OR A2_COD LIKE '%" + cSearchKey + "%' OR C7_NUM LIKE '%" + cSearchKey + "%' ) "
		EndIf

		cGroupBy:= " GROUP BY A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, C7_FILIAL, C7_EMISSAO, CR_ITGRP, CR_GRUPO, CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_ "

	Case cDocType == "IP" // Itens de Pedido
		cOrderBy    := "C7_NUM" + cRetBy

		cFields += "A2_NREDUZ, C7_NUM, E4_DESCRI, Y1_NOME, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, C7_FILIAL, C7_EMISSAO, CTT_DESC01 "

		cJoin += " INNER JOIN " + RetSqlName( "SC7" ) + " SC7 ON " + FWJoinFilial( "SC7", "SCR" ) + " AND CR_NUM = C7_NUM AND SC7.D_E_L_E_T_ = ' '" // Pedido de Compra
		cJoin += " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON " + FWJoinFilial( "SA2", "SC7" ) + " AND C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' " // Fornecedores
		cJoin += " INNER JOIN " + RetSqlName( "SE4" ) + " SE4 ON " + FWJoinFilial( "SE4", "SC7" ) + " AND E4_CODIGO = C7_COND AND SE4.D_E_L_E_T_ = ' ' " // Condição de pagamento
		cJoin += " LEFT JOIN "  + RetSqlName( "CTT" ) + " CTT ON " + FWJoinFilial( "CTT", "SC7" ) + " AND C7_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' " // Centro de Custo
		cJoin += " LEFT JOIN "  + RetSqlName( "SY1" ) + " SY1 ON " + FWJoinFilial( "SY1", "SC7" ) + " AND C7_USER = Y1_USER AND SY1.D_E_L_E_T_ = ' ' " // Compradores


		cJoin += " LEFT JOIN " + RetSqlName( "DBM" ) + " DBM ON " + FWJoinFilial( "DBM", "SCR" ) + " AND DBM_NUM = CR_NUM  AND DBM_GRUPO = CR_GRUPO AND DBM_ITGRP = CR_ITGRP AND DBM.D_E_L_E_T_ = ' ' " // Itens de doc com alçada

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

		cFields   += " C1_SOLICIT, C1_EMISSAO, C1_FILIAL, SUM(CR_TOTAL) / COUNT(*) AS TOTAL,

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

	Case cDocType $ "MD|IM" //Medição
		cOrderBy    := "CND_CONTRA" + cRetBy

		cFields  += "CND_CONTRA, CND_COMPET, CND.R_E_C_N_O_ AS REGGEN"
		nNumLen  := GetSx3Cache("CND_NUMMED","X3_TAMANHO")

		cJoin +=  " INNER JOIN " + RetSqlName( "CND" ) + " CND ON " + FWJoinFilial( "CND", "SCR" ) + " "  // Medição
		cJoin +=  " AND CND_NUMMED = SUBSTRING(CR_NUM, 1,"+Alltrim( STR( nNumLen ))+")

		If lFindFilter
			cJoin +=   " AND ( CND.CND_NUMMED LIKE '%" + cSearchKey + "%' OR "
			cJoin +=   "CND.CND_CONTRA LIKE '%" + cSearchKey + "%' ) "
		EndIf

		cJoin +=  " AND CND.D_E_L_E_T_ = ' ' "

		cJoin +=  " INNER JOIN " + RetSqlName( "CNA" ) + " CNA ON " + FWJoinFilial( "CNA", "CND" ) + " "  // Planilha Contrato
		cJoin +=  " AND CNA.CNA_CONTRA = CND.CND_CONTRA "
		cJoin +=  " AND CNA.D_E_L_E_T_ = ' ' "

		cGroupBy := " GROUP BY CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_GRUPO, CR_ITGRP, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_, CND_CONTRA, CND_COMPET, CND.R_E_C_N_O_ "

	Case cDocType == "CT" // Contratos
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

	Case cDocType == "SA" // Solicitação Armazem
		cOrderBy  := "CP_NUM" + cRetBy

		cFields += "CP_SOLICIT, CP_EMISSAO, CP_FILIAL, SUM(CR_TOTAL) / COUNT(*) AS TOTAL, CP_CC, CTT_DESC01"
		cJoin     += " INNER JOIN " + RetSqlName( "SCP" ) + " SCP ON " + FWJoinFilial( "SCP", "SCR" ) + "  AND CP_NUM = CR_NUM AND SCP.D_E_L_E_T_ = ' ' " // Solicitação Armazem
		cJoin     += " LEFT JOIN "  + RetSqlName( "CTT" ) + " CTT ON " + FWJoinFilial( "CTT", "SCP" ) + "  AND CTT_CUSTO = CP_CC  AND CTT.D_E_L_E_T_ = ' ' " // Centro de Custo
		cJoin     += " INNER JOIN " + RetSqlName( "DBM" ) + " DBM ON " + FWJoinFilial( "DBM", "SCR" ) + "  AND DBM_NUM = CR_NUM  AND DBM_ITEM = CP_ITEM AND DBM_GRUPO = CR_GRUPO AND DBM_ITGRP = CR_ITGRP AND DBM.D_E_L_E_T_ = ' ' " // Itens de doc com alçada

		If  lFindFilter
			cJoin += " AND (CP_SOLICIT LIKE '%" + cSearchKey + "%' OR CP_NUM LIKE '%" + cSearchKey + "%' ) "
		EndIf

		cGroupBy:= "Group By CR_ITGRP, CR_GRUPO, CR_FILIAL, CR_NUM, CR_TOTAL, CR_TXMOEDA, CR_TIPO, CR_STATUS, CR_MOEDA, CR_EMISSAO, SCR.R_E_C_N_O_, CP_SOLICIT, CP_CC, CP_FILIAL, CP_NUM, CP_EMISSAO, CTT_DESC01"

	EndCase

	cQuery:=    " SELECT <<PAGE_CONTROL>>," + cFields + " " + ;
		" FROM " + RetSqlName( "SCR" ) + " SCR " + ;
		cJoin + ;
		" WHERE CR_FILIAL IN (?) " + ;
		" AND CR_TIPO IN (?) " + ;
		" AND CR_STATUS IN (?) " + ;
		" AND CR_USER = ? " + ;
		cWhere + ;
		cWhereId + ;
		" AND SCR.D_E_L_E_T_ = '' "  + cGroupBy

	If !Empty( cQuery )
		cQuery := QueryPageControl( cQuery, cOrderBy,cDocType, lId )
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


			cPageControl := cFields + "FROM ( SELECT ROW_NUMBER() OVER ( ORDER BY " + cOrderBy + " ) AS LINE "
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

	nRecStart := ( ( oSelf:page - 1 ) * oSelf:pageSize ) + 1
	nRecFinish := ( nRecStart + oSelf:pageSize ) - 1

	cBranches := RetApprovalBranch( oSelf )
	aBranches:= StrTokArr( cBranches, "," )

	Do Case

	Case Empty( cDocType ) .Or. cDocType == "All" // Todos os tipos de alçada

		For nX:= 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ))
		Next


		oQuery:SetIn( 1, aBranSCR )
		oQuery:setIn( 2, { "SC", "MD", "IM", "PC", "IP", "AE","CT","SA" })
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		oQuery:SetNumeric( 5, nRecStart )
		oQuery:SetNumeric( 6, nRecFinish )

	Case cDocType $ "PC|IP|AE" // Pedido de Compra, Item Pedido, Autorização de Entrega

		For nX:= 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ))
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:setIn( 2, { cDocType })
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )

		If nId > 0
			oQuery:SetNumeric( 5, nId)
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf


	Case cDocType == "SC" // Solicitação de compra

		For nX:= 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ))
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:setIn( 2, { "SC" })
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId)
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType $ "MD|IM" // Medição ou item da medição

		For nX:= 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ))
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:setIn( 2, { cDocType })
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId )
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:setNumeric( 6, nRecFinish )

		EndIf

	Case cDocType == "CT" // Contratos

		For nX:= 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ))
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:setIn( 2, { "CT" })
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId)
		Else
			oQuery:SetNumeric( 5, nRecStart )
			oQuery:SetNumeric( 6, nRecFinish )
		EndIf

	Case cDocType == "SA" // Solicitação de compra

		For nX:= 1 to Len( aBranches )
			aAdd( aBranSCR, xFilial( "SCR", aBranches[nX] ))
		Next

		oQuery:SetIn( 1, aBranSCR )
		oQuery:setIn( 2, { "SA" })
		oQuery:SetString( 3, oSelf:documentStatus )
		oQuery:SetString( 4, oSelf:approverCode )
		If nId > 0
			oQuery:SetNumeric( 5, nId)
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
	Local cDocRet   := ""

	Do Case
	Case cDoc == "SC"
		cDocRet := "purchaseRequest"
	Case cDoc $ "PC|IP|AE"
		cDocRet := "purchaseOrder"
	Case cDoc $ "MD|IM"
		cDocRet := "measurements"
	Case cDoc == "CT"
		cDocRet := "contracts"
	Case cDoc == "SA"
		cDocRet := "warehouseRequest"
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
	Local aDoc          := {}
	Local jDoc
	Local cAlias        := ""
	Local cTable        := ""
	Local cDocType      := ""
	Local nRegGen       := 0
	Local cCodCTT       := ""
	Local cDescCTT      := ""
	Local nLenCnd       := 0
	Local nLenCna       := 0

	Local oQuery

	cDocType := oSelf:documentType

	If Empty(cDocType)

		cAlias:= GetNextAlias()

		nRegGen:= IIF( cDocType $ "MD|IM", ( cTmp )->REGGEN, ( cTmp )->REGSCR )

		oQuery := GetQueryApprovals( ( cTmp )->CR_TIPO, oSelf, nRegGen > 0 )
		SetQueryValues( @oQuery, ( cTmp )->CR_TIPO, oSelf, nRegGen )
		MPSysOpenQuery( ChangeQuery(oQuery:getFixQuery()) , cAlias )

	EndIf

	cTable:= IIF(Empty( cDocType ), cAlias, cTmp )

	Do Case
	Case cType == "contracts"

		jDoc := JsonObject():New()
		jDoc[ "contractNumber" ]            := EncodeUTF8( Alltrim(( cTable )->CNA_CONTRA )) // Contrato
		jDoc[ "date" ]                      := EncodeUTF8( Alltrim(( cTable )->CNA_DTINI )) // Competência
		jDoc[ "initialTerm" ]               := EncodeUTF8( Alltrim(( cTable )->CNA_DTINI )) // Inicio Vigência
		jDoc[ "finalTerm" ]                 := EncodeUTF8( Alltrim(( cTable )->CNA_DTFIM )) // Fim Vigência
		jDoc[ "recno" ]                     := ( cTable )->REGGEN // Recno

	Case cType == "measurements"

		DbSelectArea("CNA")
		CNA->(DbSetOrder(1))
		nLenCnd  := GetSx3Cache("CND_NUMMED","X3_TAMANHO")
		nLenCna  := GetSx3Cache("CNA_NUMERO","X3_TAMANHO")
		CNA->(Msseek(fwxFilial('CNA') + Alltrim(( cTable )->CND_CONTRA )))
		jDoc := JsonObject():New()

		while CNA->(!Eof()) .AND. Alltrim(CNA->CNA_CONTRA) == Alltrim(( cTable )->CND_CONTRA )
			if CNA->CNA_NUMERO == Alltrim( SUBSTR(( cTable )->CR_NUM, nLenCnd + 1, nLenCna))
				If(!Empty(CNA->CNA_CLIENT))
					jDoc[ "customerName" ]          := EncodeUTF8( Alltrim( GetAdvFval("SA1","A1_NREDUZ", fwxFilial("SA1") + CNA->CNA_CLIENT + CNA->CNA_LOJACL,1) ))
					Exit
				Else
					jDoc[ "supplyerName" ]          := EncodeUTF8( Alltrim( GetAdvFval("SA2","A2_NREDUZ", fwxFilial("SA2") + CNA->CNA_FORNEC + CNA->CNA_LJFORN,1) ))
					Exit
				EndIf
			endif
			CNA->(dbSkip())
		end

		jDoc[ "contractNumber" ]            := EncodeUTF8( Alltrim(( cTable )->CND_CONTRA )) // Contrato
		jDoc[ "competence" ]                := EncodeUTF8( Alltrim(( cTable )->CND_COMPET )) // Competência
		jDoc[ "recno" ]                     := ( cTable )->REGGEN // Recno

	Case cType == "purchaseRequest"

		jDoc := JsonObject():New()
		jDoc[ "requesterName" ]             := EncodeUTF8( Alltrim(( cTable )->C1_SOLICIT )) // Solicitante
		jDoc[ "date" ]                      := ( cTable )->C1_EMISSAO // Emissao
		jDoc[ "CostCenter" ]                := EncodeUTF8( Alltrim(( cTable )->CTT_DESC01 )) // Centro de Custo

	Case cType == "purchaseOrder"

		jDoc := JsonObject():New()
		jDoc[ "supplyerName" ]              := EncodeUTF8( Alltrim(( cTable )->A2_NREDUZ )) // Nome do fornecedor
		jDoc[ "paymentTermDescription" ]    := EncodeUTF8( Alltrim(( cTable )->E4_DESCRI )) // Descrição da condição de pagamento
		jDoc[ "purchaserName" ]             := EncodeUTF8( Alltrim(( cTable )->Y1_NOME )) // Nome do comprador
		jDoc[ "date" ]                      := (cTable)->C7_EMISSAO // Emissao

		if ( cTmp )->CR_TIPO == "IP"
			if jDoc[ "itemDescriptionCostCenter" ] == nil .or. empty(jDoc[ "itemDescriptionCostCenter" ])
				cCodCTT  := GetAdvFVal("DBL","DBL_CC",fwxFilial("DBL") + Alltrim(( cTmp )->CR_GRUPO + ( cTmp )->CR_ITGRP),1)
				cDescCTT := GetAdvFVal("CTT","CTT_DESC01",fwxFilial("CTT") + cCodCTT ,1)
				jDoc[ "itemDescriptionCostCenter" ] := EncodeUTF8(Alltrim(cDescCTT))
			endif
		endif

	Case cType == "warehouseRequest"

		jDoc := JsonObject():New()
		jDoc[ "requesterName" ]             := EncodeUTF8( Alltrim(( cTable )->CP_SOLICIT )) // Solicitante
		jDoc[ "date" ]                      := ( cTable )->CP_EMISSAO // Emissao
		jDoc[ "CostCenter" ]                := EncodeUTF8( Alltrim(( cTable )->CTT_DESC01 )) // Centro de Custo

	End Case

	aAdd( aDoc, jDoc )
	FreeObj(jDoc)
Return aDoc

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

		PswSeek( __cUserID, .T. ) // necessário posicionar para correta utilização da função PswRet

		aDataUsr := PswRet()[2][6]

		nBranchSAK := BIFilialLen( "SAK", cEmpAnt )
		nBrancSize := FwSizeFilial( cEmpAnt )

		cQuery:= "SELECT DISTINCT AK_FILIAL FROM " +RetSQLName("SAK")+ " "
		cQuery+= "WHERE AK_USER = ? "

		//Define a consulta e os parâmetros
		oStatement:SetQuery(cQuery)
		oStatement:SetString(1,__cUserId)

		//Recupera a consulta já com os parâmetros injetados
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

			//Para medição é preciso recarregar o modelo 1x por documento
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
		nCode := 207 //Parcialmente atendida
	ElseIf lHasSuccess
		nCode := 200 //Atendida
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
//-------------------------------------------------------------------------------------
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

	SCR->(DbSetOrder(2))//CR_FILIAL+CR_TIPO+CR_NUM+CR_USER

	cSeek := xFilial("SCR") + ::cType

	SCR->(DbSeek(cSeek)) //Posiciona em um documento do tipo selecionado, pois essa informação é utilizada no modelDef

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
				cDetails := I18N(STR0003, ;//"Problema: #1 | Solução : #2"
				{::oModel094:GetErrorMessage()[6], ::oModel094:GetErrorMessage()[7]})
			EndIf

			If ::oModel094:IsActive()
				::oModel094:DeActivate()
			EndIf

			If ::lCleanModel
				FreeObj(::oModel094)
			EndIf
		Else
			cDetails := I18N(STR0004,{ AllTrim(jDocument['documentId']) })//"Documento #1 não encontrado."
		EndIf

		::addToResponse(lSuccess, cDetails)

	next nX


	cFilAnt := cFilBkp // Restaura filial

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
	Local cJustif       := STR0009 // Justificativa não informada
	Local jDocument     := ::jCurrentDoc

	If !(Empty(jDocument['justification']))
		cJustif := jDocument['justification']
	EndIf

	cOperation := IIF(jDocument['toApprove'], '001', '005')
	A094SetOp(cOperation) //-- Seta operacao de aprovacao de documentos

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
		cFailMsg    := STR0005//"Aprovação do documento #1 falhou."
		cSuccessMsg := STR0006//"Documento #1 aprovado."
	Else
		cFailMsg    := STR0007//"Rejeição do documento #1 falhou."
		cSuccessMsg := STR0008//"Documento #1 reprovado."
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
WSMETHOD GET getItemsByDoc  PATHPARAM typeApprovals, documentId WSRECEIVE page, pageSize, itemGroup WSSERVICE backofficeApprovals
	Local nTypeIndex:= 0
	Local nCode     := 400
	Local nRecId    := 0
	Local jResponse := Nil
	Local cOper     := ""
	Local cResponse := ""
	Local cVldTypes := ""
	Local aTypes := {   {'purchaserequest'      ,'purchaseRequestItems'     ,'SC'},;
		{'warehouserequest'     ,'warehouseRequestItems'    ,'SA'},;
		{'purchaseorder'        ,'purchaseOrderItems'       ,'PC|IP|AE'},;
		{'contracts'            ,'contractsItems'           ,'CT'},;
		{'contractmeasurement'  ,'contractMeasurementItems' ,'MD|IM'};
		}

	Default Self:page           := 1
	Default Self:pageSize       := 10
	Default Self:itemGroup      := ""

	nTypeIndex := aScan(aTypes, {|x| x[1] == AllTrim(Self:typeApprovals)})
	If (nTypeIndex > 0)
		cOper       := aTypes[nTypeIndex,2]
		cVldTypes   := aTypes[nTypeIndex,3]
		nRecId      := Val(Self:documentId)

		SCR->(DbGoTo(nRecId))

		If (SCR->(!Eof()) .And. SCR->CR_TIPO $ cVldTypes)

			If (cOper == 'contractMeasurementItems')
				jResponse   := getMDItems(nRecId)

				If ValType(jResponse) == "J"
					nCode := 200
				EndIf
			Else
				nCode       := 200
				jResponse   := JsonObject():New()

				Self:itemGroup := PadR(Self:itemGroup, GetSx3Cache('CR_ITGRP','X3_TAMANHO'))

				MobJSONResult( cOper, Self, @jResponse )
			EndIf
		EndIf
	EndIf

	If (nCode > 299)
		jResponse := BadReqResponse()
	EndIf

	If (ValType( jResponse ) == "J")
		cResponse := jResponse:toJSON()
	EndIf

	Self:setStatus( nCode )
	Self:SetResponse( cResponse )

	FwFreeArray( aTypes )
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
			{ "CP_NUM"      , "requestNumber" }, ;
			{ 'CP_ITEM'     , 'requestItem' }, ;
			{ 'CP_PRODUTO'  , "itemProduct" }, ;
			{ 'CP_UM'       , "unitMeasurement" }, ;
			{ 'CP_QUANT'    , "quantity" }, ;
			{ 'CP_CC'       , "costCenter" }, ;
			{ 'B1_DESC'     , "itemSkuDescription" }, ;
			{ "CR_GRUPO"    , "groupAprov" }, ;
			{ "CR_ITGRP"    , "itemGroup" } ;
			}
	Case cOper == 'purchaseRequestItems'
		aProperties := { ;
			{ "C1_NUM"      , "requestNumber" }, ;
			{ 'C1_ITEM'     , 'requestItem' }, ;
			{ 'C1_PRODUTO'  , "itemProduct" }, ;
			{ 'C1_UM'       , "unitMeasurement" }, ;
			{ 'C1_QUANT'    , "quantity" }, ;
			{ 'C1_CC'       , "costCenter" }, ;
			{ 'C1_TOTAL'    , "itemTotal" }, ;
			{ 'C1_PRECO'    , "unitValue" }, ;
			{ 'C1_MOEDA'    , "currency" }, ;
			{ 'B1_DESC'     , "itemSkuDescription" }, ;
			{ "CR_GRUPO"    , "groupAprov" }, ;
			{ "CR_ITGRP"    , "itemGroup" } ;
			}
	Case cOper == "purchaseOrderItems"
		aProperties := { ;
			{ 'C7_NUM'      , "purchaseOrderNumber" }, ;
			{ 'C7_ITEM'     , 'purchaseOrderItem' }, ;
			{ 'C7_CC'       , "costCenter" }, ;
			{ 'C7_QUANT'    , "quantity"}, ;
			{ 'C7_TOTAL'    , "itemTotal"}, ;
			{ 'C7_PRECO'    , "unitValue"}, ;
			{ 'C7_PRODUTO'  , "itemSku"}, ;
			{ 'B1_DESC'     , "itemSkuDescription" }, ;
			{ 'C7_UM'       , "unitMeasurement" }, ;
			{ "CR_GRUPO"    , "groupAprov" }, ;
			{ "CR_ITGRP"    , "itemGroup" }, ;
			{ 'C7_MOEDA'    , "currency" } ;
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
	Local aQueryInfo    := {}
	Local aMainWhere    := {}
	Local aVariables    := {}
	Local cMainTable    := ''
	Local cFields       := ''
	Local cOrderBy      := ''
	Local cQuery        := ''
	Local cServiceName  := 'backofficeApprovals'
	Local nTesSize      := 0

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
		oService:SetItemsName("purchaseOrderItems") //nome do nó principal para os registros
		oStatement := oService:SetQuery( cQuery )
		oService:SetVariables( aVariables )

	Case cOper == "historyByItem"
		cMainTable := 'SD1'
		nTesSize := GetSx3Cache( "D1_TES", "X3_TAMANHO" )
		cOrderBy := 'D1_EMISSAO DESC '

		cQuery := "SELECT <<PAGE_CONTROL>>, D1_EMISSAO, A2_NOME, D1_QUANT, D1_VUNIT "
		cQuery +=   " FROM " + RetSqlName( "SD1" ) + " SD1 "
		cQuery +=   " INNER JOIN " + RetSqlName( "SA2" ) + " SA2 ON A2_FILIAL = ? AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA AND SA2.D_E_L_E_T_ = ' ' "
		cQuery +=   " WHERE D1_FILIAL = ? "
		cQuery +=     " AND D1_COD = ? "
		cQuery +=     " AND D1_TIPO NOT IN ('D', 'B') "
		cQuery +=     " AND D1_TES <> '" + Space( nTesSize ) + "' "
		cQuery +=     " AND SD1.D_E_L_E_T_ = ' ' "


		aAdd( aVariables, { 'C', 'A2_FILIAL = ?', XFilial( "SA2" ) } )
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

	jResponse['code']       := 400
	jResponse['origin']     := ""
	jResponse['message']    := EncodeUTF8("Bad Request")
	jResponse['detailedMessage']:= ""
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
	Local aArea     := SCR->(GetArea())
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
	Local cRecordNumber  := ""
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

	cRecordNumber   := Self:recordNumber
	cItem           := Self:itemNumber

	dbSelectArea( "SAK" )
	dbSetOrder( 2 ) //AK_FILIAL + AK_USER

	If MsSeek( xFilial( "SAK" ) + __cUserId )

		SCR->(DbGoTo(Self:itemRecno))
		cDoc := ReturnDocType(SCR->CR_TIPO )

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
			cExecBlock := "MPADDCPO"

		Case cDoc == "warehouseRequest"
			cObsField       := "CP_OBS"
			cMoreFields     := "CP_OBS"
			cTable          := "SCP"
			nIndexTable     := 1
			cExecBlock      := "MPADDCPO"

		Case cDoc == "measurements"
			cObsField       := "CND_OBS"
			cMoreFields     := "CND_OBS"
			cTable          := "CND"
			nIndexTable     := 4
			cExecBlock      := "MPADDCPO"

			If getMDItems(Self:itemRecno) <> nil
				lMeasurements   := .T.
			EndIf

		Case cDoc == "contracts"
			cObsField       := "CN9_REVISA"
			cMoreFields     := "CN9_REVISA"
			cTable          := "CN9"
			nIndexTable     := 1
			cExecBlock      := "MPADDCPO"
			lMeasurements   := .T.

		EndCase

		( cTable )->( DbSetOrder(nIndexTable) )

		If ( cTable )->( dbSeek( XFilial ( cTable ) + IIF(!lMeasurements, cRecordNumber  + cItem, cRecordNumber) ) )
			oService := MobileService():New( cServiceName, cExecBlock )
			oService:SetMainTable( cTable )

			cFields := oService:AddFieldsbyPE( )

			If !Empty( cFields )

				cFields := cMoreFields + cFields
				aTemp := StrToArray( cFields, ',')

				// verificação para não duplicar os campos caso algum campo contido em cMoreFields seja informado no PE
				For nX:= 1 to Len( aTemp )
					If aScan( aFields, aTemp[nX] ) == 0
						aAdd( aFields, aTemp[nX])
					EndIf
				Next

				oResponse[ "itemsAdditionalInformation" ] := {}
				oResponse[ "hasNext" ] := .F.

				For nRec := 1 To Len( aFields )
					cField  := aFields[ nRec ]

					nPos := ( cTable )->(FieldPos( cField ))
					If nPos > 0 //  só executa adição dos campos no retorno caso o campo exista
						cType   := FWSX3Util():GetFieldType( cField )

						oItem   := JsonObject():New()

						oItem[ "label" ]  := EncodeUTF8( FWX3Titulo( cField ) )
						oItem[ "type" ]   := cType

						If cType == "D"
							oItem[ "data" ]   := DToS( ( cTable )->( FieldGet( nPos ) ) )
						ElseIf cType == "M" .or. cObsField $ cField
							oItem[ "data" ]   := EncodeUTF8( ( cTable )->(FieldGet( nPos ) ) )
						Else
							oItem[ "data" ]   := EncodeUTF8( Alltrim(( cTable )->(FieldGet( nPos ) )))
						EndIf

						Aadd(oResponse[ "itemsAdditionalInformation" ], oItem )
					EndIf
				Next
				cJson := FWJsonSerialize( oResponse, .F., .F., .T. )

				Self:SetResponse( cJson )

				nResponse := 200

			Else
				cMessage:= STR0016 // Não há dados a serem exibidos
			EndIf
		Else
			cMessage:=  I18N( STR0015, { cRecordNumber }) // Registro #1 não encontrado
		EndIf
	Else
		cMessage:=  STR0011 // Usuário não está cadastrado como aprovador
	EndIf


	If nResponse == 400
		SetRestFault( 400, EncodeUTF8( cMessage ), .T., 400, EncodeUTF8( cMessage )  )
	EndIf

	lRet := ( nResponse == 200 )

	RestArea(aArea)
	FreeObj( oItem )
	FreeObj( oService )
	FWFreeArray( aFields )
	FwFreeArray( aTemp )

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
			cMessage:= STR0011 // Usuário não esta cadastrado como aprovador
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

	ACB->( DbSetOrder( 1 ) ) // ACB_FILIAL+ACB_CODOBJ
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
				If lFileInDB .And. File( cFullFilePath )
					lProcessFile := .T.
				EndIf
			ElseIf File( cFullFilePath )
				lProcessFile := .T.
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
		cMessage := I18N( STR0015, { Self:objectCode }) //Registro #1 não encontrado
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

			Do CASE
			Case cEntity == "CN9"
				cSearchKey := FwXFilial( "AC9" ) + cEntity + cFilEnt + PADR( CN9->( CN9_NUMERO+CN9_REVISA ), nTamCodEnt )
			Case cEntity == "SCP"
				cSearchKey := FwXFilial( "AC9" ) + cEntity + cFilEnt + PADR( SCP->( CP_NUM+CP_ITEM+CP_LOCAL ), nTamCodEnt )
			Otherwise
				If SCR->CR_TIPO == "PC"
					cX2Unico := "C7_FILIAL+C7_NUM" // desconsidera o item
					nTamCodEnt := FwSizeFilial() + GetSx3Cache( "C7_NUM", "X3_TAMANHO" )
				Else
					cX2Unico := FWX2Unico( cEntity )
				EndIf
				cSearchKey := FwXFilial( "AC9" ) + cEntity + cFilEnt + PADR(( cEntity )->(&( cX2Unico )), nTamCodEnt)
			EndCase

			AC9->( DbSetOrder( 2 ) ) // AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ

			If AC9->(DbSeek( cSearchKey ))

				While AC9->(!EOF()) .AND. ( AC9->( AC9_FILIAL + AC9_ENTIDA + AC9_FILENT + LEFT( AC9_CODENT, nTamCodEnt ) )  == cSearchKey )
					oItem := JsonObject():New()
					lProcessFile := .F.
					ACB->( DbSetOrder( 1 ) ) // ACB_FILIAL+ACB_CODOBJ
					If ACB->( DbSeek( FwXFilial( "ACB" ) + AC9->AC9_CODOBJ ) )
						cFilePath := Lower( ACB->ACB_OBJETO )
						If !Empty( cFilePath )
							cFullFilePath := cDirDoc + "\" + cFilePath

							If ACB->(FieldPos("ACB_BINID")) > 0 .and. !Empty( ACB->ACB_BINID )
								If oFb == NIL
									oFb := MPFilesBinary():New()
								EndIf
								lFileInDB := oFb:ReadFB( ACB->ACB_BINID, cDirDoc + "\", cFilePath, .F. )
								If lFileInDB .And. File( cFullFilePath )
									lProcessFile := .T.
								EndIf
							ElseIf File( cFullFilePath )
								lProcessFile := .T.
							EndIf

							If lProcessFile
								// Substituição do FOpen por FWFileReader
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
				cMessage := I18N( STR0015, { cSearchKey }) //Registro #1 não encontrado
			EndIf
		EndIf
	Else
		cMessage := I18N( STR0015, { ::documentId } ) // Registro #1 não encontrado
	EndIf

	cJson := FWJsonSerialize( oResponse, .F., .F., .T. )
	::SetResponse( cJson )

	If nResponse == 400
		SetRestFault( 400, EncodeUTF8( cMessage ), .T., 400, EncodeUTF8( cMessage ) )
	EndIf
	// Liberação de objetos
	FwFreeObj(oFileReader)
	FwFreeObj(oFb)
	FwFreeObj(oItem)
	FwFreeObj(oResponse)
	lRet := ( nResponse == 200 )
Return lRet

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

	Do Case
	Case SCR->CR_TIPO $ "PC|IP|AE"
		cEntity := "SC7"
		SC7->( DbSetOrder( 1 ) ) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
		If SCR->CR_TIPO == "IP"
			DBM->( DbSetOrder( 1 ) ) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
			DBM->( DbSeek( SCR->( CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP ) ) )
			SC7->( DbSeek( ( xFilial( "SC7" ) + DBM->( AllTrim( DBM_NUM ) + DBM_ITEM ) ) ) )
		Else
			SC7->( DbSeek( xFilial( "SC7" ) + AllTrim( SCR->CR_NUM )  ) )
		EndIf

	Case SCR->CR_TIPO == "SC"
		cEntity := "SC1"
		DBM->( DbSetOrder( 1 ) ) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
		SC1->( DbSetOrder( 1 ) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		DBM->( DbSeek( SCR->( CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP ) ) )
		SC1->( DbSeek( ( xFilial( "SC1" ) + DBM->( AllTrim( DBM_NUM ) + DBM_ITEM ) ) ) )

	Case SCR->CR_TIPO $ "IM|MD"
		cEntity := "CND"
		CND->( DbSetOrder( 4 ) ) //CND_FILIAL+CND_NUMMED
		CND->( DbSeek( xFilial( "CND" ) + LEFT(SCR->CR_NUM, GetSx3Cache("CND_NUMMED","X3_TAMANHO") ) ) )

	Case SCR->CR_TIPO $ "CT|IC"
		cEntity := "CN9"
		CN9->( DbSetOrder( 1 ) ) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA
		CN9->( DbSeek( xFilial( "CN9" ) + SCR->CR_NUM ) )

	Case SCR->CR_TIPO $ "SA"
		cEntity := "SCP"

		DBM->( DbSetOrder( 1 ) ) //DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR
		SCP->( DbSetOrder( 1 ) ) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
		DBM->( DbSeek( SCR->( CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP ) ) )
		SCP->( DbSeek( ( xFilial( "SCP" ) + DBM->( AllTrim( DBM_NUM ) + Alltrim(DBM_ITEM) ) ) ) )

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
		SCR->( DbGoTo( nRecId ) ) // posiciona no registro informado

		If ( SCR->( !Eof( ) ) )

			cKey:= SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM
			SCR->( DbSetOrder( 1 ) ) //CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
			SCR->( DbSeek( cKey ))
			aStatus:= RetSx3Box( Posicione( "SX3", 2, "CR_STATUS", "X3CBox()" ),,, GetSx3Cache( "CR_STATUS", "X3_TAMANHO" ) ) // pega o combobox do campo status
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
			cMessage:= I18N( STR0015, { nRecId }) //Registro #1 não encontrado
		EndIf
	Else
		cMessage:= I18N( STR0015, { nRecId }) //Registro #1 não encontrado
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

	cSymbol := EncodeUTF8(AllTrim(SuperGetMv('MV_SIMB' + cValToChar(nCurrency), .F., '1'))) //-- Obtém o valor do parâmetro

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
	Local oStatement := FWPreparedStatement():New()
	Local cQuery           := ""
	Local lRet             := .T.
	Local cTmp             := ""
	Local cDocStatus       := ""
	Local cTypeApproval    := ""
	Local nTotal           := 0

	dbSelectArea( "SAK" )
	dbSetOrder( 2 ) //AK_FILIAL + AK_USER
	If MsSeek( xFilial( "SAK" ) + __cUserId )
		cTmp := GetNextAlias()
		cDocStatus:= oSelf:documentStatus
		cTypeApproval := oSelf:typeApproval

		cQuery := "SELECT COUNT(*) TOTAL FROM " + RetSqlName( "SCR" ) + " SCR "
		cQuery += " WHERE SCR.CR_FILIAL = ?"
		cQuery += " AND SCR.CR_TIPO = ?"
		cQuery += " AND SCR.CR_STATUS = ?"
		cQuery += " AND SCR.CR_USER = ?"
		cQuery += " AND SCR.D_E_L_E_T_ = ?"

		//Define a consulta e os parâmetros
		oStatement:SetQuery(cQuery)
		oStatement:SetString(1, FWxFilial('SCR'))
		oStatement:SetString(2, oSelf:typeApproval)
		oStatement:SetString(3, oSelf:documentStatus)
		oStatement:SetString(4, SAK->AK_USER)
		oStatement:SetString(5, ' ')

		//Recupera a consulta já com os parâmetros injetados
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
	
	//Validação tipo = AC (Minha Prestação de Contas)
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

	// Obtém o ID do usuário logado
	Local cUserID := RetCodUSR()

	// Carrega as informações do usuário no objeto JSON de resposta
	oResponse["userId"] := cUserID
	oResponse["availableBalance"] := GetBalance(cUserID)
	oResponse["currency"] := GetUsrCur(cUserID)
	oResponse["approvalGroups"] := GetGrpApv(cUserID)

	// Serializa o JSON de resposta
	cJson := FWJsonSerialize(oResponse, .F., .F., .T.)

	// Define a resposta do método
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
			oResponse["source"]      := aDados[1]
			oResponse["language"]    := aDados[2]
			oResponse["compiler"]    := aDados[3]
			oResponse["date"]        := DToS(aDados[4]) // Formato AAAAMMDD
			oResponse["time"]        := aDados[5]
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
	Local oItem := Nil
	Local aSaldoDisp := {}
	Local aAprov := {}

	Local cQuery := ''
	Local oQrySAK := Nil
	Local cAliasSAK := GetNextAlias()
	Default cUserID := ""


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

		oItem["code"] := (cAliasSAK)->AK_COD
		oItem["availableBalance"] := aSaldoDisp[1]
		oItem["currencySymbol"] := GetSymbol((cAliasSAK)->AK_MOEDA)
		oItem["limit"] := (cAliasSAK)->AK_LIMITE
		oItem["type"] := (cAliasSAK)->AK_TIPO
		oItem["currentApprovAmount"] := GetApvAmt((cAliasSAK)->AK_COD, (cAliasSAK)->AK_TIPO)
		AAdd(aAprov, oItem)
		(cAliasSAK)->(DBSkip())
	Enddo
	(cAliasSAK)->(dbCloseArea())
	FreeObj( oItem  )
	FreeObj( oQrySAK  )
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
	Local cMoeda := "R$" // Moeda padrão

	DbSelectArea("SCS") // Tabela SCR
	If DbSeek(xFilial("SCS") + __cUserId) // Busca pelo ID do usuário
		cMoeda :=  Alltrim(GetSymbol(SCS->CS_MOEDA)) // Campo que armazena a moeda associada ao usuário
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
//-------------------------------------------------------------------------------------
Static Function GetGrpApv(cUserID)
	Local oItem := Nil
	Local aGrupos := {}
	Local cQuery := ''
	Local oQrySAL := Nil
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
		oItem["code"] := (cAliasSAL)->AL_COD
		oItem["description"] := (cAliasSAL)->AL_DESC
		AAdd(aGrupos, oItem)
		(cAliasSAL)->(DBSkip())
	Enddo
	(cAliasSAL)->(dbCloseArea())
	FreeObj( oItem  )
	FreeObj( oQrySAL  )
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
	Local nVlAprov := 0
	Local dDtIni := FirstDate(dDatabase)
	Local dDtFin := LastDate(dDatabase)

	Local cQuery := ''
	Local oQrySCR := Nil
	Local cAliasSCR := GetNextAlias()

	Default cApprov := ''
	Default cType := ''

	IF cType == 'D'
		dDtIni := dDatabase
		dDtFin := dDatabase
	elseif cType == 'S'
		dDtIni := DaySub(dDatabase, 7)
		dDtFin := dDatabase
	endif

	oQrySCR := FWPreparedStatement():New()

	cQuery := " SELECT SUM(CR_TOTAL) AS SLD
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
	FreeObj( oQrySCR  )
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
	
	Local oQuery 	  := Nil
    Local cQuery      := ""
    Local cAliasTmp   := ""
    Local nTot        := 0
	Local aApprovers  := {}

    If MATXUser(__cUserID,@aUser)

        cQuery     := ""
		cAliasTmp  := GetNextAlias()
        cBranchFLF := xFilial( "FLF" )
        cBranchSA1 := xFilial( "SA1" )
        cBranchCTT := xFilial( "CTT" )
        cBranchFO7 := xFilial( "FO7" )

        cApprovers  := GetApprov( aUser[1] )
        cInApprovers := FormatIn( cApprovers, "," )

		aApprovers  := StrTokArr(cApprovers,",")

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

    Local cApprovers  := "" 
    Local cQuery      := ""
	Local oQuery      := Nil
    Local cAliasTmp   := GetNextAlias()

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

	Local oQuery        := Nil
	Local cQuery 		:= ""
	Local lRet			:= .F.
	Local lRD0_VIAJA	:= RD0->(FieldPos("RD0_FVIAJ")) > 0
	Local cAliasTmp 	:= GetNextAlias()

	Default aUser := {}
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
