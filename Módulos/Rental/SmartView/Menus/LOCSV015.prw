#include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCSV015
Função utilizada para execução do objeto de negócio Receita e Custo
@type  Função
@author Leonardo Pacheco Fuga
@since  13/08/2025
/*/
//-------------------------------------------------------------------
Function LOCSV015()

local lSuccess As logical
local oSmartView as object
Local aRet := GetUserInfoArray()
Local cConteudo := ""
Local cQuery := ""
Local cArquivo
local nX
local cComando

    If GetRpoRelease() > "12.1.2210" 

        oSmartView := totvs.framework.smartview.callSmartView():new("sigaloc.sv.loc.receitacusto",,,,,.F.,,.T.,)
        //oSmartView := totvs.framework.smartview.callSmartView():new("loc.sv.rental.custoporequipamento.default.dg", "data-grid")
        oSmartView:setShowWizard(.T.)
        lSuccess := oSmartView:executeSmartView(.T.)

        oSmartView:destroy()

        For nX := 1 to len(aRet)
            cArquivo := "\SYSTEM\LOCADEL-"+alltrim(str(aRet[nX][3]))+".TXT"
            If file(cArquivo)
                cComando := 'cConteudo := MemoRead(cArquivo)'
                &(cComando)
                cComando := 'cQuery := "DROP TABLE "+cConteudo'
                &(cComando)
                TCSQLEXEC(cQuery)
                cComando := 'FErase(cArquivo)'
                &(cComando)
            EndIf
        Next
    EndIf

Return

