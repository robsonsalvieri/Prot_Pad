#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "fata901.ch"
#INCLUDE 'fwlibversion.ch'

Static __aPrepared  := {}

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FATA901
  Realiza Carga Inicial do Dashboard
  @author Squad CRM & Faturamento
  @since 27/03/2020
  @version Protheus 12
/*/
//---------------------------------------------------------------------------------------------------
function FATA901()
	Local aAreaA1N := A1N->(GetArea())
	Local aAreaA1O := A1O->(GetArea())
	Local aAreaA1P := A1P->(GetArea())
	Local aAreaA1Q := A1Q->(GetArea())
	Local aAreaA1R := A1R->(GetArea())
	Local aTabelas := {}

	aTabelas := { ;
					"A1N", ;
					"A1O", ;
					"A1P", ;
					"A1Q", ;
					"A1R"  ;
				}

	CargaDados(aTabelas)

	FAT901FIN1()

	RestArea(aAreaA1N)
	RestArea(aAreaA1O)
	RestArea(aAreaA1P)
	RestArea(aAreaA1Q)
	RestArea(aAreaA1R)

	FwFreeObj(aTabelas)
	FwFreeObj(aAreaA1N)
	FwFreeObj(aAreaA1O)
	FwFreeObj(aAreaA1P)
	FwFreeObj(aAreaA1Q)
	FwFreeObj(aAreaA1R)
return nil

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CargaDados
  Efetua a carga dos dados nas tabelas informadas no parâmetro aTabelas para dentro do Dashboard 
  @type function
  @author Squad CRM & Faturamento
  @since 27/03/2020
  @param aTabelas, array, lista com as tabelas que deverao ser carregadas com as configuracoes do dashboard
  @return Nil, undefined, Esta funcao nao tem retorno
/*/
//-------------------------------------------------------------------------------------------------------------
static function CargaDados(aTabelas)

	Local aRegs      := {}
	Local cTabela    := "" 
	Local nQtTabelas := 0
	Local nTabela    := 0
	Local aCarga     := {}

	Default aTabelas    := {}

	nQtTabelas := Len(aTabelas)

	For nTabela := 1 To nQtTabelas
		cTabela    := aTabelas[nTabela]

		// Carga dos dados criados na expedição inicial do Dashboard
		If !(cTabela)->(DbSeek(xFilial(cTabela)))
			Do Case
				Case cTabela == "A1N"
					aRegs := A1NInicial()
				Case cTabela == "A1O"
					aRegs := A1OInicial()
				Case cTabela == "A1P"
					aRegs := A1PInicial()
				Case cTabela == "A1Q"
					aRegs := A1QInicial()
				Case cTabela == "A1R"
					aRegs := A1RInicial()
			End Case
		EndIf

		// Carga dos dados de atualização adicionais do Dashboard, apos implantacao
		Do Case
			Case cTabela == "A1N"
				aRegs := A1NAtualiz(aRegs)
			Case cTabela == "A1P"
				aRegs := A1PAtualiz(aRegs)
		End Case
		If !(Empty(aRegs))
			aAdd(aCarga, {cTabela, aClone(aRegs)})
			FwFreeObj(aRegs)
		EndIf
	Next

	EscreveDados(aCarga)

	FwFreeObj(aCarga)
return nil


//----------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EscreveDados
  Escreve os dados da carga de dados nas tabelas do Dashboard informadas no parâmetro aCarga
  @type function
  @author Squad CRM & Faturamento
  @since 27/03/2020
  @param aCarga, array, array contendo o alias da tabela e os dados de cada um dos campos e seu respectivo dado a ser carregado na tabela
  @return nil, undefined, a funcao nao tem retorno definido
/*/
//----------------------------------------------------------------------------------------------------------------------------------------
static function EscreveDados(aCarga)
	Local nRegistro  := 0
	Local nCampo     := 0
	Local nQtTabelas := 0
	Local nTabela    := 0
	Local cTabela    := "" 
	Local aRegistros := {}

	nQtTabelas := Len(aCarga)
	For nTabela := 1 To nQtTabelas
		cTabela    := aCarga[nTabela][1]
		aRegistros := aCarga[nTabela][2]

		For nRegistro := 1 to Len(aRegistros)
			RecLock(cTabela, .T.)
			For nCampo := 1 To Len(aRegistros[nRegistro])
				FieldPut(FieldPos(aRegistros[nRegistro][nCampo][1]) , aRegistros[nRegistro][nCampo][2])
			Next
			(cTabela)->(MsUnlock())
		Next
		FwFreeObj(aRegistros)
	Next
Return Nil

//------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldAtualiz
  Valida se os novos registros a serem incluidos informados no parametro aRegs devem ser considerados na carga de dados ou nao caso ja existem no banco de dados
  @type function
  @author Squad CRM & Faturamento
  @since 06/04/2023
  @param cTab      , character, alias da tabela dos registros a serem validados
  @param aRegs     , array    , array com os registros a serem validados
  @param aValidRegs, array    , lista com os registos carregados anteriormente e os dados que agora foram validados e que devem ser considerados na carga de dados
  @return aValidRegs, array, lista com os registos carregados anteriormente e os dados que agora foram validados e que devem ser considerados na carga de dados
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------------
static function vldAtualiz(cTab, aRegs, aValidRegs)
	Local nPosStatement := 0
	Local oStatement    := Nil
	Local cQuery        := ""
	Local nQtFields     := 0
	Local nField        := 0
	Local cAlias        := GetNextAlias()
	Local aReg          := {}
	Local nReg          := 0
	Local nQtdRegs      := 0

	Default cTab       := ""
	Default aRegs      := {}
	Default aValidRegs := {}

	nQtdRegs := Len(aRegs)

	For nReg := 1 To nQtdRegs

		aReg := aRegs[nReg]

		cQuery	:= " SELECT 'FOUND' AS FOUND "
		cQuery	+= " FROM " + RetSqlName(cTab) + " " + cTab + " "
		cQuery	+= " WHERE "

		nQtFields := Len(aReg)

		For nField := 1 To nQtFields
			If ("_ID" $ aReg[nField][1])
				Loop
			EndIf
			If ValType(aReg[nField][2]) == "C"
				cQuery += " " + aReg[nField][1] + " = '" + aReg[nField][2] + "' AND "
			ElseIf ValType(aReg[nField][2]) == "N"
				cQuery += " " + aReg[nField][1] + " = " + AllTrim(cValToChar(aReg[nField][2])) + " AND "
			EndIf
		Next 
		
		cQuery  += " " + cTab + ".D_E_L_E_T_ = ' ' "

		nPosStatement := chargeAPrepared(cQuery)
		oStatement := __aPrepared[nPosStatement][1]
		execQueryAPrepared(cAlias, oStatement)

		If (cAlias)->(EOF())
			aAdd(aValidRegs, aClone(aReg))
		EndIf

		(cAlias)->(DBCloseArea())
		FwFreeObj(aReg)
	Next

Return aValidRegs

//----------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getID
  Retorna o ID do campo informado nos parâmetros da função caso ele nao exista no banco de dados ou gera e retorna um novo
  @type function
  @author Squad CRM & Faturamento
  @since 06/04/2023
  @return cID, character, ID informado no parametro cID ou um ID novo caso o mesmo ja exista no banco de dados da tabela indicada
/*/
//----------------------------------------------------------------------------------------------------------------------------------
static function getID(cAlias, cCampo, cID)

	Default cAlias := ""
	Default cCampo := "" 
	Default cID    := ""

	DbSelectArea(cAlias)
	(cAlias)->(DbSetOrder(1))	//A1?_FILIAL + A1?_ID
	If ((cAlias)->(DbSeek(FwXFilial(cAlias) + cID)))
		cId := GetSxENum(cAlias, cCampo)
		ConfirmSX8()
	EndIf

Return cID

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} A1NInicial
  Retorna um array com os tipos de Card do Dashboard criados inicialmente para a aplicacao
  @type function
  @author Squad CRM & Faturamento
  @since 05/04/2023
  @return aRet, array, Lista com os dados dos registros A1N Iniciais do Dashboard
/*/
//------------------------------------------------------------------------------------------
static function A1NInicial()
	Local aRet  := {}
	Local cFilialA1N := FwxFilial('A1N')

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000000"},;
		{"A1N_CARSER ", "/MODCARD/cards/cardInfo/aptos"},;
		{"A1N_FLDSER ", "/MODCARD/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/MODCARD/cards/itemsDetails/aptos"},;
		{"A1N_CABSER ", "/MODCARD/cards/headerItens"},;
		{"A1N_TITULO ", STR0001}; // "CARD MODELO"
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000001"},;
		{"A1N_CARSER ", "/FATD001/cards/cardInfo/aptos"},;
		{"A1N_FLDSER ", "/FATD001/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/FATD001/cards/itemsDetails/aptos"},;
		{"A1N_CABSER ", "/FATD001/cards/headerItens"},;
		{"A1N_TITULO ", STR0002}; // Pedidos Aptos a Faturar
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000002"},;
		{"A1N_CARSER ", "/FATD001/cards/cardInfo/est"},;
		{"A1N_FLDSER ", "/FATD001/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/FATD001/cards/itemsDetails/est"},;
		{"A1N_CABSER ", "/FATD001/cards/headerItens"},;
		{"A1N_TITULO ", STR0003}; // Total de Pedidos com Bloqueio de Estoque
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000003"},;
		{"A1N_CARSER ", "/FATD001/cards/cardInfo/cred"},;
		{"A1N_FLDSER ", "/FATD001/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/FATD001/cards/itemsDetails/cred"},;
		{"A1N_CABSER ", "/FATD001/cards/headerItens"},;
		{"A1N_TITULO ", STR0004}; // Total de Pedidos com Bloqueio de Crédito
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000004"},;
		{"A1N_CARSER ", "/FATD001/cards/cardInfo/credest"},;
		{"A1N_FLDSER ", "/FATD001/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/FATD001/cards/itemsDetails/credest"},;
		{"A1N_CABSER ", "/FATD001/cards/headerItens"},;
		{"A1N_TITULO ", STR0005}; // Total de Pedidos com Bloqueio de Crédito e Estoque
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000005"},;
		{"A1N_CARSER ", "/FD100CNat/cards/cardInfo/previsto"},;
		{"A1N_FLDSER ", "/FD100CNat/cards/fieldsInfo/previsto"},;
		{"A1N_ITSER  ", "/FD100CNat/cards/itemsDetails/previsto"},;
		{"A1N_CABSER ", "/FD100CNat/cards/headerItens"},;
		{"A1N_TITULO ", STR0006}; // Movimento Naturezas Previsto
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000006"},;
		{"A1N_CARSER ", "/FD100CNat/cards/cardInfo/realizado"},;
		{"A1N_FLDSER ", "/FD100CNat/cards/fieldsInfo/realizado"},;
		{"A1N_ITSER  ", "/FD100CNat/cards/itemsDetails/realizado"},;
		{"A1N_CABSER ", "/FD100CNat/cards/headerItens"},;
		{"A1N_TITULO ", STR0007}; // Movimento Naturezas Realizado
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000007"},;
		{"A1N_CARSER ", "/COMD010/cards/cardInfo"},;
		{"A1N_FLDSER ", "/COMD010/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/COMD010/cards/itemsDetails"},;
		{"A1N_CABSER ", "/COMD010/cards/headerItens"},;
		{"A1N_TITULO ", STR0008}; //Lead Time Solicitação de Compras x Pedido de Compras
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000008"},;
		{"A1N_CARSER ", "/COMD030/cards/cardInfo"},;
		{"A1N_FLDSER ", "/COMD030/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/COMD030/cards/itemsDetails"},;
		{"A1N_CABSER ", "/COMD030/cards/headerItens"},;
		{"A1N_TITULO ", STR0009}; // Lead Time Pedido de Compras x Nota Fiscal de Entrada
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000009"},;
		{"A1N_CARSER ", "/CardEst01/cards/cardInfo"},;
		{"A1N_FLDSER ", "/CardEst01/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/CardEst01/cards/itemsDetails"},;
		{"A1N_CABSER ", "/CardEst01/cards/headerItens"},;
		{"A1N_TITULO ", STR0010}; // Quantidade e Valor em Estoque
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000010"},;
		{"A1N_CARSER ", "/CardEst02/cards/cardInfo"},;
		{"A1N_FLDSER ", "/CardEst02/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/CardEst02/cards/itemsDetails"},;
		{"A1N_CABSER ", "/CardEst02/cards/headerItens"},;
		{"A1N_TITULO ", STR0011}; // Lotes Vencidos
	})

	aAdd(aRet,{;
		{"A1N_FILIAL ", cFilialA1N},;
		{"A1N_ID     ", "000011"},;
		{"A1N_CARSER ", "/CardEst03/cards/cardInfo"},;
		{"A1N_FLDSER ", "/CardEst03/cards/fieldsInfo"},;
		{"A1N_ITSER  ", "/CardEst03/cards/itemsDetails"},;
		{"A1N_CABSER ", "/CardEst03/cards/headerItens"},;
		{"A1N_TITULO ", STR0012}; // Itens a Endereçar
	})

return aRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A1NAtualiz
  Retorna um array com os tipos de Card do Dashboard a serem Atualizados
  @type function
  @author Squad CRM & Faturamento
  @since 06/04/2023
  @param aRet, array, Lista com os dados dos registros Iniciais da tabela A1N, caso tenham sido carregados anteriormente
  @return aRet, array, Lista com os dados dos registros Iniciais da tabela A1N, caso tenham sido carregados anteriormente e os Novos se nao existirem no banco de dados
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
static function A1NAtualiz(aRet)
	Local cFilialA1N  := FwxFilial('A1N')
	Local aValidRegs  := {}
	
	Default aRet  := {}

	aAdd(aValidRegs,	{;
						{"A1N_FILIAL ", cFilialA1N},;
						{"A1N_ID     ", getID("A1N", "A1N_ID", "000012")},;
						{"A1N_CARSER ", "/ProdFiscal/cards/tributos/cardInfo/ICMS"},;
						{"A1N_FLDSER ", "/ProdFiscal/cards/tributos/fieldsInfo/ICMS"},;
						{"A1N_ITSER  ", "/ProdFiscal/cards/tributos/itemsDetails/ICMS"},;
						{"A1N_CABSER ", "/ProdFiscal/cards/tributos/headerItens"},;
						{"A1N_TITULO ", STR0091}; //"Notas com Tributos de ICMS"
					})

	aAdd(aValidRegs,	{;
						{"A1N_FILIAL ", cFilialA1N},;
						{"A1N_ID     ", getID("A1N", "A1N_ID", "000013")},;
						{"A1N_CARSER ", "/ProdFiscal/cards/tributos/cardInfo/ISS"},;
						{"A1N_FLDSER ", "/ProdFiscal/cards/tributos/fieldsInfo/ISS"},;
						{"A1N_ITSER  ", "/ProdFiscal/cards/tributos/itemsDetails/ISS"},;
						{"A1N_CABSER ", "/ProdFiscal/cards/tributos/headerItens"},;
						{"A1N_TITULO ", STR0092}; //"Notas com Tributos de ISS"
					})

	aAdd(aValidRegs,	{;
						{"A1N_FILIAL ", cFilialA1N},;
						{"A1N_ID     ", getID("A1N", "A1N_ID", "000014")},;
						{"A1N_CARSER ", "/ProdFiscal/cards/tributos/cardInfo/IPI"},;
						{"A1N_FLDSER ", "/ProdFiscal/cards/tributos/fieldsInfo/IPI"},;
						{"A1N_ITSER  ", "/ProdFiscal/cards/tributos/itemsDetails/IPI"},;
						{"A1N_CABSER ", "/ProdFiscal/cards/tributos/headerItens"},;
						{"A1N_TITULO ", STR0093}; //"Notas com Tributos de IPI"
					})

	aAdd(aValidRegs,	{;
						{"A1N_FILIAL ", cFilialA1N},;
						{"A1N_ID     ", getID("A1N", "A1N_ID", "000015")},;
						{"A1N_CARSER ", "/ProdFiscal/cards/tributos/cardInfo/PIS"},;
						{"A1N_FLDSER ", "/ProdFiscal/cards/tributos/fieldsInfo/PIS"},;
						{"A1N_ITSER  ", "/ProdFiscal/cards/tributos/itemsDetails/PIS"},;
						{"A1N_CABSER ", "/ProdFiscal/cards/tributos/headerItens"},;
						{"A1N_TITULO ", STR0094}; //"Notas com Tributos de PIS"
					})

	aAdd(aValidRegs,	{;
						{"A1N_FILIAL ", cFilialA1N},;
						{"A1N_ID     ", getID("A1N", "A1N_ID", "000016")},;
						{"A1N_CARSER ", "/ProdFiscal/cards/tributos/cardInfo/COFINS"},;
						{"A1N_FLDSER ", "/ProdFiscal/cards/tributos/fieldsInfo/COFINS"},;
						{"A1N_ITSER  ", "/ProdFiscal/cards/tributos/itemsDetails/COFINS"},;
						{"A1N_CABSER ", "/ProdFiscal/cards/tributos/headerItens"},;
						{"A1N_TITULO ", STR0095}; //"Notas com Tributos de COFINS"
					})

	aRet := vldAtualiz("A1N", aValidRegs, aRet)
	FwFreeObj(aValidRegs)

return aRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} A1OInicial
  Retorna um array com Cards do Dashboard criados inicialmente para a aplicacao
  @type function
  @author Squad CRM & Faturamento
  @since 05/04/2023
  @return aRet, array, Lista com os dados dos registros A1O iniciais do Dashboard
/*/
//----------------------------------------------------------------------------------
static function A1OInicial()
	Local aRet  := {}
	Local cFilialA1O := FwxFilial("A1O")

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0002},; // Pedidos Aptos a Faturar
		{"A1O_INFO1 ", "totalOrder"},;
		{"A1O_INFO2 ", "totalItens"},;
		{"A1O_INFO3 ", "totalDup"},;
		{"A1O_INFO4 ", "totalFat"},;
		{"A1O_CAMPOS", "totalOrder,totalItens,totalDup,totalFat"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000001"},;
		{"A1O_LABEL1", STR0013},; // Total de Pedidos:
		{"A1O_LABEL2", STR0014},;   // Total de Itens:
		{"A1O_LABEL3", STR0015},; // Total de Duplicata:
		{"A1O_LABEL4", STR0016},; // Valor Total:
		{"A1O_ID    ", "000001"},;
		{"A1O_HELP  ", STR0017},; // Exibe o total de pedidos aptos a faturar.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0018},; // Pedidos com Bloq de Crédito
		{"A1O_INFO1 ", "totalOrder"},;
		{"A1O_INFO2 ", "totalItens"},;
		{"A1O_INFO3 ", "totalDup"},;
		{"A1O_INFO4 ", "totalFat"},;
		{"A1O_CAMPOS", "totalOrder,totalItens,totalDup,totalFat"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000003"},;
		{"A1O_LABEL1", STR0013},; // Total de Pedidos:
		{"A1O_LABEL2", STR0014},; // Total de Itens:
		{"A1O_LABEL3", STR0015},; // Total de Duplicata:
		{"A1O_LABEL4", STR0016},; // Valor Total:
		{"A1O_ID    ", "000002"},;
		{"A1O_HELP  ", STR0019},; // "Exibe total dos pedidos com bloqueio de crédito."
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0020},; // Pedidos com Bloq de Estoque
		{"A1O_INFO1 ", "totalOrder"},;
		{"A1O_INFO2 ", "totalItens"},;
		{"A1O_INFO3 ", "totalDup"},;
		{"A1O_INFO4 ", "totalFat"},;
		{"A1O_CAMPOS", "totalOrder,totalItens,totalDup,totalFat"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000002"},;
		{"A1O_LABEL1", STR0013},; // Total de Pedidos:
		{"A1O_LABEL2", STR0014},; // Total de Itens:
		{"A1O_LABEL3", STR0015},; // Total de Duplicata:
		{"A1O_LABEL4", STR0016},; // Valor Total:
		{"A1O_ID    ", "000003"},;
		{"A1O_HELP  ", STR0021},; // Exibe total dos pedidos com bloqueio de estoque.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0022},; // Pedidos com Bloq de Créd/Est
		{"A1O_INFO1 ", "totalOrder"},;
		{"A1O_INFO2 ", "totalItens"},;
		{"A1O_INFO3 ", "totalDup"},;
		{"A1O_INFO4 ", "totalFat"},;
		{"A1O_CAMPOS", "totalOrder,totalItens,totalDup,totalFat"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000004"},;
		{"A1O_LABEL1", STR0013},; // Total de Pedidos:
		{"A1O_LABEL2", STR0014},; // Total de Itens:
		{"A1O_LABEL3", STR0015},; // Total de Duplicata:
		{"A1O_LABEL4", STR0016},; // Valor Total:
		{"A1O_ID    ", "000004"},;
		{"A1O_HELP  ", STR0023},; // Exibe total dos pedidos com bloqueio de crédito e estoque.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0024},; // Lead Time SC x PC
		{"A1O_INFO1 ", "leadTime"},;
		{"A1O_INFO2 ", "totalAberto"},;
		{"A1O_INFO3 ", "totalFinal"},;
		{"A1O_INFO4 ", "totalSC"},;
		{"A1O_CAMPOS", "leadTime,totalAberto,totalFinal,totalSC"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000007"},;
		{"A1O_LABEL1", STR0025},; // Lead Time:
		{"A1O_LABEL2", STR0026},; // Solicitacoes em Atendimento:
		{"A1O_LABEL3", STR0027},; // Solicitacoes Finalizadas:
		{"A1O_LABEL4", STR0028},; // Total de Solicitacoes:
		{"A1O_ID    ", "000005"},;
		{"A1O_HELP  ", STR0029},; // Exibe o Lead Time da Solicitação de Compras em relação ao Pedido de Compras.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0030},; // Lead Time PC x NF
		{"A1O_INFO1 ", "leadTime"},;
		{"A1O_INFO2 ", "totalAberto"},;
		{"A1O_INFO3 ", "totalFinal"},;
		{"A1O_INFO4 ", "totalPC"},;
		{"A1O_CAMPOS", "leadTime,totalAberto,totalFinal,totalPC"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000008"},;
		{"A1O_LABEL1", STR0025},; // Lead Time:
		{"A1O_LABEL2", STR0031},; // Pedidos em Atendimento:
		{"A1O_LABEL3", STR0032},; // Pedidos Finalizados:
		{"A1O_LABEL4", STR0013},; // Total de Pedidos:
		{"A1O_ID    ", "000006"},;
		{"A1O_HELP  ", STR0033},; // Exibe o Lead Time do Pedido de Compras em relação a Nota Fiscal de Entrada.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0034},; // Quantidade e Valor em Estoque
		{"A1O_INFO1 ", "quant"},;
		{"A1O_INFO2 ", "total"},;
		{"A1O_CAMPOS", "quant,total,,"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000009"},;
		{"A1O_LABEL1", STR0035},; // Quantidade de Produtos:
		{"A1O_LABEL2", STR0016},; // Valor Total:
		{"A1O_ID    ", "000007"},;
		{"A1O_HELP  ", STR0036},; // Exibe total de produtos e valor em estoque.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0011},; // Lotes Vencidos
		{"A1O_INFO1 ", "produto"},;
		{"A1O_INFO2 ", "lote"},;
		{"A1O_CAMPOS", "produto,lote,,"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000010"},;
		{"A1O_LABEL1", STR0033},; // Quantidade de Produtos:
		{"A1O_LABEL2", STR0011 + ":"},; //Lotes Vencidos:
		{"A1O_ID    ", "000008"},;
		{"A1O_HELP  ", STR0037},; // Exibe total de produtos e lotes vencidos em estoque.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0012},; // Itens a Endereçar
		{"A1O_INFO1 ", "Docs"},;
		{"A1O_INFO2 ", "QtdProd"},;
		{"A1O_CAMPOS", "Docs,QtdProd,,"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000011"},;
		{"A1O_LABEL1", STR0038},; // Quantidade de Documentos:
		{"A1O_LABEL2", STR0035},; // Quantidades de Produtos:
		{"A1O_ID    ", "000009"},;
		{"A1O_HELP  ", STR0039},; // Exibe total de documentos e produtos pendentes a endereçar
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0040},; // Mov. Natureza Previsto
		{"A1O_INFO1 ", "prevreceita"},;
		{"A1O_INFO2 ", "prevdespesa"},;
		{"A1O_INFO3 ", "null"},;
		{"A1O_INFO4 ", "null"},;
		{"A1O_CAMPOS", "prevreceita,prevdespesa,null,null"},;
		{"A1O_EXPFIL", STR0041},; // Data Vencimento Real >= 01/01/2021 E Data Vencimento Real <= 31/07/2021
		{"A1O_ENDFIL", "ge_dtvencrea=01/01/2021&le_dtvencrea=31/07/2021"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000005"},;
		{"A1O_LABEL1", STR0042},; // Previsto Receita:
		{"A1O_LABEL2", STR0043},; // Previsto Despesas:
		{"A1O_LABEL3", ""},;
		{"A1O_LABEL4", ""},;
		{"A1O_ID    ", "000010"},;
		{"A1O_HELP  ", STR0044},; // Informação de help para o Card.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0045},; // Mov. Naturezas Realizado
		{"A1O_INFO1 ", "realreceita"},;
		{"A1O_INFO2 ", "realdespesa"},;
		{"A1O_INFO3 ", "null"},;
		{"A1O_INFO4 ", "null"},;
		{"A1O_CAMPOS", "realreceita,realdespesa,null,null"},;
		{"A1O_EXPFIL", STR0041},; // Data Vencimento Real >= 01/01/2021 E Data Vencimento Real <= 31/07/2021
		{"A1O_ENDFIL", "ge_dtvencrea=01/01/2021&le_dtvencrea=31/07/2021"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000006"},;
		{"A1O_LABEL1", STR0046},; // Realizado Receita:
		{"A1O_LABEL2", STR0047},; // Realizado Despesas:
		{"A1O_LABEL3", ""},;
		{"A1O_LABEL4", ""},;
		{"A1O_ID    ", "000011"},;
		{"A1O_HELP  ", STR0048},; // Informação de help para o Card.
		{"A1O_FILTRO", "1"};
	})

	aAdd(aRet, {;
		{"A1O_FILIAL", cFilialA1O},;
		{"A1O_TITULO", STR0001},; // "Card Modelo"
		{"A1O_INFO1 ", "totalFat"},;
		{"A1O_INFO2 ", "totalDup"},;
		{"A1O_CAMPOS", "totalFat,totalDup,,"},;
		{"A1O_STATUS", "1"},;
		{"A1O_IDTIPO", "000000"},;
		{"A1O_LABEL1", STR0049},; // Modelo 1:
		{"A1O_LABEL2", STR0050},; // Modelo 2:
		{"A1O_ID    ", "000000"},;
		{"A1O_HELP  ", STR0051},; // Informações sobre Help do card - CARD MODELO.
		{"A1O_FILTRO", "1"};
	})

Return aRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} A1PInicial
  Retorna um array com os Tipos de Gráficos criados inicialmente para a aplicacao
  @type function
  @author Squad CRM & Faturamento
  @since 05/04/2023
  @return aRet, array, Lista com os dados dos registros A1P iniciais do Dashboard
/*/
//----------------------------------------------------------------------------------
static function A1PInicial()
	Local aRet  := {}
	Local cFilialA1P := FwxFilial("A1P")

	aAdd(aRet, {;
		{"A1P_FILIAL", cFilialA1P},;
		{"A1P_ID    ", "000000"},;
		{"A1P_SRVFOR", "/MODCHART/charts/form"},;
		{"A1P_SRVDAT", "/MODCHART/charts/retdados"},;
		{"A1P_TITULO", STR0052},; // Gráfico Modelo
		{"A1P_MAXNIV", 1},;
		{"A1P_ITSERV", "/MODCHART/charts/itemsDetails"};
	})

	aAdd(aRet, {;
		{"A1P_FILIAL", cFilialA1P},;
		{"A1P_ID    ", "000001"},;
		{"A1P_SRVFOR", "/GEst01/charts/form"},;
		{"A1P_SRVDAT", "/GEst01/charts/retDados"},;
		{"A1P_TITULO", STR0053},; // Lotes a Vencer
		{"A1P_MAXNIV", 2},;
		{"A1P_ITSERV", "/GEst01/charts/itemsDetails"};
	})

	aAdd(aRet, {;
		{"A1P_FILIAL", cFilialA1P},;
		{"A1P_ID    ", "000002"},;
		{"A1P_SRVFOR", "/GEst02/charts/form"},;
		{"A1P_SRVDAT", "/GEst02/charts/retDados"},;
		{"A1P_TITULO", STR0054},; // Evolução dos Estoques por Fechamento
		{"A1P_MAXNIV", 2},;
		{"A1P_ITSERV", "/GEst02/charts/itemsDetails"};
	})

	aAdd(aRet, {;
		{"A1P_FILIAL", cFilialA1P},;
		{"A1P_ID    ", "000003"},;
		{"A1P_SRVFOR", "/FATD002/charts/form"},;
		{"A1P_SRVDAT", "/FATD002/charts/retdados"},;
		{"A1P_TITULO", STR0055},; // Notas Fiscais por UF
		{"A1P_MAXNIV", 1},;
		{"A1P_ITSERV", "/FATD002/charts/itemsDetails"};
	})

	aAdd(aRet, {;
		{"A1P_FILIAL", cFilialA1P},;
		{"A1P_ID    ", "000004"},;
		{"A1P_SRVFOR", "/FD100GNat/charts/form"},;
		{"A1P_SRVDAT", "/FD100GNat/charts/fd100GDado"},;
		{"A1P_TITULO", STR0056},; // Financeiro / Naturezas
		{"A1P_MAXNIV", 3},;
		{"A1P_ITSERV", "/FD100GNat/charts/itemsDetails"};
	})

	aAdd(aRet, {;
		{"A1P_FILIAL", cFilialA1P},;
		{"A1P_ID    ", "000005"},;
		{"A1P_SRVFOR", "/COMD020/charts/form"},;
		{"A1P_SRVDAT", "/COMD020/charts/retdados"},;
		{"A1P_SRVFIL", "/COMD020/charts/filterItens"},;
		{"A1P_TITULO", STR0057},; // Pedidos de Compra por Fornecedor
		{"A1P_MAXNIV", 3},;
		{"A1P_ITSERV", "/COMD020/charts/itemsDetails"};
	})

	aAdd(aRet, {;
		{"A1P_FILIAL", cFilialA1P},;
		{"A1P_ID    ", "000006"},;
		{"A1P_SRVFOR", "/COMD040/charts/form"},;
		{"A1P_SRVDAT", "/COMD040/charts/retdados"},;
		{"A1P_SRVFIL", "/COMD040/charts/filterItens"},;
		{"A1P_TITULO", STR0058},; // Devoluções de Documentos de Entrada por Período
		{"A1P_MAXNIV", 2},;
		{"A1P_ITSERV", "/COMD040/charts/itemsDetails"};
	})

	aAdd(aRet, {;
		{"A1P_FILIAL", cFilialA1P},;
		{"A1P_ID    ", "000007"},;
		{"A1P_SRVFOR", "/COMD050/charts/form"},;
		{"A1P_SRVDAT", "/COMD050/charts/retdados"},;
		{"A1P_SRVFIL", "/COMD050/charts/filterItens"},;
		{"A1P_TITULO", STR0059},; // Gráfico de Pedidos em Atraso
		{"A1P_MAXNIV", 1},;
		{"A1P_ITSERV", "/COMD050/charts/itemsDetails"};
	})

Return aRet

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A1PAtualiz
  Retorna um array com os Tipos de Gráficos do Dashboard criados inicialmente para a aplicacao
  @type function
  @author Squad CRM & Faturamento
  @since 05/04/2023
  @param aRet, array, Lista com os dados dos registros Iniciais da tabela A1P, caso tenham sido carregados anteriormente
  @return aRet, array, Lista com os dados dos registros Iniciais da tabela A1P, caso tenham sido carregados anteriormente e os Novos se nao existirem no banco de dados
/*/
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
static function A1PAtualiz(aRet)
	Local cFilialA1P := FwxFilial("A1P")
	Local aValidRegs := {}

	Default aRet  := {}

	aAdd(aValidRegs,	{;
						{"A1P_FILIAL", cFilialA1P},;
						{"A1P_ID    ", getID("A1P", "A1P_ID", "000008")},;
						{"A1P_SRVFOR", "/ProdFiscal/charts/difal/form"},;
						{"A1P_SRVDAT", "/ProdFiscal/charts/difal/retdados"},;
						{"A1P_TITULO", STR0090},; //"ICMS Difal operação de Saída por UF"
						{"A1P_MAXNIV", 1},;
						{"A1P_ITSERV", "/ProdFiscal/charts/difal/itemsDetails"};
					})
	
	aRet := vldAtualiz("A1P", aValidRegs, aRet)
	FwFreeObj(aValidRegs)

Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} A1QInicial
  Retorna um array com os Gráficos do Dashboard criados inicialmente para a aplicacao
  @type function
  @author Squad CRM & Faturamento
  @since 05/04/2023
  @return aRet, array, Lista com os dados dos registros A1Q Iniciais do Dashboard
/*/
//-------------------------------------------------------------------------------------
static function A1QInicial()
	Local aRet  := {}
	Local cFilialA1Q := FwxFilial("A1Q")

	aAdd(aRet, {;
		{"A1Q_FILIAL", cFilialA1Q},;
		{"A1Q_TITULO", STR0055},; // Notas Fiscais por UF
		{"A1Q_JSON  ", '{"tpNota":["N - Normal"],"filter":"{\"typechartId\":\"000003\",\"title\":\"' + STR0055 + '\",\"status\":\"1\",\"helpChart\":\"' + STR0060; // Notas Fiscais por UF // Exibe Notas Fiscais por UF
		+ '\",\"charttype\":\"bar\",\"datainicio\":\"2021-04-01\",\"datafim\":\"2021-04-30\",\"tpNota\":[\"N - '+ STR0075 + '\"],'; // Normal
		+ '\"uf\":' + FAT901UF(.T.) + ',\"vendwhere\":\"ped\",\"tranfil\":\"tyes\",\"f4duplic\":\"no\"}","status":"1",';
		+ '"typechartId":"000003","title":"' + STR0055 + '","charttype":"bar","vendwhere":"ped","f4duplic":"no","tranfil":"tyes","helpChart":"' + STR0069 + '",'; //Notas Fiscais por UF //Exibe Notas Fiscais do período de 01/04/2021 a 30/04/2021
		+ '"id":"000001","uf":' + FAT901UF(.F.) + ',';
		+ '"datafim":"2021-04-30","datainicio":"2021-04-01"}'},;
		{"A1Q_HELP  ", STR0060},; // Exibe Notas Fiscais por UF
		{"A1Q_ID    ", "000001"};
	})

	aAdd(aRet, {;
		{"A1Q_FILIAL", cFilialA1Q},;
		{"A1Q_TITULO", STR0062},; // Gráfico de Naturezas
		{"A1Q_JSON  ", '{"consPRRA":"4 = ' + STR0074 +'","filter":"{\"typechartId\":\"000004\",\"title\":\"' + STR0062; // Gráfico de Naturezas
		+ '\",\"status\":\"1\",\"charttype\":\"bar\",\"dateIni\":\"2020-11-01\",\"dateFim\":\"2021-07-31\",\"moedas\":\"01 - ' + STR0070 + '\",'; //Real
		+ '\"tpSaldo\":[\"2 = ' + STR0071 + '\",\"3 = ' + STR0072 + '\",\"0 = ' + STR0073 + '\"],\"consProv\":\"4 = ' + STR0074 + '\",\"consNCCF\":\"4 = '+ STR0074 + '\",'; //Previsto //Realizado //Todos //Considera Ambos
		+ '\"consPRRA\":\"4 = ' + STR0074 + '\",\"exibeNat\":\"Sim\"}","moedas":"01 - ' + STR0070 + '","status":"1","typechartId":"000004","title":"' + STR0062 + '",'; //Considera Ambos //Real //Exibe gráfico de pedidos de compra abertos por Fornecedor
		+ '"consProv":"4 = ' + STR0074 + '","charttype":"bar","dateIni":"2020-11-01","exibeNat":"Sim","id":"000002","consNCCF":"4 = ' + STR0074 + '","dateFim":"2021-07-31",'; //Considera Ambos
		+'"tpSaldo":["2 = ' + STR0071 + '","3 = ' + STR0072 + '","0 = ' + STR0073 + '"]}'},; //Previsto //Realizado //Todos
		{"A1Q_IDTIPO", "000004"},;
		{"A1Q_ID    ", "000002"};
	})

	aAdd(aRet, {;
		{"A1Q_FILIAL", cFilialA1Q},;
		{"A1Q_TITULO", STR0057},; // Pedidos de Compra por Fornecedor
		{"A1Q_JSON  ", '{"prodgp":[],"filter":"{\"typechartId\":\"000005\",\"title\":\"' + STR0057 + '\",\"status\":\"1\",\"helpChart\":\"' + STR0063; // Pedidos de Compra por Fornecedor //Devolução por Período
		+ '\",\"charttype\":\"bar\",\"iniforn\":\"\",\"fimforn\":\"\",\"onlypurchaser\":\"no\",\"prodgp\":[]}","status":"1","typechartId":"000005","title":"' + STR0057; //Pedidos de Compra por Fornecedor
		+ '","charttype":"bar","fimforn":"","onlypurchaser":"no","helpChart":"' + STR0063 + '","id":"000003","iniforn":""}'},; //Devolução por Período
		{"A1Q_HELP  ", STR0063},; // Exibe gráfico de pedidos de compra abertos por Fornecedor
		{"A1Q_IDTIPO", "000005"},;
		{"A1Q_ID    ", "000003"};
	})

	aAdd(aRet, {;
		{"A1Q_FILIAL", cFilialA1Q},;
		{"A1Q_TITULO", STR0063},; // Devolução por Período
		{"A1Q_JSON  ", '{"filter":"{\"typechartId\":\"000006\",\"title\":\"' + STR0063 + '\",\"status\":\"1\",\"helpChart\":\"' + STR0064; // Devolução por Período //Exibe Gráfico de Devolução de produtos através de Documento de Entrada
		+ '\",\"charttype\":\"bar\"}","status":"1","typechartId":"000006","title":"' + STR0063 + '","charttype":"bar","helpChart":"' + STR0064 + '","id":"000004"}'},; // Devolução por Período //Exibe Gráfico de Devolução de produtos através de Documento de Entrada
		{"A1Q_HELP  ", STR0064},; // Exibe Gráfico de Devolução de produtos através de Documento de Entrada
		{"A1Q_IDTIPO", "000006"},;
		{"A1Q_ID    ", "000004"};
	})

	aAdd(aRet, {;
		{"A1Q_FILIAL", cFilialA1Q},;
		{"A1Q_TITULO", STR0053},; // Lotes a Vencer
		{"A1Q_JSON  ", '{"filter":"{\"typechartId\":\"000001\",\"title\":\"'+ STR0053 + '\",\"status\":\"1\",\"helpChart\":\"' + STR0065; // Lotes a Vencer // Help para o gráfico e Lotes a Vencer.
		+ '\",\"charttype\":\"pie\"}","status":"1","typechartId":"000001","title":"' + STR0053 + '","charttype":"pie","helpChart":"' + STR0065 + '","id":"000005"}'},; // Lotes a Vencer // Help para o gráfico e Lotes a Vencer.
		{"A1Q_HELP  ", STR0065},; // Help para o gráfico e Lotes a Vencer.
		{"A1Q_ID    ", "000005"};
	})

	aAdd(aRet, {;
		{"A1Q_FILIAL", cFilialA1Q},;
		{"A1Q_TITULO", STR0054},; // Evolução dos Estoques por Fechamento
		{"A1Q_JSON  ", '{"filter":"{\"typechartId\":\"000002\",\"title\":\"'+ STR0054 + '\",\"status\":\"1\",\"helpChart\":\"'+ STR0066; // Evolução dos Estoques por Fechamento // Help para o gráfico Evolução dos Estoques por Fechamento.
		+ '\",\"charttype\":\"bar\"}","status":"1","typechartId":"000002","title":"'+ STR0054 + '","charttype":"bar","helpChart":"'+ STR0056 + '","id":"000006"}'},; // Evolução dos Estoques por Fechamento // Help para o gráfico Evolução dos Estoques por Fechamento.
		{"A1Q_HELP  ", STR0066},; // Help para o gráfico Evolução dos Estoques por Fechamento.
		{"A1Q_ID    ", "000006"};
	})

	aAdd(aRet, {;
		{"A1Q_FILIAL", cFilialA1Q},;
		{"A1Q_TITULO", STR0059},; // Gráfico de Pedidos em Atraso
		{"A1Q_JSON  ", '{"filter":"{\"typechartId\":\"000007\",\"title\":\"'+ STR0059 + '\",\"status\":\"1\",\"helpChart\":\"'+ STR0067; // Gráfico de Pedidos em Atraso // Exibe Gráfico de Pedidos de Compra com Data de Entrega em Atraso
		+ '\",\"charttype\":\"gauge\"}","status":"1","typechartId":"000007","title":"'+ STR0059 + '","charttype":"gauge","helpChart":"'+ STR0067 + '","id":"000007"}'},; // Gráfico de Pedidos em Atraso // Exibe Gráfico de Pedidos de Compra com Data de Entrega em Atraso
		{"A1Q_HELP  ", STR0067},; // Exibe Gráfico de Pedidos de Compra com Data de Entrega em Atraso
		{"A1Q_IDTIPO", "000007"},;
		{"A1Q_ID    ", "000007"};
	})

	aAdd(aRet, {;
		{"A1Q_FILIAL", cFilialA1Q},;
		{"A1Q_TITULO", STR0052},; // Gráfico Modelo
		{"A1Q_JSON  ", '{"filter":"{\"typechartId\":\"000000\",\"title\":\"' + STR0052 + '\",\"status\":\"1\",\"helpChart\":\"' + STR0068; // Gráfico Modelo // Informações sobre Help do Gráfico - GRÁFICO MODELO.
		+ '\",\"charttype\":\"pie\"}","status":"1","typechartId":"000000","title":"' + STR0052 + '","charttype":"bar","helpChart":"' + STR0068 + '","id":"000000"}'},; // Gráfico Modelo // Informações sobre Help do Gráfico - GRÁFICO MODELO.
		{"A1Q_HELP  ", STR0068},; // Informações sobre Help do Gráfico - GRÁFICO MODELO.
		{"A1Q_ID    ", "000000"};
	})

Return aRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} A1RInicial
  Retorna um array com as Visões do Dashboard criados inicialmente para a aplicacao
  @type function
  @author Squad CRM & Faturamento
  @since 05/04/2023
  @return aRet, array, Lista com os dados dos registros A1R Iniciais do Dashboard
/*/
//----------------------------------------------------------------------------------
static function A1RInicial()
	Local aRet  := {}
	Local cFilialA1R := FwxFilial("A1R")

	aAdd(aRet,{;
		{"A1R_FILIAL", cFilialA1R},;
		{"A1R_ID    ", "000001"},;
		{"A1R_TITULO", STR0076},; // Faturamento
		{"A1R_DESCRI", STR0076},; // Faturamento
		{"A1R_CARDS ", "000001,000003,000002,000004"},;
		{"A1R_GRUPOS" , "000000"},;
		{"A1R_STATUS" , "1"},;
		{"A1R_CHARTS", "000001"};
	})

	aAdd(aRet,{;
		{"A1R_FILIAL", cFilialA1R},;
		{"A1R_ID    ", "000002"},;
		{"A1R_TITULO", STR0077},; // Grafico / Card de Saldo por Naturezas
		{"A1R_DESCRI", STR0077},; // Grafico / Card de Saldo por Naturezas
		{"A1R_CARDS ", "000010,000011"},;
		{"A1R_GRUPOS" , "000000"},;
		{"A1R_STATUS" , "1"},;
		{"A1R_CHARTS", "000002"};
	})

	aAdd(aRet,{;
		{"A1R_FILIAL", cFilialA1R},;
		{"A1R_ID    ", "000003"},;
		{"A1R_TITULO", STR0078},; // Compras
		{"A1R_DESCRI", STR0078},; // Compras
		{"A1R_CARDS ", "000005,000006"},;
		{"A1R_CHARTS", "000003,000004,000007"},;
		{"A1R_GRUPOS", "000000"},;
		{"A1R_STATUS", "1"};
	})

	aAdd(aRet,{;
		{"A1R_FILIAL", xFilial("A1R")},;
		{"A1R_ID    ", "000004"},;
		{"A1R_TITULO", STR0079},; // Dashboard Estoque
		{"A1R_DESCRI", STR0079},; // Dashboard Estoque
		{"A1R_CARDS ", "000007,000008,000009"},;
		{"A1R_GRUPOS" , "000000"},;
		{"A1R_STATUS" , "1"},;
		{"A1R_CHARTS", "000005,000006"};
	})

	aAdd(aRet,{;
		{"A1R_FILIAL", xFilial("A1R")},;
		{"A1R_ID    ", "000000"},;
		{"A1R_TITULO", STR0080},; // Visão Modelo
		{"A1R_DESCRI", STR0080},; // Visão Modelo
		{"A1R_CARDS ", "000000"},;
		{"A1R_GRUPOS" , "000000"},;
		{"A1R_STATUS" , "1"},;
		{"A1R_CHARTS", "000000"};
	})

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FAT901UF
	Obtém a Lista de estados (UF) é lista em uma string
	@type function
	@author Danilo Salve / Squad CRM & Faturamento
	@since 30/03/2022
	@param lEscape, logical, Utiliza Escape '\' entre os estados
	@return character, Lista de Estados
/*/
//-------------------------------------------------------------------
static function FAT901UF(lEscape)
	Local aUF		:= FWGetSX5("12")
	Local cUF		:= '['
	Local nUF		:= 0
	Local nLenUF	:= Len(aUF)

	for nUF := 1 to nLenUF
		cUF += FAT901ESC(RTRIM(aUF[nUF, 3]), lEscape, nUF, nLenUF)
	next

	cUF += ']'
return cUF

//-------------------------------------------------------------------
/*/{Protheus.doc} FAT901ESC
	Efetua a formatação de um valor
	@type function
	@author Danilo Salve / Squad CRM & Faturamento
	@since 30/03/2022
	@param cValue, character, Valor
	@param lEscape, logical, Utiliza escape
	@param nIndex, numeric, indece atual
	@param nLength, numeric, Qtd. total de itens
	@return character, Valor formatado
/*/
//-------------------------------------------------------------------
static function FAT901ESC(cValue, lEscape, nIndex, nLength)
	Local cRet := ""

	Default lEscape := .F.

	cRet += IIF(lEscape, '\"', '"')
	cRet += cValue
	cRet += IIF(lEscape, '\"', '"')
	cRet += IIF(nIndex == nLength, "", ",")

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FAT901FIN1()
	Efetua a Carga nas tabelas A1N, A1o, A1P, A1Q e A1R para o Dashboard de Fluxo de Caixa por Naturezas
	@type function
	@author Francisco Oliveira / Squad Financeiro Inovação
	@since 31/10/2022
	@return Null
/*/
//-------------------------------------------------------------------
Static Function FAT901FIN1()
	Local aRet		As Array
	Local cQuery	As Character
	Local cAliasA1P	As Character
	Local cCodA1Q	As Character
	Local cCodA1P	As Character
	Local cCodA1R	As Character
	Local nX		As Numeric
	Local nY		As Numeric
	Local ObjA1P	As Object

	aRet		:= {}
	cAliasA1P	:= GetNextAlias()
	cCodA1Q		:= ""
	cCodA1P		:= ""
	cCodA1R		:= ""
	nX			:= 0
	nY			:= 0

	cQuery	:= " SELECT A1P_SRVFOR, A1P_SRVDAT, A1P_ITSERV "
	cQuery	+= " FROM " + RetSqlName("A1P") + " A1P "
	cQuery	+= " WHERE "
	cQuery 	+= " A1P_FILIAL = ? "
	cQuery	+= " AND A1P_SRVFOR LIKE '%FD101GNat%' "
	cQuery	+= " AND A1P_SRVDAT LIKE '%FD101GNat%' "
	cQuery	+= " AND A1P_ITSERV LIKE '%FD101GNat%' "
	cQuery  += " AND A1P.D_E_L_E_T_ = ' ' "

	ObjA1P := FWPreparedStatement():New(cQuery)

	ObjA1P:SetString(1, xFilial("A1P"))

	cQuery := ObjA1P:GetFixQuery()

	cQuery	:= ChangeQuery(cQuery)

    MPSysOpenQuery( cQuery, cAliasA1P )

    (cAliasA1P)->(DbGoTop())

	If (cAliasA1P)->(EOF())

		cCodA1P := GetSx8Num('A1P', 'A1P_ID')

		//Tabela A1P
		aAdd(aRet, {;
		{"A1P_FILIAL", FwxFilial('A1P')},;
		{"A1P_ID    ", cCodA1P},;
		{"A1P_SRVFOR", "/FD101GNat/charts/form"},;
		{"A1P_SRVDAT", "/FD101GNat/charts/fd101GDado"},;
		{"A1P_TITULO", STR0081},; 
		{"A1P_MAXNIV", 2},;
		{"A1P_ITSERV", "/FD101GNat/charts/itemsDetails"};
		})

		ConfirmSx8()

		For nX := 1 to Len(aRet)
			RecLock("A1P", .T.)
			For nY := 1 To Len(aRet[nX])
				FieldPut(FieldPos(aRet[nX][nY][1]), aRet[nX][nY][2])
			Next
			A1P->(MsUnlock())
		Next

		aRet	:= {}
		cCodA1Q := GetSx8Num('A1Q', 'A1Q_ID')

		//Tabela A1Q
		aAdd(aRet, {;
			{"A1Q_FILIAL", FwxFilial('A1Q')},;
			{"A1Q_TITULO", STR0081},; 
			{"A1Q_JSON  ", '{"typechartId":"' + cCodA1P + '","title":"' + STR0081 + '","status":"1","charttype":"bar",';
			+ '"dateIni":"2022-10-01","dateFim":"2022-10-05","natureza":["' + STR0083 + '"],"considFil":["' + STR0084 + '"],"periodos":"' + STR0085 + '",';
			+ '"conBancos":["' + STR0086 + '"],"tpSaldo":"' + STR0087 + '","moedas":"' + STR0088 + '","diversos":["' + STR0089 + '"],';
			+ '"filter":"{\"typechartId\":\"' + cCodA1P + '\",\"title\":\"' + STR0082 + '\",\"status\":\"1\",';
			+ '\"charttype\":\"bar\",\"dateIni\":\"2022-10-01\",\"dateFim\":\"2022-10-05\",\"natureza\":[\"' + STR0083 +'\"],\"considFil\":[\"' + STR0084 +'\"],';
			+ '\"periodos\":\"' + STR0085 + '\",\"conBancos\":[\"' + STR0086 + '\"],\"tpSaldo\":\"' + STR0087 + '\",\"moedas\":\"' + STR0088 + '\",';
			+ '\"diversos\":[\"' + STR0089 + '\"]}","id":"' + cCodA1Q + '"}'},;
			{"A1Q_IDTIPO", cCodA1P},;
			{"A1Q_ID    ", cCodA1Q};
		})

		ConfirmSx8()

		For nX := 1 to Len(aRet)
			RecLock("A1Q", .T.)
			For nY := 1 To Len(aRet[nX])
				FieldPut(FieldPos(aRet[nX][nY][1]), aRet[nX][nY][2])
			Next
			A1Q->(MsUnlock())
		Next

		aRet	:= {}
		cCodA1R := GetSx8Num('A1R', 'A1R_ID')

		//Tabela A1R
		aAdd(aRet,{;
			{"A1R_FILIAL", FwxFilial('A1R')},;
			{"A1R_ID    ", cCodA1R},;
			{"A1R_TITULO", STR0081},;
			{"A1R_DESCRI", STR0081},;
			{"A1R_GRUPOS", "000000"},;
			{"A1R_STATUS", "1"},;
			{"A1R_CHARTS", cCodA1Q};
		})

		ConfirmSx8()

		For nX := 1 to Len(aRet)
			RecLock("A1R", .T.)
			For nY := 1 To Len(aRet[nX])
				FieldPut(FieldPos(aRet[nX][nY][1]), aRet[nX][nY][2])
			Next
			A1R->(MsUnlock())
		Next

	Endif

	(cAliasA1P)->(DbCloseArea())
Return

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} chargeAPrepared
	Carrega o array __aPrepared com o objeto
	@type function
	@param      cQuery      , character, query a ser consultada/incluida no array __aPrepared
	@return		nPosPrepared, numeric  , posição do array com o objeto da query a ser utilizado.
	@author		Squad CRM & Faturamento
	@since		10/04/2023
	@version	12.1.33 ou superior
/*/
//---------------------------------------------------------------------------------------------
Static Function chargeAPrepared(cQuery)
	Local oStatement 	 as Object 
	Local cMD5           as Character
	Local nPosPrepared   as Numeric

	cMD5 := MD5(cQuery)
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0
		cQuery	:= ChangeQuery(cQuery)
		oStatement := IIf(FATA901FWExecStat(), FwExecStatement():New(cQuery), FWPreparedStatement():New(cQuery))
		Aadd(__aPrepared,{oStatement, cMD5})
		nPosPrepared := Len(__aPrepared)
	EndIf
Return nPosPrepared

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FATA901FWExecStat
	Função utilizada para validar a data da LIB para utilização da classe FWExecStatement
	@type       Function
	@return     __TGVA002BVerLib, lógico, se pode ser utilizado a classe FWExecStatement
	@author     Squad CRM/Faturamento
	@since      10/04/2023
	@version    12.1.33 ou superior
/*/
//-------------------------------------------------------------------------------------
Static Function FATA901FWExecStat()
	Static __FAT901BVerLib := Nil

	If __FAT901BVerLib == Nil
		__FAT901BVerLib := FWLibVersion() >= "20211116"
	EndIf
Return __FAT901BVerLib

//----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} execQueryAPrepared
	Executa a query contida na posicao indicada por parametro do array __aPrepared
	@type function
	@return     Nil
	@param		cAlias     , character, alias a ser utilizado para a workarea da query
	@param		oStatement , object   , objeto do prepared ou exec statement para executar a query
	@author		Squad CRM & Faturamento
	@since		10/04/2023
	@version	12.1.33 ou superior
/*/
//----------------------------------------------------------------------------------------------------
Static Function execQueryAPrepared(cAlias as Character, oStatement as Object)
	IIf(FATA901FWExecStat(), oStatement:OpenAlias(cAlias), DbUseArea(.T.,"TOPCONN",TcGenQry(,,oStatement:GetFixQuery()),cAlias,.T.,.T.))
Return Nil
