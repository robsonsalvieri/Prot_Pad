#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STDTABLEPRICE.CH"

Static oCache		// Objeto de Cache
Static oNewModel	//Objeto para instanciar o model
Static oStructDA0 := Nil
Static oStructMst := Nil

//--------------------------------------------------------
/*/{Protheus.doc} STDGetMod
Cria e retorna estrutura de dados do Model

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	oModel   - Retorno o Modelo de dados
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDGetMod()

Local oModel 		:= Nil	// Model
Local oMasterStr 	:= Nil
Local oGridStr		:= Nil

//Monta estrutura de tabela de cabecario	
oMasterStr := STDCrMsStr()

//Monta estrura de tabela de Itens
oGridStr := STDCrGrStr()

//Instacia Objeto
oModel 	:= 	MPFormModel():New( 'DA0', /*bPreValidacao*/, /*bPosValidacao*/, /*{ |oMdl| xFRT80MVCGR(oMdl)}*/, /*bCancel*/ )

oModel:AddFields( "MasterStr"    	, /*cOwner*/,  oMasterStr ) 
oModel:AddGrid("GridStr" 			, "MasterStr",  oGridStr, /*B*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:SetRelation("GridStr" 		, { { "DA0_FILIAL", 'xFilial( "DA0" )' }, { "DA0_CODTAB", "DA0_CODTAB" } }, 'DA0_FILIAL + DA0_CODTAB' )
		
Return oModel


//--------------------------------------------------------
/*/{Protheus.doc} STDCrMsStr
Cria estrutura do Model Master

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	oStruct - Retorna a estrutura Master
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDCrMsStr()

Local cX2Unico  	:= "DA0_FILIAL+DA0_CODTAB" //X2_UNICO da tabela DA0

If ValType(oStructMst) = 'O'
	oStructMst:Deactivate()
	oStructMst:Activate()
Else

	oStructMst := FWFormModelStruct():New() // Estrutura												
	
	If ExistFunc('FWX2Unico') 
		cX2Unico := FWX2Unico("DA0") 
	EndIf

	oStructMst:AddTable( 									;
				FWX2CHAVE()                					, 	;	// [01] Alias da tabela
				StrTokArr( cX2Unico, '+' ) 			, 	;  	// [02] Array com os campos que correspondem a primary key
				FWX2Nome("DA0") )                 						// [03] Descrição da tabela
				     
	oStructMst:AddField(                           	;
	                     "FILIAL"  		 		,	; 	// [01] Titulo do campo
	                     "FILIAL"  		 		,	; 	// [02] Desc do campo
	                     "DA0_FILIAL" 	 		,	; 	// [03] Id do Field
	                     "C"              	,	; 	// [04] Tipo do campo
	                     FWSizeFilial()   		,	; 	// [05] Tamanho do campo
	                     0                	, 	; 	// [06] Decimal do campo
	                     Nil             		,	; 	// [07] Code-block de validação do campo
	                     Nil               	,	; 	// [08] Code-block de validação When do campo
	                     Nil 					, 	; 	// [09] Lista de valores permitido do campo
	                     Nil 					, 	; 	// [10] Indica se o campo tem preenchimento obrigatório
	                     Nil              	, 	; 	// [11] Code-block de inicializacao do campo
	                     Nil             		, 	; 	// [12] Indica se trata-se de um campo chave
	                     Nil              	,  	; 	// [13] Indica se o campo pode receber valor em uma operação de update.
	               		)             			  	  	// [14] Indica se o campo é virtual

	oStructMst:AddField(                         		;
	                     "CODIGO"  		 			,	; 	// [01] Titulo do campo
	                     "CODIGO"  		 			,	; 	// [02] Desc do campo
	                     "DA0_CODTAB" 	 			,	; 	// [03] Id do Field
	                     "C"              		,	; 	// [04] Tipo do campo
	                     TamSX3("DA0_CODTAB")[1]	,	; 	// [05] Tamanho do campo
	                     0                		, 	; 	// [06] Decimal do campo
	                     Nil             			,	; 	// [07] Code-block de validação do campo
	                     Nil               		,	; 	// [08] Code-block de validação When do campo
	                     Nil 						, 	; 	// [09] Lista de valores permitido do campo
	                     Nil 						, 	; 	// [10] Indica se o campo tem preenchimento obrigatório
	                     Nil              		, 	; 	// [11] Code-block de inicializacao do campo
	                     Nil             			, 	; 	// [12] Indica se trata-se de um campo chave
	                     Nil              		,  	; 	// [13] Indica se o campo pode receber valor em uma operação de update.
	               		 )             			  			// [14] Indica se o campo é virtual
EndIf
	
Return oStructMst


//--------------------------------------------------------
/*/{Protheus.doc} CreateGridStruct
Cria estrutura do Grid

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	oStruct - Retorna a estrutura do GRID
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDCrGrStr()

Local cAlias 		:= "DA0"						// Alias que criara estrutura													
Local aArea	 		:= Nil
Local nCount		:= 0   
Local cX2Unico  	:= "DA0_FILIAL+DA0_CODTAB" //X2_UNICO da tabela DA0 
                            
If ValType(oStructDA0) = 'O'
	oStructDA0:Deactivate()
	oStructDA0:Activate()
Else
	oStructDA0	:= FWFormModelStruct():New()	// Estrutura
	
	aArea := GetArea()	// Guarda area	
	
	If ExistFunc('FWX2Unico') 
		cX2Unico := FWX2Unico(cAlias) 
	EndIf

	oStructDA0:AddTable( 							;
				FWX2CHAVE()                				, 	;  	// [01] Alias da tabela
				StrTokArr( cX2Unico, '+' ) 		, 	;  	// [02] Array com os campos que correspondem a primary key
				FWX2Nome(cAlias) )                 					// [03] Descrição da tabela
				
	//Carrega informacoes de campos
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek( cAlias ))  
		
	While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAlias
	  	nCount++
	  	If nCount > 1000
	  		Conout('STDCrGrStr - Count>1000',nCount)
	  	EndIf
	  	
	  	oStructDA0:AddField(                                   		;
						AllTrim( X3Titulo()  )        		 	,	; 	// [01] Titulo do campo
						AllTrim( X3Descric() )         			,	; 	// [02] ToolTip do campo
						AllTrim( SX3->X3_CAMPO )       			,	; 	// [03] Id do Field
						SX3->X3_TIPO                  			,	; 	// [04] Tipo do campo
						SX3->X3_TAMANHO               			,	; 	// [05] Tamanho do campo
						SX3->X3_DECIMAL                			,	; 	// [06] Decimal do campo
						Nil                         			,	; 	// [07] Code-block de validação do campo
						Nil                          			,	; 	// [08] Code-block de validação When do campo
						StrTokArr( AllTrim( X3CBox() ),';')		, 	; 	// [09] Lista de valores permitido do campo
						Nil 									,	; 	// [10] Indica se o campo tem preenchimento obrigatório
						Nil                         			, 	; 	// [11] Code-block de inicializacao do campo
						Nil                            			, 	; 	// [12] Indica se trata-se de um campo chave
						Nil                            			, 	; 	// [13] Indica se o campo pode receber valor em uma operação de update.
						(SX3->X3_CONTEXT == 'V' )     )             	// [14] Indica se o campo é virtual
		SX3->(DbSkip()) 
	End              
	
	RestArea(aArea)
EndIf
	
Return oStructDA0


//--------------------------------------------------------
/*/{Protheus.doc} GetAllData
Inclui os dados no model e retorna

@param   	
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	oNewModel - Retorna Model 
@obs     
@sample
/*/
//--------------------------------------------------------
Function STDGetData()

Local nX 			:= 0   								//Variavel de loop
Local lFirstLine	:= .T. 							//Verifica se esta incluindo a primeira linha

oNewModel := STDGetMod()
oNewModel:SetOperation( 3 )
oNewModel:SetDescription(STR0001)  //"Tabela de preco"
oNewModel:Activate()

DbSelectArea("DA0")
DbSetOrder(1)	
DA0->(DbGoTop())

// Dados do master  
oModelMaster := oNewModel:GetModel("MasterStr")
oModelMaster:SetValue("DA0_FILIAL"	, DA0->DA0_FILIAL)
oModelMaster:SetValue("DA0_CODTAB"	, DA0->DA0_CODTAB)

oModelGrid	:= oNewModel:GetModel("GridStr")
aTestStr 	:= oModelGrid:GetStruct()

// Carrega todas as tabelas de preco
While !DA0->(EOF()) .AND. (DA0_FILIAL == xFilial("DA0")) 	.AND. (DA0->DA0_ATIVO == "1");
						.AND. (dDataBase >= DA0->DA0_DATDE) 	.AND. (dDataBase <= If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE))


	//Avalia efetivamente se existe tabela de preco ativa para a data e hora atual
	//considerando se o DA0_TPHORA e igual a "1" ou "2"                                           
	If 	(DA0->DA0_TPHORA == "1" 																								.AND.	;
		(SubtHoras(dDataBase,Time(),If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE),DA0->DA0_HORATE) >= 0 	.AND.	;
		 SubtHoras(DA0->DA0_DATDE,DA0->DA0_HORADE,dDataBase,Time()) >= 0)) 											.OR.	;
		(DA0->DA0_TPHORA == "2" 																								.AND.	;
		(dDataBase >= DA0->DA0_DATDE .And. dDataBase <= If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE) 	.AND.	;
		(SubStr(Time(),1,5) >= DA0->DA0_HORADE .And. SubStr(Time(),1,5) <= DA0->DA0_HORATE)))

		//Se entrou a(s) tabela(s) o model					
		If !lFirstLine
			nLine := oModelGrid:AddLine()
		Else
			lFirstLine := .F.		
		EndIf
		
		For nX := 1 To Len(aTestStr:aFields)
			oModelGrid:SetValue(aTestStr:aFields[nX][3], &("DA0->" + aTestStr:aFields[nX][3]))
		Next nX
				
	EndIf
	
	DA0->(DbSkip())
	
End
	
Return oNewModel

//--------------------------------------------------------
/*/{Protheus.doc} SubtHoras
Calcula o Numero de Horas entre dois tempos.
@param   	Funcao duplicada para evitar de colocar o fonte inteiro
@author  	Leandro Lima
@version 	P11.8
@since   	13/10/2014
@return  	numero de horas 
/*/
//--------------------------------------------------------
Static Function SubtHoras(dDataIni,cHoraIni,dDataFim,cHoraFim,lHrCont)

Local nDias := dDataFim - dDataIni
Local nHoras:= HoraToInt(cHoraFim)-HoraToInt(cHoraIni)
//Horario Continuo. Ex. 10/10/2010 08:00 até 11/10/2010 17:00 como 32 horas. Quando .F. Considera apenas 8 hs dia 10 + 8hs dia 11 = 16hs
Default lHrCont := .T. //Considera horario continuo. 

If nDias > 0 .AND. lHrCont == .F.
	nHoras	:= nHoras+(nHoras * nDias) 
Else
	nHoras := nHoras+(nDias*24)	
EndIf

Return(nHoras)

/*/{Protheus.doc} HoraToInt
Calcula o Numero de Horas entre dois tempos.
@param   	Funcao duplicada para evitar de colocar o fonte inteiro
@author  	Leandro Lima
@version 	P11.8
@since   	13/10/2014
@return  	numero de horas 
/*/
//--------------------------------------------------------
Static Function HoraToInt(cHora,nDigitos)

Local nHoras   
Local nMinutos                            
Local nExtDigit 

nExtDigit := If( ValType( nDigitos ) == "N", nDigitos - 2, 0 ) 
					
nHoras    := Val(SubStr(cHora,1,2 + nExtDigit ))
nMinutos  := Val(SubStr(cHora,4 + nExtDigit,2))/60

Return(nHoras+nMinutos)




//--------------------------------------------------------
/*/{Protheus.doc} STDTabsPre
Funcao para recuperar as tabelas de preço do produto.
@param cItemCode	, caractere, Produto a ser consultado.
@param cMvLjRetVl	, caractere, Valor da tabela de Preço
@param cTabCli		, caractere, Tabela de Preço do Cliente, caso exista
@author  	Yuri Porto
@version 	P11.8
@since   	24/06/2016
@return  	Tabelas DA1 (Tabelas de peço, Preço de Venda), onde o produto exista
/*/
//--------------------------------------------------------
Function STDTabsPre(cItemCode,cMvLjRetVl, cTabCli) 

Local aAreaDA1	:= {}	//Guarda area
Local aAreaDA0	:= {}	//Guarda area
Local aRet		:= {}	//retorno
Local cSeek		:= ""	//Seek de busca DA0
Local cTabPad	:= ""	//Tabela de preco padrao
Local dValidTab	:= Date()	// Data limite de validade da tabela de preço

Default cItemCode 	:= " "	
Default cMvLjRetVl 	:= SuperGetMV("MV_LJRETVL",,"3")	// 1=Retorna o menor preco de uma tabela | 2=Retorna o maior preco de uma tabela | 3=Considera preco da tabela configurada no parametro MV_TABPAD
Default cTabCli		:= ""

//Quando configurado para retornar preco da MV_TABPAD(cMvLjRetVl=3), 
//nao realiza a busca na DA1, apenas retorna o conteudo do TABPAD
If cMvLjRetVl == "3"

	IF !Empty(cTabCli)
		cTabPad	:= cTabCli 	//tabela de preço do cliente
	Else
		cTabPad	:= Padr(AllTrim(SuperGetMv("MV_TABPAD",,"")),TamSX3("DA0_CODTAB")[1])	// Tabela de preco padrao
	EndIf

	If Len(cTabPad) > 1

		dValidTab := GetAdvFVal( "DA0" , "DA0_DATATE" , XFILIAL("DA0") + cTabPad, 1 , 0 )

		If 	!Empty(dValidTab) .And. dValidTab < Date()
			LjGrvLog( cItemCode, "Tabela de preço fora de vigência. Verifique o código da tabela contido no parâmetro MV_TABPAD | Tabela de preço" , cTabPad )
			AAdd(aRet,{"-999", 0})
		Else
			aAdd(aRet,{cTabPad, 0})	
		EndIf

	EndIf
	
Else
	aAreaDA1 := DA1->(GetArea())
	aAreaDA0 := DA0->(GetArea())
	
	DbSelectArea ("DA0")
	DA0->(DbSetOrder(1))	//DA0_FILIAL+DA0_CODTAB

	cSeek	:= xFilial("DA0")
	LjGrvLog( cItemCode, "Ira pesquisar tabelas da DA0 onde o produto possui cadastro na DA1(MV_LJRETVL <> 3)")
	
	If DA0->(DbSeek(cSeek))		
		While DA0->(!Eof()) .AND. DA0->DA0_FILIAL == cSeek
			If DA0->DA0_ATIVO == "1"//percorre todas as tabelas cadastradas ativas/vigentes (Regra padrao fica centralizada na rotina MaTabPrVen), nesse ponto é realizado validacao basica
				If (dDataBase >= DA0->DA0_DATDE) .AND. (dDataBase <= If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE))	
					If (DA0->DA0_TPHORA == "1" 																								.AND.	;
					(SubtHoras(dDataBase,Time(),If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE),DA0->DA0_HORATE) >= 0 					.AND.	;
					SubtHoras(DA0->DA0_DATDE,DA0->DA0_HORADE,dDataBase,Time()) >= 0)) 														.OR.	;
					(DA0->DA0_TPHORA == "2" 																								.AND.	;
					(dDataBase >= DA0->DA0_DATDE .And. dDataBase <= If(Empty(DA0->DA0_DATATE),dDataBase,DA0->DA0_DATATE) 					.AND.	;
					(SubStr(Time(),1,5) >= DA0->DA0_HORADE .And. SubStr(Time(),1,5) <= DA0->DA0_HORATE)))
						DA1->(DbSetOrder(1))	//DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
						If DA1->(DbSeek(DA0->DA0_FILIAL+DA0->DA0_CODTAB+cItemCode))	//Verifica se item cadastrado na tabela	
							While DA1->(!Eof()) .And. xFilial("DA1") + DA0->DA0_CODTAB + Alltrim(cItemCode) == DA1->DA1_FILIAL + DA1->DA1_CODTAB + Alltrim(DA1->DA1_CODPRO)
								If DA1->DA1_DATVIG <= Date() .And. DA1->DA1_ATIVO == "1"
									aAdd(aRet, {DA0->DA0_CODTAB, DA1->DA1_PRCVEN})
									Exit
								Endif
								DA1->(dbSkip())
							End
						EndIf
					EndIf		
				EndIf
			EndIf			
			DA0->(DbSkip())	
		EndDo 
	EndIf
	
	LjGrvLog( cItemCode, "Tabelas encontradas com item na DA1:",aRet)
	
	RestArea(aAreaDA1)
	RestArea(aAreaDA0)
	
EndIf

Return(aRet)
