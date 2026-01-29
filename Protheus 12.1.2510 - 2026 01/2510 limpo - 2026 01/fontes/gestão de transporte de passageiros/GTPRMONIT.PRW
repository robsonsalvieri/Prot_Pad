#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPRMONIT.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPRMONIT
Relatorio de Logs do monitor de integrações

@author SIGAGTP | João Paulo Pires
@since 10/12/2025

@type function
/*/
//-------------------------------------------------------------------
Function GTPRMONIT()
    Local oReport := nil

    If GYS->(FieldPos("GYS_REFER1")) > 0
        oReport := RPTStruct()
        oReport:PrintDialog()
    Else
        FwAlertHelp(STR0012, STR0013) // "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina" 
    Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptStruc
Define estrutura de campos

@author SIGAGTP | João Paulo Pires
@since 10/12/2025

@type function
/*/
//-------------------------------------------------------------------
Static Function RPTStruct()
    Local oReport   := nil
    Local oSection1 := nil
    Local oSection2 := nil
    Local cPerg     := "GTPRMONIT"

    Pergunte(cPerg,.T.)

    oReport := TReport():New("GTPRMONIT",STR0001,cPerg,{|oReport|RPTPrint(oReport)},STR0002) //"Monitor de integração" - "Rel. de logs do monitor de integração"
    oReport:SetLandscape(.T.)

    oSection1 := TRSection():New(oReport, STR0003,{"GYS"}, NIL,.F.,.T.) //"Cabeçalho"
    oSection1:SetHeaderSection(.T.)
    TRCell():New(oSection1,"GYS_DESCRI"  ,"GYS",  STR0004 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Item"   
    TRCell():New(oSection1,"GYS_URL"     ,"GYS",  STR0005 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"URL"
    
    oSection2 := TRSection():New(oReport,STR0006,{"GYS"},nil,.F.,.T.) //"Falhas"
    oSection2:SetCellBorder("BOTTOM")
    oSection2:SetHeaderSection(.T.)    
    oSection2:SetTotalInLine(.F.)
    
    TRCell():New(oSection2,"GYS_DATA"    ,"GYS", STR0007 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Data"
    TRCell():New(oSection2,"GYS_HORA"    ,"GYS", STR0008 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Hora"
    TRCell():New(oSection2,"REFERENCIA"  ,"GYS", STR0009 ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Referência"
    TRCell():New(oSection2,"GYS_REPORT"  ,"GYS", STR0010 ,,,,,'LEFT',.T.,'LEFT',,,.T.) //"Desc. Falha"

    TRFunction():New(oSection2:Cell("REFERENCIA") ,,"COUNT",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
    
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} RPTPrint
Realiza impressão do relatório

@author SIGAGTP | João Paulo Pires
@since 10/12/2025

@type function
/*/
//-------------------------------------------------------------------    
Static Function RPTPrint(oReport)
    Local oSection1  := oReport:Section(1)
    Local oSection2  := oReport:Section(2)
    Local cAliasGYS  := GetNextAlias()
    Local cDescri    := ""
    Local cQryRot    := "" //Rotinas que serão exibidas no log 

    //cQryRot += " 'GTPIRJ001', " //Localidade
    cQryRot += " 'GTPIRJ115' "  //Bilhetes
    cQryRot := "%"+cQryRot+"%"
    
    
    BeginSql Alias cAliasGYS  
        
       SELECT GYS.GYS_DESCRI,
       GYS.GYS_DATA,
       GYS.GYS_HORA,
       GYS.GYS_URL,
       GYS.GYS_ROTINA,
       GYS.GYS_REFER1 AS REFERENCIA,
       Isnull(Cast(Cast(GYS.GYS_REPORT AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS GYS_REPORT
        FROM   %Table:GYS% GYS
        WHERE  GYS.GYS_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
       AND GYS.GYS_ROTINA IN (%Exp:cQryRot%)
       AND GYS.%NotDel%
       ORDER BY GYS.GYS_DATA, GYS.GYS_HORA, GYS.GYS_DESCRI

    EndSql

    (cAliasGYS)->(dbGotop())

    oReport:SetMeter((cAliasGYS)->(LastRec()))    

    while (cAliasGYS)->(!Eof())
    
        oSection1:Init()
        oReport:IncMeter()

        IncProc(STR0011) //"Imprimindo..."
        
        oSection1:Cell("GYS_DESCRI"):SetValue(ALLTRIM((cAliasGYS)->GYS_DESCRI))        
        oSection1:Cell("GYS_URL"):SetValue(ALLTRIM((cAliasGYS)->GYS_URL))
                
        oSection1:Printline()		

        cDescri := (cAliasGYS)->GYS_DESCRI

        oSection2:Init()

        while (cAliasGYS)->(!Eof()) .AND. (cAliasGYS)->GYS_DESCRI == cDescri
            
            oReport:IncMeter()            

            oSection2:Cell("GYS_DATA"):SetValue(DTOC(STOD(ALLTRIM((cAliasGYS)->GYS_DATA))))
            oSection2:Cell("GYS_HORA"):SetValue(ALLTRIM((cAliasGYS)->GYS_HORA))            
            oSection2:Cell("REFERENCIA"):SetValue(ALLTRIM((cAliasGYS)->REFERENCIA))
            oSection2:Cell("GYS_REPORT"):SetValue(ALLTRIM((cAliasGYS)->GYS_REPORT))            
            oSection2:Printline()

            (cAliasGYS)->(dbskip())
        enddo

        oSection2:Finish()
       
        oReport:ThinLine()
        oSection1:Finish()                

    enddo    

    (cAliasGYS)->(dbCloseArea())

Return 
