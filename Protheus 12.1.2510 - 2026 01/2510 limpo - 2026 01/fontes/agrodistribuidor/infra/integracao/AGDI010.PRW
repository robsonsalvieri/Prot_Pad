#INCLUDE "TOTVS.ch"
#DEFINE NOTA_FISCAL_SERVICE agd.notaFiscalSaidaService.agdNotaFiscalSaidaService
#DEFINE RECEITUARIO_SERVICE agd.receituarioService.agdReceituarioService

/*/{Protheus.doc} AGDI010
Funcao executada pelo módulo de faturamento ao expedir um documento de saida
@type function
@version 12
@author Scheronlini Martins
@since 22/01/2025
@return variant, nil
/*/
Function AGDI010()
	Local oServReceituario := RECEITUARIO_SERVICE():new()

	if SUPERGETMV("MV_SIGAAGD", .f., .f.)
		AGDI013()
		if FWAliasInDic("NET")
			oServReceituario:insertReceita(SF2->(Recno()))
		EndIf
		AGDI014()
	endif

Return nil

/*/{Protheus.doc} AGDI011
Adiciona regras nas legendas do browse de Documentos de Saída.
Função utilizada no Mata460a() do fonte MATA461.PRX
@type function
@version 12
@author jc.maldonado
@since 29/09/2025
@param aCores, array, {{"regra", "Cor"}, ...}
@return array, legendas
/*/
Function AGDI011(aCores)
	Local nPos := 0

	If SUPERGETMV("MV_SIGAAGD", .f., .f.) .And. SC9->(FieldPos("C9_BLAGRO")) > 0
		nPos := aScan(aCores, {|xIt| allTrim(xIt[2]) == "ENABLE"})
		If nPos > 0
			aCores[nPos, 1] += ' .And. Empty(SC9->C9_BLAGRO)' //Incrementa a regra de Pedido de Venda liberado
		EndIf

		nPos := aScan(aCores, {|xIt| allTrim(xIt[2]) == "BR_AZUL"})
		If nPos > 0
			aCores[nPos, 1] += ' .Or. !Empty(SC9->C9_BLAGRO)' //Incrementa a regra de Pedido de Venda com bloqueio
		EndIf
	EndIF
Return aCores

/*/{Protheus.doc} AGDI012
Avalia se permite marcar o item na lista de documentos de saida.
Função utilizada no A460Avalia() do fonte MATA460.PRX
@type function
@version 12
@author jc.maldonado
@since 29/09/2025
@return logical, resultado da avaliacao
/*/
Function AGDI012()
	Local lRet := .F.

	If SUPERGETMV("MV_SIGAAGD", .f., .f.) .And. SC9->(FieldPos("C9_BLAGRO")) > 0
		lRet := !Empty(SC9->C9_BLAGRO)
	EndIf
Return lRet


/*/{Protheus.doc} AGDI013
Funcao executada pelo módulo de faturamento ao expedir um documento de saida
@type function
@version 12
@author jean.schulze
@since 22/01/2025
@return variant, nil
/*/
Function AGDI013()
	Local aAreaAtu 		:= GetArea()

	if SUPERGETMV("MV_SIGAAGD", .f., .f.)

		dbselectArea( "SD2" ) // Item da NF de SaÃ­da
		dbSetOrder( 3 )
		If dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) )

			While .Not. SD2->( Eof() ) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

				cChaveNF := xFilial("SD2") + SD2->( D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM )
				oService := NOTA_FISCAL_SERVICE():new(cChaveNF)
				oService:vincularNotaFiscal()
				FreeObj(oService)

				SD2->(DBSkip(1))
			end

		endif

	endif

	restarea(aAreaAtu)
Return nil

/*/{Protheus.doc} AGDI014
Realizar vínculo da Nota Fiscal ao Receituário
@type function
@version 12
@author Gilson.Venturi
@since 29/12/2025
@return logical, resultado da avaliacao
/*/
Function AGDI014()
	Local oServReceituario := RECEITUARIO_SERVICE():new()
	Local aPedidos 	as Array
	Local nField    as Integer

	if FWAliasInDic("NE6")
		aPedidos := oServReceituario:GetPedidosNF( SF2->(Recno()) )

		For nField := 1 to len(aPedidos)
			oServReceituario:vincularNotaReceita( aPedidos[nField], SF2->F2_DOC, SF2->F2_SERIE )
		Next

	endif
	FWFreeObj(oServReceituario)
Return nil
