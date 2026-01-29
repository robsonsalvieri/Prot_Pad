
#INCLUDE "TOTVS.ch"
#INCLUDE "AGDI021.ch"
#INCLUDE "FWMVCDEF.CH"
#DEFINE IE_PEDIDO_SERVICE agd.instrucaoEmbarquePedidoService.agdInstrucaoEmbarquePedidoService
#DEFINE SOLICITACAO_RECEITA_SERVICE agd.solicitacaoReceitaService.agdSolicitacaoReceitaService
#DEFINE SOLICITACAO_RECEITA_REPOSITORY agd.solicitacaoReceitaRepository.agdSolicitacaoReceitaRepository

/*/{Protheus.doc} AGDI021
Funcao executada pelo modulo de faturamento ao alterar um pedido de venda
@type function
@version 12
@author lindembergson.pacheco
@since 05/03/2025
@return variant, nil
/*/
Function AGDI021(oGetPV, oGetd)
	Local aAreaAtu 		:= GetArea()
	Local lRet  := .T.
	Local nPosCliente
	Local nPosLoja
	Local nX := 0
	Local lGeraNEQ := .F.
	Local cProduto := ""
	Local cLocDescarte := ""
	Local cCodUnicEng  := ""
	Local oIEPedidoService := nil
	Local oModel
	Local oNEQ
	Local nPosProduto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})

	if SUPERGETMV("MV_SIGAAGD", .f., .f.) .AND. TableInDic('NEC') .And. TableInDic('NEO') .And. TableInDic('NEQ')
		IF ALTERA
			oIEPedidoService := IE_PEDIDO_SERVICE():New()
			if (oIEPedidoService:isPedidoInstrucEmbarque(SC5->C5_NUM))

				IF oGetPV != NIL
					nPosCliente := Ascan(oGetPV:aEntryCtrls,{|x| UPPER(TRIM(x:cReadVar))=="M->C5_CLIENTE"})
					If nPosCliente > 0
						oGetPV:aEntryCtrls[nPosCliente]:lReadOnly := .T.
					EndIf

					nPosLoja := Ascan(oGetPV:aEntryCtrls,{|x| UPPER(TRIM(x:cReadVar))=="M->C5_LOJACLI"})
					If nPosLoja > 0
						oGetPV:aEntryCtrls[nPosLoja]:lReadOnly := .T.
					EndIf
				ENDIF

				IF !EMPTY(M->C5_CLIENT)
					IF (M->C5_CLIENT !=  SC5->C5_CLIENT)
						M->C5_CLIENT :=  SC5->C5_CLIENT
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_LOJAENT)
					IF (M->C5_LOJAENT !=  SC5->C5_LOJAENT)
						M->C5_LOJAENT :=  SC5->C5_LOJAENT
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_CONDPAG)
					IF (M->C5_CONDPAG !=  SC5->C5_CONDPAG)
						M->C5_CONDPAG :=  SC5->C5_CONDPAG
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_VEND1)
					IF (M->C5_VEND1 !=  SC5->C5_VEND1)
						M->C5_VEND1 :=  SC5->C5_VEND1
						M->C5_COMIS1 :=  SC5->C5_COMIS1
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_TABELA)
					IF (M->C5_TABELA !=  SC5->C5_TABELA)
						M->C5_TABELA :=  SC5->C5_TABELA
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_CODSAF)
					IF (M->C5_CODSAF !=  SC5->C5_CODSAF)
						M->C5_CODSAF :=  SC5->C5_CODSAF
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_TPFRETE)
					IF (M->C5_TPFRETE !=  SC5->C5_TPFRETE)
						M->C5_TPFRETE :=  SC5->C5_TPFRETE
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_FRETE)
					IF (M->C5_FRETE !=  SC5->C5_FRETE)
						M->C5_FRETE :=  SC5->C5_FRETE
						lRet := .F.
					ENDIF
				ENDIF


				IF oGetd != NIL
					oGetd:Disable()
				ENDIF

				IF !lRet
					AGDHELP(STR0001,  STR0002 ) //#"Atencao" # //"Este pedido possui instrução de embarque, por este motivo o tipo de modificação feita interfere com o que foi negociado. Por favor verifique."
				ENDIF
			endif
			IF oGetd == NIL
				atualizaStatus()
			endif
		ENDIF

		If INCLUI .OR. ALTERA

			IF oGetd == NIL
				// Busca Local de Descarte padrão
				cLocDescarte := GetLocDescart()

				If !Empty(cLocDescarte)
					oRepository :=  SOLICITACAO_RECEITA_REPOSITORY():New()
					For nX := 1 to Len(aCols)
						cProduto := aCols[nX,nPosProduto]
						If oRepository:IsGeraReceita(cProduto)
							DbSelectArea("NEQ")
							NEQ->(dbSetOrder(1)) //Filial + NUM
							If !NEQ->(dbSeek(xFilial("NEQ") + M->C5_NUM))
								lGeraNEQ := .T.
								Exit
							Endif
						ENDIF
					Next
				EndIf

				If lGeraNEQ
					// Busca código do único engenheiro cadastrado na filial
					cCodUnicEng := GetEngUnico()

					oModel := FwLoadModel("AGDX040")
					oModel:SetOperation(MODEL_OPERATION_INSERT)
					oNEQ := oModel:GetModel('AGDX040_NEQ')
					If oModel:Activate()
						oNEQ:SetValue("NEQ_FILIAL", xFilial("NEQ"))
						oNEQ:SetValue("NEQ_NUM"   , M->C5_NUM)
						oNEQ:SetValue("NEQ_FILDES", xFilial("NEQ"))
						oNEQ:SetValue("NEQ_CODDES", cLocDescarte)
						oNEQ:SetValue("NEQ_FILENG", xFilial("NEQ"))
						oNEQ:SetValue("NEQ_CODENG", cCodUnicEng)

						If oModel:VldData()
							oModel:CommitData()
						EndIf
					EndIf		
				EndIf		

			EndIf

		EndIF

		FreeObj(oIEPedidoService)

	endif

	restarea(aAreaAtu)

Return lRet

/*/{Protheus.doc} atualizaStatus
Atualiza Status das Solicitação
@type function
@version P12
@author scheronlini.martins
@since 05/12/2025
@param cPedido, character, codigo do pedido
/*/
function atualizaStatus()
	Local oServSolicRec := SOLICITACAO_RECEITA_SERVICE():new()
	Local oRepoSolicRec := SOLICITACAO_RECEITA_REPOSITORY():new()
	Local aSolicPedidos:={}
	Local n

	If .Not. TableInDic('NET')
		MsgNextRel()
		Return()
	Endif

	aSolicPedidos:= oRepoSolicRec:getSolicPedidos(SC5->C5_NUM)

	for n:= 1 to Len(aSolicPedidos)
		oServSolicRec:atualizaStatus(aSolicPedidos[n,1],aSolicPedidos[n,2],aSolicPedidos[n,3])
	next

return

/*/{Protheus.doc} GetLocDescart
Retorna o código do Local de Descarte padrão (NEO_CODIGO),
considerando filial corrente, registro padrão e não bloqueado.
@type function
@version P12 
@author rodrigo.nsoledade
@since 17/12/2025
@return character
/*/
Static Function GetLocDescart()
	Local cQueryNEO   as character
	Local oStatement  as object

	cQueryNEO := " SELECT NEO_CODIGO "
	cQueryNEO += " FROM " + RetSQLName("NEO") + " NEO "
	cQueryNEO += " WHERE " + RetSqlCond("NEO")
	cQueryNEO += "   AND NEO.NEO_PADRAO = '1' "
	cQueryNEO += "   AND NEO.NEO_BLOQUE = '2' "
	cQueryNEO := ChangeQuery(cQueryNEO)

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQueryNEO)
	cQueryNEO := oStatement:GetFixQuery()

Return MpSysExecScalar(cQueryNEO, "NEO_CODIGO")

/*/{Protheus.doc} GetEngUnico
Retorna o código do engenheiro apenas se existir
exatamente 1 engenheiro cadastrado na filial corrente.
@type function
@version P12 
@author rodrigo.nsoledade
@since 17/12/2025
@return character
/*/
Static Function GetEngUnico()
	Local cQueryNP8   as character
	Local oStatement  as object
	Local nQtdEng     as numeric

	// Quantidade de engenheiros na filial
	cQueryNP8 := " SELECT COUNT(*) AS QTDE "
	cQueryNP8 += " FROM " + RetSQLName("NP8") + " NP8 "
	cQueryNP8 += " WHERE " + RetSqlCond("NP8")
	cQueryNP8 := ChangeQuery(cQueryNP8)

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQueryNP8)
	cQueryNP8 := oStatement:GetFixQuery()

	nQtdEng := MpSysExecScalar(cQueryNP8, "QTDE")

	If nQtdEng <> 1
		Return ""
	EndIf

	// Retorna o código do único engenheiro
	cQueryNP8 := " SELECT NP8_CODIGO "
	cQueryNP8 += " FROM " + RetSQLName("NP8") + " NP8 "
	cQueryNP8 += " WHERE " + RetSqlCond("NP8")
	cQueryNP8 := ChangeQuery(cQueryNP8)

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQueryNP8)
	cQueryNP8 := oStatement:GetFixQuery()

Return MpSysExecScalar(cQueryNP8, "NP8_CODIGO")
