#include 'Protheus.ch'
#include 'GTPR013.CH'
Static aPerfil := {}
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR013()
Relatório consolidado de prestações de contas

@sample GTPR013()

/author YURI PORTO
@since 10/07/2024
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR013()
    Local oReport
    Local cPerg  := STR0001//'GTPR013'

    If Pergunte(cPerg, .T.)

        oReport := ReportDef(cPerg)
        oReport:PrintDialog()

    Endif

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
Relatório consolidado de prestações de contas

@sample ReportDef(cPerg)
@param cPerg - caracter - Nome da Pergunta
@return oReport - Objeto - Objeto TREPORT

/author Yuri Porto 
@since10/07/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
    Local lSintetico            := IIF(MV_PAR01==2,.T.,.F.)
    Local lPrestacao            := IIF(MV_PAR02==1,.T.,.F.)
    Local cTitle                := STR0002 + IIf(lSintetico, STR0009, STR0008) //"Relatório consolidado de prestações de contas - " //Sintético - Analitico
    Local cTitle2               := STR0003//"Seção Escalas"
    Local cTitulo               := STR0005//"Financeiro - Prestações de contas"
    Local cTotal01              := STR0006 //"Total Geral : 
    Local cTotal02              := IIf(lSintetico, STR0010, STR0012 )//"Total por motorista : " - "Total por prestação : "
    Local cTotal03              := STR0006//"Total Geral : "    
    Local cTitQtd               := IIf(lSintetico, STR0023, " " )
    Local cTitTot               := IIf(lSintetico, STR0024, " " )
    Local oSection1,oSection2,oSection3    
    Local oReport    

    oReport := TReport():New('GTPR013', cTitle, cPerg, {|oReport|ReportPrint(oReport)}, cTitulo, .F. , )
    oReport:SetLandscape()  // Visualiza tipo paisagem  
    oReport:SetTotalInLine(.F.)
 
    oSection1 := TRSection():New(oReport, cTitle, "H7I",,.F.,.T., cTotal01,,, .T.,,,,,,,, 2)
    oSection1:SetTotalInLine(.F.)
    
    TRCell():New(oSection1, "FILIPETA"              , "H7I", STR0013,                     , 20, , , "LEFT"  ,.F.,'LEFT' ,,05,.T.) //"Filipeta"      
    TRCell():New(oSection1, "LOCAL_ARRECADA_DESC"   , "H7I", STR0014,                     , 30, , , "LEFT"  ,.F.,'LEFT' ,,05,.T.) //"Desc Loc Arrec"     
    TRCell():New(oSection1, "DATA"                  , "H7I", STR0015,                     , 20, , , "LEFT"  ,.F.,'LEFT' ,,05,.T.) //"Data Prestação"
    TRCell():New(oSection1, "DATA_CONFERENCIA"      , "H7I", STR0029,                     , 20, , , "LEFT"  ,.F.,'LEFT' ,,05,.T.) //'Data conferencia'
    TRCell():New(oSection1, "DATA_SERVICO"          , "H7I", FWX3Titulo('H7I_DTSERV'),    , 20, , , "LEFT"  ,.F.,'LEFT' ,,05,.T.) //'Data Serviço'
    TRCell():New(oSection1, "NOME_CONFERENTE"       , "H7I", STR0016,                     , 15, , , "LEFT"  ,.F.,'LEFT' ,,05,.T.) //"Conferente"  
    TRCell():New(oSection1, "NOME_INCLUIU"          , "H7I", STR0042,                     , 15, , , "LEFT"  ,.F.,'LEFT' ,,05,.T.) //"Conferente"    
    TRCell():New(oSection1, "STATUS"                , "H7I", STR0041,                     , 15, , , "LEFT"  ,.F.,'LEFT' ,,05,.T.) //"Status"    
    TRCell():New(oSection1, "NOME_COLABORADOR"      , "H7I", STR0017,                     , 70, , , "LEFT"  ,.F.,'LEFT' ,,13,.T.) //"Colaborador"
    TRCell():New(oSection1, "QUANTIDADE_PASSAGEIROS", "H7I", cTitQtd, "99999"             , 20, , , "RIGHT" ,.F.,'RIGHT',,05,.T.) //"Qtd Passag"  
    TRCell():New(oSection1, "VALOR_TOTAL"           , "H7I", cTitTot, "@E 999,999,999.99" , 15, , , "RIGHT" ,.F.,'RIGHT',,05,.T.) //"Val Total"

    If !lSintetico 

        oSection1:Cell("QUANTIDADE_PASSAGEIROS"):Hide()
        oSection1:Cell("VALOR_TOTAL"):Hide()

        oSection2 := TRSection():New(oReport, cTitle2, "H7J",,.F.,.T., cTotal02,,, .F.,,,,,,,, 2)
        oSection2:SetTotalInLine(.F.)
        oSection2:SetLeftMargin(1) 

        oSection3 := TRSection():New(oReport, cTitle2, "H7J",,.F.,.T., cTotal03,,, .F.)
        oSection3:SetTotalInLine(.F.)
        oSection3:SetLeftMargin(90) 

        //DADOS SERVIÇO
        If lPrestacao

            TRCell():New(oSection2, "SERVICO"               , "H7J", STR0030,                    , 15, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Serviço"
            TRCell():New(oSection2, "DATA_INICIO_SERV"      , "H7J", STR0031,                    , 15, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Data Ini Serv"
            TRCell():New(oSection2, "DATA_TERMINO_SERV"     , "H7J", STR0032,                    , 15, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Data Term Serv"
            TRCell():New(oSection2, "PREFIXO"               , "H7J", STR0034,                    , 15, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Prefixo"
            TRCell():New(oSection2, "LINHA"                 , "H7J", STR0019,                    , 10, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Linha"
            TRCell():New(oSection2, "DESC_LINHA"            , "H7J", STR0033,                    , 45, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Desc Linha"            
            TRCell():New(oSection2, "VEICULO"               , "H7J", STR0020,                    , 45, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //Veiculo
            TRCell():New(oSection2, "TURNO"                 , "H7J", STR0021,                    , 10 , , , "LEFT" ,.F.,'LEFT'  ,,05,.T.) //"Turno"
            TRCell():New(oSection2, "TOTAL_VIAGENS"          , "H7J", FWX3Titulo("H7J_TOTVIA"), "99999"            , 20, , , "RIGHT" ,.F.,'RIGHT' ,,05,.T.) //"Total Viagem"
            TRCell():New(oSection2, "QUANTIDADE_PASSAGEIROS", "H7J", STR0023, "99999"            , 20, , , "RIGHT" ,.F.,'RIGHT' ,,05,.T.) //"Qtd Passag"
            TRCell():New(oSection2, "VALOR_TOTAL"           , "H7J", STR0024, "@E 999,999,999.99", 15, , , "RIGHT" ,.F.,'RIGHT' ,,05,.T.) //"Val Total"

            TRCell():New(oSection3, "TIPO_PAGAMENTO"        , "H7L", STR0022,                    , 20, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Tp Pagamento"
            TRCell():New(oSection3, "DESC_TIPO_PAGA"        , "H7L", STR0037,                    , 90, , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Desc Tp Pag"
            TRCell():New(oSection3, "QUANTIDADE_PASSAGEIROS", "H7L", STR0023, "99999"            , 20, , , "RIGHT" ,.F.,'RIGHT' ,,05,.T.) //"Qtd Passag"
            TRCell():New(oSection3, "VALOR_TOTAL"           , "H7L", STR0024, "@E 999,999,999.99", 15, , , "RIGHT" ,.F.,'RIGHT' ,,05,.T.) //"Val Total"
 
        Else
            oSection2:SetLeftMargin(80)

            TRCell():New(oSection2, "TIPO_PAGAMENTO"        , "H7L", STR0022,                    , 30  , , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Tp Pagamento"
            TRCell():New(oSection2, "DESC_TIPO_PAGA"        , "H7L", STR0037,                    , 90  , , , "LEFT"  ,.F.,'LEFT'  ,,05,.T.) //"Desc Tp Pag"
            TRCell():New(oSection2, "QUANTIDADE_PASSAGEIROS", "H7L", STR0023, "99999"            , 20  , , , "RIGHT" ,.F.,'RIGHT' ,,05,.T.) //"Qtd Passag"
            TRCell():New(oSection2, "VALOR_TOTAL"           , "H7L", STR0024, "@E 999,999,999.99", 15  , , , "RIGHT" ,.F.,'RIGHT' ,,05,.T.) //"Val Total"
       
        EndIf

        oSection2:Cell("QUANTIDADE_PASSAGEIROS"):lHeaderSize := .F.

        TRFunction():New(oSection2:Cell("QUANTIDADE_PASSAGEIROS"),  , "SUM",,,,,.T.,.F.,.F.)//"Qtd Passag"
        TRFunction():New(oSection2:Cell("VALOR_TOTAL")           ,  , "SUM",,,,,.T.,.F.,.F.)//"Total por motorista"        
        
    EndIf    

    TRFunction():New(oSection1:Cell("QUANTIDADE_PASSAGEIROS"), , "SUM",,,,,.T.,.F.,.F.)//"Qtd Passag"
    TRFunction():New(oSection1:Cell("VALOR_TOTAL")           , , "SUM",,,,,.T.,.F.,.F.)//"Total por motorista"

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()

@sample ReportPrint(oReport, cAliasQry)

@param oReport - Objeto - Objeto TREPORT
    cAliasQry  - Alias  - Nome do Alias para utilização na Query

/author Yuri Porto 
@since10/07/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
    Local oSection1          := oReport:Section(1)
    Local oSection2          := oReport:Section(2)
    Local oSection3          := oReport:Section(3) 
    Local lSintetico         := iIf(MV_PAR01==2,.T.,.F.)
    Local lPrestacao         := iIf(MV_PAR02==1,.T.,.F.)
    Local lPrintHeader       := .F.
    Local cAliasQry          := GetNextAlias()
    Local cQuery             := ""
    Local cMatricula         := ""
    Local cMotorista         := ""
    Local dData              := SToD('')
    Local dDataConf          := SToD('')

    cQuery := GTPR013Qry(.T.)
    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliasQry, .F., .F. )
    (cAliasQry)->(DbGoTop())

    oReport:SetMeter((cAliasQry)->(RecCount()))
    oReport:StartPage()
    oReport:SkipLine()
                          
    While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())  
        oSection1:Init()
        oReport:IncMeter()
        IncProc("Imprimindo...") //"Imprimindo..."

        If !lSintetico .And. lPrintHeader  
            oSection1:PrintHeader()
        EndIf

        dData     := SToD((cAliasQry)->DATA)
        dDataConf := SToD((cAliasQry)->DATA_CONFERENCIA)

        cMatricula := POSICIONE("GYG",1,xFilial("GYG") + (cAliasQry)->COLABORADOR, "GYG_FUNCIO")
        cMotorista := POSICIONE("GYG",1,xFilial("GYG") + (cAliasQry)->COLABORADOR, "GYG_NOME")
        
        oSection1:Cell("FILIPETA"):SetValue((cAliasQry)->FILIPETA)          
        oSection1:Cell("LOCAL_ARRECADA_DESC"):SetValue((cAliasQry)->LOC_ARRECADACAO + "-" + (cAliasQry)->LOCAL_ARRECADA_DESC)     
        oSection1:Cell("DATA"):SetValue(dData)    
        oSection1:Cell("DATA_CONFERENCIA"):SetValue(dDataConf)        
        oSection1:Cell("DATA_SERVICO"):SetValue( SToD((cAliasQry)->DATA_SERVICO) )        
        oSection1:Cell("NOME_CONFERENTE"):SetValue(GetUsrName((cAliasQry)->CONFERENTE))  
        oSection1:Cell("NOME_INCLUIU"):SetValue(GetUsrName((cAliasQry)->INCLUIU))  
        oSection1:Cell("STATUS"):SetValue((cAliasQry)->STATUS)             
        oSection1:Cell("NOME_COLABORADOR"):SetValue(cMatricula + " - " + cMotorista)
        oSection1:Cell("QUANTIDADE_PASSAGEIROS"):SetValue((cAliasQry)->QUANTIDADE_PASSAGEIROS)
        oSection1:Cell("VALOR_TOTAL"):SetValue((cAliasQry)->VALOR_TOTAL)

        oSection1:PrintLine()

        If !lSintetico // Analítico

            oSection2:init()
        
            //Imprime os itens da prestação
            RelAnalitico(oReport, oSection2, oSection3, lPrestacao, (cAliasQry)->CODIGO)
        EndIf

        (cAliasQry)->(DbSkip())    

        IF !lSintetico .And. (cAliasQry)->(!Eof())
            lPrintHeader := .T.
        EndIf       

    EndDo     
    
    oSection1:Finish()  
    oReport:EndPage()    

    (cAliasQry)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RelAnalitico()
@description Função responsável por imprimir os detalhes do relatório analitico, separado por prestação ou tipo de pagamento
@sample RelAnalitico(oReport, oSection2, oSection3, lPrestacao, lValores, cPrestacao, cAliasQryT)

@param oReport    - Objeto   - Objeto TREPORT
       oSection2  - Objeto   - Objeto TRSection
       oSection3  - Objeto   - Objeto TRSection       
       lPrestacao - Boolean  - Parametro do relatorio analitico (.T. Por prestação / .F. Por tipo de pagamento)
       lValores   - Boolean  - Define se terá vinculo com as tabelas que trazem os valores (H7J/H7L/H6R)
       cPrestacao - Caracter - Código da prestação para filtro
       cAliasQryT - Alias    - Query de totalizadores

@author Breno Gomes
@since 24/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RelAnalitico(oReport, oSection2, oSection3, lPrestacao, cPrestacao)
    Local cAliasPag    := GetNextAlias()
    Local cQuery       := ""
    Local cServico     := ""
    Local lPrintHeader := .F.
        
    If lPrestacao       

        H7J->(DbSetOrder(1)) 
        If H7J->(DbSeek(xFilial("H7J") + cPrestacao))   
            cServico := H7J->H7J_SERVIC

            While H7J->(!Eof()) .And. H7J->( H7J_FILIAL + H7J_CODIGO + H7J_SERVIC) == xFilial("H7J") + cPrestacao + cServico
            
                oSection2:init()
                If lPrintHeader
                    oSection2:PrintHeader()
                EndIf

                oSection3:init()
                oReport:IncMeter()                

                oSection2:Cell("SERVICO"):SetValue(H7J->H7J_SERVIC )
                oSection2:Cell("DATA_INICIO_SERV"):SetValue(H7J->H7J_DATAIS)
                oSection2:Cell("DATA_TERMINO_SERV"):SetValue(H7J->H7J_DATATS)
                oSection2:Cell("LINHA"):SetValue( H7J->H7J_CODLIN )
                oSection2:Cell("PREFIXO"):SetValue( H7J->H7J_PREFLI )
                oSection2:Cell("DESC_LINHA"):SetValue(POSICIONE("H6V", 4, xFilial("H6V") + H7J->H7J_CODLIN, "H6V_DESCRI"))
                oSection2:Cell("VEICULO"):SetValue(Alltrim(H7J->H7J_VEICUL) + ' - ' + GetAdvFval('ST9','T9_NOME',xFilial('ST9')+H7J->H7J_VEICUL))
                oSection2:Cell("TURNO"):SetValue(H7J->H7J_TURNO)     
                oSection2:Cell("TOTAL_VIAGENS"):SetValue(H7J->H7J_TOTVIA)
                oSection2:Cell("QUANTIDADE_PASSAGEIROS"):SetValue(H7J->H7J_TOTPAS)
                oSection2:Cell("VALOR_TOTAL"):SetValue(H7J->H7J_VLRTOT)
                
                oSection2:PrintLine()

                If lPrintHeader
                    oSection3:PrintHeader()
                EndIf

                H7L->(DbSetOrder(1)) 
                If H7L->(DbSeek(xFilial("H7L") + cPrestacao + cServico))  // H7L_FILIAL+H7L_CODIGO+H7L_SERVIC+H7L_TPAGAM 
                    cTpPag := H7L->H7L_TPAGAM                                                                                                                      
                    While H7L->(!Eof()) .And. H7L->( H7L_FILIAL+H7L_CODIGO+H7L_SERVIC+H7L_TPAGAM ) == xFilial("H7L") + cPrestacao + cServico + cTpPag
            
                        oSection3:Cell("TIPO_PAGAMENTO"):SetValue(H7L->H7L_TPAGAM )
                        oSection3:Cell("DESC_TIPO_PAGA"):SetValue(POSICIONE("H6R", 1, xFilial("H6R") + H7L->H7L_TPAGAM , "H6R_DESCRI"))
                        oSection3:Cell("QUANTIDADE_PASSAGEIROS"):SetValue(H7L->H7L_NUMPAS)
                        oSection3:Cell("VALOR_TOTAL"):SetValue(H7L->H7L_VLRTOT )
                        
                        oSection3:PrintLine()  

                        H7L->(DbSkip())  
                        cTpPag := H7L->H7L_TPAGAM 

                    EndDo

                EndIf

                H7J->(DbSkip()) 
                cServico := H7J->H7J_SERVIC  

                IF H7J->(!Eof())
                    lPrintHeader := .T.
                EndIf

            EndDo

        EndIf

    Else

        cQuery := GTPR013Qry(.F., cPrestacao)
        cQuery := ChangeQuery(cQuery)
        DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliasPag, .F., .F. )
        (cAliasPag)->(DbGoTop())

        While (cAliasPag)->(!Eof())                 
            oReport:IncMeter()

            oSection2:Cell("TIPO_PAGAMENTO"):SetBlock({|| (cAliasPag)->TIPO_PAGAMENTO })
            oSection2:Cell("DESC_TIPO_PAGA"):SetBlock({|| POSICIONE("H6R", 1, xFilial("H6R") + (cAliasPag)->TIPO_PAGAMENTO, "H6R_DESCRI") })
            oSection2:Cell("QUANTIDADE_PASSAGEIROS"):SetBlock({|| (cAliasPag)->QUANTIDADE_PASSAGEIROS })
            oSection2:Cell("VALOR_TOTAL"):SetBlock({|| (cAliasPag)->VALOR_TOTAL })
            
            oSection2:PrintLine()               
            (cAliasPag)->(DbSkip())
        EndDo
        (cAliasPag)->(DbCloseArea())

    EndIf

    oSection2:Finish()
    oSection3:Finish()
    oReport:SkipLine()        
        
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR013Qry (lCabec, lSintetico, lPrestacao, lValores, lTotaliza, cPrestacao)
@description Função responsável por imprimir os detalhes do relatório analitico, separado por prestação ou tipo de pagamento
@sample GTPR013Qry(lCabec, lSintetico, lPrestacao, lValores, lTotaliza, cPrestacao)

@param lCabec     - Boolean  - Define se a query é para o cabeçalho da prestação ou pros itens
       lSintetico - Boolean  - Indica o tipo do relatório (.T. - Sintético / .F. - Analitico)
       lPrestacao - Boolean  - Indica se o relatório analitico será separado por prestação ou por tipo de pagamento (.T. Por prestação / .F. Por tipo de pagamento)
       lValores   - Boolean  - Indica se terá vinculo com as tabelas que trazem os valores (H7J/H7L/H6R)
       lTotaliza  - Boolean  - Define se a query irá trazer apenas o totalizador
       cPrestacao - Caracter - Código da prestação para filtro

@return cQuery - Caracter - Query montada para cada situação
@author Breno Gomes
@since 24/09/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GTPR013Qry(lPrestacao, cPrestacao)
    Local cQuery  := ""
    
    Default lPrestacao := .F.    
    Default cPrestacao := ""
    
    If lPrestacao    

        cQuery := " SELECT H7I.H7I_FILIAL FILIAL, "
        cQuery +=        " H7I.H7I_CODIGO CODIGO, "
        cQuery +=        " H7I.H7I_COLETA FILIPETA, "
        cQuery +=        " H7I.H7I_DATREF DATA, "
        cQuery +=        " H7I.H7I_LOCARR LOC_ARRECADACAO, "
        cQuery +=        " H7M.H7M_DESC   LOCAL_ARRECADA_DESC, "
        cQuery +=        " H7I.H7I_CONFER CONFERENTE, "
        cQuery +=        " H7I.H7I_DTPRCO DATA_CONFERENCIA, "
        cQuery +=        " H7I.H7I_DTSERV DATA_SERVICO, "
        cQuery +=        " H7I.H7I_MOTORI COLABORADOR, " 
        cQuery += " CASE "
        cQuery += "     WHEN H7I.H7I_STATUS = '1'  THEN 'Pendente' "
        cQuery += "     WHEN H7I.H7I_STATUS = '2'  THEN 'Concluido' "
        cQuery += "     ELSE 'Reaberto' "
        cQuery += " END 'STATUS',    "
       // cQuery +=        " H7I.H7I_STATUS 'STATUS', "  
        cQuery +=        " H7I.H7I_USRINC INCLUIU, " 
        cQuery +=        " SUM(H7L.H7L_VLRTOT) VALOR_TOTAL, "
        cQuery +=        " SUM(H7L.H7L_NUMPAS) QUANTIDADE_PASSAGEIROS "
        cQuery += " FROM " + RetSqlName('H7I') + " H7I "
        cQuery += " LEFT JOIN " + RetSqlName('H7M') + " H7M "
        cQuery +=        " ON H7M.H7M_FILIAL = H7I.H7I_FILIAL"
        cQuery +=           " AND H7I.H7I_LOCARR = H7M.H7M_COD "
        cQuery +=           " AND H7M.D_E_L_E_T_ = '' "    
        cQuery += " LEFT JOIN " + RetSqlName('H7J') + " H7J "
        cQuery +=         " ON H7J.H7J_FILIAL = H7I.H7I_FILIAL "
        cQuery +=           " AND H7I.H7I_CODIGO = H7J.H7J_CODIGO "        
        cQuery +=           " AND H7J.D_E_L_E_T_ = '' "
        cQuery += " LEFT JOIN " + RetSqlName('H7L') + " H7L "
        cQuery +=         " ON H7L.H7L_FILIAL = H7J.H7J_FILIAL "
        cQuery +=            " AND H7L.H7L_SERVIC = H7J.H7J_SERVIC "
        cQuery +=            " AND H7J.H7J_CODIGO = H7L.H7L_CODIGO "
        cQuery +=            " AND H7L.D_E_L_E_T_ = '' "
        cQuery += " WHERE  H7I.H7I_FILIAL = '"+  xFilial("H7I") +"' "      
        cQuery +=      " AND ( H7I.H7I_DATREF >= '" + DTOS(MV_PAR03) + "' AND H7I.H7I_DATREF <= '" + DTOS(MV_PAR04) + "')"    
        cQuery +=      " AND ( H7I.H7I_CONFER >= '" + MV_PAR05 + "' AND H7I.H7I_CONFER <= '" + MV_PAR06 + "')"
        cQuery +=      " AND ( H7I.H7I_MOTORI >= '" + MV_PAR07 + "' AND H7I.H7I_MOTORI <= '" + MV_PAR08 + "')"
        cQuery +=      " AND ( H7I.H7I_COBRAD >= '" + MV_PAR09 + "' AND H7I.H7I_COBRAD <= '" + MV_PAR10 + "')"    
        cQuery +=      " AND ( H7I.H7I_LOCARR >= '" + MV_PAR11 + "' AND H7I.H7I_LOCARR <= '" + MV_PAR12 + "')"   
        cQuery +=      " AND ( H7I.H7I_USRINC >= '" + MV_PAR13 + "' AND H7I.H7I_USRINC <= '" + MV_PAR14 + "')" 
        If MV_PAR15 == 4 // Todos
            cQuery +=      " AND ( H7I.H7I_STATUS IN ('1','2','3')) "
        Else
            cQuery +=      " AND ( H7I.H7I_STATUS = '" + Alltrim(Str(MV_PAR15)) + "') "
        EndIf
        cQuery +=      " AND H7I.D_E_L_E_T_ = ''  "
        cQuery += " GROUP BY H7I.H7I_FILIAL,"
        cQuery +=          " H7I.H7I_CODIGO,"
        cQuery +=          " H7I.H7I_COLETA,"
        cQuery +=          " H7I.H7I_DATREF,"
        cQuery +=          " H7I.H7I_LOCARR ,"
        cQuery +=          " H7M.H7M_DESC,"
        cQuery +=          " H7I.H7I_CONFER,"
        cQuery +=          " H7I.H7I_DTPRCO,"
        cQuery +=          " H7I.H7I_DTSERV,"
        cQuery +=          " H7I.H7I_STATUS,"
        cQuery +=          " H7I.H7I_USRINC,"
        cQuery +=          " H7I.H7I_MOTORI"

    ElseIf !Empty(cPrestacao)

        cQuery := " SELECT H7L.H7L_TPAGAM TIPO_PAGAMENTO,
        cQuery +=        " SUM(H7L.H7L_VLRTOT) VALOR_TOTAL, "
        cQuery +=        " SUM(H7L.H7L_NUMPAS) QUANTIDADE_PASSAGEIROS "
        cQuery += " FROM " + RetSqlName('H7L') + " H7L "
        cQuery += " WHERE  H7L.H7L_FILIAL = '"+  xFilial("H7L") +"' "  
        cQuery +=        " AND H7L.H7L_CODIGO = '" + cPrestacao + "'  "
        cQuery +=        " AND H7L.D_E_L_E_T_ = ''  "
        cQuery += " GROUP BY H7L.H7L_TPAGAM " 

    EndIf    

Return cQuery  

Static Function GetUsrName(cCodigo)
    Local cNome := ''
    Local nPos  := 0
    If (nPos:= Ascan( aPerfil, {|e| e[1] == cCodigo })) == 0
        cNome := FwGetUserName(cCodigo)
        Aadd(aPerfil,{cCodigo,cNome})
    Else
        cNome:= aPerfil[nPos][2]
    EndIf 

Return cNome 
