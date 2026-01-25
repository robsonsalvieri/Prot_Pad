#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBDigItem
Procedimento para digitacao de quantidade x item
Caso Trabalhe com seperador de digito:
Pega o Codigo recebido/digitado e separa em Codigo do Item
e quantidade do Item, conforme configuracao do parameto

@param   cCodeReceived			Codigo recebido/digitado
@author  Varejo
@version P11.8
@since   29/03/2012
@return  cCodeReceived			Codigo recebido/digitado separado de acordo com parametro
@obs     
@sample
/*/
//-------------------------------------------------------------------

//
Function STBDigItem(cCodeReceived)

Local cDigQtde	   	:= Alltrim(SuperGetMV("MV_FRTDIGQ",,"")) 		//Digito separador de quantidade x produto	
Local nI				:= 0													//Variavel auxiliar

Default		cCodeReceived		:= ""			// Codigo recebido/digitado

ParamType 0 Var cCodeReceived As Character	Default ""

/*
	Caso Trabalhe com seperador de digito:
	Pega o Codigo recebido/digitado e separa em Codigo do Item
	e quantidade do Item, conforme configuracao do parameto
*/

If !Empty(cDigQtde)

	nI := At(cDigQtde, cCodeReceived)
	If nI > 0
		nTmpQuant 			:= Val(PadL(cCodeReceived, nI -  1))
		cCodeReceived 	:= SubStr( cCodeReceived, nI + 1, Len(cCodeReceived))
	EndIf
	
	/*
		Se encontrou Qtde > 1 Altera Qtde
	*/
	If nTmpQuant > 1	
		STBSetQuant( nTmpQuant )		
	EndIf
	
	
EndIf

Return cCodeReceived

//-------------------------------------------------------------------
/*/{Protheus.doc} STIRecProdMFL
Prepara a gravacao dos Registros no MFL conforme os parametros recebidos
@param aProCode - Resultado de Produtos Consultados
@author Varejo 
@version P11.8 
@since 15/07/2013
@return Nil 
@obs 
@sample
/*/
//-------------------------------------------------------------------

Function STIRecProdMFL(aProCode)
Local lRet 		:= .F.
Local nFor 		:= 0
Local cStation	:= STFGetStation("LG_PDV")	// PDV atual
Local cCaixa	:= STDNumCash()
Local aMFL 		:= {}

For nFor := 1 To Len(aProCode)	
	
	aMFL := {{"MFL_FILIAL"	,	xFilial("MFL")		}	,;
			 {"MFL_PRODUT"	,	aProCode[nFor][01]	}	,;
			 {"MFL_CAIXA"	,	cCaixa		   		}	,;
			 {"MFL_PDV"		,	cStation			}	,;
			 {"MFL_DATA"	,	dDataBase	   		}	,;
			 {"MFL_HORA"	,	Time() 		   		}	,;
			 {"MFL_SITUA"	,	"00" 		   		}	}			 

	lRet := STFSaveTab("MFL", aMFL, .T., .T.)
	
	If lRet
		STFSLICreate("    ", "MFL", Str(MFL->(Recno()),17,0), "NOVO")
	EndIf

Next nFor

Return Nil


/*{Protheus.doc} STBGetProd
Funcao responsavel pela busca de produtos no banco de dados da Retaguarda (Base TOP).

@param		cFil 		Filial a ser realizada a busca.
@param		cDescProd	Descrição do Produto a ser pesquisado.
@param		nLimitRegs	Quantidade Limite de registros que se deseja pesquisar. 
@author 	Varejo
@since 		07/05/2015
@version 	11.80
*/
//-------------------------------------------------------------------
Function STBGetProd(cFil, cDescProd, nLimitRegs)
Local uDados	       	:= {}
Local aParam          	:= {}
Local uResult         	:= Nil
Local aFields 			:= {}
Local aTables 			:= {} 
Local cWhere 			:= ""
Local cOrderBy 			:= ""

cDescProd := AllTrim(cDescProd)
cDescProd := Replace(cDescProd,"*","%")

//Monta os campos da query
aFields := {"B1_COD", "B1_DESC"}

//Tabela da Query
aTables := {"SB1"}

//Monta a Cláusula Where da query
cWhere := "B1_FILIAL = '"+cFil+"' AND "
cWhere += "B1_DESC LIKE '" + cDescProd + "' AND "
cWhere += "D_E_L_E_T_ = ' '"

//Monta a Cláusula Order By da query
cOrderBy := "B1_DESC"

// Busca de Clientes via STBRemoteExecute
aParam 	:= {	aFields,;
				aTables,;
				cWhere,;
				cOrderBy,;
				nLimitRegs;
			}
			
If !STBRemoteExecute("STDQueryDB", aParam,,, @uResult)
	// Tratamento do erro de conexao
	uDados := .F.
Else
	uDados := uResult
EndIf 

Return uDados
