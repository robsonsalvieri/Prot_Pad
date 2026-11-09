#INCLUDE "PROTHEUS.CH" 
#INCLUDE "DROVDLNK.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FRTDEF.CH"

//Definicao de variavel em objeto
#xtranslate bSETGET(<uVar>) => { | u | If( PCount() == 0, <uVar>, <uVar> := u ) }

//Definicao do DEFAULT
#xcommand DEFAULT <uVar1> := <uVal1> ;
     	   [, <uVarN> := <uValN> ] => ;
           <uVar1> := If( <uVar1> == nil, <uVal1>, <uVar1> ) ;;
		   [ <uVarN> := If( <uVarN> == nil, <uValN>, <uVarN> ); ]
                                  
//Utilizados para conexão RPC da TOTVSVIDA.DLL
Static oRPCServer
Static cRPCServer
Static nRPCPort
Static cRPCEnv
Static cRPCEmp 
Static cRPCFilial

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLGet  ³ Autor ³ VENDAS CRM	                        ³ Data ³20/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Solicita que o usuario digite o Numero da Autorização. A seguir chama a    ³±±
±±³          ³ funcao LjDroVLCar() que faz o "Carregamento" dos dados de venda com os dados³±±
±±³          ³ da cotação do VidaLink referente a este numero de autorizacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLGet( nOpPbm )
LjDROVLGet( nOpPbm )
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o	 ³DROVLVen  ³ Autor ³ VENDAS CRM		                    ³ Data ³26/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Após a conclusão da venda informa ao VidaLink os produto e quantidades     ³±±
±±³          ³ vendidos atraves da array aVidaLinkD.                                      ³±±
±±³          ³ Obs. As quantidades vendidas acima da autorização ou os produtos não auto- ³±±
±±³          ³      zados não serão incluidos na array aVidaLinkD e não terão os seus     ³±±
±±³          ³      preços sem os descontos do PBM.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Template Function DROVLVen( )
Local aRet := {}					// Retorno da funcao
Local _aVidaLinkC := ParamIxb[2]	// aVidalinkC
Local _aVidaLinkD := ParamIxb[3]	// aVidalinkD
Local _nVidaLink  := ParamIxb[1]	// nVidalink
Local _cDoc		  := ParamIxb[4]	// Numero do Cupom Fiscal

aRet := LjDROVLVen(_nVidaLink,_aVidaLinkC,_aVidaLinkD,_cDoc)

Return aRet
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DROVDLNK  ºAutor  ³Microsiga           º Data ³  06/25/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function CANPSys( )
                                                  
Local aVidaLinkD := {}

aAdd(aVidaLinkD, "" )
aAdd(aVidaLinkD, {} )
aAdd(aVidaLinkD, 0  )  
aAdd(aVidaLinkD, 0  )  
	
oTEF:Operacoes("PHARMASYSTEM_CANCELAMENTO", aVidaLinkD, , ,"")	//PharmaSystem	

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLImp  ³ Autor ³ VENDAS CRM		                    ³ Data ³26/04/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Após a conclusão da venda imprime o comprovante de venda Vidalink no ECF   ³±±
±±³          ³ como no exemplo abaixo:                                                    ³±±
±±³          ³ DEMONSTRATIVO PBM VIDALINK@No.Autorizacao.: 123456                         ³±±
±±³          ³                                                                            ³±±
±±³          ³ Obs. Se existir pagamento com TEF, a impressão do cupom VIDALINK se dará   ³±±
±±³          ³      junto com o cupom TEF.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                    				      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLImp( )
Local _nVidaLink := ParamIxb[1] // nVidalink
Local aRet := {}				// Retorno da Funcao

aRet := LjDROVLImp(_nVidaLink)

Return (aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLBPro ³ Autor ³ VENDAS CRM				            ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina de busca de produtos na chamada da DLL. 							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLBPro(cCodBarra, lIncProd)
	Local cRet          := ""  	// Retorno da funcao
	Local cDescrProd	:= ""  	// Descricao do produto
	Local nPrecoPMC		:= 0   	// Preco Maximo Consumidor
	Local nPrecoPromo	:= 0   	// Preco de venda do estabelecimento
	Local lEncontrou	:= .F. 	// Encontrou o produto?
	Local cCodProd	:= ""
	
	Default lIncProd := .F.
	
	DbSelectArea("SBI")
	SBI->(DbSetorder(5))
	             
	If SBI->(DbSeek(xFilial("SBI") + PADR(cCodBarra, 13)))
		cDescrProd	:= SBI->BI_DESC
		nPrecoPMC	:= SBI->BI_PRV
		nPrecoPromo	:= SBI->BI_PRV
		cCodProd	:= SBI->BI_COD
		lEncontrou	:= .T.
	EndIf
	
	If lEncontrou
		cPrecoPMC	:= PadR(AllTrim(Str(nPrecoPMC,14,2)), 11)
		cPrecoPMC	:= StrTran(cPrecoPMC, '.', '', 1)
		cPrecoPromo	:= PadR(AllTrim(Str(nPrecoPromo,14,2)), 11)
		cPrecoPromo	:= StrTran(cPrecoPromo, '.', '', 1)
		cRet := Space(7) + PadR(cDescrProd, 35) + Space(12) + cPrecoPMC + cPrecoPromo + IIF( !lIncProd, Space(1), Space(1) + cCodProd)
	Else
		cRet := ""
   EndIf
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLCall ³ Autor ³ VENDAS CRM				            ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina chamada apartir do VidaLink atravez de integração via DLL.          ³±±
±±³          ³ Na digitação do codigo de barra do produto no VidaLink, ele passa este     ³±±
±±³          ³ codigo para a DLL TOTVSVIDA.dll que invoca esta funcao tambem passando o   ³±±
±±³          ³ codigo de barra como parametro, esperando como retorno um strig de 75 bytes³±±
±±³          ³ com o formato abaixo.                                                      ³±±
±±³          ³----------------------------------------------------------------------------³±±
±±³          ³Inicio|Fim |Tamanho|Conteudo                                                ³±±
±±³          ³   01 | 07 | 07    | Espacos                                                ³±±
±±³          ³   08 | 43 | 35    | Descricao do Produto                                   ³±±
±±³          ³   44 | 54 | 11    | Espacos                                                ³±±
±±³          ³   55 | 64 | 10    | PMC - Preco Maximo ao Consumidor                       ³±±
±±³          ³   65 | 74 | 10    | Preco Promocional                                      ³±±
±±³          ³   75 | 75 | 01    | Espaco                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLCall(cFuncao, uParm1, uParm2, uParm3, uParm4, uParm5, uParm6)
	Local cRet := "" // Retorno da Funcao
    Local cEAN := "" // EAN do produto
    Local nX   := 0   
    Local nFor := 0
    Local aAuxSer := {}
    Local aServers:= {}
    Local lNewConnect := .F.
    Local lConnect	  := .F.
    	
	// Conexao RPC
	cRPCServer	:= uParm1
	nRPCPort	:= uParm2
	cRPCEnv		:= uParm3
	cRPCEmp		:= uParm4
    cRPCFilial	:= uParm5  
    cEAN 		:= uParm6
	
	nFor := FrtServRpc()		// Carrega o numero de servidores disponiveis 	

	For nX := 1 To nFor         //  Carrega os dados do server
		aAuxSer	:= FrtDadoRpc() 
		If ( !Empty(aAuxSer[1]) .AND. !Empty(aAuxSer[2]) .AND. !Empty(aAuxSer[3])) 		
			Aadd(aServers,{aAuxSer[1],Val(aAuxSer[2]),aAuxSer[3]})
		EndIf
		aAuxSer := {}
	Next nX
	
	lNewConnect := .F.
	If oRPCServer == Nil
		ConOut(STR0021)				   							// "DROVLCall: Chamada ao VIDALINK"
		ConOut(STR0022) 			   							// "DROVLCall: Abrindo nova instancia RPC..."	
		oRPCServer:=FwRpc():New( cRPCServer, nRPCPort , cRpcEnv )	// Instancia o objeto de oServer	
		oRPCServer:SetRetryConnect(1)								// Tentativas de Conexoes
	
		For nX := 1 To Len(aServers)                            	// Metodo para adicionar os Servers 
			oRPCServer:AddServer( aServers[nX][1], aServers[nX][2], aServers[nX][3] )
		Next nX
	
		ConOut(STR0023) 			   							// "DROVLCall: Conectando com o servidor..."	
		lConnect := oRPCServer:Connect()							// Tenta efetuar conexao
		lNewConnect := .T.
	Else
		lConnect 	:= .T.
		lNewConnect := .F.
	EndIf
	
	If lConnect
		If lNewConnect
			oRPCServer:CallProc("RPCSetType", 3 )
			oRPCServer:SetEnv(cRPCEmp,cRPCFilial,"FRT")                 // Prepara o ambiente no servidor alvo
		EndIf

		ConOut(STR0025) 										// "DROVLCall: Buscando produto..."
	   	cRet := oRPCServer:CallProc("T_DROVLBPro", cEAN)	   
		ConOut("Retorno: #" + cRet + "#")						// Exibe o retorno da funcao, que sera enviado para a DLL

		ConOut(STR0034) 										// "DROVLCALL: Desconectando..."
   		oRPCServer:Disconnect()			

		ConOut(STR0035)											// "DROVLCall: Finalizando VIDALINK"
		oRPCServer := Nil

		ConOut(STR0035)											// "DROVLCall: Fim da chamada ao VIDALINK"        */
	EndIf	
	
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLATbl ³ Autor ³ VENDAS CRM							³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina usada para abrir as tabelas de produto SB0 e SBI na chamada da DLL. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLATbl(cCodEmp, cCodFil)
	Local cDrvX2  := "DBFCDX"				// Driver de acesso
	Local cArqX2  := "SX2" + cCodEmp + "0"	// Nome do arquivo SX2
	Local cArqIX  := "SIX" + cCodEmp + "0"	// Nome do arquivo SXI
	Local cDriver := "DBFCDX"				// Driver de acesso

	Public cFilAnt := cCodFil		  		// Usada no Matxfuna - xFilial                  
	Public cArqTAB := ""					// Usada no Matxfuna - xFilial
	             
	SET DELETED ON
	
	#IFDEF WAXS
		cDrvX2 := "DBFCDXAX"
	#ENDIF
	
	#IFDEF WCODB
		cDrvX2 := "DBFCDXTTS"
	#ENDIF
	                
	USE &("SIGAMAT.EMP") ALIAS "SM0" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0026) //"SM0 Open Failed"
	EndIf
	
	USE &(cArqIX) ALIAS "SIX" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0027) //"SIX Open Failed"
	EndIf
	
	DbSetOrder(1)
	
	If Empty(IndexKey())
		UserException(STR0028) //"SIX Open Index Failed"
	EndIf
	
	USE &(cArqX2) ALIAS "SX2" SHARED NEW VIA cDrvX2
	
	If NetErr()
		UserException(STR0029) //"SX2 Open Failed"
	EndIf
	
	DbSetOrder(1)
	
	If Empty(IndexKey())
		UserException(STR0030) //"SX2 Open Index Failed"
	EndIf
	

	#IFDEF AXS
		cDriver := "DBFCDXAX"
	#ENDIF
	
	#IFDEF CTREE
		cDriver := "CTREECDX"
	#ENDIF
	
	#IFDEF BTV
		cDriver := "BTVCDX"
	#ENDIF
	
	T_DROVLAArq("SBI", cDriver)
	
	SET DELETED OFF
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLAArq ³ Autor ³ VENDAS CRM							³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina usada para abrir as tabelas individualmente.	    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLAArq(cAlias, cDriver)
	Local cArquivo := ""   
	
	DbSelectArea("SIX")
	DbSetOrder(1)
	DbSeek(cAlias)
	
	DbSelectArea("SX2")
	DbSetOrder(1)     
	
	If DbSeek(cAlias)
		cArquivo := AllTrim(SX2->X2_PATH) + AllTrim(SX2->X2_ARQUIVO)
	
		USE &(cArquivo) ALIAS &(cAlias) SHARED NEW VIA cDriver
		
		If NetErr()
			UserException(cAlias + STR0031) //" Open Failed"
		EndIf
		             
 		cArqTab += cAlias+SX2->X2_MODO
		DbSetOrder(1)
	
		If Empty(IndexKey())
			UserException(cAlias + STR0032) //" Open Index Failed"
		EndIf
	Else
		UserException(cAlias + STR0033) //" Not Found in SX2"
	EndIf
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLPSet   ³ Autor ³ VENDAS CRM							  ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina usada para preencher o array aParamVL.	    				    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        		   		    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLPSet(	oHora			, cHora			, oDoc			, cDoc			,;
								oCupom		 	, cCupom		, nLastTotal	, nVlrTotal		,;		
								nLastItem	 	, nTotItens		, nVlrBruto		, oDesconto		,;		
								oTotItens	 	, oVlrTotal		, oFotoProd		, nMoedaCor		,;		
								cSimbCor	 	, oTemp3		, oTemp4		, oTemp5		,;		
								nTaxaMoeda	 	, oTaxaMoeda	, nMoedaCor		, cMoeda		,;		
								oMoedaCor	 	, nVlrPercIT	, cCodProd		, cProduto		,;		
								nTmpQuant	 	, nQuant		, cUnidade		, nVlrUnit		,;		
								nVlrItem		, oProduto		, oQuant		, oUnidade		,;		
								oVlrUnit	 	, oVlrItem		, lF7			, oPgtos		,; 	
								oPgtosSint	 	, aPgtos		, aPgtosSint	, cOrcam		,;
								cPDV		 	, lTefPendCS 	, aTefBKPCS		, oDlgFrt		,;
								cCliente	 	, cLojaCli		, cVendLoja		, lOcioso		,;
								lRecebe			, lLocked		, lCXAberto		, aTefDados		,;
								dDataCN			, nVlrFSD		, lDescIT		, nVlrDescTot	,;
								nValIPI			, aItens 		, nVlrMerc		, lEsc			,;
								aParcOrc	 	, cItemCOrc		, aParcOrcOld	, aKeyFimVenda	,;
								lAltVend	 	, lImpNewIT		, lFechaCup		, aTpAdmsTmp	,;
								cUsrSessionID	, cContrato		, aCrdCliente	, aContratos	,;
								aRecCrd			, aTEFPend		, aBckTEFMult	, cCodConv		,;
								cLojConv		, cNumCartConv	, uCliTPL		, uProdTPL		,;
								lDescTotal		, lDescSE4		, aVidaLinkD	, aVidaLinkc 	,; 
								nVidaLink		, cCdPgtoOrc	, cCdDescOrc	, nValTPis		,; 
								nValTCof		, nValTCsl		, lOrigOrcam	, lVerTEFPend	,;
								nTotDedIcms		, lImpOrc		, nVlrPercTot	, nVlrPercAcr	,; 
								nVlrAcreTot		, nVlrDescCPg	, nVlrPercOri	, nQtdeItOri	,;
								nNumParcs		, aMoeda		, aSimbs		, cRecCart		,; 
								cRecCPF			, cRecCont		, aImpsSL1		, aImpsSL2		,; 
								aImpsProd		, aImpVarDup	, aTotVen		, nTotalAcrs	,;
								lRecalImp		, aCols			, aHeader 		, aDadosJur		,;
								aCProva			, aFormCtrl		, nTroco		, nTroco2 		,; 
								lDescCond		, nDesconto		, aDadosCH		, lDiaFixo		,;
								aTefMult		, aTitulo		, lConfLJRec	, aTitImp		,;
								aParcelas		, oCodProd		, cItemCond		, lCondNegF5	,;
								nTxJuros		, nValorBase	, oMensagem		, oFntGet		,;
								cTipoCli		, lAbreCup		, lReserva		, aReserva  	,;
								oTimer			, lResume		, nValor 		, aRegTEF		,;
								lRecarEfet		, oOnOffLine	, nValIPIIT		, _aMult		,;
								_aMultCanc		, nVlrDescIT	, oFntMoeda		, lBscPrdON		,;
								oPDV			, aICMS			, lDescITReg)    
						
LjDROVLPSet(	@oHora			, @cHora		, @oDoc			, @cDoc			,;
				@oCupom		 	, @cCupom		, @nLastTotal	, @nVlrTotal	,;		
				@nLastItem	 	, @nTotItens	, @nVlrBruto	, @oDesconto	,;		
				@oTotItens	 	, @oVlrTotal	, @oFotoProd	, @nMoedaCor	,;		
				@cSimbCor	 	, @oTemp3		, @oTemp4		, @oTemp5		,;		
				@nTaxaMoeda	 	, @oTaxaMoeda	, @nMoedaCor	, @cMoeda		,;		
				@oMoedaCor	 	, @nVlrPercIT	, @cCodProd		, @cProduto		,;		
				@nTmpQuant	 	, @nQuant		, @cUnidade		, @nVlrUnit		,;		
				@nVlrItem		, @oProduto		, @oQuant		, @oUnidade		,;		
				@oVlrUnit	 	, @oVlrItem		, @lF7			, @oPgtos		,; 	
				@oPgtosSint	 	, @aPgtos		, @aPgtosSint	, @cOrcam		,;
				@cPDV		 	, @lTefPendCS 	, @aTefBKPCS	, @oDlgFrt		,;
				@cCliente	 	, @cLojaCli		, @cVendLoja	, @lOcioso		,;
				@lRecebe		, @lLocked		, @lCXAberto	, @aTefDados	,;
				@dDataCN		, @nVlrFSD		, @lDescIT		, @nVlrDescTot	,;
				@nValIPI		, @aItens 		, @nVlrMerc		, @lEsc			,;
				@aParcOrc	 	, @cItemCOrc	, @aParcOrcOld	, @aKeyFimVenda	,;
				@lAltVend	 	, @lImpNewIT	, @lFechaCup	, @aTpAdmsTmp	,;
				@cUsrSessionID	, @cContrato	, @aCrdCliente	, @aContratos	,;
				@aRecCrd		, @aTEFPend		, @aBckTEFMult	, @cCodConv		,;
				@cLojConv		, @cNumCartConv	, @uCliTPL		, @uProdTPL		,;
				@lDescTotal		, @lDescSE4		, @aVidaLinkD	, @aVidaLinkc 	,; 
				@nVidaLink		, @cCdPgtoOrc	, @cCdDescOrc	, @nValTPis		,; 
				@nValTCof		, @nValTCsl		, @lOrigOrcam	, @lVerTEFPend	,;
				@nTotDedIcms	, @lImpOrc		, @nVlrPercTot	, @nVlrPercAcr	,; 
				@nVlrAcreTot	, @nVlrDescCPg	, @nVlrPercOri	, @nQtdeItOri	,;
				@nNumParcs		, @aMoeda		, @aSimbs		, @cRecCart		,; 
				@cRecCPF		, @cRecCont		, @aImpsSL1		, @aImpsSL2		,; 
				@aImpsProd		, @aImpVarDup	, @aTotVen		, @nTotalAcrs	,;
				@lRecalImp		, @aCols		, @aHeader 		, @aDadosJur	,;
				@aCProva		, @aFormCtrl	, @nTroco		, @nTroco2 		,; 
				@lDescCond		, @nDesconto	, @aDadosCH		, @lDiaFixo		,;
				@aTefMult		, @aTitulo		, @lConfLJRec	, @aTitImp		,;
				@aParcelas		, @oCodProd		, @cItemCond	, @lCondNegF5	,;
				@nTxJuros		, @nValorBase	, @oMensagem	, @oFntGet		,;
				@cTipoCli		, @lAbreCup		, @lReserva		, @aReserva  	,;
				@oTimer			, @lResume		, @nValor 		, @aRegTEF		,;
				@lRecarEfet		, @oOnOffLine	, @nValIPIIT	, @_aMult		,;
				@_aMultCanc		, @nVlrDescIT	, @oFntMoeda	, @lBscPrdON	,;
				@oPDV			, @aICMS		, @lDescITReg) 
  						
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLPGet      ³ Autor ³ VENDAS CRM				             ³ Data ³12/05/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina usada para retornar o array aParamVL.	    				        	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Front Loja com Template Drogarias                        		   		       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLPGet()
Return(LjDROVLPGet())

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³DROVLPVal ³ Autor ³ Vendas CRM                            ³ Data ³13/10/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se o valor do item da venda do VidaLink e maior ou menor,         ³±±
±±³          ³ para assumir o menor valor                                                 ³±±
±±³          ³ Recalcula o valor do desconto e percentual quando utiliza o valor do       ³±±
±±³          ³ do VidaLink                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Venda assistida e Front Loja com Template Drogarias                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function DROVLPVal(aVidaLinkD , aVidaLinkc , nVidaLink , cCodProd   ,;
                            nVlrDescIT , nTmpQuant  , nVlrItem  , nVlrPercIT ,;
                            nVlrUnit   , aVidaLinkD , nNumItem  , uProdTPL   ,;
                            uCliTPL	, lImpOrc	   , cDoc		 , cSerie )
                            
Local aRetorno   := {}

aRetorno := LjDROVLPVal(aVidaLinkD 	, aVidaLinkc , nVidaLink , cCodProd   ,;
                     	nVlrDescIT 	, nTmpQuant  , nVlrItem  , nVlrPercIT ,;
                     	nVlrUnit   	, aVidaLinkD , nNumItem  , uProdTPL   ,;
                     	uCliTPL		, lImpOrc	 , cDoc		 , cSerie )
Return(aRetorno)


/*/{Protheus.doc} RetPharma
Retorna codigo PBM PharmaSys

@param      	
@author  Varejo
@version P11.80
@since   22/05/2015
@return  .T. se a parcela digitada for válida / .F. Se a parcela digitada NÃO for válida.
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function RetPharma()

	T_DROVLGet(540)
	
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} DrSScrExMC
Seta o valor da variável estática se cancelou ou não 
a tela de medicamentos controlados
@author  julio.nery
@version P12.1.17
@since   01/02/2019
@return  lRet, Lógico
/*/
//-------------------------------------------------------------------
Template Function DrSScrExMC( lSet )
Local lRet := .F.
lRet := LjDrSScrExMC(lSet)
Return lRet