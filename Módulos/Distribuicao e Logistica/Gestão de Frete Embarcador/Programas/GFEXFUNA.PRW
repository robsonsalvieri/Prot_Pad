#INCLUDE "GFEXFUNA.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FWMVCDEF.CH"

// SONARQUBE - CA1003: Uso não permitido de chamada de API em LOOP
Static s_GFEZTT := SuperGetMv("MV_GFEZTT",.F.,"0")
Static s_GFEPF1 := SuperGetMv("MV_GFEPF1",,'1')
Static s_VLCNPJ := SuperGetMV('MV_VLCNPJ',,'1')
Static s_GFEI15 := SuperGetMV('MV_GFEI15',,'3')

Static aAlGFE := {}
Static oTabTemp

// Códigos de mensagens padronizadas
#DEFINE GFEX001 'GFEX001'
#DEFINE GFEX002 'GFEX002'
#DEFINE GFEX003 'GFEX003'

//--------------------------------------------------------------------
/*/{Protheus.doc} GFEChkCond
Verifica para uma chave estrangeira se o registro atende a uma condição.
Deve ser usado após ExistCpo.

Uso no dicionário (SX3) no campo X3_VALID

@param  cAlias  	Nome da tabela do registro da chave estrangeira
@param  nIndice   	Índice a ser usado na busca do registro. (Não obrigatório)
@param  cValores    Valores dos campos. (Não obrigatório)
@param  cCondicao   Condição para o registro ser válido

@sample
GFEChkCond("ZA0", 1, FwFldGet("ZA2_AUTOR"), "ZA0->ZA0_TIPO=='C'")


@author Israel A Possoli
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEChkCnd(cAlias, nIndice, cValores, cCondicao)
	Local lResult := .F.
	Local aArea := GetArea()
	Local aAreaAlias := (cAlias)->(GetArea())
	Local cCampo := ReadVar()
	Local cCampoLiteral := StrTran(cCampo, "M->")
	Local cMotivo := ""


	Default nIndice := 1
	Default cValores := &(cCampo)

	dbSelectArea(cAlias)
	dbSetOrder(nIndice)

	If dbSeek(xFilial(cAlias) + cValores)
		lResult := &(cCondicao)
	EndIf

	If !lResult
		dbSelectArea("SX3")
		dbSetOrder(2)
		If dbSeek(cCampoLiteral)
			cCampoLiteral := AllTrim(X3DescriC()) + " (" + cCampoLiteral + ")"
		EndIf

		If cCampo == "M->GWU_CDTRP"
			cMotivo := "Emitente não é um transportador."
		EndIf

		Help( ,, 'HELP',, STR0051 + "." + ;
			CRLF + CRLF +   ;
			If(!Empty(cMotivo), "Motivo: " + cMotivo + CRLF + CRLF, "") + ;
				"Campo: " + cCampoLiteral, 1, 0) //"Não foi encontrado o registro ou não atendeu a nenhuma condição"
		EndIf

		RestArea(aAreaAlias)
		RestArea(aArea)

		Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEExistC
- Verifica se o código da chave estrangeira existe (executa ExistCpo)
- Verifica para uma chave estrangeira se o registro atende a uma condição.
Deve ser usado após ExistCpo.

Uso no dicionário (SX3) no campo X3_VALID

@param  cAlias  	Nome da tabela do registro da chave estrangeira
@param  nIndice   	Índice a ser usado na busca do registro. (Não obrigatório)
@param  cValores    Valores dos campos. (Não obrigatório)
@param  cCondicao   Condição para o registro ser válido
@sample
GFEExistC("ZA0", 1, FwFldGet("ZA2_AUTOR"), "ZA0->ZA0_TIPO=='C'")
GFEExistC("ZA0", "ZA0->ZA0_TIPO=='C'") // Assume Índice 1 e valor do campo que está sendo atualizado no momento


@author Israel A Possoli
@since 22/10/09
@version 1.0
/*/

//-------------------------------------------------------------------
Function GFEExistC(cAlias, nIndice, cValores, cCondicao)
	Local lRet 		  := .T.
	Default nIndice   := 1
	Default cCondicao := ""

	If !ExistCpo(cAlias, cValores, nIndice)
		lRet := .F.
	EndIf

	If lRet .And. !Empty(cCondicao)
		lRet := GFEChkCnd(cAlias, nIndice, cValores, cCondicao)
	EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEFnIcms
- Retorna a alíquota do ICMS e outras informações relacionadas

@param	cCdTrp		Código do Transportador
@param	cCdRem		Código do Remetente
@param	cCdDest		Código do Destinatário
@param	cOrigem		Código da cidade de origem
@param	cOrigem		Código da cidade de destino
@param	cUsoCarga	Tipo do uso da carga (Uso e Consumo, Insdustrialização, etc)
@param	cTpItens	Tipo do Iten
@param	cTpClass	Classificação de Frete
@param	cTribIcms	Mercadoria é tributada por ICMS?
@param	cRomTpOp	Tipo de operação do romaneio
@param	cFilCre		Filial do cálculo usada para verificação das exceções de filiais que não possuem crédito onde o tipo de tributação é atribuído como Outros (Parâmetro MV_GFECRIC) [Opcional]

aRetorno - array contendo as seguintes informações
[1] - aliquota de ICMS
[2] - tipo de tributação
[3] - percentual de redução da base de cálculo
[4] - percentual de crédito em caso de tributação presumida

@author Israel A Possoli
@since 22/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEFnIcms(cCdTrp, cCdRem, cCdDest, cOrigem, cDestin, cUsoCarga, cTpItens, cTpClass, cTribIcms, cRomTpOp, cFilCre)
	Local nAliqIcms
	Local cTipoAtrib
	Local cRedImp  := 0
	Local aArea    := getArea()
	Local aAreaGUT := GUT->(getArea())
	Local aRetorno := {0,"2",0,0} // Os dados do array correspondem a transportador não contribuinte

	Local cUFOrigem
	Local cUFDestino
	Local cUFRem
	Local cRgTriRem
	Local cRgTriDest
	Local cApuIcms
	Local cConRem
	Local cConDest
	Local cConTrp
	Local cCidRem
	Local cGU3_ESEXIC

	// Variáveis para tratar nova opção de Contribuinte
	Local cCidPos
	Local cUFIni
	Local cUFFim
	Local cUFTrp

	Default cFilCre := cFilAnt

	//busca dos valores referentes a transportadora, remetente e destinatário

	cCidRem := Posicione("GU3",1,xFilial("GU3")+cCdRem,"GU3_NRCID")

	If Empty(cOrigem)
		cUFRem := "*"
	Else
		cUFRem := Posicione("GU7",1,xFilial("GU7")+cOrigem,"GU7_CDUF")
	EndIf

	cUFOrigem  := Posicione("GU7",1,xFilial("GU7")+cOrigem,"GU7_CDUF")
	cUFDestino := Posicione("GU7",1,xFilial("GU7")+cDestin,"GU7_CDUF")

	cRgTriRem  := Posicione("GU3",1,xFilial("GU3")+cCdRem,"GU3_TPTRIB")
	cRgTriDest := Posicione("GU3",1,xFilial("GU3")+cCdDest,"GU3_TPTRIB")
	cRgTrbTrp  := Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_TPTRIB")

	cConRem	 := Posicione("GU3",1,xFilial("GU3")+cCdRem,"GU3_CONICM")
	cConDest := Posicione("GU3",1,xFilial("GU3")+cCdDest,"GU3_CONICM")
	cConTrp  := Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_CONICM")
	cGU3_ESEXIC := Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_ESEXIC")

	If cConTrp == "1" .And. cUFOrigem $ cGU3_ESEXIC
		cConTrp := "2"
	EndIf

	cApuIcms := Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_APUICM")

	//-----------------------------------------------------------------------
	// Verifica a nova opção de Contribuinte ICMS, caso esteja marcada é verificada a origem para definir se é contribuinte.
	If cConTrp == "3"
		cCidPos := Posicione("GU3",1,xFilial("GU3")+cCdTrp,"GU3_NRCID")
		cUFTrp  := Posicione("GU7",1,xFilial("GU7")+cCidPos,"GU7_CDUF")

		If cUFTrp == cUFOrigem
			cConTrp := "1"
		Else
			cConTrp := "2"
		EndIf
	EndIf

	//-----------------------------------------------------------------------
	// Verifica a nova opção de Contribuinte ICMS, caso esteja marcada é verificada a origem para definir se é contribuinte.
	If cConRem == "3"
		cCidPos := Posicione("GU3",1,xFilial("GU3")+cCdRem,"GU3_NRCID")
		cUFIni  := Posicione("GU7",1,xFilial("GU7")+cCidPos,"GU7_CDUF")

		If cUFIni == cUFOrigem
			cConRem := "1"
		Else
			cConRem := "2"
		EndIf
	EndIf
	//-----------------------------------------------------------------------

	//-----------------------------------------------------------------------
	// Verifica a nova opção de Contribuinte ICMS, caso esteja marcada é verificado o destino para definir se é contribuinte.
	If cConDest == "3"
		cCidPos := Posicione("GU3",1,xFilial("GU3")+cCdDest,"GU3_NRCID")
		cUFFim  := Posicione("GU7",1,xFilial("GU7")+cCidPos,"GU7_CDUF")

		If cUFFim == cUFDestino
			cConDest := "1"
		Else
			cConDest := "2"
		EndIf
	EndIf
	//-----------------------------------------------------------------------

	cAliasQry := GetNextAlias()

	cQuery := " SELECT * FROM " + RetSQLName("GUR")
	cQuery += " WHERE (GUR_FILIAL = '" + xFilial("GUR") +"')"
	cQuery += " AND   (GUR_UF     = '*' OR GUR_UF     = '" + cUFRem     + "') "
	cQuery += " AND   (GUR_TPITEM = '*' OR GUR_TPITEM = '" + cTpItens   + "') "
	cQuery += " AND   (GUR_TPCLFR = '*' OR GUR_TPCLFR = '" + cTpClass   + "') "
	//cQuery += " AND   (GUR_UFORIG = '*' OR GUR_UFORIG = '" + cUFOrigem  + "') "
	cQuery += " AND   (GUR_UFDEST = '*' OR GUR_UFDEST = '" + cUFDestino + "') "
	cQuery += " AND   (GUR_USO    = '0' OR GUR_USO    = '" + cUsoCarga  + "') "
	cQuery += " AND   (GUR_TRREM  = '0' OR GUR_TRREM  = '" + cRgTriRem  + "') "
	cQuery += " AND   (GUR_TRDEST = '0' OR GUR_TRDEST = '" + cRgTriDest + "') "
	cQuery += " AND   (GUR_CICMS  = '0' OR GUR_CICMS  = '" + cTribIcms  + "') "
	cQuery += " AND   (GUR_TRIBR  = '0' OR GUR_TRIBR  = '" + cConRem    + "') "
	cQuery += " AND   (GUR_TRIBD  = '0' OR GUR_TRIBD  = '" + cConDest   + "') "
	cQuery += " AND   (GUR_CDTPOP = '*' OR GUR_CDTPOP = '" + cRomTpOp   + "') "
	cQuery += " AND   (GUR_TRTRAN = '0' OR GUR_TRTRAN = '" + cRgTrbTrp  + "') "
	cQuery += " AND   (GUR_TRIBT  = '0' OR GUR_TRIBT  = '" + cConTrp    + "') "
	cQuery += " AND   (D_E_L_E_T_ = ' ') "
	cQuery += " ORDER BY GUR_PRIOR ASC "

	Query := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

	dbSelectArea(cAliasQry)
	(cAliasQry)->( dbGoTop() )
	If !(cAliasQry)->( Eof() )
		nAliqIcms  := (cAliasQry)->GUR_PCICMS
		cTipoAtrib := (cAliasQry)->GUR_TPTRIB
		cRedImp    := (cAliasQry)->GUR_PCREIC
	Else
		dbSelectArea("GUT")
		dbSetOrder(1)
		If dbSeek(xFilial("GUT")+cUFOrigem)
			// Contribuinte
			If cConDest == "1"
				// Estadual
				If (cUFOrigem == cUFDestino)
					nAliqIcms  := GUT->GUT_PCEC
					cTipoAtrib := GUT->GUT_TREC
					//Interestadual
				Else
					nAliqIcms  := GUT->GUT_PCIC
					cTipoAtrib := GUT->GUT_TRIC
				EndIf

				// Casos particulares de apuração de ICMS de transportador contribuinte
				If cApuIcms == "2"
					cTipoAtrib := "3"
				ElseIf cApuIcms == "3"
					cTipoAtrib := "4"
				ElseIf cApuIcms == "4"
					cTipoAtrib := "7"
				EndIf

				// Não-Contribuinte
			Else
				// Estadual
				If (cUFOrigem == cUFDestino)
					nAliqIcms  := GUT->GUT_PCENC
					cTipoAtrib := GUT->GUT_TRENC
					//Interestadual
				Else
					nAliqIcms  := GUT->GUT_PCINC
					cTipoAtrib := GUT->GUT_TRINC
				EndIf
			EndIf
		Else
			nAliqIcms  := 0
			cTipoAtrib := "2" //Não-tributado - genérico caso não encontre UF
		EndIf
	EndIf

	// Parâmtro global de crédito de ICMS - MV_GFECRIC
	// Sobreescreve o tipo de tributação caso o parâmetro esteja marcado como "Não tem direito a crédito"
	If SuperGetMv("MV_GFECRIC", .F., "1", cFilCre) == "2"
		cTipoAtrib := "6"
	EndIF


	aRetorno[1] := nAliqIcms
	aRetorno[2] := cTipoAtrib
	aRetorno[3] := cRedImp

	If cTipoAtrib == "7" // Tipo de tributação presumido
		aRetorno[4] := Posicione("GUT",1,xFilial("GUT")+cUFRem,"GUT_ICMPRE")
	EndIf

	(cAliasQry)->(dbCloseArea())
	restArea(aAreaGUT)
	restArea(aArea)

Return aRetorno

// nDirecao: 1 = Posterior, -1: Anterior
Static Function PrxDiaUtil(dData, acaoVenc)
	Local dDiaUtil
	Local dDiaVer  := dData
	Local lDataOk  := .F.
	Local aAreaGUW := GUW->( GetArea() )
	Local nDirecao := 1 // Adiar

	If acaoVenc == "1" // Manter
		Return dData
	EndIf

	If acaoVenc == "3" // Antecipar
		nDirecao := -1
	EndIf

	dbSelectArea("GUW")
	dbSetOrder(1)

	While(lDataOk == .F.)
		If dbSeek(xFilial("GUW") + DTOS(dDiaVer))
			If GUW->GUW_TPDIA == "1"
				dDiaUtil := dDiaVer
				lDataOk = .T.
			Else
				dDiaVer := dDiaVer + nDirecao
			EndIf
		Else
			dDiaUtil := dDiaVer
			lDataOk = .T.
		EndIf
	EndDo

	RestArea(aAreaGUW)
Return dDiaUtil

// nDirecao: 1 = Posterior, -1: Anterior
Static Function DiaSemEmit(dData)
	Local dDiaSemana := dData
	Local lDataOk := .F.
	Local iSemana

	If !(GU3->GU3_SEGUN == "2" .AND. GU3->GU3_TERCA == "2" .AND. GU3->GU3_QUARTA == "2" .AND. GU3->GU3_QUINTA == "2" .AND. GU3->GU3_SEXTA == "2")

		While(lDataOk == .F.)
			iSemana := DOW(dDiaSemana)
			Do Case
			Case iSemana == 2 // Segunda
				If GU3->GU3_SEGUN == "1"
					lDataOk := .T.
				EndIf
			Case iSemana == 3 // Terça
				If GU3->GU3_TERCA == "1"
					lDataOk := .T.
				EndIf
			Case iSemana == 4 // Quarta
				If GU3->GU3_QUARTA == "1"
					lDataOk := .T.
				EndIf
			Case iSemana == 5 // Quinta
				If GU3->GU3_QUINTA == "1"
					lDataOk := .T.
				EndIf
			Case iSemana == 6 // Sexta
				If GU3->GU3_SEXTA == "1"
					lDataOk := .T.
				EndIf
			EndCase
			If lDataOk
				dDiaSemana := dDiaSemana
			Else
				dDiaSemana := dDiaSemana + 1
			EndIf
		EndDo

	Endif

Return dDiaSemana



// Busca o próximo dia informado no cadastro de emitentes
Static Function DiaMesEmit(dData)
	Local dDiaMes := dData
	Local lDataOk := .F.

	If (Empty(GU3->GU3_DBAS1).AND.Empty(GU3->GU3_DBAS2).AND.Empty(GU3->GU3_DBAS3).AND.Empty(GU3->GU3_DBAS4))
		lDataOk := .T.
	EndIf

	While(lDataOk == .F.)

		Do Case
		Case Day(dDiaMes) == GU3->GU3_DBAS1
			lDataOk := .T.
		Case Day(dDiaMes) == GU3->GU3_DBAS2
			lDataOk := .T.
		Case Day(dDiaMes) == GU3->GU3_DBAS3
			lDataOk := .T.
		Case Day(dDiaMes) == GU3->GU3_DBAS4
			lDataOk := .T.
		EndCase
		If !lDataOk
			dDiaMes := dDiaMes + 1
		EndIf
	EndDo

Return dDiaMes

//-------------------------------------------------------------------
/*/{Protheus.doc} GFECalcVc
Retorna a data de vencimento da fatura, de acordo com os parâmetros da tabela emitente (GU3)

@param  dDataEmiss	Data de emissão
@param  cCodEmit   	Código do emitente

@sample
GFECalcVc(dDataBase, "1")


@author Israel A Possoli
@since 25/11/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFECalcVc(dDataEmiss, cCodEmit)
	Local dDataBase  := dDataEmiss
	Local dDataVenc  := Nil
	Local dDataPE    := Nil
	Local aArea      := GetArea()
	Local aAreaGU3   := GU3->( GetArea() )

	Private lPEXFA02 := ExistBlock("GFEXFA02")

	dbSelectArea("GU3")
	dbSetOrder(1)
	dbSeek(xFilial("GU3") + cCodEmit)

	If GU3->GU3_CALCVC == "1"
		// Quando for calcular vencimento, somar o número de dias do prazo à data de emissão da pré-fatura.
		dDataBase := dDataEmiss + GU3->GU3_PRAZO
		dDataVenc := dDataBase

		// Semanal
		If GU3->GU3_TPFREQ == "2"
			// Busca o próxima dia da semana parametrizado na tabela emitente (GU3)
			dDataBase := DiaSemEmit(dDataBase)

			// Valida a data comparando os dias úteis, adiando,antecipando ou mantendo a data
			dDataVenc := PrxDiaUtil(dDataBase, GU3->GU3_ACAOVC)
		EndIf

		// Mês (Dia Base)
		If GU3->GU3_TPFREQ == "1"

			// Busca o próximo dia parametrizado na tabela emitente (GU3)
			dDataBase := DiaMesEmit(dDataBase)

			// Valida a data comparando os dias úteis, adiando,antecipando ou mantendo a data
			dDataVenc := PrxDiaUtil(dDataBase, GU3->GU3_ACAOVC)

			// Qualquer Dia
		ElseIf GU3->GU3_TPFREQ == "0"

			//Valida a data comparando os dias úteis, adiando,antecipando ou mantendo a data
			dDataVenc := PrxDiaUtil(dDataBase, GU3->GU3_ACAOVC)

		EndIf
	EndIf

	// Ponto de Entrada para permitir alterar a data de vencimento da fatura
	If  lPEXFA02
		dDataPE := ExecBlock("GFEXFA02",.f.,.f.,{dDataVenc, cCodEmit})
		If ValType(dDataPE) == "D" .And. !Empty(dDataPE)
			dDataVenc := dDataPE
		EndIf
	Endif

	RestArea(aAreaGU3)
	RestArea(aArea)

Return dDataVenc

//-------------------------------------------------------------------
/*/{Protheus.doc} PrevEntreg
Atualiza o valor da Data de Previsão de Entrega na liberação do Romaneio

@param	cFilRom		 Filial do Romaneio
@param  cNrRomaneio  Numero do Romaneio

@sample
PrevEntreg(GWN->GWN_NRROM)

@return
[1] Sucesso/Façha
[2] Mensagem de Erro	


@author Israel A. Possoli
@since 14/02/13
@version 1.0
/*/
//-------------------------------------------------------------------

Function PrevEntreg(cFilRom, cNrRomaneio, dDataBase, cHoraBase)
	Local aTabPrazo[11]		// Valores para o cálculo da data de previsão pela tabela de prazos
	Local aRetTabPrazo[8]	// Retorno da data de previsão pela tabela de prazos
	Local aPreDataHR[5]		// Retorno da função PrevDtEnt
	Local aRet[2]
	Local dDataRef   := dDataBase
	Local cHoraRef   := cHoraBase
	Local cNrTab     := ""
	Local cCdEmit    := ""
	Local aRetPE     := {}
	Local cAliasGW1  := Nil
	Local cWhere     := Nil
	Private lPEXFA01 := ExistBlock("GFEXFA01")

	aRet[1] := .F.

	// Romaneio
	dbSelectArea("GWN")
	GWN->( dbSetOrder(1) )
	If GWN->( dbSeek(cFilRom + cNrRomaneio) )
		If GWN->GWN_SIT == "3" .and. GWN->GWN_CALC == "1"

			// Documento de Carga
			If GFXCP1212210('GW1_FILROM')
				cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
			Else
				cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
			EndIf
			cWhere := "%" + cWhere + "%"

			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
				FROM %table:GW1% GW1
				WHERE %Exp:cWhere%
				AND GW1.GW1_NRROM  = %Exp:GWN->GWN_NRROM%
				AND GW1.%NotDel%
				ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
			EndSql
			While !(cAliasGW1)->(Eof())
				GW1->(dbGoto( (cAliasGW1)->GW1RECNO) )

				dDataRef := dDataBase
				cHoraRef := Transform(cHoraBase, '@R 99:99')

				// Trecho
				dbSelectArea("GWU")
				GWU->( dbSetOrder(1) )
				GWU->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) )
				While !GWU->( Eof() ) .And. GWU->GWU_FILIAL == GW1->GW1_FILIAL ;
						.And. GWU->GWU_CDTPDC == GW1->GW1_CDTPDC ;
						.And. GWU->GWU_EMISDC == GW1->GW1_EMISDC ;
						.And. GWU->GWU_SERDC  == GW1->GW1_SERDC  ;
						.And. GWU->GWU_NRDC   == GW1->GW1_NRDC

					If GWU->GWU_PAGAR == "1"
						// Documento do Calculo de Frete
						dbSelectArea("GWH")
						GWH->( dbSetOrder(2) )
						GWH->( dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC))
						While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == GW1->GW1_FILIAL ;
								.And. GWH->GWH_CDTPDC == GW1->GW1_CDTPDC ;
								.And. GWH->GWH_EMISDC == GW1->GW1_EMISDC ;
								.And. GWH->GWH_SERDC  == GW1->GW1_SERDC ;
								.And. GWH->GWH_NRDC   == GW1->GW1_NRDC

							// Cálculo de Frete
							dbSelectArea("GWF")
							GWF->( dbSetOrder(1) )
							GWF->( dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC) )
							While !GWF->( Eof() ) .And. GWF->GWF_FILIAL == GWH->GWH_FILIAL .And. GWF->GWF_NRCALC == GWH->GWH_NRCALC

								// Busca o cálculo Normal ou Redespaho relacionado ao trecho
								If (GWF->GWF_TPCALC == "1" .OR. GWF->GWF_TPCALC == "6") .AND. AllTrim(GWF->GWF_SEQTRE) == GWU->GWU_SEQ
									// Tabela do Cálculo de Frete
									// Será usada a primeira encontrada, as tarifas devem estar parametrizadas da mesma forma
									// para calcular o prazo de entrega
									GWG->(dbSetOrder(1))
									GWG->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC))
									/*MLOG-2160 - Posiciona na tabela de frete para saber se é uma tabela normal ou
									de vínculo. Alimenta os campos para posicionamento da GV6 conforme o tipo da tabela.*/
									GVA->(dbSetOrder(1))
									GVA->(dbSeek(xFilial("GVA")+GWG->(GWG_CDEMIT+GWG_NRTAB)))
									If GVA->GVA_TPTAB == "2"
										cNrTab := GVA->GVA_TABVIN
										cCdEmit := GVA->GVA_EMIVIN
									Else
										cNrTab := GVA->GVA_NRTAB
										cCdEmit := GVA->GVA_CDEMIT
									EndIf 

									// Busca da Tarifa da tabela de Frete
									dbSelectArea("GV6")
									dbSetOrder(1)
									If dbSeek(xFilial("GV6") + cCdEmit + cNrTab + GWG->GWG_NRNEG + GWG->GWG_CDFXTV + GWG->GWG_NRROTA)
										// Data Prevista - Tabela de Prazo
										If GV6->GV6_CONSPZ == "0"
											aTabPrazo := GFEPrazoTre(GWU->GWU_FILIAL, GWU->GWU_CDTPDC, GWU->GWU_EMISDC, GWU->GWU_SERDC, GWU->GWU_NRDC, GWU->GWU_SEQ)

											aTabPrazo[7]	:= GWN->GWN_CDTPOP	// Tipo Operação

											// Se o tipo de veículo não for informado no trecho, usa do Romaneio
											If Empty(aTabPrazo[8])
												aTabPrazo[8]	:= GWN->GWN_CDTPVC	// Tipo Veículo
											EndIf

											aTabPrazo[10] := GWN->GWN_CDCLFR

											If Empty(aTabPrazo[10])
												GW8->(dbSetOrder())
												If GW8->(dbSeek(GWU->GWU_FILIAL + GWU->GWU_CDTPDC + GWU->GWU_EMISDC + GWU->GWU_SERDC + GWU->GWU_NRDC))
													While GW8->GW8_FILIAL == GWU->GWU_FILIAL .And. GW8->GW8_CDTPDC == GWU->GWU_CDTPDC .And.;
													      GW8->GW8_EMISDC == GWU->GWU_EMISDC .And. GW8->GW8_SERDC == GWU->GWU_SERDC .And.;
														  GW8->GW8_NRDC == GWU->GWU_NRDC .And. GW8->(!EoF())

														If Empty(aTabPrazo[10])
															aTabPrazo[10] := GW8->GW8_CDCLFR
														EndIf

														GW8->(dbSkip())
													EndDo
												EndIf
											EndIf

											aRetTabPrazo := GFETabPrazo(aTabPrazo, dDataRef, cHoraRef)

											aRet[1] := .T.

											If aRetTabPrazo[5] == .T.

												RecLock("GWU",.F.)
												GWU->GWU_DTPENT := aRetTabPrazo[1]
												GWU->GWU_HRPENT := aRetTabPrazo[2]

												If GFXCP12137('GWU_QTPRAZ') .And. GFXCP12137('GWU_TPPRAZ')
													GWU->GWU_QTPRAZ := aRetTabPrazo[7]
													GWU->GWU_TPPRAZ := aRetTabPrazo[8]
												EndIf

												If GFXCP12137('GWU_DTPENO') .And. GFXCP12137('GWU_HRPENO')
													GWU->GWU_DTPENO := aRetTabPrazo[1]
													GWU->GWU_HRPENO := aRetTabPrazo[2]
												EndIf
												MsUnLock("GWU")

												dDataRef := aRetTabPrazo[1]
												cHoraRef := aRetTabPrazo[2]
											EndIf
										EndIf

										If GV6->GV6_CONSPZ == "1"
											aPreDataHR := PrevDtEnt(dDataRef, cHoraRef, cCdEmit, cNrTab, GWG->GWG_NRNEG, GWG->GWG_CDFXTV, GWG->GWG_NRROTA)

											If aPreDataHR[3]
												aRet[1] := .T.

												// Deve gravar a data mais distante dentre as negociacoes
												RecLock("GWU",.F.)
												GWU->GWU_DTPENT := aPreDataHR[1]
												GWU->GWU_HRPENT := aPreDataHR[2]

												If GFXCP12137('GWU_QTPRAZ') .And. GFXCP12137('GWU_TPPRAZ')
													GWU->GWU_QTPRAZ := aPreDataHR[4]
													GWU->GWU_TPPRAZ := aPreDataHR[5]
												EndIf

												If GFXCP12137('GWU_DTPENO') .And. GFXCP12137('GWU_HRPENO')
													GWU->GWU_DTPENO := aPreDataHR[1]
													GWU->GWU_HRPENO := aPreDataHR[2]
												EndIf

												MsUnLock("GWU")

												dDataRef := aPreDataHR[1]
												cHoraRef := aPreDataHR[2]
											Else
												aRet[1] := .F.
												aRet[2] := "Data prevista não calculada. Verifique o calendário do transportador."
											EndIf								
										EndIf

										If  lPEXFA01									

											aRetPE := ExecBlock("GFEXFA01",.F.,.F.,{dDataRef,cHoraRef})
											if !empty(aRetPE)
												aRet[1] := aRetPE[1]
												aRet[2] := aRetPE[2]											 	
											Endif				 					 	
										Endif													

									EndIf

									If GV6->GV6_CONSPZ != "1" .AND. GV6->GV6_CONSPZ != "2"
										aRet[1] := .F.
										aRet[2] := "Tarifa parametrizada para não calcular Data de Previsão. Emissor: [" + GWG->GWG_CDEMIT + "], Tabela: [" + GWG->GWG_NRTAB + "], Neg: [" + GWG->GWG_NRNEG + "], Faixa: [" + GWG->GWG_CDFXTV + "], Rota: [" + GWG->GWG_NRROTA + "]"
									EndIf
								Else
									aRet[1] := .F.
									aRet[2] := "TTipo do cálculo ou sequencia da rota inválida. Tipo Cálculo: [" + GWF->GWF_TPCALC + "], Rota: [" + GWF->GWF_SEQTRE + "]"
								EndIf

								dbSelectArea("GWF")
								GWF->( dbSkip() )
							EndDo

							dbSelectArea("GWH")
							GWH->( dbSkip() )
						EndDo
					Else
						aRet[1] := .F.
						aRet[2] := "Trecho não pago. Emissor: [" + GWU->GWU_EMISDC + "], Série: [" + GWU->GWU_SERDC + "], Número: [" + GWU->GWU_NRDC + "], Trecho: [" + GWU->GWU_SEQ + "]"					
					EndIf
					dbSelectArea("GWU")
					GWU->( dbSkip() )
				EndDo

				(cAliasGW1)->(dbSkip())
			EndDo	
			(cAliasGW1)->(dbCloseArea())
		Else
			aRet[1] := .F.
			aRet[2] := "Romaneio [" + cNrRomaneio + "] não liberado ou não calculado"					
		EndIf
	EndIf
Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} VLTOTFRET(cFil, nCalc)

Retorna o valor total do frete

@param  nCalc - Número do Cálculo

@sample
VLTOTFRET(nCalc)


@author Jorge Matos Valcanaia
@since 18/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function VLTOTFRET(cFil,  nCalc)
	Local VlTotal := 0

	If cFil != Nil .AND. nCalc != Nil
		dbSelectArea("GWF")
		dbSetOrder(1)
		dbSeek(cFil + nCalc)
	EndIf

	dbSelectArea("GWI")
	dbSetOrder(1)
	dbSeek(GWF->GWF_FILIAL+GWF->GWF_NRCALC)
	While !Eof() .And. GWI->GWI_FILIAL == GWF->GWF_FILIAL .And. GWI->GWI_NRCALC == GWF->GWF_NRCALC
		If GWI->GWI_TOTFRE == "1"
			VlTotal := VlTotal + GWI->GWI_VLFRET
		Endif
		dbSelectArea("GWI")
		dbSkip()
	EndDo
	Vltotal += GWF->GWF_VLAJUS
Return VlTotal


//-------------------------------------------------------------------
/*/{Protheus.doc} PrevDtEnt
Retorna a data e hora prevista de entrega a partir de uma data base.
Apenas quando o tipo de prazo for com base na tarifa GV6->GV6_CONSPZ == "1"

@param	dtBase		: Data Base
hrBase		: Hora Base
cEmit		: Código do Emitente 	(GV6_CDEMIT)
cTabela		: Número da Tabela 		(GV6_NRTAB)
cNrNegoc	: Número da Negociação	(GV6_NRNEG)
cSeqFaixa	: Sequência da Faixa 	(GV6_CDFXTV)
cNrRota		: Número da Rota 		(GV6_NRROTA)

@sample
PrevDtEnt(dtBase, hrBase, cEmit, cTabela, cNrNegoc, cSeqFaixa, cNrRota)

@return
aRet[1]	: Data Prevista de Entrega
aRet[2]	: Hora Prevista de Entrega
aRet[3]	: Sucesso/Falha


@author Israel A Possoli
@since 19/08/2014
@version 1.1
/*/
//-------------------------------------------------------------------
function PrevDtEnt(dtBase, hrBase, cEmit, cTabela, cNrNegoc, cSeqFaixa, cNrRota)
	Local aRet[5]
	Local aRetHoras[2]
	Local nDataCount := 0
	Local aDataTmp := dtBase
	Local lPEXFA04 := ExistBlock("GFEXFA04")


	aRet[1] := dtBase
	aRet[2] := hrBase
	aRet[3] := .F.

	dbSelectArea("GV6")
	dbSetOrder(1)
	If dbSeek(xFilial("GV6") + cEmit + cTabela + cNrNegoc + cSeqFaixa + cNrRota)
		If GV6->GV6_CONSPZ == "1"
			// Dias
			If GV6->GV6_TPPRAZ == "1"
				dbSelectArea("GUW")
				If dbSeek(xFilial("GUW") + DToS(dtBase))
					GUW->(dbSkip())
					While !GUW->(Eof())
						aDataTmp++						

						// Se for dia útil ou se o tipo de prazo for dias corridos
						If GUW->GUW_TPDIA = "1" .OR. GV6->GV6_CONTPZ == "1"
							nDataCount++				
						EndIf

						If nDataCount >= GV6->GV6_QTPRAZ
							aRet[1] := aDataTmp
							aRet[3] := .T.
							Exit
						EndIf

						GUW->(dbSkip())
					EndDo
				EndIf
			EndIf

			// Horas
			If GV6->GV6_TPPRAZ == "2"
				aRetHoras := DtHrPrev(dtBase, hrBase, GV6->GV6_QTPRAZ)

				aRet[1] := aRetHoras[1]
				aRet[2] := aRetHoras[2]
				aRet[3] := .T.
			EndIf
		EndIf

		aRet[4] := GV6->GV6_QTPRAZ

		If GV6->GV6_TPPRAZ == "1" .And. GV6->GV6_CONTPZ == "2" //Dias uteis
			aRet[5] := "0"
		ElseIf GV6->GV6_TPPRAZ == "1" .And. GV6->GV6_CONTPZ == "1" //Dias corridos
			aRet[5] := "1"
		Else
			aRet[5] := "2" //Horas
		EndIf

		// Ponto de Entrada para permitir alterar a data de previsão de entrega
		If lPEXFA04
			aRetPE := ExecBlock("GFEXFA04",.f.,.f.,{aRet})
			If ValType(aRetPE) == "A"
				aRet := aRetPE
			EndIf				
		EndIf		

	EndIf
	Return(aRet)


	//-------------------------------------------------------------------
	/*/{Protheus.doc} DtHrPrev
	Calcula uma data e hora a partir de uma data base e quantidade de horas adicionais.
	Usado na rotina de Data Prevista de Entrega, quando a tarifa estiver parametrizada para calcular o prazo em horas.

	@param	dDataBase	: Data Base
	hrBase		: Hora Base
	nQtdeHoras	: Quantidade de Horas a ser calculada

	@sample
	DtHrPrev(dDataBase, hrBase, nQtdeHoras)

	@return
	aRet[1]	: Data Calculada
	aRet[2]	: Hora Calculada


	@author Israel A Possoli
	@since 19/08/2014
	@version 1.1
	/ */
	//-------------------------------------------------------------------
	Function DtHrPrev(dDataBase, hrBase, nQtdeHoras)
	Local aRet[2]
	Local cHora
	Local nHora
	Local cMinuto
	Local nDias

	aRet[1] := dDataBase
	aRet[2] := hrBase

	// Desconsidera a hora se o tamanho for menor que 4
	If Len(hrBase) <= 3
	Return(aRet)
	EndIf

	// Extrai a informação de Hora e Minuto
	cHora 	:= Left(hrBase, 2)
	If Len(hrBase) <= 5
	cMinuto	:= Right(hrBase, 2)
	Else
	If ":" $ hrBase
	cMinuto	:= SubStr(hrBase, 4, 2)
	Else
	cMinuto	:= SubStr(hrBase, 3, 2)
	EndIf
	EndIf

	// Calcula a quantidade de horas
	nHora := Val(cHora) + nQtdeHoras

	// Calcula os dias excedentes
	nDias := NoRound(nHora / 24, 0)

	// Calcula o dia e a hora quando a quantidade de horas passar do dia atual
	If nDias > 0
	aRet[1] := dDataBase + nDias
	nHora   := Val(cHora) + Mod(nQtdeHoras, 24)
	If nHora >= 24
	nHora := nHora - 24
	EndIf
	EndIf

	aRet[2] := StrZero(nHora, 2) + ":" + cMinuto
	Return(aRet)



	//-------------------------------------------------------------------
	/*/{Protheus.doc} GFEDSMVCT(nTrans)

	Retorna a descrição do Movimento Contabil

	@param  nTrans - Valor númerico do movimento contabil

	@author Jorge Matos Valcanaia
	@since 18/02/10
	@version 1.0
	/*/
	//-------------------------------------------------------------------
	Function GFEDSMVCT(nTrans)
	Local cDsMovi /*Variavel que recebe a descrição do Movimento*/

	If Alltrim(nTrans) == "100"
		cDsMovi := STR0001 //"Emissao de Contrato com Terceiro"
	Elseif Alltrim(nTrans) == "101"
		cDsMovi := STR0002 //"IRRF a recolher"
	Elseif Alltrim(nTrans) == "102"
		cDsMovi := STR0003 //"SEST/SENAT a recolher"
	Elseif Alltrim(nTrans) == "103"
		cDsMovi := STR0004 //"Adiantamento de Frete a Terceiro"
	Elseif Alltrim(nTrans) == "104"
		cDsMovi := STR0005 //"Adiantamento de Pedagio para Terceiro"
	Elseif Alltrim(nTrans) == "105"
		cDsMovi := STR0006 //"Cancelamento de Contrato"
	Elseif Alltrim(nTrans) == "106"
		cDsMovi := STR0007 //"Estorno de IRRF a Recolher"
	Elseif Alltrim(nTrans) == "107"
		cDsMovi := STR0008 //"Estorno de SEST/SENAT a Recolher"
	Elseif Alltrim(nTrans) == "108"
		cDsMovi := STR0009 //"Estorno de Adiantamento de Frete"
	Elseif Alltrim(nTrans) == "109"
		cDsMovi := STR0010 //"Estorno de Adiantamento de Pedagio"
	Elseif Alltrim(nTrans) == "110"
		cDsMovi := STR0011 //"Baixa de Contrato"
	Elseif Alltrim(nTrans) == "111"
		cDsMovi := STR0012 //"Quitacao de Pedagio"
	Elseif Alltrim(nTrans) == "112"
		cDsMovi := STR0013 //"Estorno de Baixa de Contrato"
	Elseif Alltrim(nTrans) == "113"
		cDsMovi := STR0014 //"Estorno de Quitacao de Pedagio"
	Elseif Alltrim(nTrans) == "114"
		cDsMovi := STR0015 //"Complemento de Pedagio"
	Elseif Alltrim(nTrans) == "115"
		cDsMovi := STR0016 //"Restituicao de Adiantamento de Pedagio"
	Elseif Alltrim(nTrans) == "116"
		cDsMovi := STR0017 //"Estorno de Complemento de Pedagio"
	Elseif Alltrim(nTrans) == "117"
		cDsMovi := STR0018 //"Estorno de Restituicao de Pedagio"
	Elseif Alltrim(nTrans) == "118"
		cDsMovi := STR0019 //"INSS Empresa a Recolher"
	Elseif Alltrim(nTrans) == "119"
		cDsMovi := STR0020 //"Estorno de INSS Empresa a Recolher"
	Elseif Alltrim(nTrans) == "120"
		cDsMovi := STR0021 //"Provisao de Pagamento de Contrato"
	Elseif Alltrim(nTrans) == "121"
		cDsMovi := STR0022 //"Provisao de INSS Empresa a Recolher"
	Elseif Alltrim(nTrans) == "122"
		cDsMovi := STR0023 //"Provisao de Pagamento de Pedagio para Contrato"
	Elseif Alltrim(nTrans) == "123"
		cDsMovi := STR0024 //"Estorno de Provisao de Pagamento de Contrato"
	Elseif Alltrim(nTrans) == "124"
		cDsMovi := STR0025 //"Estorno de Provisao de INSS Empresa a Recolher"
	Elseif Alltrim(nTrans) == "125"
		cDsMovi := STR0026 //"Estorno de Provisao de Pgto de Pedagio de Contrato"
	Elseif Alltrim(nTrans) == "126"
		cDsMovi := STR0027 //"INSS Terceiro a recolher"
	Elseif Alltrim(nTrans) == "127"
		cDsMovi := STR0028 //"ISS contrato a recolher"
	Elseif Alltrim(nTrans) == "128"
		cDsMovi := STR0029 //"Estorno de INSS Terceiro a recolher"
	Elseif Alltrim(nTrans) == "129"
		cDsMovi := STR0030 //"Estorno de ISS contrato a recolher"
	Elseif Alltrim(nTrans) == "300"
		cDsMovi := STR0031 //"Provisao de Despesa de Frete"
	Elseif Alltrim(nTrans) == "301"
		cDsMovi := STR0032 //"Provisao ICMS"
	Elseif Alltrim(nTrans) == "302"
		cDsMovi := STR0033 //"Provisao PIS"
	Elseif Alltrim(nTrans) == "303"
		cDsMovi := STR0034 //"Provisao COFINS"
	Elseif Alltrim(nTrans) == "304"
		cDsMovi := STR0035 //"Provisao de Pedagio"
	Elseif Alltrim(nTrans) == "305"
		cDsMovi := STR0036 //"Estorno da Provisao de Despesa de Frete"
	Elseif Alltrim(nTrans) == "306"
		cDsMovi := STR0037 //"Estorno da Provisao de ICMS"
	Elseif Alltrim(nTrans) == "307"
		cDsMovi := STR0038 //"Estorno da Provisao de PIS"
	Elseif Alltrim(nTrans) == "308"
		cDsMovi := STR0039 //"Estorno da Provisao de COFINS"
	Elseif Alltrim(nTrans) == "309"
		cDsMovi := STR0040 //"Estorno da Provisao de Pedagio"
	Elseif Alltrim(nTrans) == "310"
		cDsMovi := STR0041 //"Contabilizacao da Despesa de Frete"
	Elseif Alltrim(nTrans) == "311"
		cDsMovi := STR0042 //"Contabilizacao de ICMS"
	Elseif Alltrim(nTrans) == "312"
		cDsMovi := STR0043 //"Contabilizacao de PIS"
	Elseif Alltrim(nTrans) == "313"
		cDsMovi := STR0044 //"Contabilizacao de COFINS"
	Elseif Alltrim(nTrans) == "314"
		cDsMovi := STR0045 //"Contabilizacao de Pedagio"
	Elseif Alltrim(nTrans) == "315"
		cDsMovi := STR0046 //"Estorno da Contabilizacao da Despesa de Frete"
	Elseif Alltrim(nTrans) == "316"
		cDsMovi := STR0047 //"Estorno da Contabilizacao do ICMS"
	Elseif Alltrim(nTrans) == "317"
		cDsMovi := STR0048 //"Estorno da Contabilizacao do PIS"
	Elseif Alltrim(nTrans) == "318"
		cDsMovi := STR0049 //"Estorno da Contabilizacao do COFINS"
	Elseif Alltrim(nTrans) == "319"
		cDsMovi := STR0050 //"Estorno da Contabilizacao do Pedagio"
	Endif
Return cDsMovi

//-------------------------------------------------------------------
/*/{Protheus.doc} GFERATFRTDC

Função de rateio do frete de um calculo para o documentos de carga informado

@author Luciano de Araujo
@since 08/10/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFERATFRTDC(cNrCalc, cChaveDC)

	Local nTotalRat  := 0
	Local nQtdDoc    := 0
	Local nVlDoc     := 0
	Local nQtM3Doc   := 0
	Local nPesoDoc   := 0
	Local nPesoCDoc  := 0
	Local nQtdTot    := 0
	Local nVlTot     := 0
	Local nQtM3Tot   := 0
	Local nPesoTot   := 0
	Local nPesoCTot  := 0
	Local nVlFreteDC := 0
	Local nQtdDC     := 0
	Local cCriRat    := SuperGetMv("MV_CRIRAT",,"1")
	Local cFilGW1

	//Salva o estado corrente das tabelas manipuladas por esta função
	Local aAreaGW1 := GW1->(getArea()), aAreaGWH := GWH->(getArea()), aAreaGW8 := GW8->(getArea())

	dbSelectArea("GW1")
	dbSetOrder(1)
	if dbSeek(xFilial("GW1")+cChaveDC)

		dbSelectArea("GWH")
		dbSetOrder(2)
		if dbSeek(xFilial("GWH")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC+cNrCalc)
			cFilGW1 := GW1->GW1_FILIAL
			// Totaliza os itens de todas as notas do calculo
			dbSelectArea("GWH")
			dbSetOrder(1)
			dbSeek(xFilial("GWH")+cNrCalc)
			While !Eof() .And. xFilial("GWH") == GWH->GWH_FILIAL .And. GWH->GWH_NRCALC == cNrCalc

				nQtdDC++

				dbselectArea("GW8")
				dbSetOrder(1)
				dbSeek(xFilial("GW8")+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC)
				While !Eof() .And. GW8->GW8_CDTPDC == GWH->GWH_CDTPDC;
				.And. GW8->GW8_EMISDC == GWH->GWH_EMISDC;
				.And. GW8->GW8_SERDC  == GWH->GWH_SERDC;
				.And. GW8->GW8_NRDC   == GWH->GWH_NRDC

					// Acumula os valores da nota que receberá o valor rateado
					If GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC == cChaveDc
						nQtdDoc   += GW8->GW8_QTDE
						nVlDoc    += GW8->GW8_VALOR
						nQtM3Doc  += GW8->GW8_VOLUME
						nPesoDoc  += GW8->GW8_PESOR
						nPesoCDoc += GW8->GW8_PESOC
					EndIf

					nQtdTot   += GW8->GW8_QTDE
					nVlTot    += GW8->GW8_VALOR
					nQtM3Tot  += GW8->GW8_VOLUME
					nPesoTot  += GW8->GW8_PESOR
					nPesoCTot += GW8->GW8_PESOC

					dbSelectArea("GW8")
					dbSkip()
				EndDo

				dbSelectArea("GWH")
				dbSkip()
			EndDo

			If cCriRat == "1"	// Peso da mercadoria
				If nPesoTot < nPesoCTot
					nTotalRat := nPesoCTot
					nVlRat    := nPesoCDoc
				Else
					nTotalRat := nPesoTot
					nVlRat    := nPesoDoc
				Endif
			ElseIf cCriRat == "2"	// Valor da mercadoria
				nTotalRat := nVlTot
				nVlRat    := nVlDoc
			ElseIf cCriRat == "3"	// Volume da mercadoria
				nTotalRat := nQtM3Tot
				nVlRat    := nQtM3Doc
			ElseIf cCriRat == "4"	// Quantidade de itens
				nTotalRat := nQtdTot
				nVlRat    := nQtdDoc
			Endif

			If nTotalRat <> 0
				nVlFreteDc := VLTOTFRET(cNrCalc) * (nVlRat / nTotalRat)
			Else
				nVlFreteDc := 1 / nQtdDC
			Endif
		EndIf
	EndIf

	// Restaura as tabelas ao estado anterior à chamada desta função
	RestArea(aAreaGW1)
	RestArea(aAreaGWH)
	RestArea(aAreaGW8)

Return nVlFreteDc

/*------------------------------------------------------------------------
Criar a tabela temporária com base na estrutura informada
Recebe um array com duas posições
[1] Estrutura da tabela a ser criada (array)
[2] Indices da tabela a ser criada (array)
-------------------------------------------------------------------------*/
Function GFECriaTab(aArrStr,oTempTable)
	Local cAliasTab  := GetNextAlias()	    // Obtem o alias para a tabela temporária
	Local aCampos    := {}
	Local nI         := 0
	Local nJ		 := 0 
	Local cBuild     := ""

	Default oTempTable := Nil

	cBuild := TCGetBuild()

	//-------------------
	//Criação do objeto
	//-------------------
	oTempTable := FWTemporaryTable():New(cAliasTab, aArrStr[1]) 

	For nI := 1 to len(aArrStr[2])
		aCampos := StrTokArr( StrTran(aArrStr[2,nI]," ",""), "+" )
		For nJ := 1 to len(aCampos)
			If At('(',aCampos[nJ]) > 0
				aCampos[nJ] := alltrim(SubStr(aCampos[nJ],At('(',aCampos[nJ]) + 1 , Rat(')',aCampos[nJ]) - At('(',aCampos[nJ]) - 1))
			EndIf
			aCampos[nJ] := StrTran(aCampos[nJ],Chr(09),"")//Remoção de tabulação
		Next nJ
		oTempTable:AddIndex( "IND"+cValToChar(nI), aCampos ) 
	Next nI
	
	oTempTable:Create()
	nI := aScan(aAlGFE,{|x|x[1] == cAliasTab})
	If nI == 0
		aAdd(aAlGFE,{cAliasTab,oTempTable})
	Else
		aAlGFE[nI,2] := oTempTable
	EndIf
Return cAliasTab

/*------------------------------------------------------------------------
Elimina a tabela temporária e os respectivos índices
Recebe o alias da tabela a eliminar
------------------------------------------------------------------------*/
Function GFEDelTab(cAliasTab)
	Local nI
	Local oTempTable    := Nil
	Local cBuild     := "" 

	// Valores do parâmetro de dbOrderInfo
	// 7  - Retorna o nome do arquivo de índice
	// 9  - Retorna a quantidade de índices do alias corrente
	// 20 - Retorna o nome completo (caminho e extensão) do arquivo de índices

	If Select(cAliasTab) > 0

		cBuild := TCGetBuild()

		nI := aScan(aAlGFE,{|x|x[1] == cAliasTab})
		If nI == 0
			oTempTable := FWTemporaryTable():New( cAliasTab )
			oTempTable:lcreated := .T.
			oTempTable:OSTRUCT:LACTIVATE := .T.
			oTempTable:Delete()
		Else
			oTempTable := aAlGFE[nI,2]
			oTempTable:Delete()
			FreeObj(oTempTable)
			aDel(aAlGFE,nI)
			aSize(aAlGFE,Len(aAlGFE)-1)
		EndIf
	EndIf

Return .T.

// Cria tabela temporária com uso do truncate
Function CriTabTemp(aArrStr)
	Local cAliasTab  	:= ""
	Local aCampos    	:= {}
	Local nI         	:= 0
	Local nJ		 	:= 0
	Local cGetRealName 	:= ""
	
	If oTabTemp == nil
		cAliasTab := GetNextAlias()
		oTabTemp  := FWTemporaryTable():New(cAliasTab, aArrStr[1])
				
		For nI := 1 to len(aArrStr[2])
			aCampos := StrTokArr( StrTran(aArrStr[2,nI]," ",""), "+" )
			For nJ := 1 to len(aCampos)
				aCampos[nJ] := StrTran(aCampos[nJ],Chr(09),"")//Remoção de tabulação
			Next nJ

			oTabTemp :AddIndex( "IND"+cValToChar(nI), aCampos ) 
		Next nI

		oTabTemp :Create()
		
		nI := aScan(aAlGFE,{|x|x[1] == cAliasTab})
		If nI == 0
			aAdd(aAlGFE,{cAliasTab,oTabTemp})
		EndIf
	Else
		cGetrealname := oTabTemp:GETREALNAME()
		cAliasTab    := oTabTemp:GetAlias()

		TcSqlExec('DELETE FROM ' + cGetrealname)
	EndIf

Return cAliasTab

// Deleta tabela temporária com uso do truncate
Function DelTabTemp()
	Local cGetRealName	:= "" 

	If oTabTemp <> nil
		cGetrealname := oTabTemp:GETREALNAME()

		TcSqlExec('DELETE FROM ' + cGetRealName)
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEEnvMail
Função para envio de e-mail.

@param cPara        Lista dos destinatários da mensagem
@param cAssunto		Assunto do email
@param cMensagem 	Corpo do email
@param lMsg         Indica se mostra mensagem de erro
@param cATTACHMENT  indica os arquivos a serem anexados, origatorio que seja a partir do Rootpath

@author Israel Alcantara Possoli
@since 30/07/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEMail(cPara, cAssunto, cMsg, lMsg, aFiles)
	Local cError    := ""
	Local cTitle    := "Configuração"
	Local cMailAut  := SuperGetMv("MV_RELACNT",,"")  // Conta do autenticaçcao
	Local cFrom     := Iif(Empty(SuperGetMv("MV_RELFROM",,"")), cMailAut, SuperGetMv("MV_RELFROM",,""))  // Conta do Remetente
	Local cServer   := SuperGetMv("MV_RELSERV",,"")  // Servidor SMTP
	Local cPass     := SuperGetMv("MV_RELPSW",,"")  // Password do servidor
	Local lAuth     := SuperGetMv("MV_RELAUTH",, .F.)  // Servidor de EMAIL necessita de Autenticacao?
	Local lSSL      := SuperGetMv("MV_RELSSL",, .F.)
	Local lTLS      := SuperGetMv("MV_RELTLS",, .F.)
	Local nRelTime  := SuperGetMv("MV_RELTIME",, 120)
	Local aRet      := {.T.,""}
	Local cMailAuth

	Default lMsg := .T.

	If Empty(cPara)
		aRet[1] := .F.
		aRet[2] := "O e-mail do destinatário não foi informado!"
		If lMsg
			MsgStop( aRet[2] , cTitle)
		EndIf
		Return aRet
	EndIf

	If Empty(cFrom)
		aRet[1] := .F.
		aRet[2] := "O e-mail do remetente não foi informado! (MV_RELFROM)"
		If lMsg
			MsgStop( aRet[2] , cTitle)
		EndIf
		Return aRet
	EndIf

	If Empty(cServer)
		aRet[1] := .F.
		aRet[2] := "O servidor de envio do e-mail não foi informado! (MV_RELSERV)"
		If lMsg
			MsgStop( aRet[2] , cTitle)
		EndIf
		Return aRet
	EndIf

	If Empty(cMailAut) .And. lAuth // Usuário e senha é obrigatório somente se o servidor exigir autenticação
		aRet[1] := .F.
		aRet[2] := "Conta a ser utilizada na autenticação SMTP não foi informada! (MV_RELACNT)"
		If lMsg
			MsgStop( aRet[2] , cTitle)
		EndIf
		Return aRet
	EndIf

	If Empty(cPass) .And. lAuth // Usuário e senha é obrigatório somente se o servidor exigir autenticação
		aRet[1] := .F.
		aRet[2] := "A senha da conta de e-mail não foi informada! (MV_RELPSW)"
		If lMsg
			MsgStop( aRet[2] , cTitle)
		EndIf
		Return aRet
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia email                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( MailSmtpOn(cServer,cMailAut,cPass,nRelTime,lTLS,lSSL) )
		If lAuth
			If ( "@" $ cMailAut )
				cMailAuth := Subs(cMailAut,1,At("@",cMailAut)-1)
			Else
				cMailAuth := cMailAut
			EndIf
			If !(MailAuth(cMailAut,cPass) .Or. MailAuth(cMailAuth,cPass))
				cTitle  := "Autenticação"
				aRet[1] :=  .F.
				aRet[2] := "Não foi possível autenticar a conta de e-mail!" + CRLF
			EndIf
		EndIf
		If aRet[1]
			If !(MailSend(cFrom,{cPara},{},{},cAssunto,cMsg,aFiles,,lTLS,lSSL))
				cTitle  := "Envio"
				aRet[1] :=  .F.
				aRet[2] := "Falha no envio do e-mail!" + CRLF
			EndIf
		EndIf
		MailSmtpOff()
	Else
		cTitle  := "Conexão"
		aRet[1] :=  .F.
		aRet[2] := "Falha de conexão com o servidor!" + CRLF
	EndIf

	If !(aRet[1])

		Get MAIL ERROR cError

		aRet[2] += "Ocorreu o seguinte erro ao enviar o e-mail: " + cError + CRLF + CRLF
		aRet[2] += "Verifique os parâmetros de configuração de e-mail:" + CRLF + CRLF

		aRet[2] += "MV_RELACNT - Conta a ser utilizada na autenticação SMTP" + CRLF
		aRet[2] += "Conteúdo: " + cMailAut + CRLF + CRLF

		aRet[2] += "MV_RELFROM - Conta a ser utilizada no envio de e-mail" + CRLF
		aRet[2] += "Conteúdo: " + cFrom + CRLF + CRLF

		aRet[2] += "MV_RELSERV - Nome do servidor de envio de e-mail" + CRLF
		aRet[2] += "Conteúdo: " + cServer + CRLF + CRLF

		aRet[2] += "MV_RELPSW - Senha da conta de e-mail" + CRLF
		aRet[2] += "Conteúdo: " + CRLF + CRLF

		aRet[2] += "MV_RELAUTH - Servidor de e-mail necessita de autenticacão?" + CRLF
		aRet[2] += "Conteúdo: " + Iif(lAuth,"Sim","Não") + CRLF + CRLF

		aRet[2] += "MV_RELSSL - Define se o envio e recebimento de e-mails utiliza conexão SSL" + CRLF
		aRet[2] += "Conteúdo: " + Iif(lSSL,"Sim","Não") + CRLF + CRLF

		aRet[2] += "MV_RELTLS - Informe se o servidor de SMTP possui conexão do tipo segura (SSL/TLS)" + CRLF
		aRet[2] += "Conteúdo: " + Iif(lTLS,"Sim","Não") + CRLF + CRLF

		aRet[2] += "MV_RELTIME - Timeout no envio de e-mail" + CRLF
		aRet[2] += "Conteúdo: " + AllTrim(Str(nRelTime))

		If lMsg
			MsgStop( aRet[2] , cTitle)
		EndIf

	EndIf

Return aRet

Function GFEEnvMail(cPara, cAssunto, cMsg, lMsg, aFiles)
	Local aRet := GFEMail(cPara, cAssunto, cMsg, lMsg, aFiles)
Return aRet[1]

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEMsgErro
Exibe Mensagem de erro.
Uso Geral.

@param 	cMsg		Mensagem de erro
@param 	cRotina		Nome da rotina a ser exibida na janela

@Return lRet	 	 .F. Sempre retorna .F. indicando um erro para poder
usar em gatilhos e validações onde exibira a mensagem
e retornara .F.

@sample
lRetorno := IIf(nTotal > 0 , .T.,  GFEMsgErro( 'Total esta zerado', 'MinhaRotina' )

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEMsgErro( cMsg, cRotina )
	Local oModel := FWModelActive()

	ParamType 0 Var cMsg       As Character Optional Default STR0059 //"Erro ..."
	ParamType 1 Var cRotina    As Character Optional Default ProcName( 1 )
	
	If oModel <> NIL .And. Empty(oModel:AERRORMESSAGE[6])
		oModel:AERRORMESSAGE[6] := cMsg
	EndIf

	If oModel <> NIL .And. !Empty(oModel:AERRORMESSAGE[6])
		cMsg := cMsg + CRLF+"-----------------"+CRLF + ;
		STR0060 + CRLF + STR0061 + " " + oModel:AERRORMESSAGE[4] + CRLF+CRLF + oModel:AERRORMESSAGE[6] //"Detalhes tecnicos:" ### "Campo:"
	EndIF

	If !IsInCallStack("GFEA117")
		Help( ,, 'HELP', cRotina, cMsg, 1, 0)
	EndIf
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEUSUAPR
Função que verifica se o usúario corrente esta cadastrado no programa de aprovadores de tabela de frete caso o parametro MV_APRTAB esteja ativado

@author Jorge Matos Valcanaia
@since 28/01/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEUSUAPR()
	Local lRet := .T.

	dbSelectArea("GUX")
	dbSetOrder(1)
	If !dbSeek(xFilial("GUX")+RetCodUsr())
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFECOUNTTB
Função para contar quantos registros tem uma tabela de acordo com a especificação informada.

@param 	cTbl - Alias da tabela
@param  aCond - Array no formato { {cCampo, cOperador, cValor}, ...n Condições   }
@param  lDel - .T. para considerar registros deletados

@Return nQtd - quantidade final

@sample GFECOUNTTB("GW1",{{"GW1_NRDC","=","152300"}},.F.)

@author Octávio Augusto Felippe de Macedo
@since 11/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFECOUNTTB(cTbl, aCond, lDel)
	Local nCont
	Local nQtd
	Local cVal

	Default lDel  := .F.
	Default aCond := {}

	cAlias := GetNextAlias()

	cQuery := " SELECT COUNT(*) AS QTD FROM " + RetSQLName(cTbl)

	If !Empty(aCond)

		cQuery += " WHERE "

	EndIf

	For nCont := 1 To Len(aCond)

		If nCont > 1

			cQuery += " AND "

		EndIf

		If ValType(aCond[nCont][3]) == "N"
			cVal := Str(aCond[nCont][3], TamSX3(aCond[nCont][1])[1])
		ElseIf ValType(aCond[nCont][3]) == "D"
			cVal := DToS(aCond[nCont][3])
		Else
			cVal := aCond[nCont][3]
		EndIf

		cQuery += aCond[nCont][1] + " " + aCond[nCont][2] + " '" + cVal + "' "

	Next nCont

	If !lDel

		If !Empty(aCond)
			cQuery += " AND D_E_L_E_T_ = ' ' "
		Else
			cQuery += " WHERE D_E_L_E_T_ = ' ' "
		EndIf

	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

	nQtd := (cAlias)->QTD

	(cAlias)->(dbCloseArea())

Return nQtd

/*------------------------------------
Função que retorna se o campo é usado
------------------------------------*/

Function GFEUSADO(cCampo)
Return X3Usado(cCampo)

/*------------------------------------------------------------------
Função para inserção da fatura
através do model.

GFEINSFAT(aValues)

-aValues: Array multidimensional com o nome do campo e valor.
Ex: {  1ª fatura-> { {"GW6_EMIFAT", "87"},
{"GW6_SERFAT", "001"},
{"GW6_NRFAT" , "123"}
},
2ª fatura-> { {"GW6_EMIFAT", "87"},
{"GW6_SERFAT", "001"},
{"GW6_NRFAT" , "12345"}
},
{....}
}

- Retorna .T.

------------------------------------------------------------------*/

Function GFEINSFAT(aValues)
	Local nCont
	Local nI

	For nCont := 1 To Len(aValues)

		RecLock("GW6", .T.)

		For nI := 1 To Len(aValues[nCont])

			GW6->&(aValues[nCont][nI][1]) := aValues[nCont][nI][2]

		Next nI

		GW6->( MsUnlock() )

	Next nCont

Return .T.

/*-----------------------------------------------------
Função para retornar um array com com as filiais
para a empresa utilizada.

-cEmp: Grupo de Empresa para qual devem ser
buscadas as filiais. Caso não informado ou
colocado '*' será assumido para todos os
Grupos de Empresa.

Retorno será um array com a seguinte estrutura:

{
{01 , "Matriz" },
{02 , "Filial" },
...
}
-----------------------------------------------------*/

Function GFEGETFIL(cEmp)

	Local aAreaSM0
	Local aFil := {}

	Default cEmp := "*"

	dbSelectArea("SM0")
	aAreaSM0 := SM0->( GetArea() )
	SM0->( dbSetOrder(1) )

	If cEmp == "*"
		SM0->( dbGoTop() )
	Else
		SM0->( dbSeek(cEmp) )
	EndIf

	While !SM0->( Eof() ) .And. (AllTrim(SM0->M0_CODIGO) == AllTrim(cEmp) .Or. cEmp == "*")

		If !SM0->( Deleted() )
			AAdd(aFil, {FWCodFil(SM0->M0_CODFIL), SM0->M0_FILIAL})
		EndIf

		SM0->( dbSkip() )
	EndDo

	RestArea(aAreaSM0)

Return aFil

/*
{Protheus.doc}
GFEVLDHR()

Função para validar a hora informada em valid de campos, pois, cria mensagem de help.

Parâmetros: Recebe uma hora no formato "08:30" ou "0830"

@author Octávio Augusto Felippe de Macedo
@since 21/02/2011
@version 1.0
*/
Function GFEVLDHR(cHr)

	If At(":", cHr) > 0
		cHr := AllTrim(StrTran(cHr, ":", ""))
	EndIf

	If !(SubStr(cHr,1,2) <= "23" .And. SubStr(cHr,1,2) >= "00" .And. SubStr(cHr,3,2) <= "59" .And. SubStr(cHr,3,2) >= "00") .Or. ;
			Len(AllTrim(cHr)) < 4 .Or. Len(AllTrim(SubStr(cHr,1,2))) != 2 .Or. Len(AllTrim(SubStr(cHr,3,2))) != 2
		Help( ,, 'HELP',, "Hora inválida.", 1, 0,) //"Hora inválida."
		Return .F.
	EndIf

Return .T.

/*
{Protheus.doc}
GFEVLDDTHR()

Função que realiza a validação de Data e Hora. 

Parâmetros: cDTVld - Data que será validada
cHRVld - Hora que será validada
cDTComp - Data base para validação (opcional)
cHRComp - Hora base para validação (opcional)
cStr - Mensagem para personalização (hora da xxx, data da xxxx)
cStr2 - Mensagem para personalização (hora xxx, data xxx)

Caso os parâmetros opcionais não sejam enviados para a função, a validação ocorrerá com base
na Data e/ou Hora atual. 
É realizada a validação para data e/ou hora inválida, e para data e/ou hora superior a data base.

Obs: Data/hora menores que a data/hora base não são validadas nessa função.		

@author Hercilio Henning Neto	
@since 01/11/2016
@version 1.0
*/
Function GFEVLDDTHR(cHr, cDt, cHrComp, cDtComp, cStr, cStr2)

	Local aRet := {}

	Default cHrComp := SubStr(GFENOW(.T., .F.), 10, 4)
	Default cDtComp := SubStr(GFENOW(.T., .F.), 1, 8)
	Default cStr := "ocorrência"
	Default cStr2 := "atual"

	If Valtype(cDt) == "D"
		cDt := DtoS(cDt)
	EndIf

	If SubStr(cHr, 3, 1) == ":"
		cHr := SubStr(cHr, 1, 2) + SubStr(cHr, 4, 2)
	EndIf

	If !GFEVLDHRO(cHr)
		aRet := {.F., "Hora " + cStr + " inválida."}
		Return aRet
	EndIf
Return {.T., ""}

Function GFEVLDHRO(cHr)

	If At(":", cHr) > 0
		cHr := AllTrim(StrTran(cHr, ":", ""))
	EndIf

	If !(SubStr(cHr,1,2) <= "23" .And. SubStr(cHr,1,2) >= "00" .And. SubStr(cHr,3,2) <= "59" .And. SubStr(cHr,3,2) >= "00") .Or. ;
			Len(AllTrim(cHr)) < 4 .Or. Len(AllTrim(SubStr(cHr,1,2))) != 2 .Or. Len(AllTrim(SubStr(cHr,3,2))) != 2
		Return .F.
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEVINCPFC

Cria o vínculo das pré-faturas na fatura com base nos conhecimentos já vinculados
Retorna um array com as pré-faturas vinculadas

Formato do Array:
[n, 1] Filial da Fatura
[n, 2] Número da Pré-Fatura

@param cFilFat	Filial da Fatura
@param cEmifat	Emissor da Fatura
@param cSerfat	Série da Fatura
@param cNrfat	Número da Fatura
@param dDtemis	Data de emissão da Fatura (em formato data)
#param oGfeLog	Objeto da função de log GFELog (Opcional)

@author Israel A Possoli
@since 18/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEVINCPFC(cFilFat, cEmifat, cSerfat, cNrfat, dDtemis, oGfeLog, lAtuFin)

	Local aRetPrefat := {}
	Local aAreaGW6 := GW6->( GetArea() )
	Local aAreaGW3 := GW3->( GetArea() )
	Local aAreaGW4 := GW4->( GetArea() )
	Local aAreaGW1 := GW1->( GetArea() )
	Local aAreaGWH := GWH->( GetArea() )
	Local aAreaGWF := GWF->( GetArea() )
	Local aAreaGWJ := GWJ->( GetArea() )
	Local cParInt  := SuperGetMv("MV_GFEI15", ,"3")
	Local lExistCamp:= GFXCP12116("GWF","GWF_CDESP") .And. (SuperGetMV("MV_DPSERV", .F., "1") == "1") .And. GFEA065VFIX()

	Default lAtuFin := .F.

	GfeLogAdd(oGfeLog, "- Buscando fatura. Filial: " + cFilFat + ", Emissor:" + cEmifat + ", Série:" + cSerfat + ", Nr: " + cNrfat + ", Dt Emiss:" + DTOS(dDtemis))

	// Busca a fatura passada por parâmetro
	dbSelectArea("GW6")
	dbSetOrder(1)
	If dbSeek(cFilFat + cEmifat + cSerfat + cNrfat + DTOS(dDtemis))

		// Busca os documentos de frete vinculados a fatura
		GfeLogAdd(oGfeLog, "- Buscando documentos de frete vinculados a fatura.")
		dbSelectArea("GW3")
		dbSetOrder(8)
		If !dbSeek(GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DTOS(GW6->GW6_DTEMIS))
			GfeLogAdd(oGfeLog, "** Nenhum documento de frete vinculado a fatura foi encontrado.")
		EndIf
		While !GW3->( EOF() )                     .AND. ;
				GW3->GW3_FILFAT == GW6->GW6_FILIAL .AND. ;
				GW3->GW3_EMIFAT == GW6->GW6_EMIFAT .AND. ;
				GW3->GW3_SERFAT == GW6->GW6_SERFAT .AND. ;
				GW3->GW3_NRFAT  == GW6->GW6_NRFAT  .AND. ;
				GW3->GW3_DTEMFA == GW6->GW6_DTEMIS

			GfeLogAdd(oGfeLog, "- Documento de frete. Filial: " + GW3->GW3_FILIAL + ", Emissor: " + GW3->GW3_EMISDF + ", Esp: " + GW3->GW3_CDESP + ", Série: " + GW3->GW3_SERDF + ", Nr: " + GW3->GW3_NRDF + ", Dt Emis: " + DTOS(GW3->GW3_DTEMIS))

			// Busca os documentos de carga do documento de frete
			GfeLogAdd(oGfeLog, "- Buscando documento de carga do documento de frete.")
			dbSelectArea("GW4")
			dbSetOrder(1)
			If !dbSeek(GW3->GW3_FILIAL + GW3->GW3_EMISDF + GW3->GW3_CDESP + GW3->GW3_SERDF + GW3->GW3_NRDF + DTOS(GW3->GW3_DTEMIS))
				GfeLogAdd(oGfeLog, "** Nenhum documento de carga vinculado ao documento de frete encontrado.")
			EndIf
			While !GW4-> ( EOF() )                    .AND. ;
					GW4->GW4_FILIAL == GW3->GW3_FILIAL .AND. ;
					GW4->GW4_CDESP  == GW3->GW3_CDESP  .AND. ;
					GW4->GW4_EMISDF == GW3->GW3_EMISDF .AND. ;
					GW4->GW4_SERDF  == GW3->GW3_SERDF  .AND. ;
					GW4->GW4_NRDF   == GW3->GW3_NRDF   .AND. ;
					GW4->GW4_DTEMIS == GW3->GW3_DTEMIS

				GfeLogAdd(oGfeLog, "- Documento de Carga. Filial: " + GW4->GW4_FILIAL + ", TpDc: " + GW4->GW4_TPDC + ", Emissor: " + GW4->GW4_EMISDC + ", Série: " + GW4->GW4_SERDC + ", Nr: " + GW4->GW4_NRDC)

				dbSelectArea("GW1")
				dbSetOrder(1)
				If !dbSeek(GW4->GW4_FILIAL + GW4->GW4_TPDC + GW4->GW4_EMISDC + GW4->GW4_SERDC + GW4->GW4_NRDC)
					GfeLogAdd(oGfeLog, "** Documento de Carga não encontrado.")
				EndIF
				While !GW1->( EOF() )                     .AND. ;
						GW1->GW1_FILIAL == GW4->GW4_FILIAL .AND. ;
						GW1->GW1_CDTPDC == GW4->GW4_TPDC   .AND. ;
						GW1->GW1_EMISDC == GW4->GW4_EMISDC .AND. ;
						GW1->GW1_SERDC  == GW4->GW4_SERDC  .AND. ;
						GW1->GW1_NRDC   == GW4->GW4_NRDC

					// Busca os cálculos do documento de carga
					GfeLogAdd(oGfeLog, "- Buscando cálculos do documento de carga.")
					dbSelectArea("GWH")
					dbSetOrder(2)
					If !dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
						GfeLogAdd(oGfeLog, "** Nenhum cálculo encontrado para o documento de carga")
					EndIf
					While !GWH->( EOF() )                     .AND. ;
							GWH->GWH_FILIAL == GW1->GW1_FILIAL .AND. ;
							GWH->GWH_CDTPDC == GW1->GW1_CDTPDC .AND. ;
							GWH->GWH_EMISDC == GW1->GW1_EMISDC .AND. ;
							GWH->GWH_SERDC  == GW1->GW1_SERDC  .AND. ;
							GWH->GWH_NRDC   == GW1->GW1_NRDC

						GfeLogAdd(oGfeLog, "- Cálculo. Filial: " + GWH->GWH_FILIAL + ", Calc: " + GWH->GWH_NRCALC)

						dbSelectArea("GWF")
						dbSetOrder(1)
						If !dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC)
							GfeLogAdd(oGfeLog, "** Cálculo não encontrado.")
						EndIf
						While !GWF->( EOF() )                     .AND. ;
								GWF->GWF_FILIAL == GWH->GWH_FILIAL .AND. ;
								GWF->GWF_NRCALC == GWH->GWH_NRCALC

							// Desconsidera os cálculos onde o tipo de cálculo é diferente do tipo do documento de frete
							If GWF->GWF_TPCALC != GW3->GW3_TPDF .Or. (lExistCamp .And. GWF->(GWF_FILIAL+GWF_CDESP+GWF_EMISDF+GWF_SERDF+GWF_NRDF+DTOS(GWF_DTEMDF)) <> GW3->(GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)))
								GfeLogAdd(oGfeLog, "** Tipo do cálculo difere do tipo de documento de frete. Tp Calc: " + GWF->GWF_TPCALC + ", Tp DF: " + GW3->GW3_TPDF)
								GWF->( dbSkip() )
								Loop
							EndIf

							// Busca as pré-faturas relacionadas ao documento de frete e realiza o vínculo na fatura
							GfeLogAdd(oGfeLog, "- Buscando pré-faturas relacionadas ao documento de frete.")
							dbSelectArea("GWJ")
							dbSetOrder(1)
							If !dbSeek(GWF->GWF_FILPRE + GWF->GWF_NRPREF)
								GfeLogAdd(oGfeLog, "** Cálculo não possui pré-fatura válida vinculada.")
							EndIf
							While !GWJ-> ( EOF() )                    .AND. ;
									GWJ->GWJ_FILIAL == GWF->GWF_FILPRE .AND. ;
									GWJ->GWJ_NRPF   == GWF->GWF_NRPREF

								GfeLogAdd(oGfeLog, "- Pré-Fatura. Filial: " + GWJ->GWJ_FILIAL + ", Nr: " + GWJ->GWJ_NRPF)

								//Se foi chamado pela atualização do financeiro e as pré-faturas são integradas

								If lAtuFin .And. cParInt != "3"

									/* Caso a Pré-fatura possa ser vinculada a fatura,
									porém sua situação está como não enviada para o Financeiro
									Ela é cancelada.*/

									If ((s_GFEPF1 == '1' .AND. GWJ->GWJ_SIT == "3") .OR.;
									(s_GFEPF1 == '2' .AND. (GWJ->GWJ_SIT == "2" .OR. GWJ->GWJ_SIT == "3") )) .AND.;
									GWJ->GWJ_SITFIN == "1" .AND. ;
									(GWJ->GWJ_CDTRP == GW6->GW6_EMIFAT .or.(s_VLCNPJ == "2" .and. SubStr(Posicione("GU3", 1, xFilial("GU3") +GWJ->GWJ_CDTRP, "GU3->GU3_IDFED"), 1, 8) == SubStr(Posicione("GU3", 1, xFilial("GU3") + GW6->GW6_EMIFAT, "GU3->GU3_IDFED"), 1, 8)))
										RecLock("GWJ", .F.)
										GWJ->GWJ_SIT := "4"
										GWJ->GWJ_MOTCAN := "Foi solicitado a atualização da fatura de frete no financeiro e esta pré-fatura não foi atualizada no financeiro."
										GWJ->GWJ_HRCAN := SubStr(Time(),1,5)
										GWJ->GWJ_DTCANC := Date()
										GWJ->GWJ_USUCAN := cUserName
										MsUnlock("GWJ")
									EndIf	

								EndIf

								/* --------------------------------------------------------------------------------
								* Realiza o vínculo da pré-fatura na fatura
								*  - Considera apenas pré-faturas Confirmadas
								*  - Considera apenas pré-fatuas Atualizadas no financeiro (apenas se está parametrizada para integrar)
								*  - Considera apenas pré-faturas onde o transportador é igual ao emissor da fatura
								*  - Desconsidera as pré-faturas vinculadas em outra fatura
								*-------------------------------------------------------------------------------- */
								If ((s_GFEPF1 == '1' .AND. GWJ->GWJ_SIT == "3") .OR.;
								(s_GFEPF1 == '2' .AND. (GWJ->GWJ_SIT == "2" .OR. GWJ->GWJ_SIT == "3") )) .And.;
								(s_GFEI15 == "3" .Or. GWJ->GWJ_SITFIN == "4") .AND. ;
								(GWJ->GWJ_CDTRP == GW6->GW6_EMIFAT .or.(s_VLCNPJ == "2" .and. SubStr(Posicione("GU3", 1, xFilial("GU3") +GWJ->GWJ_CDTRP, "GU3->GU3_IDFED"), 1, 8) == SubStr(Posicione("GU3", 1, xFilial("GU3") + GW6->GW6_EMIFAT, "GU3->GU3_IDFED"), 1, 8)))
									If Empty(GWJ->GWJ_EMIFAT) .AND. Empty(GWJ->GWJ_NRFAT)
										RecLock("GWJ", .F.)
										GWJ->GWJ_FILFAT := GW6->GW6_FILIAL
										GWJ->GWJ_EMIFAT := GW6->GW6_EMIFAT
										GWJ->GWJ_SERFAT := GW6->GW6_SERFAT
										GWJ->GWJ_NRFAT  := GW6->GW6_NRFAT
										GWJ->GWJ_DTEMFA := GW6->GW6_DTEMIS
										MsUnLock("GWJ")

										GfeLogAdd(oGfeLog, "- Pré-Fatura vinculada a fatura!")

										aADD(aRetPrefat, {GWJ->GWJ_FILIAL, GWJ->GWJ_NRPF})
									Else
										GfeLogAdd(oGfeLog, "** Pré-fatura já vinculada a fatura")
									EndIf
								Else
									GfeLogAdd(oGfeLog, "** Pré-fatura inválida: ")
									GfeLogAdd(oGfeLog, "   * Não está confirmada. Situação: " + GWJ->GWJ_SIT)
									GfeLogAdd(oGfeLog, "   * Não está Atualizada no financeiro. Situação: " + GWJ->GWJ_SITFIN)
									GfeLogAdd(oGfeLog, "   * Transportador difere do emissor da fatura. Trp Pré-Fatura: " + GWJ->GWJ_CDTRP + ", Trp Fatura: " + GW6->GW6_EMIFAT)
								EndIf

								GWJ->( dbSkip() )
							EndDo

							GWF->( dbSkip() )
						EndDo

						GWH->( dbSkip() )
					EndDO

					GW1->( dbSkip() )
				EndDo

				GW4-> ( dbSkip() )
			EndDo

			GW3->( dbSkip() )
		EndDo
	Else
		GfeLogAdd(oGfeLog, "** Fatura não encontrada.")
	EndIf

	RestArea(aAreaGW6)
	RestArea(aAreaGW3)
	RestArea(aAreaGW4)
	RestArea(aAreaGW1)
	RestArea(aAreaGWH)
	RestArea(aAreaGWF)
	RestArea(aAreaGWJ)

Return (aRetPrefat)

//-------------------------------------------------------------------
/*/{Protheus.doc} GfeLogAdd

Verifica se o objeto de log (GfeLog) está nulo ou não, se não estiver, adiciona a mensagem de log


@author Israel A Possoli
@since 22/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GfeLogAdd(oGfeLog, cText)
	If oGfeLog != Nil
		oGfeLog:Add(cText, 3)
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFETabPrazo
Realiza a busca na tabela de Prazos e Distâncias e retorna o prazo de entrega em relação
a ocorrência com mais critérios de seleção.

aCriterios	Array contendo os critérios de seleção:
aCriterios[1]	: Remetente
aCriterios[2]	: Destinatário
aCriterios[3]	: Cidade Origem
aCriterios[4]	: Cidade Destino
aCriterios[5]	: Transportador
aCriterios[6]	: Grupo Transportador
aCriterios[7]	: Tipo Operação
aCriterios[8]	: Tipo Veículo
aCriterios[9]	: Modalidade de Transporte
aCriterios[10]	: Classificação de Frete



Retorno Array contendo:
aRet[1]	: Data Prevista
aRet[2]	: Hora Prevista
aRet[3]	: Tabela de Prazos escolhida
aRet[5] : Sucesso da operação (true/false)
aRet[6]	: Mensagem de erro/warning


@author Israel A Possoli
@since 07/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFETabPrazo(aCriterios, dDataRef, cHoraRef)
	Local aRet[8]
	Local cAliasGUN
	Local cQuery
	Local aBuscaOri	 := {}	// Valores da busca de Origem
	Local aBuscaDest := {}	// Valores da busca de Destino
	Local aRegioes	 := {}	// Regiões encontradas com a cidade de Origem/Destino
	Local aFiltros	 := {}	// Filtros (Transportador, Tipo de operação, Tipo de Veículo, etc)
	Local cWOriDest  := ""	// Where de Origem e Destino
	Local cWIdaVolta := ""	// Where de Origem e Destino Ida e Volta
	Local cWFiltros  := ""	// Where de Filtros
	Local cUFOrigem  := ""
	Local cUFDestino := ""
	Local aDataHora			// Retorno da função DtHrPrev
	Local nI
	Local nDataCount
	Local lTabEscolida := .F.
	Private lPEXFA03 := ExistBlock("GFEXFA03")
	Default dDataRef := Date()
	Default cHoraRef := Substr(Time(), 1, 5)

	aRet[1] := ""
	aRet[2] := ""
	aRet[3] := ""
	aRet[4] := ""
	aRet[5] := .F.
	aRet[6] := ""
	aRet[7] := ""
	aRet[8] := ""

	// Busca a UF da cidade Origem
	If !Empty(aCriterios[3])
		cUFOrigem := POSICIONE("GU7",1,xFilial("GU7") + aCriterios[3], "GU7_CDUF")
	EndIf
	// Busca a UF da cidade de Destino
	If !Empty(aCriterios[4])
		cUFDestino := POSICIONE("GU7",1,xFilial("GU7") + aCriterios[4], "GU7_CDUF")
	EndIf

	/***********************************************
	Define a busca de Origem
	************************************************/
	// Remetente
	If !Empty(aCriterios[1])
		aADD(aBuscaOri, "GUN.GUN_CDREM  = '" + aCriterios[1] + "'")
	EndIf
	// Cidade de Origem e Região
	If !Empty(aCriterios[3])
		aADD(aBuscaOri, "GUN.GUN_NRCIOR  = '" + aCriterios[3] + "'")
		aRegioes := BuscaRegiao(aCriterios[3], cUFOrigem, aCriterios[13])
		For nI := 1 To Len(aRegioes)
			aADD(aBuscaOri, "GUN.GUN_NRREOR  = '" + aRegioes[nI] + "'")
		Next
	EndIf


	/***********************************************
	Define a busca de Destino
	************************************************/
	// Destinatário
	If !Empty(aCriterios[2])
		aADD(aBuscaDest, "GUN.GUN_CDDEST  = '" + aCriterios[2] + "'")
	EndIf
	// Cidade de Origem e Região
	If !Empty(aCriterios[4])
		aADD(aBuscaDest, "GUN.GUN_NRCIDS  = '" + aCriterios[4] + "'")
		aRegioes := {}
		aRegioes := BuscaRegiao(aCriterios[4], cUFDestino, aCriterios[14])
		For nI := 1 To Len(aRegioes)
			aADD(aBuscaDest, "GUN.GUN_NRREDS  = '" + aRegioes[nI] + "'")
		Next
	EndIf

	// Validação dos campos de Origem e Destino
	If Len(aBuscaOri) < 1 .OR. Len(aBuscaDest) < 1
		aRet[6] := "Nenhum critério de seleção para Origem ou Destino encontrado."
		Return aRet
	EndIf

	/***********************************************
	Cria o Where da Busca SQL da Origem e Destino
	************************************************/
	cWOriDest += "("
	For nI := 1 To Len(aBuscaOri)
		If (nI > 1)
			cWOriDest += " OR "
		EndIf
		cWOriDest += aBuscaOri[nI]
	Next
	cWOriDest += ") AND ("
	For nI := 1 To Len(aBuscaDest)
		If (nI > 1)
			cWOriDest += " OR "
		EndIf
		cWOriDest += aBuscaDest[nI]
	Next
	cWOriDest += ")"

	/***********************************************
	Cria o Where da Busca SQL da Origem e Destino Ida e Volta
	************************************************/
	cWIdaVolta := cWOriDest
	// Salva os campos de origem em um outro formato
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_CDREM", "%GUN-CDREM%")
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_NRCIOR", "%GUN-NRCIOR%")
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_NRREOR", "%GUN-NRREOR%")

	// Inverte os campos Destinos em campos Origem
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_CDDEST", "GUN_CDREM")
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_NRCIDS", "GUN_NRCIOR")
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_NRREDS", "GUN_NRREOR")

	// Renomeia os valores de Origem salvos em campos Destinos
	cWIdaVolta := StrTran(cWIdaVolta, "%GUN-CDREM%", "GUN_CDDEST")
	cWIdaVolta := StrTran(cWIdaVolta, "%GUN-NRCIOR%", "GUN_NRCIDS")
	cWIdaVolta := StrTran(cWIdaVolta, "%GUN-NRREOR%", "GUN_NRREDS")

	cWIdaVolta := "GUN.GUN_DUPSEN = '1' AND " + cWIdaVolta


	/***********************************************
	Define o critério de busca pelos filtros
	************************************************/
	// Transportador
	If Empty(aCriterios[5])
		aADD(aFiltros, "GUN.GUN_CDTRP = ''")
	Else
		aADD(aFiltros, "(GUN.GUN_CDTRP = '' OR GUN.GUN_CDTRP = '" + aCriterios[5] + "')")
	EndIf
	// Grupo Transportador
	If Empty(aCriterios[6])
		aADD(aFiltros, "GUN.GUN_CDGRP = ''")
	Else
		aADD(aFiltros, "(GUN.GUN_CDGRP = '" + aCriterios[6] + "' OR GUN.GUN_CDGRP = '')")
	EndIf
	// Tipo Operação
	If FwIsInCallStack("MATA410")
		If !Empty(aCriterios[7])
			aADD(aFiltros, "(GUN.GUN_CDTPOP = '" + aCriterios[7] + "' OR GUN.GUN_CDTPOP = '')")
		EndIf
	Else
		If Empty(aCriterios[7])
			aADD(aFiltros, "GUN.GUN_CDTPOP = ''")
		Else
			aADD(aFiltros, "(GUN.GUN_CDTPOP = '" + aCriterios[7] + "' OR GUN.GUN_CDTPOP = '')")
		EndIf
	EndIf
	// Tipo Veículo
	If FwIsInCallStack("MATA410")
		If !Empty(aCriterios[8])
			aADD(aFiltros, "(GUN.GUN_CDTPVC = '" + aCriterios[8] + "' OR GUN.GUN_CDTPVC = '')")
		EndIf
	Else
		If Empty(aCriterios[8])
			aADD(aFiltros, "GUN.GUN_CDTPVC = ''")
		Else
			aADD(aFiltros, "(GUN.GUN_CDTPVC = '" + aCriterios[8] + "' OR GUN.GUN_CDTPVC = '')")
		EndIf
	EndIf
	// Modalidade de Transporte
	If Empty(aCriterios[9])
		aADD(aFiltros, "GUN.GUN_MODAL = '1'")
	Else
		aADD(aFiltros, "(GUN.GUN_MODAL = '" + aCriterios[9] + "' OR GUN.GUN_MODAL = '1')")
	EndIf
	// Classificação de Frete
	If FwIsInCallStack("MATA410")
		If !Empty(aCriterios[10])
			aADD(aFiltros, "(GUN.GUN_CDCLFR = '" + aCriterios[10] + "' OR GUN.GUN_CDCLFR = '')")
		EndIf
	Else
		If Empty(aCriterios[10])
			aADD(aFiltros, "GUN.GUN_CDCLFR = ''")
		Else
			aADD(aFiltros, "(GUN.GUN_CDCLFR = '" + aCriterios[10] + "' OR GUN.GUN_CDCLFR = '')")
		EndIf
	EndIf


	/***********************************************
	Cria o Where da Busca SQL dos Filtros
	************************************************/
	cWFiltros := "("
	For nI := 1 To Len(aFiltros)
		If (nI > 1)
			cWFiltros += " AND "
		EndIf
		cWFiltros += aFiltros[nI]
	Next
	cWFiltros += ")"

	// Execução da Query criada na tabela de Prazos
	cAliasGUN := GetNextAlias()
	cQuery := "SELECT GUN.* FROM " + RetSQLName("GUN") + " GUN WHERE "
	cQuery += "((" + cWOriDest + ") OR (" + cWIdaVolta + ")) AND "
	cQuery += cWFiltros + " AND "
	cQuery += "GUN.GUN_DATDE <= '" + DTOS(Date()) + "' AND GUN.GUN_DATATE >= '" + DTOS(Date()) + "' AND "
	cQuery += "GUN.GUN_TPTAB = '1' AND "
	cQuery += "GUN.D_E_L_E_T_ = ' ' ORDER BY GUN.GUN_PRIOR DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGUN, .F., .T.)

	dbSelectArea((cAliasGUN))
	(cAliasGUN)->( dbGoTop() )

	While !(cAliasGUN)->( Eof() ) .AND. lTabEscolida == .F.
		// É escolhida a primeira tabela ordenada pela prioridade
		// caso seja necessário incluir outras regras de escolha das tabelas,
		// usar esta variável para controlar o fluxo do While
		lTabEscolida := .T.

		If lTabEscolida
			// Dias úteis
			If (cAliasGUN)->GUN_TPPRAZ == "0"
				dbSelectArea("GUW")
				dbSetOrder(1)
				If dbSeek(xFilial("GUW") + DTOS(dDataRef + 1))

					nDataCount := 0
					While(!GUW->(EOF()) .AND. nDataCount < (cAliasGUN)->GUN_PRAZO)
						If GUW->GUW_TPDIA == "1"
							nDataCount++
						EndIf

						If nDataCount >= (cAliasGUN)->GUN_PRAZO
							aRet[1] := GUW->GUW_DATA
						EndIf

						GUW->(dbSkip())
					EndDo
				EndIf

				If Empty(aRet[1])
					aRet[6] += "Não foi possível definir o prazo com base nos dias úteis do calendário de transporte. "
					aRet[1] := dDataRef + (cAliasGUN)->GUN_PRAZO
				EndIf

				aRet[2] := cHoraRef
			EndIf

			// Dias Corridos
			If (cAliasGUN)->GUN_TPPRAZ == "1"
				dDataRef := dDataRef + (cAliasGUN)->GUN_PRAZO
				aRet[1] := dDataRef
				aRet[2] := cHoraRef
			EndIf

			// Quantidade em Horas
			If (cAliasGUN)->GUN_TPPRAZ == "2"
				aDataHora := DtHrPrev(dDataRef, cHoraRef, (cAliasGUN)->GUN_PRAZO)
				aRet[1] := aDataHora[1]
				aRet[2] := aDataHora[2]
			EndIf

			aRet[3] := (cAliasGUN)->GUN_CODTAB
			aRet[7] := (cAliasGUN)->GUN_PRAZO
			aRet[8] := (cAliasGUN)->GUN_TPPRAZ

			// Ponto de Entrada para permitir alterar a data de previsão de entrega
			If lPEXFA03
				aRetPE := ExecBlock("GFEXFA03",.f.,.f.,{(cAliasGUN)->GUN_CODTAB,(cAliasGUN)->GUN_TPPRAZ,(cAliasGUN)->GUN_PRAZO,aRet})
				If ValType(aRetPE) == "A"
					aRet := aRetPE
				EndIf				
			Endif

		EndIf

		(cAliasGUN)->(dbSkip())
	EndDo
	(cAliasGUN)->(dbCloseArea())

	If Empty(aRet[1])
		cErrOrig := ""
		cErrDest := ""

		aRet[6] += "Nenhuma tabela de prazo encontrada. "
		Return(aRet)
	EndIf

	aRet[5] := .T.

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEPrazoTre
Retorna os dados de Origem, Destino e informações complementares do trecho para ser usado na roltina GFETabPrazo

@cFilial	Filial do Documento de Carga
@cCdTpDc	Tipo Documento de Carga
@cEmisDc	Emissor Documento de Carga
@cSerDc		Série Documento de Carga
@cNrDc		Número Documento de Carga
@cSeq		Sequência do Trecho

Retorna um array com os dados:
[1] Remetente
[2] Destinatário
[3] Cidade Origem
[4] Cidade Destino
[5] Transportador
[6]	Grupo Transportador
[7]	Tipo Operação
[8]	Tipo Veículo
[9]	Modalidade de Transporte
[10] Revervado para a Classificação de Frete (Retorna em branco nesta função)
[11] Sucesso
[12] Mensagem de Erro
[13] CEP De
[14] CEP Para

@author Israel A Possoli
@since 08/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEPrazoTre(cFil, cCdTpDc, cEmisDc, cSerDc, cNrDc, cSeq)
	Local nTrechos	:= 0			// Quantidade de trechos
	Local lTrechoLoc := .F.			// Verifica se o trecho foi localizado
	Local nSeq 		:= Val(cSeq)
	Local aAreaGWU 	:= GWU->(getArea())
	Local aAreaGW1 	:= GW1->(getArea())
	Local aAreaGU3 	:= GU3->(getArea())
	Local aRet[14]
	Local lOriDoc := .F.

	aRet[1] := ""
	aRet[2] := ""
	aRet[3] := ""
	aRet[4] := ""
	aRet[5] := ""
	aRet[6] := ""
	aRet[7] := ""
	aRet[8] := ""
	aRet[9] := ""
	aRet[10] := ""
	aRet[11] := .F.
	aRet[12] := ""
	aRet[13] := ""
	aRet[14] := ""

	// Se a conversão para numérico do valor da sequência ocasionar erro, cancela o processo
	If nSeq <= 0
		aRet[12] := "Sequência do trecho inválida: [" + cSeq + "]"
		Return aRet
	EndIf

	GWU->(dbSetOrder(1))
	If GWU->(dbSeek(cFil + cCdTpDc + cEmisDc + cSerDc + cNrDc + cSeq))
		While !GWU->(Eof()) .AND. ;
		GWU->GWU_FILIAL == cFil    .AND. ;
		GWU->GWU_CDTPDC == cCdTpDc .AND. ;
		GWU->GWU_EMISDC == cEmisDc .AND. ;
		GWU->GWU_SERDC  == cSerDc  .AND. ;
		GWU->GWU_NRDC   == cNrDc   .And. ;
		GWU->GWU_SEQ	   == cSeq
			nTrechos++

			lOriDoc := .F.
			// Se possuir mais de um trecho, busca as informações de origem do trecho anterior
			If GFXCP12117("GWU_NRCIDO") == .T. .And. !Empty(GWU->GWU_NRCIDO) 
				aRet[3] := GWU->GWU_NRCIDO
				lOriDoc := .T.
			ElseIf nSeq > 1 .AND. Val(GWU->GWU_SEQ) == nSeq - 1
				aRet[3] := GWU->GWU_NRCIDD
			EndIf

			// Busca informações do trecho atual
			If Val(GWU->GWU_SEQ) == nSeq
				lTrechoLoc := .T.
				aRet[4] := GWU->GWU_NRCIDD
				aRet[5] := GWU->GWU_CDTRP
				aRet[8] := GWU->GWU_CDTPVC
			EndIf

			GWU->(dbSkip())
		EndDo
	Else
		aRet[12] := "Nenhum trecho encontrado. Filial: " + cFil + ", Tipo Doc: " + cCdTpDc + ", Emissor: " + cEmisDc + ", Série: " + cSerDc + ", NrCd: " + cNrDc
		Return aRet
	EndIf

	// Se o trecho não foi encontrado com a sequência informada, limpa a variável de retorno e cancela o processo
	If !lTrechoLoc
		aRet[1] := ""
		aRet[2] := ""
		aRet[3] := ""
		aRet[4] := ""
		aRet[5] := ""
		aRet[12] := "Trecho não encontrado com a sequência: [" + cSeq + "]"
		Return aRet
	EndIf

	// Busca informações do Remetene e Destinatário
	GW1->(dbSetOrder(1))
	GW1->(dbSeek(cFil + cCdTpDc + cEmisDc + cSerDc + cNrDc))

	// Se for o primeiro trecho, grava o Remetente e a cidade origem do Remetente
	If nSeq == 1 
		aRet[1] := GW1->GW1_CDREM
		If lOriDoc == .F.
			aRet[3] := POSICIONE("GU3", 1, xFilial("GU3") + GW1->GW1_CDREM, "GU3_NRCID")
		EndIf
	EndIf

	// Se for o último trecho, grava o Destinatário
	If nSeq == nTrechos
		aRet[2] := GW1->GW1_CDDEST
	EndIf

	// Busca o Grupo de Emitentes
	aRet[6] := POSICIONE("GU3", 1, xFilial("GU3") + aRet[5], "GU3_CDGRGL")

	// Busca o Tipo Modal
	aRet[9] := POSICIONE("GU3", 1, xFilial("GU3") + aRet[5], "GU3_MODAL")

	aRet[11] := .T.

	RestArea(aAreaGWU)
	RestArea(aAreaGW1)
	RestArea(aAreaGU3)
Return(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaRegiao
Retorna as regiões que uma cidade está relacionada.
Desconsidera opção de "Demais Cidades"
Usada na rotina de GFEPrazoTre
Uso Interno

@cNrCidade	Cidade
@cUf		Uf

Retorna um array com o código das regiões encontradas:
[1] Cod Região

@author Israel A Possoli
@since 08/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaRegiao(cNrCidade, cUf, cCEP)
	Local aRet		:= {}
	Local cCepTmp	:= ""
	Local cQuery	:= ''
	Local cGU9Reg := GetNextAlias()
	Default cCEP	:= ""


	cCepTmp := cCep
	/***********************************************
	Verifica nas regiões as cidades de origem/destino
	***********************************************/
	cQuery := " SELECT GU9.GU9_NRREG, GUA.GUA_NRREG, GUA.GUA_NRCID "
	If !Empty(cCepTmp)
		cQuery += " , GUL.GUL_NRREG "
	EndIf
	cQuery += " FROM " + RetSQLName("GU9") + " GU9 "
	cQuery += " LEFT JOIN " + RetSQLName("GUA") + " GUA ON (GUA.D_E_L_E_T_ = ' ' AND GUA.GUA_FILIAL = GU9.GU9_FILIAL AND GUA.GUA_NRREG = GU9.GU9_NRREG AND GUA.GUA_NRCID = '" + cNrCidade + "') "
	If !Empty(cCepTmp)
		cQuery += " LEFT JOIN " + RetSQLName("GUL") + " GUL ON (GUL.D_E_L_E_T_ = ' ' AND GUL.GUL_FILIAL = GU9.GU9_FILIAL AND GUL.GUL_NRREG = GU9.GU9_NRREG AND '" + cCepTmp + "' >= GUL.GUL_CEPINI AND '" + cCepTmp + "' <= GUL.GUL_CEPFIM) "
	EndIf
	cQuery += " WHERE GU9.D_E_L_E_T_ = ' ' "
	cQuery += " AND GU9.GU9_SIT = '1' "
	cQuery += " AND GU9.GU9_DEMCID = '2' "
	//cQuery += " AND GU9.GU9_CDUF = '" + cUf + "'
	If !Empty(cCepTmp)
		cQuery += " AND (GUA.GUA_NRREG IS NOT NULL OR GUL.GUL_NRREG IS NOT NULL) "
	Else
		cQuery += " AND (GUA.GUA_NRREG IS NOT NULL) "
	EndIf

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cGU9Reg, .F., .T.)

	dbSelectArea(cGU9Reg) 
	(cGU9Reg)->( dbGoTop() )
	While !(cGU9Reg)->(Eof())
		aADD(aRet, (cGU9Reg)->GU9_NRREG)
		(cGU9Reg)->( dbSkip() )
	EndDo

	(cGU9Reg)->( dbCloseArea() )
Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc}
Recebe o numero de dias UTEIS de prazo
Retorna a quantidade de dias CORRIDOS a partir de uma data, baseado nos
dias úteis do calendário do GFE.

@nQtdPrazo	 Quantidade de dias de prazo
@dData	 	 Data a partir da qual se deseja verificar a quantidade de dias

Retorna a quantidade de dias
Qtd de dias

@author Lidiomar Fernando dos S. Machado
@since 08/02/2013
@version 1.0
*/
//-------------------------------------------------------------------
Function GFEPrzCorr(nQtdPrazo, dData, lSoma)
	Local nDiaUtil := 0
	Local nDiaCorr := 0
	Default dData	:= Date()
	Default lSoma := .T.

	DbSelectArea("GUW")
	DbSetOrder(1)
	While nDiaUtil < nQtdPrazo
		If dbSeek(xFilial("GUW") + DTOS(dData))
			If GUW->GUW_TPDIA == "1" //Dia Util
				nDiaUtil++
			EndIf
			If lSoma
				dData := dData + 1
			Else
				dData := dData - 1
			EndIf
			nDiaCorr++
		Else
			nDiaCorr := Nil
			Exit  //O dia não está parametrizado no calendário
		EndIf
	EndDo

Return nDiaCorr

	//-------------------------------------------------------------------
	/*/{Protheus.doc} TOTFRTIMP(nCalc)

	Retorna o valor total do frete apenas com os componentes que fazem parte da base de imposto

	@param  nCalc - Número do Cálculo

	@sample
	TOTFRTIMP(nCalc)


	@author Lidiomar Fernando dos S. Machado
	@since 23/07/13
	@version 1.
	/*/


Function TOTFRTIMP( cFilCal , nCalc )
	Local VlTotal := 0
	Local cBaseImp
	Local cNrTab
	Local cNrNeg
	Local cCdEmit
	Local cCdComp


	dbSelectArea("GWF")
	dbSetOrder(1)
	dbSeek(cFilCal + nCalc)

	dbSelectArea("GWI")
	dbSetOrder(1)
	dbSeek(cFilCal + nCalc)

	While !Eof() .And. GWI->GWI_FILIAL == cFilCal .And. GWI->GWI_NRCALC == nCalc
		dbSelectArea("GWG")
		dbSetOrder(1)
		cBaseImp := "1"
		If dbSeek(xFilial("GWG")+GWI->GWI_NRCALC)
			cNrTab := GWG->GWG_NRTAB
			cNrNeg := GWG->GWG_NRNEG
			cCdEmit:= GWG->GWG_CDEMIT
			cCdComp:= GWI->GWI_CDCOMP

			Posicione("GVA",1,xFilial("GUY")+cCdEmit+cNrTab,"GVA_TPTAB")
			If GVA->GVA_TPTAB == "2"
				cNrTab := GVA->GVA_TABVIN
				cCdEmit:= GVA->GVA_EMIVIN
			EndIf

			dbSelectArea("GUY")
			dbSetOrder(1)
			cBaseImp := Posicione("GUY",1,xFilial("GUY")+cCdEmit+cNrTab+cNrNeg+cCdComp,"GUY_BASIMP")
		EndIf

		If GWI->GWI_TOTFRE == "1" .AND. cBaseImp == "1"
			VlTotal := VlTotal + GWI->GWI_VLFRET
		Endif
		dbSelectArea("GWI")
		dbSkip()
	EndDo
	Vltotal += GWF->GWF_VLAJUS

Return VlTotal


//--------------------------------------------------------------------
/*/{Protheus.doc} GFENOW
Retorna uma string contendo a data e hora

@param lShowDate	Mostra data
@param lMs  		Mostra MiliSegundos
@param cSepDtHr	Define o separador entre data e hora. Default '_'
@param cSepHr		Define o separador entre hora, minuto e segundo. Desault '' (para manter legado)
@param cSepMS		Define o separador entre segundo e milissegundo. Default cSepDtHr (para manter legado)
@param lFileFormat 	T: Formato de arquivo: sem pontuação e data reversa. Ex: 20160127_120101. F: Formato de apresentação em tela. Ex: 27/01/2016 - 12:01:01
@author Israel A Possoli
@since 31/10/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFENOW(lShowDate, lShowMs, cSepDtHr, cSepHr, cSepMs, lFileFormat)
	Local nHH, nMM , nSS, nMS := Seconds()
	Local cRet := ""
	Default lShowDate	:= .T.
	Default lShowMs	:= .T.
	Default cSepDtHr	:= '_'
	Default cSepHr	:= ''
	Default cSepMs	:= cSepDtHr //compatibilização para manter a função com mesmo funcionamento de antes da inclusão de cSepHr e cSepMs
	Default lFileFormat := .T.

	nHH := Int(nMS / 3600)
	nMS -= (nHH * 3600)
	nMM := Int(nMS / 60)
	nMS -= (nMM * 60)
	nSS := Int(nMS)
	nMS := (nMs - nSS) * 1000

	If lFileFormat
		If lShowDate
			cRet := Dtos(Date()) + cSepDtHr
		EndIf

		cRet += StrZero(nHH,2) + ;
			cSepHr + ;
			StrZero(nMM,2) + ;
			cSepHr + ;
			StrZero(nSS,2)

		If lShowMs
			cRet += cSepMs + StrZero(nMS,3)
		EndIf

	Else
		If lShowDate
			cRet := DtoC(Date()) + cSepDtHr
		EndIf

		cRet += StrZero(nHH,2) + ":" +;
			StrZero(nMM,2) + ":" + ;
			StrZero(nSS,2)

		If lShowMs
			cRet += ":" + StrZero(nMS,3)
		EndIf

	EndIf


Return (cRet)

	//--------------------------------------------------------------------
	/*/{Protheus.doc} GFEFormIE()
	Formata a inscrição estadual retirando todos os caracteres que não
	sejam números ou letras (no caso de ISENTO)

	@author  Guilherme A. Metzger
	@since   04/02/2016
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function GFEFormIE(cInsc)
	Local nI    := 1
	Local cRet  := ""
	Local cChar := ""

	For nI := 1 To Len(cInsc)
		cChar := SubStr(cInsc,nI,1)
		If IsDigit(cChar) .Or. IsAlpha(cChar)
			cRet += cChar
		EndIf
	Next

Return AllTrim(cRet)

	//--------------------------------------------------------------------
	/*/{Protheus.doc} GFEDelTbData()
	Delete as tabelas temporárias.

	@author  Elynton Fellipe Bazzo
	@since   27/01/2016
	@version 1.0
	/*/
//-------------------------------------------------------------------
Function GFEDelTbData(cAliasTab)

	Local oTempTable
	Local nI := aScan(aAlGFE,{|x|x[1] == cAliasTab})

	If nI > 0
		oTempTable := aAlGFE[nI,2]
		TcSqlExec("DELETE FROM " + oTempTable:GetRealName())
	Else
		dbSelectArea(cAliasTab)
		ZAP
	EndIf

Return

/*/{Protheus.doc} GFEDToJson
//TODO Formata o campo data e hora no formato Json.
@author andre.wisnheski
@since 09/10/2017
@version 1.0
@return ${return}, ${Data formatada no formato Json 2010-06-01T09:45:00}
@param dDate, date, Data a ser formatada
@param cTime, String , Hora a ser formatada
@type function
/*/
Function GFEDToJson(dDate, cTime)
	Local cDate := DtoS(dDate)

	if Empty(cDate)
		cDate := "0000-00-00"
	Else
		cDate := SubStr(cDate,1,4)+"-"+SubStr(cDate,5,2)+"-"+SubStr(cDate,7,2)
	Endif
	if Empty(cTime)
		cTime := "00:00:00"
	Endif

Return cDate + "T" + cTime

//-------------------------------------------------------------------
/*/{Protheus.doc} GFETabPrzQbr
Realiza a busca na tabela de Prazos e Distâncias e retorna o prazo de entrega em relação
a ocorrência com mais critérios de seleção.

aCriterios	Array contendo os critérios de seleção:
aCriterios[1]	: Remetente
aCriterios[2]	: Destinatário
aCriterios[3]	: Cidade Origem
aCriterios[4]	: Cidade Destino
aCriterios[5]	: Transportador
aCriterios[6]	: Grupo Transportador
aCriterios[7]	: Tipo Operação
aCriterios[8]	: Tipo Veículo
aCriterios[9]	: Modalidade de Transporte
aCriterios[10]	: Classificação de Frete

cTpTab := 1-Prazo, 2-Distância, 3-Percentual Quebra de peso, 4-Frete Referência

Retorno Array contendo:
aRet[1]	: Data Prevista calculada com base no prazo
aRet[2]	: Hora Prevista calculada com base no prazo
aRet[3] : Percentual de Quebra de Peso
aRet[4]	: Tabela de Prazos escolhida
aRet[5] : Sucesso da operação (true/false)
aRet[6]	: Mensagem de erro/warning
aRet[7] : Array com retornos do Frete Referência
aRet[8] : Tipo de Prazo
aRet[9] : Prazo informado no cadastro da tabela de prazos

@author Israel A Possoli
@since 07/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFETabPrzQbr(aCriterios, dDataRef, cHoraRef, cTpTab, cTpRef)
	Local aRet[10]
	Local cAliasGUN	 	:= ""
	Local cQuery	 	:= ""
	Local aBuscaOri	 	:= {}	// Valores da busca de Origem
	Local aBuscaDest 	:= {}	// Valores da busca de Destino
	Local aRegioes	 	:= {}	// Regiões encontradas com a cidade de Origem/Destino
	Local aFiltros	 	:= {}	// Filtros (Transportador, Tipo de operação, Tipo de Veículo, etc)
	Local cWOriDest  	:= ""	// Where de Origem e Destino
	Local cWIdaVolta 	:= ""	// Where de Origem e Destino Ida e Volta
	Local cWFiltros  	:= ""	// Where de Filtros
	Local cUFOrigem  	:= ""
	Local cUFDestino 	:= ""
	Local aDataHora[2] 	// Retorno da função DtHrPrev
	Local nI		 	:= 0
	Local nDataCount 	:= 0
	Local lTabEscolida 	:= .F.
	Local aFreteRef 	:= {}

	Default dDataRef := Date()
	Default cHoraRef := Substr(Time(), 1, 5)
	Default cTpRef	 := "1"

	aRet[1] := ""
	aRet[2] := ""
	aRet[3] := 0
	aRet[4] := ""
	aRet[5] := .F.
	aRet[6] := ""
	aRet[10] := 0

	// Busca a UF da cidade Origem
	If !Empty(aCriterios[3])
		cUFOrigem := POSICIONE("GU7",1,xFilial("GU7") + aCriterios[3], "GU7_CDUF")
	EndIf
	// Busca a UF da cidade de Destino
	If !Empty(aCriterios[4])
		cUFDestino := POSICIONE("GU7",1,xFilial("GU7") + aCriterios[4], "GU7_CDUF")
	EndIf

	/***********************************************
	Define a busca de Origem
	************************************************/
	// Remetente
	If !Empty(aCriterios[1])
		aADD(aBuscaOri, "GUN.GUN_CDREM  = '" + aCriterios[1] + "'")
	EndIf
	// Cidade de Origem e Região
	If !Empty(aCriterios[3])
		aADD(aBuscaOri, "GUN.GUN_NRCIOR  = '" + aCriterios[3] + "'")
		If Len(aCriterios) > 12
			aRegioes := BuscaRegiao(aCriterios[3], cUFOrigem, aCriterios[13])
		Else
			aRegioes := BuscaRegiao(aCriterios[3], cUFOrigem, )
		EndIf

		For nI := 1 To Len(aRegioes)
			aADD(aBuscaOri, "GUN.GUN_NRREOR  = '" + aRegioes[nI] + "'")
		Next
	EndIf


	/***********************************************
	Define a busca de Destino
	************************************************/
	// Destinatário
	If !Empty(aCriterios[2])
		aADD(aBuscaDest, "GUN.GUN_CDDEST  = '" + aCriterios[2] + "'")
	EndIf
	// Cidade de Origem e Região
	If !Empty(aCriterios[4])
		aADD(aBuscaDest, "GUN.GUN_NRCIDS  = '" + aCriterios[4] + "'")
		aRegioes := {}
		If Len(aCriterios) > 13
			aRegioes := BuscaRegiao(aCriterios[4], cUFDestino, aCriterios[14])
		Else
			aRegioes := BuscaRegiao(aCriterios[4], cUFDestino, )
		EndIf

		For nI := 1 To Len(aRegioes)
			aADD(aBuscaDest, "GUN.GUN_NRREDS  = '" + aRegioes[nI] + "'")
		Next
	EndIf

	// Validação dos campos de Origem e Destino
	If Len(aBuscaOri) < 1 .OR. Len(aBuscaDest) < 1
		aRet[6] := "Nenhum critério de seleção para Origem ou Destino encontrado."
		Return aRet
	EndIf

	/***********************************************
	Cria o Where da Busca SQL da Origem e Destino
	************************************************/
	cWOriDest += "("
	For nI := 1 To Len(aBuscaOri)
		If (nI > 1)
			cWOriDest += " OR "
		EndIf
		cWOriDest += aBuscaOri[nI]
	Next
	cWOriDest += ") AND ("
	For nI := 1 To Len(aBuscaDest)
		If (nI > 1)
			cWOriDest += " OR "
		EndIf
		cWOriDest += aBuscaDest[nI]
	Next
	cWOriDest += ")"

	/***********************************************
	Cria o Where da Busca SQL da Origem e Destino Ida e Volta
	************************************************/
	cWIdaVolta := cWOriDest
	// Salva os campos de origem em um outro formato
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_CDREM", "%GUN-CDREM%")
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_NRCIOR", "%GUN-NRCIOR%")
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_NRREOR", "%GUN-NRREOR%")

	// Inverte os campos Destinos em campos Origem
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_CDDEST", "GUN_CDREM")
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_NRCIDS", "GUN_NRCIOR")
	cWIdaVolta := StrTran(cWIdaVolta, "GUN_NRREDS", "GUN_NRREOR")

	// Renomeia os valores de Origem salvos em campos Destinos
	cWIdaVolta := StrTran(cWIdaVolta, "%GUN-CDREM%", "GUN_CDDEST")
	cWIdaVolta := StrTran(cWIdaVolta, "%GUN-NRCIOR%", "GUN_NRCIDS")
	cWIdaVolta := StrTran(cWIdaVolta, "%GUN-NRREOR%", "GUN_NRREDS")

	cWIdaVolta := "GUN.GUN_DUPSEN = '1' AND " + cWIdaVolta


	/***********************************************
	Define o critério de busca pelos filtros
	************************************************/
	// Transportador
	If cTpTab != '4'
		If Empty(aCriterios[5])
			aADD(aFiltros, "GUN.GUN_CDTRP = ''")
		Else
			aADD(aFiltros, "(GUN.GUN_CDTRP = '' OR GUN.GUN_CDTRP = '" + aCriterios[5] + "')")
		EndIf
	EndIf
	// Grupo Transportador
	If Empty(aCriterios[6])
		aADD(aFiltros, "GUN.GUN_CDGRP = ''")
	Else
		aADD(aFiltros, "(GUN.GUN_CDGRP = '" + aCriterios[6] + "' OR GUN.GUN_CDGRP = '')")
	EndIf
	// Tipo Operação
	If Empty(aCriterios[7])
		aADD(aFiltros, "GUN.GUN_CDTPOP = ''")
	Else
		aADD(aFiltros, "(GUN.GUN_CDTPOP = '" + aCriterios[7] + "' OR GUN.GUN_CDTPOP = '')")
	EndIf
	// Tipo Veículo
	If Empty(aCriterios[8])
		aADD(aFiltros, "GUN.GUN_CDTPVC = ''")
	Else
		aADD(aFiltros, "(GUN.GUN_CDTPVC = '" + aCriterios[8] + "' OR GUN.GUN_CDTPVC = '')")
	EndIf
	// Modalidade de Transporte
	If !Empty(aCriterios[9])
		aADD(aFiltros, "(GUN.GUN_MODAL = '" + aCriterios[9] + "' OR GUN.GUN_MODAL = '1')")
	EndIf
	// Classificação de Frete
	If Empty(aCriterios[10])
		aADD(aFiltros, "GUN.GUN_CDCLFR = ''")
	Else
		aADD(aFiltros, "(GUN.GUN_CDCLFR = '" + aCriterios[10] + "' OR GUN.GUN_CDCLFR = '')")
	EndIf


	/***********************************************
	Cria o Where da Busca SQL dos Filtros
	************************************************/
	cWFiltros := "("
	For nI := 1 To Len(aFiltros)
		If (nI > 1)
			cWFiltros += " AND "
		EndIf
		cWFiltros += aFiltros[nI]
	Next
	cWFiltros += ")"

	// Execução da Query criada na tabela de Prazos
	cAliasGUN := GetNextAlias()
	cQuery := "SELECT GUN.* FROM " + RetSQLName("GUN") + " GUN WHERE "
	cQuery += "((" + cWOriDest + ") OR (" + cWIdaVolta + ")) AND "
	cQuery += cWFiltros + " AND "
	If cTpTab == '4'
		cQuery += "GUN.GUN_DATDE <= '" + DTOS(dDataRef) + "' AND GUN.GUN_DATATE >= '" + DTOS(dDataRef) + "' AND "
		If GFXCP12123("GUN_TPREF")
			cQuery += "GUN.GUN_TPREF = '" + cTpRef + "' AND "
		EndIf
	Else 
		cQuery += "GUN.GUN_DATDE <= '" + DTOS(Date()) + "' AND GUN.GUN_DATATE >= '" + DTOS(Date()) + "' AND "
	EndIf
	cQuery += "GUN.GUN_TPTAB = '" + cTpTab + "' AND "
	cQuery += "GUN.D_E_L_E_T_ = ' ' ORDER BY GUN.GUN_PRIOR DESC"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGUN, .F., .T.)

	dbSelectArea((cAliasGUN))
	(cAliasGUN)->( dbGoTop() )

	While !(cAliasGUN)->( Eof() ) .AND. lTabEscolida == .F.
		// É escolhida a primeira tabela ordenada pela prioridade
		// caso seja necessário incluir outras regras de escolha das tabelas,
		// usar esta variável para controlar o fluxo do While
		If cTpTab != '4'
			lTabEscolida := .T.
		EndIf

		If lTabEscolida

			If cTpTab == '1'
				aRet[8] := (cAliasGUN)->GUN_TPPRAZ
				aRet[9] := (cAliasGUN)->GUN_PRAZO

				// Dias úteis
				If (cAliasGUN)->GUN_TPPRAZ == "0"
					dbSelectArea("GUW")
					dbSetOrder(1)
					If dbSeek(xFilial("GUW") + DTOS(dDataRef + 1))

						nDataCount := 0
						While(!GUW->(EOF()) .AND. nDataCount < (cAliasGUN)->GUN_PRAZO)
							If GUW->GUW_TPDIA == "1"
								nDataCount++
							EndIf

							If nDataCount >= (cAliasGUN)->GUN_PRAZO
								aRet[1] := GUW->GUW_DATA
							EndIf

							GUW->(dbSkip())
						EndDo
					EndIf

					If Empty(aRet[1])
						aRet[6] += "Não foi possível definir o prazo com base nos dias úteis do calendário de transporte. "
						aRet[1] := dDataRef + (cAliasGUN)->GUN_PRAZO
					EndIf

					aRet[2] := cHoraRef
				EndIf

				// Dias Corridos
				If (cAliasGUN)->GUN_TPPRAZ == "1"
					dDataRef := dDataRef + (cAliasGUN)->GUN_PRAZO
					aRet[1] := dDataRef
					aRet[2] := cHoraRef
				EndIf

				// Quantidade em Horas
				If (cAliasGUN)->GUN_TPPRAZ == "2"
					aDataHora := DtHrPrev(dDataRef, cHoraRef, (cAliasGUN)->GUN_PRAZO)
					aRet[1] := aDataHora[1]
					aRet[2] := aDataHora[2]
				EndIf
			ElseIf cTpTab == '2'
				//Retorna a distância
				aRet[10] := (cAliasGUN)->GUN_DMEST
			ElseIf cTpTab == '3'
				//Retorna o percentual de quebra.
				aRet[3] := (cAliasGUN)->GUN_MAXQBR

			EndIf

			aRet[4] := (cAliasGUN)->GUN_CODTAB
		EndIf
		If cTpTab == '4' .And. !Empty((cAliasGUN)->GUN_CDTRP)
			If GFXCP12123("GUN_UMPESO")
				AADD(aFreteRef,{(cAliasGUN)->GUN_CODTAB,; 
				(cAliasGUN)->GUN_CDTRP,; 
				(cAliasGUN)->GUN_FILIAL,;
				(cAliasGUN)->GUN_FRTPES,;
				(cAliasGUN)->GUN_TPPRAZ,;
				(cAliasGUN)->GUN_PRAZO,;
				(cAliasGUN)->GUN_IMPINC,;
				(cAliasGUN)->GUN_UMPESO})
			Else
				AADD(aFreteRef,{(cAliasGUN)->GUN_CODTAB,; 
				(cAliasGUN)->GUN_CDTRP,; 
				(cAliasGUN)->GUN_FILIAL,;
				(cAliasGUN)->GUN_FRTPES})
			EndIf 
		EndIf
		(cAliasGUN)->(dbSkip())
	EndDo
	(cAliasGUN)->(dbCloseArea())

	aRet[7] := aFreteRef

	If Empty(aRet[7]) .And. cTpTab == '4'
		aRet[6] += "Nenhuma tabela de frete referência foi encontrada. "
		Return(aRet)
	EndIf

	If Empty(aRet[1]) .And. Empty(aRet[3]) .And. cTpTab != '4'
		cErrOrig := ""
		cErrDest := ""
		/*
		If !Empty(aCriterios[1])
		cErrOrig += "Remetente: " + aCriterios[1] + CRLF
		EndIf
		If !Empty(aCriterios[3])
		cErrOrig += "Cidade Origem: " + aCriterios[3] + CRLF
		EndIf
		If !Empty(aCriterios[2])
		cErrDest += "Destinatário: " + aCriterios[2] + CRLF
		EndIf
		If !Empty(aCriterios[4])
		cErrDest += "Cidade Destino: " + aCriterios[4] + CRLF
		EndIf
		*/

	aRet[6] += "Nenhuma tabela encontrada. "
Return(aRet)
EndIf

aRet[5] := .T.

Return aRet
//--------------------------------------------------------------------
/*/{Protheus.doc} GFEGetNrDc
Retorna o Número do Documento de carga formatado

@param cNrDc     Caracter, Número do documento de carga
@param nTamanho  Númerico, Tamanho do número para trocar por zeros.
@author Squad GFE
@since 06/12/2019
@version 1.0
/*/
//--------------------------------------------------------------------
Function GFEGetNrDc(cNrDc, nTamanho)
	Local cRet

	cRet := AllTrim(cNrDc)

	If nTamanho - Len(cRet) > 0
		cRet := Replicate("0", nTamanho - Len(cRet)) + cRet
	EndIf

	cRet := PadR(cRet, TamSX3("GW1_NRDC")[1])
Return cRet
//--------------------------------------------------------------------
/*/{Protheus.doc} GFEGetEmRz
Retorna lista de emitentes com a mesma raiz de CNPJ quando indicado pelo
parâmetro MV_VLCNPJ

@param cEmitente Caracter, Número do documento de carga
@author Squad GFE
@since 15/01/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Function GFEGetEmRz(cEmitente)
	Local cListEmRz := ""
	Local cCnpjRaiz := ""
	Local cAliasGU3 := Nil
	// Verifica se trata raiz do CNPJ
	If s_VLCNPJ == '2'
		// Busca o cnpj do Emitente
		cAliasGU3 := GetNextAlias()
		BeginSql Alias cAliasGU3
			SELECT GU3.GU3_IDFED
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_CDEMIT = %Exp:cEmitente%
			AND GU3.GU3_IDFED <> ' '
			AND GU3.%NotDel%
		EndSql
		If (cAliasGU3)->(!Eof())
			cCnpjRaiz := Substring((cAliasGU3)->GU3_IDFED,1,8)+"%"
		EndIf
		(cAliasGU3)->(dbCloseArea())

		// Busca os emitentes com a mesma raiz de CNPJ
		cAliasGU3 := GetNextAlias()
		BeginSql Alias cAliasGU3
			SELECT GU3.GU3_CDEMIT
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_IDFED LIKE %Exp:cCnpjRaiz%
			AND GU3.%NotDel%
		EndSql
		Do While (cAliasGU3)->(!Eof())
			If Empty(cListEmRz)
				cListEmRz := ((cAliasGU3)->GU3_CDEMIT)
			Else
				cListEmRz += "','"+((cAliasGU3)->GU3_CDEMIT)
			EndIf
			(cAliasGU3)->(dbSkip())
		EndDo
		(cAliasGU3)->(dbCloseArea())
	EndIf
	// Atribui o emitente origem quando não controla raiz ou
	// não possui outros emitentes com a raiz do CPNJ
	If Empty(cCnpjRaiz)
		cListEmRz := cEmitente
	EndIf
Return cListEmRz

/*/{Protheus.doc} GFEFindSx3
	Busca os dados principais do SX3 do campo ou passa por parâmetro as definições desejadas
	@type Function
	@author Squad GFE
	@since 27/03/2020
	@version 1.0
	@param cCampo, caracter, Nome do campo para pesquisa no Sx3
	@param nTamanho, numérico, Tamanho inteiro adribuído no campo de forma manual
	@param nDecimal, numérico, Tamanho dos decimais atribuído no campo de forma manual
	@param cTipo, caracter, Tipo do campo atribuído no campo de forma manual
	@param cPicture, caracter, Mascara do campo atribuído no campo de forma manual
	@return aCampo, array, Retorna array
	@example
	(examples)
	@see (links_or_references)
	/*/
Function GFEFindSx3(cCampo,aColsSx3,cTitulo,nTamanho,nDecimal,cTipo,cPicture)
	Local aTamSX3 := {}
	Local cTitSx3 := ""
	Local cTipSx3 := "C"
	Local cPicSx3 := "@!"
	Local nTamSx3 := 0
	Local nDecSx3 := 0

	Default cCampo   := Nil
	Default nTamanho := Nil
	Default nDecimal := Nil
	Default cTipo    := Nil
	Default cPicture := Nil
	Default cTitulo  := Nil

	If !Empty(cCampo)
		aTamSX3 := TamSx3(cCampo)
		nTamSx3 := aTamSx3[1]
		nDecSx3 := aTamSx3[2]
		cTipSx3 := aTamSx3[3]
		cPicSx3 := X3Picture(cCampo)
		cTitSx3 := FWX3Titulo(cCampo)
	EndIf
	If !Empty(nTamanho)
		nTamSx3 := nTamanho
	EndIf
	If !Empty(nDecimal)
		nDecSx3 := nDecimal
	EndIf
	If !Empty(cTipo)
		cTipSx3 := cTipo
	EndIf
	If !Empty(cPicture)
		cPicSx3 := cPicture
	EndIf
	If !Empty(cTitulo)
		cTitSx3 := cTitulo
	EndIf

	aColsSx3 := {AllTrim(cTitSx3),nTamSx3,nDecSx3,AllTrim(cPicSx3),AllTrim(cTipSx3)}
Return aColsSx3[1]

/*/{Protheus.doc} GFECheckGX4
	Busca se existem dados na tabela GX4 para verificar quais clientes utilizam Patios e Portarias.
	(long_description)
	@type  Function
	@author Squade GFE
	@since 03/05/2021
	@version 1.0
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function GFECheckGX4()
	Local lRet := .T.
	Local cAliasGX4 := GetNextAlias()
	Local lQuestion := .T.
	Local cTit      := "Patios e Portarias x YMS"
	Local cUrlTotvs := "https://produtos.totvs.com/ficha-tecnica/tudo-sobre-o-totvs-logistica-yms/"

	dbSelectArea('GX4')
	dbSetOrder(1)

	BeginSql Alias cAliasGX4
		SELECT 1
		FROM %Table:GX4% GX4
		WHERE GX4.%NotDel%
	EndSql

	If(cAliasGX4)->(Eof())

		cMsg := STR0062 + chr(10) + chr(13) // "A funcionalidade de Patios e Portarias não está mais disponivel."
		cMsg += STR0063 + chr(10) + chr(13) // "Porém, a TOTVS disponibilizou um novo produto para você!"
		cMsg += STR0064 + chr(10) + chr(13) // "Gostaria de saber mais sobre o YMS?"

		If lQuestion .And. GFEMessage(3,cTit,cMsg)
			ShellExecute("open",cUrlTotvs,"","",3)
		EndIF

		lRet := .F.
	EndIF

	(cAliasGX4)->(dbCloseArea())

Return lRet

Function GFESitCtb(nTipo, cFilDoc, cEmiDoc, cSerDoc, cNrDoc, cDtEmis, cSit)
	Local cAliGW6 	:= GetNextAlias()
	Local cQuery	:= ""

	If nTipo = 1
		cQuery := "SELECT * FROM " + RetSQLName("GW6") + " GW6 "
		cQuery += "INNER JOIN " + RetSQLName("GW3") + " GW3 "
		cQuery += "ON GW3.GW3_FILIAL = GW6.GW6_FILIAL "
		cQuery += "AND GW3.GW3_NRFAT = GW6.GW6_NRFAT "
		cQuery += "AND GW3.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN " + RetSQLName("GW4") + " GW4 "
		cQuery += "ON GW4.GW4_FILIAL = GW3.GW3_FILIAL "
		cQuery += "AND GW4.GW4_EMISDF = GW3.GW3_EMISDF "
		cQuery += "AND GW4.GW4_CDESP = GW3.GW3_CDESP "
		cQuery += "AND GW4.GW4_SERDF = GW3.GW3_SERDF "
		cQuery += "AND GW4.GW4_NRDF = GW3.GW3_NRDF "
		cQuery += "AND GW4.GW4_DTEMIS = GW3.GW3_DTEMIS "
		cQuery += "AND GW4.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN " + RetSQLName("GWH") + " GWH "
		cQuery += "ON GWH.GWH_FILIAL = GW4.GW4_FILIAL "
		cQuery += "AND GWH.GWH_NRDC = GW4.GW4_NRDC "
		cQuery += "AND GWH.GWH_CDTPDC = GW4.GW4_TPDC "
		cQuery += "AND GWH.GWH_EMISDC = GW4.GW4_EMISDC "
		cQuery += "AND GWH.GWH_SERDC = GW4.GW4_SERDC "
		cQuery += "AND GWH.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN " + RetSQLName("GWA") + " GWA "
		cQuery += "ON GWA.GWA_FILIAL = GWH.GWH_FILIAL "
		cQuery += "AND GWA.GWA_TPDOC = '1' "
		cQuery += "AND GWA.GWA_NRDOC = GWH.GWH_NRCALC "
		cQuery += "AND GWA.D_E_L_E_T_ = '' "
		cQuery += "WHERE GW6.GW6_FILIAL = '" + cFilDoc + "' "
		cQuery += "AND GW6.GW6_EMIFAT = '" + cEmiDoc + "' "
		cQuery += "AND GW6.GW6_SERFAT = '" + cSerDoc + "' "
		cQuery += "AND GW6.GW6_NRFAT = '" + cNrDoc + "' "
		cQuery += "AND GW6.GW6_DTEMIS = '" + DToS(cDtEmis) + "' "
		cQuery += "AND GW6.D_E_L_E_T_ = ''"

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliGW6, .F., .T.)

		(cAliGW6)->(dbGoTop())

		While !(cAliGW6)->(Eof())
			GWA->(dbSetOrder(1))
			If GWA->(dbSeek((cAliGW6)->GWA_FILIAL +;
					(cAliGW6)->GWA_TPDOC  +;
					(cAliGW6)->GWA_CDESP  +;
					(cAliGW6)->GWA_CDEMIT +;
					(cAliGW6)->GWA_SERIE  +;
					(cAliGW6)->GWA_NRDOC  +;
					(cAliGW6)->GWA_DTEMIS +;
					(cAliGW6)->GWA_CDTRAN +;
					(cAliGW6)->GWA_SEQ))

				RecLock("GWA",.F.)
				GWA->GWA_SITCTB := cSit
				GWA->(MsUnlock())
			EndIf

			(cAliGW6)->(dbSkip())		
		EndDo
		(cAliGW6)->(dbCloseArea())
	EndIf
Return

/*/{Protheus.doc} GFEHabPat
	(long_description)
	@type  Function
	@author joao.schmidt
	@since 15/10/2021
	@version 1.0
	@param cToken, caractere, token para ativação de pátios e portarias
	@return .T.
/*/
Function GFEHabPat(cToken)
	Local cAliasGX4	:= ""

	Default cToken	:= ""

	If cToken == "TOTVSGFE78"
		cAliasGX4 := GetNextAlias()

		BeginSql Alias cAliasGX4
			SELECT 1
			FROM %Table:GX4% GX4
			WHERE GX4.%NotDel%
		EndSql

		If (cAliasGX4)->(Eof())
			RecLock("GX4", .T.)
			GX4->GX4_NRMOV  := "123456789"
			GX4->GX4_REPOBS := "Ativação"
			GX4->(MsUnlock())

			GFEMessage(5, GFEX001, STR0065, STR0066)
		Else
			GFEMessage(5, GFEX002, STR0067, STR0068)
		EndIf

		(cAliasGX4)->(dbCloseArea())
	Else
		GFEMessage(5, GFEX003, STR0069, STR0070)
	EndIf
Return .T.

/*/{Protheus.doc} RecPrzTrec
	Função para alteração da data e hora prevista de entrega para os demais trechos de determinado documento.
	@type  Function
	@author joao.schmidt
	@since 17/11/2021
	@version 1.0
	@param nRecGWU, Numeric, Recno da GWU no banco
	@param dNovDtbase, Date, Data gravada para o trecho que foi passado o recno da GWU
	@param cNovHrBase, Caractere, Hora gravada para o trecho que foi passado o recno da GWU
	@return .T., Logical, Retorno sempre positivo devido ao processo ser todo efetuado dentro dessa função
/*/
Function RecPrzTrec(nRecGWU, dNovDtbase, cNovHrbase)
	Local dDtCalc		:= SToD("")
	Local cHrCalc		:= ""
	Local aRet			:= {}

	Default nRecGWU 	:= 0
	Default dNovDtbase 	:= SToD("")
	Default cNovHrbase	:= ""

	If nRecGWU <> 0 .And. !Empty(dNovDtbase) .And. GFXCP12137("GWU_QTPRAZ")
		GWU->(dbGoTo(nRecGWU))

		dDtCalc := dNovDtbase
		cHrCalc := cNovHrbase

		cAliasGWU := GetNextAlias()

		BeginSQL Alias cAliasGWU
			SELECT GWU.R_E_C_N_O_ RECNOGWU
			FROM %Table:GWU% GWU
			WHERE GWU.GWU_FILIAL = %Exp:GWU->GWU_FILIAL%
			AND GWU.GWU_CDTPDC = %Exp:GWU->GWU_CDTPDC%
			AND GWU.GWU_EMISDC = %Exp:GWU->GWU_EMISDC%
			AND GWU.GWU_SERDC = %Exp:GWU->GWU_SERDC%
			AND GWU.GWU_NRDC = %Exp:GWU->GWU_NRDC%
			AND GWU.GWU_SEQ > %Exp:GWU->GWU_SEQ%
			AND GWU.%NotDel%
			ORDER BY GWU.GWU_SEQ
		EndSQL

		(cAliasGWU)->(dbGoTop())

		Do While ((cAliasGWU)->(!EoF()))
			GWU->(dbGoTo((cAliasGWU)->RECNOGWU))

			aRet := CalcPrzTrc(dDtCalc, cHrCalc, GWU->GWU_QTPRAZ, GWU->GWU_TPPRAZ)

			If Len(aRet) > 0
				RecLock("GWU", .F.)
				GWU->GWU_DTPENT := aRet[1]
				GWU->GWU_HRPENT := aRet[2]
				GWU->(MsUnlock())

				dDtCalc := aRet[1]
				cHrCalc := aRet[2]
			EndIf

			(cAliasGWU)->(dbSkip())
		EndDo

		(cAliasGWU)->(dbCloseArea())
	EndIf

Return .T.

/*/{Protheus.doc} CalcPrzTrc
	Função para calcular o prazo de entrega com base nas informações de data e hora base e configuração do prazo de cada trecho
	@type  Function
	@author joao.schmidt
	@since 18/11/2021
	@version 1.0
	@param dDtCalc, Date, Data base para o cálculo do prazo
	@param cHrCalc, Caractere, hora base para o cálculo do prazo
	@param nQtPrz, Numeric, Quantidade de prazo a ser calculado
	@param cTpPrz, Caractere, Tipo de Prazo a ser calculado (0 = Dias Úteis, 1 = Dias Corridos, 2 = Horas)
	@return aRet[1], Date, Data calculada para o prazo de entrega
	@return aRet[2], Caractere, Hora calculada para o prazo de entrega
	/*/
Static Function CalcPrzTrc(dDtCalc, cHrCalc, nQtPrz, cTpPrz)
	Local aRet 		:= {}
	Local aRetHoras := {}
	Local cAliasGUW := ""
	Local nCntGUW	:= 0

	Default dDtCalc := SToD("")
	Default cHrCalc := ""
	Default nQtPrz	:= 0
	Default cTpPrz	:= "0"

	If !Empty(dDtCalc)
		Do Case
		Case cTpPrz == "0"
			cAliasGUW := GetNextAlias()

			BeginSQL Alias cAliasGUW
					SELECT GUW.GUW_DATA 
					FROM %Table:GUW% GUW
					WHERE GUW.GUW_FILIAL = %xFilial:GUW% 
					AND GUW.GUW_DATA > %Exp:dDtCalc%
					AND GUW.GUW_TPDIA = '1'
					AND GUW.%NotDel%
					ORDER BY GUW.GUW_DATA
			EndSQL

			(cAliasGUW)->(dbGoTop())

			nCntGUW := 1

			Do While ((cAliasGUW)->(!EoF()))
				If nCntGUW == nQtPrz
					aAdd(aRet,SToD((cAliasGUW)->GUW_DATA))
					aAdd(aRet,cHrCalc)

					Exit
				Else
					(cAliasGUW)->(dbSkip())
				EndIf

				nCntGUW++
			EndDo

			(cAliasGUW)->(dbCloseArea())

		Case cTpPrz == "1"
			aAdd(aRet,dDtCalc + nQTPrz)
			aAdd(aRet,cHrCalc)

		Case cTpPrz == "2"
			aRetHoras := DtHrPrev(dDtCalc, cHrCalc, nQtPrz)

			aAdd(aRet,aRetHoras[1])
			aAdd(aRet,aRetHoras[2])
		EndCase
	EndIf
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlValid

Função responsavel por validar se o caminho informado corresponde a um objeto valido no xml
Caso seja, ele grava a informação TEXT do XML no campos informado

@param cXMLDir caminho do arquivo que esta sendo importado
@param oXML     Objeto   - XML
@param cChild   Caracter - Caminho para validação

@version 1.0
/*/
//-------------------------------------------------------------------
Function XmlValid(oTEMP,aNode,cTag,lREALNAME)
	Local nCont     := 0
	Local nFCont    := 0
	Local cReturn   := ""
	Local lContinua := .T.
	Local oXML      := oTEMP

	Default lREALNAME := .F.
	Default lLibre    := .F.

	//Navega dentro do objeto XML usando a variavel aNode como base, retornando o conteudo do TEXT ou o
	nFCont := Len(aNode)
	For nCont := 1 to nFCont
		If ValType( XmlChildEx( oXML,aNode[nCont]  ) ) == 'O'
			oXML :=  XmlChildEx( oXML,aNode[nCont]  )
		Else
			lContinua := .F.
		Endif
		If lContinua
			If nCont == nFCont
				If !lREALNAME
					If Empty(cTag) .And. lLibre .And. IsIncallStack("GFEA061J")
						cReturn := cValToChar(oXMl:TEXT)
					Else
						cReturn := &("oXML:"+cTag+':TEXT')
					EndIf
				Else
					cReturn := &("oXML:REALNAME")
				Endif
			EndIf
		Else
			Exit
		EndIf
	Next nCont
Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} VerifRoundABNT()
	Função responsável por verificar o valor do parâmetro e arredondar de acordo com a norma da ABNT.

	A regra prevê os seguintes arredondamentos:
		- Quando o algarismo a ser conservado for seguido de algarismo inferior a 5, o algarismo
		permanece sem alteração;
		- Quando o algarismo a ser conservado for seguido de algarismo superior a 5, seguido de um
		algarismo diferente de zero, soma-se uma unidade ao algarismo a ser conservado;
		- Quando o algarismo a ser conservado for ímpar, seguido de 5 e posteriormente de zeros, soma-se
		uma unidade ao algarismo a ser conservado;
		- Quando o algarismo a ser conservado for par, seguido de 5 e posteriormente de zeros, o algarismo
		a ser conservado permanece sem alteração;

	@type  Function
	@author philippe.bretas
	@since 14/05/2024
	@param nVlInf  -> Valor Informado para verificação.
	@param nTamRet -> Representa a quantidade de casas após a vírgula.
	@return nVlInf -> Valor Informado, após arredondamento de acordo com a norma ABNT.

@version 1.0
/*/
//-------------------------------------------------------------------
FUNCTION VerifRoundABNT(nVlInf, nTamRet)
	Local cVlInfStr   := ""
	Local cValChar    := ""
	Local cVrfPt      := ""
	Local aArrValChar := {}
	Local nX 		  := 0
	Local nTamArray   := 0
	Default nVlInf    := 0
	Default nTamRet   := 4

	cVlInfStr         := cValtoChar(nVlInf)
	cVrfPt            := Rat(".",cVlInfStr)
	nTamArray         := Len(cVlInfStr) - cVrfPt
	aArrValChar       := Array(nTamArray)

	//Se cVrfPt for ZERO, a variável (nVlInf) é um número inteiro.
	If cVrfPt == 0
		cVrfPt        := Len( cVlInfStr )
		aArrValChar   := {0,0,0,0} 
		nTamArray 	  := 4
	EndIf

	//Cada número após o ponto, será armazenado dentro do Array (aArrValChar)
	For nX := cVrfPt + 1 To Len( cVlInfStr )
		cValChar  := SubString(cVlInfStr,nX, 1)
		cValChar  := Val(cValChar)
		aArrValChar[nX-cVrfPt] := cValChar
	Next nX

	//Se o array for menor que 4, irá completar até atingir o tamanho do ntamRet.
	While nTamArray < nTamRet
		Aadd(aArrValChar, 0)
		nTamArray += 1
	End

	//	 VERIFICAÇÃO DA REGRA ABNT
	If nTamArray == 4 //VERIFICAÇÃO VALOR MONETARIO
		nTamRet := 2
		Do Case
		Case aArrValChar[2] % 2 == 1 .And. aArrValChar[3] == 5 .And. aArrValChar[4] == 0
			nVlInf := Round(nVlInf, nTamRet)
		Case aArrValChar[2] % 2 == 0 .And. aArrValChar[3] == 5 .And. aArrValChar[4] == 0
			nVlInf := NoRound(nVlInf, nTamRet)
		Case aArrValChar[3] >= 5 .And. aArrValChar[4] != 0
			nVlInf := Round(nVlInf, nTamRet)
		Case aArrValChar[3] < 5
			nVlInf := NoRound(nVlInf, nTamRet)
		EndCase
	EndIf
	
	If nTamArray == 8 //VERIFICAÇÃO VALOR DE MEDIDA
		nTamRet := 5
		Do Case
		Case aArrValChar[nTamArray - 3] % 2 == 1 .And. aArrValChar[nTamArray - 2] == 5 .And. aArrValChar[nTamArray- 1] == 0
			nVlInf := Round(nVlInf, nTamRet)
		Case aArrValChar[nTamArray - 3] % 2 == 0 .And. aArrValChar[nTamArray - 2] == 5 .And. aArrValChar[nTamArray- 1] == 0
			nVlInf := NoRound(nVlInf, nTamRet)
		Case aArrValChar[nTamArray - 2] >= 5 .And. aArrValChar[nTamArray- 1] != 0
			nVlInf := Round(nVlInf, nTamRet)
		Case aArrValChar[nTamArray - 1] < 5
			nVlInf := NoRound(nVlInf, nTamRet)
		OtherWise
			nVlInf := Round(nVlInf, nTamRet)
		EndCase
	EndIf
Return nVlInf

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GfePicPes    | Autor ³  				    ³ Data ³14/01/2025³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a picture do CGC ou CPF                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := GfePicPes(cTipPes)                            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTipPes - F-Fisica/J-Juridica                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function GfePicPes(cTipPes)
	Local cPict := ""
	If cTipPes == "F"
		cPict := "@R 999.999.999-99"
	Else
		cPict := "@R! NN.NNN.NNN/NNNN-99"
	EndIf
	cPict := cPict + "%C"
Return cPict

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpostoList()
	Função responsável por retornar um objeto com os dados de impostos
	contidos no XML recebido por parâmetro.

	@type  Function
	@author jefferson.luiz
	@since 19/03/2025
	@param cCteXML  -> string com o xml do cte.
	@return oImpRet -> objetocontendo os impostos que vieram no xml recebido por parametro.

@version 1.0
/*/
//-------------------------------------------------------------------
Function ImpostosList(cCteXML)
	Local aArea      := FWGetArea()
    Local cAviso     := ""
    Local cErro      := ""
	Local oCteXml    := Nil
	Local oRet       := Nil

	If !Empty(cCteXML)
		oCteXml := XmlParser(cCteXML, "_", @cAviso, @cErro)

		//Se houve alguma falha
		If Empty(cErro)
			If AttIsMemberOf(oCteXml:_cteProc:_CTe:_infCte, "_imp")
				oRet := oCteXml:_cteProc:_CTe:_infCte:_imp
			EndIf
		EndIf
	EndIf

	FWRestArea(aArea)
Return oRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpostoList()
	Função responsável por retornar um array com os impostos contidos
	no XML recebido por parâmetro.

	@type  Function
	@author jefferson.luiz
	@since 19/03/2025
	@param cXML  -> string com o xml do cte.
	@return aImp -> array contendo dados basicos dos impostos que vieram
					no xml recebido por parametro.

@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEImpXML(cXML)
    Local oXml
    Local nI        := 0
    Local nZ        := 0
    Local nBase     := 0
    Local nAliq     := 0
    Local nValor    := 0
    Local cCST      := ""
    Local cClassTrib:= ""
    Local nCntImp   := 0
    Local lLoop     := .T.
    Local lInImp    := .F.
    Local aImp      := {}

    oXML := TXmlManager():New()
    If !oXML:Parse(cXML)
        MsgInfo("Falha na leitura do XML - Error: " + oXML:Error())
        aadd(aImp, {'-', '-', 0, 0, 0})
	Else 
		While lLoop
			If Upper(oXML:CNAME) == "IMP"
				lInImp := .T.
				nCntImp := oXML:DOMChildCount()
				
				If oXML:DOMHasChildNode()
					oXML:DOMChildNode()
					Loop
				EndIf
			EndIf

			If lInImp
				cCST   	   := ""
				cClassTrib := ""
				nBase  	   := 0
				nAliq      := 0
				nValor     := 0

				cCurrentTag := Upper(oXML:CNAME)
				If cCurrentTag $ "ICMS;ISS"
					If oXML:DOMHasChildNode()   // Verifica se existe um nó filho. Se estamos no nó ICMS, verifica se existe o ICMS00 por exemplo
						oXML:DOMChildNode()     // Força a passagem para o primeiro nó filho do nó atual. Por exemplo ICMS00
					EndIf

					aChildren := oXML:DOMGetChildArray() // Obtém todos os tipos deste imposto (ICMS00, ICMS20, etc)
					For nI := 1 To Len(aChildren)
						cChildName := Upper(Alltrim(aChildren[nI][1]))
						cChildValue := aChildren[nI][2]
						
						Do Case
							Case cChildName == "CST"
								cCST := cChildValue
							Case cChildName == "VBC"
								nBase := Val(cChildValue)
							Case cChildName $ "PICMS;PISS"
								nAliq := Val(cChildValue)
							Case cChildName $ "VICMS;VISS"
								nValor := Val(cChildValue)
						EndCase
					Next

					If !Empty(cCST) .and. nBase > 0 .and. nAliq > 0 .and. nValor > 0
						aAdd(aImp, {cCurrentTag, cCST, nBase, nAliq, nValor})
					EndIf

				ElseIf cCurrentTag == "IBSCBS" .Or. "IBS" $ cCurrentTag .Or. "CBS" $ cCurrentTag
					If oXML:DOMHasChildNode()   // Verifica se existe um nó filho. Se estamos no nó ICMS, verifica se existe o ICMS00 por exemplo
						
						aChildren := oXML:DOMGetChildArray() // Obtém todos os tipos deste imposto (ICMS00, ICMS20, etc)
						For nI := 1 To Len(aChildren)
							cChildName := Upper(Alltrim(aChildren[nI][1]))
							cChildValue := aChildren[nI][2]

							If cChildName == "CST"
								cCST := cChildValue
							ElseIf cChildName == "CCLASSTRIB"
								cClassTrib := Alltrim(cChildValue)
							ElseIf cChildName $ "GIBSCBS"
								oXML:DOMChildNode()

								While Upper(oXML:CNAME) != cChildName
									oXML:DOMNextNode()
								EndDo

								If oXML:DOMHasChildNode()
									aGIBSCBS := oXML:DOMGetChildArray()
									oXML:DOMChildNode()
									For nZ := 1 To Len(aGIBSCBS)
										nAliq     := 0
										nValor    := 0
										cAuxName  := Upper(Alltrim(aGIBSCBS[nZ][1]))
										cAuxValue := aGIBSCBS[nZ][2]

										While Upper(oXML:CNAME) != cAuxName
											oXML:DOMNextNode()
										EndDo

										If cAuxName == "VBC"
											nBase := Val(cAuxValue)
										ElseIf cAuxName $ "GIBSUF;GIBSMUN;GCBS"
											If oXML:DOMHasChildNode()
												nAliq  := Val( oXML:DOMGetChildArray()[1][2] )
												nValor := Val( oXML:DOMGetChildArray()[2][2] )
											EndIf

											If !Empty(cCST) .And. nBase > 0 .and. nAliq > 0 .and. nValor > 0
												aAdd(aImp, {SubStr(cAuxName,2,Len(cAuxName)), cCST, nBase, nAliq, nValor})
											EndIf
										EndIf
									Next
								EndIf

							EndIf
						Next
					EndIf
				EndIf
			EndIf

			If Upper(oXML:CNAME) != "IMP"
				If oXML:DOMHasChildNode()
					oXML:DOMChildNode()
				ElseIf oXML:DOMHasNextNode()
					oXML:DOMNextNode()
				Else
					If oXML:DOMParentNode()
						While !oXML:DOMNextNode()
							If !oXML:DOMParentNode() .And. !oXML:DOMNextNode()
								If Empty(aImp)
									aadd(aImp, {'-', '-', 0, 0, 0})
								EndIf
								Return aImp
							EndIf
						EndDo
						Loop
					EndIf
				EndIf
			EndIf
		EndDo
	EndIf

Return aImp
