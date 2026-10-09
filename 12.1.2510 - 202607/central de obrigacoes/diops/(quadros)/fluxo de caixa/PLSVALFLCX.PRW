#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVALFLCX

Fonte criado para implementacao das regras de validacao da DIOPS quadro Fluxo de Caixa

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSVALFLCX(aItensRegras)
Local cFuncao				:=	"" 
Local nRegras				:= 0
Local aRetorno				:= {}
Default aItensRegras	:= {'A'}	//,'B','C','D','E','F','G','H','I','J'}

For nRegras := 1 TO Len(aItensRegras)

	cFuncao := "FluxCaixa" + aItensRegras[nRegras] + "()" 
	lRetorno := &cFuncao 
	aAdd(aRetorno,{aItensRegras[nRegras],lRetorno})

Next nFor

Return aRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVALFLCX

Validacao do codigo da DIOPS quadro Fluxo de Caixa

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function FluxCaixaA(cCodigo) 
Local aTabFlx	:= GetTabFLCX()
Local lRet		:= .T.
Default cCodigo	:= B8H->B8H_CODIGO

If aScan(aTabFlx,{ |x| x[1] == cCodigo}) == 0
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FluxCaixaB

Valida se as contas 1213+1211 bate com o saldo final da conta 121

@author timoteo.bega
@since 18/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function FluxCaixaB() 
Local aTabFlx	:= GetTabFLCX()
Local lRet		:= .T.
Local cSql		:= ""
Local cConta	:= "121"
Local nVlrFlCx	:= 0
Local nVlrBal	:= 0
Local cAliTrb := GetNextAlias()

cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,1,cConta)
nVlrFlCx := RetornaValor(cAliTrb,cSql)

cSql := RetornaConsulta(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,2,'')
nVlrBal := RetornaValor(cAliTrb,cSql)

If nVlrFlCx != nVlrBal
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FluxCaixaC

Funcao criada para validar Critica 
Para esta conta o do saldo final deve ser menor ou igual a zero

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author jose.paulo
@since 25/07/2019
/*/
//--------------------------------------------------------------------------------------------------
Function FluxCaixaC(oModel)
	Local lRet := .T.
	Local cSql 	:= ""
	Local aNegativo := {"105","106","107","108","109","110","111","112","113","114","115","206","207","208","209","210","305","306","307","308"}

		Default oModel := Nil	

	If oModel == Nil
		cCodigo 	:= AllTrim(B8H->B8H_CODIGO)	
		nVlrCon	:= B8H->B8H_VLRCON
	Else
		cCodigo 	:= AllTrim(oModel:GetValue( 'B8HMASTER', 'B8H_CODIGO' ))
		nVlrCon 	:= oModel:GetValue( 'B8HMASTER', 'B8H_VLRCON' )
	EndIf

	nPos := Ascan( aNegativo,{|x| x == cCodigo })

	lRet := nPos == 0 .OR. nVlrCon <= 0	
	
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaConsulta

Funcao criada montar as consultas de validacao 

@author timoteo.bega
@since 27/10/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaConsulta(cCodOpe,cCodObr,cAnoCmp,cCdComp,nOpcTab,cConta)
	Local cSql			:= ""
	Local cFilTab		:= ""
	Local cTabela		:= ""
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cCdComp	:= ""
	Default nOpcTab	:= 1
	Default cConta	:= ""

	If nOpcTab == 1//Balancete

		cTabela := "B8A"
		cCampos := " SUM(B8A_SALFIN - B8A_SALANT) VALOR "
		cWhere := " AND B8A_CONTA = '" + cConta + "' "

	Else//Fluxo de Caixa

		cTabela := "B8H"
		cCampos := " SUM(B8H_VLRCON) VALOR "
		cWhere := ""

	EndIf

	cFilTab := xFilial(cTabela)
	cSql := "SELECT " + cCampos + " FROM " + RetSqlName(cTabela) + " WHERE " + cTabela + "_FILIAL='" + cFilTab + "' AND " + cTabela + "_CODOPE='" + cCodOpe + "' AND " + cTabela + "_CODOBR='" + cCodObr + "' AND " + cTabela + "_ANOCMP='" + cAnoCmp + "' AND " + cTabela + "_CDCOMP='" + cCdComp + "' " + cWhere + " AND D_E_L_E_T_=' '"
	cSql := ChangeQuery(cSql)

Return cSql

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