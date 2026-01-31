#INCLUDE "PROTHEUS.CH"
#INCLUDE "GEMA142.CH"

// .: Indices :.
// LK5	1	LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
// LK5	2	LK5_FILIAL+LK5_STRPAI+LK5_STRUCT
// LK5	3	LK5_FILIAL+LK5_STRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEMA142  ³ Autor ³ Cristiano Denardi     ³ Data ³ 26.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro das estruturas do empreendimentos LK5             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMA142( cAlias,nReg ,nOpc ,aGetCpos )

Local aArea      := GetArea()
Local lContinua  := .T.
Local lOk        := .F.
Local nX         := 0
Local oDlg       := Nil
Local oGetCodEmp := Nil
Local oGetStrPai := Nil
Local aMasc      := {}
Local cDescr     := ""
Local cNomCpo	 := ""
Local oSize
Local a1stRow    :=  {}

Private cCodigo  := ""
Private cCodSup  := ""

Default nOpc     := 3

INCLUI := nOpc == 3
ALTERA := nOpc == 4

RegToMemory("LK5", INCLUI )

If aGetCpos <> Nil
	For nX := 1 to Len(aGetCpos)
		cCpo	:= "M->"+AllTrim(aGetCpos[nx][1])
		&cCpo	:= aGetCpos[nx][2]
	Next nx
EndIf
	
cCodigo := M->LK5_STRUCT
cDescr  := T_GEM142Nom(M->LK5_CODEMP,@aMasc)

If INCLUI
	lContinua := T_GEM142Pai( M->LK5_CODEMP ,M->LK5_STRPAI ,aMasc )
Endif

If lContinua

	DbSelectArea("LK3")
	DbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
	DbSeek(xFilial("LK3")+LK5->LK5_CODEMP )  
	
							
	//Defino o tamanho dos componentes através do método FwDefSize(), amarrando ao objeto oDlg
	oSize := FwDefSize():New(.T.)
	
	oSize:lLateral := .F.
	oSize:lProp := .T.
	
	oSize:AddObject("MASTER",100,100,.T.,.T.)
	
	oSize:Process()
	
	a1stRow := {oSize:GetDimension("MASTER","LININI"),;
				oSize:GetDimension("MASTER","COLINI"),;
				oSize:GetDimension("MASTER","LINEND"),;
				oSize:GetDimension("MASTER","COLEND")}
	
	
	DEFINE MSDIALOG	oDlg TITLE OemToAnsi(STR0001); //"Estrutura do Empreendimento"
							FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]  OF oMainWnd PIXEL	   
							          
	M->LK5_ESTRUT := cDescr
	M->LK5_PREVHB := LK3->LK3_PREVHB
	M->LK5_HABITE := LK3->LK3_HABITE	
	
	oMsMGet	  := MsMGet():New(cAlias,nReg,nOpc,,,,,{a1stRow[1] + 7 ,a1stRow[2] + 2  ,a1stRow[3] ,a1stRow[4]},,,,,,oDlg,,.T.)
	
	///a1stRow[1] + 35 ,a1stRow[2] + 2  ,a1stRow[3] ,a1stRow[4] 
	////{10,0,400,700}
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| iIf( GEMA142Vld(nOpc),(lOk:=.T.,oDlg:End()),)},{||oDlg:End()} ) CENTER
	
	If lOk .And. nOpc <> 2
		IF VldGemSrt(M->LK5_CODEMP,M->LK5_STRPAI,M->LK5_STRUCT,M->LK5_PREVHB,M->LK5_HABITE,M->LK5_DESCRI,aMasc)
			T_GEM142Grav(nOpc)   
		ELSE
			lOk := .F.
		EndIf
	Endif
	
EndIf

RestArea( aArea )
Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEM142Nom³ Autor ³ Cristiano Denardi     ³ Data ³ 26.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Simula gatilho para o Nome.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEM142Nom( cCod, aMsc )

Local aArea := GetArea()
Local cDescr := ""

dbSelectArea("LK3")
dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
If MsSeek( xFilial("LK3") + cCod  )
	cDescr := LK3->LK3_DESCRI
	If aMsc <> Nil
		aMsc := T_GEMmascCnf( LK3->LK3_MASCAR )
	Endif
Endif

RestArea( aArea )

Return( cDescr )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEM142Pai³ Autor ³ Cristiano Denardi     ³ Data ³ 26.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Simula gatilho para o Satrutura Pai.							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                 
Template Function GEM142Pai( cEmpr ,cCod, aMsc )

Local aArea 	:= GetArea()
Local lRet		:= .T.
Local nNvMax	:= 0 

DEFAULT cEmpr := ""
DEFAULT cCod  := ""
DEFAULT aMsc  := {}

If !Empty(cEmpr) .and. !Empty(cCod) .and. len(aMsc)>1
                                 
	nNvMax	:= Len( aMsc[2] )
	
	dbSelectArea("LK5")
	dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
	If MsSeek( xFilial("LK5") + cEmpr + cCod )
		M->LK5_NIVEL := Soma1(LK5->LK5_NIVEL)
	Endif
	//////////////////////////////////////////////////////////////////
	// Nao pode incluir uma estrutura em nivel exclusivo para Unidades
	// Esse nivel foi definido pelo cadastro de Mascaras LK2
	// Por convencao, o ultimo nivel sempre sera exclusivo da unidade.
	If Val(M->LK5_NIVEL) == nNvMax
		lRet := .F.
		MsgAlert(	STR0002	+; //"Nao e permitido incluir uma estrutura no nivel definido para unidades. "
					STR0003	,; //"Favor verificar a configuracao da mascara usada no Empreendimento."
					STR0004) //"Atencao!"
	Endif
	                
	//////////////////////////////
	// Verifica Codigos Superiores
	If lRet .And. Empty(cCodSup)
		dbSelectArea("LK5")
		dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
		If MsSeek( xFilial("LK5") + cEmpr + cCod )
			cCodSup := Alltrim(LK5->LK5_STRUCT) + aMsc[2][Val(LK5->LK5_NIVEL)][3]
		Else
			cCodSup := ""
		Endif
			
		///////////////////////////////////////
		// Sugere Codigo para nivel da inclusao
		cCodigo := cCodSup
		cCodigo += StrZero( 0 ,aMsc[2][Val(M->LK5_NIVEL)][2])
	Endif
EndIf
RestArea( aArea )
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GEMVldCod³ Autor ³ Cristiano Denardi     ³ Data ³ 26.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Codigo da Estrutura.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                                 
Static Function GEMVldCod( cEmpr ,aMsc )

Local aArea 	:= GetArea()
Local lRet		:= .T.
Local nA		:= 0
Local nTamTot	:= 0

//////////////////////////////
// Valid 1.
// Se cCodSup nao foi deletado
If cCodSup <> SubStr( cCodigo, 1, Len(cCodSup) )
	lRet := .F.
	MsgAlert( STR0005, STR0004 ) //"Somente acrescente ao final o codigo da estrutura, nao retire codigos superiores."###"Atencao!"
Endif
 
////////////////////////////////
// Valid 2.
// Se qtde de digitos para nivel
// atual possui conforme mascara
If lRet
	For nA := 1 To Val(M->LK5_NIVEL)
		nTamTot := nTamTot + aMsc[2][nA][2] 
		If nA <> Val(M->LK5_NIVEL)
			nTamTot := nTamTot + Len(aMsc[2][nA][3])     
		Endif
	Next nA                            
	If Len(Alltrim(cEmpr)) <> nTamTot
		lRet := .F.
		MsgAlert( 	STR0006+Upper(aMsc[1][1])+STR0007,; //"Tamanho do Codigo esta invalido, verifique o nivel para esta mascara: "###" ."
						STR0004 ) //"Atencao!"
	Endif
Endif

//////////////////////////////
// Valid 3.
// Se codigo ja foi cadastrado
If lRet
	dbSelectArea("LK5")
	dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
	If MsSeek( xFilial("LK5") + cEmpr+cCodigo )
		lRet := .F.
		MsgAlert( STR0008, STR0004 ) //"Ja existe uma estrutura com esse codigo, favor ecolher outro."###"Atencao!"
	Endif
Endif

RestArea( aArea )
Return( lRet )

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GEM140Grav³ Autor ³ Cristiano Denardi     ³ Data ³ 19.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa de Gravacao - Incl./Alter                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA130                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEM142Grav( nOpc )

Local   lFind     := .T.
Local   bCampo    := {|nCampo| Field(nCampo) }
Local   nPosField := 0
Local   cCodigo   := M->LK5_STRUCT

Default nOpc  :=  3

DbSelectArea("LK5")
DbSetOrder(1) // LK5_FILIAL + LK5_CODEMP + LK5_STRUCT
	
Begin Transaction 

	If !(nOpc == 5)
	
		///////////////////////////////
		// Grava para Incluir ou Editar
		If nOpc == 3 .OR. nOpc == 4
			If nOpc == 3
				lFind := .T.
			Else
				lFind := !MsSeek( xFilial("LK5") + M->LK5_CODEMP + cCodigo )
			Endif
			
			RecLock("LK5",lFind)
				For nPosField := 1 to fCount()
					FieldPut( nPosField ,M->&(Eval(bCampo,nPosField)))
				Next nPosField
				LK5->LK5_FILIAL	:= xFilial("LK5")
				LK5->LK5_STRUCT	:= cCodigo
			MsUnLock()
			
			// grava nas estrutura e unidades filhas
			Aux142Grav( LK5->LK5_CODEMP ,LK5->LK5_STRUCT )
			
	    EndIf
		
	Else
		// Excluir as estruturas e unidades inferiores da atual
		// e inclusive a propria
		MaDelLK5( ,,LK5->(recno()) )
	EndIf
End Transaction

Return

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Aux142Grav³ Autor ³ Reynaldo Miyashita    ³ Data ³ 19.04.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava as estrutura filhas e unidades filhas                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GEMA142                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Aux142Grav( cEmpr ,cStrPai )
Local aAreaLK5  := LK5->(GetArea())
Local aAreaLIQ  := LIQ->(GetArea())
Local dHabite   := stod("")

	dbSelectArea("LK5")
	dbSetOrder(3) // LK5_FILIAL+LK5_CODEMP+LK5_STRPAI
	If MsSeek(xFilial("LK5")+cEmpr+cStrPai)
	
		RecLock("LK5",.F.,.T.)
			LK5->LK5_PREVHB := M->LK5_PREVHB
			LK5->LK5_HABITE := M->LK5_HABITE
		MsUnlock()
	
		Aux142Grav( LK5->LK5_CODEMP ,LK5->LK5_STRUCT )
		
	EndIf
		
	// deve verificar os campos chaves de estrutura e unidade para serem atualizados
	dbSelectArea("LIQ")
	dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
	dbSeek(xFilial("LIQ")+cEmpr+cCodigo )
	While !Eof() .AND. xFilial("LIQ")+cEmpr+cStrPai == LIQ->LIQ_FILIAL+LIQ->LIQ_CODEMP+LIQ->LIQ_STRPAI
	
		If LIQ->LIQ_PREVHB <> M->LK5_PREVHB .or. LIQ->LIQ_HABITE <> M->LK5_HABITE
			RecLock("LIQ",.F.)
				LIQ->LIQ_PREVHB := M->LK5_PREVHB
				LIQ->LIQ_HABITE := M->LK5_HABITE
			MsUnLock()
			
			If LIQ->LIQ_STATUS == "CA"
				dbSelectArea("LIU")
				dbSetOrder(2) // LIU_FILIAL+LIU_CODEMP
				If dbSeek(xFilial("LIU")+LIQ->LIQ_COD)
					dbSelectArea("LIT")
					dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
					If dbSeek(xFilial("LIT")+LIU->LIU_NCONTR)
						
						dHabite := iIf( Empty(LIQ->LIQ_HABITE) ,LIQ->LIQ_PREVHB ,LIQ->LIQ_HABITE )
						t_GMPRCContr( dHabite ,,LIT->(Recno()) )
						
					EndIf
				EndIf
			EndIf
			
		EndIf
		
		dbSelectArea("LIQ")
		LIQ->( dbSkip() )
	EndDo

RestArea(aAreaLIQ)	
RestArea(aAreaLK5)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GEMA142Vld³ Autor ³ Reynaldo Miyashita    ³ Data ³ 12.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a dialog                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GEMA142Vld( nOpc )
Local lRetorno := .T.
    
	// excluir estrututura
	If (nOpc == 5)
		// verifica se todas as unidades não estao reservadas ou com contrato assinado.
		lRetorno := !LK5Status( ,,LK5->(recno()) )
	EndIf

Return( lRetorno )


//
// Exclui a Estrutura e as estruturas / tarefas filhas
//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LK5Status ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 12.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a estrutura tem unidades vendidas ou reservadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LK5Status( cEmpr ,cStruct ,nRecLK5 )
Local aArea	:= GetArea()
Local aAreaLK5	:= LK5->(GetArea())
Local lContinua	:= .T.
Local lSeek	:= .F.

dbSelectArea("LK5")
If nRecLK5<>Nil
	dbGoto(nRecLK5)
	cEmpr   := LK5->LK5_CODEMP
	cStruct := LK5->LK5_STRUCT
Else
	dbSetOrder(1) // LK5_CODEMP+LK5_STRUCT
	lContinua	:= MsSeek(xFilial("LK5")+cEmpr+cStruct)
	nRecLK5		:= RecNo()
EndIf

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de registros no LK5 e efetua a exclusao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("LK5")
	dbSetOrder(3) //LK5_CODEMP+LK5_STRPAI
	MsSeek(xFilial("LK5")+cEmpr+cStruct)
	While !Eof() .And. xFilial("LK5")+cEmpr+cStruct==;
		LK5->LK5_FILIAL+LK5->LK5_CODEMP+LK5->LK5_STRUCT
		
		lSeek := LK5Status( ,,LK5->(RecNo()))
		
		dbSelectArea("LK5")
		dbSkip()
	EndDo
	
	If !lSeek
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia de registros no LIQ e efetua a exclusao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("LIQ")
		dbSetOrder(4) // LIQ_FILIAL+LIQ_CODEMP+LIQ_STRPAI
		MsSeek(xFilial("LIQ")+cEmpr+cStruct)
		While !Eof() .And. xFilial("LIQ")+cEmpr+cStruct==;
			LIQ->LIQ_FILIAL+LIQ->LIQ_CODEMP+LIQ->LIQ_STRPAI
			If LIQ->LIQ_STATUS == "RE" .OR. LIQ->LIQ_STATUS == "CA"
				MsgAlert(STR0009)//"Unidades não podem ser excluidas. Existem unidades com reserva ou com contrato assinado."
				lSeek := .T.
				Exit
			EndIf
			
			dbSelectArea("LIQ")
			dbSkip()
		EndDo
	EndIf
EndIf	
	
RestArea(aAreaLK5)
RestArea(aArea)

Return( lSeek )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GMPRCContr³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.05.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa que verifica e recalcula o valor das parcelas        ³±±
±±³          ³ baseado no Habite-se, se necessario                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GMPRCContr( dHabite ,cContrato ,nRecLIT )
Local aArea    := GetArea()
Local aAreaLIT := LIT->(GetArea())
Local aAreaLJO := LJO->(GetArea())
Local aAreaLFD := LFD->(GetArea())
Local aAreaLIX := LIX->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local nCnt      := 0
Local nQtd      := 0
Local nSldDev   := 0
Local nIntervalo:= 0 
Local nCntConj  := 0
Local nPos      := 0
Local aRegs     := {}
Local aConjunto := {}
Local aConjRegs := {}
Local lProcessa := .T.
Local lContinua := .T.
Local dVencto   := stod("")
Local dJurINI   := stod("")
Local cAnoMes   := ""
Local aTipoSist := {}
Local nOrdem := 0
Local cIndex := ""
Local cChave := ""
Local nIndex := 0

DbSelectArea("LIX")
nOrdem := LIX->(IndexOrd())
cIndex := CriaTrab(nil,.f.)
cChave := "LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND+LIX_ITNUM"
IndRegua("LIX",cIndex,cChave,,, ) //"Selecionando Registros..."
nIndex := RetIndex("LIX")
dbSelectArea("LIX")
#IFNDEF TOP
	dbSetIndex(cIndex+ordBagExt())
#ENDIF

	//
	// se nao foi informado o no. registro, procura pelo contrato.
	//
	If nRecLIT == NIL
		nRecLIT := 0
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+cContrato)
			nRecLIT := LIT->(Recno())
		EndIf
	EndIf
	
	If nRecLIT > 0 
		dbSelectArea("LIT")
		dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
		dbGoTo(nRecLIT)
		
		If LIT->(FieldPos("LIT_FECHAM")) > 0
			cAnoMes := LIT->LIT_FECHAM
		Else
			cAnoMes := GetMV("MV_GMULTFE")
		EndIf
		
		//
		// habite superior ao mes/ano de CM
		//
		If !Empty(dHabite) .and. left(dtos(dHabite),6) >= cAnoMes
			//***************************************************************************
			// Verifica a condicao de venda do contrato
			//*************************************************************************** 
			dbSelectArea("LJO")
			dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
			dbSeek( xFilial("LJO")+LIT->LIT_NCONTR )
			While LJO->(!Eof()) .and. LJO->LJO_FILIAL+LJO->LJO_NCONTR == xFilial("LJO")+LIT->LIT_NCONTR
			
				lProcessa := .F.
				lContinua := .F.
				aRegs     := {}
				
				//***************************************************************************
				// Verifica os Tipos de parcela para saber o intervalo
				//***************************************************************************
				dbSelectArea("LFD")
				dbSetOrder(1) // LFD_FILIAL+LFD_COD
				If dbSeek(xFilial("LFD")+LJO->LJO_TIPPAR)
					nIntervalo := LFD->LFD_INTERV
					// se for uma parcela do tipo C-Chaves, altera a data de vencimento da parcela
					If LFD->LFD_TIPO == "C"
						If dtos(dHabite)<>dtos(LJO->LJO_1VENC)
							RecLock("LJO",.F.)
								// Ajusta a data do vencimento com a data do habite-se
								LJO->LJO_1VENC := dHabite
							MSUnLock()

							dbSelectArea("LIX")
							dbSetOrder(4) // LIX_FILIAL + LIX_NCONTR + LIX_CODCND + LIX_ITCND
							If dbSeek(xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND)+LJO->LJO_ITEM)
								RecLock("LIX",.F.)
									// Ajusta a data do 1vencimento com a data do habite-se
									LIX->LIX_DTVENC := dHabite
								MSUnLock()
								
								dbSelectArea("SE1")
								dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
								If dbSeek(xFilial("SE1")+LIX->LIX_PREFIXO+LIX->LIX_NUM+LIX->LIX_PARCEL+LIX->LIX_TIPO)
									RecLock("SE1",.F.)
										// Ajusta a data do 1vencimento com a data do habite-se
										SE1->E1_VENCTO  := dHabite
										SE1->E1_VENCREA := DataValida(SE1->E1_VENCTO,.T.)
									MSUnLock()
								EndIf
							EndIf
						EndIf
					EndIf
		
					//
					// Se existe o habite e for diferente do juros inicio.
					//
					If !Empty(LJO->LJO_JurIni) .AND. dtos(dHabite)<>dtos(LJO->LJO_JurIni)
						RecLock("LJO",.F.)
							// se Juros Inicio e Mes/Ano for diferente calcula o Juros Inicio
							LJO->LJO_JurIni := t_GMIniJur(dHabite)
						MSUnLock()
					EndIf
					
					dVencto   := stod("")
					dJurINI   := LJO->LJO_JurIni
					nQtd      := 0
					nSldDev   := 0
					aRecSE1   := {}
					aRecLIX   := {}
				
					//***************************************************************************
					// Verifica o detalhamento dos titulos a receber
					//****************************************************************************
					dbSelectArea("LIX")
					dbSetOrder(nIndex+1) // LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND+LIX_ITNUM
					DbGoTop()
//					dbSetOrder(4) // LIX_FILIAL + LIX_NCONTR + LIX_CODCND + LIX_ITCND
					dbSeek(xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND)+LJO->LJO_ITEM)
					While LIX->(!eof()) .AND. ;
						LIX->(LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND) == ;
				 	    xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND)+LJO->LJO_ITEM
						
				 	 	// se a data de CM deve ser maior que o vencimento
				 	 	// e ser provisorio
//						If (left(dtos(LIX->LIX_DTVENC),6) > cAnoMes )

							//***************************************************************************
							// Verifica os titulos a receber
							//***************************************************************************
							dbSelectArea("SE1")
							dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
							If dbSeek(xFilial("SE1")+LIX->LIX_PREFIXO+LIX->LIX_NUM+LIX->LIX_PARCEL+LIX->LIX_TIPO)
					 	        // Se existe saldo e o mes/ano de emissao do titulo for menor que o mes/ano de CM, calcula a CM
								If SE1->E1_SALDO > 0
									aAdd( aRegs ,{SE1->(Recno()) ,LIX->(Recno())} )
									If Empty(dVencto) .or. dVencto > DataValida(LIX->LIX_DTVENC,.T.)
										dVencto := LIX->LIX_DTVENC
									EndIf
/*									If Empty(dVencto)
										dVencto := GemGetVecto(LIX->LIX_NCONTR,LIX->LIX_CODCND, LIX->LIX_PARCEL, LIX->LIX_ITCND,LIX->LIX_ITNUM,(nIndex+1))
										If Empty(dVencto)
											dVencto := LIX->LIX_DTVENC
										Endif
									elseif dVencto > DataValida(LIX->LIX_DTVENC,.T.)
										dVencto := LIX->LIX_DTVENC
									EndIf*/
									nSldDev += LIX->LIX_ORIAMO
									nQtd++
								EndIf
							EndIf
//						EndIf
						
						dbSelectArea("LIX")
						dbSkip()
					EndDo
					
					// Nao existe parcelas, naum precisa calcular.
					If nQtd > 0                                                            
						aaDD(aTipoSist, LJO->LJO_TPSIST)
						// gera os titulos de acordo com o sistema de amortizacao escolhida.
						aTitulos := T_GMGeraTit( LJO->LJO_TPSIST ,dVencto ,LJO->LJO_TAXANO ,nIntervalo ;
						                        ,nQtd ,nSldDev , ,0 ,LJO->LJO_TPPRIC ,dJurINI )
						
						//
						aAdd( aConjunto ,{ LJO->LJO_ITEM ;
						                  ,LJO->LJO_TIPPAR ;
						                  ,LJO->LJO_TPDESC ;
						                  ,iIf(LFD->(FieldPos("LFD_EXCLUS"))>0,iIf(Empty(LFD->LFD_EXCLUS),"2",LFD->LFD_EXCLUS),"2") ;
						                  ,LFD->LFD_INTERV ;
						                  ,aTitulos } )
						aAdd( aConjRegs ,{LJO->LJO_ITEM ,aRegs} )
					EndIf
				EndIf
				
				dbSelectArea("LJO")
				dbSkip()
			EndDo
            
			// reordena as datas das parcelas
			GMPRCPARC( @aConjunto )
			
			If Len(aConjunto) > 0
			
				For nCntConj := 1 to Len(aConjunto)
				    
					aRegs    := aclone( aConjRegs[nCntConj ,02] )
					If (nPos := aScan( aConjunto, {|x|x[1] == aConjRegs[nCntConj ,01] } )) >0 
						aTitulos := aclone( aConjunto[nPos ,06] )
						
						For nCnt := 1 to Len(aRegs)
							//
							// Detalhes dos titulos a receber 
			  				//
							dbSelectArea("LIX")
							dbGoto(aRegs[nCnt,2])
							RecLock("LIX" ,.F.)
								LIX->LIX_DTVENC := aTitulos[nCnt,2]
								LIX->LIX_ORIJUR := aTitulos[nCnt,4] 
								If aTipoSist[nCntConj] == "1"
									LIX->LIX_ORIAMO := aTitulos[nCnt,6]
								EndIf								
							MsUnLock()
							
							//
							// Calcula o valor da correcao monetaria efetuado ate o periodo
							//
							aCmTit := ReCalcCM( aRegs[nCnt,2] )
							
							//
							// Titulos a receber
							//
							dbSelectArea("SE1")
							dbGoto(aRegs[nCnt,1])
							RecLock("SE1" ,.F.)
								SE1->E1_VENCTO  := aTitulos[nCnt,2]
								SE1->E1_VENCREA := DataValida(SE1->E1_VENCTO,.T.)
								SE1->E1_VALOR   := aTitulos[nCnt,3]
								SE1->E1_SALDO   := aTitulos[nCnt,3]
								SE1->E1_VLCRUZ  := aTitulos[nCnt,3]
							MsUnLock()
						
						Next nCnt
					EndIf
				Next nCntConj
			EndIf
		EndIf
	EndIf
	
RestArea( aArea )
RestArea( aAreaLIT )
RestArea( aAreaLJO )
RestArea( aAreaLFD )
RestArea( aAreaLIX )
RestArea( aAreaSE1 )

Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReCalcCM ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.05.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa que recalcula a correcao monetaria acumulada        ³±±
±±³          ³ do titulo a receber                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Template GEM                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReCalcCM( nRecLIX )
Local aArea    := GetArea()
Local aAreaLIX := LIX->(GetArea())
Local aAreaLIW := LIW->(GetArea())
Local nCnt     := 1 
Local aLIWRec  := {}
Local nAmoCM   := 0
Local nVlrAmo  := 0
Local nAcuAmo  := 0
Local nVlrJur  := 0
Local nAcuJur  := 0
Local nJurCM   := 0 // Valor da correcao monetaria do Juros Financiado
Local nAcumCMAmort := 0
Local nAcumCMJuros := 0
Local nCMAmort     := 0
Local nCMJuros     := 0
Local nVlrTitulo   := 0
Local nCMTitulo    := 0
Local nNewCMAmort  := 0
Local nNewCMJuros  := 0
Local nNewVlrTit   := 0
Local aRetCoef	:= {}


	// Detalhes do titulo a receber
	dbSelectArea("LIX")
	dbGoto(nRecLIX)
	
	// Historico da correcao monetaria
	dbSelectArea("LIW")
	dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	dbSeek(xFilial("LIW")+LIX->LIX_PREFIX+LIX->LIX_NUM+LIX->LIX_PARCEL)
	While LIW->(!Eof()) .AND. ;
	      LIW->LIW_FILIAL+LIW->LIW_PREFIX+LIW->LIW_NUM+LIW->LIW_PARCEL == ;
	      xFilial("LIW")+LIX->LIX_PREFIX+LIX->LIX_NUM+LIX->LIX_PARCEL ;
	      .AND. (LIW->LIW_TIPO == MVPROVIS .OR. LIW->LIW_TIPO == MVNOTAFIS)
	      
		aAdd( aLIWRec ,{ LIW->LIW_DTREF ,LIW->(Recno()) } )
		
		dbSelectArea("LIW")
		dbSkip()
	EndDo
	
	// ordena por mes/ano de correcao monetaria	
	aSort( aLIWRec ,,,{|x,y| x[1]<y[1] } )

    //
	//  varre o array, posicionando o registro na tabela LIW
	// e gerando o calculo da CM do juros mensal, caso existir.
	//
	For nCnt := 1 To Len( aLIWRec )
	
		dbSelectArea("LIW")
		dbGoto(aLIWRec[nCnt][2])
		
        RecLock("LIW",.F.)
	        If LIX->LIX_ORIJUR == 0
	        	aRetCoef := T_GEMCoefCM( LIW->LIW_TAXA ,0 ,LIW->LIW_DTIND )             
			    nDecIndCM := aRetCoef[1]/aRetCoef[2]
		        nVlrTitulo := LIX->LIX_ORIAMO+LIX->LIX_ORIJUR+nAcuAMO+nAcuJur
				nAmorBase  := round( nVlrTitulo*(LIX->LIX_ORIAMO / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) ,2 )
				nJuroBase  := round( nVlrTitulo*(LIX->LIX_ORIJUR / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) ,2 )

				nNewCMAmort := round( nAmorBase * nDecIndCM ,2)
				// Correcao monetaria do titulo, Amortizacao, Juros
				nNewVlrTit  := round( (nVlrTitulo*nDecIndCM) ,2)
				If nNewVlrTit < 0
					nNewVlrTit := nNewVlrTit * -1
				EndIf
				nCMTitulo   := nNewVlrTit-nVlrTitulo // Valor da CM do Titulo
				nNewCMAmort := nNewCMAmort-nAmorBase // Valor da CM do amortizado
				nNewCMJuros := nCMTitulo-nNewCMAmort // Valor da CM do juros

				LIW->LIW_BASAMO := nVlrTitulo*(nAmorBase  / (nAmorBase+nJuroBase))
				LIW->LIW_BASJUR := nVlrTitulo*(nJuroBase / (nAmorBase+nJuroBase))
				LIW->LIW_VLRAMO := nNewCMAmort
				nVlrAMO := LIW->LIW_VLRAMO
				LIW->LIW_VLRJUR := nNewCMJuros
				nVlrJur := LIW->LIW_VLRJUR
				LIW->LIW_ACUAMO := nAcuAMO
				nAcuAMO += nVlrAMO
				LIW->LIW_ACUJUR := nAcuJur
				nAcuJur += nVlrJur
			Endif
    	LIW->(MsUnLock())

	Next nCnt

RestArea( aAreaLIW )
RestArea( aAreaLIX )
RestArea( aArea )

Return( {nAmoCM ,nJurCM} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldGemSrt ºAutor  ³Clovis Magenta      º Data ³  02/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a MSMGET da inclusao ou alteração de estrutura(LK5)  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMA142                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldGemSrt(cCodEmp,cStrPai,cNewStr,cPrvHB,cHabite,cDescri,aMasc)
           
Local lRet:= .F.

Default cCodEmp := ""
Default cStrPai := ""
Default cNewStr := ""
Default cPrvHB  := ""
Default cHabite := ""
           
If ExistCpo("LK3",cCodEmp,1) .And. T_GEM142Pai( M->LK5_CODEMP, cStrPai,aMasc ) .And. GEMVldCod( cNewStr, aMasc);
	.And. CheckSX3("LK5_PREVHB",cPrvHB) .And. CheckSX3("LK5_HABITE",cHabite) .And. !Vazio(cDescri)
	 
	lRet := .T. 
                    
EndIf

If Vazio(cDescri)
//"Descricao nao pode estar vazia!"
	alert(STR0010)
EndIf

Return lRet
