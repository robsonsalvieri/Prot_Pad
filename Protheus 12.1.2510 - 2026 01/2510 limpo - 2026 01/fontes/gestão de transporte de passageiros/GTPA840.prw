#INCLUDE "GTPA840.ch"
#include 'TOTVS.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ GTPA840  ³ Autor ³João P. Pires    ³ Data ³23.10.2024  		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Contabilizacao OFF LINE (GIC)                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GTPA840()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaGTP - Transporte de Passageiros                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GTPA840( aParam, lAglutina, dDtIni, dDtFim, cAgeIni, cAgeFim, cFilIni, cFilFim)

Local aButtons       := {}
Local nOpca          := 0
Local bProcesso      := {|oSelf|nOpca:=1}
Local cDescription	 := STR0002 //"Este programa tem como finalidade gerar a Contabilizacao OFF LINE dos movimentos de Bilhetes (GIC) ... "
Local oTProces
Local lDigita		 := .F.

Private cCadastro    := STR0001 //"Contabilizacao OFF LINE de Bilhetes"

Default aParam		:= {}
Default lAglutina	:= .F.
Default dDtIni		:= ""
Default dDtFim		:= ""
Default cAgeIni		:= ""
Default cAgeFim		:= ""
Default cFilIni		:= ""
Default cFilFim		:= ""

	If ( Len(aParam) > 0) 

		RpcSetType(3)
		RpcClearEnv()
		RpcSetEnv(aParam[1],aParam[2])
		
		If Empty(dDtIni) .And. Empty(dDtIni)
			dDtIni		 := dDataBase - 1
			dDtFim		 := dDataBase - 1
		Else
			dDtIni		 := CTOD(dDtIni)
			dDtFim		 := CTOD(dDtFim)
		EndIf
		
		GTPA840Proc(Nil, lDigita, lAglutina, dDtIni, dDtFim, cAgeIni, cAgeFim, cFilIni, cFilFim)

		RpcClearEnv()
		
	Else		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega as perguntas selecionadas                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ mv_par01 - Mostra Lancamentos Contabeis ?  Sim Nao           ³
		//³ mv_par02 - Aglutina Lancamentos         ?  Sim Nao           ³
		//³ mv_par03 - Data Inicial   ?                                  ³
		//³ mv_par04 - Data Final     ?                                  ³
		//³ mv_par05 - Agencia Inicial ?       
		//³ mv_par06 - Agencia Final ?       
		//³ mv_par07 - Filial Inicial ?       
		//³ mv_par08 - Filial Final ?       
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		
		If ( Pergunte("GTA840",.T.) )

			lDigita   := IIF(MV_PAR01 == 1,.T.,.F.)
			lAglutina := IIF(MV_PAR02 == 1,.T.,.F.)
			dDtIni    := MV_PAR03				
			dDtFim    := MV_PAR04				
			cAgeIni   := AllTrim(MV_PAR05)
			cAgeFim   := AllTrim(MV_PAR06)
			cFilIni	  := AllTrim(MV_PAR07) 
			cFilFim   := AllTrim(MV_PAR08) 
		Else
			lRet := .F.
		EndIf

		ProcLogIni(aButtons,"GTPA840")

		oTProces := tNewProcess():New( "GTPA840" , cCadastro, bProcesso , cDescription, "GTA840")
		oTProces:SaveLog(OemToAnsi(STR0003)) //"Finalizado com sucesso."

		If nOpca == 1	

			If !(GIC->(FieldPos("GIC_LA")) > 0)
				
				Alert(STR0004) //"Banco de dados desatualizado!"

			Else
				FWMsgRun(, {|oSelf| GTPA840Proc(oSelf, lDigita, lAglutina, dDtIni, dDtFim, cAgeIni, cAgeFim, cFilIni, cFilFim)},STR0005,STR0006) //"Aguarde" "Contabilizando..."
			Endif

		EndIf

	EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    GTPA840Proc ³ Autor ³ João Pires ³ Data ³23.10.2024³          ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Processa Contabilizacao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³GTPA850                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function GTPA840Proc(oSelf, lDigita, lAglutina, dDtIni, dDtFim, cAgeIni, cAgeFim, cFilIni, cFilFim)

Local cQuery      := ''
Local cAliasNew   := ''
Local cArqTRB     := ''
Local cAgencia	  := ''
Local lCriaHead   := .T.
Local aFlagCTB    := {}
Local aArea       := GetArea()
Local dData       := dDataBase
Local aDadosDev	  := {}
Local nRecno	  := 0
Local cFilLog	  := cFilAnt
Local cFilAtual   := ""

Private nHdlPrv            				// Endereco do arquivo de contra prova dos lanctos cont.
Private lCriaHeader := .T. 				// Para criar o header do arquivo Contra Prova
Private cLoteGTP	:= "8888"           // Numero do lote para lancamentos do GTP
Private nTotal 		:= 0        		// Total dos lancamentos contabeis
Private cArquivo           				// Nome do arquivo contra prova

Default lDigita     := .F.
Default lAglutina   := .F.
Default cFilIni		:= ""
Default cFilFim		:= ""

cArqTRB := CriaTrab(Nil,.F.)
ProcLogIni({},"GTPA840")
ProcLogAtu("INICIO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona numero do Lote para Lancamentos do GTP             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cAliasNew := GetNextAlias()
cQuery := " SELECT GIC_DTVEND, GIC_STATUS, GIC_AGENCI, GIC_CHVBPE, GIC_FILNF, GIC.R_E_C_N_O_ AS NRECNO FROM "+RetSqlName('GIC') + " GIC WHERE "
cQuery += " GIC_STAPRO = '1' AND GIC_DTVEND BETWEEN '"+DTOS(dDtIni)+"' AND '"+DTOS(dDtFim)+"' "

If Empty(cFilIni) .AND. Empty(cFilFim)
	cQuery += " AND GIC_FILIAL = '"+xFilial('GIC')+"' "
Else
	cQuery += " AND GIC_FILNF BETWEEN '"+cFilIni+"' AND '"+cFilFim+"' "
Endif

cQuery += " AND GIC_LA <> 'S' AND GIC.D_E_L_E_T_ = ' ' "

If !Empty(cAgeFim)
	cQuery += " AND GIC_AGENCI >= '"+ALLTRIM(cAgeIni)+"' AND GIC_AGENCI <= '"+ALLTRIM(cAgeFim)+"' "
Endif
cQuery += " ORDER BY GIC_FILNF,GIC_DTVEND,GIC_AGENCI,GIC_STATUS DESC"
cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
TCSetField(cAliasNew,"GIC_DTVEND","D",8,0)

DBSelectArea('GIC')

While (cAliasNew)->(!Eof())
	dData  		:= (cAliasNew)->GIC_DTVEND
	cAgencia	:= (cAliasNew)->GIC_AGENCI
	lCriaHead  	:= .T.
	nTotal      := 0
	cFilAnt     := cFilLog
	If !Empty((cAliasNew)->GIC_FILNF)
		cFilAnt := (cAliasNew)->GIC_FILNF
	Endif
	cFilAtual := (cAliasNew)->GIC_FILNF

	While (cAliasNew)->(!Eof()) .And. cFilAtual == (cAliasNew)->GIC_FILNF .AND. dData == (cAliasNew)->GIC_DTVEND .And. cAgencia == (cAliasNew)->GIC_AGENCI
		IF lCriaHead
			nHdlPrv := HeadProva(cLoteGTP,"GTPA840",cUserName,@cArquivo)			
			lCriaHead := .F.
		ENDIF

		IF (cAliasNew)->GIC_STATUS == 'C'
			aDadosDev	:= {}
			RetDadosDev("",(cAliasNew)->GIC_CHVBPE, @aDadosDev) //Traz o bilhete de origem para pegar o recno
			nRecno := IIF(Len(aDadosDev) > 0, aDadosDev[7],0)
		ELSE
			nRecno := (cAliasNew)->NRECNO
		ENDIF

		If nRecno > 0 
			GIC->(dbGoTo(nRecno))
			aAdd( aFlagCTB, {"GIC_LA", "S", "GIC", (cAliasNew)->NRECNO, 0, 0, 0} )// Armazena em aFlagCTB para atualizar no modulo Contabil
			IF (cAliasNew)->GIC_STATUS $ 'V#T#I#E' 
				nTotal += DetProva(nHdlPrv,'G02',"GTPA840",cLoteGTP)
			ELSEIF (cAliasNew)->GIC_STATUS == 'C'
				nTotal += DetProva(nHdlPrv,'G01',"GTPA840",cLoteGTP)
			ENDIF
		EndIF 

		(cAliasNew)->(DBSkip())
	Enddo

	If nTotal > 0
		RodaProva(nHdlPrv,nTotal)
		
		//-- Envia para Lan‡amento Cont bil
		cA100Incl(cArquivo,nHdlPrv,3,cLoteGTP,lDigita,lAglutina,,dData,,@aFlagCTB)
		aFlagCTB := {} // Limpa o coteudo apos a efetivacao do lancamento

	Endif

Enddo
cFilAnt := cFilLog
ProcLogAtu("FIM")

RestArea(aArea)

If Select(cAliasNew) > 0
	(cAliasNew)->(DbCloseArea())	
EndIF 

Return Nil
