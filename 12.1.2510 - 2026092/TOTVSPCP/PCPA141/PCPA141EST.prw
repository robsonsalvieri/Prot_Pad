#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA141.CH"

#DEFINE BUFFER_INTEGRACAO 1000

/*/{Protheus.doc} PCPA141EST
Executa o processamento dos registros de ESToque

@type  Function
@author lucas.franca
@since 07/08/2019
@version P12
@param 01 cUUID    , Caracter, Identificador do processo para buscar os dados na tabela T4R
@param 02 cStatus  , Caracter, Identificador do status para buscar os dados na tabela T4R (default = '3')
@param 03 lMultiThr, Lógico  , Indica se o processamento será multi-thread
@return oErros     , Objeto  , Json com os erros que ocorreram no processamento
/*/
Function PCPA141EST(cUUID, cStatus, lMultiThr)
	Local aDados      := {}
	Local aDadosInc   := {}
	Local aDadosDel   := {}
	Local aEmprCent   := {}
	Local aSuccess    := {}
	Local aError      := {}
	Local cAlias      := PCPAliasQr()
	Local cBanco      := AllTrim(Upper(TcGetDb()))
	Local cChave      := ""
	Local cFilAtu     := ""
 	Local cFilAux     := ""
	Local cGlbErros   := "ERROS_141" + cUUID
	Local cLoteUni    := SuperGetMv("MV_LOTEUNI",.F.,.F.)
	Local cQuery      := ""
	Local cQueryOri   := ""
	Local lLock       := .F.
	Local lIncluiu    := .F.
	Local nIndex      := 0
	Local nPos        := 0
	Local nIndFilEmp  := 0
	Local nTamFil     := FwSizeFilial()
	Local nTamPrd     := GetSx3Cache("B8_PRODUTO", "X3_TAMANHO")
	Local nTamLoc     := GetSx3Cache("B8_LOCAL"  , "X3_TAMANHO")
	Local nTamLote    := GetSx3Cache("B8_LOTECTL", "X3_TAMANHO")
	Local nTamSubLt   := GetSx3Cache("B8_NUMLOTE", "X3_TAMANHO")
	Local nTamQtd     := GetSx3Cache("B2_QATU"   , "X3_TAMANHO")
	Local nTamDec     := GetSx3Cache("B2_QATU"   , "X3_DECIMAL")
	Local nTotFilEmp  := 0
	Local oErros      := JsonObject():New()
	Local oPrdClear   := JsonObject():New()
	Local oPCPLock    := PCPLockControl():New()
	Default cStatus   := '3'
	Default lMultiThr := .F.

	//Chama API de CQ para Atualizacao
	If FWAliasInDic( "HWX", .F. )
		PCPA141CQ(cUUID)
	EndIf

	If FWAliasInDic("SMQ",.F.)
		aEmprCent := getFilsSMQ()
	Else
		aEmprCent := CargEmprC(cEmpAnt, cFilAnt)
	EndIf

	PutGlbValue(cGlbErros, "0")

	nTotFilEmp := Len(aEmprCent)

	For nIndFilEmp := 1 To nTotFilEmp

		cFilAtu  := aEmprCent[nIndFilEmp][2]
	
		//Monta a query utilizada para buscar os dados a integrar
		cQuery := " ( "
		cQuery +=  " SELECT branchId, "
		cQuery +=         " product, "
		cQuery +=         " warehouse, "
		cQuery +=         " lot, "
		cQuery +=         " sublot, "
		cQuery +=         " expirationDate, "
		cQuery +=         " SUM(availableQuantity) as availableQuantity, "
		cQuery +=         " SUM(consignedOut) as consignedOut, "
		cQuery +=         " SUM(consignedIn) as consignedIn, "
		cQuery +=         " SUM(unavailableQuantity) as unavailableQuantity, "
		cQuery +=         " SUM(blockedBalance) as blockedBalance, "
		cQuery +=         " T4R.R_E_C_N_O_ as recnoT4R "
		cQuery +=    " FROM (SELECT SB2.B2_FILIAL as branchId, "
		cQuery +=                 " SB2.B2_COD    as product, "
		cQuery +=                 " SB2.B2_LOCAL  as warehouse, "
		cQuery +=                 " ''            as lot, "
		cQuery +=                 " ''            as sublot, "
		cQuery +=                 " ''            as expirationDate, "
		cQuery +=                 " (CASE WHEN B1_RASTRO IN ('L', 'S') THEN 0 ELSE B2_QATU  END) as availableQuantity, "
		cQuery +=                 " 0             as consignedOut, " //saldo em poder de terc será obtido pela SB6 e SD5
		cQuery +=                 " SB2.B2_QTNP   as consignedIn, "
		cQuery +=                 " 0             as unavailableQuantity, "
		cQuery +=                 " 0             as blockedBalance "
		cQuery +=                 " FROM " + RetSqlName("SB2") + " SB2 "
		cQuery +=                 " INNER JOIN (SELECT B1_COD, B1_RASTRO "
		cQuery +=                               " FROM " + RetSqlName("SB1")
		cQuery +=                              " WHERE D_E_L_E_T_ = ' ' "
		CQuery +=                               " AND B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' ) SB1 "
		cQuery +=                 " ON SB2.B2_COD = SB1.B1_COD "
		cQuery +=           " WHERE [DELETB2] "
		cQuery +=             " AND SB2.B2_FILIAL = '" + xFilial("SB2",cFilAtu) + "' "
		cQuery +=             " AND EXISTS ( SELECT 1 "
		cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
		cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
		cQuery +=                             " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
		cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
		cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
		cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "

		If cBanco == "POSTGRES"
			cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SB2.B2_FILIAL, " + cValToChar(nTamFil) + ")||"
			cQuery +=                                              "RPAD(SB2.B2_COD   , " + cValToChar(nTamPrd) + ")||"
			cQuery +=                                              "RPAD(SB2.B2_LOCAL , " + cValToChar(nTamLoc) + ")) "
		Else
			cQuery +=                         " AND T4R.T4R_IDREG = SB2.B2_FILIAL||SB2.B2_COD||SB2.B2_LOCAL) "
		EndIf

		//Busca saldo disponível na SB8 quando tem lote/sublote				
		//Quando o parâmetro MV_LOTEUNI está F e o produto controla lote, o sublote é preenchido automaticamente pelo sistema
		//Por esse motivo foi feita uma quebra na SB8 para retornar o sublote me branco quando não controlar sublote e o mesmo for preenchido automaticamente
		//Essa regra de retornar o sublote em branco será aplicada para o Bloqueio e Em Terceiro
		IF !cLoteUni 
			//LOTE
			cQuery +=          " UNION ALL"
			cQuery +=          " SELECT SB8.B8_FILIAL  as branchId, "
			cQuery +=                 " SB8.B8_PRODUTO as product, "
			cQuery +=                 " SB8.B8_LOCAL   as warehouse, "
			cQuery +=                 " SB8.B8_LOTECTL as lot, "
			cQuery +=                 " ' '            as sublot, "
			cQuery +=                 " SB8.B8_DTVALID as expirationDate, "
			cQuery +=                 " SB8.B8_SALDO   as availableQuantity, "
			cQuery +=                 " 0              as consignedOut, "
			cQuery +=                 " 0              as consignedIn, "
			cQuery +=                 " 0              as unavailableQuantity, "
			cQuery +=                 " 0              as blockedBalance "
			cQuery +=            " FROM " + RetSqlName("SB8") + " SB8 "
			cQuery +=            " INNER JOIN (SELECT B1_COD, B1_RASTRO "
			cQuery +=                          " FROM " + RetSqlName("SB1")
			cQuery +=                         " WHERE D_E_L_E_T_ = ' ' "
			cQuery +=                           " AND B1_RASTRO IN ('L') "
			CQuery +=                           " AND B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' ) SB1 "
			cQuery +=            " ON SB8.B8_PRODUTO = SB1.B1_COD "
			cQuery +=           " WHERE [DELETB8] "
			cQuery +=             " AND SB8.B8_FILIAL = '" + xFIlial("SB8",cFilAtu) + "' "
			cQuery +=             " AND SB8.B8_SALDO > 0
			cQuery +=             " AND EXISTS ( SELECT 1 "
			cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
			cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
			cQuery +=                             " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
			cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
			cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
			cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
			If cBanco == "POSTGRES"
				cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SB8.B8_FILIAL , " + cValToChar(nTamFil) + ")||"
				cQuery +=                                              "RPAD(SB8.B8_PRODUTO, " + cValToChar(nTamPrd) + ")||"
				cQuery +=                                              "RPAD(SB8.B8_LOCAL  , " + cValToChar(nTamLoc) + ")) "
			Else
				cQuery +=                         " AND T4R.T4R_IDREG = SB8.B8_FILIAL||SB8.B8_PRODUTO||SB8.B8_LOCAL) "
			EndIf

			//SUBLOTE
			cQuery +=          " UNION ALL"
			cQuery +=          " SELECT SB8.B8_FILIAL  as branchId, "
			cQuery +=                 " SB8.B8_PRODUTO as product, "
			cQuery +=                 " SB8.B8_LOCAL   as warehouse, "
			cQuery +=                 " SB8.B8_LOTECTL as lot, "
			cQuery +=                 " SB8.B8_NUMLOTE as sublot, "
			cQuery +=                 " SB8.B8_DTVALID as expirationDate, "
			cQuery +=                 " SB8.B8_SALDO   as availableQuantity, "
			cQuery +=                 " 0              as consignedOut, "
			cQuery +=                 " 0              as consignedIn, "
			cQuery +=                 " 0              as unavailableQuantity, "
			cQuery +=                 " 0              as blockedBalance "
			cQuery +=            " FROM " + RetSqlName("SB8") + " SB8 "
			cQuery +=            " INNER JOIN (SELECT B1_COD, B1_RASTRO "
			cQuery +=                          " FROM " + RetSqlName("SB1")
			cQuery +=                         " WHERE D_E_L_E_T_ = ' ' "
			cQuery +=                           " AND B1_RASTRO IN ('S') "
			CQuery +=                           " AND B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' ) SB1 "
			cQuery +=            " ON SB8.B8_PRODUTO = SB1.B1_COD "
			cQuery +=           " WHERE [DELETB8] "
			cQuery +=             " AND SB8.B8_FILIAL = '" + xFIlial("SB8",cFilAtu) + "' "
			cQuery +=             " AND SB8.B8_SALDO > 0
			cQuery +=             " AND EXISTS ( SELECT 1 "
			cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
			cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
			cQuery +=                             " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
			cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
			cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
			cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
			If cBanco == "POSTGRES"
				cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SB8.B8_FILIAL , " + cValToChar(nTamFil) + ")||"
				cQuery +=                                              "RPAD(SB8.B8_PRODUTO, " + cValToChar(nTamPrd) + ")||"
				cQuery +=                                              "RPAD(SB8.B8_LOCAL  , " + cValToChar(nTamLoc) + ")) "
			Else
				cQuery +=                         " AND T4R.T4R_IDREG = SB8.B8_FILIAL||SB8.B8_PRODUTO||SB8.B8_LOCAL) "
			EndIf
		Else
			cQuery +=          " UNION ALL"
			cQuery +=          " SELECT SB8.B8_FILIAL  as branchId, "
			cQuery +=                 " SB8.B8_PRODUTO as product, "
			cQuery +=                 " SB8.B8_LOCAL   as warehouse, "
			cQuery +=                 " SB8.B8_LOTECTL as lot, "
			cQuery +=                 " SB8.B8_NUMLOTE as sublot, "
			cQuery +=                 " SB8.B8_DTVALID as expirationDate, "
			cQuery +=                 " SB8.B8_SALDO   as availableQuantity, "
			cQuery +=                 " 0              as consignedOut, "
			cQuery +=                 " 0              as consignedIn, "
			cQuery +=                 " 0              as unavailableQuantity, "
			cQuery +=                 " 0              as blockedBalance "
			cQuery +=            " FROM " + RetSqlName("SB8") + " SB8 "
			cQuery +=            " INNER JOIN (SELECT B1_COD, B1_RASTRO "
			cQuery +=                          " FROM " + RetSqlName("SB1")
			cQuery +=                         " WHERE D_E_L_E_T_ = ' ' "
			cQuery +=                           " AND B1_RASTRO IN ('L', 'S') "
			CQuery +=                           " AND B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' ) SB1 " 
			cQuery +=            " ON SB8.B8_PRODUTO = SB1.B1_COD "
			cQuery +=           " WHERE [DELETB8] "
			cQuery +=             " AND SB8.B8_FILIAL = '" + xFIlial("SB8",cFilAtu) + "' "
			cQuery +=             " AND SB8.B8_SALDO > 0
			cQuery +=             " AND EXISTS ( SELECT 1 "
			cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
			cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
			cQuery +=                             " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
			cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
			cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
			cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
			If cBanco == "POSTGRES"
				cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SB8.B8_FILIAL , " + cValToChar(nTamFil) + ")||"
				cQuery +=                                              "RPAD(SB8.B8_PRODUTO, " + cValToChar(nTamPrd) + ")||"
				cQuery +=                                              "RPAD(SB8.B8_LOCAL  , " + cValToChar(nTamLoc) + ")) "
			Else
				cQuery +=                         " AND T4R.T4R_IDREG = SB8.B8_FILIAL||SB8.B8_PRODUTO||SB8.B8_LOCAL) "
			EndIf
		EndIf

		//Busca saldo Em Terceiros - Sem lote e sem sublote
		cQuery +=	" UNION ALL"
		cQuery +=	" SELECT SB6.B6_FILIAL 	AS branchId,"
    	cQuery +=	" SB6.B6_PRODUTO	AS product,"
    	cQuery +=	" SB6.B6_LOCAL  	AS warehouse,"
    	cQuery +=	" ''            	AS lot,"
    	cQuery +=	" ''            	AS sublot,"
    	cQuery +=	" ''            	AS expirationDate,"
		cQuery +=	" 0					AS availableQuantity,"
    	cQuery +=	" SB6.B6_SALDO      AS consignedOut,"
    	cQuery +=	" 0 				AS consignedIn,"
    	cQuery +=	" 0 				AS unavailableQuantity,"
    	cQuery +=	" 0 				AS blockedBalance"
		cQuery +=	" FROM " + RetSqlName("SB6")+" SB6"
    	cQuery +=	" INNER JOIN (SELECT B1_COD, B1_RASTRO"
		cQuery +=				" FROM " + RetSqlName("SB1")
    	cQuery +=				" WHERE D_E_L_E_T_ = ' '"
		cQuery +=				" AND B1_RASTRO NOT IN ('L','S') "
		CQuery +=				" AND B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' ) SB1 " 
		cQuery +=	" ON SB6.B6_PRODUTO = SB1.B1_COD"
    	cQuery +=	" WHERE SB6.D_E_L_E_T_ = ' '"
		cQuery += 	" AND SB6.B6_FILIAL = '" + xFIlial("SB6",cFilAtu) + "' "
		cQuery +=	" AND SB6.B6_QUANT > 0"
		cQuery +=	" AND SB6.B6_TIPO = 'E'"
		cQuery +=   " AND SB6.B6_PODER3 = 'R'"
		cQuery +=   " AND SB6.B6_ESTOQUE = 'S'"
		cQuery +=	" AND EXISTS ( SELECT 1 "
		cQuery +=				" FROM " + RetSqlName("T4R") + " T4R "
		cQuery +=				" WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
		cQuery +=				" AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
		cQuery +=				" AND T4R.D_E_L_E_T_ = ' ' "
		cQuery +=				" AND T4R.T4R_STATUS = '" + cStatus + "' "
		cQuery +=				" AND T4R.T4R_IDPRC  = '" + cUUID   + "' "

		If cBanco == "POSTGRES"
			cQuery +=" AND T4R.T4R_IDREG = RPAD(SB6.B6_FILIAL , " + cValToChar(nTamFil) + ")||"
			cQuery +=						"RPAD(SB6.B6_PRODUTO, " + cValToChar(nTamPrd) + ")||"
			cQuery += 						"RPAD(SB6.B6_LOCAL  , " + cValToChar(nTamLoc) + ")) "
		Else
			cQuery += " AND T4R.T4R_IDREG = SB6.B6_FILIAL||SB6.B6_PRODUTO||SB6.B6_LOCAL) "
		EndIf

		//Busca saldo Em Terceiros - Com lote e sublote
	
		//DMANSMARTSQUAD1-29833 - Vivian - 20/09/2024
		//Existe uma questão quando numa mesma NF de remessa forem enviados mais de um lote/sublote do mesmo produto
		//Algumas informações estão só na SB6 (como a indentificação do tipo do movimento - B6_PODER3 = R (remessa) e D (devolução)).
		//Está sendo utilizado o campo B6_SALDO para determinar a quantidade em terceiro, porque na SD5 tem a quantidade que foi 
		//enviada para terceiro, porém as quantidades retornadas estão em outros registros da SD5, o correto seria ser efetuado 
		//cálculo (saldo = remessa - retorno), porém, o relacionamento entre as tabelas SB6 e SD5 é efetuado pelo B6_IDENT = D5_NUMSEQ
		//Quando é efetuada remessa, é gerado um registro na SB6 com B6_IDENT igual ao D5_NUMSEQ gerado na SD5, porém ao efetuar 
		//devolução é gerado novo registro da SB6, com o B6_IDENT igual ao B6_IDENT da remessa, e na SD5 é gerado um D5_NUMSEQ novo, 
		//que não relaciona com a SB6.
		//Para que fosse possível efetuar o cálculo, teria que ter um campo B6_NUMSEQ na SB6, para gravar o NUMSEQ que relaciona 
		//exatamente com a SD5, e o B6_IDENT ser utilizado para identificar todos os registros da SB6 referentes à remessa X, ou ter .
		//outra tabela que faça esse relacionamento (que pode existir e não sabemos - seria necessário tratar com a equipe de estoque)
		//Optamos por não fazer esse movimento (de envolver a equipe de estoque), nesse momento, devido a urgência da liberação da 
		//correção da issue, e só termos identificados problemas em testes internos (nos problemas das issues anteriores, identificados
		//por clientes não havia essa situação).

		IF !cLoteUni 
			//Foram montadas duas queries, uma para o Lote e outra para o Sublote.
			//Retornar o sublote me branco quando não controlar sublote e o mesmo for preenchido automaticamente	
			//Query do lote - fixando o sublote em branco
			cQuery += 	" UNION ALL"
			cQuery +=  " SELECT SD5.D5_FILIAL   AS branchId, "
			cQuery +=         " SB6a.B6_PRODUTO AS product, "
			cQuery +=         " SB6a.B6_LOCAL   AS warehouse, "
			cQuery +=         " SD5.D5_LOTECTL  AS lot, "
			cQuery +=         " ' '             AS sublot, "
			cQuery +=         " SD5.D5_DTVALID  AS expirationDate, "
			cQuery +=         " 0               AS availableQuantity, "
			cQuery +=         " SB6a.B6_SALDO   AS consignedOut, "
			cQuery +=         " 0               AS consignedIn, "
			cQuery +=         " 0               AS unavailableQuantity, "
			cQuery +=         " 0               AS blockedBalance "
			cQuery +=    " FROM " + RetSqlName("SB6") + " SB6a "
			cQuery +=   " INNER JOIN " + RetSqlName("SB1") + " SB1 "
			cQuery +=      " ON SB1.B1_COD = SB6a.B6_PRODUTO "
			cQuery +=     " AND SB1.B1_RASTRO = 'L' "
			cQuery +=     " AND SB1.D_E_L_E_T_ = ' ' "
			cQuery +=     " AND SB1.B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' "
			cQuery +=   " INNER JOIN (SELECT SD5.D5_FILIAL, "
			cQuery +=                      " SD5.D5_PRODUTO, "
			cQuery +=                      " SD5.D5_LOCAL, "
			cQuery +=                      " SD5.D5_DOC, "
			cQuery +=                      " SD5.D5_SERIE, "
			cQuery +=                      " SD5.D5_ORIGLAN, "
			cQuery +=                      " SD5.D5_NUMSEQ, "
			cQuery +=                      " SD5.D5_LOTECTL, "
			cQuery +=                      " SD5.D5_DTVALID "
			cQuery +=                 " FROM " + RetSqlName("SD5") + " SD5 "
			cQuery +=               "  WHERE SD5.D5_QUANT > 0 "
			cQuery +=                  " AND SD5.D_E_L_E_T_ = ' ' "
			cQuery += 	               " AND SD5.D5_FILIAL = '" + xFilial("SD5",cFilAtu) + "' "
			cQuery +=                " GROUP BY SD5.D5_FILIAL, "
			cQuery +=                         " SD5.D5_PRODUTO, "
			cQuery +=                         " SD5.D5_LOCAL, "
			cQuery +=                         " SD5.D5_DOC, "
			cQuery +=                         " SD5.D5_SERIE, "
			cQuery +=                         " SD5.D5_ORIGLAN, "
			cQuery +=                         " SD5.D5_NUMSEQ, "
			cQuery +=                         " SD5.D5_LOTECTL, "
			cQuery +=                         " SD5.D5_DTVALID) SD5 "
			cQuery +=      " ON SD5.D5_PRODUTO = SB6a.B6_PRODUTO "
			cQuery +=     " AND SD5.D5_LOCAL = SB6a.B6_LOCAL "
			cQuery +=     " AND SD5.D5_DOC = SB6a.B6_DOC "
			cQuery +=     " AND SD5.D5_SERIE = SB6a.B6_SERIE "
			cQuery +=     " AND SD5.D5_ORIGLAN = SB6a.B6_TES "
			cQuery +=     " AND SD5.D5_NUMSEQ = SB6a.B6_IDENT "
			cQuery +=   " INNER JOIN " + RetSqlName("T4R") + " T4R "
			cQuery +=      " ON T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
			cQuery +=     " AND T4R.T4R_API = 'MRPSTOCKBALANCE' "
			cQuery +=     " AND T4R.T4R_STATUS = '" + cStatus + "' "
			cQuery +=     " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
			If cBanco == "POSTGRES"
				cQuery += " AND T4R.T4R_IDREG = RPAD(SD5.D5_FILIAL , " + cValToChar(nTamFil) + ")||"
				cQuery +=                      "RPAD(SD5.D5_PRODUTO, " + cValToChar(nTamPrd) + ")||"
				cQuery +=                      "RPAD(SD5.D5_LOCAL  , " + cValToChar(nTamLoc) + ") "
			Else
				cQuery += " AND T4R.T4R_IDREG = SD5.D5_FILIAL||SD5.D5_PRODUTO||SD5.D5_LOCAL "
			EndIf
			cQuery +=     " AND T4R.D_E_L_E_T_ = ' ' "
			cQuery +=   " WHERE SB6a.B6_TIPO = 'E' "
			cQuery +=     " AND SB6a.B6_PODER3 = 'R' "
			cQuery +=     " AND SB6a.B6_ESTOQUE = 'S' "
			cQuery +=     " AND SB6a.D_E_L_E_T_ = ' ' "
			cQuery += 	  " AND SB6a.B6_FILIAL = '" + xFilial("SB6",cFilAtu) + "' "

			//Query do Sublote - gravando o valor do sublote
			cQuery += 	" UNION ALL"
			cQuery +=  " SELECT SD5.D5_FILIAL   AS branchId, "
			cQuery +=         " SB6a.B6_PRODUTO AS product, "
			cQuery +=         " SB6a.B6_LOCAL   AS warehouse, "
			cQuery +=         " SD5.D5_LOTECTL  AS lot, "
			cQuery +=         " SD5.D5_NUMLOTE  AS sublot, "
			cQuery +=         " SD5.D5_DTVALID  AS expirationDate, "
			cQuery +=         " 0               AS availableQuantity, "
			cQuery +=         " SB6a.B6_SALDO   AS consignedOut, "
			cQuery +=         " 0               AS consignedIn, "
			cQuery +=         " 0               AS unavailableQuantity, "
			cQuery +=         " 0               AS blockedBalance "
			cQuery +=    " FROM " + RetSqlName("SB6") + " SB6a "
			cQuery +=   " INNER JOIN " + RetSqlName("SB1") + " SB1 "
			cQuery +=      " ON SB1.B1_COD = SB6a.B6_PRODUTO "
			cQuery +=     " AND SB1.B1_RASTRO = 'S' "
			cQuery +=     " AND SB1.D_E_L_E_T_ = ' ' "
			cQuery +=     " AND SB1.B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' "
			cQuery +=   " INNER JOIN (SELECT SD5.D5_FILIAL, "
			cQuery +=                      " SD5.D5_PRODUTO, "
			cQuery +=                      " SD5.D5_LOCAL, "
			cQuery +=                      " SD5.D5_DOC, "
			cQuery +=                      " SD5.D5_SERIE, "
			cQuery +=                      " SD5.D5_ORIGLAN, "
			cQuery +=                      " SD5.D5_NUMSEQ, "
			cQuery +=                      " SD5.D5_LOTECTL, "
			cQuery +=                      " SD5.D5_NUMLOTE, "
			cQuery +=                      " SD5.D5_DTVALID "
			cQuery +=                 " FROM " + RetSqlName("SD5") + " SD5 "
			cQuery +=                " WHERE SD5.D5_QUANT > 0 "
			cQuery +=                  " AND SD5.D_E_L_E_T_ = ' ' "
			cQuery += 				   " AND SD5.D5_FILIAL = '" + xFilial("SD5",cFilAtu) + "' "
			cQuery +=                " GROUP BY SD5.D5_FILIAL, "
			cQuery +=                         " SD5.D5_PRODUTO, "
			cQuery +=                         " SD5.D5_LOCAL, "
			cQuery +=                         " SD5.D5_DOC, "
			cQuery +=                         " SD5.D5_SERIE, "
			cQuery +=                         " SD5.D5_ORIGLAN, "
			cQuery +=                         " SD5.D5_NUMSEQ, "
			cQuery +=                         " SD5.D5_LOTECTL, "
			cQuery +=                         " SD5.D5_NUMLOTE, "
			cQuery +=                         " SD5.D5_DTVALID) SD5 "
			cQuery +=      " ON SD5.D5_PRODUTO = SB6a.B6_PRODUTO "
			cQuery +=     " AND SD5.D5_LOCAL = SB6a.B6_LOCAL "
			cQuery +=     " AND SD5.D5_DOC = SB6a.B6_DOC "
			cQuery +=     " AND SD5.D5_SERIE = SB6a.B6_SERIE "
			cQuery +=     " AND SD5.D5_ORIGLAN = SB6a.B6_TES "
			cQuery +=     " AND SD5.D5_NUMSEQ = SB6a.B6_IDENT "
			cQuery +=   " INNER JOIN " + RetSqlName("T4R") + " T4R "
			cQuery +=      " ON T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
			cQuery +=     " AND T4R.T4R_API = 'MRPSTOCKBALANCE' "
			cQuery +=     " AND T4R.T4R_STATUS = '" + cStatus + "' "
			cQuery +=     " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
			If cBanco == "POSTGRES"
				cQuery += " AND T4R.T4R_IDREG = RPAD(SD5.D5_FILIAL , " + cValToChar(nTamFil) + ")||"
				cQuery +=                      "RPAD(SD5.D5_PRODUTO, " + cValToChar(nTamPrd) + ")||"
				cQuery +=                      "RPAD(SD5.D5_LOCAL  , " + cValToChar(nTamLoc) + ") "
			Else
				cQuery += " AND T4R.T4R_IDREG = SD5.D5_FILIAL||SD5.D5_PRODUTO||SD5.D5_LOCAL "
			EndIf
			cQuery +=     " AND T4R.D_E_L_E_T_ = ' ' "
			cQuery +=   " WHERE SB6a.B6_TIPO = 'E' "
			cQuery +=     " AND SB6a.B6_PODER3 = 'R' "
			cQuery +=     " AND SB6a.B6_ESTOQUE = 'S' "
			cQuery +=     " AND SB6a.D_E_L_E_T_ = ' ' "
			cQuery +=     " AND SB6a.B6_FILIAL = '" + xFilial("SB6",cFilAtu) + "' " 
		Else
			cQuery += 	" UNION ALL"
			cQuery +=  " SELECT SD5.D5_FILIAL AS branchId, "
			cQuery +=         " SB6a.B6_PRODUTO AS product, "
			cQuery +=         " SB6a.B6_LOCAL AS warehouse, "
			cQuery +=         " SD5.D5_LOTECTL AS lot, "
			cQuery +=         " SD5.D5_NUMLOTE AS sublot, "
			cQuery +=         " SD5.D5_DTVALID AS expirationDate, "
			cQuery +=         " 0 AS availableQuantity, "
			cQuery +=         " SB6a.B6_SALDO AS consignedOut, "
			cQuery +=         " 0 AS consignedIn, "
			cQuery +=         " 0 AS unavailableQuantity, "
			cQuery +=         " 0 AS blockedBalance "
			cQuery +=    " FROM " + RetSqlName("SB6") + " SB6a "
			cQuery +=   " INNER JOIN " + RetSqlName("SB1") + " SB1a "
			cQuery +=      " ON SB6a.B6_PRODUTO = SB1a.B1_COD "
			cQuery +=     " AND SB1a.B1_RASTRO IN ('L', 'S') "
			cQuery +=     " AND SB1a.D_E_L_E_T_ = ' ' "
			cQuery +=     " AND SB1a.B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "' "
			cQuery +=   " INNER JOIN (SELECT SD5.D5_FILIAL, "
			cQuery +=                      " SD5.D5_PRODUTO, "
			cQuery +=                      " SD5.D5_LOCAL, "
			cQuery +=                      " SD5.D5_DOC, "
			cQuery +=                      " SD5.D5_SERIE, "
			cQuery +=                      " SD5.D5_ORIGLAN, "
			cQuery +=                      " SD5.D5_NUMSEQ, "
			cQuery +=                      " SD5.D5_LOTECTL, "
			cQuery +=                      " SD5.D5_NUMLOTE, "
			cQuery +=                      " SD5.D5_DTVALID "
			cQuery +=                 " FROM " + RetSqlName("SD5") + " SD5 "
			cQuery +=                " WHERE SD5.D_E_L_E_T_ = ' ' "
			cQuery +=                  " AND SD5.D5_QUANT > 0 "
			cQuery += 				   " AND SD5.D5_FILIAL = '" + xFilial("SD5",cFilAtu) + "' "
			cQuery +=                " GROUP BY SD5.D5_FILIAL, "
			cQuery +=                         " SD5.D5_PRODUTO, "
			cQuery +=                         " SD5.D5_LOCAL, "
			cQuery +=                         " SD5.D5_DOC, "
			cQuery +=                         " SD5.D5_SERIE, "
			cQuery +=                         " SD5.D5_ORIGLAN, "
			cQuery +=                         " SD5.D5_NUMSEQ, "
			cQuery +=                         " SD5.D5_LOTECTL, "
			cQuery +=                         " SD5.D5_NUMLOTE, "
			cQuery +=                         " SD5.D5_DTVALID) SD5 "
			cQuery +=      " ON SD5.D5_PRODUTO = SB6a.B6_PRODUTO "
			cQuery +=     " AND SD5.D5_LOCAL = SB6a.B6_LOCAL "
			cQuery +=     " AND SD5.D5_DOC = SB6a.B6_DOC "
			cQuery +=     " AND SD5.D5_SERIE = SB6a.B6_SERIE "
			cQuery +=     " AND SD5.D5_ORIGLAN = SB6a.B6_TES "
			cQuery +=     " AND SD5.D5_NUMSEQ = SB6a.B6_IDENT "
			cQuery +=   " INNER JOIN " + RetSqlName("T4R") + " T4R "
			cQuery +=      " ON T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
			cQuery +=	  " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
			cQuery +=	  " AND T4R.T4R_STATUS = '" + cStatus + "' "
			cQuery +=	  " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
			If cBanco == "POSTGRES"
				cQuery += " AND T4R.T4R_IDREG = RPAD(SD5.D5_FILIAL , " + cValToChar(nTamFil) + ")||"
				cQuery += 						"RPAD(SD5.D5_PRODUTO, " + cValToChar(nTamPrd) + ")||"
				cQuery +=  						"RPAD(SD5.D5_LOCAL  , " + cValToChar(nTamLoc) + ") "
			Else
				cQuery += " AND T4R.T4R_IDREG = SD5.D5_FILIAL||SD5.D5_PRODUTO||SD5.D5_LOCAL "
			EndIf
			cQuery +=     " AND T4R.D_E_L_E_T_ = ' ' "
			cQuery +=   " WHERE SB6a.B6_TIPO = 'E' "
			cQuery +=     " AND SB6a.B6_PODER3 = 'R' "
			cQuery +=     " AND SB6a.B6_ESTOQUE = 'S' "
			cQuery +=     " AND SB6a.D_E_L_E_T_ = ' ' "
			cQuery += 	  " AND SB6a.B6_FILIAL = '" + xFilial("SB6",cFilAtu) + "' "
		EndIf
	
		//Busca saldo Bloqueado	para produto com Lote
		cQuery +=          " UNION ALL"
		cQuery +=          " SELECT SDDa.DD_FILIAL   as branchId, "
		cQuery +=                 " SDDa.DD_PRODUTO  as product, "
		cQuery +=                 " SDDa.DD_LOCAL    as warehouse, "
		cQuery +=                 " SDDa.DD_LOTECTL  as lot, "
		cQuery +=                 " SDDa.DD_NUMLOTE  as sublot, "
		cQuery +=                 " SDDa.DD_DTVALID  as expirationDate, "
		cQuery +=                 " 0			     as availableQuantity, "
		cQuery +=                 " 0                as consignedOut, "
		cQuery +=                 " 0                as consignedIn, "
		cQuery +=                 " 0                as unavailableQuantity, "
		cQuery +=                 " SDDa.DD_SALDO    as blockedBalance "
		cQuery +=            " FROM " + RetSqlName("SDD") + " SDDa "
		cQuery +=            " INNER JOIN (SELECT B1_COD, B1_RASTRO"
		cQuery +=						   " FROM " + RetSqlName("SB1")
		cQuery +=						  " WHERE D_E_L_E_T_ = ' '"
		cQuery +=						    " AND B1_RASTRO = 'L' "
		cQuery +=							" AND B1_FILIAL = '" + xFIlial("SB1",cFilAtu) + "' ) SB1a "
		cQuery +=					 " ON  SDDa.DD_PRODUTO = SB1a.B1_COD "	
		cQuery +=                 " WHERE SDDa.D_E_L_E_T_ = ' '  AND SDDa.DD_SALDO > 0 AND SDDa.DD_MOTIVO <> 'VV' AND SDDa.DD_FILIAL = '" + xFilial("SDD",cFilAtu)+ "' "
		cQuery +=                   " AND EXISTS ( SELECT 1 "
		cQuery +=                                  " FROM " + RetSqlName("T4R") + " T4R "
		cQuery +=                                 " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
		cQuery +=                                   " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
		cQuery +=                                   " AND T4R.D_E_L_E_T_ = ' ' "
		cQuery +=                                   " AND T4R.T4R_STATUS = '" + cStatus + "' "
		cQuery +=                                   " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "

		If cBanco == "POSTGRES"
			cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SDDa.DD_FILIAL , " + cValToChar(nTamFil) + ")||"
			cQuery +=                                              "RPAD(SDDa.DD_PRODUTO, " + cValToChar(nTamPrd) + ")||"
			cQuery +=                                              "RPAD(SDDa.DD_LOCAL  , " + cValToChar(nTamLoc) + ")) "
		Else
			cQuery +=                         " AND T4R.T4R_IDREG = SDDa.DD_FILIAL||SDDa.DD_PRODUTO||SDDa.DD_LOCAL) "
		EndIf

		//Busca saldo Bloqueado	para produto com Sublote
		cQuery += " UNION ALL"
		cQuery += " SELECT	SDDb.DD_FILIAL 	as branchId,"
		cQuery += 		"	SDDb.DD_PRODUTO as product,"
		cQuery += 		"	SDDb.DD_LOCAL 	as warehouse,"
		cQuery += 		"	SDDb.DD_LOTECTL as lot,"
		cQuery += 		"	SB8c.B8_NUMLOTE as sublot,"
		cQuery += 		"	SB8c.B8_DTVALID as expirationDate,"
		cQuery += 		"	0 				as availableQuantity,"
		cQuery += 		"	0 				as consignedOut,"
		cQuery += 		"	0 				as consignedIn,"
		cQuery += 		"	0 				as unavailableQuantity,"
		cQuery += 		"	SDDb.DD_SALDO 	as blockedBalance"
		cQuery +=	" FROM " + RetSqlName("SDD")+" SDDb"
		cQuery += 	" INNER JOIN (SELECT B8_PRODUTO, B8_DTVALID, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE"
		cQuery +=					" FROM " + RetSqlName("SB8")+" SB8"
    	cQuery +=					" INNER JOIN (SELECT B1_COD, B1_RASTRO"
		cQuery +=									" FROM " + RetSqlName("SB1")
		cQuery +=									" WHERE D_E_L_E_T_ = ' '"
		cQuery +=									" AND B1_RASTRO = 'S' "
		cQuery +=									" AND B1_FILIAL = '" + xFilial("SB1",cFilAtu) + "') SB1b"
		cQuery +=					        + " ON SB8.B8_PRODUTO = SB1b.B1_COD"									
		cQuery +=								+ " WHERE D_E_L_E_T_ = ' ' AND SB8.B8_FILIAL = '" + xFilial("SB8",cFilAtu) + "') SB8c"
		cQuery +=						+ " ON SB8c.B8_PRODUTO = SDDb.DD_PRODUTO"
		cQuery +=							+ " AND SB8c.B8_LOCAL = SDDb.DD_LOCAL"
		cQuery +=							+ " AND SB8c.B8_LOTECTL = SDDb.DD_LOTECTL"
		cQuery +=							+ " AND SB8c.B8_NUMLOTE = SDDb.DD_NUMLOTE"
		cQuery +=			+ " WHERE SDDb.D_E_L_E_T_ = ' ' AND SDDb.DD_SALDO > 0 AND SDDb.DD_MOTIVO <> 'VV' AND SDDb.DD_FILIAL = '" + xFilial("SDD",cFilAtu) + "'"
		cQuery +=             " AND EXISTS ( SELECT 1 "
		cQuery +=                            " FROM " + RetSqlName("T4R") + " T4R "
		cQuery +=                           " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
		cQuery +=                             " AND T4R.T4R_API    = 'MRPSTOCKBALANCE' "
		cQuery +=                             " AND T4R.D_E_L_E_T_ = ' ' "
		cQuery +=                             " AND T4R.T4R_STATUS = '" + cStatus + "' "
		cQuery +=                             " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "

		If cBanco == "POSTGRES"
			cQuery +=                         " AND T4R.T4R_IDREG = RPAD(SDDb.DD_FILIAL , " + cValToChar(nTamFil) + ")||"
			cQuery +=                                              "RPAD(SDDb.DD_PRODUTO, " + cValToChar(nTamPrd) + ")||"
			cQuery +=                                              "RPAD(SDDb.DD_LOCAL  , " + cValToChar(nTamLoc) + ")) "
		Else
			cQuery +=                         " AND T4R.T4R_IDREG = SDDb.DD_FILIAL||SDDb.DD_PRODUTO||SDDb.DD_LOCAL) "
		EndIf			

		cQuery +=            " ) SB2a"
		cQuery +=           " LEFT JOIN " + RetSqlName("T4R") + " T4R "
		cQuery +=             " ON T4R.T4R_FILIAL = '" + xFilial("T4R") + "' "
		cQuery +=            " AND T4R.D_E_L_E_T_ = ' ' "
		cQuery +=            " AND T4R.T4R_API = 'MRPSTOCKBALANCE' "
		cQuery +=            " AND T4R.T4R_STATUS = '" + cStatus + "' "
		cQuery +=            " AND T4R.T4R_IDPRC  = '" + cUUID   + "' "
		If cBanco == "POSTGRES"
			cQuery +=        " AND T4R.T4R_IDREG = RPAD(branchId , " + cValToChar(nTamFil) + ")||"
			cQuery +=                             "RPAD(product  , " + cValToChar(nTamPrd) + ")||"
			cQuery +=                             "RPAD(warehouse, " + cValToChar(nTamLoc) + ") "
		Else
			cQuery +=        " AND T4R.T4R_IDREG = branchId || product || warehouse "
		EndIf

		cQuery +=          " GROUP BY branchId, "
		cQuery +=                   " product, "
		cQuery +=                   " warehouse, "
		cQuery +=                   " lot, "
		cQuery +=                   " sublot, "
		cQuery +=                   " expirationDate, "
		cQuery +=                   " T4R.R_E_C_N_O_ "
		cQuery +=          " [HAVINGSUM] "
		cQuery += " ) SB2b "

		cQuery := "%" + cQuery + "%"

		If "MSSQL" $ cBanco
			cQuery := StrTran(cQuery, "||", "+")
		EndIf

		cQueryOri := cQuery

		//Primeiro roda sem o HAVING SUM, para excluir os saldos existentes.
		cQuery := StrTran(cQueryOri, "[HAVINGSUM]", " ")

		//Não filtra os registros deletados.
		cQuery := StrTran(cQuery, "[DELETB2]", " 1=1 ")
		cQuery := StrTran(cQuery, "[DELETB8]", " 1=1 ")

		BeginSql Alias cAlias
			SELECT branchId,
			       product,
			       warehouse,
			       lot,
			       sublot,
			       expirationDate,
			       recnoT4R
			FROM %Exp:cQuery%
		EndSql

		If (cAlias)->(!Eof())
			If !lLock
				lLock := oPCPLock:lock("MRP_MEMORIA", "PCPA141", "MRPSTOCKBALANCE", .F., {"PCPA712", "PCPA145", "PCPA151"}, 2)
			EndIf
		EndIf

		//Se possuir dados a processar, cria as tabelas temporárias utilizadas na integração dos estoques
		If (cAlias)->(!Eof())

			While (cAlias)->(!Eof())
				cFilAux := PadR((cAlias)->branchId , nTamFil)

				aSize(aDados, 0)
				aDados := Array(EstqAPICnt("ARRAY_ESTOQUE_SIZE"))

				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL"   )] := cFilAux
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"     )] := PadR((cAlias)->product  , nTamPrd)
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL"    )] := PadR((cAlias)->warehouse, nTamLoc)

				cChave := aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL")] +;
				          aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"  )] +;
				          aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL" )]

				If oPrdClear[cChave] == Nil
					aAdd(aDadosDel, aClone(aDados))
					oPrdClear[cChave] := .T.
				EndIf

				(cAlias)->(dbSkip())
			End
			(cAlias)->(dbCloseArea())

			If Len(aDadosDel) > 0
				PcpEstqInt("CLEAR", aDadosDel, @aSuccess, @aError, Nil)
				If Len(aError) > 0
					For nIndex := 1 To Len(aError)
						cChave := aError[nIndex]["detailedMessage"]["branchId"]+;
						          aError[nIndex]["detailedMessage"]["product"]+;
						          aError[nIndex]["detailedMessage"]["warehouse"]

						If oPrdClear[cChave] != Nil
							oPrdClear[cChave] := .F.
						EndIf
					Next nIndex
				EndIf
			EndIf

			aSize(aDadosDel, 0)

			cAlias := PCPAliasQr()

			//Roda com o HAVING SUM, para inc luir os saldos atuais
			cQuery := StrTran(cQueryOri,;
			                  "[HAVINGSUM]",;
			                  " HAVING SUM(availableQuantity)+SUM(consignedOut)+SUM(consignedIn)+SUM(unavailableQuantity)+SUM(blockedBalance) != 0 ")

			//Filtra os registros deletados.
			cQuery := StrTran(cQuery, "[DELETB2]", " SB2.D_E_L_E_T_ = ' ' ")
			cQuery := StrTran(cQuery, "[DELETB8]", " SB8.D_E_L_E_T_ = ' ' ")

			BeginSql Alias cAlias
				COLUMN availableQuantity     AS NUMERIC(nTamQtd, nTamDec)
				COLUMN consignedOut          AS NUMERIC(nTamQtd, nTamDec)
				COLUMN consignedIn           AS NUMERIC(nTamQtd, nTamDec)
				COLUMN unavailableQuantity   AS NUMERIC(nTamQtd, nTamDec)
				COLUMN expirationDate        AS DATE
				COLUMN blockedBalance        AS NUMERIC(nTamQtd, nTamDec)
				SELECT branchId,
				       product,
				       warehouse,
				       lot,
				       sublot,
				       expirationDate,
				       availableQuantity,
				       consignedOut,
				       consignedIn,
				       unavailableQuantity,
					   blockedBalance
				FROM %Exp:cQuery%
			EndSql

			nPos := 0
			While (cAlias)->(!Eof())
				aSize(aDados, 0)

				aDados := Array(EstqAPICnt("ARRAY_ESTOQUE_SIZE"))
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL"   )] := PadR((cAlias)->branchId , nTamFil)
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"     )] := PadR((cAlias)->product  , nTamPrd)
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL"    )] := PadR((cAlias)->warehouse, nTamLoc)
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOTE"     )] := PadR((cAlias)->lot      , nTamLote)
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_SUBLOTE"  )] := PadR((cAlias)->sublot   , nTamSubLt)
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_VALIDADE" )] := (cAlias)->expirationDate
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD"      )] := (cAlias)->availableQuantity
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_NPT"  )] := (cAlias)->consignedOut
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_TNP"  )] := (cAlias)->consignedIn
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_IND"  )] := (cAlias)->unavailableQuantity
				aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_QTD_BLQ"  )] := (cAlias)->blockedBalance

				cChave := aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_FILIAL")] +;
				          aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_PROD"  )] +;
				          aDados[EstqAPICnt("ARRAY_ESTOQUE_POS_LOCAL" )]

				If oPrdClear[cChave]
					aAdd(aDadosInc, aClone(aDados))
					nPos++
				EndIf

				(cAlias)->(dbSkip())

				//Executa a integração para inclusão/atualização
				If nPos > BUFFER_INTEGRACAO .Or. ((cAlias)->(Eof()) .And. Len(aDadosInc) > 0)
					If lMultiThr
						PCPIPCGO(P141IdThr(), .F., "P141Intgra", "MRPSTOCKBALANCE", nPos, "PcpEstqInt", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
					Else
						P141Intgra("MRPSTOCKBALANCE", nPos, "PcpEstqInt", cGlbErros, "INSERT", aDadosInc, Nil, Nil, cUUID)
					EndIf

					nPos     := 0
					lIncluiu := .T.
					aSize(aDadosInc, 0)
				EndIf
			End
		EndIf
		(cAlias)->(dbCloseArea())

	Next nIndFilEmp

    delPendT4R(cUUID)

	If lMultiThr
		PCPIPCWait(P141IdThr())
	EndIf

	//Limpa as pendências dos registros de saldo que não possuem quantidades a integrar
	If !lIncluiu
		clearPend(cUUID, cStatus)
	EndIf

	If lLock
		oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "MRPSTOCKBALANCE")
	EndIf

	oErros["ERROR_LOG"] := Val(GetGlbValue(cGlbErros))
	ClearGlbValue(cGlbErros)

	FreeObj(oPrdClear)
	oPrdClear := Nil

	FwFreeArray(aDados)
	FwFreeArray(aDadosDel)
	FwFreeArray(aDadosInc)
	FwFreeArray(aEmprCent)
	FwFreeArray(aError)
	FwFreeArray(aSuccess)

Return oErros

/*/{Protheus.doc} clearPend
Limpa as pendências de estoque dos registros que não possuem quantidade.

@type  Static Function
@author lucas.franca
@since 15/08/2019
@version P12.1.28
@param 01 cUUID  , Character, Identificador do processo na tabela T4R
@param 02 cStatus, Character, Identificador do status na tabela T4R
/*/
Static Function clearPend(cUUID, cStatus)
	Local cSql   := ""
	Local cError := ""

	cSql := "UPDATE " + RetSqlName("T4R")
	cSql +=   " SET D_E_L_E_T_   = '*', "
	cSql +=       " R_E_C_D_E_L_ = R_E_C_N_O_ "
	cSql += " WHERE T4R_FILIAL = '" + xFilial("T4R") + "' "
	cSql +=   " AND T4R_API    IN ('MRPSTOCKBALANCE', 'MRPREJECTEDINVENTORY') "
	cSql +=   " AND T4R_STATUS = '" + cStatus + "' "
	cSql +=   " AND T4R_IDPRC  = '" + cUUID   + "' "
	cSql +=   " AND D_E_L_E_T_ = ' ' "

	If TcSqlExec(cSql) < 0
		cError := Replicate("-",70)
		cError += CHR(10)
		cError += STR0014 //"Erro ao eliminar as pendências de processamento."
		cError += CHR(10)
		cError += cSql
		cError += CHR(10)
		cError += TcSqlError()
		cError := Replicate("-",70)

		LogMsg('PCPA141RUN', 0, 0, 1, '', '', cError)
		Final(STR0014, TcSqlError()) //"Erro ao eliminar as pendências de processamento."
	EndIf

Return


/*/{Protheus.doc} getFilsSMQ
Retorna as filiais cadastradas na tabela SMQ para o processamento.
@type  Static Function
@author Vivian Beatriz de Almeida
@since 29/05/2025
@version P12
@return aFiliais, Array, Arra com as filiais que estão cadastradas na tabela SMQ.
/*/
Static Function getFilsSMQ()
	Local aFiliais := {}

	SMQ->(dbGoTop())
	While SMQ->(!Eof())
		aAdd(aFiliais, {cEmpAnt, SMQ->MQ_CODFIL})
		SMQ->(dbSKip())
	End

Return aFiliais

/*/{Protheus.doc} getFilsSMQ
Se for uma execução via schedule, procura por pendências de estoque não eliminadas, e elimina.
@type  Static Function
@author Vivian Beatriz de Almeida
@since 29/05/2025
@version P12
@return aFiliais, Array, Arra com as filiais que estão cadastradas na tabela SMQ.
/*/
Static Function delPendT4R( cUUID)
	Local cAlias    := ""
	Local cQuery    := ""

	cQuery += " SELECT T4R.R_E_C_N_O_ REC"
	cQuery +=   " FROM " + RetSqlName("T4R") + " T4R"
	cQuery +=  " WHERE T4R.T4R_FILIAL = '" + xFilial("T4R") + "'"
	cQuery +=    " AND T4R.T4R_API    = 'MRPSTOCKBALANCE'"
	cQuery +=    " AND T4R.T4R_IDPRC  = '" + cUUID + "'"
	cQuery +=    " AND T4R.D_E_L_E_T_ = ' '"
		
	cAlias := PCPAliasQr()

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.F.)
	While (cAlias)->(!Eof())
		T4R->(dbGoTo((cAlias)->(REC)))
		RecLock("T4R", .F.)
			T4R->(dbDelete())
		T4R->(MsUnLock())
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} CargEmprC
Carrega empresas centralizadas cadastradas no PCPA106
@type  Static Function
@author Vivian Beatriz de Almeida
@since 13/06/2025
@version 1.0
@param 01 cEmp, char, Empresa centralizadora (opcional, cEmpAnt qdo não informado)
@param 02 cFil, char, Filial centralizadora (opcional, cFilAnt qdo não informado)
@return aEmpresasC, array, Empresas centralizadas
						aEmpresasC[1][1] = Código da empresa centralizada
						aEmpresasC[1][2] = Filial da empresa centralizada
/*/
Static Function CargEmprC(cEmp,cFil)
	Local cQuery     := ""
	Local cAliasQry  := "CARGEMPRC"
	Local aInfoFil   := {}
	Local cGrpEmp    := ""
	Local cCodEmp    := ""
	Local cCodUNeg   := ""
	Local cCodFil    := ""
	Local aEmpresasC := {}
	Local nTamOOGE   := GetSx3Cache("OP_CDEPCZ", "X3_TAMANHO")
	Local nTamOOEmp  := GetSx3Cache("OP_EMPRCZ", "X3_TAMANHO")
	Local nTamOOUnid := GetSx3Cache("OP_UNIDCZ", "X3_TAMANHO")
	Local nTamOOFil  := GetSx3Cache("OP_CDESCZ", "X3_TAMANHO")
	Local nTamEmp    := Len(FWSM0Layout(cEmpAnt,1))
	Local nTamUNeg   := Len(FWSM0Layout(cEmpAnt,2))
	Local nTamFil    := Len(FWSM0Layout(cEmpAnt,3))
	Local nTamSM0    := FWSizeFilial(cEmpAnt)
	Default cEmp := cEmpAnt
	Default cFil := cFilAnt

	aInfoFil := FWArrFilAtu(cEmp, cFil)

	If Len(aInfoFil) > 0
		aAdd(aEmpresasC, {cEmp,cFil})

		cGrpEmp  := PadR(aInfoFil[SM0_GRPEMP] , nTamOOGE)
		cCodEmp  := PadR(aInfoFil[SM0_EMPRESA], nTamOOEmp)
		cCodUNeg := PadR(aInfoFil[SM0_UNIDNEG], nTamOOUnid)
		cCodFil  := PadR(aInfoFil[SM0_FILIAL] , nTamOOFil)

		cQuery := " SELECT SOP.OP_CDEPGR, SOP.OP_EMPRGR, SOP.OP_UNIDGR, SOP.OP_CDESGR "
		cQuery +=   " FROM " + RetSqlName("SOP") + " SOP"
		cQuery +=  " WHERE SOP.OP_FILIAL = '" + xFilial("SOP") + "' "
		cQuery +=    " AND SOP.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND SOP.OP_CDEPCZ = '" + cGrpEmp + "' "
		cQuery +=    " AND SOP.OP_EMPRCZ = '" + cCodEmp + "' "
		cQuery +=    " AND SOP.OP_UNIDCZ = '" + cCodUNeg + "' "
		cQuery +=    " AND SOP.OP_CDESCZ = '" + cCodFil + "'"

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		While (cAliasQry)->(!Eof())
			cFil := PadR(PadR((cAliasQry)->(OP_EMPRGR),nTamEmp) + PadR((cAliasQry)->(OP_UNIDGR),nTamUNeg) + PadR((cAliasQry)->(OP_CDESGR),nTamFil),nTamSM0)
			aAdd(aEmpresasC,{AllTrim((cAliasQry)->(OP_CDEPGR)),cFil})
			(cAliasQry)->(dbSkip())
		End
		(cAliasQry)->(dbCloseArea())
	EndIf
Return aEmpresasC
