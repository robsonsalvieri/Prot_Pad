#INCLUDE "PROTHEUS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA093SCH
Geração de movimentos contábeis de provisão via Schedule

@author Israel A. Possoli
@since 17/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA093SCH()
	Private cGFETrace := GetPvProfString("General" , "GFETrace" , "ERROR" , GetAdv97() )

	If !IsBlind()
		MsgInfo("Este programa deve ser executado apenas via Schedule. " + CHR(13) + CHR(10) + "Para contabilzar documentos de provisão em lote, usar o programa GFEA093, localizado no menu 'Movimentações > Contabilização > Gerar Provisões'.")
		Return
	EndIf
	
	If cGFETrace == "1"
		GFEConout("INFO","[" + Time() + "] [GFEA093SCH] [PRE-FATURA] [MONITORING]")
	EndIf
		
	Contabilizar()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Contabilizar
Contabilizar provisões de Frete

@author Israel A. Possoli
@since 28/01/10
@version  1.0
/*/
//-------------------------------------------------------------------
Static Function Contabilizar()
	Local nI 		  := 0
	Local rPreFaturas := {}		// Armazena as pre-faturas relacionadas ao cálculo, para regerar o rateio da pré-fatura
	Local cAliasGWJ := GetNextAlias()
	Local cQuery
	Local lCalcCont	:= .T.		// Controla o status da contabilização do cálculo
	Local cStatus
	Local lOk
	Local aRetCtbPre
	Private cFilIni
	Private cFilFim
	Private cRomIni	
	Private cRomFim	 
	Private dDtImpIni
	Private dDtImpFim	
	Private dDtSaiIni
	Private dDtSaiFim
	Private nAtuFinanc
	
	cFilIni     := MV_PAR01
	cFilFim     := MV_PAR02
	cTranspIni  := MV_PAR03
	cTranspFim  := MV_PAR04
	cNumeroIni  := MV_PAR05
	cNumeroFim  := MV_PAR06
	dDtImpIni   := MV_PAR07
	dDtImpFim   := MV_PAR08
	nAtuFinanc  := MV_PAR09
	
	cQuery := "SELECT GWJ.* FROM " 	 + RetSQLName("GWJ") + " GWJ WHERE "
	cQuery += " GWJ.GWJ_FILIAL >= '" + cFilIni     + "' AND GWJ.GWJ_FILIAL <= '" + cFilFim    + "' AND "
	cQuery += " GWJ.GWJ_CDTRP  >= '" + cTranspIni  + "' AND GWJ.GWJ_CDTRP  <= '" + cTranspFim + "' AND "
	cQuery += " GWJ.GWJ_NRPF   >= '" + cNumeroIni  + "' AND GWJ.GWJ_NRPF   <= '" + cNumeroFim + "' AND "
	If !Empty(dDtImpIni) .AND. !Empty(dDtImpFim)
		cQuery += " GWJ.GWJ_DTIMPL >= '" + DTOS(dDtImpIni)  + "' AND GWJ.GWJ_DTIMPL <= '" + DTOS(dDtImpFim) + "' AND "
	EndIf
	cQuery += " GWJ.GWJ_SIT = '3' AND "
	cQuery += " (GWJ.GWJ_SITFIN  = '1' OR GWJ.GWJ_SITFIN  = '3') AND "
	cQuery += " GWJ.D_E_L_E_T_ = '' AND "
	cQuery += "     NOT EXISTS ( "
	cQuery += "     SELECT 1 FROM " + RetSQLName("GWK") + " GWK "
	cQuery += "     WHERE GWK_FILIAL = GWJ_FILIAL AND "
	cQuery += "        GWK_NRPF   = GWJ.GWJ_NRPF  AND "
	cQuery += "        GWK.D_E_L_E_T_ = '')"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWJ, .F., .T.)
	
	dbSelectArea((cAliasGWJ))
	(cAliasGWJ)->( dbGoTop() )
	
	If (cAliasGWJ)->( Eof() )
		(cAliasGWJ)->( dbCloseArea() )
		Return	
	EndIf
	
	While !(cAliasGWJ)->( Eof() )
		cStatus   	:= ""
		lOk			:= .T.
		lCalcCont 	:= .T.
		
		dbSelectArea("GWF")
		dbsetOrder(3) // GWF_FILPRE+GWF_NRPREF
		If dbSeek((cAliasGWJ)->GWJ_FILIAL + (cAliasGWJ)->GWJ_NRPF)
			While !GWF->(Eof()) 							  .AND. ;
				   GWF->GWF_FILIAL == (cAliasGWJ)->GWJ_FILIAL .AND. ;
				   GWF->GWF_NRPREF == (cAliasGWJ)->GWJ_NRPF
				   
				dbSelectArea("GXD")
				GXD->(dbsetOrder(2))
				
				// Se estiver vinculado a um lote que não esteja estornado, o cálculo é ignorado no processo
				If GXD->(dbSeek((cAliasGWJ)->GWJ_FILIAL + GWF->GWF_NRCALC))
					GXE->(dbSeek(GXD->(GXD_FILIAL+GXD_CODLOT)))
					If GXE->GXE_SIT != "6"
						dbSelectArea("GWF")	
						dbSkip()
						Loop
					EndIf
				EndIf
				
				cFilAnt := GWF->GWF_FILIAL
				aRetRateio := GFERatCal(.T.,GWF->GWF_NRCALC)
				
				If (aRetRateio[1] == .F.)
					lCalcCont := .F.				
					cStatus := "[ERRO - Calculo '" + AllTrim(GWF->GWF_FILIAL) + "/" + AllTrim(GWF->GWF_NRCALC) + "' nao contabilizado. Motivo: " + aRetRateio[2] + "]"
					lOk	:= .F.
					Exit
				EndIf
				
				dbSelectArea("GWF")
				dbSkip()							
			EndDo
		EndIf
		
		If lCalcCont
			dbSelectArea("GWJ")
			If dbSeek((cAliasGWJ)->GWJ_FILIAL + (cAliasGWJ)->GWJ_NRPF)
				aRetCtbPre := GFEACTBPRE(GWJ->GWJ_FILIAL, GWJ->GWJ_NRPF)
				
				If aRetCtbPre[1]
					cStatus := "[OK]"
					
					If nAtuFinanc == 1
						RecLock("GWJ")
							GWJ->GWJ_SITFIN := "2"
							GWJ->GWJ_MOTFIN := ""
							GWJ->GWJ_DTFIN	:= Date()
						MsUnlock("GWJ")
					EndIf
				Else
					cStatus := "[ERRO - Motivo: " + aRetCtbPre[2] + "]"
					lOk	:= .F.
				EndIf
			Else
				cStatus := "[ERRO - Pre-fatura nao encontrada]"
				lOk	:= .F.
			EndIf
		EndIf
		
		If nAtuFinanc == 1 .AND. lOk == .F.
			RecLock("GWJ")
				GWJ->GWJ_SITFIN := "3"
				GWJ->GWJ_MOTFIN := cStatus
			MsUnlock("GWJ")
		EndIf		
		
		If cGFETrace == "1"
			GFEConout("INFO","[" + Time() + "] [GFEA093SCH] [PRE-FATURA] Empresa/Filial: " + cEmpAnt + "/" + (cAliasGWJ)->GWJ_FILIAL + " [Nr: " + AllTrim((cAliasGWJ)->GWJ_NRPF) + ", Transportador: " + AllTrim((cAliasGWJ)->GWJ_CDTRP) +  "] " + cStatus)
		EndIf
		
		(cAliasGWJ)->( dbSkip() )
	EndDo
	
	(cAliasGWJ)->( dbCloseArea() )
	
	/*
	// Regera a grade de rateio para as pré-faturas dos cálculos que a grade contábil foi refeita
	If Len(rPreFaturas) > 0
		GFEResult:Add()
		GFEResult:Add("Pré-faturas recontabilizadas:")
	EndIf
	
	For nI := 1 To Len(rPreFaturas)
		dbSelectArea("GWJ")
		dbGoTo(rPreFaturas[nI])
		GFEResult:Add("> Filial: " + GWJ->GWJ_FILIAL + ", Número: " + GWJ->GWJ_NRPF, 1)
		
		GFEACTBPRE(GWJ->GWJ_FILIAL, GWJ->GWJ_NRPF)
	Next
	
	aSize(rPreFaturas, 0)
	rPreFaturas := Nil
	*/
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
Função interna para Schedule

@author Israel A. Possoli
@since 17/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Scheddef()
	Local aParam
	Local aOrd := {}
	
	aParam := {"P"		,;
			   "GFEA093SCH",;
			   "GWJ"	,;
			   {}		,;
			   "Contabilização de provisão e integração"}

Return(aParam)