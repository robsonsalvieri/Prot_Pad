#Include "Totvs.ch"
#Include "TopConn.ch"
#include "locm001.ch"

/*/{Protheus.doc} LOCM001.PRW
ITUP Business - TOTVS RENTAL
@type Function
@author Frank Zwarg Fuga
@since 03/12/2020
@version P12
@history 03/12/2020, Jose Eulálio, Fonte produtizado.
Antigo ponto de entrada: MNTA400F
Após a confirmação da tela de finalização da OS
/*/

Function LOCM001()
Local _aAreaOLD := GetArea()
Local _aAreaST9 := ST9->(GetArea())
Local _aAreaSTL := STL->(GetArea())
Local _aAreaZC1 := FPG->(GetArea())
Local _aAreaST1 := ST1->(GetArea())
Local _cQrySTL  := ""
Local cLocx061  := SuperGetMV("MV_LOCX061",.F., "")
Local cAliasSTL := GetNextAlias()
Local _lGerCE   := SuperGetMV("MV_LOCX007",.F.,.F.)	// Parametro que define se gera Custo Extra na OS
Local _lRet     := .T.
Local _cQuery
Local aBindParam
Local lLOCM001A :=  ExistBlock("LOCM001A")
Local nContMTBF := 0//Contador MTBF FH0
Local nContAtu  := 0//Contador Atual STJ que está sendo encerrada
Local nContAnt  := 0//Contador da ultima O.S que o produto fez parte
Local nApura    := 0//Valor Apurado do MTBF nContAtu - nContAnt
Local nDifMTBF  := 0//Valor Diferença MTBF nContMTBF - nApura
Local nPerc     := 0//Percentual de apuração MTBF  nApura / nContMTBF
Local cIntParc  := ""//Se o MTBF é integral ou parcial 1=Proporcional;2=Integral
Local nCustoMTBF := 0
/*
FH0 = Parcial
Calcular percentual:
nPerc := nApura / nContMTBF

FH0 = Integral
Calcular percentual:
nPerc := 100%

Aplicar sobre o custo unitário atual do produto já definido no LOCM001:
nCustoMTBF := nPerc * nCustoUnitario
*/
	//Gera Custo Extra na OS
	If _lGerCE

		/*
		+xFilial("STL")+
		+M->TJ_ORDEM+
		*/

		//Card 1149 - Circenis - 29/11/2023 - Deletar os Custos Extras não Faturados
		DeletFPG()

		_cQrySTL := "SELECT TL_FILIAL  , TL_ORDEM , TL_PLANO , TL_TAREFA , TL_TIPOREG , TL_CODIGO , TL_SEQRELA , TL_SEQTARE , "
		_cQrySTL += " TL_QUANTID , TL_CUSTO , STL.R_E_C_N_O_ As STL_RECNO_ "
		//03/08/2022 - Jose Eulalio - SIGALOC94-314 - MNT - Incorporação dos pontos de entrada - Manunteção de ativos
		If STL->(FieldPos("TL_AS")) > 0
			_cQrySTL += " , TL_AS "
		EndIf
		_cQrySTL += "FROM "+RetSqlName("STL")+" STL (NOLOCK) "
		_cQrySTL += "WHERE STL.D_E_L_E_T_ = '' AND STL.TL_FILIAL = ? AND STL.TL_ORDEM = ? "
		_cQrySTL += "  AND STL.TL_SEQRELA >  '0  ' "
		If STL->(FieldPos("TL_AS")) > 0
			_cQrySTL += " AND STL.TL_AS = 'S' "
		EndIf
		_cQrySTL += "ORDER BY TL_FILIAL , TL_ORDEM , TL_PLANO , TL_TAREFA , TL_TIPOREG , TL_CODIGO , TL_SEQRELA , TL_SEQTARE "
		_cQrySTL := ChangeQuery(_cQrySTL)
		aBindParam := {xFilial("STL"),M->TJ_ORDEM}
		cAliasSTL := MPSysOpenQuery(_cQrySTL,,,,aBindParam)
		//DBUSEAREA(.T. , "TOPCONN" , TCGENQRY(,,_cQrySTL) , cAliasSTL , .F. , .T.)

		//Gera FPG
		If (cAliasSTL)->(!Eof()) 																						// --> 'STL->'
			//roda resultados na STL
			While (cAliasSTL)->(!Eof()) .And. xFilial("STL") = (cAliasSTL)->TL_FILIAL .And. M->TJ_ORDEM = (cAliasSTL)->TL_ORDEM // --> 'STL->'
				//somente se for Frete
				If (cAliasSTL)->TL_TIPOREG <> "F"
					//Card 1149 - Circenis - 29/11/2023 - Verificar so o Custo Extra está
					if FaturaFPG(cAliasSTL)

						MSGALERT( STR0011 + (cAliasSTL)->TL_SEQRELA + STR0012 + M->TJ_ORDEM + STR0013 , STR0014 ) //"O Custo Extra para o item "###" da O.S. "###" já foi faturado e não será gerado."###"Geração de Custo Extra"

					else
						cIntParc := IntParc((cAliasSTL)->TL_CODIGO, STJ->TJ_PROJETO)//Se o MTBF é integral ou parcial
						nContMTBF := ContMTBF((cAliasSTL)->TL_CODIGO, STJ->TJ_PROJETO)//PEGO O CONTADOR DA FHO DO PRODUTO CORRENTE
						If nContMTBF <> 0
							nContAnt := ContAnt((cAliasSTL)->TL_CODIGO,(cAliasSTL)->TL_ORDEM)//PEGO O CONTADOR DA ULTIMA OS ENCERRADA
							nContAtu := STJ->TJ_POSCONT//PEGO O CONTADOR ATUAL
							nApura := nContAtu - nContAnt
							nDifMTBF := nContMTBF - nApura
						EndIf	

						If nDifMTBF > 0
							If cIntParc == '1'//Proporcional
								nPerc := 100 - ((nApura / nContMTBF) * 100)
								//nCustoMTBF := nPerc * ((cAliasSTL)->TL_CUSTO / (cAliasSTL)->TL_QUANTID)
							EndIf

							If cIntParc == '2'//Integral
								nPerc := 100
								nApura := nContAtu - nContAnt
								//nCustoMTBF := nPerc * ((cAliasSTL)->TL_CUSTO / (cAliasSTL)->TL_QUANTID)
							EndIf
						EndIf
					
						//Insere registro na FPG
						If RecLock("FPG",.T.)
							// --> Estava: .F.
							//gera numeração nova
							_cSeq := GetSx8Num("FPG","FPG_SEQ")
							ConfirmSx8()

							//popula os campos
							FPG->FPG_FILIAL := xFilial("FPG")
							If STJ->(FieldPos("TJ_PROJETO")) > 0  .And.  STJ->(FieldPos("TJ_OBRA")) > 0  .And.  STJ->(FieldPos("TJ_AS")) > 0
								FPG->FPG_PROJET := STJ->TJ_PROJETO
								FPG->FPG_OBRA   := STJ->TJ_OBRA
								FPG->FPG_NRAS   := STJ->TJ_AS
							ElseIf TTF->(FieldPos("TTF_XAS")) > 0
								If Select("TRBTTF") > 0
									TRBTTF->(dbCloseArea())
								EndIf

								/*
								+ xFilial("TTG") +
								+ M->TJ_ORDEM    +
								*/

								_cQuery := " SELECT DISTINCT TTF_XAS XAS , FQ5_OBRA XOBRA , FQ5_SOT XPROJET "
								_cQuery += " FROM " + RetSqlName("TTG") + " TTG (NOLOCK) "
								_cQuery += "        INNER JOIN " + RetSqlName("TTF") + " TTF (NOLOCK) ON  TTF.TTF_FILIAL =  TTG_FILIAL"
								_cQuery += "                                                          AND TTF.TTF_CHECK  =  TTG_CHECK "
								_cQuery += "                                                          AND TTF.D_E_L_E_T_ =  '' "
								_cQuery += "        LEFT  JOIN " + RetSqlName("FQ5") + " DTQ (NOLOCK) ON  DTQ.FQ5_AS     =  TTF_XAS  "
								_cQuery += "                                                          AND DTQ.FQ5_AS     <> '' "
								_cQuery += "                                                          AND DTQ.D_E_L_E_T_ =  '' "
								_cQuery += " WHERE  TTG.TTG_FILIAL =  ? "
								_cQuery += "    AND TTG.TTG_NUMERO =  ? "
								_cQuery += "    AND TTG.TTG_XAS    <> '' "
								_cQuery += "    AND TTG.D_E_L_E_T_ =  '' "
								_cQuery := ChangeQuery(_cQuery)
								aBindParam := {xFilial("TTG"),M->TJ_ORDEM}
								MPSysOpenQuery(_cQuery,"TRBTTF",,,aBindParam)
								//TcQuery _cQuery New Alias "TRBTTF"

								If TRBTTF->(!Eof())
									FPG->FPG_PROJET := TRBTTF->XPROJET
									FPG->FPG_OBRA   := TRBTTF->XOBRA
									FPG->FPG_NRAS   := TRBTTF->XAS
								EndIf
								TRBTTF->(dbCloseArea())
							EndIf

							//caso seja mão de obra
							If (cAliasSTL)->TL_TIPOREG == "M"
								//Localiza Produto de Mão de Obra na ST1 (Funcionários)
								ST1->(DbSetOrder(1)) //T1_FILIAL+T1_CODFUNC
								If ST1->(DbSeek(xFilial("ST1") + (cAliasSTL)->TL_CODIGO)) .And. !Empty(ST1->T1_PRODMO )
									FPG->FPG_PRODUTO := ST1->T1_PRODMO
								Else
									FPG->FPG_PRODUTO := cLocx061
								EndIf
							ElseIf (cAliasSTL)->TL_TIPOREG == "P"
								FPG->FPG_PRODUTO := (cAliasSTL)->TL_CODIGO
							EndIf

							FPG->FPG_DESCRI      := Posicione("SB1",1,xFilial("SB1")+FPG->FPG_PRODUTO,"B1_DESC")
							FPG->FPG_QUANT       := (cAliasSTL)->TL_QUANTID
							FPG->FPG_VLUNIT      := Posicione("SB1",1,xFilial("SB1")+FPG->FPG_PRODUTO,"B1_PRV1")
							//If FPG->FPG_VLUNIT < (cAliasSTL)->TL_CUSTO
							//SIGALOC94-681 - Jose Eulalio - 12/06/2023 - Ajuste geração de custo extra via OS
							//verifica qual valor unitário maior para ser considerado
							if lLOCM001A
								nValTot := ExecBlock("LOCM001A",.F.,.F.,{(cAliasSTL)->TL_CUSTO, cAliasSTL })
								if Empty(nValTot)
									nValTot := (cAliasSTL)->TL_CUSTO
								endif
							else
								nValTot := (cAliasSTL)->TL_CUSTO
							endif
							If ( nValTot / FPG->FPG_QUANT ) > FPG->FPG_VLUNIT
								FPG->FPG_VLUNIT  := nValTot / FPG->FPG_QUANT
							EndIf
							If nDifMTBF > 0//se tiver MTBF calculo o custo do MTBF e gravo o novo custo untário(MTBF)
								nCustoMTBF := (nPerc * Posicione("SB1",1,xFilial("SB1")+(cAliasSTL)->TL_CODIGO,"B1_PRV1"))/100
								FPG->FPG_VLUNIT  := nCustoMTBF
							EndIf
							If nDifMTBF <= 0 .AND. nContMTBF <> 0//se tiver MTBF calculo o custo do MTBF e gravo o novo custo untário(MTBF)
								nCustoMTBF := 0
								FPG->FPG_VLUNIT  := nCustoMTBF
							EndIf 							 	
							FPG->FPG_VALOR       := FPG->FPG_QUANT * FPG->FPG_VLUNIT
							FPG->FPG_VALTOT      := FPG->FPG_VALOR + FPG->FPG_TAXAV
							FPG->FPG_STATUS      := "1"
							If nDifMTBF > 0 .AND. nContMTBF <> 0//SE TIVER MTBF SERÁ COBRADO
								FPG->FPG_COBRA       := "S"
							Else								
								FPG->FPG_COBRA       := " "
							EndIf
							If nDifMTBF <= 0 .AND. nContMTBF <> 0//SE TIVER MTBF SERÁ COBRADO
								FPG->FPG_COBRA       := "N"
							Else								
								FPG->FPG_COBRA       := " "
							EndIf									
							FPG->FPG_DTENT       := dDataBase
							FPG->FPG_TIPO        := "4" // Indica que veio de uma OS
							FPG->FPG_JUNTO       := "S"
							FPG->FPG_CUSTO       := "MNTA400"
							FPG->FPG_CODDES      := ST9->T9_CODBEM
							FPG->FPG_DESPES      := ST9->T9_NOME
							FPG->FPG_DOCORI      := M->TJ_ORDEM+'-'+(cAliasSTL)->TL_SEQRELA
							FPG->FPG_SEQ         := _cSeq
							If nDifMTBF > 0
								FPG->FPG_CMTBF       := nContMTBF
								FPG->FPG_CATUAL      := nContAtu
								FPG->FPG_CANT        := nContAnt
								FPG->FPG_APURA       := nApura
								FPG->FPG_NPERC       := nPerc
								FPG->FPG_CUSORI      := Posicione("SB1",1,xFilial("SB1")+(cAliasSTL)->TL_CODIGO,"B1_PRV1")
								FPG->FPG_TIPCOB      := cIntParc
							EndIf
							If nDifMTBF <= 0 .AND. nContMTBF <> 0
								FPG->FPG_CMTBF       := nContMTBF
								FPG->FPG_CATUAL      := nContAtu
								FPG->FPG_CANT        := nContAnt
								FPG->FPG_APURA       := nApura
								FPG->FPG_NPERC       := 0
								FPG->FPG_CUSORI      := Posicione("SB1",1,xFilial("SB1")+(cAliasSTL)->TL_CODIGO,"B1_PRV1")
								FPG->FPG_TIPCOB      := cIntParc
							EndIf							
							FPG->(MsUnLock())
						EndIf
					EndIf
				endif
				nDifMTBF := 0
				(cAliasSTL)->(dbSkip())
			EndDo
		Else
			_lRet := .T.  // Frank em 19/01/23 estava retornando .F.
		EndIf
		(cAliasSTL)->(DbCloseArea())
	EndIf

	// DSERLOCA-1982 - implemento - Frank Fuga em 14/05/2024
	AJUSTEFQF()

	// DSERLOCA-2341 - Liberacao de equipamento quando em status de manutenção
	LIBERM001()

	RestArea( _aAreaZC1 )
	RestArea( _aAreaSTL )
	RestArea( _aAreaST9 )
	RestArea( _aAreaOLD )
	RestArea( _aAreaST1 )

Return _lRet

/*/{Protheus.doc} DeletFPG
Deleta os custos extras não faturados  gerados pela OS
@type function
@version 1.0
@author aleci
@since 11/29/2023
/*/
Static Function DeletFPG()
Local cQuery 	:= ""
Local aArea 	:= GetArea()

	cQuery += "SELECT FPG.R_E_C_N_O_"
	cQuery += " FROM "+ RetSqlName("FPG") + " FPG (NOLOCK) "
	cQuery += " WHERE FPG_FILIAL = ? " // 1 xFilial("FPG")
	cQuery += " AND FPG_DOCORI LIKE ? "   // 2 M->TJ_ORDEM
	cQuery += " AND FPG_PVNUM = ''"  // Pedido não gerado
	cQuery += " AND FPG.D_E_L_E_T_ = ' ' "
	aBindParam := {xFilial("FPG"),M->TJ_ORDEM+"%"}
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"TRBFPG",,,aBindParam)

	while !TRBFPG->(Eof())
		dbSelectArea("FPG")
		dbGoto(TRBFPG->R_E_C_N_O_)
		if Empty(FPG->FPG_PVNUM) // Pedido de Venda não foi gerado
			RecLock("FPG",.F.)
			FPG->(dbDelete())
			msUnlock()
		endif
		TRBFPG->(dbSkip())
	enddo

	TRBFPG->(dbCloseArea())
	RestArea(aArea)

Return
/*/{Protheus.doc} FaturaFPG
Retorna .T. se o custo extra do item da OS
@type function
@version 01
@author aleci
@since 11/29/2023
@return variant, .T. se estiver
/*/
Static Function FaturaFPG(cAliasSTL)
Local lRet := .F. // Se For possivel deletar todos os custos extras
Local cQuery := ""
Local aArea 	:= GetArea()

	cQuery += "SELECT FPG.R_E_C_N_O_"
	cQuery += " FROM "+ RetSqlName("FPG") + " FPG (NOLOCK) "
	cQuery += " WHERE FPG_FILIAL = ? " // 1 xFilial("FPG")
	cQuery += " AND FPG_DOCORI = ? "   // 2 M->TJ_ORDEM
	cQuery += " AND FPG_PVNUM > ''"
	cQuery += " AND FPG.D_E_L_E_T_ = ' ' "
	aBindParam := {xFilial("FPG"),M->TJ_ORDEM+'-'+(cAliasSTL)->TL_SEQRELA}
	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"TRBFPG",,,aBindParam)

	if !TRBFPG->(Eof())
		dbSelectArea("FPG")
		dbGoto(TRBFPG->R_E_C_N_O_)
		if !Empty(FPG->FPG_PVNUM) // Pedido de Venda foi gerado
			lRet := .T.
		endif

	endif

	TRBFPG->(dbCloseArea())
	RestArea(aArea)

RETurn lRet

// rotina para processamento do advpr
// Frank em 02/01/23
Function LOCM001X
Return

/*/ AJUSTEFQF
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
TRATAMENTO PARA IMPLEMENTO
DSERLOCA-1982 - Frank em 14/05/2024
/*/
Function AJUSTEFQF
Local aArea := GetArea()
Local lImplemento := .F.
Local lTem
Local cQuery

	If FindFunction( "LOCA224B1" )
        If LOCA224B1("FQG_FILIAL", "FQG") .and. SuperGetMV( 'MV_NG1LOC', .F., .F. ) .and. LOCA224B1("FQF_FILIAL", "FQF")
			lImplemento := .T.
		EndIf
	EndIf

	If lImplemento
		// Localizar o movimento do substatus
		lTem := .F.
		FQF->(dbSetOrder(5)) // Codigo do bem
		FQF->(dbSeek(xFilial("FQF")+STJ->TJ_CODBEM))
		While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_CODBEM) == xFilial("FQF")+STJ->TJ_CODBEM
			If FQF->FQF_OS == STJ->TJ_ORDEM
				lTem := .T.
				Exit
			EndIf
			FQF->(dbSkip())
		EndDo
		If lTem
			ST9->(dbSetOrder(1))
			ST9->(dbSeek(xFilial("ST9")+STJ->TJ_CODBEM))
			FQF->(RecLock("FQF",.F.))
			FQF->FQF_DPPINI := STJ->TJ_DTPPINI
			FQF->FQF_HPPINI := STJ->TJ_HOPPINI
			FQF->FQF_DPPFIM := STJ->TJ_DTPPFIM
			FQF->FQF_HPPFIM := STJ->TJ_HOPPFIM
			FQF->FQF_DPRINI := STJ->TJ_DTPRINI
			FQF->FQF_HPRINI := STJ->TJ_HOPRINI
			FQF->FQF_DPRFIM := STJ->TJ_DTPRFIM
			FQF->FQF_HPRFIM := STJ->TJ_HOPRFIM
			FQF->(MsUnlock())
		EndIF 
		// Colocar na FQG a OS como finalizada
		If select("TRBOS") > 0
            TRBOS->(dbCloseArea())
        EndIf
        cQuery := " SELECT FQG.R_E_C_N_O_ AS REG "
        cQuery += " FROM " + RETSQLNAME("FQG") + " FQG "
        cQuery += " WHERE FQG.D_E_L_E_T_ = '' AND FQG.FQG_OS = ? "
        cQuery := CHANGEQUERY(cQuery)
        aBindParam := {STJ->TJ_ORDEM}
        MPSysOpenQuery(cQuery,"TRBOS",,,aBindParam)
        While !TRBOS->(Eof())
            FQG->(dbGoto(TRBOS->(REG)))
            FQG->(RecLock("FQG"),.F.)
            FQG->FQG_FEITO := "S"
            FQG->(MsUnlock())
            TRBOS->(dbSkip())
        EndDo
        TRBOS->(dbCloseArea())
	EndIF

	RestArea(aArea)

Return .T.

/*/ LIBERM001
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
QUANDO HOUVER UM FECHAMENDO DE OS E O STATUS DO BEM ESTIVER COMO 70 (MANUTENCAO) - FAZER A LIBERACAO AUTOMATICA
DSERLOCA-2341 - Frank em 28/06/2024
/*/

Static Function LIBERM001
Local cRet70 := ""
Local cQryLeg
Local aArea := GetArea()
Local cSTSANTI := ""
Local cSTSNOVO := ""
Local cMaior := ""
Local nReg   
Local cAs
Local nReg2 := 0
Local cSeq := ""

	// Carantir a integridade das funções do RPO
	If !FindFunction("LOCA224K")
		Return .F.
	EndIF

	// Status correspondente ao 00 - Disponível
	cSTSNOVO := LOCA224K()

    If SELECT("TMPLEG") > 0
        TMPLEG->( DBCLOSEAREA() )
    EndIf   

	// Ver o status correspondente ao 70 - em manutenção
	cQryLeg := "SELECT FQD_STATQY , FQD_STAREN FROM "+ RETSQLNAME("FQD") +" WHERE FQD_STAREN = '70' AND D_E_L_E_T_ = '' "	
	TCQUERY cQryLeg NEW ALIAS "TMPLEG"
	While TMPLEG->(!EOF())
		cRet70 += TMPLEG->FQD_STATQY + "*" 
        TMPLEG->(DBSKIP()) 
    EndDo
    TMPLEG->( DBCLOSEAREA() )

	// Executar o processamento somente se o status 70 - Em manutenção foi cadastrado
	If !empty(cRet70)

		// Posicionar no bem do fechamento da OS
		ST9->(dbSetOrder(1))
		If ST9->(dbSeek(xFilial("ST9")+STJ->TJ_CODBEM))

			If ST9->T9_STATUS $ cRet70 // Em manutenção
				FQ4->(dbSetOrder(1))
				// Verificar se o bem já teve movimentação no bem
				If FQ4->(dbSeek(xFilial("FQ4")+ST9->T9_CODBEM))
					cMaior := FQ4->FQ4_SEQ
					nReg := FQ4->(Recno())
					While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4")+ST9->T9_CODBEM
						If FQ4->FQ4_SEQ > cMaior .and. FQ4->FQ4_OS == STJ->TJ_ORDEM
							cMaior := FQ4->FQ4_SEQ
							nReg := FQ4->(Recno())
						EndIF
						FQ4->(dbSkip())
					EndDo
					FQ4->(dbGoto(nReg))

					If FQ4->FQ4_OS == STJ->TJ_ORDEM
						cSTSANTI := ST9->T9_STATUS
						ST9->(RECLOCK("ST9",.F.)) 
						ST9->T9_STATUS := cSTSNOVO // DISPONIVEL 
						ST9->(MSUNLOCK()) 
						LOCXITU21(cSTSANTI, cSTSNOVO, STJ->TJ_PROJETO , "", "")
					EndIF
				Else
					// Se não localizar um movimento no gerenciamento de bens, criar neste momento
					cSTSANTI := ST9->T9_STATUS
					ST9->(RECLOCK("ST9",.F.)) 
					ST9->T9_STATUS := cSTSNOVO // DISPONIVEL 
					ST9->(MSUNLOCK()) 
					LOCXITU21(cSTSANTI, cSTSNOVO, STJ->TJ_PROJETO , "", "")
				EndIF
			EndIf
		EndIF

		// Se os campos de data estiverem preenchidos gerar o sub-status
		If !empty(STJ->TJ_DTPRINI) .or. !empty(STJ->TJ_DTPRFIM) .or. !empty(STJ->TJ_DTPPINI) .or. !empty(STJ->TJ_DTPPFIM) .or. file("\SYSTEM\LOCA059X1.TXT")
			cAs := STJ->TJ_AS
			nReg2 := 0
			cSeq := ""
			If !empty(cAs)
				FPA->(dbSetOrder(3))
				If FPA->(dbSeek(xFilial("FPA")+cAs))
					FQ4->(dbSeek(xFilial("FQ4")+STJ->TJ_CODBEM))
					While !FQ4->(Eof()) .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) == xFilial("FQ4")+STJ->TJ_CODBEM
						If FQ4->FQ4_SEQ > cSeq
							cSeq := FQ4->FQ4_SEQ
							nReg2 := FQ4->(Recno())
						EndIf
						FQ4->(dbSkip())
					EndDo

					// Se nReg for 0 criar a FQ4
					If nReg2 == 0
						ST9->(dbSetOrder(1))
						ST9->(dbSeek(xFilial("ST9")+STJ->TJ_CODBEM))
						LOCXITU21("",ST9->T9_STATUS,"","","")
						FQ4->(RecLock("FQ4",.F.))
						FQ4->FQ4_OBRA   := ""
						FQ4->FQ4_AS     := ""
						FQ4->FQ4_CODCLI := ""
						FQ4->FQ4_NOMCLI := ""
						FQ4->FQ4_CODMUN := ""
						FQ4->FQ4_MUNIC  := ""
						FQ4->FQ4_EST    := ""
						FQ4->FQ4_DTINI  := ctod("")
						FQ4->FQ4_DTFIM  := ctod("")
						FQ4->FQ4_PREDES := ctod("")
						FQ4->FQ4_LOJCLI := ""
						If empty(FQ4->FQ4_PROJET)
							FQ4->FQ4_AS := ""
						EndIf
						FQ4->(MsUnlock())
						nReg := FQ4->(Recno())
					EndIf
					// Se nReg for > 0 posiconar na FQ4
					If nReg2 > 0
						FQ4->(dbGoto(nReg2))
					EndIf

					// Localizar o movimento do substatus
					lTem := .F.
					FQF->(dbSetOrder(5)) // Codigo do bem
					FQF->(dbSeek(xFilial("FQF")+STJ->TJ_CODBEM))
					While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_CODBEM) == xFilial("FQF")+STJ->TJ_CODBEM
						If FQF->FQF_OS == STJ->TJ_ORDEM
							lTem := .T.
							Exit
						EndIf
						FQF->(dbSkip())
					EndDo
					
					If !lTem
						cCod := GetSx8Num("FQF","FQF_COD")
						ConfirmSx8()
						FQF->(RecLock("FQF",.T.))
					Else
						FQF->(RecLock("FQF",.F.))
					EndIF

					// Gerar o registro do sub-status
					FQF->FQF_FILIAL := xFilial("FQF") 
					FQF->FQF_CODBEM := STJ->TJ_CODBEM
					FQF->FQF_STATUS := FQ4->FQ4_STATUS
					FQF->FQF_CC     := FPA->FPA_CUSTO
					FQF->FQF_DTINI  := dDataBase
					FQF->FQF_HORA   := Time()
					FQF->FQF_SUBST  := ACHAFQH(FQ4->FQ4_STATUS, STJ->TJ_SERVICO)
					FQF->FQF_PROJET := FPA->FPA_PROJET
					FQF->FQF_AS     := cAs
					FQF->FQF_CONTA  := STJ->TJ_POSCONT
					FQF->FQF_SEQ    := FQ4->FQ4_SEQ
					FQF->FQF_OS     := STJ->TJ_ORDEM
					FQF->FQF_DPPINI := STJ->TJ_DTPPINI
					FQF->FQF_HPPINI := STJ->TJ_HOPPINI
					FQF->FQF_DPPFIM := STJ->TJ_DTPPFIM
					FQF->FQF_HPPFIM := STJ->TJ_HOPPFIM
					FQF->FQF_DPRINI := STJ->TJ_DTPRINI
					FQF->FQF_HPRINI := STJ->TJ_HOPRINI
					FQF->FQF_DPRFIM := STJ->TJ_DTPRFIM
					FQF->FQF_HPRFIM := STJ->TJ_HOPRFIM
					If !lTem
						FQF->FQF_COD    := cCod
					EndIf
					FQF->(MsUnlock())
				EndIf
			EndIf
		EndIf

	EndIF

	RestArea(aArea)
Return .T.

/*/ ContAnt
ITUP BUSINESS - TOTVS RENTAL
AUTHOR DENNIS CALABREZ
BUSCO O ULTIMO CONTADOR DA ULTIMA OS ENCERRADA
15/07/2025
/*/
Function ContAnt(cProd,cOrdem)
Local nCont := 0
Local aArea := GetArea()
Local cQuery := ""
Local aBindParam := {}

	cQuery := "SELECT * "
	cQuery += " FROM "+RetSqlName("STL")+" STL"
	cQuery += " WHERE TL_CODIGO = ? AND "
	cQuery += " STL.D_E_L_E_T_ = '' AND TL_ORDEM <> ?"
	cQuery += " ORDER BY TL_ORDEM DESC"
	cQuery := ChangeQuery(cQuery)

	aBindParam := {cProd,cOrdem}

	MPSysOpenQuery(cQuery,"TRBSTL",,,aBindParam)

	TRBSTL->(DbGoTop())

	DBSELECTAREA("STJ")
	STJ->(dbSetOrder(1))
	IF DbSeek(xFilial("STJ")+TRBSTL->TL_ORDEM)
		nCont := STJ->TJ_POSCONT
	ENDIF	

 RestArea(aArea)
Return(nCont)

/*/ ContMTBF
ITUP BUSINESS - TOTVS RENTAL
AUTHOR DENNIS CALABREZ
BUSCO O CONTADOR ATUAL NA FH0
15/07/2025
/*/
Function ContMTBF(cProd,cProjet)
Local cProj := ""
Local aArea := GetArea()
Local cQuery := ""
Local aBindParam := {}

	cQuery := "SELECT * "
	cQuery += " FROM "+RetSqlName("FH0")+" FH0"
	cQuery += "  WHERE FH0_CODPRO = ? AND FH0_PROJET = ?"
	cQuery += " AND FH0.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	aBindParam := {cProd,cProjet}

	MPSysOpenQuery(cQuery,"TRBFH0",,,aBindParam)

	cProj := TRBFH0->FH0_POSCON

 RestArea(aArea)
Return(cProj)

/*/ IntParc
ITUP BUSINESS - TOTVS RENTAL
AUTHOR DENNIS CALABREZ
Verifica se o MTBF será cobra integral ou parcial
15/07/2025
/*/
Function IntParc(cProd,cProjet)
Local cCob := ""
Local aArea := GetArea()
Local cQuery := ""
Local aBindParam := {}

	cQuery := "SELECT * "
	cQuery += " FROM "+RetSqlName("FH0")+" FH0"
	cQuery += "  WHERE FH0_CODPRO = ? AND FH0_PROJET = ?"
	cQuery += " AND FH0.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)

	aBindParam := {cProd,cProjet}

	MPSysOpenQuery(cQuery,"TRBFH0",,,aBindParam)

	cCob := TRBFH0->FH0_TIPCOB

 RestArea(aArea)
Return(cCob)


Function CalcMtbf(cTipCob,nApura,nMtbf)
//nPerc := 100 - ((nApura / nContMTBF) * 100)
//IIF(M->FPG_TIPCOB == '1',(M->FPG_APURA/M->FPG_CMTBF)*100,100)
	If cTipCob == '1'
		nPerc := 100-((nApura/nMtbf)*100)
	Else
		nPerc := 100	
	EndIf
	
	If nPerc < 0
		nPerc := 0
	EndIf	
Return(nPerc)
