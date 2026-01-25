#INCLUDE "tfata01.ch"
#INCLUDE "Protheus.ch"  
#INCLUDE "rwmake.ch"  
      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TFATA01   ºAutor  ³Ewerton Carlos Tomazº Data ³  07/24/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela pra ajuste de dados do cabeçalho do pedido            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
--> Alterado em 25/10/2004 para efetuar a gravação do C5_KDD com o desenvolvimento do 
    pondo de entrada para o Tipo Setorial
*/

Template Function TFATA01

CHKTEMPLATE("DCM")  

Private oLocal
Private _cPedido  := Space(6)
Private _cTPFrete := ""
Private aItems    := {"",STR0001,STR0002} //"CIF"###"FOB"
Private aItems2   := {"",STR0003,STR0004} //"Sim"###"Nao"
Private aItems3   := {"",STR0003,STR0004} //"Sim"###"Nao"
Private _cMennota := Space(90)
Private _cMenint  := Space(80)
Private _cMenint2 := Space(80)
Private _cTransp  := Space(6)
Private _cRedesp  := Space(6)
Private _cCond    := Space(3)
Private _cCliente := Space(6)
Private _cNome    := Space(25)
Private _cAglut   := Space(1)
Private _cFatInt  := Space(1)
Private _nVolume  := 0
Private _nPesoLiq := 0.00
Private _nPesoBru := 0.00
Private _nCubagem := 0.00
Private _cEndEnt  := ""
Private _cBairro  := ""
Private _cMune    := ""
Private _cEst     := ""
Private _cCEP     := ""
Private _cVendedor:= ""
Private _cCondEsp := Space(02)
Private oNome

DEFINE MSDIALOG oLocal FROM 63,181 TO 530,690 TITLE STR0005 PIXEL //"Informacoes Pedido"
@ 003,005 TO 206,250
@ 012,007 SAY STR0006 SIZE  60, 7 //"Informe o Pedido:"
@ 012,060 GET _cPedido SIZE  29, 9 Valid(BuscaPed2(_cPedido)) F3 ("SC5")
@ 13,98 SAY oNome VAR _cNome OF oLocal Pixel 
@ 024,007 SAY STR0007 SIZE  60, 7 //"Tipo de Frete:"
@ 024,060 COMBOBOX _cTPFrete ITEMS aItems SIZE 35,9
@ 036,007 SAY STR0008 SIZE  60, 7 //"Mensagem da Nota:"
@ 036,060 GET _cMennota   SIZE 180, 9
@ 048,007 SAY STR0009 SIZE  60, 7 //"Transportadora:"
@ 048,060 GET _cTransp SIZE 40, 9 VALID .T. F3 "SA4"
@ 048,110 SAY STR0010 SIZE  60, 7 //"Redespacho:"
@ 048,148 GET _cRedesp SIZE 40, 9 VALID .T. F3 "SA4"
@ 060,007 SAY STR0011 SIZE  60, 7 //"Cond.Pagto:"
@ 060,060 GET _cCond SIZE 30, 9 VALID .T. F3 "SE4"
@ 072,007 SAY STR0012 SIZE  60, 7 //"Aglutina Pedido:"
@ 072,060 COMBOBOX _cAglut ITEMS aItems2 SIZE 35,9
@ 072,100 SAY STR0013 SIZE  60, 7 //"Fatura Integral:"
@ 072,138 COMBOBOX _cFatInt ITEMS aItems3 SIZE 35,9

@ 084,007 SAY STR0014 SIZE  60, 7 //"Volumes:"
@ 084,060 GET _nVolume PICTURE "@E 999999" SIZE 30, 9 VALID .T.
@ 096,007 SAY STR0015 SIZE  60, 7 //"Peso Liquido:"
@ 096,060 GET _nPesoLiq PICTURE "@E 999,999.99" SIZE 40, 9 VALID .T.
@ 096,105 SAY STR0016 SIZE  60, 7 //"Peso Bruto:"
@ 096,135 GET _nPesoBru PICTURE "@E 999,999.99" SIZE 40, 9 VALID .T.
@ 096,180 SAY STR0017 SIZE  60, 7 //"Cubagem:"
@ 096,208 GET _nCubagem PICTURE "@E 999,999.99" SIZE 40, 9 VALID .T.

@ 108,007 SAY STR0018 SIZE  60, 7 //"Endereco Entrega:"
@ 108,060 GET _cEndEnt SIZE 180, 9 VALID .T.
@ 120,007 SAY STR0019 SIZE  60, 7 //"Bairro Entrega:"
@ 120,060 GET _cBairro SIZE 60, 9 VALID .T.
@ 120,135 SAY STR0020 SIZE  65, 7 //"Cidade Entrega:"
@ 120,188 GET _cMune SIZE 60, 9 VALID .T.
@ 132,007 SAY STR0021 SIZE  60, 7 //"Estado Entrega:"
@ 132,060 GET _cEst SIZE 15, 9 VALID .T.
@ 132,135 SAY STR0022 SIZE  60, 7 //"CEP Entrega:"
@ 132,188 GET _cCEP SIZE 30, 9 VALID .T.

@ 144,007 SAY STR0023 SIZE  60, 7 //"Vendedor:"
@ 144,060 GET _cVendedor SIZE 30, 9 VALID .T.

@ 156,007 SAY STR0024 SIZE  60, 7 //"Mensagem Interna:"
@ 156,060 GET _cMenInt    SIZE 180, 9
@ 168,060 GET _cMenInt2   SIZE 180, 9

//------------------------------------------------------------------------------------------------
//Adicionado por Luciano em 24/09/2004 para tratamento da Rotina desenvolvida por mauricio correia
// Gerar condição especial para Koraicho
 //------------------------------------------------------------------------------------------------
//@ 182,007 SAY STR0025 SIZE  60, 7 //"Condicao Especial"
//@ 182,060 GET _cCondEsp  SIZE 10, 9 VALID (val(_cCondEsp) == 0 .or. val(_cCondEsp) >= 50)

DEFINE SBUTTON FROM 210,010 TYPE 1 ACTION {||Grava(),Close(oLocal)} ENABLE OF oLocal
DEFINE SBUTTON FROM 210,040 TYPE 2 ACTION Close(oLocal) ENABLE OF oLocal
DEFINE SBUTTON FROM 210,190 TYPE 11 ACTION Multiline() ENABLE OF oLocal
ACTIVATE MSDIALOG oLocal CENTER
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BuscaPed2 ºAutor  ³Microsiga           º Data ³  08/03/05   º±±
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
	MsgStop(STR0026) //'Pedido nao encontrado'
	Return(.F.)
Endif
If !Empty(Posicione('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_CODOBS'))
	DbSelectArea('SYP')
	DbSetOrder(1)
	_cObsSyp := ''
	If DbSeek(xFilial('SYP')+SUA->UA_CODOBS)
		While SYP->(! Eof()) .AND. SYP->YP_FILIAL == xFilial('SYP') .AND. SYP->YP_CHAVE == SUA->UA_CODOBS
			_cObsSyp += RTRIM(STRTRAN(STRTRAN(STRTRAN(SYP->YP_TEXTO,CHR(13),""),CHR(10),""),'\13\10',""))
			DbSkip()
		End
	Endif
	_cObsSyp := Rtrim(LTrim(_cObsSyp))
	_cMenInt := SubStr(_cObsSyp,1,80)
	_cMenInt2:= SubStr(_cObsSyp,81,80)	
	DbSelectArea('SC5')
Endif
_cTPFreteCad := SC5->C5_TPFRETE
_cMennota    := SC5->C5_MENNOTA
_cTransp     := SC5->C5_TRANSP
_cRedesp     := SC5->C5_REDESP
_cCond       := SC5->C5_CONDPAG
_cCliente    := SC5->C5_CLIENTE
_cEndEnt     := SC5->C5_ENDENT
_cBairro     := SC5->C5_BAIRROE
_cMune       := SC5->C5_MUNE
_cEst        := SC5->C5_ESTE
_cCEP        := SC5->C5_CEPE
_cVendedor   := SC5->C5_VEND1

If _cTPFreteCad ='C'
	_cTPFrete :=aItems[2]
ElseIf _cTPFreteCad ='F'
	_cTPFrete :=aItems[3]
EndIf
If SC5->C5_AGLUTIN = 'S'
	_cAglut := aItems2[2]
ElseIf SC5->C5_AGLUTIN = 'N'
	_cAglut := aItems2[3]
Endif
If SC5->C5_FATINT = 'S'
	_cFatInt := aItems3[2]
ElseIf SC5->C5_FATINT = 'N'
	_cFatInt := aItems3[3]
Endif
_nVolume  := SC5->C5_VOLUME1
_nPesoLiq := SC5->C5_PESOL
_nPesoBru := SC5->C5_PBRUTO
_nCubagem := SC5->C5_CUBAGEM

DbSelectArea("SA1")
DbSetOrder(1)
If !dbSeek(xFilial('SA1')+_cCliente)
	msgStop(STR0027) //'Cliente nao encontrado.'
	@ 013,90 SAY Space(25)
	Return(.F.)
Else
	_cNome :=SubStr(SA1->A1_NOME,1,25)
Endif    
oNome:Refresh()

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Grava     ºAutor  ³Microsiga           º Data ³  08/03/05   º±±
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
DbSelectArea("SC5")
Reclock("SC5",.F.)
SC5->C5_TPFRETE := substr(_cTPFrete,1,1)
SC5->C5_MENNOTA := _cMennota
SC5->C5_TRANSP  := _cTransp
SC5->C5_REDESP  := _cRedesp
SC5->C5_CONDPAG := _cCond
SC5->C5_AGLUTIN := substr(_cAglut,1,1)
SC5->C5_FATINT  := substr(_cFatInt,1,1)
SC5->C5_VOLUME1 := _nVolume
SC5->C5_PESOL   := _nPesoLiq
SC5->C5_PBRUTO  := _nPesoBru
SC5->C5_CUBAGEM := _nCubagem
SC5->C5_ENDENT  := _cEndEnt
SC5->C5_BAIRROE := _cBairro
SC5->C5_MUNE    := _cMune
SC5->C5_ESTE    := _cEst
SC5->C5_CEPE    := _cCEP

If _cVendedor <> SC5->C5_VEND1
	DbSelectArea("SC9")
	DbSetOrder(1)
	If DbSeek(xFilial('SC9')+_cPedido)
		While SC9->(!Eof()) .And. SC9->C9_FILIAL == xFilial('SC9') .And. SC9->C9_PEDIDO == _cPedido
			DbSelectArea("SC9")
			Reclock("SC9",.F.)
			SC9->C9_VEND := _cVendedor
			Msunlock()
			SC9->(dbSkip(1))
		End
	End
	DbSelectArea("SC5")
	SC5->C5_VEND1   := _cVendedor
End
Msunlock()
If !( Empty(_cMenInt) ) .Or. !( Empty(_cMenInt2) )
    If !( Empty(Posicione('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_CODOBS')) )
	   DbSelectArea('SYP')
	   DbSetOrder(1)
	   If DbSeek(xFilial('SYP')+SUA->UA_CODOBS)
	      While SYP->(! Eof()) .AND. SYP->YP_FILIAL == xFilial('SYP') .AND. SYP->YP_CHAVE == SUA->UA_CODOBS
		   	RecLock('SYP',.F.)
		   	DbDelete()
		   	MsUnLock()
			DbSkip()
		  End
	   Endif  
	Endif
	DbSelectArea('SYP')
	RecLock('SYP',.T.)
    _cChave := GetSX8Num('SYP','YP_CHAVE')
    ConfirmSx8()
    SYP->YP_FILIAL := xFilial('SYP')
    SYP->YP_CHAVE  := _cChave
    SYP->YP_SEQ    := '001'
    SYP->YP_TEXTO  := _cMenInt
    SYP->YP_CAMPO  := 'UA_CODOBS'
    MsUnLock()
    If !( Empty(_cMenInt2) )
       RecLock('SYP',.T.)
       SYP->YP_FILIAL := xFilial('SYP')
       SYP->YP_CHAVE  := _cChave
       SYP->YP_SEQ    := '002'
       SYP->YP_TEXTO  := _cMenInt2
       SYP->YP_CAMPO  := 'UA_CODOBS'
       MsUnLock()
    Endif
	If SUA->UA_NUMSC5 == SC5->C5_NUM
	   DbSelectArea('SUA')
	   RecLock('SUA',.F.)
	   SUA->UA_CODOBS := SYP->YP_CHAVE
	   MsUnLock()
	Endif   
Endif
DbSelectArea('SC5')
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Multiline ºAutor  ³Microsiga           º Data ³  08/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Multiline()

Private aColsCCust := {}  // Variável utilizada na validação do gatilho do C6_PRODUTO
Private l410Auto   := .F. // Variável utilizada na validação do gatilho do C6_PRODUTO

@ 63,1 TO 530,797 DIALOG oDlg3 TITLE STR0028+SC5->C5_NUM //"Manutencao Comissao Pedido: "
aHeader := {}
nUsado := 0
DbSelectArea('SX3')
DbSeek('SC6')
_nRecno := Recno()
While !EOF() .And. X3_ARQUIVO == 'SC6'
	If x3_usado != " " .And. cNivel >= X3_NIVEL .And. Alltrim(X3_CAMPO) $ "C6_ITEM/C6_PRODUTO/C6_DESCRI/C6_PRCVEN/C6_VALOR/C6_COMISSA/C6_PERCOM"
		nUsado++
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		               X3_TAMANHO, X3_DECIMAL, IIF(Alltrim(X3_CAMPO)='C6_PERCOM','T_CalcCom(1)',''),;
		               X3_USADO, X3_TIPO, X3_ARQUIVO } )
	EndIf
	DbSkip()
EndDo
DbGoTo(_nRecno)
While !EOF() .And. X3_ARQUIVO == 'SC6'
	If x3_usado != " " .And. cNivel >= X3_NIVEL .And. Alltrim(X3_CAMPO) $ "C6_TES/C6_CF"
		nUsado++
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
		               X3_TAMANHO, X3_DECIMAL, '',;
		               X3_USADO, X3_TIPO, X3_ARQUIVO } )
	EndIf
	DbSkip()
End
DbSelectArea( "SC6" )
DbSetOrder(1)
DbSeek(xFilial("SC6")+SC5->C5_NUM)
_nRecno := Recno()
nCnt := 0
While SC6->(! EOF()) .And. SC6->C6_FILIAL == xFilial('SC6') .AND. SC6->C6_NUM == SC5->C5_NUM
	nCnt++
	DbSkip()
End
aCOLS := Array(nCnt,nUsado+1)
DbGoTo(_nRecno)
nCnt := 0
While SC6->(! EOF()) .And. SC6->C6_FILIAL == xFilial('SC6') .AND. SC6->C6_NUM == SC5->C5_NUM
	nCnt++
	nUsado:=0
	DbSelectArea('SX3')
	DbSeek('SC6')
	_nRecno := Recno()
	While !EOF() .And. X3_ARQUIVO == 'SC6'
		If x3_usado != " " .And. cNivel >= X3_NIVEL .And. Alltrim(X3_CAMPO) $ "C6_ITEM/C6_PRODUTO/C6_DESCRI/C6_PRCVEN/C6_VALOR/C6_COMISSA/C6_PERCOM"
			nUsado++
			aCOLS[nCnt][nUsado] := &("SC6->"+x3_campo)
		EndIf
		DbSkip()
	End
	DbGoTo(_nRecno)
	While !EOF() .And. X3_ARQUIVO == 'SC6'
		If x3_usado != " " .And. cNivel >= X3_NIVEL .And. Alltrim(X3_CAMPO) $ "C6_TES/C6_CF"
			nUsado++
			aCOLS[nCnt][nUsado] := &("SC6->"+x3_campo)
		EndIf
		DbSkip()
	End
	aCOLS[nCnt][nUsado+1] := .F. //Flag de Delecao
	DbSelectArea('SC6')
	DbSkip()
End
DbGoTo(_nRecno)
@ 6,5 TO 210,395 MULTILINE MODIFY VALID .T. FREEZE 1
@ 215,005 BUTTON STR0029   SIZE 40,15 ACTION VerPrecos() //"_Precos"
@ 215,310 BUTTON STR0030 SIZE 40,15 ACTION Atualiza() //"_Confirma"
@ 215,355 BUTTON STR0031 SIZE 40,15 ACTION Close(oDlg3) //"_Sair"
ACTIVATE DIALOG oDlg3 CENTERED
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VerPrecos ºAutor  ³Microsiga           º Data ³  08/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerPrecos()
_cAlias := Alias()
Posicione('SUA',8,xFilial('SUA')+SC5->C5_NUM,'UA_NUM')
If !Empty(SUA->UA_NUM)
	DbSelectArea("SX3")
	DbSeek("SUA")
	While !Eof().And.(x3_arquivo=="SUA")
		If x3_context <> 'V' 
			_cX := 'M->'+x3_campo+' := SUA->'+x3_campo
			_cX := &_cX
		Endif
		DbSkip()
	End
	_nPreco := T_TTMKA01(aCols[n,AsCan(aHeader,{|x|Alltrim(x[2])=='C6_PRODUTO'})])
Else
	MsgStop(STR0032) //'Orcamento nao encontrado!'
Endif
DbSelectArea(_cAlias)
Return(.T.)

Static Function Atualiza()
Local _nX

For _nX := 1 To Len(aCols)
	DbSelectArea( "SC6" )
	DbSetOrder(1)
	If DbSeek(xFilial("SC6")+SC5->C5_NUM+aCols[_nX,1]+aCols[_nX,Ascan(aHeader,{|x|Alltrim(x[2])=="C6_PRODUTO"})])
		RecLock('SC6',.F.)
		SC6->C6_COMISSA := aCols[_nX,Ascan(aHeader,{|x|Alltrim(x[2])=="C6_COMISSA"})]
		SC6->C6_PERCOM  := aCols[_nX,Ascan(aHeader,{|x|Alltrim(x[2])=="C6_PERCOM"})]
		MsUnLock()
	Endif
Next _nX
Close(oDlg3)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CalcCom   ºAutor  ³Microsiga           º Data ³  08/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function CalcCom(_nOp)

CHKTEMPLATE("DCM")  

_cField:=readvar()
_lRet := .T.
_nPosComis  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='C6_COMISSA'})
_nPosValor  := AsCan(aHeader,{|x|Alltrim(Upper(x[2]))=='C6_VALOR'})
If _nOp = 1
	If Upper(Alltrim(_cField))='M->C6_PERCOM'
		aCols[n,_nPosComis] := (aCols[n,_nPosValor] * M->C6_PERCOM/100)
		_lRet := IIf(aCols[n,_nPosComis] > 0,.T.,.F.)
	Endif
EndIf
Return(_lRet)