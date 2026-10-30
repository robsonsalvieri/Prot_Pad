#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDISSL1Get
Busca o Orcamento pelo numero e retorna o cabeçalho num array
@param   cNumOrc				Numero do Orcamento
@param	 lSL1Locked				Retorna .T. se a SL1 estiver com lock
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSL1					Retorna cabeçalho do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISSL1Get( cNumOrc, lSL1Locked )

Local aArea 			:= GetArea()		// Armazena alias corrente
Local cOptionsTemp 		:= GetNextAlias()	// Armazena Proximo alias disponível
Local aSL1				:= {}				// Retorno da função
Local nI				:= 0				// Contador
Local cNumExp			:= ""				// Expressao L1_NUM
Local cQryFields 		:= ""
Local aFieldsImp 		:= {}
Local axTesSql 			:= {}
Local caxTesSql			:= ""

Default cNumOrc			:= ""
Default lSL1Locked		:= .F. 

ParamType 0 Var 	cNumOrc 			As Character	Default ""	

If FindFunction("STBImpGFld")
	aFieldsImp	:= STBImpGFld("SL1") //Retorna os campos que serao utilizados na query para importacao do orcamento
Else
	aFieldsImp	:= SL1->(dbStruct()) //Todos os campos
EndIf

For nI := 1 To Len( aFieldsImp )
	cQryFields += aFieldsImp[nI][1]+","
Next nI
//Retira a Ultima Virgula
cQryFields := Left(cQryFields,Len(cQryFields)-1)
cQryFields := "%"+cQryFields+"%"

If !Empty(cNumOrc)
	If Len(Alltrim(cNumOrc)) == TamSX3("L1_NUM")[1]
		cNumExp := "%'" + cNumOrc + "'%"
	Else
		cNumExp := "%'" + StrZero(Val(cNumOrc),TamSX3("L1_NUM")[1]) + "'%"
	EndIf
Else
	cNumExp := "%''%"
EndIf

BeginSql ALIAS cOptionsTemp  
						
				SELECT %Exp:cQryFields%					
				FROM %table:SL1% SL1						
				WHERE	
						L1_FILIAL		=	%xfilial:SL1%				AND	
					  	L1_NUM			=	%exp:cNumExp%				AND        
						L1_PEDRES		=  " "							AND
						SL1.%NotDel%
EndSql

axTesSql :=   GetLastQuery()

caxTesSql := axTesSql[2]

LjGrvLog( " 03 Importação do PDV Orcamento " + cNumOrc, "SQL", Nil )
LjGrvLog( " 04 A sql = " + 	caxTesSql + "Fim", "SQL", Nil )

//Ajuste no tipo de dado retornado da query (Numerico, Data, Lógico)
For nI := 1 To Len(aFieldsImp)
	If aFieldsImp[nI,2]<>"C" .And. aFieldsImp[nI,2]<>"M" //M=Memo Real
		TcSetField(cOptionsTemp,aFieldsImp[nI,1],aFieldsImp[nI,2],aFieldsImp[nI,3],aFieldsImp[nI,4])
	EndIf
Next nI

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
	    
	For nI := 1 To FCount()
		AADD( aSL1 , {FieldName(nI) , FieldGet(nI)} )
		
	Next nI
	
	lSL1Locked := STDValLock ((cOptionsTemp)->L1_NUM)

	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

DbSelectArea( "SL1" ) // Seleção de tabela (preventiva)

RestArea(aArea)

Return aSL1


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISPafSL1Get
Busca o Orcamento pela numeração de DAV/PRE e retorna o cabeçalho
@param   cNumOrc				Numero do Orcamento(L1_NUMORC)
@param   cTypeNumber			Tipo de Numeração. "D" -> DAV , "P" -> PREVENDA
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSL1					Retorna cabeçalho do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISPafSL1Get( cNumOrc , cTypeNumber )

Local aArea 			:= GetArea()		// Armazena alias corrente
Local cOptionsTemp 		:= GetNextAlias()		// Armazena Proximo alias disponível
Local aSL1				:= {}				// Retorno da função
Local nI				:= 0				// Contador
Local cNumExp			:= ""				// Expressao L1_NUM
Local cTpOrc			:= ""				// Expressao L1_TPORC
Local cQryFields 		:= ""
Local aFieldsImp 		:= {} 

Default cNumOrc		:= ""
Default cTpOrc		:= ""

ParamType 0 Var 	cNumOrc 			As Character	Default ""	

If FindFunction("STBImpGFld")
	aFieldsImp	:= STBImpGFld("SL1") //Retorna os campos que serao utilizados na query para importacao do orcamento
Else
	aFieldsImp	:= SL1->(dbStruct()) //Todos os campos
EndIf

For nI := 1 To Len( aFieldsImp )
	cQryFields += aFieldsImp[nI][1]+","
Next nI
//Retira a Ultima Virgula
cQryFields := Left(cQryFields,Len(cQryFields)-1)
cQryFields := "%"+cQryFields+"%"


If !Empty(cNumOrc)
	cNumExp	:= "%'" + StrZero(Val(cNumOrc),TamSX3("L1_NUMORC")[1]) + "'%"
Else
	cNumExp := "%''%"
Endif
cTpOrc 	:= "%'" + cTypeNumber + "'%"

BeginSql ALIAS cOptionsTemp  
						
				SELECT %Exp:cQryFields%
				FROM %table:SL1% SL1						
				WHERE	
						L1_FILIAL		=	%xfilial:SL1%				AND	
					  	L1_NUMORC		=	%exp:cNumExp%				AND
					  	L1_TPORC		=	%exp:cTpOrc%				AND      
						SL1.%NotDel%
EndSql

//Ajuste no tipo de dado retornado da query (Numerico, Data, Lógico)
For nI := 1 To Len(aFieldsImp)
	If aFieldsImp[nI,2]<>"C" .And. aFieldsImp[nI,2]<>"M" //M=Memo Real
		TcSetField(cOptionsTemp,aFieldsImp[nI,1],aFieldsImp[nI,2],aFieldsImp[nI,3],aFieldsImp[nI,4])
	EndIf
Next nI

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
		    
	For nI := 1 To FCount()
	
		AADD( aSL1 , {FieldName(nI) , FieldGet(nI)} )
		
	Next nI
	
	(cOptionsTemp)->(DbSkip())
	
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

DbSelectArea( "SL1" ) // Seleção de tabela (preventiva)

RestArea(aArea)

Return aSL1


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISSL2Get
Busca os itens do Orcamento pelo numero e retorna num array bidimensional

@param   cNumOrc				Numero do Orcamento
@param   lPafEcf				Indica se usa PafEcf
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSL2					Retorna Itens do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISSL2Get( cNumOrc , lPafEcf )

Local aArea				:= GetArea()	// armazena alias corrente
Local aSL2				:= {}			// Retorno da funcao      
Local cOptionsTemp 		:= GetNextAlias()		// Armazena Proximo alias disponível
Local aItens			:= {}			// Armazena os itens(auxiliar do SL2)
Local nI				:= 0			// Contador
Local cNumExp			:= ""				// Expressao L1_NUM
Local cDeleted			:= ""			// Status de deleção
Local cL1_Vendid      	:= PadR('N', TamSx3("L2_VENDIDO")[1])		// Tamanho do L2_VENDIDO
Local cQryFields 		:= ""
Local aFieldsImp 		:= {} 

Default cNumOrc			:= ""
Default lPafEcf			:= .F.

ParamType 0 Var 	cNumOrc 			As Character	Default ""	

If FindFunction("STBImpGFld")
	aFieldsImp	:= STBImpGFld("SL2") //Retorna os campos que serao utilizados na query para importacao do orcamento
Else
	aFieldsImp	:= SL2->(dbStruct()) //Todos os campos
EndIf

For nI := 1 To Len( aFieldsImp )
	cQryFields += aFieldsImp[nI][1]+","
Next nI
//Retira a Ultima Virgula
cQryFields := Left(cQryFields,Len(cQryFields)-1)
cQryFields := "%"+cQryFields+"%"


If !Empty(cNumOrc)

	If Len(Alltrim(cNumOrc)) == TamSX3("L2_NUM")[1]
		cNumExp := "%'" + cNumOrc + "'%" 
	Else
		cNumExp := "%'" + StrZero(Val(cNumOrc),TamSX3("L2_NUM")[1]) + "'%"
	EndIf
Else
	cNumExp := "%''%"
EndIf
cDeleted := "%'*'%"
cL1_Vendid := "%'" + cL1_Vendid + "'%"

If  lPafEcf
	
	//No PAFECF nao usar 	%NotDel% pois os itens serao
	//impressos e cancelados de acordo com campo L2_VENDIDO	
	BeginSql ALIAS cOptionsTemp  
					
					SELECT %Exp:cQryFields%  				
					FROM %table:SL2% SL2						
					WHERE	
							L2_FILIAL		=	%xfilial:SL2%				AND	
						  	L2_NUM			=	%exp:cNumExp%             AND
						  	( 	SL2.%NotDel%                               OR
						  	   		( 	SL2.D_E_L_E_T_ = %exp:cDeleted%  AND
						  	     		SL2.L2_VENDIDO = %exp:cL1_Vendid% 
						  	    	)
						  	 )
	
	EndSql
	
Else

	BeginSql ALIAS cOptionsTemp  
					
					SELECT %Exp:cQryFields% 				
					FROM %table:SL2% SL2						
					WHERE	
							L2_FILIAL		=	%xfilial:SL2%				AND	
						  	L2_NUM			=	%exp:cNumExp%				AND
							SL2.%NotDel% 
	
	EndSql

EndIf	

//Ajuste no tipo de dado retornado da query (Numerico, Data, Lógico)
For nI := 1 To Len(aFieldsImp)
	If aFieldsImp[nI,2]<>"C" .And. aFieldsImp[nI,2]<>"M" //M=Memo Real
		TcSetField(cOptionsTemp,aFieldsImp[nI,1],aFieldsImp[nI,2],aFieldsImp[nI,3],aFieldsImp[nI,4])
	EndIf
Next nI

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
		    
	For nI := 1 To FCount()
	
		AADD( aItens , {FieldName(nI) , FieldGet(nI)} )
		
	Next nI
	
	AADD( aSL2 , aItens )
	
	aItens := {}	
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

RestArea(aArea)

Return aSL2


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISSL4Get
Busca as formas de pagamento do Orcamento pelo numero e retorna num array bidimensional

@param   cNumOrc				Numero do Orcamento
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aSL4					Retorna formas de pagamento do orçamento
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISSL4Get( cNumOrc )

Local aArea			:= GetArea()		// Armazena alçiasl corrente
Local aSL4			:= {}				// Retorno da funcao
Local cOptionsTemp 	:= GetNextAlias()	// Armazena Proximo alias disponível
Local aPay			:= {}				// Armazena formas de pagamento(auxilial aSL4)
Local nI				:= 0				// Contador

Default cNumOrc			:= ""

ParamType 0 Var 	cNumOrc 			As Character	Default ""	

If !Empty(cNumOrc)
	If Len(Alltrim(cNumOrc)) == TamSX3("L4_NUM")[1]
		cNumExp := "%'" + cNumOrc + "'%"
	Else
		cNumExp := "%'" + StrZero(Val(cNumOrc),TamSX3("L4_NUM")[1]) + "'%"
	EndIf
Else
	cNumExp := "%''%"
EndIf
 
BeginSql ALIAS cOptionsTemp  
						
				SELECT	 *					
				FROM %table:SL4% SL4						
				WHERE	
						L4_FILIAL		=	%xfilial:SL4%				AND	
					  	L4_NUM			=	%exp:cNumExp%				AND        
						SL4.%NotDel%
EndSql

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
		    
	For nI := 1 To FCount()
	
		AADD( aPay , {FieldName(nI) , FieldGet(nI)} )
		
	Next nI
	
	AADD( aSL4 , aPay )
	
	aPay := {}	
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )  

RestArea(aArea)

Return aSL4


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISGetFieldOptions
Busca de opções de orcamento em outro ambiente
@param   cField				Campo utilizado para busca
@param   cFieldAssigned		Conteúdo do campo para busca
@param   aFieldsAdd			Campos adicionais a serem buscados
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aOptions				Opções de orcamentos encontrados, contendo n orcamentos. Retorna os campos
@return  aOptions[1]			Numero do Orcamento	-> L1_NUM
@return  aOptions[2]			Numero da DAV/PRE		-> L1_NUMORC
@return  aOptions[3]			Nome do CLiente		-> A1_NOME				
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISGetFieldOptions( cField , cFieldAssigned , aFieldsAdd )

Local aOptions	   		:= {}					// Retorno funcao
Local aAux					:= {}					// Armazena aOptions temporario
Local cOptionsTemp 		:= GetNextAlias()		// Armazena Proximo alias disponível
Local cFieldExp			:= ""					// Expressao do campo preenchido
Local cAddSELECT			:= ""					// Expressao com campos adicionais a buscar
Local nI					:= 0					// Contador

Default cField				:= ""
Default cFieldAssigned		:= ""
Default aFieldsAdd			:= {}

ParamType 0 Var 	cField 			As Character	Default ""	
ParamType 1 Var  	cFieldAssigned	As Character	Default ""
ParamType 2 Var  	aFieldsAdd			As Array		Default {}

cFieldAssigned := AllTrim(cFieldAssigned)

/*/
	Monta expressão dos campos adicionais
/*/
cAddSELECT := "%"
For nI := 1 To Len(aFieldsAdd)
	If 	SL1->(ColumnPos(aFieldsAdd[nI])) > 0
		cAddSELECT := cAddSELECT + " , " + aFieldsAdd[nI]
	Else
		aDel(aFieldsAdd, nI)
		aSize(aFieldsAdd, nI-1)
	EndIf
Next nI
cAddSELECT := cAddSELECT + "%"

If cField = "L1_NUM" .AND. !Empty(cFieldAssigned) .AND. At("*",cFieldAssigned) == 0
	If Len(Alltrim(cFieldAssigned)) <> TamSX3("L1_NUM")[1] 			
		cFieldAssigned := StrZero(Val(cFieldAssigned),TamSX3("L1_NUM")[1])
	EndIf
EndIf 

/*/
	Monta Expressão do campo de pesquisa
/*/
If SuperGetMv("MV_LJORPAR",,.F.) // "Procura de orçamento por parte do conteudo de busca?" Utiliza LIKE
	
	cFieldAssigned := StrTran(cFieldAssigned,"*","%")	

	If (cField == "A1_NOME" .OR. cField == "A1_NREDUZ")
		cFieldExp := 	"%(A1_NOME LIKE '" + cFieldAssigned + "' OR " + ;
						"A1_NREDUZ LIKE '" + cFieldAssigned + "') AND%"
	Else
		cFieldExp := "%" + cField + " LIKE '" + cFieldAssigned + "' AND%"
	EndIf
	
Else  
	cFieldExp := "%" + cField + " = '" + cFieldAssigned + "' AND%"
EndIf


BeginSql ALIAS cOptionsTemp  

						%NoParser%
						
						SELECT	 L1_NUM , A1_NOME , L1_NUMORC %exp:cAddSELECT%  
					
						FROM %table:SL1% SL1
						INNER JOIN %table:SA1% SA1 ON 	A1_COD 	= 	L1_CLIENTE		AND
															A1_LOJA	=	L1_LOJA
						WHERE	
								L1_FILIAL		=	%xfilial:SL1%				AND	
								A1_FILIAL		=	%xfilial:SA1%				AND	
								L1_DTLIM 		>= 	%exp:DTOS(dDataBase)%		AND
								L1_DOC      	=   " "							AND
								L1_DOCPED		=	" "							AND
								%exp:cFieldExp%
								SL1.%notDel%									AND
								SA1.%notDel%									AND
								(
								 	(
								 		L1_SERIE    =	" "				AND	
								 		L1_PDV		=	" "				AND
										L1_STORC	<>	"C"
									) OR
									(
										L1_RESERVA	<>	" " 			AND
										L1_STATUS	<>	"D"				
									)
								)
EndSql

LjGrvLog( "STDISGetFi",  "SQL:  " + GetLastQuery()[2] )

				
While !(cOptionsTemp)->(EOF()) 
	
	// Verifica se existe arquivo informando que o orcamento ja foi importado
	// So add se o arquivo nao existir
	If !FR271HArq ( {{ (cOptionsTemp)->L1_NUM , "" }} , .T., Nil , .T. )[1]
		  
		AADD( aAux , (cOptionsTemp)->L1_NUM 		)		
		AADD( aAux , (cOptionsTemp)->L1_NUMORC 	)
		AADD( aAux , AllTrim((cOptionsTemp)->A1_NOME) 		)
					    
		For nI := 1 To Len(aFieldsAdd)
		
	   		AADD( aAux , (cOptionsTemp)->&(aFieldsAdd[nI])	)
			
		Next nI
		
		AADD( aOptions , aAux )
		
		aAux := {}
	
	EndIf
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

DbSelectArea( "SL1" ) // Seleção de tabela (preventiva)

Return aOptions


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISGetOptions
Busca das opções de orçamento
@param   nOption				Opção de pesquisa. 2 -> Todos 3 -> Data
@param   lIsPafPdv			Conteúdo do campo para busca
@param   lSearchAll			Busca Todas as vendas PAFECF
@param   aFieldsAdd			Campos adicionais a serem buscados
@param   dDataMov				Data do movimento a realizar a Busca PAFECF 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aOptions				Opções de orcamentos encontrados, contendo n orcamentos. Retorna os campos
@return  aOptions[1]			Numero do Orcamento	-> L1_NUM
@return  aOptions[2]			Numero da DAV/PRE		-> L1_NUMORC
@return  aOptions[3]			Nome do CLiente		-> A1_NOME				
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISGetOptions( 	nOption , lIsPafPdv , lSearchAll , aFieldsAdd 	,;
							  	dDataMov												)

Local aOptions			:= {}					// Retorno da funcao
Local cDateExp			:= "%%"					// Armazena Expressão de data de emissao
Local cOrderBy			:= "%%"					// Expressao ordenação
Local cAddSELECT		:= ""					// Expressao com campos adicionais a buscar
Local cOptionsTemp		:= GetNextAlias()		// Pega o proximo Alias Disponivel
Local nI				:= 0					// Contador
Local aAux				:= {}					// Auxiliar	

Default nOption				:= 0
Default lIsPafPdv			:= .F.
Default lSearchAll			:= .F.
Default aFieldsAdd			:= {}
Default dDataMov				:= dDataBase

ParamType 0 Var 		nOption 			As Numeric		Default 0
ParamType 1 Var  	lSearchAll			As Logical		Default .F.
ParamType 2 Var  	aFieldsAdd			As Array		Default {}

/*/
	Monta expressão dos campos adicionais
/*/    
If Len(aFieldsAdd) > 0
	cAddSELECT := "%"
	For nI := 1 To Len(aFieldsAdd)
		If SL1->(ColumnPos(aFieldsAdd[nI])) > 0 
			cAddSELECT := cAddSELECT + " , " + aFieldsAdd[nI]
		Else
			aDel(aFieldsAdd, nI)
			aSize(aFieldsAdd, nI-1)
		EndIf
	Next nI
	cAddSELECT := cAddSELECT + "%" 
EndIf	

If nOption == 3 // DATA  
	cDateExp := "%L1_EMISSAO	= '"+ DTOS(dDataBase)+"'	 AND%"
EndIf

cOrderBy := "%L1_NUM , A1_NOME, L1_NUMORC%"

Do Case

	Case lIsPafPdv .AND. lSearchAll // PAF - Redução Z 
		
		// TODO: Verificar se tem que tirar a DateExp da query quando for LOJA160
		BeginSql alias cOptionsTemp
				
				%NoParser%
				
				SELECT	 L1_NUM , A1_NOME, L1_NUMORC %exp:cAddSELECT%
				
				FROM %table:SL1% SL1 ,%table:SA1% SA1
				
				WHERE	L1_FILIAL		=	%xfilial:SL1%					AND	
						A1_FILIAL		=	%xfilial:SA1%					AND	
						L1_DTLIM 		< 	%exp:DTOS(dDataMov)%  			AND
						L1_SERIE		=  " "								AND
						L1_DOC			=  " "   	                		AND
						L1_PDV			=  " "       	           			AND
						L1_STORC		<> "C"								AND
						L1_ORCRES		=  " "								AND
						L1_CLIENTE		=  A1_COD							AND
						L1_LOJA	   		=  A1_LOJA                			AND
						L1_SITUA		=  " "								AND	
						L1_TPORC		=  "P"							    AND					
						SL1.%notDel%										AND
						SA1.%notDel% 
						                           
				ORDER BY %exp:cOrderBy%
		EndSql	  

	Case lIsPafPdv // PAF
		BeginSql alias cOptionsTemp
				
				%NoParser%
				
				SELECT	 L1_NUM ,A1_NOME, L1_NUMORC %exp:cAddSELECT%
				
				FROM %table:SL1% SL1 ,%table:SA1% SA1 
				
				WHERE	L1_FILIAL		=	%xfilial:SL1%				AND	
						A1_FILIAL		=	%xfilial:SA1%				AND	
						L1_DTLIM 		>= 	%exp:DTOS(dDataBase)%		AND
						L1_CLIENTE  	=  A1_COD						AND
						L1_LOJA  		=  A1_LOJA            			AND
						L1_PEDRES		=  " "							AND
						L1_DOCPED		=  " "							AND
						L1_DOC      	=  " "							AND
						((L1_SERIE  	=  " "							AND
						L1_PDV      	=  " "       	        		AND
						L1_STORC 		<> "C"							AND
						%exp:cDateExp%
						SL1.%notDel%									AND
						SA1.%notDel%)            						OR	 
				    	(L1_RESERVA		<> " "							AND
						 L1_STATUS 		<> "D"							))
									
				ORDER BY %exp:cOrderBy%
				
		EndSql    
	
	Otherwise // Normal

		BeginSql alias cOptionsTemp

				%NoParser%
				
				SELECT L1_NUM , A1_NOME , L1_NUMORC %exp:cAddSELECT%
			
				FROM %table:SL1% SL1 ,%table:SA1% SA1
				 
				WHERE	L1_FILIAL		=	%xfilial:SL1%				AND	
						A1_FILIAL		=	%xfilial:SA1%				AND	
						L1_DTLIM 		>= 	%exp:DTOS(dDataBase)%  		AND
						L1_DOC      	=  	" "   	            		AND
						L1_DOCPED		=	" "							AND
						L1_CLIENTE 		=  	A1_COD					   	AND
						L1_LOJA  		=  	A1_LOJA              		AND
						L1_PEDRES     	=  	" "		  				    AND
						%exp:cDateExp%
						SL1.%notDel%									AND
						SA1.%notDel%									AND
						(
						 	(
						 		L1_SERIE    =	" "				AND	
						 		L1_PDV		=	" "				AND
								L1_STORC	<>	"C"
							) OR
							(
								L1_RESERVA	<>	" " 			AND
								L1_STATUS	<>	"D"				
							)
						)
					
				ORDER BY %exp:cOrderBy%
				
		EndSql        
			
EndCase
           
LjGrvLog( "STDISGetOp",  "SQL:  " + GetLastQuery()[2] )

While !(cOptionsTemp)->(EOF()) 
	
	// Verifica se existe arquivo informando que o orcamento ja foi importado
	// So add se o arquivo nao existir
	If !FR271HArq ( {{ (cOptionsTemp)->L1_NUM , "" }} , .T., Nil , .T. )[1]
			  
		AADD( aAux , (cOptionsTemp)->L1_NUM 		)		
		AADD( aAux , (cOptionsTemp)->L1_NUMORC 	)
		AADD( aAux , AllTrim((cOptionsTemp)->A1_NOME )	)
		
	
		For nI := 1 To Len(aFieldsAdd)
			AADD( aAux , (cOptionsTemp)->&(aFieldsAdd[nI])	)
		Next nI

		AADD( aOptions , aAux )
		
	EndIf	
	
	aAux := {}
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

DbSelectArea( "SL1" ) // Seleção de tabela (preventiva)

Return aOptions


//-------------------------------------------------------------------
/*/{Protheus.doc} STDISSearchField
Retorna a estrutura do campo de pesquisa para Interface

@param   cField		Nome do Campo   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  aField -> Retorna a estrutura do campo de pesquisa para a interface
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDISSearchField(cField)

Local aField		:= {}				// Estrutura do campo de pesquisa para interface
Local cLabelScreen	:= ""				// Label da interface
Local bValid		:= {|| .T.}			// ValiCAIXAPOSdação do campo

Default cField		:= ""

ParamType 0 Var cField As Character	Default ""

If !Empty(cField)

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cField))
		
		Do Case 
		
			Case cField == "A1_CGC"
		
				cLabelScreen := AllTrim( X3Titulo()  )
		
			Case cField == "L1_NUMORC"
			
				If SuperGetMv("MV_LJPRVEN",,.T.) 	// Utiliza Pre-Venda:
					cLabelScreen := "Pre-Venda"
				Else
					cLabelScreen := "DAV"			// Utiliza DAV
				EndIf
				
			OtherWise
			
				cLabelScreen := AllTrim( X3Titulo()  )
				
		EndCase
		  			
		AAdd( aField		, 	cLabelScreen			        		  		) 	// [01] Titulo do campo
		AAdd( aField		,	AllTrim( X3Descric() )         				)	// [02] ToolTip do campo
		AAdd( aField		,	AllTrim( SX3->X3_CAMPO )         	  		)	// [03] Id do Field
		AAdd( aField		,	SX3->X3_TIPO                  		  		)	// [04] Tipo do campo
		AAdd( aField		,	SX3->X3_TAMANHO               		  		)	// [05] Tamanho do campo
		AAdd( aField		,	SX3->X3_DECIMAL                				)	// [06] Decimal do campo
		AAdd( aField		,	bValid                         				)	// [07] Code-block de validacaoo do campo
		AAdd( aField		,	Nil                          				)	// [08] Code-block de validacaoo When do campo
		AAdd( aField		,	StrTokArr( AllTrim( X3CBox() ),';')  		)	// [09] Lista de valores permitido do campo
		AAdd( aField		,	Nil 											)	// [10] Indica se o campo tem preenchimento obrigatorio
		AAdd( aField		,	Nil                         				)	// [11] Code-block de inicializacao do campo
		AAdd( aField		,	Nil                            				)	// [12] Indica se trata-se de um campo chave
		AAdd( aField		,	Nil                            				)	// [13] Indica se o campo pode receber valor em uma operacao de update.
		AAdd( aField		,	.F.							     				)  	// [14] Indica se o campo e virtual
		
	EndIf
	
EndIf

Return(aField)

//-------------------------------------------------------------------
/*/{Protheus.doc} STDIMPPROD
Importa as informacoes do produto da retaguarda, para posteriormente cadastra-lo na base local

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDIMPPROD( cProdCode, aFieldsProd )
Local aArea   := GetArea()
Local aCampos := {}							// Array de campos
Local aRet    := {}							// Parâmetro de retorno
Local nX      := 0							// Contador

DEFAULT cProdCode := ""

LjGrvLog("Importa_Orcamento:STDImpProd","Comunicação OK")

DbSelectArea("SB1")
DbSetOrder(1)//B1_FILIAL+B1_COD
If 	DbSeek( xFilial("SB1")+cProdCode )
	For nX := 1 to Len(aFieldsProd)
		AAdd(aRet,{aFieldsProd[nX],&("SB1->"+aFieldsProd[nX]),Nil})
	Next nX
EndIf

RestArea(aArea)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STDValLock
Valida se o orçamento está com lock, ou seja, se está sendo alterado por outro usuário
@param   sNumOrc  Número do Orçamento L1_NUM
@author  Varejo
@version P12
@since   29/01/2021
@return  lRet  Se o orçamento estiver sendo utilizado retorno .T. 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDValLock(sNumOrc)
Local lRet  := .F. 

DbSelectArea("SL1")
DbSetOrder(1)

If SL1->(DbSeek(xfilial("SL1") + sNumOrc))
	If SL1->(SimpleLock()) //tenta dar lock no registro, se retornar .F. significa que está com lock
		SL1->(MsUnLock())
	Else
		lRet :=.T. 
	Endif 	
Endif 

Return  lRet


/*/{Protheus.doc} STDAltRegL1
	Se for recebimento de multiplos orçamentos e PDV ONLINE precisa ajustar os registros dos orçamentos
	originais 
	@type  Function
	@author caio.okamoto
	@since 10/08/2023
	@version 12.1.2210
	/*/
Function STDAltRegL1()

Local oModel 	:= STDGPBModel()
Local aMultOrc	:= STDMultOrc() 
Local nI		:= 0
Local cChave	:= ""

LjGrvLog(NIL, "Importação de Orçamento PDV Online -Atualiza os Orçamentos originais quando for Multiplos", aMultOrc )

If Len(aMultOrc) >= 1
// retorna L2_NUMORIG dos orçamentos, se retornar mais de 1 registro significa que foi importação de multiplos orçamentos
// se retornar apenas um registro significa que foi importado orçamento após lançar itens no PDV.

	For nI := 1 To Len(aMultOrc)
		cChave	:=	aMultOrc[nI]
		DbSelectArea("SL1")
		DbSetOrder(1)	//L1_FILIAL+L1_NUM
		If !Empty(cChave) .AND. DbSeek(xFilial("SL1")+cChave)

			RecLock("SL1",.F.)//alteracao
		
			REPLACE	SL1->L1_SERIE	WITH	oModel:GetValue("SL1MASTER" , "L1_SERIE")
			REPLACE	SL1->L1_SERPED	WITH	oModel:GetValue("SL1MASTER" , "L1_SERPED")
			REPLACE	SL1->L1_DOC		WITH	oModel:GetValue("SL1MASTER" , "L1_DOC")
			REPLACE	SL1->L1_DOCPED	WITH	oModel:GetValue("SL1MASTER" , "L1_DOCPED")
			REPLACE	SL1->L1_PDV		WITH	oModel:GetValue("SL1MASTER" , "L1_PDV")
			REPLACE	SL1->L1_CONFVEN	WITH	"SSSSSSSSNSSS"
			REPLACE	SL1->L1_SITUA	WITH	"FR"
			REPLACE	SL1->L1_STATUS	WITH	"F"
			REPLACE	SL1->L1_EMISNF	WITH	oModel:GetValue("SL1MASTER" , "L1_EMISNF")
			REPLACE	SL1->L1_OPERADO	WITH	oModel:GetValue("SL1MASTER" , "L1_OPERADO")
			REPLACE	SL1->L1_ESTACAO	WITH	oModel:GetValue("SL1MASTER" , "L1_ESTACAO")
			REPLACE	SL1->L1_NUMFRT	WITH	oModel:GetValue("SL1MASTER" , "L1_NUM")
			REPLACE	SL1->L1_IMPRIME	WITH	"1S"
		
			SL1->(MsUnlock())
			SL1->( DbSkip() )	

		Endif

	Next nI

EndIf

Return 

/*/{Protheus.doc} STDMultOrc
	Verifica se foi recebimento de multiplos Orçamentos
	@type  Function
	@author caio.okamoto
	@since 10/08/2023
	@version 12.1.2210
	/*/

Function STDMultOrc()
Local oModel 		:= STDGPBModel()
Local nX 			:= 0
Local nQtRegSL2 	:= STDPBLength("SL2")
Local aMultOrc		:= {}

For nX:= 1 to nQtRegSL2	
	oModel:GetModel("SL2DETAIL"):GoLine(nX)
	If !Empty(oModel:GetValue("SL2DETAIL", "L2_NUMORIG")) .AND. !oModel:GetModel("SL2DETAIL"):IsDeleted(); 
	.AND. oModel:GetValue("SL2DETAIL", "L2_NUMORIG") <> oModel:GetValue("SL2DETAIL", "L2_NUM");
	.AND. AScan( aMultOrc, {|x| x == oModel:GetValue("SL2DETAIL", "L2_NUMORIG")} ) == 0 
		aAdd(aMultOrc, oModel:GetValue("SL2DETAIL", "L2_NUMORIG") ) 
	EndIf
Next nX 

LjGrvLog(NIL, "Importação de Orçamento PDV Online - Pega os L2_NUMORIG", aMultOrc )

Return aMultOrc


/*/{Protheus.doc} STDNomeVen
Retorna o nome do Vendedor
@type  		Function
@param 		cA3COD		, caracter, código do vendedor
@author 	caio.okamoto
@since 		12/02/2024
@return 	cA3NReduz	, caracter, nome do vendedor 
@version 	12.1.2310
/*/
Function STDNomeVen(cA3COD)
Local cA3NReduz	:= ""
Local aArea     := GetArea()

cA3COD	:= PadR(cA3COD, TamSx3("A3_COD")[1])	
DbSelectArea("SA3")
SA3->(DbSetOrder(1))//A3_FILIAL+A3_COD

If SA3->(DbSeek( xFilial('SA3') + cA3COD ))
	cA3NReduz:= " - " + SA3->A3_NREDUZ
Endif  

RestArea(aArea)
Return cA3NReduz


/*/{Protheus.doc} STDBuscaNccOrc
	Quando ao ambiente é Central de Pdv, tem a necessidade de buscar Ncc pendents na MDK e MDJ 
	na Central para depois buscar na SE1. Para isso, busca a MDK_NUMREC na Central de Pdv para depois
	buscar o titulo SE1 R_E_C_N_O_ da SE1 é igual a MDK_NUMREC 
	@type  Function
	@author caio.okamoto
	@since 22/11/2024
	@version 12
	@param cNumOrc, param_type, L1_NUM do Orçamento
	@return aSe1Recnos, array, array com numeros da R_E_C_N_O_ dos titulos na SE1
	/*/
Function STDBuscaNccOrc(cNumOrc)
Local aSe1Recnos 		:= {}
Local aArea 			:= GetArea()		
Local cOptionsTemp 		:= GetNextAlias()	
Local nI				:= 0				
Local cNumExp			:= ""				
Local cSituaExp			:= ""
Local aFieldsImp 		:= {}
Local axTesSql 			:= {}
Local caxTesSql			:= ""

Default cNumOrc			:= ""

If !Empty(cNumOrc)
	cNumExp := "%'" + StrZero(Val(cNumOrc),TamSX3("L1_NUM")[1]) + "'%"
EndIf

aFieldsImp	:= MDK->(dbStruct()) //Todos os campos

cSituaExp:= "%'"+ "OR" + "'%" 

BeginSql ALIAS cOptionsTemp  

	SELECT MDK_NUMREC 
	FROM %table:MDK% MDK
	INNER JOIN %table:MDJ% MDJ ON MDJ_FILIAL = MDK_FILIAL AND MDJ.%NotDel%
		WHERE 
			MDJ_NUMORC = MDK_NUMORC 		AND 
			MDJ_SITUA  = %exp:cSituaExp% 	AND 
			MDJ_NUMORC = %Exp:cNumExp%		AND 
			MDK.%NotDel% 
EndSql

axTesSql :=   GetLastQuery()
caxTesSql := axTesSql[2]

LjGrvLog(cNumOrc, "Query para busca de MDK_NUMREC",  caxTesSql )

DbSelectArea(cOptionsTemp)

While !(cOptionsTemp)->(EOF()) 
	    
	For nI := 1 To FCount()
		AADD( aSe1Recnos , FieldGet(nI))
	Next nI
	
	(cOptionsTemp)->(DbSkip())
	
EndDo

(cOptionsTemp)->( DbCloseArea() )

RestArea(aArea)

LjGrvLog(cNumOrc, "MDK_NUMREC Retornados",  aSe1Recnos )

Return aSe1Recnos 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGetValSL4
Retorna o valor restante pago do orçamento retira posterior que,
esse valor é referente a NCC, pois os demais valores são gerados na 
SL4. 
@param   aSL4, 		Array,  SL4 que está sendo importada. 
@author  Jeferson Mondeki
@version P12
@since   26/05/2025
@return  nValor,	Numerico,  Retorna o valor restante pago em NCC. 
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGetValSL4(aSL4)

Local nValor 		:= 0  					//Retrona o valor restante
Local cL4NUM 		:= "" 					//L4_NUM para busca das formas de pagamento
Local aAreaSL4	 	:= SL4->(GetArea())		//Area seleciona

cL4NUM := aSL4[1][Ascan(aSL4[1] , { |x| x[1] == "L4_NUM" } )][2]

If !Empty(cL4NUM)
	DbSetOrder(1) //L4_FILIAL+L4_NUM+L4_ORIGEM
	If SL4->(DbSeek(xFilial("SL4") + cL4NUM))
		While SL4->( !EOF() ) .AND. (SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + cL4NUM)
			nValor += SL4->L4_VALOR
			SL4->( DbSkip() )
		EndDo
	EndIf
EndIf

If nValor > 0 
	nValor := STDGPBasket("SL1","L1_VLRTOT") - STIGetTotal()
Else
	nValor := STDGPBasket("SL1","L1_VLRTOT")
EndIf

RestArea(aAreaSL4)

Return nValor
