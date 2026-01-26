#INCLUDE "tfatr01.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TFATR01  ³ Autor ³ EWERTON C TOMAZ       ³ Data ³ 07.06.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relacao de Pedidos aptos a faturar                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function Tfatr01(nOpcImp,aPedLib,cNotaEnt,cSerEnt,cFornec,cLojaFor)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local CbTxt
Local CbCont
Local cabec1
Local cabec2
Local wnrel
Local titulo      := OemToAnsi(STR0001) //"Pedidos de Vendas"
Local cDesc1      := OemToAnsi(STR0002) //"Este programa ira emitir a relacao  dos Pedidos de Vendas"
Local cDesc2      := OemToAnsi(STR0003) //"Sera feita a pesquisa no almoxarifado e verificado"
Local cDesc3      := OemToAnsi(STR0004) //"se a quantidade esta disponivel"
Local Tamanho     := "P"
Local limite      := 80
Local cString     := "SC6"
Local lContinua   := .T.
Local aOrd        := {}

PRIVATE aReturn   := {STR0005, 1,STR0006, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE nomeprog  := "RFATR01"
PRIVATE aLinha    := { }
PRIVATE nLastKey  := 0
PRIVATE cPerg     := Padr("TFATR1",Len(SX1->X1_GRUPO))
PRIVATE cNotaEntP := cNotaEnt
PRIVATE cSerEntP  := cSerEnt
PRIVATE cFornecP  := cFornec
PRIVATE cLojaForP := cLojaFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcImp <> 4
	SA3->(DbSetOrder(2))
	SA3->(MsSeek(XFILIAL("SA3")+ Upper(cUserName) ))
	cPar	:= "PD"+StrZero(SA3->(Recno()),4)
	T_ValPergUsu("TFATR1",cPar)
	cPerg	:= Padr(cPar,Len(SX1->X1_GRUPO))
	Pergunte(cPerg,.F.)
Else
	Pergunte(Padr("TFATR1",Len(SX1->X1_GRUPO)) ,.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                            ³
//³ mv_par01        	// Do Pedido                                ³
//³ mv_par02        	// Ate o Pedido                             ³
//³ mv_par03        	// Do Produto                               ³
//³ mv_par04 	     	// Ate o Produto                            ³
//³ mv_par05 	     	// Mascara                                  ³
//³ mv_par06 	     	// Aptos a Faturar Nao Aptos Todos          ³
//³ mv_par07 	     	// Soma Ipi ao Tot Sim Nao                  ³
//³ mv_par08 	     	// Qual moeda                               ³
//³ mv_par09 	     	// Quanto ao Tes- Gera Dupl, Nao Gera, Todos³
//³ mv_par10 	     	// Liberado de                              ³
//³ mv_par11 	     	// Liberado Ate                             ³
//³ mv_par12 	     	// Vendedor                                 ³
//³ mv_par13 	     	// Cliente                                  ³
//³ mv_par14 	     	// Loja                                     ³
//³ mv_par15 	     	// NFE de Liberacao                         ³
//³ mv_par16 	     	// Serie NFE                                ³
//³ mv_par17 	     	// Fornecedor de Liber.                     ³
//³ mv_par18 	     	// Loja                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := "RFATR01"

DbSelectArea("SC6")
wnrel := SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

If nLastKey == 27
	DbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	DbClearFilter()
	Return
Endif

RptStatus({|lEnd| C700Imp(@lEnd,wnRel,cString,nOpcImp,aPedLib,cNotaEntP,cSerEntP,cFornecP,cLojaForP)},Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C700IMP  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR700			                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C700Imp(lEnd,WnRel,cString,nOpcImp,aPedLib,cNotaEnt,cSerEnt,cFornec,cLojaFor)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _nFil
Local _nX
Local CbTxt
Local CbCont
Local cabec1
Local cabec2
Local titulo     := OemToAnsi(STR0001) //"Pedidos de Vendas"
Local cDesc1     := OemToAnsi(STR0002) //"Este programa ira emitir a relacao  dos Pedidos de Vendas"
Local cDesc2     := OemToAnsi(STR0003) //"Sera feita a pesquisa no almoxarifado e verificado"
Local cDesc3     := OemToAnsi(STR0004) //"se a quantidade esta disponivel"
Local tamanho    := "P"
Local limite     := 80
Local lContinua  := .T.
Local nAc1       := 0
Local nAc2       := 0
Local nTipo      := SuperGetMv("MV_COMP")
Local cPedant
Local nValIPI    := 0
Local nTotIPI    := 0
Local cDescOrdem := ""
Local lFirst
Local lImp       := .F.
Local cTipo      := ""
Local nC		   := 1
Local nQtBloq    := 0
Local aQuant     := {}
Local nVend      := Fa440cntVen()
Local _cFiltro   := ''
Local _nRecno    := 0
Local _nXPed     := 0

PRIVATE ImpQuem  := ''
PRIVATE nQtLib   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CbTxt    := SPACE(10)
CbCont   := 0
li       := 80
m_Pag    := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabelho do relatorio                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SC6")
nOpcImp := IIF(nOpcImp == Nil, 5, nOpcImp)
If nOpcImp = 1
	MV_PAR01 := ''
	MV_PAR02 := 'ZZZZZZ'
	MV_PAR03 := ''
	MV_PAR04 := 'ZZZZZZZZZZZZZZZ'
	MV_PAR06 := 1
	MV_PAR12 := ''
	MV_PAR13 := ''
	MV_PAR14 := ''
	MV_PAR15 := cNotaEnt
	MV_PAR16 := cSerEnt
	MV_PAR17 := cFornec
	MV_PAR18 := cLojaFor
	Titulo   := 'MATERIAIS RECEBIDOS'
	ImpQuem  := 'M.RECEBIDO'
ElseIf nOpcImp = 2
	MV_PAR01 := ''
	MV_PAR02 := 'ZZZZZZ'
	MV_PAR03 := ''
	MV_PAR04 := 'ZZZZZZZZZZZZZZZ'
	MV_PAR06 := 1
	MV_PAR12 := ''
	MV_PAR13 := ''
	MV_PAR14 := ''
	MV_PAR15 := ''
	MV_PAR16 := ''
	MV_PAR17 := ''
	MV_PAR18 := ''
	Titulo   := 'PEDIDOS'
	ImpQuem  := 'VENDEDOR'
ElseIf nOpcImp = 3
	MV_PAR01 := ''
	MV_PAR02 := 'ZZZZZZ'
	MV_PAR03 := ''
	MV_PAR04 := 'ZZZZZZZZZZZZZZZ'
	MV_PAR06 := 2
	MV_PAR12 := ''
	MV_PAR13 := ''
	MV_PAR14 := ''
	MV_PAR15 := ''
	MV_PAR16 := ''
	MV_PAR17 := ''
	MV_PAR18 := ''
	Titulo   := 'PEDIDOS'
	ImpQuem  := 'VENDEDOR'
ElseIf nOpcImp = 4
	Titulo   := 'PEDIDOS'
	ImpQuem  := 'ROMANEIO'
Else
	Titulo := 'PEDIDOS'
	ImpQuem := 'SISTEMA'
	aPedLib := If(TYPE("aPedLib") = "U", {}, aPedLib)
Endif

If !( Empty(MV_PAR15) ) .AND. Empty(MV_PAR01)
	cQueryCad := ""
	cQueryCad := "SELECT DISTINCT C9_PEDIDO From "+RetSqlName('SC9')+"  WHERE C9_BLEST = ' ' AND "
	cQueryCad += " C9_NFENT = '"+MV_PAR15+"'"
	If !( Empty(MV_PAR16) )
		cQueryCad += " AND C9_SERENT = '"+MV_PAR16+"'"
	Endif
	If !( Empty(MV_PAR17) )
		cQueryCad += " AND C9_FORNEC = '"+MV_PAR17+"'"
	Endif
	If !( Empty(MV_PAR18) )
		cQueryCad += " AND C9_LOJAFOR = '"+MV_PAR18+"'"
	EndIf
	cQueryCad += " ORDER BY C9_PEDIDO"
	TCQUERY cQueryCad NEW ALIAS "NFLIB"
	DbSelectArea("NFLIB")
	While NFLIB->(! Eof())
		If AsCan(aPedLib,NFLIB->C9_PEDIDO) = 0
			AaDd(aPedLib,NFLIB->C9_PEDIDO)
		EndIf
		NFLIB->(DbSkip())
	End
	_cFiltro := "C6_NUM $ '"
	For _nFil := 1 To Len(aPedLib)
		_cFiltro += aPedLib[_nFil]+'/'
	Next _nFil
	_cFiltro += "'"
	NFLIB->(DbCloseArea())
	DbSelectArea("SC6")
	IndRegua('SC6', CriaTrab(,.f.), "C6_FILIAL+C6_NUM", , _cFiltro, 'Selecionando registros')
	SC6->(DbGoTop())
EndIf
If Len(aPedLib) > 0
	ASort(aPedLib)
	MV_PAR01 := aPedLib[1]
	MV_PAR02 := aPedLib[Len(aPedLib)]
	MV_PAR10 := dDataBase
	MV_PAR11 := dDataBase
	_cFiltro := "'"
	For _nFil := 1 To Len(aPedLib)
		_cFiltro += aPedLib[_nFil]+'/'
	Next _nFil
	_cFiltro += "'"
EndIf

cDescOrdem:= STR0007 //"PEDIDO"
cCond := "SC6->C6_NUM <= MV_PAR02"
If MV_PAR06 == 1
	cTipo := STR0008 //" APTOS A FATURAR (Estoque) "
ElseIf MV_PAR06 == 2
	cTipo := STR0009 //" NAO LIBERADOS (Estoque)   "
Else
	cTipo := STR0010 //" (TODOS ITENS) "
EndIf
Titulo := Titulo + cTipo
_cTitOri := titulo

DbSelectArea("SC6")
DbSetOrder(1)
SetRegua(RecCount())		// Total de Elementos da regua
MsSeek(xFilial("SC6")+MV_PAR01,.T.)
While SC6->(! Eof()) .AND. xFilial("SC6") == SC6->C6_FILIAL .AND. lContinua .AND. &cCond
	IncRegua()
	If lEnd
		@ Prow()+1,001 Psay STR0011 //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	EndIf
	
	If !( Empty(MV_PAR13) ) .AND. ( (SC6->C6_CLI <> MV_PAR13) .OR. ((SC6->C6_CLI = MV_PAR13 .AND. SC6->C6_LOJA <> MV_PAR14)) )
		SC6->(DbSkip())
		Loop
	EndIf
	
	If MV_PAR06 <> 3 .AND. (SC6->C6_QTDVEN - SC6->C6_QTDENT) == 0
		SC6->(DbSkip())
		Loop
	EndIf
	
	If (SC6->C6_NUM < MV_PAR01 .OR. SC6->C6_NUM > MV_PAR02)
		SC6->(DbSkip())
		Loop
	EndIf

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5") + SC6->C6_NUM))
	If !( Empty(MV_PAR12) ) .AND. (SC5->C5_VEND1 <> MV_PAR12)
		SC6->(DbSkip())
		Loop
	EndIf
	
	If nOpcImp == 4 .AND. !( Empty(_cFiltro) ) .AND. !(SC6->C6_NUM $ _cFiltro)
		dbSkip()
		Loop
	EndIf
	
	_nNumCopias := Posicione('SA1',1,xFilial('SA1')+SC6->C6_CLI+SC6->C6_LOJA,'A1_NUMCPED')
	_nNumCopias := IIF((_nNumCopias > 0 .AND. nOpcImp >= 4), _nNumCopias, 1)
	_nNumCop2   := 0
	_nNumCopTo  := _nNumCopias

	_lTemRom    := .F.
	_cNumReqOrc := ""
	_cNumOrc    := ""

	SUA->(DbSetOrder(8))
	If	SUA->( DbSeek(xFilial('SUA')+SC6->C6_NUM) ) .AND. !( Empty(SUA->UA_NUM) )
		_cNumOrc    := SUA->UA_NUM
		LHA->(DbSetOrder(4))
		If LHA->(MsSeek(xFilial('LHA') + _cNumOrc)) .AND. LHA->LHA_CLIENTE == SC6->C6_CLI 
			_cNumReqOrc := LHA->LHA_NUMREQ
		Endif
		If !( Empty(_cNumReqOrc) ) .AND. nOpcImp >= 4
			_cQueryCad   := "SELECT COUNT(DISTINCT LHA_NUMREQ+LHA_CODREQ) AS TOTAL FROM "+RetSqlName("LHA")+" WHERE LHA_FILIAL = '"+xFilial("LHA")+"' AND D_E_L_E_T_ = ' ' AND LHA_NUMREQ = '"+_cNumReqOrc+"' "
			TCQuery _cQueryCad NEW ALIAS "CAD"
			_nNumCop2    := _nNumCopias + 1
			_nNumCopTo   := ( _nNumCopias * CAD->TOTAL ) + 1
			_nNumCopias  := _nNumCop2
			CAD->(DbCloseArea())
			_lTemRom     := .T.
		Endif
	EndIf

	DbSelectArea('SC6')
	_nRecno  := SC6->(Recno())
	For _nXPed := 1 To _nNumCopias
		
		If _nXPed > 1
			DbSelectArea("SC6")
			DbGoTo(_nRecno)
			titulo := 'ROMANEIO DE ENTREGA'
		Else
			titulo := _cTitOri
		Endif
		
		_aItens := {}
		
		If nOpcImp == 1
			DbSelectArea('SC9')
			DbSetOrder(1)
			If MsSeek(xFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM)
				_lCont := .F.
				While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM
					If Empty(SC9->C9_NFENT) .OR.;
					   !( SC9->C9_NFENT == MV_PAR15 .AND.;
					      SC9->C9_SERENT == MV_PAR16 .AND.;
					      Alltrim(SC9->C9_FORNEC) == Alltrim(MV_PAR17) .AND.;
					      Alltrim(SC9->C9_LOJAFOR) == Alltrim(MV_PAR18))
						DbSkip()
						Loop
					Endif
					If MV_PAR06 == 1 .AND. Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_NFISCAL)
						_lCont := .T.
					Endif
					DbSkip()
				EndDo
				DbSelectArea('SC6')
				If !( _lCont )
					DbSkip()
					//Loop - Tirado por causa do For
					Exit
				Endif
			Else
				DbSelectArea('SC6')
				DbSkip()
				//Loop - Tirado por causa do For
				Exit
			Endif
		ElseIf nOpcImp == 2 .OR. nOpcImp == 3
			DbSelectArea('SC9')
			DbSetOrder(1)
			If MsSeek(xFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM)
				_lCont := .F.
				While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9")  .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM
					If MV_PAR06 == 1 .AND. Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_NFISCAL)
						_lCont := .T.
					ElseIf MV_PAR06 == 2 .AND. SC9->C9_BLEST == '02'
						_lCont := .T.
					Endif
					DbSkip()
				EndDo
				DbSelectArea('SC6')
				If !( _lCont )
					DbSkip()
					//Loop - Tirado por causa do For
					Exit
				Endif
			Else
				DbSelectArea('SC6')
				DbSkip()
				//Loop - Tirado por causa do For
				Exit
			Endif
		ElseIf nOpcImp == 4
			DbSelectArea('SC9')
			DbSetOrder(1)
			If MsSeek(xFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM)
				_lCont := .F.
				While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM
					If MV_PAR06 == 1 .AND. Empty(SC9->C9_BLEST) .AND. Empty(SC9->C9_NFISCAL)
						_lCont := .T.
					ElseIf MV_PAR06 == 2 .AND. SC9->C9_BLEST == '02'
						_lCont := .T.
					ElseIf MV_PAR06 == 3 .AND. SC9->C9_BLEST <> '10'
						_lCont := .T.
					Endif
					DbSkip()
				End
				DbSelectArea('SC6')
				If !( _lCont )
					DbSkip()
					//Loop - Tirado por causa do For
					Exit
				Endif
			Else
				DbSelectArea('SC6')
				DbSkip()
				//Loop - Tirado por causa do For
				Exit
			Endif
		EndIf
		DbSelectArea("SC6")

		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o pedido de venda esta apto a faturar(nQtLib<>0) ³
		//³ ou com bloqueio(nQtBloq<>0) , conforme o parametro MV_PAR06  ³
		//³ seleciona os reguistros a serem impressos                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aQuant := a700Bloq(nOpcImp)
		For nC := 1 To Len(aQuant)
			nQtlib  += aQuant[nC,2]
			nQtBloq += aQuant[nC,3]
		Next nC
		
		DbSelectArea("SC6")
		If MV_PAR06 == 1 .AND. nQtLib == 0
			nAc1   := nAc2    := nValIPI := nTotIPI := 0
			nQtlib := nQtBloq := 0
			DbSkip()
			Exit
		ElseIf MV_PAR06 == 2 .AND. nQtBloq == 0
			nAc1   := nAc2    := nValIPI := nTotIPI := 0
			nQtlib := nQtBloq := 0
			DbSkip()
			Exit
		Else
			nAc1   := nAc2    := nValIPI := nTotIPI := 0
			nQtlib := nQtBloq := 0
		Endif
		
		cPedant := SC6->C6_NUM
		lFirst  := .T.
		
		DbSelectArea("SC6")
		While SC6->(! Eof()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == cPedant .AND. lContinua
			IncRegua()
			If lEnd
				@ Prow()+1,001 Psay STR0011 //"CANCELADO PELO OPERADOR"
				lContinua := .F.
				Exit
			EndIf
			
			If SC6->C6_PRODUTO < MV_PAR03 .OR. SC6->C6_PRODUTO > MV_PAR04
				DbSkip()
				Loop
			EndIf
			
			If nOpcImp == 4 .AND. !( Empty(_cFiltro) ) .AND. !(SC6->C6_NUM $ _cFiltro)
				DbSkip()
				Loop
			Endif
			
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek (xFilial("SF4")+SC6->C6_TES)
			DbSelectArea("SC6")
			If ( SF4->F4_DUPLIC == "S" .AND. MV_PAR09 == 2 ) .OR. ( SF4->F4_DUPLIC <> "S" .AND. MV_PAR09 == 1 )
				DbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o pedido de venda esta apto a faturar(nQtLib<>0) ³
			//³ ou com bloqueio(nQtBloq<>0) , conforme o parametro MV_PAR06  ³
			//³ seleciona os reguistros a serem impressos                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aQuant      := a700Bloq(nOpcImp)
			_cLibCrePre := ""
			For nC := 1 To Len(aQuant)
				nQtlib      += aQuant[nC,2]
				nQtBloq     += aQuant[nC,3]
				_cLibCrePre := If(!( Empty(aQuant[nC,4]) ),'C','.') + If(Empty(aQuant[nC,5]), 'P', '.')
			Next nC
			DbSelectArea("SC6")
			If MV_PAR06 == 1 .AND. nQtLib == 0
				nQtlib := nQtBloq := 0
				dbSkip()
				Loop
			ElseIf MV_PAR06 == 2 .AND. nQtBloq == 0
				nQtlib := nQtBloq := 0
				DbSkip()
				Loop
			EndIf
			If nOpcImp == 4 .AND. _cLibCrePre <> '..'
				nQtlib := nQtBloq := 0
				DbSkip()
				Loop
			EndIf
			
			If lFirst
				ImprPed(titulo,'','',nomeprog,tamanho,nTipo,nVend,nOpcImp,_nXPed)
				lFirst := .F.
			EndIf
			
			If li > 58
				cabec(titulo,'','',nomeprog,tamanho,nTipo)
				ImprPed(titulo,'','',nomeprog,tamanho,nTipo,nVend,nOpcImp,_nXPed)
			EndIf
			
			lImp := .T.
			
			ImpProd(titulo, '', '', nomeprog, tamanho, nTipo, nQtLib, nQtBloq, Alltrim(_cLibCrePre), nOpcImp, _nXPed)
			
			nAc1   += CalValFat(If(MV_PAR06 == 1, nQtlib, If(MV_PAR06 == 2, nQtBloq, (nQtLib + nQtBloq))))
			nQtlib := nQtBloq := 0
			
			//		li++
			DbSelectArea("SC6")
			DbSkip()
		EndDo
		
		If li > 58
			cabec(titulo,'','',nomeprog,tamanho,nTipo)
			@li,  0 Psay STR0012+SC5->C5_NUM //"PEDIDO: "
			li++
			@li,  0 Psay STR0013 + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40) //"CLIENTE : "
			@li, 71 Psay STR0014+Alltrim(Str(_nXPed,1))+"/"+Alltrim(Str(_nNumCopTo,1)) //"VIAS: "
			li += 2
		EndIf
		
		If lImp
			
			ImpProd2(titulo,'','',nomeprog,tamanho,nTipo,nOpcImp,_nXPed )
			_aItens := {}
			@li,  0 Psay STR0015 //"TOTAL DO PEDIDO--> "
			@li, 68 Psay xMoeda(nAc1, SC5->C5_MOEDA, MV_PAR08, SC5->C5_EMISSAO) PicTure "@ER 9,999,999.99" //tm(nAc1,12)
			If li+6 > 58
				cabec(titulo,'','',nomeprog,tamanho,nTipo)
				@li,  0 Psay STR0012+SC5->C5_NUM //"PEDIDO: "
				li++
				@li,  0 Psay STR0013 + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40) //"CLIENTE : "
				@li, 71 Psay STR0014+Alltrim(Str(_nXPed,1))+"/"+Alltrim(Str(_nNumCopTo,1)) //"VIAS: "
				li += 2
			EndIf
			If nOpcImp <> 1 .AND. nOpcImp <> 4
				li++
				@li, 0 Psay Replicate('-',80)
				li += 2
				@li,50 Psay Replicate('_',30)
				++li
				@li,50 Psay SubStr(R700Vend(nVend),1,30)
			Endif
			DbSelectArea('SC6')
			li += 2
			@li, 0 Psay Replicate('-',80)
			li += 2
			@li, 0 Psay 'Separador.:________________________'
			@li,40 Psay 'Setor/Zona.......:______________________'
			li += 2
			@li, 0 Psay 'Conferente:________________________'
			@li,40 Psay 'Numero de Volumes:______________________'
			li += 2
			@li, 0 Psay 'Peso......:________________________'
			@li,40 Psay 'Cubagem..........:______________________'
			li += 2
			If  _nXPed > 1
				@li, 0 Psay 'Cliente...:________________________'
				li += 2
			Endif
			If li+6 > 58
				cabec(titulo,'','',nomeprog,tamanho,nTipo)
				@li,  0 Psay STR0012+SC5->C5_NUM //"PEDIDO: "
				li++
				@li,  0 Psay STR0013 + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40) //"CLIENTE : "
				@li, 71 Psay STR0014+Alltrim(Str(_nXPed,1))+"/"+Alltrim(Str(_nNumCopTo,1)) //"VIAS: "
				li += 2
			EndIf
			@li, 0 Psay Replicate('-',80)
			li++

			@li, 0 Psay 'Observacoes:'
			_cCompObs := AllTrim(MSMM(SUA->UA_CODOBS,TamSX3("UA_OBS")[01]))

			DbSelectArea('SC6')
			If SA1->A1_MENSAGE == "BLT"
				If !( Empty(_cCompObs) )
					_cCompObs := _cCompObs + STR0016 //". ENVIAR BOLETO BANCARIO JUNTO COM A NOTA."
				Else
					_cCompObs := STR0017 //"ENVIAR BOLETO BANCARIO JUNTO COM A NOTA."
				EndIf
			EndIf
			//			If !Empty(SUA->UA_REFMOTO)
			//				@li,00 Psay 'REFERENCIA:'+SUA->UA_REFMOTO
			//				li+=2
			//			Endif
			_nLinhas := mlcount(_cCompObs,65)
			For _nX := 1 To _nLinhas
				@ Li,014 PSAY memoline(_cCompObs,65,_nX)
				LI++
			Next _nX
			LI++
			
			li   := 60
			If !_lTemRom
				Eject
			EndIf
			lImp := .F.
		EndIf
		
		If _lTemRom
			Exit
		EndIf
		DbSelectArea('SC6')
	Next _nXPed
	
	If _lTemRom
		ImpRomaneio(tamanho,ntipo)
	EndIf
	
	DbSelectArea('SC6')
EndDo

RetIndex("SC6")
DbSelectArea("SC6")
DbClearFilter()
DbSetOrder(1)

Set devi To Screen
If aReturn[5] = 1
	Set Printer To
	DbCommitAll()
	OursPool(wnrel)
EndIf
MS_FLUSH()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImprPed  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados do pedido de venda                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImprPed(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,nVend,nOpcImp,_nXPed)

Local 	_cLargx2On :=""
Local	_cLargx2Off:=""

If li > 58
	SetPrc(0,0)
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
EndIF

DbSelectArea("SC5")
DbSetOrder(1)
If DbSeek(xFilial("SC5")+SC6->C6_NUM)
	// Informar que o romaneio do pedido ja foi emitido por romaneio ou recebimento
	If (nOpcImp == 1 .OR. nOpcImp == 4) .AND. _nXPed == 1 
		_lPedAut := .F.
		If !Empty(Posicione('SU7', 1, xFilial('SU7')+SUA->UA_OPERADO, 'U7_POSTO'))
			If Posicione('SU0', 1, xFilial('SU0') + If(!( Empty(SA1->A1_GRUPOAT) ), SA1->A1_GRUPOAT, SU7->U7_POSTO), 'U0_PEDAUT') == 'S'
				_lPedAut := .T.
			EndIf
		EndIf	
		If !_lPedAut
			DbSelectArea("SC5")	
			RecLock('SC5',.f.)
			SC5->C5_NOTA := 'IMPROM'
			MsUnlock()
		Endif
	Endif
	
	@li,  0 Psay STR0018 + SC5->C5_NUM //"PEDIDO  : "
	@li, 20 Psay STR0019 + DTOC(SC5->C5_EMISSAO) //"EMISSAO : "
	If SUA->UA_NUMSC5 == SC5->C5_NUM
		@li, 64 Psay STR0020	 + SUA->UA_NUM //"ORCAMEN.: "
	Else
		If SC5->C5_NUM == Posicione('SUA',9,xFilial('SUA')+SC5->C5_NUM,'SUA->UA_NUMSC5')
			@li, 64 Psay STR0020	 + SUA->UA_NUM //"ORCAMEN.: "
		EndIf
	EndIf
	
	li += 2
	If SC5->C5_TIPO $ "BD"
		DbSelectArea("SA2")
		DbSetOrder(1)
		If MsSeek( xFilial("SA2")+SC5->C5_CLIENTE+SC6->C6_LOJA )
			@li,  0 Psay STR0021 + SA2->A2_COD+' - '+ Subs(SA2->A2_NOME,1,40) //"FORNECEDOR : "
			@li, 70 Psay STR0022 + SA2->A2_LOJA //"LOJA : "
			++li
			DbSelectArea('SA4')
			DbSetOrder(1)
			DbSeek(xFilial('SA4')+SC5->C5_TRANSP)
			@li,  0 Psay STR0023 +SC5->C5_TRANSP+'-'+SA4->A4_NREDUZ //"TRANSPORTADORA: "
			++li
			@li,  0 PSay STR0024 + R700Vend(nVend) //"VENDEDOR: "
			DbSelectArea('SE4')
			DbSetOrder(1)
			DbSeek(xFilial('SE4')+SC5->C5_CONDPAG)
			@li, 55 Psay STR0025 + SE4->E4_DESCRI //"COND.PGTO:  "
			li+=2
		EndIf
	Else
		DbSelectArea("SA1")
		DbSetOrder(1)
		If MsSeek( xFilial("SA1")+SC5->C5_CLIENTE+SC6->C6_LOJA )
			@li,  0 Psay STR0013 + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40) //"CLIENTE : "
			@li, 71 Psay STR0014+Alltrim(Str(_nXPed,1))+"/"+Alltrim(Str(_nNumCopTo,1)) //"VIAS: "
			++li
			@li,  0 Psay STR0026 + SA1->A1_NREDUZ //"NOME FANTASIA: "
			++li
			@li,  0 Psay STR0027 + "(" + SA1->A1_DDD + ") " + SA1->A1_TEL //"TELEFONE: "
			@li, 30 Psay STR0028 + SA1->A1_FAX //"FAX: "
			++li
			@li,  0 Psay STR0024 + R700Vend(nVend) //"VENDEDOR: "
			++li
			@li,  0 Psay STR0029 + SA1->A1_CONTATO //"RESPONSAVEL  : "
			If !( Empty(SA1->A1_SATIV1) )
				++li
				@li,  0 Psay STR0030 + SA1->A1_SATIV1 //"CLIENTE TIPO : "
			Endif
			li += 2
			If nOpcImp <> 1 .AND. nOpcImp <> 4
				DbSelectArea("LH2")
				DbSetOrder(5)
				If MsSeek( xFilial("LH2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC5->C5_CODREQ)
					@li,  0 Psay STR0031 + SC5->C5_REQCLI //"REQ.CLIENTE  : "
					++li
					@li,  0 Psay STR0032 + SC5->C5_NOMEREQ //"REQUISITANTE : "
					@li, 55 Psay STR0033 + LH2->LH2_CC //"CENTRO CUSTO : "
					++li
					@li,  0 Psay STR0034 + LH2->LH2_DESCRC //"DESCRICAO CC : "
					
					@li, 55 Psay STR0035 + LH2->LH2_TELEF //"TEL/RAMAL:"
					++li
					@li,  0 Psay SubStr(STR0036+ALLTRIM(SC5->C5_ENDENT)+; //"LOC. ENTREGA : "
					             If(!( Empty(SC5->C5_BAIRROE) ), " - "+ALLTRIM(SC5->C5_BAIRROE), '')+;
					             If(!( Empty(SC5->C5_MUNE) ), " - "+ALLTRIM(SC5->C5_MUNE), '')+;
					             If(!( Empty(SC5->C5_ESTE) ), " - "+ALLTRIM(SC5->C5_ESTE), '')+;
					             If(!( Empty(SC5->C5_CEPE) ), " - "+ALLTRIM(SC5->C5_CEPE), ''),1,80)
					li+=2
					@li,  0 Psay STR0037 + IIf(Empty(SC5->C5_ENDENT),SA1->A1_ENDENT,SA1->A1_END) //"ENDERECO : "
					@li, 55 Psay STR0038 + IIf(Empty(SC5->C5_BAIRROE),SA1->A1_BAIRROE,SA1->A1_BAIRRO) //"BAIRRO : "
					++li
					@li,  0 Psay STR0039 + IIf(Empty(SC5->C5_MUNE),SA1->A1_MUNE,SA1->A1_MUN) //"CIDADE   : "
					@li, 55 Psay STR0040 + IIf(Empty(SC5->C5_ESTE),SA1->A1_ESTE,SA1->A1_EST) //"UF : "
					@li, 65 Psay STR0041 + IIf(Empty(SC5->C5_CEPE),SA1->A1_CEPE,SA1->A1_CEP) //"CEP : "
					++li
					
					If !( Empty(LH2->LH2_REGIAO) )
						@li,  0 Psay STR0042 + _cLargx2On + LH2->LH2_REGIAO + _cLargx2Off //"REGIAO : "
						++li
					EndIf
				ElseIf !( Empty(SA1->A1_ENDENT) )
					@li,  0 Psay STR0037 + SA1->A1_ENDENT //"ENDERECO : "
					@li, 55 Psay STR0038 + SA1->A1_BAIRROE //"BAIRRO : "
					++li
					@li,  0 Psay STR0039 + SA1->A1_MUNE //"CIDADE   : "
					@li, 55 Psay STR0040 + SA1->A1_ESTE //"UF : "
					@li, 65 Psay STR0041 + SA1->A1_CEPE //"CEP : "
					++li
					If !( Empty(LH2->LH2_REGIAO) )
						@li,  0 Psay STR0042 +  _cLargx2On + LH2->LH2_REGIAO + _cLargx2Off //"REGIAO : "
						++li
					EndIf
				Else
					@li,  0 Psay STR0037 + SA1->A1_END //"ENDERECO : "
					@li, 55 Psay STR0038 + SA1->A1_BAIRRO //"BAIRRO : "
					++li
					@li,  0 Psay STR0039 + SA1->A1_MUN //"CIDADE   : "
					@li, 55 Psay STR0040 + SA1->A1_EST //"UF : "
					@li, 65 Psay STR0041 + SA1->A1_CEP //"CEP : "
					++li
					If !( Empty(LH2->LH2_REGIAO) )
						@li,  0 Psay STR0042 +  _cLargx2On + LH2->LH2_REGIAO + _cLargx2Off //"REGIAO : "
						++li
					EndIf
				EndIf
			Else
				If !( Empty(SC5->C5_CODREQ) ) .AND. ( _nXPed > 1 .OR. _nNumCopias = 1)
					DbSelectArea("LH2")
					DbSetOrder(5)
					If DbSeek( xFilial("LH2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+SC5->C5_CODREQ)
						@li,  0 Psay STR0031 + SC5->C5_REQCLI //"REQ.CLIENTE  : "
						++li
						@li,  0 Psay STR0032 + SC5->C5_NOMEREQ //"REQUISITANTE : "
						@li, 55 Psay STR0033 + LH2->LH2_CC //"CENTRO CUSTO : "
						++li
						@li,  0 Psay STR0034 + LH2->LH2_DESCRC //"DESCRICAO CC : "
						@li, 55 Psay STR0035 + LH2->LH2_TELEF //"TEL/RAMAL:"
						++li
					EndIf
				EndIf
				If !( Empty(SC5->C5_ENDENT) )
					@li,  0 Psay SubStr(STR0036+ALLTRIM(SC5->C5_ENDENT)+; //"LOC. ENTREGA : "
					             If(!( Empty(SC5->C5_BAIRROE) ), " - "+ALLTRIM(SC5->C5_BAIRROE), '')+;
					             If(!( Empty(SC5->C5_MUNE) ), " - "+ALLTRIM(SC5->C5_MUNE), '')+;
					             If(!( Empty(SC5->C5_ESTE) ), " - "+ALLTRIM(SC5->C5_ESTE), '')+;
					             If(!( Empty(SC5->C5_CEPE) ), " - "+ALLTRIM(SC5->C5_CEPE), ''),1,80)
					
					If !Empty(LH2->LH2_REGIAO)
						++li
						@li,  0 Psay STR0042 +  _cLargx2On + LH2->LH2_REGIAO + _cLargx2Off //"REGIAO : "
					EndIf
					li += 2
				ElseIf !Empty(SA1->A1_ENDENT)
					@li,  0 Psay STR0037 + SA1->A1_ENDENT //"ENDERECO : "
					@li, 55 Psay STR0038 + SA1->A1_BAIRROE //"BAIRRO : "
					++li
					@li,  0 Psay STR0039 + SA1->A1_MUNE //"CIDADE   : "
					@li, 55 Psay STR0040 + SA1->A1_ESTE //"UF : "
					@li, 65 Psay STR0041 + SA1->A1_CEPE //"CEP : "
					++li
					If !Empty(LH2->LH2_REGIAO)
						@li,  0 Psay STR0042 +  _cLargx2On + LH2->LH2_REGIAO + _cLargx2Off //"REGIAO : "
						++li
					EndIf
				Else
					@li,  0 Psay STR0037 + SA1->A1_END //"ENDERECO : "
					@li, 55 Psay STR0038 + SA1->A1_BAIRRO //"BAIRRO : "
					++li
					@li,  0 Psay STR0039 + SA1->A1_MUN //"CIDADE   : "
					@li, 55 Psay STR0040 + SA1->A1_EST //"UF : "
					@li, 65 Psay STR0041 + SA1->A1_CEP //"CEP : "
					++li
					If !Empty(LH2->LH2_REGIAO)
						@li,  0 Psay STR0042 +  _cLargx2On + LH2->LH2_REGIAO + _cLargx2Off //"REGIAO : "
						++li
					EndIf
				EndIf
			EndIf
			DbSelectArea('SA4')
			DbSetOrder(1)
			DbSeek(xFilial('SA4')+SC5->C5_TRANSP)
			@li,  0 Psay STR0023 + SC5->C5_TRANSP + '-' + SA4->A4_NREDUZ //"TRANSPORTADORA: "
			DbSelectArea('SE4')
			DbSetOrder(1)
			DbSeek(xFilial('SE4')+SC5->C5_CONDPAG)
			@li, 55 Psay STR0025 + SE4->E4_DESCRI //"COND.PGTO:  "
			If (nOpcImp == 1 .OR. nOpcImp == 4) .AND. _nXPed == 1
				li++
				@li,  0 Psay STR0043 +SC5->C5_FATINT //"FI: "
				@li, 55 Psay STR0044 +SC5->C5_AGLUTIN //"FA: "
			Endif
			li += 2
		EndIf
	EndIf
	If nOpcImp <> 1 .AND. nOpcImp <> 4
		cabec1 :=   STR0045 //"IT CODIGO         DESCRICAO                                   UNID    QUANTIDADE"
		cabec2 :=             "                  MARCA                                      PRECO      SUBTOTAL"
	Else
		cabec1 :=   STR0045 //"IT CODIGO         DESCRICAO                                   UNID    QUANTIDADE"
		cabec2 :=             "                  MARCA
	Endif
	//               99 99999999       1234567890123456789012345678901234567890     12         999999
	//                                 12345678901234567890                   99,999.99  9,999,999.99
	//               0         1         2         3         4         5         6         7
	//               01234567890123456789012345678901234567890123456789012345678901234567890123456789
	@li, 0 Psay Replicate('-',80)
	++li
	@li, 0 Psay cabec1
	++li
	@li, 0 Psay cabec2
	++li
	@li, 0 Psay Replicate('-',80)
	++li
EndIf
DbSelectArea("SC6")
Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ R700Vend ³ Autor ³ Marcos Bispo Abrah„o  ³ Data ³ 11/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna string com todos vendedores                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr700,ImprPed                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function R700Vend(nVend)
Local nI     := 0	//controle de loop
Local cVend  := ""
Local cVends := ""
Local lBarra := .F.

For nI := 1 to nVend
	cVend := "SC5->C5_VEND"+STR(nI,1)
	cVend := &cVend
	DbSelectArea('SA3')
	DbSetOrder(1)
	DbSeek(xFilial('SA3')+cVend)
	If !( Empty(cVend) )
		cVends += If(lBarra, "/", "") + TRIM(SA3->A3_NREDUZ)
		lBarra := .T.
	EndIf
Next nI
If !( Empty(SA3->A3_NOME) ) .AND. !( Empty(Posicione('SU7', 3, xFilial('SU7') + Rtrim(SA3->A3_NOME), 'U7_POSTO')) )
	If !( Empty(Posicione('SU0', 1, xFilial('SU0') + If(!( Empty(SA1->A1_GRUPOAT) ), SA1->A1_GRUPOAT, SU7->U7_POSTO), 'U0_NOME')) )
		cVends += " - " + Rtrim(SU0->U0_NOME)
	Endif
Endif
DbSelectArea("SC6")
Return cVends

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpProd  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime os dados do item do Pedido de Venda                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpProd(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,nQtLib,nQtBloq,cLibCre,nOpcImp,_nXPed)

Local nTotFat   := 0

DbSelectArea("SB1")
DbSetorder(1)
DbSeek(xFilial("SB1")+SC6->C6_PRODUTO)
DbSelectArea("SC6")

nTotFat   := CalValFat(If(MV_PAR06 == 1, nQtlib, If(MV_PAR06 == 2, nQtBloq, (nQtLib + nQtBloq))))

DbSelectArea("SC6")

If !( Empty(SC6->C6_SEGUM) )
	_nQtdSeg  := If(SC6->C6_SEGUM == SB1->B1_UM, 1, If(SC6->C6_SEGUM == SB1->B1_SEGUM, SB1->B1_CONV, IIF(SC6->C6_SEGUM == SB1->B1_UM3, SB1->B1_UM3FAT, SB1->B1_UM4FAT)))
Else
	_nQtdSeg  := If(SC6->C6_UM    == SB1->B1_UM, 1, If(SC6->C6_UM    == SB1->B1_SEGUM, SB1->B1_CONV, IIF(SC6->C6_UM    == SB1->B1_UM3, SB1->B1_UM3FAT, SB1->B1_UM4FAT)))
EndIf
If nQtLib > 0
	_nQtdImp  := If(!( Empty(SC6->C6_SEGUM)), (nQtLib/_nQtdSeg), nQtLib)
Else
	_nQtdImp  := If(!( Empty(SC6->C6_SEGUM)), (nQtBloq/_nQtdSeg), nQtBloq)
EndIf

If nOpcImp == 1 .OR. nOpcImp == 4
	RecLock("SC6", .f.)
	If Empty(SC6->C6_IMPRE)
		SC6->C6_IMPRE := SUBSTR(ImpQuem,1,1)+'01'
		SC6->C6_OPC   := Rtrim(FUNNAME())+' '+Upper(cUserName)+" "+dtoc(Date())+" "+time()+" h"
	Else
		SC6->C6_IMPRE := Substr(ImpQuem,1,1)+Strzero(VAL(Substr(SC6->C6_IMPRE,2))+1,2)
		SC6->C6_OPC   := Rtrim(FUNNAME())+' '+Upper(Rtrim(SubS(cUsuario,7,15)))+" "+dtoc(Date())+" "+time()+" h"
	EndIf
	MsUnlock()
EndIf
_nValUni := xMoeda(If(!( Empty(SC6->C6_SEGUM) ), SC6->C6_PRCVEN * _nQtdSeg, SC6->C6_PRCVEN), SC5->C5_MOEDA, MV_PAR08, SC5->C5_EMISSAO)

AaDd(_aItens,{SC6->C6_ITEM,;
              SB1->B1_CODBAR,;
              Substr(SB1->B1_DESC,1,40),;
              If(!( Empty(SC6->C6_SEGUM)), SC6->C6_SEGUM + StrZero(_nQtdSeg,3) + SC6->C6_UM, SC6->C6_UM),;
              ImpQuem + " " + Substr(SC6->C6_IMPRE,2) + "x",;
              SC6->C6_LOCALIZ + SC6->C6_ITEM,;
              SB1->B1_FABRIC,;
              _nQtdImp,;
              _nQtdImp,;
              _nValUni,;
              xMoeda(nTotFat, SC5->C5_MOEDA, MV_PAR08, SC5->C5_EMISSAO),;
              cLibCre,;
              SB1->B1_CODBAR,;
              SB1->B1_CODITE})

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpProd2 ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 10.01.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 												              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 		                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpProd2(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,nOpcImp,_nXPed)
Local _nX
aSort(_aItens,,,{|x,y|x[6]<y[6]})

For _nX := 1 To Len(_aItens)
	
	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@li,  0 Psay "PEDIDO: "+SC5->C5_NUM
		li++
		@li,  0 Psay "CLIENTE : " + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40)
		@li, 71 Psay "VIAS: "+Alltrim(Str(_nXPed,1))+"/"+Alltrim(Str(_nNumCopTo,1))
		li += 2
	EndIf
	@li,  0 Psay Alltrim(_aItens[_nX,1])
	@li,  3 Psay Alltrim(_aItens[_nX,2])
	@li, 18 Psay _aItens[_nX,3]
	@li, 60 Psay _aItens[_nX,4]
	If _aItens[_nX,8] > 0
		@li, 74 Psay _aItens[_nX,8]    Picture "@E 999999"
	Else
		@li, 74 Psay _aItens[_nX,9]    Picture "@E 999999"
	EndIf
	++li
	@li, 00 Psay _aItens[_nX,6]    Picture PesqPict("SC6","C6_LOCALIZ")
	@li, 18 Psay _aItens[_nX,7]
	If !( Empty(_aItens[_nX,12]) ) .AND. _aItens[_nX,12] <> '..'
		@li, 50 Psay Alltrim(_aItens[_nX,12])
	EndIf
	If (nOpcImp <> 1 .AND. nOpcImp <> 4) .OR.	(_nNumCopias > 1 .AND. _nXPed > 1)
		@li, 55 Psay _aItens[_nX,10]   Picture "@E 999,999.9999"
		@li, 68 Psay _aItens[_nX,11]   Picture "@ER 9,999,999.99"
	ElseIf !( Empty(_aItens[_nX,14]) )
		@li, 55 Psay _aItens[_nX,14]   	
	EndIf
	++li
Next _nX
++li
If (nOpcImp == 1 .OR. nOpcImp == 4) .AND. _nXPed == 1
	@li, 00 Psay 'IMPRESSOES: '+_aItens[1,5]
	++li
EndIf

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CalValFat ³ Autor ³ Paulo Boschetti       ³ Data ³ 25.02.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calcula valor a faturar                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

Static Function CalValFat(_nQtd)
Return (_nQtd * SC6->C6_PRCVEN)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a700Bloq  ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 22.01.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o pedido esta liberado e se esta bloqueado ou  ³±±
±±³          ³ ou nao                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Matr700                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function a700Bloq(nOpcImp)
Local cAlias := Alias()
Local aQuant := {}

//Elementos do Array :
// 1. Produto
// 2. Quantidade Liberada
// 3. Quantidade Bloqueada

DbSelectArea("SC9")
DbSetOrder(1)
If DbSeek(xFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM, .F.)
	While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM .AND. SC9->C9_PRODUTO == SC6->C6_PRODUTO
		If Empty(SC9->C9_NFISCAL)
			If nOpcImp <> 1 .AND. nOpcImp <> 4
				If DTOS(SC9->C9_DATALIB) < DTOS(MV_PAR10) .OR. DTOS(SC9->C9_DATALIB) > DTOS(MV_PAR11)
					DbSkip()
					Loop
				Endif
			EndIf
			If !EMPTY(MV_PAR15)
				_cNota     := MV_PAR15
				_cNotaComp := SC9->C9_NFENT
				If !( Empty(MV_PAR16) )
					_cNota += MV_PAR16
					_cNotaComp += SC9->C9_SERENT
				Endif
				If !( Empty(MV_PAR17) )
					_cNota += MV_PAR17
					_cNotaComp += SC9->C9_FORNEC
				Endif
				If !( Empty(MV_PAR18) )
					_cNota += MV_PAR18
					_cNotaComp += SC9->C9_LOJAFOR
				Endif
				If _cNotaComp <> _cNota
					DbSkip()
					Loop
				Endif
			EndIf
			If Empty(SC9->C9_BLEST) .AND. MV_PAR06 == 1 .AND. If(nOpcImp == 4, !( Empty(SC9->C9_BLPRE) ), .T.)
				nPos := Ascan(aQuant, {|x|x[1]== SC9->C9_PRODUTO})
				If nPos <> 0 
					aQuant[nPos,2] += SC9->C9_QTDLIB
				Else
					Aadd(aQuant, {SC9->C9_PRODUTO, SC9->C9_QTDLIB, 0, Alltrim(SC9->C9_BLCRED), SC9->C9_BLPRE})
				EndIf
			ElseIf !( Empty(SC9->C9_BLEST) ) .AND. MV_PAR06 == 2
				nPos := Ascan(aQuant, {|x| x[1] == SC9->C9_PRODUTO})
				If nPos <> 0
					aQuant[nPos,3] += SC9->C9_QTDLIB
				Else
					Aadd(aQuant, {SC9->C9_PRODUTO, 0, SC9->C9_QTDLIB, Alltrim(SC9->C9_BLCRED), SC9->C9_BLPRE})
				EndIf
			ElseIf MV_PAR06 = 3
				nPos := Ascan(aQuant, {|x|x[1] == SC9->C9_PRODUTO})
				If nPos <> 0
					aQuant[nPos,If(Empty(SC9->C9_BLEST) .AND. If(nOpcImp == 4, !( Empty(SC9->C9_BLPRE) ), .T.), 2, 3)] += SC9->C9_QTDLIB
				Else
					If Empty(SC9->C9_BLEST) .AND. If(nOpcImp == 4,!( Empty(SC9->C9_BLPRE) ),.T.)
						Aadd(aQuant, {SC9->C9_PRODUTO, SC9->C9_QTDLIB, 0, Alltrim(SC9->C9_BLCRED), SC9->C9_BLPRE})
					Else
						Aadd(aQuant, {SC9->C9_PRODUTO, 0, SC9->C9_QTDLIB, Alltrim(SC9->C9_BLCRED), SC9->C9_BLPRE})
					Endif
				Endif
			Endif
		ElseIf !( Empty(SC9->C9_NFISCAL) ) .AND. MV_PAR06 == 3
			nPos := Ascan(aQuant, {|x|x[1] == SC9->C9_PRODUTO})
			If nPos <> 0
				aQuant[nPos,2] += SC9->C9_QTDLIB
			Else
				Aadd(aQuant, {SC9->C9_PRODUTO, SC9->C9_QTDLIB, 0, Alltrim(SC9->C9_BLCRED), SC9->C9_BLPRE})
			Endif
		Endif
		DbSkip()
	End  
Endif
DbSetOrder(1)
DbSelectArea(cAlias)
Return aQuant


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpRomaneio³ Autor ³ Rosane Luciane Chene  ³ Data ³ 22.01.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 															   ³±±
±±³          ³ 			                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 			                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpRomaneio(tamanho,ntipo)
Local _nQtdRoma
titulo := "ROMANEIO DE ENTREGA"
_cCodReq := ''
_nRecno  := 0
_nQtdImp := 1
DbSelectArea('LHA')
While LHA->(! Eof()) .AND. LHA->LHA_FILIAL == xFilial('LHA') .AND. LHA->LHA_NUMORC == SUA->UA_NUM
	
	_nRecno  := Recno()
	
	For _nQtdRoma := 2 To _nNumCop2
		++_nQtdImp
		DbSelectArea('LHA')
		If _nQtdRoma > 2
			LHA->(DbGoTo(_nRecno))
		EndIf
		
		_cCodReq := LHA->LHA_CODREQ
		nAc1     := 0
		li       := 60
		
		While LHA->(! Eof()) .AND. LHA->LHA_FILIAL == xFilial('LHA') .AND. LHA->LHA_NUMORC == SUA->UA_NUM .AND. LHA->LHA_CODREQ == _cCodReq
			
			If li > 58
				cabec(titulo,'','',nomeprog,tamanho,nTipo)
				DbSelectArea("LH2")
				DbSetOrder(5)
				DbSeek( xFilial("LH2")+LHA->LHA_CLIENTE+LHA->LHA_LOJA+LHA->LHA_CODREQ)
				DbSelectArea("LHA")
				ImprCabRom(titulo,'','',nomeprog,tamanho,nTipo,1)
			EndIf
			
			ImpProdRom()
			
			nAc1 += LHA->LHA_TOTAL
			
			If li > 58
				cabec(titulo,'','',nomeprog,tamanho,nTipo)
				@li,  0 Psay "PEDIDO: "+SC5->C5_NUM
				li++
				@li,  0 Psay "CLIENTE : " + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40)
				@li, 71 Psay "VIAS: "+Alltrim(Str(_nQtdImp,1))+"/"+Alltrim(Str(_nNumCopTo,1))
				li+=2
			EndIf
			
			LHA->(DbSkip())
		End
		
		@li,  0 Psay "TOTAL DO PEDIDO--> "
		@li, 68 Psay nAc1 PicTure "@ER 9,999,999.99"
		If li+6 > 58
			cabec(titulo,'','',nomeprog,tamanho,nTipo)
			@li,  0 Psay "PEDIDO: "+SC5->C5_NUM
			li++
			@li,  0 Psay "CLIENTE : " + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40)
			@li, 71 Psay "VIAS: "+Alltrim(Str(_nQtdImp,1))+"/"+Alltrim(Str(_nNumCopTo,1))
			li+=2
		EndIf
		li++
		@li, 0 Psay Replicate('-',80)
		li+=2
		@li, 0 Psay 'Separador.:________________________'
		@li,40 Psay 'Setor/Zona.......:______________________'
		li+=2
		@li, 0 Psay 'Conferente:________________________'
		@li,40 Psay 'Numero de Volumes:______________________'
		li+=2
		@li, 0 Psay 'Peso......:________________________'
		@li,40 Psay 'Cubagem..........:______________________'
		li+=2
		@li, 0 Psay 'Cliente...:________________________'
		
	Next _nQtdRoma
	DbSelectArea('LHA')
End  
li:=60
Eject
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImprCabRom ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 22.01.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 															   ³±±
±±³          ³ 			                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 			                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImprCabRom(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo,nVend)

@li,  0 Psay "PEDIDO  : "	 + SC5->C5_NUM
@li, 20 Psay "EMISSAO : " + DTOC(SC5->C5_EMISSAO)
@li, 64 Psay "ORCAMEN.: "	 + SUA->UA_NUM

li+=2

@li,  0 Psay "CLIENTE : " + SA1->A1_COD+' - '+ Subs(SA1->A1_NOME,1,40)
@li, 71 Psay "VIAS: "+Alltrim(Str(_nQtdImp,1))+"/"+Alltrim(Str(_nNumCopTo,1))
++li
@li,  0 Psay "NOME FANTASIA: " + SA1->A1_NREDUZ
++li
@li,  0 Psay "TELEFONE: " + "(" + SA1->A1_DDD + ") " + SA1->A1_TEL
@li, 30 Psay "FAX: " + SA1->A1_FAX
++li
@li,  0 Psay "VENDEDOR: " + R700Vend(nVend)
++li
@li,  0 Psay "RESPONSAVEL  : " + SA1->A1_CONTATO
If !Empty(SA1->A1_SATIV1)
	++li
	@li,  0 Psay "CLIENTE TIPO : " + SA1->A1_SATIV1
EndIf
li+=2
@li,  0 Psay "REQ.CLIENTE  : " + LHA->LHA_NUMCLI
++li
@li,  0 Psay "REQUISITANTE : " + LH2->LH2_NOMERE
@li, 55 Psay "CENTRO CUSTO : " + LH2->LH2_CC
++li
@li,  0 Psay "DESCRICAO CC : " + LH2->LH2_DESCRC
@li, 55 Psay "TEL/RAMAL:" + LH2->LH2_TELEF
++li

If !Empty(LH2->LH2_ENDENT)
	@li,  0 Psay SubStr("LOC. ENTREGA : "+ALLTRIM(LH2->LH2_ENDENT)+;
	If(!Empty(LH2->LH2_BAIRRO)," - "+ALLTRIM(LH2->LH2_BAIRRO),'')+;
	If(!Empty(LH2->LH2_CIDADE)," - "+ALLTRIM(LH2->LH2_CIDADE),'')+;
	If(!Empty(LH2->LH2_EST)," - "+ALLTRIM(LH2->LH2_EST),'')+;
	If(!Empty(LH2->LH2_CEP)," - "+ALLTRIM(LH2->LH2_CEP),''),1,80)
Else
	@li,  0 Psay SubStr("LOC. ENTREGA : "+ALLTRIM(SC5->C5_ENDENT)+If(!Empty(SC5->C5_BAIRROE)," - "+ALLTRIM(SC5->C5_BAIRROE),'')+;
	If(!Empty(SC5->C5_MUNE)," - "+ALLTRIM(SC5->C5_MUNE),'')+;
	If(!Empty(SC5->C5_ESTE)," - "+ALLTRIM(SC5->C5_ESTE),'')+;
	If(!Empty(SC5->C5_CEPE)," - "+ALLTRIM(SC5->C5_CEPE),''),1,80)
Endif
li+=2
@li,  0 Psay "ENDERECO : " + SA1->A1_END
@li, 55 Psay "BAIRRO : " + SA1->A1_BAIRRO
++li
@li,  0 Psay "CIDADE   : " + SA1->A1_MUN
@li, 55 Psay "UF : " + SA1->A1_EST
@li, 65 Psay "CEP : " + SA1->A1_CEP
++li
If !Empty(LH2->LH2_REGIAO)
	@li,  0 Psay "REGIAO : " +  _cLargx2On + LH2->LH2_REGIAO + _cLargx2Off
	++li
Endif
DbSelectArea('SA4')
DbSetOrder(1)
DBSeek(xFilial('SA4')+SC5->C5_TRANSP)
@li,  0 Psay "TRANSPORTADORA: " +SC5->C5_TRANSP+'-'+SA4->A4_NREDUZ
DbSelectArea('SE4')
DbSetOrder(1)
DbSeek(xFilial('SE4')+SC5->C5_CONDPAG)
@li, 55 Psay "COND.PGTO:  " + SE4->E4_DESCRI
li+=2
cabec1 :=   "IT   CODIGO       DESCRICAO                                   UNID    QUANTIDADE"
cabec2 :=   "                  MARCA                                      PRECO      SUBTOTAL"
@li, 0 Psay Replicate('-',80)
++li
@li, 0 Psay cabec1
++li
@li, 0 Psay cabec2
++li
@li, 0 Psay Replicate('-',80)
++li

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpProdRom ³ Autor ³ Rosane Luciane Chene  ³ Data ³ 22.01.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ 															   ³±±
±±³          ³ 			                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 			                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpProdRom()

Posicione('SB1',1,xFilial('SB1')+LHA->LHA_PRODUTO,'')
@li,  0 Psay LHA->LHA_ITEM
@li,  5 Psay SB1->B1_ALTER
@li, 18 Psay LHA->LHA_DESCRI
@li, 63 Psay LHA->LHA_UM
@li, 74 Psay LHA->LHA_QUANT    Picture "@E 999999"
++li

@li, 18 Psay SB1->B1_FABRIC
@li, 56 Psay LHA->LHA_VALOR   PicTure "@E 999,999.99"
@li, 68 Psay LHA->LHA_TOTAL   PicTure "@ER 9,999,999.99"
++li

Return .T.
