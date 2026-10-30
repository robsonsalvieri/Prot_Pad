#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWOPENDEVI.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenDevi
Cria Variaveis do Sistema
@param 	oNewTEF - Objeto TEF
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet - Retorna se executou corretamente
/*/
//-------------------------------------------------------------------
Function STWOpenDevi(oNewTEF) 
Local aRet		:= {}  						//Array de retornos
Local lRet		:= .T.						//Retorno
Local lUsaTef	:= STFGetCfg("lUsaTef")		//Verifica se esta habilitado para o usuario o Tef
Local lEmitNfce	:= LjEmitNFCe()				// Sinaliza se utiliza NFC-e 
Local lMobile	:= STFGetCfg("lMobile", .F.)//Versao Mobile
Local aRetChSat	:= {} //retorno chave de ativação SAT
Local lContinua	:= .F.
Local lRecSat	:= .F. //Se a venda foi recuperada
Local lFinCnc	:= .F.
Local aSale		:= {} //Array de recovery da venda
Local lUseSAT	:= LjUseSat()		 		// Sinaliza se utiliza SAT
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Local cPorta	:= ""
Local lLjxImpRed:= .F.
Local oRaasI	:= Nil
Local cModelo	:= ""

Default oNewTEF 				:= NIL  

lMobile := ValType(lMobile) == "L" .AND. lMobile

//Versao Mobile Demonstrativa Permite entrar sem Equipamentos
If lMobile .AND. ExistFunc("STFTypeOperation") 
	If STFGetCfg("cTypeOperation","") == "DEMONSTRACAO"
		Return .T.
	EndIf 
EndIf

//Limpa o Objeto Impressora
STFClearEvents()

//Inicializa o Objeto Impressora
STFStrategyECF()      

aRet :=	STFFireEvent(ProcName(0),"STCheckDLL",{.F.} )
							
STWCloseDevice(oNewTEF)

If lUsaTef
	oNewTEF := STBGetTEF()  
	
	// Abrir o TEF antes dos perifericos 
	// Abre o Gerenciador TEF
	If ValType(oNewTEF) == "O" 
		
		If oNewTEF:lAtivo
	
			oNewTEF:Fechar()
		EndIf
		
		FreeObj(oNewTEF)
	EndIf  
	
	oNewTEF := LJC_TEF():New(STFGetStat("CODIGO") , .F.) 
	STBSetTef(oNewTEF)

Else
	If ExistFunc("STTMTT") 
		STTMTT("1")
	EndIf 
EndIf

If ExistFunc("LjxRaasInt") .And. LjxRaasInt()
	oRaasI := LjRAASIntegration():New("RAAS",STFGetStat("CODIGO"))
	STBSetRaas(oRaasI)
EndIf 

aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
							"STCheckDLL"																	,;		// Nome do evento
							{.f.} )

IF !Empty(STFGetStat("GAVETA")) .AND. !Empty(STFGetStat("PORTGAV"))  
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STDrawerOpen"																,;		// Nome do evento
							{STFGetStat("GAVETA")														,;	
							STFGetStat("PORTGAV"),;
							STFGetStat("PORTIF")} )

	If Len(aRet) == 0 .OR. aRet[1] <> 0 
			STFMessage("OpenDevice", "ALERT", STR0002 + STFGetStat("GAVETA") + STR0003 + STFGetStat("PORTGAV")) //"Erro ao conectar com a Gaveta Serial " + "na porta"                                                       
			STFShowMessage("OpenDevice")
	EndIf
EndIf


If !Empty(STFGetStat("BALANCA") )  .AND. !Empty(STFGetStat("PORTBAL") )
	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STBalanceOpen"																,;		// Nome do evento
							{STFGetStat("BALANCA")														,;	
							STFGetStat("PORTBAL")} )

	If Len(aRet) == 0 .OR. aRet[1] <> 0 
			STFMessage("OpenDevice", "ALERT", STR0004 + STFGetStat("BALANCA") + STR0003 + STFGetStat("PORTBAL")) // Erro ao conectar na balança + na porta
			STFShowMessage("OpenDevice")
	EndIf

EndIf   

If !Empty(STFGetStat("OPTICO")) .AND. !Empty(STFGetStat("PORTOPT"))    
	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STReaderOpen"																,;		// Nome do evento
							{STFGetStat("OPTICO")														,;	
							STFGetStat("PORTOPT"),;
							'F'} )

	If Len(aRet) == 0 .OR. aRet[1] <> 0 
			STFMessage("OpenDevice", "ALERT", STR0005 + STFGetStat("OPTICO") + STR0003 + STFGetStat("PORTOPT")) // "Erro ao conectar com o Leito Optico Serial + na porta
			STFShowMessage("OpenDevice")
	EndIf
	
EndIf

If !Empty(STFGetStat("CMC7") ) .AND. !Empty(STFGetStat("PORTMC7") )
	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STCMC7Open"																	,;		// Nome do evento
							{STFGetStat("CMC7")															,;		
							STFGetStat("PORTMC7"),;
							"" } )

	If Len(aRet) == 0 .OR. aRet[1] <> 0 
			STFMessage("OpenDevice", "ALERT", STR0006 + STFGetStat("CMC7") + STR0003 + STFGetStat("PORTMC7")) // "Erro ao conectar com o Leitor de CMC7 " + "na porta"
			STFShowMessage("OpenDevice")
	EndIf

EndIf 

If !Empty(STFGetStat("IMPCHQ") ) .AND. !Empty(	STFGetStat("PORTCHQ") ) 
	//Abre a impressora de cheques     
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STCHOpen"																		,;		// Nome do evento
							{STFGetStat("IMPCHQ")														,;	
							STFGetStat("PORTCHQ") } ) 	
	
	
	If Len(aRet) == 0 .OR. aRet[1] <> 0 
			STFMessage("OpenDevice", "ALERT", STR0007 + STFGetStat("IMPCHQ") + STR0003 + STFGetStat("PORTCHQ")) // "Erro ao conectar com a Impressora de Cheque " + " na porta"
			STFShowMessage("OpenDevice")
	EndIf

EndIf  

If STFGetCfg("lUseECF") .AND. !lUseSAT .AND. !lAutomato// Utiliza impressora fiscal
	
	If !Empty(STFGetStat("IMPFISC")) .AND. !Empty(STFGetStat("PORTIF") )
		aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
									"STOpenCom"																,;		// Nome do evento
									{STFGetStat("IMPFISC")													,;	
									STFGetStat("PORTIF"),;
									 .T. } )   		
		
		If Len(aRet) == 0 .OR. aRet[1] <> 0 
			STFMessage("STWOpenDevi", "STOP", STR0001) // "Falha no Comando de Abertura e Selecao da Porta"
			STFShowMessage("STWOpenDevi")			
			STWCloseDevice(oNewTEF)
			Return  .F.			
		EndIf
		
		// Grava o numero de serie do ECF no campo LG_SERPDV 
		aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
								"STChkSerie"																	,;		// Nome do evento
								{} )		

		If Len(aRet) == 0 .OR. !aRet[1]
			
			STFMessage("STWOpenDevi", "STOP", STR0008) // "Falha na verificação do arquivo criptografado"
			STFShowMessage("STWOpenDevi")			
			STWCloseDevice(oNewTEF)
			Return  .F.			
		EndIf	
			
		aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STOpenECF"																,;		// Nome do evento
								{STFGetStat("IMPFISC")													,;	
								STFGetStat("PORTIF") } )		
		
		If Len(aRet) == 0 .OR. aRet[1] <> 0
			STFMessage("STWOpenDevi", "STOP", STR0009) // "Falha no Comando de Abertura da Impressora"
			STFShowMessage("STWOpenDevi")
			STWCloseDevice(oNewTEF)			
			Return .f.
		EndIf
	
		//------------------------------------------------
		//| Compara a data do ECF com a data do Sistema  | 
		//------------------------------------------------	
		aRet :=	STFFireEvent(	ProcName(0)																	,;		// Nome do processo
									"STChkRptP"																	,;		// Nome do evento
									{} )
		If Len(aRet) == 0 .OR. !aRet[1]
		
			STFMessage("STWOpenDevi", "STOP", STR0010) // "Problemas na verificação dos dados da Estação com os Dados do ECF"
			STFShowMessage("STWOpenDevi")			
			STWCloseDevice(oNewTEF)
			Return  .F.			
		EndIf	
	
		//LJSetAliq() //TO DO: Função para programar as alíquotas que não existem - facilitador
		
		//--------------------------------------------------------------------------------
		//³Verifica se utiliza troca de serie automatica quando o COO for reinicializado.³
		//³Emite aviso para rodar a rotina de reserva de series.                         ³
		//--------------------------------------------------------------------------------
		// to do: Verificação do numero de série - Facilitador LJNSrDisp()
	Else		
		If STWIsTax()  
			STFMessage("STWOpenDevi", "STOP", STR0011) // "Usuário Caixa sem impressora Fiscal cadastrada."
			STFShowMessage("STWOpenDevi") 
			STWCloseDevice(oNewTEF) 
			Return .F.
		EndIf
	EndIf
EndIf

// NFCE e SAT- Abre comunicação impressora Não Fiscal
If 	lEmitNfce .OR. (LjAnalisaLeg(70)[1] .And. lUseSAT) 
	
	cPorta := STFGetStat("PORTIF")
	cModelo := STFGetStat("IMPFISC") 

	If !Empty(cModelo) .AND. !Empty( cPorta )
		
		lLjxImpRed := ExistFunc("LjxImpRede")
		If lLjxImpRed .And. LjxImpRede(.T.)
			cPorta := LjxEqPIPRD()[2]
		EndIf
	
		aRet :=	STFFireEvent(	ProcName(0)						,;		// Nome do processo LjMsgRun("Aguarde, Abrindo impressora Não Fiscal"
								"STOpenPrintCommunication"		,;		// Nome do evento OpenPrintCommunication
								{cModelo						,;	
								cPorta							,;
								 .T.  } )
	
		If Len(aRet) == 0 .OR. aRet[1] <> 0
			STFMessage("STWOpenDevi", "STOP", STR0001) // "Falha no Comando de Abertura e Selecao da Porta"
			STFShowMessage("STWOpenDevi")
			STWCloseDevice(oNewTEF)
			lRet := .F.
			If lLjxImpRed
				LjxImpRede( .T. , .T. )
			EndIf
		Else
			If aRet[1] == 0 .And. lLjxImpRed //Precisa fechar quando em rede - Verifique documentacao
				LjxCtImpRD( .F. , .T. )
			EndIf

			//Fecha a comunicação após utilizar para não travar a porta
			STWClosePrintCommunication(cModelo, cPorta)
		EndIf
		
	Else
		STFMessage("STWOpenDevi", "STOP", STR0015) // "NFCE - necessário configuação de Imp. Não-Fiscal"
		STFShowMessage("STWOpenDevi")
	EndIf
	
	// Abre comunicação com SAT
	If STFPROFILE(3)[1] .And. lUseSAT
		
		aSale := STDRSGetSale()
		If Len(aSale) > 0
			If aSale[1][AScan( aSale[1] , { |x| x[1] == "L1_SITUA"	} 	)][2] == "10"
				lRecSat	:= .T. 
			EndIf
		EndIf

		If !lRecSat .And. ExistFunc("LjxLPCnSat") 
			LjxLPCnSat(@lRecSat,@lFinCnc)
		EndIf
		
		lContinua := LJSATInicia(lRecSat)
		
		//Pega a chave de ativação do sat para o cliente que esta acessando o sistema
		If lContinua .AND. Empty(SuperGetMV("MV_SATTEST",,""))
			aRetChSat := LjGetSig()
			If Len(aRetChSat) > 0 .AND. !Empty(aRetChSat[2])
				MsgAlert(aRetChSat[2])
			Else
				If ExistFunc("LjSetChSat")
					LjSetChSat(aRetChSat[1])
				EndIf
			EndIf
		EndIf

		If lRecSat
			If ExistFunc("STDSatRecovery")
				STDSatRecovery(lFinCnc)
			Else
				LjGrvLog( "SAT", "AVISO: Favor atualizar o fonte STDRecoverySale.PRW e LOJSAT.PRW para a correta recuperação da venda.")
				LJSatUltimo()
			EndIf
		EndIf	
		
		If !lContinua
			lRet := .F.
		EndIf	
		
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenImp
Abre conexao com a impressora
@param 	nenhum
@author  Varejo
@version P11.8
@since   26/06/2015
@return  lRet - Retorna se abriu conexao com a impressora
/*/
//-------------------------------------------------------------------
Function STWOpenImp()
Local lMobile 		:= STFGetCfg("lMobile", .F.) 	//Versao Mobile
Local lTry				:= .T.								//Controle tentativa
Local aRet 			:= {}  							//Array de retornos
Local lRet 			:= .F.								//Retorno
Local cImpressora 	:= ""                       	//Nome da impressora cadastrada
Local cNomeImpBlu 	:= ""                       	//Nome da impressora bluetooth
Local cBlueTimeout	:= ""                     		//Timeout para impressora bluetooth
Local cPorta 			:= ""                       	//Porta da impressora cadastrada

lMobile := ValType(lMobile) == "L" .AND. lMobile

cImpressora := STFGetStat("IMPFISC")
cNomeImpBlu	:= STFGetStat("TSCSRV",,.F.)
cBlueTimeout:= STFGetStat("TSCPORT")
cPorta  	:= STFGetStat("PORTIF")

If 	!Empty(cImpressora) .AND.;
	(( lMobile  .AND. (!Empty(cNomeImpBlu) .AND. !Empty(cBlueTimeout) ) ) .OR. 	!Empty(cPorta ))//Validacao Mobile
	 
	  	Do While lTry
	  	
	  		aRet :=	STFFireEvent(	ProcName(0)					,;		// Nome do processo LjMsgRun("Aguarde, Abrindo impressora Não Fiscal"
						"STOpenPrintCommunication"					,;		// Nome do evento OpenPrintCommunication
						{cImpressora									,;	
						IIF( !lMobile .AND. !Empty(cPorta), cPorta, ; //Versao desktop
						IIF(lMobile .AND.  cPorta == "BLU", "@", "") + cNomeImpBlu + ":"+ cBlueTimeout ), !lMobile  } )  //Versao Mobile		

			If Len(aRet) == 0 .OR. aRet[1] <> 0 
			
				lTry := FWAlertYesNo( STR0001  + STR0017, STR0018 + cImpressora) // "Tentar novamente" ### "Impressora "
				
				If !lTry
					
					STFMessage("STWOpenDevi", "STOP", STR0001) // "Falha no Comando de Abertura e Selecao da Porta"
					STFShowMessage("STWOpenDevi")
					lRet := .F.
				EndIf
			Else
				lRet := .T.
				lTry := .F.
			EndIf


		EndDo
	

Else
	STFMessage("STWOpenDevi", "STOP", STR0015) // "NFCE - necessário configuação de Imp. Não-Fiscal" 
	STFShowMessage("STWOpenDevi")
EndIf


Return lRet
