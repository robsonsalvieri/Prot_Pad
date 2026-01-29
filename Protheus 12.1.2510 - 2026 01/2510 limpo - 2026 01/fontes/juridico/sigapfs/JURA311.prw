#INCLUDE "JURA311.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA311
Movimentações em Adiantamentos

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Function JURA311()
Local oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) // Movimentações em Adiantamentos
	oBrowse:SetAlias("OI8")
	JurSetLeg(oBrowse, "OI8")
	JurSetBSize(oBrowse)
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Movimentações em Adiantamentos

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOI8 := FWFormStruct(1, "OI8")
Local oCommit    := JA311COMMIT():New()

	oModel:= MPFormModel():New("JURA311", /*Pre-Validacao*/, /*Pós-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("OI8MASTER", Nil, oStructOI8, /*Pre-Validacao*/, /*Pos-Validacao*/)

	oModel:SetDescription(STR0002) // "Modelo de Dados de Movimentações em Adiantamentos"

	oModel:InstallEvent("JA311COMMIT", /*cOwner*/, oCommit)

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA311COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Class JA311COMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor FWModelEvent

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Method New() Class JA311COMMIT
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit após as
gravações porém antes do final da transação. Esse evento ocorre uma
vez no contexto do modelo principal.

@param oSubModel, Modelo de dados de anexos
@param cModelId , Id do Modelo

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA311COMMIT
	JFILASINC(oSubModel:GetModel(), "OI8", "OI8MASTER", "OI8_COD") 	// Faz a gravação na fila de sincronização (NYS)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J311Insert
Função para inserir registros de Movimentações em Adiantamentos

@param  cType     , Tipo da movimentação (para RA's criados pela JURA069):
                     1=Recebido  - Geração do RA
                     2=Utilizado - Utilização do RA (Compensação)
                     3=Cancelado - Cancelamento da Compensação
                     4=Devolvido - Estorno do RA
                    
                    Caso sejam RA's criados pelo financeiro (não usaram a JURA069) os tipos serão
                     A - Inclusão de adiantamentos sem NWF direto no SIGAFIN (JIncTitCR) -> Equivale ao 1 - Recebido
                     B - Exclusão de adiantamentos sem NWF direto no SIGAFIN (JDelTitCR) -> Equivale ao 4 - Estornado
                     C - Baixa do RA sem NWF (JGrvBxRA). Obs: Baixa em RA é um estorno -> Equivale ao 4 - Estornado
                     D - Utilização do adiantamento (Compensação) sem NWF direto no SIGAFIN (JGrvBaixa) -> Equivale ao 2 - Utilizado
                     E - Cancelamento/Exclusão da compensação de adiantamentos sem NWF direto no SIGAFIN (JCancBaixa) -> Equivale ao 3 - Cancelado
                     F - Exclusão da Baixa (JCancBaixa). Obs: Baixa em RA é um estorno -> Equivale ao 1 - Recebido

@param  nReverseVal, Valor do Estorno
@param  nRecnoSE5  , Recno da moviventação no SE5

@return lInsert    , Se verdadeiro a gravação foi efetuada com sucesso

@author Jonatas Martins
@since  20/06/2023
@obs    Para chamar essa função é obrigatório posicionar no Título SE1
/*/
//-------------------------------------------------------------------
Function J311Insert(cType, nReverseVal, nRecnoSE5)
Local lInsert := .T.

Default cType       := ""
Default nReverseVal := 0
Default nRecnoSE5   := 0

	If !Empty(cType)
		FWMsgRun(Nil, {|| lInsert := J311Save(cType, nReverseVal, nRecnoSE5)}, STR0003, STR0004) // "Inserindo Movimentações em Adiantamentos" # "Gravando..."
	Else
		lInsert := JurMsgErro(STR0005, "JURA311", STR0006) // "Tipo movimentação do adiantamento inválido!" # "Informe o tipo da movimentação em adiantamento."
	EndIf

Return lInsert

//-------------------------------------------------------------------
/*/{Protheus.doc} J311Save
Função para inserir registros de Movimentações em Adiantamentos

@param  cType     , Tipo da movimentação:
                     1=Recebido;
                     2=Utilizado;
                     3=Cancelado;
                     4=Devolvido

@param  nReverseVal, Valor do Estorno
@param  nRecnoSE5  , Recno da moviventação no SE5

@return lSave      , Se verdadeiro a gravação foi efetuada com sucesso

@author Jonatas Martins
@since  20/06/2023
@obs    Quando a variável cType contiver letras, as operação ocorrem com RA's que não possuem NWF
/*/
//-------------------------------------------------------------------
Static Function J311Save(cType, nReverseVal, nRecnoSE5)
Local oModel    := FWLoadModel("JURA311")
Local aData     := J311GetValues(cType, nReverseVal, nRecnoSE5)
Local oModelOI8 := Nil
Local nReg      := 0
Local nVal      := 0
Local lSave     := .T.

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	
	For nReg := 1 To Len(aData)
		oModel:Activate()
		oModelOI8 := oModel:GetModel("OI8MASTER")

		For nVal := 1 To Len(aData[nReg])
			lSave := oModelOI8:SetValue(aData[nReg][nVal][1], aData[nReg][nVal][2])
			
			If !lSave
				Exit
			EndIf
		Next nVal
		
		lSave := lSave .And. oModel:VldData() .And. oModel:CommitData()

		If !lSave
			JurShowErro(oModel:GetErrorMessage())
			Exit
		EndIf

		oModel:DeActivate()
	Next nReg

	oModel:DeActivate()
	oModel:Destroy()
	JurFreeArr(@aData)

Return lSave

//-------------------------------------------------------------------
/*/{Protheus.doc} J311GetValues
Função montar o array com valores para gravação

@param  cType      ,Tipo da movimentação:
                     1=Recebido;
                     2=Utilizado;
                     3=Cancelado;
                     4=Devolvido

@param  nReverseVal, Tipo da movimentação
@param  nRecnoSE5  , Recno da moviventação no SE5

@return aValues , Array com valores das Movimentações em Adiantamentos
                  para gravar na OI8

@author Jonatas Martins
@since  20/06/2023
@obs    Quando a variável cType contiver letras, as operação ocorrem com RA's que não possuem NWF
/*/
//-------------------------------------------------------------------
Static Function J311GetValues(cType, nReverseVal, nRecnoSE5)
Local aArea      := {}
Local aAreaOI8   := {}
Local aVal       := {}
Local aValues    := {}
Local dDateOI8   := Nil
Local cMoeBco    := ""
Local cBkpFilAnt := ""
Local nValue     := 0
Local nValMN     := 0
Local nCotac     := 0
Local nFator     := 0
Local lChvSE5    := .T.
Local lEstPFSRUP := FwIsInCallStack("RUP_PFS") .And. AllTrim(SE5->E5_ORIGEM) == "JURA069" // Estorno feito via JURA069 (usado para execução do RUP)

	// A - Inclusão de adiantamentos sem NWF direto no SIGAFIN (JIncTitCR) -> 1 - Recebido
	// B - Exclusão de adiantamentos sem NWF direto no SIGAFIN (JDelTitCR) -> 4 - Estornado
	If cType $ "A|B"
		cType    := IIF(cType == "A", "1", "4")
		dDateOI8 := IIF(cType == "4", dDataBase, SE1->E1_EMISSAO)
		Aadd(aVal, {"OI8_FILIAL", xFilial("OI8") })
		Aadd(aVal, {"OI8_DATA  ", dDateOI8       })
		Aadd(aVal, {"OI8_CMOEDA", StrZero(SE1->E1_MOEDA, 2)})
		Aadd(aVal, {"OI8_TPMOV ", cType          }) // 4 - Devolvido
		Aadd(aVal, {"OI8_CESCR" , JurGetDados("NS7", 4, xFilial("NS7") + SE1->E1_FILIAL, "NS7_COD") })
		Aadd(aVal, {"OI8_VALOR ", SE1->E1_VALOR  })
		Aadd(aVal, {"OI8_COTAC ", SE1->E1_TXMOEDA})
		Aadd(aVal, {"OI8_VALMN ", SE1->E1_VLCRUZ })
		Aadd(aVal, {"OI8_CCLIEN", SE1->E1_CLIENTE})
		Aadd(aVal, {"OI8_CLOJA ", SE1->E1_LOJA   })
		Aadd(aVal, {"OI8_CHVSE1", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)})
		If cType == "1" // 1 - Recebido
			Aadd(aVal, {"OI8_CHVSE5", SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)})
		EndIf
		
		Aadd(aValues, AClone(aVal))
		JurFreeArr(aVal)

	ElseIf cType $ "C|F" // C - Baixa do RA sem NWF (JGrvBxRA) | F - Exclusão/Cancelamento da Baixa de estorno (JCancBaixa)
		
		If cType == "F" // Exclusão/Cancelamento da Baixa de estorno (JCancBaixa)
			aArea    := GetArea()
			aAreaOI8 := OI8->(GetArea())
			OI8->(DbSetOrder(3)) // OI8_FILIAL + OI8_CHVSE5
			If OI8->(DbSeek(xFilial("OI8") + SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)))
				// Limpa o código da SE5, pois quando uma baixa no RA é "excluída", a sequência pode ser reaproveitada pelo sistema...
				RecLock("OI8", .F.)
				OI8->OI8_CHVSE5 := " "
				OI8->(MsUnlock())
			EndIf
			lChvSE5 := .F. // ... E indica que não deve preencher o código da SE5 no registro que será criado (pelo mesmo motivo)
			RestArea(aAreaOI8)
			RestArea(aArea)
		EndIf
	
		nFator   := IIF(cType == "C", 1, -1)
		dDateOI8 := IIF(cType == "C", SE5->E5_DTDISPO, dDataBase)
		
		Aadd(aVal, {"OI8_FILIAL", xFilial("OI8")          })
		Aadd(aVal, {"OI8_DATA  ", dDateOI8                })
		Aadd(aVal, {"OI8_CMOEDA", SE5->E5_MOEDA           })
		Aadd(aVal, {"OI8_TPMOV ", "4"                     }) // C ou F = 4 - Devolvido
		Aadd(aVal, {"OI8_CESCR" , JurGetDados("NS7", 4, xFilial("NS7") + SE1->E1_FILIAL, "NS7_COD") })
		Aadd(aVal, {"OI8_VALOR ", SE5->E5_VALOR * nFator  })
		Aadd(aVal, {"OI8_COTAC ", SE5->E5_TXMOEDA         })
		Aadd(aVal, {"OI8_VALMN ", SE5->E5_VLMOED2 * nFator})
		Aadd(aVal, {"OI8_CCLIEN", SE5->E5_CLIFOR })
		Aadd(aVal, {"OI8_CLOJA ", SE5->E5_LOJA   })
		Aadd(aVal, {"OI8_CHVSE1", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)})
		If lChvSE5
			Aadd(aVal, {"OI8_CHVSE5", SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)})
		EndIf
		
		Aadd(aValues, AClone(aVal))
		JurFreeArr(aVal)

	ElseIf cType $ "D" // D - Utilização do adiantamento (Baixa) sem NWF direto no SIGAFIN (JGrvBaixa) -> 2 - Utilizado
		aValues := J311AvgFin("2", nRecnoSE5) // 2 - Utilizado
	
	ElseIf cType == "E" // E - Cancelamento/Exclusão da compensação de adiantamentos sem NWF direto no SIGAFIN (JCancBaixa) -> 3 - Cancelado
		aValues := J311AvgRev("3", nRecnoSE5) // 3 - Cancelado

	ElseIf cType $ "1|4|5" // 1-Recebimento (Gerar financeiro JURA069) de adiantamentos com NWF | 4-Estorno (Estono do RA) de adiantamentos com NWF | 5-Estorno (Cancelamento/exclusão do Estono do RA - Valor fica negativo) de adiantamentos com NWF
		If cType == "1" // 1-Recebimento
			dDateOI8 := NWF->NWF_DTMOVI
			nValue   := NWF->NWF_VALOR
			nValMN   := IIF(NWF->NWF_CMOE == "01", NWF->NWF_VALOR, SE1->E1_VLCRUZ)

		ElseIf cType == "4" // 4-Estorno (Estornar Financeiro JURA069) de adiantamentos com NWF
			If FwIsInCallStack("J069DlgEst") // Estono pela tela de adiantamentos
				dDateOI8 := dDataBase // Se for via "Estorno" do JURA069 usa o dDataBase
				nValue   := nReverseVal
				nValMN   := IIF(NWF->NWF_CMOE <> "01",;
				            JA201FConv(NWF->NWF_CMOE, "01", nReverseVal, "A", , , , , , , , , NWF->NWF_COTACA)[1],;
				            nReverseVal)
			
			ElseIf lEstPFSRUP // Criação da OI8 através do RUP para estorno feito pela tela de adiantamentos

				cBkpFilAnt := cFilAnt
				cFilAnt    := SE1->E1_FILIAL

				cMoeBco  := StrZero(JurGetDados("SA6", 1, xFilial("SA6") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA, "A6_MOEDA"), 2)
				dDateOI8 := IIf(Empty(SE5->E5_DTDISPO), SE5->E5_DATA, SE5->E5_DTDISPO)

				If NWF->NWF_CMOE == "01" .And. cMoeBco == "01" // Adiantamento e banco na moeda REAL
					nValue   := nReverseVal
					nValMN   := nReverseVal

				ElseIf NWF->NWF_CMOE == cMoeBco // Adiantamento e banco na mesma moeda ESTRANGEIRA
					nCotac   := NWF->NWF_COTACA
					nValue   := nReverseVal
					nValMN   := IIF(NWF->NWF_CMOE <> "01",;
					            JA201FConv(NWF->NWF_CMOE, "01", nReverseVal, "A", , , , , , , , , NWF->NWF_COTACA)[1],;
					            nReverseVal)
				
				ElseIf cMoeBco <> NWF->NWF_CMOE .And. (NWF->NWF_CMOE == "01" .Or. cMoeBco == "01") // Adiantamento e banco em moedas diferentes, sendo uma delas REAL
					If NWF->NWF_CMOE == "01" // Adiantamento em REAL / Banco em moeda estrangeira
						nValue   := xMoeda(nReverseVal, Val(cMoeBco), Val(NWF->NWF_CMOE), dDateOI8, 3, GetCotacD(cMoeBco, dDateOI8)) // Converte o valor de estorno da moeda nacional para moeda do banco
						nValMN   := nValue
					Else // Adiantamento em moeda estrangeira / Banco em REAL
						nCotac   := NWF->NWF_COTACA
						nValue   := JA201FConv(NWF->NWF_CMOE, "01", nReverseVal, "A", , , , , , , , , 1 / NWF->NWF_COTACA)[1]
						nValMN   := nReverseVal
					EndIf

				Else // Adiantamento e banco em moedas entrangeiras e diferentes entre si (ex: dolar e euro)
					nCotac   := NWF->NWF_COTACA
					nValMN   := JA201FConv(cMoeBco, "01", nReverseVal, "A", , , , , , , , , GetCotacD(cMoeBco, dDateOI8))[1]
					nValue   := JA201FConv("01", NWF->NWF_CMOE, nValMN, "A", , , , , , , , , 1 / NWF->NWF_COTACA)[1]
				EndIf

				cFilAnt := cBkpFilAnt

			Else // Estorno através da baixa do título do RA pelo financeiro
				dDateOI8 := SE5->E5_DATA // Se for via Baixa do título de RA no financeiro usa o E5_DATA
				If SE5->E5_MOEDA == SuperGetMV("MV_JMOENAC",, "01") // Banco da baixa na moeda real
					nValue   := SE5->E5_VLMOED2
					nValMN   := nReverseVal
					nCotac   := SE5->E5_TXMOEDA
				ElseIf SE5->E5_MOEDA == NWF->NWF_CMOE // Adiantamento em moeda estrangeira e banco na mesma moeda
					nValue   := nReverseVal
					nValMN   := JA201FConv(NWF->NWF_CMOE, "01", nReverseVal, "A", , , , , , , , , NWF->NWF_COTACA)[1]
				EndIf
			EndIf
			nRecnoSE5 := SE5->(Recno())
		
		ElseIf cType == "5" // 4-Estorno (Valor Negativo) - Indica Cancelamento/exclusão do Estorno via SIGAFIN
			cType    := "4"
			dDateOI8 := dDataBase

			aArea    := GetArea()
			aAreaOI8 := OI8->(GetArea())
			OI8->(DbSetOrder(3)) // OI8_FILIAL + OI8_CHVSE5
			If OI8->(DbSeek(xFilial("OI8") + SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)))
				nValue := -OI8->OI8_VALOR
				nValMN := -OI8->OI8_VALMN
				nCotac := OI8->OI8_COTAC

				// Limpa o código da SE5, pois quando uma baixa no RA é "excluída", a sequência pode ser reaproveitada pelo sistema...
				RecLock("OI8", .F.)
				OI8->OI8_CHVSE5 := " "
				OI8->(MsUnlock())
			EndIf
			lChvSE5 := .F. // ... E indica que não deve preencher o código da SE5 no registro que será criado (pelo mesmo motivo)

			RestArea(aAreaOI8)
			RestArea(aArea)
		EndIf

		nCotac := IIf(nCotac == 0, NWF->NWF_COTACA, nCotac)
		
		Aadd(aVal, {"OI8_FILIAL", xFilial("OI8") })
		Aadd(aVal, {"OI8_DATA  ", dDateOI8       })
		Aadd(aVal, {"OI8_CMOEDA", NWF->NWF_CMOE  })
		Aadd(aVal, {"OI8_TPMOV ", cType          })
		Aadd(aVal, {"OI8_VALOR ", nValue         })
		Aadd(aVal, {"OI8_COTAC ", nCotac         })
		Aadd(aVal, {"OI8_VALMN ", nValMN         })
		Aadd(aVal, {"OI8_CESCR" , NWF->NWF_CESCR })
		Aadd(aVal, {"OI8_CODADT", NWF->NWF_COD   })
		Aadd(aVal, {"OI8_CCLIEN", NWF->NWF_CCLIEN})
		Aadd(aVal, {"OI8_CLOJA ", NWF->NWF_CLOJA })
		Aadd(aVal, {"OI8_CCASO ", NWF->NWF_CCASO })
		Aadd(aVal, {"OI8_CHVSE1", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)})
		If lChvSE5
			Aadd(aVal, {"OI8_CHVSE5", SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)})
		EndIf

		Aadd(aValues, AClone(aVal))
		JurFreeArr(aVal)

	ElseIf cType == "2" // 2 - Utilizado
		aValues := J311AvgCas(cType, nRecnoSE5) // Distribui valores nos casos da fatura para inclusão da OI8 de adiantamentos com NWF

	ElseIf cType == "3" // 3 - Cancelado
		aValues := J311AvgRev(cType, nRecnoSE5) // Estorna registros da OI8 de adiantamentos com NWF

	EndIf

Return aValues

//-------------------------------------------------------------------
/*/{Protheus.doc} J311AvgCas
Função montar o array com valores distribuidos entre os casos da fatura
para inclusão da OI8.

@param  cType      ,Tipo da movimentação:
                     1=Recebido;
                     2=Utilizado;
                     3=Cancelado;
                     4=Devolvido

@param  nRecnoSE5  , Recno da moviventação no SE5

@return aAvgValues , Array com valores das Movimentações em Adiantamentos
                     para gravar na OI8

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Static Function J311AvgCas(cType, nRecnoSE5)
Local oAvgCas    := Nil
Local cQuery     := ""
Local cAlsAvg    := GetNextAlias()
Local aVal       := {}
Local aAvgValues := {}
Local dDateOI8   := Nil
Local nResiduo   := 0
Local nResiduoMN := 0
Local nPerc      := 0
Local nLast      := 0
Local nValOI8    := 0
Local nValOI8MN  := 0
Local nDecOI8    := TamSX3("E1_VALOR")[2]
Local lExclus    := .F.
Local cFilNXA    := xFilial("NXA")
Local cMoeNac    := SuperGetMV("MV_JMOENAC",, "01")
Local lDateAd    := SuperGetMv('MV_JDTCVAD',, "1") == "1" // 1 - Data de inclusão do Adiantamento / 2 - Data de emissão da Fatura
Local nParam     := 0
Local nSldLiq    := 0

	cQuery := "SELECT SE5.E5_DOCUMEN, SE5.E5_DTDISPO, SE5.E5_DATA, SE5.E5_MOEDA, SE5.E5_VALOR, SE5.E5_VLMOED2, SE5.E5_TXMOEDA,"
	cQuery +=       " NWF.NWF_COD, NWF.NWF_EXCLUS, NXC.NXC_CESCR, NXC.NXC_CFATUR, NXC.NXC_CCLIEN, NXC.NXC_CLOJA, NXC.NXC_CCASO,"
	cQuery +=       " NXC.NXC_VLHFAT + NXC.NXC_VLDFAT + NXC.NXC_VGROSH - NXC.NXC_DRATP + NXC.NXC_ARATF -"
	cQuery +=         " (SELECT COALESCE(SUM(CASE WHEN OI8.OI8_TPMOV IN ('2') THEN "
	cQuery +=                                      " CASE "
	cQuery +=                                         " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQuery +=                                         " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 1 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQuery +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQuery +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQuery +=                                      " END "
	cQuery +=                                   " WHEN OI8.OI8_TPMOV IN ('3') THEN "
	cQuery +=                                      " CASE "
	cQuery +=                                         " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQuery +=                                         " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 2 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQuery +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQuery +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQuery +=                                      " END * (-1) "
	cQuery +=                              " END), "
	cQuery +=                          " 0) "
	cQuery +=            " FROM " + RetSqlName("OI8") + " OI8"
	cQuery +=           " INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQuery +=              " ON NXA.NXA_FILIAL = ? " // 3 - xFilial("NXA")
	cQuery +=             " AND NXA.NXA_CESCR = OI8.OI8_CESCR "
	cQuery +=             " AND NXA.NXA_COD = OI8.OI8_CFATUR "
	cQuery +=             " AND NXA.D_E_L_E_T_ = ' ' "
	cQuery +=            " LEFT JOIN " + RetSqlName("NXF") + " NXF "
	cQuery +=              " ON NXF.NXF_FILIAL = NXA.NXA_FILIAL "
	cQuery +=             " AND NXF.NXF_CFATUR = NXA.NXA_COD "
	cQuery +=             " AND NXF.NXF_CESCR = NXA.NXA_CESCR "
	cQuery +=             " AND NXF.NXF_CMOEDA = NXA.NXA_CMOEDA "
	cQuery +=             " AND NXF.D_E_L_E_T_ = ' ' "
	If lDateAd
		cQuery +=        " LEFT JOIN " + RetSqlName("NWF") + " NWF "
		cQuery +=          " ON NWF.NWF_FILIAL = ? " // 4 - xFilial("NWF")
		cQuery +=         " AND NWF.NWF_COD = OI8.OI8_CODADT "
		cQuery +=         " AND NWF.D_E_L_E_T_ = ' ' "
		cQuery +=        " LEFT JOIN " + RetSqlName("CTP") + " CTP "
		cQuery +=          " ON CTP.CTP_FILIAL = ? " // 5 - xFilial("CTP")
		cQuery +=         " AND CTP.CTP_DATA = NWF_DTMOVI "
		cQuery +=         " AND CTP.CTP_MOEDA = NXA.NXA_CMOEDA "
	EndIf
	cQuery +=           " WHERE OI8.OI8_FILIAL = NXC.NXC_FILIAL"
	cQuery +=             " AND OI8.OI8_CESCR = NXC.NXC_CESCR"
	cQuery +=             " AND OI8.OI8_CFATUR = NXC.NXC_CFATUR"
	cQuery +=             " AND OI8.OI8_CCLIEN = NXC.NXC_CCLIEN"
	cQuery +=             " AND OI8.OI8_CLOJA = NXC.NXC_CLOJA"
	cQuery +=             " AND OI8.OI8_CCASO = NXC.NXC_CCASO"
	cQuery +=             " AND OI8.D_E_L_E_T_ = ' '"
	cQuery +=         " ) VALORCASO,"
	cQuery +=       " NXA.NXA_VLFATH + NXA.NXA_VLFATD + NXA.NXA_VGROSH - NXA.NXA_VLDESC + NXA.NXA_VLACRE -"
	cQuery +=         " (SELECT COALESCE(SUM(CASE WHEN OI8.OI8_TPMOV IN ('2') THEN "
	cQuery +=                                      " CASE "
	cQuery +=                                         " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQuery +=                                         " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 6 ou 4 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQuery +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQuery +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQuery +=                                      " END "
	cQuery +=                                   " WHEN OI8.OI8_TPMOV IN ('3') THEN "
	cQuery +=                                      " CASE "
	cQuery +=                                         " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQuery +=                                         " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 7 ou 5 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQuery +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQuery +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQuery +=                                      " END * (-1) "
	cQuery +=                              " END), "
	cQuery +=                          " 0) "
	cQuery +=            " FROM " + RetSqlName("OI8") + " OI8"
	cQuery +=           " INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQuery +=              " ON NXA.NXA_FILIAL = ? " // 8 ou 6 - xFilial("NXA")
	cQuery +=             " AND NXA.NXA_CESCR = OI8.OI8_CESCR "
	cQuery +=             " AND NXA.NXA_COD = OI8.OI8_CFATUR "
	cQuery +=             " AND NXA.D_E_L_E_T_ = ' ' "
	cQuery +=            " LEFT JOIN " + RetSqlName("NXF") + " NXF "
	cQuery +=              " ON NXF.NXF_FILIAL = NXA.NXA_FILIAL "
	cQuery +=             " AND NXF.NXF_CFATUR = NXA.NXA_COD "
	cQuery +=             " AND NXF.NXF_CESCR = NXA.NXA_CESCR "
	cQuery +=             " AND NXF.NXF_CMOEDA = NXA.NXA_CMOEDA "
	cQuery +=             " AND NXF.D_E_L_E_T_ = ' ' "
	If lDateAd
		cQuery +=        " LEFT JOIN " + RetSqlName("NWF") + " NWF "
		cQuery +=          " ON NWF.NWF_FILIAL = ? " // 9 - xFilial("NWF")
		cQuery +=         " AND NWF.NWF_COD = OI8.OI8_CODADT "
		cQuery +=         " AND NWF.D_E_L_E_T_ = ' ' "
		cQuery +=        " LEFT JOIN " + RetSqlName("CTP") + " CTP "
		cQuery +=          " ON CTP.CTP_FILIAL = ? " // 10 - xFilial("CTP")
		cQuery +=         " AND CTP.CTP_DATA = NWF_DTMOVI "
		cQuery +=         " AND CTP.CTP_MOEDA = NXA.NXA_CMOEDA "
	EndIf
	cQuery +=           " WHERE OI8.OI8_FILIAL = NXC.NXC_FILIAL"
	cQuery +=             " AND OI8.OI8_CESCR = NXC.NXC_CESCR"
	cQuery +=             " AND OI8.OI8_CFATUR = NXC.NXC_CFATUR"
	cQuery +=             " AND OI8.OI8_CCLIEN = NXC.NXC_CCLIEN"
	cQuery +=             " AND OI8.OI8_CLOJA = NXC.NXC_CLOJA"
	cQuery +=             " AND OI8.D_E_L_E_T_ = ' '"
	cQuery +=         " ) TOTFAT,"
	// Subquery para pegar o total do título
	// Será usado em casos de liquidação para proporcionalizar a fatura sobre o total do título
	cQuery +=         " (SELECT COALESCE(SUM(NXCTIT.NXC_VLHFAT + NXCTIT.NXC_VLDFAT + NXCTIT.NXC_VGROSH - NXCTIT.NXC_DRATP + NXCTIT.NXC_ARATF), 0) "
	cQuery +=            " FROM " + RetSqlName("OHT") + " OHTTIT "
	cQuery +=           " INNER JOIN " + RetSqlName("NXC") + " NXCTIT "
	cQuery +=              " ON NXCTIT.NXC_FILIAL = OHTTIT.OHT_FILFAT "
	cQuery +=             " AND NXCTIT.NXC_CESCR  = OHTTIT.OHT_FTESCR "
	cQuery +=             " AND NXCTIT.NXC_CFATUR = OHTTIT.OHT_CFATUR "
	cQuery +=             " AND NXCTIT.D_E_L_E_T_ = ' ' "
	cQuery +=           " WHERE OHTTIT.OHT_FILTIT = OHT.OHT_FILTIT "
	cQuery +=             " AND OHTTIT.OHT_PREFIX = OHT.OHT_PREFIX "
	cQuery +=             " AND OHTTIT.OHT_TITNUM = OHT.OHT_TITNUM "
	cQuery +=             " AND OHTTIT.OHT_TITPAR = OHT.OHT_TITPAR "
	cQuery +=             " AND OHTTIT.OHT_TITTPO = OHT.OHT_TITTPO "
	cQuery +=             " AND OHTTIT.OHT_FILLIQ = OHT.OHT_FILLIQ "
	cQuery +=             " AND OHTTIT.OHT_NUMLIQ = OHT.OHT_NUMLIQ "
	cQuery +=             " AND OHTTIT.OHT_NUMLIQ <> ' ' " // Somente se for liquidação
	cQuery +=             " AND OHTTIT.D_E_L_E_T_ = ' ' "
	cQuery +=         " ) TOTTITLIQ, "
	cQuery +=       " NWF.NWF_CCLIEN, NWF.NWF_CLOJA, NWF.NWF_CCASO,"
	cQuery +=       " LTRIM(SE5.E5_FILIAL || SE5.E5_PREFIXO || E5_NUMERO || SE5.E5_PARCELA || SE5.E5_TIPO || SE5.E5_CLIFOR || SE5.E5_LOJA || SE5.E5_SEQ) CHVSE5"
	cQuery +=  " FROM " + RetSqlName("NWF") + " NWF "
	cQuery += " INNER JOIN " + RetSqlName("NS7") + " NS7 "
	cQuery +=    " ON NS7.NS7_FILIAL = ? " // 11 ou 7 - xFilial("NS7")
	cQuery +=   " AND NS7.NS7_COD = NWF_CESCR "
	cQuery +=   " AND NS7.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
	cQuery +=    " ON SE1.E1_ORIGEM = 'JURA069' "
	cQuery +=   " AND SE1.E1_FILIAL  = NS7.NS7_CFILIA "
	cQuery +=   " AND SE1.E1_PREFIXO = ? " // 12 ou 8 - PARAMETRO MV_JADTPRF
	cQuery +=   " AND SE1.E1_NUM = NWF.NWF_TITULO "
	cQuery +=   " AND SE1.E1_PARCELA = ? " // 13 ou 9 - PARAMETRO MV_JADTPAR
	cQuery +=   " AND SE1.E1_TIPO = ? " // 14 ou 10 - PARAMETRO MV_JADTTP
	cQuery +=   " AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("SE5") + " SE5 "
	cQuery +=    " ON SE5.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND SE5.E5_FILIAL  = SE1.E1_FILIAL "
	cQuery +=   " AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "
	cQuery +=   " AND SE5.E5_NUMERO  = SE1.E1_NUM "
	cQuery +=   " AND SE5.E5_PARCELA = SE1.E1_PARCELA "
	cQuery +=   " AND SE5.E5_TIPO = SE1.E1_TIPO "
	cQuery +=   " AND SE5.E5_MOTBX = 'CMP' "
	cQuery +=   " AND SE5.E5_TIPODOC = 'BA' "
	cQuery +=   " AND SE5.R_E_C_N_O_ = ? " // 15 ou 11 - nRecnoSE5
	cQuery += " INNER JOIN " + RetSqlName("OHT") + " OHT "
	cQuery +=    " ON OHT.OHT_PREFIX || OHT.OHT_TITNUM || OHT.OHT_TITPAR || OHT.OHT_TITTPO || SE1.E1_LOJA = SE5.E5_DOCUMEN "
	cQuery +=   " AND OHT.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("NXC") + " NXC "
	cQuery +=    " ON NXC.NXC_FILIAL = ? " // 16 ou 12 - xFilial("NXC")
	cQuery +=   " AND NXC.NXC_CESCR  = OHT.OHT_FTESCR "
	cQuery +=   " AND NXC.NXC_CFATUR = OHT.OHT_CFATUR "
	If NWF->NWF_EXCLUS == "1" // Adiantamento Exclusivo
		cQuery +=   " AND NXC.NXC_CCLIEN = NWF.NWF_CCLIEN "
		cQuery +=   " AND NXC.NXC_CLOJA  = NWF.NWF_CLOJA "
	EndIf
	cQuery +=   " AND NXC.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQuery +=    " ON NXA.NXA_FILIAL = OHT.OHT_FILFAT "
	cQuery +=   " AND NXA.NXA_CESCR = OHT.OHT_FTESCR "
	cQuery +=   " AND NXA.NXA_COD = OHT.OHT_CFATUR "
	cQuery +=   " AND NXA.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NWF.NWF_FILIAL = ' ' "
	cQuery +=   " AND NWF.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY NWF_COD, NXC_CESCR, NXC_CFATUR, NXC_CCLIEN, NXC_CLOJA, NXC_CCASO "
	
	cQuery := ChangeQuery(cQuery)

	oAvgCas := FWPreparedStatement():New(cQuery)

	oAvgCas:SetString(++nParam, cMoeNac           ) // Moeda nacional - 1
	oAvgCas:SetString(++nParam, cMoeNac           ) // Moeda nacional - 2
	oAvgCas:SetString(++nParam, cFilNXA           ) // NXA_FILIAL     - 3
	If lDateAd
		oAvgCas:SetString(++nParam, xFilial("NWF")) // NWF_FILIAL     - 4
		oAvgCas:SetString(++nParam, xFilial("CTP")) // CTP_FILIAL     - 5
	EndIf
	oAvgCas:SetString(++nParam, cMoeNac           ) // Moeda nacional - 6 ou 4
	oAvgCas:SetString(++nParam, cMoeNac           ) // Moeda nacional - 7 ou 5
	oAvgCas:SetString(++nParam, cFilNXA           ) // NXA_FILIAL     - 8 ou 6
	If lDateAd
		oAvgCas:SetString(++nParam, xFilial("NWF")) // NWF_FILIAL     - 9
		oAvgCas:SetString(++nParam, xFilial("CTP")) // CTP_FILIAL     - 10
	EndIf
	oAvgCas:SetString(++nParam, xFilial("NS7")    ) // NS7_FILIAL     - 11 ou 7
	oAvgCas:SetString(++nParam, SE1->E1_PREFIXO   ) // E1_PREFIXO     - 12 ou 8
	oAvgCas:SetString(++nParam, SE1->E1_PARCELA   ) // E1_PARCELA     - 13 ou 9
	oAvgCas:SetString(++nParam, SE1->E1_TIPO      ) // E1_TIPO        - 14 ou 10
	oAvgCas:SetNumeric(++nParam, nRecnoSE5        ) // SE5.R_E_C_N_O_ - 15 ou 11
	oAvgCas:SetString(++nParam, xFilial("NXC")    ) // NXC_FILIAL     - 16 ou 12

	cQuery := oAvgCas:GetFixQuery()

	MpSysOpenQuery(cQuery, cAlsAvg)

	nResiduo   := (cAlsAvg)->E5_VALOR
	// Caso o adiantamento for em moeda nacional e o fatura que está sendo compesada for moeda estrangeira, será considerado o E5_VALOR para gravação do campo OI8_VALMN
	nResiduoMN := IIF((cAlsAvg)->E5_MOEDA == "01", (cAlsAvg)->E5_VALOR, (cAlsAvg)->E5_VLMOED2)

	While (cAlsAvg)->(!Eof())

		// Valida se o caso tem saldo para movimentar
		If (cAlsAvg)->VALORCASO > 0 .Or. (cAlsAvg)->TOTTITLIQ > 0
			lExclus := (cAlsAvg)->NWF_EXCLUS == "1"

			If lExclus .And. ((cAlsAvg)->NXC_CCLIEN <> (cAlsAvg)->NWF_CCLIEN .Or. (cAlsAvg)->NXC_CLOJA <> (cAlsAvg)->NWF_CLOJA;
			                  .Or. (cAlsAvg)->NXC_CCASO <> (cAlsAvg)->NWF_CCASO)
				(cAlsAvg)->(DbSkip())
				Loop
			EndIf

			nPerc       := IIF(lExclus, 1, ((cAlsAvg)->VALORCASO / (cAlsAvg)->TOTFAT))

			If (cAlsAvg)->TOTTITLIQ > 0 // Proporção da fatura x título (usado em casos de liquidação)
				nSldLiq := (cAlsAvg)->TOTTITLIQ - J311AvgLiq(nRecnoSE5) // Saldo do título = Valor do título - Valor utilizado
				nPerc := nPerc * ((cAlsAvg)->TOTFAT / nSldLiq)
			EndIf
			nValOI8     := Round((cAlsAvg)->E5_VALOR * nPerc, nDecOI8)
			nValOI8MN   := IIF((cAlsAvg)->E5_MOEDA == "01", nValOI8, Round((cAlsAvg)->E5_VLMOED2 * nPerc, nDecOI8))
			dDateOI8    := IIF(Empty((cAlsAvg)->E5_DTDISPO), Date(), StoD((cAlsAvg)->E5_DTDISPO))

			Aadd(aVal, {"OI8_FILIAL", xFilial("OI8")       })
			Aadd(aVal, {"OI8_DATA  ", dDateOI8             })
			Aadd(aVal, {"OI8_CMOEDA", (cAlsAvg)->E5_MOEDA  })
			Aadd(aVal, {"OI8_TPMOV ", cType                })
			Aadd(aVal, {"OI8_VALOR ", nValOI8              })
			Aadd(aVal, {"OI8_COTAC ", (cAlsAvg)->E5_TXMOEDA})
			Aadd(aVal, {"OI8_VALMN ", nValOI8MN            })
			Aadd(aVal, {"OI8_CODADT", (cAlsAvg)->NWF_COD   })
			Aadd(aVal, {"OI8_CESCR ", (cAlsAvg)->NXC_CESCR })
			Aadd(aVal, {"OI8_CFATUR", (cAlsAvg)->NXC_CFATUR})
			Aadd(aVal, {"OI8_CCLIEN", (cAlsAvg)->NXC_CCLIEN})
			Aadd(aVal, {"OI8_CLOJA ", (cAlsAvg)->NXC_CLOJA })
			Aadd(aVal, {"OI8_CCASO ", (cAlsAvg)->NXC_CCASO })
			Aadd(aVal, {"OI8_CHVSE1", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)})
			Aadd(aVal, {"OI8_CHVSE5", (cAlsAvg)->CHVSE5    })

			nResiduo   -= nValOI8
			nResiduoMN -= nValOI8MN

			Aadd(aAvgValues, AClone(aVal))
			JurFreeArr(aVal)

		EndIf
		(cAlsAvg)->(DbSkip())
	EndDo

	If !Empty(aAvgValues)
		nLast := Len(aAvgValues)
		aAvgValues[nLast][5][2] += nResiduo
		aAvgValues[nLast][7][2] += nResiduoMN
	EndIf

	oAvgCas:Destroy()
	(cAlsAvg)->(DbCloseArea())

Return aAvgValues

//-------------------------------------------------------------------
/*/{Protheus.doc} J311AvgRev
Função para incluir registros de cancelamento na OI8 quando houver o
estorno/exclusão da compensação do adiantamento.

@param  cType      ,Tipo da movimentação:
                     1=Recebido;
                     2=Utilizado;
                     3=Cancelado;
                     4=Devolvido

@param  nRecnoSE5  , Recno da moviventação no SE5

@return aAvgRev , Array com valores das Movimentações em Adiantamentos
                  para gravar o estorno na OI8

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Static Function J311AvgRev(cType, nRecnoSE5)
Local aArea      := GetArea()
Local aAreaOI8   := OI8->(GetArea())
Local aAreaSE5   := SE5->(GetArea())
Local aAvgRev    := {}
Local aVal       := {}
Local lPosOI8    := .F.

	SE5->(DbGoTo(nRecnoSE5)) // Força o posicionamento na SE5 pois quando o estorno é feito posicionado no RA a SE5 vem posicionado no registro do título compensado e não da fatura.
	OI8->(DbSetOrder(3)) // OI8_FILIAL + OI8_CHVSE5
	lPosOI8 := OI8->(DbSeek(xFilial("OI8") + SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)))

	If lPosOI8
		While AllTrim(OI8->OI8_CHVSE5) == Alltrim(SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
			Aadd(aVal, {"OI8_FILIAL", OI8->OI8_FILIAL})
			Aadd(aVal, {"OI8_DATA  ", Date()         })
			Aadd(aVal, {"OI8_CMOEDA", OI8->OI8_CMOEDA})
			Aadd(aVal, {"OI8_TPMOV ", cType          })
			Aadd(aVal, {"OI8_VALOR ", OI8->OI8_VALOR })
			Aadd(aVal, {"OI8_COTAC ", OI8->OI8_COTAC })
			Aadd(aVal, {"OI8_VALMN ", OI8->OI8_VALMN })
			Aadd(aVal, {"OI8_CODADT", OI8->OI8_CODADT})
			Aadd(aVal, {"OI8_CESCR ", OI8->OI8_CESCR })
			Aadd(aVal, {"OI8_CFATUR", OI8->OI8_CFATUR})
			Aadd(aVal, {"OI8_CCLIEN", OI8->OI8_CCLIEN})
			Aadd(aVal, {"OI8_CLOJA ", OI8->OI8_CLOJA })
			Aadd(aVal, {"OI8_CCASO ", OI8->OI8_CCASO })
			Aadd(aVal, {"OI8_CHVSE1", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)})
			Aadd(aVal, {"OI8_CHVSE5", SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)})

			Aadd(aAvgRev, AClone(aVal))
			JurFreeArr(aVal)
			OI8->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSE5)
	RestArea(aAreaOI8)
	RestArea(aArea)

Return aAvgRev

//-------------------------------------------------------------------
/*/{Protheus.doc} J311AvgFin
Função montar o array com valores distribuidos entre os casos da fatura
para inclusão da OI8 na compensação via SIGAFIN de RA sem adiantamentos (NWF)

@param  cType    ,Tipo da movimentação:
                   1=Recebido;
                   2=Utilizado;
                   3=Cancelado;
                   4=Devolvido

@param  nRecnoSE5, Recno da moviventação no SE5

@return aAvgFin  , Array com valores das Movimentações em Adiantamentos
                     para gravar na OI8

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Static Function J311AvgFin(cType, nRecnoSE5)
Local cQryFin    := ""
Local cAlsFin    := GetNextAlias()
Local oAvgFin    := Nil
Local aVal       := {}
Local aAvgFin    := {}
Local nPerc      := 0
Local nValOI8    := 0
Local nValOI8MN  := 0
Local nResiduo   := 0
Local nResiduoMN := 0
Local nLast      := 0
Local dDateOI8   := Nil
Local nDecOI8    := TamSX3("E1_VALOR")[2]
Local cFilNXA    := xFilial("NXA")
Local cMoeNac    := SuperGetMV("MV_JMOENAC",, "01")
Local lDateAd    := SuperGetMv('MV_JDTCVAD',, "1") == "1" // 1 - Data de inclusão do Adiantamento / 2 - Data de emissão da Fatura
Local nParam     := 0
Local nSldLiq    := 0
Local cEscrit    := ""

	cQryFin += "SELECT SE5.E5_DTDISPO, SE5.E5_MOEDA, SE5.E5_VALOR, SE5.E5_TXMOEDA, SE5.E5_VLMOED2,"
	cQryFin +=       " COALESCE(NXC.NXC_CESCR, ' ') NXC_CESCR, "
	cQryFin +=       " COALESCE(NXC.NXC_CFATUR, ' ') NXC_CFATUR, "
	cQryFin +=       " COALESCE(NXC.NXC_CCLIEN, SE5.E5_CLIFOR) NXC_CCLIEN, "
	cQryFin +=       " COALESCE(NXC.NXC_CLOJA, SE5.E5_LOJA) NXC_CLOJA, "
	cQryFin +=       " COALESCE(NXC.NXC_CCASO, ' ') NXC_CCASO, "
	cQryFin +=       " COALESCE(NXC.NXC_VLHFAT + NXC.NXC_VLDFAT + NXC.NXC_VGROSH - NXC.NXC_DRATP + NXC.NXC_ARATF - "
	cQryFin +=         " (SELECT COALESCE(SUM(CASE WHEN OI8.OI8_TPMOV IN ('2') THEN "
	cQryFin +=                                      " CASE "
	cQryFin +=                                         " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQryFin +=                                         " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 1 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQryFin +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQryFin +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQryFin +=                                      " END "
	cQryFin +=                                   " WHEN OI8.OI8_TPMOV IN ('3') THEN "
	cQryFin +=                                      " CASE "
	cQryFin +=                                         " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQryFin +=                                         " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 2 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQryFin +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQryFin +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQryFin +=                                      " END * (-1) "
	cQryFin +=                              " END), "
	cQryFin +=                          " 0) "
	cQryFin +=            " FROM " + RetSqlName("OI8") + " OI8"
	cQryFin +=           " INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQryFin +=              " ON NXA.NXA_FILIAL = ? " // 3 - xFilial("NXA")
	cQryFin +=             " AND NXA.NXA_CESCR = OI8.OI8_CESCR "
	cQryFin +=             " AND NXA.NXA_COD = OI8.OI8_CFATUR "
	cQryFin +=             " AND NXA.D_E_L_E_T_ = ' ' "
	cQryFin +=            " LEFT JOIN " + RetSqlName("NXF") + " NXF "
	cQryFin +=              " ON NXF.NXF_FILIAL = NXA.NXA_FILIAL "
	cQryFin +=             " AND NXF.NXF_CFATUR = NXA.NXA_COD "
	cQryFin +=             " AND NXF.NXF_CESCR = NXA.NXA_CESCR "
	cQryFin +=             " AND NXF.NXF_CMOEDA = NXA.NXA_CMOEDA "
	cQryFin +=             " AND NXF.D_E_L_E_T_ = ' ' "
	If lDateAd
		cQryFin +=        " LEFT JOIN " + RetSqlName("NWF") + " NWF "
		cQryFin +=          " ON NWF.NWF_FILIAL = ? " // 4 - xFilial("NWF")
		cQryFin +=         " AND NWF.NWF_COD = OI8.OI8_CODADT "
		cQryFin +=         " AND NWF.D_E_L_E_T_ = ' ' "
		cQryFin +=        " LEFT JOIN " + RetSqlName("CTP") + " CTP "
		cQryFin +=          " ON CTP.CTP_FILIAL = ? " // 5 - xFilial("CTP")
		cQryFin +=         " AND CTP.CTP_DATA = NWF_DTMOVI "
		cQryFin +=         " AND CTP.CTP_MOEDA = NXA.NXA_CMOEDA "
	EndIf
	cQryFin +=           " WHERE OI8.OI8_FILIAL = NXC.NXC_FILIAL"
	cQryFin +=             " AND OI8.OI8_CESCR = NXC.NXC_CESCR"
	cQryFin +=             " AND OI8.OI8_CFATUR = NXC.NXC_CFATUR"
	cQryFin +=             " AND OI8.OI8_CCLIEN = NXC.NXC_CCLIEN"
	cQryFin +=             " AND OI8.OI8_CLOJA = NXC.NXC_CLOJA"
	cQryFin +=             " AND OI8.OI8_CCASO = NXC.NXC_CCASO"
	cQryFin +=             " AND OI8.D_E_L_E_T_ = ' '"
	cQryFin +=         " ), 0) VALORCASO,"
	cQryFin +=       " COALESCE(NXA.NXA_VLFATH + NXA.NXA_VLFATD + NXA.NXA_VGROSH - NXA.NXA_VLDESC + NXA.NXA_VLACRE - "
	cQryFin +=         " (SELECT COALESCE(SUM(CASE WHEN OI8.OI8_TPMOV IN ('2') THEN "
	cQryFin +=                                      " CASE "
	cQryFin +=                                         " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQryFin +=                                         " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 6 ou 4 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQryFin +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQryFin +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQryFin +=                                      " END "
	cQryFin +=                                   " WHEN OI8.OI8_TPMOV IN ('3') THEN "
	cQryFin +=                                      " CASE "
	cQryFin +=                                         " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQryFin +=                                         " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 7 ou 5 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQryFin +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQryFin +=                                     " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQryFin +=                                      " END * (-1) "
	cQryFin +=                              " END), "
	cQryFin +=                          " 0) "
	cQryFin +=            " FROM " + RetSqlName("OI8") + " OI8"
	cQryFin +=           " INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQryFin +=              " ON NXA.NXA_FILIAL = ? " // 8 ou 6 - xFilial("NXA")
	cQryFin +=             " AND NXA.NXA_CESCR = OI8.OI8_CESCR "
	cQryFin +=             " AND NXA.NXA_COD = OI8.OI8_CFATUR "
	cQryFin +=             " AND NXA.D_E_L_E_T_ = ' ' "
	cQryFin +=            " LEFT JOIN " + RetSqlName("NXF") + " NXF "
	cQryFin +=              " ON NXF.NXF_FILIAL = NXA.NXA_FILIAL "
	cQryFin +=             " AND NXF.NXF_CFATUR = NXA.NXA_COD "
	cQryFin +=             " AND NXF.NXF_CESCR = NXA.NXA_CESCR "
	cQryFin +=             " AND NXF.NXF_CMOEDA = NXA.NXA_CMOEDA "
	cQryFin +=             " AND NXF.D_E_L_E_T_ = ' ' "
	If lDateAd
		cQryFin +=        " LEFT JOIN " + RetSqlName("NWF") + " NWF "
		cQryFin +=          " ON NWF.NWF_FILIAL = ? " // 9 - xFilial("NWF")
		cQryFin +=         " AND NWF.NWF_COD = OI8.OI8_CODADT "
		cQryFin +=         " AND NWF.D_E_L_E_T_ = ' ' "
		cQryFin +=        " LEFT JOIN " + RetSqlName("CTP") + " CTP "
		cQryFin +=          " ON CTP.CTP_FILIAL = ? " // 10 - xFilial("CTP")
		cQryFin +=         " AND CTP.CTP_DATA = NWF_DTMOVI "
		cQryFin +=         " AND CTP.CTP_MOEDA = NXA.NXA_CMOEDA "
	EndIf
	cQryFin +=           " WHERE OI8.OI8_FILIAL = NXC.NXC_FILIAL"
	cQryFin +=             " AND OI8.OI8_CESCR = NXC.NXC_CESCR"
	cQryFin +=             " AND OI8.OI8_CFATUR = NXC.NXC_CFATUR"
	cQryFin +=             " AND OI8.OI8_CCLIEN = NXC.NXC_CCLIEN"
	cQryFin +=             " AND OI8.OI8_CLOJA = NXC.NXC_CLOJA"
	cQryFin +=             " AND OI8.D_E_L_E_T_ = ' '"
	cQryFin +=         " ), 0) TOTFAT,"
	// Subquery para pegar o total do título
	// Será usado em casos de liquidação para proporcionalizar a fatura sobre o total do título
	cQryFin +=         " (SELECT COALESCE(SUM(NXCTIT.NXC_VLHFAT + NXCTIT.NXC_VLDFAT + NXCTIT.NXC_VGROSH - NXCTIT.NXC_DRATP + NXCTIT.NXC_ARATF), 0) "
	cQryFin +=            " FROM " + RetSqlName("OHT") + " OHTTIT "
	cQryFin +=           " INNER JOIN " + RetSqlName("NXC") + " NXCTIT "
	cQryFin +=              " ON NXCTIT.NXC_FILIAL = OHTTIT.OHT_FILFAT "
	cQryFin +=             " AND NXCTIT.NXC_CESCR  = OHTTIT.OHT_FTESCR "
	cQryFin +=             " AND NXCTIT.NXC_CFATUR = OHTTIT.OHT_CFATUR "
	cQryFin +=             " AND NXCTIT.D_E_L_E_T_ = ' ' "
	cQryFin +=           " WHERE OHTTIT.OHT_FILTIT = OHT.OHT_FILTIT "
	cQryFin +=             " AND OHTTIT.OHT_PREFIX = OHT.OHT_PREFIX "
	cQryFin +=             " AND OHTTIT.OHT_TITNUM = OHT.OHT_TITNUM "
	cQryFin +=             " AND OHTTIT.OHT_TITPAR = OHT.OHT_TITPAR "
	cQryFin +=             " AND OHTTIT.OHT_TITTPO = OHT.OHT_TITTPO "
	cQryFin +=             " AND OHTTIT.OHT_FILLIQ = OHT.OHT_FILLIQ "
	cQryFin +=             " AND OHTTIT.OHT_NUMLIQ = OHT.OHT_NUMLIQ "
	cQryFin +=             " AND OHTTIT.OHT_NUMLIQ <> ' ' " // Somente se for liquidação
	cQryFin +=             " AND OHTTIT.D_E_L_E_T_ = ' ' "
	cQryFin +=         " ) TOTTITLIQ, "
	cQryFin +=       " LTRIM(SE5.E5_FILIAL || SE5.E5_PREFIXO || E5_NUMERO || SE5.E5_PARCELA || SE5.E5_TIPO || SE5.E5_CLIFOR || SE5.E5_LOJA || SE5.E5_SEQ) CHVSE5 "
	cQryFin +=   "FROM " + RetSqlName("SE5") + " SE5 "
	cQryFin +=   "LEFT JOIN " + RetSqlName("OHT") + " OHT "
	cQryFin +=     "ON OHT.OHT_FILIAL = ? " // 11 ou 7 - xFilial("OHT")
	cQryFin +=    "AND OHT.OHT_PREFIX || OHT.OHT_TITNUM || OHT.OHT_TITPAR || OHT.OHT_TITTPO || SE5.E5_LOJA = SE5.E5_DOCUMEN "
	cQryFin +=    "AND OHT.D_E_L_E_T_ = ' ' "
	cQryFin +=   "LEFT JOIN " + RetSqlName("NXC") + " NXC "
	cQryFin +=     "ON NXC.NXC_FILIAL = ? " // 12 ou 8 - xFilial("NXC")
	cQryFin +=    "AND NXC.NXC_CESCR  = OHT.OHT_FTESCR "
	cQryFin +=    "AND NXC.NXC_CFATUR = OHT.OHT_CFATUR "
	cQryFin +=    "AND NXC.D_E_L_E_T_ = ' ' "
	cQryFin +=   "LEFT JOIN " + RetSqlName("NXA") + " NXA "
	cQryFin +=     "ON NXA.NXA_FILIAL = OHT.OHT_FILFAT "
	cQryFin +=    "AND NXA.NXA_CESCR = OHT.OHT_FTESCR "
	cQryFin +=    "AND NXA.NXA_COD = OHT.OHT_CFATUR "
	cQryFin +=    "AND NXA.D_E_L_E_T_ = ' ' "
	cQryFin +=  "WHERE SE5.E5_FILIAL = ? " // 13 ou 9 - xFilial("SE5")
	cQryFin +=    "AND SE5.R_E_C_N_O_ = ? " // 14 ou 10 - nRecnoSE5
	cQryFin +=    "AND SE5.D_E_L_E_T_ = ' ' "
	
	cQryFin := ChangeQuery(cQryFin)
	oAvgFin := FWPreparedStatement():New(cQryFin)

	oAvgFin:SetString(++nParam, cMoeNac           ) // Moeda nacional - 1
	oAvgFin:SetString(++nParam, cMoeNac           ) // Moeda nacional - 2
	oAvgFin:SetString(++nParam, cFilNXA           ) // NXA_FILIAL     - 3
	If lDateAd
		oAvgFin:SetString(++nParam, xFilial("NWF")) // NWF_FILIAL     - 4
		oAvgFin:SetString(++nParam, xFilial("CTP")) // CTP_FILIAL     - 5
	EndIf
	oAvgFin:SetString(++nParam, cMoeNac           ) // Moeda nacional - 6 ou 4
	oAvgFin:SetString(++nParam, cMoeNac           ) // Moeda nacional - 7 ou 5
	oAvgFin:SetString(++nParam, cFilNXA           ) // NXA_FILIAL     - 8 ou 6
	If lDateAd
		oAvgFin:SetString(++nParam, xFilial("NWF")) // NWF_FILIAL     - 9
		oAvgFin:SetString(++nParam, xFilial("CTP")) // CTP_FILIAL     - 10
	EndIf
	oAvgFin:SetString(++nParam, xFilial("OHT")    ) // OHT_FILIAL     - 11 ou 7
	oAvgFin:SetString(++nParam, xFilial("NXC")    ) // NXC_FILIAL     - 12 ou 8
	oAvgFin:SetString(++nParam, xFilial("SE5")    ) // E5_FILIAL      - 13 ou 9
	oAvgFin:SetNumeric(++nParam, nRecnoSE5        ) // SE5.R_E_C_N_O_ - 14 ou 10

	cQryFin := oAvgFin:GetFixQuery()

	MpSysOpenQuery(cQryFin, cAlsFin)

	nResiduo   := (cAlsFin)->E5_VALOR
	nResiduoMN := IIf((cAlsFin)->E5_MOEDA == "01", (cAlsFin)->E5_VALOR, (cAlsFin)->E5_VLMOED2)

	While (cAlsFin)->(!Eof())

		// Valida se o caso tem saldo para movimentar
		If Empty((cAlsFin)->NXC_CFATUR) .Or. ((cAlsFin)->VALORCASO > 0 .Or. (cAlsFin)->TOTTITLIQ > 0)

			nPerc     := (cAlsFin)->VALORCASO / (cAlsFin)->TOTFAT // Proporção do caso x fatura

			If (cAlsFin)->TOTTITLIQ > 0 // Proporção da fatura x título (usado em casos de liquidação)
				nSldLiq := (cAlsFin)->TOTTITLIQ - J311AvgLiq(nRecnoSE5) // Saldo do título = Valor do título - Valor utilizado
				nPerc := nPerc * ((cAlsFin)->TOTFAT / nSldLiq)
			EndIf

			nValOI8   := Round((cAlsFin)->E5_VALOR * nPerc, nDecOI8)
			nValOI8MN := IIf((cAlsFin)->E5_MOEDA == "01", nValOI8, Round((cAlsFin)->E5_VLMOED2 * nPerc, nDecOI8))
			dDateOI8  := IIf(Empty((cAlsFin)->E5_DTDISPO), Date(), StoD((cAlsFin)->E5_DTDISPO))
			cEscrit   := IIf(Empty((cAlsFin)->NXC_CESCR), JurGetDados("NS7", 4, xFilial("NS7") + SE1->E1_FILIAL, "NS7_COD"), (cAlsFin)->NXC_CESCR)

			Aadd(aVal, {"OI8_FILIAL", xFilial("OI8")       })
			Aadd(aVal, {"OI8_DATA  ", dDateOI8             })
			Aadd(aVal, {"OI8_CMOEDA", (cAlsFin)->E5_MOEDA  })
			Aadd(aVal, {"OI8_TPMOV ", cType                })
			Aadd(aVal, {"OI8_VALOR ", nValOI8              })
			Aadd(aVal, {"OI8_COTAC ", (cAlsFin)->E5_TXMOEDA})
			Aadd(aVal, {"OI8_VALMN ", nValOI8MN            })
			Aadd(aVal, {"OI8_CESCR ", cEscrit              })
			Aadd(aVal, {"OI8_CFATUR", (cAlsFin)->NXC_CFATUR})
			Aadd(aVal, {"OI8_CCLIEN", (cAlsFin)->NXC_CCLIEN})
			Aadd(aVal, {"OI8_CLOJA ", (cAlsFin)->NXC_CLOJA })
			Aadd(aVal, {"OI8_CCASO ", (cAlsFin)->NXC_CCASO })
			Aadd(aVal, {"OI8_CHVSE1", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)})
			Aadd(aVal, {"OI8_CHVSE5", (cAlsFin)->CHVSE5    })

			nResiduo   -= nValOI8
			nResiduoMN -= nValOI8MN

			Aadd(aAvgFin, AClone(aVal))
			JurFreeArr(aVal)
		EndIf

		(cAlsFin)->(DbSkip())
	EndDo

	If !Empty(aAvgFin)
		nLast := Len(aAvgFin)
		aAvgFin[nLast][5][2] += nResiduo
		aAvgFin[nLast][7][2] += nResiduoMN
	EndIf

	oAvgFin:Destroy()
	(cAlsFin)->(DbCloseArea())

Return aAvgFin

//-------------------------------------------------------------------
/*/{Protheus.doc} J311AvgLiq
Função para retornar os valores distribuidos entre as faturas do título
para inclusão da OI8 na compensação com liquidação

@param  nRecnoSE5, Recno da moviventação no SE5

@return nValUtiTit, Valor utilizado do título de liquidação

@author Jonatas Martins
@since  20/06/2023
/*/
//-------------------------------------------------------------------
Static Function J311AvgLiq(nRecnoSE5)
Local cQryTit    := ""
Local cAlsTit    := GetNextAlias()
Local oAvgTit    := Nil
Local lDateAd    := SuperGetMv('MV_JDTCVAD',, "1") == "1" // 1 - Data de inclusão do Adiantamento / 2 - Data de emissão da Fatura
Local cMoeNac    := SuperGetMV("MV_JMOENAC",, "01")
Local nParam     := 0

	cQryTit +=         " SELECT COALESCE(SUM(CASE WHEN OI8.OI8_TPMOV IN ('2') THEN "
	cQryTit +=                                     " CASE "
	cQryTit +=                                        " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQryTit +=                                        " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 1 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQryTit +=                                    " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQryTit +=                                    " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQryTit +=                                     " END "
	cQryTit +=                                  " WHEN OI8.OI8_TPMOV IN ('3') THEN "
	cQryTit +=                                     " CASE "
	cQryTit +=                                        " WHEN OI8.OI8_CMOEDA = NXA.NXA_CMOEDA THEN OI8.OI8_VALOR " // Fatura e RA (Baixa) na mesma moeda
	cQryTit +=                                        " WHEN OI8.OI8_CMOEDA <> ? THEN OI8.OI8_VALMN " // 2 - cMoeNac // RA (Baixa) em moeda estrangeira
	If lDateAd
		cQryTit +=                                    " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / (CASE WHEN OI8_CODADT = ' ' THEN NXF.NXF_COTAC1 ELSE CTP.CTP_TAXA END) " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	Else
		cQryTit +=                                    " WHEN OI8.OI8_CMOEDA < NXA.NXA_CMOEDA THEN OI8.OI8_VALOR / NXF.NXF_COTAC1 " // RA (Baixa) em moeda nacional e Fatura em moeda estrangeira
	EndIf
	cQryTit +=                                     " END * (-1) "
	cQryTit +=                             " END), "
	cQryTit +=                         " 0) VALUTITIT "
	cQryTit +=           " FROM " + RetSqlName("OI8") + " OI8"
	cQryTit +=          " INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQryTit +=             " ON NXA.NXA_FILIAL = ? " // 3 - xFilial("NXA")
	cQryTit +=            " AND NXA.NXA_CESCR = OI8.OI8_CESCR "
	cQryTit +=            " AND NXA.NXA_COD = OI8.OI8_CFATUR "
	cQryTit +=            " AND NXA.D_E_L_E_T_ = ' ' "
	cQryTit +=           " LEFT JOIN " + RetSqlName("NXF") + " NXF "
	cQryTit +=             " ON NXF.NXF_FILIAL = NXA.NXA_FILIAL "
	cQryTit +=            " AND NXF.NXF_CFATUR = NXA.NXA_COD "
	cQryTit +=            " AND NXF.NXF_CESCR = NXA.NXA_CESCR "
	cQryTit +=            " AND NXF.NXF_CMOEDA = NXA.NXA_CMOEDA "
	cQryTit +=            " AND NXF.D_E_L_E_T_ = ' ' "
	If lDateAd
		cQryTit +=       " LEFT JOIN " + RetSqlName("NWF") + " NWF "
		cQryTit +=         " ON NWF.NWF_FILIAL = ? " // 4 - xFilial("NWF")
		cQryTit +=        " AND NWF.NWF_COD = OI8.OI8_CODADT "
		cQryTit +=        " AND NWF.D_E_L_E_T_ = ' ' "
		cQryTit +=       " LEFT JOIN " + RetSqlName("CTP") + " CTP "
		cQryTit +=         " ON CTP.CTP_FILIAL = ? " // 5 - xFilial("CTP")
		cQryTit +=        " AND CTP.CTP_DATA = NWF.NWF_DTMOVI "
		cQryTit +=        " AND CTP.CTP_MOEDA = NXA.NXA_CMOEDA "
	EndIf
	cQryTit +=          " INNER JOIN " + RetSqlName("SE5") + " SE5 "
	cQryTit +=             " ON SE5.E5_FILIAL = ? " // 6 ou 4 - xFilial("SE5")
	cQryTit +=            " AND SE5.R_E_C_N_O_ = ? " // 7 ou 5 - nRecnoSE5
	cQryTit +=            " AND SE5.D_E_L_E_T_ = ' ' "
	cQryTit +=          " INNER JOIN " + RetSqlName("OHT") + " OHT "
	cQryTit +=             " ON OHT.OHT_FILIAL = ? " // 8 ou 6 - xFilial("OHT")
	cQryTit +=            " AND OHT.OHT_PREFIX || OHT.OHT_TITNUM || OHT.OHT_TITPAR || OHT.OHT_TITTPO || SE5.E5_LOJA = SE5.E5_DOCUMEN "
	cQryTit +=            " AND OHT.D_E_L_E_T_ = ' ' "
	cQryTit +=          " WHERE OI8.OI8_FILIAL = OHT.OHT_FILIAL "
	cQryTit +=            " AND OI8.OI8_CESCR = OHT.OHT_FTESCR "
	cQryTit +=            " AND OI8.OI8_CFATUR = OHT.OHT_CFATUR "
	cQryTit +=            " AND OI8.D_E_L_E_T_ = ' ' "

	cQryTit := ChangeQuery(cQryTit)
	oAvgTit := FWPreparedStatement():New(cQryTit)

	oAvgTit:SetString(++nParam, cMoeNac           ) // Moeda nacional - 1
	oAvgTit:SetString(++nParam, cMoeNac           ) // Moeda nacional - 2
	oAvgTit:SetString(++nParam, xFilial("NXA")    ) // NXA_FILIAL     - 3
	If lDateAd
		oAvgTit:SetString(++nParam, xFilial("NWF")) // NWF_FILIAL     - 4
		oAvgTit:SetString(++nParam, xFilial("CTP")) // CTP_FILIAL     - 5
	EndIf
	oAvgTit:SetString(++nParam, xFilial("SE5")    ) // E5_FILIAL      - 6 ou 4
	oAvgTit:SetNumeric(++nParam, nRecnoSE5        ) // SE5.R_E_C_N_O_ - 7 ou 5
	oAvgTit:SetString(++nParam, xFilial("OHT")    ) // OHT_FILIAL     - 8 ou 6

	cQryTit := oAvgTit:GetFixQuery()

	MpSysOpenQuery(cQryTit, cAlsTit)

	If (cAlsTit)->(!Eof())
		nValUtiTit := (cAlsTit)->VALUTITIT
	EndIf

	oAvgTit:Destroy()
	(cAlsTit)->(DbCloseArea())

Return nValUtiTit