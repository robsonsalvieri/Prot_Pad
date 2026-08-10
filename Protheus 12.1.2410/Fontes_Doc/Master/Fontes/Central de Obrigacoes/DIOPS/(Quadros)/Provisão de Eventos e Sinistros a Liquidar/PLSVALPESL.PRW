#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDPES01

Funcao criada para validar Critica PE01
Somatório dos totais não confere com o total das contas 
'21111102','21111202','21112102','21112202',
'21111103','21111203','21112103','21112203',
'23111102','23111202','23112102','23112202',
'23111103','23111203','23112103','23112203'.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado
@author Roger C
@since 15/03/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDPES01()
Local lRetorno	:= .F.
Local aContas	:= {;
						'21111102','21111202','21112102','21112202',;
						'21111103','21111203','21112103','21112203',;
						'23111102','23111202','23112102','23112202',;
						'23111103','23111203','23112103','23112203';
					}

lRetorno	:= PlVldPESGe(aContas)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVldPESGe

Funcao criada para validar Critica CA03
Somatório dos itens referente a Cobertura Assitencial diverge do total da conta do tipo de Produto Saúde.

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author Roger C
@since 22/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlVldPESGe(aConta,oModel)
	Local lRet := .T.
	Local cSql 	:= ""
	Local cCodOpe := ""
	Local cCodObr := ""
	Local cAnoCmp := ""
	Local cCdComp:= ""	
	Local nSldCob	:= 0
	Local nVez	:= 0
	Local  cConta	:= ''

	Default oModel := Nil	
	Default aConta := {}
	
	For nVez := 1 to Len(aConta)
		cConta += aConta[nVez]+','   
	Next

	lRet := !Empty(cConta)
	If lRet
		cConta := FormatIn(cConta,",")
		If oModel == Nil
			cCodOpe := AllTrim(B3D->B3D_CODOPE)
			cCodObr := AllTrim(B3D->B3D_CDOBRI)
			cAnoCmp := AllTrim(B3D->B3D_ANO)
			cCdComp := AllTrim(B3D->B3D_CODIGO)	
		Else
			cCodOpe	:= AllTrim(oModel:GetValue( 'B8JMASTER', 'B8J_CODOPE' )) 
			cCodObr	:= AllTrim(oModel:GetValue( 'B8JMASTER', 'B8J_CODOBR' )) 
			cAnoCmp	:= AllTrim(oModel:GetValue( 'B8JMASTER', 'B8J_ANOCMP' )) 
			cCdComp := AllTrim(oModel:GetValue( 'B8JMASTER', 'B8J_CDCOMP' ))
		EndIf

		cSql := " SELECT SUM(B8J_EVULTI+B8J_EVMAIS+B8J_CAULTI+B8J_CAMAIS) TOTAL " 
		cSql += "	FROM " + RetSqlName("B8J") 
		cSql += "	WHERE B8J_FILIAL = '" + xFilial("B8J") + "' " 
		cSql += "			AND B8J_CODOPE = '" + cCodOpe + "' "
		cSql += "			AND B8J_CODOBR = '" + cCodObr + "' "
		cSql += "			AND B8J_ANOCMP = '" + cAnoCmp + "' "
		cSql += "			AND B8J_CDCOMP = '" + cCdComp + "' "
		cSql += " 			AND D_E_L_E_T_ = ' ' " 	
			
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

		If !TRBCON->(Eof())	
			// Se há dados sobre o quadro, guarda valor para comparação com a conta	
			nSldCob	:= TRBCON->TOTAL
			TRBCON->(dbCloseArea())
		Else
			// Se nao há dados sobre o quadro, aborta validação retornando Verdadeiro
			TRBCON->(dbCloseArea())
			Return(.T.)			

		EndIf

		cSql := " SELECT SUM(B8A_SALFIN) AS VALCTB "
		cSql += "	FROM " + RetSqlName("B8A") 
		cSql += "	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' " 
		cSql += "			AND B8A_CODOPE = '" + cCodOpe + "' "
		cSql += "			AND B8A_CODOBR = '" + cCodObr + "' "
		cSql += "			AND B8A_ANOCMP = '" + cAnoCmp + "' "
		cSql += "			AND B8A_CDCOMP = '" + cCdComp + "' "
		cSql += "			AND B8A_CONTA  IN " + cConta + " "
		cSql += " 			AND D_E_L_E_T_ = ' ' " 	
			
		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

		If !TRBCON->(Eof())	
			lRet := ( TRBCON->VALCTB == nSldCob )
		Else
			lRet	:= .F.			
		EndIf
		TRBCON->(dbCloseArea())
	 EndIf
Return lRet

