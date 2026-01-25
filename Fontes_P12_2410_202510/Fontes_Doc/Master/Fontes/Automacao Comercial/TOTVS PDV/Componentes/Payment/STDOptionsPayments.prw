#include 'totvs.ch'
// Interface de array para ser enviada para o DAO
#DEFINE  TAMANHOPAY        	3 // 
#DEFINE  TIPO        		1 // Obrigatório
#DEFINE  DESCRICAO        	2 // Opcional
#DEFINE  CODIGO        		3 // Opcional

Function STDAOptionsPayments() ; Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STDAOptionsPayments
Classe opções de pagamento
@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Class STDAOptionsPayments

	Data oCache
	Data aOpc
	
	// Construtor
	Method STDAOptionsPayments(oCache) 

	// Publico
	Method GetAllData()
	Method Add(aOpc)	
	
	// Privado
	Method GetModel()
	Method CreateMasterStruct() 
	Method CreateGridStruct()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} STDAOptionsPayments
Metrodo creator
@param   oCache
@author  Varejo
@version P11.8
@since   23/05/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method STDAOptionsPayments(oCache) Class STDAOptionsPayments
	Self:oCache := oCache
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Cria e retorna o model
@param   oCache
@author  Varejo
@version P11.8
@since   23/05/2012
@return  oModel
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method GetModel() Class STDAOptionsPayments	

Local oMasterStr	:= 	Nil	// Estrutura SLQ
Local oGridStr 		:= 	Nil	// Estrutura SLR
Local oModel 		:= 	Nil	// Model  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta estrutura de tabela de cabecario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMasterStr := Self:CreateMasterStruct()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta estrura de tabela de Itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGridStr := Self:CreateGridStruct()
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instacia Objeto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel 	:= 	MPFormModel():New( "SE4", /*bPreValidacao*/, /*bPosValidacao*/, /*{ |oMdl| xFRT80MVCGR(oMdl)}*/, /*bCancel*/ )
	
oModel:AddFields( 	"MasterStr"    	, /*cOwner*/,  oMasterStr ) 
oModel:AddGrid(		"GridStr" 		, "MasterStr",  oGridStr, /*B*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation(	"GridStr" 		, { { "E4_FILIAL", 'xFilial( "SE4" )' }, { "E4_CODIGO", "E4_CODIGO" } }, "AE_FILIAL + E4_CODIGO" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Add
Atualiza propriedade aOpc
@param   aOpc
@author  Varejo
@version P11.8
@since   23/05/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method Add(aOpc) Class STDAOptionsPayments

AAdd(Self:aOpc, {})
// Executar Por aClone para não criar referencia
Self:aOpc[Len(Self:aOpc)] := AClone(aOpc)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAllData
Incluir informacoes no model
@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  oNewModel
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method GetAllData() Class STDAOptionsPayments

Local oNewModel		:= Nil				// Retorno do Model
Local nX 			:= 0				// Contador do Struct
Local cCampo		:= ""				// Campo da tabela que incluirá novo Registros
Local cCacheID		:= "STDAOptionsPayments_GetAllData" // Id de Cache
Local nLine			:= 0
Local lFirstLine	:= .T.				// Primeiro regisro incluso
	
If Self:oCache != Nil .And. Self:oCache:Contains( cCacheID ) 
	oNewModel := Self:oCache:Get( cCacheID )
EndIf
	
If oNewModel == Nil
		
	oNewModel := Self:GetModel()	// Chama a estrutura de dados
	
	oNewModel:SetOperation( 3 )
	oNewModel:SetDescription("Opcao de Pagamento")
	
	oNewModel:Activate()
	
		
	// Dados 
	oModelSlq := oNewModel:GetModel("MasterStr")
	oModelSlq:SetValue("OPP_FILIAL"	, xFilial("OPP"))
	oModelSlq:SetValue("OPP_CODIGO"	, SAE->AE_COD  )
			
	// Carrega todas as Opcoes na 1º Linha
	oModSlr := oNewModel:GetModel("GridStr")
		
	aTestStr := oModSlr:GetStruct()
		
	// Carrega todas as Adm
	For nX := 1 tO  Len(Self:aOpc)
			
		If !lFirstLine
			nLine := oModSlr:AddLine()
		EndIf
			
		oModSlr:SetValue("OPP_CODIGO"	, Self:aOpc[nX][CODIGO])
		oModSlr:SetValue("OPP_DESCRI"	, Self:aOpc[nX][DESCRICAO])
		oModSlr:SetValue("OPP_TIPO"		, Self:aOpc[nX][TIPO])
		
		lFirstLine := .F.

	Next nX
		
	ConOut("Não pegou do cache")
		
	If Self:oCache != Nil
		Self:oCache:Put( cCacheID, oNewModel, 60 )
	EndIf
Else
	ConOut("Pegou do cache")
EndIf

Return oNewModel

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateMasterStruct
Cria a estrutura do model master
@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  oStruct
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method CreateMasterStruct() Class STDAOptionsPayments

Local oStruct 	:= FWFormModelStruct():New()	// Estrutura
Local cAlias 	:= "SE4"						// Alias que criara estrutura													
Local cX2Unico  := "E4_FILIAL+E4_CODIGO" //X2_UNICO da tabela SE4

//Carrega informacoes da Tabela
SX2->( DbSetOrder( 1 ) )
SX2->( DbSeek( cAlias ) )

If ExistFunc('FWX2Unico') 
    cX2Unico := FWX2Unico(cAlias) 
EndIf
	
oStruct:AddTable( 					;
FWX2CHAVE()                		, 	;  	// [01] Alias da tabela
StrTokArr( cX2Unico, '+' ) 		, 	;  	// [02] Array com os campos que correspondem a primary key
FWX2Nome(cAlias) )                 					// [03] Descrição da tabela
     
oStruct:AddField(                           ;
                     "FILIAL"  		 	,	; // [01] Titulo do campo
                     "FILIAL"  		 	,	; // [02] Desc do campo
                     "OPP_FILIAL" 	 	,	; // [03] Id do Field
                     "C"              	,	; // [04] Tipo do campo
                     FWSizeFilial()   	,	; // [05] Tamanho do campo
                     0                	, 	; // [06] Decimal do campo
                     Nil             	,	; // [07] Code-block de validação do campo
                     Nil               	,	; // [08] Code-block de validação When do campo
                     Nil 				, 	; // [09] Lista de valores permitido do campo
                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigatório
                     Nil              	, 	; // [11] Code-block de inicializacao do campo
                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
                     NIL              	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
               		)             			  // [14] Indica se o campo é virtual
	
oStruct:AddField(                           ;
                     "CODIGO"  		 	,	; // [01] Titulo do campo
                     "CODIGO"  		 	,	; // [02] Desc do campo
                     "OPP_CODIGO" 	 		,	; // [03] Id do Field
                     "C"              	,	; // [04] Tipo do campo
                     TamSX3("E4_CODIGO")[1],	; // [05] Tamanho do campo
                     0                	, 	; // [06] Decimal do campo
                     Nil             	,	; // [07] Code-block de validação do campo
                     Nil               	,	; // [08] Code-block de validação When do campo
                     Nil 				, 	; // [09] Lista de valores permitido do campo
                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigatório
                     Nil              	, 	; // [11] Code-block de inicializacao do campo
                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
                     NIL              	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
               		 )             			  // [14] Indica se o campo é virtual

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} CreateGridStruct
Cria a estrutura do model grid
@param   
@author  Varejo
@version P11.8
@since   23/05/2012
@return  oStruct
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method CreateGridStruct() Class STDAOptionsPayments

Local oStruct 	:= FWFormModelStruct():New()	// Estrutura
Local nX		:= 0							// Contador
Local cValid	:= ''							// Validacao para o bValid
Local bValid	:= {}							// Validades ção X3
Local bWhen		:= {}							// Em quanto do x3
Local bRelac	:= {}							// Relacao do x3
Local cAlias 	:= "SE4"						// Alias que criara estrutura													
Local cX2Unico  := "E4_FILIAL+E4_CODIGO" //X2_UNICO da tabela SE4
	
//Carrega informacoes da Tabela
SX2->( DbSetOrder( 1 ) )
SX2->( DbSeek( cAlias ) )

If ExistFunc('FWX2Unico') 
    cX2Unico := FWX2Unico(cAlias) 
EndIf
	
oStruct:AddTable( 					;
FWX2CHAVE()                		, 	;  	// [01] Alias da tabela
StrTokArr( cX2Unico, '+' ) 		, 	;  	// [02] Array com os campos que correspondem a primary key
FWX2Nome(cAlias) )                 					// [03] Descrição da tabela
	
//Carrega informacoes de campos
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek("SE4"))
	

oStruct:AddField(                           ;
                     "CODIGO"  		 	,	; // [01] Titulo do campo
                     "CODIGO"  		 	,	; // [02] Desc do campo
                     "OPP_CODIGO" 	 		,	; // [03] Id do Field
                     "C"              	,	; // [04] Tipo do campo
                     TamSX3("E4_CODIGO")[1],	; // [05] Tamanho do campo
                     0                	, 	; // [06] Decimal do campo
                     Nil             	,	; // [07] Code-block de validação do campo
                     Nil               	,	; // [08] Code-block de validação When do campo
                     Nil 				, 	; // [09] Lista de valores permitido do campo
                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigatório
                     Nil              	, 	; // [11] Code-block de inicializacao do campo
                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
                     NIL              	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
               		 )             			  // [14] Indica se o campo é virtual

oStruct:AddField(                           ;
                     "DESCRICAO"  		 	,	; // [01] Titulo do campo
                     "DESCRICAO"  		 	,	; // [02] Desc do campo
                     "OPP_DESCRI" 	 		,	; // [03] Id do Field
                     "C"              		,	; // [04] Tipo do campo
                     TamSX3("E4_DESCRI")[1],	; // [05] Tamanho do campo
                     0                		, 	; // [06] Decimal do campo
                     Nil             		,	; // [07] Code-block de validação do campo
                     Nil               		,	; // [08] Code-block de validação When do campo
                     Nil 					, 	; // [09] Lista de valores permitido do campo
                     Nil 					, 	; // [10] Indica se o campo tem preenchimento obrigatório
                     Nil              		, 	; // [11] Code-block de inicializacao do campo
                     NIL             		, 	; // [12] Indica se trata-se de um campo chave
                     NIL              		,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
               		 )             			  // [14] Indica se o campo é virtual


oStruct:AddField(                           ;
                     "TIPO"  		 	,	; // [01] Titulo do campo
                     "TIPO"  		 	,	; // [02] Desc do campo
                     "OPP_TIPO" 	 		,	; // [03] Id do Field
                     "C"              	,	; // [04] Tipo do campo
                     2,	; // [05] Tamanho do campo
                     0                	, 	; // [06] Decimal do campo
                     Nil             	,	; // [07] Code-block de validação do campo
                     Nil               	,	; // [08] Code-block de validação When do campo
                     Nil 				, 	; // [09] Lista de valores permitido do campo
                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigatório
                     Nil              	, 	; // [11] Code-block de inicializacao do campo
                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
                     NIL              	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
               		 )             			  // [14] Indica se o campo é virtual

Return oStruct