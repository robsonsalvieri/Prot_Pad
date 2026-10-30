#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} WSGTP001

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

WSRESTFUL WSGTP001 DESCRIPTION "API REST para integração com o sistema Urbano"

    WSDATA dataIni  as String
    WSDATA dataFim  as String
    WSDATA escala   as String OPTIONAL
    WSDATA linha    as String OPTIONAL
	WSDATA filter   as String OPTIONAL
	WSDATA page     as INTEGER OPTIONAL
	WSDATA pageSize as INTEGER OPTIONAL

    WSMETHOD GET escalaAlocada;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver ";
        PATH "escalaAlocada" PRODUCES APPLICATION_JSON;
        WSSYNTAX "WSGTP001/escalaAlocada/?{dataIni}{dataFim}{escala}{linha}";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET veiculoAlocado;
		DESCRIPTION "Método para buscar veiculos e suas alocação";
		PATH "veiculoAlocado" PRODUCES APPLICATION_JSON;
		WSSYNTAX "WSGTP001/veiculoAlocado/?{dataIni}{dataFim}{filter}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET colabAlocado;
		DESCRIPTION "Método para buscar colaboradores e suas alocações";
		PATH "colabAlocado" PRODUCES APPLICATION_JSON;
		WSSYNTAX "WSGTP001/colabAlocado/?{dataIni}{dataFim}{filter}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET colabSituacao;
		DESCRIPTION "Método para trazer situações dos colaboradores";
		PATH "colabSituacao" PRODUCES APPLICATION_JSON;
		WSSYNTAX "WSGTP001/colabSituacao/?{dataIni}{dataFim}{filter}{page}{pageSize}";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET escalaAlocada
Lista escala alocada

@since 24/04/2024
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/WSGTP001/escalaAlocada?cDtIni=20240101&cDtFim=20240105

/*/
//-------------------------------------------------------------------
WSMETHOD GET escalaAlocada WSRECEIVE dataIni, dataFim, escala, linha WSREST WSGTP001

	Local oResponse  := JsonObject():New()
    Local cAlias     := GetNextAlias()
	Local cDtIni     := Self:dataIni
	Local cDtFim     := Self:dataFim
	Local cCodLinha  := Self:linha
	Local cCodEscala := Self:escala
	Local cCodMot    := ""
	Local cCodVeic   := ""
	Local cCodCob    := ""
	Local nQtdMot    := 0
	Local nQtdVeic   := 0
	Local nQtdCob    := 0
    Local nIndex     := 0

	Self:SetContentType("application/json")

	getEscalasAloc(cDtIni, cDtFim, cCodLinha, cCodEscala, @cAlias)

    (cAlias)->(DbGoTop())

	oResponse['Escalas'] := {}

	While ( cAlias )-> (!EoF())

			nIndex++

			aadd(oResponse['Escalas'], JsonObject(): New())

			oResponse[ 'Escalas' ][nIndex][ 'pkEscala' ]                       := ((cAlias)->FILIALESCALA + (cAlias)->CODESCALAH76)
			oResponse[ 'Escalas' ][nIndex][ 'codEscala' ]                      := (cAlias)->CODESCALAH76
			oResponse[ 'Escalas' ][nIndex][ 'descEscala' ]                     := EncodeUTF8(AllTrim( (cAlias)->DESCESCALA ))
			oResponse[ 'Escalas' ][nIndex][ 'qtdVeiculos' ]                    := (cAlias)->H76_QTVEIC
			oResponse[ 'Escalas' ][nIndex][ 'qtdMotorista' ]                   := (cAlias)->H76_QTMOTO
			oResponse[ 'Escalas' ][nIndex][ 'qtdCobrador' ]                    := (cAlias)->H76_QTCOBR
            oResponse[ 'Escalas' ][nIndex][ 'codLinha' ]                       := (cAlias)->CODLINHA
			oResponse[ 'Escalas' ][nIndex][ 'descLinha' ]                      := EncodeUTF8(AllTrim( (cAlias)->DESCLINHA ))
			oResponse[ 'Escalas' ][nIndex][ 'veiculoPadrao' ]                  := (cAlias)->H76_VEICUL

			oResponse[ 'Escalas' ][nIndex][ 'codigoMotoristaPadrao' ]          := (cAlias)->H76_CODMOT
			oResponse[ 'Escalas' ][nIndex][ 'motoristaPadrao' ]                := EncodeUTF8(AllTrim(Posicione( 'GYG' , 1, xFilial( 'GYG' ) + (cAlias)->H76_CODMOT, 'GYG_NOME' )))
			oResponse[ 'Escalas' ][nIndex][ 'codigoMotoristaReserva' ]         := (cAlias)->H76_MOTRES
			oResponse[ 'Escalas' ][nIndex][ 'motoristaReserva' ]               := EncodeUTF8(AllTrim(Posicione( 'GYG' , 1, xFilial( 'GYG' ) + (cAlias)->H76_MOTRES, 'GYG_NOME' )))

			oResponse[ 'Escalas' ][nIndex][ 'codigoCobradorPadrao' ]           := (cAlias)->H76_CODCOB
			oResponse[ 'Escalas' ][nIndex][ 'cobradorPadrao' ]                 := EncodeUTF8(AllTrim(Posicione( 'GYG' , 1, xFilial( 'GYG' ) + (cAlias)->H76_CODCOB, 'GYG_NOME' )))
			oResponse[ 'Escalas' ][nIndex][ 'codigoCobradorReserva' ]          := (cAlias)->H76_COBRES
			oResponse[ 'Escalas' ][nIndex][ 'cobradorReserva' ]                := EncodeUTF8(AllTrim(Posicione( 'GYG' , 1, xFilial( 'GYG' ) + (cAlias)->H76_COBRES, 'GYG_NOME' )))


            oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ]                     := {}
			aadd(oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ], JsonObject():New())
			aTail(oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ])[ 'segunda' ] := Iif((cAlias)->SEGUNDA == 'T' , .T., .F.)
			aTail(oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ])[ 'terca' ]   := Iif((cAlias)->TERCA == 'T' , .T., .F.)
			aTail(oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ])[ 'quarta' ]  := Iif((cAlias)->QUARTA == 'T' , .T., .F.)
			aTail(oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ])[ 'quinta' ]  := Iif((cAlias)->QUINTA == 'T' , .T., .F.)
			aTail(oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ])[ 'sexta' ]   := Iif((cAlias)->SEXTA == 'T' , .T., .F.)
			aTail(oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ])[ 'sabado' ]  := Iif((cAlias)->SABADO == 'T' , .T., .F.)
			aTail(oResponse[ 'Escalas' ][nIndex][ 'diasSemana' ])[ 'domingo' ] := Iif((cAlias)->DOMINGO == 'T' , .T., .F.)

            If !Empty((cAlias)->DIA)

				oResponse[ 'Escalas' ][nIndex][ 'codH7E' ]        := (cAlias)->CODH7E
				oResponse[ 'Escalas' ][nIndex][ 'dataInicioH7E' ] := (cAlias)->DATAINI
				oResponse[ 'Escalas' ][nIndex][ 'dataFimH7E' ]    := (cAlias)->DATAFIN
                oResponse[ 'Escalas' ][nIndex][ 'dia' ]           := (cAlias)->DIA
                oResponse[ 'Escalas' ][nIndex][ 'codH7F' ]        := (cAlias)->CODH7F

				H7G->(DbSetOrder(1))
				If H7G->(DbSeek(xFilial("H7G") + (cAlias)->CODH7E + (cAlias)->CODH7F ))

					cCodMot	 := ""
					cCodVeic := ""
					cCodCob	 := ""
					nQtdVeic := 0
					nQtdMot	 := 0
					nQtdCob  := 0

					While xFilial("H7G") == H7G->H7G_FILIAL .And. (cAlias)->CODH7E == H7G->H7G_CODH7E .And. (cAlias)->CODH7F == H7G->H7G_CODH7F

						If !Empty(H7G->H7G_CODGYG) .And. cCodMot != H7G->H7G_CODGYG
							nQtdVeic++
						EndIf

						If !Empty(H7G->H7G_CODH70) .And. cCodVeic != H7G->H7G_CODH70
							nQtdMot++
						EndIf

						If !Empty(H7G->H7G_CODCOB) .And. cCodCob != H7G->H7G_CODCOB
							nQtdCob++
						EndIf

						cCodMot	 := H7G->H7G_CODGYG
						cCodVeic := H7G->H7G_CODH70
						cCodCob	 := H7G->H7G_CODCOB

						H7G->(DbSkip())

					EndDo

					oResponse[ 'Escalas' ][nIndex][ 'qtdVeiculosAlocados' ]   := nQtdVeic
					oResponse[ 'Escalas' ][nIndex][ 'qtdMotoristasAlocados' ] := nQtdMot
					oResponse[ 'Escalas' ][nIndex][ 'qtdCobradoresAlocados' ] := nQtdCob

				EndIf

            EndIf

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getEscalasAloc
Query para trazer a escala alocada

@since 26/04/2024
@version 1.0

/*/
//-------------------------------------------------------------------
Static function getEscalasAloc(cDataIni, cDataFim, cCodLinha, cCodEscala, cAlias)

	Local cQuery       := ''

	Default cCodLinha  := ''
	Default cCodEscala := ''

	cQuery := " SELECT H76.H76_CODIGO CODESCALAH76,"
	cQuery +=        " H76.H76_DESCRI DESCESCALA,"
	cQuery +=        " H76.H76_FILIAL FILIALESCALA,"
	cQuery +=        " H76.H76_QTVEIC H76_QTVEIC,"
	cQuery +=        " H76.H76_QTMOTO H76_QTMOTO,"
	cQuery +=        " H76.H76_QTCOBR H76_QTCOBR,"
	cQuery +=        " H76.H76_VEICUL H76_VEICUL,"
	cQuery +=        " H76.H76_CODMOT H76_CODMOT,"
	cQuery +=        " H76.H76_CODCOB H76_CODCOB,"
	cQuery +=        " H76.H76_MOTRES H76_MOTRES,"
	cQuery +=        " H76.H76_COBRES H76_COBRES,"
	cQuery +=        " H7F.H7F_CODH7E CODH7E,"
	cQuery +=        " H7E.H7E_DTINIC DATAINI,"
	cQuery +=        " H7E.H7E_DTFINA DATAFIN,"
	cQuery +=        " H7F.H7F_DATA   DIA,"
	cQuery +=        " H7F.H7F_CODIGO CODH7F,"
	cQuery +=        " H77.H77_CODH6V CODLINHA,"
	cQuery +=        " H77.H77_DSCLIN DESCLINHA,"
	cQuery +=        " H73.H73_SEGUND SEGUNDA,"
	cQuery +=        " H73.H73_TERCA  TERCA,"
	cQuery +=        " H73.H73_QUARTA QUARTA,"
	cQuery +=        " H73.H73_QUINTA QUINTA,"
	cQuery +=        " H73.H73_SEXTA  SEXTA,"
	cQuery +=        " H73.H73_SABADO SABADO,"
	cQuery +=        " H73.H73_DOMING DOMINGO,"
	cQuery +=        " COUNT(H7G.H7G_CODH70) AS QTD_CODH70,"
	cQuery +=        " COUNT(H7G.H7G_CODGYG) AS QTD_CODGYG,"
	cQuery +=        " COUNT(H7G.H7G_CODCOB) AS QTD_CODCOB"
	cQuery += " FROM " + RetSqlName('H76') + " H76 "
	cQuery +=        " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=                " ON ( H77.H77_CODH76 = H76.H76_CODIGO"
	cQuery +=                     " AND H77.H77_FILIAL = '" + XFilial('H77') + "' "

	If !Empty(cCodLinha)
		cQuery +=                 " AND H77.H77_CODH6V = '" + cCodLinha + "'"
	Endif

	cQuery +=                     " AND H77.D_E_L_E_T_ = '' )"

	cQuery +=        " INNER JOIN " + RetSqlName('H71') + " H71 "
	cQuery +=                "ON ( H71.H71_CODIGO = H77.H77_CODH71 "
	cQuery +=                    " AND H71.H71_FILIAL = '" + XFilial('H71') + "' "
	cQuery +=                    " AND H71.H71_STATUS = '1'"
	cQuery +=                    " AND (('" + cDataIni + "' <= H71_DTFINA OR H71_DTFINA = '') AND '" + cDataFim + "' >= H71_DTINIC) OR" //Filtro de data
	cQuery +=                           " ( H71_DTINIC <= '" + cDataFim + "' AND  (H71_DTFINA >= '" + cDataIni + "' OR H71_DTFINA = ''))"
	cQuery +=                    " AND H71.D_E_L_E_T_ = '' )"

	cQuery +=        " INNER JOIN " + RetSqlName('H73') + " H73 "
	cQuery +=                "ON ( H73.H73_CODIGO = H77.H77_CODH73 "
	cQuery +=                    " AND H73.H73_CODH71 = H77.H77_CODH71 "
	cQuery +=                    " AND H73.H73_FILIAL = '" + XFilial('H73') + "' "
	cQuery +=                    " AND H73.D_E_L_E_T_ = '' )"

	cQuery +=        " LEFT JOIN " + RetSqlName('H7F') + " H7F "
	cQuery +=               " ON ( H7F.H7F_FILIAL = '" + XFilial('H7F') + "' "
    cQuery +=                    " AND H7F.H7F_CODH76 = H76.H76_CODIGO"
	cQuery +=                    " AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
	cQuery +=                    " AND H7F.D_E_L_E_T_ = '' )"

	cQuery +=        " LEFT JOIN " + RetSqlName('H7E') + " H7E "
    cQuery +=               " ON (H7E.H7E_FILIAL = '" + XFilial('H7E') + "' "
    cQuery +=              		" AND H7E.H7E_CODH76 = H76.H76_CODIGO "
    cQuery +=               	" AND H7E.H7E_CODIGO = H7F.H7F_CODH7E "
    cQuery +=               	" AND H7E.D_E_L_E_T_ = ' ' )

	cQuery +=        " LEFT JOIN " + RetSqlName('H7G') + " H7G "
	cQuery +=               " ON ( H7G.H7G_FILIAL = '" + XFilial('H7G') + "' "
	cQuery +=                    " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
	cQuery +=                    " AND H7G.D_E_L_E_T_ = '' )"
	cQuery += " WHERE H76.H76_FILIAL = '" + xFilial("H76") + "'"

	If !Empty(cCodEscala)
		cQuery +=    " AND H76.H76_CODIGO = '" + cCodEscala + "'"
	EndIf

	cQuery +=        " AND H76.D_E_L_E_T_ = ''"

	cQuery += " GROUP  BY H76.H76_CODIGO,"
	cQuery +=           " H76.H76_DESCRI,"
	cQuery +=           " H76.H76_FILIAL,"
	cQuery +=           " H76_QTVEIC,"
	cQuery +=           " H76_QTMOTO,"
	cQuery +=           " H76_QTCOBR,"
	cQuery +=           " H76_VEICUL,"
	cQuery +=           " H76_CODMOT,"
	cQuery +=           " H76_CODCOB,"
	cQuery +=           " H76_MOTRES,"
	cQuery +=           " H76_COBRES,"
	cQuery +=           " H7F_CODH7E,"
	cQuery +=        	" H7E_DTINIC,"
	cQuery +=        	" H7E_DTFINA,"
	cQuery +=           " H7F_DATA,"
    cQuery +=           " H7F_CODIGO,"
	cQuery +=           " H77_CODH6V,"
	cQuery +=           " H77_DSCLIN,"
	cQuery +=           " H73_SEGUND,"
	cQuery +=           " H73_TERCA, "
	cQuery +=           " H73_QUARTA,"
	cQuery +=           " H73_QUINTA,"
	cQuery +=           " H73_SEXTA ,"
	cQuery +=           " H73_SABADO,"
	cQuery +=           " H73_DOMING"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET veiculoAlocado
Lista colaborador e sua alocação de houver

@since 24/04/2024
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/WSGTP001/veiculoAlocado?cDtIni=20240501&cDtFim=20240509

/*/
//-------------------------------------------------------------------
WSMETHOD GET veiculoAlocado WSRECEIVE dataIni, dataFim, filter, page, pageSize WSREST WSGTP001

	Local oResponse  := JsonObject():New()
	Local cAlias     := GetNextAlias()
	Local cAliasD    := ""
	Local cDtIni     := Self:dataIni
	Local cDtFim     := Self:dataFim
	Local cFilter    := Self:filter
	Local cdia		 := ""
	Local cEscala	 := ""
	Local nQtdDias   := IIF(!Empty(cDtIni), DateDiffDay(sTod(cDtIni), sToD(cDtFim)) + 1, 0)
	Local nX		 := 0
	Local nY		 := 0
	Local nZ		 := 0
	Local nPage      := IIF(!Empty(Self:page), Self:page, 1)
	Local nPageSize  := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
	Local nOffset    := (nPage - 1) * nPageSize
	Local nSemEscala := 0
	Local nEmManut	 := 0
	Local lManut	 := GTPGetRules("VALIDMANUT",,,.F.)

	Self:SetContentType("application/json")

	getVeiculoAloc(cDtIni, cDtFim, cFilter, @cAlias, nOffset, nPageSize, lManut)

    (cAlias)->(DbGoTop())

	oResponse['Veiculos'] := {}

	While (cAlias)->(!EoF())

		cAliasD    := GetNextAlias()

		nX++

		aadd(oResponse['Veiculos'], JsonObject(): New())

		oResponse[ 'Veiculos' ][nX][ 'pk' ]             := AllTrim((cAlias)->FILIAL + (cAlias)->VEICULO)
		oResponse[ 'Veiculos' ][nX][ 'codVeiculo' ]     := AllTrim((cAlias)->VEICULO)
		oResponse[ 'Veiculos' ][nX][ 'prefixo' ]        := AllTrim((cAlias)->PREFIXO)
		oResponse[ 'Veiculos' ][nX][ 'categoria' ]      := AllTrim( (cAlias)->CATEGORIA ) + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCCAT ))
		oResponse[ 'Veiculos' ][nX][ 'modelo' ]         := (cAlias)->MODELO
		oResponse[ 'Veiculos' ][nX][ 'nome' ]         	:= AllTrim((cAlias)->NOME)
		oResponse[ 'Veiculos' ][nX][ 'local' ]          := (cAlias)->CODLOCAL + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCLOCAL ))

		If !Empty(cDtIni) .And. !Empty(cDtFim)

			If lManut .And. !Empty( (cAlias)->ORDEM )
				oResponse[ 'Veiculos' ][nX][ 'manutencoes' ] := {}

				Aadd(oResponse[ 'Veiculos' ][nX][ 'manutencoes' ], JsonObject():New())
				oResponse[ 'Veiculos' ][nX][ 'manutencoes' ][1]['codSituacao']        := "3"
				oResponse[ 'Veiculos' ][nX][ 'manutencoes' ][1]['situacaoManutencao'] := EncodeUTF8("Em Manutenção")
				nEmManut++

			EndIf

			getDiasAloc(cDtIni, cDtFim, (cAlias)->VEICULO, @cAliasD)

			If (cAliasD)->(EoF())
				oResponse['Veiculos'][nX]['status']   := '2'
				nSemEscala++
			EndIf

			While (cAliasD)->(!EoF())

				If cDia <> (cAliasD)->DIA .And. cEscala <> (cAliasD)->ESCALA

					If Valtype(oResponse['Veiculos'][nX]['alocacoes']) <> "A"
						nY := 0
						oResponse['Veiculos'][nX]['alocacoes'] := {}
					EndIf

					nY++

					Aadd(oResponse['Veiculos'][nX]['alocacoes'], JsonObject():New())

					oResponse['Veiculos'][nX]['alocacoes'][nY]['data']        := (cAliasD)->DIA
					oResponse['Veiculos'][nX]['alocacoes'][nY]['escala']      := (cAliasD)->ESCALA + " - " + EncodeUTF8( AllTrim( (cAliasD)->DESCESCALA ))

					//1 alocado - 2 Sem alocação - 3 parcialmente
					If Len(oResponse['Veiculos'][nX]["alocacoes"]) == nQtdDias
						oResponse['Veiculos'][nX]['status']   := '1'
					Else
						oResponse['Veiculos'][nX]['status']   := '3'
					EndIf

				EndIf

				If Valtype(oResponse['Veiculos'][nX]['alocacoes']) = "A"

					If Valtype(oResponse[ 'Veiculos' ][nX][ 'alocacoes' ][nY]['horarios']) <> "A"
						nZ := 0
						oResponse[ 'Veiculos' ][nX][ 'alocacoes' ][nY]['horarios'] := {}
					EndIf

					nZ++
					Aadd(oResponse[ 'Veiculos' ][nX][ 'alocacoes' ][nY]['horarios'], JsonObject():New())
					oResponse[ 'Veiculos' ][nX][ 'alocacoes' ][nY]['horarios'][nZ]['horaInicio'] := (cAliasD)->HORAINI
					oResponse[ 'Veiculos' ][nX][ 'alocacoes' ][nY]['horarios'][nZ]['horaFinal']  := (cAliasD)->HORAFIM

				EndIf

				cdia 	:= (cAliasD)->DIA
				cEscala := (cAliasD)->ESCALA

				( cAliasD )->(DbSkip())

			EndDo

			( cAliasD )->(DbCloseArea())

		EndIf

		( cAlias )->(DbSkip())

	EndDo

	( cAlias )->(DbCloseArea())

	oResponse['total'] 	  	  := getTotal( cFilter, .F.)
	oResponse['semEscala'] 	  := nSemEscala
	oResponse['emManutencao'] := nEmManut
	oResponse['page'] 	  	  := nPage
	oResponse['pageSize'] 	  := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getVeiculoAloc
Query para trazer a escala alocada

@since 26/04/2024
@version 1.0

/*/
//-------------------------------------------------------------------
Static function getVeiculoAloc(cDtIni, cDtFim, cFilter, cAlias, nOffset, nPageSize, lManut)

	Local cQuery    := ''

	Default cCodLinha  := ''
	Default cCodEscala := ''
	Default lManut	   := .F.

	cQuery := " SELECT H70.H70_FILIAL FILIAL,"
	cQuery +=        " H70.H70_CODVEI VEICULO,"
	cQuery +=        " H70.H70_PRFVEI PREFIXO,"
	cQuery +=        " H70.H70_CATVEI CATEGORIA,"
	cQuery +=        " H70.H70_DESCAT DESCCAT,"
	cQuery +=        " T9.T9_ANOMOD   MODELO,"
	cQuery +=        " T9.T9_NOME NOME,"
	cQuery +=        " H70.H70_VERSAO VERSAO,"
	cQuery +=        " H70.H70_LOCAL  CODLOCAL,"
	cQuery +=        " H70.H70_DESCLO DESCLOCAL"
	If lManut .And. !Empty(cDtIni) .And. !Empty(cDtFim)
		cQuery +=        ", STJ.TJ_ORDEM ORDEM"
	EndIf
	cQuery += " FROM " + RetSqlName('H70') + " H70 "
	cQuery +=        " INNER JOIN " + RetSqlName('ST9') + " T9 "
	cQuery +=                " ON ( T9.T9_FILIAL = '" + xFilial("ST9") + "'"
	cQuery +=                     " AND T9.T9_CODBEM = H70_CODVEI"
	cQuery +=                     " AND T9.T9_CATBEM IN ('2','4')"
	cQuery +=                     " AND T9.D_E_L_E_T_ = '' )"
	If lManut .And. !Empty(cDtIni) .And. !Empty(cDtFim)
		cQuery +=        " LEFT JOIN " + RetSqlName('STJ') + " STJ "
		cQuery +=               " ON ( STJ.TJ_FILIAL= '" + xFilial("STJ") + "'"'
		cQuery +=                    " AND STJ.TJ_CODBEM = H70.H70_CODVEI
		cQuery +=                    " AND STJ.TJ_TIPOOS = 'B'
		cQuery +=                    " AND STJ.TJ_TERMINO = 'N'
		cQuery +=                    " AND STJ.TJ_DTMPINI <= '" +  cDtFim +"'"
		cQuery +=                    " AND (STJ.TJ_DTMPFIM = '' OR STJ.TJ_DTMPFIM < '" +  cDtFim +"')"
		cQuery +=                    " AND STJ.D_E_L_E_T_ = ' ')
	EndIf
	cQuery += " WHERE  H70_FILIAL = '" + xFilial("H70") + "'"
	cQuery +=        " AND H70_STATUS = '1'"
	cQuery +=        " AND H70.D_E_L_E_T_ = ''"

	If !Empty(cFilter)
		cQuery +=  cFilter
	EndIf

	cQuery += " GROUP  BY H70.H70_FILIAL,"
	cQuery +=           " H70.H70_CODVEI,"
	cQuery +=           " H70.H70_PRFVEI,"
	cQuery +=           " H70.H70_CATVEI,"
	cQuery +=           " H70.H70_DESCAT,"
	cQuery +=           " T9.T9_ANOMOD,"
    cQuery +=           " T9.T9_NOME,"
    cQuery +=           " H70.H70_VERSAO,"
    cQuery +=           " H70.H70_LOCAL,"
    cQuery +=           " H70.H70_DESCLO"
	If lManut .And. !Empty(cDtIni) .And. !Empty(cDtFim)
		cQuery +=           ", STJ.TJ_ORDEM"
	EndIf
	cQuery += " ORDER BY H70.H70_CODVEI "
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} colabAlocado
Query para trazer a escala alocada

@since 26/04/2024
@version 1.0

/*/
//-------------------------------------------------------------------
WSMETHOD GET colabAlocado WSRECEIVE dataIni, dataFim, filter, page, pageSize WSREST WSGTP001

	Local oResponse  := JsonObject():New()
	Local cAlias	:= GetNextAlias()
	Local cAliasD	:= ""
	Local cDtIni     := Self:dataIni
	Local cDtFim     := Self:dataFim
	Local cFilter    := Self:filter
	Local cdia		 := ""
	Local cEscala	 := ""
	Local nQtdDias   := DateDiffDay(sTod(cDtIni), sToD(cDtFim)) + 1
	Local nX		 := 0
	Local nY		 := 0
	Local nZ		 := 0
	Local lColab	 := .T.
	Local nPage      := IIF(!Empty(Self:page), Self:page, 1)
	Local nPageSize  := IIF(!Empty(Self:pageSize), Self:pageSize, 1)
	Local nOffset    := (nPage - 1) * nPageSize

	Self:SetContentType("application/json")

	getMotoristas(cDtIni, cDtFim, cFilter, @cAlias, nOffset, nPageSize)

	(cAlias)->(DbGoTop())

	oResponse['Colaboradores'] := {}

	While ( cAlias )-> (!Eof())

		cAliasD	:= GetNextAlias()

		nX++
		nY := 0

		aAdd(oResponse['Colaboradores'], JsonObject(): New())

		oResponse[ 'Colaboradores' ][nX][ 'pk' ]             := ((cAlias)->FILIAL + (cAlias)->CODGYG)
		oResponse[ 'Colaboradores' ][nX][ 'codColaborador' ] := (cAlias)->CODGYG
		oResponse[ 'Colaboradores' ][nX][ 'nome' ]           := EncodeUTF8(AllTrim( (cAlias)->NOME ))
		oResponse[ 'Colaboradores' ][nX][ 'matricula' ]      := AllTrim( (cAlias)->MATRICULA )
		oResponse[ 'Colaboradores' ][nX][ 'turno' ]          := (cAlias)->TURNO

		getDiasAloc(cDtIni, cDtFim, , @cAliasD, (cAlias)->CODGYG)

		If (cAliasD)->(EoF())
			oResponse['Colaboradores'][nX]['status']   := '2'
		EndIf

		While (cAliasD)->(!EoF())

			If cDia <> (cAliasD)->DIA .And. cEscala <> (cAliasD)->ESCALA

				If ValType(oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ]) <> "A"
					oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ] := {}
				EndIf

				nY++

				Aadd(oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ], JsonObject():New())

				oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ][nY]['data'] := (cAliasD)->DIA
				oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ][nY]['escala'] := (cAliasD)->ESCALA + " - " + EncodeUTF8( AllTrim( (cAliasD)->DESCESCALA ))

				If Len(oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ]) == nQtdDias
					oResponse[ 'Colaboradores' ][nX]['status'] := '1'
				Else
					oResponse[ 'Colaboradores' ][nX]['status'] := '3'
				EndIf

			EndIf

			If Valtype(oResponse['Colaboradores'][nX]['alocacoes']) = "A"

				If ValType(oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ][nY]['horarios']) <> "A"
					nZ := 0
					oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ][nY]['horarios'] := {}
				EndIf

				nZ++
				Aadd(oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ][nY]['horarios'], JsonObject():New())
				oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ][nY]['horarios'][nZ]['horaInicio'] := (cAliasD)->HORAINI
				oResponse[ 'Colaboradores' ][nX][ 'alocacoes' ][nY]['horarios'][nZ]['horaFinal']  := (cAliasD)->HORAFIM

			EndIf

			cdia 	:= (cAliasD)->DIA
			cEscala := (cAliasD)->ESCALA

			( cAliasD )->(DbSkip())

		EndDo
		( cAliasD )->(DbCloseArea())

		( cAlias )->(DbSkip())

	EndDo

	( cAlias )->(DbCloseArea())

	oResponse['total'] 	  := getTotal(cFilter, lColab)
	oResponse['page'] 	  := nPage
	oResponse['pageSize'] := nPageSize

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getMotoristas
Busca os motoristas existentes na base e suas alocações se houver

@author Breno Gomes
@since 26/04/2024
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function getMotoristas(cDtIni, cDtFim, cFilter, cAlias, nOffset, nPageSize)

	Local cQuery      := ''

	cQuery := " SELECT GYG.GYG_FILIAL FILIAL, "
	cQuery += 	" GYG.GYG_CODIGO CODGYG, "
	cQuery += 	" GYG.GYG_NOME NOME,"
	cQuery += 	" GYG.GYG_FUNCIO MATRICULA,"
	cQuery += 	" GYG_RECCOD CODRECURSO,"
	cQuery += 	" GYG_TURNO TURNO"
	cQuery += " FROM " + RetSqlName('GYG') + " GYG "

	cQuery += 	" INNER JOIN " + RetSqlName('SRA') + " RA "
    cQuery +=   	" ON ( RA.RA_FILIAL = GYG.GYG_FILSRA "
    cQuery +=       	" AND RA.RA_MAT = GYG.GYG_FUNCIO "
	cQuery +=       	" AND RA_SITFOLH <> 'D' "
    cQuery +=           " AND RA.D_E_L_E_T_ = '' )"

	cQuery += " WHERE  GYG_FILIAL = '" + xFilial("GYG") + "'"
	cQuery += 	" AND GYG_STATUS = '1'"

	If !Empty(cFilter)
		cQuery +=  cFilter
	EndIf

	cQuery += " AND GYG.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY GYG.GYG_CODIGO "
	cQuery += " OFFSET " + AllTrim(Str(nOffset)) + " ROWS"
	cQuery += " FETCH NEXT " + AllTrim(Str(nPageSize)) + " ROWS ONLY"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getTotal
Busca os motoristas existentes na base e suas alocações se houver

@author Breno Gomes
@since 26/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static function getTotal(cFilter, lColab)

	Local cAlias := GetNextAlias()
    Local cQuery := ""
	Local nQtde  := 0

	Default lColab := .F.

	If lColab

		cQuery := " SELECT COUNT(DISTINCT GYG.GYG_CODIGO) TOTAL "
		cQuery += " FROM " + RetSqlName('GYG') + " GYG "
		cQuery += " WHERE GYG_FILIAL = '" + xFilial("GYG") + "'"
		cQuery += " AND GYG_STATUS = '1'
		If !Empty(cFilter)
			cQuery += cFilter
		EndIf
		cQuery += " AND GYG.D_E_L_E_T_ = ''"

	Else

		cQuery := " SELECT COUNT(DISTINCT H70.H70_CODVEI) TOTAL "
		cQuery += " FROM " + RetSqlName('H70') + " H70 "
		cQuery +=        " INNER JOIN " + RetSqlName('ST9') + " T9 "
		cQuery +=                " ON ( T9.T9_FILIAL = '" + xFilial("ST9") + "'"
		cQuery +=                     " AND T9.T9_CODBEM = H70_CODVEI"
		cQuery +=                     " AND T9.T9_CATBEM IN ('2','4')"
		cQuery +=                     " AND T9.D_E_L_E_T_ = '' )"
		cQuery += " WHERE H70_STATUS = '1'
		If !Empty(cFilter)
			cQuery += cFilter
		EndIf
		cQuery += " AND H70.D_E_L_E_T_ = ''"

	EndIf

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

	If (cAlias)->(!EoF())
		nQtde := (cAlias)->TOTAL
	EndIf

	(cAlias)->(DbCloseArea())

Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} getDialoAloc
Query para trazer a escala alocada

@since 26/04/2024
@version 1.0

/*/
//-------------------------------------------------------------------
Static function getDiasAloc(cDtIni, cDtFim, cCodVei,cAliasD, cCodMot)
	Local cQuery    := ''

	Default cCodLinha  := ''
	Default cCodEscala := ''

	cQuery := " SELECT H7F.H7F_DATA DIA,"
	cQuery +=        " H7F.H7F_CODH76 ESCALA,"
	cQuery +=        " H7F.H7F_DESH76 DESCESCALA,"
	cQuery +=        " H7G.H7G_HRINIC HORAINI,"
	cQuery +=        " H7G.H7G_HRFINA HORAFIM"
	cQuery += " FROM " + RetSqlName('H7F') + " H7F "
	cQuery +=        " INNER JOIN " + RetSqlName('H7G') + " H7G "
	cQuery +=                " ON ( H7G.H7G_FILIAL = '" + xFilial("H7G") + "'"
	cQuery +=                     " AND H7G.H7G_CODH7E = H7F.H7F_CODH7E"
	cQuery +=                     " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
	If !Empty(cCodVei)
		cQuery +=                     " AND H7G.H7G_CODH70 = '" +  cCodVei +"'"
	EndIf
	If !Empty(cCodMot)
		cQuery +=                     " AND H7G.H7G_CODGYG = '" +  cCodMot +"'"
	EndIf
	cQuery +=                     " AND H7G.D_E_L_E_T_ = '' )"
	cQuery += " WHERE  H7F_FILIAL = '" + xFilial("H7F") + "'"
	cQuery +=        " AND H7F_DATA BETWEEN '" + cDtIni + "' AND '" +  cDtFim +"'"
	cQuery +=        " AND H7F.D_E_L_E_T_ = ''"
	cQuery += " GROUP  BY H7F.H7F_DATA,"
	cQuery +=           " H7F.H7F_CODH76,"
	cQuery +=           " H7F.H7F_DESH76,"
	cQuery +=           " H7G.H7G_HRINIC,"
	cQuery +=           " H7G.H7G_HRFINA"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliasD, .F., .F. )

Return

WSMETHOD GET colabSituacao WSRECEIVE dataIni, dataFim, filter WSREST WSGTP001

	Local oResponse := JsonObject():New()
    Local cAlias    := GetNextAlias()
	Local cDtIni    := Self:dataIni
	Local cDtFim    := Self:dataFim
	Local cFilter   := Self:filter
	Local nIndex    := 0

	Self:SetContentType("application/json")

	getSitColab(cDtIni, cDtFim, cFilter, @cAlias)

	(cAlias)->(DbGoTop())

	oResponse['Situacao'] := {}

	While (cAlias)->(!EoF())

		nIndex++

		aadd(oResponse['Situacao'], JsonObject(): New())

		oResponse[ 'Situacao' ][nIndex][ 'codigoColaborador' ] := (cAlias)->COLABORADOR
		oResponse[ 'Situacao' ][nIndex][ 'nome' ]              := EncodeUTF8(AllTrim( (cAlias)->NOME ))
		oResponse[ 'Situacao' ][nIndex][ 'dia' ]               := sToD((cAlias)->DIA)
		oResponse[ 'Situacao' ][nIndex][ 'tipo' ]              := EncodeUTF8(AllTrim( (cAlias)->TIPO ))
		oResponse[ 'Situacao' ][nIndex][ 'situacao' ]          := EncodeUTF8('Folga')

		( cAlias )->(DbSkip())

	EndDo

	( cAlias )->(DbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

Static function getSitColab(cDtIni, cDtFim, cFilter, cAlias)

	Local cQuery    := ''

	cQuery := " SELECT GYG.GYG_CODIGO COLABORADOR,"
	cQuery += 	" GYG.GYG_NOME NOME,"
	cQuery += 	" H7R.H7R_DATA DIA,"
	cQuery += 	" H7R.H7R_TIPO TIPO"
	cQuery += " FROM " + RetSqlName('GYG') + " GYG "
	cQuery += " RIGHT JOIN " + RetSqlName('H7R') + " H7R " "
	cQuery += 	" ON ( H7R.H7R_FILIAL = '" + XFilial('H7R') + "'"
	cQuery += 		" AND H7R.H7R_COLAB = GYG.GYG_CODIGO"
	cQuery += 		" AND H7R.H7R_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'"
	cQuery += 		" AND H7R.H7R_TIPO = '4' "
	cQuery += 		" AND H7R.D_E_L_E_T_ = '')"
	cQuery += " WHERE GYG.GYG_FILIAL = '" + XFilial('GYG') + "'"

	If !Empty(cFilter)
		cQuery +=  cFilter
	EndIf

	cQuery += 	" AND GYG.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY GYG.GYG_CODIGO,"
	cQuery += 	" GYG.GYG_NOME,"
	cQuery += 	" H7R.H7R_DATA,"
	cQuery += 	" H7R.H7R_TIPO"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

Return
