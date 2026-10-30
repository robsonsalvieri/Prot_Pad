#INCLUDE "tcomr02.ch"
#include "RWMAKE.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TCOMR02   ºAutor  ³Ewerton C. Tomaz    º Data ³  09/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio/Etiquetas das atualizacoes feitas na politica de º±±
±±º          ³ Precos                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Template function TCOMR02()

CHKTEMPLATE("DCM")  

private lEnd         := .F.
private lAbortPrint  := .F.
private limite       := 80
private tamanho      := "P"
private nomeprog     := "TCOMR02"
private nTipo        := 15
private aReturn      := { STR0001, 1, STR0002, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
private nLastKey     := 0
private cbtxt        := Space(10)
private cbcont       := 00
private CONTFL       := 01
private m_pag        := 01
private cString      := "SB0"
private wnrel        := "TCOMR02"
Private aOrd           := {}
Private cDesc1         := STR0003 //"Este programa tem como objetivo imprimir relatorio "
Private cDesc2         := STR0004 //"de acordo com os parametros informados pelo usuario."
Private cDesc3         := ""
Private cPict          := ""
Private imprime        := .T.
Private titulo         := STR0005 //"Precos Atualizados"
Private nLin           := 80
Private Cabec1         := STR0006 //"Produto         Descricao                                  UM    Preco.UM   Data"
Private Cabec2         := ""

//Produto         Descricao                                  UM    Preco.UM   Data
//123456789012345 1234567890123456789012345678901234567890   12   99,999.99  99/99
//01234567890123456789012345678901234567890123456789012345678901234567890123456789
//          1         2         3         4         5         6         7

_saida :=.T.
while _saida
	DbSelectArea("SB0")
	DbSetOrder(1)
	
	wnrel := setPrint(cString,nomeProg,'RELETQ',@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif
	
	setDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo :=if(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
End
return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RunReport ºAutor  ³Ewerton C. Tomaz    º Data ³  09/22/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local _nX

Pergunte(Padr('RELETQ',Len(SX1->X1_GRUPO)) ,.F.)
//mv_par01 = "Tabela Alterada De ?"
//mv_par02 = "Tabela Alterada Ate?"
//mv_par03 = "Produto De         ?"
//mv_par04 = "Produto Ate        ?"
//mv_par05 = "Especificar Produto?"
//mv_par06 = "                   :"
//mv_par07 = "                   :"
//mv_par08 = "                   :"
//mv_par09 = "Emitir             ?" ("Relatorio";"Etiquetas")

If MV_PAR09 = 2
	MsgStop(STR0007) //'Rotina de Etiquetas nao disponivel.'
	ms_flush()
	retIndex("SB0")
	Return
Endif


If MV_PAR09 = 2 // se etiqueta
	Private cCode
	nHeight   := 15
	lBold     := .F.
	lUnderLine:= .F.
	nLin := 0
	
	Private arial  := tFont():new( "arial",,nHeight,,lBold,,,,,lUnderLine )
	Private arial08:= tFont():new( "arial",,08,,.f.,,,,,.f. )
	Private arial10:= tFont():new( "arial",,10,,.f.,,,,,.f. )
	Private arial12:= tFont():new( "arial",,12,,.t.,,,,,.f. )
	Private arial20:= tFont():new( "arial",,20,,.t.,,,,,.f. )
	Private arial28:= tFont():new( "arial",,28,,.t.,,,,,.f. )
	Private arial36:= tFont():new( "Arial",,36,,.t.,,,,,.f. )
	Private arial48:= tFont():new( "arial",,48,,.t.,,,,,.f. )
	
	Private times14 := tFont():new( "times new roman",,14,,.t.,,,,,.f. )
	Private times18 := tFont():new( "times new roman",,18,,.t.,,,,,.f. )
	Private times18T:= tFont():new( "times new roman",,18,,.t.,,,,,.t. )
	Private times20 := tFont():new( "times new roman",,20,,.t.,,,,,.f. )
	Private times28 := tFont():new( "times new roman",,28,,.t.,,,,,.t. )
	
	Private HAETTEN:= tFont():new( "HAETTENSCHWEILLER",,10,,.t.,,,,,.f. )
	
	Private free44 := tFont():new( "free 3 of 9",,44,,.t.,,,,,.f. )
	private free38 := tFont():new( "free 3 of 9",,38,,.t.,,,,,.f. )
	
	oPrn := tmsPrinter():new()
Endif

Cabec2 := STR0008+dtoc(MV_PAR01)+STR0009+dtoc(MV_PAR02) //'Atualizacao - De: '###' Ate: '

DbSelectArea(cString)
DbSetOrder(1)
_aAtuali := {}
_nCount  := 0

If !empty(MV_PAR03+MV_PAR04)
	_cFiltroB0 :="dtos(B0_ULTREVI) >='"+dtos(MV_PAR01)+"' .and. dtos(B0_ULTREVI) <='"+dtos(MV_PAR02)+"' .and. B0_COD >='"+MV_PAR03+"' .and. B0_COD <='"+MV_PAR04+"' .and. B0_PRV1 >0"
Else
	_cFiltroB0 :="dtos(B0_ULTREVI) >='"+dtos(MV_PAR01)+"' .and. dtos(B0_ULTREVI) <='"+dtos(MV_PAR02)+"' .and. aLLtrim(B0_COD)$'"+MV_PAR05+MV_PAR06+MV_PAR07+MV_PAR08+"' .and. B0_PRV1 >0"
EndIf

IndRegua('SB0',criatrab(,.f.),"B0_FILIAL+B0_COD",,_cFiltroB0,STR0010) //'Selecionando registros'
DbGoTop()

while !eof()
	DbSelectArea('SB1')
	DbSetOrder(1)
	DbSeek(xFilial('SB1')+SB0->B0_COD)
	DbSelectArea('LH7')
	DbSetOrder(1)
	DbSeek(xFilial('LH7')+SB0->B0_COD)
	AADD(_aAtuali,{SB0->B0_COD,;
	               SB1->B1_DESC,;
	               SB1->B1_UM,;
	               SB0->B0_PRV1,;
	               LH7->LH7_NFORN,;
	               dtoc(SB0->B0_ULTREVI),;
	               If(!Empty(SB1->B1_SEGUM),SB1->B1_SEGUM,"  "),;
	               If(!Empty(SB1->B1_SEGUM),SB0->B0_PRV1*SB1->B1_CONV,0)})
	++_nCount
	DbSelectArea('SB0')
	DbSkip()
End
aSort(_aAtuali,,,{|x,y|x[5]+x[1]<y[5]+y[1]})

setRegua(_nCount)
_cForn := ''
_nCont := 0
_nCont2:= 0
For _nX := 1 to Len(_aAtuali)
	IncRegua()
	If lAbortPrint .And. MV_PAR09 =1
		@nLin,00 pSay STR0011 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	If (nLin >55 .or. _cForn <>_aAtuali[_nX,5]) .and. MV_PAR09 =1
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
		@ nLin,000 pSay STR0012+_aAtuali[_nX,5] //'Fornecedor: '
		nLin += 2
		_cForn := _aAtuali[_nX,5]
	Endif
	
	If MV_PAR09 =1
		@ nLin,000 pSay _aAtuali[_nX,1]
		@ nLin,016 pSay _aAtuali[_nX,2]
		@ nLin,059 pSay _aAtuali[_nX,3]
		@ nLin,064 pSay _aAtuali[_nX,4] picture "@ER 99,999.99"
		//          @ nLin,061 pSay _aAtuali[_nX,7]
		//          @ nLin,066 pSay _aAtuali[_nX,8] picture "@ER 9,999.99"
		@ nLin,075 pSay SubStr(_aAtuali[_nX,6],1,5)
		++nLin
	Else
		cBitMap:= "bmpetiq.bmp"
		
		oPrn:Say( 000,000, " ",Arial,100 )
		oPrn:SayBitmap( 020+(_nCont*470),100+(_nCont2*1600),cBitMap,1265,380 )
		oPrn:Say( 105+(_nCont*470),435+(_nCont2*1600), STR0013+_aAtuali[_nX,1],Arial12,100  ) //'Cod:'
		oPrn:Say( 040+(_nCont*470),815+(_nCont2*1600), 'R$',Times20,100  )
		oPrn:Say( 135+(_nCont*470),845+(_nCont2*1600), TransForm(_aAtuali[_nX,4],"@E 999.99"),Arial36,100  )
		oPrn:Say( 180+(_nCont*470),120+(_nCont2*1600), SubStr(_aAtuali[_nX,2],1,20),Arial12,100)
		oPrn:Say( 245+(_nCont*470),120+(_nCont2*1600), SubStr(_aAtuali[_nX,2],21,20),Arial12,100)
		oPrn:Say( 255+(_nCont*470),900+(_nCont2*1600), STR0014+_aAtuali[_nX,3],Times20,100  ) //'Unidade: '
		if _nCont2 = 1
			_nCont ++
			_nCont2 := 0
		Else
			_nCont2 ++
		Endif
		If _nCont = 5
			oPrn:EndPage()
			oPrn:StartPage()
			_nCont := 0
			_nCont2 := 0
		Endif
	Endif
Next

If MV_PAR09 =1
	Set device to screen
	If aReturn[5]==1
	   //	dbCommitAll()
		set printer to
		ourSpool(wnrel)
	Endif
Else
	oPrn:EndPage()
	oPrn:Preview()
	oPrn:End()
EndIf
ms_flush()
RetIndex("SB0")
Return