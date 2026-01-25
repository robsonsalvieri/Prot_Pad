#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"



/*/{Protheus.doc} WS0025001
WS para operações GET/POST dos dados das tabelas do evento R-9001 para o relatorio
@author Karen Honda  
@since 11/02/2021
@version 1.0
*/


function WS0025001(oJsonRet, cFilSel, cPeriodo, cEvento,cId, nNivel)
Local oQryTmp    := nil
Local cDescNivel := ''
Local cEvNivel   := iif(nNivel != 3, cEvento, cId )

Default cFilSel  := ''
Default cPeriodo := ''
Default cEvento  := ''
Default cId      := ''
Default nNivel   := 0


if nNivel = 1
    cDescNivel := 'eventDetail'
elseif nNivel = 2
    cDescNivel := 'invoices'
else
    cDescNivel := 'tax'
endif

//cAliasTmp := ConsulTot(cPeriodo, nNivel , cEvento, cFilSel,@oQryTmp)
cAliasTmp := ConsulTot(cPeriodo, cFilSel ,nNivel ,@oQryTmp, cEvNivel)

If select(cAliasTmp) > 0

    while (cAliasTmp)->(!eof())
        
        aadd(oJsonRet[cDescNivel],JsonObject():New())
        nPosDet := len(oJsonRet[cDescNivel])

        if nNivel = 1
            oJsonRet[cDescNivel][nPosDet]['branchId'       ] := (cAliasTmp)->V0W_FILIAL  
            oJsonRet[cDescNivel][nPosDet]['companyName'    ] := FWSM0Util( ):GetSM0Data( , (cAliasTmp)->V0W_FILIAL , { 'M0_FILIAL' } )[1][2] 
            oJsonRet[cDescNivel][nPosDet]['branchTaxNumber'] := FWSM0Util( ):GetSM0Data( , (cAliasTmp)->V0W_FILIAL , { 'M0_CGC'    } )[1][2] 
        elseif nNivel = 2
            oJsonRet[cDescNivel][nPosDet]['event'              ] := (cAliasTmp)->EVENTO
            oJsonRet[cDescNivel][nPosDet]['taxCalculationBase' ] := (cAliasTmp)->BASECALC
            oJsonRet[cDescNivel][nPosDet]['tax'                ] := (cAliasTmp)->IMPOSTO            
            oJsonRet[cDescNivel][nPosDet]['invoiceKey'         ] := (cAliasTmp)->EVENTO
            oJsonRet[cDescNivel][nPosDet]['branchId'           ] := cFilSel
        else
          if cEvNivel == 'R-2020'
                oJsonRet[cDescNivel][nPosDet]['registrationNumber'] := (cAliasTmp)->NRINSC
            else
                oJsonRet[cDescNivel][nPosDet]['recipeCode'        ] := (cAliasTmp)->CODREC
            endif    
        
            oJsonRet[cDescNivel][nPosDet]['taxBase'              ] := (cAliasTmp)->BASE_CALCULO
            oJsonRet[cDescNivel][nPosDet]['tax'                  ] := (cAliasTmp)->IMPOSTO
            oJsonRet[cDescNivel][nPosDet]['suspendedContribution'] := (cAliasTmp)->IMPSUS
        
        endif

        (cAliasTmp)->(DbSkip())

    enddo    
    
    //cResponse := oJsonRet:toJSON()
    //self:SetResponse(cResponse)
    if valtype(oQryTmp) != 'U'; FreeObj(oQryTmp); endif
    (cAliasTmp)->(DbCloseArea())
    
Endif

return 

/*/{Protheus.doc} ConsulTot
Função que retorno a tabela temporaria R-9001 para a consulta de nivel 1,2 e 3 
@author Karen Honda  
@since 11/02/2021
@version 1.0
*/
static function ConsulTot(cPeriodo, cFilSel, nNivel,oQryTmp,cEvento)
Local i         := 0
Local nRegTmp   := 0
Local cQuery    := ''
Local cAlias    := getnextalias()
Local cAliasTmp := getnextalias()
Local aEventos  := {}
Local cTblEve   := ''
Local lEventOk  := .f.
Local cGrupBy   := ''
Local aStruct   := {{'EVENTO'   , 'C' , 06 , 0 },;
    		        {'BASECALC' , 'N' , 14 , 2 },;
                    {'IMPOSTO'  , 'N' , 14,  2 }}  
Local lNivel2    := nNivel = 2
Local cWhereEvt  := ""

Default oQryTmp   := Nil

if nNivel = 1

    cQuery += " SELECT DISTINCT "
    cQuery += "    V0W.V0W_FILIAL "
    cQuery += " FROM " + RetSqlName('V0W') + " V0W "
    cQuery += " WHERE V0W.D_E_L_E_T_ = ' ' "
    cQuery += " AND V0W.V0W_PERAPU = '" + cPeriodo + "' "
    cQuery += "	AND V0W.V0W_ATIVO != '2' "
    cQuery += " AND V0W.V0W_FILIAL IN " + cFilSel + " "
    cQuery += " ORDER BY V0W.V0W_FILIAL "
    cQuery := changeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .F., .T. )

elseif ( nNivel = 2 .or. nNivel = 3 )

    if lNivel2 
        aEventos := {'R-2010','R-2020','R-2040','R-2050','R-2055','R-2060', 'R-3010'}
        oQryTmp := FWTemporaryTable():New(cAliasTmp, aStruct)
        oQryTmp:AddIndex('1', {'EVENTO'} )
        oQryTmp:Create()
    else
        aadd(aEventos, cEvento )
    endif    
    
    for i := 1 to len(aEventos)

        lEventOk := .f.
        cQuery := " SELECT "
        
        if aEventos[i] == 'R-2010'
            lEventOk := .t.
            cTblEve := ''

            if lNivel2
                cQuery += " '"+aEventos[i]+"' EVENTO, "
            else
                cQuery += " V0W.V0W_CRTOM CODREC, "
                cQuery += " SUM(V0W.V0W_VLTTNP) IMPSUS, "
                cGrupBy := " V0W.V0W_CRTOM "
            endif
            cWhereEvt := " AND V0W.V0W_TPEVEN = '2010' "
            cQuery += " SUM(V0W.V0W_VLTTBR) BASE_CALCULO, "
            cQuery += " SUM(V0W.V0W_VLTTRP) IMPOSTO "

        ElseIf aEventos[i] == 'R-2020'
            lEventOk := .t.
            cTblEve := ''

            if lNivel2
                cQuery += " '"+aEventos[i]+"' EVENTO, "
            else
                cQuery += " V0W.V0W_NRINST NRINSC,"
                cQuery += " SUM(V0W.V0W_VLPTNP) IMPSUS, "
                cGrupBy :=  " V0W.V0W_NRINST "
            endif
            cWhereEvt := " AND V0W.V0W_TPEVEN = '2020' "
            cQuery += " SUM(V0W.V0W_VLPTBR) BASE_CALCULO,"
            cQuery += " SUM(V0W.V0W_VLPTRP) IMPOSTO "

        ElseIf aEventos[i] == 'R-2040'
            lEventOk := .t.
            
            cTblEve := 'V0Y'
            if lNivel2
                cQuery += " '"+aEventos[i]+"' EVENTO, "
            else
                cQuery += " V0Y.V0Y_CRRECR CODREC, "
                cQuery += " SUM(V0Y.V0Y_VLTNRT) IMPSUS, "
                cGrupBy := " V0Y.V0Y_CRRECR "
            endif   
            cWhereEvt := " AND V0W.V0W_TPEVEN = '2040' "
            cQuery += " SUM(V0Y.V0Y_VLTREP) BASE_CALCULO, "             
            cQuery += " SUM(V0Y.V0Y_VLTRET) IMPOSTO "


        ElseIf aEventos[i] == 'R-2050'
            lEventOk := .t.

            cTblEve := 'V0X'

            if lNivel2
                cQuery += " '"+aEventos[i]+"' EVENTO, "
            else                
                cQuery += " V0X.V0X_CRCOML CODREC,"
                cQuery += " SUM(V0X.V0X_VLSUSP) IMPSUS, "
                cGrupBy := " V0X.V0X_CRCOML "
            endif
            cWhereEvt := " AND V0W.V0W_TPEVEN = '2050' "
            cQuery += " 0 BASE_CALCULO, "
            cQuery += " SUM(V0X.V0X_VLCOML) IMPOSTO "
       
        ElseIf aEventos[i] == 'R-2055'
            lEventOk := .t.
            cTblEve := 'V6B'

            if lNivel2
                cQuery += " '"+aEventos[i]+"' EVENTO, "
            else                
                cQuery += " V6B.V6B_CRAQUI CODREC,"
                cQuery += " SUM(V6B.V6B_VLRCRS) IMPSUS, "
                cGrupBy := " V6B.V6B_CRAQUI "
            endif
            cWhereEvt := " AND V0W.V0W_TPEVEN = '2055' "
            cQuery += " 0 BASE_CALCULO, "
            cQuery += " SUM(V6B.V6B_VLRCRA) IMPOSTO "

        ElseIf aEventos[i] == 'R-2060'
            lEventOk := .t.
            cTblEve := 'V0Z'
            
            if lNivel2
                cQuery += " '"+aEventos[i]+"' EVENTO, "
            else    
                cQuery += " V0Z.V0Z_CODREC CODREC, "
                cQuery += " SUM(V0Z.V0Z_VLCSUS) IMPSUS, "
                cGrupBy := " V0Z.V0Z_CODREC "                            
            endif
            cWhereEvt := " AND V0W.V0W_TPEVEN = '2060' "        
            cQuery += " 0 BASE_CALCULO, "
            cQuery += " SUM(V0Z.V0Z_VLCPAT) IMPOSTO "

        ElseIf aEventos[i] == 'R-3010'
            lEventOk := .t.
            cTblEve := ''

            if lNivel2
                cQuery += " '"+aEventos[i]+"' EVENTO, "
            else    
                cQuery += " V0W.V0W_CRESPE CODREC, "
                cQuery += " SUM(V0W_VLCPST) IMPSUS, "
                cGrupBy := " V0W.V0W_CRESPE "
            endif
            cWhereEvt :=  "AND V0W.V0W_TPEVEN = '3010' "      
            cQuery += " SUM(V0W.V0W_VLRCTT) BASE_CALCULO, "
            cQuery += " SUM(V0W.V0W_VLCPTT) IMPOSTO "
        endif

        if lEventOk
            cQuery += " FROM " + RetSqlName('V0W') + " V0W "
            if !Empty(cTblEve)
                cQuery += " INNER JOIN " + RetSqlName(cTblEve) + ' ' + cTblEve + " ON " + cTblEve + "." + cTblEve + "_FILIAL = V0W.V0W_FILIAL "
                cQuery += "    AND " + cTblEve + "." + cTblEve + "_ID = V0W.V0W_ID "
                cQuery += "    AND " + cTblEve + "." + cTblEve + "_VERSAO = V0W.V0W_VERSAO "
                cQuery += "    AND " + cTblEve + ".D_E_L_E_T_ = ' ' "
            Endif
            cQuery += " WHERE V0W.D_E_L_E_T_ = ' ' "
            cQuery += " AND V0W.V0W_FILIAL = '" + cFilSel + "' "
            cQuery += "	AND V0W.V0W_PERAPU = '" + cPeriodo + "' "
            cQuery += "	AND V0W.V0W_ATIVO != '2' "
            
            if lNivel2
                cQuery += cWhereEvt
                cQuery += " GROUP BY V0W.V0W_TPEVEN " 
            else
                cQuery += cWhereEvt
                if !Empty(cGrupBy)
                    cQuery += " GROUP BY " + cGrupBy
                Endif

            endif    
            cQuery := changeQuery(cQuery)
            dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .F., .T. )

            nRegTmp := 0

            (cAlias)->(dbEval({||nRegTmp++}))
            (cAlias)->(DbGoTop())

            if lNivel2
                if nRegTmp > 0
                    (cAliasTmp)->(RecLock(cAliasTmp,.t.))
                    (cAliasTmp)->EVENTO     := (cAlias)->EVENTO
                    (cAliasTmp)->BASECALC   := (cAlias)->BASE_CALCULO
                    (cAliasTmp)->IMPOSTO    := (cAlias)->IMPOSTO
                    (cAliasTmp)->(DbUnLock()) 
                Endif 
                (cAlias)->(DbCloseArea())   
            endif

        endif    
    next
    if lNivel2
        (cAliasTmp)->(DbGoTop())
        cAlias := cAliasTmp
    endif    
endif

return cAlias



//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QryRel5001
Função responsável por retornar a query para geração do arquivo CSV do relatorio R-9001
@param cPerApu, caracter, Periodo de apuração. Ex: 012021
@param aFil, array, array contendo as filiais

@return aRet, array, array contendo o alias da query

@author Karen Honda
@since 19/02/2021
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------------------
Function QryRel5001(cPerApu,  aFil)
Local aEventos  as array 
Local i         as numeric
Local cQuery    as character
Local cWhereEvt as character
Local cTblEve   as character
Local lEventOk  as logical
Local cFiliais  as character
Local cAliasRel as character
Local aRetAlias as character

cAliasRel	:=	GetNextAlias()
cQuery      := ""
cWhereEvt   := ""
cTblEve     := ""
cFiliais	:= RetFil(aFil)
aRetAlias   := ""
aEventos    := {'R-2010','R-2020','R-2040','R-2050','R-2055','R-2060', 'R-3010'}

for i := 1 to len(aEventos)

    lEventOk := .f.
    if i > 1
        cQuery += " UNION ALL "
    EndIf
    cQuery += " SELECT V0W.V0W_FILIAL FILIAL, V0W.V0W_NRRECB RECIBO, "
    
    if aEventos[i] == 'R-2010'
        lEventOk := .t.
        cTblEve := ''

        cQuery += " '"+aEventos[i]+"' EVENTO, "
        cQuery += " V0W.V0W_CRTOM CODREC, "
        cQuery += " ' ' NRINSC, "
        cQuery += " SUM(V0W.V0W_VLTTNP) IMPSUS, "
        cQuery += " SUM(V0W.V0W_VLTTBR) BASE_CALCULO, "
        cQuery += " SUM(V0W.V0W_VLTTRP) IMPOSTO, "

        cGrupBy := " V0W.V0W_CRTOM "
        cWhereEvt := " AND V0W.V0W_TPEVEN = '2010' "

    ElseIf aEventos[i] == 'R-2020'
        lEventOk := .t.
        cTblEve := ''

        cQuery += " '"+aEventos[i]+"' EVENTO, "

        cQuery += " ' ' CODREC,"
        cQuery += " V0W.V0W_NRINST NRINSC, "
        cQuery += " SUM(V0W.V0W_VLPTNP) IMPSUS, "
        cQuery += " SUM(V0W.V0W_VLPTBR) BASE_CALCULO,"
        cQuery += " SUM(V0W.V0W_VLPTRP) IMPOSTO, "
        cQuery += " SUM(V0W.V0W_VLPTRA) ADICIONAL, "
        cQuery += " SUM(V0W.V0W_VLPTNA) ADICSUSP "

        cGrupBy :=  " V0W.V0W_NRINST "
        cWhereEvt := " AND V0W.V0W_TPEVEN = '2020' "

    ElseIf aEventos[i] == 'R-2040'
        lEventOk := .t.
        
        cTblEve := 'V0Y'
        cQuery += " '"+aEventos[i]+"' EVENTO, "
        cQuery += " V0Y.V0Y_CRRECR CODREC , "
        cQuery += " ' ' NRINSC, "
        cQuery += " SUM(V0Y.V0Y_VLTNRT) IMPSUS, "
        cQuery += " SUM(V0Y.V0Y_VLTREP) BASE_CALCULO, "             
        cQuery += " SUM(V0Y.V0Y_VLTRET) IMPOSTO, "

        cGrupBy := " V0Y.V0Y_CRRECR "
        cWhereEvt := " AND V0W.V0W_TPEVEN = '2040' "
    ElseIf aEventos[i] == 'R-2050'
        lEventOk := .t.

        cTblEve := 'V0X'

        cQuery += " '"+aEventos[i]+"' EVENTO, "
        cQuery += " V0X.V0X_CRCOML CODREC ,"
        cQuery += " ' ' NRINSC, "
        cQuery += " SUM(V0X.V0X_VLSUSP) IMPSUS, "
        cQuery += " 0 BASE_CALCULO, "
        cQuery += " SUM(V0X.V0X_VLCOML) IMPOSTO, "

        cGrupBy := " V0X.V0X_CRCOML "
        cWhereEvt := " AND V0W.V0W_TPEVEN = '2050' "
    
    ElseIf aEventos[i] == 'R-2055'
        lEventOk := .t.
        cTblEve := 'V6B'

        cQuery += " '"+aEventos[i]+"' EVENTO, "
        cQuery += " V6B.V6B_CRAQUI CODREC ,"
        cQuery += " ' ' NRINSC, "
        cQuery += " SUM(V6B.V6B_VLRCRS) IMPSUS, "
        cQuery += " 0 BASE_CALCULO, "
        cQuery += " SUM(V6B.V6B_VLRCRA) IMPOSTO, "

        cGrupBy := " V6B.V6B_CRAQUI "
        cWhereEvt := " AND V0W.V0W_TPEVEN = '2055' "

    ElseIf aEventos[i] == 'R-2060'
        lEventOk := .t.
        cTblEve := 'V0Z'
        
        cQuery += " '"+aEventos[i]+"' EVENTO, "
        cQuery += " V0Z.V0Z_CODREC CODREC , "
        cQuery += " ' ' NRINSC, "
        cQuery += " SUM(V0Z.V0Z_VLCSUS) IMPSUS, "
        cQuery += " 0 BASE_CALCULO, "
        cQuery += " SUM(V0Z.V0Z_VLCPAT) IMPOSTO, "

        cGrupBy := " V0Z.V0Z_CODREC "                            
        cWhereEvt := " AND V0W.V0W_TPEVEN = '2060' "        

    ElseIf aEventos[i] == 'R-3010'
        lEventOk := .t.
        cTblEve := ''

        cQuery += " '"+aEventos[i]+"' EVENTO, "
        cQuery += " V0W.V0W_CRESPE CODREC , "
        cQuery += " ' ' NRINSC, "
        cQuery += " SUM(V0W_VLCPST) IMPSUS, "
        cQuery += " SUM(V0W.V0W_VLRCTT) BASE_CALCULO, "
        cQuery += " SUM(V0W.V0W_VLCPTT) IMPOSTO, "
        cGrupBy := " V0W.V0W_CRESPE "
        cWhereEvt :=  "AND V0W.V0W_TPEVEN = '3010' "      

    endif

    if lEventOk
        if aEventos[i] != "R-2020"
            cQuery += " 0 ADICIONAL, "
            cQuery += " 0 ADICSUSP "
        endif
        cQuery += " FROM " + RetSqlName('V0W') + " V0W "
        if !Empty(cTblEve)
            cQuery += " INNER JOIN " + RetSqlName(cTblEve) + ' ' + cTblEve + " ON " + cTblEve + "." + cTblEve + "_FILIAL = V0W.V0W_FILIAL "
            cQuery += "    AND " + cTblEve + "." + cTblEve + "_ID = V0W.V0W_ID "
            cQuery += "    AND " + cTblEve + "." + cTblEve + "_VERSAO = V0W.V0W_VERSAO "
            cQuery += "    AND " + cTblEve + ".D_E_L_E_T_ = ' ' "
        Endif
        cQuery += " WHERE V0W.D_E_L_E_T_ = ' ' "
        cQuery += " AND V0W.V0W_FILIAL IN (" + cFiliais + ")  "
        cQuery += "	AND V0W.V0W_PERAPU = '" + cPerApu + "' "
        cQuery += "	AND V0W.V0W_ATIVO != '2' "
        
        cQuery += cWhereEvt
        cQuery += " GROUP BY V0W.V0W_FILIAL, V0W.V0W_NRRECB "
        if !Empty(cGrupBy)
            cQuery += "," + cGrupBy
        Endif

    endif    
next
If lEventOk
		
    cQuery := changeQuery(cQuery)
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasRel, .F., .T. )
    TCSetField(cAliasRel, "IMPSUS" ,"N", 14, 2 )
    TCSetField(cAliasRel, "BASE_CALCULO" ,"N", 14, 2 )
    TCSetField(cAliasRel, "IMPOSTO" ,"N", 14, 2 )
    TCSetField(cAliasRel, "ADICIONAL" ,"N", 14, 2 )
    TCSetField(cAliasRel, "ADICSUSP" ,"N", 14, 2 )

	aRetAlias := cAliasRel
EndIf
Return aRetAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado pela tela da apuraÃ§Ã£o
para que fique no formato de execuÃ§Ã£o do IN no SQL

@author Henrique Pereira
@since 08/03/2018
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

