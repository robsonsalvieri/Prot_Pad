#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static cTablePrice 	:= "" //Codigo da tabela de preco
Static lMvConfCli 	:= SuperGetMV("MV_CONFCLI",,"N") == "S"

//--------------------------------------------------------
/*/{Protheus.doc} ValueTablePrice
Retorna o preco do item conforme esta na tabela, considerando quando retornar
o maior ou menor preco conforme o parametro MV_LJRETVL
@param cItemCode	Codigo do item
@param cCustomer	cliente
@param cFil			Filial
@param cStore		Loja
@param nMoeda		Moeda
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	nReturnPrice   Preco
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBValTbPr( cItemCode, cCustomer, cFil, cStore	,nMoeda , nQtde)

Local nX 			:= 0										//Variavel para o laco For
Local nRet			:= 	0										//Verifica se foi retornado o valor do item
Local aValues		:= {}										//Armazena temporariamente os valores do item
Local aArea			:= GetArea()								//Salva a area
Local oModel		:= STDGetData()								//Retorna o model
Local oRecords		:= oModel:GetModel("GridStr")				//Retorna os registros do grid
Local nReturnPrice	:= 0										//Retorna o resultado da funcao
Local cTabPad		:= Pad(SuperGetMv("MV_TABPAD"),TamSx3("DA0_CODTAB")[1])			// Parametro da tabela de preco padrao	
Local lCenVen		:= SuperGetMv("MV_LJCNVDA")					//Cenario de vendas
Local aTabsPrecos	:= {}										//tabelas de preço
Local nPos			:=0
Local cParam 		:= STBParam()[1] 							//Retorna o valor dos parametros para preco e se Retorna preco maior ou menor
Local cTabCli   	:= ""										//Preço de  tabela do cliente  
Local oCliModel 	:=  STDGCliModel()							//Model com as informacoes do cliente
Local cMvLjRetVl 	:= SuperGetMV("MV_LJRETVL",,"3")			//1=Retorna o menor preco de uma tabela | 2=Retorna o maior preco de uma tabela | 3=Considera preco da tabela configurada no parametro MV_TABPAD

Default cItemCode	:= ""
Default cCustomer	:= ""
Default cFil		:= ""
Default cStore		:= ""
Default nMoeda		:= 0
Default nQtde		:= 1

If lCenVen .And. FindFunction("STDTabsPre")

	If lMvConfCli .AND. !Empty(oCliModel:GetValue("SA1MASTER","A1_TABELA"))
		cTabCli := oCliModel:GetValue("SA1MASTER","A1_TABELA")
	Endif 

	aTabsPrecos := STDTabsPre(cItemCode, cMvLjRetVl, cTabCli)

	If cMvLjRetVl == "3" .AND. Len( aTabsPrecos ) > 0 .AND. aTabsPrecos[1][1] == "-999"

		nReturnPrice := -999 // Tabela fora de vigencia

	Else

		For nX := 1 To Len(aTabsPrecos)
			
			nRet := MaTabPrVen(aTabsPrecos[nX][1], cItemCode, nQtde, cCustomer,; 
									cStore, nMoeda, /*dDataVld*/, /*nTipo*/,/*lExec*/)

			If nRet > 0
				aAdd( aValues,{aTabsPrecos[nX][1], nRet} )
			EndIf

		Next nX
		 	
		CoNout('Cenario de vendas ativo, tabela de preco: ' + AllTrim(cTabPad))

	EndIf
	
Else
	//Apos verificar a variavel estatica, analisa se existe mais de 
	//uma tabela de preco ativa. Agora, verifica no MaTabPrVen      
	//se existe preco para esse produto 					              
	For nX := 1 To oRecords:LenGth()
		oRecords:GoLine(nX)
		nRet := MaTabPrVen(	oRecords:GetValue("DA0_CODTAB")	, cItemCode	, nQtde, cCustomer,; 
								cStore, nMoeda, /*dDataVld*/, /*nTipo*/,/*lExec*/)
		
		//Armazena no array aValores os possiveis valores para ser 
		//praticado para um produto. Esse array sera utilizado para
		//avaliar, caso o produto pertenca a mais de uma tabela de 
		//preco, para saber qual sera praticada.                   
		If nRet > 0
			aAdd( aValues,{ oRecords:GetValue("DA0_CODTAB")	,nRet} )
		EndIf
	Next nX
EndIf

//Sendo o aValores maior que um, significa que existe mais de 
//um preco possivel para um unico produto na venda           

If Len(aValues) > 0 .AND. nReturnPrice <> -999
	
	//Retornando os valores, ordena do menor para o maior para 
	//ser tomada a decisao posteriormente                     
	
	ASort(aValues,,,{|x,y| x[2]< y[2]})
	
	//Verifica o parametro MV_LJRETVL 
  	If cParam == "1" //utilizara o menor preco encontrado
  		nReturnPrice := aValues[1][2]
		STBSetTblPr(aValues[1][1]) 
  	ElseIf cParam == "2" //utilizara o maior valor encontrado
		nReturnPrice := aValues[Len(aValues)][2]	
		STBSetTblPr(aValues[Len(aValues)][1]) 
	elseIf cParam == "3" //utilizará a tbl de preço infoRmada no parÂmetro "MV_TABPAD"
		If !Empty(cTabCli)
			nPos := Ascan(aValues,{|x| x[1]== cTabCli})
		Endif 
		//caso retorne 0, garante o preço de tab padrão.
		If nPos == 0  
			nPos := Ascan(aValues,{|x| x[1]== cTabPad})
		Endif
		If ( nPos <> 0 )
			nReturnPrice := aValues[nPos,2]	
			STBSetTblPr(aValues[nPos,1]) 
		EndIf	  		
  	EndIf  		 
EndIf			
	
RestArea(aArea)
	
Return nReturnPrice


//--------------------------------------------------------
/*/{Protheus.doc} STBParam
Retorna o valor dos parametros para preco do SB0 e se Retorna preco maior ou menor

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	cMvLjRetVl -  Informa se retorna o maior ou menor preco 
@return  	lLjCnVB0 - Retorna preço da SB0 na ausencia do preço do Produto
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBParam()

Local cMvLjRetVl 	:= SuperGetMv("MV_LJRETVL",,"1")											//Parametro que verifica se deve retornar o maior ou menor preco
Local lLjCnVB0	:= SuperGetMv("MV_LJCNVB0",,.F.)											//Retorna preço da SB0 na ausência do preço do Produto na DA0 e DA1

Return ({cMvLjRetVl, lLjCnVB0})

//--------------------------------------------------------
/*/{Protheus.doc} STBSetTblPr
Seta o codigo da tabela de preco na variavel 

@param   	Nil
@author  	Bruno Almeida
@version 	P12
@since   	02/05/2019
@return  	
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBSetTblPr(cTblPrc)

Default cTblPrc := ""

cTablePrice := cTblPrc

Return .T.

//--------------------------------------------------------
/*/{Protheus.doc} STBGetTblPr
Captura o codigo da tabela de preco

@param   	Nil
@author  	Bruno Almeida
@version 	P12
@since   	02/05/2019
@return  	cTablePrice - Retorna o codigo da tabela de preco
@obs     
@sample
/*/
//--------------------------------------------------------
Function STBGetTblPr()
Return cTablePrice
