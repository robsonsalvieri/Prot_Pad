#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PCPMonitorConsultas
Classe com os métodos para consultas dos dados nas propriedades do Monitor
@type Class
@author renan.roeder
@since 26/04/2023
@version P12.1.2310
@return Nil
/*/
Class PCPMonitorConsultas FROM LongNameClass
    Static Method BuscaRecursos(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc)
    Static Method BuscaFiliais(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc)
    Static Method BuscaProdutos(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc)
    Static Method BuscaUsuarios(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc)
    Static Method BuscaCadastroTabela(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc)
    Static Method BuscaCadastroTabelaGenerica(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc)
EndClass

/*/{Protheus.doc} BuscaCadastroTabela
Retorna uma lista de registros conforme a tabela parametrizada
@type Method
@author renan.roeder
@since 15/08/2023
@version P12.1.2310
@param  nPage     , numerico, Número da página
@param  nPageSize , numerico, Tamanho da página
@param  cValue    , caracter, Id do Registro
@param  cFilter   , caracter, Filtro da busca
@param  cOrder    , caracter, Ordem de busca
@param  cFilialFlt, caracter, Filial para consulta
@param  lItemCons , logico  , Indica se retorna uma lista de items
@param  cTabela   , caracter, Nome da tabela
@param  cCampoCod , caracter, Nome do campo chave
@param  cCampoDsc , caracter, Nome do campo descrição
@return aResult   , array   , Array preparado com o retorno da requisição
/*/
Method BuscaCadastroTabela(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc) Class PCPMonitorConsultas
    Local aResult    := {.T.,"",200}
    Local aLista     := {}
    Local aListaCad  := {}
    Local cAlias     := GetNextAlias()
    Local cCampoFil  := GetSx3Cache(SUBSTR(cCampoCod,1,At("_",cCampoCod)-1) + "_FILIAL","X3_CAMPO")
    Local cQuery     := ""
    Local cRegistros := ""
    Local lBuscaVal  := ValType(cValue) != "U"
    Local nIndice    := 0
    Local nPos       := 0
    Local nStart     := 0
    Local oJson      := JsonObject():New()

    cQuery := " SELECT "
    If !Empty(cCampoFil)
        cQuery += "   "+cTabela+"."+cCampoFil+","
    Else
        cCampoFil := "FILIAL"
        cQuery += "   '  ' AS "+cCampoFil+","
    EndIF
    cQuery += "   "+cTabela+"."+cCampoCod+", "
    cQuery += "   "+cTabela+"."+cCampoDsc+" "
    cQuery += " FROM " + RetSqlName(cTabela) + " "+cTabela+" "
    cQuery += " WHERE "+cTabela+".D_E_L_E_T_ = ' ' "
    If !Empty(cFilialFlt)
        cQuery += "   AND "+cTabela+"."+cCampoFil+" = '"+xFilial(cTabela,PadR(cFilialFlt, FWSizeFilial()))+"' "   
    EndIf
    If !Empty(cFilter)
        cQuery += "   AND (UPPER("+cTabela+"."+cCampoCod+") LIKE '%"+UPPER(cFilter)+"%' OR UPPER("+cTabela+"."+cCampoDsc+") LIKE '%"+UPPER(cFilter)+"%') "
    EndIf
    If !Empty(cValue)
        aListaCad := strTokArr(cValue,",")
        For nIndice := 1 To Len(aListaCad)
            If Empty(cRegistros)
                cRegistros := "'" + UPPER(aListaCad[nIndice]) + "'"
            Else
                cRegistros +=  ",'" + UPPER(aListaCad[nIndice]) + "'"
            EndIf            
        Next nIndice
        cQuery += " AND UPPER("+cTabela+"."+cCampoCod+") IN ("+cRegistros+") "
    EndIf
    cQuery += " ORDER BY "+cTabela+"."+cCampoCod+" "
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    While (cAlias)->(!Eof())        
        aAdd(aLista, JsonObject():New())
        nPos++
        aLista[nPos]["Branch"]      := AllTrim(&("(cAlias)->"+cCampoFil))
        aLista[nPos]["Code"]        := AllTrim(&("(cAlias)->"+cCampoCod))
        aLista[nPos]["Description"] := AllTrim(&("(cAlias)->"+cCampoDsc))
        (cAlias)->(dbSkip())
		If !lBuscaVal .And. nPos >= nPageSize
			Exit
		EndIf
	End
    If !lItemCons
        oJson["items"]   := aLista
        oJson["hasNext"] := (cAlias)->(!Eof())
    Else
        If nPos > 0
            oJson := aLista[1]
        EndIf
    EndIf
    aResult[2] := EncodeUTF8(oJson:ToJson())
    (cAlias)->(dbCloseArea())
    FreeObj(oJson)
    FwFreeArray(aLista)
    FwFreeArray(aListaCad)
Return aResult

/*/{Protheus.doc} BuscaFiliais
Retorna uma lista de filiais
@type Method
@author renan.roeder
@since 26/04/2023
@version P12.1.2310
@param  nPage     , numerico, Número da página
@param  nPageSize , numerico, Tamanho da página
@param  cValue    , caracter, Id do Registro
@param  cFilter   , caracter, Filtro da busca
@param  cOrder    , caracter, Ordem de busca
@param  cFilialFlt, caracter, Filial para consulta
@param  lItemCons , logico  , Indica se retorna uma lista de items
@param  cTabela   , caracter, Nome da tabela
@param  cCampoCod , caracter, Nome do campo chave
@param  cCampoDsc , caracter, Nome do campo descrição
@return aResult   , array   , Array preparado com o retorno da requisição
/*/
Method BuscaFiliais(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc) Class PCPMonitorConsultas
    Local aAllFilial := FWAllFilial(,,cEmpAnt,.F.)
    Local aLista     := {}
    Local aResult    := {.T.,"",200}
    Local cFilCod    := ""
    Local cFilNome   := ""
    Local nIndice    := 0
    Local nLenFilial := Len(aAllFilial)
    Local nPos       := 0
    Local nStart     := 1
    Local oJson      := JsonObject():New()

    If nPage > 1
	    nStart += ( (nPage-1) * nPageSize )
	EndIf
    If !Empty(cValue)
        aAdd(aLista,JsonObject():New())
        nPos := aScan(aAllFilial,{|x| x == PadR(cValue, FWSizeFilial())})
        If nPos > 0
            aLista[1]["Code"] := aAllFilial[nPos]
            aLista[1]["Description"] := AllTrim(aAllFilial[nPos]) + " - " + AllTrim(FWFilialName(cEmpAnt,aAllFilial[nPos]))
        EndIf
    Else
        For nIndice := nStart To nLenFilial
            cFilCod  := aAllFilial[nIndice]
            cFilNome := FWFilialName(cEmpAnt,cFilCod)
            If Empty(cFilter) .Or. ((cFilter $ cFilCod) .Or. (Upper(cFilter) $ Upper(cFilNome)))
                nPos++
                aAdd(aLista,JsonObject():New())
                aLista[nPos]["Code"] := cFilCod
                aLista[nPos]["Description"] := AllTrim(cFilCod) + " - " + AllTrim(cFilNome)
            EndIf
            If nPos >= nPageSize
                Exit
            EndIf
        Next nIndice
    EndIf
    If !lItemCons
        oJson["items"]   := aLista
        oJson["hasNext"] := IIF(nIndice < nLenFilial ,.T.,.F.)
    Else
        If nPos > 0
            oJson := aLista[1]
        EndIf
    EndIf
    aResult[2] := EncodeUTF8(oJson:ToJson())
    FreeObj(oJson)
    FwFreeArray(aAllFilial)
    FwFreeArray(aLista)
Return aResult

/*/{Protheus.doc} BuscaRecursos
Retorna uma lista de recursos
@type Method
@author renan.roeder
@since 26/04/2023
@version P12.1.2310
@param  nPage     , numerico, Número da página
@param  nPageSize , numerico, Tamanho da página
@param  cValue    , caracter, Id do Registro
@param  cFilter   , caracter, Filtro da busca
@param  cOrder    , caracter, Ordem de busca
@param  cFilialFlt, caracter, Filial para consulta
@param  lItemCons , logico  , Indica se retorna uma lista de items
@param  cTabela   , caracter, Nome da tabela
@param  cCampoCod , caracter, Nome do campo chave
@param  cCampoDsc , caracter, Nome do campo descrição
@return aResult   , array   , Array preparado com o retorno da requisição
/*/
Method BuscaRecursos(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc) Class PCPMonitorConsultas
    Local aResult    := {.T.,"",200}
    Local aLista     := {}
    Local aListaRec  := {}
    Local cAlias     := GetNextAlias()
    Local cQuery     := ""
    Local cRecursos  := ""
    Local lBuscaVal := ValType(cValue) != "U"
    Local nIndice    := 0
    Local nPos       := 0
    Local nStart     := 0
    Local oJson      := JsonObject():New()

    cQuery := " SELECT SH1.H1_CODIGO,SH1.H1_DESCRI,SH1.H1_CCUSTO,SH1.H1_CTRAB,SH1.H1_CALEND FROM " + RetSqlName("SH1") + " SH1 "
    cQuery += " WHERE SH1.D_E_L_E_T_ = ' ' "
    If Empty(cFilialFlt)
        cQuery += " AND SH1.H1_FILIAL = '"+PadR(cFilialFlt, FWSizeFilial())+"' "
    Else
        cQuery += " AND SH1.H1_FILIAL = '"+xFilial("SH1",PadR(cFilialFlt, FWSizeFilial()))+"' "   
    EndIf
    If !Empty(cFilter)
        cQuery += "AND (UPPER(SH1.H1_CODIGO) LIKE '%"+UPPER(cFilter)+"%' OR UPPER(SH1.H1_DESCRI) LIKE '%"+UPPER(cFilter)+"%') "
    EndIf
    If !Empty(cValue)
        aListaRec := strTokArr(cValue,",")
        For nIndice := 1 To Len(aListaRec)
            If Empty(cRecursos)
                cRecursos := "'" + UPPER(aListaRec[nIndice]) + "'"
            Else
                cRecursos +=  ",'" + UPPER(aListaRec[nIndice]) + "'"
            EndIf            
        Next nIndice
        cQuery += " AND UPPER(SH1.H1_CODIGO) IN ("+cRecursos+") "
    EndIf
    cQuery += " ORDER BY SH1.H1_CODIGO"
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    While (cAlias)->(!Eof())        
        aAdd(aLista, JsonObject():New())
        nPos++
        aLista[nPos]["Code"]        := AllTrim((cAlias)->H1_CODIGO)
        aLista[nPos]["Description"] := AllTrim((cAlias)->H1_DESCRI)
        aLista[nPos]["CostCenter"]  := AllTrim((cAlias)->H1_CCUSTO)
        aLista[nPos]["WorkCenter"]  := AllTrim((cAlias)->H1_CTRAB)
        aLista[nPos]["Calendar"]    := AllTrim((cAlias)->H1_CALEND)
        (cAlias)->(dbSkip())
		If !lBuscaVal .And. nPos >= nPageSize
			Exit
		EndIf
	End
    If !lItemCons
        oJson["items"]   := aLista
        oJson["hasNext"] := (cAlias)->(!Eof())
    Else
        If nPos > 0
            oJson := aLista[1]
        EndIf
    EndIf
    aResult[2] := EncodeUTF8(oJson:ToJson())
    (cAlias)->(dbCloseArea())
    FreeObj(oJson)
    FwFreeArray(aLista)
    FwFreeArray(aListaRec)
Return aResult

/*/{Protheus.doc} BuscaProdutos
Retorna uma lista de produtos
@type Method
@author renan.roeder
@since 05/05/2023
@version P12.1.2310
@param  nPage     , numerico, Número da página
@param  nPageSize , numerico, Tamanho da página
@param  cValue    , caracter, Id do Registro
@param  cFilter   , caracter, Filtro da busca
@param  cOrder    , caracter, Ordem de busca
@param  cFilialFlt, caracter, Filial para consulta
@param  lItemCons , logico  , Indica se retorna uma lista de items
@param  cTabela   , caracter, Nome da tabela
@param  cCampoCod , caracter, Nome do campo chave
@param  cCampoDsc , caracter, Nome do campo descrição
@return aResult   , array   , Array preparado com o retorno da requisição
/*/
Method BuscaProdutos(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc) Class PCPMonitorConsultas
    Local aResult    := {.T.,"",200}
    Local aLista     := {}
    Local aListaProd := {}
    Local cAlias     := GetNextAlias()
    Local cProdutos  := ""
    Local cQuery     := ""
    Local lBuscaVal := ValType(cValue) != "U"
    Local nIndice    := 0
    Local nPos       := 0
    Local nStart     := 0
    Local oJson      := JsonObject():New()

    cQuery := " SELECT SB1.B1_COD,SB1.B1_DESC,SB1.B1_TIPO,SB1.B1_UM,SB1.B1_GRUPO FROM " + RetSqlName("SB1") + " SB1 "
    cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
    If Empty(cFilialFlt)
        cQuery += " AND SB1.B1_FILIAL = '"+PadR(cFilialFlt, FWSizeFilial())+"' "
    Else
        cQuery += " AND SB1.B1_FILIAL = '"+xFilial("SB1",PadR(cFilialFlt, FWSizeFilial()))+"' "   
    EndIf
    If !Empty(cFilter)
        cQuery += "AND (UPPER(SB1.B1_COD) LIKE '%"+UPPER(cFilter)+"%' OR UPPER(SB1.B1_DESC) LIKE '%"+UPPER(cFilter)+"%') "
    EndIf
    If !Empty(cValue)
        aListaProd := strTokArr(cValue,",")
        For nIndice := 1 To Len(aListaProd)
            If Empty(cProdutos)
                cProdutos := "'" + UPPER(aListaProd[nIndice]) + "'"
            Else
                cProdutos +=  ",'" + UPPER(aListaProd[nIndice]) + "'"
            EndIf            
        Next nIndice
        cQuery += " AND UPPER(SB1.B1_COD) IN ("+cProdutos+") "
    EndIf
    cQuery += " ORDER BY SB1.B1_COD"
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
    If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf
    While (cAlias)->(!Eof())        
        aAdd(aLista, JsonObject():New())
        nPos++
        aLista[nPos]["Code"]        := AllTrim((cAlias)->B1_COD)
        aLista[nPos]["Description"] := AllTrim((cAlias)->B1_DESC)
        aLista[nPos]["ProductType"] := AllTrim((cAlias)->B1_TIPO)
        aLista[nPos]["MeasureUnit"] := AllTrim((cAlias)->B1_UM)
        aLista[nPos]["StockGroup"]  := AllTrim((cAlias)->B1_GRUPO)
        (cAlias)->(dbSkip())
		If !lBuscaVal .And. nPos >= nPageSize
			Exit
		EndIf
	End
    If !lItemCons
        oJson["items"]   := aLista
        oJson["hasNext"] := (cAlias)->(!Eof())
    Else
        If nPos > 0
            oJson := aLista[1]
        EndIf
    EndIf
    aResult[2] := EncodeUTF8(oJson:ToJson())
    (cAlias)->(dbCloseArea())
    FreeObj(oJson)
    FwFreeArray(aLista)
    FwFreeArray(aListaProd)
Return aResult

/*/{Protheus.doc} BuscaUsuarios
Retorna uma lista de usuários do sistema
@type Method
@author renan.roeder
@since 08/06/2023
@version P12.1.2310
@param  nPage     , numerico, Número da página
@param  nPageSize , numerico, Tamanho da página
@param  cValue    , caracter, Id do Registro
@param  cFilter   , caracter, Filtro da busca
@param  cOrder    , caracter, Ordem de busca
@param  cFilialFlt, caracter, Filial para consulta
@param  lItemCons , logico  , Indica se retorna uma lista de items
@param  cTabela   , caracter, Nome da tabela
@param  cCampoCod , caracter, Nome do campo chave
@param  cCampoDsc , caracter, Nome do campo descrição
@return aResult   , array   , Array preparado com o retorno da requisição
/*/
Method BuscaUsuarios(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc) Class PCPMonitorConsultas
    Local aAllUsers  := FwsfAllUsers( {}, {"USR_CODIGO","USR_EMAIL","USR_MSBLQL"})
    Local aLista     := {}
    Local aResult    := {.T.,"",200}
    Local lBuscaVal  := ValType(cValue) != "U"
    Local nIndice    := 0
    Local nLenUsers  := Len(aAllUsers)
    Local nPos       := 0
    Local nStart     := 1
    Local oJson      := JsonObject():New()

    If nPage > 1
	    nStart += ( (nPage-1) * nPageSize )
	EndIf
    For nIndice := nStart To nLenUsers
        If aAllUsers[nIndice][5] == "2" .And. adicLista(cValue,cFilter,lBuscaVal,aAllUsers[nIndice][2],aAllUsers[nIndice][3])
            nPos++
            aAdd(aLista,JsonObject():New())
            aLista[nPos]["Code"]         := aAllUsers[nIndice][2]
            aLista[nPos]["Description"]  := aAllUsers[nIndice][3]
            aLista[nPos]["Email"]        := aAllUsers[nIndice][4]
        EndIf
        If !lBuscaVal .And. nPos >= nPageSize
            Exit
        EndIf
    Next nIndice
    If !lItemCons
        oJson["items"]   := aLista
        oJson["hasNext"] := IIF(!lBuscaVal .And. (nIndice < nLenUsers),.T.,.F.)
    Else
        If nPos > 0
            oJson := aLista[1]
        EndIf
    EndIf
    aResult[2] := EncodeUTF8(oJson:ToJson())
    FwFreeArray(aLista)
    FwFreeArray(aAllUsers)
    FreeObj(oJson)
Return aResult

/*/{Protheus.doc} adicLista
Indica se o registro deve ser adicionado na lista de retorno
@type Method
@author renan.roeder
@since 08/06/2023
@version P12.1.2310
@param  cValue    , caracter, Id do Registro
@param  cFilter   , caracter, Filtro da busca
@param  lBuscaVal , logico  , Indica se a busca é por valor
@param  cCodigo   , caracter, Codigo
@param  cDescricao, caracter, Descricao
@return lRet      , logico  , Indica se adiciona o registro
/*/
Static Function adicLista(cValue,cFilter,lBuscaVal,cCodigo,cDescricao)
    Local lRet := .F.

    If lBuscaVal
        If !Empty(cValue) .And. (UPPER(cCodigo) $ UPPER(cValue))
            lRet := .T.
        EndIf
    Else
        If Empty(cFilter) .Or. ((cFilter $ cCodigo) .Or. (UPPER(cFilter) $ UPPER(cDescricao)))
            lRet := .T.
        EndIf
    EndIf
Return lRet

/*/{Protheus.doc} BuscaCadastroTabelaPadrao
Retorna uma lista de registros conforme a tabela genérica parametrizada
@type Method
@author renan.roeder
@since 08/06/2023
@version P12.1.2310
@param  nPage     , numerico, Número da página
@param  nPageSize , numerico, Tamanho da página
@param  cValue    , caracter, Id do Registro
@param  cFilter   , caracter, Filtro da busca
@param  cOrder    , caracter, Ordem de busca
@param  cFilialFlt, caracter, Filial para consulta
@param  lItemCons , logico  , Indica se retorna uma lista de items
@param  cTabela   , caracter, Nome da tabela
@param  cCampoCod , caracter, Nome do campo chave
@param  cCampoDsc , caracter, Nome do campo descrição
@return aResult   , array   , Array preparado com o retorno da requisição
/*/
Method BuscaCadastroTabelaGenerica(nPage,nPageSize,cValue,cFilter,cOrder,cFilialFlt,lItemCons,cTabela,cCampoCod,cCampoDsc) Class PCPMonitorConsultas
    Local aCadSX5    := FWGetSX5(cTabela)
    Local aLista     := {}
    Local aResult    := {.T.,"",200}
    Local lBuscaVal  := ValType(cValue) != "U"
    Local nIndice    := 0
    Local nLenCad    := Len(aCadSX5)
    Local nPos       := 0
    Local nStart     := 1
    Local oJson      := JsonObject():New()

    If nPage > 1
	    nStart += ( (nPage-1) * nPageSize )
	EndIf
    For nIndice := nStart To nLenCad
        If adicLista(cValue,cFilter,lBuscaVal,aCadSX5[nIndice][3],aCadSX5[nIndice][4])
            nPos++
            aAdd(aLista,JsonObject():New())
            aLista[nPos]["Code"]         := aCadSX5[nIndice][3]
            aLista[nPos]["Description"]  := aCadSX5[nIndice][4]
        EndIf
        If !lBuscaVal .And. nPos >= nPageSize
            Exit
        EndIf
    Next nIndice
    If !lItemCons
        oJson["items"]   := aLista
        oJson["hasNext"] := IIF(!lBuscaVal .And. (nIndice < nLenCad),.T.,.F.)
    Else
        If nPos > 0
            oJson := aLista[1]
        EndIf
    EndIf
    aResult[2] := EncodeUTF8(oJson:ToJson())
    FwFreeArray(aLista)
    FwFreeArray(aCadSX5)
    FreeObj(oJson)
Return aResult
