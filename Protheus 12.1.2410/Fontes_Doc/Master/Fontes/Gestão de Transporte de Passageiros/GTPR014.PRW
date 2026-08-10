#include 'TOTVS.ch'
//#include 'GTPR014.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR014
Relatório SAC - Reclamações por viagem
@sample GTPR014()
@author YURI PORTO
@since 10/09/2024
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR014()

Local oReport
Local cPerg  := 'GTPR014'//'GTPR014'

If Pergunte(cPerg, .T.)

    oReport := ReportDef(cPerg)
    oReport:PrintDialog()

Endif


Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Relatório  SAC - Reclamações por viagem

@sample ReportDef(cPerg)
@param cPerg - caracter - Nome da Pergunta
@return oReport - Objeto - Objeto TREPORT
@author Yuri Porto 
@since10/07/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
    Local cTitle                := "Relatório  SAC - Reclamações  por viagem"//"Relatório  SAC - Reclamações por viagem"
    Local cTitle2               := "Seção Escalas"//"Seção Escalas"   
    Local cTitulo               := "GTP - Relatório  SAC - Reclamações  por viagem"//"GTP - Relatório  SAC - Reclamações por viagem"
    Local cTotal01              := ""
    Local cTotal02              := ""    
    Local cAliasQry             := GetNextAlias()
    Local oSection1,oSection2
    Local oReport        

    cTitle      +=  "Analitico"
    cTotal01    :=  "Total por Viagem : "
    cTotal02    :=  "Total por Viagem : "

    oReport := TReport():New('GTPR014', cTitle, cPerg, {|oReport|ReportPrint(oReport,cAliasQry)}, cTitulo, , , ,)
    oReport:SetLandScape( )
    oReport:SetTotalInLine(.F.)



    oSection1 := TRSection():New(oReport,cTitle,cAliasQry,,,,/*cTotal01*/,,,.T.)
    oSection1:SetTotalInLine(.F.)
    oSection1:PrintFunction(.T.)


    oSection2:= TRSection():New(oReport,cTitle2, cAliasQry,,,,/*cTotal02*/,,,.T.)
    oSection2:SetTotalInLine(.F.)
    oSection2:PrintFunction(.T.)
   
    TRCell():New(oSection1,"CODVIA",                    cAliasQry, "Cód. Viagem"            ,                  ,10, , ,"LEFT"  )//"Cód. Viagem"
    TRCell():New(oSection1,"TIPO",                      cAliasQry, "Tipo Viagem"            ,                  ,20, , ,"LEFT"  )//"Tipo Viagem"     
    TRCell():New(oSection1,"DATA_INI",                  cAliasQry, "Data inicial"           ,                  ,10, , ,"LEFT"  ) //"Data inicial"
    TRCell():New(oSection1,"HORA_INI",                  cAliasQry, "Hora inicial"           ,                  ,10, , ,"LEFT"  ) //"Data inicial"
    TRCell():New(oSection1,"DATA_FIM",                  cAliasQry, "Data final"             ,                  ,10, , ,"LEFT"  ) //"Data final"
    TRCell():New(oSection1,"HORA_FIM",                  cAliasQry, "Hora final"             ,                  ,10, , ,"LEFT"  ) //"Hora final"
    TRCell():New(oSection1,"ORIGEM",                    cAliasQry, "Cód Origem"             ,                  ,10, , ,"LEFT"  ) //"Cód Origem"
    TRCell():New(oSection1,"DESTINO",                   cAliasQry, "Cód Destino"            ,                  ,10, , ,"LEFT"  ) //"Cód Destino"
    TRCell():New(oSection1,"FINALIZADA",                cAliasQry, "Finalizada"             ,                  ,10, , ,"LEFT"  ) //"Finalizada"
    
    TRCell():New(oSection2,"CODIGO",                   cAliasQry, "Código"                  ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"OCORR",                    cAliasQry, "Ocorrencia"              ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"DTVIAGEM",                 cAliasQry, "Dt Viagem"               ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"ORIGEM",                   cAliasQry, "Origem"                  ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"DESTINO",                  cAliasQry, "Destino"                 ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"VEICULO",                  cAliasQry, "Veiculo"                 ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"COLABORADOR",              cAliasQry, "Colaborador"             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"DATAREC",                  cAliasQry, "Dt Reclamação"           ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"HORAREC",                  cAliasQry, "Hr Reclamação"           ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"SLA",                      cAliasQry, "SLA"                     ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"CLIENTE",                  cAliasQry, "Cliente"                 ,,,,,'LEFT',.F.,'LEFT',,,.T.)

    oSection1:SetColSpace(1,.F.)
    oSection1:SetAutoSize(.F.)

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
@sample ReportPrint(oReport, cAliasQry)
@param oReport - Objeto - Objeto TREPORT
@cAliasQry  - Alias  - Nome do Alias para utilização na Query
@author Yuri Porto 
@since10/07/2024
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,cAliasQry)
    Local oSection1             := oReport:Section(1)
    Local oSection2             := oReport:Section(2)
    Local cQuery                := ""
    Local cViagem               := ""
    
    cQuery += "    SELECT "
    //    --OCOORENCIAS
    cQuery += "    H7T.H7T_FILIAL AS FILIAL, "
    cQuery += "    COALESCE(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), [H7T_MEMO])), ' ') AS DESCRICAO, "
    cQuery += "    H7T.H7T_CODIGO AS CODIGO,"
    cQuery += "    H7T.H7T_TPOCOR AS OCORR,"
    cQuery += "    H7T.H7T_VIAGEM AS VIAGEM,"
    cQuery += "    H7T.H7T_DTVIAG AS DTVIAGEM,"
    cQuery += "    CONCAT(H7T.H7T_LOCORI,'-',H7T.H7T_NMLOCA) AS ORIGEM,"
    cQuery += "    CONCAT(H7T.H7T_LOCDES,'-',H7T.H7T_NMDEST) AS  DESTINO,"
    cQuery += "    CONCAT(H7T.H7T_CODVEI,'-',H7T.H7T_DCODVE) AS VEICULO,"
    cQuery += "    CONCAT(H7T.H7T_COLCOD,'-',H7T.H7T_COLNOM) AS COLABORADOR,"
    cQuery += "    H7T.H7T_DATA AS DATAREC,"
    cQuery += "    H7T.H7T_HORA AS HORAREC,"
    cQuery += "    H7T.H7T_SLAOCO AS SLA,"
    cQuery += "    H7T.H7T_CLINOM AS CLIENTE,"
    cQuery += "    H7T.H7T_CLIMAI AS EMAIL,"
    cQuery += "    CONCAT(H7T.H7T_CLIEND,' ',H7T.H7T_CLINUM)   AS ENDERECO,"
    cQuery += "    H7T.H7T_CLIDOC AS DOC,"
    //		--VIAGEM
    cQuery += "    GYN.GYN_CODIGO	AS CODVIA,"
    cQuery += "    GYN.GYN_TIPO	AS  TIPO,"
    cQuery += "    GYN.GYN_DTINI	AS DATA_INI,"
    cQuery += "    GYN.GYN_HRINI	AS HORA_INI,"
    cQuery += "    GYN.GYN_DTFIM	AS DATA_FIM,"
    cQuery += "    GYN.GYN_HRFIM	AS HORA_FIM,"
    cQuery += "    GYN.GYN_LOCORI	AS COD_ORIGEM,"    
    cQuery += "    GYN.GYN_LOCDES	AS COD_DESTINO,"    
    cQuery += "    GYN.GYN_HRFIM	AS FINALIZADA"    
    cQuery += "    FROM  "+ RetSqlName('H7T')+"  H7T"
    cQuery += "    LEFT JOIN " + RetSqlName('GYN')+"  GYN ON ( H7T.H7T_FILIAL = GYN.GYN_FILIAL AND H7T.H7T_VIAGEM = GYN.GYN_CODIGO AND GYN.D_E_L_E_T_ = '')"
    cQuery += "    WHERE H7T.H7T_VIAGEM <> '' "
    cQuery += "    AND H7T.D_E_L_E_T_ = ''"
    cQuery += "    AND H7T.H7T_DATA >= '"+ DTOS(MV_PAR01) +"' "
    cQuery += "    AND H7T.H7T_DATA <= '"+ DTOS(MV_PAR02) +"' "
    cQuery += "    AND GYN.GYN_LOCORI >= '"+ MV_PAR03 +"' "
    cQuery += "    AND GYN.GYN_LOCORI <= '"+ MV_PAR04 +"' "
    cQuery += "    AND H7T.H7T_COLCOD >= '"+ MV_PAR05 +"' "
    cQuery += "    AND H7T.H7T_COLCOD <= '"+ MV_PAR06 +"' "
    cQuery += "    AND H7T.H7T_CODVEI >= '"+ MV_PAR07 +"' "
    cQuery += "    AND H7T.H7T_CODVEI <= '"+ MV_PAR08 +"' "


    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliasQry, .F., .F. )
    (cAliasQry)->(DbGoTop())


    oReport:SetMeter((cAliasQry)->(RecCount()))
    oReport:StartPage()
    oReport:SkipLine()


 
    While !oReport:Cancel() .AND. (cAliasQry)->(!Eof())   
                                                                        
        oSection1:Init()        

        oSection1:Cell("CODVIA"):SetBlock({|| (cAliasQry)->CODVIA})
        oSection1:Cell("TIPO"):SetBlock({|| (cAliasQry)->TIPO})            
        oSection1:Cell("DATA_INI"):SetBlock({|| DTOC(STOD((cAliasQry)->DATA_INI))})     
        oSection1:Cell("HORA_INI"):SetBlock({|| SUBSTR((cAliasQry)->HORA_INI,1,2)+":"+SUBSTR((cAliasQry)->HORA_INI,3,4)}) 
        oSection1:Cell("DATA_FIM"):SetBlock({|| DTOC(STOD((cAliasQry)->DATA_FIM))}) 
        oSection1:Cell("HORA_FIM"):SetBlock({|| SUBSTR((cAliasQry)->HORA_FIM,1,2)+":"+SUBSTR((cAliasQry)->HORA_FIM,3,4)}) 
        oSection1:Cell("ORIGEM"):SetBlock({|| (cAliasQry)->COD_ORIGEM}) 
        oSection1:Cell("DESTINO"):SetBlock({|| (cAliasQry)->COD_DESTINO}) 
        oSection1:Cell("FINALIZADA"):SetBlock({|| SUBSTR((cAliasQry)->FINALIZADA,1,2)+":"+SUBSTR((cAliasQry)->FINALIZADA,3,4)}) 
        
        oSection1:PrintLine()
        oSection2:init()
  
        cViagem      :=  (cAliasQry)->CODVIA

        While  cViagem== (cAliasQry)->CODVIA
            oReport:IncMeter()

            oSection2:Cell("CODIGO"):SetBlock({|| (cAliasQry)->CODIGO})
            oSection2:Cell("OCORR"):SetBlock({|| (cAliasQry)->OCORR})            
            oSection2:Cell("DTVIAGEM"):SetBlock({|| DTOC(STOD((cAliasQry)->DTVIAGEM))})
            oSection2:Cell("ORIGEM"):SetBlock({|| (cAliasQry)->ORIGEM})
            oSection2:Cell("DESTINO"):SetBlock({|| (cAliasQry)->DESTINO})
            oSection2:Cell("VEICULO"):SetBlock({|| (cAliasQry)->VEICULO})
            oSection2:Cell("COLABORADOR"):SetBlock({|| (cAliasQry)->COLABORADOR})
            oSection2:Cell("DATAREC"):SetBlock({|| DTOC(STOD((cAliasQry)->DATAREC))})
            oSection2:Cell("HORAREC"):SetBlock({|| (cAliasQry)->HORAREC})
            oSection2:Cell("SLA"):SetBlock({|| (cAliasQry)->SLA})
            oSection2:Cell("CLIENTE"):SetBlock({|| (cAliasQry)->CLIENTE})            
            oSection2:PrintLine() 

            (cAliasQry)->(DbSkip())  
                                
        EndDo
        
        oSection2:Finish()       
        oReport:SkipLine()
        oSection1:Finish()

    EndDo


    oReport:EndPage()    


    (cAliasQry)->(DbCloseArea())

Return


