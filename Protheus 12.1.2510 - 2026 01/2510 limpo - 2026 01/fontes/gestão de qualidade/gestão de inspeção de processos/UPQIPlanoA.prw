#include "protheus.ch"
#include "UPQIPLANOA.CH"

/*/{Protheus.doc} UPQIPlano
@type Method
@author thiago.rover
@since 08/11/2023
@version 12.1.2310
/*/
MAIN FUNCTION UPQIPlanoA()

    Local oMainClass := UPQIPlanoAmostragemClass():New()
    oMainClass:ajustaPlanoDeAmostragem()

RETURN

/*/{Protheus.doc} UPQIPlanoAmostragemClass
Regras de Negocio 
@Type Class
@author thiago.rover
@since 08/11/2023
@version 12.1.2310
/*/
CLASS UPQIPlanoAmostragemClass FROM LongNameClass

    METHOD new() CONSTRUCTOR
    METHOD ajustaPlanoDeAmostragem()

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author    thiago.rover
@since     08/11/2023
@return Self, objeto, instancia da Classe UPQIPlanoAmostragemClass
/*/
METHOD new() CLASS UPQIPlanoAmostragemClass
RETURN Self

/*/{Protheus.doc} UPDQIPPLANO
Função responsável por ajustar as seguintes situções:
1- Criar registros na tabela QQH para planos de amostragem tipo TEXTO com base nas tabelas QP7 e QP8.
2- Desvincula registros nas tabelas QP7 e QP8 para planos de amostragem que não for tipo TEXTO.
@type Method
@author thiago.rover
@since 07/11/2023
@version 12.1.2310
/*/
METHOD ajustaPlanoDeAmostragem() CLASS UPQIPlanoAmostragemClass
   
    Local aCorrecoes   := {}
    Local aSM0         := {}
    Local cAliasSemQQH := ""
    Local cQuery       := {}
    Local lAmbiente    := .T.
    Local nIndSM0      := 0
    Local oQLTManager  := QLTQueryManager():New()

    If Empty(oQLTManager:cBanco)
        TCLink()
    EndIf

    OpenSM0()
    aSM0 := FWAllGrpCompany()

    For nIndSM0 := 1 To Len(aSM0)
        RPCSetType(3)
        If lAmbiente := RpcSetEnv(aSM0[nIndSM0])
            cQuery := " SELECT DISTINCT SEMQQH.FILIAL, "
            cQuery +=                 " SEMQQH.PRODUTO, "
            cQuery +=                 " SEMQQH.REVISAO, "
            cQuery +=                 " SEMQQH.OPERACAO, "
            cQuery +=                 " SEMQQH.ENSAIO, "
            cQuery +=                 " SEMQQH.PLAMO, " 
            cQuery +=                 " SEMQQH.CODOPERACAO, " 
            cQuery +=                 " SEMQQH.DESCRICAOPLANO "
            cQuery += " FROM " + RetSqlName("QP6") + " QP6 "
            cQuery += " INNER JOIN "
            cQuery +=   " ( SELECT QP7.QP7_FILIAL AS FILIAL, "
            cQuery +=               " QP7.QP7_PRODUT AS PRODUTO, "
            cQuery +=               " QP7.QP7_REVI AS REVISAO, "
            cQuery +=               " QP7.QP7_OPERAC AS OPERACAO, "
            cQuery +=               " QP7.QP7_ENSAIO AS ENSAIO, "
            cQuery +=               " QP7.QP7_PLAMO AS PLAMO, "
            cQuery +=               " QP7.QP7_CODREC AS CODOPERACAO, "
            cQuery +=               " QP7.QP7_DESPLA AS DESCRICAOPLANO "
            cQuery +=     " FROM " + RetSqlName("QQH") + " QQH "
            cQuery +=     " RIGHT JOIN " + RetSqlName("QP7") + " QP7 "
            cQuery +=             " ON " + oQLTManager:MontaQueryComparacaoFiliaisComCamposEspecificos("QQH", "QQH_FILIAL", "QP7", "QP7_FILIAL")
            cQuery +=             " AND QQH.QQH_PRODUT = QP7.QP7_PRODUT "
            cQuery +=             " AND QQH.QQH_REVI = QP7.QP7_REVI "
            cQuery +=             " AND QQH.QQH_ENSAIO = QP7.QP7_ENSAIO "
            cQuery +=             " AND QQH.QQH_CODREC = QP7.QP7_CODREC "
            cQuery +=             " AND QQH.QQH_OPERAC = QP7.QP7_OPERAC "
            cQuery +=             " AND QQH.D_E_L_E_T_ = ' ' "
            cQuery +=     " WHERE QP7.QP7_PLAMO <> ' ' "
            cQuery +=             " AND QP7.D_E_L_E_T_ = ' ' "
            cQuery +=             " AND QQH.QQH_PRODUT IS NULL "
            cQuery +=     " UNION ALL "
            cQuery +=     " SELECT QP8.QP8_FILIAL AS FILIAL, "
            cQuery +=            " QP8.QP8_PRODUT AS PRODUTO, "
            cQuery +=            " QP8.QP8_REVI AS REVISAO, "
            cQuery +=            " QP8.QP8_OPERAC AS OPERACAO, "
            cQuery +=            " QP8.QP8_ENSAIO AS ENSAIO, "
            cQuery +=            " QP8.QP8_PLAMO AS PLAMO, "
            cQuery +=            " QP8.QP8_CODREC AS CODOPERACAO, "
            cQuery +=            " QP8.QP8_DESPLA AS DESCRICAOPLANO "
            cQuery +=     " FROM " + RetSqlName("QQH") + " QQH "
            cQuery +=     " RIGHT JOIN " + RetSqlName("QP8") + " QP8 "
            cQuery +=             " ON " + oQLTManager:MontaQueryComparacaoFiliaisComCamposEspecificos("QQH", "QQH_FILIAL", "QP8", "QP8_FILIAL")
            cQuery +=             " AND QQH.QQH_PRODUT = QP8_PRODUT "
            cQuery +=             " AND QQH.QQH_REVI = QP8_REVI "
            cQuery +=             " AND QQH.QQH_ENSAIO = QP8.QP8_ENSAIO "
            cQuery +=             " AND QQH.QQH_CODREC = QP8.QP8_CODREC "
            cQuery +=             " AND QQH.QQH_OPERAC = QP8.QP8_OPERAC "
            cQuery +=             " AND QQH.D_E_L_E_T_ = ' ' "
            cQuery +=     " WHERE QP8.QP8_PLAMO <> ' ' "
            cQuery +=       " AND QP8.D_E_L_E_T_ = ' ' "
            cQuery +=       " AND QQH.QQH_PRODUT IS NULL ) SEMQQH ON SEMQQH.PRODUTO = QP6.QP6_PRODUT "
            cQuery +=       " AND SEMQQH.REVISAO = QP6.QP6_REVI "
            cQuery +=       " AND " + oQLTManager:MontaQueryComparacaoFiliaisComCamposEspecificos("QP6", "QP6.QP6_FILIAL", "QP7", "SEMQQH.FILIAL")
            cQuery += " WHERE QP6.D_E_L_E_T_ = ' ' "
            
            cQuery := oQLTManager:changeQuery(cQuery, TCGetDb())
            cAliasSemQQH := oQLTManager:executeQuery(cQuery)

            DbSelectArea("QQH")
            DbSelectArea("QP7")
            QP7->(DbSetOrder(1))
            DbSelectArea("QP8")
            QP8->(DbSetOrder(1))
            While (cAliasSemQQH)->(!Eof())
                // Plano de Amostragem tipo Texto
                If (cAliasSemQQH)->(PLAMO) == 'T'
                    RecLock("QQH",.T.)
                    QQH->QQH_FILIAL := xFilial("QQH", (cAliasSemQQH)->FILIAL)
                    QQH->QQH_PRODUT := (cAliasSemQQH)->PRODUTO
                    QQH->QQH_REVI := (cAliasSemQQH)->REVISAO
                    QQH->QQH_OPERAC := (cAliasSemQQH)->OPERACAO
                    QQH->QQH_ENSAIO := (cAliasSemQQH)->ENSAIO
                    QQH->QQH_PLANO := "TEXTO"
                    QQH->QQH_AMOST := "TX"
                    QQH->QQH_CODREC := (cAliasSemQQH)->CODOPERACAO
                    QQH->QQH_DESCRI := ALLTRIM((cAliasSemQQH)->DESCRICAOPLANO)
                    QQH->(MsUnLock())
                    QQH->(FKCOMMIT())
                    
                    // STR0001 - Criação da tabela QQH - Plano de Amostragem Ensaios  
                    // STR0004 - GRUPO DE EMPRESA
                    aAdd(aCorrecoes, STR0001 ;
                                    + " ' "+STR0004+ " ' "  + aSM0[nIndSM0] ;
                                    + " ' , QQH_FILIAL: ' " + xFilial("QQH") ;
                                    + " ' , QQH_PRODUT: ' " + ALLTRIM((cAliasSemQQH)->PRODUTO) ;  
                                    + " ' , QQH_REVI: ' "   + (cAliasSemQQH)->REVISAO ;
                                    + " ' , QQH_OPERAC: ' " + (cAliasSemQQH)->OPERACAO ;
                                    + " ' , QQH_ENSAIO: ' " + (cAliasSemQQH)->ENSAIO ;
                                    + " ' , QQH_PLANO: ' "  + "TEXTO" ;
                                    + " ' , QQH_AMOST: ' "  + "TX" ;
                                    + " ' , QQH_CODREC: ' " + (cAliasSemQQH)->CODOPERACAO ;
                                    + " ' , QQH_DESCRI: ' " + ALLTRIM((cAliasSemQQH)->DESCRICAOPLANO) ;
                                    + " ' , RECNO: ' "      + cValToChar(QQH->(Recno())) + " '.") 
                Else
                    If QP7->(DbSeek((cAliasSemQQH)->FILIAL+(cAliasSemQQH)->PRODUTO+(cAliasSemQQH)->REVISAO+(cAliasSemQQH)->CODOPERACAO+(cAliasSemQQH)->OPERACAO+(cAliasSemQQH)->ENSAIO))
                        // STR0002 - Remoção da ligação do registro da QP7 - Ensaios Mensuráveis Produtos com o Plano de Amostragem 
                        // STR0004 - GRUPO DE EMPRESA
                        aAdd(aCorrecoes, STR0002 ;
                            + " ' "+STR0004+ " ' "  + aSM0[nIndSM0] ;
                            + " ' , QP7_FILIAL: ' " + QP7->QP7_FILIAL ;
                            + " ' , QP7_PRODUT: ' " + ALLTRIM(QP7->QP7_PRODUT) ;  
                            + " ' , QP7_REVI: ' "   + QP7->QP7_REVI ;
                            + " ' , QP7_CODREC: ' " + QP7->QP7_CODREC ;
                            + " ' , QP7_OPERAC: ' " + QP7->QP7_OPERAC ;
                            + " ' , QP7_ENSAIO: ' " + QP7->QP7_ENSAIO ;
                            + " ' , QP7_PLAMO: ' "  + QP7->QP7_PLAMO ;
                            + " ' , QP7_DESPLA: ' " + ALLTRIM(QP7->QP7_DESPLA) ;
                            + " ' , RECNO: ' "      + cValToChar(QP7->(Recno())) + " '.")

                        // Limpeza da QP7
                        Reclock("QP7",.F.)
                        QP7->QP7_PLAMO := ""
                        QP7->QP7_DESPLA := ""
                        QP7->(MsUnLock())
                        QP7->(FKCOMMIT())
                    EndIf

                    If QP8->(DbSeek((cAliasSemQQH)->FILIAL+(cAliasSemQQH)->PRODUTO+(cAliasSemQQH)->REVISAO+(cAliasSemQQH)->CODOPERACAO+(cAliasSemQQH)->OPERACAO+(cAliasSemQQH)->ENSAIO))
                        // STR0003 - Remoção da ligação do registro da QP8 - Ensaios Textos dos Produtos com o Plano de Amostragem  
                        // STR0004 - GRUPO DE EMPRESA 
                        aAdd(aCorrecoes, STR0003 ;
                            + " ' "+STR0004+ " ' "  + aSM0[nIndSM0] ;
                            + " ' , QP8_FILIAL: ' " + QP8->QP8_FILIAL ;
                            + " ' , QP8_PRODUT: ' " + ALLTRIM(QP8->QP8_PRODUT) ;  
                            + " ' , QP8_REVI: ' "   + QP8->QP8_REVI ;
                            + " ' , QP8_CODREC: ' " + QP8->QP8_CODREC ;
                            + " ' , QP8_OPERAC: ' " + QP8->QP8_OPERAC ;
                            + " ' , QP8_ENSAIO: ' " + QP8->QP8_ENSAIO ;
                            + " ' , QP8_PLAMO: ' "  + QP8->QP8_PLAMO ;
                            + " ' , QP8_DESPLA: ' " + ALLTRIM(QP8->QP8_DESPLA) ;
                            + " ' , RECNO: ' "      + cValToChar(QP8->(Recno())) + " '.") 

                        // Limpeza da QP8
                        Reclock("QP8",.F.)
                        QP8->QP8_PLAMO := ""
                        QP8->QP8_DESPLA := ""
                        QP8->(MsUnLock())
                        QP8->(FKCOMMIT())
                    EndIf
                Endif 
                (cAliasSemQQH)->(DbSkip())
            ENDDO
            (cAliasSemQQH)->(DbCloseArea())
        Endif

        If !Empty(aCorrecoes)
            oQLTManager:ConfirmaNecessidadeDeExecucaoMensalViaSemaforo("002", "QIPJUSQQH", IIF(!Empty(aCorrecoes),aCorrecoes,{"ERRO"} ), 9999) //9999 meses - 833 anos
        EndIf

		FwFreeArray(aCorrecoes)
        aCorrecoes := {}

        RpcClearEnv()

    Next nIndSM0

	FwFreeArray(aSM0)
    aSM0 := {}
    TCUnlink()

RETURN 
