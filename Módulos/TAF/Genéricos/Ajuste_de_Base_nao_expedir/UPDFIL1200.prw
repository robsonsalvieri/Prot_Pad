#include 'protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} UPDFIL1200
Funcao de ajuste para igualar o ID do trabalhado da tabela pai 
com as tabelas filhas
@Author TOTVS ESOCIAL
@Since 14/02/2020
@Version 1.0
/*/
//-------------------------------------------------------------------
User Function UPDFIL1200()

Local cQuery  := ""
Local cRegGeral := ""
Local cAliasAjst := GetNextAlias()

cQuery := " SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO, C91.C91_TRABAL, C9L.C9L_TRABAL, C9M.C9M_TRABAL, "
cQuery += " C9Q.C9Q_TRABAL, C9R.C9R_TRABAL, T14.T14_TRABAL, T6Y.T6Y_TRABAL, T6Z.T6Z_TRABAL "
cQuery += " FROM " + RetSqlName("C91") + " C91 "
cQuery += " LEFT JOIN " + RetSqlName("C9L") + " C9L ON (C91.C91_FILIAL = C9L.C9L_FILIAL AND C91.C91_ID = C9L.C9L_ID AND C91.C91_VERSAO = C9L.C9L_VERSAO AND " 
cQuery += " C91.C91_TRABAL <> C9L.C9L_TRABAL  AND C9L.D_E_L_E_T_ = ' ' ) "
cQuery += " LEFT JOIN " + RetSqlName("C9M") + " C9M ON (C91.C91_FILIAL = C9M.C9M_FILIAL AND C91.C91_ID = C9M.C9M_ID AND C91.C91_VERSAO = C9M.C9M_VERSAO AND " 
cQuery += " C91.C91_TRABAL <> C9M.C9M_TRABAL AND C9M.D_E_L_E_T_ = ' ' ) "
cQuery += " LEFT JOIN " + RetSqlName("C9Q") + " C9Q ON (C91.C91_FILIAL = C9Q.C9Q_FILIAL AND C91.C91_ID = C9Q.C9Q_ID AND C91.C91_VERSAO = C9Q.C9Q_VERSAO AND " 
cQuery += " C91.C91_TRABAL <> C9Q.C9Q_TRABAL AND C9Q.D_E_L_E_T_ = ' ' ) "
cQuery += " LEFT JOIN " + RetSqlName("C9R") + " C9R ON (C91.C91_FILIAL = C9R.C9R_FILIAL AND C91.C91_ID = C9R.C9R_ID AND C91.C91_VERSAO = C9R.C9R_VERSAO AND " 
cQuery += " C91.C91_TRABAL <> C9R.C9R_TRABAL AND C9R.D_E_L_E_T_ = ' ' ) "
cQuery += " LEFT JOIN " + RetSqlName("T14") + " T14 ON (C91.C91_FILIAL = T14.T14_FILIAL AND C91.C91_ID = T14.T14_ID AND C91.C91_VERSAO = T14.T14_VERSAO AND " 
cQuery += " C91.C91_TRABAL <> T14.T14_TRABAL AND T14.D_E_L_E_T_ = ' ' ) "
cQuery += " LEFT JOIN " + RetSqlName("T6Y") + " T6Y ON (C91.C91_FILIAL = T6Y.T6Y_FILIAL AND C91.C91_ID = T6Y.T6Y_ID AND C91.C91_VERSAO = T6Y.T6Y_VERSAO AND " 
cQuery += " C91.C91_TRABAL <> T6Y.T6Y_TRABAL AND T6Y.D_E_L_E_T_ = ' ' ) "
cQuery += " LEFT JOIN " + RetSqlName("T6Z") + " T6Z ON (C91.C91_FILIAL = T6Z.T6Z_FILIAL AND C91.C91_ID = T6Z.T6Z_ID AND C91.C91_VERSAO = T6Z.T6Z_VERSAO AND " 
cQuery += " C91.C91_TRABAL <> T6Z.T6Z_TRABAL AND T6Z.D_E_L_E_T_ = ' ' ) "
cQuery += " WHERE "
cQuery += " ((C9L.C9L_TRABAL <> '      ' OR C9L.C9L_TRABAL IS NOT NULL ) OR "
cQuery += " (C9M.C9M_TRABAL <> '      ' OR C9M.C9M_TRABAL IS NOT NULL ) OR " 
cQuery += " (C9Q.C9Q_TRABAL <> '      ' OR C9Q.C9Q_TRABAL IS NOT NULL ) OR "
cQuery += " (C9R.C9R_TRABAL <> '      ' OR C9R.C9R_TRABAL IS NOT NULL ) OR " 
cQuery += " (T14.T14_TRABAL <> '      ' OR T14.T14_TRABAL IS NOT NULL ) OR "
cQuery += " (T6Y.T6Y_TRABAL <> '      ' OR T6Y.T6Y_TRABAL IS NOT NULL ) OR "
cQuery += " (T6Z.T6Z_TRABAL <> '      ' OR T6Z.T6Z_TRABAL IS NOT NULL )) AND " 
cQuery += " C91.D_E_L_E_T_ = ' ' AND C91.C91_ATIVO = '1' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasAjst, .F., .T.)

While !(cAliasAjst)->(EOF())

	cFilC91  := (cAliasAjst)->C91_FILIAL
	cIDC91   := (cAliasAjst)->C91_ID
	cVersC91 := (cAliasAjst)->C91_VERSAO
	
	cRegGeral := cFilC91 + cIDC91 + cVersC91

	If !Empty((cAliasAjst)->C9L_TRABAL) .AND. (cAliasAjst)->C91_TRABAL <> (cAliasAjst)->C9L_TRABAL
		DbSelectArea("C9L")
		C9L->(DbSetOrder(1))
		C9L->(DbSeek(cRegGeral))
		While C9L->(!EOF()) .AND. C9L->(C9L_FILIAL+C9L_ID+C9L_VERSAO) == cRegGeral
			RecLock("C9L", .F.)
			C9L->C9L_TRABAL := (cAliasAjst)->C91_TRABAL
			C9L->(MsUnLock())
		C9L->(DbSkip())	
		End
	EndIf
	
	If !Empty((cAliasAjst)->C9M_TRABAL) .AND. (cAliasAjst)->C91_TRABAL <> (cAliasAjst)->C9M_TRABAL
		DbSelectArea("C9M")
		C9M->(DbSetOrder(1))
		C9M->(DbSeek(cRegGeral))
		While C9M->(!EOF()) .AND. C9M->(C9M_FILIAL+C9M_ID+C9M_VERSAO) == cRegGeral
			RecLock("C9M", .F.)
			C9M->C9M_TRABAL := (cAliasAjst)->C91_TRABAL
			C9M->(MsUnLock())
		C9M->(DbSkip())	
		End	
	EndIf
	
	If !Empty((cAliasAjst)->C9Q_TRABAL) .AND. (cAliasAjst)->C91_TRABAL <> (cAliasAjst)->C9Q_TRABAL
		DbSelectArea("C9Q")
		C9Q->(DbSetOrder(1))
		C9Q->(DbSeek(cRegGeral))
		While C9Q->(!EOF()) .AND. C9Q->(C9Q_FILIAL+C9Q_ID+C9Q_VERSAO) == cRegGeral
			RecLock("C9Q", .F.)
			C9Q->C9Q_TRABAL := (cAliasAjst)->C91_TRABAL
			C9Q->(MsUnLock())
		C9Q->(DbSkip())
		End
	EndIf	

	If !Empty((cAliasAjst)->C9R_TRABAL) .AND. (cAliasAjst)->C91_TRABAL <> (cAliasAjst)->C9R_TRABAL
		DbSelectArea("C9R")
		C9R->(DbSetOrder(1))
		C9R->(DbSeek(cRegGeral))
		While C9R->(!EOF()) .AND. C9R->(C9R_FILIAL+C9R_ID+C9R_VERSAO) == cRegGeral
			RecLock("C9R", .F.)
			C9R->C9R_TRABAL := (cAliasAjst)->C91_TRABAL
			C9R->(MsUnLock())
		C9R->(DbSkip())
		End
	EndIf

	If !Empty((cAliasAjst)->T14_TRABAL) .AND. (cAliasAjst)->C91_TRABAL <> (cAliasAjst)->T14_TRABAL
		DbSelectArea("T14")
		T14->(DbSetOrder(1))
		T14->(DbSeek(cRegGeral))
		While T14->(!EOF()) .AND. T14->(T14_FILIAL+T14_ID+T14_VERSAO) == cRegGeral
			RecLock("T14", .F.)
			T14->T14_TRABAL := (cAliasAjst)->C91_TRABAL
			T14->(MsUnLock())
		T14->(DbSkip())	
		End	
	EndIf

	If !Empty((cAliasAjst)->T6Y_TRABAL) .AND. (cAliasAjst)->C91_TRABAL <> (cAliasAjst)->T6Y_TRABAL
		DbSelectArea("T6Y")
		T6Y->(DbSetOrder(1))
		T6Y->(DbSeek(cRegGeral))
		While T6Y->(!EOF()) .AND. T6Y->(T6Y_FILIAL+T6Y_ID+T6Y_VERSAO) == cRegGeral
			RecLock("T6Y", .F.)
			T6Y->T6Y_TRABAL := (cAliasAjst)->C91_TRABAL
			T6Y->(MsUnLock())
		T6Y->(DbSkip())	
		End	
	EndIf

	If !Empty((cAliasAjst)->T6Z_TRABAL) .AND. (cAliasAjst)->C91_TRABAL <> (cAliasAjst)->T6Z_TRABAL
		DbSelectArea("T6Z")
		T6Z->(DbSetOrder(1))
		T6Z->(DbSeek(cRegGeral))
		While T6Z->(!EOF()) .AND. T6Z->(T6Z_FILIAL+T6Z_ID+T6Z_VERSAO) == cRegGeral
			RecLock("T6Z", .F.)
			T6Z->T6Z_TRABAL := (cAliasAjst)->C91_TRABAL
			T6Z->(MsUnLock())
		T6Z->(DbSkip())
		End
	EndIf

(cAliasAjst)->(DbSKip())
End

MsgInfo("Processo Finalizado")
	
return