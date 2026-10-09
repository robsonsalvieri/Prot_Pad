#INCLUDE "GFEXFUNB.ch"
#include 'protheus.ch'

// Constantes usadas na função AddToLog()
#DEFINE _LOG_BEGIN 1
#DEFINE _LOG_END   2

Static s_TREENTR 	:= SuperGetMv('MV_TREENTR',.F.,"0")
Static s_UMPESO		:= SuperGetMv("MV_UMPESO",,"KG")
Static s_GFETROT	:= SuperGetMv("MV_GFETROT",.F.,"1")
Static s_ESCTBAT	:= SuperGetMV("MV_ESCTBAT",.F.,"1")
Static s_GFEGVR		:= SuperGetMv("MV_GFEGVR",.F.,"1") == "1" // 2-Não utiliza a tabela GVR / 1-Realiza consulta na tabela GVR
Static s_GFEGUL		:= SuperGetMv("MV_GFEGUL",.F.,"1") == "1" // 2-Não utiliza a tabela GUL / 1-Realiza consulta na tabela GUL
Static s_GFEVIN		:= SuperGetMv("MV_GFEVIN",.F.,"1") == "1" // 2-Não utiliza o cadastro de tabela vínculo / 1-Realiza consulta o cadastro de tabela vínculo
Static s_ESCTAB		:= SuperGetMv("MV_ESCTAB",.F.,"1")

Static lPEXFB01	:= ExistBlock("GFEXFB01")
Static lPEXFB03	:= ExistBlock("GFEXFB03")
Static lPEXFB14	:= ExistBlock("GFEXFB14")

Static lExiVLALUG := GFXCP12116('GV7_VLALUG')

/*----------------------------------------------------------------------------
{Protheus.doc} SelTabFrete
Seleciona Tabela de Frete.
Uso: GFECLCFRT

@param nTabProv	Indica se deve ser utilizada a tabela de provisão
@param lShowTabFr  Indica se vai mostrar a tela de seleção de tabela de frete

@sample SelTabFrete(.T.)

@author Felipe Nathan Welter, Luiz Fernando Soares
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Function SelTabFrete(nTabProv,lShowTabFr)
	Local nPesoCubado:=0, nQtdFaixa, nX, nQtPrazo, nRecUltUNC, nNrUltCalc
	Local cCodFaixa 	:= ""
	Local lDemaisOri	// Indica se a rota selecionada é demais cidades origem
	Local lCidOri // Indica se a rota selecionada é mais expecifica origem
	Local lDemaisDes	// Indica se a rota selecionada é demais cidades destino
	Local lCidDes // Indica se a rota selecionada é mais expecifica destino
	Local aRotDemOri := {} // Recebe as rotas selecionadas que são demais cidades Origem
	Local aRotCidOri := {} // Recebe as rotas selecionadas que são expecificas origem
	Local aRotDemDes := {} // Recebe as rotas selecionadas que são demais cidades destino
	Local aRotCidDes := {} // Recebe as rotas selecionadas que são expecificas destino
	Local aArea
	Local aAreaTRE
	Local cTrcOri
	Local cTrcDes
	Local cCepOri   	:= ""
	Local cCepDes   	:= ""
	Local lFxCEPOri 	:= .F.
	Local lFxCEPDes 	:= .F.
	Local lLstTre   	:= .F.
	Local lRegDC    	:= .F.
	Local cSelDC    	:= ""
	Local cDCDest   	:= ""
	Local cChave    	:= ""
	Local aChvRot   	:= {}
	Local nPos
	Local cPedRom   	:= ""
	Local aDelTpVc  	:= {} //Indica se deverá deletar as outras tabelas selecionadas caso encontrar uma tabela válida por carga fechada.
	Local nPosFret
	// Armazenam o transportador e tabela informados para calculo
	// Pode ser a tabela de provisão registrada no sistema ou uma tabela específica para simulação
	Local cCdTrpInf, cNrTabInf, cNrNegInf
	Local lTabInf 	:= .F.
	Local cContPz
	Local aTabPrazo[14]		// Valores para o cálculo da data de previsão pela tabela de prazos
	Local aRetTabPrazo[6]   // Array que armazena os valores retornados pela função GFETabPrazo
	//Verificação de divergencia entre {tipos de lotação, Cotas, Locação, Franquia ou excedente}
	Local aVerDiver 	:= {}
	Local lTpLota3 	:= .F. // Existe um tipo de lotação 3
	Local lBuscaEspe      //caso exista tabela específica
	Local cChaveDes
	Local lTariVali 	:= .T.
	Local lSmlVei 	:= .F.
	Local cTpLocEntr 	:= s_TREENTR
	Local cFreMinAnt
	Local lFreMinIgual
	Local lUtlFrMin
	Local lGenerica
	Local nTpLotacao := 0
	Local cCdTpVc := ""
	Local lTemCrgCmp
	Local nPesoCubCrg
	Local cTodFaixa 
	Local nI := 0
	Local dDataCalc
	Local cRegTab := ""
	Local lODOriginal := .T. // Origem e Destino Original. Será invertido quando rota é duplo sentido
	Local cTPDest := ""
	Local cNewCepOri := ""
	Local cNewCepDes := ""
	  
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
			oGFEXFBFLog:setTexto(CRLF + STR0505 + CRLF +; //"  Dados informados:"
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
			(cTRBUNC)->(dbSetOrder(01))
			(cTRBUNC)->(dbGotop())
			While !(cTRBUNC)->(Eof())
				(cTRBTCF)->(dbSetOrder(01))
				(cTRBTCF)->(dbSeek((cTRBUNC)->NRCALC))
	
				//percorre tabelas do calculos de frete relacionadas
				cFreMinAnt := ''
				lFreMinIgual := .T.
				While !(cTRBTCF)->(Eof()) .And. (cTRBUNC)->NRCALC == (cTRBTCF)->NRCALC
	
					(cTRBAGRU)->(dbSetOrder(01))
					(cTRBAGRU)->(dbSeek((cTRBUNC)->NRAGRU))
					If (cTRBAGRU)->ERRO == "1"
						(cTRBAGRU)->(dbSkip())
						Loop
					EndIf
					
					oGFEXFBFLog:setTexto(CRLF + STR0053 + (cTRBTCF)->NRCALC + STR0054 + (cTRBTCF)->CDCLFR + STR0055 + (cTRBTCF)->CDTPOP + CRLF + CRLF) //"  # Unid.Calculo "###"; Class.Frete "###"; Tp.Oper. "
	
					oGFEXFBFLog:setTexto(STR0532 + GFEFldInfo("GV9_ATRFAI",IIf(aTabelaFrt[4]=="10","8",aTabelaFrt[4]),2)) //"    Obtendo quantidade para cálculo baseado em "
	
					If Posicione("GV9",1,xFilial("GV9")+(cTRBTCF)->CDTRP+(cTRBTCF)->NRTAB+(cTRBTCF)->NRNEG,"GV9_FREROM") != cFreMinAnt .AND. cFreMinAnt != ""
						lFreMinIgual := .F.
					EndIf
					cFreMinAnt := Posicione("GV9",1,xFilial("GV9")+(cTRBTCF)->CDTRP+(cTRBTCF)->NRTAB+(cTRBTCF)->NRNEG,"GV9_FREROM")
					
					lUtlFrMin := !(lFreMinIgual .AND. (cFreMinAnt == '1'))
	
					
					nQtdFaixa := GFEQtdeComp(	(cTRBUNC)->NRAGRU,;
												(cTRBTCF)->NRCALC,;
												(cTRBTCF)->CDCLFR,;
												aTabelaFrt[4]    ,; // Atributo da faixa
												(cTRBTCF)->QTDE  ,;
												(cTRBTCF)->PESOR ,;
												(cTRBTCF)->VALOR ,;
												(cTRBTCF)->VALLIQ ,;
												(cTRBTCF)->VOLUME,;
												aTabelaFrt[7]    ,; // Fator de cubagem
												@nPesoCubado         ,; // Peso cubado a ser atualizado pela função
												s_UMPESO,;
												(cTRBTCF)->QTDALT,;
												0,;
												"1",;
												cTpLocEntr,;
												GFEXFBLOCE((cTRBTCF)->NRCALC),;
												lUtlFrMin,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
												"") //O programa chamador é o GFEA081, que não envia o array aTabelaFrt, logo nunca vai entrar aqui
					RecLock(cTRBTCF,.F.)
						(cTRBTCF)->QTCALC := nQtdFaixa
					(cTRBTCF)->(MsUnLock())
	
					oGFEXFBFLog:setTexto(" " + cValToChar(nQtdFaixa) + CRLF)
	
					(cTRBTCF)->(dbSkip())
				EndDo
				(cTRBUNC)->(dbSkip())
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
	
	cAliasQry := GetNextAlias()
	
	(cTRBUNC)->(dbSetOrder(01))
	
	(cTRBUNC)->(dbGoBottom())
	nNrUltCalc := Val((cTRBUNC)->NRCALC)	// Será usado na criação de novos registros de UNC
	nRecUltUNC := (cTRBUNC)->(Recno())
	
	(cTRBUNC)->(dbGoTop())
	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2((cTRBUNC)->(RecCount()))
	EndIf
	
	// Quando simulação geral, novas unidades de cálculo são criadas dentro do while.
	// Validando o último registro, os novos registros são ignorados, evitando que o laço entre em loop infinito
	lVazio := GFENumReg(cTRBUNC) == 0
	
	While !(cTRBUNC)->(EOF()) .And. ((cTRBUNC)->(Recno()) <= nRecUltUNC) .And. !lVazio
		(cTRBAGRU)->(dbSetOrder(01))
		(cTRBAGRU)->(dbSeek((cTRBUNC)->NRAGRU))
		If (cTRBAGRU)->ERRO == "1"
			(cTRBUNC)->(dbSkip())
			Loop
		EndIf
	
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua2(Oemtoansi(STR0052 + AllTrim((cTRBUNC)->NRCALC))) //"Unidade de cálculo "
		EndIf
	
		cPedRom := ""
	
		(cTRBTCF)->(dbSetOrder(01))
		(cTRBTCF)->(dbSeek((cTRBUNC)->NRCALC,.T.))
	
		//percorre tabelas do calculos de frete relacionadas
		While !(cTRBTCF)->(Eof()) .And. (cTRBUNC)->NRCALC == (cTRBTCF)->NRCALC
			aDelTpVc := {}
			lBuscaEspe := .F.
			oGFEXFBFLog:setTexto(CRLF + STR0053 + (cTRBTCF)->NRCALC + STR0054 + (cTRBTCF)->CDCLFR + STR0055 + (cTRBTCF)->CDTPOP + CRLF + CRLF) //"  # Unid.Calculo "###"; Class.Frete "###"; Tp.Oper. "
	
			//libera alias para que possa ser reutilizada
			If Select(cAliasQry) > 0
				(cAliasQry)->(dbCloseArea())
			EndIf
	
			//posiciona trecho com mesmo Numero Calculo
			(cTRBTRE)->(dbSetOrder(01))
			(cTRBTRE)->(dbSeek((cTRBTCF)->NRCALC))
	
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
			GFEDelTbData(cTRBSTF)
		
			nI += 1

			If nI == 1 .Or. p_TpVeic == '1'
				cCdTpVc := If( Empty((cTRBAGRU)->CDTPVC), (cTRBTRE)->CDTPVC, (cTRBAGRU)->CDTPVC )
			Else
				cCdTpVc := (cTRBTRE)->CDTPVC 
			EndIf
			
			nTpLotacao := GFEXFBECFL(cCdTpVc)
			
			oGFEXFBFLog:setTexto(STR0057 + CRLF) //"    # Pre-seleção de tabelas tipo NORMAL:"
			//codigo SQL faz pre-selecao de tabelas/negociacoes/rotas tipo (1) NORMAL para filtragem posterior, valida Dt.Vigencia
			//Chamada da função GetTabSql para que possa ser buscadas as tabelas de frete genericas ou não para o romaneio, ***BUSCA ESPECIFICA****
			lGenerica := (If((lSimulacao .AND. iTipoSim == 0),.T.,.F.))
			cQuery := GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , (cTRBTCF)->CDTRP , (cTRBTCF)->CDCLFR , (cTRBTCF)->CDTPOP , lGenerica, .T. ,,nTpLotacao)
	
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
			(cAliasQry)->(dbGoTop())
			If (cAliasQry)->(EOF() ) .AND. (cAliasQry)->(BOF() ) .And. lGenerica == .F.
				//libera alias para que possa ser reutilizada
				If Select(cAliasQry) > 0
					(cAliasQry)->(dbCloseArea())
				EndIf
	
				//Chamada da função GetTabSql para que possa ser buscadas as tabelas de frete genericas ou não para o romaneio, ***BUSCA GENERICA***
				cQuery := GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , (cTRBTCF)->CDTRP , (cTRBTCF)->CDCLFR , (cTRBTCF)->CDTPOP , .T., .T.,,nTpLotacao)
	
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
			Else
				lBuscaEspe := .T.
			Endif
	
			///grava tabelas de frete selecionadas do tipo (1) NORMAL
			nX := 0
			(cAliasQry)->(dbGoTop())
			While !(cAliasQry)->(Eof())
	
				nX++
	
				If lSimNegEspec .Or. ( Empty((cAliasQry)->GV9_DTVALF) .Or. (!Empty((cAliasQry)->GV9_DTVALF) .And. (STOD((cAliasQry)->GV9_DTVALF) >= Iif(!Empty(DTOS(GWN->GWN_DTSAI)),GWN->GWN_DTSAI,dDataBase)) ))
					RecLock(cTRBSTF,.T.)
					(cTRBSTF)->NRROM  := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")
					(cTRBSTF)->DOCS   := cDoc
					(cTRBSTF)->CDTRP  := (cAliasQry)->GVA_CDEMIT //-> emitente que sera utilizado nas validacoes
					(cTRBSTF)->NRTAB  := (cAliasQry)->GVA_NRTAB  //-> tabela que sera utilizada nas validacoes
					(cTRBSTF)->NRNEG  := (cAliasQry)->GV9_NRNEG
					(cTRBSTF)->NRCALC := (cTRBTCF)->NRCALC
	
					(cTRBSTF)->CDCLFR := (cTRBTCF)->CDCLFR
					(cTRBSTF)->CDTPOP := (cTRBTCF)->CDTPOP
	
					(cTRBSTF)->NRROTA := (cAliasQry)->GV8_NRROTA
					(cTRBSTF)->TPROTA := GFEXBEGetP((cAliasQry)->GV8_TPORIG,(cAliasQry)->GV8_TPDEST)
					(cTRBSTF)->DTVALI := STOD((cAliasQry)->GV9_DTVALI)
					(cTRBSTF)->DTVALF := STOD((cAliasQry)->GV9_DTVALF)
					(cTRBSTF)->VLFRT  := 0
					(cTRBSTF)->PRAZO  := 0 //tarifas
					(cTRBSTF)->TPTAB  := "1"
					(cTRBSTF)->EMIVIN := (cAliasQry)->GVA_CDEMIT // Recebe o proprio transportador
					(cTRBSTF)->TABVIN := (cAliasQry)->GVA_NRTAB  // Recebe a propria tabela
					(cTRBSTF)->ATRFAI := (cAliasQry)->GV9_ATRFAI
					(cTRBSTF)->QTKGM3 := (cAliasQry)->GV9_QTKGM3
					(cTRBSTF)->UNIFAI := (cAliasQry)->GV9_UNIFAI
					(cTRBSTF)->TPLOTA := (cAliasQry)->GV9_TPLOTA
					(cTRBSTF)->(MsUnLock())
	
					oGFEXFBFLog:setTexto(STR0059 + (cTRBSTF)->EMIVIN + STR0060 + (cTRBSTF)->TABVIN + STR0061 + (cTRBSTF)->NRNEG + STR0062 + (cTRBSTF)->NRROTA + CRLF) //"      Transp.: "###"; Nr. Tab: "###"; Nr. Neg: "###"; Rota: "
				EndIf
	
				(cAliasQry)->(dbSkip())
			EndDo
	
			//libera alias para que possa ser reutilizada
			If Select(cAliasQry) > 0
				(cAliasQry)->(dbCloseArea())
			EndIf
	
			if nX==0
				oGFEXFBFLog:setTexto(STR0063 + If(lTabInf,cCdTrpInf,(cTRBTCF)->CDTRP) + STR0064 + CRLF) //"      Não foram encontradas tabelas do tipo NORMAL para o transp. "###" com situação Liberada, vigentes para a data de hoje."
			endif
	
			///-------------------------------------------------------------------///
			///------------------------ TABELA VINCULO ---------------------------///
			///-------------------------------------------------------------------///
			If s_GFEVIN .AND. nTabProv != 1//So busca tabela vinculada se cálculo não for tabela de provisão
				oGFEXFBFLog:setTexto(CRLF + STR0065 + CRLF) //"    # Pre-selecao de tabelas tipo VINCULO:"
				lGenerica := (If((lSimulacao .AND. iTipoSim == 0),.T.,.F.))
				cQuery := GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , (cTRBTCF)->CDTRP , (cTRBTCF)->CDCLFR , (cTRBTCF)->CDTPOP , lGenerica, .F. ,,nTpLotacao)
	
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
				(cAliasQry)->(dbGoTop())
				If (cAliasQry)->(EOF() ) .AND. (cAliasQry)->(BOF() ) .And. lGenerica == .F.
					//libera alias para que possa ser reutilizada
					If Select(cAliasQry) > 0
						(cAliasQry)->(dbCloseArea())
					EndIf
	
					//Chamada da função GetTabSql para que possa ser buscadas as tabelas de frete genericas ou não para o romaneio, ***BUSCA GENERICA***
					cQuery := GetQuery( lTabInf , cCdTrpInf , cNrTabInf , cNrNegInf , (cTRBTCF)->CDTRP , (cTRBTCF)->CDCLFR , (cTRBTCF)->CDTPOP , .T., .F.,,nTpLotacao)
	
					cQuery := ChangeQuery(cQuery)
					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				Endif
	
				///grava tabelas de frete selecionadas do tipo (1) NORMAL
				nX := 0
				(cAliasQry)->(dbGoTop())
				While !(cAliasQry)->(Eof())
	
					nX++
	
					If lSimNegEspec .Or. ( Empty((cAliasQry)->GV9_DTVALF) .Or. (!Empty((cAliasQry)->GV9_DTVALF) .And. (STOD((cAliasQry)->GV9_DTVALF) >= Iif(!Empty(GWN->GWN_DTSAI),GWN->GWN_DTSAI,dDataBase))) )
						RecLock(cTRBSTF,.T.)
						(cTRBSTF)->NRROM  := GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")
						(cTRBSTF)->DOCS   := cDoc
						(cTRBSTF)->CDTRP  := (cAliasQry)->GVA_EMIVIN //-> emitente que sera utilizado nas validacoes
						(cTRBSTF)->NRTAB  := (cAliasQry)->GVA_TABVIN  //-> tabela que sera utilizada nas validacoes
						(cTRBSTF)->NRNEG  := (cAliasQry)->GV9_NRNEG
						(cTRBSTF)->NRCALC := (cTRBTCF)->NRCALC
						(cTRBSTF)->CDCLFR := (cAliasQry)->GV9_CDCLFR
						(cTRBSTF)->CDTPOP := (cAliasQry)->GV9_CDTPOP
						(cTRBSTF)->NRROTA := (cAliasQry)->GV8_NRROTA
						(cTRBSTF)->TPROTA := GFEXBEGetP((cAliasQry)->GV8_TPORIG,(cAliasQry)->GV8_TPDEST)
						
						(cTRBSTF)->DTVALI := STOD((cAliasQry)->GV9_DTVALI)
						(cTRBSTF)->DTVALF := STOD((cAliasQry)->GV9_DTVALF)
						(cTRBSTF)->VLFRT  := 0
						(cTRBSTF)->PRAZO  := 0 //tarifas
						(cTRBSTF)->TPTAB  := "2"
						(cTRBSTF)->EMIVIN := (cAliasQry)->GVA_CDEMIT // Recebe o proprio transportador
						(cTRBSTF)->TABVIN := (cAliasQry)->GVA_NRTAB  // Recebe a propria tabela
						(cTRBSTF)->ATRFAI := (cAliasQry)->GV9_ATRFAI
						(cTRBSTF)->QTKGM3 := (cAliasQry)->GV9_QTKGM3
						(cTRBSTF)->UNIFAI := (cAliasQry)->GV9_UNIFAI
						(cTRBSTF)->TPLOTA := (cAliasQry)->GV9_TPLOTA
						(cTRBSTF)->(MsUnLock())
	
						oGFEXFBFLog:setTexto(STR0066 + (cTRBSTF)->EMIVIN + STR0067 + (cTRBSTF)->TABVIN + STR0068 + (cTRBSTF)->NRNEG + STR0069 + (cTRBSTF)->NRROTA +;
						         STR0535 + (cTRBSTF)->CDTRP + STR0067 + (cTRBSTF)->NRTAB + ")" + CRLF) //"        Transp. "###"; Tabela "###"; Negoc. "###"; Rota " //" (Transp. "
					EndIf
	
					(cAliasQry)->(dbSkip())
				EndDo
	
				//libera alias para que possa ser reutilizada
				If Select(cAliasQry) > 0
					(cAliasQry)->(dbCloseArea())
				EndIf
	
				If nX == 0
					oGFEXFBFLog:setTexto(STR0070 + If(lTabInf,cCdTrpInf,(cTRBTCF)->CDTRP) + STR0071 + CRLF)	 //"      Não foram encontradas tabelas do tipo VINCULO para o transp. "###" com situação Liberada, vigentes para a data de hoje"
				EndIf
			EndIf
			//*********************************//*********************************//
			//Faz a copia dos registros da tabela de rotas pré-selecionadas para o DBF utilizado na simulação
			If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
				(cTRBSTF)->(dbGoTop())
				While !(cTRBSTF)->(EoF())
	
					RecLock((cTRBSIM),.T.)
					(cTRBSIM)->NRROM   := (cTRBSTF)->NRROM
					(cTRBSIM)->DOCS    := (cTRBSTF)->DOCS
					(cTRBSIM)->CDTRP   := (cTRBSTF)->CDTRP
				    (cTRBSIM)->NRTAB   := (cTRBSTF)->NRTAB
					(cTRBSIM)->NRNEG   := (cTRBSTF)->NRNEG
					(cTRBSIM)->NRCALC  := (cTRBSTF)->NRCALC
					(cTRBSIM)->CDCLFR  := (cTRBSTF)->CDCLFR
					(cTRBSIM)->CDTPOP  := (cTRBSTF)->CDTPOP
					(cTRBSIM)->CDFXTV  := (cTRBSTF)->CDFXTV
					(cTRBSIM)->CDTPVC  := (cTRBSTF)->CDTPVC
					(cTRBSIM)->NRROTA  := (cTRBSTF)->NRROTA
					(cTRBSIM)->DESROT  := (cTRBSTF)->DESROT
					(cTRBSIM)->DTVALI  := (cTRBSTF)->DTVALI
					(cTRBSIM)->DTVALF  := (cTRBSTF)->DTVALF
					(cTRBSIM)->VLFRT   := (cTRBSTF)->VLFRT
					(cTRBSIM)->PRAZO   := (cTRBSTF)->PRAZO
					(cTRBSIM)->TPTAB   := (cTRBSTF)->TPTAB
					(cTRBSIM)->EMIVIN  := (cTRBSTF)->EMIVIN
					(cTRBSIM)->TABVIN  := (cTRBSTF)->TABVIN
					(cTRBSIM)->ATRFAI  := (cTRBSTF)->ATRFAI
					(cTRBSIM)->QTKGM3  := (cTRBSTF)->QTKGM3
					(cTRBSIM)->UNIFAI  := (cTRBSTF)->UNIFAI
					(cTRBSIM)->TPLOTA  := (cTRBSTF)->TPLOTA
					(cTRBSIM)->DEMCID  := (cTRBSTF)->DEMCID
					(cTRBSIM)->QTFAIXA := (cTRBSTF)->QTFAIXA
					(cTRBSIM)->TPVCFX  := (cTRBSTF)->TPVCFX
					
					(cTRBSIM)->(MsUnLock())
	
		   			(cTRBSTF)->(DbSkip())
				EndDo
			EndIF
			//*********************************//*********************************//
	
			(cTRBSTF)->(dbGoTop() )
			If !(cTRBSTF)->(EOF() )
	
				oGFEXFBFLog:setTexto(CRLF + STR0072 + CRLF) //"    # Filtrando tabelas pre-selecionadas - ROTAS: "
	
				//************************
				//*VALIDA ROTAS          *
				//************************
				oGFEXFBFLog:setTexto(CRLF + "      " + STR0576 + " (" + STR0591 + " " + (cTRBTRE)->CDTRP + "; " + STR0592 + " " + (cTRBTRE)->ORIGEM + " - " +; //"Trecho" ### "Transp." ### "Cid.Origem"
				         AllTrim(Posicione("GU7",1,xFilial("GU7")+(cTRBTRE)->ORIGEM,"GU7_NMCID")) +;
	  				     "; " + STR0593 + " " + (cTRBTRE)->DESTIN + " - "+AllTrim(Posicione("GU7",1,xFilial("GU7")+(cTRBTRE)->DESTIN,"GU7_NMCID")) + ")" + CRLF) //"Cid.Destino"
	
				aRotDemOri := {}
				aRotCidOri := {}
				aRotDemDes := {}
				aRotCidDes := {}
				nLoop      := 0
				aChvRot    := {}
	
				(cTRBSTF)->(dbGoTop() )
	
				While !(cTRBSTF)->(EOF() )
					lDemaisOri := .F.
					lDemaisDes := .F.
					lCidOri := .F.
					lCidDes := .F.
					If nLoop == 0
						cCidOri := (cTRBTRE)->ORIGEM
						cCidDes := (cTRBTRE)->DESTIN
						lODOriginal := .T. // Origem e Destino Original
						cDsOrig := ""
						cDsDest := ""
	
						oGFEXFBFLog:setTexto(CRLF + "        " + STR0591 + " " + (cTRBSTF)->EMIVIN + "; " + STR0594 + " " + (cTRBSTF)->TABVIN + "; " + STR0595 + " " + (cTRBSTF)->NRNEG +; //"Transp." ### "Tabela" ### "Negoc."
					         "; " + STR0596 + " " + (cTRBSTF)->NRROTA + "; " + STR0597 + " " + If((cTRBSTF)->TPTAB=="1", STR0598, STR0599) + CRLF) //"Rota" ### "Tp.Tab." ### "Normal" ### "Vinculo"
					Else
						oGFEXFBFLog:setTexto("        *** " + STR0600 + CRLF) //"Rota permite duplo sentido, invertendo origem e destino do trecho..."
					EndIf
	
					//posiciona na tabela de rotas
					GV8->(dbSetOrder(01) )
					GV8->(dbSeek(xFilial("GV8")+(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA) )
	
					lRotaVld  := .F.
					lFxCEPOri := .F.
					//----ORIGEM----
					cDsOrig := ""
					cTpOrig := GV8->GV8_TPORIG
	
					oGFEXFBFLog:setTexto("          " + STR0601 + " : " + AllTrim(GFEFldInfo("GV8_TPORIG",cTpOrig,2))) //"Tipo Origem"
					If cTpOrig == "0" //Todos
						lRotaVld := .T.
						cDsOrig := "Todas as rotas"
					ElseIf cTpOrig == "1" //Cidade
						cDsOrig := AllTrim(Posicione("GU7",1,xFilial("GU7")+GV8->GV8_NRCIOR,"GU7_NMCID"))
						If AllTrim(cCidOri) == AllTrim(GV8->GV8_NRCIOR)
							lRotaVld := .T.
						EndIf
						oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + AllTrim(GV8->GV8_NRCIOR) + " - " + cDsOrig + ")-> OK", STR0603 + " (" + AllTrim(GV8->GV8_NRCIOR) + " - " + cDsOrig + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
					ElseIf cTpOrig == "2" //Distancia
						(cTRBAGRU)->(dbSetOrder(01))
						If (cTRBAGRU)->(dbSeek(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")))
							If (cTRBAGRU)->DISTAN > GV8->GV8_DSTORI .And. (cTRBAGRU)->DISTAN <= GV8->GV8_DSTORF
								lRotaVld := .T.
								cDsOrig := SubStr(STR0604 + AllTrim(STR((cTRBAGRU)->DISTAN)),1,23) //"Dist.: "
							EndIf
						EndIf
						oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + cDsOrig + ")-> OK", STR0603 + " (" + cValToChar(GV8->GV8_DSTORI) + " - " + cValToChar(GV8->GV8_DSTORF) + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
					ElseIf cTpOrig == "3" //Regiao
						
						//Localiza pela cidade
						GUALocaliza(cCidOri,GV8->GV8_NRREOR,@cDsOrig,@lRotaVld,@lCidOri)
						
						If !lRotaVld // verifica se a regiao eh demais cidades ou se está na faixa de CEP
	
							cTrcOri := (cTRBTRE)->CDTPDC+(cTRBTRE)->EMISDC+(cTRBTRE)->SERDC+(cTRBTRE)->NRDC
	
							If (cTRBTRE)->SEQ == "01"
								GWN->(dbSetOrder(1))
								If !Empty((cTRBTRE)->CEPO)
									cCepOri := (cTRBTRE)->CEPO
								ElseIf GWN->(dbSeek(xFilial("GWN")+(cTRBAGRU)->NRAGRU)) .AND. GFEVerCmpo({"GWN_CEPO"}) .AND. !Empty(GWN->GWN_CEPO)
									cCepOri := GWN->GWN_CEPO
								Else
									GW1->(dbSetOrder(1) )
									If GW1->(dbSeek(xFilial("GW1") + cTrcOri) )
	
										cCepOri := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDREM,"GU3_CEP")
	
										If Empty(cCepOri)
											cDsOrig := AllTrim(Posicione("GU9",1,xFilial("GU9")+GV8->GV8_NRREOR,"GU9_NMREG")) + "; " + STR0313 + " '" + GW1->GW1_CDREM + "' " + STR0625 // "Transportador" ### "não possui CEP."
										EndIf
	
									EndIf
								EndIf
							Else
								If !Empty((cTRBTRE)->CEPO)
									cCepOri := (cTRBTRE)->CEPO
								Else
									cCepOri := Posicione("GU3",1,xFilial("GU3")+(cTRBTRE)->CDTRP,"GU3_CEP")
								EndIf
	
								If Empty(cCepOri)
									cDsOrig := AllTrim(Posicione("GU9",1,xFilial("GU9")+GV8->GV8_NRREOR,"GU9_NMREG")) + "; " + STR0608 + " '" + (cTRBTRE)->CDTRP + "' " + STR0625 // "Remetente" ### "não possui CEP."
								EndIf
	
							EndIf
							If !lODOriginal
								cCepOri := cNewCepOri
							EndIf
							If !Empty(cCepOri) .AND. s_GFEGUL
								
								If !Empty(GV8->GV8_NRREOR)
									GULLocaliza(cCepOri,GV8->GV8_NRREOR,@cDsOrig,@lRotaVld,@lFxCEPOri)
								Else 
									GULLocaliza(cCepOri,cRegTab,@cDsOrig,@lRotaVld,@lFxCEPOri)
								EndIF
							EndIf
	
							If !lFxCEPOri
								GU7->(dbSetOrder(01))
								If GU7->(dbSeek(xFilial("GU7")+cCidOri))
									GU9->(dbSetOrder(01))
									If GU9->(dbSeek(xFilial("GU9")+GV8->GV8_NRREOR))
										If GU9->GU9_DEMCID == "1" .And. alltrim(GU9->GU9_CDUF) == alltrim(GU7->GU7_CDUF) .And. GU9->GU9_SIT == "1"
											lRotaVld := .T.
											lDemaisOri := .T.
											cDsOrig := STR0605 + " ("+GU9->GU9_CDUF+")" //"Demais Cidades"
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
				    	If Empty(GV8->GV8_NRREOR)
							oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + cRegTab + " - " + AllTrim(cDsOrig) + ")-> OK", STR0606 + " (" + cRegTab + " - " + AllTrim(cDsOrig) + ") -> " + STR0609)) //"Correspondente" ### "Não localizada" ### "INVALIDO"
						Else
							oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + GV8->GV8_NRREOR + " - " + cDsOrig + ")-> OK", STR0606 + " (" + GV8->GV8_NRREOR + " - " + cDsOrig + ") -> " + STR0609)) //"Correspondente" ### "Não localizada" ### "INVALIDO"					
						EndIf
					ElseIf cTpOrig == "4" //Pais/UF
						GU7->(dbSetOrder(01))
						If GU7->(dbSeek(xFilial("GU7")+cCidOri))
							cDsOrig := AllTrim(SubStr(Posicione("SYA",1,xFilial("SYA")+GV8->GV8_CDPAOR,"YA_DESCR"),1,18))+" - "+GU7->GU7_CDUF
							If GU7->GU7_CDUF == GV8->GV8_CDUFOR .And. GU7->GU7_CDPAIS == GV8->GV8_CDPAOR
								lRotaVld := .T.
							EndIf
						EndIf
						oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + cDsOrig + ")-> OK", STR0607)) //"Correspondente" ### "Diferente / cidade não localizada -> INVALIDO"
					ElseIf cTpOrig == "5" //Remetente
						cDsOrig := AllTrim(POSICIONE("GU3",1,XFILIAL("GU3")+GV8->GV8_CDREM,"GU3_NMEMIT")) //"Remetente"
	
						If (lSimulacao .AND. iTipoSim == 0)
	
							If IIf(nLoop == 0, GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDREM") == GV8->GV8_CDREM, GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDDEST") == GV8->GV8_CDREM)
								lRotaVld := .T.
								If AScan(aChvRot,{|x| x[1] == (cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA}) == 0
									AAdd(aChvRot, {(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA, 1})
								EndIf
							Endif
	
	
						Else
							GW1->(dbSetOrder(1))
							If GW1->(dbSeek(xFilial("GW1") + (cTRBTRE)->CDTPDC + (cTRBTRE)->EMISDC + (cTRBTRE)->SERDC + (cTRBTRE)->NRDC))
							 	If IIf(nLoop == 0, GW1->GW1_CDREM == GV8->GV8_CDREM, GW1->GW1_CDDEST == GV8->GV8_CDREM)
									lRotaVld := .T.
									If AScan(aChvRot,{|x| x[1] == (cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA}) == 0
										AAdd(aChvRot, {(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA, 1})
									EndIf
								Endif
							EndIf
	
						Endif
	
						oGFEXFBFLog:setTexto(" * " + If(lRotaVld, STR0602 + " (" + AllTrim(GV8->GV8_CDREM) + " - " + cDsOrig + ")-> OK", STR0603 + " (" + AllTrim(GV8->GV8_CDREM) + " - " + cDsOrig + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
					EndIf
					oGFEXFBFLog:setTexto(CRLF)
	
					If cTpOrig == "2" .And. (lRotaVld .OR. (lSimulacao .AND. iTipoSim == 0))
	
						lRotaVldDes := .T.
						cTPDest := GV8->GV8_TPDEST
	
					ElseIf lRotaVld .OR. (lSimulacao .AND. iTipoSim == 0) // 0-Simulação Geral, 1-Simulação Específica
						lRotaVldDes := .F.
						lFxCEPDes   := .F.
						//----DESTINO----
						cDsDest := ""
						cTPDest := GV8->GV8_TPDEST
						oGFEXFBFLog:setTexto("          " + STR0610 + " " + AllTrim(GFEFldInfo("GV8_TPDEST",cTPDest,2))) //"Tipo Destino:"
						If cTPDest == "0" //Cidade
							lRotaVldDes := .T.
							cDsDest := "Todas as rotas"
						ElseIf cTPDest == "1" //Cidade
							cDsDest := AllTrim(Posicione("GU7",1,xFilial("GU7")+GV8->GV8_NRCIDS,"GU7_NMCID"))
							If Alltrim(cCidDes) == Alltrim(GV8->GV8_NRCIDS)
								lRotaVldDes := .T.
							EndIf
							oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + GV8->GV8_NRCIDS + " - " + cDsDest + ")-> OK", STR0603 + " (" + GV8->GV8_NRCIDS + " - " + cDsDest + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
						ElseIf cTPDest == "2" //Distancia
							(cTRBAGRU)->(dbSetOrder(01))
							If (cTRBAGRU)->(dbSeek(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")))
								cDsDest := SubStr("Dist.: "+AllTrim(STR((cTRBAGRU)->DISTAN)),1,23)
								If (cTRBAGRU)->DISTAN > GV8->GV8_DSTDEI .And. (cTRBAGRU)->DISTAN <= GV8->GV8_DSTDEF
									lRotaVldDes := .T.
								EndIf
							EndIf
							oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + cDsDest + ")-> OK", STR0603 + " (" + cValToChar(GV8->GV8_DSTORI) + " - " + cValToChar(GV8->GV8_DSTORF) + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
						ElseIf cTPDest == "3" //Regiao
	
							aAreaTRE := (cTRBTRE)->( GetArea() )
	
							cTrcDes := (cTRBTRE)->CDTPDC+(cTRBTRE)->EMISDC+(cTRBTRE)->SERDC+(cTRBTRE)->NRDC
							cTrpDes := (cTRBTRE)->CDTRP
							(cTRBTRE)->(dbSkip() )
							If !(cTRBTRE)->(EOF() ) .And. cTrcDes == (cTRBTRE)->CDTPDC+(cTRBTRE)->EMISDC+(cTRBTRE)->SERDC+(cTRBTRE)->NRDC
								lLstTre := .F.
							Else
								lLstTre := .T.
							EndIf
	
							RestArea(aAreaTRE)
							
							// Campo não será utilizado na busca de rotas. Requisito LOGGFE01-695
	
							GW1->(dbSetOrder(1) )
							If GW1->(dbSeek(xFilial("GW1") + cTrcDes) )
								If lODOriginal
									cDCDest   := GW1->GW1_CDDEST
								Else
									cDCDest   := GW1->GW1_CDREM
								EndIf
							EndIf
	
							If (AllTrim(cDCDest) == "")
								(cTRBDOC)->(dbSetOrder(2))
								If (cTRBDOC)->(dbSeek(cTrcDes))
									If lODOriginal
										cDCDest   := (cTRBDOC)->CDDEST
									Else
										cDCDest   := (cTRBDOC)->CDREM
									EndIf
								EndIf
							EndIf
	
							lRegDC := lLstTre
							cSelDC := GV8->GV8_NRREDS
							
							//Localiza pela cidade
							GUALocaliza(cCidDes,cSelDC,@cDsDest,@lRotaVldDes,@lCidDes)
							
							If !lRotaVldDes // verifica se a regiao eh demais cidades ou se está na faixa de CEP
	
								If !lLstTre
									If !Empty(IIF(lODOriginal,(cTRBTRE)->CEPD,(cTRBTRE)->CEPO))
										cCepDes := IIF(lODOriginal,(cTRBTRE)->CEPD,(cTRBTRE)->CEPO)
									Else
										cCepDes := Posicione("GU3",1,xFilial("GU3")+cTrpDes,"GU3_CEP")
									EndIf
	
									If Empty(cCepDes)
										cDsDest := AllTrim(Posicione("GU9",1,xFilial("GU9")+GV8->GV8_NRREDS,"GU9_NMREG")) + "; " + STR0608 + " '" + cTrpDes + "' " + STR0625 // "Transportador" ### "não possui CEP."
									EndIf
	
								Else
									(cTRBAGRU)->(dbSetOrder(01))
									(cTRBAGRU)->(dbSeek(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")))
	
									(cTRBDOC)->(dbSetOrder(02))
									(cTRBDOC)->(dbSeek(GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
									If !Empty(IIF(lODOriginal,(cTRBTRE)->CEPD,(cTRBTRE)->CEPO))
										cCepDes := IIF(lODOriginal,(cTRBTRE)->CEPD,(cTRBTRE)->CEPO)
									ElseIf !Empty(IIF(lODOriginal,(cTRBAGRU)->CEPD,''))
										cCepDes := IIF(lODOriginal,(cTRBAGRU)->CEPD,'')
									ElseIf (cTRBTRE)->PAGAR == "1" .and. !Empty((cTRBDOC)->ENTCEP) .and. Alltrim(cCidDes) == Alltrim(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC"))
										cCepDes := (cTRBDOC)->ENTCEP
									Else
										IF (Alltrim(cCidDes) != Alltrim(Posicione("GU3",1,xFilial("GU3")+cDCDest,"GU3_NRCID")))
											cChaveDes := GW1->GW1_FILIAL + GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC + '02'
											cDCDest:= Posicione("GWU",1,cChaveDes,"GWU_CDTRP")
											If Empty(cDCDest)
												cDCDest := (cTRBDOC)->CDREM
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
											If GU9->GU9_DEMCID == "1" .And. alltrim(GU9->GU9_CDUF) == alltrim(GU7->GU7_CDUF) .And. GU9->GU9_SIT == "1"
												lRotaVldDes := .T.
												lDemaisDes:= .T.
												cDsDest := STR0605 + " ("+GU9->GU9_CDUF+")" //"Demais Cidades"
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
							oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + cSelDC + " - " + AllTrim(cDsDest) + IIf(lRegDC," - " + STR0630, "") + ")-> OK", STR0606 + " (" + cSelDC + " - " + AllTrim(cDsDest) + IIf(lRegDC,STR0630, "") + ") -> " + STR0609)) //"Correspondente" ### "Não localizada" ### "INVALIDO"
						ElseIf cTPDest == "4" //Pais/UF
							GU7->(dbSetOrder(01))
							If GU7->(dbSeek(xFilial("GU7")+cCidDes))
								If GU7->GU7_CDUF == GV8->GV8_CDUFDS .And. GU7->GU7_CDPAIS == GV8->GV8_CDPADS
									lRotaVldDes := .T.
									cDsDest := AllTrim(SubStr(Posicione("SYA",1,xFilial("SYA")+GV8->GV8_CDPADS,"YA_DESCR"),1,18))+" - "+GU7->GU7_CDUF
								EndIf
							EndIf
							oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + cDsDest + ")-> OK", STR0607)) //"Correspondente" ### "Diferente / cidade não localizada -> INVALIDO"
						ElseIf cTPDest == "5" //Destinatário
							GU3->(DbSetOrder(1))
							GU3->(DbSeek(XFILIAL("GU3")+GV8->GV8_CDDEST))
							cDsDest := AllTrim(GU3->GU3_NMEMIT) //"Destinatario "
	
							If (lSimulacao .AND. iTipoSim == 0)
								If GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"CDDEST") == GV8->GV8_CDDEST .And. ;
								 	   ((Empty(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC")) .And. GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC") != PadR("0", TamSX3("GW1_ENTNRC")[1])) .Or. (Alltrim(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"ENTNRC")) == Alltrim(GU3->GU3_NRCID)))
										lRotaVldDes := .T.
	
									If (nPos := AScan(aChvRot,{|x| x[1] == (cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA})) != 0
										aChvRot[nPos][2]++
									Else
										AAdd(aChvRot, {(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA, 1})
									EndIf
	
								 Endif
	
							Else
								GW1->(dbSetOrder(1))
								If GW1->(dbSeek(xFilial("GW1") + (cTRBTRE)->CDTPDC + (cTRBTRE)->EMISDC + (cTRBTRE)->SERDC + (cTRBTRE)->NRDC))
								 	If IIf(nLoop == 0, GW1->GW1_CDDEST == GV8->GV8_CDDEST, GW1->GW1_CDREM == GV8->GV8_CDDEST) .And. ;
								 	   ((Empty(GW1->GW1_ENTNRC) .And. GW1->GW1_ENTNRC != PadR("0", TamSX3("GW1_ENTNRC")[1])) .Or. (GW1->GW1_ENTNRC == GU3->GU3_NRCID))
										lRotaVldDes := .T.
	
									If (nPos := AScan(aChvRot,{|x| x[1] == (cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA})) != 0
										aChvRot[nPos][2]++
									Else
										AAdd(aChvRot, {(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA, 1})
									EndIf
	
								   Endif
								EndIf
	
							EndIf
							oGFEXFBFLog:setTexto(" * " + If(lRotaVldDes, STR0602 + " (" + AllTrim(GV8->GV8_CDDEST) + " - " + cDsDest + ")-> OK", STR0603 + " (" + AllTrim(GV8->GV8_CDDEST) + " - " + cDsDest + ") -> " + STR0609)) //"Correspondente" ### "Diferente" ### "INVALIDO"
						EndIf
					oGFEXFBFLog:setTexto(CRLF)
					EndIf
	
					//caso rota seja invalida, porem duplo sentido, loop verifica sentido inverso
					If (!lRotaVld .Or. !lRotaVldDes) .And. GV8->GV8_DUPSEN == "1" .And. nLoop++ == 0
						
						lGFEXFB14 := .T.
						If lPEXFB14
							lGFEXFB14 := ExecBlock("GFEXFB14")			
						EndIf	
						If lGFEXFB14
							cCidOri := (cTRBTRE)->DESTIN
							cCidDes := (cTRBTRE)->ORIGEM
							
							//inverte os ceps
							cNewCepOri := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDDEST,"GU3_CEP")
							cNewCepDes := Posicione("GU3",1,xFilial("GU3")+GW1->GW1_CDREM,"GU3_CEP")
							
							cRegTab := GV8->GV8_NRREDS 
							
							lODOriginal	:= .F. // .T. - Origem e destino original / .F. - Inverte Origem e Destino
							Loop
						EndIf
					EndIf
					
					lODOriginal := .T.
	
					//rota invalida e' excluida
					If !lRotaVld .Or. !lRotaVldDes
						If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
							(cTRBSIM)->(dbSetOrder(2))
							If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
								RecLock(cTRBSIM,.F.)
								(cTRBSIM)->VALROT := "NAO"
								(cTRBSIM)->DESROT := STR0608 + ": " + cDsOrig + " x " + STR0611 + ": " + cDsDest
								(cTRBSIM)->(MsUnLock())
							EndIf
						EndIf
	
						If (nPos := AScan(aChvRot,{|x| x[1] == (cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA})) != 0
							ADel(aChvRot,nPos)
							ASize(aChvRot,Len(aChvRot)-1)
						EndIf
	
						RecLock(cTRBSTF,.F.)
						(cTRBSTF)->(dbDelete())
						(cTRBSTF)->(MsUnLock())
	
					Else
						//grava descricao da rota
						If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
							(cTRBSIM)->(dbSetOrder(2))
							If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
								RecLock(cTRBSIM,.F.)
								(cTRBSIM)->VALROT := "SIM"
								(cTRBSIM)->ROTSEL := "1"
								(cTRBSIM)->DESROT := STR0608 + ": " + cDsOrig + " x " + STR0611 + ": " + cDsDest
								(cTRBSIM)->(MsUnLock())
							EndIf
						EndIf
						
						If cTpOrig == "0" .Or. cTpDest == "0" .Or. s_GFETROT == "2"
							
							aAdd(aTRBROT1,  {(cTRBSTF)->NRCALC ,; //Numero do Calculo
							                 (cTRBSTF)->EMIVIN ,; //Chave negociação pai
							                 (cTRBSTF)->TABVIN ,; //Chave negociação pai
							                 (cTRBSTF)->NRNEG  ,; //Chave negociação pai
							                 GV8->GV8_NRROTA   ,; //Chave negociação pai
							                 ""                ,; //Chave negociação pai
							                 (cTRBSTF)->EMIVIN ,; //Chave negociação filha
							                 (cTRBSTF)->TABVIN ,; //Chave negociação filha
							                 (cTRBSTF)->NRNEG  ,; //Chave negociação filha
							                  GFEXBEGetP(cTpOrig,cTpDest) ,; //Prioridade
							                  0                ,; //Prioridade Faixa
							                  GV8->GV8_NRROTA  ,; //Todas as rotas
							                  ""  })              //Todas as faixas
						EndIf
						RecLock(cTRBSTF,.F.)
						(cTRBSTF)->DESROT := STR0608 + ": " + cDsOrig + " x " + STR0611 + ": " + cDsDest
						(cTRBSTF)->(MsUnLock())
						
						If lDemaisOri
							aAdd(aRotDemOri,{(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							lDemaisOri := .F.
						EndIf
						If lDemaisDes
							aAdd(aRotDemDes,{(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							lDemaisDes := .F.
						EndIf
						
						If lCidOri
							aAdd(aRotCidOri,{(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							lCidOri := .F.
						Endif
						If lCidDes
							aAdd(aRotCidDes,{(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							lCidDes := .F.
						Endif
					EndIf
	
					nLoop := 0
	
					(cTRBSTF)->(dbSkip())
				EndDo
				
				aSort(aTRBROT1,,,{|x,y| x[1] + x[2] + x[3] + x[4] + x[5] < y[1] + y[2] + y[3] + y[4] + y[5] })
	
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
					(cTRBSTF)->(dbSetOrder(1) )
					(cTRBSTF)->(dbGoTop() )
					While !(cTRBSTF)->(EOF() )
						oGFEXFBFLog:setTexto(CRLF + "          Transp " + AllTrim((cTRBSTF)->CDTRP) + "; Tabela " + AllTrim((cTRBSTF)->NRTAB) + "; Negoc. " + AllTrim((cTRBSTF)->NRNEG) + ;
								 "; Rota " + AllTrim((cTRBSTF)->NRROTA) + "; Tp.Tab. " + If((cTRBSTF)->TPTAB=="1", STR0598, STR0599))
						If (nPos := AScan(aChvRot,{|x| x[1] == (cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA})) == 0
							RecLock(cTRBSTF, .F.)
								(cTRBSTF)->(dbDelete())
							(cTRBSTF)->(MsUnlock())
							
							GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							
							oGFEXFBFLog:setTexto(" -> ELIMINADA" + CRLF)
						Else
							oGFEXFBFLog:setTexto(" -> PRIORIZADA" + CRLF)
						EndIf
	
						(cTRBSTF)->(dbSkip() )
					EndDo
	
				EndIf
	
				//------------------------------------------------------------------------------------------
				// Se existirem rotas específicas, deve verificar se existem rotas do tipo demais cidades
				// para o mesmo transportador/tabela de frete/negociação, e removê-las da tabela temporária.
				// O sistema deve considerar, para efeito de cálculo, sempre as rotas mais específicas.
				//------------------------------------------------------------------------------------------
				If Len(aRotCidOri) > 0
					For nX := 1 to len(aRotDemOri)
						(cTRBSTF)->(dbSetOrder(03))
						// Verifica se a rota ainda não foi eliminada da tabela temporária
						If (cTRBSTF)->(dbSeek(aRotDemOri[nX,1]+aRotDemOri[nX,2]+aRotDemOri[nX,3]+aRotDemOri[nX,4]))
							// Verifica se a rota demais cidadades diz respeito ao mesmo transportador/tab. frete/negociação
							If AScan(aRotCidOri,{|x| x[1]+x[2]+x[3] == aRotDemOri[nX,1]+aRotDemOri[nX,2]+aRotDemOri[nX,3]}) > 0
								GV8->(dbSetOrder(1))
								If GV8->(dbSeek(xFilial("GV8") + (cTRBSTF)->CDTRP + (cTRBSTF)->NRTAB + (cTRBSTF)->NRNEG + (cTRBSTF)->NRROTA ))
									GU9->(dbSetOrder(1) )
									If GU9->(dbSeek(xFilial("GU9")+GV8->GV8_NRREOR) )
										If GU9->GU9_DEMCID == '1'
											// Elimina a rota demais cidades
											RecLock(cTRBSTF,.F.)
											(cTRBSTF)->(DbDelete())
											(cTRBSTF)->(MsUnlock())
											GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					Next nX
				EndIf
	
				If Len(aRotCidDes) > 0
					For nX := 1 to len(aRotDemDes)
						(cTRBSTF)->(dbSetOrder(03))
						// Verifica se a rota ainda não foi eliminada da tabela temporária
						If (cTRBSTF)->(dbSeek(aRotDemDes[nX,1]+aRotDemDes[nX,2]+aRotDemDes[nX,3]+aRotDemDes[nX,4]))
							// Verifica se a rota demais cidadades diz respeito ao mesmo transportador/tab. frete/negociação
							If AScan(aRotCidDes,{|x| x[1]+x[2]+x[3] == aRotDemDes[nX,1]+aRotDemDes[nX,2]+aRotDemDes[nX,3]}) > 0
								GV8->(dbSetOrder(1))
								If GV8->(dbSeek(xFilial("GV8") + (cTRBSTF)->CDTRP + (cTRBSTF)->NRTAB + (cTRBSTF)->NRNEG + (cTRBSTF)->NRROTA ))
									GU9->(dbSetOrder(1) )
									If GU9->(dbSeek(xFilial("GU9")+GV8->GV8_NRREDS) )
										If GU9->GU9_DEMCID == '1'
											// Elimina a rota demais cidades
											RecLock(cTRBSTF,.F.)
											(cTRBSTF)->(DbDelete())
											(cTRBSTF)->(MsUnlock())
											GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					Next nX
				EndIf
	
				//percorre tabelas pre-selecionadas
				oGFEXFBFLog:setTexto(CRLF + STR0073 + CRLF) //"    # Filtrando tabelas pre-selecionadas - FAIXAS/TIPO VEICULOS: "
	
				(cTRBSTF)->(dbGoTop() )
				While !(cTRBSTF)->(EOF() )
	
					nQtPrazo := 0
	
					oGFEXFBFLog:setTexto(CRLF + STR0074 + (cTRBSTF)->EMIVIN + STR0067 + (cTRBSTF)->TABVIN + STR0068 + (cTRBSTF)->NRNEG +; //"      Transp. "###"; Tabela "###"; Negoc. "
					         STR0069 + (cTRBSTF)->NRROTA + STR0075 + If((cTRBSTF)->TPTAB=="1", STR0076, STR0077) + CRLF) //"; Rota "###"; Tp.Tab. "###"Normal"###"Vinculo"
	
					
					lTemCrgCmp := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5, "PERCOUT") != 0
					
					If !lTemCrgCmp
						nPesoCubado := GFEPesoCub((cTRBSTF)->QTKGM3, (cTRBTCF)->CDCLFR, (cTRBTCF)->NRCALC,(cTRBTCF)->VOLUME)
					Else
						nPesoCubado := GFEPesoCub((cTRBSTF)->QTKGM3, (cTRBTCF)->CDCLFR, (cTRBTCF)->NRCALC)
						GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUBORG",nPesoCubado)
						nPesoCubCrg := GFEPesoCub((cTRBSTF)->QTKGM3, (cTRBTCF)->CDCLFR, (cTRBTCF)->NRCALC, (cTRBTCF)->VOLUME)
						If nPesoCubado > 0 .And. nPesoCubCrg > 0 .And. nPesoCubCrg > (cTRBTCF)->PESOR .And. nPesoCubCrg > nPesoCubado
							If GetNewPar("MV_CRIRAT", "5") == '1'
								GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5, "PERCOUT" , (nPesoCubCrg - nPesoCubado) / ( nPesoCubCrg ) )
							EndIf
							nPesoCubado := nPesoCubCrg
						EndIf
					EndIf
	
					If (cTRBSTF)->TPLOTA == "1"  //tipo lotacao : 1=carga fracionada
						//***************
						//*VALIDA FAIXAS*
						//***************
						nQtdFaixa := 0
						nPesoCubado   := 0
	
					 	oGFEXFBFLog:setTexto(STR0612 + GFEFldInfo("GV9_ATRFAI",IIf((cTRBSTF)->ATRFAI=="10","8",(cTRBSTF)->ATRFAI),2)) //"        Faixa baseada em "
					 	
					 	//cUnitiliz := RetUnitili(GV1->GV1_CDCOMP)									
					 	
						nQtdFaixa := GFEQtdeComp(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU"),;
	  			                                 (cTRBTCF)->NRCALC,;
				                                 (cTRBTCF)->CDCLFR,;
				                                 (cTRBSTF)->ATRFAI,;
				                                 (cTRBTCF)->QTDE  ,;
	  					                         (cTRBTCF)->PESOR ,;
				                                 (cTRBTCF)->VALOR ,;
				                                 (cTRBTCF)->VALLIQ,;
				                                 (cTRBTCF)->VOLUME,;
				                                 (cTRBSTF)->QTKGM3,;
				                                 @nPesoCubado         ,; // Peso cubado a ser atualizado pela função
				                                 (cTRBSTF)->UNIFAI,;
				                                 (cTRBTCF)->QTDALT,;
				                                 0,;
				                                 "1",;
				                                 If(!Empty(cTpLocEntr), "1",""),;
				                                 GFEXFBLOCE((cTRBTCF)->NRCALC),;
				                                 .T.,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"))
	
						oGFEXFBFLog:setTexto(" " + cValToChar(nQtdFaixa) + CRLF)
	
						cCodFaixa := ""
						cTodFaixa := ""
						//seleciona faixa valida para o valor encontrado
						GV7->(dbSetOrder(01))
						GV7->(dbSeek(xFilial("GV7")+(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG,.T.))
						While !GV7->(Eof()) .And. ;
							GV7->GV7_FILIAL == xFilial("GV7")   .And. GV7->GV7_CDEMIT == (cTRBSTF)->CDTRP .And.;
							GV7->GV7_NRTAB  == (cTRBSTF)->NRTAB .And. GV7->GV7_NRNEG  == (cTRBSTF)->NRNEG
							
							If GV7->GV7_QTFXFI == 0
								cTodFaixa := GV7->GV7_CDFXTV
								cCodFaixa := GV7->GV7_CDFXTV
							EndIf
							
							If nQtdFaixa <= GV7->GV7_QTFXFI
								cCodFaixa	:= GV7->GV7_CDFXTV
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
							If GV6->(dbSeek(xFilial("GV6")+(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+cCodFaixa+(cTRBSTF)->NRROTA)) .And. lTariVali
	
								If GV6->GV6_CONSPZ == "0" // Tabela de prazos
									aTabPrazo    := GFEPrazoTre(xFilial("GWU"), (cTRBTRE)->CDTPDC, (cTRBTRE)->EMISDC, (cTRBTRE)->SERDC, (cTRBTRE)->NRDC, (cTRBTRE)->SEQ)
	
									// Classificação de Frete
									aTabPrazo[10] := (cTRBTCF)->CDCLFR
	
						            //////// CEP DE/ORIGEM ////////
						            If !Empty((cTRBTRE)->CEPO)
						            	aTabPrazo[13] := (cTRBTRE)->CEPO
						            Else
						            	aTabPrazo[13] := Posicione("GU3",1,xFilial("GU3")+aTabPrazo[1],"GU3_CEP")
						            EndIf
	            		            //////// CEP DE/ORIGEM ////////
	
			                        //////// CEP PARA/DESTINO ////////
				            		If !Empty((cTRBTRE)->CEPD)
						            	aTabPrazo[14] := (cTRBTRE)->CEPD
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
	
								RecLock(cTRBSTF,.F.)
								(cTRBSTF)->CDFXTV  := cCodFaixa
								(cTRBSTF)->PRAZO   := nQtPrazo
								(cTRBSTF)->TPVCFX  := "FAIXAS"
								(cTRBSTF)->CONTPZ  := cContPz
								(cTRBSTF)->(MsUnLock())
								If lSimulacao .AND. iTipoSim == 0
									(cTRBSIM)->(dbSetOrder(2))
									If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
										RecLock(cTRBSIM,.F.)
										(cTRBSIM)->VALFAI := "SIM"
										(cTRBSIM)->QTFAIXA := nQtdFaixa
										(cTRBSIM)->(MsUnLock())
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
						If Empty((cTRBSTF)->CDFXTV)
		  					If lSimulacao .AND. iTipoSim == 0
								(cTRBSIM)->(dbSetOrder(2))
								If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
									RecLock(cTRBSIM,.F.)
									(cTRBSIM)->VALFAI := "NAO"
									(cTRBSIM)->(MsUnLock())
								EndIf
							Else
								RecLock(cTRBSTF,.F.)
									(cTRBSTF)->(dbDelete())
								(cTRBSTF)->(MsUnLock())
								GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							EndIf
			  			Else
							RecLock(cTRBSTF,.F.)
								(cTRBSTF)->QTFAIXA := nQtdFaixa
							(cTRBSTF)->(MsUnLock())
							GFEAddTodFx(cTodFaixa,cCodFaixa)
						EndIf
					Else //tipo lotacao : 2=carga fechada  ou 3 = Veículo Dedicado
						If (cTRBSTF)->TPLOTA == "3"
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
						// Fim Ponto de Entrada Harley Davidson
						//posiciona no agrupador para selecionar cod. tipo veiculo
						(cTRBAGRU)->(dbSetOrder(01))
						If (cTRBAGRU)->(dbSeek(GFEXFB_5CMP(.F.,, @aTRBGRB3, 4,"NRAGRU")))
							
							//Se não for o primeiro trecho ou Se o parâmetro do tipo de veículo para calculo  
							//for diferente de 1 utiliza o veículo informado no trecho.
							If nI == 1 .Or. p_TpVeic == '1'
								//Se não houver tipo de veiculo informado no agrupador, utiliza o do trecho
								cCdTpVei := If( Empty( (cTRBAGRU)->CDTPVC ),(cTRBTRE)->CDTPVC,(cTRBAGRU)->CDTPVC )
							Else
								cCdTpVei := (cTRBTRE)->CDTPVC 
							EndIf

							If !Empty(cCdTpVei) .Or. lSmlVei
								//percorre faixa/tp veiculo tabela de frete procurando o mesmo tipo de veiculo
								GV7->(dbSetOrder(01))
								GV7->(dbSeek(xFilial("GV7")+(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG,.T.))
								While !GV7->(Eof()) .And. ;
									GV7->GV7_FILIAL == xFilial("GV7")   .And. GV7->GV7_CDEMIT == (cTRBSTF)->CDTRP .And.;
									GV7->GV7_NRTAB  == (cTRBSTF)->NRTAB .And. GV7->GV7_NRNEG  == (cTRBSTF)->NRNEG
	
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
										// Verifica o prazo
										GV6->(dbSetOrder(01))
										If GV6->(dbSeek(xFilial("GV6")+(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+GV7->GV7_CDFXTV+(cTRBSTF)->NRROTA))
											
											If GV6->GV6_CONSPZ == "0" // Tabela de prazos
												aTabPrazo    := GFEPrazoTre(xFilial("GW1"), (cTRBTRE)->CDTPDC, (cTRBTRE)->EMISDC, (cTRBTRE)->SERDC, (cTRBTRE)->NRDC, (cTRBTRE)->SEQ)
												aTabPrazo[10] := (cTRBTCF)->CDCLFR
									            //////// CEP DE/ORIGEM ////////
									            If !Empty((cTRBTRE)->CEPO)
									            	aTabPrazo[13] := (cTRBTRE)->CEPO
									            Else
									            	aTabPrazo[13] := Posicione("GU3",1,xFilial("GU3")+aTabPrazo[1],"GU3_CEP")
									            EndIf
			            			            //////// CEP DE/ORIGEM ////////
	
						                        //////// CEP PARA/DESTINO ////////
						                        If !Empty((cTRBTRE)->CEPD)
									            	aTabPrazo[14] := (cTRBTRE)->CEPD
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
											If ( GV7->GV7_CDFXTV == cTodFaixa .And. Empty((cTRBSTF)->CDTPVC) ) .Or. cCdTpVei == GV7->GV7_CDTPVC
												RecLock(cTRBSTF,.F.)
												(cTRBSTF)->CDTPVC := cCdTpVei
												(cTRBSTF)->CDFXTV := GV7->GV7_CDFXTV
												If lExiVLALUG
													(cTRBSTF)->QTCOTA	:= GV7->GV7_QTCOTA
													(cTRBSTF)->VLALUG	:= GV7->GV7_VLALUG
													(cTRBSTF)->FRQKM	:= GV7->GV7_FRQKM
													(cTRBSTF)->VLKMEX	:= GV7->GV7_VLKMEX
												EndIf
												(cTRBSTF)->PRAZO  := nQtPrazo
												(cTRBSTF)->TPVCFX := "VEICULOS"
												(cTRBSTF)->(MsUnLock())
											EndIf
	
											If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
												(cTRBSIM)->(dbSetOrder(2))
												If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
													RecLock(cTRBSIM,.F.)
														(cTRBSIM)->VALTPVC := "SIM"
													(cTRBSIM)->(MsUnLock())
												EndIf
											EndIf
	
											oGFEXFBFLog:setTexto("      *** " + STR0613 + cCodFaixa + STR0617 + (cTRBSTF)->CDFXTV + "). " + STR0618 + cValtoChar(nQtPrazo) + CRLF) //"Faixa selecionada " ### " (Tipo Veiculo " ### "Prazo (em horas): "
										EndIf									
									EndIf
	
									GV7->(dbSkip())
								EndDo
							EndIf
						EndIf
	
						//exclui rota/tipo de veículo selecionado caso nao haja tipo veiculo
						If Empty((cTRBSTF)->CDTPVC)
	
							//Pode não existir tarifa para faixa/tipo de veículo ou
							//Pode não haver grupos de entrega (???) para a TABELA.
							If !Empty(cCdTpVei) 
								oGFEXFBFLog:setTexto("      *** Não existe tarifa para a faixa (Tipo veículo). " + CRLF) //"Não existe tarifa para a faixa (Tipo de veículo " ### ").
							Else
								oGFEXFBFLog:setTexto("      *** " + STR0619 + CRLF) //"Nao existem faixas de tipo de veículo válidas para a tabela."
							EndIf
							If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
								(cTRBSIM)->(dbSetOrder(2))
								If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
									RecLock(cTRBSIM,.F.)
										(cTRBSIM)->VALTPVC := "NAO"
									(cTRBSIM)->(MsUnLock())
								EndIf
							Else
							  	RecLock(cTRBSTF,.F.)
							  		(cTRBSTF)->(dbDelete())
								(cTRBSTF)->(MsUnLock())
								GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							EndIf
	
						Else
							If (cTRBSTF)->TPLOTA $ "2;3"
								AAdd(aDelTpVc, (cTRBSTF)->NRROM + (cTRBSTF)->NRTAB + (cTRBSTF)->NRNEG + (cTRBSTF)->NRROTA)
							EndIf
							GFEAddTodFx(cTodFaixa,(cTRBSTF)->CDFXTV)
						EndIf
					EndIf
	
					(cTRBSTF)->(dbSkip())
				EndDo
				
				aSort(aTRBROT1,,,{|x,y| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + STRZERO(x[10],6) + STRZERO(x[11],6) < y[1] + y[2] + y[3] + y[4] + y[5] + y[6] + STRZERO(y[10],6) + STRZERO(y[11],6) })
				
				//************************
				//*VALIDA DATA VIGENCIA  *
				//************************
				If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
					(cTRBSTF)->(dbSetOrder(03))
					(cTRBSTF)->(dbGoTop())
					While !(cTRBSTF)->(Eof())
						(cTRBSIM)->(dbSetOrder(2))
						If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
							While !(cTRBSIM)->(Eof()) .And. (cTRBSIM)->NRCALC  == (cTRBSTF)->NRCALC .And. (cTRBSIM)->CDCLFR  == (cTRBSTF)->CDCLFR .And. (cTRBSIM)->CDTPOP  == (cTRBSTF)->CDTPOP .And.;
											   (cTRBSIM)->EMIVIN  == (cTRBSTF)->EMIVIN .And. (cTRBSIM)->TABVIN  == (cTRBSTF)->TABVIN .And. (cTRBSIM)->NRNEG   == (cTRBSTF)->NRNEG  .And. (cTRBSIM)->NRROTA  == (cTRBSTF)->NRROTA
		           	               	If (cTRBSIM)->VALROT == "NAO" .OR. ((cTRBSIM)->VALFAI == "NAO" .OR. (cTRBSIM)->VALTPVC == "NAO") .OR. (cTRBSIM)->VALDATA == "NAO"
										RecLock(cTRBSTF,.F.)
											(cTRBSTF)->(dbDelete())
										(cTRBSTF)->(MsUnLock())
										GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
									EndIf
			   			   		(cTRBSIM)->(dbSkip())
			   				EndDo
						Endif
						(cTRBSTF)->(dbSkip())
					EndDo
				Endif
				
				If !Empty(aDelTpVc)
					//Percorre tabelas pré-selecionadas e apaga caso haja tabela informada por tipo de veículo
					(cTRBSTF)->(dbSetOrder(1) )
	
					For nX := 1 To Len(aDelTpVc)
						If (cTRBSTF)->(dbSeek(aDelTpVc[nX]) )
	
							oGFEXFBFLog:setTexto(CRLF + "        Foram encontradas Tabelas de Frete por Tipo de Veículo válidas, elas serão priorizadas na seleção, " + ;
								 "as demais rotas serão eliminadas." + CRLF)
	
							(cTRBSTF)->(dbGoTop() )
							While !(cTRBSTF)->(EOF() )
	
								oGFEXFBFLog:setTexto(CRLF + "          Transp " + AllTrim((cTRBSTF)->CDTRP) + "; Tabela " + AllTrim((cTRBSTF)->NRTAB) + "; Negoc. " + AllTrim((cTRBSTF)->NRNEG) + ;
										 "; Rota " + AllTrim((cTRBSTF)->NRROTA) + "; Tp.Tab. " + If((cTRBSTF)->TPTAB=="1", STR0598, STR0599))
	
								If !((cTRBSTF)->TPLOTA $ "2;3")
									RecLock(cTRBSTF, .F.)
										(cTRBSTF)->(dbDelete())
									(cTRBSTF)->(MsUnlock())
									
									GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
									oGFEXFBFLog:setTexto(" -> ELIMINADA" + CRLF)
								Else
									oGFEXFBFLog:setTexto(" -> PRIORIZADA" + CRLF)
								EndIf
	
								(cTRBSTF)->(dbSkip() )
							EndDo
	
							Exit
						EndIf	
					Next nX	
				EndIf				
				
				oGFEXFBFLog:setTexto(CRLF + STR0620 + CRLF + CRLF) //"    # Filtrando tabelas pre-selecionadas - DATA VIGÊNCIA: "
				cChave := ""
				(cTRBSTF)->(dbSetOrder(03))
				(cTRBSTF)->(dbGoTop())
				While !(cTRBSTF)->(Eof())
	
					dDataCalc := Iif(!Empty(DTOS(GWN->GWN_DTSAI)),DTOS(GWN->GWN_DTSAI),DTOS(dDataBase))
					
					aGV9 := {/* chave, quantidade de dias que a tabela esta vigente, nr.tab, nr.neg, transportador */}
					cChave := (cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN
					While !(cTRBSTF)->(Eof()) .And. (cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN == cChave
						aAdd(aGV9,{(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG,SToD(dDataCalc)-(cTRBSTF)->DTVALI,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->EMIVIN})
						(cTRBSTF)->(dbSkip())
					EndDo
					nRec := (cTRBSTF)->(RecNo())
					aSort(aGV9,,,{|x,y|x[2] < y[2]}) //ordena por tempo de vigencia, sendo a posicao 1 a menor vigencia
	
					oGFEXFBFLog:setTexto(STR0074 + aGV9[1,5] + STR0078 + aGV9[1,3] + STR0079 + aGV9[1,4] + STR0080 + DToS(SToD(dDataCalc)-aGV9[1,2]) + " (" + cValToChar(aGV9[1,2]) + STR0081 + CRLF) //"      Tabela "###", Negoc "###" vigente desde "###" dias) -> OK"
	
					For nX := 2 To Len(aGV9)
						oGFEXFBFLog:setTexto(STR0074 + aGV9[nX,5] + STR0078 + aGV9[nX,3] + STR0079 + aGV9[nX,4] + STR0080 + DToS(Iif(!Empty(GWN->GWN_DTSAI),GWN->GWN_DTSAI,dDataBase)-aGV9[nX,2]) + " (" + cValToChar(aGV9[nX,2]) + STR0082) //"      Tabela "###", Negoc "###" vigente desde "###" dias)"
						If (aGV9[nX,2] != aGV9[1,2]) //se a vigencia nao for igual a vigencia da negociacao que e' valida
							(cTRBSTF)->(dbSetOrder(03))
							If (cTRBSTF)->(dbSeek(aGV9[nX,1]))
						  		If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
									(cTRBSIM)->(dbSetOrder(2))
									If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
										RecLock(cTRBSIM,.F.)
											(cTRBSIM)->VALDATA := "NAO"
										(cTRBSIM)->(MsUnLock())
									EndIf
								Else
									RecLock(cTRBSTF,.F.)
										(cTRBSTF)->(dbDelete())
									(cTRBSTF)->(MsUnLocK(cTRBSTF))
									GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
					   			EndIf
								oGFEXFBFLog:setTexto(STR0083 + CRLF) //" -> INVALIDO"
							EndIf
						Else
							oGFEXFBFLog:setTexto(STR0084 + CRLF) //" -> OK"
						EndIf
					Next nX
					(cTRBSTF)->(dbGoTo(nRec))
				EndDo
	
				If lSimulacao .AND. iTipoSim == 0
	
					(cTRBSTF)->(dbSetOrder(1))
					(cTRBSTF)->(dbgotop())
					While !(cTRBSTF)->(Eof())
						(cTRBSIM)->(dbSetOrder(2))
						If (cTRBSIM)->(dbSeek((cTRBSTF)->NRCALC+(cTRBSTF)->CDCLFR+(cTRBSTF)->CDTPOP+(cTRBSTF)->EMIVIN+(cTRBSTF)->TABVIN+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA))
							If (cTRBSIM)->VALROT == "NAO" .OR. ((cTRBSIM)->VALFAI == "NAO" .OR. (cTRBSIM)->VALTPVC == "NAO") .OR. (cTRBSIM)->VALDATA == "NAO"
								RecLock(cTRBSTF,.F.)
								(cTRBSTF)->(dbDelete())
								(cTRBSTF)->(MsUnLock())
								GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							Else
								RecLock(cTRBSIM,.F.)
								(cTRBSIM)->SELEC  := "1"
								(cTRBSIM)->CDFXTV := (cTRBSTF)->CDFXTV
								(cTRBSIM)->CDTPVC := (cTRBSTF)->CDTPVC
								(cTRBSIM)->(MsUnLock())
							EndIf
						EndIf
					    (cTRBSTF)->(dbSkip())
					EndDo
	
				EndIf
				
				//elimina tabelas invalidas excluidas do arquivo de pre-selecao
				(cTRBSTF)->(dbGoTop() )
	
				If lTpLota3 .And. lExiVLALUG .And. !(cTRBSTF)->(Eof())
					//// Verifica Divergencias entre tipos de lotação da seleção da tabela de Frete
					oGFEXFBFLog:setTexto(CRLF + "      Verificando divergências nas Tabelas Selecionadas: ")
					While !(cTRBSTF)->(Eof())
	
						If (nDiver:= aScan(aVerDiver,{|x| x[1] != (cTRBSTF)->TPLOTA .Or. x[2] != (cTRBSTF)->QTCOTA .Or. x[3] != (cTRBSTF)->VLALUG .Or. x[4] != (cTRBSTF)->FRQKM .Or. x[5] != (cTRBSTF)->VLKMEX } )) == 0
							aAdd(aVerDiver,{(cTRBSTF)->TPLOTA,(cTRBSTF)->QTCOTA,(cTRBSTF)->VLALUG, (cTRBSTF)->FRQKM, (cTRBSTF)->VLKMEX, (cTRBSTF)->NRTAB, (cTRBSTF)->NRNEG})
						Else
							If aVerDiver[nDiver][1] != (cTRBSTF)->TPLOTA
								GFEXFBAEC((cTRBUNC)->NRCALC, 21, , {"os Tipos de Lotação"})
								oGFEXFBFLog:setTexto(CRLF + "      ###### Tipos de Lotação Divergentes!" + CRLF + "        Tabela      Negociação  Tipo de Lotação" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + aVerDiver[nDiver][1] + CRLF + "        " + PadR((cTRBSTF)->NRTAB,12," ") + PadR((cTRBSTF)->NRNEG,12," ") + (cTRBSTF)->TPLOTA + CRLF )
							EndIf
							If aVerDiver[nDiver][2] != (cTRBSTF)->QTCOTA
								GFEXFBAEC((cTRBUNC)->NRCALC, 21, , {"as Quantidades de Cotas"})
								oGFEXFBFLog:setTexto(CRLF + "      ###### Cotas Mínimas Divergentes!" + CRLF + "        Tabela      Negociação  Cota Mínima" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + cValToChar(aVerDiver[nDiver][2]) + CRLF + "        " + PadR((cTRBSTF)->NRTAB,12," ") + PadR((cTRBSTF)->NRNEG,12," ") + cValToChar((cTRBSTF)->QTCOTA) + CRLF )
							EndIf
							If aVerDiver[nDiver][3] != (cTRBSTF)->VLALUG
								GFEXFBAEC((cTRBUNC)->NRCALC, 21, , {"os Valores da Locação"})
								oGFEXFBFLog:setTexto(CRLF + "      ###### Valores da Locação Divergentes!" + CRLF + "        Tabela      Negociação  Valor da Locação" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + cValToChar(aVerDiver[nDiver][3]) + CRLF + "        " + PadR((cTRBSTF)->NRTAB,12," ") + PadR((cTRBSTF)->NRNEG,12," ") + cValToChar((cTRBSTF)->VLALUG) + CRLF )
							EndIf
							If aVerDiver[nDiver][4] != (cTRBSTF)->FRQKM
								GFEXFBAEC((cTRBUNC)->NRCALC, 21, , {"as Franquias em Quilômetros"})
								oGFEXFBFLog:setTexto(CRLF + "      ###### Franquias Km Divergentes!" + CRLF + "        Tabela      Negociação  Franquia Km" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + cValToChar(aVerDiver[nDiver][4]) + CRLF + "        " + PadR((cTRBSTF)->NRTAB,12," ") + PadR((cTRBSTF)->NRNEG,12," ") + cValToChar((cTRBSTF)->FRQKM) + CRLF )
							EndIf
							If aVerDiver[nDiver][5] != (cTRBSTF)->VLKMEX
								GFEXFBAEC((cTRBUNC)->NRCALC, 21, , {"as Tarifas por KM excedido franquia"})
								oGFEXFBFLog:setTexto(CRLF + "      ###### Val Km Exced Divergentes!" + CRLF + "        Tabela      Negociação  Val Km Exced" + CRLF + "        " + PadR(aVerDiver[nDiver][6],12," ") + PadR(aVerDiver[nDiver][7],12," ") + cValToChar(aVerDiver[nDiver][5]) + CRLF + "        " + PadR((cTRBSTF)->NRTAB,12," ") + PadR((cTRBSTF)->NRNEG,12," ") + cValToChar((cTRBSTF)->VLKMEX) + CRLF )
							EndIf
							RecLock(cTRBSTF, .F.)
								(cTRBSTF)->(dbDelete())
							(cTRBSTF)->(MsUnlock())
							GFEXFBDROT({(cTRBSTF)->NRCALC,(cTRBSTF)->EMIVIN,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA})
							oGFEXFBFLog:setTexto(CRLF + "          Transp " + AllTrim((cTRBSTF)->CDTRP) + "; Tabela " + AllTrim((cTRBSTF)->NRTAB) + "; Negoc. " + AllTrim((cTRBSTF)->NRNEG) + ;
										 "; Rota " + AllTrim((cTRBSTF)->NRROTA) + " -> ELIMINADA" + CRLF)
						EndIf
						(cTRBSTF)->(dbSkip())
					EndDo
				EndIf
				
				(cTRBSTF)->(dbGoTop() )
				nNumRegSTF := GFENumReg(cTRBSTF)
				aArea := (cTRBSTF)->(GetArea())
				(cTRBSTF)->(dbSetOrder(2))
				If nNumRegSTF > 1 // priorizar / eliminar rotas do tipo todas as rotas. elas serão adicionados em outras.
					If GFEXFBMTR()
						(cTRBSTF)->(dbGoTop() )
						nNumRegSTF := GFENumReg(cTRBSTF)
					EndIf
				EndIf
				RestArea(aArea)
				aSort(aTRBROT1,,,{|x,y| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + STRZERO(x[10],6) + STRZERO(x[11],6) < y[1] + y[2] + y[3] + y[4] + y[5] + y[6] + STRZERO(y[10],6) + STRZERO(y[11],6) })
				oGFEXFBFLog:setTexto(CRLF + STR0085 + cValToChar( nNumRegSTF ) + CRLF) //"      Total de tabelas válidas: "
				(cTRBSTF)->(dbGoTop() )
			
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
							EndIf
							nNumRegSTF--
						Else
							Exit
						EndIf
						
						GFEXFB_8SKIP(lTabTemp, cTRBSTF, 2)
					EndDo
					
					GFEXFB_2TOP(lTabTemp, cTRBSTF, @aTRBSTF1, 2)
				EndIf
				
				If nNumRegSTF > 1 // Simular o frete para cada tabela encontrada
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
							If Empty((cTRBTRE)->CDTRP)  /*trecho em branco*/
								GFESimulFret()//Função usada para calcular todos as tabelas de frete encontrada
							Else
								GFEXFBETVL()
								/*deletar não selecionadas*/
								nPosFret := (cTRBSTF)->(RecNo()) //Salva o registro posicionado na tabela
								(cTRBSTF)->(dbGoTop() )//Vai ao primeiro registro
									While !(cTRBSTF)->(EOF() ) .And. (cTRBSTF)->(RecNo()) != nPosFret //Enquanto o indice for diferente do salvo no Recno
										RecLock(cTRBSTF,.F.)
										(cTRBSTF)->(dbDelete()) //Apaga o registro
										(cTRBSTF)->(MsUnLock())
										(cTRBSTF)->(dbSkip() )
									EndDo
								(cTRBSTF)->(dbGoTo(nPosFret) ) //Restaura o posicionamento salvo
							EndIf
						Else
							If s_ESCTAB == "1" // 1-pelo usuario
								if !lCalcServ
									GFESimulFret()
									GFEESCTAB(lShowTabFr)
								else
									// EDI não pode ter interação com o usuário pois o processo poderá estar rodando através do Schedule
									// Neste caso deverá utilizar o menor valor de frete encontrado
									if lEdi
										GFEXFBETVL()
									else
										GFESimulFret()
										GFEESCTAB(lShowTabFr)
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
				elseif nNumRegSTF == 0
					If lCalcServ .And. !IsInCallStack("GFEA032CA")
						cNrCalc := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
						idpAnt := (cTRBTCF)->(Recno())
						RecLock(cTRBTCF,.F.)
						(cTRBTCF)->(dbdelete())
						(cTRBTCF)->(MsUnLock())
						oGFEXFBFLog:setTexto("      *** Nao foi encontrada tabela válida para a classificação de frete da unidade." + " Desconsiderando do calculo do frete.") //
						GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
						If !GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{cNrCalc})
							RecLock(cTRBUNC,.F.)
								(cTRBUNC)->(dbdelete())
							(cTRBUNC)->(MsUnLock(cTRBUNC))
						EndIf
						(cTRBTCF)->(dbGoTo(idpAnt))
					Else
					  	RecLock(cTRBUNC,.F.)
						(cTRBUNC)->VALTAB := .F.	// Nao foi encontrada tabela valida para a unidade de calculo
						(cTRBUNC)->(MsUnLock())
						GFEXFBAEC((cTRBUNC)->NRCALC, 5)
		
						(cTRBAGRU)->(dbSetOrder(1))
						(cTRBAGRU)->(dbSeek((cTRBUNC)->NRAGRU))
						RecLock(cTRBAGRU,.F.)
							(cTRBAGRU)->ERRO := "1"
						(cTRBAGRU)->(MsUnLock())
		
						lError := .T.
						oGFEXFBFLog:setTexto(STR0090) //"      *** Nao foi encontrada tabela válida para a unidade de cálculo."
					EndIf
				EndIf
	
				// Se cálculo real ou simulação específica, atualiza a tabela da unidade de calculo
			 	If !(lSimulacao .AND. iTipoSim == 0) // 0-Simulação Geral, 1-Simulação Específica
					// Verifica se tem tarifa
					GV6->(dbSetOrder(01))
					If GV6->(dbSeek(xFilial("GV6")+(cTRBSTF)->CDTRP+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->CDFXTV+(cTRBSTF)->NRROTA))
	
						If !Empty(cPedRom)
							cPedRom += ","
						EndIf
	
						cPedRom += cValToChar((cTRBTCF)->(RecNo()))
	
						//grava tabela encontrada para o calculo de frete
						RecLock(cTRBTCF,.F.)
						if lTabInf .OR. Empty((cTRBTCF)->CDTRP)	// Tabela informada ou tabela de provisão
							(cTRBTCF)->CDTRP := (cTRBSTF)->EMIVIN
						EndIf
						(cTRBTCF)->NRTAB  := (cTRBSTF)->TABVIN
						(cTRBTCF)->NRNEG  := (cTRBSTF)->NRNEG
						(cTRBTCF)->NRROTA := (cTRBSTF)->NRROTA
						(cTRBTCF)->CDTPVC := (cTRBSTF)->CDTPVC
						(cTRBTCF)->CDFXTV := (cTRBSTF)->CDFXTV
						(cTRBTCF)->DTVIGE := (cTRBSTF)->DTVALI
						(cTRBTCF)->PESCUB := GFEPesoCub((cTRBSTF)->QTKGM3, (cTRBTCF)->CDCLFR, (cTRBTCF)->NRCALC, (cTRBTCF)->VOLUME) // Recupera a cubagem por classificação da tabela do transportador
						(cTRBTCF)->QTCALC := (cTRBSTF)->QTFAIXA      //quantidade para calculo
						(cTRBTCF)->PRAZO  := (cTRBSTF)->PRAZO
						(cTRBTCF)->(MsUnLock())
						
						If aScan(aTblFrFUNB,{|x| x[1]+x[2]+x[3]+x[4]+x[5]+x[6] == (cTRBSTF)->NRROM+(cTRBSTF)->NRTAB+(cTRBSTF)->NRNEG+(cTRBSTF)->NRROTA+(cTRBSTF)->CDFXTV+(cTRBSTF)->EMIVIN}) == 0
							aADD(aTblFrFUNB,{(cTRBSTF)->NRROM,(cTRBSTF)->TABVIN,(cTRBSTF)->NRNEG,(cTRBSTF)->NRROTA,(cTRBSTF)->CDFXTV,(cTRBSTF)->EMIVIN})
						EndIf
	
						oGFEXFBFLog:setTexto(CRLF + STR0091 + (cTRBSTF)->EMIVIN + STR0067 + (cTRBSTF)->TABVIN + STR0068 + (cTRBSTF)->NRNEG + STR0069 + (cTRBSTF)->NRROTA + STR0092 + (cTRBTCF)->CDFXTV +; //"      *** Seleção finalizada -> Transp. "###"; Tabela "###"; Negoc. "###"; Rota "###"; Faixa "
								 STR0093 + (cTRBTCF)->CDTPVC + STR0094 + DTOC((cTRBTCF)->DTVIGE) + STR0095 + cValToChar((cTRBTCF)->QTCALC) + STR0096 + cValToChar((cTRBSTF)->PRAZO) +; //"; Tp.Veic. "###"; Vigência "###"; Qtd.Calculo "###"; Prazo(h) "
	 						     STR0097 + cValToChar((cTRBSTF)->VLFRT) + CRLF) //"; Vl.Frete "
					ElseIf !lCalcServ .Or. IsInCallStack("GFEA032CA")
						// Não tem tarifa, tabela invalida
					  	RecLock(cTRBUNC,.F.)
						(cTRBUNC)->VALTAB := .F.	// Nao foi encontrada tabela valida para a unidade de calculo
						(cTRBUNC)->(MsUnLock())
						GFEXFBAEC((cTRBUNC)->NRCALC, 6)
	
						(cTRBAGRU)->(dbSetOrder(1))
						(cTRBAGRU)->(dbSeek((cTRBUNC)->NRAGRU))
						RecLock(cTRBAGRU,.F.)
							(cTRBAGRU)->ERRO := "1"
						(cTRBAGRU)->(MsUnLock())
	
						lError := .T.
						oGFEXFBFLog:setTexto(STR0098 + (cTRBSTF)->EMIVIN + STR0067 + (cTRBSTF)->TABVIN + STR0068 + (cTRBSTF)->NRNEG + STR0069 + (cTRBSTF)->NRROTA + STR0092 + (cTRBSTF)->CDFXTV +; //"      *** Foi encontrada tabela, mas não há tarifas para a mesma -> Transp. "###"; Tabela "###"; Negoc. "###"; Rota "###"; Faixa "
								 STR0093 + (cTRBSTF)->CDTPVC + STR0094 + DTOC((cTRBSTF)->DTVALI) + STR0095 + cValToChar((cTRBSTF)->QTFAIXA) + CRLF) //"; Tp.Veic. "###"; Vigência "###"; Qtd.Calculo "
					EndIf
				EndIf
			Else
				RecLock(cTRBUNC,.F.)
				(cTRBUNC)->VALTAB := .F.	// Não foi encontrada tabela valida para a unidade de calculo
				(cTRBUNC)->(MsUnLock())
	
				GFEXFBAEC((cTRBUNC)->NRCALC, 7)
	
				(cTRBAGRU)->(dbSetOrder(1))
				(cTRBAGRU)->(dbSeek((cTRBUNC)->NRAGRU))
				RecLock(cTRBAGRU,.F.)
					(cTRBAGRU)->ERRO := "1"
				(cTRBAGRU)->(MsUnLock())
	
				lError := .T.
				oGFEXFBFLog:setTexto(STR0099 + CRLF) //"      *** Nenhuma tabela foi selecionada!!!"
			EndIf
	
			(cTRBTCF)->(dbSkip())
		EndDo
	
		// Cria um novo TCF //TABELA DO CALCULO DE FRETE para cada tabela encontrada
		If lSimulacao .AND. iTipoSim == 0	// 0-Simulação Geral, 1-Simulação Específica
		    GFECalcSim(@nNrUltCalc)
		Else
			GFEAPPEDUC(cPedRom, (cTRBUNC)->NRCALC, .T.)
		EndIf
	
		(cTRBUNC)->(dbSkip())
	EndDo
	
	If lError
		oGFEXFBFLog:setTexto(CRLF+CRLF, _LOG_BEGIN)
	EndIf
	
	//libera e exclui arquivo temporario
	
	GFEDelTab(cAliasQry)
	If Select(cAliasQry) > 0
		(cAliasQry)->(dbCloseArea())
	endif
	

Return NIL	// FIM SelTabFrete()

