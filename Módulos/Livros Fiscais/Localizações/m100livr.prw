#INCLUDE "Protheus.ch"

Static aLivrEnc	 := {}			// Campos SF3
Static aLivrDet	 := {}			// Valores default de campos SF3
Static aLivrPos := Array(38)	// Posiciones de campos especificos de SF3
Static nPosCpoLf := 0
Static lLxModPE	:= FindFunction("LxModPE")
Static lChkLxProp:= FindFunction("ChkLxProp")
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  º M100Livr   º Autor º Nava            º Data º  13/07/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º        Programa de Geracao de Livro Fiscal para todos os Paises       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   º M100Livr( aItemInfo, aLivro, nTaxa, cTipoMov )            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametrosº aItemInfo  - Impostos Variaveis do SD1 			          º±±
±±º           º aLivro     - Livros Fiscais            			          º±±
±±º           º nTaxa      - Taxa corrente da moeda     			      º±±
±±º           º cTipoMov   - Tipo Movimentacao         			          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   º aLivro(array com os dados do livro fiscal)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       º Localizacoes 							            	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         Atualizacoes efetuadas desde a codificacao inicial            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramadorº Data   º BOPS º  Motivo da Alteracao                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Willian   º25/06/01ºxxxxxxº Desenvolvimento Inicial                   º±±
±±º           º        º      º                                           º±±
±±º Nava      º03/07/01ºxxxxxxº Reescrito o programa para todos os paises º±±
±±º			  º	       º	  º											  º±±
±±ºTiago Bizanº15/07/10ºxxxxxxº Gravação do tipo da alíquota (F3_TPALIQ) eº±±
±±º			  º	       º	  º	do campo exentas (F3_EXENTAS)localização  º±±
±±º			  º	       º	  º Venezuela								  º±±
±±º Ivan      º06/06/11ºxxxxxxº Feita a limpeza e correcao do livro fiscalº±±
±±º Haponczuk º	       º	  º	do Uruguai.                               º±±
±±ºARodriguez º25/06/19ºDMINA-ºTratamiento CFO para MEX igual que COL	  º±±
±±º           º        º  6748ºDepurar variables no usadas. COL/MEX		  º±±
±±ºMarco A    º04/10/19ºDMINA-ºSe corrige error al generar libros fiscalesº±±
±±º           º        º  7514ºen rutina Pedimentos y NCC a partir de un  º±±
±±º           º        º      ºpedido de Venta. (MEX)                     º±±
±±ºLuis E Mataº29/01/20ºDMINA-ºEn informe de Analisis Financiero MATR210, º±±
±±º           º        º  8322ºno obtener CFO; AHEADER no existe. MEX	  º±±
±±ºARodriguez º19/02/20ºDMINA-ºOptimizacion - factura de entrada desde 	  º±±
±±º           º        º  7691ºremision. MEX							  º±±
±±º Marco A.  º07/09/20ºDMINA-ºSe agrega tratamiento para llenar el campo º±±
±±º           º        º  9972ºF3_TPDOC con el valor del campo F1_TPDOC   º±±
±±º           º        º      ºcuando los doctos. sean NF/NCP/NDP. (PER)  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M100Livr( aItemInfo, aLivro, nTaxa, cTipoMov, nSinal,dDataE)

Local nX, nY, nG, nW
Local cCFO		  := ""
Local lGeraLivr	  := .T. // Define se deve gerar o livro ou nao
Local nPosValr, nPosAliq, nPosBase, nPosDesg, nPosCFO
Local aArea       := GetArea()
Local aImpostos   := {}
Local dDataEmis
Local nTotalImp   := 0
Local nMoedaValor := 0
Local nDecs       := MsDecimais(1)
Local nMoedaAux
Local aItDel
Local nPosTpAct 	:= 0
Local nPosCodMu		:= 0
Local cTpActiv		:= ""
Local cCodMun		:= ""
Local nPosTES := 0
Local alAreaX
Local alAreaY            
Local cConcept	 := ""
Local cMV_AGENTE := GetNewPar("MV_AGENTE","   ")
Local nTotalBase := 0
Local nPosBasBol := 0
Local nPosLibFis := 0
Local lLibFis    := IIf(Upper(FunName())=="MATR210",.T.,.F.)

Local nValBase		:= 0
Local lNoActVal		:= .F.
Local lAjRed		:= .F.
Local lFisa084 := .F.
Local lFisa081 := .F.
Local lFnTpDig:= cPaisLoc == "PER" .AND. FindFunction("LxPerTpDIG") 
Local lTpDig := .F.
Local cVar 	:=ReadVar()

Local nImpNoRound := 0
Local nBaseImp 	  := 0
Local nAliqImp    := 0

Local nExentas    := 0
Local cCPOLVRO    := ""
Local lGetLvrPAR  := FindFunction("GetLvrPAR")

Private cGrpIra, cGrpIrpf
Private nE := 0
Private lMata143 := "MATA143" $ Upper(Funname()) .And. cPaisLoc=="ARG" .And. MaFisRet(,'NF_MOEDA')<>1 // A conversão da moeda na rotina MATA143(Despacho de Importação), está sendo realizado no fonte IMPXFIS. Apenas para a Argentina.
Private cNumero := ""
Private cSerie := ""

Default nTaxa := 0
Default nSinal := 1

cTipo := IIf(Type("cTipo")=="C",cTipo,"N")
cEspecie := IIf(Type("cEspecie")=="C",cEspecie,"NF")
cVenda := IIf(Type("cVenda")!="U",cVenda,"NORMAL")
nMoedaAux := IIf(Type("nMoedaNF")=="N",nMoedaNf,If(Type("nMoedaCor")=="N",nMoedaCor,1))
lNoActVal := cPaisLoc	== "ARG" .and. Iif(Type("lNoConv") == "L", lNoConv,.F.) //lNoConv indica si es detonada al final de todos los calculos, MV_ACTLIVF = .T. indica si se actualiza el libro fiscal, si ambos son .T. se realizan las sumas sin convertir los valores por la tasa. 
lAjRed := (cPaisLoc$"COL" .And. (Upper(FunName())$"MATA101N" .Or. (lChkLxProp .and. ChkLxProp("AjustaRedondeo")))  .And. nMoedaAux<>1)

aImpostos	:= aItemInfo[6]

cNrLivro		:= SF4->F4_NRLIVRO
cFormula		:= SF4->F4_FORMULA

IF ExistBlock("M100L001") .and. Iif(lLxModPE,LxModPE(, "M100L001"),.T.)
	nTaxa := ExecBlock("M100L001")
ENDIF

IF !AtIsRotina("LOCXNF") .And. Upper(Substr(FunName(),1,4)) == "LOJA"
   cNumero  := SF1->F1_DOC
   cSerie    := SF1->F1_SERIE
	IF cVenda == "RAPIDA"
		aImpostos := {}
	ENDIF
ENDIF 

IF Empty( aLivro )
	// aLivro := {{}}
	If Empty(aLivrEnc)
		aLivrEnc := GetArraySF3(cNivel)
		aFill( aLivrPos, 0)
		For nX := 1 to Len(aLivrEnc)
			aAdd( aLivrDet, Criavar(aLivrEnc[nX]) )
			Do Case
				Case aLivrEnc[nX] == "F3_VALCONT"	; aLivrPos[01] := nX
				Case aLivrEnc[nX] == "F3_NRLIVRO"	; aLivrPos[02] := nX
				Case aLivrEnc[nX] == "F3_FORMULA"	; aLivrPos[03] := nX
				Case aLivrEnc[nX] == "F3_ENTRADA"	; aLivrPos[04] := nX
				Case aLivrEnc[nX] == "F3_NFISCAL"	; aLivrPos[05] := nX
				Case aLivrEnc[nX] == "F3_SERIE"		; aLivrPos[06] := nX
				Case aLivrEnc[nX] == "F3_CLIEFOR"	; aLivrPos[07] := nX
				Case aLivrEnc[nX] == "F3_LOJA"		; aLivrPos[08] := nX
				Case aLivrEnc[nX] == "F3_ESTADO"	; aLivrPos[09] := nX
				Case aLivrEnc[nX] == "F3_EMISSAO"	; aLivrPos[10] := nX
				Case aLivrEnc[nX] == "F3_ESPECIE"	; aLivrPos[11] := nX
				Case aLivrEnc[nX] == "F3_TIPOMOV"	; aLivrPos[12] := nX
				Case aLivrEnc[nX] == "F3_TPDOC"		; aLivrPos[13] := nX
				Case aLivrEnc[nX] == "F3_TIPO"		; aLivrPos[14] := nX
				Case aLivrEnc[nX] == "F3_CFO"		; aLivrPos[15] := nX
				Case aLivrEnc[nX] == "F3_TES"		; aLivrPos[16] := nX
				Case aLivrEnc[nX] == "F3_NIT"		; aLivrPos[17] := nX
				Case aLivrEnc[nX] == "F3_EXENTAS"	; aLivrPos[32] := nX
				Case aLivrEnc[nX] == "F3_FRETE"		; aLivrPos[33] := nX
				Case aLivrEnc[nX] == "F3_VALMERC"	; aLivrPos[34] := nX
				Case aLivrEnc[nX] == "F3_MANUAL"	; aLivrPos[35] := nX
				Case aLivrEnc[nX] == "F3_GRPTRIB" .And. cPaisLoc == "URU"	; aLivrPos[36] := nX
				Case aLivrEnc[nX] == "F3_TPALIQ" .And. cPaisLoc == "VEN"	; aLivrPos[36] := nX
				Case aLivrEnc[nX] == "F3_CONCEPT" .And. cPaisLoc == "EQU"	; aLivrPos[36] := nX
				Case aLivrEnc[nX] == "F3_VALOBSE"	; aLivrPos[37] := nX
				Case aLivrEnc[nX] == "F3_RG1316" .And. cPaisLoc == "ARG"	; aLivrPos[38] := nX
				Case aLivrEnc[nX] == "F3_TPACTIV" .And. cPaisLoc == "COL"	; aLivrPos[36] := nX
				Case aLivrEnc[nX] == "F3_CODMUN" .And. cPaisLoc == "COL"	; aLivrPos[38] := nX
			EndCase
		Next nX
	EndIf
	aSize( aLivro, 0 )
	aAdd( aLivro, aLivrEnc )
ENDIF

_IdxF01 := aLivrPos[01]
_IdxF02 := aLivrPos[02]
_IdxF03 := aLivrPos[03]
_IdxF04 := aLivrPos[04]
_IdxF05 := aLivrPos[05]
_IdxF06 := aLivrPos[06]
_IdxF07 := aLivrPos[07]
_IdxF08 := aLivrPos[08]
_IdxF09 := aLivrPos[09]
_IdxF10 := aLivrPos[10]
_IdxF11 := aLivrPos[11]
_IdxF12 := aLivrPos[12]
_IdxF13 := aLivrPos[13]
_IdxF14 := aLivrPos[14]
_IdxF15 := aLivrPos[15]
_IdxF16 := aLivrPos[16]
_IdxF17 := aLivrPos[17] 
_IdxF32 := aLivrPos[32]
_IdxF33 := aLivrPos[33]
_IdxF34 := aLivrPos[34]
_IdxF35 := aLivrPos[35]   
_IdxF36 := aLivrPos[36]
_IdxF37 := aLivrPos[37]
_IdxF38 := aLivrPos[38]
//+---------------------------------------------------------------+
//¦ Busca informacoes nescessarias para o livro fiscal do Uruguai ¦
//+---------------------------------------------------------------+
If cPaisLoc == "URU"
	FGUruInf(aItemInfo)
EndIf

aItDel:=Array(Len(aLivro))
Afill(aItDel,.F.)
nE := Len( aLivro )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a regra para quebrar as linhas do livro fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "URU" .and. Posicione("SFC",2,xFilial("SFC")+SF4->F4_CODIGO,"FC_IMPOSTO")=="IRA"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quebra por tes e grupo do IRA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nSinal > 0
		nE := IIf(_IdxF16 > 0 .And. _IdxF36 > 0 ,aScan( aLivro,{|x| AllTrim(x[_IdxF16]) == SF4->F4_CODIGO .And. AllTrim(x[_IdxF36]) == cGrpIra},2),nE)
	Else
		nE := IIf(_IdxF16 > 0 .And. _IdxF36 > 0 ,aScan( aLivro,{|x| AllTrim(x[_IdxF16]) == SF4->F4_CODIGO .And. AllTrim(x[_IdxF36]) == cGrpIra .Or. Empty(x[_IdxF36])},2),nE)
	EndIf

ElseIf cPaisLoc == "EQU" .and. Posicione("SFC",1,xFilial("SFC")+AvKey(SF4->F4_CODIGO,"FC_TES"),"FC_IMPOSTO")=="RIR"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quebra por tes e conceito do RIR, caso o conceito em branco nao gera livro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cConcept := FRetNDad(aItemInfo,"D1_CONCEPT","C7_CONCEPT")
	If Empty(cConcept)
		lGeraLivr:=.F.
	Else
		nE := IIf(_IdxF16 > 0 .And. _IdxF36 > 0 ,aScan(aLivro,{|x| AllTrim(x[_IdxF16]) == SF4->F4_CODIGO .And. Alltrim(x[_IdxF36]) == AllTrim(cConcept)},2),nE)
	EndIf

ElseIf cPaisLoc $ "COL|MEX" .And. !lLibFis	// Colombia: Quebra sempre por TES + CFO
	If Type("lVisualiza" )=="L" .And. lVisualiza
		cCFO := SD1->D1_CF
		If cPaisLoc == "COL" 
			If  SD1->(ColumnPos('D1_TPACTIV')) > 0
				cTpActiv := SD1->D1_TPACTIV
			EndIf
			If  SD1->(ColumnPos('D1_CODMUN')) > 0	
				cCodMun := SD1->D1_CODMUN
			EndIf	
		EndIF	
    Else
		If  Type("aHeader")<> "U"
			nPosTpAct := aScan(aHeader,{|x| AllTrim(x[2])+" " == "D1_TPACTIV " })
			nPosCodMu := aScan(aHeader,{|x| AllTrim(x[2])+" " == "D1_CODMUN " })
		Endif
		If nSinal > 0
			If ReadVar() == "M->D1_TES"
				cCFO := SF4->F4_CF
				If cPaisLoc =="COL"
					If nPosTpAct > 0 
						cTpActiv:= aCols[aItemInfo[8]][nPosTpAct]
					EndIf
					If nPosCodMu > 0 
						cCodMun	:= aCols[aItemInfo[8]][nPosCodMu]
					EndIf
				EndIf
			Else
				If ReadVar() == "M->D1_CF"
					cCFO	:= M->D1_CF 
					If cPaisLoc =="COL"
						If nPosTpAct > 0 
							cTpActiv:= aCols[aItemInfo[8]][nPosTpAct]
						EndIf
						If nPosCodMu > 0 
							cCodMun	:= aCols[aItemInfo[8]][nPosCodMu]
						EndIf
					EndIf
				ElseIf Type("aCols") <> "U" .And. Len(aCols) >= aItemInfo[8]
					If Len(aItemInfo) > 8
						cCFO	:= aItemInfo[10]
						If cPaisLoc =="COL"
							If cVar == "M->D1_CODMUN" 
								cCodMun:= M->D1_CODMUN
								If nPosTpAct > 0
									cTpActiv := aCols[aItemInfo[8]][nPosTpAct]
								EndIf
							ElseIf cVar == "M->D1_TPACTIV" 
								cTpActiv:= M->D1_TPACTIV
								If nPosCodMu > 0
									cCodMun := aCols[aItemInfo[8]][nPosCodMu]
								EndIf
							Else
								If nPosTpAct > 0 
									cTpActiv:= aCols[aItemInfo[8]][nPosTpAct]
								EndIf
								If nPosCodMu > 0 
									cCodMun	:= aCols[aItemInfo[8]][nPosCodMu]
								EndIf 	
							EndIf
						EndIf
					Else
						nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "D1_CF " })
						If nPosCFO > 0
							cCFO	:= aCols[aItemInfo[8]][nPosCFO]
						Else
							cCFO	:= SF4->F4_CF
					    EndIf
				    EndIf
			    Else
					cCFO := SD1->D1_CF
			    EndIf
			EndIf
		Else  // Estorna sempre usando CFO do aCols
			nPosCFO := aScan(aHeader,{|x| AllTrim(x[2])+" " == "D1_CF " })
			If nPosCFO > 0
				cCFO	:= aCols[aItemInfo[8]][nPosCFO]
			Else
				cCFO	:= SF4->F4_CF
			EndIf
			If cPaisLoc =="COL"
				If nPosTpAct > 0 
					cTpActiv:= aCols[aItemInfo[8]][nPosTpAct]
				EndIf
				If nPosCodMu > 0 
					cCodMun	:= aCols[aItemInfo[8]][nPosCodMu]
				EndIf
			EndIf	
		EndIf
	EndIf
	If cPaisLoc =="COL"
		nE := IIf(_IdxF16 > 0 .And. _IdxF15 > 0 .And. _IdxF36 > 0 .And. _IdxF38 > 0  .And. nE>1 ,aScan( aLivro,{|x| x[_IdxF16] == SF4->F4_CODIGO .And. x[_IdxF15] == cCFO .And. Alltrim(x[_IdxF36]) == Alltrim(cTpActiv) .And. Alltrim(x[_IdxF38]) == Alltrim(cCodMun) },2),nE)		
	Else
		nE := IIf(_IdxF16 > 0 .And. _IdxF15 > 0 .And. nE>1 ,aScan( aLivro,{|x| x[_IdxF16] == SF4->F4_CODIGO .And. x[_IdxF15] == cCFO},2),nE)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quebra por TES, Bruno ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nE	:=	IIf(_IdxF16 > 0 .And. nE > 1 ,Ascan( aLivro ,{ |x| x[_IdxF16] == SF4->F4_CODIGO } ,2),nE)

EndIf
	
If lGeraLivr .And. !(cPaisLoc $ "MEX")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ nE < 2 significa que eh o primeiro ou que o TES escolhido nao existe no ARRAY ou que o Concepto escolhido nao existe no ARRAY ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nE < 2
		GeraLivr(@aLivro,cTipoMov,aItemInfo,dDataE,IIf(cPaisLoc=="COL",cCFO,))
	EndIf

	If lMata143 // A conversão da moeda na rotina MATA143(Despacho de Importação), está sendo realizado no fonte IMPXFIS. Apenas para a Argentina.
		aLivro[nE,_IdxF01] += (aItemInfo[3] + aItemInfo[4] + aItemInfo[5])*nSinal
	Else
		If (cPaisLoc == "ARG")
			If lNoActVal
				aLivro[nE,_IdxF01] += aItemInfo[3] + aItemInfo[4] + aItemInfo[5]
			Else
				aLivro[nE,_IdxF01] += (Round(xMoeda( aItemInfo[3] + aItemInfo[4] + aItemInfo[5],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa ),nDecs) * nSinal	)
			EndIf
		ElseIf!(cPaisLoc $ "PTG|COL")
			aLivro[nE,_IdxF01] += (xMoeda( aItemInfo[3] + aItemInfo[4] + aItemInfo[5],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa )*nSinal)
		EndIf
	EndIf
EndIf
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera o livro ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGeraLivr

	If Len(aImpostos) > 0
		If SF4->F4_CODIGO>"500"
			dDataEmis:=SF2->F2_EMISSAO
		Else     
			dDataEmis:=SF1->F1_EMISSAO      
		EndIf	
		
		If cPaisLoc <> "ARG"
			nPosLibFis := POSICIONE( "SFB", 1, xFilial("SFB")+"IVA", "FB_CPOLVRO" )
		Else
			If Empty(nPosCpoLf)
				nPosCpoLf := POSICIONE( "SFB", 1, xFilial("SFB")+"IVA", "FB_CPOLVRO" )
				nPosLibFis := nPosCpoLf
			Else
				nPosLibFis := nPosCpoLf
			EndIf
		EndIf
	
		lFisa084 := FWIsInCallStack("FISA084")
		lFisa081 := FWIsInCallStack("FISA081")
		For nX := 1 To Len(aImpostos)
			
			If aImpostos[nX]<>Nil
				If cPaisLoc $ "MEX|COL|PTG" .OR. aImpostos[nX,3] > 0.00
					nPosBase:= Ascan( aLivro[1],{|x| x == "F3_BASIMP"+aImpostos[nX][17] } )
					nPosAliq:= Ascan( aLivro[1],{|x| x == "F3_ALQIMP"+aImpostos[nX][17] } )
					nPosValr:= Ascan( aLivro[1],{|x| x == "F3_VALIMP"+aImpostos[nX][17] } )
					nPosDesg:= Ascan( aLivro[1],{|x| x == "F3_DESGR"+aImpostos[nX][17] } )
				
					DO CASE
						CASE cPaisLoc == "MEX"
							nE := Ascan( aLivro, { |x| ( x[nPosAliq] == aImpostos[nX,2] .OR. x[nPosAliq] == 0 ) .AND. ;
							IIF( _IdxF15 <> 0, x[_IdxF15] == cCFO, .T. ) .AND. ;
							IIF( _IdxF16 <> 0, x[_IdxF16] == SF4->F4_CODIGO, .T. ) }, 2 )
						CASE cPaisLoc == "PTG"
							nE := Ascan( aLivro, { |x| ( x[nPosAliq] == aImpostos[nX,2] .OR. x[nPosAliq] == 0 ) .AND. ;
							IIF( _IdxF15 <> 0, x[_IdxF15] == SF4->F4_CF, .T. ) .AND. ;
							IIF( _IdxF16 <> 0, x[_IdxF16] == SF4->F4_CODIGO, .T. ) }, 2 )
						CASE cPaisLoc == "COL"
							nE := Ascan( aLivro, { |x| ( x[nPosAliq] == aImpostos[nX,2] .OR. x[nPosAliq] == 0 ) .AND. ;
							IIF( _IdxF15 <> 0, x[_IdxF15] == cCFO, .T. ) .AND. ;
							IIF( _IdxF38 <> 0, Alltrim(x[_IdxF38]) == Alltrim(cCodMun), .T. ) .AND.;
							IIF( _IdxF36 <> 0, AllTrim(x[_IdxF36]) == AllTrim(cTpActiv), .T. ) .AND.;
							IIF( _IdxF16 <> 0, x[_IdxF16] == SF4->F4_CODIGO, .T. ) .AND. ;
							IIF( _IdxF17 <> 0, x[_IdxF17] == aItemInfo[7], .T. ) }, 2 )
					ENDCASE
					
					IF aImpostos[nX,17] == nPosLibFis  .And. cPaisLoc $ "BOL"
						nPosBasBol := aImpostos[nX,3]
					ENDIF
				
					IF cPaisLoc $ "MEX|COL|PTG" .And. nSinal > 0
						IF nE == 0
							GeraLivr(@aLivro,cTipoMov,aItemInfo,dDataE,IIf(cPaisLoc$"COL|MEX",cCFO,))
						Endif
					ENDIF

					lTpDig := .F.
					
					If lFnTpDig // verifica si el impuesto es una detracción Perú
						lTpDig := LxPerTpDIG(aImpostos[nX,1])
					EndIF
				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³No caso de moeda extrangeira, deve-se converter para moeda local³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
					// A conversão da moeda na rotina MATA143(Despacho de Importação), está sendo realizado no fonte IMPXFIS. Apenas para a Argentina.					
					If lMata143
						nMoedaValor := aImpostos[nX,4] * nSinal
					Else
						If lNoActVal
							nMoedaValor := aImpostos[nX,4]
						Else
							If lTpDig  // si es una detracción redondea a 0 decimales Perú
								nMoedaValor := round((xMoeda(aImpostos[nX,4],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa) * nSinal), 0)
							Else
								nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa) * nSinal
							EndIf
						EndIf	
					EndIf

					

					If nPosBase > 0	.And. nPosValr > 0 .And. nPosAliq > 0 .And. nE <>0
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³         Tratamento específico para localizado PERU             ³
						//³  Abaixo são efetuados os cálculos do impostoso para comporem   ³
						//³ o livro fiscal												   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
						If cPaisLoc $ "PER"

							alAreaX := SF4->(GetArea())
							alAreaY := SFC->(GetArea())
							nPosTES := Ascan( aLivro[1],{|x| x == "F3_TES" } )
						
							If aImpostos[nX][1] $ "IGV"

								DbSelectArea("SF4")
								DbSetOrder(1)
								If DbSeek(xFilial("SF4") + aLivro[nE,nPosTES])
									If (SF4->F4_CALCIGV <> "2" .And. SF4->F4_CALCIGV <> "3")
										aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
										aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + nMoedaValor
										aLivro[nE,nPosAliq] := aImpostos[nX,2]
										If nPosDesg > 0
											aLivro[nE,nPosDesg] := aImpostos[nX,18]
										EndIf
									
										nTotalImp += aLivro[nE,nPosValr]
									
										//+---------------------------------------------------------------------+
										//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
										//+---------------------------------------------------------------------+
									
										If Substr(aImpostos[nX][5],2,1)=="1"
											aLivro[nE,_IdxF01] += nMoedaValor
										ElseIf Substr(aImpostos[nX][5],2,1)=="2"
											aLivro[nE,_IdxF01] -= nMoedaValor
										EndIf
									
										If nSinal<0 .AND. nE>1
											If aLivro[nE,nPosBase]<=0 .and. aLivro[nE,nPosValr]<=0
												aItDel[nE-1]:=.T.
											EndIf
										EndIf
									EndIf
								EndIf

							ElseIf aImpostos[nX][1] $ "PIV"
							
								If cTipoMov $ "V"
								
									DbSelectArea("SA1")
									DbSetOrder(1)
									If DbSeek(xFilial("SA1")+ aLivro[nE,_IdxF07] + aLivro[nE,_IdxF08])
										If SubStr(cMV_AGENTE,1,1) == "N" .And.  SA1->A1_AGENTE == "2"
										
											aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
											aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + nMoedaValor
											aLivro[nE,nPosAliq] := aImpostos[nX,2]
											If nPosDesg > 0
												aLivro[nE,nPosDesg] := aImpostos[nX,18]
											EndIf
										
											nTotalImp += aLivro[nE,nPosValr]
										
											//+---------------------------------------------------------------------+
											//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
											//+---------------------------------------------------------------------+
										
											If Substr(aImpostos[nX][5],2,1)=="1"
												aLivro[nE,_IdxF01] += nMoedaValor
											ElseIf Substr(aImpostos[nX][5],2,1)=="2"
												aLivro[nE,_IdxF01] -= nMoedaValor
											EndIf
										
											If nSinal<0 .AND. nE>1
												If aLivro[nE,nPosBase]<=0 .and. aLivro[nE,nPosValr]<=0
													aItDel[nE-1]:=.T.
												EndIf
											EndIf
										
										EndIf
									
									EndIf
								
								ElseIf cTipoMov $ "C"
								
									DbSelectArea("SA2")
									DbSetOrder(1)
									If DbSeek(xFilial("SA2")+ aLivro[nE,_IdxF07] + aLivro[nE,_IdxF08])
									
										If SubStr(cMV_AGENTE,2,1) == "S" .And.  SA2->A2_AGENRET <> "1"
										
											aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
											aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + nMoedaValor
											aLivro[nE,nPosAliq] := aImpostos[nX,2]
											If nPosDesg > 0
												aLivro[nE,nPosDesg] := aImpostos[nX,18]
											EndIf
										
											nTotalImp += aLivro[nE,nPosValr]
										
											//+---------------------------------------------------------------------+
											//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
											//+---------------------------------------------------------------------+
										
											If Substr(aImpostos[nX][5],2,1)=="1"
												aLivro[nE,_IdxF01] += nMoedaValor
											ElseIf Substr(aImpostos[nX][5],2,1)=="2"
												aLivro[nE,_IdxF01] -= nMoedaValor
											EndIf
										
											If nSinal<0 .AND. nE>1
												If aLivro[nE,nPosBase]<=0 .and. aLivro[nE,nPosValr]<=0
													aItDel[nE-1]:=.T.
												EndIf
											EndIf
										
										EndIf
									
									EndIf
								
								EndIf
							
							ElseIf aImpostos[nX][1] $ "DIG" .or. lTpDig
							
								If cTipoMov $ "V"
								
									DbSelectArea("SA1")
									DbSetOrder(1)
									If DbSeek(xFilial("SA1")+ aLivro[nE,_IdxF07] + aLivro[nE,_IdxF08])
										If SubStr(cMV_AGENTE,1,1) == "N" .And.  SA1->A1_AGENTE == "3"
										
											aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
											aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + nMoedaValor
											aLivro[nE,nPosAliq] := aImpostos[nX,2]
											If nPosDesg > 0
												aLivro[nE,nPosDesg] := aImpostos[nX,18]
											EndIf
										
											nTotalImp += aLivro[nE,nPosValr]
										
											//+---------------------------------------------------------------------+
											//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
											//+---------------------------------------------------------------------+
										
											If Substr(aImpostos[nX][5],2,1)=="1"
												aLivro[nE,_IdxF01] += nMoedaValor
											ElseIf Substr(aImpostos[nX][5],2,1)=="2"
												aLivro[nE,_IdxF01] -= nMoedaValor
											EndIf
										
											If nSinal<0 .AND. nE>1
												If aLivro[nE,nPosBase]<=0 .and. aLivro[nE,nPosValr]<=0
													aItDel[nE-1]:=.T.
												EndIf
											EndIf
										
										EndIf
									EndIf

								ElseIf cTipoMov $ "C"

									DbSelectArea("SA2")
									DbSetOrder(1)
									If DbSeek(xFilial("SA2")+ aLivro[nE,_IdxF07] + aLivro[nE,_IdxF08])
									
										If SubStr(cMV_AGENTE,3,1) == "S" 
										
											aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
											aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + nMoedaValor
											aLivro[nE,nPosAliq] := aImpostos[nX,2]
											If nPosDesg > 0
												aLivro[nE,nPosDesg] := aImpostos[nX,18]
											EndIf
										
											nTotalImp += aLivro[nE,nPosValr]
										
											//+---------------------------------------------------------------------+
											//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
											//+---------------------------------------------------------------------+
										
											If Substr(aImpostos[nX][5],2,1)=="1"
												aLivro[nE,_IdxF01] += nMoedaValor
											ElseIf Substr(aImpostos[nX][5],2,1)=="2"
												aLivro[nE,_IdxF01] -= nMoedaValor
											EndIf
										
											If nSinal<0 .AND. nE>1
												If aLivro[nE,nPosBase]<=0 .and. aLivro[nE,nPosValr]<=0
													aItDel[nE-1]:=.T.
												EndIf
											EndIf
										
										EndIf
									
									EndIf
								
								EndIf
							
							Else
								aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
								aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + nMoedaValor
								aLivro[nE,nPosAliq] := aImpostos[nX,2]
								If nPosDesg > 0
									aLivro[nE,nPosDesg] := aImpostos[nX,18]
								EndIf
							
								nTotalImp += aLivro[nE,nPosValr]
							
								//+---------------------------------------------------------------------+
								//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
								//+---------------------------------------------------------------------+
							
								If Substr(aImpostos[nX][5],2,1)=="1"
									aLivro[nE,_IdxF01] += nMoedaValor
								ElseIf Substr(aImpostos[nX][5],2,1)=="2"
									aLivro[nE,_IdxF01] -= nMoedaValor
								EndIf
							
								If nSinal<0 .AND. nE>1
									If aLivro[nE,nPosBase]<=0 .and. aLivro[nE,nPosValr]<=0
										aItDel[nE-1]:=.T.
									EndIf
								EndIf
							
							EndIf

							RestArea(alAreaX)
							RestArea(alAreaY)
						
						ElseIf cPaisLoc $ "COL"

							alAreaX := SF4->(GetArea())
							alAreaY := SFC->(GetArea())
							nPosTES := Ascan( aLivro[1],{|x| x == "F3_TES" } )
						
							If aImpostos[nX][1] $ "IVA"

								DbSelectArea("SF4")
								DbSetOrder(1)
								If DbSeek(xFilial("SF4") + aLivro[nE,nPosTES])
									If SF4->F4_CALCIVA <> "3"
										nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,dDataEmis,nDecs+1,nTaxa)
										aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,dDataEmis,nDecs+1,nTaxa)*nSinal)
										aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)
										aLivro[nE,nPosAliq] := aImpostos[nX,2]
										If nPosDesg > 0
											aLivro[nE,nPosDesg] := aImpostos[nX,18]
										EndIf
									
										nTotalImp += aLivro[nE,nPosValr]
									
										//+---------------------------------------------------------------------+
										//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
										//+---------------------------------------------------------------------+
									
										If Substr(aImpostos[nX][5],2,1)=="1"
											aLivro[nE,_IdxF01] += nMoedaValor * nSinal
										ElseIf Substr(aImpostos[nX][5],2,1)=="2"
											aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
										EndIf
									EndIf
								EndIf

							Else

								nMoedaValor := xMoeda(aImpostos[nX,4],nMoedaAux,1,dDataEmis,nDecs+1,nTaxa)
								nValSumBs	:= (xMoeda(aImpostos[nX,3],nMoedaAux,1,dDataEmis,nDecs+1,nTaxa)*nSinal)
								aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + IIf(lAjRed, Round(nValSumBs,nDecs), nValSumBs)
								aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + (nMoedaValor * nSinal)
								aLivro[nE,nPosAliq] := aImpostos[nX,2]
								If nPosDesg > 0
									aLivro[nE,nPosDesg] := aImpostos[nX,18]
								EndIf
							
								nTotalImp += aLivro[nE,nPosValr]
							
								//+---------------------------------------------------------------------+
								//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
								//+---------------------------------------------------------------------+
							
								If Substr(aImpostos[nX][5],2,1)=="1"
									aLivro[nE,_IdxF01] += nMoedaValor * nSinal
								ElseIf Substr(aImpostos[nX][5],2,1)=="2"
									aLivro[nE,_IdxF01] -= nMoedaValor * nSinal
								EndIf

							EndIf
						
							RestArea(alAreaX)
							RestArea(alAreaY)

						Else

							If lMata143 // A conversão da moeda na rotina MATA143(Despacho de Importação), está sendo realizado no fonte IMPXFIS. Apenas para a Argentina.
								aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + aImpostos[nX,3] * nSinal
							Else
								If cPaisLoc == 'ARG'
									If lNoActVal
										nValBase	:= aImpostos[nX,3]
									Else
										nValBase	:= Round(xMoeda(aImpostos[nX,3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa),nDecs)
										//nFactor 	:= Iif(nMoedaAux != 1,aImpostos[nX,4] / aImpostos[nX,3],1)
										
										nMoedaValor := Iif(nMoedaAux != 1,xMoeda(aImpostos[nX,4],nMoedaAux,1,SF1->F1_EMISSAO,nDecs+1,nTaxa)* nSinal, nMoedaValor)
				
										nMoedaValor := Round(nMoedaValor, nDecs)
									EndIf
									
									aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (nValBase*nSinal)
								Else
									aLivro[nE,nPosBase] := IIf(aLivro[nE,nPosBase]==Nil,0,aLivro[nE,nPosBase]) + (xMoeda(aImpostos[nX,3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
								EndIf
							EndIf 

							aLivro[nE,nPosValr] := Iif(aLivro[nE,nPosValr]==Nil,0,aLivro[nE,nPosValr]) + nMoedaValor

							aLivro[nE,nPosAliq] := aImpostos[nX,2]	

							If nPosDesg > 0
								aLivro[nE,nPosDesg] := aImpostos[nX,18]
							EndIf
						
							nTotalImp += aLivro[nE,nPosValr] 						
						
							If cPaisloc == "COS"  
								nTotalBase += aLivro[nE,nPosBase] 
							EndIf						
							//+---------------------------------------------------------------------+
							//¦Soma os impostos incidentes no campo F3_VALCONT.                     ¦
							//+---------------------------------------------------------------------+
						
							If Substr(aImpostos[nX][5],2,1)=="1"
								aLivro[nE,_IdxF01] += nMoedaValor
							ElseIf Substr(aImpostos[nX][5],2,1)=="2"
								aLivro[nE,_IdxF01] -= nMoedaValor
							EndIf
						
							If nSinal<0 .AND. nE>1 .And. !(lFisa084 .or. lFisa081)
								If aLivro[nE,nPosBase]<=0 .and. aLivro[nE,nPosValr]<=0
									aItDel[nE-1]:=.T.
								EndIf
							EndIf

						EndIf
					
					EndIf

				EndIf
			EndIf
		
		    If cPaisLoc=="URU"
				SFC->(dbSetOrder(1))
				SFC->(dbGoTop())
				If SFC->(dbSeek(xFilial('SFC')+ SF4->F4_CODIGO ))
					nConcep:=1
					While SFC->(!EOF()) .And. SFC->FC_TES == SF4->F4_CODIGO .And. nConcep <= Len(aImpostos)  
						dbSelectArea('SFF')
				  		SFF->(dbSetOrder(5))
						If SFF->(dbSeek(xFilial('SFF')+ Avkey(SFC->FC_IMPOSTO,'FF_IMPOSTO')+AvKey(SF4->F4_CF,'FF_CFO_C')))
							nPosConcep:= Ascan( aLivro[1],{|x| x == "F3_CONCEP"+aImpostos[nConcep][17] } )
							aLivro[nE,nPosConcep]:=SFF->FF_CONCIRP		
						EndIf
						SFC->(dbSkip())
						nConcep++
					End
				EndIf 
			EndIf

		Next nX
	
	ElseIf cPaisLoc $ "MEX|COL|PTG"  //Tratamento quando nao ha impostos
		nE := Ascan( aLivro, { |x| IIf( _IdxF15 <> 0, x[_IdxF15] == IIf(cPaisLoc $ "COL|MEX", cCFO, SF4->F4_CF), .T. ) .AND. ;
		IIf( _IdxF16 <> 0, x[_IdxF16] == SF4->F4_CODIGO, .T. ) .AND. ;
		IIf( cPaisLoc == "COL", (IIf( _IdxF17 <> 0, x[_IdxF17] == aItemInfo[7], .T. )) ,.T.) }, 2 )
		If nE == 0 .And. nSinal > 0
			GeraLivr(@aLivro,cTipoMov,aItemInfo,dDataE,IIf(cPaisLoc $ "COL|MEX",cCFO,))
		EndIf

	EndIf

	If (cPaisLoc $ "ARG" .AND. nTotalImp == 0 .AND. Len(aImpostos) > 0)
		FOR nW:=1 TO Len(aImpostos)
			If aImpostos[nW,3] <> 0.00
				nBaseImp  := aImpostos[nW][3]
				nAliqImp  := aImpostos[nW][2]
				nImpNoRound := (nBaseImp * (nAliqImp / 100))
				Exit
			EndIf
		Next nW
	EndIf
	
	If nE>0
		If (nTotalImp == 0  .AND. nImpNoRound == 0 .AND. _IdxF32 > 0) .Or. (cPaisLoc $ "BOL" .And. _IdxF32 > 0)  // Exentas
			If (cPaisLoc=="CHI")  .Or. (cPaisLoc == "PAR") .Or. (cPaisLoc == "ARG")
				If lNoActVal
					aLivro[nE,_IdxF32] += aItemInfo[3]+aItemInfo[4]+aItemInfo[5]
				Else
					aLivro[nE,_IdxF32] += (Round(xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,dDataEmis,nDecs+1,nTaxa),nDecs)*nSinal)
				EndIf
			ElseIf cPaisLoc $ "COL"
				If SF4->F4_CALCIVA <> "2"
					If lAjRed
						aLivro[nE,_IdxF32] += Round((xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5]-Iif(aItemInfo[5]==0,0,aItemInfo[9]),nMoedaAux,1,dDataEmis,nDecs+1,nTaxa)*nSinal),nDecs)
					Else
						aLivro[nE,_IdxF32] += (xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5]-Iif(aItemInfo[5]==0,0,aItemInfo[9]),nMoedaAux,1,dDataEmis,nDecs+1,nTaxa)*nSinal)
					EndIf
				EndIf
			ElseIf cPaisLoc == "VEN"
				If SF4->F4_CALCIVA == "3"
					aLivro[nE,_IdxF32] += aItemInfo[3]
				EndIf
		 	ElseIf cPaisloc == "COS" 
				If nTotalBase > 0
					aLivro[nE,_IdxF32] += 0				
				Else
		 			aLivro[nE,_IdxF32] += (xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,dDataEmis,nDecs+1,nTaxa)*nSinal)
		  		Endif 		
			ElseIf cPaisloc == "BOL" .And. nPosBasBol > 0 
					aLivro[nE,_IdxF32]+= aItemInfo[3]-nPosBasBol
			Else
				If lMata143 // A conversão da moeda na rotina MATA143(Despacho de Importação), está sendo realizado no fonte IMPXFIS. Apenas para a Argentina.
					aLivro[nE,_IdxF32] += aItemInfo[3]+aItemInfo[4]+aItemInfo[5]
				Else
					aLivro[nE,_IdxF32] += (xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,dDataEmis,nDecs+1,nTaxa)*nSinal)
				EndIf
			EndIf
		EndIf
		
		If lMata143 // A conversão da moeda na rotina MATA143(Despacho de Importação), está sendo realizado no fonte IMPXFIS. Apenas para a Argentina.
			If _IdxF33 > 0 // Frete
				aLivro[nE,_IdxF33] += aitemInfo[4]*nSinal
			EndIf
			If _IdxF34 > 0 // ValMerc
				If (cPaisLoc == "ARG")
					aLivro[nE,_IdxF34] += (Round(xMoeda(aitemInfo[3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa),nDecs)*nSinal)
				Else
					aLivro[nE,_IdxF34] += (xMoeda(aitemInfo[3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
				EndIf
			EndIf
		Else
			If _IdxF33 > 0 // Frete
				If lNoActVal
					aLivro[nE,_IdxF33] += aitemInfo[4]
				Else
					aLivro[nE,_IdxF33] += (xMoeda(aitemInfo[4],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
				EndIf
			EndIf
			If _IdxF34 > 0 // ValMerc
				If lNoActVal
					aLivro[nE,_IdxF34] += aitemInfo[3]
				Else
					If lAjRed
						aLivro[nE,_IdxF34] += Round((xMoeda(aitemInfo[3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal),nDecs)
					Else
						aLivro[nE,_IdxF34] += (xMoeda(aitemInfo[3],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
					EndIf
				EndIf
			EndIf
		EndIf
		
		If cPaisLoc $ "COL|MEX|PTG" .AND. Len(aLivro)>1
			If lAjRed
				aLivro[nE,_IdxF01] += Round((xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal),nDecs)
			Else
				aLivro[nE,_IdxF01] += (xMoeda(aItemInfo[3]+aItemInfo[4]+aItemInfo[5],nMoedaAux,1,SF1->F1_DTDIGIT,nDecs+1,nTaxa)*nSinal)
			EndIf
		EndIf
		
		If cPaisLoc == "PAR" .And. lGetLvrPAR
			If nE > 1 .And. Len(aLivro) > 1 .And. _IdxF32 > 0 .And. _IdxF01 > 0 .And. _IdxF16 > 0
				cCPOLVRO := GetLvrPAR(aLivro[nE, _IdxF16])
				If !Empty(cCPOLVRO)
					nPosBase := Ascan(aLivro[1],{|x| x == "F3_BASIMP"+cCPOLVRO})
					nPosValr := Ascan(aLivro[1],{|x| x == "F3_VALIMP"+cCPOLVRO})
					If nPosBase > 0 .And. nPosValr > 0 .And. aLivro[nE, nPosBase] > 0
						nExentas := Round(aLivro[nE, _IdxF01] - (aLivro[nE, nPosBase] + aLivro[nE, nPosValr]), nDecs)
						If nExentas > 0
							aLivro[nE, _IdxF32] := nExentas
						Endif
					Endif
				Endif	
			Endif
		Endif

	EndIf
	
	If nSinal<0 .AND. nE>1
		If aLivro[nE,_IdxF01]<=0
			aItDel[nE-1]:=.T.
		EndIf
	EndIf

	If nSinal<0
		nY:=Len(aItDel)
		nX:=Len(aLivro)
		If nY>0
			For nG := nY To 1 Step -1
				If aItDel[nG]
					aLivro:=Adel(aLivro,nG+1)
					nX--
				EndIf
			Next
			aLivro:=ASize(aLivro,nX)
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return( aLivro )        // incluido pelo assistente de conversao do AP5 IDE em 09/09/99

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraLivr ³ Autor ³ Fernando Machima      ³ Data ³ 09/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava os dados no array aLivro                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA467, MATA468, MATA466, MATA465                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function GeraLivr(aLivro,cTipoMov,aItemInfo,dDtEmis,cCFO)

Local nY
Local lNotaManual  := IIf(Type("lNFManual")#"U",lNFManual,.F.)
Local dDataDig	   := dDataBase
Local nPosParAux:=0
Local nPosTpAct := 0
Local nPosCodMu := 0

DEFAULT dDtEmis := dDataBase
DEFAULT cCFO	:= SF4->F4_CF

nE := Len(aLivro)+1
aAdd( aLivro , aClone(aLivrDet) )
aLivro[nE,_IdxF01] := 0.00
IIf (_IdxF02 > 0, aLivro[nE,_IdxF02] := cNrLivro, .T.)
aLivro[nE,_IdxF03] := cFormula

If Type("lVisualiza" )=="L" .And. lVisualiza
	If SF4->F4_CODIGO>"500"
		dDataDig:=SF2->F2_DTDIGIT
		dDtEmis:=SF2->F2_EMISSAO
	Else
		dDataDig:=SF1->F1_DTDIGIT
		dDtEmis:=SF1->F1_EMISSAO      
	EndIf	
EndIf
aLivro[nE,_IdxF04] := dDataDig
aLivro[nE,_IdxF05] := cNumero
If MaFisFound()
	aLivro[nE,_IdxF06] := MaFisRet(,"NF_SERIENF")
EndIf
If Empty(aLivro[nE,_IdxF06])
	aLivro[nE,_IdxF06] := cSerie
EndIf
aLivro[nE,_IdxF07] := IIf(cTipo$"DB",SA1->A1_COD,	SA2->A2_COD)
aLivro[nE,_IdxF08] := IIf(cTipo$"DB",SA1->A1_LOJA,	SA2->A2_LOJA)
aLivro[nE,_IdxF09] := IIf(cTipo$"DB",SA1->A1_EST,	SA2->A2_EST)
aLivro[nE,_IdxF10] := dDtEmis
aLivro[nE,_IdxF11] := cEspecie
aLivro[nE,_IdxF12] := cTipoMov

If  cPaisLoc=="BOL" .And.  (FunName()$"MATA101N" .Or. (lChkLxProp .and. ChkLxProp("LFDescuentoFactura"))) .and.  Type("n")<> "U"    .And. Type(" aHeader")<> "U"   .And. Type("aCols")<> "U"   .And. ;
			  len (aCols)>= n .And.    len(aCols[n])>=AScan( aHeader,{|x| AllTrim(x[2]) == "D1_DESC" } )
		If Alias() == "SC7" .and. AScan( aHeader,{|x| AllTrim(x[2]) == "C7_DESC" } ) > 0
			aLivro[nE,_IdxF37] := aCols[n][AScan( aHeader,{|x| AllTrim(x[2]) == "C7_DESC" } )]
		ElseIf AScan( aHeader,{|x| AllTrim(x[2]) == "D1_DESC" } ) > 0
			aLivro[nE,_IdxF37] := aCols[n][AScan( aHeader,{|x| AllTrim(x[2]) == "D1_DESC" } )]
		EndIf
EndIf

IF (cPaisloc== "PAR") .and. (AllTrim(cEspecie)$"NDP|NF") .and. ((ALLTRIM(FunName()) $ "MATA101N") .OR.(ALLTRIM(FunName()) $ "MATA466N") .Or. (lChkLxProp .and. ChkLxProp("GrabaDOCEL")) .OR. IsBlind() )
		
		nPosParAux := Ascan(aLivro[1],{ |x| UPPER(x) == AllTrim("F3_DOCEL") } )
		IF nPosParAux<>0 .and. SF1->(FieldPos("F1_DOCEL"))>0
			aLivro[nE][nPosParAux]:=SF1->F1_DOCEL
		ENDIF
ENDIF
/*Tratamento especifico do Peru:
Cod.  Tipo de documento
01 - Faturas(Pessoa Juridica, possui CNPJ)
03 - Boleta de Venda(Pessoa Fisica, nao possui CNPJ)
07 - Nota de Credito
08 - Nota de Debito

Obs: Os codigos sao fixos
*/
IF _IdxF13 > 0 .AND. cPaisLoc == "PER"
	If Alltrim(cEspecie) $ "NF|NCC|NDP"
		If SF1->(ColumnPos("F1_TPDOC")) > 0
			aLivro[nE,_IdxF13] := SF1->F1_TPDOC
		Else
			aLivro[nE,_IdxF13] := Space(TamSx3("F3_TPDOC")[1])
		EndIf
	Else
		SA2->(DbSetOrder(1)) //A2_FILIAL+A2_COD+A2_LOJA                                                                                                                                        
		If SA2->(DbSeek(xFilial("SA2")+aLivro[nE,_IdxF07]+aLivro[nE,_IdxF08]))
			If Alltrim(cEspecie) $ "FT"
				If Empty(SA2->A2_CGC)
					aLivro[nE,_IdxF13] := "03"
				Else
					aLivro[nE,_IdxF13] := "01"
				Endif
			Else
				If Alltrim(cEspecie) $"NCI"
					aLivro[nE,_IdxF13] := "07"
				Else
					aLivro[nE,_IdxF13] := "08"
				Endif
			EndIf
		Endif
	EndIf
Endif

IIf (_IdxF14 > 0, aLivro[nE,_IdxF14]:= cTipo, .T.)  

If cPaisLoc $ "BOL | ARG"      
	IIf (_IdxF15 > 0, aLivro[nE,_IdxF15]:= aItemInfo[8], .T.)
//ElseIf cPaisLoc $ "COL"
//	IIf (_IdxF15 > 0, aLivro[nE,_IdxF15]:= aItemInfo[10], .T.)    
Else
	If FunName()$"MATA101N|MATA466N|MATA465N" .Or. (lChkLxProp .and. ChkLxProp("LFGrabaCFOVar")) .Or. !MaFisFound()
		IIf (_IdxF15 > 0, aLivro[nE,_IdxF15]:= cCFO, .T.)
	Else
		IIf (_IdxF15 > 0, aLivro[nE,_IdxF15]:= MaFisRet(,"IT_CF"), .T.)
	EndIf
EndIf

IIf (_IdxF16 > 0, aLivro[nE,_IdxF16]:= SF4->F4_CODIGO, .T.)
IIf (_IdxF17 > 0 .And. cPaisLoc == "COL", aLivro[nE,_IdxF17] := aItemInfo[7],.T.)
IIf (_IdxF35 > 0 .And. cPaisLoc == "GUA", aLivro[nE,_IdxF35] := IIf(lNotaManual,"S","N"), Nil)
IIf (_IdxF36 > 0 .And. cPaisLoc == "VEN", aLivro[nE,_IdxF36] := SF4->F4_TPALIQ, Nil)
				
If cPaisLoc == "EQU"
	If Posicione("SFC",1,xFilial("SFC")+AvKey(aLivro[nE,_IdxF16],"FC_TES"),"FC_IMPOSTO") == "RIR"
		aLivro[nE,_IdxF36] := FRetNDad(aItemInfo,"D1_CONCEPT","C7_CONCEPT")
	Else
		aLivro[nE,_IdxF36] := Space(3)
	EndIf	             
ElseIf cPaisLoc == "URU"
	If Posicione("SFC",2,xFilial("SFC")+AvKey(aLivro[nE,_IdxF16],"FC_TES"),"FC_IMPOSTO") == "IRA"
		aLivro[nE,_IdxF36] := cGrpIra
	ElseIf Posicione("SFC",2,xFilial("SFC")+AvKey(aLivro[nE,_IdxF16],"FC_TES"),"FC_IMPOSTO") == "IRP"
		aLivro[nE,_IdxF36] := cGrpIrpf
	ElseIf nE>0 .And. _IdxF36>0		
		aLivro[nE,_IdxF36] := Space(3)
	EndIf
ElseIf cPaisLoc == "ARG"
	If FindFunction("GetM100") .And. _IdxF38 > 0
		aLivro[nE,_IdxF38] := IIf(GetM100(aLivro[nE, _IdxF16]), "S", "")
	EndIf
ElseIf	cPaisLoc == "COL"
	If  Type("aHeader")<> "U"
		nPosTpAct := AScan( aHeader,{|x| AllTrim(x[2]) == "D1_TPACTIV" } ) 
		nPosCodMu := AScan( aHeader,{|x| AllTrim(x[2]) == "D1_CODMUN" } ) 
	Endif
	If nPosTpAct > 0
		IIF (_IdxF36 > 0, aLivro[nE, _IdxF36] := IIF(ReadVar() == "M->D1_TPACTIV", M->D1_TPACTIV, aCols[aItemInfo[8]][nPosTpAct]),.T.)
	EndIf
	If nPosCodMu  > 0
		IIF (_IdxF38 > 0, aLivro[nE, _IdxF38] := IIF(ReadVar() =="M->D1_CODMUN",M->D1_CODMUN,aCols[aItemInfo[8]][nPosCodMu]),.T.)
	EndIf
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGUruInf ³ Autor ³ Ivan Haponczuk      ³ Data ³ 27.05.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Busca as informacoes nescessarias para o livro fiscal      ³±±
±±³          ³ do Uruguai.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Impostos Variaveis do SD1.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uruguai                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGUruInf(aItemInfo)

	Local cProd := FRetNDad(aItemInfo,"D1_COD","C7_PRODUTO")

	cGrpIra  := ""
	cGrpIrpf := ""
	
	//Busca os dados da tabela de produtos
	cGrpIra  := AllTrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_GRPIRAE"))
	cGrpIrpf := AllTrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_GRPIRPF"))	
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FRetNDad ³ Autor ³ Ivan Haponczuk      ³ Data ³ 27.05.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna a informacao da nota/pedido.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Impostos Variaveis do SD1.                        ³±±
±±³          ³ cPar02 - Nome do campo que deve ser buscado da SD1.        ³±±
±±³          ³ cPar03 - Nome do campo que deve ser buscado da SC7.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Localizacoes                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FRetNDad(aItemInfo,cCampoD1,cCampoC7)

	Local nPos := 0
	Local cRet := ""
	
	Default cCampoD1 := ""
	Default cCampoC7 := ""
	
	//Busca dados do aCols se existir
	If Type("aCols") == "A"
		nPos := aScan(aHeader,{|x| AllTrim(x[2]) == cCampoD1 })
		If nPos <= 0
			nPos := aScan(aHeader,{|x| AllTrim(x[2]) == cCampoC7 })
		EndIf
		If nPos > 0
			cRet := aCols[aItemInfo[8]][nPos]
		EndIf
	EndIf

Return cRet

/*/{Protheus.doc} GetArraySF3
	Función utilizada para obetener los campos usados de la SF3 y los campos de impuestos.
	@type  Function
	@author raul.medina
	@since 
	@param
		cNivel - caracter - Nivel de campos a ser considerados.
	@return aLivrEnc
	/*/
Static Function GetArraySF3(cNivel)
Local aSF3Cpos 	:= FWSX3Util():GetAllFields( "SF3" , .F. )
Local nX		:= 0
Local cField	:= ""
Local aLivrEnc	:= {}

Default cNivel	 := 0

	If Len(aSF3Cpos) > 0
		For nX := 1 to Len(aSF3Cpos)
			cField := aSF3Cpos[nX]
			If (X3Uso(GetSx3Cache(cField, "X3_USADO")) .Or. (Substr(cField,1,9) $ "F3_BASIMP,F3_ALQIMP,F3_VALIMP,F3_RETIMP")) .AND. cNivel >= GetSx3Cache(cField, "X3_NIVEL")
				Aadd( aLivrEnc, RTrim(cField) )
			EndIf
		Next nX
	EndIf

Return aLivrEnc
