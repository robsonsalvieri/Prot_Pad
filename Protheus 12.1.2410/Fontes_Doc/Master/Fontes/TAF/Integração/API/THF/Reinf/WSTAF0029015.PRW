#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} WS0029015

    (long_description)

    @type  WS0029015
    @author Jose Felipe
    @since 20/01/2023
    @version 1.0
    @return

    /*/
Function WS0029015( oJsonRet, cFilSel, cPeriod, cEvento, cId, nNivel)

Local oQryTmp    as object
Local cDescNivel as character
Local cAliasTmp  as character

Default cFilSel  := ''
Default cPeriod := ''
Default cEvento  := ''
Default cId      := ''
Default nNivel   := 0

oQryTmp    := nil
cDescNivel := ''

if nNivel = 1
    cDescNivel := 'eventDetail'
elseif nNivel = 2
    cDescNivel := 'invoices'
endif

cAliasTmp := ConsulTot(cPeriod, cFilSel ,nNivel ,@oQryTmp)

	While (cAliasTmp)->(!eof())

		aadd(oJsonRet[cDescNivel],JsonObject():New())
        nPosDet := len(oJsonRet[cDescNivel])
        if nNivel = 1
            oJsonRet[cDescNivel][nPosDet]["branchId"]        := (cAliasTmp)->V9F_FILIAL
            oJsonRet[cDescNivel][nPosDet]['branchTaxNumber'] := FWSM0Util( ):GetSM0Data( , (cAliasTmp)->V9F_FILIAL , { 'M0_CGC'    } )[1][2]
            oJsonRet[cDescNivel][nPosDet]['companyName']     := FWSM0Util( ):GetSM0Data( , (cAliasTmp)->V9F_FILIAL , { 'M0_FILIAL' } )[1][2]
            oJsonRet[cDescNivel][nPosDet]['protocol']        := (cAliasTmp)->RECIBO
           
        elseif nNivel = 2            

            oJsonRet[cDescNivel][nPosDet]['event'              ] := (cAliasTmp)->EVENTO
            oJsonRet[cDescNivel][nPosDet]['grossCode'          ] := (cAliasTmp)->CODRECEITA
            oJsonRet[cDescNivel][nPosDet]['receipt'            ] := (cAliasTmp)->RECIBO
            oJsonRet[cDescNivel][nPosDet]['tax'                ] := (cAliasTmp)->TRIBUTO

        EndIf

        (cAliasTmp)->(DbSkip())

	EndDo

if valtype(oQryTmp) != 'U'; FreeObj(oQryTmp); endif
    (cAliasTmp)->(DbCloseArea())
Return 


/*/{Protheus.doc} ConsulTot
Função que retorno a tabela temporaria R-9015 para a consulta de nivel 1,2 e 3 
@author Jose Felipe
@since 23/01/2023
@version 1.0
*/
static function ConsulTot(cPeriodo, cFilSel, nNivel, oQryTmp, cEvento)
Local cQuery    := ''
Local cAlias    := getnextalias()
Local cAliasTmp := getnextalias()
Local cTblEve   := 'V9Q'
Local aStruct   := {{'EVENTO'    , 'C' , 06 , 0 },;
                    {'CODRECEITA', 'C' , 06 , 0 },;    		        
                    {'TRIBUTO'   , 'N' , 14,  2 },;
                    {'RECIBO'    , 'C' , 52,  0 }}  

Local cRetAlias  := ''

Default oQryTmp   := Nil

if nNivel == 1

    cQuery += " SELECT DISTINCT "
    cQuery += " V9F.V9F_FILIAL, "
    cQuery += " V9F.V9F_PROTUL RECIBO "
    cQuery += " FROM " + RetSqlName('V9F') + " V9F "
    cQuery += " WHERE V9F.D_E_L_E_T_ = ' ' "
    cQuery += " AND V9F.V9F_PERAPU = '" + cPeriodo + "' "
    cQuery += "	AND V9F.V9F_ATIVO != '2' "
    cQuery += " AND V9F.V9F_FILIAL IN " + cFilSel + " "
    cQuery += " ORDER BY V9F.V9F_FILIAL "
    cQuery := changeQuery(cQuery)
    
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .F., .T. )

    cRetAlias := cAlias

elseif ( nNivel == 2 )

    if nNivel == 2
        cEvento := 'R-4099'
        oQryTmp := FWTemporaryTable():New(cAliasTmp, aStruct)
        oQryTmp:AddIndex('1', {'EVENTO'} )
        oQryTmp:Create()
    endif    
     
    //SELECT
    cQuery := " SELECT "

    cQuery += " '"+cEvento+"' EVENTO, "
    cQuery += " V9Q.V9Q_CR CODRECEITA, "
    cQuery += " SUM(V9Q.V9Q_VTRIBI) TRIBUTO, "
    cQuery += " V9F.V9F_PROTUL RECIBO "

    //FROM
    cQuery += " FROM " + RetSqlName('V9F') + " V9F "
    cQuery += " INNER JOIN " + RetSqlName(cTblEve) + ' ' + cTblEve + " ON " + cTblEve + "." + cTblEve + "_FILIAL = V9F.V9F_FILIAL "
    cQuery += "    AND " + cTblEve + "." + cTblEve + "_ID = V9F.V9F_ID "
    cQuery += "    AND " + cTblEve + "." + cTblEve + "_VERSAO = V9F.V9F_VERSAO "
    cQuery += "    AND " + cTblEve + ".D_E_L_E_T_ = ' ' "
    
    //WHERE
    cQuery += " WHERE V9F.D_E_L_E_T_ = ' ' "
    cQuery += " AND V9F.V9F_FILIAL = '" + cFilSel + "' "
    cQuery += "	AND V9F.V9F_PERAPU = '" + cPeriodo + "' "
    cQuery += "	AND V9F.V9F_ATIVO != '2' "
    cQuery += " AND V9F.V9F_TPEVEN = '"+ SubStr(cEvento, 3, 6)+"' "

    //GROUP BY
    cQuery += " GROUP BY V9F.V9F_TPEVEN, V9Q.V9Q_CR, V9F.V9F_PROTUL" 

    cQuery := changeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .F., .T. )

    cRetAlias := cAlias

endif

return cRetAlias

/*/{Protheus.doc} ConsulTot
Função que retorno a query do R-9015 para gerar o nível 2 do relatório
@author Jose Felipe
@since 31/01/2023
@version 1.0
*/
Function QryRel9015(cPerApu,  aFil)

Local cQuery    as character
Local cWhereEvt as character
Local cTblEve   as character
Local cFiliais  as character
Local cAliasRel as character

cAliasRel	:= GetNextAlias()
cQuery      := ""
cWhereEvt   := ""
cTblEve     := 'V9Q'
cFiliais	:= RetFil(aFil)
cRetAlias   := ""
cEvento     := 'R-4099'


    //SELECT 
    cQuery += " SELECT V9F.V9F_FILIAL FILIAL, "
    cQuery += " '"+cEvento+"' EVENTO, "
    cQuery += " V9Q.V9Q_CR CODRECEITA, " 
    cQuery += " V9Q.V9Q_NATREN NATREN, "
    cQuery += " V9Q.V9Q_VTRIBI VALTRIB, "
    cQuery += " V9Q.V9Q_VSUSPI VLTRIBSUSP, "
    cQuery += " V9Q.V9Q_VSUSPC VLCALCSUSP, "
    cQuery += " V9Q.V9Q_TPPER PERIODO

    //FROM
    cQuery += " FROM " + RetSqlName('V9F') + " V9F "
    cQuery += " INNER JOIN " + RetSqlName(cTblEve) + ' ' + cTblEve + " ON " + cTblEve + "." + cTblEve + "_FILIAL = V9F.V9F_FILIAL "
    cQuery += "    AND " + cTblEve + "." + cTblEve + "_ID = V9F.V9F_ID "
    cQuery += "    AND " + cTblEve + "." + cTblEve + "_VERSAO = V9F.V9F_VERSAO "
    cQuery += "    AND " + cTblEve + ".D_E_L_E_T_ = ' ' "

    //WHERE
    cQuery += " WHERE V9F.D_E_L_E_T_ = ' ' "
    cQuery += " AND V9F.V9F_FILIAL IN (" + cFiliais + ")  "
    cQuery += "	AND V9F.V9F_PERAPU = '" + cPerApu + "' "
    cQuery += "	AND V9F.V9F_ATIVO != '2' "
    cQuery += " AND V9F.V9F_TPEVEN = '"+ SubStr(cEvento, 3, 6)+"' "
        
    //GROUP BY
    cQuery += " GROUP BY V9F.V9F_FILIAL, V9Q.V9Q_CR, V9Q.V9Q_NATREN, V9Q.V9Q_VTRIBI, V9Q.V9Q_VSUSPI, V9Q.V9Q_VSUSPC, V9Q.V9Q_TPPER "
    
    cQuery := changeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasRel, .F., .T. )
    cRetAlias := cAliasRel

Return (cRetAlias)


//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado pela tela da apuraÃ§Ã£o
para que fique no formato de execuÃ§Ã£o do IN no SQL

@author Jose Felipe
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
