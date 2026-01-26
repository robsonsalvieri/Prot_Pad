#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STFSAVETAB.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STFSaveTab
Realiza a gravacao dos campos passado em array no Alias correspondente

@param		cAlias			Alias para gravacao 
@param 	aArray			Array com Campos e valores a serem gravados
@param 	lAppend 		Indica se cria novo registro na tabela
@param 	lUnLock 		Indica se trava o registro para alteracao
 
@author  Varejo
@version P11.8
@since   29/06/2012
@return  lRet 			Retorna se conseguiu gravar
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFSaveTab( cAlias , aArray , lAppend , lUnLock )

Local aArea		:= GetArea()	// Guarda area

Local lRet		:=	.T.			//	Retorno

Default	cAlias			:= ""			// Alias para gravacao 
Default 	aArray			:= {}			//	array com Campos e valores a serem gravados
Default 	lAppend 		:= .F.			//	Indica se cria novo registro na tabela
Default 	lUnLock 		:= .T.			//	Indica se trava o registro para alteracao

ParamType 0 Var 	cAlias	 		As Character	Default 	""
ParamType 1 Var   aArray 		As Array		Default 	{}
ParamType 2 var  	lAppend		As Logical		Default 	.F.
ParamType 3 var  	lUnLock		As Logical		Default 	.T.

If AliasInDic(cAlias)
	DbSelectArea(cAlias)
	CoNout(STR0001 + cAlias)		//'TABELA: '

	If !lAppend .And. !lUnLock
		// Verifica se o arquivo esta disponivel para alteracao
		lRet := MsRLock()
		CoNout(STR0002 + cAlias)	//'MsRLock: '
	Else
		// Trava o registro para alteracao
		lRet := RecLock(cAlias, lAppend)
		CoNout(STR0003 + cAlias)	//'RecLock: '
	EndIf

	If lRet
		// Insere os registros do array
		AEval(aArray, {|x| FieldPut(FieldPos(x[1]), x[2])})
	
		// Se travou registro, confirma a transacao e destrava o registro
		If lUnLock
			dbCommit()
			MsUnLock()
			CoNout(STR0004 + cAlias)	//'dbCommit: '
			LjGrvLog(STR0005, 'MsUnLock ' + cAlias)	//'MsUnLock '
		EndIf
	
	Else	
		ConOut(STR0006+cAlias+STR0007+AllTrim(Str(Recno()))+".") //"Impossível travar arquivo" ### "Registro: "
		LjGrvLog("STFSaveTab", STR0006+cAlias+STR0007+AllTrim(Str(Recno()))+".")		//"Impossível travar arquivo" ### "Registro: "
	EndIf
Else
	ConOut(STR0008+cAlias+STR0009)	//"A tabela " ### " näo existe na retaguarda!" 
EndIf

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFSLICreate
Realiza a gravacao dos campos da tabela de Monitoramento das Estacoes(SLI)

@param	cStation		Estacao
@param  cType			Tipo operacao
@param  cMsg			Mensagem
@param  cChoice 		Decisao
@param 	lUnLock  		Trava o registro
@param 	cOperName		Usuario	
@param 	dDate   		Data
@param  cHour   		Hora

@param 	cAlias	   Alias a subir ao server
@param 	nRecno     Numero do recno a subir para server
@param  cFunc      Opcional - Funcao a ser executada no server para subir registro
 
@author  Varejo
@version P11.8
@since   29/06/2012
@return  lOpenCash 	Retorna se o caixa esta aberto
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STFSLICreate(	cStation	, cType			, cMsg			, cChoice		, ;
							lUnLock	, cOperName		, dDate		, cHour		, ;
							cAlias		, nRecno	    	, cFunc 						)

Local aSLI				:=	{}		// Array Usado para gravar SLI
Local lRet				:= .F.		// Retorno
Local lAppend 			:= .F.		// Cria novo registro
Local cLstSeq			:= "0" //Ultima Sequencia
Local lLi_Seq			:= SLI->(ColumnPos("LI_SEQ")) > 0 //Existe campo sequencia?
Local cChave			:= "" //Chave de Busca
Local nTamLiSeq			:= 0 //Tamanho do campo LI_SEQ

Default cStation		:= STFGetStat("CODIGO")	// Estacao
Default cType		:= ""						// Tipo operacao
Default cMsg			:= ""						// Mensagem
Default cChoice 		:= "ABANDONA"				// Decisao
Default lUnLock  	:= .T.						// Trava o registro
Default cOperName	:= cUserName				// Usuario	
Default dDate   		:= dDataBase				// Data
Default cHour   		:= Time()					// Hora
Default cAlias		:= ""						// Alias a subir ao server
Default nRecno		:= 0						// Numero do recno a subir para server
Default cFunc		:= ""						// Opcional - Funcao a ser executada no server para subir registro

ParamType 0 Var	cStation		As Character		Default  STFGetStat("CODIGO")			
ParamType 1 Var	cType			As Character		Default  ""			
ParamType 2 Var	cMsg			As Character		Default  ""			
ParamType 3 Var	cChoice 		As Character		Default  "ABANDONA"	
ParamType 4 Var	lUnLock 		As Logical			Default  .T.			
ParamType 5 Var	cOperName		As Character		Default  cUserName	
ParamType 6 Var	dDate   		As Date				Default  dDataBase	
ParamType 7 Var	cHour   		As Character		Default  Time()	
ParamType 8 Var	cAlias		    As Character		Default  ""
ParamType 9 Var	nRecno   		As Numeric			Default 	0
ParamType 10 Var cFunc   		As Character		Default  ""	

If lLi_Seq
	nTamLiSeq := TamSx3("LI_SEQ")[1]
	cLstSeq := Replicate("0", nTamLiSeq) 
	cLstSeq := Soma1(cLstSeq, nTamLiSeq)
EndIf

SLI->(DbSetOrder(1)) //LI_FILIAL+LI_ESTACAO+LI_TIPO+LI_SEQ
cChave := xFilial("SLI")+PadR(cStation,TamSx3("LI_ESTACAO")[1])+PadR(cType, TamSx3("LI_TIPO")[1])
lAppend := !SLI->(DbSeek(cChave))

If !lAppend // Se registro ja existe

	If cChoice == "ABANDONA"
		lRet := .F.
	ElseIf cChoice == "SOBREPOE"
		lAppend := .F.
		lRet 	:= .T.
	ElseIf cChoice == "NOVO"
		lAppend := .T.
		lRet 	:= .T.
	EndIf    
Else
	lRet := .T.
EndIf	

//Procura a última sequencia enviada
If lAppend .AND. lRet .AND. lLi_Seq .AND. SLI->(Found())
	
	//Artifício para ir até o último registro rapidamente
	//Pesquisa DbSeek cuja chave termina com 9999999999, para depois voltar o dbskip um registro anterior
	SLI->(DbSeek(cChave + Replicate("9", nTamLiSeq),.T.))	//com Softseek
	If SLI->(EOF())
		SLI->(DbGoBottom())
	Else
		SLI->(DbSkip(-1))
	EndIf
	cLstSeq := SLI->LI_SEQ
	
	Do While SLI->(DbSeek(cChave+cLstSeq))
		cLstSeq := Soma1(cLstSeq, nTamLiSeq)
	EndDo
EndIf

If lRet
	aSLI := {{"LI_FILIAL"	,	xFilial("SLI")	}	,;
			 {"LI_ESTACAO"	,	cStation		}	,;
			 {"LI_TIPO"		,	cType			}	,;
			 {"LI_USUARIO"	,	cOperName		}	,;
			 {"LI_DATA"		,	dDate			}	,;
			 {"LI_HORA"		,	cHour			}	,;
			 {"LI_MSG"		,	cMsg			}	,;			 
			 {"LI_ALIAS"	,	cAlias			}	,;
			 {"LI_UPREC"	,	nRecno			}	,;
			 {"LI_FUNC"		,	cFunc			}	}
	If lLi_Seq
		aAdd(aSLI, {"LI_SEQ", cLstSeq})
	EndIf
			 
	lRet := STFSaveTab("SLI", aSLI, lAppend, lUnLock)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFPesqTab
Realiza a pesquisa na tabela e retorna as informacoes solicitadas em parametros

@param	cTabela    	Alias para gravacao 
@param 	nOrder   		Ordem de busca
@param 	cChave   		Chave com campos da busca
@param 	cBusca   		Valores da busca
@param 	aArray   		Array com Campos e valores a serem retornados
@param lFirst			Considera apenas o primeiro registro encontrado  - Opcional
@param 	cValid   		Valores da validacao - Opcional
 
@author  rafael.pessoa
@version P11.8
@since   31/05/2016
@return  aRet 			Retorna informacoes solicitadas
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFPesqTab( cTabela , nOrder , cChave		 , cBusca ,;
						aArray  , lFirst , cValid )

Local aRet		:=	{}			// Retorno
Local aAux		:=	{}			// Array auxiliar
Local nI		:=	0			// Contador
Local xRet		:= Nil			// Retorno de valor dos campos 
Local lValid	:= .F.			// Verifica se recebu validacao especifica 


Default	cTabela		:= ""			// Alias para gravacao 
Default 	nOrder			:= 0			//	Ordem de busca
Default 	cChave 		:= ""			//	Chave com campos da busca
Default 	cBusca 		:= ""			//	Chave com campos da busca
Default 	aArray 		:= {}			//	array com Campos e valores a serem retornados
Default 	lFirst 		:= .F.			//	Busca apenas primeiro registro que encontrar
Default 	cValid 		:= ""			//	Valores da validacao opcional

ConOut(STR0010 + cTabela )		//"Consulta de informaçöes na base. Alias: " 
LjGrvLog("STFPesqTab", STR0010 +cTabela  )	//"Consulta de informaçöes na base. Alias: "

ConOut(cTabela + "," + cChave + "," + cBusca)

// Verifica se recebu validacao especifica 
lValid := ! Empty(cValid)

If ValType(aArray) == "A" .AND.  Len(aArray) > 0
	DbSelectArea(cTabela)                                      
	DbSetOrder(nOrder)
	If DbSeek(cBusca)	
			
		ConOut(STR0011 +cTabela )		//"Encontrou informaçöes em sua busca. Alias: " 
		LjGrvLog("STFPesqTab", STR0011 +cTabela  )		//"Encontrou informaçöes em sua busca. Alias: "
		
		While &(cChave) == cBusca .AND. !EOF()
		
			If !lValid .OR. (lValid .AND. &(cValid) )
				aAux := {}
				For nI := 1 To Len(aArray)
				
					xRet := FieldGet( FieldPos( aArray[nI]) )
					
					AADD(aAux,{aArray[nI],xRet})
					
				Next nI			
			
				AADD( aRet, aAux )
				
				If lFirst //Busca apenas primeiro registro e retorna
					Exit
				EndIf
			
			EndIf	
			
			&(cTabela)->(DbSkip())
		
		EndDo	
	
	EndIf	
EndIf

Return aRet



//--------------------------------------------------------
/*/{Protheus.doc} STFAltTab
Altera os campos da tabela de acordo com os parametros recebidos
@param	cTabela    Alias para gravacao 
@param 	nOrder   	Ordem de busca
@param 	cBusca   	Valores da busca
@param aCampos - Informa o campo ou os campos que deseja atualizar
@author  rafael.pessoa
@version P11.8
@since   31/05/2016
@return  	lSet - Retorna se o campo foi gravado ou não
@obs     
@sample
/*/
//--------------------------------------------------------
Function STFAltTab( cTabela , nOrder , cBusca , aCampos )

Local aArea		:= GetArea()	//Salva area
Local lRet			:= .F. 		//Retorno da função 
Local nI			:= 0			//Contador

Default	cTabela		:= ""			// Alias para gravacao 
Default 	nOrder			:= 0			//	Ordem de busca
Default 	cBusca 		:= ""			//	Chave com campos da busca
Default 	aCampos 		:= {}			// Campos a alterar

ConOut(STR0012 + cTabela )	//"Alterar informaçöes da base. Alias: " 
LjGrvLog("STFAltTab",STR0012 + cTabela )	//"Alterar informaçöes da base. Alias: "

DbSelectArea(cTabela)                                      
DbSetOrder(nOrder)
If DbSeek(cBusca) 
	
	If RecLock(cTabela, .F.)
				
		For nI := 1 To Len(aCampos)
			FieldPut( FieldPos( aCampos[nI, 1]), aCampos[nI, 2])
		Next nI			
		
		&(cTabela)->(MsUnLock())	
		lRet := .T.
		ConOut(STR0013 + cTabela )		//"Informaçöes alteradas com sucesso. Alias " 
		LjGrvLog("STFAltTab",STR0013 + cTabela  )	//"Informaçöes alteradas com sucesso. Alias "
		
	EndIf

EndIf
	
RestArea(aArea)	

Return lRet
