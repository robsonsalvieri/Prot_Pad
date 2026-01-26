#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"    
#INCLUDE "STWIMPORTSALE.CH"

Static cMsgOrc := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} STWISSearchOptions
Busca opções de orçamento

@param   cField				Campo utilizado para busca
@param   cFieldAssigned		Conteúdo do campo para busca 
@param   dDataMov				Data do movimento a realizar a Busca PAFECF 	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1]				lUserSelect 	- Retorna se deve ser selecionada opção de orçamento
@return  aRet[2]				aOptionSales	- Array com as opções de orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWISSearchOptions( 	cField 		, cFieldAssigned, lCancSale, lSearchAll ,;
									dDataMov	)

Local aRet				:= {}					// Retorno função
Local nOption				:= 0					// Opção de busca
Local aFieldsAdd			:= {}					// Campos adicionais a serem buscados juntamente com as opções

Default cField				:= ""
Default cFieldAssigned		:= ""
Default lCancSale			:= .F. 
Default lSearchAll			:= .F.
Default dDataMov				:= dDataBase

ParamType 0 Var 	cField 			As Character	Default ""	
ParamType 1 Var  	cFieldAssigned	As Character	Default ""
ParamType 2 Var  	lCancSale		As Logical		Default .F.
ParamType 3 Var  	lSearchAll		As Logical		Default .F.

//Tratamento para pesquisa 
If !SuperGetMv("MV_LJORPAR",,.F.) .And. (At("*",AllTrim(cFieldAssigned)) == 1 .Or. RAT("*",AllTrim(cFieldAssigned)) == Len(AllTrim(cFieldAssigned))) .And. !Empty(STRTRAN(cFieldAssigned,"*","")) 
	STFMessage(ProcName(), "ALERT", STR0018 ) //"Pesquisa Aproximada (*) desabilitada (MV_LJORPAR)."
	STFShowMessage(ProcName())	
EndIf

Do Case

	Case SubStr( cFieldAssigned , 1 , 1 ) == "*" .And. Empty(STRTRAN(cFieldAssigned,"*",""))  
	
		nOption := 2 // Todos orçamentos abertos
		
	Case SubStr( cFieldAssigned , 1 , 1 ) == "/"
	
		nOption := 3 // Pela Data do dia
		
	Otherwise
	
		nOption := 1 // Pelo Campo
		
EndCase

aFieldsAdd := STIISFieldsAdd() // Busca campos adicionais a serem apresentados

/*/
	Busca opções de orçamento na retaguarda
/*/     
aRet := STBISSearchOptions( nOption 	, cField , cFieldAssigned , lSearchAll , ;
								aFieldsAdd , dDataMov )

If Len(aRet) = 0
	LjGrvLog("Importa_Orcamento:STWISSearchOptions", "Parâmetro de retorno aRet : Conteúdo vazio." )
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWISImpAllSelected
Importa as opções de orçamento selecionadas

@param   aSelectedSales		Opções selecionadas
@param   cStage				   Etapa de importação. "D" - Direta , "S" - Selecionada   
@Param   lGetOrcExpired       Pega orcamentos expirados pafecf
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet	 - Informacoes das vendas				
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWISImpAllSelected( aSelectedSales , cStage , lGetOrcExpired )

Local aRet			:= {}			// Retorno função
Local nI				:= 0			// Contador
Local lRet			:= .T.			// retorno função
Local aAllSales		:= {}			// Armazena todos os orçamentos importados
Local aSale			:= {}			// Armazena 1 orçamento importado
Local aErrorSales	:= {}			// Armazena orçamentos que não foram importados
Local cErrorSales	:= ""			// Armazena orçamentos que não foram importados
Local cMsgInterface	:= ""			// Mensagem a ser exibida na interface
Local cSales			:= ""			// Mensagem orçamentos
Local lMessage		:= .F.			// Indica se apresenta mensagem na interface
Local lContinue		:= .F.			// Indica se continua ou interrompe o procedimento

Default aSelectedSales	:= {}
Default cStage				:= "D"
Default lGetOrcExpired		:=	.F.

ParamType 0 Var aSelectedSales		As Array 		Default {}
ParamType 0 Var cStage				As Character 	Default "D"

STFCleanInterfaceMessage()

If !( Len(aSelectedSales) > 0 )
	lRet := .F.
EndIf

If lRet
	
	For nI := 1 To Len(aSelectedSales)
		
		If nI = 1
			LjGrvLog("Importa_Orcamento:STWISImpAllSelected","Chama rotina: STWIsGetSale")
		EndIf
		aSale := STWISGetSale( aSelectedSales[nI] , lGetOrcExpired )
		
		If Len(aSale) > 0
			
			AADD( aAllSales	,	aSale	)
			
			/*/
				Atribui texto de orçamentos a serem importados (para msg)
			/*/
			If STFGetCfg("lPafEcf")
				cSales := aSelectedSales[nI][2] + " , " // DAV/PRE
			Else
				cSales := aSelectedSales[nI][1] + " , " // L1_NUM
			EndIf
			
		Else
		
			AADD( aErrorSales	,	aSelectedSales[nI]	)
			
		EndIf
		
	Next nI
	
	If Len(aErrorSales) > 0
	
		/*/
			Se ocorreu algum problema com algum orçamento
		/*/				
		If Len(aAllSales) > 0
			
			/*/
				Se vieram orçamentos com problema mas também que deram certo
			/*/
			For nI := 1 To Len(aErrorSales)
				
				If ValType(aErrorSales[nI]) == "C"
					cErrorSales := cErrorSales + aErrorSales[nI] + " , "
				ElseIf ValType(aErrorSales[nI][1]) == "C"
					cErrorSales := cErrorSales + aErrorSales[nI][1] + " , "
				EndIf	
				
			Next nI
			
			cMsgInterface := STR0001 + cErrorSales + STR0002 //"Não foi possível importar o(s) orçamento(s) "continua a importação dos outros?"
			lMessage		:= .T. // Força mensage
			lContinue		:= .T. // Continua para perguntar
			LjGrvLog("Importa_Orcamento:STWISImpAllSelected",STR0001 + cErrorSales + STR0002)	//"Não foi possível importar o(s) orçamento(s) "continua a importação dos outros?"
																		
		Else
			
			/*/
				Se vieram apenas orçamentos com problemas
			/*/	
			lMessage 	:= .F.
			lContinue	:= .F.
			
		EndIf
			
	Else
		
		lMessage 		:= .T. // Importacao sem mensagem	
		lContinue		:= .T. // Continua procedimento
		cMsgInterface := STR0003 + cSales + "?" //"Confirma importação do(s) orçamento(s) "
	
	EndIf
	

EndIf

AADD( aRet , lContinue			)
AADD( aRet , lMessage			)
AADD( aRet , cMsgInterface		)
AADD( aRet , aAllSales			)
AADD( aRet , aErrorSales		)


If !lContinue
	LjGrvLog("Importa_Orcamento:STWISImpAllSelected", "lContinue : " , lContinue )
	LjGrvLog("Importa_Orcamento:STWISImpAllSelected", "Parâmetro de retorno aRet : " , aRet )
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWISRegSale
Registra orçamento no POS

@param   aSelectedSale		Opção selecionada
@Param   lCancel				Cancela orcamento apos importar Pafecf  	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWISRegSale( aAllSales , lCancel )

Local nI				:= 0		// Contador
Local cNumLastSale 		:= ""		// Numero da ultima venda
Local cLastDoc			:= ""		// Ultimo Doc
Local oTotal			:= Nil		// Totalizador
Local oMdl 				:= Nil		// Model Pgto
Local oModelPay 		:= Nil		// Model Pgto
Local oModelParc		:= Nil		// Model Pgto
Local lCancOrc			:= .T.		// Se houver falha determina se será cancelado toda a operação
Local aCancOrc			:= {}       // Orçamentos que serão cancelados na Função STIAtuGetOrc()

Default aAllSales	:= {}
Default lCancel		:= .F.

ParamType 0 Var aAllSales As Array Default {}

/*/
	Realizar registro dos orçamentos
/*/
If Len(aAllSales) > 0
	For nI := 1 To Len(aAllSales)
		//Se ocorrer erro na importação é cancelado o cupom
		LjGrvLog("Importa_Orcamento:STWISRegSale","Chama rotina: STBImportSale, nI = ", nI)
		If !STBImportSale( aAllSales[nI] , lCancel, Len(aAllSales) > 1, @lCancOrc )
			If lCancOrc 
				LjGrvLog("Importa_Orcamento:STWISRegSale","Ocorreu um erro na importação")
				cNumLastSale 	:= STDCSLastSale()	
				cLastDoc		:= STDCSDoc( cNumLastSale )			
				LjGrvLog("Importa_Orcamento:STWISRegSale","Chama rotina: STWCancelSale")
				LjGrvLog("Importa_Orcamento:STWISRegSale","Parâmetro cLastDoc: ", cLastDoc)
				LjGrvLog("Importa_Orcamento:STWISRegSale","Parâmetro cNumLastSale: ", cNumLastSale)
				STWCancelSale(.T.,,,cLastDoc, "L1_NUM",,)
				If nI == Len(aAllSales)
					LjGrvLog("Importa_Orcamento:STWISRegSale","Chama rotina: STIRegItemInterface")
					STIRegItemInterface()
				EndIf
			Else
				Aadd(aCancOrc,nI)
			EndIf	 
		Else
		    //Cria arquivo para controle de orcamento no Venda Assistida         
            STBCtrImpOrc( aAllSales[nI][1][1][2], STFGetStation("PDV"), Nil, Nil, .T. )
		EndIf
		
		//Cancela Venda apos importar
		//Usado para vendas expiradas PafEcf
		If lCancel
		
			LjGrvLog("Importa_Orcamento:STWISRegSale","Cancela venda após importar")
			oTotal		:= STFGetTot()
			nTotalSale := oTotal:GetValue("L1_VLRTOT") 

			oMdl := ModelPayme()
			
			oModelPay := oMdl:GetModel('PARCELAS')
			oModelPay:Activate()
			oModelPay:ClearData()
			oModelPay:InitLine()
			
			oModelParc := oMdl:GetModel('APAYMENTS')
			oModelParc:Activate()
			oModelParc:ClearData()
			oModelParc:InitLine()
		
			//Seta pagamento em dinheiro
			LjGrvLog("Importa_Orcamento:STWISRegSale","Chama rotina: STICSOrc")
			STICSOrc(dDataBase, nTotalSale)
			LjGrvLog("Importa_Orcamento:STWISRegSale","Chama rotina: STIConfPay(.F.)")
			STIConfPay(.F.) 
			
			cNumLastSale 	:= STDCSLastSale()	
			cLastDoc		:= STDCSDoc( cNumLastSale )
			
			LjGrvLog("Importa_Orcamento:STWISRegSale","Chama rotina: STWCancelSale")
			LjGrvLog("Importa_Orcamento:STWISRegSale","Parâmetro cLastDoc: ", cLastDoc)
			LjGrvLog("Importa_Orcamento:STWISRegSale","Parâmetro cNumLastSale: ", cNumLastSale)
			STWCancelSale( .F. 			, .F. 	, Nil , cLastDoc	, 	;
							 cNumLastSale 		, .T. 					)

			
		EndIf			
	Next nI

	STIAtGetOr(aCancOrc)
		
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STWImportSale
Function Importação de Orçamentos

@param   aSelectedSale		Opção selecionada   	
@param   lGetOrcExpired     Importa orcamentos expirados
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSale				Retorna estrutura do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWISGetSale( aSelectedSale , lGetOrcExpired )

Local aSale				:= {}				// Retorno função
Local lContinue			:= .T.				// Fluxo lógico

Default aSelectedSale	:= ""
Default lGetOrcExpired := .F.

If !( Len(aSelectedSale) > 0 )
	lContinue := .F.
	LjGrvLog("Importa_Orcamento:STWISGetSale", "Len(aSelectedSale) < 0" )
EndIf

If STFGetCfg("lPafEcf") .AND. Empty(aSelectedSale[2]) // L1_NUMORC
	
	
	STFMessage("STImportSale","STOP", STR0004 + aSelectedSale[1] 											+ ; // "Orçamento: " 
	STR0005		+ ;     //" não possui número de DAV ou Pré-Venda. Em ambiente PAF-ECF não é permitido importar Orçamento "
	STR0006		+ ;     //"que não seja proveniente de um DAV ou Pré-Venda! Verifique se o ambiente que gerou o Orçamento "
	STR0007		) //"esta habilitado para operar em modo PAF-ECF com DAV ou Pre-Venda."
	
	lContinue := .F.
	LjGrvLog("Importa_Orcamento:STWISGetSale",STR0004 + aSelectedSale[1] + STR0005 + STR0006 + STR0007 ) //idem a acima
	
EndIf

/*/
	Realiza Importação do Orçamento
/*/
If lContinue
	If STFGetCfg("lPafEcf")
		LjGrvLog("Importa_Orcamento:STWISGetSale","STFGetCfg(lPafEcf) = .T.")
		LjGrvLog("Importa_Orcamento:STWISGetSale","Chama rotina remoto: STBImportR")
		LjGrvLog("Importa_Orcamento:STWISGetSale","Utilizando L1_NUMORC")
		LjGrvLog("Importa_Orcamento:STWISGetSale","Parâmetro aSelectedSale[2]: ", aSelectedSale[2])
		LjGrvLog("Importa_Orcamento:STWISGetSale","Parâmetro lGetOrcExpired: ", lGetOrcExpired)
		lContinue := STBRemoteExecute( "STBImportR" , { "L1_NUMORC" 	, aSelectedSale[2] , .T. , .T. , lGetOrcExpired } , NIL , .F. , @aSale )					
	Else
		LjGrvLog("Importa_Orcamento:STWISGetSale","STFGetCfg(lPafEcf) = .F.")
		LjGrvLog("Importa_Orcamento:STWISGetSale","Chama rotina remoto: STBImportR")
		LjGrvLog("Importa_Orcamento:STWISGetSale","Utilizando L1_NUM")
		LjGrvLog("Importa_Orcamento:STWISGetSale","Parâmetro aSelectedSale[1]: ", aSelectedSale[1])
		lContinue := STBRemoteExecute( "STBImportR" , { "L1_NUM" 		, aSelectedSale[1] , .T. 		} , NIL , .F. , @aSale )
	EndIf
EndIf
If !lContinue
	STFMessage( "STImportSale" , "STOP" , STR0008 ) //"Ocorreu falha de comunicação entre os ambientes"
	LjGrvLog("Importa_Orcamento:STWISGetSale",STR0008)	//"Ocorreu falha de comunicação entre os ambientes"
	aSale := {}
EndIf


/*/
	Validar Retorno a aSale
/*/
If lContinue
	If ValType(aSale) == "A"
		If Len(aSale) > 0
			If aSale[1] <> "OK"

				cMsgOrc := ""
			
				Do Case
				
					Case aSale[1] == "NOTFOUND"
					
						If STFGetCfg("lPafEcf") // PAF
							If SuperGetMv("MV_LJPRVEN",,.T.) // Utiliza Pre-Venda
								STFMessage("STImportSale","STOP",STR0009 + aSelectedSale[2] + STR0010) //" não foi encontrada na Retaguarda."
								LjGrvLog("Importa_Orcamento:STWISGetSale",STR0009 + aSelectedSale[2] + STR0010)	//"A Pre-Venda " ... " não foi encontrada na Retaguarda."
							Else
								STFMessage("STImportSale","STOP",STR0011 + aSelectedSale[2] + STR0012) //" não foi encontrada na Retaguarda."
								LjGrvLog("Importa_Orcamento:STWISGetSale",STR0011 + aSelectedSale[2] + STR0012)	//"A DAV " ... " não foi encontrada na Retaguarda."
							EndIf
						Else
							STFMessage("STImportSale","STOP",STR0004 + aSelectedSale[1] + STR0012) //" não foi encontrado na Retaguarda."
							LjGrvLog("Importa_Orcamento:STWISGetSale",STR0004 + aSelectedSale[1] + STR0012)	//"O Orçamento " ..." não foi encontrado na Retaguarda."
						EndIf
						
						aSale := {}					
						
					Case aSale[1] == "JAIMPORTADO"
					
						If STFGetCfg("lPafEcf") // PAF
							If SuperGetMv("MV_LJPRVEN",,.T.) // Utiliza Pre-Venda
								STFMessage("STImportSale","STOP",STR0009 + aSelectedSale[2] + STR0013) //"A Pre-Venda " ... " já foi importado da Retaguarda."
								LjGrvLog("Importa_Orcamento:STWISGetSale",STR0009 + aSelectedSale[2] + STR0013)	//"A Pre-Venda " ... " já foi importado da Retaguarda."
							Else
								STFMessage("STImportSale","STOP",STR0011 + aSelectedSale[2] + STR0013) //"A DAV " ... " já foi importado da Retaguarda."
								LjGrvLog("Importa_Orcamento:STWISGetSale",STR0011 + aSelectedSale[2] + STR0013)	//"A DAV " ... " já foi importado da Retaguarda."
							EndIf
						Else
							STFMessage("STImportSale","STOP",STR0016 + aSelectedSale[1] + STR0013)  //"O Orçamento " ..." já foi importado da Retaguarda."
							LjGrvLog("Importa_Orcamento:STWISGetSale",STR0016 + aSelectedSale[1] + STR0013)	//"O Orçamento " ..." já foi importado da Retaguarda."
						EndIf
						
						aSale := {}
						
					Case aSale[1] == "SEMESTOQUE"
	
						STFMessage("STImportSale","STOP",STR0016 + aSelectedSale[1] + STR0019) //"O Orçamento " ..." não contem itens que não possuem saldo em estoque."
						aSale := {}
						LjGrvLog("Importa_Orcamento:STWISGetSale",STR0016 + aSelectedSale[1] + STR0019)	//"O Orçamento " ..." não contem itens que não possuem saldo em estoque."
								
					Case aSale[1] == "ERROR"
						
						STFMessage("STImportSale","STOP", STR0015)  //"Erro ao carregar orçamento, tente novamente"
						aSale := {}
						LjGrvLog("Importa_Orcamento:STWISGetSale",STR0015)	//"Erro ao carregar orçamento, tente novamente"
						
					Case aSale[1] == "EXPIRADO"
						
						STFMessage("STImportSale","STOP", STR0017)  //"Orçamento expirado"						
						aSale := {}	
						LjGrvLog("Importa_Orcamento:STWISGetSale",STR0017)	//"Orçamento expirado"

					Case aSale[1] == "SEMCREDITO"

						cMsgOrc := STR0026 //"Não foi possível importar o orçamento, o cliente não possui limite de crédito disponível"					
						aSale := {}	
						LjGrvLog("Importa_Orcamento:STWISGetSale",STR0020)	//"Cliente Sem Crédito"

					Case aSale[1] == "BLOCKPE"
						
						STFMessage("STImportSale","STOP", STR0021 + aSelectedSale[1])  //"Bloqueado Ponto de Entrada STVLDIMP, Orçamento: "						
						aSale := {}	
						LjGrvLog("Importa_Orcamento:STWISGetSale",STR0021 + aSelectedSale[1])	//"Bloqueado Ponto de Entrada STVLDIMP, Orçamento: "
					
					Case aSale[1] == "SL1LOCK"

						STFMessage("STImportSale","STOPPOPUP", STR0016 + aSelectedSale[1] + STR0022 + aSelectedSale[3] + STR0023)
						aSale := {}	
						LjGrvLog("Importa_Orcamento:STWISGetSale",STR0016 + aSelectedSale[1] + STR0023)


					Case aSale[1] == "FPGTONAOPERMITIDO"

						STFMessage("STImportSale","STOPPOPUP",  STR0004 + aSelectedSale[1] + STR0022 + aSelectedSale[3] + Chr(13) + STR0024 + "  " + aSale[2])
						LjGrvLog("Importa_Orcamento:STWISGetSale", + STR0024 + "  " + aSale[2])
						aSale := {}	
						
					OtherWise	
						
						STFMessage("STImportSale","STOP", STR0015)  //"Erro ao carregar orçamento, tente novamente"						
						aSale := {}
						LjGrvLog("Importa_Orcamento:STWISGetSale",STR0015)	//"Erro ao carregar orçamento, tente novamente"
						
				EndCase
				
			Else
				/*/
					Retornar apenas a venda, sem o Status
				/*/
				aSale := aSale[2] 	
			EndIf
		EndIf
	Else
		aSale := {}
	EndIf
EndIf

STFShowMessage("STImportSale")	
If Len(aSale) = 0
	LjGrvLog("Importa_Orcamento:STWISGetSale", "Parâmetro de retorno aSale : Conteúdo vazio." )
EndIf

Return aSale   

//-------------------------------------------------------------------
/*/{Protheus.doc} STWISPafSearch
Busca de Orçamentos   para cancelamento PAF-ECF

@param   lSeachAll   Busca Todos orçamentos
@param   dDataMov				Data do movimento a realizar a Busca PAFECF
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWISPafSearch( lSeachAll , dDataMov )

Local aAux				:= {}						// Armazena retorno função temporariamente
Local lUserSelect		:= .F.		   				// Indica se orçamento deve ser selecionado
Local aImported			:= {}						// Armazena retorno da verificação de importação
Local aField				:= STDISSearchField("L1_NUMORC") 	// Armazena informaçõe do campo de busca de orçamento
Local aOptionSales	   := {}						// Array com vendas selecionadas
Local lCancel				:= .T.						//Cancela as vendas apos importar pois as mesma estao expiradas

Default lSeachAll 	:= .F.
Default dDataMov		:= dDataBase

ParamType 0 Var  	lSeachAll		As Logical		Default .F.

LjGrvLog("Importa_Orcamento:STWISPafSearch","Parâmetro lCancel     :  ", lCancel)

/* Chamada Busca de opções de orçamento */
aAux := STWISSearchOptions( aField[3] , "/", STFGetCfg("lPafEcf"), lSeachAll ,;
								dDataMov  )

lUserSelect 	:= aAux[1]
aOptionSales	:= aAux[2]


If Len(aOptionSales) > 0

	LjGrvLog("Importa_Orcamento:STWISPafSearch","Chama rotina: STWISImpAllSelected")
	LjGrvLog("Importa_Orcamento:STWISPafSearch","Parâmetro aOptionSales:  ", aOptionSales)

	aImported := STWISImpAllSelected( aOptionSales , "D" , lCancel  )
	
	LjGrvLog("Importa_Orcamento:STWISPafSearch","Parâmetro de retorno aImported    :", aImported)
	
	If aImported[1]		// Continua?
			
		LjGrvLog("Importa_Orcamento:STWISPafSearch","aImported[1] = .T.")
		LjGrvLog("Importa_Orcamento:STWISPafSearch","Chama rotina: STWISRegSale")
		LjGrvLog("Importa_Orcamento:STWISPafSearch","Parâmetro aImported[4]:  ", aImported[4])

		/* Chamar Importação direto */
		STWISRegSale( aImported[4] , lCancel ) 
     
		LjGrvLog("Importa_Orcamento:STWISPafSearch","Chama rotina: STIOpenCash")
     	STIOpenCash()
     
	Else
		
		LjGrvLog("Importa_Orcamento:STWISPafSearch","aImported[1] = .F.")
		lRet := .F.

	EndIf	
		 
EndIf
	

Return Nil

/*/{Protheus.doc} STWGetMsg
	Função que retorna a mensagem referente a não importação do orçamento
	@type  Function
	@author Varejo
	@since 05/04/2023
	@version P12
	@return cMsgOrc, caractere, retorna o motivo da não importação do orçamento
/*/
Function STWGetMsg()
Return cMsgOrc

/*/{Protheus.doc} STIAtGetOr
	Função que atualiza o Array aGetOrc 
	@param  aGet,  Array , 	Posição que irremos atualizar. 
	@type  Function
	@author Jeferson Mondeki
	@since 20/01/2025
	@version P12
	@return Nil
/*/
Static Function STIAtGetOr(aGet)

Local nI 	:= 0  // Contador. 

If Len(aGet) > 0
	For nI := Len(aGet) To 1 Step -1
		ADel(STIGetOrc(), aGet[nI] )	
	Next	
	Asize(STIGetOrc(), Len(STIGetOrc())-Len(aGet))
EndIf

Return 
