#INCLUDE "GFEA093.ch"
#INCLUDE "PROTHEUS.CH"

// Códigos de mensagens padronizadas
#DEFINE GFEA093001 'GFEA093001'

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA093
Provisões de Frete

@author Jorge Matos Valcanaia
@since 28/01/10
@version  1.0
/*/
//-------------------------------------------------------------------

Function GFEA093(aParam)
	// Parâmetros
	Private lBlind := IsBlind()
	Private cFilIni
	Private cFilFim
	Private cRomIni	
	Private cRomFim	 
	Private dDtCriaIni
	Private dDtCriaFim	
	Private dDtSaiIni
	Private dDtSaiFim	
	
	Private GFEResult := GFEViewProc():New()
	
	GFEResult:EnableLog("gerar_provisao", "Geração de Provisão" + If (lBlind," - Schedule",""))
	
	If !lBlind
		If !Pergunte("GFEA093",.T.)
			Return Nil
		EndIf
	EndIf
	
	/* Romaneio */	
	If !lBlind
		GFEResult:GFELog:ShowParameters("GFEA093")
		Processa({|| GfeRatRom()},"Contabilizando...", "")
		GFEResult:Show("Geração de Movimentos Contábeis", "Documentos integrados", "Erros", "Ocorreram erros durante o processo, clique no botão 'Erros' para mais detalhes.")
	Else
		BatchProcess("GFEA093","GFEA093",,{ || GfeRatRom() })
		GFEResult:GFELog:Save()
		GFEResult:GFELog:EndLog()
	EndIf
	
Return  

Static Function GfeRatRom()    
	Local nI 		  := 0
	Local rPreFaturas := {}	// Armazena as pre-faturas relacionadas ao cálculo, para regerar o rateio da pré-fatura
	Local cAliasGWN := GetNextAlias()
	Local cQuery
	
	cFilIni     := MV_PAR01
	cFilFim     := MV_PAR02
	cRomIni     := MV_PAR03
	cRomFim	    := MV_PAR04
	dDtCriaIni  := MV_PAR05
	dDtCriaFim  := MV_PAR06
	dDtSaiIni   := MV_PAR07
	dDtSaiFim	:= MV_PAR08	
	
	cQuery := "SELECT GWN.* FROM " 	 + RetSQLName("GWN") + " GWN WHERE"
	cQuery += " GWN.GWN_FILIAL >= '" + cFilIni  + "' AND GWN.GWN_FILIAL <= '" + cFilFim + "' AND "
	cQuery += " GWN.GWN_NRROM >= '"  + cRomIni  + "' AND GWN.GWN_NRROM  <= '" + cRomFim + "' AND "
	If !Empty(dDtCriaIni) .AND. !Empty(dDtCriaFim)
		cQuery += " GWN.GWN_DTIMPL >= '" + DTOS(dDtCriaIni)  + "' AND GWN.GWN_DTIMPL <= '" + DTOS(dDtCriaFim) + "' AND "
	EndIf
	If !Empty(dDtSaiIni) .AND. !Empty(dDtSaiFim)
		cQuery += " (GWN.GWN_DTSAI = '' OR (GWN.GWN_DTSAI >= '" + DTOS(dDtSaiIni) + "' AND GWN.GWN_DTSAI <= '" + DTOS(dDtSaiFim) + "')) AND "
	EndIf
	cQuery += " GWN.GWN_CALC = '1' AND "
	cQuery += " GWN.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWN, .F., .T.)
	
	dbSelectArea((cAliasGWN))
	(cAliasGWN)->( dbGoTop() )
	
	If (cAliasGWN)->( Eof() )
		(cAliasGWN)->( dbCloseArea() )
		Return	
	EndIf
	
	If !lBlind
		ProcRegua(0)
	EndIf
	
	GFEResult:Add("Regeração da grade contábil dos cálculos de frete:")
	
	While !(cAliasGWN)->( Eof() )	    
		If !lBlind
			IncProc("Filial: " + AllTrim((cAliasGWN)->GWN_FILIAL) + ", Romaneio: " + AllTrim((cAliasGWN)->GWN_NRROM) + ", Data Saída: " + (cAliasGWN)->GWN_DTSAI)
		EndIf
		                        	       		       	
		dbSelectArea("GWF")
		dbsetOrder(4)
		If dbSeek((cAliasGWN)->GWN_FILIAL + (cAliasGWN)->GWN_NRROM)
			While !GWF->(Eof()) 							  .AND. ;
				   GWF->GWF_FILIAL == (cAliasGWN)->GWN_FILIAL .AND. ;
				   GWF->GWF_NRROM  == (cAliasGWN)->GWN_NRROM
				
				dbSelectArea("GXD")
				GXD->(dbsetOrder(2))
				// Se estiver vinculado a um lote que não esteja estornado, o cálculo é ignorado no processo
				If GXD->(dbSeek((cAliasGWN)->GWN_FILIAL + GWF->GWF_NRCALC))
					While !(GXD->(EoF())) .And. GXD->GXD_FILIAL == (cAliasGWN)->GWN_FILIAL .And. GXD->GXD_NRCALC == GWF->GWF_NRCALC
						If GXE->(dbSeek(GXD->(GXD_FILIAL+GXD_CODLOT))) .And. GXE->GXE_SIT != "6"
							GFEResult:Add("["+GFEA093001+"] "+ GFEMsgFmt(STR0020,{{"[VAR01]",GWF->GWF_NRCALC},{"[VAR02]",GXD->GXD_CODLOT}}))
							dbSelectArea("GWF")	
							dbSkip()
							Loop
						EndIf

						GXD->(dbSkip())
					EndDo
				EndIf
				
				cFilAnt := GWF->GWF_FILIAL
				aRetRateio := GFERatCal(.T.,GWF->GWF_NRCALC)
				
				If (aRetRateio[1] == .T.)
					GFEResult:Add("> Filial: " + AllTrim(GWF->GWF_FILIAL) + ", Cálculo: " + AllTrim(GWF->GWF_NRCALC) + ", Romaneio: " + AllTrim((cAliasGWN)->GWN_NRROM) + ", PreFat: " + GWF->GWF_NRPREF,2)	
					// Verifica se o cálculo está relacionado a uma pre-fatura e gera o rateio da pré-fatura
					If !Empty(GWF->GWF_NRPREF)
						dbSelectArea("GWJ")
						GWJ->(dbSetOrder(1))
						If GWJ->( dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRPREF) )
							If AScan( rPreFaturas, GWJ->(RecNo()) ) == 0
								aADD( rPreFaturas, GWJ->(RecNo()) )
							EndIf
						EndIf
					EndIf								
				Else  							
					GFEResult:AddDetail("** Erro ao refazer o rateio:")
					GFEResult:AddDetail("> Filial: " + AllTrim(GWF->GWF_FILIAL) + ", Cálculo: " + AllTrim(GWF->GWF_NRCALC) + ", Romaneio: " + AllTrim((cAliasGWN)->GWN_NRROM), 2)
					GFEResult:AddDetail("> Motivo: " + aRetRateio[2], 2)
					GFEResult:AddDetail("")
				EndIf
				dbSelectArea("GWF")
				dbSkip()							
			EndDo
		EndIf

		(cAliasGWN)->( dbSkip() )
	EndDo
	
	(cAliasGWN)->( dbCloseArea() )
	
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
Return

Static Function SchedDef()
Return { "P", "GFEA093", "", {}, "" }
