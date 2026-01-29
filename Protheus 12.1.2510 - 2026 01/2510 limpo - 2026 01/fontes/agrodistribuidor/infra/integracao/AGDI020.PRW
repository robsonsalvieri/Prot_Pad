#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDEF.CH"
#DEFINE NOTA_FISCAL_SERVICE agd.notaFiscalSaidaService.agdNotaFiscalSaidaService
#DEFINE RECEITUARIO_SERVICE agd.receituarioService.agdReceituarioService

/*/{Protheus.doc} AGDI020
Funcao executada pelo módulo de faturamento ao excluir um documento de saida
@type function
@version 12
@author jean.schulze
@since 22/01/2025
@return variant, nil
/*/
Function AGDI020()
	Local aArea := FWgetArea()

	If SUPERGETMV("MV_SIGAAGD", .f., .f.)
		desvincNF()
	EndIf

	desvincNES()

	FWrestArea(aArea)
Return nil

/*/{Protheus.doc} desvincNF
Remove o vinculo dos itens da tabela NED (Itens da Instrução de Embarque) referentes a nota fiscal de saida posicionada (SF2)
@type function
@version 12
@author jc.maldonado
@since 10/09/2025
/*/
Static Function desvincNF()
	Local cChaveSF2 := SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA
	Local cFilSD2   := ""
	Local cChaveNF  := ""
	Local oService  := Nil
	Local oServRec  := Nil

	dbselectArea("SD2")
	SD2->(dbSetOrder(3))
	SD2->(dbGoTop())
	If SD2->(dbSeek(FWxFilial("SD2") + cChaveSF2))
		cFilSD2 := FWxFilial("SD2")
		While SD2->(!Eof());
				.And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == (cFilSD2 + cChaveSF2)

			cChaveNF := cFilSD2 + SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM)

			oService := NOTA_FISCAL_SERVICE():new(cChaveNF)
			oService:desvincularNotaFiscal()
			FWFreeObj(oService)

			SD2->(DBSkip(1))
		EndDo
	EndIf

	oServRec := RECEITUARIO_SERVICE():new()
	oServRec:desvincularNotaReceita(SF2->F2_DOC, SF2->F2_SERIE)
	FWFreeObj(oServRec)

Return

/*/{Protheus.doc} desvincNES
Realiza a exclusao dos registros da tabela NES (Guia de Transporte/Receituario) referentes a nota fiscal de saida posicionada (SF2)
@type function
@version 12
@author jc.maldonado
@since 10/09/2025
/*/
Static Function desvincNES()
	Local oModel := Nil

	If ! "AGRO" $ SUPERGETMV("MV_CADPROD", .F., "");
			.OR. Select("SF2") <= 0;
			.OR. ! FWAliasInDic("NES");
			.OR. ! FWAliasInDic("NCR");
			.OR. (DBSelectArea("NCR"), NCR->(FieldPos("NCR_EMREC"))) <= 0;
			.OR. NCR->(FieldPos("NCR_EMGUIA")) <= 0
		Return
	EndIf

	DBSelectArea("NES")
	NES->(DBSetOrder(1))
	NES->(DBGoTop())
	If ! NES->(DBSeek(FWxFilial("NES") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
		Return
	EndIf

	oModel := FwLoadModel("AGDA070")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	If oModel:Activate()
		If oModel:GetModel("NES_RECE"):CanDeleteLine()
			oModel:GetModel("NES_RECE"):DelAllLine()
		EndIf

		If oModel:GetModel("NES_GUIA"):CanDeleteLine()
			oModel:GetModel("NES_GUIA"):DelAllLine()
		EndIf

		If oModel:VldData()
			oModel:CommitData()
		EndIf

		oModel:DeActivate()
	EndIf

	oModel:Destroy()
	oModel := Nil
	FWFreeObj(oModel)
Return
