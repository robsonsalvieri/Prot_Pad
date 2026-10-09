#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "totvs.ch"
#Include "ap5mail.ch"
#include "TBICONN.CH"
#Include "Protheus.ch"

/*/LOCM008A.PRW
ITUP Business - TOTVS RENTAL
author Dennis Calabrez
since 31/10/2025
Encerramento da Ordem de Serviço na STJ quando informado OP na SD1 e FH1 estiver aprovada
/*/
Function LOCM008A(nVar,nOpc)
Local cQuery     := ""
Local aBindParam := {}
Local aArea      := GetArea()
Local nTamOrd    := TamSX3("FH1_ORDEM")[1]

    cQuery := "SELECT D1_OP FROM "+RetSqlName("SD1") +" SD1 "
    cQuery += " WHERE D1_FILIAL='"+xFilial("SD1")+"'"
    cQuery += " AND D1_DOC= ? "
    cQuery += " AND D1_SERIE= ? "
    cQuery += " AND D1_FORNECE= ? "
    cQuery += " AND D1_LOJA= ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery := CHANGEQUERY(cQuery)
    aBindParam := {SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA}
	MPSysOpenQuery(cQuery,"TRBSD1",,,aBindParam)

    While !TRBSD1->(Eof())

        FH1->(dbSetOrder(1))
        FH1->(dbSeek(xFilial("FH1")+SubStr(TRBSD1->D1_OP,1,nTamOrd)))

            While !FH1->(Eof()) .AND. FH1->FH1_FILIAL == xFilial("FH1");
                    .AND. FH1->FH1_ORDEM == SubStr(TRBSD1->D1_OP,1,nTamOrd) .AND. FH1->FH1_STAPRO == "2
                //DSERLOCA-9956 - Dennis Calabrez - 12/01/2026
                //Função padrão do SIGAMNT(NG) para encerramento de O.S.
                NGFINAL(FH1->FH1_ORDEM,"000000")
                FH1->(dbSkip())
            EndDo
        TRBSD1->(dbSkip())
    EndDo
    TRBSD1->(dbCloseArea())
    RestArea( aArea )
Return()
