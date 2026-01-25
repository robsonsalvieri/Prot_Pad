////////////////
// Versao 001 //
////////////////

#include "protheus.ch"
#include "VEICLSAB.CH"

Function VEICLSAB()
Return()

/*/{Protheus.doc} DMS_BackOrder

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Classe para facilitar operações com backorder

/*/
Class DMS_BackOrder
	Method New() CONSTRUCTOR
	Method QueryAll()
	Method QueryAllP()
	Method GetItensBO()
	Method GetStatus()
	Method InStarvation()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_BackOrder
	@author Vinicius Gati
	@since 05/10/2015
/*/
Method New() Class DMS_BackOrder
Return SELF

/*/{Protheus.doc} QueryAll
	Busca os dados filtrando por orçamento


	@author  Vinicius Gati
	@since   05/10/2015
	@param   aDados , Array , Será usado como datacontainer para pegar parametros de filtro
	@example 

/*/
Method QueryAll(cFil, aDados, cTipo) Class DMS_BackOrder

	Local oParams  := DMS_DataContainer():New(aDados)
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local cQuery   := " "
	Local aResults := {}
	Local cBckFil  := cFilAnt
	Local cAl      := GetNextAlias()
	Local lNewRes  := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?

	cFilAnt := cFil

	IF lNewRes

		cQuery += "   SELECT VS1.VS1_FILIAL AS FILIAL, VS1.VS1_NUMORC AS NUMORC, VS1.VS1_DATORC AS DATORC, VB5.VB5_DATSUG AS DATREG, ' ' AS HORREG "
		cQuery += "     FROM "+oSqlHlp:NoLock('VB5')
		cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VB5_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VB5_CODITE AND B1_GRUPO   = VB5_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SDF')+" ON DF_FILIAL  = '"+xFilial('SDF')+"' AND DF_CODIGO  = VB5_CODSFJ AND DF_PRODUTO = B1_COD     AND SDF.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON C7_FILIAL  = '"+xFilial('SC7')+"' AND VB5_PEDCPA = C7_NUM     AND C7_ITEM    = VB5_ITEPED AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += "    WHERE VB5.D_E_L_E_T_ = ' '  AND VB5.VB5_FILIAL = '"+xFilial('VB5')+"' "
//		cQuery += "      AND VE6_FORPED = '"+cTipo+"' "

		If ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
			cQuery += " AND VB5_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' AND VB5_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', ""))
			cQuery += " AND VB5_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
			cQuery += " AND VB5_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
		EndIf

		If ! EMPTY(oParams:GetValue('VE6_CODITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
			cQuery += " AND VB5_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' AND VB5_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_DE', ""))
			cQuery += " AND VB5_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
			cQuery += " AND VB5_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
		EndIf

		if ! EMPTY(oParams:GetValue('VS1_NUMORC', ""))
			cQuery += " AND VS1_NUMORC = '"+ oParams:GetValue('VS1_NUMORC') +"'  "
		EndIf

		cQuery += " GROUP BY VS1_FILIAL,VB5.D_E_L_E_T_,VS1_NUMORC ,VS1_DATORC ,VB5_DATSUG  "

	Else 

		cQuery += "   SELECT VS1.VS1_FILIAL AS FILIAL, VS1.VS1_NUMORC AS NUMORC, VS1.VS1_DATORC AS DATORC, VE6.VE6_DATREG AS DATREG, VE6.VE6_HORREG AS HORREG "
		cQuery += "     FROM "+oSqlHlp:NoLock('VE6')
		cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VE6_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VE6_CODITE AND B1_GRUPO   = VE6_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SDF')+" ON DF_FILIAL  = '"+xFilial('SDF')+"' AND DF_CODIGO  = VE6_SUGCOM AND DF_PRODUTO = B1_COD     AND SDF.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON C7_FILIAL  = '"+xFilial('SC7')+"' AND VE6_PEDCOM = C7_NUM     AND C7_ITEM    = VE6_ITEMPC AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += "    WHERE VE6.D_E_L_E_T_ = ' '  AND VE6.VE6_FILIAL = '"+xFilial('VE6')+"' "
		
		cQuery += " AND VE6_INDREG = '"+oParams:GetValue('VE6_INDREG', "4")+"' " // 4 - BackOrder

		If ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
			cQuery += " AND VE6_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' AND VE6_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', ""))
			cQuery += " AND VE6_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
			cQuery += " AND VE6_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
		EndIf

		If ! EMPTY(oParams:GetValue('VE6_CODITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
			cQuery += " AND VE6_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' AND VE6_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_DE', ""))
			cQuery += " AND VE6_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
			cQuery += " AND VE6_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
		EndIf

		if ! EMPTY(oParams:GetValue('VS1_NUMORC', ""))
			cQuery += " AND VS1_NUMORC = '"+ oParams:GetValue('VS1_NUMORC') +"'  "
		EndIf

		cQuery += " GROUP BY VS1_FILIAL,VE6.D_E_L_E_T_,VS1_NUMORC ,VS1_DATORC ,VE6_DATREG ,VE6_HORREG "

	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )

	(cAl)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
	While !(cAl)->(EOF())          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		cFStatus := oParams:GetValue('STATUS')
		cStatus  := self:GetStatus(xFilial('VS1'), (cAl)->NUMORC )
		If cFStatus == "TODOS" .OR. cStatus == cFStatus
			aEl := {                                   ;
				{ 'FILIAL', (cAl)->FILIAL },;
				{ 'NUMORC', (cAl)->NUMORC },;
				{ 'DATORC', (cAl)->DATORC },;
				{ 'DATREG', (cAl)->DATREG },;
				{ 'HORREG', (cAl)->HORREG },;
				{ 'STATUS', cStatus           } ;
			}
			oEl := DMS_DataContainer():New(aEl)
			AADD(aResults, oEl)
		EndIf

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return aResults

/*/{Protheus.doc} QueryAllP
	Busca os dados filtrando por pedido


	@author  Vinicius Gati
	@since   05/10/2015
	@param   aDados , Array , Será usado como datacontainer para pegar parametros de filtro
	@example 

/*/
Method QueryAllP(cFil, aDados, cTipo) Class DMS_BackOrder

	Local oParams  := DMS_DataContainer():New(aDados)
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local cQuery   := " "
	Local cAl      := getNextAlias()
	Local aResults := {}
	Local cBckFil  := cFilAnt
	Local lNewRes  := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
	
	cFilAnt := cFil

	IF lNewRes

		cQuery += "   SELECT VS1.VS1_FILIAL AS FILIAL, VS1.VS1_NUMORC AS NUMORC, C7_ITEM AS ITEM, VS1.VS1_DATORC AS DATORC, VB5.VB5_DATSUG AS DATREG, '' AS HORREG "
		cQuery += "     FROM "+oSqlHlp:NoLock('VB5')
		cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VB5_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VB5_CODITE AND B1_GRUPO   = VB5_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SDF')+" ON DF_FILIAL  = '"+xFilial('SDF')+"' AND DF_CODIGO  = VB5_CODSFJ AND DF_PRODUTO = B1_COD     AND SDF.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON C7_FILIAL  = '"+xFilial('SC7')+"' AND VB5_PEDCPA = C7_NUM     AND C7_ITEM    = VB5_ITEPED     AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += "    WHERE VB5.D_E_L_E_T_ = ' '  AND VB5.VB5_FILIAL = '"+xFilial('VB5')+"' "

		If ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
			cQuery += " AND VB5_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' AND VB5_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', ""))
			cQuery += " AND VB5_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
			cQuery += " AND VB5_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
		EndIf

		If ! EMPTY(oParams:GetValue('VE6_CODITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
			cQuery += " AND VB5_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' AND VB5_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_DE', ""))
			cQuery += " AND VB5_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
			cQuery += " AND VB5_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
		EndIf

		If ! EMPTY(oParams:GetValue('VE6_DATREG_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_DATREG_ATE', ""))
			cQuery += " AND VB5_DATSUG >= '"+DTOS(oParams:GetValue('VE6_DATREG_DE'))+"' AND VB5_DATSUG <= '"+DTOS(oParams:GetValue('VE6_DATREG_ATE'))+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_DATREG_DE', ""))
			cQuery += " AND VB5_DATSUG >= '"+DTOS(oParams:GetValue('VE6_DATREG_DE'))+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_DATREG_ATE', ""))
			cQuery += " AND VB5_DATSUG <= '"+DTOS(oParams:GetValue('VE6_DATREG_ATE'))+"' "
		EndIf

		if ! EMPTY(oParams:GetValue('C7_NUM', ""))
			cQuery += " AND C7_NUM = '"+ oParams:GetValue('C7_NUM') +"'  "
		EndIf

		cQuery += " GROUP BY VS1_FILIAL,VB5.D_E_L_E_T_ ,C7_ITEM,VS1_NUMORC ,VS1_DATORC ,VB5_DATSUG "

	Else 
		cQuery += "   SELECT VS1.VS1_FILIAL AS FILIAL, VS1.VS1_NUMORC AS NUMORC, C7_ITEM AS ITEM, VS1.VS1_DATORC AS DATORC, VE6.VE6_DATREG AS DATREG, VE6.VE6_HORREG AS HORREG"
		cQuery += "     FROM "+oSqlHlp:NoLock('VE6')
		cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VE6_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VE6_CODITE AND B1_GRUPO   = VE6_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SDF')+" ON DF_FILIAL  = '"+xFilial('SDF')+"' AND DF_CODIGO  = VE6_SUGCOM AND DF_PRODUTO = B1_COD     AND SDF.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON C7_FILIAL  = '"+xFilial('SC7')+"' AND VE6_PEDCOM = C7_NUM     AND C7_ITEM    = B1_COD     AND SC7.D_E_L_E_T_ = ' ' "
		cQuery += "    WHERE VE6.D_E_L_E_T_ = ' '  AND VE6.VE6_FILIAL = '"+xFilial('VE6')+"' "
		cQuery += " AND VE6_INDREG = '"+oParams:GetValue('VE6_INDREG', "4")+"' " // 4 - BackOrder

		If ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
			cQuery += " AND VE6_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' AND VE6_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', ""))
			cQuery += " AND VE6_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
			cQuery += " AND VE6_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
		EndIf

		If ! EMPTY(oParams:GetValue('VE6_CODITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
			cQuery += " AND VE6_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' AND VE6_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_DE', ""))
			cQuery += " AND VE6_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
			cQuery += " AND VE6_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
		EndIf

		If ! EMPTY(oParams:GetValue('VE6_DATREG_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_DATREG_ATE', ""))
			cQuery += " AND VE6_DATREG >= '"+DTOS(oParams:GetValue('VE6_DATREG_DE'))+"' AND VE6_DATREG <= '"+DTOS(oParams:GetValue('VE6_DATREG_ATE'))+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_DATREG_DE', ""))
			cQuery += " AND VE6_DATREG >= '"+DTOS(oParams:GetValue('VE6_DATREG_DE'))+"' "
		ElseIf ! EMPTY(oParams:GetValue('VE6_DATREG_ATE', ""))
			cQuery += " AND VE6_DATREG <= '"+DTOS(oParams:GetValue('VE6_DATREG_ATE'))+"' "
		EndIf

		if ! EMPTY(oParams:GetValue('VS1_NUMORC', ""))
			cQuery += " AND C7_NUM = '"+ oParams:GetValue('C7_NUM') +"'  "
		EndIf

		cQuery += " GROUP BY VS1_FILIAL,VE6.D_E_L_E_T_ ,C7_ITEM,VS1_NUMORC ,VS1_DATORC ,VE6_DATREG ,VE6_HORREG "

	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )

	(cAl)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
	While !(cAl)->(EOF())          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
		cFStatus := oParams:GetValue('STATUS') // filtro
		cStatus  := self:GetStatus(xFilial('VS1'), (cAl)->NUMORC )
		If cFStatus == "TODOS" .OR. cStatus == cFStatus
			aEl := {;
				{ 'FILIAL', (cAl)->FILIAL },;
				{ 'NUMORC', (cAl)->NUMORC },;
				{ 'DATORC', (cAl)->DATORC },;
				{ 'DATREG', (cAl)->DATREG },;
				{ 'ITEM'  , (cAl)->ITEM   },;
				{ 'HORREG', (cAl)->HORREG },;
				{ 'STATUS', cStatus       } ;
			}
			oEl := DMS_DataContainer():New(aEl)
			AADD(aResults, oEl)
		EndIf

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return aResults

/*/{Protheus.doc} GetItensBO
	Construtor simples DMS_BackOrder


	@author  Vinicius Gati
	@since   05/10/2015

Parâmetros:
	cFil: Filial
	cOrcNum: Numero do Orçamento/Pedido que fez a Sugestão, se nulo abre janela para busca geral de Sugestão BackOrder
	cSugBO: 1 - Sugestão de Compras BackOrder / Outras Sugestões de Compras (Não BackOrder)
	cTipo: não utilizado
	
	@example 

/*/
Method GetItensBO(cFil, cNumOrc, cSugBO, cTipo) Class DMS_BackOrder

	Local cQuery   := " "
	Local cAl      := getNextAlias()
	Local aResults := {}
	Local cBckFil  := cFilAnt
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local oPedido  := DMS_Pedido():New()
	Local lNewRes  := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
	Local nQtdAte  := 0

	cFilAnt := cFil

	IF lNewRes

		cQuery += "   SELECT VS1_NUMORC AS NUMORC, VB5.D_E_L_E_T_ AS DELETED, VB5_FILIAL AS FILIAL, VB5_CODSFJ AS SUGCOM, B1_COD AS CODPRO, VB5_CODITE AS CODITE, VB5_GRUITE AS GRUITE, VB5_SEQITE AS ITEORC, VB5_QTDSUG AS QTDSUG, VB5_QTDAGU AS QTDATE "
		cQuery += "     FROM "+oSqlHlp:NoLock('VB5')
		cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VB5_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VB5_CODITE AND B1_GRUPO   = VB5_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SDF')+" ON DF_FILIAL  = '"+xFilial('SDF')+"' AND DF_CODIGO  = VB5_CODSFJ AND DF_PRODUTO = B1_COD "
		cQuery += "    WHERE VB5.VB5_FILIAL = '"+xFilial('VB5')+"' "
		cQuery += "      AND VS1_NUMORC = '"+ cNumOrc +"' "
		cQuery += " GROUP BY VS1_NUMORC, VB5.D_E_L_E_T_, VB5_FILIAL, VB5_CODSFJ, B1_COD, VB5_CODITE, VB5_GRUITE, VB5_SEQITE, VB5_QTDSUG, VB5_QTDAGU "

	Else

		cQuery += "   SELECT VS1_NUMORC AS NUMORC, VE6.D_E_L_E_T_ AS DELETED, VE6_FILIAL AS FILIAL, VE6_SUGCOM AS SUGCOM, B1_COD AS CODPRO, VE6_CODITE AS CODITE, VE6_GRUITE AS GRUITE, VE6_ITEORC AS ITEORC, VE6_QTDITE AS QTDSUG, VE6_QTDATE AS QTDATE "
		cQuery += "     FROM "+oSqlHlp:NoLock('VE6')
		cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VE6_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VE6_CODITE AND B1_GRUPO   = VE6_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "    WHERE VE6.VE6_FILIAL = '"+xFilial('VE6')+"' "
		cQuery += "      AND VS1_NUMORC = '"+ cNumOrc +"' "
		If cSugBO == "1" // Sugestão BackOrder
			cQuery += "      AND VE6_INDREG = '4' " // 4 - BackOrder
			cQuery += "      AND VE6_ITEORC <> '' "
		Else // Outras Sugestões (não BackOrder)
			cQuery += "      AND VE6_INDREG = '0' " // Sugestão de Compras
			cQuery += "      AND VE6_ORIREQ = '1' " // Orçamento Balcão
		Endif
		cQuery += " GROUP BY VS1_NUMORC, VE6.D_E_L_E_T_, VE6_FILIAL, VE6_SUGCOM, B1_COD, VE6_CODITE, VE6_GRUITE, VE6_ITEORC, VE6_QTDITE, VE6_QTDATE "

	Endif

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )

	(cAl)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
	While !(cAl)->(EOF())          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo

		If lNewRes
			nQtdAte := (cAl)->QTDSUG - (cAl)->QTDATE
		Else
			nQtdAte := (cAl)->QTDATE
		EndIf

		aEl := {;
			{ 'FILIAL'  , (cAl)->FILIAL },;
			{ 'NUMORC'  , (cAl)->NUMORC },;
			{ 'SUGCOM'  , (cAl)->SUGCOM },;
			{ 'CODPRO'  , (cAl)->CODPRO },;
			{ 'CODITE'  , (cAl)->CODITE },;
			{ 'GRUITE'  , (cAl)->GRUITE },;
			{ 'ITEORC'  , (cAl)->ITEORC },;
			{ 'QTDSUG'  , (cAl)->QTDSUG },;
			{ '_DELETED', (cAl)->DELETED},;
			{ 'QTDATE'  , nQtdAte       } ;
		}

		oEl := DMS_DataContainer():New(aEl)
		AADD(aResults, oEl)

		DbSkip()
	End
	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return aResults

/*/{Protheus.doc} GetStatus
	Construtor simples DMS_BackOrder


	@author  Vinicius Gati
	@since   05/10/2015
	@param   aDados , Array , Será usado como datacontainer para pegar parametros de filtro
	@example 

/*/
Method GetStatus(cFil, cNumOrc, cTipo) Class DMS_BackOrder
	Local cQuery   := " "
	Local cAl1     := 'ASD'
	Local cBckFil  := cFilAnt
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local oPedido  := DMS_Pedido():New()
	Local lNewRes  := GetNewPar("MV_MIL0181",.f.) // Controla nova reserva no ambiente?
	Local cStatus  := STR0001	// "AGUARDANDO"
	
	cFilAnt := cFil

	If FM_SQL("SELECT COALESCE(COUNT(*),0) FROM " + oSqlHlp:NoLock('VQL') + " WHERE VQL_AGROUP = 'BO_DELETED' AND VQL_TIPO = '"+cNumOrc+"' AND VQL_FILORI = '"+xFilial('VS1')+"' AND D_E_L_E_T_ = ' ' ") > 0
		return STR0002	// "CANCELADO"
	EndIf

	IF !lNewRes 
		cQuery += "   SELECT SUM(VE6_QTDITE) VE6_QTDITE, SUM(VE6_QTDATE) VE6_QTDATE "
		cQuery += "     FROM "+oSqlHlp:NoLock('VE6')
		cQuery += "    WHERE VE6.VE6_FILIAL = '"+xFilial('VE6')+"' "
		cQuery += "      AND VE6.VE6_NUMORC = '"+ cNumOrc +"' "
		cQuery += "      AND VE6.VE6_INDREG = '4' " // 4 - BackOrder
		cQuery += "      AND VE6.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl1, .F., .T. )

		(cAl1)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
		While !(cAl1)->(EOF())          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
			If( (cAl1)->VE6_QTDITE == (cAl1)->VE6_QTDATE )
				cStatus := STR0003	// "ATENDIDO"
			ElseIf (cAl1)->VE6_QTDITE < (cAl1)->VE6_QTDATE
				cStatus := STR0004	// "PARCIAL"
			ElseIf (cAl1)->VE6_QTDATE == 0
				cStatus := STR0001	// "AGUARDANDO"
			EndIf
			(cAl1)->(DbSkip())
		End
		(cAl1)->(dbCloseArea())

		cFilAnt := cBckFil
	Else
		cQuery += "   SELECT SUM(VB5_QTDSUG) VB5_QTDSUG, SUM(VB5_QTDAGU) VB5_QTDAGU "
		cQuery += "     FROM "+oSqlHlp:NoLock('VB5')
		cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VB5_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
		cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VB5_CODITE AND B1_GRUPO   = VB5_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SDF')+" ON DF_FILIAL  = '"+xFilial('SDF')+"' AND DF_CODIGO  = VB5_CODSFJ AND DF_PRODUTO = B1_COD     AND SDF.D_E_L_E_T_ = ' ' "
	//	cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SFJ')+" ON FJ_FILIAL  = '"+xFilial('SFJ')+"' AND FJ_CODIGO  = DF_CODIGO  AND SFJ.D_E_L_E_T_ = '' "
	//	cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON C7_FILIAL  = '"+xFilial('SC7')+"' AND C7_PEDIDO  = FJ_SOLICIT AND AND C7_PRODUTO = DF_PRODUTO AND SC7.D_E_L_E_T_ = '' "
		cQuery += "    WHERE VB5.D_E_L_E_T_ = ' '  AND VB5.VB5_FILIAL = '"+xFilial('VB5')+"' "
	//	cQuery += "      AND VB5_FORPED = '"+ cTipo   +"' "
		cQuery += "      AND VS1_NUMORC = '"+ cNumOrc +"' "
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl1, .F., .T. )

		(cAl1)->(DbGoTop()) // Posiciona o cursor no início da área de trabalho ativa
		While !(cAl1)->(EOF())          // Enquanto o cursor da área de trabalho ativa não indicar fim de arquivo
			If( (cAl1)->VB5_QTDSUG == (cAl1)->VB5_QTDAGU )
				cStatus := STR0001	// "AGUARDANDO"
			ElseIf (cAl1)->VB5_QTDAGU > 0
				cStatus := STR0004	// "PARCIAL"
			ElseIf (cAl1)->VB5_QTDAGU == 0
				cStatus := STR0003	// "ATENDIDO"
			EndIf
			(cAl1)->(DbSkip())
		End
		(cAl1)->(dbCloseArea())

		cFilAnt := cBckFil
	Endif		

Return cStatus


/*/{Protheus.doc} InStarvation
	Eternamente esperando chegada de itens?

	@author  Vinicius Gati
	@since   05/10/2015
	@param   oDados , DataContainer , Dados do item
			 aEl := {                                ;
			 	{ 'VE6_FILIAL', (cAl)->VE6_FILIAL },;
			 	{ 'VS1_NUMORC', (cAl)->VS1_NUMORC },;
			 	{ 'VE6_SUGCOM', (cAl)->VE6_SUGCOM },;
			 	{ 'B1_COD'    , (cAl)->B1_COD     },;
			 	{ 'VE6_CODITE', (cAl)->VE6_CODITE },;
			 	{ 'VE6_GRUITE', (cAl)->VE6_GRUITE },;
			 	{ 'VE6_ITEORC', (cAl)->VE6_ITEORC },;
			 	{ 'VE6_QTDITE', (cAl)->VE6_QTDITE },;
			 	{ '_DELETED'  , (cAl)->_DELETED   },;
			 	{ 'VE6_QTDATE', (cAl)->VE6_QTDATE } ;
			 }
	@example 

/*/
Method InStarvation(oItData) Class DMS_BackOrder
	return FM_SQL(" SELECT COUNT(*) FROM "+RetSqlName('SFJ')+" WHERE FJ_FILIAL = '"+xFilial('SFJ')+"' AND FJ_CODIGO = '"+oItData:GetValue('SUGCOM')+"' AND FJ_SOLICIT <> '' AND D_E_L_E_T_ = '' ") > 0
Return .F.
