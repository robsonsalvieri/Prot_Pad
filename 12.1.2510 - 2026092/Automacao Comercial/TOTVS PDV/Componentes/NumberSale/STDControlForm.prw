#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static cEspFor := "1|2|3|4"	//Especies de formulario

//-------------------------------------------------------------------
/*/{Protheus.doc} STDEspeFor
Verificar especies de formlarios validas que podem ser utilizadas na venda.

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDEspeFor()

Local	aArea		:= GetArea()	//Armazena alias corrente
Local aSpecies	:= {}			//Array com as especies reservadas para a estacao
Local nRecnoFo1	:= 0			//nRecnoFo1
Local nRecnoFo2	:= 0			//nRecnoFo2
Local cEspecie	:= ""			//Especie que o usuario escolheu
Local cNumNota	:= ""			//Numero da nota
Local cSerie		:= ""			//Serie


//Verificar na tabela SL6 se os tipos de documento Boleta,  
//Boleta Exenta, Factura ou Factura Exenta estao reservados 
//para a estacao	
DbSelectArea("SL6")
DbSetOrder(3)//L6_FILIAL+L6_ESTACAO
If DbSeek(xFilial("SL6") + cEstacao)
	Do While SL6->L6_ESTACAO == cEstacao
		If SL6->L6_ESPFO $ cEspFor
		
			//Se a reserva de serie estiver associada a um 
			//formulario, verificar se o mesmo e valido.  
			If ChkFolCHI(SL6->L6_FILFO	,	SL6->L6_SERIE, Nil, cEspFor,;
						   @nRecnoFo1		,	.T.)
		   		Aadd(aSpecies, {SL6->L6_ESPFO, SL6->L6_SERIE, nRecnoFo1})			
			EndIf
						
		EndIf
		SL6->(DbSkip())
	End
EndIf


If Len(aSpecies) >= 1
	
	STDLastSale( aSpecies )	    						    	
    		
EndIf 	

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDLastSale
Busca informacao da ultima venda

@param   	aSpecie - Especies
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	aDadosFo - Dados do formulario
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDLastSale(aSpecie)

Local	aArea		:= GetArea()							//Armazena alias corrente
Local cSerieFo	:= SPACE(TamSx3("FP_SERIE")[1])	//Serie que sera utilizada para o tipo de documento escolhido
Local cDocFo		:= SPACE(TamSx3("F2_DOC")[1])		//Nota referente a serie escolhida
Local nRecnoFo	:= 0 									//Recno do formulario
Local aAreaSL1	:= SL1->(GetArea())					//Restaura a area da tabela SL1
Local nPosRec		:= 0									//Posicao para buscar a especie no array  

Default aSpecie	:= {}

ParamType 0 Var   	aSpecie 	As Array	Default 	{}
	
//Obter dados da ultima venda
DbSelectArea("SL1")
SL1->(DbGoBottom ())

If !Empty(SL1->L1_SERIE) .AND. !Empty(SL1->L1_DOC)

	nRecnoFo := STDRecnoFo(SL1->L1_SERIE)	

	aDadosFo := STDDadosFo(nRecnoFo)
	
	If nRecnoFo > 0 .AND. Len(aDadosFo) > 0 .AND. aDadosFo[1][2] $ cEspFor 
		//Retornar a especie/serie/numero+1 do documento da ultima   
		//venda se ela for:  1-FCT ; 2-FCX ; 3-BLT ; 4-BLX           
		If !Empty(SL1->L1_SERIE)		
			cSerieFo := SL1->L1_SERIE		
		ElseIf !Empty(SL1->L1_SERPED)		  
			cSerieFo := SL1->L1_SERPED				
		EndIf
		
		DbSelectArea("SX5")
   		DbSetOrder(1)
  		DbSeek(xFilial() + "01" + cSerieFo)
   		cDocFo := AllTrim(X5Descri())
		
		//Verificar se a serie da ultima venda esta reservada para a estacao
		DbSelectArea("SL6")
		DbSetOrder (1)//L6_FILIAL+L6_SERIE+L6_ESTACAO
		If !DbSeek(xFilial("SL6") + cSerieFo + cEstacao)
			aDadosFo[2][2]	:= SPACE(TamSx3("X5_CHAVE")[1]) 
			cSerieFo			:= SPACE(TamSx3("FP_SERIE")[1])
			cDocFo 			:= SPACE(TamSx3("F2_DOC")[1]) 
		EndIf
		SL6->(DbCloseArea())
	Else			
		cSerieFo	:= SPACE(TamSx3("FP_SERIE")[1])
		cDocFo 	:= SPACE(TamSx3("F2_DOC")[1])  	
	EndIf	
	
EndIf
	
SL1->(RestArea(aAreaSL1))

If Len(aDadosFo) == 0		
	nPosRec := aScan(aSpecie, { |x| AllTrim(x[02]) == aSpecie[1][2] })

	If nPosRec > 0 
		Aadd(aDadosFo, {"Especie",aSpecie[nPosRec][3]})
	Else
		Aadd(aDadosFo, {"Especie",""})
	EndIf		

	Aadd(aDadosFo, {"Sigla",STDSiglaFo(aSpecie[1][1])})
	Aadd(aDadosFo, {"Descricao",""})
	Aadd(aDadosFo, {"Serie",aSpecie[1][2]})
	Aadd(aDadosFo, {"Doc. Formulario",STDVldNota(aSpecie[1][2])[2]})	
EndIf
			
RestArea(aArea)			
			
Return aDadosFo


//-------------------------------------------------------------------
/*/{Protheus.doc} STDRecnoFo
Retorna o Recno do controle de formulario de acordo com a serie.

@param   	cSerie - Numero de serie
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	nRecno - Recno da tabela SFP
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDRecnoFo(cSerie) 

Local aArea	:= GetArea() 	//Salva a area
Local nRecno	:= 0			//Recno do formulario

Default cSerie:= "" 

ParamType 0 Var 	cSerie 	As Character	Default 	""

DbSelectArea("SFP")
DbSetOrder(1)		

If DbSeek (xFilial("SFP") + SL1->L1_FILIAL + cSerie)
	nRecno := SFP->(RecNo())
EndIf

RestArea(aArea)

Return nRecno


//-------------------------------------------------------------------
/*/{Protheus.doc} STDDadosFo
Retorna os dados do controle de formulario de acordo com o Recno passado por
parametro
@param   	nRecNo - Recno
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	aRet
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDDadosFo(nRecNo)

Local aArea 		:= GetArea()	//Guarda a area atual
Local cEspCod		:= ""			//Codigo da especie
Local cEspSigla	:= ""			//Sigla
Local cEspDesc	:= ""			//Descricao
Local cSerie		:= ""			//Serie
Local aRet		:= {}			//Array para retorno das informacoes

Default nRecNo 	:= 0			//Recno do registro do formularios

ParamType 0 Var 	nRecNo 		As Numeric	Default 	0
	
If !(nRecNo == 0) 
	
	DbSelectArea("SFP")
	SFP->(DbGoto(nRecNo))
	
	cEspCod	:= SFP->FP_ESPECIE
	cEspSigla	:= STDSiglaFo(cEspCod)
	
	DbSelectArea("SX5")
	DbSetOrder(1)
	If !DbSeek(xFilial() + "42" + cEspSigla)
		Help(" ",1,"LJ010SERIE")
		lRet := .F.	   
	Else
		cEspDesc := AllTrim(X5_DESCRI)
	EndIf
	
	cSerie:= SFP->FP_SERIE
	
	aRet := {{"Especie",cEspCod},{"Sigla",cEspSigla},{"Descricao",cEspDesc},{"Serie",cSerie}}

EndIf

RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDSiglaFo
Retorna sigla do formulario
@param   	cCodigo - Codigo do formulario
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	cRet - sigla do formulario
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDSiglaFo(cCodigo)                                       

Local	aArea	:= GetArea()		// Armazena alias corrente
Local aSX3Box	:= {}	//Array de Opcoes do Combo Box
Local cRet  	:= ""  	//Retorno
Local nPos	:= 0   	//Posicao do array    

Default cCodigo := ""

ParamType 0 Var 	cCodigo 		As Numeric	Default 	0

DbSelectArea("SX3")
DbSetOrder(2)
	
If DbSeek("FP_ESPECIE")
	aSX3Box := RetSx3Box( X3CBox(),,, 1 )
	
	nPos := Ascan(aSX3BOX,{|x| x[2] == Rtrim(cCodigo)})
	
	If nPos > 0 
		cRet := aSX3Box[nPos,3]
	EndIf
EndIf

If Empty(cRet)
	cRet := cCodigo
EndIf

RestArea(aArea)

Return Rtrim(cRet) 


//-------------------------------------------------------------------
/*/{Protheus.doc} STDDadosFo
Validar se a especie do formulario pode ser utilizada junto com a determinada
serie que deve estar reservada para estacao.

@param   	cEspecie - Especie
@param   	cSerie   - Serie
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	lRet - Retorna .T. ou .F. se validou o formulario
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDVldEsp(cEspecie,cSerie)

Local lRet 	:= .T.			//Retorno da funcao
Local aArea	:=  GetArea()	//Area 
Local nPosIni	:= 0			//Guarda a posicao da string
Local cCombo	:= ""			//Armazena o valor do combo do campo X3_CBOXSPA

Default cEspecie	:= ""
Default cSerie	:= ""

ParamType 0 Var 	cEspecie 	As Character	Default 	""
ParamType 1 Var 	cSerie 	As Character	Default 	""

//Busca posicao da descricao da especie da nota no combo da 
//tabela SFP (1=FCT;2=FCT;3=BLT;4=BLX;5=GDP;6=NDC;7=NDI;8=NCC;9=NCI;A=NCX)
SX3->(dbSetOrder(2))
SX3->(dbSeek("FP_ESPECIE"))
nPosIni:= At(AllTrim(cEspecie),AllTrim(SX3->X3_CBOXSPA))
cCombo 	:= Substr(AllTrim(SX3->X3_CBOXSPA), nPosIni - 2, 1)

DbSelectArea("SL6")
DbSetOrder(4)
If DbSeek(xFilial() + cEstacao + cCombo)
	cSerie	:= SL6->L6_SERIE
	lRet	:= .T.
Else
	lRet	:=.F.
EndIf   

RestArea(aArea)	
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDVldNota
Validar numeracao do formulario

@param   	cSerie 	- Serie
@param   	cNumNota	- Numero do documento fiscal
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	aRet - Validacao de funcoes e nu8mero na nota
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDVldNota( cSerie )

Local aRet 			:= {.T.,""}										//Retorno da funcao
Local aArea			:= GetArea()										//Area 
Local lNotaManual  	:= IIf(Type("lNFManual")#"U",lNFManual,.F.)	//Nota manual
Local cNumNota		:= ""												//Numero da nota

Default cSerie 		:= ""

ParamType 0 Var 	cSerie 	As Character	Default 	""

If !lNotaManual
	
	DbSelectArea("SX5")
   	DbSetOrder(1)
   	
   	If !DbSeek(xFilial() + "01" + cSerie)   	
		Help(" ",1,"LJ010SERIE")
		aRet := {.F.,cNumNota}
	EndIf   
   	
   	cNumNota := AllTrim(X5Descri())
   	   	
   	If !ChkFolCHI(xFilial("SFP"), cSerie, cNumNota, "1|2|3|4|8")
		aRet := {.F.,cNumNota}
	Else
		aRet := {.T.,cNumNota}
   	EndIf   	
	
EndIf

RestArea(aArea)

Return aRet  

