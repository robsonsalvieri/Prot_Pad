#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE R3010  1,1

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0023010

@description Monta a mensagem JON de retorno referente ao cabeçalho do
R-3010
@author Katielly Rezende 
@since 20/08/2020
@version 1.0
@return Retorna o alias para consulta das informações
/*/ 
//-------------------------------------------------------------------
Function WS0023010(aApurac, oEstruct, oValidationError, npage, npageSize )
    local cNrInsc		as character
    local cBranch		as character
    local cCompany		as character
    local aSM0          as array
    Local nTotReg   	as Numeric

    cNrInsc		:= ""
    cBranch		:= ""
    cCompany	:= ""
    aSM0        := {}
    nTotReg     := 0

    default oValidationError["registryKey"] = {}
    Default npage 		:= 0
	Default npageSize	:= 0

    while !(aApurac)->(eof())

        nTotReg++
        aadd(oEstruct["eventDetail"],JsonObject():New())
        nTSintetic := len(oEstruct["eventDetail"])

        //Nome da Filial
        oEstruct["eventDetail"][nTSintetic]["branchId"]                     := (aApurac)->FILIAL

        // Código da Filial
        oEstruct["eventDetail"][nTSintetic]["branch"]                       := (aApurac)->FILIAL

        //Nº do boletim
        oEstruct["eventDetail"][nTSintetic]["newsletterNumber"]             := (aApurac)->BOLETIM

        //Modalidade
        oEstruct["eventDetail"][nTSintetic]["mode"]                         := (aApurac)->MODALIDADE

        //Competição
        oEstruct["eventDetail"][nTSintetic]["competition"]                  := (aApurac)->COMPETICAO

        //CNPJ do Mandatário
        oEstruct["eventDetail"][nTSintetic]["taxNumberPrincipal"]           := (aApurac)->CNPJMAND

        //CNPJ do Visitante
        oEstruct["eventDetail"][nTSintetic]["taxNumberVisited"]             := (aApurac)->CNPJVI

        //Qtd. pagantes
        oEstruct["eventDetail"][nTSintetic]["payingOffValue"]               := (aApurac)->PAGANTES

        //Qtd. não pagantes
        oEstruct["eventDetail"][nTSintetic]["dontPayingOffValue"]           := (aApurac)->NAOPAGANTES

        //Total receita bruta
        oEstruct["eventDetail"][nTSintetic]["grossValue"]                   := (aApurac)->TOTALBRUTO

        //Contribuição previdenciaria
        oEstruct["eventDetail"][nTSintetic]["contributionValue"]            := (aApurac)->TRIBUTO

        //Valor retido
        oEstruct["eventDetail"][nTSintetic]["contributionValueSuspended"]   := (aApurac)->VALORRETIDO

        //Status
        oEstruct["eventDetail"][nTSintetic]["status"]                       := Iif(Empty((aApurac)->STATUS), 'notValidated', 'validated')

        // Chave de registro
        oEstruct["eventDetail"][nTSintetic]["key"]                          := (aApurac)->ID

        //Propriedade errors que habilita o icone no frontend
        oEstruct["eventDetail"][nTSintetic]["errors"]                       := 'errors'

        If Len(oValidationError["registryKey"]) > 0
            // Chave de busca do erro da apuração
            oEstruct["eventDetail"][nTSintetic]["keyValidationErrors"]      := KeyError(oEstruct["eventDetail"][nTSintetic], oValidationError)
        EndIf

        (aApurac)->(dbSkip())
    endDo

oEstruct['hasNext'] := Iif((npage * npageSize) >= nTotReg, .F., .T.)

Return oEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0023010

@description Monta a mensagem JON de retorno referente ao filho do
R-3010
@author Katielly Rezende 
@since 20/08/2020
@version 1.0
@return Retorna o alias para consulta das informações
/*/ 
//-------------------------------------------------------------------
Function WS002D3010(aApurac, oEstruct)

    while !(aApurac)->(eof())

        aAdd( oEstruct["invoices"],JsonObject():New())
        nTAnalytic   :=  len(oEstruct["invoices"])

        //Receita
        oEstruct["invoices"][nTAnalytic]["income"]              := (aApurac)->RECEITA

        //Tipo
        oEstruct["invoices"][nTAnalytic]["type"]                := (aApurac)->TIPORECEITA + " - " + (aApurac)->DESCRECEITA

        //Quantidade ingressos a venda
        oEstruct["invoices"][nTAnalytic]["saleAmount"]          := (aApurac)->QTDVENDA

        //Quantidade ingressos vendidos
        oEstruct["invoices"][nTAnalytic]["soldAmount"]          := (aApurac)->QTDVENDIDO

        //Quantidade ingressos devolvidos
        oEstruct["invoices"][nTAnalytic]["refundAmount"]        := (aApurac)->QTDDEVOLVIDO

        //Valor unitário
        oEstruct["invoices"][nTAnalytic]["unitaryValue"]        := (aApurac)->VALOR

        //Total
        oEstruct["invoices"][nTAnalytic]["totalGrossValue"]     := (aApurac)->TOTAL

        (aApurac)->(dbSkip())
    endDo

Return oEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} WSQry3010

@description Execução da query de cabeçalho e filho do evento 3010
@author Katielly Rezende 
@since 20/08/2020
@version 1.0
@return Retorna o alias para consulta das informações
/*/ 
//-------------------------------------------------------------------
Function WSQry3010(cPerApu, aFil, nView, cKey)
    local cAlias3010 	as character
    local cQuery        as character
    local cFiliais	    as character

    Default nView	:= 1
    Default cKey    := ""

    cAlias3010 	:= GetNextAlias()
    cQuery      := ""
    cFiliais	:= RetFil(aFil)

    If nView == 1
        //SELECT

        cQuery	+= " T9F.T9F_FILIAL FILIAL,     "
        cQuery	+= " T9F.T9F_ID ID,             "
        cQuery	+= " T9F.T9F_DTAPUR DTAPUR,     "
        cQuery	+= " T9F.T9F_VALCLU RECEITA,    "
        cQuery	+= " T9G.T9G_TPCOMP TIPO,       "
        cQuery	+= " T9G.T9G_CATEVE CATEGORIA,  "
        cQuery	+= " T9G.T9G_NUMBOL BOLETIM,    "
        cQuery	+= " T9G.T9G_MODDES MODALIDADE, "
        cQuery	+= " T9G.T9G_NOMCOM COMPETICAO, "
        cQuery	+= " T9G.T9G_CNPJMA CNPJMAND,   "
        cQuery	+= " T9G.T9G_CNPJVI CNPJVI,     "
        cQuery	+= " T9G.T9G_NOMVIS VISITANTE,  "
        cQuery	+= " T9G.T9G_PRADES PRACA,      "
        cQuery	+= " T9G.T9G_PAGANT PAGANTES,   "
        cQuery	+= " T9G.T9G_NPAGAN NAOPAGANTES,"
        cQuery	+= " T9F.T9F_VALTOT TOTALBRUTO, "
        cQuery	+= " T9F.T9F_VALPRE TRIBUTO,    "
        cQuery	+= " T9F.T9F_VALRET VALORRETIDO,"
        cQuery  += " T9F.T9F_PROCID PROCID,     "
        cQuery	+= " C07.C07_DESCRI CIDADE,     "
        cQuery	+= " C09.C09_DESCRI ESTADO,     "

        cQuery	+= " CASE "
        cQuery	+= " WHEN T9F.T9F_PROCID <> ' ' THEN '3' "
        cQuery	+= " WHEN T9F.T9F_PROCID = ' ' THEN ' ' "
        cQuery	+= " END AS STATUS "

        cQuery	+= " FROM " + RetSqlName("T9F") + " T9F "

        //INNER JOIN
        cQuery	+= " INNER JOIN " + RetSqlName("C1E") + " C1E "
        cQuery	+= " ON C1E.C1E_FILTAF = T9F.T9F_FILIAL "
        cQuery	+= " AND C1E.D_E_L_E_T_ = ' ' "
        cQuery	+= " INNER JOIN " + RetSqlName("T9G") + " T9G  "
        cQuery	+= " ON  T9G.T9G_FILIAL = T9F.T9F_FILIAL   "
        cQuery	+= " AND T9G.T9G_ID = T9F.T9F_ID  "
        cQuery	+= " AND T9G.D_E_L_E_T_ = ' ' "
        cQuery	+= " INNER JOIN " + RetSqlName("T9H") + " T9H  "
        cQuery	+= " ON T9H.T9H_FILIAL = T9G.T9G_FILIAL "
        cQuery	+= " AND T9H.T9H_ID = T9G.T9G_ID  "
        cQuery	+= " AND T9H.T9H_NUMBOL = T9G.T9G_NUMBOL  "
        cQuery	+= " AND T9H.T9H_DTAPUR = T9G.T9G_DTAPUR  "
        cQuery	+= " AND T9H.D_E_L_E_T_ = ' ' "

        cQuery	+= "  INNER JOIN "  +  RetSqlName("C07") + " C07  "
        cQuery	+= "  	ON  T9G_CODMUN = C07_ID      "
        cQuery	+= "  	AND C07.D_E_L_E_T_ = ''      "
        cQuery	+= "  INNER JOIN  " + RetSqlName("C09") + " C09 "
        cQuery	+= "  	ON  T9G.T9G_UF  = C09.C09_ID "
        cQuery	+= "  	AND C09.D_E_L_E_T_ = ''      "

        //Where
        cQuery	+= " WHERE  "
        cQuery	+= " C1E.C1E_ATIVO IN (' ','1')
        cQuery	+= " AND C1E.D_E_L_E_T_ = ' ' "
        cQuery	+= " AND T9F.T9F_FILIAL IN  (" + cFiliais + ")  "
        cQuery	+= " AND T9F.D_E_L_E_T_ = ' '
        cQuery	+= " ORDER BY T9F.T9F_FILIAL, T9F.T9F_PROCID, T9F.T9F_DTAPUR "

    ElseIf nView == 2

        cQuery	+= " 'INGRESSO' AS RECEITA, " 
        cQuery  += " T9H.T9H_TPINGR TIPORECEITA, "
        cQuery  += " T9H.T9H_INGRES DESCRECEITA, "
        cQuery  += " T9H.T9H_QTDVDA QTDVENDA, "
        cQuery	+= " T9H.T9H_QTDVDO QTDVENDIDO, "
        cQuery  += " T9H.T9H_QTDDEV QTDDEVOLVIDO, "
        cQuery  += " T9H.T9H_PREIND VALOR, "
        cQuery  += " T9H.T9H_VLRTOT TOTAL "
        cQuery	+= " FROM " + RetSqlName("T9H") + " T9H "
        cQuery	+= " WHERE  T9H.D_E_L_E_T_ = ' ' "
        cQuery	+= " AND T9H.T9H_ID =  " + cKey  + "  "

        cQuery	+= " Union ALL "

        cQuery	+= " SELECT "
        cQuery	+= " 'Outras receitas' AS RECEITA, "
        cQuery	+= " T9I.T9I_TPREC  TIPORECEITA, "
        cQuery	+= " T9I.T9I_DESREC DESCRECEITA, "
        cQuery	+= " 0 QTDVENDA, "
        cQuery	+= " 0 QTDVENDIDO, "
        cQuery	+= " 0 QTDDEVOLVIDO, " 
        cQuery	+= " T9I.T9I_VALREC VALOR, "
        cQuery	+= " T9I.T9I_VALREC TOTAL "
        cQuery	+= " FROM " + RetSqlName("T9I") + " T9I "
        cQuery	+= " WHERE  T9I.D_E_L_E_T_ = ' ' "
        cQuery	+= " AND T9I.T9I_ID =  " + cKey  + "  "
    EndIf

    cQuery	:= "%" + cQuery + "%"

    BeginSql Alias cAlias3010
		SELECT DISTINCT
			%EXP:cQuery%	
    EndSql

Return cAlias3010

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado pela tela da apuração
para que fique no formato de execução do IN no SQL

@description Trata o array de filiais passado pela tela da apuração
para que fique no formato de execução do IN no SQL
@author Katielly Rezende 
@since 20/08/2020
@version 1.0
@return Retorna um character com as filiais no formato do in 
/*/
//-------------------------------------------------------------------
Static Function RetFil(aFil)
    Local cRetFils	as Character
    Local nX		as Numeric

    cRetFils	:= ""
    nX			:= 0

    If !Empty(xFilial("T9F")) .And. Len(aFil) > 0

        For nX := 1 to Len(aFil)
            If nX > 1
                cRetFils += " , '" + xFilial("T9F", aFil[nX][2]) + "'"
            Else
                cRetFils += "'" + xFilial("T9F", aFil[nX][2]) + "'"
            EndIf
        Next nX
    Else
        cRetFils := "'" + xFilial("T9F") + "'"
    EndIf

Return cRetFils


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} KeyError
Função responsável por retornar o procid da tabela de log que contém o motivo do erro da apuração

@author Leticia Campos
@since 19/08/2020
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Static Function KeyError(oEstruct, oValidationError)
    local cKeyError as character
    local nX        as numeric

    cKeyError       := ""
    nX              := 1

    For nX := 1 to Len(oValidationError["registryKey"])
        if alltrim(oValidationError["registryKey"][nX]["branchId"]) == alltrim(oEstruct["branchId"])
            if alltrim(oValidationError["registryKey"][nX]["id"]) == alltrim(oEstruct["key"])
                cKeyError := oValidationError["registryKey"][nX]["error"]
            endif
        endif
    Next nX

return ( cKeyError )


