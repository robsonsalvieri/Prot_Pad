#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR119
Relatorio Diario de viagens.

@author SIGAGTP | João Paulo Pires
@since 27/03/2024

@type function
/*/
//-------------------------------------------------------------------
Function GTPR119()
    Local oReport := nil

    oReport := RPTStruct()
    oReport:PrintDialog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptStruc
Define estrutura de campos

@author SIGAGTP | João Paulo Pires
@since 27/03/2024

@type function
/*/
//-------------------------------------------------------------------
Static Function RPTStruct()
    Local oReport   := nil
    Local oSection1 := nil
    Local oSection2 := nil
    Local cPerg     := "GTPR119A"

    Pergunte(cPerg,.F.)

    oReport := TReport():New("GTPT119","Boletim De Viagens",cPerg,{|oReport|RPTPrint(oReport)},"Boletim das viagens finalizadas de fretamento contínuo por contrato")
    oReport:SetLandscape( )

    oSection1 := TRSection():New(oReport, "Viagem",{"GYN"}, NIL,.F.,.T.)
    TRCell():New(oSection1,"GYN_CODIGO","GYN",  "Viagem" ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection1,"GYN_CODGY0","GYN",  "Contrato" ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection1,"GYN_LINCOD","GYN",  "Linha"   ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection1,"GYN_DTINI","GYN",  "Data viagem"   ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection1,"GY0_CLIENT","GY0",  "Cod. Cliente"   ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection1,"A1_NOME","SA1",  "Nome Cliente"   ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection1,"GYN_EXTRA","GYN",  "Viag. Extra"   ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection1,"GYN_KMPROV","GYN",  "KM Prev"   ,"@E 999999.99",,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection1,"GYN_KMREAL", "GYN",  "KM Real"   ,"@E 999999.99",,,,'CENTER',.F.,'CENTER',,,.T.)
    
    oSection2 := TRSection():New(oReport,"Recursos",{"GQE"},nil,.F.,.T.)
    TRCell():New(oSection2,"G55_SEQ",   "G55",  "Rota" ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection2,"GQE_TRECUR","GQE",  "Tp. Recur." ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection2,"GQE_RECURS","GQE",  "Recurso"   ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection2,"GQE_TCOLAB","GQE",  "Tipo colab."   ,,,,,'CENTER',.F.,'CENTER',,,.T.)
    TRCell():New(oSection2,"NOME_REC",  "GQE",  "Nome. Recur."   ,,,,,'CENTER',.F.,'CENTER',,,.T.)
  
    oSection1:SetPagebreack(.F.)
    
    
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} RPTPrint
Realiza impressão do relatório

@author SIGAGTP | João Paulo Pires
@since 27/03/2024

@type function
/*/
//-------------------------------------------------------------------    
Static Function RPTPrint(oReport)
    Local oSection1  := oReport:Section(1)
    Local oSection2  := oReport:Section(2)
    Local cQuery     := ""
    Local cAlias     := GetNextAlias()
    Local cViagem    := ""
    Local cContra    := ""
    Local cRecurs    := ""
    Local cTpCola    := ""
    
    cQuery := " SELECT GYN_CODIGO, GYN_CODGY0, GYN_EXTRA, GYN.GYN_LINCOD, GY0_CLIENT, GYN.GYN_DTINI, GYN.GYN_KMPROV, GYN.GYN_KMREAL, "
    cQuery += " G55.G55_SEQ, GQE.GQE_TRECUR, GQE.GQE_RECURS, GQE.GQE_TCOLAB "
    cQuery += " FROM "+RetSqlName('GYN')+" GYN INNER JOIN "+RetSqlName('G55')+" G55 ON "
    cQuery += " GYN.GYN_FILIAL = G55.G55_FILIAL AND GYN.GYN_CODIGO = G55.G55_CODVIA AND "
    cQuery += " GYN.D_E_L_E_T_ = '' AND G55.D_E_L_E_T_ = '' "
    cQuery += " INNER JOIN "+RetSqlName('GQE')+" GQE ON "
    cQuery += " G55.G55_FILIAL = GQE.GQE_FILIAL AND G55.G55_CODVIA = GQE.GQE_VIACOD AND "
    cQuery += " G55.G55_SEQ = GQE.GQE_SEQ AND GQE.D_E_L_E_T_ = '' "
    cQuery += " INNER JOIN "+RetSqlName('GY0')+" GY0 ON "
    cQuery += " GY0.GY0_FILIAL = GYN.GYN_FILIAL AND "
    cQuery += " GY0.GY0_NUMERO = GYN.GYN_CODGY0 "
    cQuery += " WHERE  "
    cQuery += " GYN_TIPO = '3' AND GYN_CODGY0 <> '' AND  GYN_FINAL = '1' "
    cQuery += " AND GYN_DTINI  BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
    cQuery += " ORDER BY GYN_CODGY0,GYN_LINCOD,G55_SEQ "

    
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
    TCSETFIELD( cAlias,"GYN_DTINI","D")

    (cAlias)->(dbGotop())

    oReport:SetMeter((cAlias)->(LastRec()))

    IF MV_PAR03 == 2 
        oSection1:Init()
    ENDIF

    while (cAlias)->(!Eof())

        IF MV_PAR03 == 1
            oSection1:Init()
        ENDIF
        oReport:IncMeter()

        IncProc("Imprimindo...")
        
        oSection1:Cell("GYN_CODIGO"):SetValue(ALLTRIM((cAlias)->GYN_CODIGO))
        oSection1:Cell("GYN_CODGY0"):SetValue(ALLTRIM((cAlias)->GYN_CODGY0))
        oSection1:Cell("GYN_LINCOD"):SetValue(ALLTRIM((cAlias)->GYN_LINCOD))
        oSection1:Cell("GYN_DTINI"):SetValue((cAlias)->GYN_DTINI)
        oSection1:Cell("GY0_CLIENT"):SetValue(ALLTRIM((cAlias)->GY0_CLIENT))
        oSection1:Cell("A1_NOME"):SetValue(ALLTRIM(GetAdvFVal("SA1","A1_NOME",xFilial("SA1")+(cAlias)->GY0_CLIENT,1,"Erro")))
        IF (cAlias)->GYN_EXTRA == 'T'
            oSection1:Cell("GYN_EXTRA"):SetValue('Sim')
        ELSE
            oSection1:Cell("GYN_EXTRA"):SetValue('Não')
        ENDIF
        oSection1:Cell("GYN_KMPROV"):SetValue((cAlias)->GYN_KMPROV)
        oSection1:Cell("GYN_KMREAL"):SetValue((cAlias)->GYN_KMREAL)
        
        oSection1:Printline()		

        cViagem := (cAlias)->GYN_CODIGO
        cContra := (cAlias)->GYN_CODGY0

        IF MV_PAR03 == 1
            oSection2:Init()

            while (cAlias)->GYN_CODIGO == cViagem
                oReport:IncMeter()            

                oSection2:Cell("G55_SEQ"):SetValue(ALLTRIM((cAlias)->G55_SEQ))            
                            
                IF (cAlias)->GQE_TRECUR == '1'
                    cRecurs := GetAdvFVal("GYG","GYG_NOME",xFilial("GYG")+ALLTRIM((cAlias)->GQE_RECURS),1,"Erro")
                    cTpCola := GetAdvFVal("GYK","GYK_DESCRI",xFilial("GYK")+ALLTRIM((cAlias)->GQE_TCOLAB),1,"Erro")

                    oSection2:Cell("GQE_TRECUR"):SetValue('Colaborador')
                    oSection2:Cell("GQE_TCOLAB"):SetValue(ALLTRIM(cTpCola))
                ELSE
                    cRecurs := GetAdvFVal("ST9","T9_NOME",xFilial("ST9")+ALLTRIM((cAlias)->GQE_RECURS),1,"Erro")
                    oSection2:Cell("GQE_TRECUR"):SetValue('Veículo')
                    oSection2:Cell("GQE_TCOLAB"):SetValue('')
                ENDIF

                oSection2:Cell("GQE_RECURS"):SetValue(ALLTRIM((cAlias)->GQE_RECURS))
                oSection2:Cell("NOME_REC"):SetValue(ALLTRIM(cRecurs))

                oSection2:Printline()

                (cAlias)->(dbskip())
            enddo

            oSection2:Finish()
        ELSE
            WHILE (cAlias)->(!Eof()) .AND. cViagem == (cAlias)->GYN_CODIGO 
                (cAlias)->(dbskip())
            ENDDO
        ENDIF
        
        oReport:ThinLine()
        IF MV_PAR03 == 1
            oSection1:Finish()
        ENDIF

    enddo

    IF MV_PAR03 == 2
        oSection1:Finish()
    ENDIF

    (cAlias)->(dbCloseArea())

Return 
