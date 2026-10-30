#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPR011A.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR011A
Relatorio de folga diária (Urbano)

@author SIGAGTP | João Paulo Pires
@since 02/01/2026

@type function
/*/
//-------------------------------------------------------------------
Function GTPR011A()
    Local oReport := nil

    oReport := RPTStruct()
    oReport:PrintDialog()
   

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptStruc
Define estrutura de campos

@author SIGAGTP | João Paulo Pires
@since 02/01/2026

@type function
/*/
//-------------------------------------------------------------------
Static Function RPTStruct()
    Local oReport   := nil
    Local oSection1 := nil
    Local cPerg     := "GTPR011A"

    Pergunte(cPerg,.T.)

    oReport := TReport():New("GTPR011A",STR0001,cPerg,{|oReport|RPTPrint(oReport)},STR0002) //"Relatório folga diária" - "Rel. de folgas diária (urbano)"
    oReport:SetLandscape(.T.)

    oSection1 := TRSection():New(oReport, STR0003,{"H7R"}, NIL,.F.,.T.) //"Registro"
    oSection1:SetHeaderSection(.T.)
    TRCell():New(oSection1,"H7R_DATA"     ,"H7R",  STR0004 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Data"   
    TRCell():New(oSection1,"GYG_RECCOD"   ,"GYG",  STR0005 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Tp Colab."
    TRCell():New(oSection1,"GYG_FUNCIO"   ,"GYG",  STR0006 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Cod. Colab."
    TRCell():New(oSection1,"GYG_NOME"     ,"GYG",  STR0007 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Colaborador"
    TRCell():New(oSection1,"TURNO"        ,"H77",  STR0008 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Turno"
    TRCell():New(oSection1,"H6V_CODLIN"   ,"H6V",  STR0009 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Linha"
    TRCell():New(oSection1,"H84_DESCRI"   ,"H84",  STR0010 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Motivo

Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} RPTPrint
Realiza impressão do relatório

@author SIGAGTP | João Paulo Pires
@since 02/01/2026

@type function
/*/
//-------------------------------------------------------------------    
Static Function RPTPrint(oReport)
    Local oSection1  := oReport:Section(1)    
    Local oQuery     := Nil
	Local cQuery     := ""
    Local cQuebra    := ""
    Local cDtIni     := DtoS(MV_PAR01)
    Local cDtFim     := DtoS(MV_PAR02)
    Local cTpExc     := ALLTRIM(MV_PAR03)


    cQuery := " SELECT DISTINCT H7R.H7R_DATA, "
    cQuery += "                 GYG.GYG_FUNCIO, "
    cQuery += "                 GYG_RECCOD, "
    cQuery += "                 GYG.GYG_NOME, "
    cQuery += "                 CASE "
    cQuery += "                     WHEN H77.H77_HRINIC BETWEEN '00:00' AND '11:59' THEN 'MANHA' "
    cQuery += "                     WHEN H77.H77_HRINIC BETWEEN '12:00' AND '18:59' THEN 'TARDE' "
    cQuery += "                     WHEN H77.H77_HRINIC BETWEEN '19:00' AND '23:59' THEN 'NOITE' "
    cQuery += "                 END AS TURNO, "
    cQuery += "                 H6V.H6V_CODLIN, "
    cQuery += "                 H84.H84_DESCRI  "
    cQuery += " FROM  " + RetSqlName('H7R') + " H7R "
    cQuery += " INNER JOIN " + RetSqlName('GYG') + " GYG "
    cQuery += "             ON H7R.H7R_COLAB = GYG.GYG_CODIGO "
    cQuery += "                 AND GYG.GYG_FILIAL = '" + xFilial('GYG') + "' "
    cQuery += "                 AND GYG.D_E_L_E_T_ = '' "
    cQuery += "     LEFT JOIN " + RetSqlName('H76') + " H76 "
    cQuery += "             ON (  H7R.H7R_COLAB = H76.H76_CODMOT  "
    cQuery += "                     OR H7R.H7R_COLAB = H76.H76_CODCOB   ) "
    cQuery += "                 AND H7R.H7R_FILIAL = H76.H76_FILIAL "
    cQuery += "                 AND H76.D_E_L_E_T_ = ''        "
    cQuery += "     LEFT JOIN " + RetSqlName('H77') + " H77 "
    cQuery += "             ON H76.H76_FILIAL = H77.H77_FILIAL "
    cQuery += "                 AND H76.H76_CODIGO = H77.H77_CODH76 "
    cQuery += "                 AND H77.D_E_L_E_T_ = '' "
    cQuery += "     LEFT JOIN " + RetSqlName('H6V') + " H6V "
    cQuery += "             ON H77.H77_FILIAL = H6V.H6V_FILIAL "
    cQuery += "                 AND H77.H77_CODH6V = H6V.H6V_CODIGO "
    cQuery += "                 AND H6V.D_E_L_E_T_ = '' "
    cQuery += "     LEFT JOIN " + RetSqlName('H84') + " H84 "
    cQuery += "             ON H7R.H7R_FILIAL = H84.H84_FILIAL "
    cQuery += "                 AND H7R.H7R_CODH84 = H84.H84_CODIGO "
    cQuery += "                 AND H84.D_E_L_E_T_ = '' "
    cQuery += " WHERE  H7R.H7R_FILIAL = '" + xFilial('H7R') + "' "
    cQuery += "     AND GYG.GYG_URBANO = 'T' "
    cQuery += "     AND H7R.H7R_DATA BETWEEN '" + cDtIni + "' AND '" + cDtFim + "'  "
    if !Empty(cTpExc)
        cQuery += "     AND H7R.H7R_CODH84 = '" + cTpExc + "'  "
    Endif
    cQuery += "     AND H7R.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY GYG_RECCOD, H7R.H7R_DATA "

    oQuery := FWPreparedStatement():New(cQuery)
	cQuery := oQuery:GetFixQuery()
	cAlias := MPSysOpenQuery(cQuery)
    
    (cAlias)->(dbGotop())

    oReport:SetMeter((cAlias)->(LastRec()))    

    while (cAlias)->(!Eof())
    
        oSection1:Init()
        oReport:IncMeter()

        IncProc(STR0011) //"Imprimindo..."

        cQuebra := ALLTRIM((cAlias)->GYG_RECCOD) 

        While (cAlias)->(!Eof()) .AND. cQuebra == ALLTRIM((cAlias)->GYG_RECCOD) 
        
            oSection1:Cell("H7R_DATA"  ):SetValue(DTOC(STOD(ALLTRIM((cAlias)->H7R_DATA))))                  
            oSection1:Cell("GYG_RECCOD"):SetValue(ALLTRIM(POSICIONE("GYK",1,XFILIAL("GYK")+(cAlias)->GYG_RECCOD,"GYK_DESCRI")))
            oSection1:Cell("GYG_FUNCIO"):SetValue(ALLTRIM((cAlias)->GYG_FUNCIO))
            oSection1:Cell("GYG_NOME"  ):SetValue(ALLTRIM((cAlias)->GYG_NOME))
            oSection1:Cell("TURNO"     ):SetValue(ALLTRIM((cAlias)->TURNO))
            oSection1:Cell("H6V_CODLIN"):SetValue(ALLTRIM((cAlias)->H6V_CODLIN))
            oSection1:Cell("H84_DESCRI"):SetValue(ALLTRIM((cAlias)->H84_DESCRI))
                
            oSection1:Printline()		

            (cAlias)->(DBSkip())
        Enddo 

        oReport:ThinLine()
        oSection1:Finish()                

    enddo    

    (cAlias)->(dbCloseArea())

Return 
