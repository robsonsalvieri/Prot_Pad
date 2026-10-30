#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSendSale
Transmite a venda para retaguarda caso esteja online

@param   	cL1NUM - Numero Orcamento

@author  	Gorgulho
@version 	P11.8
@since   	22/10/2015
@return  	Nil  	
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDSendSale(cL1_NUM,cEstacao,lStarJob,cEmp,cFil)

Local lRet			:= .T.   
Local lGravouOk		:= .F. 
Local lEncontrou 	:= .T.	//	Se encontrou registro
Local aSL1			:= {}	//	array com dados da SL1
Local aSL2			:= {}	//	array com dados da SL2
Local aSL4			:= {}	//	array com dados da SL4
Local lHasConnect	:= .T.	// Verifica se tem comunicacao
Local cStatusNum	:= ""    
Local cNum			:= ""     
Local cNumSaleConf	:= ""
Local nCodRet		:= 0
Local lComCPDV		:= IIf( FindFunction("LjGetCPDV"), LjGetCPDV()[2] , .F. ) // Usa comunicacao com a central 
Local lGrvRet		:= .F. //Informa que gravou a venda com sucesso na retaguarda quando venda online e central de PDVs
Local lOk			:= .T.

Default cL1_NUM	 	:= ""   
Default cEstacao 	:= "001"   
Default lStarJob 	:= .F.
Default cEmp	 	:= cEmpAnt
Default cFil     	:= cFilAnt


If lStarJob
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,Nil,Nil,"SALE")     
Endif

aSL1 := STDSL1SEND(@lEncontrou, @cL1_NUM)	//Recebe o Número do Orçamento gerado

If lEncontrou
	aSL2 :=  STDSL2Create(@lEncontrou, cL1_NUM) //Passa o Número do Orçamento gerado
EndIf

If lEncontrou
	aSL4 :=  STDSL4Create(@lEncontrou, cL1_NUM) //Passa o Numero do Orçamento gerado
EndIf

//Reserva registro caso JOB STWUPDATA seja iniciado
RecLock("SL1", .F.)
REPLACE SL1->L1_SITUA With "TX"
SL1->( MsUnLock() )		

If lEncontrou

	lGravouOk := STBRemoteExecute("GeraL1L2L4", {aSL1, aSL2, aSL4, cEstacao }	, NIL, .F., @cStatusNum, , , @nCodRet)             
	CONOUT("STDSendSale - L.60 - DEPOIS STBRemoteExecute(GeraL1L2L4) - lGravouOk: "+AllToChar(lGravouOk)) 		
	lHasConnect := !(nCodRet == -105 .OR. nCodRet == -107 .OR. nCodRet == -104)  
	
	If ValType( cStatusNum ) == "C" .AND. lHasConnect //tem comunic com a Ret 
		CONOUT("STDSendSale - L.64 - lHasConnect: " +AllToChar(lHasConnect)+"cStatusNum: "+AllToChar(cStatusNum)) 
		If Left( cStatusNum, 2 ) == "OK"                                    
			CONOUT("STDSendSale - L.66 - cStatusNum: "+AllToChar(cStatusNum))	   		
	 		cNum := Substr( cStatusNum, 4, 6 )  
			CONOUT("STDSendSale - L.68 - cNum: "+AllToChar(cNum))	 		
	 		If !Empty( cNum )	
	 			lContinua := STBRemoteExecute("ConfL1L2L4", { cNum , cEstacao } , NIL, .F. , @cNumSaleConf )
				CONOUT("STDSendSale - L.72 - DEPOIS STBRemoteExecute(ConfL1L2L4) - lContinua: "+AllToChar(lContinua)) 		 		  			 			
		 		If AllTrim(cNum) == AllTrim(cNumSaleConf) 
					CONOUT("STDSendSale - L.74 - cNum: " +AllToChar(cNum)+"cNumSaleConf: "+AllToChar(cNumSaleConf)) 		 		  		
			   		DbSelectArea("SL1")
					SL1->( DbSetOrder(1) )	//L1_FILIAL+L1_NUM
					If SL1->( DbSeek(xFilial("SL1")+cL1_NUM))
						RecLock("SL1", .F.)
			            REPLACE SL1->L1_SITUA With "TX"
			            REPLACE SL1->L1_NUMORIG With cNum			            
				  		SL1->( MsUnLock() )				  		
		   			EndIf
		   						   	
				   	//Tratamento para os PDV conectados a Central de PDVs
				   	If lComCPDV	
				   		cStatusNum	:= ""
				   		cNum		:= ""
						lGravouOk 	:= STBRemoteExecute("_GeraL1L2L4", {aSL1, aSL2, aSL4, cEstacao }	, NIL, .F., @cStatusNum, , , @nCodRet)             
						CONOUT("STDSendSale - L.88 - DEPOIS STBRemoteExecute(_GeraL1L2L4) NA CENTRAL - lGravouOk: "+AllToChar(lGravouOk)) 
						If ValType( cStatusNum ) == "C"	  
					   		CONOUT("STDSendSale - L.90 - cStatusNum: "+AllToChar(cStatusNum)) 											
							If Left( cStatusNum, 2 ) == "OK"                                    				   		
						 		cNum 	:= Substr( cStatusNum, 4, 6 ) 
						 		lGrvRet := .T. 
						 		If !Empty( cNum )
						 			STBRemoteExecute("_ConfL1L2L4", { cNum , cEstacao, lGrvRet } , NIL, .F. , @cNumSaleConf )
									CONOUT("STDSendSale - L.96 - DEPOIS STBRemoteExecute(_ConfL1L2L4) NA CENTRAL - cNumSaleConf: "+AllToChar(cNumSaleConf)) 						 			
						 		EndIf		
					    	EndIf        
				   	    EndIf			   		
				   	EndIf
		   		Else
					lOk := .F.
			   	EndIf	
			Else
				lOk := .F.
			EndIf  
		Else
			lOk := .F.
		EndIf
	Else
		lOk := .F.
	EndIf
Else	
	lOk := .F.
EndIf

If !lOk 
	RecLock("SL1", .F.)
	REPLACE SL1->L1_SITUA With "00"
	SL1->( MsUnLock() )	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSL1SEND
Busca Vendas para subir ao BackOffice

@param lEncontrou		Indica se encontrou a venda - Variavel usada por referencia

@author  Varejo
@version P11.8
@since   09/01/2013
@return  aSL1		array com dados da SL1
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSL1SEND( lEncontrou, cL1_NUM )  
  
Local aArea			:= GetArea()	// Armazena alias corrente
Local nCampos 		:= 0       		// Quantidade de campos do filtro atual
Local aSL1			:= {}     		// Array do Alias
Local i				:= 0			// Contador

Default lEncontrou 	:= .F.
Default cL1_NUM 	:= ""

lEncontrou := .F.

DbSelectArea("SL1")
SL1->( DbSetOrder(1) )	//L1_FILIAL+L1_NUM

lEncontrou := SL1->( DbSeek(xFilial("SL1")+cL1_NUM) )

If lEncontrou 	
	cL1_NUM := SL1->L1_NUM
	
	nCampos := FCount() 	
	aSL1 	:= Array(nCampos)
	
	For i := 1 To nCampos		
		aSL1[i] := {FieldName(i), FieldGet(i)}
	Next i    
	
	// Salva origem da venda
	If SL1->L1_OPERACA != "C"
		aSL1[AScan(aSL1,{|x|x[1]=="L1_NUMORIG"})][2] := SL1->L1_NUM
	EndIf
	
EndIf  

RestArea(aArea)

Return aSL1

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSENDCLI
Transmite o cliente para retaguarda caso esteja online

@param   	aSA1 - Dados do cliente enviado para execauto  
@param   	lSendCli - retorno se o cliente foi incluido com sucesso

@author  	Gorgulho
@version 	P11.8
@since   	22/10/2015
@return  	Nil  	
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDSENDCLI(aSA1,lSendCli,lStarJob,cEmp,cFil)

Local lHasConnect	:= .T.	// Verifica se tem comunicacao
Local lContinua		:= .F.    
Local lExistCli		:= .F. 
Local lRetServer    := .F. 
Local lSendCli     	:= .F.
Local nRecServer	:= 0 
Local nX			:= 0  
Local xRet			:= "" 
Local aData			:= {}    
Local lCentPDV	 	:= IIf( FindFunction("LjGetCPDV"), LjGetCPDV()[1] , .F. ) // Eh Central de PDV  - CENTRAL TOTVSPDV                                                         

Default aSA1	 	:= {}
Default lSendCli	:= .F.
Default lStarJob 	:= .F.
Default cEmp	 	:= cEmpAnt
Default cFil     	:= cFilAnt

If lStarJob
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,Nil,Nil,"CLI")     
Endif

If Len(aSA1) > 0
	lContinua := STBRemoteExecute( "STDPesqCli" , { xFilial("SA1"), aSA1[1][2], aSA1[2][2] } , NIL, .F. , @lExistCli )
EndIf

If lContinua .AND. !lExistCli

	If !lCentPDV
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	
		If SA1->(DbSeek(xFilial("SA1")+aSA1[1][2]+aSA1[2][2])) 
		
			For nX := 1 To SA1->(FCount())  
				If AllTrim(FieldName( nX )) == 'A1_SITUA'
					AAdd( aData , { FieldName( nX ), '' } )
				Else
					AAdd( aData , { FieldName( nX ), FieldGet( nX ) } )
				EndIf 
			Next nX
		
		EndIf
	Else	
		aData := aClone(aSA1)
	EndIf
	
	If Len(aData) > 0

		lContinua := STBRemoteExecute( "STDRecXData" , { 'SA1' , aData } , NIL, .F. , @xRet )
		
		//Trata o retorno xRet
		If lContinua .AND. ValType(xRet) == "A"   
			lRetServer := xRet[1] == "OK" 
			nRecServer := xRet[2]
		ElseIf lContinua .AND. ValType(xRet) == "L" 
			lRetServer := xRet
		EndIf		           
		
		If lContinua .AND. lRetServer	
			RecLock('SA1',.F.)
			SA1->A1_SITUA := 'TX'
			MsUnlock()      
			lSendCli := .T.
		ElseIf lContinua .AND. !lRetServer	
			RecLock('SA1',.F.)
			SA1->A1_SITUA := 'ER'
			MsUnlock()	
		EndIf		
		
    EndIf
	
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSendRZ
Transmite o cliente para retaguarda caso esteja online

@param   	aData - Dados da reducao Z enviada para retaguarda  
@param   	lSendRZ - retorno se a reducao Z foi incluida com sucesso

@author  	Gorgulho
@version 	P11.8
@since   	01/12/2015
@return  	Nil  	
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDSendRZ(aData,lSendRZ,lStarJob,cEmp,cFil)    

Local lContinua		:= .F.    
Local lRetServer    := .F. 
Local nRecServer	:= 0 
Local nX			:= 0  
Local xRet			:= "" 

Default aData	 	:= {}
Default lSendRZ		:= .F.
Default lStarJob 	:= .F.
Default cEmp	 	:= cEmpAnt
Default cFil     	:= cFilAnt

If lStarJob
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,Nil,Nil,"REDZ")     
Endif

If Len(aData) > 0

	lContinua := STBRemoteExecute( "GeraSFI" , { aData } , NIL, .F. , @xRet )	   
	
	//Trata o retorno xRet
	If lContinua .AND. ValType(xRet) == "A"   
		lRetServer := xRet[1] == "OK" 
		nRecServer := xRet[2]
	ElseIf lContinua .AND. ValType(xRet) == "L" 
		lRetServer := xRet
	EndIf		           
	
	If lContinua .AND. lRetServer	
		lSendRZ := .T.
	EndIf		
		
EndIf

Return 