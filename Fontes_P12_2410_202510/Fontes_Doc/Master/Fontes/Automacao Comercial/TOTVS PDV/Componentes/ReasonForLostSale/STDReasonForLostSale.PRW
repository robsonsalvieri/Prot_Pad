#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "STDREASONFORLOSTSALE.CH"

Static 		oModel 	:= 	Nil			// Model 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRFDGetModel
Cria estrutura de dados do Model

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  oModel			Retorna estrutura de dados do Model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDRLSGetModel() 	

Local oMasterStr 		:= Nil			// Estrutura Master 
Local oGridStr			:= Nil			// Estrutura Grid
    
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
	oModel := MPFormModel():New( 'MBR' ) 	
	
	oModel:AddFields( "MBR_MASTER" , Nil , oMasterStr )
	 
	oModel:AddGrid(	"MBR_GRID" 		,	"MBR_MASTER"		, oGridStr 	)
					
	oModel:SetRelation( "MBR_GRID" , { { "MBR_FILIAL", 'xFilial( "MBR" )' }	, { "MBR_ITEM", "MBR_ITEM" } } , 'MBR_FILIAL + MBR_ITEM' )
	
	oModel:SetPrimaryKey( { "MBR_FILIAL" , "MBR_ITEM" } )  
	
	oModel:GetModel( "MBR_GRID" ):SetOptional( .T. ) 
	
	oModel:SetOperation( 3 )
	
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
@return  oStruct			Retorna estrutura do Model Master
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function CreateMasterStruct() 
    
Local oStruct 		:= FWFormModelStruct():New()	// Estrutura	
Local cX2Unico  	:= "MBR_FILIAL+MBR_MOTIVO+MBR_CODIGO+MBR_NUMORC+MBR_DOC+MBR_SERIE+MBR_PROD+MBR_ITEM+MBR_PDV" //X2_UNICO da tabela MBR

If ExistFunc('FWX2Unico') 
	cX2Unico := FWX2Unico("MBR") 
EndIf

oStruct:AddTable( 								;
FWX2CHAVE()                				, 	;  	// [01] Alias da tabela
StrTokArr( cX2Unico, '+' 	) 		, 	;  	// [02] Array com os campos que correspondem a primary key
FWX2Nome("MBR") 								)			// [03] Descricao da tabela
     
oStruct:AddField(                           	;
                     STR0001  		   		,	; // [01] Titulo do campo
                     STR0001  		   		,	; // [02] Desc do campo
                     "MBR_FILIAL" 	 		,	; // [03] Id do Field
                     "C"              	,	; // [04] Tipo do campo
                     FWSizeFilial()   		,	; // [05] Tamanho do campo
                     0                	, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil               	,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              	, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL             		,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               									)	  // [14] Indica se o campo e virtual

oStruct:AddField(                           	;
                     STR0002  			 	,	; // [01] Titulo do campo
                     STR0002  	 		 	,	; // [02] Desc do campo
                     "MBR_ITEM"				,	; // [03] Id do Field
                     "C"              	,	; // [04] Tipo do campo
                     TamSX3("MBR_ITEM")[1],	; // [05] Tamanho do campo
                     0                	, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validacao do campo
                     Nil               	,	; // [08] Code-block de validacao When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatorio
                     Nil              	, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              	,  	; // [13] Indica se o campo pode receber valor em uma operacao de update.
               		 							)	  // [14] Indica se o campo e virtual
	
Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateGridStruct
Cria estrutura do Model Grid

@param   
@author  Varejo
@version P11.8
@since   25/04/2012
@return  oStruct			Retorna estrutura do Model Grid
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function CreateGridStruct() 

Local oStruct 	:= FWFormModelStruct():New()		// Estrutura
Local cX2Unico 	:= "MBR_FILIAL+MBR_MOTIVO+MBR_CODIGO+MBR_NUMORC+MBR_DOC+MBR_SERIE+MBR_PROD+MBR_ITEM+MBR_PDV" //X2_UNICO da tabela MBR

If ExistFunc('FWX2Unico') 
	cX2Unico := FWX2Unico("MBR") 
EndIf

oStruct:AddTable( 								;
FWX2CHAVE()                				, 	;  	// [01] Alias da tabela
StrTokArr( cX2Unico, '+' ) 	   		, 	;  	// [02] Array com os campos que correspondem a primary key
FWX2Nome("MBR") 									)		// [03] Descrição da tabela

//Carrega informacoes de campos
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek("MBR"))

While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == "MBR"

  	oStruct:AddField(                             			      		;
	                     AllTrim( X3Titulo()  )        		  		,	; 	// [01] Titulo do campo
	                     AllTrim( X3Descric() )         			,	; 	// [02] ToolTip do campo
	                     AllTrim( SX3->X3_CAMPO )         	  		,	; 	// [03] Id do Field
	                     SX3->X3_TIPO                  		  		,	; 	// [04] Tipo do campo
	                     SX3->X3_TAMANHO               		  		,	; 	// [05] Tamanho do campo
	                     SX3->X3_DECIMAL                			,	; 	// [06] Decimal do campo
	                     Nil                         				,	; 	// [07] Code-block de validacaoo do campo
	                     Nil                          			,	; 	// [08] Code-block de validacaoo When do campo
	                     StrTokArr( AllTrim( X3CBox() ),';')  	, 	; 	// [09] Lista de valores permitido do campo
	                     Nil 											,	; 	// [10] Indica se o campo tem preenchimento obrigatorio
	                     Nil                         				, 	; 	// [11] Code-block de inicializacao do campo
	                     NIL                            			, 	; 	// [12] Indica se trata-se de um campo chave
	                     NIL                            			, 	; 	// [13] Indica se o campo pode receber valor em uma operacao de update.
	                     ( SX3->X3_CONTEXT == 'V' )     				)     	// [14] Indica se o campo e virtual
	 	
	SX3->(DbSkip()) 
	
EndDo 
	
Return oStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} STDAddReason
Function Motivo de Desconto

@param	nItemLine		Linha do Item na Venda
@param	cItemCod		Codigo do Item	
@param	nAmount			Quantidade
@param	cCodCli			Código do Cliente
@param	cStoreCli		Loja do Cliente
@param	cSeller	  		Codigo do Vendedor
@param	dDate			Data
@param	cCodReason		Codigo do Motivo de Venda Perdida
@param	cJustify		String contendo justificativa de perda 
@param	cL1_Num		caractere, valor do campo SL2->L2_NUM 
@param	cL1_Serie	caractere, valor do campo SL2->L2_SERIE 
@param	cL1_Doc		caractere, valor do campo SL2->L2_DOC

@author  Varejo
@version P11.8
@since   29/03/2012
@return  lRet			Retorna se adicionou no Grid
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDAddLostSale(	nItemLine	, cItemCod 	, nAmount	, cCodCli 		, ;
		 					cStoreCli	, cSeller	, dDate		, cCodReason	, ;
							cJustify	, cL1_Num	, cL1_Serie	, cL1_Doc		)

Local	oModelGrid		:= Nil							// Componente Grid do Motivo de Venda Perdida
Local	aBusca			:= {}							// array para busca do Item na MBR
Local	lFirstItem		:= .F.							// Indica se primeiro item
Local	lRet			:= .F.							// Retorna se adicionou motivo de desconto
Local	nLine			:= 0							// Quantidade de linhas do grid

Default nItemLine 	 	:= 0						
Default cItemCod 		:= ""				 
Default nAmount 		:= 1			  	
Default cCodCli 		:= ""		   		
Default cStoreCli		:= ""		   		
Default cSeller 		:= ""		   					
Default dDate 	  		:= CToD("")		   			
Default cCodReason 		:= ""		   		
Default cJustify 		:= ""		   							
Default cL1_Num			:= "" 
Default cL1_Serie		:= ""
Default cL1_Doc			:= ""

ParamType 0 Var nItemLine	AS Numeric		Default 0
ParamType 1 Var cItemCod 	AS Character	Default ""
ParamType 2 Var nAmount	 	AS Numeric		Default 1  
ParamType 3 Var cCodCli 	AS Character	Default ""
ParamType 4 Var cStoreCli 	AS Character	Default ""
ParamType 5 Var cSeller 	AS Character	Default ""
ParamType 6 Var dDate  		AS Date			Default CToD("")
ParamType 7 Var cCodReason 	AS Character	Default ""
ParamType 8 Var cJustify 	AS Character	Default ""
ParamType 9 Var cL1_Num		AS Character	Default ""
ParamType 10 Var cL1_Serie	AS Character	Default ""
ParamType 11 Var cL1_Doc	AS Character	Default ""


If oModel == Nil
	STDRLSGetModel() // Cria o Model
EndIf

oModelGrid := oModel:GetModel("MBR_GRID")

AAdd( aBusca, {"MBR_ITEM", CValToChar(nItemLine) })	

If oModelGrid:SeekLine( aBusca )
	If !( oModelGrid:IsDeleted() )		
		oModelGrid:DeleteLine()			
	EndIf
EndIf 	

lFirstItem := ( oModelGrid:Length() == 1 ) .AND. Empty(oModelGrid:GetValue("MBR_ITEM"))

If lFirstItem
	lRet := .T.
Else
	nLine := ( oModelGrid:Length() ) + 1		
	lRet  := oModelGrid:AddLine() == nLine
EndIf

If lRet

	oModelGrid:SetValue(	"MBR_FILIAL"	, xFilial("MBR")														)
	oModelGrid:SetValue(	"MBR_CODIGO"	, GetSxENum("MBR","MBR_CODIGO"	)										)
	oModelGrid:SetValue(	"MBR_ITEM"		, CValToChar(nItemLine)													)
	oModelGrid:SetValue(	"MBR_PROD"		, cItemCod																)		
	oModelGrid:SetValue(	"MBR_QUANT"		, nAmount				   												)		
	oModelGrid:SetValue(	"MBR_CODCLI"	, cCodCli				   												)		
	oModelGrid:SetValue(	"MBR_VEND"		, cSeller																)
	oModelGrid:SetValue(	"MBR_LOJA"		, cStoreCli																)		
	oModelGrid:SetValue(	"MBR_MOTIVO"	, cCodReason			   												)		
	oModelGrid:SetValue(	"MBR_EMISSA"	, dDate				   													) 
	oModelGrid:SetValue(	"MBR_SITUA"		, "00"				   													) 
	oModelGrid:SetValue(	"MBR_ORIGEM"	, "POS"				   													) 
	oModelGrid:SetValue(	"MBR_PDV"		, STFGetStation("PDV")													) 
	oModelGrid:SetValue(	"MBR_ESTACA"	, STFGetStation("CODIGO")												) 
	oModelGrid:SetValue(	"MBR_NUMORC"	, Iif(!Empty(cL1_Num)	, cL1_Num	, STDGPBasket("SL1","L1_NUM"	))	) 
	oModelGrid:SetValue(	"MBR_DOC"		, Iif(!Empty(cL1_Doc)	, cL1_Doc	, STDGPBasket("SL1","L1_DOC"	))	) 
	oModelGrid:SetValue(	"MBR_SERIE"		, Iif(!Empty(cL1_Serie)	, cL1_Serie	, STDGPBasket("SL1","L1_SERIE"	))	)
	oModelGrid:SetValue(	"MBR_JUSTIF"	, cJustify																) 

	
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRLSFree
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
Function STDRLSFree()

If oModel <> Nil
	FreeObj(oModel)	
EndIf

Return Nil


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
Function STDRFLSGet()

Local aReasons	:= {}				// Retorno funcao
Local aArea		:= GetArea()		// Armazena area corrente

DbSelectArea("MBQ")
DbSetOrder(1) // MDT_FILIAL + MDT_CODIGO
//MBQ->(DbGoTop()) //TODO
If MBQ->(DbSeek( xFilial("MBQ") )) // Busca aproximada
	While !EOF() .AND. xFilial("MBQ") == MBQ->MBQ_FILIAL 
		AADD( aReasons , { MBQ->MBQ_CODVEP , MBQ->MBQ_DSCVEP } ) 
		MBQ->(DbSkip())
	EndDo
EndIf

RestArea(aArea)

Return(aReasons)


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecLostSale
Grava Motivos de Venda Perdida

@author  Varejo
@version P11.8
@since   25/04/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecLostSale() 

Local	oModelGrid			:= NIL				// Componente Grid MBR
Local	aArea				:= GetArea()		// Armazena alias corrente
Local	nI					:= 0 				// Contador
Local 	nJ					:= 0				// Contador
Local	aStruct			:= {}				// Armazena estrutura de dados do modelo

If oModel <> NIL 

	oModelGrid 	:= oModel:GetModel("MBR_GRID") 
	aStruct		:= oModelGrid:GetStruct():aFields
	
	DbSelectArea("MBR")

	For nI := 1 To oModelGrid:Length()  
	
		RecLock("MBR",.T.)
	   		
	   		oModelGrid:GoLine(nI)
	   		
	   		For nJ := 1 To Len(aStruct)	        	
				REPLACE MBR->&(aStruct[nJ][3]) WITH oModelGrid:GetValue(aStruct[nJ][3])		
			Next nJ	
			
		MsUnlock()
		
		STFSLICreate(	Nil		, "UP"		   		, "UP"		, "NOVO"		, ;
						Nil	    , Nil				, Nil		, Nil			, ;
						"MBR"	, MBR->(RecNo())	, Nil 			   			)
								
	Next nI
	
EndIf

RestArea(aArea)

Return Nil


