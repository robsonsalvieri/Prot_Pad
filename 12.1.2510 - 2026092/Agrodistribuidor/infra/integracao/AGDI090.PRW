#Include "protheus.ch"
#Include "fwmvcdef.ch"

#DEFINE NF_ENTRADA "0"

/*/{Protheus.doc} AGDI090XML
Funcao para ser chamada pelo fiscal para incluir no XML de transmissao de NF os dados de guia de transito/receituario
@type function
@author carlos.augusto
@since 11/09/2025
@see DAGRODIST-1679 (Pacote dic 016030)
@param cTipo, character, "0" - Entrada, "1" - Saida
@param cNota, character, Nota Fiscal
@param cSerie, character, Serie da Nota Fiscal
@param cClieFor, character, Codigo do Cliente/Fornecedor
@param cLoja, character, Codigo da Loja
@return character, Xml de retorno
/*/
Function AGDI090XML(cTipo, cNota, cSerie, cClieFor, cLoja)
    Local cXmlRecGuia := ""
    
    If "AGRO" $ SUPERGETMV("MV_CADPROD", .F., "") .And. cNota <> Nil .And. cSerie <> Nil .And. cClieFor <> Nil .And. cLoja <> Nil .And. ;
        ((!Empty(cTipo) .And. cTipo == "0" .And. TableInDic("NER") .And. FindFunction("AGDA080")) .Or.  ;
         (!Empty(cTipo) .And. cTipo == "1" .And. TableInDic("NES") .And. FindFunction("AGDA070")))
        
        cXmlRecGuia := AGDI090GER(cTipo, cNota, cSerie, cClieFor, cLoja)
    EndIf
Return cXmlRecGuia


/*/{Protheus.doc} AGDI090XML
Passar para essa funcao "0" - Entrada, "1" - Saida e a chave da tabela SF1 ou SF2.
Com isso, o modelo AGDA070 ou AGDA080 serao chamados para gerar o XML
@type function
@author carlos.augusto
@since 11/09/2025
@see DAGRODIST-1679 (Pacote dic 016030)
@param cTipo, character, "0" - Entrada, "1" - Saida
@param cNota, character, Nota Fiscal
@param cSerie, character, Serie da Nota Fiscal
@param cClieFor, character, Codigo do Cliente/Fornecedor
@param cLoja, character, Codigo da Loja
@return character, Xml de retorno
/*/
Static Function AGDI090GER(cTipo, cNota, cSerie, cClieFor, cLoja)
    Local cXMLAGRO   := ""
	Local aAreaSF1   := SF1->(GetArea())
    Local aAreaSF2   := SF2->(GetArea())
    Local cTabNERNES := IIF(cTipo == NF_ENTRADA, "NER",        "NES")
    Local cTabSF1SF2 := IIF(cTipo == NF_ENTRADA, "SF1",        "SF2")
    Local cModelo    := IIF(cTipo == NF_ENTRADA, "AGDA080",    "AGDA070")
    Local cSubMdlRec := IIF(cTipo == NF_ENTRADA, "NER_RECEIT", "NES_RECE")
    Local cSubMdlGui := IIF(cTipo == NF_ENTRADA, "NER_GUIA",   "NES_GUIA")
    Local cCpoNumRec := IIF(cTipo == NF_ENTRADA, "NER_NUMREC", "NES_NUMREC")
    Local cCpoCPFRes := IIF(cTipo == NF_ENTRADA, "NER_CGC",    "NES_CGC")
    Local cCpoTpGuia := IIF(cTipo == NF_ENTRADA, "NER_TPGUIA", "NES_TPGUIA")
    Local cCpoUFGuia := IIF(cTipo == NF_ENTRADA, "NER_UF",     "NES_UF")
    Local cCpoSerGui := IIF(cTipo == NF_ENTRADA, "NER_SERGUI", "NES_SERGUI")
    Local cCpoNrGuia := IIF(cTipo == NF_ENTRADA, "NER_NUMGUI", "NES_NUMGUI")
    Local oSubMdlRec := Nil
    Local oSubMdlGui := Nil
    lOCAL nX         := 1

    &(cTabSF1SF2)->(DbSetOrder(1))
    If &(cTabSF1SF2)->(DBSeek(FWxFilial(cTabSF1SF2) + cNota + cSerie + cClieFor + cLoja))

        &(cTabNERNES)->(DBSetOrder(1))
        If &(cTabNERNES)->(DBSeek(FWxFilial(cTabNERNES) + cNota + cSerie + cClieFor + cLoja))
            
            cXMLAGRO += "<agropecuario>"

            oModel := FWLoadModel(cModelo)
            oModel:SetOperation(MODEL_OPERATION_VIEW)
            If oModel:Activate()

                oSubMdlRec := oModel:GetModel(cSubMdlRec)

                For nX := 1 To oSubMdlRec:Length()
                    oSubMdlRec:GoLine(nX)
                    If !Empty(oSubMdlRec:GetValue(cCpoCPFRes))
                        cXMLAGRO += "<defensivo>"
                        cXMLAGRO +=     "<nReceituario>" + AllTrim(oSubMdlRec:GetValue(cCpoNumRec)) + "</nReceituario>"
                        cXMLAGRO +=     "<CPFRespTec>"   + AllTrim(oSubMdlRec:GetValue(cCpoCPFRes)) + "</CPFRespTec>"
                        cXMLAGRO += "</defensivo>"
                    EndIf
                Next nX

                oSubMdlGui := oModel:GetModel(cSubMdlGui)

                If oSubMdlGui:GoLine(1) .And. !Empty(oSubMdlGui:GetValue(cCpoNrGuia))
                    cXMLAGRO += "<guiaTransito>"
                    cXMLAGRO +=     "<tpGuia>"    +  AllTrim(oSubMdlGui:GetValue(cCpoTpGuia)) + "</tpGuia>"
                    cXMLAGRO +=     "<UFGuia>"    +  AllTrim(oSubMdlGui:GetValue(cCpoUFGuia)) + "</UFGuia>"
                    cXMLAGRO +=     "<serieGuia>" +  AllTrim(oSubMdlGui:GetValue(cCpoSerGui)) + "</serieGuia>"
                    cXMLAGRO +=     "<nGuia>"     +  AllTrim(oSubMdlGui:GetValue(cCpoNrGuia)) + "</nGuia>"
                    cXMLAGRO += "</guiaTransito>"
				EndIf
                oModel:DeActivate()
            EndIf
            oModel:Destroy()
            oModel := NIL
            cXMLAGRO += "</agropecuario>"
        EndIf
    EndIf
    RestArea(aAreaSF1)
    RestArea(aAreaSF2)
Return cXMLAGRO








