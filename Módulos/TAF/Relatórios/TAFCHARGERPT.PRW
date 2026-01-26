#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13
#DEFINE ANALITICO_MOTIVO_DESLIGAMENTO	14
#DEFINE ANALITICO_RECIBO 				15
#DEFINE	ANALITICO_VALOR_DEP 		    16
 
Static oReport		:= Nil
Static lLaySimplif	:= TafLayESoc("S_01_00_00")

//---------------------------------------------------------------------
/*/{Protheus.doc} RptCharge

@type			function
@description	Executa a carga na tabela V3N.
@author			Felipe C. Seolin
@since			03/06/2019
@version		1.0
@param			oRunCharge		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPeriodo		-	Período de referência das informações
@param			aFilial			-	Filiais disponibilizadas para seleção de processamento
@param			cParamCPF		-	CPF selecionado como filtro de processamento
/*/
//---------------------------------------------------------------------
Function RptCharge( oRunCharge as Object, lCallExternal as Logical,;
					cPeriodo as Character, aFilial as array, cParamCPF as Character)

	Local aFilMatriz as Array
	Local aFilMV     as Array
	Local aFilSel    as Array
	Local aInfoSM0   as Array
	Local cCNPJRaiz  as Character
	Local cFilMatriz as Character
	Local lProtheus  as Logical
	Local nI         as Numeric

	Private cFilSel   as Character
	Private cFilSelMV as Character
	Private cST2Alias as Character

	Default aFilial       := {}
	Default cPeriodo      := ""
	Default cParamCPF     := ""
	Default lCallExternal := .F.
	Default oRunCharge    := Nil

	aFilMatriz := TAFGFilMatriz()
	aFilMV     := {}
	aFilSel    := {}
	aInfoSM0   := FWLoadSM0()
	cCNPJRaiz  := SubStr(SM0->M0_CGC, 1, 8)
	cFilMatriz := ""
	cFilSel    := ""
	cFilSelMV  := ""
	cPeriodo   := AllTrim(cPeriodo)
	cST2Alias  := GetNextAlias()
	lProtheus  := GetNewPar("MV_RHTAF", .F.)
	nI         := 0

	For nI := 1 to Len( aFilial )

		If aFilial[nI][1]
			aAdd( aFilSel, aFilial[nI][2] )
		EndIf

	Next nI

	cFilSel := TAFCacheFil(Nil, aFilSel, .T.)

	If oReport == Nil
		oReport := TAFSocialReport():New()
	EndIf

	If !RptFull(cPeriodo, cParamCPF)

		For nI := 1 to Len( aInfoSM0 )

			If SubStr( aInfoSM0[nI,18], 1, 8 ) == cCNPJRaiz .and. aInfoSM0[nI,1] == cEmpAnt
				aAdd( aFilMV, aInfoSM0[nI,2] )
			EndIf

		Next nI

		cFilSelMV	:= TAFCacheFil(Nil, aFilMV, .T.)
		cFilMatriz	:= IIf( !Empty( aFilMatriz ), aFilMatriz[2], "" )

		xTAFCriaTB( ,,"TAFST2", cST2Alias )

		DataS1200( oRunCharge, lCallExternal, cPeriodo, aFilSel, cParamCPF, lProtheus, cFilMatriz, aFilMV )
		DataS2299( oRunCharge, lCallExternal, cPeriodo, aFilSel, cParamCPF, lProtheus, cFilMatriz )
		DataS2399( oRunCharge, lCallExternal, cPeriodo, aFilSel, cParamCPF, lProtheus, cFilMatriz )

		( cST2Alias )->( DBCloseArea() )

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS1200
@type			function
@description	Função responsável por coletar as informações do Evento S-1200 no TAF.
@author			Felipe C. Seolin
@since			03/06/2019
@version		1.0
@param			oRunCharge		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPeriodo		-	Período de referência das informações
@param			aFilial			-	Filiais selecionadas para processamento
@param			lProtheus		-	Indica se a Origem dos dados parte do Protheus
@param			cParamCPF		-	CPF selecionado como filtro de processamento
@param			cFilMatriz		-	Filial Matriz
@param			aFilMV			-	Array de filiais a ser consideradas na cláusula IN do SQL para Múltiplos Vínculos
/*/
//---------------------------------------------------------------------
Static Function DataS1200( oRunCharge as Object, lCallExternal as Logical, cPeriodo as Character, aFilial as Array,;
						   cParamCPF as Character, lProtheus as Logical, cFilMatriz as Character, aFilMV as Array)

	Local aAnalitico  as Array
	Local cAliasQry   as Character
	Local cC87Id      as Character
	Local cCodCat     as Character
	Local cCPF        as Character
	Local cEstab      as Character
	Local cFilBkp     as Character
	Local cFilQry     as Character
	Local cID         as Character
	Local cIDCateg    as Character
	Local cIdeDmd     as Character
	Local cIDEstab    as Character
	Local cIDLotac    as Character
	Local cIDTrabal   as Character
	Local cIncidCP    as Character
	Local cIncidFGTS  as Character
	Local cIncidIRRF  as Character
	Local cIndApu     as Character
	Local cLotacao    as Character
	Local cMatric     as Character
	Local cMVEstab    as Character
	Local cMVLotac    as Character
	Local cMVTpEstab  as Character
	Local cMVTrabal   as Character
	Local cNatureza   as Character
	Local cNome       as Character
	Local cPerApu     as Character
	Local cQuery      as Character
	Local cRecibo     as Character
	Local cTipo       as Character
	Local cTipoEstab  as Character
	Local cTrabal     as Character
	Local cVersao     as Character
	Local lMultVinc   as Logical
	Local nI          as Numeric
	Local nPosValores as Numeric
	Local nQtdProc    as Numeric
	Local nQtdTotal   as Numeric
	Local nRecnoQry   as Numeric
	Local oInfoRPT    as Object

	Default aFilial       := {}
	Default aFilMV        := {}
	Default cFilMatriz    := ""
	Default cParamCPF     := ""
	Default cPeriodo      := ""
	Default lCallExternal := .F.
	Default lProtheus     := .F.
	Default oRunCharge    := Nil

	aAnalitico  := {}
	cAliasQry   := ""
	cC87Id      := ""
	cCodCat     := ""
	cCPF        := ""
	cEstab      := ""
	cFilBkp     := ""
	cFilQry     := ""
	cID         := ""
	cIDCateg    := ""
	cIdeDmd     := ""
	cIDEstab    := ""
	cIDLotac    := ""
	cIDTrabal   := ""
	cIncidCP    := ""
	cIncidFGTS  := ""
	cIncidIRRF  := ""
	cIndApu     := ""
	cLotacao    := ""
	cMatric     := ""
	cMVEstab    := ""
	cMVLotac    := ""
	cMVTpEstab  := ""
	cMVTrabal   := ""
	cNatureza   := ""
	cNome       := ""
	cPerApu     := ""
	cQuery      := ""
	cRecibo     := ""
	cTipo       := ""
	cTipoEstab  := ""
	cTrabal     := ""
	cVersao     := ""
	lMultVinc   := .F.
	nI          := 0
	nPosValores := 0
	nQtdProc    := 0
	nQtdTotal   := 0
	nRecnoQry   := 0
	oInfoRPT    := Nil

	If !Empty( aFilial )

		cAliasQry := GetNextAlias()

		cQuery := "SELECT COUNT(*) QUANTIDADE "
		cQuery += "FROM ( "
		cQuery += "			SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO "
		cQuery += "			FROM " + RetSqlName( "C91" ) + " C91 "
		cQuery += "			WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

		If Len( AllTrim( cPeriodo ) ) == 4
			cQuery += "			  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
		Else
			cQuery += "			  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "			  AND EXISTS (	SELECT C9M.R_E_C_N_O_ "
		cQuery += "							FROM " + RetSqlName( "C9M" ) + " C9M "
		cQuery += "							WHERE C9M.C9M_FILIAL = C91.C91_FILIAL "
		cQuery += "							  AND C9M.C9M_ID = C91.C91_ID "
		cQuery += "							  AND C9M.C9M_VERSAO = C91.C91_VERSAO "
		cQuery += "							  AND C9M.D_E_L_E_T_ = '' ) "

		If !Empty(cParamCPF)

			cQuery += "		      AND (EXISTS ( SELECT T3A.R_E_C_N_O_ 
			cQuery += "			  				FROM " + RetSqlName("T3A") + " T3A "
			cQuery += "			  				WHERE T3A.T3A_FILIAL = C91.C91_FILIAL "
			cQuery += "			  				  AND T3A.T3A_ID = C91.C91_TRABAL "
			cQuery += "			  	              AND T3A.T3A_CPF = '" + AllTrim(cParamCPF) + "' "
			cQuery += "			  	              AND T3A.D_E_L_E_T_ = ' ') "
			cQuery += "			  OR EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
			cQuery += "							WHERE C9V.C9V_FILIAL = C91.C91_FILIAL "
			cQuery += "							  AND C9V.C9V_ID = C91.C91_TRABAL "
			cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
			cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' )) "

		EndIf

		cQuery += "			  AND C91.C91_NOMEVE = 'S1200' "
		cQuery += "			  AND C91.C91_ATIVO = '1' "
		cQuery += "			  AND C91.C91_EVENTO <> 'E' "
		cQuery += "			  AND C91.D_E_L_E_T_ = '' "

		cQuery += "			UNION ALL "

		cQuery += "			SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO "
		cQuery += "			FROM " + RetSqlName( "C91" ) + " C91 "
		cQuery += "			WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

		If Len( AllTrim( cPeriodo ) ) == 4
			cQuery += "			  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
		Else
			cQuery += "			  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
		EndIf

		cQuery += "			  AND EXISTS (	SELECT C9R.R_E_C_N_O_ "
		cQuery += "							FROM " + RetSqlName( "C9R" ) + " C9R "
		cQuery += "							WHERE C9R.C9R_FILIAL = C91.C91_FILIAL "
		cQuery += "							  AND C9R.C9R_ID = C91.C91_ID "
		cQuery += "							  AND C9R.C9R_VERSAO = C91.C91_VERSAO "
		cQuery += "							  AND C9R.D_E_L_E_T_ = '' ) "

		If !Empty(cParamCPF)

			cQuery += "		      AND (EXISTS ( SELECT T3A.R_E_C_N_O_ 
			cQuery += "			  				FROM " + RetSqlName("T3A") + " T3A "
			cQuery += "			  				WHERE T3A.T3A_FILIAL = C91.C91_FILIAL "
			cQuery += "			  				  AND T3A.T3A_ID = C91.C91_TRABAL "
			cQuery += "			  	              AND T3A.T3A_CPF = '" + AllTrim(cParamCPF) + "' "
			cQuery += "			  	              AND T3A.D_E_L_E_T_ = ' ') "
			cQuery += "			  OR EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
			cQuery += "							WHERE C9V.C9V_FILIAL = C91.C91_FILIAL "
			cQuery += "							  AND C9V.C9V_ID = C91.C91_TRABAL "
			cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
			cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' )) "

		EndIf

		cQuery += "			  AND C91.C91_NOMEVE = 'S1200' "
		cQuery += "			  AND C91.C91_ATIVO = '1' "
		cQuery += "			  AND C91.C91_EVENTO <> 'E' "
		cQuery += "			  AND C91.D_E_L_E_T_ = '' "
		cQuery += " ) FOLHA "

		cQuery := ChangeQuery( cQuery )

		TCQuery cQuery New Alias (cAliasQry)

		( cAliasQry )->( DBGoTop() )

		If ( cAliasQry )->( !Eof() )
			nQtdTotal := ( cAliasQry )->QUANTIDADE
		EndIf

		( cAliasQry )->( DBCloseArea() )

		If nQtdTotal > 0

			C9V->(DbSetOrder(2))
			CUP->(DbSetOrder(4))
			C87->(DbSetOrder(1))
			T3A->(DbSetOrder(3))
			C92->(DbSetOrder(5))
			C99->(DbSetOrder(4))

			cFilBkp := cFilAnt

			For nI := 1 to Len( aFilial )

				cFilAnt := aFilial[nI]

				cAliasQry := GetNextAlias()

				cQuery := " SELECT DISTINCT C91.R_E_C_N_O_ C91_RECONHECIMENTO, C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO, C91.C91_INDAPU, C91.C91_PERAPU, C91.C91_TRABAL, C91.C91_CPF, C91.C91_NOME, C91.C91_MV, C91.C91_PROTUL, C91.C91_ORIEVE "
				cQuery += "     , C9K.C9K_ESTABE ESTABE, C9K.C9K_LOTACA LOTACA, C9K.C9K_TPINSC TPINSC, C9K.C9K_NRINSC NRINSC, C9K.C9K_CODLOT CODLOT "
				cQuery += "     , C9L.C9L_TRABAL TRABAL, C9L.C9L_DTRABA DTRABA "
				cQuery += "     , T14.T14_IDEDMD, T14.T14_CODCAT "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , C89MV.C89_CODIGO MVC89_CODIGO, C8RMV.C8R_INDTRB MVC8R_INDTRB, C8TMV.C8T_CODIGO MVC8T_CODIGO, C8UMV.C8U_CODIGO MVC8U_CODIGO, C8RMV.C8R_CINTFG MVC8R_CINTFG "

				cQuery += "     , C9M.C9M_VLRRUB VLRRUB, C9M.R_E_C_N_O_ C9M_RECONHECIMENTO "

				cQuery += " FROM " + RetSqlName( "C91" ) + " C91 "

				cQuery += " INNER JOIN " + RetSqlName( "T14" ) + " T14 "
				cQuery += "  ON T14.T14_FILIAL = C91.C91_FILIAL "
				cQuery += "  AND T14.T14_ID = C91.C91_ID "
				cQuery += "  AND T14.T14_VERSAO = C91.C91_VERSAO "
				cQuery += "  AND T14.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9K" ) + " C9K "
				cQuery += "  ON C9K.C9K_FILIAL = T14.T14_FILIAL "
				cQuery += "  AND C9K.C9K_ID = T14.T14_ID "
				cQuery += "  AND C9K.C9K_VERSAO = T14.T14_VERSAO "
				cQuery += "  AND C9K.C9K_RECIBO = T14.T14_IDEDMD "
				cQuery += "  AND C9K.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9L" ) + " C9L "
				cQuery += "  ON C9L.C9L_FILIAL = C9K.C9K_FILIAL "
				cQuery += "  AND C9L.C9L_ID = C9K.C9K_ID "
				cQuery += "  AND C9L.C9L_VERSAO = C9K.C9K_VERSAO "
				cQuery += "  AND C9L.C9L_RECIBO = C9K.C9K_RECIBO "
				cQuery += "  AND C9L.C9L_ESTABE = C9K.C9K_ESTABE "
				cQuery += "  AND C9L.C9L_LOTACA = C9K.C9K_LOTACA "
				cQuery += "  AND C9L.C9L_TPINSC = C9K.C9K_TPINSC "
				cQuery += "  AND C9L.C9L_NRINSC = C9K.C9K_NRINSC "
				cQuery += "  AND C9L.C9L_CODLOT = C9K.C9K_CODLOT "
				cQuery += "  AND C9L.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9M" ) + " C9M "
				cQuery += "  ON C9M.C9M_FILIAL = C9L.C9L_FILIAL "
				cQuery += "  AND C9M.C9M_ID = C9L.C9L_ID "
				cQuery += "  AND C9M.C9M_VERSAO = C9L.C9L_VERSAO "
				cQuery += "  AND C9M.C9M_RECIBO = C9L.C9L_RECIBO "
				cQuery += "  AND C9M.C9M_ESTABE = C9L.C9L_ESTABE "
				cQuery += "  AND C9M.C9M_LOTACA = C9L.C9L_LOTACA "
				cQuery += "  AND C9M.C9M_TRABAL = C9L.C9L_TRABAL "
				cQuery += "  AND C9M.C9M_TPINSC = C9L.C9L_TPINSC "
				cQuery += "  AND C9M.C9M_NRINSC = C9L.C9L_NRINSC "
				cQuery += "  AND C9M.C9M_CODLOT = C9L.C9L_CODLOT "
				cQuery += "  AND C9M.C9M_DTRABA = C9L.C9L_DTRABA "
				cQuery += "  AND C9M.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "
				cQuery += " ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
				cQuery += " AND C8R.C8R_ID = C9M.C9M_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
				cQuery += " ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
				cQuery += " ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8U "
				cQuery += " ON C8U.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTIR "
				cQuery += " AND C8U.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8RMV "
				cQuery += " ON C8RMV.C8R_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSelMV + " FILIAIS ) "
				cQuery += " AND C8RMV.C8R_CODRUB = C9M.C9M_RUBRIC "
				cQuery += " AND C8RMV.C8R_IDTBRU = C9M.C9M_IDTABR "

				If Len( AllTrim( cPeriodo ) ) == 4
					cQuery += " AND ( ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '12" + cPeriodo + "' ) ) "
				Else
					cQuery += " AND ( ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '" + cPeriodo + "' ) ) "
				EndIf

				cQuery += " AND C8RMV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89MV "
				cQuery += " ON C89MV.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89MV.C89_ID = C8RMV.C8R_NATRUB "
				cQuery += " AND C89MV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8TMV "
				cQuery += " ON C8TMV.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8TMV.C8T_ID = C8RMV.C8R_CINTPS "
				cQuery += " AND C8TMV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8UMV "
				cQuery += " ON C8UMV.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8UMV.C8U_ID = C8RMV.C8R_CINTIR "
				cQuery += " AND C8UMV.D_E_L_E_T_ = '' "

				cQuery += " WHERE C91.C91_FILIAL = '" + xFilial( "C91" ) + "' "

				If !Empty(cParamCPF)

					cQuery += "		      AND (EXISTS ( SELECT T3A.R_E_C_N_O_ 
					cQuery += "			  				FROM " + RetSqlName("T3A") + " T3A "
					cQuery += "			  				WHERE T3A.T3A_FILIAL = C91.C91_FILIAL "
					cQuery += "			  				  AND T3A.T3A_ID = C91.C91_TRABAL "
					cQuery += "			  	              AND T3A.T3A_CPF = '" + AllTrim(cParamCPF) + "' "
					cQuery += "			  	              AND T3A.D_E_L_E_T_ = ' ') "
					cQuery += "			  OR EXISTS (	SELECT C9V.R_E_C_N_O_ "
					cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
					cQuery += "							WHERE C9V.C9V_FILIAL = C91.C91_FILIAL "
					cQuery += "							  AND C9V.C9V_ID = C91.C91_TRABAL "
					cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
					cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' )) "

				EndIf

				If Len( AllTrim( cPeriodo ) ) == 4
					cQuery += "  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
				Else
					cQuery += "  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				EndIf

				cQuery += "  AND C91.C91_NOMEVE = 'S1200' "
				cQuery += "  AND C91.C91_ATIVO = '1' "
				cQuery += "  AND C91.C91_EVENTO <> 'E' "
				cQuery += "  AND C91.D_E_L_E_T_ = '' "

				cQuery += "UNION ALL "

				cQuery += " SELECT DISTINCT C91.R_E_C_N_O_, C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO, C91.C91_INDAPU, C91.C91_PERAPU, C91.C91_TRABAL, C91.C91_CPF, C91.C91_NOME, C91.C91_MV, C91.C91_PROTUL, C91.C91_ORIEVE "
				cQuery += "     , C9P.C9P_ESTABE, C9P.C9P_LOTACA, C9P.C9P_TPINSC, C9P.C9P_NRINSC, C9P.C9P_CODLOT "
				cQuery += "     , C9Q.C9Q_TRABAL, C9Q.C9Q_DTRABA "
				cQuery += "     , T14.T14_IDEDMD, T14.T14_CODCAT "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , C89MV.C89_CODIGO, C8RMV.C8R_INDTRB, C8TMV.C8T_CODIGO, C8UMV.C8U_CODIGO, C8RMV.C8R_CINTFG "
				cQuery += "     , C9R.C9R_VLRRUB, C9R.R_E_C_N_O_ C9R_RECONHECIMENTO "

				cQuery += " FROM " + RetSqlName( "C91" ) + " C91 "

				cQuery += " INNER JOIN " + RetSqlName( "T14" ) + " T14 "
				cQuery += "  ON T14.T14_FILIAL = C91.C91_FILIAL "
				cQuery += "  AND T14.T14_ID = C91.C91_ID "
				cQuery += "  AND T14.T14_VERSAO = C91.C91_VERSAO "
				cQuery += "  AND T14.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9N" ) + " C9N "
				cQuery += "  ON C9N.C9N_FILIAL = T14.T14_FILIAL "
				cQuery += "  AND C9N.C9N_ID = T14.T14_ID "
				cQuery += "  AND C9N.C9N_VERSAO = T14.T14_VERSAO "
				cQuery += "  AND C9N.C9N_RECIBO = T14.T14_IDEDMD "
				cQuery += "  AND C9N.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9O" ) + " C9O "
				cQuery += "  ON C9O.C9O_FILIAL = C9N.C9N_FILIAL "
				cQuery += "  AND C9O.C9O_ID = C9N.C9N_ID "
				cQuery += "  AND C9O.C9O_VERSAO = C9N.C9N_VERSAO "
				cQuery += "  AND C9O.C9O_RECIBO = C9N.C9N_RECIBO "
				cQuery += "  AND C9O.C9O_DTACOR = C9N.C9N_DTACOR "
				cQuery += "  AND C9O.C9O_TPACOR = C9N.C9N_TPACOR "
				cQuery += "  AND C9O.C9O_COMPAC = C9N.C9N_COMPAC "
				cQuery += "  AND C9O.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9P" ) + " C9P "
				cQuery += "  ON C9P.C9P_FILIAL = C9O.C9O_FILIAL "
				cQuery += "  AND C9P.C9P_ID = C9O.C9O_ID "
				cQuery += "  AND C9P.C9P_VERSAO = C9O.C9O_VERSAO "
				cQuery += "  AND C9P.C9P_RECIBO = C9O.C9O_RECIBO "
				cQuery += "  AND C9P.C9P_DTACOR = C9O.C9O_DTACOR "
				cQuery += "  AND C9P.C9P_TPACOR = C9O.C9O_TPACOR "
				cQuery += "  AND C9P.C9P_COMPAC = C9O.C9O_COMPAC "
				cQuery += "  AND C9P.C9P_PERREF = C9O.C9O_PERREF "
				cQuery += "  AND C9P.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9Q" ) + " C9Q "
				cQuery += "  ON C9Q.C9Q_FILIAL = C9P.C9P_FILIAL "
				cQuery += "  AND C9Q.C9Q_ID = C9P.C9P_ID "
				cQuery += "  AND C9Q.C9Q_VERSAO = C9P.C9P_VERSAO "
				cQuery += "  AND C9Q.C9Q_RECIBO = C9P.C9P_RECIBO "
				cQuery += "  AND C9Q.C9Q_DTACOR = C9P.C9P_DTACOR "
				cQuery += "  AND C9Q.C9Q_TPACOR = C9P.C9P_TPACOR "
				cQuery += "  AND C9Q.C9Q_COMPAC = C9P.C9P_COMPAC "
				cQuery += "  AND C9Q.C9Q_PERREF = C9P.C9P_PERREF "
				cQuery += "  AND C9Q.C9Q_ESTABE = C9P.C9P_ESTABE "
				cQuery += "  AND C9Q.C9Q_LOTACA = C9P.C9P_LOTACA "
				cQuery += "  AND C9Q.D_E_L_E_T_ = '' "

				cQuery += " INNER JOIN " + RetSqlName( "C9R" ) + " C9R "
				cQuery += "  ON C9R.C9R_FILIAL = C9Q.C9Q_FILIAL "
				cQuery += "  AND C9R.C9R_ID = C9Q.C9Q_ID "
				cQuery += "  AND C9R.C9R_VERSAO = C9Q.C9Q_VERSAO "
				cQuery += "  AND C9R.C9R_RECIBO = C9Q.C9Q_RECIBO "
				cQuery += "  AND C9R.C9R_DTACOR = C9Q.C9Q_DTACOR "
				cQuery += "  AND C9R.C9R_TPACOR = C9Q.C9Q_TPACOR "
				cQuery += "  AND C9R.C9R_COMPAC = C9Q.C9Q_COMPAC "
				cQuery += "  AND C9R.C9R_PERREF = C9Q.C9Q_PERREF "
				cQuery += "  AND C9R.C9R_ESTABE = C9Q.C9Q_ESTABE "
				cQuery += "  AND C9R.C9R_LOTACA = C9Q.C9Q_LOTACA "
				cQuery += "  AND C9R.C9R_TRABAL = C9Q.C9Q_TRABAL "
				cQuery += "  AND C9R.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8R "
				cQuery += " ON C8R.C8R_FILIAL = '" + xFilial( "C8R" ) + "' "
				cQuery += " AND C8R.C8R_ID = C9R.C9R_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89 "
				cQuery += " ON C89.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8T "
				cQuery += " ON C8T.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8U "
				cQuery += " ON C8U.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTIR "
				cQuery += " AND C8U.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8R" ) + " C8RMV "
				cQuery += " ON C8RMV.C8R_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSelMV + " FILIAIS ) "
				cQuery += " AND C8RMV.C8R_CODRUB = C9R.C9R_RUBRIC "
				cQuery += " AND C8RMV.C8R_IDTBRU = C9R.C9R_IDTABR "

				If Len( AllTrim( cPeriodo ) ) == 4
					cQuery += " AND ( ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '12" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '12" + cPeriodo + "' ) ) "
				Else
					cQuery += " AND ( ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN = '' ) OR ( C8RMV.C8R_DTINI <= '" + cPeriodo + "' AND C8RMV.C8R_DTFIN >= '" + cPeriodo + "' ) ) "
				EndIf

				cQuery += " AND C8RMV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C89" ) + " C89MV "
				cQuery += " ON C89MV.C89_FILIAL = '" + xFilial( "C89" ) + "' "
				cQuery += " AND C89MV.C89_ID = C8RMV.C8R_NATRUB "
				cQuery += " AND C89MV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8T" ) + " C8TMV "
				cQuery += " ON C8TMV.C8T_FILIAL = '" + xFilial( "C8T" ) + "' "
				cQuery += " AND C8TMV.C8T_ID = C8RMV.C8R_CINTPS "
				cQuery += " AND C8TMV.D_E_L_E_T_ = '' "

				cQuery += " LEFT JOIN " + RetSqlName( "C8U" ) + " C8UMV "
				cQuery += " ON C8UMV.C8U_FILIAL = '" + xFilial( "C8U" ) + "' "
				cQuery += " AND C8UMV.C8U_ID = C8RMV.C8R_CINTIR "
				cQuery += " AND C8UMV.D_E_L_E_T_ = '' "

				cQuery += " WHERE C91.C91_FILIAL = '" + xFilial( "C91" ) + "' "

				If !Empty(cParamCPF)

					cQuery += "		      AND (EXISTS ( SELECT T3A.R_E_C_N_O_ 
					cQuery += "			  				FROM " + RetSqlName("T3A") + " T3A "
					cQuery += "			  				WHERE T3A.T3A_FILIAL = C91.C91_FILIAL "
					cQuery += "			  				  AND T3A.T3A_ID = C91.C91_TRABAL "
					cQuery += "			  	              AND T3A.T3A_CPF = '" + AllTrim(cParamCPF) + "' "
					cQuery += "			  	              AND T3A.D_E_L_E_T_ = ' ') "
					cQuery += "			  OR EXISTS (	SELECT C9V.R_E_C_N_O_ "
					cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
					cQuery += "							WHERE C9V.C9V_FILIAL = C91.C91_FILIAL "
					cQuery += "							  AND C9V.C9V_ID = C91.C91_TRABAL "
					cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
					cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' )) "

				EndIf

				If Len( AllTrim( cPeriodo ) ) == 4
					cQuery += "  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
				Else
					cQuery += "  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
				EndIf

				cQuery += "  AND C91.C91_NOMEVE = 'S1200' "
				cQuery += "  AND C91.C91_ATIVO = '1' "
				cQuery += "  AND C91.C91_EVENTO <> 'E' "
				cQuery += "  AND C91.D_E_L_E_T_ = '' "

				cQuery += " ORDER BY C91_FILIAL, C91_ID, C91_VERSAO, C91_INDAPU, C91_PERAPU, ESTABE, LOTACA, TPINSC, NRINSC, CODLOT, TRABAL, DTRABA "

				cQuery := ChangeQuery( cQuery )

				TCQuery cQuery New Alias (cAliasQry)

				( cAliasQry )->( DBGoTop() )

				While !(cAliasQry)->(EOF())	

					cFilQry		:= (cAliasQry)->C91_FILIAL
					cID			:= (cAliasQry)->C91_ID
					cVersao		:= (cAliasQry)->C91_VERSAO
					cIDEstab	:= (cAliasQry)->ESTABE
					cMVTpEstab	:= (cAliasQry)->TPINSC
					cMVEstab	:= (cAliasQry)->NRINSC
					cIDLotac	:= (cAliasQry)->LOTACA
					cMVLotac	:= (cAliasQry)->CODLOT
					cIDTrabal	:= (cAliasQry)->TRABAL
					cMVTrabal	:= (cAliasQry)->DTRABA
					cIdeDmd		:= (cAliasQry)->T14_IDEDMD
					cIDCateg	:= (cAliasQry)->T14_CODCAT
					cIndApu		:= (cAliasQry)->C91_INDAPU
					cPerApu		:= (cAliasQry)->C91_PERAPU
					cRecibo		:= (cAliasQry)->C91_PROTUL
					lMultVinc	:= (cAliasQry)->C91_MV == "1"
					nRecnoQry	:= (cAliasQry)->C91_RECONHECIMENTO

					If lMultVinc

						cTipoEstab	:=	( cAliasQry )->TPINSC
						cEstab		:=	( cAliasQry )->NRINSC
						cLotacao	:=	( cAliasQry )->CODLOT
						cCPF		:=	( cAliasQry )->C91_CPF
						cNome		:=	( cAliasQry )->C91_NOME
						cMatric		:=	( cAliasQry )->DTRABA

						C87->( MsSeek( xFilial( "C87" ) + ( cAliasQry )->T14_CODCAT ) )
						cCodCat		:=	C87->C87_CODIGO

					Else

						cTrabal := IIf(Empty(cIDTrabal), (cAliasQry)->C91_TRABAL, cIDTrabal)

						If (cAliasQry)->C91_ORIEVE == "S2190"

							If T3A->(MsSeek(xFilial("T3A") + cTrabal + "1"))

								cCPF		:= T3A->T3A_CPF
								cMatric		:= T3A->T3A_MATRIC
								cNome		:= "TRABALHADOR PRELIMINAR"
								cC87Id		:= IIf(Empty(cIDCateg), T3A->T3A_CODCAT, cIDCateg)

							EndIf

						ElseIf C9V->(MsSeek(xFilial("C9V") + cTrabal + "1"))

							cCPF 	:= C9V->C9V_CPF
							cNome 	:= TAFGetNT1U(cCPF,, aFilial[nI])
							
							If Empty(cNome)
								cNome := C9V->C9V_NOME
							EndIf

							If (cAliasQry)->C91_ORIEVE == "S2200"

								cMatric		:= C9V->C9V_MATRIC
								cC87Id		:= IIf(Empty(cIDCateg), GetCodCat(C9V->C9V_NOMEVE, aFilial[nI], C9V->C9V_ID, cPerApu), cIDCateg)
								cC87Id		:= IIf(Empty(cC87Id), Posicione("CUP", 4, xFilial("CUP") + C9V->(C9V_ID + C9V_VERSAO + C9V_NOMEVE + C9V_MATRIC), "CUP_CODCAT"), cC87Id)

							ElseIf (cAliasQry)->C91_ORIEVE == "S2300"

								cMatric		:= C9V->C9V_MATTSV
								cC87Id		:= IIf(Empty(cIDCateg), GetCodCat(C9V->C9V_NOMEVE, aFilial[nI], C9V->C9V_ID, cPerApu), cIDCateg)
								cC87Id		:= IIf(Empty(cC87Id), C9V->C9V_CATCI, cC87Id)

							ElseIf Empty((cAliasQry)->C91_ORIEVE)

								cMatric		:= C9V->C9V_MATRIC

								If Empty(cMatric)

									cMatric		:= C9V->C9V_MATTSV

								EndIf

							EndIf

						EndIf

						If C92->(MsSeek(xFilial("C92") + (cAliasQry)->ESTABE + "1"))
							cTipoEstab	:=	C92->C92_TPINSC
							cEstab		:=	C92->C92_NRINSC
						EndIf

						If C99->(MsSeek(xFilial("C99") + (cAliasQry)->LOTACA + "1"))
							cLotacao :=	C99->C99_CODIGO
						EndIf

						If C87->(MsSeek(xFilial("C87") + cC87Id))
							cCodCat	:= C87->C87_CODIGO
						EndIf

					EndIf

					While ( cAliasQry )->( C91_FILIAL + C91_ID + C91_VERSAO + ESTABE + TPINSC + NRINSC + LOTACA + CODLOT + TRABAL + DTRABA + T14_CODCAT ) == cFilQry + cID + cVersao + cIDEstab + cMVTpEstab + cMVEstab + cIDLotac + cMVLotac + cIDTrabal + cMVTrabal + cIDCateg

						cNatureza	:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC89_CODIGO ), AllTrim( ( cAliasQry )->C89_CODIGO ) )
						cTipo		:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC8R_INDTRB ), AllTrim( ( cAliasQry )->C8R_INDTRB ) )
						cIncidCP	:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC8T_CODIGO ), AllTrim( ( cAliasQry )->C8T_CODIGO ) )
						cIncidIRRF	:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC8U_CODIGO ), AllTrim( ( cAliasQry )->C8U_CODIGO ) )
						cIncidFGTS	:=	IIf( lMultVinc, AllTrim( ( cAliasQry )->MVC8R_CINTFG ), AllTrim( ( cAliasQry )->C8R_CINTFG ) )

						tafDefAAnalitco(@aAnalitico)
						nPosValores := Len(aAnalitico)

						aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
						aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
						aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(cTipoEstab)
						aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(cEstab)
						aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(cLotacao)
						aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(cNatureza)
						aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(cTipo)
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(cIncidCP)
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(cIncidIRRF)
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(cIncidFGTS)
						aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
						aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
						aAnalitico[nPosValores][ANALITICO_VALOR]				:= (cAliasQry)->VLRRUB
						aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(cIdeDmd)

						( cAliasQry )->( DBSkip() )

					EndDo

					If ( cAliasQry )->( C91_FILIAL + C91_ID + C91_VERSAO ) <> cFilQry + cID + cVersao

						InfoRPTObj(cIndApu, cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)

						oReport:UpSert("S-1200", "2", cFilQry, oInfoRPT)

						If !lProtheus

							InfoRPTObj(cIndApu, cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)
							oReport:UpSert("S-1200", "1", cFilQry, oInfoRPT)

						Else

							InsOrigC91( cFilQry, nRecnoQry, lMultVinc, aFilMV )

						EndIf

						Insert5003("S-1200", cFilQry, cPeriodo, cCPF, cRecibo, cFilMatriz)
						Insert5001("S-1200", cFilQry, cIndApu, cPeriodo, cCPF, cNome, cRecibo, cFilMatriz)

						nQtdProc ++

						If !lCallExternal
							SetIncPerc( oRunCharge, "S-1200", nQtdTotal, nQtdProc )
						EndIf

						aAnalitico := {}

					EndIf

					cCodCat    := ""
					cCPF       := ""
					cEstab     := ""
					cFilQry    := ""
					cID        := ""
					cIDCateg   := ""
					cIDEstab   := ""
					cIDLotac   := ""
					cIDTrabal  := ""
					cIncidCP   := ""
					cIncidFGTS := ""
					cIncidIRRF := ""
					cIndApu    := ""
					cLotacao   := ""
					cMatric    := ""
					cMVEstab   := ""
					cMVLotac   := ""
					cMVTpEstab := ""
					cMVTrabal  := ""
					cNatureza  := ""
					cNome      := ""
					cPerApu    := ""
					cRecibo    := ""
					cTipo      := ""
					cTipoEstab := ""
					cTrabal    := ""
					cVersao    := ""
					lMultVinc  := .F.
					nRecnoQry  := 0

				EndDo

				( cAliasQry )->( DBCloseArea() )

			Next nI

			cFilAnt := cFilBkp

		Else

			nQtdProc ++

			If !lCallExternal
				SetIncPerc( oRunCharge, "S-1200", nQtdTotal, nQtdProc )
			EndIf

		EndIf

	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigC91
@type			function
@description	Função responsável por coletar as informações do Evento S-1200 no XML de entrada.
@author			Felipe C. Seolin
@since			10/06/2019
@version		1.0
@param			cFilEvt		-	Filial do registro do evento S-1200 no TAF
@param			nRecno		-	Recno do registro do evento S-1200 no TAF
@param			lMultVinc	-	Indica se o evento S-1200 é Múltiplo Vínculo
@param			aFilMV		-	Array de filiais a ser consideradas na cláusula IN do SQL para Múltiplos Vínculos
/*/
//---------------------------------------------------------------------
Static Function InsOrigC91( cFilEvt as Character , nRecno as Numeric, lMultVinc as Logical, aFilMV as Array )

	Local aAnalitico  as Array
	Local aAreaC1E    as Array
	Local aAreaC8R    as Array
	Local aAreaC9V    as Array
	Local aRubrica    as Array
	Local cAliasQry   as Character
	Local cC9KPath    as Character
	Local cC9LPath    as Character
	Local cC9MPath    as Character
	Local cC9NPath    as Character
	Local cC9OPath    as Character
	Local cC9PPath    as Character
	Local cC9QPath    as Character
	Local cC9RPath    as Character
	Local cNome       as Character
	Local cPerApu     as Character
	Local cQuery      as Character
	Local cT14Path    as Character
	Local cXml        as Character
	Local nC9K        as Numeric
	Local nC9L        as Numeric
	Local nC9M        as Numeric
	Local nC9N        as Numeric
	Local nC9O        as Numeric
	Local nC9P        as Numeric
	Local nC9Q        as Numeric
	Local nC9R        as Numeric
	Local nPosValores as Numeric
	Local nT14        as Numeric
	Local nTamCod     as Numeric
	Local nTipPer     as Numeric
	Local oInfoRPT    as Object
	Local oXml        as Object
	 	  
	aAnalitico  := {}
	aAreaC1E    := C1E->( GetArea() )
	aAreaC8R    := C8R->( GetArea() )
	aAreaC9V    := C9V->( GetArea() )
	aRubrica    := {}
	cAliasQry   := GetNextAlias()
	cC9KPath    := ""
	cC9LPath    := ""
	cC9MPath    := ""
	cC9NPath    := ""
	cC9OPath    := ""
	cC9PPath    := ""
	cC9QPath    := ""
	cC9RPath    := ""
	cNome       := ""
	cPerApu     := ""
	cQuery      := ""
	cT14Path    := ""
	cXml        := ""
	nC9K        := 0
	nC9L        := 0
	nC9M        := 0
	nC9N        := 0
	nC9O        := 0
	nC9P        := 0
	nC9Q        := 0
	nC9R        := 0
	nPosValores := 0
	nT14        := 0
	nTamCod     := TamSX3( "C8R_CODRUB" )[1]
	nTipPer     := 1
	oInfoRPT    := Nil
	oXml        := Nil

	C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C1E->( MsSeek( xFilial( "C1E" ) + cFilEvt + "1" ) )

	cQuery := " SELECT TAFST2.R_E_C_N_O_ TAFST2_RECONHECIMENTO "
	cQuery += " FROM TAFXERP TAFXERP "
	cQuery += " INNER JOIN TAFST2 TAFST2 "
	cQuery += "  ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cQuery += "  AND TAFST2.TAFFIL = '" + C1E->C1E_CODFIL + "' "
	cQuery += "  AND TAFST2.D_E_L_E_T_ = '' "
	cQuery += " WHERE TAFXERP.TAFALIAS = 'C91' "
	cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
	cQuery += "  AND TAFXERP.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY TAFXERP.R_E_C_N_O_ DESC "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )

		C8R->( DBSetOrder( 3 ) ) //C8R_FILIAL, C8R_CODRUB, C8R_ATIVO, R_E_C_N_O_, D_E_L_E_T_
		C89->( DBSetOrder( 1 ) ) //C89_FILIAL, C89_ID, R_E_C_N_O_, D_E_L_E_T_
		C8T->( DBSetOrder( 1 ) ) //C8T_FILIAL, C8T_ID, R_E_C_N_O_, D_E_L_E_T_

		( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

		cXml := ( cST2Alias )->TAFMSG

		//Tiro os espaços em branco no início e final do XML e armazeno na variável
		cXml := EncodeUTF8( AllTrim( cXml ) )

		//Instancia objeto em oXml
		oXml := TXmlManager():New()

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"

			cXml := StrTran( cXml, Chr( 13 ), "" )
			cXml := StrTran( cXml, Chr( 10 ), "" )

			//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
			If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
				cXml += ">"
			EndIf

		EndIf

		If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
			oXml:bDecodeUTF8 := .T.
		EndIf

		cPerApu := StrTran( AllTrim( oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideEvento/perApur" ) ), "-", "" )

		If oXml:xPathHasNode( "/eSocial/evtRemun/ideTrabalhador/infoComplem" )

			cNome := oXml:xPathGetNodeValue( "/eSocial/evtRemun/ideTrabalhador/infoComplem/nmTrab" )

		Else

			cCPF	:= AllTrim(oXml:xPathGetNodeValue("/eSocial/evtRemun/ideTrabalhador/cpfTrab"))
			cNome 	:= TAFGetNT1U(cCPF,, cFilEvt)

			If Empty(cNome)

				C9V->(DbSetOrder(3))

				If C9V->(MsSeek(xFilial("C9V", cFilEvt) + cCPF + "1"))
					cNome := AllTrim(C9V->C9V_NOME)
				Else
					cNome := "TRABALHADOR PRELIMINAR"
				EndIf

			EndIf

		EndIf

		//T14 - Informações do Recibo de Pagamento
		nT14 := 1
		cT14Path := "/eSocial/evtRemun/dmDev[" + cValToChar( nT14 ) + "]"

		While oXml:xPathHasNode( cT14Path )

			//Informações do Período de Apuração
			//C9K - Informações do Estabelecimento/Lotação
			nC9K := 1
			cC9KPath := cT14Path + "/infoPerApur/ideEstabLot[" + cValToChar( nC9K ) + "]"

			While oXml:xPathHasNode( cC9KPath )

				//C9L - Informações da Remuneração do Trabalhador
				nC9L := 1
				cC9LPath := cC9KPath + "/remunPerApur[" + cValToChar( nC9L ) + "]"

				While oXml:xPathHasNode( cC9LPath )

					//C9M - Informações das Rubricas
					nC9M := 1
					cC9MPath := cC9LPath + "/itensRemun[" + cValToChar( nC9M ) + "]"

					While oXml:xPathHasNode( cC9MPath )
					
						aRubrica := oReport:GetRubrica( Padr(oXml:xPathGetNodeValue( cC9MPath + "/codRubr" ),nTamCod), TAFIDTabRub( oXml:xPathGetNodeValue( cC9MPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cC9MPath + "/codRubr" )), cPerApu, lMultVinc )

						tafDefAAnalitco(@aAnalitico)
						nPosValores := Len(aAnalitico)

						aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(oXml:xPathGetNodeValue(cC9LPath + "/matricula"))
						aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(oXml:xPathGetNodeValue(cT14Path + "/codCateg"))
						aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(oXml:xPathGetNodeValue(cC9KPath + "/tpInsc"))
						aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(oXml:xPathGetNodeValue(cC9KPath + "/nrInsc"))
						aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(oXml:xPathGetNodeValue(cC9KPath + "/codLotacao"))
						aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
						aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
						aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
						aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
						aAnalitico[nPosValores][ANALITICO_VALOR]				:= Val(StrTran(oXml:xPathGetNodeValue(cC9MPath + "/vrRubr"), ",", "."))
						aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(oXml:xPathGetNodeValue(cT14Path + "/ideDmDev"))

						nC9M ++
						cC9MPath := cC9LPath + "/itensRemun[" + cValToChar( nC9M ) + "]"

					EndDo

					nC9L ++
					cC9LPath := cC9KPath + "/remunPerApur[" + cValToChar( nC9L ) + "]"

				EndDo

				nC9K ++
				cC9KPath := cT14Path + "/infoPerApur/ideEstabLot[" + cValToChar( nC9K ) + "]"

			EndDo

			//Informações do Período de Apuração Anterior
			//C9N - Informações do Acordo
			nTipPer		:= 2	// 1=Período Atual; 2=Período Anterior
			nC9N 		:= 1
			cC9NPath 	:= cT14Path + "/infoPerAnt/ideADC[" + cValToChar( nC9N ) + "]"

			While oXml:xPathHasNode( cC9NPath )

				//C9O - Identificação do Período de Referência
				nC9O := 1
				cC9OPath := cC9NPath + "/idePeriodo[" + cValToChar( nC9O ) + "]"

				While oXml:xPathHasNode( cC9OPath )

					//C9P - Informações do Estabelecimento/Lotacão
					nC9P := 1
					cC9PPath := cC9OPath + "/ideEstabLot[" + cValToChar( nC9P ) + "]

					While oXml:xPathHasNode( cC9PPath )

						//C9Q - Informações da Remuneração
						nC9Q := 1
						cC9QPath := cC9PPath + "/remunPerAnt[" + cValToChar( nC9Q ) + "]"

						While oXml:xPathHasNode( cC9QPath )

							//C9R - Itens da Remuneração
							nC9R := 1
							cC9RPath := cC9QPath + "/itensRemun[" + cValToChar( nC9R ) + "]"

							While oXml:xPathHasNode( cC9RPath )

								aRubrica := oReport:GetRubrica( Padr(oXml:xPathGetNodeValue( cC9RPath + "/codRubr" ),nTamCod), TAFIDTabRub( oXml:xPathGetNodeValue( cC9RPath + "/ideTabRubr" ), "T3M", oXml:xPathGetNodeValue( cC9RPath + "/codRubr" )), cPerApu, lMultVinc, nTipPer )

								tafDefAAnalitco(@aAnalitico)
								nPosValores := Len(aAnalitico)

								aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(oXml:xPathGetNodeValue(cC9QPath + "/matricula"))
								aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(oXml:xPathGetNodeValue(cT14Path + "/codCateg"))
								aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(oXml:xPathGetNodeValue(cC9PPath + "/tpInsc"))
								aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(oXml:xPathGetNodeValue(cC9PPath + "/nrInsc"))
								aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(oXml:xPathGetNodeValue(cC9PPath + "/codLotacao"))
								aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
								aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
								aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
								aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
								aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
								aAnalitico[nPosValores][ANALITICO_VALOR]				:= Val(StrTran(oXml:xPathGetNodeValue(cC9RPath + "/vrRubr"), ",", "."))
								aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(oXml:xPathGetNodeValue(cT14Path + "/ideDmDev"))

								nC9R ++
								cC9RPath := cC9QPath + "/itensRemun[" + cValToChar( nC9R ) + "]"

							EndDo

							nC9Q ++
							cC9QPath := cC9PPath + "/remunPerAnt[" + cValToChar( nC9Q ) + "]"

						EndDo

						nC9P ++
						cC9PPath := cC9OPath + "/ideEstabLot[" + cValToChar( nC9P ) + "]"

					EndDo

					nC9O ++
					cC9OPath := cC9NPath + "/idePeriodo[" + cValToChar( nC9O ) + "]"

				EndDo

				nC9N ++
				cC9NPath := cT14Path + "/infoPerAnt/ideADC[" + cValToChar( nC9N ) + "]"

			EndDo

			nT14 ++
			cT14Path := "/eSocial/evtRemun/dmDev[" + cValToChar( nT14 ) + "]"

		EndDo

		InfoRPTObj( AllTrim(oXml:xPathGetNodeValue("/eSocial/evtRemun/ideEvento/indApuracao")),; 
					AllTrim(cPerApu),;
					AllTrim(oXml:xPathGetNodeValue("/eSocial/evtRemun/ideTrabalhador/cpfTrab")),;
					AllTrim(cNome), aAnalitico,, @oInfoRPT)

		oReport:UpSert("S-1200", "1", cFilEvt, oInfoRPT)

	EndIf

	( cAliasQry )->( DBCloseArea() )

	RestArea( aAreaC1E )
	RestArea( aAreaC9V )
	RestArea( aAreaC8R )

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS2299
@type			function
@description	Função responsável por coletar as informações do Evento S-2299 no TAF
@author			Felipe C. Seolin
@since			15/07/2019
@version		1.0
@param			oRunCharge		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPeriodo		-	Período de referência das informações
@param			aFilial			-	Filiais selecionadas para processamento
@param			cParamCPF		-	CPF selecionado como filtro de processamento
@param			lProtheus		-	Indica se a Origem dos dados parte do Protheus
@param			cFilMatriz		-	Filial Matriz
/*/
//---------------------------------------------------------------------
Static Function DataS2299( oRunCharge as Object, lCallExternal as Logical, cPeriodo as Character,; 
						   aFilial as Array, cParamCPF as Character, lProtheus as Logical, cFilMatriz as Character)

	Local aAnalitico  as Array
	Local cAliasQry   as Character
	Local cCodCat     as Character
	Local cCPF        as Character
	Local cEstab      as Character
	Local cFilBkp     as Character
	Local cFilC9V     as Character
	Local cFilCMD     as Character
	Local cFilQry     as Character
	Local cID         as Character
	Local cIDEstab    as Character
	Local cIDLotac    as Character
	Local cIDTrabal   as Character
	Local cIncidCP    as Character
	Local cIncidFGTS  as Character
	Local cIncidIRRF  as Character
	Local cLotacao    as Character
	Local cMatric     as Character
	Local cMotDes     as Character
	Local cNatureza   as Character
	Local cNome       as Character
	Local cPerApu     as Character
	Local cQuery      as Character
	Local cRecibo     as Character
	Local cTipo       as Character
	Local cTipoEstab  as Character
	Local cVersao     as Character
	Local cIDCateg    as Character
	Local cIdeDmd     as Character
	Local nI          as Numeric
	Local nPosValores as Numeric
	Local nQtdProc    as Numeric
	Local nQtdTotal   as Numeric
	Local nRecnoQry   as Numeric
	Local oInfoRPT    as Object

	Default aFilial       := {}
	Default cFilMatriz    := ""
	Default cParamCPF     := ""
	Default cPeriodo      := ""
	Default lCallExternal := .F.
	Default lProtheus     := .F.
	Default oRunCharge    := Nil

	aAnalitico  := {}
	cAliasQry   := ""
	cCodCat     := ""
	cCPF        := ""
	cEstab      := ""
	cFilBkp     := ""
	cFilC9V     := ""
	cFilCMD     := ""
	cFilQry     := ""
	cID         := ""
	cIDEstab    := ""
	cIDLotac    := ""
	cIDTrabal   := ""
	cIncidCP    := ""
	cIncidFGTS  := ""
	cIncidIRRF  := ""
	cLotacao    := ""
	cMatric     := ""
	cMotDes     := ""
	cNatureza   := ""
	cNome       := ""
	cPerApu     := ""
	cQuery      := ""
	cRecibo     := ""
	cTipo       := ""
	cTipoEstab  := ""
	cVersao     := ""
	cIDCateg    := ""
	cIdeDmd     := ""
	nI          := 0
	nPosValores := 0
	nQtdProc    := 0
	nQtdTotal   := 0
	nRecnoQry   := 0
	oInfoRPT    := Nil

	If !Empty(aFilial)

		cFilCMD		:= GetFilial("CMD", aFilial)
		cAliasQry	:= GetNextAlias()

		If !Empty(cParamCPF)
			cFilC9V := GetFilial("C9V", aFilial)
		EndIf

		cQuery := "SELECT COUNT(*) QUANTIDADE "
		cQuery += "FROM ( "
		cQuery += "			SELECT CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO "
		cQuery += "			FROM " + RetSqlName("CMD") + " CMD "
		cQuery += "			WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilCMD + " FILIAIS ) "

		If Len(cPeriodo) == 4

			cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + cPeriodo + "01" + "01" + "' "
			cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

		Else

			cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
			cQuery += "			  AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

		EndIf
		
		cQuery += "			  AND EXISTS (	SELECT T05.R_E_C_N_O_ "
		cQuery += "							FROM " + RetSqlName("T05") + " T05 "
		cQuery += "							WHERE T05.T05_FILIAL = CMD.CMD_FILIAL "
		cQuery += "							  AND T05.T05_ID = CMD.CMD_ID "
		cQuery += "							  AND T05.T05_VERSAO = CMD.CMD_VERSAO "
		cQuery += "							  AND T05.D_E_L_E_T_ = ' ' ) "

		If !Empty(cParamCPF)

			cQuery += "			  AND EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "							FROM " + RetSqlName("C9V") + " C9V "
			cQuery += "							WHERE C9V.C9V_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilC9V + " FILIAIS ) "
			cQuery += "							  AND C9V.C9V_ID = CMD.CMD_FUNC "
			cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
			cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' ) "

		EndIf

		cQuery += "			  AND CMD.CMD_ATIVO = '1' "
		cQuery += "			  AND CMD.CMD_EVENTO <> 'E' "
		cQuery += "			  AND CMD.D_E_L_E_T_ = ' ' "

		cQuery += "			UNION ALL "

		cQuery += "			SELECT CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO "
		cQuery += "			FROM " + RetSqlName("CMD") + " CMD "
		cQuery += "			WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilCMD + " FILIAIS ) "

		If Len(cPeriodo) == 4

			cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + cPeriodo + "01" + "01" + "' "
			cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

		Else

			cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
			cQuery += "			  AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

		EndIf

		cQuery += "			  AND EXISTS (	SELECT T5S.R_E_C_N_O_ "
		cQuery += "							FROM " + RetSqlName("T5S") + " T5S "
		cQuery += "							WHERE T5S.T5S_FILIAL = CMD.CMD_FILIAL "
		cQuery += "							  AND T5S.T5S_ID = CMD.CMD_ID "
		cQuery += "							  AND T5S.T5S_VERSAO = CMD.CMD_VERSAO "
		cQuery += "							  AND T5S.D_E_L_E_T_ = ' ' ) "

		If !Empty(cParamCPF)

			cQuery += "			  AND EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "							FROM " + RetSqlName( "C9V" ) + " C9V "
			cQuery += "							WHERE C9V.C9V_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilC9V + " FILIAIS ) "
			cQuery += "							  AND C9V.C9V_ID = CMD.CMD_FUNC "
			cQuery += "							  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
			cQuery += "							  AND C9V.D_E_L_E_T_ = ' ' ) "

		EndIf

		cQuery += "			  AND CMD.CMD_ATIVO = '1' "
		cQuery += "			  AND CMD.CMD_EVENTO <> 'E' "
		cQuery += "			  AND CMD.D_E_L_E_T_ = ' ' "
		cQuery += " ) DESLIGAMENTO "

		cQuery := ChangeQuery(cQuery)

		TCQuery cQuery New Alias (cAliasQry)

		(cAliasQry )->(DBGoTop())

		If !(cAliasQry)->(EOF())
			nQtdTotal := (cAliasQry)->QUANTIDADE
		EndIf

		(cAliasQry)->(DBCloseArea())

		If nQtdTotal > 0

			C9V->(DBSetOrder(2))
			CUP->(DBSetOrder(4))
			C87->(DBSetOrder(1))
			C92->(DBSetOrder(5))
			C99->(DBSetOrder(4))

			cFilBkp := cFilAnt

			For nI := 1 To Len(aFilial)

				cFilAnt		:= aFilial[nI]
				cAliasQry	:= GetNextAlias()

				cQuery := " SELECT DISTINCT CMD.R_E_C_N_O_ CMD_RECONHECIMENTO, CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO, CMD.CMD_DTDESL, CMD.CMD_FUNC, CMD.CMD_PROTUL "
				cQuery += "     , C8O.C8O_CODIGO, T3G.T3G_ESTABE ESTABE, T3G.T3G_LOTTRB LOTTRB "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , T05.T05_VLRRUB VLRRUB, T05.R_E_C_N_O_ RECONHECIMENTO, T06.T06_IDEDMD IDEDMD "

				cQuery += " FROM " + RetSqlName("CMD") + " CMD "

				cQuery += " INNER JOIN " + RetSqlName("T06") + " T06 "
				cQuery += "  ON T06.T06_FILIAL = CMD.CMD_FILIAL "
				cQuery += "  AND T06.T06_ID = CMD.CMD_ID "
				cQuery += "  AND T06.T06_VERSAO = CMD.CMD_VERSAO "
				cQuery += "  AND T06.D_E_L_E_T_ = ' ' "

				cQuery += " INNER JOIN " + RetSqlName("T3G") + " T3G "
				cQuery += "  ON T3G.T3G_FILIAL = T06.T06_FILIAL "
				cQuery += "  AND T3G.T3G_ID = T06.T06_ID "
				cQuery += "  AND T3G.T3G_VERSAO = T06.T06_VERSAO "
				cQuery += "  AND T3G.T3G_RECPAG = T06.T06_IDEDMD "
				cQuery += "  AND T3G.D_E_L_E_T_ = ' ' "

				cQuery += " INNER JOIN " + RetSqlName("T05") + " T05 "
				cQuery += "  ON T05.T05_FILIAL = T3G.T3G_FILIAL "
				cQuery += "  AND T05.T05_ID = T3G.T3G_ID "
				cQuery += "  AND T05.T05_VERSAO = T3G.T3G_VERSAO "
				cQuery += "  AND T05.T05_RECPAG = T3G.T3G_RECPAG "
				cQuery += "  AND T05.T05_ESTABE = T3G.T3G_ESTABE "
				cQuery += "  AND T05.T05_LOTTRB = T3G.T3G_LOTTRB "
				cQuery += "  AND T05.D_E_L_E_T_ = ' ' "

				If !Empty(cParamCPF)

					cQuery += " INNER JOIN " + RetSqlName("C9V") + " C9V "
					cQuery += "  ON C9V.C9V_FILIAL = '" + xFilial("C9V") + "' "
					cQuery += "  AND C9V.C9V_ID = CMD.CMD_FUNC "
					cQuery += "  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
					cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "

				EndIf

				cQuery += " LEFT JOIN " + RetSqlName("C8R") + " C8R "
				cQuery += " ON C8R.C8R_FILIAL = '" + xFilial("C8R") + "' "
				cQuery += " AND C8R.C8R_ID = T05.T05_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C89") + " C89 "
				cQuery += " ON C89.C89_FILIAL = '" + xFilial("C89") + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C8T") + " C8T "
				cQuery += " ON C8T.C8T_FILIAL = '" + xFilial("C8T") + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C8U") + " C8U "
				cQuery += " ON C8U.C8U_FILIAL = '" + xFilial("C8U") + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTIR "
				cQuery += " AND C8U.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C8O") + " C8O "
				cQuery += "  ON C8O.C8O_FILIAL = '" + xFilial("C8O") + "' "
				cQuery += " AND C8O.C8O_ID = CMD.CMD_MOTDES "
				cQuery += " AND C8O.D_E_L_E_T_ = ' ' "

				cQuery += " WHERE CMD.CMD_FILIAL = '" + xFilial("CMD") + "' "

				If Len(cPeriodo) == 4

					cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + cPeriodo + "01" + "01" + "' "
					cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

				Else

					cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
					cQuery += "			  AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

				EndIf

				cQuery += "  AND CMD.CMD_ATIVO = '1' "
				cQuery += "  AND CMD.CMD_EVENTO <> 'E' "
				cQuery += "  AND CMD.D_E_L_E_T_ = ' ' "

				cQuery += " UNION ALL "

				cQuery += " SELECT DISTINCT CMD.R_E_C_N_O_ CMD_RECONHECIMENTO, CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO, CMD.CMD_DTDESL, CMD.CMD_FUNC, CMD.CMD_PROTUL "
				cQuery += "     , C8O.C8O_CODIGO, T5Q.T5Q_ESTABE ESTABE, T5Q.T5Q_LOTTRB LOTTRB"
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , T5S.T5S_VLRRUB, T5S.R_E_C_N_O_ RECONHECIMENTO, T06.T06_IDEDMD IDEDMD "

				cQuery += " FROM " + RetSqlName("CMD") + " CMD "

				cQuery += " INNER JOIN " + RetSqlName("T06") + " T06 "
				cQuery += "  ON T06.T06_FILIAL = CMD.CMD_FILIAL "
				cQuery += "  AND T06.T06_ID = CMD.CMD_ID "
				cQuery += "  AND T06.T06_VERSAO = CMD.CMD_VERSAO "
				cQuery += "  AND T06.D_E_L_E_T_ = ' ' "

				cQuery += " INNER JOIN " + RetSqlName("T5I") + " T5I "
				cQuery += "  ON T5I.T5I_FILIAL = T06.T06_FILIAL "
				cQuery += "  AND T5I.T5I_ID = T06.T06_ID "
				cQuery += "  AND T5I.T5I_VERSAO = T06.T06_VERSAO "
				cQuery += "  AND T5I.T5I_IDEDMD = T06.T06_IDEDMD "
				cQuery += "  AND T5I.D_E_L_E_T_ = ' ' "

				cQuery += " INNER JOIN " + RetSqlName("T5J") + " T5J "
				cQuery += "  ON T5J.T5J_FILIAL = T5I.T5I_FILIAL "
				cQuery += "  AND T5J.T5J_ID = T5I.T5I_ID "
				cQuery += "  AND T5J.T5J_VERSAO = T5I.T5I_VERSAO "
				cQuery += "  AND T5J.T5J_IDEDMD = T5I.T5I_IDEDMD "
				cQuery += "  AND T5J.T5J_DTACCO = T5I.T5I_DTACCO "
				cQuery += "  AND T5J.T5J_TPACCO = T5I.T5I_TPACCO "
				cQuery += "  AND T5J.D_E_L_E_T_ = ' ' "

				cQuery += " INNER JOIN " + RetSqlName("T5Q") + " T5Q "
				cQuery += "  ON T5Q.T5Q_FILIAL = T5J.T5J_FILIAL "
				cQuery += "  AND T5Q.T5Q_ID = T5J.T5J_ID "
				cQuery += "  AND T5Q.T5Q_VERSAO = T5J.T5J_VERSAO "
				cQuery += "  AND T5Q.T5Q_IDEDMD = T5J.T5J_IDEDMD "
				cQuery += "  AND T5Q.T5Q_DTACCO = T5J.T5J_DTACCO "
				cQuery += "  AND T5Q.T5Q_TPACCO = T5J.T5J_TPACCO "
				cQuery += "  AND T5Q.T5Q_PERREF = T5J.T5J_PERREF "
				cQuery += "  AND T5Q.D_E_L_E_T_ = ' ' "

				cQuery += " INNER JOIN " + RetSqlName("T5S") + " T5S "
				cQuery += "   ON T5S.T5S_FILIAL = T5Q.T5Q_FILIAL "
				cQuery += "  AND T5S.T5S_ID = T5Q.T5Q_ID "
				cQuery += "  AND T5S.T5S_VERSAO = T5Q.T5Q_VERSAO "
				cQuery += "  AND T5S.T5S_IDEDMD = T5Q.T5Q_IDEDMD "
				cQuery += "  AND T5S.T5S_DTACCO = T5Q.T5Q_DTACCO "
				cQuery += "  AND T5S.T5S_TPACCO = T5Q.T5Q_TPACCO "
				cQuery += "  AND T5S.T5S_PERREF = T5Q.T5Q_PERREF "
				cQuery += "  AND T5S.T5S_ESTABE = T5Q.T5Q_ESTABE "
				cQuery += "  AND T5S.T5S_LOTTRB = T5Q.T5Q_LOTTRB "
				cQuery += "  AND T5S.D_E_L_E_T_ = ' ' "

				If !Empty(cParamCPF)

					cQuery += " INNER JOIN " + RetSqlName("C9V") + " C9V "
					cQuery += "   ON C9V.C9V_FILIAL = '" + xFilial("C9V") + "' "
					cQuery += "  AND C9V.C9V_ID = CMD.CMD_FUNC "
					cQuery += "  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
					cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "

				EndIf

				cQuery += " LEFT JOIN " + RetSqlName("C8R") + " C8R "
				cQuery += "  ON C8R.C8R_FILIAL = '" + xFilial("C8R") + "' "
				cQuery += " AND C8R.C8R_ID = T5S.T5S_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C89") + " C89 "
				cQuery += "  ON C89.C89_FILIAL = '" + xFilial("C89") + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C8T") + " C8T "
				cQuery += "  ON C8T.C8T_FILIAL = '" + xFilial("C8T") + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C8U") + " C8U "
				cQuery += "  ON C8U.C8U_FILIAL = '" + xFilial("C8U") + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8U.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C8O") + " C8O "
				cQuery += "  ON C8O.C8O_FILIAL = '" + xFilial("C8O") + "' "
				cQuery += " AND C8O.C8O_ID = CMD.CMD_MOTDES "
				cQuery += " AND C8O.D_E_L_E_T_ = ' ' "

				cQuery += " WHERE CMD.CMD_FILIAL = '" + xFilial("CMD") + "' "

				If Len(cPeriodo) == 4

					cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + cPeriodo + "01" + "01" + "' "
					cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

				Else

					cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
					cQuery += "			  AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

				EndIf

				cQuery += " AND CMD.CMD_ATIVO = '1' "
				cQuery += " AND CMD.CMD_EVENTO <> 'E' "
				cQuery += " AND CMD.D_E_L_E_T_ = ' ' "
				
				cQuery += " ORDER BY CMD_FILIAL, CMD_ID, CMD_VERSAO, CMD_DTDESL, ESTABE, LOTTRB "

				cQuery := ChangeQuery(cQuery)

				TCQuery cQuery New Alias (cAliasQry)

				(cAliasQry)->(DBGoTop())

				While !(cAliasQry)->(EOF())

					cFilQry		:= (cAliasQry)->CMD_FILIAL
					cID			:= (cAliasQry)->CMD_ID
					cVersao		:= (cAliasQry)->CMD_VERSAO
					cIDEstab	:= (cAliasQry)->ESTABE
					cIDLotac	:= (cAliasQry)->LOTTRB
					cIDTrabal	:= (cAliasQry)->CMD_FUNC
					cPerApu		:= SubStr(StrTran((cAliasQry)->CMD_DTDESL, "-", ""), 1, 4) + SubStr(StrTran((cAliasQry)->CMD_DTDESL, "-", ""), 5, 2)
					cRecibo		:= (cAliasQry)->CMD_PROTUL
					nRecnoQry	:= (cAliasQry)->CMD_RECONHECIMENTO
					cMotDes		:= AllTrim((cAliasQry)->C8O_CODIGO)

					If C9V->(MsSeek(xFilial("C9V") + cIDTrabal + "1"))

						cCPF 	:= C9V->C9V_CPF
						cNome 	:= TAFGetNT1U(cCPF,, aFilial[nI])
						
						If Empty(cNome)
							cNome := C9V->C9V_NOME
						EndIf

						cMatric		:= C9V->C9V_MATRIC
						cIDCateg 	:= GetCodCat(C9V->C9V_NOMEVE, aFilial[nI], C9V->C9V_ID, cPerApu)

						If Empty(cIDCateg)

							If CUP->(MsSeek(xFilial("CUP") + C9V->(C9V_ID + C9V_VERSAO + C9V_NOMEVE + C9V_MATRIC)))
								cIDCateg := CUP->CUP_CODCAT
							EndIf

						EndIf	

					EndIf

					If C92->(MsSeek(xFilial("C92") + (cAliasQry)->ESTABE + "1"))
						cTipoEstab	:= C92->C92_TPINSC
						cEstab		:= C92->C92_NRINSC
					EndIf

					If C99->(MsSeek(xFilial("C99") + (cAliasQry)->LOTTRB + "1"))
						cLotacao :=	C99->C99_CODIGO
					EndIf

					If C87->(MsSeek(xFilial("C87") + cIDCateg))
						cCodCat	:= C87->C87_CODIGO
					EndIf
					
					While (cAliasQry)->(CMD_FILIAL + CMD_ID + CMD_VERSAO + ESTABE + LOTTRB) == cFilQry + cID + cVersao + cIDEstab + cIDLotac

						cNatureza	:= AllTrim((cAliasQry)->C89_CODIGO)
						cTipo		:= AllTrim((cAliasQry)->C8R_INDTRB)
						cIncidCP	:= AllTrim((cAliasQry)->C8T_CODIGO)
						cIncidIRRF	:= AllTrim((cAliasQry)->C8U_CODIGO)
						cIncidFGTS	:= AllTrim((cAliasQry)->C8R_CINTFG)
						cIdeDmd		:= AllTrim((cAliasQry)->IDEDMD)

						tafDefAAnalitco(@aAnalitico)
						nPosValores := Len(aAnalitico)

						aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
						aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
						aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(cTipoEstab)
						aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(cEstab)
						aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(cLotacao)
						aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= cNatureza
						aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= cTipo
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= cIncidCP
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= cIncidIRRF
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= cIncidFGTS
						aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
						aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
						aAnalitico[nPosValores][ANALITICO_VALOR]				:= (cAliasQry)->VLRRUB
						aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]  := cMotDes
						aAnalitico[nPosValores][ANALITICO_RECIBO]				:= AllTrim(cIdeDmd)

						(cAliasQry)->(DBSkip())

					EndDo

					If ( cAliasQry )->( CMD_FILIAL + CMD_ID + CMD_VERSAO ) <> cFilQry + cID + cVersao

						InfoRPTObj("1", cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)

						oReport:UpSert("S-2299", "2", cFilQry, oInfoRPT)

						If !lProtheus

							InfoRPTObj("1", cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)
							oReport:UpSert("S-2299", "1", cFilQry, oInfoRPT)

						Else

							InsOrigCMD(cFilQry, nRecnoQry)

						EndIf

						Insert5003("S-2299", cFilQry, cPeriodo, cCPF, cRecibo, cFilMatriz, cMotDes)
						Insert5001("S-2299", cFilQry, "1", cPeriodo, cCPF, cNome, cRecibo, cFilMatriz, cMotDes)

						nQtdProc ++

						If !lCallExternal
							SetIncPerc( oRunCharge, "S-2299", nQtdTotal, nQtdProc )
						EndIf

						aAnalitico := {}

					EndIf

					cCodCat    := ""
					cCPF       := ""
					cEstab     := ""
					cFilQry    := ""
					cID        := ""
					cIDEstab   := ""
					cIDLotac   := ""
					cIDTrabal  := ""
					cIncidCP   := ""
					cIncidFGTS := ""
					cIncidIRRF := ""
					cLotacao   := ""
					cMatric    := ""
					cMotDes    := ""
					cNatureza  := ""
					cNome      := ""
					cPerApu    := ""
					cRecibo    := ""
					cTipo      := ""
					cTipoEstab := ""
					cVersao    := ""
					nRecnoQry  := 0

				EndDo

				(cAliasQry)->(DBCloseArea())

			Next

			cFilAnt := cFilBkp

		Else

			nQtdProc ++

			If !lCallExternal
				SetIncPerc( oRunCharge, "S-2299", nQtdTotal, nQtdProc )
			EndIf

		EndIf
	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigCMD
@type			function
@description	Função responsável por coletar as informações do Evento S-2299 no XML de entrada.
@author			Felipe C. Seolin
@since			15/07/2019
@version		1.0
@param			cFilEvt	-	Filial do registro do evento S-2299 no TAF
@param			nRecno	-	Recno do registro do evento S-2299 no TAF
/*/
//---------------------------------------------------------------------
Static Function InsOrigCMD( cFilEvt as Character, nRecno as Numeric )

	Local aAnalitico  as Array
	Local aAreaC1E    as Array
	Local aAreaC87    as Array
	Local aAreaC8R    as Array
	Local aAreaC9V    as Array
	Local aAreaCUP    as Array
	Local aRubrica    as Array
	Local cAliasQry   as Character
	Local cCodCat     as Character
	Local cCPF        as Character
	Local cDtDeslig   as Character
	Local cMatric     as Character
	Local cMotDes     as Character
	Local cNome       as Character
	Local cPerApu     as Character
	Local cQuery      as Character
	Local cT05Path    as Character
	Local cT06Path    as Character
	Local cT3GPath    as Character
	Local cT5IPath    as Character
	Local cT5JPath    as Character
	Local cT5QPath    as Character
	Local cT5SPath    as Character
	Local cXml        as Character
	Local nC9VCPF     as Numeric
	Local nC9VMATRIC  as Numeric
	Local nPosValores as Numeric
	Local nT05        as Numeric
	Local nT06        as Numeric
	Local nT3G        as Numeric
	Local nT5I        as Numeric
	Local nT5J        as Numeric
	Local nT5Q        as Numeric
	Local nT5S        as Numeric
	Local nTamCod     as Numeric
	Local oInfoRPT    as Object
	Local oXml        as Object
	
	Default cFilEvt := ""
	Default nRecno  := 0

	aAnalitico  := {}
	aAreaC1E    := C1E->(GetArea())
	aAreaC87    := C87->(GetArea())
	aAreaC8R    := C8R->(GetArea())
	aAreaC9V    := C9V->(GetArea())
	aAreaCUP    := CUP->(GetArea())
	aRubrica    := {}
	cAliasQry   := GetNextAlias()
	cCodCat     := ""
	cCPF        := ""
	cDtDeslig   := ""
	cMatric     := ""
	cMotDes     := ""
	cNome       := ""
	cPerApu     := ""
	cQuery      := ""
	cT05Path    := ""
	cT06Path    := ""
	cT3GPath    := ""
	cT5IPath    := ""
	cT5JPath    := ""
	cT5QPath    := ""
	cT5SPath    := ""
	cXml        := ""
	nC9VCPF     := GetSX3Cache("C9V_CPF", "X3_TAMANHO")
	nC9VMATRIC  := GetSX3Cache("C9V_MATRIC", "X3_TAMANHO")
	nPosValores := 0
	nT05        := 0
	nT06        := 0
	nT3G        := 0
	nT5I        := 0
	nT5J        := 0
	nT5Q        := 0
	nT5S        := 0
	nTamCod     := TamSX3( "C8R_CODRUB" )[1]

	oInfoRPT	:= Nil
	oXml		:= Nil

	C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C1E->( MsSeek( xFilial( "C1E" ) + cFilEvt + "1" ) )

	cQuery := " SELECT TAFST2.R_E_C_N_O_ TAFST2_RECONHECIMENTO "
	cQuery += " FROM TAFXERP TAFXERP "
	cQuery += " INNER JOIN TAFST2 TAFST2 "
	cQuery += "  ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cQuery += "  AND TAFST2.TAFFIL = '" + C1E->C1E_CODFIL + "' "
	cQuery += "  AND TAFST2.D_E_L_E_T_ = '' "
	cQuery += " WHERE TAFXERP.TAFALIAS = 'CMD' "
	cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
	cQuery += "  AND TAFXERP.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY TAFXERP.R_E_C_N_O_ DESC "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )

		C9V->( DBSetOrder( 10 ) ) //C9V_FILIAL, C9V_CPF, C9V_MATRIC, C9V_NOMEVE, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_
		CUP->( DBSetOrder( 4 ) ) //CUP_FILIAL, CUP_ID, CUP_VERSAO, CUP_NOMEVE, CUP_MATRIC, R_E_C_N_O_, D_E_L_E_T_
		C87->( DBSetOrder( 1 ) ) //C87_FILIAL, C87_ID, C87_VALIDA, R_E_C_N_O_, D_E_L_E_T_

		( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

		cXml := ( cST2Alias )->TAFMSG

		//Tiro os espaços em branco no início e final do XML e armazeno na variável
		cXml := EncodeUTF8( AllTrim( cXml ) )

		//Instancia objeto em oXml
		oXml := TXmlManager():New()

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"

			cXml := StrTran( cXml, Chr( 13 ), "" )
			cXml := StrTran( cXml, Chr( 10 ), "" )

			//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
			If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
				cXml += ">"
			EndIf

		EndIf

		If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
			oXml:bDecodeUTF8 := .T.
		EndIf

		cDtDeslig	:=	oXml:xPathGetNodeValue( "/eSocial/evtDeslig/infoDeslig/dtDeslig" )
		cPerApu		:=	SubStr( StrTran( cDtDeslig, "-", "" ), 1, 4 ) + SubStr( StrTran( cDtDeslig, "-", "" ), 5, 2 )
		cCPF		:=	oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/cpfTrab" )
		cMatric		:=	oXml:xPathGetNodeValue( "/eSocial/evtDeslig/ideVinculo/matricula" )
		
		If oXml:XPathHasNode("/eSocial/evtDeslig/infoDeslig/mtvDeslig")
			cMotDes := AllTrim(oXml:XPathGetNodeValue("/eSocial/evtDeslig/infoDeslig/mtvDeslig"))
		EndIf

		cNome := TAFGetNT1U(cCPF,, cFilEvt)

		If C9V->(MsSeek(xFilial("C9V") + PadR(cCPF, nC9VCPF) + PadR(cMatric, nC9VMATRIC) + "S2200" + "1"))

			If Empty(cNome) 
				cNome := C9V->C9V_NOME
			EndIf

			If CUP->( MsSeek( xFilial( "CUP" ) + C9V->( C9V_ID + C9V_VERSAO + C9V_NOMEVE ) ) )

				If C87->( MsSeek( xFilial( "C87" ) + CUP->CUP_CODCAT ) )
					cCodCat := C87->C87_CODIGO
				EndIf

			EndIf

		EndIf

		//T06 - Informações do Recibo de Pagamento
		nT06 := 1
		cT06Path := "/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev[" + cValToChar( nT06 ) + "]"

		While oXml:xPathHasNode( cT06Path )

			//Informações do Período de Apuração
			//T3G - Informações do Estabelecimento/Lotação
			nT3G := 1
			cT3GPath := cT06Path + "/infoPerApur/ideEstabLot[" + cValToChar( nT3G ) + "]"

			While oXml:xPathHasNode( cT3GPath )

				//T05 - Informações das Rubricas
				nT05 := 1
				cT05Path := cT3GPath + "/detVerbas[" + cValToChar( nT05 ) + "]"

				While oXml:xPathHasNode(cT05Path)

					aRubrica := oReport:GetRubrica( Padr(oXml:xPathGetNodeValue(cT05Path + "/codRubr"),nTamCod), TAFIDTabRub(oXml:xPathGetNodeValue(cT05Path + "/ideTabRubr"), "T3M", oXml:xPathGetNodeValue(cT05Path + "/codRubr")))

					tafDefAAnalitco(@aAnalitico)
					nPosValores := Len(aAnalitico)

					aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
					aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
					aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(oXml:xPathGetNodeValue(cT3GPath + "/tpInsc"))
					aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(oXml:xPathGetNodeValue(cT3GPath + "/nrInsc"))
					aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(oXml:xPathGetNodeValue(cT3GPath + "/codLotacao"))
					aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
					aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
					aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
					aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
					aAnalitico[nPosValores][ANALITICO_VALOR]				:= Val(StrTran(oXml:xPathGetNodeValue(cT05Path + "/vrRubr"), ",", "."))
					aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]  := cMotDes

					nT05++

					cT05Path := cT3GPath + "/detVerbas[" + cValToChar(nT05) + "]"

				EndDo

				nT3G ++
				cT3GPath := cT06Path + "/infoPerApur/ideEstabLot[" + cValToChar( nT3G ) + "]"

			EndDo

			//Informações do Período de Apuração Anterior
			//T5I - Informações do Acordo
			nT5I := 1
			cT5IPath := cT06Path + "/infoPerAnt/ideADC[" + cValToChar( nT5I ) + "]"

			While oXml:xPathHasNode( cT5IPath )

				//T5J - Identificação do Período de Referência
				nT5J := 1
				cT5JPath := cT5IPath + "/idePeriodo[" + cValToChar( nT5J ) + "]"

				While oXml:xPathHasNode( cT5JPath )

					//T5Q - Informações do Estabelecimento/Lotacão
					nT5Q := 1
					cT5QPath := cT5JPath + "/ideEstabLot[" + cValToChar( nT5Q ) + "]"

					While oXml:xPathHasNode( cT5QPath )

						//T5S - Itens da Remuneração
						nT5S := 1
						cT5SPath := cT5QPath + "/detVerbas[" + cValToChar( nT5S ) + "]"

						While oXml:xPathHasNode(cT5SPath)

							aRubrica := oReport:GetRubrica( Padr(oXml:xPathGetNodeValue(cT5SPath + "/codRubr"),nTamCod), TAFIDTabRub(oXml:xPathGetNodeValue(cT5SPath + "/ideTabRubr"), "T3M", oXml:xPathGetNodeValue(cT5SPath + "/codRubr")))

							tafDefAAnalitco(@aAnalitico)
							nPosValores := Len(aAnalitico)

							aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
							aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
							aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(oXml:xPathGetNodeValue(cT5QPath + "/tpInsc"))
							aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(oXml:xPathGetNodeValue(cT5QPath + "/nrInsc"))
							aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(oXml:xPathGetNodeValue(cT5QPath + "/codLotacao"))
							aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
							aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
							aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
							aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
							aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
							aAnalitico[nPosValores][ANALITICO_VALOR]				:= Val(StrTran(oXml:xPathGetNodeValue(cT5SPath + "/vrRubr"), ",", "."))
							aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]  := cMotDes

							nT5S++

							cT5SPath := cT5QPath + "/detVerbas[" + cValToChar(nT5S) + "]"

						EndDo

						nT5Q ++
						cT5QPath := cT5JPath + "/ideEstabLot[" + cValToChar( nT5Q ) + "]"

					EndDo

					nT5J ++
					cT5JPath := cT5IPath + "/idePeriodo[" + cValToChar( nT5J ) + "]"

				EndDo

				nT5I ++
				cT5IPath := cT06Path + "/infoPerAnt/ideADC[" + cValToChar( nT5I ) + "]"

			EndDo

			nT06 ++
			cT06Path := "/eSocial/evtDeslig/infoDeslig/verbasResc/dmDev[" + cValToChar( nT06 ) + "]"

		EndDo

		InfoRPTObj("1", cPerApu, AllTrim(cCPF),	AllTrim(cNome), aAnalitico,, @oInfoRPT)
		oReport:UpSert("S-2299", "1", cFilEvt, oInfoRPT)

	EndIf

	(cAliasQry)->(DBCloseArea())

	RestArea(aAreaC1E)
	RestArea(aAreaC9V)
	RestArea(aAreaCUP)
	RestArea(aAreaC87)
	RestArea(aAreaC8R)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} DataS2399
@type			function
@description	Função responsável por coletar as informações do Evento S-2399 no TAF.
@author			Felipe C. Seolin
@since			17/07/2019
@version		1.0
@param			oRunCharge		-	Objeto do FWMsgRun
@param			lCallExternal	-	Indica se a chamada é externa ao menu do TAF
@param			cPeriodo		-	Período de referência das informações
@param			aFilial			-	Filiais selecionadas para processamento
@param			cParamCPF		-	CPF selecionado como filtro de processamento
@param			lProtheus		-	Indica se a Origem dos dados parte do Protheus
@param			cFilMatriz		-	Filial Matriz
/*/
//---------------------------------------------------------------------
Static Function DataS2399( oRunCharge as Object, lCallExternal as Logical, cPeriodo as Character,;
						   aFilial as Array, cParamCPF as Character, lProtheus as Logical, cFilMatriz as Character )

	Local aAnalitico  as Array
	Local cAliasQry   as Character
	Local cCodCat     as Character
	Local cCPF        as Character
	Local cEstab      as Character
	Local cFilBkp     as Character
	Local cFilC9V     as Character
	Local cFilQry     as Character
	Local cFilT92     as Character
	Local cID         as Character
	Local cIDEstab    as Character
	Local cIDLotac    as Character
	Local cIDTrabal   as Character
	Local cIncidCP    as Character
	Local cIncidFGTS  as Character
	Local cIncidIRRF  as Character
	Local cLotacao    as Character
	Local cMatric     as Character
	Local cMotDes     as Character
	Local cNatureza   as Character
	Local cNome       as Character
	Local cPerApu     as Character
	Local cQuery      as Character
	Local cRecibo     as Character
	Local cTipo       as Character
	Local cTipoEstab  as Character
	Local cVersao     as Character
	Local cIDCateg    as Character
	Local nI          as Numeric
	Local nPosValores as Numeric
	Local nQtdProc    as Numeric
	Local nQtdTotal   as Numeric
	Local nRecnoQry   as Numeric
	Local oInfoRPT    as Object

	aAnalitico  := {}
	cAliasQry   := ""
	cCodCat     := ""
	cCPF        := ""
	cEstab      := ""
	cFilBkp     := ""
	cFilC9V     := ""
	cFilQry     := ""
	cFilT92     := ""
	cID         := ""
	cIDEstab    := ""
	cIDLotac    := ""
	cIDTrabal   := ""
	cIncidCP    := ""
	cIncidFGTS  := ""
	cIncidIRRF  := ""
	cLotacao    := ""
	cMatric     := ""
	cMotDes     := ""
	cNatureza   := ""
	cNome       := ""
	cPerApu     := ""
	cQuery      := ""
	cRecibo     := ""
	cTipo       := ""
	cTipoEstab  := ""
	cVersao     := ""
	cIDCateg    := ""
	nI          := 0
	nPosValores := 0
	nQtdProc    := 0
	nQtdTotal   := 0
	nRecnoQry   := 0
	oInfoRPT    := Nil

	If !Empty(aFilial)

		cFilT92		:= GetFilial("T92", aFilial)
		cAliasQry	:= GetNextAlias()

		If !Empty(cParamCPF)
			cFilC9V := GetFilial("C9V", aFilial)
		EndIf

		cQuery := "SELECT COUNT(*) QUANTIDADE "
		cQuery += "FROM " + RetSqlName("T92") + " T92 "
		cQuery += "WHERE T92.T92_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilT92 + " FILIAIS ) "

		If Len(cPeriodo) == 4

			cQuery += "			  AND T92.T92_DTERAV BETWEEN '" + cPeriodo + "01" + "01" + "' "
			cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

		Else

			cQuery += "  AND T92.T92_DTERAV BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
			cQuery += "	 AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

		EndIf

		cQuery += "  AND EXISTS (	SELECT CMK.R_E_C_N_O_ "
		cQuery += "					FROM " + RetSqlName("CMK") + " CMK "
		cQuery += "					WHERE CMK.CMK_FILIAL = T92.T92_FILIAL "
		cQuery += "					  AND CMK.CMK_ID = T92.T92_ID "
		cQuery += "					  AND CMK.CMK_VERSAO = T92.T92_VERSAO "
		cQuery += "					  AND CMK.D_E_L_E_T_ = ' ' ) "

		If !Empty(cParamCPF)

			cQuery += "  AND EXISTS (	SELECT C9V.R_E_C_N_O_ "
			cQuery += "					FROM " + RetSqlName("C9V") + " C9V "
			cQuery += "					WHERE C9V.C9V_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilC9V + " FILIAIS ) "
			cQuery += "					  AND C9V.C9V_ID = T92.T92_TRABAL "
			cQuery += "					  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
			cQuery += "					  AND C9V.D_E_L_E_T_ = ' ' ) "

		EndIf

		cQuery += "  AND T92.T92_ATIVO = '1' "
		cQuery += "  AND T92.T92_EVENTO <> 'E' "
		cQuery += "  AND T92.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		TCQuery cQuery New Alias (cAliasQry)

		(cAliasQry)->(DBGoTop())

		If !(cAliasQry)->(EOF())
			nQtdTotal := (cAliasQry)->QUANTIDADE
		EndIf

		(cAliasQry)->(DBCloseArea())

		If nQtdTotal > 0

			C9V->(DBSetOrder(2))
			C87->(DBSetOrder(1))
			C92->(DBSetOrder(5))
			C99->(DBSetOrder(4))

			cFilBkp := cFilAnt

			For nI := 1 To Len(aFilial)

				cFilAnt		:= aFilial[nI]
				cAliasQry	:= GetNextAlias()

				cQuery := " SELECT DISTINCT T92.R_E_C_N_O_ T92_RECONHECIMENTO, T92.T92_FILIAL, T92.T92_ID, T92.T92_VERSAO, T92.T92_DTERAV, T92.T92_TRABAL, T92.T92_PROTUL "
				cQuery += "     , T3J.T3J_ESTABE, T3J.T3J_LOTTRB, CML.CML_CODIGO "
				cQuery += "     , C89.C89_CODIGO, C8R.C8R_INDTRB, C8T.C8T_CODIGO, C8U.C8U_CODIGO, C8R.C8R_CINTFG "
				cQuery += "     , CMK.CMK_VLRRUB, CMK.R_E_C_N_O_ CMK_RECONHECIMENTO "

				cQuery += " FROM " + RetSqlName("T92") + " T92 "

				cQuery += " INNER JOIN " + RetSqlName("T3I") + " T3I "
				cQuery += "  ON T3I.T3I_FILIAL = T92.T92_FILIAL "
				cQuery += "  AND T3I.T3I_ID = T92.T92_ID "
				cQuery += "  AND T3I.T3I_VERSAO = T92.T92_VERSAO "
				cQuery += "  AND T3I.D_E_L_E_T_ = ' ' "

				cQuery += " INNER JOIN " + RetSqlName("T3J") + " T3J "
				cQuery += "  ON T3J.T3J_FILIAL = T3I.T3I_FILIAL "
				cQuery += "  AND T3J.T3J_ID = T3I.T3I_ID "
				cQuery += "  AND T3J.T3J_VERSAO = T3I.T3I_VERSAO "
				cQuery += "  AND T3J.T3J_IDEDMD = T3I.T3I_IDEDMD "
				cQuery += "  AND T3J.D_E_L_E_T_ = ' ' "

				cQuery += " INNER JOIN " + RetSqlName("CMK") + " CMK "
				cQuery += "  ON CMK.CMK_FILIAL = T3J.T3J_FILIAL "
				cQuery += "  AND CMK.CMK_ID = T3J.T3J_ID "
				cQuery += "  AND CMK.CMK_VERSAO = T3J.T3J_VERSAO "
				cQuery += "  AND CMK.CMK_IDEDMD = T3J.T3J_IDEDMD "
				cQuery += "  AND CMK.CMK_ESTABE = T3J.T3J_ESTABE "
				cQuery += "  AND CMK.CMK_LOTTRB = T3J.T3J_LOTTRB "
				cQuery += "  AND CMK.D_E_L_E_T_ = ' ' "

				If !Empty(cParamCPF)

					cQuery += " INNER JOIN " + RetSqlName("C9V") + " C9V "
					cQuery += "   ON C9V.C9V_FILIAL = '" + xFilial("C9V") + "' "
					cQuery += "  AND C9V.C9V_ID = T92.T92_TRABAL "
					cQuery += "  AND C9V.C9V_CPF = '" + AllTrim(cParamCPF) + "' "
					cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "

				EndIf

				cQuery += " LEFT JOIN " + RetSqlName("C8R") + " C8R "
				cQuery += " ON C8R.C8R_FILIAL = '" + xFilial("C8R") + "' "
				cQuery += " AND C8R.C8R_ID = CMK.CMK_CODRUB "
				cQuery += " AND C8R.C8R_ATIVO = '1' "
				cQuery += " AND C8R.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C89") + " C89 "
				cQuery += " ON C89.C89_FILIAL = '" + xFilial("C89") + "' "
				cQuery += " AND C89.C89_ID = C8R.C8R_NATRUB "
				cQuery += " AND C89.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C8T") + " C8T "
				cQuery += " ON C8T.C8T_FILIAL = '" + xFilial("C8T") + "' "
				cQuery += " AND C8T.C8T_ID = C8R.C8R_CINTPS "
				cQuery += " AND C8T.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("C8U") + " C8U "
				cQuery += " ON C8U.C8U_FILIAL = '" + xFilial("C8U") + "' "
				cQuery += " AND C8U.C8U_ID = C8R.C8R_CINTIR "
				cQuery += " AND C8U.D_E_L_E_T_ = ' ' "

				cQuery += " LEFT JOIN " + RetSqlName("CML") + " CML "
				cQuery += " ON CML.CML_FILIAL = '" + xFilial("CML") + "' "
				cQuery += " AND CML.CML_ID = T92.T92_MOTDES "
				cQuery += " AND CML.D_E_L_E_T_ = ' ' "
				
				cQuery += " WHERE T92.T92_FILIAL = '" + xFilial("T92") + "' "

				If Len(cPeriodo) == 4

					cQuery += "			  AND T92.T92_DTERAV BETWEEN '" + cPeriodo + "01" + "01" + "' "
					cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

				Else

					cQuery += "  AND T92.T92_DTERAV BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
					cQuery += "	 AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

				EndIf

				cQuery += "  AND T92.T92_ATIVO = '1' "
				cQuery += "  AND T92.T92_EVENTO <> 'E' "
				cQuery += "  AND T92.D_E_L_E_T_ = '' "

				cQuery += " ORDER BY T92.T92_FILIAL, T92.T92_ID, T92.T92_VERSAO, T92.T92_DTERAV, T3J.T3J_ESTABE, T3J.T3J_LOTTRB "

				cQuery := ChangeQuery(cQuery)

				TCQuery cQuery New Alias (cAliasQry)

				(cAliasQry)->(DBGoTop())

				While !(cAliasQry)->(EOF())

					cFilQry		:= (cAliasQry)->T92_FILIAL
					cID			:= (cAliasQry)->T92_ID
					cVersao		:= (cAliasQry)->T92_VERSAO
					cIDEstab	:= (cAliasQry)->T3J_ESTABE
					cIDLotac	:= (cAliasQry)->T3J_LOTTRB
					cIDTrabal	:= (cAliasQry)->T92_TRABAL
					cPerApu		:= SubStr(StrTran((cAliasQry)->T92_DTERAV, "-", ""), 1, 4) + SubStr(StrTran((cAliasQry)->T92_DTERAV, "-", ""), 5, 2)
					cRecibo		:= (cAliasQry)->T92_PROTUL
					nRecnoQry	:= (cAliasQry)->T92_RECONHECIMENTO
					cMotDes		:= AllTrim((cAliasQry)->CML_CODIGO)

					If C9V->(MsSeek(xFilial("C9V") + cIDTrabal + "1"))

						cCPF 	:= C9V->C9V_CPF
						cNome 	:= TAFGetNT1U(cCPF,, aFilial[nI])
						
						If Empty(cNome)
							cNome := C9V->C9V_NOME
						EndIf

						cMatric		:= C9V->C9V_MATTSV
						cIDCateg	:= GetCodCat(C9V->C9V_NOMEVE, aFilial[nI], C9V->C9V_ID, cPerApu)

						If Empty(cIDCateg)
							cIDCateg := C9V->C9V_CATCI
						EndIf	

					EndIf

					If C92->(MsSeek(xFilial("C92") + (cAliasQry)->T3J_ESTABE + "1"))
						cTipoEstab	:= C92->C92_TPINSC
						cEstab		:= C92->C92_NRINSC
					EndIf

					If C99->(MsSeek(xFilial("C99") + (cAliasQry)->T3J_LOTTRB + "1"))
						cLotacao :=	C99->C99_CODIGO
					EndIf

					If C87->(MsSeek(xFilial("C87") + cIDCateg))
						cCodCat	:= C87->C87_CODIGO
					EndIf

					While (cAliasQry)->(T92_FILIAL + T92_ID + T92_VERSAO + T3J_ESTABE + T3J_LOTTRB) == cFilQry + cID + cVersao + cIDEstab + cIDLotac

						cNatureza	:= AllTrim((cAliasQry)->C89_CODIGO)
						cTipo		:= AllTrim((cAliasQry)->C8R_INDTRB)
						cIncidCP	:= AllTrim((cAliasQry)->C8T_CODIGO)
						cIncidIRRF	:= AllTrim((cAliasQry)->C8U_CODIGO)
						cIncidFGTS	:= AllTrim((cAliasQry)->C8R_CINTFG)

						tafDefAAnalitco(@aAnalitico)
						nPosValores := Len(aAnalitico)

						aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim(cMatric)
						aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
						aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(cTipoEstab)
						aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(cEstab)
						aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(cLotacao)
						aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= cNatureza
						aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= cTipo
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= cIncidCP
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= cIncidIRRF
						aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= cIncidFGTS
						aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
						aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
						aAnalitico[nPosValores][ANALITICO_VALOR]				:= (cAliasQry)->CMK_VLRRUB
						aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]  := cMotDes

						(cAliasQry)->(DBSkip())

					EndDo

					If ( cAliasQry )->( T92_FILIAL + T92_ID + T92_VERSAO ) <> cFilQry + cID + cVersao

						InfoRPTObj("1", cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)
						oReport:UpSert("S-2399", "2", cFilQry, oInfoRPT)

						If !lProtheus

							InfoRPTObj("1", cPerApu, cCPF, cNome, aAnalitico,, @oInfoRPT)
							oReport:UpSert("S-2399", "1", cFilQry, oInfoRPT)

						Else

							InsOrigT92(cFilQry, nRecnoQry)

						EndIf

						Insert5003("S-2399", cFilQry, cPeriodo, cCPF, cRecibo, cFilMatriz, cMotDes)
						Insert5001("S-2399", cFilQry, "1", cPeriodo, cCPF, cNome, cRecibo, cFilMatriz, cMotDes)

						nQtdProc ++

						If !lCallExternal
							SetIncPerc( oRunCharge, "S-2399", nQtdTotal, nQtdProc )
						EndIf

						aAnalitico := {}

					EndIf

					cCodCat    := ""
					cCPF       := ""
					cEstab     := ""
					cFilQry    := ""
					cID        := ""
					cIDEstab   := ""
					cIDLotac   := ""
					cIDTrabal  := ""
					cIncidCP   := ""
					cIncidFGTS := ""
					cIncidIRRF := ""
					cLotacao   := ""
					cMatric    := ""
					cMotDes    := ""
					cNatureza  := ""
					cNome      := ""
					cPerApu    := ""
					cRecibo    := ""
					cTipo      := ""
					cTipoEstab := ""
					cVersao    := ""
					nRecnoQry  := 0

				EndDo

				(cAliasQry)->(DBCloseArea())

			Next

			cFilAnt := cFilBkp

		Else

			nQtdProc ++

			If !lCallExternal
				SetIncPerc( oRunCharge, "S-2399", nQtdTotal, nQtdProc )
			EndIf

		EndIf

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} InsOrigT92
@type			function
@description	Função responsável por coletar as informações do Evento S-2399 no XML de entrada.
@author			Felipe C. Seolin
@since			17/07/2019
@version		1.0
@param			cFilEvt	-	Filial do registro do evento S-2399 no TAF
@param			nRecno	-	Recno do registro do evento S-2399 no TAF
/*/
//---------------------------------------------------------------------
Static Function InsOrigT92( cFilEvt as Character, nRecno as Numeric )

	Local aAnalitico  as Array
	Local aAreaC1E    as Array
	Local aAreaC87    as Array
	Local aAreaC8R    as Array
	Local aAreaC9V    as Array
	Local aRubrica    as Array
	Local cAliasQry   as Character
	Local cCMKPath    as Character
	Local cCodCat     as Character
	Local cCPF        as Character
	Local cDtTerm     as Character
	Local cMatric     as Character
	Local cMotDes     as Character
	Local cNome       as Character
	Local cPerApu     as Character
	Local cQuery      as Character
	Local cT3IPath    as Character
	Local cT3JPath    as Character
	Local cXml        as Character
	Local nC9VCATCI   as Numeric
	Local nC9VCPF     as Numeric
	Local nC9VMATTSV  as Numeric
	Local nCMK        as Numeric
	Local nPosValores as Numeric
	Local nT3I        as Numeric
	Local nT3J        as Numeric
	Local nTamCod     as Numeric
	Local oInfoRPT    as Object
	Local oXml        as Object

	Default cFilEvt := ""
	Default nRecno  := 0

	aAnalitico  := {}
	aAreaC1E    := C1E->(GetArea())
	aAreaC87    := C87->(GetArea())
	aAreaC8R    := C8R->(GetArea())
	aAreaC9V    := C9V->(GetArea())
	aRubrica    := {}
	cAliasQry   := GetNextAlias()
	cCMKPath    := ""
	cCodCat     := ""
	cCPF        := ""
	cDtTerm     := ""
	cMatric     := ""
	cMotDes     := ""
	cNome       := ""
	cPerApu     := ""
	cQuery      := ""
	cT3IPath    := ""
	cT3JPath    := ""
	cXml        := ""
	nC9VCATCI   := GetSX3Cache("C9V_CATCI", "X3_TAMANHO")
	nC9VCPF     := GetSX3Cache("C9V_CPF", "X3_TAMANHO")
	nC9VMATTSV  := GetSX3Cache("C9V_MATTSV", "X3_TAMANHO")
	nCMK        := 0
	nPosValores := 0
	nT3I        := 0
	nT3J        := 0
	nTamCod     := TamSX3( "C8R_CODRUB" )[1]
	oInfoRPT    := Nil
	oXml        := Nil

	C1E->( DBSetOrder( 3 ) ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	C1E->( MsSeek( xFilial( "C1E" ) + cFilEvt + "1" ) )

	cQuery := " SELECT TAFST2.R_E_C_N_O_ TAFST2_RECONHECIMENTO "
	cQuery += " FROM TAFXERP TAFXERP "
	cQuery += " INNER JOIN TAFST2 TAFST2 "
	cQuery += "  ON TAFST2.TAFTICKET = TAFXERP.TAFTICKET "
	cQuery += "  AND TAFST2.TAFKEY = TAFXERP.TAFKEY "
	cQuery += "  AND TAFST2.TAFFIL = '" + C1E->C1E_CODFIL + "' "
	cQuery += "  AND TAFST2.D_E_L_E_T_ = '' "
	cQuery += " WHERE TAFXERP.TAFALIAS = 'T92' "
	cQuery += "  AND TAFXERP.TAFRECNO = '" + cValToChar( nRecno ) + "' "
	cQuery += "  AND TAFXERP.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY TAFXERP.R_E_C_N_O_ DESC "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If !(cAliasQry)->(EOF())

		C9V->( DBSetOrder( 19 ) ) //C9V_FILIAL, C9V_CPF, C9V_CATCI, C9V_NOMEVE, C9V_ATIVO, R_E_C_N_O_, D_E_L_E_T_

		( cST2Alias )->( DBGoTo( ( cAliasQry )->TAFST2_RECONHECIMENTO ) )

		cXml := ( cST2Alias )->TAFMSG

		//Tiro os espaços em branco no início e final do XML e armazeno na variável
		cXml := EncodeUTF8( AllTrim( cXml ) )

		//Instancia objeto em oXml
		oXml := TXmlManager():New()

		If Upper( AllTrim( TCGetDB() ) ) == "ORACLE"

			cXml := StrTran( cXml, Chr( 13 ), "" )
			cXml := StrTran( cXml, Chr( 10 ), "" )

			//Tratamento para integração Oracle onde o XML vem com o último caracter faltando
			If SubStr( AllTrim( cXml ), Len( cXml ), 1 ) <> ">"
				cXml += ">"
			EndIf

		EndIf

		If !Empty( cXml ) .and. oXml:Parse( FTrocaPath( cXml, "eSocial" ) )
			oXml:bDecodeUTF8 := .T.
		EndIf

		cDtTerm	:=	oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/infoTSVTermino/dtTerm" )
		cPerApu	:=	SubStr( StrTran( cDtTerm, "-", "" ), 1, 4 ) + SubStr( StrTran( cDtTerm, "-", "" ), 5, 2 )
		cCPF	:=	oXml:xPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/cpfTrab" )
		cCodCat :=	oXml:XPathGetNodeValue( "/eSocial/evtTSVTermino/ideTrabSemVinculo/codCateg" )
		cMatric :=  AllTrim(oXml:xPathGetNodeValue("/eSocial/evtTSVTermino/ideTrabSemVinculo/matricula"))																						   

		If oXml:XPathHasNode("/eSocial/evtTSVTermino/infoTSVTermino/mtvDesligTSV")
			cMotDes := AllTrim(oXml:XPathGetNodeValue("/eSocial/evtTSVTermino/infoTSVTermino/mtvDesligTSV"))
		EndIf

		cNome := TAFGetNT1U(cCPF,, cFilEvt)
	
		If Empty(cNome) .And. C9V->( MsSeek( xFilial( "C9V" ) + PadR( cCPF, nC9VCPF ) + PadR( Posicione( "C87", 2, xFilial( "C87" ) + cCodCat, "C87_ID" ), nC9VCATCI ) + "S2300" + "1" ) )
			
			cNome := C9V->C9V_NOME

		Else

			C9V->( DBSetOrder( 20 ) ) //C9V_FILIAL+C9V_CPF+C9V_MATTSV+C9V_NOMEVE+C9V_ATIVO 

		 	If Empty(cNome) .And. C9V->( MsSeek( xFilial( "C9V" ) + PadR( cCPF, nC9VCPF ) + PadR( cMatric, nC9VMATTSV ) + "S2300" + "1" ) )
				cNome 	:= C9V->C9V_NOME
				cCodCat := Posicione( "C87", 1, xFilial( "C87" ) + C9V->C9V_CATCI , "C87_CODIGO" )
			EndIf

		EndIf

		//T3I - Informações do Recibo de Pagamento
		nT3I := 1
		cT3IPath := "/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev[" + cValToChar( nT3I ) + "]"

		While oXml:xPathHasNode( cT3IPath )

			//T3J - Informações do Estabelecimento/Lotação
			nT3J := 1
			cT3JPath := cT3IPath + "/ideEstabLot[" + cValToChar( nT3J ) + "]"

			While oXml:xPathHasNode( cT3JPath )

				//CMK - Informações das Rubricas
				nCMK := 1
				cCMKPath := cT3JPath + "/detVerbas[" + cValToChar( nCMK ) + "]"

				While oXml:xPathHasNode(cCMKPath)

					aRubrica := oReport:GetRubrica(Padr(oXml:xPathGetNodeValue(cCMKPath + "/codRubr"),nTamCod), TAFIDTabRub(oXml:xPathGetNodeValue(cCMKPath + "/ideTabRubr"), "T3M", oXml:xPathGetNodeValue(cCMKPath + "/codRubr")))

					tafDefAAnalitco(@aAnalitico)
					nPosValores := Len(aAnalitico)

					aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= IIf(!lLaySimplif, "", cMatric)
					aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim(cCodCat)
					aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim(oXml:xPathGetNodeValue(cT3JPath + "/tpInsc"))
					aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim(oXml:xPathGetNodeValue(cT3JPath + "/nrInsc"))
					aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim(oXml:xPathGetNodeValue(cT3JPath + "/codLotacao"))
					aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= AllTrim(aRubrica[1])
					aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= AllTrim(aRubrica[2])
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= AllTrim(aRubrica[3])
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= AllTrim(aRubrica[4])
					aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= AllTrim(aRubrica[5])
					aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
					aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= ""
					aAnalitico[nPosValores][ANALITICO_VALOR]				:= Val(StrTran(oXml:xPathGetNodeValue(cCMKPath + "/vrRubr"), ",", "."))
					aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]  := cMotDes

					nCMK++

					cCMKPath := cT3JPath + "/detVerbas[" + cValToChar(nCMK) + "]"

				EndDo

				nT3J ++
				cT3JPath := cT3IPath + "/ideEstabLot[" + cValToChar( nT3J ) + "]"

			EndDo

			nT3I ++
			cT3IPath := "/eSocial/evtTSVTermino/infoTSVTermino/verbasResc/dmDev[" + cValToChar( nT3I ) + "]"

		EndDo

		InfoRPTObj("1", cPerApu, AllTrim(cCPF),	AllTrim(cNome), aAnalitico,, @oInfoRPT)

		oReport:UpSert("S-2399", "1", cFilEvt, oInfoRPT)

	EndIf

	(cAliasQry)->(DBCloseArea())

	RestArea(aAreaC1E)
	RestArea(aAreaC9V)
	RestArea(aAreaC87)
	RestArea(aAreaC8R)

Return
 
//---------------------------------------------------------------------
/*/{Protheus.doc} Insert5003
@type			function
@description	Função responsável por coletar as informações do Evento S-5003 no retorno do Governo.
@author			Felipe C. Seolin
@since			12/07/2019
@version		1.0
@param			cEvento		-	Evento de Origem do Totalizador
@param			cFilEvt		-	Filial do Registro no TAF
@param			cPeriodo	-	Período de Referência das Informações
@param			cCPF		-	CPF do Registro no TAF
@param			cRecibo		-	Recibo do Registro no TAF
@param			cFilMatriz	-	Filial Matriz
@param			cMotDes		-	Motivo de afastamento
/*/
//---------------------------------------------------------------------
Static Function Insert5003( cEvento as Character, cFilEvt as Character, cPeriodo as Character,; 
							cCPF as Character, cRecibo as Character, cFilMatriz as Character, cMotDes as Character )

	Local aAnalitico  as Array
	Local cAliasQry   as Character
	Local cCPFTrab    as Character
	Local cFilQry     as Character
	Local cIndApu     as Character
	Local cNome       as Character
	Local cNrReci     as Character
	Local cPerApu     as Character
	Local cQuery      as Character
	Local nPosValores as Numeric
	Local oInfoRPT    as Object

	Default cCPF       := ""
	Default cEvento    := ""
	Default cFilEvt    := ""
	Default cFilMatriz := ""
	Default cMotDes    := ""
	Default cPeriodo   := ""
	Default cRecibo    := ""

	aAnalitico  := {}
	cAliasQry   := GetNextAlias()
	cCPFTrab    := ""
	cFilQry     := ""
	cIndApu     := ""
	cNome       := ""
	cNrReci     := ""
	cPerApu     := ""
	cQuery      := ""
	nPosValores := 0
	oInfoRPT    := Nil

	If Len( AllTrim( cPeriodo ) ) == 4
		cFilQry := IIf( SToD( cPeriodo + "12" + "01" ) >= GetNewPar( "MV_TOTEXDT", SToD( "20991231" ) ), cFilEvt, cFilMatriz )
	Else
		cFilQry := IIf( SToD( SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) + "01" ) >= GetNewPar( "MV_TOTEXDT", SToD( "20991231" ) ), cFilEvt, cFilMatriz )
	EndIf

	cQuery := " SELECT V2P.V2P_CPF, V2P.V2P_NOME, V2P.V2P_PERAPU, V2P.V2P_NRRECI "
	cQuery += "	 , V2Q.V2Q_TPINSC TPINSC, V2Q.V2Q_NRINSC NRINSC, V2Q.V2Q_CODLOT CODLOT "
	cQuery += "	 , V2R.V2R_MATRIC MATRIC, C87.C87_CODIGO CODCAT, V26.V26_CODIGO TPVALOR "
	cQuery += "	 , V2S.V2S_VLFGTS VALOR, V2S.V2S_VLDPS DEPVALOR "

	cQuery += " FROM " + RetSqlName( "V2P" ) + " V2P "

	cQuery += " INNER JOIN " + RetSqlName( "V2Q" ) + " V2Q "
	cQuery += "  ON V2Q.V2Q_FILIAL = V2P.V2P_FILIAL "
	cQuery += "  AND V2Q.V2Q_ID = V2P.V2P_ID "
	cQuery += "  AND V2Q.V2Q_VERSAO = V2P.V2P_VERSAO "
	cQuery += "  AND V2Q.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName( "V2R" ) + " V2R "
	cQuery += "  ON V2R.V2R_FILIAL = V2Q.V2Q_FILIAL "
	cQuery += "  AND V2R.V2R_ID = V2Q.V2Q_ID "
	cQuery += "  AND V2R.V2R_VERSAO = V2Q.V2Q_VERSAO "
	cQuery += "  AND V2R.V2R_TPINSC = V2Q.V2Q_TPINSC "
	cQuery += "  AND V2R.V2R_NRINSC = V2Q.V2Q_NRINSC "
	cQuery += "  AND V2R.V2R_CODLOT = V2Q.V2Q_CODLOT "
	cQuery += "  AND V2R.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "V2S" ) + " V2S "
	cQuery += "  ON V2S.V2S_FILIAL = V2R.V2R_FILIAL "
	cQuery += "  AND V2S.V2S_ID = V2R.V2R_ID "
	cQuery += "  AND V2S.V2S_VERSAO = V2R.V2R_VERSAO "
	cQuery += "  AND V2S.V2S_TPINSC = V2R.V2R_TPINSC "
	cQuery += "  AND V2S.V2S_NRINSC = V2R.V2R_NRINSC "
	cQuery += "  AND V2S.V2S_CODLOT = V2R.V2R_CODLOT "
	cQuery += "  AND V2S.V2S_MATRIC = V2R.V2R_MATRIC "
	cQuery += "  AND V2S.V2S_CODCAT = V2R.V2R_CODCAT "
	cQuery += "  AND V2S.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "C87" ) + " C87 "
	cQuery += " ON C87.C87_FILIAL = '" + xFilial("C87") + "' "
	cQuery += " AND C87.C87_ID = V2R.V2R_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "V26" ) + " V26 "
	cQuery += " ON V26.V26_FILIAL = '" + xFilial("V26") + "' "
	cQuery += " AND V26.V26_ID = V2S.V2S_IDTPVL "
	cQuery += " AND V26.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE V2P.V2P_FILIAL = '" + xFilial("V2P") + "' "
	cQuery += "  AND V2P.V2P_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V2P.V2P_CPF = '" + cCPF + "' "
	cQuery += "  AND V2P.V2P_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND V2P.V2P_ATIVO = '1' "
	cQuery += "  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += " UNION ALL "

	cQuery += " SELECT V2P.V2P_CPF, V2P.V2P_NOME, V2P.V2P_PERAPU, V2P.V2P_NRRECI "
	cQuery += "	 , V2Q.V2Q_TPINSC, V2Q.V2Q_NRINSC, V2Q.V2Q_CODLOT "
	cQuery += "	 , V2R.V2R_MATRIC, C87.C87_CODIGO "
	cQuery += "	 , V26.V26_CODIGO, V2U.V2U_VLFGTS "
	cQuery += "	 , 0 "

	cQuery += " FROM " + RetSqlName( "V2P" ) + " V2P "

	cQuery += " INNER JOIN " + RetSqlName( "V2Q" ) + " V2Q "
	cQuery += "  ON V2Q.V2Q_FILIAL = V2P.V2P_FILIAL "
	cQuery += "  AND V2Q.V2Q_ID = V2P.V2P_ID "
	cQuery += "  AND V2Q.V2Q_VERSAO = V2P.V2P_VERSAO "
	cQuery += "  AND V2Q.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName( "V2R" ) + " V2R "
	cQuery += "  ON V2R.V2R_FILIAL = V2Q.V2Q_FILIAL "
	cQuery += "  AND V2R.V2R_ID = V2Q.V2Q_ID "
	cQuery += "  AND V2R.V2R_VERSAO = V2Q.V2Q_VERSAO "
	cQuery += "  AND V2R.V2R_TPINSC = V2Q.V2Q_TPINSC "
	cQuery += "  AND V2R.V2R_NRINSC = V2Q.V2Q_NRINSC "
	cQuery += "  AND V2R.V2R_CODLOT = V2Q.V2Q_CODLOT "
	cQuery += "  AND V2R.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName( "V2T" ) + " V2T "
	cQuery += "  ON V2T.V2T_FILIAL = V2R.V2R_FILIAL "
	cQuery += "  AND V2T.V2T_ID = V2R.V2R_ID "
	cQuery += "  AND V2T.V2T_VERSAO = V2R.V2R_VERSAO "
	cQuery += "  AND V2T.V2T_TPINSC = V2R.V2R_TPINSC "
	cQuery += "  AND V2T.V2T_NRINSC = V2R.V2R_NRINSC "
	cQuery += "  AND V2T.V2T_CODLOT = V2R.V2R_CODLOT "
	cQuery += "  AND V2T.V2T_MATRIC = V2R.V2R_MATRIC "
	cQuery += "  AND V2T.V2T_CODCAT = V2R.V2R_CODCAT "
	cQuery += "  AND V2T.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "V2U" ) + " V2U "
	cQuery += "  ON V2U.V2U_FILIAL = V2T.V2T_FILIAL "
	cQuery += "  AND V2U.V2U_ID = V2T.V2T_ID "
	cQuery += "  AND V2U.V2U_VERSAO = V2T.V2T_VERSAO "
	cQuery += "  AND V2U.V2U_TPINSC = V2T.V2T_TPINSC "
	cQuery += "  AND V2U.V2U_NRINSC = V2T.V2T_NRINSC "
	cQuery += "  AND V2U.V2U_CODLOT = V2T.V2T_CODLOT "
	cQuery += "  AND V2U.V2U_MATRIC = V2T.V2T_MATRIC "
	cQuery += "  AND V2U.V2U_CODCAT = V2T.V2T_CODCAT "
	cQuery += "  AND V2U.V2U_PERREF = V2T.V2T_PERREF "
	cQuery += "  AND V2U.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "C87" ) + " C87 "
	cQuery += " ON C87.C87_FILIAL = '" + xFilial("C87") + "' "
	cQuery += " AND C87.C87_ID = V2R.V2R_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "V26" ) + " V26 "
	cQuery += " ON V26.V26_FILIAL = '" + xFilial("V26") + "' "
	cQuery += " AND V26.V26_ID = V2U.V2U_IDTPVL "
	cQuery += " AND V26.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE V2P.V2P_FILIAL = '" + xFilial("V2P") + "' "
	cQuery += "  AND V2P.V2P_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V2P.V2P_CPF = '" + cCPF + "' "
	cQuery += "  AND V2P.V2P_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND V2P.V2P_ATIVO = '1' "
	cQuery += "  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += " UNION ALL "

	cQuery += " SELECT V2P.V2P_CPF, V2P.V2P_NOME, V2P.V2P_PERAPU, V2P.V2P_NRRECI "
	cQuery += "	 , '', '', '' "
	cQuery += "	 , V2V.V2V_MATRIC, C87.C87_CODIGO "
	cQuery += "	 , V27.V27_CODIGO, V2W.V2W_VLFGTS "
	cQuery += "	 , 0 "

	cQuery += " FROM " + RetSqlName( "V2P" ) + " V2P "

	cQuery += " INNER JOIN " + RetSqlName( "V2V" ) + " V2V "
	cQuery += "   ON V2V.V2V_FILIAL = V2P.V2P_FILIAL "
	cQuery += "  AND V2V.V2V_ID = V2P.V2P_ID "
	cQuery += "  AND V2V.V2V_VERSAO = V2P.V2P_VERSAO "
	cQuery += "  AND V2V.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "V2W" ) + " V2W "
	cQuery += "   ON V2W.V2W_FILIAL = V2V.V2V_FILIAL "
	cQuery += "  AND V2W.V2W_ID = V2V.V2V_ID "
	cQuery += "  AND V2W.V2W_VERSAO = V2V.V2V_VERSAO "
	cQuery += "  AND V2W.V2W_MATRIC = V2V.V2V_MATRIC "
	cQuery += "  AND V2W.V2W_CODCAT = V2V.V2V_CODCAT "
	cQuery += "  AND V2W.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "C87" ) + " C87 "
	cQuery += "  ON C87.C87_FILIAL = '" + xFilial("C87") + "' "
	cQuery += " AND C87.C87_ID = V2V.V2V_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "V27" ) + " V27 "
	cQuery += "  ON V27.V27_FILIAL = '" + xFilial("V27") + "' "
	cQuery += " AND V27.V27_ID = V2W.V2W_IDTPDP "
	cQuery += " AND V27.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE V2P.V2P_FILIAL = '" + xFilial("V2P") + "' "
	cQuery += "  AND V2P.V2P_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V2P.V2P_CPF = '" + cCPF + "' "
	cQuery += "  AND V2P.V2P_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND V2P.V2P_ATIVO = '1' "
	cQuery += "  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += " UNION ALL "

	cQuery += " SELECT V2P.V2P_CPF, V2P.V2P_NOME, V2P.V2P_PERAPU, V2P.V2P_NRRECI "
	cQuery += "	 , '', '', '' "
	cQuery += "	 , V2V.V2V_MATRIC, C87.C87_CODIGO "
	cQuery += "	 , V27.V27_CODIGO, V2Y.V2Y_VLFGTS "
	cQuery += "	 , 0 "

	cQuery += " FROM " + RetSqlName( "V2P" ) + " V2P "

	cQuery += " INNER JOIN " + RetSqlName( "V2V" ) + " V2V "
	cQuery += "   ON V2V.V2V_FILIAL = V2P.V2P_FILIAL "
	cQuery += "  AND V2V.V2V_ID = V2P.V2P_ID "
	cQuery += "  AND V2V.V2V_VERSAO = V2P.V2P_VERSAO "
	cQuery += "  AND V2V.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName( "V2X" ) + " V2X "
	cQuery += "   ON V2X.V2X_FILIAL = V2V.V2V_FILIAL "
	cQuery += "  AND V2X.V2X_ID = V2V.V2V_ID "
	cQuery += "  AND V2X.V2X_VERSAO = V2V.V2V_VERSAO "
	cQuery += "  AND V2X.V2X_MATRIC = V2V.V2V_MATRIC "
	cQuery += "  AND V2X.V2X_CODCAT = V2V.V2V_CODCAT "
	cQuery += "  AND V2X.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "V2Y" ) + " V2Y "
	cQuery += "   ON V2Y.V2Y_FILIAL = V2X.V2X_FILIAL "
	cQuery += "  AND V2Y.V2Y_ID = V2X.V2X_ID "
	cQuery += "  AND V2Y.V2Y_VERSAO = V2X.V2X_VERSAO "
	cQuery += "  AND V2Y.V2Y_MATRIC = V2X.V2X_MATRIC "
	cQuery += "  AND V2Y.V2Y_CODCAT = V2X.V2X_CODCAT "
	cQuery += "  AND V2Y.V2Y_PERREF = V2X.V2X_PERREF "
	cQuery += "  AND V2Y.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "C87" ) + " C87 "
	cQuery += "  ON C87.C87_FILIAL = '" + xFilial("C87") + "' "
	cQuery += " AND C87.C87_ID = V2V.V2V_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName( "V27" ) + " V27 "
	cQuery += "  ON V27.V27_FILIAL = '" + xFilial("V27") + "' "
	cQuery += " AND V27.V27_ID = V2Y.V2Y_IDTPDP "
	cQuery += " AND V27.D_E_L_E_T_ = ' ' "
	
	cQuery += " WHERE V2P.V2P_FILIAL = '" + xFilial("V2P") + "' "
	cQuery += "  AND V2P.V2P_PERAPU = '" + cPeriodo + "' "
	cQuery += "  AND V2P.V2P_CPF = '" + cCPF + "' "
	cQuery += "  AND V2P.V2P_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND V2P.V2P_ATIVO = '1' "
	cQuery += "  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias (cAliasQry)

	(cAliasQry)->(DBGoTop())

	If !(cAliasQry)->(EOF())

		While !(cAliasQry)->(EOF())

			If Len(AllTrim(cPeriodo)) == 4
				cIndApu := "2"
				cPerApu := AllTrim((cAliasQry)->V2P_PERAPU)
			Else
				cIndApu := "1"
				cPerApu := SubStr((cAliasQry)->V2P_PERAPU, 3, 4) + SubStr((cAliasQry)->V2P_PERAPU, 1, 2)
			EndIf

			cCPFTrab	:= AllTrim((cAliasQry)->V2P_CPF)
			cNome		:= AllTrim((cAliasQry)->V2P_NOME)
			cNrReci 	:= AllTrim((cAliasQry)->V2P_NRRECI) 

			tafDefAAnalitco(@aAnalitico)
			nPosValores := Len(aAnalitico)

			aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim((cAliasQry)->MATRIC)
			aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim((cAliasQry)->CODCAT)
			aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim((cAliasQry)->TPINSC)
			aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim((cAliasQry)->NRINSC)
			aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim((cAliasQry)->CODLOT)
			aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= ""
			aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= ""
			aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= ""
			aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= ""
			aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= ""
			aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= ""
			aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= AllTrim((cAliasQry)->TPVALOR)
			aAnalitico[nPosValores][ANALITICO_VALOR]				:= (cAliasQry)->VALOR
			aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:= cMotDes

			If lLaySimplif
				aAnalitico[nPosValores][ANALITICO_VALOR_DEP] :=	(cAliasQry)->DEPVALOR 
			EndIf

			(cAliasQry)->(DBSkip())

		EndDo
		
		InfoRPTObj(cIndApu, cPerApu, cCPFTrab, cNome, aAnalitico, cNrReci, @oInfoRPT)

		oReport:UpSert(cEvento, "5", cFilQry, oInfoRPT)

	EndIf

	(cAliasQry)->(DBCloseArea())

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} SetIncPerc
@type			function
@description	Incrementa o progresso realizado.
@author			Felipe C. Seolin
@since			10/06/2019
@version		1.0
@param			oRunCharge	-	Objeto do FWMsgRun
@param			cEtapa		-	Etapa em curso de execução
@param			nQtdTotal	-	Quantidade total de registros a processar
@param			nQtdProc	-	Quantidade de registros processados
/*/
//---------------------------------------------------------------------
Static Function SetIncPerc( oRunCharge, cEtapa, nQtdTotal, nQtdProc )

	Local cMessage	:=	""
	Local cPercent	:=	cValToChar( Int( ( nQtdProc / nQtdTotal ) * 100 ) )

	If cEtapa == "S-1200"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 1/3", "Carregando histórico", "Evento", "Folha", cPercent } )
	ElseIf cEtapa == "S-2299"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 2/3", "Carregando histórico", "Evento", "Desligamento", cPercent } )
	ElseIf cEtapa == "S-2399"
		cMessage := I18N( "#1 - #2 - #3 #4 - Progresso: #5%", { "Etapa 3/3", "Carregando histórico", "Evento", "Término TSV", cPercent } )
	EndIf

	oRunCharge:cCaption := cMessage
	ProcessMessages()

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCodCat
@type			function
@description	Busca a categoria do trabalhador se houver alteração de cadastro ( S-2206 / S-2306 ).
@author			Felipe C. Seolin
@since			10/06/2019
@version		1.0
@param			cNomEve		-	Nome do Evento
@param			cFilTrb		-	Filial do Trabalhador posicionado
@param			cID			-	ID do Trabalhador posicionado
@param			cPerApu		-	Data informada no Pergunte utilizado no programa no formato AAAAMM
@return			cRet		-	Categoria do Trabalhador
/*/
//---------------------------------------------------------------------
Static Function GetCodCat(cNomEve as Character, cFilTrb as Character, cID as Character, cPerApu as Character)

	Local cAliasQry as Character
	Local cFrom     as Character
	Local cPeriodo  as Character
	Local cRet      as Character
	Local cSelect   as Character
	Local cWhere    as Character

	Default cFilTrb := ""
	Default cID     := ""
	Default cNomEve := ""
	Default cPerApu := ""

	cAliasQry := GetNextAlias()
	cFrom     := ""
	cPeriodo  := AllTrim(cPerApu)
	cRet      := ""
	cSelect   := ""
	cWhere    := ""

	If !Empty(cNomEve) .And. AllTrim(cNomEve) <> "TAUTO"

		If cNomEve == "S2200"

			cSelect := "T1V_CODCAT"
			cFrom 	:= RetSqlName("T1V") + " T1V "

			cWhere := " T1V.T1V_FILIAL = '" + xFilial("T1V", cFilTrb) + "' "
			cWhere += " AND T1V.T1V_ID = '" + cID + "' "

			If !Empty(cPeriodo)

				If Len(cPeriodo) == 4
					cWhere += " AND T1V.T1V_DTALT <= '" + cPeriodo + "12" + "31" + "' "
				Else
					cWhere += " AND T1V.T1V_DTALT <= '" + cPeriodo + "31" + "' "
				EndIf

			EndIf

			cWhere += " AND T1V.D_E_L_E_T_ = ' ' "

		ElseIf cNomEve == "S2300"

			cSelect := "T0F_CATAV"
			cFrom	:= RetSqlName("T0F") + " T0F "

			cWhere := " T0F.T0F_FILIAL = '" + xFilial("T0F", cFilTrb) + "' "
			cWhere += " AND T0F.T0F_ID = '" + cID + "' "

			If !Empty(cPeriodo)

				If Len(cPeriodo) == 4
					cWhere += " AND T0F.T0F_DTALT <= '" + cPeriodo + "12" + "31" + "' "
				Else
					cWhere += " AND T0F.T0F_DTALT <= '" + cPeriodo + "31" + "' "
				EndIf

			EndIf

			cWhere += " AND T0F.D_E_L_E_T_ = ' ' "

		EndIf

		cSelect	:= "%" + cSelect + "%"
		cFrom	:= "%" + cFrom + "%"
		cWhere	:= "%" + cWhere + "%"

		BeginSql Alias cAliasQry

			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%
				
		EndSql

		If !(cAliasQry)->(EOF())

			If cNomEve == "S2200"
				cRet := (cAliasQry)->T1V_CODCAT
			ElseIf cNomEve == "S2300"
				cRet := (cAliasQry)->T0F_CATAV
			EndIf

		EndIf

		(cAliasQry)->(DBCloseArea())

	EndIf

Return cRet

//---------------------------------------------------------------------
/*/{Protheus.doc} RptFull
@type			function
@description	Verifica a necessidade de carga na tabela V3N.
@author			Felipe C. Seolin
@since			06/08/2019
@version		1.0
@param			cPeriodo	-	Período de referência das informações
@param			cCPF		-	CPF selecionado como filtro de processamento
@return			lRet		-	Indica se a tabela V3N já possui as informações indicadas nos parâmetros
/*/
//---------------------------------------------------------------------
Static Function RptFull( cPeriodo as Character, cCPF as Character )
	
	Local cAliasQry as Character
	Local cQuery    as Character
	Local lRet      as Logical
	Local nQtdMov   as Numeric
	Local nQtdRpt   as Numeric

	Default cCPF     := ""
	Default cPeriodo := ""

	cAliasQry := ""
	cQuery    := ""
	lRet      := .F.
	nQtdMov   := 0
	nQtdRpt   := 0

	//---------------------------------------------------------------------
	// Quantidade de verbas do evento S-1200
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM ( "
	cQuery += "			SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO "
	cQuery += "			FROM " + RetSqlName( "C91" ) + " C91 "
	cQuery += "			INNER JOIN " + RetSqlName( "C9M" ) + " C9M "
	cQuery += "			   ON C9M.C9M_FILIAL = C91.C91_FILIAL "
	cQuery += "			  AND C9M.C9M_ID = C91.C91_ID "
	cQuery += "			  AND C9M.C9M_VERSAO = C91.C91_VERSAO "
	cQuery += "			  AND C9M.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If !Empty(cCPF)

		cQuery += "		AND (EXISTS (SELECT T3A.R_E_C_N_O_ FROM " + RetSqlName("T3A") + " T3A "
		cQuery += "			  WHERE T3A.T3A_FILIAL = C91.C91_FILIAL "
		cQuery += "			  	AND T3A.T3A_ID = C91.C91_TRABAL "
		cQuery += "			  	AND T3A.T3A_CPF = '" + AllTrim(cCPF) + "' "
		cQuery += "			  	AND T3A.D_E_L_E_T_ = ' ') "
		cQuery += "		OR EXISTS (SELECT C9V.R_E_C_N_O_ FROM " + RetSqlName("C9V") + " C9V "
		cQuery += "			  WHERE C9V.C9V_FILIAL = C91.C91_FILIAL "
		cQuery += "			  	AND C9V.C9V_ID = C91.C91_TRABAL "
		cQuery += "			  	AND C9V.C9V_CPF = '" + AllTrim(cCPF) + "' "
		cQuery += "			  	AND C9V.D_E_L_E_T_ = ' ')) "

	EndIf
	
	If Len( AllTrim( cPeriodo ) ) == 4
		cQuery += "			  AND C91.C91_PERAPU = '" + cPeriodo +  "' "
	Else
		cQuery += "			  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	cQuery += "			  AND C91.C91_NOMEVE = 'S1200' "
	cQuery += "			  AND C91.C91_ATIVO = '1' "
	cQuery += "			  AND C91.C91_EVENTO <> 'E' "
	cQuery += "			  AND C91.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT C91.C91_FILIAL, C91.C91_ID, C91.C91_VERSAO "
	cQuery += "			FROM " + RetSqlName( "C91" ) + " C91 "
	cQuery += "			INNER JOIN " + RetSqlName( "C9R" ) + " C9R "
	cQuery += "			   ON C9R.C9R_FILIAL = C91.C91_FILIAL "
	cQuery += "			  AND C9R.C9R_ID = C91.C91_ID "
	cQuery += "			  AND C9R.C9R_VERSAO = C91.C91_VERSAO "
	cQuery += "			  AND C9R.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE C91.C91_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If !Empty(cCPF)

		cQuery += "		AND (EXISTS (SELECT T3A.R_E_C_N_O_ FROM " + RetSqlName("T3A") + " T3A "
		cQuery += "			  WHERE T3A.T3A_FILIAL = C91.C91_FILIAL "
		cQuery += "			  	AND T3A.T3A_ID = C91.C91_TRABAL "
		cQuery += "			  	AND T3A.T3A_CPF = '" + AllTrim(cCPF) + "' "
		cQuery += "			  	AND T3A.D_E_L_E_T_ = ' ') "
		cQuery += "		OR EXISTS (SELECT C9V.R_E_C_N_O_ FROM " + RetSqlName("C9V") + " C9V "
		cQuery += "			  WHERE C9V.C9V_FILIAL = C91.C91_FILIAL "
		cQuery += "			  	AND C9V.C9V_ID = C91.C91_TRABAL "
		cQuery += "			  	AND C9V.C9V_CPF = '" + AllTrim(cCPF) + "' "
		cQuery += "			  	AND C9V.D_E_L_E_T_ = ' ')) "

	EndIf
	
	If Len( AllTrim( cPeriodo ) ) == 4
		cQuery += "			  AND C91.C91_PERAPU = '" + AllTrim( cPeriodo ) +  "' "
	Else
		cQuery += "			  AND C91.C91_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	cQuery += "			  AND C91.C91_NOMEVE = 'S1200' "
	cQuery += "			  AND C91.C91_ATIVO = '1' "
	cQuery += "			  AND C91.C91_EVENTO <> 'E' "
	cQuery += "			  AND C91.D_E_L_E_T_ = ' ' "
	cQuery += " ) FOLHA "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdMov += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Quantidade de verbas do evento S-2299
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM ( "
	cQuery += "			SELECT CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO "
	cQuery += "			FROM " + RetSqlName( "CMD" ) + " CMD "
	cQuery += "			INNER JOIN " + RetSqlName( "T05" ) + " T05 "
	cQuery += "			   ON T05.T05_FILIAL = CMD.CMD_FILIAL "
	cQuery += "			  AND T05.T05_ID = CMD.CMD_ID "
	cQuery += "			  AND T05.T05_VERSAO = CMD.CMD_VERSAO "
	cQuery += "			  AND T05.D_E_L_E_T_ = ' ' "

	//Filtro por CPF
	If !Empty( cCPF )

		cQuery += "			INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cQuery += "			   ON C9V.C9V_FILIAL = CMD.CMD_FILIAL "
		cQuery += "			  AND C9V.C9V_ID = CMD.CMD_FUNC "
		cQuery += "			  AND C9V.C9V_CPF = '" + AllTrim( cCPF ) + "' "
		cQuery += "			  AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery += "			WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Len(cPeriodo) == 4

		cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + cPeriodo + "01" + "01" + "' "
		cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

	Else

		cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
		cQuery += "			  AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

	EndIf

	cQuery += "			  AND CMD.CMD_ATIVO = '1' "
	cQuery += "			  AND CMD.CMD_EVENTO <> 'E' "
	cQuery += "			  AND CMD.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT CMD.CMD_FILIAL, CMD.CMD_ID, CMD.CMD_VERSAO "
	cQuery += "			FROM " + RetSqlName( "CMD" ) + " CMD "
	cQuery += "			INNER JOIN " + RetSqlName( "T5S" ) + " T5S "
	cQuery += "			   ON T5S.T5S_FILIAL = CMD.CMD_FILIAL "
	cQuery += "			  AND T5S.T5S_ID = CMD.CMD_ID "
	cQuery += "			  AND T5S.T5S_VERSAO = CMD.CMD_VERSAO "
	cQuery += "			  AND T5S.D_E_L_E_T_ = ' ' "

	//Filtro por CPF
	If !Empty( cCPF )

		cQuery += "			INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cQuery += "			   ON C9V.C9V_FILIAL = CMD.CMD_FILIAL "
		cQuery += "			  AND C9V.C9V_ID = CMD.CMD_FUNC "
		cQuery += "			  AND C9V.C9V_CPF = '" + AllTrim( cCPF ) + "' "
		cQuery += "			  AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery += "			WHERE CMD.CMD_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Len(cPeriodo) == 4

		cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + cPeriodo + "01" + "01" + "' "
		cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

	Else

		cQuery += "			  AND CMD.CMD_DTDESL BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
		cQuery += "			  AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

	EndIf

	cQuery += "			  AND CMD.CMD_ATIVO = '1' "
	cQuery += "			  AND CMD.CMD_EVENTO <> 'E' "
	cQuery += "			  AND CMD.D_E_L_E_T_ = ' ' "
	cQuery += " ) DESLIGAMENTO "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdMov += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Quantidade de verbas do evento S-2399
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM " + RetSqlName( "T92" ) + " T92 "
	cQuery += " INNER JOIN " + RetSqlName( "CMK" ) + " CMK "
	cQuery += "   ON CMK.CMK_FILIAL = T92.T92_FILIAL "
	cQuery += "  AND CMK.CMK_ID = T92.T92_ID "
	cQuery += "  AND CMK.CMK_VERSAO = T92.T92_VERSAO "
	cQuery += "  AND CMK.D_E_L_E_T_ = ' ' "

	//Filtro por CPF
	If !Empty( cCPF )

		cQuery += " INNER JOIN " + RetSqlName( "C9V" ) + " C9V "
		cQuery += "   ON C9V.C9V_FILIAL = T92.T92_FILIAL "
		cQuery += "  AND C9V.C9V_ID = T92.T92_TRABAL "
		cQuery += "  AND C9V.C9V_CPF = '" + AllTrim( cCPF ) + "' "
		cQuery += "  AND C9V.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery += " WHERE T92.T92_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Len(cPeriodo) == 4

		cQuery += "			  AND T92.T92_DTERAV BETWEEN '" + cPeriodo + "01" + "01" + "' "
		cQuery += "			  AND '" + cPeriodo + "12" + "31" + "' "

	Else

		cQuery += "			  AND T92.T92_DTERAV BETWEEN '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01" + "' "
		cQuery += "			  AND '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "31" + "' "

	EndIf

	cQuery += "  AND T92.T92_ATIVO = '1' "
	cQuery += "  AND T92.T92_EVENTO <> 'E' "
	cQuery += "  AND T92.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdMov += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Quantidade de verbas do evento S-5003
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM ( "
	cQuery += "			SELECT V2P.V2P_FILIAL, V2P.V2P_ID, V2P.V2P_VERSAO "
	cQuery += "			FROM " + RetSqlName( "V2P" ) + " V2P "
	cQuery += "			INNER JOIN " + RetSqlName( "V2S" ) + " V2S "
	cQuery += "			   ON V2S.V2S_FILIAL = V2P.V2P_FILIAL "
	cQuery += "			  AND V2S.V2S_ID = V2P.V2P_ID "
	cQuery += "			  AND V2S.V2S_VERSAO = V2P.V2P_VERSAO "
	cQuery += "			  AND V2S.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE V2P.V2P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery += "			  AND V2P.V2P_PERAPU = '" + AllTrim( cPeriodo ) +  "' "

	If !Empty( cCPF )
		cQuery += "			  AND V2P.V2P_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "			  AND V2P.V2P_ATIVO = '1' "
	cQuery += "			  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT V2P.V2P_FILIAL, V2P.V2P_ID, V2P.V2P_VERSAO "
	cQuery += "			FROM " + RetSqlName( "V2P" ) + " V2P "
	cQuery += "			INNER JOIN " + RetSqlName( "V2U" ) + " V2U "
	cQuery += "			   ON V2U.V2U_FILIAL = V2P.V2P_FILIAL "
	cQuery += "			  AND V2U.V2U_ID = V2P.V2P_ID "
	cQuery += "			  AND V2U.V2U_VERSAO = V2P.V2P_VERSAO "
	cQuery += "			  AND V2U.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE V2P.V2P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery += "			  AND V2P.V2P_PERAPU = '" + AllTrim( cPeriodo ) +  "' "

	If !Empty( cCPF )
		cQuery += "			  AND V2P.V2P_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "			  AND V2P.V2P_ATIVO = '1' "
	cQuery += "			  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT V2P.V2P_FILIAL, V2P.V2P_ID, V2P.V2P_VERSAO "
	cQuery += "			FROM " + RetSqlName( "V2P" ) + " V2P "
	cQuery += "			INNER JOIN " + RetSqlName( "V2W" ) + " V2W "
	cQuery += "			   ON V2W.V2W_FILIAL = V2P.V2P_FILIAL "
	cQuery += "			  AND V2W.V2W_ID = V2P.V2P_ID "
	cQuery += "			  AND V2W.V2W_VERSAO = V2P.V2P_VERSAO "
	cQuery += "			  AND V2W.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE V2P.V2P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery += "			  AND V2P.V2P_PERAPU = '" + AllTrim( cPeriodo ) +  "' "

	If !Empty( cCPF )
		cQuery += "			  AND V2P.V2P_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "			  AND V2P.V2P_ATIVO = '1' "
	cQuery += "			  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += "			UNION ALL "

	cQuery += "			SELECT V2P.V2P_FILIAL, V2P.V2P_ID, V2P.V2P_VERSAO "
	cQuery += "			FROM " + RetSqlName( "V2P" ) + " V2P "
	cQuery += "			INNER JOIN " + RetSqlName( "V2Y" ) + " V2Y "
	cQuery += "			   ON V2Y.V2Y_FILIAL = V2P.V2P_FILIAL "
	cQuery += "			  AND V2Y.V2Y_ID = V2P.V2P_ID "
	cQuery += "			  AND V2Y.V2Y_VERSAO = V2P.V2P_VERSAO "
	cQuery += "			  AND V2Y.D_E_L_E_T_ = ' ' "
	cQuery += "			WHERE V2P.V2P_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "
	cQuery += "			  AND V2P.V2P_PERAPU = '" + AllTrim( cPeriodo ) +  "' "

	If !Empty( cCPF )
		cQuery += "			  AND V2P.V2P_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "			  AND V2P.V2P_ATIVO = '1' "
	cQuery += "			  AND V2P.D_E_L_E_T_ = ' ' "

	cQuery += " ) TOTALIZADOR "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdMov += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Quantidade de verbas na tabela de Movimentação de Remunerações
	//---------------------------------------------------------------------
	cAliasQry := GetNextAlias()

	cQuery := " SELECT COUNT(*) QUANTIDADE "
	cQuery += " FROM " + RetSqlName( "V3N" ) + " V3N "
	cQuery += " WHERE V3N.V3N_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cFilSel + " FILIAIS ) "

	If Len( AllTrim( cPeriodo ) ) == 4
		cQuery += "  AND V3N.V3N_PERAPU = '" + cPeriodo +  "' "
	Else
		cQuery += "  AND V3N.V3N_PERAPU = '" + SubStr( cPeriodo, 3, 4 ) + SubStr( cPeriodo, 1, 2 ) +  "' "
	EndIf

	If !Empty( cCPF )
		cQuery += "  AND V3N.V3N_CPF = '" + AllTrim( cCPF ) + "' "
	EndIf

	cQuery += "  AND ( V3N.V3N_ORIGEM = '2' OR ( V3N.V3N_ORIGEM = '5' AND V3N.V3N_VALOR > 0 ) ) "
	cQuery += "  AND V3N.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias (cAliasQry)

	( cAliasQry )->( DBGoTop() )

	If ( cAliasQry )->( !Eof() )
		nQtdRpt += ( cAliasQry )->QUANTIDADE
	EndIf

	( cAliasQry )->( DBCloseArea() )

	//---------------------------------------------------------------------
	// Comparação de movimentação com dados gravados para relatório
	//---------------------------------------------------------------------
	lRet := nQtdMov == nQtdRpt

Return( lRet )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
@type			static function
@description	Retorna filial conforme o comportilhamento da tabela
@author			Melkz Siqueira
@since			17/11/2022
@version		1.0
@param			cAliasEve - Alias do evento
@param			aFilial	- Array com as filiais
@return			TAFCacheFil() - Nome da tabela temporária em cache
/*/
//---------------------------------------------------------------------
Static Function GetFilial( cAliasEve as Character, aFilial as Array )

	Local aFilSel as Array
	Local nI      as Numeric

	Default aFilial   := {}
	Default cAliasEve := ""

	aFilSel := {}
	nI		:= 0

	For nI := 1 To Len(aFilial)
		AAdd(aFilSel, xFilial(cAliasEve, aFilial[nI]))
	Next

Return TAFCacheFil(Nil, aFilSel, .T.)

//---------------------------------------------------------------------
/*/{Protheus.doc} Insert5001
@type			function
@description	Função responsável por coletar as informações do Evento S-5001 no retorno do Governo.
@author			Melkz Siqueira
@since			21/11/2022
@version		1.0
@param			cEvento		-	Evento de Origem do Totalizador
@param			cFilEvt		-	Filial do Registro no TAF
@param			cIndApu		-	Indicativo de apuração
@param			cPeriodo	-	Período de Referência das Informações
@param			cCPF		-	CPF do Registro no TAF
@param			cNome		-	Nome do trabalhador no TAF
@param			cRecibo		-	Recibo do Registro no TAF
@param			cFilMatriz	-	Filial Matriz
@param			cMotDes		- 	Motivo de afastamento
/*/
//---------------------------------------------------------------------
Static Function Insert5001( cEvento as character, cFilEvt as character, cIndApu as character,; 
							cPeriodo as character, cCPF as character, cNome as character, cRecibo as character,;
							cFilMatriz as character, cMotDes as character )

	Local aAnalitico  as array
	Local cAliasQry   as character
	Local cCPFTrab    as character
	Local cFilQry     as character
	Local cNrReci     as character
	Local cPerApu     as character
	Local cQuery      as character
	Local nPosValores as numeric
	Local oInfoRPT    as object
	
	Default cCPF       := ""
	Default cEvento    := ""
	Default cFilEvt    := ""
	Default cFilMatriz := ""
	Default cIndApu    := ""
	Default cMotDes    := ""
	Default cNome      := ""
	Default cPeriodo   := ""
	Default cRecibo    := ""

	aAnalitico  := {}
	cAliasQry   := GetNextAlias()
	cCPFTrab    := ""
	cFilQry     := ""
	cNrReci     := ""
	cPerApu     := ""
	cQuery      := ""
	nPosValores := 0
	oInfoRPT    := Nil

	If Len(AllTrim(cPeriodo)) == 4
		cFilQry := IIf(SToD(cPeriodo + "12" + "01") >= SuperGetMV("MV_TOTEXDT", .F., SToD("20991231")), cFilEvt, cFilMatriz)
	Else
		cFilQry := IIf(SToD(SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "01") >= SuperGetMV("MV_TOTEXDT", .F., SToD("20991231")), cFilEvt, cFilMatriz)
	EndIf

	cQuery := "SELECT DISTINCT T2M.T2M_CPFTRB, T2M.T2M_PERAPU, T2M.T2M_NRRECI, "
	cQuery += "T2M.T2M_INDAPU, C92.C92_NRINSC, C92.C92_TPINSC, C99.C99_CODIGO, "
	cQuery += "T2Q.T2Q_MATRIC, T2Q.T2Q_CODCAT, C87.C87_CODIGO, T2T.T2T_CODIGO, "
	cQuery += "T2R.T2R_INDDEC, T2R.T2R_VALOR, T2P.T2P_ESTABE, T2P.T2P_LOTACA "

	cQuery += "FROM " + RetSqlName("T2M") + " T2M "

	cQuery += "LEFT JOIN " + RetSqlName("T2P") + " T2P "
	cQuery += "   ON T2P.T2P_FILIAL = T2M.T2M_FILIAL "
	cQuery += "  AND T2P.T2P_ID = T2M.T2M_ID "
	cQuery += "  AND T2P.T2P_VERSAO = T2M.T2M_VERSAO "
	cQuery += "  AND T2P.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName("T2Q") + " T2Q "
	cQuery += "   ON T2Q.T2Q_FILIAL = T2P.T2P_FILIAL "
	cQuery += "  AND T2Q.T2Q_ID = T2P.T2P_ID "
	cQuery += "  AND T2Q.T2Q_VERSAO = T2P.T2P_VERSAO "
	cQuery += "  AND T2Q.T2Q_ESTABE = T2P.T2P_ESTABE "
	cQuery += "  AND T2Q.T2Q_LOTACA = T2P.T2P_LOTACA "
	cQuery += "  AND T2Q.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName("T2R") + " T2R "
	cQuery += "   ON T2R.T2R_FILIAL = T2Q.T2Q_FILIAL "
	cQuery += "  AND T2R.T2R_ID = T2Q.T2Q_ID "
	cQuery += "  AND T2R.T2R_VERSAO = T2Q.T2Q_VERSAO "
	cQuery += "  AND T2R.T2R_ESTABE = T2Q.T2Q_ESTABE "
	cQuery += "  AND T2R.T2R_LOTACA = T2Q.T2Q_LOTACA "
	cQuery += "  AND T2R.T2R_MATRIC = T2Q.T2Q_MATRIC "
	cQuery += "  AND T2R.T2R_CODCAT = T2Q.T2Q_CODCAT "
	cQuery += "  AND T2R.D_E_L_E_T_ = ' ' "

	cQuery += "LEFT JOIN " + RetSqlName("T2T") + " T2T "
	cQuery += "  ON T2T.T2T_FILIAL = '" + xFilial("T2T") + "' "
	cQuery += " AND T2T.T2T_ID = T2R.T2R_TPVLR "
	cQuery += " AND T2T.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName("C92") + " C92 "
	cQuery += " ON C92.C92_FILIAL = '" + xFilial("C92") + "' "
	cQuery += " AND C92.C92_ID = T2P.T2P_ESTABE "
	cQuery += " AND C92.C92_ATIVO = '1' "
	cQuery += " AND C92.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName("C99") + " C99 "
	cQuery += " ON C99.C99_FILIAL = '" + xFilial("C99") + "' "
	cQuery += " AND C99.C99_ID = T2P.T2P_LOTACA "
	cQuery += " AND C99.C99_ATIVO = '1' "
	cQuery += " AND C99.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN " + RetSqlName("C87") + " C87 "
	cQuery += "  ON C87.C87_FILIAL = '" + xFilial("C87") + "' "
	cQuery += " AND C87.C87_ID = T2Q.T2Q_CODCAT "
	cQuery += " AND C87.D_E_L_E_T_ = ' ' "

	cQuery += "WHERE T2M.T2M_FILIAL = '" + xFilial("T2M") + "' "
	cQuery += "  AND T2M.T2M_INDAPU = '" + cIndApu + "' "

	If Len(AllTrim(cPeriodo)) == 4
		cQuery += "  AND T2M.T2M_PERAPU = '" + cPeriodo + "' "
	Else
		cQuery += "  AND T2M.T2M_PERAPU = '" + SubStr(cPeriodo, 3, 4) + SubStr(cPeriodo, 1, 2) + "' "
	EndIf

	cQuery += "  AND T2M.T2M_CPFTRB = '" + cCPF + "' "
	cQuery += "  AND T2M.T2M_NRRECI = '" + cRecibo + "' "
	cQuery += "  AND T2M.T2M_ATIVO = '1' "
	cQuery += "  AND T2M.D_E_L_E_T_ = ' ' "

	cQuery += "ORDER BY T2P_ESTABE, T2P_LOTACA, T2Q_MATRIC, T2Q_CODCAT "

	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias (cAliasQry)

	(cAliasQry)->(DBGoTop())

	While !(cAliasQry)->(EOF())

		cIndApu		:= AllTrim((cAliasQry)->T2M_INDAPU)
		cPerApu 	:= AllTrim((cAliasQry)->T2M_PERAPU)
		cCPFTrab	:= AllTrim((cAliasQry)->T2M_CPFTRB)
		cNrReci 	:= AllTrim((cAliasQry)->T2M_NRRECI) 

		tafDefAAnalitco(@aAnalitico)
		nPosValores := Len(aAnalitico)

		aAnalitico[nPosValores][ANALITICO_MATRICULA]			:= AllTrim((cAliasQry)->T2Q_MATRIC)
		aAnalitico[nPosValores][ANALITICO_CATEGORIA]			:= AllTrim((cAliasQry)->C87_CODIGO)
		aAnalitico[nPosValores][ANALITICO_TIPO_ESTABELECIMENTO]	:= AllTrim((cAliasQry)->C92_TPINSC)
		aAnalitico[nPosValores][ANALITICO_ESTABELECIMENTO]		:= AllTrim((cAliasQry)->C92_NRINSC)
		aAnalitico[nPosValores][ANALITICO_LOTACAO]				:= AllTrim((cAliasQry)->C99_CODIGO)
		aAnalitico[nPosValores][ANALITICO_NATUREZA]				:= ""
		aAnalitico[nPosValores][ANALITICO_TIPO_RUBRICA]			:= ""
		aAnalitico[nPosValores][ANALITICO_INCIDENCIA_CP]		:= ""
		aAnalitico[nPosValores][ANALITICO_INCIDENCIA_IRRF]		:= ""
		aAnalitico[nPosValores][ANALITICO_INCIDENCIA_FGTS]		:= ""
		aAnalitico[nPosValores][ANALITICO_DECIMO_TERCEIRO]		:= AllTrim((cAliasQry)->T2R_INDDEC)
		aAnalitico[nPosValores][ANALITICO_TIPO_VALOR]			:= AllTrim((cAliasQry)->T2T_CODIGO)
		aAnalitico[nPosValores][ANALITICO_VALOR]				:= (cAliasQry)->T2R_VALOR
		aAnalitico[nPosValores][ANALITICO_MOTIVO_DESLIGAMENTO]	:= cMotDes

		(cAliasQry)->(DBSkip())
	
		InfoRPTObj(cIndApu, cPerApu, cCPFTrab, cNome, aAnalitico, cNrReci, @oInfoRPT)
		oReport:UpSert(cEvento, "3", cFilQry, oInfoRPT)
		
	EndDo

	(cAliasQry)->(DBCloseArea())

Return
