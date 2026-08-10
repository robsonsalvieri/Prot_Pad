#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
    /*/{Protheus.doc} WSGTP002

    API RESTful PARA TELA DE ESCALA DIÁRIA

    Esta API fornece serviços para consultas voltadas à para tela de escala diária,
    facilitando a integração com aplicações externas via PO UI.

    @Autor
        - Desenvolvedor: Silas Gomes
        - Data de Criação: 01/07/2025

    @Observações
        - Todos os endpoints seguem o padrão RESTful.
        - As respostas são estruturadas em JSON para facilitar a integração.
        - Os parâmetros são opcionais e permitem filtragem dos resultados conforme necessidade.
    /*/
//------------------------------------------------------------------------------
WSRESTFUL WSGTP002 DESCRIPTION "API REST para integração com o sistema Urbano facilitando as consultas na tela de escala diária"

    WSDATA dataIni  as String
    WSDATA dataFim  as String
    WSDATA escala   as String OPTIONAL
    WSDATA linha    as String OPTIONAL
	WSDATA filter   as String OPTIONAL
    WSDATA tipoCol  as String OPTIONAL
	WSDATA page     as INTEGER OPTIONAL
	WSDATA pageSize as INTEGER OPTIONAL

    WSMETHOD GET totEscala;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver ";
        PATH "totEscala" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/totEscala/?{dataIni}{dataFim}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET escalaAlocada;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver ";
        PATH "escalaAlocada" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/escalaAlocada/?{dataIni}{dataFim}{escala}{linha}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET semVeiculo;
		DESCRIPTION "Método para buscar escalas que não possuam alocação de veículos";
        PATH "semVeiculo" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/semVeiculo/?{dataIni}{dataFim}{escala}{linha}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET semMotorista;
		DESCRIPTION "Método para buscar escalas que não possuam alocação de motoristas";
        PATH "semMotorista" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/semMotorista/?{dataIni}{dataFim}{escala}{linha}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET semCobrador;
		DESCRIPTION "Método para buscar escalas que não possuam alocação de motoristas";
        PATH "semCobrador" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/semCobrador/?{dataIni}{dataFim}{escala}{linha}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET folgaColab;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver ";
        PATH "folgaColab" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/folgaColab/?{dataIni}{dataFim}{tipoCol}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET totVeiculo;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver ";
        PATH "totVeiculo" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/totVeiculo/?{dataIni}{dataFim}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET veiculoManutencao;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver ";
        PATH "veiculoManutencao" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/veiculoManutencao/?{dataIni}{dataFim}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET semEscala;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver ";
        PATH "semEscala" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/semEscala/?{dataIni}{dataFim}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

    WSMETHOD GET feriasColab;
        DESCRIPTION "Método para buscar colaboradores de férias";
        PATH "feriasColab" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/feriasColab/?{dataIni}{dataFim}{tipoCol}{page}{pageSize}";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET afastColab;
        DESCRIPTION "Método para buscar colaboradores afastados";
        PATH "afastColab" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/afastColab/?{dataIni}{dataFim}{tipoCol}{page}{pageSize}";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET atestColab;
        DESCRIPTION "Método para buscar colaboradores com atestado";
        PATH "atestColab" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/atestColab/?{dataIni}{dataFim}{tipoCol}{page}{pageSize}";
        PRODUCES APPLICATION_JSON

    WSMETHOD GET totColab;
        DESCRIPTION "Método para buscar total de colaboradores de folga/atestado/afastado/férias";
        PATH "totColab" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP002/totColab/?{dataIni}{dataFim}{tipoCol}";
        PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
    //{Protheus.doc} totEscala
    //Query para os totalizadores das escalas

    //@since 15/07/2025
    //@version 1.0
//-------------------------------------------------------------------

WSMETHOD GET totEscala WSRECEIVE dataIni, dataFim, linha WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
	Local cDtIni    as character
	Local cDtFim    as character
    Local cLinha    as character
    Local nIndex    as number

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cLinha    := Self:linha
    nIndex    := 0

    Self:SetContentType("application/json")

    getTotEscala(cDtIni, cDtFim, cLinha, @cAlias)

    (cAlias)->(DbGoTop())

    oResponse['totalEscala'] := {}

    While ( cAlias )-> (!EoF())
        nIndex++

        aadd(oResponse[ 'totalEscala' ], JsonObject(): New())
        oResponse[ 'totalEscala' ][nIndex][ 'totalAlocado' ]      := (cAlias)->QTD_ALOCADO
        oResponse[ 'totalEscala' ][nIndex][ 'totalSemVeiculo' ]   := (cAlias)->QTD_SEM_VEICULO
        oResponse[ 'totalEscala' ][nIndex][ 'totalSemMotorista' ] := (cAlias)->QTD_SEM_MOTORISTA
        oResponse[ 'totalEscala' ][nIndex][ 'totalSemCobrador' ]  := (cAlias)->QTD_SEM_COBRADOR
        oResponse[ 'totalEscala' ][nIndex][ 'totalSemAlocacao' ]  := (cAlias)->QTD_NAO_ALOCADO

        ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getTotEscala
    Query para trazer o total das escalas

    @since 01/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getTotEscala(cDtIni as character, cDtFim as character, cLinha as character, cAlias as character)

    Local oQuery as object
	Local cQuery as character

    oQuery := Nil
    cQuery := ''

    cQuery := " WITH CLASSIFICACAO AS ( "
    cQuery +=   " SELECT DISTINCT H7F.H7F_CODH76,"
    cQuery +=   " CASE WHEN EXISTS"
    cQuery +=       " (SELECT 1 FROM " + RetSqlName('H76') + " H76 "
    cQuery +=       " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=           " ON ( H77.H77_FILIAL = '" + XFilial('H77') + "' "
	cQuery +=               " AND H77.H77_CODH76 = H76.H76_CODIGO"

	If !Empty(cLinha)
	    cQuery +=               " AND H77.H77_CODH6V = '" + cLinha + "'"
	Endif

	cQuery +=               " AND H77.D_E_L_E_T_ = '' )"

    cQuery +=       " WHERE H7F.H7F_CODH76 = H76.H76_CODIGO "
    cQuery +=       " AND H76.H76_FILIAL = '" + xFilial('H76') + "' "
    cQuery +=       " AND H76.D_E_L_E_T_ = ''"
    cQuery +=       " AND (H76.H76_QTVEIC = 0
    cQuery +=           " OR EXISTS (SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
    cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                   " AND (H7G.H7G_CODH70 IS NOT NULL)"
    cQuery +=                   " AND (H7G.H7G_CODH70 <> '')"
    cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))"

    cQuery +=       " AND (H76.H76_QTMOTO = 0
    cQuery +=           " OR EXISTS (SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
    cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                   " AND (H7G.H7G_CODGYG IS NOT NULL)"
    cQuery +=                   " AND (H7G.H7G_CODGYG <> '')"
    cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))"

    cQuery +=       " AND (H76.H76_QTCOBR = 0"
    cQuery +=           " OR EXISTS (SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
    cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                   " AND (H7G.H7G_CODCOB IS NOT NULL)"
    cQuery +=                   " AND (H7G.H7G_CODCOB <> '')"
    cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))) THEN 'ALOCADO'"

    cQuery +=   " WHEN EXISTS"
    cQuery +=       " (SELECT 1 FROM " + RetSqlName('H76') + " H76 "
    cQuery +=       " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=           " ON ( H77.H77_FILIAL = '" + XFilial('H77') + "' "
	cQuery +=               " AND H77.H77_CODH76 = H76.H76_CODIGO"

	If !Empty(cLinha)
	    cQuery +=               " AND H77.H77_CODH6V = '" + cLinha + "'"
	Endif

	cQuery +=               " AND H77.D_E_L_E_T_ = '' )"

    cQuery +=       " WHERE H7F.H7F_CODH76 = H76.H76_CODIGO "
    cQuery +=           " AND H76.H76_FILIAL = '" + xFilial('H76') + "' "
    cQuery +=           " AND H76.D_E_L_E_T_ = ''"
    cQuery +=           " AND H76.H76_QTCOBR > 0
    cQuery +=           " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
    cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                   " AND (H7G.H7G_CODCOB IS NOT NULL)"
    cQuery +=                   " AND (H7G.H7G_CODCOB <> '')"
    cQuery +=                   " AND H7G.D_E_L_E_T_ = '')) THEN 'SEM_COBRADOR'"

    cQuery +=   " WHEN EXISTS ("
    cQuery +=       " SELECT 1 FROM " + RetSqlName('H76') + " H76 "
    cQuery +=       " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=           " ON ( H77.H77_FILIAL = '" + XFilial('H77') + "' "
	cQuery +=               " AND H77.H77_CODH76 = H76.H76_CODIGO"

	If !Empty(cLinha)
	    cQuery +=               " AND H77.H77_CODH6V = '" + cLinha + "'"
	Endif

	cQuery +=               " AND H77.D_E_L_E_T_ = '' )"

    cQuery +=       " WHERE H7F.H7F_CODH76 = H76.H76_CODIGO "
    cQuery +=           " AND H76.H76_FILIAL = '" + xFilial('H76') + "' "
    cQuery +=           " AND H76.D_E_L_E_T_ = ''"
    cQuery +=           " AND H76.H76_QTMOTO > 0 "
    cQuery +=           " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
    cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                   " AND (H7G.H7G_CODGYG IS NOT NULL)"
    cQuery +=                   " AND (H7G.H7G_CODGYG <> '')"
    cQuery +=                   " AND H7G.D_E_L_E_T_ = '')) THEN 'SEM_MOTORISTA'"

    cQuery +=   " WHEN EXISTS ("
    cQuery +=       " SELECT 1 FROM " + RetSqlName('H76') + " H76 "
    cQuery +=       " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=           " ON ( H77.H77_FILIAL = '" + XFilial('H77') + "' "
	cQuery +=               " AND H77.H77_CODH76 = H76.H76_CODIGO"

	If !Empty(cLinha)
	    cQuery +=               " AND H77.H77_CODH6V = '" + cLinha + "'"
	Endif

	cQuery +=               " AND H77.D_E_L_E_T_ = '' )"

    cQuery +=       " WHERE H7F.H7F_CODH76 = H76.H76_CODIGO "
    cQuery +=           " AND H76.H76_FILIAL = '" + xFilial('H76') + "' "
    cQuery +=           " AND H76.D_E_L_E_T_ = ''"
    cQuery +=           " AND H76.H76_QTVEIC > 0
    cQuery +=           " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
    cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                   " AND (H7G.H7G_CODH70 IS NOT NULL)"
    cQuery +=                   " AND (H7G.H7G_CODH70 <> '')"
    cQuery +=                   " AND H7G.D_E_L_E_T_ = '')) THEN 'SEM_VEICULO'"

    cQuery +=           " ELSE 'NAO_ALOCADO'"
    cQuery +=           " END AS CLASSIFICACAO"

    cQuery +=         " FROM " + RetSqlName('H7F') + " H7F "
    cQuery +=         " WHERE H7F.H7F_FILIAL = '" + xFilial('H7F') + "' "
    cQuery +=               " AND H7F.H7F_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' "
    cQuery +=               " AND H7F.D_E_L_E_T_ = '')"

    cQuery +=         " SELECT "
    cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'ALOCADO' THEN 1 END) AS QTD_ALOCADO, "
    cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'SEM_COBRADOR' THEN 1 END) AS QTD_SEM_COBRADOR,"
    cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'SEM_MOTORISTA' THEN 1 END) AS QTD_SEM_MOTORISTA,"
    cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'SEM_VEICULO' THEN 1 END) AS QTD_SEM_VEICULO, "
    cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'NAO_ALOCADO' THEN 1 END) AS QTD_NAO_ALOCADO "
    cQuery +=           " FROM CLASSIFICACAO; "

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    //{Protheus.doc} escalaAlocada
    // Lista de escalas alocadas

    // @since 15/07/2025
    // @version 1.0

    // @description Este método permite consultar as escalas alocadas dentro de um intervalo de datas.
    //              A consulta pode ser filtrada por dados como escala, linha e também suporta paginação.

    // @example
    // [Sem Opcional] GET -> http://127.0.0.1:9090/rest/WSGTP002/escalaAlocada?dataIni=20240101&dataFim=20240105

//-------------------------------------------------------------------
WSMETHOD GET escalaAlocada WSRECEIVE dataIni, dataFim, linha, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
    Local cAliasDia as character
	Local cDtIni    as character
	Local cDtFim    as character
	Local cCodLinha as character
    Local nIndex    as number
    Local nPage     as number
	Local nPageSize as number
	Local nOffset   as number

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cAliasDia := ""
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cCodLinha := Self:linha
    nIndex    := 0
    nPage     := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset   := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getEscalasAloc(cDtIni, cDtFim, cCodLinha, @cAlias, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Escalas'] := {}

    While ( cAlias )-> (!EoF())

        cAliasDia := GetNextAlias()

        nIndex++

        aadd(oResponse['Escalas'], JsonObject():New())

        oResponse['Escalas'][nIndex]['pkEscala'] := ((cAlias)->FILIAL + (cAlias)->CODESCALA)
        oResponse['Escalas'][nIndex]['codigoEscala'] := (cAlias)->CODESCALA
        oResponse['Escalas'][nIndex]['descricaoEscala'] := EncodeUTF8(AllTrim((cAlias)->DESCESCALA))

        getDiaAloc(cDtIni, cDtFim, @cAliasDia, (cAlias)->CODESCALA)

        While ( cAliasDia )->(!EoF())

            // Verifique se o campo 'dias' já existe para evitar a sobrescrição
            If Empty(oResponse['Escalas'][nIndex]['dias'])
                oResponse['Escalas'][nIndex]['dias'] := {}
            EndIf

            // Adicione o dia ao array 'dias'
            aadd(oResponse['Escalas'][nIndex]['dias'], (cAliasDia)->DIA)

            (cAliasDia)->(DbSkip())

        EndDo

        ( cAliasDia )->(DbCloseArea())

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim, cCodLinha,, .T., .T.)
    oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getEscalasAloc
    // Query para trazer a escala alocada

    // @since 15/07/2025
    // @version 1.0

    // @description Este método permite consultar as escalas alocadas. A consulta pode ser filtrada por um intervalo de datas,
    //              além de aceitar parâmetros opcionais para filtrar por escala, linha, e também suporta paginação.
    /*/
//-------------------------------------------------------------------
Static function getEscalasAloc(cDataIni as character, cDataFim as character, cCodLinha as character, cAlias as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery as object
	Local cQuery as character

    oQuery            := Nil
    cQuery            := ''

	Default cCodLinha := ''

    cQuery := " SELECT H76.H76_FILIAL FILIAL,"
    cQuery +=   " H76.H76_CODIGO CODESCALA,"
    cQuery +=   " H76.H76_DESCRI DESCESCALA"
    cQuery += " FROM " + RetSqlName('H76') + " H76 "

	cQuery +=   " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=       " ON ( H77.H77_CODH76 = H76.H76_CODIGO"
	cQuery +=           " AND H77.H77_FILIAL = '" + XFilial('H77') + "' "

	If !Empty(cCodLinha)
	    cQuery +=           " AND H77.H77_CODH6V = '" + cCodLinha + "'"
	Endif

	cQuery +=           " AND H77.D_E_L_E_T_ = '' )"

	cQuery +=   " INNER JOIN " + RetSqlName('H7F') + " H7F "
	cQuery +=       " ON ( H7F.H7F_FILIAL = '" + XFilial('H7F') + "' "
    cQuery +=           " AND H7F.H7F_CODH76 = H76.H76_CODIGO"
	cQuery +=           " AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
	cQuery +=           " AND H7F.D_E_L_E_T_ = '' )"

	cQuery += " WHERE H76.H76_FILIAL = '" + xFilial("H76") + "'"

	cQuery +=       " AND H76.D_E_L_E_T_ = ''"

	cQuery +=       " AND (H76.H76_QTVEIC = 0"
	cQuery +=           " OR EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
	cQuery +=               " WHERE H7G.H7G_FILIAL = '" + XFilial('H7G') + "' "
	cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
	cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
	cQuery +=                   " AND (H7G.H7G_CODH70 IS NOT NULL)"
	cQuery +=                   " AND (H7G.H7G_CODH70 <> '')"
	cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))"
	cQuery +=       " AND (H76.H76_QTMOTO = 0"
    cQuery +=           " OR EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
	cQuery +=               " WHERE H7G.H7G_FILIAL = '" + XFilial('H7G') + "' "
	cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
	cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
	cQuery +=                   " AND (H7G.H7G_CODGYG IS NOT NULL)"
	cQuery +=                   " AND (H7G.H7G_CODGYG <> '')"
	cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))"
    cQuery +=       " AND (H76.H76_QTCOBR = 0"
    cQuery +=           " OR EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
	cQuery +=               " WHERE H7G.H7G_FILIAL = '" + XFilial('H7G') + "' "
	cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
	cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
	cQuery +=                   " AND (H7G.H7G_CODCOB IS NOT NULL)"
	cQuery +=                   " AND (H7G.H7G_CODCOB <> '')"
	cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))"

	cQuery += " GROUP BY H76.H76_FILIAL,"
	cQuery +=   " H76.H76_CODIGO,"
	cQuery +=   " H76.H76_DESCRI"

	cQuery += " ORDER BY H76.H76_CODIGO"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

   oQuery := FWPreparedStatement():New(cQuery)
   cQuery := oQuery:GetFixQuery()
   cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    //{Protheus.doc} semVeiculo
    //Método para buscar escalas que não possuam alocação de veículos

    //@since 15/07/2025
    //@version 1.0
//-------------------------------------------------------------------
WSMETHOD GET semVeiculo WSRECEIVE dataIni, dataFim, linha, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
    Local cAliasDia as character
	Local cDtIni    as character
	Local cDtFim    as character
	Local cCodLinha as character
    Local nIndex    as numeric
    Local nPage     as numeric
	Local nPageSize as numeric
	Local nOffset   as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cAliasDia := ""
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cCodLinha := Self:linha
    nIndex    := 0
    nPage     := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset   := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getSemVeiculo(cDtIni, cDtFim, cCodLinha, @cAlias, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Escalas'] := {}

    While ( cAlias )-> (!EoF())

        cAliasDia := GetNextAlias()

        nIndex++

        aadd(oResponse['Escalas'], JsonObject():New())

        oResponse['Escalas'][nIndex]['pkEscala'] := ((cAlias)->FILIAL + (cAlias)->CODESCALA)
        oResponse['Escalas'][nIndex]['codigoEscala'] := (cAlias)->CODESCALA
        oResponse['Escalas'][nIndex]['descricaoEscala'] := EncodeUTF8(AllTrim((cAlias)->DESCESCALA))

        getDiaAloc(cDtIni, cDtFim, @cAliasDia, (cAlias)->CODESCALA)

        While ( cAliasDia )->(!EoF())

            // Verifique se o campo 'dias' já existe para evitar a sobrescrição
            If Empty(oResponse['Escalas'][nIndex]['dias'])
                oResponse['Escalas'][nIndex]['dias'] := {}
            EndIf

            // Adicione o dia ao array 'dias'
            aadd(oResponse['Escalas'][nIndex]['dias'], (cAliasDia)->DIA)

            (cAliasDia)->(DbSkip())

        EndDo

        ( cAliasDia )->(DbCloseArea())

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim, cCodLinha,, .T.,,,, .T.)
    oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getSemVeiculo
    // Query para trazer a escala sem Veiculo

    // @since 15/07/2025
    // @version 1.0

    // @description Este método permite consultar as escalas sem veiculos.
    //  A consulta pode ser filtrada por um intervalo de datas,
    //  além de aceitar parâmetros opcionais para filtrar por escala, linha, e também suporta paginação.
    /*/
//-------------------------------------------------------------------
Static function getSemVeiculo(cDataIni as character, cDataFim as character, cCodLinha as character, cAlias as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery as object
	Local cQuery as character

    oQuery := Nil
    cQuery := ''

	Default cCodLinha  := ''

    cQuery := " SELECT H76.H76_FILIAL FILIAL,"
    cQuery +=   " H76.H76_CODIGO CODESCALA,"
    cQuery +=   " H76.H76_DESCRI DESCESCALA"

    cQuery += " FROM " + RetSqlName('H76') + " H76 "

	cQuery += " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=   " ON (H77.H77_FILIAL = '" + XFilial('H77') + "' "
	cQuery +=       " AND H77.H77_CODH76 = H76.H76_CODIGO "

	If !Empty(cCodLinha)
	    cQuery +=           " AND H77.H77_CODH6V = '" + cCodLinha + "'"
	Endif

	cQuery +=       " AND H77.D_E_L_E_T_ = '' )"

    cQuery += " INNER JOIN " + RetSqlName('H7F') + " H7F "
    cQuery +=   " ON (H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
    cQuery +=       " AND H7F.H7F_CODH76 = H76.H76_CODIGO"
    cQuery +=       " AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
    cQuery +=       " AND H7F.D_E_L_E_T_ = '')"

    cQuery += " WHERE H76.H76_FILIAL = '" + xFilial("H76") + "'"

    cQuery += " AND H76.D_E_L_E_T_ = ''"
    cQuery += " AND H76.H76_QTVEIC > 0"
    cQuery += " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=                   " WHERE (H7G.H7G_FILIAL = '" + XFilial('H7G') + "'"
    cQuery +=                       " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                       " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                       " AND (H7G.H7G_CODH70 IS NOT NULL)"
    cQuery +=                       " AND (H7G.H7G_CODH70 <> '')"
    cQuery +=                       " AND H7G.D_E_L_E_T_ = ''))"

	cQuery += " GROUP BY H76.H76_FILIAL,"
	cQuery +=   " H76.H76_CODIGO,"
	cQuery +=   " H76.H76_DESCRI"

	cQuery += " ORDER BY H76.H76_CODIGO"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    //{Protheus.doc} semMotorista
    //Método para buscar escalas que não possuam alocação de motorista.

    //@since 15/07/2025
    //@version 1.0
//-------------------------------------------------------------------
WSMETHOD GET semMotorista WSRECEIVE dataIni, dataFim, linha, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
    Local cAliasDia as character
	Local cDtIni    as character
	Local cDtFim    as character
	Local cCodLinha as character
    Local nIndex    as numeric
    Local nPage     as numeric
	Local nPageSize as numeric
	Local nOffset   as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cAliasDia := ""
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cCodLinha := Self:linha
    nIndex    := 0
    nPage     := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset   := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getSemMotorista(cDtIni, cDtFim, cCodLinha, @cAlias, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Escalas'] := {}

    While ( cAlias )-> (!EoF())

        cAliasDia := GetNextAlias()

        nIndex++

        aadd(oResponse['Escalas'], JsonObject():New())

        oResponse['Escalas'][nIndex]['pkEscala'] := ((cAlias)->FILIAL + (cAlias)->CODESCALA)
        oResponse['Escalas'][nIndex]['codigoEscala'] := (cAlias)->CODESCALA
        oResponse['Escalas'][nIndex]['descricaoEscala'] := EncodeUTF8(AllTrim((cAlias)->DESCESCALA))

        getDiaAloc(cDtIni, cDtFim, @cAliasDia, (cAlias)->CODESCALA)

        While ( cAliasDia )->(!EoF())

            // Verifique se o campo 'dias' já existe para evitar a sobrescrição
            If Empty(oResponse['Escalas'][nIndex]['dias'])
                oResponse['Escalas'][nIndex]['dias'] := {}
            EndIf

            // Adicione o dia ao array 'dias'
            aadd(oResponse['Escalas'][nIndex]['dias'], (cAliasDia)->DIA)

            // Avance para o próximo registro
            (cAliasDia)->(DbSkip())

        EndDo

        ( cAliasDia )->(DbCloseArea())

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim, cCodLinha,, .T.,,, .T.)
    oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getSemMotorista
    // Query para trazer a escala sem motorista

    // @since 15/07/2025
    // @version 1.0

    // @description Este método permite consultar as escalas sem motorista.
    //  A consulta pode ser filtrada por um intervalo de datas,
    //  além de aceitar parâmetros opcionais para filtrar por escala, linha, e também suporta paginação.
    /*/
//-------------------------------------------------------------------
Static function getSemMotorista(cDataIni as character, cDataFim as character, cCodLinha as character, cAlias as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery as object
	Local cQuery as character

    oQuery    := Nil
    cQuery    := ''

	Default cCodLinha  := ''

    cQuery := " SELECT  H76.H76_FILIAL FILIAL,"
    cQuery +=   " H76.H76_CODIGO CODESCALA,"
    cQuery +=   " H76.H76_DESCRI DESCESCALA"

    cQuery += " FROM " + RetSqlName('H76') + " H76 "

	cQuery += " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=   " ON (H77.H77_FILIAL = '" + XFilial('H77') + "' "
	cQuery +=       " AND H77.H77_CODH76 = H76.H76_CODIGO "

	If !Empty(cCodLinha)
	    cQuery +=           " AND H77.H77_CODH6V = '" + cCodLinha + "'"
	Endif

	cQuery +=       " AND H77.D_E_L_E_T_ = '' )"

    cQuery += " INNER JOIN " + RetSqlName('H7F') + " H7F "
    cQuery +=   " ON (H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
    cQuery +=       " AND H7F.H7F_CODH76 = H76.H76_CODIGO"
    cQuery +=       " AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
    cQuery +=       " AND H7F.D_E_L_E_T_ = '')"

	cQuery += " WHERE H76.H76_FILIAL = '" + xFilial("H76") + "'"

    cQuery += " AND H76.D_E_L_E_T_ = ''"
    cQuery += " AND H76.H76_QTMOTO > 0"
    cQuery += " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=                   " WHERE (H7G.H7G_FILIAL = '" + XFilial('H7G') + "'"
    cQuery +=                       " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                       " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                       " AND (H7G.H7G_CODGYG IS NOT NULL)"
    cQuery +=                       " AND (H7G.H7G_CODGYG <> '')"
    cQuery +=                       " AND H7G.D_E_L_E_T_ = ''))"

	cQuery += " GROUP BY H76.H76_FILIAL,"
	cQuery +=   " H76.H76_CODIGO,"
	cQuery +=   " H76.H76_DESCRI"

	cQuery += " ORDER BY H76.H76_CODIGO"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    //{Protheus.doc} semCobrador
    //Método para buscar escalas que não possuam alocação de cobrador.

    //@since 15/07/2025
    //@version 1.0
//-------------------------------------------------------------------
WSMETHOD GET semCobrador WSRECEIVE dataIni, dataFim, linha, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
    Local cAliasDia as character
	Local cDtIni    as character
	Local cDtFim    as character
	Local cCodLinha as character
    Local nIndex    as numeric
    Local nPage     as numeric
	Local nPageSize as numeric
	Local nOffset   as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cAliasDia := ""
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cCodLinha := Self:linha
    nIndex    := 0
    nPage     := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset   := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getSemCobrador(cDtIni, cDtFim, cCodLinha, @cAlias, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Escalas'] := {}

    While ( cAlias )-> (!EoF())

        cAliasDia := GetNextAlias()

        nIndex++

        aadd(oResponse['Escalas'], JsonObject():New())

        oResponse['Escalas'][nIndex]['pkEscala'] := ((cAlias)->FILIAL + (cAlias)->CODESCALA)
        oResponse['Escalas'][nIndex]['codigoEscala'] := (cAlias)->CODESCALA
        oResponse['Escalas'][nIndex]['descricaoEscala'] := EncodeUTF8(AllTrim((cAlias)->DESCESCALA))

        getDiaAloc(cDtIni, cDtFim, @cAliasDia, (cAlias)->CODESCALA)

        While ( cAliasDia )->(!EoF())

            // Verifique se o campo 'dias' já existe para evitar a sobrescrição
            If Empty(oResponse['Escalas'][nIndex]['dias'])
                oResponse['Escalas'][nIndex]['dias'] := {}
            EndIf

            // Adicione o dia ao array 'dias'
            aadd(oResponse['Escalas'][nIndex]['dias'], (cAliasDia)->DIA)

            // Avance para o próximo registro
            (cAliasDia)->(DbSkip())

        EndDo

        ( cAliasDia )->(DbCloseArea())

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim, cCodLinha,, .T.,, .T.)
	oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getSemCobrador
    // Query para trazer a escala sem cobrador

    // @since 15/07/2025
    // @version 1.0

    // @description Este método permite consultar as escalas sem cobrador.
    //  A consulta pode ser filtrada por um intervalo de datas,
    //  além de aceitar parâmetros opcionais para filtrar por escala, linha, e também suporta paginação.
    /*/
//-------------------------------------------------------------------
Static function getSemCobrador(cDataIni as character, cDataFim as character, cCodLinha as character, cAlias as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery as object
	Local cQuery as character

    oQuery := Nil
    cQuery := ''

	Default cCodLinha  := ''

    cQuery := " SELECT  H76.H76_FILIAL FILIAL,"
    cQuery +=   " H76.H76_CODIGO CODESCALA,"
    cQuery +=   " H76.H76_DESCRI DESCESCALA"

    cQuery += " FROM " + RetSqlName('H76') + " H76 "

	cQuery += " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=   " ON (H77.H77_FILIAL = '" + XFilial('H77') + "' "
	cQuery +=       " AND H77.H77_CODH76 = H76.H76_CODIGO "

	If !Empty(cCodLinha)
	    cQuery +=           " AND H77.H77_CODH6V = '" + cCodLinha + "'"
	Endif

	cQuery +=       " AND H77.D_E_L_E_T_ = '' )"

    cQuery += " INNER JOIN " + RetSqlName('H7F') + " H7F "
    cQuery +=   " ON (H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
    cQuery +=       " AND H7F.H7F_CODH76 = H76.H76_CODIGO"
    cQuery +=       " AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
    cQuery +=       " AND H7F.D_E_L_E_T_ = '')"

	cQuery += " WHERE H76.H76_FILIAL = '" + xFilial("H76") + "'"

    cQuery += " AND H76.D_E_L_E_T_ = ''"
    cQuery += " AND H76.H76_QTCOBR > 0"
    cQuery += " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
    cQuery +=                   " WHERE (H7G.H7G_FILIAL = '" + XFilial('H7G') + "'"
    cQuery +=                       " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=                       " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
    cQuery +=                       " AND (H7G.H7G_CODCOB IS NOT NULL)"
    cQuery +=                       " AND (H7G.H7G_CODCOB <> '')"
    cQuery +=                       " AND H7G.D_E_L_E_T_ = ''))"

	cQuery += " GROUP BY H76.H76_FILIAL,"
	cQuery +=   " H76.H76_CODIGO,"
	cQuery +=   " H76.H76_DESCRI"

	cQuery += " ORDER BY H76.H76_CODIGO"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    //{Protheus.doc} folgaColab
    //Método para buscar folga dos colaboradores.

    //@since 15/07/2025
    //@version 1.0
//-------------------------------------------------------------------
WSMETHOD GET folgaColab WSRECEIVE dataIni, dataFim, tipoCol, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
    Local cAliasDia as character
	Local cDtIni    as character
	Local cDtFim    as character
    Local cTipoCol  as character
    Local nIndex    as numeric
    Local nPage     as numeric
	Local nPageSize as numeric
	Local nOffset   as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cAliasDia := ""
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cTipoCol  := Self:tipoCol
    nIndex    := 0
    nPage     := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset   := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getFolga(cDtIni, cDtFim, @cAlias, cTipoCol, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Folgas'] := {}

    While ( cAlias )-> (!EoF())

        cAliasDia := GetNextAlias()
        nIndex++

        aadd(oResponse[ 'Folgas' ], JsonObject(): New())
        oResponse[ 'Folgas' ][nIndex][ 'colaborador' ]      := AllTrim( (cAlias)->COLABORADOR )
        oResponse[ 'Folgas' ][nIndex][ 'matricula' ]        := AllTrim( (cAlias)->MATRICULA )
        oResponse[ 'Folgas' ][nIndex][ 'nome' ]             := EncodeUTF8(AllTrim( (cAlias)->NOME ))
        oResponse[ 'Folgas' ][nIndex][ 'tipo colaborador' ] := AllTrim((cAlias)->TIPO_COLAB)

        getDiaFolg(cDtIni, cDtFim, @cAliasDia, (cAlias)->COLABORADOR)

        While ( cAliasDia )->(!EoF())

            // Verifique se o campo 'dias' já existe para evitar a sobrescrição
            If Empty(oResponse[ 'Folgas' ][nIndex][ 'dias' ])
                oResponse[ 'Folgas' ][nIndex][ 'dias' ] := {}
            EndIf

            // Adicione o dia ao array 'dias'
            aadd(oResponse[ 'Folgas' ][nIndex][ 'dias' ], (cAliasDia)->DIA)

            (cAliasDia)->(DbSkip())

        EndDo

        ( cAliasDia )->(DbCloseArea())

        ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim,, cTipoCol,,,,,,,,, .T., .T.)
	oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getFolga
    Query para trazer as folgas de todos os colaboradores

    @since 01/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getFolga(cDtIni as character, cDtFim as character, cAlias as character, cTipoCol as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery as object
	Local cQuery as character

    oQuery    := Nil
    cQuery    := ''

    cQuery := " SELECT GYG.GYG_CODIGO COLABORADOR, "
	cQuery +=   " GYG.GYG_NOME NOME, "
    cQuery +=   " GYG.GYG_FUNCIO MATRICULA, "
	cQuery +=   " GYG.GYG_RECCOD TIPO_COLAB "
	cQuery += " FROM " + RetSqlName('GYG') + " GYG "
    cQuery += " RIGHT JOIN " + RetSqlName('H7R') + " H7R "
    cQuery +=   " ON ( H7R.H7R_FILIAL = '" + xFilial('H7R') + "' "
    cQuery +=       " AND H7R.H7R_COLAB = GYG.GYG_CODIGO "
    cQuery +=       " AND H7R.H7R_TIPO = '4' "
    cQuery +=       " AND H7R.H7R_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
    cQuery +=       " AND H7R.D_E_L_E_T_ = '') "
    cQuery += " WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
    cQuery +=   " AND GYG.GYG_URBANO = 'T' "

    If !Empty(cTipoCol)
        cQuery +=   " AND GYG.GYG_RECCOD = '"+ALLTRIM(cTipoCol)+"' "
    EndIf

    cQuery +=   " AND GYG.D_E_L_E_T_ = '' "
    cQuery +=   " GROUP BY GYG.GYG_CODIGO, GYG.GYG_NOME, GYG.GYG_FUNCIO, GYG.GYG_RECCOD"

    cQuery += " ORDER BY GYG.GYG_CODIGO"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    //{Protheus.doc} totVeiculo
    //Query para os totalizadores dos Veículos

    //@since 01/07/2025
    //@version 1.0
//-------------------------------------------------------------------
WSMETHOD GET totVeiculo WSRECEIVE dataIni, dataFim, linha WSREST WSGTP002

    Local oResponse as character
    Local cAlias    as character
	Local cDtIni    as character
	Local cDtFim    as character
    Local cLinha    as character
    Local nIndex    as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cLinha    := Self:linha
    nIndex    := 0

    Self:SetContentType("application/json")

    getTotVeiculo(cDtIni, cDtFim, cLinha, @cAlias)

    (cAlias)->(DbGoTop())

    oResponse['totalVeiculo'] := {}

    While ( cAlias )-> (!EoF())
        nIndex++

        nQtdSemEsc := (cAlias)->QTD_SEM_ESCALA
        nQtdEmManu := (cAlias)->QTD_EM_MANUTENCAO

        aadd(oResponse[ 'totalVeiculo' ], JsonObject(): New())
        oResponse[ 'totalVeiculo' ][nIndex][ 'totalSemEscala' ]      := (cAlias)->QTD_SEM_ESCALA
        oResponse[ 'totalVeiculo' ][nIndex][ 'totalEmManutencao' ]   := (cAlias)->QTD_EM_MANUTENCAO


        ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getTotVeiculo
    Query para trazer os veículos

    @since 01/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getTotVeiculo(cDtIni as character, cDtFim as character, cLinha as character, cAlias as character)

    Local oQuery as object
	Local cQuery as character

    oQuery    := Nil
    cQuery    := ''

    cQuery := " SELECT "
    cQuery +=   " (SELECT COUNT(DISTINCT STJ1.TJ_CODBEM) "
    cQuery +=   "  FROM " + RetSqlName("STJ") + " STJ1 "
    cQuery +=   "  WHERE STJ1.TJ_FILIAL = '" + xFilial("STJ") + "' "
    cQuery +=       " AND STJ1.TJ_TIPOOS = 'B' "
    cQuery +=       " AND STJ1.TJ_TERMINO = 'N' "
    cQuery +=       " AND (('" + cDtIni + "' <= STJ1.TJ_DTMPFIM OR STJ1.TJ_DTMPFIM = '') AND '" + cDtFim + "' >= STJ1.TJ_DTMPINI) OR" //Filtro de data
	cQuery +=           " ( STJ1.TJ_DTMPINI <= '" + cDtFim + "' AND  (STJ1.TJ_DTMPFIM >= '" + cDtIni + "' OR STJ1.TJ_DTMPFIM = ''))"

    cQuery +=       " AND STJ1.D_E_L_E_T_ = '' ) AS QTD_EM_MANUTENCAO, "

    cQuery += " (SELECT COUNT(DISTINCT H70.H70_CODVEI) "
    cQuery += " FROM " + RetSqlName("H70") + " H70 "
    cQuery += " INNER JOIN " + RetSqlName('ST9') + " ST9 "
	cQuery +=   " ON (ST9.T9_FILIAL = '" + XFilial('ST9') + "' "
	cQuery +=       " AND ST9.T9_CODBEM = H70.H70_CODVEI"
	cQuery +=       " AND ST9.T9_CATBEM IN ('2', '4')"
	cQuery +=       " AND ST9.D_E_L_E_T_ = '')"
	cQuery += " WHERE H70.H70_FILIAL = '" + xFilial("H70") + "'"
	cQuery +=   " AND H70.H70_STATUS = '1'"
	cQuery +=   " AND H70.D_E_L_E_T_ = ''"
	cQuery +=   " AND NOT EXISTS ("
	cQuery +=   " SELECT 1 FROM " + RetSqlName("H7F") + " H7F "
	cQuery +=   " INNER JOIN " + RetSqlName('H7G') + " H7G "
    cQuery +=       " ON (H7G.H7G_FILIAL = '" + XFilial('H7G') + "'"
    cQuery +=           " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO "
    cQuery +=           " AND (H7G.H7G_CODH70 IS NOT NULL AND H7G.H7G_CODH70 <> '')
    cQuery +=           " AND H7G.H7G_CODH70 = H70.H70_CODVEI"
    cQuery +=           " AND H7G.D_E_L_E_T_ = '')
    cQuery +=   " WHERE H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
    cQuery +=       " AND H7F.H7F_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
    cQuery +=       " AND H7F.D_E_L_E_T_ = '')) AS QTD_SEM_ESCALA"

    oQuery := FWPreparedStatement():New(cQuery)

	cQuery := oQuery:GetFixQuery()

	cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    //{Protheus.doc} veiculoManutencao
    //Método para buscar os veiculos em manutenção.

    //@since 15/07/2025
    //@version 1.0
//-------------------------------------------------------------------
WSMETHOD GET veiculoManutencao WSRECEIVE dataIni, dataFim, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
    Local cAliasDia as character
	Local cDtIni    as character
	Local cDtFim    as character
    Local nIndex    as numeric
    Local nPage     as numeric
	Local nPageSize as numeric
	Local nOffset   as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cAliasDia := ""
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    nIndex    := 0
    nPage     := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset   := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getManutencao(cDtIni, cDtFim, @cAlias, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Veiculos'] := {}

    While ( cAlias )-> (!EoF())

        cAliasDia := GetNextAlias()

        nIndex++

        aadd(oResponse['Veiculos'], JsonObject(): New())

        oResponse[ 'Veiculos' ][nIndex][ 'pkEscala' ]      := ((cAlias)->FILIAL + (cAlias)->CODIGO)
        oResponse[ 'Veiculos' ][nIndex][ 'codigoVeiculo' ] := (cAlias)->CODIGO
        oResponse[ 'Veiculos' ][nIndex][ 'prefixo' ]       := EncodeUTF8(AllTrim( (cAlias)->PREFIXO ))
        oResponse[ 'Veiculos' ][nIndex][ 'nome' ]          := EncodeUTF8(AllTrim( (cAlias)->NOME ))

        getDiaManu(cDtIni, cDtFim, @cAliasDia, (cAlias)->CODIGO)

        While ( cAliasDia )->(!EoF())

            // Verifique se o campo 'dias' já existe para evitar a sobrescrição
            If Empty(oResponse['Veiculos'][nIndex]['dias'])
                oResponse['Veiculos'][nIndex]['dias'] := {}
            EndIf

            // Adicione o dia ao array 'dias'
            aadd(oResponse['Veiculos'][nIndex]['dias'], (cAliasDia)->DIA)

            (cAliasDia)->(DbSkip())

        EndDo

        ( cAliasDia )->(DbCloseArea())

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim,,,,,,,, .T., .T.)
    oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getManutencao
    Query para trazer detalhamento de veiculos em manutenção

    @since 01/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getManutencao(cDataIni as character, cDataFim as character, cAlias as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery as object
	Local cQuery as character

    oQuery := Nil
    cQuery := ''

    cQuery := " SELECT H70.H70_FILIAL FILIAL,"
    cQuery +=   " H70.H70_CODVEI CODIGO,"
    cQuery +=   " H70.H70_PRFVEI PREFIXO,"
    cQuery +=   " ST9.T9_NOME NOME"

    cQuery += " FROM " + RetSqlName('H70') + " H70"

	cQuery += " INNER JOIN " + RetSqlName('ST9') + " ST9 "
	cQuery +=   " ON (ST9.T9_FILIAL = '" + XFilial('ST9') + "' "
	cQuery +=       " AND ST9.T9_CODBEM = H70.H70_CODVEI"
	cQuery +=       " AND ST9.T9_CATBEM IN ('2', '4')"
	cQuery +=       " AND ST9.D_E_L_E_T_ = '')"

    cQuery += " INNER JOIN " + RetSqlName('STJ') + " STJ "
	cQuery +=   " ON (STJ.TJ_FILIAL = '" + XFilial('STJ') + "' "
	cQuery +=       " AND STJ.TJ_CODBEM = H70.H70_CODVEI"
	cQuery +=       " AND STJ.TJ_TIPOOS = 'B'"
	cQuery +=       " AND STJ.TJ_TERMINO = 'N'"
	cQuery +=       " AND STJ.D_E_L_E_T_ = ''"
	cQuery +=       " AND ("
	cQuery +=           " (STJ.TJ_DTMPINI <='" + cDataFim + "' AND (STJ.TJ_DTMPFIM >= '" + cDataIni + "' OR STJ.TJ_DTMPFIM = ''))"
	cQuery +=           " OR"
	cQuery +=           " (STJ.TJ_DTMPFIM = '' AND STJ.TJ_DTMPINI <= '" + cDataFim + "')))"

	cQuery += " WHERE H70.H70_FILIAL = '" + xFilial("H70") + "'"
	cQuery +=   " AND H70.H70_STATUS = '1'"
	cQuery +=   " AND H70.D_E_L_E_T_ = ''"

	cQuery += " GROUP BY H70.H70_FILIAL,"
	cQuery +=   " H70.H70_CODVEI,"
	cQuery +=   " H70.H70_PRFVEI,"
	cQuery +=   " ST9.T9_NOME"

	cQuery += " ORDER BY H70.H70_CODVEI"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    //{Protheus.doc} semEscala
    //Método para buscar os veiculos sem escalas (Alocação).

    //@since 15/07/2025
    //@version 1.0
//-------------------------------------------------------------------
WSMETHOD GET semEscala WSRECEIVE dataIni, dataFim, page, pageSize WSREST WSGTP002

    Local oResponse  := JsonObject():New()
    Local cAlias     := GetNextAlias()
	Local cDtIni     := Self:dataIni
	Local cDtFim     := Self:dataFim
    Local nIndex     := 0
    Local nPage      := IIF(!Empty(Self:page), Self:page, 1)
	Local nPageSize  := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
	Local nOffset    := (nPage - 1) * nPageSize

    oResponse  := JsonObject():New()
    cAlias     := GetNextAlias()
    cDtIni     := Self:dataIni
    cDtFim     := Self:dataFim
    nIndex     := 0
    nPage      := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize  := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset    := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getSemEscala(cDtIni, cDtFim, @cAlias, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Veiculos'] := {}

    While ( cAlias )-> (!EoF())

        nIndex++

        aadd(oResponse['Veiculos'], JsonObject(): New())

        oResponse[ 'Veiculos' ][nIndex][ 'pkEscala' ]      := ((cAlias)->FILIAL + (cAlias)->CODIGO)
        oResponse[ 'Veiculos' ][nIndex][ 'codigoVeiculo' ] := (cAlias)->CODIGO
        oResponse[ 'Veiculos' ][nIndex][ 'prefixo' ]       := EncodeUTF8(AllTrim( (cAlias)->PREFIXO ))
        oResponse[ 'Veiculos' ][nIndex][ 'nome' ]          := EncodeUTF8(AllTrim( (cAlias)->NOME ))

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim,,,,,,,, .T.,, .T.,)
    oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getSemEscala
    Query para trazer detalhamento de veiculos sem escala (Alocação)

    @since 01/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getSemEscala(cDataIni as character, cDataFim as character, cAlias as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery as object
	Local cQuery as character

    oQuery := Nil
    cQuery := ''

    cQuery := " SELECT H70.H70_FILIAL FILIAL,"
    cQuery +=   " H70.H70_CODVEI CODIGO,"
    cQuery +=   " H70.H70_PRFVEI PREFIXO,"
    cQuery +=   " ST9.T9_NOME NOME"

    cQuery += " FROM " + RetSqlName('H70') + " H70"

	cQuery += " INNER JOIN " + RetSqlName('ST9') + " ST9 "
	cQuery +=   " ON (ST9.T9_FILIAL = '" + XFilial('ST9') + "' "
	cQuery +=       " AND ST9.T9_CODBEM = H70.H70_CODVEI"
	cQuery +=       " AND ST9.T9_CATBEM IN ('2', '4')"
	cQuery +=       " AND ST9.D_E_L_E_T_ = '')"

    cQuery += " WHERE H70.H70_FILIAL = '" + xFilial("H70") + "'"
	cQuery +=   " AND H70.H70_STATUS = '1'"
	cQuery +=   " AND H70.D_E_L_E_T_ = ''"
	cQuery +=   " AND NOT EXISTS "
	cQuery +=   " (SELECT 1 FROM " + RetSqlName('H7F') + " H7F"
    cQuery +=   " INNER JOIN " + RetSqlName('H7G') + " H7G "
    cQuery +=       " ON (H7G.H7G_FILIAL = '" + XFilial('H7G') + "'"
    cQuery +=       " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
    cQuery +=       " AND (H7G.H7G_CODH70 IS NOT NULL"
    cQuery +=           " AND H7G.H7G_CODH70 <> '')
    cQuery +=           " AND H7G.H7G_CODH70 = H70.H70_CODVEI"
    cQuery +=           " AND H7G.D_E_L_E_T_ = '')"

    cQuery += " WHERE H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
    cQuery +=   " AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
    cQuery +=   " AND H7F.D_E_L_E_T_ = '')

	cQuery += " GROUP BY H70.H70_FILIAL,"
	cQuery +=   " H70.H70_CODVEI,"
	cQuery +=   " H70.H70_PRFVEI,"
	cQuery +=   " ST9.T9_NOME"

	cQuery += " ORDER BY H70.H70_CODVEI"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

   oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return

WSMETHOD GET feriasColab WSRECEIVE dataIni, dataFim, tipoCol, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
	Local cDtIni    as character
	Local cDtFim    as character
    Local cTipoCol  as character
    Local nIndex    as numeric
    Local nPage     as numeric
	Local nPageSize as numeric
	Local nOffset   as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cTipoCol  := Self:tipoCol
    nIndex    := 0
    nPage      := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize  := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset    := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getFerias(cDtIni, cDtFim, @cAlias, cTipoCol, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Ferias'] := {}

    While ( cAlias )-> (!EoF())
        nIndex++

        aadd(oResponse[ 'Ferias' ], JsonObject(): New())
        oResponse[ 'Ferias' ][nIndex][ 'colaborador' ]      := AllTrim( (cAlias)->COLABORADOR )
        oResponse[ 'Ferias' ][nIndex][ 'matricula' ]        := AllTrim( (cAlias)->MATRICULA )
        oResponse[ 'Ferias' ][nIndex][ 'nome' ]             := EncodeUTF8(AllTrim( (cAlias)->NOME ))
        oResponse[ 'Ferias' ][nIndex][ 'tipo colaborador' ] := AllTrim((cAlias)->TIPO_COLAB)
        oResponse[ 'Ferias' ][nIndex][ 'dataInicio' ]       := sToD((cAlias)->INICIO)
        oResponse[ 'Ferias' ][nIndex][ 'dataFim' ]          := sToD((cAlias)->FIM)

        ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim,, cTipoCol,,,,,,,,, .T.,, .T.)
    oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getFerias
    Query para trazer as ferias de todos os colaboradores

    @since 17/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getFerias(cDtIni as character, cDtFim as character, cAlias as character, cTipoCol as character, nOffset as numeric, nPageSize as numeric)

    Local cQuery    := ''
    Local oQuery    := Nil

    cQuery := " SELECT GYG.GYG_CODIGO COLABORADOR, "
	cQuery +=   " GYG.GYG_NOME NOME, "
    cQuery +=   " GYG.GYG_FUNCIO MATRICULA, "
	cQuery +=   " GYG.GYG_RECCOD TIPO_COLAB, "
	cQuery +=   " SRH.RH_DATAINI INICIO, "
	cQuery +=   " SRH.RH_DATAFIM FIM "
	cQuery += " FROM " + RetSqlName('GYG') + " GYG "
    cQuery += " RIGHT JOIN " + RetSqlName('SRH') + " SRH "
    cQuery +=   " ON ( SRH.RH_FILIAL = GYG.GYG_FILSRA  "
    cQuery +=       " AND SRH.RH_MAT = GYG.GYG_FUNCIO "
    cQuery +=       " AND (('" + cDtIni + "' <= SRH.RH_DATAFIM AND '" + cDtFim + "' >= SRH.RH_DATAINI) "
    cQuery +=                    " OR (SRH.RH_DATAINI <= '" + cDtFim + "' AND SRH.RH_DATAFIM >= '" + cDtIni + "'))"
    cQuery +=             " AND SRH.D_E_L_E_T_ = '') "
    cQuery += " WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "'"
    cQuery += "  AND GYG.GYG_URBANO = 'T' "
    If !Empty(cTipoCol)
        cQuery +=   " AND GYG.GYG_RECCOD = '"+ALLTRIM(cTipoCol)+"' "
    Endif
    cQuery +=   " AND GYG.D_E_L_E_T_ = '' "

    cQuery += " ORDER BY GYG.GYG_CODIGO"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

    oQuery := FWPreparedStatement():New(cQuery)
    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery(cQuery)

Return

WSMETHOD GET afastColab WSRECEIVE dataIni, dataFim, tipoCol, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
	Local cDtIni    as character
	Local cDtFim    as character
    Local cTipoCol  as character
    Local nIndex    as numeric
    Local nPage     as numeric
	Local nPageSize as numeric
	Local nOffset   as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cTipoCol  := Self:tipoCol
    nIndex    := 0
    nPage      := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize  := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset    := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getAfastados(cDtIni, cDtFim, @cAlias, cTipoCol, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Afastados'] := {}

    While ( cAlias )-> (!EoF())
        nIndex++

        aadd(oResponse[ 'Afastados' ], JsonObject(): New())
        oResponse[ 'Afastados' ][nIndex][ 'colaborador' ]      := AllTrim( (cAlias)->COLABORADOR )
        oResponse[ 'Afastados' ][nIndex][ 'matricula' ]      := AllTrim( (cAlias)->MATRICULA )
        oResponse[ 'Afastados' ][nIndex][ 'nome' ]             := EncodeUTF8(AllTrim( (cAlias)->NOME ))
        oResponse[ 'Afastados' ][nIndex][ 'tipo colaborador' ] := AllTrim((cAlias)->TIPO_COLAB)
        oResponse[ 'Afastados' ][nIndex][ 'dia' ]              := sToD((cAlias)->DIA)

        ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim,, cTipoCol,,,,,,,,, .T.,,,, .T.)
    oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getAfastados
    Query para trazer todos os colaboradores afastados

    @since 17/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getAfastados(cDtIni as character, cDtFim as character, cAlias as character, cTipoCol as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery    := Nil
    Local cQuery    := ''

    cQuery := " SELECT GYG.GYG_CODIGO COLABORADOR, "
	cQuery +=   " GYG.GYG_NOME NOME, "
    cQuery +=   " GYG.GYG_FUNCIO MATRICULA, "
	cQuery +=   " GYG.GYG_RECCOD TIPO_COLAB, "
	cQuery +=   " SR8.R8_DATAINI DIA "
	cQuery += " FROM " + RetSqlName('GYG') + " GYG "
    cQuery += " RIGHT JOIN " + RetSqlName('SR8') + " SR8 "
    cQuery += "   ON ( SR8.R8_FILIAL = '" + xFilial('SR8') + "' "
    cQuery += "        AND SR8.R8_MAT = GYG.GYG_FUNCIO "
    cQuery +=             " AND ((('" + cDtIni + "' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM = '') AND '" + cDtFim + "' >= SR8.R8_DATAINI) "
    cQuery +=                    " OR (SR8.R8_DATAINI <= '" + cDtFim + "' AND (SR8.R8_DATAFIM >= '" + cDtIni + "' OR SR8.R8_DATAFIM = '')))"
    cQuery +=             " AND SR8.D_E_L_E_T_ = '') "
    cQuery += " WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
    cQuery += " AND SR8.R8_DURACAO >= 15 AND SR8.R8_DATAFIM = '' "
    cQuery += "  AND GYG.GYG_URBANO = 'T' "

    If !Empty(cTipoCol)
        cQuery +=   " AND GYG.GYG_RECCOD = '"+ALLTRIM(cTipoCol)+"' "
    EndIf

    cQuery +=   " AND GYG.D_E_L_E_T_ = '' "

    cQuery += " ORDER BY GYG.GYG_CODIGO"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

    oQuery := FWPreparedStatement():New(cQuery)
    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery(cQuery)
Return

WSMETHOD GET atestColab WSRECEIVE dataIni, dataFim, tipoCol, page, pageSize WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
	Local cDtIni    as character
	Local cDtFim    as character
    Local cTipoCol  as character
    Local nIndex    as numeric
    Local nPage     as numeric
	Local nPageSize as numeric
	Local nOffset   as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cTipoCol  := Self:tipoCol
    nIndex    := 0
    nPage      := IIF(!Empty(Self:page), Self:page, 1)
    nPageSize  := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
    nOffset    := (nPage - 1) * nPageSize

    Self:SetContentType("application/json")

    getAtestados(cDtIni, cDtFim, @cAlias, cTipoCol, nOffset, nPageSize)

    (cAlias)->(DbGoTop())

    oResponse['Atestados'] := {}

    While ( cAlias )-> (!EoF())
        nIndex++

        aadd(oResponse[ 'Atestados' ], JsonObject(): New())
        oResponse[ 'Atestados' ][nIndex][ 'colaborador' ]      := AllTrim( (cAlias)->COLABORADOR )
        oResponse[ 'Atestados' ][nIndex][ 'matricula' ]        := AllTrim( (cAlias)->MATRICULA )
        oResponse[ 'Atestados' ][nIndex][ 'nome' ]             := EncodeUTF8(AllTrim( (cAlias)->NOME ))
        oResponse[ 'Atestados' ][nIndex][ 'tipo colaborador' ] := AllTrim((cAlias)->TIPO_COLAB)
        oResponse[ 'Atestados' ][nIndex][ 'dataInicio' ]       := sToD((cAlias)->INICIO)
        oResponse[ 'Atestados' ][nIndex][ 'dataFim' ]          := sToD((cAlias)->FIM)

        ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

    oResponse[ 'total' ]    := getTotal(cDtIni, cDtFim,, cTipoCol,,,,,,,,, .T.,,, .T.)
    oResponse[ 'page' ]     := nPage
	oResponse[ 'pageSize' ] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getAtestados
    Query para trazer todos os colaboradores de atestado

    @since 17/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getAtestados(cDtIni as character, cDtFim as character, cAlias as character, cTipoCol as character, nOffset as numeric, nPageSize as numeric)

    Local oQuery as object
    Local cQuery as character

    oQuery    := Nil
    cQuery    := ''

    cQuery := " SELECT GYG.GYG_CODIGO COLABORADOR, "
	cQuery +=   " GYG.GYG_NOME NOME, "
    cQuery +=   " GYG.GYG_FUNCIO MATRICULA, "
	cQuery +=   " GYG.GYG_RECCOD TIPO_COLAB, "
	cQuery +=   " SR8.R8_DATAINI INICIO, "
	cQuery +=   " SR8.R8_DATAFIM FIM "
	cQuery += " FROM " + RetSqlName('GYG') + " GYG "
    cQuery += " RIGHT JOIN " + RetSqlName('SR8') + " SR8 "
    cQuery += "   ON ( SR8.R8_FILIAL = '" + xFilial('SR8') + "' "
    cQuery += "        AND SR8.R8_MAT = GYG.GYG_FUNCIO "
    cQuery +=             " AND ((('" + cDtIni + "' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM = '') AND '" + cDtFim + "' >= SR8.R8_DATAINI) "
    cQuery +=                    " OR (SR8.R8_DATAINI <= '" + cDtFim + "' AND (SR8.R8_DATAFIM >= '" + cDtIni + "' OR SR8.R8_DATAFIM = '')))"
    cQuery +=             " AND SR8.D_E_L_E_T_ = '') "
    cQuery += " WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
    cQuery += " AND SR8.R8_DURACAO <= 14 AND SR8.R8_DATAFIM <> '' "
    cQuery += "  AND GYG.GYG_URBANO = 'T' "

    If !Empty(cTipoCol)
        cQuery +=   " AND GYG.GYG_RECCOD = '"+ALLTRIM(cTipoCol)+"' "
    EndIf

    cQuery +=   " AND GYG.D_E_L_E_T_ = '' "

    cQuery += " ORDER BY GYG.GYG_CODIGO"
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

    oQuery := FWPreparedStatement():New(cQuery)
    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery(cQuery)

Return

WSMETHOD GET totColab WSRECEIVE dataIni, dataFim, tipoCol WSREST WSGTP002

    Local oResponse as object
    Local cAlias    as character
	Local cDtIni    as character
	Local cDtFim    as character
    Local cTipoCol  as character
    Local nIndex    as numeric

    oResponse := JsonObject():New()
    cAlias    := GetNextAlias()
    cDtIni    := Self:dataIni
    cDtFim    := Self:dataFim
    cTipoCol  := Self:tipoCol
    nIndex    := 0

    Self:SetContentType("application/json")

    getTotColab(cDtIni, cDtFim, @cAlias, cTipoCol)

    (cAlias)->(DbGoTop())

    oResponse['totalColaborador'] := {}

    While ( cAlias )-> (!EoF())
        nIndex++

        aadd(oResponse[ 'totalColaborador' ], JsonObject(): New())
        oResponse[ 'totalColaborador' ][nIndex][ 'totalFolga' ]      := (cAlias)->QTD_FOLGA
        oResponse[ 'totalColaborador' ][nIndex][ 'totalFerias' ]     := (cAlias)->QTD_FERIAS
        oResponse[ 'totalColaborador' ][nIndex][ 'totalAtestado' ]   := (cAlias)->QTD_ATESTADO
        oResponse[ 'totalColaborador' ][nIndex][ 'totalAfastado' ]   := (cAlias)->QTD_AFASTADO

        ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
    /*/{Protheus.doc} getTotColab
    Query para trazer o total de todos os colaboradores afastados/atestados/férias/folga

    @since 17/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getTotColab(cDtIni as character, cDtFim as character, cAlias as character, cTipoCol as character)

    Local oQuery as object
    Local cQuery as character
    Local cTpCol as character

    oQuery := Nil
    cQuery := ''
    cTpCol := ''

    If !Empty(cTipoCol)
        cTpCol :=   " AND GYG.GYG_RECCOD = '"+ALLTRIM(cTipoCol)+"' "
    Endif

    cQuery := " SELECT  "
    cQuery += "   ( SELECT COUNT(DISTINCT GYG.GYG_CODIGO)  "
	cQuery += "     FROM " + RetSqlName('GYG') + " GYG "
    cQuery += "     RIGHT JOIN " + RetSqlName('H7R') + " H7R "
    cQuery += "         ON ( H7R.H7R_FILIAL = '" + xFilial('H7R') + "' "
    cQuery += "         AND H7R.H7R_COLAB = GYG.GYG_CODIGO "
    cQuery += "         AND H7R.H7R_TIPO = '4' "
    cQuery += "         AND H7R.H7R_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
    cQuery += "         AND H7R.D_E_L_E_T_ = '') "
    cQuery += "     WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "'"
    cQuery += "     AND GYG.GYG_URBANO = 'T' "
    cQuery +=       cTpCol
    cQuery += "     AND GYG.D_E_L_E_T_ = '' ) AS QTD_FOLGA, "

    cQuery += "   ( SELECT COUNT(DISTINCT GYG.GYG_CODIGO)  "
	cQuery += "    FROM " + RetSqlName('GYG') + " GYG "
    cQuery += "    RIGHT JOIN " + RetSqlName('SRH') + " SRH "
    cQuery += "        ON ( SRH.RH_FILIAL = GYG.GYG_FILSRA  "
    cQuery += "        AND SRH.RH_MAT = GYG.GYG_FUNCIO "
    cQuery += "        AND (('" + cDtIni + "' <= SRH.RH_DATAFIM AND '" + cDtFim + "' >= SRH.RH_DATAINI) "
    cQuery += "             OR (SRH.RH_DATAINI <= '" + cDtFim + "' AND SRH.RH_DATAFIM >= '" + cDtIni + "'))"
    cQuery += "        AND SRH.D_E_L_E_T_ = '') "
    cQuery += "    WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "'"
    cQuery += "     AND GYG.GYG_URBANO = 'T' "
    cQuery +=      cTpCol
    cQuery += "    AND GYG.D_E_L_E_T_ = '') AS QTD_FERIAS, "

    cQuery += "   ( SELECT COUNT(DISTINCT GYG.GYG_CODIGO)  "
	cQuery += "    FROM " + RetSqlName('GYG') + " GYG "
    cQuery += "    RIGHT JOIN " + RetSqlName('SR8') + " SR8 "
    cQuery += "        ON ( SR8.R8_FILIAL = '" + xFilial('SR8') + "' "
    cQuery += "        AND SR8.R8_MAT = GYG.GYG_FUNCIO "
    cQuery += "        AND ((('" + cDtIni + "' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM = '') AND '" + cDtFim + "' >= SR8.R8_DATAINI) "
    cQuery += "             OR (SR8.R8_DATAINI <= '" + cDtFim + "' AND (SR8.R8_DATAFIM >= '" + cDtIni + "' OR SR8.R8_DATAFIM = '')))"
    cQuery += "        AND SR8.D_E_L_E_T_ = '') "
    cQuery += "    WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
    cQuery += "    AND SR8.R8_DURACAO <= 14 AND SR8.R8_DATAFIM <> '' "
    cQuery += "     AND GYG.GYG_URBANO = 'T' "
    cQuery +=      cTpCol
    cQuery += "    AND GYG.D_E_L_E_T_ = '') AS QTD_ATESTADO, "

    cQuery += "   ( SELECT COUNT(DISTINCT GYG.GYG_CODIGO)  "
	cQuery += "    FROM " + RetSqlName('GYG') + " GYG "
    cQuery += "    RIGHT JOIN " + RetSqlName('SR8') + " SR8 "
    cQuery += "       ON ( SR8.R8_FILIAL = '" + xFilial('SR8') + "' "
    cQuery += "       AND SR8.R8_MAT = GYG.GYG_FUNCIO "
    cQuery += "       AND ((('" + cDtIni + "' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM = '') AND '" + cDtFim + "' >= SR8.R8_DATAINI) "
    cQuery += "            OR (SR8.R8_DATAINI <= '" + cDtFim + "' AND (SR8.R8_DATAFIM >= '" + cDtIni + "' OR SR8.R8_DATAFIM = '')))"
    cQuery += "       AND SR8.D_E_L_E_T_ = '') "
    cQuery += "    WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
    cQuery += "     AND GYG.GYG_URBANO = 'T' "
    cQuery += "    AND SR8.R8_DURACAO >= 15 AND SR8.R8_DATAFIM = '' "
    cQuery +=      cTpCol
    cQuery += "    AND GYG.D_E_L_E_T_ = '') AS QTD_AFASTADO "

    oQuery := FWPreparedStatement():New(cQuery)
    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    /*/{Protheus.doc} getTotal
    Função destinada para fazer o count de todos os veiculos, escalas e colaboradores

    @since 23/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getTotal(cDtIni, cDtFim, cLinha, cTipoCol, lEscala, lAlocada, lSemCob, lSemMoto, lSemVeic, lVeiculo, lVeicManu, lSemEscala, lColab, lFolga, lFerias, lAtestado, lAfastado)

    Local oQuery       := Nil
    Local cAlias       := GetNextAlias()
	Local cQuery       := ""
	Local cTpCol       := ""
    Local nQtd         := 0

	Default lEscala    := .F.
	Default lAlocada   := .F.
	Default lSemCob    := .F.
	Default lSemMoto   := .F.
	Default lSemVeic   := .F.

	Default lVeiculo   := .F.
	Default lVeicManu  := .F.
	Default lSemEscala := .F.

	Default lColab     := .F.
	Default lFolga     := .F.
	Default lFerias    := .F.
	Default lAtestado  := .F.
	Default lAfastado  := .F.

    If lEscala

        cQuery := " WITH CLASSIFICACAO AS ( "
        cQuery +=   " SELECT DISTINCT H7F.H7F_CODH76,"
        cQuery +=   " CASE "

        If lAlocada
            cQuery +=   " WHEN EXISTS"
            cQuery +=       " (SELECT 1 FROM " + RetSqlName('H76') + " H76 "
            cQuery +=       " INNER JOIN " + RetSqlName('H77') + " H77 "
	        cQuery +=           " ON ( H77.H77_FILIAL = '" + XFilial('H77') + "' "
	        cQuery +=               " AND H77.H77_CODH76 = H76.H76_CODIGO"

	        If !Empty(cLinha)
	            cQuery +=               " AND H77.H77_CODH6V = '" + cLinha + "'"
	        Endif

	        cQuery +=               " AND H77.D_E_L_E_T_ = '' )"

            cQuery +=       " WHERE H7F.H7F_CODH76 = H76.H76_CODIGO "
            cQuery +=       " AND H76.H76_FILIAL = '" + xFilial('H76') + "' "
            cQuery +=       " AND H76.D_E_L_E_T_ = ''"
            cQuery +=       " AND (H76.H76_QTVEIC = 0
            cQuery +=           " OR EXISTS (SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
            cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
            cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
            cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
            cQuery +=                   " AND (H7G.H7G_CODH70 IS NOT NULL)"
            cQuery +=                   " AND (H7G.H7G_CODH70 <> '')"
            cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))"

            cQuery +=       " AND (H76.H76_QTMOTO = 0
            cQuery +=           " OR EXISTS (SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
            cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
            cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
            cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
            cQuery +=                   " AND (H7G.H7G_CODGYG IS NOT NULL)"
            cQuery +=                   " AND (H7G.H7G_CODGYG <> '')"
            cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))"

            cQuery +=       " AND (H76.H76_QTCOBR = 0"
            cQuery +=           " OR EXISTS (SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
            cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
            cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
            cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
            cQuery +=                   " AND (H7G.H7G_CODCOB IS NOT NULL)"
            cQuery +=                   " AND (H7G.H7G_CODCOB <> '')"
            cQuery +=                   " AND H7G.D_E_L_E_T_ = ''))) THEN 'ALOCADO'"

        ElseIf lSemCob

            cQuery +=   " WHEN EXISTS"
            cQuery +=       " (SELECT 1 FROM " + RetSqlName('H76') + " H76 "
            cQuery +=       " INNER JOIN " + RetSqlName('H77') + " H77 "
	        cQuery +=           " ON ( H77.H77_FILIAL = '" + XFilial('H77') + "' "
	        cQuery +=               " AND H77.H77_CODH76 = H76.H76_CODIGO"

	        If !Empty(cLinha)
	            cQuery +=               " AND H77.H77_CODH6V = '" + cLinha + "'"
	        Endif

	        cQuery +=               " AND H77.D_E_L_E_T_ = '' )"

            cQuery +=       " WHERE H7F.H7F_CODH76 = H76.H76_CODIGO "
            cQuery +=           " AND H76.H76_FILIAL = '" + xFilial('H76') + "' "
            cQuery +=           " AND H76.D_E_L_E_T_ = ''"
            cQuery +=           " AND H76.H76_QTCOBR > 0
            cQuery +=           " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
            cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
            cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
            cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
            cQuery +=                   " AND (H7G.H7G_CODCOB IS NOT NULL)"
            cQuery +=                   " AND (H7G.H7G_CODCOB <> '')"
            cQuery +=                   " AND H7G.D_E_L_E_T_ = '')) THEN 'SEM_COBRADOR'"

        ElseIf lSemMoto

            cQuery +=   " WHEN EXISTS ("
            cQuery +=       " SELECT 1 FROM " + RetSqlName('H76') + " H76 "
            cQuery +=       " INNER JOIN " + RetSqlName('H77') + " H77 "
	        cQuery +=           " ON ( H77.H77_FILIAL = '" + XFilial('H77') + "' "
	        cQuery +=               " AND H77.H77_CODH76 = H76.H76_CODIGO"

	        If !Empty(cLinha)
	            cQuery +=               " AND H77.H77_CODH6V = '" + cLinha + "'"
	        Endif

	        cQuery +=               " AND H77.D_E_L_E_T_ = '' )"
            cQuery +=       " WHERE H7F.H7F_CODH76 = H76.H76_CODIGO "
            cQuery +=           " AND H76.H76_FILIAL = '" + xFilial('H76') + "' "
            cQuery +=           " AND H76.D_E_L_E_T_ = ''"
            cQuery +=           " AND H76.H76_QTMOTO > 0 "
            cQuery +=           " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
            cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
            cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
            cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
            cQuery +=                   " AND (H7G.H7G_CODGYG IS NOT NULL)"
            cQuery +=                   " AND (H7G.H7G_CODGYG <> '')"
            cQuery +=                   " AND H7G.D_E_L_E_T_ = '')) THEN 'SEM_MOTORISTA'"

        ElseIf lSemVeic
            cQuery +=   " WHEN EXISTS ("
            cQuery +=       " SELECT 1 FROM " + RetSqlName('H76') + " H76 "
            cQuery +=       " INNER JOIN " + RetSqlName('H77') + " H77 "
	        cQuery +=           " ON ( H77.H77_FILIAL = '" + XFilial('H77') + "' "
	        cQuery +=               " AND H77.H77_CODH76 = H76.H76_CODIGO"

	        If !Empty(cLinha)
	            cQuery +=               " AND H77.H77_CODH6V = '" + cLinha + "'"
	        Endif

	        cQuery +=               " AND H77.D_E_L_E_T_ = '' )"
            cQuery +=       " WHERE H7F.H7F_CODH76 = H76.H76_CODIGO "
            cQuery +=           " AND H76.H76_FILIAL = '" + xFilial('H76') + "' "
            cQuery +=           " AND H76.D_E_L_E_T_ = ''"
            cQuery +=           " AND H76.H76_QTVEIC > 0
            cQuery +=           " AND NOT EXISTS ( SELECT 1 FROM " + RetSqlName('H7G') + " H7G "
            cQuery +=               " WHERE H7G.H7G_FILIAL = '" + xFilial('H7G') + "' "
            cQuery +=                   " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
            cQuery +=                   " AND H7G.H7G_CODH76 = H76.H76_CODIGO"
            cQuery +=                   " AND (H7G.H7G_CODH70 IS NOT NULL)"
            cQuery +=                   " AND (H7G.H7G_CODH70 <> '')"
            cQuery +=                   " AND H7G.D_E_L_E_T_ = '')) THEN 'SEM_VEICULO'"

        EndIf

        cQuery +=           " END AS CLASSIFICACAO"

        cQuery +=         " FROM " + RetSqlName('H7F') + " H7F "
        cQuery +=         " WHERE H7F.H7F_FILIAL = '" + xFilial('H7F') + "' "
        cQuery +=               " AND H7F.H7F_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' "
        cQuery +=               " AND H7F.D_E_L_E_T_ = '')"

        cQuery +=         " SELECT "
        cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'ALOCADO' THEN 1 END) AS QTD_ALOCADO, "
        cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'SEM_COBRADOR' THEN 1 END) AS QTD_SEM_COBRADOR,"
        cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'SEM_MOTORISTA' THEN 1 END) AS QTD_SEM_MOTORISTA,"
        cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'SEM_VEICULO' THEN 1 END) AS QTD_SEM_VEICULO, "
        cQuery +=           " COUNT(CASE WHEN CLASSIFICACAO = 'NAO_ALOCADO' THEN 1 END) AS QTD_NAO_ALOCADO "
        cQuery +=         " FROM CLASSIFICACAO; "

    ElseIf lVeiculo

        cQuery := " SELECT "

        If lVeicManu

            cQuery +=   " (SELECT COUNT(DISTINCT STJ1.TJ_CODBEM) "
            cQuery +=   "  FROM " + RetSqlName("STJ") + " STJ1 "
            cQuery +=   "  WHERE STJ1.TJ_FILIAL = '" + xFilial("STJ") + "' "
            cQuery +=       " AND STJ1.TJ_TIPOOS = 'B' "
            cQuery +=       " AND STJ1.TJ_TERMINO = 'N' "
            cQuery +=       " AND (('" + cDtIni + "' <= STJ1.TJ_DTMPFIM OR STJ1.TJ_DTMPFIM = '') AND '" + cDtFim + "' >= STJ1.TJ_DTMPINI) OR" //Filtro de data
	        cQuery +=           " ( STJ1.TJ_DTMPINI <= '" + cDtFim + "' AND  (STJ1.TJ_DTMPFIM >= '" + cDtIni + "' OR STJ1.TJ_DTMPFIM = ''))"

            cQuery +=       " AND STJ1.D_E_L_E_T_ = '' ) AS QTD_EM_MANUTENCAO "

        ElseIf lSemEscala

            cQuery += " (SELECT COUNT(DISTINCT H70.H70_CODVEI) "
            cQuery += " FROM " + RetSqlName("H70") + " H70 "
            cQuery += " INNER JOIN " + RetSqlName('ST9') + " ST9 "
	        cQuery +=   " ON (ST9.T9_FILIAL = '" + XFilial('ST9') + "' "
	        cQuery +=       " AND ST9.T9_CODBEM = H70.H70_CODVEI"
	        cQuery +=       " AND ST9.T9_CATBEM IN ('2', '4')"
	        cQuery +=       " AND ST9.D_E_L_E_T_ = '')"
	        cQuery += " WHERE H70.H70_FILIAL = '" + xFilial("H70") + "'"
	        cQuery +=   " AND H70.H70_STATUS = '1'"
	        cQuery +=   " AND H70.D_E_L_E_T_ = ''"
	        cQuery +=   " AND NOT EXISTS ("
	        cQuery +=   " SELECT 1 FROM " + RetSqlName("H7F") + " H7F "
	        cQuery +=   " INNER JOIN " + RetSqlName('H7G') + " H7G "
            cQuery +=       " ON (H7G.H7G_FILIAL = '" + XFilial('H7G') + "'"
            cQuery +=           " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO "
            cQuery +=           " AND (H7G.H7G_CODH70 IS NOT NULL AND H7G.H7G_CODH70 <> '')
            cQuery +=           " AND H7G.H7G_CODH70 = H70.H70_CODVEI"
            cQuery +=           " AND H7G.D_E_L_E_T_ = '')
            cQuery +=   " WHERE H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
            cQuery +=       " AND H7F.H7F_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
            cQuery +=       " AND H7F.D_E_L_E_T_ = '')) AS QTD_SEM_ESCALA"
        EndIf

    ElseIf lColab

        If !Empty(cTipoCol)
            cTpCol :=   " AND GYG.GYG_RECCOD = '"+ALLTRIM(cTipoCol)+"' "
        EndIf

        cQuery := " SELECT  "

        If lFolga

            cQuery += "   ( SELECT COUNT(DISTINCT GYG.GYG_CODIGO)  "
	        cQuery += "     FROM " + RetSqlName('GYG') + " GYG "
            cQuery += "     RIGHT JOIN " + RetSqlName('H7R') + " H7R "
            cQuery += "         ON ( H7R.H7R_FILIAL = '" + xFilial('H7R') + "' "
            cQuery += "         AND H7R.H7R_COLAB = GYG.GYG_CODIGO "
            cQuery += "         AND H7R.H7R_TIPO = '4' "
            cQuery += "         AND H7R.H7R_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
            cQuery += "         AND H7R.D_E_L_E_T_ = '') "
            cQuery += "     WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "'"
            cQuery += "     AND GYG.GYG_URBANO = 'T' "
            cQuery +=       cTpCol
            cQuery += "     AND GYG.D_E_L_E_T_ = '' ) AS QTD_FOLGA "

        ElseIf lFerias

            cQuery += "   ( SELECT COUNT(DISTINCT GYG.GYG_CODIGO)  "
	        cQuery += "    FROM " + RetSqlName('GYG') + " GYG "
            cQuery += "    RIGHT JOIN " + RetSqlName('SRH') + " SRH "
            cQuery += "        ON ( SRH.RH_FILIAL = GYG.GYG_FILSRA  "
            cQuery += "        AND SRH.RH_MAT = GYG.GYG_FUNCIO "
            cQuery += "        AND (('" + cDtIni + "' <= SRH.RH_DATAFIM AND '" + cDtFim + "' >= SRH.RH_DATAINI) "
            cQuery += "             OR (SRH.RH_DATAINI <= '" + cDtFim + "' AND SRH.RH_DATAFIM >= '" + cDtIni + "'))"
            cQuery += "        AND SRH.D_E_L_E_T_ = '') "
            cQuery += "    WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "'"
            cQuery += "     AND GYG.GYG_URBANO = 'T' "
            cQuery +=      cTpCol
            cQuery += "    AND GYG.D_E_L_E_T_ = '') AS QTD_FERIAS "

        ElseIf lAtestado

            cQuery += "   ( SELECT COUNT(DISTINCT GYG.GYG_CODIGO)  "
	        cQuery += "    FROM " + RetSqlName('GYG') + " GYG "
            cQuery += "    RIGHT JOIN " + RetSqlName('SR8') + " SR8 "
            cQuery += "        ON ( SR8.R8_FILIAL = '" + xFilial('SR8') + "' "
            cQuery += "        AND SR8.R8_MAT = GYG.GYG_FUNCIO "
            cQuery += "        AND ((('" + cDtIni + "' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM = '') AND '" + cDtFim + "' >= SR8.R8_DATAINI) "
            cQuery += "             OR (SR8.R8_DATAINI <= '" + cDtFim + "' AND (SR8.R8_DATAFIM >= '" + cDtIni + "' OR SR8.R8_DATAFIM = '')))"
            cQuery += "        AND SR8.D_E_L_E_T_ = '') "
            cQuery += "    WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
            cQuery += "    AND SR8.R8_DURACAO <= 14 AND SR8.R8_DATAFIM <> '' "
            cQuery += "     AND GYG.GYG_URBANO = 'T' "
            cQuery +=      cTpCol
            cQuery += "    AND GYG.D_E_L_E_T_ = '') AS QTD_ATESTADO "

        ElseIf lAfastado

            cQuery += "   ( SELECT COUNT(DISTINCT GYG.GYG_CODIGO)  "
	        cQuery += "    FROM " + RetSqlName('GYG') + " GYG "
            cQuery += "    RIGHT JOIN " + RetSqlName('SR8') + " SR8 "
            cQuery += "       ON ( SR8.R8_FILIAL = '" + xFilial('SR8') + "' "
            cQuery += "       AND SR8.R8_MAT = GYG.GYG_FUNCIO "
            cQuery += "       AND ((('" + cDtIni + "' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM = '') AND '" + cDtFim + "' >= SR8.R8_DATAINI) "
            cQuery += "            OR (SR8.R8_DATAINI <= '" + cDtFim + "' AND (SR8.R8_DATAFIM >= '" + cDtIni + "' OR SR8.R8_DATAFIM = '')))"
            cQuery += "       AND SR8.D_E_L_E_T_ = '') "
            cQuery += "    WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
            cQuery += "     AND GYG.GYG_URBANO = 'T' "
            cQuery += "    AND SR8.R8_DURACAO >= 15 AND SR8.R8_DATAFIM = '' "
            cQuery +=      cTpCol
            cQuery += "    AND GYG.D_E_L_E_T_ = '') AS QTD_AFASTADO "
        EndIf
    EndIf

    oQuery := FWPreparedStatement():New(cQuery)
    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery(cQuery)

    (cAlias)->(DbGoTop())

    If (cAlias)->(!EoF())

        If lEscala
            If lAlocada
                nQtd := (cAlias)->QTD_ALOCADO
            ElseIf lSemVeic
                nQtd := (cAlias)->QTD_SEM_VEICULO
            ElseIf lSemMoto
                nQtd := (cAlias)->QTD_SEM_MOTORISTA
            ElseIf lSemCob
                nQtd := (cAlias)->QTD_SEM_COBRADOR
            EndIf

        ElseIf lVeiculo
            If lSemEscala
                nQtd := (cAlias)->QTD_SEM_ESCALA
            ElseIf lVeicManu
                nQtd := (cAlias)->QTD_EM_MANUTENCAO
            EndIf

        ElseIf lColab
            If lFolga
                nQtd := (cAlias)->QTD_FOLGA
            ElseIf lFerias
                nQtd := (cAlias)->QTD_FERIAS
            ElseIf lAtestado
                nQtd := (cAlias)->QTD_ATESTADO
            ElseIf lAfastado
                nQtd := (cAlias)->QTD_AFASTADO
            EndIf

        EndIf

    EndIf

    ( cAlias )->(DbCloseArea())

Return nQtd

//-------------------------------------------------------------------
    /*/{Protheus.doc} getDiaAloc
    Função destinada para trazer os dias alocados de cada escala

    @since 23/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getDiaAloc(cDtIni as character, cDtFim as character, cAliasDia as character, cCodEscala as character)

    Local oQuery as object
    Local cQuery as character

    oQuery    := Nil
    cQuery    := ''

    cQuery := " SELECT H7F.H7F_DATA DIA"
    cQuery += " FROM " + RetSqlName('H7F') + " H7F "
    cQuery += " WHERE  H7F_FILIAL = '" + xFilial("H7F") + "'"
    cQuery +=   " AND H7F_DATA BETWEEN '" + cDtIni + "' AND '" +  cDtFim +"'"

    If !Empty(cCodEscala)
        cQuery += " AND H7F.H7F_CODH76 = '" + cCodEscala + "'"
    EndIf

    cQuery +=   " AND H7F.D_E_L_E_T_ = ''"

    cQuery += " GROUP BY H7F_DATA"

    oQuery := FWPreparedStatement():New(cQuery)
    cQuery := oQuery:GetFixQuery()
    cAliasDia := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    /*/{Protheus.doc} getDiaFolg
    Função destinada para trazer os dias de folga dos colaboradores
    @since 25/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getDiaFolg(cDtIni as character, cDtFim as character, cAliasDia as character, cCodColab as character)

    Local oQuery as object
    Local cQuery as character

    oQuery    := Nil
    cQuery    := ''

    cQuery := " SELECT H7R.H7R_DATA DIA"
    cQuery += " FROM " + RetSqlName('H7R') + " H7R "
    cQuery += " WHERE H7R.H7R_FILIAL = '" + xFilial('H7R') + "' "
    cQuery += " AND H7R.H7R_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
    cQuery += " AND H7R.H7R_TIPO = '4'"

    If !Empty(cCodColab)
        cQuery += " AND H7R.H7R_COLAB = '" + cCodColab + "'"
    EndIf

    cQuery += " AND H7R.D_E_L_E_T_ = ''	"
    cQuery += " GROUP BY H7R.H7R_DATA"

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAliasDia := MPSysOpenQuery(cQuery)

Return

//-------------------------------------------------------------------
    /*/{Protheus.doc} getDiaManu
    Função destinada para trazer os dias de folga dos colaboradores
    @since 25/07/2025
    @version 1.0

    /*/
//-------------------------------------------------------------------
Static function getDiaManu(cDtIni as character, cDtFim as character, cAliasDia as character, cCodVeic as character)

    Local oQuery as object
    Local cQuery as character

    oQuery    := Nil
    cQuery    := ''

    cQuery := " SELECT STJ.TJ_DTORIGI DIA"
    cQuery += " FROM " + RetSqlName('STJ') + " STJ "
    cQuery += " WHERE STJ.TJ_FILIAL = '" + xFilial('STJ') + "' "
    cQuery +=   " AND STJ.TJ_TIPOOS = 'B'"
    cQuery +=   " AND STJ.TJ_TERMINO = 'N'"

    If !Empty(cCodVeic)
        cQuery += " AND STJ.TJ_CODBEM = '" + cCodVeic + "'"
    EndIf

    cQuery += " AND STJ.D_E_L_E_T_ = ''"
    cQuery += " AND ("
	cQuery +=   " (STJ.TJ_DTMPINI <='" + cDtFim + "' AND (STJ.TJ_DTMPFIM >= '" + cDtIni + "' OR STJ.TJ_DTMPFIM = ''))"
	cQuery +=       " OR"
	cQuery +=       " (STJ.TJ_DTMPFIM = '' AND STJ.TJ_DTMPINI <= '" + cDtFim + "'))"

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAliasDia := MPSysOpenQuery(cQuery)

Return
