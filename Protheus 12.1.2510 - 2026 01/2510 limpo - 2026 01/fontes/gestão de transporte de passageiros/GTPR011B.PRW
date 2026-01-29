#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPR011B.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR011A
Relatorio de escala sem recurso (Urbano)

@author SIGAGTP | João Paulo Pires
@since 05/01/2026

@type function
/*/
//-------------------------------------------------------------------
Function GTPR011B()
    Local oReport := nil

    oReport := RPTStruct()
    oReport:PrintDialog()
   

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptStruc
Define estrutura de campos

@author SIGAGTP | João Paulo Pires
@since 05/01/2026

@type function
/*/
//-------------------------------------------------------------------
Static Function RPTStruct()
    Local oReport   := nil
    Local oSection1 := nil
    Local cPerg     := "GTPR011B"

    Pergunte(cPerg,.T.)

    oReport := TReport():New("GTPR011A",STR0001,cPerg,{|oReport|RPTPrint(oReport)},STR0002) //"Relatório recursos de escalas sem recursos" -"Rel. de escalas sem recurso"
    oReport:SetLandscape(.T.)

    oSection1 := TRSection():New(oReport, STR0003,{"H7R"}, NIL,.F.,.T.) //"Registro"
    oSection1:SetHeaderSection(.T.)
    TRCell():New(oSection1,"H7F_DATA"     ,"H7F",  STR0006 ,,15,,,'LEFT') //"Data"
    TRCell():New(oSection1,"H76_CODIGO"   ,"H76",  STR0004 ,,10,,,'LEFT') //"Escala"   
    TRCell():New(oSection1,"H76_DESCRI"   ,"H76",  STR0009 ,,20,,,'LEFT') //"Desc. Escala"   
    TRCell():New(oSection1,"VEICULO"      ,"H76",  STR0010 ,,50,,,'LEFT') //"Veículo"   
    TRCell():New(oSection1,"MOTORISTA"    ,"H76",  STR0011 ,,50,,,'LEFT') //"Motorista"   
    TRCell():New(oSection1,"COBRADOR"     ,"H76",  STR0012 ,,50,,,'LEFT') //"Cobrador"   
    TRCell():New(oSection1,"H77_CODH6V"   ,"H77",  STR0005 ,,15,,,'LEFT') //"Linha"
    TRCell():New(oSection1,"H6V_CODLIN"   ,"H6V",  STR0008 ,,20,,,'LEFT') //"Cod. Linha"   

Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} RPTPrint
Realiza impressão do relatório

@author SIGAGTP | João Paulo Pires
@since 05/01/2026

@type function
/*/
//-------------------------------------------------------------------    
Static Function RPTPrint(oReport)
    Local oSection1  := oReport:Section(1)    
    Local cDtIni     := DtoS(MV_PAR01)
    Local cDtFim     := DtoS(MV_PAR02)    
    Local cCodLinI   := ALLTRIM(MV_PAR03)
    Local cCodLinF   := ALLTRIM(MV_PAR04)
    Local nTipoRec   := MV_PAR05
    Local dDataAux   := Nil
    Local cQuery2    := ""
    Local cAlias2    := ""
    Local oQuery2    := Nil
    Local aDados     := {}
    Local cDia       := ""

    oSection1:Init()
            
    If !Empty(cDtIni) .AND.  !Empty(cDtFim)
        
        for dDataAux := MV_PAR01 to MV_PAR02
                
            cAlias := getRecursos(DTOS(dDataAux),DTOS(dDataAux),cCodLinI,cCodLinF,nTipoRec)

            while (cAlias)->(!Eof())               
                cDia := UPPER(DiaSemana(dDataAux, 3, ))
            
                If (cDia == "DOM" .AND.  (cAlias)->DOM == 'F') .OR.;
                   (cDia == "SEG" .AND.  (cAlias)->SEG == 'F') .OR.;
                   (cDia == "TER" .AND.  (cAlias)->TER == 'F') .OR.; 
                   (cDia == "QUA" .AND.  (cAlias)->QUA == 'F') .OR.;  
                   (cDia == "QUI" .AND.  (cAlias)->QUI == 'F') .OR.; 
                   (cDia == "SEX" .AND.  (cAlias)->SEX == 'F') .OR.;
                   (cDia == "SAB" .AND.  (cAlias)->SAB == 'F')

                    (cAlias)->(DBSkip())
                    Loop
                    
                Endif

                If Empty((cAlias)->H7F_CODIGO) 
                    aDados := {;
                            dDataAux,;
                            (cAlias)->H76_CODIGO,;
                            (cAlias)->H76_DESCRI,;
                            "",;
                            "",;
                            "",;
                            (cAlias)->H77_CODH6V}      

                    PrintRel(@oSection1,aDados)   
                    
                Else

                    cQuery2 := " SELECT  "
                    cQuery2 += "     H7G_CODH70, "
                    cQuery2 += "     H7G_CODGYG, "
                    cQuery2 += "     H7G_CODCOB	 "
                    cQuery2 += " FROM " + RetSqlName('H7G') + " H7G "
                    cQuery2 += " WHERE  "
                    cQuery2 += " H7G.H7G_FILIAL = '" + xFilial("H7G") + "' "
                    cQuery2 += " AND H7G.H7G_CODH76 = '" + (cAlias)->H76_CODIGO + "' "
                    cQuery2 += " AND H7G_CODH7F = '" + (cAlias)->H7F_CODIGO + "' "
                    cQuery2 += " AND H7G.D_E_L_E_T_ = '' "
                        
                    oQuery2 := FWPreparedStatement():New(cQuery2)
                    cQuery2 := oQuery2:GetFixQuery()
                    cAlias2 := MPSysOpenQuery(cQuery2)
                    cVeiculo   := ""
                    cMotorista := ""
                    cCobrador  := ""

                    If (cAlias2)->(Eof())
                        aDados := {;
                            dDataAux,;
                            (cAlias)->H76_CODIGO,;
                            (cAlias)->H76_DESCRI,;
                            cVeiculo,;
                            cMotorista,;
                            cCobrador,;
                            (cAlias)->H77_CODH6V}     

                        PrintRel(@oSection1,aDados)   
            
                    Else

                        While (cAlias2)->(!Eof())  

                            If !Empty((cAlias2)->H7G_CODH70)
                                cVeiculo := (cAlias2)->H7G_CODH70
                            Endif

                            If !Empty((cAlias2)->H7G_CODGYG)
                                cMotorista := (cAlias2)->H7G_CODGYG
                            Endif

                            If !Empty((cAlias2)->H7G_CODCOB)
                                cCobrador := (cAlias2)->H7G_CODCOB
                            Endif

                            (cAlias2)->(DBSkip())

                        EndDo

                        cVeiculo   := IIF(Empty(cVeiculo) .AND. (cAlias)->H76_QTVEIC == 0,"-",cVeiculo)
                        cMotorista := IIF(Empty(cMotorista) .AND. (cAlias)->H76_QTMOTO == 0,"-",cMotorista)
                        cCobrador  := IIF(Empty(cCobrador) .AND. (cAlias)->H76_QTCOBR == 0,"-",cCobrador)

                        If (nTipoRec == 4 .AND. (Empty(cVeiculo) .OR. Empty(cMotorista) .OR. Empty(cCobrador))).OR.;
                            ((Empty(cVeiculo) .AND. nTipoRec == 1) .OR. (Empty(cMotorista) .AND. nTipoRec == 2) .OR. (Empty(cCobrador) .AND. nTipoRec == 3)) 
                            
                            aSize(aDados,0)
                            aAdd(aDados,dDataAux)        
                            aAdd(aDados,(cAlias)->H76_CODIGO)
                            aAdd(aDados,(cAlias)->H76_DESCRI)

                            If !Empty(cVeiculo) .AND. cVeiculo <> "-"
                                cDesc := Posicione("ST9",1,xFilial("ST9")+cVeiculo,"T9_NOME")
                                aAdd(aDados,ALLTRIM(cVeiculo) + " - " + ALLTRIM(cDesc))                                
                            Else
                                aAdd(aDados,"")
                            Endif
                            
                            If !Empty(cMotorista) .AND. cMotorista <> "-"
                                cDesc := ALLTRIM(Posicione("GYG",1,xFilial("GYG")+cMotorista,"GYG_FUNCIO"))
                                cDesc += " - "+ALLTRIM(Posicione("GYG",1,xFilial("GYG")+cMotorista,"GYG_NOME"))
                                aAdd(aDados,ALLTRIM(cDesc))
                            Else
                                aAdd(aDados,"")
                            Endif
                                                   
                            If !Empty(cCobrador) .AND. cCobrador <> "-"
                                cDesc := ALLTRIM(Posicione("GYG",1,xFilial("GYG")+cCobrador,"GYG_FUNCIO"))
                                cDesc += " - "+ALLTRIM(Posicione("GYG",1,xFilial("GYG")+cCobrador,"GYG_NOME"))
                                aAdd(aDados,ALLTRIM(cDesc))
                            Else
                                aAdd(aDados,"")
                            Endif

                            aAdd(aDados,(cAlias)->H77_CODH6V)                            
                            PrintRel(@oSection1,aDados) 
                            
                        Endif                         
                        

                    Endif
                             
                    (cAlias2)->(DBCloseArea())
                    
                Endif

                (cAlias)->(DBSkip())
            Enddo

            (cAlias)->(dbCloseArea())
            DaySum(dDataAux,1)
        Next nX        
   
    Endif

    oSection1:Finish()   

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} getRecursos
Retorna lista de escalas sem recurso

@author SIGAGTP | João Paulo Pires
@since 02/01/2026

@type function
/*/
//-----------------------------------------------------------------
Static function getRecursos(cDataIni, cDataFim, cCodLinI, cCodLinF, nTipoRec)

    Local oQuery := Nil
	Local cQuery := ""
    Local cAlias := ""

    cQuery := " SELECT DISTINCT "    
    cQuery +=   " H76.H76_CODIGO, "
    cQuery +=   " H76.H76_DESCRI, "
    cQuery +=   " H77.H77_CODH6V, "
    cQuery += "   H76.H76_QTVEIC, "
    cQuery += "   H76.H76_QTMOTO, "
    cQuery += "   H76.H76_QTCOBR, "
    cQuery +=   " H7F.H7F_DATA,  "
    cQuery += " H73.H73_SEGUND AS SEG, "
    cQuery += " H73.H73_TERCA  AS TER, "
    cQuery += " H73.H73_QUARTA AS QUA, "
    cQuery += " H73.H73_QUINTA AS QUI, "
    cQuery += " H73.H73_SEXTA  AS SEX, "
    cQuery += " H73.H73_SABADO AS SAB, "
    cQuery += " H73.H73_DOMING AS DOM, "
    cQuery +=   " H7F.H7F_CODIGO  "
    cQuery += " FROM " + RetSqlName('H76') + " H76 "

	cQuery += " INNER JOIN " + RetSqlName('H77') + " H77 "
	cQuery +=   " ON (H77.H77_FILIAL = '" + XFilial('H77') + "' "
	cQuery +=       " AND H77.H77_CODH76 = H76.H76_CODIGO "

	If !Empty(cCodLinI) .OR. !Empty(cCodLinF)
	    cQuery +=  " AND H77.H77_CODH6V BETWEEN '" + cCodLinI + "' AND '" + cCodLinF + "' "
	Endif

	cQuery +=       " AND H77.D_E_L_E_T_ = '' )"

    cQuery += " INNER JOIN " + RetSqlName('H71') + " H71 "
	cQuery +=   " ON (H71.H71_FILIAL = '" + XFilial('H71') + "' "
	cQuery +=       " AND H71.H71_CODIGO = H77.H77_CODH71 "
	cQuery +=       " AND H71.H71_STATUS = '1' "
	cQuery +=       " AND H71.D_E_L_E_T_ = '' )"

    cQuery += " INNER JOIN " + RetSqlName('H73') + " H73 "
	cQuery +=   " ON (H73.H73_FILIAL = '" + XFilial('H73') + "' "
	cQuery +=       " AND H73.H73_CODH71 = H71.H71_CODIGO "
    cQuery +=       " AND H73.H73_CODIGO = H77.H77_CODH73 "
	cQuery +=       " AND H73.D_E_L_E_T_ = '' )"

    cQuery += " LEFT JOIN " + RetSqlName('H7F') + " H7F "
    cQuery +=   " ON (H7F.H7F_FILIAL = '" + XFilial('H7F') + "'"
    cQuery +=       " AND H7F.H7F_CODH76 = H76.H76_CODIGO"
    cQuery +=       " AND H7F.H7F_DATA BETWEEN '" + cDataIni + "' AND '" +  cDataFim +"'"
    cQuery +=       " AND H7F.D_E_L_E_T_ = '')"

	cQuery += " WHERE H76.H76_FILIAL = '" + xFilial("H76") + "'"
    cQuery += " AND H76.D_E_L_E_T_ = ''"

    If nTipoRec == 3 
        cQuery += " AND H76.H76_QTCOBR > 0"
    ElseIf nTipoRec == 2 
        cQuery += " AND H76.H76_QTMOTO > 0"
    ElseIf nTipoRec == 1
        cQuery += " AND H76.H76_QTVEIC > 0"
    Else
        cQuery += " AND ( H76.H76_QTCOBR > 0 "
        cQuery += "      OR H76.H76_QTMOTO > 0 "
        cQuery += "      OR H76.H76_QTVEIC > 0 )"
    Endif

    cQuery += "ORDER BY H76.H76_CODIGO "

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)

Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintRel
Realiza a impressão da linha

@author SIGAGTP | João Paulo Pires
@since 13/01/2026

@type function
/*/
//-----------------------------------------------------------------
Static function PrintRel(oSection,aDados)

    oSection:Cell("H7F_DATA"  ):SetValue(DTOC(aDados[1]))        
    oSection:Cell("H76_CODIGO"):SetValue(ALLTRIM(aDados[2]))
    oSection:Cell("H76_DESCRI"):SetValue(ALLTRIM(aDados[3]))
    oSection:Cell("VEICULO"):SetValue(aDados[4])
    oSection:Cell("MOTORISTA"):SetValue(aDados[5])
    oSection:Cell("COBRADOR"):SetValue(aDados[6])    
    oSection:Cell("H77_CODH6V"):SetValue(ALLTRIM(aDados[7]))
    oSection:Cell("H6V_CODLIN"):SetValue(ALLTRIM(Posicione("H6V",1,xFilial("H6V")+aDados[7],"H6V_CODLIN")))                 
    oSection:Printline()

Return 
