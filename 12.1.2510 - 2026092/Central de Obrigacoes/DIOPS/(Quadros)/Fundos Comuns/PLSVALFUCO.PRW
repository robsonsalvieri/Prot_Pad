#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDFUC01

Funcao criada para validar Critica FC01
Somatório dos totais não confere com o total das contas.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 15/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDFUC01()

	Local lRetorno	:= .F.
	Local cCampo	:= 'B6R_SLDCRD'
	Local cConta	:= "'123911082','123912082','123921082','123922082'"
	Local cWhere	:= " AND B6R_TIPO = 'FCP' "
	
	lRetorno	:= PlVldFUCGe(cCampo, cConta, cWhere)

	If lRetorno
		cCampo	:= 'B6R_SLDDEB'
		cConta	:= "'213819082','213829082'"
		cWhere	:= " AND B6R_TIPO = 'FCP'  "
		lRetorno	:= PlVldFUCGe(cCampo, cConta, cWhere)
	EndIf

Return lRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDFUC02

Funcao criada para validar Critica FC02
Somatório dos totais não confere com o total das contas '124119088','124129088' .

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 15/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDFUC02()

	Local lRetorno	:= .F.
	Local cCampo	:= 'B6R_SLDCRD'
	Local cConta	:= "'124119082','124129082'"
	Local cWhere	:= " AND B6R_TIPO = 'FCA'  "
	lRetorno	:= PlVldFUCGe(cCampo, cConta, cWhere)
	
	If lRetorno
		cCampo	:= 'B6R_SLDDEB'
		cConta	:= "'214889082'"
		cWhere	:= " AND B6R_TIPO = 'FCA'  "
		lRetorno	:= PlVldFUCGe(cCampo, cConta, cWhere)
	EndIf

Return lRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVldFUCGe

Funcao criada para validar Critica
Somatório dos itens diverge do total da conta.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author Roger C
@since 22/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlVldFUCGe(cCampo,cConta,cWhere,oModel)
	Local lRet := .T.
	Local cSql 	:= ""
	Local cCodOpe := ""
	Local cCodObr := ""
	Local cAnoCmp := ""
	Local cCdComp:= ""	
	Local nSldCob	:= 0

	Default oModel := Nil	
	Default cCampo	:= ''
	Default cConta	:= ''
	Default cWhere	:= ''
	
	If Empty(cConta) .or. Empty(cCampo) .or. Empty(cWhere)
		Return(.F.)
	EndIf	

	If oModel == Nil
		cCodOpe := AllTrim(B3D->B3D_CODOPE)
		cCodObr := AllTrim(B3D->B3D_CDOBRI)
		cAnoCmp := AllTrim(B3D->B3D_ANO)
		cCdComp := AllTrim(B3D->B3D_CODIGO)	
	Else
		cCodOpe	:= AllTrim(oModel:GetValue( 'B6RMASTER', 'B6R_CODOPE' )) 
		cCodObr	:= AllTrim(oModel:GetValue( 'B6RMASTER', 'B6R_CODOBR' )) 
		cAnoCmp	:= AllTrim(oModel:GetValue( 'B6RMASTER', 'B6R_ANOCMP' )) 
		cCdComp := AllTrim(oModel:GetValue( 'B6RMASTER', 'B6R_CDCOMP' ))
	EndIf

	cSql := " SELECT SUM(" + cCampo + ") TOTAL, COUNT(" + cCampo + ") NREGS " 
	cSql += "	FROM " + RetSqlName("B6R") 
	cSql += "	WHERE B6R_FILIAL = '" + xFilial("B6R") + "' " 
	cSql += "			AND B6R_CODOPE = '" + cCodOpe + "' "
	cSql += "			AND B6R_CODOBR = '" + cCodObr + "' "
	cSql += "			AND B6R_ANOCMP = '" + cAnoCmp + "' "
	cSql += "			AND B6R_CDCOMP = '" + cCdComp + "' "
	cSql += " 			AND D_E_L_E_T_ = ' ' " 	
	cSql += cWhere
			
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

	If !TRBCON->(Eof()) .and. TRBCON->NREGS > 0	
		// Se há dados sobre o quadro, guarda valor para comparação com a conta	
		nSldCob	:= TRBCON->TOTAL
		TRBCON->(dbCloseArea())
	
	Else
		// Se nao há dados sobre o quadro, aborta validação retornando Verdadeiro
		TRBCON->(dbCloseArea())
		Return(.T.)			

	EndIf

	cSql := " SELECT SUM(B8A_SALFIN) TOTAL "
	cSql += "	FROM " + RetSqlName("B8A") 
	cSql += "	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' " 
	cSql += "			AND B8A_CODOPE = '" + cCodOpe + "' "
	cSql += "			AND B8A_CODOBR = '" + cCodObr + "' "
	cSql += "			AND B8A_ANOCMP = '" + cAnoCmp + "' "
	cSql += "			AND B8A_CDCOMP = '" + cCdComp + "' "
	cSql += "			AND B8A_CONTA IN (" + cConta  + ") "
	cSql += " 			AND D_E_L_E_T_ = ' ' " 	
		
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

	If !TRBCON->(Eof())	
		lRet := ( TRBCON->TOTAL == nSldCob )
	Else
		lRet	:= .F.			
	EndIf
	TRBCON->(dbCloseArea())

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVldFUCGe

Funcao criada para validar campos de Operadora Participante e Adm

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author José Paulo
@since 04/07/2019
/*/
//--------------------------------------------------------------------------------------------------

function CHKCPOFC()
Local lRet:= .T.

IF M->B6R_TIPO == 'FCA' .And. Empty(M->B6R_OPEPAR)
	Help( ,, 'HELP',,"O campo Operadora Participante não está preenchido.", 1,0,NIL,NIL,NIL,NIL,NIL,{"Preencher o campo Operadora Participante."})
	lRet:= .F.
ElseIf M->B6R_TIPO == 'FCP' .And. Empty(M->B6R_OPEADM)
	Help( ,, 'HELP',,"O campo Operadora Administradora não está preenchido.", 1,0,NIL,NIL,NIL,NIL,NIL,{"Preencher o campo Operadora Administradora."})
	lRet:= .F.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVTPFUCO

Funcao criada para limpar campos Operadora ADM e Operadora

@return cRet

@author José Paulo
@since 29/07/2019
/*/
//--------------------------------------------------------------------------------------------------

Function PlVTPFUCO(cVal)
	Local lRet := .T.
	Default cVal := ""

	If cVal == "FCP" 
		M->B6R_OPEPAR:=""
	ElseIf cVal == "FCA"
		M->B6R_OPEADM:=""
	EndIf

Return lRet