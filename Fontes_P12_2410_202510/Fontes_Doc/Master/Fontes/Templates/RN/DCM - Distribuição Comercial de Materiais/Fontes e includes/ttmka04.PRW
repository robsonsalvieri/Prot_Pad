#INCLUDE "ttmka04.ch"
#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA04   บAutor  ณEwerton C Tomaz     บ Data ณ  27/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLiberacao ou estorno de pedidos sob bloqueio especifico     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Projeto Ewerton                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Template Function TTMKA04()
Local _nX
Private cCadastro := STR0001 //"Pedidos"
Private cQueryCad := ""
Private aFields   := {}
Private _cMarca   := GetMark()
Private _cCampos  := "C9_PEDIDO, C9_CLIENTE, C9_LOJA, A1_NOME, A1_SATIV1, C9_PRODUTO, C9_ITEM, C9_QTDLIB, C9_PRCVEN, C9_BLEST, C9_BLCRED, C9_BLPRE, C9_BLINF, "+;
					    "A1_EST, A1_MUN, A1_ESTE, A1_MUNE "
Private _cLibera  := STR0002 //"Libera"
Private _cEstorna := STR0003 //"Estorna"
Private _aArqSel  := {"SC9","SA1"}
Private _nCustoUni:= 0
Private _aCustoUni:= {}

If !Pergunte(Padr('TTMK04',Len(SX1->X1_GRUPO)))
	Return
EndIf

@ 100,005 TO 500,780 DIALOG oDlgPedL TITLE STR0001 //"Pedidos"
aCampos := {}
DbSelectArea('SX3')
DbSetOrder(1)
AADD(aCampos,{'000','C9_OK','','@!','2','0'})
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
		If !(ALLTRIM(X3_CAMPO) $ _cCampos)
			DbSkip()
			Loop
		EndIf
		AADD(aCampos,{StrZero(AT(ALLTRIM(X3_CAMPO),_cCampos),3,0),Alltrim(X3_CAMPO),IIf(X3_CAMPO='C9_BLCONF','',Alltrim(X3_TITULO)),X3_PICTURE,X3_TAMANHO,X3_DECIMAL})
		DbSkip()
	End  
Next
ASort(aCampos,,,{|x,y|x[1]<y[1]})

aCampos2 := {}
For _nX := 1 To Len(aCampos)
	AADD(aCampos2,{aCampos[_nX,2],aCampos[_nX,3],aCampos[_nX,4],aCampos[_nX,5],aCampos[_nX,6]})
Next
aCampos := {}
aCampos := aCampos2
Cria_TC9()
DbSelectArea('TC9')
@ 006,005 TO 190,345 BROWSE "TC9" MARK "C9_OK" FIELDS aCampos Object _oBrwPed
@ 006,347 BUTTON STR0004         SIZE 40,15 ACTION TTMK4a(_cLibera) //"_Liberar"
@ 026,347 BUTTON STR0005         SIZE 40,15 ACTION TTMK4a(_cEstorna) //"_Estornar"
@ 046,347 BUTTON STR0006         SIZE 40,15 ACTION TTMK42() //"_Ver/Marcar"
@ 066,347 BUTTON STR0007         SIZE 40,15 ACTION TTMK43() //"_Bloqueios"
@ 183,347 BUTTON STR0008         SIZE 40,15 ACTION Close(oDlgPedL) //"_Sair"

Processa({|| Monta_TC9() } ,STR0009) //"Selecionando Informacoes dos Pedidos..."

_oBrwPed:bMark := {|| Marcar()}

ACTIVATE DIALOG oDlgPedL CENTERED

DbSelectArea("TC9")
DbCloseArea()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMK4a    บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑบ          ณ Funcao:		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TTMK4a(_cParam)
_cOper:=_cParam
If MsgYesNo(STR0010+IIf(_cOper==_cLibera,STR0011,STR0012)+; //"Confirma "###"a Liberacao "###"o Estorno da Liberacao "
	STR0013) //"dos Pedidos Marcados ? "
	MsAguarde({||TTMK41()},STR0014) //'Processando... '
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMK41    บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑบ          ณ Funcao:		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TTMK41()
DbSelectArea('TC9')
DbGoTop()
_nProc:=0
Do While !Eof()
	If TC9->C9_OK==_cMarca
		DbSelectArea('SC9')
		DbSetOrder(1)
		If DbSeek(xFilial('SC9')+TC9->C9_PEDIDO+TC9->C9_ITEM)
			While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == TC9->C9_PEDIDO .AND. SC9->C9_ITEM == TC9->C9_ITEM 
				If Empty(SC9->C9_NFISCAL)
					If _cOper==_cLibera
						RecLock('SC9',.f.)
						SC9->C9_BLPRE:=PadR(cUserName ,15)+" "+dtoc(date())+" "+time()+" h"
						MsUnlock()
						_nProc++
					ElseIf _cOper==_cEstorna
						RecLock('SC9',.f.)
						SC9->C9_BLPRE:=''
						MsUnlock()
						_nProc++
					EndIf
				EndIf
				DbSkip()
			End  
		EndIf
		DbSelectArea('TC9')
		RecLock('TC9',.f.)
		DbDelete()
		MsUnLock()
		Msproctxt(alltrim(str(_nProc))+STR0015) //" itens de Pedidos Liberados"
	EndIf
	DbSkip()
End  
If _nProc > 0
	MsgBox(STR0016,STR0017,'INFO') //'Libera็ใo Efetuada com Sucesso!'###'Liberacao de Precos'
EndIf
DbGoTop()
DlgRefresh(oDlgPedL)
SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMK42    บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑบ          ณ Funcao:		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TTMK42()

SC5->(DBSETORDER(1))
If !SC5->(DbSeek(xFilial("SC5")+TC9->C9_PEDIDO,.f.))
	MsgBox(STR0018) //"Registro nao localizado na tabela [Cabecalho de pedidos de venda]"
	Return
EndIf

_cVend:=SC5->C5_VEND1
_dEmissao:=SC5->C5_EMISSAO
SUA->(DbSetOrder(8))
_cSuaNum:=""
If SUA->(DbSeek(xFilial("SUA")+SC5->C5_NUM,.f.))
	_cSuaNum:=SUA->UA_NUM
EndIf
If Empty(_cSuaNum)
	T_TTMK4V(SC5->C5_FILIAL+SC5->C5_NUM,"SC5")
Else
	T_TTMK4V(SUA->UA_FILIAL+_cSuaNum,"SUA")
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMK4V    บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	  บฑฑ
ฑฑฬออออออออออุออออออออัออออออุออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบFernando  ณ07/03/07ณ811   ณbops-105595- core็ใo feita no calculo do    บฑฑ
ฑฑบ          ณ        ณ      ณcampo divisใo                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Template Function TTMK4V(_cPedOrc,_cAlias,_lBotao)
Local _nVez,_lDeshBot

_lDeshBot := If(_lBotao= Nil,.T.,_lBotao)

_cAlias:=Upper(_cAlias)
If _cAlias=="SUA"
	_cAlias1:="SUB"
ElseIf _cAlias=="SC5"
	_cAlias1:="SC6"
EndIf

DbSelectArea(_cAlias)
Dbsetorder(1)
If !Dbseek(_cPedOrc,.f.)
	If _cAlias=="SC5"
		_cMens:=STR0019 //"Pedido de venda nao localizado no faturamento"
	ElseIf _cAlias=="SUA"
		_cMens:=STR0020 //"Orcamento nao localizado no Telemarketing"
	Else
		_cMens:=""
	EndIf
	MsgBox(_cMens)
	Return
EndIf
_cCliente := If(_cAlias=="SC5",SC5->C5_CLIENTE,SUA->UA_CLIENTE)
_cCond    := If(_cAlias=="SC5",SC5->C5_CONDPAG,SUA->UA_CONDPG)

sx3->(DbSetOrder(1))
sx3->(DbSeek(_cAlias,.f.))
_vItens:= {}
While sx3->(!Eof().and.x3_arquivo==_cAlias)
	If sx3->((x3_tipo<>"M".and.x3_context<>"V".and.X3Uso(x3_usado)).or.Alltrim(x3_campo)$"UA_ESTE")
		_cDescric:=padr(alltrim(SX3->x3_descric)+": ",28,' ')+" "
		_xConteudo:=_cAlias+"->"+sx3->x3_campo
		_xConteudo:=&_xConteudo
		If Valtype(_xConteudo)=="D"
			_xConteudo:=dtoc(_xConteudo)
		ElseIf Valtype(_xConteudo)=="N"
			_xConteudo:=padl(tran(_xConteudo,sx3->x3_picture),30)
		ElseIf Valtype(_xConteudo)=="L"
			_xConteudo:=If(_xConteudo,".T.",".F.")
		EndIf
		If alltrim(sx3->x3_campo)$"UA_CLIENTE/C5_CLIENTE"
			_xConteudo+=" "+posicione("SA1",1,xfilial("SA1")+_xConteudo,"A1_NOME")
		ElseIf alltrim(sx3->x3_campo)$"UA_VEND/C5_VEND1"
			_xConteudo+=" "+posicione("SA3",1,xfilial("SA3")+_xConteudo,"A3_NOME")
		EndIf
		AAdd(_vItens,_cDescric+_xConteudo)
	EndIf
	sx3->(Dbskip(1))
End  

// Carga do Aheader
aHeader:={}

// Logo APOS o campo abaixo, sera exibido no acols o custo unitario e total
// do item, de acordo com a politica de precos correspondente...
_cRefSUB:="UB_VLRITEM"
_cRefSC6:="C6_VALOR"

sx3->(DbSetOrder(2))

// Alteracao para inclusao da marca no acols
sx3->(DbSeek("B1_FABRIC",.f.))
_vSb1Marca:=sx3->({STR0021,x3_campo,x3_picture,4,x3_decimal,; //"Marca"
x3_valid,x3_usado,x3_tipo,x3_arquivo})
//sx3->(dbseek("LH7_VALREF",.f.))
sx3->(DbSeek("LH7_PRC",.f.))
_vLH7Uni:=sx3->({STR0022,x3_campo,x3_picture,x3_tamanho,x3_decimal,; //"Custo unitario"
x3_valid,x3_usado,x3_tipo,x3_arquivo})
sx3->(DbSeek("LH7_PRC",.f.))
_vLH7Tot:=sx3->({STR0023,x3_campo,x3_picture,x3_tamanho,x3_decimal,; //"Custo Total"
x3_valid,x3_usado,x3_tipo,x3_arquivo})
sx3->(DbSeek("LH7_PRC",.f.))
_vDivisao:=sx3->({"Divisao","DIVISAO","@er 999.99",6,2,; 
x3_valid,x3_usado,x3_tipo,x3_arquivo})

sx3->(DbSetOrder(1))
sx3->(DbSeek(_cAlias1,.f.))

While sx3->(!Eof().and.x3_arquivo==_cAlias1)
	If sx3->(x3_tipo<>"M".and.x3_context<>"V".and.!(alltrim(x3_campo)$"C6_FILIAL/UB_FILIAL/C6_NUM/UB_NUM/C6_SEGUM/UB_SEGUM/C6_UNSVEN/UB_UNSVEN"))
		sx3->(aadd(aHeader,{x3_titulo,x3_campo,x3_picture,If(alltrim(x3_campo)$"C6_PRODUTO/UB_PRODUTO",8,x3_tamanho),x3_decimal,;
		x3_valid,x3_usado,x3_tipo,x3_arquivo}))
	EndIf
	If alltrim(sx3->x3_campo)$"C6_DESCRI/UB_DESCRI"
		AAdd(aHeader,_vDivisao)
		AAdd(aHeader,_vSb1Marca)
	EndIf
	If alltrim(sx3->x3_campo)$_cReFSub+"/"+_cRefSC6
		AAdd(aHeader,_vLH7Uni)
		AAdd(aHeader,_vLH7Tot)
	EndIf
	sx3->(DbSkip(1))
End  

// Carga do acols para SUB / SC6
aCols:={}
If _cAlias=="SUA"
	_cTitulo:=STR0025 //"Dados do orcamento (Origem: Telemarketing)"
	sub->(DbSetOrder(1)) // UB_FILIAL+UB_NUM+UB_ITEM+UB_PRODUTO
	sub->(DbSeek(_cPedOrc,.f.))
	_cCondWhile := "SUB->(! Eof()) .AND. SUB->UB_FILIAL == '"+xFilial("SUB")+"' .AND. SUB->UB_NUM == SUA->UA_NUM"
	_cValTot    := "SUB->UB_VLRITEM"
ElseIf _cAlias=="SC5"
	_cTitulo:=STR0026 //"Dados do pedido de venda (Origem: Faturamento)"
	sc6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	sc6->(DbSeek(_cPedOrc,.f.))
	_cCondWhile := "SC6->(! Eof()) .AND. SC6->C6_FILIAL == '"+xFilial("SC6")+"' .AND. SC6->C6_NUM == SC5->C5_NUM"
	_cValTot    := "SC6->C6_VALOR"
EndIf
_nValTot:=0 // valor unitario x quantidade
While &(_cCondWhile)
	_vItensSub:={}
	For _nVez:=1 To Len(aHeader)
		If (ALLTRIM(aHeader[_nVez][2])$"LH7_PRC/DIVISAO/B1_FABRIC")==.f.		
			_xConteudo:=_cAlias1+"->"+alltrim(aHeader[_nVez][2])
			_xConteudo:=&_xConteudo
		Else
			_xConteudo:=0
		EndIf
		AAdd(_vItensSub,_xConteudo)
	Next
	AAdd(_vItensSub,.f.)
	AAdd(aCols,_vItensSub)
	// Calculo do valor total de venda
	_nValTot+=(&_cValTot)
	If _cAlias=="SC5"
		sc6->(Dbskip(1))
	ElseIf _cAlias=="SUA"
		sub->(Dbskip(1))
	EndIf
End  

// Carga dos custos
_nCustoGer:=0
Posicione("SU0",1,xFilial("SU0")+If(!Empty(SA1->A1_GRUPOAT),SA1->A1_GRUPOAT,Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_POSTO")),"U0_CALAFIN")
For _nVez:=1 To Len(aCols)
	_cProduto:=aCols[_nVez,AsCan(aHeader,{|x|Alltrim(x[2])==If(_cAlias=="SC5","C6_PRODUTO","UB_PRODUTO")})]
	aCols[_nVez,Ascan(aHeader,{|x|Alltrim(x[2])=="B1_FABRIC"})]:=posicione("SB1",1,xfilial("SB1")+_cProduto,"B1_FABRIC")
	
	_nCustoUni:= If(ExistBlock("TCOMA01PC"),U_TCOMA01PC(Val(SUA->UA_POLITIC)),T_TCOMA01PC())//posicione("LH7",1,xfilial("LH7")+_cProduto,"LH7_PRC")	
	_aCustoUni := T_PerAcrePre(_nCustoUni,If(_cAlias=="SC5",SC5->C5_CONDPAG,SUA->UA_CONDAF),SU0->U0_CALAFIN,SU0->U0_CALAFRE)
	_nCustoTot:=aCols[_nVez,AsCan(aHeader,{|x|Alltrim(x[2])==If(_cAlias=="SC5","C6_QTDVEN","UB_QUANT")})]*_aCustoUni[1]
	_nCustoGer+=_nCustoTot
	
	aCols[_nVez][ascan(aHeader,{|x|alltrim(x[2])=="LH7_PRC"})]   :=_nCustoUni
	aCols[_nVez][ascan(aHeader,{|x|alltrim(x[2])=="LH7_PRC"})+1] :=_nCustoTot
	
	_nTotLin:=aCols[_nVez][ascan(aHeader,{|x|alltrim(x[2])==If(_cAlias=="SC5","C6_VALOR","UB_VLRITEM")})]

	_nDivisao:=100-(_nCustoTot/(_nTotLin*100))
	aCols[_nVez][ascan(aHeader,{|x|alltrim(x[2])=="DIVISAO"})]:=_nDivisao
Next

_nList:=1
@ 000,000 TO 400,780  	DIALOG _oDlg1 TITLE _cTitulo
@ 005,005 LISTBOX _nList ITEMS _vItens SIZE 382,080
@ 085,005 say STR0027 //"Itens"

@ 095,005 TO 180,387 MULTILINE
@ 183,015 say STR0028+; //"Custo total das mercadorias:         "
              (tran(_nCustoGer,pesqpict("SF2","F2_VALFAT")))+;
              Space(10)+STR0029+Posicione('SA1',1,xFilial('SA1')+_cCliente,'A1_EST')+; //"Estado: "
              Space(10)+STR0030+Posicione('SE4',1,xFilial('SE4')+_cCond,'E4_DESCRI') //"Condicao: "

@ 192,015 Say STR0031+; //"Valor de venda das mercadorias: "
              (tran(_nValTot,pesqpict("SF2","F2_VALFAT")))+;
              Space(10)+STR0032+alltrim(tran(100-(_nCustoGer/(_nValtot*100)),; //"Divisao: "
              "@er 9,999.99")) + Space(10)
         
If _lDeshBot
	@ 183,280 BUTTON STR0033 SIZE 070,13 ACTION _fMarcaC9() //"_Marcar todos os itens"
EndIf
@ 183,360 BmpButton Type 2 Action Close(_oDlg1)

Activate DIALOG _oDlg1 Centered

DbSelectArea("SC9")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TC9  บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑบ          ณ Funcao:		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cria_TC9()
Local _nX
DbSelectArea('SX3')
DbSetOrder(1)
aFields := {}
AAdd(aFields,{"C9_OK","C",02,0})
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
		If !(ALLTRIM(X3_CAMPO) $ _cCampos) 
			DbSkip()
			Loop
		EndIf
		AAdd(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		DbSkip()
	End  
Next
cArq:=Criatrab(aFields,.T.)
DbuseArea(.t.,,cArq,"TC9")

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TC9 บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑบ          ณ Funcao:		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_TC9()
Local _nX
_nCount := 0
cQueryCad := ""
For _nX := 1 To 2
	If _nX = 1
		cQueryCad := "SELECT COUNT(*) AS TOTAL FROM "+RetSqlName('SC9')+" C9  WHERE "
	Else
		cQueryCad := "SELECT "+_cCampos
		cQueryCad += " FROM "+RetSqlName('SC9')+" C9 , "
		If !Empty(MV_PAR05)		
			cQueryCad += "      "+RetSqlName('SU7')+" U7 , "
		EndIf
		cQueryCad += "      "+RetSqlName('SA1')+" A1  WHERE "
		cQueryCad += "A1.D_E_L_E_T_ <> '*' AND "
		cQueryCad += "A1.A1_FILIAL = '"+xFilial("SA1")+"' AND "		
		If !Empty(MV_PAR05)				
			cQueryCad += "U7.U7_FILIAL = '"+xFilial("SU7")+"' AND "				
		EndIf
		cQueryCad += "A1.A1_COD  = C9.C9_CLIENTE AND "
		cQueryCad += "A1.A1_LOJA = C9.C9_LOJA AND "
		If !Empty(MV_PAR05)		
			cQueryCad += "C9.C9_VEND = U7.U7_CODVEN AND "		
			cQueryCad += " (U7.U7_POSTO = '"+MV_PAR05+"' OR A1.A1_GRUPOAT = '"+MV_PAR05+"') AND "			
		EndIf
	EndIf
	cQueryCad += "C9.D_E_L_E_T_ <> '*' AND "
	cQueryCad += "C9.C9_FILIAL = '"+xFilial("SC9")+"' AND "
	cQueryCad += "C9.C9_NFISCAL = '' "
	If !Empty(MV_PAR01)
		cQueryCad += " AND C9.C9_PEDIDO = '"+MV_PAR01+"'"
	EndIf
	If !Empty(MV_PAR02)
		cQueryCad += " AND C9.C9_CLIENTE = '"+MV_PAR02+"'"
	EndIf
	If MV_PAR03 = 1
		cQueryCad += " AND C9.C9_BLPRE = ''"
	EndIf
	If _nX = 2
		cQueryCad += " ORDER BY "+If(MV_PAR04=2,"A1.A1_NOME,C9.C9_PEDIDO",;
		If(MV_PAR04=3,"C9.C9_PRODUTO,C9.C9_PEDIDO,C9.C9_ITEM",;
		"C9.C9_PEDIDO,C9.C9_ITEM"))
	EndIf
	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
 		_nCount := CAD->TOTAL
		DbCloseArea()
	EndIf
Next

Dbselectarea("CAD")
DbGoTop()
ProcRegua(_nCount)

While CAD->(!EOF())
	IncProc()
	RecLock("TC9",.T.)
	For _nX := 1 To Len(aFields)
		If aFields[_nX,1] <> 'C9_OK'
			If aFields[_nX,2] = 'C'
				_cX := 'TC9->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
			Else
				_cX := 'TC9->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
			Endif
			_cX := &_cX
		Endif
	Next
	If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
		TC9->C9_OK := _cMarca
	Else
		TC9->C9_OK := ThisMark()
	EndIf
	MsUnLock()
	CAD->(dBSkip())
End  
Dbselectarea("CAD")
DbCloseArea()
Dbselectarea("TC9")
DbGoTop()

_cIndex:=Criatrab(Nil,.F.)
_cChave:=If(MV_PAR04=2,"A1_NOME+C9_PEDIDO",;
If(MV_PAR04=3,"C9_PRODUTO+C9_PEDIDO+C9_ITEM",;
"C9_PEDIDO+C9_ITEM"))
Indregua("TC9",_cIndex,_cChave,,,STR0043) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())

SysRefresh()
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcar    บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑบ          ณ Funcao:		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Marcar()
DbSelectArea('TC9')
RecLock('TC9',.F.)
TC9->C9_OK := If(Empty(TC9->C9_OK),_cMarca,ThisMark())
MsUnlock()
DlgRefresh(oDlgPedL)
SysRefresh()
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_fMarcaC9 บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑบ          ณ Funcao:		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function _fMarcaC9()
DbSelectArea('TC9')
_nRecTc9 := Recno()
DbGoTop()
_nItensMarc:=0
While !Eof()
	If TC9->C9_PEDIDO==SC5->C5_NUM .And. Empty(TC9->C9_BLPRE)
		RecLock('TC9',.f.)
		TC9->C9_OK:=_cMarca
		MsUnlock()
		_nItensMarc++
	EndIf
	DbSkip()
End  
msgbox(STR0044+alltrim(str(_nItensMarc)),STR0045,"INFO") //"Itens Marcados: "###"Liberacao Preco"
Close(_oDlg1)
DbGoTo(_nRecTc9)
DlgRefresh(oDlgPedL)
SysRefresh()
Return(Nil)
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMK43    บAutor  ณMicrosiga           บ Data ณ  07/26/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Template DCM                                               บฑฑ
ฑฑบ          ณ Funcao:		                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TTMK43() 
Local _aAreaT43 := GetArea()
Local _cBloqs   := ''
If !Empty(TC9->C9_BLINF)
	DbSelectArea("LH9")
	DbGoTop()
	While !Eof()
		If LH9->LH9_CODIGO $ TC9->C9_BLINF
			_cBloqs += LH9->LH9_CODIGO+' - '+LH9->LH9_DESCRI+Chr(13)
		EndIf
		DbSkip()
	End  
	If !Empty(_cBloqs)
		MsgInfo(_cBloqs)
	Endif
Endif
RestArea(_aAreaT43)
Return(Nil)
