#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_PFS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

Static _lExecutou    := .F.
Static _cEmpresa     := ""
Static _lAjuBrw      := .F. // Indica se deve ajustar o X3_BROWSE
Static _lCriaOI8     := .F. // Indica se deve entrar na rotina de criação de movimentação de adiantamento
Static _aTableSinc   := {}  // Verifica se a tabela deve ser sincronizada ao final de processamento da Filial
Static _aTabExist    := {}  // Verifica se as tabelas existem
Static _aColExist    := {}  // Verifica se as colunas Existem

//-------------------------------------------------------------------
/*/{Protheus.doc} RUP_PFS
Função para compatibilização do release incremental.
Esta função é relativa ao módulo pré-faturamento de Serviços (PFS).

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author Cristina Cintra
@since 15/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function RUP_PFS(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local aSX3         := {}
Local aSX3Old      := {}
Local aSX3Estr     := {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}

Local aSX9         := {}
Local aSX9Estr     := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM","X9_EXPCDOM","X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR", "lApaga" }

Local aSX7         := {}
Local aSX7Estr     := {"X7_CAMPO","X7_SEQUENC","X7_REGRA","X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC","X7_PROPRI", "lApaga" }

Local aSX5         := {}

Local aSX6         := {}
Local aSX6Estr     := { "X6_FIL", "X6_VAR", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PYME" }
Local cSX6Conteudo := ""

Local nPosCpo      := 0

#IFNDEF TOP
	Return Nil
#ENDIF

If _cEmpresa == cEmpAnt //Controle para permitir a atualização de todas as empresas
	_lExecutou := .T.
Else
	//Reinicia as variáveis estáticas a cada mudança de empresa, para alteração de dicionário de dados
	_lExecutou  := .F.
	_cEmpresa   := cEmpAnt
	_aTableSinc := {}
	_aTabExist  := {}
	_aColExist  := {}
EndIf

//----------------------------------------------------------------
// Solução paliativa sugerida pelo FrameWork para solucionar
// o errolog na função "SomaAbat", pois quando RUP_PFS é
// executado via UPDDISTR o SE1 está aberto de forma exclusiva
// e o "ChkFile" na linha 14283 (finxfin.prw) não consegue
// criar um novo alias.
//----------------------------------------------------------------
If FunName() == "UPDDISTR"
	DbSelectArea("SE1")
	SE1->(DbCloseArea())
	Chkfile("SE1", .F.)
EndIf

//------------------------------------------------------
// Atualizações necessárias para clientes que estão no release 12.1.33
//------------------------------------------------------
If cRelStart == "033" .And. cRelFinish >= "033"

	//========================================================================================
	// Funções para alterações no pacote de ajustes da JURA202 (006364) issue  DJURFAT1-8103
	// colocar todas alterações referente a esse pacote dentro dessa função.
	//========================================================================================
	If !_lExecutou
		JRUP202()
	EndIf

	//----------------------------------------------------------------------------------------------
	//DJURFAT1-9726 Aprovação de Despesas - Ajuste de naturezas com tipo de conta jurídica definida
	//----------------------------------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("SED") .And. SED->(JColumnPos("ED_CCJURI")) .And. SED->(JColumnPos("ED_TPCOJR"))
		JURPFS9726()
	EndIf

	//-----------------------------------------------------------------------------------
	// DJURFAT1-7923 - Envio do link da NFS-e no envio de e-mail das faturas/Pesquisa por NFe
	//-----------------------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXA") 
		If NXA->(JColumnPos("NXA_NFELET")) > 0 .And. NXA->(JColumnPos("NXA_LINKNF")) > 0
			AtuOrdem("NXA", Val(RetAsc('C0', 3, .F.)), "NXA_NFELET")
			AtuOrdem("NXA", Val(RetAsc('C1', 3, .F.)), "NXA_LINKNF")
		EndIf
		If NXA->(JColumnPos("NXA_NFGER")) > 0
			aSX3      := {}
			aSX3Old   := {}
			aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO", "X3_DESCRIC"}	
			Aadd(aSX3, {"NXA", "NXA_NFGER", "Doc Fis Ger?", "Documento Fiscal gerado?" } )		
			AtuSX3(aSX3, aSX3Estr, aSX3Old)
		EndIf
	EndIf

	If !_lExecutou .And. JChkfile("NS7") .And. NS7->(JColumnPos("NS7_LINKNF")) > 0
		AtuOrdem("NS7", 15, "NS7_LINKNF")
	EndIf

	//--------------------------------------------------------
	// DJURFAT1-8900 - Alteração formato da data no corpo do e-mail (envio de faturas)
	//--------------------------------------------------------
	If JChkfile("NRU") .And. NRU->(JColumnPos("NRU_DTFORM")) > 0
		JURPFS8900()
	EndIf

	//--------------------------------------------------------
	// DJURFAT1-9125 - Importação de Extrato Bancário
	//--------------------------------------------------------
	If JChkfile("OHB") .And. OHB->(JColumnPos("OHB_ORIGEM")) > 0  .And. OHB->(JColumnPos("OHB_CODLD")) > 0
		JURPFS9125()
	EndIf

	//-------------------------------------------------------------
	// DJURFAT1-10113 - Data de Revisão na Solicitação de Despesas
	//-------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NZQ") .And. NZQ->(JColumnPos("NZQ_DTREVI")) > 0
		AtuOrdem("NZQ", 16, "NZQ_DTREVI")
	EndIf

	//-----------------------------------------------------------------------
	// DJURFAT1-10442 - Atualiza campo de arquivo e-billing gerado na fatura
	//-----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXA") .And. NXA->(JColumnPos("NXA_ARQEBI")) > 0
		JPFS10442()
	EndIf

	If !_lExecutou

		//-----------------------------------------------------------------------
		//DJURFAT1-9713 Revisão de campos na Browse da Pré-fatura e Fatura
		//-----------------------------------------------------------------------
		If JChkfile("NXA") .And. JChkfile("NXC") .And. JChkfile("NX0") .And. JChkfile("NX1")
			JURPFS9713()
		EndIf

		//----------------------------------------------------------------------------
		// DJURFAT1-13504 - Ajustes na Natureza transitória de pagamento
		//----------------------------------------------------------------------------
		If JChkfile("OHP")
			JPFS13504()
		EndIf

		//----------------------------------------------------------------------------
		// DJURFAT1-14913 - Ajustes para permitir várias naturezas de desp. cliente
		//----------------------------------------------------------------------------
		JPFS14913()

		//----------------------------------------------------------------------
		// DJURFAT1-14432 - Revisão de TSs de contratos fixos e não cobráveis e 
		// Débitos Técnicos, exclusão de relacionamento
		//----------------------------------------------------------------------
		JPFS14432()
	
		//-----------------------------------------------------------------
		// DJURFAT1-17642 - Data final da participação do caso
		//-----------------------------------------------------------------
		JPFS17642()

		If SuperGetMV('MV_JUTPROJ', , .F.)
			JDEP10299()
		EndIf

		//----------------------------------------------------------------------
		// DJURFAT1-14119 - Vínculo de TimeSheet não cobrável na emissão 
		//----------------------------------------------------------------------
		JPFS14119()

		//---------------------------------------------------------------------------------
		// DJURFAT1-14546 - Agrupamento no envio de faturas por e-mail - encaminhamentos
		//---------------------------------------------------------------------------------
		JPFS14546()

		//----------------------------------------------------------------------
		// DJURFAT1-14594 - Gross up de Impostos / Honorários
		//----------------------------------------------------------------------
		JPFS14594()

		//----------------------------------------------------------------------
		// DJURFAT1-14640 - Quantidade de casos para cálculo de faixa
		//----------------------------------------------------------------------
		JPFS14640()
		
		//--------------------------------------------------
		// DJURFAT1-14504 - Ajuste tamanho do campo NWF_COD
		//------------------------------------------------------
		JPFS14504()

		//---------------------------------------------------------
		// DJURFAT1-15624 - Ajuste na ordem do campo NUH_ENCCAS
		//---------------------------------------------------------
		If JChkfile("NUH")
			JPFS15624()
		EndIf
		//----------------------------------------------------------------------------
		// DJURFAT1-15929 - Tira usado do campo NRC_FUTURO
		//----------------------------------------------------------------------------
		JPFS15929()

		//----------------------------------------------------------------------------
		// DJURFAT1-16328 - Novos campos na tela de Casos (GAP V11) - Itens 28 e 29
		//----------------------------------------------------------------------------
		If JChkfile("NVE")
			JPFS16328()
		EndIf
	EndIf
EndIf

//------------------------------------------------------
// Atualizações necessárias para clientes que estão até o release 12.1.2210
//------------------------------------------------------
If cRelStart >= "033" .And. cRelFinish <= "2210"

	If !_lExecutou
		//-----------------------------------------------------------------
		// DJURFAT1-16437 - Tempo Produtivo no Resumo de Profissionais
		//-----------------------------------------------------------------
		JPFS16437()
	EndIf

EndIf

//------------------------------------------------------
// Atualizações necessárias independente do release inicial
//------------------------------------------------------
If cRelFinish >= "033"

	//-----------------------------------------------------------------------
	//DJURFAT1-9713 Revisão de campos na Browse da Pré-fatura e Fatura
	//-----------------------------------------------------------------------
	If !_lExecutou .And. JChkfile("NXA") .And. JChkfile("NXC") .And. JChkfile("NX0") .And. JChkfile("NX1")
		JURPFS9713()
	EndIf

	//------------------------------------------------------------------------------------
	// DJURFAT1-15881 - Desconto não é preenchido no Participante da Fatura (NXD_DESCTO)
	//------------------------------------------------------------------------------------
	If FindFunction("J201DesLin")
		JPFS15881()
	EndIf

	If !_lExecutou
		//----------------------------------------------------------------------------
		// DJURDEP-11582 - Ajuste na Ordem dos campos de Relatório Unificado.
		//----------------------------------------------------------------------------
		JJUR11582()

		//--------------------------------------------------------
		// DJURFAT1-13102 - Ajustes no Controle de Adiantamentos
		//--------------------------------------------------------
		aSX7      := {}
		aSX7Estr  := {"X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "lApaga" }
		Aadd(aSX7, {"NWF_CCLIEN", "005", '""', "NWF_CESCR ", "__lApaga"} )
		Aadd(aSX7, {"NWF_CLOJA ", "005", '""', "NWF_CESCR ", "__lApaga"} )
		Aadd(aSX7, {"NWF_CLOJA ", "008", "NUH->NUH_CESCR2", "NWF_CESCR ", "__lApaga"} )

		//--------------------------------------------------------------------
		// DJURFAT1-15959 - Inativação dos motivos de cancelamento das faturas
		//--------------------------------------------------------------------
		If JChkfile("NSA")
			JPFS15959()
		EndIf

		//--------------------------------------------------------------------
		// DJURFAT1-17549 - Sócio Responsável e Revisor no histórico do Caso
		//--------------------------------------------------------------------
		If JChkfile("NUU")
			JPFS17549()
		EndIf
		
		//----------------------------------------------------------------------------
		// DJURFAT1-16035 - Indicação de adiantamento na Aprovação de Despesas
		//----------------------------------------------------------------------------
		If JChkfile("NZQ") .And. NZQ->(JColumnPos("NZQ_ADIANT")) > 0
			JPFS16035()
		EndIf

		//--------------------------------------------------------------------------------------
		// DJURFAT1-16365 - [Sync] Mudança no campo de Abertura Automática de Casos
		//--------------------------------------------------------------------------------------
		If JChkfile("NT0") .And. NT0->(JColumnPos("NT0_SUGPLD")) > 0
			JPFS16365()
		EndIf

		//--------------------------------------------------------------------------------------
		// DJURFAT1-18244 - Indicação do formato e geração automática de E-billing
		//--------------------------------------------------------------------------------------
		If !_lExecutou .And. JChkfile("NUH") .And. NUH->(JColumnPos("NUH_FORMEB")) > 0
			nPosCpo := Val(GetSx3Cache("NUH_DEMP", "X3_ORDEM"))
			AtuOrdem("NUH", nPosCpo + 1, "NUH_FORMEB")
			AtuOrdem("NUH", nPosCpo + 2, "NUH_CMOEBI")
			AtuOrdem("NUH", nPosCpo + 3, "NUH_DMOEBI")
		EndIf
		
		//----------------------------------------------------------------------------
		// DJURFAT1-16828 - Movimentações em Adiantamentos
		//----------------------------------------------------------------------------
		If FwIsInCallStack("UPDPFS")
			JPFS16828() // Popula tabela de Movimentações em Adiantamentos (OI8) para adiantamentos criados via JURA069 (Com NWF).
		EndIf
		//--------------------------------------------------------
		// DJURFAT1-19044 - Tirar o Loja automática do campo cliente do adiantamento
		//--------------------------------------------------------
		Aadd(aSX7, {"NWF_CCLIAD", "003", "JurLoja()", "NWF_CLOJAD", "__lApaga"} )
		AtuSX7(aSX7, aSX7Estr)

		//----------------------------------------------------------------------------
		// DJURFAT1-18988 - [Sync] Cancelamento de Solicitação de Despesa
		//----------------------------------------------------------------------------
		If !_lExecutou .And. JColumnPos("NZQ_ORIGEM") > 0
			JPFS18988() // Preenche o campo NZQ_ORIGEM
		EndIf

		//----------------------------------------------------------------------------
		// DJURFAT1-19449 - [MMSO] Emissão de Pré-Fatura - NW0_CANC
		//----------------------------------------------------------------------------
		JPFS19449() // Cancela o vínculo dos lançamentos com as pré-faturas de conferência

		//----------------------------------------------------------------------------
		// DJURFAT1-19247 - [Sync] Obrigatoriedade de campos no Participante
		//----------------------------------------------------------------------------
		If !_lExecutou .And. JChkfile("RD0")
			JPFS19247() // Preenche o campo RD0_TPJUR como '1-Sim' quando o MV_JFTJURI está ativo
		EndIf


	EndIf

	//----------------------------------------------------------------------------
	// DJURFAT1-16828 - Movimentações em Adiantamentos
	//----------------------------------------------------------------------------
	If _lCriaOI8 // Static preenchida na função JPFS16828()
		// Essa função deve ser executada para cada filial. Portanto não colocar !_lExecutou
		JPFS16828B() // Insere dados de adiantamentos criados direto no SIGAFIN (Sem NWF)
	EndIf

	//----------------------------------------------------------------------------
	// DJURFAT1-19730 - Contabilização de WO por despesa
	//----------------------------------------------------------------------------
	If JColumnPos("NVZ_FILLAN") > 0
		// Essa função deve ser executada para cada filial. Portanto não colocar !_lExecutou
		JPFS19730() // Preenche os campos NVZ_FILLAN, NVZ_DTCEMI e NVZ_DTCCAN
	EndIf
	//----------------------------------------------------------------------------
	// DJURFAT1-20747 - Ajuste do Número da Nota Fiscal Eletrônica de Serviço
	//----------------------------------------------------------------------------
	If !_lExecutou .And. JColumnPos("F2_NFELETR") > 0
		JPFS20747A() // Ajusta os campos E1_NFELETR, OHH_NFELET, NXA_NFELET e NXA_LINKNF
	EndIf
	//---------------------------------------------------------------------------------------------------------------------------
	// DJURFAT1-20248 - Realizar a carga inicial na tabela de Impostos da Fatura (OIC) com os impostos desmembrados da Fatura(NXA)
	//---------------------------------------------------------------------------------------------------------------------------
	If !_lExecutou 
		JPFS20248()
	EndIf

	//----------------------------------------------------------------------------
	// DJURFAT1-18974 - Desconto em Tabelado - Pagador [015799]
	//----------------------------------------------------------------------------
	If !_lExecutou .And. JColumnPos("NXP_TPERCD") > 0 .And. JColumnPos("NXG_TPERCD") > 0
		JPFS18974() // Preenche os campos NXP_TPERCD e NXG_TPERCD
	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	// DJURFAT1-21422 - Realiza a carga inicial na tabela de Impostos Pos. Hist. C. Receber (OIB) com base nos registros da Posicao Historica Ctas Receber (OHH)
	//---------------------------------------------------------------------------------------------------------------------------
	JPFS21422()
EndIf

If FunName() == "UPDDISTR"
	SE1->(DbCloseArea())
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX3(aSX3)
Função para ajustar o SX3. Caso aSX3Old tenha conteúdo, a alteração é
realizada apenas se o conteúdo for igual a base do cliente.
Uso Geral

@Param aSX3 Array com alterações do arquivo SX3

@author Cristina Cintra
@since 15/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX3(aSX3, aSX3Estr, aSX3Old, cLog)
Local nI        := 0
Local nJ        := 0
Local cKey      := ""
Local xValue    := Nil
Local xValueOld := Nil
Local xValueDic := Nil
Local lAtualiza := .F.
Local cCabec    := ""
Local cAux      := ""
Local cValType  := ""
Local lOrdem    := aScan(aSX3Estr, "X3_ORDEM") > 0
Local nPosRec   := aScan(aSX3Estr, "RECNO")
Local lAchou    := .F.

Default cLog    := ""
Default aSX3Old := {}

/*
aSX3Estr/aSX3
[1]X3_ARQUIVO
[2]X3_CAMPO
*/

DbSelectArea("SX3")
SX3->( DbSetOrder(2) ) //X3_CAMPO

For nI := 1 To Len(aSX3)

	If !Empty(aSX3[nI][1]) .And. (aSX3[nI][1] == SubStr(aSX3[nI][2], 1, 3) .Or. ;
	                               (SubStr(aSX3[nI][1], 1, 1) == 'S' .And. ;
	                                SubStr(aSX3[nI][1], 2, 3) == SubStr(aSX3[nI][2], 1, 2) ) ) // Tabelas com a letra S no início

		cKey := PadR( aSX3[nI][2], 10)
		If nPosRec == 0
			SX3->(DbSeek(cKey))
			lAchou := SX3->(Found())
		Else
			lAchou := .T.
			SX3->(DbGoTo(aSX3[nI][nPosRec]))
		EndIf

		If lAchou .And. (lOrdem .Or. UPPER(SX3->X3_PROPRI) != "U") // Quando for campo de usuário atualiza somente o X3_ORDEM

			RecLock("SX3", .F.)
			cCabec := aSX3[nI][aScan(aSX3Estr, "X3_CAMPO")] + CRLF //Nome do campo
			cAux   := ""

			For nJ := 1 To Len(aSX3Estr)
				If nJ <> nPosRec .And. FieldPos(aSX3Estr[nJ]) > 0

					xValueDic := FieldGet(FieldPos(Alltrim(aSX3Estr[nJ])))
					xValueDic := Iif(ValType(xValueDic) == "C", Alltrim(xValueDic), xValueDic) //Valor  no dicionario do cliente

					If Len(aSX3Old) > 0 //Só altera se não tiver conteudo anterior ou o conteudo do campo X3_XXX atual for igual ao conteudo do release para não alterar customizações.
						xValueOld := aSX3Old[nI][nJ]
						xValueOld := Iif(ValType(xValueOld) == "C", Alltrim(xValueOld), xValueOld)
						lAtualiza := xValueDic == xValueOld
					Else
						lAtualiza := .T.
					EndIf

					If lAtualiza
						//Adiciona novo valor no X3_XXX do campo
						cValType := ValType(aSX3[nI,nJ])
						If cValType != "U" // Torna possível ignorar uma determinada posição passando Nil.
							xValue := Iif(cValType == "C", Alltrim(aSX3[nI,nJ]), aSX3[nI,nJ])

							If !(xValue == xValueDic)
								FieldPut(FieldPos(Alltrim(aSX3Estr[nJ])), xValue)
								cAux += aSX3Estr[nJ] + Space(10 - Len(aSX3Estr[nJ])) + ": [" + Alltrim(AllToChar(xValueDic)) + "] -> [" + Alltrim(AllToChar(xValue)) + "] " + CRLF
							EndIf
						EndIf
					EndIf
				EndIf

			Next nJ

			If !Empty(cAux)
				cLog += cCabec + cAux + Replicate( "-", 78 ) + CRLF + CRLF
			EndIf

			SX3->(MsUnLock())
			SX3->(dbCommit())
		Else
			JurLogMsg(cEmpAnt + "] " + JurTimeStamp(2) +" ["+ STR0001 + cKey) //"Campo não encontrado: "
		EndIf

	EndIf
Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX9(aSX9)
Função para ajustar o SX9.
lApaga -> A funcao compatibilizadora procura pelo rotulo 'lApaga'  no array aSX9ESTR e
verifica se a posição correspondente no array aSX9 possui o conteudo '__lApaga'.
Nessas condicoes o relacionamento será apagado se o conteudo existir, e se não existir
ou for diferente, todas as informacoes do mesmo serao substituidas pelas informadas em aSX9.
No procedimento padrao, o relacionamento é adicionado no caso de não existir.

Uso Geral

@Param aSX9 Array com alterações do arquivo SX9

@author Ricardo Ferreira Neves
@since 25/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX9(aSX9, aSX9Estr)
Local i         := 0
Local j         := 0
Local nPosUpd   := Ascan(aSX9Estr,{|x| x == "lApaga"} )
Local lApaga    := .F.
Local lRecLock  := .F. // Indica se foi feito RecLock para atualização do registro
Local cDominio  := ""
Local cCDominio := ""

dbSelectArea("SX9")
dbSetOrder(2) // X9_CDOM + X9_DOM

For i := 1 To Len(aSX9)
	If !Empty(aSX9[i][2])

		If ( Len(aSX9[i] ) >= Len(aSX9Estr) )
			// Se existir a coluna de atualizacao no array aSX9Est e se no array de parametros existir
			// a instrucao de exclusão do parametro força a exclusão do registro.
			If( nPosUpd > 0 ) .and. aSX9[i, nPosUpd ] ==  "__lApaga"
				lApaga	:= .T.
			Else
				lApaga	:= .F.
			Endif
		Endif

		If SX9->(DbSeek(aSX9[i,3] + aSX9[i,1])) // X9_CDOM + X9_DOM
			
			cDominio  := aSX9[i,1]
			cCDominio := aSX9[i,3]

			While SX9->(!EOF()) .And. SX9->X9_DOM == cDominio .And. SX9->X9_CDOM == cCDominio
			
				If AllTrim(SX9->X9_EXPDOM) == aSX9[i,4] .And. AllTrim(SX9->X9_EXPCDOM) == aSX9[i,5]
					RecLock("SX9",.F.)
					lRecLock := .T.
				EndIf

				If lRecLock
					If lApaga
						SX9->(DbDelete())
					Else
						For j := 1 To Len(aSX9[i])
							If !Empty(FieldName(FieldPos(aSX9Estr[j])))
								FieldPut(FieldPos(aSX9Estr[j]), aSX9[i, j])
							EndIf
						Next j
					EndIf

					SX9->(MsUnLock())
					SX9->(dbCommit())
				EndIf

				lRecLock := .F.

				SX9->( DbSkip() )
			
			EndDo

		EndIf

		lApaga   := .F.
		lRecLock := .F.

	EndIf
Next i

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX7(aSX7, aSX7ESTR)
Função para ajustar o SX7.
lApaga -> A funcao compatibilizadora procura pelo rotulo 'lApaga'  no array aSX7ESTR e
verifica se a posição correspondente no array aSX7 possui o conteudo '__lApaga'.
Nessas condicoes o gatilho será apagado se o conteudo existir, e se não existir
ou for diferente, todas as informacoes do mesmo serao substituidas pelas informadas em aSX7.
No procedimento padrao, o relacionamento é adicionado no caso de não existir.

Uso Geral

@Param aSX7      Array com alterações do arquivo SX7
@Param aSX7ESTR  Array com os campos da estrutura do arquivo SX7

@author Luciano Pereira dos Santos
@since 28/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX7(aSX7, aSX7ESTR)
Local i         := 0
Local j         := 0
Local lGravaSX7 := .T.
Local lNovo     := .F.
Local lApaga    := .F.
Local cEspaco   := ''
Local nPosNCria := Ascan(aSX7Estr,{|x| x == "lNaoCria"})
Local nPosDel   := Ascan(aSX7Estr,{|x| x == "lApaga"} )
Local nPosCdom  := Ascan(aSX7Estr,{|x| x == "X7_CDOMIN"})
Local nPosRegr  := Ascan(aSX7Estr,{|x| x == "X7_REGRA"})
Local nPosAlia  := Ascan(aSX7Estr,{|x| x == "X7_ALIAS"})
Local nPosOrdm  := Ascan(aSX7Estr,{|x| x == "X7_ORDEM"})
Local nPosChav  := Ascan(aSX7Estr,{|x| x == "X7_CHAVE"})
Local nPosCond  := Ascan(aSX7Estr,{|x| x == "X7_CONDIC"})

dbSelectArea("SX7")
SX7->(dbSetOrder(1))

For i := 1 To Len(aSX7)
	lGravaSX7 := .T.
	lNovo     := .F.
	lApaga    := .F.
	cEspaco   := space(10-(len(aSX7[i,1])))
	If SX7->(DbSeek(aSX7[i,1]+cEspaco+aSX7[i,2]))
		If Iif(nPosCdom > 0, Upper(AllTrim(SX7->X7_CDOMIN)) == Upper(AllTrim(aSX7[i,4])), .T.) .And. ;
		   Iif(nPosRegr > 0, Upper(AllTrim(SX7->X7_REGRA))  == Upper(AllTrim(aSX7[i,3])), .T.) .And. ;
		   Iif(nPosAlia > 0, Upper(AllTrim(SX7->X7_ALIAS))  == Upper(AllTrim(aSX7[i,7])), .T.) .And. ;
		   Iif(nPosOrdm > 0, Upper((AllTrim(AllToChar(SX7->X7_ORDEM)))) == Upper(AllTrim(AllToChar(aSX7[i,8]))), .T.) .And. ;
		   Iif(nPosChav > 0, Upper(AllTrim(SX7->X7_CHAVE))  == Upper(AllTrim(aSX7[i,9])), .T.) .And. ;
		   Iif(nPosCond > 0, Upper(AllTrim(SX7->X7_CONDIC)) == Upper(AllTrim(aSX7[i,10])), .T.)

			lGravaSX7 := .F.
		Endif

		If ( Len(aSX7[i] ) >= Len(aSX7Estr) )
			//-- Se existir a coluna de atualizacao no array aSX7Est e se no array de parametros existir
			//-- a instrucao de exclusão do parametro força a exclusão do registro desde que atenda as
			//-- condições definidas no array aSX7.
			If( nPosDel > 0 ) .and. aSX7[i, nPosDel ] == "__lApaga"
				lApaga := .T.
			Else
				lApaga := .F.
			Endif
		Endif

	Else
		If( nPosDel > 0 ) .and. aSX7[i, nPosDel ] == "__lApaga" // Não achou e é para apagar
			lGravaSX7 := .F.
		EndIf
		
		If lGravaSX7 .And. ( nPosNCria > 0 ) .And. aSX7[i, nPosNCria ] == "__lNaoCria" // Não achou e não pode criar o novo registro
			lGravaSX7 := .F.
		EndIf
		lNovo := .T.
	Endif

	If lApaga
		If !lGravaSX7 // Encontrou o registro para excluir
			RecLock("SX7", .F.)
			SX7->(DbDelete())
			SX7->(MsUnLock())
			SX7->(dbCommit())
		EndIf
	Else
		If lGravaSX7 // Verifica se não encontrou o registro
			lSX7 := .T.
			RecLock("SX7", lNovo)
			For j:=1 To Len(aSX7[i])
				If FieldPos(aSX7Estr[j])>0
					FieldPut(FieldPos(aSX7Estr[j]),aSX7[i,j])
				EndIf
			Next j

			SX7->(MsUnLock())
			SX7->(dbCommit())
		Endif
	EndIf

Next i

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuOrdem
Libera a ordem dos campos das tabelas passadas como parametro e atualiza a ordem no SX3.
Funcao como base da versao 11 - JurcOrdem

@author Rafael Tenorio da Costa
@since 27/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuOrdem(cTabela, nOrdem, cCampo)
Local aArea		:= GetArea()
Local aSX3Area	:= SX3->( GetArea() )
Local aOrdem	:= {}
Local aSX3Estr	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}
Local aCampos	:= {}
Local nOldOrder	:= 0
Local nPasso	:= 0
Local aCpo      := {}
Local nX        := 0
Local cNewOrder := ""
Local nQtdCpos  := 0

	SX3->( DbSetOrder(2) )	//X3_CAMPO
	If SX3->( DbSeek( cCampo ) )

		//Carrega todos os campos da tabela
		SX3->( DbSetOrder(1) )	//X3_ARQUIVO + X3_ORDEM
		SX3->( DbSeek( cTabela ) )
		Do While SX3->( ! EoF() ) .And. SX3->X3_ARQUIVO == cTabela

			Aadd(aCampos, {SX3->X3_CAMPO, SX3->X3_ORDEM} )
			SX3->( DbSkip() )
		End Do

		//Acerta todas as ordens caso tenha pulado alguma ou tenha ordem iguais
		For nX:= 1 To Len(aCampos)

			cNewOrder := RetAsc(Str(nX),2,.T.)

			If cNewOrder <> aCampos[nX][2]

				SX3->( DbSetOrder(2) )	//X3_CAMPO
				If SX3->( DbSeek( aCampos[nX][1] ) )

					RecLock("SX3", .F.)
					SX3->X3_ORDEM	:= cNewOrder
					aCampos[nX][2]	:= cNewOrder
					SX3->( MsUnLock() )
				EndIf
			EndIf
		Next nX

		//Pega ordem atual do campo na base
		SX3->( DbSetOrder(2) )	//X3_CAMPO
		If SX3->( DbSeek( cCampo ) )
			nOldOrder   := Val( RetAsc(SX3->X3_ORDEM, 2, .F.) )
			nPasso      := IIF(nOrdem > nOldOrder, 1, -1)
			If nOldOrder <= Len(aCampos)
				aCpo    := aClone( aCampos[nOldOrder] )
			Else
				nOldOrder := nOrdem + 2
			EndIf
		EndIf

		//Carrega novas ordens
		nQtdCpos := Len(aCampos)
		For nX := nOldOrder To nOrdem Step nPasso

			cNewOrder := RetAsc(Str(nX),2,.T.)

			If nX == nOrdem	.And. nX <= nQtdCpos .And. nX >= 1
				aCampos[nX]   := aClone(aCpo)
				aCampos[nX,2] := cNewOrder
			Else
				If nX+nPasso <= nQtdCpos  .And. nX+nPasso >= 1
					aCampos[nX] := aClone(aCampos[nX+nPasso])
					aCampos[nX,2] := cNewOrder
				EndIf
			EndIf

			//Novas ordens
			If nX <= nQtdCpos .And. nX >= 1
				AAdd(aOrdem, {cTabela, aCampos[nX][1], aCampos[nX][2]} )
			EndIf
		Next nX

		If Len( aOrdem ) > 0

			//Ordena array
			aOrdem := aSort(aOrdem,,,{|x,y| x[3] < y[3] })

			//Reposiciona os campos
			AtuSX3(aOrdem, aSX3Estr, {})
		EndIf

	EndIf

	RestArea(aSX3Area)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} UPDPFS()
Função para executar a atualização do RUPPFS fora do release incremental.

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Main Function UPDPFS()
	Local oModal     := FWDialogModal():New()
	Local aTFolder   := {STR0015, STR0016} //#"Compatibilizador" ##"Selecionar Empresas"
	Local aEmp       := RupGetEmp()
	Local oMarkNo    := LoadBitmap( GetResources(), "LBNO" )
	Local oMarkOk    := LoadBitmap( GetResources(), "LBOK" )
	Local cRelStart  := "033" // "Release inicial"
	Local cRelFinish := GetRpoRelease()
	Local cMemo      := ""
	Local oMemoTermo := Nil
	Local oAceite    := Nil
	Local lAceite    := .F.
	Local oAjuBrw    := Nil
	Local oListbox   := Nil

	oModal:SetFreeArea(300, 150)
	oModal:SetEscClose(.T.)
	oModal:SetTitle(STR0014) //"Compatibilizador de releases - SIGAPFS"
	oModal:CreateDialog()
	oModal:addOkButton({|| Iif(lAceite, (RupProc(aEmp, cRelStart, cRelFinish), oModal:oOwner:End()), ApMsgStop(STR0017, STR0015 )) }) //# "É necessário confirmar a realização dos procedimentos antes executar o compatibilizador."  ##"Compatibilizador"
	oModal:addCloseButton()
	oMainPnl := oModal:GetPanelMain()

	oTFolder := TFolder():New( 0, 0, aTFolder, , oMainPnl, , , , .T., , , )
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	oTFolder:bSetOption := ({||})
	oTfolder1 := oTFolder:aDialogs[1]
	oTfolder2 := oTFolder:aDialogs[2]

	//Folder 1
	cMemo := + CRLF
	cMemo += STR0018 + CRLF + CRLF //"Por se tratar de um processo crítico é necessário fazer uma cópia de segurança do diretório de dicionários e demais arquivos locais, bem como da base de dados."
	cMemo += STR0019 + CRLF + CRLF //"Note que a base de dados pode estar armazenada em arquivos locais ou em banco de dados relacional, isto varia de acordo com sua instalação."
	cMemo += STR0020 + CRLF + CRLF //"Verifique se há espaço livre em disco para os arquivos locais e no banco de dados relacional, quando utilizado."
	cMemo += STR0021 + CRLF + CRLF //"A atualização de versão pode interferir em customizações existentes."
	cMemo += STR0022 //"Desta forma, se você possui customizações, é impreterível que você analise o impacto da atualização em suas customizações."
	oMemoTermo := TMultiget():New(010, 010, {| u | If( pCount() > 0, cMemo := u, cMemo ) }, oTfolder1, 279, 100, , , , , , .T., , , , , , .T., , , , , .T.)
	oAceite := TCheckBox():New(115, 010, STR0029, {|u| If(PCount() > 0, lAceite := u, lAceite)}, oTfolder1, 200, 008, , , , , , , ,.T., , , , ) // "Verifiquei os procedimentos antes de executar o compatibilizador."
	oAjuBrw := TCheckBox():New(125, 010, STR0034 + " - " + STR0033, {|u| If(PCount() > 0, _lAjuBrw := u, _lAjuBrw)}, oTfolder1, 300, 008, , , , , , , ,.T., , , , ) // "(Opcional)" - "Deseja ajustar a flag de browse dos campos (X3_BROWSE) para o valor padrão?"

	@ 121, 250 BUTTON STR0035 SIZE 030, 017 /*FONT oFont*/ PIXEL OF oTfolder1 ACTION (Info()) // "Mais info..."

	//Folder 2
	@ 10, 10 Listbox oListbox /*Var cVar*/ Fields Header " ", STR0023, STR0024 Size 279, 100 Of oTfolder2 Pixel //#"Código" ## "Grupo de Empresa"
	oListbox:SetArray(aEmp[1])
	oListbox:bLine := {|| {IIf( aEmp[1][oListbox:nAt, 1], oMarkOk, oMarkNo ), ;
	aEmp[1][oListbox:nAt, 2], ;
	aEmp[1][oListbox:nAt, 3]}}
	oListbox:BlDblClick   := { || aEmp[1][oListbox:nAt, 1] := !aEmp[1][oListbox:nAt, 1], oListbox:Refresh()}
	oListbox:BHeaderClick := { || aEval(aEmp[1], {|a, n| aEmp[1][n, 1] := !aEmp[1][n,1]}), oListbox:Refresh() }
	oListbox:cToolTip     := oModal:cTitle
	oListbox:lHScroll     := .F. // NoScroll

	oModal:Activate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Info
Apresenta o link do TDN quanto aos ajustes de browse.

@author  Cristina Cintra
@since   23/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Info()
	
	ShellExecute( "Open", "http://tdn.totvs.com/x/YLltHg", "", "C:\", 1 )
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RupGetEmp()
Função para retonar o grupo de empresas e filiais do sistema.

@Return aEmp    Array com as informaçoes das SM0

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function RupGetEmp()
	Local aEmp     := {}
	Local aSM0     := {}
	Local nI       := 0
	Local cEmpAux  := ""
	Local aMarcEmp := {}
	Local aProcEmp := {}

	OpenSm0()
	aSM0 := FWLoadSM0(.T., .F.)

	For nI := 1 To Len(aSM0)
		If cEmpAux != aSM0[nI][1]
			Aadd(aMarcEmp, {.T., aSM0[nI][1], aSM0[nI][6]})
			cEmpAux := aSM0[nI][1]
		EndIf
		Aadd(aProcEmp, {aSM0[nI][1], aSM0[nI][2]})
	Next nI

	aEmp := {aClone(aMarcEmp), aClone(aProcEmp)}
	JurFreeArr(@aMarcEmp)
	JurFreeArr(@aProcEmp)

Return aEmp

//-------------------------------------------------------------------
/*/{Protheus.doc} RupSetcEmp(aEmp, cMsgEmp)
Função para retonar as empresas selecionadas para executar o Rup.

@Param aEmp      Array gerado pela rotina RupGetEmp()
@Param cMsgEmp   Mensagem com as empresas selecionada sem dicionário
                 carregado, passado por referencia

@Return aEmpRup  Array com as empresas selecionadas

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function RupSetcEmp(aEmp, cMsgEmp)
	Local aEmpRup   := {}
	Local aEmpMark  := aEmp[1]
	Local aEmpAll   := aEmp[2]
	Local nI        := 0
	Local aEmpMsg   := {}

	Default cMsgEmp := ""

	For nI := 1 To Len(aEmpAll)
		If aScan(aEmpMark, {|x| x[1] .And. x[2] == aEmpAll[nI][1]}) > 0
			If MpDicInDb() .Or. RpcChkSxs(aEmpAll[nI][1], @aEmpMsg, .F.)
				aAdd(aEmpRup, aClone(aEmpAll[nI]))
			EndIf
		EndIf
	Next nI

	Aeval(aEmpMsg, {|x| cMsgEmp += I18N(STR0025 + CRLF, {x[1]})} ) //"A Empresa '#1' não tem dados para serem compatibilizados."
	JurFreeArr(@aEmpAll)

Return aEmpRup

//-------------------------------------------------------------------
/*/{Protheus.doc} RupProc()
Função para retonar o grupo de empresas e filiais do sistema.

@Return aEmp    Array com as informaçoes das SM0

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function RupProc(aEmp, cRelStart, cRelFinish)
	Local lRet      := .T.
	Local cEmpMsg   := ""
	Local aEmpresas := RupSetcEmp(aEmp, @cEmpMsg)
	Local cRelIni   := SubStr(cRelStart, rat('.', cRelStart) + 1)
	Local cRelFin   := SubStr(cRelFinish, rat('.', cRelFinish) + 1)

	FWMsgRun(, {|| lRet := RupProcRun(aEmpresas, cRelIni, cRelFin) }, STR0015, STR0026) //"Compatibilizando as empresas selecionadas..."

	If lRet
		ApMsgInfo(cEmpMsg + CRLF + STR0027, STR0015) //# "Compatibilizador finalizado com sucesso." ## "Compatibilizador"
	Else
		ApMsgStop(cEmpMsg + CRLF + STR0028, STR0015) //# "Compatibilizador finalizado com erro." ## "Compatibilizador"
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RupProcRun()
Rotina de abertura de ambiente e execução do Rup por empresa e filial.

@Return aEmpresas   Array com as informaçoes das empresas
@param  cRelStart   Release de partida Ex: 014
@param  cRelFinish  Release de chegada Ex: 017

@Author Luciano Pereira dos Santos
@since 17/01/2019
@version P12
/*/
//-------------------------------------------------------------------
Static function RupProcRun(aEmpresas, cRelStart, cRelFinish)
	Local lRet     := .T.
	Local cEmpOld  := ""
	Local cEmpAux  := ""
	Local cFilAux  := ""
	Local nI       := 0
	Local nP       := 0

	Private __CINTERNET := Nil // Habilita mensagens em tela após a preparação de ambiente

	For nI := 1 To Len(aEmpresas)
		cEmpAux  := aEmpresas[nI][1]
		cFilAux  := aEmpresas[nI][2]

		If cEmpOld != cEmpAux // Monta ambiente com nova empresa
			cEmpOld := cEmpAux
			RPCSetType(3)
			lRet := RpcSetEnv(cEmpAux, cFilAux, /*cEnvUser*/, /*cEnvPass*/, "PFS", /*cFunName*/ "RUP_PFS", /*aTables*/, /*lShowFinal*/, /*lAbend*/,  /*lOpenSX*/ .T., /*lConnect*/.T.)
			__CINTERNET := Nil
		Else
			cFilAnt := cFilAux // Troca filial da mesma empresa
		EndIf

		If lRet
			FWMsgRun(, {|| RUP_PFS( , , cRelStart, cRelFinish, )}, STR0015, I18N(STR0031, {"["+cEmpAnt+"]", "["+cFilAnt+"] "})) // "Compatibilizando a empresa: #1 e filial: #2..."
		EndIf

		nP := nI + 1
		If nP <= Len(aEmpresas) .And. aEmpresas[nP][1] != cEmpAux
			RpcClearEnv()
		EndIf
	Next nI

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9223
Ajusta o X3_F3 do campo NUE_CTAREF

@author Bruno Ritter / Anderson Carvalho
@since  24/06/2019
@Obs    DJURFAT1-9223
        - Foi criado esse ajuste, pois o campo NUE_CTAREF não podia ser alterado na SX3
        devido o pacote 006463 da issue DJURFAT1-8103 - Validações nas regras do modelo JURA202
        - Quando for possível, é importante ajustar o atusx para o campo NUE_CTAREF ficar
        com o campo X3_F3 = NUENRZ
/*/
//-------------------------------------------------------------------
Static Function JURPFS9223()
	Local cSXBTmp   := GetNextAlias()
	Local cF3       := "NUENRZ"
	Local aSX3      := {}
	Local aSX3Old   := {}
	Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_F3"}

	OpenSxs(,,,, cEmpAnt, cSXBTmp, "SXB", , .F.)

	If Select(cSXBTmp) > 0
		(cSXBTmp)->( DbSetOrder(1) )

		If (cSXBTmp)->( DbSeek( cF3 ) )
			Aadd(aSX3   , {"NUE", "NUE_CTAREF", cF3} )
			Aadd(aSX3Old, {"NUE", "NUE_CTAREF", "NRZNUE"} )

			AtuSX3(aSX3, aSX3Estr, aSX3Old)
		EndIf
	EndIf
	
Return Nil

//--------------------------------------------------------------------------
/*/{Protheus.doc} JRUP202
Função para encapsular as alterações feitas no pacote (006364) de ajustes 
da JURA202 issue  DJURFAT1-8103.

@author Jonatas Martins
@since  14/08/2019
/*/
//---------------------------------------------------------------------------
Static Function JRUP202()
	Local aSX3     := {}
	Local aSX3Old  := {}
	Local aSX3Estr := {}

	//----------------------------------------
	// DJURFAT1-8543 - AçãoLD nos Lançamentos
	//----------------------------------------
	If JChkfile("NUE")
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_CBOX" ,"X3_CBOXSPA","X3_CBOXENG", "X3_VALID"}
		Aadd(aSX3, {"NUE", "NUE_ACAOLD", "1=Retirar;2=Transferir;3=WO;4=Lançamento indevido;5=Transferir e retirar;6=Vincular",;
		                                 "1=Retirar;2=Transferir;3=WO;4=Asiento indebido;5=Transferir y retirar;6=Vincular",;
		                                 "1=Pick up;2=Transfer;3=WO;4=Improper entry;5=Transfer and pick up;6=Link",;
		                                 "Vazio().Or.Pertence('123456')"} )
		/*Forço o ajuste do valid pois no ATUSX foi feito num pacote que ainda não sabemos quando será liberado*/
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	If JChkfile("NVY")
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_CBOX" ,"X3_CBOXSPA","X3_CBOXENG", "X3_VALID"}
		Aadd(aSX3, {"NVY", "NVY_ACAOLD", "1=Retirar;2=Transferir;3=WO;4=Lançamento indevido;5=Transferir e retirar;6=Vincular",;
		                                 "1=Retirar;2=Transferir;3=WO;4=Asiento indebido;5=Transferir y retirar;6=Vincular",;
		                                 "1=Pick up;2=Transfer;3=WO;4=Improper entry;5=Transfer and pick up;6=Link",;
		                                 "Vazio().Or.Pertence('123456')"} )
		/*Forço o ajuste do valid pois no ATUSX foi feito num pacote que ainda não sabemos quando será liberado*/
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	If JChkfile("NV4")
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_CBOX" ,"X3_CBOXSPA","X3_CBOXENG", "X3_VALID"}
		Aadd(aSX3, {"NV4", "NV4_ACAOLD", "1=Retirar;2=Transferir;3=WO;4=Lançamento indevido;5=Transferir e retirar;6=Vincular",;
		                                 "1=Retirar;2=Transferir;3=WO;4=Asiento indebido;5=Transferir y retirar;6=Vincular",;
		                                 "1=Pick up;2=Transfer;3=WO;4=Improper entry;5=Transfer and pick up;6=Link",;
		                                 "Vazio().Or.Pertence('123456')"} )
		/*Forço o ajuste do valid pois no ATUSX foi feito num pacote que ainda não sabemos quando será liberado*/
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	//---------------------------------------------
	// DJURFAT1-9223 - Lentidão na Consulta NRZNUE
	//---------------------------------------------
	If JChkfile("NUE")
		// Ajusta o X3_F3 do campo NUE_CTAREF
		JURPFS9223()
	EndIf

	//---------------------------------------------------------------------------------------------------
	// DJURFAT1-9682 - Junção de contratos fixos para mesmo cliente, loja e caso com multiplos revisores
	//----------------------------------------------------------------------------------------------------
	If JChkfile("OHN")
		JURPFS9682(OHN->(JColumnPos("OHN_CCONTR")) == 0)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9682
Cria campo de contrato na tabela sócio/revisores (OHN). Ajusta X2_UNICO
e índice incluindo o novo campo de contrato.

@author Jonatas Martins
@since  24/06/2019
@Obs    DJURFAT1-9582 - Ajusta para corrigir error log ao emitir
        a pré-fatura de dois contratos fixos com mesmo cliente, loja
		e caso com sócios/revisores que estão em junção.
		Devido as alterações de dicionário estar no pacote da JURA202 006463
		os ajustes serão feitos via UPDPFS.
/*/
//-------------------------------------------------------------------
Static Function JURPFS9682(lCriaCtt)
	Local aArea     := GetArea()

	Default lCriaCtt := .T. 

	// Cria campo no SX3 e/ou processa alteração de indice e x2_unico
	If OHN->(JColumnPos("OHN_CCONTR")) > 0
		// Atualiza ordem dos campos
		If !_lExecutou
			AtuOrdem("OHN", 3, "OHN_CCONTR")
		EndIf
		
		// Ajusta dados existentes na base
		JPFS9682B() 
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS9682B
Ajusta dados de sócios/revisores (OHN) preenchendo o código do contrato
em registros que possuem vínculo com pré-fatura.

@author Jonatas Martins
@since  24/06/2019
/*/
//-------------------------------------------------------------------
Static Function JPFS9682B()
	Local aAreaOHN  := OHN->(GetArea())
	Local cQueryOHN := ""
	Local cAlsTmp   := GetNextAlias()

	cQueryOHN := "SELECT OHN.R_E_C_N_O_ RECOHN, NX1.NX1_CCONTR CONTRATO "
	cQueryOHN +=   "FROM " + RetSqlName("OHN") + " OHN "
	cQueryOHN +=  "INNER JOIN " + RetSqlName("NX1") + " NX1 "
	cQueryOHN +=     "ON NX1.NX1_FILIAL = '"  + xFilial("NX1") + "' "
	cQueryOHN +=    "AND NX1.NX1_CPREFT = OHN.OHN_CPREFT "
	cQueryOHN +=    "AND NX1.NX1_CCLIEN = OHN.OHN_CCLIEN "
	cQueryOHN +=    "AND NX1.NX1_CLOJA  = OHN.OHN_CLOJA "
	cQueryOHN +=    "AND NX1.NX1_CCASO  = OHN.OHN_CCASO "
	cQueryOHN +=    "AND NX1.D_E_L_E_T_ = ' ' "
	cQueryOHN +=  "WHERE OHN.OHN_FILIAL = '" + xFilial("OHN") + "' "
	cQueryOHN +=    "AND OHN.OHN_CPREFT <> ' ' "
	cQueryOHN +=    "AND OHN.OHN_CCONTR = ' ' "
	cQueryOHN +=    "AND OHN.D_E_L_E_T_ = ' ' "
	cQueryOHN := ChangeQuery(cQueryOHN)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryOHN), cAlsTmp, .T., .T.)

	While (cAlsTmp)->(!EOF())
		OHN->(DbGoTo((cAlsTmp)->RECOHN))

		If OHN->(!EOF())
			RecLock("OHN", .F.)
			OHN->OHN_CCONTR := (cAlsTmp)->CONTRATO
			OHN->(MsUnLock())
		Else
			Exit
		EndIf

		(cAlsTmp)->(DbSkip())
	End

	(cAlsTmp)->(DbCloseArea())
	RestArea(aAreaOHN)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9713
Ajuste do X3_BROWSE das tabelas NXA, NXC, NX0 e NX1 devido a performance
de abertura e navegação - DJURFAT1-9713.

@author Cristina Cintra
@since  21/08/2019
/*/
//-------------------------------------------------------------------
Static Function JURPFS9713()
Local aAjuBrwNo   := {}
Local aAjuBrwYes  := {}
Local aSX3        := {}
Local aSX3Old     := {}
Local aSX3Estr    := {"X3_ARQUIVO", "X3_CAMPO", "X3_BROWSE"}
Local nI          := 0

If IsBlind() .Or. _lAjuBrw
	aAjuBrwNo := {"NXA_PIRRF", "NXA_PPIS", "NXA_PCOFIN", "NXA_PCSLL", "NXA_PINSS", "NXA_WO", "NXA_DREFIH", "NXA_DREFFH", "NXA_DREFID", "NXA_DREFFD", "NXA_DREFIT", "NXA_DREFFT", ;
	              "NXA_SIGLA", "NXA_CPART", "NXA_DPART", "NXA_OBS", "NXA_TPPAG", "NXA_CGCCPF", "NXA_LOGRAD", "NXA_ENDENT", "NXA_CEP", "NXA_BAIRRO", "NXA_CIDADE", "NXA_ESTADO",  ; 
	              "NXA_PAIS", "NXA_INSEST", "NXA_INSMUN", "NXA_VLFIXH", "NXA_VLORIH", "NXA_VLFIXO", "NXA_VLORID", "NXA_CMOTCA", "NXA_DMOTCA", "NXA_TXTFAT", "NXA_CALDIS", "NXA_VUADIA", ;
	              "NXA_VSADIA", "NXA_EMAIL", "NXA_CRTENV", "NXA_RELENV", "NXA_RECENV", "NXA_MAILEN", "NXA_SIGLA4", "NXA_USRCAN", "NXA_DUSRCA", "NXA_FPAGTO", "NXA_CFATADC", "NXA_CBANCO", ;
	              "NXA_CAGENC", "NXA_CCONTA", "NXA_CESCSU", "NXA_CFTSUB", "NXA_CCONT", "NXA_DCONT", "NXA_CCDPGT", "NXA_DCDPGT", "NXA_TITGER", "NXA_ESCATU", "NXA_FATATU", "NXA_CIDIO", ;
	              "NXA_DIDIO", "NXA_CIDIO2", "NXA_DIDIO2", "NXA_CTPFAT", "NXA_TPREL", "NXA_DTPREL", "NXA_CCARTA", "NXA_DCARTA", "NXA_CTIPOF", "NXA_DTIPOF", "NXA_SIGLA2", "NXA_USUEMI", ;
	              "NXA_DUSUEM", "NXA_SIGLA3", "NXA_USRALT", "NXA_DUSRAL", "NXA_DTALVE", "NXA_STATUS", ; // NXA
	              "NXC_DRATE", "NXC_DRATL", "NXC_DRATP", "NXC_VLTSTB", "NXC_VLHFV", "NXC_VTBVIN", "NXC_REDAC", "NXC_PDESCH", "NXC_VLEXIT", "NXC_VFXVIN", ; // NXC
	              "NX0_TPDESC", "NX0_PDESCH", "NX0_DESCH", "NX0_DESCON", "NX0_PACREH", "NX0_CESCR", "NX0_DESCR", "NX0_SIGLA", "NX0_CPART", "NX0_DPART", "NX0_DFIMTS", "NX0_DINIDP", ;
	              "NX0_DFIMDP", "NX0_DINITB", "NX0_DINITS", "NX0_DFIMTB", "NX0_DINIFX", "NX0_DFIMFX", "NX0_CFTADC", "NX0_CPAREX", "NX0_CCONTA", "NX0_DCONTA", "NX0_SITCB", "NX0_DSITCB", ;
	              "NX0_DTINC", "NX0_DUSUEM", "NX0_TPEMI", "NX0_OBSFAT", "NX0_DTALT", "NX0_CODUSR", "NX0_USUEMI", "NX0_USRALT", "NX0_USRCAN", "NX0_DUSRCA", "NX0_ESCOLD", "NX0_FATOLD", ;
	              "NX0_CIDIO", "NX0_DIDIO", "NX0_RELPRE", "NX0_DRELPR", "NX0_FATURA", "NX0_TPSERV", ; // NX0
	              "NX1_VTBVIN", "NX1_DESP", "NX1_TABREV", "NX1_VFXVIN", "NX1_TS", "NX1_VEXITO", "NX1_DSPREV", "NX1_DMOETH", "NX1_CPAREX", "NX1_CTPREL", "NX1_TSREV", "NX1_DTPREL", ;
	              "NX1_CMOETH", "NX1_PDESCH", "NX1_SIGLA", "NX1_VDESCO", "NX1_PCDESC", "NX1_VLDESC", "NX1_CODEXI", "NX1_LANTAB", "NX1_REDAC", "NX1_VFXFAT", "NX1_VTSTAB", "NX1_VSLDPX", ;
	              "NX1_INSFAT", "NX1_VUTFAT", "NX1_CPART", "NX1_VEXLIM", "NX1_INSREV"} //NX1

	aAjuBrwYes  := {"NX1_VHON", "NX1_VFIXO", "NXC_VFIXO"}
	
	For nI := 1 To Len(aAjuBrwNo)
		Aadd(aSX3, {Substr(aAjuBrwNo[nI], 1, 3), aAjuBrwNo[nI], "N"} )
	Next nI

	For nI := 1 To Len(aAjuBrwYes)
		Aadd(aSX3, {Substr(aAjuBrwNo[nI], 1, 3), aAjuBrwYes[nI], "S"} )
	Next nI
	
	If Len(aSX3) > 0
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9726
Limpa centro de custo jurídico de naturezas que possuam o tipo de
de conta definido como 1-Banco/Caixa ou 7-Centro de Custo Profissional

@author Jonatas Martins
@since  27/09/2019
/*/
//-------------------------------------------------------------------
Static Function JURPFS9726()
	Local cUpdateSED := ""

	If SuperGetMV("MV_JURXFIN",, .F.)
		cUpdateSED := "UPDATE " + RetSqlName("SED")
		cUpdateSED +=   " SET ED_CCJURI = ' '"
		cUpdateSED += " WHERE ED_TPCOJR = '6'" // 6-Obrigações
		cUpdateSED +=   " AND ED_CCJURI <> ' '"
		cUpdateSED +=   " AND D_E_L_E_T_ = ' '"
		TcSqlExec(cUpdateSED)

		// Ajuste campo de bloqueado da natureza
		cUpdateSED := "UPDATE " + RetSqlName("SED") + " SET ED_MSBLQL = '2' WHERE D_E_L_E_T_ = ' ' AND ED_MSBLQL = ' '"
		TcSqlExec(cUpdateSED)

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS8900()
Função para preencher o novo campo NRU_DTFORM.

@author Cristina Cintra
@since  28/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURPFS8900()
Local aArea   := GetArea()
Local cUpdate := ""

cUpdate := " UPDATE " + RetSqlName("NRU")
cUpdate += " SET NRU_DTFORM = '1'"
cUpdate += " WHERE NRU_FILIAL = '" + xFilial("NRU") + "' AND NRU_DTFORM = ' ' AND D_E_L_E_T_ = ' '"
TcSqlExec(cUpdate)

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURPFS9125()
Função para ajustar lançamentos gerados através do LegalDesk.
Os lançamentos antigos eram gerados com OHB_ORIGEM = '5' e OHB_CODLD preenchido.
Novos lançamentos serão gerados com OHB_ORIGEM = '4'.

@author Jorge Martins
@since  19/11/2019
/*/
//-------------------------------------------------------------------
Static Function JURPFS9125()
Local aArea   := GetArea()
Local cUpdate := ""

cUpdate := " UPDATE " + RetSqlName("OHB")
cUpdate +=    " SET OHB_ORIGEM = '4'"
cUpdate +=  " WHERE OHB_FILIAL = '" + xFilial("OHB") + "' AND OHB_ORIGEM = '5' AND OHB_CODLD <> '" + Space(TamSx3('OHB_CODLD')[1]) + "' AND D_E_L_E_T_ = ' '"
TcSqlExec(cUpdate)

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS10442
Atualiza campo de arquivo e-billing gerado na fatura

@author Jonatas Martins
@since  07/04/2020
/*/
//-------------------------------------------------------------------
Static Function JPFS10442()
	Local cUpdate := ""

	cUpdate := "UPDATE " + RetSqlName("NXA") + " SET NXA_ARQEBI = '2' "
	cUpdate += "WHERE NXA_ARQEBI = ' ' AND D_E_L_E_T_ = ' '"

	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS12122
Preenche a data de movimentação dos adiantamentos com a data de inclusão
caso esse campo não estiver preenchido.

@author Abner Fogaça | Jonatas Martins
@since  25/11/2020
/*/
//-------------------------------------------------------------------
Static Function JPFS12122()
	Local cUpdate := ""

	cUpdate := "UPDATE " + RetSqlName("NWF")
	cUpdate += "   SET NWF_DTMOVI = NWF_DATAIN "
	cUpdate += " WHERE NWF_FILIAL = '" + xfilial("NWF") + "'"
	cUpdate += "   AND NWF_DTMOVI = ' ' "
	cUpdate += "   AND NWF_TITGER = '1' "
	cUpdate += "   AND D_E_L_E_T_ = ' ' "

	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JChkfile
Execução da Rotina de Verificação de Tabelas em Buffer

@return lRet, Indica se a tabela existe

@author fabiana.silva
@since  25/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JChkfile(cAlias)
Local nPos := {}
Local lRet := .F.

	If (nPos := aScan(_aTabExist, {|t| t[1] == cAlias})) > 0
		lRet := _aTabExist[nPos, 2]
	Else
		lRet := Chkfile(cAlias)
		aAdd(_aTabExist, {cAlias, lRet})
	EndIf

Return lRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} JColumnPos
Execução da Rotina de Verificação de Colunas em Buffer

@param  cCampo, Campo a ser verificado

@return nRet  , Indica a posição do campo no banco

@author fabiana.silva
@since  25/06/2021
/*/
//-------------------------------------------------------------------------
Static Function JColumnPos(cCampo)
Local nPos := {}
Local nRet := 0
Local cAls := ""

	If (nPos := aScan(_aColExist, {|t| t[1] == cCampo})) > 0
		nRet := _aColExist[nPos, 2]
	Else
		cAls := Substr(cCampo, 1, At("_", cCampo) - 1)

		If Len(cAls) < 3
			cAls := "S" + cAls
		EndIf

		nRet := (cAls)->(ColumnPos(cCampo))
		aAdd(_aColExist, {cCampo, nRet})
	EndIf

Return nRet

//-------------------------------------------------------------------------
/*/{Protheus.doc} JDEP10299
Migração dos dados do Projeto de Origem para o Projeto de Destino por conta
da reativação dos campos de Projeto e Item de Projeto do Destino do Lançamento

DJURDEP-10299
@author Willian Kazahaya
@since  07/03/2022
/*/
//-------------------------------------------------------------------------
Function JDEP10299()
Local cQuery   := ""
Local cAliasDb := ""
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery +=   " FROM " + RetSqlName("OHB") 
	cQuery +=  " WHERE OHB_CPROJE <> ' ' "
	cQuery +=    " AND OHB_CPROJD = ' ' "
	cQuery +=    " AND D_E_L_E_T_ = ' ' "

	cAliasDb := GetNextAlias()
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAliasDb, .T., .T.)

	While (cAliasDb)->(!Eof())
		DbSelectArea('OHB')
		OHB->( dbGoTo((cAliasDb)->(RECNO)) )

		RecLock("OHB", .F.)
		OHB->OHB_CPROJD := OHB->OHB_CPROJE
		OHB->OHB_CITPRD := OHB->OHB_CITPRJ
		OHB->OHB_CPROJE := Space(TamSx3('OHB_CPROJE')[1])
		OHB->OHB_CITPRJ := Space(TamSx3('OHB_CITPRJ')[1])
		OHB->(MsUnLock())

		(cAliasDb)->( DbSkip() )
	End
Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14432
Exclusão de relacionamentos (SX9) incorretos, e ajuste de ordem de campos
novos da NX0 de TSs de contratos fixos e não cobráveis

@author Reginaldo Borges
@since  04/04/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14432()
Local aSX9      := {}
Local aSX9Estr  := {}
Local nPosExito := 0
Local cUpdate   := ""

	If JChkfile("NVN")
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM"  ,"X9_EXPCDOM"  ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM", "X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR","lApaga" }
		aAdd(aSX9,  {"NT1"   , "001"    , "NVN"   , "NT1_SEQUEN", "NVN_CFATAD" ,           ,           ,            ,             ,           ,           ,           ,           ,"__lApaga"})
		aAdd(aSX9,  {"NVV"   , "003"    , "NVN"   , "NVV_COD"   , "NVN_CFIXO"  ,           ,           ,            ,            ,            ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
	EndIf

	If JChkfile("NX0") .And. NX0->(JColumnPos("NX0_FXNC")) > 0
		nPosExito := Val(GetSx3Cache("NX0_DFIMFX", "X3_ORDEM")) // Os campos novos ficarão após o campo de exito
		AtuOrdem("NX0", nPosExito + 1, "NX0_FXNC")
		AtuOrdem("NX0", nPosExito + 2, "NX0_DIFXNC")
		AtuOrdem("NX0", nPosExito + 3, "NX0_DFFXNC")

		cUpdate := " UPDATE " + RetSqlName("NX0")
		cUpdate +=    " SET NX0_FXNC = '2'"
		cUpdate +=  " WHERE NX0_FXNC = ' '"
		cUpdate +=    " AND D_E_L_E_T_ = ' '"
		TcSqlExec(cUpdate)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14119
Ajuste de ordem dos campos novos de valor de TimeSheet não cobrável

@author Jonatas Martins / Jorge Martins
@since  13/04/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14119()

	If JChkfile("NX1") .And. NX1->(JColumnPos("NX1_VTSNC")) > 0
		AtuOrdem("NX1", Val(GetSx3Cache("NX1_VTSVIN", "X3_ORDEM")) + 1, "NX1_VTSNC")
		AtuOrdem("NX8", Val(GetSx3Cache("NX8_VTSVIN", "X3_ORDEM")) + 1, "NX8_VTSNC")
		AtuOrdem("NXC", Val(GetSx3Cache("NXC_VTSVIN", "X3_ORDEM")) + 1, "NXC_VTSNC")
		AtuOrdem("NXB", Val(GetSx3Cache("NXB_VTSVIN", "X3_ORDEM")) + 1, "NXB_VTSNC")
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14546
Preenche novo campo (NVN_ENVENC) de envio de encaminhamentos

@author Jonatas Martins
@since  13/04/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14546()
Local cUpdate := ""

	// Atualiza flag de envio dos encaminhamentos de e-mail
	If JChkfile("NVN") .And. NVN->(JColumnPos("NVN_ENVENC")) > 0
		cUpdate := "UPDATE " + RetSqlName("NVN")
		cUpdate +=   " SET NVN_ENVENC = '2' " // "2" = Não
		cUpdate +=  "WHERE NVN_ENVENC = ' ' "
		cUpdate +=    "AND D_E_L_E_T_ = ' ' "
		TcSqlExec(cUpdate)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14594
Ajuste na ordem dos campos relacionados a Gross Up de Impostos / Honorários.
Issue DJURFAT1-14594.

@author Cristina Cintra
@since  01/06/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14594()

	If JChkfile("NUH") .And. JChkfile("NXP") .And. JChkfile("NXG") .And. JChkfile("NXA");
	   .And. NUH->(JColumnPos("NUH_GROSHN")) > 0
		AtuOrdem("NUH", 60, "NUH_GROSHN")
		AtuOrdem("NUH", 61, "NUH_PERCGH")
		AtuOrdem("NXP", 32, "NXP_GROSHN")
		AtuOrdem("NXP", 33, "NXP_PERCGH")
		AtuOrdem("NXG", 40, "NXG_GROSHN")
		AtuOrdem("NXG", 41, "NXG_PERCGH")
		AtuOrdem("NXA", 22, "NXA_VGROSH")
	
		TCSqlExec("UPDATE " + RetSqlName("NUH") + " SET NUH_GROSHN = '1' WHERE D_E_L_E_T_ = ' ' AND NUH_GROSHN = ' '")
		TCSqlExec("UPDATE " + RetSqlName("NXP") + " SET NXP_GROSHN = '1' WHERE D_E_L_E_T_ = ' ' AND NXP_GROSHN = ' '")
		TCSqlExec("UPDATE " + RetSqlName("NXG") + " SET NXG_GROSHN = '1' WHERE D_E_L_E_T_ = ' ' AND NXG_GROSHN = ' '")

	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14640
Ajuste no X3_VISUAL de V para A do campo NT1_QTDADE - Issue DJURFAT1-14640.

@author Cristina Cintra
@since  20/05/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14640()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {}

	If JChkfile("NT1") .And. NT1->(JColumnPos("NT1_QTDADE")) > 0
		aSX3Old   := {{"NT1", "NT1_QTDADE", "V"}}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VISUAL"}
		Aadd(aSX3, {"NT1", "NT1_QTDADE", "A"})
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS13504
Criação da classificação de natureza 016 - Transitória de pagamento

A Classificação nova será criada e a natureza dela será preenchida com 
a única natureza transitória de pagamento que existe. Após aplicação
do pacote dessa issue, será liberado o uso de várias transitórias de
pagamento.

@author Jorge Martins
@since  04/10/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS13504()
Local aDadosOHP := {}

	If SuperGetMV("MV_JURXFIN",, .F.)
		JA266Carga(.F.) // Carga inicial da classificação de naturezas

		aDadosOHP := JurGetDados("OHP", 1, xFilial("OHP") + "1" + "TP", {"OHP_COD", "OHP_CNATUR"})

		If !Empty(aDadosOHP) .And. !Empty(aDadosOHP[1]) .And. Empty(AllTrim(aDadosOHP[2])) // Valida se a nova classificação foi criada
			JurOperacao(4, "OHP", 1, xFilial("OHP") + "1" + "TP", {"OHP_CNATUR"}, {JurBusNat("7")}) // Se a natureza estiver vazia, preenche com a natureza transitória de pagamento que existe
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14913
Preenche novo campo ED_DESFAT e faz a criação da classificação de 
natureza 017 - Despesa de cliente

A Classificação nova será criada e a natureza dela será preenchida com 
a única natureza de despesa que existe. Após aplicação
do pacote dessa issue, será liberado o uso de várias naturezas de despesa.

@author Jorge Martins
@since  26/10/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14913()
Local cUpdate   := ""

	If SED->(JColumnPos("ED_DESFAT")) > 0
		cUpdate := " UPDATE " + RetSqlName("SED")
		cUpdate +=    " SET ED_DESFAT  = '1'"
		cUpdate +=  " WHERE ED_DESFAT  = ' '"
		cUpdate +=    " AND ED_CCJURI = '5'"
		cUpdate +=    " AND D_E_L_E_T_ = ' '"
		TcSqlExec(cUpdate)
		
		cUpdate := " UPDATE " + RetSqlName("SED")
		cUpdate +=    " SET ED_DESFAT  = '2'"
		cUpdate +=  " WHERE ED_DESFAT  = ' '"
		cUpdate +=    " AND D_E_L_E_T_ = ' '"
		TcSqlExec(cUpdate)

		If SuperGetMV("MV_JURXFIN",, .F.)
			JA266Carga(.F.) // Carga inicial da classificação de naturezas

			aDadosOHP := JurGetDados("OHP", 1, xFilial("OHP") + "3" + "DP", {"OHP_COD", "OHP_CNATUR"})

			If !Empty(aDadosOHP) .And. !Empty(aDadosOHP[1]) .And. Empty(AllTrim(aDadosOHP[2])) // Valida se a nova classificação foi criada
				JurOperacao(4, "OHP", 1, xFilial("OHP") + "3" + "DP", {"OHP_CNATUR"}, {JurBusNat("5")}) // Se a natureza estiver vazia, preenche com a natureza transitória de pagamento que existe
			EndIf
		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS14504
Função para complementar o código do adiantamento (NWF_COD) com zeros
a esqueda após o aumento do tamanho de 4 para 9.

@author Jonatas Martins
@since  19/12/2022
/*/
//-------------------------------------------------------------------------
Static Function JPFS14504()
Local cDataBase := ""
Local cUpdate   := ""
Local nTam      := GetSX3Cache("NWF_COD", "X3_TAMANHO")
Local cCaracter := Replicate("0", nTam - 4)

	If JChkfile("NWF") .And. nTam > 4 // @12.1.2310
		cDataBase := AllTrim(Upper(TCGetDB()))

		If cDataBase $ "ORACLE|POSTGRES"
			cUpdate := "UPDATE " + RetSqlName("NWF") + " SET NWF_COD = '" + cCaracter + "' || LTRIM(RTRIM(NWF_COD)) WHERE LENGTH(LTRIM(RTRIM(NWF_COD))) = 4"
		Else
			cUpdate := "UPDATE " + RetSqlName("NWF") + " SET NWF_COD = '" + cCaracter + "' + LTRIM(RTRIM(NWF_COD)) WHERE LEN(LTRIM(RTRIM(NWF_COD))) = 4"
		EndIf

		TCSqlExec(cUpdate)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS15624()
Ajuste na rotina de Clientes - Issue DJURFAT1-15624.
Ajuste na ordem de campo da NUH.

@author Reginaldo Borges
@since  02/01/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS15624()
Local nPosCpo := 0
	
	If NUH->(JColumnPos("NUH_ENCCAS")) > 0
		nPosCpo := Val(GetSx3Cache("NUH_CASAUT", "X3_ORDEM"))
		AtuOrdem("NUH", nPosCpo + 1, "NUH_ENCCAS")
		TCSqlExec("UPDATE " + RetSqlName("NUH") + " SET NUH_ENCCAS = '2' WHERE NUH_ENCCAS = ' ' AND D_E_L_E_T_ = ' '")
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS15881
Ajusta valor de desconto não é preenchido no Participante da Fatura (NXD_DESCTO)

@author Jonatas Martins
@since  06/03/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS15881()
Local aArea   := GetArea()
Local cQuery  := ""
Local cTemp   := GetNextAlias()
Local cDecFat := cValToChar(GetSX3Cache("NXA_VLDESC", "X3_DECIMAL"))

	cQuery := "SELECT A.NXA_CESCR, A.NXA_COD, A.NXA_VLDESC, A.TOT_ADVG"
	cQuery +=  " FROM (SELECT NXA.NXA_CESCR,"
	cQuery +=               " NXA.NXA_COD,"
	cQuery +=               " NXA.NXA_VLDESC,"
	cQuery +=               " SUM(NXD.NXD_VLCORR) TOT_ADVG,"
	cQuery +=               " SUM(NXD.NXD_DESCTO) TOT_DESCNXD"
	cQuery +=          " FROM " + RetSqlName("NXA") + " NXA," + RetSqlName("NXD") + " NXD"
	cQuery +=         " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQuery +=           " AND NXA.NXA_SITUAC = '1'"
	cQuery +=           " AND NXA.NXA_VLDESC > 0"
	cQuery +=           " AND NXA.D_E_L_E_T_ = ' '"
	cQuery +=           " AND NXD.NXD_FILIAL = '" + xFilial("NXD") + "'"
	cQuery +=           " AND NXD.NXD_CESCR = NXA.NXA_CESCR"
	cQuery +=           " AND NXD.NXD_CFATUR = NXA.NXA_COD"
	cQuery +=           " AND NXD.D_E_L_E_T_ = ' '"
	cQuery +=         " GROUP BY NXA.NXA_CESCR, NXA.NXA_COD, NXA.NXA_VLDESC) A"
	cQuery += " WHERE A.NXA_VLDESC <> ROUND(A.TOT_DESCNXD, " + cDecFat + ")"

	MPSysOpenQuery(cQuery, cTemp)

	// Percorre Faturas e Minutas
	While (cTemp)->(! EOF())
		J201DesLin((cTemp)->NXA_COD, (cTemp)->NXA_CESCR, .F.)
		(cTemp)->(DbSkip())
	EndDo

	(cTemp)->(DbCloseArea())
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS15929
Tira usado do campo NRC_FUTURO

@author Jorge Martins
@since  21/03/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS15929()
Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO"}
Local cUsado    := "€€€€€€€€€€€€€€ " // Formato quando NÃO É dicionário no banco
Local cNaoUsado := "€€€€€€€€€€€€€€€" // Formato quando NÃO É dicionário no banco

	If JChkfile("NRC")

		If MPDicInDB() // Dicionário no banco - Muda o formato
			cUsado    := "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     "
			cNaoUsado := X3TreatUso("€€€€€€€€€€€€€€€")
		EndIf

		aSX3Old   := {{"NRC", "NRC_FUTURO", cUsado}}
		Aadd(aSX3, {"NRC", "NRC_FUTURO", cNaoUsado})
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS16328
Ajusta a posição dos campos NVE_DTEFT e NVE_DESCAS. Ajusta a base de dados
para que o campo NVE_DTEFT seja preenchido com a Data de entrada.

DJURFAT1-16328

@author Victor Hayashi
@since  12/05/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS16328()
Local cQuery  := ""
Local cUpdate := ""
Local nPosCpo := 0
Local nX      := 0
Local aDados  := {}

	If JColumnPos("NVE_DTEFT") > 0 .And. JColumnPos("NVE_DESCAS") > 0

		// Adiciona o campo no agrupamento de caso
		NUY->(DbSetOrder(1)) //NUY_FILIAL, NUY_TABELA, NUY_FUNCAO, NUY_CODGRP, NUY_CAMPO
		If !NUY->(DbSeek(xFilial("NUY")+"NVE"+ space(TamSx3("NUY_FUNCAO")[1])+"001"+"NVE_DTEFT"))
			RecLock("NUY", .T.)
			NUY->NUY_FILIAL := xFilial("NUY")
			NUY->NUY_TABELA := "NVE"
			NUY->NUY_CODGRP := "001"
			NUY->NUY_CAMPO := "NVE_DTEFT"
			NUY->(MsUnLock())
		EndIf

		// Adiciona o campo no agrupamento de caso
		If !NUY->(DbSeek(xFilial("NUY")+"NVE"+ space(TamSx3("NUY_FUNCAO")[1])+"001"+"NVE_DESCAS"))
			RecLock("NUY", .T.)
			NUY->NUY_FILIAL := xFilial("NUY")
			NUY->NUY_TABELA := "NVE"
			NUY->NUY_CODGRP := "001"
			NUY->NUY_CAMPO := "NVE_DESCAS"
			NUY->(MsUnLock())
		EndIf

		If !Val(GetSx3Cache("NVE_DTEFT", "X3_ORDEM")) == 58 // Ordem do campo no AtuSx

			// Ajusta ordenação da tabela NVE
			cQuery := " SELECT X2_CHAVE, X3_CAMPO"
			cQuery +=   " FROM " + RetSqlName("SX2")
			cQuery +=  " INNER JOIN " + RetSqlName("SX3")
			cQuery +=     " ON X2_CHAVE = X3_ARQUIVO "
			cQuery +=    " AND X3_ORDEM ='9A'"
			cQuery +=  " WHERE X2_MODULO = '77' AND X2_CHAVE = 'NVE'"
			aDados := JurSQL(cQuery, {"*"})

			For nX := 1 to Len(aDados)
				AtuOrdem(aDados[nX][01], Val(RetAsc('A0', 3, .F.)), aDados[nX][02])
			Next nX

			// Atualiza a ordem do campo NVE_DTEFT para ficar depois do campo NVE_SITCAD
			nPosCpo := Val(RetAsc(GetSx3Cache("NVE_SITCAD", "X3_ORDEM"), 2, .F.))
			AtuOrdem("NVE", nPosCpo + 1, "NVE_DTEFT")

			// Atualiza a ordem do campo NVE_DESCRC para ficar depois do campo
			nPosCpo := Val(RetAsc(GetSx3Cache("NVE_REDFAT", "X3_ORDEM"), 2, .F.))
			AtuOrdem("NVE", nPosCpo + 1, "NVE_DESCAS")

			// Realiza ajuste na base, para que todos os casos tenham o campo novo preenchido.
			cUpdate := " UPDATE " + RetSqlName("NVE")
			cUpdate +=    " SET NVE_DTEFT = NVE_DTENTR"
			cUpdate +=  " WHERE NVE_SITCAD = '2'"
			cUpdate +=    " AND NVE_DTEFT = ' '"
			cUpdate +=    " AND D_E_L_E_T_ = ' '"
			TcSqlExec(cUpdate)
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JJUR11582
Reordena os campos da NUH para incluir o campo de Vincula Comprovante de 
despesa no Relatório Unificado (NUH_VINCOM) proximo do campo de Unifica 
Relatório (NUH_UNIREL)

@author Willian Kazahaya
@since  23/05/2023
/*/
//-------------------------------------------------------------------------
Function JJUR11582()
Local nOrdUniRel := GetSx3Cache("NUH_UNIREL", "X3_ORDEM")
	AtuOrdem("NUH", Val(nOrdUniRel) + 1, "NUH_VINCOM")
Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS16035
Preenche conteúdo padrão do campo NZQ_ADIANT e ajusta ordem do campo

@author Jonatas Martins
@since  06/06/2023
/*/
//-------------------------------------------------------------------------
Function JPFS16035()
Local cUpdate := ""
Local nPosCpo := Val(GetSx3Cache("NZQ_NOMRES", "X3_ORDEM"))

	AtuOrdem("NZQ", nPosCpo + 1, "NZQ_ADIANT")

	// Realiza ajuste na base, para que todos os casos tenham o campo novo preenchido.
	cUpdate := " UPDATE " + RetSqlName("NZQ")
	cUpdate +=    " SET NZQ_ADIANT = '2'"
	cUpdate +=  " WHERE NZQ_ADIANT = ' '"
	cUpdate +=    " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS16365
Preenche conteúdo padrão do campo NT0_SUGPLD

@author Abner Fogaça
@since  15/06/2023
/*/
//-------------------------------------------------------------------------
Function JPFS16365()
Local cUpdate := ""

	cUpdate := "UPDATE " + RetSqlName("NT0")
	cUpdate +=   " SET NT0_SUGPLD = '1'"
	cUpdate += " WHERE NT0_SUGPLD = ' '"
	cUpdate +=   " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS16828
Popula tabela de Movimentações em Adiantamentos (OI8) para adiantamentos
criados via JURA069.

@author Jonatas Martins
@since  27/06/2023
/*/
//-------------------------------------------------------------------------
Function JPFS16828()
Local cAls       := ""
Local cQuery     := ""
Local oStatement := Nil
Local cParamSync := SuperGetMv('MV_JFSINC',, '2')

	If JChkfile("NWF") .And. JChkfile("OI8") .And. FindFunction("J311Insert");
	   .And. (SuperGetMV("MV_JESCJUR",, ".F.") .Or. SuperGetMV("MV_JURXFIN",, .F.))

		cAls   := GetNextAlias()
		cQuery := "SELECT COUNT(OI8_COD) TOTREG FROM " + RetSqlName("OI8")
		MpSysOpenQuery(cQuery, cAls)

		If (cAls)->(! Eof()) .And. (cAls)->TOTREG == 0

			_lCriaOI8 := .T.

			If cParamSync == "1"
				PutMV("MV_JFSINC", "2") // Desabilita fila de sincronização (NYS)
			EndIf
			
			(cAls)->(DbCloseArea())

			cQuery := "SELECT NWF.R_E_C_N_O_ RECNWF, SE1.R_E_C_N_O_ RECSE1, SE5.R_E_C_N_O_ RECSE5 "
			cQuery +=   "FROM " + RetSqlName("NWF") + " NWF "
			cQuery +=  "INNER JOIN " + RetSqlName("NS7") + " NS7 "
			cQuery +=     "ON NS7.NS7_FILIAL = ? " // 1 - xFilial("NS7")
			cQuery +=    "AND NS7.NS7_COD = NWF.NWF_CESCR "
			cQuery +=    "AND NS7.D_E_L_E_T_ = ' ' "
			cQuery +=  "INNER JOIN " + RetSqlName("SE1") + " SE1 "
			cQuery +=     "ON SE1.E1_FILIAL = NS7.NS7_CFILIA "
			cQuery +=    "AND SE1.E1_TIPO = ? " // 2 - SuperGetMV("MV_JADTTP",, "RA")
			cQuery +=    "AND SE1.E1_NUM = NWF.NWF_TITULO "
			cQuery +=    "AND SE1.D_E_L_E_T_ = ' ' "
			cQuery +=  "INNER JOIN " + RetSqlName("SE5") + " SE5 "
			cQuery +=     "ON SE5.E5_FILIAL = SE1.E1_FILIAL "
			cQuery +=    "AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "
			cQuery +=    "AND SE5.E5_NUMERO = SE1.E1_NUM "
			cQuery +=    "AND SE5.E5_PARCELA = SE1.E1_PARCELA "
			cQuery +=    "AND SE5.E5_TIPO = SE1.E1_TIPO "
			cQuery +=    "AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "
			cQuery +=    "AND SE5.E5_LOJA = SE1.E1_LOJA "
			cQuery +=    "AND SE5.D_E_L_E_T_ = ' ' "
			cQuery +=  "WHERE NWF.NWF_FILIAL = ? " // 3 - xFilial("NWF")
			cQuery +=    "AND NWF.NWF_TITGER = '1' "
			cQuery +=    "AND NWF.D_E_L_E_T_ = ' ' "
			cQuery +=  "ORDER BY  NWF.NWF_COD, SE5.R_E_C_N_O_"

			oStatement := FWPreparedStatement():New(cQuery)

			oStatement:SetString(1 , xFilial("NS7") ) // NS7_FILIAL
			oStatement:SetString(2 , SuperGetMV("MV_JADTTP",, "RA")) // E1_TIPO
			oStatement:SetString(3 , xFilial("NWF")) // NWF_FILIAL

			cQuery := oStatement:GetFixQuery()

			MpSysOpenQuery(cQuery, cAls)

			NWF->(DbSetOrder(1))    // NWF_FILIAL + NWF_COD
			SE1->(DbSetOrder(1))    // E1_FILIAL + E1_PREFIXO + E1_NUM, E1_PARCELA + E1_TIPO

			While (cAls)->(! Eof())
				NWF->(DbGoTo((cAls)->RECNWF))
				SE1->(DbGoTo((cAls)->RECSE1))
				SE5->(DbGoTo((cAls)->RECSE5))

				BEGIN TRANSACTION
					// 1 - Recebido -> Criação do RA via NWF (JURA069)
					If SE5->E5_RECPAG == "R" .And. Empty(SE5->E5_DOCUMEN) .And. SE5->E5_TIPODOC == "RA"
						J311Insert("1")
					// 4 - Devolvido -> Estorno de Adiantamento
					ElseIf SE5->E5_RECPAG == "P" .And. Empty(SE5->E5_DOCUMEN) .And. SE5->E5_TIPODOC == "BA"
						J311Insert("4", SE5->E5_VALOR, (cAls)->RECSE5)
						If SE5->E5_SITUACA == "C" // Cancelamento da Baixa do RA sem NWF
							J311Insert("5", 0, (cAls)->RECSE5)
						EndIf
					// 2 - Utilizado -> Compensação de faturas
					ElseIf SE5->E5_RECPAG == "R" .And. !Empty(SE5->E5_DOCUMEN) .And. SE5->E5_TIPODOC == "BA" // Utilização do RA (compensação) via emissão de fatura JURA203
						J311Insert("2", 0, (cAls)->RECSE5)
					// 3 - Cancelado -> Cancelamento de faturas
					ElseIf SE5->E5_RECPAG == "P" .And. !Empty(SE5->E5_DOCUMEN) .And. SE5->E5_TIPODOC == "ES" // Estorno do RA (cancel. fatura) via emissão de fatura JURA203
						J311Insert("3", 0, (cAls)->RECSE5)
					EndIf
				END TRANSACTION

				(cAls)->(DbSkip())
			EndDo

			oStatement:Destroy()
			(cAls)->(DbCloseArea())

			If cParamSync == "1" // Restaura conteúdo do parâmetro MV_JFSINC
				PutMV("MV_JFSINC", "1") // Habilita novamente fila de sincronização (NYS)
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS16828B
Popula tabela de Movimentações em Adiantamentos (OI8) para adiantamentos
criados via SIGAFIN (Sem NWF).

@author Jonatas Martins
@since  27/06/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS16828B()
Local cQueryRA   := ""
Local cAlsRA     := GetNextAlias()
Local oStatement := Nil
Local cParamSync := SuperGetMv('MV_JFSINC',, '2')

	If cParamSync == "1"
		PutMV("MV_JFSINC", "2") // Desabilita fila de sincronização (NYS)
	EndIf

	cQueryRA := "SELECT SE1.R_E_C_N_O_ RECSE1, SE5.R_E_C_N_O_ RECSE5 "
	cQueryRA +=   "FROM " + RetSqlName("SE1") + " SE1 "
	cQueryRA +=  "INNER JOIN " + RetSqlName("SE5") + " SE5 "
	cQueryRA +=     "ON SE5.E5_FILIAL = SE1.E1_FILIAL "
	cQueryRA +=    "AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "
	cQueryRA +=    "AND SE5.E5_NUMERO = SE1.E1_NUM "
	cQueryRA +=    "AND SE5.E5_PARCELA = SE1.E1_PARCELA "
	cQueryRA +=    "AND SE5.E5_TIPO = SE1.E1_TIPO "
	cQueryRA +=    "AND SE5.E5_CLIFOR = SE1.E1_CLIENTE "
	cQueryRA +=    "AND SE5.E5_LOJA = SE1.E1_LOJA "
	cQueryRA +=    "AND SE5.D_E_L_E_T_ = ' ' "
	cQueryRA += "WHERE SE1.E1_FILIAL = ? " // 1 - xFilial("SE1")
	cQueryRA +=   "AND SE1.E1_TIPO = ? " // 2 - SuperGetMV("MV_JADTTP",, "RA")
	cQueryRA +=   "AND SE1.E1_ORIGEM <> 'JURA069 ' "
	cQueryRA +=   "AND SE1.D_E_L_E_T_ = ' ' "
	cQueryRA += "ORDER BY SE5.E5_FILIAL,  SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_SEQ "

	oStatement := FWPreparedStatement():New(cQueryRA)

	oStatement:SetString(1 , xFilial("SE1")) // E1_FILIAL
	oStatement:SetString(2 , SuperGetMV("MV_JADTTP",, "RA")) // E1_TIPO

	cQueryRA := oStatement:GetFixQuery()

	MpSysOpenQuery(cQueryRA, cAlsRA)

	While (cAlsRA)->(! Eof())
		SE1->(DbGoTo((cAlsRA)->RECSE1))
		SE5->(DbGoTo((cAlsRA)->RECSE5))

		BEGIN TRANSACTION
			// 1|A - Recebido -> Criação do RA sem NWF (SIGAFIN)
			If SE5->E5_RECPAG == "R" .And. Empty(SE5->E5_DOCUMEN) .And. SE5->E5_TIPODOC = "RA" .And. SE5->E5_MOTBX = "NOR"
				J311Insert("A", 0, SE5->(Recno()))
			// 4|C - Devolvido -> Baixa do RA sem NWF (JGrvBxRA) | 4|F - Exclusão da Baixa (JCancBaixa) não será registrada pois o SE5 fica deletado
			ElseIf SE5->E5_RECPAG == "P" .And. Empty(SE5->E5_DOCUMEN) .And. SE5->E5_TIPODOC = "BA" .And. SE5->E5_MOTBX = "NOR"
				J311Insert("C", 0, SE5->(Recno()))
				If SE5->E5_SITUACA == "C" // Cancelamento da Baixa do RA sem NWF
					J311Insert("F", 0, SE5->(Recno()))
				EndIf
			// 2|D - Utilizado -> Compensação com RA sem NWF
			ElseIf SE5->E5_RECPAG == "R" .And. !Empty(SE5->E5_DOCUMEN) .And. SE5->E5_TIPODOC = "BA" .And. SE5->E5_MOTBX = "CMP" // Utilização do RA (compensação) via emissão de fatura JURA203
				J311Insert("D", 0, SE5->(Recno()))
			// 3 - Cancelado -> Cancelamento/Exclusão de compensação com RA sem NWF
			ElseIf SE5->E5_RECPAG == "P" .And. !Empty(SE5->E5_DOCUMEN) .And. SE5->E5_TIPODOC = "ES" .And. SE5->E5_MOTBX = "CMP" // Estorno do RA (cancel. fatura) via emissão de fatura JURA203
				J311Insert("E", 0, SE5->(Recno()))
			EndIf
		END TRANSACTION

		(cAlsRA)->(DbSkip())
	EndDo

	oStatement:Destroy()
	(cAlsRA)->(DbCloseArea())

	If cParamSync == "1" // Restaura conteúdo do parâmetro MV_JFSINC
		PutMV("MV_JFSINC", "1") // Habilita novamente fila de sincronização (NYS)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS16437
Ajusta ordem dos novos campos NX2_UTP, NX2_HORAP, NX2_TEMPOP, 
NXD_UTPROD, NXD_HRPROD e NXD_HFPROD

@author Jorge Martins
@since  30/08/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS16437()
Local nPosCpo := 0

	If JChkfile("NX2") .And. JChkfile("NXD")
		If NX2->(JColumnPos("NX2_UTP")) > 0
			nPosCpo := Val(GetSx3Cache("NX2_TEMPOR", "X3_ORDEM"))
			AtuOrdem("NX2", nPosCpo + 1, "NX2_UTP"   )
			AtuOrdem("NX2", nPosCpo + 2, "NX2_HORAP" )
			AtuOrdem("NX2", nPosCpo + 3, "NX2_TEMPOP")
		EndIf

		If NXD->(JColumnPos("NXD_UTPROD")) > 0
			nPosCpo := Val(GetSx3Cache("NXD_HFREV", "X3_ORDEM"))
			AtuOrdem("NXD", nPosCpo + 1, "NXD_UTPROD")
			AtuOrdem("NXD", nPosCpo + 2, "NXD_HRPROD")
			AtuOrdem("NXD", nPosCpo + 3, "NXD_HFPROD")
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS17642
Atualiza os valids dos campos de participação e historico da participação 
para remover os valids dos campos, pois eles foram implementados no valid de 
linha do grid no modelo.

Atualiza o inicializador padrão dos campos de data inicial, para uma função 
que só sugere o inicializador padrão quando o mesmo for aberto via tela, 
evitando os problemas com as requisições em REST.

@author Victor Hayashi
@since  19/10/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS17642()
Local aSX3     := {}
Local aSX3Estr := {}
Local aSX3Old  := {}
Local cIniPad  := AllTrim(GetSX3Cache("NU9_DTINI", "X3_RELACAO"))

	If cIniPad == "M->NUH_DTEFT"
		// Atualiza o valid dos campos
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VALID"}
		Aadd(aSX3, {'NU9','NU9_DTINI', ''})
		Aadd(aSX3, {'NU9','NU9_DTFIM', ''})
		Aadd(aSX3, {'NUD','NUD_AMINI', ''})
		Aadd(aSX3, {'NUD','NUD_AMFIM', ''})
		Aadd(aSX3, {'NUK','NUK_DTINI', ''})
		Aadd(aSX3, {'NUK','NUK_DTFIN', ''})
		Aadd(aSX3, {'NVF','NVF_AMINI', ''})
		Aadd(aSX3, {'NVF','NVF_AMFIM', ''})
		Aadd(aSX3, {'NVF','NVF_DTINI', ''})
		Aadd(aSX3, {'NVF','NVF_DTFIN', ''})

		AtuSX3(aSX3, aSX3Estr)

		JurFreeArr(@aSX3)

		// Atualiza o inicializador padrão dos campos
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

		Aadd(aSX3Old, {"NU9", "NU9_DTINI", "M->NUH_DTEFT"})
		Aadd(aSX3Old, {"NUK", "NUK_DTINI", "M->NVE_DTENTR"})

		Aadd(aSX3, {'NU9','NU9_DTINI', 'JIniPdr("NU9_DTINI")'})
		Aadd(aSX3, {'NUK','NUK_DTINI', 'JIniPdr("NUK_DTINI")'})

		AtuSX3(aSX3, aSX3Estr)

		JurFreeArr(@aSX3)
		JurFreeArr(@aSX3Estr)
		JurFreeArr(@aSX3Old)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS17549
Preenche os campos de Revisor e Sócio Responsável nos últimos históricos dos 
casos

@author Jorge Martins
@since  26/10/2023
/*/
//-------------------------------------------------------------------------
Static Function JPFS17549()
Local cQuery := ""
Local cTemp  := ""

	If !_lExecutou .And. NUU->(JColumnPos("NUU_CPART1")) > 0 // Proteção @12.1.2410
		cTemp := GetNextAlias()
		
		cQuery := " SELECT NUU.R_E_C_N_O_ NUURECNO, NVE.NVE_CPART1, NVE.NVE_CPART5 "
		cQuery +=   " FROM " + RetSqlName("NUU") + " NUU "
		cQuery +=  " INNER JOIN " + RetSqlName("NVE") + " NVE "
		cQuery +=     " ON NVE.NVE_FILIAL = ? "
		cQuery +=    " AND NVE.NVE_CCLIEN = NUU.NUU_CCLIEN "
		cQuery +=    " AND NVE.NVE_LCLIEN = NUU.NUU_CLOJA "
		cQuery +=    " AND NVE.NVE_NUMCAS = NUU.NUU_CCASO "
		cQuery +=    " AND NVE.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE NUU.NUU_FILIAL = ? "
		cQuery +=    " AND NUU.NUU_AMFIM  = ' ' "
		cQuery +=    " AND NUU.NUU_CPART1 = ' ' "
		cQuery +=    " AND NUU.NUU_CPART5 = ' ' "
		cQuery +=    " AND NUU.D_E_L_E_T_ = ' ' "
		
		DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, {xFilial("NVE"), xFilial("NUU")}), cTemp, .T., .T.)

		While (cTemp)->(!EOF())
			NUU->(DbGoTo((cTemp)->NUURECNO))

			If NUU->(!EOF())
				RecLock("NUU", .F.)
				NUU->NUU_CPART1 := (cTemp)->NVE_CPART1
				NUU->NUU_CPART5 := (cTemp)->NVE_CPART5
				NUU->(MsUnLock())
			EndIf
			(cTemp)->(DbSkip())
		EndDo
		(cTemp)->(DbCloseArea())
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS15959
Preenche o campo de Ativo do Motivos de cancelamento da fatura

@author João Pedro
@since  27/02/2024
/*/
//-------------------------------------------------------------------------
Static Function JPFS15959()
Local cUpdateNSA := ""

	If !_lExecutou .And. NSA->(JColumnPos("NSA_ATIVO")) > 0 // Proteção @12.1.2410

		cUpdateNSA := " UPDATE " + RetSqlName("NSA")
		cUpdateNSA +=    " SET NSA_ATIVO = '1'"
		cUpdateNSA +=  " WHERE NSA_ATIVO  = ' '"
		cUpdateNSA +=    " AND D_E_L_E_T_ = ' '"

		TCSqlExec(cUpdateNSA)
	EndIf

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS18988
Preenche o campo NZQ_ORIGEM

@author Jonatas Martins
@since  15/04/2024
/*/
//-------------------------------------------------------------------------
Static Function JPFS18988()
Local cUpdateNZQ := ""

	cUpdateNZQ := " UPDATE " + RetSqlName("NZQ")
	cUpdateNZQ +=    " SET NZQ_ORIGEM = '1'" // 1=Digitado;2=Despesa LD;3=Prestação de Contas LD
	cUpdateNZQ +=  " WHERE NZQ_ORIGEM  = ' '"
	cUpdateNZQ +=    " AND NZQ_CODLD = ' '"
	cUpdateNZQ +=    " AND D_E_L_E_T_ = ' '"
	TCSqlExec(cUpdateNZQ)

	cUpdateNZQ := " UPDATE " + RetSqlName("NZQ")
	cUpdateNZQ +=    " SET NZQ_ORIGEM = '2'" // 1=Digitado;2=Despesa LD;3=Prestação de Contas LD
	cUpdateNZQ +=  " WHERE NZQ_ORIGEM  = ' '"
	cUpdateNZQ +=    " AND NZQ_CODLD <> ' '"
	cUpdateNZQ +=    " AND D_E_L_E_T_ = ' '"
	TCSqlExec(cUpdateNZQ)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS19449
Cancela o vínculo dos lançamentos com as pré-faturas de conferência

@author Jacques Alves Xavier
@since  18/06/2024
/*/
//-------------------------------------------------------------------------
Static Function JPFS19449()
Local cUpdate := ""

	// NW0 - NW0_CANC - Time Sheets
	cUpdate := "UPDATE " + RetSqlName("NW0")
	cUpdate +=   " SET NW0_CANC = '1'"
	cUpdate += " WHERE NW0_PRECNF IN ("
	cUpdate +=                      " SELECT NW0.NW0_PRECNF"
	cUpdate +=                        " FROM " + RetSqlName("NW0") + " NW0"
	cUpdate +=                       " INNER JOIN " + RetSqlName("NX0") + " NX0"
	cUpdate +=                          " ON NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
	cUpdate +=                         " AND NX0.NX0_COD = NW0.NW0_PRECNF"
	cUpdate +=                         " AND NX0.NX0_SITUAC = '1'"
	cUpdate +=                         " AND NX0.D_E_L_E_T_ = ' '"
	cUpdate +=                       " WHERE NW0.NW0_FILIAL = '" + xFilial("NW0") + "'"
	cUpdate +=                         " AND NW0.NW0_CANC = '2'"
	cUpdate +=                         " AND NW0.D_E_L_E_T_ = ' ')"

	TCSqlExec(cUpdate)

	// NVZ - NVZ_CANC - Despesas
	cUpdate := "UPDATE " + RetSqlName("NVZ")
	cUpdate +=   " SET NVZ_CANC = '1'"
	cUpdate += " WHERE NVZ_PRECNF IN ("
	cUpdate +=                      " SELECT NVZ.NVZ_PRECNF"
	cUpdate +=                        " FROM " + RetSqlName("NVZ") + " NVZ"
	cUpdate +=                       " INNER JOIN " + RetSqlName("NX0") + " NX0"
	cUpdate +=                          " ON NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
	cUpdate +=                         " AND NX0.NX0_COD = NVZ.NVZ_PRECNF"
	cUpdate +=                         " AND NX0.NX0_SITUAC = '1'"
	cUpdate +=                         " AND NX0.D_E_L_E_T_ = ' '"
	cUpdate +=                       " WHERE NVZ.NVZ_FILIAL = '" + xFilial("NVZ") + "'"
	cUpdate +=                         " AND NVZ.NVZ_CANC = '2'"
	cUpdate +=                         " AND NVZ.D_E_L_E_T_ = ' ')"

	TCSqlExec(cUpdate)

	// NW4 - NW4_CANC - Tabelados
	cUpdate := "UPDATE " + RetSqlName("NW4")
	cUpdate +=   " SET NW4_CANC = '1'"
	cUpdate += " WHERE NW4_PRECNF IN ("
	cUpdate +=                      " SELECT NW4.NW4_PRECNF"
	cUpdate +=                        " FROM " + RetSqlName("NW4") + " NW4"
	cUpdate +=                       " INNER JOIN " + RetSqlName("NX0") + " NX0"
	cUpdate +=                          " ON NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
	cUpdate +=                         " AND NX0.NX0_COD = NW4.NW4_PRECNF"
	cUpdate +=                         " AND NX0.NX0_SITUAC = '1'"
	cUpdate +=                         " AND NX0.D_E_L_E_T_ = ' '"
	cUpdate +=                       " WHERE NW4.NW4_FILIAL = '" + xFilial("NW4") + "'"
	cUpdate +=                         " AND NW4.NW4_CANC = '2'"
	cUpdate +=                         " AND NW4.D_E_L_E_T_ = ' ')"

	TCSqlExec(cUpdate)

	// NWE - NWE_CANC - Fixo
	cUpdate := "UPDATE " + RetSqlName("NWE")
	cUpdate +=   " SET NWE_CANC = '1'"
	cUpdate += " WHERE NWE_PRECNF IN ("
	cUpdate +=                      " SELECT NWE.NWE_PRECNF"
	cUpdate +=                        " FROM " + RetSqlName("NWE") + " NWE"
	cUpdate +=                       " INNER JOIN " + RetSqlName("NX0") + " NX0"
	cUpdate +=                          " ON NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
	cUpdate +=                         " AND NX0.NX0_COD = NWE.NWE_PRECNF"
	cUpdate +=                         " AND NX0.NX0_SITUAC = '1'"
	cUpdate +=                         " AND NX0.D_E_L_E_T_ = ' '"
	cUpdate +=                       " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") + "'"
	cUpdate +=                         " AND NWE.NWE_CANC = '2'"
	cUpdate +=                         " AND NWE.D_E_L_E_T_ = ' ')"

	TCSqlExec(cUpdate)

	// NWD - NWD_CANC - Fatura Adicional
	cUpdate := "UPDATE " + RetSqlName("NWD")
	cUpdate +=   " SET NWD_CANC = '1'"
	cUpdate += " WHERE NWD_PRECNF IN ("
	cUpdate +=                      " SELECT NWD.NWD_PRECNF"
	cUpdate +=                        " FROM " + RetSqlName("NWD") + " NWD"
	cUpdate +=                       " INNER JOIN " + RetSqlName("NX0") + " NX0"
	cUpdate +=                          " ON NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
	cUpdate +=                         " AND NX0.NX0_COD = NWD.NWD_PRECNF"
	cUpdate +=                         " AND NX0.NX0_SITUAC = '1'"
	cUpdate +=                         " AND NX0.D_E_L_E_T_ = ' '"
	cUpdate +=                       " WHERE NWD.NWD_FILIAL = '" + xFilial("NWD") + "'"
	cUpdate +=                         " AND NWD.NWD_CANC = '2'"
	cUpdate +=                         " AND NWD.D_E_L_E_T_ = ' ')"

	TCSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------------
/*/{Protheus.doc} JPFS19247
Preenche o campo RD0_TPJUR como '1-Sim' quando o MV_JFTJURI está ativo

@author Jorge Martins
@since  24/09/2024
/*/
//-------------------------------------------------------------------------
Static Function JPFS19247()
Local cUpdateRD0 := ""

	If SuperGetMV("MV_JFTJURI",, "2" ) == "1" // Se a integração SIGAJURI x SIGAPFS estiver habilitada
		cUpdateRD0 := " UPDATE " + RetSqlName("RD0")
		cUpdateRD0 +=    " SET RD0_TPJUR = '1'" // 1=Sim;2=Nao
		cUpdateRD0 +=  " WHERE RD0_TPJUR <> '1'"
		cUpdateRD0 +=    " AND D_E_L_E_T_ = ' '"
		TCSqlExec(cUpdateRD0)
	EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS19730
Atualiza os campos - NVZ_FILLAN, NVZ_DTCCAN e NVZ_DTCEMI

@author Jorge Martins
@since  05/12/2024
/*/
//-------------------------------------------------------------------
Static Function JPFS19730()
Local cSpaceFil := Space(TamSX3("NVZ_FILLAN")[1])
Local cDtCEmi   := Space(TamSX3("NVZ_DTCEMI")[1])
Local cDtCCan   := Space(TamSX3("NVZ_DTCCAN")[1])
Local cUpdate   := ""

	cUpdate := " UPDATE " + RetSqlName("NVZ")
	cUpdate +=  " SET NVZ_FILLAN = COALESCE((SELECT NWZ_FILLAN"
	cUpdate +=                               " FROM " + RetSqlName("NWZ") + " NWZ"
	cUpdate +=                              " WHERE NWZ.NWZ_FILIAL = '" + xFilial("NWZ") + "'"
	cUpdate +=                                " AND NWZ.NWZ_FILLAN = '" + cFilAnt + "'
	cUpdate +=                                " AND NWZ.NWZ_CODWO = NVZ_CWO"
	cUpdate +=                                " AND NWZ.NWZ_CCLIEN = NVZ_CCLIEN"
	cUpdate +=                                " AND NWZ.NWZ_CLOJA = NVZ_CLOJA"
	cUpdate +=                                " AND NWZ.NWZ_CCASO = NVZ_CCASO"
	cUpdate +=                                " AND NWZ.NWZ_CTPDSP = NVZ_CTPDSP"
	cUpdate +=                                " AND NWZ.D_E_L_E_T_ = ' ' ), '" + cSpaceFil + "')" // Usa Coalesce para não tentar gravar campo nulo caso a query não volte nada
	cUpdate += " WHERE NVZ_FILIAL = '" + xFilial("NVZ") + "'"
	cUpdate +=   " AND NVZ_FILLAN = '" + cSpaceFil + "'"
	cUpdate +=   " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

	cUpDate := " UPDATE " + RetSqlName("NVZ")
	cUpdate +=  " SET NVZ_DTCEMI = COALESCE((SELECT NWZ_DTCEMI"
	cUpdate +=                               " FROM " + RetSqlName("NWZ") + " NWZ"
	cUpdate +=                              " WHERE NWZ.NWZ_FILIAL = '" + xFilial("NWZ") + "'"
	cUpdate +=                                " AND NWZ.NWZ_FILLAN = '" + cFilAnt + "'
	cUpdate +=                                " AND NWZ.NWZ_CODWO = NVZ_CWO"
	cUpdate +=                                " AND NWZ.NWZ_CCLIEN = NVZ_CCLIEN"
	cUpdate +=                                " AND NWZ.NWZ_CLOJA = NVZ_CLOJA"
	cUpdate +=                                " AND NWZ.NWZ_CCASO = NVZ_CCASO"
	cUpdate +=                                " AND NWZ.NWZ_CTPDSP = NVZ_CTPDSP"
	cUpdate +=                                " AND NWZ.D_E_L_E_T_ = ' ' ), '" + cDtCEmi + "')" // Usa Coalesce para não tentar gravar campo nulo caso a query não volte nada
	cUpdate += " WHERE NVZ_FILIAL = '" + xFilial("NVZ") + "'"
	cUpdate +=   " AND NVZ_DTCEMI = '" + cDtCEmi + "'"
	cUpdate +=   " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

	cUpDate := " UPDATE " + RetSqlName("NVZ")
	cUpdate +=  " SET NVZ_DTCCAN = COALESCE((SELECT NWZ_DTCCAN"
	cUpdate +=                               " FROM " + RetSqlName("NWZ") + " NWZ"
	cUpdate +=                              " WHERE NWZ.NWZ_FILIAL = '" + xFilial("NWZ") + "'"
	cUpdate +=                                " AND NWZ.NWZ_FILLAN = '" + cFilAnt + "'
	cUpdate +=                                " AND NWZ.NWZ_CODWO = NVZ_CWO"
	cUpdate +=                                " AND NWZ.NWZ_CCLIEN = NVZ_CCLIEN"
	cUpdate +=                                " AND NWZ.NWZ_CLOJA = NVZ_CLOJA"
	cUpdate +=                                " AND NWZ.NWZ_CCASO = NVZ_CCASO"
	cUpdate +=                                " AND NWZ.NWZ_CTPDSP = NVZ_CTPDSP"
	cUpdate +=                                " AND NWZ.D_E_L_E_T_ = ' ' ), '" + cDtCCan + "')" // Usa Coalesce para não tentar gravar campo nulo caso a query não volte nada
	cUpdate += " WHERE NVZ_FILIAL = '" + xFilial("NVZ") + "'"
	cUpdate +=   " AND NVZ_DTCCAN = '" + cDtCCan + "'"
	cUpdate +=   " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS20747A
Ajusta os campos E1_NFELETR, OHH_NFELET, NXA_NFELET e NXA_LINKNF
para os documentos fiscais que tiveram o número de NF Eletronica
registrado errado devido a númeração do documento fiscal coincidir
com a numeração da fatura.

@author Abner Fogaça de Oliveira
@since  22/01/2025
/*/
//-------------------------------------------------------------------
Static Function JPFS20747A()
Local cQuery   := ""
Local cAlias   := ""
Local aArea    := GetArea()
Local aAreaSE1 := SE1->(GetArea())

	JPFS20747B() // Limpa E1_NFELETR dos títulos de impostos 

	cAlias := GetNextAlias()

	cQuery := " SELECT NXA_CESCR, NXA_COD, SF2.F2_FILIAL, SF2.F2_NFELETR"
	cQuery +=   " FROM " + RetSqlName("NXA") + " NXA "
	cQuery +=  " INNER JOIN " + RetSqlName("SF2") + " SF2 "
	cQuery +=     " ON SF2.F2_SERIE = NXA.NXA_SERIE"
	cQuery +=    " AND SF2.F2_DOC = NXA.NXA_DOC"
	cQuery +=    " AND SF2.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("NS7") + " NS7 "
	cQuery +=     " ON NS7.NS7_CFILIA = SF2.F2_FILIAL"
	cQuery +=    " AND NS7.NS7_COD = NXA.NXA_CESCR"
	cQuery +=    " AND NS7.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQuery +=    " AND NXA.D_E_L_E_T_ = ' '"

	DBUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery), cAlias, .T., .F.)
	SE1->(DBSetOrder(25)) // E1_FILIAL, E1_JURFAT

	While (cAlias)->(!Eof())
		If (SE1->(MSSeek((cAlias)->F2_FILIAL + xFilial("NXA") + '-' + (cAlias)->NXA_CESCR + '-' + (cAlias)->NXA_COD + '-' + (cAlias)->F2_FILIAL)))
			While SE1->(!Eof()) .And. !Empty(SE1->E1_JURFAT) .And. AllTrim(SE1->E1_JURFAT) == AllTrim(xFilial("NXA") + '-' + (cAlias)->NXA_CESCR + '-' + (cAlias)->NXA_COD + '-' + (cAlias)->F2_FILIAL)
				If Alltrim(SE1->E1_NFELETR) !=  Alltrim((cAlias)->F2_NFELETR)
					RecLock("SE1",.F.)
					SE1->E1_NFELETR := (cAlias)->F2_NFELETR
					SE1->(MSUnLock())
					JAjusNfe(SE1->(Recno()), SE1->E1_NFELETR) // Ajusta os campos OHH_NFELET, NXA_NFELET e NXA_LINKNF
				EndIf
				SE1->(DBSkip())
			EndDo
		EndIf
		(cAlias)->(DBSkip())
	EndDo

	(cAlias)->(DBCloseArea())
	RestArea(aAreaSE1)
	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPFS20747B
Limpa o conteúdo do campo E1_NFELETR para os títulos de impostos
dos documentos fiscais.

@author  Abner Fogaça de Oliveira
@since   24/01/2025
@obs     Essa função não filtra filial pois já é controlada pela varíavel
         lExecutou que é excutada uma única vez para cada empresa.
/*/
//-------------------------------------------------------------------
Static Function JPFS20747B()
Local cUpdate   := ""

	cUpDate := " UPDATE " + RetSqlName("SE1")
	cUpdate +=    " SET E1_NFELETR = ' '" 
	cUpdate +=  " WHERE E1_ORIGEM = 'JURA203'"
	cUpdate +=    " AND E1_JURFAT = ' '"
	cUpdate +=    " AND E1_NFELETR <> ' '"
	cUpdate +=    " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JPFS20248
Realizar a caraga da tabela de Impostos da Fatura (OIC) com os impostos desmebrandos da Fatura(NXA)

@author Leandro Sabino
@since  24/06/2025
/*/
//---------------------------------------------------------------------------------------------------
Static Function JPFS20248()
Local cQuery     := ""
Local cAlias     := ""
Local aArea      := GetArea()
Local aImpostos  := {0, 0, 0, 0, 0, 0}
Local nLoop      := 0

	If JChkfile("OIC") 
	
		If OIC->(EOF())//Somente se a tabela estiver vazia

			cAlias := GetNextAlias()

			cQuery := "SELECT * "
			cQuery += "  FROM " + RetSqlName("NXA") + " NXA "
			cQuery += " WHERE NXA.D_E_L_E_T_ = ' ' "
			cQuery += "    OR NXA.NXA_INSS > 0 "
			cQuery += "    OR NXA.NXA_PIS > 0  "
			cQuery += "    OR NXA.NXA_COFINS > 0  "
			cQuery += "    OR NXA.NXA_CSLL > 0  "
			cQuery += "    OR NXA.NXA_ISS > 0  "
	
			DBUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery), cAlias, .T., .T.)
			
			While (cAlias)->(!EOF())
				
				BEGIN TRANSACTION

					aImpostos := {(cAlias)->NXA_INSS,;
									(cAlias)->NXA_PIS,;
									(cAlias)->NXA_COFINS,;
									(cAlias)->NXA_CSLL,;
									(cAlias)->NXA_IRRF,;
									(cAlias)->NXA_ISS }

					For nLoop := 1 To 6 

						RecLock("OIC", .T.)

						OIC->OIC_FILIAL := xFilial("OIC")
						OIC->OIC_CESCR  := (cAlias)->NXA_CESCR  //Código do Escritório
						OIC->OIC_CFATUR := (cAlias)->NXA_COD    //Código da fatura
						OIC->OIC_TIPO   := (cAlias)->NXA_TIPO   //Tipo de emissão
					
						Do Case
							Case nLoop == 1 
								OIC->OIC_CODIMP := "INSS"
								OIC->OIC_ALIQ   := (cAlias)->NXA_PINSS 
								OIC->OIC_VLRIMP := aImpostos[1] //NXA_INSS 
							Case nLoop == 2 
								OIC->OIC_CODIMP := "PIS"
								OIC->OIC_ALIQ   := (cAlias)->NXA_PPIS
								OIC->OIC_VLRIMP := aImpostos[2] //NXA_PIS
							Case nLoop == 3
								OIC->OIC_CODIMP := "COF"
								OIC->OIC_ALIQ   := (cAlias)->NXA_PCOFIN
								OIC->OIC_VLRIMP := aImpostos[3] //NXA_COFINS
							Case nLoop == 4
								OIC->OIC_CODIMP := "CSL"
								OIC->OIC_ALIQ   := (cAlias)->NXA_PCSLL
								OIC->OIC_VLRIMP := aImpostos[4] //NXA_CSLL
							Case nLoop == 5
								OIC->OIC_CODIMP := "IRF"
								OIC->OIC_ALIQ   := (cAlias)->NXA_PIRRF
								OIC->OIC_VLRIMP := aImpostos[5] //NXA_IRRF
							Case nLoop == 6
								OIC->OIC_CODIMP := "ISS"
								OIC->OIC_ALIQ   := SuperGetMV('MV_ALIQISS',, 0)
								OIC->OIC_VLRIMP := aImpostos[6] //NXA_ISS
						EndCase

						//Base calculo do imposto = Honorários + Despesas Tributáveis + Acréscimos - Descontos + Grossup 														
						OIC->OIC_BASIMP := (cAlias)->NXA_VLFATH  +;
											(cAlias)->NXA_VLTRIB +;
											(cAlias)->NXA_VLACRE -;
											(cAlias)->NXA_VLDESC +;
											(cAlias)->NXA_VLGROS 

						OIC->OIC_BASIMP := J203VlrTit((cAlias)->NXA_CESCR, (cAlias)->NXA_COD, (cAlias)->NXA_CMOEDA)[1]

						OIC->(MsUnLock())
					Next nLoop

					aImpostos  := {0, 0, 0, 0, 0, 0}

				END TRANSACTION

				(cAlias)->(DbSkip())
				
			EndDo

			(cAlias)->(DbCloseArea())
		
		Endif	
	EndIf
	
	RestArea(aArea)

Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JPFS18974
Realizar o preenchimento dos campos NXG e NXP, para determinar  qual será a base de aplicação 
do desconto do pagador.

@author Victor Hayashi
@since  07/07/2025
/*/
//---------------------------------------------------------------------------------------------------
Static Function JPFS18974()
Local cUpdate := ""
Local nPosCpo := 0

	cUpdate := "UPDATE " + RetSqlName("NXP")
	cUpdate +=   " SET NXP_TPERCD = '1'"
	cUpdate += " WHERE NXP_FILIAL = '" + xFilial("NXP") + "'"
	cUpdate +=   " AND NXP_TPERCD = ' '"
	cUpdate +=   " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

	cUpdate := "UPDATE " + RetSqlName("NXG")
	cUpdate +=   " SET NXG_TPERCD = '1'"
	cUpdate += " WHERE NXG_FILIAL = '" + xFilial("NXG") + "'"
	cUpdate +=   " AND NXG_TPERCD = ' '"
	cUpdate +=   " AND D_E_L_E_T_ = ' '"
	TcSqlExec(cUpdate)

	// Atualiza a ordem do campo NXP_TPERCD para ficar antes do campo NXP_DESPAD
	nPosCpo := Val(RetAsc(GetSx3Cache("NXP_DESPAD", "X3_ORDEM"), 2, .F.))
	AtuOrdem("NXP", nPosCpo, "NXP_TPERCD")

	// Atualiza a ordem do campo NXG_TPERCD para ficar antes do campo NXG_DESPAD
	nPosCpo := Val(RetAsc(GetSx3Cache("NXG_DESPAD", "X3_ORDEM"), 2, .F.))
	AtuOrdem("NXG", nPosCpo, "NXG_TPERCD")

Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JPFS21422
Realiza a carga inicial na tabela de Impostos Pos. Hist. C. Receber (OIB) com base nos registros 
da Posicao Historica Ctas Receber (OHH) somente que tem vínculo com faturas (NXA)

@author Abner Fogaça de Oliveira
@since  22/07/2025
/*/
//---------------------------------------------------------------------------------------------------
Static Function JPFS21422()
Local cQuery    := ""
Local cAlias    := ""
Local nLoop     := 0
Local aArea     := GetArea()
Local nAliqIss  := SuperGetMV('MV_ALIQISS',, 0)
Local aImpostos := {0, 0, 0, 0, 0, 0}
Local aSX9      := {}
Local aSX9Estr  := {}
Local cModo     := ""
Local cModUn    := ""
Local cModEmp   := ""
Local lContinua := .F.

	If JChkfile("OIB") .And. OIB->(EOF())  // Somente se a tabela estiver vazia
		// Apaga os relacionamentos esses relacionamentos (Pois os campos OIB_CCLIEN e OIB_CLOJA)
		aSX9     := {}
		aSX9Estr := {"X9_DOM","X9_IDENT","X9_CDOM","X9_EXPDOM"         ,"X9_EXPCDOM"           ,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM", "X9_CONDSQL","X9_USEFIL","X9_ENABLE","X9_VINFIL","X9_CHVFOR","lApaga" }
		aAdd(aSX9,  {"NXA"   , "001"    , "OIB"   , "NXA_CESCR+NXA_COD", "OIB_CESCR+OIB_CFATUR",           ,           ,            ,             ,           ,           ,           ,           ,"__lApaga"})
		aAdd(aSX9,  {"SA1"   , "001"    , "OIB"   , "A1_COD+A1_LOJA"   , "OIB_CCLIEN+OIB_CLOJA",           ,           ,            ,            ,            ,           ,           ,           ,"__lApaga"})
		AtuSX9(aSX9, aSX9Estr)
		
		If SX2->(dbSeek("OHH")) // Atualiza o compartilhamento da OIB com base na OHH
			cModo   := SX2->X2_MODO
			cModUn  :=  SX2->X2_MODOUN
			cModEmp := SX2->X2_MODOEMP

			If SX2->(dbSeek("OIB"))
				If Alltrim(SX2->X2_UNICO) == 'OIB_FILIAL+OIB_PREFIX+OIB_NUM+OIB_PARCEL+OIB_TIPO+OIB_ANOMES+OIB_CODIMP'
					lContinua := .T.
					RecLock("SX2",.F.)
					SX2->X2_MODO    := cModo
					SX2->X2_MODOUN  := cModUn
					SX2->X2_MODOEMP := cModEmp
					SX2->(MsUnLock())
					SX2->(dbCommit())
				EndIf
			EndIf
		EndIf
		
		If lContinua
			AtuOrdem("OIB", 2, "OIB_PREFIX")
			AtuOrdem("OIB", 3, "OIB_NUM")
			AtuOrdem("OIB", 4, "OIB_PARCEL")
			AtuOrdem("OIB", 5, "OIB_TIPO")
			AtuOrdem("OIB", 6, "OIB_ANOMES")
			AtuOrdem("OIB", 7, "OIB_CODIMP")
			AtuOrdem("OIB", 8, "OIB_DESIMP")
			AtuOrdem("OIB", 9, "OIB_BASIMP")
			AtuOrdem("OIB", 10, "OIB_ALIQ")
			AtuOrdem("OIB", 11, "OIB_VLRIMP")
			AtuOrdem("OIB", 12, "OIB_CESCR")
			AtuOrdem("OIB", 13, "OIB_CFATUR")
			
			// Prepara a tabela OIB para receber os dados
			cAlias := GetNextAlias()

			cQuery := "SELECT OHH.OHH_FILIAL, OHH.OHH_PREFIX, OHH.OHH_NUM, OHH.OHH_PARCEL, OHH.OHH_TIPO, OHH.OHH_CESCR, OHH.OHH_CFATUR,"
			cQuery +=       " OHH.OHH_CMOEDA, OHH.OHH_VLIRRF,OHH.OHH_ANOMES, OHH.OHH_VLPIS, OHH.OHH_VLCOFI, OHH.OHH_VLCSLL,"
			cQuery +=       " OHH.OHH_VLISS, OHH.OHH_VLINSS,NXA.NXA_PIRRF, NXA.NXA_PPIS, NXA.NXA_PCOFIN, NXA.NXA_PCSLL, NXA.NXA_PINSS"
			cQuery += "  FROM " + RetSqlName("OHH") + " OHH "
			cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
			cQuery += "    ON SE1.E1_FILIAL = OHH.OHH_FILIAL "
			cQuery += "   AND SE1.E1_PREFIXO = OHH.OHH_PREFIX "
			cQuery += "   AND SE1.E1_NUM = OHH.OHH_NUM "
			cQuery += "   AND SE1.E1_PARCELA = OHH.OHH_PARCEL "
			cQuery += "   AND SE1.E1_TIPO = OHH.OHH_TIPO "
			cQuery += "   AND SE1.D_E_L_E_T_ = ' ' "
			cQuery += " INNER JOIN " + RetSqlName("NXA") + " NXA "
			cQuery += "    ON NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
			cQuery += "   AND NXA.NXA_CESCR  = OHH.OHH_CESCR "
			cQuery += "   AND NXA.NXA_COD = OHH.OHH_CFATUR "
			cQuery += "   AND NXA.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE OHH.OHH_FILIAL = '" + xFilial("OHH") + "'"
			cQuery += "   AND (SE1.E1_IRRF > 0"
			cQuery += "    OR SE1.E1_PIS > 0 "
			cQuery += "    OR SE1.E1_COFINS > 0"
			cQuery += "    OR SE1.E1_CSLL > 0"
			cQuery += "    OR SE1.E1_ISS > 0"
			cQuery += "    OR SE1.E1_INSS > 0)"
			cQuery += "   AND OHH.D_E_L_E_T_  = ' '""
			cQuery += " ORDER BY NXA.NXA_COD, OHH.OHH_ANOMES, OHH_PREFIX, OHH.OHH_NUM, OHH.OHH_PARCEL, OHH.OHH_TIPO"
			
			DBUseArea(.T., "TOPCONN", TCGenQry( ,,cQuery), cAlias, .T., .T.)
			
			While (cAlias)->(!EOF())
				
				BEGIN TRANSACTION

					aImpostos := {(cAlias)->OHH_VLIRRF,;
									(cAlias)->OHH_VLPIS,;
									(cAlias)->OHH_VLCOFI,;
									(cAlias)->OHH_VLCSLL,;
									(cAlias)->OHH_VLISS,;
									(cAlias)->OHH_VLINSS}

					For nLoop := 1 To Len(aImpostos)

						If aImpostos[nLoop] > 0
						
							RecLock("OIB", .T.)

							OIB->OIB_FILIAL := (cAlias)->OHH_FILIAL
							OIB->OIB_CESCR  := (cAlias)->OHH_CESCR
							OIB->OIB_CFATUR := (cAlias)->OHH_CFATUR
							OIB->OIB_ANOMES := (cAlias)->OHH_ANOMES
							OIB->OIB_PREFIX := (cAlias)->OHH_PREFIX
							OIB->OIB_NUM    := (cAlias)->OHH_NUM
							OIB->OIB_PARCEL := (cAlias)->OHH_PARCEL
							OIB->OIB_TIPO   := (cAlias)->OHH_TIPO
							OIB->OIB_BASIMP := J203VlrTit((cAlias)->OHH_CESCR, (cAlias)->OHH_CFATUR, cValToChar((cAlias)->OHH_CMOEDA))[1]
							
							Do Case
								Case nLoop == 1
									OIB->OIB_CODIMP := "IRF"
									OIB->OIB_ALIQ   := (cAlias)->NXA_PIRRF
									OIB->OIB_VLRIMP := aImpostos[1] //NXA_IRRF
								Case nLoop == 2
									OIB->OIB_CODIMP := "PIS"
									OIB->OIB_ALIQ   := (cAlias)->NXA_PPIS
									OIB->OIB_VLRIMP := aImpostos[2] //NXA_PIS
								Case nLoop == 3
									OIB->OIB_CODIMP := "COF"
									OIB->OIB_ALIQ   := (cAlias)->NXA_PCOFIN
									OIB->OIB_VLRIMP := aImpostos[3] //NXA_COFINS
								Case nLoop == 4
									OIB->OIB_CODIMP := "CSL"
									OIB->OIB_ALIQ   := (cAlias)->NXA_PCSLL
									OIB->OIB_VLRIMP := aImpostos[4] //NXA_CSLL
								Case nLoop == 5
									OIB->OIB_CODIMP := "ISS"
									OIB->OIB_ALIQ   := nAliqIss
									OIB->OIB_VLRIMP := aImpostos[5] //NXA_ISS
								Case nLoop == 6
									OIB->OIB_CODIMP := "INSS"
									OIB->OIB_ALIQ   := (cAlias)->NXA_PINSS
									OIB->OIB_VLRIMP := aImpostos[6] //NXA_INSS
							EndCase
							OIB->(MsUnLock())
						EndIf
					Next nLoop

					aImpostos  := {0, 0, 0, 0, 0, 0}

				END TRANSACTION

				(cAlias)->(DbSkip())
			EndDo

			(cAlias)->(DbCloseArea())
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return Nil
