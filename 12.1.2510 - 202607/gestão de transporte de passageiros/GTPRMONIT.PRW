#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPRMONIT.CH'

Static cTipoFalha  := ""

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

    If GYS->(FieldPos("GYS_REFER1")) > 0 .And. GYS->(FieldPos("GYS_AGENCI")) > 0
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
    Local cPerg     := "GTPRMONIT"
    Local cAliasGYS := GetNextAlias()

    Pergunte(cPerg,.T.)

    oReport := TReport():New("GTPRMONIT",STR0001,cPerg,{|oReport|RPTPrint(oReport,cAliasGYS,oSection1)},STR0002) //"Monitor de integração" - "Rel. de logs do monitor de integração"
    oReport:SetLandscape(.T.)

    oSection1 := TRSection():New(oReport, STR0003,{"GYS"}, NIL,.F.,.T.) //"Cabeçalho"
    oSection1:SetHeaderSection(.T.)
    TRCell():New(oSection1,"GYS_DESCRI"  ,cAliasGYS, STR0004 ,,45,,,'LEFT',.F.,'LEFT',,,.F.) //"Item"   
    TRCell():New(oSection1,"GYS_EMPRJI"  ,cAliasGYS, RetTitle("GYS_EMPRJI") ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Data"
    TRCell():New(oSection1,"GYS_DTVEND"  ,cAliasGYS, RetTitle("GYS_DTVEND") ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"Hora"
    TRCell():New(oSection1,"REFERENCIA"  ,cAliasGYS, STR0009 ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Referência"
    TRCell():New(oSection1,"GYS_AGENCI"  ,cAliasGYS, RetTitle("GYS_AGENCI") ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Referência"
    TRCell():New(oSection1,"GYS_NUMPRO"  ,cAliasGYS, RetTitle("GYS_NUMPRO") ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Referência"
    TRCell():New(oSection1,"GYS_CHVBPE"  ,cAliasGYS, RetTitle("GYS_CHVBPE") ,,,,,'LEFT',.F.,'LEFT',,,.T.) //"Referência"
    TRCell():New(oSection1,"GYS_REPORT"  ,cAliasGYS, STR0010 ,,,,,'LEFT',.T.,'LEFT',,,.T.) //"Desc. Falha"

    //TRCell():New(oSection1,"GYS_URL"     ,"GYS",  STR0005 ,,,,,'LEFT',.F.,'LEFT',,,.F.) //"URL"
    /*
    oSection2 := TRSection():New(oReport,STR0006,{"GYS"},nil,.F.,.T.) //"Falhas"
    oSection2:SetCellBorder("BOTTOM")
    oSection2:SetHeaderSection(.T.)    
    oSection2:SetTotalInLine(.F.)
    */
    
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} RPTPrint
Realiza impressão do relatório

@author SIGAGTP | João Paulo Pires
@since 10/12/2025

@type function
/*/
//-------------------------------------------------------------------    
Static Function RPTPrint(oReport,cAliasGYS,oSection)
    //Local oSection1  := oReport:Section(1)
    Local cQryRot    := ""
    
    If !Empty(Alltrim(MV_PAR03))
        cQryRot  := " AND GYS_ROTINA = '"+Alltrim(MV_PAR03)+"' "
    Endif
    cQryRot := "%"+cQryRot+"%"

    BEGIN REPORT QUERY oSection

        BeginSql Alias cAliasGYS  
            
        SELECT GYS.GYS_DESCRI,GYS.GYS_AGENCI,GYS.GYS_DTVEND,GYS.GYS_EMPRJI,GYS.GYS_NUMPRO,GYS.GYS_CHVBPE,
        GYS.GYS_DATA,
        GYS.GYS_HORA,
        GYS.GYS_URL,
        GYS.GYS_ROTINA,
        GYS.GYS_REFER1 AS REFERENCIA,
        Isnull(Cast(Cast(GYS.GYS_REPORT AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS GYS_REPORT
            FROM   %Table:GYS% GYS
            WHERE  GYS.GYS_DATA BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
        AND GYS.%NotDel%
            %Exp:cQryRot%
        ORDER BY GYS.GYS_DATA, GYS.GYS_HORA, GYS.GYS_DESCRI

        EndSql

    END REPORT QUERY oSection 

    oSection:Print()

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GtprMF3
Função responsvel pela busca das rotinas de origem para o relatório GTPRMONIT
@type Function
@author João Pires
@since 25/04/2026
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GtprMF3()
    Local oLookUp  := Nil
    Local lRet     := .T.
    Local aRetorno := {}
    Local cQryGYS  := ""        
    Local cLista   := GTPGetRules("LOGRMONIT",,,'GTPIRJ115|GTPJBPE')

    cLista := FormatIn(cLista, "|") 

    cQryGYS := " SELECT DISTINCT GYS_ROTINA, "
    cQryGYS += "      CASE "
    cQryGYS += "         WHEN GYS_ROTINA = 'GTPIRJ115' THEN 'Integração de bilhetes' "
    cQryGYS += "         WHEN GYS_ROTINA = 'GTPJBPE'   THEN 'Geração de notas de bilhetes' "
    cQryGYS += "         WHEN GYS_ROTINA = 'GTPIRJ002' THEN 'Integração de linhas' "
    cQryGYS += "         WHEN GYS_ROTINA = 'GTPIRJ006' THEN 'Integração de Agências' "
    cQryGYS += "         WHEN GYS_ROTINA = 'GTPIRJ427' THEN 'Integração de Receita/Despesa' "
    cQryGYS += "         WHEN GYS_ROTINA = 'GTPIRJ004' THEN 'Integração de Horários' "
    cQryGYS += "         WHEN GYS_ROTINA = 'GTPIRJ008' THEN 'Integração de Colaboradores' "
    cQryGYS += "         WHEN GYS_ROTINA = 'GTPIRJ001' THEN 'Integração de Localidades' "
    cQryGYS += "       END AS DESCRICAO "
    cQryGYS += "     FROM   "+RetSqlName("GYS")
    cQryGYS += "     WHERE  D_E_L_E_T_ = ' ' "
    cQryGYS += "         AND GYS_ROTINA IN  "+cLista

    cQryGYS := ChangeQuery(cQryGYS)

    oLookUp := GTPXLookUp():New(cQryGYS, {"GYS_ROTINA","DESCRICAO"})
    oLookUp:AddIndice("Cod. Falha", "GYS_ROTINA")
    oLookUp:AddIndice("Tipo Falha", "DESCRICAO")

    If oLookUp:Execute()
        lRet       := .T.
        aRetorno   := oLookUp:GetReturn()
        cTipoFalha := aRetorno[1]
    EndIf   
    FreeObj(oLookUp)

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} GtprF3R
Função responsvel pelo retorno da consulta padrão GtprMF3
@type Function
@author João Pires
@since 25/04/2026
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GtprF3R()

    Local cRet :='' 
    
    cRet :=	Alltrim(cTipoFalha)

Return cRet


