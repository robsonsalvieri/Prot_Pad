#include "protheus.ch"
#include "report.ch"
#include "TECR986.CH"
#include "RPTDEF.CH"
#include "FWPrintSetup.ch"

//--------------------------------------------------------------------------------
/*/{Protheus.doc} TECR986

@description Relatorio de Orçamentos em Revisao
@author Flavio Vicco
@since  15/06/2022
/*/
//--------------------------------------------------------------------------------
Function TECR986(cPdfRel)
Local oReport

Default cPdfRel := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Orçamento De? ?                                             ³
//³ MV_PAR02 : Orçamento ate ?                                             ³
//³ MV_PAR03 : Cliente De ?                                                ³
//³ MV_PAR04 : Loja De ?                                                   ³
//³ MV_PAR05 : Cliente ate ?                                               ³
//³ MV_PAR06 : Loja Até ?                                                  ³
//³ MV_PAR07 : Filial ?                                                    ³
//³ MV_PAR08 : Exibe Item Extra?                                           ³
//³ MV_PAR09 : Data De?                                                    ³
//³ MV_PAR10 : Data Até?                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oReport := ReportDef(cPdfRel)
If Valtype( oReport ) == "O"
    If !Empty(cPdfRel)
        oReport:setFile(cPdfRel)
        oReport:cFile := cPdfRel
        oReport:lParamPage := .F.
        oReport:nRemoteType := NO_REMOTE
        oReport:nDevice := 6
        oReport:SetEnvironment(1)
        oReport:SetViewPDF(.F.)
        oReport:Print()
    Else
    	If !Empty(oReport:uParam)
		    Pergunte(oReport:uParam,.F.)
	    EndIf	
        oReport:PrintDialog()
    EndIf
EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
@description Monta as definições do relatorio de Orçamento
@author Flavio Vicco
@since  15/05/2023
/*/
//--------------------------------------------------------------------------------
Static Function ReportDef(cPdfRel)
Local oReport
Local oTFJ
Local oTFL
Local oTFF
Local oTFG
Local oTFH 
Local oABP
Local oTFU
Local lOrcPrc := SuperGetMv("MV_ORCPRC",,.F.)
Local cAlias2 := GetNextAlias()
Local cAlias3 := GetNextAlias()
Local cAlias4 := GetNextAlias()
Local cAlias5 := GetNextAlias()
Local cAlias8 := GetNextAlias()
Local cAlias9 := GetNextAlias()
Local aFldTFF := {"TFF_QTDVEN","TFF_PERINI","TFF_PERFIM","TFF_ESCALA","TFF_TURNO"}
Local aFldTFG := {"TFG_QTDVEN","TFG_PERINI","TFG_PERFIM"}
Local aFldTFH := {"TFH_QTDVEN","TFH_PERINI","TFH_PERFIM"}
Local aFldTXP := {"TXP_QTDVEN"}
Local aFldTXQ := {"TXQ_QTDVEN"}
Local cPerg   := "TECR986"

Default cPdfRel := ""

oReport := TReport():New("TECR986",STR0001,cPerg,{|oReport| PrintReport(oReport,cAlias2,cAlias3,cAlias4,cAlias5,cAlias8,cAlias9)},STR0001) //"Relatório de Revisão de Orçamentos"
oReport:DisableOrientation()
oReport:SetLandScape()

oTFJ := TRSection():New(oReport,FwSX2Util():GetX2Name("TFJ"),{"TFJ","SA1"})
TRCell():New(oTFJ,"TFJ_FILIAL", "TFJ", FWX3Titulo("TFJ_FILIAL"),,,,,,,,,,,,,.T.)
TRCell():New(oTFJ,"TFJ_CODIGO", "TFJ", AllTrim(FWSX3Util():GetDescription("TFJ_CODIGO")),,,,,,,,,,,,,.T.)
TRCell():New(oTFJ,"TFJ_CODENT", "TFJ", FWX3Titulo("TFJ_CODENT"),,,,,,,,,,,,,.T.)
TRCell():New(oTFJ,"TFJ_LOJA"  , "TFJ", FWX3Titulo("TFJ_LOJA"),,,,,,,,,,,,,.T.)
TRCell():New(oTFJ,"A1_NOME"   , "SA1", FWX3Titulo("A1_NOME"),,,,,,,,,,,,,.T.)

oTFL := TRSection():New(oTFJ,FwSX2Util():GetX2Name("ABS"),{"TFL","ABS"})
oTFL:SetLeftMargin(05)
TRCell():New(oTFL,"TFL_LOCAL" , "TFL", FWX3Titulo("TFL_LOCAL") ,,,,,,,,,,,,,.T.)
TRCell():New(oTFL,"ABS_DESCRI", "ABS", FWX3Titulo("ABS_DESCRI"),,,,,,,,,,,,,.T.)
TRCell():New(oTFL,"TFL_DTINI" , "TFL", FWX3Titulo("TFL_DTINI") ,,,,,,,,,,,,,.T.)
TRCell():New(oTFL,"TFL_DTFIM" , "TFL", FWX3Titulo("TFL_DTFIM") ,,,,,,,,,,,,,.T.)
TRCell():New(oTFL,"TFL_TOTRH" , "TFL", FWX3Titulo("TFL_TOTRH") ,,,,,,,,,,,,,.T.)
TRCell():New(oTFL,"TFL_TOTMI" , "TFL", FWX3Titulo("TFL_TOTMI") ,,,,,,,,,,,,,.T.)
TRCell():New(oTFL,"TFL_TOTMC" , "TFL", FWX3Titulo("TFL_TOTMC") ,,,,,,,,,,,,,.T.)

oTFF := TRSection():New(oTFL,FwSX2Util():GetX2Name("TFF"),{"TFF","SRJ","SR6"})
oTFF:SetLeftMargin(10)
TRCell():New(oTFF,"TFF_ITEM"  , "TFF", FWX3Titulo("TFF_ITEM")  ,,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"TFF_PRODUT", "TFF", FWX3Titulo("TFF_PRODUT"),,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"B1_DESC"   , "SB1", FWX3Titulo("TFF_DESCRI"),,,,{||At982RetPrd((cAlias3)->TFF_PRODUT)},,,,,,,,,.T.)
TRCell():New(oTFF,"TFF_QTDVEN", "TFF", FWX3Titulo("TFF_QTDVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"TFF_PRCVEN", "TFF", FWX3Titulo("TFF_PRCVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"TFF_PERINI", "TFF", FWX3Titulo("TFF_PERINI"),,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"TFF_PERFIM", "TFF", FWX3Titulo("TFF_PERFIM"),,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"RJ_DESC"   , "SRJ", FWX3Titulo("RJ_FUNCAO") ,,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"TDW_DESC"  , "TDW", FWX3Titulo("TDW_DESC")  ,,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"R6_DESC"   , "SR6", FWX3Titulo("R6_TURNO")  ,,,,,,,,,,,,,.T.)
TRCell():New(oTFF,"OBSERV"    , ""   , STR0002,,99,,{||At982RetObs(cAlias3,aFldTFF)},,,,,,.T.) //"Alterações"

oTFG := TRSection():New(Iif(lOrcPrc,oTFL,oTFF),FwSX2Util():GetX2Name("TFG"),{"TFG"})
oTFG:SetLeftMargin(Iif(lOrcPrc,10,15))
TRCell():New(oTFG,"TFG_ITEM"  , "TFG", STR0003,,,,,,,,,,,,,.T.) //"Item MI"
TRCell():New(oTFG,"TFG_PRODUT", "TFG", FWX3Titulo("TFG_PRODUT"),,,,,,,,,,,,,.T.)
TRCell():New(oTFG,"B1_DESC"   , "SB1", FWX3Titulo("TFG_DESCRI"),,,,{||At982RetPrd((cAlias4)->TFG_PRODUT)},,,,,,,,,.T.)
TRCell():New(oTFG,"TFG_QTDVEN", "TFG", FWX3Titulo("TFG_QTDVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTFG,"TFG_PRCVEN", "TFG", FWX3Titulo("TFG_PRCVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTFG,"TFG_PERINI", "TFG", FWX3Titulo("TFG_PERINI"),,,,,,,,,,,,,.T.)
TRCell():New(oTFG,"TFG_PERFIM", "TFG", FWX3Titulo("TFG_PERFIM"),,,,,,,,,,,,,.T.)
TRCell():New(oTFG,"OBSERV"    , ""   , STR0002,,99,,{||At982RetObs(cAlias4,aFldTFG)},,,,,,.T.) //"Alterações"

oTFH := TRSection():New(Iif(lOrcPrc,oTFL,oTFF),FwSX2Util():GetX2Name("TFH"),{"TFH"})
oTFH:SetLeftMargin(Iif(lOrcPrc,10,15))
TRCell():New(oTFH,"TFH_ITEM"  , "TFH", STR0004,,,,,,,,,,,,,.T.) //"Item MC"
TRCell():New(oTFH,"TFH_PRODUT", "TFH", FWX3Titulo("TFH_PRODUT"),,,,,,,,,,,,,.T.)
TRCell():New(oTFH,"B1_DESC"   , "SB1", FWX3Titulo("TFH_DESCRI"),,,,{||At982RetPrd((cAlias5)->TFH_PRODUT)},,,,,,,,,.T.)
TRCell():New(oTFH,"TFH_QTDVEN", "TFH", FWX3Titulo("TFH_QTDVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTFH,"TFH_PRCVEN", "TFH", FWX3Titulo("TFH_PRCVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTFH,"TFH_PERINI", "TFH", FWX3Titulo("TFH_PERINI"),,,,,,,,,,,,,.T.)
TRCell():New(oTFH,"TFH_PERFIM", "TFH", FWX3Titulo("TFH_PERFIM"),,,,,,,,,,,,,.T.)
TRCell():New(oTFH,"OBSERV"    , ""   , STR0002,,99,,{||At982RetObs(cAlias5,aFldTFH)},,,,,,.T.) //"Alterações"

oABP := TRSection():New(oTFF,FwSX2Util():GetX2Name("SRV"),{"ABP","SRV"})
oABP:SetLeftMargin(15)
TRCell():New(oABP,"ABP_ITEM"  , "ABP", STR0005,,,,,,,,,,,,,.T.) //"Item Verba"
TRCell():New(oABP,"ABP_BENEFI", "ABP", STR0006,,,,,,,,,,,,,.T.) //"Benefício"
TRCell():New(oABP,"ABP_VALOR" , "ABP", STR0007,,,,,,,,,,,,,.T.) //"Valor"
TRCell():New(oABP,"ABP_VERBA" , "ABP", STR0008,,,,,,,,,,,,,.T.) //"Cód. Verba"
TRCell():New(oABP,"RV_DESC"   , "ABP", STR0009,,,,,,,,,,,,,.T.) //"Verba"

oTFU := TRSection():New(oTFF,STR0010,{"TFU","ABN"}) //"Hora Extra"
oTFU:SetLeftMargin(15)
TRCell():New(oTFU,"TFU_CODABN", "TFU", STR0011,,,,,,,,,,,,,.T.) //"Cód. Hora"
TRCell():New(oTFU,"ABN_DESC"  , "ABN", STR0012,,,,,,,,,,,,,.T.) //"Desc. Motivo"
TRCell():New(oTFU,"TFU_VALOR" , "TFU", STR0007,,,,,,,,,,,,,.T.) //"Valor"

oTXP := TRSection():New(oTFF,FwSX2Util():GetX2Name("TXP"),{"TXP"})
oTXP:SetLeftMargin(15)
TRCell():New(oTXP,"TXP_CODUNI", "TXP", FWX3Titulo("TXP_CODUNI"),,,,,,,,,,,,,.T.)
TRCell():New(oTXP,"B1_DESC"   , "SB1", FWX3Titulo("TXP_DSCUNI"),,,,{||At982RetPrd((cAlias8)->TXP_CODUNI)},,,,,,,,,.T.)
TRCell():New(oTXP,"TXP_QTDVEN", "TXP", FWX3Titulo("TXP_QTDVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTXP,"TXP_PRCVEN", "TXP", FWX3Titulo("TXP_PRCVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTXP,"OBSERV"    , ""   , STR0002,,99,,{||At982RetObs(cAlias8,aFldTXP)},,,,,,.T.) //"Alterações"

oTXQ := TRSection():New(oTFF,FwSX2Util():GetX2Name("TXQ"),{"TXQ"})
oTXQ:SetLeftMargin(15)
TRCell():New(oTXQ,"TXQ_CODPRD", "TXQ", STR0013,,,,,,,,,,,,,.T.) //"Cod. Armamento"
TRCell():New(oTXQ,"B1_DESC"   , "SB1", FWX3Titulo("TXQ_DSCPRD"),,,,{||At982RetPrd((cAlias9)->TXQ_CODPRD)},,,,,,,,,.T.)
TRCell():New(oTXQ,"TXQ_QTDVEN", "TXQ", FWX3Titulo("TXQ_QTDVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTXQ,"TXQ_PRCVEN", "TXQ", FWX3Titulo("TXQ_PRCVEN"),,,,,,,,,,,,,.T.)
TRCell():New(oTXQ,"OBSERV"    , ""   , STR0002,,99,,{||At982RetObs(cAlias9,aFldTXQ)},,,,,,.T.) //"Alterações"

If !Empty(cPdfRel)
    oTFL:Cell("TFL_TOTRH"):Disable()
    oTFL:Cell("TFL_TOTMI"):Disable()
    oTFL:Cell("TFL_TOTMC"):Disable()
    oTFF:Cell("TFF_PRCVEN"):Disable()
    oTFG:Cell("TFG_PRCVEN"):Disable()
    oTFH:Cell("TFH_PRCVEN"):Disable()
    oTXP:Cell("TXP_PRCVEN"):Disable()
    oTXQ:Cell("TXQ_PRCVEN"):Disable()
    oTFU:Cell("TFU_VALOR"):Disable()
    oABP:Cell("ABP_VALOR"):Disable()
EndIf

Return oReport
 
//--------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
@description Monta query para exibir no relatorio.
@author Flavio Vicco
@since  15/05/2023
/*/
//--------------------------------------------------------------------------------
Static Function PrintReport(oReport,cAlias2,cAlias3,cAlias4,cAlias5,cAlias8,cAlias9)
Local lOrcPrc   := SuperGetMv("MV_ORCPRC",,.F.)
Local lHasOrcSmp := HasOrcSimp()
Local lOrcSimp  := lHasOrcSmp .And. SuperGetMv("MV_ORCSIMP",,"2") == "1"
Local cXfilTFJ  :=  " = '" + xFilial("TFJ", cFilAnt) +"'"   
Local cFiSA1TFJ := FWJoinFilial("SA1","TFJ","SA1","TFJ",.T.)
Local cFiSA1AD1 := FWJoinFilial("SA1","AD1","SA1","AD1",.T.)
Local cFiABSTFL := FWJoinFilial("ABS","TFL","ABS","TFL",.T.)
Local cFiSRJTFF := FWJoinFilial("SRJ","TFF","SRJ","TFF",.T.)
Local cFiSR6TFF := FWJoinFilial("SR6","TFF","SR6","TFF",.T.)
Local cFiTDWTFF := FWJoinFilial("TDW","TFF","TDW","TFF",.T.)
Local cFiSRVABP := FWJoinFilial("SRV","ABP","SRV","ABP",.T.)
Local cFiABNTFU := FWJoinFilial("ABN","TFU","ABN","TFU",.T.)
Local cAlias1   := GetNextAlias()
Local cAlias6   := GetNextAlias()
Local cAlias7   := GetNextAlias()
Local cQuery    := ""
Local cQueryTFJ := ""
Local cQueryTFL := ""
Local cOrcSimp  := ""
Local cMVTFF    := ""
Local cMVTFG    := ""
Local cMVTFH    := ""
Local nX        := 0
Local aFilsPAR07  := {}
Local cValMVPAR07 := ""

Local oTFJ := oReport:Section(1)
Local oTFL := oReport:Section(1):Section(1)
Local oTFF := oReport:Section(1):Section(1):Section(1)
Local oTFG
Local oTFH
Local oABP
Local oTFU
Local oTXP
Local oTXQ

If !lOrcPrc
    oTFG := oReport:Section(1):Section(1):Section(1):Section(1)
    oTFH := oReport:Section(1):Section(1):Section(1):Section(2)
    oABP := oReport:Section(1):Section(1):Section(1):Section(3)
    oTFU := oReport:Section(1):Section(1):Section(1):Section(4)
    oTXP := oReport:Section(1):Section(1):Section(1):Section(5)
    oTXQ := oReport:Section(1):Section(1):Section(1):Section(6)
Else
    oTFG := oReport:Section(1):Section(1):Section(1)
    oTFH := oReport:Section(1):Section(1):Section(2)
    oABP := oReport:Section(1):Section(1):Section(1):Section(1)
    oTFU := oReport:Section(1):Section(1):Section(1):Section(2)
    oTXP := oReport:Section(1):Section(1):Section(1):Section(3)
    oTXQ := oReport:Section(1):Section(1):Section(1):Section(4)
EndIf

MakeSqlExp("TECR986")

If !Empty(MV_PAR07)
    cXfilTFJ    := ""    
	cValMVPAR07 := STRTRAN(MV_PAR07, "TFJ_FILIAL")
	cValMVPAR07 := REPLACE(cValMVPAR07, " IN")
	cValMVPAR07 := REPLACE(cValMVPAR07, "(")
	cValMVPAR07 := REPLACE(cValMVPAR07, ")")
	cValMVPAR07 := REPLACE(cValMVPAR07, "'")
	aFilsPAR07 := StrTokArr(cValMVPAR07,",")
	For nX := 1 To LEN(aFilsPAR07)
		If nX == 1
			cXfilTFJ += " IN ("
		EndIf
		cXfilTFJ += "'" + xFilial("TFJ", aFilsPAR07[nX] )
		If nX >= 1 .AND. nX < LEN(aFilsPAR07)
			cXfilTFJ +=  "',"
		EndIf
		If nX == LEN(aFilsPAR07)
			cXfilTFJ += " ') "
		EndIf
	Next nX   
EndIf

If !lOrcSimp
    cQuery += " LEFT JOIN " + RetSqlName("ADY") + " ADY"
    cQuery += " ON ADY.ADY_FILIAL = TFJ.TFJ_FILIAL AND "
    cQuery += " ADY.D_E_L_E_T_ = ' ' AND "

    cQuery += " TFJ.TFJ_PROPOS = ADY.ADY_PROPOS AND "
    cQuery += " TFJ.TFJ_PREVIS = ADY.ADY_PREVIS AND "
    cQuery += " TFJ.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("AD1") + " AD1 "
    cQuery += " ON AD1.AD1_FILIAL = ADY.ADY_FILIAL AND "
    cQuery += " AD1.AD1_NROPOR = ADY.ADY_OPORTU  AND "
    cQuery += " AD1.AD1_REVISA = ADY.ADY_REVISA  AND "
    cQuery += " AD1.D_E_L_E_T_ = ' ' "

    cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON " + cFiSA1AD1 + " AND "
	cQuery += " SA1.A1_COD = AD1.AD1_CODCLI AND "
	cQuery += " SA1.A1_LOJA = AD1.AD1_LOJCLI AND "
	cQuery += " SA1.D_E_L_E_T_ = ' ' "

    cOrcSimp += " ((AD1.AD1_DTINI <= '"+DTOS(mv_par09)+"' OR AD1.AD1_DTINI BETWEEN '"+DTOS(mv_par09)+"'AND '"+DTOS(mv_par10)+"')"
    cOrcSimp += " AND ( AD1.AD1_DTFIM >= '"+DTOS(mv_par10)+"' OR AD1.AD1_DTFIM BETWEEN '"+DTOS(mv_par09)+"'AND '"+DTOS(mv_par10)+"') OR AD1.AD1_DTINI = '"+ '' + "' OR AD1.AD1_DTFIM = '"+ '' + "')"
Else
    cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON " + cFiSA1TFJ + " AND "
	cQuery += " SA1.D_E_L_E_T_ = ' '  AND "
	cQuery += " SA1.A1_COD = TFJ.TFJ_CODENT AND "
	cQuery += " SA1.A1_LOJA = TFJ.TFJ_LOJA "

    cOrcSimp := " TFJ.TFJ_DATA >= '" +DTOS(mv_par09) + "' AND TFJ.TFJ_DATA <= '" +DTOS(mv_par10)+"'"
EndIf 

cQueryTFJ := " AND EXISTS ( SELECT 1  FROM " + RetSqlName('TFL') + " TFLSUB"
cQueryTFJ += " LEFT JOIN " + RetSqlName('TFF') + " TFFSUB"
cQueryTFJ += " ON TFFSUB.TFF_FILIAL = TFLSUB.TFL_FILIAL"
cQueryTFJ += " AND TFFSUB.TFF_CODPAI = TFLSUB.TFL_CODIGO"
cQueryTFJ += " AND TFFSUB.D_E_L_E_T_= ' ' "

If lOrcprc            
    cQueryTFJ += " LEFT JOIN " + RetSqlName('TFG') + " TFGSUB"
    cQueryTFJ += " ON TFGSUB.TFG_FILIAL = TFLSUB.TFL_FILIAL"
    cQueryTFJ += " AND TFGSUB.TFG_CODPAI = TFLSUB.TFL_CODIGO"
    cQueryTFJ += " AND TFGSUB.D_E_L_E_T_= ' ' " 			
        
    cQueryTFJ += " LEFT JOIN " + RetSqlName('TFH') + " TFHSUB"
    cQueryTFJ += " ON TFHSUB.TFH_FILIAL = TFLSUB.TFL_FILIAL"
    cQueryTFJ += " AND TFHSUB.TFH_CODPAI = TFLSUB.TFL_CODIGO"
    cQueryTFJ += " AND TFHSUB.D_E_L_E_T_= ' ' " 		
Else		            
    cQueryTFJ += " LEFT JOIN " + RetSqlName('TFG') + " TFGSUB"
    cQueryTFJ += " ON TFGSUB.TFG_FILIAL = TFFSUB.TFF_FILIAL"
    cQueryTFJ += " AND TFGSUB.TFG_CODPAI = TFFSUB.TFF_COD"
    cQueryTFJ += " AND TFGSUB.D_E_L_E_T_= ' ' " 			
        
    cQueryTFJ += " LEFT JOIN " + RetSqlName('TFH') + " TFHSUB"
    cQueryTFJ += " ON TFHSUB.TFH_FILIAL = TFFSUB.TFF_FILIAL"
    cQueryTFJ += " AND TFHSUB.TFH_CODPAI = TFFSUB.TFF_COD"
    cQueryTFJ += " AND TFHSUB.D_E_L_E_T_= ' ' " 		
EndIf

cQueryTFL := cQueryTFJ
            
cQueryTFJ += " WHERE TFJ.TFJ_FILIAL = TFLSUB.TFL_FILIAL"
cQueryTFJ += " AND TFJ.TFJ_CODIGO = TFLSUB.TFL_CODPAI"

cQueryTFL += " WHERE TFL.TFL_FILIAL = TFFSUB.TFF_FILIAL"
cQueryTFL += " AND TFL.TFL_CODIGO = TFFSUB.TFF_CODPAI"

If MV_PAR08 == 1
    cMVTFF := "(TFF.TFF_COBCTR IS NULL OR TFF.TFF_COBCTR IN ('','1','2')) "
    cMVTFG := "(TFG.TFG_COBCTR IS NULL OR TFG.TFG_COBCTR IN ('','1','2')) "
    cMVTFH := "(TFH.TFH_COBCTR IS NULL OR TFH.TFH_COBCTR IN ('','1','2')) "

    cQueryTFJ += " AND ((TFFSUB.TFF_COBCTR IS NULL OR TFFSUB.TFF_COBCTR IN ('','1','2'))"
    cQueryTFJ += " OR (TFGSUB.TFG_COBCTR IS NULL OR TFGSUB.TFG_COBCTR IN ('','1','2'))"
    cQueryTFJ += " OR (TFHSUB.TFH_COBCTR IS NULL OR TFHSUB.TFH_COBCTR IN ('','1','2')))"
    cQueryTFJ += " AND TFLSUB.D_E_L_E_T_= ' ' )"

    cQueryTFL += " AND ((TFFSUB.TFF_COBCTR IS NULL OR TFFSUB.TFF_COBCTR IN ('','1','2'))"
    cQueryTFL += " OR (TFGSUB.TFG_COBCTR IS NULL OR TFGSUB.TFG_COBCTR IN ('','1','2'))"
    cQueryTFL += " OR (TFHSUB.TFH_COBCTR IS NULL OR TFHSUB.TFH_COBCTR IN ('','1','2')))"
    cQueryTFL += " AND TFLSUB.D_E_L_E_T_= ' ' )"

ElseIf MV_PAR08 == 2
    cMVTFF := "(TFF.TFF_COBCTR IS NULL OR TFF.TFF_COBCTR IN ('','1'))"
    cMVTFG := "(TFG.TFG_COBCTR IS NULL OR TFG.TFG_COBCTR IN ('','1'))"
    cMVTFH := "(TFH.TFH_COBCTR IS NULL OR TFH.TFH_COBCTR IN ('','1'))"

    cQueryTFJ += " AND ((TFFSUB.TFF_COBCTR IS NULL OR TFFSUB.TFF_COBCTR IN ('','1'))"
    cQueryTFJ += " OR (TFGSUB.TFG_COBCTR IS NULL OR TFGSUB.TFG_COBCTR IN ('','1'))"
    cQueryTFJ += " OR (TFHSUB.TFH_COBCTR IS NULL OR TFHSUB.TFH_COBCTR IN ('','1')))"
    cQueryTFJ += " AND TFLSUB.D_E_L_E_T_= ' ' )"

    cQueryTFL += " AND ((TFFSUB.TFF_COBCTR IS NULL OR TFFSUB.TFF_COBCTR IN ('','1'))"
    cQueryTFL += " OR (TFGSUB.TFG_COBCTR IS NULL OR TFGSUB.TFG_COBCTR IN ('','1'))"
    cQueryTFL += " OR (TFHSUB.TFH_COBCTR IS NULL OR TFHSUB.TFH_COBCTR IN ('','1')))"
    cQueryTFL += " AND TFLSUB.D_E_L_E_T_= ' ' )"

ElseIf MV_PAR08 == 3
    cMVTFF := "(TFF.TFF_COBCTR = '2')"
    cMVTFG := "(TFG.TFG_COBCTR = '2')"
    cMVTFH := "(TFH.TFH_COBCTR = '2')" 
    
    cQueryTFJ += " AND ((TFFSUB.TFF_COBCTR = '2')"
    cQueryTFJ += " OR (TFGSUB.TFG_COBCTR = '2')"
    cQueryTFJ += " OR (TFHSUB.TFH_COBCTR = '2'))" 
    cQueryTFJ += " AND TFLSUB.D_E_L_E_T_= ' ' )"

    cQueryTFL += " AND ((TFFSUB.TFF_COBCTR = '2')"
    cQueryTFL += " OR (TFGSUB.TFG_COBCTR = '2')"
    cQueryTFL += " OR (TFHSUB.TFH_COBCTR = '2'))" 
    cQueryTFL += " AND TFLSUB.D_E_L_E_T_= ' ' )"
EndIf 

cMVTFF := "%"+cMVTFF+"%"
cMVTFG := "%"+cMVTFG+"%"
cMVTFH := "%"+cMVTFH+"%"

cQueryTFJ := "%"+cQueryTFJ+"%"
cQueryTFL := "%"+cQueryTFL+"%"

cXfilTFJ := "%"+cXfilTFJ+"%" 
cFiABSTFL := "%"+cFiABSTFL+"%"
cFiSRJTFF := "%"+cFiSRJTFF+"%"
cFiSR6TFF := "%"+cFiSR6TFF+"%"
cFiTDWTFF := "%"+cFiTDWTFF+"%"
cFiSRVABP := "%"+cFiSRVABP+"%"
cFiABNTFU := "%"+cFiABNTFU+"%"

cQuery := "%"+cQuery+"%"
cOrcSimp := "%"+cOrcSimp+"%"

BEGIN REPORT QUERY oTFJ

BeginSql alias cAlias1
    SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT,TFJ_LOJA,A1_NOME
    FROM %table:TFJ% TFJ
    %exp:cQuery%
    WHERE TFJ.TFJ_FILIAL %exp:cXfilTFJ%
        AND TFJ.TFJ_CODIGO BETWEEN %exp:mv_par01% AND %exp:mv_par02%
        AND TFJ.TFJ_CODENT BETWEEN %exp:mv_par03% AND %exp:mv_par05%
        AND TFJ.TFJ_LOJA   BETWEEN %exp:mv_par04% AND %exp:mv_par06%
        AND %exp:cOrcSimp%
        AND TFJ.TFJ_STATUS = '2'
        AND TFJ.%NotDel%
        %exp:cQueryTFJ%
    ORDER BY TFJ_FILIAL,TFJ_CODIGO
EndSql

END REPORT QUERY oTFJ

BEGIN REPORT QUERY oTFL
    
BeginSql alias cAlias2
    SELECT TFL_FILIAL,TFL_CODIGO,TFL_LOCAL,TFL_DTINI,TFL_DTFIM,TFL_TOTRH,TFL_TOTMI,TFL_TOTMC,ABS_DESCRI
    FROM %table:TFL% TFL
        JOIN %Table:ABS% ABS
            ON %exp:cFiABSTFL%	
            AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
            AND ABS.%NotDel%
    WHERE TFL_FILIAL   = %report_param: (cAlias1)->TFJ_FILIAL%
        AND TFL_CODPAI = %report_param: (cAlias1)->TFJ_CODIGO%
        AND TFL.%NotDel%
        %exp:cQueryTFL%
    ORDER BY TFL_FILIAL,TFL_CODIGO
EndSql

END REPORT QUERY oTFL

BEGIN REPORT QUERY oTFF

BeginSql alias cAlias3

    COLUMN TFF_PERINI AS DATE
    COLUMN TFF_PERFIM AS DATE
    COLUMN SUB_PERINI AS DATE
    COLUMN SUB_PERFIM AS DATE

    SELECT TFF.TFF_FILIAL,TFF.TFF_COD,TFF.TFF_ITEM,TFF.TFF_PRODUT,TFF.TFF_QTDVEN,TFF.TFF_PRCVEN,TFF.TFF_PERINI,TFF.TFF_PERFIM,RJ_DESC,R6_DESC,TDW_DESC,TFF.TFF_ESCALA,TFF.TFF_TURNO,
           SUB.TFF_PERINI SUB_PERINI, SUB.TFF_PERFIM SUB_PERFIM, SUB.TFF_QTDVEN SUB_QTDVEN, SUB.TFF_ESCALA SUB_ESCALA, SUB.TFF_TURNO SUB_TURNO
    FROM %table:TFF% TFF
        LEFT JOIN %Table:TDW% TDW
            ON %exp:cFiTDWTFF%	
            AND TDW.TDW_COD = TFF.TFF_ESCALA
            AND TDW.%NotDel%
        LEFT JOIN %Table:SRJ% SRJ
            ON %exp:cFiSRJTFF%	
            AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
            AND SRJ.%NotDel%
        LEFT JOIN %Table:SR6% SR6
            ON %exp:cFiSR6TFF%	
            AND SR6.R6_TURNO = TFF.TFF_TURNO
            AND SR6.%NotDel%
        LEFT JOIN %Table:TFF% SUB
            ON SUB.TFF_FILIAL = TFF.TFF_FILIAL
            AND SUB.TFF_CODSUB = TFF.TFF_COD
            AND SUB.%NotDel%
    WHERE TFF.TFF_FILIAL   = %report_param: (cAlias2)->TFL_FILIAL% 
        AND TFF.TFF_CODPAI = %report_param: (cAlias2)->TFL_CODIGO%
        AND %exp:cMVTFF%
        AND TFF.%NotDel%
    ORDER BY TFF.TFF_ITEM
EndSql

END REPORT QUERY oTFF

If !lOrcPrc
    BEGIN REPORT QUERY oTFG

    BeginSql alias cAlias4

        COLUMN TFG_PERINI AS DATE
        COLUMN TFG_PERFIM AS DATE
        COLUMN SUB_PERINI AS DATE
        COLUMN SUB_PERFIM AS DATE

        SELECT TFG.TFG_ITEM,TFG.TFG_PRODUT,TFG.TFG_QTDVEN,TFG.TFG_PRCVEN,TFG.TFG_PERINI,TFG.TFG_PERFIM,
               SUB.TFG_PERINI SUB_PERINI, SUB.TFG_PERFIM SUB_PERFIM, SUB.TFG_QTDVEN SUB_QTDVEN
        FROM %table:TFG% TFG
        LEFT JOIN %Table:TFG% SUB
            ON SUB.TFG_FILIAL = TFG.TFG_FILIAL
            AND SUB.TFG_CODSUB = TFG.TFG_COD
            AND (SUB.TFG_PERINI <> TFG.TFG_PERINI OR
                 SUB.TFG_PERFIM <> TFG.TFG_PERFIM OR
                 SUB.TFG_QTDVEN <> TFG.TFG_QTDVEN)
            AND SUB.%NotDel%
        WHERE TFG.TFG_FILIAL   = %report_param: (cAlias3)->TFF_FILIAL%
            AND TFG.TFG_CODPAI = %report_param: (cAlias3)->TFF_COD%
            AND %exp:cMVTFG%
            AND TFG.%NotDel%
        ORDER BY TFG.TFG_ITEM
    EndSql

    END REPORT QUERY oTFG

    BEGIN REPORT QUERY oTFH
        
    BeginSql alias cAlias5

        COLUMN TFH_PERINI AS DATE
        COLUMN TFH_PERFIM AS DATE
        COLUMN SUB_PERINI AS DATE
        COLUMN SUB_PERFIM AS DATE

        SELECT TFH.TFH_ITEM,TFH.TFH_PRODUT,TFH.TFH_QTDVEN,TFH.TFH_PRCVEN,TFH.TFH_PERINI,TFH.TFH_PERFIM,
               SUB.TFH_PERINI SUB_PERINI, SUB.TFH_PERFIM SUB_PERFIM, SUB.TFH_QTDVEN SUB_QTDVEN
        FROM %table:TFH% TFH
        LEFT JOIN %Table:TFH% SUB
            ON SUB.TFH_FILIAL = TFH.TFH_FILIAL
            AND SUB.TFH_CODSUB = TFH.TFH_COD
            AND (SUB.TFH_PERINI <> TFH.TFH_PERINI OR
                 SUB.TFH_PERFIM <> TFH.TFH_PERFIM OR
                 SUB.TFH_QTDVEN <> TFH.TFH_QTDVEN)
            AND SUB.%NotDel%
        WHERE TFH.TFH_FILIAL   = %report_param: (cAlias3)->TFF_FILIAL%
            AND TFH.TFH_CODPAI = %report_param: (cAlias3)->TFF_COD%
            AND %exp:cMVTFH%
            AND TFH.%NotDel%
        ORDER BY TFH.TFH_ITEM
    EndSql

    END REPORT QUERY oTFH

Else
    BEGIN REPORT QUERY oTFG
        
    BeginSql alias cAlias4
        SELECT TFG.TFG_ITEM,TFG.TFG_PRODUT,TFG.TFG_QTDVEN,TFG.TFG_PRCVEN,TFG.TFG_PERINI,TFG.TFG_PERFIM,
               SUB.TFG_PERINI SUB_PERINI, SUB.TFG_PERFIM SUB_PERFIM, SUB.TFG_QTDVEN SUB_QTDVEN
        FROM %table:TFG% TFG
        LEFT JOIN %Table:TFG% SUB
            ON SUB.TFG_FILIAL = TFG.TFG_FILIAL
            AND SUB.TFG_CODSUB = TFG.TFG_COD
            AND (TFG.TFG_QTDVEN <> SUB.TFG_QTDVEN OR
                 TFG.TFG_PERINI <> SUB.TFG_PERINI OR
                 TFG.TFG_PERFIM <> SUB.TFG_PERFIM)
            AND SUB.%NotDel%
        WHERE TFG.TFG_FILIAL   = %report_param: (cAlias2)->TFL_FILIAL%
            AND TFG.TFG_CODPAI = %report_param: (cAlias2)->TFL_CODIGO%
            AND TFG.TFG_LOCAL  = %report_param: (cAlias2)->TFL_LOCAL%
            AND %exp:cMVTFG%
            AND TFG.%NotDel%
        ORDER BY TFG.TFG_ITEM
    EndSql

    END REPORT QUERY oTFG

    BEGIN REPORT QUERY oTFH
        
    BeginSql alias cAlias5

        COLUMN TFH_PERINI AS DATE
        COLUMN TFH_PERFIM AS DATE
        COLUMN TFH_PERINI AS DATE
        COLUMN TFH_PERFIM AS DATE

        SELECT TFH.TFH_ITEM,TFH.TFH_PRODUT,TFH.TFH_QTDVEN,TFH.TFH_PRCVEN,TFH.TFH_PERINI,TFH.TFH_PERFIM,
               SUB.TFH_PERINI SUB_PERINI, SUB.TFH_PERFIM SUB_PERFIM, SUB.TFH_QTDVEN SUB_QTDVEN
        FROM %table:TFH% TFH
        LEFT JOIN %Table:TFH% SUB
            ON SUB.TFH_FILIAL = TFH.TFH_FILIAL
            AND SUB.TFH_CODSUB = TFH.TFH_COD
            AND (SUB.TFH_QTDVEN <> TFH.TFH_QTDVEN OR
                 SUB.TFH_PERINI <> TFH.TFH_PERINI OR
                 SUB.TFH_PERFIM <> TFH.TFH_PERFIM)
            AND SUB.%NotDel%
        WHERE TFH.TFH_FILIAL   = %report_param: (cAlias2)->TFL_FILIAL%
            AND TFH.TFH_CODPAI = %report_param: (cAlias2)->TFL_CODIGO%
            AND TFH.TFH_LOCAL  = %report_param: (cAlias2)->TFL_LOCAL%
            AND %exp:cMVTFH%
            AND TFH.%NotDel%
        ORDER BY TFH.TFH_ITEM
    EndSql

    END REPORT QUERY oTFH
EndIf

BEGIN REPORT QUERY oABP

BeginSql alias cAlias6
    SELECT ABP_COD,ABP_ITEM,ABP_BENEFI,ABP_VALOR,ABP_VERBA,RV_DESC
    FROM %table:ABP% ABP
        LEFT JOIN %Table:SRV% SRV
            ON %exp:cFiSRVABP%
            AND SRV.RV_COD = ABP.ABP_VERBA
            AND SRV.%NotDel%
    WHERE ABP_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
        AND ABP_ITRH = %report_param: (cAlias3)->TFF_COD%
        AND ABP.%NotDel%
    ORDER BY ABP_ITEM
EndSql

END REPORT QUERY oABP

BEGIN REPORT QUERY oTFU

BeginSql alias cAlias7
    SELECT TFU_CODABN,TFU_VALOR,ABN_DESC
    FROM %table:TFU% TFU
        LEFT JOIN %Table:ABN% ABN
            ON %exp:cFiABNTFU%
            AND ABN.ABN_CODIGO = TFU.TFU_CODABN
            AND ABN.%NotDel%
    WHERE TFU.TFU_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
        AND TFU_CODTFF   = %report_param: (cAlias3)->TFF_COD%
        AND TFU.%NotDel%
    ORDER BY TFU_CODIGO
EndSql

END REPORT QUERY oTFU

BEGIN REPORT QUERY oTXP

BeginSql alias cAlias8
    SELECT TXP.TXP_CODUNI, TXP.TXP_QTDVEN, TXP.TXP_PRCVEN, SUB.TXP_QTDVEN SUB_QTDVEN
    FROM %table:TXP% TXP
    LEFT JOIN %Table:TXP% SUB
    ON SUB.TXP_FILIAL = TXP.TXP_FILIAL
    AND SUB.TXP_CODSUB = TXP.TXP_CODIGO
    AND SUB.TXP_QTDVEN <> TXP.TXP_QTDVEN
    AND SUB.%NotDel%
    WHERE TXP.TXP_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
        AND TXP.TXP_CODTFF = %report_param: (cAlias3)->TFF_COD%
        AND TXP.%NotDel%
    ORDER BY TXP.TXP_CODIGO
EndSql

END REPORT QUERY oTXP

BEGIN REPORT QUERY oTXQ

BeginSql alias cAlias9
    SELECT TXQ.TXQ_CODPRD, TXQ.TXQ_QTDVEN, TXQ.TXQ_PRCVEN, SUB.TXQ_QTDVEN SUB_QTDVEN
    FROM %table:TXQ% TXQ
    LEFT JOIN %Table:TXQ% SUB
    ON SUB.TXQ_FILIAL = TXQ.TXQ_FILIAL
    AND SUB.TXQ_CODSUB = TXQ.TXQ_CODIGO
    AND SUB.TXQ_QTDVEN <> TXQ.TXQ_PRCVEN
    AND SUB.%NotDel%
    WHERE TXQ.TXQ_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
        AND TXQ.TXQ_CODTFF = %report_param: (cAlias3)->TFF_COD%
        AND TXQ.%NotDel%
    ORDER BY TXQ.TXQ_CODIGO
EndSql

END REPORT QUERY oTXQ

oTFJ:Print()

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} At982RetPrd
@description Retornar Descricao do Produto
@author Flavio Vicco
@since  15/05/2023
/*/
//--------------------------------------------------------------------------------
Static Function At982RetPrd(cCodSB1)
Local cRet := Posicione("SB1",1,xFilial("SB1")+cCodSB1,"B1_DESC")
Return cRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} At982RetObs
@description Retornar alterações do Orçamento
@author Flavio Vicco
@since  15/05/2023
/*/
//--------------------------------------------------------------------------------
Static Function At982RetObs(cAlias, aFields)
Local cRet    := ""
Local cField1 := ""
Local cField2 := ""
Local nY      := 0
Local nTam    := Len(aFields)

For nY := 1 To nTam
    cField1 := aFields[nY]
    cField2 := "SUB" + Substr(cField1,4)
    If Empty((cAlias)->(&cField2))
        cRet := STR0014 //"Item incluido"
        Exit
    EndIf
    If (cAlias)->(&cField1) <> (cAlias)->(&cField2)
        cRet += TecTituDes(cField1) + " / "
    EndIf
Next nY

Return cRet
