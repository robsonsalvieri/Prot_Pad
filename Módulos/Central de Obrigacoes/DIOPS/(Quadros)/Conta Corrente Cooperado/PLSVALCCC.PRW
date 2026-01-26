#Include 'totvs.ch'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IdaSalAtvA

Funcao de validacao do quadro conta corrente cooperado com a conta 131919011 do balancete

@author timoteo.bega
@since 19/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CtaCCoop01()
	Local cConta	:= ""
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrCCC	:= 0//Valor da Conta corrente cooperado

	//Pega o valor do balancete
	cConta	:= "'1319'"
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'A',cConta)
	nVlrBal := RetornaValor(cAliTrb,cSql)

	//Pega o valor do da idade do saldo
	cConta	:= ""
	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'A',cConta)
	nVlrCCC := RetornaValor(cAliTrb,cSql)

	If nVlrBal = nVlrCCC
		lRetorno := .T.
	Else
		lRetorno := .F.
	EndIf

Return lRetorno

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
	Default nOpcTab	:= 1//1 - Balancete - B8A, 2 - Conta Corrente Cooperado - BUW
	Default cTeste	:= "A"
	Default cConta	:= ""

	//Opcao da tabela
	If nOpcTab == 1
		cTabela	:= RetSqlName('B8A')
		cFilTab	:= xFilial('B8A')
	ElseIf nOpcTab == 2
		cTabela	:= RetSqlName('BUW')
		cFilTab	:= xFilial('BUW')
	EndIf

	//Definicao de campos 
	If nOpcTab == 1//Campos do Balancete - B8A

		cCampo := "SUM(B8A_SALFIN)"

	ElseIf nOpcTab == 2//Campos da Idade do Saldo Ativo - B3D

		Do Case
		Case cTeste == "A"
			cCampo	:= "SUM(BUW_SLDFIN)"
		OtherWise
			cCampo	:= ""
		EndCase

	EndIf

	//Montagem da consulta
	If nOpcTab == 1
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE B8A_FILIAL='" + cFilTab + "' AND B8A_CODOPE='" + cCodOpe + "' AND B8A_CODOBR='" + cCodObr + "' AND B8A_ANOCMP='" + cAnoCmp + "' AND B8A_CDCOMP='" + cCdComp + "' AND B8A_CONTA IN (" + cConta + ") AND D_E_L_E_T_=' '"
	Else
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE BUW_FILIAL='" + cFilTab + "' AND BUW_CODOPE='" + cCodOpe + "' AND BUW_CODOBR='" + cCodObr + "' AND BUW_ANOCMP='" + cAnoCmp + "' AND BUW_CDCOMP='" + cCdComp + "' AND D_E_L_E_T_=' ' "
	EndIf
	cSql := ChangeQuery(cSql)

Return cSql

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaValor

Funcao criada para executar a query e retornar o valor do balancete ou da conta corrente do cooperado

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaValor(cAliTrb,cSql)
	Local nValor	:= 0
	Default cAliTrb	:= GetNextAlias()
	Default cSql	:= ''

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

	If !(cAliTrb)->(Eof())
		nValor := (cAliTrb)->VALOR
	EndIf

	(cAliTrb)->(dbCloseArea())

Return nValor


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSValCCC

Funcao que verifica se o item alterado já existe no banco. Isso para o campo BUW_TIPO

@author jose.paulo
@since 31/07/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSValCCC(cTipo,cDenom,cDtComp,nRec)   
	Local lRet		:= .T.
	Local cSql		:= "" 
	Local cAliBUW	:= GetNextAlias()	
	Local cCodOpe := B3D->B3D_CODOPE
	Local cCodObr := B3D->B3D_CDOBRI
	Local cAnoCmp := B3D->B3D_ANO
	Local cCdComp := B3D->B3D_CODIGO            //BUW_FILIAL+BUW_CODOPE+BUW_CODOBR+BUW_ANOCMP+BUW_CDCOMP+BUW_TIPO+BUW_DENOMI+DTOS(BUW_DTCOMP)   
	Default cTipo := ""
	Default cDenom := ""
	Default cDtComp := ""

	If Altera
		cSql := " SELECT R_E_C_N_O_ FROM " + RetSqlName("BUW") + " WHERE BUW_FILIAL = '" + xFilial("BUW") + "' " 
		cSql +=" AND BUW_CODOPE = '" + cCodOpe + "' " 
		cSql +=" AND BUW_CODOBR = '" + cCodObr + "' " 
		cSql +=" AND BUW_ANOCMP = '" + cAnoCmp + "' " 
		cSql +=" AND BUW_CDCOMP = '" + cCdComp + "' " 
		cSql +=" AND BUW_TIPO   = '" + cTipo + "' " 
		cSql +=" AND BUW_DENOMI = '" + cDenom + "' " 
		cSql +=" AND BUW_DTCOMP = '" + cDtComp + "' " 
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliBUW,.F.,.T.)
		
		If !(cAliBUW)->(Eof())
		
			lRet := .F.

			iF (cAliBUW)->R_E_C_N_O_ <> nRec

				cMsgErro := "O registro não pode ser inserido pois já existe no banco de dados."
				Help( ,, 'HELP',,  cMsgErro, 1, 0,NIL,NIL,NIL,NIL,NIL,{"Verifique o conteúdo dos campos Tipo Imposto, Nome Imposto e Data de Competência."})
			EndIf			
		EndIf
		
		(cAliBUW)->(dbCloseArea())
	EndIf

Return lRet