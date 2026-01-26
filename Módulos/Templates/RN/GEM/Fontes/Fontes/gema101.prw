#INCLUDE "gema100.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMA101   ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 20.07.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Manutencao das renegociacoes de vencimento de      ³±±
±±³          ³ parcelas.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³T_GEMA101()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GEMA101(cAlias,nReg,nOpc)

Local lA101Inclui := .F.
Local lA101Visual := .F.
Local lA101Altera := .F.
Local lA101Exclui := .F.
Local lContinua   := .T.
Local lOk         := .F.

Local nX          := 0
Local nOpcGD      := 0
Local nRecLIZ     := 0
Local cAlias2     := ""
Local nGetLin     := 0
Local aPosGet     := {}
Local aHeadVen    := {}
Local aColsVen    := {}
Local aSize       := {}
Local aObjects    := {}
Local aInfo       := {}
Local aPosObj     := {}
Local aButtons    := {}
Local aUsrButtons := {}
Local aArea       := GetArea()

Local oDlg 
Local oPanel1
Local oPainel
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGet5

Private aGets[0]
Private aTela[0][0]
Private oEnch 
Private oGetCVnd
Private aColsCVnd  
PRIVATE lNaoAltera

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (aRotina[nOpc][4] == 2)
		lA101Visual := .T.
	Case (aRotina[nOpc][4] == 3)
		Inclui		:= .T.
		Altera      := .F.
		lA101Inclui	:= .T.
	Case (aRotina[nOpc][4] == 4)
		Inclui      := .F.
		Altera		:= .T.
		lA101Altera	:= .T.
	Case (aRotina[nOpc][4] == 5)
		lA101Exclui	:= .T.
		lA101Visual	:= .T.
EndCase  
lNaoAltera := lA101Visuall

If (lA101Inclui .OR. lA101Altera .OR. lA101Exclui )
	nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
Else     
	nOpcGD := 0
EndIf

// caso exista a rotina, sera incluido os botoes especificos.
If ExistBlock("GMA101BTN")
	If ValType( aUsrButtons := ExecBlock( "GMA101BTN",.F., .F. ) ) == "A"
		aEval( aUsrButtons, { |x| aAdd( aButtons, x ) } )
	EndIf
EndIf
	
aDefFields := {"LIZ_NCONTR" ,"LIZ_REVISAO" ,"LIZ_DTNEG" ,"LIZ_TIPREG" , "LIZ_HIST"}
aCampos := t_GEMA100LizLoad( aDefFields )

RegToMemory( "LIZ" ,lA101Inclui )

dbSelectArea("SX3")
SX3->(dbSetOrder(1)) // X3_FILIAL+X3_CAMPO
SX3->(dbSeek("LJR"))
While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == "LJR"
	If X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel
		aAdd( aHeadVen ,{ TRIM(x3titulo()) ,AllTrim(x3_campo),x3_picture ;
		                 ,x3_tamanho       ,x3_decimal       ,x3_valid   ;
		                 ,x3_usado         ,x3_tipo          ,x3_arquivo ;
		                 ,x3_context       } )
	EndIf
	
	SX3->(dbSkip())
EndDo
                
// Busca todos os itens da condicao de venda para as alterações do dia de vencto
aColsVen := A101ItLoad( M->LIZ_NCONTR ,M->LIZ_REVISA ,aHeadVen ,lA101Visual )
	
If lA101Inclui
	M->LIZ_FILIAL := xFilial("LIZ")
	M->LIZ_DTNEG  := dDataBase
	M->LIZ_TIPREG := "2" // Vencimentos
EndIf

If !lA101Inclui
	If lA101Altera.Or.lA101Exclui
		If !SoftLock("LIZ")
			lContinua := .F.
		Else
			nRecLIZ := LIZ->(RecNo())
		Endif
		
		// verifica o status do contrato
		lContinua := T_GMContrStatus( LIZ->LIZ_NCONTRAT )
	EndIf
EndIf

If lContinua
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aObjects, { 100, 100, .T., .T. } )
	aAdd( aObjects, { 200, 200, .T., .T. } )
	aSize   := MsAdvSize()
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
                                                                              
	//
	// Painel 
	// 
	oPainel := TPanel():New( aPosObj[1,1] ,aPosObj[1,2] ,'' ,oDlg ,/*Fonte*/ ,.T. ,.T. ,,,aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1],.T.,.T. )
	
	nGetLin := 5
	aPosGet := MsObjGetPos( aSize[3]-aSize[1], 315,;
		                    {{003,028,160,185}} )
	
	@ nGetLin ,aPosGet[1,1] SAY OemToAnsi(aCampos[1,2] )             SIZE  72,16 PIXEL Of oPainel
	@ nGetLin ,aPosGet[1,2] MSGET oGet1 VAR &("M->"+aCampos[1,1])    SIZE  75,09 PIXEL Of oPainel WHEN aCampos[1,5]!="V" ;
	                        VALID a101Valid( aCampos[1] )  F3 aCampos[1,6] HASBUTTON
	oGet1:lReadOnly := lA101Visual
	
	@ nGetLin ,aPosGet[1,3] SAY OemToAnsi(aCampos[2,2] )             SIZE  72,16 PIXEL Of oPainel
	@ nGetLin ,aPosGet[1,4] MSGET oGet2 VAR &("M->"+aCampos[2,1])    SIZE  25,09 PIXEL Of oPainel WHEN aCampos[2,5]!="V"
	oGet2:lReadOnly := lA101Visual
	nGetLin += 12
	
	@ nGetLin ,aPosGet[1,1] SAY OemToAnsi(aCampos[3,2] )             SIZE  72,16 PIXEL Of oPainel 
	@ nGetLin ,aPosGet[1,2] MSGET oGet3 VAR &("M->"+aCampos[3,1])    SIZE  80,09 PIXEL Of oPainel WHEN aCampos[3,5]!="V"
	oGet3:lReadOnly := lA101Visual
	@ nGetLin ,aPosGet[1,3] SAY OemToAnsi(aCampos[4,2] )             SIZE  72,16 PIXEL Of oPainel 
	@ nGetLin ,aPosGet[1,4] COMBOBOX oGet4 VAR &("M->"+aCampos[4,1]) SIZE  80,09 PIXEL Of oPainel WHEN aCampos[4,5]!="V" ;
                            ITEMS aClone(aCampos[4,8]) 
	oGet4:lReadOnly := lA101Visual
	nGetLin += 12
	
	@ nGetLin ,aPosGet[1,1] SAY OemToAnsi(aCampos[5,2] )             SIZE  72,16 PIXEL Of oPainel 
	@ nGetLin ,aPosGet[1,2] GET oGet5 VAR &("M->"+aCampos[5,1])      SIZE 250,32 PIXEL Of oPainel WHEN aCampos[5,5]!="V" ;
	                        MULTILINE VALID a101Valid( aCampos[5] )  
	oGet5:lReadOnly := lA101Visual

	oPanel1 := TPanel():New(aPosObj[2,1],aPosObj[2,2],'',oDlg, ,.T.,.T.,, ,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1],.T.,.T. )
	
	oGetCVnd := MsNewGetDados():New(002,02,097,338,nOpcGD,"AllwaysTrue","AllwaysTrue",,,,9999,,,,oPanel1,aHeadVen,aColsVen)
	oGetCVnd:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetCVnd:lInsert := .F.
	oGetCVnd:lDelete := .F.
	oGetCVnd:refresh()

	If lA101Visual
		aAdd(aButtons,{"PMSDOC",{|| T_GMViewContr(M->LIZ_NCONTR,M->LIZ_REVISA ) } ,OemtoAnsi(STR0002),OemtoAnsi(STR0003) } )    //"Visualiza o Contrato"###"Contrato"
	EndIf

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||iIf( a101VldDlg( lA101Visual ,aCampos ,oGetCVnd ) ;
								                           ,(lOk := .T.,oDlg:End()) ,Nil ) ;
								                    },{||lOk := .F.,oDlg:End()},,aButtons) VALID lOk
  
	If lOk .AND. (lA101Inclui .Or. lA101Altera .Or. lA101Exclui)
		Begin Transaction
			A101Grava(lA101Altera,lA101Exclui,nRecLIZ)
		End Transaction
	EndIf
	
EndIf

RestArea( aArea )
	
Return( .T. )

//
// Valida os get do objeto painel 
//
Static Function A101Valid(aCampo)
Local lRet := .F.

	If Empty(&("M->"+aCampo[1]) )
		lRet := .T.
	Else
		If &(aCampos[1,7]) 
			RunTrigger(1,,,,aCampo[1])
			lRet := .T.
		EndIf
	EndIf
	
Return( lRet )	
  
//
// Valida os campos antes de sair da dialog
//
Static Function A101VldDlg( lA101Visual ,aCampos ,oGetCVnd )
Local nX     := 0
Local nCount := 0
Local cText  := ""
Local aHead  := aClone(oGetCVnd:aHeader)
Local aCols  := aClone(oGetCVnd:aCols)
Local lRet   := .T.

If ! lA101Visual
	For nX := 1 to len(aCampos)
		If aCampos[nX][9]
			If Empty(&("M->"+aCampos[nX][1]))
				lRet := .F.
				cText := aCampos[nX][2] + Space(50-Len(aCampos[nX][2]))
				Help(1," ","OBRIGAT",,cText,3,0)
				Exit
			EndIf
		EndIf
	Next nX
	
	If lRet
		nPos_NEWDAY := aScan( aHead ,{|aCol|AllTrim(aCol[2])=="LJR_NEWDAY"})
		nPos_OLDDAY := aScan( aHead ,{|aCol|AllTrim(aCol[2])=="LJR_OLDDAY"})
	
		nCount := 0
		For nX := 1 To len(aCols)
			If aCols[nX][nPos_OLDDAY] == aCols[nX][nPos_NEWDAY]
				nCount += 1
			EndIf
		Next nX
		If len(aCols) == nCount
			lRet := .F.
			Help(1," ","DATASIGUAIS",,STR0001,1,0) // dias nao foram alterados
		EndIf
	EndIf
EndIf
Return( lRet )

//
// Condicao de pagamento customizado do historico do contrato
//
Static Function A101ItLoad( cContrato ,cRevisa ,aHead ,lA101Visual )
Local nX    := 0
Local aCols := {}
Local aArea := GetArea()

//
// Visualiza a alteracao da data de vencimento
//
If lA101Visual
	aColsCVnd := {}
	dbSelectArea("LJR")
	LJR->(dbSeek(xFilial("LJR")+cContrato+cRevisa ) )
	While LJR->(!Eof()) .AND. xFilial("LJR")+cContrato+cRevisa == LJR->LJR_FILIAL+LJR->LJR_NCONTR+LJR->LJR_REVISA
		aadd(aCols     ,Array(Len(aHead)+1))
		aadd(aColsCVnd ,Array(Len(aHead)+1))
		
		For nX := 1 to Len(aHead)
			If ( aHead[nX][10] != "V")
				aCols[Len(aCols)][nX] := FieldGet(FieldPos(aHead[nX][2]))
			Else
				aCols[Len(aCols)][nX] := CriaVar(aHead[nX][2])
			EndIf
			aColsCVnd[Len(aCols)][nX] := aCols[Len(aCols)][nX]
			If !Empty(Posicione("SX3", 2, aHead[nX][2] , "x3CBox()") )
				aCols[Len(aCols)][nX] := QA_CBox(aHead[nX][2] ,aCols[Len(aCols)][nX])
			EndIf
			aCols[Len(aCols)][Len(aHead)+1] := .F.
		Next nX
	
		LJR->(dbSkip())
	
	EndDo

//
// busca na condicao de venda as datas de vencimento
//
Else                                
	// condicao de venda customizado
	aColsCVnd := {}
	dbSelectArea("LJO")
	LJO->(dbSeek(xFilial("LJO")+cContrato ) )
	While LJO->(!Eof()) .AND. xFilial("LJO")+cContrato == LJO->LJO_FILIAL+LJO->LJO_NCONTR
		aadd(aCols     ,Array(Len(aHead)+1))
		aadd(aColsCVnd ,Array(Len(aHead)+1))
		
		For nX := 1 to Len(aHead)
			If ( aHead[nX][10] != "V")
				Do Case
					Case aHead[nX][2] == "LJR_NEWDAY"
						aCols[Len(aCols)][nX] := FieldGet(FieldPos("LJO_DIAVEN"))
					Case aHead[nX][2] == "LJR_OLDDAY"
						aCols[Len(aCols)][nX] := FieldGet(FieldPos("LJO_DIAVEN"))
					OtherWise
						aCols[Len(aCols)][nX] := FieldGet(FieldPos("LJO"+SUBSTR(aHead[nX][2],4)))
				EndCase
			Else
				aCols[Len(aCols)][nX] := CriaVar(aHead[nX][2])
			EndIf
			
			aColsCVnd[Len(aCols)][nX] := aCols[Len(aCols)][nX]
			
			If !Empty(Posicione("SX3", 2, aHead[nX][2] , "x3CBox()") )
				aCols[Len(aCols)][nX] := QA_CBox(aHead[nX][2] ,aCols[Len(aCols)][nX])
			EndIf
			aCols[Len(aCols)][Len(aHead)+1] := .F.
		Next nX
	
		LJO->(dbSkip())
	
	EndDo
	
EndIf

If len(aCols) == 0
	aColsCVnd := {}
	aAdd(aCols ,Array(Len(aHead)+1))
	aAdd(aColsCVnd ,Array(Len(aHead)+1))
	
	dbSelectArea("LJR")
	For nX := 1 to Len(aHead)
		If LJR->(FieldPos(aHead[nX][2])) >0
			aCols[Len(aCols)][nX] := CriaVar(aHead[nX][2])
			aColsCVnd[Len(aCols)][nX] := aCols[Len(aCols)][nX]
			
			If !Empty(Posicione("SX3", 2, aHead[nX][2] , "x3CBox()") )
				aCols[Len(aCols)][nX] := QA_CBox(aHead[nX][2] ,aCols[Len(aCols)][nX])
			EndIf
		EndIf
		aCols[Len(aCols)][Len(aHead)+1] := .F.
	Next nX
EndIf

RestArea(aArea)

Return( aCols )

//
// Carrega o browse com alguns dados da condicao de pagamento
//
Template Function GEMA101PRC( cContrato )
Local aColsVen := {}
Local aHeadVen := aClone(oGetCVnd:aHeader)
Local aArea    := GetArea()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	dbSelectArea("LIT")
	LIT->(dbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
	If LIT->(dbSeek(xFilial("LIT")+cContrato))
	    // Carrega os itens da msnewgetdados
		aColsVen := A101ItLoad( cContrato ,"" ,aHeadVen ,.F. )
		oGetCVnd:aCols := aClone(aColsVen)
		oGetCVnd:refresh()
    EndIf

RestArea(aArea)
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A101Grava ³ Autor ³ Reynaldo Miyashita    ³ Data ³            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa os dados para atualizar o listbox de titulos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do Arquivo                                       ³±±
±±³          ³ExpN2: Numero do Registro                                     ³±±
±±³          ³ExpN3: Opcao do aRotina                                       ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A101Grava(lA101Altera,lA101Exclui,nRecLIZ)
Local bCampo     := {|n| FieldName(n) }
Local nCount     := 0
Local nCnt2      := 0
Local cCondVenda := ""
Local cNewRevisa := ""
Local aColsVen   := aClone(oGetCVnd:aCols)
Local aHeadVen   := aClone(oGetCVnd:aHeader)
Local aArea      := GetArea()
Local cFilLIX    := xFilial("LIX")

If ! lA101Exclui

	If ! lA101Altera
		// LIT - cadastro de contratos
		dbSelectArea("LIT")
		LIT->(dbSetOrder(2)) //LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+M->LIZ_NCONTR)
			// obtem o codigo da condicao de venda
			cCondVenda := LIT->LIT_COND
			cNewRevisa := Soma1(LIT->LIT_REVISA)

			//
			// Grava o Historico do contrato
			//
			t_GMHistContr( M->LIZ_NCONTR ,M->LIZ_REVISA ,cNewRevisa ,"" )
			
			//
			// Grava a renegociacao da data de vencimento
			//
			RecLock("LIZ",.T.)
				For nCount := 1 TO FCount()
					LIZ->(FieldPut(nCount,M->&(EVAL(bCampo,nCount))))
				Next nCount
			LIZ->(MsUnlock())
			
			// Grava os Titulos renegociados
			For nCount := 1 TO Len(aColsVen)
				
				// se foi escolhido novo dia para o vencimento
				If !(aColsVen[nCount,5]==aColsVen[nCount,6])

					// se o item nao foi deletado 
					If !aColsVen[nCount][len(aHeadVen)+1]
						dbSelectArea("LJR")
						RecLock("LJR" ,.T.)
							For nCnt2 := 1 TO len(aHeadVen)
								If !Empty(Posicione("SX3", 2, aHeadVen[nCnt2][2] , "x3CBox()") )
									LJR->(FieldPut(FieldPos(aHeadVen[nCnt2][2]) ,aColsCVnd[nCount][nCnt2] ))
								Else
									LJR->(FieldPut(FieldPos(aHeadVen[nCnt2][2]) ,aColsVen[nCount][nCnt2] ))
								EndIf
							Next nCount        
							LJR->LJR_FILIAL := xFilial("LJR")
							LJR->LJR_NCONTR := M->LIZ_NCONTR
							LJR->LJR_REVISA := M->LIZ_REVISA
						LJR->(MsUnlock())
					EndIf
					
					//
					// Atualiza o dia de vencimento
					//
					nPos_NewDay := aScan(aHeadVen ,{|xCampo|xCampo[2]=="LJR_NEWDAY"})
					nPos_ITEM   := aScan(aHeadVen ,{|xCampo|xCampo[2]=="LJR_ITEM"})
					If nPos_NewDay > 0 .AND. nPos_ITEM > 0
						dbSelectArea("LJO")
						LJO->(dbSetOrder(1)) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
						If LJO->(dbSeek(xFilial("LJO")+M->LIZ_NCONTR+aColsVen[nCount][nPos_ITEM]))
							RecLock("LJO" ,.F.)
								LJO->LJO_DIAVEN := aColsVen[nCount][nPos_NewDay]
							LJO->(MsUnlock())
						EndIf
					EndIf
					
					// Detalhes do titulo a receber
					dbSelectArea("LIX")
					dbSetOrder(4) // LIX_FILIAL + LIX_NCONTR + LIX_CODCND + LIX_ITCND
					dbSeek(cFilLIX+LIT->LIT_NCONTR+cCondVenda+LJR->LJR_ITEM)
					While LIX->(!Eof()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND) == cFilLIX+LIT->LIT_NCONTR+cCondVenda+LJR->LJR_ITEM
						// titulos a receber
						dbSelectArea("SE1")
						dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO))
							// Altera a data de vencimento, somente dos titulo que nao foram baixados 
							// e não estao vencidos, isto e´ Mes/ano do titulo a vencer deve ser maior que a data de vencimento
							If SE1->E1_SALDO == SE1->E1_VALOR .AND. left(dtos(LIX->LIX_DTVENC),6) > left(dtos(dDatabase),6)
								// 
								RecLock("SE1",.F.)
									// verifica se o dia existe pro mes/ano do vencimento do titulo a receber
									// Se nao existir o dia, assume o ultimo dia do mes
									If LJR->LJR_NEWDAY > Day(lastDay(LIX->LIX_DTVENC))
										SE1->E1_VENCTO  := stod(left(dtos(LIX->LIX_DTVENC),6)+strZero(Day(lastDay(LIX->LIX_DTVENC)),2) )
									Else
										SE1->E1_VENCTO  := stod(left(dtos(LIX->LIX_DTVENC),6)+strZero(LJR->LJR_NEWDAY,2) )
									EndIf
									SE1->E1_VENCREA := DataValida(SE1->E1_VENCTO)
									
								SE1->(MSUnLock())
								
								RecLock("LIX",.F.)
									LIX->LIX_DTVENC := SE1->E1_VENCTO
								LIX->(MSUnLock())
								
							EndIf
						Endif
						dbSelectArea("LIX")
						dbSkip()
					EndDo

				EndIf

			Next nCount
			
		EndIf
	EndIf
Endif

RestArea(aArea)

Return( .T. )
