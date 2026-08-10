/* IMPORTANTE: MANUTENÇÕES REALIZADAS NESTE FONTE APÓS 01/02/2015, O FONTE 
STFSTRATEGYECF DEVERÁ SER ENVIADO COMO DEPENDÊNCIA */
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STWECFCONTROL.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "DIRECTRY.CH"

Static aCNPJDV		:= {}
Static oImpBWECF	:= STFECFCONTROL():STFECFCONTROL(ExistFunc("STHOMTEF") .AND. STWIsTotvs(SM0->M0_CGC),STWIsTax(), ChkAutocom() )
Static lEmitNfce	:= LjEmitNFCe() // Sinaliza se utiliza NFC-e
Static cCNPJInf		:= ""
Static cNomeInf		:= ""
Static cEndInf		:= ""
Static lDadosInf 	:= .F.	 	// Variavel para controle de digitação de CPF/CNPJ
Static oImpFisc		:= Nil			// Objeto do tipo LJCImpressora

Static lEcfOperante := Nil		// Indica se a ECF esta apta a movimentação (operando)
Static dDataOperante:= Nil		// Data da ultima verificação de operação da ECF
Static cMsgOperation:= ""		// Mensagem a ser exibida para o usuario
Static lVerFonte	:= Nil		// Verifica data de fonte apra correto funcionamento da rotina
Static nMaxTimeOut  := Nil		// TimeOut de leitura na balança -> "LG_TIMEBAL"
Static lLjxCtImpRD	:= ExistFunc("LjxCtImpRD")
Static lIsRmt64		:= If(ExistFunc("IsRmt64"), IsRmt64(), .F.)
Static cDLLSIGALOJA	:= STWRetDll()


//-------------------------------------------------------------------
/*{Protheus.doc} STWCheckIFDate
Function CheckIFDate
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWCheckIFDate()
Local nRet := -1

nRet := oImpBWECF:CheckIFDate()

Return nRet

//-------------------------------------------------------------------
/*{Protheus.doc} STWPrntBarCode
Function STWPrntBarCode
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWPrntBarCode(cCabecalho, cCodBarras, cRodape ,nVias)
Local nRet := -1
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

If STWCheckpaper(.T.)
	STWLjPrintlCOO(@nRet)
	If lAutomato
		mRet := 0
	Else	
		nRet := oImpBWECF:PrintBarCode(cCabecalho, cCodBarras, cRodape ,nVias)
	Endif
EndIf

//PAF-ECF: Armazena na tabela de apoio(MDZ), emissão de relatório gerencial
STDGrvMdz("RG")

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWSendSupply
Function envia suplemento
@param1   	nTroco - Troco
@param2   	nMoney - Dinheiro
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWSendSupply( nTroco , nMoney )

Local lOpenCup		:= .F.			// Variavel de controle
Local nRet			:= 0			// Retorno da funcao da dll
Local lRet		 	:= .T.			// Variavel de controle
Local nSuprimento	:= 0			// Armazena o indice do suprimento
Local cSuprimento	:= Space(20)	// Recebe o indice do suprimento do ECF
Local cRet			:= Space(10)	// Recebe da dll se o cupom esta aberto
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default nTroco 	:= 0
Default nMoney 	:= 0


If lAutomato
	nRet := 0
Else
	nRet := oImpBWECF:SendSupply( nTroco, nMoney )
Endif

If nRet == 9	// Suprimento insuficiente
	nRet := STWPrinterStatus('6', @cSuprimento )		// Pede o suprimento da impressora
	nSuprimento := Val( Alltrim( cSuprimento ) )
	// checar se o cupom esta aberto ...
	nRet := STWPrinterStatus('5', @cRet )				// Verifica se o cupom esta aberto
	If nRet == 7
		lOpenCup := .T.
	Else
		lOpenCup := .F.
	Endif

	/*
		Troco necessario para pagar o cliente
		troco disponivel na impressora fiscal
		vc. nao possui dinheiro em caixa sificiente para pegar este troco
		deseja registrar suprimento (entrada de dinheiro no caixa) automaticamente ?
		Ap¢s registrar este suprimento efetue novamente esta venda.
		Se voc? optar por n?o registrar o suprimento, somente ser  poss¡vel efetuar vendas em
		dinheiro ou com o troco dispon¡vel at? entrar algum valor de dinheiro via venda ou suprimento.
		"Falta de Troco"
	*/
	STFMessage("SENDSUPPLY","YESNO","Falta de Troco - Troco necessário para pagar ao cliente: " + Ltrim( Str( nTroco, 14, 2 ) ) + ". " + ;
									"Troco disponível na impressora fiscal: " + Ltrim( Str( nSuprimento, 14, 2 ) ) + ". " +;
									"VOcê näo possui dinheiro em caixa suficiente para pagar este troco." + ;
									"Deseja registar os suprimento (entrada de dinheiro na caixa)de forma automática ? " + If( lOpenCup, "Após registar este suprimento efectue novamente esta venda. ", "" ) + ;
									"Se você optar por näo registrar o suprimento, somente será possível efetuar vendas em " + ;
									"Dinheiro ou troco disponível até entrar algum valor de dinheiro via venda ou suprimento."  )
	If STFShowMessage( "SENDSUPPLY" )
		nRet := oImpBWECF:Supply( 2, Str( nTroco-nSuprimento, 14, 2 ) )
		lRet := .T.
	Else
		lRet := .F.
	EndIf
Else
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCheckPaper
Function Chaca papel
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCheckPaper(lMessage)

Local nRet := 0   		// Retorno
Local lRet := .T.      // Retorno
Local lMv_ljchkpp 	:= SuperGetMV( "MV_LJCHKPP" )	// Indica se faz checagem de papel
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
Default lMessage := .T.

If !STWIsTaxPrinter() .OR. !lMv_ljchkpp
	Return ( .T. )
EndIf

If lAutomato
	nRet := 0
Else
	nRet := oImpBWECF:Checkpaper()
Endif
	

If lMessage
	If nRet == 2
		STFMessage("CHECKPAPER","YESNO","Pouco Papel na Impressora, Deseja Continuar ?") //STR
		If STFShowMessage("CHECKPAPER")
			lRet := .F.
		EndIf
	ElseIf nRet <> 0
		STFMessage("CHECKPAPER","STOP","Impressora Sem Papel, Troque o Papel para Continuar.") // STR
		STFShowMessage("CHECKPAPER")
		lRet := .F.
	Endif
Else
	If nRet <> 0
		lRet := .F.
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReadCmc7
Function
@param   	nParcel - Parcela
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReadCmc7( nParcel )

Local aDados		:= {} 							// Array contendo dados do cheque
Local cBufCMC7 		:= ""							// String que recebera dados do cheque
Local aArea			:= GetArea()					// Array contendo informações da area
Local lLjLeCMC7		:= ExistBlock( "LJLECMC7" )		// Variavel logica que checa existencia do ponto de entrada LJLECMC7
Local lLjCMC7		:= ExistBlock( "LJCMC7" )  		// Variavel logica que checa existencia do ponto de entrada LJCMC7
Local nRet         	:= 0         					// Variavel retorno
Local xRet			:= Nil							// Retorno

Default nParcel := 0

If STWCMC7Use()
	If lLjCMC7
		aDados := ExecBlock( "LJCMC7",.F.,.F. )
	Else
		cBufCmc7 := Space( 200 )

		STFMessage( "STWReadCmc7", "RUN", OemToAnsi( " Aguarde a leitura do " + Numeral( nParcel ) + " cheque..." ),;	// " Aguarde a leitura do ""cheque..."
		{|| If( nParcel > 1, Sleep( 3000 ), ), nRet := STWCMC7DRead( nHdlCMC7, @cBufCMC7 ) } )
		STFShowMessage( "STWReadCmc7")

		If ( nRet == 1 ) .OR. Empty( cBufCMC7 )
			RestArea( aArea )
			Return( aDados )
		EndIf

		// Ponto de Entrada para tratamento dos dados capturados
		// pelo leitor de CMC7. Solicitado por Casa das Alian‡as

		If lLjLeCmc7
			xRet  := ExecBlock( "LJLECMC7", .F., .F., { cBufCMC7 } )
			If ValType(xRet) == "C"
			   cBufCMC7  := xRet
			EndIf
		EndIf
		AAdd( aDados, Subs( cBufCMC7, 2, 3 ) )	   		// cBanco
		AAdd( aDados, Subs( cBufCMC7, 15, 6 ) + " " )	// cNumCheque
		AAdd( aDados, Subs( cBufCMC7, 5, 4 ) )	   		// cAgencia
		AAdd( aDados, Subs( cBufCMC7, 25, 8 ) )	   		// cConta
		Aadd( aDados, Subs( cBufCMC7, 11, 3 ) )	  		// cCompensacao

	Endif
	If Len( aDados ) < 5
		Aadd( aDados, Space( 3 ) )		// cCompensacao
	EndIf
ElseIf STWComCMC7D()
	//Chama a rotina que efetua a leitura o CMC7 a partir de um CMC7 direto (comunicacao USB)
	aDados := STWCMC7Direct()
EndIf

If AllTrim( Procname( 1 ) ) == "FA080TIT"
	cBanco	:= Space( 3 )
	cAgencia:= Space( 5 )
	cConta  := Space( 10 )
	cCheque := Space( 15 )
EndIf

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCheckDLL
Function Checa DLL
@param   	lValidaID - ID Validacao
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCheckDLL(lValidaID)

Local nRet			:= -1   		// Retorno da Method da dll
Local cBuffer		:=	Space( 10 )	// Armazena o id da dll
Local cIdDll  		:= ''			// Guarda o final da dll
Local cIdProt		:= ''			// Guarda o final da versao do Protheus
Local cDllVer   	:= ''			// Armazena o retorno da versao do Protheus
Local cFrameIP		:= ""			// Armazena o servidor do TSC
Local cFramePort	:= ""			// Porta do TSC
Local nTipoMsg		:= 0			// Indica o tipo da msg a ser exibida
Local nHnd			:= oImpBWECF:GetHandle()    //Handle do ECF
Local lAutomato		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default lValidaID 	:= .F.			// Flag para verificacao da versao da dll

If nHnd = -1 .AND. !lAutomato
		
	nHnd := ExecInDLLOpen( cDLLSIGALOJA )
	
	oImpBWECF:SetHandle(nHnd)
	If nHnd = -1
		STFMessage("STWCheckDLL", "ALERT", "Erro ao abrir " + cDLLSIGALOJA)
		STFShowMessage("STWCheckDLL")
		Final( "Erro Ao Abrir " + cDLLSIGALOJA )
	EndIf
	
	If SuperGetMV( "MV_LJTSC" )
		cFrameIP   := STFGetStat( "TSCSRV" )
		cFramePort := STFGetStat( "TSCPORT" )
		If !Empty( cFrameIP ) .AND. !Empty( cFramePort )

		    nRet := oImpBWECF:OpenIPPort( nHnd , cFrameIP, cFramePort)
			If nRet == -1
				// "Não foi possível estabelecer conexão com o AP6 Terminal Services Client." ### "Atenção"
				//	MsgStop( "Não foi possível estabelecer conexão com o AP6 Terminal Services Client.", "Atenção" )
				STFMessage("STWCheckDLL", "STOP", "Não foi possível estabelecer conexão com o AP6 Terminal Services Client.")
			    STFShowMessage("STWCheckDLL")
			Else
				//E necessario esta mensagem para funcionar o MetaFrame.
				//"Conexão estabelecida com o AP6 Terminal Services Client." ### "Atenção"
				//MsgStop( "Conexão estabelecida com o AP6 Terminal Services Client.", "Atenção" )
				STFMessage("STWCheckDLL", "STOP", "Conexão estabelecida com o AP6 Terminal Services Client.")
				STFShowMessage("STWCheckDLL")
			EndIf
		EndIf
	EndIf
EndIf

If nHnd <> -1 .AND. lValidaID
	nRet	:= oImpBWECF:ExecDLLRet(nHnd, 999, @cBuffer)
	LjxVldVrDLL(cBuffer,.F.,.F.)
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenCom
Function   Abre comunicacao
@param   	cModelo
@param   	cPort
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenCom(cModelo, cPort, lClose)

Local nRet		:=-1
Local lNoOpen	:= .f.
Local nX		:= 0
Local aECFDir	:= {}
Local lAutomato :=  If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cModelo := ""
Default cPort   := ""
DEFAULT lClose	:= .T.


//Primeiramente verifica se é um  modelo de Emulador de ECF
//e se o mesmo poderá ser aberto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz a verificao do emulador. Somente permite a utilizacao na empresa ³
//³ teste (99) para efeito de testes no Laboratorio de Produtos Microsiga³
//³ Este controle se faz necessario para evitar que este recurso seja    ³
//³ utilizado em producao.                                               ³
//³ A unica excecao eh para a empresa Microsiga pois este recurso eh     ³
//³ utilizado pelo CPR para demonstracoes.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//If STWIsTax() .OR. lNotFiscal

	If "EMULATOR" $ Upper(Alltrim(cModelo))
	    lApagaECF := STWUsaECFE(SM0->M0_CGC)
		If cEmpAnt <> "99" .AND. SM0->M0_CGC <> "53113791000122" .AND. !( lApagaECF .OR. LjRecEmul(SM0->M0_CGC , "2" , .T.) )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apaga o arquivo que configura o emulador para nao permitir sua       ³
			//³ utilizacao                                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aECFDir := Directory(GetClientDir()+"ECFEMUL.???")
			For nX := 1 to Len( aECFDir )
				FErase( GetClientDir()+aECFDir[nX][1] )
			Next nX
				lNoOpen := .T.
				STFMessage("OPENCOM","STOP","Foi detectado que o cadastro de estação não está configurado corretamente conforme o convênio ECF. Peça ao Administrador para configurar o ECF e então continuar operando o sistema.") //STR
				STFShowMessage("OPENCOM")

		EndIf
	EndIf
	
	If lAutomato
		nRet := 0
	ElseIf !lNoOpen

		STFMessage("STWOpenCom", "RUN", " Conectando com a Impressora Fiscal  " + Left(cModelo, At(space(1), cModelo) -1) + " na porta " + cPort ,{||  nRet := oImpBWECF:OpenCom( cModelo, cPort, lClose ) })
		STFShowMessage("STWOpenCom")

	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCloseCom
Function  fecha comunicacao
@param   	cPort
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
/*/
//-------------------------------------------------------------------
Function STWCloseCom(cPort)
Local 	nRet := -1	//Retorno

Default cPort	:= ""

nRet := oImpBWECF:CloseCom( cPort )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWListPrint
Function     imprime lista
@param   	cBuffer   Buffer
@param   	lMostraMsg       Mensagem
@param   	lCodECF , Lista codigo ecf
@param   	lListEcnf , Lista impressoras nao fiscais
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWListPrint(cBuffer, lMostraMsg,lCodECF,lListEcnf)

Local nRet := -1  //Retorno
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cBuffer 	:= ""
Default lMostraMsg	:= .F.
Default lCodECF		:= .F.
Default lListEcnf	:= .F.

If lAutomato
 	nRet := 0
Else 	
	nRet := oImpBWECF:ListPrint( @cBuffer, lMostraMsg, lCodECF ,lListEcnf)
Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWListINF
Function     imprime lista de impressoras não fiscais
@param   	cBuffer   Buffer
@param   	lMostraMsg       Mensagem
@author  Varejo
@version 	P11.8
@since   	19/03/2015
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWListINF(cBuffer, lMostraMsg)

Local nRet := -1  //Retorno
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cBuffer 	:= ""
Default lMostraMsg	:= .F.

If lAutomato
	nRet := 0
Else
	nRet := oImpBWECF:ListINF( @cBuffer, lMostraMsg )
Endif

Return nRet

//-------------------------------------------------------------------
Function STWListCodPrint(cBuffer, lMostraMsg)

Local nRet := -1  //Retorno
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cBuffer 	:= ""
Default lMostraMsg	:= .F.

If lAutomato
	nRet := 0
Else
	nRet := oImpBWECF:ListPrint( @cBuffer, lMostraMsg, .T. )
Endif

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReadingX
Function  Leitura X
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReadingX()

Local nRet 		:= -1    //Retorno
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

If STWCheckpaper(.T.)
	If lAutomato
		nRet := 0
	Else
		nRet := oImpBWECF:ReadingX()
	Endif	
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReductZ
Function Reducao Z
@param   	cBuffer - Buffer
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReductZ(cBuffer)

Local nRet := -1        //Return
Local lDados	:= AllTrim(cBuffer) == "#"
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cBuffer	:= ""

If STWCheckpaper(.T.)
	STWLjPrintlCOO(@nRet)
	If lAutomato
		nRet := 0
	Else	
		nRet := oImpBWECF:ReductZ( @cBuffer )
	Endif	
EndIf

// Checa se e' a primeira reducao do mes e faz LMF
If !lDados
	STWChkDataMov()
EndIf

If !lAutomato .and. File(GetClientDir() + "RPCFRONT.INI")
	WritePProString("RPC", "UltimoServer", "0", GetClientDir() + "RPCFRONT.INI")
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDadoReductZ
Function Retorna dados da Reducao Z
@param   	cBuffer - Buffer
@author  	Varejo
@version 	P11.8
@since   	29/12/2016
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDadoReductZ(cBuffer)

Local nRet := -1        //Return
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cBuffer	:= ""

If STWCheckpaper(.T.)
	STWLjPrintlCOO(@nRet)
	If lAutomato 
		nRet := 0
	Else	
		nRet := oImpBWECF:DadoReductZ( @cBuffer )
	Endif	
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenReceipt
Function abre cupom
@param1 cCNPJ    	Cnpj do cliente
@param2 cCliente    Codigo do cliente
@param3 cLojaCli    Loja do cliente
@param4 lImpCpfNpj	Indica se será impresso o cnpj no CF
@param5 lVldSerie	Define se Valida a Serie
@param6 lInfoEnd	Informa o endereço do cliente
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenReceipt(cCNPJ		, cCliente , cLojaCli ,;
				 		lImpCpfNpj 	, lVldSerie	, lInfoEnd)

Local nRet 			:= -1                       // Retorno
Local cNome     	:= ""      					// Nome do Cliente
Local cEnd      	:= ""      					// Endereco do Cliente
Local lContinua		:= .T.
Local lLjInfDocCli	:= ExistFunc("LjInfDocCli")
Local nLjInfDocCli	:= IIf(lLjInfDocCli, LjInfDocCli(), 1)
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

DEFAULT cCNPJ    	:= ""	   					// Informa o codigo do cliente
DEFAULT cCliente    := ""
DEFAULT cLojaCli    := ""
DEFAULT lImpCpfNpj	:= .F.						// Indica se será impresso o cnpj no CF
DEFAULT lVldSerie	:= .T.						// Define se Valida a Serie
DEFAULT lInfoEnd	:= .F.						// Informa o endereço do cliente

//If STWVldEcfPtg(@nRet)
//	Return nRet
//EndIf

// Faz o tratamento do numero de serie
If lContinua .And. lVldSerie .And. !STWValSerie()
	nRet := 1
	lContinua := .F.
EndIf

If lContinua .And. !STWCheckDate()
	nRet := 1
	lContinua := .F.
EndIf

If lContinua .And. STWCheckpaper(.T.)

	oImpBWECF:lImpCpfNpj := lImpCpfNpj	 //PAF Imprime CNPJ no Cupom

	If lImpCpfNpj .OR. lInfoEnd

		If STBIsPaf()
			cCNPJ := cCNPJInf
			cNome := cNomeInf
			cEnd  := cEndInf

			If Empty(cCNPJ)
				oImpBWECF:lImpCpfNpj	:= .F.
			EndIf
		   	If  lVldSerie
				If !STWValGT() .OR. !STWValSerie()
					nRet := 1
					lContinua := .F.
				Endif
		   	Endif
		Else
			If ( Empty(cCNPJ) .and. lImpCpfNpj ) .or. ( lInfoEnd )
				cCNPJ := cCNPJInf
				cNome := cNomeInf
				cEnd  := cEndInf
			EndIf
			
			If !Empty(cCNPJ)
				If lDadosInf
					oImpBWECF:lImpCpfNpj	:= .T.
					lDadosInf := .F. // Reinicio a variavel de controle
				Else
					oImpBWECF:lImpCpfNpj	:= .F.
				EndIf
			Else
				oImpBWECF:lImpCpfNpj	:= .F.
			EndIf

			If  lVldSerie
				If !STWValGT()
					nRet := 1
					lContinua := .F.
				Endif
			Endif
		EndIf
    EndIf

    If lContinua
    	STWLjPrintlCOO(@nRet)
    	If lAutomato
    		nRet := 0
    	Else
    		nRet := oImpBWECF:OpenReceipt( cCNPJ, cNome, cEnd)
    	Endif	
    EndIf
EndIf

/*
	Limpo variaveis static
*/
IF !lLjInfDocCli .Or. (lLjInfDocCli .And. nLjInfDocCli <= 1)
	cCNPJInf 	:= ""
	cNomeInf 	:= ""
	cEndInf  	:= ""
	lDadosInf 	:= .F.
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWIdCliente
Function Identifica Cliente

@param1 lImpCpfNpj	Indica se será impresso o cnpj no CF
@author  Varejo
@version 	P11.8
@since   	06/04/2016
@return  	nRet - Retorno do Equipamento
/*/
//-------------------------------------------------------------------
Function STWIdCliente(lImpCpfNpj,cMensagem)
Local nRet 			:= -1                       // Retorno
Local cNome     	:= ""      					// Nome do Cliente
Local cEnd      	:= ""      					// Endereco do Cliente
Local cCNPJ			:= ""
Local lContinua		:= .T.

DEFAULT lImpCpfNpj	:= .F.						// Indica se será impresso o cnpj no CF
DEFAULT cMensagem	:= ""

//If STWVldEcfPtg(@nRet)
//	Return nRet
//EndIf

If !STWCheckDate()
	nRet		:= 1
	lContinua	:= .F.
EndIf

//Tratamento para mandar o CPF somente 1 vez, pois na Epson dá problema se mandar 2 vezes
If lContinua .And. !oImpBWECF:lImpCpfNpj
	oImpBWECF:lImpCpfNpj := lImpCpfNpj	 //PAF Imprime CNPJ no Cupom
	
	If lImpCpfNpj
		If STBIsPaf()
			cCNPJ := AllTrim(cCNPJInf)
			cNome := AllTrim(cNomeInf)
			cEnd  := AllTrim(cEndInf)
	
			If Empty(cCNPJ)
				oImpBWECF:lImpCpfNpj	:= .F.
			EndIf
		Else
			If Empty(cCNPJ) .and. lImpCpfNpj
				cCNPJ := AllTrim(cCNPJInf)
				cNome := AllTrim(cNomeInf)
				cEnd  := AllTrim(cEndInf)
			EndIf
	
			If !Empty(cCNPJ)
				If lDadosInf
					oImpBWECF:lImpCpfNpj	:= .T.
					lDadosInf := .F. // Reinicio a variavel de controle
				Else
					oImpBWECF:lImpCpfNpj	:= .F.
				EndIf
			EndIf
		EndIf
	EndIf
	
	If !(Empty(cCNPJ) .And. Empty(cNome) .And. Empty(cEnd))
		cMensagem := ""
		
		//O tratamento de CPF/CNPJ no final da venda, na bematech é diferente
		If "BEMATECH" $ Upper(STFGetStation("IMPFISC"))
			If !Empty(cCNPJ)
				cMensagem += STR0019 + cCNPJ + CHR(10) //'CPF/CNPJ:'
			EndIf
			
			If !Empty(cNome)
				cMensagem += STR0020 + cNome + CHR(10) //'Nome:'
			EndIf
			
			If !Empty(cEnd)
				cMensagem += STR0021 + cEnd + CHR(10) //'Endereco:'
			EndIf 
		EndIf
		
		nRet := oImpBWECF:idCliente(cCNPJ, cNome, cEnd)
	Else
		nRet := 0
	EndIf
EndIf

/* Limpo variaveis static */
cCNPJInf 	:= ""
cNomeInf 	:= ""
cEndInf  	:= ""
lDadosInf 	:= .F.

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWGetReceipt
Function pega recebimento
@param1   	cBuffer  Buffer
@param2   	cCancel  Cancelamento
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWGetReceipt( cBuffer, cCancel )

Local nRet 		:= -1   //Retorno
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cBuffer	:= ""
Default cCancel	:= ""

If lAutomato
	nRet := 0
Else
	nRet := oImpBWECF:GetReceipt( @cBuffer, cCancel )
Endif
	
Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CXCX
Function  Pega Serie
@param1   	cBuffer  Buffer
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/

//-------------------------------------------------------------------
Function STWGetSerie( cBuffer )
Local nRet := -1
Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cBuffer := ""

If lAutomato
	nRet := 0
Else
	nRet := oImpBWECF:GetSerie( @cBuffer )
Endif

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGetPDV
Function
@param   	cBuffer  Buffer
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWGetPDV( cBuffer )

Local nRet := -1     //Return

Default cBuffer := ""

nRet := oImpBWECF:GetPDV( @cBuffer )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRegItem
Function Registra Item
@param 	cCodigo      Codigo do item
@param  cDescricao   Descricao do item
@param  cQtde        Quantidade
@param  cVlrUnit     Valor unitario
@param  cVlrDesconto Valor Desconto
@param  cAliquota    Aliquota Imposto
@param  cTotIt       Valor Total do Item
@param  cUnidMed     Unidade de medida do item
@param  cTypeTes     Tipo da TES 1-Entrada ou 2-Saida
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
/*/
//-------------------------------------------------------------------
Function STWRegItem( cCodigo 		,cDescricao	, cQtde	, cVlrUnit,;
					 cVlrDesconto	,cAliquota	,cTotIt	,cUnidMed,;
					 cTypeTes )

Local nRet 			 := -1  //Retorno
Local lAutomato     :=  If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cCodigo      := ""
Default cDescricao   := ""
Default cQtde        := ""
Default cVlrUnit     := ""
Default cVlrDesconto := ""
Default cAliquota    := ""
Default cTotIt       := ""
Default cUnidMed     := ""
Default cTypeTes     := ""

If STWCheckpaper(.T.)
	If lAutomato
		nRet := 0
	Else
		nRet := oImpBWECF:RegItem(  cCodigo	,cDescricao, cQtde,cVlrUnit,;
								cVlrDesconto,cAliquota,cTotIt,cUnidMed,)

		If nRet == 0 .And. STBIsPaf()
			STWGrvCCGT( "SIGALOJA.VLD" )
		EndIf
	Endif							
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWGetAliq
Function   pega aliquotas
@param   	cBuffer - Buffer
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWGetAliq( cBuffer )

Local nRet := -1    //retorno

Default cBuffer := ""

nRet := oImpBWECF:GetAliq( @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWISSGetAli
Function  pega aliquota ISS
@param   	cBuffer - Buffer
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWISSGetAli( cBuffer )

Local nRet := -1  //retorno

Default cBuffer := ""

nRet := oImpBWECF:GetAliIss( @cBuffer )

Return nRet


//-------------------------------------------------------------------

/*/{Protheus.doc} STWGetConPay
Function  Pega condicao de pagamento
@param   	cBuffer - Buffer
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWGetConPay( cBuffer )

Local nRet := -1

Default cBuffer := ""

nRet := oImpBWECF:GetConPay( @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRecCondPay
Function  grava condicao de pagamento
@param   	cCondicao - Condicao de pagamento
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRecCondPay( cCondicao )

Local nRet := -1

Default cCondicao	:= ""

nRet := oImpBWECF:RecCondPay( cCondicao )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCancelItem
Function  cancela item
@param 	cNumItem     Numero do item
@param 	cCodigo      Codigo do item
@param  cDescricao   Descricao do item
@param  cQtde        Quantidade
@param  cVlrUnit     Valor unitario
@param  cVlrDesconto Valor Desconto
@param  cAliquota    Aliquota Imposto
@param  cSupervisor   supervisor
@param  lImpIncl     Controle impressao
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCancelItem( cNumItem	, cCodigo	  ,cDescricao,cQtde,;
						cVlrunit	,cVlrdesconto ,cAliquota	,cSupervisor,;
						lImpIncl )

Local nRet			:= -1   //Retorno

Default cNumItem	:= ""
Default cCodigo		:= ""
Default cDescricao  := ""
Default	cQtde		:= ""
Default cVlrunit	:= ""
Default cVlrdesconto:= ""
Default cAliquota	:= ""
Default cSupervisor := ""
Default lImpIncl	:= .T.

If STWCheckpaper(.T.)
	nRet := oImpBWECF:CancelItem(	cNumItem	,cCodigo		,cDescricao ,cQtde,;
			 							cVlrunit	,cVlrdesconto	,cAliquota  ,cSupervisor,;
										lImpIncl )
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCancReceipt
Function   Cancela recebimento
@param   	cSupervisor - Supervisor
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
/*/
//-------------------------------------------------------------------
Function STWCancReceipt( cSupervisor )
Local nRet 			:= -1
Local cRet			:= ""
Local lCupAberto	:= .F.
Local lSTbIsPaf		:= STbIsPaf()
Local cSerie		:= ""
Local cCupomArg		:= ""

Default cSupervisor	:= ""

If STWCheckpaper(.T.)
	nRet := STWPrinterStatus('5', @cRet )

	If nRet <> 7
		lCupAberto := .F.
	Else
		lCupAberto := .T.
		If STFGetCfg("lEcfArg")
			STWGetSerie(@cSerie)
	   		nRet := STWGetReceipt(@cCupomArg, "D|" + cSerie )
	   	EndIf
	Endif

	//Restaura o valor da variavel nRet, de acordo com a declaracao
	nRet := -1
	nRet := oImpBWECF:CancelReceipt(cSupervisor, nRet )

	If nRet == 0
		//Devo gravar a SLX com as informações do cupom fiscal que foi cancelado 
		If	lSTbIsPaf
			//Passo o parametro lImportSale com .T. para que não peça a tela do supervisor
			STDLogCanc( .F. , /*nItem*/	, cSupervisor , .T. ,;
			 			.F.	, .T.		)
		EndIf
		
		If lSTbIsPaf .Or. LJAnalisaLeg(20)[1] .OR. SuperGetMV( "MV_LJGRVVB", ,.F. )
			STWGrvGT( "SIGALOJA.VLD" )
		Endif
	EndIf
		
	//LjLogDevol()
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCloseReceipt
Function  fecha pagamentos
@param   	cMens 		- Mensagem
@param   	nVlrTotal 	- Valor total
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCloseReceipt( cMensAux , nVlrTotal)
Local nRet			:= -1            							//Retorno
Local cArquivo		:= STFGetStat( "JOURNAL" )					// Armazena o conteudo do campo LG_JOURNAL
Local cArq	   		:= "SIGALOJA.VLD"								// Default para gravacao da venda bruta criptografada
Local cMens			:= ""
Local lLjNfPafEcf	:= STBIsPaf()
Local lAutomato     :=  If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cMens		:= ""
Default nVlrTotal	:= 0  

If STWCheckpaper(.T.)
   //	If SL1->(FieldPos("L1_CGCCLI")) > 0
   //		If STFGetCfg("lCredDF") .AND. oImpBWECF:lImpCpfNpj
   //			cMens	:= "CREDITO LEI 4.159/08" + CRLF + cMens
   //		EndIf
   //	EndIf

	If STBIsPaf()
        cMens:= "MD-5: "+ STBRETMD5() // Armazena o comando de fechamento e imprime o MD5 do PAF-ECF na primeira posicao

		/*No Novo Ato ER 02.05 - foi removida a mensagem do PAF*/
		//Exigencia do Ato Cotepe 01.13 - Requisito VIII-B.6 - apos a impressÃ£o do MD-5 
		//contendo cliente identificado pelo CPF/CNPJ deve-se imprimir "NL"
		//If  ValType(oImpBWECF:lImpCpfNpj) == "L" .AND. oImpBWECF:lImpCpfNpj .AND. LjAnalisaLEG(62)[1] //Leg 52 = somente para validar se vem do Distrito Federal
		//	cMens += '"NL"'
		//EndIf

		/*
		HOMOLOGACAO PAF-ECF 2013
		a Ordem das Mensagens Impressas deve ser:
		1 - MD5 ; 2 - Msg do TPL PCL ou DAV/PRE-VENDA XXXXX ; 3 - Msgs dos Estados (Minas Legal, Cupom Mania etc.)
		4 - mensagens adicionais
		*/
		cMens +=  Chr(10) + AllTrim(cMensAux) + STBFMModPaf()
	Else
		cMens +=  Chr(10) + AllTrim(cMensAux) 
	EndIf 

	If lAutomato
		nRet := 0 
	Else
		nRet := oImpBWECF:CloseReceipt( cMens , nVlrTotal, cArquivo)
	Endif	

	If nRet == 0
		If lLjNfPafEcf .Or. LJAnalisaLeg(20)[1] .OR. SuperGetMV( "MV_LJGRVVB", ,.F. )
			STWGrvGT( cArq )
			
			If lLjNfPafEcf
				LjxGrvMdz("PV", 0, "REGPAF", "", "") //Registra o primeiro movimento, caso exista não grava duas vezes
			EndIf
		Endif
	EndIf
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWPayment
Function  Realiza Pagamentos
@param 	cPagto      Pagamento
@param  cVinculado  Vinculado
@param 	nVlrTotal   Valor Total
@param 	nDecLoc     Deciamis Localizacao
@param 	cPercepcion cPercepcion
@param 	aImpsSL1    Array SL1
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPayment(cPagto, cVinculado, nVlrTotal, nDecLoc,;
					cPercepcion, aImpsSL1)

Local 	nRet 		:= -1	 // Retorno
Local 	nX			:= 0     //Contador
Local	lAutomato     :=  If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default	cPagto      := ""
Default cVinculado  := ""
Default	nVlrTotal   := 0
Default	nDecLoc     := 0
Default	cPercepcion := ""
Default	aImpsSL1    := {}

If STWCheckpaper(.T.)
	If lAutomato
		nRet := 0
	Else
		nRet := oImpBWECF:Payment(	cPagto		, cVinculado ,nVlrTotal,;
								cPercepcion	, aImpsSL1 )
	Endif
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDescTot
Function   desconto total
@param   	cDesc     Desconto
@param   	cVlrTotal Valor
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDescTot( cDesc , cVlrTotal, cTipoCli )

Local nRet 			:= -1      //retorno
Local lAutomato     :=  If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

Default cDesc       := ""
Default cVlrTotal   := ""
Default cTipoCli	:= "2"

If STWCheckpaper(.T.)
	If lAutomato
		nRet := 0
	Else	
		nRet := oImpBWECF:DescTot( cDesc , cVlrTotal, cTipoCli )
	Endif	
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWAddTot
Function  add Total
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWAddTot( cAcres )

Local nRet 		:= -1
Default cAcres  := ""

	If STWCheckpaper(.T.)
		nRet := oImpBWECF:AddTot( cAcres )
    EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWMemFisc
Function    Memoria fiscal
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWMemFisc( cDataIni,cDataFim,cReducIni,cReducFim,;
					 cCheck )

Local nRet			:= -1

Default cDataIni    := ""
Default cDataFim    := ""
Default cReducIni   := ""
Default cReducFim   := ""
Default cCheck      := ""

If STWCheckpaper(.T.)
	oImpBWECF:MemFisc(	cDataIni ,cDataFim	,cReducIni ,cReducFim,;
						cCheck )
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWAddAliq
Function  add aliquota
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return   Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWAddAliq( cAliquota, cType )
Local nRet := -1

Default cAliquota   := ""
Default cType       := ""


nRet := oImpBWECF:AddAliq( cAliquota, cType )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenNotFiscalReceipt
Function  abre cupom nao fiscal
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenNotFiscalReceipt( cCondicao ,cValor ,cTotalizador ,cTexto,;
								  nPArcels )
Local nRet 				:= -1
Default cCondicao       := ""
Default cValor          := ""
Default cTotalizador    := ""
Default cTexto          := ""
Default nPArcels	    := 0

If STWCheckpaper(.T.)
	STWLjPrintlCOO(@nRet)
	nRet := oImpBWECF:OpenNotFiscalReceipt( cCondicao ,cValor ,cTotalizador ,cTexto,;
							  				 nParcels )
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWTxtNotFiscalReceipt
Function texto cupom nao fiscal
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWTxtNotFiscalReceipt( cTexto, nVias )

Local nRet		:= -1
Default nVias   :=  0
Default cTexto  :=  ""

If STWCheckpaper(.T.)
	nRet := oImpBWECF:TxtNotFiscalReceipt( cTexto, nVias )
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCloseNotFiscalReceipt
Function fecha cupom nao fiscal
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCloseNotFiscalReceipt()

Local nRet		:= -1

If STWCheckpaper(.T.)
	nRet := oImpBWECF:CloseNotFiscalReceipt()
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrinterStatus
Function    status impressora
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPrinterStatus( cType, cBuffer )

Local nRet 		 := -1
Local lRet 		 := .F.
Local cRetorno	 := ""
Default cType    := ""
Default cBuffer  := ""

If lEmitNfce
	nRet := 0
Else
	nRet := oImpBWECF:PrinterStatus( cType, @cBuffer )

	If nRet == 0
		nRet := STWTreatRet(cType, @cBuffer)
	EndIf
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWNotFiscalTotal
Function total nao fiscal
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWNotFiscalTotal( cNum, cDescr )

Local nRet		:= -1
Default cNum    := ""
Default cDescr  := ""

	nRet := oImpBWECF:NotFiscalTotal( cNum, cDescr )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWAutentic
Function Autenticacao ecf
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWAutentic( cVezes, cValor, cTexto )
Local nRet		:= -1
Default cVezes  := ""
Default cValor  := ""
Default cTexto  := ""

nRet := oImpBWECF:Autentic( cVezes, cValor, cTexto )


Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDrawer
Function   Gaveta de dinheiro
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDrawer()
Local nRet := -1

nRet:= oImpBWECF:Drawer()

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenECF
Function abre ecf
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenECF()
Local nRet := -1

If STWIsTax()
	STFMessage("STWOpenECF", "RUN", " Aguarde a abertura da Impressora Fiscal... "  ,{||  nRet := oImpBWECF:OpenECF() })
	STFShowMessage("STWOpenECF")
Else
	nRet := 0
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCloseECF
Function   Fecha ecf
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCloseECF(cPort)
Local nRet := -1

Default cPort := ""

	nRet := oImpBWECF:CloseECF(cPort)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWSupply
Function   suplimento
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWSupply( nTipo, cValor, cPagto,cTotal,;
					nModo, cFormSup )

Local nRet 		:= -1

Default nTipo   := 0
Default cValor  := ""
Default cPagto  := ""
Default cTotal  := ""
Default nModo   := 0
Default cFormSup:= ""


	If ("DARUMA FS345" $ STFGetStat("IMPFISC")) .AND. Empty(GetPvProfString("DARUMA", "SUPRIMENTO", "", GetClientDir()+"sigaloja.ini"))
/*		STFMessage("SUPPLY","STOP","Operação não efetuada. Cadastre no arquivo SIGALOJA.INI a seção [DARUMA] e a"
									"chave SUPRIMENTO=FORMA DE PAGAMENTO, onde FORMA DE PAGAMENTO é a forma utilizada"
									"para realizar o suprimento. Para maiores detalhes verifique o boletim técnico"
									"referente a FNC 00000005817/2008."
		*/		
		Return nRet
	Else

		If STWCheckpaper(.T.)
			nRet := oImpBWECF:Supply( nTipo, cValor, cPagto,cTotal,;
									   nModo, cFormSup )
		EndIf

	EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWHourSummerAdjust
Function ajusta horario de verao
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWHourSummerAdjust( cType )

Local nRet 		:= -1

Default cType	:= ""

If STWCheckPaper(.T.)
	nRet := oImpBWECF:HourSummerAdjust( cType )
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWManagReportPrint
Function    relatorio gerencial
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWManagReportPrint( cTexto ,nVias )
Local nRet		:= -1
Local lIsNfce	:= .F.
Local nI		:= 0
Local lGuil		:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina 
Local lIsPafNfce:= STFGetCfg("lPAFNFCE") .Or. IIf(ExistFunc("LjPafNFCe"),LjPafNFCe(),.F.)

Default cTexto	:= ""
Default nVias	:= 0

If (nModulo == 5 .OR. nModulo == 51) .OR.;
	   ((LJAnalisaLeg(61)[1] .AND. STBGetNFCE()) .AND. (nModulo == 12 .OR. nModulo == 23))	//Tratamento NFC-e onde permite o uso de equipamento nao fiscal

	lIsNfce := .T.
EndIf

If lIsNfce .OR. lIsPafNfce
	For nI:= 1 to nVias
		nRet := STWPrintTextNotFiscal(cTexto)
	Next nI	
	If (nRet = 0) .AND. lGuil		//Se operação bem sucedida e guilhotina ativada
		cTexto := Replic(CHR(10)+CHR(13),6)
		cTexto += TAG_GUIL_INI+TAG_GUIL_FIM		//Corte de Papel								
		STWPrintTextNotFiscal(cTexto)
	EndIf
Else
	If STWCheckpaper(.T.)
		STWLjPrintlCOO(@nRet)
		nRet := oImpBWECF:ManagReportPrint( cTexto ,nVias)
	EndIf
	
	//PAF-ECF: Armazena na tabela de apoio(MDZ), emissão de relatório gerencial
		STDGrvMdz("RG")
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWSubTotalReceipt
Function   total recebimento
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
/*/
//-------------------------------------------------------------------
Function STWSubTotalReceipt( cBuffer, cImprime )

Local nRet 		:= -1

Default cBuffer	:= ""
Default cImprime:= ""

nRet := oImpBWECF:SubTotalReceipt( @cBuffer, cImprime )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWNumItemPrint
Function  numero item impresso
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWNumItemPrint( cBuffer )

Local nRet := -1

Default cBuffer := ""

nRet := oImpBWECF:NumItemPrint( @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWEmulEcf
Function     ECFEmulator
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWEmulEcf( cNumPdv, cNumCaixa, cNomeCaixa,cNumCupom )

Local nRet 			:= -1

Default cNumPdv		:= ""
Default cNumCaixa	:= ""
Default cNomeCaixa  := ""
Default cNumCupom   := ""

nRet := oImpBWECF:EmulEcf( 	cNumPdv, cNumCaixa, cNomeCaixa,cNumCupom )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWSalesOrder
Function   ordem de venda
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWSalesOrder( cTef ,cTexto ,cValor ,cCondPgTEF )

Local nRet 			:= -1

Default cTef        := ""
Default cTexto      := ""
Default cValor      := ""
Default cCondPgTEF	:= ""

	If STWCheckPaper(.T.)
		nRet := oImpBWECF:SalesOrder( cTef ,cTexto ,cValor ,cCondPgTEF )
    EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReceiveNotFiscal
Function  recebimento nao fiscal
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReceiveNotFiscal( cTotalizador, nValor, cForma )
Local nRet				:= -1

Default cTotalizador	:=""
Default nValor      	:=0
Default cForma      	:=""

If STWCheckPaper(.T.)
	nRet:= oImpBWECF:ReceiveNotFiscal( cTotalizador, nValor, cForma )
EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWDownMFD
Function  Memoria fita detalhe
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDownMFD( cType, cInicio, cFinal )
Local	nRet		:= -1
Local cSerieIF	:= AllTrim(STFGetStation("SERPDV"))
Local cArqExt	:= ""
Local cPathArq	:= ""
Local cNomArq	:= ""
Local cConteudo	:= ""
Local cPathMFD	:= PAF_ARQMFD + "\"
Local nY		:= 0
Local lLjNfPafEcf:= StbIsPaf()
Local aArqsDir	:= {}

Default  cType      := ""
Default  cInicio    := ""
Default  cFinal     := ""

nRet := oImpBWECF:DownMFD( cType, cInicio, cFinal )

If nRet == 0 .And. lLjNfPafEcf
	STBFMGerPath( @cPathArq )
	
	/*Para Arquivo MFD*/
	cNomArq := cSerieIF + "_"
	cNomArq += Dtos(Date()) + "_"
	
	/*Deleto somente arquivos MFD criados no mesmo dia*/
	aArqsDir := Directory(cPathArq + "*.MFD")   //Lista os arquivos .TXT do diretorio
	For nY:= 1 To Len(aArqsDir)
		If Upper(cNomArq) $ Upper(aArqsDir[nY][F_NAME])
			FErase(cPathArq + aArqsDir[nY][F_NAME])
		EndIf
	Next nY
	
	/*Para Arquivo MFD - termina de preencher o nome para gravação final*/
	cNomArq += StrTran( Time(), ":")
	cArqExt := ".MFD"
		
	If File(cPathArq + "DOWNLOAD.MFD")
		FRenameEx(cPathArq + "DOWNLOAD.MFD",cPathArq + cPathMFD + cNomArq + cArqExt, NIL)
		STBFMSignPaf(cPathArq + cPathMFD + cNomArq + cArqExt,.F.,.T.)
		FErase(cPathArq + "DOWNLOAD.MFD")
		MsgAlert("Arquivo Gerado com sucesso - Tipo MFD")
	Else
		LjGrvLog(NIL,"Arquivo MFD não localizado. Verifique -> Arquivo [" + cPathArq + "DOWNLOAD.MFD" + "]")
		If lHomolPaf
			Conout("Arquivo MFD não localizado. Verifique -> Arquivo [" + cPathArq + "DOWNLOAD.MFD" + "]")
		EndIf
	EndIf
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWExecHsr
Function    Executa comando
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWExecHsr( cComando, cPosicao )
Local xRet     := Nil
Local cDelimit := ""

If STFGetCfg("lEcfArg") .AND. AllTrim(STFGetStat("LG_IMPFISC")) == "ECF EMULATOR"
	cDelimit := "|"
Else
	cDelimit := CHR(28)
EndIf

Default	cComando := ""
Default cPosicao := ""

	xRet := oImpBWECF:ExecHsr( cComando, cPosicao, cDelimit )

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWListPinPad
Function   Lista Pinpads
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWListPinPad( cBuffer, lMostraMsg )

Local nRet 			:= -1

Default cBuffer 	:= ""
Default lMostraMsg 	:= .T.

	nRet := oImpBWECF:PinPadList( @cBuffer, lMostraMsg )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPinPadOpen
Function   abre pinpad
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPinPadOpen( cModelo, cPort )

Local 	nRet 	:= -1

Default cModelo := ""
Default cPort   := ""

	nRet := oImpBWECF:PinPadOpen( cModelo, cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc}	STWLeCPinPad
Function	
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWLeCPinPad( nPinHnd, cModalidade, cBuffer )

Local 	nRet		:= -1

Default nPinHnd		:= 0
Default cModalidade	:= ""
Default cBuffer     := ""


	nRet := oImpBWECF:PinPadLeC( nPinHnd, cModalidade, @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPinsSPadLeS
Function  Pinpad
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPinsSPadLeS( nPinHnd, cTrilha2, cMsg, cWork, cStatus )

Local	nRet	 := -1

Default nPinHnd  := 0
Default cTrilha2 := ""
Default cMsg     := ""
Default cWork    := ""
Default cStatus  := ""

nRet := oImpBWECF:PinPadLeS( nPinHnd, cTrilha2, cMsg, cWork, cStatus )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPinPadFin
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPinPadFin( nPinHnd )

Local nRet := -1

Default nPinHnd := 0

nRet := oImpBWECF:PinPadFin( nPinHnd )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCMC7List
Function  Lista CMC7
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCMC7List( cBuffer, lMostraMsg )

Local 	nRet 		:= -1

Default	cBuffer		:= ""
Default lMostraMsg  := .T.

nRet := oImpBWECF:CMC7List( @cBuffer, lMostraMsg )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCMC7Open
Function    Abre CMC7
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCMC7Open( cModelo, cPort, cMensagem )
Local nRet := -1

Default cModelo		:= ""
Default cPort       := ""
Default cMensagem   := ""


STFMessage("STWCMC7Open", "RUN", " Aguarde a abertura do Leitor de CMC7 " + cModelo + " na porta " + cPort ,{||  nRet := oImpBWECF:CMC7Open( cModelo, cPort, cMensagem ) })
STFShowMessage("STWCMC7Open")



Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCMC7Close
Function fecha CMC7
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCMC7Close( nCmc7Hnd, cPort )

Local	nRet	  := -1

Default nCmc7Hnd := 0
Default cPort     := ""

nRet := oImpBWECF:CMC7Close( nCmc7Hnd, cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCMC7DRead
Function   LE CMC7
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCMC7DRead(  nCmc7Hnd, cBuffer )

Local nRet := 0

Default nCmc7Hnd 	:= 0
Default cBuffer     := ""


nRet := 	oImpBWECF:CMC7ReadD(   nCmc7Hnd, @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCMC7DCRead
Function  LE CMC&
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCMC7DCRead( nCmc7Hnd, cBuffer )

Local nRet 		:= -1

Default nCmc7Hnd 	:= 0
Default cBuffer     := ""


nRet := oImpBWECF:CMC7ReadDC( nCmc7Hnd, @cBuffer )

Return nRet



//-------------------------------------------------------------------
/*/{Protheus.doc} STWDrawerList
Function   Lista gavetas
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDrawerList( cBuffer, lMostraMsg )

Default cBuffer 	:= ""
Default lMostraMsg     := .F.

	oImpBWECF:DrawerList( @cBuffer, lMostraMsg )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDrawerOpen
Function  Abre gaveta
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDrawerOpen( cModelo, cPort, cPortIF )
Local nRet := 0

Default cModelo 	:= ""
Default cPort 	:= ""
Default cPortIF := ""

If cPort  <> cPortIF

	STFMessage("STWDrawerOpen", "RUN", " Aguarde a abertura da gaveta " + cModelo + " na porta " + cPort ,{||  	nRet := oImpBWECF:DrawerOpen( cModelo, cPort ) })
	STFShowMessage("STWDrawerOpen")

EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDrawerClose
Function fecha gaveta
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDrawerClose( cPort, cPortIF )
Local nRet	:= 0
Local nGavHnd 	:= 0
Default cPort 	:= ""
Default cPortIF	:= ""

If oImpBWECF:lDrawer .AND. cPort <> cPortIF
	nRet := 	oImpBWECF:DrawerClose( nGavHnd, cPort )
EndIf
Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDrawerAci
Function  Acao da gaveta
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDrawerAci( nGavHnd, cPort )
Local nRet := -1
Default nGavHnd 	:= 0
Default cPort 	:= ""

nRet := oImpBWECF:DrawerAction( nGavHnd, cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDrawerStatus
Function   Status da gaveta
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDrawerStatus( nGavHnd, cPort )

Default nGavHnd 	:= 0
Default cPort 	:= ""

oImpBWECF:DrawerStatus( nGavHnd, cPort )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWListReceiptPrinters
Function     Lista recebimentos
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWListReceiptPrinters( cBuffer, lMostraMsg )

Local nRet			:= -1

Default	cBuffer    	:= ""
Default lMostraMsg 	:= .T.

nRet := oImpBWECF:ListReceiptPrinters( @cBuffer, lMostraMsg )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrintOpenCommunicationReceipt
Function   abre comunicacao
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPrintOpenCommunicationReceipt( cModelo, cPort )

Local nRet 		:= -1

Default	cModelo := ""
Default cPort	:= ""

nRet := oImpBWECF:PrintOpenCommunicationReceipt( cModelo, cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrintCloseCommunicationReceipt
Function  fecha comunicacao
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPrintCloseCommunicationReceipt( nCupHnd, cPort )

Local nRet	 	:= -1

Default nCupHnd := 0
Default cPort	:= ""

nRet := oImpBWECF:PrintCloseCommunicationReceipt( nCupHnd, cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrintNotFiscalReceipt
Function    recebimento nao fiscal
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPrintNotFiscalReceipt( nCupHnd, cBuffer )

Local nRet	 	:= -1

Default nCupHnd := 0
Default cBuffer := ""

nRet := oImpBWECF:PrintNotFiscalReceipt( nCupHnd, @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReaderList
Function  Lista leituras
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReaderList( cBuffer, lMostraMsg )

Local nRet			:= -1

Default cBuffer 	:= ""
Default lMostraMsg 	:= .T.

nRet := oImpBWECF:ReaderList( @cBuffer, lMostraMsg )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReaderOpen
Function  Abre Leitura
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReaderOpen( cModelo, cPort, cFoco )

Local nRet		:= -1

Default cModelo := ""
Default cPort   := ""
Default cFoco   := ""


STFMessage("STWReaderOpen", "RUN", " Aguarde a abertura do Leitor " + cModelo + " na porta " + cPort ,{||  nRet := oImpBWECF:ReaderOpen( cModelo, cPort, cFoco ) })
STFShowMessage("STWReaderOpen")



Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReaderClose
Function Fecha leitura
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReaderClose( nLeitHnd, cPort )

Local nRet := -1

Default nLeitHnd := 0
Default cPort    := ""

nRet := oImpBWECF:ReaderClose( nLeitHnd, cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReaderFocus
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReaderFocus( lModo )

Local nRet			:= -1

Default lModo		:= .T.

nRet := oImpBWECF:ReaderFocus( lModo )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWBlacList
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWBlacList( cBuffer, lMostraMsg )

Local nRet := -1

Default cBuffer    := ""
Default lMostraMsg := .T.

nRet := oImpBWECF:BalanceList( @cBuffer, lMostraMsg )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWBlacOpen
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWBlacOpen( cModelo, cPort )

Local nRet 		:= -1

Default cModelo := ""
Default cPort	:= ""



STFMessage("STWBlacOpen", "RUN", " Aguarde a abertura da balança " + cModelo + " na porta " + cPort ,{||  nRet := oImpBWECF:BalanceOpen( cModelo, cPort ) })
STFShowMessage("STWBlacOpen")



Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWBlacClose
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWBlacClose( cPort )

Local nRet := - 1

Default cPort		:= ""

nRet := oImpBWECF:BalanceClose( cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWBlacGet
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWBlacGet( nPeso )

Local nRet 			:= -1
Local cBuffer		:= space(10)

Default nPeso := 0

STFMessage("STWBlacGet", "RUN", " Aguarde a leitura da balança....",{||  nPeso := STWBalProc(cBuffer)  })
STFShowMessage("STWBlacGet")

If nPeso > 0
	nRet := 0
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDisplayList
Function     Lista display
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDisplayList( cBuffer, lMostraMsg )

Local nRet			:= -1

Default cBuffer 	:= ""
Default lmostraMsg 	:= .T.

nRet := oImpBWECF:DisplayList( @cBuffer, lMostraMsg )


Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenDisplay
Function      Abre dsiplay
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenDisplay( cModelo, cPort )

Local nRet 		:= -1

Default cModelo := ""
Default cPort	:= ""

nRet := oImpBWECF:DisplayOpen( cModelo, cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCloseDisplay
Function   fecah display
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCloseDisplay( nDisHnd, cPort )

Local nRet 		:= -1

Default nDisHnd := 0
Default cPort   := ""

nRet := oImpBWECF:DisplayClose( oImpBWECF:StatDisplay(), cPort )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWEnvDisplay
Function    Envia display
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWEnvDisplay( nDisHnd, cTexto )

Local nRet	:= -1

Default nDisHnd	:= 0
Default cTexto  := ""

nRet := oImpBWECF:DisplayEnv( oImpBWECF:StatDisplay(), cTexto )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc}STWMsgDisplay
@param   	EXPn1 - Handle de uso da DLL
@param   	EXPa1 - Array com parametros para execucao do P. Entrada
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWMsgDisplay( nTipo, aPARAMIXB )

Local cRet 			:= ""
Local cAux          := ""

Default nTipo		:= 0
Default aParamixb   := {}


If ExistBlock("MSGDISPLAY")
	cRet := ExecBlock("MSGDISPLAY",.F.,.F.,{nTipo,aPARAMIXB})
	If ValType(cRet) <> "C"
		cRet := ""
	EndIf
Else
	If nTipo == 1					// Apos Abrir o Display
		// "AP FRONT LOJA"
		cRet := "AP FRONT LOJA"
	ElseIf nTipo == 2				// Antes de Fechar o Display
		// "AP FRONT LOJA" ### "TERMINO NORMAL"
		cRet := PadR("AP FRONT LOJA",20) + Chr(10) + PadL("TERMINO NORMAL",20)
	ElseIf nTipo == 3				// Apos Abrir o Caixa
		// "CAIXA" ### "DISPONIVEL"
		cRet := PadC("CAIXA",20) + Chr(10) + PadC("DISPONIVEL",20)
	ElseIf nTipo == 4				// Apos Fechar o Caixa
		// "CAIXA" ### "FECHADO"
		STWDisplayEnv(oImpBWECF:StatDisplay(), "1C"+ "CAIXA" + ' ' + "FECHADO"  )
		STWDisplayEnv(oImpBWECF:StatDisplay(), "2C"+ " "  )
		cRet := PadC("CAIXA",20) + Chr(10) + PadC("FECHADO",20)
	ElseIf nTipo == 5				// Apos Registrar o Item
		cAux := AllTrim(Transform(aPARAMIXB[4],PesqPictQt("L2_QUANT",7)))
		cRet := Left(aPARAMIXB[3],20) + Chr(10) + ;
		cAux + PadL(SuperGetMV("MV_SIMB1") + " " + AllTrim(Transform(aPARAMIXB[4]*aPARAMIXB[5],PesqPict("SL1","L1_VLRTOT",12))), 20-Len(cAux))
	ElseIf nTipo == 6				// Quando Teclar SubTotal (F9)
		// "SUB-TOTAL:"
		cRet := "SUB-TOTAL:" + Chr(10) + SuperGetMV("MV_SIMB1") + Transform(aPARAMIXB[1],PesqPict("SL1","L1_VLRTOT",16))
	ElseIf nTipo == 7				// Quando Houver Troco
		// "TROCO:"
		cRet := "TROCO:" + Chr(10) + SuperGetMV("MV_SIMB1") + Transform(aPARAMIXB[1],PesqPict("SL1","L1_VLRTOT",16))
	ElseIf nTipo == 8				// Apos Fechar o Cupom
		// "OBRIGADO." ### "VOLTE SEMPRE!"
		cRet := PadC("OBRIGADO.",20) + Chr(10) + PadC("VOLTE SEMPRE!",20)
	EndIf
EndIf

If Len(cRet) > 0
	oImpBWECF:DisplayEnv(oImpBWECF:StatDisplay(), '0C'+cRet)
EndIf

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCHOpen
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCHOpen( cModelo, cPort )
Local nRet := -1
Default cModelo 		:= ""
Default cPort  		:= ""



STFMessage("STWCHOpen", "RUN", " Aguarde a abertura da Impressora de Cheques  " + cModelo + " na porta " + cPort ,{||  nRet := oImpBWECF:CHOpen( cModelo, cPort ) })
STFShowMessage("STWCHOpen")



Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCHSatus
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCHSatus( cType, cBuffer )

Default cType 			:= ""
Default cBuffer  		:= ""

oImpBWECF:CHSatus( cType, @cBuffer )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCHPrints
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCHPrints( cBanco, cValor, cFavorec,cCidade,;
					  cData, cMensagem, cVerso,cExtenso,;
					  cChancela )

Local cRet		:= Space(1)									// Retorno do status da impressora
Local aDadosUsu	:= {}										// Armazena os dados do usuario
Local cUsu		:= cUserName								// Recebe dados do usuario
Local nAno		:= 4										// Recebe a qtde de digitos de anos do usuario
Local cMoedaS	:= SuperGetMV( "MV_MOEDA1", ,"REAL" )
Local cMoedaP	:= SuperGetMV( "MV_MOEDAP1", ,"REAIS" )
Local cDataOrig	:= cData
Local nRet		:= 0

Default cBanco			:= ""
Default cValor			:= ""
Default cFavorec		:= ""
Default cCidade			:= ""
Default cData			:= ""
Default cMensagem		:= ""
Default cVerso			:= ""
Default cExtenso		:= ""
Default cChancela		:= ""

	nRet := oImpBWECF:ChStatus( '01', @cRet )

	 If STFGetCfg("lImpExtChq") .OR. (nRet == 0)
	 	  cExtenso:=Extenso(Val(cValue),.F.,,,,.T.,,)
	 EndIf

	// Busca dados do usuário para saber qtos digitos usa no ANO.
	 PswOrder(2)
	 If PswSeek( cUsu, .T. )
	   aDadosUsu := PswRet() // Retorna vetor com informações do usuário
	   nAno:= aDadosUsu[1][18]
	 EndIf

	 If nAno == 2
	 	cData := SubStr(cData,3,6)
	 EndIf


	oImpBWECF:CHPrints( cBanco, cValor, cFavorec,cCidade,;
					  cData, cMensagem, cVerso,cExtenso,;
					  cChancela, cMoedaP, cMoedaS, cDataOrig )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWChTransPrin
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWChTransPrin( cBanco, cValor, cCidade,cData,;
					     cAgencia, cConta, cMensagem )
Local cRet 		:= Space( 1 )					// Retorno do status da impressora de cheque
Local aDadosUsu := {}							// Armazena os dados do usuario
Local cUsu 		:= cUserName					// Recebe dados do usuario
Local nAno 		:= 4 							// Recebe a qtde de digitos de anos do usuario
Local nRet		:= 0

Default cBanco			:= ""
Default cValor			:= ""
Default cCidade			:= ""
Default cData			:= ""
Default cAgencia		:= ""
Default cConta			:= ""
Default cMensagem		:= ""


	nRet := oImpBWECF:CHStatus( "01", @cRet )


	//Busca dados do usuário para saber qtos digitos usa no ANO.
	PswOrder( 2 )

	If PswSeek( cUsu, .T. )

		//³etorna vetor com informacoes do usuario
		aDadosUsu 	:= PswRet()
		nAno		:= aDadosUsu[1][18]
	Endif

	If nAno == 2
		cData := SubStr( cData, 3, 6 )
	Endif



	oImpBWECF:ChPrinTrans( cBanco, cValor, cCidade,cData,;
					     cAgencia, cConta, cMensagem )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCHClose
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCHClose( cPort )

Default cPort		:= ""

oImpBWECF:CHClose( cPort )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCHList
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCHList( cBuffer, lMostraMsg )

Default cBuffer		:= ""
Default lMostraMsg		:= .F.

	oImpBWECF:CHList( @cBuffer, lMostraMsg )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDLLVersionControl
Function
@param1   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	cRet - Retorno do ECF
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDLLVersionControl( lAutocom, lTotvsApi)

Local cRet          := ""

Default	lAutocom	:= .F.
Default lTotvsapi	:= .F.

cRet := oImpBWECF:DLLVersionControl( lAutocom, lTotvsApi)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDrawerMoneyOpen
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDrawerMoneyOpen(cSaida, cPorta)

Default cSaida 		:= "C"
Default cPorta		:= ""

If cSaida == "N"
	cPorta	:=SuperGetMV("MV_PORTNOT")
ElseIf cSaida == "O"
	cPorta	:=SuperGetMV("MV_PORTORC")
ElseIf cSaida == "C"
	cPorta	:=STFGetStat("PORTICP")
Endif


oImpBWECF:DrawerMoneyOpen(cSaida, cPorta)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} STWSelectCountryDevice
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWSelectCountryDevice( cBuffer, lEcf )

Default cBuffer := ""
Default lEcf	:= .F.

	oImpBWECF:SelectCountryDevice( @cBuffer, lEcf )

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} STWExecDLLRet
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWExecDLLRet( nHnd, nMethod, cBuffer )

Local nRet 		:= -1

Default nHnd	:= oImpBWECF:GetHandle()
Default nMethod	:= 0
Default cBuffer	:= ""

nRet := oImpBWECF:ExecDLLRet( nHnd, nMethod, @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCodSitef
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	cTemp - codigo sitef
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCodSitef( cBuffer )

Local cTemp 	:= ""

Default cBuffer := ""

cTemp := oImpBWECF:CodSitef( @cBuffer )

Return cTemp


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDescSitef
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	cTemp - descricao
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDescSitef( cBuffer )

Local cTemp 	:= ""
Default cBuffer := ""

cTemp := oImpBWECF:DescSitef( @cBuffer )

Return cTemp


//-------------------------------------------------------------------
/*/{Protheus.doc} STWLjStr2Array
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	aReturn - Informacoes emulado
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWLjStr2Array( cString )

Local aReturn := { }
Local cDelimit := ""

Default cString		:= ""

If STFGetCfg("lEcfArg") .AND. AllTrim(STFGetStat("LG_IMPFISC")) == "ECF EMULATOR"
	cDelimit := "|"
Else
	cDelimit := CHR(28)
EndIf

Default cString := ""

aReturn := oImpBWECF:LjStr2Array( cString, cDelimit )

Return aReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPerceptArg
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPerceptArg( cAliqIVA, cTexto, cValor, aRet)

Local nRet 			:= -1
Local cDelimit 		:= ""

Default cAliqIVA		:= ""
Default cTexto			:= ""
Default cValor	   		:= ""
Default aRet			:= {}

If STFGetCfg("lEcfArg") .AND. AllTrim(STFGetStat("LG_IMPFISC")) == "ECF EMULATOR"
	cDelimit := "|"
Else
	cDelimit := CHR(28)
EndIf

Default cAliqIVA    := ""
Default cTexto      := ""
Default cValor      := ""
Default	aRet        := {}

nRet := oImpBWECF:PerceptArg( cAliqIVA, cTexto, cValor, aRet, cDelimit)

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenDNFH
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenDNFH( cTypeDoc, cCliente, cCabec,cDocOrigem,;
					  aRet, cTypeImp, cIdDoc 				)

Local nRet	 := -1
Local cDelimit := ""

Default cTypeDoc			:= ""
Default cCliente			:= ""
Default cCabec				:= ""
Default cDocOrigem			:= ""
Default aRet				:= {}
Default cTypeImp			:= ""
Default cIdDoc				:= ""


If STFGetCfg("lEcfArg") .AND. AllTrim(STFGetStat("LG_IMPFISC")) == "ECF EMULATOR"
	cDelimit := "|"
Else
	cDelimit := CHR(28)
EndIf

Default cTypeDoc    := ""
Default cCliente    := ""
Default cCabec      := ""
Default cDocOrigem  := ""
Default aRet        := {}
Default cTypeImp    := ""
Default cIdDoc      := ""


	nRet := oImpBWECF:OpenDNFH( cTypeDoc, cCliente, cCabec,cDocOrigem,;
							     @aRet, cTypeImp, cIdDoc,	cDelimit )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCloseDNFH
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCloseDNFH( aRet)

Local nRet 	   		:= -1
Local cDelimit 		:= ""

Default aRet        := {}


If STFGetCfg("lEcfArg") .AND. AllTrim(STFGetStat("LG_IMPFISC")) == "ECF EMULATOR"
	cDelimit := "|"
Else
	cDelimit := CHR(28)
EndIf

Default aRet	:= {}

	nRet := oImpBWECF:CloseDNFH( @aRet, cDelimit)

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReprintsLastDocArg
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReprintsLastDocArg()

Local nRet 		:= -1

nRet := oImpBWECF:ReprintsLastDocArg()

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrintLinesReceiptsArg
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPrintLinesReceiptsArg(cTexto, aRet)

Local nRet		:= -1
Local cDelimit := ""

Default cTexto        := ""
Default aRet        := {}


If STFGetCfg("lEcfArg") .AND. AllTrim(STFGetStat("LG_IMPFISC")) == "ECF EMULATOR"
	cDelimit := "|"
Else
	cDelimit := CHR(28)
EndIf

Default cTexto  := ""
Default aRet    := {}

nRet := oImpBWECF:Receipts( cTexto, @aRet, cDelimit)

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWIFMemWork
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWIFMemWork( aRet)

Local nRet 		:= -1
Local cDelimit := ""

Default aRet        := {}


If STFGetCfg("lEcfArg") .AND. AllTrim(STFGetStat("LG_IMPFISC")) == "ECF EMULATOR"
	cDelimit := "|"
Else
	cDelimit := CHR(28)
EndIf

Default aRet    := {}

nRet := oImpBWECF:IFMemWork( @aRet, cDelimit)

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWCapacityArg
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCapacityArg( aRet)

Local nRet 		:= -1
Local cDelimit := ""

Default aRet    := {}


If STFGetCfg("lEcfArg") .AND. AllTrim(STFGetStat("LG_IMPFISC")) == "ECF EMULATOR"
	cDelimit := "|"
Else
	cDelimit := CHR(28)
EndIf

	nRet := oImpBWECF:CapacityArg( aRet, cDelimit)

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenDebitNote
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWOpenDebitNote( cBuffer )

Local nRet 		:= -1
Default cBuffer := ""

	nRet := oImpBWECF:OpenDebitNote( @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRestauOpenReceipt
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRestauOpenReceipt( cMesa, cCliente )

Local nRet 			:= -1

Default cMesa   	:= ""
Default cCliente	:= ""

	nRet := oImpBWECF:RestauOpenReceipt( cMesa, cCliente )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRestauRegIt
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRestauRegIt( cMesa, cCodigo, cDescricao,cAliquota,;
						 cQtde, cVlrUnit, cAcres,cDesc)

Local nRet 			:= -1

Default cMesa       := ""
Default cCodigo     := ""
Default cDescricao  := ""
Default cAliquota   := ""
Default cQtde       := ""
Default cVlrUnit    := ""
Default cAcres      := ""
Default cDesc	    := ""

	nRet := oImpBWECF:RestauRegIt( cMesa, cCodigo, cDescricao,cAliquota,;
						 			cQtde, cVlrUnit, cAcres,cDesc)

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRestauCancIt
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRestauCancIt( cMesa, cCodigo, cDescricao,cAliquota,;
						  cQtde, cVlrUnit, cAcres,cDesc )

Local nRet 			:= -1

Default cMesa       := ""
Default cCodigo     := ""
Default cDescricao  := ""
Default cAliquota   := ""
Default cQtde       := ""
Default cVlrUnit    := ""
Default cAcres      := ""
Default cDesc	    := ""

	nRet := oImpBWECF:RestauCancIt( cMesa, cCodigo, cDescricao,cAliquota,;
						  			cQtde, cVlrUnit, cAcres,cDesc )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWConfMRestau
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWConfMRestau(cMesa, cAcres, cDesc )

Local nRet 		:= -1

Default cMesa   := ""
Default cAcres  := ""
Default cDesc   := ""

	nRet := oImpBWECF:RestauConfM( cMesa, cAcres, cDesc )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRestauPrintCdp
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRestauPrintCdp()
Local nRet 		:= -1

	nRet := oImpBWECF:RestauPrintCdp()

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRestauGetCdp
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRestauGetCdp()

Local nRet 		:= -1

	nRet := oImpBWECF:RestauGetCdp()

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGetTableRestau
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWGetTableRestau( cBuffer )

Local nRet 		:= -1

Default cBuffer := ""

	nRet := oImpBWECF:RestauGetTable( @cBuffer )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRepMontRestau
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRepMontRestau( cType )

Local nRet 		:= -1

Default cType	:= ""

	nRet := oImpBWECF:RestauRepMont( cType )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRestauLeRegSal
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRestauLeRegSal( cMesa )

Local nRet 		:= -1

Default cMesa	:= ""

	nRet := oImpBWECF:RestauLeRegSal( cMesa )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWReceiptRestauClose
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWReceiptRestauClose( cPagamento, cAcres, cDesc,cMensagem )

Local nRet 			:= -1

Default cPagamento  := ""
Default cAcres      := ""
Default cDesc       := ""
Default cMensagem   := ""

	nRet := oImpBWECF:RestauCloseReceipt( cPagamento ,cAcres ,cDesc ,cMensagem )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRestauFCDiv
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRestauFCDiv( cNumeroCupons, cAcres, cDesc,cPagamento,;
						 cValorCliente, cCliente)

Local 	nRet 			:= -1

Default cNumeroCupons   := ""
Default cAcres          := ""
Default cDesc           := ""
Default cPagamento      := ""
Default cValorCliente   := ""
Default cCliente        := ""

	nRet := oImpBWECF:RestauFCDiv( cNumeroCupons, cAcres, cDesc,cPagamento,;
						   			cValorCliente, cCliente )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRestauTrfTable
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRestauTrfTable( cOrigem, cDestino )

Local nRet			:= -1

Default cOrigem 	:= ""
Default cDestino	:= ""

nRet := oImpBWECF:RestauTrfMesa( cOrigem, cDestino )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWTrfItemRestau
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWTrfItemRestau( cOrigem, cCodigo, cDescricao,cAliquota,;
						   cQtde   , cVlrUnit, cAcres,cDesc,;
						   cDestino )
Local	nRet		:= -1

Default cOrigem     := ""
Default cCodigo     := ""
Default cDescricao  := ""
Default cAliquota   := ""
Default cQtde       := ""
Default cVlrUnit    := ""
Default cAcres      := ""
Default cDesc       := ""
Default cDestino	:= ""

nRet := oImpBWECF:RestauTrfItem( cOrigem, cCodigo, cDescricao,cAliquota,;
										cQtde   , cVlrUnit, cAcres,cDesc,;
						   				cDestino )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGerRegTypE
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWGerRegTypE( cType, cInicio, cFinal, cBinario )

Local nRet 		:= -1

Default cType   := ""
Default cInicio := ""
Default cFinal  := "" 
Default cBinario := "0"

	nRet := oImpBWECF:GerRegTypE( cType, cInicio, cFinal, cBinario )

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWMsgDll
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWMsgDll( cDllVer, nTipoMsg)

Local oDlgDll
Local oFntMsg
Local oFntTit

// variaveis para o texto de detalhe
Local oMsgDet
Local cMsgDet := ''
Local oBmp
Local lTelaDetalhe :=.F.
Local cAviso := ""

Default cDllVer 	:= ""
Default nTipoMsg  	:= 0

If nTipoMsg == 1
	// "Existe incompatibilidades entre a versão do Repositório Protheus e a DLL Fiscal."
	// "Por favor, atualize a DLL Fiscal."
	cAviso := "Existe incompatibilidades entre a versão do Repositório Protheus e a DLL Fiscal."+Chr(10)+;
			  "Por favor, atualize a DLL Fiscal."+CHR(10)+cDllVer+CHR(10)
ElseIf nTipoMsg == 2
	// "Existe incompatibilidades entre a versão do Repositório Protheus e a DLL Fiscal."
	// "Por favor, atualize o Repositório Protheus."
	cAviso := "Existe incompatibilidades entre a versão do Repositório Protheus e a DLL Fiscal."+Chr(10)+;
			  "Por favor, atualize o Repositório Protheus."+CHR(10)+cDllVer+CHR(10)
Endif

cMsgDet := "O ID da DLL é composto da seguinte forma: " + Chr(10) //"O ID da DLL é composto da seguinte forma: "
cMsgDet += "x.yy.ww.zz, onde: " + Chr(10) //"x.yy.ww.zz, onde: "
cMsgDet += "x - Sempre 0 (zero). Número exigido pelo Delphi." + Chr(10) //"x - Sempre 0 (zero). Número exigido pelo Delphi."
cMsgDet += "Não é possível efetuar o controle sem essa primeira parte da numeração. " + Chr(10) //"Não é possível efetuar o controle sem essa primeira parte da numeração. "
cMsgDet += "yy - Alterações sofridas na estrutura da função desde sua concepção. " + Chr(10) //"yy - Alterações sofridas na estrutura da função desde sua concepção. "
cMsgDet += "ww - Número de equipamentos homologados. " + Chr(10) //"ww - Número de equipamentos homologados. "
cMsgDet += "zz - Número do ID. Identificador que permite compatibilização das funções do RPO com as contidas na DLL. "+ Chr(10) //"zz - Número do ID. Identificador que permite compatibilização das funções do RPO com as contidas na DLL."
cMsgDet += "A verificação do ID será efetuada ao entrar no sistema, e se os números forem incompatíveis o acesso será negado." + Chr(10) //"A verificação do ID será efetuada ao entrar no sistema, e se os números forem incompatíveis o acesso será negado."
cMsgDet += "A validação do ID será efetuada desconsiderando o número de equipamentos homologados," + Chr(10) //"A validação do ID será efetuada desconsiderando o número de equipamentos homologados,"
cMsgDet += "assim, quando o protheus estiver utilizando o ID 0.2.40.10 poderá ser utilizada a " + cDLLSIGALOJA + " com identificação 0.2.??.10." + Chr(10) //"assim, quando o protheus estiver utilizando o ID 0.2.40.10 poderá ser utilizada a SIGALOJA.DLL com identificação 0.2.??.10."

DEFINE MSDIALOG oDlgDll TITLE OemtoAnsi("Atenção") FROM 0,0 TO 130,600 PIXEL
DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15

@ 0,0  BITMAP oBmp RESNAME "LOGIN" oF oDlgDll SIZE 100,600 NOBORDER WHEN .F. PIXEL
@05,50 TO 45,300 PROMPT OemtoAnsi("AJUDA") PIXEL   //"AJUDA"
@10,52 SAY OemtoAnsi(cAviso) PIXEL SIZE 240,200 FONT oFntMsg

@50,200 BUTTON "Ok" PIXEL ACTION oDlgDll:End() //"Ok"
@50,230 BUTTON "Detalhes" PIXEL ACTION If(!lTelaDetalhe,; //"Detalhes"
		(oDlgDll:ReadClientCoors(.T.),oDlgDll:Move(oDlgDll:nTop,oDlgDll:nLeft,oDlgDll:nWidth,oDlgDll:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
		(oDlgDll:ReadClientCoors(.T.),oDlgDll:Move(oDlgDll:nTop,oDlgDll:nLeft,oDlgDll:nWidth,oDlgDll:nHeight-165,,.T.),lTelaDetalhe:=.F.))

@ 67,50 TO 140,300 PROMPT OemtoAnsi("Informações da " + cDLLSIGALOJA) PIXEL
@ 73,52 GET oMsgDet VAR cMsgDet FONT oFntMsg MEMO size 245,65  PIXEL

ACTIVATE MSDIALOG oDlgDll CENTERED

Return Nil



//-------------------------------------------------------------------
/*/{Protheus.doc} STWLjStrToArr
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	aRet - Informações do ECf
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWLjStrToArr ( cLista)

Local aRet		:= {}

Default cLista 	:= ""

	aRet := oImpBWECF:LjStrToArr( cLista)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWLjArrToStr
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	cRet - Retorno
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWLjArrToStr(aLista)

Local cRet := ""

Default aLista 	:= {}

	cRet := oImpBWECF:LjArrToStr( aLista)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWJoinList
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	cRet - Retorno
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWJoinList( cBuffer1, cBuffer2, lEcf)

Local 	cRet		:= ""

Default cBuffer1	:= ""
Default cBuffer2    := ""
Default lEcf	    := .T.

   cRet := oImpBWECF:JoinList( @cBuffer1, @cBuffer2, lEcf)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkAutocom
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function ChkAutocom()

Local  nChkAutocom := 1

If GetRemoteType() == REMOTE_LINUX	   				// Caso a plataforma seja LINUX, somente a AUTOCOM esta homologada
	nChkAutocom := DLL_AUTOCOM
EndIf


Return nChkAutocom


//-------------------------------------------------------------------
/*/{Protheus.doc} STWChkAutocom
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWChkAutocom()
	oImpBWECF:ChkAutocom()
Return  Nil



//-------------------------------------------------------------------
/*/{Protheus.doc}STWIsAutocom
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWIsAutocom( nTipo, cModelo)

Default nTipo		:= 0
Default cModelo		:= ""

	oImpBWECF:IsAutocom( nTipo, cModelo)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWChkDataMov
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWChkDataMov()
Local dUltMov		:= dDatabase	// Armazena o ultimo movimento
Local cFim			:= ""         	// Data final da LMF
Local cIni			:= ""  		  	// Data Inicial da LMF
Local lRet			:= .F. 			// Retorno da Method
Local lSai			:= .F.			// Controla de sai do while
Local lLjNfPafEcf	:= STBIsPaf()
Local aArea			:= GetArea()
Local aAreaSL1 		:= SL1->(GetArea())
local lEnvEstBlX	:=	SuperGetMV("MV_ESTABLX",, .T.)  // parametro para definir se deve envia ou não o arquivo de estoque anual do bloco X. .T. valor default, ou seja, default é enviar.
Local lGerouEstq 	:= .F. 
Local dUltMovSL1	:=  DtoC(CtoD( '' ))




//O SL1 ainda será gravado no Banco de Dados
DbSelectArea( "SL1" )
SL1->(DbSetOrder( 7 ))
SL1->(DBSeek(xFilial() + DToS( CToD( "31/12/2999" ) ), .T.)) // Para posicionar no ultimo registro
SL1->(DbSkip( -1 ))

If DtoC( SL1->L1_EMISSAO ) == DtoC(CtoD( '' ))
	dUltMov := dDatabase
Else
	dUltMov := SL1->L1_EMISSAO
	dUltMovSL1	:= SL1->L1_EMISSAO
Endif

If LJAnalisaLeg(21)[1] .OR. lLjNfPafEcf
	While !lSai
		lSai := .F.
		// Ignora se o mes for igual, significa que nao e' a primeira do mes
 		If SubStr( DToS( dUltMov ),5, 2 ) = SubStr( DToS( dDatabase ), 5, 2 )
			If dUltMov < dDatabase // Se estiver no msm mes e com a data menor tem q sair pois nao e' a primeira
				If DBSeek( xFilial( "SL1" ) + DToS( dUltMov ) )
					lSai := .T.
				Endif
			Endif
		Endif

		// Se o mes e' menor imprime a LMF
		If SubStr( DToS( dUltMov ),5, 2 ) < SubStr( DToS( dDatabase ), 5, 2 )
		    lRet := .T.
		Endif

	    If !lRet
	    	dUltMov -= 1
	    Else
	    	cFim := SubStr( DToS( LastDay( dUltMov ) ), 7, 2 )
	    	cFim := cFim + "/" + SubStr( DToS( dUltMov ), 5, 2 ) + "/" + SubStr( DToS( dUltMov ), 3, 2 )
	    	cIni := "01/" + SubStr( DToS( dUltMov ), 5, 2 ) + "/" + SubStr( DToS( dUltMov ), 3, 2 )

			STWMemFisc( cIni , cFim, " ", " ", IIF(lLjNfPafEcf , "IC", "I" ) )

			If lLjNfPafEcf
				STFMessage("STWChkDataMov1", "RUN", "Aguardando Impressão...", { || Sleep(10000)})
				STFShowMessage("STWChkDataMov1")

				If !(AllTrim(SM0->M0_ESTCOB) == "SC") // Em Santa Catarina não aceita o Requisito XII - Ato ER 02.05
					StbReqXIIZ(.F.,cIni,cFim) //Requisito XII
				EndIf
				
				
			EndIf

			lSai := .T.
		Endif

		If lSai
			lRet := .F.
		Endif

		//ARQUIVO DE ESTOQUE ANUAL SERÁ GERADO NA REDUÇÃO Z DO PRIMEIRO MOVIMENTO DE JANEIRO
		If lEnvEstBlX .AND. !lGerouEstq .AND. STBPEnvXML() ;
		.AND. SubStr( DToS( dUltMovSL1 ),5, 2 ) == "12" .AND. SubStr( DToS( dDatabase ),5, 2 ) == "01";
		.AND. dDatabase > dUltMovSL1
			LPXFiscoEstMen(.F.,.F.,LastDay(dUltMovSL1,0),,dDatabase)
			LPXVlEnvFi( .F.,.T.,"E",.T.,,.F.)
			lGerouEstq:=.T. 
		EndIf

	End

	
Endif

RestArea(aAreaSL1)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}EcfIFDate
Verifica se a data do movimento da impressora, eh a mesma
data do sistema
@param   	lExp1 -> Se utiliza a Função STWCheckHour() no LOJA701D
@param   	lExp2 -> Se executa  a Função STWCheckHour()
@param   	lExp3 -> Se a origem e de impressao de ECF
@param   	lExp4 -> Se utiliza o ponto de entrada no LojxFunC
@param   	lExp5 -> Data de retorno a ser utilizada no LojxFunC
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	lRet -> Comando da impressora
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWEcfIFDate( lFunImp, lVerHora, lFunVenda, lAtualiz,;
						 cRetData )

Local nRet	   		:= 0					// Retorno da verificao do ECF
Local lRet     		:= .T.					// Retorno da Method
Local cRetorno 		:= ""					// Data de retorno do ECF

Default lFunImp 	:= .F.					// Se precisa utilizar  a Função STWCheckHour() dentro da Method ou no retorno()
Default lVerHora	:= .F.					// Se vai chamar  a Função STWCheckHour()
Default lFunVenda	:= .F.					// Verifica se a origem eh de Method de impressao
Default lAtualiz	:= .T.					// Variavel utilizada para retornar se chama Ponto de Entrada na LojxFunc
Default cRetData	:= ""					// Retorno da Data para ser utilizado no LojxFunc desde que o lAtualiz retorne .T.

If STWIsTaxPrinter()

	//No comando 19 da DLL, se retorna 0, eh porque
	//nao foi realizada a reducao z do dia anterior
	If nRet == 0
        If CtoD(cRetorno) <> dDataBase .AND. (cRetorno == "  /  /  "  .OR. cRetorno <> "000000")
			//MsgAlert("A database do sistema sera atualizada com o movimento do dia : " + cRetorno)
			STFMessage("STWEcfIFDate", "OK","A database do sistema sera atualizada com o movimento do dia : " + cRetorno)
			STFShowMessage( "STWEcfIFDate")

			dDataBase := CtoD(cRetorno)
			If lFunVenda
				cRetData := cRetorno
			EndIf
		ElseIf lFunVenda
			lAtualiz := .F.
		EndIf

		//No comando 19 da DLL, se retorna 2, eh porque
		//foi realizada a reducao z, portanto, a database
		//assume a data da impresso
			
		ElseIf nRet == 2
			If dDataBase <> CtoD(cRetorno) .AND. (cRetorno == "  /  /  "  .OR. cRetorno <> "000000")
				STFMessage("STWEcfIFDate", "ALERT","A database do sistema sera atualizada com a data corrente : " + cRetorno)
				STFShowMessage( "STWEcfIFDate")
				dDataBase := CtoD(cRetorno)
				If lFunVenda
					cRetData := cRetorno
				EndIf
			ElseIf lFunVenda
				lAtualiz := .F.
			EndIf


	ElseIf nRet < 0
			If lFunVenda
				STFMessage("STWEcfIFDate", "STOP","Erro com a Impressora Fiscal. Operação não efetuada.")
				STFShowMessage( "STWEcfIFDate")

				lRet := .F.
			EndIf
	Else

		//As impressoras que utilizam o comando 19 sao a
		//Bematech e Sweda. Caso as outras impressoras nao
		//tenham o comando 19, entao executa o comando 2
		//(como antes).
		If !lVerHora
			If lFunVenda
				nRet := STWPrinterStatus( '2', @cRetorno )
				If nRet == 0
					If CtoD(cRetorno) <> dDataBase
						cRetData  := cRetorno
					Else
						lAtualiz := .F.
					EndIf
				EndIf
			EndIf
		Else
			lVerHora:= oImpBWECF:CheckIfDate()
			lFunImp := .T.
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWDispTorList
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDispTorList( cBuffer )

Default cBuffer		:= ""

	oImpBWECF:DispTorList( @cBuffer )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpeDispTor
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWOpeDispTor( cModelo, cPort )

Default cModelo		:= ""
Default cPort		:= ""

	oImpBWECF:DispTorOpe( cModelo, cPort )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDispTorClos
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWClosDispTor( nDisTHnd, cPort )

Default nDisTHnd		:= ""
Default cPort		:= ""

	oImpBWECF:DispTorClos( nDisTHnd, cPort )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWTorEnvDisp
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWTorEnvDisp( nDisTHnd, cTexto )

Default nDisTHnd		:= ""
Default cTexto	   		:= ""

	oImpBWECF:DispTorEnv( nDisTHnd, cTexto )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc}STWTorMsgDisp
Mensagem padrao para exibicao no display torre
@param   	ExpN1 - Tipo da mensagem a ser enviada
@param   	ExpA1 - Array com os parametros do Ponto de Entrada
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	Nil
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWTorMsgDisp( nTipo, aPARAMIXB)

// Variavel utilizada para armazenagem do texto
// que sera apresentado no display do leitor
Local cMsg := ""
Local cAux

Default nTipo				:= ""
Default aPARAMIXB	   		:= {}

If oImpBWECF:DispTorStat() <> -1
	If ExistBlock("MSGDISPLAY")
		cMsg := ExecBlock("MSGDISPLAY",.F.,.F.,{nTipo,aPARAMIXB})
		If ValType(cMsg) <> "C"
			cMsg := ""
		EndIf
	Else
		// Apos Abrir o Display
		If nTipo == 1
			cMsg := "AP FRONT LOJA"													// "AP FRONT LOJA"
		ElseIf nTipo == 2 // Antes de Fechar o Display
			cMsg := PadR("AP FRONT LOJA",16) + PadL("TERMINO NORMAL",16)			// "AP FRONT LOJA" ### "TERMINO NORMAL"
		ElseIf nTipo == 3 // Apos Abrir o Caixa
			cMsg := PadC("CAIXA",16) + PadC("DISPONIVEL",16)			// "CAIXA" ### "DISPONIVEL"
		ElseIf nTipo == 4 // Apos Fechar o Caixa
			STWDispTorEnv(oImpBWECF:DispTorStat(), "CAIXA" + ' ' + "FECHADO"  )	    	// "CAIXA" ### "FECHADO"
			STWDispTorEnv(oImpBWECF:DispTorStat(), " "  )
			cMsg := PadC("CAIXA",16) + PadC("FECHADO",16)			// "CAIXA" ### "FECHADO"
		ElseIf nTipo == 5 // Apos Registrar o Item
			cAux := AllTrim(Transform(aPARAMIXB[4],PesqPictQt("L2_QUANT",7)))
			cMsg := Left(aPARAMIXB[3],16) + ;
					cAux + PadL(SuperGetMv("MV_SIMB1") + " " +;
					AllTrim(Transform(aPARAMIXB[4]*aPARAMIXB[5],PesqPict("SL1","L1_VLRTOT",12))), 16-Len(cAux))
		ElseIf nTipo == 6 // Quando Teclar SubTotal (F9)
			cMsg := "SUB-TOTAL:" + SuperGetMv("MV_SIMB1") + Transform(aPARAMIXB[1],PesqPict("SL1","L1_VLRTOT",16))  			// "SUB-TOTAL:"
		ElseIf nTipo == 7 // Quando Houver Troco
			cMsg := "TROCO:" + SuperGetMv("MV_SIMB1") + Transform(aPARAMIXB[1],PesqPict("SL1","L1_VLRTOT",16))			// "TROCO:"
		ElseIf nTipo == 8 // Apos Fechar o Cupom
			cMsg := PadC("OBRIGADO.",16) + PadC("VOLTE SEMPRE!",16)			// "OBRIGADO." ### "VOLTE SEMPRE!"
		EndIf
	EndIf
	If Len(cMsg) > 0
		cMsg := StrTran( cMsg, ',', '.' )
		STWDispTorEnv(oImpBWECF:DispTorStat(), cMsg)
	EndIf
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} STWEcfIFCNPJ
Function
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
/*/
//-------------------------------------------------------------------
Function STWEcfIFCNPJ()
Local nRet	   		:= 0					// Retorno da verificao do ECF
Local lRet     		:= .F.					// Retorno da Method
Local cRetorno 		:= ""					// Data de retorno do ECF

If STWIsTaxPrinter()
	nRet := STWPrinterStatus( '20', @cRetorno )

	//No comando 20 da DLL, se retorna 0, eh porque
	//existe a Method de retornar o CNPJ na impressora
	If nRet == 0

		//Se o Val do cRetorno for igual a zero, significa que a impressora
		//esta em modo de Treinamento. Desta forma, prossegue com a operação
		If Val(cRetorno) <> 0

			cRetorno := StrTran( cRetorno, ".", "" )
			cRetorno := StrTran( cRetorno, "/", "" )
			cRetorno := StrTran( cRetorno, "-", "" )
			cRetorno := Alltrim(cRetorno)

			If cRetorno <> RTRIM(SM0->M0_CGC)
				//"CNPJ cadastrado na impressora não é o mesmo do arquivo de empresas. Favor entrar em contato com o Administrador do sistema"
			   	STFMessage("STWEcfIFCNPJ", "STOPPOPUP","CNPJ cadastrado na impressora não é o mesmo do arquivo de empresas. Favor entrar em contato com o Administrador do sistema" + CHR(13) + ;
			   												 "CNPJ Arquivo de Empresa(M0_CGC):" + RTRIM(SM0->M0_CGC) + CHR(13) + ;
			   												 "CNPJ Impressora:" + cRetorno ) 
			    STFShowMessage("STWEcfIFCNPJ")
			   //	MsgStop("CNPJ cadastrado na impressora não é o mesmo do arquivo de empresas. Favor entrar em contato com o Administrador do sistema")

			Else
				lRet := .T.
			EndIf
		Else
			lRet := .T.
		EndIf

	//Se for -1, significa erro no comando 20 do StatusImp
	ElseIf nRet < 0
		//"Erro com a Impressora Fiscal. Operação não efetuada.","Atenção"
		STFMessage("STWEcfIFCNPJ", "ALERT", "Erro com a Impressora Fiscal. Operação não efetuada.","Atenção")
		STFShowMessage("STWEcfIFCNPJ")
		//MsgAlert("Erro com a Impressora Fiscal. Operação não efetuada.","Atenção")

	//Caso contrario (retorno 1), significa que a impressora utilizada nao tem
	//ou nao esta preparada para retornar o CNPJ
	Else
		lRet := .T.
	EndIf
ElseIf STbIsPaf() .AND. !LjxBGetPaf()[2]
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}STWLjPrintlCOO
Fecha comunicacao com a Balanca
@param   	EXPn1 - Retorno nRet
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPc1 - Retorna Caracter
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWLjPrintlCOO( nRet)

Local cRetorno		:= " "		// Verifica se eh ECF ou Emulator
Local cNumCupFis	:= ""		// Numero do COO
Local cRetCoo       := ""      // Retorno Utilizado para Numeração da Australia.
Local aStruCampo 	:= {}		//Array com a estrutura do campo na Cesta

Default nRet				:= 0

/*/
	Verifica se esta sendo utilizado um Emulador ou um ECF
	Se for um emulador pega o numero da nota do SLG - Cadastro
	de estacoes.
	Para utilizar uma impressora Emulando um ECF devera ser
	utilizado uma estacao para cada caixa. Se a Loja tiver 5
	caixas, o SLG devera conter 5 estacoes diferentes.
/*/

If oImpBWECF:PrinterStatus('11', @cRetorno) == 0
	xNumCaixa()
	If SLG->(DBSeek(xFilial("SLG") + cEstacao))
		cNumCupFis := StrZero(Val(SLG->LG_COO), TamSx3("LG_COO")[1],0)
		RecLock("SLG", .F.)
		SLG->LG_COO := StrZero(Val(cNumCupFis) + 1, TamSx3("LG_COO")[1], 0)
		MsUnlock("SLG")
	    cRetCoo := SLG->LG_COO
	Else
		aStruCampo := STDGetProperty("L1_NUMCFIS")
		cNumCupFis := StrZero(0, TamSx3("L1_NUMCFIS")[1], 0)
	Endif
	nRet := oImpBWECF:EmulEcf(cEstacao, SA6->A6_COD, SA6->A6_NOME, cNumCupFis)
EndIf

Return cRetCoo


//-------------------------------------------------------------------
/*/{Protheus.doc} STWLjEcfTamCup
Function
@param   	Nil
@author     Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWLjEcfTamCup()
oImpBWECF:LjEcfTamCup()
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWExistEquip
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWExistEquip( nTipo, cModelo, lComOk, lAbreCom)

Default nTipo		:= 0
Default cModelo		:= ""
Default lComOk		:= .T.
Default lAbreCom		:= .T.

Return oImpBWECF:ExistEquip( nTipo, cModelo, @lComOk, lAbreCom)

//-------------------------------------------------------------------
/*/{Protheus.doc} STWTreatStatus
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWTreatStatus( oValor, cType, nRet)

Default oValor		:= Nil
Default cType		:= ""
Default nRet		:= 0

	oImpBWECF:TreatStatus( oValor, cType, @nRet)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWLoadForm
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWLoadForm( cDados)

Default cDados		:= ""

oImpBWECF:LoadForm( cDados)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWTratRedZ
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWTratRedZ( oDadosRedZ)

Default oDadosRedZ		:= Nil

oImpBWECF:TratRedZ( oDadosRedZ)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrepReport
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPrepReport( cDados, nVias)

Default cDados		:= ""
Default nVias		:= 0

	oImpBWECF:PrepReport( cDados, nVias)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWDscTotaliz
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDscTotaliz( cTotaliz)

Default cTotaliz		:= ""

	oImpBWECF:DscTotaliz( cTotaliz)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrepMsgPro
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPrepMsgPro( cDados)

Default cDados		:= ""

oImpBWECF:PrepMsgPro( cDados)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrepSupSan
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	oRetorno - Retorno
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWPrepSupSan( cDados, nVlrTotal)

Local oRetorno := oImpBWECF:PrepSupSan( cDados, nVlrTotal)

Default cDados	   		:= ""
Default nVlrTotal		:= 0

Return oRetorno




//-------------------------------------------------------------------
/*/{Protheus.doc} STWLjxReptMD5
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWLjxReptMD5()
	//oImpBWECF:LjxReptMD5()
	//TODO: PAF CRIAR FUNCAO NO STBECFMD5 - PAF - sera feito depois 2 fase
Return STBRETMD5()


//-------------------------------------------------------------------
/*/{Protheus.doc}STWTreatRet
 Trata as informacoes retornadas pelo ecf	todas ecfs
@param   	EXPn1 - Handle de uso da DLL
@param   	EXPc1 - Porta de comunicacao
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPn1 - Indica sucesso da execucao - 0 = OK / 1 = Nao OK
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWTreatRet(cType, cBuffer)

Local nRet 		:= 0					//Retorno da Method
Local aCAmpos   := {}
Local nTamCoo 	:= 0
Local nTamCnf 	:= 0
Local nTamCgr 	:= 0
Local nTamCdc 	:= 0

Default cType	:= ""	// verifica tipo de tratamento
Default cBuffer := "" 	// verifica conteudo a impressara.

Do Case
	//Retorna o Contador de Cupom Fiscal
	Case cType == "35"
		aCampos := STDGetProperty("L1_CONTDOC")
		If (nTamCoo := aCampos[5] ) = 0
			nTamCoo := SL1->(TamSx3("L1_CONTDOC"))
		EndIf

    	cBuffer := PadL(cBuffer, nTamCoo, "0")

	// Retorna o Contador Geral de Operação Não Fiscal
	Case cType == "36"
    	aCampos := STDGetProperty("L1_CONTONF")
		If (nTamCnf := aCampos[5] ) = 0
			nTamCnf := SL1->(TamSx3("L1_CONTONF")[1])
		EndIf
	
	    cBuffer := PadL(cBuffer, nTamCnf, "0")

    // Retorna o Contador Geral de Relatório Gerencial
	Case cType == "37"
		aCampos := STDGetProperty("L1_CONTRG")
		If (nTamCgr := aCampos[5] ) = 0
			nTamCgr := SL1->(TamSx3("L1_CONTRG")[1])
		EndIf

	    cBuffer := PadL(cBuffer, nTamCgr, "0")

	// Retorna o Contador de Comprovante de Debito ou Credito
	Case cType == "38"
		aCampos := STDGetProperty("L1_CONTCDC")
		If (nTamCdc := aCampos[5] ) = 0
			nTamCdc := SL1->(TamSx3("L1_CONTCDC")[1])
		EndIf
	
	    cBuffer := PadL(cBuffer, nTamCdc, "0")
EndCase

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWTreatMd5
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWTreatMd5()
//	oImpBWECF:TreatMd5()
// TODO: CRIAR FUNÇÃO DO STBECFMD5 PAF
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWMd5TreatRet
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWMd5TreatRet()
//	oImpBWECF:TreatRetMd5()
// TODO: CRIAR FUNÇÃO DO STBECFM PAF
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWVldEcfPtg
Function Indica que nao utilizara ECF em Portugal
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWVldEcfPtg(nRet)

Local lRet := .F. 				// Indica que nao utilizara ECF em Portugal

Default nRet		:= -1

nRet := -1

	If (lRet := (ExistFunc("LjNfPtgNEcf") .AND. LjNfPtgNEcf(SM0->M0_CGC)))
	nRet := 0
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWTrtStaPtg
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno dispositivo
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWTrtStaPtg(cStatus, cBuffer, lVenda)

Local nRet := 0 					// Contem o retorno da Method

Default cStatus		:= ""
Default cBuffer		:= ""
Default lVenda 		:= .T.

Do Case

	//  2 - Obtem a Data da Impressora
	Case cStatus == "2"
		cBuffer := DtoC(dDataBase)

	//  5 - Cupom Fechado ?
	Case cStatus == "5"
		// Posiciona no ultimo registro caso nao esteja entrando no atendimento
		If !lVenda //!IsInCallStack("FR271RESUME")
			SL1->(DbGoBottom())

		EndIf

		// Aberto
		If Empty(SL1->L1_DOC)
			nRet := 7
		Endif

	// 10 - Verifica se todos os itens foram impressos.
	Case cStatus == "10"
		nRet := 0

	// 12 - Verifica se o ECF possui as funcoes IFNumItem e IFSubTotal (1=Nao / 0=Sim)
	Case cStatus == "12"
		nRet := 1

	// 19 - Retorna a data do movimento da impressora
	Case cStatus == '19'
		cBuffer := DtoC(dDataBase)

End Case


Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWLjxPrintFisc
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWLjxPrintFisc()
	oImpBWECF:LjxPrintFisc()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpenPrintCommunication
Criada para abrir comunicação de Impressora Nao Fiscal
@param   	Modelo, caracter, modelo de Impressora Nao Fiscal
@param		cPort, caracter, porta de comunicação 
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Function STWOpenPrintCommunication(Modelo, cPort)
Local xRet := NIL

Default Modelo		:= Nil
Default cPort		:= ""

xRet := oImpBWECF:OpenPrintCommunication(Modelo, cPort)
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWClosePrintCommunication
Criada para fechar comunicação de Impressora Nao Fiscal
@param   	Modelo, caracter, modelo de Impressora Nao Fiscal
@param		cPort, caracter, porta de comunicação 
@author		julio.nery
@version 	P12
@since   	07/11/2019
@return  	Nil
/*/
//-------------------------------------------------------------------
Function STWClosePrintCommunication(Modelo, cPort)
Local xRet := NIL

Default Modelo		:= Nil
Default cPort		:= ""

xRet := oImpBWECF:ClosePrintCommunication(Modelo, cPort)
Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWPrintTextNotFiscal
@type Function
@param   	cTexto, caracter, texto que será impresso
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet, numerico, Imprimiu ou não ?
/*/
//-------------------------------------------------------------------
Function STWPrintTextNotFiscal(cTexto)
Local lRet		:= .T. 	// Retorno Lógico
Local nRet		:= 0 		// Retorno Númerico
Local nRetImp	:= 0 //retorno da impressao 
Local cAuxTexto	:= ""			// Texto Auxiliar
Local lPrint	:= .T.				//Controle Impressao 
Local lMobile	:= STFGetCfg("lMobile", .F.)//Smart Client Mobile
Local lTry		:= .T. //Tentativa
Local nMVNFCEIMP:= SuperGetMV("MV_NFCEIMP",, 1)
Local nTentativa:= 0
Local cPorta	:= ""

Default cTexto 	:= ""		// Texto recebido

lMobile := ValType(lMobile) == "L" .AND. lMobile

//Versao Demonstrativa nao Imprime comprovantes
If lMobile .AND. STFGetCfg("cTypeOperation","") == "DEMONSTRACAO"
	lPrint := .F.
	lRet 	:= .T.
EndIf

If lRet .AND. !Empty(AllTrim(cTexto))  .AND. lPrint
	cAuxTexto	:=  cTexto
	nRetImp := oImpBWECF:PrintTextNotFiscal(cAuxTexto)
	If (lEmitNfce .Or. lMobile) .AND. nRetImp <> 0
	
		If nRetImp <> 0
			If lEmitNfce
				If nMVNFCEIMP == 1
					MsgInfo(STR0005,"ERRO")//"Falha ao imprimir texto"
				Else
					nTentativa := 0
					//"Ocorreu algum problema durante a impressão. Será realizada tentativa de comunicação com o equipamento!" 
					//"Para remover a obrigatoriedade da Impressão ajuste o parâmetro MV_NFCEIMP para 1"
					//"ERRO"
					MsgInfo(STR0025 + CHR(10) + STR0026,STR0024)
					LjGrvLog("STWPrintTextNotFiscal",STR0025)
				EndIf
			Else
				MsgInfo(STR0005,"ERRO")//"Falha ao imprimir texto"
			EndIf
		EndIf
		
		Do While lTry
			If lEmitNfce
				If nMVNFCEIMP == 1
					lTry := FWAlertYesNo(STR0006) //"Impressora não responde. Tentar novamente?"
					
					If !lTry
						LjGrvLog("STWPrintTextNotFiscal",;
								" MV_NFCEIMP com 1 [ seta a Impressão da NFC-e como não obrigatória] " +;
								" e foi selecionado não continuar a impressão devido a problema de comunicação " )
					EndIf
				Else
					
					LjGrvLog("STWPrintTextNotFiscal",;
								" Tentativa de Impressão [" + cValToChar(nTentativa) + "] " + CHR(10) + CHR(13)+;
								" MV_NFCEIMP com 2 [ seta a Impressão da NFC-e como OBRIGATÓRIA] " +;
								" portanto será efetuada tentativa de impressão até que haja comunicação com a impressora" +;
								" caso contrário, altere o parâmetro para 1")
					
					nTentativa++
				EndIf
			Else
				lTry := FWAlertYesNo(STR0006) //"Impressora não responde. Tentar novamente?"
				LjGrvLog("STWPrintTextNotFiscal",STR0006,lTry)
			EndIf
			
			If lTry

				cPorta := STFGetStat("PORTIF")
				If lLjxCtImpRD .And. LjxImpRede(.F.)
					cPorta := LjxEqPIPRD()[2]
				EndIf

				STWCloseCom(cPorta)
				If !STWOpenImp()
					lTry := .T.
					nRetImp := -1
					Loop
				Else
					nRetImp := oImpBWECF:PrintTextNotFiscal(".")
                    
                    If nRetImp == 0
						LjGrvLog("STWPrintTextNotFiscal"," Todo o conteúdo enviado será reimpresso pois a comunicação foi restabelecida com o equipamento " )
						nRetImp := oImpBWECF:PrintTextNotFiscal(cAuxTexto)
					Else
						If lEmitNfce .And. (nMVNFCEIMP <> 1) 
							If nTentativa < 3
								//#"Ocorreu algum problema durante a impressão. "
								//#" Tente ligar a Impressora / Verificar a falta de papel / Se os cabos estão conectados."
								//#" Será realizada outra tentativa de comunicação!" #"IMPRESSORA"
								MsgInfo(STR0027 + CHR(10) + CHR(13) +;
										STR0028 + CHR(10) + CHR(13) +;
										STR0029,STR0030)
							ElseIf nTentativa == 3
								//#"Não foi possível estabelecer comunicação com a Impressora" // #"IMPRESSORA"
								MsgInfo(STR0031,STR0030)
								lTry	:= .F.
								nRetImp := -1
								nRet 	:= -1
								LjGrvLog("STWPrintTextNotFiscal", "Retorno da Impressora ", nRetImp)									
								Loop
							EndIf
						EndIf							
					EndIf
				EndIf
				lTry := nRetImp <> 0
			Else
				lTry := .F.	
			EndIf
			
			nRet := nRetImp
			LjGrvLog("STWPrintTextNotFiscal", "Retorno da Impressora ", nRetImp)
		EndDo
	EndIf
EndIf

LjGrvLog("STWPrintTextNotFiscal", "Retorno", nRet)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCMC7Direct
Function captura dados CMC7
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	aDados - Dados capturados
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCMC7Direct()
Local aDados	:= {}							//Array contendo os dados do cheque distribuidos por tipo
Local cBufCmc7	:= Space( 100 )					//Variavel de retorno da leitura do cheque (CMC7)
Local lLjLeCMC7	:= ExistBlock( "LJLECMC7" )		// Variavel logica que checa existencia do ponto de entrada LJLECMC7
Local oBufCmc7									//Objeto do GET de leitura do CMC7
Local oSay										//Objeto do Say
Local oDlg										//Objeto da Tela de Leitura
Local oBtnOK									//Objeto do botao de Ok.

//TODO: ver se vai trocar tela

DEFINE MSDIALOG oDlg TITLE "Leitura do CMC7 por Leitoras Diretas" FROM 000, 000  TO 100, 400 COLORS 0, 16777215 PIXEL	//"Leitura do CMC7 por Leitoras Diretas"

	@ 011, 004 SAY oSay PROMPT "Chave CMC7" SIZE 034, 011 OF oDlg COLORS 0, 16777215 PIXEL	//"Chave CMC7"
	@ 010, 040 MSGET oBufCmc7 VAR cBufCMC7 	SIZE 120, 010 OF oDlg VALID VldCMC7Dir(@cBufCMC7,@oDlg)  COLORS 0, 16777215 PIXEL

	DEFINE SBUTTON oBtnOK FROM 030, 220 TYPE 01 OF oDlg ENABLE Action oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

// Ponto de Entrada para tratamento dos dados capturados
// pelo leitor de CMC7. Solicitado por Casa das Alian‡as
If !Empty(cBufCMC7)
	If lLjLeCmc7
		xRet  := ExecBlock( "LJLECMC7", .F., .F., { cBufCMC7 } )
		If ValType(xRet) == "C"
		   cBufCMC7  := xRet
		EndIf
	EndIf

	AAdd( aDados, Subs( cBufCMC7, 02, 3 ) )	   		// cBanco
	AAdd( aDados, Subs( cBufCMC7, 15, 6 ) + " " )	// cNumCheque
	AAdd( aDados, Subs( cBufCMC7, 05, 4 ) )	   		// cAgencia
	AAdd( aDados, Subs( cBufCMC7, 25, 8 ) )	   		// cConta
	Aadd( aDados, Subs( cBufCMC7, 11, 3 ) )	  		// cCompensacao
EndIf

Return aDados


//-------------------------------------------------------------------
/*/{Protheus.doc} STWVldCMC7Dir
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWVldCMC7Dir(cBufCMC7,oDlg)

Default cBufCMC7		:= ""
Default oDlg	   		:= Nil

oImpBWECF:VldCMC7Dir(cBufCMC7,oDlg)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWComCMC7D
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWComCMC7D()

Local cRet := STFGetStat("CMC7DIR")
Local lRet := ValType(cRet) == "C" .AND. cRet == "1" 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWArqMFD
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWArqMFD(cDataIni, cDataFim, cCooIni ,cCooFim,;
	 			   cChPriv, cChPubl, cPath,cFile)

Default cDataIni    := ""
Default cDataFim    := ""
Default cCooIni     := ""
Default cCooFim     := ""
Default cChPriv     := ""
Default cChPubl     := ""
Default cPath       := ""
Default cFile       := ""

If STWCheckPaper(.T.)
	oImpBWECF:ArqMFD(cDataIni, cDataFim, cCooIni ,cCooFim,;
    				   cChPriv, cChPubl, cPath,cFile)
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWGetNf
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWGetNf()
oImpBWECF:GetNf()
Return  Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWIsTotvs
Function   STWIsTotvs
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	.t. or .F.
@obs
@sample STWIsTotvs(SM0->M0_CNPJ)
/*/
//-------------------------------------------------------------------
Function STWIsTotvs(cCNPJ)

Default cCNPJ    := ""

Return cCNPJ == "53113791000122"


//-------------------------------------------------------------------
/*/{Protheus.doc}VldCMC7Dir
Efetua a validacao do CMC7 lido
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPl1 - Boolean
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Static Function VldCMC7Dir(cBufCMC7,oDlg)

Local lRet	:= .T.				//Variavel de validacao para o retorno

Default cBufCMC7	:= ""		//codigo do CMC7 lido
Default oDlg		:= Nil		//Objeto da janela de leitura do CMC7

cBufCMC7 := Alltrim(cBufCMC7)

If SubStr(cBufCMC7,1,1) <> "<"
	cBufCMC7	:= SubStr(cBufCMC7,2,Len(cBufCMC7) - 1)
EndIf

If Len(cBufCMC7) <> 34
	cBufCMC7	:= ""
EndIf

If oDlg <> NIL
	oDlg:End()
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}STWCMC7Use
Efetua a validacao do CMC7 lido
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPl1 - Boolean
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWCMC7Use()
Return oImpBWECF:CMC7Use()


//-------------------------------------------------------------------
/*/{Protheus.doc}STWCheckUse
Efetua a validacao do CMC7 lido
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPl1 - Boolean
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWCheckUse()
Return oImpBWECF:CheckUse()


//-------------------------------------------------------------------
/*/{Protheus.doc}STWBalcUse
Efetua a validacao do CMC7 lido
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPl1 - Boolean
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWBlacUse()
Return oImpBWECF:BalanceUse()

//-------------------------------------------------------------------
/*/{Protheus.doc}STWBalcUse
Libera o Objeto ECF
@author  Varejo
@version 	P11.8
@since   	03/05/2012
@return  	EXPl1 - Boolean
@obs     	Nil
@sample     Nil
/*/
//-------------------------------------------------------------------
Function STWReleaseObj()
	oImpBWECF := FreeObj(oImpBWECF)

Return
//-------------------------------------------------------------------

/*/{Protheus.doc}STWCheckDate
Function STWCheckDate
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCheckDate()

Local cRetorno := ""
Local nRet := 0
Local lRet := .F.

If STWIsTaxPrinter()
	nRet := STWPrinterStatus( '19', @cRetorno )
	If nRet == 0 .OR. nRet == 2
		If ( CtoD( cRetorno ) == dDataBase .AND. STWCheckHour() )
			lRet := .T.
		Else
			STFShowMessage( "CHECKDATE" )
			STFMessage( "CHECKDATE","STOP",STR0001) //"Data da impressora fiscal diferente da data do sistema."
		Endif
	ElseIf nRet == 1
		nRet := STWPrinterStatus('2', @cRetorno )
		If nRet == 0
			If ( CtoD( cRetorno ) == dDataBase .AND. STWCheckHour() )
				lRet := .T.
			Else
			    STFShowMessage( "CHECKDATE" )
			    STFMessage( "CHECKDATE","STOP",STR0001)
			Endif
		Else
			STFShowMessage( "CHECKDATE2" )
			STFMessage( "CHECKDATE2","STOP",STR0002) //"Erro de comunicação com o ECF."
		EndIf
	Else

		STFShowMessage( "CHECKDATE2" )
		STFMessage( "CHECKDATE2","STOP",STR0002) //"Erro de comunicação com o ECF."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCheckHour
Verifica se a hora do Computador difere em mais de 15 minutos da hora do Ecf
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se a impressora é fiscal
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCheckHour(cRetHrPC, cRetHrEcf)

Local cHoraPC
Local cHoraECF		:= Space(8)
Local nHoraPC
Local nHoraECF
Local cData			:= Space(8)
Local dData
Local lRet  	// retorno da função
Local nX        // auxiliar

Default cRetHrPC  := ""
Default cRetHrEcf := ""

STWPrinterStatus('2',@cData)
dData := GetRmtDate()

STWPrinterStatus('1',@cHoraECF)
cHoraPC := GetRmtTime()

nX :=  ( CToD(cData) - dData ) * 24 * 60
nHoraPC  := (Val (SubStr (cHoraPC, 1, 2))*60) + Val (SubStr (cHoraPC, 4, 2))
nHoraECF := (Val (SubStr (cHoraECF, 1, 2))*60) + Val (SubStr (cHoraECF, 4, 2))

If STBIsPAF(SM0->M0_CGC)

	//Paf ECF - Limite 60 minutos requisito XVII
	If ABS(nX + nHoraECF - nHoraPC) <= 60
		lRet := .T.
	Else
		lRet := .F.
	EndIf

ElseIf ABS(nX + nHoraECF - nHoraPC) <= 15
	lRet := .T.
Else
	lRet 		:= .F.
	cRetHrPC 	:= cHoraPC
	cRetHrEcf	:= cHoraECF 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWIsTaxPrinter
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se a impressora e fiscal
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWIsTaxPrinter()
//Retorna se a impressora e fiscal
Local lRet := oImpBWECF:lFiscal 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWValSerie
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
/*/
//-------------------------------------------------------------------
Function STWValSerie(lPafLista)
Local cSerie 		:= Space(20)				// Buffer para captura do numero de serie atraves da impressora
Local cBuffer		:= Space(20)				// Buffer para captura do numero de serie atraves do arquivo
Local nRet 			:= 0           				// Retorno da funcao IFPegSerie: 0 = OK | 1 = Erro
Local nHandle 		:= 0 						// Handle para tratamento do arquivo criptografado a ser lido
Local nSize 		:= 0						// Tamanho do arquivo a ser lido
Local aAnalisaLeg	:= {}						// Retorno do Array AnalisaLeg
Local lLjfPaf		:= STBIsPAF()				// Ambiente PAF-ECF
Local cBufferL1		:= Space(20)
Local cCript		:= Space(20)
Local cVendaBruta	:= Space(20)
Local cGT			:= Space(20)
Local lRet			:= .T.
Local cArqLista		:= GetClientDir() + "PAFLISTA.TXT"  
Local cChaveMd5		:= ""
Local cChaveMd5F	:= ""
Local cMD5Arq		:= ""
Local lHomolPAF		:= STBHomolPaf()
Local lValida		:= .T.
Local aLinhasArq	:= {}

Default lPafLista 	:= .F.

//Nao deve realizar validacao do arquivo criptografado quando equipamento nao fiscal
If lEmitNfce .Or. STBPafNfce()
	lValida := .F.
	lRet	:= .T.
EndIf

If lValida
	
	If ExistFunc("STBPEInFld")
		STBPEInFld()
	EndIf

	If !lLjfPaf
		aAnalisaLeg := LJAnalisaLeg(23)	 // Retorno da funcao de legislacao

		If !aAnalisaLeg[1]
			If !SuperGetMV("MV_LJNSECF") .OR. !STWIsTaxPrinter()
				lValida := .F.
			EndIf
		Else
			If !STWIsTaxPrinter()
				lValida := .F.				
			EndIf
		EndIf
	EndIf
	
	If lValida
		nRet := STWGetSerie(@cSerie)
		cSerie:= SubStr(cSerie,1,20)
		
		If nRet == 0
			//Deve-se verificar a Venda Bruta
			nRet :=	STWPrinterStatus( '17', @cVendaBruta )
			cCript := cVendaBruta
			
			If Val( cVendaBruta )== 0 .AND. nRet == 0   
				nRet := STWPrinterStatus( '18', @cGT )
				cCript := cGT		
			Endif
		Else
			lRet := .F.
		EndIF

		If nRet <> 0
			lRet := .F.
			If !lLjfPaf .AND. aAnalisaLeg[1]
				LJMsgLeg( aAnalisaLeg )
			Else
				STFMessage("STWValSerie", "STOP","Ocorreu um erro ao ler o número de série do ECF ou a função de leitura de série não está disponível para este modelo de Impressora.")
				STFShowMessage( "STWValSerie" )
			EndIf
			lValida := .F.
		EndIF
		
		If lValida
	//PAF-ECF: Salva Número de Série/GT no mesmo arquivo
			If lLjfPaf
				nHandle := fOpen(GetClientDir()+"SIGALOJA.VLD")
			Else
				nHandle := fOpen(GetClientDir()+"SIGALOJA.BIN")
			EndIF
			
			If nHandle == -1    
				lRet := .F.
				If !lLjfPaf .AND. aAnalisaLeg[1]
					LJMsgLeg( aAnalisaLeg )
				Else
					STFMessage("STWValSerie2", "STOP","Ocorreu um ero ao ler o arquivo criptografado.")
					STFShowMessage( "STWValSerie2" )
				EndIf
				lValida := .F.
			EndIf
			
			If lValida
				//Le o arquivo criptografado
				nSize 	:= FSeek( nHandle, 0, 2 )
				FSeek( nHandle, 0 )
				cBuffer := Space( nSize )
				FRead( nHandle, @cBuffer, nSize )
				fClose(nHandle)

				//GT criptografado
				//Serie Criptografado
				//Razao Social 
				//CNPJ
				//IE
				//IM
				//Nome do PAF
				//Versao do PAF
				//MD5 PafLista.txt
				aLinhasArq := {}	
				If lLjfPaf
					nPos := At(chr(10),cBuffer)
					While nPos > 0
						Aadd(aLinhasArq,Encript(SubStr(cBuffer,1,nPos-1),1))
						cBuffer	:= Substr(cBuffer,nPos+1,Len(cBuffer)-nPos)
						nPos := At(chr(10),cBuffer)
					End
				EndIf
				
				//Deve ser o MD5 do PAFLista,constante na ultima linha
				If !Empty(cBuffer)
					If lLjfPaf
						Aadd(aLinhasArq,Decode64(SubStr(cBuffer,1,Len(cBuffer)))) //o Encript estava mudando o MD-5 por isso uso Decode64
					Else
						Aadd(aLinhasArq,Encript(SubStr(cBuffer,1,Len(cBuffer)),1))
					EndIf	
				EndIf	

				If lLjfPaf
					cBuffer := SubStr(aLinhasArq[2],1,20)
					cBufferL1:= aLinhasArq[1]
					cMD5Arq := aLinhasArq[Len(aLinhasArq)]
				Else
					cBuffer := aLinhasArq[1]
				EndIf	

				// Se o numero lido do arquivo for o mesmo lido da impressora entao retorna .T.
				If (AllTrim(cBuffer) == AllTrim(cSerie)) .AND.;
					(!lLjfPaf .Or. ((AllTrim(cBufferL1) == AllTrim(cCript)) .And. (cMD5Arq == STBMd5File( cArqLista ))))
					
					lRet := .T.
				Else
					If lLjfPaf .OR. !aAnalisaLeg[1]
						STFMessage("STWValSerie3", "STOP","O número de série gravado no arquivo é diferente do número de série da impressora.")
						STFShowMessage("STWValSerie3")
						lRet := STWValGT(.T.)
					Else
						LJMsgLeg(aAnalisaLeg) 
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWValGT
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
/*/
//-------------------------------------------------------------------
Function STWValGT(lRecria)
Local nRet 		:= 0							 		// Retorno dos comandos enviados a impressora
Local cVendaBruta:= Space( 20 )			 		 		// Valor da Venda Bruta
Local cGT 		:= Space( 20 )			  		 		// Valor do Grante Total
Local cCript 	:= Space( 20 )			   		 		// Valor a ser criptografado
Local cCriptL2	:= Space( 20 )			   		 		// Valor da Venda Bruta
Local cBuffer 	:= Space( 20 )					 		// Armazena os valores criptografados
Local cBufferL2	:= Space( 20 )							// Valor a ser criptografado da VB
Local lRet 		:= .F.  						 		// Retorno da funcao
Local nSize 	:= 0						  	   		// Tamanho do arquivo criptografado
Local nHandle 	:= 0									// Variavel de manipulacao do arquivo
Local lGrava 	:= SuperGetMV( "MV_LJGRVVB", ,.F. )		// Verifica se grava a venda bruta criptografada
Local cArq		:= "SIGALOJA.VLD"						// Nome do arquivo
Local nPos		:= 0
Local cSerie	:= Space( 20 )
Local cPath		:= GetClientDir()
Local cArqLista	:=  cPath + "paflista.txt" 
Local lLjNfPafEcf:= STBIsPAF()
Local lDifGrdTot:= .F.
Local lDifNumSer:= .F.
Local lDifMD5	:= .F.
Local aLinhasArq:= {}

DEFAULT lRecria		:= .T.									// Verifique se ira permitir recriar o arquivo criptografado, A partir do Ato Cotepe 01.11 permite recriar o arquivo em qualquer momento e nao apenas na inicializacao

//Verifica se existe legislacao ou se o MV_LJGRVVB esta como .T.
//Por enquanto essa validacao serve apenas para SC.
If lLjNfPafEcf .OR. LJAnalisaLeg(20)[1] .OR. lGrava
	nRet :=  STWPrinterStatus('17',@cVendaBruta )
	cCript := cVendaBruta

	//Verifica se a venda bruta esta zerada (nao foi feito venda no dia corrente)
	//e grava o sigaloja.vld com o GT.

	// faz a gravacao do arquivo inicial
	If !File( "SIGALOJA.FST" ) .AND. GetPvProfString( "MICROSIGA", "GRV. INICIAL", "N", cPath + "SIGALOJA.INI" ) <> "S"
		WritePProString( "MICROSIGA", "GRV. INICIAL", "S", cPath + "SIGALOJA.INI" )
		STWGrvGT("SIGALOJA.FST")
		STWGrvGT(cArq, lRecria)
	Endif

	If Val( cVendaBruta ) == 0 .AND. nRet == 0
		STWGrvGT( cArq )
		nRet :=  STWPrinterStatus('18',@cGT )
		cCript := cGT
	Endif

	If File(cPath+"SIGALOJA.VLD")
		nHandle := fOpen(cPath+"SIGALOJA.VLD")

		If nHandle == -1
			STFMessage("STWValGT1", "STOP","Ocorreu um erro ao ler o arquivo criptografado.")
			STFShowMessage("STWValGT1")
			lRet := .F.
		Else
			lRet := .T.
		EndIf
		
		If lRet
			//Le o arquivo criptografado
			nSize 	:= FSeek( nHandle, 0, 2 )
			FSeek( nHandle, 0 )
			cBuffer := Space( nSize )
			FRead( nHandle, @cBuffer, nSize )
			fClose(nHandle)
	
			//Quando Ambiente PAF-ECF, possui mais linhas
			If lLjNfPafEcf
				nRet := STWGetSerie(@cSerie)
				cCriptL2	:= cSerie
				
				nPos := At(chr(10),cBuffer)
				
				While nPos > 0
					Aadd(aLinhasArq,Encript(SubStr(cBuffer,1,nPos-1),1))
					cBuffer	:= Substr(cBuffer,nPos+1,Len(cBuffer)-nPos)
					nPos := At(chr(10),cBuffer)
				end
			EndIf
	
			//Linha do MD5
			If !Empty(cBuffer)
				If lLjNfPafEcf
					Aadd(aLinhasArq,Decode64(SubStr(cBuffer,1,Len(cBuffer))))
				Else
					Aadd(aLinhasArq,Encript(SubStr(cBuffer,1,Len(cBuffer)),1))
				EndIf
			EndIf
			
			cBuffer := aLinhasArq[1]
			
			If lLjNfPafEcf
				cBufferL2 := aLinhasArq[2]
				lDifMD5 := aLinhasArq[Len(aLinhasArq)] == STBMd5File( cArqLista )
			Else
				lDifMD5 := .T.
			EndIf
	
			lDifGrdTot:= (AllTrim(cBuffer) == AllTrim(cCript))
			lDifNumSer:= (AllTrim(cBufferL2) == AllTrim(cCriptL2))
						
			If lDifGrdTot .AND. lDifNumSer .And. lDifMD5
				lRet := .T.
			Else
				If lDifMD5 .And. lRecria .AND. STDLastRedZ()
					STWCripArq()
					lRet := .T.
				Else
					STFMessage("STWValGT2", "STOP","Ocorreu um erro ao ler o arquivo criptografado.")
					STFShowMessage("STWValGT2")
					If lLjNfPafEcf
						lRet := .F.
					EndIf
				EndIf
			EndIf
		Else
			STFMessage("STWValGT3", "STOP","Ocorreu um erro ao tentar abrir o arquivo criptografado. Verifique")
			STFShowMessage("STWValGT3")
		EndIf
	Else
		STFMessage("STWValGT4", "STOP","Ocorreu um erro ao ler o arquivo criptografado.")
		STFShowMessage("STWValGT4")
		lRet := .F.
	Endif
Else
	lRet := .T.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCripArq
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
/*/
//-------------------------------------------------------------------
Function STWCripArq()
Local cSerie 		:= Space(20)				// Buffer para captura do numero de serie
Local nRet 			:= 0           				// Retorno da funcao IFPegSerie: 0 = OK | 1 = Erro
Local nHandle 		:= 0 						// Handle para tratamento do arquivo criptografado a ser criado
Local lRet      	:= .T.         				// Retorno da funcao
Local cImpressora	:= STFGetStat("IMPFISC")	// Pressora fiscal
Local cPorta		:= STFGetStat("PORTIF")	// Porta configurada
Local lLjfPaf		:= STBIsPAF()	// Ambiente PAF-ECF
Local lHomolPAF		:= STBHomolPaf() // Sinaliza rotinas de processo de homologacao
Local lContinua		:= .T.

If nModulo == 23 .And. STFIsPOS()

	//Abre a impressora Fiscal 
	STWOpenCom(cImpressora, cPorta ) 
	STWOpenECF()

	If !lLjfPaf .And. !LJAnalisaLeg(23)[1] .And. ( !SuperGetMV("MV_LJNSECF") .OR. !STWIsTaxPrinter() )
		STFMessage("STWCripArq", "STOP","Esta rotina é utilizada para gerar o arquivo criptografado conforme Convênio ICMS 50/00 " +;
		" - cláusula 80a - alíneas c e d. Caso a sua UF utilize esta rotina, verifique com a Microsiga como ativá-la.")
		STFShowMessage("STWCripArq")
		lRet := .F.
		lContinua := .F.
	EndIf
	
	If lContinua
	
		nRet := STWGetSerie(@cSerie)
	
		If nRet == 0
			// Gera o arquivo no diretorio do Remote (BIN)
			fErase(GetClientDir()+"SIGALOJA.BIN")
			nHandle := fCreate(GetClientDir()+"SIGALOJA.BIN")
			fWrite(nHandle,Encript(AllTrim(cSerie),0)) // Criptografa
			fClose(nHandle)
			If lLjfPaf
				STWGrvGT("SIGALOJA.VLD", .T.)
			EndIf
		
			// Nao existe regra no Ato Cotepe 0608 para nao permitir aparecer essa mensagem de arquivo gerado, mas durante o processo de homologacao eh solicitado que nao apareca
			If !lHomolPAF
				STFMessage("STWCripArq2", "ALERT","O arquivo criptografado com o numero de série do ECF foi gerado com sucesso.")
				STFShowMessage("STWCripArq2")
			EndIf
		Else
			STFMessage("STWCripArq3", "STOP","Ocorreu um erro ao ler o número de série do ECF ou a função de leitura de série não está disponível para este modelo de Impressora.")
			STFShowMessage("STWCripArq3")
			lRet:=.T.
		EndIf       
	EndIf
	
	If IsInCallStack("__EXECUTE") //Chamada do Menu Principal - deve fechar a comunicação senão da erro na entrada do TOTVSPDV
		STWCloseCom(cPorta)
	EndIf
Else
	MsgAlert("Para o módulo diferente de TotvsPDV utilize a rotina LOJA420","Arq. ECF")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWGrvGT
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
/*/
//-------------------------------------------------------------------
Function STWGrvGT( cArquivo, lLeMD5 )
Local cGT 			:= Space( 20 )			  				// Armazena GT do ECF
Local cVendaBruta	:= Space( 20 ) 			  				// Armazena Venda Bruta do ECF
Local nRet			:= 0					   				// Retorno dos comandos da impressora
Local nHandle		:= 0					   				// Manipula o arquivo que sera criptografado
Local cCript 		:= Space( 20 ) 							// Guarda o GT ou a Venda Bruta a ser criptografada
Local lRet 			:= .F.		   				   			// Retorno da funcao
Local lGrava 		:= SuperGetMV( "MV_LJGRVVB", ,.F. )		// Verifica se faz a gravacao da venda bruta diaria em arquivo criptografado
Local cSerie 		:= Space(20)							// Buffer para captura do numero de serie atraves da impressora
Local cConteudo 	:= ""
Local cChaveMd5		:= ""
Local lLjfPaf		:= STBIsPAF()	// Ambiente PAF-ECF
Local cArqLista		:= GetClientDir() + "PAFLISTA.TXT"
Local lHomolPAF		:= STBHomolPaf()

Default cArquivo    := "" 
Default lLeMD5	:= .F. 

lLeMD5 := !(lLeMD5 .AND. lHomolPAF)  //Le o MD5 do sigaloja.vld

If IsInCallStack("STWCRIPARQ")
	lLeMD5 := .F.
Endif 

If lLjfPaf .OR. LJAnalisaLeg(20)[1] .OR. lGrava
	// Captura o GT da impressora
	nRet :=  STWPrinterStatus('17',@cVendaBruta )
	cCript := cVendaBruta

	If Val( cVendaBruta )== 0 .AND. nRet == 0
		nRet :=  STWPrinterStatus('18',@cGT )
		cCript := cGT
	Endif

	//PAF-ECF: Salva no mesmo arquivo o número de série do ECF e o MD5 do arquivo PafLista.txt, nao utilizar nesse ponto a rotina LjGrvMd5Ls, devido a performance!!!
	If lLjfPaf
		nRet := STWGetSerie(@cSerie)
        If !lLeMD5
			If File(cArqLista)
				cChaveMd5	:= 'MD5FILE('+"'"+cArqLista+"'"+')'
				cChaveMd5 	:= &(cChaveMd5)
				cChaveMd5 	:= Upper(cChaveMd5)
			EndIf
		Else 
			cChaveMd5 := STBRETMD5()
		EndIf
	EndIf

	If nRet == 0
		fErase(GetClientDir()+cArquivo)
		nHandle := fCreate(GetClientDir()+cArquivo)

		If lLjfPaf
			//GT criptografado
			cConteudo := Encript(AllTrim( cCript ),0) + Chr(10)

			//Serie Criptografado
			cConteudo += Encript(AllTrim( cSerie ),0) + Chr(10)

			//Razao Social 
			cConteudo += Encript(AllTrim( _RAZSOC ),0) + Chr(10)
			
			//CNPJ
			cConteudo += Encript(AllTrim( _CNPJTOT ),0) + Chr(10)
			
			//IE
			cConteudo += Encript(AllTrim( _INSCEST ),0) + Chr(10)
			
			//IM
			cConteudo += Encript(AllTrim( _INSCMUN ),0) + Chr(10)
			
			//Nome do PAF
			cConteudo += Encript(AllTrim( STBFMModPaf() ),0) + Chr(10)
			
			//Versao do PAF
			cConteudo += Encript(AllTrim(STBVerPAFECF("VERSAOAPLIC")),0) + Chr(10)
			
			/*
			Deixar MD5 sempre por ultimo devido a função STBGrvMd5Ls
			Não inserir a quebra aqui pra seja desconsiderada e ajustada na função 
			*/
	        //MD5 PafLista.txt
			cConteudo += Encode64(AllTrim( cChaveMd5 ))
			  
			fWrite(nHandle,cConteudo) // Criptografa
		Else
			fWrite(nHandle,Encript(AllTrim( cCript ),0)) // Criptografa
		EndIf

		fClose(nHandle)
		lRet := .T.
	Else
		If lLjfPaf
			lRet := .F.
		EndIf

		STFMessage("STWGrvGT", "ALERT","Houve erro na gravação do arquivo criptografado da Venda Bruta.")
		STFShowMessage("STWGrvGT")
	Endif
Else
	lRet := .T.
Endif

Return lRet

///-------------------------------------------------------------------
/*/{Protheus.doc} STWGrvCCGT
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet - Retorna se executou corretamente
/*/
//-------------------------------------------------------------------   
Function STWGrvCCGT( cArquivo  )
Local cGT 			:= Space( 20 )			  				// Armazena GT do ECF
Local cVendaBruta	:= Space( 20 ) 			  				// Armazena Venda Bruta do ECF
Local nRet			:= 0					   				// Retorno dos comandos da impressora          
Local nHandle		:= 0					   				// Manipula o arquivo que sera criptografado
Local cCript 		:= Space( 20 ) 							// Guarda o GT ou a Venda Bruta a ser criptografada
Local lRet 			:= .F.		   				   			// Retorno da funcao      
Local lGrava 		:= SuperGetMV( "MV_LJGRVVB", ,.F. )		// Verifica se faz a gravacao da venda bruta diaria em arquivo criptografado
Local cSerie 		:= Space( 20 )							// Buffer para captura do numero de serie atraves da impressora
Local cConteudo 	:= ""                   
Local cChaveMd5		:= ""
Local lLjfPaf		:= STBIsPAF()	// Ambiente PAF-ECF
Local cBuffer		:= ""
Local cClientDir	:= ""
Local nPos			:= 0
Local aDados		:= {}
Local aRet			:= {}
                                  
If lLjfPaf .OR. LJAnalisaLeg(20)[1] .OR. lGrava 
	// Captura o GT da impressora	
	nRet := 0
	aDados := {"17", cVendaBruta}
	aRet :=	STFFireEvent(	ProcName(0) ,"STPrinterStatus"	, aDados )
	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
    	cVendaBruta := aDados[2]
    	cCript		:= cVendaBruta
    	nRet		:= aRet[1]
 	ElseIf Len(aRet) == 0 .OR. aRet[1] <> 0
 		nRet := -1
 	EndIf
	
	If Val( cVendaBruta )== 0 .AND. nRet == 0
		nRet := 0
		aDados := {"18", cGT}
		aRet :=	STFFireEvent(	ProcName(0) ,"STPrinterStatus"	, aDados )
		If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
	    	cGT := aDados[2]
	    	cCript := cGT
	    	nRet:= aRet[1]
	 	ElseIf Len(aRet) = 0 .OR. aRet[1] <> 0
	 		nRet := -1
	 	EndIf
	Endif
	
	//PAF-ECF: Salva no mesmo arquivo o número de série do ECF e o MD5 do arquivo PafLista.txt, nao utilizar nesse ponto a rotina LjGrvMd5Ls, devido a performance!!! 
	If lLjfPaf
		nRet := STWGetSerie(@cSerie)
	EndIf
			
	If nRet == 0
		cClientDir := GetClientDir()
		nHandle := fOpen(cClientDir+cArquivo)
		nSize 	:= FSeek( nHandle, 0, 2 )
		FSeek( nHandle, 0 )
		cBuffer := Space( nSize )
		FRead( nHandle, @cBuffer, nSize )
		fClose(nHandle)
		
		//Com a mudança o MD5 ficou na ultima posição do arquivo e sem o CHR(10)
		nPos := At(chr(10),cBuffer)
		While nPos > 0
			cBuffer	:= Substr(cBuffer,nPos+1,Len(cBuffer)-nPos)
			nPos := At(chr(10),cBuffer)
		end
		
		cBuffer := Substr(cBuffer,1,Len(cBuffer)) //Linha do MD-5
		cChaveMd5:= Decode64(cBuffer) 	// Descriptografa
		
		fErase(cClientDir+cArquivo)
		nHandle := fCreate(cClientDir+cArquivo)

		If lLjfPaf
			//GT criptografado
			cConteudo := Encript(AllTrim( cCript ),0) + Chr(10)
			
			//Serie Criptografado
			cConteudo += Encript(AllTrim( cSerie ),0) + Chr(10)

			//Razao Social 
			cConteudo += Encript(AllTrim( _RAZSOC ),0) + Chr(10)
			
			//CNPJ
			cConteudo += Encript(AllTrim( _CNPJTOT ),0) + Chr(10)
			
			//IE
			cConteudo += Encript(AllTrim( _INSCEST ),0) + Chr(10)
			
			//IM
			cConteudo += Encript(AllTrim( _INSCMUN ),0) + Chr(10)
			
			//Nome do PAF
			cConteudo += Encript(AllTrim( STBFMModPaf() ),0) + Chr(10)
			
			//Versao do PAF
			cConteudo += Encript(AllTrim(STBVerPAFECF("VERSAOAPLIC")),0) + Chr(10)
			
			/*
			Deixar MD5 sempre por ultimo devido a função STBGrvMd5Ls
			Não inserir a quebra aqui pra seja desconsiderada e ajustada na função 
			*/
	        //MD5 PafLista.txt
			cConteudo += Encode64(AllTrim( cChaveMd5 ))
			  
			fWrite(nHandle,cConteudo) // Criptografa			
		Else                             
			fWrite(nHandle,Encript(AllTrim( cCript ),0)) // Criptografa
		EndIf
		
		fClose(nHandle)
		lRet := .T.
	Else     
		If lLjfPaf
			lRet := .F.
		EndIf

		STFMessage("LOJA420GT", "STOPPOPUP", STR0006)	//"Houve erro na gravação do arquivo criptografado da Venda Bruta."
		STFShowMessage("LOJA420GT")
	Endif   
Else
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGrvMdz
Function
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	Nil
/*/
//-------------------------------------------------------------------
Function STDGrvMdz(	cSimbol, nValor, cTipo, cNomeCli,;
					 cCgcCli)

LjxGrvMdz(	cSimbol, nValor, cTipo, cNomeCli, cCgcCli)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STWBalProc
Function   STWBalProc
@param   	cPeso
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nValPeso - Retorna Peso
/*/
//-------------------------------------------------------------------
Function STWBalProc(cPeso)

Local nTimeOut  	:= 0                 	//Controle de TimeOut
Local nValPeso  	:= 0                 	// Valor do peso
Local aCampos  		:= {}  					// Array de campos
Local nRet 			:= -1                  	// Retorno
Local nTamPeso 		:= Len(cPeso)          // Peso

Default cPeso := ""

If nMaxTimeOut == NIL
	nMaxTimeOut := IIf(Empty(STFGetStat("TIMEBAL")),20, STFGetStat("TIMEBAL"))
EndIf
aCampos := STDGetProperty("L2_QUANT")
If (nDec := aCampos[6] ) = NIL
	nDec := SL2->(TamSx3("L2_QUANT")[1])
EndIf

While .T. .AND. ((nMaxTimeOut = 0) .OR. nMaxTimeOut > nTimeOut)
	cPeso:= Space(nTamPeso)

	nRet := oImpBWECF:BalanceGet(@cPeso )

	If NoRound(Val(cPeso),nDec ) <> 0
		nRet := 0
		Exit
	EndIf
	
	STFMessage("ItemRegistered","STOP","Coloque o Item na Balança...Aguardando("+AllTrim(Str(nMaxTimeOut - nTimeOut))+")" ) //Registrando Item...
	STFShowMessage("ItemRegistered")
	
	
	nTimeOut += 1

	If nTimeOut > nMaxTimeOut
		cPeso := ""
		nRet := -1
	EndIf
End

nValPeso  := NoRound(Val(cPeso),nDec )

Return nValPeso

//-------------------------------------------------------------------
/*/{Protheus.doc} STWOpDrawer

@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nValPeso - Retorna Peso
/*/
//-------------------------------------------------------------------
Function STWOpDrawer()
Local nRet := 0 //retorno da função de abertura da gaveta

If IsInCallStack("STIConfPay") .or. STFPROFILE(13, "",     , , , .F. , .T.)[1]
	If STWIsTaxPrinter() .AND. STFGetStat("PORTIF")==STFGetStat("PORTGAV")
		nRet := oImpBWECF:Drawer()
	ElseIf oImpBWECF:lDrawer
	    If "LPT" $ STFGetStat("PORTGAV")
	        If STFGetStat("PORTGAV")<>STFGetStat("PORTICP")
	        	STFMessage("STWOpDrawer", "ALERT","A Porta Selecionada para a Gaveta." + CHR(13) + "Não é igual a Porta da Impressora de Cupom...")
	        	STFShowMessage("STWOpDrawer")
	        Else
    	    	STFMessage("STWOpDrawer", "OK","Pressione [ENTER] para efetuar a abertura da gaveta...")
                STFShowMessage("STWOpDrawer")
    	    	STWDrawerMoneyOpen("C", STFGetStat("PORTGAV"))
    	    	nRet := 0
			EndIf
	    Else
	        nRet := STWDrawerAci( , STFGetStat("PORTGAV"))
	    EndIf
	EndIf
EndIf
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWUsaECFE
Function   STWUsaECFE
@param   	cCNPJ - CNPJ do Cliente
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nValPeso - Retorna Peso
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STWUsaECFE(cCNPJ)

Local lRet          := .F.                   // Valida se pode utilizar ECF E

If LEN(aCNPJDV) == 0
	AADD(aCNPJDV, "60957784000415")
	AADD(aCNPJDV, "60957784000687")
	AADD(aCNPJDV, "60957784000920")
	AADD(aCNPJDV, "60957784001225")
	AADD(aCNPJDV, "60957784001497")
	AADD(aCNPJDV, "60957784001659")
	AADD(aCNPJDV, "60957784005050")
	AADD(aCNPJDV, "60957784002388")
	AADD(aCNPJDV, "60957784002540")
	AADD(aCNPJDV, "60957784005131")
	AADD(aCNPJDV, "60957784002973")
	AADD(aCNPJDV, "60957784005212")
	AADD(aCNPJDV, "60957784005301")
	AADD(aCNPJDV, "60957784003511")
	AADD(aCNPJDV, "60957784003600")
	AADD(aCNPJDV, "60957784000849")
	AADD(aCNPJDV, "60957784004160")
	AADD(aCNPJDV, "60957784004240")
	AADD(aCNPJDV, "60957784004593")
	AADD(aCNPJDV, "60957784004674")
	AADD(aCNPJDV, "60957784005727")
	AADD(aCNPJDV, "60957784005808")
	AADD(aCNPJDV, "60957784001578")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida pelo CNPJ                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := Ascan(aCNPJDV,{|x| AllTrim(x) == AllTrim(cCNPJ)}) > 0

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} STWIsTax
Function   STWIsTax
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	.t. - Is Tax User
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWIsTax()
	Local lIsTax := STFPROFILE(03, "",	, , , .F. , .F.)[1]

If FindFunction("STWVldEcfPtg")  .AND.  STWVldEcfPtg(SM0->M0_CGC) .AND. cPaisLoc <> "CHI"
	lIsTax := .F.
EndIf

Return lIsTax

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRecSerie
Function   STWRecSerie
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	.t. - Is Tax User
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRecSerie()
	Local cSerie := space(TamSX3("LG_SERPDV")[1])
	Local nRet := -1
	Local lRet := .F.

	nRet := STWGetSerie( @cSerie )

	If nRet == 0
		lRet := STFSetStat({{ "SERPDV", cSerie}})
    EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWChkSerie
Function   STWChkSerie
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	.t. - Gravou e validou numero de série
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWChkSerie()
	Local lRet := .T.

    If Empty(STFGetStat("SERPDV"))
		lRet := STWRecSerie()
	EndIf

	If Empty(STFGetStat("CRO"))
		lRet := lRet .AND. STWRecCRO()
	EndIf

	If STBIsPaf()
		lRet := lRet .AND. STWValSerie(.T.) //Recria o md5 do paflista
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWChkRptP
Function   STWChkRptP
@type	 Function
@author  Varejo
@version P11.8
@since  13/06/2012
@return	lRet , lógico , Impressora com Dados válidos
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWChkRptP()
Local cRetorno	:= space(20)
Local lRet 		:= .F.
Local nRet 		:= 0
Local cRetHrPC 	:= ""
LocaL cRetHrEcf 	:= "" 

nRet := STWPrinterStatus( '19', @cRetorno )

If nRet == 0 .OR. nRet == 2
	If ( CtoD( cRetorno ) == dDataBase  )
		lRet := .T.
	Else
		STFMessage( "CHECKRECEIPTDATA","STOPPOPUP",STR0003 + CHR(13) + ; //"Data da impressora fiscal diferente da data do sistema."
														 "Data Impressora:"+cRetorno + CHR(13) + ;
														 "Data Sistema:"+DtOc(dDataBase))													
		STFShowMessage( "CHECKRECEIPTDATA" )		
		//Valido se a Redução Z está pendente pois com o retorno .F.( não estava sendo permitida a entrada no módulo )
		lRet := (STWPrinterStatus( '8', '') == 10)		
	Endif
ElseIf nRet == 1
	nRet := STWPrinterStatus('2', @cRetorno )
	If nRet == 0
		If ( CtoD( cRetorno ) == dDataBase )
			lRet := .T.
		Else				
			STFMessage( "CHECKRECEIPTDATA","STOP",STR0003)//"Data da impressora fiscal diferente da data do sistema."
			STFShowMessage( "CHECKRECEIPTDATA" )
		Endif
	Else			
		STFMessage( "CHECKRECEIPTDATA2","STOP",STR0002) //"Erro de comunicação com o ECF."
		STFShowMessage( "CHECKRECEIPTDATA2" )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	EndIf
Else
	STFMessage( "CHECKRECEIPTDATA2","STOP",STR0002) //"Erro de comunicação com o ECF."
	STFShowMessage( "CHECKRECEIPTDATA2" )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
EndIf

If lRet .AND. LjAnalisaLeg(3)[1]
	If !STWCheckHour(@cRetHrPC,@cRetHrEcf)
		STFMessage( "CHECKRECEIPTDATA","STOPPOPUP",STR0022 + CHR(13) + ; //"Hora da impressora fiscal diferente da hora do sistema."
														 "Hora Impressora:" + cRetHrEcf + CHR(13) + ;
														 "Hora Sistema:" + cRetHrPC + CHR(13) + ;
														 "Conforme legislação, tolerância máxima permitida de 15 minutos")
		STFShowMessage( "CHECKRECEIPTDATA" )
		lRet := .F.
	Else
		lRet := .T.
	EndIf
EndIf

//Verifica se o CNPJ cadastrado na impressora, eh o mesmo do SIGAMAT	
If lRet .AND. STWIsTax()
	lRet := STWEcfIFCNPJ()
EndIf

STWGetPDV(@cRetorno)		// Numero do PDV
If !AllTrim(cRetorno) == AllTrim(STFGetStat("PDV"))
	STFMessage( "CHECKRECEIPTDATA3","STOPPOPUP",STR0004 + CHR(13) + ; //"O Número de PDV do equipamento é diferente do cadastrado na estação."
													  "PDV Impressora:" + AllTrim(cRetorno) + CHR(13) + ;
													  "PDV Estação(LG_PDV):" + AllTrim(STFGetStat("PDV")) ) 
	STFShowMessage( "CHECKRECEIPTDATA3" )		                                                                                                                                                                                                                                                                                                                                                                                                                                              
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRetTypePrt
Function   STWRetTypePrt
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	.t. - Impressora com Dados válidos
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRetTypePrt(cBuffer)
Local nRet := 0

cBuffer := oImpBWECF:RetTypePrt()
Return nRet


//-------------------------------------------------------------------
/*{Protheus.doc} STD7CPFOverReceipt
Seta as variaveis que serao utilizadas para setar os dados do cliente no cupom fiscal.
@author  Varejo
@version 	P11.8
@since   	14/05/2013
@return  	Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STD7CPFOverReceipt(cCPF,cNome,cEnd)
DEFAULT cCPF := ""
default cNome := "" 
default cEnd := ""

cCNPJInf := cCPF
cNomeInf := cNome
cEndInf  := cEnd
lDadosInf:= .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRetTypePrt
Function   STWGetNFiscTotal
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno de Execução da função
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWGetNFiscTotal( cBuffer )
Local nRet := -1

DEFAULT cBuffer := space(500)

nRet := oImpBWECF:GetNFiscTotal(@cBuffer)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRetTypePrt
Function   STWSystemDirectory
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno de Execução da função
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWSystemDirectory(cBuffer)
Local nRet := -1

DEFAULT cBuffer := space(500)

nRet := oImpBWECF:SystemDirectory(@cBuffer)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRecCRO
Function   STWRecCRO
@type	 Function
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	lRet, lógico, estacao setada ?
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRecCRO()
Local cCRO := space(TamSX3("LG_CRO")[1])
Local nRet := -1
Local lRet := .F.

//Tratamento para ECF Emulator, que não tem controle de CRO
If "EMULATOR" $ Upper(AllTrim(STFGetStat("IMPFISC")))
	cCRO := AllTrim(STFGetStat("CRO"))
	nRet := 0	
	If Empty(cCRO)
		cCRO := "1"
	EndIf
Else
	nRet := STWPrinterStatus( "23", @cCRO )
EndIf

If nRet == 0  .AND. !Empty(cCRO)
	lRet := STFSetStat({{ "CRO", cCRO}})
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWRemoveASC0
Function   STWRemoveASC0
@author  Varejo
@version 	P11.8
@since   	11/07/2012
@return  	cRet
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STWRemoveASC0(cBuffer, cChar)
Local nFor := 0 		// Contador
Local cRet := ""		// Retorno

Default cBuffer := ""
Default cChar   := " "

For nFor := 1 To Len(cBuffer)
	If Asc(SubStr(cBuffer, nFor, 1)) == 0
		cRet += cChar
	Else
		cRet += SubStr(cBuffer, nFor, 1)
	EndIf
Next nFor

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} 
Carrega aliquotas da impressora fiscal para aIcms

@author  Varejo
@version 	P11.8
@since   	11/07/2012
@return  	cRet
@obs
@sample
*/
//-------------------------------------------------------------------
Function STWSetAliq(cTipo, aAliq)
Local nRet := -1				// Retorno das funcoes da impressora
Local cAliquotas := Space(100)	// Armazena as aliquotas
Local nPos := 0					// Tamanho da string da aliquota
Local aDados := {}				// Dados retornados pelo ECF

If PCount() = 0
	cTipo = 'ICMS'
Endif

aAliq := {}

If 'SCHALTER' $ STFGetStat( 'IMPFISC' ) 

	nRet := STWGetAliq(@cAliquotas)	
	   
Else 

	If cTipo == 'ICMS'
		nRet := STWGetAliq(@cAliquotas)
	Else
		nRet := STWISSGetAli(@cAliquotas)
	EndIf
	
End  

While .T.
	nPos := At('|',cAliquotas)
	If nPos > 0
		aAdd( aAliq, { Val(SubStr(cAliquotas,1,nPos-1)) } )
		cAliquotas := SubStr(cAliquotas,nPos+1,Len(cAliquotas))
	Else
		If !Empty( cAliquotas )
			aAdd( aAliq, { Val(cAliquotas) } )
		Endif
		exit
	Endif
End

Return nRet  


//-------------------------------------------------------------------
/*/{Protheus.doc} STWMenuFiscReport
Function    relatorio gerencial
@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWMenuFiscReport( cTexto ,nVias, cTotalizer )
Local nRet 		:= -1

Default cTexto	:= ""
Default nVias	:= 0

If STWCheckpaper(.T.)
	STWLjPrintlCOO(@nRet)
	nRet := oImpBWECF:MenuFiscReport( cTexto ,nVias, cTotalizer)
EndIf

STDGrvMdz("RG") //PAF-ECF: Armazena na tabela de apoio(MDZ), emissão de relatório gerencial

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWDownMF
Download da Memoria Fiscal
@param   	Nil
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWDownMF(cTipo,cDadoIni,cDadoFinal)
Local nRet 		:= -1    //Retorno
Local cArqMF	:= "MFISCAL"
Local cArqExt	:= ""
Local cNomArq	:= ""
Local cSerieIF	:= AllTrim(STFGetStat("SERPDV"))
Local cPathArq	:= ""

nRet := oImpBWECF:DownMF(cTipo,cDadoIni,cDadoFinal)

If nRet == 0 .And. STBIsPaf()
	STBFMGerPath( @cPathArq )
	
	/*Para Arquivo MF*/
	cNomArq := cSerieIF + "_"
	cNomArq += Dtos(Date()) + "_"
	cNomArq += StrTran( Time(), ":")
	cArqExt := ".BIN"

	If File(cPathArq + cArqMF + ".BIN")
		__CopyFile(cPathArq + cArqMF + ".BIN", cPathArq + cNomArq + cArqExt)
		STBFMSignPaf(cPathArq + cNomArq + cArqExt,.F.,.T.)
		FErase(cPathArq + cArqMF + ".BIN")
		MsgAlert("Arquivo Gerado com sucesso - Tipo MF")
	Else
		LjGrvLog(NIL,"Arquivo de MF não localizado. Verifique")
		If lHomolPaf
			Conout("Arquivo de MF não localizado. Verifique")
		EndIf
	EndIf
EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWSetInfoCNPJ
Function CNPJ informado no Cupom Fiscal?
@param   	lInfoCNPJ
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	0
@obs
@sample
/*/
//-------------------------------------------------------------------

Function STWSetInfoCNPJ(lInfoCNPJ)

oImpBWECF:lInfoCNPJ := lInfoCNPJ

Return 0


//-------------------------------------------------------------------
/*/{Protheus.doc} STWRedZDat
Function Captura os Dados da Redução
@param   	cBuffer - Buffer
@author  	Varejo
@version 	P11.8
@since   	13/06/2012
@return  	nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWRedZDat(cBuffer)

Local nRet := -1        //Return

Default cBuffer	:= ""

nRet := oImpBWECF:RedZData( @cBuffer )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWCancelBound
Function   Cancela Comprovante de Credito e Debito (CCD)
@param     cSupervisor - Supervisor
@author    Varejo
@version   P11.8
@since     30/10/2014
@return    nRet - Retorno do Equipamento
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWCancelBound( cCpfCnpj, cCliente, cEndereco, cMensagem, cCOOCCD  )

Local nRet			:= -1
Local cRet			:= ""

Default cCpfCnpj	:= ""
Default cCliente	:= ""
Default cEndereco	:= ""
Default cMensagem	:= ""
Default cCOOCCD	:= ""


If STWCheckpaper(.T.)

	nRet := STWPrinterStatus('5', @cRet )

	//Restaura o valor da variavel nRet, de acordo com a declaracao
	nRet := -1

	nRet := oImpBWECF:CancelBound(cCpfCnpj, cCliente, cEndereco, cMensagem, cCOOCCD )

EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWActivePrinter
Function   Verifica se o ECF esta ativo para operações no dia corrente.
@author    Varejo
@version   P11.8
@since     27/04/2015
@return    lRet	- Retorno '.T.' caso esteja ativa/apta a ser utilizada (Redução Z não realizada) 
					- Retorno '.F.' Caso esteja passiva, não podendo ser mais utilziada no dia (Redução Z ja realizada)
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STWActivePrinter(lExibeMsg) 

Local lRet			:= .F.	//Retorno da função
Local cDtEcf		:= ""	//Data do dia do ECF
Local cPdv			:= ""	//Numero do PDV
Local dDataAtual	:= Date()

Default lExibeMsg	:= .F.	//Exibe mensagem de alerta?

If !lEmitNfce 

	If lEcfOperante == Nil .Or. dDataAtual <> dDataOperante
			
		//Verificando se esta pendente a Redução Z.
		If	STWPrinterStatus( '8', '') == 10

			cMsgOperation := "A Redução Z está pendente!" //"A Redução Z está pendente!"

		//Verificando se ja foi realizada a Redução Z.
		ElseIf STWPrinterStatus( '2', @cDtEcf ) == 0

			cPdv := STFGetStation("PDV")

			SFI->(DbSetOrder(1)) //FI_FILIAL+DToS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ
			lRet := !SFI->(DBSeek( xFilial("SFI")+DToS(cToD(cDtEcf))+cPdv ))
		
			cMsgOperation := "Redução Z já realizada para o dia de hoje!" //"Redução Z já realizada para o dia de hoje!"
		EndIf

		dDataOperante := dDataAtual
		lEcfOperante := lRet
		
		If lEcfOperante
			cMsgOperation := ""
		EndIf

	Else
		lRet := lEcfOperante
	EndIf

	If lExibeMsg .And. !lRet
		ConOut(cMsgOperation)
		STFMessage(ProcName(),"STOP",cMsgOperation)
		STFShowMessage(ProcName())
	EndIf

Else
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STWSetEcfOperante
Function   Chamado apos a redução Z para que seja realizada a verificação na próxima chamada.
@author    Varejo
@version   P11.8
@since     16/07/2015
@return    Nil
@obs       Tratamento necessário para quando for feita a Red. Z e uso do sistema no mesmo dia. Usado 
           no fonte STWZReduction.PRW.
@sample
/*/
//-------------------------------------------------------------------
Function STWSetEcfOperante()
lEcfOperante := Nil
Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} STWGetMsgOperante
Function  Retorna a mesagem de erro 
@author    Varejo
@version   P11.8
@since     16/07/2015
@return    Nil
@obs       Tratamento necessário para quando for feita a Red. Z e uso do sistema no mesmo dia. Usado 
           no fonte STWZReduction.PRW.
@sample
/*/
//-------------------------------------------------------------------
Function STWGetMsgOperante()
Return cMsgOperation

//--------------------------------------------------------
/*/{Protheus.doc} STWNFCEInfo
Função Responsável por consultar informação estendida da nfce
@param cInfo - Informação de consulta
@param cDefault - Valor default
@author  	Varejo
@version 	P11.8
@since   	08/05/2015
/*/
//-------------------------------------------------------
Function STWNFCEInfo(cInfo, cDefault)

Default cInfo := ""
Default cDefault := ""

nRet := oImpBWECF:NFCe_Info(cInfo, @cDefault)

Return nRet

/*{Protheus.doc} STWCPFGRec
Retorna no vetor as variaveis que serao utilizadas para 
setar os dados do cliente no cupom fiscal.

@author  	Anderson Machado
@version 	P12.17
@since   	16/10/2019
@return  	
			lDadosInf	Variavel de controle se digiou o CPF/CNPJ
			cCNPJInf	CPF digitado
			cNomeInf	Nome Cliente Digitado
			cEndInf		Endereco 
			cPlacaInf	Placa do veiculo
			nKmInf		Km do veiculo
/*/
Function STWCPFGRec()
Local aRet := {lDadosInf, cCNPJInf, cNomeInf, cEndInf}

Return aRet 


//--------------------------------------------------------
/*/{Protheus.doc} STWRetDll
Retorna o nome da dll para linux ou windows (32/64)

@author  	Bruno Almeida
@version 	12.1.2410
@since   	09/05/2025
/*/
//-------------------------------------------------------
Function STWRetDll()

Local lLinux := IIF(!IsBlind(),"LINUX" $ UPPER(GetRmtInfo()[2]),.F.)
Local cRet	 := ""

If lLinux
	cRet := "libsigaloja_linux.so"
Else
	cRet := IIF(lIsRmt64,"SIGALOJA64.DLL","SIGALOJA.DLL")
EndIf

Return cRet

/*/{Protheus.doc} STWTipoCom
Retorna o tipo de comunicação da impressora
@type  Function
@author joao.marcos
@since 20/05/2025
@version v1.0
@param cPort, character, Porta de comunicação da impressora
@return nTipo, numeric, tipo de comunicaçao da impressora
/*/
Function STWTipoCom(cPort)
Local nTipo := "1"
Return nTipo

/*/{Protheus.doc} STWModelImp
Retorna o modelo da impressora no formeto que a dll espera
@type  Function
@author joao.marcos
@since 20/05/2025
@version v1.0
@param cModel, character, Modelo da impressora
@return cRetModel, character,  modelo da impressora no formeto que a dll espera
/*/
Function STWModelImp(cModel) 
Local cRetModel := ""

Do Case
	Case Upper(AllTrim(cModel)) == "ELGIN I9"
		cRetModel := "i9"
	Case Upper(AllTrim(cModel)) == "ELGIN I8"
		cRetModel := "i8"
	Case Upper(AllTrim(cModel)) == "BEMATECH MP-4200 ADV" .OR. Upper(AllTrim(cModel)) == "BEMATECH MP-4200 TH"
		cRetModel := "MP-4200"
	Case Upper(AllTrim(cModel)) == "BEMATECH MP-4200 HS"
		cRetModel := "MP-4200 HS"
	// Futuramente serao implementados novos modelos
EndCase

LjGrvLog(NIL,"Modelo da impressora selecionada", cRetModel)

Return cRetModel

/*/{Protheus.doc} STWCPrtUSB
Carrega a Porta USB que a Impressora nao fiscal foi identificada em ambientes com SO Linux
@type  Function
@author joao.marcos
@since 25/05/2025
@version v1.0
@param cModel, character, Modelo da Impressora
@return cRetPrtUSB, character, porta que a impressora esta identificada
/*/
Function STWCPrtUSB(cModel, cPort, lGrvTab)
Local nHandle		:= -1
Local cPortaAtu		:= Iif(!Empty(cPort), cPort, STFGetStation("PORTA")) // PORTA
Local aOptPortas	:= {"/dev/usb/lp","/dev/ttyACM","/dev/ttyUSB"}
Local nX 			:= 0
Local nY 			:= 0
Local nRetDll		:= -1
Local cDllSigloj	:= "libsigaloja_linux.so"

Default lGrvTab := .F. // Indica se deve ou não gravar o valor na tabela SLG, LG_PORTA

nHandle := ExecInDLLOpen( cDllSigloj )

If nHandle <> -1
	If !Empty(cPortaAtu) 
		nRetDll := ExeDLLRun2(nHandle, 131, STWTipoCom() + "," + STWModelImp(cModel) + "," + cPortaAtu + "," + "0" )
		nRetDll := Iif(nRetDll == -6, 0, nRetDll) // status -6 -> conexao ja aberta
	EndIf
EndIf

Return AllTrim(cPortaAtu)
