#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH" 
#INCLUDE "STDUPDATA.CH"
#INCLUDE "XMLXFUN.CH"


Static oWS := NIL
Static oXML := NIL


//===================================================
// 				Situacoes do _SITUA                             
//
// "  " - Base Errada, Registro Ignorado.          
// "00" - Venda Efetuada com Sucesso               
// "01" - Abertura do Cupom Nao Impressa           
// "02" - Impresso a Abertura do Cupom             
// "03" - Item Nao Impresso                        
// "04" - Impresso o Item                          
// "05" - Solicitado o Cancelamento do Item        
// "06" - Item Cancelado                           
// "07" - Solicitado o Cancelamento do Cupom       
// "08" - Cupom Cancelado                          
// "09" - Encerrado SL1 (Nao gerado SL4)           
// "10" - Encerrado a Venda                        
//        Pode nao ter sido impresso o cupom       
// "TX" - Foi Enviado ao Server (Pdv)
// "ER" - Erro ao envia ao server (Pdv)  
// "EP" - Erro de processamento da venda (Pdv)
// "RE" - Ja foi feita nova tentativa de subir  (Pdv)                      
// "RX" - Foi Recebido Pelo Server (Server)                 
// "OK" - Foi Processado no Server (Serevr)               
//        Enviar um OK ao Client que foi Processado 
// "CP" - Recebido pela Central de PDV
// "RY" - Cancelamento Nfc-e
// "CX" - Cancelamento enviado first
// "C0" - Cancelamento a enviar first
//===================================================

Function STDFrstUp()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} STDLogCons
Enviado o Log para o Console

@param cMessage		Codigo da estacao

@author  Varejo
@version P11.8
@since   05/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Static Function STDLogCons( cMessage )  

Default cMessage := ""

ParamType 0 Var 	cMessage 	As Character	Default 	""

Conout(cMessage)  

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpFirstSale
Envia as Vendas para o First

@param aSL1			Array da Venda
@param aSL2			Array dos Itens
@param aSL4			Array dos Pagamentos
@param cEstacaoIni 	Estação
@param cStatusNum		Retorno da Subida 

@author  Varejo
@version P11.8
@since   05/05/2015
@return  lRet 			Execução com sucesso
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDUpFirstSale( aSL1, aSL2, aSL4, cEstacaoIni, ;
							cStatusNum)
//retirado conteudo da rotina por não existir a função chamada WSINTEGRACAOPDV() 
//PDV FIRST não está mais ativo
Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpDtFirst
Envia a movimentação  para o First

@Param   cAlias 	- Alias que sera usado
@Param   nOrder 	- Codigo de ordenacao
@Param   cChave 	- Campos de busca
@Param   cBusca 	- Conteudo de busca
@Param 	 cConfLocal 	- String de confirmacao de gravacao do campo Local	
@Param 	 cConfServer 	- String de confirmacao de gravacao do campo no server
@Param 	 cEstacaoIni 	- Estacao
@Param 	 cFunc		 	- Funcao a ser executado no server

@author  Varejo
@version P11.8
@since   16/01/2013
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDUpDtFirst(	cAlias 		, nOrder 		, cChave		, cBusca	,; 
								cConfLocal		, cEstacaoIni, cFunc )   



Local aRecnos    		:= {}		//Registros
Local nX      		:= 0    	// Contador
Local cNameField 	:= ""      	// Nome do campo situa para o Alias atual
Local aData 	 		:= {}     	// Array com dados a subir para o server
Local lContinua  		:= .F.		// Controle de execucao
Local aArea			:= GetArea()	// Guarda area atual
Local nCont			:= 0 		//Contador
Local lOk				:= .T. 	//Dados ok
Local aCposOri		:= {"E5_DATA","E5_HISTOR", "E5_VALOR", "E5_PREFIXO",;
							"E5_NUMERO", "E5_BANCO", "E5_AGENCIA", "E5_CONTA"} 
Local aCpoComp		:= {} 		//Campos comparação
Local aCpoEqua	:= {"E5_DATA", "E5_MOEDA", "E5_VALOR", "E5_NATUREZ", ;
						"E5_HISTOR", "E5_TIPODOC", "E5_PREFIXO","E5_NUMERO", ;
						"E5_DTDIGIT", "E5_NUMMOV"}
Local cSeqAnt			:= ""		//Sequencia Anterior
Local nC				:= 0 		//Variavel contadora
Local nC2				:= 0 		//Contador
Local nC3				:= 0		///Contador
Local lMovPar			:= .F. 	//movimentacao Par
Local lRet 			:= .T.		//Retorno da Rotina
Local cXML 			:= ""		//XML envio
Local cError 			:= ""		//Erro Parseamento
Local cWarnning 		:= ""		//Alerta Parseamento
Local cPai 			:= ""		//Node pai
Local cPaiAnt 		:= ""		//Node Pai anterior
Local cNode 			:= ""		//Node
Local cTipo 			:= ""		//Tipo do Node
Local cValor 			:= ""		//Valor do XML
Local cEntidade 		:= ""		//Codigo da Entidade
Local cChaveSE5 		:= ""		//Chave SE5
Local cSitua 			:= ""		//Situação

Default 	cAlias 	 		:= ""
Default 	nOrder 	 		:= 0
Default 	cChave 	 		:= ""
Default 	cBusca 	 		:= ""
Default 	cConfLocal 	 	:= ""
Default 	cFunc 	 			:= ""

ParamType 0 Var 	cAlias 		As Character	Default 	""
ParamType 1 Var 	nOrder 		As Numeric		Default 	0
ParamType 2 Var 	cChave 		As Character	Default 	""
ParamType 3 Var 	cBusca 		As Character	Default 	""
ParamType 4 Var 	cConfLocal 	As Character	Default 	""
ParamType 7 Var 	cFunc 			As Character	Default 	""

// Formata campo NOMETABELA_SITUA
// Exemplo: Iniciando com "S": SL1->L1_SITUA, caso contrário MDZ->MDZ_SITUA

If Substr(Upper(cAlias), 1, 1) == "S"
	cNameField := Substr(cAlias, 2, 2) + "_SITUA"        
Else
	cNameField := cAlias + "_SITUA"        
EndIf

DbSelectArea(cAlias)
DbSetOrder(nOrder)  

If DbSeek(cBusca)

	nCampos := FCount() 

	While (cAlias)->(!Eof()) .AND. &(cChave) == cBusca .AND. nCont <= 20 
		aRecnos := {}
		nCont := nCont + 1
		nC := 1
		
		lOk := .T.
		lMovPar := .T.
		lContinua := .T.
		aData := {}
		aCpoComp := {}
		If cAlias == "SE5"
		
			
			Do While (cAlias)->(!Eof()) .AND. &(cChave) == cBusca .AND. nC <= 2 

				
				If nC == 1 .AND. E5_RECPAG == "P"
					//Primeiro registro é pagamento
					cSeqAnt := E5_SEQ
					cChaveSE5 := E5_PREFIXO + E5_NUMERO + Dtos(E5_DATA) + E5_NUMMOV+E5_HISTOR
					cSitua := FieldGet(FieldPos(cNameField))
				ElseIf nC == 1 .AND. E5_RECPAG <> "P"
					//Não atualiza os registros
					aRecnos := {}
					Loop
				EndIf
				aAdd(aData, {} )
				aAdd(aCpoComp, {})
				aAdd(aRecnos, Recno())
				
				nC3 := 1
	
				Do While lMovPar .AND. nC3  <=  Len( aCpoEqua)
						aAdd(aCpoComp[nC], { aCpoEqua[nC3], FieldGet(FieldPos( aCpoEqua[nC3])), NIL})
						If nC > 1						
							lMovPar := aCpoComp[nC-1][nC3][2] == aCpoComp[nC][nC3][2]
						EndIf
						
					nC3++
				EndDo
				
				
				If nC == 2
					lMovPar := lMovPar  .AND.  E5_RECPAG == "R" .AND. Val(cSeqAnt)+1 == Val(E5_SEQ) //Movimentação em pares
				EndIf
				
				If lMovPar
					nC3 := 1
					Do While  nC3  <=  len( aCposOri)
							aAdd(aData[nC], { aCposOri[nC3], FieldGet(FieldPos( aCposOri[nC3])), NIL})						
							nC3++
					EndDo					
				
				Else //!lMovPar
					aRecnos := {}
					dbskip(1)
					Loop
				EndIf

				If nC == 1
					dbskip(1)
				EndIf
				nC++
			EndDo
			
			If Len(aRecnos) == 2 .AND. Len(aData) <= 2
			
				nC := 1
				//Prepar o xml para envio
				
				oXML := NIL
				cXML :=  "<movbancaria></movbancaria>"
				
				oXML := XMLParser( cXML, "" , @cError, @cWarnning)


				cPai := "oXML:_movbancaria"
		
			 	//pai cabeclaho
			 	cTipo := "NOD"  	
			 	cNode := "cabecalho"
			 	cValor := nil			 			
				STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)		

				//filhos do cabeçalho				
				 	cTipo := "NOD"  	
				 	cNode := "tipo"
				 	cValor :=  "4" 			 	
					STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	
					
				 	cTipo := "NOD"  	
				 	cNode := "historico"
				 	cValor :=  STDUpArrVal(aData[nC], "E5_HISTOR") 		 	
					STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	
			
				 	cTipo := "NOD"  	
				 	cNode := "valor"
				 	cValor :=  Str(STDUpArrVal(aData[nC], "E5_VALOR"), ,SE5->(TamSx3("E5_VALOR")[2])) 
					STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	
					
				 	cTipo := "NOD"  	
				 	cNode := "documento"
				 	cValor :=  STDUpArrVal(aData[nC], "E5_PREFIXO")+STDUpArrVal(aData[nC], "E5_NUMERO")
					STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	

				 	cTipo := "NOD"  	
				 	cNode := "data"
				 	cValor :=   TRANSFORM(DTOS(STDUpArrVal(aData[nC], "E5_DATA")), "@r 9999-99-99") //YYYY-MM-DD	 
					STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)				
				
			//fim filhos cabeçalho											
			cPai := Left(cPai, Rat(":", cPai)-1) //volta o pai
				
				Do While (nC <= 2)	
				
					//pai origem/destino
				 	cTipo := "NOD"  	
				 	cNode := If(nC == 1, "origem", "destino")
				 	cValor := nil
					STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	
				
						//filhos		
						
						 	cTipo := "NOD"  	
						 	cNode := "banco"
						 	cValor :=  STDUpArrVal(aData[nC], "E5_BANCO")
						 	STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	
						
						 	cTipo := "NOD"  	
						 	cNode := "agencia"
						 	cValor :=  STDUpArrVal(aData[nC], "E5_AGENCIA")
						 	STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	
		
						 	cTipo := "NOD"  	
						 	cNode := "conta"
						 	cValor :=  STDUpArrVal(aData[nC], "E5_CONTA")
						 	STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	
						 	
						 	cTipo := "NOD"  	
						 	cNode := "categoria"
						 	cValor :=  ""
							STDUpGTag( @cPai, cNode, cNode, cTipo, cValor)	
		
					cPai := Left(cPai, Rat(":", cPai)-1) //volta o pai		
					//fim filhos origem
					nC++
				EndDo	

			
				SAVE oXml XMLSTRING cXML  
				
				cXML := Encode64(AllTrim(cXML))
				//reenvio
				lContinua := oWS:EnviarDados(cEntidade/*codigo*/, ,"Movimentacao Bancaria",STDGtEtChv("SE5",cChaveSE5, cEntidade) ,iif(cSitua == "00", "1", "2"),cXML) //1 - INCLUSAO;2-ALTERACAO;3-EXCLUS
				If ValType(lContinua) <> "L" .OR. !lContinua
					STDLogCons(IIf( Empty(GetWscError(3)), GetWscError(1), GetWscError(3) ))
					lContinua := .F.
				EndIf			

			Endif
	

		EndIf
		
		If lContinua
		
			//array de dados
			For nX := 1 to len(aRecnos)
				dbGoto(aRecnos[nX])
				If RecLock( cAlias, .F. )            		
		         	REPLACE &((cAlias)->(cNameField))	WITH cConfLocal
	   				&(cAlias)->(dbCommit())
		         	&(cAlias)->(MsUnlock()) 
		            
	
	        	EndIf 
        	Next nX
		Else
			STDLogCons(STR0014 ) //"Erro de comunicacao com servidor"
		EndIf 
			
		/*
			Por garantia posiciona no registro anterior para depois
			ir para o primeiro, pois ao alterar um campo do indice
			os registros serao reordenados.
		*/        
		&(cAlias)->(DbSkip(-1))
		&(cAlias)->(DbGoTop()) 

	EndDo

EndIf
oXML := NIL

cSeqAnt := NIL

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpGTag
Cria e alimenta o valor da Tag

@Param   cPai 	- Node Pai
@Param   cNode 	- Nome Logico do Node
@Param   cRealNode 	- Nome real do Node
@Param   cTipo 	- Tipo do Node
@Param 	 cValor 	- Valor do Node	
@author  Varejo
@version P11.8
@since   05/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------

Static Function STDUpGTag( cPai, cNode, cRealNode, cTipo, ;
								cValor)

Default cRealNode := cNode

XmlNewNode(&cPai, cNode, cNode, cTipo )    
&(cPai+":" + cNode + ":RealName") := cRealNode
If cValor <> NIL
	&(cPai+":" + cNode + ":Text") := AllTrim(cValor)
Else
	cPai += ":" + cNode
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpFrDsty
Destroi o Objeto WS

@author  Varejo
@version P11.8
@since   05/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDUpFrDsty()

If oWS <> NIL
	oWS := FreeObj(oWS)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STDUpArrVal
Retorna o valor dos arrays da Venda

@Param   aArray 	- Array de Dados
@Param   cCampo 	- Nome do Campo
@Param   aHeader 	- Header de Campo (SL2/SL4)
@Param   lL2L4 	- Array SL2/SL4
@Param 	 cValor 	- Valor do Node	
@author  Varejo
@version P11.8
@since   05/05/2015
@return  uRet  - Valor
@obs     
@sample
/*/
//-------------------------------------------------------------------

Static Function STDUpArrVal(aArray, cCampo, aHeader, lL2L4)
Local nPos := 0
local uRet := NIL


If lL2l4
	nPos := aScan(aHeader, { |l| l == AllTrim(cCampo)})
	
	If nPos > 0
		uRet := aArray[nPos]
	EndIf
Else
	nPos := aScan(aArray, { |l| l[1] == AllTrim(cCampo)})
	
	
	If nPos > 0
		uRet := aArray[nPos, 02]
	EndIf

EndIf

Return uRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGtEtChv
Retorna a Entidade First + Chave

@Param   cAliasEnt 	- Alias da Entidade
@Param   cChave 	- Chave
@Param   cEntidade 	- Codigo da Entidade
@author  Varejo
@version P11.8
@since   05/05/2015
@return  cChaveRet  - Retorno da rotina 
@obs     
@sample
/*/
//-------------------------------------------------------------------


Function STDGtEtChv(cAliasEnt, cChave, cEntidade)
Local cChaveRet 		:= "" //Chave de Retorno
Local cFilFirst := SuperGetMv("MV_LJFILIN",.F.,"") //De/para filial do First

Default cEntidade := ""

Do Case 
Case cAliasEnt == "SA1" //Cliente
	cChaveRet := cEntidade +PadR(cFilFirst, nTamFil)+cChave //ALTERADO - RECEBEU PELO PDV
Case cAliasEnt == "SE4" //Condicao
	cChaveRet := cEntidade +PadR(cFilFirst, nTamFil)+cChave
Case cAliasEnt == "SA3" //Vendedor
	cChaveRet := cEntidade +PadR(cFilFirst, nTamFil)+cChave
Case cAliasEnt == "SB1" //Produto
	cChaveRet := cEntidade +PadR(cFilFirst, nTamFil)+cChave
	
Case cAliasEnt == "SL1" //VENDAS
	cChaveRet := cEntidade +PadR(cFilFirst, nTamFil)+cChave

Otherwise
	cChaveRet := cEntidade +PadR(cFilFirst, nTamFil)+cChave
EndCase

Return cChaveRet
