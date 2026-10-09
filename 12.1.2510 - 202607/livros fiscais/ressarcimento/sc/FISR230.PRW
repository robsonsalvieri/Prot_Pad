#Include "FISR230.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR230

Relatorio de conferencia DRCST - Demonstrativo para Apuração Mensal do Ressarcimento, 
da Restituição e da Complementação do ICMS Substituição Tributária, do Estado de Santa Catarina.

@return	Nil

@author Eduardo Vicente da Silva
@since 12/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function FISR230()
Local oReport
Local cAnoMes := ""
		
If TRepInUse() //Verifica se relatorios personalizaveis esta disponivel

	If Pergunte("FISR230",.T.)
        cAnoMes  := SubStr(mv_par01,3,4) + SubStr(mv_par01,1,2)
        
		oReport:= ReportDef(cAnoMes, mv_par02, mv_par03, mv_par04)
		oReport:PrintDialog()
	Endif	

Else
	Alert(STR0001)   //"Rotina disponível apenas em TReport (Relatório Personalizável)."
Endif

Return    

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef

Impressao do relatorio

@return Nil

@author Eduardo V. da Silva
@since 12/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cAnoMes, cProdDe, cProdAte, nTipo)
Local	oReport
Local	oSection
Local	cQuery		:= GetNextAlias()
Local 	cTitRel		:= STR0002   //"Relatório de Conferência"

oReport := TReport():New("FISR230",cTitRel,"FISR230",{|oReport| ReportPrint(oReport, oSection, cQuery, cAnoMes, cProdDe, cProdAte, nTipo)},cTitRel)
oReport:SetTotalInLine(.F.)
oReport:lHeaderVisible := .T.
//Define a orientação
oReport:SetLandScape(.T.)
//Define a saída default como Excel
oReport:SetDevice(4)

If nTipo == 1
    oSection := TRSection():New(oReport,cTitRel,{cQuery,"F1J","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
ElseIf nTipo == 2
    oSection := TRSection():New(oReport,cTitRel,{cQuery,"F1M","SA1","SA2","SB1"},/*{Array com as ordens do relatório}*/,/*Campos do SX3*/,/*Campos do SIX*/)
EndIf

oSection:lHeaderVisible := .F.
oSection:SetHeaderSection(.T.)
oSection:SetHeaderPage(.T.)
oSection:SetLinesBefore(2)

If nTipo == 1
    TRCell():New(oSection,"F1J_ANOMES"	,cQuery,STR0003,"@R 99/9999"                ,TamSx3("F1J_ANOMES")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/) //"Mês/Ano"
    TRCell():New(oSection,"F1J_PRODUT"	,cQuery,STR0004,PesqPict("F1J","F1J_PRODUT"),TamSx3("F1J_PRODUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Produto"
    TRCell():New(oSection,"F1L_VMUBST"	,cQuery,STR0005,PesqPict("F1L","F1L_VMUBST"),TamSx3("F1L_VMUBST")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr Med Uni BS ST"
    TRCell():New(oSection,"F1L2_VMUBST"	,cQuery,STR0040,PesqPict("F1L","F1L_VMUBST"),TamSx3("F1L_VMUBST")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr Med Uni BS ST"
    TRCell():New(oSection,"F1L_VMUICM"	,cQuery,STR0006,PesqPict("F1L","F1L_VMUICM"),TamSx3("F1L_VMUICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr Med Uni ICMS"
    TRCell():New(oSection,"F1L_VMUIST"	,cQuery,STR0007,PesqPict("F1L","F1L_VMUIST"),TamSx3("F1L_VMUIST")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr Med Uni ST"
    TRCell():New(oSection,"F1J_QTDVCF"	,cQuery,STR0008,PesqPict("F1J","F1J_QTDVCF"),TamSx3("F1J_QTDVCF")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Qtd Ven. C.Final"
    TRCell():New(oSection,"F1J_VLRVCF"	,cQuery,STR0009,PesqPict("F1J","F1J_VLRVCF"),TamSx3("F1J_VLRVCF")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr Ven. C.Final"
    TRCell():New(oSection,"F1J_VBSTCF"	,cQuery,STR0010,PesqPict("F1J","F1J_VBSTCF"),TamSx3("F1J_VBSTCF")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr BS ST C.Final"
    TRCell():New(oSection,"F1J_ALIQEF"	,cQuery,STR0011,PesqPict("F1J","F1J_ALIQEF"),TamSx3("F1J_ALIQEF")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Aliq. Efetiva"
    TRCell():New(oSection,"F1J_VLREST"	,cQuery,STR0012,PesqPict("F1J","F1J_VLREST"),TamSx3("F1J_VLREST")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr. Restituição"
    TRCell():New(oSection,"F1J_VLCOMP"	,cQuery,STR0013,PesqPict("F1J","F1J_VLCOMP"),TamSx3("F1J_VLCOMP")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr. Complemento"
    TRCell():New(oSection,"F1J_QTDSOE"	,cQuery,STR0014,PesqPict("F1J","F1J_QTDSOE"),TamSx3("F1J_QTDSOE")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Qtd Ven. O.Est"
    TRCell():New(oSection,"F1J_VICMOE"	,cQuery,STR0015,PesqPict("F1J","F1J_VICMOE"),TamSx3("F1J_VICMOE")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr. ICMS O.Est"
    TRCell():New(oSection,"F1J_VISTOE"	,cQuery,STR0016,PesqPict("F1J","F1J_VISTOE"),TamSx3("F1J_VISTOE")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr. ICMS ST O.Est"
    TRCell():New(oSection,"F1J_QTDSSN"	,cQuery,STR0017,PesqPict("F1J","F1J_QTDSSN"),TamSx3("F1J_QTDSSN")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Qtd Vendas S.Nac"
    TRCell():New(oSection,"F1J_VCRDSN"	,cQuery,STR0018,PesqPict("F1J","F1J_VCRDSN"),TamSx3("F1J_VCRDSN")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr. Cred. S.Nac"
    oSection:Cell("F1J_ANOMES"):lHeaderSize := .F.

ElseIf nTipo == 2
    TRCell():New(oSection,"F1M_ANOMES"	,cQuery,STR0003,"@R 99/9999"                   ,TamSx3("F1M_ANOMES")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/) //"Mês/Ano"
    TRCell():New(oSection,"F1M_PRODUT"	,cQuery,STR0004,PesqPict("F1M","F1M_PRODUT")   ,TamSx3("F1M_PRODUT")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Produto"
    TRCell():New(oSection,"F1M_DTMOV"	,cQuery,STR0019,PesqPict("F1M","F1M_DTMOV")    ,TamSx3("F1M_DTMOV")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Data Movto"
    TRCell():New(oSection,"TIPOMOV"	    ,cQuery,STR0020,                               ,                       ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Tipo Movto"
    TRCell():New(oSection,"F1M_NFISCA"	,cQuery,STR0021,PesqPict("F1M","F1M_NFISCA")   ,TamSx3("F1M_NFISCA")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Documento"
    TRCell():New(oSection,"F1M_SERIE"	,cQuery,STR0022,PesqPict("F1M","F1M_SERIE")    ,TamSx3("F1M_SERIE")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Série"
    TRCell():New(oSection,"F1M_ITEM"	,cQuery,STR0023,PesqPict("F1M","F1M_ITEM")     ,TamSx3("F1M_ITEM")[1]  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Item"
    TRCell():New(oSection,"F1M_PARTIC"	,cQuery,STR0024,PesqPict("F1M","F1M_PARTIC")   ,TamSx3("F1M_PARTIC")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Participante"
    TRCell():New(oSection,"F1M_LOJA"	,cQuery,STR0025,PesqPict("F1M","F1M_LOJA")     ,TamSx3("F1M_LOJA")[1]  ,/*lPixel*/,/*{|| code-block de impressao }*/) //"Loja"
    TRCell():New(oSection,"F1M_QTDMOV"	,cQuery,STR0026,PesqPict("F1M","F1M_QTDMOV")   ,TamSx3("F1M_QTDMOV")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Qtde"
    TRCell():New(oSection,"F1M_VLRCON"	,cQuery,STR0027,PesqPict("F1M","F1M_VLRCON")   ,TamSx3("F1M_VLRCON")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr Contabil"
    TRCell():New(oSection,"F1M_BASICM"	,cQuery,STR0028,PesqPict("F1M","F1M_BASICM")   ,TamSx3("F1M_BASICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Base ICMS"
    TRCell():New(oSection,"F1M_ALQICM"	,cQuery,STR0029,PesqPict("F1M","F1M_ALQICM")   ,TamSx3("F1M_ALQICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Aliq. ICMS"
    TRCell():New(oSection,"F1M_VLRICM"	,cQuery,STR0030,PesqPict("F1M","F1M_VLRICM")   ,TamSx3("F1M_VLRICM")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr ICMS"
    TRCell():New(oSection,"F1M_BASIST"	,cQuery,STR0031,PesqPict("F1M","F1M_BASIST")   ,TamSx3("F1M_BASIST")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Base ICMS ST"
    TRCell():New(oSection,"F1M_ALQIST"	,cQuery,STR0032,PesqPict("F1M","F1M_ALQIST")   ,TamSx3("F1M_ALQIST")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Aliq. ICMS ST"
    TRCell():New(oSection,"F1M_VLRIST"	,cQuery,STR0033,PesqPict("F1M","F1M_VLRIST")   ,TamSx3("F1M_VLRIST")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr ICMS ST"
    TRCell():New(oSection,"F1M_VCRDSN"	,cQuery,STR0034,PesqPict("F1M","F1M_VCRDSN")   ,TamSx3("F1M_VCRDSN")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Vlr Cred. SN"
    TRCell():New(oSection,"F1M_INDSAI"	,cQuery,STR0035,PesqPict("F1M","F1M_INDSAI")   ,TamSx3("F1M_INDSAI")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Ind. Saída"
    TRCell():New(oSection,"F1M_CODRES"	,cQuery,STR0041,PesqPict("F1M","F1M_CODRES")   ,TamSx3("F1M_CODRES")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Resp Ret ST Entr"
    TRCell():New(oSection,"F1M_TAGRET"	,cQuery,STR0042,PesqPict("F1M","F1M_TAGRET")   ,TamSx3("F1M_TAGRET")[1],/*lPixel*/,/*{|| code-block de impressao }*/) //"Inf. ICMS Cob Ant"

    oSection:Cell("F1M_ANOMES"):lHeaderSize := .F.
    oSection:Cell("F1M_NFISCA"):lHeaderSize := .F.
    oSection:Cell("F1M_ITEM"):lHeaderSize   := .F.

EndIf

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint

Impressao do relatorio

@return Nil

@author Eduardo Vicente da Silva
@since 12/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, oSection, cQuery, cAnoMes, cProdDe, cProdAte, nTipo)

Local cSelect	 := ""
Local cFrom      := ""
Local cWhere     := ""
Local cOrder     := ""
Local cMesAno    := "" 
Local lF1L2121   := F1L->(FieldPos("F1L_QTDVLM")) > 0 .And. F1L->(FieldPos("F1L_CODREG")) > 0
Local lF1MTagRet := F1M->(FieldPos("F1M_TAGRET")) > 0

If nTipo == 1
    cSelect := "F1J.F1J_ANOMES, F1J.F1J_PRODUT, F1J.F1J_QTDVCF, F1J.F1J_VLRVCF, F1J.F1J_VMUVCF, F1J.F1J_VBSTCF, F1J.F1J_ALIQEF, F1J.F1J_VLREST, F1J.F1J_VLCOMP, F1J.F1J_QTDSOE, "
    cSelect += "F1J.F1J_VICMOE, F1J.F1J_VISTOE, F1J.F1J_QTDSSN, F1J.F1J_VCRDSN, ISNULL(F1L.F1L_VMUBST,0) F1L_VMUBST"+Iif(lF1L2121, ", ISNULL(F1L2.F1L_VMUBST,0)", ", 0")+" F1L2_VMUBST, ISNULL(F1L.F1L_VMUICM,0) F1L_VMUICM, ISNULL(F1L.F1L_VMUIST,0) F1L_VMUIST "
    cFrom   := RetSqlName("F1J") + " F1J "
    cFrom   += "LEFT OUTER JOIN " + RetSqlName("F1L") + " F1L ON(F1L.F1L_FILIAL = '" + xFilial("F1L") + "' AND F1L.F1L_IDAPUR = F1J.F1J_IDAPUR  AND F1L.F1L_PRODUT = F1J.F1J_PRODUT "+Iif(lF1L2121, "AND F1L.F1L_CODREG IN ('','2120')", "")+" AND F1L.D_E_L_E_T_ = ' ') "
    If lF1L2121
        cFrom += "LEFT OUTER JOIN " + RetSqlName("F1L") + " F1L2 ON (F1L2.F1L_FILIAL = '" + xFilial("F1L") + "' AND F1L2.F1L_IDAPUR = F1J.F1J_IDAPUR  AND F1L2.F1L_PRODUT = F1J.F1J_PRODUT AND F1L2.F1L_CODREG = '2121' AND F1L2.D_E_L_E_T_ = ' ') "
    EndIf
    cWhere  := "F1J.F1J_FILIAL = '" + xFilial("F1J") + "' AND "
    cWhere  += "F1J.F1J_ANOMES = '" + cAnoMes + "' AND "
    cWhere  += "F1J.F1J_PRODUT BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' AND "
    cWhere  += "F1J.D_E_L_E_T_ = ' ' "
    cOrder  := "F1J.F1J_PRODUT"

ElseIf nTipo == 2
    cSelect := "F1M.F1M_ANOMES, F1M.F1M_PRODUT, F1M.F1M_DTMOV, F1M.F1M_TPMOV, F1M.F1M_INDOP, F1M.F1M_NFISCA, F1M.F1M_SERIE, F1M.F1M_ITEM, F1M.F1M_PARTIC, F1M.F1M_LOJA, F1M.F1M_QTDMOV, F1M.F1M_UNIDAD, F1M.F1M_FATCON, "
    cSelect += "F1M.F1M_QTDCON, F1M.F1M_VLRCON, F1M.F1M_BASICM, F1M.F1M_ALQICM, F1M.F1M_VLRICM, F1M.F1M_BASIST, F1M.F1M_ALQIST, F1M.F1M_VLRIST, F1M.F1M_VCRDSN, F1M_INDSAI, F1M.F1M_ORDEM, F1M_CODRES "+Iif(lF1MTagRet, ", F1M_TAGRET", ",' '")+" F1M_TAGRET"
    cFrom   := RetSqlName("F1M") + " F1M "
    cWhere  := "F1M.F1M_FILIAL = '" + xFilial("F1M") + "' AND "
    cWhere  += "F1M.F1M_ANOMES = '" + cAnoMes + "' AND "
    cWhere  += "F1M.F1M_PRODUT BETWEEN '" + cProdDe + "' AND '" + cProdAte + "' AND "
    cWhere  += "F1M.D_E_L_E_T_ = ' ' "
    cOrder  := "F1M.F1M_ANOMES,F1M.F1M_PRODUT,F1M.F1M_ORDEM "
EndIf

cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + "%"
cOrder	:= '%' + cOrder  + '%'

oSection:BeginQuery()

BeginSql Alias cQuery
    
    SELECT %Exp:cSelect%
	FROM  %Exp:cFrom% 
	WHERE %Exp:cWhere%
    Order by %Exp:cOrder%

EndSQL

oSection:EndQuery()

oReport:SetMeter((cQuery)->(RecCount()))

//-- Necessario para que o usuario possa acrescentar qualquer coluna das tabelas que compoem a secao.

If nTipo == 1
    TRPosition():New(oSection,"SB1",1,{||xFilial("SB1")+(cQuery)->(F1J_PRODUT)})
ElseIf nTipo == 2
    TRPosition():New(oSection,"SA1",1,{||xFilial("SA1")+(cQuery)->(F1M_PARTIC+F1M_LOJA)})
    TRPosition():New(oSection,"SA2",1,{||xFilial("SA2")+(cQuery)->(F1M_PARTIC+F1M_LOJA)})
    TRPosition():New(oSection,"SB1",1,{||xFilial("SB1")+(cQuery)->(F1M_PRODUT)})
EndIf

oReport:Section(1):Init()

While !oReport:Cancel() .And. !(cQuery)->(Eof())

    If nTipo == 1

        cMesAno := SubStr((cQuery)->F1J_ANOMES,5,2) + "/" + SubStr((cQuery)->F1J_ANOMES,1,4)

        oSection:Cell("F1J_ANOMES"):SetValue(cMesAno)

    Else
        cMesAno := SubStr((cQuery)->F1M_ANOMES,5,2) + "/" + SubStr((cQuery)->F1M_ANOMES,1,4)
        
        If (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '0'
            cTipoMov := STR0036 //"Entrada"
        ElseIf (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '0'
            cTipoMov := STR0037 //"Saída"
        ElseIf (cQuery)->F1M_TPMOV == 'E' .And. (cQuery)->F1M_INDOP == '1'    
            cTipoMov := STR0038 //"Dev. Saída"
        ElseIf (cQuery)->F1M_TPMOV == 'S' .And. (cQuery)->F1M_INDOP == '1'
            cTipoMov := STR0039 //"Dev. Entrada"
        EndIf

        oSection:Cell("F1M_ANOMES"):SetValue(cMesAno)
        oSection:Cell("TIPOMOV"):SetValue(cTipoMov)

    EndIf

	oReport:Section(1):PrintLine()
				
	(cQuery)->(dbSkip())
	oReport:IncMeter()
EndDo

(cQuery)->(dbCloseArea())

oReport:Section(1):Finish()

Return
