
#Include "protheus.ch"

Static __aPrepared := {} as Array

/*/{Protheus.doc} ACExeConsI
Job executado em background para reprocessar MATA290 e MATA560
@type    Function
@author  Paulo Dias Oliveira / Squad Retail
@since   11/05/2026
@version P12
/*/
Function ACExeConsI(aListFil, cCompany, cBranch)
	Local aArea       As Array
	Local nX          As Numeric
	Local cAliasD4R   As Character
	Local dDataRef    As Date
	Local dDataRefBkp As Date
	Local oQuery      As Object
	Local cQuery      As Character
	Local nParam      As Numeric

	Default aListFil   := {}
	Default cCompany   := ""
	Default cBranch    := ""

	// Prepara ambiente base na primeira thread
	RPCSetEnv(cCompany, cBranch)

	nX          := 1
	dDataRefBkp := dDataBase
	aArea       := FWGetArea()

	// A data de referencia a ser usada deve ser gerada pelo ultimo fechamento
	dDataRef  := SuperGetMv("MV_ULMES")
	dDataBase := dDataRef

	// Processar MATA290 (Consumo e Indicadores)
	cQuery := " SELECT D4R.D4R_COD"
	cQuery +=   " FROM " + RetSqlName("D4R") + " D4R"
	cQuery +=  " WHERE D4R.D4R_FILIAL = ?"  // #1
	cQuery +=    " AND D4R.D_E_L_E_T_ = ?"  // #2

	// Itera pela lista de filiais preenchidas na jornada
	For nX := 1 To Len(aListFil)
		// Verifica se a filial da iteracao esta marcada como .T. para fechamento
		If ValType(aListFil[nX]) == "A" .And. aListFil[nX, 1] == .T.
			// Troca de Filial no ambiente assincrono
			RpcClearEnv()
			RPCSetEnv(cCompany, aListFil[nX, 2])

			oQuery := ACGetQry(cQuery)
		
			// Binding dos parâmetros na ordem
			nParam := 1
			oQuery:SetString(nParam++, FWxFilial("D4R")) // #1
			oQuery:SetString(nParam++, Space(1))         // #2

			cAliasD4R := GetNextAlias()
			oQuery:OpenAlias(cAliasD4R)

			While !(cAliasD4R)->(Eof())
				// Dispara MATA290 em modo Batch (lBat = .T.)
				MATA290(.T., Nil, .F., (cAliasD4R)->D4R_COD)
				
				(cAliasD4R)->(DbSkip())
			EndDo

			(cAliasD4R)->(DbCloseArea())

			// Processar MATA560 (Atualização do Consumo de Vendas)
			MATA560(.T., {aListFil[nX, 2]})
		EndIf
	Next nX

	// Restaura o dDataBase original da thread no termino do job
	dDataBase := dDataRefBkp

	// Restaura ambiente do processo principal (D4R)
	FWRestArea(aArea)
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ACGetQry
Obtém a query preparada para execução

@sample     ACGetQry(cQuery)
@type       Function
@param      cQuery, Character, Expressão SQL
@author     Paulo Dias Oliveira / Squad Retail
@since      20/05/2026
@version    P12
@return     oPrepared, Object, Objeto de query preparada
/*/
//------------------------------------------------------------------------------
Static Function ACGetQry(cQuery)
	Local oPrepared    As Object
	Local nPosPrepared As Numeric
	Local cMD5         As Character
	
	Default cQuery := ""

	cMD5 := MD5(cQuery)
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrepared,{FwExecStatement():New(cQuery), cMD5})
		nPosPrepared := Len(__aPrepared)
	Endif

	oPrepared := __aPrepared[nPosPrepared][1]
Return oPrepared
