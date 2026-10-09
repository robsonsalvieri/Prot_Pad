#INCLUDE 'TOTVS.CH'
#INCLUDE 'GTPR015.CH'

Static nTotal  := 0 
Static lTblH81 := AliasInDic('H81')
/*/{Protheus.doc} GTPR015
      Relatorio de fechamento de caixa (Urbano)
      @type  Function
      @author João Pires
      @since 01/10/2024
      @version 1.0
/*/
Function GTPR015()

Local oReport     := Nil

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

       If Pergunte("GTPR015A", .T.)
            // Interface de impressao
            oReport := ReportDef()
            oReport:PrintDialog()
      EndIf

EndIf

Return()

/*/{Protheus.doc} ReportDef
      ReportDef()
      @type  Function
      @author João Pires
      @since 01/10/2024
      @version 1.0
      @return Object, Objeto Report
/*/
Static Function ReportDef()
      Local oReport
      Local lNewCpos := H7P->(FieldPos('H7P_DEPOSI')) > 0      

      //---------------------------------------
      // Criação do componente de impressão
      //---------------------------------------
      oReport := TReport():New("GTPR015", STR0001, "GTPR015A", {|oReport| ReportPrint(oReport,lNewCpos)}, "" , .F. ) // "Relatorio de fechamento de caixa"
      oReport:SetPortrait()      
      oReport:SetTotalInLine(.F.)
          
      //Fechamento
      oSection := TRSection():New(oReport, STR0002, "H7P",, .F., .T.)  //"Fechamento"
      oSection:SetTotalInLine(.F.)
     
      TRCell():New(oSection, "H7P_STATUS", "H7P", STR0018,                        ,10,,,'LEFT' ,.F.,'LEFT'  ,,05, .T.) // "Status"   
      TRCell():New(oSection, "H7P_CODIGO", "H7P", STR0003, X3Picture("H7P_CODIGO"),09,,,'LEFT' ,.F.,'LEFT'  ,,05, .T.) // "Caixa"
      TRCell():New(oSection, "H7M_DESC"  , "H7M", STR0004, X3Picture("H7M_DESC"  ),21,,,'LEFT' ,.F.,'LEFT'  ,,05, .T.) // "Local"
      TRCell():New(oSection, "H7P_DTFECH", "H7P", STR0002, X3Picture("H7P_DTFECH"),11,,,'LEFT' ,.F.,'LEFT'  ,,05, .T.) // "Fechamento"
      TRCell():New(oSection, "H7P_TOTREC", "H7P", STR0006, X3Picture("H7P_TOTREC"),11,,,'RIGHT',.F.,'CENTER',,05, .T.) // "Total Receita"
      TRCell():New(oSection, "H7P_TOTDES", "H7P", STR0007, X3Picture("H7P_TOTDES"),11,,,'RIGHT',.F.,'CENTER',,05, .T.) // "Total Despesa"
      If lNewCpos
        TRCell():New(oSection, "H7P_DEPOSI", "H7P", "Tot. Dep. Lanc", X3Picture("H7P_DEPOSI"),11,,,'RIGHT',.F.,'CENTER',,05, .T.) // "Tot. Dep. Lanc"
        TRCell():New(oSection, "H7P_TOTEST", "H7P", "Tot. Dep. Esto", X3Picture("H7P_TOTEST"),11,,,'RIGHT',.F.,'CENTER',,05, .T.) // "Tot. Dep. Esto"
        oSection:Cell("H7P_DEPOSI"):lHeaderSize := .F.
      EndIf   
      TRCell():New(oSection, "H7P_SLDANT", "H7P", STR0008, X3Picture("H7P_SLDANT"),15,,,'RIGHT',.F.,'CENTER',,05, .T.) // "Saldo anterior"
      TRCell():New(oSection, "H7P_SLDATU", "H7P", STR0009, X3Picture("H7P_SLDATU"),11,,,'RIGHT',.F.,'CENTER',,05, .T.) // "Saldo Atual"

      oSection:Cell("H7P_DTFECH"):lHeaderSize := .F.
      oSection:Cell("H7P_TOTREC"):lHeaderSize := .F.
      oSection:Cell("H7P_TOTDES"):lHeaderSize := .F.
      oSection:Cell("H7P_SLDANT"):lHeaderSize := .F.

      TRFunction():New(oSection:Cell("H7P_TOTREC") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
      TRFunction():New(oSection:Cell("H7P_TOTDES") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
      If lNewCpos
        TRFunction():New(oSection:Cell("H7P_DEPOSI") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
        TRFunction():New(oSection:Cell("H7P_TOTEST") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
      EndIf 
      TRFunction():New(oSection:Cell("H7P_SLDATU") ,,"ONPRINT",,/*cTitle*/,/*cPicture*/,{|| nTotal }/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

      oSection:SetTotalInLine(.F.) 

      //Receitas e despesas
      oSection2 := TRSection():New(oReport, STR0011, "H7Q",, .F., .T.)  //"Receitas e despesas"
      oSection2:SetTotalInLine(.F.)
      oSection2:SetLeftMargin(5) 

      TRCell():New(oSection2, "H7Q_CODH7O", "H7Q", STR0012, X3Picture("H7Q_CODH7O"),10 ,,,'LEFT'  ,.F.,'LEFT'  ,,05) // "Código"
      TRCell():New(oSection2, "H7O_DESCRI", "H7O", STR0013, X3Picture("H7O_DESCRI"),30 ,,,'LEFT'  ,.F.,'LEFT'  ,,22) // "Descrição"
      TRCell():New(oSection2, "H7Q_TIPO"  , "H7Q", STR0014,                        ,10 ,,,'LEFT'  ,.F.,'LEFT'  ,,05) // "Tipo"
      TRCell():New(oSection2, "H7Q_VALREC", "H7Q", STR0015, X3Picture("H7Q_VALOR") ,17 ,,,'RIGHT' ,.F.,'RIGHT' ,,06) // "Valor Receita"
      TRCell():New(oSection2, "H7Q_VALDES", "H7Q", STR0024, X3Picture("H7Q_VALOR") ,15 ,,,'RIGHT' ,.F.,'RIGHT' ,,05) // "Valor Despesa"
      TRCell():New(oSection2, 'H7Q_PRETIT', "H7Q", STR0032, X3Picture('H81_PRETIT'),10 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Prefixo'        
      TRCell():New(oSection2, 'H7Q_NUMTIT', "H7Q", STR0033, X3Picture('H81_NUMTIT'),10 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Num. Tit.'        
      TRCell():New(oSection2, 'H7Q_CLIFOR', "H7Q", STR0034,                        ,10 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Cli/For' 
            
      oSection2:Cell("H7Q_TIPO"):lHeaderSize := .F.

      If lTblH81
        oSection3 := TRSection():New(oReport, 'Depósitos', "H81",, .F., .T.)  //'Depósitos'
        oSection3:SetTotalInLine(.F.)
        oSection3:SetLeftMargin(5) 
        
        TRCell():New(oSection3, 'H81_TPDEPO', "H81", STR0014    , X3Picture('H81_TPDEPO'),10 ,,,'LEFT'  ,.F.,'LEFT'  ,,05) // "Tipo"             
        TRCell():New(oSection3, 'H81_IDDEPO', "H81", STR0025    , X3Picture('H81_IDDEPO'),15 ,,,'LEFT'  ,.F.,'LEFT'  ,,05) // "Id. Depósito"        
        TRCell():New(oSection3, 'H81_CODBCO', "H81", STR0026    , X3Picture('H81_CODBCO'),10 ,,,'LEFT'  ,.F.,'LEFT'  ,,05) // "Cód. Banco"        
        TRCell():New(oSection3, 'H81_AGEBCO', "H81", STR0027    , X3Picture('H81_AGEBCO'),10 ,,,'LEFT'  ,.F.,'LEFT'  ,,05) // Ag. Banco"          
        TRCell():New(oSection3, 'H81_CTABCO', "H81", STR0028    , X3Picture('H81_CTABCO'),10 ,,,'LEFT'  ,.F.,'LEFT'  ,,05) // "Cta. Banco"        
        TRCell():New(oSection3, 'H81_VLRDEP', "H81", STR0029    , X3Picture('H81_VLRDEP'),10 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Valor'   
        TRCell():New(oSection3, 'H81_TPMOV' , "H81", STR0030    ,                        ,10 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Tp. Lanc'  
        TRCell():New(oSection3, 'H81_DTDEPO', "H81", STR0031    , X3Picture('H81_DTDEPO'),15 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Data'       
        TRCell():New(oSection3, 'H81_PRETIT', "H81", STR0032    , X3Picture('H81_PRETIT'),10 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Prefixo'        
        TRCell():New(oSection3, 'H81_NUMTIT', "H81", STR0033    , X3Picture('H81_NUMTIT'),10 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Num. Tit.'        
        TRCell():New(oSection3, 'H81_CLIFOR', "H81", STR0034    ,                        ,10 ,,,'RIGHT'  ,.F.,'CENTER',,05) // 'Cli/For'       
        oSection3:Cell('H81_TPDEPO'):lHeaderSize := .F.
        oSection3:Cell('H81_IDDEPO'):lHeaderSize := .F.
        oSection3:Cell('H81_CODBCO'):lHeaderSize := .F.
        oSection3:Cell('H81_AGEBCO'):lHeaderSize := .F. 
        oSection3:Cell('H81_CTABCO'):lHeaderSize := .F.
        oSection3:Cell('H81_VLRDEP'):lHeaderSize := .F.
        oSection3:Cell('H81_TPMOV'):lHeaderSize := .F.
       
      EndIf         

Return oReport
 
/*/{Protheus.doc} ReportPrint
      ReportPrint()
      @type  Function
      @author João Pires
      @since 18/09/2024
      @version 1.0
/*/
Static Function ReportPrint(oReport,lNewCpos)      
    Local oSection  := oReport:Section(1)
    Local oSection2 := oReport:Section(2)
    Local oSection3 := Iif(lTblH81,oReport:Section(3),nil)
    Local cAliasH7P := ""
    Local cAliasH7Q := ""       
    Local cAliasH81 := ""       
    Local cQuery    := ""    
    Local oQuery    := Nil    
    Local cParam1   := DTOS(MV_PAR01)       //Data de?
    Local cParam2   := DTOS(MV_PAR02)       //Data ate?
    Local cParam3   := MV_PAR03             //Local de?
    Local cParam4   := MV_PAR04             //Local ate?
    Local nParam5   := MV_PAR05             //Filtra Status?
    Local cParam6   := cValtoChar(MV_PAR06) //Status?
    Local nParam7   := MV_PAR07             //Tipo?
    Local nVlrDep   := 0
    Local nVlrEst   := 0
    Local aOpcoes   := {}     
    Local aLanc     := {}   
    Local cTipoDep  := ""
    Local cTipoLan  := ""
    Local nPos      := 0

    //---------------------------------------
    // Query do relatório da secao 1
    //---------------------------------------
    cQuery := " SELECT H7P_CODIGO, H7M_DESC, H7P_DTFECH, H7P_STATUS, H7P_TOTREC, H7P_TOTDES, H7P_SLDANT, H7P_SLDATU,H7P_TOTEST " +Iif(lNewCpos,', H7P_DEPOSI','') +; 
              " FROM ? H7P "+;
              "  INNER JOIN ? H7M ON  "+;
              "  H7M.H7M_COD = H7P.H7P_CODH7M "+;
              "  AND H7M_FILIAL = ? "+;
              "  AND H7M.D_E_L_E_T_ = ' ' "+;
              " WHERE  "+;
              " H7P.D_E_L_E_T_ = ' ' "+;
              " AND H7P_FILIAL = ?  AND H7P_DTFECH >= ? AND H7P_DTFECH <= ?  "+;
              " AND H7P_CODH7M >= ? AND H7P_CODH7M <= ?  "              
                      
    IF nParam5 == 2
          cQuery += " AND H7P_STATUS = ? "
    ENDIF

    cQuery := ChangeQuery(cQuery)
    oQuery := FWPreparedStatement():New(cQuery)
    oQuery:SetUnsafe(1, RetSqlName("H7P"))      
    oQuery:SetUnsafe(2, RetSqlName("H7M"))   
    oQuery:SetString(3, xFilial("H7M"))   
    oQuery:SetString(4, xFilial("H7P"))      
    oQuery:SetString(5, cParam1)
    oQuery:SetString(6, cParam2)
    oQuery:SetString(7, cParam3)
    oQuery:SetString(8, cParam4)
    IF nParam5 == 2
      oQuery:SetString(9, cParam6)
    ENDIF
       
	cQuery    := oQuery:GetFixQuery()
	cAliasH7P := MPSysOpenQuery( cQuery )

    oReport:SetMeter((cAliasH7P)->(LastRec()))

    WHILE (cAliasH7P)->(!EOF())
        oSection:init()
        oReport:IncMeter()
        IncProc(STR0010) //"Imprimindo..."

        oSection:Cell("H7P_CODIGO"):SetValue(ALLTRIM((cAliasH7P)->H7P_CODIGO))
        Do Case
            Case (cAliasH7P)->H7P_STATUS == '1'
                oSection:Cell("H7P_STATUS"):SetValue(STR0019) //Aberto
            Case (cAliasH7P)->H7P_STATUS == '2'
                oSection:Cell("H7P_STATUS"):SetValue(STR0020) //Fechado
            Case (cAliasH7P)->H7P_STATUS == '3'
                oSection:Cell("H7P_STATUS"):SetValue(STR0021) //Conferido
            Case (cAliasH7P)->H7P_STATUS == '4'
                oSection:Cell("H7P_STATUS"):SetValue(STR0022) //Reaberto
            Case (cAliasH7P)->H7P_STATUS == '5'
                oSection:Cell("H7P_STATUS"):SetValue(STR0023) //Encerrado
        EndCase
        oSection:Cell("H7M_DESC"  ):SetValue(ALLTRIM((cAliasH7P)->H7M_DESC))
        oSection:Cell("H7P_DTFECH"):SetValue(DTOC(STOD(ALLTRIM((cAliasH7P)->H7P_DTFECH))))
        oSection:Cell("H7P_TOTREC"):SetValue((cAliasH7P)->H7P_TOTREC)
        oSection:Cell("H7P_TOTDES"):SetValue((cAliasH7P)->H7P_TOTDES)
        oSection:Cell("H7P_SLDANT"):SetValue((cAliasH7P)->H7P_SLDANT)
        oSection:Cell("H7P_SLDATU"):SetValue((cAliasH7P)->H7P_SLDATU)
        
        nVlrDep := 0
        nVlrEst := 0
        If lNewCpos
            oSection:Cell("H7P_DEPOSI"):SetValue((cAliasH7P)->H7P_DEPOSI)
            nVlrDep := (cAliasH7P)->H7P_DEPOSI
            oSection:Cell("H7P_TOTEST"):SetValue((cAliasH7P)->H7P_TOTEST)
            nVlrEst := (cAliasH7P)->H7P_TOTEST            

        EndIf 

        nTotal += (cAliasH7P)->H7P_TOTREC - (cAliasH7P)->H7P_TOTDES - nVlrDep + nVlrEst

        oSection:Printline()

        IF nParam7 == 2 //Analítico    

            //---------------------------------------
            // Query do relatório da secao 2
            //---------------------------------------
            cQuery := " SELECT H7Q_CODH7O, H7O_DESCRI, H7Q_TIPO, H7Q_VALOR, H7Q_PRETIT, H7Q_NUMTIT, H7Q_CLIFOR "+;
                      " FROM ? H7Q INNER JOIN ? H7O  "+;
                      " ON H7O.H7O_CODIGO = H7Q.H7Q_CODH7O "+;
                      " AND H7O.H7O_FILIAL = ? "+;
                      " AND H7O.D_E_L_E_T_ = ' ' "+;
                      " WHERE H7Q.D_E_L_E_T_ = ' ' "+;
                      " AND H7Q_FILIAL = ? AND H7Q_CODH7P = ? "+;
                      " ORDER BY H7Q_TIPO "

            cQuery := ChangeQuery(cQuery)
            oQuery := FWPreparedStatement():New(cQuery)
            oQuery:SetUnsafe(1, RetSqlName("H7Q"))
            oQuery:SetUnsafe(2, RetSqlName("H7O"))
            oQuery:SetString(3, xFilial("H7O"))
            oQuery:SetString(4, xFilial("H7Q"))
            oQuery:SetString(5, (cAliasH7P)->H7P_CODIGO)
            cQuery    := oQuery:GetFixQuery()
            cAliasH7Q := MPSysOpenQuery( cQuery )

            IF (cAliasH7Q)->(!Eof())               
                oSection2:init()
            ENDIF

            WHILE (cAliasH7Q)->(!Eof())
                  
                oSection2:Cell("H7Q_CODH7O"):SetValue(ALLTRIM((cAliasH7Q)->H7Q_CODH7O))
                oSection2:Cell("H7O_DESCRI"):SetValue(ALLTRIM((cAliasH7Q)->H7O_DESCRI))
                oSection2:Cell("H7Q_TIPO"  ):SetValue(IIF((cAliasH7Q)->H7Q_TIPO == '1',STR0016, STR0017)) //"Receita"- "Despesa"
                oSection2:Cell("H7Q_VALREC"):SetValue(IIF((cAliasH7Q)->H7Q_TIPO == '1',(cAliasH7Q)->H7Q_VALOR, 0))
                oSection2:Cell("H7Q_VALDES"):SetValue(IIF((cAliasH7Q)->H7Q_TIPO == '2',(cAliasH7Q)->H7Q_VALOR, 0))
                oSection2:Cell("H7Q_PRETIT"):SetValue((cAliasH7Q)->H7Q_PRETIT)
                oSection2:Cell("H7Q_NUMTIT"):SetValue((cAliasH7Q)->H7Q_NUMTIT)
                oSection2:Cell("H7Q_CLIFOR"):SetValue((cAliasH7Q)->H7Q_CLIFOR)
                
                oSection2:Printline()
                
                (cAliasH7Q)->(DBSkip())
                IF (cAliasH7Q)->(EoF())
                    oSection2:Finish()
                ENDIF
            ENDDO
            oReport:SkipLine(1)
            (cAliasH7Q)->(DBCloseArea())

            If lTblH81

                aOpcoes    := RetSx3Box(Posicione("SX3", 2, 'H81_TPDEPO', "X3CBox()"),,, 1)
                aLanc      := RetSx3Box(Posicione("SX3", 2, 'H81_TPMOV', "X3CBox()"),,, 1)
                //---------------------------------------
                // Query do relatório da secao 3 Deposito
                //---------------------------------------
                cQuery := " SELECT H81_TPDEPO, H81_IDDEPO, H81_CODBCO, H81_AGEBCO, H81_CTABCO, H81_VLRDEP, H81_TPMOV , H81_DTDEPO, H81_PRETIT, H81_NUMTIT, H81_CLIFOR"+;
                            " FROM ? H81 INNER JOIN ? H7P  "+;
                            " ON H7P.H7P_CODIGO = H81.H81_CODH7P "+;
                            " AND H7P.H7P_FILIAL = ? "+;
                            " AND H7P.D_E_L_E_T_ = ' ' "+;
                            " WHERE H81.D_E_L_E_T_ = ' ' "+;
                            " AND H81_FILIAL = ? AND H81_CODH7P = ? "+;
                            " ORDER BY H81_CODIGO "

                cQuery := ChangeQuery(cQuery)
                oQuery := FWPreparedStatement():New(cQuery)
                oQuery:SetUnsafe(1, RetSqlName("H81"))
                oQuery:SetUnsafe(2, RetSqlName("H7P"))
                oQuery:SetString(3, xFilial("H7P"))
                oQuery:SetString(4, xFilial("H81"))
                oQuery:SetString(5, (cAliasH7P)->H7P_CODIGO)
                cQuery    := oQuery:GetFixQuery()
                cAliasH81 := MPSysOpenQuery( cQuery )

                IF (cAliasH81)->(!Eof())               
                    oSection3:init()
                ENDIF

                WHILE (cAliasH81)->(!Eof())

                    cTipoDep := ''
                    If (nPos := Ascan( aOpcoes, {|e| e[2] == (cAliasH81)->H81_TPDEPO} )) > 0
			            cTipoDep := Alltrim(aOpcoes[nPos][3])
		            EndIf 

                    cTipoLan := ''
                    If (nPos := Ascan( aLanc, {|e| e[2] == (cAliasH81)->H81_TPMOV} )) > 0
			            cTipoLan := Alltrim(aLanc[nPos][3])
		            EndIf
                    
                    oSection3:Cell("H81_TPDEPO"):SetValue(cTipoDep)
                    oSection3:Cell("H81_IDDEPO"):SetValue((cAliasH81)->H81_IDDEPO)
                    oSection3:Cell("H81_CODBCO"):SetValue((cAliasH81)->H81_CODBCO)
                    oSection3:Cell("H81_AGEBCO"):SetValue((cAliasH81)->H81_AGEBCO)
                    oSection3:Cell("H81_CTABCO"):SetValue((cAliasH81)->H81_CTABCO)
                    oSection3:Cell("H81_VLRDEP"):SetValue((cAliasH81)->H81_VLRDEP)
                    oSection3:Cell("H81_TPMOV"):SetValue(cTipoLan)
                    oSection3:Cell("H81_DTDEPO"):SetValue(DTOC(STOD((cAliasH81)->H81_DTDEPO)))
                    oSection3:Cell("H81_PRETIT"):SetValue((cAliasH81)->H81_PRETIT)
                    oSection3:Cell("H81_NUMTIT"):SetValue((cAliasH81)->H81_NUMTIT)
                    oSection3:Cell("H81_CLIFOR"):SetValue((cAliasH81)->H81_CLIFOR)
                    oSection3:Printline()
                    
                    (cAliasH81)->(DBSkip())
                    IF (cAliasH81)->(EoF())
                        oSection3:Finish()
                    ENDIF
                ENDDO

            EndIf 
            oReport:SkipLine(1)
            (cAliasH81)->(DBCloseArea())
          
        ENDIF
            
        (cAliasH7P)->(DBSkip())

        IF (cAliasH7P)->(!Eof()) .AND. nParam7 == 2
            oSection:PrintHeader()
        ENDIF

    ENDDO

    (cAliasH7P)->(DBCloseArea())
Return
