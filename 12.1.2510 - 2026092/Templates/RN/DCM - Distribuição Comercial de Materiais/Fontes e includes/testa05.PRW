#INCLUDE "rwmake.ch"    
#INCLUDE 'Protheus.CH'
#INCLUDE 'AP5Mail.CH'
#INCLUDE 'TESTA05.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTESTA05   บ Autor ณ EWERTON CARLOS TOM บ Data ณ  31/07/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ ACERTO DE ESTOQUE E PENDENCIA                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TESTA05
Local oEstoque

CHKTEMPLATE("DCM")

Private _cCodPro := Space(TamSX3("B1_COD")[1])
Private _cDescri := Space(40)
Private _cPedido := Space(6)
Private _cLocal  := Space(2)
Private _cJustif := Space(100)
Private _nEstoque:= 0
Private _nEstAtu := 0
Private _nLiberar:= 0
Private _nPenden := 0
Private _nReserva:= 0
Private _nMovto  := 0
Private _lSai    := .T.
Private _lOrdSep := .F.

While _lSai

	DEFINE MSDIALOG oEstoque FROM  63,181 TO 380,600 TITLE STR0001 PIXEL //"Acerto de Pedidos/Estoque"
	@ 008,002 TO  050,200       PIXEL
	@ 002,002 SAY STR0002       PIXEL 	    SIZE  56, 7 //"Dados do Produto"
  	@ 016,004 SAY STR0003       PIXEL      SIZE  21, 7 //"Codigo"
	@ 015,029 GET _cCodPro      PIXEL      SIZE 105, 9 Valid(Busca(1))
	@ 016,150 SAY STR0004       PIXEL      SIZE  25, 7 //"Unidade"
	@ 015,175 GET SB1->B1_UM    PIXEL      SIZE  14, 9 When .F.
	@ 035,004 SAY STR0005       PIXEL      SIZE  32, 7 //"Descricao"
	@ 034,033 GET SB1->B1_DESC  PIXEL      SIZE 135, 9 When .F.
	@ 060,002 TO 112, 200       PIXEL
	@ 054,003 SAY STR0006       PIXEL      SIZE 100, 7 //"Acerto:"
	@ 069,004 SAY STR0007       PIXEL      SIZE  33, 7 //"Pedido"
	@ 069,089 SAY STR0008       PIXEL      SIZE  30, 7 //"Local"
	@ 082,004 SAY STR0009       PIXEL      SIZE  30, 7 //"Estoque"
	@ 082,089 SAY STR0010       PIXEL      SIZE  30, 7 //"Reserva"
	@ 095,004 SAY STR0011       PIXEL      SIZE  30, 7 //"Liberado"
	@ 095,089 SAY STR0012       PIXEL      SIZE  30, 7 //"Pendente"
	@ 068,042 GET _cPedido      PIXEL      SIZE  30, 9 Valid(Busca(2))
	@ 068,124 GET _cLocal       PIXEL      SIZE  10, 9 Valid(Busca(3))
	@ 081,042 GET _nEstoque  Picture "@E 999,999.99" SIZE 40, 9 When .F.          PIXEL
	@ 081,124 GET _nReserva  Picture "@E 999,999.99" SIZE 40, 9 When .F.          PIXEL
	@ 094,042 GET _nLiberar  Picture "@E 999,999.99" SIZE 40, 9 Valid(Busca(5))   PIXEL
	@ 094,124 GET _nPenden   Picture "@E 999,999.99" SIZE 40, 9 Valid(Busca(5).And.Busca(6)) PIXEL
	@ 120,002 TO 140, 200       PIXEL
	@ 114,003 SAY STR0028     SIZE 100, 7 PIXEL //"Justificativa:"       
	@ 125,004 GET _cJustif   Picture "@!" SIZE 190, 9 Valid(!Empty(_cJustif))  PIXEL 
	DEFINE SBUTTON FROM 143,120 TYPE 1 ACTION {||Atualiza(),Close(oEstoque)} ENABLE OF oEstoque  PIXEL
	DEFINE SBUTTON FROM 143,160 TYPE 2 ACTION {||Close(oEstoque),_lSai:=.F.} ENABLE OF oEstoque  PIXEL
	ACTIVATE MSDIALOG oEstoque CENTER
End

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBusca     บAutor  ณMicrosiga           บ Data ณ  08/16/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static Function Busca(_nTipo)
_cAlias := Alias()
If _nTipo = 1
	_cX := Posicione('SB1',1,xFilial('SB1')+_cCodPro,'B1_COD')
	_cLocal := SB1->B1_LOCPAD
ElseIf _nTipo = 2
	_cX := Posicione('SC6',2,xFilial('SC6')+_cCodPro+_cPedido,'C6_NUM')
	_cX := Posicione('SC9',1,xFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM,'C9_PEDIDO')
	_cLocal   := SC6->C6_LOCAL
	_nLiberar := 0
	_nPenden  := 0
	_nMovto   := 0
	_lOrdSep  := .F.
	DbSelectArea('SC9')
	While SC9->(! Eof()) .AND. SC9->C9_FILIAL  == xFilial("SC9")  .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND.;
		SC9->C9_PRODUTO == SC6->C6_PRODUTO .AND. SC9->C9_LOCAL  == SC6->C6_LOCAL
		If !Empty(SC9->C9_NFISCAL)
			DbSkip()
			Loop
		Endif
		If Empty(SC9->C9_BLEST)
			_nLiberar += SC9->C9_QTDLIB
			If  SC9->(FieldPos("C9_ORDSEP")) > 0 .And. !Empty(SC9->C9_ORDSEP)
				_lOrdSep  := .T.
			Endif
		ElseIf SC9->C9_BLEST <> '10' .And. SC9->C9_BLEST <> ''
			_nPenden  += SC9->C9_QTDLIB
		Endif
		_nMovto += SC9->C9_QTDLIB
		DbSkip()
	EndDo
	If _lOrdSep
		MsgStop(STR0029) //"Este item/pedido esta em Ordem de Separacao, favor Estornar antes de efetuar o corte!"
		Return(.F.)
	Endif
	If !Empty(SC6->C6_BLQ)
		MsgStop(STR0030) //"Esse item esta marcado como Residuo, comunique o TI para solucao!"
		Return(.F.)
	Endif
ElseIf _nTipo = 3
	DBSelectArea("SC6")
	DBSetOrder(2) // C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM
	DBSeek(xFilial("SC6")+_cCodPro+_cPedido)
	If SC6->C6_LOCAL <> _cLocal
		MsgStop(STR0013) //"Local do produto invalido !"
		Return(.F.)
	Endif
	
	_cX := Posicione('SB2',1,xFilial('SB2')+_cCodPro+_cLocal,'B2_COD')
	_nEstoque := SB2->B2_QATU
	_nEstAtu  := SB2->B2_QATU
	_nReserva := SB2->B2_RESERVA
ElseIf _nTipo = 4
	_cX := STR0031 //'OK'
	If _nEstAtu < _nReserva
		MsgStop(STR0014) //'Ajuste do estoque nao pode ser maior que as reservas !'
		Return(.F.)
	Endif
ElseIf _nTipo = 5
	_cX := STR0031 //'OK'
	If (_nLiberar > (_nMovto)) .Or. (_nPenden > (_nMovto))
		MsgStop(STR0015+Chr(13)+; //'Quantidade Liberada ou Pendente nao pode ser'
		STR0016) //'  maior que o saldo a entregar do Pedido !'
		Return(.F.)
	ElseIf (_nLiberar + _nPenden) > (_nMovto)
		MsgStop(STR0017+Chr(13)+; //'Quantidade Liberada mais Pendente nao pode ser'
		STR0016) //'  maior que o saldo a entregar do Pedido !'
		Return(.F.)
	Endif
ElseIf _nTipo = 6
	_cX := STR0031 //'OK'
	If (_nLiberar + _nPenden) < (_nMovto)
		MsgStop(STR0017+Chr(13)+; //'Quantidade Liberada mais Pendente nao pode ser'
		STR0018) //'  menor que a quantidade total do Pedido !'
		Return(.F.)
	Endif
Endif
DbSelectArea(_cAlias)
If !Empty(_cX)
	Return(.T.)
Else
	MsgStop(If(_nTipo=1,STR0019,If(_nTipo=2,STR0020,STR0021))+STR0022) //'Produto'###'Pedido'###'Saldo em Estoque'###' nao encontrado !'
Endif
Return(.F.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAtualiza  บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Static Function Atualiza()

If !Busca(6)
	Return(.T.)
Endif  

If MsgYesNo(STR0023+Alltrim(SB1->B1_COD)+' ?') .And. MsgYesNo(STR0024+Alltrim(SC6->C6_NUM)+STR0025+Alltrim(SC6->C6_ITEM)+' ?') //'Confirma a Atualizacao do estoque do produto '###'Confirma a Atualizacao do pedido '###' Item '
	Posicione('SC5',1,xFilial('SC5')+_cPedido,'C5_NUM')
	Posicione('SC9',1,xFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM,'C9_PEDIDO')
	Posicione('SUA',8,xFilial('SUA')+_cPedido,'UA_NUMSC5')
	Posicione('SB2',1,xFilial('SB2')+SC9->(C9_PRODUTO+C9_LOCAL),'B2_COD')
	
	Begin Transaction
	
	_lLib:=_lPen:=.F.
	If _nLiberar > 0
		_lLib := .T.
	Endif
	If _nPenden > 0
		_lPen := .T.
	Endif
	_nSC9Lib := 0
	_nSC9Pen := 0
	_nSequen := 0
	_cLibPre := ''
	If _lLib .Or. _lPen
		DbSelectArea('SC9')
		While SC9->(! Eof()) .AND. SC9->C9_FILIAL  == xFilial("SC9")  .AND. SC9->C9_PEDIDO  == SC6->C6_NUM .AND.;
			SC9->C9_PRODUTO == SC6->C6_PRODUTO .AND. SC9->C9_LOCAL   == SC6->C6_LOCAL
			If !Empty(SC9->C9_NFISCAL)
				DbSkip()
				_nSequen++
				Loop
			Endif
			_cLibPre := SC9->C9_BLPRE
			If Empty(SC9->C9_BLEST)
				_nSC9Lib += SC9->C9_QTDLIB
				RecLock('SC9',.F.)
				SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
				MsUnLock()
				A460Estorna()
			ElseIf SC9->C9_BLEST <> '10' .And. SC9->C9_BLEST <> ''
				_nSC9Pen  += SC9->C9_QTDLIB
				RecLock('SC9',.F.)
				SC9->C9_BLINF   := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
				MsUnLock()
				A460Estorna()
			Endif
			DbSkip()
		EndDo
	Endif
	
	If _lLib
		MaLibDoFat(SC6->(Recno()),_nLiberar,.T.,.T.,.F.,.T.,.T.,.F.) //,{SC6->C6_LOCAL})
	Endif
	If _lPen
		MaLibDoFat(SC6->(Recno()),_nPenden ,.T.,.F.,.F.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
	Endif
	
	If SC5->C5_NUM == SUA->UA_NUMSC5
		If SU7->(FieldPos("U7_EMAIL")) > 0 
			_cEmailOpe := Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_EMAIL")
			_cEmailSup := IIf(SU7->(FieldPos("U7_EMAIL")) > 0,Posicione("SU7",1,xFilial("SU7")+SU7->U7_OPESUP ,"U7_EMAIL"),"")
			_cBody := STR0032+SC5->C5_CLIENTE+" / "+SC5->C5_LOJACLI+" - "+Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI),"A1_NOME")+Chr(13)+Chr(10) //"Cliente: "
			_cBody += STR0033+SC6->C6_ITEM+STR0034+SC6->C6_PRODUTO+STR0035+Alltrim(Str(_nLiberar))+STR0036+Alltrim(Str(_nPenden))+Chr(13)+Chr(10) //"Item: "###" Produto: "###" Liberado: "###" Pendente: "
			_cBody += _cJustif+Chr(13)+Chr(10)
			If !Empty(_cEmailOpe) .Or. !Empty(_cEmailSup)
				T_EnvMail2(STR0037+SC5->C5_NUM, _cBody, _cEmailOpe, _cEmailSup, "", Nil, Nil) //"Corte de Item Liberado:"
				_cBody += STR0038 //"Verificar Estoque do Item para Ajustes."
				// Informar no parametro MV_USUESTC os emails dos usuarios responsaveis pelo estoque
				If !Empty(GetNewPar("MV_USUESTC","",xFilial("SC5")))
					T_EnvMail2(STR0037+SC5->C5_NUM, _cBody, GetMv("MV_USUESTC"),"", "", Nil, Nil) //"Corte de Item Liberado:"
				Endif
			Endif
		Endif
	Endif
	SB2->(MsUnLock())
	
	End Transaction
	DbCommitAll()
	
	MsgBox(STR0026,STR0027,'INFO') //'Operacao Concluida !'###'Acerto de Estoque'
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnvMail1  บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Template Function EnvMail1(_cSubject, _cBody, _cMailTo, _cCC, _cAnexo, _cConta, _cSenha)
Local _cMailS		:= GetMv("MV_RELSERV")
Local _cAccount		:= IIf(_cConta=Nil,GetMV("MV_RELACNT"),_cConta)
Local _cPass		:= IIf(_cSenha=Nil,GetMV("MV_RELFROM"),_cSenha)
Local _cSenha2		:= GetMV("MV_RELPSW")
Local _cUsuario2	:= GetMV("MV_RELACNT")
Local lAuth			:= GetMv("MV_RELAUTH",,.F.)

ConOut(STR0039 + _cSubject + STR0040 + _cMailTo) //"Enviando e-mail - "###" - para "

Connect Smtp Server _cMailS Account _cAccount Password _cPass RESULT lResult

If lAuth		// Autenticacao da conta de e-mail 
	lResult := MailAuth(_cUsuario2, _cSenha2)
	If !lResult
		ConOut(STR0041 + _cUsuario2) //"Nao foi possivel autenticar a conta - "
		Return()
	EndIf
EndIf
                                                          
_xx := 0        

lResult := .F.

Do while !lResult
	
	If !Empty(_cAnexo)
		Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody ATTACHMENT _cAnexo RESULT lResult
	Else
		Send Mail From _cAccount To _cMailTo CC _cCC Subject _cSubject Body _cBody RESULT lResult
	Endif
	
	_xx++
	if _xx > 2
		Exit
	Else
		Get Mail Error cErrorMsg
		ConOut(cErrorMsg)
	EndIf
EndDo

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEnvMail2  บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Template Function envMail2(cVar1,cVar2,cVar3,cVar4,cVar5,Var6)
Private mCorpo       := cVar2
Private cAssunto     := cVar1 + space(250)
Private nLineSize    := 60
Private nTabSize     := 3
Private lWrap        := .T.
Private nLine        := 0
Private cTexto       := ""
Private lServErro		:= .T.
private cDe          := cVar3
private cPara        := cVar4 + space(250)
private cCC          := space(250)

private _cArquivo  := "" //rtrim(cDirHtml)+"\OR"+M->UA_NUM+".htm"
private _cAnexo    := "" //rtrim(cDirHtml)+"\OR"+M->UA_NUM+".htm"

private _nValidade := 5
private _nEntrega  := 2
private _cCondPag  := space(03)
private _lSairTela := .F.
Private cOriMail   := ""
Private cSenhaEm   := ""

SU7->(DbSetOrder(1)) 
If SU7->(FieldPos("U7_EMAIL")) == 0 .Or. Type("M->UA_OPERADO") == "U"
	Return .T.
Endif

if SU7->(dbSeek(xFilial("SU7")+M->UA_OPERADO))
	if !empty(SU7->U7_EMAIL)
		cOriMail := SU7->U7_EMAIL
		cSenhaEm := SU7->U7_SENHA
	ElseIf !Empty(GetMv("MV_EMCONTA")) .And. !Empty(GetMv("MV_EMSENHA"))
		cOriMail :=GetMv("MV_EMCONTA")
		cSenhaEm :=GetMv("MV_EMSENHA")
	Else
		msgAlert(STR0042) //"Problemas com o e-mail do operador. Contate o administrador do sistema."
		return
	Endif
Else
	msgStop(STR0043) //"Operador nao encontrado."
	return
Endif

// cria interface
@ 122,57 To 511,833 Dialog maildlg Title oEmToAnsi(STR0044) //"Envio de E-Mail "
@ 01,2 To 09,46
@ 10,2 To 13,46
@ 01.5, 03 Say oEmToAnsi(STR0045)  Size 030,08 //"De: "
@ 02.5, 03 Say oEmToAnsi(STR0046)  Size 025,08 //"Para: "
@ 03.5, 03 Say oEmToAnsi(STR0047)  Size 030,08 //"Cc: "
@ 04.5, 03 Say oEmToAnsi(STR0048)  Size 030,08 //"Assunto: "
@ 01.5, 06 Get cDe                 Size 270,10 When .F.
@ 02.5, 06 Get cPara               Size 270,10 //oBject oPara
@ 03.5, 06 Get cCC                 Size 270,10 //oBject oCC
@ 04.5, 06 Get cAssunto            Size 270,10
@ 05.5, 03 Get mCorpo MEMO         Size 292,50                                       
/*
//@ 59,15 say oemToAnsi("Anexar: ")  size 30,8
//@ 58,40 get _cAnexo     size 270,10 when .F.
*/
@ 15,06 Button oEmToAnsi("&Enviar") Size 36,16 Action iif(!Empty(cPara),Close(maildlg),MsgAlert(STR0050)) ////STR0049###"E-Mail sem destinatario."
@ 15,16 Button oEmToAnsi("&Sair")   Size 36,16 Action FechaTela() //"_Sair"
Activate Dialog Maildlg Centered
If _lSairTela
	Return
Endif

//orcHtml(_cArquivo) // gera HTML
lServERRO :=.F.

cDe 	  := RTrim(cDe)
cPara     := RTrim(cPara)
cCC		  := If(Empty(cCC),"",RTrim(cCC))
cAssunto  := RTrim(cAssunto)

T_EnvMail1(cAssunto, mCorpo, cPara, cCC, _cAnexo, cOriMail, cSenhaEm)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFechaTela บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static function FechaTela()
_lSairTela :=.T.
Close(maildlg)
Return