#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} FRETAMENTO URBANO PO-UI

Classe WSRESTFUL - API Web Service RESTFUL - Fretamento Urbano PO UI

@Metodos WSMETHOD

@author     Breno Gomes
@since      16/01/2024
/*/
//------------------------------------------------------------------------------
WSRESTFUL FRETAMENTOURBANO DESCRIPTION "Fretamento Urbano"

	WSDATA filter     as String OPTIONAL
	WSDATA cep        as String OPTIONAL
	WSDATA cColab     as String OPTIONAL
	WSDATA lUf        as BOOLEAN
	WSDATA page       as INTEGER
	WSDATA pageSize   as INTEGER
	WSDATA cData      as String
	WSDATA cDtIni     as String
	WSDATA cDtFim     as String
	WSDATA escala     as String
	WSDATA linha      as String
	WSDATA tipoColab  as String
	WSDATA tabela     as String
	WSDATA lCombo     as BOOLEAN
	WSDATA lFilterSit as BOOLEAN
	WSDATA lVerAlocad as BOOLEAN
	WSDATA cCodH71    as String
	WSDATA cCodH73    as String
	WSDATA cCodH74    as String
	WSDATA cCodH75    as String

	WSMETHOD GET localidade;
		DESCRIPTION "Método para consultar conteudo do combo de Local" PATH "local" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/local/?&{filter}";
		PATH "FRETAMENTOURBANO/local/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET municipio;
		DESCRIPTION "Método para consultar conteudo do combo de Município" PATH "municipio" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/municipio/?{filter}";
		PATH "FRETAMENTOURBANO/municipio/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET matricula;
		DESCRIPTION "Método para buscar conteúdo para combo de matrícula" PATH "matricula" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/matricula/?{filter}";
		PATH "FRETAMENTOURBANO/matricula/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET estadoMun;
		DESCRIPTION "Método para consultar conteudo do combo de Município do formulário" PATH "estadoMun" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/estadoMun/?{filter}&{lUf}";
		PATH "FRETAMENTOURBANO/estadoMun/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET progHorLin;
		DESCRIPTION "Método para buscar conteúdo para combo de matrícula" PATH "programacao" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/programacao/?{filter}";
		PATH "FRETAMENTOURBANO/programacao/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET progViagEscala;
		DESCRIPTION "Método para buscar escala ja existente" PATH "escala" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/escala/?{filter}";
		PATH "FRETAMENTOURBANO/escala/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET GYGxAlocacao;
		DESCRIPTION "Método para buscar colaboradores e sua alocação" PATH "colaboradorAlocado" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/colaboradorAlocado/?{filter}";
		PATH "FRETAMENTOURBANO/colaboradorAlocado/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET H70xAlocacao;
		DESCRIPTION "Método para buscar veiculos e sua alocação" PATH "veiculoAlocado" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/veiculoAlocado/?{filter}";
		PATH "FRETAMENTOURBANO/veiculoAlocado/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET escalaAlocada;
		DESCRIPTION "Método para buscar escala existente e suas alocações se houver " PATH "escalaAlocada" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/escalaAlocada/?{filter}";
		PATH "FRETAMENTOURBANO/escalaAlocada/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET horariosH7G;
		DESCRIPTION "Método para buscar os horarios em que o veiculo ou motorista já esteja alocado" PATH "horarios" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/horarios/";
		PATH "FRETAMENTOURBANO/horarios/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET colaboradorView;
		DESCRIPTION "Método para buscar o motorista e sua situação para a data especifica" PATH "colaboradorView" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/colaboradorView/";
		PATH "FRETAMENTOURBANO/colaboradorView/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET veicTL;
		DESCRIPTION "Busca os recursos existentes na base e suas alocações se houver" PATH "veiculo" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/veiculo/?{cDtIni}&{cDtFim}&{filter}";
		PATH "FRETAMENTOURBANO/veiculo/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET colabTL;
		DESCRIPTION "Busca os colaboradores existentes na base para timeline" PATH "colaborador" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/colaborador/?{cDtIni}&{cDtFim}&{filter}";
		PATH "FRETAMENTOURBANO/colaborador/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET sqlName;
		DESCRIPTION "Busca o sufixo das tabelas do usuário" PATH "sqlName" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/sqlName/{tabela}";
		PATH "FRETAMENTOURBANO/sqlName/{tabela}";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET turno;
		DESCRIPTION "Método para consultar conteudo do combo de turno" PATH "turno" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/turno/?{filter}";
		PATH "FRETAMENTOURBANO/turno/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET listFiliais;
		DESCRIPTION "Método listar as filais disponíveis para o usuário" PATH "listFiliais" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/listFiliais/";
		PATH "FRETAMENTOURBANO/listFiliais/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET consultaCEP;
		DESCRIPTION "Método listar as informações do cep informado" PATH "consultaCEP" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/consultaCEP/?{cep}";
		PATH "FRETAMENTOURBANO/consultaCEP/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET QtdRecursos;
		DESCRIPTION "Método para buscar a quantidade de recursos" PATH "qtdRecursos" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/qtdRecursos/?{escala}";
		PATH "FRETAMENTOURBANO/qtdRecursos/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET LinhaAlocada;
		DESCRIPTION "Busca as linhas existentes na base que tenha alocação" PATH "linhaAlocada" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/linhaAlocada/?{cDtIni}&{cDtFim}&{filter}";
		PATH "FRETAMENTOURBANO/linhaAlocada/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET usaRH;
		DESCRIPTION "Verifica a utilização do modulo de RH" PATH "usaRH" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/usaRH/";
		PATH "FRETAMENTOURBANO/usaRH/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET StatusDoc;
		DESCRIPTION "Verifica a utilização do modulo de RH" PATH "StatusDoc" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/StatusDoc/?{cColab}";
		PATH "FRETAMENTOURBANO/StatusDoc/";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET validUpdH75;
		DESCRIPTION "Método para buscar se o horario selecionado tem vinculo na escala" PATH "validUpdH75" PRODUCES APPLICATION_JSON;
		WSSYNTAX "FRETAMENTOURBANO/validUpdH75/";
		PATH "FRETAMENTOURBANO/validUpdH75/";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET localidade
Efetua o GET de local 

@author Silas Gomes
@since 26/01/2024
@param filter - Filtro a ser aplicado na requisição - ex GI1_CDMUNI = '000425'

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/local

/*/
//-------------------------------------------------------------------
WSMETHOD GET localidade WSRECEIVE filter WSREST FRETAMENTOURBANO

Local cAliasTmp  := GetNextAlias()
Local cFilter    := self:filter
Local cQuery     := ""
Local nIndex     := 0
Local oLocal     := JsonObject():New()

cQuery := " SELECT DISTINCT "
cQuery += "     GI1_COD CODLOCAL, "
cQuery += "     GI1_DESCRI DESCR, "
cQuery += "     GI1_CDMUNI CODMUNI "
cQuery += " FROM " + RetSqlName('GI1')
cQuery += " WHERE GI1_FILIAL = '" + XFilial('GI1') + "'"
cQuery += "     AND D_E_L_E_T_ = '' "

If !Empty(cFilter)
	cQuery += cFilter
EndIf

cQuery += " GROUP BY "
cQuery += " GI1_COD, GI1_DESCRI, GI1_CDMUNI "

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )

(cAliasTmp)->(DbGoTop())

oLocal['Localidade'] := {}

While ( cAliasTmp )-> (!EoF() .And. nIndex < 10)

	nIndex++

	aadd(oLocal[ 'Localidade' ], JsonObject(): New())

	oLocal[ 'Localidade' ][nIndex][ 'codLocal' ]  := AllTrim( (cAliasTmp)->CODLOCAL )
	oLocal[ 'Localidade' ][nIndex][ 'descLocal' ] := AllTrim( (cAliasTmp)->DESCR )
	oLocal[ 'Localidade' ][nIndex][ 'codMuni' ]   := AllTrim( (cAliasTmp)->CODMUNI )

	( cAliasTmp )->(DbSkip())
EndDo

( cAliasTmp )->(DbCloseArea())

self:SetResponse(oLocal:toJson())
oLocal:fromJson("{}")
oLocal := NIL

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GET municipio
Efetua o GET de municipio 

@author Silas Gomes
@since 26/01/2024
@param filter - Filtro a ser aplicado na requisição - ex CC2_CODMUN = '000425'

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/municipio

/*/
//-------------------------------------------------------------------
WSMETHOD GET municipio WSRECEIVE filter WSREST FRETAMENTOURBANO

Local cAliasTmp  := GetNextAlias()
Local cFilter    := self:filter
Local cQuery     := ""
Local nIndex     := 0
Local oMunicipio := JsonObject():New()

cQuery := " SELECT DISTINCT "
cQuery += "    CC2.CC2_CODMUN CODMUNI, "
cQuery += "    CC2.CC2_MUN DESCMUNI, "
cQuery += "    CC2.CC2_EST UF "
cQuery += " FROM " + RetSqlName('CC2') + " CC2 "
cQuery += "    INNER JOIN " + RetSqlName('GI1') + " GI1 "
cQuery += "        ON CC2.CC2_EST = GI1.GI1_UF "
cQuery += "        AND CC2.CC2_CODMUN = GI1.GI1_CDMUNI "
cQuery += " WHERE CC2.CC2_FILIAL = '" + XFilial('CC2') + "'"
cQuery += "     AND CC2.D_E_L_E_T_ = '' "
cQuery += "     AND GI1.D_E_L_E_T_ = '' "

If !Empty(cFilter)
	cQuery += cFilter
EndIf

cQuery += " GROUP BY CC2.CC2_CODMUN, CC2.CC2_MUN, CC2.CC2_EST "

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )

(cAliasTmp)->(DbGoTop())

oMunicipio['Municipio'] := {}

While ( cAliasTmp )-> (!EoF() .AND. nIndex < 10)

	nIndex++

	aadd(oMunicipio[ 'Municipio' ], JsonObject(): New())

	oMunicipio[ 'Municipio' ][nIndex][ 'codMuni' ]  := AllTrim( (cAliasTmp)->CODMUNI )
	oMunicipio[ 'Municipio' ][nIndex][ 'descMuni' ] := AllTrim( (cAliasTmp)->DESCMUNI )
	oMunicipio[ 'Municipio' ][nIndex][ 'uf' ]       := AllTrim( (cAliasTmp)->UF )

	( cAliasTmp )->(DbSkip())
EndDo

( cAliasTmp )->(DbCloseArea())

self:SetResponse(oMunicipio:toJson())
oMunicipio:fromJson("{}")
oMunicipio := NIL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET matricula
Efetua o GET de matricula 

@author Breno Gomes
@since 30/01/2024
@param filter - Filtro a ser aplicado na requisição - ex RA_MAT = '000425'

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/matricula

/*/
//-------------------------------------------------------------------
WSMETHOD GET matricula WSRECEIVE filter WSREST FRETAMENTOURBANO

Local cAliasTmp  := GetNextAlias()
Local cFilter    := Iif(self:filter != Nil, self:filter, "")
Local cQuery     := ""
Local nIndex     := 0
Local oResponse  := JsonObject():New()

cQuery := " SELECT DISTINCT "
cQuery += "    SRA.RA_FILIAL FILIAL, "
cQuery += "    SRA.RA_MAT MATRICULA, "
cQuery += "    SRA.RA_NOME NOME, "
cQuery += "    SRA.RA_CIC CIC, "
cQuery += "    SRA.RA_NASC NASC, "
cQuery += "    SRA.RA_CODFUNC FUNCAO "
cQuery += " FROM " + RetSqlName('SRA') + " SRA "
cQuery +=        " LEFT JOIN " + RetSqlName('GYG') + " GYG "
cQuery +=               " ON SRA.RA_MAT = GYG.GYG_FUNCIO"
cQuery +=                  " AND GYG.GYG_FILSRA = SRA.RA_FILIAL"
cQuery +=                  " AND GYG.D_E_L_E_T_ = ''"
cQuery += " WHERE RA_FILIAL = '"+xFilial("SRA") + "'"
cQuery += " AND SRA.D_E_L_E_T_ = ''"

If !Empty(cFilter)
	cQuery += cFilter
EndIf

cQuery += " GROUP BY SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CIC, SRA.RA_NASC, SRA.RA_CODFUNC "

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )

(cAliasTmp)->(DbGoTop())

oResponse['Matricula'] := {}

While ( cAliasTmp )-> (!EoF() .AND. nIndex < 10)

	nIndex++

	aadd(oResponse['Matricula'], JsonObject(): New())

	oResponse['Matricula'][nIndex]['filial']    := (cAliasTmp)->FILIAL
	oResponse['Matricula'][nIndex]['matricula'] := AllTrim( (cAliasTmp)->MATRICULA )
	oResponse['Matricula'][nIndex]['nome']      := AllTrim( (cAliasTmp)->NOME )
	oResponse['Matricula'][nIndex]['cic']       := AllTrim( (cAliasTmp)->CIC )
	oResponse['Matricula'][nIndex]['nasc']      := AllTrim( (cAliasTmp)->NASC )
	oResponse['Matricula'][nIndex]['funcao']    := AllTrim( (cAliasTmp)->FUNCAO )

	( cAliasTmp )->(DbSkip())
EndDo

( cAliasTmp )->(DbCloseArea())

self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET estadoMun
Efetua o GET de estado 

@author Silas Gomes
@since 31/01/2024
@param filter - Filtro a ser aplicado na requisição - ex CC2_EST = 'SP'

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/estadoMun

/*/
//-------------------------------------------------------------------
WSMETHOD GET estadoMun WSRECEIVE filter, lUf WSREST FRETAMENTOURBANO

Local cAliasTmp := GetNextAlias()
Local cFilter   := self:filter
Local cQuery    := ""
Local cGroupBy  := ""
Local cOrderBy  := ""
Local nIndex    := 0
Local oResponse := JsonObject():New()
Local lUf       := self:lUf

cQuery := " SELECT DISTINCT "
If lUf
	cQuery   += " CC2_EST UF"
	cOrderBy := " ORDER BY CC2_EST"
Else
	cQuery +=     " CC2_EST UF,"
	cQuery +=     " CC2_CODMUN CODMUNI,"
	cQuery +=     " CC2_MUN DESCMUNI"
	cGroupBy := " GROUP BY CC2_EST, CC2_CODMUN, CC2_MUN "
	cOrderBy += " ORDER BY CC2_MUN "
EndIf
cQuery += " FROM " + RetSqlName('CC2') + " CC2 "
cQuery += " WHERE CC2.CC2_FILIAL = '" + XFilial('CC2') + "'"
cQuery += "     AND CC2.D_E_L_E_T_ = '' "

If !Empty(cFilter)
	cQuery += cFilter
EndIf

cQuery := cQuery + cGroupBy + cOrderBy

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )

(cAliasTmp)->(DbGoTop())

oResponse['EstadoMun'] := {}

While ( cAliasTmp )-> (!EoF())

	nIndex++

	aadd(oResponse['EstadoMun'], JsonObject(): New())
	If lUf
		oResponse['EstadoMun'][nIndex][ 'uf' ] := AllTrim( (cAliasTmp)->UF )
	Else
		oResponse['EstadoMun'][nIndex][ 'uf' ]        := AllTrim( (cAliasTmp)->UF )
		oResponse['EstadoMun'][nIndex][ 'codigo' ]    := AllTrim( (cAliasTmp)->CODMUNI )
		oResponse['EstadoMun'][nIndex][ 'municipio' ] := AllTrim( (cAliasTmp)->DESCMUNI )
	EndIf
	( cAliasTmp )->(DbSkip())

EndDo

( cAliasTmp )->(DbCloseArea())

self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET matricula
Efetua o GET de programação de Horário-Linhas

@author Breno Gomes
@since 14/03/2024
@param filter - Filtro a ser aplicado na requisição - ex H6V_CODIGO = '000010'

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/programacao

/*/
//-------------------------------------------------------------------
WSMETHOD GET progHorLin WSRECEIVE filter, page, pageSize, WSREST FRETAMENTOURBANO

Local cAliasTmp  := GetNextAlias()
Local cFilter    := self:filter
Local cQuery     := ""
Local nIndex     := 0
Local oResponse  := JsonObject():New()
Local nPage      := Self:page
Local nPageSize  := Self:pageSize
Local nQtdReg    := 0
Local nQtdRegIni := 0
Local nQtdRegFim := 0
Local lHasNext   := .F.

Default nPage      := 1
Default nPageSize  := 10

cQuery := " SELECT DISTINCT "
cQuery +=        " H71.H71_FILIAL FILIALH71,"
cQuery +=        " H6V.H6V_FILIAL FILIALH6V,"
cQuery +=        " H6V.H6V_PREFIX PREFIXO,"
cQuery +=        " H6V.H6V_CODLIN CODLINHA,"
cQuery +=        " H6V.H6V_CODIGO CODH6V,"
cQuery +=        " H6V.H6V_DESCRI DESCRICAO,"
cQuery +=        " H71.H71_CODIGO CODH71PK,"
cQuery +=        " H71.H71_DTINIC DTINICIO,"
cQuery +=        " H71.H71_DTFINA DTTERMINO, "
cQuery +=        " H71.H71_STATUS STATUS, "
cQuery +=        " H71.H71_COMPLE COMPLE "
cQuery += " FROM " + RetSqlName('H6V') + " H6V "
cQuery += " LEFT JOIN " + RetSqlName('H71') + " H71 "
cQuery +=        " ON ( H71.H71_FILIAL = '" + xFilial('H71') +"'"
cQuery +=             " AND H71.H71_CODH6V = H6V.H6V_CODIGO "
cQuery +=             " AND H71.H71_PREFIX = H6V.H6V_PREFIX "
cQuery +=             " AND H71.D_E_L_E_T_ = '')"
cQuery += " WHERE H6V.H6V_FILIAL = '" + xFilial('H6V') + "'"
cQuery +=       " AND H6V.H6V_STATUS = '1' "
cQuery +=       " AND H6V.D_E_L_E_T_ = ''"

If !Empty(cFilter)
	cQuery += "AND " + cFilter
Endif

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )

(cAliasTmp)->(DbGoTop())

oResponse['Programacao'] := {}

nQtdRegIni := ((nPage-1) * nPageSize)
// Define o range para inclusão no JSON
nQtdRegFim := (nPage * nPageSize)
nQtdReg    := 0

While ( cAliasTmp )-> (!EoF())
	nQtdReg++
	// Verifica se o registro está no range da pagina
	If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)

		nIndex++

		aadd(oResponse['Programacao'], JsonObject(): New())

		oResponse['Programacao'][nIndex]['filial']      := (cAliasTmp)->FILIALH6V
		oResponse['Programacao'][nIndex]['statusProgr'] := Iif(!Empty((cAliasTmp)->CODH71PK), '1','2' )
		oResponse['Programacao'][nIndex]['codProg'] 	:= (cAliasTmp)->CODH71PK
		oResponse['Programacao'][nIndex]['status']      := Iif((cAliasTmp)->STATUS == '1', 'Ativa', 'Inativa')
		oResponse['Programacao'][nIndex]['dtInicio']    := AllTrim( (cAliasTmp)->DTINICIO )
		oResponse['Programacao'][nIndex]['dtTermino']   := AllTrim( (cAliasTmp)->DTTERMINO )
		oResponse['Programacao'][nIndex]['tipo']   		:= Iif((cAliasTmp)->COMPLE == 'T','Complementar','Principal')
		oResponse['Programacao'][nIndex]['prefixo']     := AllTrim( (cAliasTmp)->PREFIXO )
		oResponse['Programacao'][nIndex]['codH6V']     := AllTrim( (cAliasTmp)->CODH6V )
		oResponse['Programacao'][nIndex]['codLinha']    := AllTrim( (cAliasTmp)->CODLINHA )
		oResponse['Programacao'][nIndex]['descricao']   := EncodeUTF8(AllTrim( (cAliasTmp)->DESCRICAO ))
		oResponse['Programacao'][nIndex]['pkH6V']       := (cAliasTmp)->FILIALH6V + (cAliasTmp)->CODH6V + (cAliasTmp)->PREFIXO
		oResponse['Programacao'][nIndex]['pk']          := (cAliasTmp)->FILIALH71 + (cAliasTmp)->CODH71PK

	ElseIf (nQtdReg == nQtdRegFim + 1)
		lHasNext := .T.
	EndIf
	( cAliasTmp )->(DbSkip())
EndDo
// Verifica se há uma proxima pagina
If (lHasNext)
	oResponse['hasNext'] := "true"
Else
	oResponse['hasNext'] := "false"
EndIf
oResponse['length'] := nQtdReg
( cAliasTmp )->(DbCloseArea())

self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET progViagEscala
Efetua o GET escalas já existentes

@author Silas Gomes
@since 11/04/2023

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/escala

/*/
//-------------------------------------------------------------------
WSMETHOD GET progViagEscala WSRECEIVE filter, page, pageSize WSREST FRETAMENTOURBANO

Local cAliasTmp as character
Local cQuery    as character
Local nIndex    as numeric
Local oResponse as object

cAliasTmp := GetNextAlias()
cQuery    := ""
nIndex    := 0
oResponse := JsonObject():New()

cQuery := " SELECT "
cQuery +=        " H77.H77_FILIAL FILIAL, "
cQuery +=        " H76.H76_CODIGO CODH76, "
cQuery +=        " H76.H76_DESCRI DESCRI, "
cQuery +=        " H77.H77_CODH71 CODH71, "
cQuery +=        " H77.H77_SENTID SENTIDO, "
cQuery +=        " H77.H77_CODH6V CODH6V, "
cQuery +=        " H77.H77_TIPO TIPO, "
cQuery +=        " H77.H77_CODH73 CODH73, "
cQuery +=        " H77.H77_CODH74 CODH74, "
cQuery +=        " H77.H77_CODH75 CODH75 "
cQuery += " FROM " + RetSqlName('H76') + " H76 "
cQuery += " INNER JOIN " + RetSqlName('H77') + " H77 "
cQuery +=        " ON H77.H77_FILIAL = H76.H76_FILIAL "
cQuery +=           " AND H77.H77_CODH76 = H76.H76_CODIGO "
cQuery +=           " AND H77.D_E_L_E_T_ = '' "
cQuery += " WHERE H76.H76_FILIAL = '" + xFilial('H76') + "' AND H76.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliasTmp, .F., .F. )

(cAliasTmp)->(DbGoTop())

oResponse['Escala'] := {}

While ( cAliasTmp )-> (!EoF())

	nIndex++

	aadd(oResponse['Escala'], JsonObject(): New())

	oResponse[ 'Escala' ][nIndex][ 'filial' ]    := AllTrim( (cAliasTmp)->FILIAL )
	oResponse[ 'Escala' ][nIndex][ 'codH76' ]    := AllTrim( (cAliasTmp)->CODH76 )
	oResponse[ 'Escala' ][nIndex][ 'descricao' ] := EncodeUTF8( AllTrim( (cAliasTmp)->DESCRI ))
	oResponse[ 'Escala' ][nIndex][ 'codH71' ]    := AllTrim( (cAliasTmp)->CODH71 )
	oResponse[ 'Escala' ][nIndex][ 'sentido' ]   := AllTrim( (cAliasTmp)->SENTIDO )
	oResponse[ 'Escala' ][nIndex][ 'codH6V' ]    := AllTrim( (cAliasTmp)->CODH6V )
	oResponse[ 'Escala' ][nIndex][ 'tipo' ]      := AllTrim( (cAliasTmp)->TIPO )
	oResponse[ 'Escala' ][nIndex][ 'codH73' ]    := AllTrim( (cAliasTmp)->CODH73 )
	oResponse[ 'Escala' ][nIndex][ 'codH74' ]    := AllTrim( (cAliasTmp)->CODH74 )
	oResponse[ 'Escala' ][nIndex][ 'codH75' ]    := AllTrim( (cAliasTmp)->CODH75 )

	( cAliasTmp )->(DbSkip())

EndDo

( cAliasTmp )->(DbCloseArea())

self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GET GYGxAlocacao
Lista colaborador e sua alocação se houver

@author Breno Gomes
@since 24/04/2024
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/colaboradorAlocado

/*/
//-------------------------------------------------------------------
WSMETHOD GET GYGxAlocacao WSRECEIVE cDtIni, cDtFim, escala, filter, tipoColab, lFilterSit WSREST FRETAMENTOURBANO

Local oResponse  := Nil
Local cDtIni     := Self:cDtIni
Local cDtFim     := Self:cDtFim
Local cFilter    := Self:filter
Local cCodEscala := Self:escala
Local cTipoColab := Self:tipoColab
Local lFilterSit := Self:lFilterSit

Self:SetContentType("application/json")

oResponse := getMotoristas(cDtIni, cDtFim, cCodEscala, cFilter, cTipoColab, lFilterSit )

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
Static Function getMotoristas(cDataIni, cDataFim, cCodEscala, cFilter, cTipoColab, lFilterSit )

	Local cQuery      := ''
	Local cAlias      := GetNextAlias()
	Local oResponse   := JsonObject():New()
	Local oSituacao   := nil
	Local nIndex      := 0
	Local nId         := 0
	Local nIdxAloc    := 0
	Local nQtdDias    := DateDiffDay(sTod(cDataIni), sToD(cDataFim)) + 1

	Default cCodEscala := ''
	Default cFilter    := ''
	Default cTipoColab := ''
	Default lFilterSit := .F.

	cQuery := qryColaboradores(cDataIni, cDataFim, cCodEscala, cFilter, cTipoColab)

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

	(cAlias)->(DbGoTop())

	oResponse['Motoristas'] := {}

	While ( cAlias )-> (!EoF())

		nId := aScan(oResponse['Motoristas'],{|x| x['pk'] == ((cAlias)->FILIAL + (cAlias)->CODGYG)})

		If nId == 0
			nIndex++
			aadd(oResponse['Motoristas'], JsonObject(): New())

			oResponse['Motoristas'][nIndex]['pk']            := ((cAlias)->FILIAL + (cAlias)->CODGYG)
			oResponse['Motoristas'][nIndex]['codMotorista']  := (cAlias)->CODGYG
			oResponse['Motoristas'][nIndex]['descMotorista'] := EncodeUTF8(AllTrim( (cAlias)->NOME ))
			oResponse['Motoristas'][nIndex]['matricula']     := AllTrim( (cAlias)->MATRICULA )
			oResponse['Motoristas'][nIndex]['turno']         := (cAlias)->TURNO
			oResponse['Motoristas'][nIndex]['recurso']       := (cAlias)->CODRECURSO + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCRECURSO ))

			If lFilterSit
				oSituacao := qrySituacao((cAlias)->CODGYG, cDataIni, cDataFim )

				If oSituacao != Nil .And. Len(oSituacao['situacao']) > 0
					oResponse['Motoristas'][nIndex]['situacao'] := oSituacao
				EndIf
			EndIf

			if (Empty(cTipoColab) .Or. cTipoColab == 'motorista')
				If !Empty( (cAlias)->MOTORISTA ) .And. !Empty( (cAlias)->DIA )

					oResponse['Motoristas'][nIndex]['alocacoes'] := {}
					Aadd(oResponse['Motoristas'][nIndex]['alocacoes'], JsonObject():New())

					oResponse['Motoristas'][nIndex]['alocacoes'][1]['data']     := (cAlias)->DIA
					oResponse['Motoristas'][nIndex]['alocacoes'][1]['escala']   := (cAlias)->ESCALA + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCESCALA ))


					If Len(oResponse['Motoristas'][nIndex]['alocacoes']) == nQtdDias
						oResponse['Motoristas'][nIndex]['status']   := '1' //1 alocado - 2 Sem alocação - 3 parcialmente
					Else
						oResponse[ 'Motoristas' ][nIndex][ 'status' ]   := '3' //1 alocado - 2 Sem alocação - 3 parcialmente
					EndIf
				Else
					oResponse[ 'Motoristas' ][nIndex][ 'status' ]   := '2' //1 alocado - 2 Sem alocação - 3 parcialmente
				EndIf
			Else
				If !Empty( (cAlias)->COBRADOR ) .And. !Empty( (cAlias)->DIA )

					oResponse['Motoristas'][nIndex]['alocacoes'] := {}
					Aadd(oResponse['Motoristas'][nIndex]['alocacoes'], JsonObject():New())

					oResponse['Motoristas'][nIndex]['alocacoes'][1]['data']     := (cAlias)->DIA
					oResponse['Motoristas'][nIndex]['alocacoes'][1]['escala']   := (cAlias)->ESCALA + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCESCALA ))

					If Len(oResponse['Motoristas'][nIndex]['alocacoes']) == nQtdDias
						oResponse['Motoristas'][nIndex]['status']   := '1' //1 alocado - 2 Sem alocação - 3 parcialmente
					Else
						oResponse[ 'Motoristas' ][nIndex][ 'status' ]   := '3' //1 alocado - 2 Sem alocação - 3 parcialmente
					EndIf
				Else
					oResponse[ 'Motoristas' ][nIndex][ 'status' ]   := '2' //1 alocado - 2 Sem alocação - 3 parcialmente
				EndIf
			EndIf

		Else
			if (Empty(cTipoColab) .Or. cTipoColab == 'motorista')
				If !Empty( (cAlias)->MOTORISTA) .And. !Empty( (cAlias)->DIA )

					If Empty(oResponse['Motoristas'][nId]['alocacoes'])
						oResponse['Motoristas'][nId]['alocacoes'] := {}
					EndIf

					nIdxAloc := Len(oResponse['Motoristas'][nId]['alocacoes']) + 1

					Aadd(oResponse['Motoristas'][nId]['alocacoes'], JsonObject():New())

					oResponse['Motoristas'][nId]['alocacoes'][nIdxAloc]['data']     := (cAlias)->DIA
					oResponse['Motoristas'][nId]['alocacoes'][nIdxAloc]['escala']   := (cAlias)->ESCALA + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCESCALA ))

					If Len(oResponse['Motoristas'][nId]["alocacoes"]) == nQtdDias
						oResponse['Motoristas'][nId]['status']   := '1' //1 alocado - 2 Sem alocação - 3 parcialmente
					Else
						oResponse['Motoristas'][nId]['status']   := '3' //1 alocado - 2 Sem alocação - 3 parcialmente
					EndIf
				EndIf
			Else
				If !Empty( (cAlias)->COBRADOR) .And. !Empty( (cAlias)->DIA )

					If Empty(oResponse['Motoristas'][nId]['alocacoes'])
						oResponse['Motoristas'][nId]['alocacoes'] := {}
					EndIf

					nIdxAloc := Len(oResponse['Motoristas'][nId]['alocacoes']) + 1

					Aadd(oResponse['Motoristas'][nId]['alocacoes'], JsonObject():New())

					oResponse['Motoristas'][nId]['alocacoes'][nIdxAloc]['data']     := (cAlias)->DIA
					oResponse['Motoristas'][nId]['alocacoes'][nIdxAloc]['escala']   := (cAlias)->ESCALA + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCESCALA ))


					If Len(oResponse['Motoristas'][nId]["alocacoes"]) == nQtdDias
						oResponse['Motoristas'][nId]['status']   := '1' //1 alocado - 2 Sem alocação - 3 parcialmente
					Else
						oResponse['Motoristas'][nId]['status']   := '3' //1 alocado - 2 Sem alocação - 3 parcialmente
					EndIf
				EndIf
			EndIf
		EndIf

		( cAlias )->(DbSkip())

	EndDo
	oResponse[ 'total' ]  := nIndex
	( cAlias )->(DbCloseArea())

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} qryColaboradores
Busca os colaboradores existentes na base e suas alocações se houver 

@author Breno Gomes
@since 20/05/2024
@version 1.0

/*/
//-------------------------------------------------------------------
Static function qryColaboradores(cDataIni, cDataFim, cCodEscala, cFilter, cTipoColab)

	Local cQuery      := ''

	cQuery := " SELECT GYG.GYG_FILIAL FILIAL, "
	cQuery +=        " GYG.GYG_CODIGO CODGYG, "
	cQuery +=        " GYG.GYG_NOME NOME,"
	cQuery +=        " GYG.GYG_FUNCIO MATRICULA,"
	cQuery +=        " COALESCE(H7G.H7G_CODGYG, ' ') AS MOTORISTA, "
	cQuery +=        " COALESCE(H7G.H7G_CODCOB, ' ') AS COBRADOR, "
	cQuery +=        " H7F_DATA       DIA,"
	cQuery +=        " H7E_CODH76 ESCALA,"
	cQuery +=        " H7E_DSCESC DESCESCALA,"
	cQuery +=        " GYG_RECCOD CODRECURSO,"
	cQuery +=        " GYG_TURNO TURNO,"
	cQuery +=        " GYK_DESCRI DESCRECURSO "

	cQuery += " FROM " + RetSqlName('GYG') + " GYG "
	cQuery +=        " INNER JOIN " + RetSqlName('GYK') + " GYK"
	cQuery +=                " ON (GYK.GYK_CODIGO = GYG.GYG_RECCOD "
	cQuery +=                   "  AND GYK.GYK_TIPREC != '' AND GYK.D_E_L_E_T_ = '')
	cQuery +=        " LEFT JOIN " + RetSqlName('H7E') + " H7E "
	cQuery +=               " ON ( H7E.H7E_FILIAL = '"+ xFilial("H7E") + "'"
	If cDataIni != cDataFim
		cQuery += " AND H7E.H7E_DTFINA >= '" + cDataIni + "'"
		cQuery += " AND H7E.H7E_DTINIC <= '" + cDataFim + "'"
	Else
		cQuery += " AND '" + cDataIni + "' BETWEEN H7E_DTINIC AND H7E_DTFINA "
	EndIf
	cQuery +=                    " AND H7E.D_E_L_E_T_ = '')"
	cQuery +=        " LEFT JOIN " + RetSqlName('H7F') + " H7F "
	cQuery +=               " ON ( H7F.H7F_FILIAL = H7E.H7E_FILIAL"
	cQuery +=                    " AND H7F.H7F_CODH7E = H7E.H7E_CODIGO"
	cQuery +=                    " AND H7F.D_E_L_E_T_ = ''
	cQuery +=                    " AND H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"')"
	cQuery +=        " LEFT JOIN " + RetSqlName('H7G') + " H7G "
	cQuery +=               " ON ( H7G.H7G_FILIAL = H7E.H7E_FILIAL"
	cQuery +=                    " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
	cQuery +=                    " AND H7G.H7G_CODH7E = H7E.H7E_CODIGO"
	cQuery +=                    " AND ( H7G.H7G_CODGYG = GYG.GYG_CODIGO"
	cQuery +=                    " OR H7G.H7G_CODCOB = GYG.GYG_CODIGO)"

	If !Empty(cCodEscala)
		cQuery +=                " AND H7G.H7G_CODH76 != '" + cCodEscala + "'"
	EndIf

	cQuery +=                    " AND H7G.D_E_L_E_T_ = '' )"

	cQuery += " WHERE  GYG_FILIAL = '" + xFilial("GYG") + "'"
	cQuery +=        " AND GYG_STATUS = '1'"
	cQuery +=        " AND GYG.D_E_L_E_T_ = ''"

	If !Empty(cFilter)
		cQuery +=  cFilter
	EndIf

	cQuery += " GROUP BY GYG.GYG_FILIAL, "
	cQuery +=          " GYG.GYG_CODIGO, "
	cQuery +=          " H7G.H7G_CODGYG, "
	cQuery +=          " H7G.H7G_CODCOB, "
	cQuery +=          " H7F_DATA, "
	cQuery +=          " H7E_CODH76, "
	cQuery +=          " GYG_RECCOD, "
	cQuery +=          " GYK_DESCRI, "
	cQuery +=          " H7E_DSCESC, "
	cQuery +=          " GYG_TURNO, "
	cQuery +=          " GYG_NOME, "
	cQuery +=          " GYG_FUNCIO "

return cQuery
//-------------------------------------------------------------------
/*/{Protheus.doc} GET H70xAlocacao
Lista colaborador e sua alocação de houver

@author Breno Gomes
@since 24/04/2024
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/veiculoAlocado?cDtIni=20240501&cDtFim=20240509&escala=000015

/*/
//-------------------------------------------------------------------
	WSMETHOD GET H70xAlocacao WSRECEIVE cDtIni, cDtFim, escala, linha, filter WSREST FRETAMENTOURBANO

	Local oResponse  := Nil
	Local cDtIni     := Self:cDtIni
	Local cDtFim     := Self:cDtFim
	Local cCodEscala := Self:escala
    Local cCodLinha  := Self:linha
	Local cFilter    := Self:filter
	Local lCombo     := Self:lCombo
	Local lVerAlocad := Self:lVerAlocad

	Self:SetContentType("application/json")

	oResponse := buscaVeiculos(cDtIni, cDtFim, cCodEscala, cCodLinha, cFilter, lCombo, lVerAlocad)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} buscaVeiculos
Busca os veiculos existentes na base e suas alocações se houver

@author Breno Gomes
@since 26/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function buscaVeiculos(cDataIni, cDataFim, cCodEscala, cCodLinha, cFilter, lCombo, lVerifyAlo)

	Local cAlias     := GetNextAlias()
	Local oResponse  := JsonObject():New()
	Local nId        := 0
	Local nX         := 0
	Local cQuery     := ''
	Local nIndex     := 0
	Local nIdxAloc   := 0
	Local nQtdDias   := DateDiffDay(sTod(cDataIni), sToD(cDataFim)) + 1
	Local aSituacao  := {}
	Local lVerifyDay := .T.

	Default cCodEscala := ''
    Default cCodLinha  := ''
	Default cFilter    := ''
	Default lCombo     := .F.
	Default lVerifyAlo := .F.

	cQuery := " SELECT H70.H70_FILIAL FILIAL,"
	cQuery +=        " H70.H70_CODVEI VEICULO,"
	cQuery +=        " H7G.H7G_CODH70 CODH70,"
	cQuery +=        " H70.H70_PRFVEI PREFIXO,"
	cQuery +=        " H70.H70_CATVEI CATEGORIA,"
	cQuery +=        " H70.H70_DESCAT DESCCAT,"
	cQuery +=        " T9.T9_ANOMOD   MODELO,"
	cQuery +=        " T9.T9_NOME NOME,"
	cQuery +=        " H70.H70_VERSAO VERSAO,"
	cQuery +=        " H70.H70_LOCAL  CODLOCAL,"
	cQuery +=        " H70.H70_DESCLO DESCLOCAL,"
	cQuery +=        " ( CASE H70.H70_PORTAS WHEN '1'  THEN 'Lado esquerdo' WHEN '2' THEN 'Lado direito' ELSE 'Ambos' END) AS PORTAS ,"
	cQuery +=        " H70.H70_PORESC PORTAESQUERDA,"
	cQuery +=        " H70.H70_PORDIR PORTADIREITA,"
	cQuery +=        " ( CASE H70.H70_CARROL WHEN '1'  THEN 'Frente' WHEN '2' THEN 'Médio' ELSE 'Seccionada' END) AS ROLETA ,"
	cQuery +=        " ( CASE H70.H70_POSCOB WHEN 'S' THEN 'Sim' ELSE 'Não' END) AS POSTOCOB, "
	cQuery +=        " ( CASE H70.H70_PACESS WHEN 'S' THEN 'Sim' ELSE 'Não' END) AS ACESSO,"
	cQuery +=        " H7F.H7F_DATA   DIA,"
	cQuery +=        " H7E.H7E_DTINIC DTINICIO,"
	cQuery +=        " H7E.H7E_DTFINA  DTFINA,"
	cQuery +=        " H7E.H7E_CODH76 ESCALA,"
	cQuery +=        " H7E.H7E_DSCESC DESCESCALA,"
	cQuery +=        " H7E.H7E_FILIAL FILIALALOCACAO,"
	cQuery +=        " H7E.H7E_CODIGO CODALOCACAO"
	cQuery += " FROM " + RetSqlName('H70') + " H70 "
	cQuery +=        " INNER JOIN " + RetSqlName('ST9') + " T9 "
	cQuery +=                " ON ( T9.T9_FILIAL = '" + xFilial("ST9") + "'"
	cQuery +=                     " AND T9.T9_CODBEM = H70_CODVEI"
	cQuery +=                     " AND T9.T9_CATBEM IN ('2','4')"
	cQuery +=                     " AND T9.D_E_L_E_T_ = '' )"
	cQuery +=        " LEFT JOIN " + RetSqlName('H7E') + " H7E "
	cQuery +=               " ON ( H7E.H7E_FILIAL = '" + xFilial("H7E") + "'"
	If cDataIni != cDataFim
		cQuery += " AND H7E.H7E_DTFINA >= '" + cDataIni + "'"
		cQuery += " AND H7E.H7E_DTINIC <= '" + cDataFim + "'"
	Else
		cQuery += " AND '" + cDataIni + "' BETWEEN H7E_DTINIC AND H7E_DTFINA "
	EndIf
	cQuery +=                    " AND H7E.D_E_L_E_T_ = '')"
	cQuery +=        " LEFT JOIN " + RetSqlName('H7F') + " H7F "
	cQuery +=               " ON ( H7F.H7F_FILIAL= '" + xFilial("H7F") + "'"
	cQuery +=                    " AND H7F.H7F_CODH7E = H7E.H7E_CODIGO"
	cQuery +=                    " AND H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
	cQuery +=                    " AND H7F.D_E_L_E_T_ = '' )"
	cQuery +=        " LEFT JOIN " + RetSqlName('H7G') + " H7G "
	cQuery +=               " ON ( H7G.H7G_FILIAL= '" + xFilial("H7G") + "'"
	cQuery +=                    " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
	cQuery +=                    " AND H7G.H7G_CODH7E = H7E.H7E_CODIGO"
	cQuery +=                    " AND H7G.H7G_CODH70 = H70.H70_CODVEI"
	cQuery +=                    " AND H7G.H7G_TIPO = '7'"

	If !Empty(cCodEscala)
		cQuery +=                " AND H7G.H7G_CODH76 != '" + cCodEscala + "'"
	EndIf

    If !Empty(cCodLinha)
		cQuery +=                 " AND H7G.H7G_CODH6V = '" + cCodLinha + "'"
	Endif

	cQuery +=                    " AND H7G.D_E_L_E_T_ = '' )"
	cQuery += " WHERE  H70_FILIAL = '" + xFilial("H70") + "'"
	cQuery +=        " AND H70_STATUS = '1'"
	cQuery +=        " AND H70.D_E_L_E_T_ = ''"

	If !Empty(cFilter)
		cQuery +=  cFilter
	EndIf

	cQuery += " GROUP  BY H70.H70_FILIAL,"
	cQuery +=           " H70.H70_CODVEI,"
	cQuery +=           " H7G.H7G_CODH70,"
	cQuery +=           " H7F_DATA,"
	cQuery +=           " H7E_CODH76,"
	cQuery +=           " H7E_DSCESC,"
	cQuery +=           " H70.H70_PRFVEI,"
	cQuery +=           " H70.H70_CATVEI,"
	cQuery +=           " T9_ANOMOD,"
	cQuery +=           " T9_NOME,"
	cQuery +=           " H70.H70_VERSAO,"
	cQuery +=           " H70_LOCAL,"
	cQuery +=           " H70_DESCLO,"
	cQuery +=           " H70_PORESC,"
	cQuery +=           " H70_PORDIR,"
	cQuery +=           " H70_CARROL,"
	cQuery +=           " H70_POSCOB,"
	cQuery +=           " H70_PACESS,"
	cQuery +=           " H7F_DATA,"
	cQuery +=           " H7E_CODH76,"
	cQuery +=           " H7E_DTINIC,"
	cQuery +=           " H7E_DTFINA,"
	cQuery +=           " H70_DESCAT,"
	cQuery +=           " H70_PORTAS,"
	cQuery +=           " H7E_FILIAL,"
	cQuery +=           " H7E_CODIGO,"
	cQuery +=           " H7E_DSCESC "

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

	(cAlias)->(DbGoTop())

	oResponse['Veiculos'] := {}

	While ( cAlias )-> (!EoF())
		nId := aScan(oResponse['Veiculos'],{|x| x['pk'] == ((cAlias)->FILIAL + (cAlias)->VEICULO)})

		If nId == 0
			nIndex++

			aadd(oResponse['Veiculos'], JsonObject(): New())

			oResponse[ 'Veiculos' ][nIndex][ 'pk' ]             := ((cAlias)->FILIAL + (cAlias)->VEICULO)
			oResponse[ 'Veiculos' ][nIndex][ 'codVeiculo' ]     := (cAlias)->VEICULO
			oResponse[ 'Veiculos' ][nIndex][ 'prefixo' ]        := (cAlias)->PREFIXO
			oResponse[ 'Veiculos' ][nIndex][ 'categoria' ]      := AllTrim( (cAlias)->CATEGORIA ) + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCCAT ))
			oResponse[ 'Veiculos' ][nIndex][ 'modelo' ]         := (cAlias)->MODELO
			oResponse[ 'Veiculos' ][nIndex][ 'nome' ]         	:= (cAlias)->NOME
			oResponse[ 'Veiculos' ][nIndex][ 'local' ]          := (cAlias)->CODLOCAL + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCLOCAL ))
			oResponse[ 'Veiculos' ][nIndex][ 'portas' ]         := (cAlias)->PORTAS
			oResponse[ 'Veiculos' ][nIndex][ 'portaEsquerda' ]  := (cAlias)->PORTAESQUERDA
			oResponse[ 'Veiculos' ][nIndex][ 'portaDireita' ]   := (cAlias)->PORTADIREITA
			oResponse[ 'Veiculos' ][nIndex][ 'roleta' ]         := EncodeUTF8((cAlias)->ROLETA)
			oResponse[ 'Veiculos' ][nIndex][ 'postoCobrador' ]  := EncodeUTF8( AllTrim( (cAlias)->POSTOCOB ))
			oResponse[ 'Veiculos' ][nIndex][ 'acessibilidade' ] := EncodeUTF8( AllTrim( (cAlias)->ACESSO ))

			lVerifyDay := !Empty( (cAlias)->DIA ) .And. (cAlias)->DIA <= dToS(dDatabase)
			aSituacao := UrbBscManut((cAlias)->FILIAL, (cAlias)->VEICULO, STOD(cDataIni), lVerifyDay , STOD(cDataFim), lCombo ) // [1]Código Situação;[2]Descrição Situação - Num. Ordem;[3]Data inicio;[4]Data Fim
			oResponse[ 'Veiculos' ][nIndex][ 'manutencoes' ] := {}
			for nX := 1 To Len(aSituacao)
				Aadd(oResponse[ 'Veiculos' ][nIndex][ 'manutencoes' ], JsonObject():New())
				oResponse[ 'Veiculos' ][nIndex][ 'manutencoes' ][nX]['codSituacao']        := aSituacao[nX][1]
				oResponse[ 'Veiculos' ][nIndex][ 'manutencoes' ][nX]['situacaoManutencao'] := EncodeUTF8( aSituacao[nX][2] )
				oResponse[ 'Veiculos' ][nIndex][ 'manutencoes' ][nX]['dataInicio']         := aSituacao[nX][3]
				oResponse[ 'Veiculos' ][nIndex][ 'manutencoes' ][nX]['dataFinal']          := aSituacao[nX][4]

			next nX

			If !Empty( (cAlias)->CODH70 ) .And. !Empty( (cAlias)->DIA )
				oResponse['Veiculos'][nIndex]['alocacoes'] := {}
				Aadd(oResponse['Veiculos'][nIndex]['alocacoes'], JsonObject():New())

				oResponse['Veiculos'][nIndex]['alocacoes'][1]['data']        := (cAlias)->DIA
				oResponse['Veiculos'][nIndex]['alocacoes'][1]['escala']      := (cAlias)->ESCALA + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCESCALA ))
				oResponse['Veiculos'][nIndex]['alocacoes'][1]['vigenciaIni'] := (cAlias)->DTINICIO
				oResponse['Veiculos'][nIndex]['alocacoes'][1]['vigenciaFim'] := (cAlias)->DTFINA
				oResponse['Veiculos'][nIndex]['alocacoes'][1]['pkAlocacao']  := ((cAlias)->FILIALALOCACAO + (cAlias)->CODALOCACAO)

				If lVerifyAlo
					lVerifyDay := !Empty( (cAlias)->DIA ) .And. (cAlias)->DIA <= dToS(dDatabase)
					aSituacao := UrbBscManut((cAlias)->FILIAL, (cAlias)->VEICULO, STOD((cAlias)->DIA), lVerifyDay , STOD((cAlias)->DIA), lCombo ) // [1]Código Situação;[2]Descrição Situação - Num. Ordem;[3]Data inicio;[4]Data Fim
					oResponse['Veiculos'][nIndex]['alocacoes'][1]['manutencoes'] := {}
					for nX := 1 To Len(aSituacao)
						Aadd(oResponse['Veiculos'][nIndex]['alocacoes'][1]['manutencoes'], JsonObject():New())
						oResponse['Veiculos'][nIndex]['alocacoes'][1]['manutencoes'][nX]['codSituacao']        := aSituacao[nX][1]
						oResponse['Veiculos'][nIndex]['alocacoes'][1]['manutencoes'][nX]['situacaoManutencao'] := EncodeUTF8( aSituacao[nX][2] )
						oResponse['Veiculos'][nIndex]['alocacoes'][1]['manutencoes'][nX]['dataInicio']         := aSituacao[nX][3]
						oResponse['Veiculos'][nIndex]['alocacoes'][1]['manutencoes'][nX]['dataFinal']          := aSituacao[nX][4]

					next nX
				EndIf

				If Len(oResponse['Veiculos'][nIndex]["alocacoes"]) == nQtdDias
					oResponse['Veiculos'][nIndex]['status']   := '1' //1 alocado - 2 Sem alocação - 3 parcialmente
				Else
					oResponse['Veiculos'][nIndex]['status']   := '3' //1 alocado - 2 Sem alocação - 3 parcialmente
				EndIf
			Else
				oResponse['Veiculos'][nIndex]['status']   := '2' //1 alocado - 2 Sem alocação - 3 parcialmente
			EndIf

		Else
			If !Empty( (cAlias)->CODH70) .And. !Empty( (cAlias)->DIA )


				If Empty(oResponse['Veiculos'][nId]['alocacoes'])
					oResponse['Veiculos'][nId]['alocacoes'] := {}
				EndIf

				nIdxAloc := Len(oResponse['Veiculos'][nId]["alocacoes"]) + 1

				Aadd(oResponse['Veiculos'][nId]['alocacoes'], JsonObject():New())

				oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['data']        := (cAlias)->DIA
				oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['escala']      := (cAlias)->ESCALA + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCESCALA ))
				oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['vigenciaIni'] := (cAlias)->DTINICIO
				oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['vigenciaFim'] := (cAlias)->DTFINA
				oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['pkAlocacao']  := ((cAlias)->FILIALALOCACAO + (cAlias)->CODALOCACAO)
				If lVerifyAlo
					lVerifyDay := !Empty( (cAlias)->DIA ) .And. (cAlias)->DIA <= dToS(dDatabase)
					aSituacao := UrbBscManut((cAlias)->FILIAL, (cAlias)->VEICULO, STOD((cAlias)->DIA), lVerifyDay , STOD((cAlias)->DIA), lCombo ) // [1]Código Situação;[2]Descrição Situação - Num. Ordem;[3]Data inicio;[4]Data Fim
					oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['manutencoes'] := {}
					for nX := 1 To Len(aSituacao)
						Aadd(oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['manutencoes'], JsonObject():New())
						oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['manutencoes'][nX]['codSituacao']        := aSituacao[nX][1]
						oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['manutencoes'][nX]['situacaoManutencao'] := EncodeUTF8( aSituacao[nX][2] )
						oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['manutencoes'][nX]['dataInicio']         := aSituacao[nX][3]
						oResponse['Veiculos'][nId]['alocacoes'][nIdxAloc]['manutencoes'][nX]['dataFinal']          := aSituacao[nX][4]

					next nX
				EndIf

				If Len(oResponse['Veiculos'][nId]['alocacoes']) == nQtdDias
					oResponse['Veiculos'][nId]['status']   := '1' //1 alocado - 2 Sem alocação - 3 parcialmente
				Else
					oResponse['Veiculos'][nId]['status']   := '3' //1 alocado - 2 Sem alocação - 3 parcialmente
				EndIf
			EndIf
		EndIf
		( cAlias )->(DbSkip())

	EndDo

	( cAlias )->(DbCloseArea())

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET escalaAlocada
Lista escala alocada

@author Breno Gomes
@since 24/04/2024
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/escalaAlocada?cDtIni=20240101&cDtFim=20240105

/*/
//-------------------------------------------------------------------
	WSMETHOD GET escalaAlocada WSRECEIVE cDtIni, cDtFim, escala, linha, lFilterSit WSREST FRETAMENTOURBANO

	Local oResponse  := Nil
	Local cDtIni     := Self:cDtIni
	Local cDtFim     := Self:cDtFim
	Local cCodLinha  := Self:linha
	Local cCodEscala := Self:escala
	Local lFilterSit := Self:lFilterSit

	Self:SetContentType("application/json")

	oResponse := getEscalasAloc(cDtIni, cDtFim, cCodLinha, cCodEscala, lFilterSit)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getEscalasAloc
Executa query para trazer a escala alocada e retorna o json com a estrutura

@author Breno Gomes
@since 26/04/2024
@version 1.0

/*/
//-------------------------------------------------------------------
Static function getEscalasAloc(cDataIni, cDataFim, cCodLinha, cCodEscala, lFilterSit)

	Local cQuery    := ''
	Local cAlias    := GetNextAlias()
	Local oResponse := JsonObject():New()
	Local oSitMoto  := JsonObject():New()
	Local oSitCob   := JsonObject():New()
	Local nIndex    := 0
	Local nId       := 0
	Local nIdxAloc  := 0
	Local nIdxH7F   := 0
	Local dDia      := sToD('')
	Local nIdSit    := 0

	Default cCodLinha  := ''
	Default cCodEscala := ''
	Default lFilterSit := .F.
	cQuery := " SELECT H7E.H7E_FILIAL FILIALALOCACAO,"
	cQuery +=        " H7E.H7E_CODIGO CODALOCACAO,"
	cQuery +=        " H76.H76_FILIAL FILIALESCALA,"
	cQuery +=        " H76.H76_CODIGO CODESCALAH76,"
	cQuery +=        " H7E.H7E_CODH76 ESCALAH7E,"
	cQuery +=        " H7E.H7E_DTINIC DTALOCINI,"
	cQuery +=        " H7E.H7E_DTFINA DTALOCFIM,"
	cQuery +=        " H76.H76_DESCRI DESCESCALA,"
	cQuery +=        " H76.H76_QTCOBR QTDCOBRADOR,"
	cQuery +=        " H7F.H7F_DATA   DIA,"
	cQuery +=        " H7F.H7F_CODIGO ESCALAXDIA,"
	cQuery +=        " H77.H77_CODH6V CODLINHA,"
	cQuery +=        " H77.H77_DSCLIN DESCLINHA,"
	cQuery +=        " H7G.H7G_CODCOB COBRADOR,"
	cQuery +=        " H7G.H7G_GYGCOB NOMECOB,"
	cQuery +=        " H7G.H7G_CODGYG MOTORISTA,"
	cQuery +=        " H7G.H7G_GYGNOM NOMEMOT,"
	cQuery +=        " H7G.H7G_CODH70 VEICULO,"
	cQuery +=        " H73.H73_SEGUND SEGUNDA,"
	cQuery +=        " H73.H73_TERCA  TERCA,"
	cQuery +=        " H73.H73_QUARTA QUARTA,"
	cQuery +=        " H73.H73_QUINTA QUINTA,"
	cQuery +=        " H73.H73_SEXTA  SEXTA,"
	cQuery +=        " H73.H73_SABADO SABADO,"
	cQuery +=        " H73.H73_DOMING DOMINGO,"
	cQuery +=        " H71.H71_DTINIC DTINICIO,"
	cQuery +=        " H71.H71_DTFINA DTFIM"

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
	cQuery +=                    " AND H73.H73_CODH71 = H71.H71_CODIGO "
	cQuery +=                    " AND H73.H73_FILIAL = '" + XFilial('H73') + "' "
	cQuery +=                    " AND H73.D_E_L_E_T_ = '' )"

	cQuery +=        " LEFT JOIN " + RetSqlName('H78') + " H78 "
	cQuery +=               " ON ( H78.H78_FILIAL = '" + XFilial('H78') + "' "
	cQuery +=                    " AND H78.H78_CODH76 = H76.H76_CODIGO "
	cQuery +=                    " AND H78.D_E_L_E_T_ = '' )"

	cQuery +=        " LEFT JOIN " + RetSqlName('H7E') + " H7E "
	cQuery +=               " ON ( H7E.H7E_CODH76 = H76.H76_CODIGO "
	cQuery +=                    " AND H7E.H7E_FILIAL = '" + XFilial('H7E') + "' "
	cQuery +=                    " AND (('" + cDataIni + "' <= H7E_DTFINA AND '" + cDataFim + "' >= H7E_DTINIC) OR" //Filtro de data
	cQuery +=                           " ( H7E_DTINIC <= '" + cDataFim + "' AND  H7E_DTFINA >= '" + cDataIni + "'))"
	cQuery +=                    " AND H7E.D_E_L_E_T_ = '' )"


	cQuery +=        " LEFT JOIN " + RetSqlName('H7F') + " H7F "
	cQuery +=               " ON ( H7F.H7F_FILIAL = '" + XFilial('H7F') + "' "
	cQuery +=                    " AND H7F.H7F_CODH7E = H7E.H7E_CODIGO"
	cQuery +=                    " AND H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
	cQuery +=                    " AND H7F.H7F_CODH76 = H76.H76_CODIGO"
	cQuery +=                    " AND H7F.D_E_L_E_T_ = '' )"

	cQuery +=        " LEFT JOIN " + RetSqlName('H7G') + " H7G "
	cQuery +=               " ON ( H7G.H7G_FILIAL = '" + XFilial('H7G') + "' "
	cQuery +=                    " AND H7G.H7G_CODH7E = H7E.H7E_CODIGO"
	cQuery +=                    " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
	cQuery +=                    " AND ( H7G.H7G_CODCOB != '' OR H7G.H7G_CODGYG != '' OR H7G.H7G_CODH70 != '')"
	cQuery +=                    " AND H7G.D_E_L_E_T_ = '' )"
	cQuery += " WHERE H76.H76_FILIAL = '" + xFilial("H76") + "'"
	If !Empty(cCodEscala)
		cQuery +=    " AND H76.H76_CODIGO = '" + cCodEscala + "'"
	EndIf

	cQuery +=        " AND H76.D_E_L_E_T_ = ''"

	cQuery += " GROUP  BY H76_FILIAL,"
	cQuery +=           " H76.H76_CODIGO,"
	cQuery +=           " H76.H76_DESCRI,"
	cQuery +=           " H7E_FILIAL,"
	cQuery +=           " H7E.H7E_CODIGO,"
	cQuery +=           " H7F_DATA,"
	cQuery +=           " H7E_CODH76,"
	cQuery +=           " H77_CODH6V,"
	cQuery +=           " H77_DSCLIN,"
	cQuery +=           " H7F_CODIGO,"
	cQuery +=           " H7G_CODCOB,"
	cQuery +=           " H7G_CODGYG,"
	cQuery +=           " H7G_CODH70,"
	cQuery +=           " H73_SEGUND,"
	cQuery +=           " H73_TERCA, "
	cQuery +=           " H73_QUARTA,"
	cQuery +=           " H73_QUINTA,"
	cQuery +=           " H73_SEXTA ,"
	cQuery +=           " H73_SABADO,"
	cQuery +=           " H73_DOMING,"
	cQuery +=           " H71_DTINIC,"
	cQuery +=           " H71_DTFINA,"
	cQuery +=           " H7G_GYGNOM,"
	cQuery +=           " H7G_GYGCOB,"
	cQuery +=           " H76_QTCOBR,"
	cQuery +=           " H7E_DTINIC,"
	cQuery +=           " H7E_DTFINA"

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

	(cAlias)->(DbGoTop())

	oResponse['Escalas'] := {}

	While ( cAlias )-> (!EoF())
		nId := aScan(oResponse['Escalas'],{|x| x['pkEscala'] == (((cAlias)->FILIALESCALA + (cAlias)->CODESCALAH76) ) .And. x['pkAlocacao'] == ((cAlias)->FILIALALOCACAO + (cAlias)->CODALOCACAO) })
		If lFilterSit
			If !Empty((cAlias)->MOTORISTA)
				oSitMoto := qrySituacao((cAlias)->MOTORISTA, cDataIni, cDataFim )
			EndIf
			If !Empty((cAlias)->COBRADOR)
				oSitCob := qrySituacao((cAlias)->COBRADOR, cDataIni, cDataFim )
			EndIf
		EndIf
		If nId == 0
			nIndex++

			aadd(oResponse['Escalas'], JsonObject(): New())

			oResponse['Escalas'][nIndex]['filial']        := (cAlias)->FILIALALOCACAO
			oResponse['Escalas'][nIndex]['pkAlocacao']    := ((cAlias)->FILIALALOCACAO + (cAlias)->CODALOCACAO)
			oResponse['Escalas'][nIndex]['pkEscala']      := ((cAlias)->FILIALESCALA + (cAlias)->CODESCALAH76)
			oResponse['Escalas'][nIndex]['codEscala']     := (cAlias)->CODESCALAH76
			oResponse['Escalas'][nIndex]['descEscala']    := EncodeUTF8(AllTrim( (cAlias)->DESCESCALA ))
			oResponse['Escalas'][nIndex]['linhas']        := EncodeUTF8(AllTrim( (cAlias)->DESCLINHA ))
			oResponse['Escalas'][nIndex]['dataIni']       := AllTrim( (cAlias)->DTINICIO )
			oResponse['Escalas'][nIndex]['dataFim']       := AllTrim( (cAlias)->DTFIM )
			oResponse['Escalas'][nIndex]['periodoAlocIni']:= (cAlias)->DTALOCINI
			oResponse['Escalas'][nIndex]['periodoAlocFim']:= (cAlias)->DTALOCFIM
			oResponse['Escalas'][nIndex]['qtdCobradores'] := (cAlias)->QTDCOBRADOR
			oResponse['Escalas'][nIndex]['diasSemana']    := {}
			Aadd(oResponse['Escalas'][nIndex]['diasSemana'], JsonObject():New()) 

			aTail(oResponse['Escalas'][nIndex]['diasSemana'])['segunda'] := Iif((cAlias)->SEGUNDA == 'T', .T., .F.)
			aTail(oResponse['Escalas'][nIndex]['diasSemana'])['terca']   := Iif((cAlias)->TERCA   == 'T', .T., .F.)
			aTail(oResponse['Escalas'][nIndex]['diasSemana'])['quarta']  := Iif((cAlias)->QUARTA  == 'T', .T., .F.)
			aTail(oResponse['Escalas'][nIndex]['diasSemana'])['quinta']  := Iif((cAlias)->QUINTA  == 'T', .T., .F.)
			aTail(oResponse['Escalas'][nIndex]['diasSemana'])['sexta']   := Iif((cAlias)->SEXTA   == 'T', .T., .F.)
			aTail(oResponse['Escalas'][nIndex]['diasSemana'])['sabado']  := Iif((cAlias)->SABADO  == 'T', .T., .F.)
			aTail(oResponse['Escalas'][nIndex]['diasSemana'])['domingo'] := Iif((cAlias)->DOMINGO == 'T', .T., .F.)


			If !Empty( (cAlias)->ESCALAH7E ) .And. !Empty( (cAlias)->DIA ) .And. !Empty( (cAlias)->ESCALAXDIA )
				oResponse['Escalas'][nIndex]['alocacoes'] := {}

				Aadd(oResponse['Escalas'][nIndex]['alocacoes'], JsonObject():New())

				aTail(oResponse['Escalas'][nIndex]['alocacoes'])['data']      := AllTrim( (cAlias)->DIA )
				aTail(oResponse['Escalas'][nIndex]['alocacoes'])['codH7F']    := AllTrim( (cAlias)->ESCALAXDIA )
				aTail(oResponse['Escalas'][nIndex]['alocacoes'])['escala']    := AllTrim( (cAlias)->ESCALAH7E ) + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCESCALA ))
				aTail(oResponse['Escalas'][nIndex]['alocacoes'])['pkAlocacao'] := ((cAlias)->FILIALALOCACAO + (cAlias)->CODALOCACAO)
				oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'] := {}
				Aadd(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'], JsonObject():New())

				If !Empty(AllTrim( (cAlias)->VEICULO ))

					oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['veiculos'] := {}
					Aadd(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['veiculos'], JsonObject():New())
					aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['veiculos'])['veiculo']  := AllTrim( (cAlias)->VEICULO )
					aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['veiculos'])['codDia']   := AllTrim( (cAlias)->ESCALAXDIA )
				EndIf

				If !Empty(AllTrim( (cAlias)->MOTORISTA ))
					oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['motoristas'] := {}
					Aadd(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['motoristas'], JsonObject():New())
					aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['motoristas'])['motorista'] := AllTrim( (cAlias)->MOTORISTA )
					aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['motoristas'])['nome'] := EncodeUTF8( AllTrim( (cAlias)->NOMEMOT ))
					aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['motoristas'])['codDia']    := AllTrim( (cAlias)->ESCALAXDIA )

					If lFilterSit
						dDia := sTod((cAlias)->DIA)
						if Len(oSitMoto['situacao']) > 0 .And.;
								(nIdSit := aScan(oSitMoto['situacao'],{|x| x['inicio'] == dDia .Or. (x['codSituacao'] != '4' .and. x['inicio'] <= dDia .and. x['final'] >= dDia ) })) > 0
							aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['motoristas'])['situacao']    := oSitMoto['situacao'][nIdSit]['descSituacao']
							aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['motoristas'])['codSituacao'] := oSitMoto['situacao'][nIdSit]['codSituacao']

						EndIf
					EndIf
				EndIf

				If !Empty(AllTrim( (cAlias)->COBRADOR ))
					oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['cobradores'] := {}
					Aadd(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['cobradores'], JsonObject():New())
					aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['cobradores'])['cobrador'] := AllTrim( (cAlias)->COBRADOR )
					aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['cobradores'])['nome']     := EncodeUTF8( AllTrim( (cAlias)->NOMECOB ))
					aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['cobradores'])['codDia']   := AllTrim( (cAlias)->ESCALAXDIA )
					If lFilterSit
						dDia := sTod((cAlias)->DIA)
						if Len(oSitCob['situacao']) > 0 .And.;
								(nIdSit := aScan(oSitCob['situacao'],{|x| x['inicio'] == dDia .Or. (x['codSituacao'] != '4' .and. x['inicio'] <= dDia .and. x['final'] >= dDia ) })) > 0
							aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['cobradores'])['situacao']    := oSitCob['situacao'][nIdSit]['descSituacao']
							aTail(oResponse['Escalas'][nIndex]['alocacoes'][1]['recursos'][1]['cobradores'])['codSituacao'] := oSitCob['situacao'][nIdSit]['codSituacao']

						EndIf
					EndIf

				EndIf
			EndIf
		Else
			If !Empty( (cAlias)->ESCALAH7E ) .And. !Empty( (cAlias)->DIA ) .And. !Empty( (cAlias)->ESCALAXDIA )

				If (nIdxH7F := aScan(oResponse['Escalas'][nId]['alocacoes'],{|x| x['data'] == AllTrim( (cAlias)->DIA )})) > 0
					nIdxAloc := nIdxH7F
				Else
					nIdxAloc := Len(oResponse['Escalas'][nId]["alocacoes"]) + 1

					Aadd(oResponse['Escalas'][nId]['alocacoes'], JsonObject():New())

					oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'] := {}
					Aadd(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'], JsonObject():New())
				EndIf

				aTail(oResponse['Escalas'][nId]['alocacoes'])['data']     := AllTrim( (cAlias)->DIA )
				aTail(oResponse['Escalas'][nId]['alocacoes'])['codH7F']   := AllTrim( (cAlias)->ESCALAXDIA )
				aTail(oResponse['Escalas'][nId]['alocacoes'])['escala']   := AllTrim( (cAlias)->ESCALAH7E ) + " - " + EncodeUTF8( AllTrim( (cAlias)->DESCESCALA ))
				aTail(oResponse['Escalas'][nId]['alocacoes'])['pkAlocacao'] := ((cAlias)->FILIALALOCACAO + (cAlias)->CODALOCACAO)

				If !Empty(AllTrim( (cAlias)->VEICULO )) .Or. !Empty(AllTrim( (cAlias)->MOTORISTA )) .Or. !Empty(AllTrim( (cAlias)->COBRADOR ))

					If !Empty(AllTrim( (cAlias)->VEICULO ))
						If Len(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos']) == 0 .Or. Empty(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos']) //Se não tiver veiculo adcionado, coloca na 1ª posição
							If Len(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos']) == 0 .Or. Empty( oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'])
								oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'] := {}
							EndIf

							Aadd(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'], JsonObject():New())

							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'])['veiculo']   := AllTrim( (cAlias)->VEICULO )
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'])['codDia']   := AllTrim( (cAlias)->ESCALAXDIA )

							//Se não for veiculo repetido, adiciona
						ElseIf ( aScan(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'],{|x| x['veiculo'] == AllTrim( (cAlias)->VEICULO ) .And. x['codDia'] == AllTrim( (cAlias)->ESCALAXDIA )})) == 0

							Aadd(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'], JsonObject():New())

							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'])['veiculo']  := AllTrim( (cAlias)->VEICULO )
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['veiculos'])['codDia']   := AllTrim( (cAlias)->ESCALAXDIA )
						EndIf
					EndIf
					//Adiciona o motorista em recursos
					If !Empty(AllTrim( (cAlias)->MOTORISTA ))

						If Len(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos']) == 0 .Or. Empty(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas']) //Se não tiver veiculo adcionado, coloca na 1ª posição

							If Len(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos']) == 0 .Or. Empty( oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])
								oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'] := {}
							EndIf

							Aadd(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'], JsonObject():New())

							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])['motorista'] := AllTrim( (cAlias)->MOTORISTA )
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])['nome'] := EncodeUTF8( AllTrim( (cAlias)->NOMEMOT ))
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])['codDia']    := AllTrim( (cAlias)->ESCALAXDIA )

							//Se não for motorista repetido, adiciona
						ElseIf ( aScan(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'],{|x| x['motorista'] == AllTrim( (cAlias)->MOTORISTA ) .And. x['codDia'] == AllTrim( (cAlias)->ESCALAXDIA )})) == 0

							Aadd(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'], JsonObject():New())

							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])['motorista'] := AllTrim( (cAlias)->MOTORISTA )
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])['nome']      := EncodeUTF8( AllTrim( (cAlias)->NOMEMOT ))
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])['codDia']    := AllTrim( (cAlias)->ESCALAXDIA )
						EndIf

						If lFilterSit
							dDia := sTod((cAlias)->DIA)
							if Len(oSitMoto['situacao']) > 0 .And.;
									(nIdSit := aScan(oSitMoto['situacao'],{|x| x['inicio'] == dDia .Or. (x['codSituacao'] != '4' .and. x['inicio'] <= dDia .and. x['final'] >= dDia ) })) > 0
								aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])['situacao']    := oSitMoto['situacao'][nIdSit]['descSituacao']
								aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['motoristas'])['codSituacao'] := oSitMoto['situacao'][nIdSit]['codSituacao']
							EndIf
						EndIf
					EndIf

					//Adiciona o cobrador em recursos
					If !Empty(AllTrim( (cAlias)->COBRADOR ))
						If Len(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos']) == 0 .Or. Empty(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores']) //Se não tiver veiculo adcionado, coloca na 1ª posição
							If Len(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos']) == 0 .Or. Empty( oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])
								oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'] := {}
							EndIf

							Aadd(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'], JsonObject():New())

							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])['cobrador'] := AllTrim( (cAlias)->COBRADOR )
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])['nome']     := EncodeUTF8( AllTrim( (cAlias)->NOMECOB ))
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])['codDia']   := AllTrim( (cAlias)->ESCALAXDIA )

							//Se não for cobrador repetido, adiciona
						ElseIf ( aScan(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'],{|x| x['cobrador'] == AllTrim( (cAlias)->COBRADOR ) .And. x['codDia'] == AllTrim( (cAlias)->ESCALAXDIA )})) == 0

							Aadd(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'], JsonObject():New())

							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])['cobrador'] := AllTrim( (cAlias)->COBRADOR )
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])['nome']     := EncodeUTF8( AllTrim( (cAlias)->NOMECOB ))
							aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])['codDia']   := AllTrim( (cAlias)->ESCALAXDIA )
						EndIf

                        If lFilterSit 
                            dDia := sTod((cAlias)->DIA)
                            if Len(oSitCob['situacao']) > 0 .And.;
                            (nIdSit := aScan(oSitCob['situacao'],{|x| x['inicio'] == dDia .Or. (x['codSituacao'] != '4' .and. x['inicio'] <= dDia .and. x['final'] >= dDia ) })) > 0 
                                aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])['situacao']    := oSitCob['situacao'][nIdSit]['descSituacao']        
                                aTail(oResponse['Escalas'][nId]['alocacoes'][nIdxAloc]['recursos'][1]['cobradores'])['codSituacao'] := oSitCob['situacao'][nIdSit]['codSituacao']        
                            EndIf
                        EndIf
                    EndIf
                EndIf
            EndIf

            If !(EncodeUTF8(AllTrim( (cAlias)->DESCLINHA )) $ oResponse['Escalas'][nId]['linhas'] )
                oResponse['Escalas'][nId]['linhas'] += ' / ' + EncodeUTF8(AllTrim( (cAlias)->DESCLINHA ))
            EndIf
        EndIf
        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

Return oResponse


//-------------------------------------------------------------------
/*/{Protheus.doc} GET escalaAlocada
Lista horatios que estão com veiculos/motoristas e cobradores vinculados

@author Breno Gomes
@since 10/04/2024
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/horarios?cDtIni=20240101&cDtFim=20240105

/*/
//-------------------------------------------------------------------
WSMETHOD GET horariosH7G WSRECEIVE cDtIni, cDtFim, escala, filter WSREST FRETAMENTOURBANO

    Local oResponse  := JsonObject():New()
    Local cDataIni   := Self:cDtIni
    Local cDataFim   := Self:cDtFim
    Local cCodEscala := Self:escala
    Local cFilter    := Self:filter
    Local cQuery     := ''
    Local cAlias     := GetNextAlias()
    Local nIndex     := 0
    Local nId        := 0
    Local nIdxAloc   := 0

    Default cCodEscala := ''
    Default cFilter := ''

	Self:SetContentType("application/json")

    cQuery := " SELECT H7G_HRINIC INICIO,"
    cQuery +=        " H7G_HRFINA FINAL,"
    cQuery +=        " H7F_DATA   DATAH7F"
    cQuery += " FROM " + RetSqlName('H7E') + " H7E "
    cQuery +=        " INNER JOIN  " + RetSqlName('H7F') + " H7F "
    cQuery +=                " ON ( H7F.H7F_FILIAL = H7E.H7E_FILIAL"
    cQuery +=                     " AND H7F.H7F_CODH7E = H7E.H7E_CODIGO"
    If !Empty(cCodEscala)
        cQuery +=                     " AND H7F.H7F_CODH76 != '" + cCodEscala + "'"
    EndIf
    cQuery +=                     " AND H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
    cQuery +=                     " AND H7F.D_E_L_E_T_ = '' )"
    cQuery +=        " INNER JOIN " + RetSqlName('H7G') + " H7G "
    cQuery +=                " ON ( H7G.H7G_FILIAL = H7E.H7E_FILIAL"
    cQuery +=                     " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO "

    If !Empty(cFilter)
        cQuery += cFilter
    EndIf
   
    cQuery +=                     " AND H7G.D_E_L_E_T_ = '' )"
    cQuery += " WHERE  H7E_FILIAL = '" + xFilial("H7E") + "'"
    cQuery +=        " AND H7E.D_E_L_E_T_ = ''"
    cQuery += " GROUP  BY H7G_HRINIC,"
    cQuery +=           " H7G_HRFINA,"
    cQuery +=           " H7F_DATA "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

    (cAlias)->(DbGoTop())

    oResponse['Horarios'] := {}

    While ( cAlias )->(!EoF())
        nId := aScan(oResponse['Horarios'],{|x| x['inicio'] == (cAlias)->INICIO .AND. x['final'] == (cAlias)->FINAL})
        If nId == 0
            nIndex++

            aadd(oResponse['Horarios'], JsonObject(): New())

            oResponse['Horarios'][nIndex]['inicio'] := ((cAlias)->INICIO ) 
            oResponse['Horarios'][nIndex]['final']  := ((cAlias)->FINAL ) 
            oResponse['Horarios'][nIndex]['dataAlocada'] := {}
                
                Aadd(oResponse['Horarios'][nIndex]['dataAlocada'], JsonObject():New())

                aTail(oResponse['Horarios'][nIndex]['dataAlocada'])['data']      := AllTrim( (cAlias)->DATAH7F )
        Else

            nIdxAloc := Len(oResponse['Horarios'][nId]["dataAlocada"]) + 1
            Aadd(oResponse['Horarios'][nId]['dataAlocada'], JsonObject():New())

            oResponse['Horarios'][nId]['dataAlocada'][nIdxAloc]['data']      := AllTrim( (cAlias)->DATAH7F )
        EndIf
            ( cAlias )->(DbSkip())
    EndDo

    ( cAlias )->(DbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET colaboradorView
Lista horatios que estão com veiculos/motoristas e cobradores vinculados

@author Breno Gomes
@since 20/05/2024
@version 1.0

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/colaboradorView?cDtIni=20240101&cDtFim=20240105?filter=and GYG_CODIGO='000667'

/*/
//-------------------------------------------------------------------
WSMETHOD GET colaboradorView WSRECEIVE cDtIni, cDtFim, filter WSREST FRETAMENTOURBANO

    Local oResponse  := JsonObject():New()
    Local cDataIni   := Self:cDtIni
    Local cDataFim   := Self:cDtFim
    Local cFilter    := Self:filter
    Local cQuery     := ''
    Local cAlias     := GetNextAlias()
    Local nIndex     := 0
    local nI         := 0
    Local nQtdDias   := DateDiffDay(sTod(cDataIni), sToD(cDataFim)) + 1
    Local dDia       := ''
    Local oSituacao  := nil

    Default cFilter := ''

    cQuery := qryColaboradores(cDataIni, cDataFim, '', cFilter)

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

    (cAlias)->(DbGoTop())
    Self:SetContentType("application/json")

    oResponse['colaboradores'] := {}
    dDia := sTod(cDataIni)
    oSituacao := qrySituacao((cAlias)->CODGYG, cDataIni, cDataFim )
    
    for nI := 1 to nQtdDias

        aadd(oResponse['colaboradores'], JsonObject(): New())
        aTail(oResponse['colaboradores'])['codigo']    := ( cAlias )->CODGYG
        aTail(oResponse['colaboradores'])['matricula'] := ( cAlias )->MATRICULA
        aTail(oResponse['colaboradores'])['nome']      := ( cAlias )->NOME
        aTail(oResponse['colaboradores'])['dia']       := dDia
        If Len(oSituacao['situacao']) > 0 .And. (nId := aScan(oSituacao['situacao'],{|x| x['inicio'] == dDia .Or. (x['codSituacao'] != '4' .and. x['inicio'] <= dDia .and. ( Empty(dToS(x['final'])) .Or. x['final'] >= dDia )) })) > 0 
            aTail(oResponse['colaboradores'])['situacao'] := oSituacao['situacao'][nId]['descSituacao']
        Endif
        
        aTail(oResponse['colaboradores'])['escala']   := ''

        dDia := dDia + 1
    next nI
    While ( cAlias )->(!EoF())
        if !Empty(( cAlias )->MOTORISTA) .Or. !Empty(( cAlias )->COBRADOR)
            nIndex := aScan(oResponse['colaboradores'],{|x| x['dia'] == (sToD((cAlias)->DIA ))})
            if nIndex > 0
                oResponse['colaboradores'][nIndex]['escala']       := (cAlias)->ESCALA + " - " +(cAlias)->DESCESCALA
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
WSMETHOD GET veicTL WSRECEIVE cData, filter WSREST FRETAMENTOURBANO

	Local oResponse := Nil
    Local cData     := Self:cData
    Local cFilter   := Self:filter

	Self:SetContentType("application/json")

    oResponse := qryVeicTimeLine(cData, cFilter)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} qryVeicTimeLine
Busca os recursos existentes na base e suas alocações se houver

@author Silas Gomes
@since 16/05/2026
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function qryVeicTimeLine(cData, cFilter)

    Local cQuery    := ''
    Local cAlias    := GetNextAlias()
    Local oResponse := JsonObject():New()
    Local nIndex    := 0
    Local nId       := 0
    Local nViagem   := 0
    Local nTrecho   := 0
    
    Default cData   := ''
    Default cFilter := ''

    cQuery := " SELECT H70.H70_FILIAL FILIAL, "
    cQuery +=       " H70.H70_CODVEI CODVEICULO, "
    cQuery +=       " T9.T9_PLACA PLACA, "
    cQuery +=       " H7G.H7G_PREFIX PREFIXO, "
    cQuery +=       " H7G.H7G_CODH77 VIAGEM, "
    cQuery +=       " H7G.H7G_CODH78 TRECHO, "
    cQuery +=       " H7G.H7G_CODH6V LINHA, "
    cQuery +=       " H7G.H7G_DSCLIN DESCLIN, "
    cQuery +=       " H7G.H7G_HRINIC HRINIC, "
    cQuery +=       " H7G.H7G_HRFINA HRFINAL, "
    cQuery +=       " H7G.H7G_TIPO TIPO, "
    cQuery +=       " H7F.H7F_DATA DIA "
    cQuery += " FROM " + RetSqlName('H70') + " H70 "
    cQuery += " INNER JOIN " + RetSqlName('ST9') + " T9 "
    cQuery +=   " ON (T9.T9_FILIAL = H70.H70_FILIAL "
    cQuery +=       " AND T9.T9_CODBEM = H70.H70_CODVEI "
    cQuery +=       " AND H70.H70_STATUS = '1' "
    cQuery +=       " AND T9.D_E_L_E_T_ = '') "
    cQuery += " LEFT JOIN " + RetSqlName('H7G') + " H7G "
    cQuery +=   " ON (H7G.H7G_FILIAL = H70.H70_FILIAL "
    cQuery +=       " AND H7G.H7G_CODH70 = H70.H70_CODVEI "
    cQuery +=       " AND H7G.D_E_L_E_T_ = '') "
    cQuery += " LEFT JOIN " + RetSqlName('H7F') + " H7F "
    cQuery +=   " ON (H7F.H7F_FILIAL = H70.H70_FILIAL "
    cQuery +=       " AND H7F.H7F_CODIGO = H7G.H7G_CODH7F "
    cQuery +=       " AND H7F.D_E_L_E_T_ = '') "
    cQuery += " LEFT JOIN " + RetSqlName('H77') + " H77 "
    cQuery +=   " ON (H77.H77_CODH6V = H7G.H7G_CODH6V "
    cQuery +=       " AND H77.D_E_L_E_T_ = '')
    cQuery += " LEFT JOIN " + RetSqlName('H78') + " H78 "
    cQuery +=   " ON (H78.H78_CODH76 = H77.H77_CODH76
    cQuery +=       " AND H78.D_E_L_E_T_ = '')
    cQuery += " WHERE H70.D_E_L_E_T_ = '' "
    cQuery +=   " AND H7F.H7F_DATA BETWEEN '" + cData + "' AND '" + cData + "'"
    cQuery +=   " AND H70.H70_FILIAL = '" + xFilial('H70') + "'"

    If !Empty(cFilter)
        cQuery += cFilter
    EndIf

    cQuery += " GROUP BY H70.H70_FILIAL, "
    cQuery +=       " H70.H70_CODVEI, "
    cQuery +=       " T9.T9_PLACA, "
    cQuery +=       " H7G.H7G_PREFIX, "
    cQuery +=       " H7G.H7G_CODH77, "
    cQuery +=       " H7G.H7G_CODH78, "
    cQuery +=       " H7G.H7G_CODH6V, "
    cQuery +=       " H7G.H7G_DSCLIN, "
    cQuery +=       " H7G.H7G_HRINIC, "
    cQuery +=       " H7G.H7G_HRFINA, "
    cQuery +=       " H7G.H7G_TIPO, "
    cQuery +=       " H7F.H7F_DATA "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

    (cAlias)->(DbGoTop())

    oResponse['Veiculos'] := {}

    While (cAlias)-> (!EoF())
        nId := aScan(oResponse['Veiculos'], {|x| x['pkVeiculo'] == (((cAlias)->FILIAL + (cAlias)->CODVEICULO) )})

        If nId == 0
            nIndex++

            aadd(oResponse['Veiculos'], JsonObject(): New())

            oResponse[ 'Veiculos' ][nIndex][ 'pkVeiculo' ] := ((cAlias)->FILIAL + (cAlias)->CODVEICULO)
            oResponse[ 'Veiculos' ][nIndex][ 'veiculo' ]   := AllTrim( (cAlias)->CODVEICULO )
            oResponse[ 'Veiculos' ][nIndex][ 'placa' ]     := AllTrim( (cAlias)->PLACA )
            oResponse[ 'Veiculos' ][nIndex][ 'prefixo' ]   := AllTrim( (cAlias)->PREFIXO )

            If !Empty( (cAlias)->VIAGEM )

                oResponse[ 'Veiculos' ][nIndex][ 'viagens' ] := {}
                aadd(oResponse[ 'Veiculos' ][nIndex][ 'viagens' ], JsonObject():New())

                oResponse[ 'Veiculos' ][nIndex][ 'viagens' ][1][ 'data' ]      := AllTrim( (cAlias)->DIA )
                oResponse[ 'Veiculos' ][nIndex][ 'viagens' ][1][ 'codViagem' ] := AllTrim( (cAlias)->VIAGEM )
                oResponse[ 'Veiculos' ][nIndex][ 'viagens' ][1][ 'linha' ]     := EncodeUTF8( AllTrim( (cAlias)->LINHA ) + " - " + AllTrim( (cAlias)->DESCLIN ) )
                oResponse[ 'Veiculos' ][nIndex][ 'viagens' ][1][ 'tipo' ]      := AllTrim( (cAlias)->TIPO )
                oResponse[ 'Veiculos' ][nIndex][ 'viagens' ][1][ 'inicio' ]    := AllTrim( (cAlias)->HRINIC )
                oResponse[ 'Veiculos' ][nIndex][ 'viagens' ][1][ 'fim' ]       := AllTrim( (cAlias)->HRFINAL )

            ElseIf !Empty( (cAlias)->TRECHO )

                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ] := {}
                aadd(oResponse[ 'Veiculos' ][nIndex][ 'trechos' ], JsonObject():New())

                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][1][ 'data' ]      := AllTrim( (cAlias)->DIA )
                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][1][ 'codTrecho' ] := AllTrim( (cAlias)->TRECHO )
                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][1][ 'tipo' ]      := AllTrim( (cAlias)->TIPO )
                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][1][ 'inicio' ]    := AllTrim( (cAlias)->HRINIC )
                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][1][ 'fim' ]       := AllTrim( (cAlias)->HRFINAL )

            EndIf
        
        Else 
            If !Empty( (cAlias)->VIAGEM )

                If Empty(oResponse[ 'Veiculos' ][nId][ 'viagens' ])
                    oResponse[ 'Veiculos' ][nId][ 'viagens' ] := {}
                EndIf

                nViagem := Len(oResponse[ 'Veiculos' ][nId][ 'viagens' ]) + 1

                aadd(oResponse[ 'Veiculos' ][nId][ 'viagens' ], JsonObject():New())

                oResponse[ 'Veiculos' ][nId][ 'viagens' ][nViagem][ 'data' ]      := AllTrim( (cAlias)->DIA )
                oResponse[ 'Veiculos' ][nId][ 'viagens' ][nViagem][ 'codViagem' ] := AllTrim( (cAlias)->VIAGEM )
                oResponse[ 'Veiculos' ][nId][ 'viagens' ][nViagem][ 'linha' ]     := EncodeUTF8( AllTrim( (cAlias)->LINHA ) + " - " + AllTrim( (cAlias)->DESCLIN ) )
                oResponse[ 'Veiculos' ][nId][ 'viagens' ][nViagem][ 'tipo' ]      := AllTrim( (cAlias)->TIPO )
                oResponse[ 'Veiculos' ][nId][ 'viagens' ][nViagem][ 'inicio' ]    := AllTrim( (cAlias)->HRINIC )
                oResponse[ 'Veiculos' ][nId][ 'viagens' ][nViagem][ 'fim' ]       := AllTrim( (cAlias)->HRFINAL )

            
            ElseIf !Empty( (cAlias)->TRECHO )

                nTrecho := Len(oResponse[ 'Veiculos' ][nId][ 'trechos' ]) + 1

                aadd(oResponse[ 'Veiculos' ][nIndex][ 'trechos' ], JsonObject():New())

                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][nTrecho][ 'data' ]      := AllTrim( (cAlias)->DIA )
                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][nTrecho][ 'codTrecho' ] := AllTrim( (cAlias)->TRECHO )
                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][nTrecho][ 'tipo' ]      := AllTrim( (cAlias)->TIPO )
                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][nTrecho][ 'inicio' ]    := AllTrim( (cAlias)->HRINIC )
                oResponse[ 'Veiculos' ][nIndex][ 'trechos' ][nTrecho][ 'fim' ]       := AllTrim( (cAlias)->HRFINAL )
            
            EndIf

        EndIf

        ( cAlias )->(DbSkip())
        
    EndDo

     ( cAlias )->(DbCloseArea())

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET colabTL
    Método para buscar os colaboradores existentes na base para timeline

    @author Silas Gomes
    @since 16/05/2024
    @version 1.0

/*/
//-------------------------------------------------------------------
WSMETHOD GET colabTL WSRECEIVE cData, filter WSREST FRETAMENTOURBANO

	Local oResponse := Nil
    Local cData     := Self:cData
    Local cFilter   := Self:filter

	Self:SetContentType("application/json")

    oResponse := qryColabTimeLine(cData, cFilter)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} qryColabTimeLine
    Busca os colaboradores existentes na base para timeline

    @author Silas Gomes
    @since 16/05/2026
    @version 1.0

/*/
//-------------------------------------------------------------------
Static Function qryColabTimeLine(cData, cFilter)

    Local cQuery    := ''
    Local cAlias    := GetNextAlias()
    Local oResponse := JsonObject():New()
    Local nIndex    := 0
    Local nId       := 0
    Local nViagem   := 0
    
    Default cData   := ''
    Default cFilter := ''

    cQuery += " SELECT GYG.GYG_FILIAL FILIAL, "
    cQuery +=       " GYG.GYG_CODIGO CODIGO, "
    cQuery +=       " GYG.GYG_RECCOD RECURSO, "
    cQuery +=       " GYK.GYK_DESCRI DESCRECURSO, "
    cQuery +=       " GYG.GYG_NOME NOME, "
    cQuery +=       " H7G.H7G_CODH77 VIAGEM, "
    cQuery +=       " H7G.H7G_CODH78 TRECHO, "
    cQuery +=       " H7G.H7G_CODH6V LINHA, "
    cQuery +=       " H7G.H7G_DSCLIN DESCLIN, "
    cQuery +=       " H7F.H7F_DATA DIA, "
    cQuery +=       " H7G.H7G_HRINIC HRINIC, "
    cQuery +=       " H7G.H7G_HRFINA HRFINAL, "
    cQuery +=       " H7G.H7G_TIPO TIPO "
	cQuery += " FROM " + RetSqlName('GYG') + " GYG "
	cQuery += " INNER JOIN " + RetSqlName('GYK') + " GYK "
	cQuery +=   " ON (GYK.GYK_CODIGO = GYG.GYG_RECCOD "
	cQuery +=       " AND GYK.D_E_L_E_T_ = '') "
	cQuery += " LEFT JOIN " + RetSqlName('H7G') + " H7G "
	cQuery +=   " ON (H7G.H7G_CODGYG = GYG.GYG_CODIGO OR H7G.H7G_CODCOB = GYG.GYG_CODIGO "
	cQuery +=       " AND H7G.D_E_L_E_T_ = '') "
	cQuery += " LEFT JOIN " + RetSqlName('H7F') + " H7F "
	cQuery +=   " ON (H7F.H7F_FILIAL = H7G.H7G_FILIAL "
	cQuery +=       " AND H7F.H7F_CODIGO = H7G.H7G_CODH7F "
	cQuery +=       " AND  H7F.D_E_L_E_T_ = '') "
    cQuery += " LEFT JOIN " + RetSqlName('H77') + " H77 "
    cQuery +=   " ON (H77.H77_CODH6V = H7G.H7G_CODH6V "
    cQuery +=       " AND H77.D_E_L_E_T_ = '')
    cQuery += " LEFT JOIN " + RetSqlName('H78') + " H78 "
    cQuery +=   " ON (H78.H78_CODH76 = H77.H77_CODH76
    cQuery +=       " AND H78.D_E_L_E_T_ = '')
	cQuery += " WHERE GYG.D_E_L_E_T_ = '' "
	cQuery +=   " AND H7F.H7F_DATA BETWEEN '" + cData + "' AND '" + cData + "'"
	cQuery +=   " AND GYG.GYG_FILIAL = '" + xFilial("GYG") + "'"

    If !Empty(cFilter)
        cQuery += cFilter
    EndIf

	cQuery += " GROUP BY GYG.GYG_FILIAL, "
    cQuery +=       "GYG.GYG_CODIGO, "
    cQuery +=       "GYG.GYG_RECCOD, "
    cQuery +=       "GYK.GYK_DESCRI, "
    cQuery +=       "GYG.GYG_NOME, "
    cQuery +=       "H7G.H7G_CODH77, "
    cQuery +=       "H7G.H7G_CODH78, "
    cQuery +=       "H7G.H7G_CODH6V, "
    cQuery +=       "H7G.H7G_DSCLIN, "
    cQuery +=       "H7F.H7F_DATA, "
    cQuery +=       "H7G.H7G_HRINIC, "
    cQuery +=       "H7G.H7G_HRFINA, "
    cQuery +=       "H7G.H7G_TIPO "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

    (cAlias)->(DbGoTop())

    oResponse['Colaboradores'] := {}

    While (cAlias)-> (!EoF())
        nId := aScan(oResponse['Colaboradores'], {|x| x['pkColaborador'] == (((cAlias)->FILIAL + (cAlias)->CODIGO) )})

        If nId == 0
            nIndex++

            aadd(oResponse['Colaboradores'], JsonObject(): New())

            oResponse[ 'Colaboradores' ][nIndex][ 'pkColaborador' ] := ((cAlias)->FILIAL + (cAlias)->CODIGO)
            oResponse[ 'Colaboradores' ][nIndex][ 'recurso' ]       := EncodeUTF8( AllTrim( (cAlias)->RECURSO ) + " - " + AllTrim( (cAlias)->DESCRECURSO ) )
            oResponse[ 'Colaboradores' ][nIndex][ 'nome' ]          := EncodeUTF8( AllTrim( (cAlias)->NOME ) )

            If !Empty( (cAlias)->VIAGEM )

                oResponse[ 'Colaboradores' ][nIndex][ 'viagens' ] := {}
                aadd(oResponse[ 'Colaboradores' ][nIndex][ 'viagens' ], JsonObject():New())

                oResponse[ 'Colaboradores' ][nIndex][ 'viagens' ][1][ 'data' ]      := AllTrim( (cAlias)->DIA )
                oResponse[ 'Colaboradores' ][nIndex][ 'viagens' ][1][ 'codViagem' ] := AllTrim( (cAlias)->VIAGEM )
                oResponse[ 'Colaboradores' ][nIndex][ 'viagens' ][1][ 'linha' ]     := EncodeUTF8( AllTrim( (cAlias)->LINHA ) + " - " + AllTrim( (cAlias)->DESCLIN ) )
                oResponse[ 'Colaboradores' ][nIndex][ 'viagens' ][1][ 'tipo' ]      := AllTrim( (cAlias)->TIPO )
                oResponse[ 'Colaboradores' ][nIndex][ 'viagens' ][1][ 'inicio' ]    := AllTrim( (cAlias)->HRINIC )
                oResponse[ 'Colaboradores' ][nIndex][ 'viagens' ][1][ 'fim' ]       := AllTrim( (cAlias)->HRFINAL )

            ElseIf !Empty( (cAlias)->TRECHO )

                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ] := {}
                aadd(oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ], JsonObject():New())

                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][1][ 'data' ]      := AllTrim( (cAlias)->DIA )
                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][1][ 'codTrecho' ] := AllTrim( (cAlias)->TRECHO )
                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][1][ 'tipo' ]      := AllTrim( (cAlias)->TIPO )
                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][1][ 'inicio' ]    := AllTrim( (cAlias)->HRINIC )
                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][1][ 'fim' ]       := AllTrim( (cAlias)->HRFINAL )

            EndIf   

        Else
            If !Empty( (cAlias)->VIAGEM )

                If Empty(oResponse[ 'Colaboradores' ][nId][ 'viagens' ])
                    oResponse[ 'Colaboradores' ][nId][ 'viagens' ] := {}
                EndIf

                nViagem := Len(oResponse[ 'Colaboradores' ][nId][ 'viagens' ]) + 1

                aadd(oResponse[ 'Colaboradores' ][nId][ 'viagens' ], JsonObject():New())

                oResponse[ 'Colaboradores' ][nId][ 'viagens' ][nViagem][ 'data' ]      := AllTrim( (cAlias)->DIA )
                oResponse[ 'Colaboradores' ][nId][ 'viagens' ][nViagem][ 'codViagem' ] := AllTrim( (cAlias)->VIAGEM )
                oResponse[ 'Colaboradores' ][nId][ 'viagens' ][nViagem][ 'linha' ]     := EncodeUTF8( AllTrim( (cAlias)->LINHA ) + " - " + AllTrim( (cAlias)->DESCLIN ) )
                oResponse[ 'Colaboradores' ][nId][ 'viagens' ][nViagem][ 'tipo' ]      := AllTrim( (cAlias)->TIPO )
                oResponse[ 'Colaboradores' ][nId][ 'viagens' ][nViagem][ 'inicio' ]    := AllTrim( (cAlias)->HRINIC )
                oResponse[ 'Colaboradores' ][nId][ 'viagens' ][nViagem][ 'fim' ]       := AllTrim( (cAlias)->HRFINAL )

            ElseIf !Empty( (cAlias)->TRECHO )

                nTrecho := Len(oResponse[ 'Colaboradores' ][nId][ 'trechos' ]) + 1

                aadd(oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ], JsonObject():New())

                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][nTrecho][ 'data' ]      := AllTrim( (cAlias)->DIA )
                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][nTrecho][ 'codTrecho' ] := AllTrim( (cAlias)->TRECHO )
                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][nTrecho][ 'tipo' ]      := AllTrim( (cAlias)->TIPO )
                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][nTrecho][ 'inicio' ]    := AllTrim( (cAlias)->HRINIC )
                oResponse[ 'Colaboradores' ][nIndex][ 'trechos' ][nTrecho][ 'fim' ]       := AllTrim( (cAlias)->HRFINAL )
            
            EndIf
        EndIf

        ( cAlias )->(DbSkip())
        
    EndDo

     ( cAlias )->(DbCloseArea())

Return oResponse


//-------------------------------------------------------------------
/*/{Protheus.doc} GET sqlName
Pesquisa o sufixo da tabela informada

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/FRETAMENTOURBANO/sqlName/{tabela}
/*/
//-------------------------------------------------------------------
WSMETHOD GET sqlName PATHPARAM tabela WSREST FRETAMENTOURBANO

    Local oResponse := JsonObject():New()

    Self:SetContentType("application/json")
    oResponse['nameTabela'] := RetSqlName(Self:tabela)

    Self:SetResponse(oResponse:toJson())
    oResponse:fromJson("{}")
    oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} UrbBscManut
    Retorna situação do Veículo se está Em Manutencao;Manutencao Finalizada;Disponivel;Indisponivel

    @author Flavio Oliveira
    @since 27/05/2024  
    @version 1.0
    @param cCodVeic, character, (Descrição do parâmetro)
    @param dDtRef, data, (Descrição do parâmetro)

/*/
//-------------------------------------------------------------------
Function UrbBscManut(cFilVeic, cCodVeic, dDtRef, lVerifyDay, dDtFim, lCombo)

	Local aAreaco    := GetArea()
	Local aAreaTF    := STF->(GetArea())
	Local aAreaTJ    := STJ->(GetArea())
    Local aRetorno   := {}
    Local dData      := dDatabase

	Default cFilVeic := ""
    Default cCodVeic := ""
	Default dDtRef   := dDatabase
	Default dDtFim   := dDatabase
    
    dData := dDtRef
    ST9->(DbSetOrder(1))    //T9_FILIAL+T9_CODBEM

    If ( ST9->( dbSeek( xFilial('ST9') + cCodVeic ) ) ) //Se encontrar o Bem

        If ST9->T9_SITBEM == "A"            

            STJ->(DbSetOrder(6))    //TJ_FILIAL+TJ_TIPOOS+TJ_CODBEM+TJ_SERVICO+TJ_SEQRELA+DTOS(TJ_DTORIGI)+TJ_SITUACA		

            If ( STJ->( dbSeek( xFilial('STJ') + "B" +cCodVeic ) ) )
            
                Do While !EoF() .And. STJ->TJ_FILIAL + STJ->TJ_TIPOOS + STJ->TJ_CODBEM == xFilial( 'STJ' ) + "B" + cCodVeic 

                    If STJ->TJ_SITUACA <> "C"
                        If STJ->TJ_TERMINO == "N" .And. STJ->TJ_DTMPINI <= dDtRef .And. STJ->TJ_DTMPINI <= dDtFim 
							If lCombo 
								aAdd(aRetorno, {"6", "Ordem de serviço em aberto" + ' - ' + STJ->TJ_ORDEM , Dtos(STJ->TJ_DTMPINI), DtoS(STJ->TJ_DTMPFIM) })
								Exit
							Else 
								aAdd(aRetorno, {"3", "Em Manutenção" + ' - ' + STJ->TJ_ORDEM, Dtos(STJ->TJ_DTMPINI), DtoS(STJ->TJ_DTMPFIM) })
                                Exit
							EndIf
                        Else
                            Do While dData <= dDtFim
                                If STJ->TJ_TERMINO == "N" .AND. ( dData >= STJ->TJ_DTMPINI .AND. dData <= STJ->TJ_DTMPFIM .AND. lVerifyDay ) //C=Cancelado;L=Liberado ;P=Pendente //N=Não;S=Sim
                                    aAdd(aRetorno, {"3", "Em Manutenção" + ' - ' + STJ->TJ_ORDEM, Dtos(STJ->TJ_DTMPINI), DtoS(STJ->TJ_DTMPFIM) })
                                    Exit

                                ElseIf STJ->TJ_TERMINO == "S" .And. ( dData >= STJ->TJ_DTPRINI .AND. dData <= STJ->TJ_DTPRFIM )
                                    aAdd(aRetorno, {"4", "Manutenção Finalizada" + ' - ' + STJ->TJ_ORDEM, DtoS(STJ->TJ_DTPRINI), DtoS(STJ->TJ_DTPRFIM) })
                                    Exit

                                ElseIf STJ->TJ_TERMINO == 'N' .And. ( dData >= STJ->TJ_DTMPINI .AND. dData <= STJ->TJ_DTMPFIM )
                                    aAdd(aRetorno, {"5", "Manutenção Programada" + ' - ' + STJ->TJ_ORDEM, DtoS(STJ->TJ_DTMPINI), DtoS(STJ->TJ_DTMPFIM) })
                                    Exit

                                EndIf
                                dData += 1
                            Enddo
                            dData := dDtRef
                        EndIf
                    EndIf
                    
                    STJ->(dbSkip())

                Enddo
            Else
                aAdd(aRetorno, {"1", "Disponível", DtoS(dDtRef), DtoS(dDtRef)})

            EndIf

        Else 
            aAdd(aRetorno, {"2", "Indisponivel", DtoS(dDtRef), DtoS(dDtRef)})
        EndIf

    EndIf

	RestArea(aAreaTJ)
	RestArea(aAreaTF)
	RestArea(aAreaco)

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GET turno
Efetua o GET de turno 

@author Silas Gomes
@since 26/06/2024
@param filter - Filtro a ser aplicado na requisição - ex H7_CODIGO = '001'

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/turno

/*/
//-------------------------------------------------------------------
WSMETHOD GET turno WSRECEIVE filter WSREST FRETAMENTOURBANO

    Local cAliasTmp := GetNextAlias()
    Local cFilter   := self:filter
    Local cQuery    := ""
    Local nIndex    := 0
    Local oResponse := JsonObject():New()

    cQuery := " SELECT "
    cQuery +=       " H7_CODIGO CODIGO, "
    cQuery +=       " H7_DESCRI DESCRI "
    cQuery += " FROM " + RetSqlName('SH7')
    cQuery += " WHERE H7_FILIAL = '" + XFilial('SH7') + "' "
    cQuery +=       " AND D_E_L_E_T_ = '' "

    If !Empty(cFilter)
        cQuery += cFilter
    EndIf

    cQuery += " GROUP BY "
    cQuery +=       " H7_CODIGO, "
    cQuery +=       " H7_DESCRI "    

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )
   
    (cAliasTmp)->(DbGoTop())

    oResponse['Turno'] := {}    

    While ( cAliasTmp )-> (!EoF())

        nIndex++

        aadd(oResponse['Turno'], JsonObject(): New())
       
        oResponse[ 'Turno' ][nIndex][ 'codigo' ]    := AllTrim( (cAliasTmp)->CODIGO )
        oResponse[ 'Turno' ][nIndex][ 'descricao' ] := AllTrim( (cAliasTmp)->DESCRI )

        ( cAliasTmp )->(DbSkip())

    EndDo

    ( cAliasTmp )->(DbCloseArea())

    self:SetResponse(oResponse:toJson())
    oResponse:fromJson("{}")
    oResponse := NIL
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} qrySituacao
    Query para trazer colaboradores com atestado/folga/ferias/afastamento dentro de um certo periodo

    @author Silas Gomes
    @since 27//06/2024
    @param cMat - Matricula
    @param cDataIni - Data inicio
    @param cDataFim - Data fim

/*/
//-------------------------------------------------------------------
Static Function qrySituacao(cCodColab, cDataIni, cDataFim)

    Local cAliasTmp := GetNextAlias()
    Local cQuery    := ""
    Local nIndex    := 0
    Local oResponse := JsonObject():New()

    cQuery := " SELECT "
    cQuery +=       " GYG.GYG_CODIGO COLABORADOR, "
    cQuery +=       " SR8.R8_DATAINI INICIO, "
    cQuery +=       " SR8.R8_DATAFIM FINAL, "
    cQuery +=       " SR8.R8_DURACAO TEMPO, "
    cQuery +=       " H7R.H7R_DATA   DIA, "
	cQuery +=       " H7R.H7R_TIPO   TIPO, "
    cQuery +=       " SRH.RH_DATAINI DTINIFER, "
    cQuery +=       " SRH.RH_DATAFIM DTFIMFER, "
    cQuery +=       " RA.RA_SITFOLH  DEMISSAO "
    
    cQuery += " FROM " + RetSqlName('GYG') + " GYG "
    //Verifica atestado
    cQuery += " LEFT JOIN " + RetSqlName('SR8') + " SR8 "
    cQuery +=        " ON ( SR8.R8_FILIAL = '" + xFilial('SR8') + "' "
    cQuery +=             " AND SR8.R8_MAT = GYG.GYG_FUNCIO "
    cQuery +=             " AND ((('" + cDataIni + "' <= SR8.R8_DATAFIM OR SR8.R8_DATAFIM = '') AND '" + cDataFim + "' >= SR8.R8_DATAINI) "
    cQuery +=                    " OR (SR8.R8_DATAINI <= '" + cDataFim + "' AND (SR8.R8_DATAFIM >= '" + cDataIni + "' OR SR8.R8_DATAFIM = '')))"
    cQuery +=             " AND SR8.D_E_L_E_T_ = '') "
    //Verifica folga
    cQuery += " LEFT JOIN " + RetSqlName('H7R') + " H7R "
    cQuery +=        " ON ( H7R.H7R_FILIAL = '" + xFilial('H7R') + "' "
    cQuery +=             " AND H7R.H7R_COLAB = GYG.GYG_CODIGO"
    cQuery +=             " AND H7R.H7R_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
    cQuery +=             " AND H7R.D_E_L_E_T_ = '') "
    //Verifica ferias
    cQuery += " LEFT JOIN " + RetSqlName('SRH') + " SRH "
    cQuery +=        " ON ( SRH.RH_FILIAL = GYG.GYG_FILSRA "
    cQuery +=             " AND SRH.RH_MAT = GYG.GYG_FUNCIO "
    cQuery +=             " AND (('" + cDataIni + "' <= SRH.RH_DATAFIM AND '" + cDataFim + "' >= SRH.RH_DATAINI) "
    cQuery +=                    " OR (SRH.RH_DATAINI <= '" + cDataFim + "' AND SRH.RH_DATAFIM >= '" + cDataIni + "'))"
    cQuery +=             " AND SRH.D_E_L_E_T_ = '') "

    cQuery += " LEFT JOIN " + RetSqlName('SRA') + " RA "
    cQuery +=        " ON ( RA.RA_FILIAL = GYG.GYG_FILSRA "
    cQuery +=             " AND RA.RA_MAT = GYG.GYG_FUNCIO "
    cQuery +=             " AND RA.D_E_L_E_T_ = '' )"

    
    cQuery += " WHERE GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
    

    If !Empty(cCodColab)
        cQuery += " AND GYG.GYG_CODIGO = '" + cCodColab + "' "
    EndIf

    cQuery += " GROUP BY "
    cQuery +=       " GYG.GYG_CODIGO, "
    cQuery +=       " SR8.R8_DATAINI, "
    cQuery +=       " SR8.R8_DATAFIM, "
    cQuery +=       " SR8.R8_DURACAO, "
    cQuery +=       " H7R.H7R_DATA, "
    cQuery +=       " H7R.H7R_TIPO, "
    cQuery +=       " SRH.RH_DATAINI, "
    cQuery +=       " SRH.RH_DATAFIM, "
    cQuery +=       " RA.RA_SITFOLH  "


    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )
   
    (cAliasTmp)->(DbGoTop())

    oResponse['situacao'] := {}    

    While ( cAliasTmp )-> (!EoF())

       
        If !Empty((cAliasTmp)->DEMISSAO) .And. (cAliasTmp)->DEMISSAO == 'D'//Demitido
            nIndex++

            aadd(oResponse[ 'situacao' ], JsonObject(): New())
            oResponse[ 'situacao' ][nIndex][ 'codColab' ]     := AllTrim( (cAliasTmp)->COLABORADOR )
            oResponse[ 'situacao' ][nIndex][ 'inicio' ]       := sToD(cDataIni)
            oResponse[ 'situacao' ][nIndex][ 'final' ]        := sToD(cDataFim)
            oResponse[ 'situacao' ][nIndex][ 'codSituacao' ]  := '7'
            oResponse[ 'situacao' ][nIndex][ 'descSituacao' ] := 'DEMITIDO'

        ElseIf !Empty((cAliasTmp)->DTINIFER) .And. !Empty((cAliasTmp)->DTFIMFER) //Ferias
            nIndex++

            aadd(oResponse[ 'situacao' ], JsonObject(): New())
            oResponse[ 'situacao' ][nIndex][ 'codColab' ]     := AllTrim( (cAliasTmp)->COLABORADOR )
            oResponse[ 'situacao' ][nIndex][ 'inicio' ]       := sToD((cAliasTmp)->DTINIFER)
            oResponse[ 'situacao' ][nIndex][ 'final' ]        := sToD((cAliasTmp)->DTFIMFER)
            oResponse[ 'situacao' ][nIndex][ 'codSituacao' ]  := '2'
            oResponse[ 'situacao' ][nIndex][ 'descSituacao' ] := 'FERIAS'

        ElseIf !Empty((cAliasTmp)->TEMPO) .AND. !Empty((cAliasTmp)->INICIO)//Atestado ou afastado
            nIndex++

            aadd(oResponse[ 'situacao' ], JsonObject(): New())
            oResponse[ 'situacao' ][nIndex][ 'codColab' ]     := AllTrim( (cAliasTmp)->COLABORADOR )
            oResponse[ 'situacao' ][nIndex][ 'inicio' ]       := sToD((cAliasTmp)->INICIO)
            oResponse[ 'situacao' ][nIndex][ 'final' ]        := sToD((cAliasTmp)->FINAL)
            If (cAliasTmp)->TEMPO <= 14 .And. !Empty((cAliasTmp)->FINAL)
                oResponse[ 'situacao' ][nIndex][ 'codSituacao' ]  := '5'
                oResponse[ 'situacao' ][nIndex][ 'descSituacao' ] := 'ATESTADO'
            Else 
                oResponse[ 'situacao' ][nIndex][ 'codSituacao' ]  := '3'
                oResponse[ 'situacao' ][nIndex][ 'descSituacao' ] := 'AFASTADO'
            EndIf
        ElseIf !Empty((cAliasTmp)->TIPO) .And. !Empty((cAliasTmp)->DIA)//Folga
            nIndex++

            aadd(oResponse[ 'situacao' ], JsonObject(): New())
            oResponse[ 'situacao' ][nIndex][ 'codColab' ]     := AllTrim( (cAliasTmp)->COLABORADOR )
            oResponse[ 'situacao' ][nIndex][ 'inicio' ]       := sToD((cAliasTmp)->DIA)
            oResponse[ 'situacao' ][nIndex][ 'final' ]        := ''
            oResponse[ 'situacao' ][nIndex][ 'codSituacao' ]  := '4'
            
            If (cAliasTmp)->TIPO == '1'
                oResponse[ 'situacao' ][nIndex][ 'codSituacao' ]  := '1'
                oResponse[ 'situacao' ][nIndex][ 'descSituacao' ] := 'TRABALHADO'
            ElseIf (cAliasTmp)->TIPO == '4'
                oResponse[ 'situacao' ][nIndex][ 'descSituacao' ] := 'FOLGA'
            ElseIf (cAliasTmp)->TIPO == '5'
                oResponse[ 'situacao' ][nIndex][ 'descSituacao' ] := 'NÃO TRABALHADO'
            ElseIf (cAliasTmp)->TIPO == '6'
                oResponse[ 'situacao' ][nIndex][ 'descSituacao' ] := 'FALTA'
            Endif
        EndIf

        ( cAliasTmp )->(DbSkip())

    EndDo

    ( cAliasTmp )->(DbCloseArea())
    
Return oResponse

//-----------------------------------------------------------------
/*/{Protheus.doc} listFiliais
Busca todas as filiais que o usuário tem acesso.

@since 11/10/2019
@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/FRETAMENTOURBANO/listFiliais
/*/
//-----------------------------------------------------------------
WSMETHOD GET listFiliais WSREST FRETAMENTOURBANO
    Local nI          := 0
    Local aFiliais    := FWUsrEmp(__cUserID)
    Local cGrpCompany := ""
    Local cEmpFil     := ""
    Local oResponse  := JsonObject():New()

    Self:SetContentType("application/json")
    oResponse['filiais'] := {}
    If ValType(aFiliais) == "A" .And. Len(aFiliais) >= 1 
        If aFiliais[1] == "@@@@"//Se for Admin tem o acesso de todas as filiais
            aFiliais := FWLoadSM0()

            For nI := 1 To Len(aFiliais)

                Aadd(oResponse['filiais'], JsonObject():New())
                aTail(oResponse['filiais'])['codGrpCompany']   := aFiliais[nI][1]
                aTail(oResponse['filiais'])['fullCodeFilial']  := aFiliais[nI][2]
                aTail(oResponse['filiais'])['nameFilial']      := EncodeUTF8(AllTrim(aFiliais[nI][7]))

            Next nI
        Else
            For nI := 1 To Len(aFiliais)

                cGrpCompany := subStr(aFiliais[nI], 0, 2)
                cEmpFil := subStr(aFiliais[nI], 3)
                Aadd(oResponse['filiais'], JsonObject():New())
                aTail(oResponse['filiais'])['codGrpCompany']   := cGrpCompany
                aTail(oResponse['filiais'])['fullCodeFilial']  := cEmpFil
                aTail(oResponse['filiais'])['nameFilial']      := FWFilialName(cGrpCompany, cEmpFil, 1)
                
            Next nI
        EndIf
    EndIf

    Self:SetResponse(oResponse:toJson())
    oResponse:fromJson("{}")
    oResponse := NIL

    aSize(aFiliais, 0)

Return .T.

//-----------------------------------------------------------------
/*/{Protheus.doc} consultaCEP
    Método listar as informações do cep informado

    @since 26/08/2024
    @Author Silas Gomes
    @example GET -> http://127.0.0.1:12173/rest/FRETAMENTOURBANO/consultaCEP
/*/
//-----------------------------------------------------------------
WSMETHOD GET consultaCEP WSRECEIVE cep WSREST FRETAMENTOURBANO

    Local oRest     := FWRest():New("https://viacep.com.br")
    Local oJson     := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cCep      := self:cep
    Local cResult   := ""
    Local cError    := ""
    Local cJson     := ""

    oRest:setPath("/ws/" + cCep + "/json/")

    If oRest:Get()
        cResult := oRest:GetResult()
        cJson := oJson:FromJson(cResult)

        oResponse['Info'] := {}
        Aadd(oResponse['Info'], JsonObject():New())

        If !Empty(cJson)
            FWAlertError("Falha ao converter texto para Objeto JSON: " + CRLF + cErro, "Conversão JSON")
        Else

            If !Empty(oJson:GetJsonObject('cep'))
                oResponse['Info'][1]['cep'] := oJson:GetJsonObject('cep')
            EndIf

            If !Empty(oJson:GetJsonObject('logradouro'))
                oResponse['Info'][1]['logradouro'] := oJson:GetJsonObject('logradouro')
            EndIf

            If !Empty(oJson:GetJsonObject('complemento'))
                oResponse['Info'][1]['complemento'] := oJson:GetJsonObject('complemento')
            EndIf

            If !Empty(oJson:GetJsonObject('bairro'))
                oResponse['Info'][1]['bairro'] := oJson:GetJsonObject('bairro')
            EndIf

            If !Empty(oJson:GetJsonObject('localidade'))
                oResponse['Info'][1]['localidade'] := oJson:GetJsonObject('localidade')
            EndIf

            If !Empty(oJson:GetJsonObject('uf'))
                oResponse['Info'][1]['uf'] := oJson:GetJsonObject('uf')
            EndIf

            If !Empty(oJson:GetJsonObject('ibge'))
                oResponse['Info'][1]['ibge'] := oJson:GetJsonObject('ibge')
            EndIf

            If !Empty(oJson:GetJsonObject('gia'))
                oResponse['Info'][1]['gia'] := oJson:GetJsonObject('gia')
            EndIf

            If !Empty(oJson:GetJsonObject('ddd'))
                oResponse['Info'][1]['ddd'] := oJson:GetJsonObject('ddd')
            EndIf

            If !Empty(oJson:GetJsonObject('siafi'))
                oResponse['Info'][1]['siafi'] := oJson:GetJsonObject('siafi')
            EndIf

        EndIf

    Else
        cError := oRest:GetLastError()

        oResponse['Error'] := {}
        Aadd(oResponse['Error'], JsonObject():New())

        oResponse['Error'][1]['Mensagem'] := "Erro ao consultar CEP: " + cError

    EndIf

    self:SetResponse(oResponse:toJson())
    oResponse:fromJson("{}")
    oResponse := NIL

Return .T.


//-----------------------------------------------------------------
/*/{Protheus.doc} consultaCEP
    Método listar a quantidade de recursos filtrados pela escala

    @since 19/11/2024
    @Author Breno Gomes
    @example GET -> http://127.0.0.1:12173/rest/FRETAMENTOURBANO/qtdRecursos
/*/
//-----------------------------------------------------------------
WSMETHOD GET QtdRecursos WSRECEIVE escala WSREST FRETAMENTOURBANO

    Local cAliasTmp := GetNextAlias()
    Local cQuery    := ""
    Local cEscala   := Self:escala
    Local oResponse := JsonObject():New()

    cQuery := " SELECT "
    cQuery +=       " H76_QTVEIC QTDVEICULO,"
    cQuery +=       " H76_QTMOTO QTDMOTORISTA,"
    cQuery +=       " H76_QTCOBR QTDCOBRADOR"
    cQuery += " FROM " + RetSqlName('H76') + " H76"
    cQuery += " WHERE H76_FILIAL = '" + XFilial('H76') + "'"
    cQuery +=       " AND H76_CODIGO = '" + cEscala + "'"
    cQuery +=       " AND D_E_L_E_T_ = ''"

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )
   
    (cAliasTmp)->(DbGoTop())

    oResponse['recursos'] := {}    

    If ( cAliasTmp )-> (!EoF())

        aadd(oResponse[ 'recursos' ], JsonObject(): New())

        oResponse[ 'recursos' ][1][ 'veiculo' ] :=  (cAliasTmp)->QTDVEICULO 
        oResponse[ 'recursos' ][1][ 'motorita' ] := (cAliasTmp)->QTDMOTORISTA
        oResponse[ 'recursos' ][1][ 'cobrador' ] := (cAliasTmp)->QTDCOBRADOR
    EndIf
    
    ( cAliasTmp )->(DbCloseArea())
    self:SetResponse(oResponse:toJson())
    oResponse:fromJson("{}")
    oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET LinhaAlocada
Efetua o GET de linhas que tenha alocação - utilizado em escala diaria

@author Breno Gomes
@since 11/12/2024
@param cDtIni - data inicio do filtro 
@param cDtFim - data final do filtro 
@param filter - Filtro a ser aplicado na requisição - ex GI1_CDMUNI = '000425'

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/LinhaAlocada

/*/
//-------------------------------------------------------------------
WSMETHOD GET LinhaAlocada WSRECEIVE cDtIni, cDtFim, filter WSREST FRETAMENTOURBANO

    Local cAliasTmp := GetNextAlias()
    Local cDtIni    := Self:cDtIni
    Local cDtFim    := Self:cDtFim
    Local cFilter   := Self:filter
    Local cQuery    := ""
    Local nIndex    := 0
    Local oLinha    := JsonObject():New()

    Default cFilter := ''

    cQuery := " SELECT H6V_CODIGO CODIGO, "
    cQuery +=        " H6V_DESCRI DESCRICAO, "
    cQuery +=        " H6V_CODLIN CODLIN "
    cQuery += " FROM " + RetSqlName('H6V') + " H6V "
    cQuery += " WHERE H6V_FILIAL = '" + XFilial('H6V') + "'"
    cQuery +=       " AND H6V_STATUS = '1'"
    cQuery +=       " AND H6V_CODIGO IN ( "
    cQuery +=                             " SELECT H7G_CODH6V "
    cQuery +=                             " FROM " + RetSqlName('H7F') + " H7F "
    cQuery +=                                    " INNER JOIN " + RetSqlName('H7G') + " H7G "
    cQuery +=                                            " ON ( H7G_FILIAL = H7F_FILIAL "
    cQuery +=                                                 " AND H7G_CODH7F = H7F_CODIGO "
    cQuery +=                                                 " AND H7G.D_E_L_E_T_ = '') "
    cQuery +=                             " WHERE H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
    cQuery +=                                   " AND H7F.H7F_DATA BETWEEN '" + cDtIni + "' AND '" +  cDtFim +"'"
    cQuery +=                                   " AND H7F.D_E_L_E_T_ = ''"
    cQuery +=                             " GROUP  BY H7G_CODH6V) "
    If !Empty(cFilter)
        cQuery += cFilter
    EndIf
    cQuery += "     AND D_E_L_E_T_ = '' "

    cQuery += " GROUP BY "
    cQuery += " H6V_CODIGO, H6V_DESCRI, H6V_CODLIN "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp, .F., .F. )
   
    (cAliasTmp)->(DbGoTop())

    oLinha['Linhas'] := {}

    While ( cAliasTmp )-> (!EoF() .And. nIndex < 10)

        nIndex++

        aadd(oLinha[ 'Linhas' ], JsonObject(): New())

        oLinha['Linhas'][nIndex]['codigo']    := AllTrim( (cAliasTmp)->CODIGO )
        oLinha['Linhas'][nIndex]['descricao'] := AllTrim( (cAliasTmp)->DESCRICAO )
        oLinha['Linhas'][nIndex]['codLin']    := AllTrim( (cAliasTmp)->CODLIN )

        ( cAliasTmp )->(DbSkip())
    EndDo

    ( cAliasTmp )->(DbCloseArea())

    self:SetResponse(oLinha:toJson())
    oLinha:fromJson("{}")
    oLinha := NIL

Return .T.

//-------------------------------------------------------------------
// /*/{Protheus.doc} GET usaRH
// Consulta o status do módulo RH.
//
// @description Retorna um JSON indicando se o módulo de RH está ativado
// @example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/FRETAMENTOURBANO/usaRH
//-------------------------------------------------------------------
WSMETHOD GET usaRH WSREST FRETAMENTOURBANO

    Local oResponse := JsonObject():New()
    Self:SetContentType("application/json")

    oResponse['usaRH'] := SuperGetMV("MV_USARH")

    Self:SetResponse(oResponse:toJson())
    oResponse:fromJson("{}")
    oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET StatusDoc
Efetua o GET de situação do documento do colaborador

@author Silas Gomes
@since 22/12/2024
@param cColab - código do colaborador

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/FRETAMENTOURBANO/StatusDoc

/*/
//-------------------------------------------------------------------
WSMETHOD GET StatusDoc WSRECEIVE cColab, WSREST FRETAMENTOURBANO

    Local oQuery  := Nil
    Local cAlias  := ""
    Local cQuery  := ""
    Local cColab  := self:cColab
    Local nIndex  := 0
    Local oStatus := JsonObject():New()

    cQuery := " SELECT "
    cQuery +=   " G6V.G6V_FILIAL FILIAL, "
    cQuery +=   " G6V.G6V_CODIGO CODG6V, "
    cQuery +=   " G6V.G6V_TRECUR TPRECUR, "
    cQuery +=   " G6V.G6V_RECURS RECURSO, "
    cQuery +=   " GYG.GYG_NOME NOME, "
    cQuery +=   " G6V.G6V_STATUS STATUS "
    cQuery += " FROM ? G6V"
    cQuery +=   " INNER JOIN ? GYG "
    cQuery +=       " ON GYG.GYG_FILIAL = ? "
    cQuery +=       " AND GYG.GYG_CODIGO = G6V.G6V_RECURS "
    cQuery +=       " AND GYG.D_E_L_E_T_ = ? "
    cQuery += " WHERE G6V.G6V_FILIAL = ? "
    cQuery +=   " AND G6V.G6V_TRECUR = ? "
    cQuery +=   " AND G6V.G6V_RECURS = ? "

    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetUnsafe(1, RetSqlName("G6V"))
    oQuery:SetUnsafe(2, RetSqlName("GYG"))
    oQuery:SetString(3, xFilial("GYG"))
    oQuery:SetString(4, '')
    oQuery:SetString(5, xFilial("G6V"))
    oQuery:SetString(6, '1')
    oQuery:SetString(7, cColab)

    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery( cQuery )

    (cAlias)->(DbGoTop())

    oStatus['Info'] := {}

    While (cAlias)->(!EoF())
        nIndex++

        aadd(oStatus['Info'], JsonObject(): New())

        oStatus['Info'][nIndex]['filial']      := AllTrim( (cAlias)->FILIAL  )
        oStatus['Info'][nIndex]['codG6V']      := AllTrim( (cAlias)->CODG6V  )
        oStatus['Info'][nIndex]['tipoRecurso'] := AllTrim( (cAlias)->TPRECUR )
        oStatus['Info'][nIndex]['recurso']     := AllTrim( (cAlias)->RECURSO )
        oStatus['Info'][nIndex]['nome']        := AllTrim( (cAlias)->NOME    )
        oStatus['Info'][nIndex]['status']      := AllTrim( (cAlias)->STATUS  )

        ( cAlias )->(DbSkip())

    EndDo

    ( cAlias )->(DbCloseArea())

    self:SetResponse(oStatus:toJson())
    oStatus:fromJson("{}")
    oStatus := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET validUpdH75
Verifica se o horario selecionado tem vinculo com escala, se tiver, não deixa alterar

@param cCodH75  - código do horario em programação de linjha
@param cHoraIni - Hora inicio do item selecionado
@param cHoraFim - Hora final do item selecionado

@author Breno Gomes
@since 20/01/2025
@version 1.0

/*/
//-------------------------------------------------------------------
WSMETHOD GET validUpdH75 WSRECEIVE cCodH71 WSREST FRETAMENTOURBANO

    Local oResponse := JsonObject():New()
    Local cCodH71   := Self:cCodH71
    Local cQuery    := ''
	Local nIndex  	:= 0
    Local cAlias    := GetNextAlias()

	Default cCodH71 := ''
   
	cQuery := " SELECT H77_CODH73 codH73, "
	cQuery +=   	 " H77_CODH74 codH74, "
	cQuery +=   	 " H77_CODH75 codH75, "
	cQuery +=   	 " H76.H76_CODIGO Codigo, "
	cQuery +=   	 " H76.H76_DESCRI Descricao"
	cQuery +=   " FROM ?  H77 
	cQuery +=   " INNER JOIN ?  H76
	cQuery +=   	 " ON(H76.H76_FILIAL = H77.H77_FILIAL
	cQuery +=   		" AND H76.H76_CODIGO = H77.H77_CODH76
	cQuery +=   		" AND H76.D_E_L_E_T_ = '' )
	cQuery +=   " WHERE H77.H77_FILIAL = ? 
	cQuery +=   	 " AND H77.H77_CODH71 = ? 
	cQuery +=   	 " AND H77.D_E_L_E_T_ = '' 


    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)    
    oQuery:SetUnsafe(1, RetSqlName("H77"))
	oQuery:SetUnsafe(2, RetSqlName("H76"))
	oQuery:SetString(3, xFilial("H76"))
    oQuery:SetString(4, cCodH71)
    

    cQuery := oQuery:GetFixQuery()
    cAlias := MPSysOpenQuery( cQuery )

    (cAlias)->(DbGoTop())

    Self:SetContentType("application/json")

	oResponse['Info'] := {}
		
    While ( cAlias )->(!EoF())	
		nIndex++

        aadd(oResponse['Info'], JsonObject(): New())	

		oResponse['Info'][nIndex]['codH73'] := EncodeUTF8((cAlias)->codH73)
		oResponse['Info'][nIndex]['codH74'] := EncodeUTF8((cAlias)->codH74)
		oResponse['Info'][nIndex]['codH75'] := EncodeUTF8((cAlias)->codH75)
		oResponse['Info'][nIndex]['codEscala'] := EncodeUTF8((cAlias)->Codigo)
		oResponse['Info'][nIndex]['descEscala'] := EncodeUTF8((cAlias)->Descricao)
		( cAlias )->(DbSkip())	
	End

    ( cAlias )->(DbCloseArea())

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.
