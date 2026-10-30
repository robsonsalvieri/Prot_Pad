#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA081
Calculo de frete por faixa de Romaneios.
Generico.

@sample
GFEA081()

@author Israel A. Possoli
@since 17/06/2013
@version 1.0
--------------------------------------------------------------------------------------------------/*/
Function GFEA081()
	Private cFilIni
	Private cFilFim
	Private cTrpIni
	Private cTrpFim
	Private cRomIni
	Private cRomFim
	Private cClassIni
	Private cClassFim
	Private cTpOpIni
	Private cTpOpFim
	Private dDataIni
	Private dDataFim
	Private lConsCalculados
	Private lDetalheCalculos
	Private lLiberar := .F.

	Private GFEResult := GFEViewProc():New()
	
	If !IsBlind() .And. Pergunte("GFEA081", .T.)
		cFilialIni	  	 := MV_PAR01
		cFilialFim	  	 := MV_PAR02
		cTranspIni   	 := MV_PAR03
		cTranspFim   	 := MV_PAR04
		cRomaneioIni   	 := MV_PAR05
		cRomaneioFim	 := MV_PAR06
		cClassIni 		 := MV_PAR07
		cClassFim 		 := MV_PAR08
		cTpOpIni  		 := MV_PAR09
		cTpOpFim  		 := MV_PAR10
		dDataIni  		 := MV_PAR11
		dDataFim  		 := MV_PAR12
		lConsCalculados	 := MV_PAR13
		lDetalheCalculos := If(MV_PAR14 == 1, .T., .F.)
		If GFEA050EXPer("GFEA081","15","Liberar?") .or. GFEA050EXPer("GFEA081","15","Liberar ?")
			lLiberar     := If(MV_PAR15 == 1, .T.,.F.)
		EndIf
		//-------------------------------------------------------------------
		//Rotina para realizar o calculo de frete do romaneio
		//-------------------------------------------------------------------

		Processa({|| ProcessaRomaneios()},"Calculando...", "")
		GFEResult:Show("Cálculo de Romaneios de Carga em Lote", "Romaneios calculados", "Erros", "Um ou mais Romaneios não foram calculados, clique no botão 'Erros' para mais detalhes.")

	Else
		cFilialIni	  	 := MV_PAR01
		cFilialFim	  	 := MV_PAR02
		cTranspIni   	 := MV_PAR03
		cTranspFim   	 := MV_PAR04
		cRomaneioIni   	 := MV_PAR05
		cRomaneioFim	 := MV_PAR06
		cClassIni 		 := MV_PAR07
		cClassFim 		 := MV_PAR08
		cTpOpIni  		 := MV_PAR09
		cTpOpFim  		 := MV_PAR10
		dDataIni  		 := MV_PAR11
		dDataFim  		 := MV_PAR12
		lConsCalculados	 := MV_PAR13
		lDetalheCalculos := If(MV_PAR14 == 1, .T., .F.)
		lLiberar      	 := If(MV_PAR15 == 1, .T., .F.)

		ProcessaRomaneios()
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcessaRomaneios
Realiza a busca dos Romaneios pela faixa selecionada

@author Israel A. Possoli
@since 17/06/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ProcessaRomaneios()
	Local aErr
	Local cMsgErro
	Local nY
	Local lRomOk 		  := .F.
	Local nZ 	  		  := 0
	Local nTotalRomaneios := 0
	Local cFilBkp 		  := cFilAnt

	Private aAgrFrt    := {}
	Private aDocCarg   := {}
	Private aTrchDoc   := {}
	Private aItDoc     := {}
	Private aRetCalc   := {}
	Private nRomCount  := 0
	Private nCountOk   := 0
	Private nCountErro := 0
	Private cAliasGWN  := GetNextAlias()
	Private _lSemHelp  := .F. // Variável usada para não exibir os Help's da função GFEA50LIB()

	If !IsBlind()
		ProcRegua(0)
		IncProc("Buscando Romaneios")
	EndIf

	cQuery := "SELECT GWN.*"
	cQuery += " FROM " + RetSQLName("GWN") + " GWN"
	cQuery += " WHERE GWN.GWN_FILIAL >= '" + cFilialIni    	+ "' AND GWN.GWN_FILIAL <= '" + cFilialFim     	+ "'"
	cQuery += "	  AND GWN.GWN_CDTRP  >= '" + cTranspIni    	+ "' AND GWN.GWN_CDTRP  <= '" + cTranspFim    	+ "'"
	cQuery += "	  AND GWN.GWN_NRROM  >= '" + cRomaneioIni  	+ "' AND GWN.GWN_NRROM  <= '" + cRomaneioFim	+ "'"
	cQuery += "	  AND GWN.GWN_CDCLFR >= '" + cClassIni    	+ "' AND GWN.GWN_CDCLFR <= '" + cClassFim		+ "'"
	cQuery += "	  AND GWN.GWN_CDTPOP >= '" + cTpOpIni   	+ "' AND GWN.GWN_CDTPOP <= '" + cTpOpFim		+ "'"
	cQuery += "	  AND GWN.GWN_DTIMPL >= '" + DTOS(dDataIni)	+ "' AND GWN.GWN_DTIMPL <= '" + DTOS(dDataFim) 	+ "'"
	If lConsCalculados == 2
		cQuery += " AND GWN_CALC != '1'"
	EndIf
	cQuery += " AND GWN.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGWN, .F., .T.)

	(cAliasGWN)->( dbGoTop() )
	If (cAliasGWN)->( Eof() )
		If !IsBlind()
			GFEResult:SetWarningIcon()
		EndIf
		GFEResult:Add("** Nenhum romaneio encontrado para a faixa informada.")
		Return
	EndIf

	/*
	 Devido a limitação na busca SQL, não é possível identificar a quantidade de registros que um comando SQL retornou,
	 Desta forma, foi necessário realizar a varredura da tabela, incrementando a variável nTotalRomaneios
	*/
	While !(cAliasGWN)->( Eof() )
		nTotalRomaneios++
		(cAliasGWN)->(dbSkip())
	EndDo

	If !IsBlind()
		ProcRegua(nTotalRomaneios)
	EndIf

	(cAliasGWN)->( dbGoTop() )
	While !(cAliasGWN)->( Eof() )
		nRomCount++
		cMsgErro := ""
		aRetCalc := {}
		cFilAnt  := (cAliasGWN)->GWN_FILIAL

		If !IsBlind()
			IncProc("Filial: " + (cAliasGWN)->GWN_FILIAL + ", Romaneio: " + AllTrim((cAliasGWN)->GWN_NRROM))
		EndIf

		GWN->(dbSetOrder(01))
		GWN->(dbSeek((cAliasGWN)->GWN_FILIAL + (cAliasGWN)->GWN_NRROM))

		lRomOk := GFE050CALC(,.F.,@cMsgErro,aRetCalc)
		If lRomOk
			nCountOk++

			GFEResult:Add("Filial: " + (cAliasGWN)->GWN_FILIAL + ", Romaneio: " + AllTrim((cAliasGWN)->GWN_NRROM))
		
			If lDetalheCalculos
				GWF->(dbSetOrder(4))
				GWF->(dbSeek((cAliasGWN)->GWN_FILIAL + (cAliasGWN)->GWN_NRROM))
				While !GWF->(Eof()) .AND. ;
					   GWF->GWF_FILIAL == (cAliasGWN)->GWN_FILIAL .AND. ;
					   GWF->GWF_NRROM  == (cAliasGWN)->GWN_NRROM
					
					GFEResult:Add("Cálculo: " + GWF->GWF_NRCALC + ", Valor: R$ " + AllTrim(Str(VLTOTFRET())), 2)
					If aScan(aRetCalc[3],{|x| x[1] == GWF->GWF_NRCALC .And. AllTrim(x[3]) == AllTrim((cAliasGWN)->GWN_NRROM) .And. x[5] == .T.}) != 0
						GFEResult:Add("Alertas:",2)
						For nY:= 1 to Len(aRetCalc[3])
							If	aRetCalc[3][nY][1] == GWF->GWF_NRCALC ;
								.And. AllTrim(aRetCalc[3][nY][3]) == AllTrim((cAliasGWN)->GWN_NRROM);
								.And. aRetCalc[3][nY][5] == .T.
								
								aErr:=GFECalcErr(aRetCalc[3][nY][2]) 
						 		For nZ:= 1 to Len(aRetCalc[3][nY][4])
									aErr[3] := StrTran(aErr[3],"[" + cValToChar(nZ) + "]",aRetCalc[3][nY][4][nZ]) 
								Next
								GFEResult:Add(aErr[3],4)
							EndIf
						Next nY
					EndIf
					GFEResult:Add("")
					GWF->(dbSkip())
				EndDo
			EndIf
		
			// Atualiza o romaneio como calculado e a Data/Hora como atual
			GWN->(dbSetOrder(1))
			If GWN->(dbseek((cAliasGWN)->GWN_FILIAL + (cAliasGWN)->GWN_NRROM))
				If lLiberar 
					cMsgErro := ""
					GFEA050LIB (.T.,@cMsgErro)
					If Empty(cMsgErro) // Não retornou menssagem de erro
						GFEResult:Add(Space(4)+"Romaneio liberado.")
					Else 
						GFEResult:AddErro(Space(4) + "Filial: " + xFilial("GWN") + ", Romaneio " + GWN->GWN_NRROM)
						GFEResult:AddErro(Space(7) + "Motivo: " + cMsgErro)
					EndIf
				EndIf
			Endif
		Else
			nCountErro++
			If Len(aRetCalc) > 0 //Falha dentro do cálculo do frete.
 				aErr:=GFECalcErr(aRetCalc[3][1][2]) 
		 		For nY:= 1 to Len(aRetCalc[3][1][4])
					aErr[1] := StrTran(aErr[1],"[" + cValToChar(nY) + "]",aRetCalc[3][1][4][nY]) 
				Next
				 
				AddErro((cAliasGWN)->GWN_FILIAL, (cAliasGWN)->GWN_NRROM, aErr[1], aRetCalc[2])
			Else
				AddErro((cAliasGWN)->GWN_FILIAL, (cAliasGWN)->GWN_NRROM,cMsgErro ) // Falha de pré-validação
			EndIf
		EndIf

		(cAliasGWN)->(dbSkip())
	EndDo
	
	cFilAnt := cFilBkp
	(cAliasGWN)->(DbCloseArea())
	GFEDElTab(cAliasGWN)

	If nCountOk == 0
		GFEResult:Add("Nenhum Romaneio calculado com sucesso.")
	EndIf

	GFEResult:Add("")
	GFEResult:Add(Replicate("-", 50))


	GFEResult:Add("Total de Romaneios processados: " + AllTrim(Str(nRomCount)))
	GFEResult:Add("Total de Romaneios calculados: "  + AllTrim(Str(nCountOk)))
	GFEResult:Add("Total de Romaneios com erros: "   + AllTrim(Str(nCountErro)))
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AddErro
Adiciona os romaneios com erros

@author Israel A. Possoli
@since 21/06/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AddErro(cFil, cRom, cMot, cLog)
	Default cLog := ""

	If (nCountErro > 1)
		GFEResult:AddErro("")
		GFEResult:AddErro(Replicate("-", 50))
	EndIf

	GFEResult:AddErro("Filial: " + cFil + ", Romaneio: " + AllTrim(cRom))
	GFEResult:AddErro("- Motivo: " + cMot, 1)
	If !Empty(cLog)
		GFEResult:AddErro("- Log: " + cLog, 1)
	EndIf
Return
