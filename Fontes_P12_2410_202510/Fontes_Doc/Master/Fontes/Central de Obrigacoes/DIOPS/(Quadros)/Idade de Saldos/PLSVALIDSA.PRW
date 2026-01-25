#Include 'totvs.ch'
/*
Fonte criado para implementacao das regras de validacao da DIOPS quadro Idade dos Saldos Ativo 
*/
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvA

Funcao de validacao item A: Verifica se a soma das contas '21111102','21111202','21112102','21112202' do balancete bate com Eventos/Sinistros a Liquidar SUS 

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvA()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

	//Pega o valor do balancete
	cConta	:= "'21111102','21111202','21112102','21112202'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'A',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

	//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'A',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvB

Funcao de validacao item B: Verifica se a soma das contas '21111103','21111203','21112103','21112203' do balancete bate com Eventos/Sinistros a Liquidar 

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvB()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'21111103','21111203','21112103','21112203'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'B',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'B',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvC

Funcao de validacao item C: Verifica se a conta '2134' do balancete bate com Comercialização sobre Operações  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvC()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'2134'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'C',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'C',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvD

Funcao de validacao item D: Verifica se a conta '2135' do balancete bate com Débitos com Operadoras  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvD()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'2135'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'D',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'D',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvE

Funcao de validacao item E: Verifica se a soma das contas '2131','2138' do balancete bate com Outros Débitos Operacionais com Planos  

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvE()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'2131','2138'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'E',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'E',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvF

Funcao de validacao item F: Verifica se a conta '2135' do balancete bate com Tributos e Encargos a Recolher Conta

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvF()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'216'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'F',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'F',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvG

Funcao de validacao item G: Verifica se a conta '2185' do balancete bate com Depósitos de Beneficiários - Contraprest/Seguros Recebidos - Plano de contas

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvG()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'2185','2132'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'G',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'G',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvH

Funcao de validacao item H: Verifica se a conta '214' do balancete bate com Prestadores de Serv. de Assistência a Saúde

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvH()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'214'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'H',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'H',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvI

Funcao de validacao item I: Verifica se a conta '2186' do balancete bate com Débitos com Aquisição de Carteira

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvI()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'2186'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'I',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'I',cConta)
	nVlrIda := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrIda
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvJ

Funcao de validacao item J: Verifica se a conta '2188' do balancete bate com Outros Débitos a Pagar

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Function IdaSalAtvJ()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrIda	:= 0//Valor da idade do saldo ativo

//Pega o valor do balancete
	cConta	:= "'2188'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'J',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'J',cConta)
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
	Default cAliTrb	:= GetNextAlias()
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
Static Function RetornaConsulta(cCodOpe,cCodObr,cAnoCmp,cCdComp,nOpcTab,cTeste,cConta)
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

//Opcao da tabela
	If nOpcTab == 1
		cTabela	:= RetSqlName('B8A')
		cFilTab	:= xFilial('B8A')
	ElseIf nOpcTab == 2
		cTabela	:= RetSqlName('B8F')
		cFilTab	:= xFilial('B8F')
	EndIf

//Definicao de campos 
	If nOpcTab == 1//Campos do Balancete - B8A

		cCampo := "SUM(B8A_SALFIN)"

	ElseIf nOpcTab == 2//Campos da Idade do Saldo Ativo - B3D

		Do Case
		Case cTeste == "A"
			cCampo	:= "SUM(B8F_EVESUS)"
		Case cTeste == "B"
			cCampo	:= "SUM(B8F_EVENTO)"
		Case cTeste == "C"
			cCampo	:= "SUM(B8F_COMERC)"
		Case cTeste == "D"
			cCampo	:= "SUM(B8F_DEBOPE)"
		Case cTeste == "E"
			cCampo	:= "SUM(B8F_OUDBOP)"
		Case cTeste == "F"
			cCampo	:= "SUM(B8F_TITSEN)"
		Case cTeste == "G"
			cCampo	:= "SUM(B8F_DEPBEN)"
		Case cTeste == "H"
			cCampo	:= "SUM(B8F_SERASS)"
		Case cTeste == "I"
			cCampo	:= "SUM(B8F_AQUCAR)"
		Case cTeste == "J"
			cCampo	:= "SUM(B8F_OUDBPG)"
		OtherWise
			cCampo	:= ""
		EndCase

	EndIf

//Montagem da consulta
	If nOpcTab == 1
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE B8A_FILIAL='" + cFilTab + "' AND B8A_CODOPE='" + cCodOpe + "' AND B8A_CODOBR='" + cCodObr + "' AND B8A_ANOCMP='" + cAnoCmp + "' AND B8A_CDCOMP='" + cCdComp + "' AND B8A_CONTA IN (" + cConta + ") AND D_E_L_E_T_=' '"
	Else
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE B8F_FILIAL='" + cFilTab + "' AND B8F_CODOPE='" + cCodOpe + "' AND B8F_CODOBR='" + cCodObr + "' AND B8F_ANOCMP='" + cAnoCmp + "' AND B8F_CDCOMP='" + cCdComp + "' AND D_E_L_E_T_=' ' "
	EndIf
	cSql := ChangeQuery(cSql)

Return cSql

//PLSCRIIDSA(oModel, 'B8FMASTER', 'B8F_CODOPE', 'B8F_CODOBR', 'B8F_CDCOMP', 'B8F_ANOCMP', 'B8F_REFERE')

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCRIIDSA

Funcao cria os demais itens do quadro idade dos saldos 

@author timoteo.bega
@since 10/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCRIIDSA(cCodOpe,cCodObr,cCdComp,cAnoCmp)
	Local aVenctos		:= {"000","030","060","090","120","999"}
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
		cWhrQuadro := GetWhrQuadro("B8F",cCodOpe,cCodObr,cAnoCmp,cCdComp)
		cWhrQuadro += " AND B8F_VENCTO='"+aVenctos[nFor]+"' "

		//Verifica se ja foi inserido algum item no quadro
		cVencto := ExisteIdaSldA(cWhrQuadro)

		If Empty(cVencto)//Se nao encontrou o vencto

			//Vou inserir o vencto nao encontrado
			InsereIdaSldAtv(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,aVenctos[nFor])

		EndIf
		
	Next nFor

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteIdaSldA

Funcao verifica se existe um evento no quadro idade de saldos ativo e posiciona 

@author timoteo.bega
@since 10/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteIdaSldA(cWhrQuadro)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local cRet		:= ""
	Default cWhrQuadro	:= ""

	If !Empty(cWhrQuadro)

		cSql := " SELECT R_E_C_N_O_ REC, B8F_VENCTO FROM " + RetSqlName("B8F") + " WHERE " + cWhrQuadro
		cSql += " AND D_E_L_E_T_ = ' ' "
		cSql := ChangeQuery(cSql)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

		If !(cAliTrb)->(Eof())
			cRet := AllTrim((cAliTrb)->B8F_VENCTO)
			B8F->(dbGoTo((cAliTrb)->REC))
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
Static Function InsereIdaSldAtv(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,cVencto)
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cRefere	:= ""
	Default cCdComp	:= ""
	Default cVencto	:= ""

	RecLock("B8F",.T.)
	B8F->B8F_FILIAL := xFilial("B8F")
	B8F->B8F_CODOPE := cCodOpe
	B8F->B8F_CODOBR := cCodObr
	B8F->B8F_ANOCMP := cAnoCmp
	B8F->B8F_REFERE := cRefere
	B8F->B8F_CDCOMP := cCdComp
	B8F->B8F_VENCTO := cVencto
	B8F->B8F_EVENTO := 0
	B8F->B8F_COMERC := 0
	B8F->B8F_DEBOPE := 0
	B8F->B8F_OUDBOP := 0
	B8F->B8F_DEPBEN := 0
	B8F->B8F_SERASS := 0
	B8F->B8F_AQUCAR := 0
	B8F->B8F_OUDBPG := 0
	B8F->B8F_EVESUS := 0
	B8F->B8F_TITSEN := 0
	B8F->B8F_STATUS := "1"
	B8F->(msUnLock())

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVAltPg

Funcao que verifica se o item alterado já existe no banco. Isso para o campo B8F_VENCTO

@author jose.paulo
@since 03/07/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSVAltPg(cCodOpe,cCodObr,cAnoCmp,cCdComp,cVencto, nRec)
	Local lRet		:= .T.
	Local cSql		:= "" 
	Local cAliB8F	:= GetNextAlias()	
	Default cCodOpe := ""
	Default cCodObr := ""
	Default cAnoCmp := ""
	Default cCdComp := ""
	Default cVencto := ""

	//B8F_FILIAL+B8F_CODOPE+B8F_CODOBR+B8F_ANOCMP+B8F_CDCOMP+B8F_VENCTO   
	If Altera
		cSql := " SELECT R_E_C_N_O_, B8F_VENCTO FROM " + RetSqlName("B8F") + " WHERE B8F_FILIAL = '" + xFilial("B8F") + "' " 
		cSql +=" AND B8F_CODOPE = '" + cCodOpe + "' " 
		cSql +=" AND B8F_CODOBR = '" + cCodObr + "' " 
		cSql +=" AND B8F_ANOCMP = '" + cAnoCmp + "' " 
		cSql +=" AND B8F_CDCOMP = '" + cCdComp + "' " 
		cSql +=" AND B8F_VENCTO = '" + cVencto + "' " 
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliB8F,.F.,.T.)
		
		If !(cAliB8F)->(Eof())
		
			lRet := .F.

			iF (cAliB8F)->R_E_C_N_O_ <> nRec

				cMsgErro := "O registro não pode ser inserido pois já existe no banco de dados."
				Help( ,, 'HELP',,  cMsgErro, 1, 0,NIL,NIL,NIL,NIL,NIL,{"No campo Vencto Fin, Selecione uma opção que não tenha sido utilizada."})
			EndIf			
		EndIf
		
		(cAliB8F)->(dbCloseArea())
	EndIf

Return lRet