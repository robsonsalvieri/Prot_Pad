#INCLUDE "Testr01.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TESTR01  ³ Autor ³ EWERTON C TOMAZ       ³ Data ³ 08.08.01  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relacao de Pedidos aptos a faturar                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
Template Function TESTR01(_cPedSel,_nLibBlq,_nTip)

CHKTEMPLATE("DCM")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private CbTxt
Private CbCont
Private cabec1
Private cabec2
Private wnrel
Private titulo	:= If(_nTip == 1 .OR. _nTip == 3, STR0001+If(_nLibBlq == 1, STR0002, STR0003), STR0004) //"Romaneio de Separacao - "###"Aptos a Faturar"###"Nao Liberados"###"Romaneio de Armazenagem"
Private cDesc1	:= OemToAnsi(STR0005+If(_nTip == 1 .OR. _nTip == 3, STR0006, STR0007))	 //"Este programa ira emitir a relacao dos Itens "###"dos Pedidos"###"das Notas"
Private cDesc2	:= OemToAnsi(STR0008)	 //"aglutinados e separados por unidade de medida"
Private cDesc3	:= OemToAnsi("")	
Private tamanho	:= "M"
Private limite	:= 132
Private cString	:= "CAD"
Private lContinua	:= .T.
Private aOrd		:= {}		
PRIVATE aReturn	:= {STR0009, 1,STR0010, 1, 2, 1, "",1 }		 //"Zebrado"###"Administracao"
PRIVATE nomeprog	:="RESTR02"
PRIVATE aLinha	:= { },nLastKey := 0

wnrel:="TESTR01"    

DbSelectArea("CAD")
wnrel:=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho)

If nLastKey == 27
	DbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey==27
	DbClearFilter()
	Return
Endif

RptStatus({|lEnd| C700Imp(@lEnd,wnRel,cString,_cPedSel,Titulo,_nTip)},Titulo)

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
Static Function C700Imp(lEnd,WnRel,cString,cPedsFun,Titulo,_nTip)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _nX

Private CbTxt
Private CbCont
Private cabec1
Private cabec2
Private tamanho		:= "M"
Private limite		:= 132
Private lContinua		:= .T.
Private nAc1
Private nAg1
Private nAc2
Private nAg2
Private nTipo
Private cPedant
Private nValIPI		:= 0
Private nTotIpi		:= 0
Private cTrab
Private cDescOrdem	:= ""
Private lFirst
Private lImp			:= .F.
Private aOrd			:= {}
Private aCampos		:= {}
Private aTam			:= {}
Private cPeds			:= cPedsFun

If _nTip == 1 .OR. _nTip == 3
	cabec1 := "Localizacao  Codigo                         Descricao                                 Separacao OK    UM Qtd.Pri.UM  UM2 Qtd.Seg.UM"
ElseIf _nTip = 2
	cabec1 := "Localizacao  Codigo                         Descricao                                 Armazenagem OK  UM Qtd.Pri.UM  UM2 Qtd.Seg.UM"
Endif
cabec2 := '                                Marca'
li       := 80
m_pag    := 1

SetRegua(RecCount())

While !Eof() .AND. lContinua
	IncRegua()
	IF lEnd
		@ Prow()+1,001 Psay STR0011 //"CANCELADO PELO OPERADOR"
		lContinua := .F.
		Exit
	Endif
	IF li > 56
		if li < 80
			If _nTip == 1 .OR. _nTip == 3
				@ ++li,000 PSAY STR0012 //"SEPARADOR : _____________________ CONFERENTE : _____________________ "
			ElseIf _nTip == 2
				@ ++li,000 PSAY STR0013           //"ARMAZENADO POR : _____________________ "
			Endif
		endif
		cabec(titulo,'','',nomeprog,tamanho,nTipo)
		li := 5
		@ li  ,000 PSAY cabec1
		@ ++li,000 PSAY cabec2
		@ ++li,000 PSAY Replicate('*',132)
		If !Empty(cPeds) .AND. _nTip  <> 3
			cPeds := SubStr(cPeds,2,Len(SubStr(cPeds,2,Len(cPeds)))-1)
			@ ++li,000 PSAY If(_nTip=1.OR._nTip=3,'Pedidos Selecionados:','Notas Selecionadas:')
			_nLinhas := MlCount(cPeds,126)
			For _nX := 1 To _nLinhas
				@ ++li,000 PSAY MemoLine(cPeds,126,_nX)
			Next _nX
			cPeds := ''
			++li
		Endif
	EndIF
    // Localizacao  Codigo                         Descricao                                 Separacao OK    UM Qtd.Pri.UM  UM2 Qtd.Seg.UM
    // 1234567890   123456789012345678901234567890 1234567890123456789012345678901234567890  [ ]___________  12  99.999,99   12  99.999,99
    // 0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
    //           1         2         3         4         5         6         7         8         9        10        11        12        13

	If _nTip == 1 .OR. _nTip == 3
		If !Empty(CAD->C6_LOCALIZ)
			@ ++li,000 PSAY CAD->C6_LOCALIZ PICTURE PESQPICT('SC6','C6_LOCALIZ')
		Else
			@ ++li,000 PSAY "____________"
		Endif
		@ li  ,013 PSAY CAD->C9_PRODUTO
		@ li  ,044 PSAY CAD->C6_DESCRI
		@ li  ,086 PSAY "[ ]___________"
		@ li  ,102 PSAY CAD->C6_UM
		@ li  ,106 PSAY CAD->C9_QTDLIB PICTURE "@ER 99,999.99"
		@ li  ,118 PSAY CAD->C6_SEGUM
		Posicione('SB1',1,xFilial('SB1')+CAD->C9_PRODUTO,'')
		@ li  ,122 PSAY CAD->C9_QTDLIB / If(!Empty(CAD->C6_SEGUM) .AND. CAD->C6_SEGUM == SB1->B1_SEGUM, SB1->B1_CONV,;
		                                    If(!Empty(CAD->C6_SEGUM) .AND. CAD->C6_SEGUM == SB1->B1_UM3, SB1->B1_UM3FAT,;
		                                       If(!Empty(CAD->C6_SEGUM) .AND. CAD->C6_SEGUM == SB1->B1_UM4, SB1->B1_UM4FAT, 0))) PICTURE "@ER 99,999.99"
		@ ++li,000 PSAY SB1->B1_CODBAR
		@   li,032 PSAY CAD->B1_FABRIC
	ElseIf _nTip == 2
		If !Empty(CAD->D1_ENDER)
			@ ++li,000 PSAY CAD->D1_ENDER PICTURE PESQPICT('SD1','D1_ENDER')
		Else
			@ ++li,000 PSAY '_____________'
		Endif
		@ li  ,013 PSAY CAD->D1_COD
		@ li  ,044 PSAY Posicione('SB1',1,xFilial('SB1')+CAD->D1_COD,'B1_DESC')
		@ li  ,086 PSAY "[ ]___________"
		@ li  ,102 PSAY CAD->D1_UM
		@ li  ,106 PSAY CAD->D1_QUANT PICTURE "@ER 99,999.99"
		@ li  ,118 PSAY CAD->D1_SEGUM
		@ li  ,122 PSAY CAD->D1_QTSEGUM PICTURE "@ER 99,999.99"
		@ ++li,000 PSAY SB1->B1_CODBAR
		@   li,032 PSAY CAD->B1_FABRIC
	Endif
	++li
	DbSkip()
Enddo

If _nTip == 1 .OR. _nTip == 3
	@ ++li,000 PSAY STR0012 //"SEPARADOR : _____________________ CONFERENTE : _____________________ "
ElseIf _nTip == 2
	@ ++li,000 PSAY STR0013           //"ARMAZENADO POR : _____________________ "
Endif

set devi to screen
If aReturn[5] == 1
	Set Printer To
	Ourspool(wnrel)
Endif
MS_FLUSH()

Return