#INCLUDE "TOTVS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WS0025011()

Função que retorna o Json para o relatório do evento totalizador 5011
@author Wesley Matos / Carlos Eduardo N Silva
@since 10/02/2021
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
function WS0025011(oJsonRet, cFilSel, cPeriodo, cEvento, cId , nNivel)
Local oQryTmp    := nil
Local cDescNivel := ''
Local lRet       := .t.
Local cEvNivel   := iif(nNivel != 3, cEvento, cId )

Default cFilSel := ''
Default cPeriodo := ''
Default cEvento := ''
Default cId := ''
Default nNivel := 0

if nNivel = 1
    cDescNivel := 'eventDetail'
elseif nNivel = 2
    cDescNivel := 'invoices'
else
    cDescNivel := 'tax'
endif

cAliasTmp := ConsulTot(cPeriodo, cFilSel ,nNivel ,@oQryTmp, cEvNivel)

while (cAliasTmp)->(!eof())
    
    aadd(oJsonRet[cDescNivel],JsonObject():New())
    nPosDet := len(oJsonRet[cDescNivel])

    if nNivel = 1
        oJsonRet[cDescNivel][nPosDet]['branchId'       ] := (cAliasTmp)->V0C_FILIAL  
        oJsonRet[cDescNivel][nPosDet]['companyName'    ] := FWSM0Util( ):GetSM0Data( , (cAliasTmp)->V0C_FILIAL , { 'M0_FILIAL' } )[1][2] 
        oJsonRet[cDescNivel][nPosDet]['branchTaxNumber'] := FWSM0Util( ):GetSM0Data( , (cAliasTmp)->V0C_FILIAL , { 'M0_CGC'    } )[1][2] 
        oJsonRet[cDescNivel][nPosDet]['receipt'        ] := (cAliasTmp)->V0C_PROTUL
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
            oJsonRet[cDescNivel][nPosDet]['recipeCode'              ] := (cAliasTmp)->CODREC
        endif    
        oJsonRet[cDescNivel][nPosDet]['taxBase'              ] := (cAliasTmp)->BASE_CALCULO            
        oJsonRet[cDescNivel][nPosDet]['tax'                  ] := (cAliasTmp)->IMPOSTO
        oJsonRet[cDescNivel][nPosDet]['suspendedContribution'] := (cAliasTmp)->IMPSUS
        endif

    (cAliasTmp)->(DbSkip())

enddo    

if valtype(oQryTmp) != 'U'; FreeObj(oQryTmp); endif
(cAliasTmp)->(DbCloseArea())

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Query para consulta dos eventos vindo do POUI(WSTAF002).
@author Wesley Matos / Carlos Eduardo N Silva
@since 10/02/2021
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
static function ConsulTot(cPeriodo, cFilSel, nNivel,oQryTmp,cEvento)
Local i         := 0
Local cQuery    := ''
Local cAlias    := getnextalias()
Local cAliasTmp := getnextalias()
Local aEventos  := {}
Local cTblEve   := ''
Local lEventOk  := .f.
Local cGrupBy   := ''
Local aStruct    := {{'EVENTO'   , 'C' , 06 , 0 },;
    		         RetInfCmp('V0F_VLRBRE', 'BASECALC' ),;
                     RetInfCmp('V0F_VLRTOM', 'IMPOSTO'  )}
Local lNivel2    := nNivel = 2

Default oQryTmp := ''  

if nNivel = 1
    cQuery += " SELECT "
    cQuery += "    V0C.V0C_FILIAL, "
    cQuery += "	   V0C.V0C_PROTUL "
    cQuery += " FROM " + RetSqlName('V0C') + " V0C "
    cQuery += " WHERE V0C.D_E_L_E_T_ = ' ' "
    cQuery += " AND V0C.V0C_PERAPU = '" + cPeriodo + "' "
    cQuery += "	AND V0C.V0C_ATIVO != '2' "
    cQuery += " AND V0C.V0C_FILIAL IN " + cFilSel + " "
    cQuery += " ORDER BY V0C.V0C_FILIAL "
    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .F., .T. )
elseif ( nNivel = 2 .or. nNivel = 3 )
    
    if lNivel2 
        aEventos := {'R-2010','R-2020','R-2040','R-2050','R-2055','R-2060'}
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
            cTblEve := 'V0F'
            
            if lNivel2
                cQuery += " 'R-2010' EVENTO, "
            else
                cQuery += " V0F.V0F_CRTOM CODREC, "
                cQuery += " SUM (V0F.V0F_VLRSUS) IMPSUS,"
                cGrupBy := " V0F.V0F_CRTOM "
            endif
            cQuery += " SUM(V0F.V0F_VLRBRE) BASE_CALCULO, "
            cQuery += " SUM(V0F.V0F_VLRTOM) IMPOSTO "

        ElseIf aEventos[i] == 'R-2020'
            lEventOk := .t.
            cTblEve := 'V0G'

            if lNivel2
                cQuery += " 'R-2020' EVENTO, "
            else
                cQuery += " V0G.V0G_NRINST NRINSC,"
                cQuery += " SUM(V0G.V0G_VLRNPR) IMPSUS,"
                cGrupBy :=  " V0G.V0G_NRINST "
            endif
            cQuery += " SUM(V0G.V0G_VLRPRI) IMPOSTO,"
            cQuery += " SUM(V0G.V0G_VLRBRE) BASE_CALCULO"

        ElseIf aEventos[i] == 'R-2040'
            lEventOk := .t.
            cTblEve := 'V0H'
            
            if lNivel2
                cQuery += " 'R-2040' EVENTO, "
            else
                cQuery += " V0H.V0H_CRRECR CODREC, "
                cQuery += " SUM(V0H.V0H_VLRNRE) IMPSUS, " 
                cGrupBy := " V0H.V0H_CRRECR "
            endif                
            cQuery += " SUM(V0H.V0H_VLRREP) BASE_CALCULO, "
            cQuery += " SUM(V0H.V0H_VLRRET) IMPOSTO "

        ElseIf aEventos[i] == 'R-2050'
            lEventOk := .t.
            cTblEve := 'V0I'
            
            if lNivel2
                cQuery += " 'R-2050' EVENTO, "
            else                
                cQuery += " V0I.V0I_CRCOML CODREC,"
                cQuery += " SUM(V0I.V0I_VRCOMS) IMPSUS, "
                cGrupBy := " V0I.V0I_CRCOML "                
            endif
            cQuery += "0 BASE_CALCULO, "
            cQuery += "SUM(V0I.V0I_VRCOML) IMPOSTO "

        
        ElseIf aEventos[i] == 'R-2055'
            lEventOk := .t.
            cTblEve := 'V6C'

            if lNivel2
                cQuery += " 'R-2055' EVENTO, "
            else
                cQuery += " V6C.V6C_CODREC CODREC, "
                cQuery += " SUM(V6C.V6C_VLSUSP) IMPSUS, "
                cGrupBy := " V6C.V6C_CODREC "                                
            endif
            cQuery += " 0 BASE_CALCULO, "                    
            cQuery += " SUM(V6C.V6C_VRAQUI) IMPOSTO " 


        ElseIf aEventos[i] == 'R-2060'
            lEventOk := .t.
            cTblEve := 'V0J'

            if lNivel2
                cQuery += " 'R-2060' EVENTO, "
            else    
                cQuery += " V0J.V0J_CODREC CODREC, "
                cQuery += " SUM(V0J.V0J_VLRCPS) IMPSUS, "
                cGrupBy := " V0J.V0J_CODREC "                                
            endif
            cQuery += " 0 BASE_CALCULO, "
            cQuery += " SUM(V0J.V0J_VLRCPT) IMPOSTO "

        endif

        if lEventOk
            cQuery += " FROM " + RetSqlName('V0C') + " V0C "
            
            cQuery += " INNER JOIN " + RetSqlName('V0E') + " V0E ON V0E.V0E_FILIAL = V0C.V0C_FILIAL " 
            cQuery += "   AND V0E.V0E_ID = V0C.V0C_ID "
            cQuery += "   AND V0E.V0E_VERSAO = V0C.V0C_VERSAO "
            cQuery += "   AND V0E.D_E_L_E_T_= ' ' "
            
            cQuery += " INNER JOIN " + RetSqlName(cTblEve) + ' ' + cTblEve + " ON " + cTblEve + "." + cTblEve + "_FILIAL = V0C.V0C_FILIAL "
            cQuery += "    AND " + cTblEve + "." + cTblEve + "_ID = V0C.V0C_ID "
            cQuery += "    AND " + cTblEve + "." + cTblEve + "_VERSAO = V0C.V0C_VERSAO "
            cQuery += "    AND " + cTblEve + "." + cTblEve + "_NRREC = V0E.V0E_NRREC "
            cQuery += "    AND " + cTblEve + ".D_E_L_E_T_ = ' ' "

            cQuery += " WHERE V0C.D_E_L_E_T_ = ' ' "
            cQuery += "	AND V0C.V0C_PERAPU = '" + cPeriodo + "' "
            cQuery += "	AND V0C.V0C_ATIVO != '2' "
            cQuery += " AND V0C.V0C_FILIAL = '" + cFilSel  + "' "

            if !lNivel2
                if !Empty(cGrupBy)
                    cQuery += " GROUP BY " + cGrupBy
                Endif
            endif    

            dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAlias, .F., .T. )

             nRegTmp := 0

            (cAlias)->(dbEval({||nRegTmp++}))
            (cAlias)->(DbGoTop())

            if lNivel2
                if nRegTmp > 0 
                    If (cAlias)->BASE_CALCULO > 0 .OR.  (cAlias)->IMPOSTO > 0
                        (cAliasTmp)->(RecLock(cAliasTmp,.t.))
                        (cAliasTmp)->EVENTO     := (cAlias)->EVENTO
                        (cAliasTmp)->BASECALC   := (cAlias)->BASE_CALCULO
                        (cAliasTmp)->IMPOSTO    := (cAlias)->IMPOSTO
                        (cAliasTmp)->(DbUnLock()) 
                    Endif
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

/*------------------------------------------------------------------------------
{Protheus.doc} QryRel5011()

Query para consulta dos eventos por periodo de apuracao e exportação para excel
@author Wesley Matos / Carlos Eduardo N Silva
@since 19/02/2021
@version 1.0
@return
------------------------------------------------------------------------------*/ 
Function QryRel5011(cPerApu,  aFil)
Local aRetAlias  := ""
Local i          := 0
Local cAliasN1   := getnextalias()
Local cAliasN2   := getnextalias()
Local cAliasTmp  := getnextalias()
Local oQryTmp    := nil
Local cQryN1     := ''
Local cQryN2     := ''
Local cGrpOrd    := ''
Local aEventos   := { {'R-2010','V0F'},{'R-2020','V0G'},{'R-2040','V0H'},{'R-2050','V0I'},{'R-2055','V6C'},{'R-2060','V0J'}}

Local aStruct   := { {'NOMEFIL'    , 'C', 45, 0 },;
                     {'CNPJ_CPF'   , 'C', 20, 0 },;
                     {'EVENTO'     , 'C', 06, 0 },;
                     RetInfCmp('V0C_FILIAL', 'FILIAL'   ),;
                     RetInfCmp('V0C_PROTUL', 'RECIBO'   ),;
                     RetInfCmp('V0F_CRTOM' , 'CODREC'   ),;
                     RetInfCmp('V0G_NRINST', 'NRINSC'   ),; 
    		         RetInfCmp('V0F_VLRBRE', 'BASECALC' ),; 
                     RetInfCmp('V0F_VLRTOM', 'IMPOSTO'  ),; 
                     RetInfCmp('V0F_VLRSUS', 'IMPSUS'   ),; 
                     RetInfCmp('V0F_VLRNPR', 'ADICIONAL'),; 
                     RetInfCmp('V0F_VLRNAD', 'ADICSUSP' ) }

cQryN1 += " SELECT "
cQryN1 += " 	V0C.V0C_FILIAL FILIAL, "
cQryN1 += "	    V0C.V0C_ID ID_PAI,
cQryN1 += "	    V0C.V0C_VERSAO VERSAO,
cQryN1 += " 	V0C.V0C_PROTUL RECIBO, "
cQryN1 += " 	V0E.V0E_NRREC NRREC"
cQryN1 += " FROM " + RetSqlName('V0C') + " V0C "
cQryN1 += " INNER JOIN " + RetSqlName('V0E') + " V0E "
cQryN1 += " 		ON V0E.V0E_FILIAL = V0C.V0C_FILIAL "
cQryN1 += " 	   	AND V0E.V0E_ID = V0C.V0C_ID  "
cQryN1 += " 		AND V0E.V0E_VERSAO = V0C.V0C_VERSAO "
cQryN1 += " 		AND V0E.D_E_L_E_T_= ' ' "
cQryN1 += " WHERE V0C.D_E_L_E_T_ = ' ' "
cQryN1 += "     AND V0C.V0C_PERAPU = '" + cPerApu + "' "
cQryN1 += "     AND V0C.V0C_ATIVO != '2' "
cQryN1 += " ORDER BY V0C.V0C_FILIAL "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryN1 ) , cAliasN1, .F., .T. )

while (cAliasN1)->(!eof())
    
    cQryN2  := ''
    cGrpOrd := ''

    //Cria tabela temporaria caso ela não exista
    if valtype(oQryTmp) == 'U'
        oQryTmp := FWTemporaryTable():New(cAliasTmp, aStruct)
        oQryTmp:AddIndex('1', {'FILIAL','EVENTO'} )
        oQryTmp:Create()
    endif   

    for i := 1 to len(aEventos)
        cQryN2  += " SELECT "
        cGrpOrd := ""
        
        if aEventos[i][1] == 'R-2010'

            cQryN2 += " '" + aEventos[i][1] + "' EVENTO,"
            cQryN2 += " V0F_CRTOM CODREC, "
            cQryN2 += " ' ' NRINSC,"            
            cQryN2 += " SUM(V0F_VLRBRE) BASE_CALCULO, "
            cQryN2 += " SUM(V0F_VLRTOM) IMPOSTO, "
            cQryN2 += " SUM (V0F_VLRSUS) IMPSUS, "
            cQryN2 += " 0 ADICIONAL, "
            cQryN2 += " 0 ADICSUSP "         

            cGrpOrd := 'V0F_CRTOM '  

        elseif aEventos[i][1] == 'R-2020'

            cQryN2 += " '" + aEventos[i][1] + "' EVENTO,"
            cQryN2 += " ' ' CODREC, "
            cQryN2 += " V0G_NRINST NRINSC,"
            cQryN2 += " SUM(V0G_VLRBRE) BASE_CALCULO,"
            cQryN2 += " SUM(V0G_VLRPRI) IMPOSTO,"
            cQryN2 += " SUM(V0G_VLRNPR) IMPSUS,"
            cQryN2 += " SUM(V0G_VLRNPR) ADICIONAL, "
            cQryN2 += " SUM(V0G_VLRNAD) ADICSUSP "

            cGrpOrd := 'V0G_NRINST '  

        elseif aEventos[i][1] == 'R-2040'

            cQryN2 += " '" + aEventos[i][1] + "' EVENTO,"
            cQryN2 += " V0H_CRRECR CODREC, "
            cQryN2 += " ' ' NRINSC,"                        
            cQryN2 += " SUM(V0H_VLRREP) BASE_CALCULO, "
            cQryN2 += " SUM(V0H_VLRRET) IMPOSTO, "        
            cQryN2 += " SUM(V0H_VLRNRE) IMPSUS, " 
            cQryN2 += " 0 ADICIONAL, "
            cQryN2 += " 0 ADICSUSP "  

            cGrpOrd := 'V0H_CRRECR '                      

        elseif aEventos[i][1] == 'R-2050'

            cQryN2 += " '" + aEventos[i][1] + "' EVENTO,"
            cQryN2 += " V0I_CRCOML CODREC,"
            cQryN2 += " ' ' NRINSC,"                        
            cQryN2 += " 0 BASE_CALCULO, "
            cQryN2 += " SUM(V0I_VRCOML) IMPOSTO, "        
            cQryN2 += " SUM(V0I_VRCOMS) IMPSUS, "
            cQryN2 += " 0 ADICIONAL, "
            cQryN2 += " 0 ADICSUSP "                      

            cGrpOrd := 'V0I_CRCOML '                      

        elseif aEventos[i][1] == 'R-2055'

            cQryN2 += " '" + aEventos[i][1] + "' EVENTO,"       
            cQryN2 += " V6C_CODREC CODREC, "
            cQryN2 += " ' ' NRINSC, "                        
            cQryN2 += " 0 BASE_CALCULO, "                    
            cQryN2 += " SUM(V6C_VRAQUI) IMPOSTO, "         
            cQryN2 += " SUM(V6C_VLSUSP) IMPSUS, "
            cQryN2 += " 0 ADICIONAL, "
            cQryN2 += " 0 ADICSUSP "      

            cGrpOrd := 'V6C_CODREC '                                      

        elseif aEventos[i][1] == 'R-2060'                

            cQryN2 += " '" + aEventos[i][1] + "' EVENTO,"
            cQryN2 += " V0J_CODREC CODREC, "
            cQryN2 += " ' ' NRINSC,"                        
            cQryN2 += " 0 BASE_CALCULO, "
            cQryN2 += " SUM(V0J_VLRCPT) IMPOSTO, "        
            cQryN2 += " SUM(V0J_VLRCPS) IMPSUS, "
            cQryN2 += " 0 ADICIONAL, "
            cQryN2 += " 0 ADICSUSP "    

            cGrpOrd := 'V0J_CODREC '                                                        

        endif
       
        cQryN2 += " FROM " + RetSqlName(aEventos[i][2])
        cQryN2 += " WHERE D_E_L_E_T_ = ' ' "
        cQryN2 += "     AND " + aEventos[i][2] + "_FILIAL = '" + (cAliasN1)->FILIAL + "' "
        cQryN2 += "     AND " + aEventos[i][2] + "_ID = '" + (cAliasN1)->ID_PAI + "' "
        cQryN2 += "     AND " + aEventos[i][2] + "_VERSAO = '" + (cAliasN1)->VERSAO + "' "
        cQryN2 += "     AND " + aEventos[i][2] + "_NRREC = '" + (cAliasN1)->NRREC + "' "
        
        if !Empty(cGrpOrd)
            cQryN2 += " GROUP BY " + cGrpOrd
        Endif

        if i < len(aEventos); cQryN2 += " UNION "; endif
    next

    dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryN2 ) , cAliasN2, .F., .T. )

    while (cAliasN2)->(!eof())
        (cAliasTmp)->(RecLock(cAliasTmp,.t.))
        (cAliasTmp)->FILIAL       := (cAliasN1)->FILIAL
        (cAliasTmp)->NOMEFIL      := FWSM0Util( ):GetSM0Data( , (cAliasN1)->FILIAL , { 'M0_FILIAL' } )[1][2]
        (cAliasTmp)->CNPJ_CPF     := FWSM0Util( ):GetSM0Data( , (cAliasN1)->FILIAL , { 'M0_CGC' } )[1][2]
        (cAliasTmp)->RECIBO       := (cAliasN1)->RECIBO
        (cAliasTmp)->EVENTO       := (cAliasN2)->EVENTO
        (cAliasTmp)->CODREC       := (cAliasN2)->CODREC
        (cAliasTmp)->NRINSC       := (cAliasN2)->NRINSC
        (cAliasTmp)->BASECALC := (cAliasN2)->BASE_CALCULO
        (cAliasTmp)->IMPOSTO      := (cAliasN2)->IMPOSTO
        (cAliasTmp)->IMPSUS       := (cAliasN2)->IMPSUS
        (cAliasTmp)->ADICIONAL    := (cAliasN2)->ADICIONAL
        (cAliasTmp)->ADICSUSP     := (cAliasN2)->ADICSUSP
        (cAliasTmp)->(MsUnlock())

        (cAliasN2)->(DbSkip())
    enddo
    (cAliasN2)->(DbCloseArea())

    (cAliasN1)->(DbSkip())
enddo
(cAliasN1)->(DbCloseArea())

aRetAlias := cAliasTmp

return aRetAlias


/*-------------------------------------------------------------
{Protheus.doc} QryRel5011()

retorna um array com a estrutura do campo passado por parametro
@author Wesley Matos / Carlos Eduardo N Silva
@since 19/02/2021
@version 1.0
@return
---------------------------------------------------------------*/ 
Static Function RetInfCmp(cCampoDic, cCampoTmp )
Local aRet := {}
Local aAux := {}

aAux := FWSX3Util():GetFieldStruct(cCampoDic)

if empty(cCampoTmp); cCampoTmp := cCampoDic; endif

aRet := { cCampoTmp, aAux[2], aAux[3], aAux[4] }

return aRet
