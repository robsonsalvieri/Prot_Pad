#Include 'PROTHEUS.CH'
#Include 'LOCXPER.CH'
#Define SnTipo      1
#Define SlFormProp  3
#Define ScEspecie   8
#Define ScTipoDoc  10
#Define SlRemito   18

Static lChkLxProp:= FindFunction("ChkLxProp")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LxVldPer   ºAutor  ³Luis Enríquez Mata º Data ³  06/09/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida campos para el país Colombia. (Encabezado).          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : True o False no se cumple validación                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXNF                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LxVldPer(aCfgNf,cFunName)
	Local lRetVld	:= .T.
	Local cProvFE	:= SuperGetMV("MV_PROVFE",,"")

	Default aCfgNf   := {}
	Default cFunName := ""

	If cFunName == "MATA467N" .And. aCfgNf[SnTipo] == 1 .And. !Empty(cProvFE) //Factura de tipo Normal
		If SF2->(ColumnPos("F2_TIPONF")) > 0
			If M->F2_TIPONF $ "1001|1002|1003|1004" //Operación sujeta a Detracción
				If SF2->(ColumnPos("F2_CODDOC")) > 0
					lRetVld := VldCpoFEPe(M->F2_CODDOC, "F2_CODDOC",cFunName)
				EndIf
				If lRetVld .And. SF2->(ColumnPos("F2_MODCONS")) > 0
					lRetVld := VldCpoFEPe(M->F2_MODCONS, "F2_MODCONS",cFunName)
				EndIf
			EndIf
		EndIf
	EndIf

	If cFunName == "MATA462N" .And. (aCfgNf[SnTipo] == 50 .Or. aCfgNf[SnTipo] == 52) .And. !Empty(cProvFE) //Remisión de salida
		lRetVld := IIF(SF2->(ColumnPos("F2_TRANSP")) > 0 .And. SF2->(ColumnPos("F2_MODTRAD")) > 0, LxVldGRem(),.T.)
	EndIf

Return lRetVld

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldCpoFEPe ºAutor  ³Luis Enríquez Mata º Data ³  06/09/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida campos para Factura Electrónica de Peru (Encabezado).º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ExpL : True o False cuando esta vacio o no cumple condicion º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOCXPER                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldCpoFEPe(cTpRel,cCpo,cFunName)
	Local aArea		:= GetArea()
	Local lRet		:= .T.
	Local cCampo    := ""

	Default cCpo	 := ""
	Default cTpRel	 := ""
	Default cFunName := ""

	If cCpo $ "F2_CODDOC|F2_MODCONS"
		If Empty(cTpRel)
			cCampo := FWX3Titulo(cCpo) + " (" + cCpo + ")"
			Aviso(STR0001,StrTran(STR0002, '###', cCampo),{STR0003}) //Atención //"El campo ###, debe ser informado." //"OK"
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103DetCon³ Prog. ³ TOTVS                 ³Data  ³24/11/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta listbox com dados da conferencia do produto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103DetCon(oList,aListBox)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do list box                                 ³±±
±±³          ³ ExpA2 = Array com o contudo da list box                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOCXNF2                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103DetCon(oList,aListBox)
Local cCodPro 	:= aListBox[oList:nAt,1]
Local aListDet 	:= {}
Local oListDet
Local oDlgDet
Local aArea 	:= sGetArea()
Local oTimer
Local oIndice
Local aIndice 	:= {}
Local cIndice
Local aIndOrd 	:= {}
Local cKeyCBE  	:= "CBE_FILIAL+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA+CBE_CODPRO"
Local aColunas 	:= {}
Local aCpoCBE  	:= {}
Local nI
Local aCampos 	:= FWSX3Util():GetAllFields("CBE",.T.)
Local aIndex	:= FWSIXUtil():GetAliasIndexes('CBE')
Local nX 	  	:= 0
Local cX3Nivel  :=""
Local cUsado  	:= ""
Local cX3Conte  := ""
Local nIndex	:= 0
Local nField	:= 0
Local cIndex	:= ""
Local cDescInd	:= ""

sGetArea(aArea,"CBE")
sGetArea(aArea,"SB1")

cIdiom := FwRetIdiom()

For nIndex := 1 To Len(aIndex)
	cIndex := ""
	For nField := 1 To Len(aIndex[nIndex])
		cIndex += aIndex[nIndex][nField] + Iif(nField < Len(aIndex[nIndex]), "+", "")
	Next
	If SubStr(cIndex,1,Len(cKeyCBE)) == cKeyCBE
		For nField := 1 To Len(aIndex[nIndex])
			If !(AllTrim(aIndex[nIndex][nField]) == "CBE_FILIAL")
				cDescInd += AllTrim(FWX3Titulo(aIndex[nIndex][nField])) + Iif(nField < Len(aIndex[nIndex]), " + ", "")
			EndIf
		Next
		aadd(aIndOrd,nIndex)
		aadd(aIndice,cDescInd)
		Exit
	EndIf
Next

For nX:=1 to Len(aCampos)
	cUsado := GetSx3Cache(aCampos[nX],"X3_USADO")
	cX3Nivel := GetSx3Cache(aCampos[nX],"X3_NIVEL")
	cX3Conte := GetSx3Cache(aCampos[nX],"X3_CONTEXT")
	If ( x3uso(cUsado) .And. cNivel >= cX3Nivel .and. !(AllTrim(aCampos[nX]) $ cKeyCBE))
		aadd(aCpoCBE,{aCampos[nX],cX3Conte})
	Endif
Next nX

SB1->(DbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cCodPro))

cIndice := aIndice[1]

For nI := 1 to Len(aCpoCBE)
	aadd(aColunas,FWX3Titulo(aCpoCBE[nI,1]))
Next

CBE->(dbsetOrder(2))

DEFINE MSDIALOG oDlgDet TITLE OemToAnsi(STR0004+cCodPro+" "+SB1->B1_DESC) From 0, 0 To 25, 67 OF oMainWnd //"Detalles de verificación del producto"
oListDet := TWBrowse():New( 02, 2, (oDlgDet:nRight/2)-5, (oDlgDet:nBottom/2)-30,,aColunas,, oDlgDet,,,,,,,,,,,, .F.,, .T.,, .F.,,, )

A103AtuDet(cCodPro,oListDet,aListDet,,aCpoCBE)

@ (oDlgDet:nBottom/2)-25, 005 Say STR0005 PIXEL OF oDlgDet //Orden
@ (oDlgDet:nBottom/2)-25, 025 MSCOMBOBOX oIndice VAR cIndice    ITEMS aIndice    SIZE 180,09 PIXEL OF oDlgDet
oIndice:bChange := {||CBE->(DbSetOrder(aIndOrd[oIndice:nAt])),A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)}
@  (oDlgDet:nBottom/2)-25, (oDlgDet:nRight/2)-50 BUTTON STR0006 SIZE 40,10 ACTION ( oDlgDet:End() ) Of oDlgDet PIXEL //Retorna

DEFINE TIMER oTimer INTERVAL 1000 ACTION (A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)) OF oDlgDet
oTimer:Activate()

ACTIVATE MSDIALOG oDlgDet CENTERED

sRestArea(aArea)
Return .T.

/*

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RetDetLine³ Prog. ³ TOTVS                 ³Data  ³24/11/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para retornar campos para o bLine do listbox        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetDetLine(aListDet,nAt)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aListDet - Array com dados do listbox                      ³±±
±±³          ³ nAt      - Linha do listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A103AtuDet                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetDetLine( aListDet,nAt)
Local aRet := {}
Local nX:= 0
For nX:= 1 to len(aListDet[nAt])
	aadd(aRet,aListDet[nAt,nx])
Next nX
Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103AtuDet³ Prog. ³ TOTVS                 ³Data  ³24/11/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza array para listbox dos detalhes de conferencia    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103AtuDet(cCodPro,oListDet,aListDet,oTimer)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPro  - Codigo do produto a procurar no CBE             ³±±
±±³          ³ oListDet - Objeto listbox a atualizar                      ³±±
±±³          ³ aListDet - Array do listbox                                ³±±
±±³          ³ oTimer   - Objeto timer a desativar para o processo        ³±±
±±³          ³ aCpoCBE  - Campos do LISTBOX                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOCXNF2                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A103AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)
Local aLine := {},nI
Local uConteudo

If ValType(oTimer) == "O"
	oTimer:Deactivate()
EndIf

aListDet := {}

CBE->(MsSeek(xFilial("CBE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cCodPro))

While !CBE->(eof()) .and. CBE->CBE_NOTA+CBE->CBE_SERIE == SF1->F1_DOC+SF1->F1_SERIE .and.;
		CBE->CBE_FORNEC+CBE->CBE_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA .and. CBE->CBE_CODPRO == cCodPro

	aLine := {}
	For nI := 1 to Len(aCpoCBE)
		If (aCpoCBE[nI,2]) <> 'V'
			uConteudo := CBE->&(aCpoCBE[nI,1])
		Else
			uConteudo := CriaVar(aCpoCBE[nI,1])
		EndIf
		aadd(aLine,uConteudo)
	Next
	aadd(aListDet,aLine)

	CBE->(DbSkip())
EndDo
If Empty(aListDet)
	aLine := {}
	For nI := 1 To Len(aCpoCBE)
		aadd(aLine,CriaVar(aCpoCBE[nI,1],.f.))
	Next
	aadd(aListDet,aLine)
EndIf

oListDet:SetArray( aListDet )
oListDet:bLine := { || RetDetLine(aListDet,oListDet:nAT)  }

oListDet:Refresh()

If ValType(oTimer) == "O"
	oTimer:Activate()
EndIf

Return

/*/{Protheus.doc} GrvSer2Per
	Tratamiento para grabado de serie 2
	La función es llamada desde LOCXNF, función GravaNfGeral.
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@version version
	@param cPrefC: Prefijo de la tabla (SF1 / SF2).
	@return Nil
	/*/
Function GrvSer2Per(cPrefC)
Local cCompSF3 := ""

Default cPrefC := ""

	If !Empty(cPrefC)
		If 	( !Empty(&(cPrefC+"_SERIE2")) .or. !Empty(&(cPrefC+"_SERORI")) )
			If cPrefC=="SF1->F1"
				cCompSF3:=SF1->(F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC+F1_SERIE)
			Else
				cCompSF3:=SF2->(F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)
			EndIf
			DbSelectArea("SF3")
			DbSetOrder(4)
			DbSeek(cCompSF3)
			Do While !Eof() .And. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE)==cCompSF3
				RecLock("SF3",.F.)
					SF3->F3_SERIE2 := &(cPrefC+"_SERIE2")
					SerieNfId("SF3",1,"F3_SERORI",,,,&(cPrefC+"_SERORI"))
				MsUnLock()
				DbSkip()
			EndDo
		EndIf
	EndIf

Return

/*/{Protheus.doc} CposSerPer
	La función es llamada desde LOCXNF, función GravaCabNF
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@version version
	@param  cAlias: Alias de tabla (SF1 / SF2)
			aCabNota: Campos de SF1 / SF2
			nPosSERIE: Posición del campo SERIE
			nPosSERIE2: Posición del campo SERIE2
			***Las variables aCabNota, nPosSERIE y nPosSERIE2 se pasan por referencia***
	@return Nil
	/*/
Function CposSerPer(cAlias, aCabNota, nPosSERIE, nPosSERIE2)
Local cCpSer2 := ""
Local cPrefC  := ""

Default cAlias := ""
Default aCabNota := {}
Default nPosSERIE := 0
Default nPosSERIE2 := 0

	If !Empty(cAlias) .And. Len(aCabNota) > 0
		cPrefC  := PrefixoCpo(cAlias)

		nPosSERIE2:=Ascan(aCabNota[1], cPrefC+"_SERIE2")
		If nPosSERIE2>0
			cCpSer2:=aCabNota[1][nPosSERIE2]
			aCabNota[1][nPosSERIE2]:="SERIE2"
			nPosSERIE:=Ascan(aCabNota[1], cPrefC+"_SERIE")
			aCabNota[1][nPosSERIE2]:=cCpSer2
		Else
			nPosSERIE:=Ascan(aCabNota[1], cPrefC+"_SERIE")
		Endif
	EndIf

Return

/*/{Protheus.doc} LxSer2Per
	Validación campos de serie para el país Perú
	La función es ejecutada desde LOCXNF, función NfTudOk.
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@param	cAliasC: Alias tabla SF1/SF2.
			aCabNota: Campos del encabezado (SF1/SF2)
			cSerie: Serie del documento
			lSerie2: .T. Si utiliza serie 2.
	@return cSerie: Serie del documento fiscal.
	/*/
Function LxSer2Per(cAliasC, aCabNota, cSerie, lSerie2)
Local cPrefixSF := ""
Local nPos      := 0

Default cAliasC  := ""
Default aCabNota := {}
Default cSerie   := ""
Default lSerie2  := .F.

	If !Empty(cAliasC) .And. Len(aCabNota) > 0
		cPrefixSF := PrefixoCpo(cAliasC)

		If lSerie2
			nPos := Ascan(aCabNota[1],  cPrefixSF+"_SERIE2")
			If nPos > 0 .And. Empty(cSerie)
				cSerie := aCabNota[2][nPos]
			EndIf
			If Empty(cSerie)
				nPos := Ascan(aCabNota[1], cPrefixSF+"_SERIE", ++nPos)
				If ( nPos > 0 )
					cSerie:=aCabNota[2][nPos]
				EndIf
			EndIf
		Else
			nPos := Ascan(aCabNota[1],{ |x| UPPER(x) == cPrefixSF+"_SERIE" } )
			IIf( nPos > 0, cSerie := aCabNota[2][nPos], "")
		EndIf
	EndIf
Return cSerie

/*/{Protheus.doc} CondNatPer
	Valida si el tipo de condición de pago y naturaleza/modalida son validos para el tipo de documento.
	La función es ejecutada en LOCXNF2, función LxTudOkPer.
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@param 	cTipoDoc: Tipo de documento.
			cAliasI: Alias de tabla (SD1 / SD2).
			aCpItens: Array con campos de ítems.
			aCItens: Ítems de documento fiscal.
			cNatureza: Código de naturaleza/modalidad.
			cCondicao: Código de condición de pago.
			aRecnoSE1: Array con ítem de anticipo.
	@return lRet: .T. si la condición de pago y naturaleza son validos.
	/*/
Function CondNatPer(cTipoDoc,cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
Local lRet			:= .T.
Local cMsg			:= ""
Local aRecnoAux	:= {}

Default cTipoDoc  := ""
Default cAliasI   := ""
Default aCpItens  := {}
Default aCItens   := {}
Default cNatureza := ""
Default cCondicao := ""
Default aRecnoSE1 := {}

	//Valida cond de pagto e natureza de oper. conforme tipo de nota
	//"A" - Adiantamento "N" - Normal
	// ED_OPERADT = 1 - Operacao de Adiantamento
	// E4_CTRADT = 1 - Compensa Adiantamentos

	If Trim(cNatureza) <> ""
		DbSelectArea("SED")
		DbSetOrder(1)
		MsSeek(XFilial("SED")+cNatureza)
		If cTipoDoc == "A" .AND. SED->ED_OPERADT <> "1"
			cMsg += STR0013+CRLF //"Na Nota Fiscal de Adiantamento é necessário escolher uma Natureza que seja Operação de Adiantamento."
		ElseIf cTipoDoc <> "A" .AND. SED->ED_OPERADT == "1"
			cMsg += STR0014+CRLF //"Escolher uma Natureza que seja Operação de Adiantamento somente é permitido para Nota Fiscal de Adiantamento."
		EndIf
	ElseIf cTipoDoc == "A"
		cMsg += STR0015+CRLF //"Na Nota Fiscal de Adiantamento é necessário escolher uma Natureza que seja Operação de Adiantamento."
	EndIf

	If Trim(cCondicao) <> ""
		DbSelectArea("SE4")
		DbSetOrder(1)
		MsSeek(XFilial("SE4")+cCondicao)
		If cTipoDoc == "A" .AND. SE4->E4_CTRADT == "1"
			cMsg += STR0016+CRLF //"Na Nota Fiscal de Adiantamento não é possível utilizar uma condição de pagamento que compense adiantamentos."
		ElseIf cTipoDoc == "N" .AND. SE4->E4_CTRADT == "1" .AND. Len(aRecnoSE1) == 0
			cMsg += STR0017+CRLF //"Quando for utilizada condição de pagamento de compensação de adiantamentos devem ser vinculados adiantamentos aos itens através do botão ações relacionadas."
		ElseIf cTipoDoc == "N" .AND. SE4->E4_CTRADT <> "1" .AND. Len(aRecnoSE1) > 0
			cMsg += STR0018+CRLF //"Quando forem vinculados adiantamentos é necessário utilizar uma condição de pagamento que compense adiantamentos."
		EndIf
	EndIf

	If cMsg <> ""
		lRet := .F.
		Aviso(STR0019,cMsg,{STR0020}) //Atenção#OK
	EndIf

	aRecnoAux := aRecnoSE1

Return lRet

/*/{Protheus.doc} NfTudOkPer
	Función de validaciones generales de nota fiscal - Perú
	La función es ejecutada desde LOCXNF, función NfTudOk.
	@type  Function
	@author Arturo Samaniego
	@since 02/09/2022
	@param  cFunName: Nombre de función
			aCfgNf: Array de configuración de nota fiscal.
			cAliasC: Alias de tabla de encabezado (SF1 / SF2).
			cAliasI: Alias de tabla de ítems (SD1 / SD2).
			aCpItens: Array con campos de ítems.
			aCItens: Ítems de documento fiscal.
			cNatureza: Código de modalidad o naturaleza. (Pasar el valor por referencia: @cNatureza)
			cCondicao: Código de condición de pago.
			aRecnoSE1: Array con ítem de anticipo.
			cnFiscal: Número de nota fiscal.
			cSerie: Código de serie.
			cEspecie: Código de especie del documento.
			cTipDoc: Código de tipo de documento.
			cFilAnt: Código de filial.
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function NfTudOkPer(cFunName, aCfgNf, cAliasC, cAliasI, aCpItens, aCItens, cNatureza, cCondicao, aRecnoSE1, cnFiscal, cSerie, cEspecie, cTipDoc, cFilAnt)
Local cSF  := ""
Local nI   := 0
Local lRet := .T.
Local nSerie := 0
Local nNF    := 0

Default cFunName  := Funname()
Default aCfgNf    := {}
Default cAliasC   := ""
Default cAliasI   := ""
Default aCpItens  := {}
Default aCItens   := {}
Default cNatureza := CriaVar("F1_NATUREZ")
Default cCondicao := ""
Default aRecnoSE1 := {}
Default cnFiscal  := ""
Default cSerie    := ""
Default cEspecie  := ""
Default cTipDoc   := ""
Default cFilAnt   := ""

	cSF := IIf(cAliasC == "SF2", "F2", "F1")

	If SF1->(ColumnPos("F1_TPRENTA")) > 0 .AND. SF2->(ColumnPos("F2_TPRENTA")) > 0 .and.  StrZero(aCfgNf[SnTipo],2)$"06|07|08|09|10|12|13|14|20"  //NDI compras/NCP/NCI compras/NDP/NF compras/NF benef/NF import/NF fletes/NF Anticipos
		SA2->(dbSeek(xFilial("SA2") +  &("M->" + cSF + IIf(cSF == "F2", "_CLIENTE", "_FORNECE")) + &("M->" + cSF + "_LOJA")))
		If(Alltrim(SA2->A2_DOMICIL)) == "2" .And. Empty(Alltrim(&("M->" + cSF + "_TPRENTA")))  // 1- Domiciliado 2- não Domiciliado
			MsgAlert(STR0007 + "TpRen.N Do.") //"Complete el campo del encabezado: "
			lRet := .F.
		Else
			lRet := .T.
		EndIf
	EndIf

	If  &("M->" + cSF + "_TPDOC") == "05" .And. !(((Val( &("M->" + cSF + "_SERIE")) >= 1 .And. Val(&("M->" + cSF + "_SERIE")) <= 5)) .Or. ((Val(&("M->" + cSF + "_SERIE2")) >= 1 .AND. Val(&("M->" + cSF + "_SERIE2")) <= 5)))
		MsgAlert(STR0008, STR0009) //"Si el campo Tp. Comprob = 05, el Campo Serie debe tener una de las siguientes informaciones: 1=Boleta manual;2=Boleta automático;3=Boleta electrónica;4=Otros;5=Anulado" //"íATENCION!"
		lRet := .F.
	EndIf

	If lRet
		lRet := LxVldPer(aCfgNf,cFunName)
	EndIf

	If lRet .AND. (aCfgNf[SnTipo] == 1 .OR. aCfgNf[SnTipo] == 19)
		lRet := LxTudOkPer(aCfgNf[ScTipoDoc],cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
	EndIf

	If lRet .And. Valtype(aCfgNF[SlFormProp]) == "L" .And. aCfgNF[SlFormProp] .And. (!Str(aCfgNF[SnTipo],2)$"54|64|50|60") .And. GetNewPar("MV_CTRLFOL",.F.)
		lRet := CtrFolios(cFilAnt,cSerie,cEspecie,cnFiscal)
	EndIf

	If lRet .AND. MaFisRet(,"NF_BASEDUP") > 0 .AND. Empty(MaFisRet(,"NF_NATUREZA")) .AND. cTipDoc <> "D"  .AND. cAliasC == "SF1" .And. !aCfgNf[SlRemito]

		If !Empty(M->F1_NATUREZ)
			MaFisAlt("NF_NATUREZA",M->F1_NATUREZ)
			cNatureza:=M->F1_NATUREZ
		EndIf

		If GetNewPar("MV_NFENAT",.F.) .And. Empty(MaFisRet(,"NF_NATUREZA"))
			Aviso(STR0010,STR0011,{STR0003}) //"Preencha o codigo da natureza!"###"OK"
			lRet := .F.
		EndIf
		If lRet //Validacoes de Adiantament
			If lRet .AND. aCfgNf[SnTipo] == 20
				lRet := LxTudOkPer(aCfgNf[ScTipoDoc],cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
			endif
		Endif
	EndIf

	If lRet .And. cFunName <> "MATA447"
		if cAliasC == "SF1" .And. (aCfgNf[SnTipo] == 10 .OR. aCfgNf[SnTipo] == 20 )
			If Empty(cNatureza)
				cNatureza := M->F1_NATUREZ
			EndIf
			lRet := LxTudOkPer(aCfgNf[ScTipoDoc],cAliasI,aCpItens,aCItens,cNatureza,cCondicao,aRecnoSE1)
		Endif
	Endif

	If (( Len(cSerie) <= TamSX3(PrefixoCpo(cAliasI)+"_SERIE")[1] ))
		//³Verificando numeracao da NF em todos os itens
		nSerie	:= Ascan(aCpItens, {|x| Trim(x) == PrefixoCpo(cAliasI)+"_SERIE"})
		nNF		:= Ascan(aCpItens, {|x| Trim(x) == PrefixoCpo(cAliasI)+"_DOC"})
		For nI := 1 to Len(aCitens)
			If !aCitens[nI][Len(aCitens[nI])] .AND. aCitens[nI][nNF] != cNFiscal .OR. aCitens[nI][nSerie] != cSerie
				Aviso(STR0010,STR0012+"("+cnFiscal+"-"+cSerie+"/"+aCitens[nI][nNF]+"-"+aCitens[nI][nSerie]+")",{STR0003})					    			 //"ATENCAO"###"Inconsistencias com a numeracao da NF em relacao a seus itens"###"OK"
				lRet := .F.
				Loop
			EndIf
		Next nI
	EndIf

Return lRet

/*/{Protheus.doc} LxLinOkPer
	Función para realizar validaciones por ítem de documento fiscal.
	La función es ejecutada en LOCXNF2, función LxLOkPer.
	@type  Function
	@author Arturo Samaniego
	@since 03/09/2022
	@param 	cAliasI: Alias de tabla de items (SD1 / SD2).
			aCposIOri: Campos de ítems.
			aDadosIOri: Linea de ítems a validar.
			cTipDoc: Tipo de documento.
			nLinha: Número de ítem.
			lFormP: Indicia si es formulario propio (.T.).
			aCfgNF: Array con configuración de nota fiscal.
			cEspecie: Código de especie del documento fiscal.
			cCondicao: Código de condición de pago.
			nSalvaN: Número de ítem a validar.
			aHeader: Array con campos de ítems.
			aCols: Array de ítems.
			cFunname: Nombre de función.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function LxLinOkPer(cAliasI,aCposIOri,aDadosIOri,cTipDoc,nLinha,lFormP, aCfgNF, cEspecie, cCondicao, nSalvaN, aHeader, aCols, cFunname)
Local cTes 		:= ""
Local lRet 		:= .T.
Local nPos 		:= 0
Local nX   		:= 0
Local nAdt 		:= 0
Local nTot 		:= 0
Local cFilSF4   := xFilial("SF4")
Local cF2TipoNF := ""
Local cCpoExp   := ""
Local cAvisoE   := ""
Local cOpeExp   := ""
Local cProvFE   := GetMv( "MV_PROVFE",.T.,"")
local lAnticip  := .F.
Local nI        := 0
Local aAux      := {}
Local lFactElec	:= !Empty(SuperGetMV("MV_PROVFE", .F., "")) //Facturacion Electronica Activa

Default cAliasI    := ""
Default aCposIOri  := {}
Default aDadosIOri := {}
Default cTipDoc    := ""
Default nLinha     := 0
Default lFormP     := .F.
Default aCfgNF     := {}
Default cEspecie   := ""
Default cCondicao  := ""
Default nSalvaN    := 0
Default aHeader    := {}
Default aCols      := {}
Default cFunname   := Funname()

	nPosNFOri  := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_NFORI'})
	nPosSerOri := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_SERIORI'})
	nPosRemito := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_REMITO'})
	nPosCod    := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_COD'})
	nPosTes    := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TES'})
	nAdt       := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_VALADI'})
	nTot       := Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TOTAL'})
	cCpoExp  := IIf(Alltrim(cEspecie) == "NF",Alltrim(FWX3Titulo("F2_TIPONF")) + " (F2_TIPONF)",IIf(Alltrim(cEspecie) == "NDC",Alltrim(FWX3Titulo("F2_TIPREF")) + " (F2_TIPREF)",Alltrim(FWX3Titulo("F1_TIPREF")) + " (F1_TIPREF)"))
	lAnticip := A410UsaAdi( cCondicao )

	If lRet .And. nSalvaN > 0 .And. aCols[nSalvaN][Len(aHeader)+1] == .F. .And. !(Alltrim(aCfgNF[ScEspecie]) $ "NCC|NDC")
		lRet := VldNFOrig(aCfgNF[SnTipo],nSalvaN,aDadosIOri,nPosNFOri,nPosSerOri)
	EndIf

	If cAliasI $ "|SD2|SD1|"
		If cTipDoc == "A"
			nPos = Ascan(aCposIOri,{|cCam| Trim(cCam) == PrefixoCpo(cAliasI)+'_TES'})
			If nPos > 0
				For nX := 1 To Len(aDadosIOri)
					If !aDadosIOri[nX][Len(aDadosIOri[nX])]
						If cTes == ""
							cTes := aDadosIOri[nX][nPos]
							//Verificar se a tes gera duplicata e nao movimenta estoque
							DbSelectArea("SF4")
							DbSetOrder(1)
							If MsSeek(cFilSF4+cTes) .AND. (SF4->F4_ESTOQUE == "S" .OR. SF4->F4_DUPLIC == "N")
								If cAliasI == "SD1"
									Aviso(STR0021,STR0022,{STR0020}) //Atenção#"En la operacion de anticipo el TES utilizado debe afectar financiero y no movilizar stock."#OK
								Else
									Aviso(STR0021,STR0023,{STR0020}) //Atenção#"Na operação de adiantamento o TES utilizado deve gerar duplicata e não movimentar estoque."#OK
								EndIf
								lRet := .F.
								Exit
							EndIf
						ElseIf aDadosIOri[nX][nPos] <> cTes
							If cAliasI == "SD1"
								Aviso(STR0021,STR0024,{STR0020}) //Atenção#"En la operacion de anticipo los items de la Nota de Entrada deben poseer el mismo TES."#OK
							Else
								Aviso(STR0021,STR0033,{STR0020}) //Atenção#"Na operação de adiantamento os itens da Nota de Saída devem possuir o mesmo TES."#OK
							EndIf
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf

		If cTipDoc == "N" .AND. nAdt > 0 .AND. !aDadosIOri[nLinha][Len(aDadosIOri[nLinha])] .AND. aDadosIOri[nLinha][nAdt] > aDadosIOri[nLinha][nTot] .and. lAnticip
			Aviso(STR0021,STR0025,{STR0020}) //Atenção#"O Valor de adiantamento relacionado não deve ser superior ao valor do item."#OK
			lRet := .F.
		EndIf

		If lRet .And. !Empty(cProvFE) .And. !aDadosIOri[nLinha][Len(aDadosIOri[nLinha])] .And. nPosTes > 0 .And. FindFunction("M486TIPIGV")
			If cFunname == "MATA467N" .And. Alltrim(cEspecie) == "NF" .And. SF2->(ColumnPos("F2_TIPONF")) > 0 .And. SF2->(ColumnPos("F2_SERIE2")) > 0 .and. cTipDoc == "N"
				cOpeExp   := IIf(cAliasI =="SD2",IIf(Substr(M->F2_SERIE2,1,1) $ 'B',"0200|0201|0203|0204|0206|0207|0208","0200|0201|0202|0203|0204|0205|0206|0207|0208"),"")
				If M->F2_TIPONF $ cOpeExp .And. M486TIPIGV(aDadosIOri[nLinha][nPosTes],'IGV') <> "40"
					cAvisoE   := StrTran(STR0026, '###',aDadosIOri[nLinha][nPosTes]) //"Para el Tipo de Entrada/Salida ###, el tipo de Afectación del IGV debe ser 40-Exportación de Bienes o Servicios ya que el campo #Exp es de exportación."
					MsgAlert(StrTran(cAvisoE, '#Exp',cCpoExp),STR0021) //"¡Atencion!"
					lRet := .F.
				ElseIf !(M->F2_TIPONF $ cOpeExp) .And. M486TIPIGV(aDadosIOri[nLinha][nPosTes],'IGV') == "40"
					cAvisoE   := StrTran(STR0027, '###',aDadosIOri[nLinha][nPosTes]) //"Para el Tipo de Entrada/Salida ###, el tipo de Afectación del IGV debe ser diferente de 40-Exportación de Bienes o Servicios ya que el campo #Exp es no es de exportación."
					MsgAlert(StrTran(cAvisoE, '#Exp',cCpoExp),STR0021)  //"¡Atencion!"
					lRet := .F.
				EndIf
			ElseIf cFunname == "MATA465N" .And. ((Alltrim(cEspecie) == "NDC" .And. SF2->(ColumnPos("F2_TIPREF")) > 0) .Or. (Alltrim(cEspecie) == "NCC" .And. SF1->(ColumnPos("F1_TIPREF")) > 0))
				cF2TipoNF := IIf(Alltrim(cEspecie) == "NDC", M->F2_TIPREF, M->F1_TIPREF)
				If cF2TipoNF $ "11" .And. M486TIPIGV(aDadosIOri[nLinha][nPosTes],'IGV') <> "40"
					cAvisoE   := StrTran(STR0026, '###',aDadosIOri[nLinha][nPosTes]) //"Para el Tipo de Entrada/Salida ###, el tipo de Afectación del IGV debe ser 40-Exportación de Bienes o Servicios ya que el campo #Exp es de exportación."
					MsgAlert(StrTran(cAvisoE, '#Exp',cCpoExp),STR0021) //"¡Atencion!"
					lRet := .F.
				ElseIf !(cF2TipoNF $ "11") .And. M486TIPIGV(aDadosIOri[nLinha][nPosTes],'IGV') == "40"
					cAvisoE   := StrTran(STR0027, '###',aDadosIOri[nLinha][nPosTes]) //"Para el Tipo de Entrada/Salida ###, el tipo de Afectación del IGV debe ser diferente de 40-Exportación de Bienes o Servicios ya que el campo #Exp es no es de exportación."
					MsgAlert(StrTran(cAvisoE, '#Exp',cCpoExp),STR0021) //"¡Atencion!"
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//Validacao notas fiscais
	If lRet.And. nLinha > 0
		aAux := {}
		For nI:=1 To Len(aDadosIOri)
			aAdd(aAux,{ aDadosIOri[nI][nPosCod], aDadosIOri[nI,nPosTes] , aDadosIOri[nI,Len(aDadosIOri[nI])] })
		Next nI
		If !Empty(aDadosIOri[nLinha,nPosTes])
			lRet := ValImpPer(nLinha,aAux,"PIV",cFunname)
			If lRet
				lRet := ValImpPer(nLinha,aAux,"DIG",cFunname)
			EndIf
		EndIf
	EndIf

	If lRet .And. nLinha > 0 .And.  cFunname == "MATA465N" .And. cEspecie $ "NDC|NCC" .And. lFormP .And. (aCols[nSalvaN][Len(aHeader)+1] == .F.) .And. (lFactElec) .And. Empty(aCols[nSalvaN][nPosRemito])
		lRet := LxVldDocIt(aCols[nSalvaN][nPosNFOri], aCols[nSalvaN][nPosSerOri], cEspecie)
	EndIf

Return lRet


/*/{Protheus.doc} LxDelNFPer
	Validaciones generales en el borrado de documento fiscal.
	La función es ejecutada en LOCXNF, función LocxDelNF.
	@type  Function
	@author Arturo Samaniego
	@since 03/09/2022
	@param 	cAlias: Alias de tabla (SF1 / SF2).
			lLocxAuto: Indica si es rutina automatica (.T.).
			cFunName: Nombre de rutina
	@return lRet: .T. Si cumple con las condiciones para anular/borrar el documento.
	/*/
Function LxDelNFPer(cAlias, lLocxAuto, cFunName)
Local cAliCampo := ""
Local lRet      := .T.

Default cAlias      := ""
Default lLocxAuto   := .F.
Default cFunName    := Funname()

	cAliCampo := Right(cAlias, 2)

	If (Empty(SuperGetMV("MV_SIGNAWS",.F.,""))) .And. cFunName $ "MATA467N|MATA465N|" .And. !lLocxAuto
		If IIf (cAlias $ "SF2|SF1" , !Empty((cAlias)->(ColumnPos(cAliCampo+"_FLFTEX"))) .Or. !( (cAlias)->&(cAliCampo+"_FLFTEX") $ "0|3|5|8" ), .F.)
			If (cAlias)->&(cAliCampo+"_FLFTEX") $ "1|4|6"
				MsgAlert( STR0028 + (cAlias)->&(cAliCampo+"_SERIE") + (cAlias)->&(cAliCampo+"_DOC") + STR0029 )//"El documento " ## " no puede ser borrado/anulado pues ya fue Transmitido. Utilice funcionalidad de comunicado de baja de la rutina Documentos Electrónicos."
				Return .F.
			ElseIf (cAlias)->&(cAliCampo+"_FLFTEX") $ "7"
				MsgAlert( STR0028 + (cAlias)->&(cAliCampo+"_SERIE") + (cAlias)->&(cAliCampo+"_DOC") + STR0030 )//"El documento " ## " se encuentra en proceso de baja. Utilice funcionalidad de comunicado de baja de la rutina Documentos Electrónicos."
				Return .F.
			EndIf
		EndIf
	EndIf

	If cAlias =="SF1"
		If AliasInDic("FR3") .AND. AliasInDic("FIE") .AND. A410UsaAdi(SF1->F1_COND)
			If !BaixaAdt()
				If IsBlind()
					Conout(STR0031)
				Else
					Aviso(STR0001,STR0031 + CRLF + STR0032,{STR0020}) //"Atenção"#"Não foi possível excluir a baixa do adiantamento associado ao Documento de Saída."#"Não será possível excluir o Documento de Saída."#OK
				EndIf
				DisarmTransaction()
				Return(.F.)
			Endif
		Endif
	EndIf
Return lRet

/*/{Protheus.doc} xVldCxaPer
	Genera asiento contable integración caja chica.
	La función es llamada de LOCXNF, función NFVldCxa.
	@type  Function
	@author Arturo Samaniego
	@since 03/09/2022
	@param 	lUsaFlag: Flag de contabilización (MV_CTBFLAG).
			nRecSEU: Número de registro de SEU a contabilizar.
			cUsuario: Código de Usuario
			cFunName: Nombre de función.
			lCtbOnLin: Indica si la contabilidad es on-line (.T.).
			lVisual572: Indica si visualiza los asientos contables.
	@return Nil
	/*/
Function xVldCxaPer(lUsaFlag, nRecSEU, cUsuario, cFunName, lCtbOnLin, lVisual572)
Local nTotal := 0
Local aTmpSEU       := {}
Local aDiario		:= {}
Local aFlagCTB		:= {}
Local cArquivo		:= ""
Local lPad572		:= VerPadrao("572")

Private nHdlPrv   	:= 0	//Guarda a evolucao da funcao HeadProva
Private cLote		:= ""  	//Lote utilizado nas rotinas contabeis

Default lUsaFlag   := SuperGetMV("MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Default nRecSEU    := 0
Default cUsuario   := ""
Default cFunName   := Funname()
Default lCtbOnLin  := .F.
Default lVisual572 := .T.

	If lPad572 .And. nRecSEU <> 0 .And. lCtbOnLin
		nTotal	:= 0
		aTmpSEU := SEU->(GetArea())
		SEU->(DBGoTo(nRecSEU))
		If UsaSeqCor()
			AADD(aDiario,{"SEU",nRecSEU,SEU->EU_DIACTB,"EU_NODIA","EU_DIACTB"})
		EndIf
		If nHdlPrv <= 0
			LoteCont("FIN")
			//Inicializa lanzamiento contable
			nHdlPrv := HeadProva( cLote, cFunName /*cPrograma*/, Substr( cUsuario, 7, 6 ), @cArquivo)
		EndIf
		If  nHdlPrv > 0 .And. Empty(SEU->EU_LA)
			//Prepara lanzamiento contable
				If lUsaFlag  //Almacenar en aFlagCTB para actualizar en el módulo de Contabilidad
					aAdd( aFlagCTB, {"EU_LA", "S", "SEU", SEU->( Recno() ), 0, 0, 0} )
				EndIf
				nTotal += DetProva( nHdlPrv			, "572" /*cPadrao*/	, cFunName /*cPrograma*/, cLote			,;
									/*nLinha*/		, /*lExecuta*/		, /*cCriterio*/			, /*lRateio*/	,;
									/*cChaveBusca*/	, /*aCT5*/			, /*lPosiciona*/		, @aFlagCTB		,;
									/*aTabRecOri*/	, /*aDadosProva*/ )
		EndIf

		If nHdlPrv > 0 .And. nTotal > 0
			//Realiza lanzamiento de Asto Contable
				RodaProva(nHdlPrv, nTotal)
				If cA100Incl( cArquivo						, nHdlPrv			, 3 /*nOpcx*/		, cLote		,;
							lVisual572 /*Visualiza*/	, .F. /*lAglut*/	, /*cOnLine*/		, /*dData*/	,;
							/*dReproc*/						, @aFlagCTB			, /*aDadosProva*/	, aDiario )
						If !lUsaflag
							Reclock("SEU",.F.)
							Replace EU_LA	With "S"
							MsUnLock()
						EndIf
						//Grava los lanzamientos de SIGAPCO
						PcoDetLan("000359","02",cFunName)
				EndIf
				// nHdlPrv := 0
				// nTotal	:= 0
				aFlagCTB:= {}  // Limpia contenido despues de realizar lanzamiento contable
		EndIf
		Restarea(aTmpSEU)
	EndIf

Return

/*/{Protheus.doc} LxDelCCPer
	Función para revertir los asientos contable de caja chica.
	La función es llamada en LOCXNF, función LocXDelCC.
	@type  Function
	@author Arturo Samaniego
	@since 03/09/2022
	@param 	lUsaFlag: Flag de contabilización (MV_CTBFLAG).
			lVisual579: Indica si visualiza los asientos contables (.T.).
			cFunName: Nombre de función
			cUsuario: Código de usuario.
	@return Nil
	/*/
Function LxDelCCPer(lUsaFlag, lVisual579, cFunName, cUsuario)
Local lPad579	:= VerPadrao("579")
Local aFlagCTB	:= {}
Local aCtbDia	:= {}
Local nTotal	:= 0
Local cArquivo	:= ""

Private nHdlPrv := 0
Private cLote	:= ""

Default lUsaFlag   := SuperGetMV("MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Default lVisual579 := .T.
Default cFunName   := Funname()
Default cUsuario   := ""

	If lPad579 .And. !Empty(SEU->EU_LA)
		If lUsaFlag
			aAdd(aFlagCTB, {"EU_LA", "S", "SEU", SEU->(Recno()), 0, 0, 0})
		EndIf
		If Empty(nHdlPrv) .Or. nHdlPrv <= 0
			LoteCont("FIN")
			nHdlPrv := HeadProva(cLote,cFunName,Subs(cUsuario,7,6),@cArquivo)
		EndIf
		If nHdlPrv > 0
			nTotal	+=	DetProva(nHdlPrv,"579",cFunName,cLote)
		EndIf
		RodaProva(nHdlPrv,nTotal)
		If nTotal > 0
			If UsaSeqCor()
				aCtbDia := {{"SEU",SEU->(Recno()),SEU->EU_DIACTB,"EU_NODIA","EU_DIACTB"}}
			EndIf
			If cA100Incl(	cArquivo						, nHdlPrv			, 3				, cLote		,;
							lVisual579 /*Visualiza*/	, .F./*Aglutina*/	,/*cOnLine*/	, /*dData*/	,;
							/*dReproc*/						, @aFlagCTB			,/*aDadosProva*/, aCtbDia)
					If !lUsaflag
						Reclock("SEU",.F.)
						SEU->EU_LA := "S"
						MsUnLock()
					EndIf
			EndIf
		EndIf
		nHdlPrv := 0
		nTotal := 0
		aFlagCTB := {}
	EndIf

Return

/*/{Protheus.doc} VencImpPer
	Función para obtener fecha de vencimiento de título de impuesto.
	La función es llamada en LOCXNF, función LocVencImp.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	dDatabase: Fecha base del sistema
			aTitPai: Array con información de títulos.
	@return dVencto: Fecha de vencimiento.
	/*/
Function VencImpPer(dDatabase, aTitPai)
Local dVencto := CTOD("//")

	If dDatabase == aTitPai[1][9]
		dVencto := aTitPai[1][9]
	ElseIf dDatabase < aTitPai[1][9]
		If (Month(dDatabase) == Month(aTitPai[1][9]))
			dVencto := aTitPai[1][9]-1
		Else
			If (aTitPai[1][9] > RetDiaUtil(Str(Month(dDatabase)),Str(Year(dDatabase))))
				dVencto := RetDiaUtil(Str(Month(dDatabase)),Str(Year(dDatabase)))
			Else
				dVencto := aTitPai[1][9]-1
			EndIf
		EndIF
	EndIf

Return dVencto


/*/{Protheus.doc} LxVdImpPer
	Función para validación de impuesto - Perú.
	La función es llamada en LOCXNF2, función ValImpPer.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	nLinha: Número de linea de ítems.
			aItens: Array de ítems
			clImp: Código de impuesto
			cFunName: Nombre de función.
	@return lRet. .T. si cumple con las condiciones.
	/*/
Function LxVdImpPer(nLinha, aItens, clImp, cFunName)
Local nlI     := 0
Local nlAliq  := 0
Local alAreaX := {}
Local lRet    := .T.
Local cFilSB1	:= xFilial("SB1")
Local cFilSFB	:= xFilial("SFB")
Local cFilSFC	:= xFilial("SFC")
Local cFilSYD	:= xFilial("SYD")

Default nLinha := 0
Default aItens := {}
Default clImp  := ""
Default cFunName := Funname()

	If cFunName $ "MATA465N/MATA466N/MATA467N/MATA101N" .Or. (lChkLxProp .and. ChkLxProp("ValidaImpuestoPER"))

		alAreaX := GetArea()

		If !aItens[nLinha,3]

			dbSelectArea("SFC")
			dbSetOrder(2)
			If SFC->(MsSeek(cFilSFC+aItens[nLinha,2]+clImp))

				dbSelectArea("SB1")
				dbSetOrder(1)
				SB1->(MsSeek(cFilSB1+aItens[nLinha,1]))

				If !Empty(SB1->B1_POSIPI)
					dbSelectArea("SYD")
					dbSetOrder(1)
					If SYD->(MsSeek(cFilSYD+SB1->B1_POSIPI))
						If clImp == "DIG"
							nlAliq := SYD->YD_ALQDIG
						Else
							nlAliq := SYD->YD_ALQPIV
						EndIf
					EndIf
				ElseIf !Empty(SB1->B1_ALQPIGV) .And. !Empty(SB1->B1_ALQPDIG)
					If clImp == "DIG"
						nlAliq := SB1->B1_ALQPDIG
					Else
						nlAliq := SB1->B1_ALQPIGV
					EndIf
				Else
					If SFB->(MsSeek(cFilSFB+clImp))
						nlAliq := SFB->FB_ALIQ
					EndIf
				EndIf

				SB1->(dbCloseArea())
				SYD->(dbCloseArea())

				For nlI := 1 To Len(aItens)
					If nlI <> nLinha .And. !aItens[nlI,3]
						SFC->(dbGoTop())
						If SFC->(MsSeek(cFilSFC+aItens[nlI,2]+clImp))

							dbSelectArea("SB1")
							dbSetOrder(1)
							SB1->(MsSeek(cFilSB1+aItens[nlI,1]))

							If !Empty(SB1->B1_POSIPI)
								dbSelectArea("SYD")
								dbSetOrder(1)
								If SYD->(MsSeek(cFilSYD+SB1->B1_POSIPI))
									If clImp == "DIG"
										If nlAliq <> SYD->YD_ALQDIG
											lRet := .F.
											Exit
										EndIf
									Else
										If nlAliq <> SYD->YD_ALQPIV
											lRet := .F.
											Exit
										EndIf
									EndIf
								EndIf
							ElseIf !Empty(SB1->B1_ALQPIGV) .And. !Empty(SB1->B1_ALQPDIG)
								If clImp == "DIG"
									If nlAliq <> SB1->B1_ALQPDIG
										lRet := .F.
										Exit
									EndIf
								Else
									If nlAliq <> SB1->B1_ALQPIGV
										lRet := .F.
										Exit
									EndIf
								EndIf
							Else
								If SFB->(MsSeek(cFilSFB+clImp))
									If nlAliq <> SFB->FB_ALIQ
										lRet := .F.
										Exit
									EndIf
								EndIf
							EndIf

							SB1->(dbCloseArea())
							SYD->(dbCloseArea())

						Else
							If !Empty(aItens[nlI,2])
								lRet := .F.
								Exit
							EndiF
						EndIf
					EndIf
				Next nlI

			Else

				For nlI := 1 To Len(aItens)
					If nlI <> nLinha .And. !aItens[nlI,3]
						SFC->(dbGoTop())
						If SFC->(msSeek(cFilSFC+aItens[nlI,2]+clImp))
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nlI

			EndIf

			If !lRet
				If clImp == "DIG"
			   		Aviso(STR0019,STR0034,{STR0020})
				Else
					Aviso(STR0019,STR0035,{STR0020})
				EndIf
			EndIf

			SFC->(dbCloseArea())

		EndIf

   		RestArea(alAreaX)
   	EndIf

Return lRet

/*/{Protheus.doc} LxdUtilPer
	Obtiene el 5° día util del mes.
	La función es llamada en LOCXNF2, función RetDiaUtil.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	cMes: Número de mes.
			cAno: Número de año.
	@return dRetData: Fecha de referencia.
	/*/
Function LxdUtilPer(cMes, cAno)
Local nDia      := 1
Local nUtil     := 0
Local dRetData  := CTOD("//")
Local aFeriados := {}
Local dData     := CTOD("//")

	If Alltrim(cMes) == "12"
		cMes := "1"
		cAno := Str(Val(cAno)+1)
	Else
		cMes :=	Str(Val(cMes)+1)
	EndIF

	aFeriados := RetFeriados()

	While nUtil < 5
		dData:=CTOD((Str(nDia))+"/"+cMes+"/"+cAno)
		If ( dData == DataValida(dData)  .And. Ascan(aFeriados,Dtos(dData)) == 0    )
			dRetData := CTOD((Str(nDia))+"/"+cMes+"/"+cAno)
			nUtil++
		EndIf
		nDia++
	EndDo

Return dRetData


/*/{Protheus.doc} xNfOrigPer
	Función para validar si existe documento origen.
	La función es llamada en LOCXNF2, función VldNFOrig.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	cTipo: Tipo de documento
			nI: Número de ítem.
			aDadosI: Array con ítems.
			nPosNFOri: Posición del campo NfOrig.
			nPosSerOri: Posición del campo SerOrig.
	@return lRet: .T. si cumple con las condiciones.
	/*/
Function xNfOrigPer(cTipo,nI,aDadosI,nPosNFOri,nPosSerOri)
Local nZ	:= 0
Local lRet	:= .T.

Default cTipo      := ""
Default nI         := 0
Default aDadosI    := {}
Default nPosNFOri  := 0
Default nPosSerOri := 0

	If !Empty(aDadosI[nI][nPosNFOri]) .And. Strzero(cTipo,2)$"02|03|04|05|06|07|08|09"
		For nZ:=1 To Len(aDadosI)
			If !aDadosI[nZ][Len(aDadosI[nZ])]
				If !Empty(aDadosI[nZ][nPosNFOri]) .And. !aDadosI[nZ][nPosNFOri]+aDadosI[nZ][nPosSerOri] == aDadosI[nI][nPosNFOri]+aDadosI[nI][nPosSerOri]
					Aviso(STR0019,STR0036+" ("+aDadosI[nZ][nPosNFOri]+" "+aDadosI[nZ][nPosSerOri]+")",{STR0020})
					lRet := .F.
				EndIf
			EndIf
		Next
	EndIf

Return lRet


/*/{Protheus.doc} VdDocItPer
	Valida documento informado en D2_NFORI/D1_NFORI con serie en D2_SERIORI/D1_SERIORI para NDC/NCC.
	La función es llamada en LOCXNF2, función LxVldDocIt.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	cNumeroDoc: Número de documento.
			cSerie: Serie del documento.
			cEspecie: Especie del documento.
			lM485PE: Valor del Punto de Entrada M465DORIFE. Default .T.
	@return lRet: .T. si cumple con las validaciones.
	/*/
Function VdDocItPer(cNumeroDoc, cSerie, cEspecie, lM485PE)
Local lRet	   := .T.
Local aArea	   := {}
Local cCpoSerO := ""
Local cCpoDocO := ""
Local cCliForE := ""
Local cLojaE   := ""

Default cNumeroDoc	:= ""
Default cSerie		:= ""
Default cEspecie	:= ""
Default lM485PE     := .T.

	cCpoSerO := IIf(cEspecie=="NDC","D2_SERIORI","D1_SERIORI")
	cCpoDocO := IIf(cEspecie=="NDC","D2_NFORI","D1_NFORI")
	cCliForE := IIf(cEspecie=="NDC",M->F2_CLIENTE,M->F1_FORNECE)
	cLojaE   := IIf(cEspecie=="NDC",M->F2_LOJA,M->F1_LOJA)

	aArea := GetArea()

	If lM485PE
		If !Empty(cNumeroDoc) .And. !Empty(cSerie)
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If !(SF2->(MsSeek(xFilial("SF2") + cNumeroDoc + cSerie + cCliForE + cLojaE)))
				MsgAlert(STR0037 + AllTrim(cSerie) + "-" + AllTrim(cNumeroDoc) + StrTran(STR0038, '###', AllTrim(cCliForE) + "-" + AllTrim(cLojaE))) //"El documento original informado en el detalle (" //"), no existe para el cliente ###. Informe otro e intente nuevamente."
				lRet := .F.
			EndIf
		Else
			MsgAlert(STR0039 + RTrim(FWX3Titulo(cCpoDocO)) + "(" + cCpoDocO + ") " + STR0040 + RTrim(FWX3Titulo(cCpoSerO)) + "(" + cCpoDocO + ") " + STR0041) //"Los campos " - " y " - ", deben ser informados en el detalle."
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} xUpdImpPer
	Actualiza valor de campos de SE2, para títulos de impuestos.
	La función es llamada en LOCXNF, función GeraTitImp.
	@type  Function
	@author Arturo Samaniego
	@since 04/09/2022
	@param 	nRecSE2: Número de registro de SE2.
			aRet: Array con valores de SE2.
			cCpoLvro: Campo de libro fiscal de impuesto.
			cParcela: Número de parcela.
	@return Nil
	/*/
Function xUpdImpPer(nRecSE2, aRet, cCpoLvro, cParcela)
Local nX := 0

Default nRecSE2  := 0
Default aRet     := {}
Default cCpoLvro := ""
Default cParcela := ""

	For nX :=1 to Len(aRet[1])
		SE2->(MsGoto(aRet[1][nX]))
		RecLock("SE2",.F.)
			Replace &("E2_PARIMP"+cCpoLvro) with cParcela
		MsUnlock()
	Next
	SE2->(MsGoto(nRecSE2))

Return

/*/{Protheus.doc} LxVldGRem
Validaciones para guardado de Guias de Rmisión
@type function
@author veronica.flores
@since 06/07/2023
@version 1.0
@param
@return lRet, boolean, Valor lógico que retorna .F.
        si hay algún problema, caso contrario retorna .T.
/*/
Function LxVldGRem()
	Local lRet			:= .T.
	Local cCRLF			:= (chr(13) + chr(10))
	Local cErrGR		:= ""
	Local cModTras		:= ""
	Local cFilSA4		:= xFilial("SA4")
	Local cCampo 		:= ""
	Local cMsg          := STR0042 //"Para guías de remisión electrónicas:"

	//Modalidad de traslado
	If Empty(M->F2_TRANSP)
		cCampo := FWX3Titulo("F2_TRANSP") + " (F2_TRANSP)"
		cErrGR += StrTran(STR0043, '###', cCampo) + cCRLF //"El campo ### es requerido, para definir si el transporte es público o privado."
	Else
		dbSelectArea("SA4")
		SA4->(dbSetOrder(1)) //A4_FILIAL + A4_COD
		If SA4->(dbSeek(cFilSA4 + M->F2_TRANSP))
			cModTras  := SA4->A4_TIPOTRA
		EndIf
		cCampo := FWX3Titulo("A4_TIPOTRA") + " (A4_TIPOTRA)"
		If Empty(cModTras)
			cErrGR += StrTran(STR0044, '###', cCampo) + cCRLF //"La Transportadora, no tiene definido si es transporte público o privado ###."

		ElseIf Alltrim(cModTras) == "02" //Trasporte privado
			If SF2->(ColumnPos("F2_VEICULO")) > 0 .And. Empty(M->F2_VEICULO)
				cErrGR += StrTran(STR0045 + FWX3Titulo("F2_VEICULO") + " (F2_VEICULO)", '###',cCampo) + cCRLF //"Para Transportadora de tipo privado ### , se debe informar el vehículo de transporte "
			EndIf
		EndIf

		//Peso Bruto
		If SF2->(ColumnPos("F2_PBRUTO")) > 0 .And. Empty(M->F2_PBRUTO)
			cCampo := FWX3Titulo("F2_PBRUTO") + " (F2_PBRUTO)"
			cErrGR += StrTran(STR0046, '###',cCampo) + cCRLF //"El peso bruto debe ser informado ###."
		EndIf

		//Cliente de entrega
		If SF2->(ColumnPos("F2_CLIENT")) > 0 .And. SF2->(ColumnPos("F2_LOJENT")) > 0  .And. (Empty(M->F2_CLIENT) .Or. Empty(M->F2_LOJENT))
			cCampo := FWX3Titulo("F2_CLIENT") + " (F2_CLIENT)"	+ FWX3Titulo("F2_LOJENT") + " (F2_LOJENT)"
			cErrGR += StrTran(STR0047, '###',cCampo) + cCRLF //"Cliente de entrega no existe o no ha sido informado ###."
		EndIf

		//Fecha de inicio de traslado
		If SF2->(ColumnPos("F2_FECDSE")) > 0  .And. Empty(M->F2_FECDSE)
			cCampo := FWX3Titulo("F2_FECDSE") + " (F2_FECDSE)"
			cErrGR += StrTran(STR0048, '###',cCampo) + cCRLF //"La fecha de inicio de traslado debe ser informada ###."
		EndIf

		//Motivo de traslado
		If Empty(M->F2_MODTRAD)
			cCampo := FWX3Titulo("F2_MODTRAD") + " (F2_MODTRAD)"
			cErrGR += StrTran(STR0049, '###',cCampo) + cCRLF //"El motivo de traslado debe ser informada ###."
		EndIf
	EndIf

	If !Empty(cErrGR)
		lRet := .F.
		MsgAlert(cMsg + cCRLF + cErrGR) //Mensaje de los campos que faltan indicar para las guias de remisión.
	EndIf

Return lRet

/*/{Protheus.doc} LxPerCliL
Llenado de campos F2_CLIENTE Y F2_LOJAENT
@type function
@author veronica.flores
@since 07/07/2023
@version 1.0
@param
@return cRet, caracter, Valor a indicar en el campo
/*/
Function LxPerCliL(cCampo)
Local cRet   	:= ""
Local cFunName	:= FunName()

Default cCampo := ""

If cFunName $"MATA462N" .And. (aCfgNf[1] == 50 .Or. aCfgNf[SnTipo] == 52) .And. SF2->(ColumnPos(cCampo)) > 0
	If !Empty(M->F2_CLIENTE) .AND. !Empty(M->F2_LOJA) .And. Empty(M->&cCampo)
		cRet := IIf(cCampo == "F2_CLIENT",M->F2_CLIENTE,IIf(cCampo == "F2_LOJENT",M->F2_LOJA,""))
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} LxAtuAtf
Grabado de campos N1_NODIA y N3_NODIA
@type function
@author oswaldo.diego
@since 20/09/2023
@version 1.0
@param aRecno,  arreglo, Arreglo con los registros RECNO de los ítems de la factura
@param aCtbDia, arreglo, Arreglo con los registros a grabar
@return

/*/
Function LxAtuAtf(aRecno, aCtbDia)
Local aAreaASD1 := SD1->(GetArea())
Local aAreaASF4 := SF4->(GetArea())
Local aAreaASN1 := SN1->(GetArea())
Local aAreaASN3 := SN3->(GetArea())
Local cFilSF4	:= xFilial("SF4")
Local cFilSN1	:= xFilial("SN1")
Local cFilSN3	:= xFilial("SN3")
Local nI        := 0

Default aRecno  := {}
Default aCtbDia := {}

SF4->(DbSetOrder(1)) /*F4_FILIAL+F4_CODIGO*/
SN1->(DbSetOrder(1)) /*N1_FILIAL+N1_CBASE+N1_ITEM*/
SN3->(DbSetOrder(1)) /*N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ*/

For nI := 1 to Len(aRecno)
	SD1->(MsGoTo(aRecno[nI,1]))
	SF4->(MsSeek(cFilSF4+SD1->D1_TES))
	If SF4->F4_ATUATF == 'S'
		SN1->(MsSeek(cFilSN1+SD1->D1_CBASEAF))
		SN3->(MsSeek(cFilSN3+SD1->D1_CBASEAF+'01'/*N3_TIPO*/+'0'/*N3_BAIXA*/+STRZERO(1,Len(SN3->N3_SEQ)))/*N3_SEQ*/)
		AAdd(aCtbDia, {"SN1",SN1->(RECNO()),SN1->N1_DIACTB,"N1_NODIA","N1_DIACTB"})
		AAdd(aCtbDia, {"SN3",SN3->(RECNO()),SN3->N3_DIACTB,"N3_NODIA","N3_DIACTB"})
	EndIf
Next nI

RestArea(aAreaASD1)
RestArea(aAreaASF4)
RestArea(aAreaASN1)
RestArea(aAreaASN3)

Return

/*/{Protheus.doc} LxPerTpDIG
Verifia si el impuesto es de tipo detracción.
Se utiliza en la rutina MATXFIS dentro de las funciones MafiscalcIV(), MafisAliqIV() y MafisVlIV()
@type function
@author alfredo.medrano
@since 20/09/2023
@version 1.0
@param cImpS, carácter, Impuesto.
@return
/*/
Function LxPerTpDIG(cImpS)
	Local aArea 	:= GetArea()
	Local lRet 		:= .F.

	dbSelectArea("SFB")
	SFB->(DbSetOrder(1)) //FB_FILIAL + FB_CODIGO

	If SFB->(MsSeek(xFilial("SFB")+cImpS))
		lRet := IIF(SFB->FB_CLASSE == "D", .T.,.F.)
	Endif

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} LxPerNFREF
Abre una pantalla de selección con los documentos de tipo NF relacionados al
cliente y tienda y retorna el número de documento y serie del documento seleccionado
llenando los campos F2_NFREF y F2_SERREF.
Se ejecuta a partir de la consulta especfica SF2DRF uilizada en el campo F2_NFREF.
@type  Function
@author alfredo.medrano
@since 14/12/2023
@version 1
@param N/A
@return F2_DOC, F2_SERIE
@example
(examples)
@see (links_or_references)
/*/
Function LxPerNFREF()

	Local aArea 	:= GetArea()
	Local cAliasQry := GetNextAlias()
	Local cEspS		:= Padr('NF', TamSx3("F2_ESPECIE")[1], " ")
	Local cClientS  := M->F2_CLIENTE
	Local cLojaS    := M->F2_LOJA
	Local aCordW	:= {125,0,450,635}
	Local aCGD		:= {44,5,90,315}
	Local nX 		:= 0
	Local nJ 		:= 0
	Local nUsado 	:= 0
	Local nPosCols 	:= 0
	Local aCombo 	:= {}
	Local aMyCombo 	:= {}
	Local cCombo 	:= ""
	Local cBusca 	:= space(TamSx3('F2_DOC')[1])
	Local cLine		:= ""
	Local aHeadS	:= {}
	Local aHeader	:= {}
	Local aCols		:= {}
	Local bLine 	:= Nil
	Local lOk 		:= .F.
	Local nTotREg 	:= 0
	Local cTitDoc 	:= ""
	Local cTitSer 	:= ""
	Local cTitFech 	:= ""
	Local cTitCliS 	:= ""
	Local cTitLojS	:= ""
	Local cVBPict 	:= ""

	Local oCombo 	:= Nil
	Local oBusca 	:= Nil
	Local oBtn1 	:= Nil
	Local oDlg 		:= Nil
	Local oListBox 	:= Nil
	Local oCliOrg 	:= Nil
	Local oLojOrg 	:= Nil

	cTitCliS:= Alltrim(FwX3Titulo("F2_CLIENTE"))
	cTitLojS:= Alltrim(FwX3Titulo("F2_LOJA"))
	If !Empty(cClientS) .and. !Empty(cLojaS)

		BeginSql Alias cAliasQry
			SELECT F2_DOC, F2_CLIENTE,F2_LOJA,F2_SERIE,F2_ESPECIE,F2_EMISSAO,F2_COND,F2_VALBRUT
			FROM
				%table:SF2% SF2
			WHERE
				SF2.F2_FILIAL= %xfilial:SF2% AND
				SF2.F2_CLIENTE = %exp:cClientS% AND
				SF2.F2_LOJA = %exp:cLojaS% AND
				SF2.F2_ESPECIE = %exp:cEspS% AND
				SF2.%notDel%
			ORDER BY F2_DOC, F2_SERIE
		EndSql

		TCSetField(cAliasQry,"F2_EMISSAO","D")
		TCSetField(cAliasQry,"F2_VALBRUT","N", GetSx3Cache("F2_VALBRUT","X3_TAMANHO"),GetSx3Cache("F2_VALBRUT","X3_DECIMAL"))
		Count to nTotREg

		If nTotREg > 0

			cTitDoc	:= Alltrim(FwX3Titulo("F2_DOC"))
			cTitSer := Alltrim(FwX3Titulo("F2_SERIE"))
			cTitFech:= Alltrim(FwX3Titulo("F2_EMISSAO"))
			cVBPict := GetSx3Cache( "F2_VALBRUT", "X3_PICTURE" )
			//Arreglo con los campos que conforman el browse
			aadd(aHeader,{'F2_DOC','F2_SERIE','F2_ESPECIE','F2_EMISSAO','F2_COND','F2_VALBRUT'})
			//Arreglo con los campos que serán mostrados en el combo de busqueda
			aadd(aCombo,cTitDoc)
			aadd(aCombo,cTitSer)
			aadd(aCombo,cTitFech)
			//Arreglo con los campos que serán utilizados para las búsquedas
			aadd(aMyCombo, {cTitDoc,'F2_DOC'} )
			aadd(aMyCombo, {cTitSer,'F2_SERIE'} )
			aadd(aMyCombo, {cTitFech,'F2_EMISSAO'} )
			//aHeadS  -  Arreglo que contiene el título de los campos y seran mostrados en el encabezado
			For nX :=1 to  len(aHeader[1])
				If X3Usado(aHeader[1][nX])
					nUsado++
					AAdd(aHeadS, FwX3Titulo(aHeader[1][nX])) //Título
				Endif
			Next
			(cAliasQry)->(dbGoTop())
			While (cAliasQry)->(!Eof())
				nPosCols++
				AAdd(aCols, Array(nUsado))
				For nJ := 1 To Len(aHeader[1])
					If aHeader[1][nj] == "F2_VALBRUT"
						aCols[nPosCols][nJ] := AllTrim(Transform((cAliasQry)->&(aHeader[1][nj]),cVBPict))
					Else
						aCols[nPosCols][nJ] :=  (cAliasQry)->&(aHeader[1][nj])
					Endif
				Next nJ
				(cAliasQry)->(dbSkip())
			EndDo

			cLine := "{"
			For nX:=1 To nUsado
				cLine += "aCols[oListBox:nAt][" + AllTrim(Str(nX)) + "]"
				If nX < nUsado
					cLine += ","
				EndIf
			Next
			cLine += "}"
			bLine := &( "{|| " + cLine + "}" )

			DEFINE MSDIALOG oDlg TITLE STR0050 FROM aCordW[1],aCordW[2] TO aCordW[3],aCordW[4] PIXEL OF oMainWnd //"Documento de Referencia"

				@ 009,005 SAY cTitCliS + " :" SIZE 35,07 OF oDlg PIXEL // 'Cliente'
				@ 005,045 MSGET oCliOrg VAR cClientS SIZE 50,10 WHEN .f. OF oDlg PIXEL
				@ 009,110 SAY cTitLojS  + " :" SIZE 35,07 OF oDlg PIXEL // 'Tienda'
				@ 005,140 MSGET oLojOrg VAR cLojaS SIZE 30,10 WHEN .f. OF oDlg PIXEL

				@ 029,005 SAY STR0051 SIZE 35,07 OF oDlg PIXEL // 'Buscar por:'
				@ 025,045 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 080,013 OF oDlg PIXEL //ON CHANGE ( lxPerFomRf(@cBusca,aMyCombo,cCombo) )
				oCombo:bChange := {||lxPerFomRf(@cBusca,aMyCombo,cCombo) }
				@ 025,130 MSGET oBusca VAR cBusca PICTURE "@!"  SIZE 80,10 OF oDlg PIXEL
				@ 043,420 BTNBMP oBtn1 RESOURCE "btpesq" SIZE 025,025 OF oDlg PIXEL ACTION ( lxPerBsRef(cBusca, cCombo, aMyCombo,aHeader, aCols, oListBox ) )

				oListBox := TWBrowse():New(aCGD[1],aCGD[2],aCGD[4],aCGD[3],,aHeadS,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
				oListBox:SetArray(aCols)
				oListBox:bLDblClick := { || }
				oListBox:bLine      := bLine

				DEFINE SBUTTON FROM aCGD[3]+55,aCGD[4]-60 TYPE 1 ENABLE OF oDlg ACTION (lOk:=lxPerActRf(aHeader,aCols, oListBox:nAt ),oDlg:End())
				DEFINE SBUTTON FROM aCGD[3]+55,aCGD[4]-30 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())
				ACTIVATE MSDIALOG oDlg CENTERED
		Else
			HELP("   ",1,"LXPERREFA",,STR0052 + " ( " + cTitCliS + " / "  + cTitLojS +")" ,1) // "No hay registros relacionados a la informacion seleccionada"
		EndIf
		(cAliasQry)->(dbCloseArea())
	Else
		HELP("   ",1,"LXPERREFC",,STR0053 + cTitCliS + " y " + cTitLojS  ,1) //"Informe los campos "
	EndIf
	RestArea(aArea)

Return lOk

/*/{Protheus.doc} lxPerActRf
Asigna el número de documento(F2_DOC) y serie (F2_SERIE) del documento seleccionado
a los campos de memoria M->F2_NFREF y M->F2_SERREF.
@type  Function
@author alfredo.medrano
@since 15/12/2023
@version 1
@param aHeader, array, campos utilizados por la lista de selección
@param aCols ,  array, columnas con información de los campos utilizados por la lista de selección
@param nNatS ,  número, posición de la línea seleccionada en la lista.
@return lRet, lógico
@example
(examples)
@see (links_or_references)
/*/
static Function lxPerActRf(aHeader,aColsD, nNatS )
	Local nPosDoc	:= 0
	Local nPosSer	:= 0
	Local lRet 		:=.F.
	Default aHeader := {}
	Default aColsD  := {}
	Default nNatS	:= 0

	nPosDoc	:= AScan(aHeader[1], { |x| AllTrim(x) == 'F2_DOC' })
	nPosSer	:= AScan(aHeader[1], { |x| AllTrim(x) == 'F2_SERIE' })
	If nPosDoc > 0 .and. nPosSer > 0
		M->F2_NFREF := aColsD[nNatS,nPosDoc]
		M->F2_SERREF := aColsD[nNatS,nPosSer]
		lRet:= .T.
	EndIf

Return lRet

/*/{Protheus.doc} lxPerFomRf
Inicializa el tamaño (número de carácter permitidos) del campo de búsqueda
dependiendo la opción de búsqueda seleccionada.
@type  Function
@author alfredo.medrano
@since 15/12/2023
@version 1
@param cBusca,    carácter, información a buscar
@param aMyCombo,  array   , Arreglo con los campos que serán utilizados para las búsquedas
@param cCombo ,   carácter, opción seleccionada en el combo de busqueda
@return lRet, lógico
@example
(examples)
@see (links_or_references)
/*/
Static function lxPerFomRf(cBusca,aMyCombo,cCombo)
	Local nCmbLin	:= 0
	Local lRet 		:=.F.
	Default cBusca	:= ""
	Default aMyCombo:= {}
	Default cCombo	:= ""

	nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )

	If nCmbLin > 0
		If aMyCombo[nCmbLin,02] == 'F2_EMISSAO'
			cBusca:=space(10)
		Else
			cBusca:=space(TamSx3(aMyCombo[nCmbLin,02])[1])
		EndIf
		lRet:=.T.
	EndIf

Return lRet


/*/{Protheus.doc} lxPerBsRef
Realiza la búsqueda a partir de la opción seleccionada en el combo y en el texto asignado.
@type  Function
@author alfredo.medrano
@since 15/12/2023
@version 1
@param cBusca,	carácter, Información a buscar
@param cCombo,	carácter, Opción seleccionada en el combo de busqueda
@param aMyCombo,array,	  Arreglo con los campos que serán utilizados para las búsquedas
@param aHeader,	array,	  Campos utilizados por la lista de selección
@param aCols,	array,	  Columnas con información de los campos utilizados por la lista de selección
@param oListBox,objeto,	  Objeto de la lista de selección
@return lRet, lógico
@example
(examples)
@see (links_or_references)
/*/
Static Function lxPerBsRef(cBusca, cCombo, aMyCombo,aHeader, aCols, oListBox )
Local nPosLin 	:= 0
Local nPosCpo 	:= 0
Local nLenCmb 	:= 0
Local nCmbLin 	:= 0
Local lRet	  	:=.F.
Default cBusca	:= ""
Default cCombo	:= ""
Default aMyCombo:= {}
Default aHeader	:= {}
Default aCols	:= {}
Default oListBox:= Nil

	nLenCmb := Len(Alltrim(cBusca))
	nCmbLin := aScan( aMyCombo, { |x| Alltrim(x[01]) == Alltrim(cCombo)} )

	If nCmbLin > 0
		nPosCpo := AScan(aHeader[1], { |x| AllTrim(x) == aMyCombo[nCmbLin,02] })
		If nPosCpo > 0
			If aMyCombo[nCmbLin,02] == 'F2_EMISSAO'
				nPosLin := aScan( aCols, { |x| Dtoc(x[nPosCpo]) == cBusca} )
			Else
				nPosLin := aScan( aCols, { |x| SubStr(Alltrim(UPPER(x[nPosCpo])),1,nLenCmb) == Alltrim(cBusca)} )
			EndIf
		EndIf
	EndIf
	If nPosLin >= 1
		oListBox:nAt := nPosLin
		lRet:= .T.
	Else
		MSGINFO( STR0052, STR0001 ) // "No se encontró información relacionada a los criterios de búsqueda." // "Atención"
	EndIf
	oListBox:Refresh()

Return lRet

/*/{Protheus.doc} MA468BjaAnt
	Baja de valores de titulo de anticipo en factura automática
	Con base a xBaixaAdt(), se ejecuta desde MATA468N->a468nGravF2()
	@type  Function
	@author ARodriguez
	@since 16/01/2024
	@version 1.0
	@param Ninguno
	@return Nil
	/*/
Function M468BjaAnt()
Local aRegSE1		:= {}
Local aCaixaFin		:= {}
Local cHist			:= ""
Local cFunOrig		:= FunName()
Local aBaixa		:= {}
Local nRecSE		:= 0
Local nRec			:= 1
Local aArea			:= GetArea()
local nX			:= 0

aRegSE1 := FPedAdtPed( "R", {SD2->D2_PEDIDO}, .F. )
aCaixaFin := xCxFina()	// Caixa Geral do Financeiro
cHist := "ANT: " + SF2->F2_DOC + " " + SF2->F2_SERIE + " " + SD2->D2_ITEM

DbSelectArea("SE1")
nRecSE := SE1->(Recno())
SE1->(DbGoto(aRegSE1[nRec][2]))
For nX := 1 to len(aRegSE1)
	SE1->(DbGoto(aRegSE1[nX][2]))
	AADD(aBaixa,{"E1_PREFIXO"	, SE1->E1_PREFIXO	, Nil})	// 01
	AADD(aBaixa,{"E1_NUM"		, SE1->E1_NUM		, Nil})	// 02
	AADD(aBaixa,{"E1_PARCELA"	, SE1->E1_PARCELA	, Nil})	// 03
	AADD(aBaixa,{"E1_TIPO"		, SE1->E1_TIPO		, Nil})	// 04
	AADD(aBaixa,{"E1_MOEDA"		, SE1->E1_MOEDA		, Nil})	// 05
	AADD(aBaixa,{"E1_TXMOEDA"	, SE1->E1_TXMOEDA	, Nil})	// 06
	AADD(aBaixa,{"E1_ORIGEM"	, cFunOrig			, Nil})	// 07
	AADD(aBaixa,{"AUTVALREC"	, aRegSE1[nX][3]	, Nil})	// 06
	AADD(aBaixa,{"AUTMOTBX"		, "NOR"				, Nil})	// 07
	AADD(aBaixa,{"AUTDTBAIXA"	, dDataBase			, Nil})	// 08
	AADD(aBaixa,{"AUTDTCREDITO"	, dDataBase			, Nil})	// 09
	AADD(aBaixa,{"AUTHIST"		, cHist				, Nil})	// 10
	AADD(aBaixa,{"AUTBANCO"		, aCaixaFin[1]		, Nil})	// 11
	AADD(aBaixa,{"AUTAGENCIA"	, aCaixaFin[2]		, Nil})	// 12
	AADD(aBaixa,{"AUTCONTA"		, aCaixaFin[3]		, Nil})	// 13
	MSExecAuto({|x,y| FINA070(x,y)},aBaixa,3)
	aBaixa:={}
Next nX
SE1->(DbGoto(nRecSE))
RestArea(aArea)

Return

/*/{Protheus.doc} LxPerSer2
	Función para Perú que asigna el valor al campo F2_SERIE2 conforme al control de formularios
	@type  Function
	@author eduardo.manriquez
	@since 18/12/2024
	@version 1.0
	@param 
	@return .T., Lógico, retorna .T. para continuar con las validaciones
	@example
	LxPerSer2()
	@see
	/*/
Function LxPerSer2()
	Local aArea    := GetArea()
	Local cVarAct:= readvar()
	Local cOp := ""

	If FunName() $ 'MATA462N' .and. AllTrim(M->F2_ESPECIE) == "RFB"
		cOp := "7"
		SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
		If ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //factura de Venta
			IF SFP->(MSSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+cOp))
				M->F2_SERIE2:= SFP->FP_SERIE2
			ELSE
				M->F2_SERIE2:= ''
			ENDIF
		Endif
	EndIf	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} VCtrlFolio
Valida si la serie está registrada en la tabla SFP y si es un registro valido.
@type function
@version 12.1.2410
@author luis.samaniego
@since 6/12/2025
@param cEspecie, character, Especie del documento (NF, NCC, NCI, etc).
@param cSerie, character, Serie del documento.
@param cNumFolio, character, Número de documento.
@return lRet, logical, Indica si la serie está registrada en SFP y es valida.
/*/
Function VCtrlFolio(cEspecie, cSerie, cNumFolio)
Local aArea      := {}
Local cActivo    := ""
Local cCombo     := ""
Local cFilSFP    := xFilial("SFP")
Local cFilUso    := ""
Local cFPEspecie := ""
Local cMsgErr    := STR0057 //"Serie no registrada en control de formularios."
Local cMsgSol    := STR0058 //"Seleccione una serie registrada en el control de formularios."
Local cNumFin    := ""
Local cNumIni    := ""
Local dDTAval    := CTOD("\\")
Local lRet       := .F.
Local nPosIni    := 0

Default cEspecie := ""
Default cSerie   := ""
Default cNumFolio := ""

	If ValType(cFilAnt) == "C"
		cFilUso := cFilAnt
	EndIf

	cCombo := AllTrim(GetSx3Cache("FP_ESPECIE", "X3_CBOX"))
	nPosIni := At(AllTrim(cEspecie), cCombo)
	cFPEspecie := Substr(cCombo, nPosIni-2 , 1)

	aArea := GetArea()
	dbSelectArea("SFP")
	dbSetOrder(5) //FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE+FP_PV
	If SFP->(MsSeek(cFilSFP + cFilUso + cSerie + cFPEspecie))
		While SFP->(FP_FILIAL + FP_FILUSO + FP_SERIE + FP_ESPECIE) == (cFilSFP + cFilUso + cSerie + cFPEspecie)
			cNumIni := SFP->FP_NUMINI
			cNumFin := SFP->FP_NUMFIM
			cActivo := SFP->FP_ATIVO
			dDTAval := SFP->FP_DTAVAL
			lRet := .T.
			If cActivo == "1"
				Exit
			EndIf
			SFP->(dbSkip())
		EndDo
	EndIf
	RestArea(aArea)

	If lRet
		If (lRet) .And. (cActivo == "2")
			cMsgErr := STR0059 //"Este folio no está activo en el control de formularios."
			cMsgSol := StrTran(STR0060, '#####', Alltrim(FWX3Titulo("FP_ATIVO"))) //"Actualice el campo ##### o incluya un nuevo registro valido."
			lRet := .F.
		EndIf
		If (lRet .And. !Empty(dDTAval)) .And. (dDataBase > dDTAval)
			cMsgErr := STR0061 //"Este folio tiene la fecha de validez vencida."
			cMsgSol := StrTran(STR0060, '#####', Alltrim(FWX3Titulo("FP_DTAVAL"))) //"Actualice el campo ##### o incluya un nuevo registro valido."
			lRet := .F.
		EndIf
		If (lRet .And. !Empty(cNumFolio)) .And. (Val(cNumFolio) < Val(cNumIni) .Or. Val(cNumFolio) > Val(cNumFin))
			cMsgErr := STR0062 //"Este folio no pertenece al intervalo de la serie."
			cMsgSol := STR0063 //"Actualice el número de documento."
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		Help(" ", 1, STR0064, , cMsgErr, 2, 0,,,,,,{cMsgSol}) //"Control de Folios"
	EndIf
	
	FwFreeArray(aArea)

Return lRet
