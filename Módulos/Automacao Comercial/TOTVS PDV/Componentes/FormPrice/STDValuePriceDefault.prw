#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static cTabPad := SuperGetMv("MV_TABPAD",,"1") //Define qual coluna da SB0 sera o preco default
Static lTabPad := (SB0->(FieldPos("B0_PRV" + cTabPad)) > 0) //Verifica se o campo existe na SB0

//--------------------------------------------------------
/*/{Protheus.doc} ValuePriceDefault
Função responsavel em localizar o preco do produto na SB0 conforme o parametro
MV_TABPAD

@param   	cItemCode  Codigo do Item
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	nReturnPrice - Preco
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDValPrDf( cItemCode )

Local nReturnPrice	:= 0	//Retorno da funcao

Default cItemCode := ""

ParamType 0 Var 	cItemCode 	As Character	Default 	""

DbSelectArea( "SB0" )

If lTabPad

	If DbSeek(xFilial("SB0") + cItemCode)
		nReturnPrice := &("SB0->B0_PRV" + cTabPad) 							
	EndIf
					
EndIf

Return nReturnPrice


//--------------------------------------------------------
/*/{Protheus.doc} STBPrecoB1
Retorna o preco do item da tabela SB1

@param   	cItemCode  Codigo do Item
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	nReturnPrice - Preco
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDPrecoB1( cItemCode )

Local aArea			:= GetArea()	//Salva a area
Local nReturnPrice	:= 0			//Retorno da funcao

Default cItemCode := ""

ParamType 0 Var 	cItemCode 	As Character	Default 	""

DbSelectArea	( "SB1" )
DbSetOrder( 1	) //B1_FILIAL + B1_COD
	
If DbSeek(xFilial("SB1") + cItemCode)
	nReturnPrice := SB1->B1_PRV1
EndIf						

RestArea(aArea)
	
Return nReturnPrice


//--------------------------------------------------------
/*/{Protheus.doc} STBChgPrDf
Função responsavel em retornar os 9 precos de um determinado produto 

@param   	cItemCode - Codigo do item
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	aPrices - Retorna uma lista de precos
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDChgPrDf( cItemCode )

Local aPrices	:= {} 				//Variavel para retorno dos precos
Local nI		:= 1				//Variavel de loop
Local aArea	:= GetArea()		//Salva a area

Default cItemCode := ""

ParamType 0 Var 	cItemCode 	As Character	Default 	""

DbSelectArea( "SB0" )
DbSetOrder( 1 ) //B0_FILIAL + B0_COD

If DbSeek(xFilial("SB0") + cItemCode)
	For nI := 1 to 9
		
		/*/If lLJ7044
	      xRet := U_LJ7044(nX)
		   If ValType(xRet) == "L"
		      If !xRet
		          Loop
		      Endif   
	       Endif	       
	    Endif/*/
	    		    
		//Checar se o campo da tabela de precos esta 'usado' e o nivel do usuario permite ver o campo
		DbSelectArea( "SX3" )
		DbSetOrder( 2 )
		
		If DbSeek(PadR("B0_PRV" + Str(nI,1,0),10," ")) .AND. X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		
			If Empty(SB0->&("B0_DATA" + Str(nI,1,0))) .OR. SB0->&("B0_DATA" + Str(nI,1,0)) >= dDatabase
			
				aAdd( aPrices, { StrZero(nI,2,0), SB0->&("B0_PRV" + Str(nI,1,0)) } )
								
			EndIf
			
		EndIf		    
	    					
	Next nI
EndIf

RestArea(aArea)

Return aPrices  


//--------------------------------------------------------
/*/{Protheus.doc} AddCurrency
Funcao responsavel em adicionar a coluna moeda quando for localizado
 
@param   	aPrices	Recebe os valores da SB0
@param   	cItemCode  Codigo do Item
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	aPrices - valores da SB0
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDAdCurre( aPrices, cItemCode )
Local nI 		:= 1			//Variavel de loop
Local aArea	:= GetArea()	//Salva a area	

Default aPrices 		:= {}
Default cItemCode 	:= ""

ParamType 0 Var  aPrices 	As Array	Default 		{}
ParamType 1 Var 	cItemCode 	As Character	Default 	""


DbSelectArea( "SB0" )
DbSetOrder( 1 ) //B0_FILIAL + B0_COD

If DbSeek(xFilial("SB0") + cItemCode)
	 
	For nI := 1 To Len(aPrices)
		AAdd(aPrices[nI],Capital(SuperGetMV("MV_MOEDA" + LTrim(Str(Max(SB0->&("B0_MOEDA" + Str(nI,1,0)),1))))))
	Next nI
	
EndIf

RestArea(aArea)	   

Return aPrices

