#include 'PROTHEUS.CH'
#Include "FwLibVersion.ch"

Static __oQryFKW      As Object
Static __oQryFKW2  	  As Object
Static __oQryFKW3 	  As Object
Static __oQryPerN     As Object
Static __oQryBase     As Object
Static __oQryFKY	  As Object
Static __oQryFKY2	  As Object
Static __oSttFKH	  As Object
Static __lFKWVlBr     As Logical
Static __lFKYVlBr     As Logical
Static __80RAltBx     As Logical
Static __450AltBx     As Logical
Static __lBtrISS      As Logical
Static __lCachQry     As Logical
Static __nTamPrf	  As Numeric

// Motor de retenções
Static _lPccMR := .F.
Static _lIrfMR := .F.

/*
	Fonte generico para funções do REINF 2.1.1
*/

//--------------------------------------------------------------------------------------
/*/{Protheus.doc}GetPropImp
Retorna o valor dos impostos retidos e não retidos da baixa a pagar proporcionalizados 
por Natureza de Rendimento e pelo valor baixado (REINF - Bloco 40).

@param cChave  - Chave do titulo
@param aImposBx - Array com os dados dos impostos da baixa:
	[1]cTpImp    - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
	[2]cIdFk4    - Id da FK4 (FK4_IDFK4)
	[3]nBasImp   - Valor da base de calculo a ser proporcionalizada
	[4]nValImp   - Valor do imposto a ser proporcionalizado (informado quando houver retencao)
	[5]nValBx    - Valor da baixa
	[6]cTabOri   - tabela de origem calculo (FK3), tabela de origem de retenção (FK4), sem impostos ou isenção/suspensão (FKW)
	[7]aRatIRPF  - array dados para registro do rateio CPF
		aRatIRPF[x][1] - CPF
		aRatIRPF[x][2] - % DE RATEIO
		aRatIRPF[x][3] - Valor de imposto calculado
		aRatIRPF[x][4] - cIdorig
		aRatIRPF[x][5] - cTabOri
	[9]nVa       - Valor dos valores acessórios (desconto/multa/juros)
@param nTotImpBx - Total dos impostos retidos na baixa
@param aDadosFKY - Array que será populado conforme abaixo:
	[1] Filial
	[2] ID da baixa (FK2_IDFK2)
	[3] Codigo do Imposto
	[4] Natureza de Rendimento
	[5] Percentual de proporcionalização
	[6] Valor da Base de calculo
	[7] Valor do imposto retido
	[8] Valor da base com exigibilidade suspensa
	[9] Valor do imposto que deixou de ser efetuado
	[10] Numero do processo judicial/administrativo
	[11] Tipo do processo

@Retorno - NIL

@author Fabio Casagrande Lima
@since  25/07/2019
@version 12
/*/
//--------------------------------------------------------------------------------------
Function GetPropImp(cChave As Char, aImposBx As Array, nTotImpBx As Numeric, aDadosFKY As Array) 

	Local cIdDoc    As Character
	Local cNatRen   As Character
	Local cFilFKY   As Character
	Local cCodProc  As Character
	Local cTpProc   As Character
	Local cIndSusp  As Character 
	Local aArea		As Array
	Local nBasNRet  As Numeric
	Local nImpNRet  As Numeric
	Local nBasFKW   As Numeric
	Local nImpFKW   As Numeric
	Local nCoef  	As Numeric
	Local lRatIRPF  As Logical
	Local nX     	As Numeric
	Local nY        As Numeric
	Local cTpImp   	As Character 
	Local cIdOrig  	As Character 
	Local nBasImp  	As Numeric
	Local nValImp  	As Numeric
	Local nValBx    As Numeric
	Local cTabOri   As Character 
	Local aRatIRPF  As Array
	Local nVa       As Numeric
	Local nVrBruto  As Numeric
	Local lBordero  As Logical
	Local lTabProg	As Logical

	Default cChave := ""
	Default aImposBx := {}
	Default nTotImpBx := 0
	Default aDadosFKY := {}

	aArea	  := GetArea()
	cNatRen   := ""
	cFilFKY   := xFilial("FKY")
	cIdDoc    := FINBuscaFK7(cChave, "SE2", SE2->E2_FILORIG)
	cCodProc  := ""
	cTpProc   := ""
	cIndSusp  := ""
	nBasNRet  := 0
	nImpNRet  := 0
	nVrBruto  := 0
	lBordero  := (FwIsInCallStack("FINA241") .Or. FwIsInCallStack("FINA590"))
	lTabProg  := SA2->A2_TIPO == 'F' .or. SA2->A2_IRPROG == '1'
	nQtdDep   := SA2->A2_NUMDEP
	nVrPorDep := SuperGetMv("MV_TMSVDEP",.T.,0)
	nTotDedDep:= nQtdDep * nVrPorDep

	FVldImp(cIdDoc)

	For nY := 1 To Len(aImposBx) 
		cTpImp   	:= aImposBx[nY][1]
		cIdOrig  	:= aImposBx[nY][2]
		nBasImp  	:= aImposBx[nY][3]
		nValImp  	:= aImposBx[nY][4]
		nValBx   	:= aImposBx[nY][5]
		cTabOri   	:= aImposBx[nY][6]
		aRatIRPF   	:= aImposBx[nY][7]
		nVa   	   	:= aImposBx[nY][8]
		lRatIRPF   	:= Len(aRatIRPF)>0

		//Encontra o coeficiente de baixa
		nCoef := CoefBx(cIdDoc, cTpImp, nValBx, nBasImp, nValImp, nTotImpBx, lBordero, nVa) 

		DbSelectArea("FKW")
		FKW->(DBSetOrder(3)) //FKW_FILIAL+FKW_IDDOC+FKW_TPIMP+FKW_CGC
		FKW->(dbGoTop())

		__lFKWVlBr	:= If(__lFKWVlBr == Nil, FKW->(ColumnPos("FKW_VLBRUT")) > 0, __lFKWVlBr)

		If !lRatIRPF
			If FKW->(DBSeek(xFilial("FKW") + cIdDoc + cTpImp)) //Caso existir registro na FKW deve respeitar a proporcionalizacao de la (Origem Doc. Entrada)
				While !FKW->(Eof()) .And. FKW->FKW_IDDOC+Alltrim(FKW->FKW_TPIMP) == cIdDoc+AllTrim(cTpImp) 
					
					cNatRen   := FKW->FKW_NATREN

					If Empty(cIdOrig)
						cTabOri := "FKW"
						cIdOrig := FKW->FKW_IDFKW
					Endif

					If cTabOri == "FK4"  //Retenção considera a base da FK4
						nBasFKW := nBasImp
						If lTabProg .And. nTotDedDep > 0
							nBasFKW := nBasImp + nTotDedDep //Base cheia para dependentes (será deduzido no extrator)
						EndIf
					Else
						//Tratamento na base do imposto para considerar a quando não houver retencao
						nBasFKW  := GetBaseFKW(cTpImp, cIdDoc)
						nBasFKW  := nBasFKW * nCoef //Aplica coeficiente da baixa
					EndIf

					nBasFKW  := (nBasFKW * FKW->FKW_PERC)/100	//Aplica proporcionalidade da natureza de rendimento na base de calculo
					nImpFKW  := (nValImp* FKW->FKW_PERC)/100    //Aplica proporcionalidade da natureza de rendimento no valor do imposto

					//Tratamento de base não retida (suspensa) para a baixa
					nBasNRet := nCoef * FKW->FKW_BASENR
					nImpNRet := nCoef * FKW->FKW_VLIMPN
					cCodProc := FKW->FKW_NUMPRO
					cTpProc  := FKW->FKW_TPPROC
					cIndSusp := FKW->FKW_CODSUS

					//Valor bruto
					If __lFKWVlBr
						If cTabOri == "FK4" .And. SED->ED_BASEIRF == 0
							nVrBruto := nBasFKW
						ElseIf !Empty(FKW->FKW_VLBRUT)
							nVrBruto := FKW->FKW_VLBRUT * nCoef
						EndIf
					EndIf

					//Grava dados no array que ira alimentar a tabela FKY
					aAdd(aDadosFKY,{cFilFKY, cIdDoc, cTabOri, cIdOrig, cTpImp, cNatRen, nBasFKW, nImpFKW, nBasNRet, nImpNRet, cCodProc, cTpProc, cIndSusp, nVrBruto })					
					
					FKW->(dbSkip())
				EndDo
			Endif
		Else
			For nX := 1 to Len(aRatIRPF)
				If FKW->(DBSeek(xFilial("FKW") + cIdDoc + cTpImp+aRatIRPF[nX][1]))
					While !FKW->(Eof()) .And. FKW->FKW_IDDOC+Alltrim(FKW->FKW_TPIMP)+Alltrim(FKW->FKW_CGC) == cIdDoc+AllTrim(cTpImp)+Alltrim(aRatIRPF[nX][1])
						cNatRen   := FKW->FKW_NATREN

						If Empty(aRatIRPF[nX][4])
							cTabOri := "FKW"
							cIdOrig := FKW->FKW_IDFKW
						Else
							cTabOri := aRatIRPF[nX][5]
							cIdOrig := aRatIRPF[nX][4]
						Endif

						//Tratamento na base do imposto para considerar a proporcionalidade
						nBasFKW  := GetBaseNat(cTpImp, cIdDoc, cNatRen) //Aplica coeficiente da baixa
						nBasFKW  := nBasFKW*(aRatIRPF[nX][2]/100) * nCoef //Aplica proporcionalidade da natureza de rendimento na base de calculo					
						If cTabOri == "FK4" //Retenção considera a base da FK4
							nBasFKW := nBasImp*(aRatIRPF[nX][2]/100)
						EndIf
						nTotNat  := GetPercNat(cTpImp, cIdDoc,cNatRen) //Verifica base real do imposto quando origem de nota fiscal
						nImpFKW  := aRatIRPF[nX][3]*(nTotNat/100) //Aplica proporcionalidade da natureza de rendimento no valor do imposto

						//Valor bruto
						If __lFKWVlBr .And. !Empty(FKW->FKW_VLBRUT)
							nVrBruto := FKW->FKW_VLBRUT * nCoef
						EndIf

						//Grava dados no array que ira alimentar a tabela FKY
						aAdd(aDadosFKY,{cFilFKY, cIdDoc, cTabOri, cIdOrig, cTpImp, cNatRen, nBasFKW, nImpFKW, nBasNRet, nImpNRet, cCodProc, cTpProc, cIndSusp, nVrBruto })					
						
						FKW->(dbSkip())
					EndDo
				EndIf
			Next nX
		EndIf
	Next nY

	RestArea(aArea)
	FwFreeArray(aArea)

Return

//--------------------------------------------------------------------------------------
/*/{Protheus.doc}FinGrvFKY
Grava os impostos retidos na baixa a pagar proporcionalizados por
Natureza de Rendimento na tabela FKY (REINF - Bloco 40).

@param cId       - ID da FK2 (FK2_IDFK2)
@param oSubFKY   - Submodelo da FKY
@param aDadosFKY - Dados a serem gravados na tabela FKY

@author Fabio Casagrande Lima
@since  25/07/2019
@version 12
/*/
//--------------------------------------------------------------------------------------
Function FinGrvFKY(cIdFk2, oSubFKY, aDadosFKY)

	Local nX As Numeric

	Default cIdFk2    	  := ""
	Default oSubFKY   := nil
	Default aDadosFKY := {}

	__lFKYVlBr	:= If(__lFKYVlBr == Nil, FKY->(ColumnPos("FKY_VLBRUT")) > 0, __lFKYVlBr)

	For nX := 1 To Len(aDadosFKY)

		If nX > 1
			oSubFKY:AddLine()
		Endif
		oSubFKY:SetValue( "FKY_FILIAL",	aDadosFKY[nX][1] )
		oSubFKY:SetValue( "FKY_IDFKY" ,	FWUUIDV4())				
		oSubFKY:SetValue( "FKY_IDDOC" ,	aDadosFKY[nX][2] )
		oSubFKY:SetValue( "FKY_IDFK2" ,	cIdFk2)
		oSubFKY:SetValue( "FKY_TABORI",	aDadosFKY[nX][3] )				
		oSubFKY:SetValue( "FKY_IDORIG",	aDadosFKY[nX][4] )
		oSubFKY:SetValue( "FKY_TPIMP" ,	aDadosFKY[nX][5] )
		oSubFKY:SetValue( "FKY_NATREN",	aDadosFKY[nX][6] )
		oSubFKY:SetValue( "FKY_BASETR",	aDadosFKY[nX][7] )
		oSubFKY:SetValue( "FKY_VLIMP" ,	aDadosFKY[nX][8] )
		oSubFKY:SetValue( "FKY_BASENR",	aDadosFKY[nX][9] )
		oSubFKY:SetValue( "FKY_VLIMPN",	aDadosFKY[nX][10] )
		oSubFKY:SetValue( "FKY_NUMPRO",	aDadosFKY[nX][11] )
		oSubFKY:SetValue( "FKY_TPPROC",	aDadosFKY[nX][12] )
		oSubFKY:SetValue( "FKY_CODSUS",	aDadosFKY[nX][13] )

		If Len(aDadosFKY[nX]) > 13 .And. __lFKYVlBr
			oSubFKY:SetValue( "FKY_VLBRUT" , aDadosFKY[nX][14] ) //Valor Bruto
		Endif

	Next nX

	//Limpa valores da memoria.
	aSize(aDadosFKY, 0)

Return

//--------------------------------------------------------------------------------------
/*/{Protheus.doc}FinDelFKY
Exclui dados na tabela FKY - Proporcionalização dos impostos retidos na baixa a pagar por 
Natureza de Rendimento (REINF - Bloco 40)

@param cIdFK2 - ID da FK2 (FK2_IDFK2)

@author Fabio Casagrande Lima
@since  26/07/2019
@version 12
/*/
//--------------------------------------------------------------------------------------
Function FinDelFKY(cIdFk2) 

	Local aArea		As Array
	Local cAliasQry As Character

	Default cIdFk2 := ""

	aArea := GetArea()

	If !Empty(cIdFk2)

		cAliasQry := GetNextAlias()

		cQuery 	:= " SELECT R_E_C_N_O_ RECNOFKY FROM "+RetSqlName("FKY")+" WHERE "
		cQuery 	+= " FKY_FILIAL = '"+xFilial("FKY")+"' AND FKY_IDFK2 = '" + cIdFK2 + "' AND "
		cQuery 	+= " D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		(cAliasQry)->(dbGoTop())
		While !( cAliasQRY )->( Eof())
			dbSelectArea("FKY")
			FKY->(dbGoTo(( cAliasQRY )->RECNOFKY ) )
			Reclock("FKY",.F.)
			FKY->(DbDelete())
			FKY->(MsUnlock())
			(cAliasQry)->(dbSkip())
		Enddo
		(cAliasQry)->(dbCloseArea())

	Endif

	RestArea(aArea)

Return

//--------------------------------------------------------------------------------------
/*/{Protheus.doc}GetFkyNr
Verifica o total de base não retida de um titulo na tabela FKY (REINF - Bloco 40).

@param cIdDoc - ID da FK7
@param cTpImp - Tipo do Imposto (IR/PIS/COF/CSL)

@author Fabio Casagrande Lima
@since  15/08/2019
@version 12
/*/
//--------------------------------------------------------------------------------------
Static Function GetFkyNr(cIdDoc, cTpImp)

	Local cAliasQry As Character
	Local nTotal    As Numeric

	Default cIdDoc := ""
	Default cTpImp := ""

	cAliasQry := GetNextAlias()
	nTotal    := 0

	cQuery 	:= "SELECT FKY_BASENR VALOR"
	cQuery  += "FROM "+RetSqlName("FKY")+" WHERE "
	cQuery 	+= "FKY_FILIAL = '"+xFilial("FKY")+"' AND FKY_IDDOC = '"+cIdDoc+"' AND FKY_TPIMP = '"+cTpImp+"' AND "
	cQuery 	+= "D_E_L_E_T_ = '  ' "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	(cAliasQry)->(dbGoTop())
	While !( cAliasQRY )->( Eof())
		nTotal += ( cAliasQRY )->VALOR
		(cAliasQry)->(dbSkip())
	Enddo
	(cAliasQry)->(dbCloseArea())

Return nTotal
//--------------------------------------------------------------------
/*/{Protheus.doc}GetBaseFKW
Retorna o valor da base de calculo do titulo presente na tabela FKW
(REINF - Bloco 40).

@param cTpImp - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param cIdDoc - Id do titulo (ID FK7)


@author Fabio Casagrande Lima
@since  25/09/2019
@version 12
/*/
//--------------------------------------------------------------------
Static Function GetBaseFKW(cTpImp, cIdDoc)
		
	Local cTblTmp As Character 
	Local nRet    As Numeric
	Local cQuery  As Character 

	Default cTpImp := ""
	Default cIdDoc := ""

	cTblTmp := ""
	nRet    := 0
	cQuery  := ""

	If __oQryFKW == Nil
		cQuery := "SELECT SUM(FKW_BASETR) BASETR FROM "+RetSqlName("FKW")
		cQuery += "WHERE FKW_FILIAL = ? AND "
		cQuery += "FKW_IDDOC = ? AND FKW_TPIMP = ? AND "
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		__oQryFKW := FWPreparedStatement():New(cQuery)
	EndIf
	
	__oQryFKW:SetString(1, xFilial("FKW"))
	__oQryFKW:SetString(2, cIdDoc)
	__oQryFKW:SetString(3, cTpImp)
	
	cQuery  := __oQryFKW:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQuery)
	If (cTblTmp)->(!Eof())
		nRet := (cTblTmp)->BASETR
	Endif
	(cTblTmp)->(dbCloseArea())
	
Return nRet

//--------------------------------------------------------------------
/*/{Protheus.doc}GetBasNR
Retorna o valor da base quando o imposto esta totalmente nao retido
devido a uma suspencao judicial (REINF - Bloco 40).

@param cIdDoc    - Id do titulo (ID FK7)
@param cTpImp    - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param nValBx    - Valor da baixa
@param nTotImpBx - Valor total de todos os impostos com fato gerador na baixa do titulo
@param nTotTit   - Valor total do titulo

@author Fabio Casagrande Lima
@since  03/10/2019
@version 12
/*/
//--------------------------------------------------------------------
Static Function GetBasNR(cIdDoc As Character, cTpImp As Character, nValBx As Numeric, nTotImpBx As Numeric, nTotTit As Numeric)
		
	Local lVlBxLiq   As Logical
	Local lVlBxAlt   As Logical
	Local nRet       As Numeric
	Local nTotBasFKY As Numeric

	Default cIdDoc    := ""
	Default cTpImp	  := ""
	Default nValBx    := 0
	Default nTotImpBx := 0
	Default nTotTit   := 0

	lVlBxAlt := .F.
	nRet	 := 0

	If FindFunction("F080RAltBx") .and. FindFunction("F450RAltBx") 
		If FwIsInCallStack("FINA080")
			lVlBxAlt := F080RAltBx()
		EndIf
		If FwIsInCallStack("FINA450")
			lVlBxAlt := F450RAltBx()
		EndIf
	EndIf
	
	If lVlBxAlt //Trata valor da baixa alterado manualmente no FINA080/FINA450
		lVlBxLiq   := SuperGetMv("MV_BP10925",.F., "1") == "2" // 1-Bruto / 2- Liquido
		If lVlBxLiq
			nRet := nValBx + nTotImpBx
		Endif
	Elseif FwIsInCallStack("FINA340") .and. FindFunction("F340VlComp")
		nRet       := F340VlComp() //base do imposto do valor compensado
	Else
		//Tratamento para pegar o valor correto da base da ultima baixa, quando MV_BP10925 = '1' e ha retencao de impostos 
		nTotBasFKY := GetFkyNr(cIdDoc, cTpImp) //Verifica total de base nao retida já gravada na FKY
		nRet       := nTotTit - nTotBasFKY
	Endif

Return nRet


//--------------------------------------------------------------------
/*/{Protheus.doc}GetPercNat
Retorna percentual total da natureza de rendimento, independente do CPF

@param cTpImp - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param cIdDoc - Id do titulo (ID FK7)
@param cNatRen - Natureza de rendimento

@author Pâmela Bernardo de Souza
@since  13/01/2023
@version 12
/*/
//--------------------------------------------------------------------
Static Function GetPercNat(cTpImp, cIdDoc, cNatRen)
		
	Local cTblTmp As Character 
	Local nRet    As Numeric
	Local cQuery  As Character 

	Default cTpImp := ""
	Default cIdDoc := ""
	Default cNatRen := ""

	cTblTmp := ""
	nRet    := 0
	cQuery  := ""

	If __oQryPerN == Nil
		cQuery := "SELECT SUM(FKW_PERC) PERC FROM "+RetSqlName("FKW")
		cQuery += "WHERE FKW_FILIAL = ? AND "
		cQuery += "FKW_IDDOC = ? AND FKW_TPIMP = ? AND "
		cQuery += "FKW_NATREN = ? AND "
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		__oQryPerN := FWPreparedStatement():New(cQuery)
	EndIf
	
	__oQryPerN:SetString(1, xFilial("FKW"))
	__oQryPerN:SetString(2, cIdDoc)
	__oQryPerN:SetString(3, cTpImp)
	__oQryPerN:SetString(4, cNatRen)
	
	cQuery  := __oQryPerN:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQuery)
	If (cTblTmp)->(!Eof())
		nRet := (cTblTmp)->PERC
	Endif
	(cTblTmp)->(dbCloseArea())
	
Return nRet

//--------------------------------------------------------------------
/*/{Protheus.doc}GetBaseNat
Retorna base total da natureza de rendimento, independente do CPF

@param cTpImp - Tipo do imposto (Ex: IRF, PIS, COF, CSL)
@param cIdDoc - Id do titulo (ID FK7)
@param cNatRen - Natureza de rendimento

@author Pâmela Bernardo de Souza
@since  13/01/2023
@version 12
/*/
//--------------------------------------------------------------------
Static Function GetBaseNat(cTpImp, cIdDoc, cNatRen)
		
	Local cTblTmp As Character 
	Local nRet    As Numeric
	Local cQuery  As Character 

	Default cTpImp := ""
	Default cIdDoc := ""
	Default cNatRen := ""

	cTblTmp := ""
	nRet    := 0
	cQuery  := ""

	If __oQryBase == Nil
		cQuery := "SELECT SUM(FKW_BASETR) BASETR FROM "+RetSqlName("FKW")
		cQuery += "WHERE FKW_FILIAL = ? AND "
		cQuery += "FKW_IDDOC = ? AND FKW_TPIMP = ? AND "
		cQuery += "FKW_NATREN = ? AND "
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		__oQryBase := FWPreparedStatement():New(cQuery)
	EndIf
	
	__oQryBase:SetString(1, xFilial("FKW"))
	__oQryBase:SetString(2, cIdDoc)
	__oQryBase:SetString(3, cTpImp)
	__oQryBase:SetString(4, cNatRen)
	
	cQuery  := __oQryBase:GetFixQuery()
	cTblTmp := MpSysOpenQuery(cQuery)
	If (cTblTmp)->(!Eof())
		nRet := (cTblTmp)->BASETR
	Endif
	(cTblTmp)->(dbCloseArea())
	
Return nRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} FTemFKW
Verifica se o titulo possui registro(s) na tabela FKW, que é pré-condição 
para enviar os dados da emissao do titulo para o TAF (REINF 2.1.1)

@param cIdTit, Character, Chave do titulo (FK7_IDDOC)
@param lFilDel, Logical, Verdadeiro para filtrar só registros deletados.

@return lRet, logical, retorna .T. se encontrar registros do titulo na FKW

@author Fabio Casagrande Lima
@since  29/12/2022
/*/
//-------------------------------------------------------------------------
Function FTemFKW(cIdTit As Char, lFilDel As Logical) As Logical
    Local lRet      As Logical
    Local cQuery    As Character
    Local cIdDoc    As Character
    Local cDelete   As Character

    Default cIdTit := ""
    Default lFilDel := .F.

    lRet    := .F.
    cQuery  := ""
    cIdDoc  := ""
    cDelete := "*"

    If !lFilDel
        cDelete := " "
    EndIf

    If __lCachQry == Nil
        __lCachQry := (FwLibVersion() >= "20211116")
    EndIf 	

    If __oQryFKW2 == NIL
        cQuery := "SELECT FKW_IDDOC IDDOC "
        cQuery += "FROM "+RetSqlName("FKW")
        cQuery += "WHERE FKW_IDDOC = ? "
        cQuery += "AND D_E_L_E_T_ = ? "
        cQuery := ChangeQuery(cQuery)
		__oQryFKW2 := IIF(__lCachQry, FwExecStatement():New(cQuery), FWPreparedStatement():New(cQuery))
    Endif
    
    __oQryFKW2:SetString(1, cIdTit)
    __oQryFKW2:SetString(2, cDelete)

    cIdDoc := __oQryFKW2:ExecScalar('IDDOC')
	cIdDoc := IIf(__lCachQry, __oQryFKW2:ExecScalar("IDDOC"), MpSysExecScalar(__oQryFKW2:GetFixQuery(), "IDDOC"))

    If !Empty(cIdDoc)
        lRet := .T.
    Endif

Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} FTemFKY
Verifica se o titulo possui registro(s) na tabela FKY, que é pré-condição 
para enviar os dados da baixa do titulo para o TAF (REINF 2.1.1)

@param cIdTit, Character, Chave do titulo (FK7_IDDOC)

@return lRet, logical, retorna .T. se encontrar registros do titulo na FKY

@author Fabio Casagrande Lima
@since  05/01/2023
/*/
//-------------------------------------------------------------------------
Function FTemFKY(cIdTit) As Logical
    Local lRet      As Logical
    Local cQuery    As Character
    Local cIdFky    As Character

    Default cIdTit := ""

    lRet    := .F.
    cQuery  := ""

    If __oQryFKY == NIL
        cQuery := "SELECT FKY_IDFKY IDFKY "
        cQuery += "FROM "+RetSqlName("FKY")+" "
        cQuery += "WHERE FKY_IDDOC = ? "
        cQuery += "AND D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
        __oQryFKY := FWPreparedStatement():New(cQuery)
    Endif
    
    __oQryFKY:SetString(1, cIdTit)
    cQuery := __oQryFKY:GetFixQuery()

    cIdFky := MpSysExecScalar(cQuery,"IDFKY")

    If !Empty(cIdFky)
        lRet := .T.
    Endif

Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} FTemSFT
Verifica se o titulo possui registro(s) na tabela SFT, ou seja,
se o documento de entrada/saída gerou livro fiscal para o título.

Obs: Caso o E2_PREFIXO seja diferente do F1_SERIE (config. MV_2DUPREF),
	a função retorna a variavel 'cSerie' condizente com o F1_SERIE.

@param nCart   , Numeric  , Carteira (1-Pagar / 2-Receber)
@param cNumNF  , Character, Numerico do título
@param cSerie  , Character, Prefixo do título/nota (retorna por referencia @)
@param cCliFor , Character, Cliente/Fornecedor do titulo
@param cLoja   , Character, Loja do cliente/fornecedor
@param nTamSer , Numeric  , Tamanho do FT_SERIE no dicionário

@return lRet, logical, retorna .T. se encontrou registro ref ao titulo na SFT

@author Fabio Casagrande Lima
@since  15/09/2023
/*/
//-------------------------------------------------------------------------
Function FTemSFT(nCart, cNumNF, cSerie, cCliFor, cLoja, nTamSer) As Logical
    Local lRet      As Logical
	Local nRecSF1   As Numeric
	Local c2DupRef  As Character

    Default nCart    := 1
    Default cSerie   := ""
    Default cNumNF   := ""
    Default cCliFor  := ""
    Default cLoja    := ""
    Default nTamSer  := TamSx3( "FT_SERIE" )[1]

	If __nTamPrf == NIL
		__nTamPrf := TamSx3( "E2_PREFIXO" )[1]
	Endif

    lRet     := .F.
	nRecSF1  := 0
	c2DupRef := SuperGetMv("MV_2DUPREF",.F.,"")

	DbSelectArea("SFT")
	SFT->(DBSetOrder(1)) //FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO

	If nCart == 1 //Contas a Pagar
		If Alltrim(c2DupRef) != "SF1->F1_SERIE" .or. __nTamPrf != nTamSer 	//Quando o MV_2DUPREF não for padrão, encontrar a serie da NF através do campo F1_SERIE
			nRecSF1 := FINBuscaNF(,cNumNF, cSerie, cCliFor, cLoja, "SF1", .T.)
			SF1->(dbGoto(nRecSF1))
			cSerie := padr(Alltrim(SF1->F1_SERIE), nTamSer)
		EndIf
		If SFT->(MsSeek(xFilial("SFT") + "E" +  cSerie + cNumNF + cCliFor + cLoja ) )
			lRet := .T.
		EndIf
	Else
		If SFT->(MsSeek(xFilial("SFT") + "S" +  cSerie + cNumNF + cCliFor + cLoja ) )
			lRet := .T.
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F989FKH
Verifica se existem dados na tabela FKH pendentes para serem integrados
na filial especificada.

@param	cFilAnt	- Filial logada
@return lRet	- Retorna .T. para final de execução

@author Fabio Casagrande Lima
@since 03/01/2025
/*/
//-------------------------------------------------------------------
Function FTemFKH(cFilAnt As Char) As Logical

	Local cQuery  As Character
	Local lTemExc As Logical
	Local nIndex  As Numeric

	Default cFilAnt	:= ""

	cQuery	:= ""
	lTemExc	:= .F.
	nIndex := 0

	If __lCachQry == Nil
		__lCachQry := (FwLibVersion() >= "20211116")
	EndIf 	

	If __oSttFKH == NIL
		cQuery	:= " SELECT Count(1) FLAG "
		cQuery	+= " FROM " + RetSQLName("FKH") + " FKH "
		cQuery	+= " WHERE FKH.FKH_FILIAL = ? "  //#1
		cQuery	+= 			" AND FKH.FKH_REINF IN ( ? ) "  //#2
		cQuery	+= 			" AND FKH.D_E_L_E_T_ = ? " //#3

		cQuery := ChangeQuery( cQuery )
		__oSttFKH := IIF(__lCachQry, FwExecStatement():New(cQuery), FWPreparedStatement():New(cQuery))
	EndIf

	__oSttFKH:SetString( ++nIndex, cFilAnt	)  //#1
	__oSttFKH:SetIn( ++nIndex, {"2"," "} ) //#2
	__oSttFKH:SetString(++nIndex, ' ') //#3

	lTemExc	:= IIf(__lCachQry, (__oSttFKH:ExecScalar("FLAG") > 0), (MpSysExecScalar(__oSttFKH:GetFixQuery(), "FLAG") > 0))

Return lTemExc

/*/{Protheus.doc} AgregTrib
	Verifica se a configuração da Natureza de Rendimento, ambiente, título e  
	baixa permitirão a aglutinação dos tributos como "agregados" para o envio
	do bloco 40 da EFD-Reinf.

	@param cCodNat, Character, Código da Natureza de Rendimento (FKX_CODIGO)
	@param cTipo, Character, Indica se a verificação será para 1-CSRF ou 2-COSIRF
	@param cFatoGer, Character, Indica o fato gerador dos tributos (1-emissao/2-baixa)
	@param aId, Array, ID da FK7 ou da FK2 conforme o fato gerador (FK2 vem como lista para atender o borderô)
	@param nTamImp , Numeric  , Tamanho do FKW_TPIMP no dicionário
	@param nTamPro , Numeric  , Tamanho do FKW_NUMPRO no dicionário

	@return lRet, Logical, Verdadeiro se os tributos do cTipo podem ser agregados

	@author Fabio Casagrande Lima
	@since  15/09/2023
/*/
Function AgregTrib(cCodNat As Char, cTipo As Char, cFatoGer As Char, aId As Array, nTamImp As Numeric, nTamPro As Numeric) As Logical
    Local cTribNatR As Char
	Local cTribAgr  As Char
	Local lRet	    As Logical
	
	//Parâmetros de entrada
    Default cCodNat  := ""
    Default cTipo    := "1"
	Default cFatoGer := "1"
	Default aId      := {}
    Default nTamImp  := TamSx3( "FKW_TPIMP" )[1]
    Default nTamPro  := TamSx3( "FKW_NUMPRO" )[1]
	
	//Inicializa variáveis
	cTribNatR := ""
	cTribAgr  := Alltrim(SuperGetMv("MV_RNFAGRE",.F.,"0")) //0=Não agrega (padrão); 1=Agrega PIS, COFINS e CSLL (CSRF); 2=Agrega IR, PIS, COFINS e CSLL (COSIRF);
	lRet      := .F.	
	
	If cTribAgr $ "1|2" .And. (cTipo := AllTrim(cTipo)) $ "1|2" .And. ((cTipo == "1") .Or. (cTipo == "2" .And. cTribAgr == "2"))
		If (cTribNatR := GetAdvFVal("FKX","FKX_TRIBUT", xFilial("FKX") + cCodNat, 1)) $ "2|5|8" //Tributos permitidos p/ a Nat. Rendimento
			/*-----------------------------------|
			| Códigos DO FKX_TRIBUT (cTribNatR)	 | 
			| 1=IR;								 |
			| 2=IR, PIS, COFINS, CSLL e Agregado |
			| 3=PIS e COFINS				 	 |
			| 4=IR e CSLL						 |
			| 5=IR, CSLL e Agregado				 |	
			| 6=CSLL							 |
			| 7=PIS, COFINS e CSLL    			 |
			| 8=PIS, COFINS, CSLL e Agregado	 |
			-------------------------------------*/		
			lRet := TemImpAgr(aId, cFatoGer, cTipo, nTamImp, nTamPro, cTribAgr)
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} TemImpAgr
	Verifica se o título ou a baixa possui os impostos necessários para 
	realizar a agregação de tributos do bloco 40 da EFD-Reinf.

	@param aIDs,       Array,     ID da FK7 ou da FK2 conforme o fato gerador (FK2 vem como lista para atender o borderô)
	@param cFatoGer,   Character, Indica o fato gerador dos tributos (1-emissao/2-baixa)
	@param cTipo,      Character, Indica se a verificação será para 1-CSRF ou 2-COSIRF
	@param nTamImp ,   Numeric,   Tamanho do FKW_TPIMP no dicionário
	@param nTamPro,    Numeric,   Tamanho do FKW_NUMPRO no dicionário
	@param cMVRNFAGRE, Character, Tributos do bloco 40 da reinf que serão agregados 

	@return lRet, Logical, Verdadeiro se o título/baixa possui todos os impostos
		permitidos para serem agregados.

	@author Fabio Casagrande Lima
	@since  18/09/2023
/*/
Function TemImpAgr(aIDs As Array, cFatoGer As Char, cTipo As Char, nTamImp As Numeric, nTamPro As Numeric, cMVRNFAGRE As Char) As Logical
	Local lRet	     As Logical
	Local lAchouPis  As Logical
	Local lAchouCof  As Logical
	Local lAchouCsl  As Logical
	Local lAchouIrf  As Logical
	Local cTributo   As Char
	Local cTblTpImp  As Char
	Local cQry1      As Char
	Local cQry2      As Char
	Local cTamPro    As Char
	Local cChvFK7	 As Char
	Local aImpos     As Array
	Local aImpSus	 As Array
	Local aAreaAtual As Array 
	Local nPos		 As Numeric

	//Parâmetros de entrada
	Default aIDs       := {}
	Default cFatoGer   := "1"
    Default cTipo      := "1"
    Default nTamImp    := TamSx3( "FKW_TPIMP" )[1]
	Default nTamPro    := TamSx3( "FKY_NUMPRO" )[1]
	Default cMVRNFAGRE := "0"
	
	//Inicializa variáveis
	lRet       := .F.
	lAchouPis  := .F.
	lAchouCof  := .F.
	lAchouCsl  := .F.
	lAchouIrf  := .F.
	cTributo   := ""
	cTblTpImp  := ""
	cQry1      := "" 
	cQry2      := ""
	cChvFK7	   := ""
	cTamPro    := Space(nTamPro)
	aImpos     := {"IRF", "PIS", "COF", "CSL"}
	aImpSus	   := {}
	aAreaAtual := GetArea()
	nPos	   := 0

	If cFatoGer == "1"  //Fato gerador na Emissão
		If __oQryFKW3 == Nil 
			cQry1 := "SELECT DISTINCT(FKW_TPIMP) TRIBUT, FKW_IDDOC IDDOC FROM ? FKW "
			cQry1 += "WHERE FKW_FILIAL = ? AND " 
			cQry1 += 		"FKW_IDDOC IN (?) AND "
			cQry1 += 		"FKW_TPIMP IN ( ? ) AND "
			cQry1 += 		"FKW_CARTEI = '1' AND "
			cQry1 += 		"FKW_NUMPRO = ? AND "
			cQry1 += 		"FKW.D_E_L_E_T_ = ' ' "

			cQry1 := ChangeQuery(cQry1)
			__oQryFKW3 := FWPreparedStatement():New(cQry1)
		Endif

		__oQryFKW3:SetNumeric(1, RetSqlName("FKW") )
		__oQryFKW3:SetString(2, xFilial("FKW") ) //FKW_FILIAL
		__oQryFKW3:SetIn(3, aIds) //FKW_IDDOC
		__oQryFKW3:SetIn(4, aImpos ) //FKW_TPIMP
		__oQryFKW3:SetString(5, cTamPro) //FKW_NUMPRO
		
		cQry1 := __oQryFKW3:GetFixQuery()
	Else //Fato gerador no pagamento
		If __oQryFKY2 == Nil 
			cQry2 := "SELECT DISTINCT(FKY_TPIMP) TRIBUT, FKY_IDDOC IDDOC FROM ? FKY "
			cQry2 += "WHERE FKY_FILIAL = ? AND " 
			cQry2 += 		"FKY_IDFK2 IN ( ? ) AND "
			cQry2 += 		"FKY_TPIMP IN ( ? ) AND "
			cQry2 += 		"FKY_NUMPRO = ? AND "
			cQry2 += 		"FKY.D_E_L_E_T_ = ' ' "

			cQry2 := ChangeQuery(cQry2)
			__oQryFKY2 := FWPreparedStatement():New(cQry2)
		Endif

		__oQryFKY2:SetNumeric(1, RetSqlName("FKY") )
		__oQryFKY2:SetString(2, xFilial("FKY") ) //FKY_FILIAL
		__oQryFKY2:SetIn(3, aIds) //FKY_IDDOC
		__oQryFKY2:SetIn(4, aImpos ) //FKY_TPIMP
		__oQryFKY2:SetString(5, cTamPro) //FKY_NUMPRO

		cQry2 := __oQryFKY2:GetFixQuery()		
	EndIf
	
	cTblTpImp := MpSysOpenQuery(IIf(cFatoGer == "1", cQry1, cQry2))
	
	While (cTblTpImp)->(!Eof())
		cTributo  := Upper(AllTrim((cTblTpImp)->TRIBUT))
		lAchouPis := IIf(lAchouPis, lAchouPis, cTributo == "PIS")
		lAchouCof := IIf(lAchouCof, lAchouCof, cTributo == "COF")
		lAchouCsl := IIf(lAchouCsl, lAchouCsl, cTributo == "CSL")
		lAchouIrf := IIf(lAchouIrf, lAchouIrf, cTributo == "IRF")
		(cTblTpImp)->(DbSkip())
	EndDo
		
	lRet := (lAchouPis .And. lAchouCof .And. lAchouCsl)		
	
	//CSRF (PIS, COFINS e CSLL) | COSIRF (IRF, PIS, COFINS e CSLL) 
	lRet := IIf(cTipo == "1", lRet, (lRet .And. lAchouIrf))
	
	//COSIRF (IRF e CSLL)
	lRet := IIf(lRet, lRet, (cMVRNFAGRE == "2" .And. lAchouIrf .And. lAchouCsl))
	
	If lRet .And. cMVRNFAGRE > '0'
		(cTblTpImp)->(DbGoTop())
		While (cTblTpImp)->(!Eof())
			cChvFK7	:= GetAdvFVal("FK7","FK7_CHAVE", xFilial("FK7") + (cTblTpImp)->IDDOC, 1)
			aImpSus	:= GetImpNRet(cChvFK7, 'SE2')
			If Len(aImpSus) > 0
				lRet := ( nPos := aScan(aImpSus,{|x| AllTrim(x) == 'PIS' .Or. AllTrim(x) == 'COF' .Or. AllTrim(x) == 'CSL' }) ) == 0
				If lRet .And. cMVRNFAGRE == '2'
					lRet := ( nPos := aScan(aImpSus,{|x| AllTrim(x) == 'IRF' }) ) == 0
				EndIf
				If !lRet
					Exit
				EndIf
			EndIf
			(cTblTpImp)->(DbSkip())
		EndDo
	EndIf

	(cTblTpImp)->(DbCloseArea())

	RestArea(aAreaAtual)
	FwFreeArray(aAreaAtual)
	FwFreeArray(aImpos)
	FwFreeArray(aImpSus)
Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} SE2VlBrut
Retorma o coeficiente do valor que foi baixado do título para
gravar a FKY proporcionalmente, comparando-se a FKW.

@param cIdDoc, Character, ID da FK7
@param cTpImp, Character, Tipo de imposto
@param nValBx, Numeric, Valor da baixa
@param nBasImp, Numeric, Base do imposto
@param nTotImpBx , Numeric, Total dos impostos da baixa

@return nRet, Numeric, Coeficiente da baixa

@author Fabio Casagrande Lima
@since  22/12/2023
/*/
//-------------------------------------------------------------------------
Static Function CoefBx(cIdDoc, cTpImp, nValBx, nBasImp, nValImp, nTotImpBx, lBordero As Logical, nVa As Numeric) As Numeric
	Local lVlBxLiq  As Logical
	Local lVlBxAlt	As Logical
	Local lPCCBaixa As Logical
	Local lIrrfBx   As Logical
	Local lJurMul   As Logical
	Local lIssBaixa As Logical
	Local nImpEmis  As Numeric
	Local lCompen   As Numeric
	Local nTotTit   As Numeric
	Local nCoef  	As Numeric
	Local nCalc     As Numeric

	Default cIdDoc := ""
	Default cTpImp := ""
	Default nValBx := 0
	Default nBasImp := 0
	Default nValImp := 0
	Default nTotImpBx := 0
	Default lBordero  := .F.
	Default nVa := 0

	//Inicializa variáveis
	lJurMul   := SuperGetMv("MV_IMPBAIX",.t.,"2") == "1"
	lVlBxAlt  := .F.	
	lCompen   := FwIsInCallStack("FINA340")
	lPCCBaixa := SuperGetMv( "MV_BX10925" ,.T.,"2") == "1"
	lIrrfBx   := SA2->A2_CALCIRF == "2"
	lVlBxLiq  := SuperGetMv("MV_BP10925",.F., "1") == "2" // 1-Bruto / 2- Liquido
	lIssBaixa := IsIssBx("P")
	nImpEmis := If(!lIssBaixa,SE2->E2_ISS+SE2->E2_BTRISS,0) + If(!lPCCBaixa,SE2->(E2_PIS+E2_COFINS+E2_CSLL),0)+If(!lIrrfBx,SE2->E2_IRRF,0) + SE2->E2_INSS + SE2->E2_SEST + SE2->E2_RETENC
	nTotTit   := salRefPag(SE2->E2_FORNECE + SE2->E2_LOJA, _lPccMR, _lIrfMR,,,,, .T.)
	nCalc 	  := 0
	nCoef	  := 1

	
	If __80RAltBx == Nil
		__80RAltBx := FindFunction("F080RAltBx")
	EndIf
	
	If __450AltBx == Nil
		__450AltBx := FindFunction("F450RAltBx")
	EndIf
	
	If lJurMul
		nTotTit+= SE2->(E2_SDACRES - E2_SDDECRE)
	EndIf

	If __lBtrISS == Nil
		__lBtrISS  := SE2->(ColumnPos("E2_BTRISS")) > 0 .And. SE2->(ColumnPos("E2_VRETBIS")) > 0
	EndIf
	
	If nTotTit < 0.0001
		nTotTit := 0
	EndIf

	//Identifica o coeficiente da baixa para calcular a proporcionalidade do imposto de acordo com o valor baixado.
	If Alltrim(cTpImp) $ "SEMIMP" 
		nCalc  := (nValBx / xMoeda(SE2->E2_VALOR, SE2->E2_MOEDA, 1, dDataBase,, SE2->E2_TXMOEDA))	
	ElseIf nBasImp == 0 .and. nValImp == 0
		//Encontra a base de calculo quando o imposto esta totalmente isento ou suspenso
		nBasImp := GetBasNR(cIdDoc,cTpImp,nValBx,nTotImpBx,nTotTit)
		nCalc  := (nBasImp / xMoeda(nTotTit, SE2->E2_MOEDA, 1, dDataBase,, SE2->E2_TXMOEDA)) 	
	Else 
		If lCompen .Or. lBordero
			nValBx := nBasImp
			If lBordero .And. SE2->(E2_SALDO == E2_VALOR)
				nValBx := SE2->E2_VLCRUZ + nImpEmis
			EndIf
		Else
			If __80RAltBx .And. FwIsInCallStack("FINA080")
				lVlBxAlt := F080RAltBx()
			EndIf
			
			If __450AltBx .And. FwIsInCallStack("FINA450")
				lVlBxAlt := F450RAltBx()
			EndIf
			
			If lVlBxAlt .And. lVlBxLiq //Verifica se o valor da baixa foi alterado
				nValBx += nTotImpBx
			ElseIf !lVlBxAlt
				nValBx += (nTotImpBx+nVa+nImpEmis)
				
				If !lVlBxLiq .And. SE2->(E2_SALDO < E2_VALOR)
					nValBx += IIf(lPCCBaixa .And. SE2->(E2_PIS+E2_COFINS+E2_CSLL) > 0, SE2->(E2_VRETPIS+E2_VRETCOF+E2_VRETCSL), 0)
					nValBx += IIf(lIrrfBx .And. SE2->E2_IRRF > 0, SE2->E2_VRETIRF, 0)
					nValBx += IIf(lIssBaixa .And. SE2->E2_ISS > 0, SE2->E2_VRETISS + IIf(__lBtrISS, SE2->E2_VRETBIS, 0), 0)
				EndIf
			EndIf
		EndIf
		
		nTotTit := xMoeda(nTotTit, SE2->E2_MOEDA, 1, dDataBase,, SE2->E2_TXMOEDA)
		
		//Caso o valor baixado for menor que o total do título, encontra o coeficiente para proporcionalizar os valores da FKW
		If nValBx < nTotTit
			nCalc  := nValBx/nTotTit
		EndIf
	Endif

	If nCalc != 0
		nCoef  := nCalc
	Endif
		
Return nCoef

//----------------------------------------------------------------------------------------------
/*/{Protheus.doc}FVldImp
Função para verificação dos impostos configurados via Motor de Retenção

@author
Parametros
@return aImpConf - Retencoes configuradas no Motor para Natureza/Fornecedor

@since  02/09/2025
@version 12
/*/
//----------------------------------------------------------------------------------------------
Static Function FVldImp(cIdDocFK7) As Array

	Local aImpConf 	As Array
	Local nZ 		As Numeric

	aImpConf := {}
	nZ := 0

	_lPccMR := .F.
	_lIrfMR	:= .F.

	//Valida quais os impostos configurados pelo motor de retenções
	aImpConf := FinImpConf("1", SE2->E2_FILORIG, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ, cIdDocFK7, SE2->E2_EMISSAO)

	For nZ := 1 to Len(aImpConf)
		Do Case
			Case aImpConf[nZ,1] $ "PIS|COF|CSL"
				_lPccMR := .T.
			Case aImpConf[nZ,1] == "IRF"
				_lIrfMR := .T.		
		End Case
	Next

	FWFreeArray(aImpConf)

Return 

