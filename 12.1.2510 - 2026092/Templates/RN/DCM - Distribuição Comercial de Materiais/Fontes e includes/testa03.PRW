#INCLUDE "testa03.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TESTA03a  º Autor ³ EWERTON C TOMAZ    º Data ³  09/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ MarkBrowse com filtro de pedidos para liberacao do confe-  º±±
±±º          ³ rente                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Template Function TESTA03a

CHKTEMPLATE("DCM")  
T_TESTA03(1)
Return

///////////////////////////////
//////////////////////////////
Template Function TESTA03b

CHKTEMPLATE("DCM")  
T_TESTA03(2)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TESTA03   ºAutor  ³Microsiga           º Data ³  08/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Template Function TESTA03(_nTipo)

Local aCposBrw    := {}
Local aStruTC9    := {}
Local cArq        := ""
Local lInverte    := .F.
Local _cMarca     := GetMark()
Local _nX

CHKTEMPLATE("DCM")

Private cCadastro := If(_nTipo == 1, STR0001, STR0002) //"Pedidos somente com bloqueio do conferente" ## "Pedidos para estorno de conferencia"
Private cDelFunc  := ".T."
Private cString   := "SC9"
Private _oBrwPed  := ""
Private _nCount   := 0
Private _cPesqPed := Space(TamSX3("C9_PEDIDO")[01])

aAdd(aCposBrw,{"C9_OK",      "",""})
aAdd(aCposBrw,{"C9_PEDIDO",  "",""})
aAdd(aCposBrw,{"C9_ITEM",    "",""})
aAdd(aCposBrw,{"C9_SEQUEN",  "",""})
aAdd(aCposBrw,{"B1_CODBAR",  "",""})
aAdd(aCposBrw,{"C6_DESCRI",  "",""})
aAdd(aCposBrw,{"C9_QTDLIB",  "",""})
aAdd(aCposBrw,{"C9_PRODUTO", "",""})
aAdd(aCposBrw,{"C9_CLIENTE", "",""})
aAdd(aCposBrw,{"C9_DATALIB", "",""})
aAdd(aCposBrw,{"C5_VEND1",   "",""})
aAdd(aCposBrw,{"B1_COD",     "",""})

aAdd(aStruTC9,{"C9_OK", "C", 2, 0})

DbSelectArea('SX3')
DbSetOrder(2)	//X3_CAMPO
For _nX := 2 To Len(aCposBrw)
	If DbSeek(Padr(aCposBrw[_nX,01],Len(SX3->X3_CAMPO)))
		aCposBrw[_nX][02] := SX3->X3_PICTURE
		aCposBrw[_nX][03] := X3Titulo()
		aAdd(aStruTC9, {aCposBrw[_nX,01], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
	EndIf
Next _nX
DbSelectArea('SX3')
DbSetOrder(1)	//X3_ARQUIVO+X3_ORDEM

cArq	:= Criatrab(aStruTC9,.T.)
dBUseArea(.T.,,cArq,"TC9")
DbSelectArea('TC9')

@ 100,005 TO 500,770 DIALOG oDlgPedL TITLE cCadastro
_oBrwPed := MsSelect():New("TC9" /*<cAlias>*/,;
                           "C9_OK" /*[cCampo]*/,;
                           /*[cCpo]*/,;
                           aCposBrw /*[aCampos]*/,;
                           @lInverte /*[lInv]*/,;
                           @_cMarca /*[cMar]*/,;
                           {006,005,190,325} /*<aCord>*/,;
                           /*[cTopFun]*/,;
                           /*[cBotFun]*/,;
                           /*<oWnd>*/,;
                           /*[uPar11]*/,;
                           /*[aColors]*/)
@ 006,330 BUTTON STR0003 SIZE 50,15 ACTION Confirma(_nTipo) //"_Confirma Conf."
@ 026,330 BUTTON STR0004 SIZE 50,15 ACTION Eval({|| TC9->(MarcaPed()), _oBrwPed:oBrowse:Refresh(), DlgRefresh(oDlgPedL)}) //"_Marca/Desmarca"
If _nTipo == 1
	@ 046,330 BUTTON STR0005 SIZE 50,15 ACTION Acerto() //"_Ajuste Pedido"
	@ 066,330 BUTTON STR0006 SIZE 50,15 ACTION BuscaPed() //"_Ajuste Volume"
Endif
@ 183,330 BUTTON STR0007 SIZE 50,15 ACTION Close(oDlgPedL) //"_Sair"

Processa({|| Monta_TC9(_nTipo, aStruTC9)}, STR0008) //"Selecionando Informacoes dos Pedidos..."

@ 193,005 SAY STR0009 + Alltrim(Str(_nCount,6,0))+STR0010 //"Foram processados "###" registro(s)"
/*
@ If(_nTipo=1,086,046),330 SAY STR0011 //"Pesquisa Pedido"
@ If(_nTipo=1,096,056),335 GET _cPesqPed    Valid Pesquisa() F3 "SC5"
*/
_oBrwPed:oBrowse:Refresh()
ACTIVATE DIALOG oDlgPedL CENTERED

DbSelectArea("TC9")
DbCloseArea()
FErase(cArq+OrdBagExt())

Return(.T.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Confirma  ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Static Function Confirma(_nTipoPar)

Local _lLib := .F.
Local _cPed := ''

If !( MsgYesNo(STR0012 + If(_nTipoPar == 1, STR0013, STR0014) + STR0015) ) //'Confirma a '###'liberacao'###'estorno'###' dos pedidos marcados ?'
	Return(.T.)
Endif
DbSelectArea('TC9')
TC9->(DbGoTop())
While TC9->(! Eof())
	If Trim(TC9->C9_OK) == ThisMark()
		DbSelectArea('SC9')
		SC9->(DbSetOrder(1))
		If SC9->(DbSeek(xFilial('SC9')+TC9->C9_PEDIDO+TC9->C9_ITEM+TC9->C9_SEQUEN))
			While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .And. SC9->C9_PEDIDO == TC9->C9_PEDIDO .AND. SC9->C9_ITEM == TC9->C9_ITEM .AND. SC9->C9_SEQUEN == TC9->C9_SEQUEN
				If !( Empty(SC9->C9_CARGA) ) .And. _nTipoPar <> 1
					MsgStop(STR0016 + TC9->C9_PEDIDO + STR0017 + SC9->C9_CARGA + STR0018) //'Pedido: '###' nao pode ser Estornado, pois esta na carga: '###' Contacte Depto Logistica.'
					Return(.T.)
				Endif
				If ALLTRIM(SC9->C9_BLEST) == ''
					SC9->(RecLock('SC9',.F.))
					SC9->C9_BLCONF := If(_nTipoPar == 1, 'OK', '')
					SC9->C9_BLINF  := RTRIM(FUNNAME())+' '+Upper(cUserName)+" "+dtoc(Date())+" "+time()+" h"
					SC9->(MsUnLock())
					_lLib := .T.
					If _cPed <> TC9->C9_PEDIDO .And. _nTipoPar == 1
						BuscaPed(TC9->C9_PEDIDO)
						_cPed := TC9->C9_PEDIDO
					Endif
					DbSelectArea('TC9')
					TC9->(RecLock('TC9',.F.))
					TC9->(DbDelete())
					TC9->(MsUnlock())
					Exit
				Endif
				SC9->(DbSkip())
			EndDo
		Endif
		DbSelectArea('TC9')
	EndIf
	TC9->(DbSkip())
EndDo
If !( _lLib )
	MsgBox(If(_nTipoPar == 1, STR0019, STR0020) + STR0021, STR0022, 'INFO') //'Liberacoes'###'Estornos'###' efetuadas com sucesso !'###'Conferencia'
	TC9->(DbGoTop())
	SysRefresh()
Else
	MsgStop(STR0023 + If(_nTipoPar == 1, STR0024, STR0025)) //'Nenhum pedido marcado para '###'liberacao !'###'estorno !'
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pesquisa  ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
Static FUNCTION Pesquisa()
If !Empty(_cPesqPed)
   DbSeek(_cPesqPed)
   SysRefresh()
Endif
Return(.T.)
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MarcaPed  ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Static Function MarcaPed()

Local _cPedCorr := TC9->C9_PEDIDO
Local _nRecTC9 := TC9->(Recno())

While TC9->(! Eof()) .And. TC9->C9_PEDIDO == _cPedCorr
   TC9->(RecLock('TC9',.F.))
   TC9->C9_OK := If(Empty(TC9->C9_OK), ThisMark(), Space(Len(TC9->C9_OK)))
   TC9->(MsUnlock())
   TC9->(DbSkip())
EndDo
TC9->(DbGoTo(_nRecTC9))
SysRefresh()
Return(.T.)     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Acerto    ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Static Function Acerto()

T_TESTA05()
MsgStop(STR0026) //'Voce deve reiniciar a rotina de conferencia !'
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Monta_TC9 ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Static Function Monta_TC9(_nTipoPar, aStruTC9)

Local _nX
Local cQueryCad	:= ""
Local _cArqSel2	:= RetSqlName("SC5")+" , " + RetSqlName("SC6")+" , " + RetSqlName("SC9")+" , " + RetSqlName("SB1")
Local lMrkAutom	:= .T.
Local nTamC9OK	:= Len(TC9->C9_OK)

_nCount := 0

For _nX := 1 To 2
	If _nX == 1
		cQueryCad := "SELECT Count(*) AS TOTAL FROM "+_cArqSel2+" WHERE "
	Else
		cQueryCad := "SELECT "
		cQueryCad += "C9_PEDIDO, C9_ITEM, C9_SEQUEN, B1_CODBAR, C6_DESCRI, C9_QTDLIB, C9_PRODUTO, C9_CLIENTE, C9_DATALIB, C5_VEND1, B1_COD "
		cQueryCad += "FROM "+_cArqSel2+" WHERE "
	Endif
	cQueryCad += RetSqlName("SC9")+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += RetSqlName("SC5")+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += RetSqlName("SC6")+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += RetSqlName("SB1")+".D_E_L_E_T_ <> '*' AND "
	cQueryCad += "C9_PEDIDO = C5_NUM AND "
	cQueryCad += "C9_PEDIDO = C6_NUM AND "
	cQueryCad += "C9_PRODUTO = C6_PRODUTO AND "
	cQueryCad += "C9_PRODUTO = B1_COD AND "
	cQueryCad += "C9_FILIAL = '"+xFilial("SC9")+"' AND "
	cQueryCad += "C5_FILIAL = '"+xFilial("SC5")+"' AND "
	cQueryCad += "C6_FILIAL = '"+xFilial("SC6")+"' AND "
	cQueryCad += "B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cQueryCad += "C9_BLEST = ' ' AND "
	If _nTipoPar == 1
		cQueryCad += "C9_BLCONF = ' ' AND "
		cQueryCad += "C9_BLEST  = ' ' AND "
		cQueryCad += "C9_BLCRED = ' ' AND "
		cQueryCad += "C9_BLPRE  <> ' ' "
	Else
		cQueryCad +=	"C9_BLCONF = 'OK' "
	Endif
	If _nX == 2
		cQueryCad += "ORDER BY C9_PEDIDO, C9_ITEM, C9_SEQUEN"
	Endif

	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX == 1
		_nCount := CAD->TOTAL
		DbCloseArea()
	Endif
Next

TcSetField("CAD","C9_DATALIB","D")
DbSelectArea("CAD")

If	CAD->(! Eof())
	lMrkAutom	:= MsgNoYes(STR0036, cCadastro)	//"Confirma a marcação automática de todos os pedidos encontrados?"
EndIf

ProcRegua(_nCount)

While CAD->(! Eof())
	IncProc()
	TC9->(RecLock("TC9",.T.))
	For _nX := 1 To Len(aStruTC9)
		If aStruTC9[_nX,1] <> 'C9_OK'
			If aStruTC9[_nX,2] == 'C'
				_cX := 'TC9->'+aStruTC9[_nX,1]+' := Alltrim(CAD->'+aStruTC9[_nX,1]+')'
			Else
				_cX := 'TC9->'+aStruTC9[_nX,1]+' := CAD->'+aStruTC9[_nX,1]
			Endif
			_cX := &_cX
		Endif
	Next
	TC9->C9_OK := If(lMrkAutom, ThisMark(), Space(nTamC9OK))
	TC9->(MsUnLock())
	CAD->(DBSkip())
EndDo
DbSelectArea("CAD")
DbCloseArea()
DbSelectArea("TC9")
DbGoTop()

_cIndex := Criatrab(Nil,.F.)
_cChave := "C9_PEDIDO+C9_ITEM+C9_SEQUEN"
IndRegua("TC9", _cIndex, _cChave, , , STR0027) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex + OrdBagExt())

SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaPed  ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function BuscaPed(_cPed)

Private oLocal
Private _cVolume  := Space(3)
Private _nPesol   := 0
Private _nPbruto  := 0
Private _nCubagem := 0
Private _cPedido  := If(_cPed == NIL, Space(6), _cPed)

DbSelectArea('SC5')
DbSetOrder(1)
If DbSeek(xFilial('SC5')+_cPedido)
   _cVolume := Str(SC5->C5_VOLUME1,3)
   _nPesol  := SC5->C5_PESOL
   _nPbruto := SC5->C5_PBRUTO
   _nCubagem:= SC5->C5_CUBAGEM
   DEFINE MSDIALOG oLocal FROM 63,181 TO 220,390 TITLE STR0028+_cPedido PIXEL //"Pedido:"
   @ 003,005 TO 060,105
   @ 013,007 SAY STR0029                           SIZE 60, 7    //"Informe a Qtde:"
   @ 012,055 GET _cVolume                          SIZE 39, 9 
   @ 023,007 SAY STR0030                           SIZE 60, 7    //"Peso Liquido:"
   @ 022,055 GET _nPesol   PICTURE "@E 999,999.99" SIZE 39, 9 
   @ 033,007 SAY STR0031                           SIZE 60, 7    //"Peso Bruto:"
   @ 032,055 GET _nPbruto  PICTURE "@E 999,999.99" SIZE 39, 9 
   @ 043,007 SAY STR0032                           SIZE 60, 7    //"Cubagem   :"
   @ 042,055 GET _nCubagem PICTURE "@E 999,999.99" SIZE 39, 9 
   DEFINE SBUTTON FROM 065,010 TYPE 1 ACTION {||Grava(),Close(oLocal)} ENABLE OF oLocal
   DEFINE SBUTTON FROM 065,040 TYPE 2 ACTION Close(oLocal) ENABLE OF oLocal
   ACTIVATE MSDIALOG oLocal CENTER
ElseIf Empty(_cPedido)
   DEFINE MSDIALOG oLocal FROM 63,181 TO 240,390 TITLE STR0033 PIXEL //"Altera Volume"
   @ 003,005 TO 070,105
   @ 013,007 SAY STR0034                           SIZE 60, 7 //"Informe o Pedido:"
   @ 012,055 GET _cPedido                          SIZE 29, 9 Valid(BuscaPed2(_cPedido))
   @ 023,007 SAY STR0029                           SIZE 60, 7    //"Informe a Qtde:"
   @ 022,055 GET _cVolume                          SIZE 39, 9 
   @ 033,007 SAY STR0030                           SIZE 60, 7    //"Peso Liquido:"
   @ 032,055 GET _nPesol   PICTURE "@E 999,999.99" SIZE 39, 9 
   @ 043,007 SAY STR0031                           SIZE 60, 7    //"Peso Bruto:"
   @ 042,055 GET _nPbruto  PICTURE "@E 999,999.99" SIZE 39, 9 
   @ 053,007 SAY STR0032                           SIZE 60, 7    //"Cubagem   :"
   @ 052,055 GET _nCubagem PICTURE "@E 999,999.99" SIZE 39, 9 
   DEFINE SBUTTON FROM 075,010 TYPE 1 ACTION {||Grava(),Close(oLocal)} ENABLE OF oLocal
   DEFINE SBUTTON FROM 075,040 TYPE 2 ACTION Close(oLocal) ENABLE OF oLocal
   ACTIVATE MSDIALOG oLocal CENTER
Endif   

If ExistBlock("TESTA03ETQ")
	ExecBlock("TESTA03ETQ")
Else
	If (! Empty(SC5->C5_REQCLI) .Or. ! Empty(SC5->C5_NOMEREQ) .Or. ! Empty(SC5->C5_ENDENT)).and.(val(_cVolume)+_nPesol+_nPbruto) >0 .And. GetMv('MV_IMPETIC')='S'
	   T_TESTR02(_cPedido,Val(_cVolume))
	Endif   
EndIf
	
Return	.T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaPed2 ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Static Function BuscaPed2(_cPedido)

DbSelectArea("SC5")
DbSetOrder(1)
If !DbSeek(xFilial('SC5')+_cPedido)
   MsgStop(STR0035) //'Pedido nao encontrado'
   Return(.F.) 
Endif
_cVolume  := Str(SC5->C5_VOLUME1,3)
_nPesol   := SC5->C5_PESOL
_nPbruto  := SC5->C5_PBRUTO
_nCubagem := SC5->C5_CUBAGEM
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Grava     ºAutor  ³Microsiga           º Data ³  08/18/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grava()

If (Val(_cVolume) + _nPesol + _nPbruto) > 0
   DbSelectArea("SC5")
   Reclock("SC5",.F.)
   SC5->C5_VOLUME1 := Val(_cVolume)
   SC5->C5_PESOL   := _nPesol
   SC5->C5_PBRUTO  := _nPbruto
   SC5->C5_CUBAGEM := _nCubagem
   Msunlock()
EndIf
Return(.T.)
