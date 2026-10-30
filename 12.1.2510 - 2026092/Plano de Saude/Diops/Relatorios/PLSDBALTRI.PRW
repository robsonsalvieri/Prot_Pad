#Include "PlsdbAltri.Ch"
#Include "PROTHEUS.Ch"       


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ PLSDBALTRI	³ Autor ³ Roberto Arruda	³ Data ³ 03.03.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Trimestral - Inicio do processo				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Function PLSDBALTRI()

	Local lRet        	:= .T.
	Private aSelFil		:= {}
	
	If !Pergunte("PLSBALTRI",.T.)
		lRet := .F.
	Else
		If Empty(mv_par01) .OR. Empty(mv_par02) .OR. Empty(mv_par03)
			MsgInfo( STR0004, STR0005 ) //"É necessário informar todos os parâmetros!"#"Parâmetros obrigatórios"
			Return .F.
		Endif
		
		//Valida filial
		aSelFil := AdmGetFil()
//		aSetOfBook	:= CTBSetOf(mv_par03)
		
		lRet := Len(aSelFil) > 0
	endif
	
	If lRet
		PLSGerPla()
	EndIf
	
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ PLSGerPla	³ Autor ³ Roberto Arruda	³ Data ³ 03.03.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Trimestral - Geração de Dados 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGerPla()

Local lEnd			:= .F.
Local cArqTmp		:= ""
Local aSetOfBook	:= {}
local lImpAntLP := .F.
Local dDataLP		:= ""
local nDivide 		:= 1
Local lVlrZerado	:= .T.
Local lImpSint		:= .T.
Local cFilUser		:= ""
Local lRecDesp0 	:= .F.
Local cRecDesp		:= ""
Local dDtZeraRD		:= ""
Local cMoedaDsc		:= ""
local aSelFil		:= {}
local nCont 		:= 0
local aValores 	    := {}
local cDiretorio
Local nTotReg		:= 0

If ! ct040Valid( mv_par03 )
	Return .F.
Else
   aSetOfBook := CTBSetOf(mv_par03)
Endif

MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
	CTGerPlan(NIL, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CT7","","", Repl("Z", TamSx3("CT1_CONTA")[1])/*mv_par03,mv_par04*/,"",Repl("Z", TamSx3("CTT_CUSTO")[1]),"",Repl("Z", TamSx3("CTD_ITEM")[1]),"",Repl("Z", TamSx3("CTH_CLVL")[1]),"01"/*mv_par08 moeda*/,;
				/*mv_par10*/"1",aSetOfBook,/*mv_par12*/"",""/*mv_par13*/,""/*mv_par14*/,""/*mv_par15*/,;
				.F.,.F.,/*mv_par11*/3,,lImpAntLP,mv_par02,1,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
					OemToAnsi(OemToAnsi(STR0002)),; //Aguarde ...
					OemToAnsi(STR0001)) //Gerando CSV - Balancete Trimestral ...
					
	dbSelectArea("cArqTmp")	
				
//nCount := cArqTmp->(RecCount())
cArqTmp->(dbEval({|| nTotReg++ }))
cArqTmp->(dbGotop())

If alltrim(aSetOfBook[11]) <> ""

	nCount := 0
	
	While (cArqTmp)->(!Eof())
		
		if alltrim(cArqTmp->TIPOCONTA) == "1"
			nCount := nCount + 1
			aadd(aValores, alltrim(cArqTmp->CONTA) + ";" + alltrim(cArqTmp->DESCCTA)  + ";" +  alltrim(cvaltochar(cArqTmp->SALDOANT)) + ";" + ;
						    alltrim(cvaltochar(cArqTmp->SALDODEB))  + ";" +  alltrim(cvaltochar(cArqTmp->SALDOCRD)) + ";" + alltrim(cvaltochar(cArqTmp->SALDOATU)))
		endif
		
		(cArqTmp)->(dbSkip())
	enddo
	
	cDiretorio := PLSGerCSV("Balancete_"+ StrTran(dtoc(mv_par01), "/", "") + "_" + StrTran(dtoc(mv_par02), "/", "") +".csv", "", aValores)
	
	Set Filter To
	dbCloseArea()
	
	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIF
	
	MsgInfo(STR0003 + cDiretorio, "TOTVS" )//Geração Finalizada. O arquivo foi gerado em:
else	
	MsgInfo("É necessário vincular um plano referencial ao livro selecionado.", "TOTVS" )//Geração Finalizada. O arquivo foi gerado em:
endif

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³PLSGerCSV ³ Autor ³ Roberto Arruda        ³ Data ³ 14.03.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gerar CSV genérico.        								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNomeArquivo - Nome do arquivo CSV a ser gerado.           ³±±
±±³          ³ cColunas     - Nome das Colunas separado por ;             ³±±
±±³          ³ aValores     - Array com valores a serem gerados no .CSV   ³±±
±±³							  cada posição corresponde a uma linha no .CSV³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGerCSV(cNomeArquivo, cColunas, aValores)

	local cDirCsv := ""
	local nFileCsv := 0
	local nI
	
	cDirCsv := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
	nFileCsv := FCreate(cDirCsv+cNomeArquivo,0,,.F.)
	If nFileCsv > 0
		if len(cColunas) > 0
	    	FWrite(nFileCSV,cColunas+CRLF)
	    endif
	    
	    For nI := 1 TO Len(aValores)
	    	cNewStr	:= aValores[nI]
	    	While '.' $ cNewStr
	    		cNewStr	:= Stuff(cNewStr, At('.',cNewStr), 1, ',')
	    	EndDo
	        FWrite(nFileCSV,cNewStr+CRLF)
	    Next nI
	    FClose(nFileCSV)
	Else
	    MsgInfo("Não foi possível criar o arquivo: " + cDirCsv+cNomeArquivo, "TOTVS" )
	    Return('')
	EndIf
	
Return(cDirCsv+cNomeArquivo)
