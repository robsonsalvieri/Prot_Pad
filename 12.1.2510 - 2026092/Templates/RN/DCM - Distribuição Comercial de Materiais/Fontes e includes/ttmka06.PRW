#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "Protheus.Ch" 
#include "ttmka06.Ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTTMKA06   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ MarkBrowse com filtro de pedidos para pesquisa, visualiza  บฑฑ
ฑฑบ          ณ cao e impressao                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TTMKA06()
Local _nX

Private cCadastro := "Pedidos "
Private cDelFunc  := ".T."
Private cString   := "SC9"
Private _lFiltra  := .f.
Private _cOper
Private _lSair    := .f.
Private cQueryCad := ""
Private aFields   := {}
Private cArq      := ""
Private _cMarca   := GetMark()
Private _nCount   := _nSomaTot := _nSomaLib := _nSomaPen := _nSomaBlq := 0
Private _cCampos  := "C9_BLCONF,C6_IMPRE,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_CLIENTE,C9_LOJA,UA_DESCCLI,C9_PRODUTO,C9_LOCAL,C9_QTDLIB,"+;
                     "C9_PRCVEN,C9_BLEST,C9_BLCRED,C9_BLPRE,C6_BLQ,C6_ENTREG,C6_DESCRI,C5_VEND1,C6_PERCOM,C6_COMISSA,C9_NFISCAL,"+;
                     "C9_SERIENF,C5_CONDPAG,C5_TRANSP,F2_DTENTR,C9_DATALIB,C9_NFENT,C9_SERENT,C9_FORNEC,C9_LOJAFOR,UA_NUM,C9_LOJA,C5_MENNOTA,C7_QUANT,"+;
                     "C7_DATPRF,C5_REQCLI,C5_NOMEREQ "
// Informar os campos nesta variavel conforme a ordem que deseja que apareca na tela e informar o campo na query na funcao que monta
Private _cOrdem   := ""
Private cPar      := ""

CHKTEMPLATE("DCM")

/*
MV_PAR01 - Pedido De
MV_PAR02 - Pedido Ate
MV_PAR03 - Cliente De
MV_PAR04 - Cliente Ate
MV_PAR05 - Produto De
MV_PAR06 - Produto Ate
MV_PAR07 - Requisitante
MV_PAR08 - Vendedor
MV_PAR09 - Situacao (Liberados/Bloqueados)
MV_PAR10 - Ordem
MV_PAR11 - Filtra Conferidos
MV_PAR12 - Req. Cliente
MV_PAR13 - Nota Fiscal
MV_PAR14 - Considera Compras
MV_PAR15 - Data Liberacao
MV_PAR16 - Grupo de Atendimento
*/

SA3->(DbSetOrder(2))
SA3->(DbSeek(XFILIAL("SA3")+Rtrim(CUSERNAME)))
cPar:= Padr("LP"+StrZero(SA3->(RECNO()),4),10)
ValidPerg(cPar)
While Pergunte(cPar,.T.)
	
	SU7->(DbSetOrder(3))
	SU7->(DbSeek(XFILIAL("SU7")+Rtrim(cUserName)))
	
	If (MV_PAR08 <> SA3->A3_COD) .And. !(Upper(Rtrim(cUserName)) $ Alltrim(Upper(SuperGetMv('MV_USUCANT'))))
		MsgStop(STR0002) //'Verifique o parametro Vendedor, para analisar somente seus dados!'
		Return(.T.)
	EndIf
	If !Empty(MV_PAR23) .And. (MV_PAR23 <> SU7->U7_COD) .And. !(Upper(Rtrim(cUserName)) $ Alltrim(Upper(SuperGetMv('MV_USUCANT'))))
		MsgStop(STR0069) //'Verifique o parametro Operador Supervisor, somente Supervisores podem utiliza-lo!'
		Return(.T.)
	EndIf
	
	cCadastro :="Pedidos "+If(MV_PAR09=1,"Liberados",If(MV_PAR09=2,"Pendentes",If(MV_PAR09=3,"Faturados",IF(MV_PAR09=4,"Bloqueados","Todos"))))
	If MV_PAR10 = 1
		_cOrdem := 'C9_PEDIDO, C9_ITEM, C9_SEQUEN'
	ElseIf MV_PAR10 = 2
		_cOrdem := 'C9_CLIENTE, C5_NOMEREQ, C9_PRODUTO'
	ElseIf MV_PAR10 = 3
		_cOrdem := 'C9_PEDIDO, C6_DESCRI'
	ElseIf MV_PAR10 = 4
		_cOrdem := 'C9_PRODUTO, C9_PEDIDO'
	EndIf
	
	@ 100,005 TO 500,If(Upper(Rtrim(cUserName)) $ Alltrim(SuperGetMv('MV_USUCANT')),1090,1000) DIALOG oDlgPedL TITLE STR0003+IIf(Empty(MV_PAR23)," - "+CUSERNAME,STR0070+Posicione("SU7",3,xFilial("SU7")+Rtrim(cUserName),STR0071)) //"Pedidos "###" - Operadores do Supervisor: "###"U7_NOME"
	aCampos := {}
	Private _aArqSel  := {'SC5','SC6','SC9','SUA','SF2',If(MV_PAR14<>1.And.MV_PAR09=2,'SC7','')}
	DbSelectArea('SX3')
	DbSetOrder(1)
	AAdd(aCampos,{'000','C9_OK','','@!','2','0'})
	For _nX := 1 To Len(_aArqSel)
		DbSeek(_aArqSel[_nX])
		While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
			If ALLTRIM(X3_CAMPO) $ _cCampos
				AAdd(aCampos,{StrZero(AT(ALLTRIM(X3_CAMPO),_cCampos),3,0),Alltrim(X3_CAMPO),If(X3_CAMPO='C9_BLCONF','',Alltrim(X3_TITULO)),X3_PICTURE,X3_TAMANHO,X3_DECIMAL})
			EndIf
			DbSkip()
		End  
	Next
	ASort(aCampos,,,{|x,y|x[1]<y[1]})
	
	aCampos2 := {}
	For _nX := 1 To Len(aCampos)
		AAdd(aCampos2,{aCampos[_nX,2],aCampos[_nX,3],aCampos[_nX,4],aCampos[_nX,5],aCampos[_nX,6]})
	Next
	aCampos := {}
	aCampos := aCampos2
	Cria_TC9()
	DbSelectArea('TC9')
	@ 006,005 TO 190,450 BROWSE "TC9" MARK "C9_OK" ENABLE "T_VerHabi()" FIELDS aCampos Object _oBrwPed
	@ 006,455 BUTTON STR0010  SIZE 40,15 OF oDlgPedL PIXEL ACTION MarcaTudo() //"_Marca Tudo"
	@ 026,455 BUTTON STR0072  SIZE 40,15 OF oDlgPedL PIXEL ACTION Historico() //"Historico"
	@ 046,455 BUTTON STR0015  SIZE 40,15 OF oDlgPedL PIXEL ACTION estoque() //"_Estoque"
	@ 066,455 BUTTON STR0016  SIZE 40,15 OF oDlgPedL PIXEL ACTION espnota() //"Es_pelho Nota"
	@ 086,455 BUTTON STR0073  SIZE 40,15 OF oDlgPedL PIXEL ACTION TransLib() //"Transf.Liberac"
	If Upper(Rtrim(cUserName)) $ Alltrim(SuperGetMv('MV_USUCANT'))
		@ 006,500 BUTTON STR0012 SIZE 40,15 OF oDlgPedL PIXEL ACTION ImprimirRel() //"_Imp.Relatorio"
		@ 026,500 BUTTON STR0013 SIZE 40,15 OF oDlgPedL PIXEL ACTION CancelaPed() //"C.I._Liberados"
		@ 046,500 BUTTON STR0014 SIZE 40,15 OF oDlgPedL PIXEL ACTION CancelaIte() //"_C.I.Pendentes"
		@ 066,500 BUTTON STR0074 SIZE 40,15 OF oDlgPedL PIXEL ACTION CancelaPend() //"Excluir Pend."
	EndIf
	@ 166,455 BUTTON STR0075 		  SIZE 40,15 OF oDlgPedL PIXEL ACTION legenda() //"Legenda"
	@ 183,455 BUTTON STR0017 		  SIZE 40,15 OF oDlgPedL PIXEL ACTION Close(oDlgPedL) //"_Sair"
	
	Processa({|| Monta_TC9() } ,STR0018) //"Selecionando Informacoes dos Pedidos..."
	
	_oBrwPed:bMark := {|| Marcar()}
	_oBrwPed:oBrowse:blDblClick := {|| VisPed()}
	
	oSayTotal := TSAY():Create(oDlgPedL)
	oSayTotal:cName := "oSayTotal"
	oSayTotal:cCaption := STR0076+Transform(_nCount,"9999999")+; //"Registros na Tela:"
	                      STR0077+Transform(_nSomaTot,"@ER 99,999,999.99")+; //" - Total Geral: "
	                      STR0078+Transform(_nSomaLib,"@ER 99,999,999.99")+; //" - Liberado (E): "
	                      STR0079+Transform(_nSomaPen,"@ER 99,999,999.99")+; //" - Pendente (E): "
	                      STR0080+Transform(_nSomaBlq,"@ER 99,999,999.99") //" - Bloqueados (C/R): "
	oSayTotal:nLeft := 10
	oSayTotal:nTop := 386
	oSayTotal:nWidth := 800
	oSayTotal:nHeight := 17
	oSayTotal:lShowHint := .F.
	oSayTotal:lReadOnly := .F.
	oSayTotal:Align := 0
	oSayTotal:lVisibleControl := .T.
	oSayTotal:lWordWrap := .F.
	oSayTotal:lTransparent := .F.
	oSayTotal:SetColor(CLR_BLUE,CLR_WHITE)	
	ACTIVATE DIALOG oDlgPedL CENTERED
	
	DbSelectArea("TC9")
	DbCloseArea()
End  

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVisPed    บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function VisPed()
PRIVATE lOnUpdate  := .T.
PRIVATE l410Auto   := .F.
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}
PRIVATE aRotina    := MenuDef()
PRIVATE cCadastro := STR0083 //"Visualiza็ใo de Pedidos de Venda"
If SC5->(DbSeek(xFilial("SC5")+TC9->C9_PEDIDO))
	Processa({||A410Visual("SC5",SC5->(Recno()),2)},STR0084) //"Aguarde..."
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLegenda   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Legenda()
BrwLegenda(STR0075,STR0085,{{"DCMIMG03.PNG",     STR0086},; //"Legenda"###"Visualiza Pedidos"###"           Liberados parcial e nใo conferidos"
							{"DCMIMG01.PNG",      STR0087},; //"           Liberados e nใo conferidos"
							{"DCMIMG01.PNG",      STR0088},; //"   OK   Liberados e conferidos"
							{"DCMIMG04.PNG",  	  STR0089},; //"           Bloqueados"
							{"DCMIMG04.PNG",  	  STR0090}}) //"   OK   Faturados"
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEspNota   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function EspNota()
Local cPergEN := Padr("NFSIGW",Len(SX1->X1_GRUPO))
If !Empty(TC9->C9_NFISCAL)
	If sx1->(DbSeek(cPergEN+"01",.f.).and.reclock(alias(),.f.))
		sx1->x1_cnt01:= TC9->C9_NFISCAL
		sx1->(msunlock())
	EndIf
	If sx1->(DbSeek(cPergEN+"02",.f.).and.reclock(alias(),.f.))
		sx1->x1_cnt01:= TC9->C9_NFISCAL
		sx1->(msunlock())
	EndIf
	If sx1->(DbSeek(cPergEN+"03",.f.).and.reclock(alias(),.f.))
		sx1->x1_cnt01:= TC9->C9_SERIENF
		sx1->(msunlock())
	EndIf
	If sx1->(DbSeek(cPergEN+"04",.f.).and.reclock(alias(),.f.))
		sx1->x1_PRESEL:= 2
		sx1->(msunlock())
	EndIf
	
	_cProgNf := SuperGetMV('MV_PROGNF')
	_cProgNf := &_cProgNf
EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerHabi   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function VerHabi()

CHKTEMPLATE("DCM")

If Empty(TC9->C9_BLEST) .And. Empty(TC9->C9_BLCRED) .And. Empty(TC9->C9_NFISCAL)
	Return(.F.)
EndIf
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcar    บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Marcar()
DbSelectArea('TC9')
RecLock('TC9',.F.)
TC9->C9_OK := If(Empty(TC9->C9_OK),_cMarca,ThisMark())
MsUnlock()
DlgRefresh(oDlgPedL)
SysRefresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcaTudo บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MarcaTudo()
DbSelectArea('TC9')
DbGoTop()
While !Eof()
	RecLock('TC9',.F.)
	TC9->C9_OK := _cMarca
	MsUnlock()
	DbSkip()
End
DbGoTop()
DlgRefresh(oDlgPedL)
SysRefresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimirRel บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ImprimirRel()
T_TFATR02(cCadastro + STR0021 + If(MV_PAR10 == 1, STR0022, If(MV_PAR10 == 2, STR0023, If(MV_PAR10 == 3, STR0024, STR0025))),; //' - Ordenados por: '###'Pedido+Item+Sequencia'###'Cliente+Requisitante+Produto'###'Pedido+Descricao do Produto'###'Produto+Pedido'
          IIf(MV_PAR14 > 1 .And. MV_PAR09 == 2, MV_PAR14, 1))
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCancelaPed  บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function CancelaPed()
Local I

If !MsgYesNo(STR0026) //"Confirma o Estorno das Liberacoes dos Itens Marcados ?"
	Return(.T.)
EndIf

_lPedAut := .F.

DBSelectArea('SC6')
DBSetOrder(1)

DBSelectArea('SC9')
DBSetOrder(1)

// Primeiro - Estorna os Itens do SC9.
DBSelectArea('TC9')
DBGoTop()
While !Eof()
	
	If C9_OK  == _cMarca
		
		If !Empty(TC9->UA_NUM)
			If !Empty(Posicione('SUA',1,xFilial('SUA')+TC9->UA_NUM,'UA_OPERADO'))
				If !Empty(Posicione('SU7',1,xFilial('SU7')+SUA->UA_OPERADO,'U7_POSTO'))
					If Posicione('SU0',1,xFilial('SU0')+SU7->U7_POSTO,'U0_PEDAUT') == 'S'
						_lPedAut := .T.
					EndIf
				EndIf
			EndIf
		EndIf
		If !_lPedAut
			If !ValidCan(1)
				Return(.T.)
			EndIf
		EndIf
		
		If SC6->(DbSeek(xFilial('SC6')+TC9->C9_PEDIDO+TC9->C9_ITEM+TC9->C9_PRODUTO)) .And. ;
			SC9->(DbSeek(xFilial('SC9')+TC9->C9_PEDIDO+TC9->C9_ITEM+TC9->C9_SEQUEN))
			IF SC9->C9_BLCRED <> "10" .AND. SC9->C9_BLEST <> "10"
				RecLock('SC9',.F.)
				SC9->C9_BLINF := Upper(Rtrim(cUserName))+" "+dtoc(date())+" "+time()+" h"
				MsUnlock()
				A460Estorna()
			EndIf
		EndIf
		
	EndIf
	
	DBSelectArea('TC9')
	DBSkip()
	
End  

DBSelectArea('TC9')
DBCloseArea()
FErase(cArq+".DBF")
Cria_TC9()
Processa({|| Monta_TC9() } ,STR0038) //"Refazendo do filtro de Informacoes dos Pedidos..."
SysRefresh()
MsgBox(STR0039,STR0040,STR0091) //'Clique em OK e no grid para atualizar a tela...'###'Informacao'###'INFO'
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCancelaIte  บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CancelaIte()

If !MsgYesNo(STR0041) //"Confirma o Cancelamento do Item Selecionado ?"
	Return(.T.)
EndIf

_lPedAut := .F.

DbSelectArea('SC6')
DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
DbSeek(xFilial('SC6')+TC9->C9_PEDIDO+TC9->C9_ITEM+TC9->C9_PRODUTO)

DbSelectArea('SC9')
DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
If DbSeek(xFilial('SC9')+TC9->C9_PEDIDO+TC9->C9_ITEM+TC9->C9_SEQUEN+TC9->C9_PRODUTO)
	If TC9->C9_BLCRED <> "10" .and. TC9->C9_BLEST <> "10"
		
		If !Empty(TC9->UA_NUM)
			If !Empty(Posicione('SUA',1,xFilial('SUA')+TC9->UA_NUM,'UA_OPERADO'))
				If !Empty(Posicione('SU7',1,xFilial('SU7')+SUA->UA_OPERADO,'U7_POSTO'))
					If Posicione('SU0',1,xFilial('SU0')+SU7->U7_POSTO,'U0_PEDAUT') == 'S'
						_lPedAut := .T.
					EndIf
				EndIf
			EndIf
		EndIf
		If !_lPedAut
			If !ValidCan(2)
				Return(.T.)
			EndIf
		EndIf
		If Empty(TC9->C9_OK)
			msgStop(STR0043) //'Utilize para este item o botao Estornar Lib. Itens'
			return(.T.)
		EndIf
		
		RecLock('SC9',.F.)
		SC9->C9_BLINF := Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
		MsUnlock()
		
		A460Estorna()
		
	EndIf
EndIf

DBSelectArea('TC9')
DBCloseArea()
FErase(cArq+".DBF")
Cria_TC9()
Processa({|| Monta_TC9() } ,STR0038) //"Refazendo do filtro de Informacoes dos Pedidos..."
SysRefresh()
MsgBox(STR0039,STR0040,'INFO') //'Clique em OK e no grid para atualizar a tela...'###'Informacao'
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TC9    บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  

Static Function Cria_TC9()
Local _nX

If Select('TC9') > 0
	TC9->(DbCloseArea())
EndIf

DbSelectArea('SX3')
DbSetOrder(1)
aFields := {}
AAdd(aFields,{"C9_OK"     ,"C",02,0})
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	While !Eof() .And. X3_ARQUIVO = _aArqSel[_nX]
		If ALLTRIM(X3_CAMPO) $ _cCampos
			AADD(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		EndIf
		DbSkip()
	End  
Next
cArq:=Criatrab(aFields,.T.)
DBUSEAREA(.t.,,cArq,"TC9")

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TC9   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  

Static Function Monta_TC9()
Local _nX

_nCount  := 0
_nSomaTot:= 0
_nSomaLib:= 0
_nSomaPen:= 0
_nSomaBlq:= 0


Pergunte(cPar,.F.)

For _nX := 1 To 2
	If _nX == 1
		_cQuery := "SELECT Count(C9_PEDIDO+C9_ITEM) AS TOTAL "
	Else
		_cQuery := "SELECT C9_BLCONF,C9_PEDIDO,C9_ITEM,C5_EMISSAO,C9_CLIENTE,UA_DESCCLI,C5_REQCLI,C5_NOMEREQ,C9_PRODUTO,C6_DESCRI,C9_QTDLIB, "
		_cQuery += " C9_PRCVEN,C9_BLEST,C9_BLCRED,C9_BLPRE,C9_SEQUEN,C6_PERCOM,C6_COMISSA, "
		_cQuery += " C5_VEND1,C9_NFISCAL,C9_SERIENF,C9_DATALIB,C9_NFENT,C9_SERENT, "
		_cQuery += " C9_FORNEC,C9_LOJAFOR,UA_NUM,C9_LOJA,C5_MENNOTA,C9_LOCAL,C6_IMPRE,C5_TRANSP,C6_ENTREG, "
		_cQuery += " C5_CONDPAG, C6_BLQ "
		
		If MV_PAR14 = 3 .AND. MV_PAR09 == 2
			_cQuery += ",ISNULL((SELECT SUM(C7_QUANT-C7_QUJE) FROM "+RetSqlName('SC7')+" SC7  WHERE SC7.D_E_L_E_T_ <> '*' AND C7_QUANT - C7_QUJE > 0 AND "
			_cQuery += " C7_PRODUTO = C9_PRODUTO  AND C7_DATPRF >= C9_DATALIB),0) AS C7_QUANT, "
			_cQuery += " ISNULL((SELECT DISTINCT C7_DATPRF FROM "+RetSqlName('SC7')+" SC7  WHERE SC7.D_E_L_E_T_ <> '*' AND C7_QUANT - C7_QUJE > 0 AND "
			_cQuery += " C7_PRODUTO = C9_PRODUTO  AND C7_DATPRF >= C9_DATALIB),' ') AS C7_DATPRF "
		Else
			_cQuery += ",0 AS C7_QUANT,'        ' AS C7_DATPRF "
		EndIf
	EndIf
	If MV_PAR14<>1 .AND. MV_PAR14<>3 .AND. MV_PAR09 == 2
		_cQuery += " FROM "+RetSqlName('SC5')+"  , "+RetSqlName('SC6')+"  , "+RetSqlName('SC9')+"  , "+RetSqlName('SUA')+"  ,  "+RetSqlName('SC7')+"  "
	Else
		_cQuery += " FROM "+RetSqlName('SC5')+"  , "+RetSqlName('SC6')+"  , "+RetSqlName('SC9')+"  , "+RetSqlName('SUA')+"  "
	EndIf
	_cQuery += " WHERE "+RetSqlName('SC9')+".D_E_L_E_T_ <> '*' AND  "
	_cQuery += " "+RetSqlName('SC5')+".D_E_L_E_T_ <> '*' AND  "
	_cQuery += " "+RetSqlName('SC6')+".D_E_L_E_T_ <> '*' AND  "
	_cQuery += " "+RetSqlName('SUA')+".D_E_L_E_T_ <> '*' AND  "
	If MV_PAR14 <> 1 .AND. MV_PAR14 <> 3 .AND. MV_PAR09 == 2
		_cQuery += "  "+RetSqlName('SC7')+".D_E_L_E_T_ <> '*' AND "
	EndIf
	_cQuery += " C9_PEDIDO = C5_NUM AND  "
	_cQuery += " C9_PEDIDO = C6_NUM AND  "
	_cQuery += " C9_PEDIDO = UA_NUMSC5 AND "
	_cQuery += " C9_ITEM = C6_ITEM AND "
	_cQuery += " C9_PRODUTO = C6_PRODUTO AND "
	If MV_PAR14 = 2 .AND. MV_PAR09 = 2
		_cQuery += " C9_PRODUTO = C7_PRODUTO AND "
		_cQuery += " C7_QUANT > C7_QUJE AND "
	EndIf
	If MV_PAR14 = 4 .AND. MV_PAR09 = 2
		_cQuery += " C9_PRODUTO *= C7_PRODUTO AND "
	EndIf
	If MV_PAR14 <> 1 .AND. MV_PAR14 <> 3 .AND. MV_PAR09 == 2
		_cQuery += " C7_FILIAL = '"+xFilial("SC7")+"' AND "
	EndIf
	_cQuery += " C9_FILIAL = '"+xFilial("SC9")+"' AND "
	_cQuery += " C5_FILIAL = '"+xFilial("SC5")+"' AND "
	_cQuery += " UA_FILIAL = '"+xFilial("SUA")+"' AND "
	_cQuery += " C6_FILIAL = '"+xFilial("SC6")+"' "
	If !Empty(MV_PAR01)
		_cQuery += " AND C9_PEDIDO >= '"+MV_PAR01+"' AND C9_PEDIDO <= '"+MV_PAR02+"' "
	EndIf
	If !Empty(MV_PAR03)
		_cQuery += " AND C9_CLIENTE >= '"+MV_PAR03+"' AND C9_CLIENTE <= '"+MV_PAR04+"' "
	EndIf
	If !Empty(MV_PAR05)
		_cQuery += " AND C9_PRODUTO >= '"+MV_PAR05+"' AND C9_PRODUTO <= '"+MV_PAR06+"' "
	EndIf
	If !Empty(MV_PAR07)
		_cQuery += " AND C5_CODREQ = '"+MV_PAR07+"' "
	EndIf
	If !Empty(MV_PAR08)
		_cQuery += " AND (C5_VEND1 = '"+MV_PAR08+"' "
		_cQuery += " OR EXISTS (SELECT 'E' FROM "+RetSqlName("SA3")+" A3 WHERE A3.D_E_L_E_T_ = ' ' AND A3_COD = C5_VEND1 AND A3_SUPER = '"+MV_PAR08+"')) "
	EndIf
	If !Empty(MV_PAR12)
		_cQuery += " AND C5_REQCLI = '"+MV_PAR12+"' "
	EndIf
	If !Empty(MV_PAR13)
		_cQuery += " AND C9_NFISCAL = '"+MV_PAR13+"' "
	EndIf
	If MV_PAR09 = 1
		_cQuery += " AND C9_BLEST = ' ' AND RTRIM(C9_NFISCAL)=' ' "
	EndIf
	If MV_PAR09 = 2
		_cQuery += " AND C9_BLEST = '02' "
	EndIf
	If MV_PAR09 = 3
		_cQuery += " AND (C9_BLEST = '10' OR C9_NFISCAL <> ' ') "
	EndIf
	If MV_PAR09 = 4
		_cQuery += " AND C9_NFISCAL = ' ' AND (C9_BLPRE = ' ' OR C9_BLEST <> ' ' OR C9_BLCRED <> ' ') " //" AND (C9_BLCONF = '' OR C9_BLCRED = '02' OR C9_BLPRE = '') "
	EndIf
	If MV_PAR09 = 1 .AND. MV_PAR11 = 1
		_cQuery += " AND C9_BLCONF = 'OK' "
	EndIf
	If MV_PAR14 = 3 .AND. MV_PAR09 = 2
		_cQuery += " AND (NOT EXISTS (SELECT 'EX' FROM "+RetSqlName("SC7")+" C7  WHERE C7.D_E_L_E_T_ <> '*' AND C9_PRODUTO = C7_PRODUTO AND C7_QUANT <> C7_QUJE AND C7_FILIAL = ''"+xFilial("SC7")+"'' ) OR "
		_cQuery += " (SELECT SUM(C7_QUANT-C7_QUJE) FROM "+RetSqlName("SC7")+" C7  WHERE C7.D_E_L_E_T_ <> '*' AND C9_PRODUTO = C7_PRODUTO AND (C7_QUANT-C7_QUJE) > 0 AND C7_FILIAL = '"+xFilial("SC7")+"' ) < C9_QTDLIB) "
	EndIf
	If !Empty(MV_PAR15)
		_cQuery += " AND C9_DATALIB = '"+Dtos(MV_PAR15)+"' "
	EndIf
	If !Empty(MV_PAR17)
		_cQuery += " AND C9_NFENT = '"+MV_PAR17+"' "
	EndIf
	If !Empty(MV_PAR18)
		_cQuery += " AND C9_SERENT = '"+MV_PAR18+"' "
	EndIf
	If !Empty(MV_PAR19)
		_cQuery += " AND C9_FORNEC = '"+MV_PAR19+"' "
	EndIf
	If !Empty(MV_PAR20)
		_cQuery += " AND C9_LOJAFOR = '"+MV_PAR20+"' "
	EndIf
	If !Empty(MV_PAR21) .And. !Empty(MV_PAR22)
		_cQuery += " AND C5_EMISSAO >= '"+Dtos(MV_PAR21)+"' AND C5_EMISSAO <= '"+Dtos(MV_PAR22)+"' "
	EndIf
	If MV_PAR26 = 1 .And. Empty(MV_PAR01) .And. Empty(MV_PAR23) .And. IIf(SU7->(FieldPos("U7_OPESUP")) > 0,Posicione("SU7",3,xFilial("SU7")+RTrim(CUSERNAME),"U7_COD") <> SU7->U7_OPESUP,.T.)
		_cQuery += " AND UA_OPERADO = '"+SU7->U7_COD+"' "
	EndIf
	If !Empty(MV_PAR24) .And. !Empty(MV_PAR25)
		_cQuery += " AND C6_ENTREG >= '"+Dtos(MV_PAR24)+"' AND C6_ENTREG <= '"+Dtos(MV_PAR25)+"' "
	EndIf
	
	If _nX == 2
		_cQuery += " ORDER BY "
		If MV_PAR10 = 1
			_cQuery += "    C9_PEDIDO, C9_ITEM, C9_SEQUEN  "
		ElseIf MV_PAR10 = 2
			_cQuery += "    C9_CLIENTE, C5_NOMEREQ, C9_PRODUTO  "
		ElseIf MV_PAR10 = 3
			_cQuery += "    C9_PEDIDO, C6_DESCRI  "
		ElseIf MV_PAR10 = 4
			_cQuery += "    C9_PRODUTO, C9_PEDIDO  "
		EndIf
	EndIf
	
	_cQuery := ChangeQuery(_cQuery)
	
	TCQUERY _cQuery NEW ALIAS "CAD"
	
	If _nX == 1
		DbSelectArea("CAD")
		_nCount := CAD->TOTAL
		DbCloseArea()
	EndIf
Next

TcSetField("CAD","C9_DATALIB","D")
TcSetField("CAD","C7_DATPRF","D")
TcSetField("CAD","C6_ENTREG","D")
If MV_PAR14 = 3 .AND. MV_PAR09 = 2
	TcSetField("CAD","C7_DATPRF","D")
EndIf

DbSelectArea("SUA")
DbSetOrder(8)

DbSelectArea("SU7")
DbSetOrder(1)

DbSelectArea("CAD")
DbGoTop()
ProcRegua(_nCount)

While CAD->(!Eof())
	IncProc()
	If (SUA->(DbSeek(xFilial('SUA')+CAD->C9_PEDIDO)))
		If !Empty(Posicione("SU7",1,xFilial("SU7")+SUA->UA_OPERADO,"U7_COD"))
			If !Empty(MV_PAR16)
				If MV_PAR16 <> SU7->U7_POSTO
					CAD->(DbSkip())
					Loop
				EndIf
			EndIf
			If !Empty(MV_PAR23) .And. SU7->(FieldPos("U7_OPESUP")) > 0 
				If MV_PAR23 <> SU7->U7_OPESUP
					CAD->(DbSkip())
					Loop
				EndIf
			ElseIf MV_PAR26 = 1 .And. SUA->UA_OPERADO <> Posicione("SU7",3,xFilial("SU7")+RTrim(CUSERNAME),"U7_COD") .And. IIf(SU7->(FieldPos("U7_OPESUP")) > 0,SU7->U7_COD <> SU7->U7_OPESUP,.T.)
				CAD->(DbSkip())
				Loop
			EndIf
		EndIf
	Else
		If !Empty(MV_PAR16)
			CAD->(DbSkip())
			Loop
		EndIf
	EndIf
	RecLock("TC9",.T.)
	For _nX := 1 To Len(aFields)
		If !(Alltrim(aFields[_nX,1]) $ 'C9_OK,F2_DTENTR,')
			If aFields[_nX,2] = 'C'
				_cX := 'TC9->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
			Else
				_cX := 'TC9->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]
			EndIf
			_cX := &_cX
		EndIf
	Next
	If !Empty(TC9->C9_NFISCAL)
		If !Empty(_cCodRot)
			TC9->F2_DTENTR := Posicione("SF2",1,xFilial("SF2")+TC9->C9_NFISCAL+TC9->C9_SERIENF,"F2_DTENTR")
		EndIf
	EndIf
	If TC9->C9_BLEST = '02' .Or. Empty(TC9->C9_BLPRE) .Or. TC9->C9_BLEST = '10' .Or. !Empty(TC9->C9_NFISCAL) .Or. Empty(TC9->C9_BLCONF)
		TC9->C9_OK := ThisMark()
	Else
		TC9->C9_OK := _cMarca
	EndIf
	MsUnLock()
	_nSomaTot += (TC9->C9_QTDLIB * TC9->C9_PRCVEN)
	If Empty(TC9->C9_BLEST)
		_nSomaLib += (TC9->C9_QTDLIB * TC9->C9_PRCVEN)
	EndIf
	If !Empty(TC9->C9_BLEST) .And. TC9->C9_BLEST <> "10"
		_nSomaPen += (TC9->C9_QTDLIB * TC9->C9_PRCVEN)
	EndIf
	If Empty(TC9->C9_BLPRE) .Or. (!Empty(TC9->C9_BLCRED) .And. TC9->C9_BLCRED <> "10")
		_nSomaBlq += (TC9->C9_QTDLIB * TC9->C9_PRCVEN)
	EndIf
	CAD->(dBSkip())
End  
DbSelectArea("CAD")
DbCloseArea()
DbSelectArea("TC9")
DbGoTop()

_cIndex:=Criatrab(Nil,.F.)
_cChave:=StrTran(_cOrdem,",","+")
Indregua("TC9",_cIndex,_cChave,,,"Ordenando registros selecionados...")
DbSetIndex(_cIndex+ordbagext())

SysRefresh()
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVALIDPERG   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  

Static Function VALIDPERG(cPerg)
Local i
Local j

ssAlias:= Alias()
cPerg  := PADR(cPerg,len(sx1->x1_grupo))
aRegs  := {}
DbSelectArea("SX1")
DbSetOrder(1)
//   Array  Varia Ord  Pergunta               PI PE  Varia   Tp  Ta                    D P TC Vld  Vr        Df                      DI DE Cn Vr Df                             DI DE Cn Vr Df               DI DE Cn Vr Df               DI DE Cn Vr Df      DI DE Cn F3       Py Gr    Hp
//                                                                                                                                          1                                          2                            3                            4                   5
AAdd(aRegs,{cPerg,"01","Pedido De          ?","","","mv_ch1","C",06,                   0,0,"G","","mv_par01",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SC5",   "","",   "",""})
AAdd(aRegs,{cPerg,"02","Pedido Ate         ?","","","mv_ch2","C",06,                   0,0,"G","","mv_par02",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SC5",   "","",   "",""})
AAdd(aRegs,{cPerg,"03","Cliente De         ?","","","mv_ch3","C",TamSx3("A1_COD")[01], 0,0,"G","","mv_par03",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SA1CGC","","001","",""})
AAdd(aRegs,{cPerg,"04","Cliente Ate        ?","","","mv_ch4","C",TamSx3("A1_COD")[01], 0,0,"G","","mv_par04",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SA1CGC","","001","",""})
AAdd(aRegs,{cPerg,"05","Produto De         ?","","","mv_ch5","C",TamSx3("B1_COD")[01], 0,0,"G","","mv_par05",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SB1",   "","030","",""})
AAdd(aRegs,{cPerg,"06","Produto Ate        ?","","","mv_ch6","C",TamSx3("B1_COD")[01], 0,0,"G","","mv_par06",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SB1",   "","030","",""})
AAdd(aRegs,{cPerg,"07","Requisitante       ?","","","mv_ch7","C",06,                   0,0,"G","","mv_par07",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","LH2",   "","",   "",""})
AAdd(aRegs,{cPerg,"08","Vendedor           ?","","","mv_ch8","C",06,                   0,0,"G","","mv_par08",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SA3",   "","",   "",""})
AAdd(aRegs,{cPerg,"09","Situacao           ?","","","mv_ch9","N",01,                   0,0,"C","","mv_par09","Liberados"            ,"","","","","Pendentes"                   ,"","","","","Faturados"     ,"","","","","Bloqueados"    ,"","","","","Todos","","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"10","Ordem              ?","","","mv_cha","N",01,                   0,0,"C","","mv_par10","Pedido+Item+Sequencia","","","","","Cliente+Requisitante+Produto","","","","","Pedido+Produto","","","","","Produto+Pedido","","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"11","Filtra Conferidos  ?","","","mv_chb","N",06,                   0,0,"C","","mv_par11","Sim"                  ,"","","","","Nao"                         ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"12","Ordem de Compra    ?","","","mv_chc","C",15,                   0,0,"G","","mv_par12",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"13","Nota Fiscal        ?","","","mv_chd","C",06,                   0,0,"G","","mv_par13",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"14","Considera Compras  ?","","","mv_che","N",01,                   0,0,"C","","mv_par14","Nao"                  ,"","","","","Com Pedidos"                 ,"","","","","Sem Pedidos"   ,"","","","","Todos"         ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"15","Data Liberacao     ?","","","mv_chf","D",08,                   0,0,"G","","mv_par15",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"16","Grupo Atendimento  ?","","","mv_chg","C",02,                   0,0,"G","","mv_par16",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SU0",   "","",   "",""})
AAdd(aRegs,{cPerg,"17","NF Entrada         ?","","","mv_chh","C",06,                   0,0,"G","","mv_par17",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"18","Serie Entrada      ?","","","mv_chi","C",03,                   0,0,"G","","mv_par18",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"19","Fornecedor Entrada ?","","","mv_chj","C",TamSx3("A2_COD")[01], 0,0,"G","","mv_par19",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SA2",   "","001","",""})
AAdd(aRegs,{cPerg,"20","Loja Forn. Entrada ?","","","mv_chl","C",TamSx3("A2_LOJA")[01],0,0,"G","","mv_par20",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","002","",""})
AAdd(aRegs,{cPerg,"21","Data Emissao De    ?","","","mv_chm","D",08,                   0,0,"G","","mv_par21",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"22","Data Emissao Ate   ?","","","mv_chn","D",08,                   0,0,"G","","mv_par22",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"23","Operador Supervisor?","","","mv_cho","C",06,                   0,0,"G","","mv_par23",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","","SU7",   "","",   "",""})
AAdd(aRegs,{cPerg,"24","Data Entrega De    ?","","","mv_chp","D",08,                   0,0,"G","","mv_par24",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"25","Data Entrega Ate   ?","","","mv_chq","D",08,                   0,0,"G","","mv_par25",""                     ,"","","","",""                            ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
AAdd(aRegs,{cPerg,"26","Visualiza Todos Op.?","","","mv_chr","N",01,                   0,0,"C","","mv_par26","Nao"                  ,"","","","","Sim"                         ,"","","","",""              ,"","","","",""              ,"","","","",""     ,"","","",""   ,   "","",   "",""})
For i := 1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			EndIf
		Next
		MsUnlock()
	EndIf
Next
DbSelectArea(ssAlias)
Return (Nil) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVALIDPERG   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
  
Static Function Estoque()
If ExistBlock("TTMKC01")
	T_TTMKC01(TC9->C9_PRODUTO,TC9->C9_LOCAL)
Else
	T_TTMKC01(TC9->C9_PRODUTO,TC9->C9_LOCAL)
EndIf
sysREfresh()
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCancelaPend บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/  

Static Function CancelaPend()
Local cVar     := Nil
Local cTitulo  := STR0092 //"Itens nใo Entregues do Pedido"
Local lMark    := .F.
Local oOk      := LoadBitmap( GetResources(), "LBTIK" )//"LBTIK" OU "LBOK"
Local oNo      := LoadBitmap( GetResources(), "LBNO" )
Local oChk     := Nil
Local _nTotPen := 0

Private oDlg     := Nil
Private lChk     := .F.
Private oLbx := Nil
Private aVetor := {}

If MV_PAR10 <> 1
	MsgStop(STR0093) //"Esta somente pode ser utilizada com a ordem 1 de pedidos, parametro 10."
	Return
EndIf

DbSelectArea("TC9")
DbGotop()

While !Eof()
	If TC9->C9_BLEST <> "10" .And. TC9->C9_BLCRED <> "10"
		aAdd( aVetor, { lMark, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C6_DESCRI, C9_QTDLIB, C9_PRCVEN, C9_BLEST, C9_BLCRED })
		_nTotPen += (C9_QTDLIB*C9_PRCVEN)
	EndIf
	DbSkip()
End

If Len( aVetor ) == 0
	Aviso( cTitulo, STR0094, {STR0095} ) //"Nao existe itens pendentes neste pedido."###"Ok"
	DbSelectArea("TC9")
	DbGotop()
	Return
EndIf

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 100,005 TO 500,750 PIXEL

@ 10,05 LISTBOX oLbx VAR cVar FIELDS HEADER " ", STR0096, "Item", "Seq", STR0097, STR0098, STR0099, STR0100, STR0101, STR0102 ; //"Pedido"###"Produto"###"Descricao"###"Quantidade"###"Pre็o"###"Estoque"###"Credito"
                              SIZE 365,170 OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())
oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
                   aVetor[oLbx:nAt,2],;
                   aVetor[oLbx:nAt,3],;
                   aVetor[oLbx:nAt,4],;
                   aVetor[oLbx:nAt,5],;
                   aVetor[oLbx:nAt,6],;
                   aVetor[oLbx:nAt,7],;
                   aVetor[oLbx:nAt,8],;
                   aVetor[oLbx:nAt,9],;
                   aVetor[oLbx:nAt,10]}}
@ 185,05 CHECKBOX oChk VAR lChk PROMPT STR0103 SIZE 60,007 PIXEL OF oDlg ON CLICK(Iif(lChk,Marca(lChk),Marca(lChk))) //"Marca/Desmarca"
@ 186,80 SAY STR0104+Transform(_nTotPen,"@ER 999,999,999.99") SIZE 120,007 PIXEL OF oDlg //"Total Pendente: "
@ 185,170 BUTTON STR0105 SIZE 40,15 OF oDlg PIXEL ACTION Processa({||T_CriaOrcP(aVetor[oLbx:nAt,2])},STR0106) //"Gera Orc."###"Criando Novo Orcamento com Pendencias..."
DEFINE SBUTTON FROM 185,273 TYPE 1 ACTION Confirma() ENABLE OF oDlg
DEFINE SBUTTON FROM 185,313 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

dbSelectArea("TC9")
DbGotop()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarca       บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
  
Static Function Marca(lMarca)
Local i := 0
If Type("_nTotBMk") <> "U"
	_nTotBMk := 0
EndIf
For i := 1 To Len(aVetor)
	aVetor[i][1] := lMarca	
Next i
oLbx:Refresh()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConfirma    บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Confirma()
Local I
Local _nX
Local _aEliRes := {}

PRIVATE lOnUpdate  := .T.
PRIVATE l410Auto   := .F.
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}
PRIVATE aRotina    := MenuDef() 
PRIVATE cCadastro := STR0083 //"Visualiza็ใo de Pedidos de Venda"

If !MsgYesNo(STR0107) //"Confirma o cancelamento dos Itens Marcados ?"
	Return(.T.)
EndIf

oDlg:End()

_lPedAut := .F.

DBSelectArea('SC6')
DBSetOrder(1)

DBSelectArea('SC9')
DBSetOrder(1)

For i := 1 To Len(aVetor)
	
	If aVetor[i][1] .And. TC9->(DbSeek(aVetor[i][2]+aVetor[i][3]+aVetor[i][4]))
		
		_lFaz := .T.
		If Empty(aVetor[i][9])
			If !ValidCan(1)
				_lFaz := .F.
			EndIf
		Else
			If !ValidCan(2)
				_lFaz := .F.
			EndIf
		EndIf
		
		If _lFaz .And. SC6->(DBSeek(xFilial('SC6')+TC9->C9_PEDIDO+TC9->C9_ITEM+TC9->C9_PRODUTO)) .And. ;
			SC9->(DBSeek(xFilial('SC9')+TC9->C9_PEDIDO+TC9->C9_ITEM+TC9->C9_SEQUEN))
			IF SC9->C9_BLCRED <> "10" .AND. SC9->C9_BLEST <> "10"
				If AsCan(_aEliRes,SC9->C9_PEDIDO) = 0
					AaDd(_aEliRes,SC9->C9_PEDIDO)
				EndIf
				RecLock('SC9',.F.)
				SC9->C9_BLINF := Upper(Rtrim(CUSERNAME))+" "+dtoc(Date())+" "+time()+" h"
				MsUnlock()
				A460Estorna()
			EndIf
		EndIf
		
	EndIf
	
Next

If Len(_aEliRes) > 0 .And. MsgNoYes(STR0108+Chr(13)+Chr(10)+; //"Elimina os Residuos dos pedidos que foram excluidas as pendencias?"
	STR0109+Chr(13)+Chr(10)+; //"ATENวรO! SERม ELIMINADO O RESIDUO DO PEDIDO INTEIRO, NรO SOMENTE DO"
	STR0110) //"ITEM QUE FOI EXCLUIDA A PENDENCIA! CONFIRMA A OPERAวรO?"
	For _nX := 1 To Len(_aEliRes)
		If SC5->(DbSeek(xFilial("SC5")+_aEliRes[_nX]))
			Ma410Resid("SC5",SC5->(Recno()),2)
		EndIf
	Next
EndIf

DBSelectArea('TC9')
DBCloseArea()
FErase(cArq+".DBF")
Cria_TC9()
Processa({|| Monta_TC9() } ,STR0038) //"Refazendo do filtro de Informacoes dos Pedidos..."
SysRefresh()
MsgBox(STR0039,STR0040,'INFO') //'Clique em OK e no grid para atualizar a tela...'###'Informacao'

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidCan    บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ValidCan(_nTipo)
Local _lRet := .T.

If _nTipo = 1
	If !Empty(TC9->C9_BLPRE)
		If TC9->C9_BLCONF = 'OK'
			MsgStop(STR0029+TC9->C9_ITEM+STR0030+Chr(13)+; //'O Item '###' deve sair da expericao e voltar para o estoque antes'
			STR0031+Chr(13)+; //'do cancelamento, encaminhe o pedido ao estoque, para que possa'
			STR0032) //'realizar a operacao com sucesso.'
			_lRet := .F.
		ElseIf !Empty(TC9->C6_IMPRE) .And. SubStr(TC9->C6_IMPRE,1,1) <> "M"
			MsgStop('O Item '+TC9->C9_ITEM+STR0033+Chr(13)+; //' ja foi impresso Pedido, para que possa'
			STR0034) //'cancelar o item informe ao estoque para devolucao dos itens separados.'
			_lRet := .F.
		ElseIf SubStr(TC9->C6_IMPRE,1,1) == "M"
			MsgInfo('O Item '+TC9->C9_ITEM+STR0111) //' foi liberado e emitida Liberacao por entrada de Nota, certifique-se que o mesmo nao seguiu para separacao!'
		EndIf
	Else
		If TC9->C9_BLCONF = 'OK'
			MsgStop('O Item '+TC9->C9_ITEM+STR0030+Chr(13)+; //' deve sair da expericao e voltar para o estoque antes'
			STR0031+Chr(13)+; //'do cancelamento, encaminhe o pedido ao estoque, para que possa'
			STR0032) //'realizar a operacao com sucesso.'
			_lRet := .F.
		ElseIf !Empty(TC9->C6_IMPRE) .And. SubStr(TC9->C6_IMPRE,1,1) <> "M"
			If !MsgNoYes('O Item '+TC9->C9_ITEM+STR0112+Chr(13)+; //' ja foi impresso Romaneio, porem esta'
				STR0113) //'com bloqueio de regra de pre็o, confirma a exclusใo da libera็ใo do item?'
				_lRet := .F.
			EndIf
		ElseIf SubStr(TC9->C6_IMPRE,1,1) == "M"
			MsgInfo('O Item '+TC9->C9_ITEM+STR0111) //' foi liberado e emitida Liberacao por entrada de Nota, certifique-se que o mesmo nao seguiu para separacao!'
		EndIf
	EndIf
Else
	If Empty(TC9->C9_BLEST)
		If TC9->C9_BLCONF = 'OK'
			msgStop('O Item '+TC9->C9_ITEM+STR0042+Chr(13)+; //' deve sair da expedicao e voltar para o estoque antes'
			STR0031+Chr(13)+; //'do cancelamento, encaminhe o pedido ao estoque, para que possa'
			STR0032) //'realizar a operacao com sucesso.'
			Return(.T.)
		ElseIf !Empty(TC9->C6_IMPRE) .And. SubStr(TC9->C6_IMPRE,1,1) <> "M"
			MsgStop('O Item '+TC9->C9_ITEM+STR0033+Chr(13)+; //' ja foi impresso Pedido, para que possa'
			STR0034) //'cancelar o item informe ao estoque para devolucao dos itens separados.'
			Return(.T.)
		ElseIf SubStr(TC9->C6_IMPRE,1,1) == "M"
			MsgInfo('O Item '+TC9->C9_ITEM+STR0111) //' foi liberado e emitida Liberacao por entrada de Nota, certifique-se que o mesmo nao seguiu para separacao!'
		EndIf
	Else
		If !Empty(TC9->C6_IMPRE)
			MsgStop('O Item '+TC9->C9_ITEM+STR0114+Chr(13)+; //' ja foi impresso Romaneio de Separacao, e posteriormente'
			STR0115) //'ajustada a libera็ใo, certifique-se desta informa็ใo com a expedi็ใo!'
		EndIf
	EndIf
EndIf
Return(_lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHistorico   บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function Historico()

Local aSalvAmb := {}
Local aVetor   := {}
Local oDlg     := Nil
Local oLbx     := Nil
Local cTitulo  := STR0116 //"Historico Atendimento / Pedido"
Local cSitu    := ""
Local oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
Local oAmare   := LoadBitmap( GetResources(), "BR_AMARELO" )
Local oPreto   := LoadBitmap( GetResources(), "BR_PRETO" )
Local oVerme   := LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oAzul    := LoadBitmap( GetResources(), "BR_AZUL" )

Local _aLegenda := {{"BR_VERDE",   STR0117},; //"Liberado Estoque"
                    {"BR_AMARELO", STR0118},; //"Pendente Estoque"
                    {"BR_AZUL",    "Bloqueado Preco / Credito"},;
                    {"BR_VERMELHO",STR0119},; //"Eliminado"
                    {"BR_PRETO",   STR0120}} //"Faturado"

aSalvAmb := GetArea()

DbSelectArea("SUB")
DbSetOrder(1)

DbSelectArea("SUA")
DbSetOrder(1)

If SUA->(DbSeek(xFilial("SUA")+TC9->UA_NUM)) .And. SUB->(DbSeek(xFilial("SUB")+TC9->UA_NUM))
	
	While SUB->(!Eof()) .AND. SUB->UB_FILIAL == xFilial("SUB") .AND. SUB->UB_NUM == TC9->UA_NUM
		_nEntregue := 0
		_nLiberado := 0
		_nPendente := 0
		_nBloqueado:= 0
		_nValEntre := 0
		_nValLiber := 0
		_nValPende := 0
		_nValBloqu := 0
		If SC9->(DbSeek(xFilial("SC9")+SUA->UA_NUMSC5+SUB->UB_ITEM))
			While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SUA->UA_NUMSC5 .AND. SC9->C9_ITEM == SUB->UB_ITEM
				If SC9->C9_BLEST == '10' .And. SC9->C9_NFISCAL <> ''
					_nEntregue += SC9->C9_QTDLIB
					_nValEntre += SC9->(C9_QTDLIB * C9_PRCVEN)
				ElseIf SC9->C9_BLEST <> '10' .And. !Empty(SC9->C9_BLEST)
					_nPendente += SC9->C9_QTDLIB
					_nValPende += SC9->(C9_QTDLIB * C9_PRCVEN)
				ElseIf Empty(SC9->C9_BLEST)
					_nLiberado += SC9->C9_QTDLIB
					_nValLiber += SC9->(C9_QTDLIB * C9_PRCVEN)
				Else
					_nBloqueado+= SC9->C9_QTDLIB
					_nValBloqu += SC9->(C9_QTDLIB * C9_PRCVEN)
				EndIf
				SC9->(DbSkip())
			End
			If SUB->UB_QUANT == _nEntregue
				cSitu := "F"
			ElseIf _nBloqueado > 0
				cSitu := "B"
			ElseIf _nPendente > 0
				cSitu := "P"
			Else
				cSitu := "L"
			EndIf
		Else
			cSitu := "E"
		EndIf
		
		AaDd( aVetor, { cSitu, SUB->UB_NUM, SUB->UB_ITEM, SUB->UB_PRODUTO, SUB->UB_DESCRI, SUB->UB_QUANT, TransForm(SUB->UB_VRUNIT,"@ER 999,999.99"), TransForm(SUB->UB_VLRITEM,"@ER 999,999.99"), _nEntregue, _nPendente, _nLiberado, _nBloqueado } )
		SUB->(DbSkip())
	End
	
EndIf

If Len( aVetor ) == 0
	Aviso( cTitulo, "Nao existe dados de Or็amento para este pedido.", {"Ok"} )
	Return
EndIf

//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+
DEFINE MSDIALOG oDlg TITLE cTitulo+" - "+TC9->C9_PEDIDO FROM 100,005 TO 500,750 PIXEL
@ 10,10 LISTBOX oLbx FIELDS HEADER " ", STR0121, "Ite", STR0097, STR0098, STR0122, STR0123, STR0124, STR0120, STR0125 , STR0126 , STR0127; //"Or็amento"###"Produto"###"Descricao"###"Quant."###"Unitแrio"###"Total"###"Faturado"###"Pendente"###"Liberado"###"Bloqueado"
                     SIZE 365,170 OF oDlg PIXEL
oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1]=="F",oPreto,;
                       IIf(aVetor[oLbx:nAt,1]=="E",oVerme,;
                           IIf(aVetor[oLbx:nAt,1]=="P",oAmare,;
                               IIf(aVetor[oLbx:nAt,1]=="B",oAzul,oVerde)))),;
                               aVetor[oLbx:nAt,2],;
                               aVetor[oLbx:nAt,3],;
                               aVetor[oLbx:nAt,4],;
                               aVetor[oLbx:nAt,5],;
                               aVetor[oLbx:nAt,6],;
                               aVetor[oLbx:nAt,7],;
                               aVetor[oLbx:nAt,8],;
                               aVetor[oLbx:nAt,9],;
                               aVetor[oLbx:nAt,10],;
                               aVetor[oLbx:nAt,11],;
                               aVetor[oLbx:nAt,12]}}
@ 185,005 BUTTON STR0075 SIZE 35,10 ACTION BrwLegenda(OemToAnsi(cTitulo),STR0128,_aLegenda ) OF oDlg PIXEL //"Legenda"###" Legenda "
DEFINE SBUTTON FROM 185,313 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER
RestArea( aSalvAmb )
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCriaOrcP    บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function CriaOrcP(_cPed)
Local _aCOPArea := GetArea()
Local _aCabOrc  := {}
Local _aIteOrc  := {}
Local _aIteOrcD := {}
Local _nX, _nX2, _nX3
Local _nCount   := 0

SC9->(DbSetOrder(1))
SUA->(DbSetOrder(8))
If SUA->(DbSeek(xFilial("SUA")+_cPed))
	_nCount   := SUA->(FCount())
	ProcRegua(_nCount)
	For _nX := 1 To SUA->(FCount())
		IncProc()
		If !(Alltrim(SUA->(FieldName(_nX))) $ "UA_NUM/UA_EMISSAO/UA_CODOBS/UA_STATUS/UA_VALBRUT/UA_VALMERC/UA_VLRLIQ/UA_FINANC/UA_OPER/")
			AaDd(_aCabOrc,{SUA->(FieldName(_nX)),SUA->(FieldGet(_nX))})
		EndIf
	Next
	DbSelectArea("SUB")
	If SUB->(DbSeek(xFilial("SUB")+SUA->UA_NUM))
		While SUB->(!Eof()) .AND. SUB->UB_FILIAL == xFilial("SUB") .AND. SUB->UB_NUM == SUA->UA_NUM
			_aIteOrcD := {}
			_lCopia   := .F.
			If SC9->(DbSeek(xFilial("SC9")+SUB->(UB_NUMPV+UB_ITEMPV)))	 .And. !Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_NFISCAL)
				_lCopia := .T.
			EndIf
			If _lCopia
				_nCount := SUB->(FCount())
				ProcRegua(_nCount)
				For _nX := 1 To SUB->(FCount())
					IncProc()
					If !(Alltrim(SUB->(FieldName(_nX))) $ "UB_NUM/UB_ITEM/UB_NUMPV/UB_ITEMPV/UB_QTDANT")
						AaDd(_aIteOrcD,{SUB->(FieldName(_nX)),SUB->(FieldGet(_nX))})
					EndIf
				Next
				AaDd(_aIteOrc,_aIteOrcD)
			EndIf
			SUB->(DbSkip())
		End
	EndIf
	If Len(_aCabOrc) > 0 .And. Len(_aIteOrc) > 0
		_cNumero := TkNumero("SUA","UA_NUM")
		RecLock("SUA",.T.)
		SUA->UA_NUM     := _cNumero
		SUA->UA_EMISSAO := dDatabase
		SUA->UA_CODOBS  := ""
		SUA->UA_STATUS  := ""
		SUA->UA_OBSDCM  := "ORC. CRIADO COM PENDENCIAS DO PEDIDO: "+_cPed
		SUA->UA_OPER    := "2"
		_nCount := Len(_aCabOrc)
		ProcRegua(_nCount)
		For _nX := 1 To Len(_aCabOrc)
			IncProc()
			SUA->(&(_aCabOrc[_nX,1])) := _aCabOrc[_nX,2]
		Next
		SUA->UA_REQCLI  := Alltrim(SUA->UA_REQCLI)+"/"+_cPed
		SUA->UA_NUMSC5  := ""
		MsUnLock()
		_cItem  := "00"
		_nTotal := 0
		_nCount := Len(_aIteOrc)
		ProcRegua(_nCount)
		For _nX2 := 1 To Len(_aIteOrc)
			IncProc()
			_cItem := SomaIt(_cItem)
			RecLock("SUB",.T.)
			SUB->UB_NUM  := _cNumero
			SUB->UB_ITEM := _cItem
			For _nX3 := 1 To Len(_aIteOrc[_nX2])
				SUB->(&(_aIteOrc[_nX2,_nX3,1])) := _aIteOrc[_nX2,_nX3,2]
			Next
			MsUnLock()
			_nTotal += SUB->UB_VLRITEM
		Next
		RecLock("SUA",.F.)
		SUA->UA_VALBRUT := _nTotal
		SUA->UA_VALMERC := _nTotal
		SUA->UA_VLRLIQ  := _nTotal
		SUA->UA_FINANC  := _nTotal
		MsUnLock()
	EndIf
EndIf
If !Empty(_cNumero) .And. _nTotal > 0
	MsgInfo(STR0129+_cNumero+STR0130) //"Or็amento Numero: "###" Criado com sucesso!"
EndIf
RestArea(_aCOPArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTransLib    บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/    

Static Function TransLib()
Local cVar     := Nil
Local cTitulo  := STR0131 //"Transferencia de Libera็๕es para Outro Pedido"
Local lMark    := .F.
Local oChk     := Nil
Local nOpc     := 0

Private oDlg     := Nil
Private lChk     := .F.
Private oLbx := Nil
Private aVetor := {}
Private aPeds  := {}
Private _nTotBMk := 0
Private oOk      := LoaDbitmap( GetResources(), "LBTIK" )//"LBTIK" OU "LBOK"
Private oNo      := LoaDbitmap( GetResources(), "LBNO" )
Private oGetBMk  := Nil

DbSelectArea("TC9")
DbGotop()

While !Eof()
	If Empty(TC9->C9_BLEST) .And. Empty(Posicione("SE4",1,xFilial("SE4")+TC9->C5_CONDPAG,"E4_ACREDCM"))
		lMark := .F.
		aAdd( aVetor, { lMark, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C6_IMPRE, ;
		                Transform(C9_PRCVEN*C9_QTDLIB,"@ER 9,999,999.99"), ;
		                TransForm(C9_QTDLIB,"@ER 999999"), ;
		                Transform(C9_PRCVEN,"@ER 99,999.9999") })
		If AsCan(aPeds,C9_PEDIDO) = 0
			AaDd(aPeds,C9_PEDIDO)
		EndIf
	EndIf
	DbSkip()
End

If Len( aVetor ) == 0
	Aviso( cTitulo, STR0132, {"Ok"} ) //"Nao existem itens a liberados!"
	DbSelectArea("TC9")
	DbGotop()
	Return
EndIf
//LIST BOX
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 100,005 TO 500,750 PIXEL

@ 10,05 LISTBOX oLbx VAR cVar FIELDS HEADER " ", STR0096, STR0133, STR0134, STR0097, STR0135, STR0124, STR0099, STR0100 ; //"Pedido"###"Item"###"Seq"###"Produto"###"Romaneio"###"Total"###"Quantidade"###"Pre็o"
                              SIZE 365,170 OF oDlg PIXEL ON DblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())
oLbx:SetArray( aVetor )
oLbx:bLine := {|| { SelTranfL(),;
                    aVetor[oLbx:nAt,2],;
                    aVetor[oLbx:nAt,3],;
                    aVetor[oLbx:nAt,4],;
                    aVetor[oLbx:nAt,5],;
                    aVetor[oLbx:nAt,6],;
                    aVetor[oLbx:nAt,7],;
                    aVetor[oLbx:nAt,8],;
                    aVetor[oLbx:nAt,9]}}
@ 185,05 CHECKBOX oChk  VAR lChk PROMPT STR0103 SIZE 60,007 PIXEL OF oDlg ON CLICK(Iif(lChk,Marca(lChk),Marca(lChk))) //"Marca/Desmarca"
@ 185,223 BUTTON STR0136 SIZE 40,15 OF oDlg PIXEL ACTION Processa({||nOpc:= 1,T_DeixaP()},STR0137) //"Deixar Pen."###"Aguarde Deixando Itens Marcados como Pendentes..."
@ 185,273 BUTTON STR0138 SIZE 40,15 OF oDlg PIXEL ACTION Processa({||nOpc:= 1,T_TraLibB(aPeds)},STR0139) //"Liberar"###"Aguarde Liberando Pedidos..."
@ 185,323 BUTTON STR0140 SIZE 40,15 OF oDlg PIXEL ACTION oDlg:End() //"Cancela"
ACTIVATE MSDIALOG oDlg CENTER

If nOpc = 1
	MsgBox(STR0141,STR0040,'INFO') //'Feche a tela para atualizar as informa็๕es...'###'Informacao'
EndIf

DbSelectArea("TC9")
DbGotop()

Return .T.

Static Function SelTranfL()
If aVetor[oLbx:nAt,1]
	Return(oOk)
Else
	Return(oNo)
EndIf
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTraLibB     บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TraLibB(aPeds)
Local _aCOPArea := GetArea()
Local _nX
Local cPerg2 := Padr("TTK06B",Len(SX1->X1_GRUPO))
Local _nQuant := 0
Local _nQuantP:= 0
Local _nQuantL:= 0
Local _nQuantPD:= 0
Local _nQuantLD:= 0
Local _nQuantPO:= 0
Local _nQuantLO:= 0
Local _nRecC5, _nRecC6, _nRecC9
Local _aEliRes := {}
Local _lEfetivado := .F.
Local _lNaoEst := .T.

// Variaveis necessarias para a rotina de estorno de liberacoes
PRIVATE lOnUpdate  := .T.
PRIVATE l410Auto   := .F.
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}
PRIVATE aRotina    := MenuDef() 
PRIVATE cCadastro := STR0083 //"Visualiza็ใo de Pedidos de Venda"

If !Pergunte(cPerg2)
	RestArea(_aCOPArea)
	Return
EndIf
ProcRegua(Len(aVetor))
For _nX := 1 To Len(aVetor)
	IncProc()
	SC9->(DbSetOrder(1))
	SC6->(DbSetOrder(1))
	SC5->(DbSetOrder(1))
	
	If aVetor[_nX,1] .And. ;
		SC9->(DbSeek(xFilial("SC9")+aVetor[_nX,2]+aVetor[_nX,3])) .And. ;
		SC6->(DbSeek(xFilial("SC6")+aVetor[_nX,2]+aVetor[_nX,3])) .And. ;
		SC5->(DbSeek(xFilial("SC5")+aVetor[_nX,2]))
		_nQuantL := Val(aVetor[_nX,8])
		If MV_PAR02 = 2
			_nQuant := T_TraLibC(_nQuantL)
		Else
			_nQuant := _nQuantL
		EndIf
		If _nQuant > 0 .And. !Empty(MV_PAR01)
			
			_lNaoEst := .T.
			
			_nRecC5 := SC5->(Recno())
			_nRecC6 := SC6->(Recno())
			_nRecC9 := SC9->(Recno())
			
			SC6->(DbSetOrder(2))
			If !SC5->(DbSeek(xFilial("SC5")+MV_PAR01)) .Or.;
				!SC6->(DbSeek(xFilial("SC6")+aVetor[_nX,5]+MV_PAR01))
				MsgStop(STR0142) //"Pedido ou Item de Destino nao encontrados!"
				RestArea(_aCOPArea)
				Return
			Else
				_nQuantLO := 0
				_nQuantPO := 0
				While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == aVetor[_nX,2] .AND. SC9->C9_ITEM == aVetor[_nX,3]
					If SC9->C9_PRODUTO == aVetor[_nX,5] .And. Empty(SC9->C9_BLEST)
						If !Empty(SC6->C6_IMPRE)
							MsgStop(STR0143+aVetor[_nX,2]+"/"+aVetor[_nX,3]+STR0144+Chr(13)+Chr(10)+; //"Uma sequencia deste Pedido e Item "###" jแ foi enviada para separacao, "
							        STR0145) //"nao ้ possivel efetuar a transferencia, at้ que retorne o pedido!"
							_lNaoEst  := .T.
							_nQuantLO := 0
							Exit
						EndIf
						_nQuantLO += SC9->C9_QTDLIB
					ElseIf SC9->C9_PRODUTO == aVetor[_nX,5] .And. !Empty(SC9->C9_BLEST) .And. SC9->C9_BLEST <> '10'
						_nQuantPO += SC9->C9_QTDLIB
					EndIf
					SC9->(DbSkip())
				End
				If _nQuantLO > 0
					_lNaoEst := .F.
				EndIf
			EndIf
			
			If !_lNaoEst
				
				_nQuantPD := 0
				_nQuantLD := 0
				If SC9->(DbSeek(xFilial('SC9')+MV_PAR01))
					DbSelectArea("SC9")
					While SC9->(!Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == MV_PAR01
						If SC9->C9_PRODUTO = aVetor[_nX,5] .And.;
							SC9->C9_BLEST <> '10' .And. !Empty(SC9->C9_BLEST)
							_nQuantPD += SC9->C9_QTDLIB
						ElseIf SC9->C9_PRODUTO = aVetor[_nX,5] .And.;
							SC9->C9_BLEST <> '10' .And. Empty(SC9->C9_BLEST)
							_nQuantLD += SC9->C9_QTDLIB
						EndIf
						SC9->(DbSkip())
					End
				EndIf
				
				If _nQuantPD > 0
					
					SC5->(DbGoTo(_nRecC5))
					SC6->(DbGoTo(_nRecC6))
					SC9->(DbGoTo(_nRecC9))
					
					SB2->(DbSeek(xFilial("SB2")+SC9->(C9_PRODUTO+C9_LOCAL)))
					
					Begin Transaction
					
					While SC9->(!Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == aVetor[_nX,2] .AND. SC9->C9_ITEM == aVetor[_nX,3]
						RecLock('SC9',.F.)
						SC9->C9_BLINF := "TRANSF(EO):"+Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
						MsUnlock()
						A460Estorna()
						SC9->(DbSkip())
					End
					
					If _nQuant < _nQuantLO
						_nQuantL := _nQuantLO-_nQuant
						_nQuantP := _nQuantPO+_nQuant
						MaLibDoFat(SC6->(Recno()),_nQuantL,.T.,.T.,.F.,.T.,.T.,.F.) //,{SC6->C6_LOCAL})
						If MV_PAR03 = 2
							MaLibDoFat(SC6->(Recno()),SC6->(C6_QTDVEN-C6_QTDENT-_nQuantL),.T.,.F.,.F.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
						EndIf
					ElseIf _nQuant > _nQuantPD .And. _nQuantLO >= _nQuantPD
						_nQuantL := _nQuantLO-_nQuantPD
						_nQuantP := _nQuantPD
						MaLibDoFat(SC6->(Recno()),_nQuantL,.T.,.T.,.F.,.T.,.T.,.F.) //,{SC6->C6_LOCAL})
						If MV_PAR03 = 2
							MaLibDoFat(SC6->(Recno()),SC6->(C6_QTDVEN-C6_QTDENT-_nQuantL),.T.,.F.,.F.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
						EndIf
					Else
						If MV_PAR03 = 2
							MaLibDoFat(SC6->(Recno()),SC6->(C6_QTDVEN-C6_QTDENT),.T.,.F.,.F.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
						Else
							AaDd(_aEliRes,aVetor[_nX,2])
						EndIf
					EndIf
					
					_lEfetivado := .F.
					If SC9->(DbSeek(xFilial('SC9')+MV_PAR01))
						DbSelectArea("SC9")
						While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial('SC9') .AND. SC9->C9_PEDIDO == MV_PAR01
							If SC9->C9_PRODUTO = aVetor[_nX,5] .And.;
								SC9->C9_BLEST <> '10'
								
								RecLock('SC9',.F.)
								SC9->C9_BLINF := "TRANSF(ED):"+Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
								MsUnlock()
								A460Estorna()
								
								_lEfetivado := .T.
							EndIf
							SC9->(DbSkip())
						End
					EndIf
					
					SC5->(DbSeek(xFilial("SC5")+MV_PAR01))
					SC6->(DbSetOrder(2))
					SC6->(DbSeek(xFilial("SC6")+aVetor[_nX,5]+MV_PAR01))
					
					If _lEfetivado
						If _nQuantPD <> _nQuant
							If _nQuant > _nQuantPD
								_nQuant := _nQuantPD
							EndIf
							_nQuantL := _nQuantLD + _nQuant
							_nQuantP := _nQuantPD - _nQuant
							MaLibDoFat(SC6->(Recno()),_nQuantL,.T.,.T.,.F.,.T.,.T.,.F.) //,{SC6->C6_LOCAL})
							If _nQuantP > 0
								MaLibDoFat(SC6->(Recno()),_nQuantP,.T.,.F.,.F.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
							EndIf
						Else
							_nQuantL := _nQuantLD + _nQuant
							MaLibDoFat(SC6->(Recno()),_nQuantL,.T.,.T.,.F.,.T.,.T.,.F.) //,{SC6->C6_LOCAL})
						EndIf
						
					EndIf
					
					SB2->(MsUnLock())
					End Transaction
					DbCommitAll()
					
					If !_lEfetivado
						MsgStop(STR0146+MV_PAR01+STR0147+aVetor[_nX,5]+Chr(13)+Chr(10)+; //"Nao efetivada liberacoes para o Pedido: "###" Produto: "
						        STR0148+Chr(13)+Chr(10)+; //" O mesmo ficarแ disponivel na quantidade que foi estornada da Origem!"
						        STR0149) //" Utilize a Liberacao de Pendencias apos o processamento desta rotina."
					EndIf
					
				Else
					MsgStop(STR0146+MV_PAR01+STR0147+aVetor[_nX,5]+Chr(13)+Chr(10)+; //"Nao efetivada liberacoes para o Pedido: "###" Produto: "
					        STR0150) //" O mesmo nao possui quantidade pendente no destino!"
				EndIf
			Else
				MsgStop(STR0146+MV_PAR01+STR0147+aVetor[_nX,5]+Chr(13)+Chr(10)+; //"Nao efetivada liberacoes para o Pedido: "###" Produto: "
				        STR0151+aVetor[_nX,2]+"/"+aVetor[_nX,3]+"/"+aVetor[_nX,4]+STR0152) //" O Pedido+Item+Sequencia:"###" nao possui liberacoes."
			EndIf
			
		EndIf
	EndIf
	
Next

If Len(aVetor) > 0 .And. Len(_aEliRes) > 0 .And. MV_PAR03 = 1 .And. MsgNoYes(STR0153+Chr(13)+Chr(10)+; //"Elimina os Residuos dos pedidos origem que foram transferidas as libera็๕es?"
                                                                             STR0109+Chr(13)+Chr(10)+; //"ATENวรO! SERม ELIMINADO O RESIDUO DO PEDIDO INTEIRO, NรO SOMENTE DO"
                                                                             STR0110) //"ITEM QUE FOI EXCLUIDA A PENDENCIA! CONFIRMA A OPERAวรO?"
	For _nX := 1 To Len(aVetor)
		If SC5->(DbSeek(xFilial("SC5")+aVetor[_nX,2])) .And. AsCan(_aEliRes,aVetor[_nX,2]) > 0
			Ma410Resid("SC5",SC5->(Recno()),2)
		EndIf
	Next
EndIf

MsgInfo(STR0154) //"Operacao Concluida"
oDlg:End()

RestArea(_aCOPArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDeixaP      บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function DeixaP()
Local _aCOPArea := GetArea()
Local _nX

// Variaveis necessarias para a rotina de estorno de liberacoes
PRIVATE lOnUpdate  := .T.
PRIVATE l410Auto   := .F.
PRIVATE aAutoCab   := {}
PRIVATE aAutoItens := {}
PRIVATE aRotina    := MenuDef() 
PRIVATE cCadastro := STR0083 //"Visualiza็ใo de Pedidos de Venda"
//

If !MsgNoYes(STR0155) //"Confirma deixar as libera็๕es marcadas como pendentes?"
	Return
EndIf

ProcRegua(Len(aVetor))
For _nX := 1 To Len(aVetor)
	IncProc()
	SC9->(DbSetOrder(1))
	SC6->(DbSetOrder(1))
	SC5->(DbSetOrder(1))
	
	If aVetor[_nX,1] .And. ;
		SC9->(DbSeek(xFilial("SC9")+aVetor[_nX,2]+aVetor[_nX,3]+aVetor[_nX,4])) .And. ;
		SC6->(DbSeek(xFilial("SC6")+aVetor[_nX,2]+aVetor[_nX,3])) .And. ;
		SC5->(DbSeek(xFilial("SC5")+aVetor[_nX,2]))
		
		_nQuantP := Val(aVetor[_nX,8])
		
		SB2->(DbSeek(xFilial("SB2")+SC9->(C9_PRODUTO+C9_LOCAL)))
		
		Begin Transaction
		
		RecLock('SC9',.F.)
		SC9->C9_BLINF := "PEND:"+Upper(Rtrim(CUSERNAME))+" "+dtoc(date())+" "+time()+" h"
		MsUnlock()
		A460Estorna()
		
		MaLibDoFat(SC6->(Recno()),_nQuantP,.T.,.F.,.T.,.F.,.F.,.F.) //,{SC6->C6_LOCAL})
		
		SB2->(MsUnLock())
		End Transaction
		DbCommitAll()
		
	EndIf
	
Next

MsgInfo(STR0154) //"Operacao Concluida"
oDlg:End()

RestArea(_aCOPArea)
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTraLibC     บ Autor ณ EWERTON C TOMAZ    บ Data ณ  07/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Template Function TraLibC(nQtd)
Local oParam
Local _nQtd := nQtd

Define msDialog oParam from 63,181 To 250,600 Title STR0159 Pixel Of oMainWnd //"Transferencia de Libera็๕es"
@ 016,009 Say               STR0099 Size   41, 7 Pixel Of oParam //"Quantidade"
@ 015,050 Get _nQtd PICTURE STR0160 Size    5, 9 Pixel Of oParam Valid _nQtd > 0 //"@ER 999999"
@ 030,009 Say               STR0161 Size  200, 7 Pixel Of oParam //"Ao definir a quantidade desejada para liberar, o item do pedido de destino"
@ 040,009 Say               STR0162 Size  200, 7 Pixel Of oParam //"somente serแ liberado esta quantidade ficando pendente o saldo restante."
Define sButton From 080,140 Type 1 Action Close(oParam) Enable Of oParam
Define sButton From 080,170 Type 2 Action {||_nQtd:=0,Close(oParam)} Enable Of oParam
Activate msDialog oParam Center
Return(_nQtd)   

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun็ใo    ณ MenuDef  ณ Autor ณ Conrado Q. Gomes      ณ Data ณ 11.12.06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TTMKA11                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/           
                 
Static Function MenuDef() 
Local aRotina := {{STR0081, "AxPesqui",   0,1,0,.F.},; //"Pesquisar"
                  {STR0082, "A410Visual", 0,2,0,NIL}} //"Visualizar"
Return(aRotina)