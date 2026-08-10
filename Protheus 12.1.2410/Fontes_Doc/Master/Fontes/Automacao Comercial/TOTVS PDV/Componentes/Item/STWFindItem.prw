#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STWFINDITEM.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STWFindItem
Function Busca Item

@param   cCodeReceived			Codigo do Item
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aRet						Array com informações do Item
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STWFindItem( cCodeReceived , lPAFECF, 	lHomolPaf, lOnlyCodBar)
 
Local aRet 				:= {}			// Retorno  
Local aRetStry			:= {}			// Retorno Balanca
Local aRetDtBar			:= {}			// Retorno do leitor Optico
Local dDtValid			:= ""			// Data validade do produto
Local cCodProd	 		:= ""			// Codigo Produto
Local lShowMsgBlock     := SuperGetMV("MV_LJITMSG",,.F.) //Contra se mostra mensagem de item não encontrado ou bloqueado
Local nTamB1UM 			:= TamSX3("B1_UM")[1]
Local cUnidMed 			:= PadR("G", nTamB1UM) + "|" + PadR("MG", nTamB1UM) + "|" + PadR("KG", nTamB1UM)
Local lPEItmNVld		As Logical

Default	cCodeReceived	:= ""			// Codigo recebido/digitado
Default lPAFECF			:= StbIsPaf()
Default	lHomolPaf		:= STBHomolPaf()//Homologação
Default lOnlyCodBar		:= .F. 

lPEItmNVld		:= ExistBlock('STWItmNVld') // Verifica se existe o ponto de entrada para customização  de item invalido

ParamType 0 Var cCodeReceived AS Character	Default ""

/*
	Caso Trabalhe com seperador de digito:
	Pega o Codigo recebido/digitado e separa em Codigo do Item
	e quantidade do Item, conforme configuracao do parameto
*/
cCodeReceived := STBDigItem(cCodeReceived)

//Para otimizar pesquisa, realiza primeira a pesquisa de codigo de barras
aRet	:= STDFItemCB( cCodeReceived,lPAFECF,lHomolPaf )

/*
	Procura Item na tabela de produtos
*/
If !aRet[ITEM_ENCONTRADO] .AND. !lOnlyCodBar
	aRet	:= STDFindItem( cCodeReceived,  lPAFECF, 		lHomolPaf)   
EndIf

//Recno do Produto na tabela SB1
If aRet[ITEM_ENCONTRADO]
	SB1->(DbGoto(aRet[ITEM_RECNO])) 
EndIf

If !IsInCallStack("STBCONFPAY") .AND.  aRet[ITEM_ENCONTRADO] .AND.	aRet[ITEM_BALANCA] == "2"  .AND. aRet[ITEM_UNID_MEDIDA] $ cUnidMed .And. !Empty(STFGetStation("BALANCA")) .And. Empty(STDGPBasket("SL1", "L1_NUMORIG"))  	// 07 - Tipo produto de balanca
	/*/	
		Verifica se usa balanca para pegar peso - ( Quantidade = Peso )
	/*/        
	aRetStry := 	STFFireEvent(	ProcName(0)	,;		// Nome do processo
					"STBalanceUse"				,;		// Nome do evento
					{.T.}							)		//  06 - Define se usa a balaça
 
	//Essa verificação é feita para considerar se deve pegar a quantidade da balança (quantidade = 1 é o default, ou seja, a quantidade deve ser retornada da balança)
   	If STBGetQuant() == 1 
		If ValTYpe(aRetStry) == "A" .AND. Len(aRetStry) > 0  .OR. Valtype(aRetStry[1]) == "L" .AND. aRetStry[1] 
			// Pega quantidade da balanca
			STBBalQuant()	
		EndIf
	EndIf
EndIf


/*
	Procura Item na tabela de codigo de barras
*/
If !aRet[ITEM_ENCONTRADO]	
	aRet	:= STDFItemCB( cCodeReceived,lPAFECF, 		lHomolPaf )		
EndIf	

/*
	Ve se e item de Etiqueta/Balanca
*/
If !aRet[ITEM_ENCONTRADO]	
	aRet	:= STDFItemBal( cCodeReceived )		
EndIf	

If !aRet[ITEM_ENCONTRADO] .AND. SuperGetMv("MV_LJDTBAR",,.F.)
	aRetDtBar := STBDataBar(cCodeReceived)
	cCodProd  := aRetDtBar[1][1]
	dDtValid  := aRetDtBar[2][1]
	aRet	   := STDFItemCB( cCodProd ) 
	
	If !aRet[ITEM_ENCONTRADO]
		aRet   := STDFindItem( cCodProd )
	EndIf
	
	If aRet[ITEM_ENCONTRADO]

		If !Empty(dDtValid) .AND. dDtValid <= dDatabase
			// Caso Retorne que o produto esta vencido apresenta uma mensagem informando que nao pode ser vendido
			STFMessage("ItemRegistered","POPUP",STR0004) //"Venda não permitida. Data de validade do produto inválida"                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
			STFShowMessage("ItemRegistered")
			aRet[ITEM_ENCONTRADO] := .F. 
		Else		
			cInfProBal:= SubStr(cCodProd,8,5)
		EndIf
	
	EndIf
	
EndIf	

/*
	Se encontrou Item e encontrou Qtde > 1 Altera Qtde
*/
If aRet[ITEM_ENCONTRADO] .AND. aRet[ITEM_QTDE] > 0

	STBSetQuant(aRet[ITEM_QTDE])
	
EndIf

/*
	Se nao achou o Item ou esta Bloqueado add mensagem 
*/
lShowMsgBlock := lShowMsgBlock .and. !(IsInCallStack( 'STISearchProd' ) .Or. IsInCallStack( 'STBSearchPrice' ) .or. IsInCallStack( 'STBCnFindItem' )) 

If	!aRet[ITEM_ENCONTRADO]
	STFMessage("FindItem","STOP",STR0001)	 //"Item nao encontrado."
	If lShowMsgBlock
		STIBtnDeActivate()
		If lPEItmNVld
			ExecBlock( "STWItmNVld", .F., .F., {1, cCodeReceived, ""} )
		Else
			STWMsgNoBut(STR0002 + cCodeReceived +  STR0005) //"Item: " //" não encontrado."
		EndIF
		STIBtnActivate()
	EndIf
EndIf		

If	aRet[ITEM_BLOQUEADO]
	STFMessage("FindItem","STOP",STR0002 + aRet[ITEM_CODIGO] +  STR0003)	 //"Item: " //" Bloqueado."
    If lShowMsgBlock
		STIBtnDeActivate()
		If lPEItmNVld
			ExecBlock( "STWItmNVld", .F., .F., {2, cCodeReceived, aRet[ITEM_CODIGO]} )
		Else
			STWMsgNoBut(STR0002 + aRet[ITEM_CODIGO] +  STR0003)
		Endif
		STIBtnActivate()
	EndIf
EndIf		
				
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STWMSGNOBUT
Tela de mensagem do item não localizado

@param   cMsg          Mensagem mostrada
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STWMsgNoBut(cMsg)

Local oDlgIt  := Nil //Obj tela
Local oEditIt := Nil //Objeto para texto apresentada na tela

DEFINE FONT oFontIt NAME "Courier New" SIZE 14,32

DEFINE MSDIALOG oDlgIt TITLE "" FROM 000, 000  TO 110, 500 COLORS 0, 16777215 PIXEL

oEditIt:= TSimpleEditor():New(005,005,oDlgIt,240,35,,.T.,,oFontIt,.T.)
oEditIt:TextFormat(2)
oEditIt:Load(Space(2)+cMsg+" (ESC)")

ACTIVATE MSDIALOG oDlgIt CENTERED

Return


