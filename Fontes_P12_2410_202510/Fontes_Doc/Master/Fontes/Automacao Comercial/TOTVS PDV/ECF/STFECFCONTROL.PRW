#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "STPOS.CH"

Static lLjxCtImpRD	:= ExistFunc("LjxCtImpRD")
Static lIsRmt64		:= If(ExistFunc("IsRmt64"), IsRmt64(), .F.)
Static cDLLAUTOCOM	:= IIf(lIsRmt64,"AUTOCOM64.DLL","AUTOCOM.DLL")
Static lLinux		:= IIF(!IsBlind(),"LINUX" $ UPPER(GetRmtInfo()[2]),.F.)

//--------------------------------------------------------
// Funcao dumb
//--------------------------------------------------------
Function STBECFCO(); Return

//--------------------------------------------------------
/*{Protheus.doc}STFECFCONTROL
Classe responsavel em manipular o ECF 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	Boolean
@obs     
@sample
*/
//--------------------------------------------------------
Class STFECFCONTROL
	
	Data nHandle
	Data cPort
	Data cModel
	Data cLib
	Data cTypeImp 
	Data cTypeCMC7
	Data cTypeCheck
	Data cTypeBalance
	Data cTypeReader	
	Data lmessage
	Data nTroco
	Data nMoney
	Data nParcel
	Data lValidaID	
	Data oTotvsAPI		
	Data oAutocom
	Data oImpFisc
   Data cCNPJ
   Data cClient
   Data cLojaCli
   Data nImpHnd
   Data nImpHndNfis
   Data nLeitorHnd    //guarda o handle do leitor
   Data cNome
   Data cEnd
   Data lImpCpfNpj
   Data nRet  
   Data lHomTEF  
   Data lImpTk   
   Data nChkAutocom   
   Data nDispHandle    //handle do display  
   Data nDistorHl      //Handle do displau Torre
   Data lFiscal		//Usuário fiscal  
   Data aIsAutocom
   Data nHnd
   Data nCmc7Hnd  
   Data nChckHnd 
   Data nBalcHnd 
   Data lCMC7
   Data lCheck
   Data lBalance  
   Data aPortas
   Data lDrawer

	Method New(lHomTEF, lFisc, nChkAutocom)	
   Method CreateTotvsApi()
   Method GetTotvsApi ()
   Method SetTotvsApi ()  
   Method CreateAutoCom()
   Method GetAutoCom()
   
    //Conversoes
   Method LJStrToArr(cLista)
	Method LJArrToStr( aLista)
	Method LJStr2Array( cString ) 
    Method STFECFCONTROL(lHomTEF, lFisc, nChkAutocom) //Constructor								
	Method ConfigFiscalPrinter(cPort,nHandle,cModel)
	Method CheckIFDate() 
	Method SendSupply( nTroco, nMoney ) 
	Method CheckPaper()
	Method OpenCom( cModel, cPort, lClose )
	Method CloseCom( cPort )
	Method ListPrint( cBuffer, lMostraMsg , lCodECF , lListEcnf)
	Method ListINF(cBuffer, lMostraMsg)
	Method ReadingX()
	Method ReductZ( cBuffer )
	Method DadoReductZ( cBuffer )
	Method OpenReceipt()
	Method GetReceipt( cBuffer, cCancel )
	Method GetSerie( cBuffer )
	Method GetPDV	( cBuffer )
	Method RegItem( 	cCode		, cDescricao, cQtde	,cVlrUnit,;
					 	cVlrDesconto, cAliquota , cTotIt,cUnidMed,;
					  	cTypeTes 								 )
	Method GetAliq( cBuffer )
	Method GetAliIss( cBuffer )
	Method GetConPay( cBuffer )
	Method RecCondPay( cCondicao )
	Method CancelItem( cNumItem, cCode, cDescricao,cQtde,cVlrunit,cVlrdesconto, cAliquota,cSupervisor,lImpIncl )
	Method CancelReceipt( cSupervisor )
	Method CancelBound( cCPFCNPJ, cCliente, cEndereco, cMensagem, cCOOCCD )
	Method CloseReceipt( cMens , nVlrTotal )
	Method Payment( cPagto  , cVinculado , nVlrTotal, cPercepcion , aImpsSL1 )
	Method DescTot( cDesc , cVlrTotal, cTipoCli )
	Method AddTot	( cAcres )
	Method MemFisc( cDataIni, cDataFim,cReducIni,cReducFim,cCheck )
	Method AddAliq( cAliquota, cType )
	Method OpenNotFiscalReceipt( cCondicao, cValue, cTotalizer, cTexto, nParcels )
	Method TxtNotFiscalReceipt( cTexto, nVias )
	Method CloseNotFiscalReceipt()
	Method PrinterStatus( cType, cBuffer )
	Method NotFiscalTotal( cNum, cDescr )
	Method Autentic	( cVezes, cValue, cTexto )
	Method Drawer	()
	Method OpenECF()
	Method CloseECF()
	Method Supply( nTipo, cValue, cPagto , cTotal, nModo, cFormSup )
	Method HourSummerAdjust( cType )
	Method ManagReportPrint( cTexto ,nVias)
	Method SubTotalReceipt( cBuffer, cImprime )
	Method NumItemPrint( cBuffer )
	Method EmulEcf( NumPdv, NumCaixa, NomeCaixa, NumCupom )
	Method SalesOrder( Tef, Texto, Valor, cCondPgTEF )
	Method ReceiveNotFiscal( cTotalizer, nValue, cForma )
	Method DownMFD( cType, cInicio, cFinal )
	Method ExecHsr( cComando,cPosicao)
	Method PinPadList( cBuffer, lMostraMsg )
	Method PinPadOpen( cModel, cPort )
	Method PinPadLeC	( nPinHnd, cModalidade, cBuffer )
	Method PinPadLeS	( nPinHnd, cTrilha2, cMsg, cWork, cStatus )
	Method PinPadFin	( nPinHnd )
	Method CMC7List	( cBuffer, lMostraMsg )
	Method CMC7Open	( cModel, cPort, cMensagem )
	Method CMC7Close	( nCmc7Hnd,cPort )
	Method CMC7ReadD	( nCmc7Hnd,cBuffer )
	Method CMC7ReadDC( nCmc7Hnd,cBuffer )
	Method DrawerList( cBuffer, lMostraMsg )
	Method DrawerOpen( cModel, cPort )
	Method DrawerClose( nGavHnd, cPort )
	Method DrawerAction( nGavHnd, cPort )
	Method DrawerStatus( nGavHnd, cPort )
	Method ListReceiptPrinters( cBuffer, lMostraMsg )
	Method PrintOpenCommunicationReceipt( cModel, cPort )
	Method PrintCloseCommunicationReceipt( nCupHnd, cPort )
	Method PrintNotFiscalReceipt( nCupHnd, cBuffer )
	Method ReaderList( cBuffer, lMostraMsg )
	Method ReaderOpen( cModel, cPort, cFoco )
	Method ReaderClose( nLeitHnd,cPort )
	Method ReaderFocus( lModo )
	Method BalanceList( cBuffer, lMostraMsg )
	Method BalanceOpen( cModel, cPort )
	Method BalanceClose(  cPort )
	Method BalanceGet( cBuffer )
	Method DisplayList( cBuffer, lMostraMsg )
	Method DisplayOpen( cModel, cPort )
	Method DisplayClose( nDisHnd, cPort )
	Method DisplayEnv( nDisHnd, cTexto )
	Method CHOpen	( cModel, cPort )
	Method CHStatus( cType, cBuffer ) 
	Method CHPrints( cBanco, cValue, cFavorec,cCidade, cData, cMensagem, cVerso,cExtenso, cChancela )
	Method ChPrinTrans( cBanco, cValue, cCidade,cData,cAgencia, cConta, cMensagem )
	Method CHClose( cPort )
	Method CHList	( cBuffer, lMostraMsg )
	Method DLLVersionControl( lAutocom, lTotvsApi)
	Method DrawerMoneyOpen(cSaida,cPorta,cTipoImp) 
	Method SelectCountryDevice( cBuffer, lEcf )
	Method ExecDLLRet( nHnd, nMethod, cBuffer )
	Method CodSitef	( cBuffer )
	Method DescSitef	( cBuffer )
	Method PerceptArg( cAliqIVA, cTexto, cValue, aRet)
	Method OpenDNFH( cTypeDoc, cClient, cCabec, cDocOrigem, aRet, cTypeImp, cIdDoc )
	Method CloseDNFH	( aRet)
	Method ReprintsLastDocArg()
	Method PrintLinesReceiptsArg( cTexto, aRet)
	Method MemWork( aRet)
	Method CapacityArg	( aRet)
	Method OpenDebitNote( cBuffer )
	Method RestauOpenReceipt( cMesa, cClient )
	Method RestauRegIt	( cMesa, cCode, cDescricao,cAliquota, cQtde, cVlrUnit, Acres,Desc )
	Method RestauCancIt( cMesa, cCode, cDescricao,cAliquota, cQtde, cVlrUnit, Acres,Desc )	
	Method RestauConfM	( cMesa, Acres, Desc )
	Method RestauPrintCdp	( )
	Method RestauGetCdp	( )
	Method RestauGetTable	( cBuffer )
	Method RestauRepMont	( cType )
	Method RestauLeRegSal	( cMesa )
	Method RestauCloseReceipt	(cPayment, cAcres, cDesc, cMensagem )
	Method RestauFCDiv	( cNumeroCupons, cAcres  , cDesc,cPayment, cValueCliente, cClient )
	Method RestauTrfTable	( cOrigem, cDestino )
	Method RestauTrfItem	( cOrigem , cCode , cDescricao,cAliquota, cQtde   , cVlrUnit, cAcres,cDesc, cDestino )
	Method GerRegTypE( cType, cInicio, cFinal, cBinario )
	Method JoinList	( cBuffer1, cBuffer2, lEcf)
	Method ChkAutocom	()
	Method IsAutocom	( nTipo, cModel)
	Method DispTorList( cBuffer )
	Method DispTorOpe( cModel, cPort )
	Method DispTorClos( nDisTHnd, cPort )
	Method DispTorEnv( nDisTHnd, cTexto )
	Method EcfTamCup( cBuffer )
	Method ExistEquip( nTipo, cModel, lComOk)
	Method TreatStatus( oValor, cType, nRet)
	Method LoadForm( cDados)
	Method TratRedZ( oDadosRedZ)
	Method PrepReport( cDados, nVias)
	Method DscTotaliz( cTotaliz)
	Method PrepMsgPro( cDados)
	Method PrepSupSan( cDados, nVlrTotal)
	Method xPrintFisc ()
	Method OpenPrintCommunication( cModel, cPort )
	Method ClosePrintCommunication( cModel, cPort )
	Method PrintTextNotFiscal( cTexto , lCheckDLL)
	Method ArqMFD	( cDataIni, cDataFim, cCooIni ,cCooFim, cChPriv, cChPubl, cPath,cFile )
	Method GetNf	()
	Method TEFHomol(nComando, cBuffer, nTipo, nVias, nRet, nImpHnd) 
	Method StatDisplay(nValor)
	Method DispTorStat(nValor)       
	Method GetHandle()
	Method SetHandle(nHandle)  
	Method OpenIpPort(nHnd, cIP, cPorta)   
	Method CMC7Use()
	Method BalanceUse()
	Method CheckUse()    
	Method TotvApiOpen()
    Method RetTypePrt() 
    Method GetNFiscTotal()
	Method SystemDirectory() 
	Method MenuFiscReport( cTexto ,nVias, cTotalizer) 
	Method DownMF(cTipo,cDadoIni,cDadoFinal)
	Method PrintBarCode(cCabecalho, cCodBarras, cRodape ,nVias)
	Method RedZData( cBuffer )
	Method IdCliente( cCNPJ, cNome, cEnd)
	Method NFCe_Enviar(oXML, cDoc, cSerie, cChave, cProt)
	Method NFCe_Cancelar(cDoc, cSerie, cChave, cProt, cJust, lOnLine, lInutiliza )
	Method NFCe_OfWs(nTotNFCeOff, nTotCancOff)
	Method NFCe_StCfg(cChave, cValor) 
	Method NFCe_Cfg(cChave, cValor)
	Method NFCe_Imprimir(cXMLEnv, cXMLRec, cUrlQR, nColunas, nTpNFCE)
	Method NFCe_ConsInfo(cInfo, cTipoCons, cInterIni, cInterFim,  cSerie, cChave, cBuffer)
	Method NFCe_Info(cInfo, cDefault)
	Method NFCe_Inutiliz(cInterIni, cInterFim,  cSerie, cJust)
	Method NFCe_ReImprimir(cDoc, cSerie, cChave)
EndClass


//--------------------------------------------------------
/*/{Protheus.doc} CreateTotvsApi
Metodo responsavel em instanciar o objeto LJCTtovsApi 
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	lRetorno - Retorna se executou corretamente
@obs     
@sample
/*/
//--------------------------------------------------------
Method CreateTotvsApi() Class STFECFCONTROL
		
Local lRetorno := .F.		// Retorno da funcao                                      

// Verifico se existe a funcao antes de instaciar a classe
If Self:oTotvsApi == Nil 
	If ExistFunc("LOJA1326")  
		Self:oTotvsApi := LJCTotvsApi():New()
		lRetorno := .T.
	EndIf	
Else
	lRetorno := .T.			
EndIf

Return lRetorno


//--------------------------------------------------------
/*/{Protheus.doc} GetTotvsApi
Metodo responsavel em retornar o objeto oTotvsApi 
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	Objeto - TotvsApi
@obs     
@sample
/*/
//--------------------------------------------------------
Method GetTotvsApi() Class STFECFCONTROL
Return Self:oTotvsApi


//--------------------------------------------------------
/*/{Protheus.doc} SetTotvsApi
Metodo que Atribui valor ao objeto oTotvsApi
@param   	ExpO1 (1 - oObj) - Objeto do tipo TotvsApi
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	Nil
@obs     
@sample
/*/
//--------------------------------------------------------
Method SetTotvsApi(oObj) Class STFECFCONTROL
	Self:oTotvsApi := oObj 
Return Nil


//--------------------------------------------------------
/*/{Protheus.doc} CreateAutoCom()
Metodo responsavel em instanciar o objeto LJCTtovsApi 
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	Boolean
@obs     
@sample
/*/
//--------------------------------------------------------
Method CreateAutoCom() Class STFECFCONTROL     

Local lRet 		   		:= .F.	// Retorno da funcao


If  ValType( Self:oAutocom ) <> "O"


	//Verifica o usuario e Fiscal e se usa LINUX
	If Self:lFiscal .OR. (!Self:lFiscal .AND. GetRemoteType() <> REMOTE_LINUX )        

     	Self:oAutocom := Autocom():New()
		lRet := .T.	

	EndIf
Else 
		lRet := .T.
EndIf                        

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} GetAutoCom
Metodo responsavel em retornar o objeto oAutoCom 
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	Objeto Autocom
@obs     
@sample
/*/
//--------------------------------------------------------
Method GetAutoCom() Class STFECFCONTROL
Return Self:oAutoCom

 
//--------------------------------------------------------
/*/{Protheus.doc} STFECFCONTROL
Metodo construtor
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	02/05/2012
@return  	Self
@obs     
@sample
/*/
//--------------------------------------------------------
Method STFECFCONTROL(lHomTEF, lFisc, nChkAutocom) Class STFECFCONTROL	

Default lHomTEF 		:= .F.   
Default lFisc 		:= .F.
nChkAutocom := 1

Return Self:New(lHomTEF, lFisc, 1)     


//--------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor New
@param   	
@author  	Varejo
@version 	P11.8
@since   	02/05/2012
@return  	Self
@obs     
@sample
/*/
//--------------------------------------------------------
Method New(lHomTEF, lFisc, nChkAutocom) Class STFECFCONTROL 

If Self:nImpHnd == NIL
	Self:nImpHnd := -1
EndIf	

If Self:nImpHndNfis == NIL
	Self:nImpHndNfis := -1
EndIf

If Self:nLeitorHnd == NIL
	Self:nLeitorHnd := -1
EndIf	

If Self:lHomTEF == NIL
	Self:lHomTEF := lHomTEF 
EndIf
						 	
If Self:lImpTk == NIL
	Self:lImpTk  := .T.
EndIf  

If Self:lFiscal == NIL
	Self:lFiscal := lFisc
EndIf

If Self:nChkAutocom == NIL
	Self:nChkAutocom := nChkAutocom
EndIf
    
If Self:nHnd == NIL
	Self:nHnd	:= -1 
EndIf

If Self:nCmc7Hnd   == nil
	Self:nCmc7Hnd := -1
EndIf 

If Self:nChckHnd == nil
   Self:nChckHnd := -1
EndIf  

If Self:nBalcHnd == NIL
	Self:nBalcHnd := -1
EndIf   

If Self:lCMC7 == NIL
	Self:lCMC7 := .F. 
EndIf

If Self:lCheck == NIL
	Self:lCheck := .F.
EndIf

If Self:lBalance == NIL
	Self:lBalance := .F.
EndIf 

If Self:lDrawer == NIL
	Self:lDrawer := .F.
EndIf

If Self:aPortas == NIL
	Self:aPortas := {}
EndIf

Return Self
 
 
//--------------------------------------------------------
/*/{Protheus.doc} OpenCom
Abre a comunicacao com a impressora
@param   	ExpO1 (1 - cModel) - Variável String / Exp02 (2 - cPort) - Variavel String
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	Nil
@obs     	Abre a comunicacao com a impressora
@sample
/*/
//--------------------------------------------------------              
Method OpenCom( cModel, cPort, lClose ) Class STFECFCONTROL

Local nRet		:= -1			// Retorno da Method
Local lComOk		:= .F.			// Controla se abriu comunicacao com a totvsapi
Local nHdlMain	:= 0			// Handle do objeto da tela do protheus
Local lContinua 	:= .T.			// Controle processo
Local oHdlMain 	:= Nil			// Objeto da janela 
Local oRet		:= Nil			// Objeto de retorno
Local oTotvsApi	:= Self:GetTotvsApi() //Objeto Totvs API
Local lRet		:= .F.   		// Retorno 
Local lEquipOpen	:= aScan(Self:aPortas, {|e| e[1] == cModel .AND. e[2] == cPort}) > 0	// Abre Equipamento

Default cModel 	:= ""
Default cPort 	:= ""   
DEFAULT lClose	:= .T.   

oHdlMain := GetWndDefault()
nHdlMain := 0

If !Empty( cModel ) .AND. !Empty( cPort )
	If ValType(oTotvsApi) <> "O"   
		If Self:CreateTotvsApi()
			oTotvsApi := Self:GetTotvsApi()
			lRet := .T.
		EndIf
	Else 
		lRet := .T.
	EndIf
	
	If lRet
		If Self:ExistEquip(EQUIP_IMPFISCAL, cModel, @lComOk)
			If lComOk .AND. !lEquipOpen  				
				ConOut("AbrirPorta " + cModel+ " " + Time())
				oRet := Self:oImpFisc:AbrirPorta(cModel, cPort, oTotvsApi)
				Self:cTypeImp := "TOTVSAPI"
				ConOut("AbrirPorta " + cModel+ " Fim " + Time())
				If oRet:lRetorno
					nRet := 0 
				ElseIf lClose
					Self:oImpFisc := Nil
					FreeObj(oTotvsApi := oTotvsApi)
					Self:SetTotvsApi(NIL)
					FreeObj(oRet)
				EndIf
			Else
		      If lEquipOpen
					Self:cTypeImp := "TOTVSAPI" 
					nRet := 0
               	EndIf                                    
			EndIf
			lContinua := .F.
		EndIf
	EndIf

If Self:CreateAutoCom()
		
		// Pesquisa se o modelo do equipamento existe na AUTOCOM                         
		// Caso houver equipamento homologado nas duas DLLs, a prioridade sera a AUTOCOM. 
		If Self:IsAutocom( EQUIP_IMPFISCAL, cModel ) == EQUIP_DLL_AUTOCOM  .AND. lContinua
			If !lEquipOpen
				nRet := Self:oAutocom:IFAbrir( cModel, cPort, nHdlMain )
			Else
				nRet := 0
			EndIF
			lContinua := .F.
			Self:cTypeImp := "EQUIP_DLL_AUTOCOM"
		Else
			If Self:IsAutocom( EQUIP_IMPFISCAL, cModel ) == EQUIP_DLL_SIGALOJA  .AND. lContinua
				Self:aIsAutocom[ EQUIP_IMPFISCAL ] := EQUIP_DLL_SIGALOJA
				STWCheckDLL( .T. )								// Verifica se a SIGALOJA.DLL esta aberta
				If !lEquipOpen
					nRet := ExeDLLRun2(Self:nHnd, 0, cModel + "," + cPort + "," + AllTrim( Str( nHdlMain ) ) )
				Else
					nRet := 0
				EndIf
				lContinua := .F.
				Self:cTypeImp := "EQUIP_DLL_SIGALOJA"
			EndIf
		EndIf
	EndIf
 
	If lContinua                 
		STWCheckDLL( .T. )									// Verifica se a SIGALOJA.DLL esta aberta
		If !lEquipOpen					
			nRet := ExeDLLRun2(Self:nHnd, 0, cModel +","+ cPort + "," + AllTrim( Str( nHdlMain ) ) )
		Else
			nRet := 0
		EndIf
		Self:cTypeImp := "DLL_SIGALOJA"
	EndIf
EndIf


//Determina retorno do Handle de comunicacao da Impressora ao Conectar
Self:nImpHnd := nRet

If nRet > -1
	aAdd(Self:aPortas, { cModel, cPort}) 
ElseIf lClose	
	Self:lFiscal := .F.
EndIf

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} CheckIFDate 
Verifica se a data do sistema eh a mesma data da impressora fiscal.
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	nRet - Retorno do ECF
@obs     	Verifica se a data do sistema eh a mesma data da impressora fiscal.
@sample
/*/
//--------------------------------------------------------              
Method CheckIFDate() Class STFECFCONTROL

Local nRet	    	:= 0		// Retorno do Method da dll
Local cRetorno		:= ""		// Retorno do ECF
 
nRet := Self:PrinterStatus('19', @cRetorno )

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} SendSupply 
Verifica troco e envia suprimento para Impressora Bematech.

@param   	nTroco = Valor do Troco a ser pago ao cliente
@param		nMoney = Valor em Dinheiro pago pelo cliente
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	lRet - Retorna se executou corretamente
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------              
Method SendSupply( nTroco, nMoney ) Class STFECFCONTROL

Local nRet			:= -1			// Retorno da Method da dll
Local lRet		 	:= .T.			// Variavel de controle

Default nTroco := 0
Default nMoney := 0


If nTroco > 0 .AND. Empty( nMoney )	
	
	//Verifica se existe suprimento na impressora 
	nRet := Self:Supply( nHdlECF, 1, Str( nTroco, 14, 2 ) )  
	
Endif

Return lRet 


//--------------------------------------------------------
/*/{Protheus.doc} CheckPaper 
Verifica o Status do Papel na impressora Bematech.
@param   	nTroco = Valor do Troco a ser pago ao cliente
@param		nMoney = Valor em Dinheiro pago pelo cliente
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	nRet - Retorno do ECF
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------              
Method CheckPaper() Class STFECFCONTROL

Local nRet 			:= 0                     // Retorno da Impressora 2- Pouco Papel 3- Sem Papel
Local cRet 			:= Space( 1 )					// Retorno do ECF

nRet := Self:PrinterStatus( '3', @cRet ) 		//Verificar

Return nRet


//--------------------------------------------------------
/*/{Protheus.doc} CloseCom 
Fecha comunicacao com a impressora 
@param 		XPc1 - Informa a porta que esta sendo usada
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------              
Method CloseCom( cPort ) Class STFECFCONTROL

Local nRet 		:= -1		// Retorno da Method da dll     
Local oRet 		:= NIL		// Objeto de retorno
Local nPosPort 	:= aScan(Self:aPortas, {|e|  e[2] == cPort})	//Posicao da porta    

Do Case
	
	Case lLinux
		nRet := ExeDLLRun2(Self:nHnd, 132, "0" + "," + cPort)
	Case nPosPort = 0
		nRet := 0
	Case Self:cTypeImp == "TOTVSAPI" 
		If ValType(Self:oImpFisc) == "O" 
			
			oRet := Self:oImpFisc:FechaPorta(cPort)  
			Self:oImpFisc:oECF:oTotvsApi:FecharCom()
		  
			FreeObj(Self:oImpFisc) 
			Self:oImpFisc:= NIL   
			
			If oRet:lRetorno
				nRet := 0
			EndIf
	        FreeObj(oRet)
				
	    EndIf
	    

	
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 1, Str( Self:nImpHnd ) + "," + cPort )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFFechar( cPort )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 1, Str( Self:nImpHnd ) + "," + cPort )

EndCase 

If nPosPort > 0 
	aDel(Self:aPortas, nPosPort)
	aSize(Self:aPortas, Len(Self:aPortas) -1)
EndIf

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} ListPrint 
Lista os ECF's homologados pela sigaloja / autocom 
@param   	EXPc1 - Armazena os perifericos que serao listados  
@param 		EXPl1 - Indica se mostrara a mensagem
@param 		lListEcnf , Lista impressoras nao fiscais  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ListPrint( cBuffer, lMostraMsg, lCodECF , lListEcnf ) Class STFECFCONTROL

Local nRet 		:= -1   				// Retorno da Method da dll
Local cBuffer1 	:= Space( 7000 )		// Armazena a lista da Sigaloja
Local cBuffer2 	:= Space( 5000 )		// Aramzena a lista da Autocom
Local cBuffer4	:= Space( 7000 )		//Armazena Impressoras Nao Fiscais da Sigaloja
Local nCount 		:= 0    				// Variavel de controle contador
Local cBuffer3 	:= ""					// Buffer
Local oRet		:= NIL					// Objeto de retorno
Local oTotvsApi	:= Self:GetTotvsApi()// Objeto totvs API    
Local lRet 		:= .F.					// Retorno

DEFAULT lCodECF := .F.
Default lListEcnf	:= .F.   

If ValType(oTotvsApi) <> "O"
	If Self:CreateTotvsApi()
		oTotvsApi := Self:GetTotvsApi() 
		lRet := .T.
	EndIf  
Else
	lRet := .T.
EndIf

//³Lista impressoras não fiscais para faturamento, paises localizados e NFC-e ³
If (nModulo == 5 .OR. nModulo == 51)
	lListEcnf := .T.
EndIf

If lRet  	
	
	oRet := oTotvsApi:ListarEcNf()			
	For nCount := 1 To oRet:Count()
		cBuffer3 += '"' + oRet:Elements(nCount):cDescricao + '",' + oRet:Elements(nCount):cPais + ',"' + oRet:Elements(nCount):cCodEcf + '",'
	Next
	
	If !lListEcnf
		oRet := oTotvsApi:ListarEcf()
	
		For nCount := 1 To oRet:Count()
			cBuffer3 += '"' + oRet:Elements(nCount):cDescricao + '",' + oRet:Elements(nCount):cPais + ',' + oRet:Elements(nCount):cCodEcf + ','
		Next		
	EndIf
	
	nRet := 0
EndIf

If !lListEcnf
	nRet := Self:ExecDLLRet(Self:nHnd, 2, @cBuffer1 )	
EndIf

nRet		:= Self:ExecDLLRet(Self:nHnd, 130, @cBuffer4 )
If Substr(AllTrim(cBuffer1), Len(AllTrim(cBuffer1)), 1) == ','
	cBuffer1 += cBuffer4		
Else	
	If Empty(cBuffer1)
		cBuffer1 := cBuffer4
	Else 
		cBuffer1 += ',' + cBuffer4
	EndIf	
EndIf

//Chama o metodo para instanciar o objeto oAutocom  
If !lListEcnf
	If Self:CreateAutoCom()
		If GetRemoteType() == REMOTE_LINUX .AND. File( GetClientDir() + "libautocom.so" )
			nRet := Self:oAutocom:IFListar()
			cBuffer2 := Self:oAutocom:cBuffer
		Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File( GetClientDir() + cDLLAUTOCOM )
			nRet := Self:oAutocom:IFListar()
			cBuffer2 := Self:oAutocom:cBuffer	
		Endif
	Endif
EndIf

If nRet == 0
	If Empty(cBuffer1) .OR. nModulo == 5 .OR. nModulo == 51
		cBuffer1 := cBuffer3 	
	Else
		If Substr(AllTrim(cBuffer1), Len(AllTrim(cBuffer1)), 1) == ','
			cBuffer1 += cBuffer3		
		Else
			cBuffer1 += ',' + cBuffer3
		EndIf
	EndIf
	cBuffer := Self:JoinList( cBuffer1, cBuffer2, .T., lCodECF )		// Junta as listas da SIGALOJA e da AUTOCOM  
EndIf

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc} ListINF 
Lista as impressoras não fiscais homologadas na Sigaloja/Autocom
@param   	EXPc1 - Armazena os perifericos que serao listados  
@param 		EXPl1 - Indica se mostrara a mensagem 
@author  	Varejo
@version 	P11.8
@since   	19/03/2015
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ListINF(cBuffer, lMostraMsg)  Class STFECFCONTROL
Local nRet	:= 0
Local cLista:= Space(7000)

nRet := Self:ExecDLLRet(Self:nHnd, 130, @cLista )

cBuffer := AllTrim(cLista)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} ReadingX
Realiza a leitura X
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ReadingX() Class STFECFCONTROL

Local nRet 		:= -1         			// Retorno da Method da dll
Local oRet		:= Nil						// Objeto retorno

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI" 
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:LeituraX()
			If oRet:lRetorno
				nRet := 0
			EndIf
		EndIf

	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFLeituraX()
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 3, Str( Self:nImpHnd ) )

    Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 3, Str( Self:nImpHnd ) )

EndCase
			
Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} ReductZ
Emite Reducao Z
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ReductZ( cBuffer ) Class STFECFCONTROL

Local nRet 		:= -1  			// Retorno da Method da dll                                                                              
Local cMapaRes 	:= cBuffer			// Retorno com o conteudo gerado na reducao z para o mapa resumo
Local oRet		:= NIL				// Objeto retorno

Default cBuffer := ""

cBuffer := Str( Self:nImpHnd )+ "," + cBuffer			// Envia um buffer e já prepara o recebimento

Do Case 
	
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:ReducaoZ()
			If oRet:lRetorno
				oRet := Self:oImpFisc:DadosRedZ()
				If oRet:lRetorno
					cBuffer := Self:TratRedZ(oRet:oRetorno)
					nRet = 0
				EndIf
			EndIf
			FreeObj(oRet)
		EndIf
	
	Case Self:cTypeImp == "DLL_SIGALOJA"	
		cBuffer := Str( Self:nImpHnd )+ "," + cBuffer	// Envia um buffer e já prepara o recebimento
		nRet := Self:ExecDLLRet(Self:nHnd, 4, @cBuffer )

	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFReducaoZ( cMapaRes )
		cBuffer := Self:oAutocom:cBuffer

    Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 4, @cBuffer )

EndCase

Return nRet 

//--------------------------------------------------------
/*/{Protheus.doc} DadoReductZ
Retorna dados da ultima Reducao Z
@author  	Varejo
@version 	P11.8
@since   	28/12/2016
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
/*/
//--------------------------------------------------------
Method DadoReductZ( cBuffer ) Class STFECFCONTROL

Local nRet 	:= -1  			// Retorno da Method da dll                                                                              

Default cBuffer := ""

cBuffer := Str( Self:nImpHnd )+ "," + cBuffer			// Envia um buffer e já prepara o recebimento

Do Case 
	/* Opcao nao compativel com TOTVSAPI e AUTOCOM */
	
	Case Self:cTypeImp == "DLL_SIGALOJA"	
		cBuffer := Str( Self:nImpHnd )+ "," + cBuffer	// Envia um buffer e já prepara o recebimento
		nRet := Self:ExecDLLRet(Self:nHnd, 129, @cBuffer )

    Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 129, @cBuffer )

EndCase

Return nRet 




//--------------------------------------------------------
/*/{Protheus.doc} OpenReceipt
Abre o cupom fiscal
@param1		cCNPJ - Indica o cliente do cupom fiscal
@param2		cNome - Nome
@param3		cEnd - Endereco
@param4		cMensagem - Mensagem do cupom fiscal
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample  	Nil
/*/
//--------------------------------------------------------
Method OpenReceipt( cCNPJ, cNome, cEnd, cMensagem	) Class STFECFCONTROL

Local nRet 			:= -1   					// Retorno da Method da dll
Local oRet			:= NIL						// Objeto retorno

Default cCNPJ    	:= ""	   					
Default cNome		:= ""
Default cEnd			:= ""
Default cMensagem   := ""

//Remove as ',' para evitar que seja interpretado pela DLL como outro parâmetro
//Igual a função IfAbreCup() do LojxEcf.prw
cEnd := StrTran(cEnd,","," ")
cNome:= StrTran(cNome,","," ")

Do Case

	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:AbrirCF(cCNPJ, cNome, cEnd)
			If oRet:lRetorno
				nRet := 0
				cBuffer := oRet:oRetorno
			EndIf 
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 5, Str( Self:nImpHnd )+ "," + cCNPJ + "|" + cNome + "|" + cEnd + "," + cMensagem )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFAbreCup( cCNPJ + "|" + cNome + "|" + cEnd )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 5, Str( Self:nImpHnd )+ "," + cCNPJ + "|" + cNome + "|" + cEnd + "," + cMensagem )

EndCase

Return nRet


//--------------------------------------------------------
/*/{Protheus.doc} IdCliente
Abre o cupom fiscal
@param1		cCNPJ - Indica o cliente do cupom fiscal
@param2		cNome - Nome
@param3		cEnd - Endereco
@author  	Varejo
@version 	P11.8
@since   	06/04/2016
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample  	Nil
/*/
//--------------------------------------------------------
Method IdCliente( cCNPJ, cNome, cEnd)  Class STFECFCONTROL

Local nRet 			:= -1   					// Retorno da Method da dll
Local oRet			:= NIL						// Objeto retorno

Default cCNPJ    	:= ""	   					
Default cNome		:= ""
Default cEnd		:= ""

Do Case
	Case Self:cTypeImp == "TOTVSAPI"
		nRet := 0
		
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:IdCliente(cCNPJ, cNome, cEnd)
			If oRet:lRetorno
				nRet	:= 0
				cBuffer := oRet:oRetorno
			EndIf 
			FreeObj(oRet)
		EndIf		
		
	Case Self:cTypeImp == "DLL_SIGALOJA" .Or. Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet( Self:nHnd, 127, Str(Self:nImpHnd) + "," + cCNPJ + "," + cNome + "," + cEnd )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := 0
EndCase

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc} GetReceipt
Lista os perifericos homologados pela sigaloja / autocom
@param1		EXPc1 - Retorna o numero do cupom fiscal
@param2		EXPc2 - Indica se ha o cancelamento do cupom fiscal
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method GetReceipt( cBuffer, cCancel ) Class STFECFCONTROL

Local nRet 		:= -1										// Retorno da Method da dll
Local cBuffTmp 	:= ""							 			// Variavel auxiliar
Local nVezes		:= 0							 			// Numero de tentativas para envio do comando
Local oRet		:= NIL										// Objeto de retorno

Default cCancel := "F"							   			// Indica se havera cancelamento
Default cBuffer := ""

cBuffer := Str( Self:nImpHnd )+ "," + cCancel + "," + cBuffer	// Envia um buffer e já prepara o recebimento

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:Cupom()
			If oRet:lRetorno
				nRet := 0
				cBuffer := oRet:oRetorno
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"
	
		cBuffTmp := cBuffer
		nRet := Self:ExecDLLRet(Self:nHnd, 6, @cBuffer )


		// Faz um tratamento para repetir se o numero retornar em branco.      
		// Verificamos que para alguns ECFs o numero volta em branco (intermi-  
		// tente) devido a alguma falha de hardware. 
		nVezes := 3
		While nRet == 0 .AND. Empty( cBuffer ) .AND. nVezes > 0
			Sleep( 500 )
			cBuffer := cBuffTmp
			nRet := Self:ExecDLLRet(Self:nHnd, 6, @cBuffer )
			nVezes --
		End
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFPegCupom( cCancel )
		cBuffer := Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 6, @cBuffer )

EndCase

// Algumas impressoras retornam o numero com espacos a esquerda
cBuffer := Padl( AllTrim( cBuffer ),STBLenReceipt(cBuffer), "0" )

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} GetSerie
Captura o numero de serie do ECF
@param1		EXPc1 - Retorna o numero de serie do cupom fiscal
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method GetSerie( cBuffer ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll 
Local oRet	:= NIL
    
//Pega o numero de serie completo da ECF
cBuffer := cValToChar( Self:nImpHnd ) + ","
cBuffer += Space(20 - Len(cBuffer))

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"

		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NumSerie()
			If oRet:lRetorno
				nRet := 0
				cBuffer := oRet:oRetorno
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 36, @cBuffer )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFPegSerie()
		cBuffer := Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 36, @cBuffer )

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} GetPDV
Captura o numero de serie do ECF
@param1		EXPc1 - Retorna o numero do PDV
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method GetPDV( cBuffer ) Class STFECFCONTROL   

Local nRet		 	:= -1		// Retorno da Method da dll
Local cRetorno 		:= " "		// Retorna o numero do PDV
Local oRet			:= NIL		// Objeto de retorno

If Self:PrinterStatus( '11', @cRetorno ) == 0			// eh um Emulador
	cBuffer := cEstacao
	nRet := 0
	Return
EndIf

cBuffer := Str( Self:nImpHnd ) + "," + cBuffer		// Envia um buffer e já prepara o recebimento

Do Case

	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NumeroEcf()
			If oRet:lRetorno
				nRet := 0
				cBuffer := oRet:oRetorno
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 7, @cBuffer )

	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFPegPDV()
		cBuffer := Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		cBuffer := Str( Self:nImpHnd )+ "," + cBuffer	
		nRet := Self:ExecDLLRet(Self:nHnd, 7, @cBuffer )

EndCase

Return nRet 

//--------------------------------------------------------
/*/{Protheus.doc} RegItem
Faz o registros dos itens no cupom fiscal
@param1      EXPc1 - Codigo do Produto                              
@param2      EXPc2 - Descricao do Produto                            
@param3      EXPc3 - Quantidade do Produto                           
@param4      EXPc4 - Valor Unitario o do PDV                           
@param5      EXPc5 - Valor do Desconto                                
@param6      EXPc6 - Aliquota de Imposto do Item                     
@param7      EXPc7 - Total do item                                
@param8      EXPc8 - Unidade de medida do item  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RegItem( 	cCode			, 	cDescricao, cQtde		, cVlrUnit,;
					cVlrDesconto	, 	cAliquota , cTotIt		, cUnidMed,;
					cTypeTes 								   	) Class STFECFCONTROL
					
Local nRet       := -1		// Retorno da Method da dll
Local cBuffer    := ""		// Armazena os paramentros do registro do item
Local oRet		 := Nil	// Retorno

Default cCode			:= ""		// Codigo			
Default cDescricao 		:= ""		// Descricao
Default cQtde			:= ""		// Quantidade		
Default cVlrUnit		:= ""		// Valor Unitario
Default cVlrDesconto	:= ""		// Valor desconto
Default cAliquota 		:= ""		// 	Aliquota 
Default cTotIt   		:= Alltrim(Str(Val(cQtde) * Val(cVlrUnit),14,TamSx3("L2_VLRITEM")[2]))	// Faz o calculo do total do item
Default cUnidMed 		:= " "		// Unidade de medida utilizada na venda
Default cTypeTes 		:= "2"		// tipo de TES


//Se o Campo TES estiver em Branco assume "2" Como Padrao
If Empty(cTypeTes)
	cTypeTes := "2"
Endif

// Caracteres invalidos, não aceitos por diversas impressoras fiscais no campo descricao
cDescricao := StrTran( cDescricao, ",", "." )
cDescricao := StrTran( cDescricao, "'", "." )
cDescricao := StrTran( cDescricao, '"', "." )
cDescricao := StrTran( cDescricao, "&", "." )
cDescricao := StrTran( cDescricao, "|", "." )

cBuffer := Str( Self:nImpHnd )+ "," + cBuffer // Envia um buffer e já prepara o recebimento

Do Case

	Case Self:cTypeImp == "TOTVSAPI"
		If !Empty(cCode) .AND. !Empty(cDescricao) .AND. !Empty(cQtde) .AND. !Empty(cVlrUnit)
			oRet := Self:oImpFisc:VenderItem(	cCode		, cDescricao	, cAliquota			, Val(Substr(cAliquota, 2 ,5))	, ;
												Val(cQtde)	, Val(cVlrUnit)	, Val(cVlrDesconto)	, Nil							, ;
												cUnidMed 	)
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		Else
			If Val(cVlrDesconto) > 0
				oRet :=	Self:oImpFisc:DescItem(Val(cVlrDesconto))
				If oRet:lRetorno
					nRet := 0
				EndIf  
				FreeObj(oRet)
			Else
				nRet := 0
			EndIf
		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"
		cBuffer    := Str( Self:nImpHnd ) + "," + cCode + "," + cDescricao + "," + cQtde + "," + cVlrUnit + "," + cVlrDesconto + "," + cAliquota + "," + cTotIt + "," + cUnidMed + "," + cTypeTes
		nRet := ExeDLLRun2(Self:nHnd, 8, cBuffer )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFRegItem( cCode, cDescricao, cQtde, cVlrUnit, cVlrDesconto, cAliquota, cTotIt, cUnidMed )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		cBuffer    := Str( Self:nImpHnd ) + "," + cCode + "," + cDescricao + "," + cQtde + "," + cVlrUnit + "," + cVlrDesconto + "," + cAliquota + "," + cTotIt + "," + cUnidMed + "," + cTypeTes
		nRet := ExeDLLRun2(Self:nHnd, 8, cBuffer )

EndCase
	
Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} GetAliq
Faz a captura das aliquotas de ICMS do ECF 
@param1		EXPc1 - Retorna as aliquotas do ECF
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------	
Method GetAliq( cBuffer ) Class STFECFCONTROL  

Local nRet 	:= -1      	// Retorno da Method da dll
Local nCount 	:= 0			// Variavel de controle contador           
Local oRet	:= NIL			// Objeto retorno

Default cBuffer			:= ""		// Buffer

cBuffer := Str( Self:nImpHnd ) + "," + cBuffer			// Envia um buffer e já prepara o recebimento

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:Aliquotas()
			If oRet:lRetorno
				nRet := 0
				For nCount := 1 To oRet:oRetorno:Count()
					If !oRet:oRetorno:Elements(nCount):lIss
//						cBuffer += AllTrim(StrTran(TransForm(oRet:oRetorno:Elements(nCount):nAliquota, "@E 99.99"), "," , ".")) + "|"
						cBuffer += AllTrim(TransForm(oRet:oRetorno:Elements(nCount):nAliquota, "@R 99.99")) + "|"

					EndIf
				Next
			EndIf

		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 9, @cBuffer )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFLeAliq()
		cBuffer := Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 9, @cBuffer )

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} GetAliIss
Faz a captura das aliquotas de ISS do ECF 
@param		EXPc1 - Retorna as aliquotas do ECF 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------	
Method GetAliIss( cBuffer ) Class STFECFCONTROL  

Local nRet := -1				// Retorno da Method da dll
Local nCount 	:= 0			//Variavel de controle contador   
Local oRet		:= NIL		// Objeto retorno

Default cBuffer			:= ""		// Buffer

cBuffer := Str( Self:nImpHnd ) + "," + cBuffer			// Envia um buffer e já prepara o recebimento

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		oRet := Self:oImpFisc:Aliquotas()
		If oRet:lRetorno
			nRet := 0
			For nCount := 1 To oRet:oRetorno:Count()
				If oRet:oRetorno:Elements(nCount):lIss
//					cBuffer += AllTrim(StrTran(TransForm(oRet:oRetorno:Elements(nCount):nAliquota, "@E 99.99"), "," , ".")) + "|"
					cBuffer += AllTrim(TransForm(oRet:oRetorno:Elements(nCount):nAliquota, "@R 99.99")) + "|"

				EndIf
			Next
		EndIf
	
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 10, @cBuffer )

	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFLeAliIss()
		cBuffer := Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA
		nRet := Self:ExecDLLRet(Self:nHnd, 10, @cBuffer )

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} GetConPay
Faz a captura das formas de pagamento do ECF 
@param		EXPc1 - Retorna as formas de pagto. do ECF  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------	
Method GetConPay( cBuffer ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll
Local nCount := 0		//contador das formas
Local oRet := NIL
Default cBuffer			:= ""		// Buffer 


cBuffer := Str( Self:nImpHnd ) + "," + cBuffer					// Envia um buffer e já prepara o recebimento


Do Case
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil			
			cBuffer := ""
			oRet := Self:oImpFisc:Formas()
			If oRet:lRetorno
				For nCount := 1 To oRet:oRetorno:Count()
					If !Empty(oRet:oRetorno:Elements(nCount):cForma)
						cBuffer += AllTrim(oRet:oRetorno:Elements(nCount):cForma) + "|"
					EndIf
				Next  
		
				nRet := 0
			EndIf
		EndIf


	Case Self:cTypeImp == "DLL_SIGALOJA"
   		nRet := Self:ExecDLLRet(Self:nHnd, 11, @cBuffer )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM
		nRet := Self:oAutocom:IFLeConPag()
		cBuffer := Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA
		nRet := Self:ExecDLLRet(Self:nHnd, 11, @cBuffer )

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} RecCondPay
Faz a gravacao das formas de pagamento do ECF 
@param		EXPc1 - Armazena a condicao que sera gravada no ECF   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RecCondPay( cCondicao ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll

Default cCondicao			:= ""		

Do Case     
    
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:ConfigPgto(cCondicao )
			If oRet:lRetorno
				nRet := 0
			EndIf
		EndIf


	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 12, Str( Self:nImpHnd ) + "," + cCondicao )

	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFGrvCondP( cCondicao )

	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 12, Str( Self:nImpHnd ) + "," + cCondicao )

EndCase

Return nRet
             

//--------------------------------------------------------
/*/{Protheus.doc} CancelItem
Realiza o cancelamento do item registrado   
@param   EXPn1 - Handle de uso da DLL                               
@param   EXPc1 - Numero do item                                    
@param   EXPc2 - Codigo do item                                    
@param   EXPc3 - Descricao do item                                 
@param   EXPc4 - Quantidade do item                               
@param   EXPc5 - Valor do Unitario do item                         
@param   EXPc6 - Valor do desconto do item                         
@param   EXPc7 - Aliquota do item    
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CancelItem( 	cNumItem		, cCode			, cDescricao		,;
				 		cQtde			,cVlrunit			, cVlrdesconto	, cAliquota ,;
				 		cSupervisor 	,lImpIncl 												) Class STFECFCONTROL
				 		
					 
Local nRet 	:= -1		// Retorno da Method da dll 
Local oRet	:= NIL		// Objeto retorno

Default cNumItem			:= ""		// Numero item			
Default cCode			:= ""		// Codigo
Default cDescricao     := ""		// Descricao		
Default cQtde			:= ""		// Quantidade
Default cVlrunit			:= ""		// Valor Unitario
Default cVlrdesconto	:= ""		// Desconto 
Default cAliquota		:= ""		// Aliquota 
Default cSupervisor 	:= NIL
Default lImpIncl    	:= .T.

Do Case

	Case Self:cTypeImp == "TOTVSAPI"
		oRet := Self:oImpFisc:CancItem(cNumItem		, cCode		, cDescricao		,  Substr(cAliquota, 1 ,1)	, Val(Substr(cAliquota, 2 ,5))	, ;
								  Val(cQtde)	, Val(cVlrUnit)	, Val(cVlrDesconto)	, Nil)
		If oRet:lRetorno
			nRet := 0
		EndIf
		FreeObj(oRet)
	Case Self:cTypeImp == "DLL_SIGALOJA			
		nRet := ExeDLLRun2(Self:nHnd, 13, Str( Self:nImpHnd ) + "," + cNumItem + "," + cCode + "," + cDescricao + "," + cQtde + "," + cVlrunit + "," + cVlrdesconto + "," + cAliquota )
			
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFCancItem( cNumItem, cCode, cDescricao, cQtde, cVlrunit, cVlrdesconto, cAliquota, cSupervisor, lImpIncl)
		
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 13, Str( Self:nImpHnd ) + "," + cNumItem + "," + cCode + "," + cDescricao + "," + cQtde + "," + cVlrunit + "," + cVlrdesconto + "," + cAliquota )

EndCase

Return nRet


//--------------------------------------------------------
/*/{Protheus.doc}CancelReceipt
Faz o cancelamento do cupom fiscal   
@param   	EXPc1 - Codigo do supervisor
@param   	EXPn1 - Numero retorno
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CancelReceipt( cSupervisor, nRet ) Class STFECFCONTROL

Local oRet := NIL	//Objeto retorno

Default cSupervisor := ""	// Armazena Supervisor
Default nRet		:= -1		// Retorno

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:CancelaCF()
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 14, Str( Self:nImpHnd ) + "," + cSupervisor )
	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFCancCup(cSupervisor)
	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 14, Str( Self:nImpHnd ) + "," + cSupervisor )

EndCase

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc}CloseReceipt
Faz o fechamento do cupom fiscal  
@param1   	EXPc1 - Mensagem do fechamento do cupom
@param2   	EXPn1 - Valor
@param3   	EXPc1 - Arquivo 
  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CloseReceipt( cMens , nVlrTotal, cArquivo ) Class STFECFCONTROL 

Local nRet		:= -1											// Retorno da Method da dll
Local cBuffer		:= ""											// Armazena o comando de fechamento
Local cRetorno	:= " "											// Verifia se e' ECF ou Emulator
Local nHandle		:= 0											// Handle do cArquivo
Local cSalvBuff	:= ""											// Buffer
Local cVlrTotal 	:= ""											// Valor total da venda em caracter
Local oRet		:= NIL											// Objeto Retorno
Local oMsg		:= NIL											// Mensagem
Local oTEF		:= STBGetTEF() 							//Captura o Objeto TEF
Local lTravaTecl := ValType(oTEF) == "O" .AND. oTEF:IsAtivo() .AND. Valtype(oTEF:oConfig:oCfgTef) == "O" .AND.  !oTEF:oConfig:oCfgTef:SiTefHb(oTEF:oConfig:oCfgTef)//travar teclado
Local aTotaisImp := {0,0,0,0}	 
Local lCpoImpEnt :=	SL2->(ColumnPos("L2_TOTFED")) > 0 .AND. ;
					SL2->(ColumnPos("L2_TOTEST")) > 0 .AND. ;
					SL2->(ColumnPos("L2_TOTMUN")) > 0 // Verifica a existencia do campo de Total de Imposto NCM/NBS

Default cMens		:= ""
Default nVlrTotal   := 0    
Default cArquivo		:= ""

                                                             //trava teclado
cVlrTotal	:= cValToChar(nVlrTotal)

//Lei dos impostos
If ExistFunc('STBSumImp') .AND. ExistFunc('Lj950ImpNC')
	If !lCpoImpEnt	
		aTotaisImp[1] := STBSumImp()
	Else
		aTotaisImp := STBSumImp()
	EndIf
											//	Lj950ImpNC(nVlrTotal,nTotaImp     ,nDecimais,                    lNFCe   , ;
											//  nTotImpFED   ,nTotImpEST   ,nTotImpMUN)
	cMens += IIF(!Empty(cMens), CRLF, "")+	Lj950ImpNC(nVlrTotal,aTotaisImp[1],MsDecimais(STBGetCurrency()),/*lNFCe*/,;
												aTotaisImp[2],aTotaisImp[3],aTotaisImp[4]) 
EndIf

//Prepara mensagem de promocao do cupom.

If STFGetCfg("lSaveCmdFch")
	cBuffer := Str( Self:nImpHnd ) + "," + cMens + "," + Space( 2000 )	// Armazena o comando de fechamento
Else
	cBuffer := Str( Self:nImpHnd ) + "|" + cMens 							// Armazena o comando de fechamento		
EndIf

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oMsg := Self:PrepMsgPro(cMens)
			oRet := Self:oImpFisc:FecharCF(oMsg)
			If oRet:lRetorno
				nRet := 0
			EndIf 
			FreeObj(oMsg)
			FreeObj(oRet)
		EndIf     
		
		lTravaTecl := .f.
	
	Case Self:cTypeImp = "DLL_SIGALOJA"					
		nRet := Self:ExecDLLRet(Self:nHnd, 15, @cBuffer ) 
		lTravaTecl := lTravaTecl .AND. .T.
	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFFechaCup( cMens , cVlrTotal )          
		cBuffer := Self:oAutocom:cBuffer 
		lTravaTecl := .F.
		
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		cSalvBuff := cBuffer
		nRet := Self:ExecDLLRet(Self:nHnd, 15, @cBuffer )
		If nRet <> 0
			cBuffer := cSalvBuff
		Endif
		Self:TEFHomol(15, cBuffer, 1, Nil, @nRet)  
		lTravaTecl := lTravaTecl .AND. .T.

EndCase 

If lTravaTecl 
	ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd))
EndIf	

//Verifica se e um emulador de ECF para pegar o Journal        
//Journal eh uma copia do cupom    
If Self:PrinterStatus( '11', @cRetorno ) == 0 	// eh um Emulador
	If ExistBlock( "LjJournal" )
		ExecBlock( "LjJournal", .F., .F., { cBuffer } )
	Else
		If !Empty( cArquivo )
			If !File( cArquivo )
				nHandle := FCreate( cArquivo )
			Else
				nHandle := FOpen( cArquivo, 1 )
				FSeek( nHandle, 0, 2 )
			Endif
			FWrite( nHandle, cBuffer, Len( cBuffer ) )
			FClose( nHandle )
		Endif
	Endif
Endif
                                


If lTravaTecl 
	ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd))  
EndIf


Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}Payment
Informa o pagamento do cupom fiscal  
@param   	EXPc1 - Informa a forma de pagamento
@param   	EXPc2 - Flag para vinculacao do cupom 
@param   	EXPc3 - Valor total do pagamento
@param   	EXPc4 - Percepcao  
@param   	EXPc5 - array do SL1   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample  Nil
/*/
//--------------------------------------------------------
Method Payment( cPagto	, cVinculado	, nVlrTotal	, cPercepcion		,;
					aImpsSL1 													) Class STFECFCONTROL

Local nRet		:= -1					// Retorno da Method da dll
Local cImpsLoc	:= ""					// Impressao	
Local nCount		:= 0					// Contador
Local oRet		:= NIL					// Objeto de retorno

Default cPagto		:= ""
Default cVinculado	:= "0"
Default nVlrTotal	:= 0
Default cPercepcion	:= ""
Default aImpsSL1		:= {}

Do Case

	Case Self:cTypeImp == "TOTVSAPI"
		aFormas := Self:LoadForm(cPagto)
		For nCount := 1 To Len(aFormas)
			oRet := Self:oImpFisc:Pagamento(aFormas[nCount][1], aFormas[nCount][2])
			If oRet:lRetorno
				nRet := 0
			Else
				nRet := -1
				Exit
			EndIf
			FreeObj(oRet)
		Next
	
	Case Self:cTypeImp = "DLL_SIGALOJA"				
		nRet := ExeDLLRun2(Self:nHnd, 37, Str(Self:nImpHnd)+ "," + cImpsLoc)
		nRet := ExeDLLRun2(Self:nHnd, 16, Str(Self:nImpHnd)+","+cPagto+","+cVinculado+","+cPercepcion) 
		
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFPagto(cPagto, cVinculado, nVlrTotal,aImpsSL1)
		
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 37, Str(Self:nImpHnd)+ "," + cImpsLoc)
		Self:TEFHomol(Nil, Nil, 5, Nil, @nRet)
		nRet := ExeDLLRun2(Self:nHnd, 16, Str(Self:nImpHnd)+","+cPagto+","+cVinculado+","+cPercepcion)
		Self:TEFHomol(16, Str(Self:nImpHnd)+","+cPagto+","+cVinculado+","+cPercepcion, 2, Nil, @nRet)	// Se for homologação e perder comunicação com a impressora

EndCase

Return nRet  


//--------------------------------------------------------
/*/{Protheus.doc}DescTot
Desconto no total da Venda  
@param   	EXPc1 - Informa os parametros do desconto
@param   	EXPc2 - Valor total   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DescTot( cDesc , cVlrTotal, cTipoCli ) Class STFECFCONTROL    

Local nRet := -1		// Retorno da Method da dll 
Local oRet := nil	// Objeto de retorno

Default cDesc 		:= ""
Default cVlrTotal 	:= "" 
Default cTipoCli	:= "2"

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:DescTotal(Val(cDesc))
				If oRet:lRetorno
					nRet := 0
				EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA						
		nRet := ExeDLLRun2(Self:nHnd, 17, Str(Self:nImpHnd)+","+cDesc+","+cTipoCli)
		
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFDescTot(cDesc , cVlrTotal )
			
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 17, Str(Self:nImpHnd)+","+cDesc+","+cTipoCli)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}AddTot
Registra o acrescimo no total do cupom fiscal   
@param   	EXPc1 - Informa os parametros do acrescimo   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method AddTot( cAcres ) Class STFECFCONTROL

Local nRet := -1		// Retorno da Method da dll 
Local oRet := NIL	// Objeto de retorno

Default cAcres := ""

Do Case
	Case Self:cTypeImp = "TOTVSAPI"
		oRet := Self:oImpFisc:AcresTotal(Val(cAcres))
		If oRet:lRetorno
			nRet := 0
		EndIf  
		FreeObj(oRet)
		
	Case Self:cTypeImp = "DLL_SIGALOJA"						
		nRet := ExeDLLRun2(Self:nHnd, 18, Str(Self:nImpHnd)+","+cAcres)
	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFAcresTot(cAcres)
	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 18, Str(Self:nImpHnd)+","+cAcres)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}MemFisc
Imprime leitura de memoria fiscal 
@param   	EXPc1 - Data inicial                                      
@param   	EXPc2 - Data Final                                        
@param   	EXPc3 - Reducao Z Inicial                                 
@param   	EXPc4 - Reducao Z Final                                   
@param   	EXPc5 - Tipo da leitura
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method MemFisc( cDataIni	, cDataFim, cReducIni,;
					cReducFim	, cCheck 				) Class STFECFCONTROL   
				
Local nRet 		:= -1		// Retorno da Method da dll
Local cPath 		:= ""     // Caminho onde a TotvsAPI ira gravar o arquivo de Memoria Fiscal quando PAF-ECF
Local cAux  		:= ""		// Variavel auxiliar que contera o path para a gravacao do arquivo
Local cTypeMF   := ""		// Define o tipo da Memoria Fiscal geradao C = Completa / S = Simplificada
Local oRet 		:= NIL		// retorno

Default cDataIni 	:= ""			
Default cDataFim 	:= ""		
Default cReducIni   := ""		
Default cReducFim	:= ""		
Default cCheck 		:= ""

cReducIni := AllTrim(cReducIni)
cReducFim := AllTrim(cReducFim)

Do Case
	Case Self:cTypeImp == "TOTVSAPI"
		//Tipo da Memoria Fiscal
		cTypeMF := SubStr(cCheck, 2, 1)
		
		If !Empty(cReducIni) .AND. !Empty(cReducFim)
			oRet := Self:oImpFisc:MFReducao(AllTrim(cReducIni), AllTrim(cReducFim), IIF("I" $ cCheck, "I", "A"), cTypeMF)
		Else
			oRet := Self:oImpFisc:MFData(CTOD(cDataIni), CTOD(cDataFim), IIF("I" $ cCheck, "I", "A"), cTypeMF)
		EndIf
			
		If oRet:lRetorno              
			//Arquivo
			If ("A" $ cCheck)
				//Pega o Path do arquivo gerado	
				oRet := Self:oImpFisc:PegPathMF()
				If oRet:lRetorno			
					cAux := AllTrim(oRet:oRetorno)
			    	If cAux == "C:\" .OR. Empty(cAux)
						cAux := "C:\LeituraMF.txt"
			    	EndIf
					If STBIsPaf() 
						If StBGerPath( @cPath ) 
							If __CopyFile(cAux, cPath + "LMF" + cTypeMF + ".TXT")
								nRet := 0
							EndIf	
						EndIf	
					Else						
						nRet := 0 
					EndIf
				EndIf	
			Else          
				nRet := 0 
			EndIf
		EndIf
        FreeObj(oRet)
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 19, Str(Self:nImpHnd)+","+cDataIni+","+cDataFim+","+cReducIni+","+cReducFim+","+cCheck)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM
		nRet := Self:oAutocom:IFMemFisc(cDataIni, cDataFim, cReducIni, cReducFim, cCheck)
	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 19, Str(Self:nImpHnd)+","+cDataIni+","+cDataFim+","+cReducIni+","+cReducFim+","+cCheck)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}AddAliq
Adiciona aliquotas na impressora 
@param   	EXPc1 - Informa a descricao da aliquota                                      
@param   	EXPc2 - Informa o tipo da aliquota S ou T                                        
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method AddAliq( cAliquota, cType ) Class STFECFCONTROL

Local nRet := -1		// Retorno da Method da dll     
Local oRet := NIL	// Retorno


Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:ConfigAliq(Val(cAliquota), IIF(cType == "2", "S", "N"))
			If oRet:lRetorno
				nRet := 0
			EndIf
		EndIf
		
 	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 20, Str(Self:nImpHnd)+","+cAliquota+","+cType)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM
		nRet := Self:oAutocom:IFAdicAliq(cAliquota, cType)
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA
		nRet := ExeDLLRun2(Self:nHnd, 20, Str(Self:nImpHnd)+","+cAliquota+","+cType)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}OpenNotFiscalReceipt
Faz a abertura do cupom nao fiscal 
@param   	EXPn1 - Handle de uso da DLL                               
@param   	EXPc1 - Condicao de pagto. do nao fiscal                   
@param   	EXPc2 - Valor do CNF                                       
@param   	EXPc3 - Totalizador NF que sera gravado                    
@param   	EXPc4 - Texto impresso no NF 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method OpenNotFiscalReceipt( cCondicao, cValue, cTotalizer,;
							 cTexto , nParcels ) Class STFECFCONTROL  
							 
Local nRet 			:= -1				// Retorno da Method da dll
Local cTotOrig		:= ""	   			// Totalizador original
Local oRet 			:= NIL   			// Retorno			
Local oTEF			:= STBGetTEF() 	// Captura o Objeto TEF
Local lTravaTecl   := ValType(oTEF) == "O" .AND. oTEF:IsAtivo() .AND. Valtype(oTEF:oConfig:oCfgTef) == "O" .AND.  !oTEF:oConfig:oCfgTef:SiTefHb(oTEF:oConfig:oCfgTef) //trava teclado

Default cCondicao 	:= ""			
Default cValue 		:= ""		
Default cTotalizer	:= ""		
Default cTexto 		:= ""		// Texto a ser impresso	
Default nParcels 	:= 1   		// Numero de parcelas na qual a venda foi finalizada - impressa no CUPOM NAO FISCAL
          
cTexto := StrTran( cTexto, Chr(13), '') 	//Remove CHR(13)

Do Case
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			cTotOrig := cTotalizer
			cTotalizer := Self:DscTotaliz(cTotalizer)
			oRet := Self:oImpFisc:AbrirCNFV(Val(cValue), cCondicao, cTotalizer, cTotOrig)
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		EndIf

	Case Self:cTypeImp == "DLL_SIGALOJA"
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		nRet := ExeDLLRun2(Self:nHnd, 21, Str(Self:nImpHnd)+","+cCondicao+","+cValue+","+cTotalizer+","+cTexto)
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFAbrCNFis(cCondicao, cValue, cTotalizer, cTexto, nParcels)
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		nRet := ExeDLLRun2(Self:nHnd, 21, Str(Self:nImpHnd)+","+cCondicao+","+cValue+","+cTotalizer+","+cTexto)
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}TxtNotFiscalReceipt
Faz a impressao do cupom nao fiscal 
@param   	EXPn1 - Handle de uso da DLL                          
@param   	EXPc1 - Texto a ser impresso                        
@param   	EXPc2 - Numero de vias                     
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method TxtNotFiscalReceipt( cTexto, nVias ) Class STFECFCONTROL 

Local nRet			:= -1						// Retorno da Method da dll
Local oRelatorio	:= Nil						// Relatorio que sera impresso
Local oRet 			:= NIL                    	// Retorno
Local oTEF			:= STBGetTEF() 			//Captura o Objeto TEF
Local lTravaTecl   	:= ValType(oTEF) == "O" .AND. oTEF:IsAtivo() .AND. Valtype(oTEF:oConfig:oCfgTef) == "O" .AND.  !oTEF:oConfig:oCfgTef:SiTefHb(oTEF:oConfig:oCfgTef)//trava teclado

Default nVias 		:= 1						// Numero de vias do texto

cTexto := StrTran( cTexto, Chr(13), '') //Remove CHR(13)

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI" 
 		If Self:Self:oImpFisc <> Nil
			oRelatorio :=  Self:PrepReport(cTexto, nVias)  
			oRet := Self:oImpFisc:ImpTxtNF(oRelatorio, .F.)
			If oRet:lRetorno
				nRet := 0
			EndIf 
			FreeObj(oRelatorio)
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		nRet := ExeDLLRun2(Self:nHnd, 23, Str(Self:nImpHnd)+'|'+cTexto+'|'+Str(nVias)+'|')
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM
		nRet := Self:oAutocom:IFTxtNFis(cTexto, nVias )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		If !Self:TEFHomol( 23, cTexto, 3, nVias, @nRet)
			nRet := ExeDLLRun2(Self:nHnd, 23, Str(Self:nImpHnd)+'|'+cTexto+'|'+Str(nVias)+'|')
		EndIf
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado

EndCase

Return nRet 
              

//--------------------------------------------------------
/*/{Protheus.doc}CloseNotFiscalReceipt
Faz o fechamento do cupom nao fiscal    
@param                           
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CloseNotFiscalReceipt() Class STFECFCONTROL  

Local nRet 			:= -1		// Retorno da Method da dll
Local oRet 			:= NIL    	// Retorno	
Local oTEF			:= STBGetTEF() //Captura o Objeto TEF
Local lTravaTecl   	:= ValType(oTEF) == "O" .AND. oTEF:IsAtivo() .AND. Valtype(oTEF:oConfig:oCfgTef) == "O" .AND.  !oTEF:oConfig:oCfgTef:SiTefHb(oTEF:oConfig:oCfgTef)// Trava teclado

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:FecharCNFV()
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		nRet := ExeDLLRun2(Self:nHnd, 24, Str( Self:nImpHnd ))
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado
		
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFFchCNFis()
		
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
			Self:TEFHomol(Nil, Nil, 5, Nil, @nRet)
			If Self:lHomTEF
				Sleep(3000)
			EndIf
			nRet := ExeDLLRun2(Self:nHnd, 24, Str( Self:nImpHnd ))
			Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado
End Case  
		
Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}PrinterStatus
Faz leitura do Status da impressora     
@param   	EXPn1 - Tipo                               
@param   	EXPc2 - Buffer                              
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrinterStatus( cType, cBuffer ) Class STFECFCONTROL

Local nRet 		:= -1		// Retorno da Method da dll
Local oRet		:= NIL     	// Retorno

Default cType 	:= ""
Default cBuffer := ""

cBuffer := Str( Self:nImpHnd )+","+cType+","+Space(500)      

Do Case

	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> NIL
			oRet := Self:oImpFisc:InfoEcf(cType)
			If oRet <> Nil .AND. oRet:lRetorno
				nRet := 0
				cBuffer := Self:TreatStatus(oRet:oRetorno, cType, @nRet)  
				FreeObj(oRet)
			EndIf
		EndIf
		
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet		:= Self:oAutocom:IFStatus(cType)
		cBuffer 	:= Self:oAutocom:cBuffer
	
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA
		nRet 		:= Self:ExecDLLRet(Self:nHnd, 25, @cBuffer)

	Case Self:cTypeImp == "DLL_SIGALOJA"						
		nRet := Self:ExecDLLRet(Self:nHnd, 25, @cBuffer)

EndCase  

Return nRet 
              

//--------------------------------------------------------
/*/{Protheus.doc}NotFiscalTotal
Grava totalizadores nao fiscais      
@param   	EXPn1 - Handle de uso da DLL                               
@param		EXPc1 - Numero do Totalizador                               
@param		EXPc2 - Descricao do totalizador
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method NotFiscalTotal( cNum, cDescr ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll
Local oRet := NIL 	//Objeto do retorno

Default cNum 	:= ""
Default cDescr 	:= ""

Do case    
    Case Self:cTypeImp == "TOTVSAPI"  

		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:ConfTotNF(cNum, cDescr)
			If oRet:lRetorno
				nRet := 0
			EndIf
		EndIf

	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 26, Str(Self:nImpHnd)+","+cNum+","+cDescr)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := oAutocom:IFTotNFis(cNum, cDescr)

	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA
		nRet := ExeDLLRun2(Self:nHnd, 26, Str(Self:nImpHnd)+","+cNum+","+cDescr)

EndCase

Return nRet 
              

//--------------------------------------------------------
/*/{Protheus.doc}Autentic
Faz a autenticacao de documentos          
@param		EXPc1 - Numero de vezes da autenticacao                    
@param		EXPc2 - Valor a ser autenticado                          
@param		EXPc3 - Texto da autenticacao
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method Autentic( cVezes, cValue, cTexto ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll
Local oRet := NIL       // Retorno

Default cVezes 	:= ""
Default cValue 	:= ""
Default cTexto 	:= ""

Do Case

	Case Self:cTypeImp == "TOTVSAPI"		
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:Autenticar(cTexto)
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		EndIf

	Case Self:cTypeImp == "DLL_SIGALOJA"			
		nRet := ExeDLLRun2(Self:nHnd, 27, Str(Self:nImpHnd)+","+cVezes+","+cValue+","+cTexto)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFAutentic(cVezes, cValue, cTexto )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 27, Str(Self:nImpHnd)+","+cVezes+","+cValue+","+cTexto)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}Drawer
Faz a abertura da gaveta via ECF         
@param   	EXPn1 - Handle de uso da DLL                               
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method Drawer() Class STFECFCONTROL 

Local nRet 		:= -1			// Retorno da Method da dll
Local oRet 		:= NIL       	// Retorno
Local cPorta 	:= STFGetStat("PORTIF")
Local cModelo	:= STFGetStat("IMPFISC") 
Local lAutomato := If(Type("lAutomatoX") <> "L",.F.,lAutomatoX)

//Somente realiza a abertura de porta se não for robo
If !lAutomato

	nRet := STWOpenPrintCommunication(cModelo, cPorta)

	If nRet == 0

		Do Case

			Case Self:cTypeImp == "TOTVSAPI"
				If Self:oImpFisc <> Nil
					oRet := Self:oImpFisc:AbrirGavet()
					
					If oRet:lRetorno
						nRet := 0
					EndIf
					
					FreeObj(oRet)
				EndIf
				
			Case (Self:cTypeImp == "DLL_SIGALOJA" .OR. Self:cTypeImp == "EQUIP_DLL_SIGALOJA" ).AND. Self:nImpHnd >= 0
				nRet := ExeDLLRun2(Self:nHnd, 28, Str( Self:nImpHnd ))
			
			Case (Self:cTypeImp == "DLL_SIGALOJA" .OR. Self:cTypeImp == "EQUIP_DLL_SIGALOJA" ).AND. Self:nImpHndNFis >= 0
				nRet := ExeDLLRun2(Self:nHnd, 137, Str( Self:nImpHndNFis ))

			Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
				nRet := Self:oAutocom:IFGaveta()     
				
			Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
				nRet := ExeDLLRun2(Self:nHnd, 28, Str( Self:nImpHnd ))

		EndCase

	EndIf

	//Fecha a comunicação após utilizar para não travar a porta
	Self:ClosePrintCommunication(cModelo, cPorta)

EndIf

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}OpenECF
 Faz a abertura do ECF (utilizada somente no inicio do dia)        
@param   	EXPn1 - Handle de uso da DLL                                
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------- 
Method OpenECF() Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll
Local oRet := NIL       // Retorno

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:AbrirDia()
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		EndIf

	Case Self:cTypeImp	== "DLL_SIGALOJA"						
		nRet	:= ExeDLLRun2(Self:nHnd, 30, Str( Self:nImpHnd ))
	 
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFAbrECF()
	    cTypeImp := "EQUIP_DLL_AUTOCOM" 
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 30, Str( Self:nImpHnd ))
		cTypeImp := "EQUIP_DLL_SIGALOJA"

EndCase  

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}CloseECF
Faz o fechamento do Dia ( utilizada no fim do dia )        
@param   	EXPn1 - Handle de uso da DLL                                
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------- 
Method CloseECF(cPort) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll

Default cPort := ""

Do Case 
	Case Self:cTypeImp = "TOTVSAPI"
		nRet := 0

	Case Self:cTypeImp == "DLL_SIGALOJA"				
		nRet := ExeDLLRun2(Self:nHnd, 31, Str( Self:nImpHnd )+"," + cPort)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFFchECF()
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 31, Str( Self:nImpHnd )+","+cPort)
EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} Supply
 Faz a inclusao de suprimento (entrada de troco)       
@param   	EXpn1 = Le o suprimento da impressora				  
@param      EXpn2 = Grava suprimento na impressora				  
@param      EXpn3 = Efetua sangria	
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------- 
Method Supply( 	nTipo, cValue, cPagto,;
				cTotal, nModo, cFormSup ) Class STFECFCONTROL   
				
Local   nRet   		:= -1       // Retorno
Local   oFormas     := Nil		// Objeto do tipo LJCFormasECF
Local 	oRet 		:= NIL      // Objeto Retorno

Default nTipo       := 0 
Default cValue 		:= ""
Default cPagto 		:= ""		// Forma de pagamento (dinheiro, cheque, cartao)
Default cTotal 		:= ""    
Default nModo       := 0                                           
Default cFormSup	:= ""		// Impressao das formas de pagamento no CUPOM


Do Case
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			//Carrega as formas 	
			oFormas := Self:PrepSupSan(cFormSup, Val(cValue))
			If nTipo == 3
				oRet := Self:oImpFisc:Sangria(oFormas)
			ElseIf nTipo == 2
				oRet := Self:oImpFisc:Suprimento(oFormas)	
			Else
				Return 8
			EndIf
			If oRet:lRetorno
				nRet := 0
			EndIf

			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp == "DLL_SIGALOJA"						
		nRet := ExeDLLRun2(	Self:nHnd,; 
							32	,; 
							Str(Self:nImpHnd)+","+;
							Str(nTipo)  +","+;
							cValue		+","+;
							cPagto		+","+;
							cTotal		+","+;
							Str(nModo)  +","+;
							cFormSup)

	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFSupr(nTipo, cValue, cPagto, cTotal)
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(	Self:nHnd,;
							32	,; 
							Str(Self:nImpHnd)+","+;
							Str(nTipo)  +","+;
							cValue		+","+;
							cPagto		+","+;
							cTotal		+","+;
							Str(nModo)  +","+;
							cFormSup)
EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}HourSummerAdjust
Ajusto o ECF conforme horario de Verao     
@param   	EXPn1 - Handle de uso da DLL                               
@param   	EXPc1 - Informa se e entrada ou saida do horario de verao
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method HourSummerAdjust( cType ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll
Local oRet := NIL       // Objeto de retorno

Default cType := ""

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI" 
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:ConfVerao(IIF(cType == "+", "E", "S"))
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		EndIf

	Case Self:cTypeImp == "DLL_SIGALOJA"						
		nRet := ExeDLLRun2(Self:nHnd, 33, Str(Self:nImpHnd)+","+cType)

	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFHrVerao( cType )

	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 33, Str(Self:nImpHnd)+","+cType)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}ManagReportPrint
Faz a Impressao do Relatorio Gerencial     
@param   	EXPn1 - Handle de uso da DLL                              
@param   	EXPc1 - Texto a ser impresso no relatorio                
@param   	EXPc2 - Numero de vias do texto
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ManagReportPrint( cTexto , nVias ) Class STFECFCONTROL 

Local nRet			:= -1						// Retorno da Method da dll
Local oRelatorio	:= Nil						//Relatorio que sera impresso
Local oRet := NIL
Local oTEF			:= STBGetTEF() //Captura o Objeto TEF
Local lTravaTecl   := ValType(oTEF) == "O" .AND. oTEF:IsAtivo() .AND. Valtype(oTEF:oConfig:oCfgTef) == "O" .AND.  !oTEF:oConfig:oCfgTef:SiTefHb(oTEF:oConfig:oCfgTef)

Default cTexto		:= ""						// Texto
Default nVias		:= 1						// Numero de Vias

cTexto := StrTran( cTexto, Chr(13), '') //Remove CHR(13)

If Self:lHomTEF
	Sleep(6000)
EndIf

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		oRelatorio :=  self:PrepReport(cTexto, nVias)  
		oRet := Self:oImpFisc:ImpRelGer(oRelatorio, Nil, .F.)
		If oRet:lRetorno
			nRet := 0
		EndIf
		FreeObj(oRelatorio)
		FreeObj(oRet)
		
	Case Self:cTypeImp == "DLL_SIGALOJA"					
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		nRet := ExeDLLRun2(Self:nHnd, 34, Str(Self:nImpHnd)+'|'+cTexto+'|'+Str(nVias)+'|')
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFRelGer(cTexto,nVias)
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		If !Self:TEFHomol( 34, cTexto, 4, nVias, @nRet)
			nRet := ExeDLLRun2(Self:nHnd, 34, Str(Self:nImpHnd)+'|'+cTexto+'|'+Str(nVias)+'|')
		EndIf
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado

EndCase

Return nRet


//--------------------------------------------------------
/*/{Protheus.doc}SubTotalReceipt
Retorna o subtotal do cupom     
@param   	EXPn1 - Handle de uso da DLL                              
@param   	EXPc1 - Retorno do subtotal                
@param   	EXPc2 - Falg de impressao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method SubTotalReceipt( cBuffer, cImprime ) Class STFECFCONTROL 

Local nRet := -1			// Retorno da Method da dll                     
Local oRet := NIL

Default cBuffer 	:= ""	
Default cImprime 	:= " "		// Indica se imprime subtotal

Do Case
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:SubTotal()
			If oRet:lRetorno
				nRet := 0
				cBuffer := Str(oRet:oRetorno * 100)
			EndIf
			FreeObj(oRet)
		EndIf
    
	Case Self:cTypeImp == "DLL_SIGALOJA"
		cBuffer := Str(Self:nImpHnd)+','+ cImprime + ','+cBuffer
		nRet := Self:ExecDLLRet(Self:nHnd, 80, @cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFSubTotal(cImprime)
		cBuffer := Self:oAutocom:cBuffer	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 80, @cBuffer)

EndCase   

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}NumItemPrint
Retorna o numero de itens impressos  
@param   	EXPn1 - Handle de uso da DLL                              
@param   	EXPc1 - Retorna o numero de itrend vendidos   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method NumItemPrint( cBuffer ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll
Local oRet := NIL       // Objeto retorno

Default cBuffer 	:= " "	

cBuffer := Str(Self:nImpHnd)+','+cBuffer   

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NumeroItem()
			
			If oRet:lRetorno
				nRet := 0
				cBuffer := oRet:oRetorno
			EndIf
			
			FreeObj(oRet)
		EndIf

	Case Self:cTypeImp == "DLL_SIGALOJA"				
		nRet := Self:ExecDLLRet(Self:nHnd, 81, @cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFNumItem()
		cBuffer := Self:oAutocom:cBuffer
   
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 81, @cBuffer)

EndCase

Return nRet      


//--------------------------------------------------------
/*/{Protheus.doc}EmulEcf
Alimenta as properties da sigaloja.dll  
@param   	EXPn1 - Handle de uso da DLL                              
@param	   	EXPc1 - Numero do PDV   
@param 		EXPc2 - Numero do Caixa
@param 		EXPc3 - Nome do Caixa 
@param 		EXPc4 - Numero do cupom 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method EmulEcf( cNumPdv, cNumCaixa, cNomeCaixa,;
				cNumCupom ) Class STFECFCONTROL
				
Local nRet := -1		// Retorno da Method da dll
Local cBuffer := Str(Self:nImpHnd)+','+cNumPdv+','+cNumCaixa+','+cNomeCaixa+','+cNumCupom		// alimenta as prop. da dll

Default cNumPdv 	:= ""			
Default cNumCaixa 	:= ""		
Default cNomeCaixa	:= ""		
Default cNumCupom	:= ""

Do Case
    Case Self:cTypeImp == "TOTVSAPI"
    	nRet := 0
	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 35, cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFAlimProp(cNumPdv, cNumCaixa, cNomeCaixa, cNumCupom)
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 35, cBuffer)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}SalesOrder
Alimenta as properties da sigaloja.dll  
@param   	EXPn1 - Handle de uso da DLL                              
@param	   	EXPc1 - Indica se a venda possui TEF   
@param 		EXPc2 - Texto a ser impresso no pedido
@param 		EXPc3 - Valor do pedido
@param 		EXPc4 - Condicao de pagamento em caso de TEF 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method SalesOrder( cTef, cTexto, cValor,;
				   cCondPgTEF 			) Class STFECFCONTROL
				   
Local nRet 			:= -1		// Retorno da Method 
Local cBuffer 		:= Str(Self:nImpHnd)+','+' '+','+cTef+','+cTexto+','+cValor+','+cCondPgTEF		// Monta o comando do Pedido
Local oRelatorio	:= Nil	// Relatorio que sera impresso
Local oRet 			:= NIL 	// Retorno

Default cTef 		:= ""			
Default cTexto 		:= ""		
Default cValor		:= ""		
Default cCondPgTEF	:= ""

cTexto := StrTran( cTexto, Chr(13), '') //Remove CHR(13)

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		oRelatorio :=  Self:PrepReport(cTexto, 1) 
		oRet := Self:oImpFisc:ImpPedido(cTef, oRelatorio, Val(cValor))
		If oRet:lRetorno
			nRet := 0
		EndIf
		FreeObj(oRelatorio)
		FreeObj(oRet)
		
	Case Self:cTypeImp == "DLL_SIGALOJA"				
		nRet := ExeDLLRun2(Self:nHnd, 38, cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := oAutocom:IFPedido(cTef, cTexto, cValor, cCondPgTEF )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 38, cBuffer)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}ReceiveNotFiscal
Realiza o recebimento nao fiscal  
@param   	EXPn1 - Handle de uso da DLL                              
@param	   	EXPc1 - Totalizador do recebimento                          
@param		EXPc2 - Valor do recebimento                              
@param		EXPc3 - Forma de Pagamento do recebimento 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ReceiveNotFiscal( cTotalizer, nValue, cForma ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll
Local cBuffer := Str(Self:nImpHnd)+','+cTotalizer+','+Str(nValue,14,2)+','+cForma		// Monta o comando do recebimento
Local oRet := NIL  		// Objeto retorno

Default cTotalizer 	:= ""
Default nValue		:= 0
Default cForma		:= ""
	
Do Case	
	Case Self:cTypeImp == "TOTVSAPI"

			If Self:CheckPaper() < 2	 
				
				oRet := Self:oImpFisc:AbrirCNF(nValue, cForma, cTotalizer)
				If oRet:lRetorno                                                                                                                     
					nRet := 0
				EndIf
				FreeObj(oRet)
			EndIf

		
	Case Self:cTypeImp == "DLL_SIGALOJA" // Verifica o parametro MV_AUTOCOM

			nRet := ExeDLLRun2(Self:nHnd, 40, cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"

			nRet :=Self:oAutocom:IFRecbNFis(cTotalizer, Str(nValue,14,2), cForma )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA" 
	
			nRet := ExeDLLRun2(Self:nHnd, 40, cBuffer)

EndCase

Return nRet    


//--------------------------------------------------------
/*/{Protheus.doc}DownMFD
Faz o download da memoria de fita detalhe    
@param   	EXPn1 - Handle de uso da DLL                              
@param	   	EXPc1 - Informa o tipo do parametro (COO ou Data)         
@param	   	EXPc2 - Parametro inical                                   
@param	   	EXPc3 - Parametro final 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DownMFD( cType, cInicio, cFinal ) Class STFECFCONTROL 

Local nRet 	:= -1		// Retorno da Method da dll
Local cPath := ""     	// Caminho onde a TotvsAPI ira gravar o arquivo de Memoria Fita Detalhe quando for PAF-ECF
Local cAux  := ""		// Variavel auxiliar que contera o path para a gravacao do arquivo
Local oRet 	:= NIL     	// Objeto de retorno
Local lLjNfPafEcf:= STBIsPaf()
Local cPathArq	:= ""

cInicio := AllTrim(cInicio)
cFinal 	:= AllTrim(cFinal)

If lLjNfPafEcf
	STBFMGerPath( @cPathArq )
	If File(cPathArq + "DOWNLOAD.MFD")
		FErase(cPathArq + "DOWNLOAD.MFD")
	EndIf
EndIf 

Do Case 
	Case Self:cTypeImp == "TOTVSAPI" 
		If Self:oImpFisc <> Nil
			If cType == "1"
				oRet := Self:oImpFisc:MFDData(CTOD(cInicio), CTOD(cFinal))
			Else
				oRet := Self:oImpFisc:MFDCoo(AllTrim(cInicio), AllTrim(cFinal))
			EndIf
			If oRet:lRetorno              
				//Pega o Path do arquivo gerado	
				oRet := Self:oImpFisc:PegPathMFD()
				If oRet:lRetorno			
					cAux := AllTrim(oRet:oRetorno)
		    		If cAux == "C:\" .OR. Empty(cAux)
						cAux := "C:\LeituraMFD_ESP.txt"
		    		EndIf

					If lLjNfPafEcf
						If STBGerPath(@cPath ) 
							If __CopyFile(cAux, cPath + "DOWNLOAD.MFD")
								nRet := 0
							EndIf	
						EndIf	
					Else
					 	nRet := 0 
					EndIf
				EndIf	
			EndIf
			FreeObj(oRet)
		EndIf
    Case Self:cTypeImp == "DLL_SIGALOJA"					
		nRet := ExeDLLRun2(Self:nHnd, 118, Str(Self:nImpHnd)+","+cType+","+cInicio+","+cFinal)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:IFDownMFD( cType, cInicio, cFinal )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 118, Str(Self:nImpHnd)+","+cType+","+cInicio+","+cFinal)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}ExecHsr
 Envia comando direto para a impressora Hasar    
@param   	EXPc1 - Comando a ser executado                           
@param   	EXPc2 - Parametro do comando a ser executado 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ExecHsr( cComando, cPosicao, cDelimit) Class STFECFCONTROL 

Local nRet 		:= -1  	// Retorno
Local aRet  	:= {}	// Array de retorno
Local cBuffer 	:= "" 	// Buffer
Local xReturn   := Nil  // Retorno	

Default cComando	:= ""			
Default cPosicao	:= '0'		
Default cDelimit	:= Chr(28)

cComando := StrTran(cComando,","," ")

//Eh necessario agregar espacos ao final da var cBuffer para que o retorno nao seja truncado
cBuffer := Str(nHdlECF) + "," + cComando + "," + cPosicao + "," + Space(115)
nRet    := Self:ExecDLLRet(Self:nHnd, 39, @cBuffer )
aRet    := Self:LjStr2Array( cBuffer, cDelimit )

If ValType( cPosicao ) == 'C'
   If Val( cPosicao ) > 0 .AND. Len( aRet ) >= Val( cPosicao )
      xReturn  := aRet[ Val( cPosicao ) ]
   Else
      xReturn  := AClone( aRet )
   EndIf
Else
   xReturn  := AClone( aRet )
EndIf

Return xReturn  


//--------------------------------------------------------
/*/{Protheus.doc}PinpadList
Lista os pinpads      
@param   	EXPc1 - Retorna a lista de pinpads             
@param   	EXPl1 - Flag de exibicao de msg
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PinpadList( cBuffer, lMostraMsg ) Class STFECFCONTROL 

Local nRet := -1			   		// Retorno da Method da dll
Local cBuffer1 := Space(2000) 		// Armazena a lista de pinpads da sigaloja
Local cBuffer2 := Space(2000) 		// Armazena a lista de pinpads da Autocom

Default cBuffer 	:= ""
Default lMostraMsg	:= .F.



//executa metodos da sigaloja.dll
nRet := Self:ExecDLLRet(Self:nHnd, 50, @cBuffer1 )
     
If Self:CreateAutoCom()
	If GetRemoteType() == REMOTE_LINUX .AND. File(GetClientDir()+"libautocom.so")
		nRet := Self:oAutocom:PinpadLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File(GetClientDir()+cDLLAUTOCOM)
		nRet := Self:oAutocom:PinpadLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Endif
EndIf

If nRet==0
	cBuffer := Self:JoinList(cBuffer1, cBuffer2)    
EndIf 

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}PinPadOpen
Abre comunicacao com o pinpad       
@param   	EXPc1 - Modelo do Pinpad                                  
@param   	EXPc2 - Porta de uso do pinpad
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PinPadOpen( cModel, cPort ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll  
Local lEquipOpen := aScan(Self:aPortas, {|e| e[1] == cModel .AND. e[2] == cPort}) > 0  //Abri equipamento

Default cModel	:= ""			
Default cPort	:= ""	

If !Empty(cModel) .AND. !Empty(cPort) .AND. !lEquipOpen
	Do Case

		Case Self:cTypeImp == "DLL_SIGALOJA"							
			nRet := ExeDLLRun2(Self:nHnd, 51, cModel+","+cPort)
			
		Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
			nRet :=Self:oAutocom:PinPadAbr( cModel, cPort )
		
		Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA
			Self:aIsAutocom[EQUIP_PINPAD] := EQUIP_DLL_SIGALOJA
			nRet := ExeDLLRun2(Self:nHnd, 51, cModel+","+cPort)

	EndCase
EndIf

If !lEquipOpen .AND. nRet > -1
	aAdd(Self:aPortas, {cModel, cPort})
EndIf   


Return nRet

 

//--------------------------------------------------------
/*/{Protheus.doc}PinPadLeC
Solicita a passagem do cartao no pinpad      
@param   	EXPc1 - Modelo do Pinpad                                  
@param   	EXPc1 - Modalidade da leitura do cartao                   
@param   	EXPc2 - Retorno da leitura do cartao
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PinPadLeC( nPinHnd, cModalidade, cBuffer ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll

Default nPinHnd		:= 0			
Default cModalidade	:= ""		
Default cBuffer		:= ""

cBuffer := Str(nPinHnd)+","+cModalidade+","+cBuffer

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA					
		nRet := Self:ExecDLLRet(Self:nHnd, 52, @cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:PinPadLeC(cModalidade)
		cBuffer :=Self:oAutocom:cBuffer        
			
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 52, @cBuffer)
		
EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}PinpadLeS
Solicita a senha do Pinpad       
@param   	EXPc1 - Modelo do Pinpad                                  
@param   	EXPc1 - Leitura da trilha do cartao                        
@param   	EXPc2 - Mensagem do cartao                                 
@param   	EXPc3 - Work                                               
@param   	EXPc4 - Status da transacao
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PinpadLeS( nPinHnd, cTrilha2, cMsg, cWork, cStatus ) Class STFECFCONTROL

Local nRet 		:= -1 			// Retorno da Method da dll
Local nPos		:= 0			// Posicao			
Local nPosAnt 	:= 1           	// Posicao anterior
Local cBuffer 	:= Str(nPinHnd)+","+cTrilha2+","+cMsg+","+cWork+","+cStatus  //Buffer

Do Case
	
	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := Self:ExecDLLRet(Self:nHnd, 53, @cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:PinPadLeS(cTrilha2+","+cMsg+","+cWork+","+cStatus)
		cBuffer :=Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 53, @cBuffer)

EndCase
	
// cBuffer retarna uma string separada por "," para destinguir as variáveis.
// Abaixo quebra a string e atualiza as variáveis de retorno por referencia
nPos := At( ",", cBuffer )
cTrilha2 := Substr(cBuffer,nPosAnt,nPos-1)
nPosAnt := nPos+1

nPos := At( ",", Substr(cBuffer,nPosAnt,Len(cBuffer)))
cMsg     := Substr(cBuffer,nPosAnt,nPos-1)
nPosAnt += nPos

nPos := At( ",", Substr(cBuffer,nPosAnt,Len(cBuffer)))
cWork    := Substr(cBuffer,nPosAnt,nPos-1)
nPosAnt += nPos

cStatus  := Substr(cBuffer,nPosAnt,Len(cBuffer))

Return nRet  


//--------------------------------------------------------
/*/{Protheus.doc}PinpadFin
Finaliza a comunicacao com o pinpad        
@param   	EXPc1 - Modelo do Pinpad                                  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PinpadFin( nPinHnd ) Class STFECFCONTROL     

Local nRet := -1		// Retorno da Method da dll

Default nPinHnd := 0

Do Case
	
	Case Self:cTypeImp == "DLL_SIGALOJA"					
		nRet := ExeDLLRun2(Self:nHnd, 54, Str(nPinHnd))
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:PinPadFin()
		cBuffer :=Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 54, Str(nPinHnd))

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}CMC7List
Lista os leiotores de CMC7       
@param   	EXPc1 - Retorno dos modelos de leitores de CMC7             
@param   	EXPl1 - Flag de exibicao da msg
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CMC7List( cBuffer, lMostraMsg ) Class STFECFCONTROL

Local nRet 			:= -1        			// Retorno da funcao da dll
Local cBuffer1 		:= Space(2000)			// Armazena lista da SIGALOJA.DLL
Local cBuffer2 		:= Space(2000)			// Armazena lista a AUTOCOM
Local cBuffer3 		:= ""			   		// Recebe a lista da TOTVSAPI
Local nCount   		:= 1					// Variavel utiliza no For...
Local oRet 			:= NIL                 	// Objeto retorno
Local oTotvsApi		:= Self:GetTotvsApi()  	// Objeto totvs API  
Local lRet 			:= .F. 					// Retorno

Default cBuffer  	:= ""
Default lMostraMsg  := .F.

If ValType(oTotvsApi) <> "O"
	If Self:CreateTotvsApi()
		oTotvsApi := Self:GetTotvsApi() 
		lRet := .T.
	EndIf  
Else
	lRet := .T.
EndIf 

If lRet  
		oRet := oTotvsApi:ListarCMC7()	
		For nCount := 1 To oRet:Count()
			cBuffer3 += '"' + oRet:Elements(nCount):cDescricao + '",' + oRet:Elements(nCount):cPais + ','
		Next
        nRet := 0
	nRet := 0
EndIf

	nRet := Self:ExecDLLRet(Self:nHnd, 55, @cBuffer1 )

	//Chama o metodo para instanciar o objeto oAutocom           

	If Self:CreateAutoCom() 
		If GetRemoteType() == REMOTE_LINUX .AND. File(GetClientDir()+"libautocom.so")
			nRet := Self:oAutocom:CMC7Lis()
			cBuffer2 := Self:oAutocom:cBuffer
		Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File(GetClientDir()+cDLLAUTOCOM)
			nRet := Self:oAutocom:CMC7Lis()
			cBuffer2 := Self:oAutocom:cBuffer
		Endif
	EndIf

If nRet == 0
	If Empty(cBuffer1) .OR. nModulo == 5 .OR. nModulo == 51
		cBuffer1 := cBuffer3 	
	Else
		If Substr(AllTrim(cBuffer1), Len(AllTrim(cBuffer1)), 1) == ','
			cBuffer1 += cBuffer3		
		Else
			cBuffer1 += ',' + cBuffer3
		EndIf
	EndIf
	cBuffer := Self:JoinList( cBuffer1, cBuffer2, .T. )		// Junta as listas da SIGALOJA e da AUTOCOM  
EndIf

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}CMC7Open 
Estabelece comunicacao com o CMC7      
@param   	EXPc1 - Modelo do leitor de CMC7                           
@param   	EXPc2 - Porta de comunicacao do leitor                    
@param   	EXPc3 - Mensagem do leitor 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CMC7Open( cModel, cPort, cMensagem ) Class STFECFCONTROL   

Local nRet 			:= -1			// Retorno da Method da dll
Local lComOk   		:= .F.			// Controla se abriu comunicacao com a totvsapi
Local oTotvsApi		:= Self:GetTotvsApi() //Objeto Totvs API
Local lRet 			:= .T.         // Retorno
Local lEquipOpen 	:= aScan(Self:aPortas, {|e| e[1] == cModel .AND. e[2] == cPort}) > 0   
Local oRet 			:= NIL  		//Retorno

Default cModel 		:= ""		
Default cPort		:= ""
Default cMensagem 	:= 'S'		// Define a exibicao da mensagem 

 
If !Empty(cModel) .AND. !Empty(cPort)
	If ValType(oTotvsApi) <> "O"    
		If  Self:CreateTotvsApi()
			oTotvsApi	:= Self:GetTotvsApi() 
			lRet := .T.
		EndIf
	Else 
		lRet := .T.
	EndIf
	If lRet
		If Self:ExistEquip(EQUIP_CMC7, cModel, @lComOk)
			If lComOk	
				If !lEquipOpen
					oRet := Self:oImpFisc:AbrirPorta(cModel, cPort, oTotvsApi)

					If oRet:lRetorno
						nRet := 0 
						aAdd(Self:aPortas, {cModel, cPort})
					EndIf					
				Else
					nRet := 0
				EndIf
			EndIf
			
			Self:cTypeCMC7 := "TOTVSAPI" 
			
			Self:nCmc7Hnd := nRet
			If nRet > -1
				Self:lCMC7 := .T.
			EndIf
			
		   	Return nRet
		EndIf
	EndIf
	If Self:ChkAutocom() == DLL_SIGALOJA								// Verifica o parametro MV_AUTOCOM
		If !lEquipOpen
			nRet := ExeDLLRun2(Self:nHnd, 56, cModel+","+cPort+","+cMensagem)
		Else
			nRet := 0
		EndIf
		Self:cTypeCMC7 := "DLL_SIGALOJA"
	ElseIf Self:CreateAutoCom()    								      // Chama o metodo para instanciar o objeto oAutocom
	
		// Pesquisa se o modelo do equipamento existe na AUTOCOM                          
		// Caso houver equipamento homologado nas duas DLLs, a prioridade sera a AUTOCOM.
		If Self:IsAutocom(EQUIP_CMC7, cModel) == EQUIP_DLL_AUTOCOM
			If !lEquipOpen
				nRet := Self:oAutocom:CMC7Abr( cModel, cPort, cMensagem )
			Else
				nRet := 0
			EndIf
			Self:cTypeCMC7 := "EQUIP_DLL_AUTOCOM"
		Else
			If Self:IsAutocom(EQUIP_CMC7, cModel) == EQUIP_DLL_SIGALOJA
				Self:aIsAutocom[EQUIP_CMC7] := EQUIP_DLL_SIGALOJA
				If !lEquipOpen
					nRet := ExeDLLRun2(Self:nHnd, 56, cModel+","+cPort+","+cMensagem) 
				Else
					nRet := 0
				EndIf
				Self:cTypeCMC7 := "EQUIP_DLL_SIGALOJA
			EndIf
		EndIf
	EndIf
EndIf

Self:nCmc7Hnd := nRet
If nRet > -1
	Self:lCMC7 := .T.
	aAdd(Self:aPortas, {cModel, cPort})
EndIf

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}CMC7Close 
Fecha comunicacao com o CMC7       
@param   	EXPc1 - Modelo do leitor de CMC7                           
@param   	EXPc1 - Porta do leitor de CMC7 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CMC7Close( nCmc7Hnd, cPort ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll       
Local nPosPort :=  aScan(Self:aPortas, {|e| e[2] == cPort}) > 0  //Posicao da porta

Default nCmc7Hnd 	:= Self:nCmc7Hnd
Default cPort 		:= ""

Do Case
	Case nPosPort = 0
		nRet := 0
	Case Self:cTypeCMC7 == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			nRet := 0
		EndIf    
		
	Case Self:cTypeCMC7 == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 57, Str(nCmc7Hnd)+","+cPort)
   
	Case Self:cTypeCMC7 == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:CMC7Fec( cPort )
	
	Case Self:cTypeCMC7 == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 57, Str(nCmc7Hnd)+","+cPort)

EndCase  

If nPosPort > 0 
	aDel(Self:aPortas, nPosPort)
	aSize(Self:aPortas, Len(Self:aPortas) -1)
EndIf
	
Return nRet  



//--------------------------------------------------------
/*/{Protheus.doc}CMC7ReadD 
Faz a leitura de documentos       
@param   	EXPn1 - Handle de uso da DLL                            
@param   	EXPc1 - Retorno da leitura do CMC7 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CMC7ReadD(   nCmc7Hnd, cBuffer ) Class STFECFCONTROL 

Local nRet := -1		// REtorno da Method da dll
Local oRet := NIL       // Objeto de retorno

Default nCmc7Hnd 	:= Self:nCmc7Hnd
Default cBuffer 	:= ""

cBuffer := Str(nCmc7Hnd)+","+cBuffer 

Do Case	
	Case Self:cTypeCMC7  == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:LeCMC7()
			
			If oRet:lRetorno
				cBuffer := oRet:oRetorno
				nRet := 0
			EndIf
			
			FreeObj(oRet)
		EndIf    
		
	Case Self:cTypeCMC7 == "DLL_SIGALOJA"					
		nRet := Self:ExecDLLRet(Self:nHnd, 58, @cBuffer)

	Case Self:cTypeCMC7 == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:CMC7leD()
		cBuffer :=Self:oAutocom:cBuffer            
		
	Case Self:cTypeCMC7 == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 58, @cBuffer)

EndCase

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}CMC7ReadDC
 Faz leitura completa do documento do CMC7        
@param   	EXPn1 - Handle de uso da DLL                            
@param   	EXPc1 - Retorno da leitura do CMC7 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CMC7ReadDC( nCmc7Hnd, cBuffer ) Class STFECFCONTROL   

Local nRet := -1		// REtorno da Method da dll
Local oRet := NIL   

Default nCmc7Hnd 	:= Self:nCmc7Hnd
Default cBuffer 	:= ""

cBuffer := Str(nCmc7Hnd)+","+cBuffer

Do Case
	
	Case Self:cTypeCMC7 == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:LeCMC7()
			
			If oRet:lRetorno
				cBuffer := oRet:oRetorno
				nRet := 0
			EndIf
			
			FreeObj(oRet)
		EndIf    
		
	Case Self:cTypeCMC7 == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := Self:ExecDLLRet(Self:nHnd, 82, @cBuffer)

	Case Self:cTypeCMC7 == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:CMC7leDC()
		cBuffer :=Self:oAutocom:cBuffer    
		
	Case Self:cTypeCMC7 == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 82, @cBuffer)

EndCase

Return nRet    



//--------------------------------------------------------
/*/{Protheus.doc}DrawerList
Lista as gavetas ( Serial )        
@param   	EXPc1 - Retorno da lista dos pinpads                    
@param   	EXPl1 - Flag de exibicao da msg 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DrawerList( cBuffer, lMostraMsg ) Class STFECFCONTROL  

Local nRet := -1						// Retorno da Method da dll
Local cBuffer1 := Space(2000)			// Armazena a lista de gavetas da sigaloja.dll
Local cBuffer2 := Space(2000)			// Armazena a lista de gavetas da autocom

Default cBuffer 	:= ""
Default lMostraMsg 	:= .F.

nRet := Self:ExecDLLRet(Self:nHnd, 59, @cBuffer1 )

//Chama o metodo para instanciar o objeto oAutocom            
If Self:CreateAutoCom() 
	If GetRemoteType() == REMOTE_LINUX .AND. File(GetClientDir()+"libautocom.so")
	nRet := Self:oAutocom:GavetaLis()
	cBuffer2 := Self:oAutocom:cBuffer
	Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File(GetClientDir()+cDLLAUTOCOM)
		nRet := Self:oAutocom:GavetaLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Endif
EndIf

If nRet==0
	cBuffer := Self:JoinList(cBuffer1, cBuffer2)  
EndIf    

Return nRet  



//--------------------------------------------------------
/*/{Protheus.doc}DrawerOpen
Estabelece comunicacao com a gaveta          
@param   	EXPc1 - Modelo da gaveta utilizada                        
@param   	EXPc2 - Porta utilizada para conexao da gaveta 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DrawerOpen( cModel, cPort ) Class STFECFCONTROL   

Local nRet 			:= -1		// Retorno da Method da dll
Local lEquipOpen	:= aScan(Self:aPortas, {|e| e[1] == cModel .AND. e[2] == cPort}) > 0     //Abre equipamento
Local cPorta 		:= STFGetStat("PORTIF")
Local cModelo		:= STFGetStat("IMPFISC") 
Local lAutomato 	:= If(Type("lAutomatoX") <> "L",.F.,lAutomatoX)

Default cModel 		:= ""
Default cPort 		:= ""

//Somente realiza a abertura de porta se não for robo
If !lAutomato

	nRet := STWOpenPrintCommunication(cModelo, cPorta)

	If nRet == 0

		If !Empty(cModel) .AND. !Empty(cPort)
			If Self:ChkAutocom() == DLL_SIGALOJA								// Verifica o parametro MV_AUTOCOM
				If !lEquipOpen
					nRet := ExeDLLRun2(Self:nHnd, 60, cModel+","+cPort)
				Else 
					nRet := 0
				EndIf
			ElseIf Self:CreateAutoCom()    								      // Chama o metodo para instanciar o objeto oAutocom
				
				// Pesquisa se o modelo do equipamento existe na AUTOCOM                          
				// Caso houver equipamento homologado nas duas DLLs, a prioridade sera a AUTOCOM. 
				If Self:IsAutocom(EQUIP_GAVETA, cModel) == EQUIP_DLL_AUTOCOM
					If !lEquipOpen
						nRet := Self:oAutocom:GavetaAbr( cModel, cPort )
					Else 
						nRet := 0
					EndIf
				Else
					If Self:IsAutocom(EQUIP_GAVETA, cModel) == EQUIP_DLL_SIGALOJA
						Self:aIsAutocom[EQUIP_GAVETA] := EQUIP_DLL_SIGALOJA
						If !lEquipOpen
							nRet := ExeDLLRun2(Self:nHnd, 60, cModel+","+cPort)
						Else 
							nRet := 0
						EndiF
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If !lEquipOpen .AND. nRet > -1
		nRet := 0
		aAdd(Self:aPortas, {cModel, cPort}) 

	EndIf

	If nRet >-1
		Self:lDrawer := .T.
	EndIf

	//Fecha a comunicação após utilizar para não travar a porta
	Self:ClosePrintCommunication(cModelo, cPorta)
EndIf

Return nRet 

//--------------------------------------------------------
/*/{Protheus.doc}DrawerClose
 Faz fechamento da porta da gaveta serial          
@param   	EXPn1 - Handle de uso da DLL                          
@param   	EXPc1 - Porta de conexao da gaveta 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DrawerClose( nGavHnd, cPort ) Class STFECFCONTROL    

Local nRet := -1		// REtorno da Method da dll          
Local nPosPort := aScan(Self:aPortas, {|e|  e[2] == cPort})  //Posicao porta

Default nGavHnd 	:= 0
Default cPort 		:= ""

Do Case
	
	Case nPosPort == 0
		nRet := 0
	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 61, Str(nGavHnd)+","+cPort)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:GavetaFec( cPort )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 61, Str(nGavHnd)+","+cPort)

EndCase  

If nPosPort > 0 
	aDel(Self:aPortas, nPosPort)
	aSize(Self:aPortas, Len(Self:aPortas) -1)
EndIf

Return nRet 


 
//--------------------------------------------------------
/*/{Protheus.doc}DrawerAction
  Faz o acionamento da gaveta          
@param   	EXPn1 - Handle de uso da DLL                              
@param   	EXPc1 - Porta de conexao da gaveta 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DrawerAction( nGavHnd, cPort ) Class STFECFCONTROL    

Local nRet 		:= -1		// Retorno da Method da dll 
Local cPorta 	:= STFGetStat("PORTIF")
Local cModelo	:= STFGetStat("IMPFISC") 
Local lAutomato := If(Type("lAutomatoX") <> "L",.F.,lAutomatoX)

Default nGavHnd := 0
Default cPort 	:= ""

//Somente realiza a abertura de porta se não for robo
If !lAutomato

	STWOpenPrintCommunication(cModelo, cPorta)

	Do Case
		Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
			nRet := ExeDLLRun2(Self:nHnd, 62, Str(nGavHnd)+","+cPort)
		
		Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
			nRet :=Self:oAutocom:GavetaAci( cPort )
		
		Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
			nRet := ExeDLLRun2(Self:nHnd, 62, Str(nGavHnd)+","+cPort)

	EndCase

	//Fecha a comunicação após utilizar para não travar a porta
	Self:ClosePrintCommunication(cModelo, cPorta)
EndIf

Return nRet   



//--------------------------------------------------------
/*/{Protheus.doc}DrawerStatus
  Faz leitura do status da gaveta            
@param   	EXPn1 - Handle de uso da DLL                              
@param   	EXPc1 - Porta de conexao da gaveta 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DrawerStatus( nGavHnd, cPort ) Class STFECFCONTROL

Local nRet := -1		// retorno da Method da dll

Default nGavHnd 	:= 0
Default cPort 		:= ""

Do Case
	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 83, Str(nGavHnd)+","+cPort)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:GavetaStat( cPort )

	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 83, Str(nGavHnd)+","+cPort)

EndCase

Return nRet   


//--------------------------------------------------------
/*/{Protheus.doc}ListReceiptPrinters
  Faz leitura do status da gaveta            
@param   	EXPc1 - Retorna a lista de impressoras de cupom            
@param   	EXPl1 - Flag de exibicao da msg 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ListReceiptPrinters( cBuffer, lMostraMsg ) Class STFECFCONTROL	

Local nRet := -1					// Retorno da Method da dll			
Local cBuffer1 := Space(2000)		// Armazena a lista vinda da sigaloja.dll
Local cBuffer2 := Space(2000)		// Armazena a lista vinda da autocom

Default cBuffer 		:= 0
Default lMostraMsg 		:= ""
     
//executa metodos da sigaloja.dll
nRet := Self:ExecDLLRet(Self:nHnd, 63, @cBuffer1 )

//Chama o metodo para instanciar o objeto oAutocom 
If Self:CreateAutoCom() 
	If GetRemoteType() == REMOTE_LINUX .AND. File(GetClientDir()+"libautocom.so")
		nRet := Self:oAutocom:ImpCupLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File(GetClientDir()+cDLLAUTOCOM)
		nRet := Self:oAutocom:ImpCupLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Endif
EndIf

If nRet==0
	cBuffer := Self:JoinList(cBuffer1, cBuffer2)  
EndIf
Return nRet     



//--------------------------------------------------------
/*/{Protheus.doc}PrintOpenCommunicationReceipt
  Estabelece comunicacao com a Impressora de Cupom            
@param   	EXPc1 - Modelo da impressora de cupom                      
@param   	EXPc2 - Porta de conexao do cupom  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrintOpenCommunicationReceipt( cModel, cPort ) Class STFECFCONTROL    

Local nRet := -1		// Retorno da Method da dll

Default cModel 			:= ""
Default cPort 	   		:= ""

If !Empty(cModel) .AND. !Empty(cPort)
	Do Case
		
		Case Self:cTypeImp == "DLL_SIGALOJA"								// Verifica o parametro MV_AUTOCOM
			nRet := ExeDLLRun2(Self:nHnd, 64, cModel+","+cPort)
   	   
   		Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
			nRet :=Self:oAutocom:ImpCupAbr( cModel, cPort )
				
		Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
			Self:aIsAutocom[EQUIP_IMPCUPOM] := EQUIP_DLL_SIGALOJA
			nRet := ExeDLLRun2(Self:nHnd, 64, cModel+","+cPort)

	End Case
EndIf 

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}PrintCloseCommunicationReceipt
  Estabelece comunicacao com a Impressora de Cupom            
@param   	EXPn1 - Handle de uso da DLL                        
@param   	EXPc1 - Porta de conxeao da impressora  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrintCloseCommunicationReceipt( nCupHnd, cPort ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll 
Local nPosPort := aScan(Self:aPortas, {|e|  e[2] == cPort})  

Default nCupHnd 		:= 0
Default cPort 			:= ""

Do Case
	
	Case nPosPort = 0
		nRet := 0
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 65, Str(nCupHnd)+","+cPort)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:ImpCupFec( cPort )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 65, Str(nCupHnd)+","+cPort)

End Case  

If nPosPort > 0 
	aDel(Self:aPortas, nPosPort)
	aSize(Self:aPortas, Len(Self:aPortas) -1)
EndIf

Return nRet   


//--------------------------------------------------------
/*/{Protheus.doc}PrintNotFiscalReceipt
  Faz a impressao em cupom nao fiscal             
@param   	EXPn1 - Handle de uso da DLL                        
@param   	EXPc1 -  Texto a ser impresso     
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrintNotFiscalReceipt( nCupHnd, cBuffer ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll

Default nCupHnd 		:= 0
Default cBuffer 			:= ""

Do Case
   
	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 66, Str(nCupHnd)+'|'+cBuffer+'|')
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:ImpCupImp( '|'+cBuffer+'|' )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 66, Str(nCupHnd)+'|'+cBuffer+'|')

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}ReaderList
 Lista os Leitores Seriais                
@param   	EXPn1 - Handle de uso da DLL                        
@param   	EXPc1 - Texto a ser impresso no relatorio   
@param   	EXPc2 - Numero de vias do texto
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ReaderList( cBuffer, lMostraMsg ) Class STFECFCONTROL

Local nRet := -1					// Retorno da Method da dll
Local cBuffer1 := Space(2000)		// Armazena a lista vinda da sigaloja
Local cBuffer2 := Space(2000)		// Armazena a lista vinda da autocom

Default cBuffer 	   		:= 0
Default lMostraMsg 			:= ""
    
//executa metodos da sigaloja.dll
nRet := Self:ExecDLLRet(Self:nHnd, 67, @cBuffer1 )

//Chama o metodo para instanciar o objeto oAutocom           
If Self:CreateAutoCom() 
	If GetRemoteType() == REMOTE_LINUX .AND. File(GetClientDir()+"libautocom.so")
		nRet := Self:oAutocom:LeitorLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File(GetClientDir()+cDLLAUTOCOM)
		nRet := Self:oAutocom:LeitorLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Endif
EndIf

If nRet==0
	cBuffer := Self:JoinList(cBuffer1, cBuffer2) 
EndIf   

Return nRet 

 
//--------------------------------------------------------
/*/{Protheus.doc}ReaderOpen
Estabelece a comunicacao com o leitor                  
@param   	EXPn1 - Handle de uso da DLL                        
@param   	EXPc1 - Porta de comunicacao     
@param   	EXPc2 - Foco do leitor
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ReaderOpen( cModel, cPort, cFoco ) Class STFECFCONTROL   

Local nRet := -1		// Retorno da Method da dll
Local lEquipOpen := aScan(Self:aPortas, {|e| e[1] == cModel .AND. e[2] == cPort}) > 0  

Default cModel		:= ""		
Default cPort		:= ""		
Default cFoco		:= ""		

If !Empty(cModel) .AND. !Empty(cPort)
	
	//Realiza abertura da comunicação com o hardware de leitor, somente compativel com SIGALOJA.DLL, nao possui leitores na TotvsApi
	If Self:IsAutocom( EQUIP_LEITOR, cModel ) == EQUIP_DLL_SIGALOJA
		If !lEquipOpen
			nRet := ExeDLLRun2(Self:nHnd, 68, cModel+","+cPort+","+cFoco )
	    Else 
	    	nRet := 0
	    EndIf
	EndIf

EndIf  

If !lEquipOpen .AND. nRet > -1
	aAdd(Self:aPortas, {cModel, cPort})
	//Determina retorno do Handle de comunicacao do Leitor
	Self:nLeitorHnd := nRet
	nRet := 0
EndIf    

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}ReaderClose
Fecha comunicacao com o Leitor                   
@param   	EXPn1 - Handle de uso da DLL                        
@param   	EXPc1 - Porta de comunicacaor
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ReaderClose( nLeitHnd, cPort ) Class STFECFCONTROL 

Local nRet := 0		// Retorno da Method da dll   
Local nPosPort := aScan(Self:aPortas, {|e|  e[2] == cPort})  

Default nLeitHnd		:= 0			
Default cPort  			:= ""


If nPosPort <> 0
  
	//Realiza abertura da comunicação com o hardware de leitor, somente compativel com SIGALOJA.DLL, nao possui leitores na TotvsApi
	If Self:IsAutocom( EQUIP_LEITOR, cModel ) == EQUIP_DLL_SIGALOJA
		nRet := ExeDLLRun2(Self:nHnd, 69, Str(nLeitHnd)+","+cPort)	
	EndIf       
EndIf

If nPosPort > 0 
	aDel(Self:aPortas, nPosPort)
	aSize(Self:aPortas, Len(Self:aPortas) -1)
EndIf

Return nRet  



//--------------------------------------------------------
/*/{Protheus.doc}ReaderFocus
Indica para a Thread do Leitor se eh ou nao para enviar
o codigo para o protheus                  
@param   	EXPn1 - Handle de uso da DLL                        
@param   	EXPl1 - Modo de leitura
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ReaderFocus( lModo ) Class STFECFCONTROL 

Local nRet 		:= 0		// Retorno da Method da dll

Default lModo  	:= .F.                          

If Self:nLeitorHnd > 0
  	nRet := ExeDLLRun2(Self:nHnd, 70, Str(Self:nLeitorHnd) + "," + Iif(lModo,"1","0"))
EndIf


Return nRet  


//--------------------------------------------------------
/*/{Protheus.doc}BalanceList
Indica para a Thread do Leitor se eh ou nao para enviar
o codigo para o protheus                  
@param   	EXPc1 - Lista de balancas                        
@param   	EXPl1 - Flag da exibicao das msg
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method BalanceList( cBuffer, lMostraMsg ) Class STFECFCONTROL

Local nRet := -1					// Retorno da Method da dll 		
Local cBuffer1 := Space(2000)		// Armazena a lista vinda da sigaloja
Local cBuffer2 := Space(2000)		// Armazena a lista vinda da autocom
	
Default cBuffer					:= ""
Default lMostraMsg  			:= .F.	

Self:nLeitorHnd := 0 //Inicializa default

nRet := Self:ExecDLLRet(Self:nHnd, 88, @cBuffer1 )

//Chama o metodo para instanciar o objeto oAutocom  
If Self:CreateAutoCom()
	If GetRemoteType() == REMOTE_LINUX .AND. File(GetClientDir()+"libautocom.so")
		nRet := Self:oAutocom:BalancaLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File(GetClientDir()+cDLLAUTOCOM)
		nRet := Self:oAutocom:BalancaLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Endif
EndIf

If nRet==0
	cBuffer := Self:JoinList(cBuffer1, cBuffer2)      
EndIf   

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc}BalanceOpen
Estabelece comunicacao com a Balanca                    
@param   	EXPc1 - Modelo da balanca                         
@param   	EXPc2 - Porta de comunicacao da balanca 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method BalanceOpen( cModel, cPort ) Class STFECFCONTROL 

Local nRet 			:= -1			// Retorno da Method da dll
Local lComOk		:= .F.			// Controla se abriu comunicacao com a totvsapi
Local oTotvsApi		:= Self:GetTotvsApi() //Objeto totvs API
Local lRet 			:= .T.       	//Retorno
Local lEquipOpen 	:= aScan(Self:aPortas, {|e| e[1] == cModel .AND. e[2] == cPort}) > 0  //Abri equipamentos 
Local oRet 			:= NIL     		//Retorno
Local lFound 		:= .F.   		//Encontrou

Default cModel		:= ""		
Default cPort  		:= ""

If !Empty(cModel) .AND. !Empty(cPort)

	If ValType(oTotvsApi) <> "O"    
		If  Self:CreateTotvsApi() 
			oTotvsApi	:= Self:GetTotvsApi()
			lRet := .T.
		EndIf
	Else 
		lRet := .T.
	EndIf
	If lRet
		If Self:ExistEquip(EQUIP_BALANCA, cModel, @lComOk)
			If lComOk	
				If !lEquipOpen
					oRet := Self:oImpFisc:AbrirPorta(cModel, cPort, oTotvsApi)
					If oRet:lRetorno
						nRet := 0 
						aAdd(Self:aPortas, {cModel, cPort})
					EndIf					
				Else
					nRet := 0
				EndIf
			EndIf
			
			Self:cTypeBalance := "TOTVSAPI" 
			lFound := .T.

		EndIf
	EndIf
	If !lFound .AND. Self:ChkAutocom() == DLL_SIGALOJA								// Verifica o parametro MV_AUTOCOM
		If !lEquipOpen
			nRet := ExeDLLRun2(Self:nHnd, 86, cModel+","+cPort)
		Else
			nRet := 0
		EndIf
		Self:cTypeBalance := "DLL_SIGALOJA"
	ElseIf Self:CreateAutoCom()    								      // Chama o metodo para instanciar o objeto oAutocom
	
		// Pesquisa se o modelo do equipamento existe na AUTOCOM                         
		// Caso houver equipamento homologado nas duas DLLs, a prioridade sera a AUTOCOM. 
		If Self:IsAutocom(EQUIP_BALANCA, cModel) == EQUIP_DLL_AUTOCOM
			If !lEquipOpen
				nRet := Self:oAutocom:BalancaAbr( cModel, cPort ) 
			Else
				nRet := 0
			EndIf
			Self:cTypeBalance := "EQUIP_DLL_AUTOCOM"
		Else
			If Self:IsAutocom(EQUIP_BALANCA, cModel) == EQUIP_DLL_SIGALOJA
				Self:aIsAutocom[EQUIP_BALANCA] := EQUIP_DLL_SIGALOJA
				If !lEquipOpen
					nRet := ExeDLLRun2(Self:nHnd, 86, cModel+","+cPort)
				Else
					nRet := 0
				EndIf
				Self:cTypeBalance := "EQUIP_DLL_SIGALOJA
			EndIf
		EndIf
	EndIf
EndIf

Self:nBalcHnd := nRet
     
If nRet > -1 
    
	nRet := 0
    
    Self:lBalance := .T. 
    If !lEquipOpen
    	aAdd(Self:aPortas, {cModel, cPort})
    EndIf  
   	
EndIf

Return nRet  


//--------------------------------------------------------
/*/{Protheus.doc}BalanceClose
Fecha comunicacao com a Balanca                   
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method BalanceClose( cPort ) Class STFECFCONTROL

Local nRet := -1		// Retorno da Method da dll    
Local nPosPort := aScan(Self:aPortas, {|e|  e[2] == cPort})  

Default cPort		:= ""

Do Case  
	Case nPosPort == 0
		nRet := 0
	Case Self:cTypeBalance == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 87, Str(Self:nBalcHnd)+","+cPort)
	
	Case Self:cTypeBalance == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:BalancaFec()
	
	Case Self:cTypeBalance == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 87, Str(Self:nBalcHnd)+","+cPort)
EndCase 

If nPosPort > 0 
	aDel(Self:aPortas, nPosPort)
	aSize(Self:aPortas, Len(Self:aPortas) -1)
EndIf

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}BalanceGet
Captura o peso da balanca                                                          
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Retorna o peso da balanca  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------

Method BalanceGet( cBuffer ) Class STFECFCONTROL 

Local nRet := -1		// retorno da Method da dll   
                 
Default cBuffer		:= ""

cBuffer := AllTrim(Str(Self:nBalcHnd))+","+cBuffer

Do Case
	
	Case Self:cTypeBalance == "DLL_SIGALOJA"						
		nRet := ExeDLLRun2(Self:nHnd, 85, @cBuffer )
	
	Case Self:cTypeBalance == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:BalancaPegaPeso()
		cBuffer :=Self:oAutocom:cBuffer	
	
	Case Self:cTypeBalance  == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 85, @cBuffer )

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}DisplayList
Lista os Displays Homologados                   
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Texto a ser impresso no relatorio                  
@param   	EXPc2 - Numero de vias do texto 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DisplayList( cBuffer, lMostraMsg ) Class STFECFCONTROL  

Local nRet := -1			   		// Retorno da Method da dll
Local cBuffer1 := Space(2000)  		// Recebe a lista da SIGALOJA.DLL
Local cBuffer2 := Space(2000) 		// Recebe a lista da AUTOCOM

Default cBuffer	   		:= ""
Default lMostraMsg		:= .F.

nRet := Self:ExecDLLRet(Self:nHnd, 72, @cBuffer1 )

//Chama o metodo para instanciar o objeto oAutocom 
If Self:CreateAutoCom() 
	If GetRemoteType() == REMOTE_LINUX .AND. File(GetClientDir()+"libautocom.so")
		nRet := Self:oAutocom:DisplayLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File(GetClientDir()+cDLLAUTOCOM)
		nRet := Self:oAutocom:DisplayLis()
		cBuffer2 := Self:oAutocom:cBuffer
	Endif
EndIf 

If nRet==0
	cBuffer := Self:JoinList(@cBuffer1, cBuffer2)
EndIf

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc}DisplayOpen
Faz a abertura do display                     
@param   	EXPn1 - Modelo do display                                
@param   	EXPc1 - Porta de comunicacao do display 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DisplayOpen( cModel, cPort ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll  
Local lEquipOpen := aScan(Self:aPortas, {|e| e[1] == cModel .AND. e[2] == cPort}) > 0  

Default cModel		:= ""		
Default cPort		:= "" 

If !Empty(cModel) .AND. !Empty(cPort)
	
	Do Case
		Case Self:cTypeImp == "DLL_SIGALOJA"								// Verifica o parametro MV_AUTOCOM
			If !lEquipOpen
				nRet := ExeDLLRun2(Self:nHnd, 73, cModel+","+cPort)
		    Else 
		    	nRet := 0
		    EndIf
		Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
			If !lEquipOpen
				nRet :=Self:oAutocom:DisplayAbr( cModel, cPort )
		    Else 
		    	nRet := 0
		    EndIf
		Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
			Self:aIsAutocom[EQUIP_DISPLAY] := EQUIP_DLL_SIGALOJA
			If !lEquipOpen
				nRet := ExeDLLRun2(Self:nHnd, 73, cModel+","+cPort)
            Else 
            	nRet := 0
            EndIf
	EndCase
EndIf

If nRet <> -1 

	Self:StatDisplay(nRet) 
	nRet := 0

EndIf

Return nRet  



//--------------------------------------------------------
/*/{Protheus.doc}DisplayClose
Realiza o fechamento do display                  
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao que sera fechada  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DisplayClose( nDisHnd, cPort ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll              
Local nPosPort := aScan(Self:aPortas, {|e|  e[2] == cPort})  

Default nDisHnd		:= 0		
Default cPort		:= ""

Do Case 
	Case nPosPort == 0
		nRet := 0
	
	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 74, Str(nDisHnd)+","+cPort)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:DisplayFec( cPort )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 74, Str(nDisHnd)+","+cPort)
EndCase 

If nPosPort > 0 
	aDel(Self:aPortas, nPosPort)
	aSize(Self:aPortas, Len(Self:aPortas) -1)
EndIf

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}DisplayEnv
Envia texto para o display                   
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Texto a ser enviado para o display 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------

Method DisplayEnv( nDisHnd, cTexto ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll

Default nDisHnd		:= 0		
Default cTexto		:= ""

Do Case
	
	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 75, Str( nDisHnd )+','+cTexto)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:DisplayEnv( cTexto )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 75, Str( nDisHnd )+','+cTexto)
EndCase

Return nRet    


//--------------------------------------------------------
/*/{Protheus.doc}CHOpen
Fecha comunicacao com a Balanca                   
@param   	EXPc1 - Modelo da impressora de cheque                   
@param   	EXPc2 - Porta a ser utilizada para impressora de cheque 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CHOpen( cModel, cPort ) Class STFECFCONTROL

Local nRet 		:= -1		// Retorno da Method da dll
Local lComOk	:= .F.		// Controla se abriu comunicacao com a totvsapi
Local oTotvsApi	:= Self:GetTotvsApi()
Local lRet := .F.        
Local oRet := NIL
Local lEquipOpen := aScan(Self:aPortas, {|e| e[1] == cModel .AND. e[2] == cPort}) > 0  

Default cModel		:= ""		
Default cPort		:= ""

If !Empty(cModel) .AND. !Empty(cPort)
	If  ValType(oTotvsApi) <> "O"
		Self:CreateTotvsApi() 
		oTotvsApi	:= Self:GetTotvsApi()
		lRet := .T.
	Else 
		lRet := .T.
	EndIf
	If lRet
		If Self:ExistEquip(EQUIP_CMC7, cModel, @lComOk)
			If lComOk	
				
				If !lEquipOpen
					oRet := Self:oImpFisc:AbrirPorta(cModel, cPort, oTotvsApi)
					//Self:cTypeImp := "TOTVSAPI"
					If oRet:lRetorno
						nRet := 0           
						aAdd(Self:aPortas, {cModel, cPort})
					EndIf					
				Else
					nRet := 0
				EndIf
				
				Self:cTypeCheck := "TOTVSAPI"
			EndIf 
			
			Self:nChckHnd := nREt
			If nRet > -1
				Self:lCheck := .T.   
			EndIf
			
			Return nRet
		EndIf
	EndIf
	If Self:ChkAutocom() == DLL_SIGALOJA						// Verifica o parametro MV_AUTOCOM
		If !lEquipOpen
			nRet := ExeDLLRun2(Self:nHnd, 76, cModel+","+cPort)
		Else 
			nRet := 0
		EndIf
		Self:cTypeCheck := "DLL_SIGALOJA"
	Else
		
		// Pesquisa se o modelo do equipamento existe na AUTOCOM                          
		// Caso houver equipamento homologado nas duas DLLs, a prioridade sera a AUTOCOM.

		If Self:CreateAutoCom()
			If Self:IsAutocom( EQUIP_IMPCHEQUE, cModel ) == EQUIP_DLL_AUTOCOM
				If !lEquipOpen
					nRet := Self:oAutocom:CHAbrir( cModel, cPort )
				Else 
					nRet := 0
				EndIf
				Self:cTypeCheck := "EQUIP_DLL_AUTOCOM"
			Else       
				If Self:IsAutocom( EQUIP_IMPCHEQUE, cModel ) == EQUIP_DLL_SIGALOJA								
				    Self:aIsAutocom[EQUIP_IMPCHEQUE] := EQUIP_DLL_SIGALOJA
					If !lEquipOpen
						nRet := ExeDLLRun2(Self:nHnd, 76, cModel+","+cPort)    
					Else
						nRet := 0
					EndIf
					Self:cTypeCheck := "EQUIP_DLL_SIGALOJA"
				EndIf
			EndIf                                                        
		Endif	
	EndIf
EndIf   

Self:nChckHnd := nREt
If nRet > -1
	Self:lCheck := .T.
	If !lEquipOpen  
		aAdd(Self:aPortas, {cModel, cPort})
	EndIf
	nRet := 0
EndIf

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}ChStatus
 Status da impressora de cheque                 
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Tipo da impressora utilizada                       
@param   	EXPc2 - Retorno do status da impressora de cheque 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ChStatus( cType, cBuffer ) Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll

Default cType		:= ""		
Default cBuffer		:= ""

cBuffer := Str( Self:nChckHnd )+","+cType+","+cBuffer

If Self:cTypeCheck == "DLL_SIGALOJA"	
						// Verifica o parametro MV_AUTOCOM
	nRet := Self:ExecDLLRet(Self:nHnd, 84, @cBuffer)
Else

	//Pesquisa se o modelo do equipamento existe na AUTOCOM                          
	//Caso houver equipamento homologado nas duas DLLs, a prioridade sera a AUTOCOM.
	If Self:cTypeCheck == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:CHStatus( cType )
		cBuffer :=Self:oAutocom:cBuffer
	Else
		If Self:cTypeCheck == "EQUIP_DLL_SIGALOJA"
			nRet := Self:ExecDLLRet(Self:nHnd, 84, @cBuffer)
		EndIf
	EndIf
EndIf       

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}CHPrints
Realiza a impressao do cheque                   
@param   	EXPn1 - Handle de uso da DLL                               
@param   	EXPc1 - Indica qual eh o banco do cheque                   
@param   	EXPc2 - Valor do cheque                                     
@param   	EXPc3 - Favorecido do cheque                              
@param   	EXPc4 - Municipio do cheque                                
@param   	EXPc5 - Data do cheque                                     
@param   	EXPc6 - Mensagem a ser impressa no cheque                 
@param   	EXPc7 - Mensagem a ser impressa no verso do cheque         
@param   	EXPc8 - Valor por extenso do cheque                        
@param   	EXPc9 - Texto da chancela do cheque 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CHPrints( cBanco		, cValue	, cFavorec	, cCidade	, ;
				 cData		, cMensagem	, cVerso	, cExtenso	, ;
				 cChancela	, cMoedaP	, cMoedaS	, cDataOrig )  Class STFECFCONTROL 
				 
Local oRet		:= NIL     		// Retorno
Local nRet		:= -1			// Retorno da Method da dll
Local cParam	:= ""         	// Parametros

Default cBanco		:= ""		
Default cValue	 	:= ""
Default cFavorec	:= ""		
Default cCidade		:= ""
Default cData		:= ""		
Default cMensagem	:= ""
Default cVerso		:= ""
Default cExtenso 	:= Space(10)			// Recebe valor por extenso do cheque
Default cChancela 	:= 'N'				// Verifica se imprimirá chancela
Default cMoedaP 	:= ""
Default cMoedaS 	:= ""
Default cDataOrig 	:= cData

cParam := Str(Self:nChckHnd)+"|"+cBanco+"|"+cValue+"|"+cFavorec+"|"+cCidade+"|"+cData+"|"+cMensagem+"|"+cVerso+"|"+cExtenso+"|"+cChancela+"|"+cPaisLoc

Do Case
	Case Self:cTypeCheck == "TOTVSAPI"
		If Self:oImpFisc <> Nil

			oRet := Self:oImpFisc:ImpCheque(	cBanco	, Val(cValue)	, cDataOrig	, cFavorec	,;
										cCidade	, cMensagem		, cExtenso	, cMoedaS	,;
					 					cMoedaP	, cPaisLoc)
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)

		
		EndIf
   
	Case Self:cTypeCheck == "DLL_SIGALOJA"							// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 77, cParam)
		
	Case Self:cTypeCheck == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:CHImprime(cBanco, cValue, cFavorec, cCidade, cData, cMensagem, cVerso, cExtenso, cChancela )
	
	Case Self:cTypeCheck == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 77, cParam)

EndCase 

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}ChPrinTrans
 Realiza a Impressao de Cheque Transferencia                    
@param   	EXPn1 - Handle de uso da DLL                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ChPrinTrans( cBanco, cValue, cCidade,;
					cData, cAgencia, cConta, cMensagem )  Class STFECFCONTROL

Local cParam	:= ""							// Concatena os comandos antes de enviar
Local nRet 		:= -1 							// Retorno da Method da dll

Default cBanco		:= ""		
Default cValue	 	:= ""
Default cCidade		:= ""
Default cData		:= ""		
Default cAgencia	:= ""
Default cConta		:= ""
Default cMensagem	:= ""

cParam := Str( Self:nChckHnd) + "|" + cBanco + "|" + cValue + "|" + cCidade + "|" + cData + "|" + cAgencia + "|" + cConta + "|" + cMensagem

//Verifica o parametro MV_AUTOCOM
Do Case

	Case Self:cTypeCheck == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 113, cParam )

	Case Self:cTypeCheck == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:CHImprTransf( cBanco, cValue, cCidade, cData, cAgencia, cConta, cMensagem )
	
	Case Self:cTypeCheck == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 113, cParam )

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}CHClose
Realiza o fechamento da impressora de cheque                  
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao usada pela impressora cheque 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CHClose( cPort ) Class STFECFCONTROL

Local nRet := -1		// Method de retorno da dll   
Local nPosPort := aScan(Self:aPortas, {|e|  e[2] == cPort})

Default cPort		:= ""		

Do Case      
	Case nPosPort == 0
		nRet := 0

	Case Self:cTypeCheck == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			nRet := 0
		 //	Return nRet
		EndIf    
		
	Case Self:cTypeCheck == "DLL_SIGALOJA"				
		nRet := ExeDLLRun2(Self:nHnd, 78, Str(Self:nChckHnd)+","+cPort)
	
	Case Self:cTypeCheck == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:CHFechar( cPort )   
		
	Case Self:cTypeCheck == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 78, Str(Self:nChckHnd)+","+cPort)

EndCase 

If nPosPort > 0 
	aDel(Self:aPortas, nPosPort)
	aSize(Self:aPortas, Len(Self:aPortas) -1)
EndIf  

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}CHList
Lista as impressoras de cheques disponiveis                  
@param   	EXPn1 - Recebe as impressoras homologadas pela SIGALOJA.DLL                         
@param   	EXPc1 - Flag que controla exibicao de msg
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CHList( cBuffer, lMostraMsg ) Class STFECFCONTROL  

Local nRet 			:= -1					// Retorno da Method da dll
Local cBuffer1 		:= Space(2000)			// Recebe a lista da SIGALOJA.DLL
Local cBuffer2 		:= Space(2000)			// Recebe a lista da AUTOCOM
Local cBuffer3 		:= ""					// Recebe a lista da TOTVSAPI
Local nCount   		:= 1					// Variavel utiliza no For...
Local oRet 			:= NIL                 	// Retorno
Local oTovtsApi		:= Self:GetTotvsApi()  	// Totvs APi
Local lRet			:= .F.               	// Retorno

Default cBuffer		:= ""
Default lMostraMsg	:= .F.

If ValType(oTovtsApi) <> "O"
	If Self:CreateTotvsApi()
		lRet := .T.
	EndIf
Else
	lRet := .T.
EndIf

If lRet
	oRet := oTovtsApi:ListImpChq()	
		
	For nCount := 1 To oRet:Count()
		cBuffer3 += '"' + oRet:Elements(nCount):cDescricao + '",' + oRet:Elements(nCount):cPais + ','
	Next   
	nRet := 0
EndIf   


nRet := Self:ExecDLLRet(Self:nHnd, 79, @cBuffer1 )

//Chama o metodo para instanciar o objeto oAutocom  
If Self:CreateAutoCom()
	If GetRemoteType() == REMOTE_LINUX .AND. File(GetClientDir()+"libautocom.so")
		nRet := Self:oAutocom:CHListar()
		cBuffer2 :=Self:oAutocom:cBuffer
	Elseif	GetRemoteType() <> REMOTE_LINUX .AND. File(GetClientDir()+cDLLAUTOCOM)
		nRet := Self:oAutocom:CHListar()
		cBuffer2 := Self:oAutocom:cBuffer
	Endif
Endif

If nRet==0
	If Empty(cBuffer1)
		cBuffer1 := cBuffer3 	
	Else
		If Substr(AllTrim(cBuffer1), Len(AllTrim(cBuffer1)), 1) == ','
			cBuffer1 += cBuffer3		
		Else
			cBuffer1 += ',' + cBuffer3
		EndIf
	EndIf
	cBuffer := Self:JoinList(cBuffer1, cBuffer2)		// Junta as listas da SIGALOJA e AUTOCOM  
EndIf

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc}DLLVersionControl
Controle de versão das DLLs                   
@param   	EXPl1 - Boolean                         
@param   	EXPl2 - Boolean 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPc1 - Indica versão da DLL solicitada 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DLLVersionControl(lAutocom, lTotvsApi) Class STFECFCONTROL

Local cRet	:= ""

Default lAutocom	:= .F.
Default lTotvsApi	:= .F.

//Faz Chamada da função no LojxEcf para evitar ficar alterando as versões em vários fontes
If FindFunction("LJDLLVER") 
	cRet := LJDLLVER(lAutocom, lTotvsApi)
Else
	cRet := "0.3.142.2"
	
	If lAutocom
		cRet:= "3.4.1.5"
	EndIf
	
	If lTotvsApi
		cRet:= "1.0.16.11"
	EndIf
EndIf

Return cRet 


//--------------------------------------------------------
/*/{Protheus.doc}DrawerMoneyOpen
Abre a gaveta de dinheiro conectada na Impressora nFiscal                    
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DrawerMoneyOpen(cSaida,cPorta,cTipoImp) Class STFECFCONTROL


Private nLastKey	:= 0
Private aReturn		:= { "", 1, "" , 2, 3, cPorta , "",IndexOrd() } 


Default cSaida		:= ""		
Default cPorta	 	:= ""
Default cTipoImp	:= ""	 

If Left(cPorta,3) == "LPT"

	SetPrint(Alias(),"","","",,,,.F.,,,,,,,'EPSON.DRV',.T.,.F.,cPorta)
		
	//Verifica se teve exito nas configuracoes do SetPrint e se existe impressora conectada

	If nLastKey <> 27 .AND. IsPrinter()
	
		SetDEFAULT(aReturn,Alias(),,.T.)
		
		//Verifica se teve exito nas configuracoes do SetDEFAULT
		If nLastKey <> 27
			@ PRow(), PCol() PSay Chr(27) + Chr(64)
			SetPrc(0,0)
		Endif
	Else
	
		STFMessage("DrawerMoneyOpen","STOP","Impressora nao conectada" + Alltrim(Str(nErroPrt) ))	
		STFShowMessage("DrawerMoneyOpen")	
    
	EndIf
Endif

@ PRow(), PCol() PSay Chr(27) + Chr(118) + Chr(140)

If SubStr(cTipoImp,1,10) == "EPSON/COMP"
	@ 1,0 PSay Chr(18)+""
Endif
SetPgEject(.F.)

Return .T. 



//--------------------------------------------------------
/*/{Protheus.doc}SelectCountryDevice
Disponibiliza para utilizacao apenas os equipamentos do pais
especificado.          
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method SelectCountryDevice( cBuffer, lEcf, lCodECF )  Class STFECFCONTROL

Local cNovoBuffer := ""		// Buffer com o tratamento de localizacao
Local cPeriferico := ""		// Periferico
Local cPaises	  := ""		// Lista de Paises do periferico
Local cCodEcf     := ""     // Codigo do ECF junto ao PAF-ECF 
Local nPos		  := 0		// Posicao de termino do nome do periferico
Local nPosPais	  := 0		// Posicao de termino da lista dos paises
Local nPosCodEcf  := 0		// Posicao de termino do codigo do ECF   
 
Default cBuffer	:= ""
Default lEcf 	:= .F.
Default lCodECF := .F.
                 
While Len( cBuffer ) # 0

	nPos        := At( ",", cBuffer )			
	cPeriferico := SubStr( cBuffer, 1, (nPos-1) )	// Nome do periferico  
	
	nPosPais    := At( ",", SubStr( cBuffer, nPos + 1 ) )
	cPaises     := SubStr( cBuffer, nPos+1, IIf( nPosPais == 0, Len( cBuffer ), nPosPais-1 ) )	
	cCodEcf := '""'
	If lEcf 
		nPosCodEcf  := At( ",", SubStr( cBuffer, nPos + nPosPais + 1 ) )
		cCodEcf     := SubStr( cBuffer, nPos+nPosPais+1, IIf( nPosCodEcf == 0, Len( cBuffer ), nPosCodEcf-1 ) )	
		
		cBuffer := SubStr( cBuffer, IIf( nPosCodEcf  == 0, Len(cBuffer)+1, nPosCodEcf+nPosPais+nPos+1 ) )
	Else
		cBuffer := SubStr( cBuffer, IIf( nPosPais == 0, Len(cBuffer)+1, nPosPais+nPos+1 ) )
	EndIf
	
	If (cPaisLoc $ cPaises) .OR. Empty( cPaises )
		cNovoBuffer += cPeriferico + IIF(lEcf .AND. lCodECF, '|"' + cCodECF +'"', '') + "," 
	EndIf
	
End

// Retorna apenas os perifericos do pais


cBuffer := Left( cNovoBuffer, Len( cNovoBuffer ) - 1 )

Return Nil



//--------------------------------------------------------
/*/{Protheus.doc}ExecDLLRet
Executa uma Method na DLL, Tratando o Retorno, Pois na 6.09
Chr(0) Eh Permitido.                  
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ExecDLLRet(nHnd, nMethod, cBuffer ) Class STFECFCONTROL   

Local nRet 		:= -1 		// Retorno da Method da dll   

Default nHnd   		:= 0  	
Default nMethod 	:= 0
Default cBuffer 	:= ""	// Concatena os parametros da Method

If Self:nHnd >= 0 
	nRet    := ExeDLLRun2(Self:nHnd, nMethod, @cBuffer)
	If At(Chr(0),cBuffer) > 0
		cBuffer := Substr(cBuffer, 1, At(Chr(0),cBuffer)-1)
	Endif
Endif
Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}CodSitef
Method para utilizacao da SIGALOJA.DLL   
Codifica as mensagens enviadas ao SITEF
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CodSitef( cBuffer ) Class STFECFCONTROL  

Local nRet  := -1  				// Retorno da Method da dll
Local nSize := Len(cBuffer)		// Variave lde controle de looping
Local nPos  := 0 				// controle de loop
Local cTemp := ""				// Retorno da Method

Default cBuffer 	:= ""

// A partir do ID 0.2.67.22, o LOJXECF passa a enviar para a DLL somente numeros decimais
// representando o caracter atraves das funcoes CodSitef() e DecSitef().
// Ex: Foi gerado a string Chr(0)+Chr(48)+Chr(1)...
//     O LOJXECF envia a string '000'+'048'+'001'... Esta string de numeros
// eh tratada dentro da SIGALOJA.DLL

For nPos := 1 To nSize
	cTemp += StrZero(Asc(Substr(cBuffer,nPos,1)),3,0)
Next nPos

cBuffer := cTemp
nRet := ExeDLLRun2(Self:nHnd, 90, @cBuffer)
cTemp := ""

For nPos := 0 To (nSize)-1
	cTemp += Chr(Val(Substr(cBuffer,(nPos*3)+1,3)))
Next nPos

Return cTemp 



//--------------------------------------------------------
/*/{Protheus.doc}DecSitef
Method para utilizacao da SIGALOJA.DLL
Decodifica as mensagens recebidas do SITEF                    
@param   	EXPc1 - Caracter Buffer                      
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DescSitef( cBuffer ) Class STFECFCONTROL 

Local nRet  := -1 				// Retorno da Method da dll 
Local nSize := 	Len(cBuffer)	// Controle de loop
Local nPos  := 0 				// controle de loop
Local cTemp := ""				// Retorno da Method

Default cBuffer 	:= ""

// A partir do ID 0.2.67.22, o LOJXECF passa a enviar para a DLL somente numeros decimais
// representando o caracter atraves das funcoes CodSitef() e DecSitef().
// Ex: Foi gerado a string Chr(0)+Chr(48)+Chr(1)...
//     O LOJXECF envia a string '000'+'048'+'001'... Esta string de numeros
// eh tratada dentro da SIGALOJA.DLL

For nPos := 1 To nSize
	cTemp += StrZero(Asc(Substr(cBuffer,nPos,1)),3,0)
Next nPos

cBuffer := cTemp
nRet := ExeDLLRun2(Self:nHnd, 91, @cBuffer)
cTemp := ""                         

For nPos := 0 To (nSize)-1
	cTemp += Chr(Val(Substr(cBuffer,(nPos*3)+1,3)))
Next nPos

Return cTemp 


//--------------------------------------------------------
/*/{Protheus.doc}LjStr2Array
Method que converte string em array desconsiderando o caracter "|"(pipe)                
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method LjStr2Array( cString, cDelimit ) Class STFECFCONTROL

Local aReturn := { }		// Armazena o retorno da Method
Local cAux    := cString 	// Variavel auxiliar
Local nPos    := 0			// Variavel auxiliar

Default cString 	:= ""
Default cDelimit 	:= CHR(28)

While At( cDelimit, cAux ) > 0
	nPos := At( cDelimit, cAux )
	Aadd( aReturn, SubStr( cAux, 1, nPos-1 ) )
	cAux := SubStr( cAux, nPos+1 )
End

Aadd( aReturn, cAux )

Return aReturn 


//--------------------------------------------------------
/*/{Protheus.doc}PerceptArg
Percepcoes - Resgistra as percepcoes (Loc. Argentina)                   
@param   	EXPn1 - Handle de uso da DLL    
@param   	EXPc1 - Aliquota de IVA                                   
@param   	EXPc2 - Texto a ser impresso                              
@param   	EXPc3 - Valor do comprovante                              
@param   	EXPa1 - Exclusivo para Autocom  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PerceptArg( cAliqIVA, cTexto, cValue, aRet, cDelimit) Class STFECFCONTROL

Local nRet := -1		// Retorno da Method da dll
Local cBuffer  := Str(Self:nImpHnd)+"|"+cAliqIVA+"|"+cTexto+"|"+cValue		// Concatena o comando antes do envio

Default cAliqIVA	:= ""		
Default cTexto	 	:= ""
Default cValue		:= ""	
Default aRet		:= {}
Default cDelimit := Chr(28)

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA"					
		nRet := Self:ExecDLLRet(Self:nHnd, 41, @cBuffer)    
		aRet := Self:LjStr2Array(cBuffer, cDelimit)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:IFPercepcao(cAliqIVA, cTexto, cValue, aRet)
		cBuffer :=Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 41, @cBuffer)    
		aRet := Self:LjStr2Array(cBuffer, cDelimit)

EndCase

Return nRet   


//--------------------------------------------------------
/*/{Protheus.doc}OpenDNFH
Abrir documento nao fiscal hoologado (Loc. Argentina                   
@param   	EXPn1 - Handle de uso da DLL                               
@param   	EXPc1 - Tipo do documento                                 
@param   	EXPc2 - Cliente do documento                                 
@param   	EXPc3 - Cabecalho do comprovante                          
@param   	EXPc1 - Origem do documento nao fiscal                    
@param   	EXPc5 - cTypeImp - Tipo de Impressão T: Ticket  
			S: Página Completa (Default)             
@param   	EXPc6 - cIdDoc = "x"  texto de até 20 caracteres 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method OpenDNFH( cTypeDoc, cClient, cCabec, cDocOrigem, ;
				 aRet	 , cTypeImp, cIdDoc, cDelimit ) Class STFECFCONTROL   
				 
Local nRet := -1 		// Retorno da Method da dll
Local cBuffer := "" 	// Concatena o comando antes de enviar
Local nPos    := 0		// Variavel auxiliar   

Default cTypeDoc	:= ""		
Default cClient	 	:= ""
Default cCabec		:= ""	
Default cDocOrigem	:= ""
Default aRet		:= {}
Default cTypeImp 	:= ""        
Default cIdDoc   	:= "" 
Default cDelimit 	:= CHR(28)

While .T.
	nPos := At(",",cClient)
	If nPos == 0
		Exit
	Else
		cClient := Stuff(cClient,nPos,1," ")
	EndIf
End 

cBuffer  := Str(Self:nImpHnd)+","+cTypeDoc+","+cClient+","+cCabec+","+cDocOrigem+","+cTypeImp+","+cIdDoc 

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA"					
		nRet := Self:ExecDLLRet(Self:nHnd, 42, @cBuffer)    
		aRet := Self:LjStr2Array( cBuffer, cDelimit )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:IFAbreDNFH(cTypeDoc, cClient, cCabec, cDocOrigem,cTypeImp,cIdDoc )          
		cBuffer :=Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 42, @cBuffer)    
		aRet := LjStr2Array( cBuffer )

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}CloseDNFH
Fechar documento nao-fiscal homologado (Loc. Argentina)                 
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Retorno da LjStr2Array
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CloseDNFH(aRet, cDelimit) Class STFECFCONTROL

Local nRet := -1 				// Retorno da Method da dll
Local cBuffer  := Str(Self:nImpHnd)	// Retorno da impressora

Default aRet		:= {}
Default cDelimit 	:= CHR(28)

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 43, @cBuffer)    
		aRet := Self:LjStr2Array( cBuffer, cDelimit )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:IFFechDNFH() 
		cBuffer :=Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 43, @cBuffer)    
		aRet := Self:LjStr2Array( cBuffer, cDelimit )

EndCase

Return nRet  



//--------------------------------------------------------
/*/{Protheus.doc}ReprintsLastDocArg
Reimpressao do ultimo documento emitido (loc. Argentina)                   
@param   	EXPn1 - Handle de uso da DLL                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ReprintsLastDocArg() Class STFECFCONTROL 

Local nRet := -1  				// Retorno da Method da dll
Local cBuffer := Str(Self:nImpHnd)	// Retorno da impressora

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA"			
		nRet := Self:ExecDLLRet(Self:nHnd, 45, @cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:IFReimprime() 
		cBuffer :=Self:oAutocom:cBuffer
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 45, @cBuffer)

EndCase

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}PrintLinesReceiptsArg
 Imprime linhas no recibo (Loc. Argentina)                    
@param   	EXPn1 - Handle de uso da DLL                               
@param   	EXPc1 - Texto a ser impresso no recibo                     
@param   	EXPa1 - Retorno da LjStr2Array 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrintLinesReceiptsArg(cTexto, aRet, cDelimit) Class STFECFCONTROL    

Local nRet := -1   							// Retorno da Method da dll
Local cBuffer  := Str(Self:nImpHnd)+","+cTexto	// Concatena antes de enviar o comando

Default cTexto 		:= ""
Default aRet		:= {}
Default cDelimit 	:= CHR(28)

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 44, @cBuffer)    
		aRet  := Self:LjStr2Array(cBuffer, cDelimit)
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM
		nRet :=Self:oAutocom:IFRecibo(cTexto)
		cBuffer :=Self:oAutocom:cBuffer	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA
		nRet := Self:ExecDLLRet(Self:nHnd, 44, @cBuffer)    
		aRet  := Self:LjStr2Array(cBuffer, cDelimit)

EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}MemWork
Fecha comunicacao com a Balanca                   
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPa1 - Retorno da LjStr2Array 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method MemWork(aRet, cDelimit) Class STFECFCONTROL  

Local nRet := -1								// Retorno da Method da dll
Local cBuffer  := Str(Self:nImpHnd)+","+Space(1000)	// Concatena o comando antes de enviar

Default aRet		:= {}
Default cDelimit 	:= CHR(28)

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet  := Self:ExecDLLRet(Self:nHnd, 46, @cBuffer)    
		aRet  := Self:LjStr2Array(cBuffer, cDelimit)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:IFMemTrab()
		cBuffer :=Self:oAutocom:cBuffer	
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet  := Self:ExecDLLRet(Self:nHnd, 46, @cBuffer)    
		aRet  := Self:LjStr2Array(cBuffer, cDelimit)

EndCase

Return nRet  


//--------------------------------------------------------
/*/{Protheus.doc}CapacityArg
Fecha comunicacao com a Balanca                   
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Retorno da LjStr2Array  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CapacityArg(aRet, cDelimit) Class STFECFCONTROL

Local nRet := -1 								// Retorno da Method da dll
Local cBuffer  := Str(Self:nImpHnd)+","+Space(1000)	// Concatena antes de enviar o comando

Default aRet		:= {}
Default cDelimit 	:= CHR(28)

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA					
		nRet  := Self:ExecDLLRet(Self:nHnd, 47, @cBuffer)    
		aRet  := Self:LjStr2Array(cBuffer, cDelimit)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM
		nRet :=Self:oAutocom:IFCapacity()
		cBuffer :=Self:oAutocom:cBuffer	
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA
		nRet  := Self:ExecDLLRet(Self:nHnd, 47, @cBuffer)    
		aRet  := Self:LjStr2Array(cBuffer, cDelimit)
	
EndCase

Return nRet   


//--------------------------------------------------------
/*/{Protheus.doc}OpenDebitNote
Abre nota de debito                  
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Retorno da impressora
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method OpenDebitNote( cBuffer ) Class STFECFCONTROL   

Local nRet := -1  						// Retorno da Method da dll

Default cBuffer 		:= ""

cBuffer := Str(Self:nImpHnd)+","+cBuffer		// Envia um buffer e já prepara o recebimento

Do Case

	Case Self:cTypeImp == "DLL_SIGALOJA"	
		nRet := Self:ExecDLLRet(Self:nHnd, 48, @cBuffer)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet :=Self:oAutocom:IFAbreNota(cClient)
		cBuffer :=Self:oAutocom:cBuffer	
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 48, @cBuffer)
	
EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauOpenReceipt
Faz a abertura do cupom de restaurante                    
@param   	EXPn1 - Handle de uso da DLL                               
@param   	EXPc1 - Informa a mesa que sera aberta                      
@param   	EXPc2 - Informa o cliente da mesa
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauOpenReceipt( cMesa, cClient ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll
           
Default cMesa		:= ""		
Default cClient	 	:= ""

cBuffer := Str(Self:nImpHnd)+","+cMesa+","+cClient

nRet := Self:ExecDLLRet(Self:nHnd, 100, @cBuffer)

Return nRet  


//--------------------------------------------------------
/*/{Protheus.doc}RestauRegIt
Registra itens de venda em impressora de restaurante                  
@param   	EXPn1 - Handle de uso da DLL                                
@param   	EXPc1 - Mesa do registro do item                            
@param   	EXPc2 - Codigo do item                                      
@param   	EXPc3 - Descricao do item                                   
@param   	EXPc4 - Aliquota do item                                   
@param   	EXPc5 - Quantidade do item                                  
@param   	EXPc6 - Valor do item                                      
@param   	EXPc7 - Acrescimo                                           
@param   	EXPc8 - Desconto   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauRegIt( cMesa		, cCode, cDescricao,		;
				 	cAliquota	, cQtde, cVlrUnit	, Acres,;
				 	Desc 							   		) Class STFECFCONTROL 
				 	
Local nRet := -1		// Retorno da Method da dll

Default cMesa		:= ""		
Default cCode 		:= ""
Default cDescricao	:= ""		
Default cAliquota	:= ""
Default cQtde 		:= ""		
Default cVlrUnit	:= ""
Default Acres 		:= "0" 		// Valor do acrescimo
Default Desc 		:= "0"		// Valor do desconto

cBuffer := Str(Self:nImpHnd)+","+cMesa+","+cCode+","+cDescricao+","+cAliquota+","+cQtde+","+cVlrUnit+","+Acres+","+Desc

nRet := Self:ExecDLLRet(Self:nHnd, 101, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauCancIt
Fecha comunicacao com a Balanca                   
@param   	EXPn1 - Handle de uso da DLL                               
@param   	EXPc1 - Mesa do item cancelado                             
@param   	EXPc2 - Codigo do item cancelado                           
@param   	EXPc1 - Descricao do item cancelado                        
@param   	EXPc2 - Aliquota do item cancelado                         
@param   	EXPc1 - Quantidade do item cancelado                       
@param   	EXPc2 - Valor do item cancelado                           
@param   	EXPc1 - Acrescimo                                          
@param   	EXPc2 - Desconto  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauCancIt( cMesa, cCode, cDescricao,;
 					cAliquota, cQtde, cVlrUnit, Acres,; 
 					Desc ) Class STFECFCONTROL
 					
Local nRet := -1      	// Retorno da Method da dll 

Default cMesa		:= ""		
Default cCode 		:= ""
Default cDescricao	:= ""		
Default cAliquota	:= ""
Default cQtde 		:= ""		
Default cVlrUnit	:= ""
Default Acres 		:= "0" 		// Valor do acrescimo
Default Desc 		:= "0"		// Valor do desconto


cBuffer := Str(Self:nImpHnd)+","+cMesa+","+cCode+","+cDescricao+","+cAliquota+","+cQtde+","+cVlrUnit+","+Acres+","+Desc

nRet := Self:ExecDLLRet(Self:nHnd, 111, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauConfM
Faz a conferencia dos itens vendidos em uma mesa                    
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauConfM( cMesa, Acres, Desc ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll   

Default cMesa		:= ""		
Default Acres 		:= "0" 		// Valor do acrescimo
Default Desc 		:= "0"		// Valor do desconto

cBuffer := Str(Self:nImpHnd)+","+cMesa+","+Acres+","+Desc

nRet := Self:ExecDLLRet(Self:nHnd, 102, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauPrintCdp
Faz a impressao do cardapio 
@param   	EXPn1 - Handle de uso da DLL                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauPrintCdp() Class STFECFCONTROL  

Local nRet 		:= -1		// Retorno da Method da dll  

Default Self:nImpHnd := 0

cBuffer := Str(Self:nImpHnd)

nRet := Self:ExecDLLRet(Self:nHnd, 103, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauGetCdp
Faz a leitura do cardapio via porta serial                  
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauGetCdp() Class STFECFCONTROL  

Local nRet := -1		// Retorno da Method da dll

cBuffer := Str(Self:nImpHnd)

nRet := Self:ExecDLLRet(Self:nHnd, 104, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauGetTable
Faz a leitura das mesas abertas                 
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Buffer 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauGetTable( cBuffer ) Class STFECFCONTROL     

Local nRet 				:= -1		// Retorno da Method da dll

Default cBuffer 		:= 0

cBuffer := Str(Self:nImpHnd)+','+ Space(2000)

nRet := Self:ExecDLLRet(Self:nHnd, 105, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauRepMont
Imprime relatorio das mesas que estao abertas                  
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Tipo 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauRepMont( cType ) Class STFECFCONTROL

Local nRet := -1		// Retorno da Method da dll 

Default cType := "0"	// Tipo do relatorio

cBuffer := Str(Self:nImpHnd)+","+cType

nRet := Self:ExecDLLRet(Self:nHnd, 112, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauLeRegSal
Retorna os registros de venda da mesa pela porta serial.                   
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauLeRegSal( cMesa ) Class STFECFCONTROL 

Local nRet := -1		// Retorno da Method da dll

Default cMesa		:= ""

cBuffer := Str(Self:nImpHnd)+","+cMesa

nRet := Self:ExecDLLRet(Self:nHnd, 106, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}RestauCloseReceipt
Fecha o cupom fiscal na impressora restaurante com acréscimo 
ou desconto, usando apenas uma forma de pagamento                   
@param   	EXPn1 - Handle de uso da DLL                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauCloseReceipt( cPayment, cAcres, cDesc, cMensagem ) Class STFECFCONTROL

Local nRet := -1		// Retorno da Method da dll  

Default cPayment	:= ""
Default cAcres 		:= "0"	// Valor do acrescimo
Default cDesc  		:= "0"	// Valor do desconto
Default cMensagem		:= ""

cBuffer := Str(Self:nImpHnd)+","+cPayment+","+cAcres+","+cDesc+","+cMensagem

nRet := Self:ExecDLLRet(Self:nHnd, 107, @cBuffer)

Return nRet   

 
//--------------------------------------------------------
/*/{Protheus.doc}RestauFCDiv
Permite fechar o cupom fiscal com formas de pagamento e permite
dividir a conta por todos os clientes. (no maximo 20)                    
@param   	EXPn1 - Handle de uso da DLL                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauFCDiv( cNumeroCupons, cAcres  , cDesc, ;
                 	cPayment, cValueCliente, cClient )  Class STFECFCONTROL   
                 	
Local nRet := -1		// Retorno da Method da dll    

Default cNumeroCupons	:= ""
Default cAcres 			:= "0"	// Valor do acrescimo
Default cDesc  			:= "0"	// Valor do desconto   
Default cPayment		:= ""
Default cValueCliente	:= ""
Default cClient			:= ""

cBuffer := Str(Self:nImpHnd)+","+cNumeroCupons+","+cAcres+","+cDesc+","+cPayment+","+cValueCliente+","+cClient

nRet := Self:ExecDLLRet(Self:nHnd, 108, @cBuffer)

Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}RestauTrfTable
Faz a transferência dos registros de venda da mesa de origem
para a mesa de destino                  
@param   	EXPn1 - Handle de uso da DLL                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauTrfTable( cOrigem, cDestino ) Class STFECFCONTROL   

Local nRet := -1		// Retorno da Method da dll

Default cOrigem			:= ""
Default cDestino		:= ""

cBuffer := Str(Self:nImpHnd)+","+cOrigem+","+cDestino

nRet := Self:ExecDLLRet(Self:nHnd, 109, @cBuffer)

Return nRet   


//--------------------------------------------------------
/*/{Protheus.doc}RestauTrfItem
Faz a transferência dos registros de venda da mesa de origem
para a mesa de destino                  
@param   	EXPn1 - Handle de uso da DLL                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RestauTrfItem( cOrigem , cCode , cDescricao, cAliquota,;
					  cQtde   , cVlrUnit, cAcres,	cDesc,;
                      cDestino ) Class STFECFCONTROL    
                      
Local nRet := -1		// Retorno da Method da dll 

Default cOrigem		:= ""		
Default cCode 		:= ""
Default cDescricao	:= ""		
Default cAliquota	:= ""
Default cQtde 		:= ""		
Default cVlrUnit	:= ""
Default cAcres 		:= "0"	// Valor do Acrescimo
Default cDesc  		:= "0"	// Valor do desconto
Default cDestino	:= ""

cBuffer := Str(Self:nImpHnd)+","+cOrigem+","+cCode+","+cDescricao+","+cAliquota+","+cQtde+","+cVlrUnit+","+cAcres+","+cDesc+","+cDestino

nRet := Self:ExecDLLRet(Self:nHnd, 110, @cBuffer)

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}GerRegTypE
Gera Arquivo de Registro Tipo E para Ato Cotepe 17/04                     
@param   	EXPn1 - Handle de uso da DLL                                 
@param   	EXPc1 - Informa o tipo do parametro (Data ou CRZ)            
@param   	EXPc2 - Parametro inical                                      
@param   	EXPc3 - Parametro final  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method GerRegTypE( cType, cInicio, cFinal, cBinario ) Class STFECFCONTROL 
Local aFile	 := {}		//Array com todos os arquivos de uma determinada pasta
Local nRet   := -1		// Retorno da Method da dll
Local nX	 := 0
Local cRazao := ""
Local cEnd   := ""  
Local cPath  := ""		// Caminho onde devera ser salvo o arquivo do Paf-Ecf
Local cPathMFD:=""    
Local aFile  := Nil   	// Array com todos os aquivos de uma determinada pasta
Local cAux   := ""		// Pega caminho e nome do arquivo gerado pela impressora
Local oRet	 := NIL
Local cArquivo 		:= ""
Local cArqINI		:= ""
Local cPathOrig		:= ""
Local cPathBin		:= ""
Local lExecDownMFD	:= .F.
Local cModelo		:= ""
Local lLjNfPafEcf	:= STBIsPaf()

Default cType		:= ""		
Default cInicio 	:= ""
Default cFinal		:= ""
Default cBinario	:= "0"	

cInicio := AllTrim(cInicio)
cFinal	:= AllTrim(cFinal)

//Pega path onde sera salvo arquivo.
STBGerPath( @cPath ) 
cPath += "ARQ MFD\"

//Apaga todos os arquivos do diretorio.
aFile := Directory(cPath + "*.*")
AEVAL( aFile, {|aFile| FERASE(cPath + aFile[F_NAME])} ) 

Do Case
	Case Self:cTypeImp == "TOTVSAPI"	
		If Self:oImpFisc <> Nil
		
			If lLjNfPafEcf
				cArqINI	:= GetClientDir() +"SIGALOJA.INI"
				cPathOrig:= GetPvProfString("PAF-ECF","patharqmfd"	, PAF_DirDef , cArqINI) + "\"
				
				/*Apaga os arquivos gerados pelo ECF*/
				cPath := cPathOrig
				aFile := Directory(cPath + "*.*")
				If Len(aFile) > 0
					AEVAL( aFile, {|aFile| FERASE(cPath + aFile[F_NAME])} )
				EndIf
				
				/*Pega path onde sera salvo arquivo e Apaga todos os arquivos do diretorio */
				cPath := GetPvProfString("PAF-ECF","patharquivo", PAF_DirDef , cArqINI) + PAF_ARQMFD + "\"
				cPathMFD := cPath	
				aFile := Directory(cPath + "*.*")
				If Len(aFile) > 0
					AEVAL( aFile, {|aFile| FERASE(cPath + aFile[F_NAME])} )
				EndIf
			EndIf
			
			/*Somente o modelo novo da Epson contem esse comando*/
			cModelo := AllTrim(STFGetStat("IMPFISC"))
			If (LJDLLVER( .F. , .T. ) >= "1.0.17.1") .And. ("EPSON" $ cModelo) .And.;
			 	cBinario == "1" .And. (("T800" $ cModelo) .OR. ("T900" $ cModelo))
			 	  
				lExecDownMFD := .T.
			EndIf
			
			//Pega o Path do arquivo gerado	
			oRet := Self:oImpFisc:PegPathTipoE(cBinario)
			
			If oRet:lRetorno

				//Pega caminho e nome do arquivo gerado pela impressora
				If cBinario == "1" .Or. lExecDownMFD
					cArquivo := "Download.bin"
				EndIf
				
				cAux := AllTrim(oRet:oRetorno)
			    If cAux == "C:\" .OR. Empty(cAux)
					cAux := "C:\" + cArquivo
			    EndIf			

				//Gera Arquivo pela Data
				If lExecDownMFD
					oRet := Self:oImpFisc:DownloadMFD(cBinario,cType,cInicio,cFinal)
				Else
					If cType == "1"
						oRet := Self:oImpFisc:TipoEData(cInicio, cFinal, ,cBinario)	 
					Else
						oRet := Self:oImpFisc:TipoECrz(cInicio, cFinal, cBinario)	
					EndIf
				EndIf
						
				If oRet:lRetorno

					//Verifica se eh Paf-Ecf
					If lLjNfPafEcf

						If cBinario == "1"
							cPathBin := cPathOrig + "*.bin"
							aFile := Directory(cPathBin)
							For nX := 1 to Len(aFile)
								If "BIN" $ Upper(aFile[nX][F_NAME])
									cPathBin := cPathOrig + aFile[nX][F_NAME]
									Exit
								EndIf
							Next nX
							
							If File(cPathBin)
								If __CopyFile(cPathBin,cPathMFD+cArquivo)
									LjGrvLog( Nil, " Arquivo copiado com sucesso [" + cPathMFD + cArquivo + "]")
									Conout(" Arquivo copiado com sucesso [" + cPathMFD + cArquivo + "]")
								EndIf
							Else
								LjGrvLog(Nil,"Arquivo .BIN não encontrado no caminho [" + cPathBin + "]")
								ConOut("Arquivo .BIN não encontrado no caminho [" + cPathBin + "]")
							EndIf
						Else
						    cArquivo := Space(30)
						    Self:GetSerie( @cArquivo )
						    
						    cArquivo := "MFD" + cArquivo + "_" +  StrTran(DtoC(dDatabase),'/') + "_" + StrTran(Time(),":") + ".TXT"
					    	
							//Copia e renomeia arquivo para a pasta do Paf-Ecf		
							If __CopyFile(cAux, cPathMFD + cArquivo)
								nRet := 0
							EndIf
						EndIf
					Else
						nRet := 0 
					EndIf
				EndIf
			EndIf
			
			FreeObj(oRet)
		EndIf   
	Case Self:cTypeImp == "DLL_SIGALOJA"						// Verifica o parametro MV_AUTOCOM
		nRet := ExeDLLRun2(Self:nHnd, 121, Str(Self:nImpHnd)+","+cType+","+cInicio+","+cFinal+","+cRazao+","+cEnd+","+cBinario)
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"

		//Necessario Implementar dentro da Autocom. 
		nRet :=Self:oAutocom:IFGerRegTipoE( cType, cInicio, cFinal, cRazao, cEnd, , cBinario )
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 121, Str(Self:nImpHnd)+","+cType+","+cInicio+","+cFinal+","+cRazao+","+cEnd+","+cBinario)

EndCase

Return nRet 
                   

//--------------------------------------------------------
/*/{Protheus.doc}LJStrToArr
Transforma uma lista separada por "," em array                  
@param   	EXPn1 - Caracteres                      
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method LJStrToArr(cLista) Class STFECFCONTROL  

Local nPos				// Variavel de loop
Local aLista := {}		// Retorno da Method

Default cLista := ""

While Len(cLista)<>0
	If (nPos:=At(",",cLista))<>0
		aAdd(aLista, Subs(cLista, 2, nPos-3))
		cLista := Subs(cLista, nPos+1 )
	Else
		If Left(cLista,1)=='"'
			aAdd(aLista, Subs(cLista, 2, len(cLista)-2) )
		Else
			aAdd(aLista, cLista )
		EndIf
		cLista := ""
	EndIf
End

Return aLista 


//--------------------------------------------------------
/*/{Protheus.doc}LJArrToStr
 Transforma um array em uma lista separada por ","                   
@param   	EXPa1 - Array                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method LJArrToStr(aLista) Class STFECFCONTROL 

Local nI   := 0		// controle de loop 
Local cRet := ""	// Retorno da Method    

Default aLista := {}

For nI := 1 To Len(aLista)
	cRet += '"'+aLista[nI]+'",'
Next nI

cRet := Substr(cRet, 1, Len(cRet)-1)

Return cRet 


//--------------------------------------------------------
/*/{Protheus.doc}JoinList
Junta a lista de equipamentos homologados na 
AUTOCOM.DLL/SO com a SIGALOJA.DLL           
@param   	EXPc1 - Buffer 1                        
@param   	EXPc2 - Buffer 2
@param   	EXPl1 - Boolean 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method JoinList(cBuffer1, cBuffer2, lEcf, lCodECF) Class STFECFCONTROL 

Local nI 		:= 0	// controle de loop
Local aSIGALOJA := {}	// retorno da Method LJStrToArr (SIGALOJA.DLL)
Local aAutocom  := {}	// retorno da Method LJStrToArr (AUTOCOM)	
Local cRet		:= ""	// Retorno da Method

Default cBuffer1		:= ""		
Default cBuffer2 		:= ""
Default lEcf 			:= .F. 
DEFAULT lCodECF			:= .F.

Self:SelectCountryDevice( @cBuffer1, lEcf, lCodECF )				// Retorna apenas os perifericos utilizados
aSIGALOJA := Self:LJStrToArr(cBuffer1)					// Transforma a string em array
Self:SelectCountryDevice( @cBuffer2, lEcf, lCodECF )				// Retorna apenas os perifericos utilizados
aAutocom  := Self:LJStrToArr(cBuffer2)					// Transforma a string em array

For nI := 1 To Len(aAutocom)							// Se o equipamento ja estiver homologado na SIGALOJA nao exibe duplicado
	If !Empty(aAutocom[nI]) .AND. AScan(aSIGALOJA, aAutocom[nI]) == 0
		AAdd(aSIGALOJA, aAutocom[nI])
	EndIf
Next nI

ASort(aSIGALOJA)									// Ordena a lista
cRet := Self:LJArrToStr(aSIGALOJA)						// Transforma o array ordenado em string

Return cRet 


//--------------------------------------------------------
/*/{Protheus.doc}ChkAutocom
Realiza a validacao do parametro MV_AUTOCOM                 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ChkAutocom() Class STFECFCONTROL  

If Self:nChkAutocom == NIL
	Self:nChkAutocom := 1
	If GetRemoteType() == REMOTE_LINUX	   				// Caso a plataforma seja LINUX, somente a AUTOCOM esta homologada
		Self:nChkAutocom := DLL_AUTOCOM
	EndIf
EndIf  

Return Self:nChkAutocom


//--------------------------------------------------------
/*/{Protheus.doc}IsAutocom
Verifica se o equipamento em questao esta homologado na  
AUTOCOM.DLL/SO ou na SIGALOJA.DLL               
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method IsAutocom( nTipo, cModel) Class STFECFCONTROL 

Local nMVAUTOCOM 	:= Self:ChkAutocom()	// Verifica o parametro MV_AUTOCOM
Local aAutocom  	:= {}					// Array autocom
Local lEcf       	:= .F.                 	// Ecf

Default nTipo			:= 0			
Default cModel	   		:= ""

If ValType(Self:aIsAutocom) == "U"
	Self:aIsAutocom := {EQUIP_DLL_NENHUM, EQUIP_DLL_NENHUM, EQUIP_DLL_NENHUM, EQUIP_DLL_NENHUM, EQUIP_DLL_NENHUM, EQUIP_DLL_NENHUM, EQUIP_DLL_NENHUM, EQUIP_DLL_NENHUM, EQUIP_DLL_NENHUM}
EndIf

If nMVAUTOCOM == DLL_SIGALOJA						// Somente SIGALOJA.DLL
	Return( EQUIP_DLL_SIGALOJA )
EndIf

If cModel == NIL									// Se nao passou nenhum parametro, somente retorna o conteudo
	Return( Self:aIsAutocom[nTipo] )
ElseIf Self:CreateAutoCom() 
	If nTipo == EQUIP_IMPFISCAL						// Retorna os equipamentos homologados na AUTOCOM
		nRet :=Self:oAutocom:IFListar()					// de cada categoria 
		lEcf := .T.
	ElseIf nTipo == EQUIP_PINPAD
		nRet :=Self:oAutocom:PinPadLis()
	ElseIf nTipo == EQUIP_CMC7
		nRet :=Self:oAutocom:CMC7Lis()
	ElseIf nTipo == EQUIP_GAVETA
		nRet :=Self:oAutocom:GavetaLis()
	ElseIf nTipo == EQUIP_IMPCUPOM
		nRet :=Self:oAutocom:ImpCupLis()
	ElseIf nTipo == EQUIP_LEITOR
		nRet :=Self:oAutocom:LeitorLis()
	ElseIf nTipo == EQUIP_BALANCA
		nRet :=Self:oAutocom:BalancaLis()
	ElseIf nTipo == EQUIP_DISPLAY
		nRet :=Self:oAutocom:DisplayLis()
	ElseIf nTipo == EQUIP_IMPCHEQUE
		nRet :=Self:oAutocom:CHListar()
	EndIf
	Self:SelectCountryDevice( @Self:oAutocom:cBuffer, lEcf )			// Retorna apenas os perifericos utilizados
	aAutocom  := Self:LJStrToArr(Self:oAutocom:cBuffer)		// Transforma a string em array
	If AScan(aAutocom, {|x| AllTrim(Upper(cModel))==AllTrim(Upper(x))}) == 0
		Self:aIsAutocom[nTipo] := EQUIP_DLL_SIGALOJA		// O modelo nao esta homologado na AUTOCOM
		If nMVAUTOCOM == DLL_AUTOCOM
			STFMessage("IsAutocom", "ALERT", "O equipamento "+cModel+" não está homologado para trabalhar com a AUTOCOM. Configure corretamente o Cadastro de Estações.")
			STFShowMessage("IsAutoCom")
		EndIf
		Return(Self:aIsAutocom[nTipo])
	Else
		Self:aIsAutocom[nTipo] := EQUIP_DLL_AUTOCOM		// O modelo esta homologado
	EndIf
EndIf

Return Self:aIsAutocom[nTipo]
         

//--------------------------------------------------------
/*/{Protheus.doc}DispTorList
Lista os displays torre homologados                  
@param   	ExpC1 - Lista de equipamentos homologados                          
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DispTorList( cBuffer ) Class STFECFCONTROL 

Local nRet := -1 

Default cBuffer		:= ""

nRet := Self:ExecDLLRet(Self:nHnd, 114, @cBuffer)

//Retorna apenas os perifericos utilizados
Self:SelectCountryDevice( @cBuffer )

Return  nRet     


//--------------------------------------------------------
/*/{Protheus.doc}DispTorOpe
SIGALOJA / SIGAFRT - chamada a partir da Method 
 LjOpenDevices() (LOJXFUNB.prw)             
@param   	ExpC1 - Indica o modelo a ser utilizado                    
@param      ExpC2 - Indica a porta que sera' utilizada para comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DispTorOpe( cModel, cPort ) Class STFECFCONTROL    

Local nRet := -1

Default cModel		:= ""
Default cPort		:= ""

nRet := ExeDLLRun2(Self:nHnd, 115, cModel+","+cPort)
 
Self:DispTorStat(nHandle)

Return  nRet 


//--------------------------------------------------------
/*/{Protheus.doc}DispTorClos
Faz o fechamento da porta do display torre                  
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Indica a porta que sera' utilizada para comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DispTorClos( nDisTHnd, cPort ) Class STFECFCONTROL 

Local nRet := -1   //Retorno

Default nDisTHnd			:= 0			
Default cPort	   			:= ""


nRet := ExeDLLRun2(Self:nHnd, 116, Str(nDisTHnd)+","+cPort)

Return  nRet 


//--------------------------------------------------------
/*/{Protheus.doc}DispTorEnv
Envia mensagem para o display torre              
@param   	ExpN1 - Handle da SIGALOJA.DLL                        
@param   	ExpC2 - Texto da mensagem   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DispTorEnv( nDisTHnd, cTexto ) Class STFECFCONTROL

Local nRet := -1

Default nDisTHnd			:= 0			
Default cTexto	   			:= ""

nRet := ExeDLLRun2(Self:nHnd, 117, Str( nDisTHnd )+','+cTexto)

Return nRet       


//--------------------------------------------------------
/*/{Protheus.doc}EcfTamCup
Verifica na Impressora o tamanho do Cupom Fiscal                   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Valor do Tamanho 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method EcfTamCup(cBuffer) Class STFECFCONTROL  

Local nTamcup	:= 6	// Verifica o tamanho do Cupom Fiscal na Impressora

nTamCup := STBLenReceipt(cBuffer)
                                                                    
Return nTamcup


//--------------------------------------------------------
/*/{Protheus.doc}ExistEquip
Verifica se o equipamento em questao esta homologado na TotvsApi.DLL/SO                 
@param1   	EXPn1 - Tipo                         
@param2   	EXPc1 - Modelo
@param3   	EXPl1 -  
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ExistEquip(nTipo, cModel, lComOk) Class STFECFCONTROL

Local cBuffer 	:= ""											//Retorno dos perifericos
Local nCount 	:= 0    										//Variavel de controle contador
Local aPerife	:= {}											//Array com os perifericos retornados    
Local lRetorno	:= .F.											//Retorno da Method    
Local lEcf      := .F.											
Local oRet 		:= NIL
Local oTovsApi	:= NIL  

Default nTipo			:= 0			
Default cModel	   		:= ""
Default lComOk			:= .F.			

    
oTovsApi := Self:GetTotvsApi()     

If oTovsApi == Nil
	Self:CreateTotvsApi()
	oTovsApi := Self:GetTotvsApi()
EndIf

If nTipo == EQUIP_IMPFISCAL
	oRet := oTovsApi:ListarEcf()					
	lEcf := .T. 
ElseIf nTipo == EQUIP_PINPAD
	oRet := oTovsApi:ListPinPad()
ElseIf nTipo == EQUIP_CMC7
	oRet := oTovsApi:ListarCMC7() 
	lEcf := .T.		
ElseIf nTipo == EQUIP_GAVETA
	oRet := oTovsApi:ListGaveta()
ElseIf nTipo == EQUIP_IMPCUPOM
	oRet := oTovsApi:ListImpCup()
ElseIf nTipo == EQUIP_LEITOR
	oRet := oTovsApi:ListLeitor()
ElseIf nTipo == EQUIP_BALANCA
	oRet := oTovsApi:ListBalanc()
ElseIf nTipo == EQUIP_DISPLAY
	oRet := oTovsApi:LstDisplay()
ElseIf nTipo == EQUIP_IMPCHEQUE
	oRet := oTovsApi:ListImpChq()
	lEcf := .T.		
ElseIf nTipo == EQUIP_IMPNAOFISCAL	
	oRet := oTovsApi:ListarEcNf()
	lEcf := .T.  
EndIf
    
For nCount := 1 To oRet:Count()
	cBuffer += '"' + oRet:Elements(nCount):cDescricao + '",' + oRet:Elements(nCount):cPais + ',"' + oRet:Elements(nCount):cCodEcf + '",'
Next
    
//Retorna apenas os perifericos utilizados
  	Self:SelectCountryDevice(@cBuffer, lEcf)			

//Transforma a string em array	
aPerife  := Self:LJStrToArr(cBuffer)		

If Ascan(aPerife, {|x| AllTrim(Upper(cModel))==AllTrim(Upper(x))}) != 0
	//Abre comunicacao com a totvsapi
	If Self:oImpFisc = NIL 
		If oTovsApi:AbrirCom() <> -1
			//Instancia o objeto LJCImpressora 
			
			If nTipo == EQUIP_IMPNAOFISCAL
				Self:oImpFisc := LJCImpNFiscal():New()
			Else
				Self:oImpFisc := LJCImpressora():New()
			EndIf
			
			lRetorno := .T.
			lComOk := .T.
		Else		
			MsgAlert("Problemas ao abrir comunicação com a DLL TotvsApi")//"Problemas ao abrir comunicação com a DLL TotvsApi"				
		EndIf
	Else
		lRetorno := .T.
		lComOk := .T.		
	EndIf							
EndIf   
	
Return lRetorno

//--------------------------------------------------------
/*/{Protheus.doc}TreatStatus
Fecha comunicacao com a Balanca                   
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method TreatStatus(oValor, cType, nRet) Class STFECFCONTROL

Local cRetorno := ""				//Retorno da Method

Default oValor			:= Nil			
Default cType	   		:= ""
Default nRet			:= 0	
	
Do Case
	
	Case cType == "1"					
		//Obtem a Hora da Impressora dd/mm/aaaa hh:mm:SS (19 bytes)
        	cRetorno := SubStr(oValor, 12, 8)

	Case cType == "2"					
		//Obtem a Data da Impressora dd/mm/aaaa hh:mm:SS (19 bytes)
		cRetorno := SubStr(oValor, 1, 10)
	
	Case cType == "3"					
		//Verifica se tem Papel 
		If oValor:lPapelAcab .Or. oValor:lFimPapel
			cRetorno := 0
			nRet := 1
		Else
			cRetorno := 1
		EndIf
			
	Case cType == "4"					
		//Verifica se eh possivel cancelar TODOS ou so o ULTIMO item registrado
		cRetorno := oValor
		
	Case cType == "5"					
		//Se o Cupom esta Fechado
		If oValor:lCfAberto
			cRetorno := 1
			nRet := 7
		Else
			cRetorno := 0
		EndIf	
		
	Case cType == "6"					
		//Retorna o suprimento da impressora
		cRetorno := oValor
	
	Case cType == "7"					
		//ECF permite desconto por Item
		If oValor
			cRetorno := 0
		Else
			cRetorno := 1
		EndIf			

	Case cType == "8" 					
		//Verifica se o dia anterior foi fechado, reducaoz pendente
		If oValor:lRedZPend
			cRetorno := 0
			nRet := 10
		Else
			cRetorno := 1
		EndIf

	Case cType ==  "9"					
		//Verifica o Status do ECF
		cRetorno := 0
	
	Case cType == "10"	   				
		//Verifica se todos os itens foram impressos
		If oValor
			cRetorno := 0
		Else
			cRetorno := 1
			nRet := 1				
		EndIf	
	
	Case cType == "11"					
		//Retorna se eh um Emulador de ECF (0=Emulador / 1=ECF)
		If oValor
			cRetorno := 1
			nRet := 1
		Else
			cRetorno := 0
		EndIf	
	
	Case cType == "12"					
		//Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
		If oValor
			cRetorno := 0
		Else
			cRetorno := 1
			nRet := 1
		EndIf
	
	Case cType == "13" 					
		//Verifica se o ECF Arredonda o Valor do Item
		If oValor == "A"
			cRetorno := 0
		Else
			cRetorno := 1
			nRet := 1
		EndIf
	
	Case cType == "14"					
		//Verifica se a Gaveta Acoplada ao ECF esta (0=Fechada / 1=Aberta)
		If oValor:lGavAberta
			cRetorno := 1
			nRet := 1
		Else
			cRetorno := 0
		EndIf
	
	Case cType == "15"					
		//Verifica se o ECF permite desconto apos registrar o item (0=Permite) 
		If oValor
			cRetorno := 0
		Else
			cRetorno := 1
			nRet := 1
		EndIf
	
	Case cType == "16" 					
		//Verifica se exige o extenso do cheque
		If oValor
			cRetorno := 0
		Else
			cRetorno := 1
		EndIf
	
	Case cType == "17" 					
		//Retorna o valor da venda bruta em caracter
		cRetorno := StrZero(oValor)
	
	Case cType == "18" 					
		//Retorna o valor do GT em string
		cRetorno := oValor
	
	Case cType == "19" 					
		//Obtem a Data do movimento dd/mm/aaaa hh:mm:SS (19 bytes)
		cRetorno := SubStr(oValor, 1, 10)
	
	Case cType == "20" 					
		//Retorna o CNPJ	
		cRetorno := oValor
		
	Case cType == "21"
		//Retorna o IE 
		cRetorno := oValor
	
	Case cType == "22"
		//Retorna o CRZ	
		cRetorno := oValor
		
	Case cType == "23"
		//Retorna o CRO
		cRetorno := oValor
		
	Case cType == "24"
		//Retorna a letra indicativa de MF adicional
		cRetorno := oValor 
		
	Case cType == "25"
		//Retorna Tipo de ECF
		cRetorno := oValor
		
	Case cType == "26"
		//Retorna Marca do ECF
		cRetorno := oValor
	
	Case cType == "27"
		//Retorna Modelo do ECF    
		cRetorno := oValor
	
	Case cType == "28"
		//Retorna o Versão atual do Software Básico do ECF gravada na MF
		cRetorno := oValor
	
	Case cType == "29"
		//Retorna a Data de instalacao da versao atual do Software Basico gravada na Memoria Fiscal do ECF
		cRetorno := StrTran( SubStr(oValor, 1, 10) , "/", "")
	
	Case cType == "30"	
		//Retorna o Horario de instalacao da versao atual do Software Básico gravada na Memoria Fiscal do ECF
		cRetorno := StrTran( SubStr(oValor, 1, 8), "/", "")
	
	Case cType == "31"
		//Retorna o Numero de ordem sequencial do ECF no estabelecimento usuario
		cRetorno := oValor
	
	Case cType == "32"
		//Retorna o Grande Total Inicial
		cRetorno := oValor 
	
	Case cType == "33"
		//Retorna o Grande Total Final
		cRetorno := oValor
	
	Case cType == "34"
		//Retorna a Venda Bruta Diaria
		cRetorno := oValor
	
	Case cType == "35"
		//Retorna o Contador de Cupom Fiscal CCF
		cRetorno := oValor
	
	Case cType == "36"
		//Retorna o Contador Geral de Operacao Nao Fiscal
		cRetorno := oValor
				
	Case cType == "37"
		//Retorna o Contador Geral de Relatorio Gerencial
		cRetorno := oValor
	
	Case cType == "38"
		//Retorna o Contador de Comprovante de Credito ou Debito
		cRetorno := oValor			
	
	Case cType == "39"
		//Retorna a Data e Hora do ultimo Documento Armazenado na MFD no formato ddmmaahhmmss (12 bytes)
		cRetorno := StrTran(oValor, "/", "")
		cRetorno += StrTran(oValor, ":", "")
		
	Case cType == "40"
		//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CODIGOS DE IDENTIFICACAO DE ECF
		cRetorno := SubStr(oValor, 1, 6)

	Case cType == "45"
		//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CODIGOS DE IDENTIFICACAO DE ECF
		cRetorno := SubStr(oValor, 1, 6)	
		
	Case cType == "46"
		//Retorna o Codigo da Impressora Referente a TABELA NACIONAL DE CODIGOS DE IDENTIFICACAO DE ECF
		cRetorno := oValor	
	
EndCase
		
Return cRetorno


//--------------------------------------------------------
/*/{Protheus.doc}LoadForm
Prepara o array com as formas                   
@param   	EXPn1 - Handle de uso da DLL                         
@param   	EXPc1 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method LoadForm(cDados) Class STFECFCONTROL

Local aRetorno := {}				//Retorno do metodo
Local cDelimit := "|"				//Delimitador
Local cForma	:= ""				//Forma de pagamento
Local nValue	:= 0				//Valor do pagamento
Local lLoop		:= .T.				//Variavel de controle do While

Default cDados := ""
		
//Retira o delimitador do inicio da string
If Substr(cDados, 1, 1) == cDelimit
	cDados := Substr(cDados, 2)
EndIf

//Retira o delimitador do fim da string
If Substr(cDados, Len(cDados), 1) == cDelimit
	cDados := Substr(cDados, 1, Len(cDados) - 1)
EndIf

While lLoop
    //Procura o delimitador na string
	nPos := At(cDelimit, cDados)
    
    //Verifica se encontrou o delimitador
	If nPos > 0 
		cForma := Substr(cDados, 1, nPos-1)
		cDados := Substr(cDados, nPos + 1)
		
		//Procura o delimitador na string
		nPos := At(cDelimit, cDados)
    
	    //Verifica se encontrou o delimitador
		If nPos > 0 
			nValue := Val(Substr(cDados, 1, nPos-1))
			cDados := Substr(cDados, nPos + 1)
			
			AADD(aRetorno, {cForma, nValue})			
		Else
			AADD(aRetorno, {cForma, Val(cDados)})
			lLoop := .F.
		EndIf
	Else
		lLoop := .F.
	EndIf
End    

Return aRetorno


//--------------------------------------------------------
/*/{Protheus.doc}TratRedZ
Prepara a string com os dados da reducaoZ                 
@param   	EXPo1 - Objeto de dados reduçãoZ                         
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method TratRedZ(oDadosRedZ) Class STFECFCONTROL
Local cRetorno 	:= ""				//Retorno da Method
Local Separador := "|"				//Separador da string
Local nCount	:= 0				//Variavel auxiliar contador
Local cAux 		:= ""

Default oDadosRedZ := Nil

IF ExistFunc("LjTratRedZ")
	cRetorno := LjTratRedZ(oDadosRedZ)
Else		
	//Data movimento
	cRetorno += DTOC(oDadosRedZ:dDataMov) + Separador
	//Numero do ecf
	cRetorno += oDadosRedZ:cNumEcf + Separador
	//Numero de serie
	cRetorno += oDadosRedZ:cNrSerie  + Separador
	//Numero de reducoes
	cRetorno += oDadosRedZ:cNumRedZ + Separador
	//GrandTotal
	cRetorno += AllTrim(Str(oDadosRedZ:nGranTotal)) + Separador
	//Cupom inicial
	cRetorno +=	oDadosRedZ:cNumCupIni + Separador
	//Cupom Final
	cRetorno +=	oDadosRedZ:cNumCupFim + Separador
	//Cancelados
	cRetorno +=	AllTrim(Str(oDadosRedZ:nTotCancel)) + Separador
	//Venda liquida
	cRetorno +=	AllTrim(Str(oDadosRedZ:nVendaLiq)) + Separador
	//Descontos
	cRetorno += AllTrim(Str(oDadosRedZ:nTotDesc)) + Separador
	//Substituidos
	cRetorno += AllTrim(Str(oDadosRedZ:nTotSubst)) + Separador
	//Isento
	cRetorno += AllTrim(Str(oDadosRedZ:nTotIsent)) + Separador
	//Nao tributado
	cRetorno += AllTrim(Str(oDadosRedZ:nTotNTrib)) + Separador
	//Data da reducao
	cRetorno += DTOC(oDadosRedZ:dDataRed) + Separador
	//Numero do cupo da ReducaoZ
	cRetorno += oDadosRedZ:cCoo + Separador
	//Outros recebimentos
	cRetorno += Replicate("0", 16) + Separador
	
	cAux := ""
	//Aliquota + Base de calculo + imposto pago "S05,00 00000000070.00 0000000003.5"
	For nCount := 1 to oDadosRedZ:oImpISS:Count()
		cAux += StrTran( "S" + Transform(oDadosRedZ:oImpISS:Elements(nCount):nAliquota, "@E 99.99"), " ","0")
		cAux += Space(1) + Padl(AllTrim(StrTran(Transform(oDadosRedZ:oImpISS:Elements(nCount):nBase, "@E 99999999999.99"), ",", ".")), 14, "0")
		cAux += Space(1) + Padl(AllTrim(StrTran(Transform(oDadosRedZ:oImpISS:Elements(nCount):nImposto, "@E 99999999999.99"), ",", ".")), 14, "0") + ";"
	Next
		
	cRetorno += Padl(AllTrim(Str(oDadosRedZ:nTotIss)), 14, "0") + ";" + cAux + Separador
	
	//Cro - contador de reinicio de operacoes
	cRetorno += Padl(AllTrim(Str(Val(oDadosRedZ:cCro))), 3, "0") + Separador
	
	//Total de desconto de ISS
	cRetorno += AllTrim(Str(oDadosRedZ:nTotDesISS)) + Separador
	
	//Total de cancelamento de ISS
	cRetorno += AllTrim(Str(oDadosRedZ:nTotCanISS)) + Separador
	
	//Quantidade de aliquota tributadas cadastradas no ecf
	cRetorno += AllTrim(Str(oDadosRedZ:oImpostos:Count())) + Separador
	
	//Aliquota + Base de calculo + imposto pago "T18,00 00000000003.93 0000000000.70"
	For nCount := 1 To oDadosRedZ:oImpostos:Count()
		cRetorno += "T" + Transform(oDadosRedZ:oImpostos:Elements(nCount):nAliquota, "@E 99.99")
		cRetorno += Space(1) + Padl(AllTrim(StrTran(Transform(oDadosRedZ:oImpostos:Elements(nCount):nBase, "@E 99999999999.99"), ",", ".")), 14, "0")
		cRetorno += Space(1) + Padl(AllTrim(StrTran(Transform(oDadosRedZ:oImpostos:Elements(nCount):nImposto, "@E 99999999999.99"), ",", ".")), 14, "0") + Separador
	Next
EndIf
		
Return cRetorno

//--------------------------------------------------------
/*/{Protheus.doc}PrepReport
Prepara o relatorio para o ecf                   
@param   	EXPn1 - Dados                         
@param   	EXPc1 - Quantidade de vias
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPo1 - Objeto 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrepReport(cDados, nVias) Class STFECFCONTROL
	                                               
Local oRetorno 	:= Nil					//Retorno da Method do tipo LJCRelatoriosEcf
Local cDelimit 	:= CHR(10)				//Delimitador
Local cDelimit13:= CHR(13)				//Delimitador sera retirado da string 
Local lLoop		:= .T.					//Variavel de controle do While
Local cAux		:= ""				    //Variavel para guardar linha a linha do relatorio
Local nCount	:= 1					//Variavel de controle contador
Local nViasAux	:= 1					//Controla o numero de vias
Local cTexto	:= ""					//Guarda o conteudo da variavel cDados

Default cDados	:= ""		
Default nVias 	:= 0
   	
//Instancia o objeto LJCRelatoriosEcf
oRetorno := LJCRelatoriosEcf():New() 
   			
//Retira o delimitador do inicio da string
If Substr(cDados, 1, 1) == cDelimit
	cDados := Substr(cDados, 2)
EndIf

//Retira o delimitador do fim da string
If Substr(cDados, Len(cDados), 1) == cDelimit
	cDados := Substr(cDados, 1, Len(cDados) - 1)
EndIf

//Guarda o conteudo original
cTexto := cDados

While lLoop
    //Procura o delimitador na string
	nPos := At(cDelimit, cDados)
    
    //Verifica se encontrou o delimitador
	If nPos > 0 
		cAux := Substr(cDados, 1, nPos-1)
		cDados := Substr(cDados, nPos + 1)
		
		If cAux == cDelimit .OR. cAux == cDelimit13
			oRetorno:ADD(nCount++, " ")
		Else
			//Retira esse caracter para nao apresentar erro na impressora
			cAux := Alltrim( StrTran(cAux, cDelimit13, " "))
			oRetorno:ADD(nCount++, cAux)
		Endif
	Else         
		//Retira esse caracter para nao apresentar erro na impressora
		cDados := Alltrim( StrTran(cDados, cDelimit13, " "))
	
		oRetorno:ADD(nCount++, cDados)	
		
		If nViasAux == nVias
			lLoop := .F.
		Else
			//Adiciona a proxima via
			nViasAux++
			
			oRetorno:ADD(nCount++, Space(40))
			oRetorno:ADD(nCount++, Replicate("-", 15) + AllTrim(Str(nViasAux)) + " Via" + Replicate("-", 15))
			oRetorno:ADD(nCount++, Space(40))
			
			cDados := cTexto
		EndIf
	EndIf
End    
	
Return oRetorno


//--------------------------------------------------------
/*/{Protheus.doc}DscTotaliz
Retorna a descricao do totalizador                
@param   	EXPc1 - Totalizador                        
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPc1 - cRetorno
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DscTotaliz(cTotaliz) Class STFECFCONTROL
	
Local cRetorno 	:= ""						//Retorno da Method
Local oGlobal	:= Nil						//Objeto do tipo LJCGlobal
Local oTotaliz	:= Nil						//Objeto do tipo LJcTotalizeresEcf
Local oRetorno	:= Nil						//Retorno da impressora do tipo LJCRetImpressora
Local nCount	:= 1						//Variavel auxiliar do tipo contador   

Default cTotaliz	:= ""

If Self:cTypeImp == "TOTVSAPI"
	
	oGlobal := LJCGlobal():Global()
	
	If oGlobal:Funcoes():IsNumeric(cTotaliz)
		
		oRetorno := Self:oImpFisc:Totaliz()
		
		oTotaliz := oRetorno:oRetorno
		
		For nCount := 1 To oTotaliz:Count()
			If Val(oTotaliz:Elements(nCount):cIndice) == Val(cTotaliz)
				cRetorno := oTotaliz:Elements(nCount):cTotaliz
				Exit
			EndIf
		Next 
		
	Else
		cRetorno := cTotaliz
	EndIf 
	
EndIf
	
Return cRetorno


//--------------------------------------------------------
/*/{Protheus.doc}PrepMsgPro
 Prepara o relatorio para o ecf                  
@param   	EXPc1 - Dados                        
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrepMsgPro(cDados) Class STFECFCONTROL
	
Local oRetorno 	:= Nil					//Retorno da Method do tipo LJCMensagensPromocionais
Local cDelimit 	:= CHR(10)				//Delimitador
Local cDelimit13:= CHR(13)				//CHR(13) sera retirado
Local lLoop		:= .T.					//Variavel de controle do While
Local cAux		:= ""				    //Variavel para guardar linha a linha do relatorio
Local nCount	:= 1					//Variavel de controle contador

Default cDados	:= ""
   	
//Instancia o objeto LJCMensagensPromocionais
oRetorno := LJCMensagensPromocionais():New()
   			
//Retira o delimitador do inicio da string
If Substr(cDados, 1, 1) == cDelimit
	cDados := Substr(cDados, 2)
EndIf

//Retira o delimitador do fim da string
If Substr(cDados, Len(cDados), 1) == cDelimit
	cDados := Substr(cDados, 1, Len(cDados) - 1)
EndIf

While lLoop
    //Procura o delimitador na string
	nPos := At(cDelimit, cDados)
	
    //Verifica se encontrou o delimitador
	If nPos > 0 
		cAux := Substr(cDados, 1, nPos-1)
		cDados := Substr(cDados, nPos + 1)
		
		If cAux != cDelimit .AND. !Empty(cAux)
			//Retira esse caracter para nao apresentar erro na impressora
			cAux := Alltrim( StrTran(cAux, cDelimit13, " "))
			
			oRetorno:ADD(nCount++, cAux)
			cAux := ""
		Endif
	Else
		//Retira esse caracter para nao apresentar erro na impressora
		cDados := Alltrim( StrTran(cDados, cDelimit13, " "))

		oRetorno:ADD(nCount++, cDados)
		lLoop := .F.						
	EndIf
End    
	
Return oRetorno


//--------------------------------------------------------
/*/{Protheus.doc}PrepSupSan
repara as formas de pagamento para suprimento e a sangria                
@param   	EXPc1 - Dados                       
@param   	EXPn1 - Valor Total
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrepSupSan(cDados, nVlrTotal) Class STFECFCONTROL
	
Local oRetorno 	:= Nil					//Retorno da Method do tipo LJCFormasECF
Local cDelimit 	:= "|"					//Delimitador
Local lLoop		:= .T.					//Variavel de controle do While
Local nCount	:= 1					//Variavel de controle contador
Local oForma    := Nil					//Objeto da Method do tipo LJCFormaECF
Local cForma    := ""					//Descricao da forma de pagamento
Local nValue    := 0					//Valor da forma da pagamento
Local cIndice   := ""					//Indice de insercao da forma de pagamento

Default cDados		:= ""		
Default nVlrTotal 	:= 0
   	
//Instancia o objeto LJCFormasECF
oRetorno := LJCFormasECF():New()  
   	
//Envia forma de pagamento padrao caso nao chegue nenhuma
   	If Empty(cDados)   
    //Carrega indice da forma, seguencia
	cIndice := cValToChar(nCount) 
    //Carrega descricao da forma
	cForma	:= "DINHEIRO"              
	//Carrega valor pago por essa forma
	nValue  := nVlrTotal
		    
	//Instancia objeto com o forma
	oForma 	:= LJCFormaEcf():New(cIndice, cForma, .F., nValue)
	                          
	//Adiciona objeto a lista de formas de pagamento					
	oRetorno:ADD(Upper(AllTrim(cForma)), oForma, .T.) 
	
	Return oRetorno
   	EndIf
   			
//Retira o delimitador do inicio da string
If Substr(cDados, 1, 1) == cDelimit
	cDados := Substr(cDados, 2)
EndIf

//Retira o delimitador do fim da string
If Substr(cDados, Len(cDados), 1) == cDelimit
	cDados := Substr(cDados, 1, Len(cDados) - 1)
EndIf

cDados := AllTrim(cDados)

While lLoop
    //Procura o delimitador na string
	nPos := At(cDelimit, cDados)
    
    //Verifica se encontrou o delimitador
	If nPos > 0 
	    //Carrega descricao da forma
		cForma := Substr(cDados, 1, nPos-1)
		cDados := Substr(cDados, nPos + 1)
		                           
		nPos := At(cDelimit, cDados)
		
		//Carrega valor pago por essa forma
		nValue := Val(IIF(nPos > 0, Substr(cDados, 1, nPos-1),Substr(cDados, 1 )) )
		cDados := Substr(cDados, nPos + 1)
		
		If cForma <> cDelimit .AND. cForma <> CHR(13) .AND. !Empty(cForma)   
		    //Carrega indice da forma, seguencia
			cIndice := cValToChar(nCount)
			//Instancia objeto com o forma
			oForma := LJCFormaEcf():New(cIndice, cForma, .F., nValue)
			//Adiciona objeto a lista de formas de pagamento					
			oRetorno:ADD(Upper(AllTrim(cForma)), oForma, .T.)
			
			cForma := ""
			nValue := 0 
			nCount++  
		Endif
	Else
		lLoop := .F.						
	EndIf
End    
	
Return oRetorno
 
    
//--------------------------------------------------------
/*/{Protheus.doc}xPrintFis
Indica se esta utilizando a AUTOCOM                   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPo1 - objeto de retorno
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method xPrintFisc() Class STFECFCONTROL
Local lRet := Self:oImpFisc <> Nil

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc}OpenPrintCommunication
Abre a comunicacao com a impressora                
@param   	EXPc1 - Modelo da impressora                         
@param   	EXPc2 - Porta de comunicacao 
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method OpenPrintCommunication( cModel, cPort ) Class STFECFCONTROL 

Local nRet		:=-1			// Retorno da Method
Local nHdlMain	:= 0			// Handle do objeto da tela do protheus
Local oHdlMain 					// Objeto da janela
Local lComOk	:= .F.			//Controla se abriu comunicacao com a totvsapi
Local oRet		:= NIL
Local oTotvsApi	:= Self:GetTotvsApi()  
Local lRet 		:= .F.

//Velocidade da porta - foi colocado aqui para facilitar a manutenção senão seria colocada dentro da sigaloja(p/ evitar compilacao de dll) 
//inserido dentro da camada da impressora Epson Nao Fiscal essa validação das velocidades de porta
Local cVelocidade:= GetPvProfString("LogDll", "VelPorta", "0" , GetClientDir() + "sigaloja.ini")
Local lContinua	:= .T.

Default cModel := ""
Default cPort  := ""

//Verifica se o tema eh FLAT ou normal
oHdlMain := GetWndDefault()
nHdlMain := oHdlMain:hWnd

If !Empty( cModel ) .AND. !Empty( cPort )  
	If Valtype(oTotvsApi) <> "O"   
		If Self:CreateTotvsApi()
			oTotvsApi	:= Self:GetTotvsApi() 
			lRet := .T.
		EndIf
	Else
		lRet := .T.
	EndIf   
	
	If lRet
		If Self:ExistEquip(EQUIP_IMPNAOFISCAL, cModel, @lComOk)
			If lComOk
				oRet := Self:oImpFisc:AbrirPorta(cModel, cPort, oTotvsApi)					
				If oRet:lRetorno			
					nRet := 0
				Else
					nRet := -1
					Self:oImpFisc := Nil
					Self:SetTotvsApi(Nil)
				EndIf 
			EndIf
			lContinua := .F.
		EndIf
	EndIf

	If Self:CreateAutoCom()
		If Self:IsAutocom( EQUIP_IMPFISCAL, cModel ) == EQUIP_DLL_SIGALOJA  .AND. lContinua
			Self:aIsAutocom[ EQUIP_IMPFISCAL ] := EQUIP_DLL_SIGALOJA
			STWCheckDLL( .T. )								// Verifica se a SIGALOJA.DLL esta aberta
			If lLinux
				nRet :=	ExeDLLRun2(Self:nHnd, 131, STWTipoCom(cPort) + "," + STWModelImp(cModel) + "," + STWCPrtUSB(cModel, cPort,.T.) + "," + "0" )
				nRet := Iif(nRet == -6, 0, nRet) 
			Else
				nRet :=	ExeDLLRun2(Self:nHnd, 131, cModel + "," + cPort + "," + cVelocidade + "," + AllTrim( Str( nHdlMain ) ) )
			EndIf
			lContinua := .F.
			Self:cTypeImp := "EQUIP_DLL_SIGALOJA"
		EndIf
	EndIf
 
	If lContinua                 
		STWCheckDLL( .T. )									// Verifica se a SIGALOJA.DLL esta aberta
		nRet := ExeDLLRun2(Self:nHnd, 131, cModel + "," + cPort + "," + cVelocidade + "," + AllTrim( Str( nHdlMain ) ) )
		Self:cTypeImp := "DLL_SIGALOJA"
	EndIf
EndIf

//Determina retorno do Handle de comunicacao da Impressora ao Conectar (necessario para comunicacao com Gaveta e demais perifericos)
Self:nImpHndNfis := nRet
Return nRet 

//--------------------------------------------------------
/*/{Protheus.doc}ClosePrintCommunication
Fecha a comunicacao com a impressora
@type 		function                
@param   	EXPc1 - Modelo da impressora                         
@param   	EXPc2 - Porta de comunicacao 
@author  	julio.nery
@version 	P12
@since   	07/11/2019
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
/*/
//--------------------------------------------------------
Method ClosePrintCommunication( cModel, cPort ) Class STFECFCONTROL 
Local nRet		:= -1			// Retorno da Method
Local nHdlMain	:= 0			// Handle do objeto da tela do protheus
Local oHdlMain 					// Objeto da janela
Local lComOk	:= .F.			//Controla se abriu comunicacao com a totvsapi
Local oRet		:= NIL
Local lContinua	:= .T.

Default cModel := ""
Default cPort  := ""

//Verifica se o tema eh FLAT ou normal
oHdlMain := GetWndDefault()
nHdlMain := oHdlMain:hWnd

If !Empty( cModel ) .AND. !Empty( cPort )
	If Self:ExistEquip(EQUIP_IMPNAOFISCAL, cModel, @lComOk)
		If lComOk
			oRet := Self:oImpFisc:FechaPorta()
			If oRet:lRetorno
				nRet := 0
			Else
				Sleep(1000)
				nRet := -1				
			EndIf 
		EndIf
		lContinua := .F.
	EndIf
 
	If lContinua
		STWCheckDLL( .T. )	// Verifica se a SIGALOJA.DLL esta aberta
		nRet := ExeDLLRun2(Self:nHnd, 132, "0" + "," + cPort)
	EndIf
EndIf

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc}PrintTextNotFiscal
Imp texto nao fiscal                   
@param   	EXPc1 - Texto não fiscal a ser impresso
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method PrintTextNotFiscal(cTexto,lCheckDLL) Class STFECFCONTROL
Local nRet			:= 0 	// Retorno
Local oRet			:= Nil  // Objeto de retorno
Local lContinua 	:= .T.
Local cAuxTxt		:=	""
Local cPorta 		:= STFGetStat("PORTIF")
Local cModelo 		:= STFGetStat("IMPFISC") 

Default cTexto		:= ""
Default lCheckDLL	:= .T.

//Não imprimir o NFC-e e SAT, somente os gerenciais como TEF, Sangria, Suprimento e outros
If !(TAG_QRCODE_INI $ cTexto) .AND. ;					//Se não for impressão de NFC-e e SAT, ambos tem QRCODE. 
	 Alltrim(StrTran(StrTran(cTexto,CHR(13),""),CHR(10),"")) <> TAG_GUIL_INI+TAG_GUIL_FIM		//Se não for Guilhotina

	cTexto		:= LjxLJ7101(cTexto)
EndIf

If lLjxCtImpRD
	LjxCtImpRD( .T. , .T.)
EndIf

STWOpenPrintCommunication(cModelo, cPorta)

If Self:oImpFisc <> Nil
	oRet := Self:oImpFisc:ImpTextoNf(cTexto)

	If oRet:lRetorno			
		nRet := 0
	Else
		Sleep(3000)
		nRet := -1   	
	EndIf 

	FreeObj(oRet)
	lContinua := .F.
EndIf

If lContinua
	cAuxTxt	:=  cTexto
	If ExistFunc("RemoveChar")
		While At('\',cAuxTxt) > 0
			cAuxTxt := RemoveChar(cAuxTxt,"\","-")
		End
	Else
		cAuxTxt := StrTran(cAuxTxt,"\","-")
	EndIf
	
	STWCheckDLL( lCheckDLL )				//Verifica se a SIGALOJA.DLL esta aberta
	If lLinux
		nRet := ExeDLLRun2(Self:nHnd, 133, EncodeUtf8(cAuxTxt) + "\0\0\0" )
	Else
		nRet := ExeDLLRun2(Self:nHnd, 133, "0" + "\" + cAuxTxt )
	EndIf
EndIf

//Fecha a comunicação após utilizar para não travar a porta
Self:ClosePrintCommunication(cModelo, cPorta)

If lLjxCtImpRD
	LjxCtImpRD( .F. , .T.)
EndIf

Return nRet


//--------------------------------------------------------
/*/{Protheus.doc}ArqMFD
Fecha comunicacao com a Balanca                   
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method ArqMFD( cDataIni, cDataFim	, cCooIni	,cCooFim,;
				cChPriv, cChPubl	, cPath		,cFile)  Class STFECFCONTROL  
				
Local cDadoIni 	:= "" 	// Dados Iniciais
Local cDadoFim 	:= "" 	// Dados fim
Local cTypeDown	:= "" 	// Tipo  
Local cUsuario  := "01" // Usuario
Local nRet		:= -1  	// Retorno

Default cDataIni 	:= ""
Default cDataFim	:= ""		
Default cCooIni 	:= ""
Default cCooFim		:= ""		
Default cChPriv		:= ""
Default cChPubl 	:= ""		
Default cPath		:= ""      
Default cFile  		:= ""		


If !Empty(cCooIni) .AND. !Empty(cCooFim)
	cTypeDown 	:= "C"
	cDadoIni 	:= cCooIni
	cDadoFim 	:= cCooFim
Else
	cTypeDown	:= "D"           
	cDadoIni 	:= cDataIni
	cDadoFim 	:= cDataFim
EndIf

If Self:ChkAutocom() == DLL_SIGALOJA			  			
	nRet := ExeDLLRun2(Self:nHnd, 123, Str(Self:nImpHnd)+ "," + cPath + "," + cDadoIni + "," + cDadoFim + "," + cTypeDown + "," + cUsuario )	
Else

	// Pesquisa se o modelo do equipamento existe na AUTOCOM                          
	// Caso houver equipamento homologado nas duas DLLs, a prioridade sera a AUTOCOM. 
	If Self:IsAutocom( EQUIP_IMPFISCAL ) == EQUIP_DLL_AUTOCOM
		nRet :=Self:oAutocom:IFGerRegTipoE( Iif( cTypeDown="C", "2", "1"), cDadoIni, cDadoFim, "", "", cPath + cFile )
	EndIf
EndIf

Return nRet


//--------------------------------------------------------
/*/{Protheus.doc}GetNf
Verifica se impressora está ativa                    
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Boolean
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method GetNf() Class STFECFCONTROL
lImpTk := .F.
Return lImpTk


//--------------------------------------------------------
/*/{Protheus.doc}TEFHomol
Funções internas de homologação do TEF                   
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPn1 - Boolean
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method TEFHomol(	nComando, cBuffer, nTipo, nVias, ;
					nRet	, nImpHnd					) Class STFECFCONTROL     

Local lRet			:= .F.							// Retorno da função
Local oTEF			:= STBGetTEF() 				// Captura o Objeto TEF
Local cSalvBuff		:= ""							// Salva o conteudo para nao perder depois que enviar para impressora
Local cTrataText	:= ""							// Variável para tratamento do texto para impressora, mandar de 3 em 3 linhas
Local cEnviaText	:= ""							// Variável para enviar o texto para impressora de 3 em 3 linhas
Local nRemp			:= 0                            // Contador do cFim
Local cFim 			:= "ANOTE TELEFONE E ENDERECO NO VERSO"								// "ANOTE TELEFONE E ENDERECO NO VERSO"


Default nComando	:= 0
Default cBuffer		:= ""
Default nTipo		:= 0
Default nVias		:= 1
Default nRet		:= -1
Default nImpHnd 	:= 0

STFMessage("TEFHomol","YESNO","Deseja imprimir novamente?") 

STFMessage("TEFHomol2","STOP","Transação TEF não foi efetuada. Favor reter o Cupom!")

If ValType(oTEF) == "O" .AND. oTEF:IsAtivo() .AND. Valtype(oTEF:oConfig:oCfgTef) == "O" .AND.  oTEF:oConfig:oCfgTef:SiTefHb(oTEF:oConfig:oCfgTef) .AND. Self:lHomTEF
	lRet := .T.
	If nTipo == 1	// fechamento do cupom - Loop quando não existe comunicação do sistema com a impressora no momento
		cSalvBuff := cBuffer
		While nRet <> 0
	   		
			If STFShowMessage("TEFHomol") 
				STFCleanInterfaceMessage()
				Sleep(4000) 
				nRet := Self:ExecDLLRet(Self:nHnd, nComando, cBuffer )
				If nRet <> 0
					cBuffer := cSalvBuff
				Endif
			Else
				STFCleanInterfaceMessage()
				oTEF:FinalTrn(0)
				Sleep(4000)
 				STFShowMessage("TEFHomol2") 
				STFCleanInterfaceMessage()				
				exit
			EndIf
		End
	ElseIf nTipo == 2	// condicao de pagamento - Loop quando não existe comunicação do sistema com a impressora no momento
		While nRet <> 0

			If STFShowMessage("TEFHomol") 		//"Deseja imprimir novamente?"#"Atenção"
				STFCleanInterfaceMessage()
				cSalvBuff := cBuffer 			
				Sleep(5000) 				
				nRet := ExeDLLRun2(Self:nHnd, nComando, cBuffer)				
				If nRet <> 0					
					cBuffer := cSalvBuff
				Endif
			Else
				STFCleanInterfaceMessage()
				oTEF:FinalTrn(0)                                  								
				Sleep(4000)
 				STFShowMessage("TEFHomol2") 
				STFCleanInterfaceMessage()				
				Self:CancelReceipt()
				nRet := 1
				exit
			EndIf
		End
	ElseIf nTipo == 3	// comprovante vinculado - Loop de tratamento para enviar no maximo 3 linhas por vez para impressora		
		nRet := 0
		cTrataText := cBuffer
		While nRet == 0
			cEnviaText := ""
			cEnviaText := SUBSTR(cTrataText,1,30)
			cTrataText := SUBSTR(cTrataText,31)
			If Empty(cTrataText)
				nRet := ExeDLLRun2(Self:nHnd, nComando, Str(nImpHnd)+'|'+cEnviaText+'|'+Str(nVias)+'|')
				Exit
			EndIf
			nRet := ExeDLLRun2(Self:nHnd, nComando, Str(nImpHnd)+'|'+cEnviaText+'|'+Str(nVias)+'|')
			nRet := Self:PrinterStatus( "20", @cRet)			// Verifico o Status do ECF
		End
	ElseIf  nTipo == 4	// relatorio gerencial - Loop de tratamento para enviar no maximo 3 linhas por vez para impressora
		nRet := ExeDLLRun2(Self:nHnd, nComando, Str(nImpHnd)+'|'+'FechaRelatorioGerencial|'+Str(nVias)+'|') 
		nRet := 0                       
		cTrataText := cBuffer
		While nRet == 0
			cEnviaText := ""
			cEnviaText := SUBSTR(cTrataText,1,60)
			cTrataText := SUBSTR(cTrataText,61)			
		
			If cFim $ cEnviaText  
				nRemp +=	1	
				cEnviaText := SubStr(cEnviaText, 1, RAT("O", cEnviaText))
			EndIf
			If nRemp == 1
				cTrataText := ""
			EndIf       
			
			If Empty(cTrataText)
				nRet := ExeDLLRun2(Self:nHnd, nComando, Str(nImpHnd)+'|'+cEnviaText+'|'+Str(nVias)+'|')
				nRet := ExeDLLRun2(Self:nHnd, nComando, Str(nImpHnd)+'|'+'FechaRelatorioGerencial|'+Str(nVias)+'|')
				Exit
			EndIf
			nRet := ExeDLLRun2(Self:nHnd, nComando, Str(nImpHnd)+'|'+cEnviaText+'|'+Str(nVias)+'|')						
			nRet := Self:PrinterStatus("20", @cRet)			// Verifico o Status do ECF
		End
	ElseIf nTipo == 5	// Envia Sleep para garantir que a impressora ja esta on-line
		Sleep(3000)
	EndIf
EndIf

Return lRet   
      

//--------------------------------------------------------
/*/{Protheus.doc}StatDisplay
Inicia o handle do display                
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPN1 - Number
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method StatDisplay( nValor ) Class STFECFCONTROL

Default nValor 	:= 0

If nValor <> Nil
	Self:nDispHandle := nValor
EndIf

Return Self:nDispHandle    

//--------------------------------------------------------
/*/{Protheus.doc}DispTorStat
Inicia o handle do display Torre                
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPN1 - Number
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DispTorStat(nValor) Class STFECFCONTROL

Default nValor 	:= 0

If nValor <> Nil
	Self:nDistorHl := nValor 
EndIf

Return Self:nDistorHl    


//--------------------------------------------------------
/*/{Protheus.doc}GetHandle
Retorna o handle do ECF              
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPN1 - Number
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method GetHandle() Class STFECFCONTROL

Return Self:nHnd
      

//--------------------------------------------------------
/*/{Protheus.doc}SetHandle
Seta o handle do ECF              
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPN1 - Number
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method SetHandle(nHandle) Class STFECFCONTROL

Default nHandle 	:= 0

Self:nHnd := nHandle

Return    


//--------------------------------------------------------
/*/{Protheus.doc}OpenIpPort
Abre a porta IP              
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPN1 - Number
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method OpenIPPort(nHnd, cFrameIP, cFramePort) Class STFECFCONTROL 
  
Local nRet := 0  

Default nHandle 	:= 0
Default cFrameIP 	:= ""
Default cFramePort 	:= ""

nRet := ExeDLLRun2( nHnd, 998, AllTrim( cFrameIP ) + "," + AllTrim( cFramePort ) )  

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc}CMC7Use
Abre a porta IP              
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPL1 - Logic
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CMC7Use() Class STFECFCONTROL 
Return Self:lCMC7
       

//--------------------------------------------------------
/*/{Protheus.doc}CheckUse
Abre a porta IP              
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPL1 - Logic
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method CheckUse() Class STFECFCONTROL
Return Self:lCheck
          

//--------------------------------------------------------
/*/{Protheus.doc}BalanceUse
Abre a porta IP              
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPL1 - Logic
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method BalanceUse() Class STFECFCONTROL
Return Self:lBalance

//--------------------------------------------------------
/*/{Protheus.doc}RetTypePrt
Retorna o tipo da Impressora Fiscal             
@author  	Varejo
@version 	P11.8
@since   19/03/13
@return  	EXPL1 - Logic
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RetTypePrt()   Class STFECFCONTROL 
Return Self:cTypeImp    


//--------------------------------------------------------
/*/{Protheus.doc} GetNFiscTotal
Faz a captura dos totalizadores não fiscais
@param		EXPc1 - Retorna dos totalizadores não fiscais
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------	
Method GetNFiscTotal(cBuffer) Class STFECFCONTROL 

	Local nRet := 0   
	Local oRetorno := NIL
	Local oTotaliz := NIL
	Local nCount := 0
	
	DEFAULT cBuffer := ""
	
cBuffer := Str( Self:nImpHnd ) + "," + cBuffer					// Envia um buffer e já prepara o recebimento

	If Self:cTypeImp == "TOTVSAPI"
	

		oRetorno := Self:oImpFisc:Totaliz()
		
		oTotaliz := oRetorno:oRetorno
		
		For nCount := 1 To oTotaliz:Count()
				cBuffer += oTotaliz:Elements(nCount):cIndice  + "," + oTotaliz:Elements(nCount):cTotaliz + "|"

		Next 
		
		
	ElseIf Self:cTypeImp == "EQUIP_DLL_SIGALOJA" //"TOTVSAPI"
		nRet := Self:ExecDLLRet(Self:nHnd, 124, @cBuffer )

    Else		
		cBuffer :=  "-99"
	EndIf 


Return nRet


//--------------------------------------------------------
/*/{Protheus.doc} SystemDirectory
Faz a captura do diretório system
@param		EXPc1 - Retorna o diretório system
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------	
Method SystemDirectory(cBuffer) Class STFECFCONTROL 

	Local nRet := 0   
	
	DEFAULT cBuffer := ""
	
	cBuffer := Str( Self:nImpHnd ) + "," + cBuffer					// Envia um buffer e já prepara o recebimento

	nRet := Self:ExecDLLRet(Self:nHnd, 996, @cBuffer )



Return nRet 



//--------------------------------------------------------
/*/{Protheus.doc}MenuFiscReport
Faz a Impressao do Relatorio Gerencial     
@param   	EXPn1 - Handle de uso da DLL                              
@param   	EXPc1 - Texto a ser impresso no relatorio                
@param   	EXPc2 - Numero de vias do texto 
@param   	EXPc3 - Indice do totalizador
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method MenuFiscReport( cTexto ,nVias, cTotalizer) Class STFECFCONTROL 

Local nRet			:= -1						// Retorno da Method da dll
Local oRelatorio	:= Nil						//Relatorio que sera impresso
Local oRet := NIL
Local oTEF			:= STBGetTEF() //Captura o Objeto TEF
Local lTravaTecl   := ValType(oTEF) == "O" .AND. oTEF:IsAtivo() .AND. Valtype(oTEF:oConfig:oCfgTef) == "O" .AND.  !oTEF:oConfig:oCfgTef:SiTefHb(oTEF:oConfig:oCfgTef)

Default cTexto		:= ""						// Texto
Default nVias		:= 1						// Numero de Vias

cTexto := StrTran( cTexto, Chr(13), '') //Remove CHR(13)

If Self:lHomTEF
	Sleep(6000)
EndIf

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
		oRelatorio :=  self:PrepReport(cTexto, nVias)  
		oRet := Self:oImpFisc:ImpRelGer(oRelatorio, cTotalizer, .F.)
		If oRet:lRetorno
			nRet := 0
		EndIf
		FreeObj(oRelatorio)
		FreeObj(oRet)
		
	Case Self:cTypeImp == "DLL_SIGALOJA"					
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado

		nRet := ExeDLLRun2(Self:nHnd, 49, Str(Self:nImpHnd)+'|'+cTotalizer+'|'+cTexto+'|'+Str(nVias)+'|')

		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM"
		nRet := Self:oAutocom:IFRelGer(cTexto,nVias)
	
	Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		If !Self:TEFHomol( 34, cTexto, 4, nVias, @nRet)

			nRet := ExeDLLRun2(Self:nHnd, 49, Str(Self:nImpHnd)+'|'+cTotalizer+'|'+cTexto+'|'+Str(nVias)+'|')
		EndIf
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado

EndCase

Return nRet   


//--------------------------------------------------------
/*/{Protheus.doc}DownMF
Realiza o Download da memória fiscal     
@since   	28/08/2013
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method DownMF( cTipo,cDadoIni,cDadoFinal ) Class STFECFCONTROL
Local nRet 		:= -1		// Retorno da Method da dll
Local cPath 	:= ""     // Caminho onde a TotvsAPI ira gravar o arquivo de Memoria Fiscal quando PAF-ECF
Local cAux  	:= ""		// Variavel auxiliar que contera o path para a gravacao do arquivo
Local oRet 		:= NIL		// retorno

Do Case
	Case Self:cTypeImp == "TOTVSAPI"
		//Tipo da Memoria Fiscal
	   	oRet := Self:oImpFisc:DownMF()

		If oRet:lRetorno              
			//Arquivo
			oRet := Self:oImpFisc:PegPathMFBin()
			If oRet:lRetorno			
				cAux := AllTrim(oRet:oRetorno)
				If Right(cAux,1)  == "\"
					cAux += "mfiscal.bin"					
				ElseIf cAux == "C:\" .OR. Empty(cAux)
					cAux := "C:\mfiscal.bin"
				ElseIf !(Upper("mfiscal.bin") $ Upper(cAux))
					cAux += "\mfiscal.bin"					
				EndIf
				
				If STBIsPaf() 
					If StBGerPath( @cPath ) 
						If __CopyFile(cAux, cPath + "mfiscal.bin")
							nRet := 0
						EndIf	
					EndIf	
				Else						
					nRet := 0 
				EndIf
			EndIf
		EndIf
        FreeObj(oRet)  
        
	Case Self:cTypeImp == "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 125, AllTrim( Str( Self:nImpHnd ) ) + "," + cTipo + "," + cDadoIni + "," + cDadoFinal )
	
	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM
	   //	nRet := Self:oAutocom:IFMemFisc(cDataIni, cDataFim, cReducIni, cReducFim, cCheck)  
	   //msgstop("função ao nao suportada por este modelo de ecf")
		nRet := Self:oAutocom:IFDownMF()
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 125, AllTrim( Str( Self:nImpHnd ) ) + "," + cTipo + "," + cDadoIni + "," + cDadoFinal )

EndCase

Return nRet 

//--------------------------------------------------------
/*/{Protheus.doc} RedZDado
Captura os dados da Reducao Z
@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
/*/
//--------------------------------------------------------
Method RedZData( cBuffer ) Class STFECFCONTROL
Local nRet 		:= -1  			// Retorno da Method da dll
Local oRet		:= NIL				// Objeto retorno

Default cBuffer := ""

cBuffer := Str( Self:nImpHnd )+ "," + cBuffer			// Envia um buffer e já prepara o recebimento

Do Case 
	
	Case Self:cTypeImp == "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:RedZDado()
			If oRet:lRetorno .and. ValType(oRet:oRetorno) == "O"
				cBuffer := Self:TratRedZ(oRet:oRetorno)
				nRet = 0
			ElseIf oRet:lRetorno
				nRet := 0  
			EndIf
			FreeObj(oRet)
	   	EndIf
	
	Case Self:cTypeImp == "DLL_SIGALOJA"	
		cBuffer := Str( Self:nImpHnd )+ "," + cBuffer	// Envia um buffer e já prepara o recebimento
		nRet := Self:ExecDLLRet(Self:nHnd, 129, @cBuffer )

	Case Self:cTypeImp == "EQUIP_DLL_AUTOCOM" 		
 		//STFMessage("RedZData","STOP","Função não suportada por este modelo de ECF")	
		//STFShowMessage("RedZData")	
		nRet := Self:oAutocom:IFRedZDado( cBuffer )
		cBuffer := Self:oAutocom:cBuffer
    Case Self:cTypeImp == "EQUIP_DLL_SIGALOJA"
		nRet := Self:ExecDLLRet(Self:nHnd, 129, @cBuffer )

EndCase

Return nRet 

//--------------------------------------------------------
/*{Protheus.doc} PrintBarCode
Realiza a impressão de um código de barras dentro de um relatorio gerencial. Feito para impressoras fiscais.

@param		cCabecalho - Cabecalho do relatorio contendo o codigo de barras
@param		cCodBarras - Código de barras
@param		cRodape    - Rodapé do relatorio contendo o codigo de barras
@param		nVias      - Numero de vias

@author  	Varejo
@version 	P11.8
@since   	03/05/2012
@return  	nRet - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample     Nil
*/
//--------------------------------------------------------	
Method PrintBarCode( cCabecalho, cCodBarras, cRodape, nVias ) Class STFECFCONTROL 
Local nRet			:= -1						// Retorno da funcao da dll
Local oTEF		    := STBGetTEF() 							//Captura o Objeto TEF
Local lTravaTecl    := ValType(oTEF) == "O" .AND. oTEF:IsAtivo() .AND. Valtype(oTEF:oConfig:oCfgTef) == "O" .AND.  !oTEF:oConfig:oCfgTef:SiTefHb(oTEF:oConfig:oCfgTef)//travar teclado
Local oCabecalho	:= Nil						//Cabecalho que sera impresso
Local oRodape		:= Nil						//Rodape que sera impresso

DEFAULT cCabecalho	:= ""						// Cabecalho do relatorio gerencial contendo o codigo de barras
DEFAULT cRodape		:= ""						// Rodape do relatorio gerencial contendo o codigo de barras
DEFAULT nVias		:= 1						// Numero de Vias

cCodBarras := StrTran( cCodBarras, Chr(13), '') //Remove CHR(13)

If Self:lHomTEF
	Sleep(6000)
EndIf

Do Case
	
	Case Self:cTypeImp == "TOTVSAPI"
	
		oCabecalho := self:PrepReport(cCabecalho, 1)
		oRodape    := self:PrepReport(cRodape, 1)
		
		oRet := Self:oImpFisc:ImpCodBar(oCabecalho,cCodBarras, oRodape, Nil, .F.)
		
		If oRet:lRetorno
			nRet := 0
		EndIf
			
		FreeObj(oCabecalho)
		FreeObj(oRodape)
		FreeObj(oRet)
	
	Case Self:cTypeImp == "DLL_SIGALOJA" .OR. Self:cTypeImp == "EQUIP_DLL_SIGALOJA"	// Verifica o parametro MV_AUTOCOM

		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 119, Str(Self:nImpHnd)), Nil)	   //Trava Teclado
		nRet := ExeDLLRun2(Self:nHnd, 126, Str(Self:nImpHnd)+'|'+cCabecalho+'|'+cCodBarras+'|'+cRodape+'|'+Str(nVias)+'|')
		Iif(lTravaTecl, ExeDLLRun2(Self:nHnd, 120, Str(Self:nImpHnd)), Nil)	   //Destrava Teclado

EndCase 

Return nRet     
          
//--------------------------------------------------------
/*/{Protheus.doc}CancelBound
Faz o cancelamento do cupom vinculado ao fiscal (CCD/CDC)
@param   	cCpfCnpj - Nome do Cliente
@param   	cEndereco - Endereco do Cliente
@param   	cMensagem - Mensagem
@param   	cCOOCCD - Numero COO DO CCD/CDC (comprovante de debito e credito)
@author  	Varejo
@version 	P11.8
@since   	23/10/2014
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK 
@obs     	Nil
@sample    Nil
/*/
//--------------------------------------------------------
Method CancelBound( cCpfCnpj, cCliente, cEndereco, cMensagem, cCOOCCD ) Class STFECFCONTROL

Local oRet := NIL	// Objeto retorno
Local nRet := -1	// Retorno da funcao

Default cCpfCnpj	:= ""	// Armazena CNPJ/CPF
Default cCliente	:= ""	// Armazena Nome Cliente
Default cEndereco	:= ""	// Armazena Endereco Cliente
Default cMensagem	:= ""	// Armazena Mensagem
Default cCOOCCD	:= ""	// Armazena Numero COO DO CCD/CDC (comprovante de debito e credito)

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:EstNFiscVinc(cCpfCnpj , cCliente , cEndereco , cMensagem , cCOOCCD)
			If oRet:lRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 128, Str( Self:nImpHnd ) + "," + cCpfCnpj + "," + cCliente + "," + cEndereco + "," + cMensagem + "," + cCOOCCD )
	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		nRet := ExeDLLRun2(Self:nHnd, 128, Str( Self:nImpHnd ) + "," + cCpfCnpj + "," + cCliente + "," + cEndereco + "," + cMensagem + "," + cCOOCCD )

EndCase
Return nRet           
		  
//--------------------------------------------------------
/*/{Protheus.doc} NFCe_Enviar
Método Responsável pelo Envio da NFCe
@param   	ExpO1 (Objeto XML) - Objeto XML gerado pela rotina LOJNFCE
@param   	cDoc - Documento da NFCe (retorno)
@param   	cSerie  - Série da NFCe (retorno)
@param   	cChave  - Chave  da NFCe (retorno)
@param   	cProt  - Protocolo da NFCe (retorno)
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@sample
/*/
//-------------------------------------------------------- 
Method NFCe_Enviar(oXML, cDoc, cSerie, cChave, cProt)    Class STFECFCONTROL
Local nRet := -1 //Retorno
Local oRet := NIL //Objeto Retorno

Default oXML := NIL
Default cDoc := ""
Default cSerie := ""
Default cChave := ""
Default cProt := ""


Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_Enviar(oXML , @cDoc, @cSerie, @cChave, @cProt)
			
			If oRet:lRetorno
				nRet := Val(AllTrim(oRet:oRetorno))
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet

 
//--------------------------------------------------------
/*/{Protheus.doc} NFCe_Cancelar
Método Responsável pelo Cancelamento da NFCe
@param   	ExpO1 (Objeto XML) - Objeto XML gerado pela rotina LOJNFCE
@param   	cDoc - Documento da NFCe (retorno)
@param   	cSerie  - Série da NFCe (retorno)
@param   	cChave  - Chave  da NFCe (retorno)
@param   	cProt  - Protocolo da NFCe (retorno)
@param   	cJust  - Justificativa de cancelamento
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@sample
/*/
//-------------------------------------------------------- 
Method NFCe_Cancelar(cDoc, cSerie, cChave, cProt, cJust,lOnLine, lInutiliza ) Class STFECFCONTROL
Local nRet := -1 //Retorno Api
Local oRet := NIL //Objeto Retorno

Default cDoc := ""
Default cSerie := ""
Default cChave := ""
Default cProt := ""
Default cJust := ""
Default lOnLine :=  .F.
Default lInutiliza := .F.

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_Cancelar(@cDoc, @cSerie, cChave, cProt, cJust, lOnLine, lInutiliza )
			
			If oRet:lRetorno
				nRet := Val(AllTrim(oRet:oRetorno))
				If nRet <> 0
					nRet := 0
				EndIf
			Else
				If Val(AllTrim(oRet:oRetorno)) <> 0
					nRet := oRet:oRetorno
				Else
					nRet := -1
				EndIf
			EndIf
			FreeObj(oRet)
		EndIf
		  
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet 

//--------------------------------------------------------
/*/{Protheus.doc} NFCe_OfWs
Método Responsável pelo Envio da Contingência OffLine
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@sample
/*/
//--------------------------------------------------------
Method NFCe_OfWs(nTotNFCeOff, nTotCancOff) Class STFECFCONTROL
Local nRet := -1 //Retorno
Local oRet := NIL //Objeto retono

Default nTotNFCeOff := 0
Default nTotCancOff := 0

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_OfWs(nTotNFCeOff, nTotCancOff)
			
			If oRet:lRetorno
				nRet := Val(AllTrim(oRet:oRetorno))
			EndIf
			FreeObj(oRet)
		EndIf
		  
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} NFCe_StCfg
Método Responsável pela configuração das chaves NFCe
@param   	cChave  - Codigo da Chave a ser configurada
@param   	cValor - Valor a ser configurado na Chave
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@sample
/*/
//--------------------------------------------------------
Method NFCe_StCfg(cChave, cValor) Class STFECFCONTROL
Local nRet 	:= -1	//Retorno da API
Local oRet 	:= NIL //Objeto Retorno

Default cChave := ""
Default cValor := ""

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_StCfg(cChave, cValor)
			
			If oRet:lRetorno
				nRet := Val(AllTrim(oRet:oRetorno))
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet 


//--------------------------------------------------------
/*/{Protheus.doc} NFCe_Cfg
Método Responsável pelo retorno da configuração da NFCe
@param   	cChave - Indice da Chave
@param   	cValor - Valor da Chave
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@return  	oRetorno
@sample
/*/
//--------------------------------------------------------
Method NFCe_Cfg(cChave, cValor) Class STFECFCONTROL
Local oRet := NIL //Objeto Retorno
Local nRet := -1 //Retorno API

Default cChave := ""
Default cValor := ""

Do Case
	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_Cfg(cChave)
			
			If oRet:lRetorno
				cValor := AllTrim(oRet:oRetorno)
				nRet := 0
			EndIf
			
			FreeObj(oRet)
		EndIf
		  
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase
Return nRet

//--------------------------------------------------------
/*/{Protheus.doc} NFCe_Imprimir
Método Responsável pela impressão do Danfe NFCE
@param cXMLEnv - XML envio
@param cXMLRec - XML REtorno
@param cUrlQR - URL QR Code 
@param nColunas - Numero de Colunas
@param nTpNFCE - Tipo NFCE
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@sample
@return  	nRet  - Retorno
/*/
//--------------------------------------------------------
Method NFCe_Imprimir(cXMLEnv, cXMLRec, cUrlQR, nColunas, nTpNFCE) Class STFECFCONTROL
Local nRet := -1 //Retorno
Local oRet := NIL //Objeto Retorno


Default cXMLEnv := ""
Default cXMLRec := ""
Default cUrlQR := ""
Default nColunas := 0
Default nTpNFCE := 0

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_Imprimir(cXMLEnv, cXMLRec, cUrlQR, nColunas, nTpNFCE)
			
			If oRet:lRetorno
				nRet := Val(AllTrim(oRet:oRetorno))
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc} NFCe_ConsInfo
Método Responsável pela consulta de informações da NFCe
@param cInfo - Informação
@param cTipoCons - Tipo da Consulta
@param cInterIni - Intervalo Inicial
@param cInterFim - Intervalo Final
@param cSerie - Serie do Documento
@param cChave - Chave NFCe
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@sample
@return  	nRet - Valor do Retorno
/*/
//--------------------------------------------------------
Method NFCe_ConsInfo(cInfo, cTipoCons, cInterIni, cInterFim,  cSerie, cChave, cBuffer) Class STFECFCONTROL

Local oRet 	:= NIL //Objeto Retorno
Local cRetorno := "" //Valor do Retorno
Local nRet := -1 //Retorno da função

Default cInfo:= ""
Default cTipoCons := "NUM"
Default cInterIni := "0"
Default cInterFim := cInterIni
Default cSerie := ""
Default cBuffer := space(500)
Default cChave := ""

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_ConsInfo(cInfo, cTipoCons, cInterIni, cInterFim,  cSerie, cChave)
			
			If oRet:lRetorno
				cBuffer := oRet:oRetorno
				nRet := 0
			EndIf
			FreeObj(oRet)
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet 

//--------------------------------------------------------
/*/{Protheus.doc} NFCe_Info
Método Responsável pelo retorno de informações estendida e internas da APi
@param   	cInfo - Codigo da Informação
@param   	cDefault - Valor Default
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@sample
@return  	oRetorno - Valor do Retorno
/*/
//-------------------------------------------------------- 
Method NFCe_Info(cInfo, cDefault) Class STFECFCONTROL

Local cRetorno := "" //rEtorno
Local nRet := -1 //REtorno da rotina

Default cInfo := ""
Default cDefault := ""


Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			cRetorno := Self:oImpFisc:NFCe_Info(cInfo, @cDefault)
			LjGrvLog("NFCe_Info", "Info " + cInfo +", value" +cDefault)
			nRet := 0
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet


//--------------------------------------------------------
/*/{Protheus.doc} NFCe_Inutiliz
Método Responsável pelo inutilização da nfce
@param cInterIni - Intervalo Inicial
@param cInterFim - Intervalo Final
@param cSerie - Serie do Documento
@param cJust - Justificativa
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
@sample
@return  	oRetorno - Valor do Retorno
/*/
//-------------------------------------------------------
Method NFCe_Inutiliz(cInterIni, cInterFim,  cSerie, cJust) Class STFECFCONTROL
Local cRetorno := "" //REtorno da api
Local nRet := -1 //REtorno da função
Local oRet := NIL //Retorno da api

Default cInterIni := ""
Default cInterFim := ""
Default cSerie := ""
Default cJust := ""

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_Inutiliz(cInterIni, cInterFim,  cSerie, cJust)
			
			If oRet:lRetorno
				nRet := 0
			EndIf
		EndIf
		
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet

//--------------------------------------------------------
/*/{Protheus.doc} NFCe_ReImprimir
Método Responsável pela Reimpressão NFCe
@param   	cDoc - Documento da NFCe (retorno)
@param   	cSerie  - Série da NFCe (retorno)
@param   	cChave  - Chave  da NFCe (retorno)
@author  	Varejo
@version 	P11.8
@since   	11/11/2015
@sample
/*/
//-------------------------------------------------------- 
Method NFCe_ReImprimir(cDoc, cSerie, cChave) Class STFECFCONTROL
Local nRet := -1 //Retorno Api
Local oRet := NIL //Objeto Retorno

Default cDoc := ""
Default cSerie := ""
Default cChave := ""

Do Case

	Case Self:cTypeImp = "TOTVSAPI"
		If Self:oImpFisc <> Nil
			oRet := Self:oImpFisc:NFCe_ReImprimir(cDoc, cSerie, cChave)
			
			If oRet:lRetorno
				nRet := Val(AllTrim(oRet:oRetorno))
				If nRet <> 0
					nRet := 0
				EndIf
			Else
				nRet := -1
			EndIf
			FreeObj(oRet)
		EndIf
		  
	Case Self:cTypeImp = "DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_AUTOCOM"
		//Comando não existe nesta dll
		nRet := -1	
	Case Self:cTypeImp = "EQUIP_DLL_SIGALOJA"
		//Comando não existe nesta dll
		nRet := -1	
EndCase

Return nRet 
