#Include 'totvs.ch'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDAGC01

Funcao criada para validar Critica AC01
Somatório dos itens referente a Contraprestação Emitida em Planos Coletivos por Adesão não confere com o total da conta 31111104.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDAGC01()

	Local lRetorno := .F.
	Local cCampo   := 'B8K_PLACE'		// Contraprestação Emitida em Planos Coletivos por Adesão
	Local aConta   := {'31111104'}
	
	lRetorno := PlVldAGCGe(cCampo, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDAGC02

Funcao criada para validar Critica AC02
Somatório dos itens referente a Planos IFPL não confere com o total da conta 411X1104.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDAGC02()

	Local lRetorno := .F.
	Local cCampo   := 'B8K_PLAEV'	// Eventos/Sinistros conhecidos em Planos Coletivos por Adesão
	Local aConta   := {'41111104','41121104','41131104','41141104','41151104','41171104','41181104','41191104'}
	lRetorno := PlVldAGCGe(cCampo, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDAGC03

Funcao criada para validar Critica AC03
Somatório dos itens referente a Contraprestação Emitida em Planos Coletivos Empresariais não confere com o total da conta 31111106.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDAGC03()

	Local lRetorno	:= .F.
	Local cCampo	:= 'B8K_PCECE'	// Contraprestação Emitida em Planos Coletivos Empresariais
	Local aConta	:= {'31111106'}
	
	lRetorno	:= PlVldAGCGe(cCampo, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDAGC04

Funcao criada para validar Critica AC04
Somatório dos itens referente a Planos PLAP não confere com o total da conta 411X1106.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 23/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDAGC04()
	
	Local lRetorno := .F.
	Local cCampo   := 'B8K_PCEEV'	// Eventos/Sinistros conhecidos em Planos Coletivos Empresariais
	Local aConta   := {'41111106', '41121106', '41131106', '41141106','41151106', '41171106', '41181106', '41191106'}

	lRetorno := PlVldAGCGe(cCampo, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDAGC05

Funcao criada para validar Critica AC05
Somatório dos itens referente a Planos PLAP não confere com o total da conta 31171104.

@return lRetorno .F. registro criticado ou .T. registro nao criticado

@author lima.everton
@since 24/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDAGC05()

	Local lRetorno := .F.
	Local cCampo   := 'B8K_PLACC'	// Correspondencia Cedida em Planos Coletivos Adesão
	Local aConta   := {'31171104'}
	Local lB8K_PLACC := B8K->(FieldPos("B8K_PLACC") > 0)

	lRetorno := PlVldAGCGe(cCampo, aConta,,lB8K_PLACC)

	If !lB8K_PLACC .And. !IsInCallStack('MVCAGCN_19')
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDAGC06

Funcao criada para validar Critica AC06
Somatório dos itens referente a Planos PLAP não confere com o total da conta 31171106.

@return lRetorno .F. registro criticado ou .T. registro nao criticado

@author lima.everton
@since 24/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDAGC06()

	Local lRetorno := .F.
	Local cCampo   := 'B8K_PCECC'	// Correspondencia Cedida em Planos Coletivos Empresariais
	Local aConta   := {'31171106'}
	Local lB8K_PLACC := B8K->(FieldPos("B8K_PLACC") > 0)

	lRetorno := PlVldAGCGe(cCampo, aConta,,lB8K_PLACC)
	
	If !lB8K_PLACC .And. !IsInCallStack('MVCAGCN_20')
		lRetorno := .F.
	EndIf

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVldAGCGe

Funcao criada para validar Critica CA03
Somatório dos itens referente a Cobertura Assitencial diverge do total da conta.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author Roger C
@since 22/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlVldAGCGe(cCampo, aConta, oModel,lCpos)
	
	Local lRet	  := .T.
	Local cSql	  := ""
	Local cCodOpe := ""
	Local cCodObr := ""
	Local cAnoCmp := ""
	Local cCdComp := ""	
	Local cConta  := ""
	Local nSldCob := 0
	Local nVez    := 0
	Local lB8K_PLACC := B8K->(FieldPos("B8K_PLACC") > 0)

	Default oModel := Nil	
	Default cCampo := ''
	Default aConta := {}
	Default lCpos  := .T.

	For nVez := 1 to Len(aConta)
		cConta += iif(nVez == Len(aConta),aConta[nVez],aConta[nVez]+',')
	Next

	lRet := !Empty(cConta)
	If lRet .And. lCpos

		If oModel == Nil
			cCodOpe := AllTrim(B3D->B3D_CODOPE)
			cCodObr := AllTrim(B3D->B3D_CDOBRI)
			cAnoCmp := AllTrim(B3D->B3D_ANO)
			cCdComp := AllTrim(B3D->B3D_CODIGO)
		Else
			cCodOpe	:= AllTrim(oModel:GetValue( 'B8KMASTER', 'B8K_CODOPE' ))
			cCodObr	:= AllTrim(oModel:GetValue( 'B8KMASTER', 'B8K_CODOBR' ))
			cAnoCmp	:= AllTrim(oModel:GetValue( 'B8KMASTER', 'B8K_ANOCMP' ))
			cCdComp := AllTrim(oModel:GetValue( 'B8KMASTER', 'B8K_CDCOMP' ))
		EndIf

		cSql := " SELECT SUM(" + cCampo + ") VALOR "
		cSql += " 	FROM " + RetSqlName("B8K")
		cSql += " WHERE B8K_FILIAL = '" + xFilial("B8K") + "' "
		cSql += "	AND B8K_CODOPE = '" + cCodOpe + "' "
		cSql += "	AND B8K_CODOBR = '" + cCodObr + "' "
		cSql += "	AND B8K_ANOCMP = '" + cAnoCmp + "' "
		cSql += "	AND B8K_CDCOMP = '" + cCdComp + "' "
		cSql += "	AND D_E_L_E_T_ = ' ' "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

		If !TRBCON->(Eof())	
			// Se há dados sobre o quadro, guarda valor para comparação com a conta	
			nSldCob	:= TRBCON->VALOR
			TRBCON->(dbCloseArea())
		Else
			// Se nao há dados sobre o quadro, aborta validação retornando Verdadeiro
			TRBCON->(dbCloseArea())
			Return(.T.)			
		EndIf

		cSql := " SELECT SUM( B8A_SALFIN ) B8A_SALFIN "
		cSql += "  FROM " + RetSqlName("B8A")
		cSql += " WHERE B8A_FILIAL = '" + xFilial("B8A") + "' "
		cSql += "  AND B8A_CODOPE = '" + cCodOpe + "' "
		cSql += "  AND B8A_CODOBR = '" + cCodObr + "' "
		cSql += "  AND B8A_ANOCMP = '" + cAnoCmp + "' "
		cSql += "  AND B8A_CDCOMP = '" + cCdComp + "' "
		cSql += "  AND B8A_CONTA  IN " + FormatIn(cConta,",") + " "
		cSql += "  AND D_E_L_E_T_ = ' ' "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

		If !TRBCON->(Eof())	
			lRet := ( TRBCON->B8A_SALFIN == nSldCob )
		Else
			lRet	:= Iif(nSldCob > 0,.F.,.T.)
		EndIf

		TRBCON->(dbCloseArea())

	EndIf

Return lRet