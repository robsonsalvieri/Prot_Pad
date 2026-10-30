	#INCLUDE "testa01.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTESTA01   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  27/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MarkBrowse com filtro de pedidos para emissao de romaneio  บฑฑ
ฑฑบ          ณ de separacao                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TESTA01a
CHKTEMPLATE("DCM")
T_TESTA01(1)
Return

Template Function TESTA01b
CHKTEMPLATE("DCM")  
T_TESTA01(2)
Return


Template Function TESTA01(_nTipoTE1)

CHKTEMPLATE("DCM")

// MV_PAR01 - Situacao (Liberados/Nao Liberados)
// MV_PAR02 - Local (Expedicao/Recebimento)
// MV_PAR03 - Ordem (Codigo/Localizacao)
// MV_PAR04 - Quantidade de Pedidos/Notas
// MV_PAR05 - Data de Liberacao
// MV_PAR06 - Ultimo Pedido
cPerg := Padr("TEST01",Len(SX1->X1_GRUPO))
If !Pergunte(cPerg)
	Return
Endif

If MV_PAR04 = 0
	MsgStop(STR0003) //'A quantidade de Pedidos/Notas deve ser Informada!'
	Return
Endif

If MV_PAR09 = 1
	If !MsgBox(STR0004,STR0005,'YESNO') //'Confirma a exibicao dos Romaneios ja Impressos ?'###'Atencao'
		Return
	Endif
Endif

Private _cMarca   := GetMark()
Private cQueryCad := ""
Private cArq      := ''
Private _cIndex   := ''
Private aFields   := {}
Private _nTipo    := _nTipoTE1

INCLUI       := .F.
aCampos      := {}
_cPesqPed    := Space(6)
_nTotal      := 0

If _nTipo = 1
	AADD(aCampos,{'T9_OK'     ,'','@!','2','0'})
	AADD(aCampos,{'T9_CONF'   ,STR0006,'@!','2','0'}) //'Conf.'
//	AADD(aCampos,{'T9_ORI'    ,'Orig','@!','3','0'})
	AADD(aCampos,{'T9_SEQ'    ,STR0007,'999','3','0'}) //'Seq'
	AADD(aCampos,{'T9_PEDIDO' ,STR0008,'@!','6','0'}) //'Pedidos'
	AADD(aCampos,{'T9_CLIENTE',STR0009,'@!','6','0'}) //'Cliente'
	AADD(aCampos,{'T9_NOMCLI' ,STR0010,'@!','40','0'}) //'Razao Social'
	AADD(aCampos,{'T9_EMISSAO',STR0011,'@!','8','0'})	 //'Emissao'
	AADD(aCampos,{'T9_VALOR'  ,STR0012,'@ER 999,999.99','10','2'}) //'Total'
	AADD(aCampos,{'T9_QTDITEM',STR0013,'999','3','0'}) //'Itens Lib.'
ElseIf _nTipo = 2
	AADD(aCampos,{'T1_OK'     ,'','@!','2','0'})
	AADD(aCampos,{'T1_SEQ'    ,STR0007,'999','3','0'}) //'Seq'
	AADD(aCampos,{'T1_DOC'    ,STR0014,'@!','6','0'}) //'Notas'
	AADD(aCampos,{'T1_FORNECE',STR0015,'@!','6','0'}) //'Fornecedor'
	AADD(aCampos,{'T1_ENDER'  ,STR0016,'@!','15','0'})	 //'Endereco'
	AADD(aCampos,{'T1_TOTAL'  ,STR0012,'@ER 999,999.99','10','2'}) //'Total'
	AADD(aCampos,{'T1_QTDITEM',STR0013,'999','3','0'}) //'Itens Lib.'
Endif

Cria_TC9(_nTipo)
If _nTipo = 1
	DbSelectArea('TC9')
	@ 100,005 TO 500,750 DIALOG oDlgPedidos TITLE STR0017+If(MV_PAR08=1,STR0018,STR0019)+If(MV_PAR09=1,STR0020,STR0021) //"Pedidos "###"RETIRA"###"ENTREGA"###" - IMPRESSOS"###" - NAO IMPRESSOS"
	@ 006,005 TO 190,325 BROWSE "TC9" MARK "T9_OK" FIELDS aCampos Object _oBrwPed
ElseIf _nTipo = 2
	DbSelectArea('TD1')
	@ 100,005 TO 500,750 DIALOG oDlgPedidos TITLE "Notas"
	@ 006,005 TO 190,325 BROWSE "TD1" MARK "T1_OK" FIELDS aCampos Object _oBrwPed
Endif
@ 006,330 BUTTON STR0022    SIZE 40,15 ACTION RelRomaneio(_nTipo) //"_Imp.Romaneio"
If _nTipo = 1
   @ 026,330 BUTTON STR0023 SIZE 40,15 ACTION RelRomaneio(3) //"_Imp.Caxarias"
   @ 046,330 BUTTON STR0024 SIZE 40,15 ACTION Relpeds() //"_Imp.Pedidos"
   @ 066,330 BUTTON STR0025 SIZE 40,15 ACTION MsAguarde({||MarcarTudo()},STR0026) //"Marcar"###'Marcando Registros...'
   @ 086,330 BUTTON STR0027 SIZE 40,15 ACTION MsAguarde({||DesMarcaTudo()},STR0028) //"Desmarcar"###'Desmarcando Registros...'
   If MV_PAR09 = 1	
      @ 106,330 BUTTON STR0029 SIZE 40,15 ACTION LibImp() //"Lib.Impressao"
   Endif   
Endif
@ 183,330 BUTTON STR0030    SIZE 40,15 ACTION Close(oDlgPedidos) //"_Sair"

Processa({|| Monta_TC9(_nTipo) } ,STR0031) //"Selecionando Informacoes dos Pedidos..."

_oBrwPed:bMark := {|| Marcar(_nTipo)}

ACTIVATE DIALOG oDlgPedidos CENTERED

If cArq <> ''
	DbSelectArea(If(_nTipo=1,"TC9","TD1"))
	DbCloseArea()
	FErase(cArq+OrdBagExt())
	FErase(_cIndex+ordbagext())
	_cIndex := ''
	cArq    := ''
Endif

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcarTudo  บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcarTudo()
DbSelectArea('TC9')
While !Eof()
	MsProcTxt(STR0032) //'Aguarde...'
	RecLock('TC9',.F.)
	TC9->T9_OK := _cMarca
	MsUnlock()
	DbSkip()
End
DbGoTop()
DlgRefresh(oDlgPedidos)
SysRefresh()
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDesmarcaTudoบAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DesmarcaTudo()
DbSelectArea('TC9')
While !Eof()
	MsProcTxt(STR0032) //'Aguarde...'
	RecLock('TC9',.F.)
	TC9->T9_OK := ThisMark()
	MsUnlock()
	DbSkip()
End  
DbGoTop()
DlgRefresh(oDlgPedidos)
SysRefresh()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcar    บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Marcar(_nTipoPar)
If _nTipoPar = 1
	DbSelectArea('TC9')
	RecLock('TC9',.F.)
	If Empty(TC9->T9_OK)
		TC9->T9_OK := _cMarca
	Endif
ElseIf _nTipoPar = 2
	DbSelectArea('TD1')
	RecLock('TD1',.F.)
	If Empty(TD1->T1_OK)
		TD1->T1_OK := _cMarca
	Endif
Endif
MsUnlock()
SysRefresh()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLibImp    บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION LibImp()
If !MsgBox(STR0033+TC9->T9_PEDIDO+' ?',STR0005,'YESNO') //'Confirma a Liberacao das Emissoes deste Pedido: '###'Atencao'
   Return
Endif
DbSelectArea('SC6')
DbSetOrder(1)
If DbSeek(xFilial('SC6')+TC9->T9_PEDIDO)   
   _lFlagSC5 := .F.   
   While SC6->(! Eof()) .And. SC6->C6_FILIAL == xFilial('SC6') .And. SC6->C6_NUM == TC9->T9_PEDIDO
      If SC6->C6_QTDENT > 0
         _lFlagSC5 := .T. //se ha Itens com Qtde. Entregue
      Endif
      If !Empty(SC6->C6_IMPRE)
         RecLock('SC6',.F.)
         SC6->C6_IMPRE := ''
         MsUnLock()
      Endif
      DbSkip()
   End   
   If !_lFlagSC5    //se nao ha Itens com Qtde. Entregue
      dBSelectArea("SC5")
      dBSetOrder(1)
      If DbSeek(xFilial('SC5')+TC9->T9_PEDIDO)   
         RecLock('SC5',.F.)
         SC5->C5_NOTA := ''
         MsUnLock()
      Endif
   Endif
Endif
DbSelectArea('TC9')
RecLock('TC9',.F.)
DbDelete()
MsUnLock()

DbSkip()

DlgRefresh(oDlgPedidos)
SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TC9  บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cria_TC9(_nTipoPar)
aFields   := {}
If _nTipoPar = 1
	AADD(aFields,{"T9_OK"     ,"C",02,0})
	AADD(aFields,{"T9_CONF"   ,"C",02,0})
//	AADD(aFields,{"T9_ORI"    ,"C",03,0})
	AADD(aFields,{"T9_SEQ"    ,"N",05,0})
	AADD(aFields,{"T9_PEDIDO" ,"C",06,0})
	AADD(aFields,{"T9_CLIENTE","C",06,0})
	AADD(aFields,{"T9_NOMCLI" ,"C",40,0})
	AADD(aFields,{"T9_EMISSAO","D",8,0})	
	AADD(aFields,{"T9_VALOR"  ,"N",10,2})
	AADD(aFields,{"T9_QTDITEM","N",03,0})
	cArq:=Criatrab(aFields,.T.)
	DBUSEAREA(.t.,,cArq,"TC9")
ElseIf _nTipoPar = 2
	AADD(aFields,{"T1_OK"     ,"C",02,0})
	AADD(aFields,{"T1_SEQ"    ,"N",05,0})
	AADD(aFields,{"T1_DOC"    ,"C",06,0})
	AADD(aFields,{"T1_FORNECE","C",06,0})
	AADD(aFields,{"T1_ENDER"  ,"C",15,0})	
	AADD(aFields,{"T1_TOTAL"  ,"N",10,2})
	AADD(aFields,{"T1_QTDITEM","N",03,0})
	cArq:=Criatrab(aFields,.T.)
	DBUSEAREA(.t.,,cArq,"TD1")
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TC9 บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_TC9(_nTipoPar) 
Local _cMVCodReti                
Local _nCodReti  
Local _nx

If _nTipoPar = 1
	For _nX := 1 To 2
		If _nX = 1
			cQueryCad := "SELECT COUNT(DISTINCT C9_PEDIDO) AS TOTAL FROM "+RetSqlName('SC9')+" C9  WHERE "
		Else
			cQueryCad := "SELECT DISTINCT  C9_PEDIDO AS T9_PEDIDO, C9_CLIENTE AS T9_CLIENTE, A1_NOME AS T9_NOMCLI, "
			//cQueryCad := "SELECT DISTINCT TOP "+Str(MV_PAR04,5,0)+" C9_PEDIDO AS T9_PEDIDO, C9_CLIENTE AS T9_CLIENTE, A1_NOME AS T9_NOMCLI, "
			cQueryCad += "C9_BLCONF AS T9_CONF, C5_EMISSAO AS T9_EMISSAO, SUM(C9_PRCVEN*C9_QTDLIB) AS T9_VALOR, "
			cQueryCad += "(SELECT COUNT(DISTINCT C92.C9_PRODUTO) FROM "+RetSqlName('SC9')+" C92  WHERE "
			cQueryCad += "C92.D_E_L_E_T_ <> '*' AND "
			cQueryCad += "C92.C9_FILIAL = '"+xFilial("SC9")+"' AND "
			cQueryCad += "C92.C9_PEDIDO = C9.C9_PEDIDO AND "
			If MV_PAR01 = 1
				cQueryCad += "C92.C9_BLEST = ' ' AND "
				If GetMv("MV_IMPPENR") = "S"
					cQueryCad += "C92.C9_NFENT = ' ' AND "
				Endif
			Else
				cQueryCad += "C92.C9_BLEST = '02' AND "
			Endif
			If !Empty(MV_PAR05)
				cQueryCad += "C92.C9_DATALIB = '"+DTOS(MV_PAR05)+"' AND "
			Endif
			cQueryCad += "C92.C9_BLCONF = ' ' AND "
			cQueryCad += "C92.C9_BLCRED = ' ' AND "
			cQueryCad += "C92.C9_BLPRE <> ' ' AND "
			cQueryCad += "C92.C9_NFISCAL = ' ') AS T9_QTDITEM "
			cQueryCad += "FROM "+RetSqlName('SC9')+" C9  , "+RetSqlName('SC5')+" C5 , "+RetSqlName("SA1")+" A1  WHERE "
			cQueryCad += "C5.D_E_L_E_T_ <> '*' AND "
			cQueryCad += "A1.D_E_L_E_T_ <> '*' AND "
			cQueryCad += "C5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
			cQueryCad += "C5.C5_NUM = C9.C9_PEDIDO AND "
			cQueryCad += "A1.A1_COD = C9.C9_CLIENTE AND "
			cQueryCad += "A1.A1_LOJA = C9.C9_LOJA AND "
			If Empty(MV_PAR07)
				If !Empty(GetMv('MV_CODRETI'))
					_cCodReti := "'"
					_cMVCodReti := Alltrim(GetMv('MV_CODRETI'))
					For _nCodReti := 1 To Len(_cMVCodReti)
						If SubStr(_cMVCodReti,_nCodReti,1) <> '/'
							_cCodReti += SubStr(_cMVCodReti,_nCodReti,1)
						Else
							_cCodReti += "'"+If(_nCodReti<>Len(_cMVCodReti),",'","")
						Endif
					Next _nCodReti
					_cCodReti += "'"
					cQueryCad += "C5.C5_TRANSP "+If(MV_PAR08=1,"","NOT")+" IN ("+_cCodReti+") AND "
    			Else
					cQueryCad += If(MV_PAR08=1,"","NOT")+" EXISTS (SELECT 'E' FROM "+RetSqlName('SA4')+" A4  "
					cQueryCad += " WHERE A4_NOME LIKE '%RETIRA%' AND "
					cQueryCad += " A4.A4_FILIAL = '"+xFilial("SA4")+"' AND "
					cQueryCad += "	A4.D_E_L_E_T_ <> '*' AND C5.C5_TRANSP = A4.A4_COD) AND "
				Endif
				
			Endif
		Endif
		cQueryCad += "C9.D_E_L_E_T_ <> '*' AND "
		cQueryCad += "C9.C9_FILIAL = '"+xFilial("SC9")+"' AND "
		If MV_PAR01 = 1
			cQueryCad += "C9.C9_BLEST = ' ' AND "
			If GetMv("MV_IMPPENR") = "S"
				cQueryCad += "C9.C9_NFENT = ' ' AND "
			Endif
		Else
			cQueryCad += "C9.C9_BLEST = '02' AND "
		Endif
		cQueryCad += "C9.C9_BLCONF = ' ' AND "
		cQueryCad += "C9.C9_BLCRED = ' ' AND "
		cQueryCad += "C9.C9_BLPRE <> ' ' AND "
		cQueryCad += "C9.C9_NFISCAL = ' ' AND "
		cQueryCad += "C9.C9_BLCRED <> '10' "
		If !Empty(MV_PAR05)
			cQueryCad += " AND C9.C9_DATALIB = '"+DTOS(MV_PAR05)+"' "
		Endif
		If !Empty(MV_PAR06)
			cQueryCad += " AND C9.C9_PEDIDO > '"+MV_PAR06+"' "
		Endif
		If !Empty(MV_PAR07)
			cQueryCad += " AND C9.C9_CLIENTE = '"+MV_PAR07+"' "
		Endif
		cQueryCad += "GROUP BY C9.C9_PEDIDO, C9.C9_CLIENTE "+If(_nX = 2,", A1.A1_NOME, C9.C9_BLCONF, C5.C5_EMISSAO ","")
		cQueryCad += "ORDER BY C9.C9_PEDIDO "
		
		TCQUERY cQueryCad NEW ALIAS "CAD"
		If _nX = 1
			_nCount := CAD->TOTAL
			DbCloseArea()
		Else
			TcSetField('CAD','T9_EMISSAO','D')
		Endif
	Next
ElseIf _nTipoPar = 2
	For _nX := 1 To 2
		If _nX = 1
			cQueryCad := "SELECT COUNT(DISTINCT D1_DOC) AS TOTAL FROM "+RetSqlName('SD1')+" D1  WHERE "
		Else
			cQueryCad := "SELECT DISTINCT  D1_DOC AS T1_DOC, D1_FORNECE AS T1_FORNECE, D1_ENDER AS T1_ENDER, SUM(D1_TOTAL) AS T1_TOTAL, " //cQueryCad := "SELECT DISTINCT TOP "+Str(MV_PAR04,5,0)+" D1_DOC AS T1_DOC, D1_FORNECE AS T1_FORNECE, D1_ENDER AS T1_ENDER, SUM(D1_TOTAL) AS T1_TOTAL, "
			cQueryCad += "(SELECT COUNT(*) FROM "+RetSqlName('SD1')+" D12  WHERE "
			cQueryCad += "D12.D_E_L_E_T_ <> '*' AND "
			cQueryCad += "D12.D1_FILIAL = '"+xFilial("SD1")+"' AND "
			If !Empty(MV_PAR05)
				cQueryCad += "D12.D1_DTDIGIT = '"+DTOS(MV_PAR05)+"' AND "
			Endif
			cQueryCad += "D12.D1_DOC = D1.D1_DOC) AS T1_QTDITEM "
			cQueryCad += "FROM "+RetSqlName('SD1')+" D1  , "+RetSqlName('SF1')+" F1  WHERE "
			cQueryCad += "F1.D_E_L_E_T_ <> '*' AND "
			cQueryCad += "F1.F1_FILIAL = '"+xFilial("SF1")+"' AND "
			cQueryCad += "F1.F1_DOC = D1.D1_DOC AND "
			cQueryCad += "F1.F1_SERIE = D1.D1_SERIE AND "
			cQueryCad += "F1.F1_FORNECE = D1.D1_FORNECE AND "
			cQueryCad += "F1.F1_LOJA = D1.D1_LOJA AND "
		Endif
		cQueryCad += "D1.D_E_L_E_T_ <> '*' AND "
		If !Empty(MV_PAR05)
			cQueryCad += " D1.D1_DTDIGIT = '"+DTOS(MV_PAR05)+"' AND "
		Endif
		cQueryCad += "D1.D1_FILIAL = '"+xFilial("SD1")+"' "
		cQueryCad += "GROUP BY D1.D1_DOC, D1.D1_FORNECE, D1.D1_ENDER "
		cQueryCad += "ORDER BY D1.D1_DOC "
		
		TCQUERY cQueryCad NEW ALIAS "CAD"
			
		If _nX = 1
			_nCount := CAD->TOTAL
			DbCloseArea()
		EndIf
	Next
EndIf

Dbselectarea(If(_nTipoPar = 1,"TC9","TD1"))
DbGoTop()
While !Eof()
	If _nTipoPar = 1
		If TC9->T9_QTDITEM = 0
			RecLock('TC9',.F.)
			TC9->T9_QTDITEM := 0
			MsUnlock()
		Endif
	ElseIf _nTipoPar = 2
		If TD1->T1_QTDITEM = 0
			RecLock('TD1',.F.)
			TD1->T1_QTDITEM := 0
			MsUnlock()
		Endif
	Endif
	DbSkip()
	
EndDo
DbGoTop()

DbSelectArea("CAD")

ProcRegua(_nCount)

_nSeq   := 0
_nTotal := 0
While CAD->(!EOF())
	IncProc()
	If _nTipoPar = 1
		DbSelectArea('SC6')
		DbSetOrder(1)
		If DbSeek(xFilial('SC6')+CAD->T9_PEDIDO)
			_lImp := .F.
			Do While SC6->(! Eof()) .And. SC6->C6_FILIAL == xFilial('SC6') .And. SC6->C6_NUM == CAD->T9_PEDIDO
				If !Empty(SC6->C6_IMPRE)
					_lImp := .T.
					Exit
				Endif
				DbSkip()
			End  
			If _lImp .And. MV_PAR09 <> 1
				DbSelectArea('CAD')
				DbSkip()
				Loop
			Endif
		Endif
		DbSelectArea('SC5')
		DbSetOrder(1)
		If DbSeek(xFilial("SC5")+CAD->T9_PEDIDO)
			If SC5->C5_FATINT = 'S'
				DbSelectArea('SC6')
				DbSetOrder(1)
				DbSeek(xFilial('SC6')+CAD->T9_PEDIDO)
				_nContaIt := 0
				_aQtdPed  := {}
				_aItePed  := {}
				While SC6->(! Eof()) .And. SC6->C6_FILIAL == xFilial('SC6') .And. SC6->C6_NUM == CAD->T9_PEDIDO
				    If AsCan(_aItePed,SC6->C6_PRODUTO) = 0
					   ++_nContaIt
					   AaDd(_aItePed,SC6->C6_PRODUTO)
   					   AaDd(_aQtdPed,{SC6->C6_PRODUTO,SC6->C6_QTDVEN})
   					Else   
   					   _aQtdPed[AsCan(_aItePed,SC6->C6_PRODUTO),2] += SC6->C6_QTDVEN 
					Endif   
 				    DbSkip()
				EndDo
				If CAD->T9_QTDITEM<>_nContaIt
					DbSelectArea('CAD')
					DbSkip()
					Loop
				Else
					_lForLib := .T.
					For _nX := 1 To Len(_aQtdPed)
						DbSelectArea('SC9')
						DbSetOrder(8)
						If DbSeek(xFilial('SC9')+_aQtdPed[_nX,1]+CAD->T9_CLIENTE+'01'+CAD->T9_PEDIDO)
							_nContaIt2 := 0
							While SC9->(! Eof()) .And. SC9->C9_FILIAL == xFilial('SC9') .And. SC9->C9_PRODUTO == _aQtdPed[_nX,1] .And. SC9->C9_PEDIDO == CAD->T9_PEDIDO
							    If Empty(SC9->C9_BLEST)
								   _nContaIt2 += SC9->C9_QTDLIB
								Endif   
								DbSkip()
							EndDo
							If _nContaIt2 <> _aQtdPed[_nX,2]
								_lForLib := .F.
								Exit
							Endif
						Endif
					Next
					If !_lForLib
						DbSelectArea('CAD')
						DbSkip()
						Loop
					Endif
				Endif
			Endif
		Endif
		DbSelectArea('TC9')
		_lIncl := .T.
		If !Empty(_cIndex)
			If !DbSeek(CAD->T9_PEDIDO)
				RecLock("TC9",.T.)
			Else
				_lIncl := .F.
				RecLock("TC9",.F.)
			Endif
		Else
			RecLock("TC9",.T.)
		Endif
		For _nX := 1 To Len(aFields)
			If !(aFields[_nX,1] $ 'T9_OK/T9_SEQ')
				If aFields[_nX,2] = 'C'
					_cX := 'TC9->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
				Else
					_cX := 'TC9->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
				Endif
				_cX := &_cX
			Endif
		Next
		++_nSeq
		If _lIncl
			TC9->T9_SEQ := _nSeq
			TC9->T9_OK  := _cMarca //If(!_lImp.And.TC9->T9_ORI<>'FAT',_cMarca,ThisMark())
		Endif
		If TRIM(TC9->T9_OK) == _cMarca
			_nTotal += TC9->T9_VALOR
		Endif
	ElseIf _nTipoPar = 2
		DbSelectArea('TD1')
		_lIncl := .T.
		If !Empty(_cIndex)
			If !DbSeek(CAD->D1_DOC)
				RecLock("TD1",.T.)
			Else
				_lIncl := .F.
				RecLock("TD1",.F.)
			Endif
		Else
			RecLock("TD1",.T.)
		Endif
		For _nX := 1 To Len(aFields)
			If !(aFields[_nX,1] $ 'T1_OK/T1_SEQ')
				If aFields[_nX,2] = 'C'
					_cX := 'TD1->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
				Else
					_cX := 'TD1->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
				Endif
				_cX := &_cX
			Endif
		Next
		++_nSeq
		If _lIncl
			TD1->T1_SEQ := _nSeq
			TD1->T1_OK  := _cMarca
		Endif
		If TRIM(TD1->T1_OK) == _cMarca
			_nTotal += TD1->T1_TOTAL
		Endif
	Endif
	MsUnLock()
	DbSelectArea('CAD')
	CAD->(dBSkip())
End  
DbSelectArea("CAD")
DbCloseArea()
DbSelectArea(If(_nTipoPar=1,"TC9","TD1"))
DbGoTop()
If !Empty(_cIndex)
	While !Eof()
		If _nTipoPar = 1
			If TC9->T9_QTDITEM = 0
				RecLock('TC9',.F.)
				DbDelete()
				MsUnlock()
			Endif
		ElseIf _nTipoPar = 2
			If TD1->T1_QTDITEM = 0
				RecLock('TD1',.F.)
				DbDelete()
				MsUnlock()
			Endif
		Endif
		DbSkip()
	End  
	DbGoTop()
Endif

//esquema pra substituir o comando TOP na query (pq funcionava apenas no SQL SERVER)
//mantem apenas os X registros filtrados no pergunte.
While !Eof()
	If Recno() > MV_PAR04
		RecLock(If(_nTipoPar=1,"TC9","TD1") , .F.)
		DBDelete()
		MsUnlock()
	EndIf
	
	DbSkip()
End  
DbGoTop()

If Empty(_cIndex)
	_cIndex := Criatrab(Nil,.F.)
Else
	FErase(_cIndex+ordbagext())
	_cIndex := Criatrab(Nil,.F.)
Endif
If _nTipoPar == 1
	_cChave := "T9_PEDIDO"
	Indregua("TC9",_cIndex,_cChave,,,STR0034) //"Ordenando registros selecionados..."
ElseIf _nTipoPar == 2
	_cChave := "T1_DOC"
	Indregua("TD1",_cIndex,_cChave,,,STR0034) //"Ordenando registros selecionados..."
Endif
DbSetIndex(_cIndex+OrdBagExt())
SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRelRomaneioบAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                          บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RelRomaneio(_nTipoPar)
Local aOldArea	:= GetArea()
Local _nTPCaixa
Local _cCADIdx	:= ""
Local _cCADKey	:= ""
Local aFldCAD    := {}
Local cArqCAD		:= ""

AADD(aFldCAD, {"C6_LOCALIZ", TamSX3("C6_LOCALIZ")[03],TamSX3("C6_LOCALIZ")[01],TamSX3("C6_LOCALIZ")[02]})
AADD(aFldCAD, {"C9_PRODUTO", TamSX3("C9_PRODUTO")[03],TamSX3("C9_PRODUTO")[01],TamSX3("C9_PRODUTO")[02]})
AADD(aFldCAD, {"C6_DESCRI",  TamSX3("C6_DESCRI")[03], TamSX3("C6_DESCRI")[01], TamSX3("C6_DESCRI")[02]})
AADD(aFldCAD, {"B1_FABRIC",  TamSX3("B1_FABRIC")[03], TamSX3("B1_FABRIC")[01], TamSX3("B1_FABRIC")[02]})
AADD(aFldCAD, {"C6_UM",      TamSX3("C6_UM")[03],     TamSX3("C6_UM")[01],     TamSX3("C6_UM")[02]})
AADD(aFldCAD, {"C9_PEDIDO",  TamSX3("C9_PEDIDO")[03], TamSX3("C9_PEDIDO")[01], TamSX3("C9_PEDIDO")[02]})
AADD(aFldCAD, {"C9_QTDLIB",  TamSX3("C9_QTDLIB")[03], TamSX3("C9_QTDLIB")[01], TamSX3("C9_QTDLIB")[02]})	
AADD(aFldCAD, {"C6_SEGUM",   TamSX3("C6_SEGUM")[03],  TamSX3("C6_SEGUM")[01],  TamSX3("C6_SEGUM")[02]})
AADD(aFldCAD, {"C6_UNSVEN",  TamSX3("C6_UNSVEN")[03], TamSX3("C6_UNSVEN")[01], TamSX3("C6_UNSVEN")[02]})
AADD(aFldCAD, {"D1_ENDER",   TamSX3("D1_ENDER")[03],  TamSX3("D1_ENDER")[01],  TamSX3("D1_ENDER")[02]})
AADD(aFldCAD, {"D1_COD",     TamSX3("D1_COD")[03],    TamSX3("D1_COD")[01],    TamSX3("D1_COD")[02]})
AADD(aFldCAD, {"D1_UM",      TamSX3("D1_UM")[03],     TamSX3("D1_UM")[01],     TamSX3("D1_UM")[02]})
AADD(aFldCAD, {"D1_QUANT",   TamSX3("D1_QUANT")[03],  TamSX3("D1_QUANT")[01],  TamSX3("D1_QUANT")[02]})
AADD(aFldCAD, {"D1_SEGUM",   TamSX3("D1_SEGUM")[03],  TamSX3("D1_SEGUM")[01],  TamSX3("D1_SEGUM")[02]})
AADD(aFldCAD, {"D1_QTSEGUM", TamSX3("D1_QTSEGUM")[03],TamSX3("D1_QTSEGUM")[01],TamSX3("D1_QTSEGUM")[02]})

cPerg := Padr("TEST01",Len(SX1->X1_GRUPO))
Pergunte(cPerg,.F.)

If _nTipoPar == 1 .Or. _nTipoPar == 3
	DbSelectArea('TC9')
	DbGoTop()
	_cPedSel := '('
	_lMarca  := .F.
	While !Eof()
		If TRIM(T9_OK) == _cMarca
			_cPedSel += "'"+T9_PEDIDO+"',"
		Endif
		DbSkip()
	EndDo
	_cPedSel := SubStr(_cPedSel,1,Len(_cPedSel)-1)+')'
	If _cPedSel = ')'
		MsgStop(STR0035) //'Voce deve selecionar algum pedido ...'
		Return
	Endif
	If _nTipoPar == 3
		cQueryCad := "SELECT DISTINCT C6_LOCALIZ, C9_PRODUTO, C6_DESCRI, B1_FABRIC, C6_UM, SUM(C9_QTDLIB) AS C9_QTDLIB, C6_SEGUM, SUM(C6_UNSVEN) AS C6_UNSVEN "
	Else
		cQueryCad := "SELECT DISTINCT C6_LOCALIZ, C9_PRODUTO, C6_DESCRI, B1_FABRIC, C9_PEDIDO, C6_UM, SUM(C9_QTDLIB) AS C9_QTDLIB, C6_SEGUM, SUM(C6_UNSVEN) AS C6_UNSVEN "
	Endif
	cQueryCad += "FROM "+RetSqlName('SC9')+" C9  , "+RetSqlName('SC6')+" C6  , "+RetSqlName('SB1')+" B1  WHERE "
	cQueryCad += "C9.D_E_L_E_T_ <> '*' AND "
	cQueryCad += "C6.D_E_L_E_T_ <> '*' AND "
	cQueryCad += "B1.D_E_L_E_T_ <> '*' AND "
	cQueryCad += "C9_FILIAL = '"+xFilial("SC9")+"' AND "
	cQueryCad += "C6_FILIAL = '"+xFilial("SC6")+"' AND "
	cQueryCad += "B1_FILIAL = '"+xFilial("SB1")+"' AND "
	If !Empty(GetMv("MV_TPCAIXA"))
		_cTPCaixa := "'"
		_cMVTPCaixa := Alltrim(GetMv('MV_TPCAIXA'))
		For _nTPCaixa := 1 To Len(_cMVTPCaixa)
			If SubStr(_cMVTPCaixa,_nTPCaixa,1) <> '/'
				_cTPCaixa += SubStr(_cMVTPCaixa,_nTPCaixa,1)
			Else             
				_cTPCaixa += "'"+If(_nTPCaixa<>Len(_cMVTPCaixa),",'","")
			Endif
		Next _nTPCaixa
		_cTPCaixa += "'"
		cQueryCad += "B1_TIPCAR "+If(_nTipoPar = 1,"NOT","")+" IN ("+_cTPCaixa+") AND "
	Endif
	If MV_PAR01 = 1
		cQueryCad += "C9_BLEST = ' ' AND "
	Else
		cQueryCad += "C9_BLEST = '02' AND "
	Endif
	cQueryCad += "C9_BLCONF = ' ' AND "
	cQueryCad += "C9_BLCRED = ' ' AND "
	cQueryCad += "C9_NFISCAL = ' ' AND "
	cQueryCad += "C9_PEDIDO = C6_NUM AND "
	cQueryCad += "C9_PRODUTO = C6_PRODUTO AND "
	cQueryCad += "C9_ITEM = C6_ITEM AND "
	cQueryCad += "C9_PRODUTO = B1_COD AND "
	cQueryCad += "C9_PEDIDO IN "+_cPedSel+" "
	If !Empty(MV_PAR05)
		cQueryCad += " AND C9_DATALIB = '"+DTOS(MV_PAR05)+"' "
	Endif
	If _nTipoPar = 3
		cQueryCad += "GROUP BY C6_LOCALIZ, C9_PRODUTO, C6_UM, C6_SEGUM, C6_DESCRI, B1_FABRIC "
	Else
		cQueryCad += "GROUP BY C6_LOCALIZ, C9_PRODUTO, C6_UM, C6_SEGUM, C6_DESCRI, B1_FABRIC, C9_PEDIDO "
	Endif
	If MV_PAR03 = 1
		cQueryCad	+= "ORDER BY C9_PRODUTO "
		_cCADKey	:= "C9_PRODUTO"
	ElseIf MV_PAR03 = 2
		cQueryCad	+= "ORDER BY C6_LOCALIZ "
		_cCADKey	:= "C6_LOCALIZ"
	Else
		cQueryCad	+= "ORDER BY C9_PRODUTO "
		_cCADKey	:= "C9_PRODUTO"
	Endif

	TCQUERY cQueryCad NEW ALIAS "QRY"

	If !( Empty(GetMv("MV_TPCAIXA")) )
		_cPedSel := ''
		If _nTipoPar == 1
			_cPedSel := '('
			DbSelectArea('QRY')
			While !Eof()
				If !(QRY->C9_PEDIDO $ _cPedSel)
					_cPedSel += "'"+QRY->C9_PEDIDO+"',"
				Endif
				DbSkip()
			EndDo
			_cPedSel := SubStr(_cPedSel,1,Len(_cPedSel)-1)+')'
		EndIf
		DbGoTop()
	Endif

ElseIf _nTipoPar = 2
	DbSelectArea('TD1')
	DbGoTop()
	_cPedSel := '('
	_lMarca  := .F.
	While !Eof()
		If TRIM(TD1->T1_OK) == _cMarca
			_cPedSel += "'"+TD1->T1_DOC+"',"
		Endif
		DbSkip()
	End  
	_cPedSel := SubStr(_cPedSel,1,Len(_cPedSel)-1)+')'
	If _cPedSel = ')'
		MsgStop(STR0036) //'Voce deve selecionar alguma nota ...'
		Return
	Endif
	cQueryCad := "SELECT DISTINCT D1_ENDER, D1_COD, B1_FABRIC, D1_UM, SUM(D1_QUANT) AS D1_QUANT, D1_SEGUM, SUM(D1_QTSEGUM) AS D1_QTSEGUM "
	cQueryCad += "FROM "+RetSqlName('SD1')+" D1  , "+RetSqlName('SB1')+" B1  WHERE "
	cQueryCad += "D1.D_E_L_E_T_ <> '*' AND "
	cQueryCad += "B1.D_E_L_E_T_ <> '*' AND "
	cQueryCad += "D1_FILIAL = '"+xFilial("SD1")+"' AND "
	cQueryCad += "B1_FILIAL = '"+xFilial("SB1")+"' AND "
	cQueryCad += "D1_COD = B1_COD AND "
	cQueryCad += "D1_DOC IN "+_cPedSel
	If !Empty(MV_PAR05)
		cQueryCad += " AND D1_DTDIGIT = '"+DTOS(MV_PAR05)+"' "
	Endif
	cQueryCad += "GROUP BY D1_ENDER, D1_COD, D1_UM, D1_SEGUM, B1_FABRIC "
	If MV_PAR03 = 1
		cQueryCad	+= "ORDER BY D1_COD "
		_cCADKey	:= "D1_COD"
	ElseIf MV_PAR03 = 2
		cQueryCad	+= "ORDER BY D1_ENDER "
		_cCADKey	:= "D1_ENDER"
	Else
		cQueryCad	+= "ORDER BY D1_COD "	
		_cCADKey	:= "D1_COD"
	Endif
	TCQUERY cQueryCad NEW ALIAS "QRY"
Endif

_cCADIdx	:= Criatrab(Nil,.F.)
cArqCAD	:= Criatrab(aFldCAD,.T.)
DBUSEAREA(.t.,,cArqCAD,"CAD")
While	QRY->(! Eof())
	CAD->(RecLock("CAD",.T.))
	If _nTipoPar == 1
		CAD->C6_LOCALIZ	:= QRY->C6_LOCALIZ
		CAD->C9_PRODUTO	:= QRY->C9_PRODUTO
		CAD->C6_DESCRI	:= QRY->C6_DESCRI
		CAD->B1_FABRIC	:= QRY->B1_FABRIC
		CAD->C9_PEDIDO	:= QRY->C9_PEDIDO
		CAD->C6_UM			:= QRY->C6_UM
		CAD->C9_QTDLIB	:= QRY->C9_QTDLIB
		CAD->C6_SEGUM		:= QRY->C6_SEGUM
		CAD->C6_UNSVEN	:= QRY->C6_UNSVEN
	ElseIf _nTipoPar == 2
		CAD->D1_ENDER		:= QRY->D1_ENDER
		CAD->D1_COD		:= QRY->D1_COD
		CAD->B1_FABRIC	:= QRY->B1_FABRIC
		CAD->D1_UM			:= QRY->D1_UM
		CAD->D1_QUANT		:= QRY->D1_QUANT
		CAD->D1_SEGUM		:= QRY->D1_SEGUM
		CAD->D1_QTSEGUM 	:= QRY->D1_QTSEGUM
	ElseIf _nTipoPar == 3
		CAD->C6_LOCALIZ	:= QRY->C6_LOCALIZ
		CAD->C9_PRODUTO	:= QRY->C9_PRODUTO
		CAD->C6_DESCRI	:= QRY->C6_DESCRI
		CAD->B1_FABRIC	:= QRY->B1_FABRIC
		CAD->C6_UM			:= QRY->C6_UM
		CAD->C9_QTDLIB	:= QRY->C9_QTDLIB
		CAD->C6_SEGUM		:= QRY->C6_SEGUM
		CAD->C6_UNSVEN	:= QRY->C6_UNSVEN
	Endif
	CAD->(MsUnLock())
	QRY->(dBSkip())
EndDo

QRY->(dBCloseArea())

DbSelectArea("CAD")
Indregua("CAD",_cCADIdx,_cCADKey,,,STR0034) //"Ordenando registros selecionados..."
DbSetIndex(_cCADIdx+OrdBagExt())

T_TESTR01(_cPedSel,MV_PAR01,_nTipoPar)
DbSelectArea("CAD")
DbCloseArea()
FErase(_cCADIdx+OrdBagExt())
DbSelectArea(If(_nTipoPar == 1 .Or. _nTipoPar == 3,"TC9","TD1"))
DbGoTop()
SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRelpeds   บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Relpeds()
cPerg := Padr("TEST01",Len(SX1->X1_GRUPO))
Pergunte(cPerg,.F.)
_nTipoRel := If(MV_PAR01=1,1,2)

DbSelectArea('SX1')
DbSetOrder(1)
DbSeek('TFATR1')
While !Eof() .And. SX1->X1_GRUPO = 'TFATR1'
	RecLock('SX1',.F.)
	If SX1->X1_ORDEM = '01'
		SX1->X1_CNT01:= ''
	ElseIf SX1->X1_ORDEM = '02'
		SX1->X1_CNT01:= Replicate('Z',6)
	ElseIf SX1->X1_ORDEM = '03'
		SX1->X1_CNT01:= ''
	ElseIf SX1->X1_ORDEM = '04'
		SX1->X1_CNT01:= Replicate('Z',15)
	ElseIf SX1->X1_ORDEM = '06'
		SX1->X1_PRESEL := _nTipoRel
	ElseIf SX1->X1_ORDEM = '10'
		SX1->X1_CNT01:= '01/01/01'
	ElseIf SX1->X1_ORDEM = '11'
		SX1->X1_CNT01:= '31/12/10'
	ElseIf SX1->X1_ORDEM = '12'
		SX1->X1_CNT01:= ''
	ElseIf SX1->X1_ORDEM = '13'
		SX1->X1_CNT01:= ''
	ElseIf SX1->X1_ORDEM = '14'
		SX1->X1_CNT01:= ''
	ElseIf SX1->X1_ORDEM = '15'
		SX1->X1_CNT01:= ''
	ElseIf SX1->X1_ORDEM = '16'
		SX1->X1_CNT01:= ''
	ElseIf SX1->X1_ORDEM = '17'
		SX1->X1_CNT01:= ''
	ElseIf SX1->X1_ORDEM = '18'
		SX1->X1_CNT01:= ''
	Endif
	MsUnLock()
	DbSkip()
EndDo

DbSelectArea('TC9')
DbGoTop()
_aPeds := {}
While !Eof()
	If TRIM(T9_OK) == _cMarca
		AaDd(_aPeds,TC9->T9_PEDIDO)
	Endif
	DbSkip()
End  
DbSelectArea('TC9')
DbGoTop()
If Len(_aPeds) > 0
	aSort(_aPeds)
	DbSelectArea('SX1')
	DbSetOrder(1)
	DbSeek(PADR('TFATR1',Len(SX1->X1_GRUPO))+'01')
	RecLock('SX1',.F.)
	SX1->X1_CNT01:= _aPeds[1]
	MsUnLock()
	DbSeek(PADR('TFATR1',Len(SX1->X1_GRUPO)) +'02')
	RecLock('SX1',.F.)
	SX1->X1_CNT01:= _aPeds[Len(_aPeds)]
	MsUnLock()
	T_TFATR01(4,_aPeds,'','','','')
	DbSelectArea('TC9')
Endif
Return
