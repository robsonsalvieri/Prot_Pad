#Include 'totvs.ch'
/*
Fonte criado para implementacao das regras de validacao da DIOPS quadro Idade dos Saldos Ativo
*/

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasA

Funcao de validacao item A: Verifica se a soma das contas '123111011','123121011','123111091','123121091' do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasA(lPPSC)
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo
	Default lPPSC	:= .F.
//Pega o valor do balancete
	If !lPPSC
		cConta	:=  "'123111011','123121011'"
	Else
		cConta	:=  "'123111091','123121091'"
	EndIf
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'A',cConta,lPPSC)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'A',cConta,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasB

Funcao de validacao item B: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasB(lPPSC)
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo
	Default lPPSC	:= .F.
//Pega o valor do balancete
	If !lPPSC
		cConta	:= "'123112011','123122011'"
	Else
		cConta	:= "'123112091','123122091'"
	EndIf
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'B',cConta,lPPSC)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'B',cConta,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasC

Funcao de validacao item C: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasC(lPPSC)
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo
	Default lPPSC	:= .F.
//Pega o valor do balancete
	If !lPPSC
		cConta	:= "'123111012','123111013','123121012','123121013'"
	Else
		cConta	:= "'123111092','123111093','123121092','123121093'"
	EndIf
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'C',cConta,lPPSC)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'C',cConta,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasD

Funcao de validacao item D: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasD(lPPSC)
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo
	Default lPPSC	:= .F.
//Pega o valor do balancete
	If !lPPSC
		cConta	:= "'123112012','123112013','123112015','123122012','123122013','123122015' "
	Else
		cConta	:= "'123112092','123112093','123112095','123122092','123122093','123122095' "
	EndIf
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'D',cConta,lPPSC)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'D',cConta,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasE

Funcao de validacao item E: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasE(lPPSC)
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo
	Default lPPSC	:= .F.
	//Pega o valor do balancete
	If !lPPSC      
  		cConta	:="'123219011','123219012','123219021','123219022','123229011','123229012','123229021','123229022'"
	Else
		cConta	:= "'123219019','123219029','123229019','123229029'"
	EndIf                                                           
	
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'E',cConta,lPPSC)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'E',cConta,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasF

Funcao de validacao item F: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasF(lPPSC)
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo
	Default lPPSC	:= .F.
//Pega o valor do balancete
	If !lPPSC
		cConta	:= "'123311011','123312011','123321011','123322011'"
	Else
		cConta	:= "'123311019','123312019','123321019','123322019'"
	EndIf
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'F',cConta,lPPSC)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'F',cConta,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasG

Funcao de validacao item G: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasG(lPPSC)
	Local cContaA	:= ""
	Local cContaB	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrBalA	:= 0//Valor conta no balancete A
	Local nVlrBalB	:= 0//Valor conta no balancete B
	Local nVlrIda	:= 0//Valor da idade do saldo Passivo
	Default lPPSC	:= .F.
//A-B
//1234 - (123411091 + 123412091 + 123421091 + 123422091)

//Pega o valor do balancete - A
	cContaA	:= "'1234'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'G',cContaA,lPPSC)
	nVlrBalA := RetornaValor(cAliTrb,cSql)

//Pega o valor do balancete - B
	cContaB	:= "'123411091','123412091','123421091','123422091'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'G',cContaB,lPPSC)
	nVlrBalB := RetornaValor(cAliTrb,cSql)

	If !lPPSC   
		If nVlrBalB < 0         //se for negativo
			nVlrBal := nVlrBalA - ABS(nVlrBalB)  
		Else
			nVlrBal := nVlrBalA - nVlrBalB		
		EndIf
	Else
		nVlrBal := nVlrBalB
	EndIf

//Pega o valor do da idade do saldo
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'G',cContaB,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasH

Funcao de validacao item H: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasH(lPPSC)
	Local cContaA	:= ""
	Local cContaB	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrBalA:= 0
	Local nVlrBalB:= 0
	Local nVlrIda	:= 0//Valor da idade do saldo ativo
	Default lPPSC	:= .F.
	
	If !lPPSC
		//Pega o valor do balancete A
		cContaA	:= "'1239'"
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'H',cContaA,lPPSC)
		nVlrBalA := RetornaValor(cAliTrb,cSql)
	EndIf
	
	//Pega o valor do balancete B
	cContaB	:= "'123911019','123911029','123911089','123912089','123921019','123921029','123921089','123922089'" 
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'H',cContaB,lPPSC)
	nVlrBalB := RetornaValor(cAliTrb,cSql)

	If !lPPSC   
		If nVlrBalB < 0         //se for negativo
			nVlrBal := nVlrBalA - ABS(nVlrBalB)  
		Else
			nVlrBal := nVlrBalA - nVlrBalB		
		EndIf
	Else
		nVlrBal := nVlrBalB
	EndIf

	//Pega o valor da idade do saldo
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'H',cContaB,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasI

Funcao de validacao item I: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasI(lPPSC)
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo
	Default lPPSC	:= .F.
//Pega o valor do balancete
	If !lPPSC
		cConta	:= "'124119011','124119021','124119022','124119082','124119088','124129011','124129021','124129022','124129082','124129088'"
	Else
		cConta	:= "'124119019','124119029','124119089','124129019','124129029','124129089'"
	EndIf
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'I',cConta,lPPSC)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'I',cConta,lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalPasJ

Funcao de validacao item J: Verifica se a soma das contas  do balancete bate com  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalPasJ(lPPSC,lPrePag)
	Local cContaA	:= ""
	Local cContaB	:= ""
	Local cSql		:= ""
	Local cCodCmp	:= 'J1' // Codigo do campo. G1 = B8G_OUCROP e G2 = B8G_CROPPO 
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrBalA	:= 0//Valor conta no balancete A
	Local nVlrBalB	:= 0//Valor conta no balancete B
	Local nVlrIda	:= 0//Valor da idade do saldo Passivo
	Default lPPSC	:= .F.
	Default lPrePag	:= .T.

	If lPrePag
		cCodCmp	:= 'J1'
		If lPPSC
			// PPSC de Credito de Operadoras - Pre-Estabelecido - .T., .T.
			// PPSC- Somatório do saldo das contas: 123411091 + 123421091
			cContaA	:= "'123411091','123421091'"
			cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,cCodCmp,cContaA,lPPSC)
			nVlrBalB := RetornaValor(cAliTrb,cSql)	

		Else
			// Credito de Operadoras - Pre-Estabelecido - .F., .T.
			// Somatório do saldo das contas: (123411 - 123411091) + (123421 - 123421091)
			cContaA	:= "'123411','123421'"
			cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,cCodCmp,cContaA,lPPSC)
			nVlrBalA := RetornaValor(cAliTrb,cSql)
			
			//Pega o valor do balancete - B
			cContaB	:= "'123411091','123421091'"
			cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,cCodCmp,cContaB,lPPSC)
			nVlrBalB := RetornaValor(cAliTrb,cSql)

		EndIf
				
	Else
		cCodCmp	:= 'J2'
		If lPPSC
			// PPSC de Credito de Operadoras - Pos-Estabelecido - .T., .F.
			// PPSC- Somatório do saldo das contas: (123412091 + 123422091)
			cContaA	:= "'123412091','123422091'"
			cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,cCodCmp,cContaA,lPPSC)
			nVlrBalB := RetornaValor(cAliTrb,cSql)	

		Else
			// Credito de Operadoras - Pos-Estabelecido - .F., .F.
			// Somatório do saldo das contas: (123412 - 123412091) + (123422 - 123422091)
			cContaA	:= "'123412','123422'"
			cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,cCodCmp,cContaA,lPPSC)
			nVlrBalA := RetornaValor(cAliTrb,cSql)
			
			//Pega o valor do balancete - B
			cContaB	:= "'123412091','123422091'"
			cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,cCodCmp,cContaB,lPPSC)
			nVlrBalB := RetornaValor(cAliTrb,cSql)
	
		EndIf
	
	EndIf

	If !lPPSC   
		If nVlrBalB < 0         //se for negativo
			nVlrBal := nVlrBalA - ABS(nVlrBalB)  
		Else
			nVlrBal := nVlrBalA - nVlrBalB		
		EndIf
	Else
		nVlrBal := nVlrBalB
	EndIf

	//Pega o valor da idade de saldo
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,cCodCmp,'',lPPSC)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaValor

Funcao criada para executar a query e retornar o valor do balancete ou do evento da idade de saldo

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaValor(cAliTrb,cSql)
	Local nValor		:= 0
	Default cAliTrb	:= ''
	Default cSql		:= ''

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

	If !(cAliTrb)->(Eof())
		nValor := (cAliTrb)->VALOR
	EndIf

	(cAliTrb)->(dbCloseArea())



Return nValor

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaConsulta

Funcao criada montar as consultas de validacao 

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaConsulta(cCodOpe,cCodObr,cAnoCmp,cCdComp,nOpcTab,cTeste,cConta,lPPSC)
	Local cSql			:= ""
	Local cCampo		:= ""
	Local cTabela		:= ""
	Local cFilTab		:= ""
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCdComp	:= ""
	Default nOpcTab	:= 1//1 - Balancete - B8A, 2 - Idade do Saldo Ativo - B3D
	Default cTeste	:= "A"
	Default cConta	:= ""
	Default lPPSC		:= .T.

//Opcao da tabela
	If nOpcTab == 1
		cTabela	:= RetSqlName('B8A')
		cFilTab	:= xFilial('B8A')
	ElseIf nOpcTab == 2
		cTabela	:= RetSqlName('B8G')
		cFilTab	:= xFilial('B8G')
	EndIf

//Definicao de campos 
	If nOpcTab == 1//Campos do Balancete - B8A

		cCampo := "SUM(B8A_SALFIN)"

	ElseIf nOpcTab == 2//Campos da Idade do Saldo Ativo - B3D

		Do Case
		Case cTeste == "A"
			cCampo	:= "SUM(B8G_INDPRE)"
		Case cTeste == "B"
			cCampo	:= "SUM(B8G_INDPOS)"
		Case cTeste == "C"
			cCampo	:= "SUM(B8G_COLPRE)"
		Case cTeste == "D"
			cCampo	:= "SUM(B8G_COLPOS)"
		Case cTeste == "E"
			cCampo	:= "SUM(B8G_CREADM)"
		Case cTeste == "F"
			cCampo	:= "SUM(B8G_PARBEN)"
		Case cTeste == "G"
			cCampo	:= "SUM(B8G_OUCROP)"
		Case cTeste == "H"
			cCampo	:= "SUM(B8G_OUCRPL)"
		Case cTeste == "I"
			cCampo	:= "SUM(B8G_OUTCRE)"
		Case cTeste == "J1"
			cCampo	:= "SUM(B8G_OUCROP)"
		Case cTeste == "J2"
			cCampo	:= "SUM(B8G_CROPPO)"
		OtherWise
			cCampo	:= ""
		EndCase

	EndIf

//Montagem da consulta
	If nOpcTab == 1
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE B8A_FILIAL='" + cFilTab + "' AND B8A_CODOPE='" + cCodOpe + "' AND B8A_CODOBR='" + cCodObr + "' AND B8A_ANOCMP='" + cAnoCmp + "' AND B8A_CDCOMP='" + cCdComp + "' AND B8A_CONTA IN (" + cConta + ") AND D_E_L_E_T_=' '"
	Else
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE B8G_FILIAL='" + cFilTab + "' AND B8G_CODOPE='" + cCodOpe + "' AND B8G_CODOBR='" + cCodObr + "' AND B8G_ANOCMP='" + cAnoCmp + "' AND B8G_CDCOMP='" + cCdComp + "' "
		If !lPPSC
			cSql += " AND B8G_VENCTO <> '400' "
		Else
			cSql += " AND B8G_VENCTO = '400' "
		EndIf
		cSql += " AND D_E_L_E_T_=' ' "
	EndIf
	cSql := ChangeQuery(cSql)

Return cSql

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCRIIDSP

Funcao cria os demais itens do quadro idade dos saldos passivo 

@author timoteo.bega
@since 10/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCRIIDSP(cCodOpe,cCodObr,cCdComp,cAnoCmp)
	Local aVenctos		:= {"000","030","060","090","099","400"}
	Local cVencto		:= ""
	Local cRefere		:= B3DRefere()
	Local nFor			:= 0
	Local lRet			:= .T.
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cCdComp	:= ""
	Default cAnoCmp	:= ""

	//Vou inserir os demais itens no quadro
	For nFor := 1 TO Len(aVenctos)

		//Monta o where para verificar se existe o iten no quadro
		cWhrQuadro := GetWhrQuadro("B8G",cCodOpe,cCodObr,cAnoCmp,cCdComp)
		cWhrQuadro += " AND B8G_VENCTO='"+aVenctos[nFor]+"' "

		//Verifica se ja foi inserido algum item no quadro
		cVencto := ExisteIdaSldP(cWhrQuadro)

		If Empty(cVencto)//Se nao encontrou o vencto

			//Vou inserir o vencto nao encontrado
			InsereIdaSldPas(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,aVenctos[nFor])

		EndIf
		
	Next nFor

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteIdaSldP

Funcao verifica se existe um evento no quadro idade de saldos passivo e posiciona 

@author timoteo.bega
@since 10/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteIdaSldP(cWhrQuadro)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local cRet		:= ""
	Default cWhrQuadro	:= ""

	If !Empty(cWhrQuadro)

		cSql := "SELECT R_E_C_N_O_ REC, B8G_VENCTO FROM " + RetSqlName("B8G") + " WHERE " + cWhrQuadro
		cSql += " AND D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

		If !(cAliTrb)->(Eof())
			cRet := AllTrim((cAliTrb)->B8G_VENCTO)
			B8G->(dbGoTo((cAliTrb)->REC))
		EndIf

		(cAliTrb)->(dbCloseArea())

	EndIf

Return cRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsereIdaSldAtv

Funcao grava itens na tabela de idade de saldos ativos 

@author timoteo.bega
@since 10/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function InsereIdaSldPas(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,cVencto)
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cRefere	:= ""
	Default cCdComp	:= ""
	Default cVencto	:= ""

	RecLock("B8G",.T.)
	B8G->B8G_FILIAL := xFilial("B8G")
	B8G->B8G_CODOPE := cCodOpe
	B8G->B8G_CODOBR := cCodObr
	B8G->B8G_ANOCMP := cAnoCmp
	B8G->B8G_REFERE := cRefere
	B8G->B8G_CDCOMP := cCdComp
	B8G->B8G_VENCTO := cVencto
	B8G->B8G_INDPRE := 0
	B8G->B8G_INDPOS := 0
	B8G->B8G_COLPRE := 0
	B8G->B8G_COLPOS := 0
	B8G->B8G_CREADM := 0
	B8G->B8G_PARBEN := 0
	B8G->B8G_OUCROP := 0
	B8G->B8G_OUCRPL := 0
	B8G->B8G_OUTCRE := 0
	B8G->B8G_STATUS := "1"
	msUnLock()

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSValAlt

Funcao que verifica se o item alterado já existe no banco. Isso para o campo B8G_VENCTO

@author jose.paulo
@since 03/07/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSValAlt(cCodOpe,cCodObr,cAnoCmp,cCdComp,cVencto, nRec)
	Local lRet		:= .T.
	Local cSql		:= "" 
	Local cAliB8G	:= GetNextAlias()	
	Default cCodOpe := ""
	Default cCodObr := ""
	Default cAnoCmp := ""
	Default cCdComp := ""
	Default cVencto := ""

	//B8G_FILIAL+B8G_CODOPE+B8G_CODOBR+B8G_ANOCMP+B8G_CDCOMP+B8G_VENCTO   
	If Altera
		cSql := " SELECT R_E_C_N_O_, B8G_VENCTO FROM " + RetSqlName("B8G") + " WHERE B8G_FILIAL = '" + xFilial("B8G") + "' " 
		cSql +=" AND B8G_CODOPE = '" + cCodOpe + "' " 
		cSql +=" AND B8G_CODOBR = '" + cCodObr + "' " 
		cSql +=" AND B8G_ANOCMP = '" + cAnoCmp + "' " 
		cSql +=" AND B8G_CDCOMP = '" + cCdComp + "' " 
		cSql +=" AND B8G_VENCTO = '" + cVencto + "' " 
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliB8G,.F.,.T.)
		
		If !(cAliB8G)->(Eof())
		
			lRet := .F.

			iF (cAliB8G)->R_E_C_N_O_ <> nRec

				cMsgErro := "O registro não pode ser inserido pois já existe no banco de dados."
				Help( ,, 'HELP',,  cMsgErro, 1, 0,NIL,NIL,NIL,NIL,NIL,{"No campo Vencto Fin, Selecione uma opção que não tenha sido utilizada."})
			EndIf			
		EndIf
		
		(cAliB8G)->(dbCloseArea())
	EndIf

Return lRet