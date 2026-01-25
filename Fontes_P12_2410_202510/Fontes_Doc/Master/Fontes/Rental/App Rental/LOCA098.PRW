#include "TOTVS.CH"
#include "TOPCONN.CH"
#include "TBICONN.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} LOCA098
Funcoes auxiliares para a execucao dos apps
@type function
@since 18/09/2025
/*/
Function LOCA098(cQry,cCli,cLoja)
Local cQuery   := ""
Local cComando := ""
Local cLinha   := ""

    If cQry == "01"
        cQuery := "SELECT TRX_NOME, COUNT(*) MULTAS "
        cQuery += "FROM "+RETSQLNAME("TRX")+" TRX " 
        cQuery += "INNER JOIN "+RETSQLNAME("FP0")+" FP0 "
        cQuery += "ON FP0_FILIAL = '" + xFilial('FP0') + "' "
        cQuery += "AND FP0.D_E_L_E_T_ = ' ' "
        
        cLinha := "AND FP0_CLI = '"+cCli+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cLinha := "AND FP0_LOJA = '"+cLoja+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cQuery += "INNER JOIN "+RETSQLNAME("FPA")+" FPA " 
        cQuery += "ON FPA_FILIAL = '" + xFilial('FPA') + "' "
        cQuery += "AND FPA_PROJET = FP0_PROJET " 
        cQuery += "AND FPA.D_E_L_E_T_ = ' ' "
        cQuery += "AND FPA_AS <> ' ' "
        cQuery += "WHERE TRX_FILIAL = '" + xFilial('TRX') + "' "
        cQuery += "AND TRX_AS = FPA_AS "
        cQuery += "AND TRX_TPMULT = 'TRANSITO' "
        cQuery += "AND TRX.D_E_L_E_T_ = ' ' "    
        cQuery += "GROUP BY TRX_NOME "
        cQuery += "ORDER BY TRX_NOME "
        cQuery := CHANGEQUERY(cQuery)
    EndIf 

    If cQry == "02"
        cQuery := "SELECT DA4_COD,DA4_NOME,DA4_CGC,DA4_NUMCNH "
        cQuery += "FROM "+RETSQLNAME("DA4")+" DA4 " 
        cQuery += "WHERE DA4_FILIAL = '" + xFilial('DA4') + "' "
        
        cLinha := "AND DA4_CODCLI  = '"+cCli+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cLinha := "AND DA4_LOJCLI = '"+cLoja+"' "  
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cQuery += "AND DA4.D_E_L_E_T_ = ' ' "
        cQuery := CHANGEQUERY(cQuery)
    EndIf 

    If cQry == "03"
        cQuery := "SELECT TRX_NOME, COUNT(*) QTDE_NOTIFICACOES_MULTAS "
        cQuery += "FROM "+RETSQLNAME("TRX")+" TRX " 
        cQuery += "INNER JOIN "+RETSQLNAME("FP0")+" FP0 "
        cQuery += "ON FP0_FILIAL = '" + xFilial('FP0') + "' "
        cQuery += "AND FP0.D_E_L_E_T_ = ' ' "

        cLinha := "AND FP0_CLI = '"+cCli+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)

        cLinha := "AND FP0_LOJA = '"+cLoja+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)

        cQuery += "INNER JOIN "+RETSQLNAME("FPA")+" FPA " 
        cQuery += "ON FPA_FILIAL = '" + xFilial('FPA') + "' "
        cQuery += "AND FPA_PROJET = FP0_PROJET " 
        cQuery += "AND FPA.D_E_L_E_T_ = ' ' "
        cQuery += "AND FPA_AS <> ' ' "
        cQuery += "WHERE TRX_FILIAL = '" + xFilial('TRX') + "' "
        cQuery += "AND TRX_AS = FPA_AS "
        cQuery += "AND TRX_TPMULT = 'NOTIFICACAO' "
        cQuery += "AND TRX.D_E_L_E_T_ = ' ' "    
        cQuery += "GROUP BY TRX_NOME "
        cQuery += "ORDER BY TRX_NOME "
        cQuery := CHANGEQUERY(cQuery)
    EndIf 

    If cQry == "04"
        cQuery := "SELECT COUNT(*) AS QTDE_BENS_MANUTENCAO "
        cQuery += "FROM "+RETSQLNAME("FQF")+" FQF " 
        cQuery += "INNER JOIN "+RETSQLNAME("FP0")+" FP0 "
        cQuery += "ON FP0_FILIAL = '" + xFilial('FP0') + "' "
        cQuery += "AND FQF_PROJET = FP0_PROJET " 
        
        cLinha := "AND FP0_CLI = '"+cCli+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cLinha := "AND FP0_LOJA = '"+cLoja+"' "    
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cQuery += "AND FP0.D_E_L_E_T_ = ' ' "
        cQuery += "INNER JOIN "+RETSQLNAME("FQE")+" FQE " 
        cQuery += " ON FQE_FILIAL = '" + xFilial('FQE') + "' "
        cQuery += "AND FQE_CODIGO = FQF_SUBST " 
        cQuery += "AND FQE.D_E_L_E_T_ = ' ' "
        cQuery += "WHERE FQF_FILIAL = ' ' " 
        cQuery += "AND FQF_OS <> ' ' "
        cQuery += "AND FQF_DPRFIM = ' ' "
        cQuery += "AND FQF.D_E_L_E_T_ = ' '"
        cQuery := CHANGEQUERY(cQuery)
    EndIf 

    If cQry == "05"
        cQuery := "SELECT COUNT(*) AS QTDE_MOTORISTAS "
        cQuery += "FROM "+RETSQLNAME("DA4")+" DA4 " 
        cQuery += "WHERE DA4_FILIAL = '" + xFilial('DA4') + "' "
        
        cLinha := "AND DA4_CODCLI  = '"+cCli+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cLinha := "AND DA4_LOJCLI = '"+cLoja+"' "  
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cQuery += "AND DA4.D_E_L_E_T_ = ' ' "
        cQuery := CHANGEQUERY(cQuery)
    EndIf 

    If cQry == "06"
        cQuery := "SELECT T4_SERVICO, T4_NOME,TE_CARACTE "
        cQuery += "FROM "+RETSQLNAME("ST4")+" ST4 " 
        cQuery += "INNER JOIN "+RetSqlName("STE")+" STE ON TE_TIPOMAN = T4_TIPOMAN AND STE.D_E_L_E_T_ = ' ' AND TE_CARACTE = 'C' "
        cQuery += "WHERE T4_FILIAL = '" + xFilial('ST4') + "' "
        cQuery += "AND ST4.D_E_L_E_T_ = ' ' "
        cQuery := CHANGEQUERY(cQuery)
    EndIf 

Return(cQuery)


/*/{Protheus.doc} LOCA098A
Funcoes auxiliares para a execucao dos apps
@type function
@since 18/09/2025
/*/
Function LOCA098A(cQry,cBem,cPlaca) 
Local cQuery := ""
Local cComando := ""
Local cLinha   := ""
    
    If cQry == "07"
        cQuery := "SELECT T9_FILIAL, T9_CODBEM, T9_NOME, T9_PLACA, T9_CODFAMI, T6_NOME  "
        cQuery += "FROM "+RETSQLNAME("ST9")+" ST9 " 
        cQuery += "INNER JOIN "+RetSqlName("ST6")+" ST6 ON T6_CODFAMI = T9_CODFAMI AND ST6.D_E_L_E_T_ = ' ' AND T6_FILIAL = '"+xFilial('ST6')+"' "
        cQuery += "WHERE T9_FILIAL = '" + xFilial('ST9') + "' "
        If !Empty(cPlaca)
            
            cLinha := "AND LTRIM(RTRIM(REPLACE(T9_PLACA,'-',''))) = '" + cPlaca + "' "
            cComando := 'cQuery += cLinha '
            &(cComando)

        EndIf    
        If !Empty(cBem)
            
            cLinha := "AND T9_CODBEM = '" + cBem + "' "
            cComando := 'cQuery += cLinha '
            &(cComando)

        EndIf        
        cQuery += "AND ST9.D_E_L_E_T_ = ' ' "
        cQuery := CHANGEQUERY(cQuery)
    EndIf 

Return(cQuery)

/*/{Protheus.doc} LOCA098B
Funcoes auxiliares para a execucao dos apps
@type function
@since 18/09/2025
/*/
Function LOCA098B(cQry,cCodFor,cLojFor,cdtini,cdtfim) 
Local cQuery := ""
Local cComando := ""
Local cLinha   := ""

    If cQry == "08"
        cQuery := "SELECT SF1.F1_DOC NOTA,  "
        cQuery += "MAX(FH1.FH1_ORDEM) OS,  "
        cQuery += "MAX(FH1.FH1_PEDCOM) PED_COMPRA,  "
        cQuery += "SE2.E2_VALOR VLR_TOTAL,  "
        cQuery += "MAX(SF1.F1_EMISSAO) EMISS_NOTA, SE2.E2_NUM NUM_TITU,  "
        cQuery += "MAX(SE2.E2_EMISSAO) EMISS_TIT,  "
        cQuery += "(SE2.E2_PARCELA) PARCELA,  "
        cQuery += "MAX(SE2.E2_VENCREA) PREV_PAGTO,  "
        cQuery += "MAX(SE2.E2_BAIXA) PAGO_EM  "
        cQuery += "FROM "+RETSQLNAME("SE2")+" SE2 " 
        cQuery += "LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL = SE2.E2_FILIAL "
        cQuery += "AND SD1.D1_DOC = SE2.E2_NUM AND SD1.D_E_L_E_T_ = ' '  "
        cQuery += "AND SD1.D1_FORNECE = SE2.E2_FORNECE AND SD1.D1_LOJA = SE2.E2_LOJA "
        cQuery += "LEFT JOIN "+RetSqlName("SF1")+" SF1 ON SF1.F1_FILIAL = SD1.D1_FILIAL  "
        cQuery += "AND SF1.F1_DOC = SD1.D1_DOC AND SF1.D_E_L_E_T_ = ' ' "
        cQuery += "LEFT JOIN "+RetSqlName("FH1")+" FH1 ON FH1.FH1_FILIAL = SD1.D1_FILIAL   "
        cQuery += "AND FH1.FH1_PEDCOM = SD1.D1_PEDIDO AND FH1.FH1_CODIGO = SD1.D1_COD AND FH1.D_E_L_E_T_ = ' ' "
        cQuery += "WHERE SE2.E2_FILIAL = '" + xFilial('SE2') + "' AND SE2.D_E_L_E_T_ = ' ' "
        
        cLinha := "AND SE2.E2_FORNECE = '"+cCodFor+"' AND SE2.E2_LOJA = '"+cLojFor+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cLinha := "AND SE2.E2_EMISSAO >= '"+cdtini+"' AND SE2.E2_EMISSAO <= '"+cdtfim+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cQuery += "GROUP BY SF1.F1_DOC,SE2.E2_VALOR,SE2.E2_PARCELA,SE2.E2_NUM "
        cQuery := CHANGEQUERY(cQuery)

    EndIf 
Return(cQuery)

/*/{Protheus.doc} LOCA098C
Funcoes auxiliares para a execucao dos apps
@type function
@since 18/09/2025
/*/
Function LOCA098C(cQry,cCodFor,cLojFor) 
Local cQuery := ""
Local cComando := ""
Local cLinha   := ""

    If cQry == "09"
        cQuery := "SELECT AIA_DATATE,AIB.AIB_CODFOR,AIB.AIB_LOJFOR, AIB.AIB_CODPRO,  "
        cQuery += "SB1.B1_DESC, SB1.B1_UM,AIB.AIB_PRCCOM,AIB_CODTAB, AIB.AIB_ITEM  "
        cQuery += "FROM "+RETSQLNAME("AIA")+" AIA " 
        cQuery += "INNER JOIN "+RetSqlName("AIB")+" AIB ON AIA.AIA_CODTAB = AIB.AIB_CODTAB "
        cQuery += "AND AIA.AIA_FILIAL = AIB.AIB_FILIAL AND  AIB.AIB_FILIAL = '" + xFilial('AIB') + "' AND AIB.D_E_L_E_T_ = ' ' "
        
        cLinha := "AND AIB.AIB_CODFOR = '"+cCodFor+"' AND AIB.AIB_LOJFOR = '"+cLojFor+"' AND AIB.D_E_L_E_T_ = ' ' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON AIB.AIB_CODPRO = SB1.B1_COD "
        cQuery += "AND SB1.B1_FILIAL = '" + xFilial('SB1') + "' AND SB1.D_E_L_E_T_ = ' '  "
        cQuery += "WHERE AIA.AIA_FILIAL = '" + xFilial('AIA') + "' AND AIA.D_E_L_E_T_ = ' ' "
        
        cLinha := "AND AIA.AIA_DATATE >= '"+DTOS(dDataBase)+"' "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cLinha := "AND AIA.AIA_CODFOR = '"+cCodFor+"' AND AIA.AIA_LOJFOR = '"+cLojFor+"'  "
        cComando := 'cQuery += cLinha '
        &(cComando)
        
        cQuery += "ORDER BY AIB.AIB_CODTAB "
        cQuery := CHANGEQUERY(cQuery)
    EndIf 

Return(cQuery)

/*/{Protheus.doc} LOCA098D
Funcoes auxiliares para a execucao dos apps
@type function
@since 18/09/2025
/*/
Function LOCA098D(cQry,cCodBem) 
Local cQuery := ""
Local cQuer := ""
Local aBindParam := {}

    If cQry == "10"
        cQuery := "SELECT FQ4_CODBEM,FQ4_PROJET,FQ4_OBRA, FQ4_AS,FQ4.R_E_C_N_O_ RECNO "
        cQuery += "FROM "+RETSQLNAME("FQ4")+" FQ4 " 
        cQuery += "WHERE FQ4.FQ4_FILIAL = '" + xFilial('FQ4') + "' AND FQ4.D_E_L_E_T_ = ' ' "
        cQuery += "AND FQ4.FQ4_CODBEM = ? "
        cQuery += "ORDER BY FQ4.R_E_C_N_O_ DESC "
        aadd(aBindParam,cCodBem)

        cQuery := CHANGEQUERY(cQuery)
        MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)

        TRBFQ4->(DbGoTop())

        cQuer := "SELECT *  "
        cQuer += "FROM "+RETSQLNAME("FQ4")+" FQ41 " 
        cQuer += "WHERE FQ41.FQ4_FILIAL = '" + xFilial('FQ4') + "' AND FQ41.D_E_L_E_T_ = ' ' "
        cQuer += "AND FQ41.R_E_C_N_O_ = '"+str(TRBFQ4->RECNO)+"' "

    EndIf 
Return(cQuer)

// passagem pelo advpr
Function LOCA098E
return
