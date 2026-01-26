#INCLUDE "PROTHEUS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STIRECESEL.CH"

//Tratamento para identificação da posição do Array aNCCs - Fonte: STINCCSelection
#DEFINE NCCSELECTED 	1	// Campo logico que indica se a NCC foi selecionada
#DEFINE SE1NUM			3	// Posicao do campo E1_NUM do Array aNCCsCli
#DEFINE SE1RECNO 		5	// Posicao do Recno do registro dentro do Array aNCCsCli
#DEFINE SE1SALDO		6	// Posicao do campo E1_SALDO do Array aNCCsCli
#DEFINE SE1PREFIXO		9	// Posicao do campo E1_PREFIXO do Array aNCCsCli
#DEFINE SE1PARCELA		10	// Posicao do campo E1_PARCELA do Array aNCCsCli

Static lOpenPDV := .T. //Controla se faz abertura do PDV perifericos, menus etc

//--------------------------------------------------------
/*/{Protheus.doc} STFPosAuto
Executa operações do TOTVS PDV de forma automática sem exibição de Tela.
Pode ser usado para testes automátizados etc.
@param   aParFunc  - Parametros utilizados a depender da rotina a ser executada
@param   cTipoOper - Tipo de operação a ser executada conforme tabela
			VD  = Venda
			CA  = Cancelamento Venda
			AC  = Abertura de caixa
			FC  = Fechamento de caixa
			RT  = Recebimento de Título
			ET  = Estorno de Título
			IO  = Importação Orcamento
			SA  = Sangria de caixa
			SU  = Suprimento de caixa
			CC  = Cadastro cliente
@type function
@author  	rafael.pessoa
@since   	08/02/2018
@version 	P12
@param 		
@return		lRet - Retorna se executou corretamente
/*/
//--------------------------------------------------------
Function STFPosAuto( aParFunc , cTipoOper )

Local	lRet 			:= .T.
Local 	aMenus			:= {}
Local   cErro			:= ""
Local	nX				:= 1 
Default aParFunc		:= Array(5) 
Default cTipoOper		:= "VD" 

//Sempre completa o array com 5 posições para suprir os parâmetros não passados
While Len(aParFunc) < 5
	aAdd(aParFunc,{})
Enddo 

If lOpenPDV
	STFSetPOS(.T.)//Seta(Força) que é TOTVS PDV
	
	//Inicialização padrão TOTVS PDV
	lRet := STFStart()
	
	// Carregar menus somente apos o STFStart 
	If lRet
		aMenus := STBLstOperCashier()
		lOpenPDV := .F. //nao faz abertura do PDV perifericos, menus etc
	EndIf
EndIf		

If lRet
 
	Do case
	
		case cTipoOper == "VD"
			If STWPOSOpenCash() 
				STFSaleAuto( aParFunc[1] , aParFunc[2] , aParFunc[3], aParFunc[4] )
			Endif
		case cTipoOper == "CA" //Cancelar venda
			If STWPOSOpenCash() 
				lRet := STFSaleCan( aParFunc[1]  )
			Endif				
		case cTipoOper == "AC"
			STWPOSCloseCash()
			lRet := STWPOSOpenCash()
		case cTipoOper == "FC"
			lRet := STWPOSCloseCash()
			//Fecha comunicacao com perifericos
			STWCloseDevice() 
			lOpenPDV := .T. //Marca para fazer abertura da proxima vez
			//Libera o objeto de totais da venda
			If ExistFunc("STFTotRelease")
				STFTotRelease()
			EndIf 					
		case cTipoOper == "CC" 
			If(STWPOSOpenCash(),lRet := STFIccAuto(aParFunc,@cErro),(cErro := "",lRet := .F.))									
		case cTipoOper == "RT"
			If STWPOSOpenCash() 
				STFRecAuto( aParFunc[1] , aParFunc[2] , aParFunc[3], aParFunc[4], aParFunc[5] )
			Endif		
		case cTipoOper == "ET"
			If STWPOSOpenCash() 
				STFEsRAuto( aParFunc[1] , aParFunc[2] )
			Endif
		Otherwise
			lRet := .F.
			cErro := "Operação: " + cTipoOper + " Inválida!."
	EndCase
	
EndIf	

If !lRet
	Conout(cErro)	
	lMsErroAuto  := .T. //Sinaliza Erro para ExecAuto
	Help( " ", 1, "Help",, cErro, 1, 0 )
EndIf	

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} STFSaleAuto
Executa operação de venda no TOTVS PDV de forma automática sem exibição de Tela.
Pode ser usado para testes automátizados etc.
@param   aCab   - Cabeçalho da venda
@param   aItens - Itens da venda 
@param   aPgtos - Pagamentos da venda

@type function
@author  	rafael.pessoa
@since   	08/02/2018
@version 	P12
@param 		
@return		lRet - Retorna se executou corretamente
/*/
//--------------------------------------------------------
Static Function STFSaleAuto( aCab , aItens , aPgtos, aNCCsCli )

	Local	lRet 			:= .T. 
	Local	cCliCode		:= ""
	Local	cCliStore		:= ""
	Local	cCliType		:= ""
	Local	cFilRes 		:= ""
	Local	cOrcRes 		:= ""
	Local	cPedRes 		:= ""
	Local	cCondPg			:= ""
	Local	cVendedor		:= ""
	Local 	lIsRetPost  	:= .F.				
	Local 	nPosPRODUTO		:= 0
	Local 	nPosVALDESC		:= 0
	Local 	nPosTES			:= 0		
	Local 	nPosPRCTAB		:= 0	
	Local 	nPosQUANT		:= 0	
	Local 	nPosCODBAR		:= 0 
	Local 	nPosITEMGAR		:= 0
	Local	nNextItem		:= 0				
	Local 	lItemFiscal		:= .T.	
	Local 	cCliente 		:= ""
	Local 	cLojaCli 		:= ""
	Local 	cNomeCli 		:= ""
	Local 	cEndCli 		:= "" 
	Local 	cCgcCli 		:= ""	
	Local	lFinServ		:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)	// Valida implementação do servico financeiro
	Local 	aItemFind		:= {}
	Local 	cCodProdReg		:= ""
	Local 	cCodItemGar		:= ""
	Local 	lRegistrou		:= .F.
	Local 	nScanJuros		:= 0	
	Local 	nScanVLJur		:= 0	
	Local 	aAcres			:= {}
	Local 	nI	   			:= 0		 		   						
	Local 	nJ				:= 0
	Local   nX              := 0
	Local   nSaldoNCCs      := 0
	
	Local 	oCliModel		:= Nil
	Local 	oModelCesta		:= Nil	   	// Model Cesta
	Local 	oModelPay		:= Nil 		// Model Formas de Pagamento
	Local 	oMdlGrd			:= Nil 		// Model  Parcelas
	Local 	oMdlPaym		:= Nil 		// Model  APAYMENTS
	Local   oModel			:= Nil
	Local 	aCopyPaym		:= STIGetSx5()[2]
	Local 	cFormaPG 		:= ""	
	Local 	nValorPG 		:= 0

	Local nPosFrete			:= AScan( aCab , { |x| x[1] == "L1_FRETE"	} 	)
	Local nVlrFrete         := 0

	Default aCab			:= {} 
	Default aItens			:= {}
	Default aPgtos			:= {}
	Default aNCCsCli		:= {}

	//Adiciona cabeçalho da venda
	If lRet

		cCliCode	:= aCab[AScan( aCab 	, { |x| x[1] == "L1_CLIENTE"} )][2]
		cCliStore	:= aCab[AScan( aCab 	, { |x| x[1] == "L1_LOJA" 	} )][2]
		cCliType	:= aCab[AScan( aCab 	, { |x| x[1] == "L1_TIPOCLI"} )][2]
		cCondPg		:= aCab[AScan( aCab 	, { |x| x[1] == "L1_CONDPG"	} )][2]
		cVendedor	:= aCab[AScan( aCab 	, { |x| x[1] == "L1_VEND"	} )][2]
		nVlrFrete   := IIF(nPosFrete > 0, aCab[nPosFrete][2],0 ) 

		oCliModel := STWCustomerSelection(cCliCode+cCliStore)

		If Len(aNCCsCli) > 0 // tem NCC para ser baixado 

			STDSetNCCs("1",aNCCsCli) //Alimenta o array aNCCs

			For nX := 1 To Len(aNCCsCli)
				If aNCCsCli[nX,NCCSELECTED]
					//STDSetNCCs("2",aNCCsCli[nX,SE1SALDO])
					nSaldoNCCs += aNCCsCli[nX,SE1SALDO]
				EndIf
			Next nX

			// alimentando as variaveis utilizadas nas rotinas do STiPosAuto
			//	aNCCs   := STDGetNCCs("1", aNCCsCli)
			STDGetNCCs("2", nSaldoNCCs)

		EndIf

		STDSPBasket( "SL1" , "L1_CLIENTE" 	, cCliCode 	)
		STDSPBasket( "SL1" , "L1_LOJA" 		, cCliStore	)
		STDSPBasket( "SL1" , "L1_TIPOCLI"	, cCliType	)
		STDSPBasket( "SL1" , "L1_CONDPG"	, cCondPg	)
		STDSPBasket( "SL1" , "L1_FRETE"		, nVlrFrete	)

		oVendModel := STWSalesmanSelection(cVendedor)
		STDSPBasket("SL1","L1_VEND"	,oVendModel:GetValue("SA3MASTER","A3_COD"))
		STDSPBasket("SL1","L1_COMIS",STDGComission( oVendModel:GetValue("SA3MASTER","A3_COD") ))

		cCliente  	:= oCliModel:GetValue("SA1MASTER", "A1_COD"	)
		cLojaCli  	:= oCliModel:GetValue("SA1MASTER", "A1_LOJA")
		cNomeCli	:= oCliModel:GetValue("SA1MASTER", "A1_NOME")
		cEndCli  	:= oCliModel:GetValue("SA1MASTER", "A1_END"	)
		cCgcCli		:= oCliModel:GetValue("SA1MASTER", "A1_CGC"	)	
		STICGCConfirm(@cCgcCli, cNomeCli, cEndCli, .T. , .F. )

	EndIf

	//	Adicionar os Itens na Venda
	If lRet

		nPosPRODUTO	:= AScan( aItens[1] , { |x| x[1] == "L2_PRODUTO"	} 	)
		nPosVALDESC	:= AScan( aItens[1] , { |x| x[1] == "L2_VALDESC"	} 	)
		nPosQUANT	:= AScan( aItens[1] , { |x| x[1] == "L2_QUANT"		} 	)
		nPosTES		:= AScan( aItens[1] , { |x| x[1] == "L2_TES"		} 	)
		nPosPRCTAB	:= AScan( aItens[1] , { |x| x[1] == "L2_PRCTAB"		} 	)

		For nI := 1 To Len(aItens)			

			// Seta quantidade
			STBSetQuant( aItens[nI][nPosQUANT][2] )				

			nNextItem := STDPBLength("SL2") + 1

			//	Busca item na base de dados		
			aItemFind	:= STWFindItem( aItens[nI][nPosPRODUTO][2] )

			// Caso nao encontre o item na base de dados
			If !aItemFind[ITEM_ENCONTRADO]
				lRet:= .F.
			EndIf

			If nPosCODBAR > 0 .And. !Empty(aItens[nI][nPosCODBAR][2])
				cCodProdReg := aItens[nI][nPosCODBAR][2]
			Else
				cCodProdReg := aItens[nI][nPosPRODUTO][2]
			EndIf
			
			//STWSetIsOpenReceipt(.T.)
			
			lRet := STWItemReg( 	nNextItem					, ;		// Item
									cCodProdReg					, ;		// Codigo Prod
									cCliCode 					, ;		// Codigo Cli
									cCliStore					, ;		// Loja Cli
									1 							, ;		// Moeda
									aItens[nI][nPosVALDESC][2]	, ;		// Valor desconto
									"V"							, ;		// Tipo desconto ( Percentual ou Valor )
									NIL							, ;		// Item adicional?
									aItens[nI][nPosTES][2] 		, ;		// TES
									cCliType 					, ;		// Tipo do cliente (A1_TIPO)
									lItemFiscal 				, ;		// Registra item no cupom fiscal?
									aItens[nI][nPosPRCTAB][2] 	, ;		// Preço
									"IMP"						, ;		// Indica que é importação de orçamento
									.T.							, ;		// Se deve imprimir o CNPJ, informacao sera passada na abertura do cupom  
									,,,,,,,,					, ;		// lRecovery,nSecItem,lServFinal,lProdBonif,lListProd,cCodList,cCodListIt,cCodMens,cEntrega
									cCodItemGar					)		// Código do item de produto garantia vinculado		

			If lRet
				//Atualiza Cesta
				iif ( ExistFunc("STBISL2Refresh"), STBISL2Refresh( aItens[nI] , nNextItem ), nil)		
				STDSaveSale(nNextItem)		
			Else
				Exit //Caso ocorra algum erro ao registrar o item não é necessário executar os passos seguintes
			EndIf

		Next nI  

	EndIf


	//Atualiza campos do cabeçalho apos inclusão dos itens
	If lRet

		//Chamada Desconto no Total
		If AScan( aCab , { |x| x[1] == "L1_DESCONT" } ) > 0
			STBTotDiscApply(  aCab[AScan( aCab , { |x| x[1] == "L1_DESCONT" } )][2] , "V" , , .T.)
		EndIf	

		//	Chamada componente de frete
		STWAddFreight(aItens)

		//Chamada Acrescimo Financeiro
		nScanJuros := AScan( aCab , { |x| x[1] == "L1_JUROS" } ) 	

		If SL1->(ColumnPos("L1_VLRJUR")) > 0 		

			nScanVLJur := AScan( aCab , { |x| x[1] == "L1_VLRJUR" } )
			If nScanVLJur > 0 	 	
				STFSetTot( "L1_VLRJUR" , aCab[nScanVLJur][2])
				STDSPBasket("SL1","L1_VLRJUR",STDGPBasket('SL1','L1_VLRJUR') + aCab[nScanVLJur][2]) 		
			Else
				STFSetTot( "L1_VLRJUR",0)
				STDSPBasket("SL1","L1_VLRJUR",0)	
			EndIf

			AADD ( aAcres , STDGPBasket("SL1","L1_VLRJUR"))
			If nScanJuros > 0
				AADD ( aAcres , aCab[nScanJuros][2])
			EndIf	 

		ElseIf nScanJuros > 0
			//Calcula o valor do acrescimo (Legado)
			//A função abaixo irá retornar o valor correto apenas para juros simples ou multi-negociação
			//Caso seja Condição negociada (juros composto ou Price) o valor total da venda não irá bater com o Total da SL4						
			aAcres := STBDiscConvert( aCab[nScanJuros][2] , 'P' )
		EndIf

		STWAddIncrease( aAcres[1]  , IIF(nScanJuros > 0,aCab[nScanJuros][2],0) )//Add acrescimo

		STFRefTot()//Atualiza Totalizador

	EndIf

	//Atualiza SL4
	If lRet

		ModelPayme()
		oModel := STISetMdlPay()
		oMdlGrd		:= oModel:GetModel("PARCELAS")
		oMdlGrd:Activate()
		oMdlPaym	:= oModel:GetModel("APAYMENTS")
		oMdlPaym:Activate()

		For nI := 1 To Len(aPgtos)

			cFormaPG := aPgtos[nI][AScan( aPgtos[nI] , { |x| x[1] == "L4_FORMA"   } )][2]
			nValorPG := aPgtos[nI][AScan( aPgtos[nI] , { |x| x[1] == "L4_VALOR"   } )][2]

			lAddPay := STIAddPay(AllTrim(cFormaPG), Nil, 1, Nil, Nil, nValorPG)
			lRet    := lRet .AND. lAddPay

		Next nI	

		If nSaldoNCCs > 0
			// alimentando as variaveis utilizadas nas rotinas do STiPosAuto
			STDSetNCCs("1", aNCCsCli  ) //Alimenta o array aNCCs
			STDGetNCCs("2", nSaldoNCCs)

			STIAddPay("CR", Nil, 1, Nil, Nil, nSaldoNCCs)
		EndIf

		//Finaliza venda
		lRet :=  STBConfPay(oMdlGrd, aCopyPaym,oMdlPaym)

	EndIf	

	If !lRet
		lMsErroAuto     := .T. //Sinaliza Erro para ExecAuto
		cErro := "STFPOSAUTO ERROR: " + Chr(10)+ Chr(13) 
		cErro += STFLatestMsg()
		ConOut("cErro")
		Help( " ", 1, "Help",, cErro, 1, 0 )
	EndIf	
	
	FreeObj(oCliModel)
	FreeObj(oModelCesta)		
	FreeObj(oModelPay)		
	FreeObj(oMdlGrd)			
	FreeObj(oMdlPaym)		
	FreeObj(oModel)				

Return lRet
//--------------------------------------------------------
/*/{Protheus.doc} STFSaleCan
Executa operação de venda no TOTVS PDV de forma automática sem exibição de Tela.
Pode ser usado para testes automátizados etc.
@param   aCab   - Cabeçalho da venda
@param   aItens - Itens da venda 
@param   aPgtos - Pagamentos da venda

@type function
@author  	rafael.pessoa
@since   	08/02/2018
@version 	P12
@param 		
@return		lRet - Retorna se executou corretamente
/*/
//--------------------------------------------------------
Static Function STFSaleCan( aCancSale )

Private cGetCanc := aCancSale[1]
private oStruGrd
Private oPanel

	//carrega os dados da venda
	aValidCancel	:= STBCSCanCancel(cGetCanc)
	lRet			:= aValidCancel[1]

	If lRet
		/*/
		Seta Informações cancelamento
		/*/
		STISetCancel( aValidCancel )
		/*/
		Ação botão de cancelar venda
		/*/
		IIF(ExistFunc("STBActionCancel"),STBActionCancel(cGetCanc), .F. )
	EndIf
Return( lRet )

//--------------------------------------------------------
/*/{Protheus.doc} STFIccAuto
Executa operação de inclusão de um novo usuário no TOTVS PDV de forma automática sem exibição de Tela.
Pode ser usado para testes automátizados etc.
@param   aDadosCli   - Dados do cliente

@type function
@author  	julioteixeira
@since   	05/07/2018
@version 	P12
@param 		
@return		lRet - Retorna se executou corretamente
/*/
//--------------------------------------------------------
Static Function STFIccAuto(aDadosCli,cErro)

Local lRet := .T.
Local nX := 1
Local nPos := 0
Local lAutoGenCod := .T.
Local cCodCliente := ""
Local lOpenRegItem := .F.
Local oLojCliente := Nil
Local cLojCliente := ""
Local aCliente := {{"A1_LOJA" ,""},;//1
				  {"A1_NOME"  ,""},;//2
				  {"A1_NREDUZ",""},;//3
				  {"A1_PESSOA",""},;//4
				  {"A1_TIPO"  ,""},;//5
				  {"A1_CGC"   ,""},;//6
				  {"A1_END"   ,""},;//7
				  {"A1_EST"   ,""},;//8
				  {"A1_MUN"   ,""},;//9
				  {"A1_TEL"   ,""},;//10
				  {"A1_EMAIL" ,""},;//11
				  {"A1_DDD"   ,""}} //12
				  
Default aDadosCli := {}
DeFault cErro := ""

For nX := 1 to len(aCliente)
	nPos = aScan(aDadosCli,{|x| x[1]==aCliente[nX][1]})
	If nPos > 0
		aCliente[nX][2] := aDadosCli[nPos][2] 
	Endif	
Next nX
 
If(STICGCVld(aCliente[6][2],aCliente[4][2],@cCodCliente,oLojCliente,.T.,aCliente[1][2])[3],,(cErro := "CPF: "+aCliente[6][2]+", invalido!",lRet := .F.))
If(STDExistChav("SA1",cCodCliente+aCliente[1][2],,""),,(cErro := "Cliente já cadastrado!",lRet := .F.))
If lRet
	lRet := STIConfCustomer(cCodCliente	,aCliente[1][2]	,aCliente[2][2]		,aCliente[3][2]		,;
				aCliente[4][2]	  	,aCliente[6][2]		,aCliente[5][2]		,aCliente[7][2]		,;
				aCliente[8][2]    	,aCliente[9][2]		,lAutoGenCod,lOpenRegItem,;
				,,,{"A1_FILIAL","A1_COD","A1_LOJA","A1_NOME","A1_NREDUZ","A1_END","A1_TIPO","A1_EST","A1_MUN","A1_PESSOA","A1_CGC","A1_DDD","A1_TEL","A1_EMAIL"},;
				{{xFilial("SA1"),cCodCliente,aCliente[1][2],aCliente[2][2],aCliente[3][2],aCliente[7][2],aCliente[5][2],aCliente[8][2],aCliente[9][2],;
				aCliente[4][2],aCliente[6][2],aCliente[12][2],aCliente[10][2],aCliente[11][2]}})			
EndIf

FreeObj(oLojCliente)//Libera objeto 
	
Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STFRecAuto


@param   aDados   - Dados

@type function
@author  	julioteixeira
@since   	12/07/2018
@version 	P12
@return		lRet - Retorna se executou corretamente
/*/
//--------------------------------------------------------
Static Function STFRecAuto(aCli,aTit,aPgtos,aNCC,aCheque)

Local lRet := .T.
Local oCliModel 
Local oMdl 		:= Nil													//Recupera o model ativo
Local oMdlGrd	:= Nil													//Seta o model do grid
Local oMdlPaym	:= Nil													//Seta o model do pagamento
Local aCopyPaym	:= STIGetSx5()[2]
Local aListTitles :={}
Local oWFReceipt
Local nX := 1
Local nY := 1
Local nPos := 0
Local cFormaPG := ""
Local nValorPG := 0
Local cAdminis := ""
Local nParc := 1
Local oMdlC	:= Nil 
Local cGetNSU := ""
Local cGetAutoriz := ""
Local lContTef := .F.
Local dData := ctod("")

Default aCli := {}
Default aTit := {}
Default aPgtos := {}
Default aNCC := {}
Default aCheque := {}

oMdl 		:= ModelPayme()													
oMdlGrd		:= oMdl:GetModel("PARCELAS")
oMdlGrd:Activate()
oMdlPaym	:= oMdl:GetModel("APAYMENTS")
oMdlPaym:Activate()

STISetRecTit(.T.)

oWFReceipt := STWReceiptTitle():STWReceiptTitle(aCli[1],aCli[2],aCli[3],"")
If (lRet := oWFReceipt:LoadTitles())
	
	oCliModel := STWCustomerSelection(aCli[1]+aCli[2],"")
	
	STWReceTit()
	
	For nX := 1 To Len(aPgtos)
		For nY := 1 to Len(aPgtos[nX])
			Do Case 
				Case aPgtos[nX][nY][1] == "L4_FORMA"
					cFormaPG := aPgtos[nX][nY][2] 
				Case aPgtos[nX][nY][1] == "L4_VALOR"
					nValorPG := aPgtos[nX][nY][2]
				Case aPgtos[nX][nY][1] == "L4_ADMINIS"
					cAdminis := aPgtos[nX][nY][2]
				Case aPgtos[nX][nY][1] == "L4_NSUTEF"
					cGetNSU  := aPgtos[nX][nY][2]
				Case aPgtos[nX][nY][1] == "L4_AUTORIZ"
					cGetAutoriz := aPgtos[nX][nY][2]
				Case aPgtos[nX][nY][1] == "L4_DATA"	
					dData	:= aPgtos[nX][nY][2]
				Case aPgtos[nX][nY][1] == "L4_PARC"	
					nParc	:= aPgtos[nX][nY][2]
				Otherwise	
			End Case		
		Next nY
		
		If cFormaPG $("CC|CD")
			oMdlC := ModelCard()//oModel:GetModel("CARDMASTER")
			oMdlC := oMdlC:GetModel("CARDMASTER")
			
			oMdlC:DeActivate()
			oMdlC:Activate()
			
			oMdlC:LoadValue("L4_FILIAL", xFilial("SL4"))
			oMdlC:LoadValue("L4_DATA", dData)
			oMdlC:LoadValue("L4_VALOR", nValorPG)
			oMdlC:LoadValue("L4_PARC", nParc)
			oMdlC:LoadValue("L4_ADMINIS", cAdminis)
			
			If !Empty(cGetNSU)
				oMdlC:LoadValue("L4_NSUTEF", cGetNSU)
			EndIf
			If !Empty(cGetAutoriz)
				oMdlC:LoadValue("L4_AUTORIZ", cGetAutoriz)
			EndIf
			
			oTEF20 := STBGetTEF()
		
			STISetCard(.T.)
			STISetTef(oTEF20)
		Elseif cFormaPG == "CH"
			STWSetCkRet(aCheque)		
		Endif
			
		lRet := STIAddPay(AllTrim(cFormaPG), oMdlC, nParc, cFormaPG $("CC|CD") , Nil, nValorPG)
	Next nX
	
	//Marca os títulos a serem baixados
	For nX := 1 to len(aTit) 
		If (nPos := aScan(oWFReceipt:aListTitles[4],{|x| x[16]==aTit[nX][16]})) > 0
			oWFReceipt:aListTitles[4][nPos][1] := .T.//Selecionado
			oWFReceipt:aListTitles[4][nPos][7] := aTit[nX][7]//Multa
			oWFReceipt:aListTitles[4][nPos][8] := aTit[nX][8]//Juros
			oWFReceipt:aListTitles[4][nPos][9] := aTit[nX][9]//Desconto
			oWFReceipt:aListTitles[4][nPos][10]:= aTit[nX][6]+aTit[nX][7]+aTit[nX][8]-aTit[nX][9]
		Endif
	Next nX
	
	If lRet .AND. oWFReceipt:DropTitles(oMdlGrd,STIGetIsCont())
		STISetCard(.F.)
		oWFReceipt:Print(oMdlGrd)
		lRet := .T. 
		STFSetTot( 'L1_VLRTOT' , 0 )
		STISetRecTit(.F.) // Depois de finalizar, seta que nao eh mais recebimento
	Else
		lRet := .F.
	EndIf

	If lRet
		STISetRecTit(.F.)
		STFRestart()
	EndIf	

Endif

FreeObj(oWFReceipt)

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} STFEsRAuto


@param   aDados   - Dados

@type function
@author  	julioteixeira
@since   	24/07/2018
@version 	P12
@return		lRet - Retorna se executou corretamente
/*/
//--------------------------------------------------------
Static Function STFEsRAuto(aCli,aTit)

Local aNCCs   := STDGetNCCs("1") //NCCs do cliente
Local aNCCCli := {}
Local cTpOp	  := STIGetTpOp()	//Tipo de operacao
Local nParcTotal := 0
Local nX := 1
Local oWFReceipt
Local oObjRec 
Local lRet := .T.

Default aTit := {}
Default aCli := Array(3)

oWFReceipt := STWReceiptTitle():STWReceiptTitle(aCli[1],aCli[2],aCli[3],"")
oObjRec := STIRetObjTit() 

oWFReceipt:SetReverseMode(.T.)

If (lRet := oWFReceipt:LoadTitles())
	//Marca os títulos a serem baixados
	For nX := 1 to len(aTit) 
		If (nPos := aScan(oWFReceipt:aListTitles[4],{|x| x[16]==aTit[nX][16]})) > 0
			oWFReceipt:aListTitles[4][nPos][1] := .T.//Selecionado
			STISetTitSelecionado(nPos,.T.)
			nParcTotal := nParcTotal + oWFReceipt:GetParcTotal(nX)
			oWFReceipt:SetParcSelecte44368d(nX, .T.)
			AADD(aNCCCli,{oWFReceipt:aListTitles[4][nX][13],oWFReceipt:aListTitles[4][nX][14]}) /// Codigo de Cliente e Loja do Titulo
		Endif
	Next nX
	
	STFSetTot( 'L1_VLRTOT', nParcTotal )
	
	If Len(oWFReceipt:aListTitles[4]) > 0 .AND. !Empty(nParcTotal) .AND. lRet
		If oWFReceipt:ReverseDropTitles()
			oWFReceipt:Print()
			STFRestart()
		Else
			//Necessario zerar o total para poder efetuar outras operações no caixa.
			STFSetTot( 'L1_VLRTOT', 0 )
			lRet := .F.
		EndIf
	Endif	
Endif

Return lRet
