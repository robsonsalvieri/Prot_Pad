#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LOJA1115.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณLOJA1115  บAutor  ณMicrosiga           บ Data ณ  03/12/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua o Envio e Recebimento dos dados de Saida e Entrada  บฑฑ
ฑฑบ          ณ ao Web Service de Integracao.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function LOJA1115(cEmp, cFil, cPdv)
Local oLJCConWS		:= Nil								// Instancia o Objeto
Local lPrepEnv		:= .F.								// Verifica se deve preparar o Ambiente
Local nTamE5Nat		:= ""								
Local oLJCLocker	:= Nil
Local oServer
Local aAux 			:= {}
Local cRPCServer	:= ""
Local nRPCPort		:= 0
Local cRPCEnv		:= ""
Local cRPCEmp		:= ""
Local cRPCFilial	:= ""
Local aAuxSer 		:= {}   // Array auxiliar para armazenar os servers 
Local aServers		:= {}   // Array que guarda os servers disponiveis
Local nFor			:= 0	// Contador do For
Local nX 			:= 1
Local lConnect		:= .F.
Local cMvNatTrc		:= ""						//Natureza do Troco
Local cMvNatSang	:= ""						//Natureza da Sangria

Private cEstacao	:= AllTrim(cPdv)
Default cEmp		:= ""							//Empresa para processamento
Default cFil		:= ""							//Filial para processamento
Default cPdv		:= "001"						// Conteudo do terceiro parametro (Parm3 do mp8srv.ini)

//Aguarda para evitar erro de __CInternet
Sleep(5000)

lPrepEnv := !Empty(cEmp) .AND. !Empty(cFil)

If lPrepEnv
	RPCSetType(3)
	If Len(GetApoInfo("framework.paf.PafEnvironment.tlpp")) > 0 //Verifica se existe o novo fonte da LIB, antes de chamar a nova fun็ใo criada pelo Frame
		totvs.framework.paf.setPafEnvironment(.T.) //Seta que o ambiente ้ PDV PAF, pois nใo deve consumir licen็a nos JOBs executados no ambiente do PDV PAF
	EndIf
	// "FRT" > Liberacao de acesso PDV cTree para o modulo FrontLoja
	RpcSetEnv(cEmp,cFil,Nil,Nil,"FRT")
Endif

DbSelectArea("SLG")
If SLG->(DbSeek(xFilial()+cPdv))

	aAux		:= FrtDadoRpc()
	
	If Len(aAux) > 0
	
		aAux[2] := Alltrim(aAux[2])
		cRPCServer	:= aAux[1]
		nRPCPort	:= Val(aAux[2])
		cRPCEnv		:= aAux[3]
		cRPCEmp		:= aAux[4]
		cRPCFilial	:= aAux[5]

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCarrega o numero de servidores disponiveis ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nFor := FrtServRpc()		
		
		For nX := 1 To nFor         
   	
			aAuxSer	:= FrtDadoRpc() //  Carrega os dados do server
		
			If ( !Empty(aAuxSer[1]) .AND. !Empty(aAuxSer[2]) .AND. !Empty(aAuxSer[3])) .AND.;
			   ( Alltrim(aAuxSer[1]) + Alltrim(aAuxSer[2]) 	  + Alltrim(aAuxSer[3]) )   <> 	;
			   ( Alltrim(cRPCServer) + Alltrim(Str(nRPCPort)) + Alltrim(cRPCEnv) )
			
				Aadd(aServers,{aAuxSer[1],Val(aAuxSer[2]),aAuxSer[3]})
			EndIf
		
			aAuxSer := {}
		Next nX   

		//"SIGALOJA PAF-ECF: Estabelecendo conexao RPC com o Servidor ("
		ConOut(STR0018+cRPCServer+")...")
		Conout(STR0019+cRPCEnv+STR0020+cRPCEmp+STR0021+cRPCFilial)	// "            Ambiente: " ### " Empresa: " ### " Filial: "

		oServer:=FwRpc():New( cRPCServer, nRPCPort , cRPCEnv )	// Instancia o objeto de oServer	
		oServer:SetRetryConnect(1)								// Tentativas de Conexoes
					
		For nX := 1 To Len(aServers)                            // Metodo para adicionar os Servers 
			oServer:AddServer( aServers[nX][1], aServers[nX][2], aServers[nX][3] )			
		Next nX 
				
		lConnect := oServer:Connect()							// Tenta efetuar conexao
		
		If lConnect
			oServer:SetEnv(cRPCEmp,cRPCFilial,"LOJA")                 // Prepara o ambiente no servidor alvo
		EndIf

		If ValType(oServer) == "O" .AND. lConnect
			//"SIGALOJA PAF-ECF: Conexao estabelecida com o Servidor ("
			ConOut(STR0022+cRPCServer + ":" + Alltrim(Str(nRPCPort)) + ").")	    
		Else
			// "SIGALOJA PAF-ECF: Nao foi possivel estabelecer conexao com o Servidor ("
			ConOut(STR0023+cRPCServer+")." )
			lConnect := .F.
		EndIf
	
	EndIf
Else
	//"PAF-ECF: A esta็ใo " + " configurada nใo existe. Verifique as configuracoes."
	ConOut(STR0024 + Alltrim(cPdv) + STR0025)	
EndIf	     
oLJCLocker := If( ExistFunc("LOJA0051") .And. SuperGetMV( "MV_LJILJLO",,"2" ) == "1", LJCGlobalLocker():New(), )	
If (If( ExistFunc("LOJA0051") .And. SuperGetMV( "MV_LJILJLO",,"2" ) == "1", oLJCLocker:GetLock( "LOJA1115ILLock" ), .T. )) .AND. lConnect
	
	nTamE5Nat := TamSX3("E5_NATUREZ")[1]
	cMvNatTrc	:= LjMExeParam("MV_NATTROC",,"TROCO")	//Natureza do Troco
	cMvNatSang	:= LjMExeParam("MV_NATSANG",,"SANGRIA")	//Natureza da Sangria

	//Instancia o Objeto
	oLJCConWS := LJCConexaoWS():New()

	//Roda a Integracao
	oLJCConWS:ExportaSaida(cEmp, cFil)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava Venda     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GravaSL1(cPDV)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava Reducao Z.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LjGrvRegWs("SFI",	 2, "SFI->FI_FILIAL + SFI->FI_SITUA", xFilial("SFI") + "00", "TX", "RX", cPDV)    
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava Sangria.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LjGrvRegWs("SE5",	 16, "SE5->E5_FILIAL + SE5->E5_SITUA + SE5->E5_NATUREZ", xFilial("SE5") + "00" + PADR(cMvNatSang, nTamE5Nat) , "OK", "OK", cPDV)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava Suprimento.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LjGrvRegWs("SE5",	 16, "SE5->E5_FILIAL + SE5->E5_SITUA + SE5->E5_NATUREZ", xFilial("SE5") + "00" + PADR(cMvNatTrc, nTamE5Nat), "OK", "OK", cPDV )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava SLW e SLT caso o parametro MV_LJCONFF esteja ativo e for PDV SigaLoja offline ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	If SuperGetMV( "MV_LJCONFF",,.F. )
		LjGrvRegWs("SLW",	 4, "SLW->LW_FILIAL + SLW->LW_SITUA", xFilial("SLW") + "00", "TX", "RX", cPDV, "Lj970Slw")				
		LjGrvRegWs("SLT",	 2, "SLT->LT_FILIAL + SLT->LT_SITUA", xFilial("SLT") + "00", "TX", "RX", cPDV )				
	EndIf 		
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava Cancelamento.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LjGrvCanWs(cPDV)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava Tabela de Apoio PAF-ECF.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If AliasInDic( "MDZ" )
		LjGrvRegWs("MDZ",	 2, "MDZ->MDZ_FILIAL + MDZ->MDZ_SITUA", xFilial("MDZ") + "00", "OK", "OK", cPDV )
	EndIf

	If HasTemplate("DRO")
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDados de Medicamento controlado LK9 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   
		LjGrvRegWs("LK9",	 3, "LK9->LK9_FILIAL + LK9->LK9_SITUA", xFilial("LK9") + "00", "TX", "RX",cPDV )  
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDados de Mov. pontos de cliente LHG ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		LjGrvRegWs("LHG",	 1, "LHG->LHG_FILIAL + LHG_CODIGO + LHG_LOJA + LHG_CARTAO", xFilial("LHG") + "00", "TX", "RX",cPDV )
	EndIf
	
	If HasTemplate("PCL")
		//Valida a aplica็ใo do UPDPCL04
		If AliasInDic("LEJ") .AND. ExistTemplate("TpPclVlInd") .AND. T_TpPclVlInd("LEJ",2)
			LjGrvRegWs("LEJ",	 2, "LEJ->LEJ_FILIAL + LEJ->LEJ_SITUA", xFilial("LEJ") + "00", "OK", "OK",cPDV )
		EndIf
	EndIf
	
	If( ExistFunc("LOJA0051") .And. SuperGetMV( "MV_LJILJLO",,"2" ) == "1", oLJCLocker:ReleaseLock( "LOJA1115ILLock" ),)
	
	If lPrepEnv
		RESET ENVIRONMENT
	EndIf
  
	If lConnect

		//"SIGALOJA PAF-ECF: Conexao estabelecida com o Servidor ("
		ConOut(STR0026+cRPCServer + ":" + Alltrim(Str(nRPCPort)) + ").")	    
		oServer:Disconnect()
		lConnect := .F. 
    EndIf
EndIF	

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    ณLJCConexaoWSบAutor  ณVendas Clientes   บ Data ณ  12/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua o Envio e Recebimento dos dados de Saida e Entrada  บฑฑ
ฑฑบ          ณ ao Web Service de Integracao.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCConexaoWS
	Data cCodAmb				//Codigo do Ambiente Atual
	Data cTrans					//Numero da Transacao Especifica
	Data cURL					//URL de Conexao ao Web Service
	Data lParam					//Parametros OK
	Data lEspecif				//Conexao Especifica ou Integracao
	Data lImpAut				//Determina se a Importacao dos dados vai ser Automatica

	Method New(lEspecif, cTrans)
	Method ExportaSaida()
	Method ImportaEntrada(oWSInt)
	Method EnviaDados(oWSInt, oDSxAmb)
	Method GravaStatus(lConnect, aDadEnv)
	Method ImportaSenha()
	Method LJRemCharEsp(xTexto)
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew       บAutor  ณVendas Clientes     บ Data ณ  05/03/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Instancia a classe que transmitira os Dados da Tabela de   บฑฑ
ฑฑบ          ณ Saida e recebera os dados para gravacao na Tabela de       บฑฑ
ฑฑบ          ณ Entrada.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpL1 - Define se e conexao especifica.                    บฑฑ
ฑฑบ          ณ ExpC2 - Numero da transacao especifica para Integracao.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New(lEspecif, cTrans) Class LJCConexaoWS

Local oEWebServ		:= LJCEntWebServices():New()	// ???
Local oDWebServ		:= NIL							// ???

Local cIP			:= ""                           //	???
Local cPorta		:= ""                           // ???
Local cEmpFil 		:= "9901"                       // ???

Default lEspecif 	:= .F.							// ???
Default cTrans		:= ""							// ???

::cCodAmb	:= AllTrim(SuperGetMV("MV_LJAMBIE", NIL, ""))
::lImpAut	:= SuperGetMV("MV_LJIMAUT", NIL, .F.)
::cTrans	:= cTrans
::lEspecif	:= lEspecif .AND. !Empty(cTrans)

If Empty(::cCodAmb)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณO parametro MV_LJAMBIE nao esta cadastrado, a Replicacao de dados nao sera realizada.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ConOut("LOJA1115 - 01 - " + Time() + " - " + STR0001)
	::cURL := ""
Else
	oEWebServ:DadosSet("MD3_CODAMB", ::cCodAmb)
	If ::lEspecif
		oEWebServ:DadosSet("MD3_TIPO", "E")
	Else
		oEWebServ:DadosSet("MD3_TIPO", "I")
	EndIf
	
	oDWebServ := oEWebServ:Consultar(1)		//Filial + Ambiente + Tipo
	
	//Verifica se tem Web Service Cadastrado para este Ambiente
	If oDWebServ:Count() > 0
		//So recupera o primeiro registro, pois apenas permite
		// o cadastramento de um Web Service de cada Tipo por Ambiente
		cIP			:= AllTrim(oDWebServ:Elements(1):DadosGet("MD3_IP"))
		cPorta		:= AllTrim(oDWebServ:Elements(1):DadosGet("MD3_PORTA"))
		cEmpFil		:= AllTrim(oDWebServ:Elements(1):DadosGet("MD3_EMPFIL"))
		
	EndIf
	
	
	If !Empty(cIP) .AND. !Empty(cPorta)
		::cURL	:= "http://" + cIP + ":"
		If Empty(cEmpFil)
			::cURL	+= cPorta + "/LJWIntegracao.APW"
		Else
			::cURL	+= cPorta +"/" + cEmpFil + "/LJWIntegracao.APW"
		Endif
	Endif
Endif

If Empty(::cURL)
	ConOut("LOJA1115 - 02 - " + Time() + " - " + STR0002)			//"Verifique o Cadastro de Web Services, pois estใo faltando informac๕es para a Conexao."
Endif

::lParam := !Empty(::cCodAmb) .AND. !Empty(::cURL)

If ::lEspecif
	::ExportaSaida()
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบMetodo    ณExportaSaidaบAutor  ณVendas Clientes    บ Data ณ  05/03/08  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a exportacao dos dados da Integracao para o Web Serviceบฑฑ
ฑฑบ          ณ configurado no Construtor (New).                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ExportaSaida(cEmp, cFil) Class LJCConexaoWS

Local lLink			:= .T.										//Comunicacao com o Web Service
Local nI			:= 0										//Contador
Local nJ			:= 0										//Contador
Local nK			:= 1										//Contador
Local nItens		:= 0										//Quantidade de registros por transacao
Local nIndSxAmb		:= 0										//Indice da Tabela Saida x Ambiente
Local nTrans		:= 0										//Quantidade de Transacoes
Local nTotReg		:= 0										//Numero total de registros na transacao
Local nPacote		:= 1										//Numero do pacote
Local nTamPac		:= SuperGetMV("MV_LJTMPAC", NIL, 0)			//Tamanho maximo do pacote (em registros)
Local nTamPACOTE	:= TamSX3("MD6_PACOTE")						//Tamanho do campo PACOTE

Local oDSaida													//Dados da Entidade Saida
Local oDSxAmb													//Dados da Entidade Saida x Ambiente
Local oESaida													//Entidade Saida x Ambiente
Local oESxAmb													//Entidade Saida
Local oWSInt													//Conexao Web Service

DEFAULT  cFil			:= ''
DEFAULT  cEmp			:= ''

If ::lParam
	
	// Fixa limite para o tamanho maximo do pacote
	If nTamPac == 0 .OR. nTamPac > 500
		nTamPac := 500 // Numero maximo obtido atraves da transacao de venda
	Endif
	
	ConOut("LOJA1115 - 03 - " + Time() + " - " + STR0006)		//"Inicio do processamento..."
	
	oESxAmb := LJCEntSaidaAmb():New()
	
	//Atribui parametros para pesquisa
	oESxAmb:DadosSet("MD7_STATUS"	,"1")
	If ::lEspecif
		oESxAmb:DadosSet("MD7_TRANS"	,::cTrans)
		nIndSxAmb := 2		//Status + Transacao + Destino
	Else
		nIndSxAmb := 3		//Status + Destino
	Endif
	oESxAmb:DadosSet("MD7_DEST"	,::cCodAmb)
	
	//Consulta Tabela de Saida x Ambiente e atribui ao objeto oDadosAmb
	oDSxAmb	:= oESxAmb:Consultar(nIndSxAmb)
	
	//Guarda o numero de Transacoes
	nTrans	:= oDSxAmb:Count()
	
	//Instancia o Web Service
	oWSInt	:= WSLJWIntegracao():New()
	iIf(ExistFunc("LjWsGetAut"),LjWsGetAut(@oWSInt),Nil) //Monta o Header de Autentica็ใo do Web Service
	
	//URL de Conexao ao Web Service
	oWSInt:_URL := ::cURL
	
	//Informa Empresa e Filial
	oWSInt:ccEmp := cEmpAnt
	oWSInt:ccFil := cFilAnt
	
	//Informa o Ambiente de Origem
	oWSInt:ccAmbiente := ::cCodAmb
	
	//Determina se realiza a Importacao dos dados
	oWSInt:llExporta := !::lEspecif
	
	//Inicializa a dimensao OutData
	oWSInt:oWSaOutData := LJWIntegracao_OutData():New()
	
	//Cria o Array para insercao das Transacoes
	oWSInt:oWSaOutData:oWSNewOutTrans := LJWIntegracao_ArrayOfOutTrans():New()
	
	For nI := 1 to nTrans
		//Reinicializa Estrutura
		oESaida := LJCEntSaida():New()
		
		//Procura a Transacao na Tabela de Saida
		oESaida:DadosSet("MD6_TRANS" , oDSxAmb:Elements(nI):DadosGet("MD7_TRANS"))
		oESaida:DadosSet("MD6_PACOTE", "")
		
		//Faz a Consulta e atribui os dados ao Objeto oDSaida
		oDSaida	:= oESaida:Consultar(1)	//MD6_TRANS+MD6_PACOTE+MD6_REG+MD6_SEQ
		
		//Guardo o total de registros da transacao e o numero do proximo pacote
		If !Empty(oDSxAmb:Elements(nI):DadosGet("MD7_TRCNT"))
			nTotReg := Val(oDSxAmb:Elements(nI):DadosGet("MD7_TRCNT"))
			nPacote := Val(oDSxAmb:Elements(nI):DadosGet("MD7_ULTPAC")) + 1
		Else
			nTotReg := oDSaida:Count()
			nPacote := 1
			nK      := 1
		Endif
		
		//Guarda o numero de Itens
		nItens	:= oDSaida:Count()
		
		//Adiciona uma nova Transacao
		Aadd(oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans, LJWIntegracao_OutTrans():New())
		
		//Cria o Array para insercao dos Itens
		oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg := LJWIntegracao_ArrayOfOutReg():New()
		
		For nJ := 1 to nItens
			If nK > nTamPac
				//Envia pacote para a matriz
				If !::EnviaDados(oWSInt, oDSxAmb)
					lLink := .F.
					Exit
				Endif
				
				//Incrementa numero do pacote
				nK := 1
				nPacote += 1
				
				//Reinicializa array de saida
				oWSInt:oWSaOutData := LJWIntegracao_OutData():New()
				oWSInt:oWSaOutData:oWSNewOutTrans := LJWIntegracao_ArrayOfOutTrans():New()
				aAdd(oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans, LJWIntegracao_OutTrans():New())
				oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg := LJWIntegracao_ArrayOfOutReg():New()
			Endif
			
			//Inicializa o Item
			Aadd(oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg, LJWIntegracao_OutReg():New())
			
			//Instancia os Campos do Item
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cTransacao		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_TRANS"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cRegistro		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_REG"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cSequencia		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_SEQ"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cTipoCampo		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_TPCPO"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cNome			:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_NOME"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cValor			:= ::LJRemCharEsp(AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_VALOR")))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cTipo			:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_TIPO"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cOrigem		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_ORIGEM"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cServWeb		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_SERVWB"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cModulo		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_MODULO"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cStatusT		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_STATUS"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cSitPro 		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_SITPRO"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cProcesso		:= AllTrim(oDSaida:Elements(nJ):DadosGet("MD6_PROCES"))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:dDataOut		:= oDSaida:Elements(nJ):DadosGet("MD6_DATA")
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cTotReg		:= lTrim(Str(nTotReg))
			oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg[nK]:cPacote		:= StrZero(nPacote, nTamPACOTE[1])
			
			
			//Incrementa contador
			nK += 1
		Next nJ
		
		If lLink
			//Envia transacao para a matriz
			If !::EnviaDados(oWSInt, oDSxAmb)
				lLink := .F.
				Exit
			Endif
			
			//Reinicializa array de saida
			oWSInt:oWSaOutData := LJWIntegracao_OutData():New()
			oWSInt:oWSaOutData:oWSNewOutTrans := LJWIntegracao_ArrayOfOutTrans():New()
		Endif
	Next nI
	
	If lLink
		//Se nao for Conexao Especifica, importa tabela de entrada
		If !::lEspecif
			//Grava tabela de Entrada
			::ImportaEntrada(oWSInt)
		Endif
	Endif
Endif

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณ EnviaDados    บAutor  ณVendas Clientesบ Data ณ  12/11/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia os dados do pacote para o Web Service                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1 - Objeto Client do Web Service instanciado no metodo บฑฑ
ฑฑบ          ณ         Exporta Saida.                                     บฑฑ
ฑฑบ          ณ Exp02 - Dados da Entidade Saida x Ambiente.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method EnviaDados(oWSInt, oDSxAmb) Class LJCConexaoWS

Local cSvcError		:= ""										//Mensagem de Erro da Conexao
Local cSoapFCode	:= ""										//Codigo do Erro
Local cSoapFDescr	:= ""										//Descricao do Erro

Local lLink			:= .T.										//Erro de comunicacao com o Web Service
Local lConnect		:= .T.										//Informa se a Conexao foi bem sucedida
Local aDadEnv		:= {}										//Dados a enviar
Local cMsg			:= ""										//Mensagem sobre o pacote enviado

ConOut("LOJA1115 - 03-B - " + Time() + " - " + STR0007 + cMsg)			//"Transmitindo dados..."

//Verifica se o pacote possue dados
If ValType(oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans) == "A"
	aDadEnv := aClone(oWSInt:oWSaOutData:oWSNewOutTrans:oWSOutTrans[1]:oWSNewOutReg:oWSOutReg)
	cMsg := STR0016 + aDadEnv[1]:cTransacao + STR0017 + aDadEnv[1]:cPacote
	
	ConOut("LOJA1115 - 04 - " + Time() + " - " + STR0007 + cMsg)			//"Transmitindo dados..."

	lConnect := oWSInt:Connect()

	ConOut("LOJA1115 - 04B - ", lConnect)
	
	ConOut("LOJA1115 - 05 - " + Time() + " - " + STR0008)					//"Retorno da Conexao..."
	
	//Conectar ao Web Service para envio
	If !lConnect .OR. ValType(lConnect) == "U"
		cSvcError := GetWSCError()
		If Left(cSvcError, 9) == "WSCERR048"
			cSoapFCode  := Alltrim(Substr(GetWSCError(3), 1, At(":",GetWSCError(3))-1))
			cSoapFDescr := Alltrim(Substr(GetWSCError(3), At(":",GetWSCError(3))+1, Len(GetWSCError(3))))
			Conout("LOJA1115 - 06 - " + Time() + " - Err WS :" + cSoapFDescr + " -> " + cSoapFCode)
		Else
			lLink := .F.
			ConOut("LOJA1115 - 07 - " + Time() + " - " + STR0003 + ::cURL)		//"Sem Comunicacao com o Web Service: "
		Endif
	Endif
	
	If lLink
		If Len(aDadEnv) > 0
			//Grava o Status da Transmissao de Dados
			::GravaStatus(lConnect, aDadEnv)
		Endif
	Endif      	
Endif

Return(lLink)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณImportaEntrada บAutor  ณVendas Clientesบ Data ณ  05/03/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava os dados recebidos no retorno do Web Service de      บฑฑ
ฑฑบ          ณ Integracao e grava na tabela de Entrada.                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpO1 - Objeto Client do Web Service instanciado no metodo บฑฑ
ฑฑบ          ณ         Exporta Saida.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ImportaEntrada(oWSInt) Class LJCConexaoWS

Local nI			:= 0									//Contador
Local nItens	 	:= 0									//Quantidade de Itens por Transacao
Local nJ			:= 0									//Contador
Local nTrans		:= 0									//Quantidade de Transacoes
Local lLock			:= .T.									//Define se deve reservar um numero de Transacao
Local oEntIn		:= LJCEntEntrada():New()				//Entidade Entrada
Local oCloneIn		:= oEntIn:Clonar()						//Guarda a Estrutura da Tabela de Entrada
Local oTrans												//Controle de Transacoes
Local lLJImAut		:= SuperGetMV("MV_LJIMAUT", NIL, .F.)	//Importacao dos Dados Automatica

oWSInt:Connect()

If ValType(oWSInt:oWSConnectResult:oWSNewInTrans) <> "U"
	//Recupera o Numero de Transacoes
	nTrans := Len(oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans)
Else
	// Busca dados para inporta็ใo na Matriz
	oWSInt:Connect()
	//Recupera o Numero de Transacoes
	nTrans := Len(oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans)
Endif

If nTrans > 0
	ConOut("LOJA1115 - 08 - " + Time() + " - " + STR0009)		//"Gravando Tabela de Entrada..."
EndIf

//Tratamento para gravacao na Tabela de Entrada
For nI := 1 to nTrans
	If lLock
		//Instancia o Controle de Transacoes e Reserva o Proximo Numero
		oTrans := LJCGetTrans():New("MD8")
	Endif
	
	//Guarda o numero de Itens
	nItens := Len(oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg)
	
	Begin Transaction
	//Tratamento para gravacao dos Registros
	For nJ := 1 to nItens
		//Recupera estrutura da Tabela
		oEntIn		:= oCloneIn:Clonar()
		
		cTransOri	:= oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cTransacao
		
		//Atribui os dados para gravacao da Tabela de Entrada
		oEntIn:DadosSet("MD8_TRANS"		,oTrans:GetTrans())
		oEntIn:DadosSet("MD8_REG"		,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cRegistro)
		oEntIn:DadosSet("MD8_SEQ"		,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cSequencia)
		oEntIn:DadosSet("MD8_TPCPO"		,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cTipoCampo)
		oEntIn:DadosSet("MD8_NOME"		,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cNome)
		oEntIn:DadosSet("MD8_VALOR"		,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cValor)
		oEntIn:DadosSet("MD8_TIPO"		,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cTipo)
		oEntIn:DadosSet("MD8_ORIGEM"	,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cOrigem)
		oEntIn:DadosSet("MD8_SERVWB"	,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cServWeb)
		oEntIn:DadosSet("MD8_MODULO"	,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cModulo)
		oEntIn:DadosSet("MD8_STATUS"	,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cStatusT)
		oEntIn:DadosSet("MD8_SITPRO"	,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cSitPro)
		oEntIn:DadosSet("MD8_PROCES"	,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cProcesso)
		oEntIn:DadosSet("MD8_DATA"		,DToC(dDataBase))
		oEntIn:DadosSet("MD8_TRCNT"		,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cTotReg)
		oEntIn:DadosSet("MD8_PACOTE"	,oWSInt:oWSConnectResult:oWSNewInTrans:oWSInTrans[nI]:oWSNewInREg:oWSInReg[nJ]:cPacote)
		
		//Grava tabela de Entrada
		oEntIn:Incluir()
	Next nJ
	//Destrava o Numero da Transacao
	oTrans:FreeTrans()
	//Pode reservar a proxima Transacao
	lLock := .T.
	End Transaction
Next nI

ConOut("LOJA1115 - 10 - " + Time() + " - " + STR0005)		//"Final do Processamento dos dados recebidos..."

::ImportaSenha()

If lLJImAut
	StartJob("LOJA1123", GetEnvServer(), .F., cEmpAnt, cFilAnt)
Endif
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบMetodo    ณGravaStatus บAutor  ณVendas Clientes    บ Data ณ  05/03/08  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava o Status da Exportacao de dados na tabela            บฑฑ
ฑฑบ          ณ Saida x Ambientes.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpL1 - Define se conseguiu conexao com o Web Service.     บฑฑ
ฑฑบ          ณ ExpA2 - Conteudo do pacote.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GravaStatus(lConnect, aDadEnv) Class LJCConexaoWS

Local cStatusPac		:= "1"			//Status da transmissao do pacote
Local cStatusTrn		:= "1"			//Status da transmissao de todos os pacotes da transacao
Local nTamDad			:= Len(aDadEnv)	//Tamanho do array com os dados enviados
Local nX				:= 0			//Contador
Local oEGrvSxAmb						//Estrutura da Tabela Saida x Ambientes
Local oESaida

Default lConnect		:= .F.			//Verifica se a Transmissao de dados foi bem sucedida

ConOut("LOJA1115 - 11 - " + Time() + " - " + STR0010)		//"Gravando Status da Tabela de Saida..."

If lConnect
	cStatusPac := "2"				//2-Transmissao OK
	
	//Verifica se eh o ultimo pacote
	If AllTrim(aDadEnv[nTamDad]:cServWeb) == AllTrim(aDadEnv[nTamDad]:cTotReg)
		cStatusTrn := "2"
	Endif
Else
	cStatusPac := "3"				//3-Erro Transmissao
Endif

//Recupera Estrutura da Tabela Saida x Ambientes
oEGrvSxAmb := LJCEntSaidaAmb():New()

//Instancia os Dados da Tabela Saida x Ambientes que devem ser alterados
oEGrvSxAmb:DadosSet("MD7_DEST"  , ::cCodAmb)
oEGrvSxAmb:DadosSet("MD7_STATUS", cStatusTrn)
oEGrvSxAmb:DadosSet("MD7_TRANS" , aDadEnv[nTamDad]:cTransacao)
oEGrvSxAmb:DadosSet("MD7_ULTPAC", aDadEnv[nTamDad]:cPacote)
oEGrvSxAmb:DadosSet("MD7_TRCNT" , aDadEnv[nTamDad]:cTotReg)

//Grava a alteracao do Status
oEGrvSxAmb:Alterar(1)	//Transacao + Destino

//Recupera Tabela de Saida
oESaida := LJCEntSaida():New()

//Atualiza MD6 com as informacoes
For nX := 1 to nTamDad
	oESaida:DadosSet("MD6_TRANS" , aDadEnv[nX]:cTransacao)
	oESaida:DadosSet("MD6_REG"   , aDadEnv[nX]:cRegistro)
	oESaida:DadosSet("MD6_SEQ"   , aDadEnv[nX]:cSequencia)
	oESaida:DadosSet("MD6_TRCNT" , aDadEnv[nX]:cTotReg)
	oESaida:DadosSet("MD6_PACOTE", aDadEnv[nX]:cPacote)
	oESaida:Alterar(1)
Next nX

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบMetodo    ณImportaSenhaบAutor  ณVendas Clientes    บ Data ณ  26/09/08  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa o arquivo de senhas e a tabela 23 de caixas        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Nao ha                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method ImportaSenha() Class LJCConexaoWS

Local cArqINI   := GetAdv97()                       								//Retorna o nome do arquivo INI do server
Local cRPCSrv 	:= GetPvProfString("LojaOffLine", "IP", "", cArqINI) 				// Endereco IP do servidor Protheus
Local nRPCPrt 	:= Val(GetPvProfString("LojaOffLine", "Porta", "", cArqINI)) 		// Porta do servidor Protheus
Local cRPCEnv 	:= GetPvProfString("LojaOffLine", "Ambiente", "", cArqINI) 			// Ambiente
Local cRPCEmp 	:= GetPvProfString("LojaOffLine", "Empresa", "", cArqINI) 			// Empresa
Local cRPCFil 	:= GetPvProfString("LojaOffLine", "Filial", "", cArqINI) 			// Filial
Local nIntervalo:= Val(GetPvProfString("LojaOffLine", "Intervalo", "0", cArqINI))	// Tempo de Intervalo para atualizacao do arquivo de senhas (em minutos)
Local cProxAtu	:= GetPvProfString("LojaOffLine", "ProximaSincro", "", cArqINI) 	// Data e Hora da proxima atualizacao do arquivo de senhas
Local aRet    	:= {} 																// Array que recebera a tabela de caixas
Local oServer 	:= Nil 																// Objeto conexao RPC
Local dDataAtu 	:= Date()
Local cHoraAtu 	:= Time()
Local dUltData
Local nUltHora	:= 0
Local nUltMin	:= 0
Local nSomaDia	:= 0
Local nSomaHora	:= 0
Local nSomaMin	:= 0
Local cMessage	:= ""
Local lUserInDB := MPIsUsrInDB() 													// Se os usuarios do sistema estao no banco de dados (Dicionแrio no Banco)
Local nQtdSecond:= 0

//Verifica se existir a parametrizacao no INI que define o intervalo de atualizacao do arquivo de senhas
If nIntervalo > 0
	
	cProxAtu := Left(cProxAtu,13)
	
	If Empty(cProxAtu)
		cProxAtu := DtoS(dDataAtu)+SubStr(cHoraAtu,1,5)
	EndIf
	
	//Verifica se estah na hora de sincronizar o arquivo de senhas
	If dToS(dDataAtu)+StrTran(SubStr(cHoraAtu,1,5),":") >= StrTran(cProxAtu,":")
		
		dUltData := dDataAtu
    	nUltHora := Val(SubStr(cHoraAtu,1,2))
    	nUltMin  := Val(SubStr(cHoraAtu,4,2))
		
	    //Calcula a data e hora da proxima sincronizacao do arquivo de senhas
	    nSomaDia := Int(nIntervalo / 60 / 24)
	    nSomaHora:= Int(nIntervalo / 60) - (nSomaDia * 24)
	    nSomaMin := Mod(nIntervalo,60)
	    
	    dUltData := dUltData + nSomaDia
	    nUltHora := nUltHora + nSomaHora
	    nUltMin  := nUltMin  + nSomaMin
	    
	    //Ajusta o minuto se necessario (caso atinja 59 minutos, vira para 00)
	    If nUltMin > 59
		    nUltMin := nUltMin - 60
		    nUltHora:= nUltHora + 1
		EndIf
		
	    //Ajusta a hora se necessario (caso atinja 23 horas, vira para 00)
	    If nUltHora > 23
		    nUltHora := nUltHora - 24
		    dUltData := dUltData + 1
		EndIf
	    
	    //Data/Hora definida para proxima sincronizacao do arquivo de senhas
		cProxAtu := DtoS(dUltData)+StrZero(nUltHora,2)+":"+StrZero(nUltMin,2)
		
		//Atualiza a chave "ProximaSincro" (proxima data/hora que o arquivo de senhas sera sincronizado com a retaguarda)
		WritePProString("LojaOffLine", "ProximaSincro",	cProxAtu,	cArqINI)
		
	Else
	
		ConOut("LOJA1115 - 17 - " + Time() + " - " + STR0027 + " " + DtoC(StoD(SubStr(cProxAtu,1,8))) + " - " + Right(cProxAtu,5) ) //"Proxima atualizacao de senhas/caixas sera realizada em:" ###
		//Abandona sem efetuar a atualizacao do arquivo de senhas
		Return Nil
		
	EndIf

EndIf

ConOut("LOJA1115 - 12 - " + Time() + " - " + STR0011) 								// "Iniciando atualizacao de senhas/caixas"

// Verifica se os parametros foram passados
If Empty(cRPCSrv) ;
	.OR. Empty(nRPCPrt) ;
	.OR. Empty(cRPCEnv) ;
	.OR. Empty(cRPCEmp) ;
	.OR. Empty(cRPCFil)
	
	ConOut("LOJA1115 - 13 - " + Time() + " - " + STR0012) // "Atualizacao de senhas/caixas nao realizada - falta configurar parametros"
	Return(NIL)
Endif

CREATE RPCCONN oServer ON SERVER cRPCSrv ;
PORT nRPCPrt ;
ENVIRONMENT cRPCEnv ;
EMPRESA cRPCEmp ;
FILIAL cRPCFil ;
MODULO "LOJA"

// atualiza senhas
If ValType(oServer) == "O"
	nQtdSecond := Seconds()
	If (!lUserInDB .And. pswGetSinc(oServer)) .Or. (lUserInDB .And. MPUsrSync( "", "", cRPCEnv,cRPCSrv,nRPCPrt,@cMessage ))
		
		nQtdSecond := Seconds()-nQtdSecond
		Conout("--------------------------------------------------")
		ConOut("Tempo de sincronizacao de usuarios: " + Str(nQtdSecond))
		LjGrvLog( "LOJA1115", "Tempo de sincronizacao de usuarios: " + AllTrim(Str(nQtdSecond)) )
		Conout("--------------------------------------------------")

		// busca tabela de caixas
		aRet := oServer:CallProc("FRTTXSX5")
		If ValType(aRet) == "A"
			// atualiza tabela de caixas
			FRTRXSX5(aRet)
			ConOut("LOJA1115 - 14 - " + Time() + " - " + STR0013) // "Atualizacao de senhas/caixas realizada com sucesso"
		Else
			ConOut("LOJA1115 - 15 - " + Time() + " - " + STR0014) // "Atualizacao de senhas/caixas nao realizada - tabela de caixas em uso"
		Endif
	Else
		ConOut("LOJA1115 - 16 - " + Time() + " - " + STR0015) // "Atualizacao de senhas/caixas nao realizada - arquivo de senhas em uso ou problema ao sincronizar tabela de usuแrios do sistema"
	Endif

	RESET ENVIRONMENT IN SERVER oServer
	CLOSE RPCCONN oServer
Endif

Return(NIL)
         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบMetodo    ณLJRemCharEspบAutor  ณVendas Clientes    บ Data ณ  01/06/10  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera caracteres especiais	       						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpX1 - Texto para troca de caracteres especiais.		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD LJRemCharEsp( xTexto ) CLASS LJCConexaoWS
Local TextoAux 	:= ""
Local cCaracter	:= ""
Local nX 		:= 0
    
If ValType(xTexto) == "C"
	For nX := 1 to Len(xTexto) 
		cCaracter := SubStr(xTexto, nX, 1)
		If cCaracter $ "ü์ลษุ"
			Do Case
				Case cCaracter  == "ü"
					TextoAux += "u"
				Case cCaracter  == "์"
			 		TextoAux += "i"
			 	Case cCaracter  == "ล"
			 		TextoAux += "A"
			 	Case cCaracter  == "ษ"
			 		TextoAux += "E"
			 	Case cCaracter  == "ุ"
			 		TextoAux += "0"	
				OtherWise
					TextoAux += cCaracter
			EndCase	
		Else
			TextoAux += cCaracter
		EndIf
	Next nX 
	
	xTexto := TextoAux
EndIf 
 
Return xTexto
