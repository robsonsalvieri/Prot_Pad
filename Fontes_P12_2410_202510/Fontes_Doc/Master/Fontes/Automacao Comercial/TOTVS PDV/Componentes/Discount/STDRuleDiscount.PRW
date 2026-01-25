#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 

Static nTotDa1 		:= 0 //Armazena o total dos produtos contidos na tabela DA1
Static lDescGrupo 	:= .F.
Static lFrmDesc 	:= .F.
Static lDscTotSPg 	:= .F.//Desconto Varejo no Total sem Grupo e sem forma de pagamento


//-------------------------------------------------------------------
/*/{Protheus.doc} STDTotRlDi
Function Busca Regras de Desconto do Tipo Total

@param 	 cCliCode			Codigo do Cliente
@param 	 cCliStore			Loja do Cliente
@param 	 lPayRule			Indica se Busca Regras do Tipo Pagamento ou Tipo Total
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1] MEI_CODREG					1 Codigo da Regra
@return  aRet[2] MEJ_PRINUM	  				2 Prioridade da Regra
@return  aRet[3] MEI_ACUMUL					3 Indica se a Regra é acumulativa
@return  aRet[4] MEI_DESCRI					4 Descrição da Regra
@obs										Verifica condicoes de Filial, Hora/Data/Semana e Cliente. Nao verifica o Range de Valores
@sample
/*/
//-------------------------------------------------------------------
Function STDTotRlDi( cCliCode , cCliStore , lPayRule, lPgto )

Local aArea			:= GetArea()		// Guarda Alias Corrente
Local aRet 			:= {}             	// Retorna regras validas  
Local cPriority		:= ""				// Prioridade da regra (MEJ_PRINUM)

Default cCliCode 	:= ""	
Default cCliStore 	:= ""
Default lPayRule 	:= .F.
Default lPgto       := .F.

ParamType 0 var  cCliCode 	As Character Default ""
ParamType 1 var  cCliStore	As Character Default ""
ParamType 1 var  lPayRule	As Logical	 Default .F.

DbSelectArea("MEI")
DbSetOrder(3) //MEI_FILIAL+MEI_TPIMPD
If DbSeek(xFilial("MEI") + "T") 
	While !(MEI->(Eof())) .AND. (AllTrim(MEI->MEI_TPIMPD) == "T")
		
		If STDValRule( cCliCode , cCliStore ) // Validacoes gerais
		
		  	cPriority := STDPriority( MEI->MEI_CODREG ) // Busca prioridade (MEJ_PRINUM)
			AADD( aRet , { MEI->MEI_CODREG, cPriority , MEI->MEI_ACUMUL , MEI->MEI_DESCRI, MEI->MEI_CODTAB } )  
		    
		EndIf 
			
		MEI->(DbSkip()) 
		
	EndDo	
EndIf

RestArea( aArea ) 

Return aRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} STDItemRlDi
Function Busca Regras de Desconto do Tipo Item

@param 	 cItemCode			Codigo do Item
@param 	 nValueItem			Valor do Item
@param 	 cTypeProd			Tipo Saldão ou mostruário
@param	 cCliCode			Codigo do cliente
@param	 cCliStore			Loja do Cliente
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1] MEI_CODREG					1 Codigo da Regra
@return  aRet[2] MEJ_PRINUM	  				2 Prioridade da Regra
@return  aRet[3] MEI_ACUMUL					3 Indica se a Regra é acumulativa
@return  aRet[4] MEI_DESCRI					4 Descrição da Regra
@obs										Verifica condicoes de Filial, Hora/Data/Semana e Cliente. Nao verifica o Range de Valores
@sample
/*/
//-------------------------------------------------------------------
Function STDItemRlDi( 	cItemCode 	, nValueItem , cTypeProd , cCliCode , ;
							cCliStore, cTyPeCall	)

Local aArea			:= GetArea()		// Guarda Alias Corrente
Local aRet 			:= {}           	// Retorna regras validas  
Local aRange		:= {}				// Armazena Range de valores
Local lCategory		:= .F.				// Indica se existe categoria para o produto
Local cCategory		:= ""				// Armazena categoria do produto
Local nI            := 0                // Variavel contador
Local aAreaSB1		:= SB1->(GetArea()) // Salva a posição da SB1

Default cItemCode 	:= ""	
Default nValueItem 	:= 0
Default cTypeProd 	:= ""
Default cCliCode 	:= ""
Default cCliStore 	:= ""
Default cTyPeCall   := "I" 				// "I" = Item, "T" = Total 

PosSB1(cItemCode) // Posiciona no produto

/*/	
	Se existir categoria no produto, vai pesquisar nas regras por categoria
/*/ 
DbSelectArea("ACV")                              
DbSetOrder(5) //ACV_FILIAL+ACV_CODPRO+ACV_CATEGO
If DbSeek(xFilial("ACV") + alltrim(cItemCode))
	cCategory 	:= ACV->ACV_CATEGO 
	lCategory	:= .T.
	LjGrvLog("Regra de desconto", "STDItemRlDi - Categoria: " + cCategory,)
Else
	ACV->( DbSetOrder(2) ) // ACV_FILIAL+ACV_GRUPO+ACV_CODPRO+ACV_CATEGO
	If !Empty(SB1->B1_GRUPO) .AND. DbSeek(xFilial("ACV") + alltrim(SB1->B1_GRUPO))
		cCategory 	:= ACV->ACV_CATEGO 
		lCategory	:= .T.
		LjGrvLog("Regra de desconto", "STDItemRlDi - Categoria: " + cCategory,)
	EndIf
EndIf

RestArea(aAreaSB1)

/*/	
	Busca regra por Categoria
/*/ 
If lCategory
	DbSelectArea("MB8")
	DbSetOrder(3)//MB8_FILIAL+MB8_CATEGO
	If DbSeek(xFilial("MB8") + cCategory ) //MB8_FILIAL+MB8_CATEGO
		While !MB8->(Eof()) .AND. AllTrim(MB8->MB8_CATEGO) == AllTrim(cCategory)
			DbSelectArea("MEI")
			DbSetOrder(1)//MEI_FILIAL+MEI_CODREG
			If DbSeek(xFilial("MEI") + MB8->MB8_CODREG )
			
				If (MEI->MEI_TPIMPD == cTyPeCall) .And. (MEI->MEI_ATIVA = "1") //só irá consultar regras ATIVAS
	
					If STDValRule( cCliCode , cCliStore ) // Validacao generica por Data, Ativa, Cliente, Grupo de cliente, Filial e Prioridade
		        		
		        		If STDValMoSa( MEI->MEI_CODREG , cTypeProd ) // Validacao especifica item (Mostruario/Saldao)
		                    
		                    cPriority := STDPriority( MEI->MEI_CODREG ) // Busca prioridade (MEJ_PRINUM)
		                    
		          			AADD( aRet , { 	MEI->MEI_CODREG	,;	// 01-Codigo da Regra de Desconto
							  				cPriority		,;	// 02-Prioridade da Regra de Desconto
											MEI->MEI_ACUMUL	,;	// 03-Acumulativa (Sim/Nao)
											MEI->MEI_DESCRI	,;	// 04-Descrição da regra
											MB8->MB8_DESCPR	,;	// 05-Percentual de Desconto
											MB8->MB8_DESCVL	,;	// 06-Valor de Desconto
											""				,;	// 07-Codigo do Produto
											"PRO"			,;	// 08-Indica se é uma regra especifica por produto
											MB8->MB8_TPREGR	,;	// 09-Tipo de Regra
											MB8->MB8_REFGRD	,;	// 10-Referencia do Grid (Item da Regra)
											Nil				,;	// 11-Posicao nao usada
											lCategory		,;	// 12-Indica que existe regra por categoria do produto
											MB8->MB8_QTDPRO ,;	// 13-Qtd. Venda para aplicacao da regra
											MB8->(Recno())} )	// 14-Recno do Registro da tabela
							LjGrvLog("Regra de desconto", "STDItemRlDi - Regra por Categoria - Regra: " + MEI->MEI_CODREG,)			
		          			   
		                EndIf
					EndIf	
				Endif	
			EndIf
			MB8->(DbSkip())
		EndDo
	EndIf
EndIf

/*/	
	Busca regra por produto
/*/ 
DbSelectArea("MB8")
DbSelectArea("MEI")
MB8->(DbSetOrder(2)) //MB8_FILIAL+MB8_CODPRO
If MB8->(DbSeek(xFilial("MB8") + cItemCode )) //MB8_FILIAL+MB8_CODPRO
	While MB8->(!EOF()) .AND. AllTrim(MB8->MB8_CODPRO) == AllTrim(cItemCode)
		MEI->(DbSetOrder(1))//MEI_FILIAL+MEI_CODREG
		If MEI->(DbSeek(xFilial("MEI")+ MB8->MB8_CODREG ))
		
        	If (MEI->MEI_TPIMPD == cTyPeCall) .And. (MEI->MEI_ATIVA = "1") //só irá consultar regras ATIVAS
        	
	        	If STDValRule( cCliCode , cCliStore ) // Validacao generica
	        		
	        		If STDValMoSa( MEI->MEI_CODREG , cTypeProd ) // Validacao especifica item (Mostruario/Saldao)
	                    
	                    cPriority := STDPriority( MEI->MEI_CODREG ) // Busca prioridade (MEJ_PRINUM)
	                    
	          			AADD( aRet , { 	MEI->MEI_CODREG	,;	// 01-Codigo da Regra de Desconto
						  				cPriority		,;	// 02-Prioridade da Regra de Desconto
										MEI->MEI_ACUMUL	,;	// 03-Acumulativa (Sim/Nao)
										MEI->MEI_DESCRI	,;	// 04-Descrição da regra
	          			 				MB8->MB8_DESCPR	,;	// 05-Percentual de Desconto
										MB8->MB8_DESCVL	,;	// 06-Valor de Desconto
										MB8->MB8_CODPRO	,;	// 07-Codigo do Produto
										"PRO"			,;	// 08-Indica se é uma regra especifica por produto
										MB8->MB8_TPREGR	,;	// 09-Tipo de Regra
										MB8->MB8_REFGRD	,;	// 10-Referencia do Grid (Item da Regra)
										Nil				,;	// 11-Posicao nao usada
										lCategory		,;	// 12-Indica que existe regra por categoria do produto
										MB8->MB8_QTDPRO ,;	// 13-Qtd. Venda para aplicacao da regra
										MB8->(Recno())} )	// 14-Recno do Registro da tabela
						LjGrvLog("Regra de desconto", "STDItemRlDi - Regra por Produto - Regra: " + MEI->MEI_CODREG,)								
	          			   
	                EndIf
				EndIf
			EndIf
		EndIf  
		MB8->(DbSkip())		
	EndDo
EndIf

/*/	
	Busca regra por Range(Todos os produtos desde que pertenca ao Range)
/*/ 
DbSelectArea("MEI")
MEI->(DbSetOrder(3)) //MEI_FILIAL+MEI_TPIMPD
If MEI->(DbSeek(xFilial("MEI") + "I")) 
	While !MEI->(Eof()) 
	  		    
		If MEI->MEI_ATIVA = "1" .And. (MEI->MEI_TPIMPD == cTyPeCall) 
			/*/	
				Busca Range para a regra.
			/*/ 
			aRange := STDIteRang( MEI->MEI_CODREG , nValueItem )
			
			If Len(aRange) > 0
			
				If STDValRule( cCliCode , cCliStore ) // Validacao generica	
					
					cPriority := STDPriority( MEI->MEI_CODREG ) // Busca prioridade (MEJ_PRINUM)
					
					For nI := 1 to len(aRange)
						AADD( aRet , { 	MEI->MEI_CODREG	,;	// 01-Codigo da Regra de Desconto
										cPriority		,;	// 02-Prioridade da Regra de Desconto
										MEI->MEI_ACUMUL	,;	// 03-Acumulativa (Sim/Nao)
										MEI->MEI_DESCRI	,;	// 04-Descrição da regra
										aRange[nI][3]	,;	// 05-Percentual de Desconto
										aRange[nI][4]	,;	// 06-Valor de Desconto
										Nil				,;	// 07-Codigo do Produto
										"TOT"			,;	// 08-Indica se é uma regra especifica por produto
										aRange[nI][5]	,;	// 09-Tipo de Regra
										aRange[nI][6]	,;	// 10-Referencia do Grid (Item da Regra)
										aRange[nI][2]	,;	// 11-Valor Final da Faixa
										lCategory		,;	// 12-Indica que existe regra por categoria do produto
										0				,;	// 13-Qtd. Venda para aplicacao da regra
										0 				} )	// 14-Recno do Registro da tabela										
					Next nI

				EndIf
			EndIf
		Endif
		MEI->(DbSkip())		
	EndDo
EndIf	

RestArea( aArea )

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDValidPer
Function Valida o período da regra.

@param 	 dDatDe		 		Data inicial da regra
@param 	 dDatAte			Data final da regra
@param 	 cCodReg			Codigo da regra

@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se a regra é válida
@obs     					Verifica condicoes de Data, Hora e Dia da Semana
@sample
/*/
//-------------------------------------------------------------------
Static Function STDValidPer( dDatDe, dDatAte, cCodReg )   

Local aArea		:= GetArea()		// Posicionamento atual
Local lRet     	:= .F.				// Retorno da Funcao
Local cTime    	:= Time()			// Horario atual da chamada da funcao para validar com horario da regra
Local dData    	:= Date()			// Armazena a data atual para validar a data da regra
Local cDiaSem  	:= CDOW(dData)		// Converte data para um dia da semana   
Local aHora    	:= {}				// Armazena a hora da regra para validar horario   

Default dDatDe 	:= CTOD(" ")	
Default dDatAte := CTOD(" ")	
Default cCodReg := ""			

ParamType 0 var  dDatDe 		As Date			Default CTOD(" ")				
ParamType 1 var  dDatAte		As Date			Default CTOD(" ")	
ParamType 2 var  cCodReg		As Character		Default ""	

/*/	
	Valida se a data informada e permitida para aplicar a regra de acordo com a data atual
/*/ 
If (dData >= dDatDe) .And. (dData <= dDatAte)
	DbSelectArea("MB7")
	DbSetOrder(1) //MB7_FILIAL+MB7_CODREG
	If DbSeek(xFilial("MB7") + cCodReg)  
		Do Case   
		Case Upper(cDiaSem) == "SUNDAY"		//Domingo
			aHora := {AllTrim(MB7->MB7_HRDOMI), AllTrim(MB7->MB7_HRDOMF)}
		Case Upper(cDiaSem) == "MONDAY"		//Segunda
			aHora := {AllTrim(MB7->MB7_HRSEGI), AllTrim(MB7->MB7_HRSEGF)}
		Case Upper(cDiaSem) == "TUESDAY"	//Terca
			aHora := {AllTrim(MB7->MB7_HRTERI), AllTrim(MB7->MB7_HRTERF)}
		Case Upper(cDiaSem) == "WEDNESDAY" //Quarta
			aHora := {AllTrim(MB7->MB7_HRQUAI), AllTrim(MB7->MB7_HRQUAF)}
		Case Upper(cDiaSem) == "THURSDAY"	//Quinta
			aHora := {AllTrim(MB7->MB7_HRQUII), AllTrim(MB7->MB7_HRQUIF)}
		Case Upper(cDiaSem) == "FRIDAY"		//Sexta
			aHora := {AllTrim(MB7->MB7_HRSEXI), AllTrim(MB7->MB7_HRSEXF)} 
		Case Upper(cDiaSem) == "SATURDAY"	//Sabado
			aHora := {AllTrim(MB7->MB7_HRSABI), AllTrim(MB7->MB7_HRSABF)}
		End
	EndIf
	MB7->(DbCloseArea())
EndIf


// Valida se a hora da regra e permitida para ser aplicada de acordo  
// com a data atual.                                                 

If Len(aHora) < 1
	lRet := .F. 
Else
	If cTime > aHora[1] .And. cTime < aHora[2]
		lRet := .T.	
	EndIf
EndIf

RestArea(aArea)	

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBValPagto
Function Valida se a Regra é do tipo Pagamento

@param 	 cCodRule			Código da regra de desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se a regra é do tipo pagamento
@obs     					As condicoes foram retiradas porque elas 
                            nao validavam com exatidao, ou seja, so 
                            validava se o codigo da regra existia na 
                            MB4 e nao a Forma de pagto selecionada 
                            era igual. 04/08/2014
@sample
/*/
//-------------------------------------------------------------------
Static Function STBValPagto( cCodRule, lPgto )

Local aArea		   		:= GetArea()  		// Guarda Alias corrente  
Local lRet 		  		:= .F.				// Retorno da Funcao 

Default cCodRule 		:= ""	 	  	
Default lPgto           := .F.

ParamType 0 var  cCodRule As Character Default "" 

/*/
	Admite como sendo por PAGAMENTO se tiver encontrado registro 
	referente a aba/guia de NEGOCIACAO do cadastro da regra.
/*/   
 
DbSelectArea("MB2")
DbSetOrder(1)  //MB2_FILIAL+MB2_CODREG+MB2_REFGRD
If DbSeek(xFilial("MB2") + cCodRule)  
	If MB2->MB2_PGTO == "1"//Considera Forma de pagamento
		If MB2->MB2_TPREGR == "2" .Or. MB2->MB2_TPREGR == "3"//Brinde ou Bonificacao 
			If lPgto
				lRet := .T. //Regra por Total apos Finalizar a Venda 
			Else
				lRet := .F. //Porque a validacao da forma de pagto é feita no OnClik do objeto no momento de selecionar a Forma de pagamento		   				
			Endif	
		ELse
			if isInCallStack("STBPromPgto") .OR. isInCallStack("STIAddNewPan")
				lRet := .T. //retona .T. para considerar a regra por forma de pagamento,mas so se vier do click da forma de pagamento 
			EndIf
		Endif
	Else
		lRet := .T.
	Endif
Endif			           

MB2->(DbCloseArea())	
	           
RestArea( aArea )

Return  lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STDValRule
Function Validacao da Regra de Desconto

@param 	 cCliCode			Código do cliente
@param 	 cCliStore			Loja do cliente
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se a regra é válida
@obs     					Verifica condicoes de Filial, Hora/Data/Semana e Cliente. Nao verifica o Range de Valores
@sample
/*/
//-------------------------------------------------------------------
Function STDValRule( cCliCode , cCliStore )

Local aArea		   			:= GetArea()		// Alias Corrente
Local lRet		   			:= .T.				// Retorna se a regra eh valida 
Local aFilMB3				:= {}				// Filiais da regra de desconto
Local lA1_CLIFUN			:= SA1->(ColumnPos("A1_CLIFUN")) > 0 //Importante: esta validação deve ser mantida, pois este campo existe no compatibilizador da 11.80 e não existe no dicionário da 12
Local cCliFun				:= "" //Cliente Funcionario?
Local lAI0_CLIFU			:= AI0->(ColumnPos("AI0_CLIFUN")) > 0 //Foi protegido este campo pois este programa vai subir na release 12.1.16 e campo na posterior

Default cCliCode				:= ""				
Default cCliStore			:= ""				

ParamType 0 var  cCliCode 		As Character	Default ""				
ParamType 1 var  cCliStore		As Character	Default ""	

/*/	
	ATIVA
/*/
If lRet
	If (MEI->MEI_ATIVA <> "1")
		lRet := .F.
	EndIf
EndIf
/*/	
	CLIENTE LOJA
/*/
If lRet 
	If !Empty(AllTrim( MEI->MEI_CODCLI + MEI->MEI_LOJA )) .AND. ( AllTrim( MEI->MEI_CODCLI + MEI->MEI_LOJA ) <> AllTrim( cCliCode + cCliStore ) )
		lRet := .F.
	EndIf
EndIf

/*/	
	GRUPO CLIENTE
/*/	
If lRet         	    
	If !Empty(AllTrim(MEI->MEI_GRPVEN)) .AND. !lDescGrupo
		DbSelectArea("SA1")
		DbSetOrder(1) 
		If DbSeek(xFilial("SA1")+ cCliCode + cCliStore)	
			If SA1->A1_GRPVEN <> MEI->MEI_GRPVEN
				lRet := .F.
				lDescGrupo := .F.
			Else
				If !Empty(SA1->A1_GRPVEN) .AND. AllTrim(SA1->A1_GRPVEN) == AllTrim(MEI->MEI_GRPVEN)
					lDescGrupo := .T.
				EndIf
			Endif	
		Endif
	Endif		
EndIf	

/*/	
	Se a regra for por desconto de funcionario, porem no cad de cliente nao estiver como desconto de funcionario nao se aplica a regra
/*/ 

If lRet
	If (MEI->MEI_DESFUN == "S") 
	
		If lAI0_CLIFU
			cCliFun := GetAdvFVal("AI0","AI0_CLIFUN",xFilial("AI0")+cCliCode + cCliStore,1,"2")
		EndIf
		
		If Empty(cCliFun) .AND. lA1_CLIFUN
			cCliFun := GetAdvFVal("SA1","A1_CLIFUN",xFilial("SA1")+cCliCode + cCliStore,1,"2")
		EndIf
		If !(cCliFun  == "1")
			lRet := .F.
		EndIf 
	EndIf	
EndIf 

/*/	
	DIA, DATA E HORA
/*/
If lRet 
	If !(STDValidPer( MEI->MEI_DATDE , MEI->MEI_DATATE , MEI->MEI_CODREG ))
		lRet := .F.
	EndIf
EndIf  

/*/	
	FILIAL
	Valida tambem Grupo de Filiais
/*/
If lRet	
	
	DbSelectArea("MB3")
	DbSetOrder(3) // MB3_FILIAL+MB3_CODREG+MB3_TIPO+MB3_CODGRU+MB3_CODEMP+MB3_CODFIL
	
	If DbSeek( xFilial("MB3") + MEI->MEI_CODREG ) 
	
		While MB3->( !Eof() .And. MB3_FILIAL+MB3_CODREG == xFilial("MB3")+MEI->MEI_CODREG )
		
			// 1. Tipo Filial
			// 2. Tipo Grupo de Filiais
			
			IF MB3->MB3_TIPO == "1"
	
				If MB3->MB3_CODEMP == SubStr(cNumEmp,1,2)

					aAdd( aFilMB3 , MB3->MB3_CODFIL )
				
				Endif
			
			ElseIF MB3->MB3_TIPO == "2"
			
				// Explode o grupo de filiais
				SAU->(dbSetOrder(1))
				IF SAU->( dbSeek( xFilial("SAU") + MB3->MB3_CODGRU ) )             
				
					While SAU->( !EOF() .And. SAU->AU_FILIAL+RTrim(SAU->AU_CODGRUP) == xFilial("SAU")+RTrim(MB3->MB3_CODGRU) )
						
						If Ascan( aFilMB3 , SAU->AU_CODFIL ) == 0  						
							aAdd( aFilMB3 , SAU->AU_CODFIL )
						Endif					
						SAU->( DbSkip() )
										
					End
								
				Endif
				
			Endif
		
			MB3->( DbSkip() )
			
		End
		

		// Verifica se a filial esta entre as filiais permitidas
		If Ascan( aFilMB3 , AllTrim( FWCodFil() ) ) == 0
			lRet := .F.			
		Endif
			
	Else
		lRet := .F.	
	EndIf

EndIf
  	
/*/	
	PRIORIDADE
/*/
If lRet
	DbSelectArea("MEJ")
	DbSetOrder(2) //MEJ_FILIAL+MEJ_CODREG
	If !(DbSeek(xFilial("MEJ") + MEI->MEI_CODREG))
		lRet := .F.
	EndIf
EndIf						
				
RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRangRul
Function Busca o(s) Range(s) da Regra de Desconto

@param 	 cCodRule			Código da regra de desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1] nMB2_VLRINI	   			1 Valor inicial
@return  aRet[2] nMB2_VLRFIM	 			2 Valor final
@return  aRet[3] nMB2_PDESC					3 Percentual de desconto
@return  aRet[4] nMB2_VLRFX					4 Valor de desconto
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDRangRul( cCodRule, cTipo )

Local aArea		   		:= GetArea()  		// Guarda Alias corrente  
Local aRet 		  		:= {}				// Armazena o(s) Range(s) da Regra de Desconto

Default cCodRule 		:= ""	 	  	
Default cTipo           := ""

ParamType 0 var  cCodRule As Character Default "" 
				
DbSelectArea("MB2")
DbSetOrder(1)  //MB2_FILIAL+MB2_CODREG+MB2_REFGRD
If DbSeek(xFilial("MB2") + cCodRule)  
	While !MB2->(Eof()) .AND. (MB2->MB2_CODREG == cCodRule)
		If Empty(cTipo)
			AADD( aRet, { MB2->MB2_VLRINI , MB2->MB2_VLRFIM , MB2->MB2_PDESC , MB2->MB2_VLRFX, ""/*MB2->MB2_IDPROD*/,MB2->MB2_TPREGR,MB2_REFGRD  } )
		Else
			If MB2->MB2_TPREGR == cTipo .Or. MB2->MB2_TPREGR <> "1"// Desconto não é contemplado para manter o legado ja existe			
				AADD( aRet, { MB2->MB2_VLRINI , MB2->MB2_VLRFIM , MB2->MB2_PDESC , MB2->MB2_VLRFX, ""/*MB2->MB2_IDPROD*/,MB2->MB2_TPREGR,MB2_REFGRD  } )		   
			Endif
		Endif	
		MB2->(DbSkip())
	EndDo
EndIf

RestArea( aArea )

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDIteRang
Function Busca Range que possa ser aplicado para o valor do Item

@param 	 cCodRule			Código da regra de desconto
@param 	 nValueItem			Valor do Item
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet[1] nMB2_VLRINI		 		1 Valor inicial
@return  aRet[2] nMB2_VLRFIM	 			2 Valor final
@return  aRet[3] nMB2_PDESC					3 Percentual de desconto
@return  aRet[4] nMB2_VLRFX					4 Valor de desconto
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDIteRang( cCodRule , nValueItem )
                   
Local aArea	   			:= GetArea()			// Alias Corrente
Local aRet				:= {}					// Retorno funcao

Default cCodRule 		:= ""	 	  	
Default nValueItem 		:= 0

ParamType 0 var  cCodRule 	As Character 	Default "" 
ParamType 0 var  nValueItem As Numeric 		Default 0 
				
DbSelectArea("MB2")
DbSetOrder(1) //MB2_FILIAL+MB2_CODREG+MB2_REFGRD
If DbSeek(xFilial("MB2") + cCodRule ) 
	While !MB2->(Eof()) .AND. (MB2->MB2_CODREG == cCodRule) 
		If ( MB2->MB2_VLRINI < nValueItem ) .AND. ( MB2->MB2_VLRFIM > nValueItem ) // Valida Range
			AADD( aRet, { MB2->MB2_VLRINI , MB2->MB2_VLRFIM , MB2->MB2_PDESC , MB2->MB2_VLRFX, MB2->MB2_TPREGR, MB2->MB2_REFGRD } )
		EndIf
		MB2->(DbSkip())
	EndDo
EndIf

RestArea( aArea )

Return aRet
   
              
//-------------------------------------------------------------------
/*/{Protheus.doc} STDPayForms
Function Busca a(s) Forma(s) de pagamento da Regra de Desconto

@param 	 cCodRule			Código da regra de desconto
@param	 cForma				Forma de pagamento selecionada na venda
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet				Retorna as formas de pagamento cadastradas para a regra de desconto
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDPayForms( cCodRule, cForma )

Local aArea			:= GetArea()	// Armazena alias corrente
Local aRet			:= {}	   		// Retorno funcao
Local nI			:= 0			// Contador

Default cCodRule 	:= ""			// Código da regra de desconto varejo
Default cForma		:= ""  			// Forma de pagamento selecionada na venda		 	  	

ParamType 0 Var  cCodRule As Character Default "" 

lFrmDesc := .F. // Setamos falso pois ela é chamada em diversas vezes e estava apresentando .T. de forma errada. 

DbSelectArea("MB4")
DbSetOrder(1)//MB4_FILIAL+MB4_CODREG+MB4_CODFRM
If DbSeek(xFilial("MB4") + cCodRule)
	While !MB4->(Eof()) .AND. ( MB4->MB4_CODREG == cCodRule )
		AADD( aRet ,  AllTrim(MB4->MB4_CODFRM)  )
		DbSkip()
	EndDo
EndIf 

RestArea(aArea)

If !Empty(aRet)
	For nI := 1 To Len(aRet)
		If AllTrim(aRet[nI]) == AllTrim(cForma)
			lFrmDesc := .T.
		EndIf	
	Next	
EndIf

Return  aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDPropForm
Function Verifica se a Regra de Desconto é proporcional ou não

@param 	 cCodRule			Código da regra de desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna as formas de pagamento cadastradas para a Regra de Desconto
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDPropForm( cCodRule )

Local aArea		 		:= GetArea()	// Armazena alias corrente
Local lRet				:= .F.	   		// Retorno funcao

Default cCodRule 		:= ""	 	  	

ParamType 0 Var  cCodRule As Character Default "" 

DbSelectArea("MB4")
DbSetOrder(1)//MB4_FILIAL+MB4_CODREG+MB4_CODFRM
If DbSeek(xFilial("MB4") + cCodRule )
	lRet := ( MB4->MB4_PROPOR == "1" )
EndIf 

RestArea(aArea)

Return  lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDValMoSa
Function Valida se a Regra de Desconto é válida para Saldão/Mostruário

@param 	 cCodRule			Código da regra de desconto
@param 	 cTypeProd			Tipo Saçdão ou Mostruário
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se a regra é válida para produto saldão/mostruário
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Static Function STDValMoSa( cCodRule , cTypeProd ) 

Local lRet 		:= .T.					// Retorno da funcao
Local aArea 	:= GetArea()				// Armazena Alias Corrente
Local aAreaMEI	:= MEI->(GetArea())	// Armazena Area MEI

Default cCodRule 		:= ""	 	  	
Default cTypeProd 		:= ""

ParamType 0 Var  cCodRule  As Character Default "" 
ParamType 0 Var  cTypeProd As Character Default "" 

DbSelectArea("MEI")
DbSetOrder(1)//MEI_FILIAL+MEI_CODREG
If DbSeek(xFilial("MEI") + cCodRule )
	If ((MEI->MEI_PRDMOS == "S") .And. cTypeProd <> "S") .Or. ((MEI->MEI_PRDMOS == "M") .AND. cTypeProd <> "M")
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaMEI)
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDPriority
Function Busca Prioridade da Regra

@param 	 cCodRule			Código da regra de desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  cPriority				Retorna prioridade da regra
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Static Function STDPriority( cCodRule )

Local aArea		 		:= GetArea()			// Armazena alias corrente
Local aAreaMEJ			:= MEJ->(GetArea())    // Armazena Posicao MEJ
Local cPriority			:= ""	   				// Retorno funcao

Default cCodRule 		:= ""	 	  	

ParamType 0 Var  cCodRule As Character Default ""

If !Empty( cCodRule )
	DbSelectArea("MEJ")
	DbSetOrder(2)//MEJ_FILIAL+MEJ_CODREG
	If DbSeek( xFilial("MEJ") + cCodRule )
		cPriority := MEJ->MEJ_PRINUM
	EndIf
EndIf

RestArea(aAreaMEJ)
RestArea(aArea)
				
Return cPriority				
				

//-------------------------------------------------------------------
/*/{Protheus.doc} STDNextSale
Function Verifica se a Regra é Desconto para P´roxima venda

@param 	 cCodRule			Código da regra de desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se é desconto na próxima venda
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDNextSale( cCodRule )

Local aArea		 		:= GetArea()			// Armazena alias corrente
Local aAreaMEI			:= MEI->(GetArea())	// Armazena area MEI
Local lRet				:= .F.					// Retorna se a regra eh para desconto na proxima venda

Default cCodRule 		:= ""	 	  	

ParamType 0 Var  cCodRule As Character Default ""

DbSelectArea("MEI")
DbSetOrder(1)//MEI_FILIAL+MEI_CODREG
If DbSeek(xFilial("MEI") + cCodRule )
	lRet := MEI->MEI_DESCPR == "2"  
EndIf

RestArea( aAreaMEI )
RestArea( aArea )

Return lRet  


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRuleDate
Function Busca a Data Final de Validade da Regra

@param 	 cCodRule			Código da regra de desconto
@author  Varejo
@version P11.8
@since   29/03/2012
@return  dRet				Retorna se é desconto na próxima venda
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDRuleDate( cCodRule )

Local aArea		 		:= GetArea()			// Armazena alias corrente
Local aAreaMEI			:= MEI->(GetArea())	// Armazena area MEI
Local dRet				:= CToD("")				// Data de validade da Regra de Desconto

Default cCodRule 		:= ""	 	  	

ParamType 0 Var  cCodRule As Character Default ""  

DbSelectArea("MEI")
DbSetOrder(1)//MEI_FILIAL+MEI_CODREG
If DbSeek(xFilial("MEI") + cCodRule )
	dRet := MEI->MEI_DATATE
EndIf

RestArea( aAreaMEI )
RestArea( aArea )

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDProdDA1
Funcao responsavel por verificar todos os produtos que existem em determinada
tabela de preco

@param 	 cTabPrc			Código da tabela de preco
@author  Bruno Almeida
@version P12
@since   02/05/2019
@return  
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDProdDA1(cTabPrc, oCesta)

Local nI := 0 //Variavel de loop
Local nTotal := 0 //Valor total para conceder o desconto

For nI := 1 To oCesta:Length()
	oCesta:GoLine(nI)
	If !oCesta:IsDeleted(nI) .AND. AllTrim(oCesta:GetValue("L2_CODTAB")) == AllTrim(cTabPrc)
		nTotal += oCesta:GetValue("L2_VLRITEM")
	EndIf
Next nI
nTotDa1 := nTotal

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGetDA1
Funcao responsavel em retornar o valor total dos produtos para condecer o 
desconto

@param 	 
@author  Bruno Almeida
@version P12
@since   02/05/2019
@return  nTotDa1 - Total dos produtos
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDGetDA1()
Return nTotDa1


//-------------------------------------------------------------------
/*/{Protheus.doc} STDAdmFn
Função para retornar Administradora Financeira (MB6) 
envolvido na Regra de Desconto Varejo utilizada

@param 	 cCodReg - Código da Regra de Desconto 
@author  Caio Okamoto
@version P12
@since   18/11/2021
@return  array com administradora financeira (MB6)
@obs     					
@sample
/*/
//-------------------------------------------------------------------
Function STDAdmFn(cCodReg)  
Local aArea	:= GetArea()
Local aRet 	:= {}

Default cCodReg		:= ""

DbSelectArea("MB6")
MB6->( DbSetOrder(1) )	//MB6_FILIAL+MB6_CODREG+MB6_ADMFIN
If MB6->( DbSeek(xFilial("MB6") + cCodReg) )
	While MB6->(!Eof()) .AND. MB6->MB6_FILIAL + MB6->MB6_CODREG == xFilial("MB6") + cCodReg
		AADD(aRet, MB6->MB6_ADMFIN )
		MB6->( DbSkip() ) 
	EndDo 
EndIf

RestArea(aArea)
Return aRet

/*/{Protheus.doc} STDGetGrp
	Retorna o conteúdo da variavel lDescGrupo
	@type  Function
	@author Varejo
	@since 11/10/2022
	@version 1.0
	@param 
	@return lDescGrupo, logico, variavel que contém o conteúdo .T. se for desconto por grupo de cliente ou .F. para quando não é desconto por grupo.
	/*/
Function STDGetGrp()
Return lDescGrupo

/*/{Protheus.doc} STDSetGrp
	Seta o valor para a variavel lDescGrupo limpando ao final de cada venda
	@type  Function
	@author Varejo
	@since 11/10/2022
	@version 1.0
	@param lValue, logico, seta um default para a variavel lDescGrupo
	@return
	/*/
Function STDSetGrp(lValue)
Default lValue := .F.
lDescGrupo := lValue
Return

/*/{Protheus.doc} STDGetFrm
Função para retornar se a forma de pagamento Existe dentro da regra de desconto
@author  Jeferson Mondeki
@version P12
@since   11/07/2023
@return  lFrmDesc, logico, variavel que contém o conteúdo .T. se existir e .F. se não existir.
@obs     					
@sample
/*/
//-------------------------------------------------------------------

Function STDGetFrm()
Return lFrmDesc

/*/{Protheus.doc} STDSetFrm
Função para setar se a forma de pagamento Existe dentro da regra de desconto
na variavel lFrmDesc limpando ao final de cada venda
@param lValue, logico, seta um default para a variavel
@author  Jeferson Mondeki
@version P12
@since   11/07/2023
@return  lValue, logico
@obs     					
@sample
/*/
//-------------------------------------------------------------------

Function STDSetFrm(lValue)
Default lValue := .F.
lFrmDesc := lValue
Return


//lDscTotSPg

/*/{Protheus.doc} STDGetDTSPg
	Regra de Desconto Varejo no Total Sem Forma de Pagamento e Sem Grupo de Cliente
	@type  Function
	@author caio.okamoto
	@since 21/11/2023
	@version 12.1.2210
	@return lDscTotSPg, lógico, Regra de Desconto Varejo no Total Sem Forma de Pagamento e Sem Grupo de Cliente
	@example
	(examples)
	@see (links_or_references)
	/*/
Function STDGetDTSPg()
Return lDscTotSPg

/*/{Protheus.doc} STDSetDTSPg
	Regra de Desconto Varejo no Total Sem Forma de Pagamento e Sem Grupo de Cliente
	@type  Function
	@author caio.okamoto
	@since 21/11/2023
	@version 12.1.2210
	@param lValue, lógico, Regra de Desconto Varejo no Total Sem Forma de Pagamento e Sem Grupo de Cliente
	/*/
Function STDSetDTSPg(lValue)
Default lValue := .F. 
lDscTotSPg:= lValue
Return 
