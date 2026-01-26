#Include 'Protheus.ch'

Function TAFDPMPCON(aWizard, nTotal)

	Local cTxtSys := CriaTrab( , .F. ) + ".TXT"
	Local nHandle := MsFCreate( cTxtSys )

	Local cAgentReg := aWizard[1][5]              // Cod. Regulador ANP
	Local cMesRefer := Substr(aWizard[1][3],1,2)  // Mês Referência
	Local cAnoRefer := LTRIM(STR(aWizard[1][4]))  // Ano Referência

    Local nCont     := 0
	Local cStrTxt   := ""

	cStrTxt += StrZero(nCont,10)               //Contador Sequencial
    cStrTxt += StrZero(cAgentReg,10)           //Agente Regulado Informante
	cStrTxt += (cMesRefer+cAnoRefer)           //Mês de Referência (MMAAAA)
	cStrTxt += StrZero(nTotal,7)               //Total de Registros

	Begin Sequence
 		WrtStrTxt( nHandle, cStrTxt )
 		GerTxtDPMP( nHandle, cTxtSys, "CONTROLE" )
 		Recover
	End Sequence
Return
