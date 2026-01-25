#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static 		oModel 	:= 	Nil			// Model 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRsnDesc
Function Motivo de Desconto

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se existe cadastro de Motivo de Desconto
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRsnDesc() 

Local	lRet	:= .F.			// Retorna se existe cadastro de Motivo de Desconto
Local 	aArea	:= GetArea()

DbSelectArea("MDT")
DbSetOrder(1) // MDT_FILIAL + MDT_CODIGO
DbSeek( xFilial("MDT") , .T. ) // Busca aproximada

lRet := !EOF() .And. xFilial("MDT") == MDT->MDT_FILIAL

RestArea(aArea)
		
Return lRet    


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRFDGet
Busca Motivos de Desconto Cadastrados

@param
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aReasons				Retorna motivos de desconto cadastrados
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRFDGet(cTpMov)

Local aArea		:= GetArea()									// Armazena alias corrente
Local aReasons		:= {}											// Retorno funcao
Local lMDT_TPMOT	:= (MDT->( FieldPos("MDT_TPMOT") ) > 0)		// Verifica se o campo que controla o filtro pelo Tipo de Motivo existe 

Default cTpMov		:= "3"											// Analisa o campo MDT_TPMOV, Sendo 1=Por item, 2=Por total e 3=Ambos (Valor default = 3) 

DbSelectArea("MDT")
DbSetOrder(1) // MDT_FILIAL + MDT_CODIGO
MDT->(DbGoTop())
If MDT->(DbSeek( xFilial("MDT") )) // Busca aproximada
	While !EOF() .AND. xFilial("MDT") == MDT->MDT_FILIAL
		If !lMDT_TPMOT .Or. (MDT->MDT_TPMOT ==  cTpMov .Or. MDT->MDT_TPMOT ==  "3")  
			AADD( aReasons , { MDT->MDT_CODIGO , MDT->MDT_DESCRI } )
		EndIf 
		MDT->(DbSkip())
	EndDo
EndIf

RestArea(aArea)

Return aReasons

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRFDGet
Verifica se existe Motivos de Desconto Cadastrado para o código passado

@param  cMotCode  - Codigo do Motivo
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se encontrou
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRFDFromRD(cMotCode)

Local lRet		:= .F.				// Retorno funcao
Local aArea		:= GetArea()		// Armazena area corrente

Default cMotCode := ""

ParamType 0 Var cMotCode 	AS Character	Default ""

DbSelectArea("MDT")
DbSetOrder(1) // MDT_FILIAL + MDT_CODIGO
If MDT->(DbSeek( xFilial("MDT") + cMotCode ))
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRFDGetModel
Cria estrutura de dados do Model

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  oModel - Retorna estrutura de dados do Model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDRFDGetModel() 	

Local oMasterStr 		:= 	Nil			// Estrutura Master 
    
If 	oModel == 	Nil
	/*/
		Monta estrutura de tabela
	/*/
	oMasterStr := CreateMasterStruct()
	/*/
		Monta estrura de grid da tabela de Motivo de Desconto (MDU)
   	/*/
	oGridStr := CreateGridStruct()		
	/*/
		Instacia Objeto
	/*/
	oModel := MPFormModel():New( 'MDU', /*bPreValidacao*/, /*bPosValidacao*/, /*bcommit*/ , /*bCancel*/ )
	
	oModel:AddFields( "MDU_MASTER" , /*cOwner*/ , oMasterStr )
	 
	oModel:AddGrid(	"MDU_GRID" 		,	"MDU_MASTER"		, oGridStr 		, /*b*/ 		,;
					/*bLinePost*/	,	/*bPreVal*/		,	/*bPosVal*/	, /*bLoad*/ 	)
					
	oModel:SetRelation( "MDU_GRID" , { { "MDU_FILIAL", 'xFilial( "MDU" )' }	, { "MDU_CODIGO", "MDU_CODIGO" } } , 'MDU_FILIAL + MDU_CODIGO' )
	
   		oModel:SetPrimaryKey( { "MDU_FILIAL" , "MDU_CODIGO" , "MDU_ITEM" } )  
	
	oModel:GetModel( "MDU_GRID" ):SetOptional( .T. ) 
	
	oModel:SetOperatin( 3 )
	
	oModel:Activate()
	
EndIf
	 	
Return oModel



//-------------------------------------------------------------------
/*/{Protheus.doc} CreateMasterStruct
Cria estrutura do Model Master

@param   
@author  Varejo
@version P11.8
@since   25/04/2012
@return  oStruct - Retorna estrutura do Model Master
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function CreateMasterStruct() 
    
Local oStruct 		:= FWFormModelStruct():New()	// Estrutura													
Local cX2Unico  	:= "" //X2_UNICO da tabela MDU

If ExistFunc('FWX2Unico') 
	cX2Unico := FWX2Unico("MDU") 
EndIf

oStruct:AddTable( 								;
FWX2CHAVE()                					, 	;  	// [01] Alias da tabela
StrTokArr( cX2Unico, '+' 	) 			, 	;  	// [02] Array com os campos que correspondem a primary key
FWX2Nome("MDU") 								)		// [03] Descricao da tabela
     
oStruct:AddField(                           	;
                     "FILIAL"  		   		,	; // [01] Titulo do campo
                     "FILIAL"  		   		,	; // [02] Desc do campo
                     "MDU_FILIAL" 	 		,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     FWSizeFilial()    		,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil               		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               								)	  // [14] Indica se o campo e virtual

oStruct:AddField(                           	;
                     "CODIGO"  			 	,	; // [01] Titulo do campo
                     "CODIGO"  	 		 	,	; // [02] Desc do campo
                     "MDU_CODIGO"			,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     TamSX3("B1_COD")[1]	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil               		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 						)	  // [14] Indica se o campo e virtual

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateGridStruct
Cria estrutura do Model Grid

@param   
@author  Varejo
@version P11.8
@since   25/04/2012
@return  oStruct - retorna estrutura do Model Grid
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function CreateGridStruct() 

Local oStruct 	:= FWFormModelStruct():New()		// Estrutura
Local cX2Unico  := "" //X2_UNICO da tabela MDU

If ExistFunc('FWX2Unico') 
	cX2Unico := FWX2Unico("MDU") 
EndIf

oStruct:AddTable( 							;
FWX2CHAVE()                				, 	;  	// [01] Alias da tabela
StrTokArr( cX2Unico, '+' ) 	   		, 	;  	// [02] Array com os campos que correspondem a primary key
FWX2Nome("MDU") 								)		// [03] Descrição da tabela

//Carrega informacoes de campos
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek("MDU"))

While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == "MDU"

  	oStruct:AddField(                             			      		;
	                     AllTrim( X3Titulo()  )        		  		,	; 	// [01] Titulo do campo
	                     AllTrim( X3Descric() )         			,	; 	// [02] ToolTip do campo
	                     AllTrim( SX3->X3_CAMPO )         	  		,	; 	// [03] Id do Field
	                     SX3->X3_TIPO                  		  		,	; 	// [04] Tipo do campo
	                     SX3->X3_TAMANHO               		  		,	; 	// [05] Tamanho do campo
	                     SX3->X3_DECIMAL                			,	; 	// [06] Decimal do campo
	                     Nil                         				,	; 	// [07] Code-block de validacaoo do campo
	                     Nil                          				,	; 	// [08] Code-block de validacaoo When do campo
	                     StrTokArr( AllTrim( X3CBox() ),';')  		, 	; 	// [09] Lista de valores permitido do campo
	                     Nil 										,	; 	// [10] Indica se o campo tem preenchimento obrigatorio
	                     Nil                         				, 	; 	// [11] Code-block de inicializacao do campo
	                     NIL                            			, 	; 	// [12] Indica se trata-se de um campo chave
	                     NIL                            			, 	; 	// [13] Indica se o campo pode receber valor em uma operacao de update.
	                     ( SX3->X3_CONTEXT == 'V' )     			)      	// [14] Indica se o campo e virtual
	 
	SX3->(DbSkip()) 
	
EndDo 

// Campo de Item necessario para utilizacao do modelo (campo chave do grid)

oStruct:AddField(                           	;
                     "ITEM"  		   		,	; // [01] Titulo do campo
                     "ITEM"  		 		,	; // [02] Desc do campo
                     "MDU_ITEM" 	 		,	; // [03] Id do Field
                     "N"              		,	; // [04] Tipo do campo
                     TamSX3("L2_ITEM")[1]	,	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil               		,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 						)	  // [14] Indica se o campo e virtual

Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRFDSFree
Limpa variáveis  

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRFDSFree()

If oModel <> Nil
	FreeObj(oModel)	
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecReason
Function Motivo de Desconto

@param   nItemLine		Linha do Item na Venda 
@param	lDeleleAll		Se Deleta todos os Itens do Grid MDU
@author  Varejo
@version P11.8
@since   25/04/2012
@return  lRet				Retorna se deletou com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecReason() 

Local	oModelGrid			:= NIL				// Componente Grid MDU
Local	aArea				:= GetArea()		// Armazena alias corrente
Local	nI					:= 0 				// Contador
Local 	nJ					:= 0				// Contador
Local	aStruct				:= {}				// Armazena estrutura de dados do modelo

If oModel <> NIL 

	oModelGrid 	:= oModel:GetModel("MDU_GRID") 
	aStruct		:= oModelGrid:GetStruct():aFields
	
	DbSelectArea("MDU")
	DbSetOrder(1)		// MDU_FILIAL+MDU_CODIGO
	For nI := 1 To oModelGrid:Length()
		oModelGrid:GoLine(nI)
		  
		If !( oModelGrid:IsDeleted() )
			RecLock("MDU",.T.)	
		   		For nJ := 1 To Len(aStruct)	        	
		        	If aStruct[nJ][3] <> "MDU_ITEM"		// Esse campo nao existe no banco	        	
						REPLACE MDU->&(aStruct[nJ][3]) WITH oModelGrid:GetValue(aStruct[nJ][3])					
					EndIf		
				Next nJ			
			MsUnlock()
			
			STFSLICreate(	Nil		, "UP"		   		, "UP"		, "NOVO"		, ;
							Nil	    , Nil				, Nil		, Nil			, ;
							"MDU"	, MDU->(RecNo())	, Nil 			   			)
		EndIf
	Next nI
	
EndIf

RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDDelReason
Function Motivo de Desconto

@param   nItemLine		Linha do Item na Venda 
@param	lDeleleAll		Se Deleta todos os Itens do Grid MDU
@author  Varejo
@version P11.8
@since   25/04/2012
@return  lRet				Retorna se deletou com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDDelReason( nItemLine , lDeleleAll ) 

Local	oModelGrid			:= NIL				// Componente Grid MDU
Local	aBusca				:= {}				// Array para busca do Item na MDU
Local 	lRet 				:= .T.				// Retorna se deletou
Local	nI					:= 0				// Contador

Default nItemLine		 	:= 0				// Codigo item	
Default lDeleleAll		 	:= .F.				// Indica se deleta todos os Itens

ParamType 0 Var nItemLine	AS Numeric		Default 0	
ParamType 1 Var lDeleleAll	AS Logical		Default .F.

// Caso nao tenha sido instanciado modelo Motivo de Desconto, Nao fazer nada   
If oModel <> NIL 

	oModelGrid := oModel:GetModel("MDU_GRID") 

	If lDeleleAll
		
		For nI := 1 To oModelGrid:Length()
		
			oModelGrid:GoLine( nI )
			
			If !( oModelGrid:IsDeleted() )

   				oModelGrid:DeleteLine()

			EndIf			
			
		Next nI
		 
	Else
	
		If nItemLine > 0				
			
			AAdd( aBusca, {"MDU_ITEM", nItemLine })	
		
			If oModelGrid:SeekLine( aBusca )
			 
				If !( oModelGrid:IsDeleted() )
				
					lRet := oModelGrid:DeleteLine()
					
				EndIf 
			
			EndIf
		
		EndIf
		
	EndIf

EndIf

Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} STDAddReason
Function Motivo de Desconto

@param	nItemLine			Linha do 	Item na Venda (Passar 99999 para Desconto no Total)
@param	cMotCode			Codigo do Motivo de Desconto	
@param	cObs				String obs (descrição do MDT + '-' + observação digitada)
@param	cType				Desconto no ITEM ou TOTAL
@param	cItemCode			Codigo do Item	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se adicionou no Grid
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDAddReason( nItemLine	, cMotCode , cObs ,	cItemCode , ;
						cType		, cCodSup	 )

Local 	oModel			:= STDRFDGetModel()				// Modelo do Motivo de Desconto (MDU)
Local	oModelGrid		:= oModel:GetModel("MDU_GRID")  // Componente Grid do Motivo de Desconto
Local	aBusca			:= {}							// array para busca do Item na MDU
Local	lFirstItem		:= .F.							// Indica se primeiro item
Local	lRet			:= .F.							// Retorna se adicionou motivo de desconto
Local	nLine			:= 0							// Quantidade de linhas do grid

Default nItemLine 		:= 0							// Linha do Item na Venda
Default cMotCode 		:= ""				   			// Codigo do Item
Default cObs 			:= ""			  				// Codigo do Cliente	
Default cItemCode 		:= ""		   					// Codigo da loja do Cliente
Default cType	 		:= ""		   					// Desconto no ITEM ou TOTAL
Default cCodSup			:= "" 							// Codigo do Supervisor que liberou o desconto

AAdd( aBusca , {"MDU_ITEM", nItemLine } )	

If oModelGrid:SeekLine( aBusca )
	STDDelReason( nItemLine )
EndIf 	

lFirstItem := ( oModelGrid:Length() == 1 ) .AND. Empty(oModelGrid:GetValue("MDU_CODIGO"))

If lFirstItem
	lRet := .T.
Else
	nLine := ( oModelGrid:Length() ) + 1		
	lRet  := oModelGrid:AddLine() == nLine
EndIf

If lRet
	
	oModelGrid:SetValue("MDU_FILIAL"	, xFilial("MDU")	)
	oModelGrid:SetValue("MDU_CODIGO"	, cMotCode			)
	oModelGrid:SetValue("MDU_OBS"		, cObs				)
	oModelGrid:SetValue("MDU_DATA"		, dDataBase	   		)
	oModelGrid:SetValue("MDU_TIPO"		, cType				)
	oModelGrid:SetValue("MDU_PRODUT"	, cItemCode			)
	oModelGrid:SetValue("MDU_SITUA"		, "00"				)
	oModelGrid:SetValue("MDU_OPERAD"	, xNumCaixa() 		)
	oModelGrid:SetValue("MDU_ITEM"		, nItemLine			) // OBS: Campo não existe fisicamente
	oModelGrid:SetValue("MDU_DOC"		, STDGPBasket("SL1" , "L1_DOC"		)	) 
	oModelGrid:SetValue("MDU_SERIE"		, STDGPBasket("SL1" , "L1_SERIE"	)	)	
	
	If oModelGrid:HasField("MDU_CODSUP")
		oModelGrid:SetValue("MDU_CODSUP"	, cCodSup	 		)
	EndIf

EndIf

Return  lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDAddSupD
Function Motivo de Desconto - Adiciona o codigo do supervisor que liberou o desconto

@param	nItemLine			Linha do 	Item na Venda (Passar 99999 para Desconto no Total)
@param	cMotCode			Codigo do Motivo de Desconto	
@param	cObs				String obs (descrição do MDT + '-' + observação digitada)
@param	cType				Desconto no ITEM ou TOTAL
@param	cItemCode			Codigo do Item	
@author  Varejo
@version P12.1.25
@since   07/05/2019
@return  lRet				Retorna se adicionou no Grid
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDAddSupD(nItemLine, cItemCode, cCodSup )

Local 	oModel			:= STDRFDGetModel()				// Modelo do Motivo de Desconto (MDU)
Local	oModelGrid		:= oModel:GetModel("MDU_GRID")  // Componente Grid do Motivo de Desconto
Local	aBusca			:= {}							// array para busca do Item na MDU

AAdd( aBusca , {"MDU_ITEM", nItemLine } )	

If oModelGrid:SeekLine( aBusca ) .AND. oModelGrid:HasField("MDU_CODSUP") 	
	oModelGrid:SetValue("MDU_CODSUP", cCodSup)
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpdReason
Função responsavel por atualizar alguns campos do model MDU_GRID 

@param	cDoc, Caracter, Documento que será atualizado
@param	cSerie, Caracter, Serie que será atualizada
@author  Lucas Novais (lnovais@)
@version P12
@since   15/09/2020
@return  Nulo, Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDUpdReason(cDoc,cSerie) 

Local	oModelGrid			:= NIL				// Componente Grid MDU
Local	nI					:= 0				// Contador

Default cDoc 		:= ""							
Default cSerie 		:= ""				   		

// Caso nao tenha sido instanciado modelo Motivo de Desconto, Nao fazer nada   
If oModel <> NIL 

	oModelGrid := oModel:GetModel("MDU_GRID") 
		
	For nI := 1 To oModelGrid:Length()
	
		oModelGrid:GoLine( nI )
		
		If !( oModelGrid:IsDeleted() )  .AND. !Empty(cDoc) .And. !Empty(cSerie)

			oModelGrid:SetValue("MDU_DOC" , cDoc ) 
			oModelGrid:SetValue("MDU_SERIE"	, cSerie )	

		EndIf			
		
	Next nI

EndIf

Return 
