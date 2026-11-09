#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STDSALESMANSELECTION.CH"

Static oModelVen := Nil 	//Model do Vendedor
Static oVendStruct	:= Nil		//Estrutura do vendedor

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSalesmanData
Cria estrutura de dados do Model de Vendedores, sem suas validacoes.
@param  cKey		 	Chave de Pesquisa. Contém Filial, Vendedor e Loja.
@param  lOffline	Pesquisa offiline 
@author  Varejo
@version P11.8
@since   10/09/2013
@return  xRet - Retorna estrutura de dados do Model
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSalesmanData( cKey , lOffline )

Local aArea	   		:= GetArea()					// Guarda area
Local oStruct 		:= 	Nil							// Estrutura 
Local xRet 	   		:= 	IIF(lOffline,Nil,{})		// Se a busca for offline, sera retornado um model. Caso contrario, sera retornado um array
Local aCampos		:= {}							// Array de campos
Local nX			:= 0							// Contador

Default cKey		 	:= ""
Default lOffline		:= .T.		

	
ParamType 0 Var cKey 		AS Character	Default ""
ParamType 1 var lOffline	As Logical		Default 	.F.

/*/
	Monta estrutura de tabela de Vendedores
/*/
oStruct := NoVldStruct()

aCampos := oStruct:GetFields() 

If lOffline
	/*/
		Instacia Objeto
	/*/
	xRet 	:= 	MPFormModel():New( 'SA3', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	xRet:AddFields("SA3MASTER",/*cOwner*/,oStruct)
	xRet:SetDescription("SalesMans")
	xRet:SetOperation(3)
	xRet:Activate()
EndIf


/* 
	Preenche o Modelo de dados do Vendedor com as informacoes da tabela SA3
*/

DbSelectArea("SA3")
DbSetOrder(1)//A3_FILIAL+A3_COD
If 	DbSeek	( cKey )
	For nX := 1 to Len(aCampos)
		If lOffline
			xRet:SetValue('SA3MASTER', aCampos[nX][MODEL_FIELD_IDFIELD], &("SA3->"+aCampos[nX][MODEL_FIELD_IDFIELD]))				
		Else
			AAdd(xRet,{aCampos[nX][MODEL_FIELD_IDFIELD],&("SA3->"+aCampos[nX][MODEL_FIELD_IDFIELD])})
		EndIf	
	Next nX
EndIf

If lOffline
	oModelVen := xRet
EndIf

RestArea(aArea)

Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} NoVldStruct
Cria estrutura do Model de Vendedores, sem suas validacoes.
@param   
@author  Varejo
@version P11.8
@since   10/09/2013
@return  oStruct - retorna estrutura do Model 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function NoVldStruct() 

Local aArea	 	:= GetArea()						// Guarda area
Local cAlias 	:= "SA3"							// Alias que criara estrutura													
Local cX2Unico  := "A3_FILIAL+A3_COD" //X2_UNICO da tabela SA3

If ValType(oVendStruct) == 'O'
	oVendStruct:DeActivate()
	oVendStruct := Nil
EndIf

oVendStruct := FWFormModelStruct():New()  		// Estrutura

//Carrega informacoes da Tabela
SX2->( DbSetOrder( 1 ) )
SX2->( DbSeek( cAlias ) )

If ExistFunc('FWX2Unico') 
	cX2Unico := FWX2Unico(cAlias) 
EndIf

oVendStruct:AddTable( 										;
						FWX2CHAVE(), 						;  	// [01] Alias da tabela
						StrTokArr( cX2Unico, '+' ), 	;  	// [02] Array com os campos que correspondem a primary key
						FWX2Nome(cAlias)						)	// [03] Descrição da tabela

//Carrega informacoes de campos
DbSelectArea("SX3")
SX3->(DbSetOrder(1))
SX3->(DbSeek(cAlias))

While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAlias

	If Upper(AllTrim(SX3->X3_TIPO)) <> "M" .AND. SX3->X3_CONTEXT <> 'V'
	  	oVendStruct:AddField(                                   		;
	                     AllTrim( X3Titulo()  )        			,	; 	// [01] Titulo do campo
	                     AllTrim( X3Descric() )         		,	; 	// [02] ToolTip do campo
	                     AllTrim( SX3->X3_CAMPO )         		,	; 	// [03] Id do Field
	                     SX3->X3_TIPO                  			,	; 	// [04] Tipo do campo
	                     SX3->X3_TAMANHO               			,	; 	// [05] Tamanho do campo
	                     SX3->X3_DECIMAL                		,	; 	// [06] Decimal do campo
	                     Nil                         			,	; 	// [07] Code-block de validacaoo do campo
	                     Nil                          			,	; 	// [08] Code-block de validacaoo When do campo
	                     StrTokArr( AllTrim( X3CBox() ),';')	, 	; 	// [09] Lista de valores permitido do campo
	                     Nil 									,	; 	// [10] Indica se o campo tem preenchimento obrigatorio
	                     Nil                         			, 	; 	// [11] Code-block de inicializacao do campo
	                     NIL                            		, 	; 	// [12] Indica se trata-se de um campo chave
	                     NIL                            		, 	; 	// [13] Indica se o campo pode receber valor em uma operacao de update.
	                     ( SX3->X3_CONTEXT == 'V' )     		)      	// [14] Indica se o campo e virtual
	EndIf    
	 
	SX3->(DbSkip()) 
End

RestArea(aArea)

Return oVendStruct 


//-------------------------------------------------------------------
/*/ {Protheus.doc} STDGVenModel
Funcao que retorna o Model do Vendedor preenchido.

@author Varejo
@since 10/09/2013
@version 11.8
@return oModelVen - Model do Vendedor
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDGVenModel()
Return oModelVen


//-------------------------------------------------------------------
/*/ {Protheus.doc} STDFilPBSalesManData
Funcao que retorna o Model do Vendedor preenchido.
@param  cVendedor	Vendedor
@author Varejo
@since 10/09/2013
@version 11.8
@return Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFilPBSalesManData( cVendedor )

Default cVendedor		:= ""

ParamType 0 Var cVendedor 		AS Character	Default ""

STDSPBasket("SL1","L1_VEND"	,oModelVen:GetValue("SA3MASTER","A3_COD"))

Return Nil 


//-------------------------------------------------------------------
/*/ {Protheus.doc} STDFilPBSalesManData
Funcao que retorna o Model do Vendedor preenchido.
@param aDados - array de dados do Vendedor
@author Varejo
@since 10/09/2013
@version 11.8
@return oModel - Model do Vendedor
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFilVenData( aDados )

Local oStruct 			:= 	Nil			// Estrutura 
Local oModel 			:= 	Nil			// Model do Vendedor
Local nX				:= 0			// Contador

Default aDados		 	:= {}	
	
ParamType 0 Var aDados AS Array	Default {}

/*/
	Monta estrutura de tabela de Vendedores
/*/
oStruct := NoVldStruct()

/*/
	Instacia Objeto
/*/
oModel 	:= 	MPFormModel():New( 'SA3', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields("SA3MASTER",/*cOwner*/,oStruct)
oModel:SetDescription("SalesMans")
oModel:SetOperation(3)
oModel:Activate()

For nX := 1 to Len(aDados)
	oModel:LoadValue('SA3MASTER', aDados[nX][FIELD_NAME], aDados[nX][FIELD_VALUE])		
Next nX 

oModelVen := oModel

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} STISalManFilter
Responsavel pela criaçao do filtro que sera passado ao Browse, com base nas informacoes digitadas pelo Vendedor.
@param cGetSalesman   	- String digitada pelo usuario utilizada para pesquisar o Vendedor.
@param oGetList      	- Objeto de escolha do campo a ser utilizado na busca
@author Varejo
@version 11.80
@since 10/09/2013
@return
*/
//-------------------------------------------------------------------

Function STISalManFilter(cGetSalesman,oGetList,aRecno)
Local aArea			:= GetArea() 	// Area Atual
Local nSec1			:= 0			// Segundos Iniciais
Local nSec2         := 0			// Segundos no processo
Local nCont			:= 0           	// Contador
Local lMinGetSize	:= Len(AllTrim(cGetSalesman)) >= 1 // Tamanho minimo do campo
Local aSalesmans	:= {}    		// Array com os vendedores achados
Local nLimit		:= 20          	// Limite de informacoes apresentadas na tela
Local cFilter 		:= ""  			// Filtro que será utilizado para pesquisar o Vendedor desejado.
Local lRet			:= .T.         	// Variavel de retorno

nSec1 := Seconds()
aRecno := {}

If !Empty(cGetSalesman)
	If lMinGetSize

		DbSelectArea("SA3")

		If Val(SubStr(cGetSalesman,1,TamSX3("A3_COD")[1])) == 0
			cFilter := "SA3->A3_FILIAL == '" + xFilial('SA3') + "' .AND. ('" + Upper(AllTrim(cGetSalesman)) + "' $ Upper(AllTrim(SA3->A3_NOME))" +;
						" .Or. '"+ Upper(AllTrim(cGetSalesman)) + "' $ Upper(AllTrim(SA3->A3_COD)))" + " .AND. SA3->A3_MSBLQL <> '1'"

			SA3->(DbSetOrder())
			If SA3->(!EOF())
				SA3->(DbGoTo(SA3->(LastRec())+1))
			EndIf
			
			SA3->(DbSetFilter({ || &cFilter }, cFilter))
			SA3->(DbGoTop())
						
			While !SA3->(EOF())
				nCont++
				aAdd(aRecno,SA3->(Recno()))
				aAdd(aSalesmans,AllTrim(SA3->A3_COD)+" / "+AllTrim(SA3->A3_NOME)+" / "+AllTrim(SA3->A3_CGC))
				If nCont == nLimit
					Exit
				EndIf
				SA3->(DbSkip())
			EndDo

			SA3->(DbClearFilter())
		Else
			SA3->(DbSetOrder(1))
			If DbSeek(xFilial("SA3")+AllTrim(cGetSalesman))
				If SA3->A3_MSBLQL <> '1'
					aAdd(aRecno,SA3->(Recno()))
					aAdd(aSalesmans,AllTrim(SA3->A3_COD)+" / "+AllTrim(SA3->A3_NOME)+" / "+AllTrim(SA3->A3_CGC))
				Endif
			EndIf
		EndIf
	Else
		lRet := .F.
		STFMessage(ProcName(),"STOP",STR0001) //"É necessário digitar pelo menos 3 caracteres."
		STFShowMessage(ProcName())
	EndIf
EndIf


nSec2 := Seconds()-nSec1

Conout("-------------------------")
ConOut(Str(nSec2))
Conout("-------------------------")

oGetList:SetArray(aSalesmans)

If Len(aSalesmans) > 0
	oGetList:GoTop()
EndIf

If lMinGetSize
	If Len(aSalesmans) == 0
		STFMessage(ProcName(),"STOP",STR0002) //"Nenhum Vendedor encontrado."
		STFShowMessage(ProcName())
		lRet := .F.
	Else
		If Len(aSalesmans) == nLimit
			STFMessage(ProcName(),"STOP",STR0003+AllTrim(Str(Len(aSalesmans)))+STR0004) //"O resultado foi limitado a "##" Vendedores. Refine sua busca se for necessário."
		ElseIf Len(aSalesmans) == 1
			STFMessage(ProcName(),"STOP",STR0005) //"1 Vendedor foi encontrado."
		Else
			STFMessage(ProcName(),"STOP",STR0006+AllTrim(Str(Len(aSalesmans)))+STR0007) //"Foram encontrados "##" Vendedores."
		EndIf
		STFShowMessage(ProcName())

		oGetList:SetFocus()
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDFindSMan()
Pesquisa o vendedor em especifico

@param
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  aRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDFindSMan()

Local aRet 		:= {}
Local cSalesMan 	:= STDGPBasket("SL1","L1_VEND")

SA3->(dbSetOrder(1))
SA3->(dbSeek(xFilial('SA3')+cSalesMan))
If SA3->(!EOF())

	Aadd(aRet,SA3->A3_NOME)

EndIf 

Return aRet
