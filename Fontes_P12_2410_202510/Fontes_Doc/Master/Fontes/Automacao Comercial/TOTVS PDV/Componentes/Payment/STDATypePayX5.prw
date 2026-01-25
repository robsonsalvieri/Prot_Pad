#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static oStructSX5 := Nil

//-------------------------------------------------------------------
//STDTTypePayX5 function dumb
//-------------------------------------------------------------------
Function STDTTypePayX5() ; Return


//-------------------------------------------------------------------
// Declaracao da class
//-------------------------------------------------------------------
Class STDTTypePayX5
	
Data oCache

// Construtor
Method STDTTypePayX5(oCache) 

// Publico
Method GetAllData()

// Privado
Method GetModel()
Method CreateStruct() 

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} STDTTypePayX5
Metodo Construtor 
@param 
@author  Varejo
@version P11.8
@since   13/07/2012
@return  Self
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method STDTTypePayX5(oCache) Class STDTTypePayX5
Self:oCache := oCache
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Pega o model  de pagamentos SX5
@param 
@author  Varejo
@version P11.8
@since   13/07/2012
@return  oModel - Retorna o Model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method GetModel() Class STDTTypePayX5	

Local oMasterStr		:= 	Nil	// Estrutura SLQ
Local oGridStr 		:= 	Nil	// Estrutura SLR
Local oModel 			:= 	Nil	// Model  
Local aTabela  		:= {}	// Informacoes da tabela
Local oNewModel		:= Nil	// Modelo preenchido retornado

//Monta estrutura de tabela de cabecario
oMasterStr 	:= Self:CreateStruct()
oGridStr 	:= Self:CreateStruct()

//Instacia Objeto
oModel 	:= 	MPFormModel():New( "X524", /*bPreValidacao*/, /*bPosValidacao*/, /*{ |oMdl| xFRT80MVCGR( oMdl ) }*/, /*bCancel*/ )

oModel:AddFields( "MasterStr"    	, /*cOwner*/,  oMasterStr ) 
oModel:AddGrid("GridStr" 	, "MasterStr",  oGridStr, /*B*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation("GridStr" 	, { { "X5_NUM", 'X5_NUM' }, { "X5_NUM", "X5_NUM" } }, "X5_NUM + X5_NUM" )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} GetAllData
pega model
@param 
@author  Varejo
@version P11.8
@since   13/07/2012
@return  oNewModel 	retorno Model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method GetAllData() Class STDTTypePayX5

Local oNewModel		:= Nil				// Retorno do Model
Local nLine			:= 0				// Numero de linha do Grid
Local lFirstLine	:= .T.				// Primeiro regisro incluso
Local cNum			:= "001"			// Numero de cada Registro
Local aRetSx5 		:= {}				// Array com retorno de registros da SX5 tabela 24
Local nCont			:= 0				// contador de registros

oNewModel := Self:GetModel()	// Chama a estrutura de dados

oNewModel:SetOperation( 3 )
oNewModel:SetDescription("Condição de Pagamento")

oNewModel:Activate()

// Dados 
oModelMarte := oNewModel:GetModel("MasterStr")

aRetSx5 := FWGetSX5('24')

If Len(aRetSx5) > 0

	oModelMarte:SetValue("X5_NUM"	, 	cNum)
	oModelMarte:SetValue("X5_TYPE"	, 	Alltrim(aRetSx5[1][3]))
	oModelMarte:SetValue("X5_DESC"	, 	Left(Alltrim(aRetSx5[1][4]),30)) 
			
	//Carrega todas as Adm na 1º Linha
	oModSlr := oNewModel:GetModel("GridStr")

	For nCont:= 1 to Len(aRetSx5) 

		If !lFirstLine
			nLine := oModSlr:AddLine()
		EndIf
		
		oModSlr:SetValue("X5_NUM"	, 	cNum)
		oModSlr:SetValue("X5_TYPE"	, 	Alltrim(aRetSx5[nCont][3]))
		oModSlr:SetValue("X5_DESC"	, 	Left(Alltrim(aRetSx5[nCont][4]),30)) 

		lFirstLine := .F.

	Next

Endif 

Return oNewModel


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateStruct
Cria strutura 
@param 
@author  Varejo
@version P11.8
@since   13/07/2012
@return  oStruct 	retorna struct
@obs     
@sample
/*/
//-------------------------------------------------------------------
Method CreateStruct() Class STDTTypePayX5
	
	Local cAlias 	:= "SX5"								// Alias que criara estrutura													

	If ValType(oStructSX5) = 'O'
		oStructSX5:Deactivate()
		oStructSX5:Activate()
	Else
		
		oStructSX5 	:= FWFormModelStruct():New()	// Estrutura
		
		oStructSX5:AddTable( 								;
						"SX5"                						, 	;  	// [01] Alias da tabela
						StrTokArr( "X5_TYPE", '+' ) 								, ; // [02] Array com os campos que correspondem a primary key
						"TypePay" )                 						// [03] Descrição da tabela
					     
		oStructSX5:AddField(                      	   ;
		                     "NUM"  		 		,	; // [01] Titulo do campo
		                     "NUM"  		 		,	; // [02] Desc do campo
		                     "X5_NUM" 	 		,	; // [03] Id do Field
		                     "C"             	,	; // [04] Tipo do campo
		                     3   				,	; // [05] Tamanho do campo
		                     0               	, 	; // [06] Decimal do campo
		                     Nil             	,	; // [07] Code-block de validação do campo
		                     Nil             	,	; // [08] Code-block de validação When do campo
		                     Nil 				, 	; // [09] Lista de valores permitido do campo
		                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigatório
		                     Nil             	, 	; // [11] Code-block de inicializacao do campo
		                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
		                     NIL             	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
		               		)             			  // [14] Indica se o campo é virtual
		
		oStructSX5:AddField(                      		;
		                     "TYPE"  		 	,	; // [01] Titulo do campo
		                     "TYPE"  		 	,	; // [02] Desc do campo
		                     "X5_TYPE" 	 		,	; // [03] Id do Field
		                     "C"             	,	; // [04] Tipo do campo
		                     3					,	; // [05] Tamanho do campo
		                     0               	, 	; // [06] Decimal do campo
		                     Nil             	,	; // [07] Code-block de validação do campo
		                     Nil             	,	; // [08] Code-block de validação When do campo
		                     Nil 				, 	; // [09] Lista de valores permitido do campo
		                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigatório
		                     Nil             	, 	; // [11] Code-block de inicializacao do campo
		                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
		                     NIL             	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
		               		 )             			  // [14] Indica se o campo é virtual
	
		oStructSX5:AddField(                      	   ;
		                     "DESCRICAO"  		,	; // [01] Titulo do campo
		                     "DESCRICAO"  		,	; // [02] Desc do campo
		                     "X5_DESC" 	 		,	; // [03] Id do Field
		                     "C"             	,	; // [04] Tipo do campo
		                     30					,	; // [05] Tamanho do campo
		                     0               	, 	; // [06] Decimal do campo
		                     Nil             	,	; // [07] Code-block de validação do campo
		                     Nil             	,	; // [08] Code-block de validação When do campo
		                     Nil 				, 	; // [09] Lista de valores permitido do campo
		                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigatório
		                     Nil             	, 	; // [11] Code-block de inicializacao do campo
		                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
		                     NIL             	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
		               		 )             			  // [14] Indica se o campo é virtual
	EndIf
		
Return oStructSX5
