#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"  
#INCLUDE "STDNEXTSALEDISCOUNT.CH" 

Static	oModel 		:= Nil			// Model 
Static 	oStructNSD	:= Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRFDGetModel
Function Cria estrutura de dados do Model

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  oModel					Retorna estrutura de dados do Model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDNSDGetModel() 	

Local oMasterStr 		:= 	Nil			// Estrutura Master 
    
If 	oModel == 	Nil

	oMasterStr := CreateMasterStruct()

	oGridStr := CreateGridStruct()		

	oModel := MPFormModel():New( 'NSD' )
	
	oModel:AddFields( "NSD_MASTER" , , oMasterStr )
	 
	oModel:AddGrid(	"NSD_GRID" 		,	"NSD_MASTER"		, oGridStr )
					
	oModel:SetRelation( "NSD_GRID" , { { "ITEM" }	, { "ITEM" } } , "ITEM" )
	
 	oModel:SetPrimaryKey( { "ITEM" } )
	
	oModel:GetModel( "NSD_GRID" ):SetOptional( .T. ) 
	
	oModel:SetOperation( 3 )
	
	oModel:Activate()
	
EndIf
	 	
Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateMasterStruct
Function Cria estrutura do Model Master

@param   
@author  Varejo
@version P11.8
@since   25/04/2012
@return  oStruct			Retorna estrutura do Model Master
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function CreateMasterStruct() 
    
If ValType(oStructNSD) = 'O'
	oStructNSD:Deactivate()
	oStructNSD:Activate()
Else               
	oStructNSD := FWFormModelStruct():New()	// Estrutura													
	 
	oStructNSD:AddTable( 						 		;
						"NSD"  					, 	;  	// [01] Alias da tabela
						{"ITEMLINE"}	   		, 	;  	// [02] Array com os campos que correspondem a primary key
						"NEXT SALE DISCOUNT"   		)	// [03] Descrição da tabela    
	
	oStructNSD:AddField(                           	;
	                     "ITEM"  			 	,	; // [01] Titulo do campo
	                     "ITEM"  	 		 	,	; // [02] Desc do campo
	                     "ITEM"					,	; // [03] Id do Field
	                     "N"              		,	; // [04] Tipo do campo
	                     TamSX3("L2_ITEM")[1]	,	; // [05] Tamanho do campo
	                     0						, 	; // [06] Decimal do campo
	                     Nil             		,	; // [07] Code-block de validacao do campo
	                     Nil               		,	; // [08] Code-block de validacao When do campo
	                     Nil 					, 	; // [09] Lista de valores permitido do campo
	                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
	                     Nil              		, 	; // [11] Code-block de inicializacao do campo
	                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
	                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
	               		 					   		) // [14] Indica se o campo e virtual
EndIf
		
Return oStructNSD

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateGridStruct
Function Cria estrutura do Model Grid

@param   
@author  Varejo
@version P11.8
@since   25/04/2012
@return  oStruct		Retorna estrutura do Model Grid
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function CreateGridStruct() 

Local	aArea		:= GetArea()		// Armazena alias corrente
Local oStruct 	:= FWFormModelStruct():New()		// Estrutura
Local aFields	:= {}								// Campos
Local nI		:= 0 								// Contador
 
oStruct:AddTable( 								;	
					"NSD"		           	, 	;  	// [01] Alias da tabela
					{"ITEMLINE"}			, 	;  	// [02] Array com os campos que correspondem a primary key
					"NEXT SALE DISCOUNT"		)	// [03] Descrição da tabela    

AADD( aFields , { "ITEMLINE"	,	"ITEMLINE"	,	"ITEMLINE"	,	"N"	,	TamSX3("L2_ITEM")[1]	,	0							,,,,,,,,	} )							
AADD( aFields , { "TYPE"   		,	"TYPE"		,	"TYPE"		,	"C"	,	1						,	  							,,,,,,,, 	} )						
AADD( aFields , { "ITEMCODE"	,	"ITEMCODE"	,	"ITEMCODE"	,	"C"	,	TamSX3("L2_PRODUTO")[1]	,	0  							,,,,,,,,	} )						
AADD( aFields , { "VALUE"		,	"VALUE"		,	"VALUE"		,	"N"	,	TamSX3("L2_VLRITEM")[1]	,	TamSX3("L2_VLRITEM")[2]		,,,,,,,,	} )						
AADD( aFields , { "DISCOUNT"	,	"DISCOUNT"	,	"DISCOUNT"	,	"N"	,	TamSX3("L2_VALDESC")[1]	,	TamSX3("L2_VALDESC")[2]		,,,,,,,,	} )						
AADD( aFields , { "DATE"		,	"DATE" 		,	"DATE"		,	"D"	,	8  						,								,,,,,,,,	} )						

For nI := 1 To Len(aFields)

  	oStruct:AddField(                             			      		;
	                     aFields[nI][1]			       		  	,	; 	// [01] Titulo do campo
	                     aFields[nI][2]			         			,	; 	// [02] ToolTip do campo
	                     aFields[nI][3]        	  					,	; 	// [03] Id do Field
	                     aFields[nI][4]                		  	,	; 	// [04] Tipo do campo
	                     aFields[nI][5]            	 		  		,	; 	// [05] Tamanho do campo
	                     aFields[nI][6]            		   			,	; 	// [06] Decimal do campo
	                     Nil                         				,	; 	// [07] Code-block de validacaoo do campo
	                     Nil                          			,	; 	// [08] Code-block de validacaoo When do campo
	                     Nil								  				, 	; 	// [09] Lista de valores permitido do campo
	                     Nil 											,	; 	// [10] Indica se o campo tem preenchimento obrigatorio
	                     Nil                         				, 	; 	// [11] Code-block de inicializacao do campo
	                     NIL                            			, 	; 	// [12] Indica se trata-se de um campo chave
	                     NIL                            			, 	; 	// [13] Indica se o campo pode receber valor em uma operacao de update.
	                     NIL						     					)      	// [14] Indica se o campo e virtual
	 
	SX3->(DbSkip()) 
	
Next nI 

RestArea(aArea)

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} STDNxtSalAdd
Function Adiciona Informações do Desconto na Próxima Venda no model

@param	cType				Tipo. I - Item , T - Total
@param	nItemLine			Linha do Item	
@param	cItemCode			Código do Produto
@param	nValue				Valor
@param	nDiscount			Valor do Desconto	
@param	dEndDate			Data de Validade	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet				Retorna se adicionou no Grid do Model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDNxtSalAdd( 	cType 	  	, 	nItemLine   ,		cItemCode		,		nValue 			, ;
							nDiscount	,	dEndDate	)
												
Local 	oModel		   		:= STDNSDGetModel()				// Modelo do Motivo de Desconto (NSD)
Local	oModelGrid	  		:= oModel:GetModel("NSD_GRID")	// Componente Grid do Motivo de Desconto
Local	nLine				:= 0							// Armazena linha do Model
Local	lFirstItem	  		:= .F.							// Indica se primeiro item
Local	lRet		 		:= .F.							// Retorna se adicionou Desconto na Proxima Venda

Default cType 	   			:= ""
Default nItemLine 	 		:= 0
Default cItemCode 			:= ""
Default nValue 	   			:= 0
Default nDiscount	 		:= 0
Default dEndDate	 			:= CToD("")
	
ParamType 0 Var cType			AS Character	Default ""
ParamType 1 Var nItemLine 		AS Numeric		Default 0
ParamType 2 Var cItemCode	 	AS Character	Default ""  
ParamType 3 Var nValue 			AS Numeric		Default 0
ParamType 4 Var nDiscount	 	AS Numeric		Default 0
ParamType 5 Var dEndDate	 	AS Date			Default cToD("")

lFirstItem := ( oModelGrid:Length() == 1 ) .AND. Empty(oModelGrid:GetValue("DISCOUNT"))

If lFirstItem
	lRet := .T.
Else	
	nLine := ( oModelGrid:Length() )		
	lRet  := oModelGrid:AddLine() == ( nLine + 1 )
EndIf

If lRet 
		                                                     
	oModelGrid:SetValue(	"ITEMLINE"	,	nItemLine		)
 	oModelGrid:SetValue(	"TYPE"		,	cType			)		
   	oModelGrid:SetValue(	"ITEMCODE"	,	cItemCode		)
   	oModelGrid:SetValue(	"VALUE"	,	nValue	  		)
	oModelGrid:SetValue(	"DISCOUNT"	,	nDiscount		)		
	oModelGrid:SetValue(	"DATE"		,	dEndDate		)
     
EndIf

Return  lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecNextSaleDiscount
Gera NCC dos descontos na próxima venda

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecNextSaleDiscount()

Local	oModelGrid			:= NIL				// Componente Grid
Local	aArea				:= GetArea()		// Armazena alias corrente
Local	nI					:= 0 				// Contador
Local	nTotalNCC			:= 0				// Valor total da NCC a ser gerada
Local	lExecNow			:= .F.				// Define se executou agora ou foi pra contingência

If oModel <> NIL 

	oModelGrid 	:= oModel:GetModel("NSD_GRID") 	
	
	For nI := 1 To oModelGrid:Length()
		
		oModelGrid:GoLine(nI)
			
		nTotalNCC += oModelGrid:GetValue("DISCOUNT")	       
	
	Next nI
    
	STBRemoteExecute(	"LJGerTitNV"	, ;
				   		{				  								 	 ;
										STDGPBasket("SL1","L1_DOC")		, ;
			   							STDGPBasket("SL1","L1_SERIE")	, ;
										STDGPBasket("SL1","L1_OPERADO")	, ;
										oModelGrid:GetValue("DATE")		, ;
			   							nTotalNCC 							, ;
										STDGPBasket("SL1","L1_CLIENTE")	, ;
										STDGPBasket("SL1","L1_LOJA")	, ;
										STFGetStat("LG_SERIE")			, ;
										dDataBase							, ;
						}													, ;
						NIL				, ;
						.T.				, ;
						@lExecNow 		, ;			
						"TRYEXEC"		  )     	
									
	If !lExecNow										
		STFMessage("STNextSaleDiscount","ALERT", STR0001) //"Sem conexão. A NCC será gerada quando a conexão for reestabelecida"
		STFShowMessage("STNextSaleDiscount")
	EndIf
	
EndIf

RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} STDNSDFree
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
Function STDNSDFree()

If oModel <> Nil
	FreeObj(oModel)	
EndIf

Return Nil

