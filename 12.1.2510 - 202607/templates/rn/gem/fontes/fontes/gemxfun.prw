#INCLUDE "GEMXFUN.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMDlgSol ºAutor  ³Telso Carneiro      º Data ³  04/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Solidarios integrada com o Pedido de Venda(MATA410)º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410, GEMA060 e GEMA100                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMDlgSol()

Local oDlgR
Local oGetSol
Local nOpcX	      := PARAMIXB[1]          //nOpc
Local cNumPed     := PARAMIXB[2] 		   //M->C5_NUM
Local cCliente    := padr( PARAMIXB[3] ,TamSX3("LEA_CODSOL")[1] )
Local cLoja       := padr( PARAMIXB[4] ,TamSX3("LEA_LJSOLI")[1] )
Local nPos_CODSOL := 0
Local nPos_LJSOLI := 0
Local nPos_NOMSOL := 0
Local nOpca       := 0
Local nOpcGD      := 0
Local nCount      := 0
Local aHeadSOL    := {}
Local aColsSOL    := {}
Local aArea       := GetArea()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

IF Type("aHeadLEA") == "U"
	PRIVATE aHeadLEA :={}
	PRIVATE aColsLEA :={}
Endif

If Empty(cCliente) .AND. Empty(cLoja) 
	Help(" ",1,"CLINAOINF",,STR0005 + CRLF + STR0006,1)  //"Código e loja do cliente "###"não foi informado no pedido."
Else
	aHeadSOL	:=aClone(aHeadLEA)
	aColsSOL	:=aClone(aColsLEA)
	
	dbSelectArea("LEA")
	RegToMemory("LEA")
	IF Len(aHeadSOL)==0
		aHeadSOL	:= aClone(TableHeader("LEA"))
	Endif
	IF Len(aColsSOL)==0
		aColsSOL := aClone(GXFFilaCols("LEA",1,nOpcX,aHeadSOL,cNumPed))
		
		//
		// preenche o campo LEA_NOMSOL
		//
		nPos_CODSOL := aScan( aHeadSOL ,{|x|Upper(AllTrim(x[2])) == "LEA_CODSOL" } )
		nPos_LJSOLI := aScan( aHeadSOL ,{|x|Upper(AllTrim(x[2])) == "LEA_LJSOLI" } )
		nPos_NOMSOL := aScan( aHeadSOL ,{|x|Upper(AllTrim(x[2])) == "LEA_NOMSOL" } )
		
		If nPos_CODSOL > 0 .AND. nPos_LJSOLI > 0 .AND. nPos_NOMSOL > 0
			For nCount := 1 To len(aColsSOL)
				dbSelectArea("SA1")
				dbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
				If SA1->(dbSeek( xFilial("SA1")+aColsSOL[nCount ,nPos_CODSOL]+aColsSOL[nCount ,nPos_LJSOLI]))
					aColsSOL[nCount ,nPos_NOMSOL] := SA1->A1_NOME
				EndIf
			Next nCount
		EndIf
		
	Endif
	
	If nOpcX == 3 .Or.nOpcX ==4
		nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
	Else
		nOpcGD := 0
	EndIf
	
	DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0001) FROM 9,0 TO 25,85 //"Cadastro de Solidarios"
	
	oGetSol := MsNewGetDados():New(002,02,097,338,nOpcGD,{|| GXFLinOk(cCliente,cLoja)},"AllwaysTrue",,,,9999,,,,oDlgR,aHeadSOL,aColsSOL)
	oGetSol:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlgR ON INIT EnchoiceBar(oDlgR,{|| iIf( nOpcGD == 0 .OR. GXFTudOk(cCliente,cLoja,oGetSol:aHeader,oGetSol:aCols);
	                                                          ,(nOpca:=1,oDlgR:End()) ;
	                                                          , nOpca:=0 )}           ;
	                                                     ,{|| nOpca:= 0,oDlgR:End()})
	
	If nOpca==1
		aHeadLEA:=aClone(oGetSol:aHeader)
		aColsLEA:=aClone(oGetSol:aCols)
	EndIf
EndIf

RestArea(aArea)

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GXFFilaCols ºAutor  ³Telso Carneiro    º Data ³  02/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Monta o aCols utilizado na Rotina                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GXFFilacols(EXPC1,EXPN1,EXPN2,EXPN3)	    	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias                                              ³±±
±±³			 ³ EXPC2 = Ordem Chave                                        ³±±
±±³			 ³ EXPC3 = Opcao aRotina                                      ³±±
±±³			 ³ EXPC4 = Tamanho do aHeader                                 ³±±
±±³			 ³ EXPC5 = numero do Pedido                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPA1 = Array com o aCols montado                          ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMDlgSol                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GXFFilaCols(cAlias,nOrdem,nOpcx,aHeadLOC,cNumPed)
Local aColsAux :={}
Local cCpoGrv
Local nX
Local nUsado   := Len(aHeadLOC)
Local aArea    := GetArea()

If nOpcx # 3
	dbSelectArea(cAlias)
	(cAlias)->(dbSetOrder(nOrdem))
	IF MSSeek(xFilial(cAlias)+cNumPed)
		While !Eof() .And. xFilial(cAlias) == &(cAlias+"_FILIAL") .And. cNumPed == &(cAlias+"_NUM")
			aAdd(aColsAux,Array(nUsado+1))
			For nX := 1 To Len(aHeadLOC)
				cCpoGrv := FieldName(FieldPos(AllTrim(aHeadLOC[nX,2])))
				aColsAux[Len(aColsAux),nX] := &cCpoGrv
			Next nX
			aColsAux[Len(aColsAux),nUsado+1] := .F.
			dbSkip()
		Enddo
	Endif
EndIf

If nOpcx == 3 .Or. Len(aColsAux) == 0
	aColsAux := Array(1,nUsado+1)
	dbSelectArea("SX3")
	dbSetOrder(1) // X3_ALIAS
	dbSeek(cAlias)
	nUsado := 0
	While !Eof() .And. (x3_arquivo == cAlias)
		If X3USO(x3_usado) .And. cNivel >= x3_nivel
			nUsado++
			If x3_tipo == "C"
				aColsAux[1,nUsado] := SPACE(x3_tamanho)
			Elseif x3_tipo == "N"
				aColsAux[1,nUsado] := 0
			Elseif x3_tipo == "D"
				aColsAux[1,nUsado] := dDataBase
			Elseif x3_tipo == "M"
				aColsAux[1,nUsado] := ""
			Else
				aColsAux[1,nUsado] := .F.
			Endif
			If x3_context == "V"
				aColsAux[1,nUsado] := CriaVar(AllTrim(x3_campo))
			Endif
		EndIf
		dbSkip()
	EndDo
	aColsAux[1,nUsado+1] := .F.
EndIf
RestArea(aArea)

Return(aColsAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GXFLinOk  ºAutor  ³Telso Carneiro      º Data ³  09/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle da MsNewGetdados Linha OK Cadastros de Solidarios º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMDlgSol                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GXFLinOk(cCliente,cLoja)
Local lRet       := .T.
Local nOcoCodSol := 0
Local nX         := 0
Local nPosCodSol := GdFieldPos( "LEA_CODSOL" ,aHeader)
Local nPosJlSol	 := GdFieldPos( "LEA_LJSOLI" ,aHeader)
Local nUsado 	 := Len(aHeader)

If cCliente == aCols[N,nPosCodSol] .AND. cLoja == aCols[N,nPosJlSol]
	Help("",1,"GFXEXISSOL",,OemToAnsi(STR0002),1) //"Existem Solidarios Duplicados"
	lRet := .F.
Endif
	
If lRet
	For nX := 1 To Len(aCols)
		// se o item nao foi deletado
		If !(aCols[N,nUsado+1])
			If aCols[nX,nPosCodSol]+aCols[nX,nPosJlSol] == aCols[N,nPosCodSol]+aCols[N,nPosJlSol]
				If !(aCols[nX,nUsado+1])
					nOcoCodSol++
				EndIf
			EndIf
		EndIf
	Next
	
	If nOcoCodSol > 1
		Help("",1,"GFXEXISSOL",,OemToAnsi(STR0002),1) //"Existem Solidarios Duplicados"
		lRet := .F.
	Else
		If Empty(aCols[N,nPosCodSol]) .Or. Empty(aCols[N,nPosJlSol])
			If !(aCols[N,nUsado+1])
				Help("",1,"OBRIGAT2")
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GXFTudOk  ºAutor  ³Telso Carneiro      º Data ³  09/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle da MsNewGetdados Tudo OK Cadastro de Solidarios   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMDlgSol                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GXFTudOk(cCliente,cLoja,aHeadSol,aColsSOL)
Local lRet       := .T.
Local nOcoCodSol := 0
Local nX,nY
Local nPosCodSol := GdFieldPos( "LEA_CODSOL" ,aHeadSol)	
Local nPosJlSol	 := GdFieldPos( "LEA_LJSOLI" ,aHeadSol)
Local nUsado 	 := Len(aHeadSol)

For nX := 1 To Len(aColsSol)
	// se o item nao foi deletado
	If !(aColsSol[nX,nUsado+1])
		If Empty(aColsSol[nX,nPosCodSol]) .Or. Empty(aColsSol[nX,nPosJlSol])
			Help("",1,"OBRIGAT2")
			lRet := .F.
			Exit
		EndIf
		
		nOcoCodSol := 0
		For nY := 1 To Len(aColsSol)
			If aColsSol[nY,nPosCodSol]+aColsSol[nY,nPosJlSol] == aColsSol[nX,nPosCodSol]+aColsSol[nX,nPosJlSol]
				If !(aColsSol[nY,nUsado+1])
					nOcoCodSol++
				EndIf
			EndIf
		Next nY
		
		If nOcoCodSol > 1 .OR. aColsSol[nX,nPosCodSol]+aColsSol[nX,nPosJlSol]==cCliente+cLoja
			Help("",1,"GFXEXISSOL",,OemToAnsi(STR0002),1)  //"Existem Solidarios Duplicados"
			lRet := .F.
			Exit
		EndIf
	Endif
Next nX

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMXGRSOL ºAutor  ³Telso Carneiro      º Data ³  10/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava os Solidarios do Cliente no Pedido de Venda           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA410 (A410Grava)                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMXGRSOL()

Local nOpcX      := PARAMIXB[1] //nOpcao
Local cNumPed    := PARAMIXB[2]	//SC5->C5_NUM
Local nX,nY
Local nPosCodSol := 0
Local nPosJlSol  := 0
Local nUsado     := 0
Local aArea	     := {}
Local aAreaLEA   := {}
Local nPosCp

If HasTemplate("LOT")

	aArea    := GetArea()
	aAreaLEA := LEA->(GetArea())
	
	If Type("aHeadLEA") == "U"
		PRIVATE aHeadLEA :={}
		PRIVATE aColsLEA :={}
	Endif
	
	If len(aColsLEA) > 0
		If Len(aHeadLEA) >0 
			nPosCodSol := GdFieldPos( "LEA_CODSOL" ,aHeadLEA)
			nPosJlSol  := GdFieldPos( "LEA_LJSOLI" ,aHeadLEA)
			nUsado     := Len(aHeadLEA)
		Endif
		
		dbSelectArea("LEA")
		dbSetOrder(1) // LEA_FILIAL+LEA_NUM+LEA_CODSOL+LEA_LJSOLI
		
		//
		// Se não for exclusao
		//
		If !(nOpcX==3)
			For nX := 1 To Len(aColsLEA)
				// se o item nao foi deletado
				If !(aColsLEA[nX,nUsado+1])
					RecLock("LEA" ,!MsSeek(xFilial("LEA")+cNumPed+aColsLEA[nX,nPosCodSol]+aColsLEA[nX,nPosJlSol]) )
					For nY := 1 to fCount()
						If (nPosCp:= GdFieldPos(FieldName(nY),aHeadLEA))<>0
							FieldPut(nY,aColsLEA[nX,nPosCp])
						Endif
					Next nY
					LEA->LEA_FILIAL := xFilial("LEA")
					LEA->LEA_NUM    := cNumPed
					MsUnLock()
				Else
					MSSeek(xFilial("LEA")+cNumPed+aColsLEA[nX,nPosCodSol]+aColsLEA[nX,nPosJlSol])
					While !Eof() .And. xFilial("LEA")+cNumPed+aColsLEA[nX,nPosCodSol]+aColsLEA[nX,nPosJlSol] == ;
						LEA->LEA_FILIAL+LEA->LEA_NUM+LEA->LEA_CODSOL+LEA->LEA_LJSOLI
						RecLock("LEA",.F.)
						LEA->(dbDelete())
						MsUnLock()
						dbSkip()
					Enddo
				EndIf
			Next nX
			
			// exclui os registros que naum sao mais utilizados 
			dbGoTop()
			MSSeek(xFilial("LEA")+cNumPed)
			While LEA->(!Eof()) .AND. xFilial("LEA")+cNumPed == LEA->LEA_FILIAL+LEA->LEA_NUM
				If (nPos := aScan( aColsLEA ,{|x| !(x[nUsado+1]) .AND. x[nPosCodSol] == LEA->LEA_CODSOL .AND. x[nPosJlSol] == LEA->LEA_LJSOLI })) <= 0
					RecLock("LEA",.F.)
					DbDelete()
					MsUnLock()
				EndIf
				DbSkip()
			EndDo
			
		Else
			MSSeek(xFilial("LEA")+cNumPed)
			While !Eof() .And. xFilial("LEA")+cNumPed == LEA->LEA_FILIAL+LEA->LEA_NUM
				RecLock("LEA",.F.)
				DbDelete()
				MsUnLock()
				LEA->(DbSkip())
			Enddo
		EndIf
		
		aHeadLEA:={}
		aColsLEA:={}
		
	EndIf
	
	RestArea(aAreaLEA)
	RestArea(aArea)

EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMXValEm ºAutor  ³Telso Carneiro      º Data ³  15/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valid e Trigger do Campo codigo do Empreendimento no       º±±
±±º          ³  pedido de vendas.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valid do Campo C6_CODEMPR                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMXValEm()
Local lRet         := .T.
Local nLoop        := 0
Local nPosy	       := GdFieldPos( "C6_PRODUTO" ,aHeader)
Local nPos_CODEMPR := GdFieldPos( "C6_CODEMPR" ,aHeader)
Local cReadVar	   := __readvar

Local aArea    := GetArea()
Local aAreaSC6 := SC6->(GetArea())
Local aAreaLIT := LIT->(GetArea())

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios
ChkTemplate("LOT")

For nLoop := 1 To len(aCols)
	If !(nLoop == n) .AND. aCols[nLoop ,nPos_CODEMPR]==M->C6_CODEMPR
		//"Template GEM" # "A unidade " #" já foi informada na linha : # 'Ok'		
		Aviso(STR0018 , STR0019 + M->C6_CODEMPR + STR0020 + strzero(nLoop,2) + ".", {STR0021})
		lRet := .F.
		Exit
	EndIf
Next nLoop

If lRet
	lRet:= .F.
	dbSelectArea("LIQ")
	dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
	If dbSeek(xFilial("LIQ")+M->C6_CODEMPR)
		// "LV" - LIVRE
		If LIQ->LIQ_STATUS == "LV"
			lRet := .T. 
		Else
			// unidade reservada ou com contrato assinado
			If LIQ->LIQ_STATUS $ "CA/RE"
			
				lRet := .T.
				
				// Itens do pedido de venda
				dbSelectArea("SC6")
				dbSetOrder(2) // C6_PRODUTO+C6_NUM+C6_ITEM
				dbSeek(xFilial("SC6")+LIQ->LIQ_CODPRD)
				While SC6->(!EOF()) .AND. SC6->C6_PRODUTO == LIQ->LIQ_CODPRD
					If SC6->C6_CODEMPR == M->C6_CODEMPR .AND. !(M->C5_NUM == SC6->C6_NUM)
					
						// Unidade Reservada
		    			If LIQ->LIQ_STATUS $ "RE" 
		    				// sem nota
		    				If Empty(SC6->C6_NOTA) .and. Empty(SC6->C6_SERIE) .and. Empty(SC6->C6_DATFAT)
		    					// "Template GEM" #  "A unidade "  # " está reservada no pedido: " # 'Ok'
								Aviso(STR0018 , STR0019 + M->C6_CODEMPR + STR0022 + SC6->C6_NUM + ".", {STR0021})
								lRet := .F.
								Exit
							EndIf
						EndIf
					
						// Unidade com contrato Assinado
		    			If LIQ->LIQ_STATUS $ "CA"
							dbSelectArea("LIT")
							dbSetOrder(1) // LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
							If dbSeek(xFilial()+ SC6->C6_NOTA+SC6->C6_SERIE+SC6->C6_CLI+SC6->C6_LOJA)
		    					// "Template GEM" #  "A unidade "  # " foi vendido no contrato: " # 'Ok'
								Aviso(STR0018 ,STR0019 + M->C6_CODEMPR + STR0023 + LIT->LIT_NCONTR + ".", {STR0021})
							Else
		    					// "Template GEM" #  "A unidade "  #  " já foi vendida." # 'Ok'
								Aviso(STR0018 ,STR0019 + M->C6_CODEMPR + STR0024, {STR0021})
							EndIf
							lRet := .F.
							Exit
						EndIf
						
					EndIf
					dbSelectArea("SC6")
					dbSkip()
				EndDo
			EndIf
	    EndIf
	    
	    If lRet
			M->C6_PRODUTO := LIQ->LIQ_CODPRD
			__readvar := "M->C6_PRODUTO"
		
			lRet:=CheckSX3("C6_PRODUTO",M->C6_PRODUTO)
		
			IF lRet
				aCols[N,nPosy] := M->C6_PRODUTO
	
				//-- Executa Gatilhos
				If ExistTrigger("C6_PRODUTO")
					RunTrigger(1,,,, "C6_PRODUTO")
				EndIf
			Endif

		M->C6_CODEMPR := LIQ->LIQ_COD
		__readvar := cReadVar

		EndIf 
	EndIf
EndIf
        

RestArea(aAreaLIT)
RestArea(aAreaSC6)
RestArea(aArea)
	
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMXGRCON ºAutor  ³Telso Carneiro      º Data ³  18/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava os Contratos do Cliente na criacao da Nota Fiscal     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA461                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMXGRCON()
Local axPvlNfs   := PARAMIXB[1]          //aPvlNfs
Local cxNumNFS   := PARAMIXB[2] 		   //cNumNFS
Local cxSerieNF  := PARAMIXB[3] 		   //cSerieNFS
Local nX         := 0
Local nOldArea   := 0
Local nSaveSX8   := 0
Local lAchou     := .F.
Local lEmpreend  := .F.
Local aAreaSF2   := {}
Local aAreaSD2   := {}
Local aArea      := {}
Local cFilLJN    := xFilial("LJN")

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( NIL )
EndIf

nSaveSX8 := GetSX8Len()
aAreaSF2 := SF2->(GetArea())
aAreaSD2 := SD2->(GetArea())
aArea    := GetARea()

If cxNumNFS+cxSerieNF != SF2->(AllTrim(F2_DOC)+F2_SERIE)
	SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
	SF2->(MSSeek(xFilial("SF2")+cxNumNFS+cxSerieNF))
EndIf

For nX := 1 To Len(axPvlNfs)
	SC6->(dbGoto(axPvlNfs[nX,10]))
	If ! Empty(SC6->C6_CODEMPR) .and. !lEmpreend
		lEmpreend := .T.
	EndIf                                                         º
Next nX

//
// se existir algum empreendimento nos itens do pedido de compra
//
If lEmpreend 
	dbSelectArea("LIT")
	dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
	lAchou := MSSeek(xFilial("LIT")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	
	If !lAchou
		M->LIT_NCONTR := CriaVar("LIT_NCONTR")
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		While LIT->(!Eof()) .AND. MSSeek(xFilial("LIT")+M->LIT_NCONTR)
			M->LIT_NCONTR := CriaVar("LIT_NCONTR")
		EndDo
	EndIf
	
	RecLock("LIT",!lAchou)
	
		If !lAchou
			dbSelectArea("SX3")
			dbSetOrder(1) // X3_ALIAS
			dbSeek("LIT")
			While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == "LIT"
				If LIT->(FieldPos(SX3->X3_CAMPO)) >0   
					If ! (SX3->X3_CAMPO=="LIT_NCONTR")
						&("LIT->"+SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
					EndIf
				EndIf
				dbSelectArea("SX3")
				dbSkip()
			EndDo
			
			LIT->LIT_NCONTR := M->LIT_NCONTR
			
		EndIf
		
		LIT->LIT_FILIAL	:= xFilial("LIT")
		LIT->LIT_DOC	:= SF2->F2_DOC
		LIT->LIT_SERIE	:= SF2->F2_SERIE
		LIT->LIT_CLIENT := SF2->F2_CLIENTE
		LIT->LIT_LOJA	:= SF2->F2_LOJA
		LIT->LIT_NOMCLI := Posicione( "SA1", 1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA ,"A1_NOME" )
		LIT->LIT_COND	:= SF2->F2_COND
		LIT->LIT_PREFIX	:= SF2->F2_PREFIXO
		LIT->LIT_DUPL	:= SF2->F2_DUPL
		LIT->LIT_VALBRU	:= SF2->F2_VALBRUT
		LIT->LIT_STATUS	:= "1"
		If !lAchou
			//LIT->LIT_NCONTR	:= InitPad(POSICIONE("SX3",2,"LIT_NCONTR","X3_RELACAO"))
			LIT->LIT_REVISA := StrZero(1,TamSX3("LIT_REVISA")[1])
		Endif
	
	LIT->(MsUnlock())
	
	While (GetSX8Len() > nSaveSx8)
		ConfirmSx8()
	Enddo
	
	If ExistBlock("GEMGRLIT")
		ExecBlock("GEMGRLIT", .F., .F.,{cxNumNFS ,cxSerieNF ,axPvlNfs} )
	Endif
	
	dbSelectArea("LIU")
	dbSetOrder(1) // LIU_FILIAL+LIU_DOC+LIU_SERIE+LIU_CLIENT+LIU_LOJA+LIU_COD+LIU_ITEM
	
	For nX:=1 TO LEN(axPvlNfs)
		
		SC6->(dbGoto(axPvlNfs[nX,10]))
		If SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+axPvlNfs[nX,6]+axPvlNfs[nX,2]!= ;
			SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD+SD2->D2_ITEM
			SD2->(DbSetOrder(3)) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(MSSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+axPvlNfs[nX,6]+axPvlNfs[nX,2]))
		Endif
		
		dbSelectArea("LIU")
		lAchou:= LIU->(MSSeek(xFilial("LIU")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD+SD2->D2_ITEM))
		RecLock("LIU",!lAchou)
		LIU->LIU_FILIAL	:= xFILIAL("LIU")
		LIU->LIU_CODEMP	:= SC6->C6_CODEMPR
		LIU->LIU_NUMSEQ	:= SD2->D2_NUMSEQ
		LIU->LIU_ITEM	:= SD2->D2_ITEM
		LIU->LIU_COD	:= SD2->D2_COD
		LIU->LIU_UM		:= SD2->D2_UM
		LIU->LIU_QUANT	:= SD2->D2_QUANT
		LIU->LIU_PRCVEN	:= SD2->D2_PRCVEN
		LIU->LIU_TOTAL	:= SD2->D2_TOTAL
		LIU->LIU_PEDIDO	:= SD2->D2_PEDIDO
		LIU->LIU_CLIENT	:= SD2->D2_CLIENTE
		LIU->LIU_LOJA	:= SD2->D2_LOJA
		LIU->LIU_DOC	:= SD2->D2_DOC
		LIU->LIU_SERIE	:= SD2->D2_SERIE
		LIU->LIU_EMISSA	:= SD2->D2_EMISSAO
		LIU->LIU_NCONTR := M->LIT_NCONTR
		
		MsUnlock()
		
		//
		// Altera o status do empreendimento como "CA" - Contrato Assinado.
		//
		If LIQ->(MSSeek(xFilial("LIQ")+SC6->C6_CODEMPR ))
			RecLock("LIQ",.F.)
				LIQ->LIQ_STATUS := "CA"
			MsUnLock()
		EndIf
		
		nOldArea := Select()
		dbSelectArea("SC5")
		If SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
			//
			// atualiza a tabela LEA990 com o numero do contrato.
			//
			dbSelectArea("LEA")
			dbSetOrder(1) // LEA_FILIAL+LEA_NUM+LEA_CODSOL+LEA_LJSOLI
			dbSeek(xFilial("LEA")+SC5->C5_NUM )
			While LEA->(!Eof()) .AND. xFilial("LEA")+SC5->C5_NUM == LEA->LEA_FILIAL+LEA->LEA_NUM
				dbSelectArea("LK6")
				RecLock("LK6",.T.)
					LK6->LK6_FILIAL := xFilial("LK6")
					LK6->LK6_NCONTR := M->LIT_NCONTR
					LK6->LK6_CODSOL := LEA->LEA_CODSOL
					LK6->LK6_LJSOLI := LEA->LEA_LJSOLI
					LK6->LK6_GRAU   := LEA->LEA_GRAU
					LK6->LK6_CIVIL  := LEA->LEA_CIVIL
				MsUnlock()
			
				dbSelectArea("LEA")
		        dbSkip()
			EndDo
		Endif
		dbSelectArea( nOldArea )
	Next nX
		
	// se for uma condicao de venda personalizada.
	If SF2->F2_COND == GetMV("MV_GMCPAG")
		// grava as condicoes de venda do pedido de venda para o contrato
		dbSelectArea("SC6")
		SC6->(dbSetOrder(4)) // C6_FILIAL+C6_NOTA+C6_SERIE
		If SC6->(dbSeek(xFilial("SC6")+SF2->F2_DOC+SF2->F2_SERIE))
			// Busca a condicao de venda personalizada do pedido de vendas
			dbSelectArea("LJN")
			If LJN->(dbSeek(cFilLJN+SC6->C6_NUM))
				// exclui a condicao de venda personalizada do contrato
				dbSelectArea("LJO")
				If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
					While LJO->(!eof()) .AND. LJO->LJO_FILIAL+LJO->LJO_NCONTR==xFilial("LJO")+LIT->LIT_NCONTR
						RecLock("LJO",.F.)
							LJO->(dbDelete())
						LJO->(MsUnLock())
						dbSelectArea("LJO")
						dbSkip()
					End
				Endif
			
				// Copia a condicao de venda personalizada do pedido de venda para o contrato
				While LJN->(!eof()) .AND. LJN->LJN_FILIAL+LJN->LJN_NUM==cFilLJN+SC6->C6_NUM
				
					RecLock("LJO",.T.)
					
					LJO->LJO_FILIAL := xFilial("LJO")
					LJO->LJO_NCONTR := LIT->LIT_NCONTR 
					
					LJO->LJO_ITEM   := LJN->LJN_ITEM
					LJO->LJO_NUMPAR := LJN->LJN_NUMPAR
					LJO->LJO_VALOR  := LJN->LJN_VALOR 
					//LJO->LJO_PERCLT := LJN->LJN_PERCLT
					LJO->LJO_TIPPAR := LJN->LJN_TIPPAR
					LJO->LJO_TPDESC := LJN->LJN_TPDESC
					LJO->LJO_DIAVEN := DAY(LJN->LJN_1VENC)
					LJO->LJO_FIXVNC := LJN->LJN_FIXVNC
					LJO->LJO_1VENC  := LJN->LJN_1VENC
					LJO->LJO_TPSIST := LJN->LJN_TPSIST
					LJO->LJO_TAXANO := LJN->LJN_TAXANO
					LJO->LJO_COEF   := LJN->LJN_COEF
					LJO->LJO_IND    := LJN->LJN_IND
					LJO->LJO_NMES1  := LJN->LJN_NMES1
					LJO->LJO_INDPOS := LJN->LJN_INDPOS
					LJO->LJO_NMES2  := LJN->LJN_NMES2
					LJO->LJO_DIACOR := LJN->LJN_DIACOR
					LJO->LJO_TPPRIC := LJN->LJN_TPPRIC
//					LJO->LJO_RESID  := LJN->LJN_RESID
//					LJO->LJO_PARRES := LJN->LJN_PARRES
					If LJO->(FieldPos("LJO_JURINI")) >0 .and. LJN->(FieldPos("LJN_JURINI")) >0
						LJO->LJO_JURINI := LJN->LJN_JURINI
					EndIf
					
					LJO->(MSUnLock())
					
					LJN->(dbSkip())
					
				EndDo
			EndIf
		EndIf
	Else
		// Condicao de pagamento
		dbSelectArea("SE4")
		dbSetOrder(1) // E4_FILIAL+E4_CODIGO
		If dbSeek(xFilial("SE4")+SF2->F2_COND)
			// Condicao de venda
			dbSelectArea("LIR")
			dbSetOrder(1) // LIR_FILIAL+LIR_CODCND
			If dbSeek(xFilial("LIR")+SE4->E4_CODCND)
				// exclui a condicao de venda personalizada do contrato
				dbSelectArea("LJO")
				If LJO->(dbSeek(xFilial("LJO")+LIT->LIT_NCONTR))
					While LJO->(!eof()) .AND. LJO->LJO_FILIAL+LJO->LJO_NCONTR==xFilial("LJO")+LIT->LIT_NCONTR
						RecLock("LJO",.F.)
						LJO->(dbDelete())
						LJO->(MsUnLock())
						LJO->(dbSkip())
					EndDo
				Endif
				
				// Itens da Condicao de venda
				dbSelectArea("LIS")
				dbSeek(xFilial("LIS")+LIR->LIR_CODCND)
			
				// Copia a condicao de venda referenciado na condicao de pagamento do 
				// pedido de venda para o contrato
				While LIS->(!eof()) .AND. LIS->LIS_FILIAL+LIS->LIS_CODCND==xFilial("LIR")+LIR->LIR_CODCND
				
					RecLock("LJO",.T.)
					
					LJO->LJO_FILIAL := xFilial("LIS")
					LJO->LJO_NCONTR := LIT->LIT_NCONTR 
					
					LJO->LJO_ITEM   := LIS->LIS_ITEM
					LJO->LJO_NUMPAR := LIS->LIS_NUMPAR
					LJO->LJO_VALOR  := LIT->LIT_VALBRU*(LIS->LIS_PERCLT/100)
					//LJO->LJO_PERCLT := LIS->LIS_PERCLT
					LJO->LJO_TIPPAR := LIS->LIS_TIPPAR
					LJO->LJO_TPDESC := LIS->LIS_TPDESC
					LJO->LJO_DIAVEN := DAY(SF2->F2_EMISSAO)
					LJO->LJO_FIXVNC := "2" // naum
					LJO->LJO_1VENC  := SF2->F2_EMISSAO
					LJO->LJO_TPSIST := LIS->LIS_TPSIST
					LJO->LJO_TAXANO := LIS->LIS_TAXANO
					LJO->LJO_COEF   := LIS->LIS_COEF
					LJO->LJO_IND    := LIS->LIS_IND
					LJO->LJO_NMES1  := LIS->LIS_NMES1
					LJO->LJO_INDPOS := LIS->LIS_INDPOS
					LJO->LJO_NMES2  := LIS->LIS_NMES2
					LJO->LJO_DIACOR := LIS->LIS_DIACOR
					LJO->LJO_TPPRIC := LIS->LIS_TPPRIC
//					LJO->LJO_RESID  := LIS->LIS_RESID
//					LJO->LJO_PARRES := LIS->LIS_PARRES
					If LIS->(FieldPos("LIS_JURINI")) > 0
						LJO->LJO_JURINI := LIS->LIS_JURINI
					EndIf
					
					LJO->(MSUnLock())
					
					LIS->(dbSkip())
					
				EndDo
			EndIf
		EndIf
	EndIf
	
EndIf
	
SF2->(RestArea(aAreaSF2))
SD2->(RestArea(aAreaSD2))
RestArea(aArea)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMXEXCON ºAutor  ³Telso Carneiro      º Data º  24/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclui Cabecalho e Itens dos Contratos do Cliente           º±±
±±º          ³na Exclusao da Nota Fiscal                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA521                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMXEXCON()
Local axRegSD2	:=PARAMIXB[1] //aRegSD2
Local axRegSE1	:=PARAMIXB[2] //aRegSE1
Local aArea		:= GetArea()
Local nX
Local cFilLIW  := xFilial("LIW")

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios
If !HasTemplate("LOT")
	Return( NIL )
EndIf

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

For nX:=1 to Len(axRegSD2)
	dbSelectArea("SD2")
	dbGoto(axRegSD2[nX])
	
	dbSelectArea("LIU")
	dbSetOrder(1) // LIU_FILIAL+LIU_DOC+LIU_SERIE+LIU_CLIENT+LIU_LOJA+LIU_COD+LIU_ITEM
	If MSSeek(xFilial("LIU")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_COD+SD2->D2_ITEM)
		//
		// Altera o status do empreendimento como "RE" - Reservado
		//
		dbSelectArea("LIQ")
		dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
		If MSSeek(xFilial("LIQ")+LIU->LIU_CODEMPR )
			RecLock("LIQ",.F.)
				LIQ->LIQ_STATUS := "RE"
			MsUnLock()
		EndIf
		
		dbSelectArea("LIU")
		RecLock("LIU",.F.)
			dbDelete()
		LIU->(MsUnlock())
		
	EndIf

Next nX

dbSelectArea("LIT")
dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
If MSSeek(xFilial("LIT")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	// exlui a condicao de venda do contrato
	dbSelectArea("LJO")
	dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
	dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
	While LJO->(!eof()) .AND. LJO->(LJO_FILIAL+LJO_NCONTR)==xFilial("LJO")+LIT->LIT_NCONTR
		RecLock("LJO",.F.)
		LJO->(dbDelete())
		LJO->(MsUnLock())
		dbSkip()
	EndDo

	dbSelectArea("LIT")
	RecLock("LIT",.F.)
		LIT->(dbDelete())
	LIT->(MsUnlock())
	
Endif

//
// exclui os registros referentes aos titulos a receber
//
For nX := 1 to Len(axRegSE1)
	dbSelectArea("SE1")
	DbGoto(axRegSE1[nX])
	
	//
	// Composicao do valor do titulo a receber 
	//
	dbSelectArea("LIX")
	dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	If MSSeek(xFilial("LIX")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
		RecLock("LIX",.F.)
		DbDelete()
		MsUnlock()
	Endif

	//
	// Correcoes monetarias calculadas do valor do titulo a receber 
	//
	dbSelectArea("LIW")
	dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	If DbSeek(cFilLIW+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
		While !LIW->(EOF()) .And. cFilLIW+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA) == LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL)
			RecLock("LIW",.F.)
			DbDelete()
			MsUnlock()
			DbSkip()
		EndDo
	Endif

	//
	// Movimentacao dos resuduos valor do titulo a receber 
	//
	dbSelectArea("LIY")
	dbSetOrder(1) // LIY_FILIAL+LIY_PREFIX+LIY_NUM+DTOS(LIY_DTIND)+LIY_PARCEL
	IF MSSeek(xFilial("LIY")+SE1->E1_PREFIXO+SE1->E1_NUM)
		RecLock("LIY",.F.)
		DbDelete()
		MsUnlock()
	Endif

Next nX

RestArea(aArea)

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMDlgCon ºAutor  ³Telso Carneiro      º Data ³  17/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Integracao com  (MATA461)                          º±±
±±º          ³ Rotina de Geracao das Notas Fiscais de Saida.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA461                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function GEMDlgcon()

Local oDlgR
Local oGetCbCon
Local oGetItCon
Local nOpca
Local axPvlNfs  :=PARAMIXB[1]          //aPvlNfs
Local cxNumNFS  :=PARAMIXB[2] 		   //cNumNFS
Local cxSerieNF :=PARAMIXB[3]

Local nOpcGD    := 0 //GD_UPDATE+GD_INSERT+GD_DELETE
Local nX,nY
Local nUsado
Local nPosCp
Local nPosCod
Local nPosIte
Local cCpoGrv
Local lEmpreend := .F.
Local aColsCON  := {}
Local aHeadCON  := {}
Local aArea     := {}

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( NIL )
EndIf

aArea := GetArea()

For nX := 1 To Len(axPvlNfs)
	SC6->(dbGoto(axPvlNfs[nX,10]))
	If ! Empty(SC6->C6_CODEMPR) .and. !lEmpreend
		lEmpreend := .T.
	EndIf
Next nX

// se encontrar algum empreendimento
If lEmpreend 
	dbSelectArea("LIU")
	RegToMemory("LIU",.F.)
	aHeadCON := aClone(TableHeader("LIU"))
	nUsado	:= Len(aHeadCON)
	
	nPosCod := GdFieldPos("LIU_COD"   ,aHeadCON)
	nPosIte := GdFieldPos("LIU_ITEM"  ,aHeadCON)
	
	dbSelectArea("LIU")
	dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
	MSSeek(xFilial("LIU")+LIT->LIT_NCONTR)
	While !LIU->(EOF()) .AND. LIU->(LIU_FILIAL+LIU_NCONTR) == xFilial("LIU")+LIT->LIT_NCONTR
		aAdd(aColsCON,Array(nUsado+1))
		For nX := 1 To Len(aHeadCON)
			cCpoGrv := FieldName(FieldPos(AllTrim(aHeadCON[nX,2])))
			aColsCON[Len(aColsCON),nX] := &cCpoGrv
		Next
		aColsCON[Len(aColsCON),nUsado+1] := .F.
		
		dbSelectArea("LIU")
		dbSkip()
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o calculo automatico de dimensoes de objetos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 015, .T., .f. } )
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,;
	{{003,033,160,200,240,263}} )
	
	DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0003) From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL //"Complemento de Contratos"
	
	dbSelectArea("LIT")
	RegToMemory("LIT",.F.)
	oGetCbCon:=MsMGet():New("LIT",LIT->(RecNo()),3,,,,,{003,000,125,100},,,,,,oDlgR)
	oGetCbCon:oBox:Align := CONTROL_ALIGN_TOP
	
	oGetItCon := MsNewGetDados():New(002,02,097,338,nOpcGD,"AllwaysTrue","AllwaysTrue",,,,9999,,,,oDlgR,aHeadCON,aColsCON)
	oGetItCon:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgR ON INIT EnchoiceBar(oDlgR,{|| If(Obrigatorio(oGetCbCon:aGets,oGetCbCon:aTela), (nOpca:=1,oDlgR:End()),nOpca == 0) },{|| If(Obrigatorio(oGetCbCon:aGets,oGetCbCon:aTela), (nOpca:= 0,oDlgR:End()),nOpca == 0)})
	
	Begin Transaction

		If nOpca==1
			//
			// cabecalho do contrato
			//
			dbSelectArea("LIT")
			RecLock("LIT",.F.)
			For nX := 1 to FCount()
				If X3USO(POSICIONE("SX3",2,FieldName(nX),"X3_USADO"))
					cCpoGrv := "M->"+FieldName(nX)
					FieldPut(nX,&cCpoGrv)
				Endif
			Next nX
			MsUnlock()
			
			//
			// itens do contrato
			//
			dbSelectArea("LIU")
			dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
			For nX := 1 To Len(aColsCON)
				If !(aColsCON[nX,nUsado+1])
					If dbSeek(xFilial("LIU")+LIT->LIT_NCONTR+aColsCON[nX,nPosCod]+aColsCON[nX,nPosIte])
						RecLock("LIU",.F.)
						For nY := 1 to fCount()
							nPosCp:= GdFieldPos(Fieldname(nY),aHeadCON)
							If nPosCp<>0
								FieldPut(nY,aColsCON[nX,nPosCp])
							Endif
						Next nY
						MsUnLock()
					Endif
				EndIf
			Next nX
		Endif
		
		//
		// cabecalho de nota fiscal de saida
		//
		dbSelectArea("SF2")
		dbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
		If dbSeek(xFilial("SF2")+LIT->LIT_DOC+LIT->LIT_SERIE )
			//
			// Detalhes do titulos a receber
			//
			dbSelectArea("LIX")
			dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
			dbSeek(xFilial("LIX")+SF2->F2_PREFIXO+SF2->F2_DUPL)
			While LIX->(!eof()) .AND. SF2->F2_PREFIXO == LIX->LIX_PREFIX ;
			      .AND. SF2->F2_DUPL == LIX->LIX_NUM
				//
			    // Condicao de venda
			    //
				dbSelectArea("LJO")
				dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
				If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
					//
					// titulos a receber
					//
					dbSelectArea("SE1")
					dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					If dbSeek(xFilial("SE1")+LIX->LIX_PREFIX+LIX->LIX_NUM+LIX->LIX_PARCEL)
						RecLock("SE1",.F.)
							SE1->E1_ITPARC  := LIX->LIX_ITNUM + "/" + STRZERO(LJO->LJO_NUMPAR ,TamSX3("LJO_NUMPAR")[1]) + "-" + LJO->LJO_ITEM 
							SE1->E1_EMISSAO := LIT->LIT_EMISSA
							SE1->E1_NCONTR  := LIT->LIT_NCONTR
						MsUnLock()
					EndIf
				EndIf

				RecLock("LIX",.F.)
					LIX->LIX_NCONTR := M->LIT_NCONTR
				MsUnLock()
				
				dbSelectArea("LIX")
				dbSkip()
			EndDo

			//
			// Processa a correcão monetaria no contrato
			// no periodo do fechamento do contrato até a data do faturamento
			//
			If ExistBlock("GEMCMCONTR")
				ExecBlock("GEMCMCONTR",.F., .F., { SF2->(Recno()), LIT->(Recno()) } )
			Else
				CMContr( SF2->(Recno()) ,LIT->(Recno()) )
			Endif	
		EndIf
	End Transaction
		
	IF MsgYESNO(OemToAnsi(STR0004))	//"Deseja emitir o contrato ?"
		T_GEMXIPCON(aClone(aHeadCON),aClone(aColsCON))
	Endif
	
EndIf
RestArea(aArea)

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMXIPCON ºAutor  ³Telso Carneiro      º Data ³  21/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para processamento de Contrato via Word             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMXIPCON(aHeadCON,aColsCON)

Local aArea  	:= GetArea()
Local aCTPath	:= T_ConPath()
Local cPathWTmp	:= aCTPath[1]
Local cPathMode	:= aCTPath[2]
Local lContinua := .T. 
Local nPosEmp	:= GdFieldPos("LIU_CODEMP",aHeadCON)
Local cPerg     := "GEMCON"
Local cArqDOT   := ""

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

dbSelectArea("LIQ")
DbSetOrder(1) // LIQ_FILIAL+LIQ_COD
If MSSeek(XFilial("LIQ")+aColsCON[1,nPosEmp])
	cArqDOT	:= Alltrim(LIQ->LIQ_MODCON)  //Modelo do contrato .DOT
	If Empty(cArqDOT)
		MsgAlert(STR0025) // #"Não foi informado nenhum modelo de contrato nesta unidade. "
	Else
		If !File( cPathMode + cArqDOT )
			Help( " ", 1, "GM_DOTNEXT" )
			lContinua := .f.
		Else
			CpyS2T(cPathMode+cArqDOT,cPathWTmp,.T.)
			If !File( cPathWTmp + cArqDOT )
				Help( " ", 1, "GM_DOTNEXT" )
				lContinua := .f.
			Endif
		EndIf
		
		If lContinua .AND. Pergunte(cPerg)  //Visualiza - Quantidade
			Processa({||AuxGEMxIPCon(cPathWTmp ,cArqDOT ,aHeadCON,aColsCON) },STR0007,STR0008,.F.)  //"Processando o contrato titulos"###"Aguarde..."
		EndIf
	
	EndIf
EndIf
RestArea( aArea )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AuxGEMxIPCºAutor  ³Reynaldo Miyashita  º Data ³ 02.06.2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para processamento de Contrato via Word             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMXFUN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxGEMxIPCon(cPathWTmp ,cArqDOT ,aHeadCON,aColsCON)

Local aArea  	  := GetArea()
Local nPosCod	  := GdFieldPos("LIU_COD"   ,aHeadCON)
Local nPosIte	  := GdFieldPos("LIU_ITEM"  ,aHeadCON)
Local nPosEmp	  := GdFieldPos("LIU_CODEMP",aHeadCON)
Local nPosPed	  := GdFieldPos("LIU_PEDIDO",aHeadCON)
Local nUsado 	  := Len(aHeadCON)
LocaL nPosCp
Local nX,nY
Local cCodEmp1    := ""
Local cEditor     := "GEMOleWord97"
Local nVlrCapital := 0
Local nCount, lApaga
Local aDocExemplo := {  "LIT_NCONTR",;
						"A1_NOME",;
						"A1_DTNASC",;
						"A1_GMCIVIL",;
						"A1_PFISICA",;
						"A1_CGC",;
						"A1_END",;
						"A1_BAIRRO",;
						"A1_MUN",;
						"A1_EST",;
						"A1_CEP",;
						"LIQ_COD01",;
						"LIQ_BLOCO01",;
						"LIQ_CIDADE01",;
						"LIQ_UF01",;
						"LIQ_AREA01",;
						"LIQ_UM01",;
						"LIQ_REGPRE01",;
						"LEJ_NOME01",;
						"LJO_NUMPAR01",;
						"LJO_TPDESC01",;
						"VALOR_PARCELA01",;
						"LJO_1VENC03",;
						"VALOR_TOTAL01",;
						"LJO_IND01",;
						"LJO_NUMPAR02",;
						"LJO_TPDESC02",;
						"VALOR_PARCELA02",;
						"LJO_1VENC02",;
						"VALOR_TOTAL02",;
						"LJO_IND02",;
						"LJO_NUMPAR03",;
						"LJO_TPDESC03",;
						"VALOR_PARCELA03",;
						"LJO_1VENC03",;
						"VALOR_TOTAL03",;
						"LJO_IND03",;
						"LIQ_OBSERV",;
						"LIT_EMISSA"}

PRIVATE oWord
					
//"Criando link de comunica‡„o com o editor"
If Type("oWord") <> "U"
	If !Empty(oWord) .And. oWord <> "-1"
		OLE_CloseFile( oWord )
		OLE_CloseLink( oWord )
	EndIf
Endif
oWord := OLE_CreateLink( cEditor )

// "Ajustando propriedades do editor"
OLE_SetProperty( oWord, oleWdVisible,   .F. )
OLE_SetProperty( oWord, oleWdPrintBack, .T. )
OLE_SetProperty( oWord, oleWdLeft,   000 )
OLE_SetProperty( oWord, oleWdTop,    100 )
OLE_SetProperty( oWord, oleWdWidth,  500 )
OLE_SetProperty( oWord, oleWdHeight, 250 )

//"Gerando novo documento"
OLE_NewFile( oWord, ( cPathWTmp + cArqDOT ) )

//carrega as variaveis vazias para nao causar error no documento word
For nX := 1 To Len(aDocExemplo)
	OLE_SetDocumentVar( oWord, aDocExemplo[nX] , Space(Len(LIT->LIT_NCONTR)) ) 
Next

dbSelectArea("SM0")
If MSSeek(cEmpAnt+cFilAnt)
	RegToMemory("SM0",.F.)
	ProcRegua( fCount() )
	For nX := 1 To fCount()
	 	IncProc()
		nPosCp:= "M->"+Fieldname(nX)
		&(nPosCp) := FieldGet(nX)
		If !Empty(Posicione("SX3", 2, Fieldname(nX) , "x3CBox()")   )
			OLE_SetDocumentVar( oWord, Fieldname(nX) , QA_CBox(Fieldname(nX),&nPosCp) )
		Else
			OLE_SetDocumentVar( oWord, Fieldname(nX) , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
		Endif
		dbSelectArea("SM0")
	Next nX
EndIf

// "Transferindo dados do sistema"
dbSelectArea("LIT") //equivale ao SF2
RegToMemory("LIT",.F.)
ProcRegua( Fcount() )
For nX := 1 To Fcount()
 	IncProc()
	nPosCp:= "M->"+Fieldname(nX)
	IF !Empty(Posicione("SX3", 2, Fieldname(nX) , "x3CBox()")   )
		OLE_SetDocumentVar( oWord, Fieldname(nX) , QA_CBox(Fieldname(nX),&nPosCp) )
	Else
		OLE_SetDocumentVar( oWord, Fieldname(nX) , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) ) 
	Endif	
	dbSelectArea("LIT")
Next nX
nVlrCapital := LIT->LIT_VALBRU

dbSelectArea("SA1")
SA1->(dbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
IF SA1->(MSSeek(xFilial("SA1")+LIT->LIT_CLIENT+LIT->LIT_LOJA))
	RegToMemory("SA1",.F.)
	ProcRegua( fCount() )
	For nX:=1 To fCount()     
		nPosCp := "M->"+SA1->(FieldName(nX))
				
		IncProc()
		
		Do Case		
			Case Fieldname(nX) == "A1_GMNACIO"
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CAMPO
				If SX5->(dbSeek( xFilial("SX5")+"34"+SA1->(FieldGet(nX)) ))
					&(nPosCp) := X5Descri()
				EndIf
			Case Fieldname(nX) == "A1_GMCIVIL"
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1)) // // X5_FILIAL+X5_TABELA+X5_CAMPO
				If SX5->(dbSeek( xFilial("SX5")+"33"+SA1->(FieldGet(nX)) ))
					&(nPosCp) := X5Descri()
				EndIf
			Otherwise
				If !Empty(Posicione("SX3", 2, Fieldname(nX)  ,"x3CBox()")   )
					&(nPosCp) := QA_CBox(Fieldname(nX),SA1->(FieldGet(nX)))
				Else
					&(nPosCp) := Transform( SA1->(FieldGet(nX)) ,X3PICTURE( Fieldname(nX) ) )
				Endif			
		EndCase
		
		dbSelectArea("SA1")
		OLE_SetDocumentVar( oWord, Fieldname(nX) ,&nPosCp )

		dbSelectArea("SA1")
	
	Next nX
Endif

// LK6 - Solidarios do contrato
dbSelectArea("LK6")  
dbSetOrder(1) // LK6_FILIAL+LK6_NCONTR+LK6_CODSOL+LK6_LJSOLI
If MSSeek(xFilial("LK6")+aColsCON[1,nPosPed])
	nY := 0
	While LK6->(!Eof()) .And. xFilial("LK6")+aColsCON[1,nPosPed] == LK6->LK6_FILIAL+LK6->LK6_NUM
		nY++
		//RegToMemory("LK6",.F.)
		ProcRegua( fCount() )
		For nX:=1 To fCount()
			IncProc()
			nPosCp:= "M->"+Fieldname(nX)+strzero(nY)
			&(nPosCp) := FieldGet(nX)
			If !Empty(Posicione("SX3", 2, Fieldname(nX) , "x3CBox()")   )
				OLE_SetDocumentVar( oWord, Fieldname(nX)+strzero(nY) , QA_CBox(Fieldname(nX),&nPosCp) )
			Else
				OLE_SetDocumentVar( oWord, Fieldname(nX)+strzero(nY) , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
			EndIf	
		Next nX		
		dbSelectArea("LK6")
		dbSkip()
	Enddo
Endif

// Condicao de pagamento
dbSelectArea("SE4")
SE4->(dbSetOrder(1)) // E4_FILIAL+E4_CODIGO
IF SE4->(MSSeek(xFilial("SE4")+LIT->LIT_COND))
	RegToMemory("SE4",.F.)
	ProcRegua( fCount() )
	For nX:=1 To fCount()
		IncProc()
		nPosCp:= "M->"+Fieldname(nX)  
		IF !Empty(Posicione("SX3", 2, Fieldname(nX) , "x3CBox()")   )
			OLE_SetDocumentVar( oWord, Fieldname(nX) , QA_CBox(Fieldname(nX),&nPosCp) )
		Else
			OLE_SetDocumentVar( oWord, Fieldname(nX) , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
		Endif
		dbSelectArea("SE4")
	Next nX
	
	// Condicao de venda
//	dbSelectArea("LIR")
//	LIR->(dbSetOrder(1))
//	If LIR->(MSSeek(xFilial("LIR")+SE4->E4_CODCND))
//		RegToMemory("LIR",.F.)
//		ProcRegua( fCount() )
//		For nX:=1 To fCount()
//			IncProc()
//			nPosCp:= "M->"+Fieldname(nX)  
//			IF !Empty(Posicione("SX3", 2, Fieldname(nX) , "x3CBox()")   )
//				OLE_SetDocumentVar( oWord, Fieldname(nX) , QA_CBox(Fieldname(nX),&nPosCp) )
//			Else
//				OLE_SetDocumentVar( oWord, Fieldname(nX) , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
//			Endif
//		Next nX
		
		//Itens de Condicao de venda
		dbSelectArea("LJO")
		dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
		MSSeek(xFilial("LJO")+LIT->LIT_NCONTR)
		While !Eof() .And. xFilial("LJO")+LIT->LIT_NCONTR == LJO->LJO_FILIAL+LJO->LJO_NCONTR
		
			//RegToMemory("LJO",.F.)
			ProcRegua( fCount() )
			For nX:=1 To fCount()
				IncProc()
				nPosCp:= "M->"+Fieldname(nX)+LJO->LJO_ITEM
				&(nPosCp) := FieldGet(nX)
				If !Empty(Posicione("SX3", 2, Fieldname(nX)+LJO->LJO_ITEM , "x3CBox()")   )
					OLE_SetDocumentVar( oWord, Fieldname(nX)+LJO->LJO_ITEM , QA_CBox(Fieldname(nX),&nPosCp) )
				Else
					OLE_SetDocumentVar( oWord, Fieldname(nX)+LJO->LJO_ITEM , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
				Endif
				dbSelectArea("LJO")
			Next nX
			//
			// Tipo de parcelas
			//                    
			dbSelectArea("LFD")
			dbSetOrder(1) // LFD_FILIAL+LFD_COD
			If MSSeek(xFilial("LFD")+LJO->LJO_TIPPAR)
				//RegToMemory("LFD",.F.)
				ProcRegua( fCount() )
				For nX:=1 To fCount()
					IncProc()
					nPosCp:= "M->"+Fieldname(nX)+LJO->LJO_ITEM
					&(nPosCp) := FieldGet(nX)
					If !Empty(Posicione("SX3", 2, Fieldname(nX)+LJO->LJO_ITEM , "x3CBox()")   )
						OLE_SetDocumentVar( oWord, Fieldname(nX)+LJO->LJO_ITEM , QA_CBox(Fieldname(nX),&nPosCp) )
					Else
						OLE_SetDocumentVar( oWord, Fieldname(nX)+LJO->LJO_ITEM , Transform( &nPosCp. ,X3PICTURE(Fieldname(nX)) ) )
					Endif
					dbSelectArea("LFD")
				Next nX
			EndIf                             
			
			// Gera dados da primeira parcela.
			aParcela := t_GMGerPriTit( LJO->LJO_TPSIST ,LJO->LJO_TAXANO ,0 ,LFD->LFD_INTERV ,LJO->LJO_NUMPAR ,LJO->LJO_VALOR ,LJO->LJO_TPPRIC ,GMDateDiff( LJO->LJO_JURINI ,LJO->LJO_1VENC,"m") )
			                          // "VALOR_TOTAL"
			OLE_SetDocumentVar( oWord, STR0026+LJO->LJO_ITEM , Transform( LJO->LJO_VALOR ,"@E 999,999,999.99" ) )
									  //"VALOR_PARCELA" 
			OLE_SetDocumentVar( oWord, STR0027+LJO->LJO_ITEM , Transform( aParcela[1] ,"@E 999,999,999.99" ) )
			
			dbSelectArea("LJO")
			dbSkip()
		Enddo
//	EndIf
EndIf

dbSelectArea("LIU")  //equivale ao SD2
LIU->(dbSetOrder(3)) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
For nX := 1 To Len(aColsCON)
	// se o item nao foi deletado
	If !(aColsCON[nX,nUsado+1])
		IF LIU->(MSSeek(xFilial("LIU")+LIT->LIT_NCONTR+aColsCON[nX,nPosCod]+aColsCON[nX,nPosIte]))
			//RegToMemory("LIU",.F.)
			ProcRegua( fCount() )
			For nY:=1 To fCount()
				IncProc()
				nPosCp:= "M->"+Fieldname(nY)+aColsCON[nX,nPosIte]
				&(nPosCp) := FieldGet(nY)
				IF !Empty(Posicione("SX3", 2, Fieldname(nY) , "x3CBox()")   )
					OLE_SetDocumentVar( oWord, Fieldname(nY)+aColsCON[nX,nPosIte] , QA_CBox(Fieldname(nY),&nPosCp) )
				Else
					OLE_SetDocumentVar( oWord, Fieldname(nY)+aColsCON[nX,nPosIte] , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
				Endif	
				dbSelectArea("LIU")
			Next nY
		Endif                   
		
		IF cCodEmp1 != aColsCON[nX,nPosEmp]
			// Cadastro da unidades do Empreendimento
			dbSelectArea("LIQ")
			LIQ->(dbSetOrder(1)) // LIQ_FILIAL+LIQ_COD
			IF LIQ->(MSSeek(XFilial("LIQ")+aColsCON[nX,nPosEmp])) //
				//RegToMemory("LIQ",.F.)
				ProcRegua( fCount() )
				For nY:=1 To fCount()
					IncProc()
					nPosCp:= "M->"+Fieldname(nY)+aColsCON[nX,nPosIte]
					&(nPosCp) := FieldGet(nY)
					IF !Empty(Posicione("SX3", 2, Fieldname(nY) , "x3CBox()") )
						OLE_SetDocumentVar( oWord, Fieldname(nY)+aColsCON[nX,nPosIte] , QA_CBox(Fieldname(nY),&nPosCp) )
					Else
						OLE_SetDocumentVar( oWord, Fieldname(nY)+aColsCON[nX,nPosIte] , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
					Endif
					dbSelectArea("LIQ")
				Next nY

	 			OLE_SetDocumentVar( oWord, "LIQ_UNID"+aColsCON[nX,nPosIte] , Transform( T_GEMLIQUNI( LIQ->LIQ_CODEMP ,LIQ->LIQ_STRPAI ,LIQ->LIQ_COD ) ,X3PICTURE( "LIQ_UNID" ) ) )
				
				//Cadastro de empreendimento
				dbSelectArea("LK3")  
				dbSetOrder(1) // LK3_FILIAL+LK3_CODEMP+LK3_DESCRI
				If MSSeek(XFilial("LK3")+LIQ->LIQ_CODEMP)
					RegToMemory("LK3",.F.)
					ProcRegua( fCount() )
					For nY:=1 To fCount()
						IncProc()
						nPosCp:= "M->"+Fieldname(nY)+aColsCON[nX,nPosIte]
						&(nPosCp) := FieldGet(nY)
						If !Empty(Posicione("SX3", 2, Fieldname(nY) , "x3CBox()") )
							OLE_SetDocumentVar( oWord, Fieldname(nY)+aColsCON[nX,nPosIte] , QA_CBox(Fieldname(nY),&nPosCp) )
						Else
							OLE_SetDocumentVar( oWord, Fieldname(nY)+aColsCON[nX,nPosIte] , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
						Endif
						dbSelectArea("LK3")  
					Next nY
				EndIf	
				
			Endif
			
			dbSelectArea("LEJ") // Cadastro de Cartorio
			MSSeek(xFilial("LEJ")+M->LIQ_CARTOR)
			ProcRegua( fCount() )
			For nY:=1 To fCount()
				IncProc()
				nPosCp:= "M->"+Fieldname(nY)+aColsCON[nX,nPosIte]
				&(nPosCp) := FieldGet(nY)
				IF !Empty(Posicione("SX3", 2, Fieldname(nY) , "x3CBox()")   )
					OLE_SetDocumentVar( oWord, Fieldname(nY)+aColsCON[nX,nPosIte] , QA_CBox(Fieldname(nY),&nPosCp) )
				Else
					OLE_SetDocumentVar( oWord, Fieldname(nY)+aColsCON[nX,nPosIte] , Transform( &nPosCp. ,X3PICTURE( Fieldname(nX) ) ) )
				Endif
 				dbSelectArea("LEJ")  
			Next nY

			cCodEmp1:=aColsCON[nX,nPosEmp]
			dbSelectArea("LIU")  //equivale ao SD2
		Endif
	EndIf
Next

// "Transferindo dados do sistema em caso Customizacao"
IF ExistBlock("GEMVCON")
	ExecBlock("GEMVCON", .F., .F. )
Endif

OLE_UpdateFields( oWord )

// "Ajustando propriedades do editor"
OLE_SetProperty( oWord, oleWdVisible, (mv_par01==1)/*.T.*/ )
               
If mv_par01==1 //Visualiza 1=SIM 2=NAO
	lApaga := .F.
	
	nCount := 1
	FErase(cPathWTmp + cArqDOT)  //tenta apagar logo de primeira
									// se nao conseguir eh pq o arq esta em uso
	While File(cPathWTmp + cArqDOT)
		If nCount == 1000
			FErase(cPathWTmp + cArqDOT)
			If File(cPathWTmp + cArqDOT) .And. Aviso(STR0012, STR0013, {STR0014, STR0015}, 2)==1 //"Atencao"###"Emitido o Contrato ?"###"Sim"###"Nao"
				lApaga := .T.
				Exit
			ElseIf File(cPathWTmp + cArqDOT) //tenta apagar novamente
				FErase(cPathWTmp + cArqDOT)
			EndIf
			nCount := 1
		EndIf
		nCount++
	EndDo
Else
	OLE_SetProperty( oWord, oleWdPrintBack, .f. )
	OLE_PrintFile( oWord, "ALL",,, mv_par02 )
	lApaga := .T.
Endif

OLE_CloseFile( oWord )
OLE_CloseLink( oWord )

If lApaga
	fErase(cPathWTmp + cArqDOT)
EndIf

RestArea(aArea)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConPath   ºAutor  ³Telso Carneiro      º Data ³  21/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de Verificacao que                                  º±±
±±º          ³ Retorna um array com dados dos Paths utilizados no sistema º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GFXImpCON                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function ConPath()

Local cPathTmp 	:= Alltrim( GetMV("MV_GMPATHT",.F.,"GETTEMPPATH()") )
Local cPathMode := Alltrim( GetMV("MV_GMPATHM",.F.,"\SYSTEM\MODELOS") )
Local cQPathDir := "protheus_tmp\"
Local aPatchs	:= {}

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

If UPPER(cPathTmp) == "GETTEMPPATH()"
	cPathTmp := &(cPathTmp)
	
	If Right( cPathTmp, 1 ) # "\"
		cPathTmp  += "\"
	Endif
	
	cPathTmp := cPathTmp+cQPathDir
	
	MakeDir(cPathTmp)
	
Endif

If Right( cPathMode, 1 ) # "\"
	cPathMode += "\"
Endif

aPatchs := {cPathTmp,cPathMode}

Return(aPatchs)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMNextMont³ Autor ³ Reynaldo Miyashita    ³ Data ³ 01.03.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula as data de vencimento e os valores das prestacoes    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GMNextMonth( dData ,nMes )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GMNextMonth( dData ,nMes )
Local nMesIni  := Month(dData)
Local nAno     := Year(dData)
Local dRetorno := stod("")

DEFAULT nMes := 1

	nMesIni += nMes
	
	While nMesIni > 12
		nMesIni -= 12
		nAno += 1
	EndDo

	// obtem o ultimo dia do mes
	dRetorno := LastDay(stod(strzero(nAno,4)+strzero(nMesIni,2)+"01") )

	If day(dRetorno) > day(dData)
		dRetorno := stod(strzero(nAno,4)+strzero(nMesIni,2)+strzero(day(dData),2))
	EndIf
	
Return( dRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GMPrevMontºAutor  ³Reynaldo Miyashita  º Data ³  11.05.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula uma data a partir de uma data e o numero de meses  º±±
±±º          ³ retrocedentes.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Parametros³ExpD1 - Data Inicio                                         ³±±
±±³          ³ExpN2 - Quantidade numero de meses                          ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GMPrevMonth( dData ,nMeses )
Local nMesIni   := Month(dData)
Local nAnoIni   := Year(dData)
Local nCount    := 0
Local dRetorno  := stod("")

DEFAULT nMeses := 1
    
	For nCount := 1 To nMeses
		If nMesIni = 1
			nMesIni := 12
			nAnoIni -= 1
		Else 
			nMesIni--
		EndIf
		
	Next nCount

	// obtem o ultimo dia do mes/ano anterior solicitado
	dRetorno :=  LastDay(stod(strzero(nAnoIni,4)+strzero(nMesIni,2)+"01"))
	
	// se o dia for maior que o dia do mes informado 
	If day(dRetorno) > day(dData)
		dRetorno := stod(strzero(nAnoIni,4)+strzero(nMesIni,2)+strzero(day(dData),2))
	EndIf
	
Return( dRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMDateDiff³ Autor ³ Reynaldo Miyashita    ³ Data ³ 28.04.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula dias, meses ou anos de diferenca entre as duas datas ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GMDateDiff( dInicio ,dFim ,cDataPart )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dInicio = Data de Inicio                                     ³±±
±±³            dFim    = Data de Fim                                        ³±±
±±³            cDataPart = Retorno do valor da diferenca                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nRetorno = Valor da diferenca no formado definido em         ³±±
±±³            cDataPart.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GMDateDiff( dInicio ,dFim ,cDataPart )
Local nRetorno   := 0
Local dData      := stod("")
Local lInvertido := .F.

DEFAULT cDataPart := "D"
	
	If dInicio > dFim
		dData   := dInicio 
		dInicio := dFim
		dFim    := dData     
		dData   := stod("")
		lInvertido := .T.
	EndIf
	
	cDataPart := upper( cDataPart )
	
	Do Case
		// se quiser saber a diferenca em anos
		Case cDataPart = "YY" .OR. cDataPart = "YYYY" 
		
			dData := dInicio 
			While dData >= dInicio .AND. dData < dFim
				nRetorno++
				dData := stod(strzero(year(dData),4)+strzero(Month(dData)+1,2)+"01")
			EndDo
			
		// se quiser saber a diferenca em meses
		Case cDataPart = "M" .OR. cDataPart = "MM" 
		                
			dData := GMNextMonth( stod(left(dtos(dInicio),6)+"01"), 1)
			dFim  := stod(left(dtos(dFim),6)+"01")
			While dtos(dData) > dtos(dInicio) .AND. dtos(dData) <= dtos(dFim)
				nRetorno++
				dData := GMNextMonth( dData, 1)
			EndDo
			
		// se quiser saber a diferenca em dias
		Case cDataPart = "D" .OR. cDataPart = "DD" 
			nRetorno := dFim - dInicio
			
	EndCase    
	
	If lInvertido 
		nRetorno := nRetorno*-1
	EndIf
	
Return( nRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMContrSta³ Autor ³ Reynaldo Miyashita    ³ Data ³ 16.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica o status do contrato para edicao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³t_GMContrStatus( cContrato )                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cContrato = Numero do contrato                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lContinua = permite edicao ou nao do contrato                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GMContrStatus( cContrato )
Local aArea     := GetArea()  
Local lContinua := .T. 

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return (.F.)
EndIf

	dbSelectArea("LIT")
	LIT->(dbSetOrder(2)) // LIT_FILIAL+LIT_NCONTR
	If dbSeek(xFilial("LIT")+cContrato )
		If LIT->LIT_STATUS == "2"
			Help("",1,"GEM_CONTRSTATUS",,OemToAnsi(STR0009)+CRLF+OemToAnsi(STR0010),1) //"Este contrato já foi ENCERRADO,"###"não pode haver alterações."
			lContinua := .F.
		ElseIf LIT->LIT_STATUS == "3"
			Help("",1,"GEM_CONTRSTATUS",,OemToAnsi(STR0011)+CRLF+OemToAnsi(STR0010),1) //"Este contrato já foi CANCELADO,"###"não pode haver alterações."
			lContinua := .F.
		ElseIf LIT->LIT_STATUS == "4"
			Help("",1,"GEM_CONTRSTATUS",,OemToAnsi(STR0028)+CRLF+OemToAnsi(STR0010),1) //"Este contrato já efetuado a Cessão de Direito," # "não pode haver alterações."
			lContinua := .F.
		ElseIf LIT->LIT_STATUS == "5"
			Help("",1,"GEM_CONTRSTATUS",,OemToAnsi(STR0029)+CRLF+OemToAnsi(STR0010),1) //"Este contrato está em processo de Distrato," # "não pode haver alterações."
			lContinua := .F.
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return( lContinua )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMHistCont³ Autor ³ Reynaldo Miyashita    ³ Data ³ 30.05.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o Historico do contrato                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³t_GMHistContr( cContrato ,cRevisa ,cRevNovo ,cCondicao        ³±± 
±±³          ³               ,cCodCliente ,cLoja ,cStatus )                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GMHistContr( cContrato ,cRevAtual ,cRevNovo ,cCondicao ,cCodCliente ,cLoja ,cStatus )
Local aArea     := GetArea()
Local aRecord   := {}
Local nCount    := 0
Local nVend     := 0
Local nPos      := 0
Local nMaxVend  := Fa440CntVen()

DEFAULT cCondicao    := ""
DEFAULT cCodCliente  := ""
DEFAULT cLoja        := ""
DEFAULT cStatus      := ""

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

	// LIT - cadastro de contratos
	dbSelectArea("LIT")
	dbSetOrder(2) //LIT_FILIAL+LIT_NCONTR
	If dbSeek(xFilial("LIT")+cContrato)
		// Revisao atual do contrato
		//cRevAtual := LIT->LIT_REVISA
		
		//
		// Detalhamento dos titulos a receber
		//
		dbSelectArea("LIX")
		dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
		dbSeek(xFilial("LIX")+LIT->LIT_NCONTR)
		While LIX->(!Eof()) .AND. LIX->(LIX_FILIAL+LIX_NCONTR) == xFilial("LIX")+LIT->LIT_NCONTR
			//
			// SE1 - Titulos a receber
			//
			dbSelectArea("SE1")
			dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->( dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO)) )
		      
				// Historico dos titulos a receber
				//
				RecLock("LJE",.T.)
					LJE->LJE_FILIAL := xFilial("LJE")
					LJE->LJE_PREFIX := SE1->E1_PREFIXO 
					LJE->LJE_NUM    := SE1->E1_NUM     
					LJE->LJE_PARCEL := SE1->E1_PARCELA 
					LJE->LJE_TIPO   := SE1->E1_TIPO    
					LJE->LJE_NATURE := SE1->E1_NATUREZ 
					LJE->LJE_CLIENT := SE1->E1_CLIENTE 
					LJE->LJE_LOJA   := SE1->E1_LOJA    
					LJE->LJE_NOMCLI := SE1->E1_NOMCLI  
					LJE->LJE_EMISSA := SE1->E1_EMISSAO 
					LJE->LJE_VENCTO := SE1->E1_VENCTO  
					LJE->LJE_VENCRE := SE1->E1_VENCREA 
					LJE->LJE_VALOR  := SE1->E1_VALOR   
					LJE->LJE_BAIXA  := SE1->E1_BAIXA
					LJE->LJE_EMIS1  := SE1->E1_EMIS1   
					LJE->LJE_HIST   := SE1->E1_HIST
					LJE->LJE_LA     := SE1->E1_LA   
					LJE->LJE_MOVIME := SE1->E1_MOVIMEN
					LJE->LJE_SITUAC := SE1->E1_SITUACA 
					LJE->LJE_CONTRA := SE1->E1_CONTRAT
					LJE->LJE_SALDO  := SE1->E1_SALDO
					LJE->LJE_VALLIQ := SE1->E1_VALLIQ
					LJE->LJE_VENCOR := SE1->E1_VENCORI 
					LJE->LJE_VALJUR := SE1->E1_VALJUR
					LJE->LJE_PORCJU := SE1->E1_PORCJUR
					LJE->LJE_MOEDA  := SE1->E1_MOEDA  
					LJE->LJE_OK     := SE1->E1_OK     
					LJE->LJE_PEDIDO := SE1->E1_PEDIDO  
					LJE->LJE_VLCRUZ := SE1->E1_VLCRUZ  
					LJE->LJE_SERIE  := SE1->E1_SERIE   
					LJE->LJE_STATUS := SE1->E1_STATUS  
					LJE->LJE_ORIGEM := SE1->E1_ORIGEM
					LJE->LJE_FILORI := SE1->E1_FILORIG 
					LJE->LJE_MSFIL  := SE1->E1_MSFIL
					LJE->LJE_MSEMP  := SE1->E1_MSEMP

					LJE->LJE_DESCON := SE1->E1_DESCONT
					LJE->LJE_MULTA  := SE1->E1_MULTA
					LJE->LJE_CORREC := SE1->E1_CORREC
					
					LJE->LJE_PRORAT := SE1->E1_PRORATA
					
					LJE->LJE_AMORT  := LIX->LIX_ORIAMO
					LJE->LJE_PVLJUR := LIX->LIX_ORIJUR
						  
					//
					// ultima correcao monetaria aplicada ao titulo
					//
					aVlrCM := ExecTemplate("CMDtPrc",.F.,.F.,{LIX->LIX_PREFIX ,LIX->LIX_NUM ,LIX->LIX_PARCEL ,dDatabase ,SE1->E1_VENCREA})
					
					LJE->LJE_CMAMOR := aVlrCM[2]
					LJE->LJE_CMJUR  := aVlrCM[3]
					
					dbSelectArea("SE1")
					For nVend := 1 To nMaxVend
						If (nPos := FieldPos("LJE_VEND"+Alltrim(Str(nVend)))) >0
							cConteudo := SE1->(FieldGet(FieldPos("E1_VEND"+Alltrim(Str(nVend)))))
							LJE->(FieldPut(nPos ,cConteudo))
						EndIf
					Next nVend
					LJE->LJE_NCONTR := LIT->LIT_NCONTR
					LJE->LJE_REVISA := cRevAtual 
					
				LJE->(MSUnlock())
			
			Else
				MsgAlert(STR0016+AllTrim(LIX->LIX_PREFIX)+"/"+AllTrim(LIX->LIX_NUM)+"/"+AllTrim(LIX->LIX_PARCEL)+"/"+LIX->LIX_TIPO+STR0017,STR0012) //"O pref/título/parcela/tipo "####" não foi encontrado no contas a receber!"      "###"Atencao!"
			EndIf
			
			dbselectArea("LIX")
			dbSkip()
			
		EndDo
		
	    //
	    // Condicao de venda do contrato
	    //
		dbSelectArea("LJO")
		dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
		dbSeek(xFilial("LJO")+cContrato )
		While LJO->(!Eof()) .AND. LJO->LJO_FILIAL+LJO->LJO_NCONTR == xFilial("LJO")+cContrato
			RecLock("LJO",.F. ,.T.)
			aRecord := {}
			For nCount := 1 to FCount()
				aAdd( aRecord ,{substr(FieldName(nCount),4) ,LJO->(FieldGet(nCount))} )
			Next nCount
			LJO->(MsUnlock())
	
			// Historico da condicao de venda
			dbSelectArea("LJP")
			RecLock("LJP",.T.)
				For nCount := 1 to Len(aRecord)
					If (nPos := LJP->(FieldPos( "LJP"+aRecord[nCount][1] )))>0
						LJP->(FieldPut( nPos ,aRecord[nCount][2] ))
					EndIf
				Next nCount
				LJP->LJP_REVISA := cRevAtual
			LJP->(MsUnlock())
			
			dbSelectArea("LJO")
			LJO->(dbSkip())
		EndDo
	    
		// LK6 - Cadastro dos solidarios do contrato
		dbSelectArea("LK6")
		dbSetOrder(1) // LK6_FILIAL+LK6_NCONTR+LK6_CODSOL+LK6_LJSOLI
		dbSeek(xFilial("LK6")+cContrato )
		While LK6->(!Eof()) .AND. LK6->LK6_FILIAL+LK6->LK6_NCONTR == xFilial("LK6")+cContrato
			RecLock("LK6",.F. ,.T.)
			aRecord := {}
			For nCount := 1 to FCount()
				aAdd( aRecord ,{substr(FieldName(nCount),4) ,FieldGet(nCount)} )
			Next nCount
			LK6->(MsUnlock())
			
			// atualiza o cliente e loja dos itens do contrato
			dbSelectArea("LJF")
			RecLock("LJF",.T.)
				For nCount := 1 to Len(aRecord)
					If (nPos := FieldPos( "LJF"+aRecord[nCount][1] )) >0
						LJF->(FieldPut( nPos ,aRecord[nCount][2] ))
					EndIf
				Next nCount
				LJF->LJF_REVISA := cRevAtual
			LJF->(MsUnlock())
			
			dbSelectArea("LK6")
			dbSkip()
		EndDo
	
		// LIU - cadastro de itens do contrato original negociado na renegociacao
		dbSelectArea("LIU")
		dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
		MSSeek(xFilial("LIU")+LIT->LIT_NCONTR)
		While LIU->(!eof()) .AND. LIU->(LIU_FILIAL+LIU_NCONTR) == xFilial("LIU")+LIT->LIT_NCONTR
				
			RecLock("LIU",.F. ,.T.)
			aRecord := {}
			For nCount := 1 to FCount()
				aAdd( aRecord ,{substr(FieldName(nCount),4) ,FieldGet(nCount)} )
			Next nCount
			
			//
			// Se existir cliente, deve excluir e adicionar os registros com cliente/loja
			//
			If ! Empty(cCodCliente)
			
				LIU->(dbDelete())
				
				// atualiza o cliente e loja dos itens do contrato
				RecLock("LIU",.T.)
					For nCount := 1 to Len(aRecord)
						LIU->(FieldPut( nCount ,aRecord[nCount][2] ))
					Next nCount
					
					LIU->LIU_CLIENT := cCodCliente
					LIU->LIU_LOJA   := cLoja
				LIU->(MsUnlock())
			EndIf		
			
			// historico dos itens do contrato 
			RecLock("LJB",.T.)
				For nCount := 1 to Len(aRecord)
					If (nPos := FieldPos( "LJB"+aRecord[nCount][1] ) )>0
						LJB->(FieldPut( nPos,aRecord[nCount][2] ))
					EndIf
				Next nCount
				LJB->LJB_REVISA := cRevAtual
			LJB->(MsUnlock())
			
			LIU->(dbSkip())
		EndDo
			
		//
		// Copia o cabecalho do contrato 
		//
		dbSelectArea("LIT")
		RecLock("LIT",.F.)
			aRecord := {}
			For nCount := 1 to FCount()
				aAdd( aRecord ,{substr(FieldName(nCount),4) ,FieldGet(nCount)} )
			Next nCount
			
			LIT->(dbDelete())
			
		LIT->(MsUnlock())
		
		// LJA - cadastro de contrato original negociado na renegociacao
		dbSelectArea("LJA")
		RecLock("LJA",.T.)
			For nCount := 1 to Len(aRecord)
				If (nPos := FieldPos( "LJA"+aRecord[nCount][1] ) )>0
					LJA->(FieldPut( nPos ,aRecord[nCount][2] ))
				EndIf
			Next nCount
			LJA->LJA_REVISA := cRevAtual
		LJA->(MsUnlock())
		
		// LIT - Grava o contrato com nova revisao
		dbSelectArea("LIT")
		RecLock("LIT",.T.)
			For nCount := 1 to Len(aRecord)
				LIT->(FieldPut( nCount ,aRecord[nCount][2] ))
			Next nCount
			
			LIT->LIT_REVISA := cRevNovo
			
			If ! Empty(cCondicao)
				LIT->LIT_COND := cCondicao
			EndIf
			
			If ! Empty(cCodCliente)
				LIT->LIT_CLIENT := cCodCliente
				LIT->LIT_LOJA   := cLoja
				LIT->LIT_NOMCLI := Posicione( "SA1" ,1 ,xFilial("SA1")+LIT->LIT_CLIENT+LIT->LIT_LOJA ,"A1_NOME")
			EndIf
			
			If ! Empty(cStatus)
				LIT->LIT_STATUS := cStatus
			EndIf
			
		LIT->(MsUnlock())
		
    EndIf
    
	RestArea(aArea)
	
Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GMUpdStatC³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o status do contrato                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³t_GMUpdStatContr()                                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function GMUpdStatContr()
Local aArea    := GetArea()
Local aAreaSE1 := GetArea("SE1")
Local lPago    := .T.
Local cTitulo  := iIf( Empty(ParamIXB[1]) ,"" ,ParamIXB[1] )
Local cSerie   := iIf( Empty(ParamIXB[2]) ,"" ,ParamIXB[2] )
Local cPrefixo := iIf( Empty(ParamIXB[3]) ,"" ,ParamIXB[3] )
Local cFilSE1  := xFilial("SE1")

cSerie := ""

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return .T. 
EndIf

//
// Detalhes do titulo a receber
//
dbSelectArea("LIX")
dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
If dbSeek( xFilial("LIX")+cPrefixo+cTitulo)
	//
	// cabecalho do contrato
	//
	dbSelectArea("LIT")
	dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
	If dbSeek( xFilial("LIT")+LIX->LIX_NCONTR)
		// se for contrato em aberto ou encerrado
		If LIT->LIT_STATUS $ "1;2" 
			// verifica todos os titulos a receber
			dbSelectArea("SE1")
			dbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			dbSeek(cFilSE1+LIX->(LIX_PREFIX+LIX_NUM))
			While SE1->(!Eof()) .AND. cFilSE1+LIX->(LIX_PREFIX+LIX_NUM) == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM)
				If SE1->E1_SALDO <> 0
					lPago := .F.
					Exit
				EndIf
				dbSelectArea("SE1")
				dbSkip()
			EndDo
			
			RecLock("LIT",.F.)
				// se todos foram recebidos, atualiza o status do contrato para concluido.
				If lPago
					LIT->LIT_STATUS := "2" // encerrado
				Else 
					LIT->LIT_STATUS := "1" // em aberto
				Endif
			LIT->(MSUnLock())
		EndIf
	EndIf
	
EndIf

RestArea(aArea)
RestArea(aAreaSE1)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GEMXPV    ³ Autor ³ Reynaldo Miyashita    ³ Data ³ 04.06.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atual2iza o status do empreendimento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³t_GEMXPV()                                                    ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMXPV()
Local aArea    := {}   
Local lExclui  := iIf( Empty(ParamIXB[1]) ,.F. ,ParamIXB[1] )
Local cCodEmpr := iIf( Empty(ParamIXB[2]) ,""  ,ParamIXB[2] )    
Local nOpcao	:= iIf( Empty(ParamIXB[3]) ,1  ,ParamIXB[3] )    

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return .T. 
EndIf

	aArea    := GetArea()
	
	//
	// Altera o status do empreendimento 
	//  
	dbSelectArea("LIQ")
	If LIQ->(MSSeek(xFilial("LIQ")+cCodEmpr ))
		RecLock("LIQ",.F.)
			//
			// Item do pedido de vendas foi excluido, o status deve ser "LV" - Livre
			//
		If nOpcao == 1
			// "LV" - Livre 
			LIQ->LIQ_STATUS := "LV"			
		Else
			If lExclui
				// "LV" - Livre 
				LIQ->LIQ_STATUS := "LV"
			Else 
	 			// "RE" - Reservado
				LIQ->LIQ_STATUS := "RE"
			EndIf
		EndIf	
		MsUnLock()
	EndIf

	RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GMXORCVldEºAutor  ³Reynaldo Miyashita  º Data ³  05.07.05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valid e Trigger do Campo codigo do Empreendimento no       º±±
±±º          ³  orcamento de vendas.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valid do Campo CK_CODEMPR                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function GMXORCVldEmp()
Local lRet	:=.F.
Local aArea := GetArea()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios
ChkTemplate("LOT")

dbSelectArea("LIQ")
LIQ->(dbSetOrder(1)) // LIQ_FILIAL+LIQ_COD
If LIQ->(dbSeek(xFilial("LIQ")+M->CK_CODEMPR))
	// "LV" - LIVRE
	If LIQ->LIQ_STATUS == "LV"
		TMP1->CK_PRODUTO := LIQ->LIQ_CODPRD
		__readvar := "M->CK_PRODUTO"
	
		lRet:=CheckSX3("CK_PRODUTO",TMP1->CK_PRODUTO)
	
		IF lRet
			//-- Executa Gatilhos
			If ExistTrigger("CK_PRODUTO")
				RunTrigger(1,,,, "CK_PRODUTO")
			EndIf
		Endif
	Else
		Help( " " ,1 ,"EMPRSTAT" ,,STR0030,1) //"Este Empreendimento não pode ser reservado."
		
    EndIf
EndIf

RestArea(aArea)
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMAMsRel ºAutor  ³Reynaldo Miyashita  º Data ³  18.07.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona o relacionamento da tabela de contratos com as    º±±
±±º          ³ outras tabelas para gerenciamento de documentos            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ matxfunc.prw - msrelation()                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMAMsRel()
Local aRelacao := {}

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If HasTemplate("LOT")
	aAdd( aRelacao ,{ "LIT", { "LIT_NCONTR" }, { || LIT->LIT_NCONTR } } )
EndIf

Return( aRelacao )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMTitRec ºAutor  ³Reynaldo Miyashita  º Data ³  03.08.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula a CM em atraso, Juros Mora e multa de um titulo a  º±±
±±ºDesc.     ³ receber do contrato em atraso.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMTitRec()

Local cPrefixo := iIf(Len(ParamIXB)>0,iIf(Empty(ParamIXB[1]) ,Space(len(SE1->E1_PREFIXO)),ParamIXB[1] ),Space(len(SE1->E1_PREFIXO)) )
Local cNumero  := iIf(Len(ParamIXB)>1,iIf(Empty(ParamIXB[2]) ,Space(len(SE1->E1_NUM)),ParamIXB[2] ),Space(len(SE1->E1_NUM)) )
Local cParcela := iIf(Len(ParamIXB)>2,iIf(Empty(ParamIXB[3]) ,Space(len(SE1->E1_PARCELA)),ParamIXB[3] ),Space(len(SE1->E1_PARCELA)) )
Local nVlrCM   := iIf(Len(ParamIXB)>3,iIf(Empty(ParamIXB[4]) ,0         ,ParamIXB[4] ),0 )
Local nVlrRata := iIf(Len(ParamIXB)>4,iIf(Empty(ParamIXB[5]) ,0         ,ParamIXB[5] ),0 )
Local dRef     := iIf(Len(ParamIXB)>5,iIf(Empty(ParamIXB[6]) ,dDatabase ,ParamIXB[6] ),dDatabase )

Local nVlrParcela := 0
Local nIndJurMora := 0
Local nDiasAtraso := 0
Local nPeriodo    := 0
Local dDateSeek   := stod("")
Local dUltBaixa   := stod("")

Local nVlrJurosMora := 0
Local nVlrMulta     := 0

Local aArea       := GetArea()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( {nVlrJurosMora,nVlrMulta} )
EndIf

// titulo a receber
dbSelectArea("SE1")
dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
If MsSeek(xFilial("SE1")+cPrefixo+cNumero+cParcela)
	
	dDateSeek := dRef
	
	// detalhes do titulo a receber							    
	dbSelectArea("LIX")
	dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	If dbSeek(xFilial("LIX")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA))
	
		//
		// Inicia o calculo do Juros e Multa
		//
	
		// verifica se o titulo tem saldo a receber e se esta vencido.
		If SE1->E1_SALDO > 0 .AND. dTos(SE1->E1_VENCREA) < dTos(dRef)
		
			nVlrParcela := SE1->E1_SALDO
			nVlrParcela += nVlrCM          // Valor da Correcao Monetaria
			nVlrParcela += nVlrRata        // Valor da Pro-Rata por atrasao diario ( Correcao Monetaria )
			dVencto     := SE1->E1_VENCREA 
			dUltBaixa   := IIF( Empty(SE1->E1_BAIXA) ,dVencto ,SE1->E1_BAIXA )
		
				// cadastro de contratos
			dbSelectArea("LIT")
			dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
			If dbSeek(xFilial("LIT")+LIX->LIX_NCONTR)
				
				// condicao de venda do contrato
				dbSelectArea("LJO")
				dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
				If dbSeek(xFilial("LJO")+LIX->(LIX_NCONTR+LIX_ITCND))
					//
					// obtem os dias de atraso entre a data referencia e o vencimento
					nDiasAtraso := dRef - dUltBaixa
					If ( Dow(dVencto) == 1 .Or. Dow(dVencto) == 7 )
						If Dow(dRef) == 2 .and. nDiasAtraso <= 2
							nDiasAtraso := 0
						EndIf
					EndIf
					nDiasAtraso := Iif(nDiasAtraso<0 ,0 ,nDiasAtraso )
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Compara dias de atraso com o parametro tolerancia de atraso  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nDiasAtraso <= GetMv("MV_TOLER")
						nDiasAtraso := 0
					EndIf
	
					If nDiasAtraso >0
					    
						nIndJurMora := LIT->LIT_JURMOR
						If LIT->(FieldPos("LIT_JURTIP")) >0 .AND. LIT->LIT_JURTIP == "3"
							nIndJurMora := LIT->LIT_JURMOR/30
						EndIf
						
						If LIT->(FieldPos("LIT_JURTIP")) >0 .AND. LIT->LIT_JURTIP == "2"
							// se a ultima baixa for menor q a baixa
							If dtos(dRef) > dtos(dUltBaixa)
								nPeriodo := (dRef-dUltBaixa)/30
								nPeriodo := Int(nPeriodo) + iIf(nPeriodo-Int(nPeriodo) >0 ,1 ,0)
							
							EndIf
			
						Else
							nPeriodo := nDiasAtraso
						EndIf

						//
						// calculo do Juros Mora diario do titulo a receber em atraso
						//
						nVlrJurosMora := round(CalcJrMora(nVlrParcela ,nIndJurMora ,nPeriodo ) ,TamSX3("E5_VALOR")[2])
						
						//
						// se a data de vencimento for igula a data da ultima baixa, quer dizer que não foi efetuado nenhuma baixa parcial
						//
						If (dVencto == dUltBaixa)
							//
							// calculo da multa mensal do titulo a receber em atraso
							//
							nVlrMulta := round(CalcMulta(nVlrParcela ,LIT->LIT_MULTA),TamSX3("E5_VALOR")[2])
				        Else
					        nVlrMulta := 0
				        EndIf
				        
					EndIf
					
				EndIf // busca o item da condicao de venda do contrato
			EndIf // busca de contrato
		EndIf
	EndIf
Endif // busca de titulos a receber

RestArea( aArea )

Return( {nVlrJurosMora,nVlrMulta} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMAtraCalºAutor  ³Reynaldo Miyashita  º Data ³  03.08.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula a Pro Rata diaria de atraso, Juros Mora e multa    º±±
±±º          ³ sobre o valor da parcela.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMAtraCalc( nVlrParcela ,dVencto ,cTaxa ,nMes ,nDiaCorr ,nPercJurMora ,nPercMulta ,dRef ,cTipJur ,dUltBaixa )
Local nVlrProRata   := 0
Local nVlrJurosMora := 0
Local nVlrMulta     := 0
Local nDiasAtraso   := 0
Local nPeriodo      := 0

DEFAULT dRef      := dDatabase
DEFAULT nDiaCorr  := 1
DEFAULT cTipJur   := ""
DEFAULT dUltBaixa := stod("")
                 
	If Empty(dUltBaixa)
		dUltBaixa := dVencto
    EndIf
 
	nDiasAtraso := dRef - dUltBaixa

	If !(dUltBaixa >= dVencto)
		nDiasAtraso := 0
	EndIf
	
	//
	// obtem os dias de atraso entre a data referencia e o vencimento
	nDiasAtraso := dRef - dUltBaixa
	If ( Dow(dVencto) == 1 .Or. Dow(dVencto) == 7 )
		If Dow(dRef) == 2 .and. nDiasAtraso <= 2
			nDiasAtraso := 0
		EndIf
	EndIf
	nDiasAtraso := Iif(nDiasAtraso<0 ,0 ,nDiasAtraso )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Compara dias de atraso com o parametro tolerancia de atraso  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nDiasAtraso <= GetMv("MV_TOLER")
		nDiasAtraso := 0
	EndIf
	
	If nDiasAtraso >0 
		//
		// calculo do Juros Mora diario do titulo a receber em atraso
		//
		nVlrProRata := round(CalcProRat( dRef, dVencto, nVlrParcela, cTaxa, nMes, nDiaCorr ) ,TamSX3("E5_VALOR")[2])

		If cTipJur == "3"
			nPercJurMora := nPercJurMora/30
		EndIf
						
		If cTipJur == "2"
		
			// se a ultima baixa for menor q a baixa
			If dtos(dRef) > dtos(dUltBaixa)
				nPeriodo := (dRef-dUltBaixa)/30
				nPeriodo := Int(nPeriodo) + iIf(nPeriodo-Int(nPeriodo) >0 ,1 ,0)
			EndIf
			
		Else
			nPeriodo := nDiasAtraso
		EndIf

		//
		// calculo do Juros Mora diario do titulo a receber em atraso
		//
		nVlrJurosMora := round(CalcJrMora( nVlrParcela+nVlrProRata ,nPercJurMora ,nPeriodo ) ,TamSX3("E5_VALOR")[2])

		//
		// se a data de vencimento for igula a data da ultima baixa, quer dizer que não foi efetuado nenhuma baixa parcial
		//
		If (dVencto == dUltBaixa)
			//
			// calculo da multa mensal do titulo a receber em atraso
			//
			nVlrMulta := round(CalcMulta(nVlrParcela+nVlrProRata ,nPercMulta),TamSX3("E5_VALOR")[2])
		Else
			nVlrMulta := 0
		EndIf

	EndIf
	
Return( {nVlrProRata ,nVlrJurosMora ,nVlrMulta} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcProRatºAutor  ³Reynaldo Miyashita  º Data ³  03.08.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula a Pro Rata diaria de atraso sobre o valor da       º±±
±±º          ³ parcela.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcProRat( dRefer, dVencto, nValor, cTaxa, nMes, nDiaCorr )
Local dPriCorr       := stod("") // 1o dia do mes da correcao
Local dPriCorrAnt    := stod("") // 1o dia do mes anterior da correcao
Local nIndCorr       := 0
Local nDiaAtraso     := 0
Local nQtdDiasMes    := 0
Local nCMMesCorr     := 0
Local nProRata       := 0
Local aRetCoef       := {}  
Local aArea				:= GetArea()      
Local aAreaAAE	 		:= {}

DEFAULT dVencto := dDatabase
DEFAULT dRefer  := dDatabase
DEFAULT nValor  := 0
DEFAULT cTaxa   := ""   
            
//
// se data da baixa for maior que a data de vencimento deve ser calculado a prorata
//
If dRefer > dVencto .and. !Empty(cTaxa) .and. !(nValor == 0)

	// calcula o primeiro dia do mes de referencia(baixa)    
	dPriCorr := stod(strzero(year(dRefer),4)+strzero(month(dRefer),2)+ "01" )
			
	/*
	-----------------------------------------------------------------------------------------
				Busca Indices para calculo da diarizacao 
	-----------------------------------------------------------------------------------------
	*/
		
	// busca o indice da database para calculo da diarizacao
	// Se existir o indice para o mes, utiliza este indice, senao usa do mes anterior 
	dbSelectArea("AAE")
	aAreaAAE := AAE->(GetArea())
	dbSetOrder( 1 ) //AAE_FILIAL+AAE_CODIND+DTOS(AAE_DATA)
	If AAE->(MsSeek(xFilial("AAE")+cTaxa+left(dtos(dPriCorr) ,6)+strzero(nDiaCorr,2)))
		aRetCoef := T_GEMCoefCM( cTaxa , 0, stod(left(dtos(dPriCorr) ,6)+strzero(nDiaCorr,2)) )
	Else
		aRetCoef := T_GEMCoefCM( cTaxa , nMes, stod(left(dtos(dPriCorr) ,6)+strzero(nDiaCorr,2)) )
	Endif	
 	RestArea(aAreaAAE)

	nIndCorr  := aRetCoef[1]/aRetCoef[2]
	lContinua := Empty(aRetCoef[3])
	
	// Se nao houver indice da database, deve procurar por database - 1 mes
	If !lContinua .and. nIndCorr == 0
		dPriCorrAnt := GMPrevMonth(dPriCorr,1)
		aRetCoef := T_GEMCoefCM( cTaxa ,nMes ,stod(left(dtos(dPriCorrAnt),6)+strzero(nDiaCorr,2)) )
		nIndCorr := aRetCoef[1]/aRetCoef[2]
		lContinua := Empty(aRetCoef[3])
	EndIf
		
	If lContinua .and. !(nIndCorr==0)
		// se mes/ano da database for igual o mes/ano do vencimento, calcula o dia do vencimento ateh a data de pagamento
		If left(dtos(dRefer),6) == left(dtos(dVencto),6)  
           	// calcular os dias de atraso
			nDiaAtraso := dRefer - dVencto
		// se mes/ano da database for maior o mes/ano do vencimento, calcula o do primeiro dia do mes/ano do pagamento ate a data do mesmo. Isto é, a database é igual a data de pagamento
		Else
           	// calcular os dias de atraso
           	nDiaAtraso := dRefer -  stod(left(dtos(dRefer),6) + "01")
		EndIf
		
		// Dias de atraso, contando a partir do 1o. dia ateh o dia da database. 
		If nDiaAtraso >0 
			// Qtd de dias no mes corrente
			nQtdDiasMes := 30 // dProRataMaisUm - dProRata
		
			// ((Valor mes passado * indice mes atual) - valor mes passado) * (dias corridos / dias corridos mes)		
	  		nCMMesCorr := Round(nValor * nIndCorr,2)
	  		If nCMMesCorr < 0
	  			nCMMesCorr :=  nCMMesCorr * -1
	  		EndIf
	  		nCMMesCorr := nCMMesCorr - nValor 
	  		nProRata   := nCMMesCorr * (nDiaAtraso / nQtdDiasMes)
		EndIf
    EndIf
EndIf
	       
RestArea(aArea)	
	
	
Return( nProRata )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcMulta ºAutor  ³Reynaldo Miyashita  º Data ³  03.08.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcMulta(nVlrParcela ,nIndice)
Local nVlrMulta := 0

Default nVlrParcela := 0
Default nIndice     := 0

	//
	// calculo da multa mensal do titulo a receber em atraso
	//
	// formula: (valor do titulo* percentual de multa
	//
	If nIndice > 0
		nVlrMulta := nVlrParcela*(nIndice/100)
	EndIf

Return( nVlrMulta )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcJrMoraºAutor  ³Reynaldo Miyashita  º Data ³  03.08.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcJrMora(nVlrParcela ,nIndice ,nPeriodo )
Local nVlrJrMora := 0

Default nVlrParcela := 0
Default nIndice     := 0
Default nPeriodo    := 0

	//
	// calculo do Juros Mora diario do titulo a receber em atraso
	//
	// formula: (valor do titulo* percentual do indice diario *Qtd de dias atraso
	//
	If nIndice > 0
	
		nVlrJrMora := (nVlrParcela*(nIndice/100))*nPeriodo     
	EndIf
	
Return( nVlrJrMora )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMTitPag ºAutor  ³Reynaldo Miyashita  º Data ³  23.08.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula a CM e CM em atraso, Juros Mora e multa de um      º±±
±±ºDesc.     ³ titulo a pagar do contrato.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßß ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMTitPag()

Local cPrefixo      := iIf(Len(ParamIXB)>0,iIf(Empty(ParamIXB[1]) ,"" ,ParamIXB[1] ),"" )
Local cNumero       := iIf(Len(ParamIXB)>1,iIf(Empty(ParamIXB[2]) ,"" ,ParamIXB[2] ),"" )
Local cParcela      := iIf(Len(ParamIXB)>2,iIf(Empty(ParamIXB[3]) ,"" ,ParamIXB[3] ),"" )

Local nVlrParcela := 0
Local nVlrCM      := 0
Local nIndJurMora := 0 
Local nDiaCorr    := 0
Local nMesCorr    := 0
Local aRetorno    := {}
Local dVencto     := stod("")
Local dUltBaixa   := stod("")
Local aArea       := GetArea()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( {0,0,0} )
EndIf

// titulo a receber
dbSelectArea("SE2")
dbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
If dbSeek(xFilial("SE2")+cPrefixo+cNumero+cParcela)
			
	//
	// Inicia o calculo da CM do titulo a pagar
	//
	
	// titulos a pagar detalhado
	dbSelectArea("LJX")
	dbSetOrder(1) // LJX_FILIAL+LJX_PREFIX+LJX_NUM+LJX_PARCEL+LJX_TIPO+LJX_DTIND
	// procura a CM do mes/ano da databse
	If dbSeek(xFilial("LJX")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+left(dtos(dDataBase),6))
		// se database for menor que a data da CM
		If Day(dDataBase) >= Day( LJX->LJX_DTIND )
			nVlrCM := LJX->LJX_VLRAMO+LJX->LJX_VLRJUR
			lSeekPrev := .F.
		EndIf
	EndIf
	
	If lSeekPrev
		If dbSeek(xFilial("LJX")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+left(dtos(GMPrevMonth(dDataBase,1)),6))
			nVlrCM := LJX->LJX_VLRAMO+LJX->LJX_VLRJUR
		Else
			nVlrCM := 0
		EndIf
	EndIf

	//
	// Inicia o calculo da CM atraso, Juros e Multa
	//

	// verifica se o titulo tem saldo a receber e se esta vencido.
	If SE2->E2_SALDO > 0 .AND. dTos(SE2->E2_VENCREA) < dTos(dDataBase)
	
		nVlrParcela := SE2->E2_SALDO
		nVlrParcela += nVlrCM
		nIndCorr    := 0
		dVencto     := SE2->E2_VENCREA 
		dUltBaixa   := iIf(SE2->E2_BAIXA > SE2->E2_VENCREA ,SE2->E2_BAIXA ,SE2->E2_VENCREA )
	
		// cadastro de contratos
		dbSelectArea("LIT")
		dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
		If dbSeek(xFilial("LIT")+SE2->E2_NUM+SE2->E2_PREFIXO)
			nIndJurMora := LIT->LIT_JURMOR
			
			// Distrato do contrato
			dbSelectArea("LJD")
			dbSetOrder(1) // LJD_FILIAL+LJD_NCONTR+LJD_REVISA
			If dbSeek(xFilial("LJD")+LIT->LIT_NCONTR)
				// Detalhes do titulo a pagar
				dbSelectArea("LJV")
				dbSetOrder(1) // LJV_FILIAL+LJV_PREFIX+LJV_NUM+LJV_PARCEL+LJV_TIPO
				If dbSeek(xFilial("LJV")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
					// condicao de pagamento do distrato do contrato
					dbSelectArea("LJS")
					dbSetOrder(1) // LJS_FILIAL+LJS_NCONTR+LJS_REVISA+LJS_ITEM
					If dbSeek(xFilial("LJS")+LJD->LJD_NCONTR+LJD->LJD_REVISA+LJV->LJV_ITCND)
						//
						// Busca o indice da CM para ser aplicado na PRO-RATA diaria de atraso
						//
						cTaxa := LJS->LJS_IND 
						nMesCorr := LJS->LJS_NMES
						nDiaCorr := LJS->LJS_DIACOR
					EndIf
		
					//
					// Calcula a CM diaria em atraso, juros mora e multa
					//
					aRetorno := t_GEMAtraCalc( nVlrParcela ,dVencto ,cTaxa ,nMesCorr ,nDiaCorr ,nIndJurMora ,LIT->LIT_MULTA ,dDatabase ,LIT->LIT_JURTIP ,dUltBaixa)
					
				EndIf // DETALHES DO TITULO A PAGAR
			EndIf	 // busca do distrato
		EndIf // busca de contrato
	EndIf	
Endif // busca de titulos a pagar

RestArea( aArea )

If Empty(aRetorno)
	If nVlrCM > 0 
		aRetorno := {nVlrCM,0,0}
	EndIf
Else
	If nVlrCM > 0 
		aRetorno[1] += nVlrCM
	EndIf
EndIf

Return( aRetorno )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMTPLGEM ºAutor  ³Reynaldo Miyashita  º Data ³  07.11.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Desenvolvida a rotina para verificar se o template GEM     º±±
±±º          ³ está aplicado no RPO. Foi feito desta forma para não       º±±
±±º          ³ comprometer o Template LOT, já que ambos utilizam a mesma  º±±
±±º          ³ licença.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGEM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßß ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMTPLGEM()
Local lRetorno := .F.

	If HasTemplate("LOT")
		lRetorno := .T.
	EndIf
	
Return( lRetorno )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMSE1DetaºAutor  ³Reynaldo Miyashita  º Data ³  09.12.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de visualizacao da formação do valor do titulo a      º±±
±±º          ³ receber através do GEM.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMSE1Detail()

Local oDlgDet
Local oGrp1 

Local aArea       := GetArea()
Local nLinha      := 0
Local nVlrTitulo  := 0 
Local nVlrOriTit  := 0
Local nVlrAmort   := 0
Local nVlrJuros   := 0
Local nVlrCMAmort := 0
Local nVlrCMJur   := 0
Local dRef        := stod("")
Local cLimite     := ""
Local lAchou      := .F.

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return (.F.)
EndIf

dbSelectArea("LIX")
dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
If dbSeek(xFilial("LIX")+SE1->E1_NCONTR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
	nVlrAmort   := LIX->LIX_ORIAMO
	nVlrJuros   := LIX->LIX_ORIJUR
	nVlrOriTit  := nVlrAmort+nVlrJuros
		
	dRef := dDataBase
	dbSelectArea("LIW")
	dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	If dbSeek(xFilial("LIW")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
		cLimite := LIW->LIW_DTREF
		While left(dtos(dRef),6) >= cLimite .and. !lAchou
			If dbSeek(xFilial("LIW")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+left(dtos(dRef),6))
				nVlrCMAmort := LIW->LIW_VLRAMO+LIW->LIW_ACUAMO
				nVlrCMJur   := LIW->LIW_VLRJUR+LIW->LIW_ACUJUR
				lAchou      := .T.
			EndIf          
			dRef := GMPrevMonth(dRef,1)
		EndDo
	EndIf
	
	nVlrTitulo  := nVlrOriTit+nVlrCMAmort+nVlrCMJur

	DEFINE MSDIALOG oDlgDet TITLE STR0031 From 0,10 to 270,340 of oMainWnd PIXEL //"Detalhes do Titulo a receber"
	
	@ 005,005 GROUP oGrp1 TO 110, 160 LABEL '' OF oDlgDet PIXEL
	
	nLinha := 15
	@ nLinha+1 ,017 SAY STR0032 SIZE 63, 07 OF oDlgDet PIXEL  //"Amortizado"
	@ nLinha   ,075 MSGET nVlrAmort Picture PesqPict( "LIX","LIX_ORIAMO" ) SIZE 60,10 OF oDlgDet PIXEL READONLY
	
	nLinha += 13
	@ nLinha+1 ,017 SAY STR0033 SIZE 63, 07 OF oDlgDet PIXEL     //"Juros"
	@ nLinha   ,075 MSGET nVlrJuros Picture PesqPict( "LIX","LIX_ORIJUR" ) SIZE 60,10 OF oDlgDet PIXEL READONLY

	nLinha += 15
	@ nLinha+1 ,017 SAY STR0034 SIZE 63, 07 OF oDlgDet PIXEL  //"Valor Original do Título "
	@ nLinha   ,075 MSGET nVlrOriTit Picture PesqPict( "SE1","E1_VALOR" ) SIZE 60,10 OF oDlgDet PIXEL READONLY

	nLinha += 15
	@ nLinha+1 ,017 SAY STR0035 SIZE 63, 07 OF oDlgDet PIXEL   //"CM Amortização"
	@ nLinha   ,075 MSGET nVlrCMAmort Picture PesqPict( "LIX","LIX_CMAMO" ) SIZE 60,10 OF oDlgDet PIXEL READONLY
	
	nLinha += 13
	@ nLinha+1 ,017 SAY STR0036 SIZE 63, 07 OF oDlgDet PIXEL         //"CM Juros"
	@ nLinha   ,075 MSGET nVlrCMJur Picture PesqPict( "LIX","LIX_CMJUR" ) SIZE 60,10 OF oDlgDet PIXEL READONLY
	
	nLinha += 15
	@ nLinha+1 ,017 SAY STR0037 SIZE 63, 07 OF oDlgDet PIXEL   //"Valor do Título"
	@ nLinha   ,075 MSGET nVlrTitulo Picture PesqPict( "SE1","E1_VALOR" ) SIZE 60,10 OF oDlgDet PIXEL READONLY

	nLinha += 30
	@ nLinha ,70 BUTTON OemToAnsi(STR0038) SIZE 040,11 ACTION ( oDlgDet:End() ) OF oDlgDet PIXEL    //"Voltar"
	
	ACTIVATE MSDIALOG oDlgDet VALID (.T.) 
	
EndIf

RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMSE2DetaºAutor  ³Reynaldo Miyashita  º Data ³  09.12.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de visualizacao da formação do valor do titulo a      º±±
±±º          ³ pagar através do GEM.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFIN                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMSE2Detail()

Local oDlgDet
Local oGrp1 

Local aArea       := GetArea()
Local nLinha      := 0
Local nVlrOriTit  := 0
Local nVlrTitulo  := 0
Local nVlrAmort   := 0
Local nVlrJuros   := 0
Local nVlrCMAmort := 0
Local nVlrCMJur   := 0

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return (.F.)
EndIf

// detalhes do titulo a pagar
dbSelectArea("LJV")
dbSetOrder(1) // LJV_FILIAL+LJV_PREFIX+LJV_NUM+LJV_PARCEL+LJV_TIPO
If dbSeek(xFilial("LJV")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
	nVlrAmort   := LJV->LJV_AMORT
	nVlrJuros   := LJV->LJV_VALJUR
	nVlrOriTit  := nVlrAmort+nVlrJuros
	nVlrCMAmort := LJV->LJV_CMAMO
	nVlrCMJur   := LJV->LJV_CMJUR
	nVlrTitulo  := nVlrOriTit+nVlrCMAmort+nVlrCMJur

	DEFINE MSDIALOG oDlgDet TITLE STR0039 From 0,10 to 270,330 of oMainWnd PIXEL  //"Detalhes do Titulo a pagar"
	
	@ 005,005 GROUP oGrp1 TO 100, 150 LABEL '' OF oDlgDet PIXEL
	
	nLinha := 15
	@ nLinha+1 ,017 SAY STR0032 SIZE 53, 07 OF oDlgDet PIXEL    //"Amortizado"
	@ nLinha   ,059 MSGET nVlrAmort Picture PesqPict( "LJV","LJV_AMORT" ) SIZE 60,10 OF oDlgDet PIXEL READONLY
	
	nLinha += 13
	@ nLinha+1 ,017 SAY STR0033 SIZE 53, 07 OF oDlgDet PIXEL     //"Juros"
	@ nLinha   ,059 MSGET nVlrJuros Picture PesqPict( "LJV","LJV_VALJUR" ) SIZE 60,10 OF oDlgDet PIXEL READONLY

	nLinha += 15
	@ nLinha+1 ,017 SAY STR0034  SIZE 53, 07 OF oDlgDet PIXEL  //"Valor do Título Original"
	@ nLinha   ,059 MSGET nVlrOriTit Picture PesqPict( "SE2","E2_VALOR" ) SIZE 60,10 OF oDlgDet PIXEL READONLY

	nLinha += 15
	@ nLinha+1 ,017 SAY STR0035 SIZE 53, 07 OF oDlgDet PIXEL  //"CM Amortização"
	@ nLinha   ,059 MSGET nVlrCMAmort Picture PesqPict( "LJV","LJV_CMAMO" ) SIZE 60,10 OF oDlgDet PIXEL READONLY
	
	nLinha += 13
	@ nLinha+1 ,017 SAY STR0036 SIZE 53, 07 OF oDlgDet PIXEL  //"CM Juros" 
	@ nLinha   ,059 MSGET nVlrCMJur Picture PesqPict( "LJV","LJV_CMJUR" ) SIZE 60,10 OF oDlgDet PIXEL READONLY
	
	nLinha += 15
	@ nLinha+1 ,017 SAY STR0037 SIZE 53, 07 OF oDlgDet PIXEL   //"Valor do Título"
	@ nLinha   ,059 MSGET nVlrTitulo Picture PesqPict( "SE2","E2_VALOR" ) SIZE 60,10 OF oDlgDet PIXEL READONLY

	nLinha += 40
	@ nLinha ,60 BUTTON OemToAnsi(STR0038) SIZE 040,11 ACTION ( oDlgDet:End() ) OF oDlgDet PIXEL  //"Voltar"
	
	ACTIVATE MSDIALOG oDlgDet VALID (.T.) 
	
EndIf

RestArea(aArea)

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA080POS  ºAutor  ³ Reynaldo Miyashita º Data ³  09.12.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada, para carrega o valor da Multa, Juros e   º±±
±±º          ³ e CM Atraso, em caso de atraso.                            º±±
±±º          ³ A taxa da multa estah no cadastro de vendas                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRotina    ³ FINA080 - Baixas a Pagar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function FA080POS()

Local aArea       := {}
Local aRetorno    := {}
Local nVlrParcela := 0
Local nIndJurMora := 0
Local dVencto     := stod("")
Local nDiaCorr    := 0
Local nMesCorr    := 0
Local dUltBaixa   := stod("")

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( .T. )
EndIf

	aArea := GetArea()
	
	//
	// Inicia o calculo da CM atraso, Juros e Multa
	//

	// verifica se o titulo tem saldo a pagar e se esta vencido.
	If SE2->E2_SALDO > 0 .AND. dTos(SE2->E2_VENCREA) < dTos(dDataBase)
	
		nVlrParcela := SE2->E2_SALDO
		dVencto     := SE2->E2_VENCREA
		dUltBaixa   := iIf(SE2->E2_BAIXA > SE2->E2_VENCREA ,SE2->E2_BAIXA ,SE2->E2_VENCREA )
	
		/**************************************************************************************
		 Busca o contrato
		**************************************************************************************/
		dbSelectArea("LIT")
		dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
		If dbSeek(xFilial("LIT")+SE1->E1_NUM+SE1->E1_PREFIXO)
			nIndJurMora := LIT->LIT_JURMOR
			// calcula o juros mora diario pelo indice proporcional
			If LIT->(FieldPos("LIT_JURTIP")) >0 .AND. LIT->LIT_JURTIP == "3"
				nIndJurMora := LIT->LIT_JURMOR/30
			EndIf

			/**************************************************************************************
			 Busca a Condicao de venda que a parcela faz parte, para obter o indice
			**************************************************************************************/
			dbSelectArea("LJS")
			dbSetOrder(1) // LJS_FILIAL+LJS_NCONTR+LJS_REVISA+LJS_ITEM
			If LJS->(dbSeek(xFilial("LJS")+LIT->LIT_NCONTR+LIX->LIX_ITCND))
				// se o dia da baixa eh maior que o dia da correcao, monta a data de busca
				// baseada no mes e ano da database
				If !Empty(LJS->LJS_IND) .and. LJS->LJS_DIACOR > 0
					//
					// Busca o indice da CM para ser aplicado na PRO-RATA diaria de atraso
					//
					cTaxa := LJS->LJS_IND 
					nMesCorr := LJS->LJS_NMES
					nDiaCorr := LJS->LJS_DIACOR 
				EndIf
			
				//
				// Calcula a CM diaria em atraso, juros mora e multa
				//
				aRetorno := t_GEMAtraCalc( nVlrParcela ,dVencto ,cTaxa ,nMesCorr ,nDiaCorr ,nIndJurMora ,LIT->LIT_MULTA ,dDatabase,LIT->LIT_JURTIP ,dUltBaixa )
				
//				nVlrCMAtraso := aRetorno[1]
				nJuros := aRetorno[2]
				nMulta := aRetorno[3]
				
			EndIf // busca o item da condicao de venda do contrato
		EndIf // busca de contrato
    EndIf
	RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMSCKFie ºAutor  ³Reynaldo Miyashita  º Data ³  30.12.2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o valor do campo solicitado que foi criado pelo    º±±
±±º          ³ template                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA416                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMSCKField()
Local cCampo := PARAMIXB[1]
Local uValor := PARAMIXB[2]

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If HasTemplate("LOT")
	If cCampo == "C6_CODEMPR"
		uValor := SCK->CK_CODEMPR
	EndIf
EndIf

Return( uValor )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMmascCnfºAutor  ³Cristiano Denardi   º Data ³  28.01.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna array com caracteristicas da Mascara em LK2        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE GEM                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMmascCnf( cCodMas )
Local   aArea 		:= GetArea()
Local   aRet		:= {{},{}}
Local   cSeq		:= ""
Local   cCrMasc	:= "x"
Local   cMasc		:= ""

Default cCodMas	:= ""

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( aRet )
EndIf

cSeq    := StrZero(0,TamSX3("LK2_SEQUEN")[1])
cCodMas := PadR( cCodMas, TamSX3("LK2_CODIGO")[1] )

dbSelectArea("LK2")
dbSetOrder(1) // LK2	1	LK2_FILIAL+LK2_CODIGO+LK2_SEQUEN
MsSeek( xFilial("LK2") + cCodMas + cSeq )

If Found()
	
	/////////////////////////////////
	// A primeira posicao sera para a
	// mascara formada em uma string
	aAdd(aRet[1],cMasc)

	While LK2->LK2_FILIAL == xFilial("LK2") .And. LK2->LK2_CODIGO == cCodMas
			
	   	/////////////////////////////
	   	// Pula registro de Cabecalho
	   	If LK2->LK2_SEQUEN == StrZero(0,TamSX3("LK2_SEQUEN")[1]) 
	   		LK2->( dbSkip() )
	   		Loop
	   	Endif
	   	
	   	cMasc += Replicate( cCrmasc, LK2->LK2_QUANT )
	   	cMasc += LK2->LK2_SEPARA
	   	aRet[1][1] := cMasc
	   	
	   	Aadd( aRet[2], { Val(LK2->LK2_SEQUEN), LK2->LK2_QUANT, LK2->LK2_SEPARA }  ) 
	   	
		LK2->( dbSkip() )
	EndDo
	
	If Right(aRet[1][1],1) <> cCrMasc
		aRet[1][1] := SubStr( cMasc, 1, Len(cMasc)-1 )
	Endif
	
Endif

RestArea(aArea)
Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMNivelUnºAutor  ³Cristiano Denardi   º Data ³  06.02.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna nivel para a unidade, conforme codigo da Est. Pai  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE GEM                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMNivelUn( cCodEmp, cCodPai )
Local aArea 		:= GetArea()
Local cNv			:= ""
Default cCodEmp	:= ""
Default cCodPai	:= ""

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( cNv )
EndIf

If !Empty(cCodEmp) .And. !Empty(cCodPai)
	dbSelectArea("LK5")
	dbSetOrder(1) // LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
	// LK5	1	LK5_FILIAL+LK5_CODEMP+LK5_STRUCT
	If MsSeek( xFilial("LK5") + cCodEmp + cCodPai )
		cNv := Soma1( LK5->LK5_NIVEL )
	Endif
Endif

RestArea( aArea )
Return( cNv )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMValTitRºAutor  ³Cristiano Denardi   º Data ³  06.02.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Valores do titulo a receber                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE GEM                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMValTitR( lPos, cPrefix, cNum, cParcela, cTipo )
Local aArea     := {}
Local aRetTit   := {}
Local aCMRet    := {}
Local lContinua := .F.

Default lPos		:= .F. // Define se ja' esta posicionado ou precisa efetuar o MsSeek()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( aRetTit )
EndIf

// .: Estrutura de aRetTit :.
// --------------------------
// 01 - VALOR do Titulo
// 02 - SALDO do Titulo
// 03 - Correcao Monetaria
// 04 - Percentual da Amort. do Valor
// 05 - Valor da Amort. do Valor
// 06 - Percentual da Amort. do Saldo
// 07 - Valor da Amort. do Saldo
// 08 - Percentual do Juros do Valor
// 09 - Valor do Juros do Valor
// 10 - Percentual do Juros do Saldo
// 11 - Valor do Juros do Saldo
// ----

lContinua := lPos

/////////////////////
// Precisa posicionar
If !lPos 
	aArea	:= GetArea()

	dbSelectArea("SE1")
	dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If MsSeek( xFilial("SE1") + cPrefix, cNum, cParcela, cTipo )
		// Detalhes do titulos a receber
		dbSelectArea("LIX")
		dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
		If MsSeek( xFilial("LIX") + SE1->E1_NCONTR + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO )
			lContinua := .T.
		EndIf
	Endif
Endif

If lContinua

	//////////////////
	// VALOR do Titulo
	Aadd( aRetTit, LIX->LIX_ORIAMO + LIX->LIX_ORIJUR )
	
	//////////////////
	// SALDO do Titulo
	Aadd( aRetTit, SE1->E1_SALDO )
	
	/////////////////////
	// Correcao Monetaria
	//
	// ultima correcao monetaria aplicada ao titulo
	//
	aCMRet := ExecTemplate("CMDtPrc",.F.,.F.,{LIX->LIX_PREFIX ,LIX->LIX_NUM ,LIX->LIX_PARCEL ,dDatabase ,SE1->E1_VENCREA})
	Aadd( aRetTit, aCMRet[2] + aCMRet[3] )
	
	////////////////////////////////////
	// Percentual e valor da amortizacao
	// em relacao ao TITULO e ao SALDO
	Aadd( aRetTit, LIX->LIX_ORIAMO/SE1->E1_VALOR ) 					                 // Percentual da Amort. do Valor
	Aadd( aRetTit, (LIX->LIX_ORIAMO/SE1->E1_VALOR)*(SE1->E1_VALOR+aCMRet[2]+aCMRet[3]) ) // Valor da Amort. do Valor
	
	Aadd( aRetTit, LIX->LIX_ORIAMO/SE1->E1_SALDO ) 					// Percentual da Amort. do Saldo
	Aadd( aRetTit, (LIX->LIX_ORIAMO/SE1->E1_SALDO)*SE1->E1_SALDO )	// Valor da Amort. do Saldo
	
	/////////////////////////////////////
	// Percentual e valor do juros mensal
	// em relacao ao titulo e ao saldo
	Aadd( aRetTit, LIX->LIX_ORIJUR / SE1->E1_VALOR ) 						// Percentual do Juros do Valor
	Aadd( aRetTit, (LIX->LIX_ORIJUR/SE1->E1_VALOR)*SE1->E1_VALOR+aCMRet[2]+aCMRet[3])	// Percentual do Juros do Valor
	
	Aadd( aRetTit, LIX->LIX_ORIJUR / SE1->E1_SALDO ) 						// Percentual do Juros do Saldo
	Aadd( aRetTit, (LIX->LIX_ORIJUR/SE1->E1_SALDO)*SE1->E1_SALDO )	// Percentual do Juros do Saldo
	
Endif

If( !lPos, RestArea( aArea ), Nil )
Return( aRetTit )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMRetEstUºAutor  ³Cristiano Denardi   º Data ³  08.03.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna todas as estruturas do nivel onde se criara a      º±±
±±º          ³ unidade, pela rotina de Wizard                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TEMPLATE GEM                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMRetEstU( cCodEmp, cCodEst )

Local aArea 	:= GetArea()
Local aEst  	:= {}
Local cStrPai	:= ""

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( aEst )
EndIf

dbSelectArea("LK5")
dbSetOrder(1) // LK5_FILIAL + LK5_CODEMP + LK5_STRUCT
If MsSeek( xFilial("LK5") + cCodEmp + cCodEst )

	cStrPai := LK5->LK5_STRPAI

	dbSetOrder(3) // LK5_FILIAL + LK5_CODEMP + LK5_STRPAI
	If MsSeek( xFilial("LK5") + cCodEmp + cStrPai )
	
		Do While	xFilial("LK5")	== LK5->LK5_FILIAL .And.;
					cCodEmp	      == LK5->LK5_CODEMP .And.;
					cStrPai			== LK5->LK5_STRPAI

      		Aadd( aEst, { LK5->LK5_STRUCT, LK5->LK5_DESCRI } )

			dbSkip()
		EndDo
	
	Endif
Endif

RestArea( aArea )
Return( aEst )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMCpySA1 ºAutor  ³Reynaldo Miyashita  º Data ³  20.03.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe a tela de cadastro de cliente com dados de outro     º±±
±±º          ³ registro em que estava posicionado.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMFXFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMCpySA1()
Local aArea     := GetArea()
Local aButtons  := {}
Local aPosEnch  := {}
Local bCampo 	:= {|n| FieldName(n) }
Local cAlias    := "SA1"
Local cCadastro := "Clientes"
Local nTop      := 0
Local nLeft     := 0
Local nBottom   := 0
Local nRight    := 0
Local nPosMemo  := 0
Local nCount    := 0
Local nOpcA     := 0
Local nReg      := 0

PRIVATE aTELA[0][0],aGETS[0]
PRIVATE aMemos    := {{"A1_CODMARC","A1_VM_MARC"},{"A1_OBS","A1_VM_OBS"}}

	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( .T. )
	EndIf

	dbSelectArea(cAlias)
	RegToMemory(cAlias, .F.)

	M->A1_COD     := Space(TamSX3("A1_COD")[1])
	M->A1_LOJA    := Space(TamSX3("A1_LOJA")[1])
	M->A1_NOME    := Space(TamSX3("A1_NOME")[1])
	M->A1_NREDUZ  := Space(TamSX3("A1_NREDUZ")[1])
	M->A1_CGC     := Space(TamSX3("A1_CGC")[1])
	M->A1_INSCR   := Space(TamSX3("A1_INSCR")[1])
	M->A1_PFISICA := Space(TamSX3("A1_PFISICA")[1])
	M->A1_INSCRM  := Space(TamSX3("A1_INSCRM")[1])
	M->A1_DTNASC  := Space(TamSX3("A1_DTNASC")[1])
	M->A1_INSCRUR := Space(TamSX3("A1_INSCRUR")[1])
	M->A1_GMEMIRG := Space(TamSX3("A1_GMEMIRG")[1])
	M->A1_GMESTRG := Space(TamSX3("A1_GMESTRG")[1])
	M->A1_GMDTEMI := Space(TamSX3("A1_GMDTEMI")[1])
	M->A1_GMNACIO := Space(TamSX3("A1_GMNACIO")[1])
	M->A1_GMSEXO  := Space(TamSX3("A1_GMSEXO")[1])
	M->A1_GMCIVIL := Space(TamSX3("A1_GMCIVIL")[1])
	M->A1_GMESCOL := Space(TamSX3("A1_GMESCOL")[1])
	M->A1_GMPROFI := Space(TamSX3("A1_GMPROFI")[1])
	M->A1_GMDTADM := Space(TamSX3("A1_GMDTADM")[1])
	M->A1_GMSALAR := 0
	M->A1_GMSTSAL := Space(TamSX3("A1_GMSTSAL")[1])
	M->A1_GMSTSAL := Space(TamSX3("A1_GMSTSAL")[1])
	
	If SetMDIChild()
		oMainWnd:ReadClientCoors()
		nTop := 40
		nLeft := 30 
		nBottom := oMainWnd:nBottom-80
		nRight := oMainWnd:nRight-70		
	Else
		nTop := 135
		nLeft := 0
		nBottom := TranslateBottom(.T.,28)
		nRight := 632
	EndIf
	
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM nTop,nLeft TO nBottom,nRight PIXEL OF oMainWnd
	oDlg:lMaximized := .T.

	aPosEnch := {,,(oDlg:nClientHeight - 4)/2,}
	
	EnChoice( cAlias ,nReg ,3 ,,,,,aPosEnch )

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| iIf( Obrigatorio(aGets,aTela) ,(nOpcA:=1,oDlg:End()),Nil)} ;
													   ,{||oDlg:End()},,aButtons)
	If nOpcA == 1
		Begin Transaction
			RecLock("SA1",.T.)
			FOR nCount := 1 TO FCount()
				FieldPut(nCount ,M->&( EVAL(bCampo,nCount) ) )
			NEXT nCount
			SA1->A1_FILIAL := xFilial("SA1")
			MsUnlock()                 
			For nCount := 1 To Len( aMemos )
				If !Empty( nPosMemo := SA1->( FieldPos( aMemos[ nCount, 1 ] ) ) )
					MSMM( SA1->( FieldGet( nPosMemo ) ),,,,2)
				EndIf
		    Next nCount
	    End Transaction
	EndIf
	
RestArea(aArea)

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CMContr   ºAutor  ³Reynaldo Miyashita  º Data ³  12.05.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula a correcao monetaria do contrato, atraves da data  º±±
±±º          ³ do contrato até a data de faturamento do pedido.           º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMFXFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CMContr( nRecSF2 ,nRecLIT )

	oProcess := MsNewProcess():New({|lEnd| AuxCMContr( nRecSF2 ,nRecLIT )}, STR0040)   //"Processando a Correcao Monetaria do Contrato"
	oProcess:Activate()
	
Return( .T. )
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AuxCMContrºAutor  ³Reynaldo Miyashita  º Data ³  12.05.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa o Calculo a correcao monetaria do contrato,       º±±
±±º          ³ atraves da data do contrato até a data de faturamento      º±± 
±±º          ³ do pedido.                                                 º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMFXFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AuxCMContr( nRecSF2 ,nRecLIT )
Local aArea        := GetArea()
Local aMsgError    := {}
Local aRetCoef     := {} 
Local cUltFech     := GetMV("MV_GMULTFE")
Local cTaxa        := ""
Local dRefCM       := stod("")
Local dIndCM       := stod("") // data do indice para CM
Local nDecIndCM    := 0
Local nAcumCMAmort := 0
Local nAcumCMJuros := 0
Local nCMAmort     := 0
Local nCMJuros     := 0
Local nVlrTitulo   := 0
Local nCMTitulo    := 0
Local nNewCMAmort  := 0
Local nNewCMJuros  := 0
Local nNewVlrTit   := 0
Local nQtdParcelas := 0
Local nTotQtdParc  := 0
Local nCount       := 0
Local lContinua    := .T.
Local lNovoLIW     := .F. 
Local aRecord      := {}
Local aRecSE1      := {}
Local aRecLIX      := {}
Local aRecLIW      := {}
Local nX           := 0
Local cFilLIW      := xFilial("LIW") 
Local dCMSeek      := STOD("")
Local aCustomCM	 := {}

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( .T. )
EndIf

//
// Pedido de Venda - cabecalho
//
dbSelectArea("SF2")
dbGoto( nRecSF2 )

//
// Contrato de venda - cabecalho
//
dbSelectArea("LIT")
dbSetOrder(1) // LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
dbGoto( nRecLIT )

If Empty(cUltFech)
	cUltFech := left(dtos(dDatabase),6)
EndIf

//
// Se o mes/ano do contrato for menor ou igual ao mes/ano do pedido de venda
// deve recalcular o valor do contrato e parcelas ateh o ultimo fechamento
//
If left(dtos(LIT->LIT_EMISSA),6) < cUltFech

	// Avanca para o proximo mes para ter o indice para correcao
	dRefCM := GMNextMonth( LIT->LIT_EMISSA ,1 )
	
	//
	// Se o mes/ano para CM for inferior ou igual ao ultimo mes/ano correcao,
	// deve calcular a CM dos titulos
	//
	While left(dtos(dRefCM),6)<=cUltFech .And. lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz a montagem do aColsLJO                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("LJO")
		dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
		If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR)
			While !Eof() .And. LJO->LJO_FILIAL+LJO->LJO_NCONTR==xFilial("LJO")+LIT->LIT_NCONTR .And. lContinua

				// zera o contador de titulos processados
				cTaxa   := ""
				// Quantidade total de titulos
				nQtdParcelas := LJO->LJO_NUMPAR
				dIndCM       := stod("")
				nDecIndCM    := 0

				// Se foi entregue as chaves e a CM for superior a data de entrega
				If ! Empty(LIQ->LIQ_HABITE) .AND. left(dtos(dRefCM),6) >= left(dtos(LIQ->LIQ_HABITE),6)
					cTaxa    := LJO->LJO_INDPOS
					nMes     := LJO->LJO_NMES2
					nDiaCorr := LJO->LJO_DIACOR
				Else
					cTaxa    := LJO->LJO_IND
					nMes     := LJO->LJO_NMES1
					nDiaCorr := LJO->LJO_DIACOR
				EndIf
				
				// se houver indice de correcao monetaria
				If ! Empty(cTaxa)
					// se foi informado o dia para a correcao monetaria
					If nDiaCorr > 0
						//
						// monta a data do indice de referencia para correcao monetaria do mes informado
						//
						aRetCoef  := T_GEMCoefCM( cTaxa ,nMes ,stod(left(dtos(dRefCM),6)+STRZERO(nDiaCorr ,TAMSX3("LIS_DIACOR")[1])) )
		                                             
						nDecIndCM := aRetCoef[1]/aRetCoef[2]
						dIndCM    := aRetCoef[4]
		
						If !(lContinua := Empty(aRetCoef[3]))
							aAdd(aMsgError ,aRetCoef[3] )
						EndIf
							
					Else 
						// "Dia da correção monetaria nao foi informado para o item '"  # "' da condicao de venda."
						aAdd(aMsgError ,OEMTOANSI(STR0041) + LJO->LJO_ITEM + OEMTOANSI(STR0042))
						lContinua := .F.
					EndIf
				EndIf
				
				// naum encontrou dados para o calculo da correcao monetaria
				If lContinua
					//
					// Tipo de parcela
					//
					dbSelectArea("LFD")
					dbSetOrder(1) // LFD_FILIAL+LFD_COD
					If dbSeek(xFilial("LFD")+LJO->LJO_TIPPAR)
						
						// Atualiza a regua de parcelas
						oProcess:SetRegua2(nQtdParcelas)
						
						// Detalhes do titulo a receber
						// calcula as prestacoes do contrato
						dbSelectArea("LIX")
						dbSetOrder(4) // LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND
						dbSeek(xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND)+LJO->LJO_ITEM)
						While LIX->(!eof()) .AND. ;
					 	      xFilial("LIX")+LIT->(LIT_NCONTR+LIT_COND)+LJO->LJO_ITEM == LIX->(LIX_FILIAL+LIX->LIX_NCONTR+LIX_CODCND+LIX_ITCND)
					 	      
							oProcess:IncRegua2("Título : " + LIX->LIX_PREFIXO +" "+LIX->LIX_NUM+"-"+LIX->LIX_PARCEL )
					 		
							//
							// titulos a receber
							//
							dbSelectArea("SE1")
							dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
							If dbSeek(xFilial("SE1")+LIX->LIX_PREFIXO+PadR(LIX->LIX_NUM, Len(LIX->LIX_NUM))+LIX->LIX_PARCEL+LIX->LIX_TIPO)
								// Se existe saldo e o mes/ano de emissao do titulo for menor que o mes/ano de CM, calcula a CM 
								If SE1->E1_SALDO > 0 .AND. left(dtos(SE1->E1_EMISSAO),6) < left(dtos(dRefCM),6)
								
									nTotQtdParc++
									
									//
									// Foi definido uma taxa entao o titulo tem CM
									//
									If ! Empty(cTaxa) .AND. nDiaCorr > 0
										// contador de prestacao recalculadas
										nAcumCMAmort := 0
										nAcumCMJuros := 0
										nCMAmort     := 0
										nCMJuros     := 0
										lNovoLIW     := .T.
                                                
										dCMSeek := GMPrevMonth( dRefCM ,1 )
									
										// Ultima correcao monetaria aplicada ( mes anterior)
										dbSelectArea("LIW")
										LIW->(dbSetOrder(1)) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
										If dbSeek(cFilLIW+SE1->E1_PREFIXO+PadR(SE1->E1_NUM, Len(SE1->E1_NUM))+SE1->E1_PARCELA+SE1->E1_TIPO+left(dtos(dCMSeek),6) )
											nAcumCMAmort := LIW->LIW_ACUAMO
											nAcumCMJuros := LIW->LIW_ACUJUR
											nCMAmort     := LIW->LIW_VLRAMO
											nCMJuros     := LIW->LIW_VLRJUR
											lNovoLIW     := .F.
										EndIf
										
										// Valor do título atual
										nVlrTitulo := SE1->E1_SALDO+nAcumCMAmort+nAcumCMJuros+nCMAmort+nCMJuros
										nAmorBase  := round( nVlrTitulo*(LIX->LIX_ORIAMO / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) ,2 )
										nJuroBase  := round( nVlrTitulo*(LIX->LIX_ORIJUR / (LIX->LIX_ORIAMO+LIX->LIX_ORIJUR)) ,2 )
										
										// Correcao monetaria do titulo, Amortizacao, Juros
										nNewVlrTit  := round( (nVlrTitulo*nDecIndCM) ,2)
										If nNewVlrTit < 0 
											nNewVlrTit := nNewVlrTit * -1
										EndIf
				
										// valor do amortizado corrigido com o indice
										nNewCMAmort := round( nAmorBase * nDecIndCM ,2)
				
										If ExistBlock("GmCalcCM")

											// nVlrTitulo - Valor do titulo atual(base amortizado + base juros)
											// nAmorBase - Valor da amortizacao do titulo atual

											aCustomCM := ExecBlock("GMCalcCM",.F.,.F.,{nVlrTitulo,nAmorBase,nDecIndCM})
											// ---> Com o valor do titulo e a base de amortizado, conseguira encontrar a base de juros
											// ---> O indice e passado para que poss    
										
											// aCustomCM[1] - Valor do titulo corrigido com novo indice
											// aCustomCM[2] - Valor do amortizado do titulo corrigido
										
											nNewVlrTit  := aCustomCM[1]
											nNewCMAmort := aCustomCM[2]
										
										EndIf                               

										nCMTitulo   := nNewVlrTit-nVlrTitulo // Valor da CM do Titulo 
										nNewCMAmort := nNewCMAmort-nAmorBase // Valor da CM do amortizado
										nNewCMJuros := nCMTitulo-nNewCMAmort // Valor da CM do juros
										
										//
										// Detalhe de Titulos a Receber (Correcao monetaria)
										// atualiza a data de processamento e o valor da correcao monetaria do titulo a receber
										//
										RecLock("LIW",.T.)
										
											LIW->LIW_FILIAL  := xFilial("LIW")
											LIW->LIW_PREFIXO := SE1->E1_PREFIXO
											LIW->LIW_NUM     := PadR(SE1->E1_NUM, Len(SE1->E1_NUM)) 
											LIW->LIW_PARCELA := SE1->E1_PARCELA 
											LIW->LIW_TIPO    := SE1->E1_TIPO
											LIW->LIW_DTPRC  := dDatabase  // data do calculo da correcao monetaria
											LIW->LIW_DTRef  := left(dtos(dRefCM),6)  // ano/Mes de referencia
											LIW->LIW_DTIND  := dIndCM     // data de referencia do indice de correcao
											LIW->LIW_TPCORR := "1"        // Correcao monetaria
											LIW->LIW_TAXA   := cTaxa      // Codigo da taxa de correcao monetaria utilizado
											LIW->LIW_INDICE := aRetCoef[1]
											LIW->LIW_BASAMO := nVlrTitulo*(nAmorBase  / (nAmorBase+nJuroBase))
											LIW->LIW_BASJUR := nVlrTitulo*(nJuroBase / (nAmorBase+nJuroBase))
											LIW->LIW_VLRAMO := nNewCMAmort
											LIW->LIW_VLRJUR := nNewCMJuros
											LIW->LIW_ACUAMO := nCMAmort+nAcumCMAmort
											LIW->LIW_ACUJUR := nCMJuros+nAcumCMJuros
										LIW->(MSUnlock())
									EndIf
								    
									// se o mes/ano do titulo for menor ou igual ao fechamento e for provisorio
									// deve converter para um titulo tipo NF
									// sera deletado e inserido novamente depois do loop da tabela LIX pois quando
									// se insere o registro, a tabela nao retorna para ordenacao correta
									If left(dtos(SE1->E1_VENCTO),6) <= left(dtos(dRefCM),6)

										If SE1->E1_TIPO == MVPROVIS
											// titulos a receber
											aRecord := {}
											dbSelectArea("SE1")
											aAdd( aRecord ,SE1->(Recno()) )
											For nCount := 1 to FCount()
												aAdd( aRecord ,FieldGet( nCount ) )
											Next nCount
											aAdd( aRecSE1,aRecord )

											// detalhes do titulos a receber
											aRecord := {}
											dbSelectArea("LIX")
											aAdd( aRecord ,LIX->(Recno()) )
											For nCount := 1 to FCount()
												aAdd( aRecord ,FieldGet( nCount ) )
											Next nCount
											aAdd( aRecLIX,aRecord )
										EndIf
										
										If LIW->LIW_TIPO == MVPROVIS  .AND. (SE1->E1_PARCELA == LIW->LIW_PARCEL)
											// Correcao monetaria do titulo a pagar
											aRecord := {}
											dbSelectArea("LIW")
											aAdd( aRecord ,LIW->(Recno()) )
											For nCount := 1 to FCount()
												aAdd( aRecord ,FieldGet( nCount ) )
											Next nCount
											aAdd( aRecLIW,aRecord )
										EndIf
										
									EndIf
								EndIf
							
							EndIf
							
							dbSelectArea("LIX")
							dbSetOrder(4) // LIX_FILIAL+LIX_NCONTR+LIX_CODCND+LIX_ITCND
					 		LIX->( dbSkip() )
					 		
					 	EndDo
					 	
					 	// titulos a receber
					 	For nCount := 1 to Len(aRecSE1)
						 	SE1->(DbGoto(aRecSE1[nCount,1]))
						 	RecLock("SE1",.F.,.T.)
					 		SE1->(DbDelete())
					 		SE1->(MsUnlock())
					 		
							RecLock("SE1",.T.)
							For nX := 2 to Len(aRecSE1[nCount])
								SE1->(FieldPut( nX-1 ,aRecSE1[nCount,nX] ))
							Next nX
							SE1->E1_TIPO := MVNOTAFIS
							SE1->(MsUnlock())
						Next nCount

						// detalhes do titulos a receber
					 	For nCount := 1 to Len(aRecLIX)
						 	LIX->(DbGoto(aRecLIX[nCount,1]))
						 	RecLock("LIX",.F.,.T.)
					 		LIX->(DbDelete())
					 		LIX->(MsUnlock())
					 		
							RecLock("LIX",.T.)
							For nX := 2 to Len(aRecLIX[nCount])
								LIX->(FieldPut( nX-1 ,aRecLIX[nCount,nX] ))
							Next nX
							LIX->LIX_TIPO := MVNOTAFIS
							LIX->(MsUnlock())
						Next nCount

						// Correcao monetaria do titulo a pagar
					 	For nCount := 1 to Len(aRecLIW)
						 	LIW->(DbGoto(aRecLIW[nCount,1]))
						 	RecLock("LIW",.F.,.T.)
					 		LIW->(DbDelete())
					 		LIW->(MsUnlock())
					 		
							RecLock("LIW",.T.)
							For nX := 2 to Len(aRecLIW[nCount])
								LIW->(FieldPut( nX-1 ,aRecLIW[nCount,nX] ))
							Next nX
							LIW->LIW_TIPO := MVNOTAFIS
							LIW->(MsUnlock())
						Next nCount
						
						aRecSE1 := {}
						aRecLIX := {}
						aRecLIW := {}

					Else
						// Tipo de Parcela  # na Condicao de venda  # Nao foi encontrado
						aAdd(aMsgError ,STR0043 + LJO->LJO_TIPPAR + STR0044 + LIS->LIS_CODCND + "/" + LJO->LJO_ITEM + STR0045)
					EndIf
				EndIf
				
				dbSelectArea("LJO")
				dbSkip()
			EndDo
		EndIf
		
		// Avanca 1 mes
		If lContinua
			dRefCM := GMNextMonth( dRefCM ,1 )
		EndIf

	EndDo
EndIf 

If LIT->(FieldPos("LIT_FECHAM"))>0 .And. LIT->(FieldPos("LIT_DTCM"))>0
	RecLock("LIT",.F.)
	LIT->LIT_DTCM   := left(dtos( GMPrevMonth( dRefCM ,1 ) ),6)
	LIT->LIT_FECHAM := LIT->LIT_DTCM
	LIT->(MsUnlock())
EndIf
    
RestArea(aArea)
    
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMJUROS  ºAutor  ³Reynaldo Miyashita  º Data ³  19.05.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtem atraves do registro posicionado na tabela SE1 o valorº±±
±±º          ³ de correcao monetaria, calculo da pro rata atraso diario,  º±± 
±±º          ³ multa e juros.                                             º±±
±±º			 ³                                                            º±±
±±º			 ³Atencao as variaveis nCM1 e nJuros sao declaradas como Pri- º±±
±±º			 ³vate na funcao Fina070                                      º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMFXFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMJUROS()
Local aAreaLIT    := {}
Local aAreaLJO    := {}
Local aAreaLIX    := {}
Local aAreaLIW    := {}

Local cAlias      := iIf( len(PARAMIXB)>0, PARAMIXB[1],"")
Local dRef        := iIf( len(PARAMIXB)>1, PARAMIXB[2],dDataBase)
Local dUltBaixa   := iIf( len(PARAMIXB)>2, PARAMIXB[3],NIL )
Local nSaldo      := iIf( len(PARAMIXB)>3, PARAMIXB[4],NIL )

Local nIndJurMor  := 0
Local nIndMulta   := 0
Local nVlrParcela := 0
Local nVlrCM      := 0
Local nVlrProRata := 0
Local nJurosMora  := 0
Local nVlrMulta   := 0
Local nMes        := 0     
Local nProRata	   := 0     
Local aRetorno    := {}
Local aVlrCM      := {}
Local dVencto     := stod("")
Local dCM         := stod("")
Local dHabite     := stod("")
Local cTaxa       := ""


If HasTemplate("LOT")

	aAreaLIT    := LIT->(GetArea())
	aAreaLJO    := LJO->(GetArea())
	aAreaLIX    := LIX->(GetArea())
	aAreaLIW    := LIW->(GetArea())

	cAlias := iIf( ValType(cAlias) <> "C" ,"SE1"     ,cAlias)
	dRef   := iIf( ValType(dRef)   <> "D" ,dDataBase ,dRef)
	
	dCM    := iIf( dRef >(cAlias)->E1_VENCREA ,dRef ,GMPrevMonth(dRef,1) )
	nSaldo := iIf( !(nSaldo==NIL) ,nSaldo ,(cAlias)->E1_SALDO)	
	dUltBaixa := iIf( dUltBaixa==NIL ,iIf( Empty((cAlias)->E1_BAIXA) ,(cAlias)->E1_VENCTO ,(cAlias)->E1_BAIXA) ,dUltBaixa)	

	/**************************************************************************************
	Detalhe do titulo a receber, se existir eh um titulo gerado pelo GEM
	**************************************************************************************/
	dbSelectArea("LIX")
	dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	If dbSeek(xFilial("LIX")+(cAlias)->E1_PREFIXO+(cAlias)->E1_NUM+(cAlias)->E1_PARCELA+(cAlias)->E1_TIPO)
		/**************************************************************************************
		 Busca o contrato
		**************************************************************************************/
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+LIX->LIX_NCONTR)
			dVencto   := (cAlias)->E1_VENCTO
			
	
			/**************************************************************************************
			 Busca a Condicao de venda que a parcela faz parte, para obter o indice
			**************************************************************************************/
			dbSelectArea("LJO")
			dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
			If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND)
				// itens do contrato
				dbSelectArea("LIU")
				dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
				If MSSeek(xFilial("LIU")+LIT->LIT_NCONTR)
					// unidades do empreendimento
					dbSelectArea("LIQ")
					dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
					If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
						If Empty( LIQ->LIQ_HABITE)
							If LIQ->LIQ_PREVHB > dRef
								cTaxa := LJO->LJO_IND 
								nMes  := LJO->LJO_NMES1
							Else
								cTaxa := LJO->LJO_INDPOS 
								nMes  := LJO->LJO_NMES2
							EndIf
							dHabite := LIQ->LIQ_PREVHB 
						Else
							If LIQ->LIQ_HABITE > dRef
								cTaxa := LJO->LJO_IND 
								nMes  := LJO->LJO_NMES1
							Else
								cTaxa := LJO->LJO_INDPOS 
								nMes  := LJO->LJO_NMES2
							EndIf
							dHabite := LIQ->LIQ_HABITE
						EndIf
					EndIf
				EndIf
				If ((cAlias)->E1_SALDO == (cAlias)->E1_VALOR .AND. EMPTY((cAlias)->E1_BAIXA))
					nVlrParcela := LIX->LIX_ORIAMO
					If !LIX->LIX_JURFCT 
						nVlrParcela += LIX->LIX_ORIJUR
					EndIf
		
					//
					// ultima correcao monetaria aplicada ao titulo
					//
					aVlrCM := ExecTemplate("CMDtPrc",.F.,.F.,{LIX->LIX_PREFIX ,LIX->LIX_NUM ,LIX->LIX_PARCEL ,dRef ,(cAlias)->E1_VENCTO})
					
					cTaxa  := iIf( Empty(aVlrCM[1]) ,cTaxa ,aVlrCM[1])
					nVlrCM := aVlrCM[2]
					If !LIX->LIX_JURFCT 
						nVlrCM += aVlrCM[3]
					EndIf

				Else
					nVlrParcela := nSaldo //(cAlias)->E1_SALDO
					nVlrCM := GEMCMSLd( LIX->(Recno()) ,nVlrParcela ,dUltBaixa ,dRef ,LIT->LIT_EMISSA ,,dHabite )
				EndIf
			EndIf
			
			nIndJurMor := 0
			nIndMulta  := 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calculo de Juros Diarios ( Taxa de Permanencia )³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If dRef > dVencto	// Parcela em Aberto Atrasada
				nIndJurMor := LIT->LIT_JURMOR
				nIndMulta  := LIT->LIT_MULTA
			EndIf
			
			//
			// Calcula a CM diaria em atraso, juros mora e multa
			//
			aRetorno := t_GEMAtraCalc( nVlrParcela+nVlrCM ,dVencto ,cTaxa ,nMes ,LJO->LJO_DIACOR ,nIndJurMor ,nIndMulta ,dRef ,LIT->LIT_JURTIP ,dUltBaixa )
			                           
			nVlrProRata  := aRetorno[1]
			nJurosMora   := aRetorno[2]
			nVlrMulta    := aRetorno[3]
			
		EndIf // busca o item da condicao de venda do contrato

	EndIf

	//
	// repassa os valores calculados para as variaveis private do modulo financeiro
	//	
	nMulta := nVlrMulta
	nJuros := nJurosMora

	If nVlrCM >0
		nJuros += nVlrCM
		nCM1   := nVlrCM
	EndIf

	// parametro MV_GMPRORA eh utilizado quando se deseja calcular a prorata no atraso do pagamento da parcela
	If SuperGetMv("MV_GMPRORA",,"1") == "1"
		If nVlrProRata >0
			nJuros   += nVlrProRata
			nProRata := nVlrProRata
		EndIf
	EndIf
       
	nMulta 	:= Round(nMulta,2)
	nJuros 	:= Round(nJuros,2)
	nProRata := Round(nProRata,2)
	
	LIW->(RestArea(aAreaLIW))
	LIX->(RestArea(aAreaLIX))
	LJO->(RestArea(aAreaLJO))
	LIT->(RestArea(aAreaLIT))
EndIf

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMDESCTO ºAutor  ³Reynaldo Miyashita  º Data ³  19.05.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtem atraves do registro posicionado na tabela SE1 o valorº±±
±±º          ³ de correcao monetaria, calculo da pro rata atraso diario,  º±± 
±±º          ³ multa e juros.                                             º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMFXFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMDESCTO()
Local aAreaLIT    := {}
Local aAreaLJO    := {}
Local aAreaLIX    := {}
Local aAreaLIW    := {}

Local cAlias      := iIf( len(PARAMIXB)>0, PARAMIXB[1], "")
Local dRef        := iIf( len(PARAMIXB)>1, PARAMIXB[2],dDataBase)
Local nDescto     := iIf( len(PARAMIXB)>2, PARAMIXB[3],0)
Local dUltBaixa   := iIf( len(PARAMIXB)>3, PARAMIXB[4],dDataBase)
Local nSaldo      := iIf( len(PARAMIXB)>4, PARAMIXB[5],0)

Local nVlrParcela := 0
Local nVlrCM      := 0
Local nVlrProRata := 0
Local dVencto     := stod("")
Local dCM         := stod("") 
Local dHabite     := stod("")
Local cTaxa       := ""
Local nMes        := 0


If HasTemplate("LOT")

	aAreaLIT    := LIT->(GetArea())
	aAreaLJO    := LJO->(GetArea())
	aAreaLIX    := LIX->(GetArea())
	aAreaLIW    := LIW->(GetArea())

	cAlias    := iIf( ValType(cAlias) <> "C" ,"SE1" ,cAlias)
	dRef      := iIf( ValType(dRef) <> "D" ,dDataBase ,dRef)
	nSaldo    := iIf( !(nSaldo==NIL) ,nSaldo ,(cAlias)->E1_SALDO)	
	dUltBaixa := iIf( dUltBaixa==NIL ,iIf( Empty((cAlias)->E1_BAIXA) ,(cAlias)->E1_VENCREA ,(cAlias)->E1_BAIXA) ,dUltBaixa)	
	
	dCM    := iIf( dRef >(cAlias)->E1_VENCREA ,dRef ,GMPrevMonth(dRef,1) )
	
	nCM1		:= iIf( Type("nCM1")     != "N" ,0 ,nCM1)
	nProRata	:= iIf( Type("nProRata") != "N" ,0 ,nProRata)
	
	/**************************************************************************************
	 Detalhe do titulo a receber, se existir eh um titulo gerado pelo GEM
	**************************************************************************************/
	dbSelectArea("LIX")
	dbSetOrder(1) // LIX_FILIAL+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	If dbSeek(xFilial("LIX")+(cAlias)->E1_PREFIXO+(cAlias)->E1_NUM+(cAlias)->E1_PARCELA+(cAlias)->E1_TIPO)
		/**************************************************************************************
		 Busca o contrato
		**************************************************************************************/
		dbSelectArea("LIT")
		dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
		If dbSeek(xFilial("LIT")+LIX->LIX_NCONTR)
		
			dVencto   := (cAlias)->E1_VENCREA
		
	
			If ((cAlias)->E1_SALDO == (cAlias)->E1_VALOR .AND. EMPTY((cAlias)->E1_BAIXA))
				/**************************************************************************************
				 Busca a Condicao de venda que a parcela faz parte, para obter o indice
				**************************************************************************************/
				dbSelectArea("LJO")
				dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
				If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND)
					// itens do contrato
					dbSelectArea("LIU")
					dbSetOrder(3) // LIU_FILIAL+LIU_NCONTR+LIU_COD+LIU_ITEM
					If MSSeek(xFilial("LIU")+LIT->LIT_NCONTR)
						// unidades do empreendimento
						dbSelectArea("LIQ")
						dbSetOrder(1) // LIQ_FILIAL+LIQ_COD
						If dbSeek(xFilial("LIQ")+LIU->LIU_CODEMP)
							If Empty( LIQ->LIQ_HABITE)
								If LIQ->LIQ_PREVHB > dRef
									cTaxa := LJO->LJO_IND 
									nMes  := LJO->LJO_NMES1
								Else
									cTaxa := LJO->LJO_INDPOS
									nMes  := LJO->LJO_NMES2
								EndIf
								dHabite := LIQ->LIQ_PREVHB
							Else
								If LIQ->LIQ_HABITE > dRef
									cTaxa := LJO->LJO_IND 
									nMes  := LJO->LJO_NMES1
								Else
									cTaxa := LJO->LJO_INDPOS
									nMes  := LJO->LJO_NMES2
								EndIf
								dHabite := LIQ->LIQ_HABITE
							EndIf
						EndIf
					EndIf

					nVlrParcela := LIX->LIX_ORIAMO
					If !LIX->LIX_JURFCT 
						nVlrParcela += LIX->LIX_ORIJUR
					EndIf

					//
					// ultima correcao monetaria aplicada ao titulo
					//
					aVlrCM := ExecTemplate("CMDtPrc",.F.,.F.,{LIX->LIX_PREFIX ,LIX->LIX_NUM ,LIX->LIX_PARCEL ,dRef ,(cAlias)->E1_VENCREA })
										
					cTaxa  := iIf( Empty(aVlrCM[1]) ,cTaxa ,aVlrCM[1])
					nMes   := iIf( Empty(aVlrCM[1]) ,nMes ,aVlrCM[4])
					nVlrCM := aVlrCM[2]
					If !LIX->LIX_JURFCT 
						nVlrCM += aVlrCM[3]
					EndIf
					//nVlrCM -= (cAlias)->E1_CM1
				Else
					nVlrParcela := nSaldo //(cAlias)->E1_SALDO
		   		nVlrCM := GEMCMSLd( LIX->(Recno()) ,nVlrParcela ,dUltBaixa ,dRef ,LIT->LIT_EMISSA ,,dHabite )
			  	EndIf
			EndIf
			
			// se o dia da baixa eh maior que o dia da correcao, monta a data de busca
			// baseada no mes e ano da database
			If !Empty(cTaxa) .and. LJO->LJO_DIACOR > 0
				//
				// Calcula a CM Pro-rata diaria em atraso
				//
				nVlrProRata := CalcProRat( dRef, dVencto, nVlrParcela+nVlrCM, cTaxa, nMes, LJO->LJO_DIACOR )
			EndIf
			
		EndIf 

	EndIf

	//
	// repassa os valores calculados para as variaveis private do modulo financeiro
	//	
	If nVlrCM < 0
		nCM1    := nVlrCM
		nDescto -= nVlrCM
	EndIf
	
	If nVlrProRata < 0
		nProRata := nVlrProRata
		nDescto  -= nVlrProRata
	EndIf
	
	LIW->(RestArea(aAreaLIW))
	LIX->(RestArea(aAreaLIX))
	LJO->(RestArea(aAreaLJO))
	LIT->(RestArea(aAreaLIT))
EndIf

Return( nDescto )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMSE5Grv ºAutor  ³Reynaldo Miyashita  º Data ³  19.05.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava nos campos especificos do registro posicionado       º±±
±±º          ³ da tabela SE5. Devendo o registro da tabela SE1 estar      º±±
±±º          ³ posicionado tambem.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMFXFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMSE5Grv()

	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( NIL )
	EndIf
		
	//
	// Verifica se eh um titulo gerado pelo template GEM, atraves da tabela LIX
	//
	If T_GEMSE1LIX()
		If SE5->(FieldPos("E5_PRORATA")) >0
			Replace SE5->E5_PRORATA With nProRata
		EndIf
		If SE5->(FieldPos("E5_CM1")) >0
			Replace SE5->E5_CM1 With nCM1
		EndIf
	EndIf
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMSE1Grv ºAutor  ³Reynaldo Miyashita  º Data ³  19.05.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava nos campos especificos do registro posicionado       º±±
±±º          ³ da tabela SE1.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMFXFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßß ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMSE1Grv()
	
	//
	// Verifica se eh um titulo gerado pelo template GEM, atraves da tabela LIX
	//
	If T_GEMSE1LIX()
		If SE1->(FieldPos("E1_PRORATA")) >0
			SE1->E1_PRORATA := nProRata
		EndIf
		If SE1->(FieldPos("E1_CM1")) >0
			SE1->E1_CM1 := nCM1
		EndIf
	EndIf
Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMSE1LIX ºAutor  ³Reynaldo Miyashita  º Data ³  28.05.2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava nos campos especificos do registro posicionado       º±±
±±º          ³ da tabela SE1.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMFXFUN                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMSE1LIX()
Local lEncontrou  := .F.
Local aArea := GetArea()

If HasTemplate("LOT")

	dbSelectArea("LIX")
	dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	If dbSeek(xFilial("LIX")+SE1->E1_NCONTR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)
		lEncontrou := .T.
	EndIf

	RestArea(aArea)

EndIf

Return( lEncontrou )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | GEMCMTit  ³ Autor ³ Reynaldo Miyashita     ³ Data ³ 01.06.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima correcao monetaria aplicado no titulo conforme³±±
±±³          ³ database. Informando a taxa, Cm do Principal e CM do juros     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GEMCMTit( nRecLIX ,dRef )
Local aArea    := GetArea()
Local nCMAmort := 0
Local nCMJur   := 0 
Local nCount   := 0
Local nMes     := 0
Local cTaxa    := ""
Local cLimite  := ""
Local lAchou   := .F.
Local aValores := {}

DEFAULT dRef := dDataBase

	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( NIL )
	EndIf
		
	dbSelectArea("LIX")
	dbGoto(nRecLIX)
	
	dbSelectArea("LIW")
	dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
	dbSeek(xFilial("LIW")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL))
	While LIW->(!Eof()) .and. ;
	       LIW->(LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL)==xFilial("LIW")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL)
	      
		aAdd( aValores ,{LIW->LIW_DTREF ,LIW->LIW_DTIND ,LIW->LIW_TAXA ,LIW->LIW_VLRAMO+LIW->LIW_ACUAMO ,LIW->LIW_VLRJUR+LIW->LIW_ACUJUR})
		dbSkip()
		
	EndDo
	
	// ordena mes/ano crescente
	aSort(aValores ,,,{|x,y| x[1] < y[1] })
	
	nCount := 1
	While nCount <= Len(aValores) ;
	      .and. aValores[nCount,1] <= left(dtos(dRef),6)
		cTaxa    := aValores[nCount,3]
		nMes     := GMDateDiff( sTod(aValores[nCount,1]+"01") ,aValores[nCount,2] ,"m" )
		nCMAmort := aValores[nCount,4]
		nCMJur   := aValores[nCount,5]
		nCount += 1
	EndDo
	
RestArea(aArea)

Return( {cTaxa ,nCMAmort ,nCMJur ,nMes } )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | GMDTEMP   ³ Autor ³ Reynaldo Miyashita     ³ Data ³ 01.06.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a data informada com o mes/ano do fechamento da correcao³±±
±±³          ³ monetaria.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico(X3_VALID do campo LK3_PREVHB)                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GMDTEMP( dRef )
Local lRet := .T.
Local cUltFech := GetMV("MV_GMULTFE")

	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( NIL )
	EndIf
	    
	If !Empty( dRef )
		If left(dtos(dRef),6) < cUltFech
		//"Mes/Ano da data informada deve ser superior ao Mês/Ano do fechamento da CM. "
			MsgAlert(STR0046)
			lRet := .F.
		EndIf
	EndIf
	
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GMPRCPARC   ºAutor  ³Reynaldo Miyashitaº Data ³  04/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Reordena das datas previstas das parcelas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GMPRCPARC( aConjunto )                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aConjunto[n] - Grupos de parcelas pelo item de condicao    ³±±
±±³			 ³             [1] - Item da condicao de venda                ³±±
±±³			 ³             [2] - Codigo do tipo de parcela                ³±±
±±³			 ³             [3] - Descricao do tipo de parcela             ³±±
±±³			 ³             [4] - Parcela Exclusiva "1"=Sim                ³±±
±±³			 ³             [5] - Intervalo entre as parcelas              ³±±
±±³			 ³             [6][n] - Parcelas geradas                      ³±±
±±³			 ³                   [1] - Numero da parcela                  ³±±
±±³			 ³                   [2] - Data de vencimento                 ³±±
±±³			 ³                   [3] - Valor da Parcela                   ³±±
±±³			 ³                   [4] - Juros Mensal da Parcela            ³±±
±±³			 ³                   [5] - Saldo Amortizado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMDlgSol                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GMPRCPARC( aConjunto )
Local nCnt1   := 0
Local nCnt2   := 0
Local nCnt3   := 0
Local nCnt4   := 0
Local nCnt5   := 0
Local nPos    := 0
Local aVencto := {}

	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( NIL )
	EndIf
	
	// reordena pelo se é exclusiva e item
	aSort( aConjunto ,,,{|x,y| x[04]+"."+x[01] < y[04]+"."+y[01] } )

	// item da condicao
	For nCnt1 := 1 To Len(aConjunto)-1
		// titulos do item
		For nCnt2 := 1 To Len(aConjunto[nCnt1 ,06])
		
			For nCnt3 := nCnt1+1 To Len(aConjunto)
				For nCnt4 := 1 To Len(aConjunto[nCnt3 ,06])
				
					If aConjunto[nCnt1 ,04]=="1"
						
						If left(dtos(aConjunto[nCnt1 ,06,nCnt2,02]),6) == left(dtos(aConjunto[nCnt3 ,06,nCnt4,02]),6)
							For nCnt5 := nCnt4 to Len(aConjunto[nCnt3 ,06])
								aConjunto[nCnt3 ,06,nCnt5,02] := GMNextMonth( aConjunto[nCnt3 ,06,nCnt5,02] ,aConjunto[nCnt3 ,05] )
								While (aScan( aVencto, {|x|left(dtos(x),6) == left(dtos(aConjunto[nCnt3 ,06,nCnt5,02]),6) } )) >0
									aConjunto[nCnt3 ,06,nCnt5,02] := GMNextMonth( aConjunto[nCnt3 ,06,nCnt5,02] ,aConjunto[nCnt3 ,05] )
								EndDo
							Next nCnt5
							
						EndIf
						If aScan( aVencto ,{|x|dtos(x) == dtos(aConjunto[nCnt1 ,06,nCnt2,02]) }) <= 0
							aAdd( aVencto ,aConjunto[nCnt1 ,06,nCnt2,02] )
						EndIf
						
					EndIf
					
				Next nCnt4
		  	Next nCnt3
		  	
		Next nCnt2
	Next nCnt1
	
	// reordena pelo item 
	aSort( aConjunto ,,,{|x,y| x[1] < y[1] } )

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMRGB      ºAutor  ³Reynaldo Miyashitaº Data ³  04/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Calculo do RGB                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GEMRGB( nRed ,nGreen ,nBlue )                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMDlgSol                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMRGB( nRed ,nGreen ,nBlue )
// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( NIL )
EndIf
Return( nRed + ( nGreen * 256 ) + ( nBlue * 65536 ) )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F040CPO  ³ Autor ³ Reynaldo Miyashita    ³ Data ³25.10.2006   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function F040CPO()
Local aCPosOri := ParamIXB
Local aCPos    := {}
Local nPos     := 0

	If (nPos := aScan(aCPosOri ,"E1_NATUREZ") ) > 0
		aAdd(aCpos,"E1_NATUREZ")
	EndIf
	Aadd(aCpos,"E1_VENCTO")
	Aadd(aCpos,"E1_VENCREA")
	Aadd(aCpos,"E1_HIST")

Return( aCPOS )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | GEMCMSLd  ³ Autor ³ Reynaldo Miyashita     ³ Data ³ 01.06.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima correcao monetaria aplicado no titulo conforme³±±
±±³          ³ database. Informando a taxa, Cm do Principal e CM do juros     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GEMCMSLd( nRecLIX ,nSaldo ,dUltBaixa ,dRef ,dContrato ,lProRata ,dHabite )
Local aArea      := GetArea()
Local nDias      := 0
Local nInd       := 0
Local nIndBase   := 0
Local nInd2      := 0
Local nProRata   := 0
Local nCM        := 0
Local nIndCorr   := 0
Local nCMMesCorr := 0
Local dIndice    := stod("")

Local dProxCM    := stod("")
Local dBase      := stod("")
Local dCMBase    := stod("")
Local aValores   := {}
Local dCMAtual   := stod("") 
Local nPosDias   := 0
Local aTaxas     := {}
Local cAlias     := If(Select("__SE1")==0,"SE1","__SE1") //esta funcao eh utilizada no relatorio finr130(titulos a receber) que cria um filtro na tabela SE1 e aqui nao pode ser utilizado este filtro

DEFAULT nSaldo    := 0
DEFAULT dUltBaixa := stod("")
DEFAULT dRef      := dDataBase
DEFAULT lProRata  := .F.

	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( nCM )
	EndIf
	
	//
	// Detalhes do titulos a receber
	//
	dbSelectArea("LIX")
	dbGoto(nRecLIX)
	
	If !(dUltBaixa == dRef)
		//
		// titulos a receber
		//
		dbSelectArea(cAlias)
		dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If dbSeek(xFilial("SE1")+LIX->(LIX_PREFIX+LIX_NUM+LIX_PARCEL))
	
			If !((cAlias)->E1_SALDO == (cAlias)->E1_VALOR .AND. EMPTY((cAlias)->E1_BAIXA))
				//
				// Contrato
				//
				dbSelectArea("LIT")
				dbSetOrder(2) // LIT_FILIAL+LIT_NCONTR
				If dbSeek(xFilial("LIT")+LIX->LIX_NCONTR)
				    
					dContrato := LIT->LIT_EMISSA
					aIndice   := {}
					
					//
					// Condicao do contrato
					//
					dbSelectArea("LJO")
					dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
					If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND)
	
						aAdd( aTaxas ,{LJO->LJO_IND    ,LJO->LJO_NMES1} )
						aAdd( aTaxas ,{LJO->LJO_INDPOS ,LJO->LJO_NMES2} )
	
						nDiaCorr := LJO->LJO_DIACOR
					
					EndIf
					
				EndIf
	
				//
				// obtem o indice base da data do contrato
				//
				dIndice := dContrato
				If aTaxas[01][02] > 0
					dIndice := GMNextMonth(dContrato ,aTaxas[01][02])
				ElseIf aTaxas[01][02] < 0
					dIndice := GMPrevMonth(dContrato ,aTaxas[01][02]*-1)
				EndIf
				dIndice := stod(left(dtos(dIndice),6)+strzero(nDiaCorr,2))
				
				//
				// TABELA DE INDICES DE CORRECAO 
				//
				dbSelectArea("AAE")
				dbSetOrder(1) // AAE_FILIAL+AAE_CODIND+DTOS(AAE_DATA)
				// indice do periodo a ser corrigido
				If dbSeek(xFilial("AAE")+aTaxas[01][01]+dtos(dIndice))
					aAdd( aValores ,{left(dtos(dContrato),6) ,AAE->AAE_CODIND ,AAE->AAE_INDICE * Iif(AAE->AAE_SINAL == "2", -1, 1) })
		  		EndIf
		        
				//
				// obtem o indice base da data do habite, isto é, o mes anterior a data do habite-se
				//
				dIndice := dHabite
				If aTaxas[02][02] > 0
					dIndice := GMNextMonth(dIndice ,aTaxas[02][02])
				ElseIf aTaxas[02][02] < 0
					dIndice := GMPrevMonth(dIndice ,aTaxas[02][02]*-1)
				EndIf
				dIndice := GMPrevMonth(dIndice ,1)
				dIndice := stod(left(dtos(dIndice),6)+strzero(nDiaCorr,2))
				
				//
				// TABELA DE INDICES DE CORRECAO 
				//
				dbSelectArea("AAE")
				dbSetOrder(1)
				// indice do periodo a ser corrigido
				If dbSeek(xFilial("AAE")+aTaxas[02][01]+dtos(dIndice))
					aAdd( aValores ,{left(dtos(dHabite),6) ,AAE->AAE_CODIND,AAE->AAE_INDICE * Iif(AAE->AAE_SINAL == "2", -1, 1) } )
		  		EndIf

				// carrega as taxas e indices aplicados nas correcoes do titulo
				dbSelectArea("LIW")
				dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
				dbSeek(xFilial("LIW")+LIX->LIX_PREFIX+LIX->LIX_NUM+LIX->LIX_PARCEL)
				While LIW->(!Eof()) .and. ;
				       LIW->LIW_FILIAL+LIW->LIW_PREFIX+LIW->LIW_NUM+LIW->LIW_PARCEL==xFilial("LIW")+LIX->LIX_PREFIX+LIX->LIX_NUM+LIX->LIX_PARCEL
				      
					aAdd( aValores ,{LIW->LIW_TAXA ,LIW->LIW_DTREF ,LIW->LIW_INDICE} )
					dbSkip()
					
				EndDo
		
				// ordena mes/ano crescente
				aSort(aValores ,,,{|x,y| x[1]+x[2] < y[1]+y[2] })

				dCMBase := dUltBaixa
				
				//
				// INICIO = Calcula a correcao monetaria da data da baixa ateh a proxima correcao.
				//
				// Exemplo:
				//
				//     O titulo foi parcialmente pago em 10/05/2006, mas venceu em 01/05/2006.
				//     O saldo do titulo precisa ser corrigido ateh 01/06/2006.
				//
				//////////////////////////////////////////////////////////////
				
                // se a database for maior que o dia do vencimento
				If (dRef > (cAlias)->E1_VENCTO) .AND. (dRef > stod(left(DtoS(dRef),06)+Strzero(Day((cAlias)->E1_VENCTO))))
				
					// Calcula o proximo mes que coindicida com o dia de vencimento
					dProxCM := stod(left(DtoS(GMNextMonth(dUltBaixa)),06)+Strzero(Day((cAlias)->E1_VENCTO),02))
					
					// se a data da proxima correcao for maior q a data do habite
					If Left(dtos(dHabite),6) > Left(dtos(dProxCM),6)
						cTaxa := aTaxas[01][01]
					Else
						cTaxa := aTaxas[02][01]
					EndIf

					// Indice base do mes anterior da ultima baixa
					If (nPos := aScan( aValores ,{|x| x[1]+x[2] == cTaxa+Left(dTos(dUltBaixa),6) })) >0
						// indice base para calculo
						nIndBase := aValores[nPos,3]  
						
				        // Indice do Proximo Mes para Correcao monetaria
						If (nPos := aScan( aValores ,{|x| x[1]+x[2] == cTaxa+Left(dTos(dProxCM),6) })) >0
                           
							dCMBase := dProxCM
							nIndProx := aValores[nPos,3]  
							nPosDias := dProxCM - (dUltBaixa+1)
		                    
		                    nIndCorr := nIndProx / nIndBase
		                                             
							// Calcula o valor de pro-rata da data da baixa ateh a data do proximo mes
							// Formula:
							// ((Valor mes passado * indice mes atual) - valor mes passado) * (dias corridos / dias corridos mes)		
					  		nCMMesCorr := Round(nSaldo * nIndCorr,2) - nSaldo
					  		nCM := nCMMesCorr * (nPosDias / 30)
				  		EndIf
                    EndIf
				EndIf
		        
				//
				// FIM = Calcula a correcao monetaria da data da baixa ateh a proxima correcao.
				//
				//////////////////////////////////////////////////////////////
				
				
				//
				// INICIO = Calcula a correcao monetaria mensais 
				//
				////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				// se a data do habite for maior que a data de base
				If Left(dtos(dHabite),6) > Left(dtos(dCMBase),6)
				
					// se a data do habite for maior que a data de referencia, usa a taxa pre-habite
					If Left(dtos(dHabite),6) > Left(dtos(dRef),6)
						nCM += CalcCM( aTaxas[01][01] ,dCMBase ,dRef ,nSaldo+nCM ,aValores )

					// deve calcular com taxa pre-habite ateh a data do habite e 
					// a partir da data do habite ateh a data de referencia com a taxa pos-habite
					Else
						// calcula com taxa pre-habite da data de base ateh o mes anterior do habite
						nCM += CalcCM( aTaxas[01][01] ,dCMBase ,GMPrevMonth( dHabite ,1 ) ,nSaldo+nCM ,aValores )
						
						// calcula com taxa pos-habite do mes anterior do habite ateh a data de referencia
						nCM += CalcCM( aTaxas[02][01] ,GMPrevMonth( dHabite ,1 ) ,dRef ,nSaldo+nCM ,aValores )
						
					EndIf
				Else
					// se a data do habite for menor ou igual que a data de referencia, usa a taxa pre-habite
					If Left(dtos(dHabite),6) <= Left(dtos(dRef),6)
						nCM += CalcCM( aTaxas[01][01] ,dCMBase ,dRef ,nSaldo+nCM ,aValores )
					EndIf
				EndIf
				
				
				//
				// FIM = Calcula a correcao monetaria mensais 
				//
				//////////////////////////////////////////////////////////////

				//
				// INICIO = Calcula a pro-rata
				//
				//////////////////////////////////////////////////////////////
				If lProRata
				
					If Left(dtos(dHabite),6) > Left(dtos(dRef),6)
						cTaxa := aTaxas[01][01]
						nMes  := aTaxas[01][02]
					Else
						cTaxa := aTaxas[02][01]
						nMes  := aTaxas[02][02]
					EndIf
					nProRata := CalcProRat( dRef, (cAlias)->E1_VENCTO, (nSaldo+nCM), cTaxa, nMes, nDiaCorr )
                    nCM += nProRata
				EndIf
			
				//
				// FIM = Calcula a pro-rata
				//
				//////////////////////////////////////////////////////////////
			EndIf
		EndIf
	EndIf

RestArea(aArea)

Return( nCM )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | CalcCM    ³ Autor ³                        ³ Data ³            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcCM( cTaxa ,dBase ,dAtual ,nSaldo ,aValores )
Local nCount    := 0
Local nPos      := 0
Local nIndBase  := 0
Local nIndAtual := 0
Local nCM       := 0

	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( nCM )
	EndIf

	// Indice base 
	If (nPos := aScan( aValores ,{|x| x[1]+x[2] == cTaxa+Left(dTos(dBase),6) })) >0
		nIndBase := aValores[nPos,3]
		
		nCount := nPos
		nInd2  := 0
		While nCount <= Len(aValores) ;
		      .and. aValores[nCount,1] == cTaxa ;
		      .and. aValores[nCount,2] <= left(dtos(dAtual),6)
			nIndAtual  := aValores[nCount,3]
			nCount += 1
		EndDo
		If !(nIndAtual == 0)
			nCM := nCM +((nSaldo+nCM)*((nIndAtual/nIndBase)-1))
		EndIf
	EndIf	

Return( nCM )

//
// Retorna um array com os dados detalhados do titulo a receber 
//
//	aTitulo[01] - Situacao do titulo: recebido/Atrasado/A Receber 
//	aTitulo[02] - Parcela (aaa/bbb/-cc)
//	aTitulo[03] - Descricao do tipo de parcela
//	aTitulo[04] - data de vencimento
//	aTitulo[05] - Data da baixa
//	aTitulo[06] - Valor Recebido
//	aTitulo[07] - Valor do Titulo
//	aTitulo[08] - Valor Principal Original
//	aTitulo[09] - Correcao monetaria do Valor Principal 
//	aTitulo[10] - Valor Juros Fcto Original
//	aTitulo[11] - Correcao monetaria do Valor Juros Fcto 
//	aTitulo[12] - Pro rata
//	aTitulo[13] - Juros Mora
//	aTitulo[14] - Multa
//	aTitulo[15] - Desconto
//	aTitulo[16] - Valor Atualizado
//	aTitulo[17] - Taxa
//
Template Function GMCalcTit( cContrato ,cPrefixo, cNumero ,cParcela ,cTipo ,dContrato ,dHabite ,nPorcJurMor ,nPorcMulta ,cTipoJuros ,lAtualizar ,dRefer )
Local aArea         := GetArea()
Local aAreaSE1      := SE1->(GetArea())
Local aAreaSE5      := SE5->(GetArea())
Local aAreaLIX      := LIX->(GetArea())
Local aAreaLJO      := LJO->(GetArea())
Local lContinua
Local nStatus
Local nVlrReceb
Local nVlrLiq       := 0
Local nVlrDistr     := 0
Local nVlrBaixa     := 0
Local nVlrParcela   := 0 
Local nVlrProRata   := 0
Local nVlrJurosMora := 0
Local nVlrMulta     := 0
Local nVlrDescon    := 0
Local nDiaCorr      := 0
Local aVlrCM        := {}
Local nVlrAtual     := 0
Local nVlrCessao    := 0

Local aBaixas       := {}
Local aTipoDoc      := {}
Local nCntSE5       := 0
Local lEstornada    := .F.
Local lBaixaAbat    := .F.
Local nRecAtu       := 0
Local cSequencia    := ""
Local cTipoEst      := ""

Local nCMPrinc      := 0
Local nCMJuros      := 0
Local nMes          := 0
Local lAtraso       := .T.
Local aRet          := {}
Local dUltBaixa     := stod("")
Local dVencto       := stod("")                                
Local lUltCM        := GetNewPar("MV_GEMULTC",.F.) 

Local aTitulo       := {}

DEFAULT dContrato   := stod("")
DEFAULT dRefer      := dDatabase
DEFAULT nPorcJurMor := 0
DEFAULT nPorcMulta  := 0
DEFAULT cTipoJuros  := ""
DEFAULT lAtualizar  := .F.

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
If !HasTemplate("LOT")
	Return( aTitulo )
EndIf

// detalhes do titulo a receber
dbSelectArea("LIX")
dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
If dbSeek(xFilial("LIX")+cContrato+cPrefixo+cNumero+cParcela+cTipo)

	// titulo a receber
	dbSelectArea("SE1")
	dbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
 		dbSeek(SE1->(xFilial("SE1"))+LIX->LIX_PREFIX+PadR(LIX->LIX_NUM, Len(LIX->LIX_NUM))+LIX->LIX_PARCEL+LIX->LIX_TIPO, .T. )

		lContinua := .T.
		nStatus   := 0
		nVlrBaixa := 0
		nVlrReceb := 0
		nVlrLiq   := 0 
		nVlrDistr := 0
		nVlrCessao:= 0
		
		//
		// se numliq for preenchido e emissao for maior que a database, naum considera
		//
		If !Empty(SE1->E1_NUMLIQ) .AND. SE1->E1_EMISSAO > dRefer
			lContinua := .F.
		EndIf

		If lContinua 
			aBaixas := {}
			aTipoDoc := {"BA" ,"VL"}
	  		For nCntSE5 := 1 to Len(aTipoDoc)
				//
				// Busca no SE5, as baixas do titulo a receber tanto baixa com/sem mov. bancario
				//
			    dbSelectArea("SE5")
			    dbSetOrder(2) // E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
			    dbSeek(xFilial("SE5")+aTipoDoc[nCntSE5]+SE1->E1_PREFIXO+PadR(SE1->E1_NUM, Len(SE1->E1_NUM))+SE1->E1_PARCELA+SE1->E1_TIPO)
			    While SE5->(!Eof()) ;
			         .AND.    SE5->E5_FILIAL+SE5->E5_TIPODOC  +SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ;
			               == SE1->E1_FILIAL+aTipoDoc[nCntSE5]+SE1->E1_PREFIXO+PadR(SE1->E1_NUM, Len(SE1->E1_NUM))   +SE1->E1_PARCELA+SE1->E1_TIPO
			    	If SE5->E5_CLIFOR+SE5->E5_LOJA == SE1->E1_CLIENTE+SE1->E1_LOJA
						lEstornada := .F.
						lBaixaAbat := .F.
						nRecAtu := SE5->(recno())
						cSequencia	:= SE5->E5_SEQ
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica se existe uma baixa cancelada para esta baixa efetuada       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						SE5->(MsSeek(xFilial("SE5")+"ES"+SE1->E1_PREFIXO+PadR(SE1->E1_NUM, Len(SE1->E1_NUM))+SE1->E1_PARCELA+SE1->E1_TIPO))
						cTipoEst := "ES"
				
						While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .and. ;
						            SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO ;
						         == cTipoEst       +SE1->E1_PREFIXO+PadR(SE1->E1_NUM, Len(SE1->E1_NUM))+SE1->E1_PARCELA+SE1->E1_TIPO
				
							If SE5->E5_CLIFOR != SE1->E1_CLIENTE .OR. SE5->E5_LOJA != SE1->E1_LOJA
								SE5->(dbSkip())
								Loop
							EndIF
				
							IF SE5->E5_SEQ != cSequencia
								SE5->(dbSkip())
								Loop
							EndIF
				
							If SE5->E5_MOTBX == "FAT"
								dbSkip()
								Loop
							Endif
				
							//ÚBaixa NormalÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Sera estornado se for exatamente a mesma sequencia, carteira          ³
							//³contraria e nao for um adiantamento ou credito. (Titulo Normal)       ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SE5->E5_SEQ == cSequencia .And. SE5->E5_RECPAG == "P" .and. !SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG
								lEstornada := .T.
								Exit
							EndIf
				
							//ÚÄBaixa de AdiantamentoÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Sera estornado se for exatamente a mesma sequencia, carteira          ³
							//³contraria e for um adiantamento ou credito. (Titulo de Credito        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SE5->E5_SEQ == cSequencia .And. SE5->E5_RECPAG == "R" .and. SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG
								lEstornada := .T.
								Exit
							EndIf
							SE5->( dbSkip() )
						EndDo
						SE5->(dbSetOrder(2)) // // E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
						SE5->(dbGoTo(nRecAtu))
						If lEstornada
							lEstornada := .F.
							lBaixaAbat := .F.
							SE5->(dbSkip())
							Loop
						EndIf
						If (SE5->E5_TIPODOC == "VL") .OR. (SE5->E5_TIPODOC == "BA") 
				    		Do Case
						    	Case SE5->E5_TIPODOC == "VL"
						    		nVlrBaixa += SE5->E5_VALOR
						    		aAdd( aBaixas ,{ SE5->E5_DATA ;
						    		                ,SE5->E5_VALOR ;
						    		                ,SE5->E5_VLDESCO-iIf(SE5->E5_CM1<0,SE5->E5_CM1*-1,0) -iIf(SE5->E5_PRORATA<0,SE5->E5_PRORATA*-1,0) ;
						    		                ,SE5->E5_VLMULTA ;
						    		                ,SE5->E5_VLJUROS-iIf(SE5->E5_CM1>0,SE5->E5_CM1,0) -iIf(SE5->E5_PRORATA>0,SE5->E5_PRORATA,0) ;
						    		                ,SE5->E5_CM1 ;
						    		                ,SE5->E5_PRORATA ;
						    		                })
	
						    	Case SE5->E5_TIPODOC == "BA"
						    		Do Case
						    			Case SE5->E5_MOTBX == "LIQ" // POR LIQUIDACAO
						    				nVlrLiq += SE5->E5_VALOR 
						    			Case SE5->E5_MOTBX == "DIS" // POR DISTRATO
						    				nVlrDistr += SE5->E5_VALOR
						    			Case SE5->E5_MOTBX == "CSS" // POR CESSAO DE DIREITO
						    				nVlrCessao += SE5->E5_VALOR
						    			OtherWise
						    				nVlrBaixa += SE5->E5_VALOR
						    		EndCase 
						    EndCase
						EndIf
				    EndIf
				    
			    	dbSelectArea("SE5")
			    	dbSkip()
			    EndDo
			Next nCntSE5
	         			
			If SE1->E1_SALDO == 0 .AND. nVlrDistr >0
				lContinua := .F.
			EndIf
		EndIf
		
		If lContinua 
			
			// se o vencimento for menor que a data referencia
			If dTos(SE1->E1_VENCREA) < dTos(dRefer)
			
				// se a data da baixa for menor que a data referencia
				If !Empty(SE1->E1_BAIXA) .AND. (dtos(SE1->E1_BAIXA) <= dTos(dRefer))
					If (nVlrBaixa>0)
						If SE1->E1_SALDO == 0 
							// Parcelas Recebidas
							nStatus := 1
						Else
							// Parcelas atrasada
							nStatus := 3
						EndIf
					Else
						// Titulo baixado sem movimentacao bancaria
						If SE1->E1_SALDO == 0 
							// com valor de liquidacao 
							If (nVlrLiq>0)
								// Parcelas Renegociadas
								nStatus := 2
								lContinua := .F.
							EndIf

							// com valor de cessao
							If (nVlrCessao>0)
								// Parcelas Renegociadas
								nStatus := 5
								lContinua := .T.
							EndIf
						EndIf
					EndIf
                        
				Else
					// parcela atrasada
					nStatus := 3
				EndIf
								
			Else
				// se a data da baixa for menor que a data referencia
				If !Empty(SE1->E1_BAIXA) .AND. (dtos(SE1->E1_BAIXA) <= dTos(dRefer))
                    If (nVlrBaixa>0)
			        	If SE1->E1_SALDO == 0 
							// Parcelas Recebidas
							nStatus := 1
						Else
							// Parcelas a receber
							nStatus := 4
						EndIf
					Else
						// Titulo baixado sem movimentacao bancaria
						If SE1->E1_SALDO == 0 
							// com valor de liquidacao 
							If (nVlrLiq>0)
								// Parcelas Renegociadas
								nStatus := 2
								lContinua := .F.
							EndIf

							// com valor de cessao
							If (nVlrCessao>0)
								// Parcelas de cessao
								nStatus := 5
								lContinua := .T.
							EndIf
						EndIf
					EndIf
									
				Else
					// parcela a receber
					nStatus := 4
				EndIf
			EndIf
		EndIf
	                                    
		If lContinua
			aTitulo     := Array(17)
			aTitulo[01] := 0
			aFill( aTitulo ,"" ,2 ,4)
			aFill( aTitulo ,0 ,6 )
			aTitulo[17] := ""
					
			aTitulo[ 1] := nStatus
			aTitulo[ 3] := STR0047 // Parcela
			aTitulo[17] := "" // Indice de CM
		    
			nVlrParcela   := 0 
			nVlrProRata   := 0
			nVlrJurosMora := 0
			nVlrMulta     := 0
			nVlrDescon    := SE1->E1_DECRESC

			aTitulo[ 8] := LIX->LIX_ORIAMO // Valor Principal do titulo Original
                            
//				If  dDataBase >= dHabite
				aTitulo[10] := LIX->LIX_ORIJUR // juros fcto
//				else
//					aTitulo[10] := 0
//				EndIf                      
			
			// Condicao de venda
			dbSelectArea("LJO")
			dbSetOrder(1) // LJO_FILIAL+LJO_NCONTR+LJO_ITEM
			If dbSeek(xFilial("LJO")+LIT->LIT_NCONTR+LIX->LIX_ITCND )
				// Tipo de Parcela
				aTitulo[ 3] := LJO->LJO_TPDESC
				
				aTitulo[ 2] := LIX->LIX_ITNUM + "/" + STRZERO(LJO->LJO_NUMPAR,TamSX3("LJO_NUMPAR")[1]) + "-" + LJO->LJO_ITEM // No. da parcela
                                                               
				nDiaCorr := LJO->LJO_DIACOR

				// Atualiza parcelas baixadas?
				If (SE1->E1_SALDO == 0 .AND. !Empty(SE1->E1_BAIXA)) 
					// Atualiza a parcela pela database
					If lAtualizar
						// Busca a CM da prestacao da dataBase
						aVlrCM := GEMCmTit( LIX->(Recno()) ,dRefer )
						aTitulo[17] := aVlrCM[1] // nome da taxa
						nCMPrinc    := aVlrCM[2] // cm do principal
						
						If  dDataBase >= dHabite
							nCMJuros    := aVlrCM[3] // cm do juros
					   else
						   nCMJuros    := 0
					   Endif
						
					Else
						// Busca a CM da prestacao da data de baixa
						aVlrCM := GEMCmTit( LIX->(Recno()) ,SE1->E1_BAIXA )
						aTitulo[17] := aVlrCM[1] // nome da taxa
						
						// carrega os valores baixados para o titulos
						aVlrCM := CMBAIXAS( lAtualizar ,LIX->(Recno()) ,SE1->E1_BAIXA ,LIT->LIT_EMISSA ,dHabite ,aBaixas )
						
						nCMPrinc := aVlrCM[05]*(LIX->LIX_ORIAMO/SE1->E1_VALOR ) // cm do principal
						                   
						If  dDataBase >= dHabite
							nCMJuros := aVlrCM[05]*(LIX->LIX_ORIJUR/SE1->E1_VALOR ) // cm do juros
					   else
						   nCMJuros := 0
					   Endif
					
					EndIf

					nVlrAtual := aTitulo[ 8]+nCMPrinc+aTitulo[10]+nCMJuros

				Else                                            
				    // Busca do Valor da Correcao Monetaria
				    if ! lUltCM
						If left(dTos(SE1->E1_VENCREA),6) < left(dTos(dRefer),6)
							// Busca a CM da prestacao da dataBase
							aVlrCM := GEMCmTit( LIX->(Recno()) ,GMPrevMonth(dRefer,1) )
						Else
							// Busca a CM da prestacao da dataBase
							aVlrCM := GEMCmTit( LIX->(Recno()) ,dRefer )
						Endif
					else
						// Busca a CM da prestacao da dataBase
						aVlrCM := GEMCmTit( LIX->(Recno()) ,dRefer )
					endif	
						
					aTitulo[17] := aVlrCM[1] // nome da taxa
					nCMPrinc    := aVlrCM[2] // cm do principal
					
//						If  dDataBase >= dHabite
					nCMJuros    := aVlrCM[3] // cm do juros
//						else
//							nCMJuros := 0
//						EndIf                      



					nVlrCM := 0
					
					If (SE1->E1_SALDO == SE1->E1_VALOR .AND. EMPTY(SE1->E1_BAIXA))
						nVlrAtual := aTitulo[ 8]+nCMPrinc+aTitulo[10]+nCMJuros
					Else
						nVlrCM    := GEMCMSLd( LIX->(Recno()) ,SE1->E1_SALDO ,SE1->E1_BAIXA ,dRefer ,LIT->LIT_EMISSA ,, dHabite )
						nVlrAtual := SE1->E1_SALDO+nVlrCM
					EndIf
				EndIf
                                
				If left(dtos(dRefer),6) > left(dtos(dHabite),6)
					aTitulo[17] := iIf( Empty(aTitulo[17]) ,LJO->LJO_INDPOS ,aTitulo[17] )
					nMes        := LJO->LJO_NMES2
				Else               
					aTitulo[17] := iIf( Empty(aTitulo[17]) ,LJO->LJO_IND ,aTitulo[17] )
					nMes        := LJO->LJO_NMES1
				EndIf
				
				lAtraso := .F.
				// Atualiza parcelas baixadas?
				If (SE1->E1_SALDO == 0 .AND. !Empty(SE1->E1_BAIXA))
					If lAtualizar
						If SE1->E1_BAIXA > SE1->E1_VENCREA
							lAtraso := .T.
							dUltBaixa := dRefer - (SE1->E1_BAIXA - SE1->E1_VENCREA)
						EndIf
					EndIf
				Else
					If dTos(SE1->E1_VENCREA) < dTos(dRefer)
						lAtraso := .T.
						If !Empty(SE1->E1_BAIXA)
							dUltBaixa := SE1->E1_BAIXA
						Else
							dUltBaixa := SE1->E1_VENCREA
						EndIf
					EndIf
				EndIf

				dVencto := SE1->E1_VENCREA

				//
				// CM do Principal e Juros
				//
				aTitulo[ 9] := nCMPrinc //CM Principal
				aTitulo[11] := nCMJuros //CM Juros

				aTitulo[ 7] := aTitulo[ 8]+aTitulo[ 9]+aTitulo[10]+aTitulo[11] // Valor do Titulo
				
				aTitulo[ 4] := dtoc(SE1->E1_VENCTO) // Data de vencimento
				aTitulo[ 5] := " "
				If dRefer >= SE1->E1_BAIXA
					aTitulo[ 5] := IIF(!Empty(SE1->E1_BAIXA),dtoc(SE1->E1_BAIXA)," ")   // Data da baixa do titulo
				Endif

				// Valor recebido pelo Titulo na data da baixa
				aTitulo[ 6] := nVlrBaixa

				//
				// não houve baixa parcial no titulo
				//
				If (SE1->E1_SALDO == 0 .AND. !Empty(SE1->E1_BAIXA))
					// carrega os valores baixados para o titulos
					aVlrCM := CMBaixas( lAtualizar ,LIX->(Recno()) ,dRefer ,LIT->LIT_EMISSA ,dHabite ,aBaixas )

					nVlrProRata   := aVlrCM[1] // Pro-Rata
					nVlrJurosMora := aVlrCM[2] // Juros Mora
					nVlrMulta     := aVlrCM[3] // multa
					nVlrDescon    := aVlrCM[4] //desconto
		
				Else
					aTitulo[ 6] := 0
					For nCntSE5 := 1 To Len(aBaixas)
						// Valor recebido pelo Titulo na data da baixa
						nVlrCM := GEMCMSLd( LIX->(Recno()) ,aBaixas[nCntSE5][2]+aBaixas[nCntSE5][3] ,aBaixas[nCntSE5][1] ,dRefer ,LIT->LIT_EMISSA ,.T. ,dHabite)

						aTitulo[ 6] += aBaixas[nCntSE5][2]+aBaixas[nCntSE5][3]+nVlrCM
					Next nCntSE5
					
					// parcela em atraso, calcula-se a Pro-Rata por atraso diario, Juros Mora e Multa
					If lAtraso 
						//
						// Parcela Atrasada
						//
						nPorcJurMor := LIT->LIT_JURMOR
						nPorcMulta  := LIT->LIT_MULTA
						
						//
						// calcula a Pro-Rata Dia de Atraso, Juros mora e Multa do titulo
						//
						aRet := t_GEMAtraCalc( nVlrAtual ,dVencto ,aTitulo[17] ,nMes ,nDiaCorr ,nPorcJurMor ,nPorcMulta ,dRefer ,cTipoJuros ,dUltBaixa )
						
						nVlrProRata   := aRet[1] // Pro-Rata dia (CM diaria) por atraso na baixa do titulo 
						nVlrJurosMora := aRet[2] // Juros Mora dia por atraso na baixa do titulo
						nVlrMulta     := aRet[3] // Multa por atraso na baixa do titulo
					EndIf
						
				EndIf

				aTitulo[12] := nVlrProRata   // Pro-Rata
				aTitulo[13] := nVlrJurosMora // Juros Mora
				aTitulo[14] := nVlrMulta     // multa
				aTitulo[15] := nVlrDescon    //desconto
			EndIf
	   
			// Valor Total Atualizado
			aTitulo[16] := nVlrAtual + aTitulo[12]+aTitulo[13]+aTitulo[14]-aTitulo[15]
			
		EndIf
	EndIf


RestArea(aAreaLJO)
RestArea(aAreaLIX)
RestArea(aAreaSE5)
RestArea(aAreaSE1)
RestArea(aArea)

Return( aTitulo )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | CMBaixas  ³ Autor ³ Reynaldo Miyashita     ³ Data ³ 27.06.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a correcao monetaria da pro-rata, multa, juros e desconto  ³±±
±±³          ³ do titulo jah baixado                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CMBaixas( lAtualizar ,nRecnoLIX ,dRef ,dContrato ,dHabite ,aBaixas )
Local aArea       := GetArea()
Local nVlrCM      := 0
Local nVlrProRata := 0
Local nVlrJuros   := 0
Local nVlrMulta   := 0
Local nVlrDesct   := 0

Local nCntSE5 := 0

DEFAULT lAtualizar := .F.
DEFAULT aBaixas    := {}
DEFAULT dRef       := dDatabase
DEFAULT aBaixas    := {}

	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( {nVlrProRata ,nVlrJuros ,nVlrMulta ,nVlrDesct ,nVlrCM} )
	EndIf

	For nCntSE5 := 1 to Len(aBaixas)
		// se data de referencia maior ou igual a data da baixa, processa	    
		If dRef >= aBaixas[nCntSE5][1]
			nVlrDesct   += aBaixas[nCntSE5][3]
			nVlrMulta   += aBaixas[nCntSE5][4]
			nVlrJuros   += aBaixas[nCntSE5][5]
			nVlrCM      += aBaixas[nCntSE5][6]
			nVlrProRata += aBaixas[nCntSE5][7]
		
			If lAtualizar
				// Corrige o Valor de Desconto
				nVlrDesct   += GEMCMSLd( nRecnoLIX ,aBaixas[nCntSE5][3] ,aBaixas[nCntSE5][1] ,dRef ,dContrato ,.T. ,dHabite)
	
				// Corrige o Valor de Multa
				nVlrMulta   += GEMCMSLd( nRecnoLIX ,aBaixas[nCntSE5][4] ,aBaixas[nCntSE5][1] ,dRef ,dContrato ,.T. ,dHabite)
				
				// Corrige o Valor de Juros
				nVlrJuros   += GEMCMSLd( nRecnoLIX ,aBaixas[nCntSE5][5] ,aBaixas[nCntSE5][1] ,dRef ,dContrato ,.T. ,dHabite)
		
				// Corrige o Valor da CM
				nVlrCM      += GEMCMSLd( nRecnoLIX ,aBaixas[nCntSE5][6] ,aBaixas[nCntSE5][1] ,dRef ,dContrato ,.T. ,dHabite)
				
				// Corrige o Valor de ProRata
				nVlrProRata += GEMCMSLd( nRecnoLIX ,aBaixas[nCntSE5][7] ,aBaixas[nCntSE5][1] ,dRef ,dContrato ,.T. ,dHabite)
			EndIf
		EndIf

	Next nCntSE5

RestArea(aArea)

Return( {nVlrProRata ,nVlrJuros ,nVlrMulta ,nVlrDesct ,nVlrCM} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMDlgSol ºAutor  ³Telso Carneiro      º Data ³  04/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Solidarios integrada Contratos(GEMA060) e          º±±
±±º    .     ³ Transferencia de Contrato(GEMA100)                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMA060 e GEMA100                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GMSOLCONT()
Local oDlgR
Local oGetSol
Local nOpcX	      := PARAMIXB[1]          //nOpc
Local cContr      := PARAMIXB[2] 		   //M->LIT_NCONTR
Local cCliente    := padr( PARAMIXB[3] ,TamSX3("LK6_CODSOL")[1] )
Local cLoja       := padr( PARAMIXB[4] ,TamSX3("LK6_LJSOLI")[1] )
Local nPos_CODSOL := 0
Local nPos_LJSOLI := 0
Local nPos_NOMSOL := 0
Local nOpca       := 0
Local nOpcGD      := 0
Local nCount      := 0
Local aHeadSOL    := {}
Local aColsSOL    := {}
Local aArea       := GetArea()

// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
ChkTemplate("LOT")

IF Type("aHeadLK6") == "U"
	PRIVATE aHeadLK6 :={}
	PRIVATE aColsLK6 :={}
Endif

lInclui := (nOpcX == 3)

If Empty(cCliente) .AND. Empty(cLoja) 
	Help(" ",1,"CLINAOINF",,STR0005 + CRLF + STR0006,1)  //"Código e loja do cliente "###"não foi informado no pedido."
Else
	aHeadSOL	:=aClone(aHeadLK6)
	aColsSOL	:=aClone(aColsLK6)
	
	dbSelectArea("LK6")
	IF Len(aHeadSOL)==0
		aHeadSOL	:= aClone(TableHeader("LK6"))
	Endif
	If Len(aColsSOL)==0
		aColsSOL := aClone(LoadSolContr(nOpcX ,aHeadSOL ,cContr))
	Endif
	
	If nOpcX == 3 .Or.nOpcX ==4
		nOpcGD := GD_UPDATE+GD_INSERT+GD_DELETE
	Else
		nOpcGD := 0
	EndIf
	
	DEFINE MSDIALOG oDlgR TITLE OemToAnsi(STR0001) FROM 9,0 TO 25,85 //"Cadastro de Solidarios"
	
	oGetSol := MsNewGetDados():New(002,02,097,338,nOpcGD,{|| SolCLinOk(cCliente,cLoja)},"AllwaysTrue",,,,9999,,,,oDlgR,aHeadSOL,aColsSOL)
	oGetSol:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlgR ON INIT EnchoiceBar(oDlgR,{|| iIf( nOpcGD == 0 .OR. SolCTudOk(cCliente,cLoja,oGetSol:aHeader,oGetSol:aCols);
	                                                          ,(nOpca:=1,oDlgR:End()) ;
	                                                          , nOpca:=0 )}           ;
	                                                     ,{|| nOpca:= 0,oDlgR:End()})
	
	If nOpca==1
		aHeadLK6:=aClone(oGetSol:aHeader)
		aColsLK6:=aClone(oGetSol:aCols)
	EndIf
EndIf

RestArea(aArea)

Return(NIL)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LoadSolContrºAutor  ³Reynaldo Miyashitaº Data ³  27/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡…o ³ Monta o aCols do solidarios do contrato                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LoadSolContr() 	    	                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Alias                                              ³±±
±±³			 ³ EXPC2 = Ordem Chave                                        ³±±
±±³			 ³ EXPC3 = Opcao aRotina                                      ³±±
±±³			 ³ EXPC4 = Tamanho do aHeader                                 ³±±
±±³			 ³ EXPC5 = numero do Pedido                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPA1 = Array com o aCols montado                          ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMDlgSol                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadSolContr(nOpcX ,aHeadLOC ,cContr)
Local aColsAux := {}
Local cCpoGrv  := ""
Local nX       := 0
Local nUsado   := Len(aHeadLOC)
Local aArea    := GetArea()
Local cAlias   := "LK6"
Local nOrdem   := 1

	If nOpcx # 3
		dbSelectArea(cAlias)
		dbSetOrder(nOrdem)
		dbSeek(xFilial(cAlias)+cContr)
		While !Eof() .And. xFilial(cAlias) == &(cAlias+"_FILIAL") .And. cContr == &(cAlias+"_NCONTR")
			aAdd(aColsAux,Array(nUsado+1))
			For nX := 1 To Len(aHeadLOC)
				If ( aHeadLOC[nX][10] != "V")
					aColsAux[Len(aColsAux) ,nX] := FieldGet(FieldPos(aHeadLOC[nX,2]))
				Else
					aColsAux[Len(aColsAux) ,nX] := CriaVar(aHeadLOC[nX,2])
				EndIf
			Next nX
			aColsAux[Len(aColsAux),nUsado+1] := .F.
			dbSkip()
		Enddo
	EndIf
	
	If nOpcx == 3 .Or. Len(aColsAux) == 0
		aAdd(aColsAux,Array(Len(aHeadLOC)+1))
		For nX := 1 to Len(aHeadLOC)
			aColsAux[1 ,nX] := CriaVar(aHeadLOC[nX ,2])
		Next nX
		aColsAux[1 ,Len(aHeadLOC)+1] := .F.
	EndIf

RestArea(aArea)

Return(aColsAux)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SolCLinOk ºAutor  ³Reynaldo Miyashita  º Data ³ 27/02/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle da MsNewGetdados Linha OK Cadastros de Solidarios º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMDlgSol                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SolCLinOk(cCliente,cLoja)
Local lRet       := .T.
Local nOcoCodSol := 0
Local nX         := 0
Local nPosCodSol := GdFieldPos( "LK6_CODSOL" ,aHeader)
Local nPosJlSol	 := GdFieldPos( "LK6_LJSOLI" ,aHeader)
Local nUsado 	 := Len(aHeader)

If cCliente == aCols[N,nPosCodSol] .AND. cLoja == aCols[N,nPosJlSol]
	Help("",1,"GFXEXISSOL",,OemToAnsi(STR0002),1) //"Existem Solidarios Duplicados"
	lRet := .F.
Endif
	
If lRet
	For nX := 1 To Len(aCols)
		// se o item nao foi deletado
		If !(aCols[N,nUsado+1])
			If aCols[nX,nPosCodSol]+aCols[nX,nPosJlSol] == aCols[N,nPosCodSol]+aCols[N,nPosJlSol]
				If !(aCols[nX,nUsado+1])
					nOcoCodSol++
				EndIf
			EndIf
		EndIf
	Next nX
	
	If nOcoCodSol > 1
		Help("",1,"GFXEXISSOL",,OemToAnsi(STR0002),1) //"Existem Solidarios Duplicados"
		lRet := .F.
	Else
		If Empty(aCols[N,nPosCodSol]) .Or. Empty(aCols[N,nPosJlSol])
			If !(aCols[N,nUsado+1])
				Help("",1,"OBRIGAT2")
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SolCTudOk ºAutor  ³Reynaldo Miyashita  º Data ³ 27/02/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Controle da MsNewGetdados Tudo OK Cadastro de Solidarios   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMDlgSol                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SolCTudOk(cCliente,cLoja,aHeadSol,aColsSOL)
Local lRet       := .T.
Local nOcoCodSol := 0
Local nX,nY
Local nPosCodSol := GdFieldPos( "LK6_CODSOL" ,aHeadSol)	
Local nPosJlSol	 := GdFieldPos( "LK6_LJSOLI" ,aHeadSol)
Local nUsado 	 := Len(aHeadSol)

For nX := 1 To Len(aColsSol)
	// se o item nao foi deletado
	If !(aColsSol[nX,nUsado+1])
		If Empty(aColsSol[nX,nPosCodSol]) .Or. Empty(aColsSol[nX,nPosJlSol])
			Help("",1,"OBRIGAT2")
			lRet := .F.
			Exit
		EndIf
		
		nOcoCodSol := 0
		For nY := 1 To Len(aColsSol)
			If aColsSol[nY,nPosCodSol]+aColsSol[nY,nPosJlSol] == aColsSol[nX,nPosCodSol]+aColsSol[nX,nPosJlSol]
				If !(aColsSol[nY,nUsado+1])
					nOcoCodSol++
				EndIf
			EndIf
		Next nY
		
		If nOcoCodSol > 1 .OR. aColsSol[nX,nPosCodSol]+aColsSol[nX,nPosJlSol]==cCliente+cLoja
			Help("",1,"GFXEXISSOL",,OemToAnsi(STR0002),1)  //"Existem Solidarios Duplicados"
			lRet := .F.
			Exit
		EndIf
	Endif
Next nX

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | CMDtPrc   ³ Autor ³ Reynaldo Miyashita     ³ Data ³ 01.03.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna a ultima correcao monetaria aplicado no titulo conforme³±±
±±³          ³ database. Informando a taxa, Cm do Principal e CM do juros     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template FUNCTION CMDtPrc( cPrefix ,cNum ,cParcel ,dRef ,dVencto )
Local aArea    := GetArea()
Local aAreaLIW := LIW->(GetArea())
Local nCMAmort := 0
Local nCMJur   := 0 
Local nCount   := 0
Local nMes     := 0
Local cTaxa    := ""
Local cLimite  := ""
Local lAchou   := .F.
Local aValores := {}
Local cAnoMesRef := ""
Local lUltCM   := GetNewPar("MV_GEMULTC",.F.) 

DEFAULT cPrefix := ""
DEFAULT cNum    := ""
DEFAULT cParcel := ""
DEFAULT dRef    := dDataBase
DEFAULT dVencto := dDataBase
           
	// Valida se tem licenças para o Template GEM = Gestao de Empreendimentos Imobiliarios							 
	If !HasTemplate("LOT")
		Return( {cTaxa ,nCMAmort ,nCMJur ,nMes } )
	EndIf

	// Se o parametro para verificar sempre a ultima correcao monetaria (a partir do dRef) estiver desligado       
	If ! lUltCM
	
		// obtem o mes/ano referencia do vencimento do titulo
		If dRef <= dVencto
			cAnoMesRef := Left(dTos(dVencto),6)
		Else
			// obtem o mes/ano referencia do mes anterior a data de referencia
			If left(dtos(dVencto),6) < left(dtos(dRef),6)
				cAnoMesRef := Left(dTos(GMPrevMonth(dRef,1)),6)
				
			// obtem o mes/ano referencia da data de referencia
			Else
				cAnoMesRef := Left(dTos(dRef),6)
			EndIf
		EndIf
	Else
		cAnoMesRef := Left(dTos(dRef),6)
	EndIf
	
	If !(Empty(cPrefix) .and. Empty(cNum) .and. Empty(cParcel))
		dbSelectArea("LIW")
		dbSetOrder(1) // LIW_FILIAL+LIW_PREFIX+LIW_NUM+LIW_PARCEL+LIW_TIPO+LIW_DTREF
		dbSeek(xFilial("LIW")+cPrefix+cNum+cParcel)
		While LIW->(!Eof()) .and. ;
		       LIW->LIW_FILIAL+LIW->LIW_PREFIX+LIW->LIW_NUM+LIW->LIW_PARCEL==xFilial("LIW")+cPrefix+cNum+cParcel
		      
			aAdd( aValores ,{LIW->LIW_DTPRC ,LIW->LIW_DTREF ,LIW->LIW_DTIND ,LIW->LIW_TAXA ,LIW->LIW_VLRAMO+LIW->LIW_ACUAMO ,LIW->LIW_VLRJUR+LIW->LIW_ACUJUR})
			dbSkip()
			
		EndDo
		
		// ordena data de processamento crescente
		aSort(aValores ,,,{|x,y| x[2] < y[2] })
		
		nCount := 1
		While nCount <= Len(aValores) .And. aValores[nCount,2] <= cAnoMesRef
			cTaxa    := aValores[nCount,4]
			nMes     := GMDateDiff( sTod(aValores[nCount,2]+"01") ,aValores[nCount,3] ,"m" )
			nCMAmort := aValores[nCount,5]
			nCMJur   := aValores[nCount,6]
			nCount += 1
		EndDo
	
	EndIf
	
RestArea(aAreaLIW)
RestArea(aArea)

Return( {cTaxa ,nCMAmort ,nCMJur ,nMes } )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    | GEMBaixa  ³ Autor ³ Daniel Tadashi Batori  ³ Data ³ 13.08.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula a correcao monetaria aplicado no titulo conforme       ³±±
±±³          ³ database e atualiza as variaveis private da funcao de baixa do ³±±
±±³          ³ financeiro.                                                    ³±±
±±³          ³ a variavel private cNumTit(origem da funcao fA200Ger) contem a ³±±
±±³          ³ informacao necessaria para localizar o registro no SE1 de      ³±±
±±³          ³ acordo o CNAB de retorno do banco.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template FUNCTION GEMBaixa()
Local aAreaSE1   := GetArea()
Local nTamTit    := TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]

If !HasTemplate("LOT")
	Return .F.
EndIf

DbSelectArea("SE1")

If !Empty(xFilial("SE1"))
	//Busca por IdCnab (sem filial)
	SE1->(dbSetOrder(19)) // IdCnab
	SE1->(DbSeek(Substr(cNumTit,1,10)))
Endif

//Se nao achou, utiliza metodo antigo (titulo)
If SE1->(!Found())
	SE1->(dbSetOrder(1))			
	SE1->(DbSeek(xFilial("SE1")+Substr(cNumTit,1,nTamTit)))
Endif

If SE1->(Found()) .And. !Empty(SE1->E1_NCONTR)
	//Calcula a correcao monetaria na variavel private nCM1,
	//Calcula a prorata na variavel private nProRata
	ExecTemplate("GEMJUROS",.F.,.F.,{"SE1" ,dBaixa})

EndIf
	
RestArea(aAreaSE1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMNxtParcºAutor  ³Daniel Tadashi B.   º Data ³  09/10/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtem o proximo numero disponivel para parcela a ser criadaº±±
±±º          ³ no GEM.                                                    º±± 
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINXAPI                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMNxtParc(cAliasSE1,	cPrefixo,	cNumero,	cParcela, cTipo) 

Local aArea    := GetArea()
Local aAreaSE1 := SE1->(GetArea())   
Local nTamParc := TamSx3("E1_PARCELA")[1]

DEFAULT cAliasSE1:= "SE1"
DEFAULT cPrefixo := (cAliasSE1)->E1_PREFIXO
DEFAULT cNumero  := (cAliasSE1)->E1_NUM
DEFAULT cParcela := Repl("0",Len((cAliasSE1)->E1_PARCELA))
DEFAULT cTipo    := (cAliasSE1)->E1_TIPO                 
     
dbSelectArea(cAliasSE1)
dbSetOrder(1)
While !eof() .and. (cAliasSE1)->(E1_PREFIXO+E1_NUM)==cPrefixo+cNumero
	
	cParcela := (cAliasSE1)->E1_PARCELA 
	(cAliasSE1)->( dbSkip() )
	
EndDo

cParcela := Soma1(cParcela,nTamParc,.T.)

RestArea(aArea)
RestArea(aAreaSE1)
Return (cParcela)      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMSE2DIS ºAutor  ³CLOVIS MAGENTA      º Data ³  13/11/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FUNCAO PARA VERIFICAR SE O TITULO AO SER EXCLUIDO DA SE2   º±±
±±º          ³ FOI GERADO PELA ROTINA DE DISTRATO                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA050                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function GEMSE2DIS()

Local lDistrato 	:= .F.
Local aArea 	  	:= GetArea()
Local aAreaSE2  	:= SE2->(GetArea())

dbSelectArea("LJV")
dbSetOrder(1)  //LJV_FILIAL+LJV_PREFIX+LJV_NUM+LJV_PARCEL+LJV_TIPO
If dbSeek(xFilial("LJV")+SE2->(E2_PREFIXO +E2_NUM +E2_PARCELA +E2_TIPO) )
	lDistrato := .T.
EndIf                                                                    

RestArea(aArea)
RestArea(aAreaSE2)

Return lDistrato

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMGETPARCºAutor  ³Clovis Magenta      º Data ³  09/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que verifica qual o real tipo da parcela no SE1		  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GEMA160 	                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template Function GemGetParc(aRecnos)

Local aArea		:= GetArea()
Local aAreaSE1 := SE1->( GetArea() ) 
Local aAreaLIX := LIX->( GetArea() ) 
Local aAreaLIW := LIW->( GetArea() ) 
Local aRecord  := {}
Local nCount   := 0
Local nX 		:= 0

For nX := 1 to Len(aRecnos)
	dbSelectArea("SE1")
	dbGoto(aRecnos[nX])
	
	dbSelectArea("LIX")
	dbSetOrder(3) // LIX_FILIAL+LIX_NCONTR+LIX_PREFIX+LIX_NUM+LIX_PARCEL+LIX_TIPO
	If MsSeek( xFilial("LIX")+SE1->(E1_NCONTR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
      
		aRecord  := {}
	   //
      // copia a registro da tabela LIX
      //
	   RecLock("LIX",.F.,.T.)
			For nCount := 1 to FCount()
				aAdd( aRecord ,FieldGet( nCount ) )
			Next nCount
		
	  		LIX->( dbDelete() )
		LIX->( MsUnlock() )
							
		RecLock("LIX",.T.)
			For nCount := 1 to Len(aRecord)
				LIX->(FieldPut( nCount ,aRecord[nCount] ))
			Next nCount
			
			LIX->LIX_TIPO := MVPROVIS
		LIX->( MsUnlock() )
	
      //
	   // copia a registro da tabela SE1
		//	   
		aRecord := {}
	   RecLock("SE1",.F.,.T.)
			For nCount := 1 to FCount()
				aAdd( aRecord ,FieldGet( nCount ) )
			Next nCount
			
			SE1->( dbDelete() )
		SE1->( MsUnlock() )
								
		RecLock("SE1",.T.)
			For nCount := 1 to Len(aRecord)
				SE1->(FieldPut( nCount ,aRecord[nCount] ))
			Next nCount
			
			SE1->E1_TIPO := MVPROVIS
		SE1->( MsUnlock() )
	
	EndIf
	
Next nX
	
RestArea(aAreaLIW)
RestArea(aAreaLIX)
RestArea(aAreaSE1)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³GMBLOQCM	³ Autor ³ Clovis Magenta    	  ³ Data ³ 13/12/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Alteracao de dados	da C.M. no momento da baixa				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ GMBLQCM()			 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA070																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GMBLQCM()

Local lRet	:= .F.

If	ExistBlock("PEBLQCM")
	lRet := ExecBlock("PEBLQCM",.F.,.F.)
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GEMREGSE5 ºAutor  ³Clovis Magenta      º Data ³  14.04.2009 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica registro de baixa a receber nos titulos renegocia-º±±
±±º          ³ dos														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA070                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function GEMREGSE5()
Local lEncontrou := .F.
Local aArea	:= GetArea()
Local aAreaSE5 := SE5->( GetArea() )
Local aAreaSE1 := SE1->( GetArea() )
Local cPrefixo := PARAMIXB[1]
Local cNum     := PARAMIXB[2]
Local cParcela := PARAMIXB[3]
Local cTipo	   := PARAMIXB[4]

//Certifica que esta posicionado no titulo a receber         
dbSelectArea("SE1")
dbSetOrder(1)	//E1_FILIAL+E1_PREFIXO+E1_NUMERO+E1_PARCELA+E1_TIPO
dbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela+cTipo)                 

// Posiciona no contrato deste titulo
dbSelectArea("LIT")
dbSetOrder(1)	//LIT_FILIAL+LIT_DOC+LIT_SERIE+LIT_CLIENT+LIT_LOJA
dbSeek(xFilial("LIT")+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA) )

// Procura a baixa desta parcela
dbSelectArea("SE5")
dbSetOrder(7)	//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ                         
If dbSeek(xFilial("SE5")+cPrefixo+cNum+cParcela+cTipo)

	//Procura pelas renegociacoes que este contrato possa ter sofrido                                                                     
	dbSelectArea("LIZ")
	dbSetOrder(1)	//LIZ_FILIAL+LIZ_NCONTR+LIZ_REVISA
	dbSeek(xFilial("LIZ")+SE1->E1_NCONTR)
	While LIZ->( !EOF() ) .AND. (LIZ->LIZ_NCONTR == SE1->E1_NCONTR )

		dbSelectArea("LJQ")
		dbSetOrder(1)	//LJQ_FILIAL+LJQ_NCONTR+LJQ_REVISA+LJQ_PARCEL
		If dbSeek(xFilial("LJQ")+LIZ->(LIZ_NCONTR+LIZ_REVISA)+cParcela) .and. SE5->E5_MOTBX == "LIQ"
			lEncontrou := .T.
			MSGALERT("Este titulo foi baixado pela rotina de Renegociação do Template GEM e não poderá ser manipulado!" , "Atenção")
			Exit
		EndIf
		
		LIZ->( dbSkip() )	
	EndDo
EndIF                        


RestArea(aAreaSE1)
RestArea(aAreaSE5)
RestArea(aArea)

Return( lEncontrou )
