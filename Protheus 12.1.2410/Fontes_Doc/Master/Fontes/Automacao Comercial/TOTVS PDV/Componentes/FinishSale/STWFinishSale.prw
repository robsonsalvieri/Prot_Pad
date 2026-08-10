#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWFINISHSALE.CH"

Static cStDoc		:= ""
Static cStSerie		:= ""
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado 
Static lPDVOnline	:= ExistFunc("STFGetOnPdv") .AND. STFGetOnPdv()	// Variável para definir se o totvs PDV está no modo online

/*/{Protheus.doc} STWFinishSale
Workflow de finalizacao de venda.
@type		function	
@param		lPendSale, logico, indica se a venda pode ser finalizada novamente caso haja erro
@author  	Varejo
@version 	P11.8
@since   	09/01/2013
@return  	Nil
/*/
Function STWFinishSale(lPendSale)

Local nRet      	:= 0				// Retorno
Local lContinua 	:= .T.				// Controle de processo
Local nTotalNCCs	:= STDGetNCCs("2")	// Valor total das NCCs
Local cDoc			:= ""				// Documento
Local cSerie		:= ""				// Serie do Documento Fiscal
Local cACli			:= ""				// Cliente
Local cALojaCli		:= ""				// Loja do Cliente
Local cACPFCli		:= ""				// CPF/CNPJ do Cliente
Local aRet			:= {}
Local aDados		:= {"23", space(SLG->(TamSx3("LG_CRO")[1])) } 
Local lArredondar 	:= SuperGetMV( "MV_LJINSAR",, .F.)			// Configuração para ativar doação para o Instituto Arredondar
Local nArredondar	:= 0										// Valor da doação para o Instituto Arredondar 	
Local lEmitNfce		:= Iif(FindFunction("LjEmitNFCe"), LjEmitNFCe(), .F.) // Sinaliza se utiliza NFC-e
Local cKeyNfce		:= ""
Local nRetNfce		:= -1	//Sinaliza se transmitiu a NFCe
Local lPrintNFCE	:= .T.																						// Se imprime Danfe Nfc-e
Local lLimSang		:= SuperGetMV( "MV_LJLISAN",, .F.) // Utiliza controle para limite de sangria
Local aNotas		:= {}
Local nItem			:= 0
Local nTotItSL2		:= 0
Local lMobile 		:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile
Local cXML 			:= ""
Local lSAT 			:= STFGetCfg("lUseSAT",.F.)
Local cPass 		:= STFGetStat("CODSAT",,.F.) 		//Retorna o código de ativação do SAT
Local cDocSat 		:= ""								//numero de documento da venda SAT
Local cSerieSat		:= ""								//numero de serie do equipamento SAT
Local lSaveOrc		:= IIF( ValType(STFGetCfg( "lSaveOrc" , .F. )) == "L" , STFGetCfg( "lSaveOrc" , .F. )  , .F. )   //Salva venda como orcamento 
Local lRet			:= .F.
Local cAFormPg		:= ""								//Forma de pagamento
Local cMsgErro		:= ""								//Motivo da rejeição
Local lEmiteNFe		:= .F.								//Valida se gerar NF-e
Local oCliModel 	:= STDGCliModel()					// Model do Cliente	
Local lCliPadrao	:= (AllTrim(oCliModel:GetValue("SA1MASTER","A1_COD"))+AllTrim(oCliModel:GetValue("SA1MASTER","A1_LOJA"))) == ( AllTrim( SuperGetMV("MV_CLIPAD", .F., "") ) + AllTrim( SuperGetMV("MV_LOJAPAD", .F., "") ) )
Local aRetTSS		:= {}
Local cRetTSS		:= ""
Local cMsgTSS		:= ""
Local cRetTrans		:= ""
Local cMVLOJANF		:= AllTrim( SuperGetMV("MV_LOJANF", .F. ,"UNI") )
Local nDocSai 		:= SuperGetMv("MV_LJLBNT", .F., 0)
Local lMVFISNOTA	:= SuperGetMV("MV_FISNOTA", .F., .F.) .and. !Empty(cMVLOJANF) .and. nDocSai > 0
Local lLjDNota		:= .F.
Local oRaas			:= Nil
Local oFidelityC	:= Nil
Local lLjGetModNf	:= ExistFunc("LjGetModNf")
Local lSemRetXml	:= .F. 		// Define se poderá ou não finalizar novamente a venda NFC-e que será no modo de contingencia.
Local lNaoGrvSLX	:= .F. // Quando retorna do TSS "nota ja autorizada" mas a chave NFCe são diferentes então signifca q a nota e serie já foram utilizadas em outra venda
						   // nesse caso não pode inutilizar nem gravar SLX.
Local lDelPg		:= !(ExistFunc("STFGetOnPdv") .AND. STFGetOnPdv() .AND. !Empty(STDGPBasket("SL1" , "L1_NUMORIG")))
Local aDescPgto		:= {}	
Local aItensFid		:= {}
Local aFormPgto		:= {}
Local nX			:= 0
Local aAreaSL4		:= {}
Local aAreaSL1		:= {}
Local lRetArea		:= .F.  // Retorna se teve area selecionada no retorno da função STWVldRgNfe()

Local aRetInfDocCli := {}

Default lPendSale	:= .F.								//Em caso de erro, indica se a venda fica pendente para ser finalizada de novo 

lMobile := ( ValType(lMobile) == "L" .AND. lMobile ) 

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Inicio - Workflow de finalizacao de venda." )  //Gera LOG

//tratamento para verificar se está no modo SAT
lSAT := IIf( ValType(lSAT) == "U", .F., lSAT)

// ?? TO DO: Cancelar cupom caso não haja item registrado.

//nRet := IFStatus(nHdlECF, "9", @cRet)		// Verifico o Status do ECF
If nRet <> 0
	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	HELP(' ',1,'FRT011')
	
	lContinua := .F.
EndIf

If lContinua

	// TO DO: Chamar funcao de rateio de desconto e acrescimo e Arredondamento da impressora - Verificar com o Rondon.
	
	// TO DO: Monta FORMAS DE PAGAMENTO que serao enviadas para a impressora, com seus valores  - Bruno
	
	// TO DO: Atualizar totais do SL1 e Gravar L1_SITUA COM "09"
		
	cDoc := STDGPBasket("SL1","L1_DOC")
	
	If Empty(cDoc)
		cDoc := STDGPBasket("SL1","L1_DOCPED")
	EndIf  

	aRet := STFFireEvent( 	ProcName(0)	,;		// Nome do processo
							"STPrinterStatus",;	// Nome do evento
							aDados )  

	//Atualiza o numero de série
	If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 1  .AND. !Empty(aDados[2])
		//Verifica o numero de série
		STBSerieAlt( cDoc, aDados[2] )
	EndIf

	// Doação para o Instituto Arredondar
	If lArredondar
	
		If SL1->(FieldPos( "L1_VLRARR" )) > 0
			nArredondar := STBGetInsArr()
			If nArredondar > 0
				If ExistFunc("STBIANotFiscal")
					If !(lEmitNfce .OR. lSAT)		// Somente ECF. NFC-e ou SAT é após esta etapa
						cSerie		:= STDGPBasket("SL1","L1_SERIE")
						cDoc		:= STDGPBasket("SL1","L1_DOC")
						cACli 		:= STDGPBasket("SL1","L1_CLIENTE")
						cALojaCli	:= STDGPBasket("SL1","L1_LOJA")
						cACPFCli	:= STDGPBasket("SL1","L1_CGCCLI")
						cAFormPg	:= STDGPBasket("SL1","L1_FORMPG")

						//Imprime cupom de doação ao Instituto Arredondar
						STBIANotFiscal( nArredondar	, cSerie	, cDoc		, cACli,;
										cALojaCli	, cACPFCli	, cAFormPg	)
					EndIf
				EndIf
			EndIf	
		EndIf	
	Endif
		
	// Grava tabela MGX para controle de limite de Sangria 
	If lLimSang .AND. AliasIndic("MGX")
		STDGrvMGX()
	EndIf	
	// Verifica se haverá atualizacao de saldo de ShopCard
	If STDGUpdShopCardFundsResult()	
		STDIncShopCardFunds()
		STDRUpdShopCardFundsResult()
	EndIf
	
	// TO DO: Verificar se o cupom foi encerrado e alterar o status do L1_SITUA.
	
	// TO DO: Informar a retaguarda o status atual do check-out.
	
	// TO DO: Exibir mensagem de finalizacao de cupom
	
	If GetVersao(.F.) >= "12" .AND. !(lEmitNfce .OR. lSAT) //Impressão de Vale-Troca quando utilizada IMPRESSORA FISCAL
		STBVTCupom(SL1->L1_DOC,.F.)
	EndIf

	//Versao Mobile Demonstrativa nao emite Cupom
	If  lMobile 
		
		//Se salva venda como orcamento 		
		If  lSaveOrc 
			STDFinishSale()		
		EndIf	

	EndIf

	//Executa PE para saber se gera NFC-e/NF-e/SAT ou utiliza parametro 
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "MV_LJLBNT: " + Str(nDocSai,1) )

	//-- Chama a funcao LjNFFimVd, pois dentro dela executa o PE "LJ7087" e valida se pode gerar NF de acordo com as regras do Varejo
	if lMVFISNOTA .and. !lCliPadrao
		lEmiteNFe := LjNFFimVd() //Resgata a opção selecionada na tela de Seleção de Documento de saída no inicio da venda.
	endif

	//Itens da Venda
	For nX := 1 To STDPBLength("SL2")
		//Somente inclui itens que não foram cancelados
		If !STDPBIsDeleted("SL2", nX)
			aAdd(aItensFid, {	nX	,; 
								STDGPBasket("SL2", "L2_DESCRI"	,nX),;
								STDGPBasket("SL2", "L2_PRODUTO"	,nX),;
								STDGPBasket("SL2", "L2_QUANT"	,nX),;
								STDGPBasket("SL2", "L2_VLRITEM"	,nX) + STDGPBasket("SL2", "L2_VALDESC", nX),;
								STDGPBasket("SL2", "L2_VLRITEM"	,nX) })
		EndIf
	Next nX
	
	//Formas de Pagamento da Venda
	aAreaSL4 := SL4->(GetArea())
	DbSelectArea("SL4")
	SL4->(DbSetOrder(1))
	If DbSeek(xFilial("SL4") + SL1->L1_NUM)
		While SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM
			aDescPgto := FWGetSX5("24", SL4->L4_FORMA)
			aAdd(aFormPgto, {	"",;
								aDescPgto[1][4],;
								SL1->L1_VLRTOT })
			SL4->(DbSkip())
		EndDo
	EndIf
	RestArea(aAreaSL4)

	If Empty(STDGPBasket("SL1","L1_CGCCLI")) .And.;
	   Empty(AllTrim(STDGPBasket("SL1","L1_PFISICA"))) .And. Lj950ImpCpf(STDGPBasket("SL1","L1_VLRTOT"))
		aRetInfDocCli := LjxDCGC(Nil,Nil, , ,STDGPBasket("SL1","L1_VLRTOT"))

		LjGrvLog("InformaCliente:STIPayment","Chama rotina: STICGCConfirm")
		if !STICGCConfirm(aRetInfDocCli[1], aRetInfDocCli[2], aRetInfDocCli[3], .T. , .F.)
			lRet      := .F.
			lPendSale := .T.
			STFCleanInterfaceMessage()
		Else
			lRet      := .T.
		EndIf
	Else
		lRet := .T.
	EndIf		

	If lRet
		lRet := .F.
		If lEmiteNFe .and. STBExistItemFiscal(.F.) //usa NF-e e tem item fiscal
			cSerie    := PadR(If(SubStr(cMVLOJANF,1,1)=="&",&(SubStr(cMVLOJANF,2,Len(cMVLOJANF))),cMVLOJANF), len(SL1->L1_SERIE))
			lLjDNota := LjxDNota( cSerie, 3, .F., 1, @aNotas,,,,,,,,,,,,,"SPED" ) // DOC/SERIE
			
			if lLjDNota .and. Len(aNotas) >= 1 .AND. Len(aNotas[1]) >= 2

				cDoc := aNotas[1][2]

				STDSPBasket( "SL1", "L1_HORA"   , Left(Time(), TamSX3("L1_HORA")[1]) )
				STDSPBasket( "SL1", "L1_SERIE"	, cSerie )
				STDSPBasket( "SL1", "L1_DOC"	, cDoc )
				STDSPBasket( "SL1", "L1_NUMCFIS", cDoc )	// Numero cupom fiscal
				STDSPBasket( "SL1", "L1_SITUA"	, "55" )	//Atribuimos um L1_SITUA extra (55) antes da transmissão
				STDSPBasket( "SL1", "L1_IMPNF"	, .T. )
				STDSPBasket( "SL1", "L1_IMPRIME", "2S" )	//Necessário pois se trata de uma venda fiscal (CUPOM/NFC-e)
				
				If STIGetMult()
					STDSPBasket( "SL1", "L1_CONDPG" , "CN" )
				EndIf

				nTotItSL2 := STDPBLength("SL2")
				For nItem := 1 to nTotItSL2
					
					If STDGPBasket("SL2","L2_FISCAL", nItem) .OR.;
						(ExistFunc("STBIsGarEst") .AND. STBIsGarEst(STDGPBasket("SL2","L2_PRODUTO", nItem)))
						
						STDSPBasket( "SL2", "L2_DOC", cDoc, nItem  )
						//persiste todos os dados da venda (SL1 e item do SL2)
						STDSaveSale(nItem)
					EndIf

				Next nItem

				STFCleanInterfaceMessage()
				STFMessage(ProcName(), "ALERT", STR0006 + STDGPBasket("SL1","L1_NUM") + STR0007 + cDoc+"/"+cSerie) //#"Aguarde, Preparando Orc: " / #" Ref. NFe: "
				STFShowMessage( ProcName() )

				//Chama Mini-Grava-Batch para gerar SF2, SD2, SF3, SFT e CD2 para o NFSEFAZ
				if STBGrvBatch(/*cAlias*/, /*lMultFil*/, /*cKey*/,.T. /*Executado pelo Totvs PDV?*/)
					//Transmitir para a SEFAZ 
					LjAutoNFe(cDoc,;
								cSerie,;
								oCliModel:GetValue("SA1MASTER","A1_COD"),;
								oCliModel:GetValue("SA1MASTER","A1_LOJA"))
							

					aAreaSL1:= STWVldRgNfe() 
					//Como a rotina nao retorna se deu problema, valida-se pelo L1_RETSFZ
					aRetTSS := StrToKarr(SL1->L1_RETSFZ,"|")
					if len(aRetTSS) > 2
						cRetTSS := aRetTSS[02]
						cMsgTSS := aRetTSS[03] 
					else
						cRetTSS := aRetTSS[01]
						cMsgTSS := iif( len(aRetTSS) > 1, aRetTSS[02], "")
					endif

					If lLjGetModNf .AND. LjGetModNf() == 7
						nRetNfce := 1
						cKeyNFCe := SL1->L1_KEYNFCE				
					Else
						//-- Quando Autorizado conclui a venda com sucesso
						cRetTrans := LjRetStatusSEFAZ(cRetTSS, cMsgTSS)
						If ValType(cRetTrans) == "C" .and. cRetTrans $ "A"
							nRetNfce := 1
							cKeyNFCe := SL1->L1_KEYNFCE
						EndIf
					EndIf

					STFCleanInterfaceMessage()

					If Len(aAreaSL1)
						lRetArea := .T.
					Endif 
				endif

			endif
			
			If nRetNfce <> 1 .And. lPDVOnline .And. !LjGetCPDV()[1]
				MsgAlert(""," IMPORTANTE :"+ CRLF+ CRLF+ CRLF; 
						+ "A Nota : " 	+ STDGPBasket("SL1","L1_DOC") 	+ CRLF;
						+ "Serie : "	+ STDGPBasket("SL1","L1_SERIE") + CRLF + CRLF;
						+ "Não foi transmitida."+ CRLF + CRLF;
						+ "Será necessario realizar a retransmissão dessa nota !"+ CRLF + CRLF;
						+ "Acessar a opção: " + CRLF + CRLF;
						+ "Menu F2 > Retransmissão NF-e.")
				nRetNfce := 1
				cKeyNFCe := SL1->L1_KEYNFCE
			EndIf

			If nRetNfce == 1 .AND. nArredondar > 0 .AND. ExistFunc("STBIANotFiscal")		//Instituto Arredondar 

				cSerie		:= STDGPBasket("SL1","L1_SERIE")
				cDoc		:= STDGPBasket("SL1","L1_DOC")
				cACli 		:= STDGPBasket("SL1","L1_CLIENTE")
				cALojaCli	:= STDGPBasket("SL1","L1_LOJA")
				cACPFCli	:= STDGPBasket("SL1","L1_CGCCLI")
				cAFormPg	:= STDGPBasket("SL1","L1_FORMPG")
				
				//Imprime cupom de doação ao Instituto Arredondar - NFC-e
				STBIANotFiscal( nArredondar	, cSerie	, cDoc		,cACli,;
								cALojaCli	, cACPFCli	, cAFormPg	)
			EndIf

			STBVTCupom() //Impressão de Vale-Troca quando utilizada IMPRESSORA NÃO-FISCAL

			//---
			// Situações nRetNfce:
			// 1	-> NFC-e/NFe processada com sucesso
			// 0 	-> NFC-e/NFe enviada para o TSS sem Rejeicao, 
			//		   mas não houve sucesso na comunicação TSS->SEFAZ
			//-1 	-> NFC-e/NFe rejeitada
			//---
			
			//reseta o objeto referente a NFC-e
			LjNFCeFree()

			If nRetNfce == 1
				//a chave da NFC-e nao deve ser gravada em caso de rejeição, já que a nota será inutilizada
				STDSPBasket("SL1", "L1_KEYNFCE", cKeyNfce)

				If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
						
					// -- Finaliza BonusHub
					oRaas := STBGetRaas()

					If Valtype(oRaas) == "O" .And. oRaas:ServiceIsActive("TFC")
						oFidelityC := oRaas:GetFidelityCore()

						If oFidelityC:ChoseToUse()
							// -- Desativa Botões na tela
							STIBtnDeActivate()
							oFidelityC:Finalization(STFGetStat("CODIGO"),;
													POSICIONE( "SA3", 1, xfilial("SA3") + STDGPBasket('SL1','L1_VEND'), "A3_NOME" ),;
													cKeyNfce,;
													STDPBLength("SL2", .T.),;
													STDGPBasket('SL1','L1_VLRLIQ'),;
													aItensFid,;
													aFormPgto)

							// -- Ativa Botões na tela
							STIBtnActivate()
							
							oFidelityC:Clean()
							STDSPBasket( "SL1" , "L1_FIDCORE",.T.)
						EndIf

					Endif 
				
				EndIf 

				STDFinishSale(lEmiteNFe, lRetArea)
				lRet := .T.
			Else
				/*
					Pre-Requisitos para a inutilizacao atraves da SLX
				*/
				lPendSale := STBChkInut()

				If lPendSale
					// realiza a inutilizacao da NFC-e atraves da SLX
					LjGrvLog( NIL, "Antes da chamada da função STWInuNFCE - Inutilização atraves da SLX" )
					lPendSale := STWInuNFCE(STDGPBasket("SL1","L1_DOC")		, STDGPBasket("SL1","L1_SERIE")		, STDGPBasket("SL1","L1_PDV")	,;
											STDGPBasket("SL1","L1_OPERADO")	, STDGPBasket("SL1","L1_ESTACAO")	, cMsgErro						,;
											STDGPBasket("SL1","L1_NUM") 	)
					LjGrvLog( NIL, "Depois da chamada da função STWInuNFCE",lPendSale)
					
					// resetamos e apagamos os campos referentes aos Pagamentos que ja foram realizados(SL1/SL4)
					If lPendSale .AND. lDelPg
						lPendSale := STWDelPay( STDGPBasket("SL1","L1_NUM") )
					EndIf
				EndIf
			
				// Faz a exclusao/inutilizacao pelo metodo antigo
				If !lPendSale
					STWCancelSale(.T.,,,cDoc, "L1_NUM",,)
				EndIf
			
		

				If !IsBlind()			
					STFMessage("STWFinisale3", "POPUP", STR0003)
					STFShowMessage("STWFinisale3")
				Else
					Conout(STR0003)	// "Venda não Efetuada devido falha de comunicação"				
				EndIf
				
				LjGrvLog( NIL,STR0003)
			EndIf

		ElseIf lSAT .AND. STBExistItemFiscal(.F.) //usa SAT e tem item fiscal

			STDSPBasket( "SL1", "L1_SITUA", "10" ) //Para possivel restauração de venda

			cXML := LjSATXml() // Gera XML

			aRet := LJSATComando({"12","EnviarDadosVenda",LJSATnSessao(),cPass,cXML})

			If Len(aRet) > 2 .And. Val(aRet[2]) == 6000 //retorno de sucesso
				If FindFunction("LJSATRetDoc")
					aSATDoc := LJSATRetDoc(Decode64(aRet[5]),aRet)  //retorna o doc e serie gerado no SAT

					cDoc := cDocSat	:= aSATDoc[1] 
					cSerieSat			:= aSATDoc[2]

					STDSPBasket( "SL1",  "L1_DOC"		, cDoc  )
					STDSPBasket( "SL1",  "L1_ESPECIE"	, "SATCE"  )
					STDSPBasket( "SL1",  "L1_SERSAT"	, cSerieSat  )
					STDSPBasket( "SL1",  "L1_KEYNFCE"	, SubStr(aRet[7],4,Len(aRet[7])) )
					STDSPBasket( "SL1",	"L1_HORA"   	, Left(Time(),TamSX3("L1_HORA")[1]) )
					STDSPBasket( "SL1",  "L1_SITUA"		, "T3"  ) // Pois a venda já foi transmitida para sefaz e retornou a numeração para o sistema. 
					STDSaveSale()
					
					LjGrvLog( SL1->L1_NUM, "SAT - Numeração do Doc e Serie do SAT", aSATDoc )

				EndIf
			
				STFMessage("STIPayment","STOP", cSiglaSat + " - Transmitido com sucesso" ) //"SAT - Transmitido com sucesso"
				STFShowMessage("STIPayment")
				
				LojSATImprimir(Decode64(aRet[5]), cXML, SL1->L1_SERIE, @cDocSat, @cSerieSat, ,aSATDoc) //impressao do cupom
				
				cDoc := cDocSat
				
				STDSPBasket( "SL1", "L1_DOC", cDoc )
				STDSPBasket( "SL1", "L1_NUMCFIS", cDoc )	// Numero cupom fiscal
				STDSPBasket( "SL1", "L1_SERSAT", cSerieSat )
				STDSPBasket( "SL1", "L1_ESPECIE", "SATCE" )
				STDSPBasket( "SL1", "L1_KEYNFCE", SubStr(aRet[7],4,Len(aRet[7])) )
				STDSPBasket( "SL1", "L1_SITUA"	, "58" )	//Atribuimos um L1_SITUA extra (58) SAT
				
				nTotItSL2 := STDPBLength("SL2")
				
				For nItem := 1 to nTotItSL2
					If STDGPBasket("SL2","L2_FISCAL", nItem) .OR.;
					(ExistFunc("STBIsGarEst") .AND. STBIsGarEst(STDGPBasket("SL2","L2_PRODUTO", nItem)))
						STDSPBasket( "SL2", "L2_DOC", cDoc, nItem  )
						STDSaveSale(nItem)
					EndIf
				Next         	

				If nArredondar > 0 .AND. ExistFunc("STBIANotFiscal")
					cSerie		:= STDGPBasket("SL1","L1_SERIE")
					cDoc		:= STDGPBasket("SL1","L1_DOC")
					cACli 		:= STDGPBasket("SL1","L1_CLIENTE")
					cALojaCli	:= STDGPBasket("SL1","L1_LOJA")
					cACPFCli	:= STDGPBasket("SL1","L1_CGCCLI")
					cAFormPg	:= STDGPBasket("SL1","L1_FORMPG")
					//Imprime cupom de doação ao Instituto Arredondar - SAT
					STBIANotFiscal(nArredondar,cSerie,cDoc,cACli,;
										cALojaCli,cACPFCli,cAFormPg)
				EndIf

				If GetVersao(.F.) >= "12" //Impressão de Vale-Troca quando utilizada IMPRESSORA NÃO-FISCAL
					STBVTCupom(SL1->L1_DOC,.T.)
				EndIf

				If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
						
					// -- Finaliza BonusHub
					oRaas := STBGetRaas()

					If Valtype(oRaas) == "O" .And. oRaas:ServiceIsActive("TFC")
						oFidelityC := oRaas:GetFidelityCore()

						If oFidelityC:ChoseToUse()
							// -- Desativa Botões na tela
							STIBtnDeActivate()
							oFidelityC:Finalization(STFGetStat("CODIGO"),;
													POSICIONE( "SA3", 1, xfilial("SA3") + STDGPBasket('SL1','L1_VEND'), "A3_NOME" ),;
													cSerie + cDoc,;
													STDPBLength("SL2", .T.),;
													STDGPBasket('SL1','L1_VLRLIQ'),;
													aItensFid,;
													aFormPgto)

							// -- Ativa Botões na tela
							STIBtnActivate()
							
							oFidelityC:Clean()
							STDSPBasket( "SL1" , "L1_FIDCORE",.T.)
						EndIf

					Endif 
				
				EndIf 
				
				STDFinishSale()
				
				lRet := .T.
			Else 
				STWCancelSale(.T.,,,cDoc, "L1_NUM",,) //cancela venda
			
				If Len(aRet) > 3 .And. ExistFunc("LjGrvLogSAT")
					//Log SAT
					LjGrvLogSAT(;
									/*serie*/,;
									/*numero da venda*/,;
									/*chave da venda*/,;
									cXML,;
									/*xml retorno*/,;
									"VENDA",;
									"ERRO",;
									IIf( Len(aRet) > 1 , aRet[2], "aRetSAT[2] = NIL") + "-" + IIf( Len(aRet) > 3 , cValToChar(DecodeUTF8(aRet[4])), "aRetSAT[4] = NIL");
								)
					
					/*
						aRet[2] - Codigo 
						aRet[4] - Descrição
					*/
					//Não foi colocado em STFMESSAGE porque a mensagem pode ser grande e não será exibida por completo
					STFMessage(ProcName(),"STOP",STR0005 + IIf( Len(aRet) > 1 , aRet[2], "aRetSAT[2] = NIL") + "-" + IIf( Len(aRet) > 3 , cValToChar(DecodeUTF8(aRet[4])), "aRetSAT[4] = NIL")) //#"Venda não realizada: " // Código de erro retornado pelo SAT
					STFShowMessage(ProcName())    

				EndIf            
				
			EndIf                 
		
		ElseIf lEmitNFCe .AND. STBExistItemFiscal(.F.) .AND. !lSaveOrc

			//
			// obtem a serie e numeracao da NFC-e
			cSerie := STFGetStation("SERIE")
			
			LjxDNota( cSerie, 3, .F., 1, @aNotas,,,,,,,,,,,,,"NFCE" )  // DOC/SERIE
			If Len(aNotas) >= 1 .AND. Len(aNotas[1]) >= 2
				cDoc := aNotas[1][2]
			EndIf

			STDSPBasket( "SL1", "L1_HORA"   , Left(Time(), TamSX3("L1_HORA")[1]) )
			STDSPBasket( "SL1", "L1_SERIE"	, cSerie )
			STDSPBasket( "SL1", "L1_DOC"	, cDoc )
			STDSPBasket( "SL1", "L1_NUMCFIS", cDoc )	// Numero cupom fiscal
			STDSPBasket( "SL1", "L1_SITUA"	, "65" )	//Atribuimos um L1_SITUA extra (65) antes da transmissão
			STDSPBasket( "SL1", "L1_IMPRIME", "1S" )	//Necessário pois se trata de uma venda fiscal (CUPOM/NFC-e)

			nTotItSL2 := STDPBLength("SL2")
			For nItem := 1 to nTotItSL2
				If STDGPBasket("SL2","L2_FISCAL", nItem) .OR.;
					(ExistFunc("STBIsGarEst") .AND. STBIsGarEst(STDGPBasket("SL2","L2_PRODUTO", nItem)))
					STDSPBasket( "SL2", "L2_DOC", cDoc, nItem  )
					//persiste todos os dados da venda (SL1 e item do SL2)
					STDSaveSale(nItem)
				EndIf
			Next nItem

			STFCleanInterfaceMessage()

			LjMsgRun( STR0002+ " " + SL1->L1_NUM + " " + STR0004 + " " + cDoc,,;
			{|| nRetNfce := LjNFCeGera(SL1->L1_FILIAL,SL1->L1_NUM, @cKeyNfce,,lPrintNFCE, @cMsgErro,,,,,@lSemRetXml, @lNaoGrvSLX)} )   //"Aguarde... Processando NFC-e Orcamento: "  " - Doc.: "

			If nRetNfce == 1 .AND. nArredondar > 0 .AND. ExistFunc("STBIANotFiscal")		//Instituto Arredondar 
				cSerie		:= STDGPBasket("SL1","L1_SERIE")
				cDoc		:= STDGPBasket("SL1","L1_DOC")
				cACli 		:= STDGPBasket("SL1","L1_CLIENTE")
				cALojaCli	:= STDGPBasket("SL1","L1_LOJA")
				cACPFCli	:= STDGPBasket("SL1","L1_CGCCLI")
				cAFormPg	:= STDGPBasket("SL1","L1_FORMPG")
				
				//Imprime cupom de doação ao Instituto Arredondar - NFC-e
				STBIANotFiscal( nArredondar	, cSerie	, cDoc		,cACli,;
								cALojaCli	, cACPFCli	, cAFormPg	)
			EndIf

			If nRetNfce == 1 .And. GetVersao(.F.) >= "12" //Impressão de Vale-Troca quando utilizada IMPRESSORA NÃO-FISCAL
				STBVTCupom(SL1->L1_DOC,.T.)
			EndIf

			//
			//---
			// Situações nRetNfce:
			// 1	-> NFC-e/NFe processada com sucesso
			// 0 	-> NFC-e/NFe enviada para o TSS sem Rejeicao, 
			//		   mas não houve sucesso na comunicação TSS->SEFAZ
			//-1 	-> NFC-e/NFe rejeitada
			//---
			
			//reseta o objeto referente a NFC-e
			LjNFCeFree()

			If nRetNfce == 1
				//a chave da NFC-e nao deve ser gravada em caso de rejeição, já que a nota será inutilizada
				STDSPBasket("SL1", "L1_KEYNFCE", cKeyNfce)
				
				If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
						
					// -- Finaliza BonusHub
					oRaas := STBGetRaas()

					If Valtype(oRaas) == "O" .And. oRaas:ServiceIsActive("TFC")
						oFidelityC := oRaas:GetFidelityCore()

						If oFidelityC:ChoseToUse()
							// -- Desativa Botões na tela
							STIBtnDeActivate()
							oFidelityC:Finalization(STFGetStat("CODIGO"),;
													POSICIONE( "SA3", 1, xfilial("SA3") + STDGPBasket('SL1','L1_VEND'), "A3_NOME" ),;
													cKeyNfce,;
													STDPBLength("SL2", .T.),;
													STDGPBasket('SL1','L1_VLRLIQ'),;
													aItensFid,;
													aFormPgto)

							// -- Ativa Botões na tela
							STIBtnActivate()
							
							oFidelityC:Clean()
							STDSPBasket( "SL1" , "L1_FIDCORE",.T.)
						EndIf

					Endif 
				
				EndIf 

				STDFinishSale()
				lRet := .T.
				lEnviaContg := .F. 
			Else
				/*
					Pre-Requisitos para a inutilizacao atraves da SLX
				*/
			
				If ExistFunc("STBChkInut")	//STBCANCELSALE.PRW
						
						//verifica se possui todos os requisitos
									
					lPendSale := STBChkInut()

					If lPendSale .AND.!lNaoGrvSLX
						// realiza a inutilizacao da NFC-e atraves da SLX
						LjGrvLog( NIL, "Antes da chamada da função STWInuNFCE - Inutilização atraves da SLX" )
						lPendSale := STWInuNFCE(STDGPBasket("SL1","L1_DOC")		, STDGPBasket("SL1","L1_SERIE")		, STDGPBasket("SL1","L1_PDV")	,;
												STDGPBasket("SL1","L1_OPERADO")	, STDGPBasket("SL1","L1_ESTACAO")	, cMsgErro						,;
												STDGPBasket("SL1","L1_NUM") 	)
						LjGrvLog( NIL, "Depois da chamada da função STWInuNFCE",lPendSale)
						
						// resetamos e apagamos os campos referentes aos Pagamentos que ja foram realizados(SL1/SL4)
						If lPendSale .AND. lDelPg
							lPendSale := STWDelPay( STDGPBasket("SL1","L1_NUM") )
						EndIf
					EndIf
				EndIf
				
				// Faz a exclusao/inutilizacao pelo metodo antigo
				If !lPendSale
					STWCancelSale(.T.,,,cDoc, "L1_NUM",,)
				EndIf
				


				If !IsBlind()	
					If lSemRetXml .OR. lNaoGrvSLX
						STFMessage("STWFinisale3", "POPUP", STR0008)//Finalize a Venda novamente através do botão Finalizar pagamento CTRL+P!
						STFShowMessage("STWFinisale3")
					Else
						STFMessage("STWFinisale3", "POPUP", STR0003)//Venda não Efetuada devido falha de comunicação com SEFAZ
						STFShowMessage("STWFinisale3")
					Endif 
				Else
					Conout(STR0003)	//Venda não Efetuada devido falha de comunicação com SEFAZ			
				EndIf
				
				LjGrvLog( NIL,STR0003)
				
			EndIf
		//Se nao for NF-e, NFC-e ou SAT
		Else
			
			If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
						
				// -- Finaliza BonusHub
				oRaas := STBGetRaas()

				If Valtype(oRaas) == "O" .And. oRaas:ServiceIsActive("TFC")
					oFidelityC := oRaas:GetFidelityCore()

					If oFidelityC:ChoseToUse()
						// -- Desativa Botões na tela
						STIBtnDeActivate()
						oFidelityC:Finalization(STFGetStat("CODIGO"), POSICIONE( "SA3", 1, xfilial("SA3") + STDGPBasket('SL1','L1_VEND'), "A3_NOME" ),;
												STDGPBasket("SL1","L1_SERIE") + STDGPBasket("SL1","L1_DOC"),STDPBLength("SL2"),STDGPBasket('SL1','L1_VLRLIQ'))
						// -- Ativa Botões na tela
						STIBtnActivate()
						
						oFidelityC:Clean()
						STDSPBasket( "SL1" , "L1_FIDCORE",.T.)
					EndIf

				Endif 
			
			EndIf 

			STDFinishSale()	
			lRet := .T.
		EndIf

		If !lPendSale .AND. nTotalNCCs > 0 
			STWBxNCC()
		EndIf	

		If !lPendSale
			STBBaixaVP() 
		Endif 
	
	EndIf

EndIf

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Venda ficara pendente?", lPendSale )
LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Fim - Workflow de finalizacao de venda.", lRet )

If !lPendSale	
	//Gravo o doc e a série antes do STFRestart(). Útil para o Ponto de Entrada STFinishSale() em STBPayment.prw. 
	STWSetDocSerie(STDGPBasket( "SL1", "L1_DOC" ),STDGPBasket( "SL1", "L1_SERIE" ))
	STFRestart()
EndIf


LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Proxima venda será: " + STDGPBasket('SL1','L1_NUM') )

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} STWFinishValid
Função criada para validar se o fonte esta atualizado por conta da troca
de impressão do comprovante TEF
@param 
@author  Varejo
@version P11.8
@since   07/06/2016
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STWFinishValid
Return



//-------------------------------------------------------------------
/*{Protheus.doc} STWSetDocSerie
Função criada para armazenar o último número do cupom fiscal antes do STFRestart()

@param	 cDoc,cSerie 
@author  Varejo
@version P11.8
@since   26/06/2017
@return  Nil
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STWSetDocSerie(cDoc,cSerie)

cStDoc := cDoc
cStSerie := cSerie

Return nil


//-------------------------------------------------------------------
/*{Protheus.doc} STWGetDocSerie
Função criada para ler o último número do cupom fiscal e Série antes do STFRestart()

@param	 Nil 
@author  Varejo
@version P11.8
@since   26/06/2017
@return  {cStDoc,cStSerie}
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STWGetDocSerie()

Return( {cStDoc,cStSerie} )

/*/{Protheus.doc} STWVldRgNfe
	Rotina criada para ajustar o ponteiro da SL1 no registro do Item Retira
	quando foi emitido NF-e na situação seguinte:
	-Importação de Orçamento com reserva (retira posterior, entrega);
	-Venda de item durante a importação de orçamentos acima;
	-Emissão de NF-e
	Nessa situação, o ponteiro da SL1 fica no registro do Orçamento pai, 
	porém a NF-e foi emitida pela SL1 referente aos itens Retira ou item lançado no PDV.
	No trecho da rotina STWFinishSale(), quando busca o L1_RETSFZ e L1_KEYNFCE ocorre erro 
	justamente pq no SL1 do registro Pai não tem esses valores.
	Criada essa rotina para mudar o ponteiro para o registro de SL1 que foi gerado pelos itens retira.

	@type  Static Function
	@author user
	@since 05/05/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
/*/
Static Function STWVldRgNfe() 
Local lRet		:= .F. // Seta .T. caso for mudado o ponteiro, nesse caso precisa dar RestArea() depois
Local aArea		:= {}
Local cSl1Num 	:= SL1->L1_NUM 

If lPDVOnline .AND. STBIsImpOrc()
	aArea := SL1->(GetArea())
	DbSelectArea("SL1") 
	SL1->(DbSetOrder(14))//L1_FILIAL+L1_ORCRES 
	If SL1->( DbSeek(xFilial("SL1") + cSl1Num))
		While !lRet .AND. !Eof() .AND. (xFilial()+cSl1Num) == (SL1->L1_FILIAL+SL1->L1_ORCRES) 
			lRet:= !Empty(SL1->L1_RETSFZ) .AND. !Empty(SL1->L1_KEYNFCE) .AND. SL1->L1_SITUA == "OK"
			If !lRet 
				SL1->(dbSkip())
			Endif 
    	EndDo	
	Endif

	If !lRet
		RestArea(aArea)
		aArea:={}
	Endif 

Endif  

Return aArea


