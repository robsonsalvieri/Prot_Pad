#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPR011C.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR011C
Relatorio de recursos sem escalas (Urbano)

@author SIGAGTP | João Paulo Pires
@since 09/01/2026

@type function
/*/
//-------------------------------------------------------------------
Function GTPR011C()
    Local oReport := nil

    oReport := RPTStruct()
    oReport:PrintDialog()
   

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptStruc
Define estrutura de campos

@author SIGAGTP | João Paulo Pires
@since 09/01/2026

@type function
/*/
//-------------------------------------------------------------------
Static Function RPTStruct()
    Local oReport   := nil
    Local oSection1 := nil
    Local cPerg     := "GTPR011C"

    Pergunte(cPerg,.T.)

    oReport := TReport():New("GTPR011C",STR0001,cPerg,{|oReport|RPTPrint(oReport)},STR0002) //"Relatório recursos sem escalas" -"Rel. de recursos sem escalas"
    oReport:SetLandscape(.T.)

    oSection1 := TRSection():New(oReport, STR0003,{"H7R"}, NIL,.F.,.T.) //"Registro"
    oSection1:SetHeaderSection(.T.)
    TRCell():New(oSection1,"FILIAL"       ,"H76",  STR0008 ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Filial" 
    TRCell():New(oSection1,"RECURSO"      ,"H76",  STR0007 ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Recurso" 
    TRCell():New(oSection1,"CODREC"       ,"H76",  STR0004 ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Cod. Recurso"
    TRCell():New(oSection1,"NOMREC"       ,"H76",  STR0005 ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Nome Recurso"
    TRCell():New(oSection1,"TURNO"        ,"H76",  STR0006 ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Turno" 
  

Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} RPTPrint
Realiza impressão do relatório

@author SIGAGTP | João Paulo Pires
@since 09/01/2026

@type function
/*/
//-------------------------------------------------------------------    
Static Function RPTPrint(oReport)
    Local oSection1  := oReport:Section(1)    
    Local cDtIni     := DtoS(MV_PAR01)
    Local cDtFim     := DtoS(MV_PAR02)    
    Local nTipoRec   := MV_PAR03
    Local cAliasVei  := ""
    Local cAliasMot  := ""
    Local cAliasCob  := ""
    Local nScan      := 0
    Local aTurnos    := {{"1","Manha"}, {"2","Tarde"},{"3","Noite"},;
                       {"12","Manha/Tarde"},{"13","Manha/Noite"},;
                       {"23","Tarde/Noite"},{"123","Manha/Tarde/Noite"}}

    oSection1:Init()
            
    If nTipoRec == 1 .OR. nTipoRec == 4
        getRecursos(cDtIni,cDtFim,@cAliasVei,1)

        while (cAliasVei)->(!Eof())            

            oSection1:Cell("FILIAL"    ):SetValue(ALLTRIM((cAliasVei)->FILIAL))                  
            oSection1:Cell("RECURSO"   ):SetValue("VEICULO")                             
            oSection1:Cell("CODREC"    ):SetValue(ALLTRIM((cAliasVei)->CODREC))
            oSection1:Cell("NOMREC"    ):SetValue(ALLTRIM((cAliasVei)->NOMREC))
            
            oSection1:Printline()

            (cAliasVei)->(DBSkip())
        Enddo
        oReport:ThinLine()

        (cAliasVei)->(dbCloseArea())
    Endif

    If nTipoRec == 2 .OR. nTipoRec == 4
        getRecursos(cDtIni,cDtFim,@cAliasMot,2)

        while (cAliasMot)->(!Eof())    
            nScan := aScan(aTurnos,{|x| x[1] == ALLTRIM((cAliasMot)->TURNO)})        

            oSection1:Cell("FILIAL"    ):SetValue(ALLTRIM((cAliasMot)->FILIAL))                  
            oSection1:Cell("RECURSO"   ):SetValue("MOTORISTA")                                                       
            oSection1:Cell("CODREC"    ):SetValue(ALLTRIM((cAliasMot)->CODREC))
            oSection1:Cell("NOMREC"    ):SetValue(ALLTRIM((cAliasMot)->NOMREC))
            If nScan > 0
                oSection1:Cell("TURNO"     ):SetValue(UPPER(aTurnos[nScan,2]))
            Endif
            oSection1:Printline()

            (cAliasMot)->(DBSkip())
        Enddo
        oReport:ThinLine()

        (cAliasMot)->(dbCloseArea())
    Endif

    If nTipoRec == 3 .OR. nTipoRec == 4
        getRecursos(cDtIni,cDtFim,@cAliasCob,3)

        while (cAliasCob)->(!Eof())           
            nScan := aScan(aTurnos,{|x| x[1] == ALLTRIM((cAliasCob)->TURNO)}) 

            oSection1:Cell("FILIAL"    ):SetValue(ALLTRIM((cAliasCob)->FILIAL))                  
            oSection1:Cell("RECURSO"   ):SetValue("COBRADOR")                                                                           
            oSection1:Cell("CODREC"    ):SetValue(ALLTRIM((cAliasCob)->CODREC))
            oSection1:Cell("NOMREC"    ):SetValue(ALLTRIM((cAliasCob)->NOMREC))
            If nScan > 0
                oSection1:Cell("TURNO"     ):SetValue(UPPER(aTurnos[nScan,2]))
            Endif

            oSection1:Printline()

            (cAliasCob)->(DBSkip())
        Enddo
        oReport:ThinLine()

        (cAliasCob)->(dbCloseArea())
    Endif

    oSection1:Finish()   

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRecursos
Retorna lista de recursos sem escalas

@author SIGAGTP | João Paulo Pires
@since 09/01/2026

@type function
/*/
//-----------------------------------------------------------------
Static function getRecursos(cDataIni, cDataFim, cAlias, nTipoRec)

    Local oQuery    := Nil
	Local cQuery    := ""

    If nTipoRec == 1
    
        cQuery := " SELECT H70.H70_FILIAL FILIAL,"  
        cQuery +=   " H70.H70_CODVEI CODREC,"
        cQuery +=   " ST9.T9_NOME NOMREC"

        cQuery += " FROM " + RetSqlName('H70') + " H70"

        cQuery += " INNER JOIN " + RetSqlName('ST9') + " ST9 "
        cQuery +=   " ON (ST9.T9_FILIAL = '" + XFilial('ST9') + "' "
        cQuery +=       " AND ST9.T9_CODBEM = H70.H70_CODVEI"
        cQuery +=       " AND ST9.T9_CATBEM IN ('2', '4')"
        cQuery +=       " AND ST9.D_E_L_E_T_ = '')"

        cQuery += " WHERE H70.H70_FILIAL = '" + xFilial("H70") + "'"
        cQuery +=   " AND H70.H70_STATUS = '1'"
        cQuery +=   " AND H70.D_E_L_E_T_ = ''"
        cQuery +=   " AND NOT EXISTS "
        cQuery +=   " (SELECT 1 FROM " + RetSqlName('H7F') + " H7F"
        cQuery +=   " INNER JOIN " + RetSqlName('H7G') + " H7G "
        cQuery +=       " ON (H7G.H7G_FILIAL = '" + XFilial('H7G') + "'"
        cQuery +=       " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO"
        cQuery +=       " AND (H7G.H7G_CODH70 IS NOT NULL"
        cQuery +=           " AND H7G.H7G_CODH70 <> '')
        cQuery +=           " AND H7G.H7G_CODH70 = H70.H70_CODVEI"
        cQuery +=           " AND H7G.D_E_L_E_T_ = '')"

        cQuery += " WHERE H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
        cQuery +=   " AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
        cQuery +=   " AND H7F.D_E_L_E_T_ = '')

        cQuery += " GROUP BY H70.H70_FILIAL,"        
        cQuery +=   " H70.H70_CODVEI,"        
        cQuery +=   " ST9.T9_NOME"

    ElseIf nTipoRec == 2

        cQuery := " SELECT  "
        cQuery += "     GYG.GYG_FILSRA FILIAL, "
        cQuery += "     GYG.GYG_FUNCIO CODREC, "
        cQuery += "     GYG.GYG_NOME   NOMREC, "
        cQuery += "     GYG.GYG_TURNO  TURNO "
        cQuery += " FROM  " + RetSqlName('GYG') + " GYG "
        cQuery += " INNER JOIN " + RetSqlName('GYK') + " GYK "
        cQuery += " ON GYK.GYK_FILIAL = '" + XFilial('GYK') + "' "
        cQuery += " AND GYG.GYG_RECCOD = GYK.GYK_CODIGO "        
        cQuery += " AND GYK.D_E_L_E_T_ = '' "
        cQuery += " WHERE  GYG.GYG_FILIAL = '" + XFilial('GYG') + "'"
        cQuery += "     AND GYG.GYG_URBANO = 'T' "
        cQuery += "     AND GYK.GYK_TIPREC = '1' "
        cQuery += "     AND NOT EXISTS (SELECT 1 "
        cQuery += "                     FROM " + RetSqlName('H7R') + " H7R "
        cQuery += "                     WHERE  H7R_FILIAL = '" + XFilial('H7R') + "' "
        cQuery += "                             AND H7R.H7R_COLAB = GYG.GYG_CODIGO "
        cQuery += "                             AND H7R.H7R_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
        cQuery += "                             AND H7R.D_E_L_E_T_ = '') "
        cQuery += "     AND NOT EXISTS(SELECT 1 "
        cQuery += "                     FROM " + RetSqlName('H7F') + " H7F "
        cQuery += "                             INNER JOIN " + RetSqlName('H7G') + " H7G "
        cQuery += "                                     ON ( H7G.H7G_FILIAL = '" + XFilial('H7G') + "' "
        cQuery += "                                         AND H7G.H7G_CODH7F = H7F.H7F_CODIGO "
        cQuery += "                                         AND ( H7G.H7G_CODGYG IS NOT NULL ) "
        cQuery += "                                         AND ( H7G.H7G_CODGYG <> '' ) "
        cQuery += "                                         AND H7G.H7G_CODGYG = GYG.GYG_CODIGO "
        cQuery += "                                         AND H7G.D_E_L_E_T_ = '' ) "
        cQuery += "                     WHERE  H7F.H7F_FILIAL = '" + XFilial('H7F') + "' "
        cQuery += "                             AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
        cQuery += "                             AND H7F.D_E_L_E_T_ = '') "
        cQuery += "     AND GYG.D_E_L_E_T_ = ''  "
        cQuery += "     GROUP BY "
        cQuery += "     GYG.GYG_FILSRA, "
        cQuery += "     GYG.GYG_FUNCIO, "
        cQuery += "     GYG.GYG_NOME, "
        cQuery += "     GYG.GYG_TURNO "

    ElseIf nTipoRec == 3

        cQuery := " SELECT  "
        cQuery += "     GYG.GYG_FILSRA FILIAL, "
        cQuery += "     GYG.GYG_FUNCIO CODREC, "
        cQuery += "     GYG.GYG_NOME   NOMREC, "
        cQuery += "     GYG.GYG_TURNO  TURNO "
        cQuery += " FROM  " + RetSqlName('GYG') + " GYG "
        cQuery += " INNER JOIN " + RetSqlName('GYK') + " GYK "
        cQuery += " ON GYK.GYK_FILIAL = '" + XFilial('GYK') + "' "
        cQuery += " AND GYG.GYG_RECCOD = GYK.GYK_CODIGO "        
        cQuery += " AND GYK.D_E_L_E_T_ = '' "
        cQuery += " WHERE  GYG.GYG_FILIAL = '" + XFilial('GYG') + "'"
        cQuery += "     AND GYG.GYG_URBANO = 'T' "
        cQuery += "     AND GYK.GYK_TIPREC = '2' "
        cQuery += "     AND NOT EXISTS (SELECT 1 "
        cQuery += "                     FROM " + RetSqlName('H7R') + " H7R "
        cQuery += "                     WHERE  H7R_FILIAL = '" + XFilial('H7R') + "' "
        cQuery += "                             AND H7R.H7R_COLAB = GYG.GYG_CODIGO "
        cQuery += "                             AND H7R.H7R_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
        cQuery += "                             AND H7R.D_E_L_E_T_ = '') "
        cQuery += "     AND NOT EXISTS(SELECT 1 "
        cQuery += "                     FROM " + RetSqlName('H7F') + " H7F "
        cQuery += "                             INNER JOIN " + RetSqlName('H7G') + " H7G "
        cQuery += "                                     ON ( H7G.H7G_FILIAL = '" + XFilial('H7G') + "' "
        cQuery += "                                         AND H7G.H7G_CODH7F = H7F.H7F_CODIGO "
        cQuery += "                                         AND ( H7G.H7G_CODCOB IS NOT NULL ) "
        cQuery += "                                         AND ( H7G.H7G_CODCOB <> '' ) "
        cQuery += "                                         AND H7G.H7G_CODCOB = GYG.GYG_CODIGO "
        cQuery += "                                         AND H7G.D_E_L_E_T_ = '' ) "
        cQuery += "                     WHERE  H7F.H7F_FILIAL = '" + XFilial('H7F') + "' "
        cQuery += "                             AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
        cQuery += "                             AND H7F.D_E_L_E_T_ = '') "
        cQuery += "     AND GYG.D_E_L_E_T_ = ''  "
        cQuery += "     GROUP BY "
        cQuery += "     GYG.GYG_FILSRA, "
        cQuery += "     GYG.GYG_FUNCIO, "
        cQuery += "     GYG.GYG_NOME, "
        cQuery += "     GYG.GYG_TURNO "
    
    EndIf

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return
