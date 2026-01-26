#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STDBONUSSALES.CH"

Static aUsedRules := {}

//--------------------------------------------------------
/*{Protheus.doc} STDBonusProduto
Busca o produto que sera contemplado pela regra de bonificacao e seta a quantidade.
@param		cRegraBon		Codigo da regra de bonificacao

@author  Varejo
@version P11.8
@since   22/08/2012
@return  cRet - Codigo do Produto
@obs     
@sample
*/
//--------------------------------------------------------
Function STDBonusProduto(cRegraBon)

Local aArea		:= GetArea()	// Guarda area
Local cRet 		:= ""			// Retorno	
Local nQuant  	:= 0			// quantidade

Default cRegraBon	:= ""	// Codigo da regra de bonificacao

ParamType 0 Var cRegraBon 	AS Character	Default ""

DbSelectArea("ACQ")
ACQ->(DbSetOrder(1))
If ACQ->(MsSeek(xFilial("ACQ")+cRegraBon))
	cRet := ACQ->ACQ_CODPRO 
	nQuant := ACQ->ACQ_QUANT
	
	STBSetQuant(nQuant)
EndIf

RestArea(aArea)

Return cRet


//--------------------------------------------------------
/*{Protheus.doc} STDQuantProd
Retorna a quantidade total do produto que esta contido na cesta.
@param   cProd - Codigo do produto que esta sendo registrado
@author  Varejo
@version P11.8
@since   22/08/2012
@return  nRet Quantidade do produto
@obs     
@sample
*/
//--------------------------------------------------------
Function STDQuantProd(cProd)

Local nX     := 0
Local nRet   := 0 
Local oCesta := STDGPBModel()

Default cProd	:= ""	// Codigo da regra de bonificacao

ParamType 0 Var cProd 	AS Character	Default ""

oCesta := oCesta:GetModel("SL2DETAIL")

For nX := 1 To STDPBLength("SL2")
	
	oCesta:GoLine(nX)
	If cProd == STDGPBasket( "SL2" , "L2_PRODUTO" , nX ) .AND. !oCesta:IsDeleted()
		nRet += STDGPBasket( "SL2" , "L2_QUANT" , nX )
	EndIf
	
Next nX

Return nRet

//--------------------------------------------------------
/*{Protheus.doc} STDBSFilter
Filtra as regras de bonificacao que contem o item que esta sendo registrado

@param   nItemLine - Numero do item da venda
@author  Varejo
@version P11.8
@since   22/08/2012
@return  Nil
@obs     
@sample
*/
//--------------------------------------------------------
Function STDBSFilter( nItemLine )
Local aArea         := GetArea()
Local cCodigo 		:= STDGPBasket( "SL2" , "L2_PRODUTO" , nItemLine )
Local cGrupoProd	:= Posicione("SB1",1,xFilial("SB1")+cCodigo,"B1_GRUPO")
Local cFilter       := ""
Local aRet			:= {}
Local cKey          := ""

If !Empty(cGrupoProd)
	cFilter := "'" + AllTrim(cCodigo) + "' == AllTrim(ACR->ACR_CODPRO) .OR. '" + AllTrim(cGrupoProd) + "' == AllTrim(ACR->ACR_GRUPO)"
Else
	cFilter := "'" + AllTrim(cCodigo) + "' == AllTrim(ACR->ACR_CODPRO)"
EndIf

DbSelectArea("ACR")
ACR->(DbSetOrder(1)) // ACR_FILIAL+ACR_CODREG+ACR_ITEM
If ACR->(!EOF())
	ACR->(DbGoTo(ACR->(LastRec())+1))
EndIf
ACR->(DbSetFilter({ || &cFilter }, cFilter))
ACR->(DbSkip(-1))

While ACR->(!BOF())
	
	cKey := ACR->ACR_FILIAL+ACR->ACR_CODREG
	If aScan(aRet,cKey) == 0
		Aadd(aRet,cKey)
	EndIf
	ACR->(DbSkip(-1))
End
ACR->(DbClearFilter())

RestArea(aArea)

Return aRet


//--------------------------------------------------------
/*{Protheus.doc} STDSetBonusQuantidade
Seta a quantidade do produto que sera bonificado. Ao chamar esta rotina, todas as validacoes ja devem ter sido realizadas.

@param   cRegraBon - Codigo da regra de bonificacao
@author  Varejo
@version P11.8
@since   22/08/2012
@return  Nil
@obs     
@sample
*/
//--------------------------------------------------------
Function STDSetBonusQuantidade(cRegraBon)

Local aArea    		:= GetArea()	// Guarda area
Local nQuant   		:= 0  			// Quantidade a ser bonificada
Local nLote	 		:= 0  			// Numero de itens a ser comprados para bonificar
Local nComprados 	:= 0  			// Numero de itens comprados
Local nMultiplo		:= 0  			// Multiplicador
Local lLoteCab 		:= .F.			// Indica se utiliza o lote do cabecalho
Local cTipoBon 		:= "" 			// Tipo da bonificacao
Local lAccBonus     := SuperGetMv("MV_TPBONUS",.F.,.T.) // Indica se a regra de bonificacao sera acumulada ou nao
Local nTimesUsed    := 0
Local nPosRegra     := 0

If Len(aUsedRules) > 0
	nPosRegra := aScan(aUsedRules,{|x| AllTrim(x[1]) == AllTrim(cRegraBon)})
	If nPosRegra > 0
		nTimesUsed := aUsedRules[nPosRegra,2]
	EndIf
EndIf

Default cRegraBon	:= ""			// Codigo da regra de bonificacao

ParamType 0 Var cRegraBon 	AS Character	Default ""

DbSelectArea("ACQ")
ACQ->(DbSetOrder(1))
If ACQ->(MsSeek(xFilial("ACQ")+cRegraBon))
	nQuant 		:= ACQ->ACQ_QUANT
	cTipoBon 		:= ACQ->ACQ_TPRGBN
	nLote 			:= ACQ->ACQ_LOTE
EndIf

If nLote > 0
	lLoteCab 	:= .T.
EndIf

DbSelectArea("ACR")
ACR->(DbSetOrder(1)) // ACR_FILIAL+ACR_CODREG+ACR_ITEM
If ACR->(MsSeek(xFilial("ACR")+cRegraBon))
	While !EOF() .AND. ACR->ACR_FILIAL == xFilial("ACR") .AND. ACR->ACR_CODREG == cRegraBon	
	
		If cTipoBon == "1" // Caso todos os produtos da regra tenham de ser vendidos.
			
			If lLoteCab				
				nComprados += STDQuantProd(ACR->ACR_CODPRO)						
			Else
				nComprados := STDQuantProd(ACR->ACR_CODPRO)
				
				If nMultiplo > 0
					/*
					 Como todos os produtos devem ser comprados, apenas o menor multiplicador sera considerado
					 Ex: Lote do produto A = 10 e Lote do produto B = 10 bonificam 1 unidade do produto C
					 Caso 50 produtos A sejam vendidos e apenas 10 produtos B sejam vendidos, apenas 1 produto C deve ser bonificado			     
					*/
					If nMultiplo > Int(nComprados/ACR->ACR_LOTE) 
						nMultiplo := Int(nComprados/ACR->ACR_LOTE)
					EndIf
				Else
					nMultiplo := Int(nComprados/ACR->ACR_LOTE)
				EndIf
			EndIf
		
			
		ElseIf cTipoBon == "2"
		
			If lLoteCab
				nComprados += STDQuantProd(ACR->ACR_CODPRO)
			Else
				nComprados := STDQuantProd(ACR->ACR_CODPRO) // quantidade de determinado produto
				
				If lAccBonus // Indica se a bonificacao sera acumulada 
					
					// Se acumula, apenas incremento o multiplicador
					nMultiplo += Int(nComprados/ACR->ACR_LOTE)
				Else
					// Se nao acumular, considero apenas o maior multiplicador
					If Int(nComprados/ACR->ACR_LOTE) > nMultiplo
						nMultiplo := Int(nComprados/ACR->ACR_LOTE)
					EndIf
				EndIf				
			EndIf		
		EndIf		
		ACR->(DbSkip())
	EndDo
	
	If lLoteCab // Se utilizar o lote do cabecalho, o nMultiplo nao pode ser calculado durante o laco
		nMultiplo := Int(nComprados/nLote)
	EndIf
	
	If lAccBonus
		If nTimesUsed == 1 .AND. nMultiplo > 1
			nQuant := nQuant * nMultiplo
			aUsedRules[nPosRegra,2] := nMultiplo
		ElseIf nMultiplo > nTimesUsed
			nTimesUsed-= 1
			nMultiplo -= nTimesUsed
			If nMultiplo > 1
				nQuant := nQuant * nMultiplo
				aUsedRules[nPosRegra,2] += (nMultiplo-1)
			EndIf
		EndIf
	EndIf
	
EndIf

STBSetQuant(nQuant)

RestArea(aArea)

Return nQuant

//--------------------------------------------------------
/*{Protheus.doc} STDBSGtQtd
Retorna o lote de quantidade do produto passado via parametro

@author  Varejo
@version P11.8
@since   28/10/2013
@return  Nil
*/
//--------------------------------------------------------
Function STDBSGtQtd( cRegraBon, cCodProd )
Local aArea       := GetArea()
Local nRet        := 0

Default cRegraBon := "" // Codigo da regra de bonificacao que esta sendo avaliada
Default cCodProd  := "" // Codigo do produto a ser buscado

If !Empty(cRegraBon) .AND. !Empty(cCodProd)

	DbSelectArea("ACR")
	ACR->(DbSetOrder(1)) // ACR_FILIAL+ACR_CODREG+ACR_ITEM
	If DbSeek(xFilial("ACR")+cRegraBon)
		While (xFilial("ACR")+cRegraBon) == ACR->ACR_FILIAL+ACR->ACR_CODREG .AND. ACR->(!EOF())
			If ACR->ACR_CODPRO == cCodProd
				nRet := ACR->ACR_LOTE
				Exit
			EndIf
			ACR->(DbSkip())
		End	
	EndIf

EndIf

RestArea(aArea)

Return nRet

//--------------------------------------------------------
/*{Protheus.doc} STDBS7Rules
Seta a variavel static que guarda as regras de bonificacao utilizadas, alem do numero de vezes que ela foi utilizada.

@author  Varejo
@version P11.8
@since   28/10/2013
@return  Nil
*/
//--------------------------------------------------------
Function STDBS7Rules( aRules )

DEFAULT aRules := {}

aUsedRules := aRules

Return

//--------------------------------------------------------
/*{Protheus.doc} STDBSGetRules
Limpa a variavel static que guarda as regras de bonificacao utilizadas

@author  Varejo
@version P11.8
@since   28/10/2013
@return  Nil
*/
//--------------------------------------------------------
Function STDBSGetRules( )

Return aUsedRules

//--------------------------------------------------------
/*{Protheus.doc} STDPesqMei
Pesquisa as regras de desconto ativas e que sejam
regras de desconto por item

@author  Bruno Almeida
@version P12
@since   26/08/2019
@return  aMei -> Retorno das regras ativas
*/
//--------------------------------------------------------
Function STDPesqMei()

Local aMei := {} //Variavel de retorno
Local cCustomer	:= STDGPBasket("SL1","L1_CLIENTE")
Local cLoja	 	:= STDGPBasket("SL1","L1_LOJA")
Local lSTDValRule := ExistFunc("STDVALRULE")	//Ver se está em Function antes de executar
Local aArea       := GetArea()

If lSTDValRule
	dbSelectArea('MEI')
	MEI->(DbSetOrder(1)) //MEI_FILIAL+MEI_CODREG
	MEI->(DbSeek(xFilial('MEI')))
	
	While MEI->(!EOF()) .AND. MEI->MEI_FILIAL == xFilial('MEI')
		If MEI->MEI_ATIVA = "1" .AND. MEI->MEI_TPIMPD == "I" .AND. STDValRule( cCustomer , cLoja ) // Validacao generica por Data, Ativa, Cliente, Grupo de cliente, Filial e Prioridade
			aAdd(aMei,MEI->MEI_CODREG)
		EndIf
		MEI->(DbSkip())
	End
Else
	MsgAlert(STR0001)	//"Necessário que o RPO esteja com o fonte STDRuleDiscount.prw atualizado a partir de 01/11/2019!"
EndIf

RestArea(aArea)
Return aMei

//--------------------------------------------------------
/*{Protheus.doc} STDPesqMb8
Pesquisa em determina regra de desconto se determinado
produto esta contido naquela regra e se eh de bonificacao

@author  Bruno Almeida
@version P12
@since   26/08/2019
@return  lRet -> Retorna .T. se encontrou
*/
//--------------------------------------------------------
Function STDPesqMb8(cCodReg, cCodProd, cCodCat)

Local lRet := .F. //Variavel de retorno
Local aArea       := GetArea()

Default cCodReg		:= ""
Default cCodProd 	:= ""
Default cCodCat		:= ""		//Retorno Código de Categoria

dbSelectArea('MB8')
If !Empty(cCodCat)		//Pesquisa Categoria
	MB8->(DbSetOrder(3)) //MB8_FILIAL+MB8_CATEGO
	If MB8->(DbSeek(xFilial('MB8')+cCodCat)) .AND. MB8->MB8_TPREGR = '2'
		lRet := .T.
	EndIf
Else
	MB8->(DbSetOrder(4)) //MB8_FILIAL+MB8_CODREG+MB8_CODPRO
	If MB8->(DbSeek(xFilial('MB8')+cCodReg+cCodProd)) .AND. MB8->MB8_TPREGR = '2'
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)
Return lRet

//--------------------------------------------------------
/*{Protheus.doc} STDPesqMgb
Retorna qual sera o produto que sera bonificado para o
cliente

@author  Bruno Almeida
@version P12
@since   26/08/2019
@return  aRetMgb -> Contem o produto que sera bonificado
*/
//--------------------------------------------------------
Function STDPesqMgb(cCodReg, cIdProd)

Local aRetMgb := {}
Local aArea       := GetArea()

Default cCodReg	:= ""
Default cIdProd	:= ""

dbSelectArea('MGB')
MGB->(DbSetOrder(1)) //MGB_FILIAL+MGB_CODREG+MGB_IDPROD
MGB->(DbSeek(xFilial('MGB')+cCodReg+cIdProd))

While MGB->(!EOF()) .AND. AllTrim(MGB->MGB_FILIAL+MGB_CODREG+MGB_IDPROD) == AllTrim(xFilial('MGB')+cCodReg+cIdProd)
	aAdd(aRetMgb,{MGB->MGB_CODPROD,MGB->MGB_QTDPRO})
	MGB->(DbSkip())
End

RestArea(aArea)
Return aRetMgb
