#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
    /*/{Protheus.doc} WSGTP002

    API RESTful PARA TELA DE CADASTROS

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
WSRESTFUL WSGTP003 DESCRIPTION "API REST para integração com o sistema Urbano facilitando as consultas na tela de cadastro"

	WSDATA page     as INTEGER OPTIONAL
	WSDATA pageSize as INTEGER OPTIONAL
    WSDATA filter   as String OPTIONAL

    WSMETHOD GET filtroSTJ;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver ";
        PATH "filtroSTJ" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP003/filtroSTJ/?&{filter}";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
    //{Protheus.doc} totEscala
    //Query para os totalizadores das escalas

    //@since 15/07/2025
    //@version 1.0
//-------------------------------------------------------------------

WSMETHOD GET filtroSTJ WSRECEIVE filter WSREST WSGTP003  

    Local oResponse := JsonObject():New()
    Local cAlias    := GetNextAlias()
    Local cSit      := ""
    Local nIndex    := 0

    Self:SetContentType("application/json")

    getTotSTJ(@cAlias)

    (cAlias)->(DbGoTop())

    oResponse['totalOrdemServico'] := {}

    While ( cAlias )-> (!EoF())
        nIndex++

        If ( cAlias )->TJ_TERMINO == "N" 
            cSit := "Em Manutencao"
        ElseIf ( cAlias )->TJ_TERMINO == "S" 
            cSit := "Manutencao Finalizada"
        EndIf

        aadd(oResponse[ 'totalOrdemServico' ], JsonObject(): New())
        oResponse[ 'totalOrdemServico' ][nIndex][ 'codigoVeiculo' ]  := (cAlias)->TJ_CODBEM
        oResponse[ 'totalOrdemServico' ][nIndex][ 'ordemServico' ]   := (cAlias)->TJ_ORDEM
        oResponse[ 'totalOrdemServico' ][nIndex][ 'Situacao' ] := cSit
        oResponse[ 'totalOrdemServico' ][nIndex][ 'dataInicioManutencao' ] := (cAlias)->TJ_DTMPINI
        oResponse[ 'totalOrdemServico' ][nIndex][ 'dataFinalManutencao' ]  := (cAlias)->TJ_DTMPFIM

        ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

Static Function getTotSTJ(cAlias)

    Local oQuery := Nil
	Local cQuery := ''

    Default cAlias := ""

    cQuery := " SELECT STJ.TJ_CODBEM, "
    cQuery +=        " STJ.TJ_ORDEM,  "
	cQuery +=        " STJ.TJ_SITUACA,"
	cQuery +=        " STJ.TJ_DTMPINI,"
	cQuery +=        " STJ.TJ_DTMPFIM,"
    cQuery +=        " STJ.TJ_TERMINO,"
    cQuery +=        " STJ.TJ_DTPRINI,"
    cQuery +=        " STJ.TJ_DTPRFIM "
    cQuery += " FROM " + RetSqlName('STJ') + " STJ "
    cQuery += " WHERE STJ.TJ_FILIAL = '" + xFilial('STJ') + "' "
	cQuery +=       " AND STJ.TJ_TIPOOS = 'B' "
    cQuery +=       " AND STJ.TJ_SITUACA <> 'C' "
    cQuery +=       " AND STJ.D_E_L_E_T_ = '' "

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return 
