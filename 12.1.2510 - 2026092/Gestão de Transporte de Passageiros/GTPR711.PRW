#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
//#INCLUDE 'GTPR711.CH'
/*/{Protheus.doc} GTPR711
Relatório de divergência bilhetes/TotalBus
@type function
@version 1.0 
@author pedro.saboia
@since 31/08/2026
/*/
Function GTPR711()
    Local oReport := nil

    oReport := RPTStruct()
    oReport:PrintDialog()

Return


/*/{Protheus.doc} RPTStruct
Define estrutura de campos
@type function
@version  1.0
@author pedro.saboia
@since 31/08/2026
/*/
Static Function RPTStruct()
    Local oReport   := nil
    Local oSection1 := nil
    Local oSection2 := nil
    Local cPerg     := "GTPR711"

    Pergunte(cPerg,.T.)

    oReport := TReport():New("GTPR711","Relatório de divergência bilhetes/TotalBus",cPerg,{|oReport|RPTPrint(oReport)},"Relatório de divergência bilhetes/TotalBus")//"Rel. de divergência bilhetes/TotalBus"
    oReport:SetLandscape( )
    oReport:SetTotalInLine(.F.)

    oSection1 := TRSection():New(oReport, "Cod. Ven. RJ",{"GIC"}, NIL,.F.,.T.) //""
    oSection1:SetTotalInLine(.F.)

    TRCell():New(oSection1,"GIC_VENDRJ"    ,"GIC",  RetTitle("GIC_VENDRJ")        ,,06,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"GIC_AGENCI"    ,"GIC",  RetTitle("GIC_AGENCI")        ,,06,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"QTDVEN"  ,"GIC",  "Qtde"                              ,,40,,,'LEFT',.F.,'LEFT',,05)
    TRCell():New(oSection1,"VALORTOT" ,"GIC",  RetTitle("GIC_VALTOT")             ,,35,,,'LEFT',.F.,'LEFT',,05)


    TRFunction():New(oSection1:Cell("QTDVEN")      ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
    TRFunction():New(oSection1:Cell("VALORTOT")    ,,"SUM",,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/)
    
    oSection2 := TRSection():New(oReport,"Bilhetes",{"GIC"},nil,.F.,.T.) //"Bilhetes"
    TRCell():New(oSection2,"GIC_NUMBPE" ,"GIC",  RetTitle("GIC_NUMBPE")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_VENDRJ" ,"GIC",  RetTitle("GIC_VENDRJ")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_DTVEND" ,"GIC",  RetTitle("GIC_DTVEND")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_LINHA"  ,"GIC",  RetTitle("GIC_LINHA")              ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_AGENCI" ,"GIC",  RetTitle("GIC_AGENCI")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_STATUS" ,"GIC",  RetTitle("GIC_STATUS")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)
    TRCell():New(oSection2,"GIC_CHVBPE" ,"GIC",  RetTitle("GIC_CHVBPE")             ,,,,,'LEFT',.F.,'LEFT',,,.T.)

  
    oSection1:SetPagebreack(.F.)
    
    
Return oReport


/*/{Protheus.doc} RPTPrint
Realiza impressão do relatório
@type function
@version  1.0
@author pedro.saboia
@since 31/08/2026
/*/ 
Static Function RPTPrint(oReport)
    Local oSection1  := oReport:Section(1)
    Local oSection2  := oReport:Section(2)
    Local cAlias1    := GetNextAlias()
    Local cAlias2    := ""
    Local cVendRJ    := ""
    Local cAgenci    := ""
    


    BeginSQL Alias cAlias1
        SELECT
            GIC.GIC_VENDRJ AS GIC_VENDRJ,
            GIC.GIC_AGENCI AS GIC_AGENCI,
            COUNT(*)       AS QTDVEN,
            SUM(GIC.GIC_VALTOT) AS VALORTOT
        FROM %Table:GIC% GIC
        WHERE
            GIC_FILIAL =  %xFilial:GIC%
            AND GIC_DTVEND BETWEEN %Exp:Dtos(MV_PAR01)%  AND %Exp:Dtos(MV_PAR02)%    
            AND GIC_AGENCI BETWEEN %Exp:MV_PAR03%  AND %Exp:MV_PAR04%    
            AND GIC.%notDel%
        GROUP BY GIC.GIC_VENDRJ,GIC.GIC_AGENCI
        ORDER BY QTDVEN DESC

    EndSql


    (cAlias1)->(dbGotop())

    oReport:SetMeter((cAlias1)->(LastRec()))

    IF MV_PAR05 == 2 //Sintetico
        oSection1:Init()
    ENDIF

    while (cAlias1)->(!Eof())

        IF MV_PAR05 == 1 //Analitico
            oSection1:Init()
        ENDIF
        oReport:IncMeter()

        IncProc("Imorimindo..")//"Imprimindo..."
        
        oSection1:Cell( "GIC_VENDRJ" ):SetValue( ALLTRIM((cAlias1)->GIC_VENDRJ))
        oSection1:Cell( "GIC_AGENCI" ):SetValue( ALLTRIM((cAlias1)->GIC_AGENCI))
        oSection1:Cell( "QTDVEN"     ):SetValue( (cAlias1)->QTDVEN)
        oSection1:Cell( "VALORTOT"    ):SetValue( (cAlias1)->VALORTOT) 
        
        oSection1:Printline()		

        IF MV_PAR05 == 1
            oSection2:Init()

            cAlias2 := GetNextAlias()
            cVendRJ := (cAlias1)->GIC_VENDRJ
            cAgenci := (cAlias1)->GIC_AGENCI

            BeginSQL Alias cAlias2

                SELECT 
                GIC_NUMBPE,GIC_DTVEND,GIC_LINHA,GIC_AGENCI,GIC_DTVEND,GIC_CHVBPE,GIC_STATUS,GIC_VENDRJ
                FROM %Table:GIC% GIC    
                WHERE 
                    GIC_FILIAL =  %xFilial:GIC%
                    AND GIC_DTVEND BETWEEN %Exp:Dtos(MV_PAR01)%  AND %Exp:Dtos(MV_PAR02)%    
                    AND GIC_AGENCI BETWEEN %Exp:MV_PAR03%  AND %Exp:MV_PAR04%    
                    AND GIC_AGENCI =  %Exp:cAgenci%
                    AND GIC_VENDRJ =  %Exp:cVendRJ%
                    AND GIC.%notDel% 
                ORDER BY GIC_VENDRJ

            EndSql

            while (cAlias2)->(!Eof())
                oReport:IncMeter()            

                oSection2:Cell("GIC_NUMBPE"):SetValue((cAlias2)->GIC_NUMBPE)
                oSection2:Cell("GIC_VENDRJ"):SetValue((cAlias2)->GIC_VENDRJ)
                oSection2:Cell("GIC_DTVEND"):SetValue(DTOC(STOD((cAlias2)->GIC_DTVEND)))
                oSection2:Cell("GIC_LINHA"):SetValue((cAlias2)->GIC_LINHA)
                oSection2:Cell("GIC_AGENCI"):SetValue((cAlias2)->GIC_AGENCI)

                //oSection2:Cell("GIC_NLOCOR"):SetValue(ALLTRIM(POSICIONE('GI1',1,XFILIAL('GI1')+(cAlias2)->GIC_LOCORI,'GI1_DESCRI')))
                //oSection2:Cell("GIC_NLOCDE"):SetValue(ALLTRIM(POSICIONE('GI1',1,XFILIAL('GI1')+(cAlias2)->GIC_LOCDES,'GI1_DESCRI')))
                oSection2:Cell("GIC_STATUS"):SetValue((cAlias2)->GIC_STATUS)
                oSection2:Cell("GIC_CHVBPE"):SetValue((cAlias2)->GIC_CHVBPE)

                oSection2:Printline()

                (cAlias2)->(dbskip())
            enddo

            oSection2:Finish()
            (cAlias2)->(DBCloseArea())
        ENDIF
                
        IF MV_PAR05 == 1
            oReport:ThinLine()
            oSection1:Finish()
        ENDIF

        (cAlias1)->(DBSkip())
    enddo

    IF MV_PAR05 == 2
        oSection1:Finish()
    ENDIF

    (cAlias1)->(dbCloseArea())

Return 
