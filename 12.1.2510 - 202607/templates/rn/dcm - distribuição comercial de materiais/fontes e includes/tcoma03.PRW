#INCLUDE "tcoma03.ch"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TCOMA03   º Autor ³EWERTON CARLOS TOMAZº Data ³  24/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para trazer os produtos em ponto de pedido no       º±±
±±º          ³ pedido de compras                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Compras                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Template Function TCOMA03()

CHKTEMPLATE("DCM")  

_cRet := ''
If Inclui
   _n    := n
   If Empty(CA120FORN)
      MsgBox(STR0001,STR0002) //"Preencha o campo com Codigo do Fornecedor !!!"###"Atencao"
     Return
   Endif
   SetKey(120 , )
   Processa( {|| RunProc() } )
   SetKey(120 , { || T_TCOMA03() } ) // F9 chama produto em ponto de pedido
   n     := _n
Else     

Endif

Return _cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunProc   º Autor ³EWERTON CARLOS TOMAZº Data ³  24/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Executa o processo para trazer os produto de ponto de      º±±
±±º          ³ no pedido de compras	                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 			                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunProc()

Local cLocCQ	:= GetMV("MV_CQ")
Local nQuant := nSaldo := 0 ,nValUnit ,nValor ,nValTot ,cTipoVal ,nPrazo
Local nToler, nEstSeg, nNeces ,_nConta := 0
Local _aProds := {}
Local cAlias := Alias()
Local nIndex := IndexOrd()
Local lTemPP := .F.
Local _cReadVar := ReadVar()
Local nX
Local I

//³ mv_par01             // Produto de                           ³
//³ mv_par02             // Produto ate                          ³
//³ mv_par03             // Grupo de                             ³
//³ mv_par04             // Grupo ate                            ³
//³ mv_par05             // Tipo de                              ³
//³ mv_par06             // Tipo ate                             ³
//³ mv_par07             // Local de                             ³
//³ mv_par08             // Local ate                            ³
//³ mv_par09             // Considera Necess Bruta   1 - Sim     ³ Pto Pedido
//³ mv_par10             // Saldo Neg Considera      1 - Sim     ³ Lote Economico
//³ mv_par11             // Considera C.Q.           1 - Sim     ³


_MV_ORI01 := MV_PAR01
_MV_ORI02 := MV_PAR02
_MV_ORI03 := MV_PAR03
_MV_ORI04 := MV_PAR04
_MV_ORI05 := MV_PAR05
_MV_ORI06 := MV_PAR06
_MV_ORI07 := MV_PAR07

If !Pergunte(Padr('MTR440',Len(SX1->X1_GRUPO)) ,.T.)
	MV_PAR01 := _MV_ORI01
	MV_PAR02 := _MV_ORI02
	MV_PAR03 := _MV_ORI03
	MV_PAR04 := _MV_ORI04
	MV_PAR05 := _MV_ORI05
	MV_PAR06 := _MV_ORI06
	MV_PAR07 := _MV_ORI07
	_nn := (iif(Len(aCols)=1,1,Len(aCols)+1))
	PreparaAcols(_nn)
	DbSelectArea(cAlias)
	DbSetOrder(nIndex)
	Return( _cReadVar )     //M->C7_PRODUTO
Endif

If MsgBox(STR0003,STR0004,"YESNO") //"Deseja utilizar Amarracao Produto x Fornecedor ?"###"Amarracao ProdutoxFornecedor"
	dBSelectArea("SA5")
	dBSetOrder(1)
	dBGoTop()
	If dBSeek(xFilial("SA5")+CA120FORN,.F.)
		While !Eof() .And. SA5->A5_FORNECE == CA120FORN
			AaDd(_aProds,SA5->A5_PRODUTO)
			_nConta ++
			DbSkip()
		EndDo
	Endif
Else
	DbSelectArea('SB1')
	dBSetOrder(1)
	dBGoTop()
	While !Eof() //.and. SB1->B1_PROC = CA120FORN .AND. _NCONTA <= 98
		AaDd(_aProds,SB1->B1_COD)
		_nConta ++
		DbSkip()
	EndDo
Endif

If _aProds == Nil .Or. Len(_aProds) <= 0
	DbSelectArea(cAlias)
	DbSetOrder(nIndex)
	Return( _cReadVar )     //M->C7_PRODUTO
Endif

/*
DbSelectArea('SB1')
DbSetOrder(6)
If !DbSeek(xFilial('SB1')+CA120FORN)
PreparaAcols(1)
DbSelectArea(cAlias)
DbSetOrder(nIndex)
Return M->C7_PRODUTO
Endif

While !Eof() //.and. SB1->B1_PROC = CA120FORN .AND. _NCONTA <= 98
AaDd(_aProds,SB1->B1_COD)
_nConta ++
DbSkip()
EndDo
*/

_nPosIte  := aScan(aHeader,{|e|Trim(e[2])=='C7_ITEM' })
_nPosCod  := aScan(aHeader,{|e|Trim(e[2])=='C7_PRODUTO' })
_nPosDesc := aScan(aHeader,{|e|Trim(e[2])=='C7_DESCRI' })
_nPosUni  := aScan(aHeader,{|e|Trim(e[2])=='C7_UM' })
_nPosQtd  := aScan(aHeader,{|e|Trim(e[2])=='C7_QUANT' })
_nPosPrc  := aScan(aHeader,{|e|Trim(e[2])=='C7_PRECO' })
_nPosTot  := aScan(aHeader,{|e|Trim(e[2])=='C7_TOTAL' })
_nPosFlu  := aScan(aHeader,{|e|Trim(e[2])=='C7_FLUXO' })
_nPosPen  := aScan(aHeader,{|e|Trim(e[2])=='C7_PENDEN' })
_nPosKFOR := aScan(aHeader,{|e|Trim(e[2])=='C7_NREDUZ'})

ProcRegua(_nConta)

nProcesso := 0
For I := 1 To Len(_aProds)
	DbSelectArea('SB1')
	DbSetOrder(1)
	DbSeek(xFilial('SB1')+_aProds[I])
	IncProc(_aProds[I]+' - '+SUBSTR(SB1->B1_DESC,1,25))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra grupos e tipos nao selecionados e tambem se for MOD³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  B1_GRUPO < mv_par03 .Or. B1_GRUPO > mv_par04 .Or.;
		B1_TIPO  < mv_par05 .Or. B1_TIPO  > mv_par06 .Or.;
		SubStr(B1_COD,1,3) == "MOD" .Or. B1_TIPO == "BN" .Or.;
		B1_CONTRAT == "S"
		Loop
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Direciona para funcao que calcula o necessidade de compra ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o saldo atual de todos os almoxarifados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SB2")
	dbSeek(xFilial('SB2')+SB1->B1_COD )
	While !Eof() .And. SB2->B2_FILIAL == xFilial('SB2') .AND. SB2->B2_COD == SB1->B1_COD
		If B2_LOCAL < mv_par07 .Or. B2_LOCAL > mv_par08
			dbSkip()
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ inclui os produtos que estao no C.Q.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If B2_LOCAL == cLocCQ .And. mv_par11 == 2
			dbSkip()
			Loop
		Endif
		nSaldo += (SaldoSB2()+B2_SALPEDI)-B2_QPEDVEN
		dbSkip()
	EndDo
	nEstSeg := CalcEstSeg( SB1->B1_ESTFOR )
	nSaldo -= nEstSeg
	If (Round(nSaldo,4) # 0) .Or. (mv_par09 == 1)
		Do Case
			Case ( SB1->B1_EMIN != 0 .And. MV_PAR09 == 1 )
				nNeces := If((nSaldo < 0),Abs(nSaldo)+SB1->B1_EMIN,(SB1->B1_EMIN-nSaldo))
			Case ( SB1->B1_EMIN != 0 .And. MV_PAR09 == 2 )
				nNeces := If((nSaldo < 0),Abs(nSaldo),(SB1->B1_EMIN-nSaldo))
			Case ( SB1->B1_LE != 0 .And. (nSaldo < 0  .or. mv_par09 == 2) )
				If ( MV_PAR10 == 2 .And. nSaldo < 0 )
					nNeces := Abs(nSaldo)+SB1->B1_LE
				Else
					nNeces := If( Abs(nSaldo)<SB1->B1_LE,SB1->B1_LE,if(nSaldo<0,Abs(nSaldo),0))
				EndIf
			OtherWise
				nNeces := IF(MV_PAR09 == 1,IIf(nSaldo<0,Abs(nSaldo),0),0)
		EndCase
	Else
		If SB1->B1_EMIN != 0
			nNeces := ( SB1->B1_EMIN )
		Else
			nNeces := 0
		Endif
	EndIf
	If nNeces > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o produto tem estrutura                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SG1")
		If dbSeek( xFilial("SG1")+SB1->B1_COD )
			aQtdes := CalcLote(SB1->B1_COD,nNeces,"F")
		Else
			aQtdes := CalcLote(SB1->B1_COD,nNeces,"C")
		Endif
		For nX := 1 to Len(aQtdes)
			nQuant += aQtdes[nX]
		Next
	EndIf
	dbSelectArea("SB1")
	If nQuant > 0
		nProcesso++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega o prazo de entrega do material         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPrazo := CalcPrazo(SB1->B1_COD,nQuant)
		dbSelectArea("SB1")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula a tolerancia do item                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nToler   := (B1_LE * B1_TOLER)/100
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica qual dos precos e' mais recente servir de base ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValor := 0
		nTotal := 0
		dbSelectArea("LH7")
		DbSetOrder(1)
		If DbSeek(xFilial('LH7')+_aProds[I])
			cTipoVal := "POL"
			dData    := dDataBase
			nValor   := LH7_PRC
		ElseIf SB1->B1_UCOM < SB1->B1_DATREF
			cTipoVal := "STD"
			dData    := SB1->B1_DATREF
			nValor   := SB1->B1_CUSTD
		Else
			cTipoVal := "U.CO"
			dData    := SB1->B1_UCOM
			nValor   := SB1->B1_UPRC
		EndIf
		nTotal := nQuant * nValor
		dbSelectArea("SB1")
		
		If nProcesso > 1
			AADD(aCols,Array(Len(aHeader)+1))
			n := Len(aCols)
			PreparaAcols(n)
		Endif
		
		RegToMemory("SC7",.T.)
		aCols[n,_nPosIte]  := StrZero(n,4)
		M->C7_PRODUTO := aCols[n,_nPosCod]  := B1_COD
		M->C7_QUANT   := aCols[n,_nPosQtd]  := nQuant
		M->C7_PRECO   := aCols[n,_nPosPrc]  := nValor
		_MV_01 := MV_PAR01
		_MV_02 := MV_PAR02
		_MV_03 := MV_PAR03
		_MV_04 := MV_PAR04
		_MV_05 := MV_PAR05
		_MV_06 := MV_PAR06
		_MV_07 := MV_PAR07
		MV_PAR01 := _MV_ORI01
		MV_PAR02 := _MV_ORI02
		MV_PAR03 := _MV_ORI03
		MV_PAR04 := _MV_ORI04
		MV_PAR05 := _MV_ORI05
		MV_PAR06 := _MV_ORI06
		MV_PAR07 := _MV_ORI07
		lAP := .T.
		A120Produto(M->C7_PRODUTO)
		MaFisRef("IT_PRODUTO","MT120",M->C7_PRODUTO)
		A120Quant(M->C7_QUANT)
		MaFisRef("IT_QUANT","MT120",M->C7_QUANT)
		A120Preco(M->C7_PRECO)
		MaFisRef("IT_PRCUNI","MT120",M->C7_PRECO)
		lAP := .F.
		MV_PAR01 := _MV_01
		MV_PAR02 := _MV_02
		MV_PAR03 := _MV_03
		MV_PAR04 := _MV_04
		MV_PAR05 := _MV_05
		MV_PAR06 := _MV_06
		MV_PAR07 := _MV_07
		aCols[n,_nPosDesc] := B1_DESC
		aCols[n,_nPosUni]  := B1_UM
		aCols[n,_nPosQtd]  := nQuant
		aCols[n,_nPosPrc]  := nValor
		aCols[n,_nPosTot]  := nTotal
		aCols[n,_nPosFlu]  := 'S'
		aCols[n,_nPosPen]  := 'S'
		aCols[n,_nPosKFOR] := SA2->A2_NREDUZ
		
		lTemPP := .T.
		// *** Executa gatilhos dos campos
		aOrd := SaveOrd("SX7",1)
		SX7->(dBGoTop())
		SX7->(dbSeek("C7_"))
		While "C7_"$SX7->X7_CAMPO
			If ALLTRIM(SX7->X7_CAMPO)$"C7_QTSEGUM#C7_SEGUM" .Or.;
				(ALLTRIM(SX7->X7_CAMPO)="C7_PRODUTO" .And. ALLTRIM(SX7->X7_REGRA) = 'T_CONSULSD("P")')
				SX7->(dbSkip())
				Loop
			Endif
			cRegra := ALLTRIM(SX7->X7_REGRA)
			_nPosCampo := aScan(aHeader,{|e|Trim(e[2])==AllTrim(SX7->X7_CDOMIN)})
			x:=&cRegra
			aCols[n,_nPosCampo]  := x
			SX7->(dbSkip())
		Enddo
		RestOrd(aOrd)
	Endif
	nSaldo := 0
	nQuant := 0
	dbSelectArea("SB1")
Next I

MV_PAR01 := _MV_ORI01
MV_PAR02 := _MV_ORI02
MV_PAR03 := _MV_ORI03
MV_PAR04 := _MV_ORI04
MV_PAR05 := _MV_ORI05
MV_PAR06 := _MV_ORI06
MV_PAR07 := _MV_ORI07

DbSelectArea(cAlias)
DbSetOrder(nIndex)

_cRet := ''

If !lTemPP
	Alert(STR0005) //'Nao existem produtos em ponto de pedido para este fornecedor !!!'
	PreparaAcols(n)
Else
	If Len(_aProds) > 0
		//_cRet := _aProds[1]
	Else
		//_cRet := M->C7_PRODUTO
	Endif
Endif
Return(_cRet)

Static Function PreparaAcols(nPos)
Local i2

For i2:=1 to Len(aHeader)
	cCampo:=Alltrim(aHeader[i2,2])
	If aHeader[i2,10] # "V"
		IF aHeader[i2,8] == "C"
			If cCampo == "C7_ITEM"
				aCOLS[nPos][i2] := Repl("0",aHeader[i2,4]-1)+"1"
			Else
				aCOLS[nPos][i2] := SPACE(aHeader[i2,4])
			EndIf
		ElseIf aHeader[i2,8] == "N"
			aCOLS[nPos][i2] := 0
		ElseIf aHeader[i2,8] == "D"
			aCOLS[nPos][i2] := dDataBase
		ElseIf aHeader[i2,8] == "M"
			aCOLS[nPos][i2] := ""
		Else
			aCOLS[nPos][i2] := .F.
		EndIf
	Else
		aCols[nPos][i2] := CriaVar(cCampo)
	Endif
Next i2
aCOLS[nPos][Len(aHeader)+1] := .F.
Return
