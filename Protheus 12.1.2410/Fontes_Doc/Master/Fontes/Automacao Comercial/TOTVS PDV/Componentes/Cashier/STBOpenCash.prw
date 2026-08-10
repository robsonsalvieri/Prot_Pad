#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"   
#INCLUDE "STBOPENCASH.CH"

Static	 	nHandleCX		:= 0				// Handle do arquivo de caixa criado na abertura de caixa

//-------------------------------------------------------------------
/*/{Protheus.doc} STBOpenCash
Verifica se o caixa esta esta aberto    

@param
@author  Varejo
@version P11.8
@since   02/07/2012
@return  lRet	retorna se o caixa esta aberto

@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STBOpenCash()

Local lRet 			:= .F.	// Retorno
Local cNumMov 		:= ""	// Numero do movimento
Local cNumCashier	:= ""	// Numero do caixa

cNumCashier			:=	xNumCaixa()  
cNumMov 			:= 	STDNumMov()

If cNumMov <> ""
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBInfoEst
Retorna Informacoes referente a estacao    

@param   nOpc  			1: Retorna array com dados | 2: retorna string com dados
@param   lFormat		Retorna formatacao do SX3
@param   lRetSize		Define se no array de retorno sera add tamanho do campo

@author  Varejo
@version P11.8
@since   02/07/2012
@return  uRet		 	[1]CAIXA [2]ESTACAO [3]SERIE [4]PDV

@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STBInfoEst(		nOpc	,	lFormat	,	lRetSize)

Local aStation		:= {}		// Array com informacoes da estacao
Local aTMP			:= {}		// Array temporario
Local uRet			:= ""		// Variavel indefinida para retorno

Default nOpc			:=  1			// 1: Retorna array com dados | 2: retorna string com dados
Default lFormat		:= .F.			// Retorna formatacao do SX3?
Default lRetSize		:= .F.			// Define se no array de retorno sera add tamanho do campo

ParamType 0 Var 		nOpc 			As Numeric		Default 1	
ParamType 1 var  	lFormat		As Logical		Default .F.
ParamType 2 var  	lRetSize		As Logical		Default .F.

// Guarda no array temporario as informacoes da estacao
aTMP := STFGetStat({"CODIGO","SERIE","PDV","SERNFIS"})

If Len(aTMP) > 0

	//Caso nao se utilize o retorno de tamanho de campos ou a opcao de retorno seja de string
	If !lRetSize .OR. nOpc <> 1
		
		aStation := Array(5)
		
		If !lFormat
			aStation[1] := AllTrim(xNumCaixa())
			aStation[2] := AllTrim(aTMP[1])
			aStation[3] := AllTrim(aTMP[2])
			aStation[4] := AllTrim(aTMP[3])
			aStation[5] := AllTrim(aTMP[4])
		Else
			aStation[1] := PadR(AllTrim(xNumCaixa()),TamSX3("L1_OPERADO")[1])
			aStation[2] := PadR(AllTrim(aTMP[1]),TamSX3("LG_CODIGO")[1])
			aStation[3] := PadR(AllTrim(aTMP[2]),TamSX3("LG_SERIE")[1])
			aStation[4] := PadR(AllTrim(aTMP[3]),TamSX3("LG_PDV")[1])
			aStation[5] := PadR(AllTrim(aTMP[4]),TamSX3("LG_SERNFIS")[1])
		Endif
	
		If nOpc == 1
			uRet := aStation
		Else
			aEval(aStation,{|x| uRet += x})
		Endif	
		
	Else
	
		aStation := Array(5,2)
		
		If !lFormat
			aStation[1][1] := AllTrim(xNumCaixa())
			aStation[2][1] := AllTrim(aTMP[1])
			aStation[3][1] := AllTrim(aTMP[2])
			aStation[4][1] := AllTrim(aTMP[3])
			aStation[5][1] := AllTrim(aTMP[4])
		Else
			aStation[1][1] := PadR(AllTrim(xNumCaixa()),TamSX3("L1_OPERADO")[1])
			aStation[2][1] := PadR(AllTrim(aTMP[1]),TamSX3("LG_CODIGO")[1])
			aStation[3][1] := PadR(AllTrim(aTMP[2]),TamSX3("LG_SERIE")[1])
			aStation[4][1] := PadR(AllTrim(aTMP[3]),TamSX3("LG_PDV")[1])
			aStation[5][1] := PadR(AllTrim(aTMP[4]),TamSX3("LG_SERNFIS")[1])
		Endif
		
		aStation[1][2] := TamSX3("L1_OPERADO")[1]
		aStation[2][2] := TamSX3("LG_CODIGO")[1]
		aStation[3][2] := TamSX3("LG_SERIE")[1]
		aStation[4][2] := TamSX3("LG_PDV")[1]
		aStation[5][2] := TamSX3("LG_SERNFIS")[1]
		
		If nOpc == 1
			uRet := aStation
		Else
			aEval(aStation,{|x| uRet += x[1]})
		EndIf
				
	EndIf
	
EndIf

Return uRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FR271BSemaforo
Cria um Semaforo em Arquivo

@param cType				Tipo operacao
@param cStation			Estacao
 
@author  Varejo
@version P11.8
@since   04/07/2012
@return  lRet 	Retorna se conseguiu gravar semaforo
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBTraffic( cType, cStation )

Local 	lRet			:= .T.				// Retorno
Local  lMobile 		:= STFGetCfg("lMobile", .F.)		//Smart Client Mobile

Default cType			:= "CON"			// Tipo operacao
Default cStation			:= ""				// Estacao

ParamType 0 Var 	cType				As Character		Default  "CON"			
ParamType 1 var  	cStation			As Character		Default  ""			

lMobile := ValType(lMobile) == "L" .AND. lMobile

//Em versoes Mobile nao faz controle por arquivo 
//fisico apenas por registros em Base de dados
If !lMobile 

	// Se nao existir o diretorio cria
	If !ExistDir("\SEMAFORO\SIGAFRT\")
		MakeDir("\SEMAFORO\SIGAFRT\")
	EndIf
	
	// Tenta criar o arquivo de semaforo
	nHandleCX := MSFCreate("\SEMAFORO\SIGAFRT\"+StrTran(cType+cFilAnt+cStation," ","")+".L"+StrTran(cEmpAnt," ",""))
	
	IF nHandleCX < 0
		// Nao conseguiu criar arquivo de semaforo
		lRet := .F.
	EndIf
	
EndIf	
							
// Grava SLI							
STFSLICreate( cStation, "CON", "|||||", "SOBREPOE" )

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} FR271BSemaforo
Retorna o Handle do arquivo de caixa criado na abertura de caixa

@author  Varejo
@version P11.8
@since   04/07/2012
@return  nHandleCX 	Retorna o Handle do arquivo de caixa criado na abertura de caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBGetCXHnd()
Return nHandleCX


//-------------------------------------------------------------------
/*/{Protheus.doc} STBAutOpenCash
Verifica Autorizacao(permissao) de usuario e caixa para 
Abrir/Fechar/Reabrir o caixa

@param 

@author  Varejo
@version P11.8
@since   13/07/2012
@return  aRet[1]Retorna permissao
@return  aRet[2]Supervisor/Usuario
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBAutOpenCash()

Local cSupervisor 	:= ""			// Usuario Supervisor
Local lRet			:= {} 			// Validacao
Local aRet			:= {.F.,""}	// Retorno com validacao se esta autorizado e usuario supervisor
Local aMov			:= {}			// array com informacoes do movimento

// Verifica permissao de usuario
If ChkPsw(41)
	
	//Verifica permissao de caixa	
	aMov := STDNumMov( {{"LW_NUMMOV","LW_DTFECHA"}} )
	
	// Se o caixa ja foi fechado na data atual, Ver permissao para reabrir             
	If ValType(aMov) == "A" .AND. Len(aMov) > 1
		If aMov[2] == dDataBase 
		   aRet := STFProFile(16) // 16 - Permissao para Reabrir o Caixa
		EndIf   
	Else
		aRet := STFProFile(4)// 04 - Permissao para abrir e fechar o caixa
	Endif
	
	If !aRet[1]
	
	    If lUsaDisplay                    
	 		// Inicia Evento
			STFFireEvent(ProcName(0), "STDisplay", { StatDisplay(), "2C"+ STR0001 } ) //"Senha invalida ou acesso negado"
		End
		
		// Usuario / sem permissao para Abrir/Reabrir/Fechar o Caixa. / Atenção	
		STFMessage("OpenCash","STOP", STR0003 + cUserName + STR0002)	 //"Atencao, Usuario,  Sem permissao para Abrir/Reabrir/Fechar o Caixa."

	Endif	

EndIf

Return aRet



//-------------------------------------------------------------------
/*/{Protheus.doc} STBDtCash
Pega data para realizar abertura do caixa

@param 
@author  Varejo
@version P11.8
@since   13/07/2012
@return  aDtHr 	Retorna array com data e hora [1]Data [2]hora 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBDtCash()

Local 		aDtHr 		:= Array(2)

aDtHr[1] 	:= Date()
aDtHr[2] 	:= Time()

Return aDtHr


//-------------------------------------------------------------------
/*/{Protheus.doc} STBOpenLX
Emite leitura X na abertura do caixa
segundo a regra de negocios

@param 
@author  Varejo
@version P11.8
@since   13/07/2012
@return  lRet Retorno
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBOpenLX()

Local lRet			    := .T.					// Retorno
Local dDtLastMov		:= STDGtLstMov()	 	// Pega data do ultimo fechamento antes de abrir
Local lEmitNFCe         := LjEmitNFCe()     //Indica a utilizacao da NFC-e

// Verifica Legislacao se e necessario a Emissao
// de uma Leitura X na primeira abertura do Caixa no dia		  		
If !lEmitNFCe .AND. LJAnalisaLeg(42)[1]
	// Se a data do ultimo fechamento for menor que a data atual emite leitura X
	If dDtLastMov < dDatabase .and. STDEmitLeitX() // Verifica se já imprimiu uma vez a Leitura X
	
		LJMsgLeg( LJAnalisaLeg(42) )
		// Inicia Evento
		STFFireEvent(ProcName(0), "STReadingX", {} ) // Leitura X
		
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGtFstMov
Verifica se a leitura x ja foi impressa quando a tela de venda
não é fechado de um dia para outro.  
@author  Varejo
@version P11.8
@since   03/11/2015
@return  lRet
@obs     
@sample
/*/
//-------------------------------------------------------------------

Static Function STDEmitLeitX()
Local aSLWArea	:= {}
Local lRet		:= .T.
Local cPdv		:= PadR(AllTrim(LjGetStation("PDV")),TamSX3("LG_PDV")[1])

DBSelectArea("SLW")
aSLWArea := SLW->(GetArea())
SLW->(DBSetOrder(2))

lRet := !SLW->(DbSeek(xFilial("SLW")+cPdv+DToS(dDataBase)))

RestArea(aSLWArea)

Return lRet