#include "totvs.ch"
#Include 'FWMVCDef.ch'
#Include "ESTDOCREF.CH"

Static __lChkNFCrd  := Nil
Static __lChkAvFnc  := Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ESTDOCREF
Classe utilizada para validações de Estoque no COMDOCREF
@author Squad Entradas
@since 25/02/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Class ESTDOCREF

    data nPosLote   as numeric
    data nPosNumLot as numeric
    data nPosDtVld  as numeric
    data nPosPotenc as numeric
    data nPosDFabri as numeric
    data nPosIdenB6 as numeric
    data nPosItem   as numeric

    Method New() CONSTRUCTOR
    Method AfterTTS()
    Method vldLoteVinc()
    Method isAdjustmentInvoice()
    Method ESTFilD1()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Instancia a classe
@author Squad Entradas
@since 25/02/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class ESTDOCREF

    ::nPosLote   := GetPosSD1("D1_LOTECTL")
    ::nPosNumLot := GetPosSD1("D1_NUMLOTE")
    ::nPosDtVld  := GetPosSD1("D1_DTVALID")
    ::nPosPotenc := GetPosSD1("D1_POTENCI")
    ::nPosDFabri := GetPosSD1("D1_DFABRIC")
    ::nPosIdenB6 := GetPosSD1("D1_IDENTB6")
    ::nPosItem   := GetPosSD1("D1_ITEM")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Pós-validação do modelo MVC do Documento de Referência (COMDOCREF).
Preenche automaticamente lote, sublote e data de validade nos itens
do complemento a partir do documento de origem, quando o produto possui
rastreabilidade (MV_RASTRO). A tabela de origem consultada varia conforme
o tipo de ajuste: SD1 para notas de redução de valores (compra) e SD2
para notas de recusa parcial (venda).
@author Squad Entradas
@since 25/02/2026
@version 1.2
@param oModel, object, modelo MVC do documento
@return logical, sempre .T. (preenchimento automático, não bloqueia)
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel) Class ESTDOCREF
    Local lContinua   := .F.
    Local oModelItm   := Nil
    Local oModelSel   := Nil
    Local nX          := 0
    Local aArea       := {}
    Local cChvBusca   := ""
    Local nLiItem     := 0

    If __lChkNFCrd == Nil
	    __lChkNFCrd := findFunction("backoffice.stock.inbounddocument.updateB2FromD1")
    EndIf

    If __lChkNFCrd
        //Continua se a nota fiscal de crédito for uma redução,recusa parcial ou total
        lContinua := ::isAdjustmentInvoice(oModel)
    EndIf

    If lContinua

        oModelItm := oModel:GetModel("ITENSDETAIL")
        oModelSel := oModel:GetModel("SELECTDETAIL")

        aArea := SD2->(GetArea())

        SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

        // SELECTDETAIL possui apenas 1 linha (dados do cabeçalho da NF de origem)
        oModelSel:GoLine(1)

        // Limpa os campos de todos os itens da nota de entrada para refazer a amarração no próximo loop
        For nX := 1 To Len(aCols)
            If ::nPosIdenB6 > 0
                aCols[nX][::nPosIdenB6] := CriaVar("D1_IDENTB6") 
            EndIf
            If ::nPosLote > 0
                aCols[nX][::nPosLote]   := CriaVar("D1_LOTECTL")
            EndIf
            If ::nPosNumLot > 0
                aCols[nX][::nPosNumLot] := CriaVar("D1_NUMLOTE")
            EndIf
            If ::nPosDtVld > 0
                aCols[nX][::nPosDtVld]  := dDataBase
            EndIf
            If ::nPosPotenc > 0
                aCols[nX][::nPosPotenc] := 0
            EndIf
            If ::nPosDFabri > 0
                aCols[nX][::nPosDFabri] := CToD("")
            EndIf
        Next nX

        For nX := 1 To oModelItm:Length()
            If oModelSel:IsDeleted()
                Loop
            EndIf

            oModelItm:GoLine(nX)

            nLiItem := AScan(aCols, {|i| i[::nPosItem] == oModelItm:GetValue("D1_ITEM") })

            // Busca o item original na SD2 para copiar identb6/lote/sublote/validade/potencia/fabricacao
            cChvBusca := FWxFilial("SD2") + oModelSel:GetValue("D1_DOC") + oModelSel:GetValue("D1_SERIE") + ;
                        oModelSel:GetValue("D1_FORNECE") + oModelSel:GetValue("D1_LOJA") + ;
                        oModelSel:GetValue("D1_COD") + oModelSel:GetValue("D1_ITEM")

            If SD2->(MsSeek(cChvBusca))
                If ::nPosIdenB6 > 0
                    aCols[nLiItem][::nPosIdenB6] := SD2->D2_IDENTB6
                EndIf
                
                If !Rastro(oModelSel:GetValue("D1_COD"))
                    Loop
                Else
                    If ::nPosLote > 0
                        aCols[nLiItem][::nPosLote] := SD2->D2_LOTECTL
                    EndIf
                    If ::nPosNumLot > 0
                        aCols[nLiItem][::nPosNumLot] := SD2->D2_NUMLOTE
                    EndIf
                    If ::nPosDtVld > 0
                        aCols[nLiItem][::nPosDtVld] := SD2->D2_DTVALID
                    EndIf
                    If ::nPosPotenc > 0
                        aCols[nLiItem][::nPosPotenc] := SD2->D2_POTENCI
                    EndIf
                    If ::nPosDFabri > 0
                        aCols[nLiItem][::nPosDFabri] := SD2->D2_DFABRIC
                    EndIf
                EndIf
            EndIf
        Next nX

        SD2->(RestArea(aArea))
    EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} vldLoteVinc
Valida se o produto possui rastreabilidade (lote/sublote) e, nesse caso,
permite apenas um documento vinculado por item no COMDOCREF.
@author Squad Entradas
@type method
@since 26/06/2026
@version 1.0
@param cCodProd, character, codigo do produto selecionado no filtro
@param cDocVinc, character, documento ja vinculado no grid SELECTDETAIL
@param cIdentB6, character, código do campo D1_IDENTB6 que indicará que a operação controla poder de terceiros
@return logical, .T. = permite vincular / .F. = bloqueado (produto com lote ja possui vinculo)
/*/
//-------------------------------------------------------------------
Method vldLoteVinc(cCodProd, cDocVinc, cIdentB6) Class ESTDOCREF
    Local lRet := .T.

    If __lChkAvFnc == Nil
	    __lChkAvFnc := findFunction("backoffice.stock.averagecost.creditnote.IsNotaCredito")
    EndIf

    If __lChkAvFnc
        If Type("cTipo") == "C" .And. Type("cTpCompl") == "C"
            If backoffice.stock.averagecost.creditnote.IsNotaCredito(Nil,cTipo,cTpCompl)
                If (Rastro(cCodProd) .Or. !Empty(cIdentB6)) .And. !Empty(cDocVinc)
                    Help(NIL, NIL, "A103CRDLOT", NIL, STR0001, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002})
                    lRet := .F.
                EndIf
            EndIf
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} isPartialRejectionInvoice
Retorna se a nota fiscal é uma redução de valores ou recusa parcial.
Informa também, por referência, o alias da tabela de origem que deve
ser usada na busca do item original: SD1 para redução de valores
(vínculo com documento de compra) ou SD2 para recusa parcial (vínculo
com documento de venda).
@author Squad Entradas
@since 10/07/2026
@version 1.1
@param oModel, objeto, modelo
@return logical, .T. = é uma redução de valores, recusa parcial ou total / .F. = não se aplica
/*/
//-------------------------------------------------------------------
Method isAdjustmentInvoice(oModel) Class ESTDOCREF
    Local lRet := .F.

    If (Type("cTipo") == "C" .And. Type("cTpCompl") == "C") .And. (oModel:HasModel("ITENSDETAIL"))
        If __lChkAvFnc == Nil
            __lChkAvFnc := findFunction("backoffice.stock.averagecost.creditnote.IsNotaCredito")
        EndIf

        If __lChkAvFnc
            If backoffice.stock.averagecost.creditnote.IsNotaCredito(Nil,cTipo,cTpCompl)
                lRet := .T.
            EndIf
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTFilD1
Adiciona os campos de estoque no aCols do mata103 quando utilizado nota
de crédito de redução com formulário próprio Sim e Não.
@author Squad Entradas
@since 17/07/2026
@version 1.0
@param oModel, objeto, modelo
/*/
//-------------------------------------------------------------------
Method ESTFilD1(aLinha,cDocSD1,cSerieSD1,cFornece,cLoja,cAliasSD1) Class ESTDOCREF
    Local aAreaSD1 := SD1->(GetArea())
    Local cCod     := (cAliasSD1)->D1_COD
    Local cItem    := (cAliasSD1)->D1_ITEM
    Local cChave   := ""

    SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

    cChave := FWxFilial("SD1")+cDocSD1+cSerieSD1+cFornece+cLoja+cCod+cItem
    If SD1->(MsSeek(cChave))
        If !Empty(SD1->D1_IDENTB6)
            AAdd(aLinha, { "D1_IDENTB6", SD1->D1_IDENTB6, Nil } )
        Endif

        If Rastro(cCod)
            AAdd(aLinha, { "D1_LOTECTL", SD1->D1_LOTECTL, Nil } )
            AAdd(aLinha, { "D1_NUMLOTE", SD1->D1_NUMLOTE, Nil } )
            AAdd(aLinha, { "D1_DTVALID", SD1->D1_DTVALID, Nil } )
            AAdd(aLinha, { "D1_POTENCI", SD1->D1_POTENCI, Nil } )
            AAdd(aLinha, { "D1_DFABRIC", SD1->D1_DFABRIC, Nil } )
        EndIf
    EndIf

    SD1->(RestArea(aAreaSD1))

Return
