#Include "protheus.ch"
#DEFINE BLOQUEIOFATURAMENTO_SERVICE agd.bloqueioFaturamentoService.agdBloqueioFaturamentoService


/*/{Protheus.doc} AGDI100FAT
Ponto de chamada após clicar em Prep Doc's no MATA460A. 
@type method
@version P12.1.2610
@author carlos.augusto
@since 15/12/2025
@param cMarca, Character, marca atual da thread
@param lInverte, logical, indica se usuario clicou para interter registros marcados
@param cSerie, Character, serie - não usado atualmente no metodo
@param cQrySC9, Character, filtros que não sao de visualizacao do browse mas realizados nos registros pela rotina
@return lRet, logical, retorna .F. se deve impedir processo de faturamento
/*/
Function AGDI100FAT(cMarca,lInverte,cSerie,cQrySC9)
	Local lRet       	  := .T.
	Local aItensMark 	  := {}
	Local aItensTela 	  := {}
	Local oBloqFatService := Nil

	If SUPERGETMV("MV_SIGAAGD", .F., .F.) .And. TableInDic('NEU')
		aItensMark := AGDI100Mrk(.T.,cMarca,lInverte, ,cQrySC9)
		aItensTela := AGDI100Mrk(.F.,cMarca,lInverte, ,cQrySC9)
		If !Empty(aItensMark)
			oBloqFatService := BLOQUEIOFATURAMENTO_SERVICE():New()
			lRet := oBloqFatService:validaMarcacaoFaturamentoEstornoSC9(aItensMark,aItensTela,cMarca, .F.,.F.)
			FreeObj(oBloqFatService)
		EndIf
	EndIf
Return lRet


/*/{Protheus.doc} AGDI100ESP
Ponto de chamada após clicar em Estor Doc's no MATA460A. Quando o parãmetro de abertura de tela está como 'Estorno da Liberc. ?' com a opção 'Posicionado'
@type method
@version P12.1.2610
@author carlos.augusto
@since 15/12/2025
@param cMarca, Character, marca atual da thread
@param lInverte, logical, indica se usuario clicou para interter registros marcados
@param nRecnoSC9, numerico, recno da SC9 posicionada
@return lRet, logical, retorna .F. se deve impedir processo de estorno
/*/
Function AGDI100ESP(cMarca,lInverte,nRecnoSC9)
	Local lRet 				:= .T.
	Local aItensMark 		:= {}
	Local aAreaSC9 			:= SC9->(GetArea())
	Local oBloqFatService   := Nil

	If SUPERGETMV("MV_SIGAAGD", .F., .F.) .And. TableInDic('NEU')
		SC9->(DbGoto(nRecnoSC9))
		aAdd(aItensMark,{SC9->C9_FILIAL, SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN, SC9->C9_PRODUTO})
		oBloqFatService := BLOQUEIOFATURAMENTO_SERVICE():New()
		lRet := oBloqFatService:validaMarcacaoFaturamentoEstornoSC9(aItensMark, aItensMark, cMarca, .T.,.T.) //Quando posicionado, mandamos reabrir a tela caso seja grupo de NEU
		FreeObj(oBloqFatService)
	EndIf
	RestArea(aAreaSC9)
Return lRet


/*/{Protheus.doc} AGDI100ESM
Ponto de chamada após clicar em Estor Doc's no MATA460A. Quando o parãmetro de abertura de tela está como 'Estorno da Liberc. ?' com a opção 'Marcados'
@type method
@version P12.1.2610
@author carlos.augusto
@since 15/12/2025
@param cMarca, Character, marca atual da thread
@param lInverte, logical, indica se usuario clicou para interter registros marcados
@param aFiltro, array, filtros utilizados na rotina (não são filtros no browse)
@param cFiltrPesq, numerico, filtros utilizados na rotina (não são filtros no browse)
@return lRet, logical, retorna .F. se deve impedir processo de estorno
/*/
Function AGDI100ESM(cMarca,lInverte, aFiltro, cFiltrPesq )
	Local lRet 			  := .T.
	Local oBloqFatService := Nil
	Local aItensTela 	  := {}
	Local aItensMark 	  := {}

	If SUPERGETMV("MV_SIGAAGD", .F., .F.) .And. TableInDic('NEU')
		aItensMark := AGDI100Mrk(.T.,cMarca,lInverte,aFiltro,cFiltrPesq)
		aItensTela := AGDI100Mrk(.F.,cMarca,lInverte,aFiltro,cFiltrPesq)
		If !Empty(aItensMark)
			oBloqFatService := BLOQUEIOFATURAMENTO_SERVICE():New()
			lRet := oBloqFatService:validaMarcacaoFaturamentoEstornoSC9(aItensMark,aItensTela,cMarca, .T.,.F.)
			FreeObj(oBloqFatService)
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} AGDI100AUT
Ponto de chamada após iniciar o processo de faturamento via execauto. 
@type method
@version P12.1.2610
@author carlos.augusto
@since 15/12/2025
@param aPvlNfs, array, array de SC9 enviadas para faturamento
@return lRet, logical, retorna .F. se deve impedir processo de faturamento
/*/
Function AGDI100AUT(aPvlNfs)
	Local lRet      := .T.
	Local nX 		:= 1
	Local aItensSC9 := {}
	Local aAreaSC9  := SC9->(GetArea())
	Local lIsBlind  := isBlind()

	If SUPERGETMV("MV_SIGAAGD", .F., .F.) .And. lIsBlind .And. TableInDic('NEU')
		If Len(aPvlNfs) >= 1
			For nX := 1 To Len(aPvlNfs)
				If Len(aPvlNfs[nX]) >= 8 .And. ValType(aPvlNfs[nX][8]) == "N"
					SC9->(DbGoto(aPvlNfs[nX][8]))
					aAdd(aItensSC9,{SC9->C9_FILIAL, SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN, SC9->C9_PRODUTO})
				EndIf
			Next
		EndIf
		If !Empty(aItensSC9)
			oBloqFatService := BLOQUEIOFATURAMENTO_SERVICE():New()
			lRet := oBloqFatService:validaMarcacaoFaturamentoEstornoSC9(aItensSC9,aItensSC9,'  ', .F.,.F.)
			FreeObj(oBloqFatService)
		EndIf
	EndIf

	RestArea(aAreaSC9)

Return lRet



/*/{Protheus.doc} AGDI100Mrk
Ponto de chamada após iniciar o processo de faturamento via execauto. 
@type method
@version P12.1.2610
@author carlos.augusto
@since 15/12/2025
@param lMarcados, logical, indica se quer retornar apenas os registros marcados
@param cMarca, Character, marca atual da thread
@param lInverte, logical, indica se usuario clicou para interter registros marcados
@param aFiltro, array, filtros utilizados na rotina (não são filtros no browse)
@param cFiltrPesq, numerico, filtros utilizados na rotina (não são filtros no browse)
@return aItensMark, array, array conforme chave SC9 - {SC9->C9_FILIAL, SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN, SC9->C9_PRODUTO}
/*/
Function AGDI100Mrk(lMarcados, cMarca, lInverte, aFiltro, cFiltrPesq)
	Local cPergBkp := SX1->X1_GRUPO
	Local aItensMark := {}
	Local aAreaSC9 		:= SC9->(GetArea())
	Local cAliasSC9     := ""
	Local cQrySC9       := ""
	Local lFatPrev      := SuperGetMV("MV_FATFTPR",.F.,.T.) //Indica se permite faturar itens previstos (C9_TPOP = P)

	SaveInter() // Salva variaveis publicas 

	//MV_PAR01     // Filtra j  emitidas     - Sim/Nao 
	//MV_PAR02     // Estorno da Liberacao   - Posic./Marcados
	//MV_PAR03     // Cons. Param. Abaixo    - Sim/Nao
	//MV_PAR04     // Trazer Ped. Marc       - Sim/Nao
	//MV_PAR05     // De  Pedido
	//MV_PAR06     // Ate Pedido
	//MV_PAR07     // De  Cliente
	//MV_PAR08     // Ate Cliente
	//MV_PAR09     // De  Loja
	//MV_PAR10     // Ate Loja
	//MV_PAR11     // De  Liberacao
	//MV_PAR12     // Ate Liberacao
	//MV_PAR13     // Mostra Itens Previstos - Sim/N?
	//MV_PAR14     // De  Entrega
	//MV_PAR15     // Ate Entrega

	Pergunte("MT461A",.F.)
	cQrySC9 := "SELECT SC9.R_E_C_N_O_ C9RECNO, SC9.C9_OK "
	cQrySC9 += 	" FROM " + RetSqlName("SC9")+" SC9 "
	cQrySC9 += 		" WHERE SC9.C9_FILIAL='"+xFilial("SC9")+"'"

	If !Empty(cFiltrPesq)
		cQrySC9	+= "AND (" +cFiltrPesq +")"
	EndIf

	If !Empty(aFiltro) .And. !Empty(aFiltro[2])
		cQrySC9   += "AND (" +aFiltro[2] +")"
	EndIf

	If ( MV_PAR01 == 1 )
		cQrySC9 += " And SC9.C9_BLEST<>'10'"
		cQrySC9 += " And SC9.C9_BLEST<>'ZZ'"
	EndIf
	
	If ( !lFatPrev )	//Indica se permite faturar itens Previstos (Campo C6_TPOP)
		//Filtra apenas itens com Tipo de Ordem de Produção Firmes (C6_TPOP = 'F' | C9_TPOP = '1')
		cQrySC9 += " And SC9.C9_TPOP != '2' "
	EndIf
	
	If ( MV_PAR03 == 1 )
		cQrySC9 += " And SC9.C9_PEDIDO  >='"+MV_PAR05+"'"
		cQrySC9 += " And SC9.C9_PEDIDO  <='"+MV_PAR06+"'"
		cQrySC9 += " And SC9.C9_CLIENTE >='"+MV_PAR07+"'"
		cQrySC9 += " And SC9.C9_CLIENTE <='"+MV_PAR08+"'"
		cQrySC9 += " And SC9.C9_LOJA    >='"+MV_PAR09+"'"
		cQrySC9 += " And SC9.C9_LOJA    <='"+MV_PAR10+"'"
		cQrySC9 += " And SC9.C9_DATALIB >='"+Dtos(MV_PAR11)+"'"
		cQrySC9 += " And SC9.C9_DATALIB <='"+Dtos(MV_PAR12)+"'"
		
		//Mostra itens previstos?
		If ( !Empty( MV_PAR13 ) ) .And. ( ValType(MV_PAR13) == 'N' )
			If ( MV_PAR13 == 2 ) .And. ( lFatPrev )
				cQrySC9 += " And SC9.C9_TPOP <> '2'"
			EndIf
		EndIf
		
		//Filtra por data de entrega
		If ( !Empty( MV_PAR14 ) ) .And. ( ValType(MV_PAR14) == 'D' )
			cQrySC9 += " And SC9.C9_DATENT >= '" + DToS(MV_PAR14) + "'"
		EndIf
		If ( !Empty( MV_PAR15 ) ) .And. ( ValType(MV_PAR15) == 'D' )
			cQrySC9 += " And SC9.C9_DATENT <= '" + DToS(MV_PAR15) + "'"
		EndIf
		
	EndIf

	If lMarcados
		If lInverte
			cQrySC9 += " AND SC9.C9_OK<>'"+cMarca+"'"
		Else
			cQrySC9 += " AND SC9.C9_OK='"+cMarca+"'"
		End
	EndIf
	cQrySC9 += " AND SC9.C9_NFISCAL = ' '"
	cQrySC9 += " AND SC9.D_E_L_E_T_ = ' '"

	cAliasSC9 := GetNextAlias()
	cQrySC9   := ChangeQuery(cQrySC9)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQrySC9 ), cAliasSC9, .F., .T. )
	While !(cAliasSC9)->(EOF())
		If !lMarcados .Or. ((cAliasSC9)->C9_OK <> cMarca .And. lInverte) .Or. ((cAliasSC9)->C9_OK == cMarca .And. !lInverte)
			SC9->(DbGoto((cAliasSC9)->C9RECNO))
			aAdd(aItensMark,{SC9->C9_FILIAL, SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN, SC9->C9_PRODUTO, SC9->C9_DATENT})
		EndIf
		dbSelectarea("SC9")
		(cAliasSC9)->(dbSkip())
	EndDo
	(cAliasSC9)->(dbCloseArea())
	RestArea(aAreaSC9)
	Pergunte(cPergBkp, .F.)
	RestInter()//Recupera as variaveis pulicas

Return aItensMark

