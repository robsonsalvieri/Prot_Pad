#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA096R
Relatório dos documentos de carga relacionados ao lote de provisão

@author  Guilherme A. Metzger
@since   06/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA096R()
Local oReport   := Nil

Private cAliasTmp := ""

	If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definição do relatório

@author  Guilherme A. Metzger
@since   06/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport  := Nil
Local oSection := Nil

	oReport := TReport():New("GFEA096R","Documentos de Carga do Lote de Provisão",, {|oReport| ReportPrint(oReport)}, "Apresenta os Documentos de Carga relacionados ao Lote de Provisão")
	oReport:HideParamPage()

	oSection := TRSection():New(oReport,"Documentos de Carga do Lote de Provisão",{"cAliasTmp"}, {"Documentos de Carga do Lote de Provisão"})
	oSection:SetHeaderSection(.T.)

    TRCell():New(oSection,"GXD_CODLOT","GXD",/*Nome*/         ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GXD_CODLOT })
    TRCell():New(oSection,"GWM_FILIAL","GWM",/*Nome*/         ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_FILIAL })
    TRCell():New(oSection,"GWM_CDTPDC","GWM",/*Nome*/         ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_CDTPDC })
    TRCell():New(oSection,"GWM_EMISDC","GWM",/*Nome*/         ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_EMISDC })
    TRCell():New(oSection,"GWM_SERDC" ,"GWM",/*Nome*/         ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_SERDC  })
    TRCell():New(oSection,"GWM_NRDC"  ,"GWM",/*Nome*/         ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_NRDC   })
    TRCell():New(oSection,"GWM_DTEMIS","GWM",/*Nome*/         ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_DTEMIS })
    TRCell():New(oSection,"GWM_CDTRP" ,"GWM","Cód. Transp."   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_CDTRP  })
    TRCell():New(oSection,"GU3_NMEMIT","GU3","Nome Transp."   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GU3_NMEMIT })
    TRCell():New(oSection,"GXD_NRCALC","GWM",/*Nome*/         ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GXD_NRCALC })
    TRCell():New(oSection,"GW8_VALOR" ,"GW8","Val. Doc. Carga",/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GW8_VALOR  })
    TRCell():New(oSection,"GWM_VLISS" ,"GWM","Val. ISS"       ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_VLISS  })
    TRCell():New(oSection,"GWM_VLICMS","GWM","Val. ICMS"      ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_VLICMS })
    TRCell():New(oSection,"GWM_VLPIS" ,"GWM","Val. PIS"       ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_VLPIS  })
    TRCell():New(oSection,"GWM_VLCOFI","GWM","Val. COFINS"    ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_VLCOFI })
    TRCell():New(oSection,"GWM_VLFRET","GWM","Val. Frete"     ,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| (cAliasTmp)->GWM_VLFRET })

Return oReport

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressão do relatório

@author  Guilherme A. Metzger
@since   06/03/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local oExec     := Nil
Local oSection  := oReport:Section(1)
Local lFilIgual := GXE->GXE_FILDE == GXE->GXE_FILATE

    // Aqui eu optei por utilizar CTE (Common Table Expression), para facilitar a separação de regras e leitura da consulta
    // Neste caso, a função ChangeQuery não pode ser utilizada, visto que não suporta CTEs
    cQuery := "WITH RAT AS ("
    cQuery +=     " SELECT GXD_CODLOT,"
    cQuery +=            " GWM_FILIAL,"
    cQuery +=            " GWM_CDTPDC,"
    cQuery +=            " GWM_EMISDC,"
    cQuery +=            " GWM_SERDC,"
    cQuery +=            " GWM_NRDC,"
    cQuery +=            " GWM_DTEMIS,"
    cQuery +=            " GWM_CDTRP,"
    cQuery +=            " GXD_NRCALC,"
    cQuery +=            " SUM(GWM_VLISS ) AS GWM_VLISS,"
    cQuery +=            " SUM(GWM_VLICMS) AS GWM_VLICMS,"
    cQuery +=            " SUM(GWM_VLPIS ) AS GWM_VLPIS,"
    cQuery +=            " SUM(GWM_VLCOFI) AS GWM_VLCOFI,"
    cQuery +=            " SUM(GWM_VLFRET) AS GWM_VLFRET"
    cQuery +=       " FROM "+RetSqlName("GXD")+" GXD"
    cQuery +=      " INNER JOIN "+RetSqlName("GWM")+" GWM"
    cQuery +=         " ON GWM.GWM_FILIAL = GXD.GXD_FILCAL"
    cQuery +=        " AND GWM.GWM_NRDOC  = GXD.GXD_NRCALC"
    cQuery +=        " AND GWM.GWM_TPDOC IN ('1','4')" // Apenas 1 - Cálculo Normal e 4 - Estimativa
    cQuery +=        " AND GWM.D_E_L_E_T_ = GXD.D_E_L_E_T_"
    If lFilIgual
        cQuery +=  " WHERE GXD.GXD_FILIAL = ?"
    Else
        cQuery +=  " WHERE GXD.GXD_FILIAL >= ?"
        cQuery +=    " AND GXD.GXD_FILIAL <= ?"
    EndIf
    cQuery +=        " AND GXD.GXD_CODLOT = ?"
    cQuery +=        " AND GXD.D_E_L_E_T_ = ' '"
    cQuery +=      " GROUP BY "
    cQuery +=            " GXD_CODLOT,"
    cQuery +=            " GWM_FILIAL,"
    cQuery +=            " GWM_CDTPDC,"
    cQuery +=            " GWM_EMISDC,"
    cQuery +=            " GWM_SERDC,"
    cQuery +=            " GWM_NRDC,"
    cQuery +=            " GWM_DTEMIS,"
    cQuery +=            " GWM_CDTRP,"
    cQuery +=            " GXD_NRCALC"
    cQuery += " ),"
    cQuery +=     " ITE AS ("
    cQuery +=     " SELECT GW8_FILIAL,"
    cQuery +=            " GW8_CDTPDC,"
    cQuery +=            " GW8_EMISDC,"
    cQuery +=            " GW8_SERDC,"
    cQuery +=            " GW8_NRDC,"
    cQuery +=            " SUM(GW8_VALOR) AS GW8_VALOR"
    cQuery +=       " FROM "+RetSqlName("GW8")+" GW8"
    If lFilIgual
        cQuery +=  " WHERE GW8.GW8_FILIAL = ?"
    Else
        cQuery +=  " WHERE GW8.GW8_FILIAL >= ?"
        cQuery +=    " AND GW8.GW8_FILIAL <= ?"
    EndIf
    cQuery +=        " AND GW8.D_E_L_E_T_ = ' '"
    cQuery +=        " AND EXISTS(SELECT 1"
    cQuery +=                     " FROM RAT"
    cQuery +=                    " WHERE RAT.GWM_FILIAL = GW8.GW8_FILIAL"
    cQuery +=                      " AND RAT.GWM_CDTPDC = GW8.GW8_CDTPDC"
    cQuery +=                      " AND RAT.GWM_EMISDC = GW8.GW8_EMISDC"
    cQuery +=                      " AND RAT.GWM_SERDC  = GW8.GW8_SERDC"
    cQuery +=                      " AND RAT.GWM_NRDC   = GW8.GW8_NRDC)"
    cQuery +=     " GROUP BY "
    cQuery +=           " GW8_FILIAL,"
    cQuery +=           " GW8_CDTPDC,"
    cQuery +=           " GW8_EMISDC,"
    cQuery +=           " GW8_SERDC,"
    cQuery +=           " GW8_NRDC"
    cQuery += " ) "
    cQuery += "SELECT GXD_CODLOT,"
    cQuery +=       " GWM_FILIAL,"
    cQuery +=       " GWM_CDTPDC,"
    cQuery +=       " GWM_EMISDC,"
    cQuery +=       " GWM_SERDC,"
    cQuery +=       " GWM_NRDC,"
    cQuery +=       " GWM_DTEMIS,"
    cQuery +=       " GWM_CDTRP,"
    cQuery +=       " GU3_NMEMIT,"
    cQuery +=       " GXD_NRCALC,"
    cQuery +=       " GW8_VALOR,"
    cQuery +=       " GWM_VLISS,"
    cQuery +=       " GWM_VLICMS,"
    cQuery +=       " GWM_VLPIS,"
    cQuery +=       " GWM_VLCOFI,"
    cQuery +=       " GWM_VLFRET"
    cQuery +=  " FROM RAT"
    cQuery += " INNER JOIN ITE"
    cQuery +=    " ON ITE.GW8_FILIAL = RAT.GWM_FILIAL"
    cQuery +=   " AND ITE.GW8_CDTPDC = RAT.GWM_CDTPDC"
    cQuery +=   " AND ITE.GW8_EMISDC = RAT.GWM_EMISDC"
    cQuery +=   " AND ITE.GW8_SERDC  = RAT.GWM_SERDC"
    cQuery +=   " AND ITE.GW8_NRDC	  = RAT.GWM_NRDC"
    cQuery += " INNER JOIN "+RetSqlName("GU3")+" GU3"
    cQuery +=    " ON GU3.GU3_FILIAL = ?"
    cQuery +=   " AND GU3.GU3_CDEMIT = RAT.GWM_CDTRP"
    cQuery +=   " AND GU3.D_E_L_E_T_ = ' '"
    cQuery += " ORDER BY "
    cQuery +=       " GXD_CODLOT,"
    cQuery +=       " GWM_FILIAL,"
    cQuery +=       " GWM_CDTPDC,"
    cQuery +=       " GWM_EMISDC,"
    cQuery +=       " GWM_SERDC,"
    cQuery +=       " GWM_NRDC,"
    cQuery +=       " GWM_DTEMIS,"
    cQuery +=       " GXD_NRCALC"

    oExec   := FwExecStatement():New(cQuery)

    If lFilIgual
        oExec:SetString(1,GXE->GXE_FILDE )
        oExec:SetString(2,GXE->GXE_CODLOT)
        oExec:SetString(3,GXE->GXE_FILDE )
        oExec:SetString(4,xFilial("GU3") )
    Else
        oExec:SetString(1,GXE->GXE_FILDE )
        oExec:SetString(2,GXE->GXE_FILATE)
        oExec:SetString(3,GXE->GXE_CODLOT)
        oExec:SetString(4,GXE->GXE_FILDE )
        oExec:SetString(5,GXE->GXE_FILATE)
        oExec:SetString(6,xFilial("GU3") )
    EndIf

    cAliasTmp := oExec:OpenAlias()

	oSection:Init()

	While !(cAliasTmp)->(Eof())

		oSection:PrintLine()

		(cAliasTmp)->(DbSkip())
	EndDo

	oSection:Finish()

    (cAliasTmp)->(DbCloseArea())

    oExec:Destroy()
    oExec := Nil

RestArea(aAreaAnt)
Return
