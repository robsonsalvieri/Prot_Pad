#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBRECOVERYSALE.CH"

Static lRecovered := .F.

//-------------------------------------------------------------------
/*{Protheus.doc} STBRSCanRecovery
verifica se pode Recuperar Vendas

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se pode recuperar Venda
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBRSCanRecovery()

Local lRet := .T.			// Retorna se pode recuperar vendas 

If SuperGetMv("MV_CTRLFOL",,.F.) .AND. AllTrim(cPaisLoc) $ "CHI|COL"
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STBRSStationChange
Verifica troca de ECF

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet					Retorna se ocorreu a troca de ECF
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRSStationChange( cPDV )

Local lRet			:= .F.			// Retorna se trocou ECF
Local cPDVPrint	:= ""			// PDV do periférico
Local aPDV		:= {""}			// Retorno evento get PDV
Local aPrinter	:= {}

Default cPDV := ""

ParamType 0 Var 	cPDV 	As Character	Default 	""

If STFUseFiscalPrinter()
	/*/
		Get PDV Impressora
	/*/
	aPrinter := STFFireEvent( ProcName(0) , "STGetPDV" , aPDV )
			
	If ValType(aPrinter) <> "A" .OR. Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aPDV) < 1     
	
		STFMessage(ProcName(),"STOP", "Falha na obtenção do cupom")
		STFShowMessage(ProcName())
		cPDVPrint := ""
		
	Else	
		cPDVPrint := AllTrim(aPDV[1])	
	EndIf 
	
Else    
	cPDVPrint := AllTrim(STFGetStat("PDV"))	
EndIf

If cPDVPrint <> AllTrim(cPDV)
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRSHasPrint
Verifica se a venda possui itens de reserva e/ou de impressão

@param   aSL2						Itens da venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1]					Retorna se possui itens de reserva
@return  aRet[2]					Retorna se possui itens de impressão
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRSHasPrint( aSL2 )

Local lReserve			:= .F.			// Possui itens de reserva?
Local lPrint			:= .F.			// Possui Itens de Impressão?
Local nI				:= 0			// Contador
Local nPosReserve		:= 0			// Posicao do campo
Local aRet				:= {}			// Retorno da funcao 

Default aSL2 := {}

ParamType 0 Var aSL2 As Array Default {}

nPosReserve := AScan( aSL2[1] , { |x| x[1] == "L2_RESERVA" } )

For nI := 1 To Len(aSL2)
	If Empty(aSL2[nI][nPosReserve][2])
		lPrint := .T.
	Else
		lReserve := .T.
	EndIf
Next nI

AADD( aRet , lReserve 	)
AADD( aRet , lPrint 		)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRSNumPrinter
Busca o Ultimo Cupom da Impressora

@param	 
@author  Varejo
@version P11.8
@since   29/03/2012
@return   cNumDoc						Retorna o Ultimo Cupom da impressora				
@obs     								Se der erro na impressora retorna "ERROR", se nao usa impressora retorna vazio
@sample
/*/
//-------------------------------------------------------------------
Function STBRSNumPrinter()

Local cNumDoc 		:= ""			// Retorna o Ultimo Cupom da impressora, caso use
Local nRet			:= 0			// Retorno da impressora
Local aPrinter		:= {}			// Retorno da impressora
Local aDados		:= {Space(STBLenReceipt()),Nil}

aPrinter := STFFireEvent(ProcName(0), "STGetReceipt", aDados)
							
If Len(aPrinter) == 0 .OR. aPrinter[1] <> 0 .OR. Len(aDados) == 0	
	cNumDoc := "ERROR"
	STFMessage(ProcName(),"STOP","Erro com a Impressora Fiscal. Operação não efetuada.")
	STFShowMessage(ProcName())
Else
	cNumDoc := PADR(aDados[1],TamSX3("L1_DOC")[1])
EndIf						
 
Return cNumDoc


//-------------------------------------------------------------------
/*/{Protheus.doc} STBRSCloseCupCancel
Recuperação de venda com o Cupom fechado

@param   aSale						Venda com Cabeçalho, Itens e Pagamentos (SL1,SL2,SL4)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRSCloseCupCancel( aSale, lNFCe )

Local lRet			:= .T.			// Retorna se pode continuar a recuperar a venda
Local aSL1			:= {}			// SL1
Local aSL2			:= {}			// SL2
Local aSL4			:= {}			// SL4
Local cNumCup		:= ""			// Armazena o numero do Cupom da impressora
Local aRet			:= {}			// Armazena retorno da impressora
Local nI			:= 0			// Contador
Local aProfile		:= {}			// Armazena o retorno da permissao
Local lError		:= .F.			// Indica que houve erro
Local aIsOpenReceipt:= { "5" , "" }	// Armazena retorno se o cupom está aberto

Default aSale := {}
Default lNFCe := STBGetNFCE()

ParamType 0 Var   	aSale 	As Array	Default 	{}

aSL1 := aSale[1]
aSL2 := aSale[2]
aSl4 := aSale[3]

aRet := STFFireEvent( ProcName(0),"STPrinterStatus",aIsOpenReceipt) // Verifica Cupom Fechado 

If !lNFCe .AND. Len(aRet) > 0 .AND. ValType(aRet[1]) == "N"	.AND. aRet[1] <> 7
 
	STFMessage("STRecoverySale","STOP","O ECF não está com o cupom aberto. Este cupom será cancelado.")
	STFShowMessage("STRecoverySale") // Mostrar a mensagem antes q cancele(ou peça permissao se preciso for)	
		
	LjGrvLog( "L1_NUM: "+aSL1[AScan( aSL1 , { |x| x[1] == "L1_NUM" } )][2], "O ECF não está com o cupom aberto. Este cupom será cancelado." )  //Gera LOG	
		
	cNumCup := STBRSNumPrinter()
	
	If (cNumCup <> "ERROR") .AND. !(Empty(cNumCup))
	
		If AllTrim(cNumCup) == AllTrim(aSL1[AScan( aSL1 , { |x| x[1] == "L1_DOC" } )][2])
			aProfile := STFPROFILE(8) // Permissao cancelamento
			aRet := STFFireEvent( ProcName(0) , "STCancelReceipt" , {aProfile[2]} )
			If Len(aRet) > 0 .AND. aRet[1] == 0
				STDCSDeleteSale( aSL1[AScan( aSL1 , { |x| x[1] == "L1_NUM" 	} 	)][2] )
			Else
				lError := .T.
			EndIf
		Else
			lError := .T. // Se a numeracao eh diferente, nao consegue cancelar, (deve ter aberto comprovante TEF)
			lRet := .F.		// Retorna que nao continua a recuperar a venda
		EndIf
		
	Else
		lError := .T.
		lRet := .F.		// Retorna que nao continua a recuperar a venda
	EndIf
	
	If lError

		STFMessage("STRecoverySale","STOP","Erro com a Impressora Fiscal. Será necessário efetuar Nota de Devolução.")
		STFShowMessage("STRecoverySale")
		
		LjGrvLog( "L1_NUM: "+aSL1[AScan( aSL1 , { |x| x[1] == "L1_NUM" } )][2], "Erro com a Impressora Fiscal. Será necessário efetuar Nota de Devolução." )  //Gera LOG
		
		/*/					
			Caso ocorra erro no cancelamento , continua a gravacao do cupom, pois o mesmo nao 
			pode ser cancelado no ECF. Neste caso sera necessario realizar uma NOTA DE DEVOLUCAO.
		/*/
		
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_SITUA" 	} 	)][2] := "00"		// "00" - Venda Efetuada Com Sucesso
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_STATUS" 	} 	)][2] := "T"		// Indica que houve erro na Transacao TEF
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_VENDTEF" 	} 	)][2] := "N"
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_DATATEF" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_HORATEF" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_DOCTEF" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_AUTORIZ" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_INSTITU" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_DOCCANC" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_DATCANC" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_HORCANC" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_NSUTEF" 	} 	)][2] := ""
		aSL1[AScan( aSL1 , { |x| x[1] == "L1_TIPCART" 	} 	)][2] := ""
		If SL1->(FieldPos("L1_TIMEATE")) > 0
			aSL1[AScan( aSL1 , { |x| x[1] == "L1_TIMEATE" 	} 	)][2] := 0
        EndIf
		/*/
			Realiza a persistencia dos dados
		/*/
		STFSaveTab( "SL1" , aSL1 , .F. )
		
		
		
	EndIf
		
EndIf

Return lRet


//-------------------------------------------------------------------
/*{Protheus.doc} STBRSCancelSale
Realiza o cancelamento da venda caso, durante a recuperaçao da venda, seja identificado que a venda tem itens de reserva ou;
é um orçamento importado.

@param   aSale						Venda com Cabeçalho, Itens e Pagamentos (SL1,SL2,SL4)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet		Realizou cancelamento				 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBRSCancelSale( aSale, lHasPrint )

Local lRet			:= .T.			// Fluxo da funcao
Local aRet			:= {}			// Armazena retorno da impressora
Local lCancCup		:= .T.			// Indica se cancelou cupom fiscal
Local aSL1			:= {}			// Cabeçalho da venda
Local aProfile		:= {}			// Armazena Retorno de permissao
Local cCGCCli		:= ""
Local cNome			:= ""
Local cNumOrc		:= ""
Local cNumOrig		:= ""

Default aSale		:=	{} 

ParamType 0 Var   	aSale 				As Array	  Default 	{}

If STFGetCfg("lUseECF")  
	aRet := STFFireEvent( 	ProcName(0)		, ; // Nome do processo
	   						"STPrinterStatus"	, ; // Nome do evento
						   	{ "9", "" }	  	) // Verifica STATUS
	
	If Len(aRet) > 0 .AND. ValType(aRet[1]) == "N"	.AND. aRet[1] <> 0	
		HELP(' ',1,'FRT011')	// "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
		lRet := .F.
	EndIf
	
	If lRet
		aSL1 := {{"L1_SITUA",	"07"}} // "07" - Solicitado o Cancelamento do Cupom
		
		// Realiza a persistência
		STFSaveTab( "SL1" , aSL1 , .F. )
	
		If lHasPrint 
			aProfile := STFPROFILE(8) // Permissao cancelamento
			aRet := STFFireEvent( ProcName(0) , "STCancelReceipt" , {aProfile[2]} )
			If Len(aRet) == 0 .OR. aRet[1] <> 0
				lCancCup := .F.
			EndIf
		EndIf
		
		If lCancCup
			STDCSDeleteSale( aSale[1][AScan( aSale[1] , { |x| x[1] == "L1_NUM" 	} 	)][2] )
			STFMessage(ProcName(),"ALERT", "CUPOM FISCAL CANCELADO") //"CUPOM FISCAL CANCELADO"
			STFShowMessage(ProcName())
			
			If STBIsPaf()
				cCGCCli := aSale[1][AScan( aSale[1] , { |x| x[1] == "L1_CGCCLI" 	} 	)][2]
				STFFireEvent(ProcName(0), "STGrvMdz",	{"R4",,aSale[1][AScan( aSale[1] , { |x| x[1] == "L1_NUM" 	} 	)][2], cNome, cCGCCli}) //"Suprimento"
				
			EndIf
		EndIf
			
	EndIf

Else

	cNumOrc := aSale[1][AScan( aSale[1] , { |x| x[1] == "L1_NUM" })][2]
	cNumOrig := aSale[1][AScan( aSale[1] , { |x| x[1] == "L1_NUMORIG" })][2]
	aSL1 := {{"L1_SITUA",	"07"}} // "07" - Solicitado o Cancelamento do Cupom		
	
	// Realiza a persistência
	STFSaveTab( "SL1" , aSL1 , .F. )

	STDCSDeleteSale(cNumOrc ,Nil ,cNumOrig)
	
	STFMessage(ProcName(),"ALERT", "CUPOM CANCELADO") //"CUPOM CANCELADO"
	STFShowMessage(ProcName())

EndIf

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STBRSZReduction
Realiza recuperaçao da venda

@param   aSale						Venda com Cabeçalho, Itens e Pagamentos (SL1,SL2,SL4)
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet						 	Retorna se Realizou a Recuperação da venda
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBRSZReduction( )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} STBIsRecovered
Informa se a venda esta sendo recuperada

@author  Varejo
@version P11.8
@since   26/06/2013
@return  lRecovered				Informa se a venda esta sendo recuperada
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STBIsRecovered()
Return lRecovered

//-------------------------------------------------------------------
/*{Protheus.doc} STBR7Recovered
Reseta variavel static que informa se a venda esta sendo recuperada

@author  Varejo
@version P11.8
@since   26/06/2013
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STB7Recovered(lSet)

DEFAULT lSet := .F.

lRecovered := lSet

Return 


