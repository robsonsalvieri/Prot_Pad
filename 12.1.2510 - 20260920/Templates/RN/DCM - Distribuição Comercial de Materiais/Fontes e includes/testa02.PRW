#INCLUDE "testa02.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTESTA02   บAutor  ณEwerton C Tomaz     บ Data ณ  04/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de conferencia por codigo de barras					  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template function TESTA02()

CHKTEMPLATE("DCM")  

Private _cStatus    := .T.
Private _nTipo      := 0
Private _cArquivo   := ""
Private _cArquivo2  := ""
Private _LconfOK    := ""
Private _cUniPed    := _cDesc := _cMarca := ""
Private oEstoque
Private _cCodigo
Private _cQtde
Private _cQtdeLib
Private aProdutos
Private _aArqSel    := {"SB1","SC6","SC9"}
Private _cCampos    := "C9_BLCONF,C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_PRODUTO,C6_DESCRI,C9_QTDLIB,"+;
                       "C6_LOCALIZ,C9_CLIENTE,C9_VEND,C6_FILIAL,B1_CODBAR,C6_UM,C6_SEGUM,"+;
                       "B1_CONV,"
Private _LJaConcluido
Private aCampos     := {}
Private aFields     := {}
Private cQueryCad   := ""
Private cArq        := ""
Private _cIndex     := ""

aadd(aCampos,{"C9_PEDIDO" ,"Pedido"                        })
aadd(aCampos,{"C9_ITEM"   ,"Item"                          })
If GetMv("MV_CFCEGA") = "N"
	aadd(aCampos,{"B1_CODBAR" ,STR0001                    }) //"Cod.Barras"
	aadd(aCampos,{"C6_DESCRI" ,STR0002                     }) //"Descricao"
	aadd(aCampos,{"C6_UM"     ,STR0003                         }) //"1a.UN"
	aadd(aCampos,{"C9_QTDLIB" ,STR0004 ,"@E 999999"       }) //"Qtde.1a.UN"
	aadd(aCampos,{"C6_SEGUM"  ,STR0005                         }) //"2a.UN"
	aadd(aCampos,{"C9_QTDLIB2",STR0006 ,"@E 999999"       }) //"Qtde.2a.UN"
	aadd(aCampos,{"B1_CONV"   ,STR0007  ,"@E 999999"       }) //"Embalagem"
Endif
aadd(aCampos,{"C9_PRODUTO",STR0008                       }) //"Produto"
aadd(aCampos,{"C9_SEQUEN" ,STR0009                     }) //"Sequencia"
aadd(aCampos,{"C6_LOCALIZ",STR0010,                  }) //"Localizacao"
aadd(aCampos,{"C9_CLIENTE",STR0011                       }) //"Cliente"
aadd(aCampos,{"C9_VEND"   ,STR0012                      }) //"Vendedor"

_LSai := .T.
_cPedido :=space(6)
while _LSai
	_cCodigo    := space(TamSX3("B1_COD")[01])
	_cQtde      :=0
	_cQtdeLib   :=0
	aProdutos   :={}
	
	define msDialog oEstoque from 0,0 to 120,290 title STR0013 pixel //"Conferencia"
	@ 005,005 say STR0014 size  90,07 //"INFORME O NUMERO DO PEDIDO"
	@ 018,005 say STR0015 size 21,07  //"Pedido:"
	@ 018,037 get _cPedido  size 49,08 valid(busca(1)) F3 ("SC5")
	
	Define sButton from 040,080 type 1 action{||telaped(),close(oEstoque)} enable of oEstoque
	Define sButton from 040,110 type 2 action{||close(oEstoque),_LSai :=.F.} enable of oEstoque
	Activate msDialog oEstoque center
End  
If Select("TC9") > 0
	DbSelectArea('TC9')
	DbCloseArea()
Endif
If file(cArq+OrdBagExt())
	fErase(cArq+OrdBagExt())
EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณbusca     บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static function busca(_nTipo)
If _nTipo =1
	If empty(_cPedido)
		msgInfo(STR0016) //"Informe o n๚mero do Pedido."
	Else              
		DbSelectArea('SC5')
		_cX := posicione('SC5',1,xFilial('SC5')+_cPedido,'C5_NUM')
		If !empty(_cX)
			return(.T.)
		Else
			msgStop(STR0017) //"Pedido nใo cadastrado."
			Return(.F.)
		EndIf
	Endif
Endif
If _nTipo =2 .And. !Empty(_cCodigo)
	_cQtdeLib  :=0
	_cCodigo2  :=  Space(TamSX3("B1_COD")[01])
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+alltrim(_cCodigo))
		_cCodigo2 :=SB1->B1_COD
	Else
		DbSetOrder(5)
		If DbSeek(xFilial("SB1")+alltrim(_cCodigo))
			_cCodigo2 :=SB1->B1_COD
		Else
			DbSelectArea("SLK")
			DbSetOrder(1)
			If DbSeek(xFilial("SLK")+Alltrim(_cCodigo))
				DbSelectArea("SB1")
				DbSetOrder(1)
				If dbSeek(xFilial("SB1")+alltrim(SLK->LK_CODIGO))
					_cCodigo2 :=SB1->B1_COD
				Endif
			Else
				MsgStop(STR0018) //"Codigo de Barras nao encontrado. Digite [F8] para cadastrar."
				DbSelectArea("SB1")
				Return(.F.)
			Endif
		Endif
	Endif
	If !Empty(TC9->C6_SEGUM)
		_cUniPed :=TC9->C6_SEGUM
	Else
		_cUniPed :=TC9->C6_UM
	Endif
	_cDesc := SB1->B1_DESC
	_cMarca:= SB1->B1_FABRIC
	if !empty(_cCodigo2)
		DbSelectArea("TC9")
		DbGoTop()
		_LJaConcluido :=.T.
		while TC9->(!eof())
			If TC9->C9_BLCONF <> 'OK'
				_LJaConcluido:=.F.
			Endif
			DbSkip()
		End  
		DbGoTop()
		_LMen :=.F.
		While TC9->(!Eof())
			_LMen :=.F.
			If (Rtrim(_cCodigo2) =alltrim(TC9->C9_PRODUTO) .and. TC9->C9_BLCONF <>'OK')
				If !Empty(TC9->C6_SEGUM)
					_cQtdeLib :=(TC9->C9_QTDLIB / TC9->B1_CONV)
				Else
					_cQtdeLib :=TC9->C9_QTDLIB
				Endif
				Exit
			ElseIf (Rtrim(_cCodigo2) =alltrim(TC9->C9_PRODUTO) .and. TC9->C9_BLCONF ='OK')
				_LMen := .T.
			Endif
			DbSkip()
			If (Rtrim(_cCodigo2) <>alltrim(TC9->C9_PRODUTO) .and. _LMen)
				If !_LJaConcluido
					msgStop(STR0019+alltrim(_cCodigo2)+STR0020) //"Produto "###" ja coletado."
					Return(.F.)
				Else
					fecha_coleta()
				Endif
			Endif
		End  
		If (_cQtdeLib =0).and.!_LMen
			msgStop(STR0021) //"Produto nใo disponivel no Pedido para Coleta."
			Return(.F.)
		Endif
	Endif
Endif
If _nTipo =3 .and. !Empty(_cCodigo)
	if _cQtde > 0
		_nPosicao :=aScan(aProdutos,{|x|x[1]=TC9->C9_PRODUTO.and.x[3]=TC9->C9_ITEM.and.x[4]=TC9->C9_SEQUEN})
		if _nPosicao <>0
			if (_cQtde > _cQtdeLib).or.(aProdutos[_nPosicao,2]+_cQtde > _cQtdeLib)
				msgStop(STR0022) //"Quantidade nao confere com o Pedido."
				Return(.F.)
			ElseIf (_cQtde<_cQtdeLib)
				aProdutos[_nPosicao,2] +=_cQtde
				close(oColetar)
			Endif
		Else
			aAdd(aProdutos,{TC9->C9_PRODUTO,_cQtde,TC9->C9_ITEM,TC9->C9_SEQUEN,TC9->C6_SEGUM,TC9->B1_CONV})
			_nPosicao :=aScan(aProdutos,{|x|x[1]=TC9->C9_PRODUTO.and.x[3]=TC9->C9_ITEM.and.x[4]=TC9->C9_SEQUEN})
			close(oColetar)
		Endif
		if (aProdutos[_nPosicao,2] =_cQtdeLib) .and. (TC9->C9_BLCONF <>'OK')
			DbSelectArea("TC9")
			DbSetOrder(1)
			If DbSeek(aProdutos[_nPosicao,1]+alltrim(aProdutos[_nPosicao,3])+alltrim(aProdutos[_nPosicao,4]))
				RecLock("TC9",.F.)
				TC9->C9_BLCONF :='OK'
				msUnlock()
				_LconfOK :=.T.
				Close(oColetar)
				DlgRefresh(oDlgPed)
				SysRefresh()
			Endif
		Endif
	Else
		msgStop(STR0023) //"Informe a quantidade coletada."
		Return(.F.)
	Endif
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณtelaped   บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static Function telaped()
@ 00,00 to 450,780 Dialog oDlgPed Title STR0024 //"Liberacao da Conferencia"

cria_TC9()
DbSelectArea('TC9')
@ 05,02 to 200,390 Browse "TC9" Enable "!C9_BLCONF" Fields aCampos

@ 205,005 Button STR0025	Size 45,18 Action LOJA210() //"Cod._Barras"
@ 205,055 Button STR0026	Size 45,18 Action coletar() //"Co_letar"
@ 205,290 button STR0027	Size 45,18 Action finaliza() //"_Conferencia OK"
@ 205,340 button STR0028	Size 45,18 Action sair() //"_Sair"

Processa({|| monta_TC9()},STR0029) //"Selecionando registros..."
Activate Dialog oDlgPed Centered
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcria_TC9  บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static Function cria_TC9()
Local _nX
DbSelectArea('SX3')
DbSetOrder(1)
aFields     :={}
For _nX := 1 To Len(_aArqSel)
	DbSeek(_aArqSel[_nX])
	while !eof() .And. _aArqSel[_nX] = X3_ARQUIVO
		if (alltrim(X3_CAMPO)+"," $_cCampos)
			aadd(aFields,{X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL})
		Endif
		DbSkip()
	End  
Next
AADD(aFields,{"C9_QTDLIB2","N",9,2})
If Select("TC9") > 0
	DbSelectArea('TC9')
	DbCloseArea()
Endif
cArq:=criatrab(aFields,.T.)
dbUseArea(.t.,,cArq,"TC9")
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณmonta_TC9 บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function monta_TC9()
Local _nCount
Local _nX

For _nX := 1 To 2
	If _nX = 1
		cQueryCad :="select count(*) as TOTAL from "
	Else
		cQueryCad :="select " +substr(_cCampos,1,len(_cCampos)-1) +" from "
	Endif
	cQueryCad +=RetSqlName('SC6')+" , "
	cQueryCad +=RetSqlName('SC9')+" , "
	cQueryCad +=RetSqlName('SB1')+"   "
	cQueryCad +=" where "
	cQueryCad +=RetSqlName('SC6')+".D_E_L_E_T_ <>'*' and "
	cQueryCad +=RetSqlName('SC9')+".D_E_L_E_T_ <>'*' and "
	cQueryCad +=RetSqlName('SB1')+".D_E_L_E_T_ <>'*' "
	cQueryCad +=" and C6_NUM ='"+_cPedido +"'"
	cQueryCad +=" and C6_FILIAL ='"+xFilial("SC6")+"'"
	cQueryCad +=" and C9_FILIAL ='"+xFilial("SC9")+"'"
	cQueryCad +=" and B1_FILIAL ='"+xFilial("SB1")+"'"
	cQueryCad +=" and C6_NUM =C9_PEDIDO "
	cQueryCad +=" and C6_ITEM =C9_ITEM "
	cQueryCad +=" and C9_BLEST =' ' "
	cQueryCad +=" and C9_BLPRE <> ' ' "	
	cQueryCad +=" and C6_IMPRE <> ' ' "
	cQueryCad +=" and C6_PRODUTO =B1_COD"
	If _nX <> 1
		cQueryCad +=" order by C9_PEDIDO ,C9_ITEM ,C9_SEQUEN"
	Endif

	tcQuery cQueryCad new alias "CAD"
	If _nX = 1
		_nCount := CAD->TOTAL
		DbCloseArea()
	Endif
Next
DbSelectArea("CAD")
DbGoTop()

ProcRegua(_nCount)
while CAD->(!eof())
	IncProc()
	RecLock("TC9",.T.)
	For _nX := 1 to Len(aFields)
		If aFields[_nX,2] ='C'
			_cX :='TC9->'+aFields[_nX,1]+' :=alltrim(CAD->'+aFields[_nX,1]+')'
		Else
			If aFields[_nX,1] ="C9_QTDLIB2"
				If !empty(CAD->C6_SEGUM)
					_cx :='TC9->C9_QTDLIB2 :=CAD->C9_QTDLIB /CAD->B1_CONV'
				Else
					_cx :='TC9->C9_QTDLIB2 :=0'
				Endif
			Else
				_cX :='TC9->'+aFields[_nX,1]+' :=CAD->'+aFields[_nX,1]
			Endif
		Endif
		_cX :=&_cX
	Next
	MsUnLock()
	CAD->(dbSkip())
End  
DbSelectArea("CAD")
DbCloseArea()
DbSelectArea("TC9")
DbGoTop()

_cIndex :=criatrab(nil,.F.)
_cChave :="C9_PRODUTO+C9_ITEM+C9_SEQUEN"
IndRegua("TC9",_cIndex,_cChave,,,STR0030) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())

SysRefresh()
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcoletar   บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static Function coletar()
lSai3 :=.T.
While lSai3
	coletar_PRO(lSai3)
end  
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณcoletar_PROบAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function coletar_PRO()
Private oColetar,_LSai2,_cCodigo
SetKey(119 , { || LOJA210()       }) // F8
SetKey(120 , { || fecha_coleta()  }) // F9
SetKey(123 , { || quanti_coleta() }) // F12
_LconfOK :=.F.
DbSelectArea("TC9")
DbGoTop()
_cStatus :=.T.
while TC9->(!eof())
	If empty(TC9->C9_BLCONF)
		_cStatus :=.F.
		Exit
	Endif
	DbSkip()
End  
DbGoTop()

If (!_cStatus)
	_LSai2   := .T.
	_cCodigo := Space(TamSX3("B1_COD")[01])
	While _LSai2
		_cQtde   :=1
		_cDesc   := _cMarca := ""
		Define MsDialog oColetar From 0,0 to 195,300 Title STR0031 Pixel //"Coletar"
		@ 005,005 Say STR0032 Size 90,07 //"COLETAR PRODUTO"
		@ 016,005 Say STR0033 //"Produto:"
		@ 016,040 Get _cCodigo      Size 105,08 Valid(if(_LSai2,busca(2),.T.) .and. If(GetMV('MV_CFQTDCB')='S',busca(3),.T.))
		@ 027,005 Get _cDesc        Size 142,08 When .F.
		@ 038,005 Get _cMarca       Size 142,08 When .F.
		
		If GetMV('MV_CFQTDCB')='S'
			@ 049,005 Say STR0034 //"Quantidade: "
			@ 049,040 Get _cQtde            Size 80,08 picture "@E 99999999" when .F.
			@ 049,123 Say _cUniPed
			
			@ 061,005 Say STR0035 //"Coletado: "
			@ 061,040 Get If(!Empty(_cCodigo) .and. (aScan(aProdutos,{|x|x[1]=SB1->B1_COD .and. x[3]=TC9->C9_ITEM .and. x[4]=TC9->C9_SEQUEN})>0),;
			                 aProdutos[aScan(aProdutos,{|x|x[1]=SB1->B1_COD .and. x[3]=TC9->C9_ITEM .and. x[4]=TC9->C9_SEQUEN}),2],;
			                 0);
			          Size 80,08 Picture "@E 99999999" When .F.
			@ 061,123 Say _cUniPed
			@ 088,005 Say STR0036 //"[F12] Informar Quantidade"
		Else
			@ 049,005 Say STR0034 //"Quantidade: "
			@ 049,040 Get _cQtde            Size 80,08 Picture "@E 99999999" Valid validaqtd() .and. busca(3)
			@ 061,005 Say STR0035 //"Coletado: "
			@ 061,040 Get if(!Empty(_cCodigo) .and. (aScan(aProdutos,{|x|x[1]=SB1->B1_COD .and. x[3]=TC9->C9_ITEM .and. x[4]=TC9->C9_SEQUEN})>0),;
			                 aProdutos[aScan(aProdutos,{|x|x[1]=SB1->B1_COD .and. x[3]=TC9->C9_ITEM .and. x[4]=TC9->C9_SEQUEN}),2],;
			                 0);
			          Size 80,08 Picture "@E 99999999" when .F.
			@ 061,123 Say _cUniPed
		Endif
		
		@ 072,005 Say STR0037 //"[F8]  Cadastra Cod.Barras"
		@ 080,005 Say STR0038 //"[F9]  Sair"
		
		Define sButton From 085,110 Type 1 Action{||busca(3),close(oColetar)} Enable of oColetar
		Activate MsDialog oColetar Center
	End  
Else
	msgStop(STR0039) //"Nao ha mais itens a serem coletados neste Pedido."
	SetKey(119, )
	SetKey(120, )
	SetKey(123, )
	fecha_coleta()
Endif
If (_LconfOK .and. !_LSai2)
	DbSelectArea("TC9")
	DbGoTop()
EndIf
SetKey(119, )
SetKey(120, )
SetKey(123, )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณvalidaqtd  บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                             บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function validaqtd()
If _cQtde<>_cQtdeLib
	MsgStop(STR0040) //'Quantidade Diferente da Pedida!'
	Return(.F.)
Endif
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณquanti_coletaบAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

Static Function quanti_coleta()
Private oColQuanti
If !empty(_cCodigo)
	_nada :=""
	Define MsDialog oColQuanti From 0,0 to 100,400 Title STR0041 Pixel //"Coletar Quantidade"
	@ 06,05 Say STR0042	      	Size 040,07 //"Codigo: "
	@ 06,40 Get _cCodigo 	  	Size 105,08 When .F.
	@ 18,05 Say STR0043 	  	Size 040,07 //"Descricao: "
	@ 18,40 get SB1->B1_DESC	Size 150,08 When .F.
	@ 30,05 Say STR0034 		Size 040,07 //"Quantidade: "
	@ 30,40 Get _cQtde         	Size 040,08 Picture "@E 99999999" Valid(valida_qtde())
	@ 30,86 Say _cUniPed
	@ 42,005 Get _nada
	Activate MsDialog oColQuanti Center
Else
	msgStop(STR0044) //"Informe o codigo do produto a ser coletado."
EndIf
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณvalida_qtde  บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function valida_qtde()
If (_cQtde >=1)
	Close(oColQuanti)
	Close(oColetar)
Else
	MsgStop(STR0045) //"Quantidade invalida."
Endif
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfecha_coleta บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static Function fecha_coleta()
_cCodigo = Space(TamSX3("B1_COD")[01])
If Type('oColetar') <> 'U'
	close(oColetar)
Endif
_LSai2 :=.F.
LSai3  :=.F.
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfinaliza     บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Static Function finaliza()
Local i
If Len(aProdutos) >0
	_QtdeOK     :=.T.
	_atualizado :=.F.
	DbSelectArea("SC9")
	DbSetOrder(1)
	For i :=1 to Len(aProdutos)
		If DbSeek(xFilial("SC9")+alltrim(_cPedido)+aProdutos[i,3]+aProdutos[i,4])
			If ((aProdutos[i,2] < SC9->C9_QTDLIB) .And. Empty(aProdutos[i,5])).or.;
				((aProdutos[i,6]*aProdutos[i,2] < SC9->C9_QTDLIB) .And. !Empty(aProdutos[i,5]))
				_QtdeOk :=.F.
				msgStop(STR0046) //"Quantidade coletada nao confere com o Pedido."
				Exit
			Endif
		Endif
	Next
	DbSelectArea("TC9")
	DbGoTop()
	While !Eof()
		If Empty(TC9->C9_BLCONF)
			_QtdeOk :=.F.
			msgStop(STR0047) //"Faltam Itens a serem Conferidos no Pedido!"
			DbGoTop()
			Exit
		Endif
		DbSkip()
	End  
	DbSelectArea("SC9")
	If (_QtdeOK)
		For i :=1 to Len(aProdutos)
			If DbSeek(xFilial("SC9")+alltrim(_cPedido)+aProdutos[i,3]+aProdutos[i,4])
				recLock("SC9",.F.)
				SC9->C9_BLCONF :=STR0048 //"OK"
				SC9->C9_BLINF  := RTRIM(FUNNAME())+' '+ Upper(cUserName)+" "+dtoc(Date())+" "+time()+" h"
				msUnlock()
				_atualizado :=.T.
			Endif
		Next
		If (_atualizado)
			aProdutos :={}
			//			msgInfo("Coleta concluida.")
			etiqueta_VOL()
			sair()
		Endif
	Endif
Else
	msgStop(STR0049) //"Nao ha produtos coletados."
Endif
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณetiqueta_VOL บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/        

Static Function etiqueta_VOL()
Private oEtiqueta
Private _cVolume := Space(3)
Private _nPesol  := 0
Private _nPbruto := 0
Private _nCubagem:= 0

If (SC5->C5_NUM =_cPedido)
	_cVolume :=str(SC5->C5_VOLUME1,3)
	_nPesol  :=SC5->C5_PESOL
	_nPbruto :=SC5->C5_PBRUTO
	_nCubagem:=SC5->C5_CUBAGEM
	Define MsDialog oEtiqueta From 0,0 to 177,300 Title STR0050 Pixel //"Volume"
	
	@ 005,005 Say STR0051	 Size 90,07 //"INFORME O VOLUME"
	@ 018,005 Say STR0052    Size 35,07 //"Quantidade:"
	@ 018,045 Get _cVolume   Size 45,08
	@ 030,005 Say STR0053    Size 35,07 //"Peso Liquido:"
	@ 030,045 Get _nPesol    Size 50,08 Picture "@E 999,999.99"
	@ 042,005 Say STR0054    Size 35,07 //"Peso Bruto:"
	@ 042,045 Get _nPbruto   Size 50,08 Picture "@E 999,999.99"
	@ 054,005 Say STR0055    Size 35,07 //"Cubagem   :"
	@ 054,045 Get _nCubagem  Size 50,08 Picture "@E 999,999.99"
	
	Define sButton From 070,085 Type 1 Action {||grava_VOL(),close(oEtiqueta)} Enable Of oEtiqueta
	Define sButton From 070,115 Type 2 Action close(oEtiqueta) Enable of oEtiqueta
	Activate MsDialog oEtiqueta center
Else
	msgStop(STR0056) //"Pedido nao encontrado, consulte o administrador da rede."
	return(.F.)
Endif 

If ExistBlock("TESTA03ETQ")
	ExecBlock("TESTA03ETQ")
Else
	If (!Empty(SC5->C5_REQCLI) .or. !Empty(SC5->C5_NOMEREQ) .or. !Empty(SC5->C5_ENDENT)) .And. GetMv('MV_IMPETIC')='S'
		T_TestR02(_cPedido,Val(_cVolume))
	EndIf
EndIf
	
Return	.T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณgrava_VOL    บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function grava_VOL()
DbSelectArea("SC5")
recLock("SC5",.F.)
SC5->C5_VOLUME1 :=val(_cVolume)
SC5->C5_PESOL   :=_nPesol
SC5->C5_PBRUTO  :=_nPbruto
SC5->C5_CUBAGEM :=_nCubagem
MsUnlock()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณsair		   บAutor  ณMicrosiga           บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                               บฑฑ
ฑฑบ          ณ                                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                 

Static Function sair()
DbSelectArea("TC9")
DbCloseArea()
Close(oDlgPed)
If file(cArq+OrdBagExt())
	FErase(cArq+OrdBagExt())
Endif
Return
