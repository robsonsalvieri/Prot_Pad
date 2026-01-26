#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STBCANCELSALE.CH"

Static lLjcFid		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()			//Indica se a recarga de cartao fidelidade esta ativa
Static cSiglaSat	:= IIF( ExistFunc("LjSiglaSat"),LjSiglaSat(), "SAT" )	//Retorna sigla do equipamento que esta sendo utilizado
Static lPdvOn		:= ExistFunc("STFPdvOn") .AND. STFPdvOn() 				// Verifica se é PDV-Online

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSIsProgressSale
Verifica se a venda está em andamento

@param 	 nenhum
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se a venda está em andamento ou não
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSIsProgressSale()

Local lRet 				:= .F.				// Retorna se a venda está em andamento ou não
Local aRet				:= {}				// Armazena retorno impressora
Local aIsOpenReceipt   	:= { "5" , "" }	// Armazena retorno se o cupom está aberto

/*/
	Se usa impressora Fiscal, verifica cupom aberto
/*/
If STFUseFiscalPrinter() 

	/*/
		Verifica cupom aberto
	/*/	
	aRet := STFFireEvent( 	ProcName(0)						, ; // Nome do processo
   							"STPrinterStatus"						, ; // Nome do evento
					   		aIsOpenReceipt	  					)		
					   						
	If Len(aRet) > 0 .AND. ValType(aRet[1]) == "N"						    
		If aRet[1] == 7
  			lRet := .T.	// Aberto
  		Else
   			lRet := .F.	// Fechado
		EndIf
	EndIf
	
	/*/
		Verifica se existe venda com apenas itens não-fiscais
	/*/
	If !lRet
	
		If STDPBLength("SL2") > 0
			
			If !STBExistItemFiscal()			
				lRet := .T.
			EndIf
			
		EndIf	
		
	EndIf

Else 
	
	/*/
		Verifica se existe item registrado
	/*/	
	If STDPBLength("SL2") > 0		
		lRet := .T.	
	Else	
		lRet := .F.		
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSNumPrinter
Busca o Ultimo Cupom da Impressora

@param	 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   cNumDoc						Retorna o ultimo cupom da impressora
@obs     								Se der erro na impressora retorna "ERROR", se nao usa impressora retorna vazio
@sample
/*/
//-------------------------------------------------------------------
Function STBCSNumPrinter()

Local cNumDoc 		:= ""					// Retorno funcao
Local aPrinter		:= {}					// Armazena retorno da impressora
Local aDados 			:= { "" , Nil }		// Dados do evento

aPrinter := STFFireEvent( ProcName(0) , "STGetReceipt" , aDaDos )
			
If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aDados) < 1     

	STFMessage("STCancelSale","STOP", STR0003) //Falha na obtenção do cupom
	STFShowMessage("STCancelSale") 
	
	cNumDoc := "ERROR"

Else	
	cNumDoc := aDados[1]	
EndIf

Return cNumDoc


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSGetPDV
Busca o PDV atual

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   aRet					Retorna se obteve e a numeração do PDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSGetPDV()

Local aPrinter	:= {}			// Armazena retorno da impressora
Local aRet		:= {}			// Retorno funcao
Local aPDV		:= {""}			// Retorno evento get PDV

If STFUseFiscalPrinter()
	/*/
		Get PDV Impressora
	/*/
	aPrinter := STFFireEvent( ProcName(0) , "STGetPDV" , aPDV )
			
	If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aPDV) < 1     
	
		STFMessage("STCancelSale","STOP", STR0003) //Falha na obtenção do cupom
		STFShowMessage("STCancelSale")
		aRet := { .F. , "" }
		
	Else	
		aRet := { .T. , PadR( AllTrim(aPDV[1] ) , TamSx3("L1_PDV")[1] , " " ) }		
	EndIf 
	
Else    
	aRet := { .T. , STFGetStat("PDV") }		
EndIf
		
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCanChoose
Verifica se pode escolher a venda a ser cancelada

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se pode escolher a venda a ser cancelada
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCanChoose()

Local lRet := .F.		//	Retorna se pode escolher a venda a ser cancelada

If STFGetCfg("lCanChoose")
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSFiCanCancel
Verifica se é premitido cancelar vendas Finalizadas

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se é permitido cancelar vendas finalizadas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSFiCanCancel()

Local lRet := .T.			// Retorna se é permitido cancelar vendas finalizadas

If STFGetCfg("lFiCanCancel")
	lRet := .F.
	STFMessage("STCancelSale","STOP", STR0004) //Comprovantes de vendas anteriores nao podem ser cancelados
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSCanCancel
Verifica se pode Cancelar a Venda em andamento

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return   aRet Retorna array com informacoes do cancelamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSCanCancel(cGetDoc, lProfile, cGetSerie, cL1Num)
 
Local aRet				:= {}																	// Retorno funcao
Local lCanCancel			:= .F.																// Retorna se pode cancelar a venda
Local lIsProgressSale	:= .F.																	// Define se a venda está em andamento
Local aProfile			:= {}																	// Armazena retorno permissao do usuario
Local cNumLastSale		:= ""																	// Numeração da ultima venda
Local cLastDoc			:= ""																	// Numeração do ultimo doc do banco
Local cDocPrinter		:= ""																	// Numeraçãp do Doc atual da impressora
Local cPDV				:= STFGetStation("PDV")    												// Numero do PDV
Local cSuperior			:= ""
Local cDocPed			:= ""																	//Doc da serie nao fiscal
Local lTemCCCD			:= .F.
Local lTemPD			:= .F.
Local cDocRPS 			:= "" 																	//Cancelamento RPS
Local cSerRPS 			:= "" 																	//Cancelamento RPS
Local lPdvOn			:= ExistFunc("STFPdvOn") .AND. STFPdvOn() 								// Verifica se é PDV-Online

Default cGetDoc			:= ""
Default lProfile		:= .T.
Default cGetSerie		:= STFGetStation("SERIE")
Default cL1Num			:= ""

If STBOpenCash() 

	If lProfile
		aProfile	:= STFProfile( 8 )
		lCanCancel	:= aProfile[1]
		cSuperior	:= aProfile[2]
	Else
		lCanCancel := .T.
	EndIf 	 
	
	If lCanCancel
	    
		lIsProgressSale := STBCSIsProgressSale() // Venda em Andamento?
		
		/*/
			Venda em andamento
		/*/
		If lIsProgressSale
				
			If STFGetCfg("lCanActSale")
			
				If STDPBLength("SL2") == 0 // Permitido apenas o cancelamento da venda corrente com mais de um item lancado
					lCanCancel := .F.
					STFMessage("STCancelSale","STOP", STR0005) //Permitido apenas o cancelamento da venda corrente com mais de um item lançado
				EndIf
				
			EndIf
		    
		   If lCanCancel
		   
				If STFUseFiscalPrinter()
				
					cDocPrinter := STBCSNumPrinter()
					
					If cDocPrinter == "ERROR" 										
						lCanCancel := .F.												
					Else					
						lCanCancel 	:= .T.
						cLastDoc	:= cDocPrinter					
					EndIf
					
				EndIf
				
			EndIf
			
		Else
			/*/
				Venda Finalizada
			/*/		
			
			If !Empty(cGetDoc)	
				cLastDoc		:= cGetDoc
				cNumLastSale:= Iif((lPdvOn .And.!Empty(cL1Num)), cL1Num, STDCSNum(cGetDoc,cPDV,,cGetSerie))
			Else				
				cNumLastSale 	:= STDCSLastSale()	
				cLastDoc		:= STDCSDoc( cNumLastSale )
			EndIf
			
			If Empty(cLastDoc) .And. ExistFunc("STDGetDocP")
				//Recupera o numedo do documento nao fiscal
				cDocPed := STDGetDocP()
				cDocRPS := STDGtDocRPS()
				cSerRPS := STDGtSerRPS()
			ElseIf ExistFunc("STDGtDocRPS") .And. (cLastDoc == STDGtDocRPS() .And. ExistFunc("STDGetDocP"))
				//Recupera o numedo do documento nao fiscal após processamento do LJGRVBATCH pois alimenta o campo L1_DOC. 
				cDocPed := STDGetDocP()
				cDocRPS := STDGtDocRPS()
				cSerRPS := STDGtSerRPS()
			EndIf
			
			If STFUseFiscalPrinter()
			
				cDocPrinter := STBCSNumPrinter()
				
				If cDocPrinter == "ERROR"				
					lCanCancel := .F.					
				EndIf 
				
				If lCanCancel
				
					If !STBCanChoose()
					
						If AllTrim(cLastDoc) == AllTrim(cDocPrinter)					    	
					    	lCanCancel	:= .T.
					    	cLastDoc	:= cDocPrinter
						ElseIf FindFunction("STDCancTef") .And. STDCancTef(cNumLastSale, @lTemCCCD,@lTemPD)
					    	lCanCancel	:= .T.

						Else
							lCanCancel := .F.
							STFMessage("STCancelSale","STOP", STR0006) //A numeração do último cupom do ECF não corresponde com a última venda. Não será feito o cancelamento do cupom
						EndIf
					
					EndIf 
					
				EndIf
				
			EndIf
			
		EndIf

	Else
		STFShowMessage("STFProfile")  // "Acesso Negado. O caixa XX não tem permissão para executar a seguinte operação: Cancelamento Cupom"
	EndIf
	
Else

	STFMessage("STCancelSale","STOP", STR0007) // Caixa Fechado
	
EndIf

STFShowMessage("STCancelSale")

If lCanCancel

	AADD( aRet , lCanCancel			)
	AADD( aRet , lIsProgressSale	)
	AADD( aRet , cSuperior			)
	AADD( aRet , cLastDoc	   		)
	AADD( aRet , cNumLastSale  		)
	AADD( aRet , cDocPed  			)
	AADD( aRet , cGetSerie 			)
	AADD( aRet , lTemCCCD 			)
	AADD( aRet , lTemPD 			)
	AADD( aRet , cDocRPS 			)//10º
	AADD( aRet , cSerRPS 			)//11º
	
Else 

	AADD( aRet , .F.				)
	AADD( aRet , .F.				)
	AADD( aRet , ""					)
	AADD( aRet , ""			   		)
	AADD( aRet , ""			   		)
	AADD( aRet , ""			   		)
	AADD( aRet , ""		 			)
	AADD( aRet , lTemCCCD		 	)
	AADD( aRet , lTemPD		 		)
	
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSCanLastCancel
Valida se pode cancelar Ultimo Cupom

@param   cNumDocPrint			Numero do documento da Impressora
@param   cNumSale					Numero da Venda a ser cancelada
@param   cNumDoc					Numero do Documento da venda a ser cancelada
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se pode cancelar
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBCSCanLastCancel( cNumDocPrint , cNumSale , cNumDoc )

Local lRet 				:= .T.				// Retorna se Pode Cancelar

Default cNumDocPrint  	:= ""
Default cNumSale  		:= ""
Default cNumDoc  		:= ""

ParamType 0 Var  cNumDocPrint 	As Character	 Default ""
ParamType 1 Var  cNumSale 		As Character	 Default ""
ParamType 2 Var  cNumDoc 		As Character	 Default ""

If STFGetCfg("lVldCanLastSale")  // Configuração para Bloquear se a ultima venda nao eh o Ultimo Cupom
	// Num da Impressora Diferente do Num da ultima venda Bloqueia
	If cNumDocPrint <> cNumDoc
		lRet := .F.
		STFMessage("STCancelSale","STOP", STR0008) //"O último cupom do ECF não corresponde com a última venda. Não será feito o cancelamento do cupom.")
	Endif
EndIf

Return  lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSUseDocChoose
Verifica se escolhe venda a ser Cancelada a Partir do L1_DOC

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet					Retorna se escolhe por DOC
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STBCSUseDocChoose()

Local lRet := .F.		// Retorna se escolhe por DOC

// Verifica se escolhe a venda a partir do Ultimo L1_DOC
If STFGetCfg("lseDocChoose")
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSFactura
Valida se Cancela a Venda verificando se pertence a uma Factura Global

@param   cNumSale					Numero da Venda a ser cancelada
@param   cNumDoc					Numero do documento
@param   cPDVPrint				Numero do PDV
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se Pode Cancelar a Venda
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSFactura( cNumSale , cNumDoc , cPDVPrint )

Local lRet				:= .T.			// Retorna se Pode Cancelar a Venda
Local aSale				:= {}			// Armazena dados da venda para analise de factura global
Local oRemoteCall		:= NIL			// Retorna da chamada da funcao na Retaguarda

Default cNumSale  		:= ""
Default cNumDoc  		:= ""
Default cPDVPrint  		:= ""

ParamType 0 Var  cNumSale 		As Character	 Default ""
ParamType 1 Var  cNumDoc 		As Character	 Default ""
ParamType 2 Var  cPDVPrint 	As Character	 Default ""

If STFGetCfg("lGlobFact") // Verifica Factura Global

	// Busca informações da Venda para analise de Factura Global
	aSale := STDCSFactura( cNumDoc , cPDVPrint ) 
	
	oRemoteCall := FWCallFunctionality("FR271CPGlobal", {aSale[1], aSale[2], aSale[3], aSale[4]})
	If oRemoteCall:nStatusCode < 0
		lRet := STFMessage("STCancelSale","YESNO", STR0009) //"A conexao com o servidor de BackOffice por alguma razao se encontra interrompida. Esse cupom pode pertencer a uma Nota Fiscal. Assim mesmo deseja cancelar o cupom de numero " + cNumDoc)	
	Else
		aRet := oRemoteCall:uResult
		lRet := aRet[2]
		Do Case 
			Case AllTrim(aRet) == "GLOBAL"
				STFMessage("STCancelSale","STOP", STR0010) //O cupom nao podera ser cancelado porque pertence a uma Nota Fiscal Global
			Case AllTrim(aRet) == "NFCUPOM"
				STFMessage("STCancelSale","STOP", STR0011) //O cupom nao podera ser cancelado porque foi gerada uma Nota Fiscal sobre cupom
			Case AllTrim(aRet) == "QTDEDEV"
				STFMessage("STCancelSale","STOP", STR0012) //Cupom não poderá ser cancelado, porque foi realizado devolução de um ou mais itens desta venda
			Case AllTrim(aRet) == "BAIXADO"
				STFMessage("STCancelSale","STOP", STR0013) //O cupom nao podera ser cancelado porque ja foi gerada a baixa
		EndCase
	EndIf
EndIf
				
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSCancCupPrint
Manda o cancelamento para a impressora

@param   cSupervisor				ID do Usuario Supervisor
@param   cNumDoc					Numero do documento
@param   cNumSale					Numero da Venda
@param   lNFCETSS					NFCe Transmitida pelo TSS?
@param   lForceCancel				Força cancelamento da Venda?
@param   cTipoCanc					Tipo de Cancelamento
@param   lInutiliza					Inutiliza NFCe?
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						Retorna se cancelou na impressora
/*/
//------------------------------------------------------------------- 
Function STBCSCancCupPrint( cSupervisor , cNumDoc, cNumSale, lNFCETSS,;
 							lForceCancel, cTipoCanc, lInutiliza, cSerie, lTemCCCD,lTemPD)
Local lRet			:= .T.				// Retorna se cancelou na impressora
Local aPrinter		:= {}				// Armazena Retorno da impressora
Local cCOOCCD		:= ""				// Armazena o Comprovante vinculado (CCD) a ser estornado
Local cNumCup		:= ""				// Armazena o numero do Comprovante vinculado (CCD) menos 1
Local cCpfCnpj		:= ""				// Cnpj/CPF do cliente da venda para o estorno do CCD
Local cMensagem		:= ""				// Mensagem a ser impressa no estorno do CCD
Local nCCDs			:= 1				
local nX								

Default cNumSale	:= ""
Default cSupervisor	:= ""
Default cNumDoc		:= ""
Default lNFCETSS	:= .T.
Default lForceCancel:= .F.
Default cTipoCanc	:= ""
Default lInutiliza	:= .F.
Default cSerie		:= STFGetStation("SERIE")
Default lTemCCCD	:= .F.
Default lTemPD		:= .F.

LjGrvLog( "L1_NUM: "+cNumSale+"L1_DOC: "+cNumDoc, "Cancelamento de venda" )  //Gera LOG

If STFUseFiscalPrinter()

	If lTemCCCD .And. lTemPD
		nCCDs := 2
	EndIf 

	//Solicitar o cancelamento do CCD antes do cancelamento do cupom se tiver.
	cCOOCCD := STBCSNumPrinter()
	cNumCup := PADR(StrZero(Val(AllTrim(cCOOCCD))-nCCDs,Len(cCOOCCD)),TamSX3("L1_DOC")[1])

	If !Empty(cNumDoc) .And. AllTrim(cNumDoc) == AllTrim(cNumCup)

		cCpfCnpj  := AllTrim(STDCSLastSale("L1_CGCCLI"))
		cMensagem := "Cancelamento de Comprovante de Credito e Debito"

		For nX := 1 To nCCDs
			aPrinter  := STFFireEvent( ProcName(0) , "STCancelBound" , {cCpfCnpj, "" , "", cMensagem, StrZero(Val(cNumCup) + nX,Len(cCOOCCD)) } )

			If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0
				lRet := .F.
				STFMessage("STCancelSale","STOP", STR0022) //Erro com a Impressora Fiscal. Não foi efetuado o cancelamento do Comprovante de Credito e Debito (CCD).
			EndIf
		Next
	EndIf

	If lRet
		aPrinter := STFFireEvent( ProcName(0) , "STCancelReceipt" , {cSupervisor} )
		If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0
			lRet := .F.
			STFMessage("STCancelSale","STOP", STR0014) //Erro com a Impressora Fiscal. Não foi efetuado Cancelamento do Cupom
		Else
			lRet := .T.
		EndIf
	EndIf
Else        
	/*/
		Se nao utiliza impressora fiscal, retornar .T.
	/*/
	lRet := .T.
	If !lNFCETSS .AND. ExistFunc("LjDNFCeCanc")
		lRet :=  LjDNFCeCanc( @cNumDoc, @cNumSale, lNFCETSS, @cTipoCanc,@lInutiliza, cSerie )
		If lForceCancel .AND. !lRet
			lRet := .T.
			LjGrvLog( "L1_NUM: "+cNumSale+"L1_DOC"+cNumDoc, "Ocorreu erro no cancelamento da NFCe mas a venda será excluída" )  //Gera LOG
		EndIf
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSCancGP
Cancelar Vale Presente

@param   cNumSale					Numero da Venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						Retorna se cancelou VPs
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSCancGP( cNumSale )

Local lRet				:= .T.					// Retorna se cancelou VPs
Local uResult		:= NIL						// Retorno da chamada da funcao na Retaguarda
Local aGiftVoucher		:= {}					// Armazena VP a estornar

Default cNumSale  	:= ""

ParamType 0 Var  cNumSale 	As Character	 Default "" 

aGiftVoucher := STDCSGiftVoucher( cNumsale ) // Busca VPs na Venda

If Len(aGiftVoucher) > 0

	If STBRemoteExecute("LjVpAtiva" ,{aGiftVoucher}, NIL,.T.	,@uResult)
		lRet := uResult
	EndIf
	
EndIf	

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSChkStatusPrint
Verifica STATUS Impressora

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return   lRet						Retorna se STATUS da impressora está ok
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSChkStatusPrint()

Local lRet				:= .T.					// Retorna se STATUS da impressora está ok
Local aRet				:= {}					// Armazena retorno impressora
Local aStatusPrint   	:= { "9" , "" }		// Armazena retorno Impressora

/*/
	Se usa impressora Fiscal, verifica cupom aberto
/*/
If STFUseFiscalPrinter() 

	/*/
		Verifica Status
	/*/	
	aRet := STFFireEvent( 	ProcName(0)					   		, ; // Nome do processo
   							"STPrinterStatus"							, ; // Nome do evento
					   		aStatusPrint	  							)	
					   							
	If Len(aRet) > 0 .AND. ValType(aRet[1]) == "N"		
					    
		If aRet[1] == 0
  			lRet := .T.
  		Else
   			lRet := .F.
   			STFMessage("STCancelSale","STOP", STR0015) //"Erro com a Impressora Fiscal. Operação não efetuada
		EndIf
		
	EndIf
	
Else
	lRet := .T.
EndIf
	 
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSQuestion
Formula a perunta de confirmação de cancelamento

@param   lIsProgressSale	Define se a venda está em andamento
@param   lAllNotFiscal		Todos os itens não fiscais
@param   cNumber			Numeração a ser cancelada
@author  Varejo
@version P11.8
@since   29/03/2012
@return   cQuestion			Retorna Pergunta de confirmação
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSQuestion( lIsProgressSale , lAllNotFiscal , cNumber )

Local cQuestion				:= ""		// Mensagem

Default lIsProgressSale		:= .F.
Default lAllNotFiscal		:= .F.
Default cNumber				:= ""

ParamType 0 Var  lIsProgressSale 	As Logical	 Default .F.
ParamType 1 Var  lAllNotFiscal 		As Logical	 Default .F.
ParamType 2 Var  cNumber   			As Character Default ""

If lIsProgressSale
	/*/
		Venda em andamento
	/*/
	If STFUseFiscalPrinter() 
	
		If STBExistItemFiscal() 		
			cQuestion := STR0016 //Venda em andamento. Realiza o CANCELAMENTO deste Cupom Fiscal?		
		Else		
			cQuestion := STR0017 //Venda em andamento. Realiza o CANCELAMENTO deste Cupom Não Fiscal?			
		EndIf
		
	Else
		
		cQuestion :=  STR0018 //Venda em andamento. Realiza o CANCELAMENTO desta venda?
		
	EndIf
	
Else

	/*/	
		Venda Finalizada
	/*/
	If STBCanChoose()	
		cQuestion := STR0019 + cNumber + ")" //"Deseja cancelar o último cupom emitido (Numero: "		
	Else
		
		If STFUseFiscalPrinter()
		
			If lAllNotFiscal		
				cQuestion := STR0020 //"Realiza o CANCELAMENTO do Cupom não Fiscal. "				
			Else			
				cQuestion := STR0021 + cNumber + " ?"	//"Realiza o CANCELAMENTO do Cupom Fiscal nº "		
			EndIf
		
		EndIf	
	
	EndIf
	
EndIf

Return cQuestion


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSTotalSale
Formula a perunta de confirmação de cancelamento

@param   lIsProgressSale	Define se a venda está em andamento
@param   cNumberSale		Numeração a ser cancelada (L1_NUM)
@author  Varejo
@version P11.8
@since   29/03/2012
@return   nTotalSale		Retorna o total da venda a ser cancelada
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSTotalSale( lIsProgressSale , cNumberSale )

Local nTotalSale			:= 0 				// Retorna o total da venda a ser cancelada
Local oTotal				:= STFGetTot()		// Totalizador	

Default lIsProgressSale		:= .F.
Default cNumberSale			:= ""

ParamType 0 Var  lIsProgressSale 	As Logical	 Default .F.
ParamType 1 Var  cNumberSale		As Character Default ""


If lIsProgressSale

	nTotalSale := oTotal:GetValue("L1_VLRTOT") 

Else
	
	If !Empty(cNumberSale)
		
		nTotalSale := STDCSTotalSale(cNumberSale)
		
	EndIf
	
EndIf

Return nTotalSale


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSNumberSale
Formula a perunta de confirmação de cancelamento

@param   lIsProgressSale	Define se a venda está em andamento
@param   cDocSale			Numeração do Documento(L1_DOC)
@author  Varejo
@version P11.8
@since   29/03/2012
@return   cDocSale			Retorna o documento
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBCSNumberSale( lIsProgressSale , cDocSale )

Default lIsProgressSale		:= .F.
Default cDocSale			:= ""

ParamType 0 Var  lIsProgressSale 	As Logical	 Default .F.
ParamType 1 Var  cDocSale		As Character Default ""

If lIsProgressSale

	cDocSale := STDGPBasket("SL1","L1_DOC")	

Else

	If Empty(cDocSale)
   		
   		/*/
   			Busca o DOC a partir da ultima venda
   		/*/		
		cDocSale := STDCSDoc( STDCSLastSale() )		
		
	EndIf

EndIf

Return cDocSale

//-------------------------------------------------------------------
/*/{Protheus.doc} STBActionCancel
Ação botão de cancelar venda

@param		cGetCanc	Código da venda 
@author	Varejo
@version	P11.8
@since		17/04/2015
@return   
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Function STBActionCancel(cGetCanc, cGetSerie)

Local lEmitNFCe  := STBGetNFCE() 				//Valida se é NFC-e ou não
Local cDoc       := "" 							//Numero do documento
Local lUseSat    := STFGetCfg("lUseSAT", .F.) 	//Utiliza SAT
Local cEspeLast  := STDCSLastSale("L1_ESPECIE") //Especie ultima venda
Local lRet       := .T.
Local cNFisCanc  := "" 							//Doc de cancelamento
Local cRetsx5    := "" 							//Tamanho da serie no SX5
Local cMsg       := "" 							//Mensagem referente ao cancelamento do SAT
Local aInfCanSAT := {}
Local lRet       := .T.
Local aCancel    := STIGetCancel() 				//Retornar o array com as informacoes da venda a ser cancelada
Local lDocNf     := .F. 						//Indica se a venda que esta sendo cancelada eh nao fiscal
Local aProfile   := {} 							//Recebe o retorno do STFProfile
Local lNfe		 := .F.							//Indica se é uma NFe
Local aAreaSL1	 := SL1->(GetArea())
Local oRaas      := Nil
Local oFidelityC := Nil
Local lL1Tel 	 := SL1->(ColumnPos("L1_TEL")) > 0 //Variavel para verificar a existencia do campo L1_TEL
Local lDocRPS 	 := .F. //venda de serviço RPS
Local lExistReg	 := .F. 
Local lChgX5FIL  := ExistBlock("CHGX5FIL")		//Ponto de Entrada CHGX5FIL 
Local cFilSx5	 := ""
Local lREtNfe 	 := .F. 						// Retorno do DBSeek para buscar L1_IMPNF

Default cGetCanc := ""
Default cGetSerie := STFGetStation("SERIE")


If aCancel[4]<>cGetCanc
	STISetCancel(STBCSCanCancel(cGetCanc,,cGetSerie)) //Atualiza a  informacoes da venda a ser cancelada no PDV ONLINE
	aCancel := STIGetCancel()   
Endif

If ValType(aCancel) == "A" .AND. Len(aCancel) > 5 .AND. !Empty(aCancel[6])
	//Se entrar no IF, significa que eh uma venda nao fiscal vale credito ou vale presente
	lDocNf := .T.
EndIf

lDocRPS := ValType(aCancel) == "A" .AND. Len(aCancel) >= 11 .AND. !Empty(aCancel[10]) .AND. !Empty(aCancel[11]) 

If Valtype(lUseSat) = "U"
	lUseSat := .F.
	If lEmitNFCe
		lUseSat := LjUseSat()
	EndIf
EndIf

//Ponto de Entrada ao checar se esse cupom pode cancelar ou não
If ExistBlock("STCANACT")	
	lRet := ExecBlock( "STCANACT",.F.,.F.,{PadL(AllTrim(cGetCanc),TamSX3("L1_DOC")[1], "0")})
	If !lRet
		STIGridCupRefresh() // Sincroniza a Cesta com a interface
		STIRegItemInterface()
		STFMessage(ProcName(), "STOP", "Nao será permitido o cancelamento dessa venda.") //"Nao permitido o cancelamento desta venda."
		STFShowMessage(ProcName())
	EndIf
EndIf

If !STBCSIsProgressSale() 
	DbSelectArea("SL1")
	if lPdvOn .AND. Len(aCancel) >= 5 .AND. !Empty(aCancel[5]) .AND. !lDocRPS
		SL1->(DbSetOrder(1))//L1_FILIAL+L1_NUM 
		lRetNfe := SL1->( DbSeek(xFilial("SL1") + aCancel[5]))
	Else
		SL1->(DbSetOrder(2))//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
		lRetNfe := SL1->(DbSeek(xFilial("SL1")+cGetSerie+cGetCanc))
	Endif 
	If lRetNfe
		lNfe := SL1->L1_IMPNF
	Endif 
Endif 

If !STBCSIsProgressSale() .AND. !STBValCanc()
	lRet:=.F. 
Endif 

//Somente poderá prosseguir com cancelamento de cupom finalizado caso não exista item com reserva
If lRet .AND. !STBCSIsProgressSale() .AND. (lEmitNFCe .OR. lUseSAT)
	lRet:= STBVldItRes(SL1->L1_NUM, SL1->L1_SERIE, SL1->L1_NUMORIG)
Endif 

//Valida se o motivo da Perda de Venda foi informado
If lRet .AND. (lEmitNFCe .OR. lUseSAT) .AND. SuperGetMV ("MV_LJMVPE",,.F.) .AND. ExistFunc("STIVldRsnInf")
	lRet:= STIVldRsnInf()
EndIf 

If lRet .And. lEmitNFCe .And. !STBCSIsProgressSale() .And. (!lUseSat .Or. lNfe)

	If !lDocNf .AND. !lDocRPS
		//Ajusta tamanho caso o usuario ano informe os zeros.
		If lChgX5FIL
			LjGrvLog(NIL, "Antes da execução do PE CHGX5FIL pela rotina LjFilSX5()")   
			cFilSx5	:= LjFilSX5()
			LjGrvLog(NIL, "Depois da execução do PE CHGX5FIL pela rotina LjFilSX5()",cFilSx5 )   
			dbSelectArea("SX5")
			SX5->(dbSetOrder(1))//X5_FILIAL+X5_TABELA+X5_CHAVE
			SX5->(dbSeek(cFilSx5 +'01'+ PADR(cGetSerie, TamSX3("X5_CHAVE")[1])))
			If SX5->(Found())
				cRetsx5 := SX5->X5_DESCRI
			Endif 
		Else 
			cRetsx5 := Tabela("01", AllTrim(cGetSerie) )
		Endif

		If !Empty(cRetsx5)
			cGetCanc := PadL(AllTrim(cGetCanc),Len(AllTrim(cRetsx5)), "0")
		Else
			cGetCanc := PadL(AllTrim(cGetCanc),TamSX3("L1_DOC")[1], "0")
		EndIf
	EndIf

	//verifica o SITUA do documento antes de prosseguir com a exclusao
	If STBSitCanc(cGetCanc, cGetSerie)
		If !lDocNf .AND. !lDocRPS
			if lPdvOn .AND. Len(aCancel) >= 5 .AND. !Empty(aCancel[5]) 
				STICancelSale(cGetCanc, cGetSerie, aCancel[5])
			Else
				STICancelSale(cGetCanc, cGetSerie)
			Endif 
		Else
			If ExistFunc('STWCancNF')
				aProfile := STFProfile( 8 )
				If ValType(aProfile) == 'A' .AND. aProfile[1]
					STWCancNF()
				Else
					LJGrvLog(Nil, "Venda nao foi cancelada porque nao foi informado o superior - L1_DOCPED: ", cGetCanc)
				EndIf
			Else	
				LJGrvLog(Nil, "Venda nao foi cancelada porque nao existe a funcao STWCancNF - L1_DOCPED: ", cGetCanc)				
			EndIf
		EndIf
	EndIf
	
ElseIf lRet .And. lEmitNFCe .And. STBCSIsProgressSale()
	/*Cancela venda quando configurado com nfc-e e esta em andamento*/
	cDoc := STDGPBasket("SL1","L1_DOC")
	STWCancelSale(.T.,,,cDoc, "L1_NUM",,)
	STIGridCupRefresh()
	STIRegItemInterface()	
	
Else 
	
	If lRet .And. lUseSat .And. !STBCSIsProgressSale() 	

		DbSelectArea("SL1")
		
		If lDocRPS .And. cGetCanc == aCancel[10]
			SL1->( DbSetOrder(1) )	//L1_FILIAL+L1_NUM 
			aCancel[5]:= Padr(aCancel[5], TamSx3("L1_NUM")[1])
			lExistReg := SL1->(DbSeek(xFilial("SL1") + aCancel[5]))
		Else
			If lPdvOn .AND. Len(aCancel) >= 5 .AND. !Empty(aCancel[5])
				SL1->(DbSetOrder(1))	//L1_FILIAL+L1_NUM
				lExistReg:= SL1->( DbSeek(xFilial("SL1") + aCancel[5]))
			Else
				SL1->( DbSetOrder(2) )	//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
				lExistReg:= SL1->( DbSeek(xFilial("SL1") + IIf(!Empty(cGetSerie),cGetSerie, STFGetStation("SERIE")) + cGetCanc + STFGetStation("PDV")) )
			Endif 
		Endif 

		If lExistReg

			If lDocRPS .And. cGetCanc == aCancel[10]
				aInfCanSAT := STBCSCanCancel()
			Else
				If lPdvOn .AND. Len(aCancel) > 5 .AND. !Empty(aCancel[5])
					aInfCanSAT := STBCSCanCancel(cGetCanc,,cGetSerie,aCancel[5])
				else
					aInfCanSAT := STBCSCanCancel(cGetCanc,,cGetSerie)
				Endif 
			Endif 

			STISetCancel( aInfCanSAT )
			
			lRet :=  aInfCanSAT[1]
			

			If lRet
				// Gera cancelamento SAT
				If !Empty(SL1->L1_SERSAT) .And. !Empty(SL1->L1_KEYNFCE)
					lRet := IIF(ExistFunc("LJSatxCanc"),LJSatxCanc(.F.,@cNFisCanc),.F.)
				Endif 
				If !lRet
					cMsg := StrTran(STR0027,"SAT",cSiglaSat) //"SAT - Venda já cancelada ou excedeu o período de 30 minutos."
				EndIf
			Else
				cMsg := StrTran(STR0031,"SAT",cSiglaSat) //"SAT - Usuário sem permissão para cancelar venda"
			EndIf
			
		Else
			lRet := .F.	
			cMsg := StrTran(STR0028,"SAT",cSiglaSat) //"SAT - Venda não encontrada."
		EndIf	
		
		If !lRet  
			STFMessage(ProcName(), "STOP", cMsg) //"SAT - Venda já cancelada." ou "SAT - Venda não encontrada."
			STFShowMessage(ProcName())
		EndIf		
				    
	EndIf
	
	/*Cancela venda ecf */
	If lRet
		If lUseSat
			STICancel(cGetCanc,cNFisCanc)
		Else	
			STICancel()
		EndIf	
	EndIf	
	
EndIf

// -- Cancelamento FidelityCore
If lRet .And. ExistFunc("LjxRaasInt") .And. LjxRaasInt()
	oRaas := STBGetRaas()
	If Valtype(oRaas) == "O" .AND. SL1->L1_FIDCORE
		If oRaas:ServiceIsActive("TFC")
			oFidelityC := oRaas:GetFidelityCore()
			If !oFidelityC:CancelBonus(,SL1->L1_FILIAL + SL1->L1_NUM, STFGetStat("CODIGO"), IIF(lL1Tel,AllTrim(SL1->L1_TEL),""))[1]
				MsgAlert( I18n(STR0035, {CRLF + CRLF}), STR0034)    //"Não foi possível cancelar o bônus aplicado nesta venda.#1Entre em contato com seu parceiro de bônus."  //"TOTVS Bonificação"
			EndIf
		Else 
			MsgAlert(STR0036, STR0034)  //"A venda possui uso de programa de bonificação, porém o programa de bonificação esta desativado no cadastro de estação."    //"TOTVS Bonificação"
		Endif 
	EndIf 
Endif 
// Limpa variavel de verificação de regra de desconto por item
STBLimpRegra(.F.)

If	lRet .And. ExistFunc("STDRestCanL1") .And. !Empty(STDGPBasket("SL1","L1_CGCCLI"))	
	STDRestCanL1()	
EndIf

RestArea(aAreaSL1)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STBCSitDoc
Verifica o L1_SITUA do documento antes de permitir o cancelamento

@param		cDoc	Número do documento fiscal 
@author	Varejo
@version	P11.8
@since		21/07/2015
@return   	lRet	Indica se pode continuar com o cancelamento
@obs     
@sample
/*/
//------------------------------------------------------------------- 
Static Function STBSitCanc(cDoc, cSerie)

Local lRet 		:= .T.	//indica se o cancelamento pode continuar
Local cPDV		:= ""	//numero do PDV ( LG_PDV )
Local lDSitDoc	:= FindFunction("STDSitDoc")	//retorna o L1_SITUA do documento fiscal
Local aSitua	:= {}
Local nSpedExc  := SuperGetMV("MV_SPEDEXC",, 72) // Indica a quantidade de horas q a NFe pode ser cancelada
Local nNfceExc  := SuperGetMV("MV_NFCEEXC",, 0)  // Indica a quantidade de horas q a NFCe pode ser cancelada
Local aCancel	:= STIGetCancel() 	//Retornar o array com as informacoes da venda a ser cancelada
Local lDocNf	:= .F. 				//Indica se a venda que esta sendo cancelada eh nao fiscal
Local lDocRPS 	:= .F. 				//Cancelamento RPS	
Local cL1Num	:= ""
Local cLojaNf   := AllTrim(SuperGetMV("MV_LOJANF", .F. ,"")) // Serie da NF-e para validar o prazo de cancelamento.

Default cSerie  := STFGetStation("SERIE")

cPDV := STFGetStation("PDV")

//Tratamento para manter o legado do parametro MV_SPEDEXC e em caso de NF-e pegar o prazo correto.  
If nNfceExc <= 0 .Or. cSerie == cLojaNf
    nNfceExc := nSpedExc
EndIf 

//se nao estiver compilado, nao validamos o documento, assim como era antes
If lDSitDoc
	
	If ValType(aCancel) == "A" .AND. Len(aCancel) > 5 .AND. !Empty(aCancel[6])
		//Se entrar no IF, significa que eh uma venda nao fiscal vale credito ou vale presente
		lDocNf := .T.
	Elseif ValType(aCancel) == "A" .AND. Len(aCancel) >= 11 .AND. !Empty(aCancel[10]) .AND. !Empty(aCancel[11])
		lDocRPS := .T. 
		cL1Num	:= aCancel[5]
	Elseif ValType(aCancel) == "A" .AND. lPdvOn .AND. Len(aCancel) >= 11 .AND. !Empty(aCancel[5]) .AND. Empty(aCancel[10])
		cL1Num	:= aCancel[5]
	EndIf
	
	//retorna os campos L1_SITUA e L1_STORC
	aSitua := STDSitDoc(cSerie, cDoc, cPDV, lDocNf, lDocRPS, cL1Num )

	If aSitua[1] == "404"
		lRet := .F.
		STFMessage("STCancelSale", "STOP", STR0023) //"Documento fiscal não encontrado"
		STFShowMessage("STCancelSale")
	
	//A - caso de nota cancelada automaticamente | C - cancelamento manual
	ElseIf aSitua[2] $ "A|C"
		lRet := .F.
		If !lDocNf .AND. !lDocRPS
			STFMessage("STCancelSale", "STOP", STR0024)	//"Documento fiscal já enviado para cancelamento"
		Else
			STFMessage("STCancelSale", "STOP", STR0033)	//"Documento não fiscal já enviado para cancelamento"
		EndIf
		STFShowMessage("STCancelSale")
	ElseIf !lDocNf .AND. !lDocRPS .AND. !STBCancTime(nNfceExc, cDoc, cSerie) //verifica o prazo do documento antes de prosseguir com a exclusao
	   lRet := .F.
	   STFMessage("STCancelSale", "STOP", STR0029 + " " + AllTrim(STR(nNfceExc)) + STR0030) //"Prazo para o cancelamento de venda é de"#"horas. Verifique o parâmetro MV_NFCEEXC"
	   STFShowMessage("STCancelSale")
	ElseIf aSitua[1] $ "00|TX"
		If !lDocNf .AND. !lDocRPS
			STFMessage("STCancelSale", "YESNO", STR0025 + cDoc + "/" + cSerie + " ?" )	//Deseja cancelar o documento fiscal: "
		Else
			STFMessage("STCancelSale", "YESNO", STR0032 + cDoc +  "/" + cSerie + " ?" )	//"Deseja cancelar o documento não fiscal: "
		EndIf
		lRet := STFShowMessage("STCancelSale")
	
	Else
		STFMessage( "STCancelSale", "STOP", STR0026 )	//"Venda não finalizada/cancelada. Por favor, verifique a venda."
		STFShowMessage("STCancelSale")
	EndIf
	
EndIf

Return lRet


/*/{Protheus.doc} STBChkInut
Verifica se todos os requisitos foram atendidos
@type		function
@author  	Varejo
@version 	P12
@since   	14/10/2016
@return  	logico, se todos os requisitos foram atendidos
@obs     	Melhoria: Pode ser usada como funcao generica, recebendo o array
/*/
Function STBChkInut()

Local cAliasName 	:= ""
Local nI			:= 0
Local nPos			:= 0
Local lRet			:= .T.
Local aAux			:= {}
Local aArea			:= GetArea()

//Campos e funcoes necessarias para a Inutilizacao
Aadd( aAux, {"FIELD", "LX_MODDOC"	, .F.} )
Aadd( aAux, {"FUNC"	, "STWDELPAY"	, .F.} )		//STWCANCELSALE.PRW
Aadd( aAux, {"FUNC"	, "STDDELPAY"	, .F.} )		//STDCANCELSALE.PRW

For nI := 1 to Len(aAux)
	
	If aAux[nI][1] == "FIELD"
		
		nPos := At( "_", aAux[nI][2] )
			
		//ZZ_FieldName
		If nPos == 3
			cAliasName := 'S' + SubStr(aAux[nI][2], 1, 2)  		
		//ZZZ_FieldName
		Else
			cAliasName := SubStr(aAux[nI][2], 1, 3)
		EndIf	
		
		DbSelectArea( cAliasName )
		If &(cAliasName)->( ColumnPos(aAux[nI][2]) ) > 0
			aAux[nI][3] := .T.
		Else
			LJGrvLog(Nil, "CAMPO não encontrada no dicionario de dados", aAux[nI][2])
		EndIf

	ElseIf aAux[nI][1] == "FUNC"

		If ExistFunc(aAux[nI][2])
			aAux[nI][3] := .T.
		Else
			LJGrvLog(Nil, "FUNCAO não encontrada no repositorio", aAux[nI][2])
		EndIf

	EndIf

Next

RestArea(aArea)

nPos := aScan( aAux, {|x| !x[3]} )
If nPos > 0
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBCancTime
Verifica se eh venda NFCe transmitida, pois neste caso deve respeitar o
parametro MV_SPEDEXC que indica o numero de horas que pode ser excluida

@type       function
@author     Varejo
@version    P12
@since      22/02/2017
@return     logico, se venda esta no prazo de cancelamento
/*/
//-------------------------------------------------------------------
Static Function STBCancTime(nNfceExc, cDoc, cSerie)
Local aArea     := GetArea()
Local aAreaSL1  := SL1->(GetArea())
Local lRet      := .T.
Local dDtDigit  := dDataBase
Local nHoras    := 0
Local cEstacao  := Padr(STFGetStation("PDV"), TamSx3("L1_PDV")[1])
Local lEndFis   := SuperGetMv("MV_SPEDEND",, .F.)						// Se estiver como F refere-se ao endereço de Cobrança se estiver T ao endereço de Entrega.
Local cEstSM0	:= IIf(!lEndFis, SM0->M0_ESTCOB, SM0->M0_ESTENT)
Local cHoraUF 	:= FwTimeUF(cEstSM0)[2]

DEFAULT cSerie	:= Padr(STFGetStation("SERIE"), TamSx3("L1_SERIE")[1])

If Empty(cHoraUF)
	cHoraUF := Time()
EndIf

cDoc := Padr(cDoc, TamSx3("L1_DOC")[1])

SL1->(dbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV

If SL1->(dbSeek(xFilial("SL1") + cSerie + cDoc + cEstacao)) .And. ExistFunc("LjSubtHora")
    //Verifica se a NFCe foi transmitida pela chave            
    If !Empty(SL1->L1_KEYNFCE)
        dDtDigit := SL1->L1_EMISNF
        nHoras   := LjSubtHora(dDtdigit, SL1->L1_HORA, dDataBase, SubStr(cHoraUF, 1, 2) + ":" + SubStr(cHoraUF, 4, 2))                 
        
        If nHoras > nNfceExc        
            lRet := .F.             
        EndIf
    EndIf
EndIf

RestArea(aAreaSL1)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValCanc()
Verifica SE1 da Retaguarda se o titulo diferente de R$ foi baixada,
caso sim, não permite o cancelamento do cupom. 

@type       function
@author     caio.okamoto
@version    P12
@since      21/07/2021
@return     lógico, se o titulo não estiver em aberto retorna .T. para prosseguir o processo
/*/
//-------------------------------------------------------------------
Static Function STBValCanc()
Local lRet 				:= .T.
Local uDados	       	:= Nil 
Local aParam          	:= {}
Local uResult         	:= Nil
Local aFields 			:= {}
Local aTables 			:= {} 
Local cWhere 			:= ""
Local cMvLjBxAut		:= SuperGetMv("MV_LJBXTIT ",,"")
Local nX				:= 0

If !Empty(cMvLjBxAut) .AND. Substr(SL1->L1_CONFVEN,6,1) <> "N" .AND. !(SL1->L1_CREDITO > 0) 
	aFields := {"E1_TIPO",;		//1
				"E1_ORIGEM"}	//2

	aTables := {"SE1"}

	cWhere := " E1_FILIAL = '"+ SL1->L1_FILIAL +"' AND"
	cWhere += " E1_PREFIXO = '"+ SL1->L1_SERIE + "' AND"
	cWhere += " E1_NUM = '" + SL1->L1_DOC + "' AND"
	cWhere += " E1_VALOR <> E1_SALDO AND"
	cWhere += " E1_TIPO <> 'R$' AND E1_TIPO <> 'CR' AND E1_TIPO <> 'NCC' AND E1_TIPO <> 'VP'AND"
	cWhere += " D_E_L_E_T_ = ' '"

	aParam 	:= {	aFields,;
					aTables,;
					cWhere,;
					'',;
					10;
				}
				
	If STBRemoteExecute("STDQueryDB", aParam,,, @uResult)
		uDados := uResult
	EndIf 

	If ValType(uDados) == 'A'
		For nX := 1 To Len(uDados)
			If Alltrim(Upper(uDados[nX][1])) $ cMvLjBxAut .AND. AllTrim(Upper(uDados[nX][2])) $ "LOJA010/LOJA220/LOJA701/RPC/LOJA720/FATA701"
				lRet := .F.
				STFMessage("STBValCanc", "POPUP", STR0037 +". "+ STR0038 + uDados[nX][1]+".") 
				STFShowMessage("STBValCanc")
				Exit 
			EndIf 
		Next 
	EndIf

Endif  

Return lRet

/*/{Protheus.doc} STBDelItAS() Deleta Itens Auto Serviço
	Rotina criada para cancelamento de venda em andamento onde existe item auto serviço e importação de orçamento
	e com Totvs PDV ONLINE. Neste cenário, é preciso excluir os itens que não fazem parte do orçamento, pois caso 
	contrário, os itens vendidos no auto serviço vai fazer parte do orçamento quando for importar de novo.
	@type  Function
	@author caio.okamoto
	@since 24/08/2023
	@version 12
	/*/
Function STBDelItAS()
Local oModel 		:= STDGPBModel()
Local nX 			:= 0
Local nQtRegSL2 	:= STDPBLength("SL2")
Local lCanceled		:= .F. 

For nX:= 1 to nQtRegSL2	
	oModel:GetModel("SL2DETAIL"):GoLine(nX)
	If Empty(oModel:GetValue("SL2DETAIL", "L2_NUMORIG")) .AND. !oModel:GetModel("SL2DETAIL"):IsDeleted()
		LjGrvLog(NIL, "exclusão de itens auto serviço", oModel:GetValue("SL2DETAIL", "L2_PRODUTO") )
		STWItemCancel (oModel:GetValue("SL2DETAIL", "L2_PRODUTO"), , ,oModel:GetValue("SL2DETAIL", "L2_ITEM"))
		lCanceled:= .T. 
	EndIf
Next nX 

If lCanceled
	iif (Existfunc("STBISL4Refresh"),STBISL4Refresh(), nil) 
	STDSaveSale()
Endif 

Return 


/*/{Protheus.doc} STBVldItRes
	Verifica se existe item com reserva.
	Caso exista, não pode prosseguir com cancelamento
	uso somente para cancelamento e venda finalizada
	@type  Function
	@author caio.okamoto
	@since 16/10/2024
	@version 12
	@param cSL1NUM 		, caracter	,	L1_NUM 
	@param cL1SERIE		, caracter	,	L1_SERIE
	@param cSL1NUMORI	, caracter	,	L1_NUMORIG
	@return lRet		, lógico	, se .T. pode prosseguir com cancelamento
	/*/
Static Function STBVldItRes(cSL1NUM, cL1SERIE, cSL1NUMORI )
Local lRet 		:= .T. 
	If STDCSChkRes(cSL1NUM, cSL1NUMORI )
		lRet := .F. 
		MsgAlert(STR0039)//Existe Pedido e Reserva de itens vinculados à essa Venda. Favor realizar a Troca/Devolução pela Retaguarda
		STFMessage("STBVldItRes","STOP", STR0039) 
		LjGrvLog(cSL1NUM,STR0039)
	Endif 
Return lRet 
