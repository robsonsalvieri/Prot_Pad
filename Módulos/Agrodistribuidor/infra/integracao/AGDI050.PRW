#INCLUDE "TOTVS.ch"
#DEFINE NOTA_FISCAL_SERVICE agd.notaFiscalSaidaService.agdNotaFiscalSaidaService
#DEFINE NEGOCIO_STATUS_SERVICE agd.negocioStatusService.agdNegocioStatusService
#DEFINE NEGOCIO_SERVICE agd.negocioService.agdNegocioService
#DEFINE IE_ITEM_REPOSITORY agd.instrucaoEmbarqueItemRepository.agdInstrucaoEmbarqueItemRepository

/*/{Protheus.doc} AGDI050
Funcao executada pelo MATA103 ao Registrar Nota Devolução
@type function
@version 12
@author Gilson.Venturi
@since 25/02/2025
@return variant, nil
/*/
Function AGDI050()
	Local aAreaAtu		:= GetArea()
	Local aAreaSF1 		:= SF1->( GetArea() )
	Local aAreaSD1 		:= SD1->( GetArea() )
	Local nQtde			:= 0
	Local cCodNegocio	:= ""
	Local cVersaoNegocio := ""
	Local oNFService	:= nil
	Local oNegocioService := nil
	Local oNegocioStatusService	:= nil
	Local oIEItemRepository	:= nil

	if SUPERGETMV("MV_SIGAAGD", .f., .f.)

		dbSelectArea( "SD1" )
		dbSetOrder( 1 )
		If dbSeek( xFilial( "SD1" ) + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) )
			While .Not. SD1->( Eof() ) .and. !Empty(SD1->D1_NFORI) .and.;
					SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)

				cChaveNF := xFilial("SD1") + SD1->( D1_NFORI + D1_SERIORI + D1_FORNECE + D1_LOJA + D1_COD ) + Padr(D1_ITEMORI, TamSX3("D2_ITEM")[1])

				dbSelectArea('NED')
				NED->(dbSetOrder(2))
				NED->(DBGoTop())
				If NED->(dbSeek(cChaveNF))
					oIEItemRepository := IE_ITEM_REPOSITORY():new()
					//metodo sumByDevolucaoNFItemIE ja busca a soma do total da qtd na SD1 de todas as devoluções do item desta IE, fazendo alto ajuste caso tiver errado
					nQtde := oIEItemRepository:sumByDevolucaoNFItemIE(NED->NED_CODIEB, NED->NED_ITEM)
					cFilNegocio := NED->NED_FILIAL
					cCodNegocio := NED->NED_CODBRT

					oNFService := NOTA_FISCAL_SERVICE():new(cChaveNF)
					oNFService:atualizarQuantidadeDevolvida(nQtde)
					FreeObj(oNFService)
				EndIf

				SD1->(DBSkip(1))
			EndDo

			If !Empty(cCodNegocio)
				oNegocioService := NEGOCIO_SERVICE():New()
				cVersaoNegocio := oNegocioService:buscarVersaoAtualValida(cCodNegocio)
				oNegocioStatusService := NEGOCIO_STATUS_SERVICE():New(FWxFilial("NEA",cFilNegocio) + cCodNegocio + cVersaoNegocio)
				oNegocioStatusService:informarInstrucaoEmbarque()
				FreeObj(oNegocioService)
				FreeObj(oNegocioStatusService)
			endif
		endif
	endif

	RestArea( aAreaSD1 )
	RestArea( aAreaSF1 )
	RestArea( aAreaAtu )
Return nil
