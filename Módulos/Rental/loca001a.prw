#include "loca001.ch" 
#include "TOTVS.CH"

// FUNCOES ESPECIFICAS PARA O TRATAMENTO DO TURNO NO LOCA001

/*/{PROTHEUS.DOC} LOCA00183
ITUP BUSINESS - TOTVS RENTAL - validação do turno
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/07/2024
/*/

Function LOCA00183(cCampo)
Local lRet := .T.
Local cHrini
Local cHrfim
Local cTipo
Local cIniFpa := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_HRINI"})]
Local cFimFPA := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_HRFIM"})] 

	If valtype(oDlgTur) == "O"
		If cCampo == "FPE_HRINIT"
			cHrini := M->FPE_HRINIT
			cHrfim := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_HOFIMT", oDlgTur:aHeader)]
			cTipo  := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_DIASEM", oDlgTur:aHeader)]
		ElseIf cCampo == "FPE_HOFIMT"
			cHrini := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_HRINIT", oDlgTur:aHeader)]
			cHrfim := M->FPE_HOFIMT
			cTipo  := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_DIASEM", oDlgTur:aHeader)]
		ElseIf cCampo == "FPE_DIASEM"
			cHrini := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_HRINIT", oDlgTur:aHeader)]
			cHrfim := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_HOFIMT", oDlgTur:aHeader)]
			cTipo  := M->FPE_DIASEM
		EndIf
	
		If cTipo == "D" .or. cTipo == "N" .or. cTipo == "A" //.or. cTipo == "E"
			If !empty(cHrIni) .and. !empty(cHrFim) .and. !empty(cIniFPA) .and. !empty(cFimFpa)
				If !LOCA001DV1(cHrIni, cHrFim, cIniFPA, cFimFpa )
				//If (cHrini > cIniFPA .and. cHrIni < cFimFpa) .or. (cHrfim > cIniFPA .and. cHrfim < cFimFpa) .or. (cHrini == cIniFPA .and. cHrfim == cFimFpa)
					MsgAlert(STR0627,STR0033) //"Conflito de horas entre o turno e o projeto"###"Inconsistência nos dados"
					lRet := .F.
				EndIF
			EndIf
		EndIF
	EndIf
	
Return lRet


/*/LOCA001T01
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
SINCE 18/12/2024
HISTORY 18/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
DSERLOCA-3409 Registro dos turnos
FFOLDERTUR
/*/
Function LOCA001T01(nFolder, nLin1, nCol1, nLin2, nCol2, lFiltra)
Local nStyle := GD_INSERT + GD_UPDATE + GD_DELETE
Local cAlias
Local cChave
Local cCondicao
Local nIndice
Local cFiltro
Local cProjet := FP0->FP0_PROJET
Local cObra := odlgPla:aCols[odlgPla:nAt][ascan(odlgPla:aHeader,{|X|alltrim(X[2])=="FPA_OBRA"})]
Local cSeq := odlgPla:aCols[odlgPla:nAt][ascan(odlgPla:aHeader,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})]
Local aRet
Local MaxGetDad := 99999

Default lFiltra := .F.

	nStyle := Iif(nOpcManu==2, 0, nStyle) 

	cAlias := "FPE"
	cChave := xFilial(cAlias)+cProjet
	cCondicao := 'FPE_FILIAL+FPE_PROJET=="'+cChave+'"'
	cFiltro := cCondicao
	
	aRet := LOCA001T02(lFiltra, aHeader, cAlias, nIndice, cChave, cCondicao, cFiltro)
	aCols := aRet[1,2]
	oTur_cols := aclone(aCols)
	oTurno_orig := aclone(aCols)

	nIndice := 2

	cCondicao := 'FPE_FILIAL+FPE_PROJET+FPE_OBRA+FPE_SEQGUI=="'+cChave+'"'
	cChave := xFilial(cAlias)+cProjet+cObra+cSeq
	cFiltro := cCondicao

    aRet := LOCA001T02(lFiltra, aHeader, cAlias, nIndice, cChave, cCondicao, cFiltro)
	aHeader := aRet[1,1]
	aCols := aRet[1,2]

	oDlgTur := MsNewGetDados():New(nLin1, nCol1, nLin2, nCol2, nStyle,,,"",,, MaxGetDad,,, {|| .T.}, oFolder:aDiaLogs[nFolder], aHeader, aCols)
	//ODLGTUR:OBROWSE:BCHANGE := {|| LOCA001B()}
	//ODLGTUR:OBROWSE:BADD	:= {|| IIF( LOCA001A7() ,ODLGIMP:ADDLINE(),)}
	//ODLGTUR:OBROWSE:BDELETE := {|| LOCA001AA() }
	oDlgTur:SetEditLine(.F.)

Return Nil

/*/LOCA001T03
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
SINCE 18/12/2024
HISTORY 18/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
DSERLOCA-3409 Inicializador dos campos FPE_PROJET, OBRA, SEQGUI e FROTA
FFOLDERTUR
/*/
Function LOCA001T03(cCampo)
Local cRet
Local cProjet := FP0->FP0_PROJET
Local cObra := odlgPla:aCols[odlgPla:nAt][ascan(odlgPla:aHeader,{|X|alltrim(X[2])=="FPA_OBRA"})]
Local cSeq := odlgPla:aCols[odlgPla:nAt][ascan(odlgPla:aHeader,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})]
Local cFrota := odlgPla:aCols[odlgPla:nAt][ascan(odlgPla:aHeader,{|X|ALLTRIM(X[2])=="FPA_GRUA"})]

    If cCampo == "FPE_PROJET"
        cRet := cProjet
    ElseIf cCampo == "FPE_OBRA" 
        cRet := cObra
    ElseIf cCampo == "FPE_SEQGUI"
        cRet := cSeq
    Else
        cRet := cFrota
    EndIf

Return cRet

/*/ LOCA00182
ITUP BUSINESS - TOTVS RENTAL - VALIDACAO DOS CAMPOS DA FPE
AUTHOR FRANK ZWARG FUGA
SINCE 03/12/2020
HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

Function LOCA00182(cCampo)
Local lRet := .T.
Local cHrIni := ""
Local cHrFim := ""
Local cDiaSem := ""
Local cHrIni2 := ""
Local cHrFim2 := ""
Local cdiaSem2 := ""
Local lVldHrTu := SuperGetMV("MV_LOCX258",.F.,.T.)
Local nX

	If valtype(oDlgTur) == "O"

		If cCampo == "FPE_HRINIT"
			cHrIni := M->FPE_HRINIT
			cHrFim := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_HOFIMT", oDlgTur:aHeader)]
		ElseIf cCampo == "FPE_HOFIMT"
			cHrIni := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_HRINIT", oDlgTur:aHeader)]
			cHrFim := M->FPE_HOFIMT
		Else
			cHrIni := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_HRINIT", oDlgTur:aHeader)]
			cHrFim := oDlgTur:aCols[oDlgTur:nAt, GDFIELDPOS("FPE_HOFIMT", oDlgTur:aHeader)]
		EndIf

		If empty(cCampo)
			cDiaSem := M->FPE_DIASEM
		Else
			cDiaSem := oDlgTur:aCols[N, GDFIELDPOS("FPE_DIASEM", oDlgTur:aHeader)]
		EndIf

		If cHrIni == "2400" .and. cHrFim == "2400"
			lRet := .F.
			Help(Nil,	Nil,STR0029+alltrim(upper(Procname())),; //"RENTAL: "
							Nil,STR0033,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
							{STR0404}) //"A hora inicial deve ser diferente da hora final."
		EndIf

		If cHrIni == "2400"
			cHrIni := "0000"
		EndIf

		If lVldHrTu
			If !Empty(cHrFim) .and. lRet .and. !empty(cHrIni)
				If cHrIni > cHrFim .and. lRet
					Help(Nil,	Nil,STR0029+alltrim(upper(Procname())),; //"RENTAL: "
							Nil,STR0033,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
							{STR0405}) //"A hora final não pode ser inferior a hora inicial."
					lRet := .F.
				EndIf
				If lRet .and. cHrFim == cHrIni
					Help(Nil,	Nil,STR0029+alltrim(upper(Procname())),; //"RENTAL: "
							Nil,STR0033,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
							{STR0404}) //"A hora inicial deve ser diferente da hora final."
					lRet := .F.
				EndIf
			EndIf
		EndIf

		If lRet .and. cHrIni > "2400"
			Help(Nil,	Nil,STR0029+alltrim(upper(Procname())),; //"RENTAL: "
							Nil,STR0033,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
							{STR0406}) //"A hora inicial é inválida."
			lRet := .F.
		EndIf

		If lRet .and. cHrFim > "2400"
			Help(Nil,	Nil,STR0029+alltrim(upper(Procname())),; //"RENTAL: "
							Nil,STR0033,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
							{STR0407}) //"A hora final é inválida."
			lRet := .F.
		EndIf

		If lRet
			For nX := 1 to Len(oDlgTur:aCols) 
				If !(oDlgTur:aCols[nX][len(oDlgTur:aHeader)+1])

					If oDlgTur:nAt <> nX
						cHrIni2 := oDlgTur:aCols[nX, GDFIELDPOS("FPE_HRINIT", oDlgTur:aHeader)]
						cHrFim2 := oDlgTur:aCols[nX, GDFIELDPOS("FPE_HOFIMT", oDlgTur:aHeader)]
						cDiaSem2 := oDlgTur:aCols[nX, GDFIELDPOS("FPE_DIASEM", oDlgTur:aHeader)]
						
						If cHrIni2 == "2400"
							cHrIni2 := "0000"
						EndIf

						If lRet .and. cDiaSem == cDiaSem2
							// Hora inicial não pode estar entre inicial2 e final2, mas pode ser igual a final2
							If cHrIni >= cHrIni2 .and. cHrIni < cHrFim2
								lRet := .F.
							EndIf
							// Hora final não pode estar entre inicial2 e final2
							If cHrFim >= cHrIni2 .and. cHrFim <= cHrFim2
								lRet := .F.
							EndIf
							If !lRet
								Help(Nil,	Nil,STR0029+alltrim(upper(Procname())),; //"RENTAL: "
								Nil,STR0033,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
								{STR0408+ALLTRIM(STR(NX))}) //"Conflito de horários com a linha: "
								lRet := .F.
							exit
							EndIf
						EndIf

					EndIf
				EndIf
			Next
		EndIf
	EndIF

Return lRet


/*/{PROTHEUS.DOC} LOCA001T04
ITUP BUSINESS - TOTVS RENTAL - GRAVACAO DOS REGISTROS DO TURNO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
/*/

//Function LOCA001T04(cAlias, aHeader, aCols)	
Function LOCA001T04(cAlias)	
local npos
local aArea := getarea()
Local cProjet
Local cObra
Local cSeq
Local cFrota
Local cTurno
Local cHrInit
Local cHoFimt
Local nX
Local cCampo
Local cConteudo

	If valtype(oDlgTur) == "O"

		(cAlias)->(dbSetOrder(1))

		If nFolderTur <> OFOLDER:NOPTION
			LOCA001T05("ENTRANDO")
		EndIf
		
		LOCA001T05("SAINDO")

		if nOpc != 5  

			// Buscar no array original para verificar se exclui o registro antigo
			// O que estava anteriormente gravado que foi alterado, vamos primeiramente excluir
			For nX := 1 to len(oTurno_orig)
				cProjet := oTurno_orig[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_PROJET"})]
				cObra := oTurno_orig[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_OBRA"})]
				cSeq := oTurno_orig[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_SEQGUI"})]
				cFrota := oTurno_orig[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_FROTA"})]
				cTurno := oTurno_orig[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_TURNO"})]
				FPE->(dbSetOrder(1))
				if FPE->(dbSeek(xFilial(cAlias)+cProjet+cObra+cFrota+cSeq+cTurno))
					FPE->(RecLock("FPE"),.F.)
					FPE->(dbDelete())
					FPE->(MsUnlock())
				EndIf
			Next

			For nPos := 1 TO len(oTur_cols)

				If oTur_cols[nPos][len(oDlgTur:aHeader)+1] .or. file("\SYSTEM\248E1.TXT")
					Loop
				EndIf

				cProjet := oTur_cols[nPos][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_PROJET"})]
				cObra := oTur_cols[nPos][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_OBRA"})]
				cSeq := oTur_cols[nPos][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_SEQGUI"})]
				cFrota := oTur_cols[nPos][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_FROTA"})]
				cTurno := oTur_cols[nPos][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_TURNO"})]
				cHrInit := oTur_cols[nPos][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_HRINIT"})]
				cHoFimt := oTur_cols[nPos][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_HOFIMT"})]
		
				If !empty(cHrInit)
					RecLock("FPE",.T.)
					For nX := 1 to len(oDlgTur:aHeader)
						cCampo := alltrim(oDlgTur:aHeader[nX,2])
						cConteudo := oTur_cols[nPos][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])==cCampo})]
						cCampo := "FPE->"+cCampo
						&(cCampo) := cConteudo
					Next	
					FPE->FPE_FILIAL := xFilial("FPE")
					FPE->(MsUnlock())
				EndIf
			Next

			// Apos a gravacao de todos os itens da FPE
			// Valiar se a FP1, ou FPA foram deletados
			cProjeto := FP0->FP0_PROJET
			FPE->(dbSetOrder(1))
			FPE->(dbSeek(xFilial("FPE")+cProjeto))
			FP1->(dbSetOrder(1))
			FPA->(dbSetOrder(1))
			While !FPE->(Eof()) .and. FPE->(FPE_FILIAL+FPE_PROJET) == xFilial("FPE")+cProjeto
				If !FP1->(dbSeek(xFilial("FP1")+FPE->(FPE_PROJET+FPE_OBRA)))	
					FPE->(RecLock("FPE",.F.))
					FPE->(dbDelete())
					FPE->(MsUnlock())
				Else
					If !FPA->(dbSeek(xFilial("FPA")+FPE->(FPE_PROJET+FPE_OBRA+FPE_SEQGUI)))	
						FPE->(RecLock("FPE",.F.))
						FPE->(dbDelete())
						FPE->(MsUnlock())
					EndIF
				EndIF
				FPE->(dbSkip())
			EndDo

		ENDIF
		
		RestArea(aArea)
		aSize(aArea,0)
		FwFreeArray(aArea)
	EndIF

Return Nil


/*/ LOCA001T05
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
USADO PARA O BCHANGE QUANDO SE SAI DA ABA FROTA
DSERLOCA-1982 - Frank em 30/04/2024
/*/
Function LOCA001T05(cVar)
Local nPos	
Local nPos2
Local ACOLS0
Local cProjeto
Local cObra
Local cSeq
Local lDeletada
Local nPosObra
Local nPosSeqgui
Local aAcumula := {}
Local nX
Local cFrota

	If valtype(oDlgTur) == "O"

		nPosObra := GDFIELDPOS("FPE_OBRA", oDlgTur:aHeader)
		nPosSeqgui := GDFIELDPOS("FPE_SEQGUI", oDlgTur:aHeader)

		If cVar=="ENTRANDO"
			oDlgTur:aCols := {}
			aCols := {}
			for nPos := 1 TO LEN(oTur_cols) 
				lDeletada := oTur_cols[nPos][len(aHeader)+1] 
				If lDeletada .or. file("\SYSTEM\248E2.TXT")
					Loop
				EndIf
				aCols0 := {}
				cProjeto := FP0->FP0_PROJET
				cObra := oTur_cols[nPos][ASCAN(oDlgTur:aHeader,{|X|ALLTRIM(X[2])=="FPE_OBRA"})]
				cSeq := oTur_cols[nPos][ASCAN(oDlgTur:aHeader,{|X|ALLTRIM(X[2])=="FPE_SEQGUI"})]
				If cProjeto == FP0->FP0_PROJET
					If cObra == oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_OBRA"})]
						If cSeq == oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_SEQGRU"})]
							For nPos2:=1 to len(oDlgTur:aHeader)
								aadd(aCols0,oTur_cols[nPos][nPos2])
							Next
							aadd(aCols0, lDeletada )
							aadd(aCols, aCols0)
						EndIf
					EndIf
				EndIf
			Next
			If len(aCols) == 0
				aCols0 := {}
				For nPos := 1 to len(oDlgTur:aHeader)
					aadd(aCols0,criavar(oDlgTur:aHeader[nPos,2]))
				Next
				aadd(aCols0 , .F.) 
				aadd(oDlgTur:aCols,aClone(aCols0))
				oDlgTur:aCols[1][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_PROJET"})] := FP0->FP0_PROJET
				oDlgTur:aCols[1][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_OBRA"})]   := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_OBRA"})]
				oDlgTur:aCols[1][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_SEQGUI"})] := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_SEQGRU"})]
				oDlgTur:aCols[1][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_FROTA"})]  := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_GRUA"})]
			Else
				oDlgTur:aCols := aClone(aCols)
				cFrota := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_GRUA"})]
				For nX := 1 to len(oDlgTur:aCols)
					oDlgTur:aCols[nX][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_FROTA"})] := cFrota
				Next
			EndIf

			// Atuazar o FPE_VALTUR
			For nX := 1 to len(oDlgTur:aCols)
				oDlgTur:aCols[nX][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_VALTUR"})] := odlgPla:aCols[odlgPla:nAt][ascan(odlgPla:aHeader,{|X|alltrim(X[2])=="FPA_VRHOR"})]
				oDlgTur:aCols[nX][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_VROPER"})] := (oDlgTur:aCols[nX][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_VALTUR"})]*(oDlgTur:aCols[nX][ASCAN(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_PORCEN"})]+100))/100
			Next

			oDlgTur:REFRESH()
		ElseIf cVar=="SAINDO"

			aAcumula := {}

			cObra := odlgPla:aCols[odlgPla:nAt][ascan(odlgPla:aHeader,{|X|alltrim(X[2])=="FPA_OBRA"})]
			cSeq := odlgPla:aCols[odlgPla:nAt][ascan(odlgPla:aHeader,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})]

			For nPos2 := 1 to len(oTur_cols)
				If oTur_cols[nPos2][nPosObra] <> cObra .or. oTur_cols[nPos2][nPosSeqgui] <> cSeq
					If !oTur_cols[nPos2][len(oDlgTur:aHeader)+1]
						aadd(aAcumula, oTur_cols[nPos2] )
					EndIF
				EndIf
			Next

			For nPos := 1 to len(oDlgTur:aCols)
				If oDlgTur:aCols[nPos][nPosObra] == cObra .and. oDlgTur:aCols[nPos][nPosSeqgui] == cSeq
					If !oDlgTur:aCols[nPos][len(oDlgTur:aHeader)+1]
						aadd(aAcumula, oDlgTur:aCols[nPos] )
					EndIf
				EndIf
			Next

			oTur_cols := aClone(aAcumula)

		EndIF
	EndIf

Return 

/*/ LOCA001T06
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
VALIDACOES PARA A ABA TURNOS
DSERLOCA-1982 - Frank em 30/04/2024
/*/
Function LOCA001T06(lcarrega)
Local lRet := .T.
Local nX
Local nY
Local cObra
Local cSeq
Local cTurno
Local lBranco := .F.
Local nLinha := 0
Local cHrIni

Default lCarrega := .T.

	If valtype(oDlgTur) == "O"

		If nFolderTur <> OFOLDER:NOPTION
			LOCA001T05("ENTRANDO")
		EndIf

		LOCA001T05("SAINDO")

		For nX := 1 to len(oTur_cols)
			If !oTur_cols[nX][len(oDlgTur:aHeader)+1]
				cObra := oTur_cols[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_OBRA"})]
				cSeq := oTur_cols[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_SEQGUI"})]
				cTurno := oTur_cols[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_TURNO"})]
				cHrIni := oTur_cols[nX][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_HRINIT"})]
				If empty(cTurno) .and. !empty(cHrIni) 
					lBranco := .T.
					nLinha := nX
				EndIf
				For nY := 1 to len(oTur_cols)
					If nX <> nY	.and. !empty(cObra)
						If !oTur_cols[nY][len(oDlgTur:aHeader)+1]
							If cObra == oTur_cols[nY][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_OBRA"})]
								If cSeq == oTur_cols[nY][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_SEQGUI"})]
									If cTurno == oTur_cols[nY][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_TURNO"})]
										lRet := .F.
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				Next
			EndIf
		Next

		if lBranco
			lRet := .F.
			Help(Nil,	Nil,STR0029+alltrim(upper(Procname())),; //"RENTAL: "
							Nil,STR0033,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
							{STR0660+alltrim(str(nLinha))}) //"Na aba turno, faltou o preenchimento do campo turno, linha: "
		Else
			If !lRet
				Help(Nil,	Nil,STR0029+alltrim(upper(Procname())),; //"RENTAL: "
							Nil,STR0033,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
							{STR0659}) //"Existem turnos com a mesma numeração, para a mesma obra e sequência na aba Turnos."
			EndIf
		EndIf

	EndIF

Return lRet

/*/ LOCA001T07
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
GATILHOS DO % TABELA FPE
DSERLOCA-1982 - Frank em 30/04/2024
/*/
Function LOCA001T07(cCampo)
Local nRet := 0
Local nValtur
Local nVrOper
Local nPorcen

	nValtur := 0
	nVrOper := 0
	nPorcen := 0

	If valtype(oDlgTur) == "O"
		If cCampo == "FPE_VROPER" 
			nValTur := oDlgTur:aCols[oDlgTur:nAt][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_VALTUR"})]
			nVrOper := M->FPE_VROPER
			//nPorcen := oDlgTur:aCols[oDlgTur:nAt][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_PORCEN"})] - 100
			// Calcular Percentual
			nRet := ((nVrOper / nValTur)*100)-100
		ElseIf cCampo == "FPE_PORCEN"
			nValTur := oDlgTur:aCols[oDlgTur:nAt][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_VALTUR"})]
			nVrOper := oDlgTur:aCols[oDlgTur:nAt][ascan(oDlgTur:aHeader,{|X|alltrim(X[2])=="FPE_VROPER"})]
			nPorcen := M->FPE_PORCEN + 100
			// Calcular VROPER
			nRet := ((nValTur * nPorcen)/100)
		EndIf
	EndIf
	
Return nRet

/*/ FSALVARTUR
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
FUNÇÃO COMPLEMENTAR DO LOCA001 PARA EFEITO DE SUBSTITUICAO DA ROTINA ANTIGA DOS TURNOS
Frank em 26/01/2025
/*/
Function FSALVARTUR
Return .T.

/*/ LOCA001DV1
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
FUNCAO PARA COMPARACAO DE HORARIOS
Frank em 26/01/2025
/*/
Function LOCA001DV1(cHrIni1, cHrFim1, cHrIni2, cHrFim2)
Local lRet := .T.
	Processa({|| lRet := LOCA001DV2(cHrIni1, cHrFim1, cHrIni2, cHrFim2)},"Validando o período") 
Return lRet

/*/ LOCA001DV2
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
FUNCAO PARA COMPARACAO DE HORARIOS
Frank em 26/01/2025
/*/
Function LOCA001DV2(cHrIni1, cHrFim1, cHrIni2, cHrFim2 )
Local lRet := .T.
Local cHoraTemp
Local dDataTemp
Local aPeriodo1 := {}
Local aPeriodo2 := {}
Local nX
Local nY

	ProcRegua(0)

	// Remover os : se existirem
	If at(":", cHrIni1) > 0
		cHrIni1 := substr(cHrIni1,1,2)+substr(cHrIni1,4,2)
	EndIf
	If at(":", cHrIni2) > 0
		cHrIni2 := substr(cHrIni2,1,2)+substr(cHrIni2,4,2)
	EndIf
	If at(":", cHrFim1) > 0
		cHrFim1 := substr(cHrFim1,1,2)+substr(cHrFim1,4,2)
	EndIf
	If at(":", cHrFim2) > 0
		cHrFim2 := substr(cHrFim2,1,2)+substr(cHrFim2,4,2)
	EndIf

	If cHrIni1 == "2400"
		cHrIni1 := "0000"
	EndIf
	If cHrIni2 == "2400"
		cHrIni2 := "0000"
	EndIf

	IncProc()
	SysRefresh()

	dDataTemp := dDataBase
	cHoraTemp := cHrIni1
	nHoraTemp := val(cHrIni1)
	While cHoraTemp <= cHrFim1
		aadd(aPeriodo1, {dDataTemp, cHoraTemp})
		nHoraTemp ++
		cHoraTemp := strzero(nHoraTemp,4,0)
	EndDo
	IncProc()
	SysRefresh()

	dDataTemp := dDataBase
	cHoraTemp := cHrIni2
	nHoraTemp := val(cHrIni2)
	While cHoraTemp <= cHrFim2
		aadd(aPeriodo2, {dDataTemp, cHoraTemp})
		nHoraTemp ++
		cHoraTemp := strzero(nHoraTemp,4,0)
	EndDo
	IncProc()
	SysRefresh()

	For nX := 1 to len(aPeriodo1)
		For nY := 1 to len(aPeriodo2)
			If aPeriodo1[nX,1] == aPeriodo2[nY,1] // Comparacao da data
				If aPeriodo1[nX,2] == aPeriodo2[nY,2] 
					lRet := .F.
				EndIf
			EndIf
		Next
	Next
	IncProc()
	SysRefresh()

	If !lRet .and. cHrFim1 == cHrIni2
		lRet := .T.
	EndIf
	If !lRet .and. cHrIni1 == cHrFim2
		lRet := .T.
	EndIf

Return lRet    
