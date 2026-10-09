
#include "PLSMGER.CH"
#include "PLSA164.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA164 ³ Autor ³ Tulio Cesar          ³ Data ³ 09.04.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Tipos de Saida                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA164

Private cRet  := ""                   
                     
					 

Private aRotAdic := {{"Vinculo TISS" , "MsgRun('','Vínculo TISS',{||PLVINCTIS('BIY',BIY->BIY_CODSAI, 1)})", 0,2},;
				     {"Excluir Vinculo TISS" , "MsgRun('',,{||PLVINCTIS('BIY',BIY->BIY_CODSAI, 0)})", 0,2}}

AxCadastro("BIY", PLSRETTIT("BIY"), "PLSA164Del()", "PLSA164Int(nOpc)", aRotAdic)

	
Return




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA256Del ³ Autor ³ 				      ³ Data ³ 13.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao de exclusao Tabelas do modulo Gestão Hospitalar    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA164Del()
LOCAL lRet := .T.
Local lEspelhar := GetNewPar("MV_INTSAIP",.F.)  // Parametro integração entre Tabelas GH e PLS   

If lEspelhar
	DbSelectarea ("GF4")
	GF4->(DbSetOrder(1))
	If GF4->(MsSeek(xFilial("GF4")+BIY->BIY_CODSAI)) .and. HS_A16DOK()
		DbSelectarea ("BBL")
		BBL->(DbSetOrder(2))
		If BBL->(MsSeek(xFilial("BBL")+"PLSA164   "+"BIY"+"GF4")) 
			RecLock("GF4", .F.)
			DbDelete()
			MsUnlock()
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
			Endif
		Endif
	
	Endif
Endif
Return(lRet)





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA164Int ³ Autor ³ 				      ³ Data ³ 13.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteracao/Inclusão  Tabelas do Modulo GH com Sincronismo       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA164Int(nOpc)
Local lRet 		:= .T.
Local lAchou	:=.F.
local lNovGF4   := .T.
Local lEspelhar := GetNewPar("MV_INTSAIP",.F.)  // Parametro integração entre Tabelas GH e PLS   

If nOpc == 3
	If lEspelhar
		If  ! Empty(M->BIY_CODSAI)
			DbSelectarea ("GF4")
			GF4->(DbSetOrder(1))
			lNovGF4 := (GF4->(MsSeek(xFilial("GF4")+M->BIY_CODSAI)))
		Else
			lNovGF4 := .T.
		Endif
	Endif
	
	If  ! LNovGF4
		DbSelectarea ("BBL")
		BBL->(DbSetOrder(2))
		If 	BBL->(MsSeek(xFilial("BBL")+"PLSA164   "+"BIY"+"GF4"))
			RecLock("GF4", .T.)
			GF4->GF4_FILIAL := xFilial("GF4")
			PlsSinc("PLSA164   ","BIY","GF4")
			GF4->GF4_LOGARQ := HS_LOGARQ()
			MsUnlock()
		Else
			If GetNewPar("MV_PLSMSGS","1") == "1"
				MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
			Endif
		Endif
	Endif
ElseIf nOpc == 4
	If lEspelhar
		DbSelectarea ("GF4")
		GF4->(DbSetOrder(1))
		If BIY->(FieldPos("BIY_REFIGH"))>0
			If !Empty(M->BIY_REFIGH) .and. GF4->(MsSeek(xFilial("GF4")+M->BIY_REFIGH)) 
				lAchou:= HS_A16DOK(nOpc)  // Função para Validação de Sincronismo no Gestão Hospitalar
			Else
				lAchou:= GF4->(MsSeek(xFilial("GF4")+M->BIY_CODSAI))
			Endif
			If lAchou
				DbSelectarea ("BBL")
				BBL->(DbSetOrder(2))
				If 	BBL->(MsSeek(xFilial("BBL")+"PLSA164   "+"BIY"+"GF4"))
					RecLock("GF4", .F.)
					PlsSinc("PLSA164   ","BIY","GF4")
					GF4->GF4_LOGARQ := HS_LOGARQ()
					MsUnlock()
				Else
					If GetNewPar("MV_PLSMSGS","1") == "1"
						MsgAlert(OemtoAnsi(STR0001)) //"Arquivo de sincronismo entre BIY x GF4 nao esta integro. Verifique!"
					Endif
					
				Endif
			Endif
		Endif
	Endif
Endif
Return(lRet)


Function PLSTIPFAT()
	Local MvPar 	 
	Local aAux 	     := StrTokArr(X3CBox( Posicione('SX3',2,"BE4_TIPFAT",'X3_CBOX') ),';')
	lOCAL cTitulo    := "Tp Faturamen"
	Local cMvParDef  := ""
	Local nI         := 0
	Local MvRet      := Alltrim(ReadVar())
	Local aRet       := {}

	For nI:=1 To Len(aAux)
		If !(SubStr(aAux[nI],1,1) $ 'T/P')
			AADD(aRet,(aAux[nI]))
		EndIf
	Next 
	
	MvPar := &(Alltrim(ReadVar()))		 
	MvRet := Alltrim(ReadVar())			 

	iF f_Opcoes(@MvPar,cTitulo,@aRet,@cMvParDef,NIL,NIL,.F.,NIL,,.F.,.F.,,.F.,.F.,.t.)

		&MvRet:= ""

		For nI:=1 To Len(MvPar)
			&MvRet+= SubStr(MvPar[nI],1,1)
		Next nI

		cRet:=PadR(Alltrim(&MvRet),TamSx3("BIY_TPFTIN")[1])

	EndIf

Return .t.

Function PLSVLTFAT(cTipAlt,cTipFat)
	Local cSQL       := ""   
	Local lCps       := BIY->(FieldPos("BIY_TPFTIN"))>0	
	Local lOK        := .T.
	Local lInclui    := IIF(ValType(inclui)="L" .And. inclui, .T.,.F.)
	
	If !lCps .Or.  FUNNAME() <> 'PLSA498' .Or. GetNewPar("MV_PLSUNI", "0") == "0" .Or. IIF(lInclui,M->BE4_CODEMP <> GetNewPar("MV_PLSGEIN","0050") .And. !Empty(M->BE4_CODEMP),BE4->BE4_CODEMP <> GetNewPar("MV_PLSGEIN","0050") .And. !Empty(BE4->BE4_CODEMP)) 
		Return .t.
	EndIF

	If lCps .And. GetNewPar("MV_PLSUNI", "0") == "1" .And. FUNNAME() == 'PLSA498' 

		iF Empty(cTipAlt)
			MsgInfo("Favor informar o Motivo de Saída primeiro. ")
			Return .F.
		EndIf 

		cSql := "SELECT BIY_TPFTIN RET FROM " + RetSqlName("BIY") + ""
		cSql += " WHERE BIY_FILIAL = '" + xFilial("BIY") + "'"
		cSql += "   AND BIY_CODOPE   = '" + PLSINTPAD() + "'"
		cSql += "   AND BIY_CODSAI   = '" + cTipAlt + "'"
		cSql += "   AND D_E_L_E_T_ = ' ' "

		cRet := Alltrim(MPSysExecScalar(cSql, "RET"))

		If !(Alltrim(cTipFat) $ cRet)
			lOk := .F.
			MsgInfo("Tipo de faturamento utilizado está incorreto! Analise os Tipos possíveis no cadastro de Motivos de Saída.")
		EndIf

	EndIf 


Return lOk
