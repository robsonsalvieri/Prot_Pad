#INCLUDE "testr02.ch"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TESTR02   º Autor ³ EWERTON C TOMAZ    º Data ³  03/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Etiquetas de identificacao de volumes do estoque           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
   
Template Function TESTR02(_cVarPed,_nVarVol)

CHKTEMPLATE("DCM")

Private aOrd := {}
Private cDesc1         := STR0001 //"Este programa tem como objetivo imprimir etiquetas "
Private cDesc2         := STR0002 //"de identificacao de volumes do estoque              "
Private cDesc3         := ""
Private cPict          := ""
Private lEnd           := .F.
Private lAbortPrint    := .F.
Private limite         := 80
Private tamanho        := "P"
Private nomeprog       := "TESTR02"
Private nTipo          := 18
Private aReturn        := { STR0003, 1, STR0004, 2, 3, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey       := 0
Private titulo         := STR0005 //"Etiquetas de Volumes"
Private nLin           := 00
Private Cabec1         := ""
Private Cabec2         := ""
Private cbtxt          := Space(10)
Private cbcont         := 00
Private CONTFL         := 01
Private m_pag          := 01
Private imprime        := .T.
Private wnrel          := "TESTR02" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString        := "SC5"
Private _cPedido       := If(_cVarPed = nil, Space(6), _cVarPed)
Private _nVolumes      := If(_nVarVol = nil, 0,        _nVarVol)

DbSelectArea("SC5")
DbSetOrder(1)

If Empty(_cPedido)
	If !Pergunte(Padr("TEST02",Len(SX1->X1_GRUPO)) ,.T.)
		Return(.T.)
	Endif
Else
	DbSelectArea("SX1")
	DbSetOrder(1)
	DbSeek(Padr("TEST02",Len(SX1->X1_GRUPO)))
	While !Eof() .And. X1_GRUPO = Padr("TEST02",Len(SX1->X1_GRUPO))
		RecLock('SX1',.F.)
		If X1_ORDEM = '01'
			X1_CNT01 := _cPedido
		ElseIf X1_ORDEM = '02'
			X1_CNT01 := Str(_nVolumes,3)
		ElseIf X1_ORDEM = '03'
			X1_CNT01 := '1'
		Endif
		MsUnLock()
		DbSkip()
	End
	Pergunte(Padr("TEST02",Len(SX1->X1_GRUPO)),.F.)
Endif

wnrel := SetPrint(cString,NomeProg,"TEST02",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TESTR02   º Autor ³ EWERTON C TOMAZ    º Data ³  03/10/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Etiquetas de identificacao de volumes do estoque           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local _nX

DbSelectArea(cString)
DbSetOrder(1)
DbSeek(xFilial('SC5')+MV_PAR01)

SetPrc(0,0)

@ nLin,00 PSAY Chr(18)

If MV_PAR03 = 1
	For _nX := 1 To MV_PAR02
		@ nLin,00 PSAY '.'
		@ nLin,01 PSAY 'Ped.Nosso...: '
		@ nLin,15 PSAY chr(27)+"W1"
		@ nLin,09 PSAY SC5->C5_NUM
		@ nLin,09 PSAY SC5->C5_NUM
		@ nLin,36 PSAY chr(27)+"W0"
		++nLin
		@ nLin,01 PSAY 'Cliente.....: '+Posicione('SA1',1,xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJAENT,'A1_NOME')
		++nLin
		@ nLin,01 PSAY 'Ped.Cliente.:'
		@ nLin,16 PSAY SC5->C5_REQCLI
		++nLin
		@ nLin,01 PSAY 'C.Custo.....: '+Posicione("LH2",5,xFilial("LH2")+SC5->C5_CLIENTE+SC5->C5_LOJAENT+SC5->C5_CODREQ,"Alltrim(LH2->LH2_CC)+' '+alltrim(LH2->LH2_DESCRC)")
		++nLin
		@ nLin,01 PSAY 'Req.: '+SC5->C5_NOMEREQ
		++nLin
		@ nLin,01 PSAY 'Dep.: '
		@ nLin,07 PSAY SC5->C5_ENDENT
		@ nLin,08 PSAY SC5->C5_ENDENT
		nLin+=4
	Next
ElseIf MV_PAR03 = 2
	For _nX := 1 To MV_PAR02
		@ nLin,00 PSAY '.'
		@ nLin,01 PSAY 'Ped.Nosso...: '
		@ nLin,15 PSAY chr(27)+"W1"
		@ nLin,09 PSAY SC5->C5_NUM
		@ nLin,09 PSAY SC5->C5_NUM
		@ nLin,36 PSAY chr(27)+"W0"
		nLin+=2
		@ nLin,01 PSAY 'Cliente.....: '+Posicione('SA1',1,xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJAENT,'A1_NOME')
		nLin+=2
		@ nLin,01 PSAY 'Ped.Cliente.:'
		@ nLin,16 PSAY SC5->C5_REQCLI
		nLin+=2
		@ nLin,01 PSAY 'C.Custo.....: '+Posicione("LH2",5,xFilial("LH2")+SC5->C5_CLIENTE+SC5->C5_LOJAENT+SC5->C5_CODREQ,"Alltrim(LH2->LH2_CC)+' '+alltrim(LH2->LH2_DESCRC)")
		nLin+=2
		@ nLin,01 PSAY 'Req.: '+SC5->C5_NOMEREQ
		nLin+=2
		@ nLin,01 PSAY 'Dep.: '
		@ nLin,07 PSAY SC5->C5_ENDENT
		@ nLin,08 PSAY SC5->C5_ENDENT
		nLin+=2
		@ nLin,01 PSAY 'Nome do Fornecedor: '+SM0->M0_NOMECOM
		nLin+=2
		@ nLin,01 PSAY 'No. Da Nota Fiscal: ____________________________'
		nLin+=3
	Next
Endif

@ nLin,00 PSAY Chr(18)

SET DEVICE TO SCREEN

If aReturn[5]==1
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return