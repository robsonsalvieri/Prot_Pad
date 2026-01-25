#Include "LOCA084.ch"
#INCLUDE "TOTVS.CH" 
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA084
Integração com Módulo de Gestão de Serviços
@author Jose Eulalio
@since 16/01/2023
/*/
//------------------------------------------------------------------------------
FUNCTION LOCA084(lExclusao)
Local lRet := .T.
Default lExclusao		:= .F.

	Processa( {|| lRet := LOCA0841(lExclusao)}, STR0001)  //"Executando integração com módulo de Gestão de Serviços"

RETURN lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA0841
Inclusão ou Exclusão de Base Instalada no Módulo de Gestão de Serviços
@author Jose Eulalio
@since 16/01/2023
@see https://centraldeatendimento.totvs.com/hc/pt-br/articles/360058627714-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Exclus%C3%A3o-atrav%C3%A9s-de-rotina-autom%C3%A1tica-TECA040-
/*/
//------------------------------------------------------------------------------
FUNCTION LOCA0841(lExclusao)
Local cCodProd		:= ""
Local cCodBem		:= ""
Local cCliCod		:= Space(TamSx3("A1_COD")[1])
Local cCliLoja		:= Space(TamSx3("A1_LOJA")[1])
Local cSeqEst		:= ""
Local cEqAloc		:= ""
Local cStatus		:= ""
Local cNewIdAA3		:= ""
Local nOperacao 	:= 3
Local aAreaAA3		:= AA3->(GetArea())
Local aAreaFP1		:= FP1->(GetArea())
Local aAreaFQ7		:= FQ7->(GetArea())
Local aAreaST9		:= ST9->(GetArea())
Local lRet      	:= .T.
Local lIsMinuta		:= .F.
//Local lMvLocx305	:= SuperGetMV("MV_LOCX305" , .F. , .T.) //Define se aceita geração de contrato sem equipamento
Local lMvLocx304	 	:= SuperGetMV("MV_LOCX304",.F.,.F.) // Utiliza o cliente destino informado na aba conjunto transportador será o utilizado como cliente da nota fiscal de remessa,

Default lExclusao 	:= .F.

PRIVATE lMsErroAuto := .F.

	cCodProd 	:= FPA->FPA_PRODUT
	cCodBem		:= FPA->FPA_GRUA
	cSeqEst		:= AllTrim(FPA->FPA_SEQEST)
	lIsMinuta	:= IsEqMinuta(cCodBem)

	//gera somente para estruras e bem sem fihos
	//If At(". ",cSeqEst) == 0 //Se tiver um ponto nessa posição, quer dizer que é filho
	If Empty(cSeqEst) .Or. SubStr(cSeqEst,5,1) == " " //Sem NÃO tiver espaço na quinta posição é filho, regra alterada, pois vezes vem com ponto, vezes vem sem ponto da FPA

		//verifica se grava cliente e se é do conjunto transportador
		If !lIsMinuta
			//posiciona na obra
			FP1->(DbSetOrder(1)) //FP1_FILIAL+FP1_PROJET+FP1_OBRA
			FP1->(DbSeek(FPA->(FPA_FILIAL + FPA_PROJET + FPA_OBRA)))
			cCliCod		:= FP1->FP1_CLIORI
			cCliLoja	:= FP1->FP1_LOJORI

			//Se não for contrato sem equipamento confere se tem conjunto transportador
			//If !lMvLocx305
			If lMvLocx304
				//posiciona no conjunto transportador
				FQ7->(DbSetOrder(2)) //FQ7_FILIAL+FQ7_PROJET+FQ7_OBRA+FQ7_SEQGUI+FQ7_ITEM
				If FQ7->(DbSeek(xFilial("FQ7") + FPA->(FPA_PROJET + FPA_OBRA + FPA_SEQGRU)))
					cCliCod		:= FQ7->FQ7_LCCDES
					cCliLoja	:= FQ7->FQ7_LCLDES
				EndIf
			EndIf
		EndIf

		//Quando não há bem informado, gera Id Unico
		If Empty(cCodBem)
			If FQ5->(FieldPos("FQ5_IDUAA3")) > 0 .And. !Empty(FQ5->FQ5_IDUAA3)
				cCodBem := FQ5->FQ5_IDUAA3
			ElseIf  !lExclusao
				//monta codigo unico baseado no produto + cliente +  sequencial (NN)
				//cCodBem := NewIdAA3( cCodProd , cCliCod , cCliLoja )
				cNewIdAA3 := NewIdAA3( cCodProd , cCliCod , cCliLoja )
			EndIf
		EndIf

		//atualiza se é locação
		If FPA->FPA_TIPOSE == "L" .And. lIsMinuta
			cEqAloc := "1"
		Else
			cEqAloc := "2"
			If FindFunction("LOCA0810") .And. TableInDic( "FQD", .F. ) .And. FQD->(FieldPos("FQD_STAAA3")) > 0
				ST9->(DBSETORDER(1) )
				IF ST9->(DBSEEK(XFILIAL("ST9")+cCodBem))
					cStatus := LOCA0810("AA3",ST9->T9_STATUS)
				EndIf
			EndIf
			If Empty(cStatus)
				cStatus := "07" //De para de Status
			EndIf
		EndIf

		Begin Transaction

			//verifica se é exclusão
			If lExclusao

				//Limpa campos do RENTAL
				lRet := LimpaAA3(cCodProd,cCodBem,cCliCod,cCliLoja)

			Else
				//localiza para ver se é alteração
				If FAchouAA3(cCodProd,cCodBem,cCliCod,cCliLoja,cEqAloc,@nOperacao) .And. !Empty(cCodBem)

					/*If Empty(cCodBem)
						cCodBem := cNewIdAA3
					EndIf*/

					lRet := TransfAA3(cCliCod,cCliLoja)

				Else

					If Empty(cCodBem)
						cCodBem := cNewIdAA3
					EndIf

					lRet := IncluiAA3(cCodProd,cCodBem,cSeqEst,cEqAloc,cCliCod,cCliLoja,cStatus,nOperacao)

				EndIf

				//Grava o Id da Base de Atendimento na FQ5
				If lRet
					If FQ5->(FieldPos("FQ5_IDUAA3")) > 0
						RecLock("FQ5", .F.)
							FQ5->FQ5_IDUAA3 := cCodBem
						FQ5->(MsUnlock())
					EndIf
				EndIf

			EndIf

			//desfaz a transação se retornar erro
			If !lRet
				DisarmTransaction()
			EndIf

		End Transaction

	EndIf

	RestArea(aAreaAA3)
	RestArea(aAreaFP1)
	RestArea(aAreaFQ7)
	RestArea(aAreaST9)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsEqMinuta

Verifica se o Equipamento é para minuta, ou seja contém Status da ST9 vazio
@type  Static Function
@author Jose Eulalio
@since 01/11/2022

/*/
//------------------------------------------------------------------------------
Static Function IsEqMinuta(cCodBem)
Local lRet		:= .F.
Local aAreaSt9	:= ST9->(GetArea())

	ST9->(DbSetOrder(1)) //T9_FILIAL + T9_CODBEM
	lRet := ST9->(DbSeek(xFilial("ST9") + cCodBem)) .And. Empty(ST9->T9_STATUS)

	RestArea(aAreaSt9)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} LimpaAA3

Limpa os campos do RENTAL na Base de Atendimento
@type  Static Function
@author Jose Eulalio
@since 17/01/2023

/*/
//------------------------------------------------------------------------------
Static Function LimpaAA3(cCodProd,cCodBem,cCliCod,cCliLoja)
Local lRet			:= .T.
Local cProjetAnt	:= ""
Local cAsAnt		:= ""
Local cStatus 		:= ""

	AA3->(DbSetOrder(1)) //AA3_FILIAL+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER+AA3_FILORI
	If AA3->(DbSeek(xFilial("AA3") + cCliCod + cCliLoja + cCodProd + cCodBem ))
		//Limpa Projeto e AS
		RecLock("AA3", .F.)
			//campos novos
			If AA3->(FieldPos("AA3_PROJET")) > 0
				cProjetAnt		:= AA3->AA3_PROJET
				AA3->AA3_PROJET := ""
			EndIf
			If AA3->(FieldPos("AA3_AS")) > 0
				cAsAnt		:= AA3->AA3_AS
				AA3->AA3_AS := ""
			EndIf
			If AA3->AA3_EQALOC == "2"
				If FindFunction("LOCA0810") .And. TableInDic( "FQD", .F. ) .And. FQD->(FieldPos("FQD_STAAA3")) > 0
					ST9->(DBSETORDER(1) )
					IF ST9->(DBSEEK(XFILIAL("ST9")+cCodBem))
						cStatus := LOCA0810("AA3",ST9->T9_STATUS)
					EndIf
				EndIf
				If Empty(cStatus)
					cStatus := "02" //De para de Status
				EndIf
			EndIf
		AA3->(MsUnlock())

		//?Atualiza o historico do equipamento                               ?
		Reclock("AAF",.T.)
		AAF->AAF_FILIAL := xFilial("AAF")
		AAF->AAF_CODCLI := cCliCod
		AAF->AAF_LOJA   := cCliLoja
		AAF->AAF_CODPRO := AA3->AA3_CODPRO
		AAF->AAF_NUMSER := AA3->AA3_NUMSER
		AAF->AAF_PRODAC := AA3->AA3_CODPRO
		AAF->AAF_NSERAC := AA3->AA3_NUMSER
		AAF->AAF_DTINI  := dDataBase
		AAF->AAF_CODFAB := AA3->AA3_CODFAB
		AAF->AAF_LOJAFA := AA3->AA3_LOJAFA
		AAF->AAF_LOGINI := Left( 	STR0002 + 	cProjetAnt + "/" + ; //"Estorno de projeto/AS "
																cAsAnt ,  ;
									Len( AAF->AAF_LOGINI ) ) // # "TRANSFERENCIA DE CLIENTE/LOJA " ## " PARA "
		AAF->( MsUnlock() )
		AAF->( MsUnlock() )
	EndIf

	//Limpa o Id da Base de Atendimento na FQ5
	If lRet
		If FQ5->(FieldPos("FQ5_IDUAA3")) > 0
			RecLock("FQ5", .F.)
				FQ5->FQ5_IDUAA3 := ""
			FQ5->(MsUnlock())
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} IncluiAA3

Realiza inclusão na Base de Atendimento
@type  Static Function
@author Jose Eulalio
@since 17/01/2023

/*/
//------------------------------------------------------------------------------
Static Function IncluiAA3(cCodProd,cCodBem,cSeqEst,cEqAloc,cCliCod,cCliLoja,cStatus,nOperacao)
Local cNSerAc		:= ""
Local lRet			:= .T.
Local aCab040   	:= {}    // Cabecalho do AA3
Local aItens040 	:= {}    // Itens AA4
Local aItensAux		:= {}
Local aArea			:= GetArea()

	//Monta cabeçalho
	Aadd(aCab040, { "AA3_FILIAL"    , xFilial("AA3")    , NIL } )
	Aadd(aCab040, { "AA3_CODPRO"    , cCodProd			, NIL } )
	Aadd(aCab040, { "AA3_NUMSER"    , cCodBem     		, NIL } )
	//Aadd(aCab040, { "AA3_CODBEM"    , cCodBem     		, NIL } )
	Aadd(aCab040, { "AA3_EQALOC"    , cEqAloc  			, NIL } )
	If cEqAloc == "2"
		Aadd(aCab040, { "AA3_CODCLI"    , cCliCod      		, NIL } )
		Aadd(aCab040, { "AA3_LOJA"      , cCliLoja     		, NIL } )
	//Else
		Aadd(aCab040, { "AA3_STATUS"    , cStatus     		, NIL } )
	EndIf

	//campos novos
	If AA3->(FieldPos("AA3_PROJET")) > 0
		Aadd(aCab040, { "AA3_PROJET"      , FP0->FP0_PROJET     		, NIL } )
	EndIf
	If AA3->(FieldPos("AA3_AS")) > 0
		Aadd(aCab040, { "AA3_AS"      , FPA->FPA_AS    		, NIL } )
	EndIf

	//se tem estrutura grava AA4 e atualiza itens
	If !Empty(cSeqEst)

		//pega o prefixo o item pai
		cSeqEst := SubStr(FPA->FPA_SEQEST, 1, 3)

		//Pula linha para próximo da estrutura
		FPA->(DbSkip())

		While cSeqEst == SubStr(FPA->FPA_SEQEST, 1, 3)

			//sempre é necessário enviar um Id Unico para Acessório
			If Empty(cNSerAc)
				/*If !Empty(FPA->FPA_GRUA)
					cNSerAc		:= FPA->FPA_GRUA
				Else*/
					cNSerAc		:= NewIdAA4(cCodBem)
				//EndIf
			Else
				cNSerAc := Soma1(cNSerAc)
			EndIf

			Aadd(aItensAux, { "AA4_FILIAL"	, xFilial("AA4")    , NIL } )
			Aadd(aItensAux, { "AA4_CODPRO"  , cCodProd			, NIL } )
			Aadd(aItensAux, { "AA4_NUMSER"  , cCodBem     		, NIL } )
			Aadd(aItensAux, { "AA4_PRODAC"  , FPA->FPA_PRODUT   , NIL } )
			Aadd(aItensAux, { "AA4_NSERAC"  , cNSerAc     		, NIL } )

			If cEqAloc == "1"
				Aadd(aItensAux, { "AA4_CODCLI"  , cCliCod      		, NIL } )
				Aadd(aItensAux, { "AA4_LOJA"    , cCliLoja    		, NIL } )
			EndIf

			//adiciona na grid
			Aadd(aItens040 , aItensAux)

			//limpa array auxiliar
			aItensAux := {}

			FPA->(DbSkip())

		EndDo

	EndIf

	DbSelectArea("AA3")
	//Executa rotina automatica
	TECA040(NIL,aCab040,aItens040,nOperacao)

	//³VerIfica se houveram erros durante a geracao da base   ³
	If lMsErroAuto
		lRet := !lMsErroAuto
		MostraErro()
	Endif

	aCab040 := {}
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TransfAA3

Realiza transferencia de Cliente e grava Historico
@type  Static Function
@author Jose Eulalio
@since 17/01/2023

/*/
//------------------------------------------------------------------------------
Static Function TransfAA3(cCliCod,cCliLoja)
Local lRet			:= .T.
Local lIncluiAc		:= .T.
Local cCodCliAnt	:= ""
Local cLojaCliAnt	:= ""
Local cProjetAnt	:= ""
Local cAsAnt		:= ""
Local cSeqEst		:= ""
Local cNSerAc		:= ""

	//Armazena codigo do cliente e loja antes de gravar o AA3?
	cCodCliAnt	:= AA3->AA3_CODCLI
	cLojaCliAnt	:= AA3->AA3_LOJA

	//Altera cliente
	RecLock("AA3", .F.)
		AA3->AA3_CODCLI := cCliCod
		AA3->AA3_LOJA 	:= cCliLoja
		//campos novos
		If AA3->(FieldPos("AA3_PROJET")) > 0
			cProjetAnt		:= AA3->AA3_PROJET
			AA3->AA3_PROJET := FP0->FP0_PROJET
		EndIf
		If AA3->(FieldPos("AA3_AS")) > 0
			cAsAnt		:= AA3->AA3_AS
			AA3->AA3_AS := FPA->FPA_AS
		EndIf
	AA3->(MsUnlock())

	//Grava o Id da Base de Atendimento na FQ5
	If FQ5->(FieldPos("FQ5_IDUAA3")) > 0
		RecLock("FQ5", .F.)
			FQ5->FQ5_IDUAA3 := AA3->AA3_NUMSER
		FQ5->(MsUnlock())
	EndIf

	//Atualiza acessórios
	AA4->(dbSetOrder(1)) // AA4_FILIAL+AA4_CODCLI+AA4_LOJA+AA4_CODPRO+AA4_NUMSER+AA4_PRODAC+AA4_NSERAC
	AA4->(MsSeek(xFilial("AA4")+AA3->AA3_CODCLI+AA3->AA3_LOJA+AA3->AA3_CODPRO+AA3->AA3_NUMSER))
	While ( !Eof() .And. AA4->AA4_FILIAL==xFilial("AA4") .And.;
						AA4->AA4_CODCLI==M->AA3_CODCLI .And.;
						AA4->AA4_LOJA  ==M->AA3_LOJA   .And.;
						AA4->AA4_CODPRO==M->AA3_CODPRO .And.;
						AA4->AA4_NUMSER==M->AA3_NUMSER )

		RecLock("AA4", .F.)
			AA4->AA4_CODCLI := cCliCod
			AA4->AA4_LOJA 	:= cCliLoja
		AA4->(MsUnlock())

		AA4->(dbSkip())
	EndDo

	//se for estrutura atualiza ou inclui os itens
	//cSeqEst		:= AllTrim(FPA->FPA_SEQEST)
	cSeqEst		:= FPA->FPA_SEQEST // retirado alltrim para garantir que a 5ª posição esteja vazia quando for um item pai
	//gera somente para estruras e bem sem fihos
	//If At(".",cSeqEst) == 0 //Se tiver um ponto nessa posição, quer dizer que é filho
	If !Empty(cSeqEst) .And. SubStr(cSeqEst,5,1) == " " //Sem NÃO tiver espaço na quinta posição é filho, regra alterada, pois vezes vem com ponto, vezes vem sem ponto da FPA
		//pega o prefixo o item pai
		cSeqEst := SubStr(FPA->FPA_SEQEST, 1, 3)
		//Pula linha para próximo da estrutura
		FPA->(DbSkip())
		While !(FPA->(Eof())) .And. cSeqEst == SubStr(FPA->FPA_SEQEST, 1, 3)
			//sempre é necessário enviar um Id Unico para Acessório
			If Empty(cNSerAc)
				cNSerAc	:= NewIdAA4(AA3->AA3_NUMSER)
			Else
				cNSerAc := Soma1(cNSerAc)
			EndIf
			If AA4->(MsSeek(xFilial("AA4") + cCliCod + cCliLoja + AA3->AA3_CODPRO + AA3->AA3_NUMSER + FPA->FPA_PRODUT))
				lIncluiAc := .F.
			Else
				lIncluiAc := .T.
			EndIf
			Reclock("AA4",lIncluiAc)
				AA4->AA4_FILIAL := xFilial("AA4")
				AA4->AA4_CODPRO := AA3->AA3_CODPRO
				AA4->AA4_NUMSER := AA3->AA3_NUMSER
				AA4->AA4_PRODAC := FPA->FPA_PRODUT
				AA4->AA4_NSERAC := cNSerAc
				AA4->AA4_CODCLI := AA3->AA3_CODCLI
				AA4->AA4_LOJA 	:= AA3->AA3_LOJA
			AA4->( MsUnlock() )
			//Pula linha para próximo da estrutura
			FPA->(DbSkip())
		EndDo
	EndIf

	//?Atualiza o historico do equipamento                               ?
	Reclock("AAF",.T.)
	AAF->AAF_FILIAL := xFilial("AAF")
	AAF->AAF_CODCLI := cCliCod
	AAF->AAF_LOJA   := cCliLoja
	AAF->AAF_CODPRO := AA3->AA3_CODPRO
	AAF->AAF_NUMSER := AA3->AA3_NUMSER
	AAF->AAF_PRODAC := AA3->AA3_CODPRO
	AAF->AAF_NSERAC := AA3->AA3_NUMSER
	AAF->AAF_DTINI  := dDataBase
	AAF->AAF_CODFAB := AA3->AA3_CODFAB
	AAF->AAF_LOJAFA := AA3->AA3_LOJAFA
	AAF->AAF_LOGINI := Left( 	STR0003 + 	cCodCliAnt + "/" + ; //"Transferencia de cliente/loja/projeto/AS "
																				cLojaCliAnt + "/" + ;
																				cProjetAnt + "/" + ;
																				cAsAnt + "/" + ;
																				STR0004 + ; //" para "
																				cCliCod + "/" + ;
																				cCliLoja + "/" + ;
																				FP0->FP0_PROJET + "/" + ;
																				FPA->FPA_AS ,  ;
								Len( AAF->AAF_LOGINI ) ) // # "TRANSFERENCIA DE CLIENTE/LOJA " ## " PARA "
	AAF->( MsUnlock() )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FAchouAA3

Posiciona na AA3 para realizar alteração ou Transferencia de cliente
@type  Static Function
@author Jose Eulalio
@since 17/01/2023

/*/
//------------------------------------------------------------------------------
Static Function FAchouAA3(cCodProd,cCodBem,cCliCod,cCliLoja,cEqAloc,nOperacao)
Local cQuery	:= ""
Local cAliasAA3 := GetNextAlias()
Local nRecnoAA3 := 0
Local lRet		:= .F.

	AA3->(DbSetOrder(1)) //AA3_FILIAL+AA3_CODCLI+AA3_LOJA+AA3_CODPRO+AA3_NUMSER+AA3_FILORI
	If AA3->(DbSeek(xFilial("AA3") + cCliCod + cCliLoja + cCodProd + cCodBem ))
		nOperacao 	:= 4
		lRet		:= .T. //ESSA LINHA FOI INSERIDA, POIS A GRAVAÇÃO PADRÃO ESTÁ COM PROBLEMA NA FUNÇÃO At040Alter, ELA ALTERA O TAMANHOA DE M->AA3_NUMSER PARA 15, enquanto AA3->AA3_NUMSER TEM 20
	Else

		cQuery += " SELECT R_E_C_N_O_ RECNOAA3 FROM " + RetSqlName("AA3")
		cQuery += " WHERE 	AA3_CODPRO = '"
		&('cQuery += cCodProd')
		cQuery += "' AND "
		If !Empty(cCodBem)
			cQuery += " 		AA3_NUMSER = '"
			&('cQuery += cCodBem')
			cQuery += "' AND "
		EndIf
		cQuery += " 		AA3_FILIAL = '" + xFilial("AA3") + "' AND "
		cQuery += " 		D_E_L_E_T_ =  ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAA3,.T.,.T.)

		If !(cAliasAA3)->(Eof())
			lRet		:= .T.
			nRecnoAA3 	:= (cAliasAA3)->RECNOAA3
			AA3->(DbGoTo(nRecnoAA3))
		EndIf

		(cAliasAA3)->(DbCloseArea())

	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} NewIdAA3

Gera novo Id Unico para AA3_NUMSER baseado no Produto e Cliente
@type  Static Function
@author Jose Eulalio
@since 17/01/2023

/*/
//------------------------------------------------------------------------------
Static Function NewIdAA3( cCodProd , cCliCod , cCliLoja )
Local cIdAa3	:= ""
Local cSeqAa3	:= "01"
Local cQuery	:= ""
Local cAliasAA3 := GetNextAlias()
Local cNewProd	:= AllTrim(SubStr(cCodProd, 1, 8))
Local lBusca	:= .T.

	//Query não considera nem filial, nem delete, pois o número deve ser único
	cQuery += " SELECT MAX(AA3_NUMSER) NUMSER FROM " + RetSqlName("AA3")
	cQuery += " WHERE "
	cQuery += " 		AA3_NUMSER LIKE '"
	&('cQuery += cNewProd + cCliCod + cCliLoja')
	cQuery += "%'  "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAA3,.T.,.T.)

	If !(cAliasAA3)->(Eof()) .And. !Empty((cAliasAA3)->NUMSER)
		cSeqAa3 	:= AllTrim(StrTran((cAliasAA3)->NUMSER, cNewProd + cCliCod + cCliLoja, ""))
		cSeqAa3 	:= Soma1(cSeqAa3)
	EndIf

	(cAliasAA3)->(DbCloseArea())

	cIdAa3 := cNewProd + cCliCod + cCliLoja + cSeqAa3

	//verifica se existe na AA4
	While lBusca

		//Query não considera nem filial, nem delete, pois o número deve ser único
		/*
		+ cIdAa3 +
		*/
		cQuery := " SELECT AA4_NSERAC NSERAC FROM " + RetSqlName("AA4")
		cQuery += " WHERE "
		cQuery += " 		AA4_NSERAC = ?  "

		cQuery := ChangeQuery(cQuery)
		aBindParam := {cIdAa3}
		cAliasAA3 := MPSysOpenQuery(cQuery,,,,aBindParam)

		//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAA3,.T.,.T.)

		If !(cAliasAA3)->(Eof()) .And. !Empty((cAliasAA3)->NSERAC)
			cIdAa3 := Soma1(cIdAa3)
		Else
			lBusca := .F.
		EndIf

		(cAliasAA3)->(DbCloseArea())

	EndDo

Return cIdAa3

//------------------------------------------------------------------------------
/*/{Protheus.doc} NewIdAA4

Gera novo Id Unico para AA4_NSERAC baseado no Produto e Cliente
@type  Static Function
@author Jose Eulalio
@since 17/01/2023

/*/
//------------------------------------------------------------------------------
Static Function NewIdAA4( cCodBem )
Local cIdAA4	:= ""
Local cSeqAA4	:= "01"
Local cQuery	:= ""
Local cAliasAA4 := GetNextAlias()
Local cNewCod	:= AllTrim(SubStr(cCodBem, 1, 18))
Local lBusca	:= .T.

	//Query não considera nem filial, nem delete, pois o número deve ser único
	cQuery += " SELECT MAX(AA4_NSERAC) NSERAC FROM " + RetSqlName("AA4")
	cQuery += " WHERE "
	cQuery += " 		AA4_NSERAC LIKE '"
	&('cQuery += cNewCod')
	cQuery += "%'  "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAA4,.T.,.T.)

	If !(cAliasAA4)->(Eof()) .And. !Empty((cAliasAA4)->NSERAC)
		cSeqAA4 	:= AllTrim(StrTran((cAliasAA4)->NSERAC, cNewCod, ""))
		cSeqAA4 	:= Soma1(cSeqAA4)
	EndIf

	(cAliasAA4)->(DbCloseArea())

	cIdAA4 := cNewCod + cSeqAA4

	//verifica se existe na AA4
	While lBusca

		/*
		+ cIdAA4 +
		*/

		//Query não considera nem filial, nem delete, pois o número deve ser único
		cQuery := " SELECT AA3_NUMSER NSERAC FROM " + RetSqlName("AA3")
		cQuery += " WHERE "
		cQuery += " 		AA3_NUMSER = ?  "

		cQuery := ChangeQuery(cQuery)
		aBindParam := {cIdAA4}
		cAliasAA4 := MPSysOpenQuery(cQuery,,,,aBindParam)

		//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAA4,.T.,.T.)

		If !(cAliasAA4)->(Eof()) .And. !Empty((cAliasAA4)->NSERAC)
			cIdAA4 := Soma1(cIdAA4)
		Else
			lBusca := .F.
		EndIf

		(cAliasAA4)->(DbCloseArea())

	EndDo

Return cIdAA4


Function FP0AA3Fil(cCodCli,cLojCli)

Local oDlg, oLbx
Local aCpos  	:= {}
Local aRet   	:= {}
Local cQuery 	:= ""
Local cAliasQry := GetNextAlias()
Local cCliPesq	:= ""
Local cLojPesq	:= ""
Local lRet   	:= .F.
Local cPesq 	:= Space(30)

Private aLstBxOri	:= {}

	/*
	+ cCodCli +
	+ cLojCli +
	+ cCodCli +
	+ cLojCli +
	*/

	cQuery := " SELECT DISTINCT FP0_PROJET, FP0_NOMECO, FP0_CLI, FP0_LOJA, FP1_CLIORI, FP1_LOJORI,FQ7_LCCDES, FQ7_LCLDES, A1_NOME "
	cQuery += " FROM " + RetSqlName("FP0") + " FP0 "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " 	ON A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += " 	AND A1_COD = ? "
	cQuery += " 	AND A1_LOJA = ? "
	cQuery += " 	AND SA1.D_E_L_E_T_ = ' '  "
	cQuery += " INNER JOIN " + RetSqlName("FP1") + " FP1 "
	cQuery += " 	ON FP0_FILIAL = FP1_FILIAL "
	cQuery += " 	AND FP0_PROJET = FP1_PROJET "
	cQuery += " 	AND A1_COD = FP1_CLIORI "
	cQuery += " 	AND A1_LOJA = FP1_LOJORI "
	cQuery += " 	AND FP1.D_E_L_E_T_ = ' '  "
	cQuery += " LEFT JOIN " + RetSqlName("FQ7") + " FQ7 "
	cQuery += " 	ON FP0_FILIAL = FQ7_FILIAL "
	cQuery += " 	AND FP0_PROJET = FQ7_PROJET "
	cQuery += " 	AND FP1_OBRA = FQ7_OBRA "
	cQuery += " 	AND A1_COD = FQ7_LCCDES "
	cQuery += " 	AND A1_LOJA = FQ7_LCLDES "
	cQuery += " 	AND FQ7.D_E_L_E_T_ = ' '  "
	cQuery += " WHERE 	FP0_FILIAL = '" + xFilial("FP0") + "' "
	cQuery += " 	AND FP0.D_E_L_E_T_ = ' '  "
	cQuery += " 	AND SA1.D_E_L_E_T_ = ' '  "
	cQuery += " 	AND A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += " 	AND A1_COD = ? "
	cQuery += " 	AND A1_LOJA = ? "
	cQuery += " ORDER BY FP0_PROJET DESC "

	cQuery := ChangeQuery(cQuery)
	aBindParam := {cCodCli, cLojCli, cCodCli, cLojCli }
	cAliasQry := MPSysOpenQuery(cQuery,,,,aBindParam)

	//dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

	While (cAliasQry)->(!Eof())
		If !Empty((cAliasQry)->(FQ7_LCCDES)) // Circenis 14/02/24 Incluido o Alias
			cCliPesq := (cAliasQry)->(FQ7_LCCDES)
			cLojPesq := (cAliasQry)->(FQ7_LCLDES)
		Else
			cCliPesq := (cAliasQry)->(FP1_CLIORI)
			cLojPesq := (cAliasQry)->(FP1_LOJORI)
		EndIf
		aAdd(aCpos,{(cAliasQry)->(FP0_PROJET), cCliPesq, cLojPesq, (cAliasQry)->(A1_NOME)})
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	If Len(aCpos) < 1
		aAdd(aCpos,{" "," "," "," "})
	EndIf

	DEFINE MSDIALOG oDlg TITLE /*STR0083*/ STR0005 FROM 0,0 TO 260,500 PIXEL //"Orçamentos Rental"

		//Texto de pesquisa
		@ 003,010 MsGet oPesqEv Var cPesq Size 192,009 COLOR CLR_BLACK PIXEL OF oDlg

		//Interface para selecao de indice e filtro
		@ 003,205 Button STR0010    Size 043,012 PIXEL OF oDlg Action IF(!Empty(oLbx:aArray[oLbx:nAt][2]),ITPESQ(oLbx,cPesq),Nil) //Pesquisar

		@ 018,010 LISTBOX oLbx FIELDS HEADER STR0007 , STR0008 , STR0006  , STR0009 SIZE 240,95 OF oDlg PIXEL //'Loja' //'Orçamento' //'Cliente' //'Nome'

		oLbx:SetArray( aCpos )

		//copia array original
		aLstBxOri := aClone(oLbx:aArray)

		oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4]}}
		oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4]}}}

	DEFINE SBUTTON FROM 114,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3], oLbx:aArray[oLbx:nAt,4]})  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER

	If Len(aRet) > 0 .And. lRet
		If Empty(aRet[1])
			lRet := .F.
		Else
			FP0->(dbSetOrder(1))
			FP0->(dbSeek(xFilial("FP0")+aRet[1]))
		EndIf
	EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ITPESQ

Funcao para pesquisar dentro da consulta padrao SXB
@type  Static Function
@author Jose Eulalio
@since 16/09/2022

/*/
//------------------------------------------------------------------------------
Static Function ITPESQ(oLstBx,cPesq)
Local _nX
Local _nY
Local nTamArray	:= len(oLstBx:aArray)
Local nContArra	:= 1
Local _lAchou 	:= .F.
Local aLstBxNew	:= {}

	If empty(AllTrim(cPesq)) .Or. Len(AllTrim(cPesq)) < 2
		MsgAlert(STR0011,STR0012)	// "Favor informar o que deseja pesquisar " ##### "Atenção!"
		oLstBx:setarray(aLstBxOri)
		oLstBx:bLine 	:= {|| {aLstBxOri[oLstBx:nAt,1],;
								aLstBxOri[oLstBx:nAt,2],;
								aLstBxOri[oLstBx:nAt,3],;
								aLstBxOri[oLstBx:nAt,4]}}
		oLstBx:nAt := 1
		oLstBx:Refresh()
	Else
		//Busca a partir da linha posicionada + 1
		For _nx := 1 to nTamArray
			For _nY := 1 to 4
				If UPPER(AllTrim(cPesq)) $ UPPER(alltrim(oLstBx:aArray[_nX,_nY]))
					Aadd(aLstBxNew,oLstBx:aArray[_nX])
					Exit
				EndIf
				++nContArra
			Next _nY
		Next _nx
		If Len(aLstBxNew) > 0
			_lAchou := .T.
			aSort(aLstBxNew,,,{|x,y| x[1] > y[1]})
			oLstBx:setarray(aLstBxNew)
			oLstBx:bLine 	:= {|| {aLstBxNew[oLstBx:nAt,1],;
									aLstBxNew[oLstBx:nAt,2],;
									aLstBxNew[oLstBx:nAt,3],;
									aLstBxNew[oLstBx:nAt,4]}}
			oLstBx:nAt := 1
			oLstBx:Refresh()
		EndIf
		If !_lAchou
			If nContArra >= nTamArray
				MsgAlert(STR0013,STR0012)	// "Não localizado." ##### "Atenção!"
				oLstBx:setarray(aLstBxOri)
				oLstBx:bLine 	:= {|| {aLstBxOri[oLstBx:nAt,1],;
										aLstBxOri[oLstBx:nAt,2],;
										aLstBxOri[oLstBx:nAt,3],;
										aLstBxOri[oLstBx:nAt,4]}}
				oLstBx:nAt := 1
				oLstBx:Refresh()
			//Else
				//oLstBx:nAt := 1
			EndIf
		EndIf
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AB6Gatilho()
Gatilho da tabela AB6

@author Jose Eulalio
@since 27/01/2023
/*/
//-------------------------------------------------------------------
Function AB6Gatilho(cCampo)
Local xRet 		:= &(ReadVar())
/*Local nX		:= 0
Local nPosProd 	:= aScan(aHeaderAB7,{|x| AllTrim(x[2])=="AB7_CODPRO"})
Local nPosNSer 	:= aScan(aHeaderAB7,{|x| AllTrim(x[2])=="AB7_NUMSER"})
Local nPosAS 	:= aScan(aHeaderAB7,{|x| AllTrim(x[2])=="AB7_AS"})
Local nTamProd	:= tamsx3("AB7_CODPRO")[1]
Local nTamNSer	:= tamsx3("AB7_NUMSER")[1]
Local nTamAS	:= 0
Local nTamHead	:= Len(acols[1])
Local lMvGSxRent:= SuperGetMv("MV_GSXRENT",.F.,.F.)

//Integração com o Rental
If lMvGSxRent
	If cCampo == "AB6_PROJET"
		For nX := 1 To Len(aCols)
			nTamAS	:= tamsx3("AB7_AS")[1]
			aCols[nX][nPosProd] := Space(nTamProd)
			aCols[nX][nPosNSer] := Space(nTamNSer)
			aCols[nX][nPosAS] 	:= Space(nTamAS)
			If nX <> 1
				aCols[nX][nTamHead] := .T.
			EndIf
		Next nX
	EndIf
EndIf*/

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AB7Valid()
Gatilho da tabela AB6

@author Jose Eulalio
@since 27/01/2023
/*/
//-------------------------------------------------------------------
Function AB7Valid()
Local lRet 		:= .T.
Local lMvGSxRent:= SuperGetMv("MV_GSXRENT",.F.,.F.)
Local cCpoEdit	:= ""

	//Integração com o Rental
	If lMvGSxRent
		If AB6->(FieldPos("AB6_PROJET")) > 0 .And. AB7->(FieldPos("AB7_AS")) > 0
			cCpoEdit := ReadVar()
			lRet := ExistCpo( "FPA" , M->AB6_PROJET + &(cCpoEdit) , 6 )
		EndIf
	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AB7When()
When da Tabela AB7

@author Jose Eulalio
@since 27/01/2023
/*/
//-------------------------------------------------------------------
Function AB7When()
Local lRet		:= .T.
Local lMvGSxRent:= SuperGetMv("MV_GSXRENT",.F.,.F.)
Local cCpoEdit	:= ""

	//Integração com o Rental
	If lRet .And.lMvGSxRent
		If AB6->(FieldPos("AB6_PROJET")) > 0 .And. AB7->(FieldPos("AB7_AS")) > 0 .And. !Empty(M->AB6_PROJET)
			cCpoEdit := ReadVar()
			If AllTrim(cCpoEdit) == 'M->AB7_CODPRO' .Or. AllTrim(cCpoEdit) == 'M->AB7_NUMSER'
				lRet := .F.
			ElseIf AllTrim(cCpoEdit) == 'M->AB7_AS'
				lRet := !Empty(M->AB6_PROJET)
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AB6When()
When da Tabela AB6

@author Jose Eulalio
@since 27/01/2023
/*/
//-------------------------------------------------------------------
Function AB6When()
Local lRet		:= .T.
Local lMvGSxRent:= SuperGetMv("MV_GSXRENT",.F.,.F.)
Local cCpoEdit	:= ""

	//Integração com o Rental
	If lRet .And.lMvGSxRent
		cCpoEdit := ReadVar()
		If cCpoEdit == "M->AB6_PROJET"
			If !Empty(&(cCpoEdit))
				lRet := .F.
			EndIf
		ElseIf !Empty(M->AB6_PROJET)
			lRet := .F.
		EndIf
	EndIf

Return lRet

