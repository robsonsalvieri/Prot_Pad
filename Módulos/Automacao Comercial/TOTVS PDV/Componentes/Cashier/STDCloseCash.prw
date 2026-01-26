#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static cLastNumMov := ""
Static aDtConf     := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} STDCloseCash
Fecha o caixa 

@param cCash			Caixa	
@param dDtClose   	Data de fechamento
@param cHrClose		Hora de fechamento
 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  lRet Retorna se fechou o caixa
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCloseCash( cCash	,	dDtClose	, cHrClose	)

Local aArea			:= GetArea()					// Guarda área
Local lRet			:= .F.						// Retorno
Local lCashName := FindFunction("STDCashName")	// Ver se a função STDCashName existe no rpo
Local cNomeCaixa := Upper(cUsername)				// Usuario



Default cCash				:= ""						// Caixa	
Default dDtClose     	:= CtoD("  /  /  ")		// Data do fechamento
Default cHrClose			:= "  :  "					// Hora do fechamento


ParamType 0 Var 		cCash 			As Character		Default 	""
ParamType 1 Var 		dDtClose 		As Date			Default 	CtoD("  /  /  ")
ParamType 2 var  	cHrClose		As Character		Default 	"  :  "


If lCashName //inicio
	cNomeCaixa := STDCashName() 
EndIf


DbSelectArea("SA6")
DbSetOrder(2)//A6_FILIAL+A6_NOME
If DbSeek( xFilial("SA6") + Upper(cNomeCaixa)  ) //final

	RecLock("SA6",.F.)

	SA6->A6_DATAABR 	:= CtoD("  /  /  ")
	SA6->A6_HORAABR 	:= "  :  "
	SA6->A6_DATAFCH 	:= dDtClose
	SA6->A6_HORAFCH 	:= cHrClose

	MsUnLock()
	
	lRet := .T.
	
EndIf

RestArea(aArea) // Restaura area
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDCloseMult
Fecha caixas associados (tratamento multi-moeda)

@param cCash			Caixa	
@param dDtClose   	Data de fechamento
@param cHrClose		Hora de fechamento
 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  lRet Retorna se fechou os caixas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCloseMult( cCash	,	dDtClose	, cHrClose	)

Local aArea			:= GetArea()				// Guarda area
Local lRet			:= .F.						// Retorno
Local cCodigo			:= ""						// Codigo do caixa principal
Local cAgencia		:= ""						// Agencia  do caixa principal
Local cConta			:= ""						// Conta  do caixa principal

Default cCash		:= ""						// Caixa	
Default dDtClose   	:= CtoD("  /  /  ")		// Data de fechamento
Default cHrClose		:= "  :  "					// Hora de fechamento


ParamType 0 Var 		cCash 			As Character		Default 	""
ParamType 1 Var 		dDtClose 		As Date			Default 	CtoD("  /  /  ")
ParamType 2 var  	cHrClose		As Character		Default 	"  :  "

// Fecha caixas associados(tratamento multi-moeda) 
xNumCaixa()
cCodigo  	:= SA6->A6_COD				
cAgencia 	:= SA6->A6_AGENCIA			
cConta   	:= SA6->A6_NUMCON  			 
      	
DbSelectArea("SA6")
DbSetOrder(1) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
If DbSeek( xFilial("SA6") + Upper(cCash)  )
      	
	While !Eof() .And. ( xFilial()+cCodigo ) == ( SA6->A6_FILIAL+SA6->A6_COD )

    	If AllTrim(cCodigo + cAgencia + cConta) == AllTrim(SA6->A6_COD + SA6->A6_AGENCIA + SA6->A6_NUMCON)
        	SA6->(dbSkip())
        	Loop
        EndIf
            	
		RecLock("SA6",.F.)
				
		SA6->A6_DATAABR 	:= CtoD("  /  /  ")
		SA6->A6_HORAABR 	:= "  :  "
		SA6->A6_DATAFCH 	:= dDtClose
		SA6->A6_HORAFCH 	:= cHrClose
		
		MsUnLock()
      
      lRet := .T.
       
      SA6->(dbSkip())
            	
    EndDo
         	
EndIf  

RestArea(aArea) // Restaura area
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDSaveMov
Grava numero do movimento e Numero do Cupom Final 
no Fechamento do caixa
 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  lRet 	Retorna se realizou a gravacao
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDCSaveMov( aDtHr , cCupomFim )

Local aArea			:= GetArea()							//Guarda area
Local aStation		:= STBInfoEst(	1, .T. ) 			//Informacoes da estacao  // [1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
Local lRet			:= .F.									//Retorno
Local cChave			:= ""									//Chave de Pesquisa
Local cNumMov			:= AllTrim(STDNumMov())				//Numero do Movimento
Local lConfCaixa 	:= SuperGetMV( "MV_LJCONFF",,.F. ) //Parametro da conferencia de caixa
Local cConfere		:= ""									//Verifica se deve ser gravado 1 ou 2 no LW_CONFERE
Local nIndice			:= 1									//Numero do indice
Local cNomeUs			:= AllTrim(UsrRetName(__cUserID))	//Nome do usuario padrao

Default aDtHr 		:= 	STBDtCash()	
Default cCupomFim 	:= 	""

ParamType 0 Var   aDtHr 			As Array		Default 	STBDtCash()	
ParamType 1 Var 	cCupomFim 		As Character	Default 	""

If !lConfCaixa
	//Pesquisar o proximo movimento em aberto que deve ser finalizado
	cChave 	:= xFilial("SLW") + aStation[4] + aStation[1]
	nIndice 	:= 1 //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_NUMMOV
Else
	cChave 	:= STDUtMovAb(1,aStation[1],aStation[4],aStation[2],cNumMov,.T.)
	nIndice 	:= 3 //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
EndIf

If !Empty(cNumMov)
	cLastNumMov := cNumMov
EndIf

DbSelectArea("SLW")
DbSetOrder(nIndice) 
If DbSeek( cChave )

	If !lConfCaixa
		While !SLW->(Eof()) .AND. ( SLW->(LW_FILIAL + LW_PDV + LW_OPERADO) == cChave ) .AND. ( DtoC(SLW->LW_DTFECHA) <> "  /  /  " )
			SLW->(dbSkip())
		EndDo
	EndIf
	
  	If !SLW->(Eof())

		If lConfCaixa
			cConfere := "2"
		Else
			cConfere := "1"
		EndIf

		// Grava SLW
		Reclock("SLW",.F.)	
		
		Replace SLW->LW_DTFECHA 		With aDtHr[1]			
		Replace SLW->LW_HRFECHA 		With aDtHr[2]			
		Replace SLW->LW_NUMFIM  		With cCupomFim
		Replace SLW->LW_SITUA 			With Replicate("0",TamSX3("LW_SITUA")[1])
		Replace SLW->LW_TIPFECH 		With "2"
		Replace SLW->LW_CONFERE 		With cConfere
	
		If Empty(SLW->LW_ORIGEM)
			Replace SLW->LW_ORIGEM	With cModulo
		EndIf
				
		MsUnlock()
		
		aDtConf := {SLW->LW_DTABERT,SLW->LW_HRABERT,SLW->LW_DTFECHA,SLW->LW_HRFECHA}
		
		lRet := .T.
		
		If lConfCaixa		
					
			STFSLICreate(aStation[2],"FCH","2" + StrZero(SLW->(IndexOrd()),2) + cChave,"ABANDONA",.T.,cNomeUs,aDtHr[1],aDtHr[2])
				
		EndIf

	EndIf
  
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} STDGLstNumMov
Fornece o ultimo numero do movimento. 
 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  cLastNumMov - Código da ultima movimentacao
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDGLstNumMov( )

Return cLastNumMov

//-------------------------------------------------------------------
/*{Protheus.doc} STDGDtAbFch
Retorna um array com as informacoes de data e hora de abertura e fechamento.
 
@author  Varejo
@version P11.8
@since   11/07/2012
@return  aDtConf[1] - Data de Abertura;
		 aDtConf[2] - Hora de Abertura;
		 aDtConf[3] - Data de Fechamento;
		 aDtConf[4] - Hora de Fechamento
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDGDtAbFch( )

Return aDtConf

//-------------------------------------------------------------------
/*{Protheus.doc} STDDtAbCx
Retorna informacao de aberta e fechamento de caixa 
 
@author  Varejo
@version P11.8
@since   19/05/2017
@return  aDtConf[1] - Data de Abertura;
		 aDtConf[2] - Hora de Abertura;
		 aDtConf[3] - Data de Fechamento;
		 aDtConf[4] - Hora de Fechamento
@obs     
@sample
*/
//-------------------------------------------------------------------
Function STDDtAbCx()

Local aArea			:= GetArea()							//Guarda area
Local aStation		:= STBInfoEst(	1, .T. ) 			//Informacoes da estacao  // [1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
Local cChave		:= ""									//Chave de Pesquisa
Local cNumMov		:= AllTrim(STDNumMov())				//Numero do Movimento
Local nIndice		:= 1									//Numero do indice
Local aDtConf		:= {}

cChave 	:= STDUtMovAb(1,aStation[1],aStation[4],aStation[2],cNumMov,.T.)
nIndice := 3 //LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV

DbSelectArea("SLW")
DbSetOrder(nIndice) 
If DbSeek( cChave )
	aDtConf := {SLW->LW_DTABERT,SLW->LW_HRABERT,SLW->LW_DTFECHA,SLW->LW_HRFECHA}
Else
	aDtConf := Array(4)
EndIf

RestArea(aArea) 

Return aDtConf
