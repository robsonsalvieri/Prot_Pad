#Include 'Protheus.ch'

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} AddDataMex
Popula a tabela MEX (Wizard)

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
User Function STPopula()

Local aField 	:= LoadFields()
Local aRoot	:= {}
Local aOthers	:= {}

//Inicializa Ambiente
RpcSetEnv("T1","D MG 01")

aRoot 		:= Root()
aOthers 	:= Others()

RecData(aField,aRoot)
RecData(aField,aOthers)
			
// Finaliza Ambiente
RPCClearEnv()
	
Alert("Dados OK!!!")

Return Nil


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} AddDataMex
Retorna todos os campos da tabela

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function LoadFields()

Local aField := {}

Aadd(aField,"MEX_ID")
Aadd(aField,"MEX_FATHER")
Aadd(aField,"MEX_TITLE")
Aadd(aField,"MEX_DESC")
Aadd(aField,"MEX_SOURCE")
Aadd(aField,"MEX_MVIEW")
Aadd(aField,"MEX_OPER")
Aadd(aField,"MEX_BCKOPR")
Aadd(aField,"MEX_LOAD")
Aadd(aField,"MEX_ACTION")
Aadd(aField,"MEX_ORDER")
Aadd(aField,"MEX_PANEL")
Aadd(aField,"MEX_LMENU")
Aadd(aField,"MEX_SKIP")

Return aField

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} Root
Inserir todos os registros do tipo Root

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function Root()

Local aDataRoot := {}

Aadd(aDataRoot, {	"CLIENTE"	,; //MEX_ID 
					"ROOT"		,; //MEX_FATHER
					"CLIENTE"	,; //MEX_TITLE
					"CLIENTE"	,; //MEX_DESC
					""			,; //MEX_SOURCE
					""			,; //MEX_MVIEW
					""			,; //MEX_OPER
					""			,; //MEX_BCKOPR
					""			,; //MEX_LOAD
					""			,; //MEX_ACTION
					"1"			,; //MEX_ORDER
					.F.			,; //MEX_PANEL
					.F.			,; //MEX_LMENU
					.F. 		}) //MEX_SKIP


Aadd(aDataRoot, {	"VENDA"	,; //MEX_ID
					"ROOT"		,; //MEX_FATHER
					"VENDA"	,; //MEX_TITLE
					"VENDA"	,; //MEX_DESC 
					""			,; //MEX_SOURCE
					""			,; //MEX_MVIEW 
					""			,; //MEX_OPER 
					""			,; //MEX_BCKOPR
					""			,; //MEX_LOAD 
					"{|aVet| STIVetor( aVet ) }",; //MEX_ACTION
					"2"			,; //MEX_ORDER 
					.F.			,; //MEX_PANEL 
					.F.			,; //MEX_LMENU 
					.F. 		}) //MEX_SKIP 


Aadd(aDataRoot, {	"ORCAMENTO"			,; //MEX_ID
					"ROOT"						,; //MEX_FATHER 
					"ORCAMENTO"				,; //MEX_TITLE 
					"ORCAMENTO"				,; //MEX_DESC 
					""							,; //MEX_SOURCE 
					""							,; //MEX_MVIEW 
					""							,; //MEX_OPER 
					""							,; //MEX_BCKOPR
					""							,; //MEX_LOAD 
					"{||STBISCanImport()}"	,; //MEX_ACTION 
					"3"							,; //MEX_ORDER 
					.F.							,; //MEX_PANEL 
					.F.							,; //MEX_LMENU 
					.F. 						}) //MEX_SKIP 


Aadd(aDataRoot, {	"ABRCAIXA"				,; //MEX_ID 
					"ROOT"					,; //MEX_FATHER 
					"ABR. CAIXA"			,; //MEX_TITLE 
					"ABERTURA DE CAIXA"	,; //MEX_DESC 
					""						,; //MEX_SOURCE 
					""						,; //MEX_MVIEW 
					""						,; //MEX_OPER 
					""						,; //MEX_BCKOPR 
					""						,; //MEX_LOAD 
					""						,; //MEX_ACTION 
					"4"						,; //MEX_ORDER 
					.F.						,; //MEX_PANEL 
					.F.						,; //MEX_LMENU 
					.F. 					}) //MEX_SKIP 


Aadd(aDataRoot, {	"FCHCAIXA"				,; //MEX_ID 
					"ROOT"					,; //MEX_FATHER
					"FCH. CAIXA"			,; //MEX_TITLE 
					"FECHAMENTO DE CAIXA",; //MEX_DESC 
					""						,; //MEX_SOURCE 
					""						,; //MEX_MVIEW 
					""						,; //MEX_OPER 
					""						,; //MEX_BCKOPR 
					""						,; //MEX_LOAD 
					""						,; //MEX_ACTION 
					"5"						,; //MEX_ORDER 
					.F.						,; //MEX_PANEL 
					.F.						,; //MEX_LMENU 
					.F. 					}) //MEX_SKIP 					
	
	
Aadd(aDataRoot, {	"CANCVENDA"		,; //MEX_ID 
					"ROOT"				,; //MEX_FATHER 
					"CANC. VENDA"		,; //MEX_TITLE 
					"CANCELAR VENDA"	,; //MEX_DESC 
					""					,; //MEX_SOURCE 
					""					,; //MEX_MVIEW 
					""					,; //MEX_OPER 
					""					,; //MEX_BCKOPR 
					""					,; //MEX_LOAD 
					"{|| STICanCancel() }"					,; //MEX_ACTION 
					"6"					,; //MEX_ORDER 
					.F.					,; //MEX_PANEL 
					.F.					,; //MEX_LMENU 
					.F. 				}) //MEX_SKIP 


Aadd(aDataRoot, {	"RECEBTITULO"				,; //MEX_ID 
					"ROOT"						,; //MEX_FATHER  
					"RECEB. TITULO"			,; //MEX_TITLE 
					"RECEBIMENTO DE TITULO"	,; //MEX_DESC 
					""							,; //MEX_SOURCE
					""							,; //MEX_MVIEW 
					""							,; //MEX_OPER 
					""							,; //MEX_BCKOPR 
					""							,; //MEX_LOAD 
					""							,; //MEX_ACTION 
					"7"							,; //MEX_ORDER 
					.F.							,; //MEX_PANEL 
					.F.							,; //MEX_LMENU 
					.F. 						}) //MEX_SKIP 	


Aadd(aDataRoot, {	"LSTPRESENTE"			,; //MEX_ID 
					"ROOT"					,; //MEX_FATHER  
					"LST. PRESENTE"		,; //MEX_TITLE 
					"LISTA DE PRESENTE"	,; //MEX_DESC 
					""						,; //MEX_SOURCE
					""						,; //MEX_MVIEW 
					""						,; //MEX_OPER 
					""						,; //MEX_BCKOPR 
					""						,; //MEX_LOAD 
					""						,; //MEX_ACTION 
					"8"						,; //MEX_ORDER 
					.F.						,; //MEX_PANEL 
					.F.						,; //MEX_LMENU 
					.F. 					}) //MEX_SKIP 


Aadd(aDataRoot, {	"CONFCAIXA"				,; //MEX_ID 
					"ROOT"						,; //MEX_FATHER 
					"CONF. CAIXA"				,; //MEX_TITLE 
					"CONFERENCIA DE CAIXA"	,; //MEX_DESC 
					""							,; //MEX_SOURCE 
					""							,; //MEX_MVIEW 
					""							,; //MEX_OPER 
					""							,; //MEX_BCKOPR 
					""							,; //MEX_LOAD 
					""							,; //MEX_ACTION 
					"9"							,; //MEX_ORDER 
					.F.							,; //MEX_PANEL 
					.F.							,; //MEX_LMENU 
					.F. 						}) //MEX_SKIP 	

Aadd(aDataRoot, {	"ESTTITULO"				,; //MEX_ID 
					"ROOT"						,; //MEX_FATHER 
					"EST. DE TITULO"			,; //MEX_TITLE 
					"ESTORNO DE TITULO"		,; //MEX_DESC 
					""							,; //MEX_SOURCE 
					""							,; //MEX_MVIEW 
					""							,; //MEX_OPER 
					""							,; //MEX_BCKOPR 
					""							,; //MEX_LOAD 
					""							,; //MEX_ACTION 
					"10"						,; //MEX_ORDER 
					.F.							,; //MEX_PANEL 
					.F.							,; //MEX_LMENU 
					.F. 						}) //MEX_SKIP
	
Return aDataRoot

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} Others
Inserir os registros que nao fazem parte do Root

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function Others()

Local aDataOthers := {}

Aadd(aDataOthers, {	"CCAIXA"					,; //MEX_ID 
						"CONFCAIXA"				,; //MEX_FATHER 
						"CONF. CAIXA"				,; //MEX_TITLE 
						"CONFERENCIA DE CAIXA"	,; //MEX_DESC 
						"STIConfCash"				,; //MEX_SOURCE 
						""							,; //MEX_MVIEW 
						"1"							,; //MEX_OPER 
						"1"							,; //MEX_BCKOPR 
						""							,; //MEX_LOAD 
						"{||STIInsPaym()}"		,; //MEX_ACTION 
						""							,; //MEX_ORDER 
						.T.							,; //MEX_PANEL 
						.F.							,; //MEX_LMENU 
						.F. 						}) //MEX_SKIP 	


Aadd(aDataOthers, {	"RTITULO"					,; //MEX_ID 
						"RECEBTITULO"				,; //MEX_FATHER 
						"RECEB. TITULO"			,; //MEX_TITLE 
						"RECEBIMENTO DE TITULO"	,; //MEX_DESC 
						"STISrchTit"				,; //MEX_SOURCE 
						"RECBTIT"					,; //MEX_MVIEW 
						"3"							,; //MEX_OPER 
						"4"							,; //MEX_BCKOPR 
						""							,; //MEX_LOAD
						"{||STIFindTit()}"		,; //MEX_ACTION 
						""							,; //MEX_ORDER 
						.F.							,; //MEX_PANEL 
						.F.							,; //MEX_LMENU 
						.T. 						}) //MEX_SKIP


Aadd(aDataOthers, {	"ESTTIT"					,; //MEX_ID 
						"ESTTITULO"				,; //MEX_FATHER 
						"EST. DE TITULO"			,; //MEX_TITLE 
						"ESTORNO DE TITULO"		,; //MEX_DESC 
						"STISrchTit"				,; //MEX_SOURCE 
						"ESTTIT"					,; //MEX_MVIEW 
						"3"							,; //MEX_OPER 
						"4"							,; //MEX_BCKOPR 
						""							,; //MEX_LOAD
						"{||STIFindTit()}"		,; //MEX_ACTION 
						""							,; //MEX_ORDER 
						.F.							,; //MEX_PANEL 
						.F.							,; //MEX_LMENU 
						.T. 						}) //MEX_SKIP


Aadd(aDataOthers, {	"IMP ORCAMENTO"				,; //MEX_ID 
						"ORCAMENTO"					,; //MEX_FATHER 
						"IMP ORC"						,; //MEX_TITLE 
						"IMPORTACAO DE ORCAMENTO"	,; //MEX_DESC 
						"STIImportSale"				,; //MEX_SOURCE 
						""								,; //MEX_MVIEW 
						"3"								,; //MEX_OPER 
						"3"								,; //MEX_BCKOPR 
						""								,; //MEX_LOAD
						"{||STIImpSales()}"			,; //MEX_ACTION 
						""								,; //MEX_ORDER 
						.F.								,; //MEX_PANEL 
						.F.								,; //MEX_LMENU 
						.T. 							}) //MEX_SKIP   
													
Aadd(aDataOthers, {		"INCPROD"						,; //MEX_ID 
						"VENDA"							,; //MEX_FATHER 
						"REGISTRO DE ITEM"				,; //MEX_TITLE 
						"" 								,; //MEX_DESC 
						"STIRegItem"		   			,; //MEX_SOURCE 
						""								,; //MEX_MVIEW 
						"3"								,; //MEX_OPER 
						"3"								,; //MEX_BCKOPR 
						""	  		,; //MEX_LOAD
						"" 								,; //MEX_ACTION 
						""								,; //MEX_ORDER 
						.F.								,; //MEX_PANEL 
						.F.								,; //MEX_LMENU 
						.T. 							}) //MEX_SKIP 
						

					
Aadd(aDataOthers, {"INCCLIENTE"						,; //MEX_ID 
						"CLIENTE"						,; //MEX_FATHER 
						"SELECAO DE CLIENTES"			,; //MEX_TITLE 
						"" 								,; //MEX_DESC 
						"STICustomerSelection"	  		,; //MEX_SOURCE 
						""								,; //MEX_MVIEW 
						"3"								,; //MEX_OPER 
						"3"								,; //MEX_BCKOPR 
						""								,; //MEX_LOAD
						"{|| STIFilCustomerData()}"		,; //MEX_ACTION 
						""								,; //MEX_ORDER 
						.F.								,; //MEX_PANEL 
						.F.								,; //MEX_LMENU 
						.F. 							}) //MEX_SKIP
						
Aadd(aDataOthers, {		"INCPROD2"						,; //MEX_ID 
						"INCCLIENTE"					,; //MEX_FATHER 
						"REGISTRO DE ITEM"				,; //MEX_TITLE 
						"" 								,; //MEX_DESC 
						"STIRegItem"		   			,; //MEX_SOURCE 
						""								,; //MEX_MVIEW 
						"3"								,; //MEX_OPER 
						"3"								,; //MEX_BCKOPR 
						"STIGridItens|GRID|1|1"	  		,; //MEX_LOAD
						"" 								,; //MEX_ACTION 
						""								,; //MEX_ORDER 
						.T.								,; //MEX_PANEL 
						.T.								,; //MEX_LMENU 
						.F. 							}) //MEX_SKIP 

Return aDataOthers

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} RecData
Grava as informacoes na tabela MEX

@param   	aField - campos a serem gravados
@param   	aData  - registros a serem gravados
@author  	Vendas & CRM
@version 	P12
@since   	30/03/2012
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Static Function RecData(aField,aData)

Local nI := 0 //Variavel de Loop
Local nX := 0 //Variavel de Loop

DbSelectArea("MEX")
DbSetOrder(1)

For nI := 1 To Len(aData)

	// Se existe substitui
	If MEX->(DbSeek( xFilial("MEX") + aData[nI][1] )) // FILIAL + ID
	
		RecLock( "MEX" , .F. )	
		
		For nX := 1 To Len(aData[nI])
		
			Replace &(aField[nX]) With aData[nI][nX]
					
		Next nX
		
		MsUnlock()
		
	// Nao existe cria
	Else
	
		RecLock("MEX",.T.)
			
		For nX := 1 To Len(aData[nI])
		
			Replace &(aField[nX]) With aData[nI][nX]
			
		Next nX
		
		MsUnlock()
		
	EndIf
	
Next nI	


Return Nil




