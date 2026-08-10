#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------  
/*/{Protheus.doc} WSGTP000

    API RESTful para Impressão de Relatórios

    Esta API fornece serviços para consultas voltadas à geração de relatórios, 
    facilitando a integração com aplicações externas via PO UI.

    @Autor
        - Desenvolvedor: Silas Gomes
        - Data de Criação: 13/03/2025 

    @Observações  
        - Todos os endpoints seguem o padrão RESTful.  
        - As respostas são estruturadas em JSON para facilitar a integração.  
        - Os parâmetros são opcionais e permitem filtragem dos resultados conforme necessidade.
/*/  
//------------------------------------------------------------------------------  

WSRESTFUL WSGTP000 DESCRIPTION "API REST para integração com o sistema Urbano"

    // Definição dos dados aceitos na API
    WSDATA dataIni         as String OPTIONAL // Data inicial do período de consulta
    WSDATA dataFim         as String OPTIONAL // Data final do período de consulta
    WSDATA tipoPagamento   as String OPTIONAL // Tipo de pagamento a ser consultado
    WSDATA statusPrestacao as String OPTIONAL // Status da prestação a ser filtrado
    WSDATA prefixoVei as String OPTIONAL // Status da prestação a ser filtrado

    WSMETHOD GET tipoDePagamento;
        DESCRIPTION "Consulta os dados de tipos de pagamento para geração de relatórios.";
        PATH "tipoDePagamento";
        WSSYNTAX "WSGTP000/tipoDePagamento/?{dataIni}{dataFim}{tipoPagamento}{statusPrestacao}";
        PRODUCES APPLICATION_JSON
    
    WSMETHOD GET divergenciaDeRoleta;
        DESCRIPTION "Consulta os dados de divergência de roleta para geração de relatórios.";
        PATH "divergenciaDeRoleta";
        WSSYNTAX "WSGTP000/divergenciaDeRoleta/?{dataIni}{dataFim}{prefixoVei}";
        PRODUCES APPLICATION_JSON


END WSRESTFUL

//-------------------------------------------------------------------  
/*/{Protheus.doc}

    Consulta para Impressão de Relatório – Tipo de Pagamento  

    Este método permite a consulta e filtragem de informações sobre tipos de pagamento,  
    possibilitando a geração de relatórios personalizados conforme os critérios especificados.  

    @Parâmetros  
        - dataIni (String, Opcional) ? Data inicial do período da consulta.  
        - dataFim (String, Opcional) ? Data final do período da consulta.  
        - tipoPagamento (String, Opcional) ? Tipo de pagamento a ser consultado.  
        - statusPrestacao (String, Opcional) ? Status da prestação do pagamento.

    @Retorno  
        - Os dados serão retornados no formato JSON, contendo as informações filtradas conforme os parâmetros fornecidos.

    @Exemplo de Resposta 
        "resultado": [  
            {  
                "filial": "001",  
                "dataInicio": "2025-01-01",  
                "dataFim": "2025-01-31",  
                "codigoLinha": "1001",  
                "prefixoLinha": "EXP",  
                "linha": "Linha Centro",  
                "tipoPagamento": "Cartão",  
                "formaPagamento": "Crédito",  
                "total": 12500.50,  
                "tarifa": 4.50,  
                "ocupacao": 2780  
            }  
        ]     

    @Observações
        - Se nenhum parâmetro for informado, o retorno incluirá todos os registros disponíveis.
        - Os filtros podem ser combinados para obter resultados mais específicos.
        - Os valores monetários são representados em reais (BRL).

    @Autor  
        - Desenvolvedor: Silas Gomes  
        - Data de Criação: 13/03/2025
/*/  
//-------------------------------------------------------------------
WSMETHOD GET tipoDePagamento WSRECEIVE dataIni, dataFim, tipoPagamento, statusPrestacao WSREST WSGTP000

    Local cAlias       as character
    Local cQuery       as character
    Local cDataIni     as character
    Local cDataFim     as character
    Local cTpPagamento as character
    Local cStatusPrest as character
    Local oResultado   as object
    Local oQuery       as object
    Local nIndex       as numeric

    cAlias       := ""
    cQuery       := ""
    cDataIni     := self:dataIni
    cDataFim     := self:dataFim
    cTpPagamento := self:tipoPagamento
    cStatusPrest := self:statusPrestacao
    oResultado   := JsonObject():New()
    oQuery       := Nil
    nIndex       := 0

    Default     cTpPagamento := ""
    Default     cStatusPrest := ""

    cQuery := " SELECT "
    cQuery +=   " H7J.H7J_FILIAL FILIAL, "
    cQuery +=   " H7I.H7I_STATUS STATUS, "
    cQuery +=   " H7J.H7J_DATAIS DATAINI, "
    cQuery +=   " H7J.H7J_DATATS DATATERM, "
    cQuery +=   " H6V.H6V_CODLIN CODLIN, "
    cQuery +=   " H6V.H6V_PREFIX PRFXLIN, "
    cQuery +=   " H6V.H6V_DESCRI LINHA, "
    cQuery +=   " H7L.H7L_TPAGAM TPPAG,"
    cQuery +=   " COALESCE(H6R.H6R_DESCRI, 'Não Informado') FORMPAG, "
    cQuery +=   " CAST(SUM(H7L.H7L_VLRTOT) AS DECIMAL(10,2)) TOTAL, "
    cQuery +=   " CAST(SUM(H7L.H7L_VLRUNI*H7L.H7L_NUMPAS) AS DECIMAL(10,2)) TARIFA, "
    cQuery +=   " SUM(H7L.H7L_NUMPAS) OCUPACAO "
    cQuery += " FROM ? H7L "
    cQuery +=   " INNER JOIN ? H7I "
    cQuery +=       " ON H7I.H7I_FILIAL = ? "
    cQuery +=       " AND H7I.H7I_CODIGO = H7L.H7L_CODIGO "   
    If !Empty(cStatusPrest)
        cQuery +=       " AND H7I.H7I_STATUS IN ('" + STRTRAN(cStatusPrest,",","','") + "') "
    EndIf
    cQuery +=       " AND H7I.D_E_L_E_T_ = '' "
    cQuery +=   " INNER JOIN ? H7J "
    cQuery +=       " ON H7J.H7J_FILIAL = ? "
    cQuery +=       " AND H7J.H7J_CODIGO = H7L.H7L_CODIGO "
    cQuery +=       " AND H7J.H7J_SERVIC =  H7L.H7L_SERVIC "
    cQuery +=       " AND H7J.H7J_DATAIS BETWEEN ? AND ? "
    cQuery +=       " AND H7J.D_E_L_E_T_ = '' "
    cQuery +=   " LEFT JOIN ? H6V "
    cQuery +=       " ON H6V.H6V_FILIAL = ? "
    cQuery +=       " AND H6V.H6V_CODIGO = H7J.H7J_CODH6V "
    cQuery +=       " AND H6V.D_E_L_E_T_ = '' "
    cQuery +=   " LEFT JOIN ? H6R "
    cQuery +=       " ON H6R.H6R_FILIAL = ? "
    cQuery +=       " AND H6R.H6R_CODIGO = H7L.H7L_TPAGAM "
    cQuery +=       " AND H6R.D_E_L_E_T_ = '' "
    cQuery += " WHERE H7L.H7L_FILIAL = ? "
    If !Empty(cTpPagamento)
        cQuery +=   " AND H7L.H7L_TPAGAM IN ('" + STRTRAN(cTpPagamento,",","','") + "') "
    EndIf
    cQuery +=   " AND H7L.D_E_L_E_T_ = '' "    
    cQuery += " GROUP BY H7J.H7J_FILIAL, H7I.H7I_STATUS, H7J.H7J_DATAIS, H7J.H7J_DATATS, H6V.H6V_CODLIN, H6V.H6V_PREFIX, H6V.H6V_DESCRI, H7L.H7L_TPAGAM, H6R.H6R_DESCRI "


    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetUnsafe(1, RetSqlName("H7L"))
    oQuery:SetUnsafe(2, RetSqlName("H7I"))
    oQuery:SetString(3, xFilial('H7I'))    
    oQuery:SetUnsafe(4, RetSqlName("H7J"))
    oQuery:SetString(5, xFilial("H7J"))
    oQuery:SetString(6, cDataIni)
    oQuery:SetString(7, cDataFim)
    oQuery:SetUnsafe(8, RetSqlName("H6V"))
    oQuery:SetString(9, xFilial("H6V"))
    oQuery:SetUnsafe(10, RetSqlName("H6R"))
    oQuery:SetString(11, xFilial("H6R"))
    oQuery:SetString(12, xFilial("H7L"))

    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery( cQuery )

    (cAlias)->(DbGoTop())

    Self:SetContentType("application/json")

    oResultado['Resultado'] := {}

    While (cAlias)-> (!EoF())
        
        nIndex++

        aadd(oResultado['Resultado'], JsonObject(): New())

        oResultado[ 'Resultado' ][nIndex][ 'filial' ]          := AllTrim( (cAlias)->FILIAL )
        oResultado[ 'Resultado' ][nIndex][ 'status' ]          := AllTrim( (cAlias)->STATUS )
        oResultado[ 'Resultado' ][nIndex][ 'data inicio' ]     := AllTrim( (cAlias)->DATAINI )
        oResultado[ 'Resultado' ][nIndex][ 'data fim' ]        := AllTrim( (cAlias)->DATATERM )
        oResultado[ 'Resultado' ][nIndex][ 'codigo linha' ]    := AllTrim( (cAlias)->CODLIN )
        oResultado[ 'Resultado' ][nIndex][ 'prefixo linha' ]   := AllTrim( (cAlias)->PRFXLIN )
        oResultado[ 'Resultado' ][nIndex][ 'linha' ]           := AllTrim( (cAlias)->LINHA )
        oResultado[ 'Resultado' ][nIndex][ 'tipo pagamento' ]  := AllTrim( (cAlias)->TPPAG )
        oResultado[ 'Resultado' ][nIndex][ 'forma pagamento' ] := AllTrim( (cAlias)->FORMPAG )
        oResultado[ 'Resultado' ][nIndex][ 'total' ]           := (cAlias)->TOTAL 
        oResultado[ 'Resultado' ][nIndex][ 'tarifa' ]          := (cAlias)->TARIFA 
        oResultado[ 'Resultado' ][nIndex][ 'ocupacao' ]        := (cAlias)->OCUPACAO 

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

    self:SetResponse(oResultado:toJson())
    oResultado:fromJson("{}")
    oResultado := Nil

Return .T.

//-------------------------------------------------------------------  
/*/{Protheus.doc}

    Consulta para Impressão de Relatório – Divergência de roleta

    Este método permite a consulta e filtragem de informações sobre a roleta,  
    possibilitando a geração de relatórios personalizados conforme os critérios especificados.  

    @Parâmetros  
        - dataIni (String, Opcional) ? Data inicial do período da consulta.  
        - dataFim (String, Opcional) ? Data final do período da consulta.  
        - prefixoVei (String, Opcional) ? Prefixo do veículo a ser consultado.  
        

    @Retorno  
        - Os dados serão retornados no formato JSON, contendo as informações filtradas conforme os parâmetros fornecidos.

    @Exemplo de Resposta 
        "resultado": [  
            {  
                "prefixoVeiculo": "10001           ",
			    "dataServico": "20250311",
			    "horaInicial": "1220  ",
			    "horaFinal": "1940  ",
			    "turno": 0,
			    "codLinha": "S13            ",
			    "nomeLinha": "FRADE X T. CENTRAL",
			    "filipeta": "962288J",
			    "roletaInical": 1581,
			    "roletaFinal": 2081,
			    "diferenca": 500
            }  
        ]     

    @Observações
        - Se nenhum parâmetro for informado, o retorno incluirá todos os registros disponíveis.
        - Os filtros podem ser combinados para obter resultados mais específicos.
        - Os valores monetários são representados em reais (BRL).

    @Autor  
        - Desenvolvedor: Karyna Martins 
        - Data de Criação: 31/03/2025
/*/  
//-------------------------------------------------------------------
WSMETHOD GET divergenciaDeRoleta WSRECEIVE dataIni, dataFim, prefixoVei WSREST WSGTP000

    Local cAlias       as character
    Local cQuery       as character
    Local cDataIni     as character
    Local cDataFim     as character
    Local cprefixoVei  as character
    Local oResultado   as object
    Local oQuery       as object
    Local nIndex       as numeric

    Local nUltRolF  := 0
    Local cVeiculo  := ""
    Local cFilipeta := ""


    cAlias       := ""
    cQuery       := ""
    cDataIni     := self:dataIni
    cDataFim     := self:dataFim
    cprefixoVei  := self:prefixoVei
    oResultado   := JsonObject():New()
    oQuery       := Nil
    nIndex       := 0

    Default cprefixoVei := ""
    
    cQuery := " SELECT H7J.H7J_VEICUL VEICULO, "
	cQuery +=   " H70.H70_PRFVEI PREFIXO, "
	cQuery +=   " GYG.GYG_FUNCIO MATRICULA, "
	cQuery +=   " GYG.GYG_NOME COLABORADOR, "
	cQuery +=   " H7J.H7J_DATAIS DATA, "
	cQuery +=   " H7J.H7J_HRRINI HORA_INICIAL, "
	cQuery +=   " H7J.H7J_HRRFIN HORA_FINAL, "
	cQuery +=   " H7J.H7J_TURNO TURNO, "
	cQuery +=   " H6V_CODLIN COD_LINHA, "
	cQuery +=   " H6V_DESCRI NOME_LINHA, "
	cQuery +=   " H7I.H7I_COLETA FILIPETA, "
	cQuery +=   " H7K.H7K_ROLENT ROLETA_INICIAL, "
	cQuery +=   " H7K.H7K_ROLSAI ROLETA_FINAL, "
	cQuery +=   " H7K.H7K_ROLSAI-H7K.H7K_ROLENT DIFERENCA "
    cQuery += " FROM ? H7K "
    cQuery +=   " INNER JOIN ? H7J "
    cQuery +=       " ON H7J.H7J_FILIAL = ? "
    cQuery +=         " AND H7J.H7J_CODIGO = H7K.H7K_CODIGO "     
	cQuery +=         " AND H7J.H7J_SERVIC = H7K.H7K_SERVIC "

    If !Empty(cprefixoVei)
	    cQuery +=     " AND H7J.H7J_VEICUL = '" + cprefixoVei + "'"
    EndIf

    cQuery +=         " AND H7J.D_E_L_E_T_ = '' "
    cQuery +=   " INNER JOIN ? H7I "
    cQuery +=       " ON H7I.H7I_FILIAL = ? "
    cQuery +=         " AND H7I.H7I_CODIGO = H7J.H7J_CODIGO "
    cQuery +=         " AND H7I.H7I_DTSERV BETWEEN ? AND ? "
    cQuery +=         " AND H7I.D_E_L_E_T_ = '' "
    cQuery +=   " LEFT JOIN ? H6V "
    cQuery +=       " ON H6V.H6V_FILIAL =  ? "
    cQuery +=         " AND H6V.H6V_CODIGO = H7J.H7J_CODH6V "
    cQuery +=         " AND H6V.D_E_L_E_T_ = '' "
    cQuery +=   " LEFT JOIN ? H70 "
    cQuery +=       " ON H70.H70_FILIAL = ? "
    cQuery +=         " AND H70.H70_CODVEI = H7J.H7J_VEICUL "
    cQuery +=         " AND H70.D_E_L_E_T_ = '' "
    cQuery += "  LEFT JOIN ? GYG "
    cQuery +=       " ON GYG.GYG_FILIAL = ? "
    cQuery +=       " AND GYG.GYG_CODIGO = H7I.H7I_MOTORI "
    cQuery +=       " AND GYG.D_E_L_E_T_ = '' "
    cQuery +=   " WHERE H7K.H7K_FILIAL = ? "
    cQuery +=         " AND H7K.D_E_L_E_T_ = '' "
    cQuery +=   " ORDER BY H7J.H7J_VEICUL, H7J.H7J_DATAIS, H7J.H7J_HRRINI  " 
  
    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetUnsafe(1, RetSqlName("H7K"))
    oQuery:SetUnsafe(2, RetSqlName("H7J"))
    oQuery:SetString(3, xFilial("H7J"))
    oQuery:SetUnsafe(4, RetSqlName("H7I")) 
    oQuery:SetString(5, xFilial("H7I")) 
    oQuery:SetString(6, cDataIni)
    oQuery:SetString(7, cDataFim)   
    oQuery:SetUnsafe(8, RetSqlName("H6V"))
    oQuery:SetString(9, xFilial("H6V"))
    oQuery:SetUnsafe(10, RetSqlName("H70"))
    oQuery:SetString(11, xFilial("H70"))
    oQuery:SetUnsafe(12, RetSqlName("GYG"))
    oQuery:SetString(13, xFilial("GYG"))
    oQuery:SetString(14, xFilial("H7K"))    

    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery( cQuery )

    (cAlias)->(DbGoTop())

    Self:SetContentType("application/json")

    oResultado['Resultado'] := {}

    While (cAlias)-> (!EoF())

        If cVeiculo == (cAlias)->VEICULO

            If nUltRolF <> (cAlias)->ROLETA_INICIAL .And. (cAlias)->ROLETA_INICIAL > nUltRolF
      
                nDiferenca := (cAlias)->ROLETA_INICIAL - nUltRolF

                nIndex++

                aadd(oResultado['Resultado'], JsonObject(): New())

                oResultado[ 'Resultado' ][nIndex][ 'veiculo' ]              := (cAlias)->VEICULO
                oResultado[ 'Resultado' ][nIndex][ 'prefixoVeiculo' ]       := (cAlias)->PREFIXO
                oResultado[ 'Resultado' ][nIndex][ 'matricula' ]            := (cAlias)->MATRICULA
                oResultado[ 'Resultado' ][nIndex][ 'colaborador' ]          := (cAlias)->COLABORADOR
                oResultado[ 'Resultado' ][nIndex][ 'dataServico' ]          := (cAlias)->DATA
                oResultado[ 'Resultado' ][nIndex][ 'horaInicial' ]          := (cAlias)->HORA_INICIAL
                oResultado[ 'Resultado' ][nIndex][ 'horaFinal' ]            := (cAlias)->HORA_FINAL
                oResultado[ 'Resultado' ][nIndex][ 'turno' ]                := (cAlias)->TURNO
                oResultado[ 'Resultado' ][nIndex][ 'codLinha' ]             := (cAlias)->COD_LINHA
                oResultado[ 'Resultado' ][nIndex][ 'nomeLinha' ]            := AllTrim( (cAlias)->NOME_LINHA )
                oResultado[ 'Resultado' ][nIndex][ 'filipetaAnterior' ]     := cFilipeta
                oResultado[ 'Resultado' ][nIndex][ 'filipeta' ]             := AllTrim( (cAlias)->FILIPETA )
                oResultado[ 'Resultado' ][nIndex][ 'roletaFinalAnterior' ]  := nUltRolF
                oResultado[ 'Resultado' ][nIndex][ 'roletaInicial' ]        := (cAlias)->ROLETA_INICIAL            
                oResultado[ 'Resultado' ][nIndex][ 'diferenca' ]            := nDiferenca
            EndIf

        EndIf
            
        cVeiculo  := (cAlias)->VEICULO   
        cFilipeta := AllTrim( (cAlias)->FILIPETA )    
        nUltRolF  := (cAlias)->ROLETA_FINAL        

        ( cAlias )->(DbSkip())
        
    EndDo

    ( cAlias )->(DbCloseArea())

    self:SetResponse(oResultado:toJson())
    oResultado:fromJson("{}")
    oResultado := Nil

Return .T.
