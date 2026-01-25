#Include 'totvs.ch'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CtaTrPas01

Funcao de validacao do quadro conta tributo passivo verifica se a conta faz parte do grupo 1319

@author timoteo.bega
@since 27/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CtaTrPas01(cConta)
    Local lRetorno  := .F.
    Local cSql      := ""
    Default cConta  := ""
    
    If Empty(cConta)
    	cConta := BUY->BUY_CONTA
    EndIf

	// Se não estiver no grupo, já considera a conta inválida
	If Subs(cConta,1,4) == '1319'		
    	lRetorno := .T.
    EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CtaTrPas02

Funcao de validacao do quadro conta tributo passivo (1319) Verifica se o Saldo Inicial menos o 
Valor Pago mais Atualização Monetária é igual ao Saldo Final do Trimestre 

@author timoteo.bega
@since 27/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CtaTrPas02(cConta)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrCTP	:= 0//Valor da Conta Tributo Passivo
    Local lRetorno  := .F.
	Default cConta	:= ""
    
    If Empty(cConta)
    	cConta := BUY->BUY_CONTA
    EndIf

	// Somente valido a conta 1319. Mesmo que a conta seja do grupo 1319 não dever ser validada a critica CT02. Também não é necessário verificar se ela está no balancete.
    If Subs(cConta,1,4) == '1319'  

    	//Pega o valor do quadro conta tributo passivo
	    cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'C',cConta)
    	nVlrCTP := RetValor(cAliTrb,cSql)

    	If nVlrCTP == 1
	    	lRetorno := .T.
    	Else    
	    	lRetorno := .F.
    	EndIf

    Else
    	lRetorno := .T.  
    EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CtaTrPas03

Funcao de validacao do quadro conta tributo verifica se a somatoria dos saldos bate com a conta 1319

@author timoteo.bega
@since 27/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CtaTrPas03(cConta)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local nVlrBal	:= 0//Valor conta no balancete
	Local nVlrCTP	:= 0//Valor da Conta Tributo Passivo
    Local lRetorno  := .F.
	Default cConta	:= ""
    
    If Empty(cConta)
    	cConta := BUY->BUY_CONTA
    EndIf

 	// Se não estiver no grupo, já considera a conta inválida
    If Subs(cConta,1,4) == '1319' .and. ExisteContaBal(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,cConta)

    	//Pega o valor do balancete
	    cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,'A','1319' ) 	//cConta)
    	nVlrBal := RetornaValor(cAliTrb,cSql)

	    //Pega o valor do quadro tributo passivo
    	cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'A',"")
	    nVlrCTP := RetornaValor(cAliTrb,cSql)

	    If nVlrBal = nVlrCTP
		    lRetorno := .T.
    	Else
	    	lRetorno := .F.
	    EndIf

    EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteContaBal

Funcao de validacao do quadro conta tributo verifica se a conta existe no balancete

@author timoteo.bega
@since 27/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteContaBal(cCodOpe,cCodObr,cAnoCmp,cCdComp,cConta)
	Local cSql	:= ""
	Local lRet	:= .F.
	Local cAliasN := getNextAlias()

	cSql := "SELECT B8A_CONTA FROM " + RetSqlName("B8A") + " WHERE B8A_FILIAL='" + xFilial("B8A") + "' AND B8A_CODOPE='" + cCodOpe + "' AND B8A_CODOBR='" +cCodObr+ "' AND B8A_ANOCMP='" +cAnoCmp+ "' "
	cSql += "AND B8A_CDCOMP='" +cCdComp+ "' AND B8A_CONTA='" +cConta+ "' AND D_E_L_E_T_ = ' ' "
	cSql := ChangeQuery(cSql)
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)
	
	lRet := !(cAliasN)->(Eof())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaConsulta

Funcao criada montar as consultas de validacao 

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaConsulta(cCodOpe,cCodObr,cAnoCmp,cCdComp,nOpcTab,cTeste,cConta)
	Local cSql		:= ""
	Local cCampo	:= ""
	Local cTabela	:= ""
	Local cFilTab	:= ""
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCdComp	:= ""
	Default nOpcTab	:= 1//1 - Balancete - B8A, 2 - Conta Tributo Passivo - BUY
	Default cTeste	:= "A"
	Default cConta	:= ""

	//Opcao da tabela
	If nOpcTab == 1
		cTabela	:= RetSqlName('B8A')
		cFilTab	:= xFilial('B8A')
	ElseIf nOpcTab == 2
		cTabela	:= RetSqlName('BUY')
		cFilTab	:= xFilial('BUY')
	EndIf

	//Definicao de campos 
	If nOpcTab == 1//Campos do Balancete - B8A

		cCampo := "SUM(B8A_SALFIN)"

	ElseIf nOpcTab == 2//Campos da Idade do Saldo Ativo - B3D

		Do Case
		Case cTeste == "A"
			cCampo	:= "SUM(BUY_SLDFIN)"
		Case cTeste == "C"
			cCampo	:= " BUY_VLRINI AS VLRINI,BUY_VLRPAG AS VLRPAG,BUY_ATUMON AS ATUMON,BUY_SLDFIN "
		OtherWise
			cCampo	:= ""
		EndCase

	EndIf

	//Montagem da consulta
	If nOpcTab == 1
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE B8A_FILIAL='" + cFilTab + "' AND B8A_CODOPE='" + cCodOpe + "' AND B8A_CODOBR='" + cCodObr + "' AND B8A_ANOCMP='" + cAnoCmp + "' AND B8A_CDCOMP='" + cCdComp + "' AND B8A_CONTA IN ('" + cConta + "') AND D_E_L_E_T_=' ' "
	Else
		cSql := "SELECT " + cCampo + " VALOR FROM " + cTabela + " WHERE BUY_FILIAL='" + cFilTab + "' AND BUY_CODOPE='" + cCodOpe + "' AND BUY_CODOBR='" + cCodObr + "' AND BUY_ANOCMP='" + cAnoCmp + "' AND BUY_CDCOMP='" + cCdComp + "' "
        If !Empty(cConta)
            cSql += " AND BUY_CONTA = '" + cConta + "'"
        EndIf
        cSql += " AND D_E_L_E_T_=' ' "
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
/*/{Protheus.doc} RetValor

Funcao criada para executar a query e retornar o valor do balancete ou da conta corrente do cooperado

@author jose.paulo
@since 27/06/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetValor(cAliTrb,cSql)
	Local nVlrIni	:= 0
	Local nVlrPag	:= 0
	Local nVlrAtu	:= 0
    Local nVlrSld   := 0 
    Local nValor    := 0
    
	Default cAliTrb	:= GetNextAlias()           
	Default cSql	:= ''

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

	If !(cAliTrb)->(Eof())

		If (((cAliTrb)->VLRINI - (cAliTrb)->VLRPAG) + (cAliTrb)->ATUMON) == (cAliTrb)->VALOR
			nValor := 1    			 
		EndIf 
	
	EndIf

	(cAliTrb)->(dbCloseArea())

Return nValor

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSNUMCTP

Funcao criada para atualizar o Model com a próxima sequência.

@author jose.paulo
@since 30/07/2019
/*/
//--------------------------------------------------------------------------------------------------

FUNCTION PLSNUMCTP(oModel)

	Local cSql    :=""
	Local cRet    :="000001"       
	Local cConta  := oModel:GetValue( 'BUYMASTER', 'BUY_CONTA')
	Local lMudaSeq:= .T.
	Local lCpos   := BUY->(FieldPos("BUY_SEQUEN")) > 0
	Local lAuto   := IsInCallStack("MVCTP_001") .Or. IsInCallStack("MVCTP_002") .Or. IsInCallStack("MVCTP_003") .Or. IsInCallStack("MVCTP_004").Or. IsInCallStack("MVCTP_005");
	.Or. IsInCallStack("MVCTP_006") .Or. IsInCallStack("MVCTP_007") .Or. IsInCallStack("MVCTP_008") .Or. IsInCallStack("MVCTP_009")

	If lAuto //se for automação não deve verificar alteração
		Altera:= .F.
	EndIf

	If Altera  //se for alteração e não for mudada a conta, não atualizo a sequência
		If Alltrim(cConta) == Alltrim(BUY->BUY_CONTA)
			lMudaSeq:= .F.	
		EndIf

	EndIf 	

	If lMudaSeq .And. lCpos
		cSql := " SELECT MAX(BUY_SEQUEN) AS MAIOR  FROM " + RetSqlName("BUY") + " WHERE BUY_FILIAL = '" + xFilial("BUY") + "' " 
		cSql +=" AND BUY_CODOPE = '" + B3D->B3D_CODOPE + "' " 
		cSql +=" AND BUY_CODOBR = '" + B3D->B3D_CDOBRI + "' " 
		cSql +=" AND BUY_ANOCMP = '" + B3D->B3D_ANO + "' " 
		cSql +=" AND BUY_CDCOMP = '" + B3D->B3D_CODIGO + "' " 
		cSql +=" AND BUY_CONTA = '" + alltrim(cConta) + "' " 
		cSql += " AND D_E_L_E_T_ = ' '"
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBUY",.F.,.T.)

		If !TRBBUY->(Eof())
			
			cRet := TRBBUY->MAIOR
			If !Empty(cRet) 
				oModel:SetValue( 'BUYMASTER', 'BUY_SEQUEN', Soma1(cRet))
			Else
				oModel:SetValue( 'BUYMASTER', 'BUY_SEQUEN', "000001")
			EndIf

			TRBBUY->(dbCloseArea())
		Else
			oModel:SetValue( 'BUYMASTER', 'BUY_SEQUEN', "000001")
		EndIf
	EndIf
Return 
	


