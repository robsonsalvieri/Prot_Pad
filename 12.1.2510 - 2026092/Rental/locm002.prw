#Include "protheus.ch"
#Include "topconn.ch"                                                                                       
#Include "TbiConn.ch"

/*/{Protheus.doc} LOCM002
Função chamada ao excluir a nota de saida 
@type Function
@author Frank Zwarg Fuga
@since 03/12/2020
@version P12
@history 03/12/2020, Frank Zwarg Fuga, Fonte produtizado.
Antigo ponto de entrada: SF2520E.PRW
Após a exclusão da nota fiscal de saída
/*/

Function LOCM002()
Local aArea     := GetArea()
Local aAreaSC6  := SC6->(GetArea())
Local aAreaST9  := ST9->(GetArea())
Local aAreaZAG  := FPA->(GetArea())
Local aAreaZA0  := FP0->(GetArea())

Local cAliasQry := GetNextAlias() 
Local cRoma     := ""
Local cFpyRoma  := ""
Local cPvAs		:= ""
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local lMVLCX243 := SuperGetMv("MV_LOCX243",.F.,.F.)
Local cQuery
Local aBindParam
Local _cQuery

	dbSelectArea("SC6")
	SC6->(dbSetOrder(4))
	If SC6->(dbSeek(SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE))
		While SC6->(!Eof()) .And. SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE == SC6->C6_FILIAL + SC6->C6_NOTA + SC6->C6_SERIE
			If lMVLCX243
				LOCA040(SC6->C6_FILIAL , SC6->C6_NUM , SC6->C6_ITEM , , , , .T.) 
			EndIf
			SC6->(dbSkip())
		EndDo
	EndIf

	ST9->( dbSetOrder(1) )

	// Verificamos se eh NF de Remessa

	/*
	+SF2->F2_FILIAL+
	+SF2->F2_DOC   +
	+SF2->F2_SERIE +
	*/

	cQuery := " SELECT R_E_C_N_O_ ZAGREC  "      
	cQuery += " FROM "+RetSqlName("FPA")+" ZAG " 
	cQuery += " WHERE  ZAG.FPA_FILREM = ? " 
	cQuery += "   AND  ZAG.FPA_NFREM  = ? " 
	cQuery += "   AND  ZAG.FPA_SERREM = ? " 
	cQuery += "   AND  ZAG.D_E_L_E_T_ = ' ' "
	cQuery := changequery(cQuery) 
	aBindParam := {SF2->F2_FILIAL,SF2->F2_DOC,SF2->F2_SERIE}
	cAliasQry := MPSysOpenQuery(cQuery,,,,aBindParam)
	(cAliasQry)->(dbGoTop()) 

// Se não encontrar a serie na FPA, pesquisar com a serie do parametro carregada no cSerie - Rossana - 13/03/2024
// Ajuste - Closearea na query correta agora
// Comentado - DSERLOCA 6024 - estava excluindo NF de mesmo numero de NF de remessa do Rental, porém com outra serie, 
// e considerou como se a NF do Rental estivesse sendo excluida
/*
	If (cAliasQry)->(Eof())
		(cAliasQry)->( dbCloseArea() )
		cQuery := " SELECT R_E_C_N_O_ ZAGREC  "      
		cQuery += " FROM "+RetSqlName("FPA")+" ZAG " 
		cQuery += " WHERE  ZAG.FPA_FILREM = ? " 
		cQuery += "   AND  ZAG.FPA_NFREM  = ? " 
		cQuery += "   AND  ZAG.FPA_SERREM = ? " 
		cQuery += "   AND  ZAG.D_E_L_E_T_ = ' ' "
		cQuery := changequery(cQuery) 
		aBindParam := {SF2->F2_FILIAL,SF2->F2_DOC,cSerie}
		cAliasQry := MPSysOpenQuery(cQuery,,,,aBindParam)
		(cAliasQry)->(dbGoTop()) 
	EndIf
/*
	If SF2->F2_SERIE != cSerie .Or. SF2->F2_TIPO != 'N' 
		RestArea( aArea )
		Return Nil
	EndIf
*/
	dbSelectArea("FP0")

	While ! (cAliasQry)->( Eof() )
	
		FPA->( dbGoTo( (cAliasQry)->ZAGREC ) )
	
		If ! Empty(FPA->FPA_GRUA) .And. ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
			If !Empty(ST9->T9_STATUS)
				
				LOCM002ES( FPA->FPA_GRUA, FPA->FPA_NFREM, FPA->FPA_SERREM )
				
			Endif
		EndIf
	
		// Frank em 20/09/23
		// Limpar o campo somente se a nota de remessa em questão for a registrada na FPA
		// Liberamos a exclusão de notas mais antigas em algumas situações
		If alltrim(FPA->FPA_NFREM) == alltrim(SF2->F2_DOC)
			If RecLock("FPA", .F.)
				FPA->FPA_FILREM	:= ""
				FPA->FPA_NFREM  := ""
				FPA->FPA_SERREM	:= ""
				FPA->FPA_ITEREM	:= ""
				FPA->FPA_DNFREM := StoD("")
				FPA->FPA_PEDIDO := ""
				FPA->(MsUnLock())
			EndIf
		EndIF
		
		_aZAG := FPA->(GetArea())
		_aSZ1 := FQ3->(GetArea())
		SC6->(dbSetOrder(4))
		SC6->(dbSeek(xFilial("SC6")+SF2->F2_DOC+SF2->F2_SERIE))
		While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->(C6_NOTA+C6_SERIE) == SF2->F2_DOC+SF2->F2_SERIE
			If lMvLocBac
				FPY->(dbSetOrder(1))
				FPY->(dbSeek(xFilial("SC6") + SC6->C6_NUM))
				FPZ->(dbSetOrder(1))
				FPZ->(dbSeek(xFilial("SC6") + SC6->C6_NUM))
				cFpyRoma:= FPY->FPY_NFDEVO
				cPvAs	:= FPZ->FPZ_AS
			Else
			/*/ Não entra se LocBac for falso
				cFpyRoma:= SF2->F2_IT_ROMA
				cPvAs	:= SC6->C6_XAS
			/*/
			EndIf

			
			If !empty(cPvAs)
				FQ3->(dbSetOrder(3))
				If FQ3->(dbSeek(xFilial("FQ3")+cPvAs))
					If !empty(FQ3->fq3_NFREM) .and. FQ3->fq3_NUM = cFpyRoma
						
						// Frank em 20/09/23
						// Limpar o campo somente se a nota de remessa em questão for a registrada na FPA
						// Liberamos a exclusão de notas mais antigas em algumas situações
						If FQ3->FQ3_NFREM == SF2->F2_DOC
							FQ3->(RecLock("FQ3",.F.))
							FQ3->fq3_NFREM	:= ""
							FQ3->fq3_SERREM	:= ""
							FQ3->(MsUnlock())
							cRoma := FQ3->FQ3_NUM
						EndIF
					EndIf
				EndIf
			EndIf
			SC6->(dbSkip())
		EndDo

		If !empty(cRoma)
			FQ2->(dbSetOrder(1))
			If FQ2->(dbSeek(xFilial("FQ2")+cRoma))
				FQ2->(RecLock("FQ2",.F.))
				FQ2->FQ2_NFSER := ""
				FQ2->(MsUnlock())
			EndIF
		EndIF

 	   	If FindFunction( "LOCA224B1" )

    	    If LOCA224B1("FQV_FILIAL", "FQV")
		//Processar as novas tabelas do Romaneio
		// Verificar se veio da Gestão de Expedição
				_cQuery := " SELECT FQV.R_E_C_N_O_ FQVRECNO"
				_cQuery += " FROM " + RetSqlName("FQV") + " FQV"
				_cQuery += " WHERE FQV.FQV_FILIAL = '"+xFilial("FQV")+"' "
				_cQuery += " AND FQV.FQV_SERREM  = ? "
				_cQuery += " AND FQV.FQV_NFREM  = ? "
				_cQuery += " AND FQV.D_E_L_E_T_ = ' ' "
				_cQuery := changequery(_cQuery)
				aBindParam := {SF2->F2_SERIE, SF2->F2_DOC}
				MPSysOpenQuery(_cQuery,"TRBFQV",,,aBindParam)

				While !TRBFQV->(Eof()) // Achou nota de remessa no romaneio
					FQV->(dbGoto(TRBFQV->FQVRECNO))
					RecLock("FQV")
					FQV->FQV_NFREM := ''
					FQV->FQV_SERREM := ''
					FQV->FQV_ITEMNF := ''
					msUnLock()
					
					FH2->(dbSetOrder(1)) // Verificar se existem bens quantificaveis
					IF FH2->(dbSeek(xFilial("FH2")+FQV->FQV_AS))

						cQuery := " SELECT   FQD_STATQY"      
						cQuery += " FROM " + RetSqlName("FQD") + " FQD " 
						cQuery += " WHERE    FQD.FQD_STAREN < '20' "     
						cQuery += "   AND    FQD.D_E_L_E_T_ = ' ' "       
						cQuery += " ORDER BY FQD_STAREN DESC "
						cQuery := changequery(cQuery) 
						MPSysOpenQuery( cQuery, "TRBFQD")
						TRBFQD->(dbGotop()) // antes era na query top 1, agora pegamos o primeiro registro
						
						while !(FH2->(Eof())) .and. FH2->FH2_AS = FQV->FQV_AS .and. FH2->FH2_FILIAL = xFilial("FH2")
				
							LOCM002ES( FH2->FH2_CODBEM, FH2->FH2_NFREM, FH2->FH2_SERREM )

							RecLock("FH2", .F.)
							FH2->FH2_NFREM  := ""
							FH2->FH2_SERREM := ""
							FH2->FH2_INFREM := ""
							MsUnlock()
				
							FH2->(dbSkip())
						enddo
						TRBFQD->(dbCloseArea())
					endif
					TRBFQV->(dbSkip())
				enddo
			EndIf
		EndIf

		RestArea(_aZAG)
		RestArea(_aSZ1)
		
		(cAliasQry)->( dbSkip() )
	EndDo

	(cAliasQry)->( dbCloseArea() )

	RestArea( aAreaZA0 )
	RestArea( aAreaST9 )
	RestArea( aAreaZAG )
	RestArea( aAreaSC6 )
	RestArea( aArea )

Return Nil

/*/{Protheus.doc} LOCM002ES
Estorna o status da ST9 e deleta a movimentação na 
@type function
@version 25.10  
@author Alexandre Circenis
@since 23/03/2026
@param cBem, character, Codigo do Bem para se estornado
@Param cDoc, character, Codigo do documento que está sendo estornado
@param cSerie, Character, Codigo da serie do documento que está sendo estornado

/*/
Function LOCM002ES( cBem, cDoc, cSerie )
Local aArea := GetArea()
Local cQuery := ""
Local aBind := {}

	cQuery += "SELECT R_E_C_N_O_ REG"
	cQuery += " FROM "+RetSqlName("FQ4")
	cQuery += " WHERE FQ4_FILIAL = '"+xFilial("FQ4")+"'"
	cQuery += "  AND FQ4_CODBEM =  ? "
	Aadd( aBind, { cBem, "S"})
	cQuery += "  AND FQ4_DOCUME = ? "
	Aadd( aBind, { cDoc, "S"})
	cQuery += "  AND FQ4_SERIE  = ? "
	Aadd( aBind, { cSerie, "S"})
	cQuery += "  AND D_E_L_E_T_ =  ' '"

	cQuery := ChangeQuery(cQuery)
	cQuery := LocXGerQry(cQuery, aBind)

	MPSysOpenQuery( cQuery, "TRBFQ4")

	if !TRBFQ4->(Eof())

		FQ4->(dbGoto(TRBFQ4->REG))

		ST9->( DBSETORDER(1) )
		IF  ST9->( DBSEEK( XFILIAL("ST9")+ cBem))
			RecLock("ST9", .F.)
			ST9->T9_STATUS :=  FQ4->FQ4_STSOLD
			ST9->(msUnLock())
		endif

		RecLock("FQ4",.F.)
		FQ4->(dbDelete())
		FQ4->(msUnLock())

	endif

	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LocXGerQry 
Gera a query substituindo os paramentros palo conteudo do array

@param cQuery, Query original sem bind para substituição de valores
@param aBind , Valores para utilização na query

@Return cQuery, Query com as substituição de valores

@author  Alexandre Circenis
@since   24/02/2026
/*/
//-------------------------------------------------------------------
Function LocXGerQry(cQuery, aBind)
Local oStatement as Object
Local nQtd as Numeric
Local nI as Numeric

	nQtd := Len(aBind)
	If nQtd > 0
		oStatement := FWPreparedStatement():New()
		oStatement:SetQuery(cQuery)
		For nI := 1 To nQtd
			If aBind[nI][2] == "S" // Tipo String
				oStatement:SetString(nI, aBind[nI][1])
			ElseIf aBind[nI][2] == "U"
				oStatement:SetUnsafe(nI, aBind[nI][1])
			Elseif aBind[nI][2] == "I"
				oStatement:SetIn(nI, aBind[nI][1])
			ElseIf aBind[nI][2] == "D"	
				oStatement:SetDate(nI, aBind[nI][1])
			Else 
				oStatement:SetNumeric(nI, aBind[nI][1])
			EndIf
		Next nI
		cQuery := oStatement:GetFixQuery()
	EndIf

Return cQuery
