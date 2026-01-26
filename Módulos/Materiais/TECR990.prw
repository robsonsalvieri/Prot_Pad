#include "protheus.ch"
#include "report.ch"
#include "TECR990.CH"
#include "RPTDEF.CH"
#include "FWPrintSetup.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR990
Relatorio de Orçado x Realizado

@author Djalma Mathias
@since 27/02/2024
@version P12.1.23
/*/
//-------------------------------------------------------------------
Function TECR990()
Local oReport  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Orçamentoate ?                                              ³
//³ MV_PAR02 : Cliente De ?                                                ³
//³ MV_PAR03: Loja De ?                                                   ³
//³ MV_PAR04 : Cliente ate ?                                               ³
//³ MV_PAR05 : Loja Até ?                                                  ³
//³ MV_PAR06 : Filial ?                                                    ³
//³ MV_PAR07 : Data De?                                                    ³
//³ MV_PAR08 : Data Até?                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If !Pergunte("TECR990",.T.)     
    Return
EndIf

oReport := ReportDef()  
oReport:SetLandscape()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Monta as definições do relatorio de Orçamento

@author  Djalma Mathias
@version P12.1.23
@since 	 27/02/2024
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef()
Local oReport
Local oTFJ
Local oTFL
Local oTFF
Local oTFG
Local oTFH 
Local oTXP
Local oTXQ
  
 Pergunte("TECR990",.F.)  

DEFINE REPORT oReport NAME "TECR990" TITLE STR0001 PARAMETER "TECR990" ACTION {|oReport| PrintReport(oReport),STR0034} //"Relatório de orçamentos"#"Orçamentos"

    DEFINE SECTION oTFJ OF oReport TITLE STR0034 TABLES "TFJ","SA1" //"Orçamentos" // CALIAS1

        DEFINE CELL NAME "TFJ_FILIAL"   OF oTFJ ALIAS "TFJ" TITLE STR0029 //"Filial"    
        DEFINE CELL NAME "TFJ_CODIGO"   OF oTFJ ALIAS "TFJ" TITLE STR0002 //"Cód. Orçamento"
        DEFINE CELL NAME "TFJ_CODENT"   OF oTFJ ALIAS "TFJ" TITLE STR0003 //"Cod. Cliente"
        DEFINE CELL NAME "TFJ_LOJA"     OF oTFJ ALIAS "TFJ" TITLE STR0005 //"Loja"
        DEFINE CELL NAME "A1_NOME"      OF oTFJ ALIAS "SA1" TITLE STR0004 //"Cliente"

        DEFINE SECTION oTFL OF oTFJ TITLE STR0035 TABLES "TFL","ABS" //"Locais" // CALIAS2

            DEFINE CELL NAME "TFL_LOCAL"    OF oTFL ALIAS "TFL" TITLE STR0007 //"Cód. Local"
            DEFINE CELL NAME "ABS_DESCRI"   OF oTFL ALIAS "ABS" TITLE STR0008 //"Descrição do Local"
            DEFINE CELL NAME "TFL_DTINI"    OF oTFL ALIAS "TFL" TITLE STR0009 //"Data Inicial"
            DEFINE CELL NAME "TFL_DTFIM"    OF oTFL ALIAS "TFL" TITLE STR0010 //"Data Final"

            //oTFL:SetLeftMargin(01)
 
            DEFINE SECTION oTFF OF oTFL TITLE STR0036 TABLE "TFF","SRJ","SR6", "TDW", "ABS" //"Recursos Humanos" (POSTO) // CALIAS3 , "SCP"

                DEFINE CELL NAME "TFF_ITEM"     OF oTFF ALIAS "TFF" SIZE 04 TITLE STR0042 //"Item"
                DEFINE CELL NAME "TFF_PRODUT"   OF oTFF ALIAS "TFF" TITLE STR0015 //"Cód. Produto"
                DEFINE CELL NAME "ABS_CCUSTO"   OF oTFF ALIAS "ABS" TITLE STR0061 //"Centro de Custo" ? VERIFICAR COM PO
                DEFINE CELL NAME "TFF_QTDVEN"   OF oTFF ALIAS "TFF" SIZE 15 TITLE STR0017 //"Qtd"
                DEFINE CELL NAME "TFF_PRCVEN"   OF oTFF ALIAS "TFF" SIZE 15 TITLE STR0018 //"Preço"
                DEFINE CELL NAME "TFF_PERINI"   OF oTFF ALIAS "TFF" SIZE 15 TITLE STR0009 //"Data Inicial"
                DEFINE CELL NAME "TFF_PERFIM"   OF oTFF ALIAS "TFF" SIZE 15 TITLE STR0010 //"Data Final"
                DEFINE CELL NAME "RJ_DESC"      OF oTFF ALIAS "SRJ" TITLE STR0020 //"Função"
                DEFINE CELL NAME "TDW_DESC"     OF oTFF ALIAS "TDW" TITLE STR0037 //"Escala"
                DEFINE CELL NAME "R6_DESC"      OF oTFF ALIAS "SR6" TITLE STR0022 //"Turno"

                oTFF:SetLeftMargin(05)

                    DEFINE SECTION oTFG OF oTFF TITLE STR0038 TABLE "TFG", "TFS", "SCP", "TFF", "SB1" //"Material de Implantação" // CALIAS4
                        // DESCRIÇÃO
                        DEFINE CELL NAME "CP_DESCRI"    OF oTFG ALIAS "SCP" SIZE 30 TITLE STR0038 //"Material de Implantação" 
                        DEFINE CELL NAME "TFG_QTDVEN"   OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0017 //"Qtd"
                        DEFINE CELL NAME "TFG_PRCVEN"   OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0018 //"Valor Unitário Orçado"
                        DEFINE CELL NAME "TFG_TOTAL"    OF oTFG ALIAS "TFG" SIZE 17 TITLE STR0026 //"Valor Total" CALCULO QTDE X VL UNIT
                        DEFINE CELL NAME "TFG_CODPAI"   OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0064 //"Cod Item RH"  ? FALAR COM O PO
                        DEFINE CELL NAME "TFG_QTDVEN"   OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0065 //"Total Previsto em Contrato"
                        DEFINE CELL NAME "TFG_QUANT"    OF oTFG ALIAS "TFG" SIZE 17 TITLE STR0066 //"Total Solicitado" TECA890 - TABELA TFS - MONTAR QUERY DO PERÍODO OLHAR TB SCP TECA890
                        DEFINE CELL NAME "TFG_QUJE"     OF oTFG ALIAS "TFG" SIZE 17 TITLE STR0068 //Block {|| TECRENT(oTFG:Cell("TFG_CODPAI"):GetValue(.T.),oTFG:Cell("TFG_QTDVEN"):GetValue(.T.))} // "Entregue"   SOMATÓRIA DA SA DO SCP RETORNO DA QUERY
                        DEFINE CELL NAME "B1_CUSTD"     OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0069 //"Custo Médio Almox"
                        DEFINE CELL NAME "TFG_VALCM"    OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0070 //"Valor Orçado x Custo Médio"
                        DEFINE CELL NAME "TFG_PVOCM"    OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0071 //"% Valor Orçado x Custo Médio" TFG_PVOCM
                        DEFINE CELL NAME "B1_UPRC"      OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0072 //"Custo Ult. Compra"
                        DEFINE CELL NAME "TFG_VOUC"     OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0073 //"Valor Orçado x Ultima Compra"
                        DEFINE CELL NAME "TFG_PVOUC"    OF oTFG ALIAS "TFG" SIZE 15 TITLE STR0074 //"% Valor Orçado x Custo Médio"
                    
                    oTFG:SetLeftMargin(10)

                    DEFINE SECTION oTFH OF oTFF TITLE STR0039 TABLE "TFH", "TFT", "SCP" //"Material de Consumo" // CALIAS5
                        // DESCRIÇÃO
                        DEFINE CELL NAME "CP_DESCRI"    OF oTFH ALIAS "SCP" SIZE 30 TITLE STR0039 //"Material de Consumo"
                        DEFINE CELL NAME "TFH_QTDVEN"   OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0017 //"Qtd"
                        DEFINE CELL NAME "TFH_PRCVEN"   OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0018 //"Valor Unitário Orçado"
                        DEFINE CELL NAME "TFH_TOTAL"    OF oTFH ALIAS "TFH" SIZE 17 TITLE STR0026 //"Valor Total" CALCULO QTDE X VL UNIT
                        DEFINE CELL NAME "TFH_PRODUT"   OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0064 //"Cod Item RH"  ? FALAR COM O PO
                        DEFINE CELL NAME "TFH_QTDVEN"   OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0065 //"Total Previsto em Contrato"
                        DEFINE CELL NAME "TFH_QUANT"    OF oTFH ALIAS "TFH" SIZE 17 TITLE STR0066 //"Total Solicitado" TECA890 - TABELA TFS - MONTAR QUERY DO PERÍODO OLHAR TB SCP TECA890
                        DEFINE CELL NAME "TFH_QUJE"     OF oTFH ALIAS "TFH" SIZE 17 TITLE STR0068 //"Entregue" SOMATÓRIA DA SA DO SCP RETORNO DA QUERY
                        DEFINE CELL NAME "B1_CUSTD"     OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0069 //"Custo Médio Almox"
                        DEFINE CELL NAME "TFH_VALCM"    OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0070 //"Valor Orçado x Custo Médio"
                        DEFINE CELL NAME "TFH_PVOCM"    OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0071 //"% Valor Orçado x Custo Médio"
                        DEFINE CELL NAME "TFH_VALCM2"   OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0072 //"Custo Ult. Compra"
                        DEFINE CELL NAME "TFH_VOUC"     OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0073 //"Valor Orçado x Ultima Compra"
                        DEFINE CELL NAME "TFH_PVOUC"    OF oTFH ALIAS "TFH" SIZE 15 TITLE STR0074 //"% Valor Orçado x Custo Médio"

                    oTFH:SetLeftMargin(10)  

                    DEFINE SECTION oTXP OF oTFF TITLE STR0062 TABLES "TXP" , "SB1" , "TXD" //"Uniforme"  // CALIAS6
                        // DESCRIÇÃO
                        DEFINE CELL NAME "B1_DESC"      OF oTXP ALIAS "SB1" SIZE 30 TITLE STR0077 //UNIFORME
                        DEFINE CELL NAME "TXP_QTDVEN"   OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0017 //"Qtd" 
                        DEFINE CELL NAME "TXP_PRCVEN"   OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0018 //"Valor Unitário Orçado"
                        DEFINE CELL NAME "TXP_TOTAL"    OF oTXP ALIAS "TXP" SIZE 17 TITLE STR0026 //"Valor Total"
                        DEFINE CELL NAME "B1_COD"       OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0064 //"Cod Item RH"  ? FALAR COM O PO
                        DEFINE CELL NAME "TXP_QTDVEN"   OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0065 //"Total Previsto em Contrato"
                        DEFINE CELL NAME "TXP_QUANT"    OF oTXP ALIAS "TXD" SIZE 17 TITLE STR0066 //"Total Solicitado" TECA890 - TABELA TXD - MONTAR QUERY DO PERÍODO OLHAR TB SCP TECA894
                        DEFINE CELL NAME "TXP_QUJE"     OF oTXP ALIAS "TXP" SIZE 17 TITLE STR0068 //"Entregue" SOMATÓRIA DA SA DO SCP RETORNO DA QUERY
                        DEFINE CELL NAME "B1_CUSTD"     OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0069 //"Custo Médio Almox"
                        DEFINE CELL NAME "TXP_VALCM"    OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0070 //"Valor Orçado x Custo Médio"
                        DEFINE CELL NAME "TXP_PVOCM"    OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0071 //"% Valor Orçado x Custo Médio"
                        DEFINE CELL NAME "B1_UPRC"      OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0072 //"Custo Ult. Compra"
                        DEFINE CELL NAME "TXP_VOUC"     OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0073 //"Valor Orçado x Ultima Compra"
                        DEFINE CELL NAME "TXP_PVOUC"    OF oTXP ALIAS "TXP" SIZE 15 TITLE STR0074 //"% Valor Orçado x Custo Médio"                        

                    oTXP:SetLeftMargin(10)  

                    DEFINE SECTION oTXQ OF oTFF TITLE STR0063 TABLE "TXQ", "TFO", "SB1" //"Armamento"     // CALIAS7                
                        // DESCRIÇÃO
                        DEFINE CELL NAME "B1_DESC"      OF oTXQ ALIAS "SB1" SIZE 30 TITLE STR0063 //"Armamento"
                        DEFINE CELL NAME "TXQ_QTDVEN"   OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0017 //"Qtd"
                        DEFINE CELL NAME "TXQ_PRCVEN"   OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0018 //"Valor Unitário Orçado"
                        DEFINE CELL NAME "TXQ_TOTAL"    OF oTXQ ALIAS "TXQ" SIZE 17 TITLE STR0026 //"Valor Total" - CALCULAR QTDE X VALOR
                        DEFINE CELL NAME "B1_COD"       OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0064 //"Cod Item RH"  ? FALAR COM O PO
                        DEFINE CELL NAME "TXQ_QTDVEN"   OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0065 //"Total Previsto em Contrato"
                        DEFINE CELL NAME "TXQ_QUANT"    OF oTXQ ALIAS "TXQ" SIZE 17 TITLE STR0066 //"Total Solicitado" TECA890 - TABELA TXD - MONTAR QUERY DO PERÍODO OLHAR TB SCP TECA880
                        DEFINE CELL NAME "TXQ_QUJE"     OF oTXQ ALIAS "TFO" SIZE 17 TITLE STR0068 //"Entregue" SOMATÓRIA DA SA DO TFO_QTDE RETORNO DA QUERY
                        DEFINE CELL NAME "B1_CUSTD"     OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0069 //"Custo Médio Almox"
                        DEFINE CELL NAME "TXQ_VALCM"    OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0070 //"Valor Orçado x Custo Médio"
                        DEFINE CELL NAME "TXQ_PVOCM"    OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0071 //"% Valor Orçado x Custo Médio"
                        DEFINE CELL NAME "B1_UPRC"      OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0072 //"Custo Ult. Compra"
                        DEFINE CELL NAME "TXQ_VOUC"     OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0073 //"Valor Orçado x Ultima Compra"
                        DEFINE CELL NAME "TXQ_PVOUC"    OF oTXQ ALIAS "TXQ" SIZE 15 TITLE STR0074 //"% Valor Orçado x Custo Médio"                        
         
                    oTXQ:SetLeftMargin(10)   
  
                
Return oReport 
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Monta a query para exebir no relatório.

@author  Djalma Mathias
@version P12.1.23
@since 	 27/02/2024
@return  Nil
/*/
//------------------------------------------------------------------------------------- 
Static Function PrintReport(oReport) // ,cAlias2
Local lHasOrcSmp := HasOrcSimp()
Local lOrcSimp  := lHasOrcSmp .And. SuperGetMv("MV_ORCSIMP",,"2") == "1"
Local cXfilTFJ  :=  " = '" + xFilial("TFJ", cFilAnt) +"'"   
Local cXfilTFF  :=  xFilial("TFF", cFilAnt)
Local cXfilABS  :=  xFilial("ABS", cFilAnt)
Local cXfilTFJ2 := "" 
Local cFiSA1TFJ := FWJoinFilial("SA1","TFJ","SA1","TFJ",.T.)
Local cFiSA1AD1 := FWJoinFilial("SA1","AD1","SA1","AD1",.T.)
Local cFiABSTFL := FWJoinFilial("ABS","TFL","ABS","TFL",.T.)
Local cFiSRJTFF := FWJoinFilial("SRJ","TFF","SRJ","TFF",.T.) 
Local cFiSR6TFF := FWJoinFilial("SR6","TFF","SR6","TFF",.T.)
Local cFiSCPTFF := FWJoinFilial("SCP","TFF","SCP","TFF",.T.)
Local cFiTDWTFF := FWJoinFilial("TDW","TFF","TDW","TFF",.T.)
Local cFiSRVABP := FWJoinFilial("SRV","ABP","SRV","ABP",.T.)
Local cFiABNTFU := FWJoinFilial("ABN","TFU","ABN","TFU",.T.)
Local cAlias1 := GetNextAlias()
Local cAlias2 := GetNextAlias() 
Local cAlias3 := GetNextAlias()
Local cAlias4 := GetNextAlias()
Local cAlias5 := GetNextAlias()
Local cAlias6 := GetNextAlias()
Local cAlias7 := GetNextAlias()  
Local cQuery := ""
Local cQueryTFJ := ""
Local cQueryTFL := ""
Local cOrcSimp := ""
Local cMVTFF := ""
Local cMVTFG := ""
Local cMVTFH := ""
//Local nX
//Local cQryMVPAR1  := ""
//Local cValMVPAR1  := ""
//Local aConMVPAR1  := {}

MakeSqlExp("TECR990")

If !Empty(MV_PAR01)
    cXfilTFJ2   := ""  
    cXfilTFJ2   := MV_PAR01
Else
    cXfilTFJ2   := " TFJ_CODIGO = ' ' "
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

    cOrcSimp += " ((AD1.AD1_DTINI <= '"+DTOS(MV_PAR07)+"' OR AD1.AD1_DTINI BETWEEN '"+DTOS(MV_PAR07)+"'AND '"+DTOS(MV_PAR08)+"')"
    cOrcSimp += " AND ( AD1.AD1_DTFIM >= '"+DTOS(MV_PAR08)+"' OR AD1.AD1_DTFIM BETWEEN '"+DTOS(MV_PAR07)+"'AND '"+DTOS(MV_PAR08)+"') OR AD1.AD1_DTINI = '"+ '' + "' OR AD1.AD1_DTFIM = '"+ '' + "')"

else
    cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON " + cFiSA1TFJ + " AND "
	cQuery += " SA1.D_E_L_E_T_ = ' '  AND "
	cQuery += " SA1.A1_COD = TFJ.TFJ_CODENT AND "
	cQuery += " SA1.A1_LOJA = TFJ.TFJ_LOJA "

    cOrcSimp := " TFJ.TFJ_DATA >= '" +DTOS(MV_PAR08) + "' AND TFJ.TFJ_DATA <= '" +DTOS(MV_PAR08)+"'"
EndIf 

cQueryTFJ := " AND EXISTS ( SELECT 1  FROM " + RetSqlName('TFL') + " TFLSUB"
cQueryTFJ += " LEFT JOIN " + RetSqlName('TFF') + " TFFSUB"
cQueryTFJ += " ON TFFSUB.TFF_FILIAL = TFLSUB.TFL_FILIAL"
cQueryTFJ += " AND TFFSUB.TFF_CODPAI = TFLSUB.TFL_CODIGO"
cQueryTFJ += " AND TFFSUB.D_E_L_E_T_= ' ' "

	            
cQueryTFJ += " LEFT JOIN " + RetSqlName('TFG') + " TFGSUB"
cQueryTFJ += " ON TFGSUB.TFG_FILIAL = TFFSUB.TFF_FILIAL"
cQueryTFJ += " AND TFGSUB.TFG_CODPAI = TFFSUB.TFF_COD"
cQueryTFJ += " AND TFGSUB.D_E_L_E_T_= ' ' " 			
        
cQueryTFJ += " LEFT JOIN " + RetSqlName('TFH') + " TFHSUB"
cQueryTFJ += " ON TFHSUB.TFH_FILIAL = TFFSUB.TFF_FILIAL"
cQueryTFJ += " AND TFHSUB.TFH_CODPAI = TFFSUB.TFF_COD"
cQueryTFJ += " AND TFHSUB.D_E_L_E_T_= ' ' " 		


cQueryTFL := cQueryTFJ
            
cQueryTFJ += " WHERE TFJ.TFJ_FILIAL = TFLSUB.TFL_FILIAL"
cQueryTFJ += " AND TFJ.TFJ_CODIGO = TFLSUB.TFL_CODPAI"

cQueryTFL += " WHERE TFL.TFL_FILIAL = TFFSUB.TFF_FILIAL"
cQueryTFL += " AND TFL.TFL_CODIGO = TFFSUB.TFF_CODPAI"

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


cMVTFF := "%"+cMVTFF+"%"
cMVTFG := "%"+cMVTFG+"%"
cMVTFH := "%"+cMVTFH+"%"

cQueryTFJ := "%"+cQueryTFJ+"%"
cQueryTFL := "%"+cQueryTFL+"%"

cXfilTFJ  := "%"+cXfilTFJ+"%" 
cXfilTFJ2 := "%"+cXfilTFJ2+"%" 
cFiABSTFL := "%"+cFiABSTFL+"%"
cFiSRJTFF := "%"+cFiSRJTFF+"%"
cFiSR6TFF := "%"+cFiSR6TFF+"%"
cFiSCPTFF := "%"+cFiSCPTFF+"%"
cFiTDWTFF := "%"+cFiTDWTFF+"%"
cFiSRVABP := "%"+cFiSRVABP+"%"
cFiABNTFU := "%"+cFiABNTFU+"%"

cQuery := "%"+cQuery+"%"
cOrcSimp := "%"+cOrcSimp+"%"

BEGIN REPORT QUERY oReport:Section(1) 

BeginSql alias cAlias1
    SELECT TFJ_FILIAL,TFJ_CODIGO,TFJ_CODENT,TFJ_LOJA,A1_NOME, TFJ_CONTRT
    FROM %table:TFJ% TFJ
    LEFT JOIN %table:SA1% SA1  
        ON SA1.A1_COD = TFJ.TFJ_CODENT
        AND SA1.A1_LOJA = TFJ.TFJ_LOJA
        AND SA1.%notDel% 
    WHERE %exp:cXfilTFJ2%   
        //AND TFJ_CONTRT  %Exp:cQryMVPAR1% 
        AND TFJ.TFJ_FILIAL %exp:cXfilTFJ%
        AND TFJ.TFJ_CODENT  BETWEEN %exp:mv_par02% AND %exp:mv_par04%
        AND TFJ.TFJ_LOJA    BETWEEN %exp:mv_par03% AND %exp:mv_par05%
        AND TFJ.TFJ_DATA    BETWEEN %exp:mv_par07% AND %exp:mv_par08%
        AND TFJ.%notDel%   
        %exp:cQueryTFJ%          
        
    ORDER BY TFJ_FILIAL,TFJ_CODIGO  
EndSql
    
END REPORT QUERY oReport:Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(1) 
    
BeginSql alias cAlias2
    SELECT TFL_FILIAL,TFL_CODIGO,TFL_LOCAL,TFL_DTINI,TFL_DTFIM,TFL_TOTRH,TFL_TOTMI,TFL_TOTMC,ABS_DESCRI
    FROM %table:TFL% TFL
        JOIN %Table:ABS% ABS
            ON ABS.ABS_FILIAL = %exp:cXfilABS% 
            AND ABS.ABS_LOCAL = TFL.TFL_LOCAL
            AND ABS.%NotDEL%
    WHERE TFL_FILIAL   = %report_param: (cAlias1)->TFJ_FILIAL% 
        AND TFL_CODPAI = %report_param: (cAlias1)->TFJ_CODIGO%                         
        AND TFL.%notDel% 
        %exp:cQueryTFL%
    ORDER BY TFL_FILIAL,TFL_CODIGO
EndSql
    
END REPORT QUERY oReport:Section(1):Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1)

BeginSql alias cAlias3
    SELECT TFF_FILIAL,TFF_COD,TFF_ITEM,TFF_PRODUT,TFF_QTDVEN,TFF_PRCVEN,TFF_PERINI,TFF_PERFIM,RJ_DESC,R6_DESC,TDW_DESC,CP_DESCRI, TFF_LOCAL
    FROM %table:TFF% TFF
        LEFT JOIN %Table:TDW% TDW
            ON TDW_FILIAL = TFF_FILIAL
            AND TDW.TDW_COD = TFF.TFF_ESCALA
            AND TDW.%NotDEL%
        LEFT JOIN %Table:SRJ% SRJ
            ON SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO
            AND SRJ.%NotDEL%
        LEFT JOIN %Table:SR6% SR6
            ON SR6.R6_TURNO = TFF.TFF_TURNO
            AND SR6.%NotDEL%
        LEFT JOIN %Table:SCP% SCP
            ON CP_FILIAL = TFF_FILIAL
            AND SCP.CP_PRODUTO = TFF.TFF_PRODUT
            AND SCP.%NotDEL%
    WHERE TFF.TFF_FILIAL = %exp:cXfilTFF%
        AND TFF_CODPAI = %report_param: (cAlias2)->TFL_CODIGO% 
        AND %exp:cMVTFF%
        AND TFF.%notDel% 
    ORDER BY TFF_ITEM 
EndSql
    
END REPORT QUERY oReport:Section(1):Section(1):Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(1)
    
BeginSql alias cAlias4
    SELECT TFG_ITEM,TFG_PRODUT,TFG_QTDVEN,TFG_PRCVEN,TFG_PERINI,TFG_PERFIM, TFG_SLD, 
        B1_UPRC, B1_CUSTD, CP_DESCRI, TFG_CODPAI, TFF_QTPREV,
        B1_CUSTD-TFG_PRCVEN TFG_VALCM, (B1_CUSTD / TFG_PRCVEN)*100 TFG_PVOCM, 
        B1_UPRC-TFG_PRCVEN  TFG_VOUC,  (B1_UPRC / TFG_PRCVEN)*100 TFG_PVOUC, 
        TFF_QTPREV*TFG_QTDVEN TFG_QUANT, 0 TFG_QUJE, TFG_QTDVEN*TFG_PRCVEN TFG_TOTAL
    FROM %table:TFG% TFG
    INNER JOIN %table:TFF% TFF 
        ON TFF_FILIAL = TFG_FILIAL
        AND TFF_COD = TFG_CODPAI
        AND TFF.%notDel% 
    LEFT JOIN %table:SB1% SB1 
        ON B1_COD = TFG_PRODUT
        AND SB1.%notDel%       
    INNER JOIN %table:SCP% SCP ON CP_PRODUTO = TFG_PRODUT
        AND SCP.%notDel%      
    INNER JOIN %table:TFJ% TFJ 
        ON TFJ_FILIAL = TFG_FILIAL
        AND TFJ_CONTRT = %report_param: (cAlias1)->TFJ_CONTRT% 
        AND TFJ.%notDel%    
    WHERE %exp:cXfilTFJ2% 
        AND TFG_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
        AND TFG_CODPAI = %report_param: (cAlias3)->TFF_COD% 
        AND TFG_LOCAL  = %report_param: (cAlias3)->TFF_LOCAL% 
        AND TFG_CONTRT = %report_param: (cAlias1)->TFJ_CONTRT% 
        AND TFG.%notDel%  
    ORDER BY TFG_ITEM 
EndSql  
        

END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(1)

BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(2)  
    
BeginSql alias cAlias5
    SELECT CP_DESCRI,TFH_ITEM,TFH_PRODUT,TFH_QTDVEN,TFH_PRCVEN,TFH_PERINI,
        TFH_PERFIM, B1_CUSTD, B1_UPRC, TFF_QTPREV,
        B1_CUSTD-TFH_PRCVEN TFH_VALCM, B1_UPRC-TFH_PRCVEN TFH_VOUC, 
        (B1_UPRC / TFH_PRCVEN)*100 TFH_PVOUC, 
        TFH_QTDVEN*TFH_PRCVEN TFH_TOTAL, TFF_QTPREV*TFH_QTDVEN TFH_QUANT, 
        0 TFH_QUJE, (B1_CUSTD / TFH_PRCVEN)*100  TFH_PVOCM
    FROM %table:TFH% TFH
    LEFT JOIN %table:TFF% TFF 
        ON TFF_FILIAL = TFH_FILIAL
        AND TFF_FILIAL   = %report_param: (cAlias2)->TFL_FILIAL% 
        AND TFF_CODPAI = %report_param: (cAlias2)->TFL_CODIGO%  
        AND %exp:cMVTFF%
        AND TFF.%notDel%                
    INNER JOIN %table:SCP% SCP ON CP_PRODUTO = TFH_PRODUT 
        AND SCP.%notDel% 
    INNER JOIN %table:SB1% SB1 ON B1_COD = TFH_PRODUT
        AND SB1.%notDel% 
    WHERE TFH_FILIAL   = %report_param: (cAlias3)->TFF_FILIAL%
        AND TFH_CODPAI = %report_param: (cAlias3)->TFF_COD% 
        AND %exp:cMVTFH%
        AND TFH.%notDel% 
    ORDER BY TFH_ITEM
EndSql 

END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(2)

BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(3)

BeginSql alias cAlias6
    SELECT B1_CUSTD-TXP_PRCVEN TXP_VALCM, B1_UPRC-TXP_PRCVEN TXP_VOUC, 
    TXP_QTDVEN*TXP_PRCVEN TXP_TOTAL, TFF_QTPREV*TXP_QTDVEN TXP_QUANT,
    0 TXP_QUJE, (B1_UPRC / TXP_PRCVEN)*100 TXP_PVOUC, (B1_CUSTD / TXP_PRCVEN)*100 TXP_PVOCM, *
    FROM %table:TXP% TXP  
    //INNER JOIN %table:TXD% TXD
    //    ON TXD.TXD_CODTXP = TXP.TXP_CODIGO
    //    AND TXD.TXD_CONTRT = %report_param: (cAlias1)->TFJ_CODIGO%
    //    AND TXD.%notDel%
    INNER JOIN %table:TFF% TFF 
        ON  TFF_FILIAL = %exp:cXfilTFF%
        AND TFF_COD = TXP.TXP_CODTFF
        AND TFF.%notDel%
    INNER JOIN %table:SB1% SB1
        ON SB1.B1_COD = TXP.TXP_CODUNI
        AND SB1.%notDel%            
    WHERE TXP.TXP_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
        AND TXP_CONTRT= %report_param: (cAlias1)->TFJ_CONTRT% 
        AND TXP.%notDel%
    ORDER BY TXP_CODIGO  
EndSql   

END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(3)

BEGIN REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(4)

BeginSql alias cAlias7 
    SELECT B1_CUSTD-TXQ_PRCVEN TXQ_VALCM, B1_UPRC-TXQ_PRCVEN TXQ_VOUC, 
    (B1_UPRC / TXQ_PRCVEN)*100 TXQ_PVOUC, 
    TXQ_QTDVEN*TXQ_PRCVEN TXQ_TOTAL, TFF_QTPREV*TXQ_PRCVEN TXQ_QUANT,
    0 TXQ_QUJE, (B1_CUSTD / TXQ_PRCVEN)*100 TXQ_PVOCM, *
    FROM %table:TXQ% TXQ
    LEFT JOIN %table:TFO% TFO 
        ON TFO.%notDel%
    LEFT JOIN %table:SB1% SB1 
        ON B1_COD = TXQ_CODPRD
        AND SB1.%notDel%     
    LEFT JOIN %table:TFF% TFF 
        ON TFF_PRODUT = B1_COD
        AND TFF.%notDel%                 
    WHERE TXQ.TXQ_FILIAL = %report_param: (cAlias3)->TFF_FILIAL%
        AND TXQ.TXQ_CONTRT  = %report_param: (cAlias1)->TFJ_CONTRT% 
        AND TXQ.TXQ_CODIGO = TFO_CODTXQ
        AND TXQ.%notDel%
    ORDER BY TXQ.TXQ_CODIGO 
EndSql

END REPORT QUERY oReport:Section(1):Section(1):Section(1):Section(4)

oReport:Section(1):Print()     


Return 
