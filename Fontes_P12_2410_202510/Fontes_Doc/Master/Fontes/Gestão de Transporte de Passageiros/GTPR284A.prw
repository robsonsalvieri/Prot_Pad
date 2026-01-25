#INCLUDE 'TOTVS.CH'
#INCLUDE 'GTPR284A.CH'

/*/{Protheus.doc} GTPR284A
      Relatório de requisições com lote e fator aglutinador
      @type  Function
      @author João Pires
      @since 18/09/2024
      @version 1.0
/*/
Function GTPR284A()

Local oReport     := Nil

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

       If Pergunte("GTPR284A", .T.)
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
      @since 18/09/2024
      @version 1.0
      @return Object, Objeto Report
/*/
Static Function ReportDef()
      Local oReport

      //---------------------------------------
      // Criação do componente de impressão
      //---------------------------------------
      oReport := TReport():New("GTPR284A", STR0001, "GTPR284A", {|oReport| ReportPrint(oReport)}, "" ) // "Requisições por lote/aglutinador"
      oReport:SetTotalInLine(.F.)
      oReport:SetLandscape( )
      
      //Lotes
      oSection := TRSection():New(oReport, STR0002, "GQY", /*{Array com as ordens do relatório}*/, .F., .T.)  //"Lotes de Requisições"
      oSection:SetTotalInLine(.F.)
      
      TRCell():New(oSection, "GQY_CODIGO", "GQY", STR0003, X3Picture("GQY_CODIGO"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Lote"
      TRCell():New(oSection, "GQY_DESCRI", "GQY", STR0004, X3Picture("GQY_DESCRI"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Descrição"
      TRCell():New(oSection, "GQY_CODCLI", "GQY", STR0005, X3Picture("GQY_CODCLI"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Cliente"
      TRCell():New(oSection, "GQY_NOMCLI", "GQY", STR0006, X3Picture("GQY_NOMCLI"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Nome"
      TRCell():New(oSection, "GQY_DTEMIS", "GQY", STR0007, X3Picture("GQY_DTEMIS"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Emissão"
      TRCell():New(oSection, "GQY_DTFECH", "GQY", STR0008, X3Picture("GQY_DTFECH"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Fechamento"
      TRCell():New(oSection, "GQY_STATUS", "GQY", STR0009, X3Picture("GQY_STATUS"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Status"
      TRCell():New(oSection, "GQY_TOTAL" , "GQY", STR0010, X3Picture("GQY_TOTAL") ,,,,'CENTER',.F.,'CENTER',,,.T.) // "Total"
      TRCell():New(oSection, "GQY_TOTDES", "GQY", STR0026, X3Picture("GQY_TOTDES"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Desconto"
      TRCell():New(oSection, "GQY_TOTALL" ,"GQY", STR0027, X3Picture("GQY_TOTAL") ,,,,'CENTER',.F.,'CENTER',,,.T.) // "Liquido"

      TRFunction():New(oSection:Cell("GQY_TOTALL") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)

      oSection:SetTotalInLine(.F.) 

      oSection:Cell("GQY_CODIGO"):lHeaderSize := .F.
      oSection:Cell("GQY_CODCLI"):lHeaderSize := .F.
      oSection:Cell("GQY_DTEMIS"):lHeaderSize := .F.
      oSection:Cell("GQY_DTFECH"):lHeaderSize := .F.
      oSection:Cell("GQY_STATUS"):lHeaderSize := .F.
      oSection:Cell("GQY_TOTAL"):lHeaderSize := .F.

      //Requisições
      oSection2 := TRSection():New(oReport, STR0011, "GQW", /*{Array com as ordens do relatório}*/, .F., .T.)  //"Requisições"
      oSection2:SetTotalInLine(.F.)
      oSection2:SetLeftMargin(5) 

      TRCell():New(oSection2, "GQW_CODIGO", "GQW", STR0011, X3Picture("GQW_CODIGO"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Requisição"
      TRCell():New(oSection2, "GQW_CODH7A", "GQW", STR0025, X3Picture("GQW_CODH7A"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Aglutinador"
      TRCell():New(oSection2, "GQW_CODORI", "GQW", STR0012, X3Picture("GQW_CODORI"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Cod. Origem"
      TRCell():New(oSection2, "GQW_REQDES", "GQW", STR0004, X3Picture("GQW_REQDES"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Descrição"
      TRCell():New(oSection2, "GQW_CODAGE", "GQW", STR0013, X3Picture("GQW_CODAGE"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Agência"
      TRCell():New(oSection2, "GQW_TOTAL" , "GQW", STR0010, X3Picture("GQW_TOTAL") ,,,,'CENTER',.F.,'CENTER',,,.T.) // "Total"
      TRCell():New(oSection2, "GQW_TOTDES" ,"GQW", STR0026, X3Picture("GQW_TOTDES") ,,,,'CENTER',.F.,'CENTER',,,.T.) // "Desconto"
 
      //Bilhetes
      oSection3 := TRSection():New(oReport, STR0015, "GIC", /*{Array com as ordens do relatório}*/, .F., .T.)  //"Bilhetes"
      oSection3:SetTotalInLine(.F.)

      TRCell():New(oSection3, "GIC_LINHA" , "GIC", STR0017, X3Picture("GIC_LINHA") ,,,,'LEFT'  ,.F.,'LEFT'  ,,,.T.) // "Linha"
      TRCell():New(oSection3, "GIC_BILHET", "GIC", STR0016, X3Picture("GIC_BILHET"),,,,'LEFT'  ,.F.,'LEFT'  ,,,.T.) // "Bilhete"      
      TRCell():New(oSection3, "GIC_DTVIAG", "GIC", STR0028, X3Picture("GIC_DTVIAG"),,,,'LEFT'  ,.F.,'LEFT'  ,,,.T.) // "Data"      
      TRCell():New(oSection3, "GIC_NLOCOR", "GIC", STR0018, X3Picture("GIC_NLOCOR"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Origem"
      TRCell():New(oSection3, "GIC_NLOCDE", "GIC", STR0019, X3Picture("GIC_NLOCDE"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Destino"
      TRCell():New(oSection3, "GIC_TAR"   , "GIC", STR0020, X3Picture("GIC_TAR")   ,,,,'CENTER',.F.,'CENTER',,,.T.) // "Tarifa"
      TRCell():New(oSection3, "GIC_TAX"   , "GIC", STR0021, X3Picture("GIC_TAX")   ,,,,'CENTER',.F.,'CENTER',,,.T.) // "Tx. Embarque"
      TRCell():New(oSection3, "GIC_PED"   , "GIC", STR0022, X3Picture("GIC_PED")   ,,,,'CENTER',.F.,'CENTER',,,.T.) // "Pedágio"
      TRCell():New(oSection3, "GIC_VALTOT", "GIC", STR0010, X3Picture("GIC_VALTOT"),,,,'CENTER',.F.,'CENTER',,,.T.) // "Total"
      
      oSection3:Cell("GIC_LINHA"):lHeaderSize := .F.
      oSection3:Cell("GIC_DTVIAG"):lHeaderSize := .F.

Return oReport
 
/*/{Protheus.doc} ReportPrint
      ReportPrint()
      @type  Function
      @author João Pires
      @since 18/09/2024
      @version 1.0
/*/
Static Function ReportPrint(oReport)      
      Local oSection  := oReport:Section(1)
      Local oSection2 := oReport:Section(2)
      Local oSection3 := oReport:Section(3)
      Local cAliasGQY := ""
      Local cAliasGQW := ""
      Local cAliasGIC := ""
      Local cQuery    := ""
	Local oQuery    := Nil
      Local cParam1   := cValToChar(MV_PAR01) // Cliente de?
      Local cParam2   := cValToChar(MV_PAR02) // Cliente até?
      Local cParam3   := DTOS(MV_PAR03) // Emissão de?
      Local cParam4   := DTOS(MV_PAR04) // Emissão até?
      Local cParam5   := DTOS(MV_PAR05) // Fechamento de?
      Local cParam6   := DTOS(MV_PAR06) // Fechamento até?
      Local cParam7   := cValToChar(MV_PAR07) // Aglut. de?
      Local cParam8   := cValToChar(MV_PAR08) // Aglut. ate?
      Local cParam9   := cValToChar(MV_PAR09) // Status?

      //---------------------------------------
      // Query do relatório da secao 1
      //---------------------------------------
      cQuery :=   " SELECT GQY.GQY_CODIGO, GQY.GQY_DESCRI, GQY.GQY_CODCLI, GQY.GQY_DTEMIS, "+;
                  "       GQY.GQY_DTFECH, GQY.GQY_STATUS, GQY.GQY_TOTAL, GQY.GQY_TOTDES, SA1.A1_NOME "+;
                  " FROM ? GQY INNER JOIN ? SA1 ON SA1.A1_COD = GQY.GQY_CODCLI "+;
                  " AND SA1.A1_LOJA = GQY.GQY_CODLOJ "+;
                  " AND SA1.A1_FILIAL = ? "+;
                  " WHERE GQY.GQY_FILIAL = ? "+;
              	" AND GQY.D_E_L_E_T_ = ' '            "+;
                  " AND GQY.GQY_CODCLI BETWEEN ? AND ? "+;
                  " AND GQY.GQY_DTEMIS BETWEEN ? AND ? "+;
                  " AND GQY.GQY_DTFECH BETWEEN ? AND ? "+;
                  " AND GQY.GQY_CODH7A BETWEEN ? AND ? "
      IF cParam9 <> '3'
            cQuery += " AND GQY.GQY_STATUS = ? "
      ENDIF

      cQuery := ChangeQuery(cQuery)
      oQuery := FWPreparedStatement():New(cQuery)
	oQuery:SetUnsafe(1, RetSqlName("GQY"))
      oQuery:SetUnsafe(2, RetSqlName("SA1"))
      oQuery:SetString(3, xFilial("SA1"))
      oQuery:SetString(4, xFilial("GQY"))
      oQuery:SetString(5, cParam1)
      oQuery:SetString(6, cParam2)
      oQuery:SetString(7, cParam3)
      oQuery:SetString(8, cParam4)
      oQuery:SetString(9, cParam5)
      oQuery:SetString(10, cParam6)
      oQuery:SetString(11, cParam7)
      oQuery:SetString(12, cParam8)
      IF cParam9 <> '3'
            oQuery:SetString(13, cParam9)
      ENDIF
      
	cQuery    := oQuery:GetFixQuery()
	cAliasGQY := MPSysOpenQuery( cQuery )

      oReport:SetMeter((cAliasGQY)->(LastRec()))

      WHILE (cAliasGQY)->(!EOF())
            oReport:SkipLine(1)
            oSection:init()
            oReport:IncMeter()
            IncProc(STR0024) //"Imprimindo..."

            oSection:Cell("GQY_CODIGO"):SetValue(ALLTRIM((cAliasGQY)->GQY_CODIGO))
            oSection:Cell("GQY_DESCRI"):SetValue(ALLTRIM((cAliasGQY)->GQY_DESCRI))
            oSection:Cell("GQY_CODCLI"):SetValue(ALLTRIM((cAliasGQY)->GQY_CODCLI))
            oSection:Cell("GQY_NOMCLI"):SetValue(ALLTRIM((cAliasGQY)->A1_NOME))
            oSection:Cell("GQY_DTEMIS"):SetValue(DTOC(STOD(ALLTRIM((cAliasGQY)->GQY_DTEMIS))))
            oSection:Cell("GQY_DTFECH"):SetValue(DTOC(STOD(ALLTRIM((cAliasGQY)->GQY_DTFECH))))
            oSection:Cell("GQY_TOTAL"):SetValue((cAliasGQY)->GQY_TOTAL)
            oSection:Cell("GQY_TOTDES"):SetValue((cAliasGQY)->GQY_TOTDES)
            oSection:Cell("GQY_TOTALL"):SetValue((cAliasGQY)->GQY_TOTAL-(cAliasGQY)->GQY_TOTDES)
            oSection:Cell("GQY_STATUS"):SetValue(IIF((cAliasGQY)->GQY_STATUS == '2','Baixada','Aberto'))

            oSection:Printline()

            //---------------------------------------
            // Query do relatório da secao 2
            //---------------------------------------
            cQuery := " SELECT GQW_CODIGO, GQW_CODH7A, GQW_CODORI, GQW_REQDES, GQW_CODAGE, GQW_TOTAL,GQW_TOTDES FROM ? GQW  "+;
                      " WHERE GQW.D_E_L_E_T_ = ' '  "+;
                      " AND GQW_FILIAL = ? "+;
                      " AND GQW_CODLOT = ? "

            cQuery := ChangeQuery(cQuery)
            oQuery := FWPreparedStatement():New(cQuery)
            oQuery:SetUnsafe(1, RetSqlName("GQW"))
            oQuery:SetString(2, xFilial("GQW"))
            oQuery:SetString(3, (cAliasGQY)->GQY_CODIGO)
            cQuery    := oQuery:GetFixQuery()
            cAliasGQW := MPSysOpenQuery( cQuery )

            WHILE (cAliasGQW)->(!Eof())
                  oReport:SkipLine(1)
                  oSection2:init()
                  oSection2:Cell("GQW_CODIGO"):SetValue(ALLTRIM((cAliasGQW)->GQW_CODIGO))
                  oSection2:Cell("GQW_CODH7A"):SetValue(ALLTRIM((cAliasGQW)->GQW_CODH7A))
                  oSection2:Cell("GQW_CODORI"):SetValue(ALLTRIM((cAliasGQW)->GQW_CODORI))
                  oSection2:Cell("GQW_REQDES"):SetValue(ALLTRIM((cAliasGQW)->GQW_REQDES))
                  oSection2:Cell("GQW_CODAGE"):SetValue(ALLTRIM((cAliasGQW)->GQW_CODAGE))
                  oSection2:Cell("GQW_TOTAL"):SetValue((cAliasGQW)->GQW_TOTAL)
                  oSection2:Cell("GQW_TOTDES"):SetValue((cAliasGQW)->GQW_TOTDES)
                  oSection2:Printline()
                  oSection2:Finish()

                  //---------------------------------------
                  // Query do relatório da secao 3
                  //---------------------------------------
                  cQuery := " SELECT GIC_CODIGO, GIC_DTVIAG, GIC_BILHET,GIC_LINHA, GIC_LOCORI, GIC_LOCDES, GIC_TAR, GIC_TAX, GIC_PED, GIC_VALTOT FROM ? GIC "+;
                            " WHERE GIC.D_E_L_E_T_ = ' '  "+;
                            " AND GIC.GIC_FILIAL = ? "+;
                            " AND GIC.GIC_CODREQ = ? "

                  cQuery := ChangeQuery(cQuery)
                  oQuery := FWPreparedStatement():New(cQuery)
                  oQuery:SetUnsafe(1, RetSqlName("GIC"))
                  oQuery:SetString(2, xFilial("GIC"))
                  oQuery:SetString(3, (cAliasGQW)->GQW_CODIGO)
                  cQuery    := oQuery:GetFixQuery()
                  cAliasGIC := MPSysOpenQuery( cQuery )
                  
                  IF (cAliasGIC)->(!EoF())
                        oReport:SkipLine(1)
                        oSection3:init()
                  ENDIF

                  WHILE (cAliasGIC)->(!EoF())                          
                        oSection3:Cell("GIC_BILHET"):SetValue(ALLTRIM((cAliasGIC)->GIC_BILHET))
                        oSection3:Cell("GIC_DTVIAG"):SetValue(DTOC(STOD(ALLTRIM((cAliasGIC)->GIC_DTVIAG))))
                        oSection3:Cell("GIC_LINHA"):SetValue(ALLTRIM((cAliasGIC)->GIC_LINHA))
                        oSection3:Cell("GIC_NLOCOR"):SetValue(ALLTRIM(POSICIONE('GI1',1,XFILIAL('GI1')+(cAliasGIC)->GIC_LOCORI,'GI1_DESCRI')))
                        oSection3:Cell("GIC_NLOCDE"):SetValue(ALLTRIM(POSICIONE('GI1',1,XFILIAL('GI1')+(cAliasGIC)->GIC_LOCDES,'GI1_DESCRI')))
                        oSection3:Cell("GIC_TAR"):SetValue((cAliasGIC)->GIC_TAR)
                        oSection3:Cell("GIC_TAX"):SetValue((cAliasGIC)->GIC_TAX)
                        oSection3:Cell("GIC_PED"):SetValue((cAliasGIC)->GIC_PED)
                        oSection3:Cell("GIC_VALTOT"):SetValue((cAliasGIC)->GIC_VALTOT) 
                        oSection3:Printline()                        

                        (cAliasGIC)->(DBSkip())
                        IF (cAliasGIC)->(EoF())
                              oSection3:Finish()
                              oReport:FatLine( )
                        ENDIF
                  ENDDO
                  (cAliasGIC)->(DBCloseArea())

                  (cAliasGQW)->(DBSkip())
            ENDDO
            (cAliasGQW)->(DBCloseArea())
            

            oSection:Finish()
            oReport:EndPage()
            (cAliasGQY)->(DBSkip())

            IF (cAliasGQY)->(!Eof())
                  oReport:StartPage()
            ENDIF
      ENDDO

     (cAliasGQY)->(DBCloseArea())
Return
