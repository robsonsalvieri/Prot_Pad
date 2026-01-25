#INCLUDE "PROTHEUS.CH"
#INCLUDE "STFGETSTATION.CH"


Static cAuxEstacao 

//--------------------------------------------------------
/*/{Protheus.doc} STFGetStat
Retorna o(s) valor(es) do(s) campo(s) da SLG

@param   	uCampos - Informa o campo ou os campos que deseja retornar o valor da SLG
@param   	lTef    - Informa se o campo eh da tabela do TEF MDG
@param   	lUpperChar  - Informa se o retorna Caracteres em uppercase
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	uReturn - Retorna o valor do campo ou dos campos que foi solicitado na funcao
@obs     
@sample
/*/
//--------------------------------------------------------
Function STFGetStat(uCampos , lTef, lUpperChar )

Local aArea		:= GetArea() 				//Salva area
Local uReturn		:= ""						//Retorno da funcao
Local nI			:= 0 						//Variavel de loop
Local xRet		:= ""						//Variavel que armazena o nome do campo
Local cParam		:= ""						//Armazena um bloco de codigo para uma macro execucaoR
Local nTamSerie	:= TamSX3("LG_SERIE")[1]	//Tamanho do campo LG_SERIE	
Local lRet			:= .T.						// Retorno caso não haja estação

Default uCampos  	:= Nil
Default lTef 	 	:= .F.
Default lUpperChar := .T. //Caracteres em uppercase?
	
If cAuxEstacao == NIL .AND. !Empty(cEstacao)
   cAuxEstacao  := cEstacao   
Endif	
	
DbSelectArea("SLG")                                      
DbSetOrder(1)//LG_FILIAL+LG_CODIGO

If !DbSeek(xFilial("SLG")+cEstacao)
	If Empty(cEstacao) .AND. ValType(cAuxEstacao) == "C" .AND. !Empty(cAuxEstacao)
	   cEstacao  := cAuxEstacao
	Endif   
	If Empty(cEstacao)	                                                                                                          
	   //"O cadastro de estacao desse operador não foi localizado, por favor, saia do sistema e entre novamente."
	   //"Atenção"
   	   MsgStop(STR0002, STR0001)
   	   DbSeek(xFilial("SLG"),.T.)
   	   lRet := .F.
   	Endif   
Endif

If lRet
	If ValType(uCampos) == "A"
	
		uReturn := {}
		
		For nI := 1 To Len(uCampos)
		
			xRet := FieldGet( FieldPos( If(! Left(uCampos[nI],3) == "LG_","LG_","") + uCampos[nI]))
			
			If ValType(xRet) == "C" 
				If lUpperChar
					xRet := Upper(AllTrim(xRet))
				Else
					xRet := AllTrim(xRet)
				EndIf
			EndIf
			
			If Upper(uCampos[nI]) == "SERIE"
			
				cParam := SuperGetMV("MV_LJSERIE")
				
				// Este parametro permite que seja criada uma regra para o preenchimento   
				// do Numero de Serie do cupom:                                            
				// Por exemplo:                                                            
				// MV_LJSERIE = "Chr(64+Val(cFilAnt))+StrZero(Val(LJGetStation("PDV")),2)" 
				// Ira gerar o numero "A01", onde "A" e a Filial e "01" e o numero do ECF. 					
				If !Empty(cParam)
					xRet := &(cParam)
				EndIf
				
				//Formata a variavel de retorno conforme o tamanho do campo
				Padr(xRet, nTamSerie)
				
			EndIf
			
			AAdd(uReturn,xRet)
			
		Next nI			
	
	Else
		
		If lTef
		
			DbSelectArea("MDG")		
			DbSetOrder(1) //MDG_FILIAL+MDG_CODEST		
			If DbSeek(xFilial("MDG") + cEstacao)   		
				uReturn := FieldGet( FieldPos( If(! Left(uCampos,4) == "MDG_","MDG_","") + uCampos))				
			EndIf	
			
		Else
			uReturn := FieldGet( FieldPos( If(! Left(uCampos,3) == "LG_","LG_","") + uCampos))		
		EndIf		
		
		If Valtype(uReturn) == "C" 
			If lUpperChar
				uReturn := Upper(AllTrim(uReturn))
			Else
				uReturn := AllTrim(uReturn)
			EndIf
		EndIf
		
		If Upper(uCampos) == "SERIE"
		
			cParam := SuperGetMV("MV_LJSERIE")
			
			// Este parametro permite que seja criada uma regra para o preenchimento   
			// do Numero de Serie do cupom:                                           
			// Por exemplo:                                                            
			// MV_LJSERIE = "Chr(64+Val(cFilAnt))+StrZero(Val(LJGetStation("PDV")),2)" 
			// Ira gerar o numero "A01", onde "A" e a Filial e "01" e o numero do ECF. 
			If !Empty(cParam)
				uRet := &(cParam)
			EndIf
			
			//Formata a variavel de retorno conforme o tamanho do campo
			Padr(uReturn, nTamSerie )
			
		EndIf		
				
	EndIf
EndIf

RestArea(aArea)	
	
Return uReturn


//--------------------------------------------------------
/*/{Protheus.doc} STIsRotina
Verifica qual eh a rotina chamadora.    

@param   	cRotina - Rotina 
@author  	Varejo
@version 	P11.8
@since   	11/11/2013
@return  	lRetorno - Se foi a rotina do parametro a chamadora
@obs     
@sample
/*/
//--------------------------------------------------------
Function STIsRotina( cRotina )

Local lRetorno := .F.
Local nContador:= 1

Default cRotina := ""

//Verifica qual a rotina chamadora                                        
While ( !lRetorno .And. !Empty(ProcName(nContador)) )
	If ( Upper(ProcName(nContador))==cRotina )
		lRetorno := .T.
	EndIf
	nContador++
EndDo

Return lRetorno


//--------------------------------------------------------
/*/{Protheus.doc} STStrToArr
Transforma uma lista separada por "," em array     

@param   	cLista - Lista a ser transformada em array
@author  	Varejo
@version 	P11.8
@since   	11/11/2013
@return  	aLista - Lista em array
@obs     
@sample
/*/
//--------------------------------------------------------
Function STStrToArr(cLista)

Local nPos	:= 0		// Variavel de loop
Local aLista := {}		// Retorno da funcao

Default cLista := ""

While Len(cLista)<>0
	If (nPos:=At(",",cLista))<>0
		aAdd(aLista, Subs(cLista, 2, nPos-3))
		cLista := Subs(cLista, nPos+1 )
	Else
		If Left(cLista,1)=='"'
			aAdd(aLista, Subs(cLista, 2, len(cLista)-2) )
		Else
			aAdd(aLista, cLista )
		EndIf
		cLista := ""
	EndIf
End

Return aLista 
