#INCLUDE "GFEXFUNB.ch"
#include 'protheus.ch'

// Constantes usadas na função AddToLog()
#DEFINE _LOG_BEGIN 1
#DEFINE _LOG_END   2

Static s_GFEGVR		:= SuperGetMv("MV_GFEGVR",.F.,"1") == "1" // 2-Não utiliza a tabela GVR / 1-Realiza consulta na tabela GVR
Static s_TREENTR	:= SuperGetMv('MV_TREENTR',.F.,"0")
Static s_UMPESO		:= SuperGetMv("MV_UMPESO",,"KG")
Static s_GFEVIN		:= SuperGetMv("MV_GFEVIN",.F.,"1") == "1" // 2-Não utiliza o cadastro de tabela vínculo / 1-Realiza consulta o cadastro de tabela vínculo
Static s_GFEGUL		:= SuperGetMv("MV_GFEGUL",.F.,"1") == "1" // 2-Não utiliza a tabela GUL / 1-Realiza consulta na tabela GUL
Static s_ESCTBAT	:= SuperGetMV("MV_ESCTBAT",.F.,"1")
Static s_ESCTAB		:= SuperGetMv("MV_ESCTAB",.F.,"1")
Static s_MULFIL		:= SuperGetMV("MV_MULFIL",.F.,"2")

Static lPEXFB01	:= ExistBlock("GFEXFB01")
Static lPEXFB03	:= ExistBlock("GFEXFB03")
Static lPEXFB12	:= ExistBlock("GFEXFB12")
Static lPEXFB14	:= ExistBlock("GFEXFB14")
Static lPEXFB21	:= ExistBlock("GFEXFB21")

Static lExiVLALUG := GFXCP12116('GV7_VLALUG')

/*----------------------------------------------------------------------------
{Protheus.doc} SELTABFRT
Seleciona Tabela de Frete.
Uso: GFECLCFRT

@param nTabProv	Indica se deve ser utilizada a tabela de provisão

@sample SELTABFRT(.T.)

@author Andre Luis Wisnheski
@since 04/06/15
@version 1.0
----------------------------------------------------------------------------*/
Function SELTABFRT(nTabProv,lShowTabFr)
	Local nX
	Local nRecUltUNC
	Local nNrUltCalc
	Local aQryPar
	Local cCdTrpInf
	Local cNrTabInf
	Local cNrNegInf
	Local lBuscaEspe      //caso exista tabela específica
	Local nCntRot
	Local lGenerica
	Local aAreaTRE
	Local nTpLotacao := 0
	Local cCdTpVc    := ""
	Local cRomFil    := ""
	Local aRetFilSQL := {}
	Local aRegioes   := Nil
	Local cTpLocEntr := s_TREENTR
	Local lRotaReg   := IIF(SuperGetMv("MV_GFECREG", .F., 0) == 1, .T., .F.) // Habilitar / Desabilitar busca somente rotas por região que tiverem cidade dos trechos relacionada a região

	Private nI		 := 0
	Private p_TpVeic := SuperGetMv('MV_GFE006', .F., '1')

	If Empty(p_TpVeic)
		p_TpVeic := '1'
	EndIf
	
	If cTpLocEntr != "1"
		cTpLocEntr := ""
  	EndIf

	oGFEXFBFLog:setTexto(CRLF + STR0050 + CRLF) //"3. Selecionando tabela de frete..."
	
	If nTabProv == 1
		lTabInf   := .T.
		cCdTrpInf := SuperGetMv("MV_EMIPRO",.F.,"")
		cNrTabInf := SuperGetMv("MV_TABPRO",.F.,"")
		cNrNegInf := SuperGetMv("MV_NEGPRO",.F.,"")
	ElseIf !Empty(aTabelaFrt)
		// Tabela Frete Informada
		If GFEXFBUAT()
			oGFEXFBFLog:setTexto(CRLF + STR0504 + CRLF)		 //"  Foram informados dados da tabela de frete. Seleção de tabela de frete não será realizada."
			oGFEXFBFLog:setTexto(	CRLF + STR0505 + CRLF +; //"  Dados informados:"
									CRLF + STR0506 + aTabelaFrt[1] + ; //"  Transportador.......: "
									CRLF + STR0507 + aTabelaFrt[2] + ; //"  Tabela de Frete.....: "
									CRLF + "  Nr Negociação.......: " + aTabelaFrt[20] + ; //"  Nr Negociação.......: "
									CRLF + STR0508 + IF(aTabelaFrt[3]=="1",STR0509,STR0510) + ; //"  Tipo de Lotação.....: "###"Fracionado"###"Fechado"
									CRLF + STR0511 + GFEFldInfo("GV9_ATRFAI",IIf(aTabelaFrt[4]=="10","8",aTabelaFrt[4]),2 /*Descricao*/) + ; //"  Atributo da Faixa...: "
									CRLF + STR0512 + aTabelaFrt[5] + ; //"  Tipo de Veículo.....: "
									CRLF + STR0513 + aTabelaFrt[6] + ; //"  Unidade de Medida...: "
									CRLF + STR0514 + cValToChar(aTabelaFrt[7]) + ; //"  Fator de Cubagem....: "
									CRLF + STR0515 + cValToChar(aTabelaFrt[8]) + ; //"  Qtde. Mínima........: "
									CRLF + STR0516 + cValToChar(aTabelaFrt[9]) + ; //"  Vl. Frete Mínimo....: "
									CRLF + STR0517 + aTabelaFrt[10] + ; //"  Comp. Frt. Garantia.: "
									CRLF + STR0518 + If(aTabelaFrt[11]=="1",STR0010,STR0519) + ; //"  Considera Prazo?....: "###"Sim"###"Não"
									CRLF + STR0520 + If(aTabelaFrt[12]=="1",STR0521,STR0522) + ; //"  Tipo de Prazo.......: "###"Dias"###"Horas"
									CRLF + STR0523 + cValToChar(aTabelaFrt[13]) + ; //"  Qtde. Prazo.........: "
									CRLF + STR0524 + If(aTabelaFrt[14]=="1",STR0525,STR0526) + ; //"  Contagem do Prazo...: "###"Dias Corridos"###"Dias Úteis"
									CRLF + STR0527 + If(aTabelaFrt[15]=="1",STR0010,STR0519) + ; //"  Adic. ISS no Frete?.: "###"Sim"###"Não"
									CRLF + STR0528 + If(aTabelaFrt[16]=="1",STR0010,STR0519) + ; //"  Adic. ICMS no Frete?: "###"Sim"###"Não"
									CRLF + STR0529 + If(aTabelaFrt[17]=="1",STR0010,STR0519) + ; //"  Rateia Imposto?.....: "###"Sim"###"Não"
									CRLF + STR0530 + aTabelaFrt[18] + ; //"  Compon. p/ Imposto..: "
									CRLF + STR0531 ) //"  Componentes.........: "
			
			For nX := 1 to len(aTabelaFrt[19])
				if nX > 1
					oGFEXFBFLog:setTexto(",")
				EndIf
				oGFEXFBFLog:setTexto(TRIM(aTabelaFrt[19,nX,1])) // Código do componente
			Next nX

			oGFEXFBFLog:setTexto(CRLF)

			// Atualizar o peso para calculo das tabelas da unidade de calculo
			//posiciona e percorre trechos com mesmo Numero Calculo para calcular o peso cubado
			GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6) 
			GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6) 
			While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6) 
				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
				GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 

				//percorre tabelas do calculos de frete relacionadas
				While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
					GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
					GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU")}) 
					If GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO") == '1' 
						GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0) 
						Loop
					EndIf
					oGFEXFBFLog:setTexto(CRLF + STR0053 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") + STR0054 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + STR0055 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + CRLF + CRLF) //"  # Unid.Calculo "###"; Class.Frete "###"; Tp.Oper. "
					oGFEXFBFLog:setTexto(STR0532 + GFEFldInfo("GV9_ATRFAI",IIf(aTabelaFrt[4]=="10","8",aTabelaFrt[4]),2)) //"    Obtendo quantidade para cálculo baseado em "

					nQtdFaixa := GFEQtdeComp(	GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU"),;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
												aTabelaFrt[4]    ,; // Atributo da faixa
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")  ,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") ,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR") ,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ") ,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
												aTabelaFrt[7]    ,; // Fator de cubagem
												@nPesCub         ,; // Peso cubado a ser atualizado pela função
												s_UMPESO,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
												0,;
												"1",;
												If(!Empty(cTpLocEntr), "1",""),;
												GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRLCENT"),;
												.T.,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
												"")
					
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC",nQtdFaixa)

					oGFEXFBFLog:setTexto(" " + cValToChar(nQtdFaixa) + CRLF)

					GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) 
				EndDo
				GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 
			EndDo

			oGFEXFBFLog:setTexto(CRLF)

			Return NIL
		EndIf
		// Tabela Frete Informada

		lTabInf   := .T.
		cCdTrpInf := aTabelaFrt[1]
		cNrTabInf := aTabelaFrt[2]
		cNrNegInf := aTabelaFrt[20]
	EndIf

	If lTabInf
		oGFEXFBFLog:setTexto(CRLF + STR0533 + cCdTrpInf + STR0534 + cNrTabInf + STR0068 + cNrNegInf + CRLF) //"  Usando tabela informada -> Transp. "###"; Nr. Tab. "###"; Negoc. "
	EndIf

	//TABELAS DE FRETE (STF = Selecao Tabela Frete)
	//arquivo temporario que armazena as tabelas pre-selecionadas
	//com objetivo de realizar um filtro e excluir tabelas invalidas
	If !lTabTemp
		cTRBSTF := ''
		cTRBSIM := ''
	EndIf

	cAliasSTA := GetNextAlias()
	GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6) 

	GFEXFB_IBOTTOM(lTabTemp, cTRBUNC, @aTRBUNC1, 6) 
	nNrUltCalc := Val(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"))	// Será usado na criação de novos registros de UNC
	nRecUltUNC := GFEXFB_GRECNO(lTabTemp, cTRBUNC, 6) 

	GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6) 
	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2(Len(aTRBUNC1))
	EndIf

	// Quando simulação geral, novas unidades de cálculo são criadas dentro do while.
	// Validando o último registro, os novos registros são ignorados, evitando que o laço entre em loop infinito
	IF lTabTemp
		lVazio := (GFENumReg(cTRBUNC) == 0)
	Else
		lVazio := (Len(aTRBUNC1) == 0)
	EndIf

	While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6) .And. (GFEXFB_GRECNO(lTabTemp, cTRBUNC, 6) <= nRecUltUNC) .And. !lVazio
		GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
		GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU")}) 
		If GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO") == '1' 
			GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 
			Loop
		EndIf

		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua2(Oemtoansi(STR0052 + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")))) //"Unidade de cálculo "
		EndIf

		cPedRom := ""

		GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
		GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 

		//percorre tabelas do calculos de frete relacionadas
		While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
			aDelTpVc := {}
			lBuscaEspe := .F.
			oGFEXFBFLog:setTexto(CRLF + STR0053 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") + STR0054 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + STR0055 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + CRLF + CRLF) //"  # Unid.Calculo "###"; Class.Frete "###"; Tp.Oper. "

			//libera alias para que possa ser reutilizada
			If Select(cAliasSTA) > 0
				(cAliasSTA)->(dbCloseArea())
			EndIf

			//posiciona trecho com mesmo Numero Calculo
			GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
			GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")}) 

			//posiciona Grupo de Entrega com mesmo Numero Grupo
			GFEXFB_BORDER(.F.,,03,4)
			GFEXFB_CSEEK(.F.,, @aTRBGRB3, 4,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRGRUP")}) 

			oGFEXFBFLog:setTexto(STR0031 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") + ;
					 STR0023 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") + ;
					 STR0024 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  + ;
					 STR0025 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")   + ;
					 STR0032 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ")    + ;
					 STR0033 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRGRUP") + ;
					 STR0034 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP")  + CRLF) //" Trecho (Tp.Doc. "###"; Emis. "###"; Série "###"; Nr.Doc. "###"; Seq. "###"), Grupo "###", Transp. "

			//lista os documentos relacionados
			cGrupo := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRGRUP")
			cDoc := ""
			While !GFEXFB_3EOF(.F.,, @aTRBGRB3, 4) .And. ;
				  cGrupo == GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRGRUP")

				cDoc += GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRDC")
				GFEXFB_8SKIP(.F.,, 4) 
				cDoc += If(!GFEXFB_3EOF(.F.,, @aTRBGRB3, 4) .And. cGrupo == GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRGRUP"),", ","")
			EndDo
			oGFEXFBFLog:setTexto(STR0056 + cDoc + CRLF + CRLF) //"    Doctos. Carga: "

			//reposiciona Grupo de Entrega com mesmo Numero Grupo
			GFEXFB_CSEEK(.F.,, @aTRBGRB3, 4,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRGRUP")}) 

			//limpa arquivo de tabelas de frete
			If lTabTemp
				GFEDelTbData(cTRBSTF)
			Else
				IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
				IIF(aTRBSTF2==NIL,,aSize(aTRBSTF2,0))
				IIF(aTRBSTF3==NIL,,aSize(aTRBSTF3,0))
				aTRBSTF1 := {}
				aTRBSTF2 := {}
				aTRBSTF3 := {}
			EndIf

			oGFEXFBFLog:setTexto(STR0057 + CRLF) //"    # Pre-seleção de tabelas tipo NORMAL:"

			lGW1Enc := .F.

			GW1->(dbSetOrder(1) )
			If GW1->(dbSeek( GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"FILIAL") + ;
							 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") + ;
							 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") + ;
							 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  + ;
							 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")))
				lGW1Enc := .T.
				cGW1CDDEST := GW1->GW1_CDDEST
				cGW1CDREM  := GW1->GW1_CDREM
				cGW1CDTPDC := GW1->GW1_CDTPDC
				cGW1EMISDC := GW1->GW1_EMISDC
				cGW1ENTNRC := GW1->GW1_ENTNRC
				cGW1NRDC   := GW1->GW1_NRDC
				cGW1SERDC  := GW1->GW1_SERDC
				cGW1FILIAL := GW1->GW1_FILIAL
			EndIf

			cRomFil := GW1->GW1_FILIAL
			If s_MULFIL == "1" .And. GFXCP1212210('GW1_FILROM')
				cRomFil := GW1->GW1_FILROM
			EndIf

			GWN->(dbSetOrder(1))
			GWN->(dbSeek(cRomFil + GW1->GW1_NRROM))

			/* BLOCO TRASFERIDO*/

			aAreaTRE := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7) 

			cTrcDes := 	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") + ;
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") + ;
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  + ;
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")
			cTrpDes := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP")
			cCepDsGU3 := Posicione("GU3",1,xFilial("GU3")+cTrpDes,"GU3_CEP")

			GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7) 
			If !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. ;
				cTrcDes == 	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") + ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") + ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  + ;
							GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")
				lLstTre := .F.
			Else
				lLstTre := .T.
			EndIf

			GFEXFB_ARESTAREA(lTabTemp,aAreaTRE,7) //RestArea(aAreaTRE)

			If lGW1Enc // Campo não será utilizado na busca de rotas. Requisito LOGGFE01-695
				cDCDest   := cGW1CDDEST
			EndIf 

			If (AllTrim(cDCDest) == "") 
				GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1) 
				If GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), ;
																 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), ;
																 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC") , ;
																 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")}) 
					cDCDest   := GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDDEST")
				EndIf
			EndIf 

			lRegDC := lLstTre

			/* BLOCO TRASFERIDO*/

			aQryPar := {.T., 				;	// REALIZA FILTROS ADICIONAIS - PERFORMANCE MELHORADA 
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM"), 	;	// CIDADE ORIGEM
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN"),  ; 	// CIDADE DESTINO
						cGW1FILIAL,         ;
						cGW1CDTPDC,         ;
						cGW1EMISDC,         ;
						cGW1SERDC,          ;
						cGW1NRDC,			;
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO"),  ;
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD")}

			If lPEXFB12
			   	aRetFilSQL := ExecBlock("GFEXFB12",.f.,.f.,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM"),; 
			   												GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")})
			EndIf
			nCntRot := 0
			
			nI++

			If nI == 1 .Or. p_TpVeic == '1' 
				cCdTpVc := If( Empty( GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPVC") ),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPVC"),GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPVC") )				
			Else
				cCdTpVc := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPVC")
				If Empty(cCdTpVc)
					cCdTpVc := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPVC")
				EndIF
			EndIf		

			nTpLotacao := GFEXFBECFL(cCdTpVc)		
			
			//codigo SQL faz pre-selecao de tabelas/negociacoes/rotas tipo (1) NORMAL para filtragem posterior, valida Dt.Vigencia
			//Chamada da função GetTabSql para que possa ser buscadas as tabelas de frete genericas ou não para o romaneio, ***BUSCA ESPECIFICA****
			lGenerica := (If((lSimulacao .AND. iTipoSim == 0),.T.,.F.))

			If !lRotaReg
				cQuery := GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") , lGenerica, .T.,aQryPar,nTpLotacao,aRetFilSQL)
				cQuery := ChangeQuery(cQuery)

				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSTA, .F., .T.)
			Else
				aRegioes := GetRegRotas( aQryPar )
				aQuery := GetTabQry( lTabInf, cCdTrpInf, cNrTabInf, cNrNegInf, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"), lGenerica, .T., aQryPar, nTpLotacao, aRetFilSQL, aRegioes)
				
				cAliasSTA := GetNextAlias()
				BeginSql Alias cAliasSTA
					SELECT %Exp:aQuery[1]%
					  FROM %Table:GVA% GVA
					  JOIN %Exp:aQuery[2]%
					 WHERE %Exp:aQuery[3]%
				EndSql
			EndIf

			(cAliasSTA)->(dbGoTop())
			If (cAliasSTA)->(EOF()) .AND. (cAliasSTA)->(BOF()) .And. lGenerica == .F.
				//libera alias para que possa ser reutilizada
				If Select(cAliasSTA) > 0
					(cAliasSTA)->(dbCloseArea())
				EndIf

				//Chamada da função GetTabSql para que possa ser buscadas as tabelas de frete genericas ou não para o romaneio, ***BUSCA GENERICA***
				cQuery := GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") , .T., .T.,aQryPar,nTpLotacao,aRetFilSQL)

				cQuery := ChangeQuery(cQuery)

				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSTA, .F., .T.)
			Else
				lBuscaEspe := .T.
			Endif

			(cAliasSTA)->(dbGoTop())
			If (cAliasSTA)->(EOF() ) .AND. (cAliasSTA)->(BOF() )
				oGFEXFBFLog:setTexto(STR0063 + If(lTabInf,cCdTrpInf,GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")) + STR0064 + CRLF) //"      Não foram encontradas tabelas do tipo NORMAL para o transp. "###" com situação Liberada, vigentes para a data de hoje."
			Else
				nCntRot += SELTABGR()
			EndIf

			cQuery := ''

			///grava tabelas de frete selecionadas do tipo (1) NORMAL
			//libera alias para que possa ser reutilizada
			If Select(cAliasSTA) > 0
				(cAliasSTA)->(dbCloseArea())
			EndIf

			///-------------------------------------------------------------------///
			///------------------------ TABELA VINCULO ---------------------------///
			///-------------------------------------------------------------------///
			If s_GFEVIN .AND. nTabProv != 1//So busca tabela vinculada se cálculo não for tabela de provisão
				oGFEXFBFLog:setTexto(CRLF + STR0065 + CRLF) //"    # Pre-selecao de tabelas tipo VINCULO:"
				lGenerica := (If((lSimulacao .AND. iTipoSim == 0),.T.,.F.))

				If !lRotaReg
					lGenerica := .T.	// Alterado flag para considerar preenchimento ou não de TpOper e ClasFrete na tabela devido a caso da Camil
					cQuery := GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") , lGenerica, .F., aQryPar, nTpLotacao)
					cQuery := ChangeQuery(cQuery)

					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSTA, .F., .T.)

				Else
					aRegioes := GetRegRotas( aQryPar )
					aQuery := GetTabQry( lTabInf, cCdTrpInf, cNrTabInf, cNrNegInf, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"), lGenerica, .F., aQryPar, nTpLotacao, aRetFilSQL, aRegioes)
					
					cAliasSTA := GetNextAlias()
					BeginSql Alias cAliasSTA
						SELECT %Exp:aQuery[1]%
						FROM %Table:GVA% GVA
						JOIN %Exp:aQuery[2]%
						WHERE %Exp:aQuery[3]%
					EndSql
				EndIf

				(cAliasSTA)->(dbGoTop())
				If (cAliasSTA)->(EOF() ) .AND. (cAliasSTA)->(BOF() ) .And. lGenerica == .F.
					//libera alias para que possa ser reutilizada
					If Select(cAliasSTA) > 0
						(cAliasSTA)->(dbCloseArea())
					EndIf

					//Chamada da função GetTabSql para que possa ser buscadas as tabelas de frete genericas ou não para o romaneio, ***BUSCA GENERICA***
					cQuery := GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") , GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") , .T., .F.,aQryPar, nTpLotacao)

					cQuery := ChangeQuery(cQuery)

					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSTA, .F., .T.)
				Endif
				
				nCntRot += SELTABGR()				
			EndIf
			IF nCntRot == 0
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VALTAB",.F.)	// Não foi encontrada tabela valida para a unidade de calculo
		
				GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 7)
		
				GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
				GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU")}) 
				GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO", '1') 
		
				lError := .T.
				oGFEXFBFLog:setTexto(STR0099 + CRLF) //"      *** Nenhuma tabela foi selecionada!!!"
			Else
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VALTAB",.T.)	// Não foi encontrada tabela valida para a unidade de calculo
				GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
				GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU")})
				GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO", '0')
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) 
		EndDo	// While !(cTRBTCF)->(Eof()) .And. (cTRBUNC)->NRCALC == (cTRBTCF)->NRCALC
		
		// Cria um novo TCF //TABELA DO CALCULO DE FRETE para cada tabela encontrada
		If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
			GFECalcSim(@nNrUltCalc)
		Else
			GFEAPPEDUC(cPedRom, GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), .T.)
		EndIf
		GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 
	EndDo

	If !lTabTemp
		// NA função GFECalcSim() e pode ser incluido informações no array 2, por este motivo ele pode ser maior.
		IF Len(aTRBUNC2) > Len(aTRBUNC1)
			// Como acima pode ter ocorrido alteração de registro, do campo VALTAB, esta informação precisa ser passada para array 2 para ser utilizado como clone
			for nX:= 1 to Len(aTRBUNC1)
				if aTRBUNC1[nX,18] == .F. //"VALTAB",; // 18
					GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
					GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{aTRBUNC1[nX,19],aTRBUNC1[nX,01]})
					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VALTAB",.F.)
				EndIf
			next
			aTRBUNC1 := aClone(aTRBUNC2)
			aTRBUNC3 := aClone(aTRBUNC2)
		Else
			// se os dois arrays são iguais, deve ser realizado uma copia. O array 1 pode ter sido alterado.
			aTRBUNC2 := aClone(aTRBUNC1)
			aTRBUNC3 := aClone(aTRBUNC1)
		EndIf
		aSort(aTRBUNC1  ,,,{|x,y| x[01]             < y[01]})
		aSort(aTRBUNC2  ,,,{|x,y| x[19]+x[01]       < y[19]+y[01]})
		aSort(aTRBUNC3  ,,,{|x,y| x[19]+x[21]+x[01] < y[19]+y[21]+y[01]})
	EndIf

	//------------------------------------------------------------------------------
	//VERIFICAÇÂO DO PESO CUBADO POR NOTA FISCAL
	//------------------------------------------------------------------------------
	If !lError .Or. lOrigLote
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua1("Determinando o peso cubado para o cálculo...")
		EndIf
		GFEDefPes()
	EndIf

	If lError
		oGFEXFBFLog:setTexto(CRLF+CRLF, _LOG_BEGIN)
	EndIf

	if !lTabTemp
		IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
		IIF(aTRBSTF2==NIL,,aSize(aTRBSTF2,0))
		IIF(aTRBSTF3==NIL,,aSize(aTRBSTF3,0))
		aTRBSTF1 := {}
		aTRBSTF2 := {}
		aTRBSTF3 := {}
	EndIf

	GFEDelTab(cAliasSTA)
	If Select(cAliasSTA) > 0
		(cAliasSTA)->(dbCloseArea())
	Endif

	if lTabTemp
		IIF(aTRBSIM1==NIL,,aSize(aTRBSIM1,0))
		aTRBSIM1 := Nil
		IIF(aTRBSIM2==NIL,,aSize(aTRBSIM2,0))
		aTRBSIM2 := Nil
	EndIf 

Return NIL

//Retorna a configuração para o tipo de lotação
//Simulação sem tipo de veículo informado considera os dois tipos
//Simulação com tipo de veículo informado considera o parâmetro
//Normal sem tipo de veículo informado considera o fracionado
//Normal com tipo de veículo informado considera o parâmetro
Function GFEXFBECFL(cCdTpVc)

	Local nTpLotacao := 0
	
	If Empty(cCdTpVc)
		If !lSimulacao .And. !lPEXFB03 //O ponto de entrada tem prioridade
			nTpLotacao := 1 //Somente Fracionado quando cálculo do romaneio
		EndIf
	Else 
		If AllTrim(SuperGetMv('MV_LOCTVEI',.F.,'1')) == '2' 
			nTpLotacao := 2
		EndIf
	EndIf

Return nTpLotacao


/*----------------------------------------------------------------------------
{Protheus.doc} GetQuery
//Função que gera a query para ser executada no sql, lGenerica = .T.
busca negociações genericas, lGenerica = .F. é necessario uma negociação exata a classifica/tipo de operação


@author Jorge Valcanaia
@since 12/12/2013
@version 1.0
----------------------------------------------------------------------------*/
Function GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , cCdTrp , cCdClFr , cCdTpOp , lGenerica, lTabNor, aQryPar,nTpLotacao, aRetFilSQL)
	Local cQryCon := ""
	Local nCount	:= 0

	Default lGenerica := .F.
	Default aQryPar   := {  .F.,; // REALIZA FILTROS ADICIONAIS - PERFORMANCE MELHORADA 
					/*02*/	'', ; // CIDADE ORIGEM
					/*03*/	'', ; // CIDADE DESTINO
					/*04*/	'', ; // cGW1FILIAL 
					/*05*/	'', ; // cGW1CDTPDC 
					/*06*/	'', ; // cGW1EMISDC
					/*07*/	'', ; // cGW1SERDC 
					/*08*/	'', ; // cGW1NRDC
					/*09*/	'', ; // CEP ORIGEM
					/*10*/	'', } // CEP DESTINO
	Default nTpLotacao := 0
	Default aRetFilSQL	:=	{{}}
	Default pdtCalcPed := stod("")	
	
	oGFEXFBFLog:setTexto("      #Dados Localização Tabela de Frete" + CRLF)
	
	oGFEXFBFLog:setTexto("      #Tipo Operação:" + cCdTpOp)
	
	oGFEXFBFLog:setTexto(" #Classificação Frete:" + cCdClFr)
	
	If nTpLotacao == 0
		oGFEXFBFLog:setTexto(' #Lotação: 1=Carga Fracionada;2=Carga Fechada;3=Veiculo Dedicado')
	ElseIf nTpLotacao == 1
		oGFEXFBFLog:setTexto(' #Lotação: 1=Carga Fracionada')
	ElseIf nTpLotacao == 2
		oGFEXFBFLog:setTexto(' #Lotação: 2=Carga Fechada;3=Veiculo Dedicado')
	EndIf
	
	cQryCon := " SELECT "
	cQryCon += " GVA.GVA_EMIVIN,"
	cQryCon += " GVA.GVA_TABVIN,"
	cQryCon += " GVA.GVA_CDEMIT,"
	cQryCon += " GVA.GVA_NRTAB,"
	cQryCon += " GV9.GV9_DTVALF,"
	cQryCon += " GV9.GV9_NRNEG,"
	cQryCon += " GV9.GV9_CDCLFR,"
	cQryCon += " GV9.GV9_CDTPOP,"
	cQryCon += " GV9.GV9_DTVALI,"
	cQryCon += " GV9.GV9_DTVALF,"
	cQryCon += " GV9.GV9_ATRFAI,"
	cQryCon += " GV9.GV9_QTKGM3,"
	cQryCon += " GV9.GV9_UNIFAI,"
	cQryCon += " GV9.GV9_TPLOTA,"
	cQryCon += " GV8.GV8_NRROTA,"
	cQryCon += " GV8.GV8_TPORIG,"
	cQryCon += " GV8.GV8_TPDEST"
	IF aQryPar[1] = .T.
		If lTabNor
			cQryCon += " , 	   '1' AS NOR_VIN, "
		Else
			cQryCon += " , 	   '2' AS NOR_VIN, "
		EndIf
		
		cQryCon += " GV8.GV8_NRCIOR, GV8.GV8_NRCIDS, "
		cQryCon += " GU7ORI.GU7_CDUF, GU7ORI.GU7_CDPAIS, GV8.GV8_CDUFOR, GV8.GV8_CDPAOR, "
		cQryCon += " GU7DES.GU7_CDUF, GU7DES.GU7_CDPAIS, GV8.GV8_CDUFDS, GV8.GV8_CDPADS, "
		cQryCon += " GV8.GV8_DSTORI,  GV8.GV8_DSTORF,    GV8.GV8_NRREOR, GV8.GV8_CDREM, "
		cQryCon += " GV8.GV8_DSTDEI,  GV8.GV8_DSTDEF,    GV8.GV8_NRREDS, GV8.GV8_CDDEST, "
		cQryCon += " GV8.GV8_DUPSEN, "
		cQryCon += " ISNULL(GU9ORI.GU9_SIT,'') AS GU9_SIT, ISNULL(GU9ORI.GU9_NMREG,'') AS GU9_NMREG, "
		cQryCon += " GU3DES.GU3_NMEMIT, GU3DES.GU3_NRCID, GU3ORI.GU3_NMEMIT AS GU3_NMEMITORI, "
		cQryCon += " ISNULL(GU9DES.GU9_NMREG,'') AS GU9_NMREGDS, "
		cQryCon += " CASE "
		cQryCon += " 	WHEN ( ISNULL((SELECT COUNT(GUA.GUA_FILIAL)  "
		cQryCon += " 		    FROM "+RetSQLName("GUA")+" GUA  "
		cQryCon += " 			JOIN "+RetSQLName("GU9")+" GU9 ON (GU9.GU9_NRREG = GUA.GUA_NRREG) "
		cQryCon += " 		   WHERE GUA.GUA_FILIAL = '"+xFilial("GUA")+"' "
		cQryCon += " 		     AND GU9.GU9_FILIAL = '"+xFilial("GU9")+"' "
		cQryCon += "			 AND GUA.D_E_L_E_T_ = ' ' "
		cQryCon += "			 AND GU9.D_E_L_E_T_ = ' ' "
		cQryCon += " 			 AND GU9.GU9_SIT = '1' "
		cQryCon += " 		     AND GUA.GUA_NRREG = GV8.GV8_NRREOR "
		cQryCon += "			 AND (GUA.GUA_NRCID = '"+aQryPar[2]+"')"
		cQryCon += "		   ),0)"
		If GFXTB12117("GVR") .AND. s_GFEGVR
			cQryCon += "        +  ISNULL((SELECT COUNT(GUA.GUA_FILIAL)  "
			cQryCon += " 		    FROM "+RetSQLName("GUA")+" GUA  "
			cQryCon += " 			JOIN "+RetSQLName("GVR")+" GVR ON (GVR.GVR_NRREGR = GUA.GUA_NRREG) "
			cQryCon += " 			JOIN "+RetSQLName("GU9")+" GU9 ON (GU9.GU9_NRREG = GUA.GUA_NRREG) "
			cQryCon += " 		   WHERE GUA.GUA_FILIAL = '"+xFilial("GUA")+"' "
			cQryCon += " 		     AND GU9.GU9_FILIAL = '"+xFilial("GU9")+"' "
			cQryCon += " 		     AND GVR.GVR_FILIAL = '"+xFilial("GVR")+"' "
			cQryCon += "			 AND GUA.D_E_L_E_T_ = ' ' "
			cQryCon += "			 AND GVR.D_E_L_E_T_ = ' ' "
			cQryCon += "			 AND GU9.D_E_L_E_T_ = ' ' "
			cQryCon += " 			 AND GU9.GU9_SIT = '1' "
			cQryCon += " 		     AND GVR.GVR_NRREG = GV8.GV8_NRREOR "
			cQryCon += "			 AND (GUA.GUA_NRCID = '"+aQryPar[2]+"')"
			cQryCon += "		   ),0)"
		EndIf
		cQryCon += " ) > 0 "
		cQryCon += " THEN 1 ELSE 0 "
		cQryCon += " END AS REG_ORI1, "
		
		lGFEXFB14 := .T.
		If lPEXFB14 
			lGFEXFB14 := ExecBlock("GFEXFB14")			
		EndIf
		
		If lGFEXFB14		
		
			cQryCon += " CASE "
			cQryCon += " 	WHEN ( ISNULL((SELECT COUNT(GUA.GUA_FILIAL)  "
			cQryCon += " 		    FROM "+RetSQLName("GUA")+" GUA  "
			cQryCon += " 			JOIN "+RetSQLName("GU9")+" GU9 ON (GU9.GU9_NRREG = GUA.GUA_NRREG) "
			cQryCon += " 		   WHERE GUA.GUA_FILIAL = '"+xFilial("GUA")+"' "
			cQryCon += " 		     AND GU9.GU9_FILIAL = '"+xFilial("GU9")+"' "
			cQryCon += "			 AND GUA.D_E_L_E_T_ = ' ' "
			cQryCon += "			 AND GU9.D_E_L_E_T_ = ' ' "
			cQryCon += " 			 AND GU9.GU9_SIT = '1' "
			cQryCon += " 		     AND GUA.GUA_NRREG = GV8.GV8_NRREOR "
			cQryCon += "			 AND (GV8.GV8_DUPSEN = '1' AND GUA.GUA_NRCID = '"+aQryPar[3]+"')"
			cQryCon += "		   ),0)"
			If GFXTB12117("GVR") .AND. s_GFEGVR
				cQryCon += "        +  ISNULL((SELECT COUNT(GUA.GUA_FILIAL)  "
				cQryCon += " 		    FROM "+RetSQLName("GUA")+" GUA  "
				cQryCon += " 			JOIN "+RetSQLName("GVR")+" GVR ON (GVR.GVR_NRREGR = GUA.GUA_NRREG) "
				cQryCon += " 			JOIN "+RetSQLName("GU9")+" GU9 ON (GU9.GU9_NRREG = GUA.GUA_NRREG) "
				cQryCon += " 		   WHERE GUA.GUA_FILIAL = '"+xFilial("GUA")+"' "
				cQryCon += " 		     AND GU9.GU9_FILIAL = '"+xFilial("GU9")+"' "
				cQryCon += " 		     AND GVR.GVR_FILIAL = '"+xFilial("GVR")+"' "
				cQryCon += "			 AND GUA.D_E_L_E_T_ = ' ' "
				cQryCon += "			 AND GVR.D_E_L_E_T_ = ' ' "
				cQryCon += "			 AND GU9.D_E_L_E_T_ = ' ' "
				cQryCon += " 			 AND GU9.GU9_SIT = '1' "
				cQryCon += " 		     AND GVR.GVR_NRREG = GV8.GV8_NRREOR "
				cQryCon += "			 AND (GV8.GV8_DUPSEN = '1' AND GUA.GUA_NRCID = '"+aQryPar[3]+"')"
				cQryCon += "		   ),0)"
			EndIf
			cQryCon += " ) > 0 "
			cQryCon += " THEN 1 ELSE 0 "
			cQryCon += " END AS REG_ORI2, "
			
		EndIf
		cQryCon += "    CASE "
		cQryCon += " 		WHEN ( ISNULL((SELECT COUNT(GUA.GUA_FILIAL) "
		cQryCon += " 			    FROM "+RetSQLName("GUA")+" GUA " 
		cQryCon += " 				JOIN "+RetSQLName("GU9")+" GU9 ON (GU9.GU9_NRREG = GUA.GUA_NRREG) "
		cQryCon += " 			   WHERE GUA.GUA_FILIAL = '"+xFilial("GUA")+"' "
		cQryCon += " 			     AND GU9.GU9_FILIAL = '"+xFilial("GU9")+"' "
		cQryCon += " 				 AND GU9.D_E_L_E_T_ = ' ' "
		cQryCon += " 				 AND GUA.D_E_L_E_T_ = ' ' "
		cQryCon += " 				 AND GU9.GU9_SIT = '1' "
		cQryCon += " 			     AND GUA.GUA_NRREG = GV8.GV8_NRREDS "
		cQryCon += " 				 AND GUA.GUA_NRCID = '"+aQryPar[2]+"'),0)"
		If GFXTB12117("GVR")  .AND. s_GFEGVR
			cQryCon += "            + ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
			cQryCon += " 		    FROM "+RetSQLName("GUA")+" GUA"
			cQryCon += " 			JOIN "+RetSQLName("GVR")+" GVR ON (GVR.GVR_NRREGR = GUA.GUA_NRREG)"
			cQryCon += " 			JOIN "+RetSQLName("GU9")+" GU9 ON (GU9.GU9_NRREG = GUA.GUA_NRREG)"
			cQryCon += " 		   WHERE GUA.GUA_FILIAL = '"+xFilial("GUA")+"'"
			cQryCon += " 		     AND GU9.GU9_FILIAL = '"+xFilial("GU9")+"'"
			cQryCon += " 		     AND GVR.GVR_FILIAL = '"+xFilial("GVR")+"'"
			cQryCon += "			 AND GUA.D_E_L_E_T_ = ' ' "
			cQryCon += "			 AND GVR.D_E_L_E_T_ = ' ' "
			cQryCon += "			 AND GU9.D_E_L_E_T_ = ' ' "
			cQryCon += " 			 AND GU9.GU9_SIT = '1' "
			cQryCon += " 		     AND GVR.GVR_NRREG = GV8.GV8_NRREDS "
			cQryCon += "			 AND GUA.GUA_NRCID = '"+aQryPar[2]+"' ),0)"
		EndIf
		cQryCon += "		   )"
		cQryCon += "  > 0 "
		cQryCon += " THEN 1 ELSE 0 "
		cQryCon += " END AS REG_DEST1, "

		cQryCon += "    CASE "
		cQryCon += " 		WHEN (ISNULL((SELECT COUNT(GUA.GUA_FILIAL) "
		cQryCon += " 			    FROM "+RetSQLName("GUA")+" GUA " 
		cQryCon += " 				JOIN "+RetSQLName("GU9")+" GU9 ON (GU9.GU9_NRREG = GUA.GUA_NRREG) "
		cQryCon += " 			   WHERE GUA.GUA_FILIAL = '"+xFilial("GUA")+"' "
		cQryCon += " 			     AND GU9.GU9_FILIAL = '"+xFilial("GU9")+"' "
		cQryCon += " 				 AND GU9.D_E_L_E_T_ = ' ' "
		cQryCon += " 				 AND GUA.D_E_L_E_T_ = ' ' "
		cQryCon += " 				 AND GU9.GU9_SIT = '1' "
		cQryCon += " 			     AND GUA.GUA_NRREG = GV8.GV8_NRREDS "
		cQryCon += " 			     AND GV8.GV8_TPDEST = '3'
		cQryCon += " 				 AND GUA.GUA_NRCID = '"+aQryPar[3]+"'),0)"
		If GFXTB12117("GVR") .AND. s_GFEGVR
			cQryCon += "            + ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
			cQryCon += " 		    FROM "+RetSQLName("GUA")+" GUA"
			cQryCon += " 			JOIN "+RetSQLName("GVR")+" GVR ON (GVR.GVR_NRREGR = GUA.GUA_NRREG)"
			cQryCon += " 			JOIN "+RetSQLName("GU9")+" GU9 ON (GU9.GU9_NRREG = GUA.GUA_NRREG)"
			cQryCon += " 		   WHERE GUA.GUA_FILIAL = '"+xFilial("GUA")+"'"
			cQryCon += " 		     AND GU9.GU9_FILIAL = '"+xFilial("GU9")+"'"
			cQryCon += " 		     AND GVR.GVR_FILIAL = '"+xFilial("GVR")+"'"
			cQryCon += "			 AND GUA.D_E_L_E_T_ = ' ' "
			cQryCon += "			 AND GVR.D_E_L_E_T_ = ' ' "
			cQryCon += "			 AND GU9.D_E_L_E_T_ = ' ' "
			cQryCon += " 			 AND GU9.GU9_SIT = '1' "
			cQryCon += " 		     AND GVR.GVR_NRREG = GV8.GV8_NRREDS "
			cQryCon += " 			 AND GV8.GV8_TPDEST = '3'
			cQryCon += "			 AND GUA.GUA_NRCID = '"+aQryPar[3]+"' ),0)"
		EndIf
		cQryCon += "		   )"
		cQryCon += "  > 0 "
		cQryCon += " THEN 1 ELSE 0 "
		cQryCon += " END AS REG_DEST2, "
		cQryCon += " ISNULL(GWU.GWU_CDTRP,'') AS GWU_CDTRP, ISNULL(GU3GWU.GU3_CEP,'') AS GU3_CEP "
	EndIf

	cQryCon += " FROM "+RetSQLName("GVA")+" GVA"
	If lTabNor
		cQryCon += " JOIN "+RetSQLName("GV9")+" GV9 ON GVA.GVA_CDEMIT = GV9.GV9_CDEMIT AND GVA.GVA_NRTAB = GV9.GV9_NRTAB"
	Else
		cQryCon += " JOIN "+RetSQLName("GV9")+" GV9 ON GVA.GVA_EMIVIN = GV9.GV9_CDEMIT AND GVA.GVA_TABVIN = GV9.GV9_NRTAB"
	EndIf
	cQryCon += " JOIN "+RetSQLName("GV8")+" GV8 ON GV9.GV9_CDEMIT = GV8.GV8_CDEMIT AND GV9.GV9_NRTAB = GV8.GV8_NRTAB AND GV9.GV9_NRNEG = GV8.GV8_NRNEG"

	IF aQryPar[1] = .T.
		cQryCon += " LEFT JOIN "+RetSQLName("GU7")+" GU7ORI ON GU7ORI.GU7_NRCID  = '"+aQryPar[2]+"' AND GU7ORI.GU7_FILIAL = '"+xFilial("GU7")+"' AND GU7ORI.D_E_L_E_T_ = ' '"
		cQryCon += " LEFT JOIN "+RetSQLName("GU7")+" GU7DES ON GU7DES.GU7_NRCID  = '"+aQryPar[3]+"' AND GU7DES.GU7_FILIAL = '"+xFilial("GU7")+"' AND GU7DES.D_E_L_E_T_ = ' ' "
		cQryCon += " LEFT JOIN "+RetSQLName("GU9")+" GU9ORI ON GU9ORI.GU9_FILIAL = '"+xFilial("GU9")+"' AND GU9ORI.GU9_NRREG  = GV8.GV8_NRREOR AND GU9ORI.D_E_L_E_T_ = ' ' "
		cQryCon += " LEFT JOIN "+RetSQLName("GU9")+" GU9DES ON GU9DES.GU9_FILIAL = '"+xFilial("GU9")+"' AND GU9DES.GU9_NRREG  = GV8.GV8_NRREDS AND GU9DES.D_E_L_E_T_ = ' ' "
		cQryCon += " LEFT JOIN "+RetSQLName("GU3")+" GU3DES ON GU3DES.GU3_FILIAL = '"+xFilial("GU3")+"' AND GU3DES.GU3_CDEMIT = GV8.GV8_CDDEST AND GU3DES.D_E_L_E_T_ = ' ' "
		cQryCon += " LEFT JOIN "+RetSQLName("GU3")+" GU3ORI ON GU3ORI.GU3_FILIAL = '"+xFilial("GU3")+"' AND GU3ORI.GU3_CDEMIT = GV8.GV8_CDREM  AND GU3ORI.D_E_L_E_T_ = ' ' "
		cQryCon += " LEFT JOIN "+RetSQLName("GWU")+" GWU ON " 
		cQryCon += "     GWU.GWU_FILIAL = '"+aQryPar[04]+"' " 
		cQryCon += " AND GWU.GWU_CDTPDC = '"+aQryPar[05]+"' "
		cQryCon += " AND GWU.GWU_EMISDC = '"+aQryPar[06]+"' "
		cQryCon += "  AND GWU.GWU_SERDC = '"+aQryPar[07]+"' "
		cQryCon += "   AND GWU.GWU_NRDC = '"+aQryPar[08]+"' "
		cQryCon += "    AND GWU.GWU_SEQ = '02' "
		cQryCon += "    AND GWU.D_E_L_E_T_ = ' ' "
		cQryCon += " LEFT JOIN "+RetSQLName("GU3")+" GU3GWU ON GU3GWU.GU3_FILIAL = '"+xFilial("GU3")+"'  AND GU3GWU.GU3_CDEMIT = GWU.GWU_CDTRP AND GU3GWU.D_E_L_E_T_ = ' ' "
	EndIf

	cQryCon += " WHERE "
	if Len(aRetFilSQL) > 0 .AND. Len(aRetFilSQL[1]) > 0 //O PE GFEXFB12 foi executado e retornou os transportadores
		oGFEXFBFLog:setTexto(CRLF +" Ponto de Entrada GFEXFB12 executado Filtro por Transportador" + CRLF)
		
		cQryCon += " ( "
		For nCount := 1 To Len(aRetFilSQL[1])
			IF nCount > 1
				cQryCon += " OR "
			EndIf
			cQryCon += " GVA.GVA_CDEMIT = '" + aRetFilSQL[1][nCount] + "' "
		next nCount
		cQryCon += " ) AND "
	Else
		If lTabInf //Se o parametro lTabInf for verdadeiro então acrescenta-se no SQL a Tabela e Negociação a ser utilizada
			oGFEXFBFLog:setTexto(" #Transportador:" + cCdTrpInf)
			
			cQryCon += " GV9.GV9_CDEMIT = '" + cCdTrpInf + "'"
			If !Empty(cNrTabInf)
				cQryCon += " AND GV9.GV9_NRTAB = '" + cNrTabInf + "'" + If(!Empty(cNrNegInf)," AND GV9.GV9_NRNEG = '" + cNrNegInf + "' AND "," AND ")
			Else
				cQryCon += " AND "
			EndIf
		Else
			If !Empty( cCdTrp )
				oGFEXFBFLog:setTexto(" #Transportador:" + cCdTrp + CRLF)
				
				cQryCon += " GVA.GVA_CDEMIT = '" + cCdTrp + "' AND " //- Tranportador igual ao do trecho
			EndIf
		Endif
	EndIf
	If lTabNor
		cQryCon += " GVA.GVA_TPTAB = '1'"
	Else
		cQryCon += " GVA.GVA_TPTAB = '2'"
	EndIf

	If !lSimNegEspec

		if !Empty(pdtCalcPed)
			cQryCon += " AND GV9.GV9_DTVALI <= '"+ DTOS(pdtCalcPed)+"'"
		elseIf lCalcDataBase
			cQryCon += " AND GV9.GV9_DTVALI <= '"+ Iif(!Empty(DTOS(GWN->GWN_DTSAI)),DTOS(GWN->GWN_DTSAI),DTOS(dDataBase))+"'"
		Else
			cQryCon += " AND GV9.GV9_DTVALI <= '"+DTOS(Date())+"'" 
		EndIf
		If nTpLotacao == 1
			cQryCon += " AND GV9.GV9_TPLOTA = '1'"
		ElseIf nTpLotacao == 2
			cQryCon += " AND GV9.GV9_TPLOTA IN ('2','3')"
		EndIf
	EndIf
	
	//Verifica se deve filtrar as tabelas de frete em negociação
	If !lConsNeg
		cQryCon += " AND GV9.GV9_SIT     = '2'"  // Situacao da tabela igual a Liberada
	EndIf
	
	If !lTabNor .And. !lConsNeg
		cQryCon += " AND GVA.GVA_SITVIN  = '2'"  // Situacao da tabela VINCULO igual a Liberada
	EndIf

	// Tabelas com class. frete igual a class. de frete do romaneio/documentos de carga ou tabelas com class. de frete em branco
	If lGenerica
		if !Empty(cCdTpOp)
			cQryCon += " AND (GV9.GV9_CDTPOP = '"+ cCdTpOp +"' OR GV9.GV9_CDTPOP = '')"
		EndIf
		if !Empty(cCdClFr)
			cQryCon += " AND (GV9.GV9_CDCLFR = '"+ cCdClFr +"' OR GV9.GV9_CDCLFR = '')"
		EndIf
	ElseIf !lSimNegEspec
		cQryCon += " AND (GV9.GV9_CDCLFR = '"+ cCdClFr +"')"
		cQryCon += " AND (GV9.GV9_CDTPOP = '"+ cCdTpOp +"')"
	EndIf

	/* Criação de ponto de entrada para permitir o filtro de campos específicos das tabelas GV8 e GV9 */
	If lPEXFB21 
		cQryCon := ExecBlock("GFEXFB21",.F.,.F., cQryCon)	
	EndIf

	if !empty(pdtCalcPed )
		oGFEXFBFLog:setTexto("      #Data Base:" + DTOS(pdtCalcPed) + CRLF)
	else
		oGFEXFBFLog:setTexto("      #Data Base:" + Iif(!Empty(DTOS(GWN->GWN_DTSAI)),DTOS(GWN->GWN_DTSAI),DTOS(dDataBase)) + CRLF)
	endif

	//---------------------------------
	cQryCon += " AND GVA.GVA_FILIAL = '"+xFilial("GVA")+"' AND GV9.GV9_FILIAL = '"+xFilial("GV9")+"' AND GV8.GV8_FILIAL = '"+xFilial("GV8")+"'"

	IF aQryPar[1] = .T.

		if !empty(pdtCalcPed )
			cQryCon += " AND (ISNULL(GV9.GV9_DTVALF,'') = '' OR GV9.GV9_DTVALF = '        ' OR GV9.GV9_DTVALF >= '"+DTOS(pdtCalcPed)+"') "
		elseIf !lSimNegEspec
			cQryCon += " AND (ISNULL(GV9.GV9_DTVALF,'') = '' OR GV9.GV9_DTVALF = '        ' OR GV9.GV9_DTVALF >= '"+Iif(!Empty(DTOS(GWN->GWN_DTSAI)),DTOS(GWN->GWN_DTSAI),DTOS(dDataBase))+"') "
		EndIf
		cQryCon += " AND ( ( GV8.GV8_TPORIG = '1'"     // Origem Cidade
		cQryCon +=        " AND ( ( GV8.GV8_NRCIOR = '"+aQryPar[2]+"' )"
		cQryCon +=              " OR ( GV8.GV8_DUPSEN = '1'"
		cQryCon +=                    " AND GV8.GV8_NRCIOR = '"+aQryPar[3]+"' ) ) )"
		cQryCon +=        " OR ( GV8.GV8_TPORIG = '4'" // Origem País/UF
		cQryCon +=              " AND ( GU7ORI.GU7_CDUF = GV8.GV8_CDUFOR"
		cQryCon +=                    " AND GU7ORI.GU7_CDPAIS = GV8.GV8_CDPAOR )"
		cQryCon +=              " OR ( GV8.GV8_DUPSEN = '1'"
		cQryCon +=                    " AND GU7DES.GU7_CDUF = GV8.GV8_CDUFOR"
		cQryCon +=                    " AND GU7DES.GU7_CDPAIS = GV8.GV8_CDPAOR ) )" 
		cQryCon +=" OR ( GV8.GV8_TPORIG = '2' )"
		cQryCon +=" OR ( GV8.GV8_TPORIG = '0' )"
		cQryCon +=" OR ( GV8.GV8_TPORIG = '3' )"
		cQryCon +=" OR ( GV8.GV8_TPORIG = '5' ) )"
		cQryCon += " AND ( ( GV8.GV8_TPDEST = '1'"     // Destino Cidade
		cQryCon +=        " AND ( ( GV8.GV8_NRCIDS = '"+aQryPar[3]+"' )"
		cQryCon +=              " OR ( GV8.GV8_DUPSEN = '1'"
		cQryCon +=                    " AND GV8.GV8_NRCIDS = '"+aQryPar[2]+"' ) ) )"
		cQryCon +=        " OR ( GV8.GV8_TPDEST = '4'" // Destino País/UF
		cQryCon +=              " AND ( GU7DES.GU7_CDUF = GV8.GV8_CDUFDS"
		cQryCon +=                    " AND GU7DES.GU7_CDPAIS = GV8.GV8_CDPADS )"
		cQryCon +=              " OR ( GV8.GV8_DUPSEN = '1'"
		cQryCon +=                    " AND GU7ORI.GU7_CDUF = GV8.GV8_CDUFDS" 
		cQryCon +=                    " AND GU7ORI.GU7_CDPAIS = GV8.GV8_CDPADS ) ) "
		cQryCon +=" OR ( GV8.GV8_TPDEST = '2' )"
		cQryCon +=" OR ( GV8.GV8_TPDEST = '0' )"
		cQryCon +=" OR ( GV8.GV8_TPDEST = '3' )"
		cQryCon +=" OR ( GV8.GV8_TPDEST = '5' ) )"
	EndIf

	cQryCon += " AND GVA.D_E_L_E_T_ = ' ' AND GV9.D_E_L_E_T_ = ' ' AND GV8.D_E_L_E_T_ = ' '"

Return cQryCon


/*----------------------------------------------------------------------------
	{Protheus.doc} SELTABGR
Grava em tabelas temporárias as rotas que possivelmente poderão ser utilizadas para realizar o cálculo de frete .


@sample GFECLCFRT()

@Return Vetor contendo dados do cálculo
[1] 0-Não possui Rotas válidas / 1-Possui rotas válidas 

@author Andre Luis Wisnheski
@since 11/06/15
@version 1.0
----------------------------------------------------------------------------*/

 Static function SELTABGR()
	Local cCodFaixa := ""
	Local lDemaisOri	// Indica se a rota selecionada é demais cidades origem
	Local lCidOri // Indica se a rota selecionada é mais expecifica origem
	Local lDemaisDes	// Indica se a rota selecionada é demais cidades destino
	Local lCidDes // Indica se a rota selecionada é mais expecifica destino
	//Local lEliminaDemCid    // Indica que a rota demais cidades deve ser eliminada 
	Local aRotDemOri := {} // Recebe as rotas selecionadas que são demais cidades Origem
	Local aRotCidOri := {} // Recebe as rotas selecionadas que são expecificas origem
	Local aRotDemDes := {} // Recebe as rotas selecionadas que são demais cidades destino
	Local aRotCidDes := {} // Recebe as rotas selecionadas que são expecificas destino
	Local cCepOri   := ""
	Local cCepDes   := ""
	Local lFxCEPOri := .F.
	Local lFxCEPDes := .F.
	Local cSelDC    := ""
	Local cChave  := ""
	Local aChvRot := {}
	Local nPos
	Local nPosFret
	Local cContPz
	Local aTabPrazo[14]		// Valores para o cálculo da data de previsão pela tabela de prazos
	Local aRetTabPrazo[6]   // Array que armazena os valores retornados pela função GFETabPrazo
	Local aVerDiver := {}
	Local lTpLota3 := .F. // Existe um tipo de lotação 3 
	Local lTariVali := .T.
	Local lSmlVei := .F.
	Local nX
	Local nRet := 1
	Local cTpLocEntr := s_TREENTR
	//Dados diferenciados entre tabela normal e vínculo
	Local cCdTrp
	Local nNrTab
	Local nNrNeg
	Local cCdClfr
	Local cCdTpop
	Local lTemCrgCmp
	Local nPesoCubCrg
	Local cTodFaixa := ""
	Local lUncDel := .F.
	Local aRetFilSQL := {}
	Local cRegTab := ""
	Local lODOriginal := .T. // Origem e Destino Original. Será invertido quando rota é duplo sentido
	Local cTPDest := ""
	Local cNewCepOri := ""
	Local cNewCepDes := ""
	Local cOri := ""	
	Local cDest := ""
	Local nPosAux := 0
	Local aNegEli := {}

	If cTpLocEntr != "1"
		cTpLocEntr := ""
	EndIf

	(cAliasSTA)->(dbGoTop())
	If !(cAliasSTA)->(EOF() )

		oGFEXFBFLog:setTexto(CRLF + STR0072 + CRLF) //"    # Filtrando tabelas pre-selecionadas - ROTAS: "

		//************************
		//*VALIDA ROTAS          *
		//************************
		oGFEXFBFLog:setTexto(CRLF + "      " +  STR0576 + " (" + ;
									STR0591 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP") + "; " + ; 
									STR0592 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM") + " - " + ; //"Trecho" ### "Transp." ### "Cid.Origem"
									AllTrim(Posicione("GU7",1,xFilial("GU7")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM"),"GU7_NMCID")) +"; " + ;
									STR0593 + " " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN") + " - "+AllTrim(Posicione("GU7",1,xFilial("GU7")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN"),"GU7_NMCID")) + ")" + CRLF) //"Cid.Destino"
		
		aRotDemOri := {}
		aRotCidOri := {}
		aRotDemDes := {}
		aRotCidDes := {}
		nLoop      := 0
		aChvRot    := {}

		While !(cAliasSTA)->(EOF() )
			lDemaisOri := .F.
			lDemaisDes := .F.
			lCidOri := .F.
			lCidDes := .F.
			If nLoop == 0
				cCidOri := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM")
				cCidDes := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")
				lODOriginal := .T. // Origem e Destino Original
				cDsOrig := ""
				cDsDest := ""

				oGFEXFBFLog:setTexto(CRLF + "        " + STR0591 + " " + (cAliasSTA)->GVA_CDEMIT + "; " + STR0594 + " " + (cAliasSTA)->GVA_NRTAB + "; " + STR0595 + " " + (cAliasSTA)->GV9_NRNEG +; //"Transp." ### "Tabela" ### "Negoc."
				"; " + STR0596 + " " + (cAliasSTA)->GV8_NRROTA + "; " + STR0597 + " " + If((cAliasSTA)->NOR_VIN=="1", STR0598, STR0599) + CRLF) //"Rota" ### "Tp.Tab." ### "Normal" ### "Vinculo"
			Else
				oGFEXFBFLog:setTexto("        *** " + STR0600 + CRLF) //"Rota permite duplo sentido, invertendo origem e destino do trecho..."
			EndIf
			
			If (cAliasSTA)->NOR_VIN = '1'
				cCdTrp   := (cAliasSTA)->GVA_CDEMIT
				nNrTab   := (cAliasSTA)->GVA_NRTAB
				nNrNeg   := (cAliasSTA)->GV9_NRNEG
				cCdClfr  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
				cCdTpop  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
			Else
				cCdTrp  := (cAliasSTA)->GVA_EMIVIN //-> emitente que sera utilizado nas validacoes
				nNrTab  := (cAliasSTA)->GVA_TABVIN  //-> tabela que sera utilizada nas validacoes
				nNrNeg  := (cAliasSTA)->GV9_NRNEG
				cCdClfr := (cAliasSTA)->GV9_CDCLFR
				cCdTpop := (cAliasSTA)->GV9_CDTPOP
			EndIf

			lRotaVld  		:= .F.
			lFxCEPOri 	 	:= .F.
			lInvRegCid    := .T.

			//*********************************************************//
			//************************  ORIGEM  ***********************//
			//*********************************************************//

			cDsOrig := ""
			cTpOrig := (cAliasSTA)->GV8_TPORIG

			oGFEXFBFLog:setTexto("          " + STR0601 + " : " + AllTrim(GFEFldInfo("GV8_TPORIG",cTpOrig,2))) //"Tipo Origem"
			DO CASE
				
				CASE cTpOrig == "0" //Todos
					lRotaVld := .T.
					cDsOrig := "Todas as rotas -> OK"
				CASE cTpOrig == "1" //Cidade // ESTA EM SQL
					cDsOrig := AllTrim(Posicione("GU7",1,xFilial("GU7")+(cAliasSTA)->GV8_NRCIOR,"GU7_NMCID"))
					If AllTrim(cCidOri) == AllTrim((cAliasSTA)->GV8_NRCIOR)
						lRotaVld := .T.
					EndIf
					oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + AllTrim((cAliasSTA)->GV8_NRCIOR) + " - " + cDsOrig + ")-> OK", STR0603 + " (" + AllTrim((cAliasSTA)->GV8_NRCIOR) + " - " + cDsOrig + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
				CASE cTpOrig == "2" //Distancia
					GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
					If GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")})
						If GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"DISTAN") >= (cAliasSTA)->GV8_DSTORI .And. GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"DISTAN") <= (cAliasSTA)->GV8_DSTORF
							lRotaVld := .T.
							cDsOrig := SubStr(STR0604 + AllTrim(STR(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"DISTAN"))),1,23) //"Dist.: "
						EndIf
					EndIf
					oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + cDsOrig + ")-> OK", STR0603 + " (" + cValToChar((cAliasSTA)->GV8_DSTORI) + " - " + cValToChar((cAliasSTA)->GV8_DSTORF) + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
				CASE cTpOrig == "3" //Regiao
					//Localiza pela cidade
					GUALocaliza(cCidOri,(cAliasSTA)->GV8_NRREOR,@cDsOrig,@lRotaVld,@lCidOri)
						
					IF ((cAliasSTA)->REG_ORI1 == 1 .AND. nLoop == 0) .OR. (lInvRegCid .And. (cAliasSTA)->REG_ORI2 == 1 .AND. nLoop > 0)
						lRotaVld := .T.
						lCidOri  := .T.
					Else // verifica se a regiao eh demais cidades ou se está na faixa de CEP
	
						If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ") == "01"
							GWN->(dbSetOrder(1))
							If !Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO"))
				            	cCepOri := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO")
				            ElseIf GWN->(dbSeek(xFilial("GWN")+GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))) .AND. GFEVerCmpo({"GWN_CEPO"}) .AND. !Empty(GWN->GWN_CEPO)
								cCepOri := GWN->GWN_CEPO
							Else
								If lGW1Enc
									
									If lODOriginal .Or. Empty((cAliasSTA)->GV8_NRREOR)
										cCepOri := Posicione("GU3",1,xFilial("GU3")+cGW1CDREM,"GU3_CEP")
									EndIf										
									If Empty(cCepOri)
										cDsOrig := AllTrim((cAliasSTA)->GU9_NMREG) + "; " + STR0313 + " '" + cGW1CDREM + "' " + STR0625 // "Transportador" ### "não possui CEP."
									EndIf
	
								EndIf
							EndIf
						Else
							If !Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO"))
				      	cCepOri := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO")
				      Else				                  
				      	cCepOri := Posicione("GU3",1,xFilial("GU3")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"),"GU3_CEP")
				      EndIf
	
							If Empty(cCepOri)
								cDsOrig := AllTrim((cAliasSTA)->GU9_NMREG) + "; " + STR0608 + " '" + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP") + "' " + STR0625 // "Remetente" ### "não possui CEP."
							EndIf
	
						EndIf
						If !lODOriginal
							cCepOri := cNewCepOri
						EndIf
						If !Empty(cCepOri) .AND. s_GFEGUL
							If !Empty((cAliasSTA)->GV8_NRREOR)
								GULLocaliza(cCepOri,(cAliasSTA)->GV8_NRREOR,@cDsOrig,@lRotaVld,@lFxCEPOri)
							Else
								GULLocaliza(cCepOri,cRegTab,@cDsOrig,@lRotaVld,@lFxCEPOri)
							EndIf
						EndIf
	
						If !lFxCEPOri
							GU7->(dbSetOrder(01))
							If GU7->(dbSeek(xFilial("GU7")+cCidOri))
								GU9->(dbSetOrder(01))
								If GU9->(dbSeek(xFilial("GU9")+(cAliasSTA)->GV8_NRREOR))
									If GU9->GU9_DEMCID == "1" .And. AllTrim(GU9->GU9_CDUF) == AllTrim(GU7->GU7_CDUF) .And. GU9->GU9_SIT == "1"
										lRotaVld := .T.
										lDemaisOri := .T.
										cDsOrig := STR0605 + " ("+GU9->GU9_CDUF+")" //"Demais Cidades"
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					If Empty(cDsOrig)
						cDsOrig := AllTrim((cAliasSTA)->GU9_NMREG)
					EndIf
					If Empty((cAliasSTA)->GV8_NRREOR)
						oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + cRegTab + " - " + AllTrim(cDsOrig) + ")-> OK", STR0606 + " (" + cRegTab + " - " + AllTrim(cDsOrig) + ") -> " + STR0609)) //"Correspondente" ### "Não localizada" ### "INVALIDO"
					Else
						oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + (cAliasSTA)->GV8_NRREOR + " - " + AllTrim(cDsOrig) + ")-> OK", STR0606 + " (" + (cAliasSTA)->GV8_NRREOR + " - " + AllTrim(cDsOrig) + ") -> " + STR0609)) //"Correspondente" ### "Não localizada" ### "INVALIDO"					
					EndIf
				CASE cTpOrig == "4" //Pais/UF // ESTA EM SQL
					GU7->(dbSetOrder(01))
					If GU7->(dbSeek(xFilial("GU7")+cCidOri))
						cDsOrig := AllTrim(SubStr(Posicione("SYA",1,xFilial("SYA")+(cAliasSTA)->GV8_CDPAOR,"YA_DESCR"),1,18))+" - "+GU7->GU7_CDUF
						If GU7->GU7_CDUF == (cAliasSTA)->GV8_CDUFOR .And. GU7->GU7_CDPAIS == (cAliasSTA)->GV8_CDPAOR
							lRotaVld := .T.
						EndIf
					ElseIf nLoop > 0 .And. GU7->(dbSeek(xFilial("GU7")+cCidDes))
						cDsOrig := AllTrim(SubStr(Posicione("SYA",1,xFilial("SYA")+(cAliasSTA)->GV8_CDPADS,"YA_DESCR"),1,18))+" - "+GU7->GU7_CDUF
						If GU7->GU7_CDUF == (cAliasSTA)->GV8_CDUFDS .And. GU7->GU7_CDPAIS == (cAliasSTA)->GV8_CDPADS
							lRotaVld := .T.
						EndIf	
					EndIf
					oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + cDsOrig + ")-> OK", STR0607)) //"Correspondente" ### "Diferente / cidade não localizada -> INVALIDO"
				CASE cTpOrig == "5" //Remetente
					If !lODOriginal
						cOri := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDDEST")
					Else
						cOri := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDREM")
					EndIf

					cDsOrig := AllTrim(Posicione("GU3",1,xFilial("GU3")+cOri,"GU3_NMEMIT"))

					If (lSimulacao .AND. iTipoSim == 0)
	
						If IIf(nLoop == 0, GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDREM") == (cAliasSTA)->GV8_CDREM, cOri == (cAliasSTA)->GV8_CDREM)
							lRotaVld := .T.
							If AScan(aChvRot,{|x| x[1] == cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA}) == 0
								AAdd(aChvRot, {cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA, 1})
							EndIf
						Endif	
					Else
						If lGW1Enc
							If IIf(nLoop == 0, cGW1CDREM == (cAliasSTA)->GV8_CDREM, cGW1CDDEST == (cAliasSTA)->GV8_CDREM)
								lRotaVld := .T.
								If AScan(aChvRot,{|x| x[1] == cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA}) == 0
									AAdd(aChvRot, {cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA, 1})
								EndIf
							EndIf
						EndIf	
					EndIf
	
					oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + AllTrim(cOri) + " - " + cDsOrig + ")-> OK", STR0603 + " (" + AllTrim(cOri) + " - " + cDsOrig + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
			ENDCASE
			oGFEXFBFLog:setTexto(CRLF)

			//******************************** ************************//
			//************************ DESTINO ************************//
			//******************************** ************************//

			If cTpOrig == "2" .And. (lRotaVld .OR. (lSimulacao .AND. iTipoSim == 0))
				lRotaVldDes := .T.
			ElseIf lRotaVld .OR. (lSimulacao .AND. iTipoSim == 0) // 0-Simulação Geral, 1-Simulação Específica
				lRotaVldDes := .F.
				lFxCEPDes   := .F.
				//----DESTINO----
				cDsDest := ""
				cTPDest := (cAliasSTA)->GV8_TPDEST
				oGFEXFBFLog:setTexto("          " + STR0610 + " " + AllTrim(GFEFldInfo("GV8_TPDEST",cTPDest,2))) //"Tipo Destino:"
				DO CASE
					CASE cTPDest == "0" //Todos
						lRotaVldDes := .T.
						cDsDest := "Todas as rotas -> OK"
					CASE cTPDest == "1" //Cidade // ESTA EM SQL
						cDsDest := AllTrim(Posicione("GU7",1,xFilial("GU7")+(cAliasSTA)->GV8_NRCIDS,"GU7_NMCID"))
						If AllTrim(cCidDes) == AllTrim((cAliasSTA)->GV8_NRCIDS)
							lRotaVldDes := .T.
						EndIf
						oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + AllTrim((cAliasSTA)->GV8_NRCIDS) + " - " + cDsDest + ")-> OK", STR0603 + " (" + AllTrim((cAliasSTA)->GV8_NRCIDS) + " - " + cDsDest + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
					CASE cTPDest == "2" //Distancia
						GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
						If GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")}) 
							cDsDest := SubStr("Dist.: "+AllTrim(STR(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"DISTAN"))),1,23)
							If GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"DISTAN") >= (cAliasSTA)->GV8_DSTDEI .And. GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"DISTAN") <= (cAliasSTA)->GV8_DSTDEF
								lRotaVldDes := .T.
							EndIf
						EndIf
						oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + cDsDest + ")-> OK", STR0603 + " (" + cValToChar((cAliasSTA)->GV8_DSTORI) + " - " + cValToChar((cAliasSTA)->GV8_DSTORF) + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
					CASE cTPDest == "3" //Regiao
							cDsDest := AllTrim((cAliasSTA)->GU9_NMREGDS)
		
							lRegDC := lLstTre
							cSelDC := (cAliasSTA)->GV8_NRREDS
							
							IF ((cAliasSTA)->REG_DEST2 == 1 .AND. nLoop == 0) .OR. ((cAliasSTA)->REG_DEST1 == 1 .AND. nLoop > 0)
								lRotaVldDes := .T.
								lCidDes := .T. 
							Else // verifica se regiao eh demais cidades ou está dentro da faixa de CEP
		
								If !lLstTre
									If !Empty(IIF(lODOriginal,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO")))
						            	cCepDes := IIF(lODOriginal,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO"))
						            Else
										cCepDes := cCepDsGU3 //Posicione("GU3",1,xFilial("GU3")+cTrpDes,"GU3_CEP")
									EndIf
									
									If Empty(cCepDes)
										cDsDest := AllTrim((cAliasSTA)->GU9_NMREGDS) + "; " + STR0608 + " '" + cTrpDes + "' " + STR0625 // "Transportador" ### "não possui CEP."
									EndIf
		
								Else
									GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
									GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")})
		
									GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1) 
									GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,{cGW1CDTPDC, cGW1EMISDC, cGW1SERDC, cGW1NRDC}) 
									
									If !Empty(IIF(lODOriginal,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO")))
						            	cCepDes := IIF(lODOriginal,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO"))
						            ElseIf !Empty(IIF(lODOriginal,GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CEPD"),''))
										cCepDes := IIF(lODOriginal,GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CEPD"),'')
									ElseIf GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"PAGAR") == "1" .and. !Empty(GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"ENTCEP")) .and. Alltrim(cCidDes) == Alltrim(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC"))
										cCepDes := GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"ENTCEP")
									Else
										IF (Alltrim(cCidDes) != Alltrim(Posicione("GU3",1,xFilial("GU3")+cDCDest,"GU3_NRCID")))
											cDCDest:= (cAliasSTA)->GWU_CDTRP //Posicione("GWU",1,cChaveDes,"GWU_CDTRP")
											If Empty(cDCDest)
												cDCDest := cGW1CDREM
											EndIf
										EndIf
										cCepDes := Posicione("GU3",1,xFilial("GU3")+cDCDest,"GU3_CEP") 
									EndIf
		
									If Empty(cCepDes)
										cDsDest := AllTrim(Posicione("GU9",1,xFilial("GU9")+cSelDC,"GU9_NMREG")) + "; " + STR0629 + " '" + cDCDest + "' " + STR0625 // "Destinatário" ### "não possui CEP."
									EndIf
								EndIf
		
								If !Empty(cCepDes) .AND. s_GFEGUL
		
									GULLocaliza(cCepDes,cSelDC,@cDsDest,@lRotaVldDes,@lFxCEPDes)
		
								EndIf
		
								If !lFxCEPDes
									GU7->(dbSetOrder(01))
									If GU7->(dbSeek(xFilial("GU7")+cCidDes))
										GU9->(dbSetOrder(01))
										If GU9->(dbSeek(xFilial("GU9")+cSelDC))
											If GU9->GU9_DEMCID == "1" .And. AllTrim(GU9->GU9_CDUF) == AllTrim(GU7->GU7_CDUF) .And. GU9->GU9_SIT == "1"
												lRotaVldDes := .T.
												lDemaisDes:= .T.
												cDsDest := STR0605 + " ("+GU9->GU9_CDUF+")" //"Demais Cidades"
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						If Empty(cSelDC)
							cSelDC := (cAliasSTA)->GV8_NRREOR
							cDsDest := (cAliasSTA)->GU9_NMREG
						EndIf
						oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + cSelDC + " - " + AllTrim(cDsDest) + IIf(lRegDC," - " + STR0630, "") + ")-> OK", STR0606 + " (" + cSelDC + " - " + AllTrim(cDsDest) + IIf(lRegDC,STR0630, "") + ") -> " + STR0609)) //"Correspondente" ### "Não localizada" ### "INVALIDO"
					CASE cTPDest == "4" //Pais/UF // ESTA EM SQL
						GU7->(dbSetOrder(01))
						If GU7->(dbSeek(xFilial("GU7")+cCidDes))
							cDsDest := AllTrim(SubStr(Posicione("SYA",1,xFilial("SYA")+(cAliasSTA)->GV8_CDPADS,"YA_DESCR"),1,18))+" - "+GU7->GU7_CDUF
							If GU7->GU7_CDUF == (cAliasSTA)->GV8_CDUFDS .And. GU7->GU7_CDPAIS == (cAliasSTA)->GV8_CDPADS
								lRotaVldDes := .T.								
							EndIf
						ElseIf nloop > 0 .And. GU7->(dbSeek(xFilial("GU7")+cCidOri))
							cDsDest := AllTrim(SubStr(Posicione("SYA",1,xFilial("SYA")+(cAliasSTA)->GV8_CDPAOR,"YA_DESCR"),1,18))+" - "+GU7->GU7_CDUF
							If GU7->GU7_CDUF == (cAliasSTA)->GV8_CDUFOR .And. GU7->GU7_CDPAIS == (cAliasSTA)->GV8_CDPAOR
								lRotaVldDes := .T.
							EndIf
						EndIf
						oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + cDsDest + ")-> OK", STR0607)) //"Correspondente" ### "Diferente / cidade não localizada -> INVALIDO"
					CASE cTPDest == "5" //Destinatário
						If !lODOriginal
							cDest := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDREM")
						Else
							cDest := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDDEST")
						EndIf
						
						cDsDest := AllTrim(Posicione("GU3",1,xFilial("GU3")+cDest,"GU3_NMEMIT"))

						If (lSimulacao .AND. iTipoSim == 0)
							  If cDest == (cAliasSTA)->GV8_CDDEST .And. ;
							  ((Empty(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC")) .And. GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC") != PadR("0", TamSX3("GW1_ENTNRC")[1])) .Or. (Alltrim(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC")) == Alltrim((cAliasSTA)->GU3_NRCID)))

								lRotaVldDes := .T.
	
								If (nPos := AScan(aChvRot,{|x| x[1] == cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA})) != 0
									aChvRot[nPos][2]++
								Else
									AAdd(aChvRot, {cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA, 1})
								EndIf
	
							Endif
	
						Else
							If lGW1Enc
								If IIf(nLoop == 0, cGW1CDDEST == (cAliasSTA)->GV8_CDDEST, cGW1CDREM == (cAliasSTA)->GV8_CDDEST)
									lRotaVldDes := .T.
	
									If (nPos := AScan(aChvRot,{|x| x[1] == cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA})) != 0
										aChvRot[nPos][2]++
									Else
										AAdd(aChvRot, {cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA, 1})
									EndIf
	
								Endif
							EndIf
	
						EndIf
						oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + AllTrim(cDest) + " - " + cDsDest + ")-> OK", STR0603 + " (" + AllTrim(cDest) + " - " + cDsDest + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
				ENDCASE
				oGFEXFBFLog:setTexto(CRLF)
			EndIf

			//caso rota seja invalida, porem duplo sentido, loop verifica sentido inverso
			If (!lRotaVld .Or. !lRotaVldDes) .And. (cAliasSTA)->GV8_DUPSEN == "1" .And. nLoop++ == 0
				
				lGFEXFB14 := .T.
				If lPEXFB14
					lGFEXFB14 := ExecBlock("GFEXFB14")			
				EndIf	
								
				If lGFEXFB14		
					cCidOri := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")
					cCidDes := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM")
					
					//inverte os ceps
					cNewCepOri := Posicione("GU3",1,xFilial("GU3")+cGW1CDDEST,"GU3_CEP")
					cNewCepDes := Posicione("GU3",1,xFilial("GU3")+cGW1CDREM,"GU3_CEP")
					
					cRegTab := (cAliasSTA)->GV8_NRREDS
					
					lODOriginal	:= .F. // .T. - Origem e destino original / .F. - Inverte Origem e Destino
					
					cTpOrig := (cAliasSTA)->GV8_TPDEST
					cTPDest := (cAliasSTA)->GV8_TPORIG
					
					If lPEXFB12
				   		aRetFilSQL := ExecBlock("GFEXFB12",.f.,.f.,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM"),; 
				   												GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")})
					EndIf												
					Loop
				EndIf
			EndIf
			
			lODOriginal := .T.

			//rota invalida e' excluida
			If !lRotaVld .Or. !lRotaVldDes
				If (nPos := AScan(aChvRot,{|x| x[1] == cCdTrp + nNrTab + nNrNeg + (cAliasSTA)->GV8_NRROTA})) != 0
					ADel(aChvRot,nPos)
					ASize(aChvRot,Len(aChvRot)-1)
				EndIf
			Else
				//grava descricao da rota
				If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
					GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
					If !GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM1, 3,{	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
																		(cAliasSTA)->GVA_CDEMIT,;
																		(cAliasSTA)->GVA_NRTAB,;
																		(cAliasSTA)->GV9_NRNEG,;
																		(cAliasSTA)->GV8_NRROTA})
						if lTabTemp
							/*Caso a função SelTabFrete seja removida, permanecendo apenas esta, deve-se testar
							  o cálculo com tabelas vínculo utilizando tabela temporária (parâmetro MV_GFEBRF=0).
							*/
							
							RecLock((cTRBSIM),.T.)
							(cTRBSIM)->NRROM   := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")
							(cTRBSIM)->DOCS    := cDoc
							(cTRBSIM)->CDTRP   := cCdTrp
							(cTRBSIM)->NRTAB   := nNrTab
							(cTRBSIM)->NRNEG   := nNrNeg
							(cTRBSIM)->NRCALC  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")

							(cTRBSIM)->CDCLFR  := cCdClfr
							(cTRBSIM)->CDTPOP  := cCdTpop

							(cTRBSIM)->NRROTA  := (cAliasSTA)->GV8_NRROTA
							(cTRBSIM)->DESROT  := STR0608 + ": " + cDsOrig + " x " + STR0611 + ": " + cDsDest
							(cTRBSIM)->DTVALI  := STOD((cAliasSTA)->GV9_DTVALI)
							(cTRBSIM)->DTVALF  := STOD((cAliasSTA)->GV9_DTVALF)
							(cTRBSIM)->VLFRT   := 0
							(cTRBSIM)->PRAZO   := 0
							(cTRBSIM)->TPTAB   := (cAliasSTA)->NOR_VIN
							(cTRBSIM)->EMIVIN  := (cAliasSTA)->GVA_CDEMIT
							(cTRBSIM)->TABVIN  := (cAliasSTA)->GVA_NRTAB
							(cTRBSIM)->ATRFAI  := (cAliasSTA)->GV9_ATRFAI
							(cTRBSIM)->QTKGM3  := (cAliasSTA)->GV9_QTKGM3
							(cTRBSIM)->UNIFAI  := (cAliasSTA)->GV9_UNIFAI
							(cTRBSIM)->TPLOTA  := (cAliasSTA)->GV9_TPLOTA
							(cTRBSIM)->VALROT := "SIM"
							(cTRBSIM)->ROTSEL := "1"
							(cTRBSIM)->(MsUnLock())
						Else
							AADD(aTRBSIM1,{ GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")											,;	//"NRROM"   ,;
											cDoc														,;	//"DOCS"   ,;
											cCdTrp														,; 	//"CDTRP"  ,;
											nNrTab														,;	//"NRTAB"  ,;
											nNrNeg														,;	//"NRNEG"  ,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")											,;	//"NRCALC" ,;
											cCdClfr													,;	//"CDCLFR" ,;
											cCdTpop													,;	//"CDTPOP" ,;
											Space(04)													,;	//"CDFXTV" ,;
											Space(10)													,;	//"CDTPVC" ,;
											(cAliasSTA)->GV8_NRROTA									,;	//"NRROTA" ,;
											STR0608 + ": " + cDsOrig + " x " + STR0611 + ": " + cDsDest	,;	//"DESROT" ,;
											STOD((cAliasSTA)->GV9_DTVALI)							,;	//"DTVALI" ,;
											STOD((cAliasSTA)->GV9_DTVALF)							,;	//"DTVALF" ,;
											0															,;	//"VLFRT"  ,;
											0															,;	//"PRAZO"  ,;
											(cAliasSTA)->NOR_VIN										,;	//"TPTAB"  ,;
											(cAliasSTA)->GVA_CDEMIT									,;	//"EMIVIN" ,;
											(cAliasSTA)->GVA_NRTAB									,;	//"TABVIN" ,;
											Space(06)													,;	//"NRTAB1" ,;
											(cAliasSTA)->GV9_ATRFAI									,;	//"ATRFAI" ,;
											(cAliasSTA)->GV9_QTKGM3									,;	//"QTKGM3" ,;
											(cAliasSTA)->GV9_UNIFAI									,;	//"UNIFAI" ,;
											(cAliasSTA)->GV9_TPLOTA									,;	//"TPLOTA" ,;
											.F.															,;	//"DEMCID" ,;
											0															,;	//"QTFAIXA",;
											Space(13)													,;	//"TPVCFX" ,;
											Space(01)													,;	//"SELEC"  ,;
											"SIM"														,;	//"VALROT" ,;
											Space(03)													,;	//"VALFAI" ,;
											Space(03)													,;	//"VALTPVC",;
											Space(03)													,;	//"VALDATA",;
											"1"															,;	//"ROTSEL" ,;
											"0"															})	//"ERRO"}							
						EndIf
					EndIf
				EndIf

				if lTabTemp
					/*Caso a função SelTabFrete seja removida, permanecendo apenas esta, deve-se testar
					  o cálculo com tabelas vínculo utilizando tabela temporária (parâmetro MV_GFEBRF=0).
					*/
					RecLock(cTRBSTF,.T.)
					(cTRBSTF)->NRROM  := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")
					(cTRBSTF)->DOCS   := cDoc
					(cTRBSTF)->CDTRP  := cCdTrp //-> emitente que sera utilizado nas validacoes
					(cTRBSTF)->NRTAB  := nNrTab  //-> tabela que sera utilizada nas validacoes
					(cTRBSTF)->NRNEG  := nNrNeg
					(cTRBSTF)->NRCALC := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
					(cTRBSTF)->CDCLFR := cCdClfr
					(cTRBSTF)->CDTPOP := cCdTpop
					(cTRBSTF)->NRROTA := (cAliasSTA)->GV8_NRROTA
					(cTRBSTF)->DTVALI := STOD((cAliasSTA)->GV9_DTVALI)
					(cTRBSTF)->DTVALF := STOD((cAliasSTA)->GV9_DTVALF)
					(cTRBSTF)->VLFRT  := 0
					(cTRBSTF)->PRAZO  := 0 //tarifas
					(cTRBSTF)->TPTAB  := (cAliasSTA)->NOR_VIN
					(cTRBSTF)->EMIVIN := (cAliasSTA)->GVA_CDEMIT // Recebe o proprio transportador
					(cTRBSTF)->TABVIN := (cAliasSTA)->GVA_NRTAB  // Recebe a propria tabela
					(cTRBSTF)->ATRFAI := (cAliasSTA)->GV9_ATRFAI
					(cTRBSTF)->QTKGM3 := (cAliasSTA)->GV9_QTKGM3
					(cTRBSTF)->UNIFAI := (cAliasSTA)->GV9_UNIFAI
					(cTRBSTF)->TPLOTA := (cAliasSTA)->GV9_TPLOTA
					(cTRBSTF)->TPROTA := GFEXBEGetP((cAliasSTA)->GV8_TPORIG,(cAliasSTA)->GV8_TPDEST)
					(cTRBSTF)->DESROT := STR0608 + ": " + cDsOrig + " x " + STR0611 + ": " + cDsDest
					(cTRBSTF)->(MsUnLock())
				Else
					AADD(aTRBSTF1,{GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU"),;                                            //NRROM"  ,; //Numero do Romaneio
									cDoc,;                                                        //DOCS"   ,; //Documentos de Carga
									cCdTrp,;                          						         //CDTRP"  ,; //Codigo do Transportador (Base ou Vinculo)
									nNrTab,;                      					                //NRTAB"  ,; //Numero da Tabela (Base ou Vinculo)
									nNrNeg,;                          					            //NRNEG"  ,; //Negociacao (Base ou Vinculo)
									GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;                                           //NRCALC" ,; //Numero do Calculo
									cCdClfr,;                           				            //CDCLFR" ,; //Classificacao de Frete
									cCdTpop,;                                				         //CDTPOP" ,; //Tipo Operacao
									Space(04) ,;                                                  //CDFXTV" ,; //Seq. Faixa
									Space(10) ,;                                                  //CDTPVC" ,; //Tipo de Veiculo
									(cAliasSTA)->GV8_NRROTA,;                                     //NRROTA" ,; //Rota
									STR0608 + ": " + cDsOrig + " x " + STR0611 + ": " + cDsDest,; //DESROT" ,; //Descricao da Rota
									STOD((cAliasSTA)->GV9_DTVALI),;                               //DTVALI" ,; //Data Vigencia Inicio
									STOD((cAliasSTA)->GV9_DTVALF),;                               //DTVALF" ,; //Data Vigencia Fim
									0 ,;                                                          //VLFRT"  ,; //Valor Frete
									0 ,;                                                          //PRAZO"  ,; //Prazo Entrega
									(cAliasSTA)->NOR_VIN,;                                        //TPTAB"  ,; //Tipo Tabela (1=Normal; 2=Vinculo)
									(cAliasSTA)->GVA_CDEMIT,;                                     //EMIVIN" ,; //Emitente Vinculo (Original)
									(cAliasSTA)->GVA_NRTAB,;                                      //TABVIN" ,; //Tabela Vinculo (Original)
									Space(06),;                                                   //NRTAB1" ,; //Não usado. Mantido por compatibilidade.
									(cAliasSTA)->GV9_ATRFAI,;                                     //ATRFAI" ,; //Atributo da Faixa
									(cAliasSTA)->GV9_QTKGM3,;                                     //QTKGM3" ,; //K3/M3 - Fator de Cubagem
									(cAliasSTA)->GV9_UNIFAI,;                                     //UNIFAI" ,; //Unidade da Faixa
									(cAliasSTA)->GV9_TPLOTA,;                                     //TPLOTA" ,; //Tipo Lotacao
									Space(13),;                                                   //TPVCFX" ,; //Grava se foi selecionada uma faixa ou um tipo de veiculo, usado na Simulação do Calculo de frete
									.F.,;                                                         //DEMCID" ,; //Indica se rota eh demais cidades
									0,;                                                           //QTFAIXA",; //Quantidade usada para determinação da faixa, usada como quantidade para calculo quando a rota eh selecionada
									Space(01),;                                                   //CONTPZ" ,; //Indica a forma de contagem do prazo, dias corridos, uteis ou horas
									0,;                                                           //QTCOTA" ,; //Cota Do tipo de Veículo, para validação
									0,;                                                           //VLALUG" ,; //Valor da locação do tipo Veículo, para validação
									0,;                                                           //FRQKM"  ,;  //Franquia em km, para validação
									0,;                                                           //VLKMEX" ,;  //Valor excedente da franquia, para validação
									'0',;                                                         //ERRO"}
									GFEXBEGetP((cAliasSTA)->GV8_TPORIG,(cAliasSTA)->GV8_TPDEST)})  //"TPROTA" prioridade da rota em caso de composição
				EndIf

				If lDemaisOri
					aAdd(aRotDemOri,{(cAliasSTA)->GVA_CDEMIT,(cAliasSTA)->GVA_NRTAB,(cAliasSTA)->GV9_NRNEG,(cAliasSTA)->GV8_NRROTA})
					lDemaisOri := .F.
				EndIf

				If lDemaisDes
					aAdd(aRotDemDes,{(cAliasSTA)->GVA_CDEMIT,(cAliasSTA)->GVA_NRTAB,(cAliasSTA)->GV9_NRNEG,(cAliasSTA)->GV8_NRROTA})
					lDemaisDes := .F.
				EndIf

				If lCidOri
					aAdd(aRotCidOri,{(cAliasSTA)->GVA_CDEMIT,(cAliasSTA)->GVA_NRTAB,(cAliasSTA)->GV9_NRNEG,(cAliasSTA)->GV8_NRROTA})
					lCidOri := .F.
				EndIf

				If lCidDes
					aAdd(aRotCidDes,{(cAliasSTA)->GVA_CDEMIT,(cAliasSTA)->GVA_NRTAB,(cAliasSTA)->GV9_NRNEG,(cAliasSTA)->GV8_NRROTA})
					lCidDes := .F.
				EndIf
			EndIf

			nLoop := 0

			(cAliasSTA)->(dbSkip())
		EndDo

		If Select(cAliasSTA) > 0
			(cAliasSTA)->(dbCloseArea())
		EndIf
		//Caso array não esteja vazio indica que há rotas por remetente/destinatário que devem ser priorizadas.
		If !Empty(aChvRot) .AND. !(lSimulacao .AND. iTipoSim == 0)

			oGFEXFBFLog:setTexto(CRLF)

			If AScan(aChvRot, {|x| x[2] == 2}) != 0
				oGFEXFBFLog:setTexto("        Foram encontradas rotas válidas por Remetente e Destinatário, elas serão priorizadas na seleção, " + ;
				"as demais rotas serão eliminadas." + CRLF)
				nX := 1
				While nX <= Len(aChvRot)
					If aChvRot[nX][2] == 2
						nX++
					Else
						ADel(aChvRot,nX)
						ASize(aChvRot,Len(aChvRot)-1)
					EndIf
				EndDo
			Else
				oGFEXFBFLog:setTexto("        Foram encontradas rotas válidas por Remetente ou Destinatário, elas serão priorizadas na seleção, " + ;
				"as demais rotas serão eliminadas." + CRLF)
			EndIf

			//Percorre rotas pré-selecionadas e apaga as que não pertencem as rotas por remetente/destinatário	
			GFEXFB_BORDER(lTabTemp,cTRBSTF,01,2) 				
			GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 		
			While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2)	//!(cTRBSTF)->(EOF() )
				oGFEXFBFLog:setTexto(CRLF + "          Transp " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP")) + ;
							"; Tabela " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")) + ;
							"; Negoc. " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")) + ;
							"; Rota " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA")) + ;
							"; Tp.Tab. " + If(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPTAB")=="1", STR0598, STR0599))
				
				If (nPos := AScan(aChvRot,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA")})) == 0
					if lTabTemp
						RecLock(cTRBSTF, .F.)
						(cTRBSTF)->(dbDelete())
						(cTRBSTF)->(MsUnlock())
					EndIf
					oGFEXFBFLog:setTexto(" -> ELIMINADA" + CRLF)
				Else
					AADD(aTRBSTF2,{	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROM"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DOCS"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRCALC"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDCLFR"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPOP"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPVC"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DESROT"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DTVALI"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DTVALF"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLFRT"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPTAB"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB1"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"ATRFAI"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTKGM3"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"UNIFAI"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPLOTA"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPVCFX"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DEMCID"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTFAIXA"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CONTPZ"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTCOTA"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLALUG"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"FRQKM"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLKMEX"),;
									'0',;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPROTA")})
					oGFEXFBFLog:setTexto(" -> PRIORIZADA" + CRLF)
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
			EndDo
			if !lTabTemp
				IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
				aTRBSTF1 := Nil
				aTRBSTF1 := aClone(aTRBSTF2)
			EndIf

		EndIf
		if !lTabTemp
			aTRBSTF3 := aClone(aTRBSTF1)
			aSort(aTRBSTF3  ,,,{|x,y| x[18]+x[19]+x[05]+x[11]      < y[18]+y[19]+y[05]+y[11]})
			IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
			aTRBSTF1 := {}
		EndIf

		//------------------------------------------------------------------------------------------
		// Se existirem rotas específicas, deve verificar se existem rotas do tipo demais cidades
		// para o mesmo transportador/tabela de frete/negociação, e removê-las da tabela temporária.
		// O sistema deve considerar, para efeito de cálculo, sempre as rotas mais específicas.
		//------------------------------------------------------------------------------------------
		If Len(aRotCidOri) > 0
			For nX := 1 to len(aRotDemOri)
				GFEXFB_BORDER(lTabTemp,cTRBSTF,03,2) 
				// Verifica se a rota ainda não foi eliminada
				if GFEXFB_CSEEK(lTabTemp, cTRBSTF, @aTRBSTF3, 2,{aRotDemOri[nX,1], aRotDemOri[nX,2], aRotDemOri[nX,3], aRotDemOri[nX,4]})
					// Verifica se a rota demais cidadades diz respeito ao mesmo transportador/tab. frete/negociação
					If AScan(aRotCidOri,{|x| x[1]+x[2]+x[3] == aRotDemOri[nX,1]+aRotDemOri[nX,2]+aRotDemOri[nX,3]}) > 0
						GV8->(dbSetOrder(1))
						If GV8->(dbSeek(xFilial("GV8") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")))
							GU9->(dbSetOrder(1) )
							If GU9->(dbSeek(xFilial("GU9")+GV8->GV8_NRREOR) )
								If GU9->GU9_DEMCID == '1'
									// Elimina a rota demais cidades
									If lTabTemp
										RecLock(cTRBSTF,.F.)
										(cTRBSTF)->(DbDelete())
										(cTRBSTF)->(MsUnlock())
									Else
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO", '1')
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf

		If Len(aRotCidDes) > 0
			For nX := 1 to len(aRotDemDes)
				GFEXFB_BORDER(lTabTemp,cTRBSTF,03,2) 
				// Verifica se a rota ainda não foi eliminada
				if GFEXFB_CSEEK(lTabTemp, cTRBSTF, @aTRBSTF3, 2,{aRotDemDes[nX,1], aRotDemDes[nX,2], aRotDemDes[nX,3], aRotDemDes[nX,4]})
					// Verifica se a rota demais cidadades diz respeito ao mesmo transportador/tab. frete/negociação
					If AScan(aRotCidDes,{|x| x[1]+x[2]+x[3] == aRotDemDes[nX,1]+aRotDemDes[nX,2]+aRotDemDes[nX,3]}) > 0
						dbSelectArea("GV8")
						GV8->(dbSetOrder(1))
						If GV8->(dbSeek(xFilial("GV8") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")))
							GU9->(dbSetOrder(1) )
							If GU9->(dbSeek(xFilial("GU9")+GV8->GV8_NRREDS) )
								If GU9->GU9_DEMCID == '1'
									// Elimina a rota demais cidades
									If lTabTemp
										RecLock(cTRBSTF,.F.)
										(cTRBSTF)->(DbDelete())
										(cTRBSTF)->(MsUnlock())
									Else
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO", '1')
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nX
		EndIf

		//percorre tabelas pre-selecionadas
		oGFEXFBFLog:setTexto(CRLF + STR0073 + CRLF) //"    # Filtrando tabelas pre-selecionadas - FAIXAS/TIPO VEICULOS: "
		GFEXFB_BORDER(lTabTemp,cTRBSTF,03,2) //
		GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF3, 2) 
		While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF3, 2) 

			if !lTabTemp
				if GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO") == '1'
					GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
					Loop
				EndIf
			EndIf
			
			nQtPrazo := 0

			oGFEXFBFLog:setTexto(CRLF + STR0074 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN") + ;
							STR0067 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN") + ;
							STR0068 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") +  ; 
							STR0069 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA") + ;
							STR0075 + If(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TPTAB")=="1", STR0076, STR0077) + CRLF) //"      Transp. "###"; Tabela "###"; Negoc. "//"; Rota "###"; Tp.Tab. "###"Normal"###"Vinculo"
			
			lTemCrgCmp := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5, "PERCOUT") != 0
			If !lTemCrgCmp
				nPesCub := GFEPesoCub(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"QTKGM3"), ;
									  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR"), ;
									  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"))
			Else
				nPesCub := GFEPesoCub(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"QTKGM3"), ;
									  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR"), ;
									  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"))
				GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUBORG",nPesCub)
				nPesoCubCrg := GFEPesoCub(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"QTKGM3"), ;
									     GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR"), ;
									     GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"), ;
									     GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"))
				If nPesCub > 0 .And. nPesoCubCrg > 0 .And. nPesoCubCrg > GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") .And. nPesoCubCrg > nPesCub
					If GetNewPar("MV_CRIRAT", "5") == '1'
						GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5, "PERCOUT" , (nPesoCubCrg - nPesCub) / ( nPesoCubCrg ) )
					EndIf
					nPesCub := nPesoCubCrg
				EndIf
				
			EndIf

			If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TPLOTA") == "1"  //tipo lotacao : 1=carga fracionada
				//***************
				//*VALIDA FAIXAS*
				//***************
				nQtdFaixa := 0
				nPesCub   := 0

				oGFEXFBFLog:setTexto(STR0612 + GFEFldInfo("GV9_ATRFAI",IIf(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ATRFAI")=="10","8",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ATRFAI")),2)) //"        Faixa baseada em "
				
				nQtdFaixa := GFEQtdeComp(	GFEXFB_5CMP(.F.     ,        , @aTRBGRB3, 4,"NRAGRU"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ATRFAI"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")  ,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") ,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR") ,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ") ,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"QTKGM3"),;
											@nPesCub         ,; // Peso cubado a ser atualizado pela função
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"UNIFAI"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
											0,;
											"1",;
											If(!Empty(cTpLocEntr), "1",""),;
											GFEXFBLOCE(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")),;
											.T.,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"))

				oGFEXFBFLog:setTexto(" " + cValToChar(nQtdFaixa) + CRLF)

				cCodFaixa := ""
				cTodFaixa := ""
				//seleciona faixa valida para o valor encontrado
				GV7->(dbSetOrder(01))
				GV7->(dbSeek(xFilial("GV7")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),.T.))
				While !GV7->(Eof()) .And. ;
						GV7->GV7_FILIAL == xFilial("GV7")   .And. GV7->GV7_CDEMIT == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTRP") .And.;
						GV7->GV7_NRTAB  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB") .And. GV7->GV7_NRNEG  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG")
	
					If GV7->GV7_QTFXFI == 0
						cTodFaixa := GV7->GV7_CDFXTV
						cCodFaixa := GV7->GV7_CDFXTV
					EndIf
					
					If nQtdFaixa <= GV7->GV7_QTFXFI
						cCodFaixa		:= GV7->GV7_CDFXTV
						Exit
					EndIf

					GV7->(dbSkip())
				EndDo

				//grava faixa para tabela de frete se houver tarifa para a tabela de frete
				If !Empty(cCodFaixa)

					// Início Ponto de Entrada Engepack
					lTariVali := .T.
					If lPEXFB01
						lTariVali := ExecBlock("GFEXFB01",.f.,.f.,{cCodFaixa})
					EndIf
					// Fim Ponto de Entrada Engepack

					GV6->(dbSetOrder(01))
					If GV6->(dbSeek(xFilial("GV6")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG")+cCodFaixa+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA"))) .And. lTariVali

						If GV6->GV6_CONSPZ == "0" // Tabela de prazos
							aTabPrazo    := GFEPrazoTre(xFilial("GWU"), ; 
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC") , ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")  , ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ"))

							// Classificação de Frete
							aTabPrazo[10] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")

							//////// CEP DE/ORIGEM ////////
							If !Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO"))
								aTabPrazo[13] := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO")
							Else
								aTabPrazo[13] := Posicione("GU3",1,xFilial("GU3")+aTabPrazo[1],"GU3_CEP")
							EndIf
					           
							//////// CEP DE/ORIGEM ////////

							//////// CEP PARA/DESTINO ////////
							If !Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD"))
								aTabPrazo[14] := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD")
							Else
								aTabPrazo[14] := Posicione("GU3",1,xFilial("GU3")+aTabPrazo[2],"GU3_CEP")
							EndIf
							//////// CEP PARA/DESTINO ////////

							aRetTabPrazo := GFETabPrazo(aTabPrazo)
							If aRetTabPrazo[5]
								nQtPrazo := Posicione("GUN",1,xFilial("GUN")+aRetTabPrazo[3],"GUN_PRAZO")
								cContPz  := Posicione("GUN",1,xFilial("GUN")+aRetTabPrazo[3],"GUN_TPPRAZ") // 0=Dias Corridos; 1=Dias Uteis; 2=Horas

								If cContPz == "2"
									nQtPrazo := nQtPrazo * 24
								EndIf
							Else
								nQtPrazo := Nil //Não há tabela de prazos cadastrada
							EndIf

						ElseIf GV6->GV6_CONSPZ == "1" // Tarifas

							nQtPrazo := GV6->GV6_QTPRAZ
							cContPz  := GV6->GV6_CONTPZ

							If GV6->GV6_TPPRAZ == "2"
								nQtPrazo := GV6->GV6_QTPRAZ * 24
							EndIf
						EndIf
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDFXTV",cCodFaixa)
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"PRAZO" ,nQtPrazo)
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TPVCFX","FAIXAS")
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CONTPZ",cContPz)
						If lSimulacao .AND. iTipoSim == 0 
							GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
							If GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM1, 3,{ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"), ;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR"), ;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPOP"), ;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"), ;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"), ;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") , ;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
								GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM1, 3,"VALFAI","SIM")
								GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM1, 3,"QTFAIXA", nQtdFaixa)
							EndIf
						EndIf
						oGFEXFBFLog:setTexto("      *** " + STR0613 + cCodFaixa + " (" + STR0614 + cValToChar(nQtdFaixa) + ")" + CRLF) //"Faixa selecionada " ### "Qtd "
					Else
						oGFEXFBFLog:setTexto("      *** " + STR0615 + cCodFaixa + " (" + STR0614 + cValToChar(nQtdFaixa) + ")." + CRLF) //"Não existe tarifa para a faixa " ### "Qtd "
					EndIf
				Else
					oGFEXFBFLog:setTexto("      *** " + STR0616 + STR0614 + cValToChar(nQtdFaixa) + ")." + CRLF)//"Não existem faixas válidas para a tabela (" ### "Qtd "
				EndIf

				//exclui tabela de frete selecionada caso nao haja faixa
				If Empty(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDFXTV"))
					If lSimulacao .AND. iTipoSim == 0
						GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
						If GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM1, 3,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"), ; 
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPOP"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") , ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM1, 3,"VALFAI","NAO")
						EndIf
					Else
						IF lTabTemp
							RecLock(cTRBSTF,.F.)
							(cTRBSTF)->(dbDelete())
							(cTRBSTF)->(MsUnLock())
						Else
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO","1")
						EndIf
					EndIf
				Else
					GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"QTFAIXA",nQtdFaixa)
					GFEAddTodFx(cTodFaixa,cCodFaixa)
				EndIf
			Else //tipo lotacao : 2=carga fechada  ou 3 = Veículo Dedicado
				If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TPLOTA") == "3"
					lTpLota3 := .T.
				EndIf
				//*********************
				//*VALIDA TIPO VEICULO*
				//*********************
				// Início Ponto de Entrada Harley Davidson
				lSmlVei := .F.
				If lPEXFB03
					lSmlVei := ExecBlock("GFEXFB03",.f.,.f.,{lSimulacao})
				EndIf
				cTodFaixa := ""
				cCodFaixa := ""
				
				// Fim Ponto de Entrada Harley Davidson
				//posiciona no agrupador para selecionar cod. tipo veiculo
				GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
				If GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")})
					//Se não for o primeiro trecho ou Se o parâmetro do tipo de veículo para calculo  
					//for diferente de 1 utiliza o veículo informado no trecho.
					If nI == 1 .Or. p_TpVeic == '1'
						//Se não houver tipo de veiculo informado no agrupador, utiliza o do trecho				
						cCdTpVei := If(Empty(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPVC") ),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPVC"),GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPVC") )
					Else
						cCdTpVei := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPVC")
						If Empty(cCdTpVei)
							cCdTpVei := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPVC")
						EndIF
					EndIf

					If !Empty(cCdTpVei) .Or. lSmlVei
						//percorre faixa/tp veiculo tabela de frete procurando o mesmo tipo de veiculo
						GV7->(dbSetOrder(01))
						GV7->(dbSeek( xFilial("GV7")+;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTRP")+;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB")+;
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),.T.))
						While !GV7->(Eof()) .And. ;
								GV7->GV7_FILIAL == xFilial("GV7")   .And. ;
								GV7->GV7_CDEMIT == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTRP") .And.;
								GV7->GV7_NRTAB  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB") .And. ;
								GV7->GV7_NRNEG  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG")

							// Início Ponto de Entrada Engepack
							lTariVali := .T.
							If lPEXFB01
								lTariVali := ExecBlock("GFEXFB01",.f.,.f.,{GV7->GV7_CDFXTV})
							EndIf
							// Fim Ponto de Entrada Engepack
							If ( ( Empty(GV7->GV7_CDTPVC) .Or. cCdTpVei == GV7->GV7_CDTPVC) .And. lTariVali) .Or. lSmlVei
								If Empty(GV7->GV7_CDTPVC)
									cTodFaixa := GV7->GV7_CDFXTV
								EndIf
								cCodFaixa := GV7->GV7_CDFXTV

								// Verifica o prazo
								GV6->(dbSetOrder(01))
								If GV6->(dbSeek(xFilial("GV6")+;
										  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTRP")+;
										  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB")+;
										  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG")+;
										  GV7->GV7_CDFXTV+;
										  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")))
									If GV6->GV6_CONSPZ == "0" // Tabela de prazos
										aTabPrazo    := GFEPrazoTre(xFilial("GW1"), ;
																	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), ;
																	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), ;
																	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC") , ;
																	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")  , ;
																	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ"))
										aTabPrazo[10] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
										
										//////// CEP DE/ORIGEM ////////
										If !Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO"))
											aTabPrazo[13] := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPO")
										Else
											aTabPrazo[13] := Posicione("GU3",1,xFilial("GU3")+aTabPrazo[1],"GU3_CEP")
										EndIf
								           
										//////// CEP DE/ORIGEM ////////
			
										//////// CEP PARA/DESTINO ////////
										If !Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD"))
											aTabPrazo[14] := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CEPD")
										Else
											aTabPrazo[14] := Posicione("GU3",1,xFilial("GU3")+aTabPrazo[2],"GU3_CEP")
										EndIf
										//////// CEP PARA/DESTINO ////////

										aRetTabPrazo := GFETabPrazo(aTabPrazo)
										If aRetTabPrazo[5]
											nQtPrazo := Posicione("GUN",1,xFilial("GUN")+aRetTabPrazo[3],"GUN_PRAZO")
											cContPz  := Posicione("GUN",1,xFilial("GUN")+aRetTabPrazo[3],"GUN_TPPRAZ") // 0=Dias Corridos; 1=Dias Uteis; 2=Horas

											If cContPz == "2"
												nQtPrazo := nQtPrazo * 24
											EndIf
										Else
											nQtPrazo := Nil //Não há tabela de prazos cadastrada
										EndIf

									ElseIf GV6->GV6_CONSPZ == "1" // Tarifas

										nQtPrazo := GV6->GV6_QTPRAZ
										cContPz  := GV6->GV6_CONTPZ

										If GV6->GV6_TPPRAZ == "2"
											nQtPrazo := GV6->GV6_QTPRAZ * 24
										EndIf
									EndIf

									//grava tipo veiculo para tabela de frete
									If ( GV7->GV7_CDFXTV == cTodFaixa .And. Empty(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPVC")) ) .Or. cCdTpVei == GV7->GV7_CDTPVC
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPVC", cCdTpVei)
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDFXTV", GV7->GV7_CDFXTV)
										If lExiVLALUG
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"QTCOTA", GV7->GV7_QTCOTA)
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"VLALUG", GV7->GV7_VLALUG)
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"FRQKM" , GV7->GV7_FRQKM)
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"VLKMEX", GV7->GV7_VLKMEX)
										EndIf
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"PRAZO" , nQtPrazo)
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CONTPZ" , cContPz)
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TPVCFX", "VEICULOS")
									EndIf
	
									If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
										GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
										If GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM1, 3,{ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"), ;
																						  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR"), ;
																						  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPOP"), ;
																						  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"), ;
																						  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"), ;
																						  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"), ;
																						  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
											GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM1, 3,"VALTPVC","SIM")
										EndIf
									EndIf

									oGFEXFBFLog:setTexto("      *** " + STR0613 + cCodFaixa + STR0617 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDFXTV") + "). " + STR0618 + cValtoChar(nQtPrazo) + CRLF) //"Faixa selecionada " ### " (Tipo Veiculo " ### "Prazo (em horas): "
								EndIf
							EndIf

							GV7->(dbSkip())
						EndDo
					EndIf
				EndIf

				//exclui rota/tipo de veículo selecionado caso nao haja tipo veiculo
				If Empty(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPVC"))

					//Pode não existir tarifa para faixa/tipo de veículo ou
					//Pode não haver grupos de entrega (???) para a TABELA.
					If !Empty(cCdTpVei) 
						oGFEXFBFLog:setTexto("      *** Não existe tarifa para a faixa (Tipo veículo). " + CRLF) //"Não existe tarifa para a faixa (Tipo de veículo " ### ").
					Else
						oGFEXFBFLog:setTexto("      *** " + STR0619 + CRLF) //"Nao existem faixas de tipo de veículo válidas para a tabela."
					EndIf

					If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
						GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
						If GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM1, 3,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPOP"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"), ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") , ;
																		 GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM1, 3,"VALTPVC","NAO")
						EndIf
					Else
						if lTabTemp
							RecLock(cTRBSTF,.F.)
							(cTRBSTF)->(dbDelete())
							(cTRBSTF)->(MsUnLock())
						Else
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO","1")
						EndIf
					EndIf

				Else
					If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TPLOTA") $ "2;3"
	
						AAdd(aDelTpVc,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROM"), ;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRTAB"), ; 
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"), ;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
					EndIf
					GFEAddTodFx(cTodFaixa,GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDFXTV"))
				EndIf
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
		EndDo
		
		aSort(aTRBROT1,,,{|x,y| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + STRZERO(x[10],6) + STRZERO(x[11],6) < y[1] + y[2] + y[3] + y[4] + y[5] + y[6] + STRZERO(y[10],6) + STRZERO(y[11],6) })
		
		
		//************************
		//*VALIDA DATA VIGENCIA  *
		//************************
		If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica

			if !lTabTemp
				aTRBSIM2 := aClone(aTRBSIM1)
				aSort(aTRBSIM1  ,,,{|x,y| x[01]+x[04]+x[05]+x[06]+x[11]+x[28]      	< y[01]+y[04]+y[05]+y[06]+y[11]+y[28]})
				aSort(aTRBSIM2  ,,,{|x,y| x[06]+x[07]+x[08]+x[18]+x[19]+x[05]+x[11] < y[06]+y[07]+y[08]+y[18]+y[19]+y[05]+y[11]})
			EndIf
			GFEXFB_BORDER(lTabTemp,cTRBSTF,03,2) 
			GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF3, 2) 
			While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF3, 2) 
				if !lTabTemp
					If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO") == "1"
						GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
						Loop
					EndIf
				EndIf
				GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
				If GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM2, 3,{ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"), ;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR"), ;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPOP"), ;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"), ;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"), ;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") , ;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
					While   !GFEXFB_3EOF(lTabTemp, cTRBSIM, @aTRBSIM2, 3) .And. ;
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRCALC")  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC") .And. ;
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDCLFR")  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR") .And. ;
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTPOP")  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPOP") .And. ;
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"EMIVIN")  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN") .And. ;
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"TABVIN")  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN") .And. ;
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRNEG")   == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG")  .And. ;
							GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"NRROTA")  == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")
						If GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALROT")    == "NAO"  .OR. ;
							(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALFAI")  == "NAO"  .OR. ;
							 GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALTPVC") == "NAO") .OR. ;
							 GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALDATA") == "NAO"
							IF lTabTemp
								RecLock(cTRBSTF,.F.)
								(cTRBSTF)->(dbDelete())
								(cTRBSTF)->(MsUnLock())
							Else
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO", "1")
							EndIf
							GFEXFBDROT({GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
						EndIf
						GFEXFB_8SKIP(lTabTemp, cTRBSIM, 3) 
					EndDo
				Endif
				GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
			EndDo
		Endif

		if !lTabTemp
			IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
			aTRBSTF1 := {}
			for nX:= 1 to Len(aTRBSTF3)
				if aTRBSTF3[nx,33] == '0'
					AADD(aTRBSTF1, {aTRBSTF3[nx,01], aTRBSTF3[nx,02], aTRBSTF3[nx,03], aTRBSTF3[nx,04], aTRBSTF3[nx,05], aTRBSTF3[nx,06], aTRBSTF3[nx,07],; 
									aTRBSTF3[nx,08], aTRBSTF3[nx,09], aTRBSTF3[nx,10], aTRBSTF3[nx,11], aTRBSTF3[nx,12], aTRBSTF3[nx,13], aTRBSTF3[nx,14],;
									aTRBSTF3[nx,15], aTRBSTF3[nx,16], aTRBSTF3[nx,17], aTRBSTF3[nx,18], aTRBSTF3[nx,19], aTRBSTF3[nx,20], aTRBSTF3[nx,21],;
									aTRBSTF3[nx,22], aTRBSTF3[nx,23], aTRBSTF3[nx,24], aTRBSTF3[nx,25], aTRBSTF3[nx,26], aTRBSTF3[nx,27], aTRBSTF3[nx,28],;
									aTRBSTF3[nx,29], aTRBSTF3[nx,30], aTRBSTF3[nx,31], aTRBSTF3[nx,32], aTRBSTF3[nx,33], aTRBSTF3[nx,34]})
				EndIf
			next
			aTRBSTF3 := aClone(aTRBSTF1)
			aSort(aTRBSTF3  ,,,{|x,y| x[18]+x[19]+x[05]+x[11]      < y[18]+y[19]+y[05]+y[11]})
			IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
			aTRBSTF1 := {}
		EndIf

		If !Empty(aDelTpVc)

			//Percorre tabelas pré-selecionadas e apaga caso haja tabela informada por tipo de veículo
			If !lTabTemp
				aTRBSTF1 := aClone(aTRBSTF3)
				aSort(aTRBSTF1  ,,,{|x,y| x[01]+x[04]+x[05]+x[11]      < y[01]+y[04]+y[05]+y[11]})
			EndIf
			GFEXFB_BORDER(lTabTemp,cTRBSTF,01,2) 
			GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2)

			For nX := 1 To Len(aDelTpVc)

				If GFEXFB_CSEEK(lTabTemp, cTRBSTF, @aTRBSTF1, 2,aDelTpVc[nX])
					oGFEXFBFLog:setTexto(CRLF + "        Foram encontradas Tabelas de Frete por Tipo de Veículo válidas, elas serão priorizadas na seleção, " + ;
					"as demais rotas serão eliminadas." + CRLF)

					GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2)
					While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2)
						nPosAux := GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2)
						oGFEXFBFLog:setTexto(CRLF + "          Transp " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP")) + ;
												"; Tabela " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")) + ;
												"; Negoc. " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")) + ;
												"; Rota " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA")) + ;
												"; Tp.Tab. " + If(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPTAB")=="1", STR0598, STR0599))

						If !(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPLOTA") $ "2;3")
							If lTabTemp
								RecLock(cTRBSTF, .F.)
									(cTRBSTF)->(dbDelete())
								(cTRBSTF)->(MsUnlock())
							Else
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"ERRO", "1")
							EndIf
							
							GFEXFB_BORDER(.F., ,03,2) 
							GFEXFB_CSEEK(.F., , aTRBSTF3, 2, {GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN"),;
															  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN"),;
															  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),;
															  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA")})
							
							GFEXFBDROT({GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"),;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"),;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"),;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),;
										GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
									
							Aadd(aNegEli,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"),;
										  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"),;
										  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"),;
										  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),;
										  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
							
							oGFEXFBFLog:setTexto(" -> ELIMINADA" + CRLF)
						Else
							oGFEXFBFLog:setTexto(" -> PRIORIZADA" + CRLF)
						EndIf
						GFEXFB_HGOTO(lTabTemp,cTRBSTF,2, nPosAux)
						GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
					EndDo
					Exit
				EndIf
			Next nX
		EndIf
		
		For nX := 1 To Len(aNegEli)
			GFEXFBDSTF({aNegEli[nX][2],;
						aNegEli[nX][3],;
						aNegEli[nX][4],;
						aNegEli[nX][5]})
		Next nX

		oGFEXFBFLog:setTexto(CRLF + STR0620 + CRLF + CRLF) //"    # Filtrando tabelas pre-selecionadas - DATA VIGÊNCIA: "
		cChave := ""
		GFEXFB_BORDER(lTabTemp,cTRBSTF,03,2) 
		GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF3, 2) 
		While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF3, 2) 

			if !lTabTemp
				If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO") == "1"
					GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
					Loop
				EndIf
			EndIf

			aGV9 := {/* chave, quantidade de dias que a tabela esta vigente, nr.tab, nr.neg, transportador */}
			cChave := GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN")
			While  !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF3, 2) .And. ;
					GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN") == cChave
					
				aAdd(aGV9,{	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN")+ ;
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN")+ ;
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") , ;
							Iif(!Empty(DTOS(GWN->GWN_DTSAI)),GWN->GWN_DTSAI,dDataBase)-(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"DTVALI")), ;
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"), ;
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG") , ;
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"),;
							GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2)})
				GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
			EndDo
			
			nRec := GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2) 
			
			aSort(aGV9,,,{|x,y|x[2] < y[2]}) //ordena por tempo de vigencia, sendo a posicao 1 a menor vigencia

			oGFEXFBFLog:setTexto(STR0074 + aGV9[1,5] + STR0078 + aGV9[1,3] + STR0079 + aGV9[1,4] + STR0080 + DTOC(Iif(!Empty(DTOS(GWN->GWN_DTSAI)),GWN->GWN_DTSAI,dDataBase)-aGV9[1,2]) + " (" + cValToChar(aGV9[1,2]) + STR0081 + CRLF) //"      Tabela "###", Negoc "###" vigente desde "###" dias) -> OK"

			For nX := 2 To Len(aGV9)
				oGFEXFBFLog:setTexto(STR0074 + aGV9[nX,5] + STR0078 + aGV9[nX,3] + STR0079 + aGV9[nX,4] + STR0080 + DTOC(Iif(!Empty(DTOS(GWN->GWN_DTSAI)),GWN->GWN_DTSAI,dDataBase)-aGV9[nX,2]) + " (" + cValToChar(aGV9[nX,2]) + STR0082) //"      Tabela "###", Negoc "###" vigente desde "###" dias)"
				
				If (aGV9[nX,2] != aGV9[1,2]) //se a vigencia nao for igual a vigencia da negociacao que e' valida 
					GFEXFB_BORDER(lTabTemp,cTRBSTF,03,2) 
					GFEXFB_HGOTO(lTabTemp,cTRBSTF,2, aGV9[nX,6]) 
						If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
							GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
							If GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM2, 3,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC") ,;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR") ,;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPOP") ,;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN") ,;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN") ,;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG")  ,;
																			  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
								GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALDATA","NAO")
							EndIf
						Else
							If lTabTemp
								RecLock(cTRBSTF,.F.)
									(cTRBSTF)->(dbDelete())
								(cTRBSTF)->(MsUnLocK())
							Else
								GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO", "1")
							EndIf
							GFEXFBDROT({GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
						EndIf
						oGFEXFBFLog:setTexto(STR0083 + CRLF) //" -> INVALIDO"
				Else
					oGFEXFBFLog:setTexto(STR0084 + CRLF) //" -> OK"
				EndIf
			Next nX
			GFEXFB_HGOTO(lTabTemp, cTRBSTF, 2, nRec)
		EndDo

		If lSimulacao .AND. iTipoSim == 0
			GFEXFB_BORDER(lTabTemp,cTRBSTF,01,2) 
			GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF3, 2) 
			While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF3, 2) 

				if !lTabTemp
					If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO") == "1"
						GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
						Loop
					EndIf
				EndIf
				GFEXFB_BORDER(lTabTemp,cTRBSIM,02,3) 
				If GFEXFB_CSEEK(lTabTemp, cTRBSIM, @aTRBSIM2, 3,{ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC") ,;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDCLFR") ,;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPOP") ,;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN") ,;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN") ,;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG")  ,;
																  GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
					If 	GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALROT") == "NAO"  .OR. ;
						(GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALFAI") == "NAO" .OR. ;
						 GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALTPVC") == "NAO") .OR. ;
						GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"VALDATA") == "NAO"
						if lTabTemp
							RecLock(cTRBSTF,.F.)
							(cTRBSTF)->(dbDelete())
							(cTRBSTF)->(MsUnLock())
						Else
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"ERRO", "1")
						EndIf
						GFEXFBDROT({GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
					Else
						GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"SELEC","1")
						GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDFXTV",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDFXTV"))
						GFEXFB_5CMP(lTabTemp, cTRBSIM, @aTRBSIM2, 3,"CDTPVC",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"CDTPVC"))
					EndIf
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
			EndDo
			if !lTabTemp
				IIF(aTRBSIM1==NIL,,aSize(aTRBSIM1,0))
				aTRBSIM1 := aClone(aTRBSIM2)
				aSort(aTRBSIM1  ,,,{|x,y| x[01]+x[04]+x[05]+x[06]+x[11]+x[28]      	< y[01]+y[04]+y[05]+y[06]+y[11]+y[28]})
				aSort(aTRBSIM2  ,,,{|x,y| x[06]+x[07]+x[08]+x[18]+x[19]+x[05]+x[11] < y[06]+y[07]+y[08]+y[18]+y[19]+y[05]+y[11]})

				aTRBSTF1 := aClone(aTRBSTF3)
				aSort(aTRBSTF1  ,,,{|x,y| x[01]+x[04]+x[05]+x[11]      < y[01]+y[04]+y[05]+y[11]})
			EndIf
		Else
			if !lTabTemp
				aTRBSTF1 := aClone(aTRBSTF3)
				aSort(aTRBSTF1  ,,,{|x,y| x[01]+x[04]+x[05]+x[11]      < y[01]+y[04]+y[05]+y[11]})
			EndIf
		EndIf
		
		//elimina tabelas invalidas excluidas do arquivo de pre-selecao
		GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 

		If lTpLota3 .And. lExiVLALUG .And. !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
			//// Verifica Divergencias entre tipos de lotação da seleção da tabela de Frete
			oGFEXFBFLog:setTexto(CRLF + "      Verificando divergências nas Tabelas Selecionadas: ")
			While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 

				if !lTabTemp
					If GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"ERRO") == "1"
						GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
						Loop
					EndIf
				EndIf

				If (nDiver:= aScan(aVerDiver,{|x| 	x[1] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPLOTA") .Or. ;
													x[2] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTCOTA") .Or. ;
													x[3] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLALUG") .Or. ;
													x[4] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"FRQKM") .Or. ;
													x[5] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLKMEX") } )) == 0
					aAdd(aVerDiver,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPLOTA"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTCOTA"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLALUG"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"FRQKM"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLKMEX"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")})
				Else
					If aVerDiver[nDiver][1] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPLOTA")
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 21, , {"os Tipos de Lotação"})
						oGFEXFBFLog:setTexto(CRLF + "      ###### Tipos de Lotação Divergentes!" + CRLF + "        Tabela      Negociação  Tipo de Lotação" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + aVerDiver[nDiver][1] + CRLF + "        " + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB"),12," ") + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),12," ") + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TPLOTA") + CRLF )
					EndIf
					If aVerDiver[nDiver][2] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTCOTA")
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 21, , {"as Quantidades de Cotas"})
						oGFEXFBFLog:setTexto(CRLF + "      ###### Cotas Mínimas Divergentes!" + CRLF + "        Tabela      Negociação  Cota Mínima" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + cValToChar(aVerDiver[nDiver][2]) + CRLF + "        " + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB"),12," ") + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),12," ") + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTCOTA")) + CRLF )
					EndIf
					If aVerDiver[nDiver][3] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLALUG")
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 21, , {"os Valores da Locação"})
						oGFEXFBFLog:setTexto(CRLF + "      ###### Valores da Locação Divergentes!" + CRLF + "        Tabela      Negociação  Valor da Locação" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + cValToChar(aVerDiver[nDiver][3]) + CRLF + "        " + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB"),12," ") + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),12," ") + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLALUG")) + CRLF )
					EndIf
					If aVerDiver[nDiver][4] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"FRQKM")
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 21, , {"as Franquias em Quilômetros"})
						oGFEXFBFLog:setTexto(CRLF + "      ###### Franquias Km Divergentes!" + CRLF + "        Tabela      Negociação  Franquia Km" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + cValToChar(aVerDiver[nDiver][4]) + CRLF + "        " + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB"),12," ") + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),12," ") + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"FRQKM")) + CRLF )
					EndIf
					If aVerDiver[nDiver][5] != GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLKMEX")
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 21, , {"as Tarifas por KM excedido franquia"})
						oGFEXFBFLog:setTexto(CRLF + "      ###### Val Km Exced Divergentes!" + CRLF + "        Tabela      Negociação  Val Km Exced" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + cValToChar(aVerDiver[nDiver][5]) + CRLF + "        " + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB"),12," ") + PadR(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),12," ") + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLKMEX")) + CRLF )
					EndIf
					
					if lTabTemp
						RecLock(cTRBSTF, .F.)
						(cTRBSTF)->(dbDelete())
						(cTRBSTF)->(MsUnlock())
					Else
						GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"ERRO", "1")
					EndIf
					GFEXFBDROT({GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRCALC"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"EMIVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"TABVIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRNEG"),;
									GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF3, 2,"NRROTA")})
					oGFEXFBFLog:setTexto(CRLF + "          Transp " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP")) + ;
									"; Tabela " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")) + ;
									"; Negoc. " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")) + ;
									"; Rota " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA")) + " -> ELIMINADA" + CRLF)
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
			EndDo

		EndIf
		
		if !lTabTemp
			aTRBSTF3 := aClone(aTRBSTF1)
			IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
			aTRBSTF1 := {}
			for nX:= 1 to Len(aTRBSTF3)
				if aTRBSTF3[nx,33] == '0'
					AADD(aTRBSTF1, {aTRBSTF3[nx,01], aTRBSTF3[nx,02], aTRBSTF3[nx,03], aTRBSTF3[nx,04], aTRBSTF3[nx,05], aTRBSTF3[nx,06], aTRBSTF3[nx,07],; 
									aTRBSTF3[nx,08], aTRBSTF3[nx,09], aTRBSTF3[nx,10], aTRBSTF3[nx,11], aTRBSTF3[nx,12], aTRBSTF3[nx,13], aTRBSTF3[nx,14],;
									aTRBSTF3[nx,15], aTRBSTF3[nx,16], aTRBSTF3[nx,17], aTRBSTF3[nx,18], aTRBSTF3[nx,19], aTRBSTF3[nx,20], aTRBSTF3[nx,21],;
									aTRBSTF3[nx,22], aTRBSTF3[nx,23], aTRBSTF3[nx,24], aTRBSTF3[nx,25], aTRBSTF3[nx,26], aTRBSTF3[nx,27], aTRBSTF3[nx,28],;
									aTRBSTF3[nx,29], aTRBSTF3[nx,30], aTRBSTF3[nx,31], aTRBSTF3[nx,32], aTRBSTF3[nx,33], aTRBSTF3[nx,34]})
				EndIf
			next
			aSort(aTRBSTF1  ,,,{|x,y| x[01]+x[04]+x[05]+x[11]      < y[01]+y[04]+y[05]+y[11]})
		EndIf
		GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
		if lTabTemp
			nNumRegSTF := GFENumReg(cTRBSTF)
		Else
			nNumRegSTF := Len(aTRBSTF1)
		EndIf
		
		aArea :=  GFEXFB_9GETAREA(lTabTemp, cTRBSTF, 2)
		If nNumRegSTF > 1 // priorizar / eliminar rotas do tipo todas as rotas. elas serão adicionados em outras.
			If GFEXFBMTR()
				GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
				if lTabTemp
					nNumRegSTF := GFENumReg(cTRBSTF)
				Else
					nNumRegSTF := Len(aTRBSTF1)
				EndIf
			EndIf
		EndIf
		GFEXFB_ARESTAREA(lTabTemp,aArea,2)
		
		aSort(aTRBROT1,,,{|x,y| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + STRZERO(x[10],6) + STRZERO(x[11],6) < y[1] + y[2] + y[3] + y[4] + y[5] + y[6] + STRZERO(y[10],6) + STRZERO(y[11],6) })
		GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
		if lTabTemp
			nNumRegSTF := GFENumReg(cTRBSTF)
		Else
			nNumRegSTF := Len(aTRBSTF1)
		EndIf
		// Simular o frete para cada tabela encontrada
		oGFEXFBFLog:setTexto(CRLF + STR0085 + cValToChar( nNumRegSTF ) + CRLF) //"      Total de tabelas válidas: "
		
		GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
		
		If lCalcServ .And. !IsInCallStack("GFEA032CA")
			oGFEXFBFLog:setTexto("Verificando se as negociações encontradas foram utilizadas no cálculo do romaneio" + CRLF)
			While !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2)
				If aScan(aTblFrFUNB,{|x| x[2]+x[3]+x[4]+x[5]+x[6] == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN")+ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")+ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA")+ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV")+ GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN")}) == 0
					oGFEXFBFLog:setTexto(CRLF + "Tabela : " + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN") + " negociação : " + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG") + " não utilizada no cálculo do romaneio. -> ELIMINADA")
					If lTabTemp
						RecLock(cTRBSTF,.F.)
						(cTRBSTF)->(dbdelete())
						(cTRBSTF)->(MsUnLock())
					Else
						aDel(aTRBSTF1,idpSTF)
						aSize(aTRBSTF1,Len(aTRBSTF1)-1)
						nNumRegSTF--
						Loop
					EndIf
					nNumRegSTF--
				Else
					Exit
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
			EndDo
			GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2)
		EndIf
		lUncDel := .F.	
		If nNumRegSTF > 1
			If (IsBlind() .Or. lHideProcess)
				s_ESCTAB := s_ESCTBAT
				
				If s_ESCTAB == "1" .Or. Empty(s_ESCTAB)
					s_ESCTAB :=  "2"
				ElseIf s_ESCTAB == "2"
					s_ESCTAB := "3"
				EndIf
			EndIf


			oGFEXFBFLog:setTexto(STR0086 + If(s_ESCTAB=="1", STR0087, If(s_ESCTAB=="2", STR0088, STR0089)) + CRLF) //" Forma de seleção: "###"Manual (Usuário)"###"Valor Frete"###"Prazo Entrega"
			// Simular com todas as opções possíveis
			If lSimulacao .AND. iTipoSim == 0 // 0-Simulação Geral, 1-Simulação Específica
				If Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"))  /*trecho em branco*/

					GFESimulFret()//Função usada para calcular todos as tabelas de frete encontrada
				Else
					GFEXFBETVL()
					/*deletar não selecionadas*/
					nPosFret := GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2) 
					GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2) 
					//While  !(cTRBSTF)->(EOF() ) .And. (cTRBSTF)->(RecNo()) != nPosFret //Enquanto o indice for diferente do salvo no Recno
					While  !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2) .And. GFEXFB_GRECNO(lTabTemp, cTRBSTF, 2) != nPosFret //Enquanto o indice for diferente do salvo no Recno
						if lTabTemp
							RecLock(cTRBSTF,.F.)
							(cTRBSTF)->(dbDelete()) //Apaga o registro
							(cTRBSTF)->(MsUnLock())
						Else
							GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"ERRO", "1")
						EndIf
						GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2) 
					EndDo
					GFEXFB_HGOTO(lTabTemp, cTRBSTF, 2, nPosFret)
				EndIf

			Else
				If s_ESCTAB == "1" // 1-pelo usuario
					if !lCalcServ
						GFESimulFret()
						GFEESCTAB(.T.)
					else
						// EDI não pode ter interação com o usuário pois o processo poderá estar rodando através do Schedule
						// Neste caso deverá utilizar o menor valor de frete encontrado
						if lEdi .Or. lCalcServ
							GFEXFBETVL()
						else
							GFESimulFret()
							GFEESCTAB()
						Endif
					Endif
				ElseIf s_ESCTAB == "2" // 2-menor valor de frete
					GFEXFBETVL()
				ElseIf s_ESCTAB == "3" // 3-menor prazo de entrega
					// Para cálculos de serviço não será utilizado o menor prazo de entrega.
					// Nesta situação utiliza o menor valor de frete
					if lCalcServ
						GFEXFBETVL()
					Else
						GFEXFBETPE()
					EndIf
				EndIf
			EndIf
			if !lTabTemp
				aTRBSTF3 := aClone(aTRBSTF1)
				IIF(aTRBSTF1==NIL,,aSize(aTRBSTF1,0))
				aTRBSTF1 := {}
				for nX:= 1 to Len(aTRBSTF3)
					if aTRBSTF3[nx,33] == '0'
						AADD(aTRBSTF1, {aTRBSTF3[nx,01], aTRBSTF3[nx,02], aTRBSTF3[nx,03], aTRBSTF3[nx,04], aTRBSTF3[nx,05], aTRBSTF3[nx,06], aTRBSTF3[nx,07],; 
										aTRBSTF3[nx,08], aTRBSTF3[nx,09], aTRBSTF3[nx,10], aTRBSTF3[nx,11], aTRBSTF3[nx,12], aTRBSTF3[nx,13], aTRBSTF3[nx,14],;
										aTRBSTF3[nx,15], aTRBSTF3[nx,16], aTRBSTF3[nx,17], aTRBSTF3[nx,18], aTRBSTF3[nx,19], aTRBSTF3[nx,20], aTRBSTF3[nx,21],;
										aTRBSTF3[nx,22], aTRBSTF3[nx,23], aTRBSTF3[nx,24], aTRBSTF3[nx,25], aTRBSTF3[nx,26], aTRBSTF3[nx,27], aTRBSTF3[nx,28],;
										aTRBSTF3[nx,29], aTRBSTF3[nx,30], aTRBSTF3[nx,31], aTRBSTF3[nx,32], aTRBSTF3[nx,33], aTRBSTF3[nx,34]})
					EndIf
				next
				aSort(aTRBSTF1  ,,,{|x,y| x[01]+x[04]+x[05]+x[11]      < y[01]+y[04]+y[05]+y[11]})
			EndIf
		ElseIf nNumRegSTF == 0
			If lCalcServ .And. !IsInCallStack("GFEA032CA")
				cNrCalc := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
				aDel(aTRBTCF1,idpTCF)
				aSize(aTRBTCF1,Len(aTRBTCF1)-1)
				oGFEXFBFLog:setTexto("      *** Nao foi encontrada tabela válida para a classificação de frete da unidade." + " Desconsiderando do calculo do frete.") //
				idpAnt := idpTCF
				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
				If !GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{cNrCalc})
					aDel(aTRBUNC1,idpUNC)
					aSize(aTRBUNC1,Len(aTRBUNC1)-1)
					idpUNC--
					aTRBUNC2 := aClone(aTRBUNC1)
					aTRBUNC3 := aClone(aTRBUNC1)
				EndIf
				idpTCF := idpAnt
				idpTCF--
				lUncDel := .T.
			Else
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VALTAB",.F.)	// Nao foi encontrada tabela valida para a unidade de calculo
				GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 5)
				GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
				GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU")}) 
				GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO", "1") 
	
				//lError := .T.
				nRet := 0
				oGFEXFBFLog:setTexto(STR0090) //"      *** Nao foi encontrada tabela válida para a unidade de cálculo."
			EndIf
		EndIf

		// Se cálculo real ou simulação específica, atualiza a tabela da unidade de calculo
		If !(lSimulacao .AND. iTipoSim == 0) .And. !lUncDel  // 0-Simulação Geral, 1-Simulação Específica
			// Verifica se tem tarifa
			GFEXFB_BORDER(lTabTemp,cTRBSTF,01,2)
			if !GFEXFB_3EOF(lTabTemp, cTRBSTF, @aTRBSTF1, 2)
			
				GV6->(dbSetOrder(01))
				If GV6->(dbSeek(xFilial("GV6") + 	GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTRP")+;
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRTAB")+;
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")+;
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV")+;
											GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA")))
	
					If !Empty(cPedRom)
						cPedRom += ","
					EndIf
	
					cPedRom += cValToChar(GFEXFB_GRECNO(lTabTemp, cTRBTCF, 5)) 
	
					//grava tabela encontrada para o calculo de frete
					if lTabInf .OR. Empty(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"))	// Tabela informada ou tabela de provisão
						GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN"))
					EndIf
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB" ,GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG" ,GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPVC"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DTVIGE",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DTVALI"))
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB",GFEPesoCub(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTKGM3"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"))) // Recupera a cubagem por classificação da tabela do transportador
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC",GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTFAIXA"))      //quantidade para calculo
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PRAZO" ,GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO"))
					
					If aScan(aTblFrFUNB,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROM")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN")}) == 0
						aADD(aTblFrFUNB,{GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROM"),GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN"),GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG"),GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA"),GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV"),GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN")})
					EndIf
					
	
					oGFEXFBFLog:setTexto(CRLF + STR0091 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN") + ;
									STR0067 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN") + ;
									STR0068 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG") + ;
									STR0069 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA") + ;
									STR0092 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV") + ; //"      *** Seleção finalizada -> Transp. "###"; Tabela "###"; Negoc. "###"; Rota "###"; Faixa "
									STR0093 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC") + ;
									STR0094 + DTOC(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DTVIGE")) + ;
									STR0095 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC")) + ;
									STR0096 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"PRAZO")) +; //"; Tp.Veic. "###"; Vigência "###"; Qtd.Calculo "###"; Prazo(h) "
									STR0097 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"VLFRT")) + CRLF) //"; Vl.Frete "
				Else
					// Não tem tarifa, tabela invalida
					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VALTAB",.F.)	// Nao foi encontrada tabela valida para a unidade de calculo
					GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 6)
					GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
					GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU")}) 
					GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO", "1") 
	
					//lError := .T.
					nRet := 0
					oGFEXFBFLog:setTexto(	STR0098 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"EMIVIN") + ;
								STR0067 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"TABVIN") + ;
								STR0068 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRNEG") + ;
								STR0069 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"NRROTA") + ;
								STR0092 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDFXTV") +; //"      *** Foi encontrada tabela, mas não há tarifas para a mesma -> Transp. "###"; Tabela "###"; Negoc. "###"; Rota "###"; Faixa "
								STR0093 + GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"CDTPVC") + ;
								STR0094 + DTOC(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"DTVALI")) + ;
								STR0095 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBSTF, @aTRBSTF1, 2,"QTFAIXA")) + CRLF) //"; Tp.Veic. "###"; Vigência "###"; Qtd.Calculo "
				EndIf
			Else
				nRet := 0 
			EndIf
		EndIf
	Else
		nRet := 0
	EndIf
Return nRet /*SELTABGR*/

Function GFEXBEGetP(cTpOrig,cTpDest)
	Local nOrigPri
	Local nDesPri
	//Um valor maior significa que possui menos prioridade
	Do Case
		Case cTpOrig == "5" //Remetente/destinatário
			nOrigPri := 1
		Case cTpOrig == "1" //Cidade
			nOrigPri := 2
		Case cTpOrig == "2" //Distancia
			nOrigPri := 4
		Case cTpOrig == "3" //Região
			nOrigPri := 8
		Case cTpOrig == "4" //Pais/uf
			nOrigPri := 16
		Case cTpOrig == "0" //Todos
			nOrigPri := 32
	EndCase
	
	Do Case
		Case cTpDest == "5" //Remetente/destinatário
			nDesPri := 64
		Case cTpDest == "1" //Cidade
			nDesPri := 128
		Case cTpDest == "2" //Distancia
			nDesPri := 256
		Case cTpDest == "3" //Região
			nDesPri := 512
		Case cTpDest == "4" //Pais/uf
			nDesPri := 1024
		Case cTpDest == "0" //Todos
			nDesPri := 2048
	EndCase	
Return nDesPri + nOrigPri

// Função responsável por excluir  array das tabelas de frete selecionadas
Static Function GFEXFBDSTF(aSeek)
	If lNovoMod == .T.
		GFEXFB_BORDER(.F., ,03,2) 
		GFEXFB_CSEEK(.F., , aTRBSTF3, 2, aSeek)
		While !GFEXFB_3EOF(.F., , aTRBSTF3, 2) .And.;
			aSeek[1] == GFEXFB_5CMP(.F., , aTRBSTF3, 2,"EMIVIN" ) .And.;
			aSeek[2] == GFEXFB_5CMP(.F., , aTRBSTF3, 2,"TABVIN" ) .And.;
			aSeek[3] == GFEXFB_5CMP(.F., , aTRBSTF3, 2,"NRNEG" )  .And.;
			aSeek[4] == GFEXFB_5CMP(.F., , aTRBSTF3, 2,"NRROTA")
			
			ADel(aTRBSTF3,idpSTF)
			ASize(aTRBSTF3,Len(aTRBSTF3)-1)
			GFEXFB_8SKIP(.F., , 2)
		EndDo
	EndIf
Return


/*----------------------------------------------------------------------------
{Protheus.doc} GetQuery
//Função que gera a query para ser executada no sql, lGenerica = .T.
busca negociações genericas, lGenerica = .F. é necessario uma negociação exata a classifica/tipo de operação


@author Jorge Valcanaia
@since 12/12/2013
@version 1.0
----------------------------------------------------------------------------*/
Function GetTabQry( lTabInf, cCdTrpInf, cNrTabInf, cNrNegInf, cCdTrp, cCdClFr, cCdTpOp, lGenerica, lTabNor, aQryPar, nTpLotacao, aRetFilSQL, aRegioes)
	Local nCount    := 0
	Local aQryTab   := Nil
	Local cSelect   := ""
	Local cJoin     := ""
	Local cWhere    := ""
	Local cCodReg   := ""
	Local lGFEXFB14 := .T.

	Default lGenerica := .F.
	Default aQryPar   := {.F.,; // 1 - REALIZA FILTROS ADICIONAIS - PERFORMANCE MELHORADA 
						  '', ; // 2 - CIDADE ORIGEM
						  '', ; // 3 - CIDADE DESTINO
						  '', ; // 4 - cGW1FILIAL 
						  '', ; // 5 - cGW1CDTPDC 
						  '', ; // 6 - cGW1EMISDC
						  '', ; // 7 - cGW1SERDC 
						  ''  } // 8 - cGW1NRDC
	Default nTpLotacao := 0
	Default aRetFilSQL	:=	{{}}
	Default pdtCalcPed := stod("")	
	
	oGFEXFBFLog:setTexto("      #Dados Localização Tabela de Frete" + CRLF)
	
	oGFEXFBFLog:setTexto("      #Tipo Operação:" + cCdTpOp)
	
	oGFEXFBFLog:setTexto(" #Classificação Frete:" + cCdClFr)
	
	If nTpLotacao == 0
		oGFEXFBFLog:setTexto(' #Lotação: 1=Carga Fracionada;2=Carga Fechada;3=Veiculo Dedicado')
	ElseIf nTpLotacao == 1
		oGFEXFBFLog:setTexto(' #Lotação: 1=Carga Fracionada')
	ElseIf nTpLotacao == 2
		oGFEXFBFLog:setTexto(' #Lotação: 2=Carga Fechada;3=Veiculo Dedicado')
	EndIf
	
	// -----------------------------------------------------------------------------------------------------------
	// MONTAGEM DOS CAMPOS DO SELECT
	// -----------------------------------------------------------------------------------------------------------
	cSelect := " GVA.GVA_EMIVIN"
	cSelect += ", GVA.GVA_TABVIN"
	cSelect += ", GVA.GVA_CDEMIT"
	cSelect += ", GVA.GVA_NRTAB"
	cSelect += ", GV9.GV9_DTVALF"
	cSelect += ", GV9.GV9_NRNEG"
	cSelect += ", GV9.GV9_CDCLFR"
	cSelect += ", GV9.GV9_CDTPOP"
	cSelect += ", GV9.GV9_DTVALI"
	cSelect += ", GV9.GV9_DTVALF"
	cSelect += ", GV9.GV9_ATRFAI"
	cSelect += ", GV9.GV9_QTKGM3"
	cSelect += ", GV9.GV9_UNIFAI"
	cSelect += ", GV9.GV9_TPLOTA"
	cSelect += ", GV8.GV8_NRROTA"
	cSelect += ", GV8.GV8_TPORIG"
	cSelect += ", GV8.GV8_TPDEST"

	If aQryPar[1]
		If lTabNor
			cSelect += ",'1' AS NOR_VIN"
		Else
			cSelect += ", '2' AS NOR_VIN"
		EndIf

		cSelect += ", GV8.GV8_NRCIOR"
		cSelect += ", GV8.GV8_NRCIDS"
		cSelect += ", GU7ORI.GU7_CDUF"
		cSelect += ", GU7ORI.GU7_CDPAIS"
		cSelect += ", GV8.GV8_CDUFOR"
		cSelect += ", GV8.GV8_CDPAOR"
		cSelect += ", GU7DES.GU7_CDUF"
		cSelect += ", GU7DES.GU7_CDPAIS"
		cSelect += ", GV8.GV8_CDUFDS"
		cSelect += ", GV8.GV8_CDPADS"
		cSelect += ", GV8.GV8_DSTORI"
		cSelect += ", GV8.GV8_DSTORF"
		cSelect += ", GV8.GV8_NRREOR"
		cSelect += ", GV8.GV8_CDREM"
		cSelect += ", GV8.GV8_DSTDEI"
		cSelect += ", GV8.GV8_DSTDEF"
		cSelect += ", GV8.GV8_NRREDS"
		cSelect += ", GV8.GV8_CDDEST"
		cSelect += ", GV8.GV8_DUPSEN"
		cSelect += ", ISNULL(GU9ORI.GU9_SIT,'') AS GU9_SIT"
		cSelect += ", ISNULL(GU9ORI.GU9_NMREG,'') AS GU9_NMREG"
		cSelect += ", GU3DES.GU3_NMEMIT"
		cSelect += ", GU3DES.GU3_NRCID"
		cSelect += ", GU3ORI.GU3_NMEMIT AS GU3_NMEMITORI"
		cSelect += ", ISNULL(GU9DES.GU9_NMREG,'') AS GU9_NMREGDS"

		cSelect += ", CASE WHEN (ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
		cSelect += " 		               FROM " + RetSQLName("GUA") + " GUA"
		cSelect += " 			           JOIN " + RetSQLName("GU9") + " GU9 ON GU9.GU9_NRREG = GUA.GUA_NRREG"
		cSelect += " 		              WHERE GUA.GUA_FILIAL = '" + xFilial("GUA") + "'"
		cSelect += " 		                AND GU9.GU9_FILIAL = '" + xFilial("GU9") + "'"
		cSelect += "			            AND GUA.D_E_L_E_T_ = ' '"
		cSelect += "			            AND GU9.D_E_L_E_T_ = ' '"
		cSelect += " 			            AND GU9.GU9_SIT = '1'"
		cSelect += " 		                AND GUA.GUA_NRREG = GV8.GV8_NRREOR"
		cSelect += "			            AND GUA.GUA_NRCID = '" + aQryPar[2] + "'), 0)"
		If GFXTB12117("GVR") .AND. s_GFEGVR
			cSelect += "       + ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
			cSelect += "		           FROM " + RetSQLName("GUA") + " GUA"
			cSelect += " 			       JOIN " + RetSQLName("GVR") + " GVR ON GVR.GVR_NRREGR = GUA.GUA_NRREG"
			cSelect += " 			       JOIN " + RetSQLName("GU9") + " GU9 ON GU9.GU9_NRREG = GUA.GUA_NRREG"
			cSelect += " 		          WHERE GUA.GUA_FILIAL = '" + xFilial("GUA") + "'"
			cSelect += " 		            AND GU9.GU9_FILIAL = '" + xFilial("GU9") + "'"
			cSelect += " 		            AND GVR.GVR_FILIAL = '" + xFilial("GVR") + "'"
			cSelect += "			        AND GUA.D_E_L_E_T_ = ' '"
			cSelect += "			        AND GVR.D_E_L_E_T_ = ' '"
			cSelect += "			        AND GU9.D_E_L_E_T_ = ' '"
			cSelect += " 			        AND GU9.GU9_SIT = '1'"
			cSelect += " 		            AND GVR.GVR_NRREG = GV8.GV8_NRREOR"
			cSelect += "			        AND GUA.GUA_NRCID = '" + aQryPar[2] + "'), 0)"
		EndIf
		cSelect += ") > 0 THEN 1 ELSE 0 END AS REG_ORI1"
		
		If lPEXFB14 
			lGFEXFB14 := ExecBlock("GFEXFB14")			
		EndIf
		
		If lGFEXFB14		
			cSelect += ", CASE WHEN (ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
			cSelect += " 		               FROM " + RetSQLName("GUA") + " GUA"
			cSelect += " 			           JOIN " + RetSQLName("GU9") + " GU9 ON GU9.GU9_NRREG = GUA.GUA_NRREG"
			cSelect += " 		              WHERE GUA.GUA_FILIAL = '" + xFilial("GUA") + "'"
			cSelect += " 		                AND GU9.GU9_FILIAL = '" + xFilial("GU9") + "'"
			cSelect += "			            AND GUA.D_E_L_E_T_ = ' '"
			cSelect += "			            AND GU9.D_E_L_E_T_ = ' '"
			cSelect += " 			            AND GU9.GU9_SIT = '1'"
			cSelect += " 		                AND GUA.GUA_NRREG = GV8.GV8_NRREOR"
			cSelect += "			            AND (GV8.GV8_DUPSEN = '1' AND GUA.GUA_NRCID = '" + aQryPar[3] + "')), 0)"
			If GFXTB12117("GVR") .AND. s_GFEGVR
				cSelect += "       + ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
				cSelect += " 		           FROM " + RetSQLName("GUA") + " GUA"
				cSelect += " 			       JOIN " + RetSQLName("GVR") + " GVR ON GVR.GVR_NRREGR = GUA.GUA_NRREG"
				cSelect += " 			       JOIN " + RetSQLName("GU9") + " GU9 ON GU9.GU9_NRREG = GUA.GUA_NRREG"
				cSelect += " 		          WHERE GUA.GUA_FILIAL = '" + xFilial("GUA") + "'"
				cSelect += " 		            AND GU9.GU9_FILIAL = '" + xFilial("GU9") + "'"
				cSelect += " 		            AND GVR.GVR_FILIAL = '" + xFilial("GVR") + "'"
				cSelect += "			        AND GUA.D_E_L_E_T_ = ' '"
				cSelect += "			 		AND GVR.D_E_L_E_T_ = ' '"
				cSelect += "			 		AND GU9.D_E_L_E_T_ = ' '"
				cSelect += " 			 		AND GU9.GU9_SIT = '1'"
				cSelect += " 		     		AND GVR.GVR_NRREG = GV8.GV8_NRREOR"
				cSelect += "			 		AND (GV8.GV8_DUPSEN = '1' AND GUA.GUA_NRCID = '" + aQryPar[3] + "')), 0)"
			EndIf
			cSelect += ") > 0 THEN 1 ELSE 0 END AS REG_ORI2"
		EndIf

		cSelect += ", CASE WHEN (ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
		cSelect += " 			           FROM " + RetSQLName("GUA") + " GUA"
		cSelect += " 				       JOIN " + RetSQLName("GU9") + " GU9 ON GU9.GU9_NRREG = GUA.GUA_NRREG"
		cSelect += " 			          WHERE GUA.GUA_FILIAL = '" + xFilial("GUA") + "'"
		cSelect += " 			            AND GU9.GU9_FILIAL = '" + xFilial("GU9") + "'"
		cSelect += " 				        AND GU9.D_E_L_E_T_ = ' '"
		cSelect += " 				        AND GUA.D_E_L_E_T_ = ' '"
		cSelect += " 				        AND GU9.GU9_SIT = '1'"
		cSelect += " 			            AND GUA.GUA_NRREG = GV8.GV8_NRREDS"
		cSelect += " 				        AND GUA.GUA_NRCID = '" + aQryPar[2] + "'), 0)"
		If GFXTB12117("GVR") .AND. s_GFEGVR
			cSelect += "       + ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
			cSelect += " 		           FROM " + RetSQLName("GUA") + " GUA"
			cSelect += " 			       JOIN " + RetSQLName("GVR") + " GVR ON GVR.GVR_NRREGR = GUA.GUA_NRREG"
			cSelect += " 			       JOIN " + RetSQLName("GU9") + " GU9 ON GU9.GU9_NRREG = GUA.GUA_NRREG"
			cSelect += " 		          WHERE GUA.GUA_FILIAL = '" + xFilial("GUA") + "'"
			cSelect += " 		            AND GU9.GU9_FILIAL = '" + xFilial("GU9") + "'"
			cSelect += " 		            AND GVR.GVR_FILIAL = '" + xFilial("GVR") + "'"
			cSelect += "			        AND GUA.D_E_L_E_T_ = ' '"
			cSelect += "			 		AND GVR.D_E_L_E_T_ = ' '"
			cSelect += "			        AND GU9.D_E_L_E_T_ = ' '"
			cSelect += " 			        AND GU9.GU9_SIT = '1'"
			cSelect += " 		     		AND GVR.GVR_NRREG = GV8.GV8_NRREDS"
			cSelect += "			        AND GUA.GUA_NRCID = '" + aQryPar[2] + "'), 0)"
		EndIf
		cSelect += " ) > 0 THEN 1 ELSE 0 END AS REG_DEST1"

		cSelect += ", CASE WHEN (ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
		cSelect += " 			    	   FROM " + RetSQLName("GUA") + " GUA"
		cSelect += " 				       JOIN " + RetSQLName("GU9") + " GU9 ON GU9.GU9_NRREG = GUA.GUA_NRREG"
		cSelect += " 			          WHERE GUA.GUA_FILIAL = '" + xFilial("GUA") + "'"
		cSelect += " 			            AND GU9.GU9_FILIAL = '" + xFilial("GU9") + "'"
		cSelect += " 				        AND GU9.D_E_L_E_T_ = ' '"
		cSelect += " 				        AND GUA.D_E_L_E_T_ = ' '"
		cSelect += " 				        AND GU9.GU9_SIT = '1'"
		cSelect += " 			            AND GUA.GUA_NRREG = GV8.GV8_NRREDS"
		cSelect += " 			            AND GV8.GV8_TPDEST = '3'
		cSelect += " 				        AND GUA.GUA_NRCID = '" + aQryPar[3] + "'), 0)"
		If GFXTB12117("GVR") .AND. s_GFEGVR
			cSelect += "       + ISNULL((SELECT COUNT(GUA.GUA_FILIAL)"
			cSelect += " 		           FROM " + RetSQLName("GUA") + " GUA"
			cSelect += " 			       JOIN " + RetSQLName("GVR") + " GVR ON GVR.GVR_NRREGR = GUA.GUA_NRREG"
			cSelect += " 			       JOIN " + RetSQLName("GU9") + " GU9 ON GU9.GU9_NRREG = GUA.GUA_NRREG"
			cSelect += " 		          WHERE GUA.GUA_FILIAL = '" + xFilial("GUA") + "'"
			cSelect += " 		            AND GU9.GU9_FILIAL = '" + xFilial("GU9") + "'"
			cSelect += " 		            AND GVR.GVR_FILIAL = '" + xFilial("GVR") + "'"
			cSelect += "			        AND GUA.D_E_L_E_T_ = ' '"
			cSelect += "			 		AND GVR.D_E_L_E_T_ = ' '"
			cSelect += "			 		AND GU9.D_E_L_E_T_ = ' '"
			cSelect += " 			 		AND GU9.GU9_SIT = '1'"
			cSelect += " 		            AND GVR.GVR_NRREG = GV8.GV8_NRREDS"
			cSelect += " 			        AND GV8.GV8_TPDEST = '3'
			cSelect += "			        AND GUA.GUA_NRCID = '" + aQryPar[3] + "'), 0)"
		EndIf
		cSelect += ") > 0 THEN 1 ELSE 0 END AS REG_DEST2"

		cSelect += ", ISNULL(GWU.GWU_CDTRP, '') AS GWU_CDTRP"
		cSelect += ", ISNULL(GU3GWU.GU3_CEP, '') AS GU3_CEP"
	EndIf


	// -----------------------------------------------------------------------------------------------------------
	// MONTAGEM DAS CLAUSULAS DE JUNÇÃO
	// -----------------------------------------------------------------------------------------------------------
	If lTabNor
		cJoin := RetSQLName("GV9") + " GV9 ON GV9.GV9_CDEMIT = GVA.GVA_CDEMIT AND GV9.GV9_NRTAB = GVA.GVA_NRTAB"
	Else
		cJoin := RetSQLName("GV9") + " GV9 ON GV9.GV9_CDEMIT = GVA.GVA_EMIVIN AND GV9.GV9_NRTAB = GVA.GVA_TABVIN"
	EndIf

	For nCount := 1 To Len(aRegioes)
		If nCount > 1
			cCodReg += ","
		EndIf
		cCodReg += "'" + aRegioes[nCount] + "'"
	Next nCount

	cJoin += " JOIN " + RetSQLName("GV8") + " GV8 ON GV8.GV8_CDEMIT = GV9.GV9_CDEMIT AND GV8.GV8_NRTAB = GV9.GV9_NRTAB AND GV8.GV8_NRNEG = GV9.GV9_NRNEG"
	If !Empty(cCodReg)
		cJoin += " AND GV8_NRREOR IN ('', " + cCodReg + ")"
		cJoin += " AND GV8_NRREDS IN ('', " + cCodReg + ")"
	EndIf

	If aQryPar[1]
		cJoin += " LEFT JOIN " + RetSQLName("GU7") + " GU7ORI ON GU7ORI.GU7_NRCID = '" + aQryPar[2] + "' AND GU7ORI.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7ORI.D_E_L_E_T_ = ' '"
		cJoin += " LEFT JOIN " + RetSQLName("GU7") + " GU7DES ON GU7DES.GU7_NRCID = '" + aQryPar[3] + "' AND GU7DES.GU7_FILIAL = '" + xFilial("GU7") + "' AND GU7DES.D_E_L_E_T_ = ' '"
		cJoin += " LEFT JOIN " + RetSQLName("GU9") + " GU9ORI ON GU9ORI.GU9_FILIAL = '" + xFilial("GU9") + "' AND GU9ORI.GU9_NRREG = GV8.GV8_NRREOR AND GU9ORI.D_E_L_E_T_ = ' '"
		cJoin += " LEFT JOIN " + RetSQLName("GU9") + " GU9DES ON GU9DES.GU9_FILIAL = '" + xFilial("GU9") + "' AND GU9DES.GU9_NRREG = GV8.GV8_NRREDS AND GU9DES.D_E_L_E_T_ = ' '"
		cJoin += " LEFT JOIN " + RetSQLName("GU3") + " GU3DES ON GU3DES.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3DES.GU3_CDEMIT = GV8.GV8_CDDEST AND GU3DES.D_E_L_E_T_ = ' '"
		cJoin += " LEFT JOIN " + RetSQLName("GU3") + " GU3ORI ON GU3ORI.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3ORI.GU3_CDEMIT = GV8.GV8_CDREM AND GU3ORI.D_E_L_E_T_ = ' '"
		cJoin += " LEFT JOIN " + RetSQLName("GWU") + " GWU ON GWU.GWU_FILIAL = '" + aQryPar[04] + "' AND GWU.GWU_CDTPDC = '" + aQryPar[05] + "' AND GWU.GWU_EMISDC = '" + aQryPar[06] + "' AND GWU.GWU_SERDC = '" + aQryPar[07] + "' AND GWU.GWU_NRDC = '" + aQryPar[08] + "' AND GWU.GWU_SEQ = '02' AND GWU.D_E_L_E_T_ = ' '"
		cJoin += " LEFT JOIN " + RetSQLName("GU3") + " GU3GWU ON GU3GWU.GU3_FILIAL = '" + xFilial("GU3") + "' AND GU3GWU.GU3_CDEMIT = GWU.GWU_CDTRP AND GU3GWU.D_E_L_E_T_ = ' '"
	EndIf

	// -----------------------------------------------------------------------------------------------------------
	// MONTAGEM DAS CLAUSULAS DE JUNÇÃO
	// -----------------------------------------------------------------------------------------------------------
	If lTabNor
		cWhere += " GVA.GVA_TPTAB = '1'"
	Else
		cWhere += " GVA.GVA_TPTAB = '2'"
	EndIf
	
	If Len(aRetFilSQL) > 0 .And. Len(aRetFilSQL[1]) > 0
		oGFEXFBFLog:setTexto(CRLF +" Ponto de Entrada GFEXFB12 executado Filtro por Transportador" + CRLF)

		cWhere += " AND ( "
		For nCount := 1 To Len(aRetFilSQL[1])
			If nCount > 1
				cWhere += " OR "
			EndIf
			cWhere += " GVA.GVA_CDEMIT = '" + aRetFilSQL[1][nCount] + "'"
		Next nCount
		cWhere += " )"

	Else
		If lTabInf //Se o parametro lTabInf for verdadeiro então acrescenta-se no SQL a Tabela e Negociação a ser utilizada
			oGFEXFBFLog:setTexto(" #Transportador:" + cCdTrpInf)

			cWhere += " AND GV9.GV9_CDEMIT = '" + cCdTrpInf + "'"
			If !Empty(cNrTabInf)
				cWhere += " AND GV9.GV9_NRTAB = '" + cNrTabInf + "'" + If(!Empty(cNrNegInf), " AND GV9.GV9_NRNEG = '" + cNrNegInf + "'", " ")
			EndIf
		Else
			If !Empty( cCdTrp )
				oGFEXFBFLog:setTexto(" #Transportador:" + cCdTrp + CRLF)

				cWhere += " AND GVA.GVA_CDEMIT = '" + cCdTrp + "'" // Tranportador igual ao do trecho
			EndIf
		EndIf
	EndIf

	If !lSimNegEspec

		if !Empty(pdtCalcPed)
			cWhere += " AND GV9.GV9_DTVALI <= '"+ DTOS(pdtCalcPed)+"'"
		elseIf lCalcDataBase
			cWhere += " AND GV9.GV9_DTVALI <= '"+ Iif(!Empty(DTOS(GWN->GWN_DTSAI)),DTOS(GWN->GWN_DTSAI),DTOS(dDataBase))+"'"
		Else
			cWhere += " AND GV9.GV9_DTVALI <= '"+DTOS(Date())+"'" 
		EndIf

		If nTpLotacao == 1
			cWhere += " AND GV9.GV9_TPLOTA = '1'"
		ElseIf nTpLotacao == 2
			cWhere += " AND GV9.GV9_TPLOTA IN ('2','3')"
		EndIf
	EndIf

	//Verifica se deve filtrar as tabelas de frete em negociação
	If !lConsNeg
		cWhere += " AND GV9.GV9_SIT = '2'"  // Situacao da tabela igual a Liberada
	EndIf

	If !lTabNor .And. !lConsNeg
		cWhere += " AND GVA.GVA_SITVIN = '2'"  // Situacao da tabela VINCULO igual a Liberada
	EndIf

	// Tabelas com class. frete igual a class. de frete do romaneio/documentos de carga ou tabelas com class. de frete em branco
	If lGenerica
		If !Empty(cCdTpOp)
			cWhere += " AND (GV9.GV9_CDTPOP = '" + cCdTpOp + "' OR GV9.GV9_CDTPOP = '')"
		EndIf

		If !Empty(cCdClFr)
			cWhere += " AND (GV9.GV9_CDCLFR = '" + cCdClFr + "' OR GV9.GV9_CDCLFR = '')"
		EndIf
	ElseIf !lSimNegEspec
		cWhere += " AND GV9.GV9_CDCLFR = '" + cCdClFr + "'"
		cWhere += " AND GV9.GV9_CDTPOP = '" + cCdTpOp + "'"
	EndIf

	if !empty(pdtCalcPed )
		oGFEXFBFLog:setTexto("      #Data Base:" + DTOS(pdtCalcPed) + CRLF)
	else
		oGFEXFBFLog:setTexto("      #Data Base:" + Iif(!Empty(DTOS(GWN->GWN_DTSAI)), DTOS(GWN->GWN_DTSAI), DTOS(dDataBase)) + CRLF)
	endif

	cWhere += " AND GVA.GVA_FILIAL = '" + xFilial("GVA") + "' AND GV9.GV9_FILIAL = '" + xFilial("GV9") + "' AND GV8.GV8_FILIAL = '" + xFilial("GV8") + "'"

	If aQryPar[1]

		if !empty(pdtCalcPed )
			cWhere += " AND (ISNULL(GV9.GV9_DTVALF,'') = '' OR GV9.GV9_DTVALF = '        ' OR GV9.GV9_DTVALF >= '"+DTOS(pdtCalcPed)+"') "
		elseIf !lSimNegEspec
			cWhere += " AND (ISNULL(GV9.GV9_DTVALF,'') = '' OR GV9.GV9_DTVALF = '        ' OR GV9.GV9_DTVALF >= '" + Iif(!Empty(DTOS(GWN->GWN_DTSAI)), DTOS(GWN->GWN_DTSAI), DTOS(dDataBase)) + "')"
		Endif

		cWhere += " AND ( ( GV8.GV8_TPORIG = '1'"     // Origem Cidade
		cWhere +=         " AND ( (GV8.GV8_NRCIOR = '" + aQryPar[2] + "') OR (GV8.GV8_DUPSEN = '1' AND GV8.GV8_NRCIOR = '" + aQryPar[3] + "')) )"

		cWhere +=        " OR ( GV8.GV8_TPORIG = '4'" // Origem País/UF
		cWhere +=             " AND ( GU7ORI.GU7_CDUF = GV8.GV8_CDUFOR AND GU7ORI.GU7_CDPAIS = GV8.GV8_CDPAOR)"
		cWhere +=              " OR (GV8.GV8_DUPSEN = '1' AND GU7DES.GU7_CDUF = GV8.GV8_CDUFOR AND GU7DES.GU7_CDPAIS = GV8.GV8_CDPAOR) )"
		cWhere += " OR GV8.GV8_TPORIG IN ('0','2','3','5') )"

		cWhere += " AND ( (GV8.GV8_TPDEST = '1'"     // Destino Cidade
		cWhere +=        " AND ((GV8.GV8_NRCIDS = '" +aQryPar[3] + "') OR (GV8.GV8_DUPSEN = '1' AND GV8.GV8_NRCIDS = '" + aQryPar[2] + "')) )"
		cWhere +=        " OR (GV8.GV8_TPDEST = '4'" // Destino País/UF
		cWhere +=            " AND (GU7DES.GU7_CDUF = GV8.GV8_CDUFDS AND GU7DES.GU7_CDPAIS = GV8.GV8_CDPADS) OR (GV8.GV8_DUPSEN = '1' AND GU7ORI.GU7_CDUF = GV8.GV8_CDUFDS AND GU7ORI.GU7_CDPAIS = GV8.GV8_CDPADS))"
		cWhere += " OR GV8.GV8_TPDEST IN ('0','2','3','5') )"
	EndIf

	cWhere += " AND GVA.D_E_L_E_T_ = ' '"
	cWhere += " AND GV9.D_E_L_E_T_ = ' '"
	cWhere += " AND GV8.D_E_L_E_T_ = ' '"

  
	cSelect := "%" + cSelect + "%"
	cJoin   := "%" + cJoin + "%"
	cWhere  := "%" + cWhere + "%"
	aQryTab := {cSelect, cJoin, cWhere}

Return aQryTab


/*----------------------------------------------------------------------------
{Protheus.doc} GetRegRotas
//Função que lista todas as rotas ~por regiões que possuam as cidade Origem
distino usadas no trecho.

@author 
@since 15/03/2021
@version 1.0
----------------------------------------------------------------------------*/
Function GetRegRotas( aQryPar )
	Local aRegioes  := {}
	Local cCepOri   := ""
	Local cCepDes   := ""
	Local cCodCid   := "%'" + aQryPar[2] + "','" + aQryPar[3] + "'%"
	Local cAliasGrp := GetNextAlias()
	Local aAreaGW1  := GW1->(GetArea())

	If Len(aQryPar) < 9 .Or. Empty(aQryPar[9])
		// Busca CEP origem
		cCepOri := Posicione("GU3", 1, xFilial("GU3") + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7, "CDTRP"), "GU3_CEP")
	Else
		cCepOri := aQryPar[9]
	EndIf

	If Len(aQryPar) < 10 .Or. Empty(aQryPar[10])
		// Busca CEP Destino
		GW1->( dbSetOrder(1) ) // GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC
		If GW1->( dbSeek(aQryPar[4] + aQryPar[5] + aQryPar[6] + aQryPar[7] + aQryPar[8]) )
			cCepDes := Posicione("GU3", 1, xFilial("GU3") + GW1->GW1_CDDEST, "GU3_CEP") 
		EndIf
	Else
		cCepDes := aQryPar[10]
	EndIf

	// Busca as regiões relacionadas as cidades de origem/destino
	BeginSql Alias cAliasGrp
		SELECT GU9.GU9_NRREG
		  FROM %Table:GU7% GU7						// Cidades
		 INNER JOIN %Table:GU9% GU9					// Região
			ON GU9_FILIAL = %xFilial:GU9%
		   AND GU9_CDUF = GU7_CDUF
		 INNER JOIN %Table:GUA% GUA					// Cidades da região
			ON GUA_FILIAL = %xFilial:GUA%
		   AND GUA_NRREG = GU9_NRREG
		   AND GUA_NRCID = GU7_NRCID
		 WHERE GU7.GU7_FILIAL = %xFilial:GU7%
		   AND GU7.GU7_NRCID IN (%Exp:cCodCid%)
		   AND ( GU9_DEMCID='1' OR (GU9_DEMCID='2' AND GUA_NRCID = GU7_NRCID) )
		   AND GU7.%NotDel% AND GU9.%NotDel% AND GUA.%NotDel%
	EndSql
	Do While (cAliasGrp)->( !Eof() )
		aadd(aRegioes, (cAliasGrp)->GU9_NRREG)

		(cAliasGrp)->( DbSkip() )
	EndDo
	(cAliasGrp)->( dbCloseArea() )


	// Busca as regiões relacionadas aos CEPS conforme emitentes origem/destino
	If s_GFEGUL
		cAliasGrp := GetNextAlias()

		BeginSql Alias cAliasGrp
			SELECT GU9.GU9_NRREG
		  	  FROM %Table:GU9% GU9
			 INNER JOIN %Table:GUL% GUL
  			    ON GUL_FILIAL = %xFilial:GUL%
			   AND GUL_NRREG = GU9_NRREG
			   AND ( (GUL_CEPINI <= %Exp:cCepOri% AND GUL_CEPFIM >= %Exp:cCepOri%) OR (GUL_CEPINI <= %Exp:cCepDes% AND GUL_CEPFIM >= %Exp:cCepDes%) )
			 WHERE GU9_FILIAL = %xFilial:GU9%
			   AND GU9_DEMCID='2'
		       AND GU9.%NotDel%
			   AND GUL.%NotDel%
		EndSql
		Do While (cAliasGrp)->( !Eof() )
			aadd(aRegioes, (cAliasGrp)->GU9_NRREG)

			(cAliasGrp)->( DbSkip() )
		EndDo
		(cAliasGrp)->( dbCloseArea() )
	EndIf


	// Busca as regiões de regiões relacionadas a origem/destino
	If s_GFEGVR
		cAliasGrp := GetNextAlias()

		BeginSql Alias cAliasGrp
			SELECT GU9.GU9_NRREG
			  FROM %Table:GU9% GU9					// Região
			 INNER JOIN %Table:GVR% GVR				// Regiões da região
			    ON GVR.GVR_FILIAL = %xFilial:GVR%
			   AND GVR_NRREG = GU9_NRREG
			   AND GVR.%NotDel%
			  LEFT JOIN %Table:GUA% GUA				// Cidades da região
			    ON GUA_FILIAL = %xFilial:GUA%
			   AND GUA_NRREG = GVR_NRREGR
			   AND GUA_NRCID IN (%Exp:cCodCid%)
			   AND GUA.%NotDel%
			  LEFT JOIN %Table:GUL% GUL				// CEPs da região
			    ON GUL_FILIAL = %xFilial:GUL%
			   AND GUL_NRREG = GVR_NRREGR
			   AND ( (GUL_CEPINI <= %Exp:cCepOri% AND GUL_CEPFIM >= %Exp:cCepOri%) OR (GUL_CEPINI <= %Exp:cCepDes% AND GUL_CEPFIM >= %Exp:cCepDes%) )
			   AND GUL.%NotDel%
			 WHERE GU9_FILIAL = %xFilial:GU9%
			   AND GU9_DEMCID = '2'
			   AND GU9.%NotDel%
		EndSql
		Do While (cAliasGrp)->( !Eof() )
			aadd(aRegioes, (cAliasGrp)->GU9_NRREG)

			(cAliasGrp)->( DbSkip() )
		EndDo
		(cAliasGrp)->( dbCloseArea() )
	EndIf

	RestArea(aAreaGW1)
Return aRegioes

Function GUALocaliza(cCidade,cSelDC,cDs,lRota,lCid)
	Local cAl
	Local cQuery := ""
	
	cQuery += "SELECT GUA_NRCID, GU9_NMREG, GUA.R_E_C_N_O_ GUARECNO"
	cQuery += "	FROM " + RetSqlName("GUA") + " GUA INNER JOIN " + RetSqlName("GU9") + " GU9"
	cQuery += "	ON GU9_NRREG = GUA_NRREG "
	cQuery += "WHERE GU9_FILIAL = '" + xFilial("GU9") + "'"
	cQuery += "	AND GUA_FILIAL = '" + xFilial("GUA") + "'"
	cQuery += "	AND GUA.D_E_L_E_T_ = ' '"
	cQuery += "	AND GU9.D_E_L_E_T_ = ' '"
	cQuery += "	AND GUA_NRCID = '" + cCidade + "'"
	cQuery += "	AND GU9_NRREG = '" + cSelDC + "'"
	cQuery += "	AND GU9_SIT = '1'"
	If GFXTB12117("GVR") .AND. s_GFEGVR
		cQuery += "UNION "
		cQuery += "SELECT GUA_NRCID, GU9B.GU9_NMREG, GUA.R_E_C_N_O_ GUARECNO"
		cQuery += "	FROM " + RetSqlName("GUA") + " GUA INNER JOIN " + RetSqlName("GVR") + " GVR"
		cQuery += "	ON GVR_NRREGR = GUA_NRREG"
		cQuery += "	INNER JOIN " + RetSqlName("GU9") + " GU9A"
		cQuery += "	ON GVR_NRREGR = GU9A.GU9_NRREG"
		cQuery += "	INNER JOIN " + RetSqlName("GU9") + " GU9B"
		cQuery += "	ON GVR_NRREG = GU9B.GU9_NRREG "
		cQuery += "WHERE GU9A.GU9_FILIAL = '" + xFilial("GU9") + "'"
		cQuery += "	AND GU9B.GU9_FILIAL = '" + xFilial("GU9") + "'"
		cQuery += "	AND GUA_FILIAL = '" + xFilial("GUA") + "'"
		cQuery += "	AND GVR_FILIAL = '" + xFilial("GVR") + "'"
		cQuery += "	AND GUA.D_E_L_E_T_ = ' '"
		cQuery += "	AND GU9A.D_E_L_E_T_ = ' '"
		cQuery += "	AND GU9B.D_E_L_E_T_ = ' '"
		cQuery += "	AND GVR.D_E_L_E_T_ = ' '"
		cQuery += "	AND GUA_NRCID = '" + cCidade + "'"
		cQuery += "	AND GVR_NRREG = '" + cSelDC  + "'"
		cQuery += "	AND GU9A.GU9_SIT = '1'"
		cQuery += "	AND GU9B.GU9_SIT = '1'"
	EndIf
	cQuery := ChangeQuery(cQuery)
	cAl := MpSysOpenQuery(cQuery)
	
	If !(cAl)->(Eof()) .And. !Empty((cAl)->GUARECNO)
		cDs := AllTrim((cAl)->GU9_NMREG)
		lRota := .T.
		lCid   := .T.
	Else
		lRota := .F.
		lCid   := .F.
	EndIf
	
	(cAl)->(dbCloseArea())
Return
