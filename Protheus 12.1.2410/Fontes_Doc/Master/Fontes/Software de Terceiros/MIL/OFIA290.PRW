#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} OFIA290
Funcoes DMS - Chamadas pelo MATA103 ( NF ENTRADA POR COMPRA ) e MATA140 ( PRE NF ENTRADA POR COMPRA )

@author Andre Luis Almeida
@since 01/06/2020
@version 1.0
@return NIL
/*/
Function OFIA290()
Return NIL

/*/{Protheus.doc} OA2900011_A103NFiscal_PodeClassificar
	Chamada do MATA103 funcao A103NFiscal ( Verifica se pode Classificar a NF )

	@author Andre Luis Almeida
	@since 02/06/2020
/*/
Function OA2900011_A103NFiscal_PodeClassificar( aParametros )
Local lRetorno := .f.
// Verifica se pode classificar a NF - Conferencia de Itens da NF de Entrada
If ExistBlock("OA290CLA")
	lRetorno := ExecBlock("OA290CLA",.f.,.f.,{	aParametros[1] ,; // Variavel cTipo do MATA103 ( N=Normal / D=Devolucao )
												aParametros[2] ,; // Variavel cNFiscal do MATA103 ( Nro.NF )
												aParametros[3] }) // Variavel INCLUI do MATA103
Else
	lRetorno := OM3900161_PermiteClassificarNFEntrada(	aParametros[1] ,; // Variavel cTipo do MATA103 ( N=Normal / D=Devolucao )
														aParametros[2] ,; // Variavel cNFiscal do MATA103 ( Nro.NF )
														aParametros[3]  ) // Variavel INCLUI do MATA103
EndIf
Return lRetorno

/*/{Protheus.doc} OA2900021_A103NFiscal_AposOK
	Chamada do MATA103 funcao A103NFiscal ( Rotina de Inclusao/Alteracao/Exclusao de NF de Compra )

	@author Andre Luis Almeida
	@since 02/06/2020
/*/
Function OA2900021_A103NFiscal_AposOK( aParametros )
Local lRetorno := .f.
Local cAlias   := "SQLVS1"
Local cQuery   := ""
Local cNumOrc  := ""
Local aSeqDev  := {}
Local oVmi
Local cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial trabalha
//
 If aParametros[2] == 1 // Confirmou a Tela
	// Apos Ok da Tela - Verifica Conferencia de Entrada - Se houver Divergencia, faz movimentacao do Item
	 If ExistBlock("OA290DOK")
		lRetorno := ExecBlock("OA290DOK",.f.,.f.,{	aParametros[1] ,; // nOpc ( 3-Inclusao / 4-Alteracao / 5-Exclusao )
													aParametros[2] ,; // Opcao OK ( Confirmou a Tela )
													aParametros[3] ,; // Numero da NF
													aParametros[4] ,; // Serie da NF
													aParametros[5] ,; // Fornecedor
													aParametros[6] }) // Loja
	Else
	 	lRetorno := OM3900151_AposOkMATA103(aParametros[1] ,; // nOpc ( 3-Inclusao / 4-Alteracao / 5-Exclusao )
											aParametros[2] ,; // Opcao OK ( Confirmou a Tela )
											aParametros[3] ,; // Numero da NF
											aParametros[4] ,; // Serie da NF
											aParametros[5] ,; // Fornecedor
											aParametros[6]  ) // Loja
	EndIf
	If lRetorno
		oVmi := IIf( ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" , OFAGVmi():New() , NIL )
		If ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
			oVmi:Trigger({;
					{'EVENTO', oVmi:oVmiMovimentos:Pedido },;
					{'ORIGEM', "MATA103_DMS3"             },;
					{'DELETE', ( aParametros[1] == 5 )    },;
					{'ALTERA', ( aParametros[1] == 4 )    },;
					{'INCLUI', ( aParametros[1] == 3 )    },;
					{'CODIGO', ( aParametros[3] + aParametros[4] + aParametros[5] + aParametros[6] ) } ; // DOC + SERIE + FORNECEDOR + LOJA
			})
			// Verificar se é DEVOLUCAO do Cliente para disparar o DMS-4 relacionado ao Orcamento Origem
			cQuery := "SELECT VS1.VS1_NUMORC , SD1.D1_ITEMORI , SD1.D1_QUANT "
			cQuery += "  FROM "+RetSqlName('SF1')+" SF1 "
			cQuery += "  JOIN "+RetSqlName('SD1')+" SD1 ON SD1.D1_FILIAL = SF1.F1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SD1.D1_LOJA = SF1.F1_LOJA AND SD1.D_E_L_E_T_ = ' '"
			cQuery += "  JOIN "+RetSqlName('VS1')+" VS1 ON VS1.VS1_FILIAL = SD1.D1_FILORI AND VS1.VS1_NUMNFI = SD1.D1_NFORI AND VS1.VS1_SERNFI = SD1.D1_SERIORI AND VS1.D_E_L_E_T_ = ' '"
			cQuery += " WHERE SF1.F1_FILIAL = '"+xFilial("SF1")+"'"
			cQuery += "   AND SF1.F1_DOC = '"+aParametros[3]+"'"
			cQuery += "   AND SF1.F1_SERIE = '"+aParametros[4]+"'"
			cQuery += "   AND SF1.F1_FORNECE = '"+aParametros[5]+"'" 
			cQuery += "   AND SF1.F1_LOJA = '"+aParametros[6]+"'"
			cQuery += "   AND SF1.F1_TIPO = 'D'"
			cQuery += "   AND SF1.D_E_L_E_T_ = ' '"
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAlias, .F., .T. )
			While !(cAlias)->(EOF())
				cNumOrc := (cAlias)->( VS1_NUMORC )
				aAdd(aSeqDev, { val((cAlias)->( D1_ITEMORI )) , (cAlias)->(D1_QUANT ) } )
				(cAlias)->(DbSkip())
			EndDo
			(cAlias)->(dbCloseArea())
			DbSelectArea("SF1")
			If !Empty(cNumOrc)
				oVmi:Trigger({;
					{'EVENTO'          , oVmi:oVmiMovimentos:Orcamento},;
					{'ORIGEM'          , "MATA103_DMS4"  },;
					{'NUMERO_ORCAMENTO', cNumOrc         },;
					{'SEQ_DEVOLUCAO'   , aSeqDev         } ;
				})
			EndIf
		EndIf
	EndIf
EndIf
//
Return lRetorno

/*/{Protheus.doc} OA2900035_MaCanDelF1_Valid
	Chamada do MATA103X funcao MaCanDelF1

	@author Renato Vinicius
	@since 02/12/2021
/*/
Function OA2900035_MaCanDelF1_Valid( aParametros )

	Local lRetorno := .f.

	lRetorno := FM_CHKDNFE( aParametros[1], aParametros[2], aParametros[3], aParametros[4] ) // F1_DOC/F1_SERIE/F1_FORNECE/F1_LOJA

Return lRetorno

/*/{Protheus.doc} OA2900045_a103Grava_AposGravacao do SF1 e SD1
	Chamada do MATA103 funcao a103Grava

	@author Renato Vinicius
	@since 02/12/2021
/*/
Function OA2900045_a103Grava_AposGravacao( aParametros )

	Local aArea    := GetArea()
	Local cCombust := GetNewPar("MV_COMBUS","")
	Local lVerComb := SF1->F1_FORMUL == "S" .and. Alltrim(SF1->F1_ESPECIE) == "SPED"

	Local lNewRes  := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
	Local cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial trabalha

	// Chamado 004638 - 
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1") + aParametros[1] + aParametros[2] + aParametros[3] + aParametros[4] )

	While !SD1->(Eof()) .and. (SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA  == xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )

		if cMVMIL0006 == "JD" .AND. FindFunction("JD3100024_TouchItemDelta")
			JD3100024_TouchItemDelta(SD1->D1_COD, "", SD1->D1_FILIAL)
		endif

		If cPaisLoc == "BRA" .or. (cPaisLoc $ "ARG|MEX" .AND. Empty(SD1->D1_REMITO))
			If lNewRes
				OA4840095_BaixaMovimentoCompra( SD1->D1_PEDIDO, SD1->D1_ITEMPC, SD1->D1_COD, SD1->D1_TES, SD1->D1_QUANT, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_FILIAL, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_LOCAL)
			Else
				FM_BXSUGCOM( SD1->D1_PEDIDO, SD1->D1_ITEMPC, SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_DTDIGIT, SD1->D1_TES, SD1->D1_QUANT, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_LOTECTL )
			EndIf
		EndIf

		If FindFunction("OM0300055_BaixaServicoTerceiro")
			OM0300055_BaixaServicoTerceiro(SD1->D1_FILIAL, SD1->D1_PEDIDO, SD1->D1_ITEMPC, SD1->D1_DOC, SD1->D1_SERIE)
		EndIf

		If cPaisLoc == "BRA" .and. lVerComb .and. SB1->(FieldPos("B1_CODSIMP")) > 0

			CD6->(dbSetOrder(1))
			C0G->(DbSetOrder(7))

			If Alltrim(SD1->D1_GRUPO) $ cCombust

				DbSelectArea("SB1")
				DbSeek(xFilial("SB1")+SD1->D1_COD)

				If !CD6->(dbSeek(xFilial("CD6")+"E"+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD))

					C0G->(DbSeek(xFilial("C0G")+SB1->B1_CODSIMP))

					DbSelectArea("CD6")
					RecLock("CD6",.T.)
						CD6_FILIAL := xFilial("CD6")
						CD6_TPMOV  := "E"
						CD6_DOC    := SD1->D1_DOC
						CD6_SERIE  := SD1->D1_SERIE
						CD6_CLIFOR := SD1->D1_FORNECE
						CD6_LOJA   := SD1->D1_LOJA
						CD6_ITEM   := SD1->D1_ITEM
						CD6_COD    := SD1->D1_COD
						CD6_UFCONS := SF1->F1_EST
						CD6_CODANP := SB1->B1_CODSIMP
						CD6_DESANP := C0G->C0G_DESCRI
					MsUnlock()
				EndIf
			Endif
		EndIf

		DbSelectArea("SD1")
		SD1->(DbSkip())

	Enddo

	RestArea(aArea)

Return
/*/{Protheus.doc} OA2900031_A140NFiscal_AposOK
	Chamada do MATA140 funcao A140NFiscal ( Rotina de Inclusao/Alteracao/Exclusao de Pré-NF de Compra )

	@author Andre Luis Almeida
	@since 17/11/2021
/*/
Function OA2900031_A140NFiscal_AposOK( aParametros )
Local lRetorno := .t.
//
If aParametros[2] == 1 // Confirmou a Tela
	// Apos Ok da Tela - Pre-NF Entrada
	lRetorno := OM3900341_AposOkMATA140(aParametros[1] ,; // nOpc ( 3-Inclusao / 4-Alteracao / 5-Exclusao )
										aParametros[2] ,; // Opcao OK ( Confirmou a Tela )
										aParametros[3] ,; // Numero da NF
										aParametros[4] ,; // Serie da NF
										aParametros[5] ,; // Fornecedor
										aParametros[6] ,; // Loja
										aParametros[7]  ) // Tipo
EndIf
//
Return lRetorno

/*/{Protheus.doc} OA2900051_a103Grava_SQL_SE1
	Retorna Filtro da QUERY do SE1 - todos os tipos de titulos de BAL/OFI/VEI com exceção dos de Abatimento

	@author Andre Luis Almeida
	@since 06/07/2023
/*/
Function OA2900051_a103Grava_SQL_SE1()
Local cPrefBAL := Alltrim(GetNewPar("MV_PREFBAL","BAL"))
Local cPrefOFI := Alltrim(GetNewPar("MV_PREFOFI","OFI"))
Local cPrefVEI := Alltrim(GetNewPar("MV_PREFVEI","VEI"))
Local cRetorno := ""
cRetorno += " AND SE1.E1_TIPO NOT IN "+FormatIn(MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT,"|") // Desconsiderar os titulos de Abatimento
cRetorno += " AND SE1.E1_PREFORI IN ('"+cPrefBAL+"','"+cPrefOFI+"','"+cPrefVEI+"')" // Somente Prefixo de Origem BAL/OFI/VEI
Return cRetorno

/*/{Protheus.doc} OA2900061_a103Grava_ver_geracao_SE1
	Valida se o titulo pode ser utilizado

	@author Andre Luis Almeida
	@since 07/07/2023
/*/
Function OA2900061_a103Grava_ver_geracao_SE1( nRecSE1 )
Local lRetorno := .f.
If nRecSE1 > 0
	DbSelectArea("SE1")
	DbGoto( nRecSE1 )
	lRetorno := !( SE1->E1_TIPO $ MVABATIM+"|"+MVIRABT+"|"+MVINABT+"|"+MVCFABT+"|"+MVCSABT+"|"+MVPIABT ) // Desconsiderar os titulos de Abatimento
EndIf
Return lRetorno

/*/{Protheus.doc} OA2900078_a103Grava_MI_AposGravacao do SF1 e SD1
	Chamada do MATA101N/MATA102N funcao PrepGravaNf

	@author André Cruz
	@since 26/03/2025
/*/

function OA2900078_a103Grava_MI_AposGravacao()
	if cPaisLoc $ "ARG|MEX" .and. cFunName $ "MATA101N/MATA102N/MATA462TN"
		OA2900045_a103Grava_AposGravacao( { SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA } )
	endif
return nil