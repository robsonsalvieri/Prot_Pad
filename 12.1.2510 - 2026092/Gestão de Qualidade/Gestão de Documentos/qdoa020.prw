#INCLUDE "QDOA020.CH"
#INCLUDE "TOTVS.CH"

Static oCodigo := Nil
Static oDescr  := Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDOA020    ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Tipos de Documentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDOA020()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ SIGAQDO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³  Data  ³ BOPS ³Programador³ Alteracao                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³26/11/01³012341³Eduardo S. ³ Acertado para gravar corretamente a filial³±±
±±³        ³      ³           ³ corrente.                           	  ³±±
±±³22/03/02³ META ³Eduardo S. ³ Otimizacao e Melhorias na Rotina.         ³±±
±±³02/08/02³059419³Eduardo S. ³ Incluido o campo "Qtde Num Seq" utilizado ³±±
±±³        ³      ³           ³ na geracao do numero sequencial do Docto. ³±±
±±ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()

Local aRotina  := {{OemToAnsi(STR0001), "AxPesqui", 0,1,,.F.},; //"Pesquisar"
					{OemToAnsi(STR0002), "QD020Telas",0,2},; //"Visualizar"
					{OemToAnsi(STR0003), "QD020Telas",0,3},; //"Incluir"
					{OemToAnsi(STR0004), "QD020Telas",0,4},; //"Alterar"
					{OemToAnsi(STR0005), "QD020Telas",0,5}}  //"Excluir"

Return aRotina

Function QDOA020()

Private aRotina   := MenuDef()
Private cCadastro := OemToAnsi(STR0006) // "Cadastro Tipo de Documento"
Private nQaConpad := 7

DbSelectArea("QD2")
DbSetOrder(1)
DbGoTop()
mBrowse(006,001,022,075,"QD2")

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020Telas ³ Autor ³ Aldo Marini Junior ³ Data ³ 30/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Cadastro de Tipos de Documentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020Telas(ExpC1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Alias do Arquivo                                  ³±±
±±³           ³ ExpN1 - Registro Atual ( Recno() )                        ³±±
±±³           ³ ExpN2 - Opcao de selecao do aRotina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020Telas(cAlias,nReg,nOpc)
	
	Local aMemos      := {{"QD2_PROTOC", "QD2_MEMO1"}} // Texto Protocolo
	Local nI          := 0
	Local oQDOA020Aux := QDOA020AuxClass():New()

	Private aCols       := {}
	Private aGETS[0]
	Private aHeader     := {}
	Private aTELA[0][0]
	Private bCampo      :={|nCPO| Field( nCPO ) }
	Private cFilDep     := xFilial("QAD") // Utilizada no SXB
	Private lIntGPE     := If(GetMv("MV_QGINT",.F.,"N") == "S",.T.,.F.)
	Private nPosFil     := 0
	Private nUsado      := 0
	Private oGetNivResp := NIL
	Private oGetResp    := NIL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa campos MEMO                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI:=1 to Len(aMemos)
		cMemo := aMemos[nI][2]
		If ExistIni(cMemo)
			&cMemo := InitPad(GetSx3Cache(cMemo, "X3_RELACAO"))
		Else
			&cMemo := ""
		EndIf
	Next nI

	If nOpc == 3
		For nI := 1 To FCount()
			cCampo := Eval( bCampo, nI )
			lInit  := .f.
			If ExistIni( cCampo )
				lInit := .t.
				M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, "X3_RELACAO") )
				If ValType( M->&( cCampo ) ) = "C"
					M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, "X3_TAMANHO") )
				EndIf
				If M->&( cCampo ) == Nil
					lInit := .f.
				EndIf
			EndIf
			If !lInit
				M->&( cCampo ) := FieldGet( nI )
				If ValType( M->&( cCampo ) ) = "C"
					M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
				ElseIf ValType( M->&( cCampo ) ) = "N"
					M->&( cCampo ) := 0
				ElseIf ValType( M->&( cCampo ) ) = "D"
					M->&( cCampo ) := CtoD( "  /  /  " )
				ElseIf ValType( M->&( cCampo ) ) = "L"
					M->&( cCampo ) := .f.
				EndIf
			EndIf
		Next nI
		M->QD2_FILIAL:= xFilial("QD2")
	Else
		For nI := 1 To FCount()
			M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
		Next nI
	EndIf

	// Metodo que monta a estrutura da tela
	oQDOA020Aux:montaEstruturaDaTela(cAlias, nReg, nOpc)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³QDA020GrTP³ Autor ³ Eduardo de Souza      ³ Data ³ 20/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Tipo de Documentos                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QDA020GrTP(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA020GrTP(nOpc)

Local lRecLock:= .F.
Local nI      := 0

If nOpc == 3
	lRecLock:= .T.
EndIf

RecLock("QD2",lRecLock)
For nI := 1 TO FCount()
	FieldPut(nI,M->&(Eval(bCampo,nI)))
Next nI
MsUnLock()             
FKCOMMIT()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravacao das chaves dos Campos Memo na Inclusao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->QD2_MEMO1) .Or. nOpc == 4
	MSMM(QD2_PROTOC,,,M->QD2_MEMO1,1,,,"QD2","QD2_PROTOC")
	FKCOMMIT()
Endif

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QDA020Dele ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Exclusao de Tipos de Documentos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QDA020Dele()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QDA020Dele()

Local lRet:= .T.

If !Inclui
	CursorWait()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe algum documento cadastrado com o tipo de documento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDH->(DbGoTop())
	While QDH->(!Eof())
		If QDH->QDH_CODTP == M->QD2_CODTP
			lRet:= .F.
			Exit
		EndIf
		QDH->(DbSkip())
	EndDo		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe cadastrado alguma Pasta com o tipo de documento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	QDC->(DbGoTop())
	While QDC->(!Eof())
		If QDC->QDC_CODTP == M->QD2_CODTP
			lRet:= .F.
			Exit
		EndIf
		QDC->(DbSkip())
	EndDo
	CursorArrow()
EndIf

If lRet
	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe responsaveis cadastrados por tipo de documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QDD->(DbSeek(xFilial("QDD")+M->QD2_CODTP))
			While QDD->(!Eof()) .And. M->QD2_FILIAL + M->QD2_CODTP == QDD->QDD_FILIAL + QDD->QDD_CODTP
				RecLock("QDD",.F.)
				QDD->(DbDelete())
				MsUnlock()
				QDD->(DbSkip())
			Enddo
		EndIf		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe niveis obrigatorios cadastrados por tipo de documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QD5->(DbSeek(xFilial("QD5")+M->QD2_CODTP))
			While QD5->(!Eof()) .And. M->QD2_FILIAL + M->QD2_CODTP == QD5->QD5_FILIAL + QD5->QD5_CODTP
				RecLock("QD5",.F.)
				QD5->(DbDelete())
				MsUnlock()
				QD5->(DbSkip())
			Enddo
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se existe tipo de Documento         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If QD2->(DbSeek(xFilial("QD2")+M->QD2_CODTP))
			RecLock("QD2",.F.)
			QD2->(DbDelete())
			MsUnlock()
			MSMM(M->QD2_PROTOC,,,,2)
			QD2->(DbSkip())
		EndIf
	End Transaction		
Else
	Help(" ",1,"QD_DCTOEXT") // "Existem Documentos/Pastas associadas a este Tipo de Documento"
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020GrRsp ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava Responsaveis por Tipo de Documento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020GrRsp(ExpA1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo as informacoes iniciais do Acols   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020GrRsp(aColsAux,aHeadRsp)

Local nCnt   := 0
Local nCpo   := 0   
Local nPos01 := GdfieldPos("QDD_AUT"   ,aHeadRsp)
Local nPos02 := GdfieldPos("QDD_FILA"  ,aHeadRsp)
Local nPos03 := GdfieldPos("QDD_DEPTOA",aHeadRsp)
Local nPos04 := GdfieldPos("QDD_CARGOA",aHeadRsp)

nUsado:=Len(aHeadRsp)

Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Refaz o cadastro de responsaveis por tipo de documento            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If QDD->(DbSeek(xFilial("QDD")+M->QD2_CODTP))
		While QDD->(!Eof()) .And. M->QD2_FILIAL + M->QD2_CODTP == QDD->QDD_FILIAL + QDD->QDD_CODTP
			RecLock("QDD",.F.)
			QDD->(DbDelete())
			MsUnlock()
			QDD->(DbSkip())
		Enddo
	EndIf   
	DbSelectArea("QDD")
	DbSetOrder(1)
	For nCnt:= 1 To Len(aColsAux)
		If !aColsAux[nCnt,nUsado+1] // Verifica se o item foi deletado
		    IF !EMPTY(aColsAux[nCnt,1])
				If QDD->(DbSeek(xFilial("QDD")+M->QD2_CODTP+aColsAux[nCnt,nPos01]+aColsAux[nCnt,nPos02]+aColsAux[nCnt,nPos03]+aColsAux[nCnt,nPos04]))
					RecLock("QDD",.F.)
				Else
					RecLock("QDD",.T.)
				Endif			
				For nCpo := 1 To Len(aHeadRsp)
					If aHeadRsp[nCpo, 10] <> "V"
						QDD->(FieldPut(FieldPos(Trim(aHeadRsp[nCpo,2])),aColsAux[nCnt,nCpo]))
					EndIf
				Next nCpo
				QDD->QDD_FILIAL:= xFilial("QDD") //M->QD2_FILIAL
				QDD->QDD_CODTP := M->QD2_CODTP
				MsUnlock()   
				FKCOMMIT()
			Endif
		Else
			If QDD->(DbSeek(xFilial("QDD")+M->QD2_CODTP+aColsAux[nCnt,nPos01]+aColsAux[nCnt,nPos02]+aColsAux[nCnt,nPos03]+aColsAux[nCnt,nPos04]))
				RecLock("QDD",.F.)
				QDD->(DbDelete())
				MsUnlock()
				FKCOMMIT()
			Endif
		Endif
	Next nCnt
End Transaction
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020GrNiv ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava Niveis de Responsaveis                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020GrNiv(ExpA1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo as informacoes iniciais do Acols   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020GrNiv(AcolsAux,aHeadNiv)

Local nCnt  := 0
Local nCpo  := 0
Local nPos01:= GdFieldPos("QD5_AUT" ,aHeadNiv)

nUsado:=Len(aHeadNiv)

DbSelectArea("QD5")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Deleta os NIVEIS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt:= 1 To Len(AcolsAux)                                     
	If AcolsAux[nCnt,nUsado+1] // Verifica se o item foi deletado
		If QD5->(DbSeek(xFilial("QD5")+M->QD2_CODTP+AcolsAux[nCnt,nPos01]))
			RecLock("QD5",.F.)
			QD5->(DbDelete())
			MsUnlock()
			FKCOMMIT()
		Endif
	Endif	
Next nCnt		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava  os NIVEIS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCnt:= 1 To Len(AcolsAux)		
	If !AcolsAux[nCnt,nUsado+1] // Verifica se o item foi deletado
		If QD5->(DbSeek(xFilial("QD5")+M->QD2_CODTP+AcolsAux[nCnt,nPos01]))
			RecLock("QD5",.F.)
		Else
			RecLock("QD5",.T.)
		Endif
		For nCpo := 1 To Len(aHeadNiv)
			If aHeadNiv[nCpo, 10] <> "V"
				QD5->(FieldPut(FieldPos(Trim(aHeadNiv[nCpo,2])),AcolsAux[nCnt,nCpo]))
			EndIf
		Next nCpo
		QD5->QD5_FILIAL:= xFilial("QD5") //M->QD2_FILIAL
		QD5->QD5_CODTP := M->QD2_CODTP
		MsUnlock()       
		FKCOMMIT()
	Endif
Next nCnt

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020LinOk ³ Autor ³ Aldo Marini Junior ³ Data ³ 24/04/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Critica Linha Digitada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020LinOk()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020LinOk()

Local lRet     := .T.
Local nCnt     := 0
Local nCont    := 0
Local nPos0    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDD_AUT"	})
Local nPos1    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDD_FILA"	})
Local nPos2    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDD_DEPTOA"})
Local nPos3    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QDD_CARGOA"})
Local nPos4    := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) = "QD5_AUT" 	})
Local nPosAli  := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) $ "QDD_ALI_WT | QD5_ALI_WT" 	})
Local nPosDel  := Len(aCols[n])
Local nPosRec  := Ascan(aHeader,{ |X| Upper( Alltrim( X[ 2 ] ) ) $ "QDD_REC_WT | QD5_REC_WT" 	})

If !aCols[n,nPosDel]
	If nPos0 <> 0 .And. nPos1 <> 0 .And. nPos2 <> 0 .And. nPos3 <> 0
		Aeval(aCols,{|X| IF(!X[nPosDel],If(X[nPos0] == aCols[n,nPos0] .And. X[nPos1] == aCols[n,nPos1] .And. ;
									X[nPos2] == aCols[n,nPos2] .And. X[nPos3] == aCols[n,nPos3],nCont++,nCont),"") })
		If nCont > 1
			Help( " ", 1, "QALCTOJAEX" ) // Informacao ja Cadastrada
			Return .F.
		EndIf
	EndIf	
	If nPos4 <> 0
		nCont:= 0
		Aeval(aCols,{|X| IF(!X[nPosDel],If( X[nPos4] == aCols[n,nPos4],nCont++,nCont),"")})
		If nCont > 1
			Help( " ", 1,"QALCTOJAEX" ) // Informacao ja Cadastrada
			Return .F.
		EndIf
	EndIf
	
	For nCnt = 1 To Len(aHeader)
		If nCnt == nPosAli .Or. nCnt == nPosRec
			Loop
		EndIf
		If Empty(aCols[n,nCnt])
			If Lastkey() <> 27
				Help(" ",1,"QDA020BRA")
				lRet:= .F.
			EndIf
			Exit
		EndIf
	Next nCnt
EndIf

Return lRet

/*/{Protheus.doc} QD020CkRsp
Checa existencia de Responsavel cadastrado 
@type function
@version 1.0 - @author Aldo Marini Junior
@version 2.0 - @author rafael.hesse
@since 27/08/1998
@param 01 - cFilQD2, caracter, indica a filial do departamento na tabela QD2
@param 02 - cDepQD2, caracter, indica o departamento da tabela QD2
@return lRet, lógico, indica se existe responsável cadastrado
/*/
Function QD020CkRsp(cFilQD2, cDepQD2)
	Local aArea      := GetArea()
	Local cAliasQAA  := ""
	Local cFilQAAQAD := ""
	Local cFilQAD    := ""
	Local cQuery     := ""
	Local lRet       := .F.
	Local oQLTQueryM := Nil

	Default cDepQD2  := Iif(Type("M->QD2_DEPTO") == "C", M->QD2_DEPTO, QD2->QD2_DEPTO)
	Default cFilQD2  := Iif(Type("M->QD2_FILDEP") == "C", M->QD2_FILDEP, QD2->QD2_FILDEP)

	cFilQAD := xFilial("QAD",cFilQD2)
	
	If FindClass("QLTQueryManager")

		QAD->(DbSetOrder(1))
		If QAD->(DbSeek(cFilQAD+cDepQD2))  
			
			oQLTQueryM := QLTQueryManager():New()
			cFilQAAQAD := oQLTQueryM:MontaQueryComparacaoFiliaisComValorReferencia("QAA", "QAA.QAA_FILIAL", "QAD", cFilQAD)

			cQuery := " SELECT QAA.QAA_MAT "
			cQuery += " FROM " + RetSqlName("QAA") + " QAA "
			cQuery += " WHERE " + cFilQAAQAD      
			cQuery += 		" AND QAA.QAA_CC='" + cDepQD2 + "' "
			cQuery += 		" AND QAA.QAA_DISTSN = '1' "
			cQuery += 		" AND "+ QA_FilSitF(.T.,.T.)
			cQuery += 		" AND QAA.D_E_L_E_T_ = ' ' "

			cQuery 	  := oQLTQueryM:changeQuery(cQuery)
			cAliasQAA := oQLTQueryM:executeQuery(cQuery)
				
			lRet := (cAliasQAA)->(!Eof())
			(cAliasQAA)->(DbCloseArea())			

			IF !lRet
				MsgAlert(OemToAnsi(STR0013),STR0014)  //"O departamento informado deve ter no minimo um Usuario com distribuidor indicado !"###"Aviso"
			Endif	     	
		Else
			lRet := .F.
			Help(" ",1,"QD050CCNE")		                                    	
		EndIf

	Else
		//STR0017 - "Ambiente desatualizado."
		//STR0018 - "Atualize o path mais recente de expedição contínua do módulo SIGAQDO."
		Help(NIL, NIL, "NOQLTQueryManager", NIL, STR0017 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0018})
	EndIf

	RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QD020CkNiv ³ Autor ³ Aldo Marini Junior ³ Data ³ 27/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Checa existencia de Niveis de resposaveis cadastrado      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QD020CkNiv(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 - Alias do Arquivo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QDOA020                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020CkNiv(aColsAux)

Local lRet  := .T.
Local nPosE := AsCaN(aColsAux,{|x| X[1]="E" }) // Nivel de Elaborador
    
IF nPosE==0 
	lRet:= .F.
Else
	IF aColsAux[nPosE,LEn(aColsAux[nPosE])]  // Nao esta Deletado
		lRet:= .F.
 	Endif
EndIf

IF !lRet
	//STR0022 - Atenção
	//STR0023 - Não foi definido nenhum nível de elaboração para este tipo de documento.
	//STR0024 - Acesse a aba Níveis de Responsáveis e adicione um elaborador.
	Help(NIL, NIL, STR0022, NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0024})
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ QD020Final³ Autor ³Eduardo de Souza      ³ Data ³ 21/03/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida Finalizacao do Cadastro do Tipo de Documentos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD020Final(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao no Browse                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020Final(nOpc)

Local lRet:= .T.

If Obrigatorio(aGets,aTela)
	If nOpc == 3 .Or. nOpc == 4
		
		If oFolder:nOption == 2
			aColsResponsaveis := aClone(aCols)
		ElseIf oFolder:nOption == 3
			aColsNiveisResponsaveis := aClone(oGetNivResp:aCols)
		Endif
		
		lRet:= QD020CkNiv(aColsNiveisResponsaveis) .AND. QD020CkRsp(M->QD2_FILDEP, M->QD2_DEPTO)		
		IF lRet
			Begin Transaction
				QDA020GrTP(nOpc)
				QD020GrNiv(aColsNiveisResponsaveis,aHeadNiveisResponsaveis)
				QD020GrRsp(aColsResponsaveis,aHeadResponsaveis)
			End Transaction
		Endif
	ElseIf nOpc == 5
		lRet:= QDA020Dele()
	EndIf
Else
	lRet:= .F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD020VdSeq ³ Autor ³Eduardo de Souza      ³ Data ³ 02/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida os campos responsaveis pela sequencia do Documento. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD020VdSeq()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QD020VdSeq()

nTamDoc := TamSx3("QDH_DOCTO")[1]

If M->QD2_QSEQ <= 0 .And. !Empty(M->QD2_SIGLA)
	Help(" ",1,"QD020QSEQ") // "Para a utilizacao da numecao sequencial de documento e necessario informar a Quantidade de Sequencia que devera utilizar."
	Return .F.
EndIf

If Len(AllTrim(M->QD2_SIGLA))+M->QD2_QSEQ > nTamDoc
	Help(" ",1,"QD020SIGLA") // "A Sigla do Documento junto com a Quantidade da numeracao sequencial ultrapassam o tamanho do nome do Documento."
	Return .F.
EndIf

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³QD020OrAr  ³ Autor ³Telso Carneiro        ³ Data ³09/03/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Organiza o Array da Matriz de Responsabilidade             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QD020OrAr(aAux)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ QDOA020                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function QD020OrAr(aAux)
                              
//E -Elaboracao, R -Revisao , A -Aprovacao , H -Homologacao

AEval(aAux,{|X| X[1]:=IF(X[1]=="E","1",IF(X[1]=="R","2",IF(X[1]=="A","3",IF(X[1]=="H","4",X[1])))) })

aAux := aSort( aAux, , , {|x,y| x[1]<Y[1] } )                                    

AEval(aAux,{|X| X[1]:=IF(X[1]=="1","E",IF(X[1]=="2","R",IF(X[1]=="3","A",IF(X[1]=="4","H",X[1])))) })

Return(aAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QD020FGet º Autor ³Raafel S. Bernardi  º Data ³ 26/01/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o aHeader e Acols, utilizando a funcao FillGetDados  º±±
±±º          ³ para adequar as funcionalidades do Walk Thru               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ QDOA020                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QD020FGet(cAlias,nOpc)
Local cSeek
Local cWhile
Local lInclui  := .F.

aHeader := {}
aCols   := {}

If cAlias == "QDD"
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If !dbSeek(xFilial(cAlias)+M->QD2_CODTP) .And. (nOpc == 3 .Or. nOpc == 4)
		lInclui := .T.
	Endif

	cSeek  := QDD_FILIAL+QDD_CODTP
	cWhile := "QDD_FILIAL+QDD_CODTP"
	
	If !lInclui
		FillGetDados(nOpc,cAlias,1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
	  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	Else
		FillGetDados(nOpc,cAlias,1     ,      ,             ,         ,         ,          ,        ,      ,         ,lInclui,          ,        ,          ,           ,            ,)
	  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	EndIf
	
ElseIf cAlias == "QD5"
	dbSelectArea(cAlias)
	dbSetOrder(1)
	If !dbSeek(xFilial(cAlias)+M->QD2_CODTP) .And. (nOpc == 3 .Or. nOpc == 4)
		lInclui := .T.
	Endif

	cSeek  := QD5_FILIAL+QD5_CODTP
	cWhile := "QD5_FILIAL+QD5_CODTP"
	
	If !lInclui
		FillGetDados(nOpc,cAlias,1     ,cSeek ,{|| &cWhile},         ,         ,          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,)
	  //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	Else
		FillGetDados(nOpc,cAlias,1     ,      ,             ,         ,         ,          ,        ,      ,         ,lInclui,          ,        ,          ,           ,            ,)
	  //FillGetDados(nOpcao,Alias ,nOrdem,cSeek  ,bSeekWhile   ,uSeekFor ,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
	EndIf

EndIF
Return

/*/{Protheus.doc} QDOA020AuxClass
Classe agrupadora de métodos auxiliares do QDOA020
@author thiago.rover
@since 28/03/2024
@version 1.0
/*/
CLASS QDOA020AuxClass FROM LongNameClass

    METHOD new() Constructor
    
	METHOD calculaDimensoesTela()
	METHOD montaFolder()
	METHOD montaTelaNiveisResponsaveis(nOperation)
	METHOD montaTelaResponsaveis(nOperation)
	METHOD mudaDeAba(nAbaGot, nAbaLost, nOperation)
	METHOD montaEstruturaDaTela(cAlias, nRecno, nOperation)

ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author thiago.rover
@since 28/03/2024
@version 1.0
/*/
METHOD new() CLASS QDOA020AuxClass
Return Self


/*/{Protheus.doc} montaEstruturaDaTela
Método que monta a estrutura da tela de Tipo de Documento
@author thiago.rover
@since 28/03/2024
@version 1.0
@parametro 1 - cAlias, caracter, Alias da tabela
@parametro 2 - nRecno, numérico, Recno do registro atual
@parametro 3 - nOperation, numérico, operação atual
/*/
METHOD montaEstruturaDaTela(cAlias, nRecno, nOperation) CLASS QDOA020AuxClass
	
	Private aColsNiveisResponsaveis := {}
    Private aColsResponsaveis       := {}
    Private aHeadNiveisResponsaveis := {}
    Private aHeadResponsaveis       := {}
	Private aInfo                   := {}
	Private aObjects                := {}
	Private aPaginas                := {}
	Private aPosObj                 := {}
	Private aSize                   := MsAdvSize(.T.)
	Private aTitulos                := {}
	Private cCodigo                 := ""
	Private cDescricao              := ""
	Private nOpcGD                  := 0
	Private oDlg                    := NIL
	Private oFolder                 := NIL
	Private oSize                   := NIL
	Private oTipoDocto              := NIL

	aInfo := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3}

	If nOperation == 3 .Or. nOperation ==4
		nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
	Else
		nOpcGD := 0
	EndIf
   
	AAdd( aObjects, { 100, 100, .T., .T. } ) // Dados da Enchoice 
    aPosObj := MsObjSize( aInfo, aObjects, .T. ,.F.)

	// Monta o oSize
	self:calculaDimensoesTela()

    // STR0006 - Cadastro Tipo de Documento
	DEFINE MSDIALOG oDlg TITLE STYLE nOR( WS_VISIBLE, WS_POPUP ) FROM oSize:aWindSize[1],oSize:aWindSize[2] to oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
	
		// Monta o TFolder
		oFolder := self:montaFolder(nOperation)

		// Monta a tela Tipo de Documento
		oTipoDocto := MsmGet():New( "QD2", nRecno, nOperation,,,,,aPosObj[1], , , , , ,oFolder:aDialogs[1])
		oTipoDocto:oBox:Align := CONTROL_ALIGN_ALLCLIENT

		// Montagem da GetDados em ARRAY
		QD020FGet("QD5",nOperation)
		aHeadNiveisResponsaveis := aClone(aHeader)
		aColsNiveisResponsaveis := aClone(aCols)

		// Monta a tela Níveis de Responsáveis
	    self:montaTelaNiveisResponsaveis(nOperation)

		// Montagem da GetDados em ARRAY
		QD020FGet("QDD",nOperation)
		aHeadResponsaveis := aClone(aHeader)
		aColsResponsaveis := aClone(aCols)

		// Monta a tela Responsáveis
		self:montaTelaResponsaveis(nOperation)

	ACTIVATE MSDIALOG oDlg ON INIT ;
		EnchoiceBar(oDlg,{|| If(QD020Final(nOperation), oDlg:End(), .F.)}, ;
										   {||oDlg:End()})  CENTERED
RETURN NIL


/*/{Protheus.doc} calculaDimensoesTela
Método que monta o oSize
@author thiago.rover
@since 28/03/2024
@version 1.0
/*/
METHOD calculaDimensoesTela() CLASS QDOA020AuxClass

 	oSize := FwDefSize():New(.T.)
    oSize:AddObject("DIALOG",100,100,.T.,.T.)
    oSize:lProp := .T.
    oSize:aMargins := {3,3,3,3}
    oSize:Process()

RETURN

/*/{Protheus.doc} montaFolder
Método que monta o Folder
@author thiago.rover
@since 28/03/2024
@version 1.0
@parametro 1 - nOperation, numérico, Operação atual da tela 
@return oFolder
/*/
METHOD montaFolder(nOperation) CLASS QDOA020AuxClass

	Local aPaginas := {}
	Local aTitulos := {}

	//Montagem do folder
    Aadd(aTitulos,OemToAnsi(STR0019)) // STR0019 - TIPO DE DOCUMENTO
    Aadd(aTitulos,OemToAnsi(STR0020)) // STR0020 - RESPONSÁVEIS
    Aadd(aTitulos,OemToAnsi(STR0021)) // STR0021 - NÍVEIS DE RESPONSÁVEIS
    
    Aadd(aPaginas, STR0019) // STR0019 - TIPO DE DOCUMENTO
    Aadd(aPaginas, STR0020) // STR0020 - RESPONSÁVEIS 
    Aadd(aPaginas, STR0021) // STR0021 - NÍVEIS DE RESPONSÁVEIS

	oFolder := TFolder():New(oSize:GetDimension("DIALOG","LININI"), oSize:GetDimension("DIALOG","COLINI"),aTitulos,aPaginas,oDlg,,,, .T., .F.,oSize:GetDimension("DIALOG","XSIZE"),oSize:GetDimension("DIALOG","YSIZE"))
	oFolder:bSetOption := {|nPos| self:mudaDeAba(nPos,oFolder:nOption,nOperation)}
	oFolder:Align := CONTROL_ALIGN_ALLCLIENT

RETURN oFolder


/*/{Protheus.doc} montaTelaResponsaveis
Método que monta o tela dos responsáveis do tipo de documento
@author thiago.rover
@since 28/03/2024
@version 1.0
@parametro 1 - nOperation, numerico, operação
/*/
METHOD montaTelaResponsaveis(nOperation) CLASS QDOA020AuxClass

	Local cCampo     := ""
	Local lInit      := .T.
	Local nI         := 0

	// Posicionamento na tabela QDD
	DbSelectArea("QDD")
	QDD->(DbSetOrder(1))
	If nOperation == 3
		For nI := 1 To FCount()
			cCampo := Eval( bCampo, nI )
			lInit  := .f.
			If ExistIni( cCampo )
				lInit := .t.
				M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, "X3_RELACAO") )
				If ValType( M->&( cCampo ) ) = "C"
					M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, "X3_TAMANHO") )
				EndIf
			EndIf
			If !lInit
				M->&( cCampo ) := FieldGet( nI )
				If ValType( M->&( cCampo ) ) = "C"
					M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
				ElseIf ValType( M->&( cCampo ) ) = "N"
					M->&( cCampo ) := 0
				ElseIf ValType( M->&( cCampo ) ) = "D"
					M->&( cCampo ) := CtoD( "  /  /  " )
				ElseIf ValType( M->&( cCampo ) ) = "L"
					M->&( cCampo ) := .f.
				EndIf
			EndIf
		Next nI
		M->QDD_FILIAL:= xFilial("QDD")
	Else
		For nI := 1 To FCount()
			M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
		Next nI
	EndIf

	// Função que organizará o Acols da Grade de Responsaveis em: E, R, A, H
	aColsResponsaveis := QD020OrAr(aColsResponsaveis)

	// Montagem da GetDados
	aHeader := aClone(aHeadResponsaveis)
	aCols   := aClone(aColsResponsaveis)

	nPosFil := aScan(aHeadResponsaveis, { |x| AllTrim(x[2]) == "QDD_FILA"   })

    @ 004,006 SAY STR0009 SIZE 050,007 OF oFolder:aDialogs[2] PIXEL // STR0009 - Cod. Tipo Doc
    @ 011,006 MSGET oCodigo VAR cCodigo SIZE 042,008 OF oFolder:aDialogs[2] PIXEL
    oCodigo:lReadOnly:= .T.
    
    @ 004,105 SAY STR0010 SIZE 050,007 OF oFolder:aDialogs[2] PIXEL // STR0010 - Des. Tipo Doc
    @ 011,105 MSGET oDescr VAR cDescricao SIZE 118,008 OF oFolder:aDialogs[2] PIXEL
    oDescr:lReadOnly:= .T.

	oGetResp := MSGetDados():New(035,oSize:GetDimension("DIALOG","COLINI"),   ;
	                                 oSize:GetDimension("DIALOG","LINEND")-45,;
								     oSize:GetDimension("DIALOG","COLEND"),   ;
	                                 nOperation, "QD020LinOk","","",;
									 If(nOperation==2 .Or. nOperation==5,.F.,.T.),,,,10000000000000000,,,,,oFolder:aDialogs[2]) 
RETURN


/*/{Protheus.doc} montaTelaNiveisResponsaveis
Método que monta tela dos níveis de responsáveis do tipo de documento
@author thiago.rover
@since 28/03/2024
@version 1.0
@parametro 1 - nOperation, numerico, Operação atual da tela 
/*/
METHOD montaTelaNiveisResponsaveis(nOperation) CLASS QDOA020AuxClass

	Local nI := 0

	// Posicionamento na tabela QD5
    DbSelectArea("QD5")
	QD5->(DbSetOrder(1))
	If nOperation == 3
		For nI := 1 To FCount()
			cCampo := Eval( bCampo, nI )
			lInit  := .f.
			If ExistIni( cCampo )
				lInit := .t.
				M->&( cCampo ) := InitPad( GetSx3Cache(cCampo, "X3_RELACAO") )
				If ValType( M->&( cCampo ) ) = "C"
					M->&( cCampo ) := PADR( M->&( cCampo ), GetSx3Cache(cCampo, "X3_TAMANHO") )
				EndIf
			EndIf
			If !lInit
				M->&( cCampo ) := FieldGet( nI )
				If ValType( M->&( cCampo ) ) = "C"
					M->&( cCampo ) := Space( Len( M->&( cCampo ) ) )
				ElseIf ValType( M->&( cCampo ) ) = "N"
					M->&( cCampo ) := 0
				ElseIf ValType( M->&( cCampo ) ) = "D"
					M->&( cCampo ) := CtoD( "  /  /  " )
				ElseIf ValType( M->&( cCampo ) ) = "L"
					M->&( cCampo ) := .f.
				EndIf
			EndIf
		Next nI
		M->QD5_FILIAL:= xFilial("QD5")
	Else
		For nI := 1 To FCount()
			M->&( Eval( bCampo, nI ) ) := FieldGet( nI )
		Next nI
	EndIf

	// Função que organizará o Acols da Grade de Responsaveis em: E, R, A, H
	aColsNiveisResponsaveis := QD020OrAr(aColsNiveisResponsaveis)

	// Montagem da GetDados
	aHeader := aClone(aHeadNiveisResponsaveis)
	aCols   := aClone(aColsNiveisResponsaveis)
    
    @ 004,006 SAY STR0009 SIZE 050,007 OF oFolder:aDialogs[3] PIXEL // STR0009 - Cod. Tipo Doc
    @ 011,006 MSGET oCodigo VAR cCodigo SIZE 042,008 OF oFolder:aDialogs[3] PIXEL
    oCodigo:lReadOnly:= .T.
    
    @ 004,105 SAY STR0010 SIZE 050,007 OF oFolder:aDialogs[3] PIXEL // STR0010 - Des. Tipo Doc
    @ 011,105 MSGET oDescr VAR cDescricao SIZE 118,008 OF oFolder:aDialogs[3] PIXEL
    oDescr:lReadOnly:= .T.

	oGetNivResp := MSNewGetDados():New(035,oSize:GetDimension("DIALOG","COLINI"), ;
	                                 oSize:GetDimension("DIALOG","LINEND")-45, ;
									 oSize:GetDimension("DIALOG","COLEND"), ;
									 nOpcGD, ;
									 {||QD020LinOk()};
									 ,,"",,,10000000000000000,,,,oFolder:aDialogs[3],aHeader,aCols)
RETURN


/*/{Protheus.doc} mudaDeAba
Método que valida na mudança de aba
@author thiago.rover
@since 04/04/2024
@version 1.0
@parametro 1 - nAbaGot    - numérico, Posição próxima aba			  
@parametro 2 - nAbaLost   - numérico, Posição última aba 
@parametro 3 - nOperation - numérico, Operação atual da tela 
/*/
METHOD mudaDeAba(nAbaGot, nAbaLost, nOperation) CLASS QDOA020AuxClass
	Local aAreaAnt  := GetArea()
	Local lRetorno  := .T.

	If nAbaLost == 1 .AND. (nAbaGot == 2 .OR. nAbaGot == 3)
		lRetorno := Obrigatorio(aGets,aTela)
	ElseIf nAbaLost == 3
		lRetorno := QD020CkNiv(oGetNivResp:aCols)
	Endif

	If nAbaGot <> 1
		cCodigo    := M->QD2_CODTP
		cDescricao := Left(M->QD2_DESCTP,50)
	Endif

	// Recupera o conteúdo preenchido nas Grids(Responsaveis e Níveis de Responsaveis)
	If nAbaLost == 2
		aColsResponsaveis        := aClone(aCols)
	ElseIf nAbaLost == 3
	     aColsNiveisResponsaveis := aClone(oGetNivResp:aCols)
	Endif

	If nAbaGot == 3
		aCols   := aClone(aColsNiveisResponsaveis)
		aHeader := aClone(aHeadNiveisResponsaveis)
	ElseIf nAbaGot == 2
		aCols   := aClone(aColsResponsaveis)
		aHeader := aClone(aHeadResponsaveis)
	EndIf

	oCodigo:Refresh()
	oDescr:Refresh()

	RestArea(aAreaAnt)

RETURN lRetorno
