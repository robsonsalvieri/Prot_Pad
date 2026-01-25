#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"   

Static lPDVOnline	:= ExistFunc("STFGetOnPdv") .AND. STFGetOnPdv()	// Variável para definir se o totvs PDV está no modo online
//-------------------------------------------------------------------
/*/{Protheus.doc} STDFinishSale
Componente de gravacao de dados no Model e persistencia do Model no banco de dados.
@param lEmiteNFe, Indica se esta emitindo NF-e  
@param lRetArea , Indica se a função STWVldRgNfe() retornou a area.
@author  Varejo
@version P11.8
@since   09/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDFinishSale(lEmiteNFe, lRetArea)

Local lRMS		:= SuperGetMv("MV_LJRMS",,.F.) 	//Integracao RMS ativada
Local cRetorno	:= ""							//Retorno da data da impressora
Local lCentPDV	:= LjGetCPDV()[1]				//Server é Central de Pdv - 
												//Permitido Somente quando o Totvs Pdv é Online 	

Default lEmiteNFe := .F. // Se emite NF-e
Default lRetArea  := .F. // Se teve area selecionada no retorno da função STWVldRgNfe()

If STDGPBasket("SL1","L1_TIPO") == "P" .And. Empty(STDGPBasket("SL1","L1_PEDRES")) .And. !Empty(STDGPBasket("SL1","L1_ORCRES"))
	STDSPBasket("SL1","L1_TIPO"   , "P")
Else
	STDSPBasket("SL1","L1_TIPO"   , "V")
EndIf
If SL1->(FieldPos("L1_TIMEATE")) > 0 .AND. ValType(STDGPBasket("SL1","L1_TIMEATE")) == 'N'
	STDSPBasket("SL1","L1_TIMEATE"	, Seconds() - STDGPBasket("SL1","L1_TIMEATE") )
EndIf

If STBGetNFCe()
    STDSPBasket("SL1", "L1_HORA", SL1->L1_HORA)
ElseIf !STFGetCfg("lPafEcf") .AND. !lRMS
	STDSPBasket("SL1","L1_HORA"   	, Left(Time(),TamSX3("L1_HORA")[1]) )
EndIf	

STDSPBasket("SL1","L1_VALPIS" 	, STBTaxRet(Nil,"NF_VALPIS"))
STDSPBasket("SL1","L1_VALCOFI"	, STBTaxRet(Nil,"NF_VALCOF"))
STDSPBasket("SL1","L1_VALCSLL"	, STBTaxRet(Nil,"NF_VALCSL"))

If ExistBlock("STSaleComp")
	/* 
		P.E com objetivo de gravar alguma informação complementar na venda antes de subir para a retaguarda.
		Sera executado no final da venda, depois que já transmitiu o documento e antes de gravar o L1_SITUA = 00
	*/
	LjGrvLog( "L1_NUM: " + STDGPBasket('SL1','L1_NUM'), "Antes P.E STSaleComp | L1_SITUA: " + STDGPBasket('SL1','L1_SITUA') )
	ExecBlock("STSaleComp",.F.,.F.,{STDGPBasket('SL1','L1_FILIAL'),STDGPBasket('SL1','L1_NUM'),STDGPBasket('SL1','L1_DOC'),STDGPBasket('SL1','L1_SERIE')}) //Filial, número do orçamento, doc. e série
	LjGrvLog( "L1_NUM: " + STDGPBasket('SL1','L1_NUM'), "Depois P.E STSaleComp | L1_SITUA: " + STDGPBasket('SL1','L1_SITUA') )
EndIf

If lPDVOnline
	If lEmiteNFe .AND. !lCentPDV
		STDSPBasket("SL1","L1_SITUA", "OK")
	Elseif lCentPDV //Se Totvs Pdv está conectado no Central de Pdv L1_SITUA deve ser "CP" para que Central envie a venda para RET.
		STDSPBasket("SL1","L1_SITUA", "CP")
	Else
		STDSPBasket("SL1","L1_SITUA", "RX")
	EndIf
Else
	STDSPBasket("SL1","L1_SITUA", "00")
EndIf
STDSPBasket("SL1","L1_CONFVEN"	, "SSSSSSSSNSSS")

if !lEmiteNFe
	STDSPBasket("SL1","L1_IMPRIME"	, "1S")
Endif 


If lRMS
	nRet := STWPrinterStatus( '19', @cRetorno )
	If nRet <> 1 .AND. !Empty(cRetorno)
		STDSPBasket("SL1","L1_DTMOV" 	, CToD(cRetorno) )
	Else
		STDSPBasket("SL1","L1_DTMOV" 	, dDataBase )
	EndIf	
	STDSPBasket("SL1","L1_DTFIM"	, Date())	
	STDSPBasket("SL1","L1_HRFIM"	, SubStr(Time(),1,8))		
EndIf

// Doação para o Instituto Arredondar
If SL1->(FieldPos( "L1_VLRARR" )) > 0
	STIInsArrTax(STDGPBasket("SL4","L4_FORMA"),STDGPBasket("SL4","L4_ADMINIS"))
	STDSPBasket("SL1","L1_VLRARR", STBGetDInsArr())	//Valor com desconto
EndIf

If Empty(STDGPBasket("SL1","L1_CONDPG"))
	STDSCondPG("CN")
EndIf

//STDSPBasket("SL1","L1_TABELA" ,  ) TODO:
//STDSPBasket("SL1","L1_NUMORC" ,  )
//STDSPBasket("SL1","L1_TPORC"  ,  )

LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Faz gravação final da venda." )  //Gera LOG

/* Quando a variavel lRetArea está como .T. significa que é PDV online com importação de orçamento
com retira ou entrega, quando temos emissão de NF-e no PDV online processamos a venda pelo mini gravabatch,
com isso toda a venda já está processada neste momento, por esse motivo não chamamos a função STDSaveSale(). 
No caso da central com PDV online ele atualiza a situação para CP e o job processa a venda, por esse motimo deve ser chamado.
*/
If !(lRetArea .And. lEmiteNFe .And. !LjGetCPDV()[1])  
	STDSaveSale()
EndIf

//Quando é PDV Online e for recebimento de mais de um orçamento, precisa atualizar os registros 
//da SL1 originais. mais detalhes vide a propria rotina TDAltRegL1()
If (lPDVOnline .AND. STBIsImpOrc() .AND. ExistFunc("STDAltRegL1"),STDAltRegL1(),NIL)
/*/
	Motivo de Desconto
/*/

STDUpdReason(STDGPBasket( "SL1", "L1_DOC" ),STDGPBasket( "SL1", "L1_SERIE" )) // -- Atualiza DOC apos emissão. 
STDRecReason()

/*/
	Motivo de Venda Perdida
/*/
STDRecLostSale()

/*/
	Desconto na próxima venda
/*/
STDRecNextSaleDiscount()

/*/
	Verifica se houve cancelamento de item na venda para ajustar a SLX
/*/
If ExistFunc('STDAjstSLX')
	STDAjstSLX(SL1->L1_DOC)
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} STDSaveSale
Faz a persistencia dos dados nas tabelas SL1, SL2 e SL4.

@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSale[1]				Retorna Cabeçalho da Venda (SL1)
@return  aSale[2]				Retorna Itens da Venda (SL2)
@return  aSale[3]				Retorna Formas de Pagamento da venda (SL4)
@obs     
@sample
*/
//-------------------------------------------------------------------

Function STDSaveSale(nItemLine,lCancel,lBrinde)

Local aArea			:= GetArea()
Local aRows			:= FwSaveRows()
Local oModel 		:= STDGPBModel()
Local aSL1Fields	:= oModel:GetModel("SL1MASTER"):GetStruct():GetFields()
Local aSL2Fields	:= oModel:GetModel("SL2DETAIL"):GetStruct():GetFields()
Local aSL4Fields	:= oModel:GetModel("SL4DETAIL"):GetStruct():GetFields()
Local cField		:= ""
Local nX			:= 0
Local nY			:= 0
Local lIsPAF		:= STBIsPAF()
Local lMD5SL1		:= lIsPAF .AND.  SL1->(ColumnPos("L1_PAFMD5")) > 0
Local lMD5SL2		:= lIsPAF .AND.  SL2->(ColumnPos("L2_PAFMD5")) > 0
Local lMD5SL4		:= lIsPAF .AND.  SL4->(ColumnPos("L4_PAFMD5")) > 0
Local cPAFMD5			:= ""
Local uValor		:= ""
Local cFieldSL4		:= "" //Quarda Valor dos campos da SL4 na inclusao para Log
Local cTipouValor	:= "" // Tipo da variavel uValor
Local cValorField	:= "" // Valor da variavel uValor em caracter
Local lFoundSL2		:= .F.

DEFAULT nItemLine := 0
DEFAULT lCancel   := .F.
DEFAULT lBrinde   := .F.


Begin Transaction

	DbSelectArea("SL1")
	SL1->(DbSetOrder(1))
	
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Grava tabela SL1 | L1_SITUA: " + STDGPBasket('SL1','L1_SITUA') )  //Gera LOG
		
	If SL1->( DbSeek(xFilial("SL1") + oModel:GetValue("SL1MASTER", "L1_NUM")) )
		RecLock("SL1",.F.)
	Else
		RecLock("SL1",.T.)
	EndIf
	
	For nX := 1 To Len(aSL1Fields)
		cField := aSL1Fields[nX,MODEL_FIELD_IDFIELD]
		REPLACE &(cField) WITH STDGPBasket( "SL1" , cField )
	Next nX
	
	If lMD5SL1	
		cPAFMD5 := STBPAFMD5("SL1")
		REPLACE SL1->L1_PAFMD5 WITH cPAFMD5
	EndIf

	SL1->(MsUnlock())
	SL1->(ConfirmSX8())
	
	LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Quantidade de itens no Model da tabela SL2", oModel:GetModel("SL2DETAIL"):Length() )  //Gera LOG
	
	
	If nItemLine > 0
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1)) //L2_FILIAL + L2_NUM + L2_ITEM + L2_PRODUTO
		oModel:GetModel("SL2DETAIL"):GoLine(nItemLine)
		
		lFoundSL2 := SL2->(DbSeek(xFilial("SL2") + oModel:GetValue("SL1MASTER" , "L1_NUM") + STDGPBasket( "SL2" , "L2_ITEM" ))) 
		
		If !oModel:GetModel("SL2DETAIL"):IsDeleted() .Or. lIsPAF

			If oModel:GetModel("SL2DETAIL"):IsDeleted()
				SET DELETED OFF 
				lFoundSL2 := SL2->(DbSeek(xFilial("SL2") + oModel:GetValue("SL1MASTER" , "L1_NUM") + STDGPBasket( "SL2" , "L2_ITEM" )),.T.)	
				SET DELETED ON
			EndIf

			If lFoundSL2
				LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Tabela SL2 - Alteração do item", SL2->L2_ITEM )  //Gera LOG
				//// Caso o item seja cancelado, Eh alterado o L2_SITUA para sinalizar que o mesmo esta deletado.
				RecLock("SL2",.F.)//alteracao
			Else
				LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Tabela SL2 - Inclusão de novo item", SL2->L2_ITEM )  //Gera LOG
				RecLock("SL2",.T.)//Inclusao			
			EndIf
			
			For nX := 1 To Len(aSL2Fields)
				cField := aSL2Fields[nX,MODEL_FIELD_IDFIELD]
				REPLACE &(cField) WITH STDGPBasket( "SL2" , cField )
			Next nX
			
			If lMD5SL2	
				cPAFMD5 := STBPAFMD5("SL2")
				REPLACE L2_PAFMD5 WITH cPAFMD5
			EndIf

			SL2->(MsUnlock())
			
			If lCancel .AND. lFoundSL2
				RecLock("SL2",.F.)
					SL2->( DbDelete() )
				SL2->(MsUnlock())
			EndIf
		Else
			If lCancel .AND. lFoundSL2
				RecLock("SL2",.F.)
					SL2->( DbDelete() )
				SL2->(MsUnlock())
			EndIf
		EndIf 
		
		LjGrvLog("L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "L2_PRODUTO " , SL2->L2_PRODUTO)  //Gera LOG
	
	EndIf
	
	/*/
		Se L1_SITUA for igual a '10', significa que o SL2 ja foi salvo e nao sera alterado
	/*/
	
	If oModel:GetValue("SL1MASTER" , "L1_SITUA") $ "10|65"
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "L1_SITUA 10|65")  //Gera LOG
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1))
		SL2->( dbGoTop() )
		For nX := 1 To oModel:GetModel("SL2DETAIL"):Length()
			oModel:GetModel("SL2DETAIL"):GoLine(nX)
			
			If oModel:GetModel("SL2DETAIL"):IsDeleted(nX) ;
			.AND. SL2->( DbSeek(xFilial("SL2") + oModel:GetValue("SL1MASTER", "L1_NUM") + STDGPBasket("SL2", "L2_ITEM")) ) ;
			.AND. STDGPBasket("SL2" , "L2_VENDIDO") == "N"

				While SL2->( !EoF() ) .AND.( xFilial("SL2") + oModel:GetValue("SL1MASTER", "L1_NUM") + STDGPBasket("SL2", "L2_ITEM" ) == SL2->L2_FILIAL + SL2->L2_NUM + SL2->L2_ITEM)

					If SL2->L2_VENDIDO == "N"
						RecLock("SL2",.F.)
						SL2->( DbDelete() )
						SL2->( MsUnlock() )
					EndIf
					SL2->(DbSkip())
					
				End

			EndIf
		Next nX
	EndIf
	
	/*/
		Se L1_SITUA for igual a '10', significa que o SL4 ja foi salvo e nao sera alterado
	/*/
	
	If oModel:GetValue("SL1MASTER" , "L1_SITUA") == "10"  .AND. nItemLine == 0
		DbSelectArea("SL4")
		SL4->(DbSetOrder(1))	//L4_FILIAL + L4_NUM
		If ExistFunc("STDDelPay") .And. SL4->( DbSeek(xFilial("SL4") + oModel:GetValue("SL1MASTER", "L1_NUM")) ) // é recuperação de venda e já gravou L4
 			While !Eof() .AND. (L4_FILIAL + L4_NUM) == (xFilial("SL4") + oModel:GetValue("SL1MASTER" , "L1_NUM"))
 		  		STDDelPay(oModel:GetValue("SL1MASTER", "L1_NUM")) //deletar o registro da SL4 anterior
 		  		SL4->( DbSkip() )
			EndDo
 		EndIf
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Quantidade de itens no Model da tabela SL4", oModel:GetModel("SL4DETAIL"):Length() )  
		LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Quantidade de Campos no Model da tabela SL4: " + AllTrim(STR(Len(aSL4Fields))) )
		If STDPBLength("SL4") > 0		
			DbSelectArea("SL4")
			SL4->( DbSetOrder(1) )//L4_FILIAL+L4_NUM+L4_ORIGEM
			For nX := 1 To STDPBLength("SL4") 
				oModel:GetModel("SL4DETAIL"):GoLine(nX)
				
				//Verificação para não gravar linha em branco na SL4 (Gravava em branco quando utilizado NCC).
				If !Empty(STDGPBasket( "SL4" , "L4_FORMA"))
					
					cFieldSL4 := ""
					
					If RecLock("SL4",.T.)
						For nY := 1 To Len(aSL4Fields)
							cField := aSL4Fields[nY,MODEL_FIELD_IDFIELD]
							uValor	:= STDGPBasket( "SL4" , cField)
							REPLACE SL4->&(cField) WITH uValor
							
							cTipouValor	:= AllTrim( UPPER( ValType(uValor) ))
							If cTipouValor == "U" 
								cValorField := "Indefinido"
							Else
								cValorField := AllTrim(cValToChar(uValor))	
							EndIf	
							cFieldSL4 += cField+"=" + cValorField + " | "
						Next nY
			
						If lMD5SL4					
							//REPLACE L4_DOC WITH oModel:GetValue("SL1MASTER" , "L1_DOC")
							cPAFMD5 := STBPAFMD5("SL4")
							REPLACE SL4->L4_PAFMD5 WITH cPAFMD5
							cFieldSL4 += "L4_PAFMD5=" + cPAFMD5
						EndIf
						SL4->(MsUnlock())
					Else
						LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Falha no RecLock do alias SL4" )
					EndIf	
				Else
					LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Forma de pagamento vazia L4_FORMA")  
				EndIf
	
			Next nX
		Else
			LjGrvLog( "L1_NUM: "+STDGPBasket('SL1','L1_NUM'), "Não existem parcelas a gravar na Tabela SL4" )	
		EndIf	

	ElseIf oModel:GetValue("SL1MASTER" , "L1_SITUA") == "00" .AND. !Empty( oModel:GetValue("SL1MASTER" , "L1_CONTONF") )

		DbSelectArea("SL4")
		SL4->(DbSetOrder(1))	//L4_FILIAL + L4_NUM
		If SL4->( DbSeek(xFilial("SL4") + oModel:GetValue("SL1MASTER", "L1_NUM")) )
			While SL4->( !Eof() ) .AND. (L4_FILIAL + L4_NUM) == (xFilial("SL4") + oModel:GetValue("SL1MASTER" , "L1_NUM"))
				If !Empty(L4_DATATEF)
					RecLock("SL4", .F.)
					
					If SL4->(FieldPos("L4_CONTONF")) > 0
						REPLACE L4_CONTONF With oModel:GetValue("SL1MASTER" , "L1_CONTONF")
					EndIf
					
					If SL4->(FieldPos("L4_DOC")) > 0
						REPLACE L4_DOC WITH STBRetCup() 
					EndIf
					
					If lMD5SL4	
						cPAFMD5 := STBPAFMD5("SL4")
						REPLACE L4_PAFMD5 WITH cPAFMD5
					EndIf
					SL4->(MsUnLock())
				EndIf
				SL4->( DbSkip() )
			EndDo

		EndIf
	EndIf
	
End Transaction

RestArea(aArea)
FwRestRows(aRows)

// Limpa os vetores para melhor gerenciamento de memoria (Desaloca Memória)
aSize( aRows, 0 )
aRows := Nil

Return


//-------------------------------------------------------------------
/*{Protheus.doc} STDGrvMGX
Grava forma de pagamento e valor na tabela de controle para limite de Sangria.

@param 
@author  Varejo
@version P12
@since   16/01/2015
@return  .T.
@obs     
@sample
*/
//-------------------------------------------------------------------

Function STDGrvMGX()

Local oModel 			:= STDGPBModel() // Objeto Model 
Local nX				:= 0 // Contador de registros SL4
Local nValor 			:= 0 // Valor atual do campo MGX_VALOR posicionado
Local aArea			:= GetArea() 

// Gravação da Tabela MGX para controle de Limite de Sangria 
For nX := 1 To oModel:GetModel("SL4DETAIL"):Length()
	oModel:GetModel("SL4DETAIL"):GoLine(nX)
	DbSelectArea("MGX")
	DbSetOrder(1) // MGX_FILIAL+MGX_FPAGTO+DTOS(MGX_DATA)
	If DbSeek (xFilial("MGX") + Substr(oModel:GetValue("SL4DETAIL" , "L4_FORMA"),1,3))
		Reclock("MGX", .F.) // Alteração
		oModel:GetModel("SL4DETAIL"):GoLine(nX)
		MGX->MGX_FPAGTO := oModel:GetValue("SL4DETAIL" , "L4_FORMA")			
		nValor := MGX->MGX_VALOR		
		MGX->MGX_VALOR := (nValor + oModel:GetValue("SL4DETAIL" , "L4_VALOR"))
	Else	
		Reclock("MGX", .T.) // Inclusão
		oModel:GetModel("SL4DETAIL"):GoLine(nX)
		MGX->MGX_FPAGTO := oModel:GetValue("SL4DETAIL" , "L4_FORMA")
		MGX->MGX_VALOR := oModel:GetValue("SL4DETAIL" , "L4_VALOR")
	EndIf
Next nX
MsUnlock()		
		
RestArea(aArea)			

Return .T.

//-------------------------------------------------------------------
/*{Protheus.doc} STDNfCeSt
Alimenta as variáveis estáticas utilizadas na nfce

@param 
@author  Varejo
@version P1180
@since   15/04/2015
@return  .T.
@obs     
@sample
*/
//-------------------------------------------------------------------

Function STDNfCeSt()
Local oModel 		:= STDGPBModel() //Model da Venda
Local nX := 0		//Variavel Contadora
Local aNFCeICMST := {} //Array de Dados da NFCe ST
Local aArea := GetArea() //WorkArea


DbSelectArea("SL2")
SL2->( DbSetOrder(1) )
SL2->( dbGoTop() )
For nX := 1 To oModel:GetModel("SL2DETAIL"):Length()
	oModel:GetModel("SL2DETAIL"):GoLine(nX)
	If !oModel:GetModel("SL2DETAIL"):IsDeleted(nX) .AND.;
		 SL2->( DbSeek(xFilial("SL2") + oModel:GetValue("SL1MASTER", "L1_NUM") + STDGPBasket("SL2", "L2_ITEM")) ) 

		While SL2->( !EoF() ) .AND. ;
		xFilial("SL2") + oModel:GetValue("SL1MASTER", "L1_NUM") + STDGPBasket("SL2", "L2_ITEM") == SL2->L2_FILIAL + SL2->L2_NUM + SL2->L2_ITEM
			aNFCeICMST := Array(2)
			
			aNFCeICMST[1] := STDGPBasket( "SL2" , "L2_ITEM" )
			aNFCeICMST[2] := {}

			Aadd( aNFCeICMST[2], STBTaxRet(nX, "IT_MARGEM") )
			Aadd( aNFCeICMST[2], STBTaxRet(nX, "IT_PREDST") )
			Aadd( aNFCeICMST[2], STBTaxRet(nX, "IT_BASESOL"))
			Aadd( aNFCeICMST[2], STBTaxRet(nX, "IT_ALIQSOL"))
			Aadd( aNFCeICMST[2], STBTaxRet(nX, "IT_VALSOL") )
			
			//alimenta o array estatico (aICMSST) do LOJNFCE.PRW
			If FindFunction("LjSetICMST")
				LjSetICMST( aNFCeICMST )
			EndIf
		
			SL2->( DbSkip() )						
		End
		
	EndIf
Next nX

RestArea(aArea)

Return
