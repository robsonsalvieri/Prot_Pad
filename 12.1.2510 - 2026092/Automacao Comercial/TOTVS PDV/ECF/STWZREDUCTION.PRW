#INCLUDE "PROTHEUS.CH"         
#INCLUDE "STWZREDUCTION.CH"         

#DEFINE MODELIMPRES "EPSON"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWZReduction
Function emite redução Z  
@param   	lDialog - Exibe Dialogo de redução Z
@param   lRedZPend Existe redução Z pendente no ECF
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Emissão com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWZReduction( lDialog , lRedZPend)
Local nOpt          := 0											// Escolha do usuario entre o OK e o CANCELA
Local cPrinter   := ""											// Impressora que sera utilizada
Local cLock          := cUserName+cEstacao							// Flag para que a rotina nao seja executada simultaneamente em MDI 
Local lRet           := .F.											// Retorno da funcao
Local lCancOrc		 := .T.											// Define se cancela os orçamentos
Local nRet			 := 0  											// Retorno do ECF(IFAbrECF)
Local lTax		 	:= STWIsTax()                                   // Verifica se o usuário é Fiscal
Local aRet			:= {}
Local aDados		:= {}											// Dados de retorno
Local dDataMov		:= dDataBase									// Data do movimento do ECF

Default lDialog 	:= .T.
Default lRedZPend 	:= .F. //Verifica se a redução Z está pendente no ECF

/* Faz o controle via LockByName para evitar que um usuario acesse  
2 vezes uma rotina que use os perifericos de automacao 
evitando assim a concorrencia dos mesmos*/
If !LockByName( cLock )
	Return(Nil)
Endif 
        
cPrinter :=  STFGetStat("IMPFISC")

If !lTax
	// Para Emitir a Redu‡„o Z da Impressora fiscal, deve-se estar cadastrado como usu rio fiscal e com os parƒmetros da impressora corretos.
    STFMessage( "ZREDUCTION","STOP",STR0001)
    STFShowMessage( "ZREDUCTION")
Else 
	//--------------------------------------------------------------------------------------------------------------
	//Consiste o numero de serie do equipamento conforme arq. sigaloja.bin somente se o parametro MV_LJNSECF = .T.
	//--------------------------------------------------------------------------------------------------------------
	STWValSerie()
	
	If  STFProfile(6)[1]	
	
	    If lDialog //Chamada  a partir da função STFStart
	    
			nOpt := STIZReduction(cPrinter)
		Else     
			STFMessage("ZREDUCTION2", "YESNO", STR0004) //"A Impressora está ligada corretamente e as configurações de gravação do cadastro de redução Z corretos ?"
			IIF(STFShowMessage("ZREDUCTION2"),nOpt := 1,nOpt:=0)
		EndIf
			
		//Se o usuario confirrmou executa a leitura da Reducao Z e a impressao
		If nOpt == 1

				//-----------------------------------------------------------------------
				//TO DO TPL POSTO(REQUISITO XXXV):Emissao automatica, antes da reducao Z,
				//do(s) CF(s) referente a abastecimento pendente(Finalizacao da venda).    
				//-----------------------------------------------------------------------
				
				//-----------------------------------------------------------------------
				// TO DO Requisito XLI do Ato Cotepe 0608 para Oficina de Conserto - Emissão		
				// do Relatório Gerencial de DAV-OS Emititdos				
				//-----------------------------------------------------------------------
				
				aDados := { "19" , "" } //Data do ECF 
				aRet := STFFireEvent(ProcName(0),"STPrinterStatus",aDados)  
				
				If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 1  .AND. !Empty(aDados[2])
					 dDataMov	:= CTOD((aDados[2]))
				EndIf
				
				If !lRedZPend .AND. STFGetCfg("lPafEcf") 
					//Emissão pela redução Z..
					STWCancOrc( dDataMov )
					lCancOrc := .F.
				EndIf
				
				//Processa reducao Z				
				Processa({|lEnd| STBZRedProc()}) 				
					
				// Para impressoras Epson, e necessario a reabertura do ECF para reinicializacao das variaveis					
				If MODELIMPRES $ cPrinter .and. !(lRedZPend .AND. STFGetCfg("lPafEcf"))
				   	nRet := STWOpenECF()
				EndIf

				// Se existir redução Z pendente no ECF
				If lRedZPend .AND. STFGetCfg("lPafEcf")

					nRet :=	STWOpenECF()

					If nRet == 0
						//Busca Orcamentos vencidos e cancela depois da Redução Z
						STWCancOrc( dDataMov )
					Else
						STFMessage("ZREDUCTION3", "STOP", STR0005 + " "+STR0009+" " +Str(nRet,2,0)) //"Erro:"
						// "Não foi possível realizar a Abertura do ECF. Não será possível efetuar cancelamento das Pré Vendas pendentes na Retaguarda."
						STFShowMessage("ZREDUCTION3")
					EndIf
				EndIf

				//TO DO: Quando não processada, tenta realizar efetivacao dos abastecimentos apos da RedZ
				
				//TO DO: Impressão de DAV-OS
		Endif

		lRet := .T.

	Endif
Endif

If lRet
	STWSetEcfOperante()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWDadoZReduction
Function Retorna dados da redução Z  
@author  Varejo
@version 	P11.8
@since   	28/12/2016
@return  	lRet - Ultima Z emitida com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWDadoZReduction()
Local aRet		:= {}
Local aDados	:= {}
Local cDataUltZ	:= ''
Local dDataUltZ	:= Nil
Local cPDVUltZ	:= ''
Local cReduction:= Space(5000)
Local nAtAux	:= 0
Local lRet		:= .T.	//quando .T. nao processa reducao Z novamente
Local bOldError	:= Nil

bOldError := ErrorBlock( {|x| LjGrvLog("Dados_ReducaoZ", "Nao foi possivel verificar dados da ultima reducao Z") } ) 

Begin Sequence

	aDados := {cReduction}
	
	LjGrvLog("Dados_ReducaoZ", "Antes de STDadoReductZ",aRet)
	aRet := STFFireEvent(	ProcName(0)		,;		// Nome do processo
							"STDadoReductZ"	,;		// Nome do evento
							@aDados)
	LjGrvLog("Dados_ReducaoZ", "Depois de STDadoReductZ - aDados",aDados)
	LjGrvLog("Dados_ReducaoZ", "Depois de STDadoReductZ - aRet",aRet)
	
	LjGrvLog("Dados_ReducaoZ", "Antes de validar aDados e aRet")
	If (ValType(aRet) == "A") .And. (Len(aRet) > 0) .AND. (aRet[1] == 0) .AND.;
		(ValType(aDados) == "A") .And. (Len(aDados) > 0) .AND. (aDados[1] <> '')
	 	
		cReduction := aDados[1]
		LjGrvLog("Dados_ReducaoZ", "cReduction antes",cReduction)
		
		//Pega Data
		nAtAux 	:= At("|", cReduction) 	
		cDataUltZ 	:= SUBS(cReduction,1,nAtAux-1)
		cReduction := SUBS(cReduction, nAtAux + 1, LEN(cReduction) )
		
		LjGrvLog("Dados_ReducaoZ", "nAtAux",nAtAux)
		LjGrvLog("Dados_ReducaoZ", "cDataUltZ",cDataUltZ)
		LjGrvLog("Dados_ReducaoZ", "cReduction depois",cReduction)
		
		If !Empty(cDataUltZ)
			dDataUltZ := CTOD(cDataUltZ)
			LjGrvLog("Dados_ReducaoZ", "dDataUltZ",dDataUltZ)
		EndIf
		
		//Pega PDV
		nAtAux 	:= At("|", cReduction) 	
		cPDVUltZ 	:= SUBS(cReduction,1,nAtAux-1)
		LjGrvLog("Dados_ReducaoZ", "nAtAux depois",nAtAux)
		LjGrvLog("Dados_ReducaoZ", "cPDVUltZ",cPDVUltZ)
	EndIf
	LjGrvLog("Dados_ReducaoZ", "Depois de validar aDados e aRet")
	
	
	//Verifica se possui SFI armazenada na base
	LjGrvLog("Dados_ReducaoZ", "Antes de posicionar a SFI")
	LjGrvLog("Dados_ReducaoZ", "cDataUltZ",cDataUltZ)
	LjGrvLog("Dados_ReducaoZ", "cPDVUltZ",cPDVUltZ)
	LjGrvLog("Dados_ReducaoZ", "dDataUltZ",dDataUltZ)
	If !Empty(cDataUltZ) .AND. !Empty(cPDVUltZ)
		DbSelectArea("SFI")
		SFI->( DbSetOrder(1) )
		lRet := SFI->( DbSeek(xFilial("SFI") + DTOS(dDataUltZ) + cPDVUltZ) )
	EndIf
	LjGrvLog("Dados_ReducaoZ", "Depois de posicionar a SFI",lRet)
	
Recover
	LjGrvLog("Dados_ReducaoZ", "Nao foi possivel verificar dados da ultima reducao Z")
	lRet := .T.	
End Sequence

ErrorBlock(bOldError)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCancOrc
Fluxo para cancelamento de orçamento 
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Cancelamento com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWCancOrc(dDataMov) 
Local aRet		:= LjAnalisaLeg(24)					// Retorno da legislacao do estado
Local lRet 		:= .F.								// Retorno da funcao
Local lEmite	:= SuperGetMv("MV_LJPRVEN",,.T.)	// Define se o cliente trata o orcamento como pre-venda
Local nOpc	    := 1							//Cancelar Orcamentos abertos
Local lRedZPend	:= .F.							//Verifica se a redução Z está pendente no ECF       
Local aRet1		:= {}

Default dDataMov				:= dDataBase

If cPaisLoc == "BRA"  
	If STBIsPAF(SM0->M0_CGC)
	                          
	    //Procedimento de cancelamento utilizado pelo SIGALOJA(Offline/PAF-ECF) e FrontLoja
		If lEmite
			
			aRet1 :=	STFFireEvent(	ProcName(0)			,;		// Nome do processo
							"STPrinterStatus"				,;		// Nome do evento
							{"8"							,;	
							" "} )

			//Verifica se Redução Z esta pendente 
			If Len(aRet1) > 0 .AND. aRet1[1] == 10
				lRedZPend	:=	.T. 
			EndIf

			If !lRedZPend // Se lRedZPend == .T., ECF está com redução Z pendente
			   //Aguarde....Cancelando Pré-Vendas"
				STFMessage("STWCancOrc", "RUN", STR0006  ,{ || STWISPafSearch( .T. , dDataMov ) }) //"Aguarde... Cancelando Pré-Vendas"
				STFShowMessage("STWCancOrc")

				lRet := .T.
			EndIf

		Else
			lRet := .T.	
		EndIf	
	
	Else
		If aRet[1] .AND. lEmite
			nOpc := 2  
			STFMessage("STWCancOrc2", "YESNO", STR0007 ) //STR0018, STR0019, {STR0020, STR0021},, STR0022) // ### "Atenção" ### ""Deseja cancelar pré vendas em aberto?" ### {"&Sim","&Não"} ### "Redução Z"
			//"Deseja cancelar pré vendas em aberto?"
			If STFShowMessage("STWCancOrc2")  
		    	nOpc := 1
			EndIf
		Else
			nOpc := 2
		EndIf	
	
		If nOpc == 1
			If Len(aRet) >= 1 
				If aRet[1] .AND. lEmite
					LJMsgLeg( aRet )
					//Aguarde....Cancelando Pré-Vendas"
					STFMessage("STWCancOrc3", "RUN", "Aguarde... Cancelando Pré-Vendas"  ,{ || STWISPafSearch( .T. , dDataMov )})
					STFShowMessage("STWCancOrc3")
					lRet := .T.
				EndIf
			EndIf
		Else
			lRet := .T.	
		EndIf	
	EndIf
Else
	lRet := .T.	
EndIf 


Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STWChkZReduction
Function emite redução Z  
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	lRet - Emissão com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWChkZReduction(lPrint) 
Local aRet := {}
Local lRet := .T.  

Default lPrint := .T. 

aRet :=	STFFireEvent(	ProcName(0)				,;		// Nome do processo
							"STPrinterStatus"	,;		// Nome do evento
							{"8"				,;	
							" "} )

//Verifica se Redução Z esta pendente 
If (lRet := Len(aRet) > 0 .AND. aRet[1] == 10 )
    If lPrint
    // "Não foi realizado o Fechamento do ECF no dia anterior. Deseja realizá-lo agora?", "Atenção"	
    	lPrint := .F.
    	STFMessage( "STWChkZReduction","YESNO",STR0008)
    	If STFShowMessage( "STWChkZReduction")	
			lRet := !STWZReduction( .T. , .T. )
		EndIf 
	EndIf
EndIf

//Verifica se ultima Z foi gravada
If ExistFunc("STBValidaZ") .AND. !STWDadoZReduction()
	STBZRedProc(.F.)	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STIZReduction
Janela de emissão da Redução Z  
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	nOpt - Opção selecionada pelo usuário
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STIZReduction(cPrinter)
Local oDlg															// Tela	
Local nOpt          := 0											// Escolha do usuario entre o OK e o CANCELA

Default cPrinter := STFGetStat("IMPFISC")

DEFINE MSDIALOG oDlg FROM 39,85 TO 280,600 TITLE STR0010 PIXEL OF oMainWnd //"Cupom de Redução Z"

	// Objetivo do Programa
	@ 7,4 TO 80,250 LABEL STR0002 OF oDlg  PIXEL COLOR CLR_RED  //Objetivo do Programa"

	// Este programa tem como  objetivo  efetuar  a  impress„o do + cupom de Redução Z da impressora:
	@ 19, 15 SAY STR0003 SIZE 250,10 OF oDlg PIXEL COLOR CLR_RED  //"Este programa tem como  objetivo  efetuar  a  impress„o do + cupom de Redução Z da impressora"
	@ 29, 15 SAY cPrinter SIZE 250,10 OF oDlg PIXEL COLOR CLR_BLUE
    
	//"Além da impressão o sistema permite a gravação automática do cadastro de redução Z. Desde que o ECF esteja homologado com essa rotina e as configurações de parâmetros estejam adequadas."
	//	@ 49, 15 SAY STR0007 SIZE 230,60 OF oDlg PIXEL COLOR CLR_BLUE

	DEFINE SBUTTON FROM 95, 180 TYPE 1 ACTION (nOpt := 1, oDlg:End() ) ENABLE OF oDlg	

	DEFINE SBUTTON FROM 95, 220 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
ACTIVATE MSDIALOG oDlg CENTERED     

Return nOpt
