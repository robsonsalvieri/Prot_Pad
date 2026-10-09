#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} WS0029005
@type  WS0029005
@author Wesley Matos
@since 20/01/2023
@version 1.0
@return
/*/

Function WS0029005( oJsonRet, cFilSel, cPeriod, cEvento, cId, nNivel, nPage, nPageSize, lHasNext)

Local oQryTmp    as object
Local cDescNivel as character
Local cAliasTmp  as character

Default cFilSel  := ''
Default cPeriod := ''
Default cEvento  := ''
Default cId      := ''
Default nNivel   := 0

lHasNext	:=	.F.
oQryTmp    := nil
cDescNivel := ''

if nNivel = 1
    cDescNivel := 'eventDetail'
elseif nNivel = 2
    cDescNivel := 'invoices'
endif

cAliasTmp := ConsulTot(cPeriod, cFilSel ,nNivel ,@oQryTmp, nPage, nPageSize, @lHasNext)

    (cAliasTmp)->(dbGoTop())

	While (cAliasTmp)->(!eof())

		aadd(oJsonRet[cDescNivel],JsonObject():New())
        nPosDet := len(oJsonRet[cDescNivel])

        if nNivel = 1
            oJsonRet[cDescNivel][nPosDet]["branchId"]        := (cAliasTmp)->V9D_FILIAL
            oJsonRet[cDescNivel][nPosDet]['taxNumberBranch'] := FWSM0Util( ):GetSM0Data( , (cAliasTmp)->V9D_FILIAL , { 'M0_CGC'    } )[1][2]
            oJsonRet[cDescNivel][nPosDet]['companyName']     := FWSM0Util( ):GetSM0Data( , (cAliasTmp)->V9D_FILIAL , { 'M0_FILIAL' } )[1][2]
        elseif nNivel = 2    
            oJsonRet[cDescNivel][nPosDet]['event'              ] := (cAliasTmp)->EVENTO
            oJsonRet[cDescNivel][nPosDet]['recipeCode'         ] := (cAliasTmp)->CODRECEITA
            oJsonRet[cDescNivel][nPosDet]['taxBase'            ] := (cAliasTmp)->BASECALC            
            oJsonRet[cDescNivel][nPosDet]['tax'                ] := (cAliasTmp)->TRIBUTO

        EndIf
        (cAliasTmp)->(DbSkip())

	EndDo

oJsonRet["hasNext"] := lHasNext

if valtype(oQryTmp) != 'U'; FreeObj(oQryTmp); endif
(cAliasTmp)->(DbCloseArea())

Return 


/*/{Protheus.doc} ConsulTot
Função que retorno a tabela temporaria R-9005 para a consulta de nivel 1,2
@author Wesley Matos
@since 23/01/2023
@version 1.0
*/
static function ConsulTot(cPeriodo, cFilSel, nNivel,oQryTmp,nPage,nPageSize,lHasNext)
Local i         := 0
Local cQuery    := ''
Local cAlias    := getnextalias()
Local cAliasRel	:= GetNextAlias()
Local cAliasTot := GetNextAlias()
Local aEventos  := VerTot()
Local cTblEve   := 'V9G'
Local cRetAlias := ''
Local cSelect   := ''
Local cFrom     := ''
Local cWhere    := ''
Local cGroupBy  := ''
Local cQryTot   := ''
Local nTotReg   := 0

Default oQryTmp   := Nil
Default nPage     := 0
Default nPageSize := 0

if nNivel = 1

    cQuery += " SELECT DISTINCT "
    cQuery += " V9D.V9D_FILIAL "
    cQuery += " FROM " + RetSqlName('V9D') + " V9D "
    cQuery += " WHERE V9D.D_E_L_E_T_ = ' ' "
    cQuery += " AND V9D.V9D_PERAPU = '" + cPeriodo + "' "
    cQuery += "	AND V9D.V9D_ATIVO != '2' "
    cQuery += " AND V9D.V9D_FILIAL IN " + cFilSel + " "
    cQuery += " ORDER BY V9D.V9D_FILIAL "
    cQuery := changeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .F., .T. )
    cRetAlias := cAlias

elseif ( nNivel = 2 )

    If (nPage > 0 .And. nPageSize > 0) 
        cQuery := " SELECT EVENTO, CODRECEITA, BASECALC, TRIBUTO FROM("
    EndIf

    for i := 1 to len(aEventos)
        
        If aEventos[i] $ "R-4010|R-4020|R-4040|R-4080"
            
            if i > 1
                cQuery += " UNION ALL "
            EndIf
            
            //SELECT
            cSelect := " SELECT '"+ aEventos[i] +"' EVENTO, "
            cSelect += " V9G.V9G_CR CODRECEITA, "
            cSelect += " SUM(V9G.V9G_BASECR) BASECALC, "
            cSelect += " SUM(V9G.V9G_VINFO) TRIBUTO "

            //FROM
            cFrom := " FROM  " + RetSqlName('V9D') + " V9D "
            cFrom += " INNER JOIN " + RetSqlName(cTblEve) + ' ' + cTblEve + " ON " + cTblEve + "." + cTblEve + "_FILIAL = V9D.V9D_FILIAL "
            cFrom += "    AND " + cTblEve + "." + cTblEve + "_ID = V9D.V9D_ID "
            cFrom += "    AND " + cTblEve + "." + cTblEve + "_VERSAO = V9D.V9D_VERSAO "
            cFrom += "    AND " + cTblEve + ".D_E_L_E_T_ = ' ' "

            //WHERE
            cWhere := "  WHERE V9D.D_E_L_E_T_ = ' ' "
            cWhere += " AND V9D.V9D_FILIAL = '" + cFilSel + "' "
            cWhere += "	AND V9D.V9D_PERAPU = '" + cPeriodo + "' "
            cWhere += "	AND V9D.V9D_ATIVO != '2' "
            cWhere += " AND V9D.V9D_TPEVEN = '"+ SubStr(aEventos[i], 3, 6)+"' "
            
            //GROUP BY
            cGroupBy := " GROUP BY V9G.V9G_CR, V9D.V9D_TPEVEN "

            cQuery += cSelect + cFrom + cWhere + cGroupBy

        EndIf
    next

    If (nPage > 0 .And. nPageSize > 0) 
        cQuery += " ) TB1 "
    EndIf
    
    If (nPage > 0 .And. nPageSize > 0) 
        cQryTot := " SELECT COUNT(*) QTDREG FROM  ( " + cQuery + " ) TB3 "
        cQryTot := ChangeQuery(cQryTot) 
        dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryTot ) , cAliasTot, .F., .T. )
        nTotReg := (cAliasTot)->QTDREG
        (cAliasTot)->(DBCloseArea())

        lHasNext := Iif((nPage * nPageSize) >= nTotReg, .F., .T.)        
    EndIf

    cQuery += 'ORDER BY EVENTO, CODRECEITA'

    cQuery := ChangeQuery(cQuery)

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasRel, .F., .T. )
    
    cRetAlias := cAliasRel

endif

return (cRetAlias)

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryRel9005
Função responsável por retornar a query para geração do arquivo CSV do relatorio R-9005
@param cPerApu, caracter, Periodo de apuração. Ex: 012021
@param aFil, array, array contendo as filiais

@return aRet, array, array contendo o alias da query

@author Wesley Matos
@since 30/01/2023
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Function QryRel9005(cPerApu,  aFil)
Local aEventos  as array 
Local i         as numeric
Local cQuery    as character
Local cWhereEvt as character
Local cTblEve   as character
Local cFiliais  as character
Local cAliasRel as character
Local aRetAlias as character

cAliasRel	:=	GetNextAlias()
cQuery      := ""
cWhereEvt   := ""
cTblEve     := 'V9G'
cFiliais	:= RetFil(aFil)
aRetAlias   := ""
aEventos    := VerTot()

for i := 1 to len(aEventos)

    if i > 1
        cQuery += " UNION ALL "
    EndIf

    //SELECT 
    cQuery += " SELECT V9D.V9D_FILIAL FILIAL, "
    cQuery += " '" + aEventos[i] + "' EVENTO, "
    cQuery += " V9G.V9G_CR            CODREC, " 
    cQuery += " V9G.V9G_NATREN        NATREN, "
    cQuery += " Sum(V9G.V9G_BASECR)   BASETRI, "
    cQuery += " Sum(V9G.V9G_VINFO)    VALTRIB, "
    cQuery += " Sum(V9G.V9G_VSUSPI)   VLTRIBSUSP,"
    cQuery += " Sum(V9G.V9G_VSUSPC)   VLCALCSUSP,"
    cQuery += " V9G.V9G_TPPER         PERIODO

    //FROM
    cQuery += " FROM " + RetSqlName('V9D') + " V9D "
    cQuery += " INNER JOIN " + RetSqlName(cTblEve) + ' ' + cTblEve + " ON " + cTblEve + "." + cTblEve + "_FILIAL = V9D.V9D_FILIAL "
    cQuery += "    AND " + cTblEve + "." + cTblEve + "_ID = V9D.V9D_ID "
    cQuery += "    AND " + cTblEve + "." + cTblEve + "_VERSAO = V9D.V9D_VERSAO "
    cQuery += "    AND " + cTblEve + ".D_E_L_E_T_ = ' ' "

    //WHERE
    cQuery += " WHERE V9D.D_E_L_E_T_ = ' ' "
    cQuery += " AND V9D.V9D_FILIAL IN (" + cFiliais + ")  "
    cQuery += "	AND V9D.V9D_PERAPU = '" + cPerApu + "' "
    cQuery += "	AND V9D.V9D_ATIVO != '2' "
    cQuery += " AND V9D.V9D_TPEVEN = '"+ SubStr(aEventos[i], 3, 6)+"' "
        
    //GROUP BY
    cQuery += " GROUP BY V9D.V9D_FILIAL, V9G.V9G_CR, V9G.V9G_NATREN, V9G.V9G_BASECR, V9G.V9G_VINFO, V9G.V9G_VSUSPI, V9G.V9G_VSUSPC, V9G.V9G_TPPER "
next
    
    cQuery := changeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasRel, .F., .T. )
    cRetAlias := cAliasRel

Return (cRetAlias)


//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado pela tela da apuraÃ§Ã£o
para que fique no formato de execuÃ§Ã£o do IN no SQL

@author Wesley Matos
@since 30/01/2023
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function RetFil(aFil)
	Local cRetFils	as Character
	Local nX		as Numeric

	cRetFils	:= ""
	nX			:= 0

	If !Empty(xFilial("C20")) .And. Len(aFil) > 0

		For nX := 1 to Len(aFil)
			If nX > 1
				cRetFils += " , '" + xFilial("C20", aFil[nX][2]) + "'"
			Else
				cRetFils += "'" + xFilial("C20", aFil[nX][2]) + "'"
			EndIf
		Next nX
	Else
		cRetFils := "'" + xFilial("C20") + "'"
	EndIf

Return cRetFils

//---------------------------------------------------------------------
/*/{Protheus.doc} VerTot()
Verifica a tabela e retorna os eventos existentes para o totalizador

@Author		Wesley Matos
@Since		03/02/2023
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function VerTot()
    
Local cQuery    := ''
Local cAliasRel := GetNextAlias()
Local aEvent    := {}


    cQuery += "SELECT V9D_TPEVEN EVENTO FROM " + RetSqlName('V9D') + " V9D " + "GROUP BY V9D_TPEVEN"

    cQuery := changeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasRel, .F., .T. )

    While ( cAliasRel )->( !Eof() )
        Aadd(aEvent, 'R-'+AllTrim((cAliasRel)-> EVENTO))
        ( cAliasRel )->( DBSkip() )
    ENDDO

Return aEvent
