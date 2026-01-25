#Include 'totvs.ch'
/*
Fonte criado para implementacao das regras de validacao da DIOPS quadro Idade dos Saldos Ativo
*/

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContPecCoA

Funcao de validacao item A: 
Verifica se o conteúdo do campo B37_EMITID é igual a soma dos campos B37_RECEBI,B37_VENCID,B37_AVENCE

@author jose.paulo
@since 30/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function ContPecCoA()
	Local nVlrCem	:= 0
	Local nVlrCve	:= 0
	
	nVlrCem := B37->B37_EMITID     
	nVlrCve := B37->(B37_RECEBI+B37_VENCID+B37_AVENCE)

	lRetorno := nVlrCem = nVlrCve

Return lRetorno            

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContPecCoB

Funcao de validacao item B:
Soma dos campos Vlr.Venc.Atr(B37_VENCID) dos registros com Tipo Plano(B37_PLANO) = PIF=Planos Individuais/Familiares(Pessoa Física) 
deve ser igual a soma dos campos Indiv Pre-Es(B8G_INDPRE) 
onde Vencto Fin(BG8_VENCTO) é diferente de 000 do quadro idade de saldos a receber do mesmo compromisso.

@author jose.paulo
@since 30/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function ContPecCoB(lValid)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrCpe	:= 0//Contraprestação Pecuniária
	Local nVlrIda	:= 0//Valor da idade do saldo 
	local lRetorno  := .T.
	Default lValid  := .T.

	If lValid 
		//Pega o valor da Contraprestação
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'A',"PIF",,.F.)  
		nVlrCpe := RetornaValor(cAliTrb,cSql)

		//Pega o valor da idade do saldo
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'A',"PIF",,.F.)
		nVlrIda := RetornaValor(cAliTrb,cSql)

		lRetorno := nVlrCpe = nVlrIda
	EndIf
Return lRetorno
 
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContPecCoC

Funcao de validacao item C: 
Soma dos campos Vlr.Venc.Atr(B37_VENCID) dos registros com Tipo Plano(B37_PLANO) = PCJ=Planos Coletivos(Pessoa Juridica)
deve ser igual a soma dos campos Colet Pre-Es(B8G_COLPRE) 
onde o campo Vencto Fin(BG8_VENCTO) é diferente de 000 do quadro idade de saldos a receber do mesmo compromisso.

@author jose.paulo
@since 30/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function ContPecCoC(lValid)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrCpe	:= 0//Contraprestação Pecuniária
	Local nVlrIda	:= 0//Valor da idade do saldo 
	Local lRetorno  := .T.
	Default lValid  := .F.

	If !lValid
		//Pega o valor da Contraprestação
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'A',"PCJ",,.F.)
		nVlrCpe := RetornaValor(cAliTrb,cSql)

		//Pega o valor da idade do saldo
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'B',"PCJ",,.F.)
		nVlrIda := RetornaValor(cAliTrb,cSql)

		lRetorno := nVlrCpe = nVlrIda
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContPecCoD

Funcao de validacao item D:
Soma dos campos Vlr A Vencer(B37_AVENCE) dos registros com Tipo Plano(B37_PLANO) = PIF=Planos Individuais/Familiares(Pessoa Física)
deve ser igual a soma dos campos Indiv Pre-Es(B8G_INDPRE)
onde o campo Vencto Fin(BG8_VENCTO) é igual a 000 do quadro idade de saldos a receber do mesmo compromisso.

@author jose.paulo
@since 30/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function ContPecCoD(lValid)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrCpe	:= 0//Contraprestação Pecuniária
	Local nVlrIda	:= 0//Valor da idade do saldo 
	local lRetorno  := .T.
	Default lValid  := .T.

	If lValid
		//Pega o valor da Contraprestação
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'B',"PIF",,.F.)
		nVlrCpe := RetornaValor(cAliTrb,cSql)

		//Pega o valor da idade do saldo
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'A',"PIF",,.T.)
		nVlrIda := RetornaValor(cAliTrb,cSql)

		lRetorno := nVlrCpe = nVlrIda
	EndIf
	
Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ContPecCoE

Funcao de validacao item E:  
Soma dos campos Vlr A Vencer(B37_AVENCE) dos registros com Tipo Plano(B37_PLANO) = PCJ=Planos Coletivos(Pessoa Juridica)
deve ser igual a soma dos campos Colet Pre-Es(B8G_COLPRE)
onde Vencto Fin(BG8_VENCTO) é igual a 000 do quadro idade de saldos a receber do mesmo compromisso.

@author jose.paulo
@since 30/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function ContPecCoE(lValid)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrCpe	:= 0//Contraprestação Pecuniária
	Local nVlrIda	:= 0//Valor da idade do saldo 
	Local lRetorno  := .T.
	Default lValid  := .F.

	if !lValid
		//Pega o valor da Contraprestação
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'B',"PCJ",,.F.)
		nVlrCpe := RetornaValor(cAliTrb,cSql)

		//Pega o valor da idade do saldo
		cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'B',"PCJ",,.T.)
		nVlrIda := RetornaValor(cAliTrb,cSql)

		lRetorno := nVlrCpe = nVlrIda
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaValor

Funcao criada para executar a query e retornar o valor do balancete ou do evento da idade de saldo

@author JOSE.PAULO
@since 30/05/2019
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
Static Function RetornaConsulta(cCodOpe,cCodObr,cAnoCmp,cCdComp,nOpcTab,cTeste,cPlano,cPerCob,lIgual)
	Local cSql			:= ""
	Local cCampo		:= ""
	Local cTabela		:= ""
	Local cFilTab		:= ""
	Default cPlano  	:= ""
	Default cCodOpe		:= ""
	Default cCodObr		:= ""
	Default cAnoCmp		:= ""
	Default cCdComp		:= ""
	Default nOpcTab		:= 1				//1 - Contraprestação(B37), 2 - Idade do Saldo(B8G)
	Default cTeste 		:= "A" 
    Default cPerCob	 	:= ""    
    Default lIgual 	 	:= .F.
    
	If nOpcTab == 1
		cTabela	:= RetSqlName('B37')
		cFilTab	:= xFilial('B37')
	ElseIf nOpcTab == 2
		cTabela	:= RetSqlName('B8G')
		cFilTab	:= xFilial('B8G')
	EndIf

	If nOpcTab == 1//Campos do Balancete - B8A
 		Do Case
		Case cTeste == "A"
			cCampo := "SUM(B37_VENCID)"         
		Case cTeste == "B"
			cCampo := "SUM(B37_AVENCE)"
		OtherWise
			cCampo	:= ""
		EndCase
	 
	ElseIf nOpcTab == 2//Campos da Idade do Saldo Ativo - B3D

		Do Case
		Case cTeste == "A"
			cCampo	:= "SUM(B8G_INDPRE)"       //Vencto Fin(BG8_VENCTO) é diferente de 000
		Case cTeste == "B"
			cCampo	:= "SUM(B8G_COLPRE)"
		OtherWise
			cCampo	:= ""
		EndCase

	EndIf

    //B37_FILIAL+B37_CODOPE+B37_CODOBR+B37_ANOCMP+B37_CDCOMP+B37_PERCOB+B37_PLANO
	If nOpcTab == 1
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE B37_FILIAL='" + cFilTab + "' AND B37_CODOPE='" + cCodOpe + "' AND B37_CODOBR='" + cCodObr + "' AND B37_ANOCMP='" + cAnoCmp + "' AND B37_CDCOMP='" + cCdComp + "' 
		If !Empty(cPerCob)
			cSql += " AND B37_PERCOB='" + cPerCob + "'"
		EndIf	
		cSql += " AND B37_PLANO='" + cPlano   + "'"
		cSql += " AND D_E_L_E_T_=' '"
	Else
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE B8G_FILIAL='" + cFilTab + "' AND B8G_CODOPE='" + cCodOpe + "' AND B8G_CODOBR='" + cCodObr + "' AND B8G_ANOCMP='" + cAnoCmp + "' AND B8G_CDCOMP='" + cCdComp + "' "
		If !lIgual
			cSql += " AND B8G_VENCTO NOT IN('000','400') "
		Else
			cSql += " AND B8G_VENCTO = '000' "
		EndIf
		cSql += " AND D_E_L_E_T_=' ' "
	EndIf
	cSql := ChangeQuery(cSql)

Return cSql
                                                 
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetRegCtPe

Retorna array de regras para validar o quadro Contraprestações Pecuniárias / Prêmios por Período de Cobertura

@author jose.paulo
@since 27/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function GetRegCtPe()

	local aVldReg := {}
	local aVldBloco := {}
	local aRegras := {}

	aAdd( aVldReg, 	{"CP01","    ","ContPecCoA()", "Valor do campo Vlr.Emit.Liq está diferente da Soma dos campos Vlr Recebido,Vlr.Venc.Atr e Vlr A Vencer", "Verifique o(s) valor(es) do(s) campos mencionados", " AND B37_AVENCE <> '400' " } )
	aAdd( aVldBloco,	{"CP02","    ","ContPecCoB(.T.)", "Soma dos campos Vlr.Venc.Atr com Tipo Plano=PIF é igual a soma da coluna Indiv Pre-Es Vencidos Quadro idade de saldos.", "Verifique o(s) valor(es) do(s) campos mencionados", " AND B37_AVENCE <> '400' AND B37_PLANO = 'PIF' " } )
	aAdd( aVldBloco,	{"CP03","    ","ContPecCoC(.F.)", "Soma dos campos Vlr.Venc.Atr com Tipo Plano=PCJ é igual a soma da coluna Colet Pre-Es Vencidos Quadro idade de saldos.", "Verifique o(s) valor(es) da(s) campos mencionados", " AND B37_AVENCE <> '400' AND B37_PLANO = 'PCJ' " } )
	aAdd( aVldBloco,	{"CP04","    ","ContPecCoD(.T.)", "Soma dos campos Vlr A Vencer com Tipo Plano=PIF é igual a soma da coluna Indiv Pre-Es A Vencer Quadro Idade de Saldos.", "Verifique o(s) valor(es) do(s) campos mencionados", " AND B37_AVENCE <> '400' AND B37_PLANO = 'PIF' " } )
	aAdd( aVldBloco,	{"CP05","    ","ContPecCoE(.F.)", "Soma dos campos Vlr A Vencer com Tipo Plano=PCJ é igual a soma da coluna Colet Pre-Es A Vencer Quadro Idade de Saldos.", "Verifique o(s) valor(es) do(s) campos mencionados", " AND B37_AVENCE <> '400' AND B37_PLANO = 'PCJ' " } )	
	aRegras := { GetTabCtPe(), aVldReg, aVldBloco }
	
Return aRegras

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} plperc

Retorna status do combo do campo B37_PERCOB do quadro Contraprestações Pecuniárias / Prêmios por Período de Cobertura

@author jose.paulo
@since 28/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLPERCBC()
	LOCAL cStatus := ""

	cStatus := "084=À iniciar;085=Iniciado no dia 1;086=Iniciado no dia 2;087=Iniciado no dia 3;088=Iniciado no dia 4;089=Iniciado no dia 5;090=Iniciado no dia 6;"
	cStatus += "091=Iniciado no dia 7;092=Iniciado no dia 8;093=Iniciado no dia 9;094=Iniciado no dia 10;095=Iniciado no dia 11;096=Iniciado no dia 12;097=Iniciado no dia 13;"
	cStatus += "098=Iniciado no dia 14;099=Iniciado no dia 15;100=Iniciado no dia 16;101=Iniciado no dia 17;102=Iniciado no dia 18;103=Iniciado no dia 19;104=Iniciado no dia 20;"
	cStatus += "105=Iniciado no dia 21;106=Iniciado no dia 22;107=Iniciado no dia 23;108=Iniciado no dia 24;109=Iniciado no dia 25;110=Iniciado no dia 26;111=Iniciado no dia 27;"
	cStatus += "112=Iniciado no dia 28;113=Iniciado no dia 29;114=Iniciado no dia 30;115=Iniciado no dia 31;116=Iniciado em meses anteriores;"
		
Return cStatus

