#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
/* Funções da contabilização da Pré-Fatura e Fatura
	GWK
	GW7
*/


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEACTBPRE

Função que busca os movimentos contabeis dos cálculos para serem criados os movimentos da pré-fatura

@Param -> cFilPre - Filial da Pré-fatura
@Param -> cNrPref - Número da Pré-fatura

@author Jorge Matos Valcanaia
@since 01/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEACTBPRE(cFilPre, cNrPref)
	Local cTrans
	Local aArea       := GetArea()
	Local aAreaGWJ    := GWJ->(GetArea())
	Local nSeq        := 0
	Local aRetGWK
	Local aRet[2]
	Private GFELogD   := GFELog():New("Contab_PreFatura_" + Trim(cValToChar(cNrPref)), "LOG DE CONTABILIZAÇÃO DA PRÉ-FATURA", SuperGetMV('MV_GFEEDIL',,'1') )
	
	aRet[1] := .T.
	aRet[2] := ""

	GFELogD:Add("Filial....: " + cValToChar(cFilPre))
	GFELogD:Add("Pré Fatura: " + cValToChar(cNrPref))

	// Verifica se a Pré-Fatura existe e se a situação está como confirmada
	dbSelectArea("GWJ")
	GWJ->( dbSetOrder(1) )
	If GWJ->( dbSeek(cFilPre + cNrPref) )
		If GWJ->GWJ_SIT != "3"
			aRet[1] := .F.
			aRet[2] := "Situação da pré-fatura diferente de Confirmada."
			
			GFELogD:Add("Situação da pré-fatura diferente de Confirmada." + Space(1) + "CANCELANDO OPERAÇÃO")
			Return(aRet)
		EndIf
	Else
		aRet[1] := .F.
		aRet[2] := "Pré-fatura não encontrada."
	
		GFELogD:Add("Pré-fatura não encontrada." + Space(1) + "CANCELANDO OPERAÇÃO")
		Return(aRet)
	EndIf

	GFELogD:Add("Processando cálculos relacionado a pré-fatura:")
	GFELogD:Add("---------------------------------------------")
	GFELogD:Add("")

	dbSelectArea("GWK")
	GWK->(dbSetOrder(1))
	
	dbSelectArea("GWF")
	GWF->( dbSetOrder(3) )
	GWF->( dbSeek(cFilPre + cNrPref ) )
	If GWK->(dbSeek(cFilPre + cNrPref))			
		GFELogD:Add(Space(3) + "Eliminando Rateio da Pré-fatura : " + cNrPref )
		While !GWK->(Eof()) .And. cFilPre + cNrPref == GWK->GWK_FILIAL + GWK->GWK_NRPF
				RecLock("GWK",.F.)
				GWK->(dbDelete())
				GWK->(msUnlock())
				GWK->(dbSkip())
		EndDo
	EndIf	
	
	
	While !GWF->( Eof() ) .AND. GWF->GWF_FILPRE == cFilPre .And. GWF->GWF_NRPREF == cNrPref
		GFELogD:Add("Cálculo: " + cValToChar(GWF->GWF_NRCALC))

		GFELogD:Add(Space(3) + "Rateios do cálculo:")
		dbSelectArea("GWM")
		GWM->( dbSetOrder(1) )
		If GWM->( dbSeek( GWF->GWF_FILIAL + "1" + Space(5) + GWF->GWF_TRANSP + Space(5) + GWF->GWF_NRCALC ) )
			
			GFELogD:Add(Space(3) + "> Rateio RecNo: " + cValToChar(GWM->(RecNo())) )
			dbSelectArea("GWA")
			GWA->( dbSetOrder(1) )
			GWA->( dbSeek(GWM->GWM_FILIAL + GWM->GWM_TPDOC + GWM->GWM_CDESP + GWM->GWM_CDTRP + GWM->GWM_SERDOC + GWM->GWM_NRDOC + DTOS(GWM->GWM_DTEMIS) ) )

			GFELogD:Add(Space(3) + "Criando movimento contábil da pré-fatura:")
			While !GWA->( Eof() ) .And. ;
			    GWA->GWA_FILIAL == GWM->GWM_FILIAL .And. GWA->GWA_TPDOC == GWM->GWM_TPDOC .And. GWA->GWA_CDESP == GWM->GWM_CDESP;
				.And. GWA->GWA_CDEMIT == GWM->GWM_CDTRP .And. GWA->GWA_SERIE == GWM->GWM_SERDOC .And. GWA->GWA_NRDOC == GWM->GWM_NRDOC;
				.And. GWA->GWA_DTEMIS == GWM->GWM_DTEMIS

				Do Case
					Case GWA->GWA_CDTRAN == PadR("300",10)
						cTrans := "1 "
					Case GWA->GWA_CDTRAN == PadR("301",10)
						cTrans := "2 "
					Case GWA->GWA_CDTRAN == PadR("302",10)
						cTrans := "3 "
					Case GWA->GWA_CDTRAN == PadR("303",10)
						cTrans := "4 "
				EndCase

				//Grava Debito
				aRetGWK := GFEAGWK(cFilPre, cNrPref, GWA->GWA_CTADEB, GWA->GWA_CCDEB, GWA->GWA_VLMOV, "1", cTrans, @nSeq, GWA->GWA_UNINEG)

				GFELogD:Add("")

				GWA->( dbSkip() )
			EndDo

		Else
			GFELogD:Add(Space(3) + "Nenhum Rateio encontrado")
		EndIf

		GWF->( dbSkip() )
	EndDo

	RestArea(aArea)
	RestArea(aAreaGWJ)
	
	GFELogD:EndLog()
Return(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEAGWK

Grava os dados na GWK

@Param -> cFil    - Filial
@Param -> cNrPref - Número Pré-fatura
@Param -> cCtaCtb - Conta Contábil
@Param -> cCCusto - Centro de Custo
@Param -> nVlMov  - Valor Movimento
@Param -> cLanCto - Lançamento Contábil
@Param -> cTrans  - Transição

@author Jorge Matos Valcanaia
@since 01/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEAGWK(cFil, cNrPref, cCtaCtb, cCCusto, nVlMov, cLanCto, cTrans, nSeq, cUniNeg)
	Local aRet[2]
	Local aArea := GWA->(GetArea())
	
	aRet[1] := .T.
	aRet[2] := ""

	If cLanCto == "1"
		GFELogD:Add(Space(6) + "> " + "Tipo Lançamento: " + "DÉBITO")
	ElseIf cLanCto == "2"
		GFELogD:Add(Space(6) + "> " + "Tipo Lançamento: " + "CRÉDITO")
	Else
		GFELogD:Add(Space(6) + "> " + "Tipo Lançamento: " + "INVÁLIDO (" + cValToChar(cLanCto) + ")")
	EndIf

	GFELogD:Add(Space(6) + "> " + "Filial.........: " + cValToChar(cFil))
	GFELogD:Add(Space(6) + "> " + "Pré Fatura.....: " + cValToChar(cNrPref))
	GFELogD:Add(Space(6) + "> " + "Conta Contábil.: " + cValToChar(cCtaCtb))
	GFELogD:Add(Space(6) + "> " + "Centro Custo...: " + cValToChar(cCCusto))
	GFELogD:Add(Space(6) + "> " + "Transacao......: " + cValToChar(cTrans))
	GFELogD:Add(Space(6) + "> " + "Valor Movimento: " + cValToChar(nVlMov))

	If Empty(cCtaCtb)
		aRet[1] := .F.
		aRet[2] := "Conta contábil em branco."	
		
		GFELogD:Add(Space(6) + "Conta contábil em branco." + Space(1) + "CANCELANDO OPERAÇÃO")
		Return(aRet)
	EndIf

	dbSelectArea("GWK")
	GWK->( dbSetOrder(2) )
	If GWK->( dbSeek(cFil + cNrPref + cCtaCtb + cCCusto + cLanCto + cTrans + cUniNeg) )
		GFELogD:Add(Space(6) + "Atualizando valor em movimento já criado")
		GFELogD:Add(Space(6) + "> Valor Atual.....: " + cValToChar(GWK->GWK_VLMOV))

		RecLock("GWK",.F.)
			GWK->GWK_VLMOV += nVlMov
		MsUnLock("GWK")

		GFELogD:Add(Space(6) + "> Valor Atualizado: " + cValToChar(GWK->GWK_VLMOV))
	Else
		GFELogD:Add(Space(6) + "Criando novo movimento")
		GFELogD:Add(Space(6) + " > Valor: " + cValToChar(nVlMov))

		RecLock("GWK",.T.)
			GWK->GWK_FILIAL := cFil
			GWK->GWK_NRPF   := cNrPref
			GWK->GWK_SEQ    := StrZero(++nSeq, 5)
			GWK->GWK_CTACTB := cCtaCtb
			GWK->GWK_CCUSTO := cCCusto
			GWK->GWK_VLMOV  := nVlMov
			GWK->GWK_LANCTO := cLanCto
			GWK->GWK_TRANS  := cTrans
			If !Empty(cUniNeg) //Alteração para ser compatível com e sem o update 41
				GWK->GWK_UNINEG := cUniNeg
			EndIf
		MsUnLock("GWK")

	Endif

	RestArea(aArea)
Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GFECTBFATC()
Geração da Contabilização da fatura, Criação dos movimentos

@author Israel Alcantara Possoli
@since 29/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFECTBFATC(cFilFat, cEmiFat, cSerFat, cNrFat, dDtEmis)
	GFECTBFAT(cFilFat, cEmiFat, cSerFat, cNrFat, dDtEmis, "C")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFECTBFATD()
Geração da Contabilização da fatura, Eliminação dos movimentos

@author Israel Alcantara Possoli
@since 29/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFECTBFATD(cFilFat, cEmiFat, cSerFat, cNrFat, dDtEmis)
	GFECTBFAT(cFilFat, cEmiFat, cSerFat, cNrFat, dDtEmis, "D")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA70AGW7()
Geração da Contabilização da fatura

@author Israel Alcantara Possoli
@since 24/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFECTBFAT(cFilFat, cEmiFat, cSerFat, cNrFat, dDtEmis, cOperacao)

	Local cTrans // Transação
	Local lIntDocF    := SuperGetMv('MV_DSCTB',, '1') == "2" .And. SuperGetMv('MV_ERPGFE',, '1') == "1" 
	Local aAreaGW6    := GW6->( GetArea() )
	Local aAreaGW3    := GW3->( GetArea() )
	Local aAreaGWM    := GWM->( GetArea() )
	Local aAreaGWA    := GWA->( GetArea() )
	Local nSeq        := 0
	
	Private LogCtbFat
	Default cOperacao := "C"

	LogCtbFat := GFELog():New("Contabilizacao_Fatura", "Contabilização da Fatura", If(cOperacao == "C", "2", "1"))

	LogCtbFat:Add("Filial.....: " + cValToChar(cFilFat))
	LogCtbFat:Add("Emitente...: " + cValToChar(cEmiFat))
	LogCtbFat:Add("Série......: " + cValToChar(cSerFat))
	LogCtbFat:Add("Nr. Fatura.: " + cValToChar(cNrFat))
	LogCtbFat:Add("Data Emiss.: " + DToC(dDtEmis))
	LogCtbFat:NewLine()

	// Busca a fatura
	dbSelectArea("GW6")
	GW6->( dbSetOrder(1) )
	If GW6->( dbSeek( cFilFat + cEmiFat + cSerFat + cNrFat + DToS(dDtEmis)) ) .Or. GW6->( dbSeek( xFilial("GW6") + cEmiFat + cSerFat + cNrFat) )

		If cOperacao == "D"
			dbSelectArea("GW7")
			GW7->( dbSetOrder(2) )
			GW7->( dbSeek(cFilFat + cEmiFat + cSerFat + cNrFat + DToS(dDtEmis)) )
			While !GW7->( Eof() ) .And. GW7->GW7_FILIAL == cFilFat .And. GW7->GW7_EMIFAT == cEmiFat .And. GW7->GW7_SERFAT == cSerFat .And. ;
				  GW7->GW7_NRFAT == cNrFat .And. GW7->GW7_DTEMIS == dDtEmis

				RecLock("GW7", .F. )
					dbDelete()
				MsUnLock("GW7")

				GW7->( dbSkip() )
			EndDo

		ElseIf cOperacao == "C"
			LogCtbFat:Add("Buscando Documentos de Frete da Fatura")

			// Busca todos os Documento de Frete relacionados a fatura
			dbSelectArea("GW3")
			GW3->( dbSetOrder(8) )
			If GW3->( dbSeek( GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + DToS(GW6->GW6_DTEMIS) ) )

				While !GW3->( Eof() ) .AND. ;
					   GW3->GW3_FILFAT == GW6->GW6_FILIAL .AND. ;
					   GW3->GW3_EMIFAT == GW6->GW6_EMIFAT .AND. ;
					   GW3->GW3_SERFAT == GW6->GW6_SERFAT .AND. ;
					   GW3->GW3_NRFAT  == GW6->GW6_NRFAT  .AND. ;
					   DTOS(GW3->GW3_DTEMFA) == DTOS(GW6->GW6_DTEMIS)

					LogCtbFat:Add("> Filial: " + GW3->GW3_FILIAL + ", Série: " + GW3->GW3_SERDF + ", Número: " + AllTrim(GW3->GW3_NRDF) + ", Espécie: " + AllTrim(GW3->GW3_CDESP) + ", Emissor: " + AllTrim(GW3->GW3_EMISDF) + ", Data Emissão: " + cValToChar(GW3->GW3_DTEMIS))
					dbSelectArea("GWA")
					GWA->( dbSetOrder(2) )
					If GWA->( dbSeek(GW3->GW3_FILIAL + "2" + GW3->GW3_CDESP + GW3->GW3_EMISDF + GW3->GW3_SERDF + GW3->GW3_NRDF + DTOS(GW3->GW3_DTEMIS)) )

						LogCtbFat:Add(" - Movimentos contábeis:")
						While !GWA->( Eof() ) .And. ;
							   GW3->GW3_FILIAL == GWA->GWA_FILIAL .AND. ;
							   GWA->GWA_CDESP  == GW3->GW3_CDESP  .AND. ;
							   GWA->GWA_CDEMIT == GW3->GW3_EMISDF .AND. ;
							   GWA->GWA_SERIE  == GW3->GW3_SERDF  .AND. ;
							   GWA->GWA_NRDOC  == GW3->GW3_NRDF   .AND. ;
							   GWA->GWA_DTEMIS == GW3->GW3_DTEMIS .AND. ;
							   GWA->GWA_TPDOC  == "2"

							LogCtbFat:Add("> Seq: " + AllTrim(GWA->GWA_SEQ) + ", Transação: " + AllTrim(GWA->GWA_CDTRAN) + ", Conta Deb: " + AllTrim(GWA->GWA_CTADEB) + ", Conta Cred: " + AllTrim(GWA->GWA_CCDEB) + ", Valor: " + cValToChar(GWA->GWA_VLMOV), 1)

							Do Case
								Case GWA->GWA_CDTRAN == PadR("310", 10)
									cTrans := "1"
								Case GWA->GWA_CDTRAN == PadR("311", 10)
									cTrans := "2"
								Case GWA->GWA_CDTRAN == PadR("312", 10)
									cTrans := "3"
								Case GWA->GWA_CDTRAN == PadR("313", 10)
									cTrans := "4"
							EndCase

							LogCtbFat:Add("Contabilizando:", 1)
							
							If !lIntDocF .Or. GW3->GW3_ACINT != "1"
								GFEAGRVGW7(cFilFat, cEmiFat, cSerFat, cNrFat, dDtEmis, GWA->GWA_CTADEB, GWA->GWA_CCDEB, GWA->GWA_VLMOV, "1", cTrans, @nSeq, GWA->GWA_UNINEG)
							Else // Processo para integrar o Documento de Frete com o Fiscal
								dbSelectArea('GUS')
								GUS->(dbSetOrder(1))//GUS_FILIAL+GUS_FILCTB
								GUS->(dbSeek(xFilial('GUS')+GWA->GWA_FILIAL))
							
								GFEAGRVGW7(cFilFat, cEmiFat, cSerFat, cNrFat, dDtEmis, GUS->GUS_CTFRET, GUS->GUS_CCFRET, GWA->GWA_VLMOV, "1", cTrans, @nSeq, GWA->GWA_UNINEG)
							EndIf
							LogCtbFat:NewLine()

							GWA->( dbSkip() )
						EndDo
					Else
						LogCtbFat:Add("** Nenhum movimento contábil encontrado para o documento de frete.", 1)
					EndIf

					GW3->( dbSkip() )

					If !GW3->( Eof() )
						LogCtbFat:Add(Replicate("-", 30))
					EndIf
				EndDo
			Else
				LogCtbFat:Add("** Não foi encontrado nenhum Documento de Frete para esta fatura.")
			EndIf
		EndIf
	Else
		LogCtbFat:Add("** Fatura não encontrada.")
	Endif

	LogCtbFat:EndLog()

	RestArea( aAreaGWA )
	RestArea( aAreaGWM )
	RestArea( aAreaGW3 )
	RestArea( aAreaGW6 )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEAGRVGW7()
Função para gravar o rateio contabil da fatura de frete

@Param 		cFil      - Filial que será criado o rateio
@Param 		cEmisso   - Emissor que será criado o rateio
@Param 		cSerie    - Serie que será criado o rateio
@Param 		cNrFatura - Número da fatura do rateio
@Param 		dDtEmiss  - Data de Emissão do rateio
@Param 		cCtaCtb   - Conta Contabil para a criação do rateio
@Param 		cCCusto   - Centro de Custo do rateio
@Param 		nVlMov    - Valor do Movimento do rateio
@Param 		cLance    - Se o movimento sera de debito ou credito
@Param 		cTpTrans  - Tipo de transação
@Param		cOperacao	Operação C=Create, D=Delete

@author Jorge Matos Valcanaia
@since 03/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEAGRVGW7(cFil, cEmisso, cSerie, cNrFatura, dDtEmiss, cCtaCtb, cCCusto, nVlMov, cLance, cTpTrans, nSeq, cUniNeg)

	Local aAreaGW7 := GW7->( GetArea() )

		LogCtbFat:Add("> Conta Contábil.: " + AllTrim(cCtaCtb), 2)
		LogCtbFat:Add("> Centro de Custo: " + AllTrim(cCCusto), 2)
		LogCtbFat:Add("> Valor..........: " + AllTrim(cValToChar(nVlMov)),  2)

	If Empty(cCtaCtb) .OR. nVlMov <= 0
		LogCtbFat:Add("** Conta contábil ou valor zerado. Cancelando operação.", 2)
		Return .F.
	EndIf

	dbSelectArea("GW7")
	GW7->( dbSetOrder(2) )
	If GW7->( dbSeek(xFilial("GW7") + cEmisso + cSerie + cNrFatura + DTOS(dDtEmiss) + cCtaCtb + cCCusto + cLance + cTpTrans + cUniNeg) )
		RecLock("GW7",.F.)
			GW7->GW7_VLMOV += nVlMov
		MsUnLock("GW7")

		LogCtbFat:Add("# Movimento Atualizado. Novo Valor: " + cValToChar(GW7->GW7_VLMOV), 2)
	Else

		RecLock("GW7", .T.)
			GW7->GW7_FILIAL	:= cFil				  //FILIAL
			GW7->GW7_EMIFAT	:= cEmisso			  //Emissor
			GW7->GW7_SERFAT	:= cSerie 			  //Serie
			GW7->GW7_NRFAT	:= cNrFatura		  //Nr Fatura
			GW7->GW7_DTEMIS	:= dDtEmiss 		  //Dt Emissao
			GW7->GW7_SEQ	:= StrZero(++nSeq, 5) //Sequência
			GW7->GW7_CTACTB	:= cCtaCtb 			  //Cta Contßbil
			GW7->GW7_CCUSTO	:= cCCusto 			  //Centro Custo
			GW7->GW7_VLMOV	:= nVlMov 			  //Valor Movto
			GW7->GW7_LANCTO	:= cLance 			  //Lancto
			GW7->GW7_TRANS	:= cTpTrans 		  //Tp Trans
			If !Empty(cUniNeg)
				GW7->GW7_UNINEG := cUniNeg            //Unidade de Negócio
			EndIf
		MsUnLock("GW7")
		LogCtbFat:Add("# Movimento Criado. Sequência: " + cValToChar(GW7->GW7_SEQ), 2)
	EndIf

	RestArea( aAreaGW7 )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEACTBCON()
Geração da Contabilização do Contrato

@author Israel Alcantara Possoli
@since 24/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEACTBCON(cNrContrato, cGW2_CDPROP)
	Local cTrans
	Local nSeq := 0
	Private GFELogD   := GFELog():New("Contab_Contrato_" + Trim(cValToChar(cNrContrato)), "LOG DE CONTABILIZAÇÃO DO CONTRATO")

	GFELogD:Add("Contrato: " + PrintFld(cNrContrato))

	GFELogD:Add("1. Elimando movimentos antigos")

	// Contas de débito - Lancto 1
	dbSelectArea("GW9")
	GW9->( dbSetOrder(2) )
	GW9->( dbSeek(xFilial("GW9") + cNrContrato) )
	While !GW9->( Eof() ) .And. GW9->GW9_FILIAL == xFilial("GW9") .And. GW9->GW9_NRCONT == cNrContrato
		GFELogD:Add(Space(3) + "ELIMINANDO. RecNo: " + PrintFld(GW9->(RecNo())))
		GFELogD:Add(Space(3) + "> Nr Contrato: " + PrintFld(GW9->GW9_NRCONT) + ", Conta: " + PrintFld(GW9->GW9_CTACTB) + ", Centro Custo: " + PrintFld(GW9->GW9_CCUSTO) + ", VALOR: " + PrintFld(GW9->GW9_VLMOV) )
		GFELogD:Add(Space(3) + "> Lancto: " + PrintFld(GW9->GW9_LANCTO) + ", Trans: " + PrintFld(GW9->GW9_TRANS) )

		RecLock("GW9", .F.)
			dbDelete()
		MsUnlock()

		GW9->( dbSkip() )
	EndDo

	GFELogD:Add("2. Procurando rateios")

	dbSelectArea("GWA")
	GWA->( dbSetOrder(1) )
	If GWA->( dbSeek(xFilial("GWA") + "3" + Space(TamSx3("GWA_CDESP")[1]) + cGW2_CDPROP + Space(TamSx3("GWA_SERIE")[1]) + cNrContrato) )
		While !GWA->( Eof() ) .And. ;
			GWA->GWA_FILIAL == xFilial("GWA") .And. ;
			GWA->GWA_TPDOC  == "3" .And. ;
			GWA->GWA_CDESP  == Space(TamSx3("GWA_CDESP")[1]) .And. ;
			GWA->GWA_CDEMIT == cGW2_CDPROP .And. ;
			GWA->GWA_SERIE  == Space(TamSx3("GWA_SERIE")[1]) .And. ;
			GWA->GWA_NRDOC  == PadR(cNrContrato, TamSx3("GWA_NRDOC")[1]);

	 		GFELogD:Add(Space(3) + "Movimento Contábil RecNo: " + PrintFld(GWA->(RecNo()) ))
	 		GFELogD:Add(Space(6) + "> Nr Doc: " + PrintFld(GWA->GWA_NRDOC) + ", Data Emissão: " + PrintFld(GWA->GWA_DTEMIS) + ", Trans: " + PrintFld(GWA->GWA_CDTRAN) + ", SEQ: " + PrintFld(GWA->GWA_SEQ))
			GFELogD:Add(Space(6) + "> Conta Deb: " + PrintFld(GWA->GWA_CTADEB) + ", Conta Cre: " + PrintFld(GWA->GWA_CTACRE) + ", VALOR: " + PrintFld(GWA->GWA_VLMOV) )

			Do Case
				Case Alltrim(Alltrim(GWA->GWA_CDTRAN)) == "100" .Or. Alltrim(GWA->GWA_CDTRAN) == "103" .Or. Alltrim(GWA->GWA_CDTRAN) == "120"
					cTrans := "1"
				Case Alltrim(GWA->GWA_CDTRAN) == "101"
					cTrans := "9"
				Case Alltrim(GWA->GWA_CDTRAN) == "102"
					cTrans := "8"
				Case Alltrim(GWA->GWA_CDTRAN) == "118" .Or. Alltrim(GWA->GWA_CDTRAN) == "121"
					cTrans := "7"
				Case Alltrim(GWA->GWA_CDTRAN) == "103" .Or. Alltrim(GWA->GWA_CDTRAN) == "114" .Or. Alltrim(GWA->GWA_CDTRAN) == "122"
					cTrans := "10"
				Case Alltrim(GWA->GWA_CDTRAN) == "126"
					cTrans := "6"
				Case Alltrim(GWA->GWA_CDTRAN) == "127"
					cTrans := "5"
			EndCase

			/*Grava Debito  */
			GFEAGRAGW9(GWA->GWA_FILIAL, cNrContrato, GWA->GWA_CTADEB, GWA->GWA_CCDEB, GWA->GWA_VLMOV, "1", cTrans, @nSeq, GWA->GWA_UNINEG)

			If !Eof()
				GFELogD:Add(Space(3) + "----------------------------------------------------------------------------------------")
			EndIf

			GWA->( dbSkip() )
		EndDo
	Else
		GFELogD:Add("Não há nenhuma rateio para o contrato.")
	EndIf

	GFELogD:EndLog()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEACTBCON()
Geração da Contabilização do Contrato

@author Israel Alcantara Possoli
@since 24/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEAGRAGW9(cFil, cNrContrato, cCtaCtb, cCCusto, nVlMov, cLancto, cTrans, nSeq, cUniNeg)

	GFELogD:Add(Space(6) + "2. Criação do Movimento")
	GFELogD:Add(Space(6) + "> Contrato: " + PrintFld(cNrContrato) + ", Conta: " + PrintFld(cCtaCtb) + ", Centro Custo: " + PrintFld(cCCusto) + ", Valor: " + PrintFld(nVlMov) + ", Lancto: " + PrintFld(cLancto) + ", Trans: " + PrintFld(cTrans))

	If Empty(cCtaCtb)
		GFELogD:Add(Space(6) + "Conta em branco." + Space(1) + "CANCELANDO OPERAÇÂO")
		Return
	EndIf

	dbSelectArea("GW9")
	GW9->( dbSetOrder(2) )
	If GW9->( dbSeek(xFilial("GW9") + cNrContrato + cCtaCtb + cCCusto + cLancto + cTrans + cUniNeg) )

		RecLock("GW9",.F.)
			GW9->GW9_VLMOV += nVlMov
		MsUnLock("GW9")

		GFELogD:Add(Space(9) + "MOVIMENTO ATUALIZADO")
		GFELogD:Add(Space(10) + "> RecNo: " + cValToChar(GW9->(RecNo())) )
		GFELogD:Add(Space(10) + "> VALOR: " + PrintFld(GW9->GW9_VLMOV))

	Else

		RecLock( "GW9" , .T. )
			GW9->GW9_FILIAL := cFil
			GW9->GW9_NRCONT := cNrContrato
			GW9->GW9_SEQ    := StrZero(++nSeq, 5)
			GW9->GW9_CTACTB := cCtaCtb
			GW9->GW9_CCUSTO := cCCusto
			GW9->GW9_VLMOV  := nVlMov
			GW9->GW9_LANCTO := cLancto
			GW9->GW9_TRANS  := cTrans
			If !Empty(cUniNeg)
				GW9->GW9_UNINEG := cUniNeg
			EndIf
		MsUnLock( "GW9" )

		GFELogD:Add(Space(9) + "MOVIMENTO CRIADO")
		GFELogD:Add(Space(10) + "> RecNo: " + PrintFld(GW9->(RecNo())) )
		GFELogD:Add(Space(10) + "> Contrato: " + PrintFld(GW9->GW9_NRCONT) + ", Filial: " + PrintFld(GW9->GW9_FILIAL) + ", Seq: " + PrintFld(GW9->GW9_SEQ))
		GFELogD:Add(Space(10) + "> Conta Contábil: " + PrintFld(GW9->GW9_CTACTB) + ", Centro de Custo: " + PrintFld(GW9->GW9_CCUSTO) + ", VALOR: " + PrintFld(GW9->GW9_VLMOV))

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintFld()
Função interna para o arquivo de log, imprime o valor do campo convertendo para string e retirando os espaços excedentes

@author Israel Alcantara Possoli
@since 24/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PrintFld(cCampo)

Return Trim(cValToChar(cCampo))
