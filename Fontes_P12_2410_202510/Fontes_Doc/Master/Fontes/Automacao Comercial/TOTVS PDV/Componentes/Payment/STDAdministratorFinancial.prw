#include 'PROTHEUS.CH'   
#Include "FWMVCDEF.CH"
#INCLUDE "STDADMINISTRATORFINANCIAL.CH"

Static oStructSAE := Nil
Static oModelAdmF := Nil

Function STDAAdministratorFinancial ; Return  	// "dummy" function - Internal Use

//--------------------------------------------------------------------
/*/{Protheus.doc} STDTAdministratorFinancial
Classe STDTAdministratorFinancial, que cria model baseado no Alias SAE
@param   
@return  Self
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@todo	
@obs   
/*/
//--------------------------------------------------------------------
Class STDAAdministratorFinancial

Data oCache
	
// Construtor

Method 	STDAAdministratorFinancial(oCache) 
// Publico
Method GetAllData()
	
// Privado
Method GetModel()
Method CreateMasterStruct() 
Method CreateGridStruct()
Method CreateDetGridStruct()

EndClass

//--------------------------------------------------------------------
/*/{Protheus.doc} STDTAdministratorFinancial
Metodo construtor da classe STDTAdministratorFinancial
@param   oCache componente para realizar cache
@return  Self
@author  Verejo
@since   24/04/2012
@version P11.8
@see	
@todo	
@obs   
/*/
//--------------------------------------------------------------------
Method STDAAdministratorFinancial(oCache) Class STDAAdministratorFinancial
Self:oCache := oCache
Return Self

//--------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Cria e retorna estrutura de dados do Model
@param   
@return  Self
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@todo	
@obs   
/*/
//--------------------------------------------------------------------
Method GetModel() Class STDAAdministratorFinancial	
Local oMasterStr 	:= 	Nil	// Estrutura SLQ
Local oGridStr 		:= 	Nil	// Estrutura SLR
Local oModel 		:= 	Nil	// Model  
Local oGridDetStr	:= Nil 	// Strutura de Projetos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta estrutura de tabela de cabecario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMasterStr 	:= Self:CreateMasterStruct()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta estrura de tabela de Itens³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGridStr 	:= Self:CreateGridStruct()
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta estrura de tabela de Detal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGridDetStr := Self:CreateDetGridStruct()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Instacia Objeto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel 	:= 	MPFormModel():New( 'SAE', /*bPreValidacao*/, /*bPosValidacao*/, /*{ |oMdl| xFRT80MVCGR( oMdl ) }*/, /*bCancel*/ )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adocionas os model e os relcionam  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oModel:AddFields( "MasterStr"    	, /*cOwner*/,  oMasterStr ) 

oModel:AddGrid("GridStr" 			, "MasterStr",  oGridStr, /*B*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation("GridStr" 		, { { "AE_FILIAL", 'xFilial( "SAE" )' }, { "AE_COD", "AE_COD" } }, 'AE_FILIAL + AE_COD' )

oModel:AddGrid("GridDetStr" 		, "GridStr"		,  oGridDetStr, /*B*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation("GridDetStr" 	, { { 'MEN_FILIAL', 'xFilial( "MEN" )' }, { 'MEN_CODADM' 	, 'AE_COD'	} 	}	, MEN->(IndexKey(2)) )

oModel:GetModel( "GridDetStr" ):SetOptional(.T.)

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} GetAllData
Inclui os dados no model e retorna
@param   
@return  Self
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@todo	
@obs   
/*/
//--------------------------------------------------------------------
Method GetAllData() Class STDAAdministratorFinancial

Local oNewModel		:= Nil				// Retorno do Model
Local nX 			:= 0				// Contador do Struct
Local nY			:= 0				// Contador do Struct Men
Local cCampo		:= ""				// Campo da tabela que incluirá novo Registros
Local lFirstLine	:= .T.				// Primeiro regisro incluso
Local oModelMater	:= Nil				// Model do Field Master
Local oModelGrid	:= Nil				// Model do Grid
Local aStrGrid		:= {}				// Vetor com estrutura de dados	
Local oModelDetGrid	:= Nil				// Model do Field detalhe Grid
Local aStrDetGrid	:= {}				// Vetor com estrutura de dados
Local lDetaFirstLin	:= .T.				// Primeira Linha	
Local nLineDt		:= 0

oNewModel := Self:GetModel()	// Chama a estrutura de dados

oNewModel:SetOperation( 3 )
oNewModel:SetDescription(STR0001) //"Administradora Financeira"

oNewModel:Activate()
	
DbSelectArea("SAE")
DbSetOrder(1)	
SAE->(DbSeek(xFilial("SAE")))
	
// Dados 
oModelMater := oNewModel:GetModel("MasterStr")
oModelMater:SetValue("AE_FILIAL"	, SAE->AE_FILIAL)
oModelMater:SetValue("AE_COD"		, SAE->AE_COD  )
	
// Carrega todas as Adm na 1º Linha
oModelGrid := oNewModel:GetModel("GridStr")
aStrGrid := oModelGrid:GetStruct() // Retorna a estrutura de dados para Put dos valores
	

// Carrega todas do detalhes da  Adm na 1º Linha
oModelDetGrid 	:= oNewModel:GetModel("GridDetStr")
aStrDetGrid 	:= oModelDetGrid:GetStruct() // Retorna a estrutura de dados para Put dos valores

If ValType(oModelAdmF) = 'O'
	oNewModel := LjGetMdAdm()
Else

	// Carrega todas as Adm
	While !SAE->(EOF()) .And. SAE->AE_FILIAL == xFilial("SAE")
		
		If SAE->(FieldPos("AE_MSBLQL")) > 0 .AND. SAE->AE_MSBLQL == "1"
			// Desconsidera Adm Bloqueada
			SAE->(DbSkip())
			Loop
		EndIf

		If !lFirstLine
			nLine := oModelGrid:AddLine()
		EndIf
			
		For nX := 1 TO Len(aStrGrid:aFields)
			If !aStrGrid:aFields[nX][MODEL_FIELD_VIRTUAL]
				cCampo := aStrGrid:aFields[nX][3]
				oModelGrid:SetValue(cCampo	, &("SAE->"+cCampo))
			EndIf
		Next nX		
		
		// Carrega Detalhes da Adm Fin (Juros, Descontos e etc)
		DbSelectArea("MEN")
		DbSetOrder(2)
		If DbSeek(xFilial("MEN") + SAE->AE_COD)		
			
			// SOmente dados da Adm atual do ponteiro
			lDetaFirstLin := .T.
			While (!MEN->(EOF())) .AND.  (MEN->MEN_FILIAL == xFilial("MEN")) .AND. (MEN->MEN_CODADM == SAE->AE_COD)
				
				If !lDetaFirstLin
					nLineDt := oModelDetGrid:AddLine()
					
				EndIf
				Conout(Str(nLineDt))
				
				For nY := 1 TO Len(aStrDetGrid:aFields)
					If !aStrDetGrid:aFields[nY][MODEL_FIELD_VIRTUAL]
						cCampo := aStrDetGrid:aFields[nY][3]
						oModelDetGrid:SetValue(cCampo	, &("MEN->"+cCampo))
					EndIf
				Next nY		
				lDetaFirstLin := .F.
				MEN->(DbSkip())
			End
		
		EndIf	
		nLineDt := 1
		lFirstLine := .F.
		SAE->(DbSkip())
	End
EndIf

If ValType(oModelAdmF) = 'U'
	LjSetMdAdm(oNewModel)
EndIf
		
Return oNewModel

//--------------------------------------------------------------------
/*/{Protheus.doc} CreateMasterStruct
Cria estrutura do Model Master
@param   
@return  Struc
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@todo	
@obs   
/*/
//--------------------------------------------------------------------
Method CreateMasterStruct() Class STDAAdministratorFinancial

	Local cAlias 	:= "SAE"						// Alias que criara estrutura													
	Local aArea		:= Nil
	Local cX2Unico  := "AE_FILIAL+AE_COD" //X2_UNICO da tabela SAE

	If ValType(oStructSAE) = 'O'
		oStructSAE:Deactivate()
		oStructSAE:Activate()
	Else
	
		oStructSAE 	:= FWFormModelStruct():New()
		
		aArea := GetArea()	// Guarda area
		//Carrega informacoes da Tabela
		SX2->( DbSetOrder( 1 ) )
		SX2->( DbSeek( cAlias ) )
			
		If ExistFunc('FWX2Unico') 
			cX2Unico := FWX2Unico(cAlias) 
		EndIf

		oStructSAE:AddTable( 							;
					FWX2CHAVE()	                			, 	;  	// [01] Alias da tabela
					StrTokArr( cX2Unico, '+' ) 		, 	;  	// [02] Array com os campos que correspondem a primary key
					FWX2Nome(cAlias) )            					// [03] Descrição da tabela
		
		RestArea(aArea)
				     
		oStructSAE:AddField(                           ;
			                     "FILIAL"  		 	,	; // [01] Titulo do campo
			                     "FILIAL"  		 	,	; // [02] Desc do campo
			                     "AE_FILIAL" 	 	,	; // [03] Id do Field
			                     "C"              	,	; // [04] Tipo do campo
			                     FWSizeFilial()   	,	; // [05] Tamanho do campo
			                     0                	, 	; // [06] Decimal do campo
			                     Nil             	,	; // [07] Code-block de validação do campo
			                     Nil               	,	; // [08] Code-block de validação When do campo
			                     Nil 				, 	; // [09] Lista de valores permitido do campo
			                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigat?io
			                     Nil              	, 	; // [11] Code-block de inicializacao do campo
			                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
			                     NIL              	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
			               		)             			  // [14] Indica se o campo ?virtual
			
		oStructSAE:AddField(                           	;
			                     "CODIGO"  		 	,	; // [01] Titulo do campo
			                     "CODIGO"  		 	,	; // [02] Desc do campo
			                     "AE_COD" 	 		,	; // [03] Id do Field
			                     "C"              	,	; // [04] Tipo do campo
			                     TamSX3("AE_COD")[1],	; // [05] Tamanho do campo
			                     0                	, 	; // [06] Decimal do campo
			                     Nil             	,	; // [07] Code-block de validação do campo
			                     Nil               	,	; // [08] Code-block de validação When do campo
			                     Nil 				, 	; // [09] Lista de valores permitido do campo
			                     Nil 				, 	; // [10] Indica se o campo tem preenchimento obrigat?io
			                     Nil              	, 	; // [11] Code-block de inicializacao do campo
			                     NIL             	, 	; // [12] Indica se trata-se de um campo chave
			                     NIL              	,  	; // [13] Indica se o campo pode receber valor em uma operação de update.
			               		 )             			  // [14] Indica se o campo ?virtual
	EndIf	
Return oStructSAE

//--------------------------------------------------------------------
/*/{Protheus.doc} CreateGridStruct
Cria estrutura do Model Grid
@param   
@return  Struc
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@todo	
@obs   
/*/
//--------------------------------------------------------------------
Method CreateGridStruct() Class STDAAdministratorFinancial

	Local oStruct 	:= FWFormModelStruct():New()	// Estrutura
	Local nX		:= 0							// Contador
	Local cAlias 	:= "SAE"						// Alias que criara estrutura													
	Local cX2Unico  := "AE_FILIAL+AE_COD" //X2_UNICO da tabela SAE
	
	//Carrega informacoes da Tabela
	SX2->( DbSetOrder( 1 ) )
	SX2->( DbSeek( cAlias ) )

	If ExistFunc('FWX2Unico') 
		cX2Unico := FWX2Unico(cAlias) 
	EndIf	
	
	oStruct:AddTable( 							;
	FWX2CHAVE()	                			, 	;  	// [01] Alias da tabela
	StrTokArr( cX2Unico, ' + ' ) 		, 	;  	// [02] Array com os campos que correspondem a primary key
	FWX2Nome(cAlias) )                 					// [03] Descrição da tabela
	
	//Carrega informacoes de campos
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek("SAE"))
	
	While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAlias
	  	oStruct:AddField(                                   	;
	                     AllTrim( X3Titulo()  )        		 	,	; // [01] Titulo do campo
	                     AllTrim( X3Descric() )         		,	; // [02] ToolTip do campo
	                     AllTrim( SX3->X3_CAMPO )       		,	; // [03] Id do Field
	                     SX3->X3_TIPO                  			,	; // [04] Tipo do campo
	                     SX3->X3_TAMANHO               			,	; // [05] Tamanho do campo
	                     SX3->X3_DECIMAL                		,	; // [06] Decimal do campo
	                     Nil                         			,	; // [07] Code-block de validação do campo
	                     Nil                          			,	; // [08] Code-block de validação When do campo
	                     StrTokArr( AllTrim( X3CBox() ),';')	, 	; // [09] Lista de valores permitido do campo
	                     Nil 									,	; // [10] Indica se o campo tem preenchimento obrigatório
	                     Nil                         			, 	; // [11] Code-block de inicializacao do campo
	                     NIL                            		, 	; // [12] Indica se trata-se de um campo chave
	                     NIL                            		, 	; // [13] Indica se o campo pode receber valor em uma operação de update.
	                     ( SX3->X3_CONTEXT == 'V' )     )             // [14] Indica se o campo é virtual
		SX3->(DbSkip()) 
	End

Return oStruct

//--------------------------------------------------------------------
/*/{Protheus.doc} CreateDetGridStruct
Cria estrutura dos Detalhes de cada parcela
@param   
@return  Struc
@author  Varejo
@since   24/04/2012
@version P11.8
@see	
@todo	
@obs   
/*/
//--------------------------------------------------------------------
Method CreateDetGridStruct() Class STDAAdministratorFinancial

Local oStruct 	:= FWFormModelStruct():New()	// Estrutura
Local nX		:= 0							// Contador
Local cAlias 	:= "MEN"						// Alias que criara estrutura													
Local cX2Unico  := "MEN_FILIAL+MEN_CODADM+MEN_ITEM" //X2_UNICO da tabela MEN

//Carrega informacoes da Tabela
SX2->( DbSetOrder( 1 ) )
SX2->( DbSeek( cAlias ) )

If ExistFunc('FWX2Unico') 
	cX2Unico := FWX2Unico(cAlias) 
EndIf

oStruct:AddTable( 							;
FWX2CHAVE()	                			, 	;  	// [01] Alias da tabela
StrTokArr( cX2Unico, ' + ' ) 		, 	;  	// [02] Array com os campos que correspondem a primary key
FWX2Nome(cAlias) )             					// [03] Descri?o da tabela

//Carrega informacoes de campos
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))

While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAlias
  	oStruct:AddField(                                   	;
                     AllTrim( X3Titulo()  )        		 	,	; // [01] Titulo do campo
                     AllTrim( X3Descric() )         		,	; // [02] ToolTip do campo
                     AllTrim( SX3->X3_CAMPO )       		,	; // [03] Id do Field
                     SX3->X3_TIPO                  			,	; // [04] Tipo do campo
                     SX3->X3_TAMANHO               			,	; // [05] Tamanho do campo
                     SX3->X3_DECIMAL                		,	; // [06] Decimal do campo
                     Nil                         			,	; // [07] Code-block de validação do campo
                     Nil                          			,	; // [08] Code-block de validação When do campo
                     StrTokArr( AllTrim( X3CBox() ),';')	, 	; // [09] Lista de valores permitido do campo
                     Nil 									,	; // [10] Indica se o campo tem preenchimento obrigatório
                     Nil                         			, 	; // [11] Code-block de inicializacao do campo
                     NIL                            		, 	; // [12] Indica se trata-se de um campo chave
                     NIL                            		, 	; // [13] Indica se o campo pode receber valor em uma operação de update.
                     ( SX3->X3_CONTEXT == 'V' )     )             // [14] Indica se o campo é virtual
	SX3->(DbSkip()) 
End

Return oStruct

//--------------------------------------------------------------------
/*/{Protheus.doc} LjGetMdAdm
Retorno o objeto estatico oModelAdmF
@return  oModelAdmF, Objeto, Model SAE MEN
@author  joao.marcos
@since   17/06/2022
/*/
//--------------------------------------------------------------------
Function LjGetMdAdm()
Return oModelAdmF
//--------------------------------------------------------------------
/*/{Protheus.doc} LjSetMdAdm
Seta valor ao objeto estatico oModelAdmF
@param 	oModel, objeto, Model SAE e MEN carregado pelo metodo GetAllData
@return  oModelAdmF, Objeto, Model SAE e MEN
@author  joao.marcos
@since   17/06/2022  
/*/
//--------------------------------------------------------------------
Function LjSetMdAdm(oModel)
oModelAdmF := oModel
return
