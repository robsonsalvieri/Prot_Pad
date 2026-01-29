#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPR951.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR951
Relatório Geracão de dados operacionais (ANTT, DER e SIE (SC))

@author SIGAGTP | João P. Pires
@since 28/01/2025

@type function
/*/
//-------------------------------------------------------------------
Function GTPR951()
    Local oReport := nil

    oReport := RPTStruct()
    oReport:PrintDialog()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} RptStruc
Define estrutura de campos

@author SIGAGTP | João P. Pires
@since 28/01/2025

@type function
/*/
//-------------------------------------------------------------------
Static Function RPTStruct()
    Local oReport   := nil
    Local oSection1 := nil
    Local oSection2 := nil
    Local cPerg     := "GTPR951"

    Pergunte(cPerg,.T.)

    oReport := TReport():New("GTPR951",STR0001,cPerg,{|oReport|RPTPrint(oReport)},STR0001)//"Relatório dados operacionais (ANTT, DER e SIE (SC))"
    oReport:SetLandscape( )
    oReport:SetTotalInLine(.F.)

    oSection1 := TRSection():New(oReport, STR0002,{"GI2"}, NIL,.F.,.T.) //"Linha"
    oSection1:SetTotalInLine(.F.)

    TRCell():New(oSection1,"GI2_COD"    ,"GI2",  RetTitle("GI2_COD")                ,,06,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"GI2_ORGAO"  ,"GI2",  RetTitle("GI2_ORGAO")              ,,40,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"GI2_NCATEG" ,"GI2",  RetTitle("GI2_NCATEG")             ,,35,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"GI2_PREFIX" ,"GI2",  RetTitle("GI2_PREFIX")             ,,20,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"GI2_QTDLUG" ,"GI2",  RetTitle("GI2_QTDLUG")             ,,02,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"GI2_MSBLQL" ,"GI2",  RetTitle("GI2_MSBLQL")             ,,06,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"GI2_KMTOTA" ,"GI2",  RetTitle("GI2_KMTOTA") ,"@E 9999.99",08,,,'RIGHT',.F.,'RIGHT',,05)
    TRCell():New(oSection1,"TOTVIAG"    ,"GI2",  STR0009                            ,,04,,,'RIGHT',.F.,'RIGHT',,05) //"Tot. Viagens */

    TRFunction():New(oSection1:Cell("GI2_KMTOTA") ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
    TRFunction():New(oSection1:Cell("TOTVIAG")    ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
    
    oSection2 := TRSection():New(oReport,STR0003,{"GIC"},nil,.F.,.T.) //"Viagens"
    TRCell():New(oSection2,"GIC_BILHET" ,"GIC",  RetTitle("GIC_BILHET")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_DTVEND" ,"GIC",  RetTitle("GIC_DTVEND")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_DTVIAG" ,"GIC",  RetTitle("GIC_DTVIAG")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_AGENCI" ,"GIC",  RetTitle("GIC_AGENCI")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_NLOCOR" ,"GIC",  RetTitle("GIC_NLOCOR")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_NLOCDE" ,"GIC",  RetTitle("GIC_NLOCDE")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_HORA"   ,"GIC",  RetTitle("GIC_HORA")               ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_SENTID" ,"GIC",  RetTitle("GIC_SENTID")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
  
    oSection1:SetPagebreack(.F.)
    
    
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} RPTPrint
Realiza impressão do relatório

@author SIGAGTP | João P. Pires
@since 28/01/2025

@type function
/*/
//-------------------------------------------------------------------    
Static Function RPTPrint(oReport)
    Local oSection1  := oReport:Section(1)
    Local oSection2  := oReport:Section(2)
    Local cAlias1    := GetNextAlias()
    Local cAlias2    := ""
    
    BeginSQL Alias cAlias1
        SELECT 
           GI2_COD,CONCAT(GI2_ORGAO,' - ',GI0_DESCRI) GI2_ORGAO,GI2_CATEG,GI2_PREFIX,GI2_KMTOTA,GI2_QTDLUG,
           GI2_MSBLQL, COUNT(GIC_CODIGO) TOTVIAG
            FROM %Table:GIC% GIC
            INNER JOIN %Table:GI2% GI2 ON GIC_FILIAL = %xFilial:GIC% AND GI2_FILIAL = %xFilial:GI2% 
                        AND GI2_COD = GIC_LINHA AND GI2.%notDel% AND GIC.%notDel% 
            INNER JOIN %Table:GI0% GI0 ON GI0_FILIAL = %xFilial:GI0% AND GI0_COD = GI2_ORGAO AND GI0.%notDel%
            WHERE
                GIC_DTVEND BETWEEN %Exp:Dtos(MV_PAR01)%  AND %Exp:Dtos(MV_PAR02)%    
                AND GIC_AGENCI BETWEEN %Exp:MV_PAR03%  AND %Exp:MV_PAR04%    
                AND GI2_ORGAO BETWEEN %Exp:MV_PAR05%  AND %Exp:MV_PAR06%    
                AND GIC_LINHA <> ' ' 
                AND GI2_HIST = '2' 
            GROUP BY GI2_COD,GI2_ORGAO,GI0_DESCRI,GI2_CATEG,GI2_PREFIX,GI2_KMTOTA,GI2_QTDLUG,GI2_MSBLQL
            ORDER BY GI2_COD

    EndSql


    (cAlias1)->(dbGotop())

    oReport:SetMeter((cAlias1)->(LastRec()))

    IF MV_PAR07 == 2 //Sintetico
        oSection1:Init()
    ENDIF

    while (cAlias1)->(!Eof())

        IF MV_PAR07 == 1 //Analitico
            oSection1:Init()
        ENDIF
        oReport:IncMeter()

        IncProc(STR0004)//"Imprimindo..."
        
        oSection1:Cell( "GI2_COD"    ):SetValue( ALLTRIM((cAlias1)->GI2_COD))
        oSection1:Cell( "GI2_ORGAO"  ):SetValue( ALLTRIM((cAlias1)->GI2_ORGAO))
        oSection1:Cell( "GI2_NCATEG" ):SetValue( ALLTRIM(POSICIONE("GYR", 1, XFILIAL("GYR") + (cAlias1)->GI2_CATEG, "GYR_DESCRI")))
        oSection1:Cell( "GI2_PREFIX" ):SetValue( ALLTRIM((cAlias1)->GI2_PREFIX))
        oSection1:Cell( "GI2_KMTOTA" ):SetValue( (cAlias1)->GI2_KMTOTA)
        oSection1:Cell( "GI2_QTDLUG" ):SetValue( ALLTRIM((cAlias1)->GI2_QTDLUG))
        oSection1:Cell( "GI2_MSBLQL" ):SetValue( IIF((cAlias1)->GI2_MSBLQL == '2',STR0005,STR0006))//"Ativo" "Inativo"
        oSection1:Cell( "TOTVIAG"    ):SetValue( (cAlias1)->TOTVIAG) 
        
        oSection1:Printline()		

        IF MV_PAR07 == 1
            oSection2:Init()

            cAlias2 := GetNextAlias()
            cLinha  := (cAlias1)->GI2_COD

            BeginSQL Alias cAlias2

                SELECT 
                GIC_LOCORI,GIC_LOCDES,GIC_HORA,GIC_SENTID,GIC_DTVEND,GIC_DTVIAG,GIC_AGENCI,GIC_BILHET
                FROM %Table:GIC% GIC    
                WHERE 
                    GIC_FILIAL =  %xFilial:GIC%
                    AND GIC_DTVEND BETWEEN %Exp:Dtos(MV_PAR01)%  AND %Exp:Dtos(MV_PAR02)%    
                    AND GIC_AGENCI BETWEEN %Exp:MV_PAR03%  AND %Exp:MV_PAR04%    
                    AND GIC_LINHA =  %Exp:cLinha%
                    AND GIC.%notDel% 
                ORDER BY GIC_LINHA,GIC_DTVIAG

            EndSql

            while (cAlias2)->(!Eof())
                oReport:IncMeter()            

                oSection2:Cell("GIC_BILHET"):SetValue(ALLTRIM(GIC_BILHET))
                oSection2:Cell("GIC_DTVEND"):SetValue(DTOC(STOD((cAlias2)->GIC_DTVEND)))
                oSection2:Cell("GIC_DTVIAG"):SetValue(DTOC(STOD((cAlias2)->GIC_DTVIAG)))
                oSection2:Cell("GIC_AGENCI"):SetValue((cAlias2)->GIC_AGENCI)
                oSection2:Cell("GIC_NLOCOR"):SetValue(ALLTRIM(POSICIONE('GI1',1,XFILIAL('GI1')+(cAlias2)->GIC_LOCORI,'GI1_DESCRI')))
                oSection2:Cell("GIC_NLOCDE"):SetValue(ALLTRIM(POSICIONE('GI1',1,XFILIAL('GI1')+(cAlias2)->GIC_LOCDES,'GI1_DESCRI')))
                oSection2:Cell("GIC_HORA"):SetValue((cAlias2)->GIC_HORA)
                oSection2:Cell("GIC_SENTID"):SetValue(IIF((cAlias2)->GIC_SENTID == '1',STR0007,STR0008)) //"Ida" - "Volta"

                oSection2:Printline()

                (cAlias2)->(dbskip())
            enddo

            oSection2:Finish()
            (cAlias2)->(DBCloseArea())
        ENDIF
                
        IF MV_PAR07 == 1
            oReport:ThinLine()
            oSection1:Finish()
        ENDIF

        (cAlias1)->(DBSkip())
    enddo

    IF MV_PAR07 == 2
        oSection1:Finish()
    ENDIF

    (cAlias1)->(dbCloseArea())

Return 
