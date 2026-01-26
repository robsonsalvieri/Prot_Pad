#INCLUDE "TOTVS.ch"
#Include "fwmvcdef.ch"

#DEFINE NOTA_FISCAL_SERVICE agd.notaFiscalSaidaService.agdNotaFiscalSaidaService
#DEFINE NEGOCIO_STATUS_SERVICE agd.negocioStatusService.agdNegocioStatusService
#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService

/*/{Protheus.doc} AGDI051
Funcao executada pelo MATA103 ao Eliminar Nota Devolução
@type function
@version 12
@author Gilson.Venturi
@since 25/02/2025
@return variant, nil
/*/
Function AGDI051(lDeleta)
	Default lDeleta := .F.

	If lDeleta
		AGDI051Agd()
		AGDI051NER()
	EndIf

Return nil

/*/{Protheus.doc} AGDI051Agd
	(Atualizacoes no barter apos exclusao de NF)
	@type  Static Function
	@author Gilson.Venturi
	@since 25/02/2025
/*/
Static Function AGDI051Agd()
	Local aAreaAtu		:= GetArea()
	Local aAreaSF1 		:= SF1->( GetArea() )
	Local aAreaSD1 		:= SD1->( GetArea() )
	Local nQtde			:= 0
	Local cCodNegocio	:= ""
	Local cVersaoNegocio := ""
	Local oNFService	:= nil
	Local oNegocioService := nil
	Local oNegocioStatusService	:= nil

	if SUPERGETMV("MV_SIGAAGD", .f., .f.)

		SD1->(dbSetOrder( 1 ))
		If SD1->(dbSeek( xFilial( "SD1" ) + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )
			While .Not. SD1->( Eof() ) .and. !Empty(SD1->D1_NFORI) .and.;
					SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)

				cChaveNF := xFilial("SD1") + SD1->( D1_NFORI + D1_SERIORI + D1_FORNECE + D1_LOJA + D1_COD ) + Padr(D1_ITEMORI, TamSX3("D2_ITEM")[1])
				nQtde	 := SD1->D1_QUANT

				dbSelectArea('NED')
				NED->(dbSetOrder(2))
				NED->(DBGoTop())
				If NED->(dbSeek(cChaveNF))
					nQtde := NED->NED_QTDDEV - nQtde
					cCodNegocio := NED->NED_CODBRT
				EndIf

				oNFService := NOTA_FISCAL_SERVICE():new(cChaveNF)
				oNFService:atualizarQuantidadeDevolvida(nQtde)
				FreeObj(oNFService)

				SD1->(DBSkip(1))
			EndDo


			If !Empty(cCodNegocio)
				oNegocioService := NEGOCIO_SERVICE():New()
				cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(cCodNegocio)
				oNegocioStatusService := NEGOCIO_STATUS_SERVICE():New(FWxFilial("NEA") + cCodNegocio + cVersaoNegocio)
				oNegocioStatusService:informarInstrucaoEmbarque()
				FreeObj(oNegocioService)
				FreeObj(oNegocioStatusService)
			EndIf

		endif
	endif
	RestArea( aAreaSD1 )
	RestArea( aAreaSF1 )
	RestArea( aAreaAtu )
Return


/*/{Protheus.doc} AGDI051NER
	(Exclusao de vinculo de receituario/guia de transito)
	@type  Static Function
	@author carlos.augusto
	@since 08/09/2025
/*/
Static Function AGDI051NER()
	Local oModel   := nil
	Local aAreaSD1 := SD1->(GetArea())

	If "AGRO" $ SUPERGETMV("MV_CADPROD", .F., "")
		If TableInDic("NER") .And. (DBSelectArea("NCR"), NCR->(FieldPos("NCR_EMREC"))) > 0 .And. NCR->(FieldPos("NCR_EMGUIA")) > 0

			NER->(DBSetOrder(1))
			If NER->(DBSeek(FWxFilial("NER") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

				oModel := FWLoadModel("AGDA080")
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				If oModel:Activate()
					If oModel:GetModel("NER_RECEIT"):CanDeleteLine()
						oModel:GetModel("NER_RECEIT"):DelAllLine()
					EndIf
					If oModel:GetModel("NER_GUIA"):CanDeleteLine()
						oModel:GetModel("NER_GUIA"):DelAllLine()
					EndIf
					If oModel:VldData()
						oModel:CommitData()
					EndIf
					oModel:DeActivate()
				EndIf
				oModel:Destroy()
				oModel := NIL
			EndIf
		Endif
	EndIf
	RestArea(aAreaSD1)
Return
