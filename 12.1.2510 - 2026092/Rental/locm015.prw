#include "totvs.ch"
#include "PROTHEUS.ch"
#Include "locm015.ch"

/*/{Protheus.doc} LOCM015

Prerequisito: parametro MV_LOCBAC = .T. e tabela FQZ no dicionario.

@type    function
@author  Alessandro Gois
@since   30/06/2026
@version 1.0
@return  logical, .T. = permite a exclusao / .F. = bloqueia a exclusao
/*/
Function LOCM015()

Local aArea     := { SF1->(GetArea()), SC5->(GetArea()), GetArea() }
Local lRet       := .T.
//Local cPedFQZ    := ""
Local cMsgBlk    := ""
Local cQuery     := ""
Local cAliasQ    := GetNextAlias()
Local aBindParam := {}
Local lBloqueia  := .F.

    // ------------------------------------------------------------------
    // Prerequisito: tabela FQZ precisa existir no dicionario
    // ------------------------------------------------------------------
    If !ChkFile("FQZ") .or. file("\SYSTEM\LOCM015_1.TXT")
        AEval(aArea, {|x| RestArea(x)})
        Return lRet
    EndIf

    // ------------------------------------------------------------------
    // Busca todos os registros da FQZ vinculados ao documento de entrada
    // atual (SF1 esta posicionado pelo chamador - A103VldEXC).
    //
    // Campos de referencia — ajuste os nomes conforme o dicionario:
    //   FQZ_FILIAL  Filial
    //   FQZ_DOC     Numero do documento de entrada  (F1_DOC)
    //   FQZ_SERIE   Serie do documento              (F1_SERIE)
    //   FQZ_FORNE  Codigo do fornecedor            (F1_FORNECE)
    //   FQZ_LOJA    Loja do fornecedor              (F1_LOJA)
    // ------------------------------------------------------------------
    cQuery := "SELECT  R_E_C_N_O_ AS RECNO_FQZ "
    cQuery += "FROM   " + RetSqlName("FQZ") + " "
    cQuery += "WHERE  FQZ_FILIAL = '" + xFilial("FQZ") + "' "
    cQuery += "  AND  FQZ_DOC    = ? "
    If !Empty(AllTrim(SF1->F1_SERIE))
        cQuery += "  AND  FQZ_SERIE  = ? "
    EndIf
    cQuery += "  AND  FQZ_FORNE  = ? "
    cQuery += "  AND  FQZ_LOJA   = ? "
    cQuery += "  AND  FQZ_PV <> ' ' "
    cQuery += "  AND  FQZ_PV <> 'X' "
    cQuery += "  AND  D_E_L_E_T_ = ' '"

    AAdd(aBindParam, AllTrim(SF1->F1_DOC))
    If !Empty(AllTrim(SF1->F1_SERIE))
        AAdd(aBindParam, AllTrim(SF1->F1_SERIE))
    EndIf    
    AAdd(aBindParam, AllTrim(SF1->F1_FORNECE))
    AAdd(aBindParam, AllTrim(SF1->F1_LOJA))

    LOCACLOSE(cAliasQ)

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery, cAliasQ, , , aBindParam)

    if !(cAliasQ)->(eof())
        lBloqueia := .T.
    endif
    LOCACLOSE(cAliasQ)


    If lBloqueia
        // Bloqueia a exclusao e orienta o usuario

        cMsgBlk := STR0001 //"Existem pedidos de faturamento vinculados a este documento de entrada. nao sera possivel excluir. "
 
        Help(" ", 1, "LOCM015", , cMsgBlk, 1, 0)
        lRet := .F.

    EndIf

    AEval(aArea, {|x| RestArea(x)})

Return lRet
