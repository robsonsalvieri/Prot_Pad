#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FRTA271.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "FRTDEF.CH"
 
#DEFINE	 FRT_SEPARATOR		"----------------------------------------"

// Indices do Array aItens
// Sempre Que Houver a Necessidade de Alterar o aItens, Sempre Verificar o AIT_CANCELADO
#DEFINE AIT_ITEM				1
#DEFINE AIT_COD				    2
#DEFINE AIT_CODBAR				3
#DEFINE AIT_DESCRI				4
#DEFINE AIT_QUANT				5
#DEFINE AIT_VRUNIT				6
#DEFINE AIT_VLRITEM				7
#DEFINE AIT_VALDESC		   		8
#DEFINE AIT_ALIQUOTA			9          
#DEFINE AIT_VALIPI				10
#DEFINE AIT_CANCELADO			11
#DEFINE AIT_VALSOL   			12
#DEFINE AIT_DEDICMS   			13          // Deducao de ICMS
#DEFINE AIT_ITIMP   			14          // Numero do item na Impressora
#DEFINE AIT_PBM		   			15          // Define se o produto e PBM 
#DEFINE AIT_IMPINCL             16          // Verifica se o imposto esta incluido no valor do item

#DEFINE _FORMATEF				"CC;CD"     // Formas de pagamento que utilizam opera็ใo TEF para valida็ใo
#DEFINE CRLF                   Chr(13)+Chr(10)  //Pula linha


Static cGetCliDir 
Static cProfStr1
Static lCancItRec	:= .F.							// Indica que o item de recarga precisa ser cancelado antes de finalizar a venda, porque a transa็ใo ja foi desfeita
Static oPbm	:= Nil									//Objeto oPbm
Static bkp_oDlgFrt									//Objeto da Tela do Front utilizado na Finalizacao da PBM
Static bkp_oFntGet									//Objeto da Tela do Front utilizado na Finalizacao da PBM

Static aVidaLinkD	:= {}						//array de detalhe (produto,qtde,preco) com o orcamento gerado no PBM VidaLink
Static aVidaLinkc	:= {}						//array cabecalhoe (Cliente,loja,etc) do orcamento gerado no PBM VidaLink
Static nVidaLink	:= 0 						//Indica se Itens veio do VidaLink. 0=Nao usa VidalInk. 1=Gravando VidaLink. 2=Gravou VidaLink
Static lEmitNfce	:= ExistFunc("LjEmitNFCe") .AND.  LjEmitNFCe()			//Sinaliza se utiliza NFC-e
Static lUseSAT 		:= LjUseSat() 
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuno	 ณ FRTA271  ณ Autor ณ    Vendas Clientes    ณ Data ณ06/06/2000ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Vendas - FrontLoja										  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ FRTA010()									              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ FrontLoja												  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/              		
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFRTA271A  บAutor  ณMicrosiga           บ Data ณ  06/24/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 

Function FRTA271(lFRTAuto)
Local nTamSXG
Local nRPCInt
Local lTefMult		:= SuperGetMV("MV_TEFMULT", ,.F.)	//Identifica se o cliente utiliza m๚ltiplas transa็๕es TEF
Local nX
Local nMVAUTOCOM
Local lTefPendCS  	:= .F.								// Controla se existe TEF Pendente da CLISITEF
Local aTefBKPCS     := {}								// Guarda a transacao TEF Pendente da CLISITEF
Local nTB1COD	    := TamSX3("BI_COD")[1]				// Tamanho do campo B1_COD
Local cImpressora	:= CRIAVAR("LG_IMPFISC",.F.)		// Inicializa com o tamanho original do campo LG_IMPFIS: Qual a impressora fiscal ligada.
Local cPorta		:= CRIAVAR("LG_PORTIF",.F.)		// Determina qual a Porta de impressao informada no cadastro de estacao desse caixa
Local cCliente 		:= ""								// Codigo do cliente
Local cLojaCli 		:= ""								// Loja do cliente
Local cTipoCli 		:= ""								// Loja do cliente
Local cVendLoja		:= ""								// Vendedor
Local cVndLjAlt		:= ""								// Backup Vendedor para funcao FRTX272T10
Local lOcioso		:= .T.								// Nao Esta fazendo NENHUMA VENDA. (Nenhum Cupom Aberto)
Local lRecebe     	:= .F.								// Esta realizando Recebimento de Parcelas					
Local lLocked		:= .F.								// Solicitado Travamento Pelo Server. (CARGA)
Local lCXAberto		:= .F.								// Caixa Esta FECHADO
Local lDescIT		:= .T.								// Indica se o item atual JA TEVE DESCONTO
Local lDescITReg	:= .F.								// Indica se permite desconto apos o registro do item
Local aDadosVen		:= {{"",0}}
Local aDadosSan		:= {{"",0}}

Local cSimbCheq   	:= AllTrim(MVCHEQUE)
Local dDataCN	    := dDataBase 						// Data utilizada como referencia durante utilizacao da Condicao Negociada
Local nVlrFSD     	:= 0
Local nVlrDescTot	:= 0								// VALOR DO DESCONTO
Local aCNPJVLD   	:= {}              //CNPJs validos 
Local lTouch		:= .F.
Local aMoeda    	:= {}
Local aSimbs     	:= {}
Local nMoedaCor  	:= 1
Local nDecimais  	:= NIL
Local lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)	// Indica se usa integracao com cenario de vendas
Local cTabPadrao	:= ""								// Tabela de precos padrao
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a estacao possui Display ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lUsaDisplay 	:= !Empty(LjGetStation("DISPLAY"))
//Variaveis criadas pelo Depto de Localizacoes                              
Local lVisuSint  	:= .F.	//Indica se a interface utilizarแ a forma de visualiza็ใo sintetizada ou a antiga, evitando problemas com a metodologia anterior
Local nTA1TIPO		:= NIL												//Tamanho do campo A1_TIPO
Local aRegTEF		:= {}												// Array com as movimenta็๕es do TEF da recargas
Local lRecarEfet	:= .F.												// Indica se foi efetuada alguma recarga na venda.
Local lPermitEcf	:= .T.												//Verifica se possui permissao para ECF
Local lConfCx		:= SuperGetMV("MV_LJCONFF",.F.,.F.) .AND. IIf(ExistFunc("LjUpd70Ok"),LjUpd70Ok(),.F.) //Verifica se o parametro que define a utilizacao da conferencia de caixa esta habilitada
Local lFechaCaixa 	:= SuperGetMv("MV_LJFECCX",,.T.)	// Indica se usa Fechamento automแtico de caixa na tabela SLW
Local lPOS			:= ExistFunc("STFIsPOS") .AND. STFIsPOS()  //TO DO: Colocar a regra de como identificar de estแ sendo executado Front ou POS
Local lWsOk			:= .T.		//Sinaliza se conexao WebService esta disponivel, para evitar que outras rotinas facam a tentativa causando lentidao na abertura do sistema
Local lLjNfPafEcf	:= LjNfPafEcf(SM0->M0_CGC) 
Local aAnalisLeg65	:= LJAnalisaLeg(65)
Local aRetChSat		:= {} //retorno chave de ativa็ใo SAT
Local lContinua		:= .F.
Local lRecovery		:= .F. //recuperacao de venda SAT
Local lIsMDI 		:= Iif(ExistFunc("LjIsMDI"),LjIsMDI(),oApp:lMDI) //Verifica se acessou via SIGAMDI

DEFAULT lFRTAuto	:= .F.  

DbSelectArea("SLG")
If !(SLG->(DbSeek(xFilial("SLG")+cEstacao)))
	Help(" ",1,"NOESTACAO")
EndIf

//Func็ใo chamada
If lPOS	.OR. STFPdvOn(cEstacao)
	If ExistFunc("STFUserProfInfo") .AND. (STFUserProfInfo("FRTAUTO") == "S")
		//Com permissใo de caixa abre diretamente o PDV
		STIPosMain() 
		// Caso estiver com acionamento automatico da tela de venda o sistema ้ fechado totalmente
		If lFRTAuto
			Final()
		EndIf
	ElseIf !lFRTAuto
		MsgStop(STR0361) //"Ambiente configurado para TotvsPdv, para utilizar o FrontLoja altere o conte๚do da chave PosLight = 0 no AppServer.ini deste ambiente"
	EndIf	
	
	Return .T.
Else
	If FindFunction("LjMsgInfo")
		LjMsgInfo( 300, 200,  ;               
				STR0371,   ;                        // "Configura็ใo Incorreta para o TOTVS PDV"
				STR0369 + CRLF + CRLF + ;           // "A rotina de Atendimento FRTA271 do m๓dulo frontLoja foi descontinuada."
				STR0374 + CRLF + CRLF + ;           // "Nใo foi localizada a chave PosLight para o TOTVS PDV Offline e nem identificada a configura็ใo do TOTVS PDV Online habilitada (LG_PDVON=1)."
				STR0370 + CRLF + CRLF, ;  			// "Revise as configura็๕es para o TOTVS PDV. Clique em Saiba Mais:"
				.F.,      ;                         // lHtml = .F.
				"https://tdn.totvs.com/pages/viewpage.action?pageId=1067035530", ; // link
				"", 0 )
	Else
		FWAlertWarning( STR0369 + CRLF + CRLF + ;  // "A rotina de Atendimento FRTA271 do m๓dulo frontLoja foi descontinuada."
						STR0374 + CRLF + CRLF + ;  // "Nใo foi localizada a chave PosLight para o TOTVS PDV Offline e nem identificada a configura็ใo do TOTVS PDV Online habilitada (LG_PDVON=1)."
						STR0370 + CRLF + CRLF , ;  // "Revise as configura็๕es para o TOTVS PDV. Clique em Saiba Mais:"
						STR0371 )                  // "Configura็ใo Incorreta para o TOTVS PDV"
	EndIf
	
	Final()
EndIf

/*-------------------------------------------------------------
	Avisa ao usuแrio sobre a desativa็ใo da NFC-e 3.10
-------------------------------------------------------------*/
If lEmitNfce .And. !lUseSAt
	If ExistFunc("LjNfceMsg")
		cMsg := LjNfceMsg()
		
		If !Empty(cMsg)
			STPosMSG( "NT 2016.002" , cMsg, .T., .F., .F.)
		EndIf
	EndIf
EndIf

If  (lEmitNfce .AND. !lUseSAT .And. ExistFunc("Lj7NfceVer") .And. !Lj7NfceVer(lFRTAuto)) //lUseSAT
	Return .T.
EndIf

If !ExistFunc("FR271BChkModo")
	If !lFRTAuto
		MsgStop(STR0362) //"Foi constatada a utiliza็ใo do RPO reduzido, seu funcionamento ้ exclusivo para o TotvsPdv, nใo serแ possํvel acessar o FrontLoja"
	EndIf
	
	Return .T.
EndIf

//Variแves carregada por fun็๕es existentes no RPO do Front
lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )    //manter
nDecimais  	:= MsDecimais(nMoedaCor)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a estacao possui Display ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lUsaDisplay 	:= !Empty(LjGetStation("DISPLAY"))

//Variaveis criadas pelo Depto de Localizacoes
                              
lVisuSint  	:= If(SL4->(FieldPos("L4_FORMAID"))>0,.T.,.F.) 	//Indica se a interface utilizarแ a forma de visualiza็ใo sintetizada ou a antiga, evitando problemas com a metodologia anterior
nTA1TIPO		:= TamSX3("A1_TIPO")[1]								//Tamanho do campo A1_TIPO

If lIsMDI															// verifica a propriedade do objeto verdadeiro se MDI
	MsgStop(STR0339)	//"O acesso a rotina atendimento na interface SIGAMDI nใo ้ permitido."
	Return(.F.)
EndIf

// Protege rotina para que seja usada apenas no SIGALOJA / Front Loja
If !AmIIn(12,23)
	Return(.F.)
EndIf

//Validar a configuracao de conferencia de caixa entre a retaguarda e a estacao
If FindFunction("LjChkCfgCF")
	If !LjChkCfgCF(@lWsOk)
		Return .F.
	Endif
Endif 

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica a exist๊ncia da fun็ใo da configura็ใo daณ
//ณanalise de credito do financial                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ENDDOC*/  
If lWsOk .AND. FindFunction("LjCkCfgIFS")
	If !LjCkCfgIFS()
		Return .F.
	Endif
Endif 


Private aTefDados		:= {}
Private lTTefAberto		:= .F. 
Private nNumUltIt		:= 0					   // Numero do ultimo item registrado no cupom.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variavel utilizada para a nova DLL Fiscal ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Public oAutocom

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe nao tem midia cadastrada e for obrigatorio informar, mostra msg de alerta  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !(lFRTAuto) .AND. SuperGetMv("MV_LJRGMID",,0) == 2 .AND. ExistFunc("LjxValMid") .AND. !LjxValMid() 
	MsgInfo(STR0342) //"O parametro MV_LJRGMID esta com o preenchimento obrigatorio porem nao existem midias cadastradas, favor regularizar."	  	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variavel utilizada para registro de midia ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If SuperGetMv("MV_LJRGMID",,0) == 1 .OR. SuperGetMv("MV_LJRGMID",,0) == 2    
	M->L1_MIDIA := CriaVar("L1_MIDIA")           // Variavel utilizada para registro de midia
	M->L1_MIDIA := Space(TamSX3("UH_MIDIA")[1]) // Codigo da Midia
EndIf  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAjusta os Helps.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AjustaHelp()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSe utiliza cenario de vendas, verifica se a tabela esta validaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lCenVenda .And. SuperGetMV("MV_LJRETVL",,"3") == "3" //1=Retorna o menor preco de uma tabela | 2=Retorna o maior preco de uma tabela | 3=Considera preco da tabela configurada no parametro MV_TABPAD

	cTabPadrao := SuperGetMv("MV_TABPAD")   
	
	DA0->(DbSetOrder(1))

	If !DA0->(DbSeek(xFilial("DA0")+cTabPadrao))
		MsgStop(STR0332) //"Tabela de preco invalida no parametro MV_TABPAD"
		Return Nil
	EndIf

	If !MaVldTabPrc(cTabPadrao)
		Return Nil
	EndIf

EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Funcao que cria o objeto oAutocom         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
CriaAutocom()             
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica compatibilidade entre o campo L4_FORMAID e MV_TEFMULT. Se o parametro estiver .T., o campo deve existir |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lTefMult .AND. !lVisuSint
   CriaAutocom()
   //"Hแ uma incompatibilidade na funcionalidade M๚ltiplas Transa็๕es TEF."		
   //"Com o parโmetro MV_TEFMULT habilitado, o campo L4_FORMAID deve estar criado no dicionแrio de dados."
   //"Verifique com o Administrador do sistema para desabilitar o parโmetro ou criar o campo."		
   MsgStop(STR0304 + CRLF + STR0305 + CRLF + STR0306)
   Return (.F.)
EndIf

If cPaisLoc <> "BRA"
	/////////////////////////////////////////////////////////////////////////////////
	//O array aDadosJur armazena os resultados do calculo dos juros ou desconto    //
	//financeiro sendo que o mesmo eh valorizado na funcao LjxDRecVB , que se      //
	//encontra no Loja010c.prw                                                     //
    /////////////////////////////////////////////////////////////////////////////////
	//Descricao do Array                                                           //
	//aDadosJur[1] => Total do acrescimo                                           //
	//aDadosJur[2] => Valor Liquido da Venda                                       //
	//aDadosJur[3] => Valor Base da Venda                                          //
	//aDadosJur[4] => Valor total dos impostos                                     //
	//aDadosJur[5] => Total de desconto                                            //
	//aDadosJur[6] => Valor anterior do imposto                                    //
	//aDadosJur[7] => Taxa de juros			                                       // 
	//aDadosJur[8] => Percentual de desconto                                       //	 
	//aDadosJur[9] => Valor do desconto financeiro                                 //	
	/////////////////////////////////////////////////////////////////////////////////	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ      Descrico do array aImpsSL1          ณ
	//รฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
	//ณPosicaoณ Descrico						  ณ
	//รฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
	//ณ  1	  ณ Codigo do imposto                 ณ
	//ณ  2	  ณ Campo do valor do imposto no SL1  ณ
	//ณ  3	  ณ Valor do imposto                  ณ
	//ณ  4	  ณ Campo da base do imposto no SL1   ณ
	//ณ  5	  ณ Base do imposto                   ณ
	//ณ  6	  ณ Imposto incrementa na NF          ณ
	//ณ  7	  ณ Aliquota do imposto               ณ
	//ภฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ      Descrico do array aImpsSL2           ณ
	//รฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
	//ณPosicao ณ Descrico						   ณ
	//รฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
	//ณ   1	   ณ Codigo do produto                 ณ
	//ณ   2	   ณ TES                               ณ
	//ณ   3,1  ณ Codigo do imposto                 ณ
	//ณ   3,2  ณ Aliquota do imposto               ณ
	//ณ   3,3  ณ Base do imposto                   ณ
	//ณ   3,4  ณ Valor do imposto                  ณ
	//ณ   3,5  ณ Soma na dupl/Soma na NF/Cred.custoณ
	//ณ   3,6  ณ Cpo grav. valor do imposto no itemณ
	//ณ   3,7  ณ Cpo grav. base do imposto no item ณ
	//ณ   3,8  ณ Cpo grav. valor do imposto no cab.ณ
	//ณ   3,9  ณ Cpo grav. base do imposto no cab. ณ
	//ณ   3,10 ณ {1,-1,0}                          ณ
	//ณ   3,11 ณ Quantidade                        ณ
	//ณ   3,12 ณ Valor unitario                    ณ
	//ณ   4	   ณ Item                              ณ
	//ณ   5	   ณ Registro cancelado                ณ
	//ณ   6	   ณ Quantidade                        ณ
	//ณ   7	   ณ Valor unitario                    ณ
	//ภฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ      Descrico do array aTotVen           ณ
	//รฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
	//ณPosicaoณ Descrico						  ณ
	//รฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤด
	//ณ  1	  ณ Ordem da moeda                    ณ
	//ณ  2	  ณ Nome da moeda                     ณ
	//ณ  3	  ณ Valor da venda em n moedas        ณ
	//ณ  4	  ณ Deve calcular em outra moeda      ณ
	//ภฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		
EndIf   

FR271BChkModo()														// Realiza a Checagem do Modo do SB1 e SBI

xNumCaixa()
DbSelectArea("SLF")
SLF->(DbSetOrder(1))
SLF->(DbSeek(xFilial("SLF")+SA6->A6_COD))
cStrAcesso := SLF->LF_ACESSO
If Empty(cEstacao)
	Help(" ",1,"NOESTACAO")
	cEstacao := "001"
EndIf
DbSelectArea("SLG")
If !(SLG->(DbSeek(xFilial("SLG")+cEstacao)))
	Help(" ",1,"NOESTACAO")
EndIf
cImpressora	:= LjGetStation("IMPFISC")
cPorta		:= LjGetStation("PORTIF")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica Se Foi Chamado Pelo SIGAFRT.PRW. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lFRTAuto
	If ! (LjGetProfile("FRTAUTO") == "S")
		If LjGetProfile("MULTIMI") == "S"
			LJ060Vis("SBI", 0)
		EndIf
		Return(NIL)
	EndIf
EndIf

lFRTAuto := (LjGetProfile("FRTAUTO") == "S")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona o Usuario no SA6 e Verifica Permissao. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !LjxDChkVenda(.F.,.T.)
	If lFRTAuto										// Entrada Automatica, Saida Automatica.
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Finaliza o Job FRTA020, Quando For TwoTier ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    FR2712Tier()
	EndIf
	Return(NIL)
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica Permissao "Usa Imp. Fiscal" - #3       ณ
//ณ PTG,ANG e CHI (Release 11.5) - Nao Utilizara ECFณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


If ExistFunc("LjNfPtgNEcf") 
	lPermitEcf := !LjNfPtgNEcf(SM0->M0_CGC)
EndIf

If lPermitEcf                                                                       
	lFiscal := LJProfile(3)
	If !lFiscal
		HELP(" ",1,"FRT002")		// "Usuแrio sem permissใo para usar impressora fiscal.", "Aten็ใo"
		If lFRTAuto					// Entrada Automatica, Saida Automatica.
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Finaliza o Job FRTA020, Quando For TwoTier ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		    FR2712Tier()
		EndIf
		Return(NIL)
	EndIf
	
	If cPaisLoc == "BRA" .AND. !lLjNfPafEcf .AND. LJAnalisaLeg(64)[1] .AND. aAnalisLeg65[1] .AND. !lEmitNfce
		LJMsgLeg(aAnalisLeg65)
		Final(STR0343) //"Relat๓rio Gerencial nใo enviado e PAF-ECF nใo liberado! Verifique!"
	EndIf
	
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRelease 11.5 - Localizacao                                   ณ
	//ณSe for dispensado o uso do ECF, a variavel de usuario fiscal ณ
	//ณsera definida de acordo com o perfil de caixa.               ณ
	//ณPaises: Chile  - F1CHI                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cPaisLoc == "CHI"
		lFiscal := LJProfile(3)
	Else
		lFiscal := .F.
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Verifica se M0_ESTCOB esta preenchido para a validacao referente a legislacao  |
//| de acordo com cada estado 													   | 
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(SM0->M0_ESTCOB)
   //"Foi detectado que o campo referente ao estado de cobranca(M0_ESTCOB) nao esta configurado."
   //"Solicite ao Administrador para configurar o arquivo sigamat.emp."
   MsgStop(STR0321 + chr(13) + chr(10) + STR0322)
   Return (NIL)      
Endif   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso use controle de fechamento e o caixa esteja aberto , avisa
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF !lFechaCaixa
	ljCxAberto(.T.,)	 
EndIf	
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCaso exista tratamento para movimento e o caixa esteja abertoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If AllTrim(LjNumMov()) <> ""
	lCxAberto := .T.
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se o repositorio de imagens esta ok. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
LJMsgRun(STR0215,, {|oDlg| FR271IChkBMP(oDlg)})	// "Aguarde. Verificando reposit๓rio de imagens..."

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a estacao possui Leitor de CMC7 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lUsaCmc7:= !Empty(LJGetStation("CMC7")) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a estacao possui Impressora de Cheque  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lUsaCH	:= !Empty(LJGetStation("IMPCHQ"))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a estacao possui Gaveta ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lGaveta	:= !Empty(LjGetStation('GAVETA'))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se a estacao possui Leitor Optico Serial ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lUsaLeitor := !Empty(LjGetStation('OPTICO'))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Intervalo Para Verificacao. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nRPCInt 	:= LjGetStation("RPCINT")
nRPCInt 	:= If(nRPCInt=0, 5, nRPCInt)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define cliente com o padrao do parametro ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
cTipoCli := Left(GetAdvFVal("SA1","A1_TIPO",xFilial("SA1")+cCliente+cLojaCli,1,"F")+Space(nTA1TIPO),nTA1TIPO)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define o Vendedor como o padrao definido no parametro ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTamSX3  := Len(SA3->A3_COD)
cVendLoja:= Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSX3),nTamSX3)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Zera os valores de desconto                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nVlrPercIT := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Prepara o Sist.para trabalhar com TEF                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lTefOk  := .F.
lUsaTef := LJProFile(2) 
cTipTEF := LjGetStation("TIPTEF")   

If lUsaTEF .AND. cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO+";"+TEF_CLISITEF+";"+TEF_CENTROPAG
    CriaAutocom()
	If cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_CLISITEF
		aPinPad:=LJGetStation({"PINPAD","PORTPAD"})
		nHdlPinPad:=PinPadAbr(aPinPad[1],aPinPad[2])
	EndIf
	If cTipTEF == TEF_CLISITEF
	    CriaAutocom()
		If SLG->(FieldPos("LG_IPSITEF")) == 0
			// "Para utilizar o TEF na modalidade CliSiTEF, ้ necessแrio configurar corretamente o " "Aten็ใo"
			MsgStop(STR0295+"LG_IPSITEF.", STR0003)
			lUsaTEF := .F.
		EndIf
		If SL4->(FieldPos("L4_FORMAID")) == 0
			// "Para utilizar o TEF na modalidade CliSiTEF, ้ necessแrio configurar corretamente o " "Aten็ใo"
			MsgStop(STR0295+"L4_FORMAID.", STR0003)
			lUsaTEF := .F.
		EndIf
		If !lUsaTEF .OR. ChkAutocom() == DLL_SIGALOJA	// Verifica o parametro MV_AUTOCOM
			// "Para utilizar o TEF na modalidade CliSiTEF, ้ necessแrio configurar corretamente o " "Aten็ใo"
			MsgStop(STR0295+" MV_AUTOCOM.", STR0003)
			lUsaTEF := .F.
		Else
			oTEF 	:= LJTEFAbre()	    				//Prepara o objeto TEF e carrega as variแveis necessแrias para a utiliza็ใo do TEF
			lUsaTef := oTef:lAtivo						//Indica se a abertura de terminal foi processada com sucesso
		EndIf				
	ElseIf cTipTEF == TEF_CENTROPAG .AND. cPaisLoc == "MEX" 
		oTEF 	:= LJACENTPAG():New()	    		//Prepara o objeto TEF e carrega as variแveis necessแrias para a utiliza็ใo do TEF
		lUsaTef := oTef:lAtivo						//Indica se a abertura de terminal foi processada com sucesso		
	Else
		lUsaTef :=	Loja010T(  	"A"   			, Nil 	, Nil			, Nil  	,;
	 			               	Nil 			, Nil 	, Nil			, Nil	,;
                			   	Nil				, Nil	, Nil			, Nil	,;	
                   				Nil	)
		                     		                     
		CriaAutocom()
	EndIf		
Else
	lUsaTef := .F.
EndIf

//Se nใo for usuแrio caixa nใo faz valida็ใo do SAT
If LjProfile(3)

	//Verifica se usa SAT
	If LjUseSat()

		//Tratativa para posicionar no ultimo registro da tabela SL1
		SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
		SL1->(DbSeek(xFilial("SL1")+PadR("Z",TamSX3("L1_NUM")[1]), .T.))
		SL1->(DbSkip(-1))

		If SL1->L1_SITUA == "10"
			MH2->(DBSetOrder(3)) //MH2_FILIAL + MH2_SERIE + MH2_DOC
			If MH2->(DBSeek(xFilial("MH2")+SL1->(L1_SERIE+L1_DOC)))
				lRecovery := .F.
			Else
				lRecovery := .T.
			EndIf
		EndIf
		
		//Valida se houve queda no meio do processo de cancelamento de venda
		If !lRecovery .And. ExistFunc("LjxLPCnSat")
			LjxLPCnSat(@lRecovery)
		EndIf		

		//inicia ambiente SAT
		If ExistFunc("LJSATInicia")
			lContinua := LJSATInicia(lRecovery)
		Else
			lcontinua := .F.
		EndIf
		
		//Pega a chave de ativa็ใo do sat para o cliente que esta acessando o sistema
		If lContinua .And. ExistFunc("LjGetSig") .AND. Empty(SuperGetMV("MV_SATTEST",,""))
			aRetChSat := LjGetSig()
			If Len(aRetChSat) > 0 .AND. !Empty(aRetChSat[2])
				MsgAlert(aRetChSat[2])
			Else
				If ExistFunc("LjSetChSat")
					LjSetChSat(aRetChSat[1])
				EndIf
			EndIf
		EndIf
		
		If !lContinua
			Return .F.
		EndIf
		
	EndIf
EndIf

If lTouch
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria tela do Front-Loja para Touch ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	FR271BVlGP(.T.)										// Valida o parametro MV_LJGRPPR 
	FRT273TS(	@cImpressora	, @cCliente		, @cLojaCli		, @cVendLoja	,;
				@lOcioso		, @lRecebe		, @lLocked		, @lCXAberto	,;
				@lDescIT		, @lDescITReg	, @aTefDados	, @dDataCN		,;
				@nVlrFSD		, @nVlrDescTot	, @aMoeda		, @aSimbs		,;
				@cPorta			, @cSimbCheq	, @cEstacao		, @lTouch		,;
				@aRegTEF		, @lRecarEfet	, @lCancItRec   , @lUsaDisplay	,;
				/*@nTaxaMoeda*/	, /*@aHeader*/	, /*@nVlrDescIT*/, @cTipoCli	,;
				/*@lBscPrdON*/	, /*@nConTcLnk*/, /*@cEntrega*/	, /*@aReserva*/	,;  
				/*@lReserva*/	, /*@lAbreCup*/	, /*@nValor*/	, /*@cCupom*/	,;
				@cVndLjAlt		, /*@cCliCGC*/)
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCria tela do Front-Loja para Remoteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	FRT272(	nRPCInt			, @cImpressora	, @cCliente		, @cLojaCli		,;	
			@cVendLoja		, @lOcioso		, @lRecebe		, @lLocked		,; 
			@lCXAberto		, @lDescIT		, @lDescITReg	, @aTefDados	,; 
			@dDataCN		, @nVlrFSD		, @nVlrDescTot	, @aMoeda		,;
			@aSimbs			, @cPorta		, @cSimbCheq	, @cEstacao		,;
			@lTouch			, @cTipoCli 	, @cVndLjAlt	, @aRegTEF		,;
			@lRecarEfet		, @lCancItRec	, @aVidaLinkD  	, @aVidaLinkC  	,;
			@nVidalink		, lFRTAuto ) 
Endif		

FRTSetKey()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fecha o Caixa ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lCXAberto .AND. lFechaCaixa  // se o caixa estiver aberto e nใo utiliza controle de fechamento 
	//Se o caixa estiver aberto e nao se utilize as rotinas de conferencia de caixa ou a tabela SLW nao esteja criada
	If !AliasIndic("SLW") .OR. !lConfCx
		Cx_Abre_Fecha(SA6->A6_COD, "F")
	Else
	
		// Apresentar instrucoes no display sobre o fechamento de caixa
		FRT271EDpF(1)
	
		//Caso o fechamento retorne falso, significa que este caixa possui pend๊ncias de confer๊ncia de fechamentos anteriores (LOCAL), abortar a sua abertura.
		If !Cx_Abre_Fecha(SA6->A6_COD,"F")
			// Apresentar no display que o fechamento de caixa nao ocorreu com sucesso
			FRT271EDpF(3)
			MsgAlert(STR0341)	//"Opera็ใo de confer๊ncia de caixa cancelada."
			LjLimpDisp()
		Else
			// Apresentar no display que o fechamento de caixa nao ocorreu com sucesso
			FRT271EDpF(2)
		Endif
	EndIf
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fechamento da Impressora Fiscal ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//Nao enviar comando para fechar porta em equipamento nใo fiscal utilizando NFC-e
If nHdlECF <> -1 .And. !lEmitNfce
	IFFechar(nHdlECF, cPorta)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fechamento da Impressora de Cheque ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lUsaCH
	CHFechar( nHdlCH, LJGetStation("PORTCHQ") )
EndIf

If lUsaTEF
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFecha arquivo de controle de numeracao TEFณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    L010ClTermTef()
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fechamento do CMC7 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lUsaCMC7
    CMC7Fec(nHdlCMC7, AllTrim(LJGetStation("PORTMC7")) )
EndIf   
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fechamento do Leitor Optico Serial ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lUsaLeitor
    LeitorFec(nHdlLeitor,LJGetStation("PORTOPT"))
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fechamento da Balanca Serial       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If StatBalanca()[1]
    BalancaFec(StatBalanca()[2],LJGetStation("PORTBAL"))
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fechamento da Gaveta ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lGaveta .AND. !Empty(LJGetStation("PORTGAV")) .AND. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
    GavetaFec(nHdlGaveta,LJGetStation("PORTGAV"))
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Fechamento do Display ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lUsaDisplay
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Exibir Mensagem de Finalizacao no Display ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MsgDisplay(2)
    DisplayFec(StatDisplay(), AllTrim(LJGetStation("PORTDIS")) )
EndIf   

If lFRTAuto										// Entrada Automatica, Saida Automatica.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza o Job FRTA020, Quando For TwoTier ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    FR2712Tier()
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณFR2712Tierณ Autor ณ                       ณ Data ณ06/06/2000ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ                     					        			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ FRTA010()									              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ FrontLoja												  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function FR2712Tier()
If cGetCliDir == NIL
   cGetCliDir := GetClientDir()
EndIf                                                                              
If cProfStr1 == NIL
   cProfStr1  := GetPvProfString("Config", "TwoTier", "0", cGetCliDir+Left(GetAdv97(),3)+"RMT.INI")
EndIf
   
If AllTrim(cProfStr1) == "1"
	FR271BGerSLI(Space(4), Space(3), "ENDTHREAD", "SOBREPOE")
	LjMsgRun(STR0159,, {|| FR271TWait2T()})	// "Aguarde, finalizando conexใo com o Servidor..."
EndIf
FRTCloseServices()
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณFR271TWait2T ณ Autor ณ                    ณ Data ณ06/06/2000ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ                     					        			  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ FRTA010()									              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ FrontLoja												  ณฑฑ 
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FR271TWait2T()
Local nTimeOut := 30                                             
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณNao realizar PMC no DbSeekณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SLI->(DbSeek(xFilial("SLI")+"       "))
	While .T. .AND. nTimeOut>0
		If SLI->(DbSeek(xFilial("SLI")+"       "))
			If Left(SLI->LI_MSG,2)=="OK"
				Exit
			EndIf
		Else
			Exit
		EndIf
		Sleep(1000)
		nTimeOut--
	End
EndIf
Return(NIL)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณFR271Hora ณ Autor ณ Cesar Eduardo Valadao ณ Data ณ06/06/2000ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Atualiza a Hora e eventualmente o Numero do Cupom		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ SIGAFRT	 												  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Progr.   ณ Data     BOPS   Descricao								  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณMauro S.  ณ23/01/06ณ091900ณInclusao do Ponto de Entrada FRTNUMCF para  ณฑฑ
ฑฑณ          ณ        ณ      ณdeixar o numero do cupom fiscal de 4 digitosณฑฑ
ฑฑณ          ณ        ณ      ณpara 6 digitos (Ex. Sweda)                  ณฑฑ
ฑฑ|          |        |      |Inclusao parametro lConsulta para verificar ณฑฑ
ฑฑณ          ณ        ณ      ณse esta gravando ou recuperando o n. cupom. ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FR271Hora(lDoc, lConsulta, oHora, cHora, oDoc, cDoc)
Local aParam 	:= {}                      
Local lTouch	:= If( LJGetStation("TIPTELA") == "2", .T., .F. )
Local lMenuFisc := IsInCallStack("STBMenFis") 
//ณRelease 11.5 - Controle de Formularios ณ
//ณPaises:Chile/Colombia - F1CHI		  ณ
Local lCFolLocR5:=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL" .AND. !lFiscal
					
DEFAULT lDoc 	  := .F.                   
DEFAULT lConsulta := .T.

cHora := Left(Time(),TamSX3("L1_HORA")[1])
If !lTouch .AND. !lMenuFisc
	oHora:Refresh()
Endif

If lDoc .AND. nHdlECF <> -1
	//ณRelease 11.5 - Controle de Formularios 						   ณ
	//ณSe estiver utilizando controle de formularios na venda, pegar   ณ
	//ณo numero de documento informado pelo usuario no inicio da venda.ณ
	//ณPaises:Chile/Colombia - F1CHI	   						       ณ		
	If !(lCFolLocR5)
		If IFPegCupom(nHdlECF, @cDoc) == 0		// Pega o Numero do Cupom
			If ExistBlock("FRTNUMCF")
				AaDD(aParam, cDoc) //numero original do cupom fiscal 
				AaDD(aParam, lConsulta) //indica se e leitura ou gravacao
				cDoc := ExecBlock("FRTNUMCF",.F.,.F.,aParam) //numero com 6 digitos 
			EndIf
			cDoc := PadR(cDoc, Len(SL1->L1_DOC))
		EndIf
	EndIf
	If !lTouch .AND. !lMenuFisc
		oDoc:Refresh()
	Endif	

EndIf
Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑณFuno	 ณFR271Resume ณ Autor ณ Cesar Eduardo Valadao ณDataณ09/08/2000ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Retomar a Venda do Ponto Que Parou						  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ SIGAFRT	 												  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Progr.   ณ Data     BOPS   Descricao								  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณThiago H. ณ29/08/06ณ106195ณCorrecao do problema encontrado no momento  ณฑฑ
ฑฑณ          ณ        ณ      ณda impressใo do cupom fiscal				  ณฑฑ
ฑฑณ          ณ        ณ      ณEstava imprimindo o codigo de barras do	  ณฑฑ
ฑฑณ          ณ        ณ      ณdo produto e nao o codigo do produto   	  ณฑฑ
ฑฑณ          ณ        ณ      ณSegundo parametro da funcao IFREGITEM()	  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณAnalista  ณ Data   ณ Bops ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณErik W.B  ณ19/05/07ณ124560ณAlterada a utiliza็ใo da chamada            ณฑฑ
ฑฑณ          ณ        ณ      ณSubStr(cUsuario,7,15) por cUserName         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/                                 
Function FR271Resume( 	cPDV		, oMoedaCor		, nMoedaCor		, cMoeda		,;
						oTaxaMoeda	, nTaxaMoeda	, cSimbCor		, oTemp3		,;
						cCodProd	, oFotoProd		, oProduto		, oUnidade		,;
						oQuant		, oVlrUnit		, oVlrItem		, oVlrTotal		,;
						oTotItens	, oDesconto		, cDoc			, nVlrTotal		,;	
						nVlrBruto	, nTotItens		, cProduto		, cUnidade		,;
						nQuant		, nVlrUnit		, oCupom		, cOrcam		,;
						cCliente	, cLojaCli		, lOcioso		, aItens		,;
						nVlrMerc 	, lExitNow		, lFechaCup		, aCrdCliente	,;
						uCliTPL		, uProdTPL		, nTotDedIcms	, aMoeda		,;
						aSimbs		, aImpsSL1		, aImpsSL2		, aImpsProd		,; 
						aImpVarDup	, aTotVen 		, aCols			, aHeader 		,;
						cVendLoja	, cTipoCli 		, oHora			, cHora			,;
						oDoc		, cDoc			, aPgtos		, lResume		,;
						cCupom		, lAbreCup		, cMensagem				)

Local nI			:= 1													// Contador de for
Local cAlias	 	:= Alias() 												// Tabela corrente
Local nOrder	 	:= SL1->(IndexOrd())									// Index Order do SL1
Local nRecno	 	:= 0													// Recno do registro
Local aCupom																// Dados do cupom fiscal
Local cRet		 	:= " "													// Texto de impressora
Local cTemp		 	:= ""                                  					// Temporario
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis utilizadas no calculo dos impostos variaveis - Localizacoesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local aImposto   	:= {}													// Imppostos
Local aImps      	:= {}													// Impostos gerais
Local aSL1			:= {}													// Contem dados para gera็ใo de SL1
Local aSL2			:= {}													// Contem dados para gera็ใo de SL2
Local nValImp    	:= 0                                                 	// Valor dos impostos
Local nTotImp    	:= 0													// Total de impostos
Local nVlrItem   	:= 0													// Valor do item
Local nDescUni   	:= 0													// Unidade de medida
Local nVlIcmRet  	:= 0 													// Valor do ICM Retido para ser somado junto ao item
Local cVlIcmRet  	:= 0 													// Valor do ICM Retido para ser impresso no cupom fiscal 
Local lFRTCODB2t 	:= ExistTemplate( "FRTCODB2" )							// Verifica se existe o ponto de entrada de template FRTCODB2
Local lFRTCODB3t 	:= ExistTemplate( "FRTCODB3" )							// Verifica se existe o ponto de entrada de template FRTCODB3
Local lT_FrtResume	:= ExistTemplate( "FRTRESUME")	   						// Verifica se existe o ponto de entrada de template FRTRESUME
Local aRetTplResume := {} 													// Retorno do template function FRTRESUME
Local nDedIcmsIt    := 0                            						// Valor da deducao do ICMS de um item da venda
Local nTB1COD	    := TamSX3("BI_COD")[1]									// Tamanho do campo B1_COD
Local nTB1CODBAR    := TamSX3("BI_CODBAR")[1] 								// Tamanho do campo B1_CODBAR
Local nRet 			:= 1													// Retorno de funcao de impressora
Local cCodBar		:= ""          											// Codigo de barra
Local lTouch		:= If( LJGetStation("TIPTELA") == "2", .T., .F. )		// Se trabalha com Touch Screen
Local nDecimais  	:= MsDecimais(nMoedaCor)								// Decimais
Local nItem 		:= 0													// Item 
Local cCliCGC		:= ""													// CGC do cliente
Local lFRTCancelat  := ExistTemplate("FRTCancela")							// verifica se existe o PONTO DE ENTRADA FRTCancela
Local lReserva		:= .F.													// Se trabalha com reserva
Local lImport       := .F.													// Se trabalha com importacao de orcamento
Local cSupervisor	:= Space(15)											// Superior de usuario
Local nTA1TIPO		:= TamSX3("A1_TIPO")[1]									// Tamanho do campo A1_TIPO
Local cProdLocal   	:= ""													// Armazena o codigo de barras ou codigo do produto
Local nX			:= 0													// Contador 
Local lTemImpressao	:= .F.													// Verifica se tem algum item na venda que nao seja pedido
Local aKey			:= {}													// Array Utilizado para a funcao SetKey
Local cNumCup		:= ""													// Numero do cupom no ECF
Local lImpIncl      := .T.                                                  // Verfica se existe valor incluido no item
Local lTefDiscado	:= .F.
Local lCancCupDis	:= .F.
Local lLjNfPafEcf	:= LjNfPafEcf(SM0->M0_CGC)								// Verifica se ้ paf-ecf
Local lVendaTEF		:= .F.													// Verifica se foi utilizado tef na venda.


/*Release 11.5 - Cartao Fidelidade*/ 
Local lLjcFid	 	:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()			// Indica se a recarga de cartao fidelidade esta ativa				

/*Release 11.5 - Controle de Formularios
Paises:Chile/Colombia - F1CHI*/
Local lCFolLocR5	:=	SuperGetMv("MV_CTRLFOL",,.F.) .AND. cPaisLoc$"CHI|COL" .AND. !lFiscal

Local nVlrFSD 		:= 0 //Valor de Frete + Seguro + Despesa
Local lPergFecha	:= .T. //Pergunta se o cupom fiscal foi fechado com sucesso
Local aAreaSL1 	:= {} //Area referente ao orcamento atual SL1
Local aAreaSL2 	:= {} //Area referente ao orcamento atual SL2
Local aAreaSL4 	:= {} //Area referente ao orcamento atual SL4
Local aCpAreaSL1 	:= {} //Area referente ao orcamento novo que foi feita uma copia SL1
Local aCpAreaSL2 	:= {} //Area referente ao orcamento novo que foi feita uma copia SL2
Local aCpAreaSL4 	:= {} //Area referente ao orcamento novo que foi feita uma copia SL4
Local cNFisCanc		:= ""
Local cMsgSLI		:= ""
Local lRecovery	:= .F. // Referente a recuperacao de venda de SAT
Local lVPNewRegra 	:= ExistFunc("Lj7VPNew") .And. Lj7VPNew()  //Nova regra de vale-presente
Local lL2VALEPRE := SL2->(ColumnPos("L2_VALEPRE") > 0)
Local lFinaCanc		:= .F.
Local lEstTef		:= .F.
Local nRecSL1Sat	:= 0
Local cMVLJTEFPD    := IIf(FindFunction("LjTEFPend"),LjTEFPend(1), Substr(AllTrim(SuperGetMV("MV_LJTEFPD",,"1")),1,1) )

DEFAULT cTipoCli 	:= ""
DEFAULT oHora		:= NIL
DEFAULT cHora		:= ""
DEFAULT oDoc		:= NIL
DEFAULT cDoc		:= ""
DEFAULT aPgtos		:= {}
DEFAULT cCupom		:= "" 
DEFAULT lAbreCup	:= .F.
DEFAULT lResume		:= .F.               
DEFAULT cMensagem	:= ""            

While nRet <> 0
	nRet := IFPegCupom( nHdlECF,@cDoc )
	If nRet <> 0
		HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Opera็ใo nใo efetuada.", "Aten็ใo"
	Else
		cOrcam := CriaVar("L1_NUM")
	Endif
End

If lEmitnfce .And. ExistFunc("Fr271aVlDt") .And. !Fr271aVlDt(.T.)
	MsgAlert(STR0366 + CRLF + STR0367)  // "A Data do dia ้ diferente da data do movimento" ... "Favor inicializar o sistema para atualizar com data atual."
	lExitNow := .T.
	Return Nil	
EndIf

lResume := .F.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Detectar Registros Nao Finalizados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SL1")
//Tratativa para posicionar no ultimo registro da tabela SL1
SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
SL1->(DbSeek(xFilial("SL1")+PadR("Z",TamSX3("L1_NUM")[1]), .T.))
SL1->(DbSkip(-1))
If !SL1->(EOF()) .AND. SL1->L1_SITUA >= "01" .AND. SL1->L1_SITUA <= "99"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRelease 11.5 - Controle de Formularios              ณ
	//ณQuando o ECF nao estiver em uso,caso				   ณ
	//ณa venda nao tenha sido concluida devida a algum erroณ
	//ณos registros da SL1,SL2 e SL4 serao excluidos.      ณ
	//ณPaises:Chile/Colombia - F1CHI				       ณ	
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !lCFolLocR5
		lResume := .T.
		
		If cPaisLoc <> "BRA"
			nMoedaCor := SL1->L1_MOEDA
			cMoeda    := AllTrim(SuperGetMV("MV_MOEDA"+Str(nMoedaCor,1)))
			oMoedaCor:Refresh()
			
			nTaxaMoeda := SL1->L1_TXMOEDA
			oTaxaMoeda:Refresh()
	
			cSimbCor := AllTrim(SuperGetMV("MV_SIMB"+Str(nMoedaCor,1)))
			oTemp3:Refresh()
		EndIf
	Else
		//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExcluir SL4ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SL4")   
		DbSetOrder(1)
		If DbSeek(xFilial("SL4")+SL1->L1_NUM)
			While !SL4->(EOF()) .AND. SL4->L4_NUM == SL1->L1_NUM 			
				RecLock("SL4", .F.)
				dbDelete()
				MsUnLock()
				SL4->(DbSkip())	
			End			
	    EndIf	    
	    
	    //ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExcluir SL2ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู
		DbSelectArea("SL2")   
		DbSetOrder(1)
		If DbSeek(xFilial("SL2")+SL1->L1_NUM)
			While !SL2->(EOF()) .AND. SL2->L2_NUM == SL1->L1_NUM 			
				RecLock("SL2", .F.)
				SL2->L2_VENDIDO := "N"	//Sinaliza item cancelado, quando PAF-ECF considera registro deletado na subida da Venda
				dbDelete()
				MsUnLock()
				SL2->(DbSkip())	
			End			
	    EndIf
	    
	    //ฺฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExcluir SL1ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤู	    
    	RecLock("SL1", .F.)
		dbDelete()
		MsUnLock()
	    
	EndIf
EndIf   
IF lResume .AND.;
	SLI->(DbSeek(xFilial("SLI")+PadR(cEstacao,4)+"OPE")) .AND. ;
	! Empty(SLI->LI_MSG) .AND.;
	! (AllTrim(SLI->LI_USUARIO) == AllTrim(cUserName))         
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ	Existe um cupom do caixa:                                                       ณ
	//ณ	para ser recuperado. Acesse o sistema com esse caixa para concluir a operacao   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	MsgInfo(STR0140+AllTrim(SLI->LI_USUARIO)+STR0141)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza o Job FRTA020, Quando For TwoTier ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    FR2712Tier()
ENDIF

If lResume
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Posiciona o cadastro de clientes. Faz isto fora do laco no SL2 para fazer  ณ
	//ณ uma unica vez.                                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty(SL1->L1_CLIENTE+SL1->L1_LOJA)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Define cliente com o padrao do parametro ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
		cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
		nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
		cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
		nTamSXG   := Len(SA3->A3_COD)
		cVendLoja := Left(PadR(SuperGetMV("MV_VENDPAD"),nTamSXG),nTamSXG)				
		cTipoCli := Left(GetAdvFVal("SA1","A1_TIPO",xFilial("SA1")+cCliente+cLojaCli,1,"")+Space(nTA1TIPO),nTA1TIPO)		
	Else
		cCliente := SL1->L1_CLIENTE
		cLojaCli := SL1->L1_LOJA
		cVendLoja := SL1->L1_VEND		
		cTipoCli := If(!Empty(SL1->L1_TIPO),SL1->L1_TIPO,Left(GetAdvFVal("SA1","A1_TIPO",xFilial("SA1")+cCliente+cLojaCli,1,"")+Space(nTA1TIPO),nTA1TIPO))
	Endif
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLojaCli))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de entrada para tratamento do cliente ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lT_FrtResume
		aRetTplResume := ExecTemplate( "FRTRESUME", .F., .F., { cCliente, cLojaCli } )
		If ValType( aRetTplResume ) == "A" .AND. Len( aRetTplResume ) >= 1
			uCliTpl	:= aRetTplResume[1]
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Atualiza a aCrdCliente com as informacoes do cliente para nao ser soli-ณ
			//ณ citada novamente na finalizacao da venda.                              ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aCrdCliente[1] := SA1->A1_CGC
		Endif
	Endif

Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Detectar Troca de ECF ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lResume .AND. L1_PDV <> cPDV

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ"Foi detectada a troca do ECF " ### " pelo ECF " ### ". Os items impressos no outro ECF deverใo ser cancelados. "   ณ
//ณ"Caso deseje reimprimir o cupom clique em OK, caso contrแrio, este cupom serแ cancelado.", "Aten็ใo"                ณ
//ณ	                                                                                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If MsgYesNo(STR0016 + AllTrim(L1_PDV) + STR0017 + AllTrim(cPDV) + STR0018 + STR0019, STR0003)
		nRet := IFStatus(nHdlECF, "8", @cRet)	  			// Verifica Reducao Z
		If nRet == 10

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ	 "Nใo foi feita a Redu็ใo Z neste ECF. O cupom na base de dados serแ cancelado.", "Aten็ใo"    ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			HELP(' ',1,'FRT005')
			FR271BCancela()
			lResume := .F.
		ElseIf nRet == 0
			nRet := IFStatus(nHdlECF, "5", @cRet)				// Verifica Cupom Fechado
			If nRet == 7
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ	// "Existe um cupom em aberto neste ECF. O cupom na base de dados serแ cancelado.", "Aten็ใo"ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
				HELP(" ",1,"FRT003")
				FR271BCancela()
				lResume := .F.
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Finaliza o Job FRTA020, Quando For TwoTier ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			    FR2712Tier()
			    
			ElseIf nRet == 0
				nRet := IFAbreCup(nHdlECF,@cCliCGC)
				lFechaCup := .T.

				If nRet <> 0

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ "Nใo foi possํvel realizar a abertura do cupom. O cupom na base de dados serแ cancelado.", "Aten็ใo"       ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			
			   		HELP(" ",1,"FRT004")
					FR271BCancela()
					lResume := .F.
				Else
					DbSelectArea("SL2")
					DbSetOrder(1)
					DbSeek(xFilial()+SL1->L1_NUM)
					While L2_FILIAL+L2_NUM == xFilial()+SL1->L1_NUM
						SBI->(DbSeek(xFilial("SBI")+SL2->L2_PRODUTO))
						cCodProd := SBI->BI_COD
						cCodBar  := SBI->BI_CODBAR
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ P.E. Para Tratamento dos Dados Que Serao Mostrados na Tela. ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						aAux := {FR271HLastIT(@aItens)+1, cCodProd, cCodBar, "", "", "", "", "", "", "", 0 ,.F.}
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณVerifica se existe a chamado do Ponto de Entradaณ
						//ณcriado pela equipe de Templates                 ณ
						//ณTemplate Drogaria                               ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If lFRTCODB2t
							aAdd(aAux,uProdTPL)
							aAdd(aAux,uCliTPL)
							
							aAux := ExecTemplate( "FRTCODB2", .F., .F., { aAux, uProdTPL, uCliTPL } )
							cCodProd := Padr( aAux[2], nTB1COD )
							cCodBar  := Padr( aAux[3], nTB1CODBAR )
							If ValType( aAux[13] ) == "A"
								uProdTPL := aClone( aAux[13] )
							Else
								uProdTPL := aAux[13]
							Endif
							If ValType( aAux[14] ) == "A"
								uCliTPL  := aClone( aAux[14] )
							Else
								uCliTPL  := aAux[14]
							Endif
						EndIf
						
						If ExistBlock("FRTCODB2")
							aAux := ExecBlock("FRTCODB2",.F.,.F.,aAux)
							cCodProd := Padr(aAux[2],nTB1COD)
							cCodBar  := Padr(aAux[3],nTB1CODBAR)
						EndIf

						If (cPaisLoc <> "BRA") .AND. ((L2_VLRITEM < L2_PRCTAB) .OR. (L2_VLRITEM > L2_PRCTAB))

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณRealiza o acerto do Arquivo SL2 caso a venda possua descontoณ
							//ณno total ou acrescimo...		                               ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							
							nVlrItem := ((L2_PRCTAB*L2_QUANT)-L2_VALDESC)
							nDescUni := Round(L2_VALDESC/L2_QUANT,nDecimais)
											
							aSL2 := {	{"L2_DESCPRO",	0},;
							         	{"L2_VLRITEM", nVlrItem},;
							         	{"L2_VRUNIT" , nVlrItem/L2_QUANT}}
							         	
							FR271BGeraSL("SL2", aSL2, .F.)
						EndIf

						MaFisIni(	cCliente,	cLojaCli,	"C"	,	"S",;
									cTipoCli,	NIL		,	NIL	,	.F.,;
									"SBI"	,	NIL		,	"01",	NIL,;
									NIL		,	NIL		,	NIL	,	NIL,;
									NIL		,	NIL		,	.F.	)
						
						MaFisAdd(	cCodProd									,;
							 		L2_TES										,;
							 		L2_QUANT									,;
							 		L2_VRUNIT+If(cPaisLoc<>"BRA",nDescUni,0)	,;
							 		L2_VALDESC									,;
							 		""											,;
							 		""											,;
							 													,; 
							 		0											,; 
							 		0											,; 
							 		0											,; 
							 		0											,; 
							 		L2_VLRITEM+If(cPaisLoc<>"BRA",L2_VALDESC,0)	,;
							 		0)
						
						SF4->(DbSeek(xFilial("SF4")+MaFisRet(1,"IT_TES")))
						nDedIcmsIt  := 0
						
						If cPaisLoc == "BRA"
							If SF4->F4_ISS == "S"
								cAliquota := "S" + Str(MaFisRet(1,"IT_ALIQISS"),5,2)
							Else
								If (SBI->BI_PICMRET > 0 .OR. SBI->BI_PICMENT > 0) .AND. cTipoCli $ SuperGetMV("MV_TPSOLCF") .AND. SF4->F4_BSICMST <> 100
									cAliquota := "F"
								ElseIf SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100
									cAliquota := "T" + Str(SBI->BI_ALIQRED,5,2)
								Elseif SF4->F4_LFICM == "I"
									cAliquota := "I"					// Isento
									If SF4->F4_AGREG == "D"            // Deducao de ICMS  
									   nDedIcmsIt  := MaFisRet(1,"IT_DEDICM")
									   nTotDedIcms += nDedIcmsIt																		
									Endif   
								Elseif SF4->F4_LFICM == "N"
									cAliquota := "N"					// No sujeito a ICMS
								Else
									cAliquota := "T" + Str(MaFisRet(1,"IT_ALIQICM"),5,2)
								Endif
							Endif
							nVlrMerc  += (SL2->L2_PRCTAB * SL2->L2_QUANT) // Acumula o valor de mercadorias
						Else
							nTotImp  := 0
					 	    aImps    := TesImpInf(MaFisRet(1,"IT_TES"))
						    Aadd(aImpsSL2,{cCodProd,MaFisRet(1,"IT_TES"),{}})
						    For nI := 1 to Len(aImps)                                                 
						    	If (nE := Ascan( aImpsSL1,{|x| x[1] == aImps[nI,1]})) == 0
						        	AAdd(aImpsSL1,{aImps[nI][1],"L1_"+Substr(aImps[nI][6],4,7),0,"L1_"+Substr(aImps[nI][8],4,7),0,aImps[nI][3],aImps[nI][9]})		    		    
						     		nE := Len(aImpsSL1)
						       	EndIf   
						       	cIndImp  := Substr(aImps[nI][2],10,1)               
						       	cCampoVal:= "IT_VALIV"+cIndImp		    
						       	cCampoAlq:= "IT_ALIQIV"+cIndImp	 
						       	nValImp  := Round(MaFisRet(1,cCampoVal),nDecimais)
							   	FR271HGeraImp(@aImposto,aImps[nI],nValImp,L2_QUANT,L2_VRUNIT,1,cIndImp,nDecimais)
							   	AAdd(aImpsSL2[Len(aImpsSL2)][3],aClone(aImposto))
							   	nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
							   	aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
							   	aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   
						    Next nI
           					AAdd(aImpsSL2[Len(aImpsSL2)],L2_ITEM)				
           					AAdd(aImpsSL2[Len(aImpsSL2)],.F.)				   	           					      
           					AAdd(aImpsSL2[Len(aImpsSL2)],L2_QUANT)				
           					AAdd(aImpsSL2[Len(aImpsSL2)],L2_VRUNIT)				   	           					                 					
   							nVlrMerc  += (L2_VRUNIT * L2_QUANT)
				            nVlrItem  := ((L2_VRUNIT * L2_QUANT)+nTotImp)
						    cAliquota := " " + IIf(Len(aImps) > 0,Str(MaFisRet(1,cCampoAlq),5,2),"")
							
							FR271ITotVen(	@nVlrTotal	, @nMoedaCor	, @nTaxaMoeda	, @aTotVen,	;
										@aMoeda)
							
							FR271ISimACols(	cCodProd	, L2_QUANT	, L2_VRUNIT	, L2_TES	,;
											L2_CF		, L2_ITEM	, Nil		, @aCols	,;
							 				@aHeader)
							AAdd(aImpsProd,aClone(aImpsSL2[Len(aImpsSL2)]))
						Endif   
						MaFisEnd()

						nDec := TamSX3("L2_QUANT")[2]
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ P.E. Para Tratamento dos Dados Que Serao Impressos no Cupom. ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If cPaisLoc == "BRA"
							aAux := {cCodProd, cCodBar, SBI->BI_DESC, L2_QUANT, L2_VRUNIT, L2_VALDESC, cAliquota, nVlrItem + L2_VALDESC, .F., "", 0, SBI->BI_UM}
						Else
							aAux := {cCodProd, cCodBar, SBI->BI_DESC, L2_QUANT, L2_VRUNIT, L2_VALDESC, cAliquota, nVlrItem , .F., "", 0, SBI->BI_UM}
						EndIf   
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณVerifica se existe a chamado do Ponto de Entradaณ
						//ณcriado pela equipe de Templates                 ณ
						//ณTemplate Drogaria                               ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If lFRTCODB3t
							If cPaisLoc == "BRA"
								aAux := {cCodProd, cCodBar, SBI->BI_DESC, L2_QUANT, L2_VRUNIT, L2_VALDESC, cAliquota, nVlrItem + L2_VALDESC, .F., "", 0, SBI->BI_UM,uProdTPL,uCliTPL}
							Else
								aAux := {cCodProd, cCodBar, SBI->BI_DESC, L2_QUANT, L2_VRUNIT, L2_VALDESC, cAliquota, nVlrItem , .F., "", 0, SBI->BI_UM,uProdTPL,uCliTPL}
							EndIf							
							aAux := ExecTemplate("FRTCODB3",.F.,.F.,{aAux,uProdTPL,uCliTPL})
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณvalorizando variaveis do tipo STATICณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู							
							If ValType( aAux[13] ) == "A"
								uProdTPL := aClone(aAux[13])
							Else
								uProdTPL := aAux[13]
							Endif
							
							If ValType( aAux[14] ) == "A"
								uCliTPL  := aClone(aAux[14])
							Else
								uCliTPL  := aAux[14]
							Endif
							
						EndIf
						
						If ExistBlock("FRTCODB3")
							aAux := ExecBlock("FRTCODB3",.F.,.F.,aAux)
						EndIf
						
						If LjAnalisaLeg(39)[1]
							nRet := IFRegItem(nHdlECF, If(LjAnalisaLeg(9)[1],Right('0000000000000'+Alltrim(aAux[2]),13),aAux[1]), aAux[3], AllTrim(Str(aAux[4],8,nDec)), AllTrim(Str(aAux[5],14,TamSX3("BI_PRV")[2])),;
											  AllTrim(Str(aAux[6],14,2)), aAux[7],AllTrim(Str(aAux[8],14,2)), aAux[12])
						Else							      
							nRet := IFRegItem(nHdlECF, If(LjAnalisaLeg(9)[1],Right('0000000000000'+Alltrim(aAux[1]),13),aAux[1]), aAux[3], AllTrim(Str(aAux[4],8,nDec)), AllTrim(Str(aAux[5],14,TamSX3("BI_PRV")[2])),;
											  AllTrim(Str(aAux[6],14,2)), aAux[7],AllTrim(Str(aAux[8],14,2)), aAux[12])
						EndIf
											  
						If nRet <> 0

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณ "Nใo foi possํvel reimprimir o cupom. O cupom na base de dados serแ cancelado.", "Aten็ใo"ณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							
							HELP(' ',1,'FRT006')
							FR271BCancela()
							lResume := .F.
        				EndIf
						DbSkip()
					End
					cCodProd := Space(nTB1COD)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Atualizando o SL1 ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					aSL1 := {	{	"L1_EMISSAO", 	dDataBase				}, ;
							 	{	"L1_DTLIM"	,	dDataBase				}, ;
							 	{	"L1_EMISNF"	,	dDataBase				}, ;
							 	{	"L1_DOC"	,	cDoc					}, ;
							 	{	"L1_NUMCFIS",	cDoc					}, ;
							 	{	"L1_SERIE"	,	LJGetStation("SERIE")	}, ;
							 	{	"L1_PDV"	,	cPDV					}, ;
							 	{	"L1_OPERADO",	xNumCaixa()				}, ;
							 	{	"L1_VEND"	,	cVendLoja				}, ;							 	
							 	{	"L1_HORA"	,	cHora					} }

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณAtualiza o campo L1_CGCCLI caso trabalhe com ณ
					//ณNota Fiscal Paulista                         ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู				
					If LjAnalisaLeg(30)[1]
						If SL1->(FieldPos("L1_CGCCLI")) > 0					
							Aadd(aSL1,{ "L1_CGCCLI" , cCliCGC } ) 
							cCliCGC	:= ""											// Caso abriu o cupom limpa a varivavel de CGC 								
						EndIf
	    			EndIf

					FR271BGeraSL("SL1", aSL1, .F.)
					DbSeek(xFilial()+SL1->L1_NUM)
					While SL2->L2_FILIAL+SL2->L2_NUM == xFilial()+SL1->L1_NUM .AND. !EOF()
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Atualizando o SL2 ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						aSL2 := {	{	"L2_DOC"	, SL1->L1_DOC     }, ;
									{	"L2_SERIE"	, SL1->L1_SERIE   }, ;
								 	{	"L2_PDV"	, SL1->L1_PDV     }, ;
								 	{	"L2_EMISSAO", SL1->L1_EMISSAO } }
						FR271BGeraSL("SL2", aSL2, .F.)
						DbSkip()
					End
				EndIf
			EndIf
		EndIf
 	Else
		FR271BCancela()
		lResume := .F.
	EndIf
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ verifica se possui um ou todos itens com Reserva  			ณ
//ณ  lReserva 	= .T. Possui algum item pedido 					ณ
//ณ  lImpressao = .T. Possui algum item normal que foi impresso ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lResume
	lReserva := FR271HRES( @lTemImpressao)
EndIf

lTefDiscado := lUsaTEF .AND. cTipTEF $ TEF_DISCADO .AND. (L010IsDirecao(L010GetGPAtivo()) .OR. L010IsPayGo(L010GetGPAtivo()))

/* 
	Detectar Cupom Aberto 
*/
If lResume .And. !lEmitNfce
	LJProfile(8,@cSupervisor)
	If lTemImpressao
		nRet := IFStatus(nHdlECF, "5", @cRet)				// Verifica Cupom Fechado
		If nRet <> 7
			If SL1->L1_SITUA <> "10"
				If !lLjNfPafEcf
					// "O ECF nใo estแ com o cupom aberto. Este cupom serแ cancelado.", "Aten็ใo"
					HELP(' ',1,'FRT007')
				EndIf
				
				nRet := IFPegCupom( nHdlECF,@cNumCup ) 			//Busca o COO da impressora para verificar se e possivel efetuar o cancelamento
				If nRet == 0
					If ExistFunc("LjDEstVinc") .And. !Empty(SL1->L1_DOCTEF)				//Tratamento para cancelar o Comprovante de Credito e Debito
						LjDEstVinc(Alltrim(cNumCup) <> Alltrim(SL1->L1_DOC),@cNumCup)
					EndIf
					
					//Esta fun็ใo permite a gera็ใo da tabela SLX na retaguarda
					LjLogCanc( cSupervisor, Nil, .T., "")

					//Pega os dados do SL1 antes de deleta-lo
					cSliCan := SL1->L1_NUMORIG+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV
					FR271BGerSLI("    ", "CAN", cSliCan, "NOVO")		// Envia Para o Server Caso Tenha Sido Baixado						
					
					If lTefDiscado
						lCancCupDis := .T.
					Else
						FR271BCancela()
						If lLjNfPafEcf
							LJGrvGT( "SIGALOJA.VLD" ) //Atualiza o GT quando a um cupom cancelado
						EndIf
					EndIf
				EndIf

				/* Inicializa o Cliente e a Loja conforme o parametro */
				Frt271IniCli( @cCliente, @cLojaCli)
				lResume := .F.
			EndIf

		ElseIf lUsaTef .AND. cTipTEF == TEF_CLISITEF
			If oTef:lTemPbm
				IFCancCup(nHdlECF)
				FRTCancela()
				lResume := .F.
			EndIf
		Else
			// Indica que existe um cupom aberto 
			lAbreCup := .T.	
		EndIf

		If lTefDiscado
			lResume := .F.
			FR271BCancela()
			lOcioso := .T.

			If lLjNfPafEcf		
				LJGrvGT( "SIGALOJA.VLD" ) //Atualiza o GT quando a um cupom cancelado
			EndIf
			
			If lAbreCup .Or. lCancCupDis      
				IFCancCup(0)
				lAbreCup := .F.
				lTemImpressao := .F.				
			EndIf
		EndIf
	EndIf	
EndIf

/* Caso a venda contenha itens de reserva Cancela a venda  */
If lResume .AND. (!lEmitNfce .OR. lUseSAT)
	If lReserva
		// "O Sistema irแ finalizar o Cupom, pois existe item de reserva.", "Aten็ใo"
		MsgStop(STR0329,STR0003)
	Else
		// Cancelamento de cupom caso o orcamento tenha sido importado da retaguarda via CTRL-Z.
		lImport := !Empty(SL1->L1_NUMORIG)
		If lImport
			// "O Sistema irแ finalizar o cupom."
			MsgStop(STR0331, STR0003)
		Endif
	Endif

	If lReserva .OR. lImport
		lResume := .F.
		cLiMsg  := SL1->L1_NUMORIG+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV
		If !lEmitNfce
			nRet := IFStatus(nHdlECF, "9", @cRet)			// Verifico o Status do ECF
			If nRet <> 0
				HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Opera็ใo nใo efetuada.", "Aten็ใo"
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Restaura os SetKey's do Fechamento da Venda ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				FRTSetKey(aKey)
				Return(lRet)
			EndIf
		EndIf
		
		aSL1 := {{"L1_SITUA",	"07"}}				// "07" - Solicitado o Cancelamento do Cupom
		FR271BGeraSL("SL1", aSL1)
		If lTemImpressao 
			nRet := IFCancCup(nHdlECF, cSupervisor)
		EndIf	

		If nRet == 0
			lFechaCup := .T.
			lAbreCup := .F.
		EndIf

		If nRet == 0 
			FR271BCancela()
			IFPegPDV(nHdlECF, @cPDV)
			lOcioso := .T.
			oCupom:AppendText(chr(13) + chr(10))
			oCupom:AppendText(chr(13) + chr(10))
			oCupom:AppendText(STR0330 + chr(10) + chr(13)) // "         CUPOM FISCAL CANCELADO         "
			oCupom:AppendText(chr(13) + chr(10))
			oCupom:AppendText(chr(13) + chr(10))
			oCupom:AppendText((DToC(dDatabase)+" "+Time()+STR0030+PadR(cPDV,4)+STR0031+cDoc)) // "  PDV:" "   COD:"
			oCupom:AppendText(chr(13) + chr(10))
			oCupom:AppendText(("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))			
			oCupom:GoEnd()

			aPgtos	:= {}
			lOcioso	:= .T.
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Zera o valor e o percentual de desconto do item       ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nVlrPercIT 	:= 0
			nTotItens 	:= 0
			nVlrTotal 	:= 0
			nVlrBruto 	:= 0
			nVlrMerc  	:= 0
			nTotDedIcms := 0

			Frt060End()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Inicializa o Cliente e a Loja conforme o parametro ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
			Frt271IniCli( @cCliente, @cLojaCli)

			If !lTouch					
				oDesconto:Refresh()
				oTotItens:Refresh()
				oVlrTotal:Refresh()
			Endif	

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Reinicializa as variแveis de Templates                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			uCliTPL := NIL     
			uProdTPL:= NIL

			FR271AInitIT(	.T.		 , 	.F.		 ,	@cCodProd ,	@cProduto,;
							NIL	     ,	@nQuant	 ,	@cUnidade ,	@nVlrUnit,;	
							@nVlrItem,	@oProduto,	@oQuant	  ,	@oUnidade,;	
							@oVlrUnit,	@oVlrItem,	@oDesconto,	@cCliente,;
							@cLojaCli)
			
			FR271Hora(	.T.	 ,	NIL	 , @oHora, @cHora,;
						@oDoc,	@cDoc )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ P.E. Apos o Cancelamento        ณ
			//ณ Tipo      : 1 - Item            ณ
			//ณ             2 - Cupom           ณ
			//ณ Supervisor: Senha que autorizou ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lFRTCancelat .And. (Len(aItens) > 0 .And. Len(aItens[nI]) > 0 )
				uProdTPL := ExecTemplate("FRTCancela",.F.,.F.,{1,cSupervisor,aItens[nI][AIT_ITEM],uProdTPL})
			EndIf
			If ExistBlock("FRTCancela")
				ExecBlock("FRTCancela",.F.,.F.,{1,cSupervisor})
			EndIf
		Else
			HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Opera็ใo nใo efetuada.", "Aten็ใo"
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Restaura os SetKey's do Fechamento da Venda ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			FRTSetKey(aKey)
		EndIf
	EndIf
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verificar a Situacao do Cupom ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lResume
	If SL1->L1_SITUA == "01"								// "01" - Abertura do Cupom Nao Impressa
		nRet := IFStatus(nHdlECF, "5", @cRet)				// Verifica Cupom Fechado
		If nRet <> 7
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Cancelar a Abertura do Cupom ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			FR271BCancela(.T., .F., .F.)					// Deleta Somente o SL1
			lResume := .F.
		EndIf
		
	ElseIf SL1->L1_SITUA == "03"							// "03" - Item nao Impresso
		lVendaTEF :=  lUsaTef .AND. cTipTEF == TEF_CLISITEF .And. ((!Empty(SL1->L1_HORATEF) .And. !Empty(SL1->L1_AUTORIZ)) .Or. !Empty(SLG->LG_LOGTEF)) 
		
		LjGrvLog("LOGTEF PDV","Valor do campo SLG->LG_LOGTEF :" , SLG->LG_LOGTEF )
		LjGrvLog("LOGTEF PDV","Valor da variavel cMVLJTEFPD :" , cMVLJTEFPD )
		LjGrvLog("LOGTEF PDV","Valor da variavel lEmitNfce :"  , lEmitNfce )
		
		If lEmitNfce .And. !lUseSAT .and. lVendaTEF .And. cMVLJTEFPD == "4" 
			// caso existir venda com TEF envio o cancelamento da transa็ใo
			LjGrvLog("LOGTEF PDV","Vai executar o cancelamento da transacao" + cMVLJTEFPD )
			F271TefPd(0 , .T. )
		EndIf 	
		
	ElseIf SL1->L1_SITUA == "04"							// "04" - Impressao do item
		If cPaisLoc <> "BRA"
			If Empty(cDoc) .OR. cDoc == Replicate("0", TamSX3("L1_DOC")[1])
				cDoc := SL1->L1_DOC							// Pega numero do cupom em aberto
			EndIf
		EndIf
		lVendaTEF :=  lUsaTef .AND. cTipTEF == TEF_CLISITEF .And. ((!Empty(SL1->L1_HORATEF) .And. !Empty(SL1->L1_AUTORIZ)) .Or. !Empty(SLG->LG_LOGTEF)) 
		
		LjGrvLog("LOGTEF PDV","Valor do campo SLG->LG_LOGTEF :" , SLG->LG_LOGTEF )
		LjGrvLog("LOGTEF PDV","Valor da variavel cMVLJTEFPD :" , cMVLJTEFPD )
		LjGrvLog("LOGTEF PDV","Valor da variavel lEmitNfce :"  , lEmitNfce )
		
		If lEmitNfce .And. !lUseSAT .and. lVendaTEF .And. cMVLJTEFPD == "4" .And. cPaisLoc == "BRA"
			// caso existir venda com TEF envio o cancelamento da transa็ใo
			LjGrvLog("LOGTEF PDV","Vai executar o cancelamento da transacao" + cMVLJTEFPD )
			F271TefPd(0 , .T. )
		EndIf
		
		If lReserva
			// "O Sistema irแ finalizar o Cupom, pois existe item de reserva.", "Aten็ใo"
			MsgStop(STR0329,STR0003)
			lPergFecha := .F.
			lResume := .F. //sinaliza para nao restaurar a venda.
			FR271BCancela()				
		EndIf 
		
	ElseIf SL1->L1_SITUA == "07"							// "07" - Solicitado o Cancelamento do Cupom
		// "Foi solicitado o Cancelamento do Cupom Fiscal. Ele foi realmente cancelado?", "Aten็ใo"
		If MsgYesNo(STR0025, STR0003)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณPega os dados do SL1 antes de deleta-lo ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			cLiMsg := SL1->L1_NUMORIG+"|"+SL1->L1_DOC+"|"+SL1->L1_PDV
			FR271BCancela()
			FR271BGerSLI("    ", "CAN", cLiMsg, "NOVO")		// Envia Para o Server Caso Tenha Sido Baixado
			lResume := .F.
		Else												// Volta ao normal
			FR271BCancela(.F., .F., .T.)						// Deleta Somente o SL4
			aSL1 := {{"L1_SITUA",	"04"}}					// "04" - Impresso o Item
			FR271BGeraSL("SL1", aSL1)
			lResume := .T.
		EndIf
	ElseIf SL1->L1_SITUA == "09"							// "09" - Encerrado SL1 (Nao gerado SL4)
		FR271HRollB04()
		lResume := .T.
	ElseIf SL1->L1_SITUA == "10"							// "10" - Encerrado a Venda
		
		If lEmitNfce
			//Se ainda nao tem o numero do DOCUMENTO definido, entao seta para nao perguntar se a venda foi finalizada,
			//pois obrigatoriamente deve recuperar a venda para tentar finaliza-la novamente.
			If Upper(AllTrim(SL1->L1_DOC)) == "NFCE"
				lPergFecha := .F.
				MsgAlert(STR0356) //"A venda foi recuperada."
			//Se for NFC-e e existir DOC e Serie usada, porem sem a Chave ainda, entao seta para nao perguntar se a venda foi finalizada,
			//pois ira mandar o Documento para Inutilizacao para poder finalizar a venda Recuperada novamente com um novo numero de NFC-e.
			ElseIf Empty(SL1->L1_KEYNFCE) .And. !Empty(SL1->L1_SERIE) .And.  !Empty(SL1->L1_DOC)
				lPergFecha := .F.

			ElseIf lReserva
				// "O Sistema irแ finalizar o Cupom, pois existe item de reserva.", "Aten็ใo"
				MsgStop(STR0329,STR0003)
				lPergFecha := .F.
				lResume := .F. //sinaliza para nao restaurar a venda.
				FR271BCancela()				
			ElseIf lUseSAT .And. Empty(SL1->L1_DOC)
				lPergFecha := .F.
				MsgAlert(STR0356) //"A venda foi recuperada."
			EndIf

			If lUseSAT
				MH2->(DBSetOrder(3)) //MH2_FILIAL + MH2_SERIE + MH2_DOC
				If MH2->(DBSeek(xFilial("MH2")+SL1->(L1_SERIE+L1_DOC)))
					lRecovery := .F.
				Else
					lRecovery := .T.  //sinaliza que SAT executara processo de recuperacao no comando de abertura
				EndIf
			EndIf
		EndIf

		// "Foi solicitado o Fechamento do Cupom Fiscal. Ele foi realmente finalizado?", "Aten็ใo"
		If lPergFecha
			aSL1 := {{"L1_SITUA", "00"},{"L1_NUMCFIS",SL1->L1_DOC}} // "00" - Venda Efetuada com Sucesso
			FR271BGeraSL("SL1", aSL1)
			
			//Se trata-se de uma venda com TEF			
			lVendaTEF :=  lUsaTef .AND. cTipTEF == TEF_CLISITEF .And. ((!Empty(SL1->L1_HORATEF) .And. !Empty(SL1->L1_AUTORIZ)) .Or. !Empty(SLG->LG_LOGTEF))
			
			LjGrvLog("LOGTEF PDV","Valor do campo SLG->LG_LOGTEF :" , SLG->LG_LOGTEF )
			LjGrvLog("LOGTEF PDV","Valor da variavel cMVLJTEFPD :" , cMVLJTEFPD )
			LjGrvLog("LOGTEF PDV","Valor da variavel lVendaTEF :"  , lVendaTEF )
			
			
			//Caso esteja configurado como 4 Confirmamos a transa็ใo Pendente pois finalizamos o or็amento com Nfc-e
			If cMVLJTEFPD == "4" .And. lVendaTEF
				LjGrvLog("LOGTEF PDV","Vai executar a confirma็ใo da transacao. " )
				F271TefPd(1 , .T. )
			EndIf

			Msginfo( STR0349 + If(!Empty(AllTrim(SL1->L1_DOC)),STR0350 + AllTrim(SL1->L1_DOC) + "'","") + STR0351 +; //#"Venda" ##" com nบ de documento '" ###" recuperada e finalizada com sucesso!"
					 If(lVendaTEF, CHR(13)+CHR(10) + STR0352,"") )//"Caso necessแrio, favor reimprimir o ๚ltimo comprovante TEF atrav้s da op็ใo do menu 'Rotinas TEF'."

			LjAjustaNcc(.T.) //Verifica se foi pago com NCC para que ela seja baixada posteriomente.

			If lUseSAT .And. MsgYesNo(STR0353, STR0003) //#"Deseja reimprimir documento desta ๚ltima venda?" ##"Aten็ใo"
				LJSatReImp()
			EndIf

			lResume := .F. //sinaliza para nao restaurar a venda.

		Else
						
			//Se trata-se de uma venda com TEF			
			lVendaTEF :=  lUsaTef .AND. cTipTEF == TEF_CLISITEF .And. ((!Empty(SL1->L1_HORATEF) .And. !Empty(SL1->L1_AUTORIZ)) .Or. !Empty(SLG->LG_LOGTEF))
			
			LjGrvLog("LOGTEF PDV","Valor do campo SLG->LG_LOGTEF :" , SLG->LG_LOGTEF )
			LjGrvLog("LOGTEF PDV"," Valor do parametro cMVLJTEFPD: " + cMVLJTEFPD )
			LjGrvLog("LOGTEF PDV"," Valor da variavel lVendaTEF: " , lVendaTEF )
						
			//Caso esteja configurado como 4 cancelamos a transa็ใo Pendente pois finalizamos o or็amento com Nfc-e
			If cMVLJTEFPD == "4" .And. lVendaTEF
				LjGrvLog("LOGTEF PDV","Vai executar o cancelamento da transacao cMVLJTEFPD: " + cMVLJTEFPD )
				F271TefPd(0 , .T. )
			EndIf
				
			LjAjustaNcc(.F.) //Faz a limpeza da tabela MDJ - baixa da ncc 

			If lEmitNfce .And. !lUseSAT
				//Se for NFC-e e existir DOC e Serie usada, entao manda o Documento para Inutilizacao 
				//para poder finalizar a venda novamente com um novo numero de NFC-e.
				If Upper(AllTrim(SL1->L1_DOC)) != "NFCE" .And. !Empty(SL1->L1_SERIE) .And. !Empty(SL1->L1_DOC)
					If ExistFunc("F271GInuti")
						MsgAlert("A NFC-e de n๚mero " + SL1->L1_DOC + " s้rie " + SL1->L1_SERIE +;
						 " desta venda recuperada, serแ inutilizada." + chr(13) + chr(13) +;
						 "Ao tentar finalizar essa venda novamente, serแ utilizado um novo n๚mero de NFC-e.")
						
						//Envia o DOCUMENTO para Inutilizacao
						F271GInuti()
					EndIf
				EndIf
			EndIf
			If lResume

				If lUseSAT .And. lRecovery
					//Guarda posi็ใo do or็amento original
					aAreaSL1 	:= SL1->(GetArea())
					aAreaSL2 	:= SL2->(GetArea())
					aAreaSL4 	:= SL4->(GetArea())

					FrtDblOrc() //copia or็amento

					//Guarda posi็ใo do or็amento novo (c๓pia)
					aCpAreaSL1	:= SL1->(GetArea())
					aCpAreaSL2	:= SL2->(GetArea())
					aCpAreaSL4	:= SL4->(GetArea())

					//Retorna posi็ใo do or็amento original			
					RestArea(aAreaSL4)
					RestArea(aAreaSL2)
					RestArea(aAreaSL1)

					LJSatUltimo(lRecovery)

					//Se o DOC estแ em branco eh pq nao teve cupom SAT para ser cancelado, pois o sistema deve ter caido antes de efetuar a transmissao do SAT.
					If Empty(SL1->L1_DOC)
						//Neste caso, faz a dele็ใo do orcamento anterior, pois foi feita a sua c๓pia para recupera็ใo da venda
						FR271BCancela()
					Endif

					//Retorna posi็ใo do or็amento novo (c๓pia)
					RestArea(aCpAreaSL4)
					RestArea(aCpAreaSL2)
					RestArea(aCpAreaSL1)

				EndIf

				FR271HRollB04()
				lResume := .T.
			EndIf

		EndIf
	EndIf
	If lResume
		lOcioso := .F.											// Abriu um Cupom

		aCupom := {	"",	"", "", "", "", ;
					"", "", "", "", "", ;
					"",	"",	"",	"",	"", ;
					"",	"",	""	}

		If ExistBlock("FRTCLICHE")
			aFRTCliche := ExecBlock("FRTCLICHE", .F., .F.)
            For nX := 1 To Len(aFRTCliche)
            	oCupom:AppendText(aFRTCliche[nX])
            Next nX		
		Else
			oCupom:AppendText( "" + chr(10) + chr(13))  
			oCupom:AppendText( STR0027 + chr(10) + chr(13)) // "        MICROSIGA SOFTWARE S.A.         "
			oCupom:AppendText( STR0028 + chr(10) + chr(13)) // "    Av. Braz Leme, 1399 - Sใo Paulo     "
			oCupom:AppendText( STR0029 + chr(10) + chr(13)) // "          www.microsiga.com.br          "
		EndIf  
		
		If lResume .AND. cPaisLoc == "MEX"
			oCupom:AppendText( DToC(dDatabase)+" "+Time()+STR0030+PadR(cPDV,4)+STR0031+StrZero(Val(cDoc)-1,TamSX3("L1_DOC")[1])+ chr(10) + chr(13)) // "  PDV:" "   COD:"
		Else
			oCupom:AppendText( DToC(dDatabase)+" "+Time()+STR0030+PadR(cPDV,4)+STR0031+cDoc+ chr(10) + chr(13)) // "  PDV:" "   COD:"
		EndIf  
		
		oCupom:AppendText( FRT_SEPARATOR + chr(10) + chr(13))    
		oCupom:AppendText( PADC(STR0032,40) + chr(10) + chr(13)) 												// "        C U P O M   F I S C A L         "
		oCupom:AppendText( "" + chr(10) + chr(13))                 
		oCupom:AppendText( STR0033 + chr(10) + chr(13)) 														// "ITEM   CำDIGO           DESCRIวใO       "
		oCupom:AppendText( STR0034  + "("+cSimbCor+")"  + chr(10) + chr(13)) 									// "      QTDxUNITARIO    ST     VALOR( SIMBOLO ) "
		oCupom:AppendText( FRT_SEPARATOR + chr(10) + chr(13)) 

		aItens := {}
		cOrcam := SL1->L1_NUM

		If SL1->L1_SITUA == "01"								// "01" - Abertura do Cupom Nao Impressa
			aSL1 := { 	{"L1_NUMCFIS"	,	cDoc }, ;
						{"L1_DOC"		, 	cDoc }, ;
					 	{"L1_SITUA"	,	"02" } }			// "02" - Impresso a Abertura do Cupom
			FR271BGeraSL("SL1", aSL1)
		EndIf

		SBI->(DbSetOrder(1))
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))	
		SL2->(DbSeek(xFilial("SL2")+cOrcam))
		While SL2->(L2_FILIAL+L2_NUM) == xFilial("SL2")+cOrcam
			If SL2->L2_SITUA == "03"							// "03" - Item Nao Impresso
				// "Foi solicitado a impressใo do item " ### ". Ele foi realmente impresso?", "Aten็ใo"
				If MsgYesNo(STR0035+StrZero(FR271BPegaIT(SL2->L2_ITEM),3,0)+STR0036, STR0003)
					aSL2 := {{"L2_SITUA",	"04"}}				// "04" - Impresso o Item
					FR271BGeraSL("SL2", aSL2)
					aSL1 := {{"L1_SITUA",	"04"}}				// "04" - Impresso o Item
					FR271BGeraSL("SL1", aSL1)
				Else
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Cancelar o Item ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					DbSelectArea("SL2")
					RecLock("SL2", .F.)
					SL2->L2_VENDIDO := "N"	//Sinaliza item cancelado, quando PAF-ECF considera registro deletado na subida da Venda
					dbDelete()
					MsUnLock()
					DbSkip()
					Loop
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ----ฤฤฟ
					//ณRelease 11.5 - Cartao Fidelidade				  |
					//ณ Reinicializa variaveIs de cartao fidelidade	  |
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ----ฤู
					If lLjcFid
						If Fa271aGrcf ()
							LaFunhDelS ()
							Fa271aSrcf (.F.)
							Fa271aSpfw (.F.)
						EndIf					
					Endif
					
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณRelease 11.5 - Controle de Formularios 			ณ
					//ณZerar RECNO da especie de documento fiscal 		ณ
					//ณescolhida no inicio da venda.   					ณ
					//ณPaises:Chile/Colombia - F1CHI	   			    ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If (lCFolLocR5,FaZerRecFo(),NIL)			
				EndIf
			ElseIf SL2->L2_SITUA == "05"						// "05" - Solicitado o Cancelamento do Item
				// "Foi solicitado o cancelamento do item " ### ". Ele foi realmente cancelado?", "Aten็ใo"
				If MsgYesNo(STR0037+StrZero(FR271BPegaIT(L2_ITEM),3,0)+STR0038, STR0003)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Cancelar o Item ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					DbSelectArea("SL2")
					RecLock("SL2", .F.)
					SL2->L2_VENDIDO := "N"	//Sinaliza item cancelado, quando PAF-ECF considera registro deletado na subida da Venda
					dbDelete()
					MsUnLock()
					DbSkip()
					Loop
				Else
					aSL2 := {{"L2_SITUA",	"04"}}				// "04" - Impresso o Item
					
									
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณRelease 11.5 - Cartao Fidelidade 		ณ									
					//ณRecarga do cartao fidelidade processada: ณ				
					//ณB - Via processo batch (LJGRVBATCH)      ณ
					//ณW - Via WebService(LJCCARFID) 		    ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู													
					If lLjcFid
						If Fa271aGrcf()
							If Ca280CkWs ()                                          
								//W - Via WebService(LJCCARFID)                 
								aSL2 := {{"L2_PROCFID",	"W"}}						
								Fa271aSpfw (.T.)
							Else
								//B - Via processo batch (LJGRVBATCH)       
								aSL2 := {{"L2_PROCFID",	"B"}}
								Fa271aSpfw (.F.)							
							EndIf		
						Endif
					Endif
					FR271BGeraSL("SL2", aSL2)
					aSL1 := {{"L1_SITUA",	"04"}}				// "04" - Impresso o Item
					FR271BGeraSL("SL1", aSL1)
				EndIf
			EndIf
			SBI->(DbSeek(xFilial("SBI")+SL2->L2_PRODUTO))
			cCodProd := SBI->BI_COD
			cCodBar  := SBI->BI_CODBAR

			//Realiza o acerto do Arquivo SL2 caso a venda possua desconto
			//no total ou acrescimo...		
			If (cPaisLoc <> "BRA") .AND. ((SL2->L2_VLRITEM < SL2->L2_PRCTAB) .OR. (SL2->L2_VLRITEM > SL2->L2_PRCTAB))
				nVlrItem := ((SL2->L2_PRCTAB*Sl2->L2_QUANT)-SL2->L2_VALDESC)
				nDescUni := Round(Sl2->L2_VALDESC/SL2->L2_QUANT,nDecimais)
								
				aSL2 := {	{"L2_DESCPRO",	0},;
				         	{"L2_VLRITEM", nVlrItem},;
				         	{"L2_VRUNIT" , nVlrItem/SL2->L2_QUANT}}
				         	
				FR271BGeraSL("SL2", aSL2, .F.)
			EndIf


			
			MaFisIni(	cCliente,cLojaCli	,	"C"	,	"S"	,;
						cTipoCli,	NIL		,	NIL	,	.F.	,;
						"SBI"	,	NIL		,	"01",	NIL	,;
						NIL		,	NIL		,	NIL	,	NIL	,;
						NIL		,	NIL		,	.F.	)
			MaFisAdd(cCodProd, SL2->L2_TES, SL2->L2_QUANT, Sl2->L2_VRUNIT+If(cPaisLoc<>"BRA",nDescUni,0), SL2->L2_VALDESC, "", "",, 0, 0, 0, 0, SL2->L2_VLRITEM, 0)
			nVlIcmRet := MaFisRet(1,"IT_VALSOL") //ICMS Retido
			
			SF4->(DbSeek(xFilial("SF4")+MaFisRet(1,"IT_TES")))
			nDedIcmsIt  := 0
			
			If cPaisLoc == "BRA"
				If SF4->F4_ISS == "S"
					cAliquota := "S" + Str(MaFisRet(1,"IT_ALIQISS"),5,2)
				Else
					If (SBI->BI_PICMRET > 0 .OR. SBI->BI_PICMENT > 0) .AND. cTipoCli $ SuperGetMV("MV_TPSOLCF") .AND. SF4->F4_BSICMST <> 100					
						cAliquota := "F"
					ElseIf SF4->F4_BASEICM > 0 .AND. SF4->F4_BASEICM < 100
						cAliquota := "T" + Str(SBI->BI_ALIQRED,5,2)
					Elseif SF4->F4_LFICM == "I"
						cAliquota := "I"					// Isento
						If SF4->F4_AGREG == "D"            // Deducao de ICMS
					       nDedIcmsIt  := MaFisRet(1,"IT_DEDICM")
					       nTotDedIcms += nDedIcmsIt																					
					    Endif   
					Elseif SF4->F4_LFICM == "N"
						cAliquota := "N"					// No sujeito a ICMS
					Else
						cAliquota := "T" + Str(MaFisRet(1,"IT_ALIQICM"),5,2)
					Endif
				Endif
				nVlrMerc  += (SL2->L2_PRCTAB * SL2->L2_QUANT) // Acumula o valor de mercadorias
			Else
				nTotImp  := 0
		 	    aImps    := TesImpInf(MaFisRet(1,"IT_TES"))
			    Aadd(aImpsSL2,{cCodProd,MaFisRet(1,"IT_TES"),{}})
			    For nI := 1 to Len(aImps)                                                 
			    	If (nE := Ascan( aImpsSL1,{|x| x[1] == aImps[nI,1]})) == 0
			        	AAdd(aImpsSL1,{aImps[nI][1],"L1_"+Substr(aImps[nI][6],4,7),0,"L1_"+Substr(aImps[nI][8],4,7),0,aImps[nI][3],aImps[nI][9]})		    		    
			          	nE := Len(aImpsSL1)
			       	EndIf   
			       	cIndImp  := Substr(aImps[nI][2],10,1)               
			       	cCampoVal:= "IT_VALIV"+cIndImp		    
			       	cCampoAlq:= "IT_ALIQIV"+cIndImp	 
			       	nValImp  := Round(MaFisRet(1,cCampoVal),nDecimais)		       	    		       
				   	FR271HGeraImp(@aImposto,aImps[nI],nValImp,L2_QUANT,L2_VRUNIT,1,cIndImp, nDecimais )
				   	AAdd(aImpsSL2[Len(aImpsSL2)][3],aClone(aImposto))
				   	nTotImp += (nValImp * aImposto[10,Val(Subs(aImposto[5],2,1))])			   
				   	aImpsSL1[ nE,3 ] += aImpsSL2[len(aImpsSL2)][3][nI][4]	//Valor do imposto no cabecalho		   			   
				   	aImpsSL1[ nE,5 ] += aImpsSL2[len(aImpsSL2)][3][nI][3]	//Base do imposto no cabecalho		   			   		   
			    Next nI      
	           	AAdd(aImpsSL2[Len(aImpsSL2)],L2_ITEM)				
	           	AAdd(aImpsSL2[Len(aImpsSL2)],.F.)						           	
	           	AAdd(aImpsSL2[Len(aImpsSL2)],L2_QUANT)				
	           	AAdd(aImpsSL2[Len(aImpsSL2)],L2_VRUNIT)						           		           	
   				nVlrMerc  += (L2_VRUNIT * L2_QUANT)
	            nVlrItem  := ((L2_VRUNIT * L2_QUANT)+nTotImp)
			    cAliquota := " " + IIf(Len(aImps) > 0,Str(MaFisRet(1,cCampoAlq),5,2),"")
			Endif
			MaFisEnd()

			If SF4->F4_INCSOL == 'S' 
				nVlrTotal	+= If(cPaisLoc=="BRA",L2_VLRITEM + L2_VALIPI + L2_VALFRE + L2_SEGURO + L2_DESPESA + nVlIcmRet,nVlrItem)
				nVlrBruto	+= If(cPaisLoc=="BRA",L2_VLRITEM + L2_VALIPI + L2_VALFRE + L2_SEGURO + L2_DESPESA + nVlIcmRet,nVlrItem)
				nVlrFSD 	+= SL2->L2_VALFRE + SL2->L2_SEGURO + SL2->L2_DESPESA
				cVlIcmRet  := Transform(nVlIcmRet,PesqPict("SD2", "D2_ICMSRET", 13,nMoedaCor))
			Else
				nVlrTotal	+= If(cPaisLoc=="BRA",L2_VLRITEM + L2_VALIPI + L2_VALFRE + L2_SEGURO + L2_DESPESA,nVlrItem)
				nVlrBruto	+= If(cPaisLoc=="BRA",L2_VLRITEM + L2_VALIPI + L2_VALFRE + L2_SEGURO + L2_DESPESA,nVlrItem)
				nVlrFSD 	+= SL2->L2_VALFRE + SL2->L2_SEGURO + SL2->L2_DESPESA
				cVlIcmRet  	:= Transform(0,PesqPict("SD2", "D2_ICMSRET", 13,nMoedaCor))
			End
			nItem		:= FR271BPegaIT(SL2->L2_ITEM)
			nTotItens++
			cQuant     := PadL(Trans(L2_QUANT, If(L2_QUANT-Int(L2_QUANT)==0, "999999999", PesqPictQt("L2_QUANT",9))),9)
			cVlrUnit   := PadR(AllTrim(Trans(L2_VRUNIT+If(cPaisLoc<>"BRA",(nTotImp/L2_QUANT),0),PesqPict("SBI", "BI_PRV",9,nMoedaCor))),9)
			cVlrItem   := Transform(If(cPaisLoc=="BRA",L2_VLRITEM+L2_VALIPI,nVlrItem),PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))
		    cVlrPercIT := Transform(L2_DESC,"@R 99.99%")
			cValIPIIT  := Transform(L2_VALIPI,PesqPict("SL2", "L2_VALIPI" , 13,nMoedaCor))
			
			//Executa a funcao para calculo do total da venda em diversas moedas e
			//simula um aCols...
			If cPaisLoc <> "BRA"
				FR271ITotVen(	@nVlrTotal	, @nMoedaCor	, @nTaxaMoeda	, @aTotVen	,; 
							@aMoeda)
				FR271ISimACols(	cCodProd	, L2_QUANT	, L2_VRUNIT	, SF4->F4_CODIGO	,;
								SF4->F4_CF	, L2_ITEM	, Nil		, @aCols			,;
							 	@aHeader)
				AAdd(aImpsProd,aClone(aImpsSL2[Len(aImpsSL2)]))
			EndIf	
			
			nNumUltIt := nItem   // Armazena o numero do ultimo item registrado
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ P.E. Para Tratamento dos Dados Que Serao Mostrados na Tela. ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aAux := {	nItem 		, cCodProd	, cCodBar	, L2_DESCRI	, ;
						cQuant		, cVlrUnit	, cAliquota	, cVlrItem	, ;
						cVlrPercIT	, cValIPIIT	, .F.		, cVlIcmRet	}
			If lFRTCODB2t
				aAdd(aAux,uProdTPL)
				aAdd(aAux,uCliTPL)				
				
				aAux := ExecTemplate( "FRTCODB2", .F., .F., { aAux, uProdTPL, uCliTPL } )
				cCodProd := Padr(aAux[2],nTB1COD)
				cCodBar  := Padr(aAux[3],nTB1CODBAR)       
				If ValType( aAux[13] ) == "A"
					uProdTPL := aClone( aAux[13] )
				Else
					uProdTPL := aAux[13]
				Endif
				If ValType( aAux[14] ) == "A"
					uCliTPL  := aClone( aAux[14] )
				Else
					uCliTPL  := aAux[14]
				Endif
			EndIf
			If ExistBlock("FRTCODB2")
				aAux := ExecBlock("FRTCODB2",.F.,.F.,aAux)
				cCodProd := Padr(aAux[2],nTB1COD)
				cCodBar  := Padr(aAux[3],nTB1CODBAR)
			EndIf
			AAdd(aItens, { nItem     	, cCodProd  		, cCodBar    		, SL2->L2_DESCRI  						,;
			               SL2->L2_QUANT, SL2->L2_VRUNIT 	, SL2->L2_VLRITEM 	, SL2->L2_VALDESC  						,;
			               cAliquota	,SL2->L2_VALIPI 	, .F.        		, If (SF4->F4_INCSOL == 'S',nVlIcmRet,0),;
		                   nDedIcmsIt	, nItem             , Nil               , lImpIncl} )

			If SuperGetMv("MV_CODBAR",,"N") == "S" .AND. !Empty(cCodBar)
				cProdLocal := cCodBar
			Else
				cProdLocal := aAux[2]
			EndIf

			oCupom:AppendText((StrZero(aAux[1],3)+" "+Left(cProdLocal,13)+" "+Left(aAux[4],21) )+ chr(10) + chr(13))
			
			If cPaisLoc == "BRA"
				oCupom:AppendText((aAux[5]+"x"+aAux[6]+PadR(aAux[7],6)+"%"+aAux[8] )+ chr(10) + chr(13))
			Else
				oCupom:AppendText((aAux[5]+"x"+aAux[6]+Space(06)+aAux[8] )+ chr(10) + chr(13))
			EndIf
			If L2_DESC > 0 
				oCupom:AppendText( STR0039+aAux[9]) 	// "Desconto de :  "
			Endif
			If L2_VALIPI > 0 
				oCupom:AppendText("IPI: "+aAux[10]) 
			Endif
			If nVlIcmRet > 0 .AND. SF4->F4_INCSOL == 'S'  
				oCupom:AppendText( "ICMS Retido: "+aAux[12]) //"ICMS Retido: "+aAux[12])
			EndIf

			//Verifica se a venda ้ de um item vale-presente
			If lL2VALEPRE .AND. lVpNewRegra .AND. !Empty(SL2->L2_VALEPRE) .AND. ExistFunc("FrtSetVPIt")
				//Configura o item de vale-presente
				Lj7VPVdaVP(1)
				FrtSetVPIt(nItem, cCodProd	, cCodBar	,  SL2->L2_DESCRI, ;
						cQuant     	, cVlrUnit	, cAliquota	, nVlrItem, ;
						cVlrPercIT	, cValIPIIT	, .F.	, cVlIcmRet  )
				
			EndIf

			nRecno := SL2->(Recno())
			
			SL2->(DbSkip())
		End
		
		If nVlrFSD > 0
			oCupom:AppendText(("ACRESCIMO (FRETE) : "+ Transform(nVlrFSD,PesqPict("SL2", "L2_VLRITEM", 13,nMoedaCor))+ chr(10) + chr(13)))
		EndIf
		
		If nRecno > 0
			SL2->(dbGoTo(nRecno))
			cProduto := SBI->BI_DESC
			cUnidade := SL2->L2_UM
			nQuant   := SL2->L2_QUANT
			nVlrUnit := SL2->L2_VRUNIT
			nVlrItem := If(cPaisLoc=="BRA",SL2->L2_VLRITEM + SL2->L2_VALIPI + nVlIcmRet,nVlrItem)
			
		    If !lTouch  
			    If Empty(SBI->BI_BITMAP)    
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica se existe a imagem FRTWIN , caso nao possua apresenta a LOJAWINณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If oFotoProd:ExistBmp("FRTWIN")
						ShowBitMap(oFotoProd, "FRTWIN")				
					Else
						ShowBitMap(oFotoProd, "LOJAWIN")
					EndIf	
				Else
					ShowBitMap(oFotoProd, AllTrim(SBI->BI_BITMAP))
				EndIf
				oProduto:Refresh()
				oUnidade:Refresh()
				oQuant:Refresh()
				oVlrUnit:Refresh()
				oVlrItem:Refresh()
				oVlrTotal:Refresh()
				oTotItens:Refresh()
				oDesconto:Refresh()
			Endif	
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !lEmitNfce .And. IFStatus(nHdlECF, "12", @cRet) == 0
			IFNumItem(nHdlECF, @cTemp)
			If Val(cTemp) == nTotItens
				IFSubTotal(nHdlECF, @cTemp)
				If Val(cTemp)/100 <> nVlrTotal
					// "Existe diferen็as entre o Cupom Fiscal e o Sistema. Por favor, cancele o Cupom Fiscal.", "Aten็ใo"
					HELP(' ',1,'FRT008')
				EndIf
			Else
				// "Existe diferen็as entre o Cupom Fiscal e o Sistema. Por favor, cancele o Cupom Fiscal.", "Aten็ใo"
				HELP(' ',1,'FRT008')
			EndIf
		EndIf
		cCodProd := Space(nTB1COD)
		oCupom:GoEnd()
	EndIf
Else
	If !lEmitNfce .And. !lUseSat
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Como nao houve retomada, verifica Reducao Z ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If IFStatus(nHdlECF, "8", @cRet) == 10			  			// Verifica Reducao Z
			// "Nใo foi realizado o Fechamento do ECF no dia anterior. Deseja realizแ-lo agora?", "Aten็ใo"
			If MsgYesNo(STR0040, STR0003)
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Verifica Permissao "Redu็ใo Z" - #6 ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If LojA160()
					nRet := IFAbrECF(nHdlECF)
					If nRet <> 0
						// "Nใo foi possํvel realizar a Abertura do ECF. O Sistema serแ finalizado. Erro: " ###, "Aten็ใo"
						MsgStop(STR0042+Str(nRet,2,0), STR0003)
						// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
						lExitNow := .T.
						Return(NIL)
					EndIf
				Else
					// "Usuแrio sem permissใo para fechar o ECF. O sistema serแ finalizado.", "Aten็ใo"
					HELP(' ',1,'FRT009')
					// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
					lExitNow := .T.
					Return(NIL)
				EndIf
			Else
				// "ษ necessแrio fechar o ECF no dia anterior. O sistema serแ finalizado.", "Aten็ใo"
				HELP(' ',1,'FRT010')
				// Setar esta variavel como TRUE, caso deseje sair do sistema sem pedir permissao
				lExitNow := .T.
				Return(NIL)
			EndIf
		EndIf
	Else	
		If lEmitnfce .And. ExistFunc("Fr271aVlDt") .And. !Fr271aVlDt(.T.)
			MsgAlert(STR0366 + CRLF + STR0367)  // "A Data do dia ้ diferente da data do movimento" ... "Favor inicializar o sistema para atualizar com data atual."
			lExitNow := .T.
			Return NIL
		EndIf	
	EndIf

	/* Recupera็ใo do Cancelamento da Venda */
	If lEmitNfce .And. lUseSAT .And. ExistFunc("LjxLPCnSat")
		LjGrvLog("SAT"," SAT - Processo de verifica็ใo de recupera็ใo de cancelamento")
		
		//Guarda posi็ใo do or็amento original
		aAreaSL1 	:= SL1->(GetArea())
		aAreaSL2 	:= SL2->(GetArea())
		aAreaSL4 	:= SL4->(GetArea())	
		
		If !lRecovery
			LjGrvLog("SAT"," Pesquisa do arquivo para verificar se recupera cancelamento ")
			lFinaCanc := .F.
			nRecSL1Sat:= 0
			LjxLPCnSat(@lRecovery,@lFinaCanc,@nRecSL1Sat)
			LjGrvLog("SAT"," Recupera cancelamento -> lRecovery :",lRecovery)
			LjGrvLog("SAT"," Recupera cancelamento -> lFinaCanc :",lFinaCanc)
			LjGrvLog("SAT"," Recupera cancelamento -> nRecSL1Sat:",nRecSL1Sat)
		EndIf
		
		If lFinaCanc 
			If nRecSL1Sat > 0
				SL1->( DbGoto(nRecSL1Sat) )
				If LjSatFinCnc(.F.)
					SL2->(DbSetOrder(1)) //L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
					SL4->(DbSetOrder(1)) //L4_FILIAL + L4_NUM + L4_ORIGEM
					SL2->(DbSeek(xFilial("SL2")+SL1->L1_NUM))
					SL4->(DbSeek(xFilial("SL4")+SL1->L1_NUM))
					
					//" Venda referente ao or็amento #" + XXXXX + " cancelada no Equipamento de SAT estแ pendente de cancelamento no Protheus " + CHR(13) + " Serแ realizado o cancelamento dessa venda!"
					MsgAlert(STR0363 + AllTrim(SL1->L1_NUM) + StrTran(STR0364,"SAT",cSiglaSat) + CHR(13) + STR0365)
					
					//Gera cancelamento SAT
					lRet := LJSatxCanc(.F.,@cNFisCanc)
					
					If lRet
						LjRegRefsh("SL1") //Caso orcamento tenha subido e alterado L1_SITUA enquanto esta cancelando
						
						If ExistFunc("FrtFCncTEF")
							 IF FrtFCncTEF(.F.,lTefDiscado,.T.,@cSupervisor,.T.,)
							 	lRet := .T.
							 Else
							 	lRet := .F.
							 	LjGrvLog("SAT","Recupera็ใo de cancelamento - TEF nใo foi cancelado")
							 EndIf
						EndIf
						
						If lRet
							LjSatAjTab(.T.,	.F.	,.F.,cNFisCanc,@cMsgSLI,)
							LjSatFinCnc(.T.) //apaga a sessใo
							LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo sinal de recupera็ใo de cancelamento
							LjGrvLog("SAT","Recupera็ใo de cancelamento - Processo finalizado")
						EndIf
						
						cMsgSLI		:= ""
						cNFisCanc	:= ""
					Else
						LjGrvLog("SAT"," Recupera็ใo de cancelamento nใo finalizado - L1_NUM [" + SL1->L1_NUM + "]")
					EndIf
				Else
					LjGrvLog("SAT"," SAT - Recupera็ใo de cancelamento nใo encontrado na sessใo do equipamento do SAT ")
				EndIf
			Else
				LjGrvLog("SAT","Localizado Cancelamento nใo finalizado pendente")
			EndIf
		EndIf
		
		//Retorna posi็ใo do or็amento original			
		RestArea(aAreaSL4)
		RestArea(aAreaSL2)
		RestArea(aAreaSL1)
	EndIf
EndIf
SL1->(DbSetOrder(nOrder))
DbSelectArea(cAlias)

// Funcao abaixo chamada para atualizar o objeto TOTAL do Quadrante 2
// da interface principal na entrada da tela, pois existe vendas interrompidas
// em que o valor do total deve voltar.
If lTouch
	FRTAtuTot(nVlrTotal)
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ AjustaSX1    ณ Autor ณ Conrado Q. Gomes     ณ Data ณ 17/09/2007 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Ajusta os Helps.                                                ณฑฑ 
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ SIGAFRT                                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaHelp()
Local aHlpP	:= {}		// Texto em portugu๊s
Local aHlpE	:= {}		// Texto em ingl๊s
Local aHlpS := {}		// Texto em castelhano

// Help FRT046
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Transa็ใo TEF cancelada devido เ " 		)
aAdd (aHlpP, "falha ao imprimir o comprovante " 		)
aAdd (aHlpP, "TEF. O cupom fiscal serแ cancelado, " 	)
aAdd (aHlpP, "pois o n๚mero seqüencial do Emissor " 	)	
aAdd (aHlpP, "do Cupom Fiscal nใo foi incrementado." 	)
aAdd (aHlpE, "EFT transaction cancelled due to " 		)	
aAdd (aHlpE, "failure when printing EFT voucher. " 		)
aAdd (aHlpE, "The tax coupon will be  cancelled " 		)
aAdd (aHlpE, "because the sequentialnumber of the " 	)	
aAdd (aHlpE, "tax coupon printer (ECF) was not " 		)
aAdd (aHlpE, "increased." 								)
aAdd (aHlpS, "Transaccion TEF anulada debido a falla" 	)
aAdd (aHlpS, "al imprimir comprobante TEF." 			)
aAdd (aHlpS, "Se anulara el cupon fiscal porque el " 	)
aAdd (aHlpS, "numero secuencial del emisor " 			)	
aAdd (aHlpS, "de cupon fiscal no aumento." 				)

PutHelp("PFRT046", aHlpP, aHlpE, aHlpS, .T. )
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "" )
aAdd (aHlpE, "" )
aAdd (aHlpS, "" )
PutHelp("SFRT046", aHlpP, aHlpE, aHlpS, .T. )

// Help FRT047
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Transa็ใo TEF cancelada devido เ " 		)
aAdd (aHlpP, "impossibilidade de registrar a forma " 	)
aAdd (aHlpP, "de pagamento no ECF." 					)
aAdd (aHlpE, "EFT transaction cancelled due to the "	)
aAdd (aHlpE, "impossibility to register payment " 		)
aAdd (aHlpE, "mode in ECF (tax coupon printer)." 		)
aAdd (aHlpS, "Transaccion TEF anulada debido a " 		)
aAdd (aHlpS, "imposibilidad de registrar la forma " 	)
aAdd (aHlpS, "de pago en el ECF." 						)
PutHelp("PFRT047", aHlpP, aHlpE, aHlpS, .T. )
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Por favor, realize novamente a opera็ใo "	)
aAdd (aHlpP, "TEF, ou escolha uma nova forma de " 		)
aAdd (aHlpP, "pagamento." 								)
aAdd (aHlpE, "Please, execute the EFT transaction " 	)
aAdd (aHlpE, "again or select a new payment mode."		)
aAdd (aHlpS, "Por favor, efectue la operacion TEF " 	)
aAdd (aHlpS, "nuevamente o seleccione una nueva " 		)
aAdd (aHlpS, "forma de pago." 							)
PutHelp("SFRT047", aHlpP, aHlpE, aHlpS, .T. )

// Help FRT048
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Transa็ใo TEF cancelada devido เ falha "		)
aAdd (aHlpP, "ao registrar a forma de pagamento no ECF."	)
aAdd (aHlpE, "ETF cancelled due to failure when "			)
aAdd (aHlpE, "registereing payment mode in ECF "			)
aAdd (aHlpE, "(tax coupon printer).	"						)
aAdd (aHlpS, "Transaccion TEF anulada debido a falla" 		)
aAdd (aHlpS, "al registrar la forma de pago en el  ECF."	)
PutHelp("PFRT048", aHlpP, aHlpE, aHlpS, .T. )
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "Por favor, realize novamente a opera็ใo " 	)
aAdd (aHlpP, "TEF, ou escolha uma nova forma de pagamento." )
aAdd (aHlpE, "Please, execute the EFT transaction " 		)
aAdd (aHlpE, "again or select a new payment mode."			)
aAdd (aHlpS, "Por favor, efectue la operacion TEF " 		)
aAdd (aHlpS, "nuevamente o seleccione uma nueva " 			)
aAdd (aHlpS, "forma de pago." 								)
PutHelp("SFRT048", aHlpP, aHlpE, aHlpS, .T. )

// Help FRT049
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "O cupom fiscal serแ cancelado devido " 		)
aAdd (aHlpP, "ao erro na finaliza็ใo da venda." 			)
aAdd (aHlpE, "The tax coupon will be cancelled due " 		)
aAdd (aHlpE, "to error finishing the sale." 				)
aAdd (aHlpS, "Se cancelara el cupon fiscal debido "			)
aAdd (aHlpS, "a error al finalizar la venta." 				)
PutHelp("PFRT049", aHlpP, aHlpE, aHlpS, .T. )
aHlpP := {}
aHlpE := {}
aHlpS := {}
aAdd (aHlpP, "" )	// ""
aAdd (aHlpE, "" )	// ""
aAdd (aHlpS, "" )	// ""
PutHelp("SFRT049", aHlpP, aHlpE, aHlpS, .T. )

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFR271HRES บAutor  ณVendas Cliente      บ Data ณ  04/16/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se existe reserva nos itens para efetuar o        บฑฑ
ฑฑบ          ณ cancelamento do Cupom                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FR271HRES( lTemImpressao)

Local lRet		:=	.F.
Local aAreaSL2	:= SL2->(GetArea())
                         
DEFAULT lTemImpressao 	:= .F.

DbSelectArea("SL2")
DbSetOrder(1)
If DbSeek(xFilial("SL2")+SL1->L1_NUM)
	While !EOF() .AND. (SL2->L2_FILIAL+SL2->L2_NUM == xFilial("SL2")+SL1->L1_NUM)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Verifica se existe reserva nos itens para efetuar o cancelamento do Cupom 		ณ
		//ณ Tambem verifica se existe itens sem reserva para poder executar comandos de ECF	ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(SL2->L2_RESERVA) .And. SL2->L2_ENTREGA<>"2"
			lRet := .T.   
		Else
		    lTemImpressao := .T.
		EndIf
	
		DbSkip()
	End              
EndIf	

RestArea(aAreaSL2)                

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFrtValProdบAutor  ณVendas Cliente      บ Data ณ  06/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz o tratamento da recarga de celular					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FrtValProd(	nVlrUnit	,cCodProd	,lTefPendCS,	cSeqTrans ,;
						aRegTEF		,aItens	)

Local lRet		:= .F.								// Retorno da funcao

DEFAULT aRegTEF	:= {}
DEFAULT aItens	:= {}

If Len(aRegTEF) > 0
	cSeqTrans 	:= aRegTef[1][1]
Else
	If Len(aItens) == 0
		cSeqTrans := StrZero(Val(FR271PegNuCup()) + 1, TamSx3("LG_COO") [1], 0)
	Else
		cSeqTrans := StrZero(Val(FR271PegNuCup()), TamSx3("LG_COO") [1], 0)
	EndIf
Endif	

nVlrUnit    := SBI->BI_PRV
lRet        := oTef:LjRecCelProd( @nVlrUnit	, Nil		, Nil			, Nil	, ;
          					       cSeqTrans	, cCodProd	, @lTefPendCS )
If lRet
	lTefPendCS  := .T.
	aAdd(aRegTEF,{oTef:cCupom,oTef:cData,oTef:cHora,.T.})
Else
	If Len(aRegTEF) == 0 
		lTefPendCS  := .F.
	Endif	
	aAdd(aRegTEF,{oTef:cCupom,oTef:cData,oTef:cHora,.F.})
Endif	

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFrtPegNuCupบAutor  ณVendas Clientes     บ Data ณ  27/12/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega o numero do cupom da impressora.				           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFrontLoja                                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณCaracter                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FrtPegNuCup()
Local cCupom := ""				//Retorno da funcao

//Pega o numero do cupom
If IFPegCupom(nHdlECF, @cCupom) != 0
    	cCupom := ""
EndIf

Return cCupom

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFrtConfTefบAutor  ณVendas Cliente      บ Data ณ  10/06/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a confirmacao ou desfazimento do TEF.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FrtConfTef( lTefPendCS, aTefBKPCS, lConfirma )

Local cCupom		:= ""     // Numero do cupom da transacao TEF
Local cData			:= ""     // Data da transacao TEF
Local cHora			:= ""     // Hora da transacao TEF
Local nCont			:= 0      // Variavel do loop
Local nTotReg		:= 0      // Total de transacoes a serem finalizadas na transacao TEF

Default lTefPendCS	:= .T.
Default aTefBKPCS	:= {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTratamento para realizar o processo de confirma็ใo do TEF     ณ
//ณpara o processo de recarga de celular.                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If (cTipTEF == TEF_CLISITEF) .AND. lUsaTEF
	cCupom		:= oTef:cCupom
	cData		:= oTef:cData
	cHora		:= oTef:cHora
	nTotReg		:= Len(aRegTEF)

	For nCont := 1 to nTotReg                          
		oTef:cCupom	:= aRegTEF[nCont][1]
		oTef:cData	:= aRegTEF[nCont][2]
		oTef:cHora	:= aRegTEF[nCont][3]
		
		If aRegTEF[nCont][4]
			oTEF:FinalTrn(1)
		Else
			oTEF:FinalTrn(0)
		EndIf
	Next nCont     
	oTef:cCupom	:= cCupom
	oTef:cData	:= cData
	oTef:cHora	:= cHora	
EndIf	

If lTefPendCS .AND. lUsaTEF
	lTefPendCS := .F.
	aTefBKPCS  := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento realizado para TEF pendente, utilizando a CLISITEF.ณ
	//ณCaso o usuario abandone a tela de forma de pagamento e exista ณ
	//ณuma transacao TEF Pendente, mando uma nao confirmacao.		 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lConfirma
		oTEF:FinalTrn(1)
	Else
		oTEF:FinalTrn(0)
	EndIf		
EndIf

aRegTEF := {}

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFrtDesFormบAutor  ณVendas Clientes     บ Data ณ  20/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe a forma no SX5 Tabela24 e retorna a      บฑฑ
ฑฑบ		     ณdescricao.												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFrontLoja                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cForma) - Forma a ser consultada.   			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณCaracter                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FrtDesForm(cForma)
Local cRetorno := Nil						//Retorno da funcao com a descricao da forma
Local aArea	   := Nil						//Array para guardar a area do SX5
Local aAtual   := Nil						//Array para guardar a area atual
	
//Guarda a posicao do arquivo atual
aAtual := GetArea()
//Guarda a posicao do SX5
aArea := GetArea("SX5")

//Seleciona a tabela
DbSelectArea("SX5")

//Posiciona no registro
DbSeek(xFilial("SX5")+"24")

//Procura a forma na tabela 24
While !Eof() .AND. cFilial == X5_FILIAL .AND. X5_TABELA = "24"
    //Verifica se encontrou a forma
	If AllTrim(SX5->X5_CHAVE) == cForma
		//Guarda a descricao da forma
		cRetorno := Alltrim(X5Descri())
		Exit
	EndIf	
    //Vai para o proximo registro
	DbSkip()
End

//Restaura a posicao do arquivo atual
RestArea(aAtual)
//Restaura a posicao do SX5
RestArea(aArea)

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFrtPegNumCFบAutor  ณVendas Clientes     บ Data ณ  27/12/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega o numero do cupom da impressora.		 		           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFrontLoja                                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณCaracter                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FrtPegNumCF()
Local cCupom := ""				//Retorno da funcao

//Pega o numero do cupom
If IFPegCupom(nHdlECF, @cCupom) <> 0
    	cCupom := ""
EndIf

Return cCupom

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFrtRecVend บAutor  ณVendas Clientes     บ Data ณ  13/01/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe recarga de celular na venda               บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FrtRecVend( aRegTEF )
	
	Local nCont			:= 0      					// Variavel do loop
	Local nTotReg		:= 0  					    // Total de transacoes de recarga
	Local cTipTEF 		:= LJGetStation("TIPTEF")	//Indica o tipo de TEF
	Local lRetorno		:= .F.	 					// Retorno da funcao

	Default aRegTEF		:= {}
	
	If (cTipTEF == TEF_CLISITEF) .AND. lUsaTEF
		
		If ValType(aRegTEF) == "A"
			nTotReg	:= Len(aRegTEF)
		EndIf
	
		For nCont := 1 to nTotReg                          
			If aRegTEF[nCont][4]
				lRetorno := .T.
				Exit
			EndIf
		Next
	EndIf	
	
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFrtCanItRe บAutor  ณVendas Clientes     บ Data ณ  14/01/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIndica que o item de recarga precisa ser cancelado antes     บฑฑ
ฑฑบ		     ณde finalizar a venda, porque a transa็ใo ja foi desfeita     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FrtCanItRe(lValor)
	
	lCancItRec := lValor
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FrtRetStc บAutor  ณVendas Clientes     บ Data ณ  02/04/09   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o valor da variแvel static 'lCancItRec'              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FrtRetStc()

	Local lRet := lCancItRec
	
Return(lRet)

//--------------------------------------------------------------------------------
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFUNCOES UTILIZADAS APENAS PARA PBM ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFR271MenuPbmบAutor  ณVendas Clientes     บ Data ณ  14/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Apresenta um menu com as opcoes de transacoes para o PBM.   	บฑฑ
ฑฑบ          ณ                                                            	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271F                                                   	บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FR271MenuPbm(oDlgFrt, oFntGet)
Local oDlg     

DEFINE MSDIALOG oDlg TITLE STR0336 FROM 00,00 TO 240,200 OF GetWndDefault() PIXEL	//"Rotinas PBM" 

	@ 10,10 BUTTON STR0333	SIZE 80,20 OF oDlg PIXEL ACTION ( LjOPbm(@oDlgFrt, @oFntGet)   , oDlg:End() )	//"Venda PBM" 
	@ 30,10 BUTTON STR0334	SIZE 80,20 OF oDlg PIXEL ACTION ( LjCancPbm(@oDlgFrt, @oFntGet), oDlg:End() )	//"Cancelamento PBM" 	
	@ 50,10 BUTTON STR0335	SIZE 80,20 OF oDlg PIXEL ACTION ( oDlg:End() )	        	 					//"&Sair"

ACTIVATE MSDIALOG oDlg CENTERED

Return()    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjOpbm     บAutor  ณVendas Clientes     บ Data ณ  14/10/08   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Instancia o objeto PBM, para utilizacao das PBMs            บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LjOPbm(oDlgFrt, oFntGet)
	
	Local cDoc 		:= ""						// Retorna o numero do cupom fiscal
	Local cOperador := LjGetStation("PDV")		// Guada o codigo do pdv para passar para a PBM
	Local cSerie	:= LjGetStation("SERIE")	// retorna a SERIE fiscal da esta็ใo
	Local cTpDoc	:= "0" //tipo de documento utilizado no pbm = 0 - ecf, 1 - nfce, 2 -sat
	Local nTamCupPBM	:= 6 //Tamanho do cupom PBM

	//Estancia o objeto LjCPbm
	oPbm := LjCPbm():Pbm()
	
	/*
		Busca o numero do documento fiscal
	*/
	
	cDoc := LjPbmNumDoc(nTamCupPBM, cSerie, .T.)

	
	//Pega o numero do cupom
	If !Empty(cDoc)

   	    //Seleciona a PBM
	    If !oPbm:SelecPbm()
	    	oPbm := Nil
	 	Else
	 		If lUseSAT
	 			cTpDoc := "2"
	 		ElseIf lEmitNfce
	 			cTpDoc := "1"
	 		EndIf
	 		 		
	 		//Inicializa a venda PBM
	 		If !oPbm:IniciaVend( cDoc, cOperador, cTpDoc )
	    		oPbm := Nil
	 		Else
	 			LjMsgRodaP(@oDlgFrt, @oFntGet, STR0333) // "Venda PBM"
	 			setObjTelaFRT( oDlgFrt, oFntGet)
	 		EndIf
	    EndIf
    EndIf
    
Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLjCancPbm บAutor  ณVendas Clientes     บ Data ณ  19/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Chama a transacao de cancelamento da PBM                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function LjCancPbm(oDlgFrt, oFntGet)
		
	oPbm := LjCPbm():Pbm()
	
	If oPbm <> Nil
		If oPbm:SelecPbm()
			
			LjMsgRodaP (@oDlgFrt, @oFntGet, STR0334) //"Cancela PBM"
			
			If oPbm:CancPbm()
				oTef:ImpCupTef()
			EndIf
		EndIf
	EndIf
    
	oPbm := Nil
	
	LjMsgRodaP (@oDlgFrt, @oFntGet, STR0001) //"   Protheus Front Loja"
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjCancProdPBM บ Autor ณVendas Clientes     บ Data ณ  14/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o cancelamento da PBM                                  บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjCancProdPBM( cCodBarra, nQtde )

	Local lRet := .F.		// Retorno da funcao
    
	If oPbm:CancProd( cCodBarra, nQtde )
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return( lRet )
                     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjGetOPBM บAutor  ณMarcio Lopes	     บ Data ณ  19/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o valor do Objeto oPbm	                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjGetOPBM()

	Local oRetPbm
	
	oRetPbm := oPbm
	    
Return( oRetPbm )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjSetOPBM บAutor  ณMicrosiga           บ Data ณ  09/19/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o objeto oPbm                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ ExpO1 - Objeto que atualizara o Objeto oPbm                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjSetOPBM( oSetPbm )
	
	oPbm := oSetPbm

Return()     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjVendProdPbm บAutor  ณMarcio Lopes        บ Data ณ  09/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Vede produtos da PBM                                           บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 - Codigo de barras                                       บฑฑ
ฑฑบ          ณ ExpN1 - Quantidade do item                                     บฑฑ
ฑฑบ          ณ ExpN2 - Valor unitario                                         บฑฑ
ฑฑบ          ณ ExpN3 - Percentual de desconto                                 บฑฑ
ฑฑบ          ณ ExpL1 - Indica se vendeu produto da PBM                        บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjVendProdPbm(	cCodBar, nQuant, nVlrUnit, lItemPbm, nVlrDescIT, lPrioPbm, nVlrPercIT )

	Local lRet 		:= .F.						// Retorno da funcao
	Local nPercDesc := 0						// Percentual de desconto
	Local nValorAux := 0						// Utilizado para calcular o valor do desconto

	Default nVlrDescIT 	:= 0
	Default lPrioPbm 	:= .T.                                  	
	Default nVlrPercIT 	:= 0
		
	If nVlrDescIT > 0 .AND. nVlrPercIT == 0
		nPercDesc := (nVlrDescIT/(nVlrUnit*nQuant)) * 100
	Else
		nPercDesc := nVlrPercIT
	EndIf
	
	lRet := oPbm:VendProd( 	cCodBar		, nQuant	, nVlrUnit	, @nPercDesc, ;
							@lItemPbm	, lPrioPbm	)

	If lItemPbm
		nVlrPercIT := nPercDesc
	Else
		nValorLiq := NoRound(nVlrUnit - (nVlrUnit * (nPercDesc / 100)), 2)
		nPercDesc := NoRound(((nVlrUnit - nValorLiq) * 100) / nVlrUnit, 2)
		nVlrPercIT := nPercDesc
	EndIf
	
	nValorAux  := NoRound((nVlrUnit * nQuant) - (((nVlrUnit * nQuant) * nPercDesc) / 100), 2)	
		
	nVlrDescIT := (nVlrUnit * nQuant) - nValorAux
		
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjConfProdPBMบAutor  ณMarcio Lopes        บ Data ณ  15/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConfirma os produtos da PBM.                                   บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณExpC1 - Codigo de barras                                       บฑฑ
ฑฑบ          ณExpN1 - Quantidade do produto                                  บฑฑ
ฑฑบ          ณExpL1 - Flag de confirmaca do produto                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjConfProdPBM( 	cCodBarra	, nQtde, lOk, lItemPbm, ;
								aItens		, nX )

	Local lRet := .F.		// Retorno da funcao

	If lItemPbm
		lRet := oPbm:ConfProd( cCodBarra, nQtde, lOk )
		If !lRet
			//"Produto nใo confirmado na PBM. Cupom fiscal sera cancelado."
			Alert(STR0338)
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCancela o Cupom Fiscal e PBMณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			FrtCancCup( .T. )
		Else
			aItens[nX, AIT_PBM] := lItemPbm
		EndIf
	Else
		lRet := .T.
	EndIf
	
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjFinVend บAutor  ณ Vendas Clientes    บ Data ณ  30/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Finaliza o processo de venda na PBM                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjFinVend(cDoc, cSerie, cKeyDoc)

	Local lRet := .F.	// Retorno da funcao

	lRet := oPbm:FinalVend(cDoc, cSerie, cKeyDoc)  
	
	LjMsgRodaP (bkp_oDlgFrt, bkp_oFntGet, STR0001) //"   Protheus Front Loja"

Return( lRet )    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjSubsidioบAutor  ณVendas Clientes     บ Data ณ  12/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a venda PBM possui subsidio para ja levar auto- บฑฑ
ฑฑบ          ณmaticamente para as formas de pagamento.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjSubsidio(aFormCtrl, aPgtos, nMoedaCor, aPgtosSint, nVidaLink, aVidaLinkD)

	Local nValor	:= 0			    	//Valor do subsidio
	Local lRetorno  := .F.					//Retorno da funcao, define se tem ou nao subsidio
    Local cFormaSub := ""					//Forma utilizada no subsidio
    Local cDescForm := Nil					//Descricao da forma de pagamento
    Local nI		:= 0
    
    Default nVidaLink 	:= 0
    Default aVidaLinkD 	:= {}

	If nVidaLink <> 0 .And. nVidaLink <> 99
		If oTef:nCodFuncao <> 560	//Se nao for Funcional Card
	    	For nI := 1 to Len(aVidaLinkD[VL_DETALHE])
	      		nValor += (aVidaLinkD[VL_DETALHE,nI, VL_PRVENDA ] - aVidaLinkD[VL_DETALHE,nI, VL_PRVISTA ]) * aVidaLinkD[VL_DETALHE,nI, VL_QUANTID]
	      	Next nI
		EndIf   	    
    Else
    	nValor	:= oPbm:BuscaSubs()
    EndIf   

	If nValor > 0
		
		//Verifica a forma utilizada para subsidio, se nao encontrar o default e CO.
		cFormaSub := SuperGetMV("MV_LJFSUB", Nil, "CO")		
		
		//Verifica se a forma esta cadastrada na tabela 24 e guarda a descricao.
		cDescForm := FR271DesForm(cFormaSub) //FrtDesForm
		
		If cDescForm != Nil
			aPgtos 			:= {}				// Variavel da forma de pagamento
			aPgtosSint   	:= {}				// Variavel da forma de pagamento
			AADD(aPgtos, { dDataBase, nValor, cFormaSub, LjRetCad(cDescForm), "", "", "", "", "", .F., 1, "1", 0, "" })
			AAdd(aFormCtrl, {cFormaSub, LjRetCad(cDescForm), dDataBase, 1, 0, 0, nValor, NIL , "1"} )
			aPgtosSint:=Fr271IMontPgt(aPgtos, nMoedaCor)
			lRetorno := .T.
		Else
			Alert(STR0337) //"Venda PBM com subsํdio, por favor, cadastrar uma forma no parโmetro MV_LJFSUB."
		EndIf
	EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjTemSubsiบAutor  ณVendas Clientes     บ Data ณ  21/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a venda PBM possui subsidio.					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRTA271                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjTemSubsi()

	Local nValor	:= 0    				//Valor do subsidio
	Local lRetorno  := .F.					//Retorno da funcao, define se tem ou nao subsidio
    Local cFormaSub := ""					//Forma utilizada no subsidio
    Local cDescForm := Nil					//Descricao da forma de pagamento
    
	If oPbm != Nil
		
		nValor	:= oPbm:BuscaSubs()
		
		If nValor > 0
			
			//Verifica a forma utilizada para subsidio, se nao encontrar o default e CO.
			cFormaSub := SuperGetMV("MV_LJFSUB", Nil, "CO")		
			
			//Verifica se a forma esta cadastrada na tabela 24 e guarda a descricao.
			cDescForm := FR271DesForm(cFormaSub) //FrtDesForm
			
			If cDescForm != Nil
				lRetorno := .T.
			EndIf
		EndIf
	EndIf

Return lRetorno
//--------------------------------------------------------------------------------      


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFUNCOES DE USO GERAISณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//--------------------------------------------------------------------------------      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFR271PegNuCupบAutor  ณVendas Clientes     บ Data ณ  27/12/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPega o numero do cupom da impressora.				             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFRTA271                                                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณCaracter                                                       บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FR271PegNuCup()
Local cCupom := ""				//Retorno da funcao

//Pega o numero do cupom
If IFPegCupom(nHdlECF, @cCupom) != 0
    	cCupom := ""
EndIf

Return cCupom  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณFR271DesFormบAutor  ณVendas Clientes     บ Data ณ  20/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe a forma no SX5 Tabela24 e retorna a      บฑฑ
ฑฑบ		     ณdescricao.												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณFrontLoja                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณEXPC1 (1 - cForma) - Forma a ser consultada.   			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณCaracter                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FR271DesForm(cForma)
Local cRetorno := Nil						//Retorno da funcao com a descricao da forma
Local aArea	   := Nil						//Array para guardar a area do SX5
Local aAtual   := Nil						//Array para guardar a area atual
	
//Guarda a posicao do arquivo atual
aAtual := GetArea()
//Guarda a posicao do SX5
aArea := GetArea("SX5")

//Seleciona a tabela
DbSelectArea("SX5")

//Posiciona no registro
DbSeek(xFilial("SX5")+"24")

//Procura a forma na tabela 24
While !Eof() .AND. cFilial == X5_FILIAL .AND. X5_TABELA = "24"
    //Verifica se encontrou a forma
	If AllTrim(SX5->X5_CHAVE) == cForma
		//Guarda a descricao da forma
		cRetorno := Alltrim(X5Descri())
		Exit
	EndIf	
    //Vai para o proximo registro
	DbSkip()
End

//Restaura a posicao do arquivo atual
RestArea(aAtual)
//Restaura a posicao do SX5
RestArea(aArea)

Return cRetorno  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjMsgRodaPบAutor  ณVendas Clientes     บ Data ณ  06/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra a mensagem na tela do front                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LjMsgRodaP( oDlgFrt, oFntGet, cMensagem ) 

@ 221, 166 SAY oMensagem VAR cMensagem FONT oFntGet PIXEL SIZE 332,18 COLOR CLR_WHITE,CLR_BLACK OF oDlgFRT
oMensagem:lTransparent := .F.
oMensagem:cCaption := cMensagem
oMensagem:cTitle   := cMensagem
oMensagem:Refresh()    
	
Return(.T.)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjRetCad  บAutor  ณVendas Clientes     บ Data ณ  10/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a administradora consultada esta cadastrada no บฑฑ
ฑฑบ          ณ SAE                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRONTLOJA                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LjRetCad( cAdmRet )
Local cReturn	:= ""								// Retorna a administradora + codigo da ADM no SAE
Local lContinua	:= .T.								// Controla o While

DbSelectArea("SAE")
DbSetOrder(1)
DbSeek(xFilial("SAE"))
While !Eof() .AND. AE_FILIAL == xFilial("SAE") .And. lContinua

	//-- Caso encontre a administradora retornada pelo TEF no cad. de administradora ela que serแ utilizada,
	//-- caso contrแrio fica a que o usuแrio escolheu.	
	If cAdmRet == AllTrim(Upper(SAE->AE_DESC))
		cReturn := SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))
		lContinua := .F.
	Endif
	DbSkip()
End 

Return( cReturn )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsetObjTelaFRT บAutor  ณVendas Clientes     บ Data ณ  10/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Set os objetos da tela do front para ser usado na finalizacao  บฑฑ
ฑฑบ          ณ do PBM.                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRONTLOJA                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function setObjTelaFRT( oDlgFrt, oFntGet )

bkp_oDlgFrt := oDlgFrt
bkp_oFntGet := oFntGet

Return()

      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณFrt271IniCli  บAutor  ณVendas Clientes     บ Data ณ  07/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que inicializa as variaveis referentes a cliente        บฑฑ
ฑฑบ          ณ com o conteudo dos parametros                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FRONTLOJA                                                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Frt271IniCli( cCliente, cLojaCli)

Local nTamSXG := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define cliente com o padrao do parametro ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nTamSXG  := TamSXG("001")[1]	// Grupo de Cliente
cCliente := Left(PadR(SuperGetMV("MV_CLIPAD"), nTamSXG),nTamSXG)
nTamSXG  := TamSXG("002")[1]	// Grupo de Loja
cLojaCli := Left(PadR(SuperGetMV("MV_LOJAPAD"),nTamSXG),nTamSXG)
	
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณFRT271aVL	 บAutor  ณVendas Clientes     บ Data ณ  25/05/10   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao Criada para receber as variaveis da Vida Link         บฑฑ
ฑฑบ          ณdas outras funcoes.                		                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Function FRT271aVL(aVidaLink)
If Len (aVidaLink) > 0 
	aVidaLinkD := aVidaLink[1]
	aVidaLinkc := aVidaLink[2] 
	nVidaLink  := aVidalink[3]
EndIf	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LjAjustaNcc
Fun็ใo responsแvel por marcar a NCC para baixar posteriormente ou 
para limpar os residuos de controle de NCC que nao serใo mais baixados
@author	Varejo
@param		lBaixa -> Se marcar para baixar posteriormente (.T.) ou deleta (.F.)
@return	lRet - .T. = Marcou para baixa / .F. -> nao marcou para baixa    	
@since		21/10/2016
/*/
//------------------------------------------------------------------- 
Static Function LjAjustaNcc(lBaixa)
Local lRet			:= .F. //retorno

Default lBaixa	:= .F. //se marcar para baixar ou apenas limpa a tabela

If SL1->L1_CREDITO > 0
	MDJ->(DBSetOrder(2)) //MDJ_FILIAL+MDJ_SITUA
	/*"TP" - significa que foi criada a NCC temporaria na tabela MDJ para em caso de queda de venda seja 
	restaurado a baixa da NCC para nao ficar com a venda finalizada porem a NCC nใo baixada */
	If MDJ->(DBSeek(xFilial("MDJ")+"TP"))
		While MDJ->(!EOF()) .And. AllTrim(xFilial("MDJ")+"TP") == AllTrim(MDJ->(MDJ_FILIAL+MDJ_SITUA))
			If MDJ->(RecLock("MDJ",.F.))
				If lBaixa .And. AllTrim(MDJ->MDJ_NUMORC) == AllTrim(SL1->L1_NUM)
					MDJ->MDJ_SITUA := "NP" //Marca para baixa posteriormente via Job (FRTA020)
					lRet := .T.
				Else
					MDJ->(DBDelete()) //limpa o controle de NCC para vendas recuperadas
				EndIf
				MDJ->(MSUnlock())
			EndIf
			MDJ->(DBSkip())
		End
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FrtDblOrc
@description Duplica Orcamento
@author Verejo
@since 06/10/2016
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function FrtDblOrc() 

Local aStruSL1	:= {} //Estrutura inteira do dicionario da SL1
Local aDadosSL1	:= {} //Conteudo dos campos da SL1
Local aStruSL2	:= {} //Estrutura inteira do dicionario da SL2
Local aDadosSL2	:= {} //Conteudo dos campos da SL2
Local aStruSL4	:= {} //Estrutura inteira do dicionario da SL4
Local aDadosSL4	:= {} //Conteudo dos campos da SL4
Local nX			:= 0  //contador
Local cNewNum		:= "" //numero do or็amento
Local nPos			:= 0  //posicao para recuperar valor de uma campo da busca do aScan
Local nLinha		:= 0  //numero de registros adicionados para cada estrutura da SL2 , SL4
Local nSaveSx8 	:= GetSx8Len() // Numeracao do SX8
Local nRegNumOrig	:= SL1->(RECNO())	//numero do or็amento original a ser copiado
Local cMay 		:= ""
Local nTent 		:= 0

SL1->(DBSetOrder(1))//L1_FILIAL + L1_NUM

cNewNum := CriaVar("L1_NUM") //Nova numera็ใo

// Caso o SXE e o SXF estejam corrompidos cNumOrc estava se repetindo.
cMay := Alltrim(xFilial("SL1"))+cNewNum
FreeUsedCode() //libera codigos de correlativos reservados pela MayIUseCode()

// Se dois orcamentos iniciam ao mesmo tempo a MayIUseCode impede que ambos utilizem o mesmo numero.
While SL1->(DbSeek(xFilial("SL1")+cNewNum)) .OR. !MayIUseCode(cMay)
	If ++nTent > 20
		Final("Impossivel gerar numero sequencial de orcamento correto.") //#"Impossivel gerar numero sequencial de orcamento correto."
	Endif
	While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	End
	cNewNum := CriaVar("L1_NUM")
	FreeUsedCode()
	cMay := Alltrim(xFilial("SL1"))+cNewNum
End
While (GetSX8Len() > nSaveSx8)
	ConfirmSX8()
End

//Reposiciona na venda original
SL1->(DBGOTO(nRegNumOrig))

aStruSL1:= SL1->(dbStruct())
aStruSL2:= SL2->(dbStruct())
aStruSL4:= SL4->(dbStruct())

//****SL1****
For nX := 1 To Len(aStruSL1)
	aAdd(aDadosSL1, { aStruSL1[nX][1], &("SL1->"+aStruSL1[nX][1]) } )
Next nX
nPos := aScan(aDadosSL1, {|x| x[1] == "L1_NUM"} )
aDadosSL1[nPos][2] := cNewNum

//****SL2****
SL2->(DbSetOrder(1)) // L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
SL2->(DbSeek(xFilial("SL2") + SL1->L1_NUM))
While !SL2->(EOF()) .And. xFilial("SL2") + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM
	aAdd(aDadosSL2,{})
	nLinha := Len(aDadosSL2)
	For nX := 1 To Len(aStruSL2)
		aAdd(aDadosSL2[nLinha], { aStruSL2[nX][1], &("SL2->"+aStruSL2[nX][1]) } )
	Next nX

	nPos := aScan(aDadosSL2[nLinha], {|x| x[1] == "L2_NUM"} )
	aDadosSL2[nLinha][nPos][2] := cNewNum

	SL2->(DbSkip())
EndDo

//****SL4****
SL4->(DbSetOrder(1)) // L4_FILIAL + L4_NUM + L4_ORIGEM
SL4->(DbSeek(xFilial("SL4") + SL1->L1_NUM))
While !SL4->(EOF()) .And. xFilial("SL4") + SL1->L1_NUM == SL4->L4_FILIAL + SL4->L4_NUM
	aAdd(aDadosSL4,{})
	nLinha := Len(aDadosSL4)
	For nX := 1 To Len(aStruSL4)
		aAdd(aDadosSL4[nLinha], { aStruSL4[nX][1], &("SL4->"+aStruSL4[nX][1]) } )
	Next nX

	nPos := aScan(aDadosSL4[nLinha], {|x| x[1] == "L4_NUM"} )
	aDadosSL4[nLinha][nPos][2] := cNewNum

	SL4->(DbSkip())
EndDo

//Cria o or็amento novo
FR271BGeraSL("SL1",aDadosSL1,.T.)

For nX := 1 To Len(aDadosSL2)
	FR271BGeraSL("SL2",aDadosSL2[nX],.T.)
Next nX

For nX := 1 To Len(aDadosSL4)
	FR271BGeraSL("SL4",aDadosSL4[nX],.T.)
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F271TefNum
@description	Pega o numero de chave para transa็ใo TEF
@author		Verejo
@since			26/12/2016
@version		11.80
@return		cRet - Chave da transa็ใo TEF.
/*/
//-------------------------------------------------------------------
Function F271TefNum()
Local cRet := ""

If oPbm <> NIL .AND. !Empty(oPBM:oPBM:cNumCupom) .AND. oPBM:GetTpOpera() == 1
	cRet := oPBM:oPBM:cNumCupom
ElseIf ValType(oTEF:aRetVidaLink) == "O" .AND. oTEF:lTEFOk .AND. !Empty(oTEF:cCupom)
	cRet := oTEF:cCupom
Else

	If SL1->(!EOF()) .And. !Empty(SL1->L1_NUM)
		cRet := AllTrim(SL1->L1_NUM) + LjGetStation("PDV")
	EndIf

Endif

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LjPbmNumDoc
@description	Rotina para confirmar a transa็ใo que ficou pendente 
                do TEf na venda quando existir queda do sistema
@author			Fabiana.silva
@since			27/03/2018
@version		11.80
@return			sem retorno
@parametros		nTamCupPBM = Tamanho do cupom PBM
		   		cSerie =  Serie do PDV
/*/
//-------------------------------------------------------------------
Function LjPbmNumDoc(nTamCupPBM, cSerie, lSomaCup)
Local aLastSat	:= {}
Local cDoc	:= ""

Default nTamCupPBM := 6
Default cSerie := LjGetStation("SERIE")
Default lSomaCup := .F.

If lEmitNFCe
	//retorna o conte๚do do campo X5_DESCRI	da tabela SX5
	If lUseSAT 
		If !ExistFunc("LJSatNumSale")
			MsgAlert(STR0368) //"Entrar em contato com o suporte e solicitar a atualiza็ใo do programa LOJSAT"
		Else
			aLastSat := LJSatNumSale()
			If Len(aLastSat) >= 1
				cDoc := aLastSat[01]
				cDoc := Right( cDoc, nTamCupPBM )
				cDoc := PADL( Val(cDoc) + IIF(lSomaCup,1, 0), nTamCupPBM, "0" )
			EndIf
		EndIf
	Else
		cDoc := Tabela('01', cSerie)
		//a transa็ใo PBM sometne suporte 6 caracteres para o n๚mero do cupom fiscal
		cDoc := Right( cDoc, nTamCupPBM )
	
	EndIf	
Else		
	cDoc := FR271PegNuCup()
	//+1 no numero retornado, pois ela retorna o ultimo numero utilizado
	cDoc := PADL( Val(cDoc)+ IIF(lSomaCup,1, 0), nTamCupPBM, "0" )
EndIf
				
Return cDoc			

//-------------------------------------------------------------------
/*/{Protheus.doc} F271TefPd
@description	Rotina para confirmar a transa็ใo que ficou pendente 
                do TEf na venda quando existir queda do sistema
@author			Verejo
@since			12/12/2017
@version		11.80
@return			sem retorno
@parametros		nConfirma = 1 confirma transa็ใo , nConfirma = 0 cancela transa็ใo TEF
		   		lLimpaLog = limpa as informa็๕es do campo LG_LOGTEF
/*/
//-------------------------------------------------------------------

Static Function F271TefPd(nConfirma, lLimpaLog)
Local nTCupom	  := Len(LjGetStation("PDV")) + TamSx3("L1_NUM")[1]		// Pego o Tamanho do conteudo do campo LG_PDV pois este pode ser variado e somo com o tamanho do cupom

Default nConfirma := 2
Default lLimpaLog := .F.

LjGrvLog("LOGTEF PDV","F271TefPd Vai inicio da fun็ใo" )
oTef:cCupom	:= Substr(SLG->LG_LOGTEF,1,nTCupom)
oTef:cData	:= Substr(SLG->LG_LOGTEF,nTCupom + 1,8)
oTef:cHora	:= Substr(SLG->LG_LOGTEF,nTCupom + 9,6)

LjGrvLog("LOGTEF PDV","F271TefPd - cCupom: " + oTef:cCupom + " cData" + oTef:cData + " cHora: " + oTef:cHora  )
LjGrvLog("LOGTEF PDV","F271TefPd nConfirma" , nConfirma  )	
LjGrvLog("LOGTEF PDV","F271TefPd lLimpaLog" , lLimpaLog  )

If nConfirma == 1 
	LjGrvLog("LOGTEF PDV","F271TefPd vai executar a confirma็ใo da transa็ใo" , nConfirma  )	
	oTef:FinalTrn(1,lLimpaLog)
ElseIf nConfirma == 0 	
	LjGrvLog("LOGTEF PDV","Vai executar o cancelamento da transacao" )	
	oTef:FinalTrn(0,lLimpaLog)
EndIf	
				
Return	
